/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$BILLING_PERIOD
IS
    -- Author  : VANO
    -- Created : 21.06.2022 14:46:31
    -- Purpose : Функції роботи з розрахунковими періодами

    g_save_job_messages   INTEGER := 2;

    PROCEDURE close_period (              --p_bp_id billing_period.bp_id%TYPE,
                            p_bp_Ids     IN     VARCHAR2,
                            p_messages      OUT SYS_REFCURSOR);

    PROCEDURE open_period (p_bp_id          billing_period.bp_id%TYPE,
                           p_messages   OUT SYS_REFCURSOR);
END API$BILLING_PERIOD;
/


/* Formatted on 8/12/2025 5:48:50 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$BILLING_PERIOD
IS
    l_hs         histsession.hs_id%TYPE;
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

    PROCEDURE write_bp_log (p_bpl_bp        bp_log.bpl_bp%TYPE,
                            p_bpl_hs        bp_log.bpl_hs%TYPE,
                            p_bpl_st        bp_log.bpl_st%TYPE,
                            p_bpl_message   bp_log.bpl_message%TYPE,
                            p_bpl_st_old    bp_log.bpl_st_old%TYPE,
                            p_bpl_tp        bp_log.bpl_tp%TYPE:= 'SYS')
    IS
    BEGIN
        --друга частина буде завжди виконуватись, неважливо перша is null чи is not null
        --а отже будуть кожний раз створюватись нові сесії
        --l_hs := NVL(p_bpl_hs, TOOLS.GetHistSession);
        l_hs := p_bpl_hs;

        IF l_hs IS NULL
        THEN
            l_hs := TOOLS.GetHistSession;
        END IF;

        INSERT INTO bp_log (bpl_id,
                            bpl_bp,
                            bpl_hs,
                            bpl_st,
                            bpl_message,
                            bpl_st_old,
                            bpl_tp)
             VALUES (0,
                     p_bpl_bp,
                     l_hs,
                     p_bpl_st,
                     p_bpl_message,
                     p_bpl_st_old,
                     NVL (p_bpl_tp, 'SYS'));
    END;

    PROCEDURE close_period (              --p_bp_id billing_period.bp_id%TYPE,
                            p_bp_ids     IN     VARCHAR2, -- ідентифікатори періодів, які треба закрити через кому
                            p_messages      OUT SYS_REFCURSOR)
    IS
        g_messages     TOOLS.t_messages := TOOLS.t_messages ();

        l_bp           billing_period%ROWTYPE;
        l_bp_new       billing_period%ROWTYPE;
        l_cnt          INTEGER;

        --l_msg bp_log.bpl_message%TYPE;
        l_errors_cnt   INTEGER;

        PROCEDURE write_to_logs (p_msg   bp_log.bpl_message%TYPE,
                                 p_tp    VARCHAR2 DEFAULT 'I')
        IS
        BEGIN
            write_bp_log (l_bp.bp_id,
                          l_hs,
                          l_bp.bp_st,
                          p_msg,
                          NULL);
            TOOLS.add_message (
                g_messages,
                p_tp,
                uss_ndi.Rdm$msg_Template.Getmessagetext (p_msg));
        END;
    BEGIN
        l_hs := NVL (l_hs, TOOLS.GetHistSession);

        --  raise_application_error(-20000, p_bp_ids);

        DELETE FROM tmp_ac_nst_list
              WHERE 1 = 1;

        API$ACCRUAL.init_nst_list;


        TOOLS.add_message (g_messages, 'I', 'Розпочато закриття періоду!');

        FOR xx IN (    SELECT TO_NUMBER (REGEXP_SUBSTR (p_bp_ids,
                                                        '[^,]+',
                                                        1,
                                                        LEVEL))    AS bp_id,
                              LEVEL                                AS num
                         FROM DUAL
                   CONNECT BY REGEXP_SUBSTR (p_bp_ids,
                                             '[^,]+',
                                             1,
                                             LEVEL)
                                  IS NOT NULL)
        LOOP
            SELECT *
              INTO l_bp
              FROM billing_period
             WHERE bp_id = xx.bp_id;

            TOOLS.add_message (
                g_messages,
                'I',
                   'Передано для закриття: bp_class'
                || l_bp.bp_class
                || '; bp_tp'
                || l_bp.bp_tp
                || '; bp_org'
                || l_bp.bp_org);

            IF l_bp.bp_st = 'Z'
            THEN
                TOOLS.add_message (g_messages, 'E', 'Період вже закритий!');
                CONTINUE;
            END IF;

            l_errors_cnt := 0;

            /*--Кількість справ, по яких за вказаний місяць рішення в стані "нараховано", але немає нарахувань
            SELECT COUNT(*)
            INTO l_cnt
            FROM personalcase
            WHERE com_org = l_bp.bp_org
              AND EXISTS (SELECT 1
                          FROM pc_decision, pd_accrual_period dap, tmp_ac_nst_list
                          WHERE pd_pc = pc_id
                            AND pdap_pd = pd_id
                            AND dap.history_status = 'A'
                            AND pdap_start_dt <= LAST_DAY(l_bp.bp_month)
                            AND pdap_stop_dt >= l_bp.bp_month
                            AND pd_nst = x_nst
                            AND pd_st = 'S')
              AND NOT EXISTS (SELECT 1
                              FROM accrual
                              WHERE ac_pc = pc_id
                                AND ac_month = l_bp.bp_month);

            l_errors_cnt := l_errors_cnt + l_cnt;

            IF l_cnt > 0 THEN
              write_to_logs(chr(38)||'82#'||l_cnt, 'E');
            END IF;

            --Кількість справ, по яких за вказаний місяць є нарахуваня в станах, відмінних від "Підтверджено"
            SELECT COUNT(*)
            INTO l_cnt
            FROM personalcase
            WHERE com_org = l_bp.bp_org
              AND EXISTS (SELECT 1
                          FROM accrual
                          WHERE ac_pc = pc_id
                            AND ac_month = l_bp.bp_month)
              AND NOT EXISTS (SELECT 1
                              FROM accrual
                              WHERE ac_pc = pc_id
                                AND ac_month = l_bp.bp_month
                                AND ac_st IN ('R', DECODE(l_bp.bp_class, 'V', 'RV', 'RP')));

            l_errors_cnt := l_errors_cnt + l_cnt;*/

            IF l_cnt > 0
            THEN
                write_to_logs (CHR (38) || '85#' || l_cnt, 'E');
            END IF;

            IF l_errors_cnt > 0
            THEN
                write_to_logs (CHR (38) || '83#' || l_errors_cnt, 'E');
            ELSIF l_errors_cnt = 0
            THEN
                NULL;
                --!!!Тут закриття періоду!!!
                write_to_logs (
                       'Закриваємо період '
                    || TO_CHAR (l_bp.bp_month, 'MM.YYYY')
                    || ' по '
                    || l_bp.bp_tp
                    || '!');

                UPDATE billing_period
                   SET bp_st = 'Z', bp_hs_close = l_hs
                 WHERE bp_id = l_bp.bp_id;

                l_bp_new := l_bp;
                l_bp_new.bp_id := 0;
                l_bp_new.bp_month := ADD_MONTHS (l_bp_new.bp_month, 1);

                write_to_logs (
                       'Відкриваємо період '
                    || TO_CHAR (l_bp_new.bp_month, 'MM.YYYY')
                    || ' по '
                    || l_bp_new.bp_tp
                    || '!');

                MERGE INTO billing_period
                     USING (SELECT l_bp_new.bp_month     AS x_month,
                                   l_bp_new.bp_tp        AS x_tp,
                                   l_bp_new.bp_class     AS x_class,
                                   'R'                   AS x_st,
                                   l_bp_new.com_org      AS x_com_org,
                                   l_bp_new.bp_org       AS x_org
                              FROM DUAL)
                        ON (    bp_month = x_month
                            AND bp_tp = x_tp
                            AND bp_class = x_class
                            AND bp_org = x_org)
                WHEN MATCHED
                THEN
                    UPDATE SET bp_st = x_st, bp_hs_close = NULL
                WHEN NOT MATCHED
                THEN
                    INSERT     (bp_id,
                                bp_month,
                                bp_tp,
                                bp_class,
                                bp_st,
                                com_org,
                                bp_org)
                        VALUES (0,
                                x_month,
                                x_tp,
                                x_class,
                                x_st,
                                x_com_org,
                                x_org);

                --INSERT INTO billing_period VALUES l_bp_new;
                write_to_logs (CHR (38) || '84');
            ELSE
                raise_application_error (
                    -20000,
                    'Помилка підрахунку кількості помилок закриття періоду!');
            END IF;

            --Вважається, що якщо сюди дійшло, то все ОК і можна коммітити трансакцію або ніяких важливих змін не зроблено.
            COMMIT;
        END LOOP;

        TOOLS.add_message (g_messages, 'I', 'Завершено закриття періоду!');

        OPEN p_Messages FOR SELECT * FROM TABLE (g_messages);
    END;

    PROCEDURE open_period (p_bp_id          billing_period.bp_id%TYPE,
                           p_messages   OUT SYS_REFCURSOR)
    IS
        g_messages     TOOLS.t_messages := TOOLS.t_messages ();
        l_bp           billing_period%ROWTYPE;
        l_cnt          INTEGER;
        l_errors_cnt   INTEGER;

        PROCEDURE write_to_logs (p_msg   bp_log.bpl_message%TYPE,
                                 p_tp    VARCHAR2 DEFAULT 'I')
        IS
        BEGIN
            write_bp_log (l_bp.bp_id,
                          l_hs,
                          l_bp.bp_st,
                          p_msg,
                          NULL);
            TOOLS.add_message (
                g_messages,
                p_tp,
                uss_ndi.Rdm$msg_Template.Getmessagetext (p_msg));
        END;
    BEGIN
        l_hs := NVL (l_hs, TOOLS.GetHistSession);
        TOOLS.add_message (g_messages, 'I', 'Розпочато відкриття періоду!');

        SELECT *
          INTO l_bp
          FROM billing_period
         WHERE bp_id = p_bp_id;

        l_errors_cnt := 0;

        SELECT COUNT (*)
          INTO l_cnt
          FROM accrual a, billing_period b
         WHERE     a.com_org = bp_org
               AND ac_month > bp_month
               AND bp_id = l_bp.bp_id;

        IF l_cnt > 0
        THEN
            write_to_logs (CHR (38) || '87#' || l_cnt, 'E');
        END IF;

        l_errors_cnt := l_errors_cnt + l_cnt;

        SELECT COUNT (*)
          INTO l_cnt
          FROM payroll a, billing_period b
         WHERE     a.com_org = bp_org
               AND pr_month > bp_month
               AND bp_id = l_bp.bp_id;

        IF l_cnt > 0
        THEN
            write_to_logs (CHR (38) || '88#' || l_cnt, 'E');
        END IF;

        IF l_errors_cnt > 0
        THEN
            write_to_logs (CHR (38) || '86#' || l_cnt, 'E');
        ELSIF l_errors_cnt = 0
        THEN
            UPDATE billing_period
               SET bp_st = 'Z'
             WHERE     bp_tp = l_bp.bp_tp
                   AND bp_class = l_bp.bp_class
                   AND bp_org = l_bp.bp_org
                   AND bp_month > l_bp.bp_month;

            UPDATE billing_period
               SET bp_st = 'R', bp_hs_close = NULL
             WHERE bp_id = p_bp_id;
        ELSE
            raise_application_error (
                -20000,
                'Помилка підрахунку кількості помилок відкриття періоду!');
        END IF;

        TOOLS.add_message (g_messages, 'I', 'Завершено відкриття періоду!');

        OPEN p_Messages FOR SELECT * FROM TABLE (g_messages);
    END;
END API$BILLING_PERIOD;
/