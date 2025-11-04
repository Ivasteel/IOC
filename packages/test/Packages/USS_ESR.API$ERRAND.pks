/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$ERRAND
IS
    -- Author  : VANO
    -- Created : 12.05.2023 12:30:01
    -- Purpose : Функції роботи з дорученнями на одноразову виплату

    --Ініціалізація рішень про припинення виплати допомоги за зверненням
    PROCEDURE init_act_by_appeals_923 (p_mode           INTEGER,
                                       p_ap_id          appeal.ap_id%TYPE,
                                       p_messages   OUT SYS_REFCURSOR);

    --Формування доручення на одноразову виплату за рішенням на припинення виплати допомог
    PROCEDURE init_errand_by_acts_923 (p_mode        INTEGER,
                                       p_at_id       act.at_id%TYPE,
                                       p_ed_id   OUT errand.ed_id%TYPE);

    --Ініціалізація рішень про припинення виплати допомог за масовим перерахунком по виявленню АЗ про смерть
    PROCEDURE init_act_by_odeath (p_mode INTEGER, p_rc_id appeal.ap_id%TYPE);

    PROCEDURE errand_recalc (p_ed_id errand.ed_id%TYPE);

    PROCEDURE errand_approve (p_ed_id errand.ed_id%TYPE);

    PROCEDURE errand_reject (p_ed_id    errand.ed_id%TYPE,
                             p_ed_rnp   errand.ed_rnp%TYPE);

    PROCEDURE errand_return (p_ed_id errand.ed_id%TYPE, p_reason VARCHAR2);

    PROCEDURE decision_rstopv_approve (p_at_id act.at_id%TYPE);

    PROCEDURE decision_rstopv_return (p_at_id    act.at_id%TYPE,
                                      p_reason   VARCHAR2 DEFAULT NULL);

    PROCEDURE decision_rstopv_reject (p_at_id act.at_id%TYPE);

    --Формування документу одноразової виплати "Повернення зайво утриманих сум" по проводкам відрахування
    PROCEDURE init_errand_by_deduction (p_mode         INTEGER, --1=Повернення зайво утриманих сум проводками 1 відрахування (ід-и проводок через tmp_work_ids4)
                                        p_ed_id    OUT errand.ed_id%TYPE,
                                        p_reason       VARCHAR2 := NULL);

    PROCEDURE init_errand_by_accrual (p_mode INTEGER); --1=Повернення зайво утриманих сум проводками 1 відрахування (ід-и проводок через tmp_work_ids4)
END API$ERRAND;
/


/* Formatted on 8/12/2025 5:49:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$ERRAND
IS
    PROCEDURE write_at_log (p_atl_at        at_log.atl_at%TYPE,
                            p_atl_hs        at_log.atl_hs%TYPE,
                            p_atl_st        at_log.atl_st%TYPE,
                            p_atl_message   at_log.atl_message%TYPE,
                            p_atl_st_old    at_log.atl_st_old%TYPE,
                            p_atl_tp        at_log.atl_tp%TYPE:= 'SYS')
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        --l_hs := NVL(p_atl_hs, TOOLS.GetHistSession);
        l_hs := p_atl_hs;

        IF l_hs IS NULL
        THEN
            l_hs := TOOLS.GetHistSession;
        END IF;

        INSERT INTO at_log (atl_id,
                            atl_at,
                            atl_hs,
                            atl_st,
                            atl_message,
                            atl_st_old,
                            atl_tp)
             VALUES (0,
                     p_atl_at,
                     l_hs,
                     p_atl_st,
                     p_atl_message,
                     p_atl_st_old,
                     NVL (p_atl_tp, 'SYS'));
    END;

    PROCEDURE write_ed_log (p_edl_ed        ed_log.edl_ed%TYPE,
                            p_edl_hs        ed_log.edl_hs%TYPE,
                            p_edl_st        ed_log.edl_st%TYPE,
                            p_edl_message   ed_log.edl_message%TYPE,
                            p_edl_st_old    ed_log.edl_st_old%TYPE,
                            p_edl_tp        ed_log.edl_tp%TYPE:= 'SYS')
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        --l_hs := NVL(p_edl_hs, TOOLS.GetHistSession);
        l_hs := p_edl_hs;

        IF l_hs IS NULL
        THEN
            l_hs := TOOLS.GetHistSession;
        END IF;

        INSERT INTO ed_log (edl_id,
                            edl_ed,
                            edl_hs,
                            edl_st,
                            edl_message,
                            edl_st_old,
                            edl_tp)
             VALUES (0,
                     p_edl_ed,
                     l_hs,
                     p_edl_st,
                     p_edl_message,
                     p_edl_st_old,
                     NVL (p_edl_tp, 'SYS'));
    END;

    --Ініціалізація рішень про припинення виплати допомоги за зверненням
    PROCEDURE init_act_by_appeals_923 (p_mode           INTEGER,
                                       p_ap_id          appeal.ap_id%TYPE,
                                       p_messages   OUT SYS_REFCURSOR)
    IS
        l_cnt        INTEGER;
        l_hs         histsession.hs_id%TYPE := NULL;
        g_messages   TOOLS.t_messages := TOOLS.t_messages ();
    BEGIN
        IF p_mode = 1 AND p_ap_id IS NOT NULL
        THEN
            DELETE FROM tmp_work_set3
                  WHERE 1 = 1;

            INSERT INTO tmp_work_set3 (x_id1)
                SELECT ap_id
                  FROM appeal
                 WHERE     ap_id = p_ap_id
                       AND ap_st IN ('O')
                       AND ap_tp IN ('O')
                       AND EXISTS
                               (SELECT 1
                                  FROM ap_service
                                 WHERE     aps_ap = ap_id
                                       AND history_status = 'A'
                                       AND aps_nst IN (923, 924));

            l_cnt := SQL%ROWCOUNT;
        ELSE
            DELETE FROM tmp_work_set3
                  WHERE NOT EXISTS
                            (SELECT 1
                               FROM appeal, ap_service
                              WHERE     x_id1 = ap_id
                                    AND ap_st IN ('O')
                                    AND ap_tp IN ('O')
                                    AND aps_ap = ap_id
                                    AND history_status = 'A'
                                    AND aps_nst IN (923, 924));

            SELECT COUNT (*) INTO l_cnt FROM tmp_work_set3;
        END IF;

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'В функцію формування рішень про припинення надання послуг (по послугам 923/924) не передано зверненнь!');
        END IF;

        --А чи не повторна обробка це звернення, після повернення на довведення?
        UPDATE tmp_work_set3
           SET x_id3 =
                   (SELECT at_id
                      FROM act
                     WHERE at_ap = x_id1 AND at_tp = 'RSTOPV' AND at_st = 'W')
         WHERE 1 = 1;

        UPDATE tmp_work_set3
           SET x_id2 = NVL (x_id3, id_act (0))
         WHERE 1 = 1;

        --Створюємо проекти рішень для тих звереннь, що обробляються вперше
        INSERT INTO act (at_id,
                         at_tp,
                         at_pc,
                         at_num,
                         at_dt,
                         at_org,
                         at_sc,
                         at_rnp,
                         at_ap,
                         at_st,
                         at_src)
            SELECT x_id2,
                   'RSTOPV',
                   ap_pc,
                   x_id2,
                   TRUNC (SYSDATE),
                   pc.com_org,
                   pc_sc,
                   2,
                   ap_id,
                   'E',
                   ap_src
              FROM tmp_work_set3, appeal, personalcase pc
             WHERE x_id1 = ap_id AND ap_pc = pc_id AND x_id3 IS NULL;

        --Видаляємо ті послуги, які пропали зі звернення (якщо повторно прийшло після довведення)
        UPDATE at_service
           SET history_status = 'H'
         WHERE     history_status = 'A'
               AND EXISTS
                       (SELECT 1
                          FROM act, tmp_work_set3
                         WHERE at_id = x_id2 AND ats_at = at_id)
               AND NOT EXISTS
                       (SELECT 1
                          FROM act, tmp_work_set3, ap_service aps
                         WHERE     at_id = x_id2
                               AND ats_at = at_id
                               AND aps_ap = at_ap
                               AND aps.history_status = 'A');

        --Додаємо ті послуги, що є зі зверненні і немає в акті ще
        INSERT INTO at_service (ats_id,
                                ats_at,
                                ats_nst,
                                history_status,
                                ats_st)
            SELECT 0,
                   at_id,
                   aps_nst,
                   'A',
                   'R'
              FROM act, tmp_work_set3, ap_service aps
             WHERE     at_id = x_id2
                   AND aps_ap = at_ap
                   AND aps.history_status = 'A'
                   AND NOT EXISTS
                           (SELECT 1
                              FROM at_service ats
                             WHERE     ats_at = at_id
                                   AND ats.history_status = 'A'
                                   AND ats_nst = aps_nst);

        --Оновлюємо стан рішень, звернення яких повертались на доопрацювання (також оновлюємо дату рішення, ЕОС, орган та соц.картку, якщо змінилось щось)
        UPDATE act
           SET (at_st,
                at_pc,
                at_dt,
                at_org,
                at_sc) =
                   (SELECT 'E',
                           ap_pc,
                           TRUNC (SYSDATE),
                           pc.com_org,
                           pc_sc
                      FROM tmp_work_set3, appeal, personalcase pc
                     WHERE x_id1 = ap_id AND ap_pc = pc_id AND at_ap = x_id1)
         WHERE at_id IN (SELECT x_id2
                           FROM tmp_work_set3
                          WHERE x_id3 IS NOT NULL);

        l_hs := TOOLS.GetHistSession;

        INSERT INTO at_log (atl_id,
                            atl_at,
                            atl_hs,
                            atl_st,
                            atl_message,
                            atl_st_old,
                            atl_tp)
            SELECT 0,
                   x_id2,
                   l_hs,
                   'E',
                   CHR (38) || '212',
                   NULL,
                   'SYS'
              FROM tmp_work_set3;

        --Проставляємо стан звернення "обробляється"
        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
            SELECT x_id1 FROM tmp_work_set3;

        API$APPEAL.mark_appeal_working (2,
                                        4,
                                        NULL,
                                        l_cnt);

        --Повідомляємо про зміну стану звернення в ЄСП
        FOR xx IN (SELECT x_id2 AS x_at, at_num, pc_num
                     FROM tmp_work_set3, act, personalcase
                    WHERE at_id = x_id2 AND at_pc = pc_id)
        LOOP
            api$esr_action.preparewrite_visit_at_log (
                xx.x_at,
                CHR (38) || '219#' || xx.at_num || '#' || xx.pc_num);
        END LOOP;

        OPEN p_Messages FOR SELECT * FROM TABLE (g_messages);
    END;

    --Ініціалізація рішень про припинення виплати допомог за масовим перерахунком по виявленню АЗ про смерть
    PROCEDURE init_act_by_odeath (p_mode INTEGER, p_rc_id appeal.ap_id%TYPE)
    IS
        l_cnt   INTEGER;
        l_hs    histsession.hs_id%TYPE := NULL;
    BEGIN
        IF p_mode = 1 AND p_rc_id IS NOT NULL
        THEN
            DELETE FROM tmp_work_set3
                  WHERE 1 = 1;

            INSERT INTO tmp_work_set3 (x_id1)
                SELECT rcc_pc
                  FROM rc_candidates
                 WHERE rcc_rc = p_rc_id;

            l_cnt := SQL%ROWCOUNT;
        ELSE
            raise_application_error (
                -20000,
                'В функцію формування рішень про припинення надання послуг (по перерахунку з фактів виявлення АЗ про смерть) не передано ЕОС-ів!');
        END IF;

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'В функцію формування рішень про припинення надання послуг (по перерахунку з фактів виявлення АЗ про смерть) не передано ЕОС-ів!');
        END IF;

        UPDATE tmp_work_set3
           SET x_id2 = id_act (0)
         WHERE 1 = 1;

        --Створюємо проекти рішень для тих справ, по особам яких в СРКО є діючий АЗ про смерть (по всім справам - не можна, могло бути так, що це учасник!)
        INSERT INTO act (at_id,
                         at_tp,
                         at_pc,
                         at_num,
                         at_dt,
                         at_org,
                         at_sc,
                         at_rnp,
                         at_ap,
                         at_st,
                         at_src)
            SELECT x_id2,
                   'RSTOPV',
                   x_id1,
                   x_id2,
                   TRUNC (SYSDATE),
                   pc.com_org,
                   pc_sc,
                   (SELECT MIN (rnp_id)
                      FROM uss_ndi.v_ndi_reason_not_pay
                     WHERE rnp_class = 'PAY' AND rnp_code = 'AT_AZD'),
                   NULL,
                   'E',
                   'USS'
              FROM tmp_work_set3, personalcase pc
             WHERE     x_id1 = pc_id
                   AND EXISTS
                           (SELECT 1
                              FROM uss_person.v_sc_document
                             WHERE     scd_sc = pc_sc
                                   AND scd_st = '1'
                                   AND scd_ndt = 89);

        --Додаємо ті послуги, що є в рішеннях таких ЕОС-ів
        INSERT INTO at_service (ats_id,
                                ats_at,
                                ats_nst,
                                history_status,
                                ats_st)
            SELECT DISTINCT 0,
                            at_id,
                            pd_nst,
                            'A',
                            'R'
              FROM tmp_work_set3,
                   act,
                   personalcase,
                   pc_decision
             WHERE     at_id = x_id2
                   AND at_pc = pc_id
                   AND pd_pc = pc_id
                   AND pd_nst IN (248,
                                  249,
                                  265,
                                  267,
                                  268,
                                  269,
                                  664)
                   AND pd_st IN ('S');

        l_hs := TOOLS.GetHistSession;

        --Записуємо в протокол по Акту - причину створення.
        INSERT INTO at_log (atl_id,
                            atl_at,
                            atl_hs,
                            atl_st,
                            atl_message,
                            atl_st_old,
                            atl_tp)
            SELECT 0,
                   x_id2,
                   l_hs,
                   'E',
                   CHR (38) || '260',
                   NULL,
                   'SYS'
              FROM tmp_work_set3, act
             WHERE at_id = x_id2;
    END;

    --Формування доручення на одноразову виплату за рішенням на припинення виплати допомог
    PROCEDURE init_errand_by_acts_923 (p_mode        INTEGER,
                                       p_at_id       act.at_id%TYPE,
                                       p_ed_id   OUT errand.ed_id%TYPE)
    IS
        l_cnt   INTEGER;
        l_hs    histsession.hs_id%TYPE := NULL;
    --g_messages TOOLS.t_messages := TOOLS.t_messages();
    BEGIN
        IF p_mode = 1 AND p_at_id IS NOT NULL
        THEN
            DELETE FROM tmp_work_ids4
                  WHERE 1 = 1;

            INSERT INTO tmp_work_ids4 (x_id)
                SELECT at_id
                  FROM act
                 WHERE     at_id = p_at_id
                       AND at_st IN ('Z')
                       AND at_tp IN ('RSTOPV')
                       AND (   EXISTS
                                   (SELECT 1
                                      FROM ap_service
                                     WHERE     at_ap = aps_ap
                                           AND history_status = 'A'
                                           AND aps_nst IN (923, 924))
                            OR at_ap IS NULL);  --Це для обробки АЗ про смерть

            l_cnt := SQL%ROWCOUNT;
        ELSE
            raise_application_error (-20000, 'Режим не підтримується!');

            DELETE FROM tmp_work_ids4
                  WHERE NOT EXISTS
                            (SELECT 1
                               FROM act, ap_service
                              WHERE     x_id = at_id
                                    AND at_st IN ('Z')
                                    AND at_tp IN ('RSTOPV')
                                    AND at_ap = aps_ap
                                    AND history_status = 'A'
                                    AND aps_nst IN (923, 924));

            SELECT COUNT (*) INTO l_cnt FROM tmp_work_ids4;
        END IF;

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'В функцію формування доручень на одноразову виплату (по послугам 923/924) не передано рішення про припинення надання допомог!');
        END IF;

        SELECT COUNT (*)
          INTO l_cnt
          FROM errand
         WHERE ed_at = p_at_id;

        IF l_cnt = 1
        THEN
            SELECT ed_id
              INTO p_ed_id
              FROM errand
             WHERE ed_at = p_at_id;
        ELSIF l_cnt > 1
        THEN
            raise_application_error (
                -20000,
                'По рішенню про припинення надання допомог вже створено декілька дорученнь на разову виплату!');
        END IF;

        DELETE FROM tmp_work_set3
              WHERE 1 = 1;

        --Генеруємо ІД-и доручень
        INSERT INTO tmp_work_set3 (x_id1, x_id2)
            SELECT x_id, id_errand (0)
              FROM tmp_work_ids4, act
             WHERE x_id = at_id;

        --Генеруємо № документів доручень
        UPDATE tmp_work_set3
           SET x_string1 = x_id2
         WHERE 1 = 1;

        --FOR xx IN (SELECT x_id FROM tmp_work_ids4)

        --Створюємо реєстраційні записи доручень
        INSERT INTO errand (ed_id,
                            ed_pc,
                            com_org,
                            com_wu,
                            ed_ap,
                            ed_num,
                            ed_dt,
                            ed_st,
                            ed_sum,
                            ed_pay_tp,
                            ed_index,
                            ed_kaot,
                            ed_nb,
                            ed_account,
                            ed_street,
                            ed_ns,
                            ed_building,
                            ed_block,
                            ed_apartment,
                            ed_nd,
                            ed_pay_dt,
                            ed_scc,
                            ed_at,
                            ed_rnp,
                            ed_tp)
            SELECT x_id2,
                   at_pc,
                   at_org,
                   TOOLS.GetCurrWu,
                   at_ap,
                   x_string1,
                   TRUNC (SYSDATE),
                   'E',
                   0,
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
                   (SELECT MAX (nd_id)
                      FROM uss_ndi.v_ndi_post_office, uss_ndi.v_ndi_delivery
                     WHERE     nd_npo = npo_id
                           AND npo_index = apm_index
                           AND nd_code = '000'),
                   5,
                   sc_scc,
                   x_id1,
                   NULL,
                   'DEATH'
              FROM tmp_work_set3,
                   act,
                   ap_payment  apm,
                   ap_person   app,
                   uss_person.v_socialcard
             WHERE     x_id1 = at_id
                   AND apm_ap = at_ap
                   AND apm_app = app_id
                   AND app_sc = sc_id
                   AND apm.history_status = 'A'
                   AND app.history_status = 'A';

        l_hs := TOOLS.GetHistSession;

        INSERT INTO ed_log (edl_id,
                            edl_ed,
                            edl_hs,
                            edl_st,
                            edl_message,
                            edl_st_old,
                            edl_tp)
            SELECT 0,
                   x_id2,
                   l_hs,
                   'E',
                   CHR (38) || '213',
                   NULL,
                   'SYS'
              FROM tmp_work_set3, errand
             WHERE x_id2 = ed_id;

        BEGIN
            SELECT ed_id
              INTO p_ed_id
              FROM errand
             WHERE ed_at = p_at_id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                p_ed_id := NULL;
        END;
    END;

    --Формування документу одноразової виплати "Повернення зайво утриманих сум" по проводкам відрахування
    PROCEDURE init_errand_by_deduction (p_mode         INTEGER, --1=Повернення зайво утриманих сум проводками 1 відрахування (ід-и проводок через tmp_work_ids4)
                                        p_ed_id    OUT errand.ed_id%TYPE,
                                        p_reason       VARCHAR2 := NULL)
    IS
        l_cnt1         INTEGER;
        l_cnt2         INTEGER;
        l_hs           histsession.hs_id%TYPE := NULL;
        l_ed_id        errand.ed_id%TYPE;
        l_ac_id        accrual.ac_id%TYPE;
        l_org          personalcase.com_org%TYPE;
        l_curr_month   accrual.ac_month%TYPE;
        l_str          pc_decision.pd_num%TYPE;
    --g_messages TOOLS.t_messages := TOOLS.t_messages();
    BEGIN
        IF p_mode = 1
        THEN
            SELECT MIN (pa_org)
              INTO l_org
              FROM pc_account,
                   deduction,
                   ac_detail,
                   tmp_work_ids4
             WHERE dn_pa = pa_id AND acd_id = x_id AND acd_dn = dn_id;

            SELECT bp_month
              INTO l_curr_month
              FROM billing_period
             WHERE     bp_tp = 'PR'
                   AND bp_org = l_org
                   AND bp_class = 'V'
                   AND bp_st = 'R';

            SELECT COUNT (DISTINCT acd_dn), COUNT (*)
              INTO l_cnt1, l_cnt2
              FROM tmp_work_ids4, ac_detail d, accrual
             WHERE     x_id = acd_id
                   AND acd_ac = ac_id
                   AND d.history_Status = 'A'
                   AND acd_dn IS NOT NULL   --тільки проводки по відрахуванням
                   AND acd_ed IS NULL --тільки невключені в інші одноразові виплати
                   AND ac_month <> l_curr_month; --тільки по закритим розрахунковим періодам

            IF l_cnt1 = 0
            THEN
                raise_application_error (
                    -20000,
                    'Не вказано зайво утриманих сум по відрахуванню - виберіть неповернуті суми в документі Відрахування!');
            ELSIF l_cnt1 > 1
            THEN
                raise_application_error (
                    -20000,
                    'Некоректне використання функції - доступне формування документу тільки по сумам 1 (одного) відрахування!');
            END IF;

            SELECT COUNT (*) INTO l_cnt1 FROM tmp_work_ids4;

            IF l_cnt1 <> l_cnt2
            THEN
                raise_application_error (
                    -20000,
                    'Некоректне використання функції - не можна повернути суми, які сформовані в поточному розрахунковому періоді!');
            END IF;
        ELSE
            raise_application_error (-20000, 'Режим не підтримується!');
        END IF;

        DELETE FROM tmp_work_set3
              WHERE 1 = 1;

        --Генеруємо ІД-и доручень
        INSERT INTO tmp_work_set3 (x_id1,
                                   x_id2,
                                   x_id3,
                                   x_sum1)
            SELECT x_dn,
                   id_errand (0),
                   x_pd,
                   x_sum
              FROM (  SELECT acd_dn            AS x_dn,
                             MAX (acd_pd)      AS x_pd,
                             SUM (acd_sum)     AS x_sum
                        FROM tmp_work_ids4,
                             ac_detail d,
                             deduction,
                             accrual
                       WHERE     x_id = acd_id
                             AND acd_ac = ac_id
                             AND acd_dn = dn_id
                             AND d.history_status = 'A'
                             AND acd_ed IS NULL
                             AND ac_month <> l_curr_month --тільки по закритим розрахунковим періодам
                    GROUP BY acd_dn);

        --Генеруємо № документів доручень
        UPDATE tmp_work_set3
           SET x_string1 = x_id2
         WHERE 1 = 1;

        --Створюємо реєстраційні записи доручень
        INSERT INTO errand (ed_id,
                            ed_pc,
                            com_org,
                            com_wu,
                            ed_ap,
                            ed_num,
                            ed_dt,
                            ed_st,
                            ed_sum,
                            ed_pay_tp,
                            ed_index,
                            ed_kaot,
                            ed_nb,
                            ed_account,
                            ed_street,
                            ed_ns,
                            ed_building,
                            ed_block,
                            ed_apartment,
                            ed_nd,
                            ed_pay_dt,
                            ed_scc,
                            ed_dn,
                            ed_tp,
                            ed_dpp)
            SELECT x_id2,
                   dn_pc,
                   pa_org                                       /*dn.com_org*/
                         ,
                   TOOLS.GetCurrWu,
                   NULL,
                   x_string1,
                   TRUNC (SYSDATE),
                   'E',
                   x_sum1,
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
                   NVL (
                       pdm_nb,
                       (SELECT MAX (nd_id)
                          FROM uss_ndi.v_ndi_post_office,
                               uss_ndi.v_ndi_delivery
                         WHERE     nd_npo = npo_id
                               AND npo_index = pdm_index
                               AND nd_code = '000')),
                   pdm_pay_dt,
                   NVL (pdm_scc,
                        NVL (pd_scc,
                             (SELECT sc_scc
                                FROM personalcase, uss_person.v_socialcard
                               WHERE pc_sc = sc_id AND pd_pc = pc_id))),
                   x_id1,
                   'RETDN',
                   dn_dpp
              FROM tmp_work_set3,
                   deduction      dn,
                   pd_pay_method  pdm,
                   pc_decision,
                   pc_account
             WHERE     x_id1 = dn_id
                   AND pdm_pd = x_id3
                   AND pd_id = x_id3
                   AND pdm_pd = pd_id
                   AND pdm.history_status = 'A'
                   AND pdm.pdm_is_actual = 'T'
                   AND dn_pa = pa_id;

        l_cnt1 := SQL%ROWCOUNT;

        -- return;
        IF l_cnt1 = 0 OR l_cnt1 > 1
        THEN
            BEGIN
                SELECT pd_num
                  INTO l_str
                  FROM tmp_work_set3, pc_decision
                 WHERE x_id3 = pd_id;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    raise_application_error (
                        -20000,
                        'Не вдалось визначити параметри виплати - перевірте параметри виплати рішень, з яких стягувались відрахування!');
            END;

            raise_application_error (
                -20000,
                   'Не вдалось визначити параметри виплати - перевірте параметри виплати рішень, з яких стягувались відрахування ('
                || l_str
                || ')!');
        END IF;

        SELECT x_id2 INTO l_ed_id FROM tmp_work_set3;

        SELECT com_org
          INTO l_org
          FROM errand
         WHERE ed_id = l_ed_id;

        SELECT bp_month
          INTO l_curr_month
          FROM billing_period
         WHERE     bp_tp = 'PR'
               AND bp_org = l_org
               AND bp_class = 'V'
               AND bp_st = 'R';

        SELECT MIN (ac_id)
          INTO l_ac_id
          FROM accrual, errand
         WHERE ac_pc = ed_pc AND ac_month = l_curr_month AND ed_id = l_ed_id;

        IF l_ac_id IS NULL
        THEN
            INSERT INTO accrual (ac_id,
                                 ac_pc,
                                 ac_month,
                                 ac_assign_sum,
                                 ac_else_dn_sum,
                                 ac_st,
                                 history_status,
                                 com_org,
                                 ac_rc)
                SELECT 0,
                       ed_pc,
                       l_curr_month,
                       ed_sum,
                       NULL,
                       'E',
                       'A',
                       com_org,
                       NULL
                  FROM errand
                 WHERE ed_id = l_ed_id;

            SELECT MIN (ac_id)
              INTO l_ac_id
              FROM accrual, errand
             WHERE     ac_pc = ed_pc
                   AND ac_month = l_curr_month
                   AND ed_id = l_ed_id;
        END IF;

        --Пишемо операцію "ПОВЕРНЕННЯ ЗАЙВО УТРИМАНИХ СУМ ОТРИМУВАЧУ ДОПОМОГИ" та "СТЯГНЕННЯ ЗАЙВО УТРИМАНИХ СУМ З ОТРИМУВАЧА ВІДРАХУВАНЬ" в таблицю операцій
        INSERT INTO ac_detail (acd_id,
                               acd_ac,
                               acd_op,
                               acd_npt,
                               acd_start_dt,
                               acd_stop_dt,
                               acd_sum,
                               acd_dn,
                               acd_ac_start_dt,
                               acd_ac_stop_dt,
                               acd_st,
                               history_status,
                               acd_ed,
                               acd_pd)
            WITH
                sums
                AS
                    (  SELECT acd_npt AS q_npt, SUM (acd_sum) AS q_npt_sum
                         FROM ac_detail, tmp_work_ids4
                        WHERE acd_id = x_id
                     GROUP BY acd_npt)
            SELECT 0,
                   l_ac_id,
                   DECODE (x_tp, 1, 10, 11),
                   q_npt,
                   l_curr_month,
                   LAST_DAY (l_curr_month),
                   q_npt_sum,
                   x_id1,
                   l_curr_month,
                   LAST_DAY (l_curr_month),
                   'E',
                   'A',
                   l_ed_id,
                   x_id3
              FROM tmp_work_set3,
                   (    SELECT LEVEL     AS x_tp
                          FROM DUAL
                    CONNECT BY LEVEL < 3),
                   sums;

        --Проставляємо в проводки зайво стагнених сум посилання на Доручення, яким вони будуть "повернуті".
        UPDATE ac_detail
           SET acd_ed =
                   (SELECT x_id2
                      FROM tmp_work_set3
                     WHERE acd_dn = x_id1)
         WHERE acd_id IN (SELECT x_id FROM tmp_work_ids4);

        l_hs := TOOLS.GetHistSession;

        INSERT INTO ed_log (edl_id,
                            edl_ed,
                            edl_hs,
                            edl_st,
                            edl_message,
                            edl_st_old,
                            edl_tp)
            SELECT 0,
                   x_id2,
                   l_hs,
                   'E',
                   CHR (38) || '263',
                   NULL,
                   'SYS'
              FROM tmp_work_set3, errand
             WHERE x_id2 = ed_id;

        IF p_reason IS NOT NULL
        THEN
            INSERT INTO ed_log (edl_id,
                                edl_ed,
                                edl_hs,
                                edl_st,
                                edl_message,
                                edl_st_old,
                                edl_tp)
                SELECT 0,
                       x_id2,
                       l_hs,
                       'E',
                       p_reason,
                       NULL,
                       'SYS'
                  FROM tmp_work_set3, errand
                 WHERE x_id2 = ed_id;
        END IF;

        p_ed_id := l_ed_id;
    --!!! залишився децл - протягнути проводки такого доручення в відомість. Причому 10 в "вилату отримувачу", а 11 в "зменшення суми для DPP" (з контролем, аби не було менше 0).
    END;

    --Формування документу одноразової виплати "Повернення надміру утриманих сум" по проводкам повернення відрахування за сумами вже сплаченими закладу держутримання
    PROCEDURE init_errand_by_accrual (p_mode INTEGER) --1=Повернення зайво утриманих сум проводками 1 відрахування (ід-и проводок через tmp_work_ids4)
    IS
        l_cnt1    INTEGER;
        l_cnt2    INTEGER;
        l_hs      histsession.hs_id%TYPE := NULL;
        l_ed_id   errand.ed_id%TYPE;
        l_ac_id   accrual.ac_id%TYPE;
        --l_org personalcase.com_org%TYPE;
        --l_curr_month accrual.ac_month%TYPE;
        l_str     pc_decision.pd_num%TYPE;
    --g_messages TOOLS.t_messages := TOOLS.t_messages();
    BEGIN
        IF p_mode = 1
        THEN
            --SELECT MIN(pa_org) INTO l_org FROM pc_account, deduction, ac_detail, tmp_work_ids4 WHERE dn_pa = pa_id AND acd_id = x_id AND acd_dn = dn_id;
            --SELECT bp_month INTO l_curr_month FROM billing_period WHERE bp_tp = 'PR' AND bp_org = l_org AND bp_class = 'V' AND bp_st = 'R';

            SELECT                                 /*COUNT(DISTINCT acd_dn),*/
                   COUNT (*)
              INTO                                                 /*l_cnt1,*/
                   l_cnt2
              FROM tmp_work_ids4, ac_detail d, accrual
             WHERE     x_id = acd_id
                   AND acd_ac = ac_id
                   AND d.history_Status = 'A'
                   AND acd_op IN (33)
                   AND acd_dn IS NOT NULL   --тільки проводки по відрахуванням
                   AND acd_ed IS NULL; --тільки невключені в інші одноразові виплати

            IF l_cnt1 = 0
            THEN
                RETURN;
            END IF;
        ELSE
            raise_application_error (-20000, 'Режим не підтримується!');
        END IF;

        DELETE FROM tmp_work_set3
              WHERE 1 = 1;

        --Генеруємо ІД-и доручень
        INSERT INTO tmp_work_set3 (x_id1,
                                   x_id2,
                                   x_id3,
                                   x_sum1)
            SELECT x_dn,
                   id_errand (0),
                   x_pd,
                   x_sum
              FROM (  SELECT acd_dn            AS x_dn,
                             MAX (acd_pd)      AS x_pd,
                             SUM (acd_sum)     AS x_sum
                        FROM tmp_work_ids4,
                             ac_detail d,
                             deduction,
                             accrual
                       WHERE     x_id = acd_id
                             AND acd_ac = ac_id
                             AND acd_dn = dn_id
                             AND d.history_status = 'A'
                             AND acd_ed IS NULL
                             AND acd_op IN (33)
                    GROUP BY acd_dn);

        --Генеруємо № документів доручень
        UPDATE tmp_work_set3
           SET x_string1 = x_id2
         WHERE 1 = 1;

        --Створюємо реєстраційні записи доручень
        INSERT INTO errand (ed_id,
                            ed_pc,
                            com_org,
                            com_wu,
                            ed_ap,
                            ed_num,
                            ed_dt,
                            ed_st,
                            ed_sum,
                            ed_pay_tp,
                            ed_index,
                            ed_kaot,
                            ed_nb,
                            ed_account,
                            ed_street,
                            ed_ns,
                            ed_building,
                            ed_block,
                            ed_apartment,
                            ed_nd,
                            ed_pay_dt,
                            ed_scc,
                            ed_dn,
                            ed_tp,
                            ed_dpp)
            SELECT x_id2,
                   dn_pc,
                   pa_org                                       /*dn.com_org*/
                         ,
                   TOOLS.GetCurrWu,
                   NULL,
                   x_string1,
                   TRUNC (SYSDATE),
                   'E',
                   x_sum1,
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
                   NVL (
                       pdm_nb,
                       (SELECT MAX (nd_id)
                          FROM uss_ndi.v_ndi_post_office,
                               uss_ndi.v_ndi_delivery
                         WHERE     nd_npo = npo_id
                               AND npo_index = pdm_index
                               AND nd_code = '000')),
                   pdm_pay_dt,
                   NVL (pdm_scc,
                        NVL (pd_scc,
                             (SELECT sc_scc
                                FROM personalcase, uss_person.v_socialcard
                               WHERE pc_sc = sc_id AND pd_pc = pc_id))),
                   x_id1,
                   'RETPP',
                   dn_dpp
              FROM tmp_work_set3,
                   deduction      dn,
                   pd_pay_method  pdm,
                   pc_decision,
                   pc_account
             WHERE     x_id1 = dn_id
                   AND pdm_pd = x_id3
                   AND pd_id = x_id3
                   AND pdm_pd = pd_id
                   AND pdm.history_status = 'A'
                   AND pdm.pdm_is_actual = 'T'
                   AND dn_pa = pa_id;

        --Проставляємо в проводки надміру стагнених сум посилання на Доручення, яким вони будуть "повернуті".
        UPDATE ac_detail
           SET acd_ed =
                   (SELECT x_id2
                      FROM tmp_work_set3
                     WHERE acd_dn = x_id1)
         WHERE acd_id IN (SELECT x_id FROM tmp_work_ids4);

        l_hs := TOOLS.GetHistSession;

        INSERT INTO ed_log (edl_id,
                            edl_ed,
                            edl_hs,
                            edl_st,
                            edl_message,
                            edl_st_old,
                            edl_tp)
            SELECT 0,
                   x_id2,
                   l_hs,
                   'E',
                   CHR (38) || '263',
                   NULL,
                   'SYS'
              FROM tmp_work_set3, errand
             WHERE x_id2 = ed_id;
    END;


    PROCEDURE decision_rstopv_approve (p_at_id act.at_id%TYPE)
    IS
        l_act        act%ROWTYPE;
        l_ed_id      errand.ed_id%TYPE;
        l_rnp_tp     VARCHAR2 (10);
        l_rnp_code   VARCHAR2 (10);
        l_hs         histsession.hs_id%TYPE := NULL;
        l_lock       TOOLS.t_lockhandler;
    BEGIN
        --l_lock := TOOLS.request_lock(p_descr => 'decision_rstopv_approve_'||p_at_id, p_error_msg => 'В даний момент вже виконується підтвердження рішення про припинення послуг!');

        SELECT *
          INTO l_act
          FROM act
         WHERE at_id = p_at_id AND at_tp = 'RSTOPV';

        SELECT rnp_pnp_tp, rnp_code
          INTO l_rnp_tp, l_rnp_code
          FROM uss_ndi.v_ndi_reason_not_pay
         WHERE rnp_id = l_act.at_rnp;

        DBMS_OUTPUT.put_line ('l_rnp_code=' || l_rnp_code);

        --Проставляємо новий стан рішенню. Редагується -> Проект, Проект -> Затверджене
        UPDATE act
           SET at_st = DECODE (at_st,  'E', 'P',  'P', 'Z')
         WHERE at_id = p_at_id AND at_tp = 'RSTOPV' AND at_st IN ('E', 'P');

        IF SQL%ROWCOUNT > 0
        THEN
            write_at_log (
                p_at_id,
                NULL,
                CASE l_act.at_st WHEN 'E' THEN 'P' WHEN 'P' THEN 'Z' END,
                CHR (38) || '214',
                l_act.at_st);

            --Якщо рішення про припинення виплати допомог затверджується, то формуємо заготовку доручення про одноразову виплату
            IF l_act.at_st = 'P'
            THEN
                --!!! Припинення рішень про надання послуг  !!!
                DELETE FROM tmp_work_ids1
                      WHERE 1 = 1;

                INSERT INTO tmp_work_ids1 (x_id)
                    SELECT pd_id
                      FROM pc_decision, act
                     WHERE     at_pc = pd_pc
                           AND pd_nst IN (664,
                                          248,
                                          249,
                                          265,
                                          267,
                                          268,
                                          269)
                           AND at_id = p_at_id
                           AND at_st = 'Z'
                           AND (   pd_st = 'S' --призупиняємо всі діючі рішення
                                OR EXISTS
                                       (SELECT 1
                                          FROM pd_accrual_period pdap
                                         WHERE     pdap_pd = pd_id
                                               AND pdap.history_status = 'A'
                                               AND (   LAST_DAY (at_dt) + 1 <=
                                                       pdap_stop_dt --перепризупиняємо всі рішення, які діють після першого числа місяця, що слідує за датою рішення
                                                    OR (    l_rnp_code =
                                                            'AT_AZD'
                                                        AND LAST_DAY (at_dt) =
                                                            pdap_stop_dt))));

                l_hs := TOOLS.GetHistSession;

                DELETE FROM tmp_pc_block
                      WHERE 1 = 1;

                INSERT INTO tmp_pc_block (b_id,
                                          b_pc,
                                          b_pd,
                                          b_tp,
                                          b_rnp,
                                          b_locl_pnp_tp,
                                          b_hs_lock,
                                          b_ap_src,
                                          b_dt,
                                          b_at_src)
                    SELECT 0,
                           pd_pc,
                           pd_id,
                           'RPP'
                               AS x_pcb_tp,
                           CASE
                               WHEN rnp_code = 'AT_AZD'
                               THEN
                                   NVL (
                                       (SELECT MIN (rnp_id)
                                          FROM uss_ndi.v_ndi_reason_not_pay
                                         WHERE     rnp_class = 'PAY'
                                               AND rnp_code = 'AT_AZD'
                                               AND rnp_pay_tp =
                                                   (SELECT pdm_pay_tp
                                                      FROM pd_pay_method r
                                                     WHERE     pdm_pd = pd_id
                                                           AND r.history_status =
                                                               'A'
                                                           AND pdm_is_actual =
                                                               'T')),
                                       at_rnp)
                               ELSE
                                   at_rnp
                           END,
                           rnp_pnp_tp,
                           l_hs,
                           at_ap,
                           LAST_DAY (at_dt),
                           at_id
                      FROM tmp_work_ids1,
                           pc_decision,
                           act,
                           uss_ndi.v_ndi_reason_not_pay
                     WHERE     x_id = pd_id
                           AND at_id = p_at_id
                           AND at_rnp = rnp_id
                           AND at_pc = pd_pc;

                API$PC_BLOCK.decision_block (l_hs);

                FOR xx IN (SELECT DISTINCT pd_id, pd_st
                             FROM tmp_pc_block, pc_decision
                            WHERE b_pd = pd_id)
                LOOP
                    API$PC_DECISION.write_pd_log (
                        xx.pd_id,
                        l_hs,
                        xx.pd_st,
                        CHR (38) || '235#' || l_act.at_num,
                        xx.pd_st);
                END LOOP;

                INSERT INTO pd_reject_info (pri_id,
                                            pri_nrr,
                                            pri_njr,
                                            pri_pd)
                    SELECT 0,
                           NULL,
                           502,
                           pd_id
                      FROM pc_decision, act
                     WHERE     at_pc = pd_pc
                           AND pd_nst IN (664,
                                          248,
                                          249,
                                          265,
                                          267,
                                          268,
                                          269)
                           AND at_id = p_at_id
                           AND at_st = 'Z'
                           AND pd_st NOT IN ('S', 'PS', 'V'); --робимо відмову всм рішенням по справі, що знаходяться не в статусах Нараховано/Призупинено

                UPDATE pc_decision
                   SET pd_hs_reject = l_hs, pd_st = 'V'
                 WHERE pd_id IN (SELECT pd_id
                                   FROM pc_decision, act
                                  WHERE     at_pc = pd_pc
                                        AND pd_nst IN (664,
                                                       248,
                                                       249,
                                                       265,
                                                       267,
                                                       268,
                                                       269)
                                        AND at_id = p_at_id
                                        AND at_st = 'Z'
                                        AND pd_st NOT IN ('S', 'PS', 'V'));

                init_errand_by_acts_923 (1, p_at_id, l_ed_id);
            END IF;
        ELSE
            raise_application_error (
                -20000,
                'В функцію підтвердження рішення про припинення надання послуг не передано рішень в станах Редагується та Підтверджено!');
        END IF;
    END;

    PROCEDURE decision_rstopv_return (p_at_id    act.at_id%TYPE,
                                      p_reason   VARCHAR2 DEFAULT NULL)
    IS
        l_act    act%ROWTYPE;
        l_cnt    INTEGER;
        l_lock   TOOLS.t_lockhandler;
    BEGIN
        l_lock :=
            TOOLS.request_lock (
                p_descr   => 'decision_rstopv_return_' || p_at_id,
                p_error_msg   =>
                    'В даний момент вже виконується повернення рішення про припинення послуг!');

        SELECT *
          INTO l_act
          FROM act
         WHERE at_id = p_at_id AND at_tp = 'RSTOPV';

        UPDATE act
           SET at_st = DECODE (at_st,  'P', 'E',  'E', 'W')
         WHERE at_id = p_at_id AND at_tp = 'RSTOPV' AND at_st IN ('P', 'E');

        l_cnt := SQL%ROWCOUNT;

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'В функцію повернення рішень про припинення надання послуг не передано рішення!');
        ELSE
            write_at_log (
                p_at_id,
                NULL,
                CASE l_act.at_st WHEN 'P' THEN 'E' WHEN 'E' THEN 'W' END,
                CHR (38) || '215',
                l_act.at_st);

            IF p_reason IS NOT NULL
            THEN
                write_at_log (
                    p_at_id,
                    NULL,
                    CASE l_act.at_st WHEN 'P' THEN 'E' WHEN 'E' THEN 'W' END,
                    p_reason,
                    l_act.at_st,
                    'USR');
            END IF;

            IF l_act.at_st = 'E' AND l_act.at_ap IS NOT NULL
            THEN
                Dnet$pay_Assignments.return_appeal (l_act.at_ap, p_reason);
            END IF;
        END IF;
    END;

    PROCEDURE decision_rstopv_reject (p_at_id act.at_id%TYPE)
    IS
        l_act    act%ROWTYPE;
        l_cnt    INTEGER;
        l_lock   TOOLS.t_lockhandler;
    BEGIN
        l_lock :=
            TOOLS.request_lock (
                p_descr   => 'decision_rstopv_reject_' || p_at_id,
                p_error_msg   =>
                    'В даний момент вже виконується відмова рішення про припинення послуг!');

        SELECT *
          INTO l_act
          FROM act
         WHERE at_id = p_at_id AND at_tp = 'RSTOPV';

        UPDATE act
           SET at_st = DECODE (at_st, 'P', 'O')
         WHERE at_id = p_at_id AND at_tp = 'RSTOPV' AND at_st IN ('P');

        l_cnt := SQL%ROWCOUNT;

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'В функцію відміни рішень про припинення надання послуг не передано звернення!');
        ELSE
            write_at_log (p_at_id,
                          NULL,
                          'E',
                          CHR (38) || '216',
                          l_act.at_st);
        END IF;
    END;


    PROCEDURE errand_recalc (p_ed_id errand.ed_id%TYPE)
    IS
        l_sum        errand.ed_sum%TYPE;
        l_ed         errand%ROWTYPE;
        l_cnt        INTEGER;
        l_messages   SYS_REFCURSOR;
        l_start_dt   DATE;
    BEGIN
        SELECT *
          INTO l_ed
          FROM errand
         WHERE ed_id = p_ed_id;

        IF l_ed.ed_st <> 'E'
        THEN
            raise_application_error (
                -20000,
                'Розрахунок суми доручення на разову виплату не можна виконувати не в стані "Редагується"!');
        END IF;

        IF l_ed.ed_tp <> 'DEATH'
        THEN
            raise_application_error (
                -20000,
                'Розрахунок суми доручення на разову виплату можна виконувати тільки для для документів типу "Одноразова виплата у зв`язку з смертю одержувача"!');
        END IF;

        --Скидаємо посилання на доручення
        UPDATE ac_detail
           SET acd_ed = NULL
         WHERE acd_ed = p_ed_id;

        --Ставимо в чергу на розрахунок
        SELECT ADD_MONTHS (TRUNC (at_dt, 'MM'), -3)
          INTO l_start_dt
          FROM act
         WHERE at_id = l_ed.ed_at;

        SELECT COUNT (*)
          INTO l_cnt
          FROM pc_accrual_queue
         WHERE     paq_pc = l_ed.ed_pc
               AND paq_st = 'W'
               AND paq_start_dt <= l_start_dt;

        IF l_cnt = 0
        THEN
            API$PERSONALCASE.add_pc_accrual_queue (l_ed.ed_pc,
                                                   'ED',
                                                   l_start_dt,
                                                   NULL,
                                                   p_ed_id,
                                                   NULL);
        END IF;

        --Виконуємо нарахування "останнього шансу" - якщо не було виконано раніше, щось нарахується по призупиненим рішенням
        API$ACCRUAL.calc_accrual (1,
                                  1,
                                  l_ed.ed_pc,
                                  NULL,
                                  l_messages);

        --Знаходимо проводки, які можна виплатити разовим дорученням (не включені в інші доручення)
        INSERT INTO tmp_work_ids4 (x_id)
            SELECT acd_id
              FROM ac_detail acd, accrual
             WHERE     ac_pc = l_ed.ed_pc
                   AND acd_ac = ac_id
                   AND acd_npt IN
                           (SELECT npt_id
                              FROM uss_ndi.v_ndi_payment_type   t,
                                   uss_ndi.v_ndi_npt_ed_config  nedc
                             WHERE     npt_id = nedc_npt
                                   AND nedc_ed_tp = l_ed.ed_tp
                                   AND nedc.history_status = 'A'
                                   AND l_ed.ed_dt >= nedc_start_dt
                                   AND (   l_ed.ed_dt <= nedc_stop_dt
                                        OR nedc_stop_dt IS NULL))
                   AND acd_op IN (SELECT op_id
                                    FROM uss_ndi.v_ndi_op
                                   WHERE op_tp1 IN ('NR', 'DN'))
                   AND acd.history_status = 'A'
                   AND acd_prsd IS NULL
                   AND acd_imp_pr_num IS NULL
                   AND acd_ed IS NULL;

        l_cnt := SQL%ROWCOUNT;

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'Не знайдено невиплачених сум нарахувань!');
        END IF;

        --Знаходимо повну суму доручення
        SELECT SUM (acd_sum * API$ACCTOOLS.xsign (acd_op))
          INTO l_sum
          FROM ac_detail, tmp_work_ids4
         WHERE acd_id = x_id;

        --Маркуємо рядки нарахувань документом доручення
        UPDATE ac_detail
           SET acd_ed = p_ed_id
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_work_ids4
                     WHERE acd_id = x_id);

        UPDATE errand
           SET ed_sum = l_sum
         WHERE ed_id = p_ed_id AND ed_st = 'E';

        write_ed_log (p_ed_id,
                      NULL,
                      l_ed.ed_st,
                      CHR (38) || '220#' || l_sum,
                      l_ed.ed_st);
    --  raise_application_error(-20000, 'errand_recalc в розробці!');
    END;

    PROCEDURE errand_approve (p_ed_id errand.ed_id%TYPE)
    IS
        l_ed     errand%ROWTYPE;
        l_cnt    INTEGER;
        l_sum    ac_detail.acd_sum%TYPE;
        l_lock   TOOLS.t_lockhandler;
        l_ac     accrual%ROWTYPE;
    BEGIN
        l_lock :=
            TOOLS.request_lock (
                p_descr   => 'errand_approve_' || p_ed_id,
                p_error_msg   =>
                    'В даний момент вже виконується підтвердження доручення!');

        SELECT *
          INTO l_ed
          FROM errand
         WHERE ed_id = p_ed_id;

        IF l_ed.ed_st NOT IN ('E', 'P')
        THEN
            raise_application_error (
                -20000,
                'Підтверджувати можна тільки доручення в стані "Редагується"!');
        END IF;

        IF l_ed.ed_sum IS NULL OR l_ed.ed_sum <= 0
        THEN
            raise_application_error (
                -20000,
                'Не розраховано суму доручення: виконайте розрахунок суми доручення!');
        END IF;

        IF l_ed.ed_tp = 'DEATH' AND l_ed.ed_st = 'P'
        THEN --Для доручнь по смерті переводимо нарахування в "Діюче" при переведенні доручення в "Діюче".
            SELECT COUNT (*), SUM (acd_sum * API$ACCTOOLS.xsign (acd_op))
              INTO l_cnt, l_sum
              FROM ac_detail
             WHERE acd_ed = p_ed_id AND history_Status = 'A';

            IF    l_cnt = 0
               OR l_sum IS NULL
               OR l_sum <= 0
               OR l_ed.ed_sum != l_sum
            THEN
                raise_application_error (
                    -20000,
                    'Сума доручення розрахована некоректно: виконайте розрахунок суми доручення повторно!');
            END IF;
        END IF;

        UPDATE errand
           SET ed_st = DECODE (ed_st,  'E', 'P',  'P', 'R')
         WHERE ed_id = p_ed_id AND ed_st IN ('E', 'P');

        l_cnt := SQL%ROWCOUNT;

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'В функцію підтвердження доручення не передано доручення в стані "Редагується" або "Підтверджено"!');
        ELSE
            IF l_ed.ed_tp = 'DEATH' AND l_ed.ed_st = 'P'
            THEN --Для доручнь по смерті переводимо нарахування в "Діюче" при переведенні доручення в "Діюче".
                BEGIN
                    SELECT *
                      INTO l_ac
                      FROM accrual
                     WHERE ac_id =
                           (SELECT MAX (acd_ac)
                              FROM ac_detail sl
                             WHERE     sl.history_status = 'A'
                                   AND acd_ed = p_ed_id);

                    --Підтверджуємо перший раз зі всіх станів, де непідтверджене
                    IF l_ac.ac_st IN ('E',
                                      'RV',
                                      'RP',
                                      'W')
                    THEN
                        API$ACCRUAL.approve_accrual (l_ac.ac_id);
                    END IF;

                    --Підтверджуємо другий раз з "Редагується" (бо для всіх інших станів воно вже повинно бути Діюче).
                    IF l_ac.ac_st IN ('E')
                    THEN
                        API$ACCRUAL.approve_accrual (l_ac.ac_id);
                    END IF;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        NULL;
                END;
            END IF;

            write_ed_log (
                p_ed_id,
                NULL,
                CASE l_ed.ed_st WHEN 'E' THEN 'P' WHEN 'P' THEN 'R' END,
                CHR (38) || '217',
                l_ed.ed_st);
        END IF;
    END;

    PROCEDURE errand_reject (p_ed_id    errand.ed_id%TYPE,
                             p_ed_rnp   errand.ed_rnp%TYPE)
    IS
        l_ed     errand%ROWTYPE;
        l_cnt    INTEGER;
        l_lock   TOOLS.t_lockhandler;
    BEGIN
        l_lock :=
            TOOLS.request_lock (
                p_descr   => 'errand_reject_' || p_ed_id,
                p_error_msg   =>
                    'В даний момент вже виконується відмова доручення!');

        SELECT *
          INTO l_ed
          FROM errand
         WHERE ed_id = p_ed_id;

        IF l_ed.ed_st <> 'E'
        THEN
            raise_application_error (
                -20000,
                'Відхиляти можна тільки доручення в стані "Редагується"!');
        END IF;

        --  IF l_ed.ed_tp = 'RETPP' THEN
        --    raise_application_error(-20000, 'Не можна відхиляти доручення типу "Повернення надміру стягнених суп по держутриманню"!');
        --  END IF;

        UPDATE errand
           SET ed_st = DECODE (ed_st, 'E', 'V'), ed_rnp = p_ed_rnp
         WHERE ed_id = p_ed_id AND ed_st IN ('E');

        l_cnt := SQL%ROWCOUNT;

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'В функцію відхилення доручення не передано доручення в стані "Редагується"!');
        ELSE
            IF l_ed.ed_tp = 'RETDN'
            THEN --Видаляємо проводки по операціям 10/11 для одноразових виплат повернення зайво стягнених коштів
                DELETE FROM uss_esr.ac_detail
                      WHERE acd_op IN (10, 11) AND acd_ed = p_ed_id;
            ELSIF l_ed.ed_tp = 'DEATH'
            THEN --Скидаємо посилання на документ разового доручення по смерті в операціях нарахувань.
                UPDATE ac_detail
                   SET acd_ed = NULL
                 WHERE acd_ed = p_ed_id;
            ELSIF l_ed.ed_tp = 'RETPP'
            THEN --Для доручень повернення зайво стягнених відрахуваннь по держутриманню - нічого не робимо. Таке роблять підчас перерозподілу між кодами імпортованих сум
                NULL;
            END IF;

            write_ed_log (p_ed_id,
                          NULL,
                          'V',
                          CHR (38) || '218',
                          l_ed.ed_st);
        END IF;
    END;

    PROCEDURE errand_return (p_ed_id errand.ed_id%TYPE, p_reason VARCHAR2)
    IS
        l_ed     errand%ROWTYPE;
        l_cnt    INTEGER;
        l_lock   TOOLS.t_lockhandler;
    BEGIN
        l_lock :=
            TOOLS.request_lock (
                p_descr   => 'errand_return_' || p_ed_id,
                p_error_msg   =>
                    'В даний момент вже виконується повернення доручення!');

        SELECT *
          INTO l_ed
          FROM errand
         WHERE ed_id = p_ed_id;

        IF l_ed.ed_st NOT IN ('P', 'R')
        THEN
            raise_application_error (
                -20000,
                'Повертати можна тільки доручення в стані "Підтверджено" або "Діюче" (за відсутності виплати по доручненю)! Разове доручення на виплаті (у виплатних відомостях) - не можна повертати для редагування!');
        END IF;

        UPDATE errand
           SET ed_st = DECODE (ed_st,  'P', 'E',  'R', 'P')
         WHERE     ed_id = p_ed_id
               AND ed_st IN ('P', 'R')
               AND NOT EXISTS
                       (SELECT 1
                          FROM ac_detail d
                         WHERE     acd_ed = ed_id
                               AND acd_prsd IS NOT NULL
                               AND d.history_status = 'A'
                               AND acd_op IN (10, 33));

        l_cnt := SQL%ROWCOUNT;

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'В функцію повернення доручення не передано доручення в стані "Підтверджено" або "Діюче" (за відсутності виплати по доручненю)! Разове доручення на виплаті (у виплатних відомостях) - не можна повертати для редагування!');
        ELSE
            write_ed_log (
                p_ed_id,
                NULL,
                CASE l_ed.ed_st WHEN 'P' THEN 'E' WHEN 'R' THEN 'P' END,
                CHR (38) || '218',
                l_ed.ed_st);

            IF p_reason IS NOT NULL
            THEN
                write_ed_log (
                    p_ed_id,
                    NULL,
                    CASE l_ed.ed_st WHEN 'P' THEN 'E' WHEN 'R' THEN 'P' END,
                    p_reason,
                    l_ed.ed_st,
                    'USR');
            END IF;
        END IF;
    END;
BEGIN
    NULL;
END API$ERRAND;
/