/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.api$clean_test
IS
    -- Author  : VANO
    -- Created : 24.07.2023 15:22:36
    -- Purpose : Функції очищення даних

    --Очиска рішень по 6 допомогам, по 1 ОСЗН: ручних та мігрованих
    PROCEDURE clean_one_oszn_6_services (p_org      ikis_sys.opfu.org_id%TYPE,
                                         p_nst_id   NUMBER:= NULL);

    --Очиска рішень по 6 допомогам, по переліку ОСЗН (через кому): ручних та мігрованих
    PROCEDURE clean_list_oszn_6_services (p_org_list   VARCHAR2,
                                          p_nst_id     NUMBER:= NULL);

    --Очистка рішень по 6 допомогам, по всім ОСЗН вказаного ДСЗН: ручних та мігрованих
    PROCEDURE clean_one_dszn_6_services (p_org      ikis_sys.opfu.org_id%TYPE,
                                         p_nst_id   NUMBER:= NULL);
END api$clean_test;
/


GRANT EXECUTE ON USS_ESR.API$CLEAN_TEST TO OZYNOVETS
/

GRANT EXECUTE ON USS_ESR.API$CLEAN_TEST TO TNIKONOVA
/


/* Formatted on 8/12/2025 5:48:58 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.api$clean_test
IS
    PROCEDURE clean_list_oszn_6_services (p_org_list   VARCHAR2,
                                          p_nst_id     NUMBER:= NULL)
    IS
    BEGIN
        DBMS_OUTPUT.put_line (
               TO_CHAR (SYSDATE, 'DD.MM.YYYY HH24:MI:SS')
            || ': Починаю очистку рішень - і мігрованих, і ручних - по переліку ОСЗН: '
            || p_org_list);

        FOR xx
            IN (SELECT org_id
                  FROM opfu
                 WHERE     org_to = 32
                       AND org_st = 'A'
                       AND org_id IN (    SELECT REGEXP_SUBSTR (p_org_list,
                                                                '[^,]+',
                                                                1,
                                                                LEVEL)
                                            FROM DUAL
                                      CONNECT BY REGEXP_SUBSTR (p_org_list,
                                                                '[^,]+',
                                                                1,
                                                                LEVEL)
                                                     IS NOT NULL))
        LOOP
            clean_one_oszn_6_services (xx.org_id, p_nst_id);
        END LOOP;

        DBMS_OUTPUT.put_line (
               TO_CHAR (SYSDATE, 'DD.MM.YYYY HH24:MI:SS')
            || ': Завершено очистку рішень');
    END;

    PROCEDURE clean_one_dszn_6_services (p_org      ikis_sys.opfu.org_id%TYPE,
                                         p_nst_id   NUMBER:= NULL)
    IS
    BEGIN
        DBMS_OUTPUT.put_line (
               TO_CHAR (SYSDATE, 'DD.MM.YYYY HH24:MI:SS')
            || ': Починаю очистку рішень - і мігрованих, і ручних - по ДСЗН: '
            || p_org);

        FOR xx IN (SELECT org_id
                     FROM opfu
                    WHERE org_to = 32 AND org_st = 'A' AND org_org = p_org)
        LOOP
            clean_one_oszn_6_services (xx.org_id);
        END LOOP;

        DBMS_OUTPUT.put_line (
               TO_CHAR (SYSDATE, 'DD.MM.YYYY HH24:MI:SS')
            || ': Завершено очистку рішень');
    END;

    PROCEDURE clean_one_oszn_6_services (p_org      ikis_sys.opfu.org_id%TYPE,
                                         p_nst_id   NUMBER:= NULL)
    IS
        l_cnt   INTEGER;
    BEGIN
        DBMS_OUTPUT.put_line (
               TO_CHAR (SYSDATE, 'DD.MM.YYYY HH24:MI:SS')
            || ': Починаю очистку рішень - і мігрованих, і ручних - по ОСЗН: '
            || p_org);

        EXECUTE IMMEDIATE 'ALTER SESSION SET cell_offload_processing=FALSE';

        IF ikis_sys.IKIS_PARAMETER_UTIL.GetParameter1 ('APP_INSTNACE_TYPE',
                                                       'IKIS_SYS') <>
           'TEST'
        THEN
            raise_application_error (
                -20000,
                'Ця функція може виконуватись тільки на тестовій базі!!!');
        END IF;

        UPDATE uss_esr.pc_account
           SET pa_stage = 1
         WHERE     (   (    p_nst_id IS NULL
                        AND pa_nst IN (248,
                                       249,
                                       265,
                                       267,
                                       268,
                                       269,
                                       862,
                                       251,
                                       275,
                                       250,
                                       901))
                    OR (p_nst_id IS NOT NULL AND pa_nst = p_nst_id))
               AND pa_stage = 2
               AND EXISTS
                       (SELECT 1
                          FROM uss_esr.pc_decision pd, ikis_sys.opfu
                         WHERE     pd_pa = pa_id
                               AND pd.com_org = org_id
                               AND org_id = p_org);

        UPDATE uss_esr.pc_account
           SET pa_stage = 1
         WHERE     (   (    p_nst_id IS NULL
                        AND pa_nst IN (248,
                                       249,
                                       265,
                                       267,
                                       268,
                                       269,
                                       862,
                                       251,
                                       275,
                                       250,
                                       901))
                    OR (p_nst_id IS NOT NULL AND pa_nst = p_nst_id))
               AND (pa_stage = 2 OR pa_stage IS NULL)
               AND EXISTS
                       (SELECT 1
                          FROM uss_esr.pc_decision pd, ikis_sys.opfu
                         WHERE     pd_pa = pa_id
                               AND pd.com_org = org_id
                               AND org_id = p_org);

        INSERT INTO uss_esr.tmp_work_ids2 (x_id)
            SELECT pd_id
              FROM uss_esr.pc_decision   pd,
                   uss_esr.personalcase  pc,
                   ikis_sys.opfu
             WHERE     (   (    p_nst_id IS NULL
                            AND pd_nst IN (248,
                                           249,
                                           265,
                                           267,
                                           268,
                                           269,
                                           862,
                                           251,
                                           275,
                                           250,
                                           901))
                        OR (p_nst_id IS NOT NULL AND pd_nst = p_nst_id))
                   /*AND (pd_src = 'MG' OR pd_ap < 0)*/
                   AND pd_pc = pc_id
                   AND pd.com_org = org_id
                   AND org_id = p_org;

        l_cnt := SQL%ROWCOUNT;

        IF l_cnt > 0
        THEN
            DBMS_OUTPUT.put_line (
                   TO_CHAR (SYSDATE, 'DD.MM.YYYY HH24:MI:SS')
                || ': буде очищено рішень: '
                || l_cnt);
        ELSE
            DBMS_OUTPUT.put_line (
                   TO_CHAR (SYSDATE, 'DD.MM.YYYY HH24:MI:SS')
                || ': немає рішень для очищення');
        END IF;

        INSERT INTO uss_esr.tmp_work_ids3 (x_id)
            SELECT DISTINCT pd_ap
              FROM uss_esr.pc_decision   pd,
                   uss_esr.personalcase  pc,
                   ikis_sys.opfu
             WHERE     (   (    p_nst_id IS NULL
                            AND pd_nst IN (248,
                                           249,
                                           265,
                                           267,
                                           268,
                                           269,
                                           862,
                                           251,
                                           275,
                                           250,
                                           901))
                        OR (p_nst_id IS NOT NULL AND pd_nst = p_nst_id))
                   /*AND pd_src = 'MG' and pd_ap < 0*/
                   AND pd_pc = pc_id
                   AND pd.com_org = org_id
                   AND org_id = p_org;

        l_cnt := SQL%ROWCOUNT;

        IF l_cnt > 0
        THEN
            DBMS_OUTPUT.put_line (
                   TO_CHAR (SYSDATE, 'DD.MM.YYYY HH24:MI:SS')
                || ': буде очищено зверненнь: '
                || SQL%ROWCOUNT);
        ELSE
            ROLLBACK;
            RETURN;
        END IF;

        DELETE FROM uss_esr.ap_log
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids3
                          WHERE x_id = apl_ap);

        DELETE FROM uss_esr.apr_income
              WHERE apri_apr IN (SELECT apr_id
                                   FROM uss_esr.ap_declaration
                                  WHERE EXISTS
                                            (SELECT 1
                                               FROM uss_esr.tmp_work_ids3
                                              WHERE x_id = apr_ap));

        DELETE FROM uss_esr.apr_land_plot
              WHERE aprt_apr IN (SELECT apr_id
                                   FROM uss_esr.ap_declaration
                                  WHERE EXISTS
                                            (SELECT 1
                                               FROM uss_esr.tmp_work_ids3
                                              WHERE x_id = apr_ap));

        DELETE FROM uss_esr.apr_living_quarters
              WHERE aprl_apr IN (SELECT apr_id
                                   FROM uss_esr.ap_declaration
                                  WHERE EXISTS
                                            (SELECT 1
                                               FROM uss_esr.tmp_work_ids3
                                              WHERE x_id = apr_ap));

        DELETE FROM uss_esr.apr_living_quarters
              WHERE aprl_aprp IN
                        (SELECT aprp_id
                           FROM uss_esr.apr_person
                          WHERE aprp_apr IN
                                    (SELECT apr_id
                                       FROM uss_esr.ap_declaration
                                      WHERE EXISTS
                                                (SELECT 1
                                                   FROM uss_esr.tmp_work_ids3
                                                  WHERE x_id = apr_ap)));

        DELETE FROM uss_esr.apr_other_income
              WHERE apro_apr IN (SELECT apr_id
                                   FROM uss_esr.ap_declaration
                                  WHERE EXISTS
                                            (SELECT 1
                                               FROM uss_esr.tmp_work_ids3
                                              WHERE x_id = apr_ap));

        DELETE FROM uss_esr.apr_spending
              WHERE aprs_apr IN (SELECT apr_id
                                   FROM uss_esr.ap_declaration
                                  WHERE EXISTS
                                            (SELECT 1
                                               FROM uss_esr.tmp_work_ids3
                                              WHERE x_id = apr_ap));

        DELETE FROM uss_esr.apr_vehicle
              WHERE aprv_apr IN (SELECT apr_id
                                   FROM uss_esr.ap_declaration
                                  WHERE EXISTS
                                            (SELECT 1
                                               FROM uss_esr.tmp_work_ids3
                                              WHERE x_id = apr_ap));

        DELETE FROM uss_esr.apr_alimony
              WHERE apra_apr IN (SELECT apr_id
                                   FROM uss_esr.ap_declaration
                                  WHERE EXISTS
                                            (SELECT 1
                                               FROM uss_esr.tmp_work_ids3
                                              WHERE x_id = apr_ap));

        DELETE FROM uss_esr.apr_person
              WHERE aprp_apr IN (SELECT apr_id
                                   FROM uss_esr.ap_declaration
                                  WHERE EXISTS
                                            (SELECT 1
                                               FROM uss_esr.tmp_work_ids3
                                              WHERE x_id = apr_ap));

        DELETE FROM uss_esr.ap_declaration
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids3
                          WHERE x_id = apr_ap);

        DELETE FROM uss_esr.ap_payment
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids3
                          WHERE x_id = apm_ap);

        DELETE FROM uss_esr.ap_document_attr
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids3
                          WHERE x_id = apda_ap);

        DELETE FROM uss_esr.ap_document
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids3
                          WHERE x_id = apd_ap);

        DELETE FROM uss_esr.pd_document_attr
              WHERE pdoa_pdo IN
                        (SELECT pdo_id
                           FROM uss_esr.pd_document
                          WHERE pdo_aps IN
                                    (SELECT aps_id
                                       FROM uss_esr.ap_service
                                      WHERE EXISTS
                                                (SELECT 1
                                                   FROM uss_esr.tmp_work_ids3
                                                  WHERE x_id = aps_ap)));

        DELETE FROM uss_esr.pd_document
              WHERE pdo_aps IN (SELECT aps_id
                                  FROM uss_esr.ap_service
                                 WHERE EXISTS
                                           (SELECT 1
                                              FROM uss_esr.tmp_work_ids3
                                             WHERE x_id = aps_ap));

        DELETE FROM uss_esr.ap_service
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids3
                          WHERE x_id = aps_ap);

        --commit;
        DELETE FROM uss_esr.eva_log
              WHERE eval_eva IN (SELECT eva_id
                                   FROM uss_esr.esr2visit_actions
                                  WHERE EXISTS
                                            (SELECT 1
                                               FROM uss_esr.tmp_work_ids3
                                              WHERE x_id = eva_ap));

        DELETE FROM uss_esr.esr2visit_actions
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids3
                          WHERE x_id = eva_ap);

        DELETE FROM uss_esr.pd_log
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids2
                          WHERE x_id = pdl_pd);

        DELETE FROM uss_esr.pd_right_log
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids2
                          WHERE x_id = prl_pd);

        DELETE FROM uss_esr.pd_detail
              WHERE pdd_pdp IN (SELECT pdp_id
                                  FROM uss_esr.pd_payment
                                 WHERE EXISTS
                                           (SELECT 1
                                              FROM uss_esr.tmp_work_ids2
                                             WHERE x_id = pdp_pd));

        DELETE FROM uss_esr.pd_payment
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids2
                          WHERE x_id = pdp_pd);

        DELETE FROM uss_esr.pd_features
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids2
                          WHERE x_id = pde_pd);

        DELETE FROM uss_esr.pd_family
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids2
                          WHERE x_id = pdf_pd);

        --commit;

        DELETE FROM uss_esr.pd_income_src
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids2
                          WHERE x_id = pis_pd);

        DELETE FROM uss_esr.pd_income_log
              WHERE pil_pid IN
                        (SELECT pid_id
                           FROM uss_esr.pd_income_detail
                          WHERE pid_pic IN
                                    (SELECT pic_id
                                       FROM uss_esr.pd_income_calc
                                      WHERE EXISTS
                                                (SELECT 1
                                                   FROM uss_esr.tmp_work_ids2
                                                  WHERE x_id = pic_pd)));

        DELETE FROM uss_esr.pd_income_detail
              WHERE pid_pic IN (SELECT pic_id
                                  FROM uss_esr.pd_income_calc
                                 WHERE EXISTS
                                           (SELECT 1
                                              FROM uss_esr.tmp_work_ids2
                                             WHERE x_id = pic_pd));

        DELETE FROM uss_esr.pd_income_calc
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids2
                          WHERE x_id = pic_pd);

        DELETE FROM uss_esr.pd_income_src
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids2
                          WHERE x_id = pis_pd);

        DELETE FROM uss_esr.pd_accrual_period
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids2
                          WHERE x_id = pdap_pd);

        DELETE FROM uss_esr.pd_accrual_period p
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids2
                          WHERE x_id = p.pdap_change_pd);

        DELETE FROM uss_esr.pd_pay_method m
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids2
                          WHERE x_id = m.pdm_pd);

        --commit;

        DELETE FROM uss_esr.pco_detail
              WHERE pcod_pco IN (SELECT pco_id
                                   FROM uss_esr.pc_data_ordering
                                  WHERE EXISTS
                                            (SELECT 1
                                               FROM uss_esr.tmp_work_ids2
                                              WHERE x_id = pco_pd));

        DELETE FROM uss_esr.pc_data_ordering
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids2
                          WHERE x_id = pco_pd);

        DELETE FROM uss_esr.ac_detail d
              WHERE     EXISTS
                            (SELECT 1
                               FROM uss_esr.tmp_work_ids2
                              WHERE x_id = d.acd_pd)
                    AND ROWNUM < 8000000; -- 26102022 додано захист, якщо поле заповнено значить додано до ведомосты ы видалення вже неможливе

        UPDATE uss_esr.pc_decision
           SET pd_pcb = NULL
         WHERE EXISTS
                   (SELECT 1
                      FROM uss_esr.tmp_work_ids3
                     WHERE x_id = pd_ap);

        UPDATE uss_esr.pr_sheet
           SET prs_pcb = NULL
         WHERE prs_pcb IN (SELECT pcb_id
                             FROM uss_esr.pc_block pcb
                            WHERE EXISTS
                                      (SELECT 1
                                         FROM uss_esr.tmp_work_ids2
                                        WHERE x_id = pcb.pcb_pd));

        DELETE FROM uss_esr.pc_block pcb
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids2
                          WHERE x_id = pcb.pcb_pd);

        DELETE FROM uss_esr.pc_accrual_queue
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids2
                          WHERE x_id = paq_pd);

        DELETE FROM uss_esr.pd_reject_info
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids2
                          WHERE x_id = pri_pd);

        DELETE FROM uss_esr.pc_location
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.pc_attestat
                          WHERE     pl_pca = pca_id
                                AND EXISTS
                                        (SELECT 1
                                           FROM uss_esr.tmp_work_ids2
                                          WHERE x_id = pca_pd));

        DELETE FROM uss_esr.pca_log
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.pc_attestat
                          WHERE     pcal_pca = pca_id
                                AND EXISTS
                                        (SELECT 1
                                           FROM uss_esr.tmp_work_ids2
                                          WHERE x_id = pca_pd));

        DELETE FROM uss_esr.pc_attestat
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids2
                          WHERE x_id = pca_pd);

        DELETE FROM uss_esr.pd_document_attr
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.pd_document m
                          WHERE     pdoa_pdo = pdo_id
                                AND EXISTS
                                        (SELECT 1
                                           FROM uss_esr.tmp_work_ids2
                                          WHERE x_id = m.pdo_pd));

        DELETE FROM uss_esr.pd_document m
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids2
                          WHERE x_id = m.pdo_pd);

        DELETE FROM uss_esr.pd_source
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids2
                          WHERE x_id = pds_pd);

        DELETE FROM uss_esr.pd_log
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids2
                          WHERE x_id = pdl_pd); -- 03112022 pd.pd_ap_reason = pd.pd_ap так как удаляются только то что замигрировалось

        DELETE FROM uss_esr.rc_candidates
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids2
                          WHERE x_id = rcc_pd);

        DELETE FROM uss_esr.pc_decision pd
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids2
                          WHERE x_id = pd_id); -- 03112022 pd.pd_ap_reason = pd.pd_ap так как удаляются только то что замигрировалось

        DELETE FROM uss_esr.dn_person
              WHERE dnp_dn IN (SELECT dn_id
                                 FROM uss_esr.deduction
                                WHERE EXISTS
                                          (SELECT 1
                                             FROM uss_esr.tmp_work_ids3
                                            WHERE x_id = dn_ap));

        DELETE FROM uss_esr.dn_detail
              WHERE dnd_dn IN (SELECT dn_id
                                 FROM uss_esr.deduction
                                WHERE EXISTS
                                          (SELECT 1
                                             FROM uss_esr.tmp_work_ids3
                                            WHERE x_id = dn_ap));

        DELETE FROM uss_esr.dn_log
              WHERE dnl_dn IN (SELECT dn_id
                                 FROM uss_esr.deduction
                                WHERE EXISTS
                                          (SELECT 1
                                             FROM uss_esr.tmp_work_ids3
                                            WHERE x_id = dn_ap));

        DELETE FROM uss_esr.dn_month_usage
              WHERE dnu_dn IN (SELECT dn_id
                                 FROM uss_esr.deduction
                                WHERE EXISTS
                                          (SELECT 1
                                             FROM uss_esr.tmp_work_ids3
                                            WHERE x_id = dn_ap));

        --!!!!
        --  DELETE FROM uss_esr.ac_detail WHERE acd_ed IN (select ed_id FROM uss_esr.errand WHERE EXISTS (SELECT 1 FROM uss_esr.tmp_work_ids3 WHERE x_id = ed_ap));
        DELETE FROM uss_esr.ac_detail
              WHERE acd_ed IN
                        (SELECT ed_id
                           FROM uss_esr.errand
                          WHERE ed_dn IN
                                    (SELECT dn_id
                                       FROM uss_esr.deduction
                                      WHERE EXISTS
                                                (SELECT 1
                                                   FROM uss_esr.tmp_work_ids3
                                                  WHERE x_id = dn_ap)));

        DELETE FROM uss_esr.ed_log
              WHERE edl_ed IN
                        (SELECT ed_id
                           FROM uss_esr.errand
                          WHERE ed_dn IN
                                    (SELECT dn_id
                                       FROM uss_esr.deduction
                                      WHERE EXISTS
                                                (SELECT 1
                                                   FROM uss_esr.tmp_work_ids3
                                                  WHERE x_id = dn_ap)));

        DELETE FROM uss_esr.ed_detail
              WHERE edd_ed IN
                        (SELECT ed_id
                           FROM uss_esr.errand
                          WHERE ed_dn IN
                                    (SELECT dn_id
                                       FROM uss_esr.deduction
                                      WHERE EXISTS
                                                (SELECT 1
                                                   FROM uss_esr.tmp_work_ids3
                                                  WHERE x_id = dn_ap)));

        DELETE FROM uss_esr.pr_sheet_detail
              WHERE prsd_prs IN
                        (SELECT prs_id
                           FROM uss_esr.pr_sheet
                          WHERE prs_ed IN
                                    (SELECT ed_id
                                       FROM uss_esr.errand
                                      WHERE ed_dn IN
                                                (SELECT dn_id
                                                   FROM uss_esr.deduction
                                                  WHERE EXISTS
                                                            (SELECT 1
                                                               FROM uss_esr.tmp_work_ids3
                                                              WHERE x_id =
                                                                    dn_ap))));

        DELETE FROM uss_esr.pr_sheet
              WHERE prs_ed IN
                        (SELECT ed_id
                           FROM uss_esr.errand
                          WHERE ed_dn IN
                                    (SELECT dn_id
                                       FROM uss_esr.deduction
                                      WHERE EXISTS
                                                (SELECT 1
                                                   FROM uss_esr.tmp_work_ids3
                                                  WHERE x_id = dn_ap)));

        DELETE FROM uss_esr.errand
              WHERE ed_dn IN (SELECT dn_id
                                FROM uss_esr.deduction
                               WHERE EXISTS
                                         (SELECT 1
                                            FROM uss_esr.tmp_work_ids3
                                           WHERE x_id = dn_ap));

        DELETE FROM uss_esr.ac_detail
              WHERE acd_dn IN (SELECT dn_id
                                 FROM uss_esr.deduction
                                WHERE EXISTS
                                          (SELECT 1
                                             FROM uss_esr.tmp_work_ids3
                                            WHERE x_id = dn_ap));

        DELETE FROM uss_esr.deduction
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids3
                          WHERE x_id = dn_ap);

        DELETE FROM uss_esr.ps_log
              WHERE psl_ps IN (SELECT ps_id
                                 FROM uss_esr.pc_state_alimony
                                WHERE EXISTS
                                          (SELECT 1
                                             FROM uss_esr.tmp_work_ids3
                                            WHERE x_id = ps_ap));

        DELETE FROM uss_esr.ps_changes
              WHERE psc_ps IN (SELECT ps_id
                                 FROM uss_esr.pc_state_alimony
                                WHERE EXISTS
                                          (SELECT 1
                                             FROM uss_esr.tmp_work_ids3
                                            WHERE x_id = ps_ap));

        DELETE FROM uss_esr.pc_state_alimony
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids3
                          WHERE x_id = ps_ap);

        DELETE FROM uss_esr.ap_income
              WHERE api_app IN (SELECT app_id
                                  FROM uss_esr.ap_person
                                 WHERE EXISTS
                                           (SELECT 1
                                              FROM uss_esr.tmp_work_ids3
                                             WHERE x_id = app_ap));

        DELETE FROM uss_esr.pd_income_src
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids2
                          WHERE x_id = pis_pd);

        DELETE FROM uss_esr.pd_income_src
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.ap_person
                          WHERE     pis_app = app_id
                                AND EXISTS
                                        (SELECT 1
                                           FROM uss_esr.tmp_work_ids3
                                          WHERE x_id = app_ap));

        DELETE FROM uss_esr.pd_income_detail
              WHERE pid_app IN (SELECT app_id
                                  FROM uss_esr.ap_person
                                 WHERE EXISTS
                                           (SELECT 1
                                              FROM uss_esr.tmp_work_ids3
                                             WHERE x_id = app_ap));

        DELETE FROM uss_esr.ap_person
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids3
                          WHERE x_id = app_ap);

        DELETE FROM uss_esr.pc_location
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.pc_attestat
                          WHERE     pl_pca = pca_id
                                AND EXISTS
                                        (SELECT 1
                                           FROM uss_esr.tmp_work_ids2
                                          WHERE x_id = pca_pd));

        DELETE FROM uss_esr.pca_log
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.pc_attestat
                          WHERE     pcal_pca = pca_id
                                AND EXISTS
                                        (SELECT 1
                                           FROM uss_esr.tmp_work_ids3
                                          WHERE x_id = pca_ap_reason));

        DELETE FROM uss_esr.pc_attestat
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids3
                          WHERE x_id = pca_ap_reason);

        DELETE FROM uss_esr.ps_changes
              WHERE EXISTS
                        (SELECT 1
                           FROM uss_esr.tmp_work_ids3
                          WHERE x_id = psc_ap);

        DELETE FROM uss_esr.appeal
              WHERE     EXISTS
                            (SELECT 1
                               FROM uss_esr.tmp_work_ids3
                              WHERE x_id = ap_id)
                    AND NOT EXISTS
                            (SELECT 1
                               FROM uss_esr.pc_decision
                              WHERE pd_ap = ap_id);


        BEGIN
            FOR xx
                IN (    SELECT ADD_MONTHS (TO_DATE ('01.01.2014', 'DD.MM.YYYY'),
                                           LEVEL - 1)    AS dt
                          FROM DUAL
                    CONNECT BY LEVEL <= 112)
            LOOP
                DELETE FROM uss_esr.tmp_work_ids1
                      WHERE 1 = 1;

                INSERT INTO uss_esr.tmp_work_ids1 (x_id)
                    SELECT ac_id                       --, trunc(rownum/10000)
                      FROM uss_esr.accrual, uss_esr.personalcase pc
                     WHERE     ac_month = xx.dt
                           AND pc_id = ac_pc
                           AND pc.com_org IN (SELECT org_id
                                                FROM ikis_sys.opfu
                                               WHERE org_id = p_org);

                --dbms_output.put_line(to_char(sysdate, 'DD.MM.YYYY HH24:MI:SS')||': '||to_char(xx.dt, 'DD.MM.YYYY')||' - starting '||sql%rowcount);

                uss_esr.api$accrual.actuilize_payed_sum (1);
            --dbms_output.put_line(to_char(sysdate, 'DD.MM.YYYY HH24:MI:SS')||': '||to_char(xx.dt, 'DD.MM.YYYY')||' - end.');
            --    commit;
            END LOOP;
        END;

        UPDATE uss_esr.accrual ac
           SET ac_st = 'E'
         WHERE     com_org IN (SELECT org_id
                                 FROM ikis_sys.opfu
                                WHERE org_id = p_org)
               AND EXISTS
                       (SELECT 1
                          FROM uss_esr.billing_period
                         WHERE     bp_class = 'V'
                               AND bp_st = 'R'
                               AND bp_month = ac_month
                               AND bp_org = ac.com_org)
               AND ac_st <> 'E';

        UPDATE uss_esr.accrual ac
           SET ac_st = 'R'
         WHERE     com_org IN (SELECT org_id
                                 FROM ikis_sys.opfu
                                WHERE org_id = p_org)
               AND NOT EXISTS
                       (SELECT 1
                          FROM uss_esr.billing_period
                         WHERE     bp_class = 'V'
                               AND bp_st = 'R'
                               AND bp_month = ac_month
                               AND bp_org = ac.com_org)
               AND ac_st <> 'R';

        DELETE FROM uss_esr.ac_log
              WHERE acl_ac IN
                        (SELECT ac_id
                           FROM uss_esr.accrual ac
                          WHERE     com_org IN (SELECT org_id
                                                  FROM ikis_sys.opfu
                                                 WHERE org_id = p_org)
                                AND ac_month >
                                    (SELECT MAX (bp_month)
                                       FROM uss_esr.billing_period
                                      WHERE     bp_st = 'R'
                                            AND bp_org = ac.com_org));

        UPDATE uss_esr.pco_detail
           SET pcod_fix_acd = NULL
         WHERE pcod_fix_acd IN
                   (SELECT acd_id
                      FROM uss_esr.ac_detail
                     WHERE acd_ac IN
                               (SELECT ac_id
                                  FROM uss_esr.accrual ac
                                 WHERE     com_org IN (SELECT org_id
                                                         FROM ikis_sys.opfu
                                                        WHERE org_id = p_org)
                                       AND ac_month >
                                           (SELECT MAX (bp_month)
                                              FROM uss_esr.billing_period
                                             WHERE     bp_st = 'R'
                                                   AND bp_org = ac.com_org)));

        DELETE FROM uss_esr.ac_detail
              WHERE acd_prsd IN
                        (SELECT prsd_id
                           FROM uss_esr.pr_sheet_detail
                          WHERE EXISTS
                                    (SELECT 1
                                       FROM uss_esr.pr_sheet
                                      WHERE     prsd_prs = prs_id
                                            AND EXISTS
                                                    (SELECT 1
                                                       FROM uss_esr.payroll
                                                      WHERE     pr_npc <> 24
                                                            AND prs_pr =
                                                                pr_id
                                                            AND com_org IN
                                                                    (SELECT org_id
                                                                       FROM ikis_sys.opfu
                                                                      WHERE org_id =
                                                                            p_org))));

        /*
          delete from uss_esr.ac_detail where acd_ac in (select ac_id
            FROM uss_esr.accrual ac
            where com_org IN (select org_id FROM ikis_sys.opfu WHERE org_id = p_org)
              and ac_month > (select MAX(bp_month) from uss_esr.billing_period where bp_st = 'R' and bp_org = ac.com_org ))
              and acd_prsd is null;

          DELETE
            FROM uss_esr.accrual ac
            where com_org IN (select org_id FROM ikis_sys.opfu WHERE org_id = p_org)
              and ac_month > (select MAX(bp_month) from uss_esr.billing_period where bp_st = 'R' and bp_org = ac.com_org )
              and not exists (select 1 from uss_esr.ac_detail where acd_ac = ac_id);
        */
        COMMIT;

        DBMS_OUTPUT.put_line (
               TO_CHAR (SYSDATE, 'DD.MM.YYYY HH24:MI:SS')
            || ': Завершено очистку рішень');
    END;
BEGIN
    NULL;
END api$clean_test;
/