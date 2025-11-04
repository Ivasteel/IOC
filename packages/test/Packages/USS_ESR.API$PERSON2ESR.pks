/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$PERSON2ESR
IS
    -- Author  : OLEKSII
    -- Created : 05.04.2023 10:22:41
    -- Purpose :

    --ініціалізація в BODY
    g_end_war_dt   DATE;            -- := to_date('30.09.2023', 'dd.mm.yyyy');

    PROCEDURE rollback_pc_location (p_pl_pc NUMBER, p_hs NUMBER);

    PROCEDURE Check_Decision;

    PROCEDURE Event2Decision;

    -- 0 - № ЕОС
    -- 1 - № ЕОС (ОСЗН)
    FUNCTION get_eos_by_sc (p_sc_id IN NUMBER, p_mode IN NUMBER DEFAULT 0)
        RETURN VARCHAR2;
END API$Person2ESR;
/


GRANT EXECUTE ON USS_ESR.API$PERSON2ESR TO II01RC_USS_ESR_INTERNAL
/

GRANT EXECUTE ON USS_ESR.API$PERSON2ESR TO IKIS_RBM
/

GRANT EXECUTE ON USS_ESR.API$PERSON2ESR TO USS_PERSON
/

GRANT EXECUTE ON USS_ESR.API$PERSON2ESR TO USS_RPT
/

GRANT EXECUTE ON USS_ESR.API$PERSON2ESR TO USS_VISIT
/


/* Formatted on 8/12/2025 5:49:16 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$PERSON2ESR
IS
    --==================================================================================--
    g_hs   NUMBER;

    --==================================================================================--
    PROCEDURE rollback_pc_location (p_pl_pc NUMBER, p_hs NUMBER)
    IS
        l_hs_old   NUMBER;
        l_hs       NUMBER := NVL (p_hs, tools.GetHistSession ());
    BEGIN
        SELECT MAX (pl_hs_del)
          INTO l_hs_old
          FROM uss_esr.pc_location
         WHERE pl_pc = p_pl_pc AND SYSDATE BETWEEN pl_start_dt AND pl_stop_dt;

        UPDATE uss_esr.pc_location
           SET HISTORY_STATUS = 'H', pl_hs_del = l_hs
         WHERE     pl_pc = p_pl_pc
               AND pl_hs_ins = l_hs_old
               AND HISTORY_STATUS = 'A';

        INSERT INTO uss_esr.pc_location (pl_id,
                                         pl_pc,
                                         pl_org,
                                         pl_start_dt,
                                         pl_stop_dt,
                                         history_status,
                                         pl_hs_ins,
                                         pl_hs_del,
                                         pl_pca)
            SELECT 0,
                   pl_pc,
                   pl_org,
                   pl_start_dt,
                   pl_stop_dt,
                   'A',
                   l_hs,
                   NULL,
                   pl_pca
              FROM uss_esr.pc_location
             WHERE     pl_pc = p_pl_pc
                   AND pl_hs_del = l_hs_old
                   AND HISTORY_STATUS = 'H';

        UPDATE uss_esr.personalcase
           SET com_org =
                   (SELECT pl_org
                      FROM uss_esr.pc_location
                     WHERE     pl_pc = p_pl_pc
                           AND pl_hs_del = l_hs_old
                           AND HISTORY_STATUS = 'H')
         WHERE pc_id = p_pl_pc;
    END;

    --==================================================================================--
    FUNCTION gen_pd_num (p_pc_id personalcase.pc_id%TYPE)
        RETURN VARCHAR2
    IS
        l_cnt      INTEGER;
        l_pc_num   personalcase.pc_num%TYPE;
    BEGIN
        SELECT COUNT (1)
          INTO l_cnt
          FROM pc_decision
         WHERE     pd_pc = p_pc_id
               AND pd_dt BETWEEN TRUNC (SYSDATE, 'YYYY')
                             AND LAST_DAY (
                                     ADD_MONTHS (TRUNC (SYSDATE, 'YYYY'), 11))
               AND pd_num IS NOT NULL;

        SELECT pc_num
          INTO l_pc_num
          FROM personalcase
         WHERE pc_id = p_pc_id;

        RETURN    l_pc_num
               || '-'
               || TO_CHAR (SYSDATE, 'YYYY')
               || '-'
               || (l_cnt + 1);
    END;

    --==================================================================================--
    PROCEDURE Check_Decision
    IS
    BEGIN
        UPDATE TMP_Event2Decision t
           SET t.x_cnt_pd =
                   (SELECT COUNT (1)
                      FROM uss_esr.pc_decision
                     WHERE     pd_pc = x_pc
                           AND pd_st IN ('S')
                           AND pd_nst = 664       ---Поки так, потім розширкмо
                           AND EXISTS
                                   (SELECT 1
                                      FROM uss_esr.pd_accrual_period
                                     WHERE     pdap_pd = pd_id
                                           AND history_status = 'A'
                                           AND t.x_doc_dt BETWEEN pdap_start_dt
                                                              AND NVL (
                                                                      pdap_stop_dt,
                                                                      t.x_doc_dt)));

        UPDATE TMP_Event2Decision t
           SET t.x_cnt_pd_ps =
                   (SELECT COUNT (1)
                      FROM uss_esr.pc_decision pd
                     WHERE     pd_pc = x_pc
                           AND pd_st IN ('PS')
                           AND pd_nst = 664       ---Поки так, потім розширкмо
                           AND EXISTS
                                   (SELECT 1
                                      FROM uss_esr.pc_block  b
                                           JOIN
                                           uss_ndi.v_ndi_reason_not_pay n
                                               ON n.rnp_id = b.pcb_rnp
                                     WHERE     b.pcb_pd = pd_id
                                           AND b.pcb_rup IS NULL
                                           AND n.rnp_code IN
                                                   ('CHO', 'VPOREF'))
                           AND pd.pd_id IN
                                   (  SELECT pd_1.pd_id
                                        FROM uss_esr.pc_decision pd_1
                                             JOIN uss_esr.pd_accrual_period
                                                 ON     pdap_pd = pd_1.pd_id
                                                    AND history_status = 'A'
                                       WHERE     pd_1.pd_pa = pd.pd_pa
                                             AND pd_1.pd_st IN ('S', 'PS')
                                             AND TRUNC (
                                                     ADD_MONTHS (t.x_doc_dt,
                                                                 -1),
                                                     'MM') BETWEEN pdap_start_dt
                                                               AND NVL (
                                                                       pdap_stop_dt,
                                                                       t.x_doc_dt)
                                    ORDER BY pd_1.pd_start_dt DESC,
                                             pd_1.pd_id DESC
                                       FETCH FIRST 1 ROW ONLY));
    END;

    --==================================================================================--
    PROCEDURE Create_Decision_S (p_ap         NUMBER,
                                 p_com_org    NUMBER,
                                 p_start_dt   DATE,
                                 p_pd_old     NUMBER,
                                 p_pd_new     NUMBER)
    IS
        l_pd_id      NUMBER (14) := p_pd_new;
        pay_method   pd_pay_method%ROWTYPE;
        l_sql_cnt    NUMBER;

        ---------------------------------------------
        CURSOR pdm (p_pd NUMBER)
        IS
              SELECT p.*
                FROM pd_pay_method p
               WHERE p.pdm_pd = p_pd AND p.history_status = 'A'
            ORDER BY p.pdm_start_dt DESC, p.pdm_id DESC;
    BEGIN
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
                   'S'
                       AS x_st,
                   pd_nst,
                   p_com_org,
                   com_wu,
                   'PV'
                       AS x_pd_src,
                   pd_ps
                       AS x_pd_ps,
                   pd_id,
                   pd_has_right,
                   p_start_dt,
                   CASE
                       WHEN pd_stop_dt < p_start_dt THEN g_end_war_dt
                       ELSE pd_stop_dt
                   END,
                   p_ap,
                   pd_scc
              FROM pc_decision pd
             WHERE     pd.pd_id = p_pd_old
                   AND NOT EXISTS
                           (SELECT 1
                              FROM pd_source pds
                             WHERE     pds.pds_ap = p_ap
                                   AND pds.pds_pd = p_pd_old
                                   AND pds.pds_tp = 'AN');

        /*
                  FOR d IN (SELECT * FROM  pc_decision WHERE pd_id= l_pd_id ) LOOP
                    dbms_output_put_lines('pd_st='||d.pd_st);
                  END LOOP;
        */
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
             WHERE pds_pd = p_pd_old AND history_status = 'A'
            UNION ALL
            SELECT 0,
                   l_pd_id     AS pds_pd,
                   'AN'        AS pds_tp,
                   p_ap        AS pds_ap,
                   SYSDATE,
                   'A'
              FROM DUAL;

        FOR pm IN pdm (p_pd_old)
        LOOP
            pay_method := pm;
        END LOOP;

        IF pay_method.pdm_pd IS NOT NULL
        THEN
            pay_method.pdm_id := NULL;
            pay_method.pdm_pd := l_pd_id;
            pay_method.pdm_start_dt := p_start_dt;

            CASE
                WHEN pay_method.PDM_PAY_DT > 25 OR pay_method.PDM_PAY_DT < 4
                THEN
                    pay_method.PDM_PAY_DT := 4;
                ELSE
                    NULL;
            END CASE;

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
             WHERE prl.prl_pd = p_pd_old;

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
             WHERE pde.pde_pd = p_pd_old;

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
                   g_hs,
                   pdf_tp
              FROM pd_family pdf, pc_decision pd
             WHERE pdf.pdf_pd = p_pd_old AND pd.pd_id = l_pd_id;

        DELETE FROM tmp_work_set1
              WHERE 1 = 1;

        INSERT INTO tmp_work_set1 (x_id1, x_id2)
            SELECT pdp_id, id_pd_payment (0)
              FROM pd_payment pdp
             WHERE pdp.pdp_pd = p_pd_old AND pdp.pdp_stop_dt > p_start_dt;

        l_sql_cnt := SQL%ROWCOUNT;

        IF l_sql_cnt > 0
        THEN
            INSERT INTO pd_payment (pdp_id,
                                    pdp_pd,
                                    pdp_npt,
                                    pdp_start_dt,
                                    pdp_stop_dt,
                                    pdp_sum,
                                    pdp_hs_ins,
                                    pdp_hs_del,
                                    history_status)
                SELECT x_id2,
                       l_pd_id    AS x_pd,
                       pdp_npt,
                       CASE
                           WHEN pdp_start_dt < p_start_dt THEN p_start_dt
                           ELSE pdp_start_dt
                       END        AS x_start_dt,
                       pdp_stop_dt,
                       pdp_sum,
                       pdp_hs_ins,
                       pdp_hs_del,
                       history_status
                  FROM pd_payment pdp JOIN tmp_work_set1 ON x_id1 = pdp_id;

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
                SELECT 0                                      AS x_id,
                       x_id2,
                       pdd_row_order,
                       pdd_row_name,
                       pdd_value,
                       (SELECT MAX (new_f.pdf_id)
                          FROM pd_family  old_f
                               JOIN pd_family new_f
                                   ON new_f.pdf_sc = old_f.pdf_sc
                         WHERE     old_f.pdf_id = pdd.pdd_key
                               AND new_f.pdf_pd = l_pd_id)    AS x_pdd_key,
                       pdd_ndp,
                       CASE
                           WHEN pdd_start_dt < p_start_dt THEN p_start_dt
                           ELSE pdd_start_dt
                       END                                    AS x_start_dt,
                       pdd_stop_dt,
                       pdd_npt
                  FROM pd_detail pdd JOIN tmp_work_set1 ON x_id1 = pdd_pdp;
        ELSE
            INSERT INTO tmp_work_set1 (x_id1, x_id2)
                SELECT pdp_id, id_pd_payment (0)
                  FROM pd_payment pdp
                 WHERE     pdp.pdp_pd = p_pd_old
                       AND (pdp.pdp_stop_dt + 1) > p_start_dt;

            INSERT INTO pd_payment (pdp_id,
                                    pdp_pd,
                                    pdp_npt,
                                    pdp_start_dt,
                                    pdp_stop_dt,
                                    pdp_sum,
                                    pdp_hs_ins,
                                    pdp_hs_del,
                                    history_status)
                SELECT x_id2,
                       l_pd_id    AS x_pd,
                       pdp_npt,
                       CASE
                           WHEN pdp_start_dt < p_start_dt THEN p_start_dt
                           ELSE pdp_start_dt
                       END        AS x_start_dt,
                       (CASE
                            WHEN pdp_stop_dt < p_start_dt THEN g_end_war_dt
                            ELSE pdp_stop_dt
                        END)      AS pdp_stop_dt,
                       pdp_sum,
                       pdp_hs_ins,
                       pdp_hs_del,
                       history_status
                  FROM pd_payment pdp JOIN tmp_work_set1 ON x_id1 = pdp_id;

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
                SELECT 0                                      AS x_id,
                       x_id2,
                       pdd_row_order,
                       pdd_row_name,
                       pdd_value,
                       (SELECT MAX (new_f.pdf_id)
                          FROM pd_family  old_f
                               JOIN pd_family new_f
                                   ON new_f.pdf_sc = old_f.pdf_sc
                         WHERE     old_f.pdf_id = pdd.pdd_key
                               AND new_f.pdf_pd = l_pd_id)    AS x_pdd_key,
                       pdd_ndp,
                       CASE
                           WHEN pdd_start_dt < p_start_dt THEN p_start_dt
                           ELSE pdd_start_dt
                       END                                    AS x_start_dt,
                       (CASE
                            WHEN pdd_stop_dt < p_start_dt THEN g_end_war_dt
                            ELSE pdd_stop_dt
                        END)                                  AS pdd_stop_dt,
                       pdd_npt
                  FROM pd_detail pdd JOIN tmp_work_set1 ON x_id1 = pdd_pdp;
        END IF;

        api$pc_decision.recalc_pd_periods_fs (l_pd_id, g_hs);
        api$pc_decision.Update_PA_Org (l_pd_id, 'S', 'S');
    END;

    --==================================================================================--
    PROCEDURE Create_Decision_V (p_ap         NUMBER,
                                 p_com_org    NUMBER,
                                 p_start_dt   DATE,
                                 p_pd_old     NUMBER,
                                 p_pd_new     NUMBER)
    IS
        l_pd_id      NUMBER (14) := p_pd_new;
        pay_method   pd_pay_method%ROWTYPE;

        ---------------------------------------------
        CURSOR pdm (p_pd NUMBER)
        IS
              SELECT p.*
                FROM pd_pay_method p
               WHERE p.pdm_pd = p_pd AND p.history_status = 'A'
            ORDER BY p.pdm_start_dt DESC, p.pdm_id DESC;
    BEGIN
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
                                 pd_ap_reason,
                                 pd_scc)
            SELECT l_pd_id,
                   pd_pc,
                   pd_ap,
                   pd_pa,
                   TRUNC (SYSDATE),
                   'V'       AS x_st,
                   pd_nst,
                   p_com_org,
                   com_wu,
                   'PV'      AS x_pd_src,
                   pd_ps     AS x_pd_ps,
                   pd_id,
                   pd_has_right,
                   p_ap,
                   pd_scc
              FROM pc_decision pd
             WHERE     pd.pd_id = p_pd_old
                   AND NOT EXISTS
                           (SELECT 1
                              FROM pd_source pds
                             WHERE     pds.pds_ap = p_ap
                                   AND pds.pds_pd = p_pd_old
                                   AND pds.pds_tp = 'AN');

        INSERT INTO pd_reject_info (pri_id, pri_njr, pri_pd)
            SELECT 0 AS x_id, t.njr_id, l_pd_id
              FROM uss_ndi.v_ndi_reject_reason t
             WHERE t.njr_code = '51' AND t.njr_nst = '664';


        --24 741 51 Термін призначення допомоги завершився у місці звернення щодо зміни місця проживання 24 664 A

        /*
                  FOR d IN (SELECT * FROM  pc_decision WHERE pd_id= l_pd_id ) LOOP
                    dbms_output_put_lines('pd_st='||d.pd_st);
                  END LOOP;
        */
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
             WHERE pds_pd = p_pd_old AND history_status = 'A'
            UNION ALL
            SELECT 0,
                   l_pd_id     AS pds_pd,
                   'AN'        AS pds_tp,
                   p_ap        AS pds_ap,
                   SYSDATE,
                   'A'
              FROM DUAL;

        FOR pm IN pdm (p_pd_old)
        LOOP
            pay_method := pm;
        END LOOP;

        IF pay_method.pdm_pd IS NOT NULL
        THEN
            pay_method.pdm_id := NULL;
            pay_method.pdm_pd := l_pd_id;
            pay_method.pdm_start_dt := p_start_dt;

            CASE
                WHEN pay_method.PDM_PAY_DT > 25 OR pay_method.PDM_PAY_DT < 4
                THEN
                    pay_method.PDM_PAY_DT := 4;
                ELSE
                    NULL;
            END CASE;

            INSERT INTO pd_pay_method
                 VALUES pay_method;
        END IF;
    END;

    --==================================================================================--
    PROCEDURE ReCreate_Decision (p_hs NUMBER)
    IS
        l_sql_cnt   NUMBER;
        l_pd_id     NUMBER;
        l_lock      TOOLS.t_lockhandler;
        l_num       VARCHAR2 (200);
    BEGIN
        g_hs := p_hs;

        FOR rec
            IN (SELECT t.x_scde,
                       t.x_com_org,
                       t.x_doc_dt,
                       t.x_pc,
                       t.x_pc_com_org,
                       t.x_ap,
                       pd_id                               AS x_pd_id,
                       LAST_DAY (TRUNC (x_doc_dt)) + 1     AS x_start_dt,
                       pd_start_dt                         AS old_start_dt,
                       pd_stop_dt                          AS old_stop_dt
                  FROM TMP_Event2Decision  t
                       JOIN uss_esr.pc_decision
                           ON     pd_pc = x_pc
                              AND pd_st IN ('S')
                              AND pd_nst = 664    ---Поки так, потім розширкмо
                 WHERE EXISTS
                           (SELECT 1
                              FROM uss_esr.pd_accrual_period
                             WHERE     pdap_pd = pd_id
                                   AND history_status = 'A'
                                   AND t.x_doc_dt BETWEEN pdap_start_dt
                                                      AND NVL (pdap_stop_dt,
                                                               t.x_doc_dt)))
        LOOP
            API$PC_DECISION.decision_block (rec.x_pd_id,
                                            'CHO',
                                            rec.x_ap,
                                            p_hs);
            l_pd_id := id_pc_decision (0);

            IF rec.x_start_dt < rec.old_stop_dt
            THEN
                Create_Decision_S (rec.x_ap,
                                   rec.x_com_org,
                                   rec.x_start_dt,
                                   rec.x_pd_id,
                                   l_pd_id);
            ELSE
                Create_Decision_V (rec.x_ap,
                                   rec.x_com_org,
                                   rec.x_start_dt,
                                   rec.x_pd_id,
                                   l_pd_id);
            END IF;


            --Проставляємо номери рішень
            FOR xx
                IN (SELECT pd_id,
                           pc_id,
                           pc_num,
                           nst_name,
                           pa_num
                      FROM (  SELECT pd_id,
                                     pc_id,
                                     pc_num,
                                     nst_name,
                                     pa_num
                                FROM personalcase,
                                     pc_decision,
                                     uss_ndi.v_ndi_service_type,
                                     pc_account
                               WHERE     pd_pc = pc_id
                                     AND pd_id = l_pd_id
                                     AND pd_nst = nst_id
                                     AND pd_num IS NULL
                                     AND pd_pa = pa_id
                            ORDER BY LPAD (pa_num, 10, '0') ASC, pd_id ASC))
            LOOP
                --Вішаємо lock на генерацію номера для ЕОС
                l_lock :=
                    TOOLS.request_lock (
                        p_descr   => 'CALC_PA_NUMS_PC_' || xx.pc_id,
                        p_error_msg   =>
                               'В даний момент вже виконується генерація номерів для особових рахунків ЕОС №'
                            || xx.pc_num
                            || '!');

                l_num := gen_pd_num (xx.pc_id);

                UPDATE pc_decision
                   SET pd_num = l_num
                 WHERE pd_id = xx.pd_id;

                --#81214 20221104
                API$PC_ATTESTAT.Check_pc_com_org (xx.pd_id, SYSDATE, p_hs);

                TOOLS.release_lock (l_lock);
                --TOOLS.add_message(g_messages, 'I', 'Створено проект рішення рахунок № '||l_num||' для ЕОС № '||xx.pc_num||' по послузі: '||xx.nst_name||'.');
                API$PC_DECISION.write_pd_log (
                    xx.pd_id,
                    p_hs,
                    'S',
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
                API$ESR_Action.PrepareCopy_ESR2Visit (
                    rec.x_ap,
                    'V',
                       CHR (38)
                    || '11#'
                    || l_num
                    || '#'
                    || xx.pc_num
                    || '#'
                    || xx.nst_name);
            END LOOP;
        -- api$pc_decision.recalc_pd_periods(p_pd_id => l_pd_id, p_hs => p_hs);

        END LOOP;
    END;

    --==================================================================================--
    PROCEDURE Close_Decision (p_hs NUMBER)
    IS
        l_pd_id      NUMBER;
        pay_method   pd_pay_method%ROWTYPE;
        l_lock       TOOLS.t_lockhandler;
        l_num        VARCHAR2 (200);

        CURSOR pdm (p_pd NUMBER)
        IS
              SELECT p.*
                FROM pd_pay_method p
               WHERE p.pdm_pd = p_pd AND p.history_status = 'A'
            ORDER BY p.pdm_start_dt DESC, p.pdm_id DESC;
    BEGIN
        --dbms_output_put_lines('Close_Decision');

        FOR rec
            IN (SELECT t.x_scde,
                       t.x_com_org,
                       t.x_doc_dt,
                       t.x_pc,
                       t.x_pc_com_org,
                       t.x_ap,
                       pd_id                                              AS x_pd_id,
                       --LAST_DAY(x_doc_dt)+1 AS x_start_dt,
                        (SELECT TRUNC (
                                    ADD_MONTHS (MAX (pdap_stop_dt), 1),
                                    'MM')
                           FROM uss_esr.pd_accrual_period
                          WHERE     pdap_pd = pd.pd_id
                                AND history_status = 'A'
                                AND TRUNC (ADD_MONTHS (t.x_doc_dt, -1),
                                           'MM') BETWEEN pdap_start_dt
                                                     AND pdap_stop_dt)    AS x_start_dt
                  FROM TMP_Event2Decision  t
                       JOIN uss_esr.pc_decision pd
                           ON     pd_pc = x_pc
                              AND pd_st IN ('PS')
                              AND pd_nst = 664    ---Поки так, потім розширкмо
                 WHERE     EXISTS
                               (SELECT 1
                                  FROM uss_esr.pc_block  b
                                       JOIN uss_ndi.v_ndi_reason_not_pay n
                                           ON n.rnp_id = b.pcb_rnp
                                 WHERE     b.pcb_pd = pd_id
                                       AND b.pcb_rup IS NULL
                                       AND n.rnp_code IN ('CHO', 'VPOREF'))
                       AND pd.pd_id IN
                               (  SELECT pd_1.pd_id
                                    FROM uss_esr.pc_decision pd_1
                                         JOIN uss_esr.pd_accrual_period
                                             ON     pdap_pd = pd_1.pd_id
                                                AND history_status = 'A'
                                   WHERE     pd_1.pd_pa = pd.pd_pa
                                         AND pd_1.pd_st IN ('S', 'PS')
                                --AND trunc(add_months(t.x_doc_dt,-1),'MM') BETWEEN pdap_start_dt AND pdap_stop_dt
                                ORDER BY pd_1.pd_start_dt DESC,
                                         pd_1.pd_id DESC
                                   FETCH FIRST 1 ROW ONLY)
                       AND NOT EXISTS
                               (SELECT 1
                                  FROM uss_esr.pc_decision pd_2
                                 WHERE pd_2.pd_ap_reason = t.x_ap))
        LOOP
            API$PC_DECISION.decision_block (rec.x_pd_id,
                                            'CHO',
                                            rec.x_ap,
                                            p_hs);

            l_pd_id := id_pc_decision (0);

            dbms_output_put_lines ('l_pd_id=' || l_pd_id);

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
                       'S'
                           AS x_st,
                       pd_nst,
                       rec.x_com_org,
                       com_wu,
                       'PV'
                           AS x_pd_src,
                       pd_ps
                           AS x_pd_ps,
                       pd_id,
                       pd_has_right,                          /*pd_start_dt,*/
                       rec.x_start_dt,
                       CASE
                           WHEN pd_stop_dt < rec.x_start_dt THEN g_end_war_dt
                           ELSE pd_stop_dt
                       END,
                       rec.x_ap,
                       pd_scc
                  FROM pc_decision pd
                 WHERE     pd.pd_id = rec.x_pd_id
                       AND NOT EXISTS
                               (SELECT 1
                                  FROM pd_source pds
                                 WHERE     pds.pds_ap = rec.x_ap
                                       AND pds.pds_pd = rec.x_pd_id
                                       AND pds.pds_tp = 'AN');

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
                 WHERE pds_pd = rec.x_pd_id AND history_status = 'A'
                UNION ALL
                SELECT 0,
                       l_pd_id      AS pds_pd,
                       'AN'         AS pds_tp,
                       rec.x_ap     AS pds_ap,
                       SYSDATE,
                       'A'
                  FROM DUAL;

            FOR pm IN pdm (rec.x_pd_id)
            LOOP
                pay_method := pm;
            END LOOP;

            IF pay_method.pdm_pd IS NOT NULL
            THEN
                pay_method.pdm_id := NULL;
                pay_method.pdm_pd := l_pd_id;
                pay_method.pdm_start_dt := rec.x_start_dt;

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
                 WHERE prl.prl_pd = rec.x_pd_id;

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
                 WHERE pde.pde_pd = rec.x_pd_id;

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
                 WHERE pdf.pdf_pd = rec.x_pd_id AND pd.pd_id = l_pd_id;


            DELETE FROM tmp_work_set1
                  WHERE 1 = 1;

            INSERT INTO tmp_work_set1 (x_id1, x_id2)
                SELECT pdp_id, id_pd_payment (0)
                  FROM pd_payment pdp
                 WHERE     pdp.pdp_pd = rec.x_pd_id
                       AND pdp.pdp_stop_dt > rec.x_start_dt;

            INSERT INTO pd_payment (pdp_id,
                                    pdp_pd,
                                    pdp_npt,
                                    pdp_start_dt,
                                    pdp_stop_dt,
                                    pdp_sum,
                                    pdp_hs_ins,
                                    pdp_hs_del,
                                    history_status)
                SELECT x_id2,
                       l_pd_id    AS x_pd,
                       pdp_npt,
                       CASE
                           WHEN pdp_start_dt < rec.x_start_dt
                           THEN
                               rec.x_start_dt
                           ELSE
                               pdp_start_dt
                       END        AS x_start_dt,
                       pdp_stop_dt,
                       pdp_sum,
                       pdp_hs_ins,
                       pdp_hs_del,
                       history_status
                  FROM pd_payment pdp JOIN tmp_work_set1 ON x_id1 = pdp_id;

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
                SELECT 0
                           AS x_id,
                       x_id2,
                       pdd_row_order,
                       pdd_row_name,
                       pdd_value,
                       (SELECT MAX (new_f.pdf_id)
                          FROM pd_family  old_f
                               JOIN pd_family new_f
                                   ON new_f.pdf_sc = old_f.pdf_sc
                         WHERE     old_f.pdf_id = pdd_key
                               AND EXISTS
                                       (SELECT 1
                                          FROM pd_payment p
                                         WHERE     p.pdp_id = x_id2
                                               AND p.pdp_pd = new_f.pdf_pd))
                           AS x_pdd_key,
                       pdd_ndp,
                       CASE
                           WHEN pdd_start_dt < rec.x_start_dt
                           THEN
                               rec.x_start_dt
                           ELSE
                               pdd_start_dt
                       END
                           AS x_start_dt,
                       pdd_stop_dt,
                       pdd_npt
                  FROM pd_detail pdd JOIN tmp_work_set1 ON x_id1 = pdd_pdp;

            api$pc_decision.recalc_pd_periods_fs (l_pd_id, p_hs);

            --Проставляємо номери рішень
            FOR xx
                IN (SELECT pd_id,
                           pc_id,
                           pc_num,
                           nst_name,
                           pa_num
                      FROM (  SELECT pd_id,
                                     pc_id,
                                     pc_num,
                                     nst_name,
                                     pa_num
                                FROM personalcase,
                                     pc_decision,
                                     uss_ndi.v_ndi_service_type,
                                     pc_account
                               WHERE     pd_pc = pc_id
                                     AND pd_id = l_pd_id
                                     AND pd_nst = nst_id
                                     AND pd_num IS NULL
                                     AND pd_pa = pa_id
                            ORDER BY LPAD (pa_num, 10, '0') ASC, pd_id ASC))
            LOOP
                --Вішаємо lock на генерацію номера для ЕОС
                l_lock :=
                    TOOLS.request_lock (
                        p_descr   => 'CALC_PA_NUMS_PC_' || xx.pc_id,
                        p_error_msg   =>
                               'В даний момент вже виконується генерація номерів для особових рахунків ЕОС №'
                            || xx.pc_num
                            || '!');

                l_num := gen_pd_num (xx.pc_id);

                UPDATE pc_decision
                   SET pd_num = l_num
                 WHERE pd_id = xx.pd_id;

                --#81214 20221104
                API$PC_ATTESTAT.Check_pc_com_org (xx.pd_id, SYSDATE, p_hs);

                TOOLS.release_lock (l_lock);
                --TOOLS.add_message(g_messages, 'I', 'Створено проект рішення рахунок № '||l_num||' для ЕОС № '||xx.pc_num||' по послузі: '||xx.nst_name||'.');
                API$PC_DECISION.write_pd_log (
                    xx.pd_id,
                    p_hs,
                    'S',
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
                API$ESR_Action.PrepareCopy_ESR2Visit (
                    rec.x_ap,
                    'V',
                       CHR (38)
                    || '11#'
                    || l_num
                    || '#'
                    || xx.pc_num
                    || '#'
                    || xx.nst_name);
            END LOOP;
        END LOOP;
    END;

    --==================================================================================--
    PROCEDURE Event2Decision
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        l_hs := TOOLS.GetHistSession;

        UPDATE TMP_Event2Decision t
           SET t.x_cnt_pd =
                   (SELECT COUNT (*)
                      FROM uss_esr.pc_decision, uss_esr.pd_accrual_period
                     WHERE     pd_pc = x_pc
                           AND pd_nst = 664       ---Поки так, потім розширкмо
                           AND pdap_pd = pd_id
                           AND history_status = 'A'
                           AND pd_st IN ('S')
                           AND t.x_doc_dt BETWEEN pdap_start_dt
                                              AND NVL (pdap_stop_dt,
                                                       t.x_doc_dt));

        --Створити новий аттестат (pc_attestat) в схемі uss_esr по передачі справи з джерелом pca_src = 'VPO_REF' одразу в статус "Оброблено"
        --з записом в лог атестату шаблонізованого запису про автоматичну обробку;
        INSERT INTO pc_attestat (pca_id,
                                 pca_pc,
                                 pca_st,
                                 pca_org_src,
                                 pca_org_dest,
                                 pca_ap_reason,
                                 pca_hs_ins,
                                 pca_hs_decision,
                                 pca_doc_num,
                                 pca_doc_dt,
                                 pca_start_dt,
                                 pca_src)
            SELECT 0,
                   t.x_pc,
                   'A',
                   t.x_pc_com_org,
                   t.x_com_org,
                   t.x_ap,
                   l_hs,
                   l_hs,
                   (SELECT MAX (apda_val_string)
                      FROM ap_document_attr
                     WHERE     ap_document_attr.history_status = 'A'
                           AND apda_apd = apd_id
                           AND apda_nda = 1756                -- Номер довідки
                                              ),
                   t.x_doc_dt,
                   t.x_doc_dt,
                   'VPO_REF'
              FROM TMP_Event2Decision  t
                   JOIN ap_document
                       ON     apd_ap = t.x_ap
                          AND ap_document.history_status = 'A'
             WHERE apd_ndt = 10052;

        --Змінює в записі personalcase com_org на pca_org_dest;
        UPDATE personalcase
           SET personalcase.com_org =
                   (SELECT t.x_com_org
                      FROM TMP_Event2Decision t
                     WHERE pc_id = t.x_pc)
         WHERE EXISTS
                   (SELECT 1
                      FROM TMP_Event2Decision t
                     WHERE pc_id = t.x_pc);

        INSERT INTO pca_log (pcal_id,
                             pcal_pca,
                             pcal_hs,
                             pcal_st,
                             pcal_message,
                             pcal_st_old,
                             pcal_tp)
            SELECT 0,
                   pca_id,
                   l_hs,
                   pca_st,
                   CHR (38) || '124',
                   pca_st,
                   'SYS'
              FROM TMP_Event2Decision  t
                   JOIN pc_attestat
                       ON t.x_pc = pca_pc AND t.x_ap = pca_ap_reason;

        FOR rec
            IN (SELECT pca_id,
                       pca_st,
                       pca_org_dest,
                       t.x_doc_dt,
                       t.x_pc
                  FROM TMP_Event2Decision  t
                       JOIN pc_attestat
                           ON t.x_pc = pca_pc AND t.x_ap = pca_ap_reason)
        LOOP
            API$PC_ATTESTAT.Recalc_pc_location (
                p_pc_id      => rec.x_pc,
                p_org_dest   => rec.pca_org_dest,
                p_start_dt   => rec.x_doc_dt,
                p_hs         => l_hs,
                p_pca_id     => rec.pca_id);
        END LOOP;

        --Призупинити наявне рішення в стані "Нараховане" з 1 числа місяця, що слідує за наступним до дати події;
        --Створити копію призупиненого рішення, прив'язану до нового ОСЗН, в статус "Призначене" з записом в лог рішення шаблонізованого повідомлення щодо автоматичного створення рішення за подією "поява нової довідки ВПО з передачеє ЕОС".
        ReCreate_Decision (l_hs);

        Close_Decision (l_hs);
    END;

    -- 0 - № ЕОС
    -- 1 - № ЕОС (ОСЗН)
    FUNCTION get_eos_by_sc (p_sc_id IN NUMBER, p_mode IN NUMBER DEFAULT 0)
        RETURN VARCHAR2
    IS
        l_res   VARCHAR2 (100);
    BEGIN
        SELECT CASE
                   WHEN p_mode = 0 THEN t.pc_num
                   WHEN p_mode = 1 THEN t.pc_num || ' (' || t.com_org || ')'
               END
          INTO l_res
          FROM personalcase t
         WHERE t.pc_sc = p_sc_id
         FETCH FIRST ROW ONLY;

        RETURN l_res;
    END;
BEGIN
    -- Initialization
    g_end_war_dt := TOOLS.GGPD ('VPO_END_BY_94');
END API$Person2ESR;
/