/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$PD_INIT
IS
    -- Author  : OLEKSII
    -- Created : 25.06.2024 13:43:21
    -- Purpose : Створення рішення

    --========================================================================--
    --  Функція формування проектів рішень про призначення на основі звернення
    --  p_mode 1=з p_ap_id, 2=з таблиці tmp_work_ids 3=з p_ap_id у авторежимі  4=з таблиці tmp_work_ids у авторежимі
    --========================================================================--
    PROCEDURE init_pc_decision_by_appeals (p_mode           INTEGER,
                                           p_ap_id          appeal.ap_id%TYPE,
                                           p_messages   OUT SYS_REFCURSOR);
END API$PD_INIT;
/


/* Formatted on 8/12/2025 5:49:11 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$PD_INIT
IS
    g_end_war_dt   DATE;

    --=============================================================
    --#85988
    --Копіювання документів оцінки потреб, що надійшли з візіту
    --=============================================================
    PROCEDURE Create_Pd_Document
    IS
        CURSOR pdd IS
            SELECT pd_ap          AS x_ap,
                   apd_id         AS x_apd,
                   pd_id          AS x_pd,
                   pdo.pdo_id     AS x_pdo
              FROM pc_decision
                   JOIN tmp_work_ids ON x_id = pd_ap
                   JOIN ap_document apd ON apd_ap = pd_ap
                   LEFT JOIN pd_document pdo
                       ON pdo.pdo_pd = pd_id AND pdo.pdo_apd = apd.apd_id
             WHERE apd_ndt IN (804, 818, 819);

        l_pdo   NUMBER;
    BEGIN
        FOR rec IN pdd
        LOOP
            IF rec.x_pdo IS NULL
            THEN
                l_pdo := id_pd_document (0);

                INSERT INTO pd_document (pdo_id,
                                         pdo_pd,
                                         pdo_doc,
                                         pdo_dh,
                                         pdo_apd,
                                         pdo_ap,
                                         pdo_app,
                                         pdo_aps,
                                         pdo_ndt,
                                         history_status)
                    SELECT l_pdo     AS x_id,
                           rec.x_pd,
                           apd.apd_doc,
                           apd.apd_dh,
                           apd.apd_id,
                           rec.x_ap,
                           apd.apd_app,
                           apd_aps,
                           apd.apd_ndt,
                           apd.history_status
                      FROM ap_document apd
                     WHERE apd_id = rec.x_apd;

                INSERT INTO pd_document_attr (pdoa_id,
                                              pdoa_pdo,
                                              pdoa_pd,
                                              pdoa_nda,
                                              pdoa_val_int,
                                              pdoa_val_sum,
                                              pdoa_val_id,
                                              pdoa_val_dt,
                                              pdoa_val_string,
                                              history_status)
                    SELECT 0     AS id,
                           l_pdo,
                           rec.x_pd,
                           apda.apda_nda,
                           apda.apda_val_int,
                           apda.apda_val_sum,
                           apda.apda_val_id,
                           apda.apda_val_dt,
                           apda.apda_val_string,
                           apda.history_status
                      FROM ap_document_attr apda
                     WHERE     apda.apda_apd = rec.x_apd
                           AND apda.history_status = 'A';
            ELSE
                UPDATE pd_document
                   SET (pdo_doc, pdo_dh, history_status) =
                           (SELECT apd.apd_doc,
                                   apd.apd_dh,
                                   apd.history_status
                              FROM ap_document apd
                             WHERE apd_id = pdo_apd)
                 WHERE pdo_id = rec.x_pdo;

                UPDATE pd_document_attr pdoa
                   SET history_status = 'H'
                 WHERE pdoa.pdoa_pdo = rec.x_pdo;

                INSERT INTO pd_document_attr (pdoa_id,
                                              pdoa_pdo,
                                              pdoa_pd,
                                              pdoa_nda,
                                              pdoa_val_int,
                                              pdoa_val_sum,
                                              pdoa_val_id,
                                              pdoa_val_dt,
                                              pdoa_val_string,
                                              history_status)
                    SELECT 0     AS id,
                           rec.x_pdo,
                           rec.x_pd,
                           apda.apda_nda,
                           apda.apda_val_int,
                           apda.apda_val_sum,
                           apda.apda_val_id,
                           apda.apda_val_dt,
                           apda.apda_val_string,
                           apda.history_status
                      FROM ap_document_attr apda
                     WHERE     apda.apda_apd = rec.x_apd
                           AND apda.history_status = 'A';
            END IF;
        END LOOP;
    END;

    --=============================================================
    PROCEDURE calc_pd (P_PD_ID IN NUMBER)
    IS
        l_PAY_CUR   SYS_REFCURSOR;
    BEGIN
        UPDATE pc_decision t
           SET t.com_wu = COALESCE (tools.GetCurrWu, t.com_wu)
         WHERE t.pd_id = P_PD_ID;

        api$calc_pd.calc_pd (1, p_pd_id, l_pay_cur);
    END;

    --=============================================================
    PROCEDURE calc_pd_RC (P_PD_ID NUMBER, p_rc_dt DATE)
    IS
        l_messages   SYS_REFCURSOR;
    BEGIN
        UPDATE pc_decision t
           SET t.com_wu = COALESCE (tools.GetCurrWu, t.com_wu)
         WHERE t.pd_id = P_PD_ID;

        api$calc_pd.calc_pd (p_mode          => 1,
                             p_pd_id         => p_pd_id,
                             p_ic_tp         => 'RC.START_DT',
                             p_ic_start_dt   => p_rc_dt,
                             p_messages      => l_messages);
    END;

    --=============================================================
    PROCEDURE calc_pd_RC (P_PD_ID         NUMBER,
                          p_rc_start_dt   DATE,
                          p_rc_stop_dt    DATE)
    IS
        l_messages   SYS_REFCURSOR;
    BEGIN
        UPDATE pc_decision t
           SET t.com_wu = COALESCE (tools.GetCurrWu, t.com_wu)
         WHERE t.pd_id = P_PD_ID;

        api$calc_pd.calc_pd (p_mode          => 1,
                             p_pd_id         => p_pd_id,
                             p_ic_tp         => 'RC.START_DT',
                             p_ic_start_dt   => p_rc_start_dt,
                             p_ic_stop_dt    => p_rc_stop_dt,
                             p_messages      => l_messages);
    END;

    --=============================================================
    PROCEDURE calc_income_for_pd (P_PD_ID IN NUMBER)
    IS
        p_messages   SYS_REFCURSOR;
    BEGIN
        api$calc_income.calc_income_for_pd (1,
                                            P_PD_ID,
                                            0,
                                            p_messages);
    END;

    --=============================================================
    PROCEDURE move_pd_income (p_pd_id_old NUMBER, p_pd_id_new NUMBER)
    IS
        l_pic_id   NUMBER;
    BEGIN
        DELETE FROM pd_income_log
              WHERE pil_pid IN
                        (SELECT pid_id
                           FROM pd_income_detail
                                JOIN pd_income_calc ON pid_pic = pic_id
                          WHERE pic_pd = p_pd_id_new);

        DELETE FROM pd_income_detail
              WHERE pid_pic IN (SELECT pic_id
                                  FROM pd_income_calc
                                 WHERE pic_pd = p_pd_id_new);

        DELETE FROM pd_income_calc
              WHERE pic_pd = p_pd_id_new;

        l_pic_id := id_pd_income_calc (0);

        INSERT INTO pd_income_calc (pic_id,
                                    pic_st,
                                    pic_dt,
                                    pic_pc,
                                    pic_pd,
                                    pic_total_income_6m,
                                    pic_plot_income_6m,
                                    pic_month_income,
                                    pic_members_number,
                                    pic_member_month_income,
                                    pic_limit)
            SELECT l_pic_id,
                   pic_st,
                   pic_dt,
                   pic_pc,
                   p_pd_id_new,
                   pic_total_income_6m,
                   pic_plot_income_6m,
                   pic_month_income,
                   pic_members_number,
                   pic_member_month_income,
                   pic_limit
              FROM pd_income_calc
             WHERE pic_pd = p_pd_id_old;

        DELETE FROM tmp_work_set1
              WHERE 1 = 1;

        INSERT INTO tmp_work_set1 (x_id1, x_id2)
            SELECT pid.pid_id, id_pd_income_detail (0)
              FROM pd_income_detail pid
             WHERE pid_pic IN (SELECT pic_id
                                 FROM pd_income_calc
                                WHERE pic_pd = p_pd_id_old);


        INSERT INTO pd_income_detail (pid_id,
                                      pid_pic,
                                      pid_sc,
                                      pid_fact_sum,
                                      pid_app,
                                      pid_calc_sum,
                                      pid_month,
                                      pid_min_zp,
                                      pid_koef,
                                      pid_is_family_member)
            SELECT x_id2,
                   l_pic_id,
                   pid_sc,
                   pid_fact_sum,
                   pid_app,
                   pid_calc_sum,
                   pid_month,
                   pid_min_zp,
                   pid_koef,
                   pid_is_family_member
              FROM pd_income_detail JOIN tmp_work_set1 ON pid_id = x_id1;

        INSERT INTO pd_income_log (pil_id, pil_pid, pil_message)
            SELECT 0, x_id2, pil_message
              FROM pd_income_log JOIN tmp_work_set1 ON pil_pid = x_id1;
    END;

    --====================================================================================--
    PROCEDURE gen_pd_num (p_pc_id NUMBER, p_hs IN histsession.hs_id%TYPE)
    IS
        l_lock_init   TOOLS.t_lockhandler;
        l_lock        TOOLS.t_lockhandler;
        l_num         VARCHAR2 (2000);
        g_messages    TOOLS.t_messages := TOOLS.t_messages ();
    BEGIN
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
                            FROM appeal,
                                 personalcase,
                                 pc_decision,
                                 uss_ndi.v_ndi_service_type,
                                 pc_account
                           WHERE     ap_pc = p_pc_id
                                 AND ap_pc = pc_id
                                 AND pd_pc = pc_id
                                 AND pd_ap_reason = ap_id
                                 AND pd_nst = nst_id
                                 AND pd_num IS NULL
                                 AND pd_pa = pa_id)
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

            l_num := API$PC_DECISION.gen_pd_num (xx.pc_id);

            UPDATE pc_decision
               SET pd_num = l_num
             WHERE pd_id = xx.pd_id;

            --#81214 20221104
            API$PC_ATTESTAT.Check_pc_com_org (xx.pd_id, SYSDATE, p_hs);

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
                p_hs,
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
    EXCEPTION
        WHEN OTHERS
        THEN
            BEGIN
                TOOLS.release_lock (l_lock_init);
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;

            RAISE;
    END;

    --====================================================================================--
    PROCEDURE Process_ap_tp_O_641 (p_hs IN histsession.hs_id%TYPE)
    IS
        pay_method   pd_pay_method%ROWTYPE;

        -- 641 послуга
        CURSOR ap_tp_o_641 IS
            SELECT ap.ap_id,
                   ap.ap_num,
                   ap.ap_reg_dt,
                   ap.ap_st,
                   app.app_id, --app.app_fn||' '||app.app_mn||' '||app.app_ln AS app_fio,
                   app.app_sc,
                   pc_id,
                   (SELECT COUNT (pd.pd_id)
                      FROM pc_decision pd
                     WHERE     pd_pc = pc_id
                           AND (   ap.ap_reg_dt BETWEEN pd.pd_start_dt
                                                    AND pd.pd_stop_dt
                                OR pd_nst = 20                        --#89422
                                              )
                           AND pd_st IN ('S'))    decision_count
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
                   AND (   p_calc_dt BETWEEN pd.pd_start_dt AND pd.pd_stop_dt
                        OR pd_nst = 20                                --#89422
                                      )
                   AND pd_st IN ('S')
                   AND (   EXISTS
                               (SELECT 1
                                  FROM TMP_WORK_PA_IDS t
                                 WHERE     t.x_pa = pd.pd_pa
                                       AND t.x_nst = 1
                                       AND t.x_ap = pd.pd_ap)
                        OR NOT EXISTS
                               (SELECT 1
                                  FROM TMP_WORK_PA_IDS t
                                 WHERE t.x_ap = pd.pd_ap));

        CURSOR method (p_pd NUMBER, p_calc_dt DATE)
        IS
              SELECT p.*
                FROM pd_pay_method p
               WHERE     p.pdm_pd = p_pd
                     AND p.history_status = 'A'
                     AND p_calc_dt BETWEEN p.pdm_start_dt AND p.pdm_stop_dt
            ORDER BY p.pdm_start_dt DESC, p.pdm_id DESC;
    BEGIN
        FOR rec IN ap_tp_o_641
        LOOP
            --dbms_output.put_line('pc_id='||rec.pc_id||'   rec.app_sc='||rec.app_sc);
            IF rec.ap_st != 'O'
            THEN
                raise_application_error (
                    -20000,
                       'Звернення щодо змін обставин '
                    || rec.ap_num
                    || ' вже оброблено!');
            END IF;

            IF rec.decision_count = 0
            THEN
                raise_application_error (
                    -20000,
                    'Щодо отримувача допомоги не знайдено рішення у статусі "Нараховано", зміна персональних даних здійснюється лише за наявності рішень у статусі "Нараховано"!');
            END IF;

            api$pc_decision.Copy_Document2Socialcard (p_ap => rec.ap_id);

            FOR pd IN decision_641 (rec.pc_id, rec.ap_reg_dt)
            LOOP
                --dbms_output.put_line('pd.pd_id='||pd.pd_id||'    rec.ap_reg_dt='||rec.ap_reg_dt);
                FOR pdm IN method (pd.pd_id, rec.ap_reg_dt)
                LOOP
                    --dbms_output.put_line('p.pdm_id='||pdm.pdm_id);
                    --Вкорочуємо старій запис.
                    IF pdm.pdm_start_dt = rec.ap_reg_dt
                    THEN
                        UPDATE pd_pay_method p
                           SET p.history_status = 'H'
                         WHERE p.pdm_id = pdm.pdm_id;
                    ELSE
                        UPDATE pd_pay_method p
                           SET p.pdm_stop_dt = rec.ap_reg_dt - 1,
                               p.pdm_is_actual = 'F'
                         WHERE p.pdm_id = pdm.pdm_id;
                    END IF;

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

                API$PC_DECISION.write_pd_log (
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


                API$PC_DECISION.Check_pd_pay_method (pd.pd_id);
            END LOOP;

            UPDATE appeal
               SET ap_st = 'WD'
             WHERE ap_id = rec.ap_id;
        END LOOP;
    END;

    --====================================================================================--
    PROCEDURE Process_ap_tp_O_642 (p_hs IN histsession.hs_id%TYPE)
    IS
        pay_method   pd_pay_method%ROWTYPE;
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
                          AND (   ap.ap_reg_dt BETWEEN pd.pd_start_dt
                                                   AND pd.pd_stop_dt
                               OR pd_nst = 20                         --#89422
                                             )
                          AND pd_st IN ('S')
             WHERE    EXISTS
                          (SELECT 1
                             FROM TMP_WORK_PA_IDS t
                            WHERE     t.x_pa = pd.pd_pa
                                  AND t.x_nst = 1
                                  AND t.x_ap = ap.ap_id)
                   OR NOT EXISTS
                          (SELECT 1
                             FROM TMP_WORK_PA_IDS t
                            WHERE t.x_ap = ap.ap_id);

        CURSOR pdm (p_pd NUMBER)
        IS
              SELECT p.*
                FROM pd_pay_method p
               WHERE p.pdm_pd = p_pd AND p.history_status = 'A'
            ORDER BY p.pdm_start_dt DESC, p.pdm_id DESC;
    BEGIN
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

                    SELECT MAX (sc_scc)
                      INTO pay_method.pdm_scc
                      FROM uss_person.v_socialcard sc
                     WHERE sc.sc_id = rec.app_sc;

                    INSERT INTO pd_pay_method
                         VALUES pay_method;

                    Api$pc_Decision.Update_pdm_nd (pay_method.pdm_pd);

                    API$PC_DECISION.decision_block (
                        rec.pd_id,
                        tools.ggp ('CHANGE_PAYMENT_CODE', rec.ap_reg_dt),
                        rec.ap_id,
                        p_hs);

                    API$PC_DECISION.write_pd_log (
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

            API$PC_DECISION.recalc_pd_periods_pv (p_pd_id      => rec.pd_id,
                                                  p_start_dt   => l_start_dt,
                                                  p_hs         => p_hs);

            UPDATE appeal
               SET ap_st = 'WD'
             WHERE ap_id = rec.ap_id;
        END LOOP;
    END;

    --====================================================================================--
    PROCEDURE Process_ap_tp_O_643 (p_hs IN histsession.hs_id%TYPE)
    IS
        pay_method       pd_pay_method%ROWTYPE;
        l_CHNG_CODE      VARCHAR2 (200);
        l_prew_stop_dt   DATE;            --дата закриття існуючого розрахунку
        l_new_start_dt   DATE;               --дата відкмття нового розрахунку

        -- 643 послуга
        -- Зміна складу сім`ї
        CURSOR ap_tp_o_643 IS
            WITH
                ap
                AS
                    (SELECT ap.ap_id,
                            ap.ap_num,
                            ap.ap_reg_dt,
                            ap.ap_st,
                            aps_nst,
                            app.app_id,
                            app.app_sc,
                            pc_id,
                            CASE aps_nst
                                WHEN 643
                                THEN
                                    REGEXP_SUBSTR (
                                        API$PC_DECISION.get_doc_string (
                                            app.app_id,
                                            10098,
                                            2262),
                                        '[[:digit:]]+')
                                ELSE
                                    NULL
                            END    AS edit_nst
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
                            JOIN personalcase pc ON pc_sc = app_sc)
            SELECT ap_id,
                   ap_num,
                   ap_reg_dt,
                   ap_st,
                   aps_nst,
                   pd.pd_id,
                   pd.pd_ap,
                   pd.pd_num,
                   pd.pd_st,
                   pd.pd_start_dt,
                   pd.pd_stop_dt,
                   edit_nst,
                   npd.pd_id                           AS new_pd_id,
                   npd.pd_ap                           AS new_pd_ap,
                   npd.pd_num                          AS new_pd_num,
                   npd.pd_start_dt                     AS new_pd_start_dt,
                   npd.pd_stop_dt                      AS new_pd_stop_dt,
                   CASE
                       WHEN pd.pd_id IS NOT NULL AND npd.pd_id IS NULL
                       THEN
                           'I'
                       WHEN pd.pd_id IS NULL AND npd.pd_id IS NOT NULL
                       THEN
                           'U'
                       WHEN pd.pd_id IS NOT NULL AND npd.pd_id IS NOT NULL
                       THEN
                           'U'
                       ELSE
                           'ERR'
                   END                                 AS pd_Mode,
                   COALESCE (api$appeal.get_doc_dt_min (ap_id,
                                                        NULL,
                                                        10205,
                                                        2688),
                             api$appeal.get_doc_dt_min (ap_id,
                                                        NULL,
                                                        10325,
                                                        8524),
                             api$appeal.get_doc_dt_min (ap_id,
                                                        NULL,
                                                        10328,
                                                        8577),
                             api$appeal.get_doc_dt_min (ap_id,
                                                        NULL,
                                                        10329,
                                                        8579),
                               api$appeal.get_doc_dt_min (ap_id,
                                                          NULL,
                                                          661,
                                                          2666)
                             - 1,
                               api$appeal.get_doc_dt_min (ap_id,
                                                          NULL,
                                                          662,
                                                          2667)
                             - 1)                      AS recalc_min_dt,
                   api$appeal.get_doc_dt_max (ap_id,
                                              NULL,
                                              10205,
                                              2689)    AS recalc_max_dt
              FROM ap
                   LEFT JOIN pc_decision pd
                       ON     pd.pd_pc = pc_id
                          AND pd.pd_nst = edit_nst
                          AND pd.pd_st IN ('S', 'PS')
                          AND pd.pd_ap_reason != ap.ap_id
                   LEFT JOIN pc_decision npd
                       ON npd.pd_ap_reason = ap.ap_id AND npd.pd_st != 'V'
             WHERE     (   ap.ap_reg_dt BETWEEN pd.pd_start_dt
                                            AND pd.pd_stop_dt
                        OR npd.pd_id IS NOT NULL)
                   AND edit_nst NOT IN (248, 664)
                   AND (   EXISTS
                               (SELECT 1
                                  FROM TMP_WORK_PA_IDS t
                                 WHERE     (   t.x_pa = pd.pd_pa
                                            OR t.x_pa = npd.pd_pa)
                                       AND t.x_nst = 1
                                       AND t.x_ap = ap.ap_id)
                        OR NOT EXISTS
                               (SELECT 1
                                  FROM TMP_WORK_PA_IDS t
                                 WHERE t.x_ap = ap.ap_id));

        --========================================================--
        CURSOR cur_anf_pd (x_ap_main NUMBER)
        IS
            SELECT pd.pd_id
              FROM appeal ap JOIN pc_decision pd ON pd_ap = ap_id
             WHERE ap_ap_main = x_ap_main;
    --========================================================--
    BEGIN
        /*
        Є рішення за послугою NST_ID 901 № 51808-111055-2024-1 (в статусі "Нараховано")

        Для виключення зі скліду сім'ї створила звернення "Зміна скаладу сім'ї" 9000000000240000046810 в статусі "Передано на призначення/ опрацювання"

        Потрібно знайти рішення в статусі "Нараховано" для послуги 901, призупити його та перерахувати з урахуванням дати вказаної в документі "Заява про зміни складу сім'ї" (NDT_ID 10098) в атрибуті "Дата подання заяви" (NDA_ID 2254).
        */
        FOR rec IN ap_tp_o_643
        LOOP
            --dbms_output.put_line('pc_id='||rec.pc_id||'   rec.app_sc='||rec.app_sc);
            IF rec.ap_st != 'O'
            THEN
                raise_application_error (
                    -20000,
                       'Звернення щодо змін обставин '
                    || rec.ap_num
                    || ' вже оброблено!');
            END IF;

            IF rec.pd_id IS NULL AND rec.new_pd_id IS NULL
            THEN
                raise_application_error (
                    -20000,
                       'Опрацювання звернення "Зміна складу сім''ї " не можливо. '
                    || 'Щодо отримувача допомоги не знайдено рішення у статусі "Нараховано" для виду допомоги, '
                    || 'яка вказана у документі "Зміна виплатних реквізитів" в атрибуті "Вид допомоги"');
            END IF;

            /*
                           api$appeal.get_doc_dt_min(ap_id, NULL, 10205, 2688) AS recalc_min_dt,
                           api$appeal.get_doc_dt_max(ap_id, NULL, 10205, 2689) AS recalc_max_dt
            */

            IF rec.pd_Mode = 'I'
            THEN
                api$pc_decision.Copy_Document2Socialcard (p_ap => rec.ap_id);

                INSERT INTO pd_source (pds_id,
                                       pds_pd,
                                       pds_tp,
                                       pds_ap,
                                       pds_create_dt,
                                       history_status,
                                       pds_recalc_dt)
                    SELECT 0,
                           rec.pd_id     AS pds_pd,
                           'AP'          AS pds_tp,
                           rec.ap_id     AS pds_ap,
                           SYSDATE,
                           'A',
                           rec.recalc_min_dt + 1
                      FROM DUAL;

                API$ESR_Action.PrepareWrite_Visit_ap_log (
                    rec.ap_id,
                    'O',
                    rec.pd_id,
                    CHR (38) || '130#' || rec.pd_num);

                UPDATE pc_decision pd
                   SET pd.pd_ap_reason = rec.ap_id, pd.pd_src = 'RC'
                 WHERE pd_id = rec.pd_id;

                --обробка рішення другого батька вихователя
                FOR anf IN cur_anf_pd (rec.pd_ap)
                LOOP
                    INSERT INTO pd_source (pds_id,
                                           pds_pd,
                                           pds_tp,
                                           pds_ap,
                                           pds_create_dt,
                                           history_status,
                                           pds_recalc_dt)
                        SELECT 0,
                               anf.pd_id     AS pds_pd,
                               'AP'          AS pds_tp,
                               rec.ap_id     AS pds_ap,
                               SYSDATE,
                               'A',
                               rec.recalc_min_dt + 1
                          FROM DUAL;

                    UPDATE pc_decision pd
                       SET pd.pd_ap_reason = rec.ap_id, pd.pd_src = 'RC'
                     WHERE pd_id = anf.pd_id;
                END LOOP;
            ELSE
                NULL;
            END IF;

            /*
                  UPDATE pd_payment p SET
                    p.history_status = 'H',
                    p.pdp_hs_del = p_hs
                  WHERE EXISTS ( SELECT 1 FROM pc_decision WHERE pd_id = p.pdp_pd AND pd_ap_reason = rec.ap_id)
                    AND p.history_status = 'A';

                  UPDATE pd_family f SET
                    f.history_status = 'H',
                    f.pdf_hs_del = p_hs
                  WHERE EXISTS ( SELECT 1 FROM pc_decision WHERE pd_id = f.pdf_pd AND pd_ap_reason = rec.ap_id)
                    AND f.history_status = 'A';
            */
            UPDATE appeal
               SET ap_st = 'WD'
             WHERE ap_id = rec.ap_id;

            --calc_pd( nvl(rec.pd_id, rec.new_pd_id) );
            IF rec.pd_Mode = 'I'
            THEN
                calc_pd_RC (rec.pd_id, rec.recalc_min_dt + 1);

                --обробка рішення другого батька вихователя
                FOR anf IN cur_anf_pd (rec.pd_ap)
                LOOP
                    calc_pd_RC (anf.pd_id, rec.recalc_min_dt + 1);
                END LOOP;
            ELSE
                calc_pd_RC (rec.new_pd_id, rec.recalc_min_dt + 1);

                --обробка рішення другого батька вихователя
                FOR anf IN cur_anf_pd (rec.new_pd_ap)
                LOOP
                    calc_pd_RC (anf.pd_id, rec.recalc_min_dt + 1);
                END LOOP;
            END IF;
        END LOOP;
    END;

    --====================================================================================--
    PROCEDURE Process_ap_tp_O_1161 (p_hs       histsession.hs_id%TYPE,
                                    p_com_wu   pc_decision.com_wu%TYPE)
    IS
        l_cnt               INTEGER;
        l_pd_id             NUMBER;
        l_curr_id           NUMBER := 0;
        pay_method          pd_pay_method%ROWTYPE;
        l_CHNG_CODE         VARCHAR2 (200);
        l_PD_SRC            VARCHAR2 (200) := 'PV';
        l_prew_pd_stop_dt   DATE;            --дата закриття існуючого рішення
        l_new_pd_start_dt   DATE;               --дата відкмття нового рішення
        l_new_pd_stop_dt    DATE;               --дата відкмття нового рішення

        CURSOR ap_tp_o_1161 IS
              SELECT ap.ap_id,
                     ap.ap_num,
                     ap.ap_reg_dt,
                     ap.ap_st,
                     app.app_id, --app.app_fn||' '||app.app_mn||' '||app.app_ln AS app_fio,
                     app.app_sc,
                     pc_id,
                     pd.pd_id,
                     pd.pd_st,
                     npd.pd_id          AS new_pd_id,
                     npd.pd_num         AS new_pd_num,
                     npd.pd_start_dt    AS new_pd_start_dt,
                     npd.pd_stop_dt     AS new_pd_stop_dt,
                     CASE
                         WHEN pd.pd_id IS NOT NULL AND npd.pd_id IS NULL
                         THEN
                             'I'
                         WHEN pd.pd_id IS NULL AND npd.pd_id IS NOT NULL
                         THEN
                             'U'
                         WHEN pd.pd_id IS NOT NULL AND npd.pd_id IS NOT NULL
                         THEN
                             'U'
                         ELSE
                             'ERR'
                     END                AS pd_Mode
                FROM tmp_work_ids
                     JOIN appeal ap ON ap_id = x_id AND ap_tp = 'O'
                     JOIN ap_service aps
                         ON     aps_ap = ap_id
                            AND aps_nst = 1161
                            AND aps.history_status = 'A'
                     JOIN ap_person app
                         ON     app_ap = ap_id
                            AND app_tp = 'O'
                            AND app.history_status = 'A'
                     JOIN personalcase pc ON pc_sc = app_sc
                     LEFT JOIN pc_decision pd
                         ON     pd_pc = pc_id
                            AND pd_nst = 275
                            AND ap.ap_reg_dt BETWEEN pd.pd_start_dt
                                                 AND pd.pd_stop_dt
                            AND pd.pd_st IN ('S', 'PS', 'R0')
                            AND EXISTS
                                    (SELECT 1
                                       FROM pd_family f
                                            JOIN ap_person app1
                                                ON     app1.app_ap = ap_id
                                                   AND f.pdf_sc = app1.app_sc
                                                   AND app1.history_status =
                                                       'A'
                                      WHERE     f.pdf_pd = pd.pd_id
                                            AND app1.app_tp != 'O')
                     LEFT JOIN pc_decision npd
                         ON npd.pd_ap_reason = ap.ap_id AND npd.pd_st != 'V'
            ORDER BY ap_id ASC, pd.pd_id DESC;
    BEGIN
        FOR rec IN ap_tp_o_1161
        LOOP
            CONTINUE WHEN l_curr_id = rec.ap_id;

            l_curr_id := rec.ap_id;

            IF rec.pd_id IS NULL AND rec.new_pd_id IS NULL
            THEN
                raise_application_error (
                    -20000,
                       'Опрацювання звернення "Повідомлення про зміну розміру доходів для призначення ДСД" не можливо. '
                    || 'Щодо отримувача допомоги не знайдено рішення у статусі "Нараховано", "Призупинено"');
            END IF;

            l_CHNG_CODE := tools.ggp ('CHANGE_FAMILY_CODE', rec.ap_reg_dt);

            --      raise_application_error(-20000, 'rec.pd_Mode = '||rec.pd_Mode);

            IF rec.pd_Mode = 'I'
            THEN
                l_PD_SRC := 'RC';
                l_new_pd_start_dt :=
                    TRUNC (ADD_MONTHS (rec.ap_reg_dt, 1), 'MM');
                l_prew_pd_stop_dt := l_new_pd_start_dt - 1;
                l_new_pd_stop_dt := g_end_war_dt;

                API$PC_DECISION.decision_block_pap (rec.pd_id,
                                                    l_prew_pd_stop_dt,
                                                    l_CHNG_CODE,
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
                           CASE pd.pd_st WHEN 'S' THEN 'S' ELSE 'R0' END,
                           pd_nst,
                           com_org,
                           p_com_wu,
                           l_PD_SRC     AS x_pd_src,
                           pd_ps        AS x_pd_ps,
                           pd_id,
                           pd_has_right,
                           pd_start_dt,
                           pd_stop_dt,  --l_new_pd_start_dt, l_new_pd_stop_dt,
                           rec.ap_id,
                           pd_scc
                      FROM pc_decision pd
                     WHERE     pd.pd_id = rec.pd_id
                           AND NOT EXISTS
                                   (SELECT 1
                                      FROM pc_decision pdsl
                                     WHERE     pdsl.pd_ap_reason = rec.ap_id
                                           AND pdsl.pd_st != 'V');

                INSERT INTO pd_source (pds_id,
                                       pds_pd,
                                       pds_tp,
                                       pds_ap,
                                       pds_create_dt,
                                       history_status)
                    SELECT 0,
                           l_pd_id     AS x_pds_pd,
                           pds_tp,
                           pds_ap,
                           SYSDATE     AS x_create_dt,
                           history_status
                      FROM pd_source
                     WHERE pds_pd = rec.pd_id AND history_status = 'A'
                    UNION ALL
                    SELECT 0,
                           l_pd_id       AS x_pds_pd,
                           'AP'          AS pds_tp,
                           rec.ap_id     AS pds_ap,
                           SYSDATE       AS x_create_dt,
                           'A'
                      FROM DUAL
                     WHERE EXISTS
                               (SELECT *
                                  FROM pc_decision z
                                 WHERE z.pd_id = l_pd_id);

                --        IF rec.edit_nst = 249 THEN -- потрібно взяти старий розрахунок доходу
                --          move_pd_income(rec.pd_id, l_pd_id);
                --        END IF;

                FOR pm
                    IN (  SELECT p.*
                            FROM pd_pay_method p
                           WHERE     p.pdm_pd = rec.pd_id
                                 AND p.history_status = 'A'
                                 AND (   l_new_pd_start_dt <= p.pdm_start_dt
                                      OR l_new_pd_start_dt BETWEEN p.pdm_start_dt
                                                               AND p.pdm_stop_dt)
                        ORDER BY p.pdm_start_dt ASC, p.pdm_id DESC)
                LOOP
                    pay_method := pm;
                    pay_method.pdm_id := NULL;
                    pay_method.pdm_pd := l_pd_id;

                    IF pay_method.pdm_start_dt < l_new_pd_start_dt
                    THEN
                        pay_method.pdm_start_dt := l_new_pd_start_dt;
                    END IF;

                    INSERT INTO pd_pay_method
                         VALUES pay_method;
                END LOOP;

                SELECT COUNT (1)
                  INTO l_cnt
                  FROM pd_pay_method
                 WHERE pdm_pd = l_pd_id;

                IF l_cnt = 0
                THEN
                    FOR pm
                        IN (  SELECT p.*
                                FROM pd_pay_method p
                               WHERE     p.pdm_pd = rec.pd_id
                                     AND p.history_status = 'A'
                            ORDER BY p.pdm_start_dt ASC)
                    LOOP
                        pay_method := pm;
                    END LOOP;

                    pay_method.pdm_id := NULL;
                    pay_method.pdm_pd := l_pd_id;
                    pay_method.pdm_start_dt := l_new_pd_start_dt;
                    pay_method.pdm_stop_dt :=
                        ADD_MONTHS (l_new_pd_start_dt, 12);

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
                     WHERE prl.prl_pd = rec.pd_id;

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
                     WHERE pde.pde_pd = rec.pd_id;

                INSERT INTO pd_family (pdf_id,
                                       pdf_pd,
                                       pdf_sc,
                                       pdf_birth_dt,
                                       pdf_start_dt,
                                       pdf_stop_dt,
                                       history_status,
                                       pdf_hs_ins,
                                       pdf_tp)
                    SELECT 0           AS x_id,
                           l_pd_id     AS x_pd,
                           pdf_sc,
                           pdf_birth_dt,
                           pd_start_dt,
                           pd_stop_dt,
                           history_status,
                           p_hs,
                           pdf_tp
                      FROM pd_family pdf, pc_decision pd
                     WHERE pdf.pdf_pd = rec.pd_id AND pd.pd_id = l_pd_id;

                calc_income_for_pd (l_pd_id);
                calc_pd (l_pd_id);
                gen_pd_num (rec.pc_id, p_hs);

                INSERT INTO pd_accrual_period (pdap_id,
                                               pdap_pd,
                                               pdap_start_dt,
                                               pdap_stop_dt,
                                               pdap_change_pd,
                                               history_status,
                                               pdap_change_ap,
                                               pdap_reason_start,
                                               pdap_reason_stop,
                                               pdap_pco,
                                               pdap_hs_ins)
                    SELECT 0           AS x_pdap_id,
                           l_pd_id     AS x_pd,
                           pdap_start_dt,
                           pdap_stop_dt,
                           pdap_change_pd,
                           history_status,
                           pdap_change_ap,
                           pdap_reason_start,
                           pdap_reason_stop,
                           pdap_pco,
                           p_hs
                      FROM pd_accrual_period
                     WHERE     pdap_pd = rec.pd_id
                           AND history_status = 'A'
                           AND rec.pd_st = 'S';
            ELSE
                gen_pd_num (rec.pc_id, p_hs);

                UPDATE pc_decision
                   SET pd_st = 'R0'
                 WHERE pd_id = rec.new_pd_id;
            END IF;



            --recalc_pd_periods(p_pd_id => rec.pd_id, p_hs => p_hs);
            UPDATE appeal
               SET ap_st = 'WD'
             WHERE ap_id = rec.ap_id;
        END LOOP;
    END;

    --====================================================================================--
    PROCEDURE Process_ap_tp_O_1162 (p_hs       histsession.hs_id%TYPE,
                                    p_com_wu   pc_decision.com_wu%TYPE)
    IS
        l_cnt               INTEGER;
        l_pd_id             NUMBER;
        pay_method          pd_pay_method%ROWTYPE;
        l_CHNG_CODE         VARCHAR2 (200);
        l_PD_SRC            VARCHAR2 (200) := 'PV';
        l_prew_pd_stop_dt   DATE;            --дата закриття існуючого рішення
        l_new_pd_start_dt   DATE;               --дата відкмття нового рішення
        l_new_pd_stop_dt    DATE;               --дата відкмття нового рішення

        CURSOR ap_tp_o_1162 IS
            SELECT ap.ap_id,
                   ap.ap_num,
                   ap.ap_reg_dt,
                   ap.ap_st,
                   app.app_id, --app.app_fn||' '||app.app_mn||' '||app.app_ln AS app_fio,
                   app.app_sc,
                   pc_id,
                   pd.pd_id,
                   npd.pd_id          AS new_pd_id,
                   npd.pd_num         AS new_pd_num,
                   npd.pd_start_dt    AS new_pd_start_dt,
                   npd.pd_stop_dt     AS new_pd_stop_dt,
                   CASE
                       WHEN pd.pd_id IS NOT NULL AND npd.pd_id IS NULL
                       THEN
                           'I'
                       WHEN pd.pd_id IS NULL AND npd.pd_id IS NOT NULL
                       THEN
                           'U'
                       WHEN pd.pd_id IS NOT NULL AND npd.pd_id IS NOT NULL
                       THEN
                           'U'
                       ELSE
                           'ERR'
                   END                AS pd_Mode
              FROM tmp_work_ids
                   JOIN appeal ap ON ap_id = x_id AND ap_tp = 'O'
                   JOIN ap_service aps
                       ON     aps_ap = ap_id
                          AND aps_nst = 1162
                          AND aps.history_status = 'A'
                   JOIN ap_person app
                       ON     app_ap = ap_id
                          AND app_tp = 'O'
                          AND app.history_status = 'A'
                   JOIN personalcase pc ON pc_sc = app_sc
                   LEFT JOIN pc_decision pd
                       ON     pd_pc = pc_id
                          AND pd_nst = 275
                          AND ap.ap_reg_dt BETWEEN pd.pd_start_dt
                                               AND pd.pd_stop_dt
                          AND pd.pd_st IN ('S')
                          AND EXISTS
                                  (SELECT 1
                                     FROM pd_family  f
                                          JOIN ap_person app1
                                              ON     app1.app_ap = ap_id
                                                 AND f.pdf_sc = app1.app_sc
                                                 AND app1.history_status =
                                                     'A'
                                          JOIN ap_document apd
                                              ON     apd.apd_app =
                                                     app1.app_id
                                                 AND apd.history_status = 'A'
                                                 AND apd.apd_ndt IN
                                                         (10302, 10303)
                                    WHERE     f.pdf_pd = pd.pd_id
                                          AND app1.app_tp != 'O')
                   LEFT JOIN pc_decision npd
                       ON npd.pd_ap_reason = ap.ap_id AND npd.pd_st != 'V';
    BEGIN
        -- Initialization
        g_end_war_dt := LAST_DAY (TOOLS.GGPD ('WAR_MARTIAL_LAW_END'));

        NULL;

        FOR rec IN ap_tp_o_1162
        LOOP
            IF rec.pd_id IS NULL AND rec.new_pd_id IS NULL
            THEN
                raise_application_error (
                    -20000,
                       'Опрацювання звернення "Повідомлення про перебування за кордоном" не можливо. '
                    || 'Щодо отримувача допомоги не знайдено рішення у статусі "Нараховано"');
            END IF;

            l_CHNG_CODE := tools.ggp ('CHANGE_FAMILY_CODE', rec.ap_reg_dt);

            --      raise_application_error(-20000, 'rec.pd_Mode = '||rec.pd_Mode);

            IF rec.pd_Mode = 'I'
            THEN
                l_PD_SRC := 'RC';
                l_new_pd_start_dt :=
                    TRUNC (ADD_MONTHS (rec.ap_reg_dt, 1), 'MM');
                l_prew_pd_stop_dt := l_new_pd_start_dt - 1;
                l_new_pd_stop_dt := g_end_war_dt;

                API$PC_DECISION.decision_block_pap (rec.pd_id,
                                                    l_prew_pd_stop_dt,
                                                    l_CHNG_CODE,
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
                           l_PD_SRC     AS x_pd_src,
                           pd_ps        AS x_pd_ps,
                           pd_id,
                           pd_has_right,
                           pd_start_dt,
                           pd_stop_dt,  --l_new_pd_start_dt, l_new_pd_stop_dt,
                           rec.ap_id,
                           pd_scc
                      FROM pc_decision pd
                     WHERE     pd.pd_id = rec.pd_id
                           AND NOT EXISTS
                                   (SELECT 1
                                      FROM pc_decision pdsl
                                     WHERE     pdsl.pd_ap_reason = rec.ap_id
                                           AND pdsl.pd_st != 'V');

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

                --        IF rec.edit_nst = 249 THEN -- потрібно взяти старий розрахунок доходу
                --          move_pd_income(rec.pd_id, l_pd_id);
                --        END IF;

                FOR pm
                    IN (  SELECT p.*
                            FROM pd_pay_method p
                           WHERE     p.pdm_pd = rec.pd_id
                                 AND p.history_status = 'A'
                                 AND (   l_new_pd_start_dt <= p.pdm_start_dt
                                      OR l_new_pd_start_dt BETWEEN p.pdm_start_dt
                                                               AND p.pdm_stop_dt)
                        ORDER BY p.pdm_start_dt ASC, p.pdm_id DESC)
                LOOP
                    pay_method := pm;
                    pay_method.pdm_id := NULL;
                    pay_method.pdm_pd := l_pd_id;

                    IF pay_method.pdm_start_dt < l_new_pd_start_dt
                    THEN
                        pay_method.pdm_start_dt := l_new_pd_start_dt;
                    END IF;

                    INSERT INTO pd_pay_method
                         VALUES pay_method;
                END LOOP;

                SELECT COUNT (1)
                  INTO l_cnt
                  FROM pd_pay_method
                 WHERE pdm_pd = l_pd_id;

                IF l_cnt = 0
                THEN
                    FOR pm
                        IN (  SELECT p.*
                                FROM pd_pay_method p
                               WHERE     p.pdm_pd = rec.pd_id
                                     AND p.history_status = 'A'
                            ORDER BY p.pdm_start_dt ASC)
                    LOOP
                        pay_method := pm;
                    END LOOP;

                    pay_method.pdm_id := NULL;
                    pay_method.pdm_pd := l_pd_id;
                    pay_method.pdm_start_dt := l_new_pd_start_dt;
                    pay_method.pdm_stop_dt :=
                        ADD_MONTHS (l_new_pd_start_dt, 12);

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
                     WHERE prl.prl_pd = rec.pd_id;

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
                     WHERE pde.pde_pd = rec.pd_id;

                INSERT INTO pd_family (pdf_id,
                                       pdf_pd,
                                       pdf_sc,
                                       pdf_birth_dt,
                                       pdf_start_dt,
                                       pdf_stop_dt,
                                       history_status,
                                       pdf_hs_ins,
                                       pdf_tp)
                    SELECT 0           AS x_id,
                           l_pd_id     AS x_pd,
                           pdf_sc,
                           pdf_birth_dt,
                           pd_start_dt,
                           pd_stop_dt,
                           history_status,
                           p_hs,
                           pdf_tp
                      FROM pd_family pdf, pc_decision pd
                     WHERE pdf.pdf_pd = rec.pd_id AND pd.pd_id = l_pd_id;

                calc_pd (l_pd_id);
                gen_pd_num (rec.pc_id, p_hs);
            --в новому рішенні розміри допомоги не перераховуються.
            --Допомога дітям-сиротам з інвалідністю продовжує нараховуватися до досягнення ними 23 років (навіть без підтвердження інвалідності);
            /*
                      DELETE FROM tmp_work_set1 WHERE 1=1;
                      INSERT INTO tmp_work_set1 (x_id1, x_id2)
                      SELECT pdp_id, id_pd_payment(0)
                      FROM pd_payment pdp
                      WHERE pdp.pdp_pd = rec.pd_id
                        AND pdp.pdp_stop_dt > l_new_pd_start_dt;
                      l_cnt := SQL%ROWCOUNT;
                      IF l_cnt > 0 THEN
                        INSERT INTO pd_payment (pdp_id, pdp_pd, pdp_npt, pdp_start_dt, pdp_stop_dt, pdp_sum, pdp_hs_ins, pdp_hs_del, history_status)
                        SELECT x_id2, l_pd_id AS x_pd, pdp_npt,
                               CASE
                                 WHEN pdp_start_dt < l_new_pd_start_dt THEN
                                   l_new_pd_start_dt
                                 ELSE
                                   pdp_start_dt
                               END AS x_start_dt,
                               pdp_stop_dt, pdp_sum, pdp_hs_ins, pdp_hs_del, history_status
                        FROM pd_payment pdp
                             JOIN tmp_work_set1 ON x_id1 = pdp_id;

                        INSERT INTO pd_detail (pdd_id, pdd_pdp, pdd_row_order, pdd_row_name, pdd_value, pdd_key, pdd_ndp, pdd_start_dt, pdd_stop_dt, pdd_npt)
                        SELECT 0 AS x_id, x_id2, pdd_row_order, pdd_row_name, pdd_value, pdd_key, pdd_ndp,
                               CASE
                                 WHEN pdd_start_dt < l_new_pd_start_dt THEN
                                   l_new_pd_start_dt
                                 ELSE
                                   pdd_start_dt
                               END AS x_start_dt,
                               pdd_stop_dt, pdd_npt
                        FROM pd_detail pdd
                             JOIN tmp_work_set1 ON x_id1 = pdd_pdp;

                     END IF;
            */
            ELSE
                gen_pd_num (rec.pc_id, p_hs);

                UPDATE pc_decision
                   SET pd_st = 'R0'
                 WHERE pd_id = rec.new_pd_id;
            END IF;



            --recalc_pd_periods(p_pd_id => rec.pd_id, p_hs => p_hs);
            UPDATE appeal
               SET ap_st = 'WD'
             WHERE ap_id = rec.ap_id;
        END LOOP;
    END;

    --====================================================================================--
    PROCEDURE Process_ap_tp_O_1181 (p_hs       histsession.hs_id%TYPE,
                                    p_com_wu   pc_decision.com_wu%TYPE)
    IS
        l_num       VARCHAR2 (200);
        l_stop_dt   DATE;

        -----------------------------------------------------------------
        CURSOR ap_tp_o_1181 IS
            SELECT ap.ap_id,
                   ap.ap_num,
                   ap.ap_reg_dt,
                   ap.ap_st,
                   app.app_id, -- app.app_fn||' '||app.app_mn||' '||app.app_ln AS app_fio,
                   app.app_sc,
                   pc_id,
                   pd.pd_id,
                   pd.pd_st,
                   pd.pd_num,
                   pd.pd_stop_dt,
                   (SELECT d.pd_id
                      FROM appeal a JOIN pc_decision d ON d.pd_ap = a.ap_id
                     WHERE a.ap_ap_main = pd.pd_ap)    AS anf_pd_id,
                   npd.pd_id                           AS new_pd_id, --npd.pd_num AS new_pd_num,
                   anf.pd_id                           AS new_anf_pd_id, --anf.pd_num AS new_anf_pd_num,
                   CASE
                       WHEN pd.pd_id IS NOT NULL AND npd.pd_id IS NULL
                       THEN
                           'I'
                       WHEN pd.pd_id IS NULL AND npd.pd_id IS NOT NULL
                       THEN
                           'U'
                       WHEN pd.pd_id IS NOT NULL AND npd.pd_id IS NOT NULL
                       THEN
                           'U'
                       ELSE
                           'ERR'
                   END                                 AS pd_Mode,
                   ADD_MONTHS (api$appeal.get_doc_dt_min (ap_id,
                                                          NULL,
                                                          10319,
                                                          8490),
                               12 * 18)                AS recalc_min_dt,
                   ADD_MONTHS (api$appeal.get_doc_dt_min (ap_id,
                                                          NULL,
                                                          10318,
                                                          8488),
                               4)                      AS recalc_max_dt
              FROM tmp_work_ids
                   JOIN appeal ap ON ap_id = x_id AND ap_tp = 'O'
                   JOIN ap_service aps
                       ON     aps_ap = ap_id
                          AND aps_nst = 1181
                          AND aps.history_status = 'A'
                   JOIN ap_person app
                       ON     app_ap = ap_id
                          AND app_tp = 'O'
                          AND app.history_status = 'A'
                   JOIN personalcase pc ON pc_sc = app_sc
                   LEFT JOIN pc_decision pd
                       ON     pd.pd_pc = pc_id
                          AND pd.pd_nst = 275
                          AND ap.ap_reg_dt > pd.pd_start_dt
                          AND ADD_MONTHS (ap.ap_reg_dt, -4) < pd.pd_stop_dt
                          AND pd.pd_st IN ('S', 'PS')
                          AND EXISTS
                                  (SELECT 1
                                     FROM pd_family  f
                                          JOIN ap_person app1
                                              ON     app1.app_ap = ap_id
                                                 AND f.pdf_sc = app1.app_sc
                                                 AND app1.history_status =
                                                     'A'
                                    WHERE     f.pdf_pd = pd.pd_id
                                          AND app1.app_tp != 'O')
                   LEFT JOIN pc_decision npd
                       ON     npd.pd_ap_reason = ap.ap_id
                          AND npd.pd_st != 'V'
                          AND npd.pd_pc = pc_id
                   LEFT JOIN pc_decision anf
                       ON     anf.pd_ap_reason = ap.ap_id
                          AND anf.pd_st != 'V'
                          AND anf.pd_pc != pc_id
             WHERE pd.pd_id IN
                       (SELECT MAX (d.pd_id)
                          FROM pc_decision d
                         WHERE     pd_pc = pc_id
                               AND pd_nst = 275
                               AND ap.ap_reg_dt > pd.pd_start_dt
                               AND ADD_MONTHS (ap.ap_reg_dt, -4) <
                                   pd.pd_stop_dt
                               AND pd.pd_st IN ('S', 'PS')
                               AND EXISTS
                                       (SELECT 1
                                          FROM pd_family  f
                                               JOIN ap_person app1
                                                   ON     app1.app_ap = ap_id
                                                      AND f.pdf_sc =
                                                          app1.app_sc
                                                      AND app1.history_status =
                                                          'A'
                                         WHERE     f.pdf_pd = pd.pd_id
                                               AND app1.app_tp != 'O'));

        ------------------------------------------------------------
        ---Перевіремо, чи подовжується рішення.
        PROCEDURE Change_pd (p_pd_id           NUMBER,
                             p_stop_dt         DATE,
                             p_recalc_max_dt   DATE,
                             p_ap_id           NUMBER,
                             p_ap_num          VARCHAR2)
        AS
        BEGIN
            IF p_stop_dt < p_recalc_max_dt
            THEN
                API$PC_DECISION.write_pd_log (
                    p_pd_id,
                    p_hs,
                    'S',
                       CHR (38)
                    || '314#'
                    || TO_CHAR (p_stop_dt, 'dd.mm.yyyy')
                    || '#'
                    || TO_CHAR (p_recalc_max_dt, 'dd.mm.yyyy')
                    || '#'
                    || p_ap_num,
                    NULL);

                UPDATE pc_decision pd
                   SET pd.pd_stop_dt = p_recalc_max_dt,
                       pd.pd_ap_reason = p_ap_id,
                       pd.pd_src = 'RC'
                 WHERE pd_id = p_pd_id;

                INSERT INTO pd_accrual_period (pdap_id,
                                               pdap_pd,
                                               pdap_start_dt,
                                               pdap_stop_dt,
                                               pdap_change_pd,
                                               history_status,
                                               pdap_change_ap,
                                               pdap_reason_start,
                                               pdap_reason_stop,
                                               pdap_pco,
                                               pdap_hs_ins)
                    SELECT 0     AS x_pdap_id,
                           pdap_pd,
                           p_stop_dt + 1,
                           p_recalc_max_dt,
                           pdap_change_pd,
                           history_status,
                           pdap_change_ap,
                           pdap_reason_start,
                           pdap_reason_stop,
                           pdap_pco,
                           p_hs
                      FROM pd_accrual_period
                     WHERE     pdap_pd = p_pd_id
                           AND pdap_stop_dt = p_stop_dt
                           AND history_status = 'A';
            --AND rec.pd_st = 'S';

            ELSE
                API$PC_DECISION.write_pd_log (p_pd_id,
                                              p_hs,
                                              'S',
                                              CHR (38) || '334#' || p_ap_num,
                                              NULL);

                UPDATE pc_decision pd
                   SET pd.pd_ap_reason = p_ap_id, pd.pd_src = 'RC'
                 WHERE pd_id = p_pd_id;
            END IF;
        END;
    ------------------------------------------------------------
    BEGIN
        FOR rec IN ap_tp_o_1181
        LOOP
            IF rec.pd_id IS NULL AND rec.new_pd_id IS NULL
            THEN
                raise_application_error (
                    -20000,
                       'Опрацювання звернення "Повідомлення про зміну розміру доходів для призначення ДСД" не можливо. '
                    || 'Щодо отримувача допомоги не знайдено рішення у статусі "Нараховано", "Призупинено"');
            END IF;

            --      raise_application_error(-20000, 'rec.pd_Mode = '||rec.pd_Mode);

            IF rec.pd_Mode = 'I'
            THEN
                INSERT INTO pd_source (pds_id,
                                       pds_pd,
                                       pds_tp,
                                       pds_ap,
                                       pds_create_dt,
                                       history_status,
                                       pds_recalc_dt)
                    SELECT 0,
                           rec.pd_id     AS pds_pd,
                           'AP'          AS pds_tp,
                           rec.ap_id     AS pds_ap,
                           SYSDATE,
                           'A',
                           rec.recalc_min_dt
                      FROM DUAL;

                API$ESR_Action.PrepareWrite_Visit_ap_log (
                    rec.ap_id,
                    'O',
                    rec.pd_id,
                    CHR (38) || '130#' || rec.pd_num);
                Change_pd (rec.pd_id,
                           rec.pd_stop_dt,
                           rec.recalc_max_dt,
                           rec.ap_id,
                           rec.ap_num);

                --обробка рішення другого батька вихователя
                IF rec.anf_pd_id IS NOT NULL
                THEN
                    INSERT INTO pd_source (pds_id,
                                           pds_pd,
                                           pds_tp,
                                           pds_ap,
                                           pds_create_dt,
                                           history_status,
                                           pds_recalc_dt)
                        SELECT 0,
                               rec.anf_pd_id     AS pds_pd,
                               'AP'              AS pds_tp,
                               rec.ap_id         AS pds_ap,
                               SYSDATE,
                               'A',
                               rec.recalc_min_dt
                          FROM DUAL;

                    SELECT pd_num, pd_stop_dt
                      INTO l_num, l_stop_dt
                      FROM pc_decision
                     WHERE pd_id = rec.anf_pd_id;

                    API$ESR_Action.PrepareWrite_Visit_ap_log (
                        rec.ap_id,
                        'O',
                        rec.anf_pd_id,
                        CHR (38) || '130#' || l_num);
                    Change_pd (rec.anf_pd_id,
                               l_stop_dt,
                               rec.recalc_max_dt,
                               rec.ap_id,
                               rec.ap_num);
                END IF;
            ELSE
                NULL;
            --        UPDATE pc_decision SET
            --            pd_st = 'R0'
            --        WHERE pd_id = rec.new_pd_id;

            END IF;

            UPDATE appeal
               SET ap_st = 'WD'
             WHERE ap_id = rec.ap_id;


            IF rec.pd_Mode = 'I'
            THEN
                calc_pd_RC (rec.pd_id, rec.recalc_min_dt);

                --обробка рішення другого батька вихователя
                IF rec.anf_pd_id IS NOT NULL
                THEN
                    calc_pd_RC (rec.anf_pd_id, rec.recalc_min_dt);
                END IF;
            ELSE
                calc_pd_RC (rec.new_pd_id, rec.recalc_min_dt);

                --обробка рішення другого батька вихователя
                IF rec.new_anf_pd_id IS NOT NULL
                THEN
                    calc_pd_RC (rec.new_anf_pd_id, rec.recalc_min_dt);
                END IF;
            END IF;
        END LOOP;
    END;

    --====================================================================================--
    PROCEDURE Process_ap_tp_O_1181_old (p_hs       histsession.hs_id%TYPE,
                                        p_com_wu   pc_decision.com_wu%TYPE)
    IS
        l_cnt               INTEGER;
        l_pd_id             NUMBER;
        pay_method          pd_pay_method%ROWTYPE;
        l_CHNG_CODE         VARCHAR2 (200);
        l_PD_SRC            VARCHAR2 (200) := 'PV';
        l_prew_pd_stop_dt   DATE;            --дата закриття існуючого рішення

        --    l_new_pd_start_dt DATE;--дата відкмття нового рішення

        CURSOR ap_tp_o_1181 IS
            SELECT ap.ap_id,
                   ap.ap_num,
                   ap.ap_reg_dt,
                   ap.ap_st,
                   app.app_id, -- app.app_fn||' '||app.app_mn||' '||app.app_ln AS app_fio,
                   app.app_sc,
                   pc_id,
                   pd.pd_id,
                   pd.pd_ap,
                   pd.pd_st,
                   pd.pd_stop_dt,
                   npd.pd_id                                      AS new_pd_id,
                   npd.pd_num                                     AS new_pd_num,
                   npd.pd_start_dt                                AS new_pd_start_dt,
                   npd.pd_stop_dt                                 AS new_pd_stop_dt,
                   CASE
                       WHEN pd.pd_id IS NOT NULL AND npd.pd_id IS NULL
                       THEN
                           'I'
                       WHEN pd.pd_id IS NULL AND npd.pd_id IS NOT NULL
                       THEN
                           'U'
                       WHEN pd.pd_id IS NOT NULL AND npd.pd_id IS NOT NULL
                       THEN
                           'U'
                       ELSE
                           'ERR'
                   END                                            AS pd_Mode,
                   COALESCE (api$appeal.get_doc_dt_min (ap_id,
                                                        NULL,
                                                        10205,
                                                        2688),
                             api$appeal.get_doc_dt_min (ap_id,
                                                        NULL,
                                                        10325,
                                                        8524),
                             api$appeal.get_doc_dt_min (ap_id,
                                                        NULL,
                                                        10328,
                                                        8577),
                             api$appeal.get_doc_dt_min (ap_id,
                                                        NULL,
                                                        10329,
                                                        8579),
                             api$appeal.get_doc_dt_min (ap_id,
                                                        NULL,
                                                        661,
                                                        2666),
                             api$appeal.get_doc_dt_min (ap_id,
                                                        NULL,
                                                        662,
                                                        2667))    AS recalc_min_dt
              FROM tmp_work_ids
                   JOIN appeal ap ON ap_id = x_id AND ap_tp = 'O'
                   JOIN ap_service aps
                       ON     aps_ap = ap_id
                          AND aps_nst = 1181
                          AND aps.history_status = 'A'
                   JOIN ap_person app
                       ON     app_ap = ap_id
                          AND app_tp = 'O'
                          AND app.history_status = 'A'
                   JOIN personalcase pc ON pc_sc = app_sc
                   LEFT JOIN pc_decision pd
                       ON     pd_pc = pc_id
                          AND pd_nst = 275
                          AND ap.ap_reg_dt > pd.pd_start_dt
                          AND ADD_MONTHS (ap.ap_reg_dt, -4) < pd.pd_stop_dt
                          AND pd.pd_st IN ('S', 'PS', 'R0')
                          AND EXISTS
                                  (SELECT 1
                                     FROM pd_family  f
                                          JOIN ap_person app1
                                              ON     app1.app_ap = ap_id
                                                 AND f.pdf_sc = app1.app_sc
                                                 AND app1.history_status =
                                                     'A'
                                    WHERE     f.pdf_pd = pd.pd_id
                                          AND app1.app_tp != 'O')
                   LEFT JOIN pc_decision npd
                       ON npd.pd_ap_reason = ap.ap_id AND npd.pd_st != 'V'
             WHERE pd.pd_id IN
                       (SELECT MAX (d.pd_id)
                          FROM pc_decision d
                         WHERE     pd_pc = pc_id
                               AND pd_nst = 275
                               AND ap.ap_reg_dt > pd.pd_start_dt
                               AND ADD_MONTHS (ap.ap_reg_dt, -4) <
                                   pd.pd_stop_dt
                               AND pd.pd_st IN ('S', 'PS', 'R0')
                               AND EXISTS
                                       (SELECT 1
                                          FROM pd_family  f
                                               JOIN ap_person app1
                                                   ON     app1.app_ap = ap_id
                                                      AND f.pdf_sc =
                                                          app1.app_sc
                                                      AND app1.history_status =
                                                          'A'
                                         WHERE     f.pdf_pd = pd.pd_id
                                               AND app1.app_tp != 'O'));

        ------------------------------------------------------------
        CURSOR cur_anf_pd (x_ap_main NUMBER)
        IS
            SELECT pd.pd_id
              FROM appeal ap JOIN pc_decision pd ON pd_ap = ap_id
             WHERE ap_ap_main = x_ap_main;
    ------------------------------------------------------------

    BEGIN
        FOR rec IN ap_tp_o_1181
        LOOP
            IF rec.pd_id IS NULL AND rec.new_pd_id IS NULL
            THEN
                raise_application_error (
                    -20000,
                       'Опрацювання звернення "Повідомлення про зміну розміру доходів для призначення ДСД" не можливо. '
                    || 'Щодо отримувача допомоги не знайдено рішення у статусі "Нараховано", "Призупинено"');
            END IF;

            l_CHNG_CODE := tools.ggp ('CHANGE_FAMILY_CODE', rec.ap_reg_dt);

            --      raise_application_error(-20000, 'rec.pd_Mode = '||rec.pd_Mode);

            IF rec.pd_Mode = 'I'
            THEN
                l_PD_SRC := 'RC';

                --        l_new_pd_start_dt := trunc(add_months(rec.ap_reg_dt, 1), 'MM');
                IF rec.pd_stop_dt <
                   TRUNC (ADD_MONTHS (rec.ap_reg_dt, 1), 'MM') - 1
                THEN
                    l_prew_pd_stop_dt := rec.pd_stop_dt;
                ELSE
                    l_prew_pd_stop_dt :=
                        TRUNC (ADD_MONTHS (rec.ap_reg_dt, 1), 'MM') - 1;
                END IF;

                API$PC_DECISION.decision_block_pap (rec.pd_id,
                                                    l_prew_pd_stop_dt,
                                                    l_CHNG_CODE,
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
                           CASE pd.pd_st WHEN 'S' THEN 'S' ELSE 'R0' END,
                           pd_nst,
                           com_org,
                           p_com_wu,
                           l_PD_SRC     AS x_pd_src,
                           pd_ps        AS x_pd_ps,
                           pd_id,
                           pd_has_right,
                           pd_start_dt,
                           pd_stop_dt,  --l_new_pd_start_dt, l_new_pd_stop_dt,
                           rec.ap_id,
                           pd_scc
                      FROM pc_decision pd
                     WHERE     pd.pd_id = rec.pd_id
                           AND NOT EXISTS
                                   (SELECT 1
                                      FROM pc_decision pdsl
                                     WHERE     pdsl.pd_ap_reason = rec.ap_id
                                           AND pdsl.pd_st != 'V');

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

                --        IF rec.edit_nst = 249 THEN -- потрібно взяти старий розрахунок доходу
                --          move_pd_income(rec.pd_id, l_pd_id);
                --        END IF;

                FOR pm
                    IN (  SELECT p.*
                            FROM pd_pay_method p
                           WHERE     p.pdm_pd = rec.pd_id
                                 AND p.history_status = 'A'
                        /*AND ( l_new_pd_start_dt <= p.pdm_start_dt
                              OR
                              l_new_pd_start_dt BETWEEN p.pdm_start_dt AND p.pdm_stop_dt
                            )*/
                        ORDER BY p.pdm_start_dt ASC, p.pdm_id DESC)
                LOOP
                    pay_method := pm;
                    pay_method.pdm_id := NULL;
                    pay_method.pdm_pd := l_pd_id;

                    /*IF pay_method.pdm_start_dt < l_new_pd_start_dt THEN
                      pay_method.pdm_start_dt := l_new_pd_start_dt;
                    END IF;*/
                    INSERT INTO pd_pay_method
                         VALUES pay_method;
                END LOOP;

                SELECT COUNT (1)
                  INTO l_cnt
                  FROM pd_pay_method
                 WHERE pdm_pd = l_pd_id;

                /*
                        IF l_cnt = 0 THEN
                          FOR pm IN (SELECT p.*
                                     FROM pd_pay_method p
                                     WHERE p.pdm_pd = rec.pd_id
                                           AND p.history_status = 'A'
                                     ORDER BY p.pdm_start_dt ASC) LOOP
                            pay_method := pm;
                          END LOOP;
                            pay_method.pdm_id := NULL;
                            pay_method.pdm_pd := l_pd_id;
                            pay_method.pdm_start_dt := l_new_pd_start_dt;
                            pay_method.pdm_stop_dt  := add_months( l_new_pd_start_dt, 12);

                            INSERT INTO pd_pay_method VALUES pay_method;

                        END IF;
                */
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
                     WHERE prl.prl_pd = rec.pd_id;

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
                     WHERE pde.pde_pd = rec.pd_id;

                INSERT INTO pd_family (pdf_id,
                                       pdf_pd,
                                       pdf_sc,
                                       pdf_birth_dt,
                                       pdf_start_dt,
                                       pdf_stop_dt,
                                       history_status,
                                       pdf_hs_ins,
                                       pdf_tp)
                    SELECT 0           AS x_id,
                           l_pd_id     AS x_pd,
                           pdf_sc,
                           pdf_birth_dt,
                           pd_start_dt,
                           pd_stop_dt,
                           history_status,
                           p_hs,
                           pdf_tp
                      FROM pd_family pdf, pc_decision pd
                     WHERE pdf.pdf_pd = rec.pd_id AND pd.pd_id = l_pd_id;

                calc_income_for_pd (l_pd_id);
                calc_pd (l_pd_id);

                gen_pd_num (rec.pc_id, p_hs);

                INSERT INTO pd_accrual_period (pdap_id,
                                               pdap_pd,
                                               pdap_start_dt,
                                               pdap_stop_dt,
                                               pdap_change_pd,
                                               history_status,
                                               pdap_change_ap,
                                               pdap_reason_start,
                                               pdap_reason_stop,
                                               pdap_pco,
                                               pdap_hs_ins)
                    SELECT 0           AS x_pdap_id,
                           l_pd_id     AS x_pd,
                           pdap_start_dt,
                           pdap_stop_dt,
                           pdap_change_pd,
                           history_status,
                           pdap_change_ap,
                           pdap_reason_start,
                           pdap_reason_stop,
                           pdap_pco,
                           p_hs
                      FROM pd_accrual_period
                     WHERE     pdap_pd = rec.pd_id
                           AND history_status = 'A'
                           AND rec.pd_st = 'S';

                gen_pd_num (rec.pc_id, p_hs);

                --обробка рішення другого батька вихователя
                FOR anf IN cur_anf_pd (rec.pd_ap)
                LOOP
                    INSERT INTO pd_source (pds_id,
                                           pds_pd,
                                           pds_tp,
                                           pds_ap,
                                           pds_create_dt,
                                           history_status,
                                           pds_recalc_dt)
                        SELECT 0,
                               anf.pd_id     AS pds_pd,
                               'AP'          AS pds_tp,
                               rec.ap_id     AS pds_ap,
                               SYSDATE,
                               'A',
                               rec.recalc_min_dt + 1
                          FROM DUAL;

                    UPDATE pc_decision pd
                       SET pd.pd_ap_reason = rec.ap_id, pd.pd_src = 'RC'
                     WHERE pd_id = anf.pd_id;
                END LOOP;
            ELSE
                UPDATE pc_decision
                   SET pd_st = 'R0'
                 WHERE pd_id = rec.new_pd_id;
            END IF;


            --48635


            --recalc_pd_periods(p_pd_id => rec.pd_id, p_hs => p_hs);
            UPDATE appeal
               SET ap_st = 'WD'
             WHERE ap_id = rec.ap_id;
        END LOOP;
    END;

    --====================================================================================--
    PROCEDURE Process_ap_tp_O_1241 (p_hs IN histsession.hs_id%TYPE)
    IS
        -----------------------------------------------------------------
        CURSOR ap_tp_o_1241 IS
            WITH
                ap
                AS
                    (SELECT ap.ap_id,
                            ap.ap_num,
                            ap.ap_reg_dt,
                            ap.ap_st,
                            aps_nst,
                            app.app_id,
                            app.app_sc,
                            pc_id,
                            862     AS edit_nst
                       FROM tmp_work_ids
                            JOIN appeal ap ON ap_id = x_id AND ap_tp = 'O'
                            JOIN ap_service aps
                                ON     aps_ap = ap_id
                                   AND aps_nst = 1241
                                   AND aps.history_status = 'A'
                            JOIN ap_person app
                                ON     app_ap = ap_id
                                   AND app_tp = 'O'
                                   AND app.history_status = 'A'
                            JOIN personalcase pc ON pc_sc = app_sc)
            SELECT ap_id,
                   ap_num,
                   ap_reg_dt,
                   ap_st,
                   aps_nst,
                   pd.pd_id,
                   pd.pd_num,
                   pd.pd_st,
                   pd.pd_start_dt,
                   pd.pd_stop_dt,
                   edit_nst,
                   npd.pd_id                           AS new_pd_id,
                   npd.pd_num                          AS new_pd_num,
                   npd.pd_start_dt                     AS new_pd_start_dt,
                   npd.pd_stop_dt                      AS new_pd_stop_dt,
                   CASE
                       WHEN pd.pd_id IS NOT NULL AND npd.pd_id IS NULL
                       THEN
                           'I'
                       WHEN pd.pd_id IS NULL AND npd.pd_id IS NOT NULL
                       THEN
                           'U'
                       WHEN pd.pd_id IS NOT NULL AND npd.pd_id IS NOT NULL
                       THEN
                           'U'
                       ELSE
                           'ERR'
                   END                                 AS pd_Mode,
                   api$appeal.get_doc_dt_max (ap_id,
                                              NULL,
                                              10108,
                                              2275)    AS recalc_max_dt
              FROM ap
                   LEFT JOIN pc_decision pd
                       ON     pd.pd_pc = pc_id
                          AND pd.pd_nst = edit_nst
                          AND pd.pd_st IN ('S', 'PS')
                          AND pd.pd_ap_reason != ap.ap_id
                   LEFT JOIN pc_decision npd
                       ON npd.pd_ap_reason = ap.ap_id AND npd.pd_st != 'V'
             WHERE     (   ap.ap_reg_dt BETWEEN pd.pd_start_dt
                                            AND ADD_MONTHS (pd.pd_stop_dt, 4)
                        OR npd.pd_id IS NOT NULL)
                   AND edit_nst NOT IN (248, 664)
                   AND (   EXISTS
                               (SELECT 1
                                  FROM TMP_WORK_PA_IDS t
                                 WHERE     (   t.x_pa = pd.pd_pa
                                            OR t.x_pa = npd.pd_pa)
                                       AND t.x_nst = 1
                                       AND t.x_ap = ap.ap_id)
                        OR NOT EXISTS
                               (SELECT 1
                                  FROM TMP_WORK_PA_IDS t
                                 WHERE t.x_ap = ap.ap_id));
    -----------------------------------------------------------------
    BEGIN
        FOR rec IN ap_tp_o_1241
        LOOP
            --dbms_output.put_line('pc_id='||rec.pc_id||'   rec.app_sc='||rec.app_sc);
            IF rec.ap_st != 'O'
            THEN
                raise_application_error (
                    -20000,
                       'Повідомлення про вступ до навчального закладу '
                    || rec.ap_num
                    || ' вже оброблено!');
            END IF;

            IF rec.pd_id IS NULL AND rec.new_pd_id IS NULL
            THEN
                raise_application_error (
                    -20000,
                       'Опрацювання звернення "Повідомлення про вступ до навчального закладу" не можливо. '
                    || 'Щодо отримувача допомоги не знайдено рішення у статусі "Нараховано" для виду допомоги,');
            END IF;

            IF rec.pd_Mode = 'I'
            THEN
                api$pc_decision.Copy_Document2Socialcard (p_ap => rec.ap_id);

                INSERT INTO pd_source (pds_id,
                                       pds_pd,
                                       pds_tp,
                                       pds_ap,
                                       pds_create_dt,
                                       history_status,
                                       pds_recalc_dt)
                    SELECT 0,
                           rec.pd_id     AS pds_pd,
                           'AP'          AS pds_tp,
                           rec.ap_id     AS pds_ap,
                           SYSDATE,
                           'A',
                           rec.pd_stop_dt + 1              --rec.recalc_min_dt
                      FROM DUAL;

                API$ESR_Action.PrepareWrite_Visit_ap_log (
                    rec.ap_id,
                    'O',
                    rec.pd_id,
                    CHR (38) || '130#' || rec.pd_num);

                ---Перевіремо, чи подовжується рішення.
                IF rec.pd_stop_dt < rec.recalc_max_dt
                THEN
                    API$PC_DECISION.write_pd_log (
                        rec.pd_id,
                        p_hs,
                        'S',
                           CHR (38)
                        || '314#'
                        || TO_CHAR (rec.pd_stop_dt, 'dd.mm.yyyy')
                        || '#'
                        || TO_CHAR (rec.recalc_max_dt, 'dd.mm.yyyy')
                        || '#'
                        || rec.ap_num,
                        NULL);

                    UPDATE pc_decision pd
                       SET pd.pd_stop_dt = rec.recalc_max_dt,
                           pd.pd_ap_reason = rec.ap_id,
                           pd.pd_src = 'RC'
                     WHERE pd_id = rec.pd_id;

                    INSERT INTO pd_accrual_period (pdap_id,
                                                   pdap_pd,
                                                   pdap_start_dt,
                                                   pdap_stop_dt,
                                                   pdap_change_pd,
                                                   history_status,
                                                   pdap_change_ap,
                                                   pdap_reason_start,
                                                   pdap_reason_stop,
                                                   pdap_pco,
                                                   pdap_hs_ins)
                        SELECT 0     AS x_pdap_id,
                               pdap_pd,
                               rec.pd_stop_dt + 1,
                               rec.recalc_max_dt,
                               pdap_change_pd,
                               history_status,
                               pdap_change_ap,
                               pdap_reason_start,
                               pdap_reason_stop,
                               pdap_pco,
                               p_hs
                          FROM pd_accrual_period
                         WHERE     pdap_pd = rec.pd_id
                               AND pdap_stop_dt = rec.pd_stop_dt
                               AND history_status = 'A'
                               AND rec.pd_st = 'S';
                ELSE
                    UPDATE pc_decision pd
                       SET pd.pd_ap_reason = rec.ap_id, pd.pd_src = 'RC'
                     WHERE pd_id = rec.pd_id;
                END IF;
            ELSE
                NULL;
            END IF;

            UPDATE appeal
               SET ap_st = 'WD'
             WHERE ap_id = rec.ap_id;

            IF rec.pd_stop_dt < rec.recalc_max_dt
            THEN
                calc_pd_RC (rec.pd_id, rec.pd_stop_dt + 1, rec.recalc_max_dt);
            ELSE
                calc_pd_RC (rec.pd_id, rec.pd_stop_dt + 1);
            END IF;
        END LOOP;
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
        l_cnt               INTEGER;
        pay_method          pd_pay_method%ROWTYPE;
        l_curr_id           NUMBER := 0;
        l_pd_id             NUMBER;
        l_CHNG_CODE         VARCHAR2 (200);
        l_PD_SRC            VARCHAR2 (200) := 'PV';
        l_prew_pd_stop_dt   DATE;            --дата закриття існуючого рішення
        l_new_pd_start_dt   DATE;               --дата відкмття нового рішення

        /*
        ndt_id=200 nda_id=792 Дата встановлення інвалідності DATE
        ndt_id=201 nda_id=352 дата встановлення інвалідності
        */
        -- Зміна складу сім`ї
        CURSOR ap_tp_o_change IS
            WITH
                ap
                AS
                    (SELECT ap.ap_id,
                            ap.ap_num,
                            ap.ap_reg_dt,
                            ap.ap_st,
                            aps_nst,
                            app.app_id,
                            app.app_sc,
                            pc_id,
                            CASE aps_nst
                                WHEN 643
                                THEN
                                    REGEXP_SUBSTR (
                                        API$PC_DECISION.get_doc_string (
                                            app.app_id,
                                            10098,
                                            2262),
                                        '[[:digit:]]+')
                                WHEN 801
                                THEN
                                    REGEXP_SUBSTR (
                                        API$PC_DECISION.get_doc_string (
                                            app.app_id,
                                            10099,
                                            2260),
                                        '[[:digit:]]+')
                                ELSE
                                    NULL
                            END    AS edit_nst,
                            CASE
                                WHEN ap.ap_reg_dt >=
                                     TO_DATE ('01.08.2023', 'dd.mm.yyyy')
                                THEN
                                    1
                                ELSE
                                    0
                            END    AS ap_Is_New
                       FROM tmp_work_ids
                            JOIN appeal ap ON ap_id = x_id AND ap_tp = 'O'
                            JOIN ap_service aps
                                ON     aps_ap = ap_id
                                   AND (aps_nst = 643 OR aps_nst = 801)
                                   AND aps.history_status = 'A'
                            JOIN ap_person app
                                ON     app_ap = ap_id
                                   AND app_tp = 'O'
                                   AND app.history_status = 'A'
                            JOIN personalcase pc ON pc_sc = app_sc)
              SELECT ap_id,
                     ap_num,
                     ap_reg_dt,
                     ap_st,
                     aps_nst,
                     pd.pd_id,
                     pd.pd_num,
                     pd.pd_st,
                     pd.pd_start_dt,
                     pd.pd_stop_dt,
                     NVL (api$pc_decision.get_pd_doc_dt (pd.pd_id,
                                                         NULL,
                                                         201,
                                                         347),
                          api$pc_decision.get_pd_doc_dt (pd.pd_id,
                                                         NULL,
                                                         200,
                                                         793))
                         AS inv_stop_dt,
                     (SELECT MAX (p.pdp_stop_dt)     stop_dt_for_309
                        FROM pd_payment p
                       WHERE     p.pdp_pd = pd.pd_id
                             AND p.pdp_npt = 181
                             AND p.history_status = 'A')
                         stop_dt_for_309,
                     --API$PC_DECISION.get_doc_dt(app_id, 200, 792) AS start_dt_nda_200_792,
                     --API$PC_DECISION.get_doc_dt(app_id, 201, 352) AS start_dt_nda_201_352,
                      (SELECT MIN (
                                  API$PC_DECISION.get_doc_dt (app_.app_id,
                                                              200,
                                                              792))
                         FROM ap_person app_
                        WHERE app_.app_ap = ap_id AND app_.history_status = 'A')
                         AS start_dt_nda_200_792,
                     (SELECT MIN (
                                 API$PC_DECISION.get_doc_dt (app_.app_id,
                                                             201,
                                                             352))
                        FROM ap_person app_
                       WHERE app_.app_ap = ap_id AND app_.history_status = 'A')
                         AS start_dt_nda_201_352,
                     edit_nst,
                     npd.pd_id
                         AS new_pd_id,
                     npd.pd_num
                         AS new_pd_num,
                     npd.pd_start_dt
                         AS new_pd_start_dt,
                     npd.pd_stop_dt
                         AS new_pd_stop_dt,
                     CASE
                         WHEN pd.pd_id IS NOT NULL AND npd.pd_id IS NULL
                         THEN
                             'I'
                         WHEN pd.pd_id IS NULL AND npd.pd_id IS NOT NULL
                         THEN
                             'U'
                         WHEN pd.pd_id IS NOT NULL AND npd.pd_id IS NOT NULL
                         THEN
                             'U'
                         ELSE
                             'ERR'
                     END
                         AS pd_Mode,
                     ap_Is_New
                FROM ap
                     LEFT JOIN pc_decision pd
                         ON     pd.pd_pc = pc_id
                            AND pd.pd_nst = edit_nst
                            --AND ap.ap_reg_dt BETWEEN pd.pd_start_dt AND pd.pd_stop_dt
                            AND (   (pd.pd_nst = 664 AND pd.pd_st = 'S')
                                 OR (    pd.pd_nst != 664
                                     AND pd.pd_st IN ('S', 'PS')))
                            AND pd.pd_ap_reason != ap.ap_id
                     LEFT JOIN pc_decision npd
                         ON npd.pd_ap_reason = ap.ap_id AND npd.pd_st != 'V'
               WHERE     (   ap.ap_reg_dt BETWEEN pd.pd_start_dt
                                              AND pd.pd_stop_dt
                          OR (    edit_nst = 248
                              AND pd.pd_id =
                                  (SELECT MAX (pd_.pd_id)
                                     FROM pc_decision pd_
                                    WHERE     pd_.pd_pa = pd.pd_pa
                                          AND pd_.pd_st IN ('S')
                                          AND pd_.pd_ap_reason != ap.ap_id))
                          OR                          /*pd.pd_id is null and*/
                             npd.pd_id IS NOT NULL)
                     AND (   EXISTS
                                 (SELECT 1
                                    FROM TMP_WORK_PA_IDS t
                                   WHERE     (   t.x_pa = pd.pd_pa
                                              OR t.x_pa = npd.pd_pa)
                                         AND t.x_nst = 1
                                         AND t.x_ap = ap.ap_id)
                          OR NOT EXISTS
                                 (SELECT 1
                                    FROM TMP_WORK_PA_IDS t
                                   WHERE t.x_ap = ap.ap_id))
                     AND edit_nst NOT IN (901)
            ORDER BY ap_id ASC, pd.pd_id DESC;

        ------------------------------------------------------------------
        PROCEDURE Close_accrual_period (p_pd_id NUMBER, p_dt DATE)
        IS
            l_pdap_id   pd_accrual_period.pdap_id%TYPE;
        BEGIN
            FOR rec
                IN (SELECT NULL,
                           pdap_pd,
                           pdap_start_dt,
                           p_dt            AS x_stop_dt,
                           l_CHNG_CODE     AS x_reason_stop
                      FROM pd_accrual_period ac
                     WHERE     ac.pdap_pd = p_pd_id
                           AND ac.history_status = 'A'
                           AND p_dt BETWEEN ac.pdap_start_dt
                                        AND ac.pdap_stop_dt
                           AND ROWNUM < 2)
            LOOP
                INSERT INTO pd_accrual_period (pdap_id,
                                               pdap_pd,
                                               pdap_start_dt,
                                               pdap_stop_dt,
                                               history_status,
                                               pdap_reason_start,
                                               pdap_hs_ins)
                     VALUES (NULL,
                             rec.pdap_pd,
                             rec.pdap_start_dt,
                             rec.x_stop_dt,
                             'A',
                             rec.x_reason_stop,
                             p_hs)
                  RETURNING pdap_id
                       INTO l_pdap_id;
            END LOOP;

            UPDATE pd_accrual_period ac
               SET ac.history_status = 'H',
                   ac.pdap_reason_stop = l_CHNG_CODE,
                   ac.pdap_hs_del = p_hs
             WHERE     ac.pdap_pd = p_pd_id
                   AND ac.history_status = 'A'
                   AND (   p_dt BETWEEN ac.pdap_start_dt AND ac.pdap_stop_dt
                        OR p_dt < ac.pdap_start_dt)
                   AND (ac.pdap_id != l_pdap_id OR l_pdap_id IS NULL);
        END;
    ------------------------------------------------------------------
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

        /*
          DECLARE
            str  VARCHAR(200);
          BEGIN
             SELECT  listagg('x_ap = '||x_ap||'  x_nst = '||x_nst||'  x_pa = '||x_pa , chr(13)||chr(10) )
                INTO str
             FROM TMP_WORK_PA_IDS;
            raise_application_error(-20000, str);
          END;
        */

        -- 641 послуга
        Process_ap_tp_O_641 (p_hs);

        -- 642 послуга
        Process_ap_tp_O_642 (p_hs);

        -- 643 послуга
        Process_ap_tp_O_643 (p_hs);

        -- 1161 послуга
        Process_ap_tp_O_1161 (p_hs, p_com_wu);
        --    raise_application_error(-20000, 'test');
        -- 1162 послуга
        Process_ap_tp_O_1162 (p_hs, p_com_wu);

        -- 1181 послуга
        Process_ap_tp_O_1181 (p_hs, p_com_wu);

        -- 1241 послуга
        Process_ap_tp_O_1241 (p_hs);

        FOR rec IN ap_tp_o_change
        LOOP
            CONTINUE WHEN l_curr_id = rec.ap_id;

            l_curr_id := rec.ap_id;

            IF rec.pd_id IS NULL AND rec.new_pd_id IS NULL
            THEN
                IF rec.aps_nst = 643
                THEN
                    raise_application_error (
                        -20000,
                           'Опрацювання звернення "Зміна складу сім''ї " не можливо. '
                        || 'Щодо отримувача допомоги не знайдено рішення у статусі "Нараховано" для виду допомоги, '
                        || 'яка вказана у документі "Зміна виплатних реквізитів" в атрибуті "Вид допомоги"');
                ELSIF rec.aps_nst = 801
                THEN
                    raise_application_error (
                        -20000,
                           'Опрацювання звернення "Повідомлення про встановлення інвалідності" не можливо. '
                        || 'Не знайдено рішення у статусі «Нараховано» щодо допомоги, '
                        || 'яка вказана в документі «Повідомлення про встановлення інвалідності» в атрибуті «Вид допомоги»');
                ELSE
                    raise_application_error (
                        -20000,
                           'Не знайдено рішення у статусі «Нараховано» щодо допомоги, '
                        || 'яка вказана в документі «Повідомлення про встановлення інвалідності» в атрибуті «Вид допомоги»');
                END IF;
            END IF;

            l_CHNG_CODE := tools.ggp ('CHANGE_FAMILY_CODE', rec.ap_reg_dt);

            /*
                           pd.pd_id, pd.pd_num, pd.pd_st,pd.pd_start_dt, pd.pd_stop_dt,
                           (select max(p.pdp_stop_dt) stop_dt_for_309
            */

            --      raise_application_error(-20000, 'rec.pd_Mode = '||rec.pd_Mode);

            IF rec.pd_Mode = 'I'
            THEN
                IF     rec.edit_nst = 664
                   AND (   rec.stop_dt_for_309 IS NOT NULL
                        OR rec.pd_start_dt <
                           TO_DATE ('01.03.2022', 'dd.mm.yyyy'))
                   AND rec.ap_is_new = 0
                THEN
                    --raise_application_error(-20000, 'rec.pd_start_dt = '||rec.pd_start_dt);
                    IF rec.stop_dt_for_309 >
                       TO_DATE ('01.03.2022', 'dd.mm.yyyy')
                    THEN
                        l_prew_pd_stop_dt := LAST_DAY (rec.stop_dt_for_309);
                    ELSE
                        l_prew_pd_stop_dt :=
                            TO_DATE ('01.03.2022', 'dd.mm.yyyy') - 1;
                    END IF;

                    l_new_pd_start_dt := l_prew_pd_stop_dt + 1;
                    -- Тут рішення у S, але accrual_period по l_prew_pd_stop_dt
                    Close_accrual_period (rec.pd_id, l_prew_pd_stop_dt);
                ELSIF rec.edit_nst = 664 AND rec.ap_is_new > 0
                THEN
                    --l_new_pd_start_dt := trunc(add_months(rec.ap_reg_dt,1), 'MM');
                    l_new_pd_start_dt := TRUNC (rec.ap_reg_dt, 'MM');
                    l_prew_pd_stop_dt := l_new_pd_start_dt - 1;

                    IF l_new_pd_start_dt = rec.pd_start_dt
                    THEN
                        API$PC_DECISION.decision_block_pap (rec.pd_id,
                                                            rec.pd_start_dt,
                                                            'CH_CRC',
                                                            rec.ap_id);
                    ELSE
                        API$PC_DECISION.decision_block_pap (
                            rec.pd_id,
                            l_prew_pd_stop_dt,
                            'CH_CRC',
                            rec.ap_id);
                    END IF;
                ELSIF     rec.edit_nst = 248
                      AND rec.start_dt_nda_200_792 IS NULL
                      AND rec.start_dt_nda_201_352 IS NULL
                THEN                                                        --
                    raise_application_error (
                        -20000,
                           'Опрацювання звернення "Повідомлення про встановлення інвалідності" не можливо. '
                        || 'Не встановлено дату, з якої призначено інвалідність, '
                        || 'яка вказана в документі «Виписка з акту огляду МСЕК про встановлення, зняття або зміну групи інвалідності» або '
                        || '«Медичний висновок (для дітей з інвалідністю до 18 років)»');
                ELSIF     rec.edit_nst = 248
                      AND rec.start_dt_nda_200_792 IS NOT NULL
                THEN                                                        --
                    --          raise_application_error(-20000, 'rec.start_dt_nda_200_792 = '||rec.start_dt_nda_200_792);
                    l_PD_SRC := 'RC';

                    IF TRUNC (rec.pd_stop_dt) >
                       TRUNC (rec.start_dt_nda_200_792) - 1
                    THEN
                        l_new_pd_start_dt := TRUNC (rec.start_dt_nda_200_792);
                        l_prew_pd_stop_dt := l_new_pd_start_dt - 1;
                    -- Тут рішення у S, але accrual_period по l_prew_pd_stop_dt

                    ELSIF TRUNC (rec.pd_stop_dt) =
                          TRUNC (rec.start_dt_nda_200_792) - 1
                    THEN
                        l_new_pd_start_dt := TRUNC (rec.start_dt_nda_200_792);
                    ELSIF TRUNC (rec.pd_stop_dt) BETWEEN ADD_MONTHS (
                                                             TRUNC (
                                                                 rec.start_dt_nda_200_792),
                                                             -1)
                                                     AND TRUNC (
                                                             rec.start_dt_nda_200_792)
                    THEN
                        l_new_pd_start_dt := TRUNC (rec.pd_stop_dt) + 1;
                    ELSE
                        l_new_pd_start_dt :=
                            ADD_MONTHS (TRUNC (rec.start_dt_nda_200_792), -1);
                    END IF;
                ELSIF     rec.edit_nst = 248
                      AND rec.start_dt_nda_201_352 IS NOT NULL
                THEN                                                        --
                    /*
                    Відсутня перерва (дата в nda_id=352 зазначена дата, до якої призначено інвалідність +1 день)  З дати зазначеної в nda_id=352
                    Перерва менше ніж 1 місяць  З дати, до якої була призначена попередня допомога+1 день
                    Перерва більше ніж 1 місяць  З дати зазначеної в nda_id=352 мінус один місяць
                    */
                    --          raise_application_error(-20000, 'rec.start_dt_nda_201_352 = '||rec.start_dt_nda_201_352);

                    l_PD_SRC := 'RC';

                    IF TRUNC (NVL (rec.inv_stop_dt, rec.pd_stop_dt)) >
                       TRUNC (rec.start_dt_nda_201_352) - 1
                    THEN
                        l_new_pd_start_dt := TRUNC (rec.start_dt_nda_201_352);
                        l_prew_pd_stop_dt := l_new_pd_start_dt - 1;
                    -- Тут рішення у S, але accrual_period по l_prew_pd_stop_dt

                    ELSIF TRUNC (NVL (rec.inv_stop_dt, rec.pd_stop_dt)) =
                          TRUNC (rec.start_dt_nda_201_352) - 1
                    THEN
                        l_new_pd_start_dt := TRUNC (rec.start_dt_nda_201_352);
                    ELSIF TRUNC (NVL (rec.inv_stop_dt, rec.pd_stop_dt)) BETWEEN ADD_MONTHS (
                                                                                    TRUNC (
                                                                                        rec.start_dt_nda_201_352),
                                                                                    -1)
                                                                            AND TRUNC (
                                                                                    rec.start_dt_nda_201_352)
                    THEN
                        l_new_pd_start_dt :=
                            TRUNC (NVL (rec.inv_stop_dt, rec.pd_stop_dt)) + 1;
                    ELSE
                        l_new_pd_start_dt :=
                            ADD_MONTHS (TRUNC (rec.start_dt_nda_201_352), -1);
                    END IF;
                ELSIF rec.edit_nst = 249
                THEN
                    l_PD_SRC := 'RC';
                    l_new_pd_start_dt := TRUNC (rec.ap_reg_dt, 'MM');
                    l_prew_pd_stop_dt := l_new_pd_start_dt - 1;
                ELSE
                    -- Тут рішення у PS, accrual_period потім потрібно перерахувати
                    l_new_pd_start_dt := rec.pd_start_dt;
                    API$PC_DECISION.decision_block (rec.pd_id,
                                                    l_CHNG_CODE,
                                                    rec.ap_id,
                                                    p_hs);
                END IF;

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
                           l_PD_SRC     AS x_pd_src,
                           pd_ps        AS x_pd_ps,
                           pd_id,
                           pd_has_right,
                           l_new_pd_start_dt,                 /*pd_start_dt,*/
                           pd_stop_dt,
                           rec.ap_id,
                           pd_scc
                      FROM pc_decision pd
                     WHERE     pd.pd_id = rec.pd_id
                           AND NOT EXISTS
                                   (SELECT 1
                                      FROM pc_decision pdsl
                                     WHERE     pdsl.pd_ap_reason = rec.ap_id
                                           AND pdsl.pd_st != 'V');

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

                MERGE INTO pd_income_session
                     USING (SELECT pin_id     AS x_pin_id,
                                   pd_id      AS x_pin_pd,
                                   'FST'      AS x_pin_tp,
                                   p_hs       AS x_pin_hs_ins,
                                   pin_st     AS x_pin_st
                              FROM pc_decision
                                   LEFT JOIN pd_income_session
                                       ON     pin_pd = pd_id
                                          AND pin_tp = 'FST'
                                          AND pin_st = 'E'
                             WHERE pd_id = l_pd_id)
                        ON (pin_id = x_pin_id)
                --WHEN MATCHED THEN
                WHEN NOT MATCHED
                THEN
                    INSERT     (pin_id,
                                pin_pd,
                                pin_tp,
                                pin_hs_ins,
                                pin_st)
                        VALUES (0,
                                x_pin_pd,
                                x_pin_tp,
                                x_pin_hs_ins,
                                'E');

                IF rec.edit_nst = 249
                THEN                -- потрібно взяти старий розрахунок доходу
                    move_pd_income (rec.pd_id, l_pd_id);
                END IF;

                FOR pm
                    IN (  SELECT p.*
                            FROM pd_pay_method p
                           WHERE     p.pdm_pd = rec.pd_id
                                 AND p.history_status = 'A'
                                 AND (   l_new_pd_start_dt <= p.pdm_start_dt
                                      OR l_new_pd_start_dt BETWEEN p.pdm_start_dt
                                                               AND p.pdm_stop_dt)
                        ORDER BY p.pdm_start_dt ASC, p.pdm_id DESC)
                LOOP
                    pay_method := pm;
                    pay_method.pdm_id := NULL;
                    pay_method.pdm_pd := l_pd_id;

                    IF pay_method.pdm_start_dt < l_new_pd_start_dt
                    THEN
                        pay_method.pdm_start_dt := l_new_pd_start_dt;
                    END IF;

                    INSERT INTO pd_pay_method
                         VALUES pay_method;
                END LOOP;

                SELECT COUNT (1)
                  INTO l_cnt
                  FROM pd_pay_method
                 WHERE pdm_pd = l_pd_id;

                IF l_cnt = 0
                THEN
                    FOR pm
                        IN (  SELECT p.*
                                FROM pd_pay_method p
                               WHERE     p.pdm_pd = rec.pd_id
                                     AND p.history_status = 'A'
                            ORDER BY p.pdm_start_dt ASC)
                    LOOP
                        pay_method := pm;
                    END LOOP;

                    pay_method.pdm_id := NULL;
                    pay_method.pdm_pd := l_pd_id;
                    pay_method.pdm_start_dt := l_new_pd_start_dt;
                    pay_method.pdm_stop_dt :=
                        ADD_MONTHS (l_new_pd_start_dt, 12);

                    INSERT INTO pd_pay_method
                         VALUES pay_method;
                END IF;


                IF rec.edit_nst = 664 AND rec.ap_is_new > 0
                THEN
                    NULL;
                ELSIF     rec.stop_dt_for_309 IS NULL
                      AND rec.pd_start_dt >=
                          TO_DATE ('01.03.2022', 'dd.mm.yyyy')
                THEN
                    API$PC_DECISION.recalc_pd_periods_pv (
                        p_pd_id      => rec.pd_id,
                        p_start_dt   => l_new_pd_start_dt,
                        p_hs         => p_hs);
                END IF;
            ELSE
                IF rec.edit_nst = 664 AND rec.ap_is_new > 0
                THEN
                    l_new_pd_start_dt := TRUNC (rec.ap_reg_dt, 'MM');
                    l_prew_pd_stop_dt := l_new_pd_start_dt - 1;

                    UPDATE pc_decision
                       SET pd_start_dt = l_new_pd_start_dt
                     WHERE pd_id = rec.new_pd_id;

                    NULL;
                ELSIF     rec.pd_id IS NOT NULL
                      AND rec.stop_dt_for_309 IS NULL
                      AND rec.pd_start_dt >=
                          TO_DATE ('01.03.2022', 'dd.mm.yyyy')
                      AND rec.edit_nst NOT IN (248)
                THEN
                    API$PC_DECISION.decision_block (rec.pd_id,
                                                    l_CHNG_CODE,
                                                    rec.ap_id,
                                                    p_hs);
                END IF;


                IF     rec.edit_nst = 248
                   AND rec.start_dt_nda_200_792 IS NOT NULL
                THEN                                                        --
                    l_PD_SRC := 'RC';

                    IF TRUNC (NVL (rec.inv_stop_dt, rec.pd_stop_dt)) >
                       TRUNC (rec.start_dt_nda_200_792) - 1
                    THEN
                        l_new_pd_start_dt := TRUNC (rec.start_dt_nda_200_792);
                    ELSIF TRUNC (NVL (rec.inv_stop_dt, rec.pd_stop_dt)) =
                          TRUNC (rec.start_dt_nda_200_792) - 1
                    THEN
                        l_new_pd_start_dt := TRUNC (rec.start_dt_nda_200_792);
                    ELSIF TRUNC (NVL (rec.inv_stop_dt, rec.pd_stop_dt)) BETWEEN ADD_MONTHS (
                                                                                    TRUNC (
                                                                                        rec.start_dt_nda_200_792),
                                                                                    -1)
                                                                            AND TRUNC (
                                                                                    rec.start_dt_nda_200_792)
                    THEN
                        l_new_pd_start_dt :=
                            TRUNC (NVL (rec.inv_stop_dt, rec.pd_stop_dt)) + 1;
                    ELSE
                        l_new_pd_start_dt :=
                            ADD_MONTHS (TRUNC (rec.start_dt_nda_200_792), -1);
                    END IF;

                    --          raise_application_error(-20000, '248  '||chr(13)||
                    --                                          'rec.start_dt_nda_200_792 = '||rec.start_dt_nda_200_792||chr(13)||
                    --                                          'l_new_pd_start_dt = '||l_new_pd_start_dt||chr(13)||
                    --                                          'rec.inv_stop_dt   = '||rec.inv_stop_dt||chr(13)||
                    --                                          'rec.pd_stop_dt    = '||rec.pd_stop_dt
                    --                                  );
                    UPDATE pc_decision
                       SET pd_start_dt = l_new_pd_start_dt, pd_src = l_PD_SRC
                     WHERE pd_id = rec.new_pd_id;
                ELSIF     rec.edit_nst = 248
                      AND rec.start_dt_nda_201_352 IS NOT NULL
                THEN                                                        --
                    --          raise_application_error(-20000, 'rec.start_dt_nda_201_352 = '||rec.start_dt_nda_201_352);
                    l_PD_SRC := 'RC';

                    IF TRUNC (NVL (rec.inv_stop_dt, rec.pd_stop_dt)) >
                       TRUNC (rec.start_dt_nda_201_352) - 1
                    THEN
                        l_new_pd_start_dt := TRUNC (rec.start_dt_nda_201_352);
                    ELSIF TRUNC (NVL (rec.inv_stop_dt, rec.pd_stop_dt)) =
                          TRUNC (rec.start_dt_nda_201_352) - 1
                    THEN
                        l_new_pd_start_dt := TRUNC (rec.start_dt_nda_201_352);
                    ELSIF TRUNC (NVL (rec.inv_stop_dt, rec.pd_stop_dt)) BETWEEN ADD_MONTHS (
                                                                                    TRUNC (
                                                                                        rec.start_dt_nda_201_352),
                                                                                    -1)
                                                                            AND TRUNC (
                                                                                    rec.start_dt_nda_201_352)
                    THEN
                        l_new_pd_start_dt :=
                            TRUNC (NVL (rec.inv_stop_dt, rec.pd_stop_dt)) + 1;
                    ELSE
                        l_new_pd_start_dt :=
                            ADD_MONTHS (TRUNC (rec.start_dt_nda_201_352), -1);
                    END IF;

                    --          raise_application_error(-20000, '248  '||chr(13)||
                    --                                          'l_new_pd_start_dt = '||rec.start_dt_nda_201_352||chr(13)||
                    --                                          'rec.inv_stop_dt   = '||rec.inv_stop_dt||chr(13)||
                    --                                          'rec.pd_stop_dt    = '||rec.pd_stop_dt
                    --                                  );
                    UPDATE pc_decision
                       SET pd_start_dt = l_new_pd_start_dt, pd_src = l_PD_SRC
                     WHERE pd_id = rec.new_pd_id;
                /*
                        ELSIF rec.edit_nst = 664 AND rec.start_dt_nda_201_352 IS NOT NULL THEN  --

                        dbms_output_put_lines( 'rec.edit_nst = '||rec.edit_nst);
                        dbms_output_put_lines( 'rec.start_dt_nda_201_352 = '||rec.start_dt_nda_201_352);
                        dbms_output_put_lines( 'rec.new_pd_stop_dt = '||rec.new_pd_stop_dt);

                          IF trunc(rec.pd_stop_dt) > trunc(rec.start_dt_nda_201_352)-1 THEN
                            l_new_pd_start_dt := trunc(rec.start_dt_nda_201_352);
                          ELSIF trunc(rec.pd_stop_dt) = trunc(rec.start_dt_nda_201_352)-1 THEN
                            l_new_pd_start_dt := trunc(rec.start_dt_nda_201_352);
                          ELSIF trunc(rec.pd_stop_dt) BETWEEN add_months(trunc(rec.start_dt_nda_201_352),-1) AND trunc(rec.start_dt_nda_201_352) THEN
                            l_new_pd_start_dt := trunc(rec.pd_stop_dt)+1;
                          ELSE
                            l_new_pd_start_dt := add_months(trunc(rec.start_dt_nda_201_352),-1);
                          END IF;
                          UPDATE pc_decision SET
                              pd_start_dt = l_new_pd_start_dt
                          WHERE pd_id = rec.new_pd_id;
                */
                END IF;

                UPDATE pc_decision
                   SET pd_st = 'R0'
                 WHERE pd_id = rec.new_pd_id;
            END IF;



            --recalc_pd_periods(p_pd_id => rec.pd_id, p_hs => p_hs);
            UPDATE appeal
               SET ap_st = 'WD'
             WHERE ap_id = rec.ap_id;
        END LOOP;
    END;

    --========================================================================--
    --  Функція формування проектів рішень про призначення на основі звернення
    --  p_mode 1=з p_ap_id, 2=з таблиці tmp_work_ids 3=з p_ap_id у авторежимі  4=з таблиці tmp_work_ids у авторежимі
    --========================================================================--
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
                                     'VV',
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
                                 'VV',
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

        --Якщо є рішення по зміні обставин - обробляємо
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

        /*
          DECLARE
            str  VARCHAR(200);
          BEGIN
             SELECT  listagg('x_ap = '||x_ap||'  x_nst = '||x_nst||'  x_pa = '||x_pa , chr(13)||chr(10) )
                INTO str
             FROM TMP_WORK_PA_IDS;
            raise_application_error(-20000, str);
          END;
        */
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
                   AND ap_tp IN ('V',
                                 'VV',
                                 'U',
                                 'SS')
                   AND aps_ap = ap_id
                   AND aps_ap = x_id
                   AND aps_nst = nst_id
                   AND ap_pc = pc_id
                   AND ap_pc IS NOT NULL
                   AND nst_is_or_generate = 'T'
                   AND NOT EXISTS
                           (SELECT 1
                              FROM pc_decision
                             WHERE pd_ap_reason = ap_id)
                   --      AND NOT EXISTS (SELECT 1
                   --                      FROM pc_decision
                   --                      WHERE pd_pc = pc_id
                   --                        AND pd_nst = aps_nst)
                   AND (   NOT EXISTS
                               (SELECT 1
                                  FROM pc_account
                                 WHERE pa_pc = pc_id AND pa_nst = aps_nst)
                        OR EXISTS
                               (SELECT 1
                                  FROM TMP_WORK_PA_IDS
                                 WHERE     x_ap = ap_id
                                       AND x_nst = aps_nst
                                       AND x_pa IN (0, -1)));

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
            --Вішаємо lock на генерацію номера для ОР
            l_lock :=
                TOOLS.request_lock (
                    p_descr   => 'CALC_PA_NUMS_PC_' || xx.pc_id,
                    p_error_msg   =>
                           'В даний момент вже виконується генерація номерів для особових рахунків ЕОС №'
                        || xx.pc_num
                        || '!');

            l_num := API$PC_DECISION.gen_pa_num (xx.pc_id);

            UPDATE pc_account
               SET pa_num = l_num
             WHERE pa_id = xx.pa_id;

            --Формвання записів в таблицю обробки - для можливості обробки звереннь на нові держутримання
            INSERT INTO tmp_work_pa_ids (x_pa, x_nst)
                 VALUES (xx.pa_id, 3);

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

        SELECT COUNT (1) INTO l_cnt FROM tmp_work_pa_ids;

        --       raise_application_error(-20000, 'p_mode = '||p_mode||' l_com_org = ' || l_com_org ||';l_cnt='||l_cnt );

        --Якщо є рішення по дерутриманню, ініціалізуємо по ним держутримання/відрахування
        SELECT COUNT (*)
          INTO l_is_have_ap_tp_U
          FROM tmp_work_ids, appeal
         WHERE     x_id = ap_id
               AND ap_st IN ('O')
               AND (   ap_tp IN ('U')            --Звернення держутримання або
                    OR (    ap_tp IN ('V', 'VV')       --Звернення по допомогу
                        AND EXISTS
                                (SELECT 1
                                   FROM ap_service
                                  WHERE     aps_ap = ap_id
                                        AND aps_nst = 248
                                        AND history_Status = 'A') --з послугою "особам з інвалідністю
                        AND EXISTS
                                (SELECT 1
                                   FROM ap_document
                                  WHERE     apd_ap = ap_id
                                        AND apd_ndt = 10034
                                        AND history_Status = 'A'))); --і наявністю довідки про зарахування

        IF l_is_have_ap_tp_U > 0
        THEN
            API$PC_STATE_ALIMONY.init_pc_state_alimony_by_appeals (
                2,
                NULL,
                p_messages);
        END IF;


        UPDATE pc_decision pd
           SET pd.pd_start_dt = NULL, pd.pd_stop_dt = NULL
         WHERE     pd.pd_st = 'R0'
               AND EXISTS
                       (SELECT 1
                          FROM tmp_work_ids
                               JOIN appeal ON ap_id = x_id
                               JOIN pc_decision p ON p.pd_ap = ap_id
                         WHERE     p.pd_id = pd.pd_id
                               AND ap_pc IS NOT NULL
                               AND ap_tp IN ('V', 'SS'));

        -- Якщо відсутня, заливаємо привязку NST до конкретного PA
        --    IF l_cnt = 0 THEN
        --      DELETE FROM TMP_WORK_PA_IDS WHERE 1 = 1;
        INSERT INTO TMP_WORK_PA_IDS (X_PA, X_NST, X_AP)
            WITH
                ap
                AS
                    (SELECT ap_id,
                            ap_pc,
                            CASE
                                WHEN nst_nst_main = 248 THEN nst_nst_main
                                ELSE nst_id
                            END    AS aps_nst
                       FROM tmp_work_ids
                            JOIN appeal ON ap_id = x_id
                            JOIN ap_service aps
                                ON     aps_ap = ap_id
                                   AND aps.history_status = 'A'
                            JOIN uss_ndi.v_ndi_service_type
                                ON     nst_id = aps_nst
                                   AND nst_is_or_generate = 'T')
              SELECT MAX (pa.pa_id), aps_nst, ap_id
                FROM ap
                     JOIN pc_account pa
                         ON pa.pa_pc = ap_pc AND pa.pa_nst = aps_nst
               WHERE    NOT EXISTS
                            (SELECT 1
                               FROM TMP_WORK_PA_IDS
                              WHERE x_ap = ap_id AND x_nst = aps_nst)
                     OR EXISTS
                            (SELECT 1
                               FROM TMP_WORK_PA_IDS
                              WHERE     x_ap = ap_id
                                    AND x_nst = aps_nst
                                    AND x_pa IN (0, -1))
            GROUP BY aps_nst, ap_id;

        --    END IF;
        /*
          DECLARE
            str  VARCHAR(200);
          BEGIN
             SELECT  listagg('x_ap = '||x_ap||'  x_nst = '||x_nst||'  x_pa = '||x_pa , chr(13)||chr(10) )
                INTO str
             FROM TMP_WORK_PA_IDS;
            raise_application_error(-20000, str);
          END;
        */
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
                                                    WHEN 35 THEN ap_dest_org
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
                   AND ap_tp IN ('V', 'VV', 'SS')
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
                             WHERE pd_ap = aps_ap AND pd_nst = aps_nst)
                   AND EXISTS
                           (SELECT 1
                              FROM TMP_WORK_PA_IDS
                             WHERE     X_PA = pa_id
                                   AND X_NST = aps_nst
                                   AND X_AP = ap_id);

        Create_pd_document;

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
             USING (SELECT DISTINCT
                           0            AS x_pde_id,
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



        MERGE INTO pd_features
             USING (SELECT DISTINCT
                           0            AS x_pde_id,
                           pd.pd_id     AS x_pd_id,
                           nft_id       AS x_nft_id
                      FROM tmp_work_ids
                           JOIN pc_decision pd ON pd_ap = x_id
                           JOIN ap_person app
                               ON     app.app_ap = pd.pd_ap
                                  AND app.app_tp IN ('Z', 'FM')
                                  AND app.history_status = 'A'
                           JOIN uss_ndi.v_ndi_pd_feature_type nft
                               ON nft.nft_id IN (82, 83)
                     WHERE     pd.pd_nst IN (249, 267)
                           AND api$appeal.get_doc_string (app.app_id,
                                                          605,
                                                          652) =
                               'T')
                ON (pde_pd = x_pd_id AND pde_nft = x_nft_id)
        WHEN NOT MATCHED
        THEN
            INSERT     (pde_id, pde_pd, pde_nft)
                VALUES (x_pde_id, x_pd_id, x_nft_id);

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
                                 pde_val_string)
            SELECT DISTINCT 0            AS x_pde_id,
                            pd.pd_id     AS x_pd_id,
                            nft_id       AS x_nft_id,
                            'T'          AS x_val
              FROM tmp_work_ids
                   JOIN pc_decision pd ON pd_ap = x_id
                   JOIN ap_person app
                       ON     app.app_ap = pd.pd_ap
                          AND app.app_tp IN ('Z', 'FP')
                          AND app.history_status = 'A'
                   JOIN uss_ndi.v_ndi_pd_feature_type nft
                       ON nft.nft_id IN (37)
             WHERE    api$appeal.get_doc_string (app.app_id, 98, 856) = 'T'
                   OR api$appeal.get_doc_dt (app.app_id, 10034, 923)
                          IS NOT NULL;

        UPDATE pd_features pde
           SET (pde_val_string) =
                   (SELECT CASE
                               WHEN pde.pde_nft = 82
                               THEN
                                   MAX (apda_val_string)
                               ELSE
                                   '0'
                           END
                      FROM pc_decision
                           JOIN ap_document
                               ON     apd_ap = pd_ap
                                  AND ap_document.history_status = 'A'
                           JOIN ap_document_attr
                               ON     apda_apd = apd_id
                                  AND ap_document_attr.history_status = 'A'
                     WHERE     pd_id = pde_pd
                           AND apd_ndt = 605
                           AND apda_nda = 652)
         WHERE     pde.pde_nft IN (82, 83)
               AND pde.pde_pd IN
                       (SELECT pd_id
                          FROM pc_decision  pd
                               JOIN tmp_work_ids ON pd_ap = x_id);

        --Для допомог з Ід=249, 267, 265, 248, 269, 268, якщо до Заявника прикріплено документ з Ід=92,
        --то в Ознаках для ознаки "Проживає, працює (навчається) в гірському нас. пункті" встановлювати "Так"

        MERGE INTO pd_features
             USING (SELECT DISTINCT
                           0            AS x_pde_id,
                           pd.pd_id     AS x_pd_id,
                           nft_id       AS x_nft_id
                      FROM tmp_work_ids
                           JOIN pc_decision pd ON pd_ap = x_id
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
        WHEN NOT MATCHED
        THEN
            INSERT     (pde_id, pde_pd, pde_nft)
                VALUES (x_pde_id, x_pd_id, x_nft_id);

        UPDATE pd_features pde
           SET (pde_val_string) =
                   (SELECT 'T'
                      FROM pc_decision
                           JOIN ap_document
                               ON     apd_ap = pd_ap
                                  AND ap_document.history_status = 'A'
                     WHERE pd_id = pde_pd AND apd_ndt = 92 AND ROWNUM <= 1)
         WHERE     pde.pde_nft IN (90)
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
                     new_pd_matrix,
                     tmp_work_pa_ids
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
                     AND pd_pa = x_pa
                     AND x_nst = 1
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

        --#85322
        INSERT INTO pd_pay_method (pdm_id,
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
                                   pdm_nd,
                                   pdm_pay_dt,
                                   pdm_hs,
                                   pdm_scc,
                                   pdm_is_actual,
                                   pdm_nd_num)
            SELECT 0            AS pdm_id,
                   sa.pd_id     AS pdm_pd,
                   pdm.pdm_start_dt,
                   pdm.pdm_stop_dt,
                   pdm.history_status,
                   pdm.pdm_ap_src,
                   pdm.pdm_pay_tp,
                   pdm.pdm_index,
                   pdm.pdm_kaot,
                   pdm.pdm_nb,
                   pdm.pdm_account,
                   pdm.pdm_street,
                   pdm.pdm_ns,
                   pdm.pdm_building,
                   pdm.pdm_block,
                   pdm.pdm_apartment,
                   pdm.pdm_nd,
                   pdm.pdm_pay_dt,
                   pdm.pdm_hs,
                   pdm.pdm_scc,
                   pdm.pdm_is_actual,
                   pdm.pdm_nd_num
              FROM pc_decision  sa
                   JOIN tmp_work_ids x ON sa.pd_ap_reason = x.x_id
                   JOIN pc_decision pd ON pd.pd_id = sa.pd_src_id
                   JOIN pd_pay_method pdm
                       ON     pdm.pdm_pd = pd.pd_id
                          AND pdm.history_status = 'A'
                          AND pdm.pdm_is_actual = 'T'
             WHERE sa.pd_src = 'SA' AND sa.pd_st = 'R0';

        --Робимо історію для зверненнь, дежерло яких - звернення по держутриманню
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
              FROM pd_source,
                   pc_decision  sa,
                   tmp_work_ids,
                   appeal
             WHERE     pds_pd = sa.pd_src_id
                   AND history_status = 'A'
                   AND pd_ap_reason = x_id
                   AND pd_src = 'SA'
                   AND pd_st = 'R0'
                   AND ap_id = x_id
                   AND ap_tp = 'U'
            UNION ALL
            SELECT 0,
                   pd_id     AS pds_pd,
                   'AP'      AS pds_tp,
                   x_id      AS pds_ap,
                   SYSDATE,
                   'A'
              FROM pc_decision sa, tmp_work_ids, appeal
             WHERE     pd_ap_reason = x_id
                   AND pd_src = 'SA'
                   AND pd_st = 'R0'
                   AND ap_id = x_id
                   AND ap_tp = 'U';

        --Розрахунок
        --Видаляємо лог попереднього розрахунку
        DELETE FROM pd_right_log
              WHERE prl_pd IN
                        (SELECT pd_id
                           FROM pc_decision, tmp_work_ids
                          WHERE     pd_ap = x_id
                                AND pd_st NOT IN ('PS', 'S', 'P'));

        --Видаляємо існуючі деталі розрахунку рішення
        DELETE FROM pd_detail
              WHERE pdd_pdp IN
                        (SELECT pdp_id
                           FROM pd_payment, pc_decision, tmp_work_ids
                          WHERE     pdp_pd = pd_id
                                AND pd_ap = x_id
                                AND pd_st NOT IN ('PS', 'S', 'P'));

        --Видаляємо існуючі розрахунки рішення
        DELETE FROM pd_payment
              WHERE pdp_pd IN
                        (SELECT pd_id
                           FROM pc_decision, tmp_work_ids
                          WHERE     pd_ap = x_id
                                AND pd_st NOT IN ('PS', 'S', 'P'));

        --Розрахунку доходу
        --Видаляємо лог попереднього розрахунку доходу
        DELETE FROM pd_income_log
              WHERE pil_pid IN
                        (SELECT pid_id
                           FROM pd_income_detail
                                JOIN pd_income_calc ON pid_pic = pic_id
                                JOIN pc_decision ON pic_pd = pd_id
                                JOIN tmp_work_ids ON pd_ap = x_id
                                JOIN pd_income_session ON pin_id = pic_pin
                          WHERE     pd_st NOT IN ('PS', 'S', 'P')
                                AND pin_st = 'E'
                                AND pin_tp = 'FST');

        --Видаляємо детальний розрахунок доходу
        DELETE FROM pd_income_detail
              WHERE pid_pic IN
                        (SELECT pic_id
                           FROM pd_income_calc
                                JOIN pc_decision ON pic_pd = pd_id
                                JOIN tmp_work_ids ON pd_ap = x_id
                                JOIN pd_income_session ON pin_id = pic_pin
                          WHERE     pd_st NOT IN ('PS', 'S', 'P')
                                AND pin_st = 'E'
                                AND pin_tp = 'FST');

        --Видаляємо розрахунок доходу
        DELETE FROM pd_income_calc
              WHERE pic_pd IN
                        (SELECT pd_id
                           FROM pc_decision
                                JOIN tmp_work_ids ON pd_ap = x_id
                                JOIN pd_income_session ON pin_id = pic_pin
                          WHERE     pd_st NOT IN ('PS', 'S', 'P')
                                AND pin_st = 'E'
                                AND pin_tp = 'FST');

        /*

                AND EXISTS (SELECT 1
                            FROM pd_income_session
                            WHERE pin_id = pis_pin
                              AND pin_st = 'E'
                              AND pin_tp = 'FST' )
                              ;

        */



        UPDATE pc_decision p
           SET p.pd_st = 'R0',
               p.pd_src =
                   (CASE
                        WHEN (SELECT COUNT (*)
                                FROM pc_decision pd1
                               WHERE pd1.pd_pa = p.pd_pa AND pd1.pd_st = 'S') >
                             0 --Якщо вже є нараховані рішення - то це повторне призначення
                        THEN
                            'PV'
                        ELSE
                            'FS' --нарахованих зверненнь - немає, отже - це первинне призначення
                    END)
         WHERE     p.pd_st IN ('W', 'E')
               AND EXISTS
                       (SELECT 1
                          FROM tmp_work_ids
                         WHERE pd_ap = x_id);

        UPDATE pc_decision pd
           SET pd.pd_start_dt = NULL, pd.pd_stop_dt = NULL
         WHERE     pd.pd_st = 'R0'
               AND pd.pd_src != 'SA'
               AND EXISTS
                       (SELECT 1
                          FROM tmp_work_ids
                               JOIN appeal ON ap_id = x_id
                               JOIN pc_decision p ON p.pd_ap = ap_id
                         WHERE     p.pd_id = pd.pd_id
                               AND ap_pc IS NOT NULL
                               AND ap_tp IN ('V', 'SS'));


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
        DBMS_OUTPUT.put_line ('Проставляємо номери рішень');

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

            l_num := API$PC_DECISION.gen_pd_num (xx.pc_id);

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
                              WHERE pd_ap = x_id AND pis_pd = pd_id)
                    AND EXISTS
                            (SELECT 1
                               FROM pd_income_session
                              WHERE     pin_id = pis_pin
                                    AND pin_st = 'E'
                                    AND pin_tp = 'FST');

        /*
            INSERT INTO pd_income_session (pin_id, pin_pd, pin_tp, pin_hs_ins, pin_st)
            VALUES (0, pd_id, 'FST', l_hs, 'E')
        */

        MERGE INTO pd_income_session
             USING (SELECT pin_id     AS x_pin_id,
                           pd_id      AS x_pin_pd,
                           'FST'      AS x_pin_tp,
                           l_hs       AS x_pin_hs_ins,
                           pin_st     AS x_pin_st
                      FROM tmp_work_ids
                           JOIN pc_decision ON pd_ap = x_id
                           LEFT JOIN pd_income_session
                               ON     pin_pd = pd_id
                                  AND pin_tp = 'FST'
                                  AND pin_st = 'E')
                ON (pin_id = x_pin_id)
        --WHEN MATCHED THEN
        WHEN NOT MATCHED
        THEN
            INSERT     (pin_id,
                        pin_pd,
                        pin_tp,
                        pin_hs_ins,
                        pin_st)
                VALUES (0,
                        x_pin_pd,
                        x_pin_tp,
                        x_pin_hs_ins,
                        'E');

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
                                   pis_exch_tp,
                                   pis_tax_sum,
                                   pis_use_tp,
                                   pis_pin)
            SELECT DISTINCT
                   0,
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
                   NULL,
                   NULL,
                   'STO',
                   (SELECT MAX (pin_id)
                      FROM pd_income_session
                     WHERE pin_pd = pd_id AND pin_tp = 'FST' AND pin_st = 'E')
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
            SELECT DISTINCT
                   0,
                   api_src,
                   api_tp,
                   api_edrpou,
                   api_sum,
                     api_sum
                   - CASE
                         WHEN api_src = 'DPS' AND api_exch_tp = '101'
                         THEN
                             api_tax_sum
                         ELSE
                             0
                     END,
                   app_sc,
                   DECODE (api_esv_paid,  '0', 'F',  '1', 'T',  'F'),
                   DECODE (api_esv_min,  '0', 'F',  '1', 'T',  'F'),
                   NVL (api_start_dt, api_month),
                   NVL (api_stop_dt, LAST_DAY (api_month)),
                   pd_id,
                   app_id,
                   'F',
                   api_exch_tp,
                   api_tax_sum,
                   'STO',
                   (SELECT MAX (pin_id)
                      FROM pd_income_session
                     WHERE pin_pd = pd_id AND pin_tp = 'FST' AND pin_st = 'E')
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
                                   pis_exch_tp,
                                   pis_use_tp,
                                   pis_pin)
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
                   pis_exch_tp,
                   pis_use_tp,
                   (SELECT MAX (pin_id)
                      FROM pd_income_session
                     WHERE     pin_pd = dest.pd_id
                           AND pin_tp = 'FST'
                           AND pin_st = 'E')
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

        -- #86901
        -- При створенні рішення по зверненню V зберігати адреси реєстрації та проживання, використовуючи процедуру Api$socialcard.Save_Sc_Address
        API$PC_DECISION_EXT.Save_Sc_Address;

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
    EXCEPTION
        WHEN OTHERS
        THEN
            BEGIN
                TOOLS.release_lock (l_lock_init);
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;

            RAISE;
    END;
--========================================================================--
BEGIN
    NULL;
END API$PD_INIT;
/