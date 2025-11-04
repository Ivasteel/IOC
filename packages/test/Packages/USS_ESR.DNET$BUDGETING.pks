/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$BUDGETING
IS
    -- Author  : BOGDAN
    -- Created : 17.11.2021 16:56:22
    -- Purpose : Бюджетування

    Package_Name   VARCHAR2 (20) := 'DNET$BUDGETING';

    TYPE r_detail IS RECORD
    (
        Frs_Nst               fr_detail_service.frs_nst%TYPE,
        Com_Org               funding_request.com_org%TYPE,
        Qnt_Edit              fr_detail_service.frs_value%TYPE,
        Bank_Sum_Edit         fr_detail_service.frs_value%TYPE,
        Post_Sum_Edit         fr_detail_service.frs_value%TYPE,
        Post_Cost_Sum_Edit    fr_detail_service.frs_value%TYPE
    );

    TYPE t_detail IS TABLE OF r_detail;

    -- Журнал Потреб
    PROCEDURE GET_FUNDING_REQUEST_LIST (P_FR_MONTH     IN     DATE,
                                        P_FR_TP        IN     VARCHAR2,
                                        P_FR_OWN_TP    IN     VARCHAR2,
                                        P_FR_DOC_NUM   IN     VARCHAR2,
                                        P_FR_NBG       IN     NUMBER,
                                        RES_CUR           OUT SYS_REFCURSOR);


    -- Ініціалізація Потреб
    PROCEDURE INIT_FUNDING_REQUEST (P_FR_MONTH   IN     DATE,
                                    P_FR_TP      IN     VARCHAR2,
                                    P_FR_NBG     IN     NUMBER,
                                    P_FR_ID         OUT NUMBER);

    -- #73227: Підтвердити:
    -- для документів з fr_own_tp='OWN' та fr_st = Редагується це означає: після зміни статусу на fr_st = Затверджено,
    --     створити/оновити копію документу на вищому рівні (fr_fr_cons) з типом fr_own_tp = 'CONS' з статусом fr_st = Передано;
    -- для документів з fr_own_tp='CONS' та fr_st = Передано це означає: зміну статусу на fr_st = Підтверджено;
    PROCEDURE PROVE_FUND_REQUEST (P_FR_ID IN NUMBER);

    -- #73227: Відхилити:
    -- для документів з fr_own_tp='OWN' та fr_st = Затверджено це означає: зміну статусу на fr_st = Редагується, але тільки за умови,
    --      якщо документ, який вказано в fr_fr_cons - знаходиться в статусі Передано або Відхилено;
    -- для документів з fr_own_tp='CONS' та fr_st = Передано це означає: зміну статусу на fr_st = Відхилено;
    PROCEDURE REJECT_FUND_REQUEST (P_FR_ID IN NUMBER);


    -- вичитка картки потреби
    PROCEDURE GET_FR_CARD (P_FR_ID     IN     NUMBER,
                           RES_CUR        OUT SYS_REFCURSOR,
                           GROUP_CUR      OUT SYS_REFCURSOR);

    -- збереження картки потреби
    PROCEDURE SAVE_CARD (P_FR_ID IN NUMBER, P_XML IN CLOB);

    -- видалення картки потреби
    PROCEDURE delete_card (P_FR_ID IN NUMBER);
END DNET$BUDGETING;
/


GRANT EXECUTE ON USS_ESR.DNET$BUDGETING TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$BUDGETING TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:29 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$BUDGETING
IS
    ------------------------------------------------------------------------
    --------------------------- Потреби в коштах ---------------------------

    -- Журнал Потреб
    PROCEDURE GET_FUNDING_REQUEST_LIST (P_FR_MONTH     IN     DATE,
                                        P_FR_TP        IN     VARCHAR2,
                                        P_FR_OWN_TP    IN     VARCHAR2,
                                        P_FR_DOC_NUM   IN     VARCHAR2,
                                        P_FR_NBG       IN     NUMBER,
                                        RES_CUR           OUT SYS_REFCURSOR)
    IS
        --l_org NUMBER := tools.getcurrorg;
        l_sql   VARCHAR2 (10000)
            :=    'SELECT t.*,
                                     st.dic_sname AS fr_st_name,
                                     stc.dic_sname AS fr_fr_st_name,
                                     ''№'' || t.fr_doc_num || '' від '' || to_char(t.fr_doc_dt, ''DD.MM.YYYY'') as Fr_Doc_Dt_Num,
                                     hs.hs_dt as hs_ins_dt,
                                     nvl(t.fr_bank_sum, 0) +  nvl(t.fr_post_sum, 0) +  nvl(t.fr_post_cost_sum, 0) as fr_summary_sum
                                FROM v_funding_request t
                                JOIN uss_ndi.v_ddn_fr_st st ON (st.dic_value = t.fr_st)
                                join histsession hs on (hs.hs_id = t.fr_hs_ins)
                                LEFT JOIN v_funding_request fr ON (t.fr_fr_cons = fr.fr_id)
                                LEFT JOIN uss_ndi.v_ddn_fr_st stc ON (stc.dic_value = fr.fr_st)
                               WHERE 1 = 1
                                 AND t.fr_own_tp = '''
               || P_FR_OWN_TP
               || '''
                                 ';
    --l_mfo VARCHAR2(10);
    BEGIN
        tools.WriteMsg ('DNET$BUDGETING.' || $$PLSQL_UNIT);

        TOOLS.validate_param (P_FR_TP);
        TOOLS.validate_param (P_FR_OWN_TP);
        TOOLS.validate_param (P_FR_DOC_NUM);

        IF (P_FR_MONTH IS NOT NULL)
        THEN
            l_sql :=
                   l_sql
                || ' and t.fr_month = to_date('''
                || TO_CHAR (P_FR_MONTH, 'DD.MM.YYYY')
                || ''', ''DD.MM.YYYY'')';
        END IF;

        IF (P_FR_DOC_NUM IS NOT NULL)
        THEN
            l_sql :=
                l_sql || ' and t.fr_doc_num = ''' || P_FR_DOC_NUM || '''';
        END IF;

        IF (P_FR_TP IS NOT NULL)
        THEN
            l_sql := l_sql || ' and t.fr_tp = ''' || P_FR_TP || '''';
        END IF;

        IF (P_FR_NBG IS NOT NULL)
        THEN
            l_sql := l_sql || ' and t.fr_nbg = ' || P_FR_NBG;
        END IF;

        --raise_application_error(-20000, l_sql);
        OPEN res_cur FOR l_sql || ' ORDER by hs.hs_dt desc';
    END;

    -- Ініціалізація Потреб
    PROCEDURE INIT_FUNDING_REQUEST (P_FR_MONTH   IN     DATE,
                                    P_FR_TP      IN     VARCHAR2,
                                    P_FR_NBG     IN     NUMBER,
                                    P_FR_ID         OUT NUMBER)
    IS
        --l_cnt NUMBER;
        l_fr_st              VARCHAR2 (10);
        l_org                NUMBER := tools.getcurrorg;
        l_org_to             NUMBER;
        l_org_org            NUMBER;
        l_hs                 NUMBER := tools.GetHistSession;

        l_frs_id             NUMBER;
        l_fr_recipient_qnt   NUMBER := 0;
        l_fr_bank_sum        NUMBER := 0;
        l_fr_post_sum        NUMBER := 0;
        l_fr_post_cost_sum   NUMBER := 0;

        l_k2240              NUMBER;
        l_k2730              NUMBER;

        PROCEDURE SEED_FULL
        IS
        BEGIN
            FOR xx
                IN ( /*SELECT pa.pa_nst,
                            COUNT(DISTINCT t.prs_pc_num) AS qnt,
                            SUM(CASE WHEN pc.npc_nkv = l_k2730 AND t.prs_tp = 'PB' THEN t.prs_sum END) AS bank_sum,
                            SUM(CASE WHEN pc.npc_nkv = l_k2730 AND t.prs_tp = 'PP' THEN t.prs_sum END) AS post_sum,
                            SUM(CASE WHEN pc.npc_nkv = l_k2240 THEN t.prs_sum END) AS post_cost_sum
                       FROM v_payroll p
                       JOIN v_pr_sheet t ON (t.prs_pr = p.pr_id)
                       JOIN v_pc_account pa ON (pa.pa_id = t.prs_pa)
                       JOIN uss_ndi.v_ndi_payment_type pt ON (pt.npt_id = t.prs_npt)
                       JOIN uss_ndi.v_ndi_payment_codes pc ON (pc.npc_id = pt.npt_npc)
                       JOIN uss_ndi.v_ndi_payment_codes pc ON pc.npc_id = p.pr_npc
                      WHERE 1 = 1
                        AND pt.npt_nbg = p_fr_nbg
                        AND pt.history_status = 'A'
                        AND p.com_org = l_org
                        AND p.pr_month = p_fr_month
                        AND p.pr_tp = CASE WHEN p_fr_tp = 'MAIN' THEN 'M' ELSE 'A' END
                        AND t.prs_tp IN ('PP', 'PB')
                      GROUP BY pa.pa_nst*/
                                     --#85222 LEV виконано перехід на prsd_npt
                     SELECT pa.pa_nst,
                            COUNT (DISTINCT t.prs_pc_num)    AS qnt,
                            SUM (
                                CASE
                                    WHEN     pc.npc_nkv = l_k2730
                                         AND t.prs_tp = 'PB'
                                    THEN
                                        (CASE
                                             WHEN sd.prsd_tp IN
                                                      ('PWI', 'RDN')
                                             THEN
                                                 sd.prsd_sum
                                             WHEN sd.prsd_tp IN ('PRUT',
                                                                 'PRAL',
                                                                 'PROZ',
                                                                 'PROP')
                                             THEN
                                                 0 - sd.prsd_sum
                                         END)
                                END)                         AS bank_sum,
                            SUM (
                                CASE
                                    WHEN     pc.npc_nkv = l_k2730
                                         AND t.prs_tp = 'PP'
                                    THEN
                                        (CASE
                                             WHEN sd.prsd_tp IN
                                                      ('PWI', 'RDN')
                                             THEN
                                                 sd.prsd_sum
                                             WHEN sd.prsd_tp IN ('PRUT',
                                                                 'PRAL',
                                                                 'PROZ',
                                                                 'PROP')
                                             THEN
                                                 0 - sd.prsd_sum
                                         END)
                                END)                         AS post_sum,
                            SUM (
                                CASE
                                    WHEN pc.npc_nkv = l_k2240
                                    THEN
                                        (CASE
                                             WHEN sd.prsd_tp IN
                                                      ('PWI', 'RDN')
                                             THEN
                                                 sd.prsd_sum
                                             WHEN sd.prsd_tp IN ('PRUT',
                                                                 'PRAL',
                                                                 'PROZ',
                                                                 'PROP')
                                             THEN
                                                 0 - sd.prsd_sum
                                         END)
                                END)                         AS post_cost_sum
                       FROM v_payroll p
                            JOIN v_pr_sheet t
                                ON     t.prs_pr = p.pr_id
                                   AND t.prs_tp IN ('PP', 'PB')
                            JOIN v_pc_account pa ON pa.pa_id = t.prs_pa
                            JOIN v_pr_sheet_detail sd ON sd.prsd_prs = t.prs_id
                            JOIN uss_ndi.v_ndi_payment_type pt
                                ON     pt.npt_id = sd.prsd_npt
                                   AND pt.npt_nbg = p_fr_nbg
                                   AND pt.history_status = 'A'
                            JOIN uss_ndi.v_ndi_payment_codes pc
                                ON pc.npc_id = pt.npt_npc
                      WHERE     p.com_org = l_org
                            AND p.pr_month = p_fr_month
                            AND p.pr_tp =
                                (CASE
                                     WHEN p_fr_tp = 'MAIN' THEN 'M'
                                     ELSE 'A'
                                 END)
                   GROUP BY pa.pa_nst)
            LOOP
                l_fr_post_sum := l_fr_post_sum + NVL (xx.post_sum, 0);
                l_fr_bank_sum := l_fr_bank_sum + NVL (xx.bank_sum, 0);
                l_fr_post_cost_sum :=
                    l_fr_post_cost_sum + NVL (xx.post_cost_sum, 0);
                l_fr_recipient_qnt := l_fr_recipient_qnt + NVL (xx.qnt, 0);

                -- кількість
                INSERT INTO FR_DETAIL_SERVICE (FRS_FR,
                                               FRS_NST,
                                               FRS_VALUE,
                                               FRS_PAY_TP,
                                               FRS_NKV,
                                               FRS_VALUE_TP)
                     VALUES (p_fr_id,
                             xx.pa_nst,
                             xx.qnt,
                             NULL,
                             NULL,
                             'QNT'                                       -- hz
                                  )
                  RETURNING FRS_ID
                       INTO l_frs_id;

                FOR yy
                    IN ( /*SELECT  t.prs_nb,
                                 t.prs_npt,
                                 COUNT(DISTINCT t.prs_pc_num) AS qnt
                            FROM v_payroll p
                            JOIN v_pr_sheet t ON (t.prs_pr = p.pr_id)
                            JOIN v_pc_account pa ON (pa.pa_id = t.prs_pa)
                            JOIN uss_ndi.v_ndi_payment_type pt ON (pt.npt_id = t.prs_npt)
                            JOIN uss_ndi.v_ndi_payment_codes pc ON (pc.npc_id = pt.npt_npc)
                            --JOIN uss_ndi.v_ndi_kekv k ON (k.nkv_id = pc.npc_nkv)
                           WHERE 1 = 1
                             AND pt.npt_nbg = p_fr_nbg
                             AND pt.history_status = 'A'
                             AND p.com_org = l_org
                             AND p.pr_month = p_fr_month
                             AND p.pr_tp = CASE WHEN p_fr_tp = 'MAIN' THEN 'M' ELSE 'A' END
                             --AND t.prs_tp = xx.prs_tp
                             --AND k.nkv_id = xx.nkv_id
                             AND pa.pa_nst = xx.pa_nst
                           GROUP BY t.prs_nb, t.prs_npt*/
                                     --#85222 LEV виконано перехід на prsd_npt
                         SELECT t.prs_nb,
                                pt.npt_id,
                                COUNT (DISTINCT t.prs_pc_num)     AS qnt
                           FROM v_payroll p
                                JOIN v_pr_sheet t ON t.prs_pr = p.pr_id
                                JOIN v_pc_account pa
                                    ON     pa.pa_id = t.prs_pa
                                       AND pa.pa_nst = xx.pa_nst
                                JOIN v_pr_sheet_detail sd
                                    ON sd.prsd_prs = t.prs_id
                                JOIN uss_ndi.v_ndi_payment_type pt
                                    ON     pt.npt_id = sd.prsd_npt
                                       AND pt.npt_nbg = p_fr_nbg
                                       AND pt.history_status = 'A'
                                JOIN uss_ndi.v_ndi_payment_codes pc
                                    ON pc.npc_id = pt.npt_npc
                          WHERE     p.com_org = l_org
                                AND p.pr_month = p_fr_month
                                AND p.pr_tp =
                                    (CASE
                                         WHEN p_fr_tp = 'MAIN' THEN 'M'
                                         ELSE 'A'
                                     END)
                       GROUP BY t.prs_nb, pt.npt_id)
                LOOP
                    INSERT INTO FR_DETAIL_FULL (FRF_FR,
                                                FRF_FRS,
                                                FRF_NKV,
                                                FRF_VALUE,
                                                FRF_NB,
                                                FRF_PAY_TP,
                                                FRS_NPT,
                                                FRF_VALUE_TP)
                         VALUES (P_FR_ID,
                                 l_frs_id,
                                 NULL,
                                 yy.qnt,
                                 yy.prs_nb,
                                 NULL,
                                 /*yy.prs_npt*/
                                 yy.npt_id,
                                 'QNT');
                END LOOP;

                -- сума по банку
                INSERT INTO FR_DETAIL_SERVICE (FRS_FR,
                                               FRS_NST,
                                               FRS_VALUE,
                                               FRS_PAY_TP,
                                               FRS_NKV,
                                               FRS_VALUE_TP)
                     VALUES (p_fr_id,
                             xx.pa_nst,
                             xx.bank_sum,
                             'PB',
                             l_k2730,
                             'BSA'                                       -- hz
                                  )
                  RETURNING FRS_ID
                       INTO l_frs_id;

                FOR yy
                    IN ( /*SELECT  t.prs_nb,
                                 t.prs_npt,
                                 SUM(t.prs_sum) AS bank_sum
                            FROM v_payroll p
                            JOIN v_pr_sheet t ON (t.prs_pr = p.pr_id)
                            JOIN v_pc_account pa ON (pa.pa_id = t.prs_pa)
                            JOIN uss_ndi.v_ndi_payment_type pt ON (pt.npt_id = t.prs_npt)
                            JOIN uss_ndi.v_ndi_payment_codes pc ON (pc.npc_id = pt.npt_npc)
                           WHERE 1 = 1
                             AND pt.npt_nbg = p_fr_nbg
                             AND pt.history_status = 'A'
                             AND p.com_org = l_org
                             AND p.pr_month = p_fr_month
                             AND p.pr_tp = CASE WHEN p_fr_tp = 'MAIN' THEN 'M' ELSE 'A' END
                             --AND t.prs_tp = xx.prs_tp
                             AND pc.npc_nkv = l_k2730
                              AND t.prs_tp = 'PB'
                             AND pa.pa_nst = xx.pa_nst
                           GROUP BY t.prs_nb, t.prs_npt*/
                          --#85222 LEV виконано перехід на prsd_npt
                          SELECT t.prs_nb,
                                 pt.npt_id,
                                 SUM (CASE
                                          WHEN sd.prsd_tp IN ('PWI', 'RDN')
                                          THEN
                                              sd.prsd_sum
                                          WHEN sd.prsd_tp IN ('PRUT',
                                                              'PRAL',
                                                              'PROZ',
                                                              'PROP')
                                          THEN
                                              0 - sd.prsd_sum
                                      END)    AS bank_sum
                            FROM v_payroll p
                                 JOIN v_pr_sheet t
                                     ON t.prs_pr = p.pr_id AND t.prs_tp = 'PB'
                                 JOIN v_pc_account pa
                                     ON     pa.pa_id = t.prs_pa
                                        AND pa.pa_nst = xx.pa_nst
                                 JOIN v_pr_sheet_detail sd
                                     ON sd.prsd_prs = t.prs_id
                                 JOIN uss_ndi.v_ndi_payment_type pt
                                     ON     pt.npt_id = sd.prsd_npt
                                        AND pt.npt_nbg = p_fr_nbg
                                        AND pt.history_status = 'A'
                                 JOIN uss_ndi.v_ndi_payment_codes pc
                                     ON     pc.npc_id = pt.npt_npc
                                        AND pc.npc_nkv = l_k2730
                           WHERE     p.com_org = l_org
                                 AND p.pr_month = p_fr_month
                                 AND p.pr_tp =
                                     (CASE
                                          WHEN p_fr_tp = 'MAIN' THEN 'M'
                                          ELSE 'A'
                                      END)
                        GROUP BY t.prs_nb, pt.npt_id)
                LOOP
                    INSERT INTO FR_DETAIL_FULL (FRF_FR,
                                                FRF_FRS,
                                                FRF_NKV,
                                                FRF_VALUE,
                                                FRF_NB,
                                                FRF_PAY_TP,
                                                FRS_NPT,
                                                FRF_VALUE_TP)
                         VALUES (P_FR_ID,
                                 l_frs_id,
                                 l_k2730,
                                 yy.bank_sum,
                                 yy.prs_nb,
                                 'PB',
                                 /*yy.prs_npt*/
                                 yy.npt_id,
                                 'BSA');
                END LOOP;

                -- сума по пошті
                INSERT INTO FR_DETAIL_SERVICE (FRS_FR,
                                               FRS_NST,
                                               FRS_VALUE,
                                               FRS_PAY_TP,
                                               FRS_NKV,
                                               FRS_VALUE_TP)
                     VALUES (p_fr_id,
                             xx.pa_nst,
                             xx.post_sum,
                             'PP',
                             l_k2730,
                             'PSA'                                       -- hz
                                  )
                  RETURNING FRS_ID
                       INTO l_frs_id;

                FOR yy
                    IN ( /*SELECT  t.prs_nb,
                                 t.prs_npt,
                                 SUM(t.prs_sum) AS bank_sum
                            FROM v_payroll p
                            JOIN v_pr_sheet t ON (t.prs_pr = p.pr_id)
                            JOIN v_pc_account pa ON (pa.pa_id = t.prs_pa)
                            JOIN uss_ndi.v_ndi_payment_type pt ON (pt.npt_id = t.prs_npt)
                            JOIN uss_ndi.v_ndi_payment_codes pc ON (pc.npc_id = pt.npt_npc)
                           WHERE 1 = 1
                             AND pt.npt_nbg = p_fr_nbg
                             AND pt.history_status = 'A'
                             AND p.com_org = l_org
                             AND p.pr_month = p_fr_month
                             AND p.pr_tp = CASE WHEN p_fr_tp = 'MAIN' THEN 'M' ELSE 'A' END
                            -- AND t.prs_tp = xx.prs_tp
                             AND pc.npc_nkv = l_k2730
                              AND t.prs_tp = 'PP'
                             AND pa.pa_nst = xx.pa_nst
                           GROUP BY t.prs_nb, t.prs_npt*/
                          --#85222 LEV виконано перехід на prsd_npt
                          SELECT t.prs_nb,
                                 pt.npt_id,
                                 SUM (CASE
                                          WHEN sd.prsd_tp IN ('PWI', 'RDN')
                                          THEN
                                              sd.prsd_sum
                                          WHEN sd.prsd_tp IN ('PRUT',
                                                              'PRAL',
                                                              'PROZ',
                                                              'PROP')
                                          THEN
                                              0 - sd.prsd_sum
                                      END)    AS bank_sum
                            FROM v_payroll p
                                 JOIN v_pr_sheet t
                                     ON t.prs_pr = p.pr_id AND t.prs_tp = 'PP'
                                 JOIN v_pc_account pa
                                     ON     pa.pa_id = t.prs_pa
                                        AND pa.pa_nst = xx.pa_nst
                                 JOIN v_pr_sheet_detail sd
                                     ON sd.prsd_prs = t.prs_id
                                 JOIN uss_ndi.v_ndi_payment_type pt
                                     ON     pt.npt_id = sd.prsd_npt
                                        AND pt.npt_nbg = p_fr_nbg
                                        AND pt.history_status = 'A'
                                 JOIN uss_ndi.v_ndi_payment_codes pc
                                     ON     pc.npc_id = pt.npt_npc
                                        AND pc.npc_nkv = l_k2730
                           WHERE     p.com_org = l_org
                                 AND p.pr_month = p_fr_month
                                 AND p.pr_tp =
                                     (CASE
                                          WHEN p_fr_tp = 'MAIN' THEN 'M'
                                          ELSE 'A'
                                      END)
                        GROUP BY t.prs_nb, pt.npt_id)
                LOOP
                    INSERT INTO FR_DETAIL_FULL (FRF_FR,
                                                FRF_FRS,
                                                FRF_NKV,
                                                FRF_VALUE,
                                                FRF_NB,
                                                FRF_PAY_TP,
                                                FRS_NPT,
                                                FRF_VALUE_TP)
                         VALUES (P_FR_ID,
                                 l_frs_id,
                                 l_k2730,
                                 yy.bank_sum,
                                 yy.prs_nb,
                                 'PP',
                                 /*yy.prs_npt*/
                                 yy.npt_id,
                                 'PSA');
                END LOOP;

                -- сума витрат пересилки по пошті
                INSERT INTO FR_DETAIL_SERVICE (FRS_FR,
                                               FRS_NST,
                                               FRS_VALUE,
                                               FRS_PAY_TP,
                                               FRS_NKV,
                                               FRS_VALUE_TP)
                     VALUES (p_fr_id,
                             xx.pa_nst,
                             xx.post_cost_sum,
                             'PP',
                             l_k2240,
                             'PSV'                                       -- hz
                                  )
                  RETURNING FRS_ID
                       INTO l_frs_id;

                FOR yy
                    IN ( /*SELECT  t.prs_nb,
                                 t.prs_npt,
                                 SUM(t.prs_sum) AS bank_sum
                            FROM v_payroll p
                            JOIN v_pr_sheet t ON (t.prs_pr = p.pr_id)
                            JOIN v_pc_account pa ON (pa.pa_id = t.prs_pa)
                            JOIN uss_ndi.v_ndi_payment_type pt ON (pt.npt_id = t.prs_npt)
                            JOIN uss_ndi.v_ndi_payment_codes pc ON (pc.npc_id = pt.npt_npc)
                           WHERE 1 = 1
                             AND pt.npt_nbg = p_fr_nbg
                             AND pt.history_status = 'A'
                             AND p.com_org = l_org
                             AND p.pr_month = p_fr_month
                             AND p.pr_tp = CASE WHEN p_fr_tp = 'MAIN' THEN 'M' ELSE 'A' END
                             --AND t.prs_tp = xx.prs_tp
                             AND pc.npc_nkv = l_k2240
                             --AND t.prs_tp = 'PP'
                             AND pa.pa_nst = xx.pa_nst
                           GROUP BY t.prs_nb, t.prs_npt*/
                          --#85222 LEV виконано перехід на prsd_npt
                          SELECT t.prs_nb,
                                 pt.npt_id,
                                 SUM (CASE
                                          WHEN sd.prsd_tp IN ('PWI', 'RDN')
                                          THEN
                                              sd.prsd_sum
                                          WHEN sd.prsd_tp IN ('PRUT',
                                                              'PRAL',
                                                              'PROZ',
                                                              'PROP')
                                          THEN
                                              0 - sd.prsd_sum
                                      END)    AS bank_sum
                            FROM v_payroll p
                                 JOIN v_pr_sheet t ON t.prs_pr = p.pr_id
                                 JOIN v_pc_account pa
                                     ON     pa.pa_id = t.prs_pa
                                        AND pa.pa_nst = xx.pa_nst
                                 JOIN v_pr_sheet_detail sd
                                     ON sd.prsd_prs = t.prs_id
                                 JOIN uss_ndi.v_ndi_payment_type pt
                                     ON     pt.npt_id = sd.prsd_npt
                                        AND pt.npt_nbg = p_fr_nbg
                                        AND pt.history_status = 'A'
                                 JOIN uss_ndi.v_ndi_payment_codes pc
                                     ON     pc.npc_id = pt.npt_npc
                                        AND pc.npc_nkv = l_k2240
                           WHERE     p.com_org = l_org
                                 AND p.pr_month = p_fr_month
                                 AND p.pr_tp =
                                     (CASE
                                          WHEN p_fr_tp = 'MAIN' THEN 'M'
                                          ELSE 'A'
                                      END)
                        GROUP BY t.prs_nb, pt.npt_id)
                LOOP
                    INSERT INTO FR_DETAIL_FULL (FRF_FR,
                                                FRF_FRS,
                                                FRF_NKV,
                                                FRF_VALUE,
                                                FRF_NB,
                                                FRF_PAY_TP,
                                                FRS_NPT,
                                                FRF_VALUE_TP)
                         VALUES (P_FR_ID,
                                 l_frs_id,
                                 l_k2240,
                                 yy.bank_sum,
                                 yy.prs_nb,
                                 NULL,
                                 /*yy.prs_npt*/
                                 yy.npt_id,
                                 'PSV');
                END LOOP;
            /*Показник, в залежності від frs_value_tp
            QNT - кількість одержувачів;
            BSA - сума по банку;
            BSV - комісія банку;
            PSA - сума по пошті;
            PSV - поштові витрати;*/


            -- fr_detail_full: frs_id, nkv_id (npc_nkv), npt_id
            /*FOR yy IN (SELECT  t.prs_nb,
                               t.prs_npt,
                               COUNT(DISTINCT t.prs_pc_num) AS qnt
                          FROM v_payroll p
                          JOIN v_pr_sheet t ON (t.prs_pr = p.pr_id)
                          JOIN v_pc_account pa ON (pa.pa_id = t.prs_pa)
                          JOIN uss_ndi.v_ndi_payment_type pt ON (pt.npt_id = t.prs_npt)
                          JOIN uss_ndi.v_ndi_payment_codes pc ON (pc.npc_id = pt.npt_npc)
                          JOIN uss_ndi.v_ndi_kekv k ON (k.nkv_id = pc.npc_nkv)
                         WHERE 1 = 1
                           AND pt.npt_nbg = p_fr_nbg
                           AND pt.history_status = 'A'
                           AND p.com_org = l_org
                           AND t.prs_tp = xx.prs_tp
                           AND k.nkv_id = xx.nkv_id
                           AND pa.pa_nst = xx.pa_nst
                         GROUP BY t.prs_nb,t.prs_npt)
            LOOP
              insert into FR_DETAIL_FULL
                ( FRF_FR,
                  FRF_FRS,
                  FRF_NKV,
                  FRF_VALUE,
                  FRF_NB,
                  FRF_PAY_TP,
                  FRS_NPT,
                  FRF_VALUE_TP
                )
               values
                ( P_FR_ID,
                  l_frs_id,
                  xx.nkv_id,
                  yy.qnt,
                  yy.prs_nb,
                  xx.prs_tp,
                  yy.prs_npt,
                  '1.0'
                );

            END LOOP;*/
            END LOOP;
        END;

        PROCEDURE SEED_BY_CONS
        IS
        --l_cnt NUMBER;
        BEGIN
            --raise_application_error(-20000, 'l_org='||l_org||';p_fr_month='||p_fr_month||';p_fr_tp='||p_fr_tp);
            -- не хватает разреза по опфу по услугам для еще не созданных документов
            FOR xx
                IN (  SELECT t.frs_nst,
                             op.org_id            AS fr_org,
                             SUM (t.frs_value)    AS frs_value,
                             t.frs_pay_tp,
                             t.frs_value_tp,
                             CASE
                                 WHEN t.frs_value_tp IN ('BSA', 'PSA')
                                 THEN
                                     l_k2730
                                 WHEN t.frs_value_tp IN ('PSV')
                                 THEN
                                     l_k2240
                             END                  AS kekv
                        FROM v_opfu op
                             JOIN funding_request fr
                                 ON (    fr.fr_org = op.org_id
                                     AND fr.fr_own_tp = 'CONS'
                                     AND fr.com_org = l_org
                                     AND fr.fr_month = p_fr_month
                                     AND fr.fr_tp = p_fr_tp
                                     AND fr.fr_st = 'R')
                             JOIN fr_detail_service t ON (t.frs_fr = fr.fr_id)
                       WHERE     op.org_org = l_org
                             AND op.org_st = 'A'
                             AND op.org_to IN (30, 31, 32)
                    GROUP BY t.frs_nst,
                             op.org_id,
                             t.frs_pay_tp,
                             t.frs_value_tp)
            LOOP
                IF (xx.frs_value_tp = 'QNT')
                THEN
                    l_fr_recipient_qnt :=
                        l_fr_recipient_qnt + NVL (xx.frs_Value, 0);
                ELSIF (xx.frs_value_tp = 'BSA')
                THEN
                    l_fr_bank_sum := l_fr_bank_sum + NVL (xx.frs_Value, 0);
                ELSIF (xx.frs_value_tp = 'PSA')
                THEN
                    l_fr_post_sum := l_fr_post_sum + NVL (xx.frs_Value, 0);
                ELSIF (xx.frs_value_tp = 'PSV')
                THEN
                    l_fr_post_cost_sum :=
                        l_fr_post_cost_sum + NVL (xx.frs_Value, 0);
                END IF;

                INSERT INTO FR_DETAIL_SERVICE (FRS_FR,
                                               FRS_NST,
                                               FRS_ORG,
                                               FRS_VALUE,
                                               FRS_PAY_TP,
                                               FRS_NKV,
                                               FRS_VALUE_TP)
                     VALUES (p_fr_id,
                             xx.frs_nst,
                             xx.fr_org,
                             xx.frs_value,
                             xx.frs_pay_tp,
                             xx.kekv,
                             xx.frs_value_tp);
            END LOOP;
        END;
    BEGIN
        SELECT MAX (t.fr_id), MAX (t.fr_st)
          INTO p_fr_id, l_fr_st
          FROM v_funding_request t
         --LEFT JOIN funding_request q ON (q.fr_id = t.fr_fr_cons)
         WHERE     t.fr_month = p_fr_month
               AND t.fr_tp = p_fr_tp
               AND t.fr_nbg = p_fr_nbg
               AND t.fr_own_tp = 'OWN';

        --raise_application_error(-20000, 'p_fr_month='||p_fr_month||';p_fr_nbg='||p_fr_nbg||';l_fr_st='||l_fr_st||';p_fr_id='||p_fr_id);

        IF (P_FR_TP = 'MAIN' AND l_fr_st IS NOT NULL AND l_fr_st = 'Z')
        THEN
            --l_fr_id := NULL;
            --raise_application_error(-20000, 'Ініціалізація по типу "основна" може виконуватись тільки 1 на 1 місяць');
            raise_application_error (
                -20000,
                'Перезапис документу в стані "Підтверджено" не дозволено. Поверніть документ на редагування!');
        ELSIF (P_FR_TP = 'ADD')
        THEN
            p_fr_id := NULL;
        END IF;

        SELECT (SELECT t.nkv_id
                  FROM uss_ndi.v_ndi_kekv t
                 WHERE t.nkv_code = '2240'),
               (SELECT t.nkv_id
                  FROM uss_ndi.v_ndi_kekv t
                 WHERE t.nkv_code = '2730')
          INTO l_k2240, l_k2730
          FROM DUAL;

        SELECT org_to, org_org
          INTO l_org_to, l_org_org
          FROM v_opfu t
         WHERE t.org_id = l_org;

        IF (p_fr_id IS NULL)
        THEN
            INSERT INTO FUNDING_REQUEST (COM_ORG,
                                         FR_ORG,
                                         FR_DOC_NUM,
                                         FR_DOC_DT,
                                         FR_SRC,
                                         FR_MONTH,
                                         FR_NBG,
                                         FR_TP,
                                         --FR_RECIPIENT_QNT,
                                         --FR_BANK_SUM,
                                         -- FR_POST_SUM,
                                         -- FR_POST_COST_SUM,
                                         FR_OWN_TP,
                                         FR_ST,
                                         FR_HS_INS)
                 VALUES (l_org,
                         l_org,
                         TO_CHAR (P_FR_MONTH, 'DDMMYYYY'),
                         TRUNC (SYSDATE),
                         NULL,
                         TRUNC (P_FR_MONTH),
                         p_FR_NBG,
                         p_FR_TP,
                         --p_FR_RECIPIENT_QNT,
                         --p_FR_BANK_SUM,
                         --p_FR_POST_SUM,
                         --p_FR_POST_COST_SUM,
                         'OWN',
                         'E',
                         l_hs)
              RETURNING FR_ID
                   INTO p_fr_id;
        END IF;


        -- fr_detail_service: pay_tp, nst, nkv_id (npc_nkv)
        IF (l_org_to = 32)
        THEN
            SEED_FULL ();
        ELSIF (l_org_to IN (30, 31))
        THEN
            SEED_BY_CONS ();
        END IF;

        UPDATE FUNDING_REQUEST
           SET FR_RECIPIENT_QNT = l_FR_RECIPIENT_QNT,
               FR_BANK_SUM = l_FR_BANK_SUM,
               FR_POST_SUM = l_FR_POST_SUM,
               FR_POST_COST_SUM = l_FR_POST_COST_SUM,
               fr_st = 'E'
         WHERE FR_ID = p_FR_ID;
    END;

    -- #73227: Підтвердити:
    -- для документів з fr_own_tp='OWN' та fr_st = Редагується це означає: після зміни статусу на fr_st = Затверджено,
    --     створити/оновити копію документу на вищому рівні (fr_fr_cons) з типом fr_own_tp = 'CONS' з статусом fr_st = Передано;
    -- для документів з fr_own_tp='CONS' та fr_st = Передано це означає: зміну статусу на fr_st = Підтверджено;
    PROCEDURE PROVE_FUND_REQUEST (P_FR_ID IN NUMBER)
    IS
        l_row       v_funding_request%ROWTYPE;
        l_org_to    NUMBER;
        l_org_org   NUMBER;
        l_hs        NUMBER := tools.gethistsession;
        l_new_id    NUMBER;
    BEGIN
        tools.WriteMsg ('DNET$BUDGETING.' || $$PLSQL_UNIT);

        SELECT *
          INTO l_row
          FROM v_funding_request t
         WHERE t.fr_id = p_fr_id;

        SELECT org_to, t.org_org
          INTO l_org_to, l_org_org
          FROM v_opfu t
         WHERE t.org_id = l_row.com_org;


        IF (l_org_to = 30 AND l_row.fr_own_tp = 'OWN' AND l_row.fr_st = 'E')
        THEN
            UPDATE funding_request t
               SET t.fr_st = 'Z'
             WHERE t.fr_id = p_fr_id;
        ELSIF (l_row.fr_own_tp = 'CONS' AND l_row.fr_st = 'P')
        THEN
            UPDATE funding_request t
               SET t.fr_st = 'R'
             WHERE t.fr_id = p_fr_id;
        ELSIF (    l_org_to IN (31, 32)
               AND l_row.fr_own_tp = 'OWN'
               AND l_row.fr_st = 'E')
        THEN
            UPDATE funding_request t
               SET t.fr_st = 'Z'
             WHERE t.fr_id = p_fr_id;

            IF l_row.fr_fr_cons IS NULL
            THEN
                INSERT INTO FUNDING_REQUEST (COM_ORG,
                                             FR_ORG,
                                             FR_DOC_NUM,
                                             FR_DOC_DT,
                                             FR_SRC,
                                             FR_MONTH,
                                             FR_NBG,
                                             FR_TP,
                                             FR_RECIPIENT_QNT,
                                             FR_BANK_SUM,
                                             FR_POST_SUM,
                                             FR_POST_COST_SUM,
                                             FR_OWN_TP,
                                             FR_ST,
                                             FR_HS_INS)
                     VALUES (l_org_org,
                             l_row.com_org,
                             l_row.FR_DOC_NUM,
                             TRUNC (SYSDATE),
                             l_row.FR_SRC,
                             l_row.FR_MONTH,
                             l_row.FR_NBG,
                             l_row.FR_TP,
                             l_row.FR_RECIPIENT_QNT,
                             l_row.FR_BANK_SUM,
                             l_row.FR_POST_SUM,
                             l_row.FR_POST_COST_SUM,
                             'CONS',
                             'P',
                             l_hs)
                  RETURNING FR_ID
                       INTO l_new_id;

                UPDATE funding_request t
                   SET t.fr_fr_cons = l_new_id
                 WHERE t.fr_id = P_FR_ID;
            ELSE
                l_new_id := l_row.fr_fr_cons;

                UPDATE FUNDING_REQUEST
                   SET FR_RECIPIENT_QNT = l_row.FR_RECIPIENT_QNT,
                       FR_BANK_SUM = l_row.FR_BANK_SUM,
                       FR_POST_SUM = l_row.FR_POST_SUM,
                       FR_POST_COST_SUM = l_row.FR_POST_COST_SUM,
                       FR_ST = 'P'
                 WHERE FR_ID = l_new_id;
            END IF;

            DELETE FROM fr_detail_service t
                  WHERE t.frs_fr = l_new_id;

            /*insert into FR_DETAIL_SERVICE
             ( FRS_FR,
               FRS_NST,
               FRS_VALUE,
               FRS_PAY_TP,
               FRS_NKV,
               FRS_VALUE_TP,
               FRS_ORG
             )
            SELECT l_new_id,
                   t.frs_nst,
                   t.frs_value,
                   t.frs_pay_tp,
                   t.frs_nkv,
                   t.frs_value_tp,
                   frs_org
              FROM fr_detail_service t
             WHERE t.frs_fr = P_FR_ID;*/
            INSERT INTO FR_DETAIL_SERVICE (FRS_FR,
                                           FRS_NST,
                                           FRS_VALUE,
                                           FRS_PAY_TP,
                                           FRS_NKV,
                                           FRS_VALUE_TP,
                                           FRS_ORG)
                  SELECT l_new_id,
                         t.frs_nst,
                         SUM (t.frs_value),
                         t.frs_pay_tp,
                         t.frs_nkv,
                         t.frs_value_tp,
                         l_row.com_org
                    FROM fr_detail_service t
                   WHERE t.frs_fr = P_FR_ID
                GROUP BY frs_nst,
                         frs_pay_tp,
                         frs_value_tp,
                         frs_nkv;
        END IF;
    END;


    -- #73227: Відхилити:
    -- для документів з fr_own_tp='OWN' та fr_st = Затверджено це означає: зміну статусу на fr_st = Редагується, але тільки за умови,
    --      якщо документ, який вказано в fr_fr_cons - знаходиться в статусі Передано або Відхилено;
    -- для документів з fr_own_tp='CONS' та fr_st = Передано це означає: зміну статусу на fr_st = Відхилено;
    PROCEDURE REJECT_FUND_REQUEST (P_FR_ID IN NUMBER)
    IS
        l_row        v_funding_request%ROWTYPE;
        l_cons_row   v_funding_request%ROWTYPE;
    BEGIN
        tools.WriteMsg ('DNET$BUDGETING.' || $$PLSQL_UNIT);

        SELECT *
          INTO l_row
          FROM v_funding_request t
         WHERE t.fr_id = p_fr_id;

        IF (l_row.fr_fr_cons IS NOT NULL)
        THEN
            SELECT *
              INTO l_cons_row
              FROM funding_request t
             WHERE t.fr_id = l_row.fr_fr_cons;
        END IF;

        IF (l_row.fr_own_tp = 'CONS' AND l_row.fr_st = 'P')
        THEN
            UPDATE funding_request t
               SET t.fr_st = 'V'
             WHERE t.fr_id = p_fr_id;
        ELSIF (    l_row.fr_own_tp = 'OWN'
               AND l_row.fr_st = 'Z'
               AND l_cons_row.fr_st IN ('P', 'V'))
        THEN
            UPDATE funding_request t
               SET t.fr_st = 'E'
             WHERE t.fr_id = p_fr_id;
        ELSE
            raise_application_error (-20000, 'Відхилення неможливе.');
        END IF;
    END;

    -- вичитка картки потреби
    PROCEDURE GET_FR_CARD (P_FR_ID     IN     NUMBER,
                           RES_CUR        OUT SYS_REFCURSOR,
                           GROUP_CUR      OUT SYS_REFCURSOR)
    IS
        l_org_to   NUMBER;
    BEGIN
        tools.WriteMsg ('DNET$BUDGETING.' || $$PLSQL_UNIT);

        SELECT p.org_to
          INTO l_org_to
          FROM v_funding_request t JOIN v_opfu p ON (p.org_id = t.fr_org)
         WHERE t.fr_id = P_FR_ID;

        OPEN RES_CUR FOR
            SELECT t.*,
                   st.dic_sname
                       AS fr_st_name,
                   tp.DIC_SNAME
                       AS fr_tp_name,
                   l_org_to
                       AS org_to,
                      '№'
                   || t.fr_doc_num
                   || ' від '
                   || TO_CHAR (t.fr_doc_dt, 'DD.MM.YYYY')
                       AS Fr_Doc_Dt_Num,
                     NVL (t.fr_bank_sum, 0)
                   + NVL (t.fr_post_sum, 0)
                   + NVL (t.fr_post_cost_sum, 0)
                       AS fr_summary_sum
              FROM v_funding_request  t
                   JOIN uss_ndi.v_ddn_fr_st st ON (st.DIC_VALUE = t.fr_st)
                   JOIN uss_ndi.v_ddn_fr_tp tp ON (tp.DIC_VALUE = t.fr_tp)
             WHERE t.fr_id = p_fr_id;

        IF (l_org_to = 32)
        THEN
            OPEN GROUP_CUR FOR
                  SELECT t.frs_nst,
                         st.nst_name
                             AS frs_nst_name,
                         (SELECT SUM (z.frf_value)
                            FROM fr_detail_full z
                                 JOIN fr_detail_service ds
                                     ON (ds.frs_id = z.frf_frs)
                           WHERE     ds.frs_nst = t.frs_nst
                                 AND z.frf_fr = fr.fr_id
                                 AND ds.frs_value_tp = 'QNT')
                             AS qnt,
                         SUM (
                             CASE
                                 WHEN t.frs_value_tp = 'QNT' THEN t.frs_value
                             END)
                             AS qnt_edit,
                         (SELECT SUM (z.frf_value)
                            FROM fr_detail_full z
                                 JOIN fr_detail_service ds
                                     ON (ds.frs_id = z.frf_frs)
                           WHERE     ds.frs_nst = t.frs_nst
                                 AND z.frf_fr = fr.fr_id
                                 AND ds.frs_value_tp IN ('BSA', 'PSA', 'PSV'))
                             AS total_sum,
                         (SELECT SUM (z.frf_value)
                            FROM fr_detail_full z
                                 JOIN fr_detail_service ds
                                     ON (ds.frs_id = z.frf_frs)
                           WHERE     ds.frs_nst = t.frs_nst
                                 AND z.frf_fr = fr.fr_id
                                 AND ds.frs_value_tp IN ('BSA', 'PSA'))
                             AS total_2730_sum,
                         (SELECT SUM (z.frf_value)
                            FROM fr_detail_full z
                                 JOIN fr_detail_service ds
                                     ON (ds.frs_id = z.frf_frs)
                           WHERE     ds.frs_nst = t.frs_nst
                                 AND z.frf_fr = fr.fr_id
                                 AND ds.frs_value_tp IN ('BSA'))
                             AS bank_sum,
                         SUM (
                             CASE
                                 WHEN t.frs_value_tp = 'BSA' THEN t.frs_value
                             END)
                             AS bank_sum_edit,
                         (SELECT SUM (z.frf_value)
                            FROM fr_detail_full z
                                 JOIN fr_detail_service ds
                                     ON (ds.frs_id = z.frf_frs)
                           WHERE     ds.frs_nst = t.frs_nst
                                 AND z.frf_fr = fr.fr_id
                                 AND ds.frs_value_tp IN ('PSA'))
                             AS post_sum,
                         SUM (
                             CASE
                                 WHEN t.frs_value_tp = 'PSA' THEN t.frs_value
                             END)
                             AS post_sum_edit,
                         (SELECT SUM (z.frf_value)
                            FROM fr_detail_full z
                                 JOIN fr_detail_service ds
                                     ON (ds.frs_id = z.frf_frs)
                           WHERE     ds.frs_nst = t.frs_nst
                                 AND z.frf_fr = fr.fr_id
                                 AND ds.frs_value_tp IN ('PSV'))
                             AS post_cost_sum,
                         SUM (
                             CASE
                                 WHEN t.frs_value_tp = 'PSV' THEN t.frs_value
                             END)
                             AS post_cost_sum_edit
                    FROM v_funding_request fr
                         JOIN fr_detail_service t ON (t.frs_fr = fr.fr_id)
                         JOIN uss_ndi.v_ndi_service_type st
                             ON (st.nst_id = t.frs_nst)
                   WHERE fr.fr_id = p_fr_id
                GROUP BY t.frs_nst, st.nst_name, fr.fr_id;
        ELSE
            OPEN GROUP_CUR FOR
                  SELECT s.frs_nst,
                         st.nst_name
                             AS frs_nst_name,
                         s.frs_org
                             AS com_org,
                         op.org_name
                             AS com_org_name,
                         (SELECT SUM (z.frs_value)
                            FROM v_funding_request zr
                                 JOIN fr_detail_service z
                                     ON (z.frs_fr = zr.fr_id)
                           WHERE     z.frs_nst = s.frs_nst
                                 AND zr.fr_org = s.frs_org
                                 AND zr.fr_month = fr.fr_month
                                 AND zr.fr_own_tp = 'CONS'
                                 AND zr.fr_st = 'R'
                                 AND zr.fr_tp = fr.fr_tp
                                 AND z.frs_value_tp = 'QNT')
                             AS qnt,
                         SUM (
                             CASE
                                 WHEN s.frs_value_tp = 'QNT' THEN s.frs_value
                             END)
                             AS qnt_edit,
                         SUM (
                             CASE
                                 WHEN s.frs_value_tp IN ('BSA', 'PSA', 'PSV')
                                 THEN
                                     s.frs_value
                             END)
                             AS total_sum,
                         SUM (
                             CASE
                                 WHEN s.frs_value_tp IN ('BSA', 'PSA')
                                 THEN
                                     s.frs_value
                             END)
                             AS total_2730_sum,
                         (SELECT SUM (z.frs_value)
                            FROM v_funding_request zr
                                 JOIN fr_detail_service z
                                     ON (z.frs_fr = zr.fr_id)
                           WHERE     z.frs_nst = s.frs_nst
                                 AND zr.fr_org = s.frs_org
                                 AND zr.fr_month = fr.fr_month
                                 AND zr.fr_own_tp = 'CONS'
                                 AND zr.fr_st = 'R'
                                 AND zr.fr_tp = fr.fr_tp
                                 AND z.frs_value_tp IN ('BSA'))
                             AS bank_sum,
                         SUM (
                             CASE
                                 WHEN s.frs_value_tp = 'BSA' THEN s.frs_value
                             END)
                             AS bank_sum_edit,
                         (SELECT SUM (z.frs_value)
                            FROM v_funding_request zr
                                 JOIN fr_detail_service z
                                     ON (z.frs_fr = zr.fr_id)
                           WHERE     z.frs_nst = s.frs_nst
                                 AND zr.fr_org = s.frs_org
                                 AND zr.fr_month = fr.fr_month
                                 AND zr.fr_own_tp = 'CONS'
                                 AND zr.fr_st = 'R'
                                 AND zr.fr_tp = fr.fr_tp
                                 AND z.frs_value_tp IN ('PSA'))
                             AS post_sum,
                         SUM (
                             CASE
                                 WHEN s.frs_value_tp = 'PSA' THEN s.frs_value
                             END)
                             AS post_sum_edit,
                         (SELECT SUM (z.frs_value)
                            FROM v_funding_request zr
                                 JOIN fr_detail_service z
                                     ON (z.frs_fr = zr.fr_id)
                           WHERE     z.frs_nst = s.frs_nst
                                 AND zr.fr_org = s.frs_org
                                 AND zr.fr_month = fr.fr_month
                                 AND zr.fr_own_tp = 'CONS'
                                 AND zr.fr_st = 'R'
                                 AND zr.fr_tp = fr.fr_tp
                                 AND z.frs_value_tp IN ('PSV'))
                             AS post_cost_sum,
                         SUM (
                             CASE
                                 WHEN s.frs_value_tp = 'PSV' THEN s.frs_value
                             END)
                             AS post_cost_sum_edit
                    FROM v_funding_request fr
                         JOIN fr_detail_service s ON (s.frs_fr = fr.fr_id)
                         JOIN uss_ndi.v_ndi_service_type st
                             ON (st.nst_id = s.frs_nst)
                         JOIN v_opfu op ON (op.org_id = s.frs_org)
                   WHERE fr.fr_id = p_fr_id
                GROUP BY fr.fr_month,
                         fr.fr_tp,
                         s.frs_org,
                         op.org_name,
                         s.frs_nst,
                         st.nst_name;
        END IF;
    END;

    -- збереження картки потреби

    PROCEDURE SAVE_CARD (P_FR_ID IN NUMBER, P_XML IN CLOB)
    IS
        l_details            t_detail := t_detail ();
        l_org_to             NUMBER := tools.getcurrorgto;

        l_fr_bank_sum        NUMBER := 0;
        l_fr_post_sum        NUMBER := 0;
        l_fr_post_cost_sum   NUMBER := 0;
        l_FR_RECIPIENT_QNT   NUMBER := 0;
    BEGIN
        /*INSERT INTO tmp_lob t
        (x_clob)
        VALUES
        (p_xml);
        COMMIT;*/
        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''. ''');

        EXECUTE IMMEDIATE Type2xmltable (Package_Name, 't_detail', TRUE)
            BULK COLLECT INTO l_details
            USING p_xml;

        IF (l_org_To = 32)
        THEN
            FOR xx IN (SELECT *
                         FROM TABLE (l_details) t)
            LOOP
                UPDATE fr_detail_service t
                   SET t.frs_value = xx.qnt_edit
                 WHERE t.frs_nst = xx.frs_nst AND t.frs_value_tp = 'QNT';

                UPDATE fr_detail_service t
                   SET t.frs_value = xx.bank_sum_edit
                 WHERE t.frs_nst = xx.frs_nst AND t.frs_value_tp = 'BSA';

                UPDATE fr_detail_service t
                   SET t.frs_value = xx.post_sum_edit
                 WHERE t.frs_nst = xx.frs_nst AND t.frs_value_tp = 'PSA';

                UPDATE fr_detail_service t
                   SET t.frs_value = xx.post_cost_sum_edit
                 WHERE t.frs_nst = xx.frs_nst AND t.frs_value_tp = 'PSV';
            END LOOP;
        ELSE
            FOR xx IN (SELECT *
                         FROM TABLE (l_details) t)
            LOOP
                UPDATE fr_detail_service t
                   SET t.frs_value = xx.qnt_edit
                 WHERE     t.frs_nst = xx.frs_nst
                       AND t.frs_org = xx.Com_Org
                       AND t.frs_value_tp = 'QNT';

                UPDATE fr_detail_service t
                   SET t.frs_value = xx.bank_sum_edit
                 WHERE     t.frs_nst = xx.frs_nst
                       AND t.frs_org = xx.Com_Org
                       AND t.frs_value_tp = 'BSA';

                UPDATE fr_detail_service t
                   SET t.frs_value = xx.post_sum_edit
                 WHERE     t.frs_nst = xx.frs_nst
                       AND t.frs_org = xx.Com_Org
                       AND t.frs_value_tp = 'PSA';

                UPDATE fr_detail_service t
                   SET t.frs_value = xx.post_cost_sum_edit
                 WHERE     t.frs_nst = xx.frs_nst
                       AND t.frs_org = xx.Com_Org
                       AND t.frs_value_tp = 'PSV';
            END LOOP;
        END IF;

        SELECT SUM (CASE WHEN t.frs_value_tp = 'BSA' THEN t.frs_value END)
                   AS bank_sum,
               SUM (CASE WHEN t.frs_value_tp = 'PSA' THEN t.frs_value END)
                   AS post_sum,
               SUM (CASE WHEN t.frs_value_tp = 'PSV' THEN t.frs_value END)
                   AS post_cost_sum,
               SUM (CASE WHEN t.frs_value_tp = 'QNT' THEN t.frs_value END)
                   AS qnt
          INTO l_fr_bank_sum,
               l_fr_post_sum,
               l_fr_post_cost_sum,
               l_FR_RECIPIENT_QNT
          FROM fr_detail_service t
         WHERE t.frs_fr = P_FR_ID;

        UPDATE FUNDING_REQUEST
           SET FR_RECIPIENT_QNT = l_FR_RECIPIENT_QNT,
               FR_BANK_SUM = l_FR_BANK_SUM,
               FR_POST_SUM = l_FR_POST_SUM,
               FR_POST_COST_SUM = l_FR_POST_COST_SUM,
               fr_st = 'E'
         WHERE FR_ID = p_FR_ID;
    END;

    -- видалення картки потреби
    PROCEDURE delete_card (P_FR_ID IN NUMBER)
    IS
        l_flag      NUMBER;
        l_cons      NUMBER;
        l_cons_st   VARCHAR2 (10);

        PROCEDURE delete_by_id (p_id NUMBER)
        IS
        BEGIN
            DELETE FROM fr_detail_full t
                  WHERE t.frf_fr = p_id;

            DELETE FROM fr_detail_service t
                  WHERE t.frs_fr = p_id;

            DELETE FROM funding_request t
                  WHERE t.fr_id = p_id;
        END;
    BEGIN
        SELECT COUNT (*), MAX (t.fr_fr_cons), MAX (c.fr_st)
          INTO l_flag, l_cons, l_cons_st
          FROM funding_request  t
               LEFT JOIN funding_request c ON (c.fr_id = t.fr_fr_cons)
         WHERE t.fr_id = p_fr_id AND t.fr_st IN ('E');

        IF (l_flag = 0)
        THEN
            raise_application_error (
                -20000,
                'Видалення можливе тільки картки в стані "Редагується"!');
        END IF;

        IF (l_cons IS NOT NULL AND l_cons_st NOT IN ('P', 'V'))
        THEN
            raise_application_error (
                -20000,
                'Консолідована картка вже затверджена. Видалення неможливе!');
        END IF;

        delete_by_id (p_fr_id);

        IF (l_cons IS NOT NULL)
        THEN
            delete_by_id (l_cons);
        END IF;
    END;
BEGIN
    NULL;
END DNET$BUDGETING;
/