/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$PARAMSESR
IS
    -- Author  : LESHA
    -- Created : 13.09.2022 11:09:00
    -- Purpose :

    g_format_d       CONSTANT VARCHAR2 (20) := 'dd.mm.yyyy';
    g_WAR_CODE       CONSTANT VARCHAR2 (20) := 'WAR_MARTIAL_LAW_END';
    g_WAR_CODE_709   CONSTANT VARCHAR2 (20) := 'VPO_END_BY_709';
    g_WAR_CODE_94    CONSTANT VARCHAR2 (20) := 'VPO_END_BY_94';


    --===========================================================================--
    --
    --===========================================================================--
    PROCEDURE set_param (p_name VARCHAR2, p_val VARCHAR2);

    PROCEDURE Recalc_664_94 (p_war_old_dt   DATE,
                             p_war_new_dt   DATE,
                             p_hs           histsession.hs_id%TYPE);
END API$PARAMSESR;
/


/* Formatted on 8/12/2025 5:49:08 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$PARAMSESR
IS
    --===========================================================================--
    /*
      PROCEDURE Recalc_Not_664(  p_war_old_dt DATE, p_hs  histsession.hs_id%TYPE) IS
        l_dt DATE;
        l_old_dt DATE;
      BEGIN
        DELETE FROM tmp_work_ids WHERE 1=1;
        l_dt     := last_day(ADD_MONTHS(TOOLS.GGPD('WAR_MARTIAL_LAW_END'), 1));
        IF p_war_old_dt IS NOT NULL THEN
          --l_old_dt := last_day(ADD_MONTHS(p_war_old_dt, 1));
          l_old_dt := last_day(p_war_old_dt);
        END IF;

        --Сформуємо перелік рішень для обробки
        INSERT INTO tmp_work_ids(x_id)
        SELECT pd_id
        FROM pc_decision pd
        WHERE pd.pd_nst IN ( 664
              AND pd_st != 'PS'
              AND pd_stop_dt IS NOT NULL
              AND (l_old_dt IS NULL OR pd_stop_dt >= l_old_dt)
        UNION ALL
        SELECT DISTINCT pd_id
        FROM pc_decision pd
             JOIN pc_block ON pcb_id = pd_pcb
             JOIN uss_ndi.v_ndi_reason_not_pay ON rnp_id = pcb_rnp
        WHERE pd.pd_nst = 664
              AND pd_st = 'PS'
              AND pcb_lock_pnp_tp != 'CPX'
              AND rnp_code NOT IN ( 'CHO', 'DE' )
              AND pd_stop_dt IS NOT NULL
              AND (l_old_dt IS NULL OR pd_stop_dt >= l_old_dt);

        --
        UPDATE pc_decision pd SET
           pd.pd_stop_dt = l_dt
        WHERE pd_id IN (SELECT x_id FROM tmp_work_ids);
        --
        UPDATE pd_pay_method pm SET
           pm.pdm_stop_dt = l_dt
        WHERE pdm_pd IN (SELECT x_id FROM tmp_work_ids)
              AND pm.pdm_is_actual = 'T'
              AND pm.history_status = 'A';
        --
        INSERT INTO pd_accrual_period(pdap_id, pdap_pd, pdap_start_dt, pdap_stop_dt,
                                      pdap_change_pd, history_status,pdap_change_ap,pdap_reason_start,pdap_reason_stop,pdap_pco,pdap_hs_ins)
        SELECT x_pdap_id, pdap_pd, x_start_dt, x_stop_dt,
               pdap_change_pd,    history_status,   pdap_change_ap,
               pdap_reason_start, pdap_reason_stop, pdap_pco, x_hs
        FROM (SELECT 0 AS x_pdap_id, ap.pdap_pd, ap.pdap_stop_dt+1 AS x_start_dt, l_dt AS x_stop_dt,
                     ap.pdap_change_pd, ap.history_status, ap.pdap_change_ap,
                     ap.pdap_reason_start, ap.pdap_reason_stop, ap.pdap_pco, p_hs AS x_hs,
                     ROW_NUMBER()  OVER (PARTITION BY pdap_pd ORDER BY ap.pdap_id) AS rn
              FROM pd_accrual_period ap
              WHERE pdap_pd IN (SELECT x_id FROM tmp_work_ids)
                    AND ap.pdap_stop_dt = (SELECT MAX(m.pdap_stop_dt) FROM pd_accrual_period m WHERE m.pdap_pd = ap.pdap_pd AND m.history_status = 'A')
                    AND ap.pdap_stop_dt >= l_old_dt
                    AND ap.history_status = 'A'
                    AND NOT EXISTS (SELECT 1 FROM pc_decision WHERE pd_id = pdap_pd AND pd_st = 'PS')
                    AND ap.pdap_start_dt IS NOT NULL
                    AND ap.pdap_stop_dt  IS NOT NULL
              )
        WHERE rn < 2;

        DELETE FROM tmp_work_set1  WHERE 1 = 1;
        INSERT INTO tmp_work_set1(x_id1, x_id2)
        SELECT pdp.pdp_id, id_pd_payment(0) AS new_id
        FROM  pd_payment pdp
        WHERE pdp_pd IN (SELECT x_id FROM tmp_work_ids)
              AND pdp_stop_dt >= l_old_dt
              AND pdp.history_status = 'A';

        INSERT INTO pd_payment(pdp_id, pdp_pd, pdp_npt, pdp_start_dt, pdp_stop_dt,
                               pdp_sum, pdp_hs_ins, history_status, pdp_src)
        SELECT  x_id2, pdp.pdp_pd, pdp.pdp_npt, pdp.pdp_stop_dt+1,  l_dt,
                pdp_sum, p_hs, 'A', 'EMS'
        FROM tmp_work_set1
             JOIN pd_payment pdp ON pdp.pdp_id = x_id1;

        INSERT INTO pd_detail (pdd_id, pdd_pdp, pdd_row_order, pdd_row_name, pdd_value, pdd_key, pdd_ndp,
                               pdd_start_dt, pdd_stop_dt, pdd_npt)
        SELECT 0 AS x_pdd_id, x_id2, pdd_row_order, pdd_row_name, pdd_value, pdd_key, pdd_ndp,
               pdd_stop_dt+1, l_dt, pdd_npt
        FROM tmp_work_set1
             JOIN pd_detail pdd ON pdd.pdd_pdp = x_id1;

      END;
    */
    --===========================================================================--
    PROCEDURE Recalc_664 (p_war_old_dt   DATE,
                          p_war_new_dt   DATE,
                          p_hs           histsession.hs_id%TYPE)
    IS
        l_dt       DATE;
        l_old_dt   DATE;
    BEGIN
        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        --l_dt     := last_day(ADD_MONTHS(TOOLS.GGPD('WAR_MARTIAL_LAW_END'), 1));
        --l_dt     := last_day(TOOLS.GGPD('VPO_END_BY_709'));
        l_dt := LAST_DAY (p_war_new_dt);

        IF p_war_old_dt IS NOT NULL
        THEN
            --l_old_dt := last_day(ADD_MONTHS(p_war_old_dt, 1));
            l_old_dt := LAST_DAY (p_war_old_dt);
        END IF;

        --Сформуємо перелік рішень для обробки
        INSERT INTO tmp_work_ids (x_id)
            SELECT pd_id
              FROM pc_decision pd
             WHERE     pd.pd_nst = 664
                   AND pd_st NOT IN ('PS', 'W', 'V')
                   AND pd_stop_dt IS NOT NULL
                   AND (l_old_dt IS NULL OR pd_stop_dt = l_old_dt)
            UNION ALL
            SELECT DISTINCT pd_id
              FROM pc_decision  pd
                   JOIN pc_block ON pcb_id = pd_pcb
                   JOIN uss_ndi.v_ndi_reason_not_pay ON rnp_id = pcb_rnp
             WHERE     pd.pd_nst = 664
                   AND pd_st = 'PS'
                   AND pcb_lock_pnp_tp != 'CPX'
                   AND rnp_code NOT IN ('CHO', 'DE')
                   AND pd_stop_dt IS NOT NULL
                   AND (l_old_dt IS NULL OR pd_stop_dt = l_old_dt);

        --
        UPDATE pc_decision pd
           SET pd.pd_stop_dt = l_dt
         WHERE pd_id IN (SELECT x_id FROM tmp_work_ids);

        --
        UPDATE pd_pay_method pm
           SET pm.pdm_stop_dt = l_dt
         WHERE     pdm_pd IN (SELECT x_id FROM tmp_work_ids)
               AND pm.pdm_is_actual = 'T'
               AND pm.history_status = 'A';

        --
        /*
            UPDATE pd_accrual_period ap SET
               ap.pdap_stop_dt = l_dt
            WHERE pdap_pd IN (SELECT x_id FROM tmp_work_ids)
                  AND ap.pdap_stop_dt = (SELECT MAX(m.pdap_stop_dt) FROM pd_accrual_period m WHERE m.pdap_pd = ap.pdap_pd AND m.history_status = 'A')
                  AND ap.history_status = 'A'
                  AND NOT EXISTS (SELECT 1 FROM pc_decision WHERE pd_id = pdap_pd AND pd_st = 'PS');
        */
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
            SELECT x_pdap_id,
                   pdap_pd,
                   x_start_dt,
                   x_stop_dt,
                   pdap_change_pd,
                   history_status,
                   pdap_change_ap,
                   pdap_reason_start,
                   pdap_reason_stop,
                   pdap_pco,
                   x_hs
              FROM (SELECT 0                                 AS x_pdap_id,
                           ap.pdap_pd,
                           ap.pdap_stop_dt + 1               AS x_start_dt,
                           l_dt                              AS x_stop_dt,
                           ap.pdap_change_pd,
                           ap.history_status,
                           ap.pdap_change_ap,
                           ap.pdap_reason_start,
                           ap.pdap_reason_stop,
                           ap.pdap_pco,
                           p_hs                              AS x_hs,
                           ROW_NUMBER ()
                               OVER (PARTITION BY pdap_pd
                                     ORDER BY ap.pdap_id)    AS rn
                      FROM pd_accrual_period ap
                     WHERE     pdap_pd IN (SELECT x_id FROM tmp_work_ids)
                           AND ap.pdap_stop_dt =
                               (SELECT MAX (m.pdap_stop_dt)
                                  FROM pd_accrual_period m
                                 WHERE     m.pdap_pd = ap.pdap_pd
                                       AND m.history_status = 'A')
                           AND ap.pdap_stop_dt >= l_old_dt
                           AND ap.history_status = 'A'
                           AND NOT EXISTS
                                   (SELECT 1
                                      FROM pc_decision
                                     WHERE pd_id = pdap_pd AND pd_st = 'PS')
                           AND ap.pdap_start_dt IS NOT NULL
                           AND ap.pdap_stop_dt IS NOT NULL)
             WHERE rn < 2;

        DELETE FROM tmp_work_set1
              WHERE 1 = 1;

        INSERT INTO tmp_work_set1 (x_id1, x_id2)
            SELECT pdp.pdp_id, id_pd_payment (0) AS new_id
              FROM pd_payment pdp
             WHERE     pdp_pd IN (SELECT x_id FROM tmp_work_ids)
                   AND pdp_stop_dt >= l_old_dt
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
                   pdp.pdp_stop_dt + 1,
                   l_dt,
                   pdp_sum,
                   p_hs,
                   'A',
                   'EMS'
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
                   pdd_stop_dt + 1,
                   l_dt,
                   pdd_npt
              FROM tmp_work_set1 JOIN pd_detail pdd ON pdd.pdd_pdp = x_id1;
    /*
        UPDATE pd_detail pdd SET
           pdd.pdd_stop_dt = l_dt
        WHERE pdd_pdp IN (SELECT pdp.pdp_id
                          FROM pd_payment pdp
                               JOIN tmp_work_ids ON pdp_pd = x_id AND pdp.history_status = 'A')
              AND pdd_stop_dt >= l_old_dt;
    */
    END;

    --===========================================================================--
    PROCEDURE Recalc_664_94 (p_war_old_dt   DATE,
                             p_war_new_dt   DATE,
                             p_hs           histsession.hs_id%TYPE)
    IS
        l_dt       DATE;
        l_old_dt   DATE;
    BEGIN
        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        l_dt := LAST_DAY (p_war_new_dt);

        IF p_war_old_dt IS NOT NULL
        THEN
            l_old_dt := LAST_DAY (p_war_old_dt);
        END IF;

        --Сформуємо перелік рішень для обробки
        INSERT INTO tmp_work_ids (x_id)
            SELECT pd_id
              FROM pc_decision pd
             WHERE     pd.pd_nst = 664
                   --AND pd_st != 'PS'
                   AND pd_st NOT IN ('PS', 'W', 'V')
                   AND pd_stop_dt IS NOT NULL
                   AND (l_old_dt IS NULL OR pd_stop_dt = l_old_dt)
                   AND EXISTS
                           (SELECT 1
                              FROM pd_payment pdp
                             WHERE     pdp_pd = pd_id
                                   AND pdp_stop_dt >= l_old_dt
                                   AND pdp.history_status = 'A')
            --AND pd.pd_num IN ( '51808-91258-2024-1', '51808-91056-2024-1')
            UNION ALL
            SELECT DISTINCT pd_id
              FROM pc_decision  pd
                   JOIN pc_block ON pcb_id = pd_pcb
                   JOIN uss_ndi.v_ndi_reason_not_pay ON rnp_id = pcb_rnp
             WHERE     pd.pd_nst = 664
                   AND pd_st = 'PS'
                   AND pcb_lock_pnp_tp != 'CPX'
                   AND rnp_code NOT IN ('CHO', 'DE')
                   AND pd_stop_dt IS NOT NULL
                   AND (l_old_dt IS NULL OR pd_stop_dt = l_old_dt);

        DELETE FROM tmp_work_set2
              WHERE 1 = 1;

        INSERT INTO tmp_work_set2 (x_id1,
                                   x_id2,
                                   x_id3,
                                   x_id4,
                                   x_id5)
            SELECT f.pdf_pd,
                   f.pdf_id,
                   f.pdf_sc,
                   d.pd_ap,
                   d.pd_ap_reason
              FROM tmp_work_ids
                   JOIN pc_decision d ON pd_id = x_id
                   JOIN pd_family f ON f.pdf_pd = x_id;

        --    SELECT x_id1 AS x_pd, x_id2 AS x_pdf, x_id3 AS x_sc, x_id4 AS x_ap, x_id5 AS x_ap_reason FROM  tmp_work_set2;
        /**/
        UPDATE tmp_work_set2 t
           SET (t.x_dt1, t.x_string1) =
                   (SELECT MAX (a347.apda_val_dt),
                           MAX (NVL (a4188.apda_val_string, 'F'))
                      FROM ap_document  apd
                           JOIN ap_person app
                               ON     app.app_id = apd.apd_app
                                  AND app.history_status = 'A'
                           LEFT JOIN ap_document_attr a347
                               ON     a347.apda_apd = apd_id
                                  AND a347.apda_nda = 347
                                  AND a347.history_status = 'A'
                           LEFT JOIN ap_document_attr a4188
                               ON     a4188.apda_apd = apd_id
                                  AND a4188.apda_nda = 4188
                                  AND a4188.history_status = 'A'
                     WHERE     (apd.apd_ap = t.x_id4 OR apd.apd_ap = t.x_id5)
                           AND apd.apd_ndt = 201
                           AND apd.history_status = 'A'
                           AND app.app_sc = x_id3);

        UPDATE tmp_work_set2 t
           SET t.x_sum1 = 2000
         --    WHERE t.x_dt1 < to_date('01.10.2023', 'dd.mm.yyyy')
         WHERE     TRUNC (t.x_dt1, 'MM') =
                   TO_DATE ('01.10.2023', 'dd.mm.yyyy')
               AND t.x_dt1 IS NOT NULL
               AND t.x_string1 = 'F';

        /**/
        --
        UPDATE pd_family pdf
           SET pdf.pdf_stop_dt = l_dt
         WHERE     pdf_pd IN (SELECT x_id FROM tmp_work_ids)
               AND (pdf.history_status = 'A' OR pdf.history_status IS NULL)
               AND (   pdf.pdf_stop_dt = (SELECT pd_stop_dt
                                            FROM pc_decision pd
                                           WHERE pdf_pd = pd_id)
                    OR pdf.pdf_stop_dt IS NULL);

        --
        UPDATE pc_decision pd
           SET pd.pd_stop_dt = l_dt
         WHERE pd_id IN (SELECT x_id FROM tmp_work_ids);

        --
        UPDATE pd_pay_method pm
           SET pm.pdm_stop_dt = l_dt
         WHERE     pdm_pd IN (SELECT x_id FROM tmp_work_ids)
               AND pm.pdm_is_actual = 'T'
               AND pm.history_status = 'A';

        --
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
            SELECT x_pdap_id,
                   pdap_pd,
                   x_start_dt,
                   x_stop_dt,
                   pdap_change_pd,
                   history_status,
                   pdap_change_ap,
                   pdap_reason_start,
                   pdap_reason_stop,
                   pdap_pco,
                   x_hs
              FROM (SELECT 0                                 AS x_pdap_id,
                           ap.pdap_pd,
                           ap.pdap_stop_dt + 1               AS x_start_dt,
                           l_dt                              AS x_stop_dt,
                           ap.pdap_change_pd,
                           ap.history_status,
                           ap.pdap_change_ap,
                           ap.pdap_reason_start,
                           ap.pdap_reason_stop,
                           ap.pdap_pco,
                           p_hs                              AS x_hs,
                           ROW_NUMBER ()
                               OVER (PARTITION BY pdap_pd
                                     ORDER BY ap.pdap_id)    AS rn
                      FROM pd_accrual_period ap
                     WHERE     pdap_pd IN (SELECT x_id FROM tmp_work_ids)
                           AND ap.pdap_stop_dt =
                               (SELECT MAX (m.pdap_stop_dt)
                                  FROM pd_accrual_period m
                                 WHERE     m.pdap_pd = ap.pdap_pd
                                       AND m.history_status = 'A')
                           AND ap.pdap_stop_dt >= l_old_dt
                           AND ap.history_status = 'A'
                           AND NOT EXISTS
                                   (SELECT 1
                                      FROM pc_decision
                                     WHERE pd_id = pdap_pd AND pd_st = 'PS')
                           AND ap.pdap_start_dt IS NOT NULL
                           AND ap.pdap_stop_dt IS NOT NULL)
             WHERE rn < 2;

        /*
        Є лише один виняток, якщо особі після 01.08.2023 призначено допомогу 3000 як особі з інвалідністю
        (станом на січень 2024 розмір допомоги=3000 грн, інвалідність встановлена до жовтня 2023 року
        (в документі з Ід=201 в атрибуті з Ід=347 встановлено день жовтня 2023 року)
        і МСЕКи виконують свої повноваження (в документі з Ід=201 в атрибуті з Ід=4188 встановлено "Ні" або "пусто")

        Таким на лютий 2024 допомога ВПО має становити 2000 грн, а не 3000

        Приклад такого на Соні 51808-91258-2024-1 на січень 3000 грн, після подовження на лютий сума допомоги має змінитися на 2000 грн
        */
        DELETE FROM tmp_work_set1
              WHERE 1 = 1;

        INSERT INTO tmp_work_set1 (x_id1, x_id2)
            SELECT pdp.pdp_id, id_pd_payment (0) AS new_id
              FROM pd_payment pdp
             WHERE     pdp_pd IN (SELECT x_id FROM tmp_work_ids)
                   AND pdp_stop_dt >= l_old_dt
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
                   pdp.pdp_stop_dt + 1,
                   l_dt,
                   pdp_sum,
                   p_hs,
                   'A',
                   'EMS'
              FROM tmp_work_set1 JOIN pd_payment pdp ON pdp.pdp_id = x_id1;

        --    SELECT x_id1 AS x_pd, x_id2 AS x_pdf, x_id3 AS x_sc, x_id4 AS x_ap, x_id5 AS x_ap_reason FROM  tmp_work_set2;

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
            SELECT 0                 AS x_pdd_id,
                   x_id2,
                   pdd_row_order,
                   pdd_row_name,
                   NVL (
                       (SELECT /*+ index(y) */
                               CASE
                                   WHEN NVL (y.x_sum1, 0) = 2000 THEN 2000
                                   ELSE pdd_value
                               END
                          FROM tmp_work_set2 y
                         WHERE y.x_id2 = pdd.pdd_key),
                       pdd_value)    AS x_pdd_value,
                   pdd_key,
                   pdd_ndp,
                   pdd_stop_dt + 1,
                   l_dt,
                   pdd_npt
              FROM tmp_work_set1 x JOIN pd_detail pdd ON pdd.pdd_pdp = x_id1;
    /*
    UPDATE pd_payment pdp SET
      pdp.pdp_sum = (SELECT SUM(pdd_value)
                     FROM pd_detail
                     WHERE pdd_pdp = pdp_id
                       AND pdd_ndp  IN (290, 300)
    WHERE EXISTS (SELECT 1 FROM tmp_work_set1 WHERE x_id2 = pdp_id);
*/
    END;

    --===========================================================================--
    PROCEDURE set_war_martial_law_end (p_val DATE)
    IS
        l_bp_month     DATE;
        l_WAR_OLD_CH   VARCHAR (20);
        l_WAR_OLD_DT   DATE;
        l_lock         TOOLS.t_lockhandler;
        l_hs           histsession.hs_id%TYPE;
    BEGIN
        --l_lock := TOOLS.request_lock(p_descr => 'SET_WAR_MARTIAL_LAW_END', p_error_msg => 'В даний момент вже виконується перерахунок рішень ВПО для нової дати завершення воєнного стану');
        l_lock :=
            TOOLS.request_lock (
                p_descr   => 'VPO_END_BY_709',
                p_error_msg   =>
                    'В даний момент вже виконується перерахунок рішень ВПО для нової дати завершення постанові КМУ №709');

        SELECT NVL (MAX (bp_month), SYSDATE)
          INTO l_bp_month
          FROM BILLING_PERIOD
         WHERE bp_class = 'VPO';

        l_bp_month := ADD_MONTHS (TRUNC (l_bp_month), 1);

        IF l_bp_month > p_val
        THEN
            raise_application_error (
                -20000,
                'дата повинна бути не менше, ніж в наступному місяці від максимального розрахункового поточного місяця по класу розрахункових місяці "по ВПО"');
        END IF;

        l_hs := TOOLS.GetHistSession;

        SELECT MAX (PRM_VALUE)
          INTO l_WAR_OLD_CH
          FROM PARAMSESR
         WHERE prm_code = g_war_code;

        IF l_WAR_OLD_CH IS NOT NULL
        THEN
            l_WAR_OLD_DT := TO_DATE (l_WAR_OLD_CH, g_format_d);
        END IF;

        MERGE INTO PARAMSESR
             USING (SELECT g_war_code                      AS x_CODE,
                           TO_CHAR (p_val, g_format_d)     AS x_VALUE,
                           'Закінчення воєнного стану'     AS x_COMMENT
                      FROM DUAL)
                ON (prm_code = x_code)
        WHEN MATCHED
        THEN
            UPDATE SET prm_value = x_value
        WHEN NOT MATCHED
        THEN
            INSERT     (PRM_ID,
                        PRM_CODE,
                        PRM_NAME,
                        PRM_VALUE,
                        PRM_COMMENT)
                VALUES (0,
                        x_code,
                        x_code,
                        x_VALUE,
                        x_COMMENT);

        --Recalc_not_664(l_WAR_OLD_DT, l_hs);

        TOOLS.release_lock (l_lock);
    END;

    --===========================================================================--
    PROCEDURE set_VPO_END_BY_709 (p_WAR_NEW_DT DATE)
    IS
        l_bp_month     DATE;
        l_WAR_OLD_CH   VARCHAR (20);
        l_WAR_OLD_DT   DATE;
        l_lock         TOOLS.t_lockhandler;
        l_hs           histsession.hs_id%TYPE;
    BEGIN
        l_lock :=
            TOOLS.request_lock (
                p_descr   => 'VPO_END_BY_709',
                p_error_msg   =>
                    'В даний момент вже виконується перерахунок рішень ВПО для нової дати завершення постанові КМУ №709');

        SELECT NVL (MAX (bp_month), SYSDATE)
          INTO l_bp_month
          FROM BILLING_PERIOD
         WHERE bp_class = 'VPO';

        l_bp_month := ADD_MONTHS (TRUNC (l_bp_month), 1);

        IF l_bp_month > p_WAR_NEW_DT
        THEN
            raise_application_error (
                -20000,
                'дата повинна бути не менше, ніж в наступному місяці від максимального розрахункового поточного місяця по класу розрахункових місяці "по ВПО"');
        END IF;

        l_hs := TOOLS.GetHistSession;

        SELECT MAX (PRM_VALUE)
          INTO l_WAR_OLD_CH
          FROM PARAMSESR
         WHERE prm_code = g_war_code;

        IF l_WAR_OLD_CH IS NOT NULL
        THEN
            l_WAR_OLD_DT := TO_DATE (l_WAR_OLD_CH, g_format_d);
        END IF;

        MERGE INTO PARAMSESR
             USING (SELECT g_war_code                                                     AS x_CODE,
                           TO_CHAR (p_WAR_NEW_DT, g_format_d)                             AS x_VALUE,
                           'Дата закінчення допомоги по ВПО згідно постанови КМУ №709'    AS x_COMMENT
                      FROM DUAL)
                ON (prm_code = x_code)
        WHEN MATCHED
        THEN
            UPDATE SET prm_value = x_value
        WHEN NOT MATCHED
        THEN
            INSERT     (PRM_ID,
                        PRM_CODE,
                        PRM_NAME,
                        PRM_VALUE,
                        PRM_COMMENT)
                VALUES (0,
                        x_code,
                        x_code,
                        x_VALUE,
                        x_COMMENT);

        /*
        IF p_WAR_NEW_DT > l_WAR_OLD_DT THEN
          Recalc_664(l_WAR_OLD_DT, p_WAR_NEW_DT, l_hs);
        END IF;
        */
        TOOLS.release_lock (l_lock);
    END;

    --===========================================================================--
    PROCEDURE set_VPO_END_BY_94 (p_WAR_NEW_DT DATE)
    IS
        l_bp_month     DATE;
        l_WAR_OLD_CH   VARCHAR (20);
        l_WAR_OLD_DT   DATE;
        l_lock         TOOLS.t_lockhandler;
        l_hs           histsession.hs_id%TYPE;
    BEGIN
        l_lock :=
            TOOLS.request_lock (
                p_descr   => 'VPO_END_BY_94',
                p_error_msg   =>
                    'В даний момент вже виконується перерахунок рішень ВПО для нової дати завершення постанові КМУ №94');

        SELECT NVL (MAX (bp_month), SYSDATE)
          INTO l_bp_month
          FROM BILLING_PERIOD
         WHERE bp_class = 'VPO';

        l_bp_month := ADD_MONTHS (TRUNC (l_bp_month), 1);

        IF l_bp_month > p_WAR_NEW_DT
        THEN
            raise_application_error (
                -20000,
                'дата повинна бути не менше, ніж в наступному місяці від максимального розрахункового поточного місяця по класу розрахункових місяці "по ВПО"');
        END IF;

        l_hs := TOOLS.GetHistSession;

        SELECT MAX (PRM_VALUE)
          INTO l_WAR_OLD_CH
          FROM PARAMSESR
         WHERE prm_code = g_WAR_CODE_94;

        IF l_WAR_OLD_CH IS NOT NULL
        THEN
            l_WAR_OLD_DT := TO_DATE (l_WAR_OLD_CH, g_format_d);
        END IF;

        MERGE INTO PARAMSESR
             USING (SELECT g_war_code_94                                                 AS x_CODE,
                           TO_CHAR (p_WAR_NEW_DT, g_format_d)                            AS x_VALUE,
                           'Дата закінчення допомоги по ВПО згідно постанови КМУ №94'    AS x_COMMENT
                      FROM DUAL)
                ON (prm_code = x_code)
        WHEN MATCHED
        THEN
            UPDATE SET prm_value = x_value
        WHEN NOT MATCHED
        THEN
            INSERT     (PRM_ID,
                        PRM_CODE,
                        PRM_NAME,
                        PRM_VALUE,
                        PRM_COMMENT)
                VALUES (0,
                        x_code,
                        x_code,
                        x_VALUE,
                        x_COMMENT);

        IF p_WAR_NEW_DT > l_WAR_OLD_DT
        THEN
            Recalc_664_94 (l_WAR_OLD_DT, p_WAR_NEW_DT, l_hs);
        END IF;

        TOOLS.release_lock (l_lock);
    END;

    --===========================================================================--
    --
    --===========================================================================--
    PROCEDURE set_param (p_name VARCHAR2, p_val VARCHAR2)
    IS
    BEGIN
        CASE p_name
            WHEN g_war_code
            THEN
                set_war_martial_law_end (TO_DATE (p_val, g_format_d));
            WHEN g_war_code_709
            THEN
                raise_application_error (
                    -20000,
                    'Зміна параметру "Дата закінчення допомоги по ВПО згідно постанови КМУ №709" заборонено!');
                set_VPO_END_BY_709 (TO_DATE (p_val, g_format_d));
            WHEN g_WAR_CODE_94
            THEN
                set_VPO_END_BY_94 (TO_DATE (p_val, g_format_d));
            ELSE
                raise_application_error (
                    -20000,
                    'В функцію встановлення параметрів передано невідомий параметр!');
        END CASE;
    EXCEPTION
        WHEN OTHERS
        THEN
            --dbms_output.put_line('SQLCODE='||SQLCODE);
            --dbms_output.put_line('SQLERRM='||SQLERRM);
            IF SQLCODE BETWEEN -1899 AND -1800
            THEN
                raise_application_error (
                    -20000,
                    'Дата повинна бути в форматі "' || g_format_d || '"!');
            ELSE
                RAISE;
            END IF;
    END;
--===========================================================================--
END API$PARAMSESR;
/