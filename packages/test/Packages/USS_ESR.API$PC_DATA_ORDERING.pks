/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$PC_DATA_ORDERING
IS
    -- Author  : VANO
    -- Created : 01.12.2022 15:11:35
    -- Purpose : Функції обробки впорядкування даних АСПОД

    PROCEDURE process_pc_data_ordering (
        p_pco_id   pc_data_ordering.pco_id%TYPE);
END API$PC_DATA_ORDERING;
/


/* Formatted on 8/12/2025 5:49:08 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$PC_DATA_ORDERING
IS
    PROCEDURE write_pco_log (p_pcol_pco       pco_log.pcol_pco%TYPE,
                             p_pcol_hs        pco_log.pcol_hs%TYPE,
                             p_pcol_st        pco_log.pcol_st%TYPE,
                             p_pcol_message   pco_log.pcol_message%TYPE,
                             p_pcol_st_old    pco_log.pcol_st_old%TYPE,
                             p_pcol_tp        pco_log.pcol_tp%TYPE:= 'SYS')
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        --l_hs := NVL(p_pcol_hs, TOOLS.GetHistSession);
        l_hs := p_pcol_hs;

        IF l_hs IS NULL
        THEN
            l_hs := TOOLS.GetHistSession;
        END IF;

        INSERT INTO pco_log (pcol_id,
                             pcol_pco,
                             pcol_hs,
                             pcol_st,
                             pcol_message,
                             pcol_st_old,
                             pcol_tp)
             VALUES (0,
                     p_pcol_pco,
                     l_hs,
                     p_pcol_st,
                     p_pcol_message,
                     p_pcol_st_old,
                     NVL (p_pcol_tp, 'SYS'));
    END;

    PROCEDURE process_pc_data_ordering (
        p_pco_id   pc_data_ordering.pco_id%TYPE)
    IS
        l_pco      pc_data_ordering%ROWTYPE;
        l_sum      pc_data_ordering.pco_new_acd_sum%TYPE;
        l_pdp_id   pd_payment.pdp_id%TYPE;
        l_hs       histsession.hs_id%TYPE;
        l_cnt      INTEGER;
    BEGIN
        --  raise_application_error(-20000, 'Внесення змін в призначене та нараховане щодо впорядкування даних ВПО - не реалізоване поки що.');

        BEGIN
            SELECT *
              INTO l_pco
              FROM pc_data_ordering
             WHERE pco_id = p_pco_id AND pco_st = 'N';
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                raise_application_error (
                    -20000,
                    'Впорадякування даного випадку вже виконано або не передано реєстраційного запису.');
        END;

        --11 В призначено пишемо суму нарахованого
        IF     l_pco.pco_decision_tp = '11'
           AND (l_pco.pco_fix_acd_sum IS NULL OR l_pco.pco_fix_acd_sum <= 0)
        THEN
            raise_application_error (
                -20000,
                '11> Некоректно вказано зафіксовану суму нарахувань! Повинна бути більша або рівна за 0.');
        END IF;

        --12 В призначене пишемо 0
        --13 Призначене відрізняється від нарахованого
        IF     l_pco.pco_decision_tp = '13'
           AND (l_pco.pco_new_pdp_sum IS NULL OR l_pco.pco_new_pdp_sum <= 0)
        THEN
            raise_application_error (
                -20000,
                '13> Некоректно вказано нову сумму призначеного! Повинна бути більша за 0.');
        END IF;

        --14 Сума нарахованого неправильна
        IF     l_pco.pco_decision_tp = '14'
           AND (l_pco.pco_new_acd_sum IS NULL OR l_pco.pco_new_acd_sum < 0)
        THEN
            raise_application_error (
                -20000,
                '14> Некоректно вказано нову сумму нарахування! Повинна бути більша або рівна 0.');
        END IF;

        SELECT SUM (pcod_new_acd_sum)
          INTO l_sum
          FROM pco_detail
         WHERE pcod_pco = p_pco_id;

        IF     l_pco.pco_decision_tp = '14'
           AND (l_sum <> l_pco.pco_new_acd_sum OR l_sum IS NULL)
        THEN
            raise_application_error (
                -20000,
                '14> Сума нарахування з рядків не дорівнює сумі нарахування з шапки. Виправте, будь-ласка!');
        END IF;

        --21 В призначено пишемо суму нарахованого
        IF     l_pco.pco_decision_tp = '21'
           AND (l_pco.pco_fix_acd_sum IS NULL OR l_pco.pco_fix_acd_sum <= 0)
        THEN
            raise_application_error (
                -20000,
                '21> Некоректно вказано зафіксовану суму нарахувань! Повинна бути більша або рівна за 0.');
        END IF;

        --221 Сума призначеного та нарахованого правильні
        --222 Сума призначеного та нарахованого неправильні
        IF     l_pco.pco_decision_tp = '222'
           AND (l_pco.pco_new_pdp_sum IS NULL OR l_pco.pco_new_pdp_sum <= 0)
        THEN
            raise_application_error (
                -20000,
                '222> Некоректно вказано нову сумму призаченого! Повинна бути більша або рівна 0.');
        END IF;

        IF     l_pco.pco_decision_tp = '222'
           AND (l_sum <> l_pco.pco_new_acd_sum OR l_sum IS NULL)
        THEN
            raise_application_error (
                -20000,
                '222> Сума нарахування з рядків не дорівнює сумі нарахування з шапки. Виправте, будь-ласка!');
        END IF;

        SELECT COUNT (*)
          INTO l_sum
          FROM pco_detail, ac_detail
         WHERE     pcod_pco = p_pco_id
               AND pcod_fix_acd = acd_id
               AND history_status = 'H';

        IF l_sum > 0
        THEN
            raise_application_error (
                -20000,
                '00> Спроба виправити історичні (логічно видалені) дані - між формуванням даних для виправленя та даною дією виконані якісь чутливі дії!');
        END IF;

        --Не обрано коректне рішення для дублікатів періодів по рішенням
        SELECT COUNT (*)
          INTO l_cnt
          FROM pco_detail
         WHERE pcod_pco = p_pco_id AND pcod_is_correct = 'T';

        IF l_pco.pco_decision_tp = '31' AND (l_cnt = 0 OR l_cnt > 1)
        THEN
            raise_application_error (-20000,
                                     '31> Не обрано коректне рішення!');
        END IF;

        --Кількість дублікатів не відповідає зафіксованій кількості
        SELECT COUNT (*)
          INTO l_cnt
          FROM pco_detail, pd_accrual_period
         WHERE     pdap_pd = pcod_pd
               AND history_status = 'A'
               AND pcod_pco = p_pco_id
               AND l_pco.pco_month BETWEEN pdap_start_dt AND pdap_stop_dt;

        SELECT COUNT (*)
          INTO l_sum
          FROM pco_detail
         WHERE pcod_pco = p_pco_id;

        IF l_pco.pco_decision_tp = '31' AND (l_cnt <> l_sum)
        THEN
            raise_application_error (
                -20000,
                '31> З часу фіксації проблеми відбулись зміни в строках дії рішень! Можливо, проблема вирішена штатними методами.');
        END IF;

        IF    (    l_pco.pco_tp = 'AWP'
               AND l_pco.pco_decision_tp IN ('11',
                                             '12',
                                             '13',
                                             '14'))
           OR (    l_pco.pco_tp = 'PNEA'
               AND l_pco.pco_decision_tp IN ('21', '221', '222'))
        THEN
            DELETE FROM tmp_work_set2
                  WHERE 1 = 1;

            INSERT INTO tmp_work_set2 (x_id1,
                                       x_id2,
                                       x_id3,
                                       x_dt1,
                                       x_dt2,
                                       x_sum1,
                                       x_sum2)
                SELECT pdp_id,
                       pdp_pd,
                       pdp_npt,
                       pdp_start_dt,
                       pdp_stop_dt,
                       pdp_sum,
                       l_pco.pco_new_pdp_sum
                  FROM pd_payment pdp
                 WHERE     pdp_pd = l_pco.pco_pd
                       AND pdp_npt = l_pco.pco_npt
                       AND pdp.history_status = 'A';

            --D1..D2--перетворюємо в
            --D1..pco_month-1,  pco_month..lastday(pco_month),  addmonth(pco_month, 1)..D2

            --Визначаємо необхідність обмеження запису PDP зліва
            UPDATE tmp_work_set2
               SET x_string1 = '+'
             WHERE l_pco.pco_month > x_dt1 AND l_pco.pco_month <= x_dt2;

            --Визначаємо необхідність обмеження запису PDP зправа (+) і нового запису, обмеженого зправа, якщо це той же, що обмежений зліва
            UPDATE tmp_work_set2
               SET x_string2 = DECODE (x_string1, '+', '++', '+')
             WHERE     LAST_DAY (l_pco.pco_month) >= x_dt1
                   AND LAST_DAY (l_pco.pco_month) < x_dt2;

            --Визначаємо необхідність просто видалення запису PDP, якщо він повністю всередині pco_month..lastday(pco_month)
            UPDATE tmp_work_set2
               SET x_string1 = '-', x_string2 = '-'
             WHERE     x_dt1 BETWEEN l_pco.pco_month
                                 AND LAST_DAY (l_pco.pco_month)
                   AND x_dt2 BETWEEN l_pco.pco_month
                                 AND LAST_DAY (l_pco.pco_month);

            IF l_pco.pco_decision_tp IN ('11', '21')
            THEN
                l_pco.pco_new_pdp_sum := l_pco.pco_fix_acd_sum;
            ELSIF l_pco.pco_decision_tp = '12'
            THEN
                l_pco.pco_new_pdp_sum := 0;
            END IF;

            IF l_pco.pco_decision_tp IN ('11',
                                         '12',
                                         '13',
                                         '21',
                                         '222')
            THEN
                --Обмежуємо запис зліва
                UPDATE pd_payment pdp
                   SET pdp_stop_dt = l_pco.pco_month - 1
                 WHERE     EXISTS
                               (SELECT 1
                                  FROM tmp_work_set2
                                 WHERE pdp_id = x_id1 AND x_string1 = '+')
                       AND pdp.history_status = 'A';

                --Обмежуємо запис зправа
                UPDATE pd_payment pdp
                   SET pdp_start_dt = ADD_MONTHS (l_pco.pco_month, 1)
                 WHERE     EXISTS
                               (SELECT 1
                                  FROM tmp_work_set2
                                 WHERE pdp_id = x_id1 AND x_string2 = '+')
                       AND pdp.history_status = 'A';

                UPDATE tmp_work_set2
                   SET x_id4 = id_pd_payment (0)
                 WHERE x_string2 = '++';

                --Створюємо новий запис призначеного зліва, якщо ми розрізаємо запис
                INSERT INTO pd_payment (pdp_id,
                                        pdp_pd,
                                        pdp_npt,
                                        pdp_start_dt,
                                        pdp_stop_dt,
                                        pdp_sum,
                                        history_status,
                                        pdp_hs_ins)
                    SELECT x_id4,
                           x_id2,
                           x_id3,
                           ADD_MONTHS (l_pco.pco_month, 1),
                           x_dt2,
                           x_sum1,
                           'A',
                           l_hs
                      FROM tmp_work_set2
                     WHERE x_string2 = '++';

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
                           x_id4,
                           pdd_row_order,
                           pdd_row_name,
                           pdd_value,
                           pdd_key,
                           pdd_ndp,
                           ADD_MONTHS (l_pco.pco_month, 1),
                           pdd_stop_dt
                      FROM pd_payment pdp, tmp_work_set2, pd_detail
                     WHERE     pdp_pd = x_id2
                           AND pdp_npt = x_id3
                           AND pdp_start_dt = x_dt1
                           AND x_string2 = '++'
                           AND pdd_pdp = pdp_id
                           AND pdp.history_status = 'A';

                /*      DELETE
                        FROM pd_detail
                        WHERE EXISTS (SELECT 1 FROM tmp_work_set2 WHERE pdd_pdp = x_id1 AND x_string1 = '-');

                      DELETE
                        FROM pd_payment
                        WHERE EXISTS (SELECT 1 FROM tmp_work_set2 WHERE pdp_id = x_id1 AND x_string1 = '-');*/

                UPDATE pd_payment pdp
                   SET history_Status = 'H', pdp_hs_del = l_hs
                 WHERE     EXISTS
                               (SELECT 1
                                  FROM tmp_work_set2
                                 WHERE pdp_id = x_id1 AND x_string1 = '-')
                       AND pdp.history_status = 'A';

                --Вставляємо в призначене на відповідний місяць суму нарахування
                INSERT INTO pd_payment (pdp_id,
                                        pdp_pd,
                                        pdp_npt,
                                        pdp_start_dt,
                                        pdp_stop_dt,
                                        pdp_sum,
                                        history_status,
                                        pdp_hs_ins)
                     VALUES (0,
                             l_pco.pco_pd,
                             l_pco.pco_npt,
                             l_pco.pco_month,
                             LAST_DAY (l_pco.pco_month),
                             l_pco.pco_new_pdp_sum,
                             'A',
                             l_hs)
                  RETURNING pdp_id
                       INTO l_pdp_id;

                INSERT INTO pd_detail (pdd_id,
                                       pdd_pdp,
                                       pdd_row_order,
                                       pdd_row_name,
                                       pdd_value,
                                       pdd_key,
                                       pdd_ndp,
                                       pdd_start_dt,
                                       pdd_stop_dt)
                     VALUES (0,
                             l_pdp_id,
                             290,
                             NULL,
                             l_pco.pco_new_pdp_sum,
                             NULL,
                             290,
                             l_pco.pco_month,
                             LAST_DAY (l_pco.pco_month));
            END IF;

            IF l_pco.pco_decision_tp IN ('14', '222')
            THEN          --Записуємо в нарахування суми коригувань порядково.
                INSERT INTO tmp_work_set3 (x_id1)
                    SELECT pcod_id
                      FROM pco_detail
                     WHERE     pcod_pco = l_pco.pco_id
                           AND pcod_fix_acd_sum <> pcod_new_acd_sum;

                UPDATE tmp_work_set3
                   SET x_id2 = id_ac_detail (0)
                 WHERE 1 = 1;

                INSERT INTO ac_detail (acd_id,
                                       acd_ac,
                                       acd_op,
                                       acd_npt,
                                       acd_start_dt,
                                       acd_stop_dt,
                                       acd_sum,
                                       acd_month_sum,
                                       acd_delta_recalc,
                                       acd_pd,
                                       acd_ac_start_dt,
                                       acd_ac_stop_dt,
                                       acd_is_indexed,
                                       acd_st,
                                       history_status,
                                       acd_payed_sum,
                                       acd_imp_pr_num,
                                       acd_dn)
                    SELECT x_id2,
                           acd_ac,
                           CASE
                               WHEN pcod_fix_acd_sum < pcod_new_acd_sum
                               THEN
                                   2
                               ELSE
                                   3
                           END,
                           acd_npt,
                           acd_start_dt,
                           acd_stop_dt,
                           ABS (pcod_fix_acd_sum - pcod_new_acd_sum),
                           pcod_new_acd_sum,
                           DECODE (
                               l_pco.pco_is_need_pay,
                               'T', ABS (pcod_fix_acd_sum - pcod_new_acd_sum)),
                           acd_pd,
                           acd_ac_start_dt,
                           acd_ac_stop_dt,
                           acd_is_indexed,
                           acd_st,
                           history_status,
                           DECODE (l_pco.pco_is_need_pay,
                                   'T', NULL,
                                   ABS (pcod_fix_acd_sum - pcod_new_acd_sum)),
                           DECODE (l_pco.pco_is_need_pay, 'T', NULL, '999'),
                           acd_dn
                      FROM ac_detail, pco_detail, tmp_work_set3
                     WHERE     acd_id = pcod_fix_acd
                           AND pcod_fix_acd_sum <> pcod_new_acd_sum
                           AND pcod_pco = l_pco.pco_id
                           AND pcod_id = x_id1;

                UPDATE pco_detail
                   SET pcod_new_acd =
                           (SELECT x_id2
                              FROM tmp_work_set3
                             WHERE x_id1 = pcod_id)
                 WHERE EXISTS
                           (SELECT 1
                              FROM tmp_work_set3
                             WHERE x_id1 = pcod_id);

                IF    l_pco.pco_is_need_pay = 'F'
                   OR l_pco.pco_is_need_pay IS NULL
                THEN
                    UPDATE ac_detail z
                       SET z.acd_imp_pr_num = '999'
                     WHERE     EXISTS
                                   (SELECT 1
                                      FROM pco_detail
                                     WHERE     pcod_pco = l_pco.pco_id
                                           AND pcod_fix_acd = acd_id)
                           AND EXISTS
                                   (SELECT 1
                                      FROM uss_ndi.v_ndi_payment_type
                                     WHERE     npt_npc IS NULL
                                           AND acd_npt = npt_id);
                END IF;

                INSERT INTO tmp_work_ids1 (x_id)
                    SELECT DISTINCT acd_ac
                      FROM pco_detail, ac_detail
                     WHERE pcod_pco = l_pco.pco_id AND pcod_new_acd = acd_id;

                API$ACCRUAL.actuilize_payed_sum (1);
            END IF;

            l_pco.pco_st := 'V';
            l_hs := TOOLS.GetHistSession;

            UPDATE pc_data_ordering
               SET pco_st = 'V',
                   pco_new_pdp_sum = l_pco.pco_new_pdp_sum,
                   pco_hs_decision = l_hs
             WHERE pco_id = l_pco.pco_id;

            write_pco_log (l_pco.pco_id,
                           NULL,
                           'V',
                           CHR (38) || '134#' || l_pco.pco_decision_tp,
                           'N');
        ELSIF l_pco.pco_tp = 'DUPD' AND l_pco.pco_decision_tp IN ('31')
        THEN
            l_hs := TOOLS.GetHistSession;

            DELETE FROM tmp_work_set2
                  WHERE 1 = 1;

            INSERT INTO tmp_work_set2 (x_id1,
                                       x_id2,
                                       x_dt1,
                                       x_dt2,
                                       x_id4)
                SELECT pdap_id,
                       pdap_pd,
                       pdap_start_dt,
                       pdap_stop_dt,
                       DECODE (pcod_is_correct, 'T', 1, 0)
                  FROM pd_accrual_period pdap, pc_decision, pco_detail
                 WHERE     pdap_pd = pd_id
                       AND pcod_pd = pd_id
                       AND pd_pc = l_pco.pco_pc
                       AND pcod_pco = l_pco.pco_id
                       AND pdap.history_status = 'A';

            --D1..D2 (pco_month)--перетворюємо в
            --D1..pco_month-1,  addmonth(pco_month, 1)..D2
            --pco_month..lastday(pco_month) - залишається діючим в pcod_is_correct = 'T'

            --Визначаємо необхідність обмеження запису PDAP зліва. Але аналізуємо тільки "неправильні" по pcod_is_correct.
            UPDATE tmp_work_set2
               SET x_string1 = '+'
             WHERE     l_pco.pco_month > x_dt1
                   AND l_pco.pco_month <= x_dt2
                   AND x_id4 = 0;

            --Визначаємо необхідність обмеження запису PDAP зправа (+) і нового запису, обмеженого зправа, якщо це той же, що обмежений зліва. Але аналізуємо тільки "неправильні" по pcod_is_correct.
            UPDATE tmp_work_set2
               SET x_string2 = DECODE (x_string1, '+', '++', '+')
             WHERE     LAST_DAY (l_pco.pco_month) >= x_dt1
                   AND LAST_DAY (l_pco.pco_month) < x_dt2
                   AND x_id4 = 0;

            --Визначаємо необхідність просто видалення запису PDAP, якщо він повністю всередині pco_month..lastday(pco_month). Але аналізуємо тільки "неправильні" по pcod_is_correct.
            UPDATE tmp_work_set2
               SET x_string1 = '-', x_string2 = '-'
             WHERE     x_dt1 BETWEEN l_pco.pco_month
                                 AND LAST_DAY (l_pco.pco_month)
                   AND x_dt2 BETWEEN l_pco.pco_month
                                 AND LAST_DAY (l_pco.pco_month)
                   AND x_id4 = 0;

            --Видаляємо всі записи, які "зачепила" зміна.
            UPDATE pd_accrual_period
               SET history_status = 'H', pdap_hs_del = l_hs
             WHERE EXISTS
                       (SELECT 1
                          FROM tmp_work_set2
                         WHERE     (   x_string1 IS NOT NULL
                                    OR x_string2 IS NOT NULL)
                               AND pdap_id = x_id1);

            --Обмежуємо запис зліва
            INSERT INTO pd_accrual_period (pdap_id,
                                           pdap_pd,
                                           pdap_start_dt,
                                           pdap_stop_dt,
                                           history_status,
                                           pdap_pco,
                                           pdap_hs_ins,
                                           pdap_change_pd,
                                           pdap_change_ap)
                SELECT 0,
                       pdap_pd,
                       pdap_start_dt,
                       l_pco.pco_month - 1,
                       'A',
                       l_pco.pco_id,
                       l_hs,
                       pdap_change_pd,
                       pdap_change_ap
                  FROM pd_accrual_period, tmp_work_set2
                 WHERE pdap_id = x_id1 AND x_string1 = '+';

            --Обмежуємо запис зправа
            INSERT INTO pd_accrual_period (pdap_id,
                                           pdap_pd,
                                           pdap_start_dt,
                                           pdap_stop_dt,
                                           history_status,
                                           pdap_pco,
                                           pdap_hs_ins,
                                           pdap_change_pd,
                                           pdap_change_ap)
                SELECT 0,
                       pdap_pd,
                       ADD_MONTHS (l_pco.pco_month, 1),
                       pdap_stop_dt,
                       'A',
                       l_pco.pco_id,
                       l_hs,
                       pdap_change_pd,
                       pdap_change_ap
                  FROM pd_accrual_period, tmp_work_set2
                 WHERE pdap_id = x_id1 AND x_string2 IN ('+', '++');

            l_pco.pco_st := 'V';

            UPDATE pc_data_ordering
               SET pco_st = 'V', pco_hs_decision = l_hs
             WHERE pco_id = l_pco.pco_id;

            write_pco_log (l_pco.pco_id,
                           NULL,
                           'V',
                           CHR (38) || '134#' || l_pco.pco_decision_tp,
                           'N');
        --    raise_application_error(-20000, l_pco.pco_id||'-000> Впорядкування проблеми '||l_pco.pco_tp||' рішенням '||NVL(l_pco.pco_decision_tp, '<не обрано рішення>')||' не підтримується!');
        ELSIF l_pco.pco_tp = 'DUPD' AND l_pco.pco_decision_tp IN ('32')
        THEN
            --Шукаємо перелік перетинів по періодам дії по ЕОС на конкретну дату
            DELETE FROM tmp_work_set2
                  WHERE 1 = 1;

            INSERT INTO tmp_work_set2 (x_id1, x_id2, x_dt1)
                SELECT u_pc, u_pd, u_dt
                  FROM (WITH
                            all_dt
                            AS
                                (SELECT pd_pa               AS u_pa,
                                        pd_pc               AS u_pc,
                                        pd_id               AS u_pd,
                                        l_pco.pco_month     AS u_dt
                                   FROM pc_decision, pd_accrual_period pdap
                                  WHERE     pdap_pd = pd_id
                                        AND pdap.history_status = 'A'
                                        AND pd_nst = 664
                                        AND l_pco.pco_month BETWEEN pdap_start_dt
                                                                AND NVL (
                                                                        pdap_stop_dt,
                                                                        TO_DATE (
                                                                            '31.03.2023',
                                                                            'DD.MM.YYYY'))
                                        AND pd_Pc = l_pco.pco_pc)
                        SELECT *
                          FROM all_dt
                         WHERE 1 <
                               (SELECT COUNT (*)
                                  FROM pc_decision, pd_accrual_period pdap
                                 WHERE     pdap_pd = pd_id
                                       AND pdap.history_status = 'A'
                                       AND pd_pa = u_pa
                                       AND u_dt BETWEEN pdap_start_dt
                                                    AND NVL (
                                                            pdap_stop_dt,
                                                            TO_DATE (
                                                                '31.03.2023',
                                                                'DD.MM.YYYY'))))
                 WHERE u_dt >= TO_DATE ('01.03.2022', 'DD.MM.YYYY');

            l_cnt := SQL%ROWCOUNT;

            IF l_cnt = 0
            THEN --Якщо на дату перетинів немає - проблема вирішена "штатними" методами. Просто міняємо статус на V
                l_pco.pco_st := 'V';

                UPDATE pc_data_ordering
                   SET pco_st = 'V', pco_hs_decision = l_hs
                 WHERE pco_id = l_pco.pco_id;

                write_pco_log (l_pco.pco_id,
                               NULL,
                               'V',
                               CHR (38) || '184#' || l_pco.pco_decision_tp,
                               'N');
            ELSE --Інакше - пробема все ж наявна, а отже - оновлюємо перелік перетинів, аби можна було вирішити проблему рішенням 31, навіть якщо щось змінилось.
                DELETE FROM uss_esr.pco_detail
                      WHERE pcod_pco = l_pco.pco_id;

                INSERT INTO uss_esr.pco_detail (pcod_id,
                                                pcod_pco,
                                                pcod_pd,
                                                pcod_is_correct)
                    SELECT 0,
                           pco_id,
                           x_id2,
                           NULL
                      FROM uss_esr.tmp_work_set2, uss_esr.pc_data_ordering
                     WHERE     pco_tp = 'DUPD'
                           AND pco_pc = x_id1
                           AND pco_id = l_pco.pco_id
                           AND pco_month = x_dt1;

                write_pco_log (l_pco.pco_id,
                               NULL,
                               'N',
                               CHR (38) || '183',
                               'N');
            END IF;
        ELSE
            raise_application_error (
                -20000,
                   '000> Впорядкування проблеми '
                || l_pco.pco_tp
                || ' рішенням '
                || NVL (l_pco.pco_decision_tp, '<не обрано рішення>')
                || ' не підтримується!');
        END IF;
    END;
BEGIN
    -- Initialization
    NULL;
END API$PC_DATA_ORDERING;
/