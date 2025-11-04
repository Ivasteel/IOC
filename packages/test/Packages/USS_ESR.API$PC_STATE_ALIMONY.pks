/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$PC_STATE_ALIMONY
IS
    -- Author  : VANO
    -- Created : 08.12.2021 11:09:20
    -- Purpose : Функції роботи з держутриманнями

    g_write_messages_to_output   INTEGER := 0;

    PROCEDURE write_ps_log (p_psl_ps        ps_log.psl_ps%TYPE,
                            p_psl_hs        ps_log.psl_hs%TYPE,
                            p_psl_st        ps_log.psl_st%TYPE,
                            p_psl_message   ps_log.psl_message%TYPE,
                            p_psl_st_old    ps_log.psl_st_old%TYPE,
                            p_psl_tp        ps_log.psl_tp%TYPE:= 'SYS');

    PROCEDURE init_pc_state_alimony_by_appeals (
        p_mode           INTEGER,      --1=з p_ap_id, 2=з таблиці tmp_work_ids
        p_ap_id          appeal.ap_id%TYPE,
        p_messages   OUT SYS_REFCURSOR);

    --Вичищення всіх даних по зверненню держутримання
    PROCEDURE return_ps (p_ap_id appeal.ap_id%TYPE);

    --======================================================--
    --  Отримання текстового параметру документу по зверненню
    --======================================================--
    FUNCTION get_doc_string (p_ap        ap_document.apd_ap%TYPE,
                             p_ndt       ap_document.apd_ndt%TYPE,
                             p_nda       ap_document_attr.apda_nda%TYPE,
                             p_default   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;

    --======================================================--
    --  Перевірити стан держутримання --#74595  2022.01.26
    --======================================================--
    PROCEDURE Check_state_alimony_for_aprove (
        p_ap_reason   pc_decision.pd_ap_reason%TYPE,
        p_old_pd_st   pc_decision.pd_st%TYPE);

    PROCEDURE Check_state_alimony_for_reject (
        p_ap_reason   pc_decision.pd_ap_reason%TYPE,
        p_old_pd_st   pc_decision.pd_st%TYPE);

    --======================================================--
    --  Продвинути стан держутримання
    --======================================================--
    PROCEDURE approve_state_alimony (p_ps_id pc_state_alimony.ps_id%TYPE);

    --======================================================--
    --  Повернути стан держутримання на попереднью позицію
    --======================================================--
    PROCEDURE reject_state_alimony (p_ps_id       pc_state_alimony.ps_id%TYPE,
                                    p_reason   IN VARCHAR2 := NULL);

    --Переведення держутримання в стан "Припинено перебування" з "Діючий"
    PROCEDURE close_state_alimony (p_ps_id pc_state_alimony.ps_id%TYPE);

    --Переведення держутримання в стан "Діючий" з "Припинено перебування"
    PROCEDURE reopen_state_alimony (p_ps_id pc_state_alimony.ps_id%TYPE);

    --Видалення держутримання та відповідного відрахування у випадку переведення рішення про призначення в стан Відхилено
    PROCEDURE clean_ps_by_ap_reject_pd (p_ap_id appeal.ap_id%TYPE);

    --Перевірка інсторії держутримання на коректність
    PROCEDURE check_ps_hist (p_ps_id pc_state_alimony.ps_id%TYPE);
END API$PC_STATE_ALIMONY;
/


/* Formatted on 8/12/2025 5:49:10 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$PC_STATE_ALIMONY
IS
    PROCEDURE write_ps_log (p_psl_ps        ps_log.psl_ps%TYPE,
                            p_psl_hs        ps_log.psl_hs%TYPE,
                            p_psl_st        ps_log.psl_st%TYPE,
                            p_psl_message   ps_log.psl_message%TYPE,
                            p_psl_st_old    ps_log.psl_st_old%TYPE,
                            p_psl_tp        ps_log.psl_tp%TYPE:= 'SYS')
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        --l_hs := NVL(p_psl_hs, TOOLS.GetHistSession);
        l_hs := p_psl_hs;

        IF l_hs IS NULL
        THEN
            l_hs := TOOLS.GetHistSession;
        END IF;

        INSERT INTO ps_log (psl_id,
                            psl_ps,
                            psl_hs,
                            psl_st,
                            psl_message,
                            psl_st_old,
                            psl_tp)
             VALUES (0,
                     p_psl_ps,
                     l_hs,
                     p_psl_st,
                     p_psl_message,
                     p_psl_st_old,
                     NVL (p_psl_tp, 'SYS'));
    END;

    PROCEDURE debug_write_1 (p_table_name VARCHAR2)
    IS
    BEGIN
        IF g_write_messages_to_output = 1
        THEN
            EXECUTE IMMEDIATE   'begin BLD$IMPEXP.debug_table_data(''USS_ESR'', '''
                             || p_table_name
                             || ''', ''where 1 = 1'', ''TAB''); end;';
        END IF;
    END;

    PROCEDURE check_ps_hist (p_ps_id pc_state_alimony.ps_id%TYPE)
    IS
        l_cnt   INTEGER;
        l_msg   VARCHAR2 (500);
    BEGIN
        WITH
            dnh
            AS
                (SELECT DISTINCT psc_start_dt     AS x_dt
                   FROM uss_esr.ps_changes
                  WHERE history_status = 'A' AND psc_ps = p_ps_id)
        SELECT COUNT (*),
               LISTAGG (TO_CHAR (x_dt, 'DD.MM.YYYY'), ',')
                   WITHIN GROUP (ORDER BY x_dt)
          INTO l_cnt, l_msg
          FROM dnh
         WHERE 1 <
               (SELECT COUNT (*)
                  FROM uss_esr.ps_changes
                 WHERE     psc_ps = p_ps_id
                       AND history_status = 'A'
                       AND x_dt >= psc_start_dt
                       AND (x_dt <= psc_stop_dt OR psc_stop_dt IS NULL));

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                   'Помилка маніпуляцій з історією держутримання! В результаті змін виявлено дублікати або перетини історії на дати <'
                || l_msg
                || '>. dn='
                || p_ps_id);
        END IF;
    END;

    PROCEDURE init_pc_state_alimony_by_appeals (
        p_mode           INTEGER,      --1=з p_ap_id, 2=з таблиці tmp_work_ids
        p_ap_id          appeal.ap_id%TYPE,
        p_messages   OUT SYS_REFCURSOR)
    IS
        l_com_org     pc_decision.com_org%TYPE;
        l_com_wu      pc_decision.com_wu%TYPE;
        l_lock_init   TOOLS.t_lockhandler;
        l_cnt         INTEGER;
        g_messages    TOOLS.t_messages := TOOLS.t_messages ();
        l_hs          histsession.hs_id%TYPE;
    BEGIN
        l_com_org := TOOLS.GetCurrOrg;
        l_com_wu := TOOLS.GetCurrWu;
        l_lock_init :=
            TOOLS.request_lock (
                p_descr   => 'INIT_PC_STATE_ALIMONY_' || p_ap_id,
                p_error_msg   =>
                       'В даний момент вже виконується створення держутримання по зверненню '
                    || p_ap_id
                    || '!');

        IF l_com_org IS NULL
        THEN
            raise_application_error (-20000,
                                     'Не можу визначити орган призначення!');
        END IF;

        IF l_com_wu IS NULL
        THEN
            raise_application_error (-20000,
                                     'Не можу визначити користувача!');
        END IF;

        IF p_mode = 1 AND p_ap_id IS NOT NULL
        THEN
            DELETE FROM tmp_work_ids
                  WHERE 1 = 1;

            INSERT INTO tmp_work_ids (x_id)
                SELECT ap_id
                  FROM v_appeal
                 WHERE     ap_id = p_ap_id
                       AND ap_st IN ('O')
                       AND (   ap_tp IN ('U')    --Звернення держутримання або
                            OR (    ap_tp = 'V'        --Звернення по допомогу
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

            l_cnt := SQL%ROWCOUNT;
        ELSE
            SELECT COUNT (*)
              INTO l_cnt
              FROM tmp_work_ids, v_appeal
             WHERE     x_id = ap_id
                   AND (   ap_tp IN ('U')        --Звернення держутримання або
                        OR (    ap_tp = 'V'            --Звернення по допомогу
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
                                            AND history_Status = 'A'))); --і наявністю довідки про зарахування;
        END IF;

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'В функцію формування держутримання не передано зверненнь!');
        END IF;

        SELECT COUNT (*)
          INTO l_cnt
          FROM tmp_work_pa_ids
         WHERE x_pa IS NOT NULL AND x_nst IN (1, 3, 248);

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'В функцію формування держутримання не передано особових рахунків, до яких треба застосовувати відрахування!');
        END IF;

        SELECT COUNT (*)
          INTO l_cnt
          FROM tmp_work_ids
         WHERE     EXISTS
                       (SELECT 1
                          FROM ap_service
                         WHERE     aps_ap = x_id
                               AND aps_nst IN (248, 620)
                               AND history_Status = 'A')
               AND 2 <>
                   (SELECT COUNT (DISTINCT apd_ndt)
                      FROM ap_document
                     WHERE     apd_ap = x_id
                           AND history_Status = 'A'
                           AND apd_ndt IN (10033, 10034));

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                'В функцію формування держутримання передано звернення, в якому немає документів "Довідка про зарахування особи на повне державне утримання" та "Заява про перерахування коштів на банківський рахунок закладу держутримання"!');
        END IF;

        SELECT COUNT (*)
          INTO l_cnt
          FROM tmp_work_ids
         WHERE     EXISTS
                       (SELECT 1
                          FROM ap_service
                         WHERE     aps_ap = x_id
                               AND aps_nst IN (621)
                               AND history_Status = 'A')
               AND 1 <>
                   (SELECT COUNT (DISTINCT apd_ndt)
                      FROM ap_document
                     WHERE     apd_ap = x_id
                           AND history_Status = 'A'
                           AND apd_ndt IN (10035));

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                'В функцію формування держутримання передано звернення, в якому немає документу "Витяг/Копія наказу закладу держутримання про підстави припинення/поновлення відрахувань"!');
        END IF;

        TOOLS.add_message (g_messages,
                           'W',
                           'Розпочинаю формування держутримання!');

        l_hs := TOOLS.GetHistSession;

        DELETE FROM tmp_state_alimony
              WHERE 1 = 1;

        INSERT INTO tmp_state_alimony (xps_id,
                                       xps_pc,
                                       xps_rstart_dt,
                                       xps_first_dt,
                                       xps_first_action,
                                       xps_second_dt,
                                       xps_second_action,
                                       xps_ap,
                                       xps_sc,
                                       xps_st,
                                       xps_tp,
                                       xps_dpp,
                                       xps_dppa,
                                       xps_dn_out)
            WITH
                wrk_ids
                AS
                    (SELECT x_id                            AS x_ap,
                            (SELECT MIN (app_id)
                               FROM ap_person app, ap_document apd
                              WHERE     app_ap = x_id
                                    AND app.history_status = 'A'
                                    AND apd.history_status = 'A'
                                    AND apd_app = app_id
                                    AND apd_ndt = 10033)    AS x_app_10033
                       FROM tmp_work_ids)
            SELECT 0,
                   x_pc,
                   x_base_in,
                   tools.least2 (x_in_dt, x_out_dt),
                   CASE
                       WHEN x_in_dt = x_out_dt
                       THEN
                           'OUT'
                       WHEN tools.least2 (x_in_dt, x_out_dt) = x_in_dt
                       THEN
                           'IN'
                       WHEN tools.least2 (x_in_dt, x_out_dt) = x_out_dt
                       THEN
                           'OUT'
                   END, --якщо менша серед дат - прибуття, то перша подія - прибуття.--якщо менша серед дат - вибуття, то перша подія - вибуття. А може і пусто бути
                   CASE
                       WHEN x_in_dt IS NOT NULL AND x_out_dt IS NOT NULL
                       THEN
                           tools.greatest2 (x_in_dt, x_out_dt)
                   END,
                   CASE
                       WHEN x_in_dt = x_out_dt
                       THEN
                           'IN'
                       WHEN     x_in_dt IS NOT NULL
                            AND x_out_dt IS NOT NULL
                            AND tools.greatest2 (x_in_dt, x_out_dt) =
                                x_out_dt
                       THEN
                           'OUT'
                       WHEN     x_in_dt IS NOT NULL
                            AND x_out_dt IS NOT NULL
                            AND tools.greatest2 (x_in_dt, x_out_dt) = x_in_dt
                       THEN
                           'IN'
                   END, --якщо є (дата прибуття та дата вибуття) та дата прибуття більша за дату вибуття - другая подія - прибуття
                   x_ap,
                   x_sc,
                   x_st,
                   x_tp,
                   x_dpp,
                   NVL (
                       x_dppa,
                       (SELECT dppa_id
                          FROM uss_ndi.v_ndi_pay_person_acc
                         WHERE     dppa_dpp = x_dpp
                               AND history_status = 'A'
                               AND dppa_is_main IN ('T', '1'))),
                   CASE
                       WHEN x_tp = 'V' THEN x_out_dt
                       WHEN x_tp IN ('TR', 'UN', 'DE') THEN x_out_dt + 1
                       WHEN x_tp = 'HL' THEN LAST_DAY (x_out_dt) + 1
                   END
                       AS x_dn_out
              FROM (SELECT x_pc,
                           x_base_in,
                           x_in_dt,
                           x_out_dt,
                           x_ap,
                           x_sc,
                           x_st,
                           x_tp,
                           NVL (
                               (SELECT MAX (dppa_dpp)
                                  FROM uss_ndi.v_ndi_pay_person_acc dppa
                                 WHERE     dppa_id =
                                           NVL (
                                               API$APPEAL.Get_Doc_Id (
                                                   x_app_10033,
                                                   10033,
                                                   5362),
                                               (SELECT MAX (apm_dppa)
                                                  FROM tmp_work_ids,
                                                       ap_payment  apm
                                                 WHERE     apm_ap = x_ap
                                                       AND apm_tp = 'SA'
                                                       AND apm.history_status =
                                                           'A'))
                                       AND dppa.history_status = 'A'),
                               (SELECT MIN (dpp_id)
                                  FROM uss_ndi.v_ndi_pay_person dpp
                                 WHERE     dpp_tax_code =
                                           NVL (x_924_value, x_906_value)
                                       AND dpp.history_status = 'A'))
                               AS x_dpp,
                           NVL (
                               x_dppa,
                               NVL (
                                   NVL (
                                       API$APPEAL.Get_Doc_Id (x_app_10033,
                                                              10033,
                                                              5362),
                                       (SELECT MAX (apm_dppa)
                                          FROM tmp_work_ids, ap_payment apm
                                         WHERE     apm_ap = x_ap
                                               AND apm_tp = 'SA'
                                               AND apm.history_status = 'A')),
                                   (SELECT MIN (dppa_id)
                                      FROM uss_ndi.v_ndi_pay_person    dpp,
                                           uss_ndi.ndi_pay_person_acc  ac
                                     WHERE     dpp_tax_code =
                                               NVL (x_924_value, x_906_value)
                                           AND dppa_dpp = dpp_id
                                           AND ac.history_status = 'A'
                                           AND ac.dppa_is_main = '1'
                                           AND dpp.history_status = 'A')))
                               AS x_dppa
                      FROM (SELECT ap_pc
                                       AS x_pc,
                                   API$APPEAL.get_doc_dt (app_id, 10034, 923)
                                       AS x_base_in,
                                   API$APPEAL.get_doc_dt (app_id, 10035, 908)
                                       AS x_in_dt,
                                   API$APPEAL.get_doc_dt (app_id, 10035, 907)
                                       AS x_out_dt,
                                   ap_id
                                       AS x_ap,
                                   app_sc
                                       AS x_sc,
                                   DECODE (aps_nst,
                                           248, 'IN',
                                           620, 'IN',
                                           621, 'OUT')
                                       AS x_st,
                                   API$APPEAL.get_doc_string (app_id,
                                                              10035,
                                                              909)
                                       AS x_tp,
                                   API$APPEAL.Get_Doc_Id (x_app_10033,
                                                          10033,
                                                          5362)
                                       AS x_5362_value,
                                   API$APPEAL.get_doc_string (app_id,
                                                              10034,
                                                              924)
                                       AS x_924_value,
                                   API$APPEAL.get_doc_string (app_id,
                                                              10035,
                                                              906)
                                       AS x_906_value,
                                   NVL (
                                       API$APPEAL.Get_Doc_Id (x_app_10033,
                                                              10033,
                                                              5362),
                                       (SELECT apm_dppa
                                          FROM tmp_work_ids, ap_payment apm
                                         WHERE     apm_ap = ap_id
                                               AND apm_tp = 'SA'
                                               AND apm.history_status = 'A'))
                                       AS x_dppa,
                                   x_app_10033
                              FROM wrk_ids,
                                   appeal,
                                   ap_service  s,
                                   ap_person   p
                             WHERE     ap_id = x_ap
                                   AND (   ap_tp IN ('U') --Звернення держутримання або
                                        OR (    ap_tp = 'V' --Звернення по допомогу
                                            AND EXISTS
                                                    (SELECT 1
                                                       FROM ap_service dx
                                                      WHERE     dx.aps_ap =
                                                                ap_id
                                                            AND dx.aps_nst =
                                                                248
                                                            AND dx.history_Status =
                                                                'A') --з послугою "особам з інвалідністю
                                            AND EXISTS
                                                    (SELECT 1
                                                       FROM ap_document apd
                                                      WHERE     apd.apd_ap =
                                                                ap_id
                                                            AND apd.apd_app =
                                                                app_id
                                                            AND apd.apd_ndt IN
                                                                    (10034,
                                                                     10035)
                                                            AND apd.history_Status =
                                                                'A'))) --і наявністю довідки про зарахування
                                   AND ap_pc IS NOT NULL
                                   AND aps_ap = ap_id
                                   AND aps_nst IN (620, 621, 248)
                                   AND app_ap = ap_id
                                   AND p.history_status = 'A'
                                   AND s.history_status = 'A'
                                   AND app_tp NOT IN ('P')
                                   AND (   (    app_tp = 'DU'
                                            AND EXISTS
                                                    (SELECT 1
                                                       FROM ap_document  d,
                                                            ap_document_attr
                                                            da
                                                      WHERE     apd_app =
                                                                app_id
                                                            AND apda_apd =
                                                                apd_id
                                                            AND apd_ndt =
                                                                10037
                                                            AND (   (    apda_nda =
                                                                         929
                                                                     AND apda_val_string =
                                                                         'T') --Дитина з інвалідністю
                                                                 OR (    apda_nda =
                                                                         930
                                                                     AND apda_val_string =
                                                                         'T')) --Особа з інвалідністю з дитинства
                                                            AND d.history_status =
                                                                'A'
                                                            AND da.history_status =
                                                                'A'))
                                        OR EXISTS
                                               (SELECT 1
                                                  FROM ap_document apd
                                                 WHERE     apd.apd_ap = ap_id
                                                       AND apd.apd_app =
                                                           app_id
                                                       AND apd.apd_ndt IN
                                                               (10034, 10035)
                                                       AND apd.history_Status =
                                                           'A'))));

        IF SQL%ROWCOUNT = 0
        THEN
            raise_application_error (
                -20000,
                'В функцію формування держутримання не передано зверненнь, в якому був би 1 учасник, або учасник типу DU та з ознакою "Дитина з інвалідністю" або "Особа з інвалідністю з дитинства"!');
        END IF;

        SELECT COUNT (*)
          INTO l_cnt
          FROM tmp_state_alimony
         WHERE xps_dpp IS NULL;

        TOOLS.raise_exception (
            l_cnt,
            'Не вдалось обрахувати заклад держутримання за параметрами документів звернення!');

        SELECT COUNT (*)
          INTO l_cnt
          FROM tmp_state_alimony
         WHERE xps_dppa IS NULL;

        TOOLS.raise_exception (
            l_cnt,
            'Не вдалось визначити рахунок закладу держутримання за параметрами документів звернення!');

        --Знаходимо ті, по яким не визначився Заклад Держутримання
        UPDATE tmp_state_alimony
           SET xps_action = 'E_DPP'
         WHERE xps_dpp IS NULL;

        --Знаходимо ті, що повернуті з довведення
        UPDATE tmp_state_alimony
           SET xps_action = 'U_FULL',
               xps_id =
                   (SELECT ps_id
                      FROM pc_state_alimony
                     WHERE xps_ap = ps_ap)
         WHERE EXISTS
                   (SELECT 1
                      FROM pc_state_alimony
                     WHERE xps_ap = ps_ap AND ps_st = 'W');

        UPDATE tmp_state_alimony
           SET xps_action = 'U_ERR_DT'
         WHERE     xps_first_dt IS NULL
               AND xps_second_dt IS NULL
               AND xps_rstart_dt IS NULL;

        IF SQL%ROWCOUNT > 0
        THEN
            raise_application_error (
                -20000,
                'Зі звернення не вичитано жодних дати прибуття/вибуття!');
        END IF;

        UPDATE tmp_state_alimony
           SET xps_action = 'U_ERR_ORD'
         WHERE     xps_first_dt IS NOT NULL
               --AND xps_second_dt IS NOT NULL
               AND xps_rstart_dt IS NOT NULL
               AND xps_first_action = 'IN';

        debug_write_1 ('tmp_state_alimony');

        IF SQL%ROWCOUNT > 0
        THEN
            raise_application_error (
                -20000,
                'У зверенні вказано повторне прибуття особи в заклад держутримання!');
        END IF;

        UPDATE tmp_state_alimony
           SET xps_action = 'U_ERR_ORD'
         WHERE     xps_first_dt IS NOT NULL
               --AND xps_second_dt IS NOT NULL
               AND xps_rstart_dt IS NOT NULL
               AND xps_first_action = 'IN';

        IF SQL%ROWCOUNT > 0
        THEN
            raise_application_error (
                -20000,
                'У зверенні вказано повторне прибуття особи в заклад держутримання!');
        END IF;

        --Знаходимо ті, що намагаються ініціалізувати тим же зверненням повторно і Держутримання не в статусі "Очікується довведення".
        UPDATE tmp_state_alimony
           SET xps_action = 'E_DUP',
               xps_id =
                   (SELECT ps_id
                      FROM pc_state_alimony
                     WHERE xps_ap = ps_ap)
         WHERE EXISTS
                   (SELECT 1
                      FROM pc_state_alimony
                     WHERE xps_ap = ps_ap AND ps_st <> 'W');

        IF SQL%ROWCOUNT > 0
        THEN
            raise_application_error (
                -20000,
                'Спроба повторно ініціалізувати держутримання тим же зверненням!');
        END IF;

        UPDATE tmp_state_alimony
           SET xps_action = 'E_DUP_INIT'
         WHERE     xps_first_dt IS NULL
               AND xps_second_dt IS NULL
               AND xps_rstart_dt IS NOT NULL
               AND EXISTS
                       (SELECT 1
                          FROM pc_state_alimony
                         WHERE     ps_dpp = xps_dpp
                               AND ps_sc = xps_sc
                               AND ps_pc = xps_pc);

        IF SQL%ROWCOUNT > 0
        THEN
            raise_application_error (
                -20000,
                'Спроба обробити повторне звернення про прийняття до закладу держутримання!');
        END IF;

        --Знаходимо ті, по яким іде спроба прийняти на дерутримання, коли особа ще на Держутриманні в іншому закладі.
        UPDATE tmp_state_alimony
           SET xps_action = 'E_ELSE1'
         WHERE EXISTS
                   (SELECT 1
                      FROM pc_state_alimony, ps_changes
                     WHERE     xps_sc = ps_sc
                           AND psc_ps = ps_id
                           AND history_status = 'A'
                           AND xps_dpp <> ps_dpp
                           AND (   (    xps_first_dt >= psc_start_dt
                                    AND (   xps_first_dt <= psc_stop_dt
                                         OR psc_start_dt IS NULL)
                                    AND xps_first_action = 'IN') --прибуваэмо першою подією
                                OR (    xps_second_dt >= psc_start_dt
                                    AND (   xps_second_dt <= psc_stop_dt
                                         OR psc_start_dt IS NULL)
                                    AND xps_second_action = 'IN') --прибуваэмо другою подією
                                OR (    xps_rstart_dt >= psc_start_dt
                                    AND (   xps_rstart_dt <= psc_stop_dt
                                         OR psc_start_dt IS NULL))) --прибуваэмо первинним зверненням
                           AND psc_st = 'IN');

        IF SQL%ROWCOUNT > 0
        THEN
            raise_application_error (
                -20000,
                'Спроба прийняти на держутримання особу, яка знаходиться на держутримання в іншому закладі!');
        END IF;

        --Знаходимо ті, по яким іде спроба виїхати з дерутримання, коли особа НЕ на Держутриманні в закладі зі звернення.
        UPDATE tmp_state_alimony
           SET xps_action = 'E_ELSE2'
         WHERE     EXISTS
                       (SELECT 1
                          FROM pc_state_alimony
                         WHERE ps_sc = xps_sc AND ps_dpp = xps_dpp)
               AND xps_first_action = 'OUT'          --вибуваємо першою подією
               AND NOT EXISTS
                       (SELECT 1
                          FROM pc_state_alimony, ps_changes
                         WHERE     xps_sc = ps_sc
                               AND psc_ps = ps_id
                               AND history_status = 'A'
                               AND xps_dpp = ps_dpp
                               AND xps_first_dt >= psc_start_dt
                               AND (   xps_first_dt <= psc_stop_dt
                                    OR psc_stop_dt IS NULL)
                               AND psc_st = 'IN');

        IF SQL%ROWCOUNT > 0
        THEN
            raise_application_error (
                -20000,
                'Спроба зняти з держутримання особу, яка НЕ знаходиться на держутримання в закладі зі звернення!');
        END IF;

        --Знаходимо ті, по яким іде спроба прибуття на дерутримання, коли особа ще перебуває в закладі, в який колись потрапила на Держутримання
        UPDATE tmp_state_alimony
           SET xps_action = 'E_ELSE3'
         WHERE     xps_action IS NULL
               AND EXISTS
                       (SELECT 1
                          FROM pc_state_alimony
                         WHERE ps_sc = xps_sc AND ps_dpp = xps_dpp)
               AND xps_first_action = 'IN'          --прибуваємо першою подією
               AND NOT EXISTS
                       (SELECT 1
                          FROM pc_state_alimony, ps_changes
                         WHERE     xps_sc = ps_sc
                               AND psc_ps = ps_id
                               AND history_status = 'A'
                               AND xps_dpp = ps_dpp
                               AND xps_first_dt >= psc_start_dt
                               AND (   xps_first_dt <= psc_stop_dt
                                    OR psc_stop_dt IS NULL)
                               AND psc_st = 'OUT');

        --return;
        IF SQL%ROWCOUNT > 0
        THEN
            raise_application_error (
                -20000,
                'Спроба прийняти на держутримання особу, щодо якої немає запису щодо вибуття!');
        END IF;

        UPDATE tmp_state_alimony
           SET xps_action = 'C_NOT_NEW'
         WHERE     xps_rstart_dt IS NULL
               AND NOT EXISTS
                       (SELECT 1
                          FROM pc_state_alimony
                         WHERE ps_sc = xps_sc AND ps_dpp = xps_dpp);

        IF SQL%ROWCOUNT > 0
        THEN
            raise_application_error (
                -20000,
                'Спроба обробити прибуття/вибуття особи в заклад держутримання, в який особу не приймали!');
        END IF;

        --Знаходимо ті, які потребують лише зміни стану в ps_change, бо дата зміни по зверненню - в періоді дії держутримання
        UPDATE tmp_state_alimony
           SET xps_action = 'U_STATE',
               xps_id =
                   (SELECT ps_id
                      FROM pc_state_alimony
                     WHERE     xps_sc = ps_sc
                           AND xps_dpp = ps_dpp
                           AND (   xps_first_dt >= ps_start_dt
                                OR xps_first_dt >= ps_start_dt)
                           AND ps_stop_dt IS NULL)
         WHERE EXISTS
                   (SELECT 1
                      FROM pc_state_alimony
                     WHERE     xps_sc = ps_sc
                           AND xps_dpp = ps_dpp
                           AND (   xps_first_dt >= ps_start_dt
                                OR xps_second_dt >= ps_start_dt)
                           AND ps_stop_dt IS NULL);

        UPDATE tmp_state_alimony
           SET xps_dppa =
                   (SELECT psc_dppa
                      FROM ps_changes y
                     WHERE     psc_ps = xps_id
                           AND history_status = 'A'
                           AND psc_start_dt =
                               (SELECT MAX (x.psc_start_dt)
                                  FROM ps_changes x
                                 WHERE     x.psc_ps = xps_id
                                       AND x.history_status = 'A'))
         WHERE xps_action = 'U_STATE' AND xps_dppa IS NULL;


        --Всі інші - повністю нові Держутримання.
        UPDATE tmp_state_alimony
           SET xps_action = 'C_NEW'
         WHERE xps_action IS NULL;

        UPDATE tmp_state_alimony
           SET xps_action = 'C_PD_NOT_F'
         WHERE     xps_action IN ('C_NEW', 'U_STATE')
               AND NOT EXISTS
                       (SELECT 1
                          FROM pc_decision, tmp_work_pa_ids
                         WHERE     pd_pc = xps_pc
                               AND pd_st = 'S'
                               AND pd_nst = 248
                               AND pd_pa = x_pa
                               AND x_nst = 1)
               AND EXISTS
                       (SELECT 1
                          FROM appeal
                         WHERE xps_ap = ap_id AND ap_tp = 'U');

        IF SQL%ROWCOUNT > 0
        THEN
            raise_application_error (
                -20000,
                'Не знайдено рішення в стані Нараховано по ОР типу послуги "Державна соціальна допомога особам з інвалідністю з дитинства та дітям з інвалідністю"!');
        END IF;

        --Дублікат - треба щось робити з вже існуючим держутриманням.
        UPDATE tmp_state_alimony
           SET xps_action = 'E_DUP'
         WHERE     xps_action = 'C_NEW'
               AND EXISTS
                       (SELECT 1
                          FROM pc_state_alimony
                         WHERE ps_sc = xps_sc AND ps_dpp = xps_dpp);

        IF SQL%ROWCOUNT > 0
        THEN
            raise_application_error (
                -20000,
                'В системі вже наявне держутримання по цій особі у вказаному закладі!');
        END IF;

        --Дублікат - треба щось робити з вже існуючим держутриманням.
        UPDATE tmp_state_alimony
           SET xps_action = 'E_NOT_R'
         WHERE     xps_action = 'U_STATE'
               AND EXISTS
                       (SELECT 1
                          FROM ap_service
                         WHERE     aps_ap = xps_ap
                               AND history_Status = 'A'
                               AND aps_nst = 621)
               AND NOT EXISTS
                       (SELECT 1
                          FROM pc_state_alimony
                         WHERE     ps_sc = xps_sc
                               AND ps_dpp = xps_dpp
                               AND ps_st = 'R');

        IF SQL%ROWCOUNT > 0
        THEN
            raise_application_error (
                -20000,
                'Не можна виконувати дії з припинення перебування в закладі, якщо запис держутримання не в стані "Діючий"!');
        END IF;

        UPDATE tmp_state_alimony
           SET xps_id = id_ps_changes (0)
         WHERE xps_action = 'C_NEW';

        --Створюємо нові держутримання
        INSERT INTO pc_state_alimony (ps_id,
                                      ps_pc,
                                      ps_start_dt,
                                      ps_stop_dt,
                                      ps_ap,
                                      ps_hs_ins,
                                      ps_st,
                                      ps_dpp,
                                      ps_sc)
            SELECT xps_id,
                   xps_pc,
                   xps_rstart_dt,
                   NULL,
                   xps_ap,
                   l_hs,
                   'P',
                   xps_dpp,
                   xps_sc
              FROM tmp_state_alimony
             WHERE xps_action = 'C_NEW';

        INSERT INTO ps_changes (psc_id,
                                psc_ps,
                                psc_ap,
                                psc_start_dt,
                                psc_stop_dt,
                                history_status,
                                psc_st,
                                psc_hs_ins,
                                psc_hs_del,
                                psc_dppa,
                                psc_tp)
            SELECT 0,
                   xps_id,
                   xps_ap,
                   xps_rstart_dt,
                   NULL,
                   'A',
                   xps_st,
                   l_hs,
                   NULL,
                   xps_dppa,
                   NULL
              FROM tmp_state_alimony
             WHERE xps_action = 'C_NEW';

        api$hist.init_work;

        --По записам оновлення стану - створуємо потрібні записи історії
        INSERT INTO tmp_unh_old_list (ol_obj,
                                      ol_hst,
                                      ol_begin,
                                      ol_end)
            SELECT psc_ps,
                   psc_id,
                   psc_start_dt,
                   psc_stop_dt
              FROM ps_changes, tmp_state_alimony
             WHERE     psc_ps = xps_id
                   AND xps_action = 'U_STATE'
                   AND history_status = 'A';

        INSERT INTO tmp_unh_work_list (work_obj,
                                       work_hst,
                                       work_begin,
                                       work_end)
            SELECT xps_id,
                   0,
                   xps_first_dt,
                   xps_second_dt --CASE WHEN xps_second_action = 'OUT' THEN xps_second_dt ELSE xps_second_dt - 1 END--прибув/вибув + вибув/прибув
              FROM tmp_state_alimony
             WHERE xps_action = 'U_STATE' AND xps_first_dt IS NOT NULL /*
                                         UNION ALL
                                         SELECT xps_id, 0, xps_second_dt, (SELECT MIN(ol_begin) - 1 FROM tmp_unh_old_list WHERE ol_begin >= xps_second_dt)  --прибув/вибув другою подією
                                         FROM tmp_state_alimony
                                         WHERE xps_action = 'U_STATE'
                                           AND xps_second_dt IS NOT NULL*/
                                                                      ;

        api$hist.setup_history (2,
                                NULL,
                                NULL,
                                NULL);

        --return;
        -- закриття записів, які видаляються
        UPDATE ps_changes
           SET history_status = 'H', psc_hs_del = l_hs
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_unh_to_prp
                     WHERE tprp_hst = psc_id);

        -- додавання нових періодів
        INSERT INTO ps_changes (psc_id,
                                psc_ps,
                                psc_ap,
                                psc_start_dt,
                                psc_stop_dt,
                                history_status,
                                psc_st,
                                psc_hs_ins,
                                psc_hs_del,
                                psc_dppa,
                                psc_tp)
            SELECT 0,
                   psc_ps,
                   psc_ap,
                   rz.rz_begin,
                   rz.rz_end,
                   'A',
                   psc_st,
                   l_hs,
                   NULL,
                   psc_dppa,
                   psc_tp
              FROM tmp_unh_rz_list rz, ps_changes
             WHERE     rz_hst <> 0
                   AND (rz_begin <= rz_end OR rz_end IS NULL)
                   AND psc_id = rz_hst
            UNION ALL
            SELECT 0,
                   xps_id,
                   xps_ap,
                   rz_begin,
                   rz_end,
                   'A',
                   CASE
                       WHEN rz_begin = xps_first_dt THEN xps_first_action
                       ELSE xps_second_action
                   END,
                   l_hs,
                   NULL,
                   xps_dppa,
                   CASE WHEN rz_begin = xps_first_dt THEN xps_tp END
              FROM tmp_unh_rz_list, tmp_state_alimony
             WHERE     rz_hst = 0
                   AND (rz_begin <= rz_end OR rz_end IS NULL)
                   AND rz_obj = xps_id;

        --Проставляємо дату вибуття по держутриманню (і закриття держутримання), якщо людина вибула з причини "Смерть".
        UPDATE pc_state_alimony
           SET ps_stop_dt =
                   (SELECT MAX (psc_start_dt)
                      FROM ps_changes psc
                     WHERE     psc_ps = ps_id
                           AND psc.history_status = 'A'
                           AND psc_st = 'OUT'
                           AND psc_tp IN ('DE'))
         WHERE     EXISTS
                       (SELECT 1
                          FROM ps_changes psc
                         WHERE     psc_ps = ps_id
                               AND psc.history_status = 'A'
                               AND psc_st = 'OUT'
                               AND psc_tp IN ('DE'))
               AND EXISTS
                       (SELECT 1
                          FROM tmp_state_alimony
                         WHERE     xps_action IN ('U_STATE', 'C_NEW')
                               AND xps_id = ps_id);

        --Перевіряємо, чи коректно змінили історію по держутриманню
        FOR xx IN (SELECT DISTINCT xps_id
                     FROM tmp_state_alimony
                    WHERE xps_action IN ('U_STATE', 'C_NEW'))
        LOOP
            check_ps_hist (xx.xps_id);
        END LOOP;

        --Пишемо протокол обробки
        FOR xx IN (SELECT xps_id, xps_action
                     FROM tmp_state_alimony
                    WHERE xps_action IN ('U_STATE', 'C_NEW'))
        LOOP
            write_ps_log (
                xx.xps_id,
                NULL,
                'P',
                   CHR (38)
                || CASE
                       WHEN xx.xps_action IN ('U_STATE') THEN '45'
                       ELSE '43'
                   END,
                NULL,
                'SYS');
        END LOOP;

        --Формуємо множину даних для зміни (або просто реєстрації) відрахувань
        DELETE FROM tmp_work_ids_dn
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids_dn (x_id,
                                     x_start_dt,
                                     x_stop_dt,
                                     x_action,
                                     x_psc)
            SELECT xps_id, --DECODE(xps_action, 'C_NEW', xps_rstart_dt, 'U_STATE', DECODE(psc_start_dt, xps_first_dt, xps_first_dt, xps_second_dt)),
                   CASE
                       WHEN xps_action = 'C_NEW'
                       THEN
                           ADD_MONTHS (TRUNC (xps_rstart_dt, 'MM'), 1)
                       WHEN     xps_action = 'U_STATE'
                            AND xps_first_action = 'IN'
                       THEN
                           xps_first_dt + 1
                       WHEN     xps_action = 'U_STATE'
                            AND xps_first_action = 'OUT'
                            AND xps_tp = 'V'
                            AND psc_st = 'OUT'
                       THEN
                           xps_first_dt
                       WHEN     xps_action = 'U_STATE'
                            AND xps_first_action = 'OUT'
                            AND xps_tp = 'V'
                            AND psc_st = 'IN'
                       THEN
                           xps_second_dt + 1
                       WHEN     xps_action = 'U_STATE'
                            AND xps_first_action = 'OUT'
                            AND psc_tp IN ('TR', 'UN', 'DE')
                       THEN
                           xps_first_dt + 1
                       WHEN     xps_action = 'U_STATE'
                            AND xps_first_action = 'OUT'
                            AND psc_tp IN ('HL')
                       THEN
                           LAST_DAY (xps_first_dt) + 1
                       WHEN     xps_action = 'U_STATE'
                            AND xps_second_action = 'IN'
                       THEN
                           xps_second_dt + 1
                   END,
                   --DECODE(xps_action, 'U_STATE', DECODE(psc_start_dt, xps_first_dt, xps_second_dt - 1)),
                   CASE
                       WHEN     xps_action = 'U_STATE'
                            AND xps_first_action = 'IN'
                            AND xps_second_action IS NOT NULL
                       THEN
                           xps_second_dt - 1
                       WHEN     xps_action = 'U_STATE'
                            AND psc_st = 'OUT'
                            AND xps_first_action = 'OUT'
                            AND xps_second_action IS NOT NULL
                       THEN
                           xps_second_dt
                       WHEN     xps_action = 'U_STATE'
                            AND psc_st = 'IN'
                            AND xps_first_action = 'OUT'
                            AND xps_second_action IS NOT NULL
                            AND psc_start_dt = xps_second_dt + 1
                       THEN
                           psc_stop_dt
                   END,
                   DECODE (
                       xps_action,
                       'C_NEW', 'IN_NEW',
                       'U_STATE', DECODE (psc_start_dt,
                                          xps_first_dt, xps_first_action,
                                          xps_second_action)),
                   psc_id
              FROM tmp_state_alimony, ps_changes
             WHERE     xps_action IN ('U_STATE', 'C_NEW')
                   AND psc_ps = xps_id
                   AND (   (    xps_action IN ('U_STATE')
                            AND psc_start_dt IN
                                    (xps_first_dt, xps_second_dt + 1)
                            AND NOT (    xps_first_action = 'OUT'
                                     AND psc_st = 'OUT'
                                     AND psc_start_dt = xps_second_dt + 1
                                     AND xps_second_dt IS NOT NULL)
                            AND NOT (    xps_first_action = 'IN'
                                     AND psc_st = 'IN'
                                     AND psc_start_dt = xps_second_dt + 1
                                     AND xps_second_dt IS NOT NULL))
                        OR (    xps_action IN ('C_NEW')
                            AND psc_start_dt = xps_rstart_dt))
                   AND history_Status = 'A';

        --  ikis_sysweb.ikis_debug_pipe.WriteMsg(SQL%ROWCOUNT);
        --RETURN;

        API$DEDUCTION.init_deduction_by_state_alimony (2,
                                                       NULL,
                                                       g_messages,
                                                       l_hs);

        --Переводимо звернення в стан 'WD' = Опрацювання рішення, якщо хоча б одне держутримання створене
        API$APPEAL.mark_appeal_working (2,
                                        3,
                                        NULL,
                                        l_cnt);

        IF l_cnt = 0
        THEN
            TOOLS.add_message (
                g_messages,
                'W',
                'Держутриманнь за зверненням не знайдено, стан звернення не змінено!');
        END IF;

        TOOLS.release_lock (l_lock_init);

        TOOLS.add_message (g_messages,
                           'W',
                           'Завершую формування держутримання!');

        --raise_application_error(-20000, 'x');

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

    --Вичищення всіх даних по зверненню держутримання
    PROCEDURE return_ps (p_ap_id appeal.ap_id%TYPE)
    IS
        l_appeal     appeal%ROWTYPE;
        --  l_cnt INTEGER;
        l_hs_prove   ps_changes.psc_hs_ins%TYPE;
        l_ps_cnt     INTEGER;
    BEGIN
        SELECT *
          INTO l_appeal
          FROM appeal
         WHERE ap_id = p_ap_id;

        IF l_appeal.ap_st <> 'P'
        THEN
            raise_application_error (
                -20000,
                'Спроба очистити/видалити дані по держутриманню для зверненнь не в статусі "повернуто на довведення"!');
        END IF;

        SELECT COUNT (*)
          INTO l_ps_cnt
          FROM pc_state_alimony, appeal, ap_service
         WHERE     ps_ap = ap_id
               AND ap_tp = 'V'
               AND aps_ap = ap_id
               AND history_Status = 'A'
               AND aps_nst = 248
               AND ap_id = p_ap_id;

        IF     l_appeal.ap_tp <> 'U'
           AND NOT (l_appeal.ap_tp = 'V' AND l_ps_cnt > 0)
        THEN
            RETURN;
            raise_application_error (
                -20000,
                'Спроба очистити/видалити дані по держутриманню для зверненнь не для звернення типу "держутримання"!');
        END IF;

        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
            SELECT ps_id
              FROM pc_state_alimony
             WHERE ps_ap = p_ap_id;

        IF SQL%ROWCOUNT > 0
        THEN --Новоприбулі особи - вчищаємо всі рішення, всі відрахування та всі держутримання
            --Видаляємо рішення
            DELETE FROM pd_log
                  WHERE pdl_pd IN
                            (SELECT pd_id
                               FROM pc_decision
                              WHERE pd_ps IN (SELECT x_id FROM tmp_work_ids));

            DELETE FROM pd_right_log
                  WHERE prl_pd IN
                            (SELECT pd_id
                               FROM pc_decision
                              WHERE pd_ps IN (SELECT x_id FROM tmp_work_ids));

            DELETE FROM pd_reject_info
                  WHERE pri_pd IN
                            (SELECT pd_id
                               FROM pc_decision
                              WHERE pd_ps IN (SELECT x_id FROM tmp_work_ids));

            DELETE FROM pd_detail
                  WHERE pdd_pdp IN
                            (SELECT pdp_id
                               FROM pd_payment
                              WHERE pdp_pd IN
                                        (SELECT pd_id
                                           FROM pc_decision
                                          WHERE pd_ps IN
                                                    (SELECT x_id
                                                       FROM tmp_work_ids)));

            DELETE FROM pd_payment
                  WHERE pdp_pd IN
                            (SELECT pd_id
                               FROM pc_decision
                              WHERE pd_ps IN (SELECT x_id FROM tmp_work_ids));

            DELETE FROM pd_features
                  WHERE pde_pd IN
                            (SELECT pd_id
                               FROM pc_decision
                              WHERE pd_ps IN (SELECT x_id FROM tmp_work_ids));

            DELETE FROM pd_family
                  WHERE pdf_pd IN
                            (SELECT pd_id
                               FROM pc_decision
                              WHERE pd_ps IN (SELECT x_id FROM tmp_work_ids));

            DELETE FROM pd_pay_method
                  WHERE pdm_pd IN
                            (SELECT pd_id
                               FROM pc_decision
                              WHERE pd_ps IN (SELECT x_id FROM tmp_work_ids));

            DELETE FROM pd_source
                  WHERE pds_pd IN
                            (SELECT pd_id
                               FROM pc_decision
                              WHERE pd_ps IN (SELECT x_id FROM tmp_work_ids));

            DELETE FROM uss_esr.pd_pay_method
                  WHERE pdm_pd IN
                            (SELECT pd_id
                               FROM pc_decision
                              WHERE pd_ps IN (SELECT x_id FROM tmp_work_ids));

            DELETE FROM uss_esr.pd_income_detail
                  WHERE pid_pic IN
                            (SELECT pic_id
                               FROM uss_esr.pd_income_calc
                              WHERE pic_pd IN
                                        (SELECT pd_id
                                           FROM pc_decision
                                          WHERE pd_ps IN
                                                    (SELECT x_id
                                                       FROM tmp_work_ids)));

            DELETE FROM uss_esr.pd_income_calc
                  WHERE pic_pd IN
                            (SELECT pd_id
                               FROM pc_decision
                              WHERE pd_ps IN (SELECT x_id FROM tmp_work_ids));

            UPDATE uss_esr.pc_attestat
               SET pca_pd = NULL
             WHERE pca_pd IN
                       (SELECT pd_id
                          FROM uss_esr.pc_decision
                         WHERE pd_ps IN
                                   (SELECT x_id FROM uss_esr.tmp_work_ids));

            DELETE FROM uss_esr.pd_income_session
                  WHERE pin_pd IN
                            (SELECT pd_id
                               FROM pc_decision
                              WHERE pd_ps IN (SELECT x_id FROM tmp_work_ids));

            DELETE FROM pc_decision
                  WHERE pd_ps IN (SELECT x_id FROM tmp_work_ids);

            DELETE FROM tmp_work_ids_dn
                  WHERE 1 = 1;

            INSERT INTO tmp_work_ids_dn (x_id)
                SELECT dn_id
                  FROM deduction
                 WHERE dn_ap = p_ap_id;

            --Видаляємо відрахування
            IF SQL%ROWCOUNT > 0
            THEN
                DELETE FROM dn_detail
                      WHERE dnd_dn IN (SELECT x_id FROM tmp_work_ids_dn);

                DELETE FROM dn_log
                      WHERE dnl_dn IN (SELECT x_id FROM tmp_work_ids_dn);

                DELETE FROM pc_accrual_queue
                      WHERE paq_dn IN (SELECT x_id FROM tmp_work_ids_dn);

                DELETE FROM ac_detail
                      WHERE     acd_dn IN (SELECT x_id FROM tmp_work_ids_dn)
                            AND EXISTS
                                    (SELECT 1
                                       FROM accrual
                                      WHERE acd_ac = ac_id AND ac_st = 'E')
                            AND acd_prsd IS NULL
                            AND acd_imp_pr_num IS NULL;

                DELETE FROM deduction
                      WHERE dn_id IN (SELECT x_id FROM tmp_work_ids_dn);
            END IF;

            --Видаляємо держутримання
            DELETE FROM ps_log
                  WHERE psl_ps IN (SELECT x_id FROM tmp_work_ids);

            DELETE FROM ps_changes
                  WHERE psc_ps IN (SELECT x_id FROM tmp_work_ids);

            DELETE FROM pc_state_alimony
                  WHERE ps_id IN (SELECT x_id FROM tmp_work_ids);
        ELSE --Або помилкове зверення, що не породило записів, або це зміна стану особи, яка вже перебуває на держутриманні
            --Шукаємо сесію вставки в табилці історії по держутриманню - вона повинна бути однакова у всіх нових записів по зверненню
            SELECT MIN (psc_hs_ins)
              INTO l_hs_prove
              FROM ps_changes
             WHERE psc_ap = p_ap_id AND history_status = 'A';

            --Визначаємо ті держутримання, по яких, вірогідно, було проставлено дату вибуття в реєстраційному записі держутримання.
            DELETE FROM tmp_work_set1
                  WHERE 1 = 1;

            INSERT INTO tmp_work_set1 (x_id1, x_id2)
                  SELECT psc_ps, COUNT (*)
                    FROM ps_changes
                   WHERE     psc_ap = p_ap_id
                         AND history_status = 'A'
                         AND psc_st = 'OUT'
                         AND psc_tp IN ('DE')
                GROUP BY psc_ps;

            --Видаляємо рішення, які створені по такому зверненню
            INSERT INTO tmp_work_ids (x_id)
                SELECT pd_id
                  FROM pc_decision
                 WHERE pd_ap_reason = p_ap_id AND pd_src = 'SA';

            DELETE FROM pd_log
                  WHERE pdl_pd IN (SELECT x_id FROM tmp_work_ids);

            DELETE FROM pd_right_log
                  WHERE prl_pd IN (SELECT x_id FROM tmp_work_ids);

            DELETE FROM pd_reject_info
                  WHERE pri_pd IN (SELECT x_id FROM tmp_work_ids);

            DELETE FROM pd_detail
                  WHERE pdd_pdp IN
                            (SELECT pdp_id
                               FROM pd_payment
                              WHERE pdp_pd IN (SELECT x_id FROM tmp_work_ids));

            DELETE FROM pd_payment
                  WHERE pdp_pd IN (SELECT x_id FROM tmp_work_ids);

            DELETE FROM pd_features
                  WHERE pde_pd IN (SELECT x_id FROM tmp_work_ids);

            DELETE FROM pd_family
                  WHERE pdf_pd IN (SELECT x_id FROM tmp_work_ids);

            DELETE FROM ac_detail
                  WHERE     acd_pd IN (SELECT x_id FROM tmp_work_ids)
                        AND EXISTS
                                (SELECT 1
                                   FROM accrual
                                  WHERE acd_ac = ac_id AND ac_st = 'E');

            DELETE FROM uss_esr.pd_source
                  WHERE pds_pd IN (SELECT x_id FROM tmp_work_ids);

            DELETE FROM uss_esr.pd_pay_method
                  WHERE pdm_pd IN (SELECT x_id FROM uss_esr.tmp_work_ids);

            DELETE FROM uss_esr.pd_income_detail
                  WHERE pid_pic IN
                            (SELECT pic_id
                               FROM uss_esr.pd_income_calc
                              WHERE pic_pd IN
                                        (SELECT x_id
                                           FROM uss_esr.tmp_work_ids));

            DELETE FROM uss_esr.pd_income_calc
                  WHERE pic_pd IN (SELECT x_id FROM uss_esr.tmp_work_ids);

            DELETE FROM uss_esr.pd_income_session
                  WHERE pin_pd IN (SELECT x_id FROM uss_esr.tmp_work_ids);

            UPDATE uss_esr.pc_attestat
               SET pca_pd = NULL
             WHERE pca_pd IN (SELECT x_id FROM uss_esr.tmp_work_ids);

            DELETE FROM pc_decision
                  WHERE pd_id IN (SELECT x_id FROM tmp_work_ids);

            --Видаляємо нові записи деталі відрахування та відновлюємо видалені при "проведенні"
            DELETE FROM dn_detail
                  WHERE dnd_hs_ins = l_hs_prove;

            --Відновлюємо попередні записи з історії.
            UPDATE dn_detail
               SET history_status = 'A', dnd_hs_del = NULL, dnd_psc = NULL
             WHERE dnd_hs_del = l_hs_prove AND history_status = 'H';

            --Видаляємо нові записи деталі держутримання та відновлюємо видалені при "проведенні"
            DELETE FROM ps_changes
                  WHERE psc_hs_ins = l_hs_prove;

            --Відновлюємо попередні записи з історії.
            UPDATE ps_changes
               SET history_status = 'A', psc_hs_del = NULL
             WHERE psc_hs_del = l_hs_prove AND history_status = 'H';

            UPDATE pc_state_alimony
               SET ps_stop_dt = NULL
             WHERE     ps_stop_dt IS NOT NULL
                   AND EXISTS
                           (SELECT 1
                              FROM tmp_work_set1
                             WHERE x_id1 = ps_id AND x_id2 > 0);
        END IF;
    END;

    --======================================================--
    --  Отримання текстового параметру документу по зверненню
    --======================================================--
    FUNCTION get_doc_string (p_ap        ap_document.apd_ap%TYPE,
                             p_ndt       ap_document.apd_ndt%TYPE,
                             p_nda       ap_document_attr.apda_nda%TYPE,
                             p_default   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_rez   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (apda_val_string)
          INTO l_rez
          FROM ap_document JOIN ap_document_attr ON apda_apd = apd_id
         WHERE     ap_document.history_status = 'A'
               AND apd_ap = p_ap
               AND apd_ndt = p_ndt
               AND apda_nda = p_nda;

        IF p_default IS NOT NULL
        THEN
            RETURN NVL (l_rez, p_default);
        END IF;

        RETURN l_rez;
    END;

    --======================================================--
    --  Перевірити стан держутримання --#74595  2022.01.26
    --======================================================--
    /*
      PROCEDURE Check_state_alimony_for_aprove(
                                     p_ap_reason  pc_decision.pd_ap_reason%TYPE,
                                     p_old_pd_st  pc_decision.pd_st%TYPE) IS
        l_ps_st      pc_state_alimony.ps_st%TYPE;
        l_ps_st_name uss_ndi.v_ddn_ps_st.dic_name%TYPE;
      BEGIN
        IF p_ap_reason IS NULL THEN
          RETURN;
        END IF;

        WITH state_alimony AS
           ( SELECT MAX(ps_st) ps_st FROM pc_state_alimony  WHERE ps_ap = p_ap_reason )
        SELECT ps_st, nvl(dic_name, 'Статус не зазначено') dic_name
        INTO l_ps_st, l_ps_st_name
        FROM state_alimony
             LEFT JOIN uss_ndi.v_ddn_ps_st ON ps_st = dic_value;

        CASE
        WHEN l_ps_st IS NULL THEN
          NULL;
        WHEN p_old_pd_st IN ('R0', 'R1' ) THEN
          NULL;
        WHEN p_old_pd_st = 'P' AND l_ps_st IN  ('P') THEN
          raise_application_error(-20000, 'Необхідно в ЕОС перевірити та підтвердити запис про "Держутримання",який знаходиться у статусі "Редагується"');
        WHEN p_old_pd_st = 'K' AND l_ps_st IN  ('P') THEN
          raise_application_error(-20000, 'Необхідно в ЕОС перевірити та підтвердити запис про "Держутримання",який знаходиться у статусі "Редагується"');
        ELSE
          NULL;
        END CASE;

      END;
    */
    PROCEDURE Check_state_alimony_for_aprove (
        p_ap_reason   pc_decision.pd_ap_reason%TYPE,
        p_old_pd_st   pc_decision.pd_st%TYPE)
    IS
        l_err_txt   VARCHAR2 (2000);
    BEGIN
        IF p_ap_reason IS NULL
        THEN
            RETURN;
        END IF;

        WITH
            state_alimony
            AS
                (SELECT MAX (ps_st)     ps_st
                   FROM pc_state_alimony
                  WHERE ps_ap = p_ap_reason)
        SELECT                                                  --pd.ch_pd_st,
                 --ps_st, nvl(nst.dic_name, 'Статус не зазначено') ps_st_name,
              LISTAGG (
                  CASE
                      WHEN pd.aprove_ps_st NOT LIKE '%' || st.ps_st || '%'
                      THEN
                             'Необхідно в ЕОС перевірити та підтвердити запис про "Держутримання",який знаходиться у статусі "'
                          || nst.dic_name
                          || '"'
                      ELSE
                          ''
                  END)
              WITHIN GROUP (ORDER BY 1)    AS err_txt
         INTO l_err_txt
         FROM TABLE (API$ANKETA.Get_Check_pd_st) pd,
              state_alimony                      st
              JOIN uss_ndi.v_ddn_ps_st nst ON ps_st = nst.dic_value
        WHERE pd.ch_pd_st IN ('P', 'K', 'S') AND pd.isaprove = 'T';

        IF l_err_txt IS NOT NULL
        THEN
            raise_application_error (-20000, l_err_txt);
        END IF;
    END;

    --======================================================--
    /*
      PROCEDURE Check_state_alimony_for_reject(
                                     p_ap_reason  pc_decision.pd_ap_reason%TYPE,
                                     p_old_pd_st  pc_decision.pd_st%TYPE) IS
        l_ps_st      pc_state_alimony.ps_st%TYPE;
        l_ps_st_name uss_ndi.v_ddn_ps_st.dic_name%TYPE;
      BEGIN
        IF p_ap_reason IS NULL THEN
          RETURN;
        END IF;

        WITH state_alimony AS
           ( SELECT MAX(ps_st) ps_st FROM pc_state_alimony  WHERE ps_ap = p_ap_reason )
        SELECT ps_st, nvl(dic_name, 'Статус не зазначено') dic_name
        INTO l_ps_st, l_ps_st_name
        FROM state_alimony
             LEFT JOIN uss_ndi.v_ddn_ps_st ON ps_st = dic_value;

        CASE
        WHEN l_ps_st IS NULL THEN
          NULL;
        WHEN p_old_pd_st = 'S' AND l_ps_st IN  ('R', 'NR') THEN
          raise_application_error(-20000, 'Необхідно в ЕОС перевірити та відкатити запис про "Держутримання",який знаходиться у статусі "'||l_ps_st_name||'"');
        WHEN p_old_pd_st = 'K' AND l_ps_st IN  ('R', 'NR') THEN
          raise_application_error(-20000, 'Необхідно в ЕОС перевірити та відкатити запис про "Держутримання",який знаходиться у статусі "'||l_ps_st_name||'"');
        WHEN p_old_pd_st = 'P' AND l_ps_st IN  ('P') THEN
          raise_application_error(-20000, 'Необхідно в ЕОС перевірити та підтвердити запис про "Держутримання",який знаходиться у статусі "'||l_ps_st_name||'"');
        ELSE
          NULL;
        END CASE;

      END;
    */
    PROCEDURE Check_state_alimony_for_reject (
        p_ap_reason   pc_decision.pd_ap_reason%TYPE,
        p_old_pd_st   pc_decision.pd_st%TYPE)
    IS
        l_err_txt   VARCHAR2 (2000);
    BEGIN
        IF p_ap_reason IS NULL
        THEN
            RETURN;
        END IF;

        WITH
            state_alimony
            AS
                (SELECT MAX (ps_st)     ps_st
                   FROM pc_state_alimony
                  WHERE ps_ap = p_ap_reason)
        SELECT                                                  --pd.ch_pd_st,
                 --ps_st, nvl(nst.dic_name, 'Статус не зазначено') ps_st_name,
              LISTAGG (
                  CASE
                      WHEN pd.reject_ps_st LIKE '%' || st.ps_st || '%'
                      THEN
                             'Необхідно в ЕОС перевірити та відкатити запис про "Держутримання",який знаходиться у статусі "'
                          || nst.dic_name
                          || '"'
                      ELSE
                          ''
                  END)
              WITHIN GROUP (ORDER BY 1)    AS err_txt
         INTO l_err_txt
         FROM TABLE (API$ANKETA.Get_Check_pd_st) pd,
              state_alimony                      st
              JOIN uss_ndi.v_ddn_ps_st nst ON ps_st = nst.dic_value
        WHERE pd.ch_pd_st IN ('P', 'K', 'S') AND pd.isreject = 'T';

        IF l_err_txt IS NOT NULL
        THEN
            raise_application_error (-20000, l_err_txt);
        END IF;
    END;

    --======================================================--
    --  Продвинути стан держутримання --#74595  2022.01.26
    --======================================================--
    PROCEDURE approve_state_alimony (p_ps_id pc_state_alimony.ps_id%TYPE)
    IS
        l_old_st    pc_state_alimony.ps_st%TYPE;
        l_new_st    pc_state_alimony.ps_st%TYPE;
        l_err_txt   VARCHAR2 (2000);
    BEGIN
        WITH
            state_alimony
            AS
                (SELECT ps_id,
                        ps_ap,
                        ps_st,
                        CASE
                            WHEN ps_st = 'P'
                            THEN
                                'S'
                            WHEN     ps_st = 'S'
                                 AND api$pc_state_alimony.get_doc_string (
                                         ps_ap,
                                         10035,
                                         909,
                                         '-') IN ('TR',
                                                  'UN',
                                                  'DE',
                                                  'HL')
                            THEN
                                'NR'
                            WHEN ps_st = 'S'
                            THEN
                                'R'
                        END    AS ps_st_new
                   FROM pc_state_alimony)
        SELECT ps_st,
               ps_st_new,                          --ps.aprove_pd_st, d.pd_st,
               CASE
                   WHEN     ps.aprove_pd_st NOT LIKE '%' || d.pd_st || '%'
                        AND ps.isaprove = 'T'
                   THEN
                          'Держутримання неможливо перевести в "'
                       || (SELECT dic_name
                             FROM uss_ndi.v_ddn_ps_st
                            WHERE dic_value = ps_st_new)
                       || '", коли "Рішення про призначення допомоги" в статусі "'
                       || nst.dic_name
                       || '"!'
                   WHEN ps_st_new IS NULL
                   THEN
                          '"Держутримання" вже знаходиться в статусі "'
                       || (SELECT dic_name
                             FROM uss_ndi.v_ddn_ps_st
                            WHERE dic_value = ps_st)
                       || '"'
                   ELSE
                       ''
               END    AS err_txt
          INTO l_old_st, l_new_st, l_err_txt
          FROM state_alimony  sa
               LEFT JOIN TABLE (API$ANKETA.Get_Check_ps_st) ps
                   ON ch_ps_st = sa.ps_st
               LEFT JOIN pc_decision d ON d.pd_ap_reason = sa.ps_ap
               LEFT JOIN uss_ndi.v_ddn_pd_st nst ON pd_st = nst.dic_value
         WHERE sa.ps_id = p_ps_id;

        IF l_err_txt IS NOT NULL
        THEN
            raise_application_error (-20000, l_err_txt);
        END IF;

        UPDATE pc_state_alimony
           SET ps_st = l_new_st
         WHERE ps_id = p_ps_id AND ps_st = l_old_st AND l_new_st IS NOT NULL;

        IF SQL%ROWCOUNT > 0
        THEN
            write_ps_log (p_ps_id,
                          NULL,
                          l_new_st,
                          CHR (38) || '40',
                          l_old_st,
                          'SYS');
        END IF;
    END;

    --======================================================--
    --  Повернути стан держутримання на попереднью позицію --#74595  2022.01.26
    --======================================================--
    PROCEDURE reject_state_alimony (p_ps_id       pc_state_alimony.ps_id%TYPE,
                                    p_reason   IN VARCHAR2 := NULL)
    IS
        l_hs            histsession.hs_id%TYPE;
        l_old_st        pc_state_alimony.ps_st%TYPE;
        l_new_st        pc_state_alimony.ps_st%TYPE;
        l_err_txt       VARCHAR2 (2000);
        l_old_st_name   uss_ndi.v_ddn_ps_st.dic_name%TYPE;
        l_pd_st         pc_decision.pd_st%TYPE;
        l_pd_st_name    uss_ndi.v_ddn_pd_st.dic_name%TYPE;
    BEGIN
        --raise_application_error(-20000, p_ps_id);
        /*WITH state_alimony AS
             ( SELECT ps_id, ps_ap, ps_st,
                       CASE WHEN ps_st = 'P' THEN 'S'
                            WHEN ps_st = 'S' AND api$pc_state_alimony.get_doc_string(ps_ap, 10035, 909, '-') IN ('TR','UN','DE','HL') THEN 'NR'
                            WHEN ps_st = 'S' THEN 'R'
                       END AS ps_st_new
               FROM pc_state_alimony
             )
        SELECT ps_st, ps_st_new, --ps.aprove_pd_st, d.pd_st,
               CASE WHEN ps.reject_pd_st NOT LIKE '%'||d.pd_st||'%' AND ps.isreject = 'T' THEN
                         'Держутримання неможливо перевести в "'||(SELECT dic_name FROM uss_ndi.v_ddn_ps_st WHERE dic_value = ps_st_new)||
                         '", коли "Рішення про призначення допомоги" в статусі "'||nst.dic_name||'"!'
                    WHEN ps_st_new IS NULL THEN
                         '"Держутримання" вже знаходиться в статусі "'||(SELECT dic_name FROM uss_ndi.v_ddn_ps_st WHERE dic_value = ps_st)||'"'
                    ELSE ''
                    END AS err_txt
        INTO l_old_st, l_new_st, l_err_txt
        FROM state_alimony sa
             LEFT JOIN TABLE(API$ANKETA.Get_Check_ps_st) ps ON ch_ps_st = sa.ps_st
             LEFT JOIN pc_decision  d ON d.pd_ap_reason = sa.ps_ap
             LEFT JOIN uss_ndi.v_ddn_pd_st nst ON pd_st = nst.dic_value
        WHERE sa.ps_id = p_ps_id;

        IF l_err_txt IS NOT NULL THEN
          raise_application_error(-20000, l_err_txt);
        END IF;*/

        SELECT ps_st,
               dic_name,
               CASE WHEN ps_st = 'S' THEN 'P' END,
               pd_st,
               (SELECT dic_name
                  FROM uss_ndi.v_ddn_pd_st
                 WHERE dic_value = d.pd_st)
          INTO l_old_st,
               l_old_st_name,
               l_new_st,
               l_pd_st,
               l_pd_st_name
          FROM pc_state_alimony
               INNER JOIN uss_ndi.v_ddn_ps_st ON ps_st = dic_value
               LEFT JOIN pc_decision d ON d.pd_ap_reason = ps_ap
         WHERE ps_id = p_ps_id;

        IF l_old_st NOT IN ('R', 'NR', 'S')
        THEN
            raise_application_error (
                -20000,
                   'Держутримання неможливо повернути з статусу '
                || l_old_st_name
                || '!');
        --    ELSIF l_old_st IN ('R', 'NR') AND  THEN
        --      raise_application_error(-20000, 'Держутримання неможливо повернути на візування з статусу '||l_old_st_name||'!');
        ELSIF l_old_st IN ('S') AND l_pd_st IN ('K', 'S')
        THEN
            raise_application_error (
                -20000,
                   'Держутримання неможливо повернути на редагування, коли "Рішення про призначення допомоги" в статусі '
                || l_pd_st_name
                || '!');
        ELSIF l_new_st IS NULL
        THEN
            raise_application_error (
                -20000,
                   'Держутримання неможливо повернути з статусу .'
                || l_old_st_name
                || '!');
        END IF;

        l_hs := tools.GetHistSession;

        UPDATE pc_state_alimony
           SET ps_st = l_new_st
         WHERE ps_id = p_ps_id AND ps_st = l_old_st AND l_new_st IS NOT NULL;

        IF SQL%ROWCOUNT > 0
        THEN
            write_ps_log (p_ps_id,
                          l_hs,
                          l_new_st,
                          CHR (38) || '41',
                          l_old_st,
                          'SYS');
        /*
            IF p_reason IS NOT NULL THEN
              API$PC_DECISION.write_pd_log(p_dn_id, l_hs, l_new_st, p_reason, l_old_st, 'USR');
            END IF;
        */
        END IF;
    END;

    PROCEDURE close_state_alimony (p_ps_id pc_state_alimony.ps_id%TYPE)
    IS
        l_ps    v_pc_state_alimony%ROWTYPE;
        l_cnt   INTEGER;
    BEGIN
        SELECT *
          INTO l_ps
          FROM v_pc_state_alimony
         WHERE ps_id = p_ps_id;

        SELECT COUNT (*)
          INTO l_cnt
          FROM ps_changes
         WHERE     psc_ps = l_ps.ps_id
               AND history_status = 'A'
               AND psc_tp IN ('TR',
                              'UN',
                              'DE',
                              'HL')
               AND psc_st = 'OUT'
               AND psc_stop_dt IS NULL;

        IF l_ps.ps_st = 'R' AND l_cnt = 1
        THEN
            UPDATE pc_state_alimony
               SET ps_st = 'NR'
             WHERE ps_id = l_ps.ps_id AND ps_st = 'R';

            write_ps_log (l_ps.ps_id,
                          NULL,
                          'NR',
                          CHR (38) || '286',
                          'R',
                          'SYS');
        ELSE
            raise_application_error (
                -20000,
                'Не можна виконувати дану операцію - запис держутримання не діючий або особа не вибула з закладу з причиною ""Переведення" або "Самовільне вибуття", або "Смерть особи", або "Вибув"');
        END IF;
    END;

    PROCEDURE reopen_state_alimony (p_ps_id pc_state_alimony.ps_id%TYPE)
    IS
        l_ps    v_pc_state_alimony%ROWTYPE;
        l_cnt   INTEGER;
    BEGIN
        SELECT *
          INTO l_ps
          FROM v_pc_state_alimony
         WHERE ps_id = p_ps_id;

        SELECT COUNT (*)
          INTO l_cnt
          FROM ps_changes
         WHERE     psc_ps = l_ps.ps_id
               AND history_status = 'A'
               AND psc_tp IN ('TR',
                              'UN',
                              'DE',
                              'HL')
               AND psc_st = 'OUT'
               AND psc_stop_dt IS NULL;

        IF l_ps.ps_st = 'NR' AND l_cnt = 1
        THEN
            UPDATE pc_state_alimony
               SET ps_st = 'R'
             WHERE ps_id = l_ps.ps_id AND ps_st = 'NR';

            write_ps_log (l_ps.ps_id,
                          NULL,
                          'R',
                          CHR (38) || '286',
                          'NR',
                          'SYS');
        ELSE
            raise_application_error (
                -20000,
                'Не можна виконувати дану операцію - запис держутримання не "Припинено перебування" або особа не вибула з закладу з причиною ""Переведення" або "Самовільне вибуття", або "Смерть особи", або "Вибув"');
        END IF;
    END;

    PROCEDURE clean_ps_by_ap_reject_pd (p_ap_id appeal.ap_id%TYPE)
    IS
        l_cnt   INTEGER;
    BEGIN
        --видаляємо тільки ті держутримання і відповідно відрахування, по яким відповідне рішення в стані "Відмовлено".
        SELECT COUNT (*)
          INTO l_cnt
          FROM appeal, pc_decision
         WHERE     ap_id = p_ap_id
               AND pd_ap_reason = ap_id
               AND pd_src = 'SA'
               AND pd_st = 'V';

        IF l_cnt = 0
        THEN
            RETURN;
            raise_application_error (
                -20000,
                'Не можна виконувати дану операцію - не знайдено рішень в стані "Відхилено", по яким треба видаляти держутримання та відповідне відрахування!');
        END IF;

        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
            SELECT ps_id
              FROM pc_state_alimony
             WHERE ps_ap = p_ap_id;

        DELETE FROM tmp_work_ids_dn
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids_dn (x_id)
            SELECT dn_id
              FROM deduction
             WHERE dn_ap = p_ap_id;

        --Видаляємо відрахування
        DELETE FROM dn_detail
              WHERE dnd_dn IN (SELECT x_id FROM tmp_work_ids_dn);

        DELETE FROM dn_log
              WHERE dnl_dn IN (SELECT x_id FROM tmp_work_ids_dn);

        DELETE FROM pc_accrual_queue
              WHERE paq_dn IN (SELECT x_id FROM tmp_work_ids_dn);

        DELETE FROM ac_detail
              WHERE     acd_dn IN (SELECT x_id FROM tmp_work_ids_dn)
                    AND EXISTS
                            (SELECT 1
                               FROM accrual
                              WHERE acd_ac = ac_id AND ac_st = 'E')
                    AND acd_prsd IS NULL
                    AND acd_imp_pr_num IS NULL;

        DELETE FROM deduction
              WHERE dn_id IN (SELECT x_id FROM tmp_work_ids_dn);

        --Видаляємо держутримання
        UPDATE pc_decision
           SET pd_ps = NULL
         WHERE pd_ps IN (SELECT x_id FROM tmp_work_ids);

        DELETE FROM ps_log
              WHERE psl_ps IN (SELECT x_id FROM tmp_work_ids);

        DELETE FROM ps_changes
              WHERE psc_ps IN (SELECT x_id FROM tmp_work_ids);

        DELETE FROM pc_state_alimony
              WHERE ps_id IN (SELECT x_id FROM tmp_work_ids);
    END;
BEGIN
    -- Initialization
    NULL;
END API$PC_STATE_ALIMONY;
/