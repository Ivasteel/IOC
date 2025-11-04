/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$PD_OPERATIONS
IS
    -- Author  : LESHA
    -- Created : 08.09.2022 15:59:44
    -- Purpose :
    g_write_messages_to_output   INTEGER := 0;

    PROCEDURE Recalc_BD_END (p_rc   rc_candidates.rcc_rc%TYPE,
                             p_hs   histsession.hs_id%TYPE);

    PROCEDURE Recalc_S_VPO_18 (p_rc_id   rc_candidates.rcc_rc%TYPE,
                               p_hs      histsession.hs_id%TYPE);

    PROCEDURE Recalc_S_VPO_REF (p_rc_id   rc_candidates.rcc_rc%TYPE,
                                p_hs      histsession.hs_id%TYPE);

    PROCEDURE Recalc_S_EXT_VS (p_rc_id   rc_candidates.rcc_rc%TYPE,
                               p_hs      histsession.hs_id%TYPE);

    PROCEDURE Recalc_S_MF_STOP (p_rc_id   rc_candidates.rcc_rc%TYPE,
                                p_hs      histsession.hs_id%TYPE);


    PROCEDURE Recalc_S_ODEATH (p_rc_id   rc_candidates.rcc_rc%TYPE,
                               p_hs      histsession.hs_id%TYPE);

    PROCEDURE Recalc_S_EXT_2NST (p_rc_id   rc_candidates.rcc_rc%TYPE,
                                 p_hs      histsession.hs_id%TYPE);

    PROCEDURE Recalc_S_LGW_CHNG (p_rc_id   rc_candidates.rcc_rc%TYPE,
                                 p_hs      histsession.hs_id%TYPE);

    PROCEDURE Prepare_S_VPO_51 (p_rc_id recalculates.rc_id%TYPE);

    PROCEDURE Recalc_S_VPO_51 (p_rc_id   recalculates.rc_id%TYPE,
                               p_hs      histsession.hs_id%TYPE);

    PROCEDURE Prepare_S_VPO_131 (p_rc_id recalculates.rc_id%TYPE);

    PROCEDURE Recalc_S_VPO_131 (p_rc_id   recalculates.rc_id%TYPE,
                                p_hs      histsession.hs_id%TYPE);

    PROCEDURE Prepare_S_VPO_133 (p_rc_id recalculates.rc_id%TYPE);

    PROCEDURE Recalc_S_VPO_133 (p_rc_id   recalculates.rc_id%TYPE,
                                p_hs      histsession.hs_id%TYPE);

    PROCEDURE Recalc_PA_DN_18 (p_rc_id   recalculates.rc_id%TYPE,
                               p_hs      histsession.hs_id%TYPE);

    PROCEDURE Prepare_S_VPO_13_6 (p_rc_id recalculates.rc_id%TYPE);

    PROCEDURE Recalc_S_VPO_13_6 (p_rc_id   recalculates.rc_id%TYPE,
                                 p_hs      histsession.hs_id%TYPE);

    PROCEDURE reset_rcca_value (p_rcca_id rc_candidate_attr.rcca_id%TYPE);

    PROCEDURE Prepare_S_VPO_INC (p_rc_id recalculates.rc_id%TYPE);

    PROCEDURE Postscript_S_VPO_INC (p_rc_id recalculates.rc_id%TYPE);

    PROCEDURE Recalc_S_VPO_INC (p_rc_id   recalculates.rc_id%TYPE,
                                p_hs      histsession.hs_id%TYPE);

    PROCEDURE Recalc_S_PAT_PAY (p_rc_id   rc_candidates.rcc_rc%TYPE,
                                p_hs      histsession.hs_id%TYPE);

    PROCEDURE Recalc_S_VPO_INV (p_rc_id   rc_candidates.rcc_rc%TYPE,
                                p_hs      histsession.hs_id%TYPE);

    PROCEDURE Prepare_INDEX_VF (p_rc_id recalculates.rc_id%TYPE);

    PROCEDURE Recalc_INDEX_VF (p_rc_id   rc_candidates.rcc_rc%TYPE,
                               p_hs      histsession.hs_id%TYPE);
END API$PD_OPERATIONS;
/


/* Formatted on 8/12/2025 5:49:14 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$PD_OPERATIONS
IS
    PROCEDURE write_message (p_mode      INTEGER,
                             p_message   VARCHAR2,
                             p_tp        VARCHAR2:= NULL)
    IS
    BEGIN
        IF g_write_messages_to_output = 1
        THEN
            DBMS_OUTPUT.put_line (SYSTIMESTAMP || ' : ' || p_message);
        END IF;
    --  dbms_application_info.set_action(action_name => p_message);
    END;

    --===========================================================================--
    --
    --===========================================================================--
    PROCEDURE Recalc_BD_END (p_rc   rc_candidates.rcc_rc%TYPE,
                             p_hs   histsession.hs_id%TYPE)
    IS
        l_pnp_code   VARCHAR2 (20) := 'VPOE';
        l_start_dt   DATE := TO_DATE ('24.11.2023', 'dd.mm.yyyy');
    BEGIN
        API$PC_BLOCK.CLEAR_BLOCK;

        /* #100238
        2. Дата припинення залежить від наказу, яким встановлена дата закінчення.
        Якщо дата набрання чинності наказу до 24.11.2023, то припинення здійснюється з першого числа місяця наступного за місяцем набрання чинності наказу.
        Якщо дата набрання чинності наказу після 24.11.2023, то припинення здійснюється з першого числа місяця + 4 місяці до місяця набрання чинності наказу.
        Наприклад: наказ набрав чинності 02.02.2024, для Території №1 внесено дату закінчення "Можливих бойових дій" - 05.05.2022,
                 отже припинення необхідно здійснювати з 01.06.2024*/
        INSERT INTO tmp_pc_block (b_id,
                                  b_pc,
                                  b_pd,
                                  b_tp,
                                  b_rnp,
                                  b_locl_pnp_tp,
                                  b_hs_lock,
                                  b_ap_src,
                                  b_dt)
            WITH
                bd
                AS
                    (SELECT kaot_id,                           /*kaots_kaot,*/
                            kaot_code,
                            kaot_tp,
                            kaot_full_name,
                            kaot_koatuu,         --kaots_stop_dt, nna_start_dt
                            /*
                            case
                            when kaots_stop_dt > nna_start_dt
                              then last_day(kaots_stop_dt)
                              else last_day(add_months( nna_start_dt, - 1))
                            end  as X_stop_dt,
                            */
                            --#100238
                            CASE
                                WHEN nna_start_dt < l_start_dt
                                THEN
                                    LAST_DAY (nna_start_dt) + 1
                                ELSE
                                    ADD_MONTHS (TRUNC (nna_start_dt, 'MM'),
                                                4)
                            END                                AS X_stop_dt,
                            CASE
                                WHEN k.kaot_kaot_l3 = kaots_kaot THEN 3
                                WHEN k.kaot_kaot_l4 = kaots_kaot THEN 4
                                WHEN k.kaot_kaot_l5 = kaots_kaot THEN 5
                            END                                AS lvl,
                            MAX (
                                CASE
                                    WHEN k.kaot_kaot_l3 = kaots_kaot THEN 3
                                    WHEN k.kaot_kaot_l4 = kaots_kaot THEN 4
                                    WHEN k.kaot_kaot_l5 = kaots_kaot THEN 5
                                END)
                                OVER (PARTITION BY kaot_id)    AS max_lvl
                       FROM uss_ndi.v_NDI_KATOTTG  k
                            JOIN
                            (SELECT DISTINCT
                                    kaots_kaot,
                                    FIRST_VALUE (kaots_start_dt)
                                        OVER (PARTITION BY kaots_kaot
                                              ORDER BY kaots_start_dt ASC)
                                        kaots_start_dt,
                                    FIRST_VALUE (kaots_tp)
                                        OVER (PARTITION BY kaots_kaot
                                              ORDER BY kaots_start_dt DESC)
                                        kaots_tp_last,
                                    FIRST_VALUE (kaots_stop_dt)
                                        OVER (PARTITION BY kaots_kaot
                                              ORDER BY kaots_start_dt DESC)
                                        kaots_stop_dt,
                                    FIRST_VALUE (nna_start_dt)
                                        OVER (PARTITION BY kaots_kaot
                                              ORDER BY kaots_start_dt DESC)
                                        nna_start_dt
                               FROM uss_ndi.v_NDI_KAOT_STATE
                                    JOIN uss_ndi.v_ndi_normative_act
                                        ON nna_id = kaots_nna
                              WHERE uss_ndi.v_NDI_KAOT_STATE.history_status =
                                    'A')
                                ON                 --k.kaot_kaot_l3=kaots_kaot
                                       (   k.kaot_kaot_l3 = kaots_kaot
                                        OR k.kaot_kaot_l4 = kaots_kaot
                                        OR k.kaot_kaot_l5 = kaots_kaot)
                                   AND kaots_tp_last IN ('PMO', 'BD', 'TO')
                      WHERE kaot_st = 'A' AND kaots_stop_dt IS NOT NULL),
                pd
                AS
                    (SELECT DISTINCT pd_pc,
                                     pd_id,
                                     'MR'     AS x_b_tp,
                                     np.rnp_id,
                                     np.rnp_pnp_tp,
                                     p_hs,
                                     pd_ap,
                                     X_stop_dt
                       FROM rc_candidates
                            JOIN pc_decision ON rcc_pc = pd_pc
                            JOIN AP_DOCUMENT_ATTR apda
                                ON     apda_ap = pd_ap
                                   AND apda_nda = 1775
                                   AND apda.history_status = 'A'
                            JOIN bd
                                ON kaot_id = apda_val_id AND max_lvl = lvl
                            JOIN Pd_Pay_Method pm
                                ON     pm.pdm_pd = pd_id
                                   AND pm.pdm_is_actual = 'T'
                                   AND pm.history_status = 'A'
                            JOIN uss_ndi.V_NDI_REASON_NOT_PAY np
                                ON     np.rnp_pay_tp = pm.pdm_pay_tp
                                   AND np.rnp_code = l_pnp_code
                                   AND np.history_status = 'A'
                      WHERE     pd_st = 'S'
                            AND pd_nst = 664
                            AND rcc_rc = p_rc
                            AND NOT EXISTS
                                    (SELECT 1
                                       FROM AP_DOCUMENT_ATTR apda1
                                      WHERE     apda1.apda_ap = pd_ap
                                            AND apda1.apda_nda = 2101
                                            AND apda1.history_status = 'A'
                                            AND apda1.apda_val_string = 'T'))
            SELECT id_pc_block (NULL),
                   pd_pc,
                   pd_id,
                   x_b_tp,
                   rnp_id,
                   rnp_pnp_tp,
                   p_hs,
                   pd_ap,
                   X_stop_dt
              FROM pd;

        API$PC_BLOCK.decision_block (p_hs);
    END;

    --===========================================================================--
    PROCEDURE Recalc_S_VPO_18 (p_rc_id   rc_candidates.rcc_rc%TYPE,
                               p_hs      histsession.hs_id%TYPE)
    IS
        l_hs            histsession.hs_id%TYPE;
        l_recalculate   recalculates%ROWTYPE;
    BEGIN
        --ikis_sysweb.ikis_debug_pipe.WriteMsg('enter Recalc_S_VPO_18');

        --l_hs := NVL(p_hs, TOOLS.GetHistSession);
        l_hs := p_hs;

        IF l_hs IS NULL
        THEN
            l_hs := TOOLS.GetHistSession;
        END IF;

        SELECT *
          INTO l_recalculate
          FROM recalculates
         WHERE rc_id = p_rc_id;

        --ikis_sysweb.ikis_debug_pipe.WriteMsg(l_recalculate.rc_org_list);
        TOOLS.org_list_to_work_ids (3, l_recalculate.rc_org_list);

        DELETE FROM tmp_work_set2
              WHERE 1 = 1;

        --Знаходимо всіх осіб в рішеннях, по яким розписана в деталізації призначення сума 3000
        INSERT INTO tmp_work_set2 (x_id1,
                                   x_id2,
                                   x_id3,
                                   x_id4,
                                   x_id5,
                                   x_sum1,
                                   x_sum2,
                                   x_dt2)
            SELECT pc_id,
                   pd_id,
                   pdf_id,
                   pdp_id,
                   pdf_sc,
                   pdp_sum,
                   2000,
                   pdf_birth_dt
              FROM pd_family     mf,
                   pc_decision,
                   personalcase  pc,
                   rc_candidates,
                   recalculates,
                   pd_payment    pdp
             WHERE     rcc_rc = p_rc_id
                   AND rcc_rc = rc_id
                   AND rcc_pc = pc_id
                   AND rcc_pc = pd_pc
                   AND pdf_pd = pd_id
                   AND pd_nst = 664
                   AND pd_st = 'S'
                   AND mf.history_status = 'A'
                   AND pc.com_org IN (SELECT orgs.x_id
                                        FROM tmp_work_ids3 orgs)
                   AND pd_pc = pc_id
                   AND EXISTS
                           (SELECT 1
                              FROM pd_accrual_period pdap
                             WHERE     pdap_pd = pd_id
                                   AND pdap.history_status = 'A'
                                   AND rc_month <= pdap_stop_dt) --Рішення діє після 1 числа місяця перерахунку
                   AND pdp.history_status = 'A'
                   AND pdp_pd = pd_id
                   AND rc_month <= pdp_stop_dt --рядок призначення діє після 1 числа місяця перерахунку.
                   AND pdp_npt = 167
                   AND EXISTS
                           (SELECT 1
                              FROM pd_detail
                             WHERE     pdd_pdp = pdp_id
                                   --AND pdd_ndp = CASE WHEN pd_ap < 0 THEN 290 ELSE 300 END
                                   AND pdd_ndp IN (290, 300)
                                   AND pdd_key = pdf_id
                                   AND pdd_value = 3000); --беруться тільки ті рядки призначення, в яких є особи з 3000 грн

        --  write_rc_log(p_rc_id, l_hs, 'F', NULL, l_recalculate.rc_st);

        write_message (1, 'Осіб, що отримують 3000 грн: ' || SQL%ROWCOUNT);

        --Знаходимо по всім особам день народження
        UPDATE tmp_work_set2
           SET x_dt1 =
                   NVL (
                       (SELECT DISTINCT
                               FIRST_VALUE (apda_val_dt)
                                   OVER (
                                       ORDER BY
                                           (CASE ndt_id
                                                WHEN 600 THEN 10
                                                ELSE ndt_order
                                            END))    AS x_birth_dt
                          FROM uss_esr.ap_person           app,
                               uss_esr.ap_document         apd,
                               uss_ndi.v_ndi_document_type,
                               uss_esr.v_ap_document_attr  apda,
                               uss_ndi.v_ndi_document_attr,
                               uss_esr.pc_decision
                         WHERE     app.history_status = 'A'
                               AND apd.history_status = 'A'
                               AND apda.history_status = 'A'
                               AND ndt_id = apd_ndt
                               AND (ndt_ndc = 13 OR ndt_id = 600)
                               AND apda_apd = apd_id
                               AND apda_val_dt IS NOT NULL
                               AND nda_id = apda_nda
                               AND nda_class = 'BDT'
                               AND apd_app = app_id
                               AND app_ap = apda_ap
                               AND app_ap = pd_ap
                               AND apd_ap = pd_ap
                               AND apda_ap = pd_ap
                               AND pd_id = x_id2
                               AND app_sc = x_id5),
                       x_dt2)
         WHERE 1 = 1;

        --Видаляємо тих, кому виповнилось 18 років в період з -19 років до -18 років. Залишаються тільки ті, яким треба виставити 2000.
        DELETE FROM tmp_work_set2
              WHERE    x_dt1 <
                       ADD_MONTHS (l_recalculate.rc_month, -1 * (12 * 19))
                    OR x_dt1 >
                       ADD_MONTHS (l_recalculate.rc_month, -1 * (12 * 18));

        write_message (
            1,
               'Видалили тих, хто значно старший за 18 чи молодший за 18. Таких: '
            || SQL%ROWCOUNT);

        DELETE FROM tmp_work_set1
              WHERE 1 = 1;

        --Обраховуємо нову суму призначеного для рядків, в яких є 18річні. Обробляємо також випадки, коли таких осіб більше 1.
        INSERT INTO tmp_work_set1 (x_id1,
                                   x_dt1,
                                   x_dt2,
                                   x_sum1,
                                   x_sum2)
            SELECT pdp_id,
                   pdp_start_dt,
                   pdp_stop_dt,
                   pdp_sum,
                     pdp_sum
                   - NVL (
                         (SELECT SUM (pdd_value) - SUM (x_sum2)
                            FROM tmp_work_set2, pd_detail
                           WHERE     pdp_pd = x_id2
                                 AND pdd_pdp = pdp_id
                                 --AND pdd_ndp = CASE WHEN pd_ap < 0 THEN 290 ELSE 300 END
                                 AND pdd_ndp IN (290, 300)
                                 AND pdd_key = x_id3),
                         0)
              FROM pd_payment pdp, pc_decision
             WHERE     pdp_id IN (SELECT x_id4 FROM tmp_work_set2)
                   AND pdp_pd = pd_id;

        --Визначаємо необхідність обмеження запису PDP зліва
        UPDATE tmp_work_set1
           SET x_string1 = '+'
         WHERE     l_recalculate.rc_month > x_dt1
               AND l_recalculate.rc_month <= x_dt2;

        --Визначаємо необхідність заміни запису PDP
        UPDATE tmp_work_set1
           SET x_string1 = '++'
         WHERE l_recalculate.rc_month <= x_dt1;

        UPDATE tmp_work_set1
           SET x_id2 = CASE WHEN x_string1 = '+' THEN id_pd_payment (0) END,
               x_id3 = id_pd_payment (0)
         WHERE 1 = 1;

        --Обмежуємо запис зліва
        UPDATE pd_payment pdp
           SET history_status = 'H', pdp_hs_del = l_hs
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_set1
                         WHERE pdp_id = x_id1 AND x_string1 = '+')
               AND history_status = 'A';

        --Створюємо новий запис призначеного зліва, якщо ми розрізаємо запис
        INSERT INTO pd_payment (pdp_id,
                                pdp_pd,
                                pdp_npt,
                                pdp_start_dt,
                                pdp_stop_dt,
                                pdp_sum,
                                history_status,
                                pdp_hs_ins)
            SELECT x_id2,
                   pdp_pd,
                   pdp_npt,
                   pdp_start_dt,
                   l_recalculate.rc_month - 1,
                   pdp_sum,
                   'A',
                   l_hs
              FROM tmp_work_set1, pd_payment
             WHERE x_string1 = '+' AND pdp_id = x_id1;

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
                   x_id2,
                   pdd_row_order,
                   pdd_row_name,
                   pdd_value,
                   pdd_key,
                   pdd_ndp,
                   pdd_start_dt,
                   l_recalculate.rc_month - 1
              FROM pd_payment pdp, tmp_work_set1, pd_detail
             WHERE pdp_id = x_id1 AND x_string1 = '+' AND pdd_pdp = pdp_id;

        --Записуємо запис "замість"
        UPDATE pd_payment pdp
           SET history_status = 'H', pdp_hs_del = l_hs
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_set1
                         WHERE pdp_id = x_id1 AND x_string1 IN ('+', '++'))
               AND history_status = 'A';

        --Створюємо новий запис призначеного на "заміну". pdp_sum - нова, з поправкою на зменшені суми
        INSERT INTO pd_payment (pdp_id,
                                pdp_pd,
                                pdp_npt,
                                pdp_start_dt,
                                pdp_stop_dt,
                                pdp_sum,
                                history_status,
                                pdp_hs_ins)
            SELECT x_id3,
                   pdp_pd,
                   pdp_npt,
                   CASE
                       WHEN l_recalculate.rc_month < x_dt1 THEN x_dt1
                       ELSE l_recalculate.rc_month
                   END,
                   pdp_stop_dt,
                   x_sum2,
                   'A',
                   l_hs
              FROM tmp_work_set1, pd_payment
             WHERE x_string1 IN ('+', '++') AND pdp_id = x_id1;

        --Створюємо деталі pdp. pdd_value для 290 коду - нова, 2000 грн, по тим особам, кому виповнилось 18, але отримують 3000
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
                   x_id3,
                   pdd_row_order,
                   pdd_row_name,
                   CASE
                       WHEN --pdd_ndp = CASE WHEN pd_ap < 0 THEN 290 ELSE 300 END
                                pdd_ndp IN (290, 300)
                            AND EXISTS
                                    (SELECT 1
                                       FROM tmp_work_set2
                                      WHERE     x_id4 = pdp_id
                                            AND x_id3 = pdd_key)
                       THEN
                           2000
                       ELSE
                           pdd_value
                   END,
                   pdd_key,
                   pdd_ndp,
                   CASE
                       WHEN l_recalculate.rc_month < x_dt1 THEN x_dt1
                       ELSE l_recalculate.rc_month
                   END,
                   pdp_stop_dt
              FROM pd_payment  pdp,
                   tmp_work_set1,
                   pd_detail,
                   pc_decision
             WHERE     pdp_id = x_id1
                   AND x_string1 IN ('+', '++')
                   AND pdd_pdp = pdp_id
                   AND pdp_pd = pd_id;

        FOR xx
            IN (SELECT DISTINCT
                       pdp_pd,
                       pd_st,
                       uss_person.api$sc_tools.GET_PIB (z2.x_id5)
                           AS x_pib,
                       2000
                           AS x_new_sum
                  FROM tmp_work_set1  z1,
                       pd_payment,
                       pc_decision,
                       tmp_work_set2  z2
                 WHERE     z1.x_id1 = pdp_id
                       AND z1.x_string1 IN ('+', '++')
                       AND pdp_pd = pd_id
                       AND z1.x_id1 = z2.x_id4)
        LOOP
            API$PC_DECISION.write_pd_log (
                xx.pdp_pd,
                l_hs,
                xx.pd_st,
                   CHR (38)
                || '176#'
                || TO_CHAR (l_recalculate.rc_month, 'DD.MM.YYYY')
                || '#'
                || xx.x_pib
                || '#'
                || xx.x_new_sum,
                xx.pd_st);
        END LOOP;
    END;

    PROCEDURE Recalc_S_VPO_REF (p_rc_id   rc_candidates.rcc_rc%TYPE,
                                p_hs      histsession.hs_id%TYPE)
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        --l_hs := NVL(p_hs, TOOLS.GetHistSession);
        l_hs := p_hs;

        IF l_hs IS NULL
        THEN
            l_hs := TOOLS.GetHistSession;
        END IF;

        API$PC_BLOCK.CLEAR_BLOCK;

        --Просто всих кандидатів - в блокування з 1 числа місяця перерахунку
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
                                  b_dt)
            SELECT DISTINCT 0,
                            pd_pc,
                            pd_id,
                            x_b_tp,
                            rnp_id,
                            rnp_pnp_tp,
                            x_hs,
                            pd_ap,
                            rc_month - 1
              FROM (SELECT pd_pc,
                           pd_id,
                           'MR'     AS x_b_tp,
                           np.rnp_id,
                           np.rnp_pnp_tp,
                           p_hs     AS x_hs,
                           pd_ap,
                           rc_month
                      FROM recalculates,
                           rc_candidates,
                           pc_decision,
                           uss_ndi.v_ndi_reason_not_pay  np,
                           pd_pay_method                 pdm
                     WHERE     rcc_rc = p_rc_id
                           AND rcc_pc = pd_pc
                           AND rcc_rc = rc_id
                           AND pdm_pd = pd_id
                           AND pd_st = 'S'
                           AND pd_nst = 664
                           AND np.rnp_pay_tp = pdm_pay_tp
                           AND np.rnp_code = 'VPOREF' --Припинення виплати в зв'язку з зняттім з обліку довідки ВПО
                           AND np.history_status = 'A'
                           AND pdm_is_actual = 'T'
                           AND pdm.history_status = 'A'
                           AND EXISTS
                                   (SELECT 1
                                      FROM pd_accrual_period pdap
                                     WHERE     pdap_pd = pd_id
                                           AND rc_month BETWEEN pdap_start_dt
                                                            AND pdap_stop_dt
                                           AND pdap.history_status = 'A'));

        FOR xx IN (SELECT DISTINCT pd_id, pd_st
                     FROM tmp_pc_block, pc_decision
                    WHERE b_pd = pd_id)
        LOOP
            API$PC_DECISION.write_pd_log (xx.pd_id,
                                          l_hs,
                                          xx.pd_st,
                                          CHR (38) || '181',
                                          xx.pd_st);
        END LOOP;

        API$PC_BLOCK.decision_block (l_hs);
    END;

    PROCEDURE Recalc_S_EXT_VS (p_rc_id   rc_candidates.rcc_rc%TYPE,
                               p_hs      histsession.hs_id%TYPE)
    IS
        l_hs            histsession.hs_id%TYPE;
        l_recalculate   recalculates%ROWTYPE;
    BEGIN
        --ikis_sysweb.ikis_debug_pipe.WriteMsg('enter Recalc_S_VPO_18');
        --l_hs := NVL(p_hs, TOOLS.GetHistSession);
        l_hs := p_hs;

        IF l_hs IS NULL
        THEN
            l_hs := TOOLS.GetHistSession;
        END IF;

        SELECT *
          INTO l_recalculate
          FROM recalculates
         WHERE rc_id = p_rc_id;

        --ikis_sysweb.ikis_debug_pipe.WriteMsg(l_recalculate.rc_org_list);
        TOOLS.org_list_to_work_ids (3, l_recalculate.rc_org_list);

        DELETE FROM tmp_work_set2
              WHERE 1 = 1;

        DELETE FROM tmp_work_set3
              WHERE 1 = 1;

        --Знаходимо всі рішення, які закінчуються в період перерахунку
        INSERT INTO tmp_work_set2 (x_id1,
                                   x_dt1,
                                   x_dt2,
                                   x_id2,
                                   x_string2)
            WITH
                params
                AS
                    (SELECT rc_id                              AS x_rc,
                            ADD_MONTHS (
                                TRUNC (tools.ggpd ('WAR_MARTIAL_LAW_END'),
                                       'MM'),
                                -2)                            AS x_start_dt,
                            LAST_DAY (
                                ADD_MONTHS (
                                    tools.ggpd ('WAR_MARTIAL_LAW_END'),
                                    1))                        AS x_stop_dt,
                            tools.ggpd ('WAR_2PHASE_START')    AS x_2phase_war_start_dt
                       --SELECT rc_id AS x_rc, ADD_MONTHS(TRUNC(tools.ggpd('VPO_END_BY_709'), 'MM'), -3) AS x_start_dt,
                       --       LAST_DAY(tools.ggpd('VPO_END_BY_709')) AS x_stop_dt
                       FROM recalculates
                      WHERE rc_id = p_rc_id)
            SELECT DISTINCT
                   pd_id,
                   pd_stop_dt,
                   x_stop_dt,
                   pc_sc,
                   DECODE (pd_nst, 248, 'ALL', 'EXCL_18')     AS x_mode
              FROM pc_decision   ma,
                   rc_candidates,
                   personalcase  pc,
                   params,
                   pc_account
             WHERE     pd_nst IN (268, 265, 248)
                   AND pd_st = 'S'
                   AND rcc_rc = p_rc_id
                   AND pd_pc = pc_id
                   AND pc_id = rcc_pc
                   AND pd_pa = pa_id
                   AND pa_pc = pc_id
                   AND pa_org IN (SELECT orgs.x_id
                                    FROM tmp_work_ids3 orgs)
                   AND pd_stop_dt BETWEEN x_start_dt
                                      AND x_stop_dt - 1 / 86400 --ті, що закінчуються в 4-місячний строк
                   AND pd_stop_dt =
                       (SELECT MAX (pdap_stop_dt) --дата реальної дії співпадає з датою номінальної дії
                          FROM pd_accrual_period pdap
                         WHERE pdap.history_status = 'A' AND pdap_pd = pd_id)
                   AND pd_stop_dt =
                       (SELECT MAX (pdp_stop_dt) --дата останнього розрахованого призначення співпадає з датою номінальної дії
                          FROM pd_payment pdp
                         WHERE pdp.history_status = 'A' AND pdp_pd = pd_id)
                   AND NOT EXISTS
                           (SELECT 1 --Немає діючих рішеннь на даному ОР, які діють ПІСЛЯ закінчення дії рішення, що аналізується
                              FROM pc_decision sl, pd_accrual_period pdap
                             WHERE     sl.pd_pa = pa_id
                                   AND pdap.pdap_pd = sl.pd_id
                                   AND pdap.history_status = 'A'
                                   AND pdap.pdap_stop_dt > ma.pd_stop_dt)
                   AND (   (    pd_nst IN (265, 268)
                            AND EXISTS
                                    (SELECT 1
                                       FROM uss_esr.appeal
                                      WHERE     pd_ap = ap_id
                                            AND ap_reg_dt <
                                                x_2phase_war_start_dt))
                        OR pd_nst IN (248));

        --  write_rc_log(p_rc_id, l_hs, 'F', NULL, l_recalculate.rc_st);

        write_message (
            1,
               'Знайдено '
            || SQL%ROWCOUNT
            || ' кандидатів, рішення по яким будуть подовжені.');

        DELETE FROM tmp_work_set1
              WHERE 1 = 1;

        --Знаходимо записи призначеного, які будуть подовжені
        INSERT INTO tmp_work_set1 (x_id1,
                                   x_id2,
                                   x_dt1,
                                   x_dt2,
                                   x_sum1,
                                   x_string1,
                                   x_string2)
            SELECT pdp_pd,
                   pdp_id,
                   x_dt1 + 1,
                   x_dt2,
                   pdp_sum,
                   '+',
                   x_string2     AS x_mode
              FROM tmp_work_set2, pd_payment
             WHERE     x_id1 = pdp_pd
                   AND history_status = 'A'
                   AND x_dt1 = pdp_stop_dt;

        --Створюємо таблицю розривів для тих, в кого є особи, які досягли 18-річного віку в періоді подовження
        INSERT INTO tmp_calc_dates (cd_pd, cd_begin)
            SELECT DISTINCT
                   pdf_pd,
                   CASE ll
                       WHEN 1
                       THEN
                           x_dt1
                       WHEN 2
                       THEN
                           LAST_DAY (ADD_MONTHS (pdf_birth_dt, 216)) + 1
                       WHEN 3
                       THEN
                           x_dt2 + 1
                   END
              FROM pd_family  mf,
                   tmp_work_set1,
                   (    SELECT LEVEL     AS ll
                          FROM DUAL
                    CONNECT BY LEVEL <= 3)
             WHERE     mf.history_status = 'A'
                   AND x_string2 = 'EXCL_18'
                   AND pdf_pd = x_id1
                   AND ADD_MONTHS (pdf_birth_dt, 216) <= x_dt2 --ті, хто в періоді подовження досягають 18 років
                   --AND ADD_MONTHS(pdf_birth_dt, 216) BETWEEN x_dt1 AND x_dt2 --ті, хто в періоді подовження досягають 18 років
                   AND ADD_MONTHS (pdf_birth_dt, 216) <> x_dt2; --тих, хто досягає в останній день подовження (а це останній день місяця) - ігноруємо

        UPDATE /*+full(ma1)*/
               tmp_calc_dates ma1
           SET cd_end =
                   (SELECT /*+index(sl i_tcd_set1)*/
                           MIN (cd_begin) - 1
                      FROM tmp_calc_dates sl
                     WHERE     sl.cd_pd = ma1.cd_pd
                           AND sl.cd_begin > ma1.cd_begin)
         WHERE 1 = 1;

        DELETE FROM tmp_calc_dates
              WHERE cd_end IS NULL;

        --Видаляємо тих, в кого є 18річний в періоді подовження і сума призначеного не співпадає з сумою розподіленого по особам в зверненні (тобто - не виконано розподіл)
        DELETE FROM tmp_work_set1
              WHERE     EXISTS
                            (SELECT 1
                               FROM tmp_calc_dates
                              WHERE cd_pd = x_id1)
                    AND x_sum1 <> NVL ( (SELECT SUM (pdd_value)
                                           FROM pd_detail,
                                                pd_family  mf,
                                                pd_payment,
                                                pc_decision
                                          WHERE     pdd_pdp = x_id2
                                                AND pdf_pd = x_id1
                                                --AND pdd_ndp = CASE WHEN pd_ap < 0 THEN 290 ELSE 300 END
                                                AND pdd_ndp IN (290,
                                                                291,
                                                                292,
                                                                293,
                                                                294,
                                                                295,
                                                                300)
                                                AND pdd_key = pdf_id
                                                AND pdd_pdp = pdp_id
                                                AND pdp_pd = pd_id
                                                AND mf.history_status = 'A'),
                                       0);

        --Видаляємо тих, по кому не можемо провести подовження.
        DELETE FROM tmp_work_set2 ma
              WHERE NOT EXISTS
                        (SELECT 1
                           FROM tmp_work_set1 sl
                          WHERE ma.x_id1 = sl.x_id1);

        INSERT INTO tmp_work_set1 (x_id1,
                                   x_id2,
                                   x_dt1,
                                   x_dt2,
                                   x_sum1,
                                   x_string1,
                                   x_string2)
            SELECT x_id1,
                   x_id2,
                   cd_begin,
                   cd_end,
                     x_sum1
                   - NVL (
                         (SELECT SUM (pdd_value)
                            FROM pd_detail,
                                 pd_family  mf,
                                 pd_payment,
                                 pc_decision
                           WHERE     pdd_pdp = x_id2
                                 --AND pdd_ndp = CASE WHEN pd_ap < 0 THEN 290 ELSE 300 END
                                 AND pdd_ndp IN (290,
                                                 291,
                                                 292,
                                                 293,
                                                 294,
                                                 295,
                                                 300)
                                 AND pdd_key = pdf_id
                                 AND LAST_DAY (
                                         ADD_MONTHS (pdf_birth_dt, 216)) <
                                     cd_begin
                                 AND pdd_pdp = pdp_id
                                 AND pdp_pd = pd_id
                                 AND mf.history_status = 'A'),
                         0),
                   '++',
                   x_string2
              FROM tmp_work_set1, tmp_calc_dates
             WHERE x_id1 = cd_pd AND cd_begin >= x_dt1;

        DELETE FROM tmp_work_set1 ma
              WHERE     x_string1 = '+'
                    AND EXISTS
                            (SELECT 1
                               FROM tmp_work_set1 sl
                              WHERE     ma.x_id1 = sl.x_id1
                                    AND sl.x_string1 = '++');

        UPDATE tmp_work_set1
           SET x_id3 = id_pd_payment (0)
         WHERE 1 = 1;

        --Записуємо запис подовження призначеного
        INSERT INTO pd_payment (pdp_id,
                                pdp_pd,
                                pdp_npt,
                                pdp_start_dt,
                                pdp_stop_dt,
                                pdp_sum,
                                history_status,
                                pdp_hs_ins,
                                pdp_src,
                                pdp_rc)
            SELECT x_id3,
                   x_id1,
                   pdp_npt,
                   x_dt1,
                   x_dt2,
                   x_sum1,
                   'A',
                   l_hs,
                   'EMS',
                   p_rc_id
              FROM tmp_work_set1, pd_payment
             WHERE pdp_id = x_id2;

        --Записуємо деталі запису подовження призначеного
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
                   x_id3,
                   pdd_row_order,
                   pdd_row_name,
                   CASE
                       WHEN     x_string2 = 'EXCL_18'
                            --AND pdd_ndp = CASE WHEN pd_ap < 0 THEN 290 ELSE 300 END --якщо це "по особі" і особа вже досягла 18річчя, то по ній - нуль
                            AND pdd_ndp IN (290,
                                            291,
                                            292,
                                            293,
                                            294,
                                            295,
                                            300)
                            AND EXISTS
                                    (SELECT 1
                                       FROM pd_family
                                      WHERE     pdf_pd = pdp_pd
                                            AND LAST_DAY (
                                                    ADD_MONTHS (pdf_birth_dt,
                                                                216)) <
                                                x_dt1
                                            AND pdd_key = pdf_id)
                       THEN
                           0
                       ELSE
                           pdd_value
                   END,
                   pdd_key,
                   pdd_ndp,
                   x_dt1,
                   x_dt2,
                   pdd_npt
              FROM tmp_work_set1,
                   pd_detail,
                   pd_payment,
                   pc_decision
             WHERE pdd_pdp = x_id2 AND pdd_pdp = pdp_id AND pdp_pd = pd_id;

        -- подовжуємо записи по членах родини
        UPDATE pd_family pdf
           SET pdf.pdf_stop_dt =
                   (SELECT x_dt2
                      FROM tmp_work_set2
                     WHERE x_id1 = pdf_pd)
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_set2
                         WHERE x_id1 = pdf_pd)
               AND (pdf.history_status = 'A' OR pdf.history_status IS NULL)
               AND (   pdf.pdf_stop_dt = (SELECT pd_stop_dt
                                            FROM pc_decision pd
                                           WHERE pdf_pd = pd_id)
                    OR pdf.pdf_stop_dt IS NULL);

        --Подовжуємо номінальний строк дії
        UPDATE pc_decision
           SET pd_stop_dt =
                   (SELECT x_dt2
                      FROM tmp_work_set2
                     WHERE x_id1 = pd_id)
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_work_set2
                     WHERE x_id1 = pd_id);

        --Подовжуємо реальний строк дії
        INSERT INTO pd_accrual_period (pdap_id,
                                       pdap_pd,
                                       pdap_start_dt,
                                       pdap_stop_dt,
                                       history_status,
                                       pdap_hs_ins)
            SELECT 0, x_id1, x_dt1 + 1, x_dt2, 'A', l_hs FROM tmp_work_set2;

        --Подовжуємо строк дії параметрів виплати
        UPDATE pd_pay_method
           SET pdm_stop_dt =
                   (SELECT x_dt2
                      FROM tmp_work_set2
                     WHERE x_id1 = pdm_pd)
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_set2
                         WHERE x_id1 = pdm_pd)
               AND pdm_is_actual = 'T'
               AND history_status = 'A';

        -- Перелік записів по відрахуванням з Dn_Detail, для яких потрібно зробити подовження (закінчуються останнім днем період з якого подовжуємо)
        INSERT INTO tmp_work_set3 (x_id1,
                                   x_id2,
                                   x_dt1,
                                   x_dt2)
            SELECT DISTINCT dnd.dnd_id,
                            d.dn_id,
                            x_dt1,
                            x_dt2
              FROM tmp_work_set1
                   JOIN pc_decision ON pd_id = x_id1
                   JOIN Deduction d ON d.dn_pa = pd_pa
                   JOIN Dn_Detail dnd ON dnd.dnd_dn = d.dn_id
             WHERE     d.DN_NDN IN (41,
                                    67,
                                    68,
                                    81)
                   AND d.dn_st = 'R'
                   AND dnd.dnd_stop_dt = x_dt1 - 1;

        -- Подовжуэмо выдрахування
        INSERT INTO Dn_Detail (Dnd_Id,
                               Dnd_Dn,
                               Dnd_Start_Dt,
                               Dnd_Stop_Dt,
                               Dnd_Tp,
                               Dnd_Value,
                               History_Status,
                               Dnd_Psc,
                               Dnd_Hs_Ins)
            SELECT 0         AS x_Dnd_Id,
                   dnd.Dnd_Dn,
                   x_dt1     AS x_Start_Dt,
                   x_dt2     AS x_Stop_Dt,
                   dnd.Dnd_Tp,
                   dnd.Dnd_Value,
                   dnd.History_Status,
                   dnd.Dnd_Psc,
                   l_hs      AS x_Hs_Ins
              FROM Dn_Detail dnd JOIN tmp_work_set3 ON x_id1 = dnd.dnd_id;

        --Пишемо протокол в подовжені рішення
        FOR xx IN (SELECT pd_id, pd_st, pd_stop_dt
                     FROM tmp_work_set2 z1, pc_decision
                    WHERE x_id1 = pd_id)
        LOOP
            API$PC_DECISION.write_pd_log (
                xx.pd_id,
                l_hs,
                xx.pd_st,
                CHR (38) || '209#' || TO_CHAR (xx.pd_stop_dt, 'DD.MM.YYYY'),
                xx.pd_st);
        END LOOP;
    END;

    PROCEDURE Recalc_S_MF_STOP (p_rc_id   rc_candidates.rcc_rc%TYPE,
                                p_hs      histsession.hs_id%TYPE)
    IS
        l_hs            histsession.hs_id%TYPE;
        l_recalculate   recalculates%ROWTYPE;
    BEGIN
        --l_hs := NVL(p_hs, TOOLS.GetHistSession);
        l_hs := p_hs;

        IF l_hs IS NULL
        THEN
            l_hs := TOOLS.GetHistSession;
        END IF;

        SELECT *
          INTO l_recalculate
          FROM recalculates
         WHERE rc_id = p_rc_id;

        TOOLS.org_list_to_work_ids (3, l_recalculate.rc_org_list);

        API$PC_BLOCK.CLEAR_BLOCK;

        --Просто всих кандидатів - в блокування з 1 числа місяця перерахунку
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
                   'MR'     AS x_b_tp,
                   rnp_id,
                   rnp_pnp_tp,
                   p_hs     AS x_hs,
                   pd_ap,
                   rc_month - 1,
                   x_merc
              FROM (SELECT DISTINCT
                           pd_pc,
                           pd_id,
                           pd_ap,
                           rc_month,
                           pdm_pay_tp,
                           FIRST_VALUE (merc_id)
                               OVER (
                                   PARTITION BY pd_id
                                   ORDER BY
                                       CASE merc_type_rec
                                           WHEN 443 THEN 100
                                           WHEN 442 THEN 90
                                           WHEN 432 THEN 80
                                           WHEN 434 THEN 70
                                           WHEN 439 THEN 60
                                           WHEN 440 THEN 50
                                           WHEN 441 THEN 40
                                           ELSE 30
                                       END DESC
                                   RANGE BETWEEN UNBOUNDED PRECEDING
                                         AND     UNBOUNDED FOLLOWING)    AS x_merc --MIN(merc_id) AS x_merc
                      FROM recalculates,
                           rc_candidates,
                           pc_decision,
                           personalcase       pc,
                           mass_exchanges,
                           me_minfin_request_rows,
                           me_minfin_recomm_rows,
                           pd_accrual_period  pdap,
                           pd_pay_method      pdm
                     WHERE     rcc_rc = p_rc_id
                           AND rcc_pc = pd_pc
                           AND rcc_rc = rc_id
                           AND pd_nst IN (664)
                           AND pd_st IN ('S', 'PS')
                           AND pc.com_org IN (SELECT orgs.x_id
                                                FROM tmp_work_ids3 orgs)
                           AND pd_pc = pc_id
                           AND me_month BETWEEN ADD_MONTHS (rc_month, -3)
                                            AND LAST_DAY (rc_month)
                           AND me_tp = 'MF'
                           AND merc_memr = memr_id
                           AND merc_st = 'O'
                           AND merc_type_rec IN (432,
                                                 442,
                                                 443,
                                                 444,
                                                 434,
                                                 435,
                                                 439,
                                                 440,
                                                 441,
                                                 430,
                                                 455,
                                                 456,
                                                 462,
                                                 457,
                                                 458,
                                                 459,
                                                 460,
                                                 461,
                                                 464,
                                                 463)
                           AND memr_pc = pc_id
                           AND '' || merc_type_pref IN
                                   (SELECT npt_code
                                      FROM uss_ndi.v_ndi_payment_type,
                                           pd_payment  pdp
                                     WHERE     pdp_npt = npt_id
                                           AND pdp_pd = pd_id
                                           AND pdp.history_status = 'A')
                           AND pdap_pd = pd_id
                           AND pdap.history_status = 'A'
                           AND rc_month BETWEEN pdap_start_dt
                                            AND pdap_stop_dt
                           AND pdm_pd = pd_id
                           AND pdm_is_actual = 'T'
                           AND pdm.history_status = 'A'),
                   me_minfin_recomm_rows,
                   uss_ndi.v_ndi_reason_not_pay  np
             WHERE     (   (np.rnp_code = 'MF_OVER30' AND merc_type_rec = 432)
                        OR (    np.rnp_code = 'MF_OVER_07'
                            AND merc_type_rec = 444)
                        OR (    np.rnp_code = 'MF_DBL_EOS'
                            AND merc_type_rec = 442)
                        OR (np.rnp_code = 'MF_DEAD' AND merc_type_rec = 443)
                        OR (np.rnp_code = 'MF_434' AND merc_type_rec = 434)
                        OR (np.rnp_code = 'MF_435' AND merc_type_rec = 435)
                        OR (np.rnp_code = 'MF_439' AND merc_type_rec = 439)
                        OR (np.rnp_code = 'MF_440' AND merc_type_rec = 440)
                        OR (np.rnp_code = 'MF_441' AND merc_type_rec = 441)
                        OR (np.rnp_code = 'MF_430' AND merc_type_rec = 430)
                        OR (np.rnp_code = 'MF_455' AND merc_type_rec = 455)
                        OR (np.rnp_code = 'MF_456' AND merc_type_rec = 456)
                        OR (np.rnp_code = 'MF_462' AND merc_type_rec = 462)
                        OR (np.rnp_code = 'MF_457' AND merc_type_rec = 457)
                        OR (np.rnp_code = 'MF_458' AND merc_type_rec = 458)
                        OR (np.rnp_code = 'MF_459' AND merc_type_rec = 459)
                        OR (np.rnp_code = 'MF_460' AND merc_type_rec = 460)
                        OR (np.rnp_code = 'MF_461' AND merc_type_rec = 461)
                        OR (np.rnp_code = 'MF_464' AND merc_type_rec = 464)
                        OR (np.rnp_code = 'MF_463' AND merc_type_rec = 463))
                   AND x_merc = merc_id
                   AND np.rnp_pay_tp = pdm_pay_tp
                   AND np.history_status = 'A';

        FOR xx
            IN (SELECT DISTINCT pd_id,
                                pd_st,
                                rnp_code,
                                rnp_id
                  FROM tmp_pc_block,
                       pc_decision,
                       uss_ndi.v_ndi_reason_not_pay
                 WHERE b_pd = pd_id AND b_rnp = rnp_id)
        LOOP
            API$PC_DECISION.write_pd_log (xx.pd_id,
                                          l_hs,
                                          xx.pd_st,
                                          CHR (38) || '248#@4@' || xx.rnp_id,
                                          xx.pd_st);
        END LOOP;

        --Переводимо нарахування в стан Редагується для тих справ, по яким є рішення, що будуть призупинятись
        UPDATE accrual ac
           SET ac_st = 'E'
         WHERE     ac_month =
                   (SELECT bp_month
                      FROM billing_period
                     WHERE     bp_org = ac.com_org
                           AND bp_class = 'VPO'
                           AND bp_tp = 'PR'
                           AND bp_st = 'R')
               AND AC_pc IN (SELECT b_pc FROM tmp_pc_block);

        --Переводимо рекомендацію в стан Виконано
        UPDATE me_minfin_recomm_rows
           SET merc_st = 'V'
         WHERE merc_id IN (SELECT b_at_src FROM tmp_pc_block);

        --Переводимо запит в стан Виконано рекомендацію
        UPDATE me_minfin_request_rows
           SET memr_st = 'V'
         WHERE memr_id IN
                   (SELECT merc_memr
                      FROM me_minfin_recomm_rows
                     WHERE merc_id IN (SELECT b_at_src FROM tmp_pc_block));

        --Формуємо запис виконання рекомендації - прийнятого рішення
        INSERT INTO me_minfin_result_rows (mesr_id,
                                           mesr_me,
                                           mesr_memr,
                                           mesr_merc,
                                           mesr_ef,
                                           mesr_id_rec,
                                           mesr_id_fam,
                                           mesr_ris_code,
                                           mesr_klcom_coddec,
                                           mesr_res_date,
                                           mesr_summ_p,
                                           mesr_res_start,
                                           mesr_res_end,
                                           mesr_content_rec,
                                           mesr_type_rec,
                                           mesr_rec_code,
                                           mesr_rec_date,
                                           mesr_st,
                                           mesr_d14)
            SELECT 0,
                   merc_me,
                   merc_memr,
                   merc_id,
                   NULL,
                   merc_id_rec,
                   merc_id_fam,
                   d14_ris_code,
                   d14_klcom_coddec,
                   TRUNC (SYSDATE),
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   merc_type_rec,
                   d14_ris_code,
                   TRUNC (SYSDATE),
                   'P',
                   d14_id
              FROM me_minfin_recomm_rows, uss_ndi.v_ndi_minfin_d14
             WHERE     merc_id IN (SELECT b_at_src FROM tmp_pc_block)
                   AND d14_id = 4;

        --Очищаємо b_at_src, яке використали для роботи з рядками рекомендацій.
        UPDATE tmp_pc_block
           SET b_at_src = NULL
         WHERE b_at_src IS NOT NULL;

        --Виконуємо блокування рішень
        API$PC_BLOCK.decision_block (l_hs);
    END;

    PROCEDURE Recalc_S_ODEATH (p_rc_id   rc_candidates.rcc_rc%TYPE,
                               p_hs      histsession.hs_id%TYPE)
    IS
        l_hs   histsession.hs_id%TYPE;
        l_rc   recalculates%ROWTYPE;
    BEGIN
        SELECT *
          INTO l_rc
          FROM recalculates
         WHERE rc_id = p_rc_id;

        --l_hs := NVL(p_hs, TOOLS.GetHistSession);
        l_hs := p_hs;

        IF l_hs IS NULL
        THEN
            l_hs := TOOLS.GetHistSession;
        END IF;

        API$PC_BLOCK.CLEAR_BLOCK;

        --Просто всих кандидатів - в блокування з 1 числа місяця перерахунку
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
                                  b_dt)
            SELECT DISTINCT 0,
                            pd_pc,
                            pd_id,
                            x_b_tp,
                            rnp_id,
                            rnp_pnp_tp,
                            x_hs,
                            pd_ap,
                            LAST_DAY (x_death_dt)
              ----!!! Призупинення з 1 числа місяця, настуного за датою смерті!!!
              FROM (SELECT pd_pc,
                           pd_id,
                           'MR'                                         AS x_b_tp,
                           np.rnp_id,
                           np.rnp_pnp_tp,
                           p_hs                                         AS x_hs,
                           pd_ap,
                           rc_month,
                           NVL (
                               uss_person.API$SC_TOOLS.get_death_dt (pc_sc,
                                                                     1),
                               (SELECT MIN (
                                           uss_person.API$SC_TOOLS.get_death_dt (
                                               pdf_sc,
                                               1))
                                  FROM pd_family mf
                                 WHERE     pdf_pd = pd_id
                                       AND mf.history_status = 'A'))    AS x_death_dt
                      FROM recalculates,
                           rc_candidates,
                           pc_decision,
                           uss_ndi.v_ndi_reason_not_pay  np,
                           pd_pay_method                 pdm,
                           personalcase
                     WHERE     rcc_rc = p_rc_id
                           AND pd_pc = pc_id
                           AND rcc_pc = pc_id
                           AND rcc_pc = pd_pc
                           AND rcc_rc = rc_id
                           AND pdm_pd = pd_id
                           AND pd_st = 'S'
                           AND pd_nst IN (248,
                                          249,
                                          265,
                                          267,
                                          268,
                                          269,
                                          664)
                           AND np.rnp_pay_tp = pdm_pay_tp
                           AND np.rnp_code = 'DRAC_AZD' --Припинення виплати в зв'язку з "Надійшов АЗ про смерть із ДРАЦ"
                           AND np.history_status = 'A'
                           AND pdm_is_actual = 'T'
                           AND pdm.history_status = 'A'
                           AND pd_st IN ('S', 'PS')
                           AND (   EXISTS
                                       (SELECT 1 --Є документ про смерть по особі-власнику ЕОС
                                          FROM uss_person.v_sc_document
                                         WHERE     scd_sc = pc_sc
                                               AND scd_st = '1'
                                               AND scd_ndt = 89)
                                OR EXISTS
                                       (SELECT 1 --Або є документ про смерть по учаснику рішення
                                          FROM uss_person.v_sc_document,
                                               pd_family  xf
                                         WHERE     pdf_pd = pd_id
                                               AND scd_sc = pdf_sc
                                               AND scd_st = '1'
                                               AND scd_ndt = 89
                                               AND xf.history_status = 'A')))
             WHERE     EXISTS
                           (SELECT 1
                              FROM pd_accrual_period pdap
                             WHERE     pdap_pd = pd_id
                                   AND x_death_dt BETWEEN pdap_start_dt
                                                      AND pdap_stop_dt
                                   AND pdap.history_status = 'A')
                   AND x_death_dt IS NOT NULL; --Нічого не блокуємо, якщо не змогли вирахувати дату смерті-блокування

        INSERT INTO uss_person.tmp_work_ids (x_id)
            SELECT scde_id
              FROM uss_person.v_scd_event,
                   uss_person.v_sc_document,
                   personalcase,
                   tmp_pc_block
             WHERE     b_pc = pc_id
                   AND pc_sc = scd_sc
                   AND scde_scd = scd_id
                   AND scd_ndt = 89
                   AND scd_st = '1'
                   AND scde_event = 'CR'
                   AND scde_dt BETWEEN l_rc.rc_month
                                   AND   ADD_MONTHS (l_rc.rc_month, 1)
                                       - 1 / 86400
            UNION
            SELECT scde_id
              FROM uss_person.v_scd_event,
                   uss_person.v_sc_document,
                   pd_family  mf,
                   tmp_pc_block
             WHERE     b_pd = pdf_pd
                   AND pdf_sc = scd_sc
                   AND scde_scd = scd_id
                   AND mf.history_status = 'A'
                   AND scd_ndt = 89
                   AND scd_st = '1'
                   AND scde_event = 'CR'
                   AND scde_dt BETWEEN l_rc.rc_month
                                   AND   ADD_MONTHS (l_rc.rc_month, 1)
                                       - 1 / 86400;

        uss_person.api$scd_event.use_by_rc (2,
                                            NULL,
                                            p_rc_id,
                                            NULL);

        FOR xx IN (SELECT DISTINCT pd_id, pd_st
                     FROM tmp_pc_block, pc_decision
                    WHERE b_pd = pd_id)
        LOOP
            API$PC_DECISION.write_pd_log (xx.pd_id,
                                          l_hs,
                                          xx.pd_st,
                                          CHR (38) || '258',
                                          xx.pd_st);
        END LOOP;

        --Ініціалізація рішень про припинення виплати допомог за масовим перерахунком по виявленню АЗ про смерть
        API$ERRAND.init_act_by_odeath (1, p_rc_id);

        --Блокування рішеннь
        API$PC_BLOCK.decision_block (l_hs);
    END;


    PROCEDURE Recalc_S_EXT_2NST (p_rc_id   rc_candidates.rcc_rc%TYPE,
                                 p_hs      histsession.hs_id%TYPE)
    IS
        l_hs            histsession.hs_id%TYPE;
        l_recalculate   recalculates%ROWTYPE;
    BEGIN
        --ikis_sysweb.ikis_debug_pipe.WriteMsg('enter Recalc_S_VPO_18');
        --l_hs := NVL(p_hs, TOOLS.GetHistSession);
        l_hs := p_hs;

        IF l_hs IS NULL
        THEN
            l_hs := TOOLS.GetHistSession;
        END IF;

        SELECT *
          INTO l_recalculate
          FROM recalculates
         WHERE rc_id = p_rc_id;

        --ikis_sysweb.ikis_debug_pipe.WriteMsg(l_recalculate.rc_org_list);
        TOOLS.org_list_to_work_ids (3, l_recalculate.rc_org_list);

        DELETE FROM tmp_work_set2
              WHERE 1 = 1;

        DELETE FROM tmp_work_set3
              WHERE 1 = 1;

        --Знаходимо всі рішення, які закінчуються в період перерахунку
        INSERT INTO tmp_work_set2 (x_id1,
                                   x_dt1,
                                   x_dt2,
                                   x_id2,
                                   x_string2)
            WITH
                params
                AS
                    (SELECT rc_id                         AS x_rc,
                            ADD_MONTHS (rc_month, -1)     AS x_start_dt,
                            rc_month - 1                  AS x_stop_dt,
                            LAST_DAY (rc_month)           AS x_to_dt
                       FROM recalculates
                      WHERE rc_id = p_rc_id)
            SELECT DISTINCT pd_id,
                            pd_stop_dt,
                            x_to_dt,
                            pc_sc,
                            'ALL'    /*DECODE(pd_nst, 248, 'ALL', 'EXCL_18')*/
                                      AS x_mode
              FROM rc_candidates,
                   pc_decision   pd,
                   personalcase  pc,
                   appeal,
                   params
             WHERE     pd_nst IN (249, 267)
                   AND pd_st = 'S'
                   AND pd.com_org IN (SELECT orgs.x_id
                                        FROM tmp_work_ids3 orgs)
                   AND pd_pc = pc_id
                   AND rcc_pc = pc_id
                   AND rcc_rc = p_rc_id
                   AND pd_ap = ap_id
                   AND ap_reg_dt < uss_esr.Tools.ggpd ('WAR_2PHASE_START')
                   AND pd_stop_dt BETWEEN x_start_dt AND x_stop_dt --Рішення завершується в попередньому місяці від розрахункового місяця
                   AND pd_stop_dt =
                       (SELECT MAX (pdap_stop_dt) --Повіністю співпадає період дії рішення з первинним періодом дії рішення
                          FROM pd_accrual_period pdap
                         WHERE pdap.history_status = 'A' AND pdap_pd = pd_id)
                   AND pd_stop_dt =
                       (SELECT MAX (pdp_stop_dt) --Повністю співпадає період дії призначення з первинним періодом дії рішення
                          FROM pd_payment pdp
                         WHERE pdp.history_status = 'A' AND pdp_pd = pd_id)
                   AND EXISTS
                           (SELECT 1
                              FROM uss_ndi.v_ndi_index_aspod_config,
                                   (SELECT apda_val_string     AS x_index
                                      FROM uss_esr.Ap_Document_Attr  a,
                                           uss_esr.Ap_Document       d
                                     WHERE     a.Apda_Apd = d.Apd_Id
                                           AND d.Apd_Ndt = 600
                                           AND apda_nda = 599
                                           AND apda_ap = pd_ap
                                           AND d.apd_app IN
                                                   (SELECT p.app_id
                                                      FROM uss_esr.v_ap_person
                                                           p
                                                     WHERE     p.app_ap =
                                                               pd_ap
                                                           AND p.app_tp =
                                                               CASE
                                                                   WHEN ap_tp IN
                                                                            ('U',
                                                                             'A')
                                                                   THEN
                                                                       'O'
                                                                   ELSE
                                                                       'Z'
                                                               END
                                                           AND p.app_sc =
                                                               pc.pc_sc
                                                           AND p.history_status =
                                                               'A')
                                           AND d.History_Status = 'A'
                                           AND a.Apda_Ap = ap_id
                                           AND a.History_Status = 'A') --Індекс адреси проживання з звернення
                             WHERE     x_index IN
                                           (niac_post_index, niac_vipl_index) --Індекси з довідника АСОПД <-> КАТОТТГ
                                   AND EXISTS
                                           (SELECT 1
                                              FROM uss_ndi.v_ndi_kaot_state
                                                   kaots,
                                                   uss_ndi.v_ndi_normative_act
                                                   nna
                                             WHERE     kaots_kaot = niac_kaot
                                                   AND kaots.history_status =
                                                       'A'
                                                   AND kaots_nna = nna_id
                                                   --AND nna_num = '309' --По 309 поставнові
                                                   AND nna.history_status =
                                                       'A'
                                                   AND kaots_tp IN
                                                           ('TO', 'BD', 'PMO') --В бойових діях, окупації чи можливих бойових діях
                                                   AND (   kaots_stop_dt BETWEEN x_start_dt
                                                                             AND x_stop_dt --Завершили стан бойових лій тощо в попередньому місяці від розрахункового
                                                        OR kaots_stop_dt
                                                               IS NULL)));

        --  write_rc_log(p_rc_id, l_hs, 'F', NULL, l_recalculate.rc_st);

        write_message (
            1,
               'Знайдено '
            || SQL%ROWCOUNT
            || ' кандидатів, рішення по яким будуть подовжені.');

        DELETE FROM tmp_work_set1
              WHERE 1 = 1;

        --Знаходимо записи призначеного, які будуть подовжені
        INSERT INTO tmp_work_set1 (x_id1,
                                   x_id2,
                                   x_dt1,
                                   x_dt2,
                                   x_sum1,
                                   x_string1,
                                   x_string2)
            SELECT pdp_pd,
                   pdp_id,
                   x_dt1 + 1,
                   x_dt2,
                   pdp_sum,
                   '+',
                   x_string2     AS x_mode
              FROM tmp_work_set2, pd_payment
             WHERE     x_id1 = pdp_pd
                   AND history_status = 'A'
                   AND x_dt1 = pdp_stop_dt;

        --Створюємо таблицю розривів для тих, в кого є особи, які досягли 18-річного віку в періоді подовження
        INSERT INTO tmp_calc_dates (cd_pd, cd_begin)
            SELECT DISTINCT
                   pdf_pd,
                   CASE ll
                       WHEN 1
                       THEN
                           x_dt1
                       WHEN 2
                       THEN
                           LAST_DAY (ADD_MONTHS (pdf_birth_dt, 216)) + 1
                       WHEN 3
                       THEN
                           x_dt2 + 1
                   END
              FROM pd_family  mf,
                   tmp_work_set1,
                   (    SELECT LEVEL     AS ll
                          FROM DUAL
                    CONNECT BY LEVEL <= 3)
             WHERE     mf.history_status = 'A'
                   AND x_string2 = 'EXCL_18'
                   AND pdf_pd = x_id1
                   AND ADD_MONTHS (pdf_birth_dt, 216) BETWEEN x_dt1 AND x_dt2 --ті, хто в періоді подовження досягають 18 років
                   AND ADD_MONTHS (pdf_birth_dt, 216) <> x_dt2; --тих, хто досягає в останній день подовження (а це останній день місяця) - ігноруємо

        UPDATE /*+full(ma1)*/
               tmp_calc_dates ma1
           SET cd_end =
                   (SELECT /*+index(sl i_tcd_set1)*/
                           MIN (cd_begin) - 1
                      FROM tmp_calc_dates sl
                     WHERE     sl.cd_pd = ma1.cd_pd
                           AND sl.cd_begin > ma1.cd_begin)
         WHERE 1 = 1;

        DELETE FROM tmp_calc_dates
              WHERE cd_end IS NULL;

        --Видаляємо тих, в кого є 18річний в періоді подовження і сума призначеного не співпадає з сумою розподіленого по особам в зверненні (тобто - не виконано розподіл)
        DELETE FROM tmp_work_set1
              WHERE     EXISTS
                            (SELECT 1
                               FROM tmp_calc_dates
                              WHERE cd_pd = x_id1)
                    AND x_sum1 <>
                        NVL (
                            (SELECT SUM (pdd_value)
                               FROM pd_detail,
                                    pd_family  mf,
                                    pd_payment,
                                    pc_decision
                              WHERE     pdd_pdp = x_id2
                                    AND mf.history_status = 'A'
                                    AND pdf_pd = x_id1
                                    --AND pdd_ndp = CASE WHEN pd_ap < 0 THEN 290 ELSE 300 END
                                    AND pdd_ndp IN (290, 300)
                                    AND pdd_key = pdf_id
                                    AND pdd_pdp = pdp_id
                                    AND pdp_pd = pd_id),
                            0);

        --Видаляємо тих, по кому не можемо провести подовження.
        DELETE FROM tmp_work_set2 ma
              WHERE NOT EXISTS
                        (SELECT 1
                           FROM tmp_work_set1 sl
                          WHERE ma.x_id1 = sl.x_id1);

        INSERT INTO tmp_work_set1 (x_id1,
                                   x_id2,
                                   x_dt1,
                                   x_dt2,
                                   x_sum1,
                                   x_string1)
            SELECT x_id1,
                   x_id2,
                   cd_begin,
                   cd_end,
                     x_sum1
                   - NVL (
                         (SELECT SUM (pdd_value)
                            FROM pd_detail,
                                 pd_family  mf,
                                 pd_payment,
                                 pc_decision
                           WHERE     pdd_pdp = x_id2
                                 AND mf.history_status = 'A'
                                 --AND pdd_ndp = CASE WHEN pd_ap < 0 THEN 290 ELSE 300 END
                                 AND pdd_ndp IN (290, 300)
                                 AND pdd_key = pdf_id
                                 AND LAST_DAY (
                                         ADD_MONTHS (pdf_birth_dt, 216)) <
                                     cd_begin
                                 AND pdd_pdp = pdp_id
                                 AND pdp_pd = pd_id),
                         0),
                   '++'
              FROM tmp_work_set1, tmp_calc_dates
             WHERE x_id1 = cd_pd;

        DELETE FROM tmp_work_set1 ma
              WHERE     x_string1 = '+'
                    AND EXISTS
                            (SELECT 1
                               FROM tmp_work_set1 sl
                              WHERE     ma.x_id1 = sl.x_id1
                                    AND sl.x_string1 = '++');

        UPDATE tmp_work_set1
           SET x_id3 = id_pd_payment (0)
         WHERE 1 = 1;

        --Записуємо запис подовження призначеного
        INSERT INTO pd_payment (pdp_id,
                                pdp_pd,
                                pdp_npt,
                                pdp_start_dt,
                                pdp_stop_dt,
                                pdp_sum,
                                history_status,
                                pdp_hs_ins,
                                pdp_src,
                                pdp_rc)
            SELECT x_id3,
                   x_id1,
                   pdp_npt,
                   x_dt1,
                   x_dt2,
                   x_sum1,
                   'A',
                   l_hs,
                   'EMS',
                   p_rc_id
              FROM tmp_work_set1, pd_payment
             WHERE pdp_id = x_id2;

        --Записуємо деталі запису подовження призначеного
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
                   x_id3,
                   pdd_row_order,
                   pdd_row_name,
                   CASE
                       WHEN     x_string2 = 'EXCL_18'
                            --AND pdd_ndp = CASE WHEN pd_ap < 0 THEN 290 ELSE 300 END --якщо це "по особі" і особа вже досягла 18річчя, то по ній - нуль
                            AND pdd_ndp IN (290, 300)
                            AND EXISTS
                                    (SELECT 1
                                       FROM pd_family mf
                                      WHERE     pdf_pd = pdp_pd
                                            AND mf.history_status = 'A'
                                            AND LAST_DAY (
                                                    ADD_MONTHS (pdf_birth_dt,
                                                                216)) <
                                                x_dt1
                                            AND pdd_key = pdf_id)
                       THEN
                           0
                       ELSE
                           pdd_value
                   END,
                   pdd_key,
                   pdd_ndp,
                   x_dt1,
                   x_dt2,
                   pdd_npt
              FROM tmp_work_set1,
                   pd_detail,
                   pd_payment,
                   pc_decision
             WHERE pdd_pdp = x_id2 AND pdd_pdp = pdp_id AND pdp_pd = pd_id;

        -- подовжуємо записи по членах родини
        UPDATE pd_family pdf
           SET pdf.pdf_stop_dt =
                   (SELECT x_dt2
                      FROM tmp_work_set2
                     WHERE x_id1 = pdf_pd)
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_set2
                         WHERE x_id1 = pdf_pd)
               AND (pdf.history_status = 'A' OR pdf.history_status IS NULL)
               AND (   pdf.pdf_stop_dt = (SELECT pd_stop_dt
                                            FROM pc_decision pd
                                           WHERE pdf_pd = pd_id)
                    OR pdf.pdf_stop_dt IS NULL);

        --Подовжуємо номінальний строк дії
        UPDATE pc_decision
           SET pd_stop_dt =
                   (SELECT x_dt2
                      FROM tmp_work_set2
                     WHERE x_id1 = pd_id)
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_work_set2
                     WHERE x_id1 = pd_id);

        --Подовжуємо реальний строк дії
        INSERT INTO pd_accrual_period (pdap_id,
                                       pdap_pd,
                                       pdap_start_dt,
                                       pdap_stop_dt,
                                       history_status,
                                       pdap_hs_ins)
            SELECT 0, x_id1, x_dt1 + 1, x_dt2, 'A', l_hs FROM tmp_work_set2;

        --Подовжуємо строк дії параметрів виплати
        UPDATE pd_pay_method
           SET pdm_stop_dt =
                   (SELECT x_dt2
                      FROM tmp_work_set2
                     WHERE x_id1 = pdm_pd)
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_set2
                         WHERE x_id1 = pdm_pd)
               AND pdm_is_actual = 'T'
               AND history_status = 'A';

        -- Перелік записів по відрахуванням з Dn_Detail, для яких потрібно зробити подовження
        INSERT INTO tmp_work_set3 (x_id1,
                                   x_id2,
                                   x_dt1,
                                   x_dt2)
            SELECT DISTINCT dnd.dnd_id,
                            d.dn_id,
                            x_dt1,
                            x_dt2
              FROM tmp_work_set1
                   JOIN pc_decision ON pd_id = x_id1
                   JOIN Deduction d ON d.dn_pa = pd_pa
                   JOIN Dn_Detail dnd ON dnd.dnd_dn = d.dn_id
             WHERE     d.DN_NDN IN (41,
                                    67,
                                    68,
                                    81)
                   AND d.dn_st = 'R'
                   AND dnd.dnd_stop_dt = x_dt1 - 1;

        -- Подовжуэмо выдрахування
        INSERT INTO Dn_Detail (Dnd_Id,
                               Dnd_Dn,
                               Dnd_Start_Dt,
                               Dnd_Stop_Dt,
                               Dnd_Tp,
                               Dnd_Value,
                               History_Status,
                               Dnd_Psc,
                               Dnd_Hs_Ins)
            SELECT 0         AS x_Dnd_Id,
                   dnd.Dnd_Dn,
                   x_dt1     AS x_Start_Dt,
                   x_dt2     AS x_Stop_Dt,
                   dnd.Dnd_Tp,
                   dnd.Dnd_Value,
                   dnd.History_Status,
                   dnd.Dnd_Psc,
                   l_hs      AS x_Hs_Ins
              FROM Dn_Detail dnd JOIN tmp_work_set3 ON x_id1 = dnd.dnd_id;

        --Пишемо протокол в подовжені рішення
        FOR xx IN (SELECT pd_id, pd_st, pd_stop_dt
                     FROM tmp_work_set2 z1, pc_decision
                    WHERE x_id1 = pd_id)
        LOOP
            API$PC_DECISION.write_pd_log (
                xx.pd_id,
                l_hs,
                xx.pd_st,
                CHR (38) || '261#' || TO_CHAR (xx.pd_stop_dt, 'DD.MM.YYYY'),
                xx.pd_st);
        END LOOP;
    END;

    PROCEDURE Recalc_S_LGW_CHNG (p_rc_id   rc_candidates.rcc_rc%TYPE,
                                 p_hs      histsession.hs_id%TYPE)
    IS
        l_hs            histsession.hs_id%TYPE;
        l_recalculate   recalculates%ROWTYPE;
    BEGIN
        --ikis_sysweb.ikis_debug_pipe.WriteMsg('enter Recalc_S_VPO_18');
        --l_hs := NVL(p_hs, TOOLS.GetHistSession);
        l_hs := p_hs;

        IF l_hs IS NULL
        THEN
            l_hs := TOOLS.GetHistSession;
        END IF;

        SELECT *
          INTO l_recalculate
          FROM recalculates
         WHERE rc_id = p_rc_id;

        TOOLS.org_list_to_work_ids (3, l_recalculate.rc_org_list);
        TOOLS.list_to_work_ids (4, l_recalculate.rc_nst_list);

        DELETE FROM tmp_in_calc_pd
              WHERE 1 = 1;

        INSERT INTO tmp_in_calc_pd (ic_pd, ic_tp, ic_start_dt)
            SELECT DISTINCT c.rcc_pd, 'RC.START_DT', l_recalculate.rc_month
              FROM rc_candidates      c,
                   pc_decision        pd,
                   personalcase       pc,
                   pd_accrual_period  pdap
             WHERE     c.rcc_rc = p_rc_id
                   AND rcc_pd = pd_id
                   AND pd_st = 'S'
                   AND pd.com_org IN (SELECT orgs.x_id
                                        FROM tmp_work_ids3 orgs)
                   AND pd.pd_nst = (SELECT nst.x_id
                                      FROM tmp_work_ids4 nst)
                   AND pd_pc = pc_id
                   AND pd_nst IN (249,
                                  267,
                                  265,
                                  248,
                                  268,
                                  275,
                                  901)
                   AND pdap_pd = pd_id
                   AND pdap.history_status = 'A'
                   --AND pdap_stop_dt >= l_recalculate.rc_month;
                   AND l_recalculate.rc_month BETWEEN pdap_start_dt
                                                  AND pdap_stop_dt
                   AND (   (    pd_nst IN (267,
                                           265,
                                           248,
                                           268,
                                           275,
                                           901)
                            AND NOT EXISTS
                                    (SELECT 1
                                       FROM pd_payment pdp, recalculates
                                      WHERE     pdp_pd = pd_id
                                            AND pdp.history_Status = 'A'
                                            AND pdp_stop_dt >=
                                                l_recalculate.rc_month
                                            AND pdp_rc = rc_id
                                            AND rc_tp = 'S_LGW_CHNG'))
                        OR (    pd_nst IN (249)
                            AND NOT EXISTS
                                    (SELECT 1
                                       FROM pd_payment pdp, recalculates
                                      WHERE     pdp_pd = pd_id
                                            AND pdp.history_Status = 'A'
                                            AND pdp_stop_dt >=
                                                l_recalculate.rc_month
                                            AND pdp_rc = rc_id
                                            AND pdp_sum > 0
                                            AND rc_tp = 'S_LGW_CHNG')))
            UNION ALL
            SELECT DISTINCT c.rcc_pd, 'RC.FULL', pd.pd_start_dt --l_recalculate.rc_month
              FROM rc_candidates c, pc_decision pd, personalcase pc
             WHERE     c.rcc_rc = p_rc_id
                   AND rcc_pd = pd_id
                   AND pd_st = 'S'
                   AND pd.com_org IN (SELECT orgs.x_id
                                        FROM tmp_work_ids3 orgs)
                   AND pd.pd_nst = (SELECT nst.x_id
                                      FROM tmp_work_ids4 nst)
                   AND pd_pc = pc_id
                   AND pd_nst = 251
                   AND NOT EXISTS
                           (SELECT 1
                              FROM pd_payment pdp, recalculates r
                             WHERE     pdp_pd = pd_id
                                   AND pdp.history_Status = 'A'
                                   AND r.rc_month >= l_recalculate.rc_month
                                   AND pdp_rc = rc_id
                                   AND rc_tp = 'S_LGW_CHNG');

        --  raise_application_error(-20009, 'Відібрано '||SQL%ROWCOUNT||' рішень!');

        api$calc_pd.calc_pd (p_rc_ic => l_recalculate.rc_id);

        --Пишемо протокол про перераховані рішення
        FOR xx
            IN (SELECT pd_id,
                       pd_pc,
                       pd_st,
                       pd_nst,
                       TRUNC (pd_start_dt, 'MM')     AS x_queue_start
                  FROM tmp_in_calc_pd z1, pc_decision
                 WHERE     ic_pd = pd_id
                       AND EXISTS
                               (SELECT 1
                                  FROM pd_payment
                                 WHERE     pdp_pd = pd_id
                                       AND history_status = 'A'
                                       AND pdp_start_dt >=
                                           l_recalculate.rc_month
                                       AND pdp_rc = p_rc_id))
        LOOP
            API$PC_DECISION.write_pd_log (
                xx.pd_id,
                l_hs,
                xx.pd_st,
                   CHR (38)
                || '268#'
                || TO_CHAR (l_recalculate.rc_month, 'DD.MM.YYYY'),
                xx.pd_st);
        END LOOP;

        --Пишемо в чергу перерахунку
        FOR xx
            IN (SELECT pd_id,
                       pd_pc,
                       pd_st,
                       pd_nst,
                       TRUNC (pd_start_dt, 'MM')     AS x_queue_start
                  FROM tmp_in_calc_pd z1, pc_decision
                 WHERE     ic_pd = pd_id
                       AND pd_nst = 251
                       AND EXISTS
                               (SELECT 1
                                  FROM pd_payment
                                 WHERE     pdp_pd = pd_id
                                       AND history_status = 'A'
                                       AND pdp_rc = p_rc_id))
        LOOP
            API$PERSONALCASE.add_pc_accrual_queue (xx.pd_pc,
                                                   'PD',
                                                   xx.x_queue_start,
                                                   NULL,
                                                   xx.pd_id);
        END LOOP;
    --raise_application_error(-20009, 'В реалізації!');
    END;

    PROCEDURE Prepare_S_VPO_51 (p_rc_id recalculates.rc_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_s_vpo_51_list (r_pd,
                                       r_pdf,
                                       r_sc,
                                       r_pc,
                                       r_start_dt,
                                       r_stop_dt,
                                       r_chk_dt,
                                       r_chk_month,
                                       r_birth_dt,
                                       r_z_member)
            SELECT pdf_pd,
                   pdf_id,
                   pdf_sc,
                   pd_pc,
                   ADD_MONTHS (rc_month, -3),
                   ADD_MONTHS (rc_month, -2) - 1,
                   rc_month - 1,
                   ADD_MONTHS (rc_month, -1),
                   NVL (
                       (SELECT scb_dt
                          FROM uss_person.v_socialcard,
                               uss_person.v_sc_change,
                               uss_person.v_sc_birth
                         WHERE     sc_id = pdf_sc
                               AND scc_sc = sc_id
                               AND sc_scc = scc_id
                               AND scc_scb = scb_id
                               AND scc_scb > 0),
                       pdf_birth_dt),
                   CASE
                       WHEN EXISTS
                                (SELECT 1
                                   FROM ap_person ap
                                  WHERE     app_ap = pd_ap
                                        AND ap.history_status = 'A'
                                        AND app_sc = pdf_sc
                                        AND app_tp = 'Z')
                       THEN
                           'T'
                       ELSE
                           'F'
                   END
              FROM pd_family      mf,
                   pc_decision    md,
                   pc_account,
                   tmp_work_ids3  orgs,
                   appeal,
                   recalculates   marc
             WHERE     pdf_pd = pd_id
                   AND mf.history_status = 'A'
                   AND pd_pa = pa_id
                   AND pa_org = orgs.x_id
                   AND pd_ap = ap_id
                   AND rc_id = p_rc_id
                   AND ap_reg_dt BETWEEN ADD_MONTHS (rc_month, -3)
                                     AND ADD_MONTHS (rc_month, -2) - 1 --призначені в період (-3 місяці, -2 місяці) від періоду розрахунку
                   AND pd_st = 'S'
                   AND pd_nst = 664
                   AND pd_stop_dt >= rc_month    --Діють і в місяці розрахунку
                   /* AND NOT EXISTS (SELECT 1
                                    FROM pc_decision ed, pd_family ef
                                    WHERE ef.pdf_pd = ed.pd_id
                                      AND ed.pd_nst = 664
                                      AND ef.pdf_sc = mf.pdf_sc
                                      AND ed.pd_start_dt < md.pd_start_dt)*/
                   AND (   NOT EXISTS
                               (SELECT 1 --Не мають інших рішеннь по будь-які осоіб до рішення, що аналізається
                                  FROM uss_esr.pc_decision  prev_pd,
                                       uss_esr.pd_family    prev_f,
                                       uss_esr.pd_family    curr
                                 WHERE     curr.pdf_pd = md.pd_id
                                       AND prev_f.pdf_sc = curr.pdf_sc
                                       AND prev_f.pdf_pd = prev_pd.pd_id
                                       AND prev_pd.pd_nst = 664
                                       AND prev_pd.pd_start_dt <
                                           md.pd_start_dt
                                       AND prev_f.history_status = 'A'
                                       AND curr.history_status = 'A')
                        OR EXISTS
                               (SELECT 1
                                  FROM uss_esr.recalculates  slrc,
                                       uss_esr.pd_payment    slp
                                 WHERE     slrc.rc_month = marc.rc_month
                                       AND slrc.rc_tp = marc.rc_tp
                                       AND slp.pdp_pd = pd_id
                                       AND slp.pdp_rc = slrc.rc_id
                                       AND slrc.rc_id <> marc.rc_id))
                   AND NOT EXISTS
                           (SELECT 1
                              FROM pd_payment pdi, recalculates slrc
                             WHERE     pdi.pdp_pd = pd_id
                                   AND pdi.history_status = 'A'
                                   AND marc.rc_month - 1 BETWEEN pdi.pdp_start_dt
                                                             AND pdi.pdp_stop_dt
                                   AND pdi.pdp_rc = slrc.rc_id
                                   AND slrc.rc_tp IN ('S_VPO_INC'));

        --особа набула статусу безробітного в період з 1 грудня 2023 по 29 лютого 2024 - встановлюємо ознаку особі – має право, як особа, що набула статусу безробітного
        UPDATE tmp_s_vpo_51_list
           SET r_is_dcz_become_unemp = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_51_list
           SET r_is_dcz_become_unemp = 'T'
         WHERE EXISTS
                   (SELECT 1
                      FROM me_dcz_result_rows
                     WHERE     mdsr_sc = r_sc
                           AND mdsr_d_sb BETWEEN r_start_dt AND r_chk_dt);

        --особа є Пенсіонер станом на 29.02.2024 - встановлюємо ознаку особі – має право, як непрацездатна особа;
        UPDATE tmp_s_vpo_51_list
           SET r_is_penisioner = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_51_list
           SET r_is_penisioner = 'T'
         WHERE    EXISTS
                      (SELECT 1
                         FROM uss_person.v_sc_pension
                        WHERE     scp_sc = r_sc
                              AND scp_is_pension = 'T'
                              AND r_chk_dt BETWEEN scp_begin_dt
                                               AND NVL (scp_end_dt, r_chk_dt))
               OR EXISTS
                      (SELECT 1
                         FROM src_pension_info
                        WHERE     spi_sc = r_sc
                              AND spi_month BETWEEN r_chk_month AND r_chk_dt
                              AND (   (    spi_ls_subject_tp IN
                                               ('PENS', 'DD', 'DPN')
                                       AND spi_sum_zag > 0)
                                   OR (    spi_ls_subject_tp_mil IN
                                               ('PENS', 'DD', 'DPN')
                                       AND spi_sum_zag_mil > 0)));


        --особа перебуває в трудових відносинах в період з 1 грудня 2023 по 29 лютого 2024 - встановлюємо ознаку, що особа має право, як працююча особа.
        UPDATE tmp_s_vpo_51_list
           SET r_is_working = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_51_list
           SET r_is_working = 'T'
         WHERE EXISTS
                   (SELECT 1
                      FROM src_pension_info
                     WHERE     spi_sc = r_sc
                           AND spi_month BETWEEN r_chk_month AND r_chk_dt
                           AND spi_oznak_prac IN ('T', '1')); --spi_rab IN ('T', '1')

        --одна доросла особа (віком старше 18 років) і наявна дитина, яка станом на 29.02.2024 має менше ніж 6 років - ознаку «має право, як особа, що здійснює догляд за дитиною до 6-ти років».
        UPDATE tmp_s_vpo_51_list ma
           SET r_is_1_adult_and_child_6years = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_51_list ma
           SET r_is_1_adult_and_child_6years = 'T'
         WHERE     1 =
                   (SELECT COUNT (*)
                      FROM tmp_s_vpo_51_list sl
                     WHERE     sl.r_pd = ma.r_pd
                           AND sl.r_birth_dt < ADD_MONTHS (r_chk_dt, -216))
               AND 0 <
                   (SELECT COUNT (*)
                      FROM tmp_s_vpo_51_list sl
                     WHERE     sl.r_pd = ma.r_pd
                           AND sl.r_birth_dt > ADD_MONTHS (r_chk_dt, -72))
               AND r_birth_dt < ADD_MONTHS (r_chk_dt, -216);

        --в рішенні дві дорослі особи, які не мають ознак «має право, як працююча особа» або «має право, як особа, що набула статусу безробітного», або «має право, як непрацездатна особа»
        --і серед отримувачів допомоги наявна дитина, яка станом на 29.02.2024 має менше ніж 6 років, то особі «Заявнику» встановлюємо ознаку «має право, як особа, що здійснює догляд за дитиною до 6-ти років»
        UPDATE tmp_s_vpo_51_list
           SET r_is_Z_2_adult_and_child_6years = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_51_list ma
           SET r_is_Z_2_adult_and_child_6years = 'T'
         WHERE     2 =
                   (SELECT COUNT (*)
                      FROM tmp_s_vpo_51_list sl
                     WHERE     sl.r_pd = ma.r_pd
                           AND sl.r_birth_dt < ADD_MONTHS (r_chk_dt, -216)
                           AND r_is_dcz_become_unemp = 'F'
                           AND r_is_penisioner = 'F'
                           AND r_is_working = 'F')
               AND 0 <
                   (SELECT COUNT (*)
                      FROM tmp_s_vpo_51_list sl
                     WHERE     sl.r_pd = ma.r_pd
                           AND sl.r_birth_dt > ADD_MONTHS (r_chk_dt, -72))
               AND r_z_member = 'T'
               AND r_birth_dt < ADD_MONTHS (r_chk_dt, -216);

        --в рішенні є дві дорослі особи, одна з них має хоча б одну із ознак «має право, як працююча особа» або «має право, як особа, що набула статусу безробітного», або «має право, як непрацездатна особа»,
        --друга доросла людина не має жодної ознаки «має право, як працююча особа» або «має право, як особа, що набула статусу безробітного», або «має право, як непрацездатна особа»
        --і серед отримувачів допомоги наявна дитина, яка станом на 29.02.2024 має менше ніж 6 років, то особі, яка не має жодної ознаки встановлюємо ознаку «має право, як особа, що здійснює догляд за дитиною до 6-ти років»
        UPDATE tmp_s_vpo_51_list
           SET r_is_1_adult_wo_1_adult_with_and_child_6years = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_51_list ma
           SET r_is_1_adult_wo_1_adult_with_and_child_6years = 'T'
         WHERE     2 =
                   (SELECT COUNT (*)
                      FROM tmp_s_vpo_51_list sl
                     WHERE     sl.r_pd = ma.r_pd
                           AND sl.r_birth_dt < ADD_MONTHS (r_chk_dt, -216))
               AND 1 =
                   (SELECT COUNT (*)
                      FROM tmp_s_vpo_51_list sl
                     WHERE     sl.r_pd = ma.r_pd
                           AND sl.r_birth_dt < ADD_MONTHS (r_chk_dt, -216)
                           AND (   r_is_dcz_become_unemp = 'T'
                                OR r_is_penisioner = 'T'
                                OR r_is_working = 'T'))
               AND r_is_dcz_become_unemp = 'F'
               AND r_is_penisioner = 'F'
               AND r_is_working = 'F'
               AND 0 <
                   (SELECT COUNT (*)
                      FROM tmp_s_vpo_51_list sl
                     WHERE     sl.r_pd = ma.r_pd
                           AND sl.r_birth_dt > ADD_MONTHS (r_chk_dt, -72))
               AND r_birth_dt < ADD_MONTHS (r_chk_dt, -216);

        --одна доросла особа віком старше 18 років і наявно більше ніж 3 дітей, яким станом на 29.02.2024 має менше ніж 18 років, то такій особі подовжуємо, встановлюємо ознаку «має право, як особа, що здійснює догляд за 3-ма і більше дітьми»
        UPDATE tmp_s_vpo_51_list
           SET r_is_1_adult_and_3_child_18years = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_51_list ma
           SET r_is_1_adult_and_3_child_18years = 'T'
         WHERE     1 =
                   (SELECT COUNT (*)
                      FROM tmp_s_vpo_51_list sl
                     WHERE     sl.r_pd = ma.r_pd
                           AND sl.r_birth_dt < ADD_MONTHS (r_chk_dt, -216))
               AND 3 <=
                   (SELECT COUNT (*)
                      FROM tmp_s_vpo_51_list sl
                     WHERE     sl.r_pd = ma.r_pd
                           AND sl.r_birth_dt > ADD_MONTHS (r_chk_dt, -216))
               AND r_birth_dt < ADD_MONTHS (r_chk_dt, -216);

        --в рішенні дві дорослі особи, які не мають ознак «має право, як працююча особа» або «має право, як особа, що набула статусу безробітного», або «має право, як непрацездатна особа»
        --і серед отримувачів допомоги наявно більше ніж 3 дітей, яким станом на 29.02.2024 має менше ніж 18 років, і один з тих дорослих є заявником,
        --то такій особі «Заявнику» встановлюємо ознаку «має право, як особа, що здійснює догляд за 3-ма і більше дітьми»
        UPDATE tmp_s_vpo_51_list
           SET r_is_Z_2_adult_and_3_child_18years = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_51_list ma
           SET r_is_Z_2_adult_and_3_child_18years = 'T'
         WHERE     2 =
                   (SELECT COUNT (*)
                      FROM tmp_s_vpo_51_list sl
                     WHERE     sl.r_pd = ma.r_pd
                           AND sl.r_birth_dt < ADD_MONTHS (r_chk_dt, -216)
                           AND r_is_dcz_become_unemp = 'F'
                           AND r_is_penisioner = 'F'
                           AND r_is_working = 'F')
               AND 3 <=
                   (SELECT COUNT (*)
                      FROM tmp_s_vpo_51_list sl
                     WHERE     sl.r_pd = ma.r_pd
                           AND sl.r_birth_dt > ADD_MONTHS (r_chk_dt, -216))
               AND r_is_dcz_become_unemp = 'F'
               AND r_is_penisioner = 'F'
               AND r_is_working = 'F'
               AND r_z_member = 'T'
               AND r_birth_dt < ADD_MONTHS (r_chk_dt, -216);

        --в рішенні є дві дорослі особи, одна з них має хоча б одну із ознак «має право, як працююча особа» або «має право, як особа, що набула статусу безробітного», або «має право, як непрацездатна особа»,
        --друга доросла людина не має жодної ознаки «має право, як працююча особа» або «має право, як особа, що набула статусу безробітного», або «має право, як непрацездатна особа»
        --і серед отримувачів допомоги наявно більше ніж 3 дітей, яким станом на 29.02.2024 має менше ніж 18 років,
        --то особі, яка не має жодної ознаки встановлюємо ознаку «має право, як особа, що здійснює догляд за 3-ма і більше дітьми»
        UPDATE tmp_s_vpo_51_list
           SET r_is_1_adult_wo_1_adult_with_and_3_child_18years = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_51_list ma
           SET r_is_1_adult_wo_1_adult_with_and_3_child_18years = 'T'
         WHERE     2 =
                   (SELECT COUNT (*)
                      FROM tmp_s_vpo_51_list sl
                     WHERE     sl.r_pd = ma.r_pd
                           AND sl.r_birth_dt < ADD_MONTHS (r_chk_dt, -216))
               AND 1 =
                   (SELECT COUNT (*)
                      FROM tmp_s_vpo_51_list sl
                     WHERE     sl.r_pd = ma.r_pd
                           AND sl.r_birth_dt < ADD_MONTHS (r_chk_dt, -216)
                           AND (   r_is_dcz_become_unemp = 'T'
                                OR r_is_penisioner = 'T'
                                OR r_is_working = 'T'))
               AND 1 =
                   (SELECT COUNT (*)
                      FROM tmp_s_vpo_51_list sl
                     WHERE     sl.r_pd = ma.r_pd
                           AND sl.r_birth_dt < ADD_MONTHS (r_chk_dt, -216)
                           AND r_is_dcz_become_unemp = 'F'
                           AND r_is_penisioner = 'F'
                           AND r_is_working = 'F')
               AND 3 <=
                   (SELECT COUNT (*)
                      FROM tmp_s_vpo_51_list sl
                     WHERE     sl.r_pd = ma.r_pd
                           AND sl.r_birth_dt > ADD_MONTHS (r_chk_dt, -216))
               AND r_is_dcz_become_unemp = 'F'
               AND r_is_penisioner = 'F'
               AND r_is_working = 'F'
               AND r_birth_dt < ADD_MONTHS (r_chk_dt, -216);

        --особи, яка доглядає за хворою дитиною - В ЄІССС здійснюємо пошук осіб, які отримують допомогу по послузі з Ід= 265 і встановлюємо ознаку «має право, як особа, що здійснює догляд за хворою дитиною»
        UPDATE tmp_s_vpo_51_list
           SET r_is_have_265 = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_51_list
           SET r_is_have_265 = 'T'
         WHERE EXISTS
                   (SELECT 1
                      FROM pc_decision, personalcase, pd_accrual_period
                     WHERE     pd_pc = pc_id
                           AND pd_nst = 265
                           AND pc_sc = r_sc
                           AND pd_st IN ('S', 'PS')
                           AND pdap_pd = pd_id
                           AND history_status = 'A'
                           AND r_chk_dt BETWEEN pdap_start_dt
                                            AND pdap_stop_dt);

        --особи з інвалідністюI чи II групи - щодо особи наявний документ з Ід=201 («Виписка МСЕК») і в атрибуті з Ід= 349 («група інвалідності») встановлено 1 група або 2 група
        --і в атрибуті 347 («встановлено на період по») зазначено дату після першого дня місяця (включно), що дорівнює «розрахунковий період» мінус 3 місяці,
        --то встановлюємо ознаку «має право, як особа, з інвалідністю 1 або 2 групи»
        UPDATE tmp_s_vpo_51_list
           SET r_is_have_inv_1_or_2 = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_51_list
           SET r_is_have_inv_1_or_2 = 'T'
         WHERE    EXISTS
                      (SELECT 1
                         FROM pc_decision,
                              ap_person         app,
                              ap_document       ap,
                              ap_document_attr  apda
                        WHERE     pd_id = r_pd
                              AND app_sc = r_sc
                              AND app.history_status = 'A'
                              AND ap.history_status = 'A'
                              AND apda.history_status = 'A'
                              AND app_ap = pd_ap
                              AND apd_app = app_id
                              AND apda_apd = apd_id
                              AND apd_ndt = 201
                              AND apda_nda = 349
                              AND apda_val_string IN ('1', '2'))
               OR EXISTS
                      (SELECT 1
                         FROM pc_decision,
                              ap_person         app,
                              ap_document       ap,
                              ap_document_attr  apda
                        WHERE     pd_id = r_pd
                              AND app_sc = r_sc
                              AND app.history_status = 'A'
                              AND ap.history_status = 'A'
                              AND apda.history_status = 'A'
                              AND app_ap = pd_ap
                              AND apd_app = app_id
                              AND apda_apd = apd_id
                              AND apd_ndt = 201
                              AND apda_nda = 347
                              AND apda_val_dt > r_start_dt);

        --особи, яка доглядає за особою з інвалідністю - за даними ЄІССС особа отримує допомогу по послузі з Ід=248 і до звернення прикріплено документ з Ід=200 до іншої особи,
        --то такій особі встановлювати ознаку «Має право, як особа, яка доглядає за дитиною з інвалідністю»
        UPDATE tmp_s_vpo_51_list
           SET r_is_have_248_and_doc_200 = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_51_list
           SET r_is_have_248_and_doc_200 = 'T'
         WHERE EXISTS
                   (SELECT 1
                      FROM pc_decision, personalcase, pd_accrual_period
                     WHERE     pd_pc = pc_id
                           AND pd_nst = 248
                           AND pc_sc = r_sc
                           AND pd_st IN ('S', 'PS')
                           AND pdap_pd = pd_id
                           AND history_status = 'A'
                           AND r_chk_dt BETWEEN pdap_start_dt
                                            AND pdap_stop_dt
                           AND EXISTS
                                   (SELECT 1
                                      FROM ap_person app, ap_document ap
                                     WHERE     app_ap = pd_ap
                                           AND app_sc <> r_sc
                                           AND app.history_status = 'A'
                                           AND ap.history_status = 'A'
                                           AND apd_app = app_id
                                           AND apd_ndt = 200));

        --особи, яка доглядає за особою з інвалідністю - за даними ЄІССС особа отримує допомогу по послузі з Ід=248 і до звернення прикріплено документ з Ід=201 до іншої особи,
        --у якому в атрибуті з Ід= 349 («група інвалідності») встановлено 1 група, то такій особі встановлювати ознаку «Має право, як особа, яка доглядає за особою з 1 групою інвалідності»
        UPDATE tmp_s_vpo_51_list
           SET r_is_have_248_and_doc_201 = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_51_list
           SET r_is_have_248_and_doc_201 = 'T'
         WHERE EXISTS
                   (SELECT 1
                      FROM pc_decision, personalcase, pd_accrual_period
                     WHERE     pd_pc = pc_id
                           AND pd_nst = 248
                           AND pc_sc = r_sc
                           AND pd_st IN ('S', 'PS')
                           AND pdap_pd = pd_id
                           AND history_status = 'A'
                           AND r_chk_dt BETWEEN pdap_start_dt
                                            AND pdap_stop_dt
                           AND EXISTS
                                   (SELECT 1
                                      FROM ap_person         app,
                                           ap_document       ap,
                                           ap_document_attr  apda
                                     WHERE     app_ap = pd_ap
                                           AND app_sc <> r_sc
                                           AND app.history_status = 'A'
                                           AND ap.history_status = 'A'
                                           AND apda.history_status = 'A'
                                           AND app_ap = pd_ap
                                           AND apd_app = app_id
                                           AND apda_apd = apd_id
                                           AND apd_ndt = 201
                                           AND apda_nda = 349
                                           AND apda_val_string IN ('1')));

        --особи, яка доглядає за  особою з інвалідністю I чи II групи внаслідок психічного розладу - Якщо за даними АСОПД особа здійснює догляд за особою з інвалідністю I чи II групи
        -- внаслідок психічного розладу то такій особі встановлювати ознаку «Має право, як особа, яка доглядає за  особою з інвалідністю I чи II групи внаслідок психічного розладу»
        UPDATE tmp_s_vpo_51_list
           SET r_is_have_inv_ph = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_51_list
           SET r_is_have_inv_ph = 'T'
         WHERE EXISTS
                   (SELECT 1
                      FROM src_disability_asopd
                     WHERE     sda_sc = r_sc
                           AND sda_dt =
                               (SELECT MAX (x.sda_dt)
                                  FROM src_disability_asopd x
                                 WHERE     x.sda_sc = r_sc
                                       AND x.sda_dt <= r_chk_dt)
                           AND sda_osob_2 IN ('T', 'TRUE'));

        --особи, яка доглядає за  особою з інвалідністю I групи - за даними АСОПД особа здійснює догляд за особою з інвалідністю I,
        --то такій особі встановлювати ознаку «Має право, як особа, яка доглядає за  особою з інвалідністю I групи»
        UPDATE tmp_s_vpo_51_list
           SET r_is_have_inv_1 = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_51_list
           SET r_is_have_inv_1 = 'T'
         WHERE EXISTS
                   (SELECT 1
                      FROM src_disability_asopd
                     WHERE     sda_sc = r_sc
                           AND sda_dt =
                               (SELECT MAX (x.sda_dt)
                                  FROM src_disability_asopd x
                                 WHERE     x.sda_sc = r_sc
                                       AND x.sda_dt <= r_chk_dt)
                           AND sda_osob_1 IN ('T', 'TRUE'));

        --фізичної особи, яка надає соціальні послуги з догляду  - Якщо за даними АСОПД особа надає соціальні послуги,
        --то такій особі встановлювати ознаку «Має право, як особа, яка надає соціальні послуги з нагляду»
        UPDATE tmp_s_vpo_51_list
           SET r_is_have_soc_serv = 'F'
         WHERE 1 = 1;

        --  UPDATE tmp_s_vpo_51_list
        --    SET r_is_have_soc_serv = 'T'
        --    WHERE  EXISTS (SELECT 1
        --                  FROM src_disability_asopd
        --                  WHERE sda_sc = r_sc
        --                    AND sda_dt = (SELECT MAX(x.sda_dt) FROM src_disability_asopd x WHERE x.sda_sc = r_sc AND x.sda_dt < r_chk_dt)
        --                    AND (sda_osob_1 = 'TRUE' OR sda_osob_2 = 'TRUE' OR sda_osob_3 = 'TRUE' OR sda_osob_6 = 'TRUE' OR sda_osob_11 = 'TRUE');

        --студента, який навчається за денною або дуальною формою здобуття освіти в закладах загальної середньої, професійної (професійно-технічної), фахової передвищої, вищої освіти.
        --Якщо за даними АСОПД особа надає отримує соцстипендію, то такій особі встановлювати ознаку «Має право, як особа, яка надає соціальні послуги з нагляду»
        --Всім дітям до 18-ти станом на 29.02.2024 (перше число розрахункового періоду мінус один день) продовжуємо виплату – відповідно їм встановлюємо ознаку «має право як дитина до 18 ти»
        UPDATE tmp_s_vpo_51_list
           SET r_is_student = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_51_list
           SET r_is_student = 'T'
         WHERE r_birth_dt > ADD_MONTHS (r_chk_dt, -216);


        --Всім особам, які віком більше ніж 60 років станом на 29.02.2024 (перше число розрахункового періоду мінус один день) продовжуємо виплату
        --відповідно їм встановлюємо ознаку «має право як особа, яка досягла віку 60 років і старше»
        UPDATE tmp_s_vpo_51_list
           SET r_is_60_age = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_51_list
           SET r_is_60_age = 'T'
         WHERE r_birth_dt < ADD_MONTHS (r_chk_dt, -720);
    END;

    PROCEDURE Recalc_S_VPO_51 (p_rc_id   recalculates.rc_id%TYPE,
                               p_hs      histsession.hs_id%TYPE)
    IS
        l_hs            histsession.hs_id%TYPE;
        l_recalculate   recalculates%ROWTYPE;
    BEGIN
        --  raise_application_error(-20009, 'В реалізації!');
        l_hs := p_hs;

        IF l_hs IS NULL
        THEN
            l_hs := TOOLS.GetHistSession;
        END IF;

        SELECT *
          INTO l_recalculate
          FROM recalculates
         WHERE rc_id = p_rc_id;

        --ikis_sysweb.ikis_debug_pipe.WriteMsg(l_recalculate.rc_org_list);
        TOOLS.org_list_to_work_ids (3, l_recalculate.rc_org_list);

        DELETE FROM tmp_work_set2
              WHERE 1 = 1;

        DELETE FROM tmp_work_set3
              WHERE 1 = 1;

        --Знаходимо всі рішення і осіб, які діють на дату початку місяція перерахунку
        INSERT INTO tmp_work_set2 (x_id1,
                                   x_id2,
                                   x_id3,
                                   x_id4,
                                   x_id5,
                                   x_dt1,
                                   x_dt2,
                                   x_dt3,
                                   x_dt4)
            SELECT pdf_pd,
                   pdf_id,
                   pdf_sc,
                   pd_pc,
                   pdp_id,
                   NVL (
                       (SELECT scb_dt
                          FROM uss_person.v_socialcard,
                               uss_person.v_sc_change,
                               uss_person.v_sc_birth
                         WHERE     sc_id = pdf_sc
                               AND scc_sc = sc_id
                               AND sc_scc = scc_id
                               AND scc_scb = scb_id
                               AND scc_scb > 0),
                       pdf_birth_dt),
                   rc_month,
                   pd_stop_dt,
                   SYSDATE
              FROM rc_candidates,
                   pd_family      mf,
                   pc_decision    md,
                   pc_account,
                   tmp_work_ids3  orgs,
                   appeal,
                   recalculates   marc,
                   pd_payment     pdp
             WHERE     rcc_rc = rc_id
                   AND mf.history_status = 'A'
                   AND rcc_pd = pd_id
                   AND rcc_sc = pdf_sc
                   AND pdf_pd = pd_id
                   AND pd_pa = pa_id
                   AND pa_org = orgs.x_id
                   AND pd_ap = ap_id
                   AND rc_id = p_rc_id
                   AND ap_reg_dt BETWEEN ADD_MONTHS (rc_month, -3)
                                     AND ADD_MONTHS (rc_month, -2) - 1 --призначені в період (-3 місяці, -2 місяці) від періоду розрахунку
                   AND pd_st = 'S'
                   AND pd_nst = 664
                   AND pd_stop_dt >= rc_month    --Діють і в місяці розрахунку
                   AND (   NOT EXISTS
                               (SELECT 1 --Не мають інших рішеннь по будь-які осоіб до рішення, що аналізається
                                  FROM uss_esr.pc_decision  prev_pd,
                                       uss_esr.pd_family    prev_f,
                                       uss_esr.pd_family    curr
                                 WHERE     curr.pdf_pd = md.pd_id
                                       AND prev_f.pdf_sc = curr.pdf_sc
                                       AND prev_f.pdf_pd = prev_pd.pd_id
                                       AND prev_pd.pd_nst = 664
                                       AND prev_pd.pd_start_dt <
                                           md.pd_start_dt
                                       AND prev_f.history_status = 'A'
                                       AND curr.history_status = 'A')
                        OR EXISTS
                               (SELECT 1
                                  FROM uss_esr.recalculates  slrc,
                                       uss_esr.pd_payment    slp
                                 WHERE     slrc.rc_month = marc.rc_month
                                       AND slrc.rc_tp = marc.rc_tp
                                       AND slp.pdp_pd = pd_id
                                       AND slp.pdp_rc = slrc.rc_id
                                       AND slrc.rc_id <> marc.rc_id))
                   AND pdp_pd = pd_id
                   AND pdp.history_status = 'A'
                   AND rc_month BETWEEN pdp_start_dt AND pdp_stop_dt
                   AND NOT EXISTS
                           (SELECT 1
                              FROM pd_payment pdi, recalculates slrc
                             WHERE     pdi.pdp_pd = pd_id
                                   AND pdi.history_status = 'A'
                                   AND marc.rc_month - 1 BETWEEN pdi.pdp_start_dt
                                                             AND pdi.pdp_stop_dt
                                   AND pdi.pdp_rc = slrc.rc_id
                                   AND slrc.rc_tp IN ('S_VPO_INC'));

        --  write_rc_log(p_rc_id, l_hs, 'F', NULL, l_recalculate.rc_st);

        write_message (
            1,
               'Знайдено '
            || SQL%ROWCOUNT
            || ' кандидатів, рішення по яким будуть виконані подовження або неподовження.');

        --Знаходимо осіб, по яким призначена сума допомоги - збергігається
        UPDATE tmp_work_set2
           SET x_string1 = '+'
         WHERE EXISTS
                   (SELECT 1
                      FROM rc_candidates, rc_candidate_attr
                     WHERE     rcca_rcc = rcc_id
                           AND rcc_rc = p_rc_id
                           AND rcc_pd = x_id1
                           AND rcc_sc = x_id3
                           AND rcca_val_string = 'T');

        --Видаляємо всі діючі записи, які діють на перше число місяця перерахунку і пізніше
        UPDATE pd_payment
           SET pdp_hs_del = l_hs, history_status = 'H'
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_set2
                         WHERE pdp_pd = x_id1)
               AND pdp_stop_dt > l_recalculate.rc_month
               AND history_status = 'A';

        --Вставляємо шматочок запису призначеного, який діяв на перше число місяця перерахнку, якщо він почався до першого числа місяця перерахнку.
        INSERT INTO pd_payment (pdp_id,
                                pdp_pd,
                                pdp_npt,
                                pdp_start_dt,
                                pdp_stop_dt,
                                pdp_sum,
                                history_status,
                                pdp_hs_ins,
                                pdp_src,
                                pdp_rc)
            SELECT 0,
                   pdp_pd,
                   pdp_npt,
                   pdp_start_dt,
                   l_recalculate.rc_month - 1,
                   pdp_sum,
                   'A',
                   l_hs,
                   'EMS',
                   pdp_rc
              FROM pd_payment
             WHERE     pdp_hs_del = l_hs
                   AND pdp_start_dt < l_recalculate.rc_month;

        --Формуємо нові записи призначеного на місяць перерахунку --LAST_DAY(l_recalculate.rc_month)
        INSERT INTO pd_payment (pdp_id,
                                pdp_pd,
                                pdp_npt,
                                pdp_start_dt,
                                pdp_stop_dt,
                                history_status,
                                pdp_hs_ins,
                                pdp_src,
                                pdp_rc)
            SELECT 0,
                   pdp_pd,
                   pdp_npt,
                   l_recalculate.rc_month,
                   (SELECT MAX (x_dt3)
                      FROM tmp_work_set2
                     WHERE x_id1 = pdp_pd),
                   'A',
                   l_hs,
                   'EMS',
                   p_rc_id
              FROM pd_payment
             WHERE     pdp_hs_del = l_hs
                   AND l_recalculate.rc_month BETWEEN pdp_start_dt
                                                  AND pdp_stop_dt;

          --відтворюємо записи деталей призначеного на запис призначеного на місяць перерахунку
          INSERT ALL
            WHEN x_old_pdp <> x_new_pdp
            THEN --Робимо копію всіх записів в запис призначеного, який діє на попередій період
                INTO pd_detail (pdd_id,
                                pdd_pdp,
                                pdd_row_order,
                                pdd_row_name,
                                pdd_key,
                                pdd_ndp,
                                pdd_start_dt,
                                pdd_stop_dt,
                                pdd_npt,
                                pdd_value)
                  VALUES (0,
                          x_old_pdp,
                          pdd_row_order,
                          pdd_row_name,
                          pdd_key,
                          pdd_ndp,
                          x_start_dt,
                          x_stop_dt,
                          pdd_npt,
                          pdd_value)
            WHEN pdd_ndp <> 137
            THEN                                   --Робимо копію всіх записів
                INTO pd_detail (pdd_id,
                                pdd_pdp,
                                pdd_row_order,
                                pdd_row_name,
                                pdd_key,
                                pdd_ndp,
                                pdd_start_dt,
                                pdd_stop_dt,
                                pdd_npt,
                                pdd_value)
                  VALUES (0,
                          x_new_pdp,
                          pdd_row_order,
                          pdd_row_name,
                          pdd_key,
                          pdd_ndp,
                          x_start_dt,
                          x_stop_dt,
                          pdd_npt,
                          x_sum)
            WHEN    (x_sum = 0 AND pdd_value > 0 AND pdd_ndp IN (290, 300))
                 OR pdd_ndp = 137
            THEN
                INTO pd_detail (pdd_id,
                                pdd_pdp,
                                pdd_row_order,
                                pdd_row_name,
                                pdd_key,
                                pdd_ndp,
                                pdd_start_dt,
                                pdd_stop_dt,
                                pdd_npt,
                                pdd_value)
                  VALUES (0,
                          x_new_pdp,
                          pdd_row_order,
                          pdd_row_name,
                          pdd_key,
                          137,
                          x_start_dt,
                          x_stop_dt,
                          pdd_npt,
                          pdd_value)
            SELECT pdd_pdp,
                   pdd_row_order,
                   pdd_row_name,
                   pdd_value,
                   pdd_key,
                   pdd_ndp,
                   l_recalculate.rc_month
                       AS x_start_dt,     /*LAST_DAY(l_recalculate.rc_month)*/
                   (SELECT MAX (x_dt3)
                      FROM tmp_work_set2
                     WHERE x_id1 = pdp_pd)
                       AS x_stop_dt,
                   pdd_npt,
                   CASE
                       WHEN     pdd_ndp IN (290, 300)
                            AND EXISTS
                                    (SELECT 1
                                       FROM tmp_work_set2
                                      WHERE     x_id1 = pdp_pd
                                            AND x_id2 = pdd_key
                                            AND x_string1 = '+')
                       THEN
                           CASE
                               WHEN pdd_value > 0
                               THEN
                                   pdd_value
                               WHEN EXISTS
                                        (SELECT 1
                                           FROM pd_detail sl
                                          WHERE     sl.pdd_ndp = 137
                                                AND sl.pdd_key = ma.pdd_key
                                                AND sl.pdd_value > 0)
                               THEN
                                   (SELECT MIN (sl.pdd_value)
                                      FROM pd_detail sl
                                     WHERE     sl.pdd_ndp = 137
                                           AND sl.pdd_key = ma.pdd_key
                                           AND sl.pdd_value > 0)
                               ELSE
                                   0
                           END
                       ELSE
                           0
                   END
                       AS x_sum, --сума для 290/300 змінюється в залежності від наявності права
                   (SELECT MAX (pdp_id)
                      FROM pd_payment np
                     WHERE np.pdp_pd = dp.pdp_pd AND np.pdp_hs_ins = l_hs)
                       AS x_new_pdp,
                   (SELECT MIN (pdp_id)
                      FROM pd_payment np
                     WHERE np.pdp_pd = dp.pdp_pd AND np.pdp_hs_ins = l_hs)
                       AS x_old_pdp
              FROM pd_payment dp, pd_detail ma
             WHERE     pdp_hs_del = l_hs
                   AND l_recalculate.rc_month BETWEEN pdp_start_dt
                                                  AND pdp_stop_dt
                   AND pdd_pdp = pdp_id;

        UPDATE pd_payment
           SET pdp_sum =
                   NVL ( (SELECT SUM (pdd_value)
                            FROM pd_detail
                           WHERE pdd_pdp = pdp_id AND pdd_ndp IN (290, 300)),
                        0)
         WHERE pdp_hs_ins = l_hs AND pdp_start_dt = l_recalculate.rc_month;

        --Переводимо реєстраційні записи нарахуваннь в "редагується" та "діюче по послугам" - аби можна було виконувати нарахування
        UPDATE accrual ac
           SET ac_st = CASE ac_st WHEN 'R' THEN 'RV' WHEN 'RP' THEN 'E' END
         WHERE     ac_st IN ('R', 'RP')
               AND EXISTS
                       (SELECT 1
                          FROM tmp_work_set2
                         WHERE ac_pc = x_id4)
               AND EXISTS
                       (SELECT 1
                          FROM billing_period,
                               pc_decision,
                               pc_account,
                               tmp_work_set2
                         WHERE     x_id4 = ac_pc
                               AND x_id1 = pd_id
                               AND pd_pa = pa_id
                               AND bp_month = ac_month
                               AND bp_org = pa_org
                               AND bp_tp = 'PR'
                               AND bp_class = 'VPO'
                               AND bp_st = 'R')
               AND (SELECT SUM (pdp_sum)
                      FROM pd_payment pdp, tmp_work_set2
                     WHERE     pdp.history_status = 'A'
                           AND x_id1 = pdp_pd
                           AND x_id4 = ac_pc
                           AND pdp_stop_dt = l_recalculate.rc_month - 1) <>
                   (SELECT SUM (pdp_sum)
                      FROM pd_payment pdp, tmp_work_set2
                     WHERE     pdp.history_status = 'A'
                           AND x_id1 = pdp_pd
                           AND x_id4 = ac_pc
                           AND pdp_start_dt = l_recalculate.rc_month);

        DELETE FROM pd_features
              WHERE     pde_nft BETWEEN 100 AND 116
                    AND EXISTS
                            (SELECT 1
                               FROM tmp_work_set2
                              WHERE x_id1 = pde_pd);

        INSERT INTO pd_features (pde_id,
                                 pde_pd,
                                 pde_val_string,
                                 pde_pdf,
                                 pde_nft)
            SELECT 0,
                   x_id1,
                   'T',
                   x_id2,
                   CASE rcca_nda
                       WHEN 8220 THEN 100
                       WHEN 8222 THEN 101
                       WHEN 8223 THEN 102
                       WHEN 8224 THEN 103
                       WHEN 8225 THEN 104
                       WHEN 8228 THEN 105
                       WHEN 8226 THEN 106
                       WHEN 8227 THEN 107
                       WHEN 8229 THEN 108
                       WHEN 8230 THEN 109
                       WHEN 8231 THEN 110
                       WHEN 8232 THEN 111
                       WHEN 8233 THEN 112
                       WHEN 8234 THEN 113
                       WHEN 8235 THEN 114
                       WHEN 8236 THEN 115
                       WHEN 8245 THEN 116
                       WHEN 8346 THEN 125
                   END
              FROM tmp_work_set2, rc_candidates, rc_candidate_attr
             WHERE     rcc_rc = p_rc_id
                   AND rcc_pd = x_id1
                   AND rcc_sc = x_id3
                   AND rcca_rcc = rcc_id
                   AND rcca_val_string = 'T';

        --Пишемо протокол в змінені рішення
        FOR xx IN (SELECT DISTINCT pd_id,
                                   pd_st,
                                   pd_stop_dt,
                                   x_dt2
                     FROM tmp_work_set2 z1, pc_decision
                    WHERE x_id1 = pd_id AND x_string1 = '+')
        LOOP
            API$PC_DECISION.write_pd_log (
                xx.pd_id,
                l_hs,
                xx.pd_st,
                CHR (38) || '281#' || TO_CHAR (xx.x_dt2, 'DD.MM.YYYY'),
                xx.pd_st);
        END LOOP;
    END;

    PROCEDURE Prepare_S_VPO_131 (p_rc_id recalculates.rc_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_s_vpo_131_list (r_pd,
                                        r_pdf,
                                        r_sc,
                                        r_pc,
                                        r_start_dt,
                                        r_stop_dt,
                                        r_chk_dt,
                                        r_chk_month,
                                        r_birth_dt,
                                        r_z_member)
            SELECT pdf_pd,
                   pdf_id,
                   pdf_sc,
                   pd_pc,
                   ADD_MONTHS (rc_month, -3),
                   ADD_MONTHS (rc_month, -2) - 1,
                   rc_month - 1,
                   ADD_MONTHS (rc_month, -1),
                   NVL (
                       (SELECT scb_dt
                          FROM uss_person.v_socialcard,
                               uss_person.v_sc_change,
                               uss_person.v_sc_birth
                         WHERE     sc_id = pdf_sc
                               AND scc_sc = sc_id
                               AND sc_scc = scc_id
                               AND scc_scb = scb_id
                               AND scc_scb > 0),
                       pdf_birth_dt),
                   CASE
                       WHEN EXISTS
                                (SELECT 1
                                   FROM appeal, ap_person ap
                                  WHERE     ap_id = pd_ap
                                        AND app_ap = pd_ap
                                        AND ap.history_status = 'A'
                                        AND app_sc = pdf_sc
                                        AND app_tp = 'Z')
                       THEN
                           'T'
                       ELSE
                           'F'
                   END
              FROM pd_family      mf,
                   pc_decision    md,
                   pc_account,
                   tmp_work_ids3  orgs,
                   recalculates   m
             WHERE     pdf_pd = pd_id
                   AND mf.history_status = 'A'
                   AND pd_pa = pa_id
                   AND pa_org = orgs.x_id
                   AND rc_id = p_rc_id
                   AND pd_st = 'S'
                   AND pd_nst = 664
                   AND pd_stop_dt = rc_month - 1 --Діють на останній день що передує розрахунковому місяцю
                   AND NOT EXISTS
                           (SELECT 1 --Відсутнє інше рішення, яке діяло в місяці , що визначається як «розрахунковий період» «мінус» сім
                              FROM pc_decision sd, pd_accrual_period pdap
                             WHERE     sd.pd_pc = md.pd_pc
                                   AND sd.pd_nst = 664
                                   AND sd.pd_st IN ('S', 'PS')
                                   AND pdap_pd = sd.pd_id
                                   AND pdap.history_status = 'A'
                                   --AND sd.pd_id <> md.pd_id
                                   AND ADD_MONTHS (m.rc_month, -7) BETWEEN pdap_start_dt
                                                                       AND pdap_stop_dt)
                   AND EXISTS
                           (SELECT 1 -- наявне це або інше рішення, яке діяло в місяці, що визначається як «розрахунковий період» «мінус» шість
                              FROM pc_decision sd, pd_accrual_period pdap
                             WHERE     sd.pd_pc = md.pd_pc
                                   AND sd.pd_nst = 664
                                   AND sd.pd_st IN ('S', 'PS')
                                   AND pdap_pd = sd.pd_id
                                   AND pdap.history_status = 'A'
                                   AND ADD_MONTHS (m.rc_month, -6) BETWEEN pdap_start_dt
                                                                       AND pdap_stop_dt)
                   AND NOT EXISTS
                           (SELECT 1 --Не мають інших рішеннь по будь-які осоіб до рішення, що аналізається
                              FROM uss_esr.pc_decision  next_pd,
                                   uss_esr.pd_family    next_f,
                                   uss_esr.pd_family    curr
                             WHERE     curr.pdf_pd = md.pd_id
                                   AND next_f.pdf_sc = curr.pdf_sc
                                   AND next_f.pdf_pd = next_pd.pd_id
                                   AND next_pd.pd_nst = 664
                                   AND next_pd.pd_start_dt > rc_month
                                   AND next_f.history_status = 'A'
                                   AND curr.history_status = 'A')
                   AND EXISTS
                           (SELECT 1  --Подовжувалось перерахунком 'S_VPO_133'
                              FROM pd_payment pdp
                             WHERE     pdp_pd = pd_id
                                   AND m.rc_month - 1 BETWEEN pdp_start_dt
                                                          AND pdp_stop_dt
                                   AND pdp.history_status = 'A'
                                   AND pdp_sum > 0   --Сума загалом не нульова
                                                  )
                   AND NOT EXISTS
                           (SELECT 1
                              FROM pd_payment pdi, recalculates slrc
                             WHERE     pdi.pdp_pd = pd_id
                                   AND pdi.history_status = 'A'
                                   AND m.rc_month - 1 BETWEEN pdi.pdp_start_dt
                                                          AND pdi.pdp_stop_dt
                                   AND pdi.pdp_rc = slrc.rc_id
                                   AND slrc.rc_tp IN ('S_VPO_INC'));

        /*AND ((pd_stop_dt = rc_month - 1 --Діють на останній день що передує розрахунковому місяцю
            AND NOT EXISTS (SELECT 1
                            FROM pc_decision ed, pd_family ef
                            WHERE ef.pdf_pd = ed.pd_id
                              AND ed.pd_nst = 664
                              AND ef.pdf_sc = mf.pdf_sc
                              AND ed.pd_stop_dt >= rc_month))
          OR (pd_stop_dt = ADD_MONTHS(rc_month, 6) - 1
            AND NOT EXISTS (SELECT 1 --немає інших рішень
                            FROM pc_decision ed, pd_family ef
                            WHERE ef.pdf_pd = ed.pd_id
                              AND ed.pd_nst = 664
                              AND ef.pdf_sc = mf.pdf_sc
                              AND ed.pd_stop_dt >= rc_month
                              AND ed.pd_id <> md.pd_id)
            AND EXISTS (SELECT 1
                        FROM pd_family chk --Перевіряємо не осіб-кандидатів, а "всіх осіб в рішення" - аби в результуючі кандидати попали всі особи рішення, а не тільки ті, що підходять під наступні умови
                        WHERE chk.pdf_pd = pd_id
                          AND EXISTS (SELECT 1 --Є сума, з розподілом, по особі в попередньому місяці
                                      FROM pd_payment pdp, pd_detail
                                      WHERE pdp.history_status = 'A'
                                        AND pdp_pd = pd_id
                                        AND pdd_pdp = pdp_id
                                        AND pdp_stop_dt = rc_month - 1
                                        AND pdd_key = chk.pdf_id
                                        AND pdd_ndp IN (290, 300)
                                        AND pdd_value > 0)
                          AND NOT EXISTS (SELECT 1 --Немає суми, з розподілом, по особі в поточному місяці (тобто - по особі не нарахували)
                                      FROM pd_payment pdp, pd_detail
                                      WHERE pdp.history_status = 'A'
                                        AND pdp_pd = pd_id
                                        AND pdd_pdp = pdp_id
                                        AND pdp_start_dt = rc_month
                                        AND pdd_key = chk.pdf_id
                                        AND pdd_ndp IN (290, 300)
                                        AND pdd_value > 0))));*/
        --  raise_application_error(-20009, 'В реалізації'||SQL%ROWCOUNT||'!');

        --особам, які втратили працездатність, зокрема які досягли пенсійного віку, визначеного частиною першою статті
        --26 Закону України “Про загальнообов'язкове державне пенсійне страхування”, та отримують пенсію, розмір якої не
        --перевищує чотирьох розмірів прожиткового мінімуму для осіб, які втратили працездатність, на 1 січня року, в якому приймається рішення про призначення допомоги
        UPDATE tmp_s_vpo_131_list
           SET r_is_pens_9444 = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_131_list
           SET r_is_pens_9444 = 'T'
         WHERE EXISTS
                   (SELECT 1
                      FROM src_pension_info ma
                     WHERE     spi_sc = r_sc
                           AND spi_month =
                               (SELECT MAX (sl.spi_month)
                                  FROM src_pension_info sl
                                 WHERE     ma.spi_sc = sl.spi_sc
                                       AND sl.spi_month <= r_chk_dt)
                           AND (   (    spi_ls_subject_tp IN
                                            ('PENS', 'DD', 'DPN')
                                    AND spi_sum_zag > 0
                                    AND spi_sum_zag < 9444)
                                OR (    spi_ls_subject_tp_mil IN
                                            ('PENS', 'DD', 'DPN')
                                    AND spi_sum_zag_mil > 0
                                    AND spi_sum_zag_mil < 9444)));

        --особам з інвалідністю I чи II групи, дитині з інвалідністю віком до 18 років, дитині, хворій на тяжкі перинатальні ураження нервової системи, тяжкі вроджені
        --вади розвитку, рідкісні орфанні захворювання, онкологічні, онкогематологічні захворювання, дитячий церебральний параліч, тяжкі психічні розлади,
        --цукровий діабет I типу (інсулінозалежний), гострі або хронічні захворювання нирок IV ступеня, яка отримала тяжку травму, потребує трансплантації органа,
        --потребує паліативної допомоги, якій не встановлено інвалідність, що підтверджується документальн
        UPDATE tmp_s_vpo_131_list
           SET r_pre_inv_group_by_ap =
                   (SELECT MIN (apda_val_string) --Група інвалідності з довідки МСЕК в зверненні
                      FROM pc_decision,
                           ap_person         app,
                           ap_document       ap,
                           ap_document_attr  apda
                     WHERE     pd_id = r_pd
                           AND app_sc = r_sc
                           AND app.history_status = 'A'
                           AND ap.history_status = 'A'
                           AND apda.history_status = 'A'
                           AND app_ap IN (pd_ap, pd_ap_reason)
                           AND apd_app = app_id
                           AND apda_apd = apd_id
                           AND apd_ndt = 201
                           AND apda_nda = 349),
               r_pre_inv_till_by_ap =
                   (SELECT MIN (apda_val_dt) --Дата призначено до з довідки МСЕК в зверненні
                      FROM pc_decision,
                           ap_person         app,
                           ap_document       ap,
                           ap_document_attr  apda
                     WHERE     pd_id = r_pd
                           AND app_sc = r_sc
                           AND app.history_status = 'A'
                           AND ap.history_status = 'A'
                           AND apda.history_status = 'A'
                           AND app_ap IN (pd_ap, pd_ap_reason)
                           AND apd_app = app_id
                           AND apda_apd = apd_id
                           AND apd_ndt = 201
                           AND apda_nda = 347),
               r_pre_have_201_in_ap =
                   CASE
                       WHEN EXISTS
                                (SELECT 1 --Чи є взагалі довідка МСЕК в зверненні
                                   FROM pc_decision,
                                        ap_person    app,
                                        ap_document  ap
                                  WHERE     pd_id = r_pd
                                        AND app_sc = r_sc
                                        AND app.history_status = 'A'
                                        AND ap.history_status = 'A'
                                        AND app_ap IN (pd_ap, pd_ap_reason)
                                        AND apd_app = app_id
                                        AND apd_ndt = 201)
                       THEN
                           'T'
                       ELSE
                           'F'
                   END,
               r_pre_in_bd =
                   CASE
                       WHEN EXISTS
                                (SELECT 1 --Чи є особа в бойових діях або можливих бойових діях по довідці ВПО
                                   FROM uss_person.v_sc_document,
                                        Uss_Doc.v_Doc_Attr2hist   h,
                                        Uss_Doc.v_Doc_Attributes  a
                                  WHERE     h.Da2h_Da = a.Da_Id
                                        AND da2h_dh = scd_dh
                                        AND scd_st IN ('1', 'A')
                                        AND da_nda = 4492
                                        AND scd_sc = r_sc
                                        AND EXISTS
                                                (SELECT 1
                                                   FROM uss_ndi.v_ndi_kaot_state
                                                        kaots,
                                                        uss_ndi.v_ndi_normative_act
                                                        nna
                                                  WHERE     kaots_kaot =
                                                            da_val_id
                                                        AND kaots.history_status =
                                                            'A'
                                                        AND kaots_nna =
                                                            nna_id
                                                        AND nna.history_status =
                                                            'A'
                                                        AND kaots_tp IN
                                                                ('BD', 'PMO') --В бойових діяхчи можливих бойових діях
                                                        AND (   kaots_stop_dt >
                                                                r_chk_dt
                                                             OR kaots_stop_dt
                                                                    IS NULL)))
                       THEN
                           'T'
                       ELSE
                           'F'
                   END
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_131_list
           SET r_is_various_sic = 'F'
         WHERE 1 = 1;

        --Шукаємо серед даних довідок МСЕК, що прикріплені до рішення, такі, в яких 1/2 група та "призначено до" після r_start_dt (-3 місяці від розрахункового місяця).
        --Всіх інших з довідкою - виключаємо
        UPDATE tmp_s_vpo_131_list
           SET r_is_various_sic =
                   CASE
                       WHEN r_pre_inv_group_by_ap IN ('1', '2') THEN 'T'
                       ELSE 'X'
                   END
         WHERE     r_is_various_sic = 'F'
               AND r_pre_have_201_in_ap = 'T'
               AND r_pre_inv_till_by_ap > r_chk_dt;

        --Шукаємо серед даних довідок МСЕК, що прикріплені до рішення, такі, в яких 1/2 група та "призначено до" до r_start_dt (-3 місяці від розрахункового місяця) та в Бойових діях чи можливих бойових діях по довідці ВПО.
        --Всіх інших з довідкою - виключаємо
        UPDATE tmp_s_vpo_131_list
           SET r_is_various_sic =
                   CASE
                       WHEN r_pre_inv_group_by_ap IN ('1', '2') THEN 'T'
                       ELSE 'X'
                   END
         WHERE     r_is_various_sic = 'F'
               AND r_pre_have_201_in_ap = 'T'
               AND r_pre_inv_till_by_ap <= r_chk_dt
               AND r_pre_in_bd = 'T';

        --Обраховуємо дані по довідкам МСЕК з ЦБІ
        UPDATE tmp_s_vpo_131_list
           SET r_pre_inv_group_from_cbi =
                   (SELECT da_val_string --Група інвалідності з довідки МСЕК з даних ЦБІ
                      FROM uss_person.v_sc_document,
                           Uss_Doc.v_Doc_Attr2hist   h,
                           Uss_Doc.v_Doc_Attributes  a
                     WHERE     scd_sc = r_sc
                           AND scd_st IN ('1', 'A')
                           AND scd_ndt = 201
                           AND scd_src = '34'
                           AND Da2h_Da = a.Da_Id
                           AND da2h_dh = scd_dh
                           AND da_nda = 349),
               r_pre_inv_till_from_cbi =
                   (SELECT da_val_dt --Дата призначено до з довідки МСЕК з даних ЦБІ
                      FROM uss_person.v_sc_document,
                           Uss_Doc.v_Doc_Attr2hist   h,
                           Uss_Doc.v_Doc_Attributes  a
                     WHERE     scd_sc = r_sc
                           AND scd_st IN ('1', 'A')
                           AND scd_ndt = 201
                           AND scd_src = '34'
                           AND Da2h_Da = a.Da_Id
                           AND da2h_dh = scd_dh
                           AND da_nda = 347),
               r_pre_have_201_from_cbi =
                   CASE
                       WHEN EXISTS
                                (SELECT 1 --Чи є взагалі довідка МСЕК з даних ЦБІ
                                   FROM uss_person.v_sc_document
                                  WHERE     scd_sc = r_sc
                                        AND scd_st IN ('1', 'A')
                                        AND scd_ndt = 201
                                        AND scd_src = '34')
                       THEN
                           'T'
                       ELSE
                           'F'
                   END
         WHERE r_is_various_sic = 'F';

        --Шукаємо серед даних довідок МСЕК, що надійшли з ЦБІ, такі, в яких 1/2 група та "призначено до" після r_start_dt (-3 місяці від розрахункового місяця).
        --Всіх інших з довідкою - виключаємо
        UPDATE tmp_s_vpo_131_list
           SET r_is_various_sic =
                   CASE
                       WHEN r_pre_inv_group_from_cbi IN ('1', '2') THEN 'T'
                       ELSE 'X'
                   END
         WHERE     r_is_various_sic = 'F'
               AND r_pre_have_201_from_cbi = 'T'
               AND r_pre_inv_till_from_cbi > r_chk_dt;

        --Шукаємо серед даних довідок МСЕК, що надійшли з ЦБІ, такі, в яких 1/2 група та "призначено до" до r_start_dt (-3 місяці від розрахункового місяця) та в Бойових діях чи можливих бойових діях по довідці ВПО.
        --Всіх інших з довідкою - виключаємо
        UPDATE tmp_s_vpo_131_list
           SET r_is_various_sic =
                   CASE
                       WHEN r_pre_inv_group_from_cbi IN ('1', '2') THEN 'T'
                       ELSE 'X'
                   END
         WHERE     r_is_various_sic = 'F'
               AND r_pre_have_201_from_cbi = 'T'
               AND r_pre_inv_till_from_cbi <= r_chk_dt
               AND r_pre_in_bd = 'T';

        --Обраховуємо дані по даним АСПОД
        UPDATE tmp_s_vpo_131_list
           SET r_pre_inv_group_from_asd =
                   (SELECT MIN (sda_dis_group) --Група інвалідності по даним АСПОД
                      FROM src_disability_asopd
                     WHERE     sda_sc = r_sc
                           AND sda_dt =
                               (SELECT MAX (sl.sda_dt)
                                  FROM src_disability_asopd sl
                                 WHERE     sl.sda_sc = r_sc
                                       AND sl.sda_dt BETWEEN r_chk_month
                                                         AND r_chk_dt)
                           AND sda_dis_group IS NOT NULL
                           AND sda_dis_group IN ('1', '2')),
               r_pre_inv_till_from_asd =
                   (SELECT MIN (sda_dis_end) --Дата призначено до по даним АСПОД
                      FROM src_disability_asopd
                     WHERE     sda_sc = r_sc
                           AND sda_dt =
                               (SELECT MAX (sl.sda_dt)
                                  FROM src_disability_asopd sl
                                 WHERE     sl.sda_sc = r_sc
                                       AND sl.sda_dt BETWEEN r_chk_month
                                                         AND r_chk_dt)
                           AND sda_dis_group IS NOT NULL
                           AND sda_dis_group IN ('1', '2')),
               r_pre_have_201_from_asd =
                   CASE
                       WHEN EXISTS
                                (SELECT 1            --Чи є взагалі дані АСПОД
                                   FROM src_disability_asopd
                                  WHERE     sda_sc = r_sc
                                        AND sda_dt BETWEEN r_chk_month
                                                       AND r_chk_dt
                                        AND sda_dis_group IS NOT NULL)
                       THEN
                           'T'
                       ELSE
                           'F'
                   END
         WHERE r_is_various_sic = 'F';

        --Шукаємо серед даних АСОПД, такі, в яких 1/2 група та "призначено до" після r_start_dt (-3 місяці від розрахункового місяця).
        --Всіх інших з довідкою - виключаємо
        UPDATE tmp_s_vpo_131_list
           SET r_is_various_sic =
                   CASE
                       WHEN r_pre_inv_group_from_asd IN ('1', '2') THEN 'T'
                       ELSE 'X'
                   END
         WHERE     r_is_various_sic = 'F'
               AND r_pre_have_201_from_asd = 'T'
               AND r_pre_inv_till_from_asd > r_chk_dt;

        --Шукаємо серед даних АСОПД, такі, в яких 1/2 група та "призначено до" до r_start_dt (-3 місяці від розрахункового місяця) та в Бойових діях чи можливих бойових діях по довідці ВПО.
        --Всіх інших з довідкою - виключаємо
        UPDATE tmp_s_vpo_131_list
           SET r_is_various_sic =
                   CASE
                       WHEN r_pre_inv_group_from_asd IN ('1', '2') THEN 'T'
                       ELSE 'X'
                   END
         WHERE     r_is_various_sic = 'F'
               AND r_pre_have_201_from_asd = 'T'
               AND r_pre_inv_till_from_asd <= r_chk_dt
               AND r_pre_in_bd = 'T';

        --В ЄІССС здійснюємо пошук рішень по послузі з Ід=265 встановлюємо ознаку «має право, як хвора дитина» тим учасникам рішень, які мають вік до 18-ти років
        UPDATE tmp_s_vpo_131_list
           SET r_is_have_265 = 'F'
         WHERE 1 = 1;

        --Шукаємо рішення 265 по учаснику
        UPDATE tmp_s_vpo_131_list
           SET r_is_have_265 = 'T'
         WHERE     r_birth_dt > ADD_MONTHS (r_chk_dt, -216)
               AND EXISTS
                       (SELECT 1
                          FROM pc_decision,
                               pd_family          mf,
                               pd_accrual_period  pdap
                         WHERE     pd_nst = 265
                               AND mf.history_status = 'A'
                               AND pdf_pd = pd_id
                               AND pdf_sc = r_sc
                               AND pd_st IN ('S', 'PS')
                               AND pdap_pd = pd_id
                               AND pdap.history_status = 'A'
                               AND r_chk_dt BETWEEN pdap_start_dt
                                                AND pdap_stop_dt);

        --ЄІССС здійснюємо пошук рішень по послузі з Ід=248 встановлюємо ознаку «має право, як дитина з інвалідністю до 18-ти років» тим учасникам рішень, які мають вік до 18-ти років
        UPDATE tmp_s_vpo_131_list
           SET r_is_have_248 = 'F'
         WHERE 1 = 1;

        --Шукаємо рішення 248 по учаснику
        UPDATE tmp_s_vpo_131_list
           SET r_is_have_248 = 'T'
         WHERE     r_birth_dt > ADD_MONTHS (r_chk_dt, -216)
               AND EXISTS
                       (SELECT 1
                          FROM pc_decision,
                               pd_family          mf,
                               pd_accrual_period  pdap
                         WHERE     pd_nst = 248
                               AND mf.history_status = 'A'
                               AND pdf_pd = pd_id
                               AND pdf_sc = r_sc
                               AND pd_st IN ('S', 'PS')
                               AND pdap_pd = pd_id
                               AND pdap.history_status = 'A'
                               AND r_chk_dt BETWEEN pdap_start_dt
                                                AND pdap_stop_dt);


        --!В ЄІССС здійснюємо пошук рішень по послузі з Ід=248 і встановлюємо «має право, як особа, з інвалідністю 1 або 2 групи»,
        --!якщо в особи звернення по послузі з Ід=248, у якому наявний документ з Ід=201 («Виписка МСЕК»)
        --!і в атрибуті з Ід= 349 («група інвалідності») встановлено 1 група або 2 група і в атрибуті 347 («встановлено на період по») зазначено дату до першого дня місяця (включно),
        --!що дорівнює «розрахунковий період» мінус 3 місяці і в довідці ВПО в атрибуті з Ід= 4492 (КАТОТТГ), зазначено КАТОТТГ, у якого встановлено ознаку «Активні бойові дії» або «Можливі бойові дії»
        --По особі  ЄІССС здійснюємо пошук рішень по послузі з Ід=248
        --Якщо щодо особи наявний документ з Ід=201 («Виписка МСЕК») і в атрибуті з Ід= 349 («група інвалідності») встановлено 1 група або 2 група
        -- і в атрибуті 347 («встановлено на період по») зазначено дату після першого дня місяця (включно), що дорівнює «розрахунковий період» мінус 3 місяці,
        --то встановлюємо ознаку «має право, як особа, з інвалідністю 1 або 2 групи за даними призначеної допомоги особам з інвалідністю з дитинства»
        UPDATE tmp_s_vpo_131_list
           SET r_is_have_248_and_have_201 = 'F'
         WHERE 1 = 1;

        --Знаходим тих, в кого взагалі є 248 послуга
        UPDATE tmp_s_vpo_131_list
           SET r_is_have_248_and_have_201 = 'X'
         WHERE EXISTS
                   (SELECT 1
                      FROM pc_decision, pd_family mf, pd_accrual_period pdap
                     WHERE     pd_nst = 248
                           AND mf.history_status = 'A'
                           AND pdf_pd = pd_id
                           AND pdf_sc = r_sc
                           AND pd_st IN ('S', 'PS')
                           AND pdap_pd = pd_id
                           AND pdap.history_status = 'A'
                           AND r_chk_dt BETWEEN pdap_start_dt
                                            AND pdap_stop_dt);

        --По таким образовуємо групу інвалідності та дату "призначено по"
        UPDATE tmp_s_vpo_131_list
           SET r_pre_inv_group_by_248_ap =
                   (SELECT MIN (apda_val_string) --Група інвалідності з довідки МСЕК в зверненні
                      FROM pc_decision,
                           ap_person          app,
                           ap_document        ap,
                           ap_document_attr   apda,
                           pd_accrual_period  pdap
                     WHERE     pd_nst = 248
                           AND app_sc = r_sc
                           AND app.history_status = 'A'
                           AND ap.history_status = 'A'
                           AND apda.history_status = 'A'
                           AND app_ap IN (pd_ap, pd_ap_reason)
                           AND apd_app = app_id
                           AND apda_apd = apd_id
                           AND apd_ndt = 201
                           AND apda_nda = 349
                           AND pd_st IN ('S', 'PS')
                           AND pdap_pd = pd_id
                           AND pdap.history_status = 'A'
                           AND r_chk_dt BETWEEN pdap_start_dt
                                            AND pdap_stop_dt),
               r_pre_inv_till_by_248_ap =
                   (SELECT MIN (apda_val_dt) --Дата призначено до з довідки МСЕК в зверненні
                      FROM pc_decision,
                           ap_person          app,
                           ap_document        ap,
                           ap_document_attr   apda,
                           pd_accrual_period  pdap
                     WHERE     pd_nst = 248
                           AND app_sc = r_sc
                           AND app.history_status = 'A'
                           AND ap.history_status = 'A'
                           AND apda.history_status = 'A'
                           AND app_ap IN (pd_ap, pd_ap_reason)
                           AND apd_app = app_id
                           AND apda_apd = apd_id
                           AND apd_ndt = 201
                           AND apda_nda = 347
                           AND pd_st IN ('S', 'PS')
                           AND pdap_pd = pd_id
                           AND pdap.history_status = 'A'
                           AND r_chk_dt BETWEEN pdap_start_dt
                                            AND pdap_stop_dt)
         WHERE r_is_have_248_and_have_201 = 'X';

        --  UPDATE tmp_s_vpo_131_list
        --    SET r_is_have_248_and_have_201 = CASE WHEN r_pre_inv_group_by_248_ap IN ('1', '2') AND r_pre_inv_till_by_248_ap < r_start_dt AND r_pre_in_bd = 'T' THEN 'T' ELSE 'X' END
        --    WHERE r_is_have_248_and_have_201 = 'X';

        UPDATE tmp_s_vpo_131_list
           SET r_is_have_248_and_have_201 =
                   CASE
                       WHEN     r_pre_inv_group_by_248_ap IN ('1', '2')
                            AND r_pre_inv_till_by_248_ap >= r_start_dt
                       THEN
                           'T'
                       ELSE
                           'X'
                   END
         WHERE r_is_have_248_and_have_201 = 'X';

        --За даними ЄІС «Діти» встановлюємо ознаку «має право, як дитина сирота» дітям сиротам
        UPDATE tmp_s_vpo_131_list
           SET r_is_orphan = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_131_list
           SET r_is_orphan = 'T'
         WHERE EXISTS
                   (SELECT 1
                      FROM src_orphans_reestr
                     WHERE     sor_sc_child = r_sc
                           AND sor_dt BETWEEN r_chk_month AND r_chk_dt);

        --За даними ЄІС «Діти» встановлюємо ознаки «має право, як батько вихователь» батькам виховалелям
        UPDATE tmp_s_vpo_131_list
           SET r_is_orphan_parent = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_131_list
           SET r_is_orphan_parent = 'T'
         WHERE    EXISTS
                      (SELECT 1
                         FROM src_orphans_reestr
                        WHERE     sor_sc_father = r_sc
                              AND sor_dt BETWEEN r_chk_month AND r_chk_dt)
               OR EXISTS
                      (SELECT 1
                         FROM src_orphans_reestr
                        WHERE     sor_sc_mother = r_sc
                              AND sor_dt BETWEEN r_chk_month AND r_chk_dt);

        --За даними ЄІС «Діти» встановлюємо ознаки «має право, як прийомні батьки» прийомним батькам
        UPDATE tmp_s_vpo_131_list
           SET r_is_adopt_parent = 'F'
         WHERE 1 = 1;

        /*UPDATE tmp_s_vpo_131_list
          SET r_is_adopt_parent = 'T'
          WHERE EXISTS (SELECT 1
                        FROM src_orphan_reestr
                        WHERE sor_sc_child = r_sc
                          AND sor_dt BETWEEN r_chk_month AND r_chk_dt);*/

        --В ЄІССС здійснюємо пошук рішень по послузі з Ід=268 встановлюємо ознаку «має право, як дитина сирота або як дитина,
        --позбавленим батьківського піклування» тим учасникам рішень, які мають вік до 18-ти років на перше число розрахункового місяця включно
        UPDATE tmp_s_vpo_131_list
           SET r_is_268_orphant = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_131_list
           SET r_is_268_orphant = 'T'
         WHERE     r_birth_dt >= ADD_MONTHS (r_chk_dt, -216)
               AND EXISTS
                       (SELECT 1
                          FROM pc_decision,
                               pd_family          mf,
                               pd_accrual_period  pdap
                         WHERE     pd_nst = 268
                               AND mf.history_status = 'A'
                               AND pdf_pd = pd_id
                               AND pdf_sc = r_sc
                               AND pd_st IN ('S', 'PS')
                               AND pdap_pd = pd_id
                               AND pdap.history_status = 'A'
                               AND r_chk_dt BETWEEN pdap_start_dt
                                                AND pdap_stop_dt);

        --В ЄІССС здійснюємо пошук рішень по послузі з Ід=268 встановлюємо ознаку «має право, як опікун (піклувальник)» тим учасникам рішень,
        --які є заявниками, якщо в рішенні є хоча б одна дитина  віком до 18-ти років станом на перше число розрахункового місяця включно
        UPDATE tmp_s_vpo_131_list
           SET r_is_268_parent = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_131_list
           SET r_is_268_parent = 'T'
         WHERE     r_birth_dt < ADD_MONTHS (r_chk_dt, -216)
               AND EXISTS
                       (SELECT 1
                          FROM pc_decision,
                               pd_accrual_period  pdap,
                               ap_person          app
                         WHERE     pd_nst = 268
                               AND pd_st IN ('S', 'PS')
                               AND pdap_pd = pd_id
                               AND pdap.history_status = 'A'
                               AND r_chk_dt BETWEEN pdap_start_dt
                                                AND pdap_stop_dt
                               AND app_ap = pd_ap
                               AND app_sc = r_sc
                               AND app.history_status = 'A'
                               AND app_tp = 'Z'
                               AND 1 <=
                                   (SELECT COUNT (*)
                                      FROM pd_family spdf
                                     WHERE     spdf.pdf_pd = pd_id
                                           AND spdf.history_status = 'A'
                                           AND spdf.pdf_birth_dt >=
                                               ADD_MONTHS (r_chk_dt, -216)));

        --Якщо щодо особи наявна інформація про інвалідність або з ПФУ, або з ЦБІ, а саме, «група інвалідності» встановлено 1 група або 2 група і відсутній атрибут «встановлено на період по»,  то встановлюємо ознаку «має право, як особа, з інвалідністю 1 або 2 групи за даними ПФУ або ЦБІ»
        UPDATE tmp_s_vpo_131_list
           SET r_is_pfu_cbi_inv = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_131_list
           SET r_is_pfu_cbi_inv = 'T'
         WHERE    EXISTS
                      (SELECT 1
                         FROM uss_person.v_sc_document,
                              Uss_Doc.v_Doc_Attr2hist   h,
                              Uss_Doc.v_Doc_Attributes  a
                        WHERE     scd_sc = r_sc
                              AND scd_st IN ('1', 'A')
                              AND scd_ndt = 201
                              AND scd_src = '34'
                              AND Da2h_Da = a.Da_Id
                              AND da2h_dh = scd_dh
                              AND da_nda = 349
                              AND da_val_string IN ('1', '2')) --Група інвалідності з довідки МСЕК з даних ЦБІ
               OR EXISTS
                      (SELECT 1
                         FROM src_pension_info
                        WHERE     spi_sc = r_sc
                              AND spi_month BETWEEN r_chk_month AND r_chk_dt
                              AND (   spi_inv_gr IN ('1', '2')
                                   OR spi_inv_gr_mil IN ('1', '2'))); --Група інвалідності з даних ПФУ
    END;


    PROCEDURE Recalc_S_VPO_131 (p_rc_id   recalculates.rc_id%TYPE,
                                p_hs      histsession.hs_id%TYPE)
    IS
        l_hs            histsession.hs_id%TYPE;
        l_recalculate   recalculates%ROWTYPE;
    BEGIN
        --  raise_application_error(-20009, 'В реалізації!');
        l_hs := p_hs;

        IF l_hs IS NULL
        THEN
            l_hs := TOOLS.GetHistSession;
        END IF;

        SELECT *
          INTO l_recalculate
          FROM recalculates
         WHERE rc_id = p_rc_id;

        --ikis_sysweb.ikis_debug_pipe.WriteMsg(l_recalculate.rc_org_list);
        TOOLS.org_list_to_work_ids (3, l_recalculate.rc_org_list);

        DELETE FROM tmp_work_set2
              WHERE 1 = 1;

        DELETE FROM tmp_work_set3
              WHERE 1 = 1;

        --Знаходимо всі рішення і осіб, які діють на дату початку місяція перерахунку
        INSERT INTO tmp_work_set2 (x_id1,
                                   x_id2,
                                   x_id3,
                                   x_id4,
                                   x_id5,
                                   x_dt1,
                                   x_dt2,
                                   x_dt3,
                                   x_dt4)
            SELECT pdf_pd,
                   pdf_id,
                   pdf_sc,
                   pd_pc,
                   pdp_id,
                   NVL (
                       (SELECT scb_dt
                          FROM uss_person.v_socialcard,
                               uss_person.v_sc_change,
                               uss_person.v_sc_birth
                         WHERE     sc_id = pdf_sc
                               AND scc_sc = sc_id
                               AND sc_scc = scc_id
                               AND scc_scb = scb_id
                               AND scc_scb > 0),
                       pdf_birth_dt),
                   rc_month,
                   pd_stop_dt,
                   SYSDATE
              FROM rc_candidates,
                   pd_family      mf,
                   pc_decision    md,
                   pc_account,
                   tmp_work_ids3  orgs,
                   recalculates   m,
                   pd_payment     pdp
             WHERE     rcc_rc = rc_id
                   AND mf.history_status = 'A'
                   AND rcc_pd = pd_id
                   AND rcc_sc = pdf_sc
                   AND pdf_pd = pd_id
                   AND pd_pa = pa_id
                   AND pa_org = orgs.x_id
                   AND rc_id = p_rc_id
                   AND pd_st = 'S'
                   AND pd_nst = 664
                   AND pd_stop_dt = rc_month - 1 --Діють на останній день що передує розрахунковому місяцю
                   AND NOT EXISTS
                           (SELECT 1 --Відсутнє інше рішення, яке діяло в місяці , що визначається як «розрахунковий період» «мінус» сім
                              FROM pc_decision sd, pd_accrual_period pdap
                             WHERE     sd.pd_pc = md.pd_pc
                                   AND sd.pd_nst = 664
                                   AND sd.pd_st IN ('S', 'PS')
                                   AND pdap_pd = sd.pd_id
                                   AND pdap.history_status = 'A'
                                   --AND sd.pd_id <> md.pd_id
                                   AND ADD_MONTHS (m.rc_month, -7) BETWEEN pdap_start_dt
                                                                       AND pdap_stop_dt)
                   AND EXISTS
                           (SELECT 1 -- наявне це або інше рішення, яке діяло в місяці, що визначається як «розрахунковий період» «мінус» шість
                              FROM pc_decision sd, pd_accrual_period pdap
                             WHERE     sd.pd_pc = md.pd_pc
                                   AND sd.pd_nst = 664
                                   AND sd.pd_st IN ('S', 'PS')
                                   AND pdap_pd = sd.pd_id
                                   AND pdap.history_status = 'A'
                                   AND ADD_MONTHS (m.rc_month, -6) BETWEEN pdap_start_dt
                                                                       AND pdap_stop_dt)
                   AND NOT EXISTS
                           (SELECT 1 --Не мають інших рішеннь по будь-які осоіб до рішення, що аналізається
                              FROM uss_esr.pc_decision  next_pd,
                                   uss_esr.pd_family    next_f,
                                   uss_esr.pd_family    curr
                             WHERE     curr.pdf_pd = md.pd_id
                                   AND next_f.pdf_sc = curr.pdf_sc
                                   AND next_f.pdf_pd = next_pd.pd_id
                                   AND next_pd.pd_nst = 664
                                   AND next_pd.pd_start_dt > rc_month
                                   AND next_f.history_status = 'A'
                                   AND curr.history_status = 'A')
                   AND pdp_sum > 0                   --Сума загалом не нульова
                   /*AND ((pd_stop_dt = rc_month - 1 --Діють на останній день що передує розрахунковому місяцю
                       AND NOT EXISTS (SELECT 1
                                       FROM pc_decision ed, pd_family ef
                                       WHERE ef.pdf_pd = ed.pd_id
                                         AND ed.pd_nst = 664
                                         AND ef.pdf_sc = mf.pdf_sc
                                         AND ed.pd_stop_dt >= rc_month))
                     OR (pd_stop_dt = ADD_MONTHS(rc_month, 6) - 1
                       AND NOT EXISTS (SELECT 1 --немає інших рішень
                                       FROM pc_decision ed, pd_family ef
                                       WHERE ef.pdf_pd = ed.pd_id
                                         AND ed.pd_nst = 664
                                         AND ef.pdf_sc = mf.pdf_sc
                                         AND ed.pd_stop_dt >= rc_month
                                         AND ed.pd_id <> md.pd_id)
                       AND EXISTS (SELECT 1
                                   FROM pd_family chk --Перевіряємо не осіб-кандидатів, а "всіх осіб в рішення" - аби в результуючі кандидати попали всі особи рішення, а не тільки ті, що підходять під наступні умови
                                   WHERE chk.pdf_pd = pd_id
                                     AND EXISTS (SELECT 1 --Є сума, з розподілом, по особі в попередньому місяці
                                                 FROM pd_payment pdp, pd_detail
                                                 WHERE pdp.history_status = 'A'
                                                   AND pdp_pd = pd_id
                                                   AND pdd_pdp = pdp_id
                                                   AND pdp_stop_dt = rc_month - 1
                                                   AND pdd_key = chk.pdf_id
                                                   AND pdd_ndp IN (290, 300)
                                                   AND pdd_value > 0)
                                     AND NOT EXISTS (SELECT 1 --Немає суми, з розподілом, по особі в поточному місяці (тобто - по особі не нарахували)
                                                 FROM pd_payment pdp, pd_detail
                                                 WHERE pdp.history_status = 'A'
                                                   AND pdp_pd = pd_id
                                                   AND pdd_pdp = pdp_id
                                                   AND pdp_start_dt = rc_month
                                                   AND pdd_key = chk.pdf_id
                                                   AND pdd_ndp IN (290, 300)
                                                   AND pdd_value > 0))))*/
                   AND pdp_pd = pd_id
                   AND pdp.history_status = 'A'
                   AND pdp_stop_dt = rc_month - 1
                   AND NOT EXISTS
                           (SELECT 1
                              FROM pd_payment pdi, recalculates slrc
                             WHERE     pdi.pdp_pd = pd_id
                                   AND pdi.history_status = 'A'
                                   AND m.rc_month - 1 BETWEEN pdi.pdp_start_dt
                                                          AND pdi.pdp_stop_dt
                                   AND pdi.pdp_rc = slrc.rc_id
                                   AND slrc.rc_tp IN ('S_VPO_INC'));

        --  write_rc_log(p_rc_id, l_hs, 'F', NULL, l_recalculate.rc_st);

        write_message (
            1,
               'Знайдено '
            || SQL%ROWCOUNT
            || ' кандидатів, рішення по яким будуть виконані подовження або неподовження.');

        --Видаляємо всі діючі записи, які діють на перше число місяця перерахунку і пізніше
        UPDATE pd_payment
           SET pdp_hs_del = l_hs, history_status = 'H'
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_set2
                         WHERE pdp_pd = x_id1)
               AND pdp_stop_dt > l_recalculate.rc_month --Так як ми беремо тільки ті, що діють до "rc_month-1" або є записи з rc_month в призначеном, то не треба вставляти розрізане
               AND history_status = 'A';

        --Знаходимо осіб, по яким призначена сума допомоги - збергігається
        UPDATE tmp_work_set2
           SET x_string1 = '+'
         WHERE EXISTS
                   (SELECT 1
                      FROM rc_candidates, rc_candidate_attr
                     WHERE     rcca_rcc = rcc_id
                           AND rcc_rc = p_rc_id
                           AND rcc_pd = x_id1
                           AND rcc_sc = x_id3
                           AND rcca_val_string = 'T');

        --Формуємо нові записи призначеного з місяця перерахунку + 6 місяців
        INSERT INTO pd_payment (pdp_id,
                                pdp_pd,
                                pdp_npt,
                                pdp_start_dt,
                                pdp_stop_dt,
                                history_status,
                                pdp_hs_ins,
                                pdp_src,
                                pdp_rc)
            SELECT 0,
                   pdp_pd,
                   pdp_npt,
                   l_recalculate.rc_month,
                   ADD_MONTHS (l_recalculate.rc_month, 6) - 1,
                   'A',
                   l_hs,
                   'EMS',
                   p_rc_id
              FROM pd_payment
             WHERE EXISTS
                       (SELECT 1
                          FROM tmp_work_set2
                         WHERE x_string1 = '+' AND x_id5 = pdp_id);

          --відтворюємо записи деталей призначеного на запис призначеного на місяць перерахунку
          INSERT ALL
            WHEN pdd_ndp <> 137
            THEN                     --Робимо копію всіх записів з новою сумою
                INTO pd_detail (pdd_id,
                                pdd_pdp,
                                pdd_row_order,
                                pdd_row_name,
                                pdd_key,
                                pdd_ndp,
                                pdd_start_dt,
                                pdd_stop_dt,
                                pdd_npt,
                                pdd_value)
                  VALUES (0,
                          x_new_pdp,
                          pdd_row_order,
                          pdd_row_name,
                          pdd_key,
                          pdd_ndp,
                          x_start_dt,
                          x_stop_dt,
                          pdd_npt,
                          x_sum)
            WHEN    (x_sum = 0 AND pdd_value > 0 AND pdd_ndp IN (290, 300))
                 OR pdd_ndp = 137
            THEN
                INTO pd_detail (pdd_id,
                                pdd_pdp,
                                pdd_row_order,
                                pdd_row_name,
                                pdd_key,
                                pdd_ndp,
                                pdd_start_dt,
                                pdd_stop_dt,
                                pdd_npt,
                                pdd_value)
                  VALUES (0,
                          x_new_pdp,
                          pdd_row_order,
                          pdd_row_name,
                          pdd_key,
                          137,
                          x_start_dt,
                          x_stop_dt,
                          pdd_npt,
                          pdd_value)
            SELECT pdd_pdp,
                   pdd_row_order,
                   pdd_row_name,
                   pdd_value,
                   pdd_key,
                   pdd_ndp,
                   l_recalculate.rc_month
                       AS x_start_dt,
                   ADD_MONTHS (l_recalculate.rc_month, 6) - 1
                       AS x_stop_dt,
                   pdd_npt,
                   CASE
                       WHEN     pdd_ndp IN (290, 300)
                            AND EXISTS
                                    (SELECT 1
                                       FROM tmp_work_set2
                                      WHERE     x_id1 = pdp_pd
                                            AND x_id2 = pdd_key
                                            AND x_string1 = '+')
                       THEN
                           pdd_value
                       ELSE
                           0
                   END
                       AS x_sum, --сума для 290/300 змінюється в залежності від наявності права
                   (SELECT MAX (pdp_id)
                      FROM pd_payment np
                     WHERE np.pdp_pd = dp.pdp_pd AND np.pdp_hs_ins = l_hs)
                       AS x_new_pdp
              FROM pd_payment dp, pd_detail ma
             WHERE     EXISTS
                           (SELECT 1
                              FROM tmp_work_set2
                             WHERE x_string1 = '+' AND x_id5 = pdp_id)
                   AND pdd_pdp = pdp_id;

        UPDATE pd_payment
           SET pdp_sum =
                   NVL ( (SELECT SUM (pdd_value)
                            FROM pd_detail
                           WHERE pdd_pdp = pdp_id AND pdd_ndp IN (290, 300)),
                        0)
         WHERE pdp_hs_ins = l_hs AND pdp_start_dt = l_recalculate.rc_month;

        DELETE FROM pd_features
              WHERE     pde_nft BETWEEN 117 AND 123
                    AND EXISTS
                            (SELECT 1
                               FROM tmp_work_set2
                              WHERE x_id1 = pde_pd);

        INSERT INTO pd_features (pde_id,
                                 pde_pd,
                                 pde_val_string,
                                 pde_pdf,
                                 pde_nft)
            SELECT 0,
                   x_id1,
                   'T',
                   x_id2,
                   CASE rcca_nda
                       WHEN 8264 THEN 117
                       WHEN 8265 THEN 118
                       WHEN 8266 THEN 119
                       WHEN 8267 THEN 120
                       WHEN 8268 THEN 121
                       WHEN 8269 THEN 122
                       WHEN 8270 THEN 123
                       WHEN 8284 THEN 124
                       WHEN 8347 THEN 126
                       WHEN 8348 THEN 127
                       WHEN 8349 THEN 128
                   END
              FROM tmp_work_set2, rc_candidates, rc_candidate_attr
             WHERE     rcc_rc = p_rc_id
                   AND rcc_pd = x_id1
                   AND rcc_sc = x_id3
                   AND rcca_rcc = rcc_id
                   AND rcca_val_string = 'T';

        -- подовжуємо записи по членах родини
        UPDATE pd_family pdf
           SET pdf.pdf_stop_dt =
                   (SELECT MIN (ADD_MONTHS (x_dt2, 6) - 1)
                      FROM tmp_work_set2
                     WHERE x_id1 = pdf_pd AND x_string1 = '+')
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_set2
                         WHERE x_id1 = pdf_pd AND x_string1 = '+')
               AND (pdf.history_status = 'A' OR pdf.history_status IS NULL)
               AND (   pdf.pdf_stop_dt = (SELECT pd_stop_dt
                                            FROM pc_decision pd
                                           WHERE pdf_pd = pd_id)
                    OR pdf.pdf_stop_dt IS NULL);

        --Подовжуємо номінальний строк дії
        UPDATE pc_decision
           SET pd_stop_dt =
                   (SELECT MIN (ADD_MONTHS (x_dt2, 6) - 1)
                      FROM tmp_work_set2
                     WHERE x_id1 = pd_id AND x_string1 = '+')
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_work_set2
                     WHERE x_id1 = pd_id AND x_string1 = '+');

        --Видаляємо всі діючі записи, які діють на перше число місяця перерахунку і пізніше
        UPDATE pd_accrual_period
           SET pdap_hs_del = l_hs, history_status = 'H'
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_set2
                         WHERE pdap_pd = x_id1)
               AND pdap_stop_dt > l_recalculate.rc_month --Так як ми беремо тільки ті, що діють до "rc_month-1" або є записи з rc_month в призначеном, то не треба вставляти розрізане
               AND history_status = 'A';

        --Подовжуємо реальний строк дії
        INSERT INTO pd_accrual_period (pdap_id,
                                       pdap_pd,
                                       pdap_start_dt,
                                       pdap_stop_dt,
                                       history_status,
                                       pdap_hs_ins)
            SELECT 0,
                   pd_id,
                   (SELECT MIN (x_dt2)
                      FROM tmp_work_set2
                     WHERE x_id1 = pd_id AND x_string1 = '+'),
                   (SELECT MIN (ADD_MONTHS (x_dt2, 6) - 1)
                      FROM tmp_work_set2
                     WHERE x_id1 = pd_id AND x_string1 = '+'),
                   'A',
                   l_hs
              FROM pc_decision
             WHERE EXISTS
                       (SELECT 1
                          FROM tmp_work_set2
                         WHERE x_id1 = pd_id AND x_string1 = '+');

        --Подовжуємо строк дії параметрів виплати
        UPDATE pd_pay_method
           SET pdm_stop_dt =
                   (SELECT MIN (ADD_MONTHS (x_dt2, 6) - 1)
                      FROM tmp_work_set2
                     WHERE x_id1 = pdm_pd AND x_string1 = '+')
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_set2
                         WHERE x_id1 = pdm_pd AND x_string1 = '+')
               AND pdm_is_actual = 'T'
               AND history_status = 'A';

        --Пишемо протокол в змінені рішення
        FOR xx IN (SELECT DISTINCT pd_id,
                                   pd_st,
                                   pd_stop_dt,
                                   x_dt2
                     FROM tmp_work_set2 z1, pc_decision
                    WHERE x_id1 = pd_id AND x_string1 = '+')
        LOOP
            API$PC_DECISION.write_pd_log (
                xx.pd_id,
                l_hs,
                xx.pd_st,
                CHR (38) || '282#' || TO_CHAR (xx.x_dt2, 'DD.MM.YYYY'),
                xx.pd_st);
        END LOOP;
    END;

    PROCEDURE Prepare_S_VPO_133 (p_rc_id recalculates.rc_id%TYPE)
    IS
        l_recalculate   recalculates%ROWTYPE;
    BEGIN
        SELECT *
          INTO l_recalculate
          FROM recalculates
         WHERE rc_id = p_rc_id;

        IF l_recalculate.rc_month < TO_DATE ('01.06.2024', 'DD.MM.YYYY')
        THEN
            raise_application_error (
                -20000,
                'Даний перерахунок можна робити тільки починаючи з 06.2024!');
        END IF;

        --  raise_application_error(-20009, 'В реалізації!');
        INSERT INTO tmp_s_vpo_133_list (r_pd,
                                        r_pdf,
                                        r_sc,
                                        r_pc,
                                        r_start_dt,
                                        r_stop_dt,
                                        r_chk_dt,
                                        r_chk_month,
                                        r_birth_dt,
                                        r_z_member)
            SELECT pdf_pd,
                   pdf_id,
                   pdf_sc,
                   pd_pc,
                   ADD_MONTHS (rc_month, -3),
                   ADD_MONTHS (rc_month, -2) - 1,
                   rc_month - 1,
                   ADD_MONTHS (rc_month, -1),
                   NVL (
                       (SELECT scb_dt
                          FROM uss_person.v_socialcard,
                               uss_person.v_sc_change,
                               uss_person.v_sc_birth
                         WHERE     sc_id = pdf_sc
                               AND scc_sc = sc_id
                               AND sc_scc = scc_id
                               AND scc_scb = scb_id
                               AND scc_scb > 0),
                       pdf_birth_dt),
                   CASE
                       WHEN EXISTS
                                (SELECT 1
                                   FROM ap_person ap
                                  WHERE     app_ap = pd_ap
                                        AND ap.history_status = 'A'
                                        AND app_sc = pdf_sc
                                        AND app_tp = 'Z')
                       THEN
                           'T'
                       ELSE
                           'F'
                   END
              FROM pd_family      mf,
                   pc_decision    md,
                   pc_account,
                   tmp_work_ids3  orgs,
                   appeal,
                   recalculates   m
             WHERE     pdf_pd = pd_id
                   AND mf.history_status = 'A'
                   AND pd_pa = pa_id
                   AND pa_org = orgs.x_id
                   AND pd_ap = ap_id
                   AND rc_id = p_rc_id
                   --      AND ap_reg_dt BETWEEN ADD_MONTHS(rc_month, -3) AND ADD_MONTHS(rc_month, 3) - 1 --призначені в період (-3 місяці, +2 місяці) від періоду розрахунку
                   AND pd_st = 'S'
                   AND pd_nst = 664
                   AND pd_stop_dt >= rc_month    --Діють і в місяці розрахунку
                   AND pd_start_dt >= TO_DATE ('01.03.2024', 'DD.MM.YYYY') --Період призначення с 01.03.2024
                   AND EXISTS
                           (SELECT 1 --Виключаємо тих, хто не діє ні одного дня
                              FROM pd_accrual_period pdap
                             WHERE     pdap_pd = pd_id
                                   AND pdap.history_status = 'A')
                   AND EXISTS
                           (SELECT 1 --Перейшли в статус "Призначено" в період (-3 місяці, -2 місяці)
                              FROM pd_log, histsession
                             WHERE     pdl_pd = pd_id
                                   AND pdl_hs = hs_id
                                   AND hs_dt BETWEEN ADD_MONTHS (rc_month,
                                                                 -3)
                                                 AND   ADD_MONTHS (rc_month,
                                                                   -2)
                                                     - 1 / 86400
                                   AND pdl_st = 'P'
                                   AND pdl_message = CHR (38) || '17')
                   AND EXISTS
                           (SELECT 1 --Мають інші рішення до рішення, що аналізається
                              FROM pc_decision  prev_pd,
                                   pd_family    prev_f,
                                   pd_family    curr
                             WHERE     curr.pdf_pd = md.pd_id
                                   AND prev_f.pdf_sc = curr.pdf_sc
                                   AND prev_f.pdf_pd = prev_pd.pd_id
                                   AND prev_pd.pd_nst = 664
                                   AND prev_pd.pd_start_dt < md.pd_start_dt
                                   AND prev_f.history_status = 'A'
                                   AND curr.history_status = 'A')
                   AND (   EXISTS
                               (SELECT 1              --Мають право по коду 64
                                  FROM pd_right_log, uss_ndi.v_ndi_right_rule
                                 WHERE     prl_nrr = nrr_id
                                       AND prl_pd = pd_id
                                       AND nrr_code = '64'
                                       AND prl_result = 'T')
                        OR NOT EXISTS
                               (SELECT 1 --Або не мають права по жодному з 3 кодів (63/64/65)
                                  FROM pd_right_log, uss_ndi.v_ndi_right_rule
                                 WHERE     prl_nrr = nrr_id
                                       AND prl_pd = pd_id
                                       AND nrr_code IN ('63', '64', '65')
                                       AND prl_result = 'T'))
                   AND NOT EXISTS
                           (SELECT 1 --Подовжувалось -5/-6 місяців тому перерахунком 'S_VPO_131'
                              FROM pd_payment pdp, recalculates s
                             WHERE     pdp_pd = pd_id
                                   AND m.rc_month BETWEEN pdp_start_dt
                                                      AND pdp_stop_dt
                                   AND pdp.history_status = 'A'
                                   AND pdp_sum > 0   --Сума загалом не нульова
                                   AND pdp_rc = s.rc_id
                                   AND s.rc_tp = 'S_VPO_13_6')
                   AND NOT EXISTS
                           (SELECT 1
                              FROM pd_payment pdi, recalculates slrc
                             WHERE     pdi.pdp_pd = pd_id
                                   AND pdi.history_status = 'A'
                                   AND m.rc_month - 1 BETWEEN pdi.pdp_start_dt
                                                          AND pdi.pdp_stop_dt
                                   AND pdi.pdp_rc = slrc.rc_id
                                   AND slrc.rc_tp IN ('S_VPO_INC'));

        --«Особа непрацездатна», якщо вік особи до 18 років або 60 років і старше, або від ПФУ надійшла відповідь, що особа є Пенсіонер, або якщо наявна інформація про інвалідність за даними документу з Ід=201
        UPDATE tmp_s_vpo_133_list
           SET r_is_unable_work = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_133_list
           SET r_is_unable_work = 'T'
         WHERE /*EXISTS (SELECT 1 FROM uss_person.v_sc_pension WHERE scp_sc = r_sc AND scp_is_pension = 'T' AND r_chk_dt BETWEEN scp_begin_dt AND NVL(scp_end_dt, r_chk_dt))
           OR */
                  EXISTS
                      (SELECT 1
                         FROM src_pension_info
                        WHERE     spi_sc = r_sc
                              AND spi_month BETWEEN r_chk_month AND r_chk_dt
                              AND (   (    spi_ls_subject_tp IN
                                               ('PENS', 'DD', 'DPN')
                                       AND spi_sum_zag > 0)
                                   OR (    spi_ls_subject_tp_mil IN
                                               ('PENS', 'DD', 'DPN')
                                       AND spi_sum_zag_mil > 0)))
               OR EXISTS
                      (SELECT 1
                         FROM pc_decision,
                              ap_person         app,
                              ap_document       ap,
                              ap_document_attr  apda
                        WHERE     pd_id = r_pd
                              AND app_sc = r_sc
                              AND app.history_status = 'A'
                              AND ap.history_status = 'A'
                              AND apda.history_status = 'A'
                              AND app_ap = pd_ap
                              AND apd_app = app_id
                              AND apda_apd = apd_id
                              AND apd_ndt = 201
                              AND apda_nda = 349
                              AND apda_val_string IN ('1',
                                                      '2',
                                                      '3',
                                                      '4'))
               OR r_birth_dt > ADD_MONTHS (r_chk_dt, -216)
               OR r_birth_dt < ADD_MONTHS (r_chk_dt, -720);

        --«Особа зареєстрована як безробітня в ДЦЗ», якщо за даними ДЦЗ наявна інформація про те, що особа зареєстрована в ДЦЗ і відсутня ознака, що особа знята з обліку в ДЦЗ
        UPDATE tmp_s_vpo_133_list
           SET r_is_reg_in_dcz = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_133_list
           SET r_is_reg_in_dcz = 'T'
         WHERE     EXISTS
                       (SELECT 1
                          FROM me_dcz_result_rows
                         WHERE     mdsr_sc = r_sc
                               AND mdsr_d_start BETWEEN r_start_dt
                                                    AND r_chk_dt)
               AND (   NOT EXISTS
                           (SELECT 1
                              FROM me_dcz_result_rows
                             WHERE     mdsr_sc = r_sc
                                   AND mdsr_d_end BETWEEN r_start_dt
                                                      AND r_chk_dt)
                    OR (SELECT MAX (mdsr_d_start)
                          FROM me_dcz_result_rows
                         WHERE     mdsr_sc = r_sc
                               AND mdsr_d_start BETWEEN r_start_dt
                                                    AND r_chk_dt) >
                       (SELECT MAX (mdsr_d_end)
                          FROM me_dcz_result_rows
                         WHERE     mdsr_sc = r_sc
                               AND mdsr_d_end BETWEEN r_start_dt AND r_chk_dt));

        --«Особа працевлаштована», якщо за даними ПФУ в період з 1 березня по квітень 2024, наявна інформація, що особа перебуває в трудових відносинах
        UPDATE tmp_s_vpo_133_list
           SET r_is_work_by_pfu = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_133_list
           SET r_is_work_by_pfu = 'T'
         WHERE EXISTS
                   (SELECT 1
                      FROM src_pension_info
                     WHERE     spi_sc = r_sc
                           AND spi_month BETWEEN r_chk_month AND r_chk_dt
                           AND spi_oznak_prac IN ('T', '1')); --spi_rab IN ('T', '1')

        --«Особа вагітна», якщо наявний документ з ІД= 10196 «Лікарняний у зв'язку з вагітністю та пологами»
        UPDATE tmp_s_vpo_133_list
           SET r_is_pregnant = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_133_list
           SET r_is_pregnant = 'T'
         WHERE EXISTS
                   (SELECT 1
                      FROM pc_decision, ap_person app, ap_document ap
                     WHERE     pd_id = r_pd
                           AND app_sc = r_sc
                           AND app.history_status = 'A'
                           AND ap.history_status = 'A'
                           AND app_ap = pd_ap
                           AND apd_app = app_id
                           AND apd_ndt = 10196);

        --«Особа, яка відповідає умовам п.13-4», якщо стосовно особи наявно в документі з Ід=605 встановлено «так» в атрибуті з Ід=8218
        UPDATE tmp_s_vpo_133_list
           SET r_is_13_4 = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_133_list
           SET r_is_13_4 = 'T'
         WHERE EXISTS
                   (SELECT 1
                      FROM pc_decision,
                           ap_person         app,
                           ap_document       ap,
                           ap_document_attr  apda
                     WHERE     pd_id = r_pd
                           AND app_sc = r_sc
                           AND app.history_status = 'A'
                           AND ap.history_status = 'A'
                           AND apda.history_status = 'A'
                           AND app_ap = pd_ap
                           AND apd_app = app_id
                           AND apda_apd = apd_id
                           AND apd_ndt = 605
                           AND apda_nda = 8218
                           AND apda_val_string IN ('T'));

        --«Особа, яка здобуває освіту за денною формою навчання» якщо стосовно особи наявний документ з ІД= 98 «Довідка про навчання» і в атрибуті з Ід=690 зазначено «Денна»
        UPDATE tmp_s_vpo_133_list
           SET r_is_student = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_133_list
           SET r_is_student = 'T'
         WHERE EXISTS
                   (SELECT 1
                      FROM pc_decision,
                           ap_person         app,
                           ap_document       ap,
                           ap_document_attr  apda
                     WHERE     pd_id = r_pd
                           AND app_sc = r_sc
                           AND app.history_status = 'A'
                           AND ap.history_status = 'A'
                           AND apda.history_status = 'A'
                           AND app_ap = pd_ap
                           AND apd_app = app_id
                           AND apda_apd = apd_id
                           AND apd_ndt = 98
                           AND apda_nda = 690
                           AND apda_val_string IN ('D'));

        --«Особа, яка проходить військову службу», якщо стосовно особи наявний документ з ІД= 10246 «Довідка про участь в АТО, у  заходах безпеки і оборони, відсічі і стримування агресії рф»
        UPDATE tmp_s_vpo_133_list
           SET r_is_military = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_133_list
           SET r_is_military = 'T'
         WHERE EXISTS
                   (SELECT 1
                      FROM pc_decision, ap_person app, ap_document ap
                     WHERE     pd_id = r_pd
                           AND app_sc = r_sc
                           AND app.history_status = 'A'
                           AND ap.history_status = 'A'
                           AND app_ap = pd_ap
                           AND apd_app = app_id
                           AND apd_ndt = 10246);

        --Одна особа, в якої немає будь-яких інших ознак для подовження
        UPDATE tmp_s_vpo_133_list
           SET r_is_1_adult_wo_have_no_sign = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_133_list --помічаємо всіх як тих, кому потенційно можна подовжити
           SET r_is_1_adult_wo_have_no_sign = 'X'
         WHERE     r_is_unable_work = 'F'
               AND r_is_reg_in_dcz = 'F'
               AND r_is_work_by_pfu = 'F'
               AND r_is_pregnant = 'F'
               AND r_is_13_4 = 'F'
               AND r_is_student = 'F'
               AND r_is_military = 'F';

        UPDATE tmp_s_vpo_133_list ma --дозволяємо подовжити тим, хто заявник з потенційних, або якщо серед потенційних немає заявника, то найстаршу з потенційних
           SET r_is_1_adult_wo_have_no_sign = 'T'
         WHERE     r_is_1_adult_wo_have_no_sign = 'X'
               AND (   r_z_member = 'T'
                    OR (    0 =
                            (SELECT COUNT (*)
                               FROM tmp_s_vpo_133_list sl
                              WHERE     sl.r_is_1_adult_wo_have_no_sign = 'X'
                                    AND ma.r_pd = sl.r_pd
                                    AND sl.r_z_member = 'T')
                        AND r_birth_dt =
                            (SELECT MIN (sl.r_start_dt)
                               FROM tmp_s_vpo_133_list sl
                              WHERE     sl.r_is_1_adult_wo_have_no_sign = 'X'
                                    AND ma.r_pd = sl.r_pd)));

        UPDATE tmp_s_vpo_133_list ma
           SET r_is_1_adult_wo_have_no_sign = 'X' --помічаємо потенційною випадки, коли дата народження в потенційних виявилась однаковою. Тобто залишаємо лише 1го по цій ознаці
         WHERE     r_is_1_adult_wo_have_no_sign = 'T'
               AND 1 <
                   (SELECT COUNT (*)
                      FROM tmp_s_vpo_133_list sl
                     WHERE     sl.r_is_1_adult_wo_have_no_sign = 'T'
                           AND ma.r_pd = sl.r_pd)
               AND r_sc <>
                   (SELECT MIN (sl.r_sc)
                      FROM tmp_s_vpo_133_list sl
                     WHERE     sl.r_is_1_adult_wo_have_no_sign = 'T'
                           AND ma.r_pd = sl.r_pd);
    /*
          r_sc IN (SELECT xx.r_sc
                       FROM (SELECT sl.r_sc, 1 AS r_weight, sl.r_birth_dt FROM tmp_s_vpo_133_list sl WHERE sl.r_is_1_adult_wo_have_no_sign = 'X' AND r_z_member = 'T' AND ma.r_pd = sl.pd
                             UNION ALL
                             SELECT sl.r_sc, 2 AS r_weight, sl.r_birth_dt FROM tmp_s_vpo_133_list sl WHERE sl.r_is_1_adult_wo_have_no_sign = 'X' AND ma.r_pd = sl.pd
                             ORDER BY r_weight, r_birth_dt) xx
                       WHERE rownum = 1)
    */

    END;

    PROCEDURE Recalc_S_VPO_133 (p_rc_id   recalculates.rc_id%TYPE,
                                p_hs      histsession.hs_id%TYPE)
    IS
        l_hs            histsession.hs_id%TYPE;
        l_recalculate   recalculates%ROWTYPE;
    BEGIN
        --raise_application_error(-20009, 'В реалізації!');
        l_hs := p_hs;

        IF l_hs IS NULL
        THEN
            l_hs := TOOLS.GetHistSession;
        END IF;

        SELECT *
          INTO l_recalculate
          FROM recalculates
         WHERE rc_id = p_rc_id;

        --ikis_sysweb.ikis_debug_pipe.WriteMsg(l_recalculate.rc_org_list);
        TOOLS.org_list_to_work_ids (3, l_recalculate.rc_org_list);

        DELETE FROM tmp_work_set2
              WHERE 1 = 1;

        DELETE FROM tmp_work_set3
              WHERE 1 = 1;

        --Знаходимо всі рішення і осіб, які діють на дату початку місяція перерахунку
        INSERT INTO tmp_work_set2 (x_id1,
                                   x_id2,
                                   x_id3,
                                   x_id4,
                                   x_id5,
                                   x_dt1,
                                   x_dt2,
                                   x_dt3,
                                   x_dt4)
            SELECT pdf_pd,
                   pdf_id,
                   pdf_sc,
                   pd_pc,
                   pdp_id,
                   NVL (
                       (SELECT scb_dt
                          FROM uss_person.v_socialcard,
                               uss_person.v_sc_change,
                               uss_person.v_sc_birth
                         WHERE     sc_id = pdf_sc
                               AND scc_sc = sc_id
                               AND sc_scc = scc_id
                               AND scc_scb = scb_id
                               AND scc_scb > 0),
                       pdf_birth_dt),
                   rc_month,
                   pd_stop_dt,
                   SYSDATE
              FROM rc_candidates,
                   pd_family      mf,
                   pc_decision    md,
                   pc_account,
                   tmp_work_ids3  orgs,
                   appeal,
                   recalculates   m,
                   pd_payment     pdp
             WHERE     rcc_rc = rc_id
                   AND mf.history_status = 'A'
                   AND rcc_pd = pd_id
                   AND rcc_sc = pdf_sc
                   AND pdf_pd = pd_id
                   AND pd_pa = pa_id
                   AND pa_org = orgs.x_id
                   AND pd_ap = ap_id
                   AND rc_id = p_rc_id
                   --AND ap_reg_dt BETWEEN ADD_MONTHS(rc_month, -3) AND ADD_MONTHS(rc_month, -2) - 1 --призначені в період (-3 місяці, -2 місяці) від періоду розрахунку
                   AND pd_st = 'S'
                   AND pd_nst = 664
                   AND pd_stop_dt >= rc_month    --Діють і в місяці розрахунку
                   AND pd_start_dt >= TO_DATE ('01.03.2024', 'DD.MM.YYYY') --Період призначення с 01.03.2024
                   AND EXISTS
                           (SELECT 1 --Виключаємо тих, хто не діє ні одного дня
                              FROM pd_accrual_period pdap
                             WHERE     pdap_pd = pd_id
                                   AND pdap.history_status = 'A')
                   AND EXISTS
                           (SELECT 1 --Перейшли в статус "Призначено" в період (-3 місяці, -2 місяці)
                              FROM pd_log, histsession
                             WHERE     pdl_pd = pd_id
                                   AND pdl_hs = hs_id
                                   AND hs_dt BETWEEN ADD_MONTHS (rc_month,
                                                                 -3)
                                                 AND   ADD_MONTHS (rc_month,
                                                                   -2)
                                                     - 1 / 86400
                                   AND pdl_st = 'P'
                                   AND pdl_message = CHR (38) || '17')
                   AND EXISTS
                           (SELECT 1 --Мають інші рішення до рішення, що аналізається
                              FROM pc_decision  prev_pd,
                                   pd_family    prev_f,
                                   pd_family    curr
                             WHERE     curr.pdf_pd = md.pd_id
                                   AND prev_f.pdf_sc = curr.pdf_sc
                                   AND prev_f.pdf_pd = prev_pd.pd_id
                                   AND prev_pd.pd_nst = 664
                                   AND prev_pd.pd_start_dt < md.pd_start_dt
                                   AND prev_f.history_status = 'A'
                                   AND curr.history_status = 'A')
                   AND (   EXISTS
                               (SELECT 1              --Мають право по коду 64
                                  FROM pd_right_log, uss_ndi.v_ndi_right_rule
                                 WHERE     prl_nrr = nrr_id
                                       AND nrr_code = '64'
                                       AND prl_result = 'T')
                        OR NOT EXISTS
                               (SELECT 1 --Або не мають права по жодному з 3 кодів (63/64/65)
                                  FROM pd_right_log, uss_ndi.v_ndi_right_rule
                                 WHERE     prl_nrr = nrr_id
                                       AND nrr_code IN ('63', '64', '65')
                                       AND prl_result = 'T'))
                   AND NOT EXISTS
                           (SELECT 1 --Подовжувалось -5/-6 місяців тому перерахунком 'S_VPO_131'
                              FROM pd_payment pdp, recalculates s
                             WHERE     pdp_pd = pd_id
                                   AND m.rc_month BETWEEN pdp_start_dt
                                                      AND pdp_stop_dt
                                   AND pdp.history_status = 'A'
                                   AND pdp_sum > 0   --Сума загалом не нульова
                                   AND pdp_rc = s.rc_id
                                   AND s.rc_tp = 'S_VPO_13_6')
                   AND pdp_pd = pd_id
                   AND pdp.history_status = 'A'
                   AND rc_month BETWEEN pdp_start_dt AND pdp_stop_dt
                   AND NOT EXISTS
                           (SELECT 1
                              FROM pd_payment pdi, recalculates slrc
                             WHERE     pdi.pdp_pd = pd_id
                                   AND pdi.history_status = 'A'
                                   AND m.rc_month - 1 BETWEEN pdi.pdp_start_dt
                                                          AND pdi.pdp_stop_dt
                                   AND pdi.pdp_rc = slrc.rc_id
                                   AND slrc.rc_tp IN ('S_VPO_INC'));

        --  write_rc_log(p_rc_id, l_hs, 'F', NULL, l_recalculate.rc_st);

        write_message (
            1,
               'Знайдено '
            || SQL%ROWCOUNT
            || ' кандидатів, рішення по яким будуть виконані подовження або неподовження.');

        --Знаходимо осіб, по яким призначена сума допомоги - збергігається
        UPDATE tmp_work_set2
           SET x_string1 = '+'
         WHERE EXISTS
                   (SELECT 1
                      FROM rc_candidates, rc_candidate_attr
                     WHERE     rcca_rcc = rcc_id
                           AND rcc_rc = p_rc_id
                           AND rcc_pd = x_id1
                           AND rcc_sc = x_id3
                           AND rcca_val_string = 'T');

        --Видаляємо всі діючі записи, які діють на перше число місяця перерахунку і пізніше
        UPDATE pd_payment
           SET pdp_hs_del = l_hs, history_status = 'H'
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_set2
                         WHERE pdp_pd = x_id1)
               AND pdp_stop_dt > l_recalculate.rc_month
               AND history_status = 'A';

        --Вставляємо шматочок запису призначеного, який діяв на перше число місяця перерахнку, якщо він почався до першого числа місяця перерахнку.
        INSERT INTO pd_payment (pdp_id,
                                pdp_pd,
                                pdp_npt,
                                pdp_start_dt,
                                pdp_stop_dt,
                                pdp_sum,
                                history_status,
                                pdp_hs_ins,
                                pdp_src,
                                pdp_rc)
            SELECT 0,
                   pdp_pd,
                   pdp_npt,
                   pdp_start_dt,
                   l_recalculate.rc_month - 1,
                   pdp_sum,
                   'A',
                   l_hs,
                   'EMS',
                   pdp_rc
              FROM pd_payment
             WHERE     pdp_hs_del = l_hs
                   AND pdp_start_dt < l_recalculate.rc_month;

        --Формуємо нові записи призначеного на місяць перерахунку --LAST_DAY(l_recalculate.rc_month)
        INSERT INTO pd_payment (pdp_id,
                                pdp_pd,
                                pdp_npt,
                                pdp_start_dt,
                                pdp_stop_dt,
                                history_status,
                                pdp_hs_ins,
                                pdp_src,
                                pdp_rc)
            SELECT 0,
                   pdp_pd,
                   pdp_npt,
                   l_recalculate.rc_month,
                   (SELECT MAX (x_dt3)
                      FROM tmp_work_set2
                     WHERE x_id1 = pdp_pd),
                   'A',
                   l_hs,
                   'EMS',
                   p_rc_id
              FROM pd_payment
             WHERE     pdp_hs_del = l_hs
                   AND l_recalculate.rc_month BETWEEN pdp_start_dt
                                                  AND pdp_stop_dt;

          --відтворюємо записи деталей призначеного на запис призначеного на місяць перерахунку
          INSERT ALL
            WHEN x_old_pdp <> x_new_pdp
            THEN --Робимо копію всіх записів в запис призначеного, який діє на попередій період
                INTO pd_detail (pdd_id,
                                pdd_pdp,
                                pdd_row_order,
                                pdd_row_name,
                                pdd_key,
                                pdd_ndp,
                                pdd_start_dt,
                                pdd_stop_dt,
                                pdd_npt,
                                pdd_value)
                  VALUES (0,
                          x_old_pdp,
                          pdd_row_order,
                          pdd_row_name,
                          pdd_key,
                          pdd_ndp,
                          x_start_dt,
                          x_stop_dt,
                          pdd_npt,
                          pdd_value)
            WHEN pdd_ndp <> 137
            THEN                                   --Робимо копію всіх записів
                INTO pd_detail (pdd_id,
                                pdd_pdp,
                                pdd_row_order,
                                pdd_row_name,
                                pdd_key,
                                pdd_ndp,
                                pdd_start_dt,
                                pdd_stop_dt,
                                pdd_npt,
                                pdd_value)
                  VALUES (0,
                          x_new_pdp,
                          pdd_row_order,
                          pdd_row_name,
                          pdd_key,
                          pdd_ndp,
                          x_start_dt,
                          x_stop_dt,
                          pdd_npt,
                          x_sum)
            WHEN    (x_sum = 0 AND pdd_value > 0 AND pdd_ndp IN (290, 300))
                 OR pdd_ndp = 137
            THEN
                INTO pd_detail (pdd_id,
                                pdd_pdp,
                                pdd_row_order,
                                pdd_row_name,
                                pdd_key,
                                pdd_ndp,
                                pdd_start_dt,
                                pdd_stop_dt,
                                pdd_npt,
                                pdd_value)
                  VALUES (0,
                          x_new_pdp,
                          pdd_row_order,
                          pdd_row_name,
                          pdd_key,
                          137,
                          x_start_dt,
                          x_stop_dt,
                          pdd_npt,
                          pdd_value)
            SELECT pdd_pdp,
                   pdd_row_order,
                   pdd_row_name,
                   pdd_value,
                   pdd_key,
                   pdd_ndp,
                   l_recalculate.rc_month
                       AS x_start_dt,     /*LAST_DAY(l_recalculate.rc_month)*/
                   (SELECT MAX (x_dt3)
                      FROM tmp_work_set2
                     WHERE x_id1 = pdp_pd)
                       AS x_stop_dt,
                   pdd_npt,
                   CASE
                       WHEN     pdd_ndp IN (290, 300)
                            AND EXISTS
                                    (SELECT 1
                                       FROM tmp_work_set2
                                      WHERE     x_id1 = pdp_pd
                                            AND x_id2 = pdd_key
                                            AND x_string1 = '+')
                       THEN
                           CASE
                               WHEN pdd_value > 0
                               THEN
                                   pdd_value
                               WHEN EXISTS
                                        (SELECT 1
                                           FROM pd_detail sl
                                          WHERE     sl.pdd_ndp = 137
                                                AND sl.pdd_key = ma.pdd_key
                                                AND sl.pdd_value > 0)
                               THEN
                                   (SELECT MIN (sl.pdd_value)
                                      FROM pd_detail sl
                                     WHERE     sl.pdd_ndp = 137
                                           AND sl.pdd_key = ma.pdd_key
                                           AND sl.pdd_value > 0)
                               ELSE
                                   0
                           END
                       ELSE
                           0
                   END
                       AS x_sum, --сума для 290/300 змінюється в залежності від наявності права
                   (SELECT MAX (pdp_id)
                      FROM pd_payment np
                     WHERE np.pdp_pd = dp.pdp_pd AND np.pdp_hs_ins = l_hs)
                       AS x_new_pdp,
                   (SELECT MIN (pdp_id)
                      FROM pd_payment np
                     WHERE np.pdp_pd = dp.pdp_pd AND np.pdp_hs_ins = l_hs)
                       AS x_old_pdp
              FROM pd_payment dp, pd_detail ma
             WHERE     pdp_hs_del = l_hs
                   AND l_recalculate.rc_month BETWEEN pdp_start_dt
                                                  AND pdp_stop_dt
                   AND pdd_pdp = pdp_id;

        UPDATE pd_payment
           SET pdp_sum =
                   NVL ( (SELECT SUM (pdd_value)
                            FROM pd_detail
                           WHERE pdd_pdp = pdp_id AND pdd_ndp IN (290, 300)),
                        0)
         WHERE pdp_hs_ins = l_hs AND pdp_start_dt = l_recalculate.rc_month;

        --Переводимо реєстраційні записи нарахуваннь в "редагується" та "діюче по послугам" - аби можна було виконувати нарахування
        UPDATE accrual ac
           SET ac_st = CASE ac_st WHEN 'R' THEN 'RV' WHEN 'RP' THEN 'E' END
         WHERE     ac_st IN ('R', 'RP')
               AND EXISTS
                       (SELECT 1
                          FROM tmp_work_set2
                         WHERE ac_pc = x_id4)
               AND EXISTS
                       (SELECT 1
                          FROM billing_period,
                               pc_decision,
                               pc_account,
                               tmp_work_set2
                         WHERE     x_id4 = ac_pc
                               AND x_id1 = pd_id
                               AND pd_pa = pa_id
                               AND bp_month = ac_month
                               AND bp_org = pa_org
                               AND bp_tp = 'PR'
                               AND bp_class = 'VPO'
                               AND bp_st = 'R')
               AND (SELECT SUM (pdp_sum)
                      FROM pd_payment pdp, tmp_work_set2
                     WHERE     pdp.history_status = 'A'
                           AND x_id1 = pdp_pd
                           AND x_id4 = ac_pc
                           AND pdp_stop_dt = l_recalculate.rc_month - 1) <>
                   (SELECT SUM (pdp_sum)
                      FROM pd_payment pdp, tmp_work_set2
                     WHERE     pdp.history_status = 'A'
                           AND x_id1 = pdp_pd
                           AND x_id4 = ac_pc
                           AND pdp_start_dt = l_recalculate.rc_month);

        DELETE FROM pd_features
              WHERE     pde_nft BETWEEN 129 AND 136
                    AND EXISTS
                            (SELECT 1
                               FROM tmp_work_set2
                              WHERE x_id1 = pde_pd);

        INSERT INTO pd_features (pde_id,
                                 pde_pd,
                                 pde_val_string,
                                 pde_pdf,
                                 pde_nft)
            SELECT 0,
                   x_id1,
                   'T',
                   x_id2,
                   CASE rcca_nda
                       WHEN 8463 THEN 129
                       WHEN 8464 THEN 130
                       WHEN 8465 THEN 131
                       WHEN 8466 THEN 132
                       WHEN 8467 THEN 133
                       WHEN 8468 THEN 134
                       WHEN 8469 THEN 135
                       WHEN 8470 THEN 136
                   END
              FROM tmp_work_set2, rc_candidates, rc_candidate_attr
             WHERE     rcc_rc = p_rc_id
                   AND rcc_pd = x_id1
                   AND rcc_sc = x_id3
                   AND rcca_rcc = rcc_id
                   AND rcca_val_string = 'T';

        --Пишемо протокол в змінені рішення
        FOR xx IN (SELECT DISTINCT pd_id,
                                   pd_st,
                                   pd_stop_dt,
                                   x_dt2
                     FROM tmp_work_set2 z1, pc_decision
                    WHERE x_id1 = pd_id AND x_string1 = '+')
        LOOP
            API$PC_DECISION.write_pd_log (
                xx.pd_id,
                l_hs,
                xx.pd_st,
                CHR (38) || '290#' || TO_CHAR (xx.x_dt2, 'DD.MM.YYYY'),
                xx.pd_st);
        END LOOP;
    END;

    PROCEDURE Recalc_PA_DN_18 (p_rc_id   recalculates.rc_id%TYPE,
                               p_hs      histsession.hs_id%TYPE)
    IS
        l_hs            histsession.hs_id%TYPE;
        l_recalculate   recalculates%ROWTYPE;
    BEGIN
        --raise_application_error(-20009, 'В реалізації!');
        l_hs := p_hs;

        IF l_hs IS NULL
        THEN
            l_hs := TOOLS.GetHistSession;
        END IF;

        SELECT *
          INTO l_recalculate
          FROM recalculates
         WHERE rc_id = p_rc_id;

        --ikis_sysweb.ikis_debug_pipe.WriteMsg(l_recalculate.rc_org_list);
        TOOLS.org_list_to_work_ids (3, l_recalculate.rc_org_list);

        DELETE FROM tmp_work_set2
              WHERE 1 = 1;

        DELETE FROM tmp_work_set3
              WHERE 1 = 1;

        --Знаходимо записи історії відрахування по держутриманням, яким необхідно змінити відсоток відрахування
        INSERT INTO tmp_work_set2 (x_id1,
                                   x_id2,
                                   x_dt1,
                                   x_dt2,
                                   x_dt3,
                                   x_id3)
            WITH
                params
                AS
                    (SELECT rc_id
                                AS x_rc,
                            l_hs
                                AS x_hs,
                            rc_month
                                AS x_period,
                            ADD_MONTHS (rc_month, -217)
                                AS x_birth_lock_start,
                            ADD_MONTHS (rc_month, -216) - 1
                                AS x_birth_lock_stop,
                            ADD_MONTHS (rc_month, -216)
                                AS x_birth_lock
                       FROM uss_esr.recalculates
                      WHERE rc_id = p_rc_id),
                sc_birth
                AS
                    (SELECT q_sc,
                            q_sc_birth_dt,
                            ADD_MONTHS (TRUNC (q_sc_birth_dt, 'MM'), 217)    AS q_change_dt --Зміна відсотку виконується з першого числа місяця, що слідує за місяцем настання дати народження
                       FROM (SELECT rcc_sc                           AS q_sc,
                                    (SELECT scb_dt
                                       FROM uss_person.v_sc_birth,
                                            uss_person.v_socialcard,
                                            uss_person.v_sc_change
                                      WHERE     sc_id = rcc_sc
                                            AND sc_scc = scc_id
                                            AND scc_scb = scb_id)    AS q_sc_birth_dt
                               FROM rc_candidates, params
                              WHERE rcc_rc = x_rc))
            SELECT dnd_id,
                   dnd_dn,
                   q_change_dt     AS x_change_dt,
                   dnd_start_dt,
                   dnd_stop_dt,
                   x_hs
              FROM rc_candidates,
                   uss_esr.personalcase  pc,
                   uss_esr.pc_state_alimony,
                   params,
                   uss_esr.deduction,
                   uss_esr.dn_detail     dnd,
                   sc_birth
             WHERE     rcc_rc = x_rc
                   AND rcc_pc = pc_id
                   AND rcc_sc = ps_sc
                   AND rcc_sc = q_sc
                   AND ps_pc = pc_id
                   AND ps_st = 'R'                       --діюче держутримання
                   AND dn_pc = pc_id
                   AND dn_ps = ps_id
                   AND dn_st = 'R'                        --діюче відрахування
                   AND dnd_dn = dn_id
                   AND dnd.history_status = 'A'
                   AND dnd_value <= 50 --відсоток відрахування менше-рівний за 50% (для дітей-сиріт в т.ч.)
                   AND dnd_tp = 'PD'
                   AND (q_change_dt <= dnd_stop_dt OR dnd_stop_dt IS NULL) --1 число розрахункового періода діє в періоді дії шматка історії відрахування з непустим відсотком відрахуванням
                   AND q_sc_birth_dt < x_birth_lock --Дата народження особи менша за дату розрахункового періоду мінус 18 років
                   AND 1 =
                       (SELECT COUNT (*)
                          FROM uss_esr.deduction sdn, uss_esr.dn_detail sdnd
                         WHERE     sdn.dn_pc = pc_id
                               AND sdn.dn_ps = ps_id
                               AND sdn.dn_st = 'R'        --діюче відрахування
                               AND sdnd.dnd_dn = sdn.dn_id
                               AND sdnd.history_status = 'A'
                               AND sdnd.dnd_value <= 50 --відсоток відрахування менше-рівний за 50% (для дітей-сиріт в т.ч.)
                               AND sdnd.dnd_tp = 'PD'
                               AND x_period >= sdnd.dnd_start_dt --діє на 1 число розрахункового періода
                               AND (   x_period <= sdnd.dnd_stop_dt
                                    OR sdnd.dnd_stop_dt IS NULL)
                               AND NOT EXISTS
                                       (SELECT 1 --немає рішень, які на період з місяця розрахунку подовжені по перерахунку S_EXT_VS
                                          FROM uss_esr.pc_decision,
                                               uss_esr.pd_accrual_period pdap,
                                               uss_esr.pd_payment  pdp,
                                               uss_esr.recalculates
                                         WHERE     pd_pa = sdn.dn_pa
                                               AND pd_st = 'S'
                                               AND pd_nst = 248
                                               AND pdap_pd = pd_id
                                               AND pdap.history_status = 'A'
                                               --AND x_period >= pdap_start_dt
                                               --AND (x_period <= pdap_stop_dt OR pdap_stop_dt IS NULL)
                                               AND pdp_pd = pd_id
                                               AND pdp.history_status = 'A'
                                               --AND (x_period <= pdp_stop_dt OR pdp_stop_dt IS NULL)
                                               AND pdp_rc = rc_id
                                               AND rc_tp = 'S_EXT_VS'))
                   AND pc.com_org IN (SELECT orgs.x_id
                                        FROM uss_esr.tmp_work_ids3 orgs);

        --Визначаємо, що будемо робити з записами історії відрахування
        UPDATE uss_esr.tmp_work_set2
           SET x_string1 =
                   CASE
                       WHEN     x_dt1 > x_dt2
                            AND (x_dt3 >= x_dt1 OR x_dt3 IS NULL) --дата початку розрахункового періоду розділяє період дії шматка історіх відрахування
                       THEN
                           'DIV' --і потрібно зробити з нього 2 записи - один з старим відсотком, а інший - з новим відостком - 75%.
                       ELSE
                           'SAVE' --Період шматка відрахування зберігається - кожному такому прописується новий відсоток - 75%
                   END
         WHERE x_dt1 > x_dt2 AND x_dt3 >= x_dt1 OR x_dt3 IS NULL;

        --Всі записи історії відрахування, які будуть змінюватись - переводимо в історичні
        UPDATE uss_esr.dn_detail
           SET history_status = 'H', dnd_hs_del = l_hs
         WHERE EXISTS
                   (SELECT 1
                      FROM uss_esr.tmp_work_set2
                     WHERE x_id1 = dnd_id);

        --Запис з старим відсотком відрахування, якщо дата розрахункового періоду виявилась в середині періоду дії старого шматка історії відрахування
        INSERT INTO uss_esr.dn_detail (dnd_id,
                                       dnd_dn,
                                       dnd_start_dt,
                                       dnd_stop_dt,
                                       dnd_tp,
                                       dnd_value,
                                       history_status,
                                       dnd_psc,
                                       dnd_value_prefix,
                                       dnd_dppa,
                                       dnd_hs_ins,
                                       dnd_hs_del,
                                       dnd_nl_tp,
                                       dnd_nl_value,
                                       dnd_nl_value_prefix)
            SELECT 0,
                   dnd_dn,
                   dnd_start_dt,
                   x_dt1 - 1,
                   dnd_tp,
                   dnd_value,
                   'A',
                   dnd_psc,
                   dnd_value_prefix,
                   dnd_dppa,
                   x_id3,
                   NULL,
                   dnd_nl_tp,
                   dnd_nl_value,
                   dnd_nl_value_prefix
              FROM uss_esr.dn_detail, uss_esr.tmp_work_set2
             WHERE x_id1 = dnd_id AND x_string1 = 'DIV';

        --Запис з новим відсотком відрахування, якщо дата розрахункового періоду виявилась в середині періоду дії старого шматка історії відрахування
        INSERT INTO uss_esr.dn_detail (dnd_id,
                                       dnd_dn,
                                       dnd_start_dt,
                                       dnd_stop_dt,
                                       dnd_tp,
                                       dnd_value,
                                       history_status,
                                       dnd_psc,
                                       dnd_value_prefix,
                                       dnd_dppa,
                                       dnd_hs_ins,
                                       dnd_hs_del,
                                       dnd_nl_tp,
                                       dnd_nl_value,
                                       dnd_nl_value_prefix)
            SELECT 0,
                   dnd_dn,
                   x_dt1,
                   dnd_stop_dt,
                   dnd_tp,
                   CASE
                       WHEN dnd_value <= 50 THEN 75
                       WHEN dnd_value IS NULL THEN NULL
                       ELSE dnd_value
                   END,
                   'A',
                   dnd_psc,
                   dnd_value_prefix,
                   dnd_dppa,
                   x_id3,
                   NULL,
                   dnd_nl_tp,
                   dnd_nl_value,
                   dnd_nl_value_prefix
              FROM uss_esr.dn_detail, uss_esr.tmp_work_set2
             WHERE x_id1 = dnd_id AND x_string1 = 'DIV';

        --Записи з новим відсотком відрахування, якщо період дії шматка історії відрахування знаходиться поівністю після дати розрахункового періоду
        INSERT INTO uss_esr.dn_detail (dnd_id,
                                       dnd_dn,
                                       dnd_start_dt,
                                       dnd_stop_dt,
                                       dnd_tp,
                                       dnd_value,
                                       history_status,
                                       dnd_psc,
                                       dnd_value_prefix,
                                       dnd_dppa,
                                       dnd_hs_ins,
                                       dnd_hs_del,
                                       dnd_nl_tp,
                                       dnd_nl_value,
                                       dnd_nl_value_prefix)
            SELECT 0,
                   dnd_dn,
                   dnd_start_dt,
                   dnd_stop_dt,
                   dnd_tp,
                   CASE
                       WHEN dnd_value <= 50 THEN 75
                       WHEN dnd_value IS NULL THEN NULL
                       ELSE dnd_value
                   END,
                   'A',
                   dnd_psc,
                   dnd_value_prefix,
                   dnd_dppa,
                   x_id3,
                   NULL,
                   dnd_nl_tp,
                   dnd_nl_value,
                   dnd_nl_value_prefix
              FROM uss_esr.dn_detail, uss_esr.tmp_work_set2
             WHERE x_id1 = dnd_id AND x_string1 = 'SAVE';

        --Пишемо протокол в відрахування
        FOR xx IN (SELECT dn_id, dn_st
                     FROM deduction
                    WHERE EXISTS
                              (SELECT 1
                                 FROM tmp_work_set2
                                WHERE x_id2 = dn_id))
        LOOP
            API$DEDUCTION.write_dn_log (
                xx.dn_id,
                l_hs,
                xx.dn_st,
                   CHR (38)
                || '293#'
                || TO_CHAR (l_recalculate.rc_month, 'DD.MM.YYYY'),
                xx.dn_st);
        END LOOP;
    END;

    PROCEDURE Prepare_S_VPO_13_6 (p_rc_id recalculates.rc_id%TYPE)
    IS
        l_recalculate   recalculates%ROWTYPE;
    BEGIN
        --  raise_application_error(-20000, 'В розробці!');
        SELECT *
          INTO l_recalculate
          FROM recalculates
         WHERE rc_id = p_rc_id;

        IF l_recalculate.rc_month < TO_DATE ('01.09.2024', 'DD.MM.YYYY')
        THEN
            raise_application_error (
                -20000,
                'Даний перерахунок можна робити тільки починаючи з 09.2024!');
        END IF;

        --  raise_application_error(-20009, 'В реалізації!');
        INSERT INTO tmp_s_vpo_13_6_list (r_pd,
                                         r_pdf,
                                         r_sc,
                                         r_pc,
                                         r_start_dt,
                                         r_stop_dt,
                                         r_chk_dt,
                                         r_chk_month,
                                         r_birth_dt)
            SELECT pdf_pd,
                   pdf_id,
                   pdf_sc,
                   pd_pc,
                   ADD_MONTHS (rc_month, -3),
                   ADD_MONTHS (rc_month, -2) - 1,
                   rc_month - 1,
                   ADD_MONTHS (rc_month, -1),
                   NVL (
                       (SELECT scb_dt
                          FROM uss_person.v_socialcard,
                               uss_person.v_sc_change,
                               uss_person.v_sc_birth
                         WHERE     sc_id = pdf_sc
                               AND scc_sc = sc_id
                               AND sc_scc = scc_id
                               AND scc_scb = scb_id
                               AND scc_scb > 0),
                       pdf_birth_dt)
              FROM pd_family      mf,
                   pc_decision    md,
                   pc_account,
                   tmp_work_ids3  orgs,
                   appeal,
                   recalculates   m
             WHERE     pdf_pd = pd_id
                   AND mf.history_status = 'A'
                   AND pd_pa = pa_id
                   AND pa_org = orgs.x_id
                   AND pd_ap = ap_id
                   AND rc_id = p_rc_id
                   AND pd_st = 'S'
                   AND pd_nst = 664
                   AND mf.history_status = 'A'
                   --AND pd_stop_dt = rc_month - 1 --Діють до останнього дня місяця, що передує місяцю розрахунку
                   AND (SELECT MAX (pdap_stop_dt)
                          FROM pd_accrual_period pdap
                         WHERE pdap_pd = pd_id AND pdap.history_status = 'A') =
                       rc_month - 1 --Діють до останнього дня місяця, що передує місяцю розрахунку
                   AND NOT EXISTS
                           (SELECT 1
                              FROM pc_decision sd, pd_accrual_period pdap
                             WHERE     sd.pd_pc = md.pd_pc
                                   AND sd.pd_nst = 664
                                   AND sd.pd_st = 'S'
                                   AND pdap_pd = sd.pd_id
                                   AND pdap.history_status = 'A'
                                   AND pdap_stop_dt > md.pd_stop_dt) --На справі відсутні інші рішення по ВПО які діють в періоди з розрахункового періоду включано
                   ---пункт1
                   AND (   EXISTS
                               (SELECT 1 --Подовжувалось -5/-6 місяців тому перерахунком 'S_VPO_131'
                                  FROM pd_payment pdp, recalculates s
                                 WHERE     pdp_pd = pd_id
                                       AND m.rc_month - 1 BETWEEN pdp_start_dt
                                                              AND pdp_stop_dt
                                       AND pdp.history_status = 'A'
                                       AND pdp_sum > 0 --Сума загалом не нульова
                                       AND pdp_rc = s.rc_id
                                       AND s.rc_tp = 'S_VPO_131'
                                       AND s.rc_month IN
                                               (ADD_MONTHS (m.rc_month, -5),
                                                ADD_MONTHS (m.rc_month, -6)))
                        ---пункт2
                        OR (    EXISTS
                                    (SELECT 1 --Наявне інше рішення, яке діяло в місяці , що визначається як «розрахунковий період» «мінус» сім
                                       FROM pc_decision        sd,
                                            pd_accrual_period  pdap
                                      WHERE     sd.pd_pc = md.pd_pc
                                            AND sd.pd_nst = 664
                                            AND sd.pd_st IN ('S', 'PS')
                                            AND pdap_pd = sd.pd_id
                                            AND pdap.history_status = 'A'
                                            AND sd.pd_id <> md.pd_id
                                            AND ADD_MONTHS (m.rc_month, -7) BETWEEN pdap_start_dt
                                                                                AND pdap_stop_dt)
                            AND EXISTS
                                    (SELECT 1 -- наявне це або інше рішення, яке діяло в місяці, що визначається як «розрахунковий період» «мінус» шість
                                       FROM pc_decision        sd,
                                            pd_accrual_period  pdap
                                      WHERE     sd.pd_pc = md.pd_pc
                                            AND sd.pd_nst = 664
                                            AND sd.pd_st IN ('S', 'PS')
                                            AND pdap_pd = sd.pd_id
                                            AND pdap.history_status = 'A'
                                            AND ADD_MONTHS (m.rc_month, -6) BETWEEN pdap_start_dt
                                                                                AND pdap_stop_dt)
                            AND EXISTS
                                    (SELECT 1 --Подовжувалось перерахунком 'S_VPO_133'
                                       FROM pd_payment pdp, recalculates s
                                      WHERE     pdp_pd = pd_id
                                            AND m.rc_month - 1 BETWEEN pdp_start_dt
                                                                   AND pdp_stop_dt
                                            AND pdp.history_status = 'A'
                                            AND pdp_sum > 0 --Сума загалом не нульова
                                            AND pdp_rc = s.rc_id
                                            AND s.rc_tp = 'S_VPO_133'))
                        ---пункт3
                        OR (    EXISTS
                                    (SELECT 1 --Наявне інше рішення, яке діяло в місяці , що визначається як «розрахунковий період» «мінус» сім
                                       FROM pc_decision        sd,
                                            pd_accrual_period  pdap
                                      WHERE     sd.pd_pc = md.pd_pc
                                            AND sd.pd_nst = 664
                                            AND sd.pd_st IN ('S', 'PS')
                                            AND pdap_pd = sd.pd_id
                                            AND pdap.history_status = 'A'
                                            --AND sd.pd_id <> md.pd_id
                                            AND ADD_MONTHS (m.rc_month, -7) BETWEEN pdap_start_dt
                                                                                AND pdap_stop_dt)
                            AND EXISTS
                                    (SELECT 1 -- наявне це або інше рішення, яке діяло в місяці, що визначається як «розрахунковий період» «мінус» шість
                                       FROM pc_decision        sd,
                                            pd_accrual_period  pdap
                                      WHERE     sd.pd_pc = md.pd_pc
                                            AND sd.pd_nst = 664
                                            AND sd.pd_st IN ('S', 'PS')
                                            AND pdap_pd = sd.pd_id
                                            AND pdap.history_status = 'A'
                                            AND ADD_MONTHS (m.rc_month, -6) BETWEEN pdap_start_dt
                                                                                AND pdap_stop_dt)
                            AND NOT EXISTS
                                    (SELECT 1 --Не подовжувалось перерахунком 'S_VPO_131' або 'S_VPO_133'
                                       FROM pd_payment pdp, recalculates s
                                      WHERE     pdp_pd = pd_id
                                            AND m.rc_month - 1 BETWEEN pdp_start_dt
                                                                   AND pdp_stop_dt
                                            AND pdp.history_status = 'A'
                                            AND pdp_sum > 0 --Сума загалом не нульова
                                            AND pdp_rc = s.rc_id
                                            AND s.rc_tp IN
                                                    ('S_VPO_131', 'S_VPO_133'))));

        --Подовження допомоги (встановлення нового періоду дії рішення) виконується тим, кому допомога була призначена станом на «розрахунковий період» мінус один день
        UPDATE tmp_s_vpo_13_6_list
           SET r_payed_before = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_13_6_list
           SET r_payed_before = 'T'
         WHERE EXISTS
                   (SELECT 1
                      FROM pd_payment pdp, pd_detail
                     WHERE     pdp_pd = r_pd
                           AND pdp.history_status = 'A'
                           AND r_chk_dt BETWEEN pdp_start_dt AND pdp_stop_dt
                           AND pdd_pdp = pdp_id
                           AND pdd_ndp IN (290, 300)
                           AND pdd_key = r_pdf
                           AND pdd_value > 0);

        --наявний документ з Ід=10196 «Лікарняний у зв'язку з вагітністю та пологами» і в рішенні-кандидаті встановлено «так» в правилі щодо 13-4 (nrr_code=65)
        --  і не встановлено в правилі щодо 13-2 (nrr_code=64)
        --АБО яких наявний документ з Ід=10196 "Лікарняний у зв'язку з вагітністю та пологами" і в рішенні кандидаті не встановлено «так» ні в  правилі щодо 13-2 (nrr_code=64),
        --  ні в правилі щодо 13-4 (nrr_code=65)
        UPDATE tmp_s_vpo_13_6_list
           SET r_not_cb_sick_card = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_13_6_list
           SET r_not_cb_sick_card = 'T'
         WHERE NOT EXISTS
                   (SELECT 1
                      FROM pc_decision, ap_person app, ap_document ap
                     WHERE     pd_id = r_pd
                           AND app_sc = r_sc
                           AND app.history_status = 'A'
                           AND ap.history_status = 'A'
                           AND app_ap = pd_ap
                           AND apd_app = app_id
                           AND apd_ndt = 10196
                           AND (   (    EXISTS
                                            (SELECT 1
                                               FROM pd_right_log,
                                                    uss_ndi.v_ndi_right_rule
                                              WHERE     prl_nrr = nrr_id
                                                    AND prl_pd = pd_id
                                                    AND nrr_code = '65'
                                                    AND prl_result = 'T')
                                    AND NOT EXISTS
                                            (SELECT 1
                                               FROM pd_right_log,
                                                    uss_ndi.v_ndi_right_rule
                                              WHERE     prl_nrr = nrr_id
                                                    AND prl_pd = pd_id
                                                    AND nrr_code = '64'
                                                    AND prl_result = 'T'))
                                OR (    NOT EXISTS
                                            (SELECT 1
                                               FROM pd_right_log,
                                                    uss_ndi.v_ndi_right_rule
                                              WHERE     prl_nrr = nrr_id
                                                    AND prl_pd = pd_id
                                                    AND nrr_code = '65'
                                                    AND prl_result = 'T')
                                    AND NOT EXISTS
                                            (SELECT 1
                                               FROM pd_right_log,
                                                    uss_ndi.v_ndi_right_rule
                                              WHERE     prl_nrr = nrr_id
                                                    AND prl_pd = pd_id
                                                    AND nrr_code = '64'
                                                    AND prl_result = 'T'))));
    END;

    PROCEDURE Recalc_S_VPO_13_6 (p_rc_id   recalculates.rc_id%TYPE,
                                 p_hs      histsession.hs_id%TYPE)
    IS
        l_hs            histsession.hs_id%TYPE;
        l_recalculate   recalculates%ROWTYPE;
    BEGIN
        --raise_application_error(-20009, 'В реалізації!');
        l_hs := p_hs;

        IF l_hs IS NULL
        THEN
            l_hs := TOOLS.GetHistSession;
        END IF;

        SELECT *
          INTO l_recalculate
          FROM recalculates
         WHERE rc_id = p_rc_id;

        --ikis_sysweb.ikis_debug_pipe.WriteMsg(l_recalculate.rc_org_list);
        TOOLS.org_list_to_work_ids (3, l_recalculate.rc_org_list);

        DELETE FROM tmp_work_set2
              WHERE 1 = 1;

        DELETE FROM tmp_work_set3
              WHERE 1 = 1;

        --Знаходимо всі рішення і осіб, які діють на дату початку місяція перерахунку
        INSERT INTO tmp_work_set2 (x_id1,
                                   x_id2,
                                   x_id3,
                                   x_id4,
                                   x_id5,
                                   x_dt1,
                                   x_dt2,
                                   x_dt3,
                                   x_dt4)
            SELECT pdf_pd,
                   pdf_id,
                   pdf_sc,
                   pd_pc,
                   pdp_id,
                   NVL (
                       (SELECT scb_dt
                          FROM uss_person.v_socialcard,
                               uss_person.v_sc_change,
                               uss_person.v_sc_birth
                         WHERE     sc_id = pdf_sc
                               AND scc_sc = sc_id
                               AND sc_scc = scc_id
                               AND scc_scb = scb_id
                               AND scc_scb > 0),
                       pdf_birth_dt),
                   rc_month,
                   pd_stop_dt,
                   SYSDATE
              FROM rc_candidates,
                   pd_family      mf,
                   pc_decision    md,
                   pc_account,
                   tmp_work_ids3  orgs,
                   appeal,
                   recalculates   m,
                   pd_payment     pdpm
             WHERE     rcc_rc = rc_id
                   AND mf.history_status = 'A'
                   AND rcc_pd = pd_id
                   AND rcc_sc = pdf_sc
                   AND pdf_pd = pd_id
                   AND pd_pa = pa_id
                   AND pa_org = orgs.x_id
                   AND pd_ap = ap_id
                   AND rc_id = p_rc_id
                   --AND ap_reg_dt BETWEEN ADD_MONTHS(rc_month, -3) AND ADD_MONTHS(rc_month, -2) - 1 --призначені в період (-3 місяці, -2 місяці) від періоду розрахунку
                   AND pd_st = 'S'
                   AND pd_nst = 664
                   AND pdp_pd = pd_id
                   AND pdpm.history_status = 'A'
                   AND rc_month - 1 BETWEEN pdp_start_dt AND pdp_stop_dt
                   --AND pd_stop_dt = rc_month - 1 --Діють до останнього дня місяця, що передує місяцю розрахунку
                   AND (SELECT MAX (pdap_stop_dt)
                          FROM pd_accrual_period pdap
                         WHERE pdap_pd = pd_id AND pdap.history_status = 'A') =
                       rc_month - 1 --Діють до останнього дня місяця, що передує місяцю розрахунку
                   AND NOT EXISTS
                           (SELECT 1
                              FROM pc_decision sd, pd_accrual_period pdap
                             WHERE     sd.pd_pc = md.pd_pc
                                   AND sd.pd_nst = 664
                                   AND sd.pd_st = 'S'
                                   AND pdap_pd = sd.pd_id
                                   AND pdap.history_status = 'A'
                                   AND pdap_stop_dt > md.pd_stop_dt) --На справі відсутні інші рішення по ВПО які діють в періоди з розрахункового періоду включано
                   ---пункт1
                   AND (   EXISTS
                               (SELECT 1 --Подовжувалось -5/-6 місяців тому перерахунком 'S_VPO_131'
                                  FROM pd_payment pdp, recalculates s
                                 WHERE     pdp.pdp_pd = pd_id
                                       AND m.rc_month - 1 BETWEEN pdp_start_dt
                                                              AND pdp_stop_dt
                                       AND pdp.history_status = 'A'
                                       AND pdp.pdp_sum > 0 --Сума загалом не нульова
                                       AND pdp.pdp_rc = s.rc_id
                                       AND s.rc_tp = 'S_VPO_131'
                                       AND s.rc_month IN
                                               (ADD_MONTHS (m.rc_month, -5),
                                                ADD_MONTHS (m.rc_month, -6)))
                        ---пункт23
                        OR (    EXISTS
                                    (SELECT 1 --Наявне інше рішення, яке діяло в місяці , що визначається як «розрахунковий період» «мінус» сім
                                       FROM pc_decision        sd,
                                            pd_accrual_period  pdap
                                      WHERE     sd.pd_pc = md.pd_pc
                                            AND sd.pd_nst = 664
                                            AND sd.pd_st IN ('S', 'PS')
                                            AND pdap_pd = sd.pd_id
                                            AND pdap.history_status = 'A'
                                            AND sd.pd_id <> md.pd_id
                                            AND ADD_MONTHS (m.rc_month, -7) BETWEEN pdap_start_dt
                                                                                AND pdap_stop_dt)
                            AND EXISTS
                                    (SELECT 1 -- наявне це або інше рішення, яке діяло в місяці, що визначається як «розрахунковий період» «мінус» шість
                                       FROM pc_decision        sd,
                                            pd_accrual_period  pdap
                                      WHERE     sd.pd_pc = md.pd_pc
                                            AND sd.pd_nst = 664
                                            AND sd.pd_st IN ('S', 'PS')
                                            AND pdap_pd = sd.pd_id
                                            AND pdap.history_status = 'A'
                                            AND ADD_MONTHS (m.rc_month, -6) BETWEEN pdap_start_dt
                                                                                AND pdap_stop_dt)
                            AND EXISTS
                                    (SELECT 1 --Подовжувалось перерахунком 'S_VPO_133'
                                       FROM pd_payment pdp, recalculates s
                                      WHERE     pdp.pdp_pd = pd_id
                                            AND m.rc_month - 1 BETWEEN pdp_start_dt
                                                                   AND pdp_stop_dt
                                            AND pdp.history_status = 'A'
                                            AND pdp.pdp_sum > 0 --Сума загалом не нульова
                                            AND pdp.pdp_rc = s.rc_id
                                            AND s.rc_tp = 'S_VPO_133'))
                        ---пункт3
                        OR (    EXISTS
                                    (SELECT 1 --Наявне інше рішення, яке діяло в місяці , що визначається як «розрахунковий період» «мінус» сім
                                       FROM pc_decision        sd,
                                            pd_accrual_period  pdap
                                      WHERE     sd.pd_pc = md.pd_pc
                                            AND sd.pd_nst = 664
                                            AND sd.pd_st IN ('S', 'PS')
                                            AND pdap_pd = sd.pd_id
                                            AND pdap.history_status = 'A'
                                            --AND sd.pd_id <> md.pd_id
                                            AND ADD_MONTHS (m.rc_month, -7) BETWEEN pdap_start_dt
                                                                                AND pdap_stop_dt)
                            AND EXISTS
                                    (SELECT 1 -- наявне це або інше рішення, яке діяло в місяці, що визначається як «розрахунковий період» «мінус» шість
                                       FROM pc_decision        sd,
                                            pd_accrual_period  pdap
                                      WHERE     sd.pd_pc = md.pd_pc
                                            AND sd.pd_nst = 664
                                            AND sd.pd_st IN ('S', 'PS')
                                            AND pdap_pd = sd.pd_id
                                            AND pdap.history_status = 'A'
                                            AND ADD_MONTHS (m.rc_month, -6) BETWEEN pdap_start_dt
                                                                                AND pdap_stop_dt)
                            AND NOT EXISTS
                                    (SELECT 1 --Не подовжувалось перерахунком 'S_VPO_131' або 'S_VPO_133'
                                       FROM pd_payment pdp, recalculates s
                                      WHERE     pdp.pdp_pd = pd_id
                                            AND m.rc_month - 1 BETWEEN pdp_start_dt
                                                                   AND pdp_stop_dt
                                            AND pdp.history_status = 'A'
                                            AND pdp.pdp_sum > 0 --Сума загалом не нульова
                                            AND pdp.pdp_rc = s.rc_id
                                            AND s.rc_tp IN
                                                    ('S_VPO_131', 'S_VPO_133'))));

        --  write_rc_log(p_rc_id, l_hs, 'F', NULL, l_recalculate.rc_st);

        write_message (
            1,
               'Знайдено '
            || SQL%ROWCOUNT
            || ' кандидатів, рішення по яким будуть виконані подовження або неподовження.');

        --Знаходимо осіб, по яким призначена сума допомоги - збергігається
        UPDATE tmp_work_set2
           SET x_string1 = '+'
         WHERE 2 =
               (SELECT COUNT (*)
                  FROM rc_candidates, rc_candidate_attr
                 WHERE     rcca_rcc = rcc_id
                       AND rcc_rc = p_rc_id
                       AND rcc_pd = x_id1
                       AND rcc_sc = x_id3
                       AND rcca_val_string = 'T');

        --Видаляємо всі діючі записи, які діють на перше число місяця перерахунку і пізніше
        UPDATE pd_payment
           SET pdp_hs_del = l_hs, history_status = 'H'
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_set2
                         WHERE pdp_pd = x_id1)
               AND pdp_stop_dt > l_recalculate.rc_month
               AND history_status = 'A';

        --Вставляємо шматочок запису призначеного, який діяв на перше число місяця перерахнку, якщо він почався до першого числа місяця перерахнку.
        INSERT INTO pd_payment (pdp_id,
                                pdp_pd,
                                pdp_npt,
                                pdp_start_dt,
                                pdp_stop_dt,
                                pdp_sum,
                                history_status,
                                pdp_hs_ins,
                                pdp_src,
                                pdp_rc)
            SELECT 0,
                   pdp_pd,
                   pdp_npt,
                   pdp_start_dt,
                   l_recalculate.rc_month - 1,
                   pdp_sum,
                   'A',
                   l_hs,
                   'EMS',
                   pdp_rc
              FROM pd_payment
             WHERE     pdp_hs_del = l_hs
                   AND pdp_start_dt < l_recalculate.rc_month;

        --Формуємо нові записи призначеного з місяця перерахунку + 6 місяців
        INSERT INTO pd_payment (pdp_id,
                                pdp_pd,
                                pdp_npt,
                                pdp_start_dt,
                                pdp_stop_dt,
                                history_status,
                                pdp_hs_ins,
                                pdp_src,
                                pdp_rc)
            SELECT 0,
                   pdp_pd,
                   pdp_npt,
                   l_recalculate.rc_month,
                   ADD_MONTHS (l_recalculate.rc_month, 6) - 1,
                   'A',
                   l_hs,
                   'EMS',
                   p_rc_id
              FROM pd_payment
             WHERE EXISTS
                       (SELECT 1
                          FROM tmp_work_set2
                         WHERE x_string1 = '+' AND x_id5 = pdp_id);

          --відтворюємо записи деталей призначеного на запис призначеного на місяць перерахунку
          INSERT ALL
            WHEN pdd_ndp <> 137
            THEN                     --Робимо копію всіх записів з новою сумою
                INTO pd_detail (pdd_id,
                                pdd_pdp,
                                pdd_row_order,
                                pdd_row_name,
                                pdd_key,
                                pdd_ndp,
                                pdd_start_dt,
                                pdd_stop_dt,
                                pdd_npt,
                                pdd_value)
                  VALUES (0,
                          x_new_pdp,
                          pdd_row_order,
                          pdd_row_name,
                          pdd_key,
                          pdd_ndp,
                          x_start_dt,
                          x_stop_dt,
                          pdd_npt,
                          x_sum)
            WHEN    (x_sum = 0 AND pdd_value > 0 AND pdd_ndp IN (290, 300))
                 OR pdd_ndp = 137
            THEN
                INTO pd_detail (pdd_id,
                                pdd_pdp,
                                pdd_row_order,
                                pdd_row_name,
                                pdd_key,
                                pdd_ndp,
                                pdd_start_dt,
                                pdd_stop_dt,
                                pdd_npt,
                                pdd_value)
                  VALUES (0,
                          x_new_pdp,
                          pdd_row_order,
                          pdd_row_name,
                          pdd_key,
                          137,
                          x_start_dt,
                          x_stop_dt,
                          pdd_npt,
                          pdd_value)
            SELECT pdd_pdp,
                   pdd_row_order,
                   pdd_row_name,
                   pdd_value,
                   pdd_key,
                   pdd_ndp,
                   l_recalculate.rc_month
                       AS x_start_dt,
                   ADD_MONTHS (l_recalculate.rc_month, 6) - 1
                       AS x_stop_dt,
                   pdd_npt,
                   CASE
                       WHEN     pdd_ndp IN (290, 300)
                            AND EXISTS
                                    (SELECT 1
                                       FROM tmp_work_set2
                                      WHERE     x_id1 = pdp_pd
                                            AND x_id2 = pdd_key
                                            AND x_string1 = '+')
                       THEN
                           pdd_value
                       ELSE
                           0
                   END
                       AS x_sum, --сума для 290/300 змінюється в залежності від наявності права
                   (SELECT MAX (pdp_id)
                      FROM pd_payment np
                     WHERE np.pdp_pd = dp.pdp_pd AND np.pdp_hs_ins = l_hs)
                       AS x_new_pdp
              FROM pd_payment dp, pd_detail ma
             WHERE     EXISTS
                           (SELECT 1
                              FROM tmp_work_set2
                             WHERE x_string1 = '+' AND x_id5 = pdp_id)
                   AND pdd_pdp = pdp_id;

        UPDATE pd_payment
           SET pdp_sum =
                   NVL ( (SELECT SUM (pdd_value)
                            FROM pd_detail
                           WHERE pdd_pdp = pdp_id AND pdd_ndp IN (290, 300)),
                        0)
         WHERE pdp_hs_ins = l_hs AND pdp_start_dt = l_recalculate.rc_month;

        --Переводимо реєстраційні записи нарахуваннь в "редагується" та "діюче по послугам" - аби можна було виконувати нарахування
        UPDATE accrual ac
           SET ac_st = CASE ac_st WHEN 'R' THEN 'RV' WHEN 'RP' THEN 'E' END
         WHERE     ac_st IN ('R', 'RP')
               AND EXISTS
                       (SELECT 1
                          FROM tmp_work_set2
                         WHERE ac_pc = x_id4)
               AND EXISTS
                       (SELECT 1
                          FROM billing_period,
                               pc_decision,
                               pc_account,
                               tmp_work_set2
                         WHERE     x_id4 = ac_pc
                               AND x_id1 = pd_id
                               AND pd_pa = pa_id
                               AND bp_month = ac_month
                               AND bp_org = pa_org
                               AND bp_tp = 'PR'
                               AND bp_class = 'VPO'
                               AND bp_st = 'R')
               AND (SELECT SUM (pdp_sum)
                      FROM pd_payment pdp, tmp_work_set2
                     WHERE     pdp.history_status = 'A'
                           AND x_id1 = pdp_pd
                           AND x_id4 = ac_pc
                           AND pdp_stop_dt = l_recalculate.rc_month - 1) <>
                   (SELECT SUM (pdp_sum)
                      FROM pd_payment pdp, tmp_work_set2
                     WHERE     pdp.history_status = 'A'
                           AND x_id1 = pdp_pd
                           AND x_id4 = ac_pc
                           AND pdp_start_dt = l_recalculate.rc_month);

        DELETE FROM pd_features
              WHERE     pde_nft BETWEEN 137 AND 138
                    AND EXISTS
                            (SELECT 1
                               FROM tmp_work_set2
                              WHERE x_id1 = pde_pd);

        INSERT INTO pd_features (pde_id,
                                 pde_pd,
                                 pde_val_string,
                                 pde_pdf,
                                 pde_nft)
            SELECT 0,
                   x_id1,
                   'T',
                   x_id2,
                   CASE rcca_nda WHEN 8538 THEN 137 WHEN 8539 THEN 138 END
              FROM tmp_work_set2, rc_candidates, rc_candidate_attr
             WHERE     rcc_rc = p_rc_id
                   AND rcc_pd = x_id1
                   AND rcc_sc = x_id3
                   AND rcca_rcc = rcc_id
                   AND rcca_val_string = 'T';

        -- подовжуємо записи по членах родини
        UPDATE pd_family pdf
           SET pdf.pdf_stop_dt =
                   (SELECT MIN (ADD_MONTHS (x_dt2, 6) - 1)
                      FROM tmp_work_set2
                     WHERE x_id1 = pdf_pd AND x_string1 = '+')
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_set2
                         WHERE x_id1 = pdf_pd AND x_string1 = '+')
               AND (pdf.history_status = 'A' OR pdf.history_status IS NULL)
               AND (   pdf.pdf_stop_dt = (SELECT pd_stop_dt
                                            FROM pc_decision pd
                                           WHERE pdf_pd = pd_id)
                    OR pdf.pdf_stop_dt IS NULL);

        --Подовжуємо реальний строк дії
        INSERT INTO pd_accrual_period (pdap_id,
                                       pdap_pd,
                                       pdap_start_dt,
                                       pdap_stop_dt,
                                       history_status,
                                       pdap_hs_ins)
            SELECT 0,
                   pd_id,
                   (SELECT MIN (x_dt2)
                      FROM tmp_work_set2
                     WHERE x_id1 = pd_id AND x_string1 = '+'),
                   (SELECT MIN (ADD_MONTHS (x_dt2, 6) - 1)
                      FROM tmp_work_set2
                     WHERE x_id1 = pd_id AND x_string1 = '+'),
                   'A',
                   l_hs
              FROM pc_decision
             WHERE EXISTS
                       (SELECT 1
                          FROM tmp_work_set2
                         WHERE x_id1 = pd_id AND x_string1 = '+');

        --Подовжуємо номінальний строк дії
        UPDATE pc_decision
           SET pd_stop_dt =
                   (SELECT MIN (ADD_MONTHS (x_dt2, 6) - 1)
                      FROM tmp_work_set2
                     WHERE x_id1 = pd_id AND x_string1 = '+')
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_work_set2
                     WHERE x_id1 = pd_id AND x_string1 = '+');

        --Пишемо протокол в змінені рішення
        FOR xx IN (SELECT DISTINCT pd_id,
                                   pd_st,
                                   pd_stop_dt,
                                   x_dt2
                     FROM tmp_work_set2 z1, pc_decision
                    WHERE x_id1 = pd_id AND x_string1 = '+')
        LOOP
            API$PC_DECISION.write_pd_log (
                xx.pd_id,
                l_hs,
                xx.pd_st,
                CHR (38) || '305#' || TO_CHAR (xx.x_dt2, 'DD.MM.YYYY'),
                xx.pd_st);
        END LOOP;
    END;

    PROCEDURE reset_rcca_value (p_rcca_id rc_candidate_attr.rcca_id%TYPE)
    IS
        l_rcca       rc_candidate_attr%ROWTYPE;
        l_rc_id      recalculates.rc_id%TYPE;
        l_rc_month   recalculates.rc_month%TYPE;
        l_pd         rc_candidates.rcc_pd%TYPE;
        l_sc         rc_candidates.rcc_sc%TYPE;
    BEGIN
        IF     TOOLS.GetCurrOrgTo NOT IN (32)
           AND NOT tools.is_role_assigned ('W_ESR_PAYROLL')
        THEN
            raise_application_error (
                -20000,
                'Тільки користувач ІОЦ з роллю "Технолог виплатних відомостей" може виконувати цю функцію!');
        END IF;

        BEGIN
            SELECT *
              INTO l_rcca
              FROM rc_candidate_attr
             WHERE     rcca_id = p_rcca_id
                   AND EXISTS
                           (SELECT 1
                              FROM uss_ndi.v_ndi_document_attr
                             WHERE nda_id = rcca_nda AND nda_can_edit = 'T')
                   AND EXISTS
                           (SELECT 1
                              FROM rc_candidates,
                                   recalculates,
                                   v_personalcase
                             WHERE     rcca_rcc = rcc_id
                                   AND rcc_pc = pc_id
                                   AND rcc_rc = rc_id
                                   AND rc_tp = 'S_VPO_INC');
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                raise_application_error (
                    -20000,
                    'Не вдалось оновити ознаку - ознаки можна оновлювати тільки для тих ЕОС, які на обліку в даному ОСЗН!');
        END;

        IF l_rcca.rcca_nda = 8561
        THEN
            SELECT rcc_rc,
                   rcc_pd,
                   rc_month,
                   rcc_sc
              INTO l_rc_id,
                   l_pd,
                   l_rc_month,
                   l_sc
              FROM rc_candidates, recalculates
             WHERE rcc_rc = rc_id AND rcc_id = l_rcca.rcca_rcc;

            --Якщо середньомісячний сукупний дохід на одного отримувача в сім'ї протягом тримісячного періоду,
            --за який враховуються доходи на момент продовження виплати допомоги, не перевищує чотирьох розмірів
            --прожиткового мінімуму для осіб, які втратили працездатність, то встановлюємо ознаку «так»
            UPDATE rc_candidate_attr
               SET rcca_val_string =
                       CASE
                           WHEN    NVL (
                                       (SELECT SUM (pic_member_month_income)
                                          FROM pd_income_calc,
                                               pd_income_session,
                                               rc_candidates
                                         WHERE     pic_pd = pin_pd
                                               AND pic_pin = pin_id
                                               AND pin_pd = rcc_pd
                                               AND rcca_rcc = rcc_id
                                               AND pin_rc = l_rc_id
                                               AND rcc_rc = l_rc_id
                                               AND pin_rc = rcc_rc),
                                       0) =
                                   0
                                OR (NOT EXISTS
                                        (SELECT *
                                           FROM pd_payment  pdp,
                                                pd_detail,
                                                pd_family   mf
                                          WHERE     pdp_pd = l_pd
                                                AND mf.history_status = 'A'
                                                AND pdf_pd = l_pd
                                                AND pdf_pd = pdp_pd
                                                AND pdd_pdp = pdp_id
                                                AND pdd_key = pdf_id
                                                AND pdf_sc = l_sc
                                                AND pdp.history_Status = 'A'
                                                AND l_rc_month BETWEEN pdp_start_dt
                                                                   AND pdp_stop_dt
                                                AND pdd_ndp IN (290, 300)
                                                AND pdd_value > 0))
                           THEN
                               'F'
                           WHEN (SELECT SUM (pic_member_month_income)
                                   FROM pd_income_calc,
                                        pd_income_session,
                                        rc_candidates
                                  WHERE     pic_pd = rcc_pd
                                        AND pic_pin = pin_id
                                        AND pin_pd = rcc_pd
                                        AND pin_rc = rcc_rc
                                        AND rcca_rcc = rcc_id) <=
                                  NVL (
                                      (SELECT lgw_work_unable_sum
                                         FROM uss_ndi.v_ndi_living_wage,
                                              rc_candidates,
                                              recalculates
                                        WHERE     history_status = 'A'
                                              AND rc_month >= lgw_start_dt
                                              AND (   rc_month <= lgw_stop_dt
                                                   OR lgw_stop_dt IS NULL)
                                              AND rcca_rcc = rcc_id
                                              AND rcc_rc = rc_id),
                                      0)
                                * 4
                           THEN
                               'T'
                           ELSE
                               'F'
                       END
             WHERE rcca_id = p_rcca_id;
        --raise_application_error(-20000, 'В реалізації!');
        ELSE
            UPDATE rc_candidate_attr
               SET rcca_val_string =
                       CASE WHEN rcca_val_string = 'T' THEN 'F' ELSE 'T' END
             WHERE rcca_id = p_rcca_id;
        END IF;
    END;

    PROCEDURE Prepare_S_VPO_INC (p_rc_id recalculates.rc_id%TYPE)
    IS
    BEGIN
        INSERT INTO tmp_s_vpo_inc_list (r_pd,
                                        r_pdf,
                                        r_sc,
                                        r_pc,
                                        r_start_dt,
                                        r_stop_dt,
                                        r_chk_dt,
                                        r_chk_month,
                                        r_birth_dt,
                                        r_z_member)
            SELECT pdf_pd,
                   pdf_id,
                   pdf_sc,
                   pd_pc,
                   ADD_MONTHS (rc_month, -3),
                   ADD_MONTHS (rc_month, -2) - 1,
                   rc_month - 1,
                   ADD_MONTHS (rc_month, -1),
                   NVL (
                       (SELECT scb_dt
                          FROM uss_person.v_socialcard,
                               uss_person.v_sc_change,
                               uss_person.v_sc_birth
                         WHERE     sc_id = pdf_sc
                               AND scc_sc = sc_id
                               AND sc_scc = scc_id
                               AND scc_scb = scb_id
                               AND scc_scb > 0),
                       pdf_birth_dt),
                   CASE
                       WHEN EXISTS
                                (SELECT 1
                                   FROM ap_person ap
                                  WHERE     app_ap = pd_ap
                                        AND ap.history_status = 'A'
                                        AND app_sc = pdf_sc
                                        AND app_tp = 'Z')
                       THEN
                           'T'
                       ELSE
                           'F'
                   END
              FROM pd_family      mf,
                   pc_decision    md,
                   pc_account,
                   tmp_work_ids3  orgs,
                   appeal,
                   recalculates   marc
             WHERE     pdf_pd = pd_id
                   AND mf.history_status = 'A'
                   AND pd_pa = pa_id
                   AND pa_org = orgs.x_id
                   AND pd_ap = ap_id
                   AND rc_id = p_rc_id
                   AND pd_st = 'S'
                   AND pd_nst = 664
                   AND pd_stop_dt >= ADD_MONTHS (rc_month, 1) --Діють і в місяці розрахунку + 1 місяць
                   AND EXISTS
                           (SELECT * --Строк реальної дії - не менший за розрахунковий період + 1 місяць
                              FROM pd_accrual_period pdap
                             WHERE     pdap_pd = pd_id
                                   AND pdap.history_status = 'A'
                                   AND ADD_MONTHS (rc_month, 1) <=
                                       pdap_stop_dt)
                   AND EXISTS
                           (SELECT *            --Діє в розрахунковому періоді
                              FROM pd_accrual_period pdap
                             WHERE     pdap_pd = pd_id
                                   AND pdap.history_status = 'A'
                                   AND rc_month BETWEEN pdap_start_dt
                                                    AND pdap_stop_dt)
                   AND EXISTS
                           (SELECT *  --Подовжувалось перерахунком 'S_VPO_136'
                              FROM pd_payment pdp, recalculates s
                             WHERE     pdp_pd = pd_id
                                   AND marc.rc_month BETWEEN pdp_start_dt
                                                         AND pdp_stop_dt
                                   AND pdp.history_status = 'A'
                                   AND pdp_sum > 0   --Сума загалом не нульова
                                   AND pdp_rc = s.rc_id
                                   AND s.rc_tp = 'S_VPO_13_6')
                   AND (   EXISTS
                               (SELECT 1 --Отримання доходів виконано хоча б по одній особі рішення в місяці розрахунку
                                  FROM mass_exchanges,
                                       me_income_result_rows,
                                       pd_family  sl
                                 WHERE     me_tp IN ('INC', 'INC2')
                                       AND me_month = marc.rc_month
                                       AND misr_me = me_id
                                       AND sl.pdf_pd = md.pd_id
                                       AND misr_sc = sl.pdf_sc
                                       AND sl.history_status = 'A')
                        OR EXISTS
                               (SELECT 1
                                  FROM mass_exchanges,
                                       me_income_request_src,
                                       me_income_request_rows,
                                       pd_family  sl
                                 WHERE     me_tp IN ('INC', 'INC2')
                                       AND me_month = marc.rc_month
                                       AND mirr_me = me_id
                                       AND mirr_sc = sl.pdf_sc
                                       AND mirs_mirr = mirr_id
                                       AND sl.pdf_pd = md.pd_id
                                       AND sl.history_status = 'A'
                                       AND (mirs_src_tp, mirs_answer_code) IN
                                               (SELECT 'PFU', '2' FROM DUAL
                                                UNION ALL
                                                SELECT 'DPS', '4' FROM DUAL)));

        ----------------------------------Копія розрахунку ознак з перерахунку 13.1
        --особам, які втратили працездатність, зокрема які досягли пенсійного віку, визначеного частиною першою статті
        --26 Закону України “Про загальнообов'язкове державне пенсійне страхування”, та отримують пенсію, розмір якої не
        --перевищує чотирьох розмірів прожиткового мінімуму для осіб, які втратили працездатність, на 1 січня року, в якому приймається рішення про призначення допомоги
        UPDATE tmp_s_vpo_inc_list
           SET r_is_pens_9444 = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_inc_list
           SET r_is_pens_9444 = 'T'
         WHERE EXISTS
                   (SELECT 1
                      FROM src_pension_info ma
                     WHERE     spi_sc = r_sc
                           AND spi_month =
                               (SELECT MAX (sl.spi_month)
                                  FROM src_pension_info sl
                                 WHERE     ma.spi_sc = sl.spi_sc
                                       AND sl.spi_month BETWEEN r_chk_month
                                                            AND LAST_DAY (
                                                                    r_chk_month))
                           AND (   (    spi_ls_subject_tp IN
                                            ('PENS', 'DD', 'DPN')
                                    AND spi_sum_zag > 0
                                    AND spi_sum_zag < 9444)
                                OR (    spi_ls_subject_tp_mil IN
                                            ('PENS', 'DD', 'DPN')
                                    AND spi_sum_zag_mil > 0
                                    AND spi_sum_zag_mil < 9444)));

        --особам з інвалідністю I чи II групи, дитині з інвалідністю віком до 18 років, дитині, хворій на тяжкі перинатальні ураження нервової системи, тяжкі вроджені
        --вади розвитку, рідкісні орфанні захворювання, онкологічні, онкогематологічні захворювання, дитячий церебральний параліч, тяжкі психічні розлади,
        --цукровий діабет I типу (інсулінозалежний), гострі або хронічні захворювання нирок IV ступеня, яка отримала тяжку травму, потребує трансплантації органа,
        --потребує паліативної допомоги, якій не встановлено інвалідність, що підтверджується документальн
        UPDATE tmp_s_vpo_inc_list
           SET r_pre_inv_group_by_ap =
                   (SELECT MIN (apda_val_string) --Група інвалідності з довідки МСЕК в зверненні
                      FROM pc_decision,
                           ap_person         app,
                           ap_document       ap,
                           ap_document_attr  apda
                     WHERE     pd_id = r_pd
                           AND app_sc = r_sc
                           AND app.history_status = 'A'
                           AND ap.history_status = 'A'
                           AND apda.history_status = 'A'
                           AND app_ap IN (pd_ap, pd_ap_reason)
                           AND apd_app = app_id
                           AND apda_apd = apd_id
                           AND apd_ndt = 201
                           AND apda_nda = 349),
               r_pre_inv_till_by_ap =
                   (SELECT MIN (apda_val_dt) --Дата призначено до з довідки МСЕК в зверненні
                      FROM pc_decision,
                           ap_person         app,
                           ap_document       ap,
                           ap_document_attr  apda
                     WHERE     pd_id = r_pd
                           AND app_sc = r_sc
                           AND app.history_status = 'A'
                           AND ap.history_status = 'A'
                           AND apda.history_status = 'A'
                           AND app_ap IN (pd_ap, pd_ap_reason)
                           AND apd_app = app_id
                           AND apda_apd = apd_id
                           AND apd_ndt = 201
                           AND apda_nda = 347),
               r_pre_have_201_in_ap =
                   CASE
                       WHEN EXISTS
                                (SELECT 1 --Чи є взагалі довідка МСЕК в зверненні
                                   FROM pc_decision,
                                        ap_person    app,
                                        ap_document  ap
                                  WHERE     pd_id = r_pd
                                        AND app_sc = r_sc
                                        AND app.history_status = 'A'
                                        AND ap.history_status = 'A'
                                        AND app_ap IN (pd_ap, pd_ap_reason)
                                        AND apd_app = app_id
                                        AND apd_ndt = 201)
                       THEN
                           'T'
                       ELSE
                           'F'
                   END,
               r_pre_in_bd =
                   CASE
                       WHEN EXISTS
                                (SELECT 1 --Чи є особа в бойових діях або можливих бойових діях по довідці ВПО
                                   FROM uss_person.v_sc_document,
                                        Uss_Doc.v_Doc_Attr2hist   h,
                                        Uss_Doc.v_Doc_Attributes  a
                                  WHERE     h.Da2h_Da = a.Da_Id
                                        AND da2h_dh = scd_dh
                                        AND scd_st IN ('1', 'A')
                                        AND da_nda = 4492
                                        AND EXISTS
                                                (SELECT 1
                                                   FROM uss_ndi.v_ndi_kaot_state
                                                        kaots,
                                                        uss_ndi.v_ndi_normative_act
                                                        nna
                                                  WHERE     kaots_kaot =
                                                            da_val_id
                                                        AND kaots.history_status =
                                                            'A'
                                                        AND kaots_nna =
                                                            nna_id
                                                        AND nna.history_status =
                                                            'A'
                                                        AND kaots_tp IN
                                                                ('BD', 'PMO') --В бойових діяхчи можливих бойових діях
                                                        AND (   kaots_stop_dt >
                                                                r_chk_dt
                                                             OR kaots_stop_dt
                                                                    IS NULL)))
                       THEN
                           'T'
                       ELSE
                           'F'
                   END
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_inc_list
           SET r_is_various_sic = 'F'
         WHERE 1 = 1;

        --Шукаємо серед даних довідок МСЕК, що прикріплені до рішення, такі, в яких 1/2 група та "призначено до" після r_start_dt (-3 місяці від розрахункового місяця).
        --Всіх інших з довідкою - виключаємо
        UPDATE tmp_s_vpo_inc_list
           SET r_is_various_sic =
                   CASE
                       WHEN r_pre_inv_group_by_ap IN ('1', '2') THEN 'T'
                       ELSE 'X'
                   END
         WHERE     r_is_various_sic = 'F'
               AND r_pre_have_201_in_ap = 'T'
               AND r_pre_inv_till_by_ap > r_chk_dt;

        --Шукаємо серед даних довідок МСЕК, що прикріплені до рішення, такі, в яких 1/2 група та "призначено до" до r_start_dt (-3 місяці від розрахункового місяця) та в Бойових діях чи можливих бойових діях по довідці ВПО.
        --Всіх інших з довідкою - виключаємо
        UPDATE tmp_s_vpo_inc_list
           SET r_is_various_sic =
                   CASE
                       WHEN r_pre_inv_group_by_ap IN ('1', '2') THEN 'T'
                       ELSE 'X'
                   END
         WHERE     r_is_various_sic = 'F'
               AND r_pre_have_201_in_ap = 'T'
               AND r_pre_inv_till_by_ap <= r_chk_dt
               AND r_pre_in_bd = 'T';

        --Обраховуємо дані по довідкам МСЕК з ЦБІ
        UPDATE tmp_s_vpo_inc_list
           SET r_pre_inv_group_from_cbi =
                   (SELECT da_val_string --Група інвалідності з довідки МСЕК з даних ЦБІ
                      FROM uss_person.v_sc_document,
                           Uss_Doc.v_Doc_Attr2hist   h,
                           Uss_Doc.v_Doc_Attributes  a
                     WHERE     scd_sc = r_sc
                           AND scd_st IN ('1', 'A')
                           AND scd_ndt = 201
                           AND scd_src = '34'
                           AND Da2h_Da = a.Da_Id
                           AND da2h_dh = scd_dh
                           AND da_nda = 349),
               r_pre_inv_till_from_cbi =
                   (SELECT da_val_dt --Дата призначено до з довідки МСЕК з даних ЦБІ
                      FROM uss_person.v_sc_document,
                           Uss_Doc.v_Doc_Attr2hist   h,
                           Uss_Doc.v_Doc_Attributes  a
                     WHERE     scd_sc = r_sc
                           AND scd_st IN ('1', 'A')
                           AND scd_ndt = 201
                           AND scd_src = '34'
                           AND Da2h_Da = a.Da_Id
                           AND da2h_dh = scd_dh
                           AND da_nda = 347),
               r_pre_have_201_from_cbi =
                   CASE
                       WHEN EXISTS
                                (SELECT 1 --Чи є взагалі довідка МСЕК з даних ЦБІ
                                   FROM uss_person.v_sc_document
                                  WHERE     scd_sc = r_sc
                                        AND scd_st IN ('1', 'A')
                                        AND scd_ndt = 201
                                        AND scd_src = '34')
                       THEN
                           'T'
                       ELSE
                           'F'
                   END
         WHERE r_is_various_sic = 'F';

        --Шукаємо серед даних довідок МСЕК, що надійшли з ЦБІ, такі, в яких 1/2 група та "призначено до" після r_start_dt (-3 місяці від розрахункового місяця).
        --Всіх інших з довідкою - виключаємо
        UPDATE tmp_s_vpo_inc_list
           SET r_is_various_sic =
                   CASE
                       WHEN r_pre_inv_group_from_cbi IN ('1', '2') THEN 'T'
                       ELSE 'X'
                   END
         WHERE     r_is_various_sic = 'F'
               AND r_pre_have_201_from_cbi = 'T'
               AND r_pre_inv_till_from_cbi > r_chk_dt;

        --Шукаємо серед даних довідок МСЕК, що надійшли з ЦБІ, такі, в яких 1/2 група та "призначено до" до r_start_dt (-3 місяці від розрахункового місяця) та в Бойових діях чи можливих бойових діях по довідці ВПО.
        --Всіх інших з довідкою - виключаємо
        UPDATE tmp_s_vpo_inc_list
           SET r_is_various_sic =
                   CASE
                       WHEN r_pre_inv_group_from_cbi IN ('1', '2') THEN 'T'
                       ELSE 'X'
                   END
         WHERE     r_is_various_sic = 'F'
               AND r_pre_have_201_from_cbi = 'T'
               AND r_pre_inv_till_from_cbi <= r_chk_dt
               AND r_pre_in_bd = 'T';

        --Обраховуємо дані по даним АСПОД
        UPDATE tmp_s_vpo_inc_list
           SET r_pre_inv_group_from_asd =
                   (SELECT MIN (sda_dis_group) --Група інвалідності по даним АСПОД
                      FROM src_disability_asopd
                     WHERE     sda_sc = r_sc
                           AND sda_dt =
                               (SELECT MAX (sl.sda_dt)
                                  FROM src_disability_asopd sl
                                 WHERE     sl.sda_sc = r_sc
                                       AND sl.sda_dt BETWEEN r_chk_month
                                                         AND r_chk_dt)
                           AND sda_dis_group IS NOT NULL
                           AND sda_dis_group IN ('1', '2')),
               r_pre_inv_till_from_asd =
                   (SELECT MIN (sda_dis_end) --Дата призначено до по даним АСПОД
                      FROM src_disability_asopd
                     WHERE     sda_sc = r_sc
                           AND sda_dt =
                               (SELECT MAX (sl.sda_dt)
                                  FROM src_disability_asopd sl
                                 WHERE     sl.sda_sc = r_sc
                                       AND sl.sda_dt BETWEEN r_chk_month
                                                         AND r_chk_dt)
                           AND sda_dis_group IS NOT NULL
                           AND sda_dis_group IN ('1', '2')),
               r_pre_have_201_from_asd =
                   CASE
                       WHEN EXISTS
                                (SELECT 1            --Чи є взагалі дані АСПОД
                                   FROM src_disability_asopd
                                  WHERE     sda_sc = r_sc
                                        AND sda_dt BETWEEN r_chk_month
                                                       AND r_chk_dt
                                        AND sda_dis_group IS NOT NULL)
                       THEN
                           'T'
                       ELSE
                           'F'
                   END
         WHERE r_is_various_sic = 'F';

        --Шукаємо серед даних АСОПД, такі, в яких 1/2 група та "призначено до" після r_start_dt (-3 місяці від розрахункового місяця).
        --Всіх інших з довідкою - виключаємо
        UPDATE tmp_s_vpo_inc_list
           SET r_is_various_sic =
                   CASE
                       WHEN r_pre_inv_group_from_asd IN ('1', '2') THEN 'T'
                       ELSE 'X'
                   END
         WHERE     r_is_various_sic = 'F'
               AND r_pre_have_201_from_asd = 'T'
               AND r_pre_inv_till_from_asd > r_chk_dt;

        --Шукаємо серед даних АСОПД, такі, в яких 1/2 група та "призначено до" до r_start_dt (-3 місяці від розрахункового місяця) та в Бойових діях чи можливих бойових діях по довідці ВПО.
        --Всіх інших з довідкою - виключаємо
        UPDATE tmp_s_vpo_inc_list
           SET r_is_various_sic =
                   CASE
                       WHEN r_pre_inv_group_from_asd IN ('1', '2') THEN 'T'
                       ELSE 'X'
                   END
         WHERE     r_is_various_sic = 'F'
               AND r_pre_have_201_from_asd = 'T'
               AND r_pre_inv_till_from_asd <= r_chk_dt
               AND r_pre_in_bd = 'T';

        --В ЄІССС здійснюємо пошук рішень по послузі з Ід=265 встановлюємо ознаку «має право, як хвора дитина» тим учасникам рішень, які мають вік до 18-ти років
        UPDATE tmp_s_vpo_inc_list
           SET r_is_have_265 = 'F'
         WHERE 1 = 1;

        --Шукаємо рішення 265 по учаснику
        UPDATE tmp_s_vpo_inc_list
           SET r_is_have_265 = 'T'
         WHERE     r_birth_dt > ADD_MONTHS (r_chk_dt, -216)
               AND EXISTS
                       (SELECT 1
                          FROM pc_decision,
                               pd_family          mf,
                               pd_accrual_period  pdap
                         WHERE     pd_nst = 265
                               AND mf.history_status = 'A'
                               AND pdf_pd = pd_id
                               AND pdf_sc = r_sc
                               AND pd_st IN ('S', 'PS')
                               AND pdap_pd = pd_id
                               AND pdap.history_status = 'A'
                               AND r_chk_dt BETWEEN pdap_start_dt
                                                AND pdap_stop_dt);

        --ЄІССС здійснюємо пошук рішень по послузі з Ід=248 встановлюємо ознаку «має право, як дитина з інвалідністю до 18-ти років» тим учасникам рішень, які мають вік до 18-ти років
        UPDATE tmp_s_vpo_inc_list
           SET r_is_have_248 = 'F'
         WHERE 1 = 1;

        --Шукаємо рішення 248 по учаснику
        UPDATE tmp_s_vpo_inc_list
           SET r_is_have_248 = 'T'
         WHERE     r_birth_dt > ADD_MONTHS (r_chk_dt, -216)
               AND EXISTS
                       (SELECT 1
                          FROM pc_decision,
                               pd_family          mf,
                               pd_accrual_period  pdap
                         WHERE     pd_nst = 248
                               AND mf.history_status = 'A'
                               AND pdf_pd = pd_id
                               AND pdf_sc = r_sc
                               AND pd_st IN ('S', 'PS')
                               AND pdap_pd = pd_id
                               AND pdap.history_status = 'A'
                               AND r_chk_dt BETWEEN pdap_start_dt
                                                AND pdap_stop_dt);


        --!В ЄІССС здійснюємо пошук рішень по послузі з Ід=248 і встановлюємо «має право, як особа, з інвалідністю 1 або 2 групи»,
        --!якщо в особи звернення по послузі з Ід=248, у якому наявний документ з Ід=201 («Виписка МСЕК»)
        --!і в атрибуті з Ід= 349 («група інвалідності») встановлено 1 група або 2 група і в атрибуті 347 («встановлено на період по») зазначено дату до першого дня місяця (включно),
        --!що дорівнює «розрахунковий період» мінус 3 місяці і в довідці ВПО в атрибуті з Ід= 4492 (КАТОТТГ), зазначено КАТОТТГ, у якого встановлено ознаку «Активні бойові дії» або «Можливі бойові дії»
        --По особі  ЄІССС здійснюємо пошук рішень по послузі з Ід=248
        --Якщо щодо особи наявний документ з Ід=201 («Виписка МСЕК») і в атрибуті з Ід= 349 («група інвалідності») встановлено 1 група або 2 група
        -- і в атрибуті 347 («встановлено на період по») зазначено дату після першого дня місяця (включно), що дорівнює «розрахунковий період» мінус 3 місяці,
        --то встановлюємо ознаку «має право, як особа, з інвалідністю 1 або 2 групи за даними призначеної допомоги особам з інвалідністю з дитинства»
        UPDATE tmp_s_vpo_inc_list
           SET r_is_have_248_and_have_201 = 'F'
         WHERE 1 = 1;

        --Знаходим тих, в кого взагалі є 248 послуга
        UPDATE tmp_s_vpo_inc_list
           SET r_is_have_248_and_have_201 = 'X'
         WHERE EXISTS
                   (SELECT 1
                      FROM pc_decision, pd_family mf, pd_accrual_period pdap
                     WHERE     pd_nst = 248
                           AND mf.history_status = 'A'
                           AND pdf_pd = pd_id
                           AND pdf_sc = r_sc
                           AND pd_st IN ('S', 'PS')
                           AND pdap_pd = pd_id
                           AND pdap.history_status = 'A'
                           AND r_chk_dt BETWEEN pdap_start_dt
                                            AND pdap_stop_dt);

        --По таким образовуємо групу інвалідності та дату "призначено по"
        UPDATE tmp_s_vpo_inc_list
           SET r_pre_inv_group_by_248_ap =
                   (SELECT MIN (apda_val_string) --Група інвалідності з довідки МСЕК в зверненні
                      FROM pc_decision,
                           ap_person          app,
                           ap_document        ap,
                           ap_document_attr   apda,
                           pd_accrual_period  pdap
                     WHERE     pd_nst = 248
                           AND app_sc = r_sc
                           AND app.history_status = 'A'
                           AND ap.history_status = 'A'
                           AND apda.history_status = 'A'
                           AND app_ap IN (pd_ap, pd_ap_reason)
                           AND apd_app = app_id
                           AND apda_apd = apd_id
                           AND apd_ndt = 201
                           AND apda_nda = 349
                           AND pd_st IN ('S', 'PS')
                           AND pdap_pd = pd_id
                           AND pdap.history_status = 'A'
                           AND r_chk_dt BETWEEN pdap_start_dt
                                            AND pdap_stop_dt),
               r_pre_inv_till_by_248_ap =
                   (SELECT MIN (apda_val_dt) --Дата призначено до з довідки МСЕК в зверненні
                      FROM pc_decision,
                           ap_person          app,
                           ap_document        ap,
                           ap_document_attr   apda,
                           pd_accrual_period  pdap
                     WHERE     pd_nst = 248
                           AND app_sc = r_sc
                           AND app.history_status = 'A'
                           AND ap.history_status = 'A'
                           AND apda.history_status = 'A'
                           AND app_ap IN (pd_ap, pd_ap_reason)
                           AND apd_app = app_id
                           AND apda_apd = apd_id
                           AND apd_ndt = 201
                           AND apda_nda = 347
                           AND pd_st IN ('S', 'PS')
                           AND pdap_pd = pd_id
                           AND pdap.history_status = 'A'
                           AND r_chk_dt BETWEEN pdap_start_dt
                                            AND pdap_stop_dt)
         WHERE r_is_have_248_and_have_201 = 'X';

        --  UPDATE tmp_s_vpo_inc_list
        --    SET r_is_have_248_and_have_201 = CASE WHEN r_pre_inv_group_by_248_ap IN ('1', '2') AND r_pre_inv_till_by_248_ap < r_start_dt AND r_pre_in_bd = 'T' THEN 'T' ELSE 'X' END
        --    WHERE r_is_have_248_and_have_201 = 'X';

        UPDATE tmp_s_vpo_inc_list
           SET r_is_have_248_and_have_201 =
                   CASE
                       WHEN     r_pre_inv_group_by_248_ap IN ('1', '2')
                            AND r_pre_inv_till_by_248_ap >= r_start_dt
                       THEN
                           'T'
                       ELSE
                           'X'
                   END
         WHERE r_is_have_248_and_have_201 = 'X';

        --За даними ЄІС «Діти» встановлюємо ознаку «має право, як дитина сирота» дітям сиротам
        UPDATE tmp_s_vpo_inc_list
           SET r_is_orphan = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_inc_list
           SET r_is_orphan = 'T'
         WHERE EXISTS
                   (SELECT 1
                      FROM src_orphans_reestr
                     WHERE     sor_sc_child = r_sc
                           AND sor_dt BETWEEN r_chk_month AND r_chk_dt);

        --За даними ЄІС «Діти» встановлюємо ознаки «має право, як батько вихователь» батькам виховалелям
        UPDATE tmp_s_vpo_inc_list
           SET r_is_orphan_parent = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_inc_list
           SET r_is_orphan_parent = 'T'
         WHERE    EXISTS
                      (SELECT 1
                         FROM src_orphans_reestr
                        WHERE     sor_sc_father = r_sc
                              AND sor_dt BETWEEN r_chk_month AND r_chk_dt)
               OR EXISTS
                      (SELECT 1
                         FROM src_orphans_reestr
                        WHERE     sor_sc_mother = r_sc
                              AND sor_dt BETWEEN r_chk_month AND r_chk_dt);

        --За даними ЄІС «Діти» встановлюємо ознаки «має право, як прийомні батьки» прийомним батькам
        UPDATE tmp_s_vpo_inc_list
           SET r_is_adopt_parent = 'F'
         WHERE 1 = 1;

        /*UPDATE tmp_s_vpo_inc_list
          SET r_is_adopt_parent = 'T'
          WHERE EXISTS (SELECT 1
                        FROM src_orphan_reestr
                        WHERE sor_sc_child = r_sc
                          AND sor_dt BETWEEN r_chk_month AND r_chk_dt);*/

        --В ЄІССС здійснюємо пошук рішень по послузі з Ід=268 встановлюємо ознаку «має право, як дитина сирота або як дитина,
        --позбавленим батьківського піклування» тим учасникам рішень, які мають вік до 18-ти років на перше число розрахункового місяця включно
        UPDATE tmp_s_vpo_inc_list
           SET r_is_268_orphant = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_inc_list
           SET r_is_268_orphant = 'T'
         WHERE     r_birth_dt >= ADD_MONTHS (r_chk_dt, -216)
               AND EXISTS
                       (SELECT 1
                          FROM pc_decision,
                               pd_family          mf,
                               pd_accrual_period  pdap
                         WHERE     pd_nst = 268
                               AND mf.history_status = 'A'
                               AND pdf_pd = pd_id
                               AND pdf_sc = r_sc
                               AND pd_st IN ('S', 'PS')
                               AND pdap_pd = pd_id
                               AND pdap.history_status = 'A'
                               AND r_chk_dt BETWEEN pdap_start_dt
                                                AND pdap_stop_dt);

        --В ЄІССС здійснюємо пошук рішень по послузі з Ід=268 встановлюємо ознаку «має право, як опікун (піклувальник)» тим учасникам рішень,
        --які є заявниками, якщо в рішенні є хоча б одна дитина  віком до 18-ти років станом на перше число розрахункового місяця включно
        UPDATE tmp_s_vpo_inc_list
           SET r_is_268_parent = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_inc_list
           SET r_is_268_parent = 'T'
         WHERE     r_birth_dt < ADD_MONTHS (r_chk_dt, -216)
               AND EXISTS
                       (SELECT 1
                          FROM pc_decision,
                               pd_accrual_period  pdap,
                               ap_person          app
                         WHERE     pd_nst = 268
                               AND pd_st IN ('S', 'PS')
                               AND pdap_pd = pd_id
                               AND pdap.history_status = 'A'
                               AND r_chk_dt BETWEEN pdap_start_dt
                                                AND pdap_stop_dt
                               AND app_ap = pd_ap
                               AND app_sc = r_sc
                               AND app.history_status = 'A'
                               AND app_tp = 'Z'
                               AND 1 <=
                                   (SELECT COUNT (*)
                                      FROM pd_family spdf
                                     WHERE     spdf.pdf_pd = pd_id
                                           AND spdf.history_status = 'A'
                                           AND spdf.pdf_birth_dt >=
                                               ADD_MONTHS (r_chk_dt, -216)));

        --Якщо щодо особи наявна інформація про інвалідність або з ПФУ, або з ЦБІ, а саме, «група інвалідності» встановлено 1 група або 2 група і відсутній атрибут «встановлено на період по»,  то встановлюємо ознаку «має право, як особа, з інвалідністю 1 або 2 групи за даними ПФУ або ЦБІ»
        UPDATE tmp_s_vpo_inc_list
           SET r_is_pfu_cbi_inv = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_inc_list
           SET r_is_pfu_cbi_inv = 'T'
         WHERE    EXISTS
                      (SELECT 1
                         FROM uss_person.v_sc_document,
                              Uss_Doc.v_Doc_Attr2hist   h,
                              Uss_Doc.v_Doc_Attributes  a
                        WHERE     scd_sc = r_sc
                              AND scd_st IN ('1', 'A')
                              AND scd_ndt = 201
                              AND scd_src = '34'
                              AND Da2h_Da = a.Da_Id
                              AND da2h_dh = scd_dh
                              AND da_nda = 349
                              AND da_val_string IN ('1', '2')) --Група інвалідності з довідки МСЕК з даних ЦБІ
               OR EXISTS
                      (SELECT 1
                         FROM src_pension_info
                        WHERE     spi_sc = r_sc
                              AND spi_month BETWEEN r_chk_month AND r_chk_dt
                              AND (   spi_inv_gr IN ('1', '2')
                                   OR spi_inv_gr_mil IN ('1', '2'))); --Група інвалідності з даних ПФУ

        ----------------------------------Кінець копії з 13.1

        --Якщо середньомісячний сукупний дохід на одного отримувача в сім'ї протягом тримісячного періоду,
        --за який враховуються доходи на момент продовження виплати допомоги, не перевищує чотирьох розмірів
        --прожиткового мінімуму для осіб, які втратили працездатність, то встановлюємо ознаку «так»
        UPDATE tmp_s_vpo_inc_list
           SET r_income_not_enough = 'F'
         WHERE 1 = 1;

        --Реальний розрахунок - в Postscript_S_VPO_INC

        --Якщо в рішенні наявний будь-який із трьох документів з Ід= 10072 «Довідка про наявність родинних зв’язків»,
        --з Ід= 10073 «Наказ служби у справах дітей про тимчасове влаштування», з Ід=10074 «Заява одного із законних
        --представників, завірена органом опіки та піклування», то особам віком до 18-ти років встановлюємо ознаку
        --«має право як дитина, яка прибула без супроводу законного представника»
        UPDATE tmp_s_vpo_inc_list
           SET r_child_unaccomp = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_inc_list
           SET r_child_unaccomp = 'T'
         WHERE     r_birth_dt > ADD_MONTHS (r_chk_dt, -216)
               AND EXISTS
                       (SELECT 1
                          FROM pc_decision, ap_person app, ap_document ap
                         WHERE     pd_id = r_pd
                               --AND app_sc = r_sc
                               AND app.history_status = 'A'
                               AND ap.history_status = 'A'
                               AND app_ap IN (pd_ap, pd_ap_reason)
                               AND apd_app = app_id
                               AND apd_ndt IN (10072, 10073, 10074));

        --В ЄІССС здійснюємо пошук рішень по послузі з Ід=901 «Допомога  на утримання дитини в сім’ї патронатного вихователя»,
        --якщо в такому рішенні особа має виплату з ndt_code=523, то встановлюємо ознаку «має право як патронатним вихователям,
        UPDATE tmp_s_vpo_inc_list
           SET r_foster_teacher = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_inc_list
           SET r_foster_teacher = 'T'
         WHERE EXISTS
                   (SELECT 1
                      FROM pc_decision,
                           pd_payment         pdp,
                           pd_family          mf,
                           pd_detail,
                           pd_accrual_period  pdap
                     WHERE     pdf_pd = pd_id
                           AND mf.history_status = 'A'
                           AND pd_st IN ('S', 'PS')
                           AND pd_nst = 901
                           AND pdp_pd = pd_id
                           AND pdp.history_status = 'A'
                           AND r_chk_dt + 1 BETWEEN pdp_start_dt
                                                AND pdp_stop_dt
                           AND pdp_npt = 839
                           AND pdd_pdp = pdp_id
                           AND pdd_ndp IN (521, 522)
                           AND pdd_key = pdf_id
                           AND pdf_sc = r_sc
                           AND pdap_pd = pd_id
                           AND pdap.history_status = 'A'
                           AND r_chk_dt + 1 BETWEEN pdap_start_dt
                                                AND pdap_stop_dt);

        --В ЄІССС здійснюємо пошук рішень по послузі з Ід=901 «Допомога  на утримання дитини в сім’ї патронатного вихователя»,
        --якщо в такому рішенні особа має виплату з ndt_code=524, то встановлюємо ознаку «має право як дитина влаштована до патронатного вихователя»
        UPDATE tmp_s_vpo_inc_list
           SET r_child_placed_foster = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_inc_list
           SET r_child_placed_foster = 'T'
         WHERE EXISTS
                   (SELECT 1
                      FROM pc_decision,
                           pd_payment         pdp,
                           pd_family          mf,
                           pd_detail,
                           pd_accrual_period  pdap
                     WHERE     pdf_pd = pd_id
                           AND mf.history_status = 'A'
                           AND pd_st IN ('S', 'PS')
                           AND pd_nst = 901
                           AND pdp_pd = pd_id
                           AND pdp.history_status = 'A'
                           AND r_chk_dt + 1 BETWEEN pdp_start_dt
                                                AND pdp_stop_dt
                           AND pdp_npt = 840
                           AND pdd_pdp = pdp_id
                           AND pdd_ndp IN (521, 522)
                           AND pdd_key = pdf_id
                           AND pdf_sc = r_sc
                           AND pdap_pd = pd_id
                           AND pdap.history_status = 'A'
                           AND r_chk_dt + 1 BETWEEN pdap_start_dt
                                                AND pdap_stop_dt);

        --Якщо в рішенні наявна особа, у якої в документі з Ід=605 «Анкета учасника звернення» в атрибуті з Ід= 8218 Особа,
        --яка втратила працездатність (визначено в абз.4 п.13-4) встановлено «Так», і якщо середньомісячний сукупний дохід на одного отримувача
        -- в сім'ї протягом тримісячного періоду, за який враховуються доходи на момент продовження виплати допомоги,
        --не перевищує чотирьох розмірів прожиткового мінімуму для осіб, які втратили працездатність, то «має право як особа, яка втратила працездатність згідно абз.4 п.13-4
        UPDATE tmp_s_vpo_inc_list
           SET r_lost_avility_work = 'F'
         WHERE 1 = 1;

        UPDATE tmp_s_vpo_inc_list
           SET r_lost_avility_work = 'X'
         WHERE EXISTS
                   (SELECT 1
                      FROM pc_decision,
                           ap_person         app,
                           ap_document       ap,
                           ap_document_attr  apda
                     WHERE     pd_id = r_pd
                           AND app_sc = r_sc
                           AND app.history_status = 'A'
                           AND ap.history_status = 'A'
                           AND apda.history_status = 'A'
                           AND app_ap = pd_ap
                           AND apd_app = app_id
                           AND apda_apd = apd_id
                           AND apd_ndt = 605
                           AND apda_nda = 8218
                           AND apda_val_string IN ('T'));

        --Додаткова умова щодо доходу - в Postscript_S_VPO_INC.


        --Особа відповідає умовам пункту 13-1 Порядку 332. Це ознака для ручного редагування
        UPDATE tmp_s_vpo_inc_list
           SET r_13_1_usr = 'F'
         WHERE 1 = 1;

        --Особа відповідає умовам пункту 13-4 Порядку 332. Це ознака для ручного редагування
        UPDATE tmp_s_vpo_inc_list
           SET r_13_4_usr = 'F'
         WHERE 1 = 1;
    END;

    PROCEDURE Postscript_S_VPO_INC (p_rc_id recalculates.rc_id%TYPE)
    IS
        l_hs            histsession.hs_id%TYPE;
        l_recalculate   recalculates%ROWTYPE;
    BEGIN
        l_hs := TOOLS.GetHistSession;

        SELECT *
          INTO l_recalculate
          FROM recalculates
         WHERE rc_id = p_rc_id;

        --Формуємо новий розріз доходів в рішеннях
        API$PC_DECISION_EXT.Processing_Income (p_rc_id, l_hs);

        --Якщо середньомісячний сукупний дохід на одного отримувача в сім'ї протягом тримісячного періоду,
        --за який враховуються доходи на момент продовження виплати допомоги, не перевищує чотирьох розмірів
        --прожиткового мінімуму для осіб, які втратили працездатність, то встановлюємо ознаку «так»
        UPDATE tmp_s_vpo_inc_list
           SET r_income_not_enough = 'X'
         WHERE     (SELECT SUM (pic_member_month_income)
                      FROM pd_income_calc, pd_income_session
                     WHERE     pic_pd = r_pd
                           AND pic_pin = pin_id
                           AND pin_pd = r_pd
                           AND pin_rc = p_rc_id) >
                   0
               AND EXISTS
                       (SELECT *
                          FROM pd_payment pdp, pd_detail, pd_family mf
                         WHERE     pdp_pd = r_pd
                               AND mf.history_status = 'A'
                               AND pdf_pd = r_pd
                               AND pdf_pd = pdp_pd
                               AND pdd_key = pdf_id
                               AND pdd_pdp = pdp_id
                               AND pdd_key = pdf_id
                               AND pdf_sc = r_sc
                               AND pdp.history_Status = 'A'
                               AND ADD_MONTHS (r_chk_month, 1) BETWEEN pdp_start_dt
                                                                   AND pdp_stop_dt
                               AND pdd_ndp IN (290, 300)
                               AND pdd_value > 0);

        UPDATE tmp_s_vpo_inc_list
           SET r_income_not_enough = 'T'
         WHERE     r_income_not_enough = 'X'
               AND (SELECT SUM (pic_member_month_income)
                      FROM pd_income_calc, pd_income_session
                     WHERE     pic_pd = r_pd
                           AND pic_pin = pin_id
                           AND pin_pd = r_pd
                           AND pin_rc = p_rc_id) <=
                     NVL (
                         (SELECT lgw_work_unable_sum
                            FROM uss_ndi.v_ndi_living_wage
                           WHERE     history_status = 'A'
                                 AND l_recalculate.rc_month >= lgw_start_dt
                                 AND (   l_recalculate.rc_month <=
                                         lgw_stop_dt
                                      OR lgw_stop_dt IS NULL)),
                         0)
                   * 4;

        --Якщо в рішенні наявна особа, у якої в документі з Ід=605 «Анкета учасника звернення» в атрибуті з Ід= 8218 Особа,
        --яка втратила працездатність (визначено в абз.4 п.13-4) встановлено «Так», і якщо середньомісячний сукупний дохід на одного отримувача
        -- в сім'ї протягом тримісячного періоду, за який враховуються доходи на момент продовження виплати допомоги,
        --не перевищує чотирьох розмірів прожиткового мінімуму для осіб, які втратили працездатність, то «має право як особа, яка втратила працездатність згідно абз.4 п.13-4
        UPDATE tmp_s_vpo_inc_list
           SET r_lost_avility_work = 'T'
         WHERE r_lost_avility_work = 'X' AND r_income_not_enough = 'T';

        INSERT INTO rc_candidate_attr (rcca_id,
                                       rcca_rcc,
                                       rcca_nda,
                                       rcca_val_string)
            SELECT 0,
                   rcc_id,
                   nda_id,
                   DECODE (nda_id,
                           8550, r_is_pens_9444,
                           8551, r_is_various_sic,
                           8552, r_is_have_265,
                           8553, r_is_have_248,
                           8554, r_is_orphan,
                           8555, r_is_orphan_parent,
                           8556, r_is_adopt_parent,
                           8557, r_is_have_248_and_have_201,
                           8558, r_is_268_orphant,
                           8559, r_is_268_parent,
                           8560, r_is_pfu_cbi_inv,
                           8561, r_income_not_enough,
                           8562, r_child_unaccomp,
                           8563, r_foster_teacher,
                           8564, r_child_placed_foster,
                           8565, r_lost_avility_work,
                           8566, r_13_1_usr,
                           8567, r_13_4_usr)
              FROM rc_candidates,
                   uss_ndi.v_ndi_document_attr,
                   tmp_s_vpo_inc_list
             WHERE     rcc_rc = p_rc_id
                   AND nda_ndt = 400
                   AND history_status = 'A'
                   AND rcc_pd = r_pd
                   AND rcc_sc = r_sc
                   AND nda_id IN (8550,
                                  8551,
                                  8552,
                                  8553,
                                  8554,
                                  8555,
                                  8556,
                                  8557,
                                  8558,
                                  8559,
                                  8560,
                                  8561,
                                  8562,
                                  8563,
                                  8564,
                                  8565,
                                  8566,
                                  8567);
    END;

    PROCEDURE Recalc_S_VPO_INC (p_rc_id   recalculates.rc_id%TYPE,
                                p_hs      histsession.hs_id%TYPE)
    IS
        l_hs            histsession.hs_id%TYPE;
        l_recalculate   recalculates%ROWTYPE;
    BEGIN
        --  raise_application_error(-20009, 'В реалізації!');
        l_hs := p_hs;

        IF l_hs IS NULL
        THEN
            l_hs := TOOLS.GetHistSession;
        END IF;

        SELECT *
          INTO l_recalculate
          FROM recalculates
         WHERE rc_id = p_rc_id;

        --ikis_sysweb.ikis_debug_pipe.WriteMsg(l_recalculate.rc_org_list);
        TOOLS.org_list_to_work_ids (3, l_recalculate.rc_org_list);

        DELETE FROM tmp_work_set2
              WHERE 1 = 1;

        DELETE FROM tmp_work_set3
              WHERE 1 = 1;

        --Знаходимо всі рішення і осіб, які діють на дату початку місяція перерахунку
        INSERT INTO tmp_work_set2 (x_id1,
                                   x_id2,
                                   x_id3,
                                   x_id4,
                                   x_id5,
                                   x_dt1,
                                   x_dt2,
                                   x_dt3,
                                   x_dt4)
            SELECT pdf_pd,
                   pdf_id,
                   pdf_sc,
                   pd_pc,
                   pdp_id,
                   NVL (
                       (SELECT scb_dt
                          FROM uss_person.v_socialcard,
                               uss_person.v_sc_change,
                               uss_person.v_sc_birth
                         WHERE     sc_id = pdf_sc
                               AND scc_sc = sc_id
                               AND sc_scc = scc_id
                               AND scc_scb = scb_id
                               AND scc_scb > 0),
                       pdf_birth_dt),
                   ADD_MONTHS (rc_month, 1),
                   pd_stop_dt,
                   SYSDATE
              FROM rc_candidates,
                   pd_family      mf,
                   pc_decision    md,
                   pc_account,
                   tmp_work_ids3  orgs,
                   appeal,
                   recalculates   marc,
                   pd_payment     pdp
             WHERE     rcc_rc = rc_id
                   AND mf.history_status = 'A'
                   AND rcc_pd = pd_id
                   AND rcc_sc = pdf_sc
                   AND pdf_pd = pd_id
                   AND pd_pa = pa_id
                   AND pa_org = orgs.x_id
                   AND pd_ap = ap_id
                   AND rc_id = p_rc_id
                   AND pd_st = 'S'
                   AND pd_nst = 664
                   AND pd_stop_dt >= ADD_MONTHS (rc_month, 1) --Діють і в місяці розрахунку
                   AND EXISTS
                           (SELECT * --Строк реальної дії - не менший за розрахунковий період + 1 місяць
                              FROM pd_accrual_period pdap
                             WHERE     pdap_pd = pd_id
                                   AND pdap.history_status = 'A'
                                   AND ADD_MONTHS (rc_month, 1) <=
                                       pdap_stop_dt)
                   AND EXISTS
                           (SELECT *            --Діє в розрахунковому періоді
                              FROM pd_accrual_period pdap
                             WHERE     pdap_pd = pd_id
                                   AND pdap.history_status = 'A'
                                   AND rc_month BETWEEN pdap_start_dt
                                                    AND pdap_stop_dt)
                   AND EXISTS
                           (SELECT 1  --Подовжувалось перерахунком 'S_VPO_136'
                              FROM pd_payment pdpx, recalculates s
                             WHERE     pdpx.pdp_pd = pd_id
                                   AND marc.rc_month BETWEEN pdpx.pdp_start_dt
                                                         AND pdpx.pdp_stop_dt
                                   AND pdpx.history_status = 'A'
                                   AND pdpx.pdp_sum > 0 --Сума загалом не нульова
                                   AND pdpx.pdp_rc = s.rc_id
                                   AND s.rc_tp = 'S_VPO_13_6')
                   AND pdp_pd = pd_id
                   AND pdp.history_status = 'A'
                   AND rc_month BETWEEN pdp_start_dt AND pdp_stop_dt
                   AND (   EXISTS
                               (SELECT * --Отримання доходів виконано хоча б по одній особі рішення в місяці розрахунку
                                  FROM mass_exchanges,
                                       me_income_result_rows,
                                       pd_family  sl
                                 WHERE     me_tp IN ('INC', 'INC2')
                                       AND me_month = marc.rc_month
                                       AND misr_me = me_id
                                       AND sl.pdf_pd = md.pd_id
                                       AND misr_sc = sl.pdf_sc
                                       AND sl.history_status = 'A')
                        OR EXISTS
                               (SELECT *
                                  FROM mass_exchanges,
                                       me_income_request_src,
                                       me_income_request_rows,
                                       pd_family  sl
                                 WHERE     me_tp IN ('INC', 'INC2')
                                       AND sl.history_status = 'A'
                                       AND me_month = marc.rc_month
                                       AND mirr_me = me_id
                                       AND mirr_sc = sl.pdf_sc
                                       AND mirs_mirr = mirr_id
                                       AND sl.pdf_pd = md.pd_id
                                       AND (mirs_src_tp, mirs_answer_code) IN
                                               (SELECT 'PFU', '2' FROM DUAL
                                                UNION ALL
                                                SELECT 'DPS', '4' FROM DUAL)))
                   AND EXISTS
                           (SELECT 1
                              FROM pd_income_session
                             WHERE     pin_pd = rcc_pd
                                   AND pin_rc = rc_id
                                   AND pin_st = 'E');

        write_message (
            1,
               'Знайдено '
            || SQL%ROWCOUNT
            || ' кандидатів, рішення по яким будуть виконані подовження або неподовження.');

        --Знаходимо осіб, по яким призначена сума допомоги - збергігається
        UPDATE tmp_work_set2
           SET x_string1 = '+'
         WHERE     EXISTS
                       (SELECT 1
                          FROM rc_candidates, rc_candidate_attr
                         WHERE     rcca_rcc = rcc_id
                               AND rcc_rc = p_rc_id
                               AND rcc_pd = x_id1
                               AND rcc_sc = x_id3
                               AND rcca_val_string = 'T')
               AND EXISTS
                       (SELECT *
                          FROM pd_detail
                         WHERE     pdd_pdp = x_id5
                               AND pdd_ndp IN (290, 300)
                               AND pdd_key = x_id2
                               AND pdd_value > 0);

        --Видаляємо всі діючі записи, які діють на перше число місяця перерахунку і пізніше
        UPDATE pd_payment
           SET pdp_hs_del = l_hs, history_status = 'H'
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_set2
                         WHERE pdp_pd = x_id1)
               AND pdp_stop_dt > ADD_MONTHS (l_recalculate.rc_month, 1)
               AND history_status = 'A';

        --Вставляємо шматочок запису призначеного, який діяв на перше число місяця перерахнку, якщо він почався до першого числа місяця перерахнку.
        INSERT INTO pd_payment (pdp_id,
                                pdp_pd,
                                pdp_npt,
                                pdp_start_dt,
                                pdp_stop_dt,
                                pdp_sum,
                                history_status,
                                pdp_hs_ins,
                                pdp_src,
                                pdp_rc)
            SELECT 0,
                   pdp_pd,
                   pdp_npt,
                   pdp_start_dt,
                   ADD_MONTHS (l_recalculate.rc_month, 1) - 1,
                   pdp_sum,
                   'A',
                   l_hs,
                   'EMS',
                   pdp_rc
              FROM pd_payment
             WHERE     pdp_hs_del = l_hs
                   AND pdp_start_dt < ADD_MONTHS (l_recalculate.rc_month, 1);

        --Формуємо нові записи призначеного на місяць перерахунку --LAST_DAY(l_recalculate.rc_month)
        INSERT INTO pd_payment (pdp_id,
                                pdp_pd,
                                pdp_npt,
                                pdp_start_dt,
                                pdp_stop_dt,
                                history_status,
                                pdp_hs_ins,
                                pdp_src,
                                pdp_rc)
            SELECT 0,
                   pdp_pd,
                   pdp_npt,
                   ADD_MONTHS (l_recalculate.rc_month, 1),
                   (SELECT MAX (x_dt3)
                      FROM tmp_work_set2
                     WHERE x_id1 = pdp_pd),
                   'A',
                   l_hs,
                   'EMS',
                   p_rc_id
              FROM pd_payment
             WHERE     pdp_hs_del = l_hs
                   AND ADD_MONTHS (l_recalculate.rc_month, 1) BETWEEN pdp_start_dt
                                                                  AND pdp_stop_dt;

          --відтворюємо записи деталей призначеного на запис призначеного на місяць перерахунку
          INSERT ALL
            WHEN x_old_pdp <> x_new_pdp
            THEN --Робимо копію всіх записів в запис призначеного, який діє на попередій період
                INTO pd_detail (pdd_id,
                                pdd_pdp,
                                pdd_row_order,
                                pdd_row_name,
                                pdd_key,
                                pdd_ndp,
                                pdd_start_dt,
                                pdd_stop_dt,
                                pdd_npt,
                                pdd_value)
                  VALUES (0,
                          x_old_pdp,
                          pdd_row_order,
                          pdd_row_name,
                          pdd_key,
                          pdd_ndp,
                          x_start_dt,
                          x_stop_dt,
                          pdd_npt,
                          pdd_value)
            WHEN pdd_ndp <> 137
            THEN                                   --Робимо копію всіх записів
                INTO pd_detail (pdd_id,
                                pdd_pdp,
                                pdd_row_order,
                                pdd_row_name,
                                pdd_key,
                                pdd_ndp,
                                pdd_start_dt,
                                pdd_stop_dt,
                                pdd_npt,
                                pdd_value)
                  VALUES (0,
                          x_new_pdp,
                          pdd_row_order,
                          pdd_row_name,
                          pdd_key,
                          pdd_ndp,
                          x_start_dt,
                          x_stop_dt,
                          pdd_npt,
                          x_sum)
            WHEN    (x_sum = 0 AND pdd_value > 0 AND pdd_ndp IN (290, 300))
                 OR pdd_ndp = 137
            THEN
                INTO pd_detail (pdd_id,
                                pdd_pdp,
                                pdd_row_order,
                                pdd_row_name,
                                pdd_key,
                                pdd_ndp,
                                pdd_start_dt,
                                pdd_stop_dt,
                                pdd_npt,
                                pdd_value)
                  VALUES (0,
                          x_new_pdp,
                          pdd_row_order,
                          pdd_row_name,
                          pdd_key,
                          137,
                          x_start_dt,
                          x_stop_dt,
                          pdd_npt,
                          pdd_value)
            SELECT pdd_pdp,
                   pdd_row_order,
                   pdd_row_name,
                   pdd_value,
                   pdd_key,
                   pdd_ndp,
                   ADD_MONTHS (l_recalculate.rc_month, 1)
                       AS x_start_dt,     /*LAST_DAY(l_recalculate.rc_month)*/
                   (SELECT MAX (x_dt3)
                      FROM tmp_work_set2
                     WHERE x_id1 = pdp_pd)
                       AS x_stop_dt,
                   pdd_npt,
                   CASE
                       WHEN     pdd_ndp IN (290, 300)
                            AND EXISTS
                                    (SELECT 1
                                       FROM tmp_work_set2
                                      WHERE     x_id1 = pdp_pd
                                            AND x_id2 = pdd_key
                                            AND x_string1 = '+')
                       THEN
                           CASE
                               WHEN pdd_value > 0
                               THEN
                                   pdd_value
                               WHEN EXISTS
                                        (SELECT 1
                                           FROM pd_detail sl
                                          WHERE     sl.pdd_ndp = 137
                                                AND sl.pdd_key = ma.pdd_key
                                                AND sl.pdd_value > 0)
                               THEN
                                   (SELECT MIN (sl.pdd_value)
                                      FROM pd_detail sl
                                     WHERE     sl.pdd_ndp = 137
                                           AND sl.pdd_key = ma.pdd_key
                                           AND sl.pdd_value > 0)
                               ELSE
                                   0
                           END
                       ELSE
                           0
                   END
                       AS x_sum, --сума для 290/300 змінюється в залежності від наявності права
                   (SELECT MAX (pdp_id)
                      FROM pd_payment np
                     WHERE np.pdp_pd = dp.pdp_pd AND np.pdp_hs_ins = l_hs)
                       AS x_new_pdp,
                   (SELECT MIN (pdp_id)
                      FROM pd_payment np
                     WHERE np.pdp_pd = dp.pdp_pd AND np.pdp_hs_ins = l_hs)
                       AS x_old_pdp
              FROM pd_payment dp, pd_detail ma
             WHERE     pdp_hs_del = l_hs
                   AND ADD_MONTHS (l_recalculate.rc_month, 1) BETWEEN pdp_start_dt
                                                                  AND pdp_stop_dt
                   AND pdd_pdp = pdp_id;

        UPDATE pd_payment
           SET pdp_sum =
                   NVL ( (SELECT SUM (pdd_value)
                            FROM pd_detail
                           WHERE pdd_pdp = pdp_id AND pdd_ndp IN (290, 300)),
                        0)
         WHERE     pdp_hs_ins = l_hs
               AND pdp_start_dt = ADD_MONTHS (l_recalculate.rc_month, 1);

        --Переводимо реєстраційні записи нарахуваннь в "редагується" та "діюче по послугам" - аби можна було виконувати нарахування
        UPDATE accrual ac
           SET ac_st = CASE ac_st WHEN 'R' THEN 'RV' WHEN 'RP' THEN 'E' END
         WHERE     ac_st IN ('R', 'RP')
               AND EXISTS
                       (SELECT 1
                          FROM tmp_work_set2
                         WHERE ac_pc = x_id4)
               AND EXISTS
                       (SELECT 1
                          FROM billing_period,
                               pc_decision,
                               pc_account,
                               tmp_work_set2
                         WHERE     x_id4 = ac_pc
                               AND x_id1 = pd_id
                               AND pd_pa = pa_id
                               AND bp_month = ac_month
                               AND bp_org = pa_org
                               AND bp_tp = 'PR'
                               AND bp_class = 'VPO'
                               AND bp_st = 'R')
               AND (SELECT SUM (pdp_sum)
                      FROM pd_payment pdp, tmp_work_set2
                     WHERE     pdp.history_status = 'A'
                           AND x_id1 = pdp_pd
                           AND x_id4 = ac_pc
                           AND pdp_stop_dt =
                               ADD_MONTHS (l_recalculate.rc_month, 1) - 1) <>
                   (SELECT SUM (pdp_sum)
                      FROM pd_payment pdp, tmp_work_set2
                     WHERE     pdp.history_status = 'A'
                           AND x_id1 = pdp_pd
                           AND x_id4 = ac_pc
                           AND pdp_start_dt =
                               ADD_MONTHS (l_recalculate.rc_month, 1));

        DELETE FROM pd_features
              WHERE     pde_nft BETWEEN 100 AND 116
                    AND EXISTS
                            (SELECT 1
                               FROM tmp_work_set2
                              WHERE x_id1 = pde_pd);

        INSERT INTO pd_features (pde_id,
                                 pde_pd,
                                 pde_val_string,
                                 pde_pdf,
                                 pde_nft)
            SELECT 0,
                   x_id1,
                   'T',
                   x_id2,
                   CASE rcca_nda
                       WHEN 8550 THEN 141
                       WHEN 8551 THEN 142
                       WHEN 8552 THEN 143
                       WHEN 8553 THEN 144
                       WHEN 8554 THEN 145
                       WHEN 8555 THEN 146
                       WHEN 8556 THEN 147
                       WHEN 8557 THEN 148
                       WHEN 8558 THEN 149
                       WHEN 8559 THEN 150
                       WHEN 8560 THEN 151
                       WHEN 8561 THEN 152
                       WHEN 8562 THEN 153
                       WHEN 8563 THEN 154
                       WHEN 8564 THEN 155
                       WHEN 8565 THEN 156
                       WHEN 8566 THEN 157
                       WHEN 8567 THEN 158
                   END
              FROM tmp_work_set2, rc_candidates, rc_candidate_attr
             WHERE     rcc_rc = p_rc_id
                   AND rcc_pd = x_id1
                   AND rcc_sc = x_id3
                   AND rcca_rcc = rcc_id
                   AND rcca_val_string = 'T';

        UPDATE pd_income_session
           SET pin_st = 'F'
         WHERE pin_rc = p_rc_id;

        --Пишемо протокол в змінені рішення
        FOR xx IN (SELECT DISTINCT pd_id,
                                   pd_st,
                                   pd_stop_dt,
                                   x_dt2
                     FROM tmp_work_set2 z1, pc_decision
                    WHERE x_id1 = pd_id AND x_string1 = '+')
        LOOP
            API$PC_DECISION.write_pd_log (
                xx.pd_id,
                l_hs,
                xx.pd_st,
                CHR (38) || '307#' || TO_CHAR (xx.x_dt2, 'DD.MM.YYYY'),
                xx.pd_st);
        END LOOP;
    END;

    --=====================================================================================--
    PROCEDURE Recalc_S_PAT_PAY (p_rc_id   rc_candidates.rcc_rc%TYPE,
                                p_hs      histsession.hs_id%TYPE)
    IS
        l_hs            histsession.hs_id%TYPE;
        l_lock          TOOLS.t_lockhandler;
        l_recalculate   recalculates%ROWTYPE;
        l_num           pc_account.pa_num%TYPE;
        l_1201          NUMBER (10) := 1201;
        l_messages      SYS_REFCURSOR;
    BEGIN
        --raise_application_error(-20000, 'В розробці!');
        --ikis_sysweb.ikis_debug_pipe.WriteMsg('enter Recalc_S_VPO_18');
        l_hs := p_hs;

        IF l_hs IS NULL
        THEN
            l_hs := TOOLS.GetHistSession;
        END IF;

        SELECT *
          INTO l_recalculate
          FROM recalculates
         WHERE rc_id = p_rc_id;

        -- Первинні данні
        DELETE FROM tmp_work_set2
              WHERE 1 = 1;

        INSERT INTO tmp_work_set2 (x_id1,
                                   x_id2,
                                   x_id3,
                                   x_id4,
                                   x_id5,
                                   x_sum1)
            WITH
                Dog
                AS
                    (SELECT DISTINCT a.ap_id, a.ap_reg_dt, a.ap_pc AS x_pc --,
                       FROM rc_candidates  rcc
                            JOIN appeal a
                                ON     a.ap_pc = rcc.rcc_pc
                                   AND a.ap_st IN ('O', 'WD')
                            JOIN ap_service s
                                ON     aps_ap = ap_id
                                   AND s.history_status = 'A'
                                   AND s.aps_nst = l_1201
                            JOIN ap_person p
                                ON     app_ap = ap_id
                                   AND p.history_status = 'A'
                                   AND p.app_tp = 'Z'
                      WHERE     rcc.rcc_rc = p_rc_id
                            AND a.ap_id =
                                (SELECT MAX (aa.ap_id)
                                   FROM appeal  aa
                                        JOIN ap_service SS
                                            ON     ss.aps_ap = aa.ap_id
                                               AND ss.history_status = 'A'
                                               AND ss.aps_nst = l_1201
                                  WHERE     aa.ap_pc = a.ap_pc
                                        AND a.ap_st IN ('O', 'WD')))
            SELECT pd.pd_pc,
                   pd.pd_id,                                      --pd.pd_nst,
                   d.ap_id,                                     --d.ap_reg_dt,
                   npd.pd_id     AS new_pd_id,
                   npd.pd_pa     AS new_pd_pa,
                   --pa.pa_id AS x_pa
                   rcc.rcc_rc
              FROM pc_decision  pd
                   JOIN rc_candidates rcc ON rcc.rcc_pd = pd_id
                   JOIN Dog d ON d.x_pc = pd.pd_pc
                   LEFT JOIN pc_decision npd ON npd.pd_src_id = pd.pd_id
             --  LEFT JOIN pc_account pa ON pa.pa_pc = pd.pd_pc AND pa.pa_nst = 1201
             WHERE rcc_rc = p_rc_id;

        --Пoшукаемо pc_account
        -- x_id1 AS x_pc, x_id2 AS x_pd, x_id3 AS x_ap, x_id4 AS x_npd, x_id5 AS x_pa
        UPDATE tmp_work_set2
           SET x_id5 =
                   (SELECT MAX (pa.pa_id)
                      FROM pc_account pa
                     WHERE pa.pa_pc = x_id1 AND pa.pa_nst = l_1201)
         WHERE x_id5 IS NULL;

        --Генеруємо необхідну кількість нових Особових рахунків
        INSERT INTO pc_account (pa_id, pa_pc, pa_nst)
            SELECT DISTINCT 0, x_id1, l_1201
              FROM tmp_work_set2
             WHERE x_id5 IS NULL;

        --Пoшукаемо pc_account новостворені
        -- x_id1 AS x_pc, x_id2 AS x_pd, x_id3 AS x_ap, x_id4 AS x_npd, x_id5 AS x_pa
        UPDATE tmp_work_set2
           SET x_id5 =
                   (SELECT MAX (pa.pa_id)
                      FROM pc_account pa
                     WHERE pa.pa_pc = x_id1 AND pa.pa_nst = l_1201)
         WHERE x_id5 IS NULL;

        --Генеруємо номера нових Особових рахунків
        FOR xx IN (  SELECT pa_id, pc_id, pc_num
                       FROM tmp_work_set2
                            JOIN personalcase ON pc_id = x_id1
                            JOIN pc_account ON pa_id = x_id5
                      WHERE pa_num IS NULL
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

            TOOLS.release_lock (l_lock);
        END LOOP;


        UPDATE pc_decision pd
           SET pd.pd_start_dt =
                   (SELECT MAX (p.pdp_stop_dt) + 1
                      FROM pd_payment p
                     WHERE p.pdp_pd = pd.pd_src_id AND p.history_status = 'A')
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_work_set2
                     WHERE x_id4 = pd.pd_id);

        --RETURN;

        --для зверненнь "Допомога"
        INSERT INTO pc_decision (pd_id,
                                 pd_pc,
                                 pd_ap,
                                 pd_pa,
                                 pd_dt,
                                 pd_st,
                                 pd_nst,
                                 pd_start_dt,
                                 com_org,
                                 com_wu,
                                 pd_src,
                                 pd_src_id,
                                 pd_ap_reason,
                                 pd_scc)
            SELECT DISTINCT
                   0,
                   x_pc,
                   x_ap,
                   x_pa,
                   TRUNC (SYSDATE),
                   'R0',
                   pa_nst,
                   (SELECT MAX (p.pdp_stop_dt) + 1
                      FROM pd_payment p
                     WHERE     p.pdp_pd = t.x_pd
                           AND p.history_status = 'A')    AS x_start_dt,
                   pd.com_org                             AS com_org,
                   NULL                                   AS com_wu,
                   'FS'                                   AS x_pd_src,
                   x_pd,
                   x_ap,
                   api$personalcase.Get_scc_by_appeal (x_ap)
              FROM (SELECT x_id1     AS x_pc,
                           x_id2     AS x_pd,
                           x_id3     AS x_ap,
                           x_id4     AS x_npd,
                           x_id5     AS x_pa
                      FROM tmp_work_set2) t
                   JOIN pc_decision pd ON pd.pd_id = t.x_pd
                   JOIN pc_account pa ON pa.pa_id = t.x_pa
             WHERE t.x_npd IS NULL;

        --Пoшукаемо новостворені рішення
        -- x_id1 AS x_pc, x_id2 AS x_pd, x_id3 AS x_ap, x_id4 AS x_npd, x_id5 AS x_pa
        UPDATE tmp_work_set2
           SET x_id4 =
                   (SELECT pd.pd_id
                      FROM pc_decision pd
                     WHERE pd.pd_src_id = x_id2)
         WHERE x_id4 IS NULL;

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
            SELECT 0                                             AS pdm_id,
                   t.x_npd,
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
                   l_hs,
                   api$personalcase.Get_scc_by_appeal (x_ap)     AS pdm_scc,
                   pdm.pdm_is_actual,
                   pdm.pdm_nd_num
              FROM (SELECT x_id1     AS x_pc,
                           x_id2     AS x_pd,
                           x_id3     AS x_ap,
                           x_id4     AS x_npd,
                           x_id5     AS x_pa
                      FROM tmp_work_set2) t
                   JOIN pd_pay_method pdm
                       ON     pdm.pdm_pd = t.x_pd
                          AND pdm.history_status = 'A'
                          AND pdm.pdm_is_actual = 'T'
             WHERE NOT EXISTS
                       (SELECT 1
                          FROM pd_pay_method m
                         WHERE m.pdm_pd = t.x_npd);



        DBMS_OUTPUT.put_line ('Проставляємо номери рішень');

        FOR xx
            IN (SELECT pd_id,
                       pc_id,
                       pc_num,
                       nst_name,
                       pa_num
                  FROM (SELECT pd_id,
                               pc_id,
                               pc_num,
                               nst_name,
                               pa_num
                          FROM tmp_work_set2
                               JOIN pc_decision ON pd_id = x_id4
                               JOIN personalcase ON pc_id = pd_pc
                               JOIN pc_account ON pa_id = pd_pa
                               JOIN uss_ndi.v_ndi_service_type
                                   ON pd_nst = nst_id
                         WHERE pd_num IS NULL))
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

            TOOLS.release_lock (l_lock);

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
        --API$ESR_Action.PrepareWrite_Visit_ap_log(xx.pd_id, CHR(38)||'11#'||l_num||'#'||xx.pc_num||'#'||xx.nst_name, NULL);
        END LOOP;

        --RETURN;

        DELETE FROM tmp_in_calc_pd
              WHERE 1 = 1;

        INSERT INTO tmp_in_calc_pd (ic_pd, ic_tp, ic_start_dt)
            --SELECT t.x_npd, 'RC.START_DT', l_recalculate.rc_month
            SELECT t.x_npd, 'R0', NULL
              FROM (SELECT x_id1     AS x_pc,
                           x_id2     AS x_pd,
                           x_id3     AS x_ap,
                           x_id4     AS x_npd,
                           x_id5     AS x_pa
                      FROM tmp_work_set2) t;

        --api$calc_pd.calc_pd( p_rc_ic  => l_recalculate.rc_id);
        api$calc_pd.calc_pd (2, NULL, l_messages);


        --    UPDATE
        --Ну, так работает только для массового рассчета начислений - там те, по кому появилась запись в accrual, привязанная к масс.перерасчету, переходят в R, а по кому не появилась - в O.
        --Можешь добавить обновление статуса на R в API$PD_OPERATIONS. Строка 4472, по идее. А после цикла, по кому не обновился статус - в O.



        /*
            DELETE FROM tmp_in_calc_pd WHERE 1=1;

            INSERT INTO tmp_in_calc_pd (ic_pd,ic_tp, ic_start_dt)
              SELECT DISTINCT rcc_pd, 'RC.START_DT', l_recalculate.rc_month
              FROM pc_decision pd, personalcase pc, pd_accrual_period pdap, recalculates, rc_candidates
              WHERE rc_id = p_rc_id
                AND rcc_rc = rc_id
                AND rcc_pd = pd_id
                AND pd_st = 'S'
                AND pd.com_org IN (SELECT orgs.x_id FROM tmp_work_ids3 orgs)
                AND pd.pd_nst IN (901, 1221)
                AND pd_pc = pc_id
                AND pdap_pd = pd_id
          --      AND pd_num = '51808-126434-2024-1'
                AND pdap.history_status = 'A'
                AND pdap_stop_dt BETWEEN ADD_MONTHS(rc_month, -1) AND LAST_DAY(rc_month) --кусочек срока рейльного действия в период "перший день попереднього місяця до місяця розрахунку".."останній день місяця розрахунку"
                AND NOT EXISTS (SELECT 1 --нет других кусочков после выбранного кусочка - т.е. срок действия реальный в указанном периоде и закончился
                                FROM pd_accrual_period epdap
                                WHERE epdap.pdap_start_dt > pdap.pdap_stop_dt
                                  AND epdap.history_Status = 'A'
                                  AND epdap.pdap_pd = pdap.pdap_pd);

            api$calc_pd.calc_pd( p_rc_ic  => l_recalculate.rc_id);
        */

        --Пишемо протокол про перераховані рішення
        FOR xx
            IN (SELECT pd_id,
                       pd_pc,
                       pd_st,
                       pd_nst,
                       TRUNC (l_recalculate.rc_month, 'MM')    AS x_queue_start
                  FROM tmp_in_calc_pd z1, pc_decision
                 WHERE     ic_pd = pd_id
                       AND pd_nst IN (901, 1221)
                       AND EXISTS
                               (SELECT 1
                                  FROM pd_payment
                                 WHERE     pdp_pd = pd_id
                                       AND history_status = 'A'
                                       AND pdp_start_dt >=
                                           l_recalculate.rc_month
                                       AND pdp_rc = p_rc_id))
        LOOP
            API$PC_DECISION.write_pd_log (
                xx.pd_id,
                l_hs,
                xx.pd_st,
                   CHR (38)
                || '331#'
                || TO_CHAR (l_recalculate.rc_month, 'DD.MM.YYYY'),
                xx.pd_st);
        END LOOP;

        --Пишемо в чергу перерахунку
        FOR xx
            IN (SELECT pd_id,
                       pd_pc,
                       pd_st,
                       pd_nst,
                       TRUNC (l_recalculate.rc_month, 'MM')    AS x_queue_start
                  FROM tmp_in_calc_pd z1, pc_decision
                 WHERE     ic_pd = pd_id
                       AND pd_nst IN (901, 1221)
                       AND EXISTS
                               (SELECT 1
                                  FROM pd_payment
                                 WHERE     pdp_pd = pd_id
                                       AND history_status = 'A'
                                       AND pdp_rc = p_rc_id))
        LOOP
            API$PERSONALCASE.add_pc_accrual_queue (xx.pd_pc,
                                                   'PD',
                                                   xx.x_queue_start,
                                                   NULL,
                                                   xx.pd_id);
        END LOOP;
    --raise_application_error(-20009, 'В реалізації!');
    END;

    --===========================================================================--
    PROCEDURE Recalc_S_VPO_INV (p_rc_id   rc_candidates.rcc_rc%TYPE,
                                p_hs      histsession.hs_id%TYPE)
    IS
        l_hs            histsession.hs_id%TYPE;
        l_recalculate   recalculates%ROWTYPE;
    BEGIN
        --ikis_sysweb.ikis_debug_pipe.WriteMsg('enter Recalc_S_VPO_18');

        --l_hs := NVL(p_hs, TOOLS.GetHistSession);
        l_hs := p_hs;

        IF l_hs IS NULL
        THEN
            l_hs := TOOLS.GetHistSession;
        END IF;

        SELECT *
          INTO l_recalculate
          FROM recalculates
         WHERE rc_id = p_rc_id;

        --ikis_sysweb.ikis_debug_pipe.WriteMsg(l_recalculate.rc_org_list);
        TOOLS.org_list_to_work_ids (3, l_recalculate.rc_org_list);

        DELETE FROM tmp_work_set4
              WHERE 1 = 1;

        --Знаходимо всіх осіб в рішеннях, по яким розписана в деталізації призначення сума 3000
        INSERT INTO tmp_work_set4 (x_id1,
                                   x_id2,
                                   x_id3,
                                   x_id4,
                                   x_id5,
                                   x_sum1,
                                   x_sum2,
                                   x_dt2)
            SELECT pc_id,
                   pd_id,
                   pdf_id,
                   pdp_id,
                   pdf_sc,
                   pdp_sum,
                   2000,
                   pdf_birth_dt
              FROM pd_family     mf,
                   pc_decision,
                   personalcase  pc,
                   rc_candidates,
                   recalculates,
                   pd_payment    pdp
             WHERE     rcc_rc = p_rc_id
                   AND rcc_rc = rc_id
                   AND rcc_pc = pc_id
                   AND rcc_pc = pd_pc
                   AND pdf_pd = pd_id
                   AND pd_nst = 664
                   AND pd_st = 'S'                             --Діючі рішення
                   AND mf.history_status = 'A'
                   AND pc.com_org IN (SELECT orgs.x_id
                                        FROM tmp_work_ids3 orgs)
                   AND pd_pc = pc_id
                   AND EXISTS
                           (SELECT 1
                              FROM pd_accrual_period pdap
                             WHERE     pdap_pd = pd_id
                                   AND pdap.history_status = 'A'
                                   AND rc_month <= pdap_stop_dt) --Рішення діє після 1 числа місяця перерахунку
                   AND pdp.history_status = 'A'
                   AND pdp_pd = pd_id
                   AND rc_month <= pdp_stop_dt --рядок призначення діє після 1 числа місяця перерахунку.
                   AND pdp_npt = 167
                   AND EXISTS
                           (SELECT 1
                              FROM pd_detail
                             WHERE     pdd_pdp = pdp_id
                                   --AND pdd_ndp = CASE WHEN pd_ap < 0 THEN 290 ELSE 300 END
                                   AND pdd_ndp IN (290, 300)
                                   AND pdd_key = pdf_id
                                   AND pdd_value = 3000); --беруться тільки ті рядки призначення, в яких є особи з 3000 грн

        --  write_rc_log(p_rc_id, l_hs, 'F', NULL, l_recalculate.rc_st);

        write_message (1, 'Осіб, що отримують 3000 грн: ' || SQL%ROWCOUNT);

        --Знаходимо по всім особам день народження та інші показники
        UPDATE tmp_work_set4
           SET x_dt1 =
                   NVL (
                       (SELECT DISTINCT
                               FIRST_VALUE (apda_val_dt)
                                   OVER (
                                       ORDER BY
                                           (CASE ndt_id
                                                WHEN 600 THEN 10
                                                ELSE ndt_order
                                            END))    AS x_birth_dt
                          FROM uss_esr.ap_person           app,
                               uss_esr.ap_document         apd,
                               uss_ndi.v_ndi_document_type,
                               uss_esr.v_ap_document_attr  apda,
                               uss_ndi.v_ndi_document_attr,
                               uss_esr.pc_decision
                         WHERE     app.history_status = 'A'
                               AND apd.history_status = 'A'
                               AND apda.history_status = 'A'
                               AND ndt_id = apd_ndt
                               AND (ndt_ndc = 13 OR ndt_id = 600)
                               AND apda_apd = apd_id
                               AND apda_val_dt IS NOT NULL
                               AND nda_id = apda_nda
                               AND nda_class = 'BDT'
                               AND apd_app = app_id
                               AND app_ap = apda_ap
                               AND app_ap = pd_ap
                               AND apd_ap = pd_ap
                               AND apda_ap = pd_ap
                               AND pd_id = x_id2
                               AND app_sc = x_id5),
                       x_dt2),
               x_string5 =
                   CASE
                       WHEN EXISTS
                                (SELECT 1 --Чи є особа в бойових діях або можливих бойових діях по довідці ВПО
                                   FROM uss_person.v_sc_document,
                                        Uss_Doc.v_Doc_Attr2hist   h,
                                        Uss_Doc.v_Doc_Attributes  a
                                  WHERE     h.Da2h_Da = a.Da_Id
                                        AND da2h_dh = scd_dh
                                        AND scd_st IN ('1', 'A')
                                        AND da_nda = 4492
                                        AND scd_ndt = 10052
                                        AND scd_sc = x_id5
                                        AND EXISTS
                                                (SELECT 1
                                                   FROM uss_ndi.v_ndi_kaot_state
                                                        kaots,
                                                        uss_ndi.v_ndi_normative_act
                                                        nna
                                                  WHERE     kaots_kaot =
                                                            da_val_id
                                                        AND kaots.history_status =
                                                            'A'
                                                        AND kaots_nna =
                                                            nna_id
                                                        AND nna.history_status =
                                                            'A'
                                                        AND kaots_tp IN
                                                                ('BD', 'PMO') --В бойових діяхчи можливих бойових діях
                                                        AND (   kaots_stop_dt >
                                                                l_recalculate.rc_month
                                                             OR kaots_stop_dt
                                                                    IS NULL)))
                       THEN
                           'T'
                       ELSE
                           'F'
                   END
         WHERE 1 = 1;

        UPDATE tmp_work_set4
           SET x_dt1 = NVL (x_dt1, x_dt2)
         WHERE 1 = 1;

        --Видаляємо тих, кому треба продовжувати виплачувати 3000 - на даному етапі - тим, кому не виповнилось 18 років. Залишаються тільки ті, яким треба виставити 2000.
        DELETE FROM tmp_work_set4
              WHERE x_dt1 >
                    ADD_MONTHS (l_recalculate.rc_month, -1 * (12 * 18));

        --Обраховуємо дані про інвалідність з 4 джерел. Пріорітетність: ЄІСС -> ЦБІ -> ПФУ -> Асопд
        --Група інвалідності та "призначено до" з довідки МСЕК з даних ЄІССС
        UPDATE tmp_work_set4
           SET (x_string4, x_string3, x_dt3) =
                   (SELECT 'USS',
                           MAX (
                               CASE
                                   WHEN da_nda = 349 THEN da_val_string
                                   ELSE NULL
                               END),
                           MAX (
                               CASE
                                   WHEN da_nda = 347 THEN da_val_dt
                                   ELSE NULL
                               END)
                      FROM uss_person.v_sc_document,
                           Uss_Doc.v_Doc_Attr2hist   h,
                           Uss_Doc.v_Doc_Attributes  a
                     WHERE     scd_sc = x_id5
                           AND scd_st IN ('1', 'A')
                           AND scd_ndt = 201
                           AND scd_src IN ('35', '37')
                           AND Da2h_Da = a.Da_Id
                           AND da2h_dh = scd_dh
                           AND da_nda IN (347, 349)
                    HAVING     MAX (
                                   CASE
                                       WHEN da_nda = 349 THEN da_val_string
                                       ELSE NULL
                                   END) IN
                                   ('1', '2')
                           AND MAX (
                                   CASE
                                       WHEN da_nda = 347 THEN da_val_dt
                                       ELSE NULL
                                   END)
                                   IS NOT NULL)
         WHERE 1 = 1;

        --Група інвалідності та "призначено до" з довідки МСЕК з даних ЦБІ
        UPDATE tmp_work_set4
           SET (x_string4, x_string3, x_dt3) =
                   (SELECT 'CBI',
                           MAX (
                               CASE
                                   WHEN da_nda = 349 THEN da_val_string
                                   ELSE NULL
                               END),
                           NVL (
                               MAX (
                                   CASE
                                       WHEN da_nda = 347 THEN da_val_dt
                                       ELSE NULL
                                   END),
                               TO_DATE ('31.12.2099', 'DD.MM.YYYY'))
                      FROM uss_person.v_sc_document,
                           Uss_Doc.v_Doc_Attr2hist   h,
                           Uss_Doc.v_Doc_Attributes  a
                     WHERE     scd_sc = x_id5
                           AND scd_st IN ('1', 'A')
                           AND scd_ndt = 201
                           AND scd_src = '34'
                           AND Da2h_Da = a.Da_Id
                           AND da2h_dh = scd_dh
                           AND da_nda IN (347, 349)
                    HAVING MAX (
                               CASE
                                   WHEN da_nda = 349 THEN da_val_string
                                   ELSE NULL
                               END) IN
                               ('1', '2'))
         WHERE x_dt3 IS NULL; --Не визначено на попередніх етапах перевірки "призначено по"

        --Група інвалідності та "призначено до" за даними ПФУ
        UPDATE tmp_work_set4
           SET (x_string4, x_string3, x_dt3) =
                   (SELECT 'PFU',
                           NVL (spi_inv_gr, spi_inv_gr_mil),
                           spi_inv_stop_dt
                      FROM src_pension_info
                     WHERE     (   spi_inv_gr IN ('1', '2')
                                OR spi_inv_gr_mil IN ('1', '2'))
                           AND spi_inv_stop_dt IS NOT NULL
                           AND spi_id =
                               (SELECT MAX (id.spi_id)
                                  FROM src_pension_info id
                                 WHERE     id.spi_sc = x_id5
                                       AND spi_month >=
                                           ADD_MONTHS (
                                               l_recalculate.rc_month,
                                               -1)))
         WHERE x_dt3 IS NULL; --Не визначено на попередніх етапах перевірки "призначено по"

        --Група інвалідності та "призначено до" з довідки МСЕК з даних АСОПД
        UPDATE tmp_work_set4
           SET (x_string4, x_string3, x_dt3) =
                   (SELECT 'ASOPD',
                           MAX (
                               CASE
                                   WHEN da_nda = 349 THEN da_val_string
                                   ELSE NULL
                               END),
                           MAX (
                               CASE
                                   WHEN da_nda = 347 THEN da_val_dt
                                   ELSE NULL
                               END)
                      FROM uss_person.v_sc_document,
                           Uss_Doc.v_Doc_Attr2hist   h,
                           Uss_Doc.v_Doc_Attributes  a
                     WHERE     scd_sc = x_id5
                           AND scd_st IN ('1', 'A')
                           AND scd_ndt = 201
                           AND scd_src = '710'
                           AND Da2h_Da = a.Da_Id
                           AND da2h_dh = scd_dh
                           AND da_nda IN (347, 349)
                    HAVING     MAX (
                                   CASE
                                       WHEN da_nda = 349 THEN da_val_string
                                       ELSE NULL
                                   END) IN
                                   ('1', '2')
                           AND MAX (
                                   CASE
                                       WHEN da_nda = 347 THEN da_val_dt
                                       ELSE NULL
                                   END)
                                   IS NOT NULL)
         WHERE x_dt3 IS NULL; --Не визначено на попередніх етапах перевірки "призначено по"

        --Якщо в документі з Ід=201 в атрибуті з Ід=347 ("встановлено на період до") зазначено перше число місяця. то датою до якої встановлено інвалідність вважати дату останній день попереднього місяця.
        UPDATE tmp_work_set4
           SET x_dt3 = x_dt3 - 1
         WHERE     x_dt3 IS NOT NULL
               AND x_string4 IN ('USS', 'CBI', 'ASOPD')
               AND x_dt3 = TRUNC (x_dt3, 'MM');

        --Видаляємо тих, кому треба продовжувати виплачувати 3000. Залишаються тільки ті, яким треба виставити 2000.
        DELETE FROM tmp_work_set4
              WHERE     x_string3 IS NOT NULL --Встановлена група інвалідності
                    AND (   ADD_MONTHS (x_dt3, 3) >= l_recalculate.rc_month --Дата "призначена до" + 3 місяці більша або рівна ніж дата розрахунку
                         OR (    ADD_MONTHS (x_dt3, 3) <
                                 l_recalculate.rc_month --Дата "призначена до" + 3 місяці менша ніж дата розрахунку та
                             AND x_string5 = 'T'));    --Особа з "бойових дій"

        write_message (
            1,
               'Визначили тих, кому продовжуємо виплачувати 3000 грн. Таких: '
            || SQL%ROWCOUNT);

        DELETE FROM tmp_work_set1
              WHERE 1 = 1;

        --Обраховуємо нову суму призначеного для рядків, в яких є треба продовжувати виплачувати. Обробляємо також випадки, коли таких осіб більше 1.
        INSERT INTO tmp_work_set1 (x_id1,
                                   x_dt1,
                                   x_dt2,
                                   x_sum1,
                                   x_sum2)
            SELECT pdp_id,
                   pdp_start_dt,
                   pdp_stop_dt,
                   pdp_sum,
                     pdp_sum
                   - NVL (
                         (SELECT SUM (pdd_value) - SUM (x_sum2)
                            FROM tmp_work_set4, pd_detail
                           WHERE     pdp_pd = x_id2
                                 AND pdd_pdp = pdp_id
                                 AND pdd_ndp IN (290, 300)
                                 AND pdd_key = x_id3),
                         0)
              FROM pd_payment pdp, pc_decision
             WHERE     pdp_id IN (SELECT x_id4 FROM tmp_work_set4)
                   AND pdp_pd = pd_id;

        --Визначаємо необхідність обмеження запису PDP зліва
        UPDATE tmp_work_set1
           SET x_string1 = '+'
         WHERE     l_recalculate.rc_month > x_dt1
               AND l_recalculate.rc_month <= x_dt2;

        --Визначаємо необхідність заміни запису PDP
        UPDATE tmp_work_set1
           SET x_string1 = '++'
         WHERE l_recalculate.rc_month <= x_dt1;

        UPDATE tmp_work_set1
           SET x_id2 = CASE WHEN x_string1 = '+' THEN id_pd_payment (0) END,
               x_id3 = id_pd_payment (0)
         WHERE 1 = 1;

        --Обмежуємо запис зліва
        UPDATE pd_payment pdp
           SET history_status = 'H', pdp_hs_del = l_hs
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_set1
                         WHERE pdp_id = x_id1 AND x_string1 = '+')
               AND history_status = 'A';

        --Створюємо новий запис призначеного зліва, якщо ми розрізаємо запис
        INSERT INTO pd_payment (pdp_id,
                                pdp_pd,
                                pdp_npt,
                                pdp_start_dt,
                                pdp_stop_dt,
                                pdp_sum,
                                history_status,
                                pdp_hs_ins)
            SELECT x_id2,
                   pdp_pd,
                   pdp_npt,
                   pdp_start_dt,
                   l_recalculate.rc_month - 1,
                   pdp_sum,
                   'A',
                   l_hs
              FROM tmp_work_set1, pd_payment
             WHERE x_string1 = '+' AND pdp_id = x_id1;

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
                   x_id2,
                   pdd_row_order,
                   pdd_row_name,
                   pdd_value,
                   pdd_key,
                   pdd_ndp,
                   pdd_start_dt,
                   l_recalculate.rc_month - 1
              FROM pd_payment pdp, tmp_work_set1, pd_detail
             WHERE pdp_id = x_id1 AND x_string1 = '+' AND pdd_pdp = pdp_id;

        --Записуємо запис "замість"
        UPDATE pd_payment pdp
           SET history_status = 'H', pdp_hs_del = l_hs
         WHERE     EXISTS
                       (SELECT 1
                          FROM tmp_work_set1
                         WHERE pdp_id = x_id1 AND x_string1 IN ('+', '++'))
               AND history_status = 'A';

        --Створюємо новий запис призначеного на "заміну". pdp_sum - нова, з поправкою на зменшені суми
        INSERT INTO pd_payment (pdp_id,
                                pdp_pd,
                                pdp_npt,
                                pdp_start_dt,
                                pdp_stop_dt,
                                pdp_sum,
                                history_status,
                                pdp_hs_ins,
                                pdp_rc)
            SELECT x_id3,
                   pdp_pd,
                   pdp_npt,
                   CASE
                       WHEN l_recalculate.rc_month < x_dt1 THEN x_dt1
                       ELSE l_recalculate.rc_month
                   END,
                   pdp_stop_dt,
                   x_sum2,
                   'A',
                   l_hs,
                   p_rc_id
              FROM tmp_work_set1, pd_payment
             WHERE x_string1 IN ('+', '++') AND pdp_id = x_id1;

        --Створюємо деталі pdp. pdd_value для 290 коду - нова, 2000 грн, по тим особам, кому виповнилось 18, але отримують 3000
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
                   x_id3,
                   pdd_row_order,
                   pdd_row_name,
                   CASE
                       WHEN --pdd_ndp = CASE WHEN pd_ap < 0 THEN 290 ELSE 300 END
                                pdd_ndp IN (290, 300)
                            AND EXISTS
                                    (SELECT 1
                                       FROM tmp_work_set4
                                      WHERE     x_id4 = pdp_id
                                            AND x_id3 = pdd_key)
                       THEN
                           2000
                       ELSE
                           pdd_value
                   END,
                   pdd_key,
                   pdd_ndp,
                   CASE
                       WHEN l_recalculate.rc_month < x_dt1 THEN x_dt1
                       ELSE l_recalculate.rc_month
                   END,
                   pdp_stop_dt
              FROM pd_payment  pdp,
                   tmp_work_set1,
                   pd_detail,
                   pc_decision
             WHERE     pdp_id = x_id1
                   AND x_string1 IN ('+', '++')
                   AND pdd_pdp = pdp_id
                   AND pdp_pd = pd_id;

        FOR xx
            IN (SELECT DISTINCT
                       pdp_pd,
                       pd_st,
                       uss_person.api$sc_tools.GET_PIB (z2.x_id5)
                           AS x_pib,
                       2000
                           AS x_new_sum
                  FROM tmp_work_set1  z1,
                       pd_payment,
                       pc_decision,
                       tmp_work_set4  z2
                 WHERE     z1.x_id1 = pdp_id
                       AND z1.x_string1 IN ('+', '++')
                       AND pdp_pd = pd_id
                       AND z1.x_id1 = z2.x_id4)
        LOOP
            API$PC_DECISION.write_pd_log (
                xx.pdp_pd,
                l_hs,
                xx.pd_st,
                   CHR (38)
                || '370#'
                || TO_CHAR (l_recalculate.rc_month, 'DD.MM.YYYY')
                || '#'
                || xx.x_pib
                || '#'
                || xx.x_new_sum,
                xx.pd_st);
        END LOOP;
    END;

    PROCEDURE Prepare_INDEX_VF (p_rc_id recalculates.rc_id%TYPE)
    IS
        l_nd        pd_pay_method.pdm_nd%TYPE;
        l_day       pd_pay_method.pdm_pay_dt%TYPE;
        l_message   VARCHAR2 (500);
    BEGIN
        INSERT INTO tmp_index_vf_list (r_pd,
                                       r_sc,
                                       r_pc,
                                       r_chk_month,
                                       r_index,
                                       r_ns,
                                       r_building,
                                       r_apartment)
            SELECT pd_id,
                   pc_sc,
                   pd_pc,
                   rc_month,
                   pdm_index,
                   pdm_ns,
                   pdm_building,
                   pdm_apartment
              FROM pc_decision    md,
                   personalcase,
                   recalculates   marc,
                   pd_pay_method  pdm
             WHERE     pd_pc = pc_id
                   AND rc_id = p_rc_id
                   AND pd_st = 'S'
                   --AND pd_nst = 664
                   AND pd_stop_dt >= rc_month    --Діють і в місяці розрахунку
                   AND pdm_pd = pd_id
                   AND pdm.history_status = 'A'
                   AND pdm_is_actual = 'T'
                   AND pdm_index = rc_index
                   AND pdm_ns IS NOT NULL
                   AND EXISTS
                           (SELECT 1
                              FROM uss_ndi.v_ndi_npo_config  t,
                                   uss_ndi.v_ndi_post_office
                             WHERE     t.nnc_ns = pdm_ns
                                   AND t.nnc_npo = npo_id
                                   AND npo_index <> pdm_index);

        --Шукаємо кількість налаштувань вулиці на поштові відділення
        UPDATE tmp_index_vf_list
           SET r_nnc_cnt =
                   (SELECT COUNT (*)
                      FROM uss_ndi.v_ndi_npo_config  t,
                           uss_ndi.v_ndi_post_office
                     WHERE nnc_ns = r_ns AND nnc_npo = npo_id)
         WHERE 1 = 1;

        --Видалення тих кандидатів, по вулицям яких немає налаштування прив'язки до поштового відділення. Пересторого - на даному етапі таких не повинно бути.
        DELETE FROM tmp_index_vf_list
              WHERE r_new_index = 0;

        --Якщо налаштування вулиці на поштове відділення одне - значить цей індекс і використовуємо
        UPDATE tmp_index_vf_list
           SET r_new_index =
                   (SELECT npo_index
                      FROM uss_ndi.v_ndi_npo_config  t,
                           uss_ndi.v_ndi_post_office
                     WHERE nnc_ns = r_ns AND nnc_npo = npo_id)
         WHERE r_nnc_cnt = 1;

        FOR xx IN (SELECT r_pd,
                          r_ns,
                          r_building,
                          r_apartment
                     FROM tmp_index_vf_list
                    WHERE r_nnc_cnt > 1)
        LOOP
            l_nd := NULL;
            uss_ndi.DNET$DIC_DELIVERY.GetDeliverybyadress (xx.r_ns,
                                                           xx.r_building,
                                                           xx.r_apartment,
                                                           l_nd,
                                                           l_day,
                                                           l_message);

            IF l_nd IS NULL
            THEN
                UPDATE tmp_index_vf_list
                   SET r_new_index = NULL, r_message = l_message
                 WHERE r_pd = xx.r_pd;
            ELSE
                UPDATE tmp_index_vf_list
                   SET r_new_index =
                           (SELECT npo_index
                              FROM uss_ndi.v_ndi_delivery,
                                   uss_ndi.v_ndi_post_office
                             WHERE nd_npo = npo_id AND nd_id = l_nd),
                       r_message =
                           'Індекс визначено за даними налаштування доставочних дільниць по вулиці!'
                 WHERE r_pd = xx.r_pd;
            END IF;
        END LOOP;
    END;

    PROCEDURE Recalc_INDEX_VF (p_rc_id   rc_candidates.rcc_rc%TYPE,
                               p_hs      histsession.hs_id%TYPE)
    IS
        l_hs            histsession.hs_id%TYPE;
        l_recalculate   recalculates%ROWTYPE;
    BEGIN
        l_hs := TOOLS.GetHistSessionEX (p_hs);

        SELECT *
          INTO l_recalculate
          FROM recalculates
         WHERE rc_id = p_rc_id;

        DELETE FROM tmp_work_set4
              WHERE 1 = 1;

        INSERT INTO tmp_work_set4 (x_id1,
                                   x_string1,
                                   x_id2,
                                   x_string2)
            SELECT pdm_id,
                   rcca_val_string,
                   rcc_pd,
                   pdm_index
              FROM rc_candidates, rc_candidate_attr, pd_pay_method pdm
             WHERE     rcc_rc = p_rc_id
                   AND rcca_rcc = rcc_id
                   AND rcca_nda = 9059
                   AND rcca_val_string IS NOT NULL
                   AND pdm_pd = rcc_pd
                   AND pdm.history_status = 'A'
                   AND pdm_is_actual = 'T'
                   AND pdm_index <> rcca_val_string;

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
            SELECT 0,
                   pdm_pd,
                   l_recalculate.rc_month,
                   pdm_stop_dt,
                   'A',
                   pdm_ap_src,
                   pdm_pay_tp,
                   x_string1,
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
                   l_hs,
                   pdm_scc,
                   'T',
                   pdm_nd_num
              FROM pd_pay_method, tmp_work_set4
             WHERE x_id1 = pdm_id AND x_id2 = pdm_pd;

        UPDATE pd_pay_method
           SET pdm_stop_dt = l_recalculate.rc_month - 1, pdm_is_actual = 'F'
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_work_set4
                     WHERE pdm_id = x_id1);

        UPDATE rc_candidates
           SET rcc_st = 'O'
         WHERE     rcc_rc = p_rc_id
               AND rcc_pd IN (SELECT x_id2 FROM tmp_work_set4);

        FOR xx
            IN (SELECT x_id2         AS x_pd,
                       x_string1     AS x_new_index,
                       x_string2     AS x_old_index
                  FROM tmp_work_set4)
        LOOP
            API$PC_DECISION.write_pd_log (
                xx.x_pd,
                l_hs,
                NULL,
                CHR (38) || '380#' || xx.x_old_index || '#' || xx.x_new_index,
                NULL);
        END LOOP;
    END;
END API$PD_OPERATIONS;
/