/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$PC_ATTESTAT
IS
    -- Author  : LESHA
    -- Created : 26.10.2022 15:22:58
    -- Purpose :

    --Змінює "Історія перебування справи в ОСЗН" (uss_esr.pc_location) таким чином, аби з дати pca_start_dt до 31.12.2999 справа перебувала в ОСЗН pca_org_dest.
    --Всі записи, яких зачіпляє дія "pca_start_dt : 31.12.2999" повинні піти в історію (history_Status = 'A'), запис, дія якого припадає на pca_start_dt,
    --повинен бути "розрізаний" і з новим строком дії (оригінальна дата старту : pca_start_dt -1) вставлений в pc_location.
    --В видалених записих поле pca_hs_del та в створюваному записі поле pca_hs_ins повинне бути заповнене однією і тією ж сессією,
    --яка до того ж співпадає з pca_hs_decision.
    PROCEDURE Recalc_pc_location (p_pc_id      personalcase.pc_id%TYPE,
                                  p_org_dest   pc_location.pl_org%TYPE,
                                  p_start_dt   pc_location.pl_start_dt%TYPE,
                                  p_hs         histsession.hs_id%TYPE,
                                  p_pca_id     pc_attestat.pca_id%TYPE);

    --#81214
    --функция, которая будет "забирать" автоматически справу из 50000 в тот ОСЗН, в который "перекодируется" звернення (часть алгоритма передачи).
    PROCEDURE Check_pc_com_org (p_pd         pc_decision.pd_id%TYPE,
                                p_start_dt   pc_attestat.pca_start_dt%TYPE,
                                p_hs         histsession.hs_id%TYPE);

    -- Функція створення запиту на передачу справи з ОСЗН до ОСЗН.
    FUNCTION Registr_Transmission (p_pd        pc_decision.pd_id%TYPE,
                                   p_msg   OUT VARCHAR2)
        RETURN pc_attestat.pca_id%TYPE;

    -- Функція створення запиту на передачу ОР з ОСЗН до ОСЗН.
    PROCEDURE Registr_Transmission (p_ap_id appeal.ap_id%TYPE);

    -- Функція "Відміна передачі справи з ОСЗН до ОСЗН".
    -- Функція "Відмова передачі справи з ОСЗН до ОСЗН". Заповнюємо p_pcal_message
    PROCEDURE REJECT_Transmission (
        p_pca            pc_attestat.pca_id%TYPE,
        p_pcal_message   pca_log.pcal_message%TYPE:= NULL);

    --Функція "Передача справи з ОСЗН до ОСЗН".
    PROCEDURE APPROVE_Transmission (p_pca pc_attestat.pca_id%TYPE);

    -- #81113
    -- Фукнція провірки можливості виконання дій з pc_decision на основі відповідності pc_decision.com_org & personalcase.com_org & tools.getcurrorg
    PROCEDURE check_right (p_mode    INTEGER, --1=з p_pd_id, 2=з таблиці tmp_chk_ids
                           p_pd_id   pc_decision.pd_id%TYPE,
                           p_level   INTEGER);

    PROCEDURE init_pc_location_internal (p_mode INTEGER); --1=з комітами - для шед.задачі, 2=без комітів. Спосок ЕОС на обробку - через таблицю tmp_work_ids2

    --Запуск ініціалізації pc_location для відкладеної задачі
    PROCEDURE init_pc_location;
END API$PC_ATTESTAT;
/


/* Formatted on 8/12/2025 5:49:08 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$PC_ATTESTAT
IS
    PROCEDURE write_pca_log (p_pcal_pca       pca_log.pcal_pca%TYPE,
                             p_pcal_hs        pca_log.pcal_hs%TYPE,
                             p_pcal_st        pca_log.pcal_st%TYPE,
                             p_pcal_message   pca_log.pcal_message%TYPE,
                             p_pcal_st_old    pca_log.pcal_st_old%TYPE,
                             p_pcal_tp        pca_log.pcal_tp%TYPE:= 'SYS')
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        --l_hs := NVL(p_pcal_hs, TOOLS.GetHistSession);
        l_hs := p_pcal_hs;

        IF l_hs IS NULL
        THEN
            l_hs := TOOLS.GetHistSession;
        END IF;

        INSERT INTO pca_log (pcal_id,
                             pcal_pca,
                             pcal_hs,
                             pcal_st,
                             pcal_message,
                             pcal_st_old,
                             pcal_tp)
             VALUES (0,
                     p_pcal_pca,
                     l_hs,
                     p_pcal_st,
                     p_pcal_message,
                     p_pcal_st_old,
                     p_pcal_tp);
    END;

    -------------------------
    PROCEDURE write_ap_log (p_ap_id     NUMBER,
                            p_ap_st     VARCHAR2,
                            p_message   VARCHAR2)
    IS
    BEGIN
        API$ESR_Action.preparewrite_visit_ap_st (p_eva_ap        => p_ap_id,
                                                 p_eva_st_new    => p_ap_st,
                                                 p_eva_message   => p_message,
                                                 p_hs_ins        => NULL);
    END;

    --===================================================================--
    PROCEDURE ReCreate_Decision (p_ap_id      NUMBER,
                                 p_pa_id      NUMBER,
                                 p_pd_id      NUMBER,
                                 p_start_dt   DATE,
                                 p_dest_org   NUMBER,
                                 p_hs         NUMBER)
    IS
        l_sql_cnt    NUMBER;
        pay_method   pd_pay_method%ROWTYPE;
        l_lock       TOOLS.t_lockhandler;
        l_num        VARCHAR2 (200);
        p_new_id     NUMBER;

        CURSOR pdm (p_pd NUMBER)
        IS
              SELECT p.*
                FROM pd_pay_method p
               WHERE p.pdm_pd = p_pd AND p.history_status = 'A'
            ORDER BY p.pdm_start_dt DESC, p.pdm_id DESC;
    BEGIN
        /*
             FOR rec IN (SELECT t.x_scde, t.x_com_org, t.x_doc_dt, t.x_pc, t.x_pc_com_org, t.x_ap, pd_id AS x_pd_id,
                                LAST_DAY(trunc(x_doc_dt))+1 AS x_start_dt
                         FROM TMP_Event2Decision t
                              JOIN uss_esr.pc_decision ON pd_pc = x_pc
                                                          AND pd_st IN ( 'S' )
                                                          AND pd_nst = 664 ---Поки так, потім розширкмо
                         WHERE EXISTS (SELECT 1
                                       FROM uss_esr.pd_accrual_period
                                       WHERE pdap_pd = pd_id
                                         AND history_status = 'A'
                                         AND t.x_doc_dt BETWEEN pdap_start_dt AND NVL(pdap_stop_dt, t.x_doc_dt))
                         ) LOOP
        */
        API$PC_DECISION.decision_block (p_pd_id,
                                        'CHO',
                                        p_ap_id,
                                        p_hs);
        p_new_id := id_pc_decision (0);

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
            SELECT p_new_id,
                   pd_pc,
                   pd_ap,
                   p_pa_id,
                   TRUNC (SYSDATE),
                   'S'       AS x_st,
                   pd_nst,
                   p_dest_org,
                   com_wu,
                   'PV'      AS x_pd_src,
                   pd_ps     AS x_pd_ps,
                   pd_id,
                   pd_has_right,
                   p_start_dt,
                   pd_stop_dt,
                   p_ap_id,
                   pd_scc
              FROM pc_decision pd
             WHERE pd.pd_id = p_pd_id;

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
             WHERE pds_pd = p_pd_id AND history_status = 'A'
            UNION ALL
            SELECT 0,
                   p_new_id     AS pds_pd,
                   'AN'         AS pds_tp,
                   p_ap_id      AS pds_ap,
                   SYSDATE,
                   'A'
              FROM DUAL;

        FOR pm IN pdm (p_pd_id)
        LOOP
            pay_method := pm;
        END LOOP;

        IF pay_method.pdm_pd IS NOT NULL
        THEN
            pay_method.pdm_id := NULL;
            pay_method.pdm_pd := p_new_id;
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
            SELECT 0            AS x_id,
                   p_new_id     AS x_pd,
                   prl_nrr,
                   prl_result,
                   prl_hs_rewrite,
                   prl_calc_result,
                   prl_calc_info
              FROM pd_right_log prl
             WHERE prl.prl_pd = p_pd_id;

        INSERT INTO pd_features (pde_id,
                                 pde_pd,
                                 pde_nft,
                                 pde_val_int,
                                 pde_val_sum,
                                 pde_val_id,
                                 pde_val_dt,
                                 pde_val_string,
                                 pde_pdf)
            SELECT 0            AS x_id,
                   p_new_id     AS x_pd,
                   pde_nft,
                   pde_val_int,
                   pde_val_sum,
                   pde_val_id,
                   pde_val_dt,
                   pde_val_string,
                   pde_pdf
              FROM pd_features pde
             WHERE pde.pde_pd = p_pd_id;

        INSERT INTO pd_family (pdf_id,
                               pdf_pd,
                               pdf_sc,
                               pdf_birth_dt,
                               pdf_start_dt,
                               pdf_stop_dt,
                               history_status,
                               pdf_hs_ins,
                               pdf_tp)
            SELECT 0            AS x_id,
                   p_new_id     AS x_pd,
                   pdf_sc,
                   pdf_birth_dt,
                   p_start_dt,
                   pdf_stop_dt,
                   'A',
                   p_hs,
                   pdf_tp
              FROM pd_family pdf
             WHERE pdf.pdf_pd = p_pd_id;

        DELETE FROM tmp_work_set1
              WHERE 1 = 1;

        INSERT INTO tmp_work_set1 (x_id1, x_id2)
            SELECT pdp_id, id_pd_payment (0)
              FROM pd_payment pdp
             WHERE pdp.pdp_pd = p_pd_id AND pdp.pdp_stop_dt > p_start_dt;

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
                       p_new_id    AS x_pd,
                       pdp_npt,
                       CASE
                           WHEN pdp_start_dt < p_start_dt THEN p_start_dt
                           ELSE pdp_start_dt
                       END         AS x_start_dt,
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
                           WHEN pdd_start_dt < p_start_dt THEN p_start_dt
                           ELSE pdd_start_dt
                       END
                           AS x_start_dt,
                       pdd_stop_dt,
                       pdd_npt
                  FROM pd_detail pdd JOIN tmp_work_set1 ON x_id1 = pdd_pdp;
        ELSE
            INSERT INTO tmp_work_set1 (x_id1, x_id2)
                SELECT pdp_id, id_pd_payment (0)
                  FROM pd_payment pdp
                 WHERE     pdp.pdp_pd = p_pd_id
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
                       p_new_id    AS x_pd,
                       pdp_npt,
                       CASE
                           WHEN pdp_start_dt < p_start_dt THEN p_start_dt
                           ELSE pdp_start_dt
                       END         AS x_start_dt,
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
                SELECT 0      AS x_id,
                       x_id2,
                       pdd_row_order,
                       pdd_row_name,
                       pdd_value,
                       pdd_key,
                       pdd_ndp,
                       CASE
                           WHEN pdd_start_dt < P_start_dt THEN P_start_dt
                           ELSE pdd_start_dt
                       END    AS x_start_dt,
                       pdd_stop_dt,
                       pdd_npt
                  FROM pd_detail pdd JOIN tmp_work_set1 ON x_id1 = pdd_pdp;
        END IF;

        api$pc_decision.recalc_pd_periods_fs (p_new_id, p_hs);

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
                                 AND pd_id = p_new_id
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

            l_num := API$PC_DECISION.gen_pd_num (xx.pc_id);

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
                p_ap_id,
                'V',
                   CHR (38)
                || '11#'
                || l_num
                || '#'
                || xx.pc_num
                || '#'
                || xx.nst_name);
        END LOOP;
    END;

    PROCEDURE move_pc_account (p_rec_pca pc_attestat%ROWTYPE, p_hs NUMBER)
    IS
        l_account    pc_account%ROWTYPE;
        l_new_id     NUMBER;
        l_start_dt   DATE;
        l_num        pc_account.pa_num%TYPE;

        -----------------------------
        CURSOR decision IS
            SELECT pd.*
              FROM pc_decision pd
             WHERE     pd.pd_pa = p_rec_pca.pca_pa
                   AND EXISTS
                           (SELECT 1
                              FROM uss_esr.pd_accrual_period
                             WHERE     pdap_pd = pd_id
                                   AND history_status = 'A'
                                   AND l_start_dt BETWEEN pdap_start_dt
                                                      AND NVL (pdap_stop_dt,
                                                               l_start_dt));
    BEGIN
        l_start_dt := TRUNC (ADD_MONTHS (SYSDATE, 1), 'MM');

        SELECT pa.*
          INTO l_account
          FROM pc_account pa
         WHERE pa.pa_id = p_rec_pca.pca_pa;

        -- Перевіримо, може вже є потрібний account
        SELECT MAX (pa.pa_id)
          INTO l_new_id
          FROM pc_account pa
         WHERE     pa.pa_pc = p_rec_pca.pca_pc
               AND pa.pa_org = p_rec_pca.pca_org_dest
               AND pa.pa_nst = l_account.pa_nst;

        IF l_new_id IS NULL
        THEN
            l_new_id := id_pc_account (0);
            l_num := API$PC_DECISION.gen_pa_num (p_rec_pca.pca_pc);

            INSERT INTO pc_account (pa_id,
                                    pa_pc,
                                    pa_num,
                                    pa_nst,
                                    pa_stage,
                                    pa_org)
                 VALUES (l_new_id,
                         p_rec_pca.pca_pc,
                         l_num,
                         l_account.pa_nst,
                         l_account.pa_stage,
                         p_rec_pca.pca_org_dest);
        END IF;


        FOR rec IN decision
        LOOP
            ReCreate_Decision (p_ap_id      => p_rec_pca.pca_ap_reason,
                               p_pa_id      => l_new_id,
                               p_pd_id      => rec.pd_id,
                               p_start_dt   => l_start_dt,
                               p_dest_org   => p_rec_pca.pca_org_dest,
                               p_hs         => p_hs);
            NULL;
        END LOOP;
    END;

    -------------------------
    PROCEDURE Check_pc_location (p_pca   pc_attestat%ROWTYPE,
                                 p_hs    histsession.hs_id%TYPE)
    IS
        cnt_err   NUMBER;
    BEGIN
        WITH
            all_dt
            AS
                (SELECT TRUNC (pl.pl_start_dt)     AS u_dt
                   FROM uss_esr.pc_location pl
                  WHERE pl.pl_pc = p_pca.pca_pc AND pl.history_status = 'A'
                 UNION
                 SELECT TRUNC (pl.pl_stop_dt)
                   FROM uss_esr.pc_location pl
                  WHERE pl.pl_pc = p_pca.pca_pc AND pl.history_status = 'A')
        SELECT COUNT (1)
          INTO cnt_err
          FROM all_dt
         WHERE 1 <
               (SELECT COUNT (1)
                  FROM uss_esr.pc_location pl
                 WHERE     pl.pl_pc = p_pca.pca_pc
                       AND pl.history_status = 'A'
                       AND u_dt BETWEEN TRUNC (pl.pl_start_dt)
                                    AND TRUNC (pl.pl_stop_dt));

        IF cnt_err > 0
        THEN
            write_pca_log (
                p_pca.pca_id,
                p_hs,
                p_pca.pca_st,
                   'Помилка формування періоду дії персональної справи. Дата розриву '
                || TO_CHAR (p_pca.pca_start_dt, 'dd.mm.yyyy'),
                p_pca.pca_st);
            raise_application_error (
                -20000,
                   'Помилка формування періоду дії персональної справи. Дата розриву '
                || TO_CHAR (p_pca.pca_start_dt, 'dd.mm.yyyy'));
        END IF;
    END;

    --Змінює "Історія перебування справи в ОСЗН" (uss_esr.pc_location) таким чином, аби з дати pca_start_dt до 31.12.2999 справа перебувала в ОСЗН pca_org_dest.
    --Всі записи, яких зачіпляє дія "pca_start_dt : 31.12.2999" повинні піти в історію (history_Status = 'A'), запис, дія якого припадає на pca_start_dt,
    --повинен бути "розрізаний" і з новим строком дії (оригінальна дата старту : pca_start_dt -1) вставлений в pc_location.
    --В видалених записих поле pca_hs_del та в створюваному записі поле pca_hs_ins повинне бути заповнене однією і тією ж сессією,
    --яка до того ж співпадає з pca_hs_decision.
    PROCEDURE Recalc_pc_location (p_pc_id      personalcase.pc_id%TYPE,
                                  p_org_dest   pc_location.pl_org%TYPE,
                                  p_start_dt   pc_location.pl_start_dt%TYPE,
                                  p_hs         histsession.hs_id%TYPE,
                                  p_pca_id     pc_attestat.pca_id%TYPE)
    IS
        l_cnt       NUMBER;
        l_stop_dt   DATE := TO_DATE ('31.12.2999', 'dd.mm.yyyy');
    BEGIN
        IF p_start_dt IS NULL
        THEN
            raise_application_error (
                -20000,
                'Не налаштовано поточний розрахунковий період!');
        END IF;

        SELECT COUNT (1)
          INTO l_cnt
          FROM pc_location pcl
         WHERE     pcl.pl_pc = p_pc_id
               AND pcl.history_status = 'A'
               AND p_start_dt BETWEEN pcl.pl_start_dt AND pcl.pl_stop_dt;

        --- #88716  Приберемо наступні періоди
        UPDATE pc_location pcl
           SET pcl.history_status = 'H', pcl.pl_hs_del = p_hs
         WHERE     pcl.pl_pc = p_pc_id
               AND pcl.pl_start_dt > p_start_dt
               AND pcl.history_status = 'A';

        IF l_cnt > 0
        THEN
            FOR rec
                IN (SELECT *
                      FROM pc_location pcl
                     WHERE     pcl.pl_pc = p_pc_id
                           AND pcl.history_status = 'A'
                           AND p_start_dt BETWEEN pcl.pl_start_dt
                                              AND pcl.pl_stop_dt)
            LOOP
                UPDATE pc_location pcl
                   SET pcl.history_status = 'H', pcl.pl_hs_del = p_hs
                 WHERE pcl.pl_id = rec.pl_id;

                INSERT INTO pc_location (pl_id,
                                         pl_pc,
                                         pl_org,
                                         pl_start_dt,
                                         pl_stop_dt,
                                         history_status,
                                         pl_hs_ins,
                                         pl_pca)
                     VALUES (0,
                             rec.pl_pc,
                             rec.pl_org,
                             rec.pl_start_dt,
                             p_start_dt - 1,
                             'A',
                             p_hs,
                             p_pca_id);

                INSERT INTO pc_location (pl_id,
                                         pl_pc,
                                         pl_org,
                                         pl_start_dt,
                                         pl_stop_dt,
                                         history_status,
                                         pl_hs_ins,
                                         pl_pca)
                     VALUES (0,
                             rec.pl_pc,
                             p_org_dest,
                             p_start_dt,
                             l_stop_dt,
                             'A',
                             p_hs,
                             p_pca_id);

                NULL;
            END LOOP;
        ELSE
            INSERT INTO pc_location (pl_id,
                                     pl_pc,
                                     pl_org,
                                     pl_start_dt,
                                     pl_stop_dt,
                                     history_status,
                                     pl_hs_ins,
                                     pl_pca)
                 VALUES (0,
                         p_pc_id,
                         p_org_dest,
                         p_start_dt,
                         l_stop_dt,
                         'A',
                         p_hs,
                         p_pca_id);
        END IF;
    END;

    --#81214
    --функция, которая будет "забирать" автоматически справу из 50000 в тот ОСЗН, в который "перекодируется" звернення (часть алгоритма передачи).
    PROCEDURE Check_pc_com_org (p_pd         pc_decision.pd_id%TYPE,
                                p_start_dt   pc_attestat.pca_start_dt%TYPE,
                                p_hs         histsession.hs_id%TYPE)
    IS
        l_start_dt   pc_attestat.pca_start_dt%TYPE;
        l_pc_id      personalcase.pc_id%TYPE;
        l_org_src    personalcase.com_org%TYPE;
        l_org_dest   pc_decision.com_org%TYPE;
        l_ap         appeal.ap_id%TYPE;
    BEGIN
        SELECT pc.pc_id,
               pc.com_org,
               pd.com_org,
               pd_ap
          INTO l_pc_id,
               l_org_src,
               l_org_dest,
               l_ap
          FROM pc_decision pd JOIN personalcase pc ON pc.pc_id = pd.pd_pc
         WHERE pd.pd_id = p_pd;

        IF l_org_src = '50000'
        THEN
            SELECT MAX (bp_month)
              INTO l_start_dt
              FROM billing_period
             WHERE bp_org = l_org_dest AND bp_class = 'V' AND bp_st = 'R';

            IF l_start_dt IS NULL
            THEN
                raise_application_error (
                    -20000,
                       'Не налаштовано поточний розрахунковий період по ОСЗН '
                    || NVL ('' || l_org_dest, '-')
                    || '! (ap='
                    || l_ap
                    || ')');
            END IF;

            --Змінює в записі personalcase com_org на pca_org_dest;
            UPDATE personalcase
               SET personalcase.com_org = l_org_dest
             WHERE pc_id = l_pc_id;

            Recalc_pc_location (l_pc_id,
                                l_org_dest,
                                l_start_dt,
                                p_hs,
                                NULL);
        END IF;
    END;


    -- Функція створення запиту на передачу справи з ОСЗН до ОСЗН.
    FUNCTION Registr_Transmission (p_pd        pc_decision.pd_id%TYPE,
                                   p_msg   OUT VARCHAR2)
        RETURN pc_attestat.pca_id%TYPE
    IS
        l_pca         pc_attestat.pca_id%TYPE;
        l_start_dt    pc_attestat.pca_start_dt%TYPE;
        l_hs          histsession.hs_id%TYPE;
        l_pc_id       personalcase.pc_id%TYPE;
        l_org_src     personalcase.com_org%TYPE;
        l_org_dest    pc_decision.com_org%TYPE;
        l_ap_reason   pc_decision.pd_ap%TYPE;
        l_pd_st       pc_decision.pd_st%TYPE;
        l_ap_src      appeal.ap_src%TYPE;
        l_cnt_pca     NUMBER;
    BEGIN
        SELECT pc.pc_id,
               pc.com_org,
               pd.com_org,
               pd.pd_ap,
               pd.pd_st,
               ap_src,
               (SELECT COUNT (1)
                  FROM pc_attestat
                 WHERE pca_pc = pc.pc_id AND pca_st = 'O')
          INTO l_pc_id,
               l_org_src,
               l_org_dest,
               l_ap_reason,
               l_pd_st,
               l_ap_src,
               l_cnt_pca
          FROM pc_decision  pd
               JOIN personalcase pc ON pc.pc_id = pd.pd_pc
               JOIN appeal ap ON ap.ap_id = pd.pd_ap
         WHERE pd.pd_id = p_pd;

        IF l_org_src = l_org_dest
        THEN
            raise_application_error (
                -20000,
                '"ОСЗН рішення" та "ОСЗН-власника справи" співпадають!');
        END IF;

        IF l_pd_st != 'R0' AND l_ap_src != 'ASOPD'
        THEN
            raise_application_error (-20000,
                                     'Рішення не в статусі "Розраховано"!');
        END IF;

        IF l_cnt_pca != 0
        THEN
            raise_application_error (-20000,
                                     'Вже є запити на "Передачу справи"!');
        END IF;

        l_pca := id_pc_attestat (0);

        --pca_start_dt = поточний розрахунковий період за классом "послуги" (bp_class = 'V');
        SELECT MAX (bp_month)
          INTO l_start_dt
          FROM billing_period, tmp_org
         WHERE     bp_org = u_org
               AND bp_class = 'VPO'
               AND bp_st = 'R'
               AND bp_tp = 'PR';

        IF l_start_dt IS NULL
        THEN
            raise_application_error (
                -20000,
                'Не налаштовано поточний розрахунковий період!');
        END IF;

        l_hs := TOOLS.GetHistSession;

        IF l_org_src = '50000'
        THEN
            --Змінює в записі personalcase com_org на pca_org_dest;
            UPDATE personalcase
               SET personalcase.com_org = l_org_dest
             WHERE pc_id = l_pc_id;

            Recalc_pc_location (l_pc_id,
                                l_org_dest,
                                l_start_dt,
                                l_hs,
                                NULL);
            p_msg :=
                'Передано з ' || TO_CHAR (TRUNC (l_start_dt), 'dd.mm.yyyy');
            RETURN NULL;
        END IF;

        INSERT INTO pc_attestat (pca_id,
                                 pca_pc,
                                 pca_st,
                                 pca_org_src,
                                 pca_org_dest,
                                 pca_ap_reason,
                                 pca_hs_ins,
                                 pca_doc_num,
                                 pca_doc_dt,
                                 pca_start_dt,
                                 pca_pd,
                                 pca_tp)
             VALUES (l_pca,
                     l_pc_id,
                     'O',
                     l_org_src,
                     l_org_dest,
                     l_ap_reason,
                     l_hs,
                     l_pca,
                     TRUNC (SYSDATE),
                     l_start_dt,
                     p_pd,
                     'PC');

        IF l_ap_src != 'ASOPD'
        THEN
            UPDATE pc_decision pd
               SET pd.pd_st = 'TR'
             WHERE pd.pd_id = p_pd;
        END IF;

        SELECT o.org_code || ', ' || o.org_name
          INTO p_msg
          FROM v_opfu o
         WHERE o.org_id = l_org_dest;

        write_pca_log (
            l_pca,
            L_hs,
            'O',
               CHR (38)
            || '125#'
            || l_pca
            || '#'
            || TO_CHAR (TRUNC (SYSDATE), 'dd.mm.yyyy'),
            'O');

        api$pc_decision.write_pd_log (
            p_pdl_pd        => p_pd,
            p_pdl_hs        => L_hs,
            p_pdl_st        => l_pd_st,
            p_pdl_message   => CHR (38) || '131#' || p_msg,
            p_pdl_st_old    => l_pd_st);

        p_msg :=
               'Запит створено, № '
            || l_pca
            || ' від '
            || TO_CHAR (TRUNC (SYSDATE), 'dd.mm.yyyy');
        RETURN l_pca;
    END;

    -- Функція створення запиту на передачу справи з ОСЗН до ОСЗН.
    --Потрібна нова функція (або новий режим) створення pc_attestat по зверненню з послугою 1021 - яка буде приймати тільки ід звернення.
    --За цією функцією потрібно створити запит на передачу ОР - з заповненням pca_pa та pca_tp='PA'.
    --Відповідно, звернення повинно змінювати статус на "в обробці", а налогічно обробці "проектів рішень" по зверенню та донесення цих змін до ЄСП.
    PROCEDURE Registr_Transmission (p_ap_id appeal.ap_id%TYPE)
    IS
        l_msg        VARCHAR2 (2000);
        l_pca        pc_attestat.pca_id%TYPE;
        l_start_dt   pc_attestat.pca_start_dt%TYPE;
        l_hs         histsession.hs_id%TYPE;
        l_pc_id      personalcase.pc_id%TYPE;
        l_org_dest   pc_decision.com_org%TYPE;
        l_ap_src     appeal.ap_src%TYPE;
        l_nst        NUMBER;
        l_cnt_pca    NUMBER;
        l_cnt_nst    NUMBER;
    BEGIN
        SELECT pc.pc_id,
               ap.com_org,
               (SELECT COUNT (1)
                  FROM pc_attestat
                 WHERE pca_pc = pc.pc_id AND pca_st = 'O'),
               (SELECT COUNT (1)
                  FROM ap_service aps
                 WHERE     aps_ap = ap_id
                       AND aps_nst = 1021
                       AND aps.history_status = 'A')
          INTO l_pc_id,
               l_org_dest,
               l_cnt_pca,
               l_cnt_nst
          FROM personalcase pc JOIN appeal ap ON ap.ap_pc = pc.pc_id
         WHERE ap_id = p_ap_id;

        l_nst :=
            TO_NUMBER (
                api$appeal.Get_Ap_Doc_Str (p_Ap_Id,
                                           'Z',
                                           4375,
                                           '')
                    DEFAULT NULL ON CONVERSION ERROR);

        /*
            IF l_org_src = l_org_dest THEN
              raise_application_error(-20000, '"ОСЗН рішення" та "ОСЗН-власника справи" співпадають!');
            END IF;
        */
        IF l_cnt_pca != 0
        THEN
            raise_application_error (-20000,
                                     'Вже є запити на "Передачу справи"!');
        END IF;

        IF l_cnt_nst = 0
        THEN
            raise_application_error (-20000, 'Відсутня послуга 1021!');
        END IF;

        --pca_start_dt = поточний розрахунковий період за классом "послуги" (bp_class = 'V');
        SELECT MAX (bp_month)
          INTO l_start_dt
          FROM billing_period, tmp_org
         WHERE     bp_org = u_org
               AND bp_class = 'VPO'
               AND bp_st = 'R'
               AND bp_tp = 'PR';

        IF l_start_dt IS NULL
        THEN
            raise_application_error (
                -20000,
                'Не налаштовано поточний розрахунковий період!');
        END IF;

        l_hs := TOOLS.GetHistSession;
        l_cnt_pca := 0;

        FOR rec
            IN (SELECT *
                  FROM pc_account pa
                 WHERE     pa.pa_pc = l_pc_id
                       AND pa.pa_nst = l_nst
                       AND pa.pa_org != l_org_dest)
        LOOP
            l_pca := id_pc_attestat (0);

            INSERT INTO pc_attestat (pca_id,
                                     pca_pc,
                                     pca_st,
                                     pca_org_src,
                                     pca_org_dest,
                                     pca_ap_reason,
                                     pca_hs_ins,
                                     pca_doc_num,
                                     pca_doc_dt,
                                     pca_start_dt,
                                     pca_tp,
                                     pca_pa)
                 VALUES (l_pca,
                         l_pc_id,
                         'O',
                         rec.pa_org,
                         l_org_dest,
                         p_ap_id,
                         l_hs,
                         l_pca,
                         TRUNC (SYSDATE),
                         l_start_dt,
                         'PA',
                         rec.pa_id);

            SELECT o.org_code || ', ' || o.org_name
              INTO l_msg
              FROM v_opfu o
             WHERE o.org_id = l_org_dest;

            write_pca_log (
                l_pca,
                L_hs,
                'O',
                   CHR (38)
                || '125#'
                || l_pca
                || '#'
                || TO_CHAR (TRUNC (SYSDATE), 'dd.mm.yyyy'),
                'O');
            API$ESR_Action.preparewrite_visit_ap_st (
                p_eva_ap        => p_ap_id,
                p_eva_st_new    => 'WD',
                p_eva_message   =>
                       CHR (38)
                    || '125#'
                    || l_pca
                    || '#'
                    || TO_CHAR (TRUNC (SYSDATE), 'dd.mm.yyyy'),
                p_hs_ins        => l_hs);
            l_cnt_pca := l_cnt_pca + 1;
        END LOOP;

        IF l_cnt_pca = 0
        THEN
            raise_application_error (
                -20000,
                'Не знайдено особових рахунків для передачі!');
        ELSE
            UPDATE Appeal
               SET Ap_St = 'WD'
             WHERE ap_id = p_ap_id;
        END IF;
    END;

    /*
  O Очікує рішення
  A Дозволено передачу
  R Відмовлено в передачі
  C Відмінено
  */
    /*
    122 Відмінено передачу справи між ОСЗН.
    123 Відмовлено в передачі справи між ОСЗН. Причина #.
    */

    -- Функція "Відміна передачі справи з ОСЗН до ОСЗН".
    -- Функція "Відмова передачі справи з ОСЗН до ОСЗН". Заповнюємо p_pcal_message
    PROCEDURE REJECT_Transmission (
        p_pca            pc_attestat.pca_id%TYPE,
        p_pcal_message   pca_log.pcal_message%TYPE:= NULL)
    IS
        l_hs        HistSession.Hs_Id%TYPE;
        l_rec_pca   pc_attestat%ROWTYPE;
    BEGIN
        SELECT *
          INTO l_rec_pca
          FROM pc_attestat
         WHERE pca_id = p_pca;

        IF NOT tools.CheckUserRole ('W_ESR_PAY_OPER')
        THEN
            raise_application_error (
                -20000,
                'Немає прав для виконання данної операції!');
        END IF;

        --    IF l_rec_pca.pca_org_dest != tools.getcurrorg THEN
        IF     l_rec_pca.pca_org_src != tools.getcurrorg
           AND l_rec_pca.pca_org_dest != tools.getcurrorg
        THEN
            raise_application_error (-20000,
                                     '"Передачі справи" не вашого ОСЗН!');
        END IF;

        IF l_rec_pca.pca_st != 'O'
        THEN
            raise_application_error (
                -20000,
                '"Передачі справи" не в статусі "Очікує рішення"!');
        END IF;

        l_hs := tools.GetHistSession;

        IF l_rec_pca.pca_tp = 'PA'
        THEN
            UPDATE pc_attestat
               SET pc_attestat.pca_hs_decision = l_hs,
                   pc_attestat.pca_st = 'C'
             WHERE pca_id = p_pca AND l_rec_pca.pca_tp != 'PA';

            write_pca_log (p_pca,
                           L_hs,
                           'C',
                           CHR (38) || '122',
                           'O');

            API$ESR_Action.preparewrite_visit_ap_st (
                p_eva_ap        => l_rec_pca.pca_ap_reason,
                p_eva_st_new    => 'WD',
                p_eva_message   => CHR (38) || '122',
                p_hs_ins        => l_hs);

            RETURN;
        ELSIF p_pcal_message IS NULL
        THEN
            UPDATE pc_attestat
               SET pc_attestat.pca_hs_decision = l_hs,
                   pc_attestat.pca_st = 'C'
             WHERE pca_id = p_pca AND l_rec_pca.pca_tp != 'PA';

            write_pca_log (p_pca,
                           L_hs,
                           'C',
                           CHR (38) || '122',
                           'O');
        ELSE
            UPDATE pc_attestat
               SET pc_attestat.pca_hs_decision = l_hs,
                   pc_attestat.pca_st = 'R'
             WHERE pca_id = p_pca AND l_rec_pca.pca_tp != 'PA';

            write_pca_log (p_pca,
                           L_hs,
                           'R',
                           CHR (38) || '123#' || p_pcal_message,
                           'O');
        END IF;

        UPDATE pc_decision
           SET pd_st = 'R0'
         WHERE pd_ap = l_rec_pca.pca_ap_reason AND pd_st = 'TR';
    END;

    --Abolition
    --Refusal
    -- Функція "Відмова передачі справи з ОСЗН до ОСЗН".
    -- Функція "Передача справи з ОСЗН до ОСЗН".

    /*
    Передача:
    Контроль:
    на "чи мій запит" (pca_org_src = tools.getcurrorg) та статус "Очікує рішення";
    Чи немає Нарахувань не в стані "Діючий";

    */
    --Передача:
    PROCEDURE APPROVE_Transmission (p_pca pc_attestat.pca_id%TYPE)
    IS
        l_hs        HistSession.Hs_Id%TYPE;
        l_rec_pca   pc_attestat%ROWTYPE;
        l_ap_src    appeal.ap_src%TYPE;
        l_acc_org   NUMBER;
        l_cnt_err   NUMBER;
        l_cnt       NUMBER;
        l_pd_id     NUMBER;
        l_pd_st     VARCHAR2 (20);
        l_msg       VARCHAR2 (2000);
    BEGIN
        SELECT *
          INTO l_rec_pca
          FROM pc_attestat
         WHERE pca_id = p_pca;

        SELECT ap_src
          INTO l_ap_src
          FROM appeal
         WHERE ap_id = l_rec_pca.pca_ap_reason;

        SELECT MAX (o.org_acc_org)
          INTO l_acc_org
          FROM v_opfu o
         WHERE o.org_id = l_rec_pca.pca_org_src AND o.org_st = 'A';

        IF NOT tools.CheckUserRole ('W_ESR_PAY_OPER')
        THEN
            raise_application_error (
                -20000,
                'Немає прав для виконання данної операції!');
        END IF;

        --    IF l_rec_pca.pca_org_dest != tools.getcurrorg THEN
        IF tools.getcurrorg NOT IN (l_rec_pca.pca_org_src, l_acc_org)
        THEN
            raise_application_error (-20000,
                                     '"Передачі справи" не вашого ОСЗН!');
        --      raise_application_error(-20000, '"Передачі справи" не вашого ОСЗН! dest='||l_rec_pca.pca_org_dest ||' src='||l_rec_pca.pca_org_src||'   currorg='||tools.getcurrorg);
        END IF;

        IF l_rec_pca.pca_st != 'O'
        THEN
            raise_application_error (
                -20000,
                '"Передачі справи" не в статусі "Очікує рішення"!');
        END IF;

        IF l_rec_pca.pca_tp = 'PA'
        THEN                  -- Це окремо, передаються тільки особові рахунки
            move_pc_account (l_rec_pca, l_hs);
        ELSIF l_ap_src = 'ASOPD'
        THEN
            SELECT COUNT (1)
              INTO l_cnt_err
              FROM pc_decision
             WHERE     pd_pc = l_rec_pca.pca_pc
                   AND pd_st NOT IN ('PS', 'V')
                   AND pd_nst = 664
                   AND com_org = l_rec_pca.pca_org_src
                   AND NOT (pd_ap = l_rec_pca.pca_ap_reason AND pd_st = 'TR');

            SELECT MAX (pd_id), MAX (pd_st)
              INTO l_pd_id, l_pd_st
              FROM pc_decision pd
             WHERE pd_ap = l_rec_pca.pca_ap_reason;


            IF l_cnt_err > 0
            THEN
                raise_application_error (
                    -20000,
                    'На момент передачі всі рішення на справі повинні бути в статусах "Призупинено", "Відмовлено"!');
            END IF;
        ELSE
            --Додатковий контроль: на момент передачі всі рішення на справі повинні бути в статусах "Нараховано", "Призупинено", "Відмовлено".
            SELECT COUNT (1)
              INTO l_cnt_err
              FROM pc_decision
             WHERE     pd_pc = l_rec_pca.pca_pc
                   AND pd_st NOT IN ('PS', 'V')
                   AND pd_nst NOT IN (732, 1101)
                   AND com_org = l_rec_pca.pca_org_src
                   AND NOT (pd_ap = l_rec_pca.pca_ap_reason AND pd_st = 'TR');

            SELECT pd_id, pd_st
              INTO l_pd_id, l_pd_st
              FROM pc_decision pd
             WHERE pd_ap = l_rec_pca.pca_ap_reason AND pd_st = 'TR';


            IF l_cnt_err > 0
            THEN
                raise_application_error (
                    -20000,
                    'На момент передачі всі рішення на справі повинні бути в статусах "Призупинено", "Відмовлено"!');
            END IF;

            --повернення рішення в статусі "Очікує передачі справи", пов'язаного з pca_ap_reason, в стан R0;
            UPDATE pc_decision
               SET pd_st = 'R0'
             WHERE pd_ap = l_rec_pca.pca_ap_reason AND pd_st = 'TR';
        END IF;

        l_hs := tools.GetHistSession;

        --проставляє статус "Дозволено передачу", заповнює pca_hs_decision, пише запис в pca_log;
        UPDATE pc_attestat
           SET pc_attestat.pca_hs_decision = l_hs, pc_attestat.pca_st = 'A'
         WHERE pca_id = p_pca;

        write_pca_log (p_pca,
                       L_hs,
                       'A',
                       CHR (38) || '124',
                       'O');

        -- тут не обробляється personalcase
        IF l_rec_pca.pca_tp = 'PA'
        THEN
            RETURN;
        END IF;

        --Змінює в записі personalcase com_org на pca_org_dest;
        UPDATE personalcase
           SET personalcase.com_org = l_rec_pca.pca_org_dest
         WHERE pc_id = l_rec_pca.pca_pc;

        SELECT o.org_code || ', ' || o.org_name
          INTO l_msg
          FROM v_opfu o
         WHERE o.org_id = l_rec_pca.pca_org_src;

        api$pc_decision.write_pd_log (
            p_pdl_pd        => l_pd_id,
            p_pdl_hs        => L_hs,
            p_pdl_st        => l_pd_st,
            p_pdl_message   => CHR (38) || '132#' || l_msg,
            p_pdl_st_old    => l_pd_st);



        Recalc_pc_location (l_rec_pca.pca_pc,
                            l_rec_pca.pca_org_dest,
                            l_rec_pca.pca_start_dt,
                            l_hs,
                            l_rec_pca.pca_id);

        Check_pc_location (l_rec_pca, l_hs);
    END;

    /*
    Функція повинна отримувати в режимі "1" id рішення, код дії та перевіряти відповідність з subj. Якщо є не відповідність - генерувати виключення з повідомленням "Дії з рішеннями по справі з ОСЗН <код> не дозволені".

    Відомі на поточний момент сполучення:
    1. Будь-яка дія : pc_decision.com_org = personalcase.com_org = tools.getcurrorg => OK; Свої рішення кожен ОСЗН може редагувати як хоче
    2. Перевірка права : (tools.getcurrorg = pc_decision.com_org) != personalcase.com_org => OK; Мається на увазі, що можна створити проект рішення та перевірити право.
    3. Затвердження : tools.getcurrorg = 50001 != (pc_decision.com_org) = personalcase.com_org) => OK; ІОЦ має право перевести рішення з "Призначено" до "Нараховано" і все
    4. Призупинення : (tools.getcurrorg = personalcase.com_org) != pc_decision.com_org => OK; Рішення Своїх справ, навіть створених в чужих ОСЗН, користувач ОСЗН має право призупинити
    5. Поновлення : (tools.getcurrorg = personalcase.com_org) != pc_decision.com_org => OK; Рішення Своїх справ, навіть створених в чужих ОСЗН, користувач ОСЗН має право поновити

    Вбудувати виклик у всі функції, як по кнопкам викликаються з інтерфейсу:

    Форма визначення права:
    Перевірка права;
    Підтвердження права;
    Відмова в праві;
    Повернення на опрацювання;

    Форма розрахунку доходу:
    Розрахунок доходу;
    Додавання доходу;

    Форма розрахунку призначення
    Збереження;
    Затвердження;
    Повернення на опрацювання;
    Затвердження з підписом;
    Поновлення виплати;
    Припинення виплати;
    Активація нарахування.

    В режимі 2 повинна приймати через нову таблицю tmp_chk_ids (x_id) перелік id-ів рішень та виконувати те ж саме - якщо відопвідають, ок,
    --якщо не відопвідають - виключення з текстом "Спроба виконати дію над рішеннями справ, які не належать ОСЗН <tools.getcurrorg> (рішення № <номер будь-якого рішення>
    --та ще <кількість рішень, якщо більше 1>)!".
    */

    -- #81113
    -- Фукнція провірки можливості виконання дій з pc_decision на основі відповідності pc_decision.com_org & personalcase.com_org & tools.getcurrorg
    PROCEDURE check_right (p_mode    INTEGER, --1=з p_pd_id, 2=з таблиці tmp_chk_ids
                           p_pd_id   pc_decision.pd_id%TYPE,
                           p_level   INTEGER)
    IS
        l_cnt       INTEGER;
        l_CurrOrg   NUMBER := tools.GetCurrOrg;
        l_err_txt   VARCHAR2 (2000);
    BEGIN
        IF p_mode = 1 AND p_pd_id IS NOT NULL
        THEN
            DELETE FROM tmp_chk_ids
                  WHERE 1 = 1;

            INSERT INTO tmp_chk_ids (x_id)
                SELECT pd_id
                  FROM pc_decision
                 WHERE pd_id = p_pd_id;

            l_cnt := SQL%ROWCOUNT;
        ELSE
            SELECT COUNT (*)
              INTO l_cnt
              FROM tmp_chk_ids, pc_decision
             WHERE x_id = pd_id;
        END IF;

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'В функцію провірки можливості виконання дій не передано ідентифікаторів проектів рішень!');
        END IF;

        IF p_level = 1
        THEN
            --1. Будь-яка дія : pc_decision.com_org = personalcase.com_org = tools.getcurrorg => OK; Свої рішення кожен ОСЗН може редагувати як хоче
            WITH
                err
                AS
                    (SELECT FIRST_VALUE (pd.pd_num) OVER (ORDER BY pd_num)    AS pd_num
                       FROM tmp_chk_ids
                            JOIN pc_decision pd ON pd.pd_id = x_id
                            JOIN personalcase pc ON pc.pc_id = pd.pd_pc
                      WHERE CASE
                                WHEN    l_CurrOrg != pc.com_org
                                     OR l_CurrOrg != pd.com_org
                                THEN
                                    1
                                ELSE
                                    0
                            END =
                            1),
                cnt
                AS
                    (SELECT COUNT (pd_num) AS cnt_err, MAX (pd_num) AS pd_num
                       FROM err)
            SELECT CASE
                       WHEN cnt_err = 1
                       THEN
                              'Спроба виконати дію над рішеннями справ, які не належать ОСЗН '
                           || l_CurrOrg
                           || ' ( рішення № '
                           || pd_num
                           || ' )!'
                       WHEN cnt_err > 1
                       THEN
                              'Спроба виконати дію над рішеннями справ, які не належать ОСЗН '
                           || l_CurrOrg
                           || ' ( рішення № '
                           || pd_num
                           || ' та ще '
                           || cnt_err
                           || ' )!'
                       ELSE
                           ''
                   END    AS err_txt
              INTO l_err_txt
              FROM cnt;
        ELSIF p_level = 2
        THEN
            --2. Перевірка права : (tools.getcurrorg = pc_decision.com_org) != personalcase.com_org => OK;
            --   Мається на увазі, що можна створити проект рішення та перевірити право.
            WITH
                err
                AS
                    (SELECT FIRST_VALUE (pd.pd_num) OVER (ORDER BY pd_num)    AS pd_num
                       FROM tmp_chk_ids
                            JOIN pc_decision pd ON pd.pd_id = x_id
                            JOIN personalcase pc ON pc.pc_id = pd.pd_pc
                      WHERE CASE
                                WHEN     l_CurrOrg = pd.com_org
                                     AND l_CurrOrg != pc.com_org
                                THEN
                                    0
                                ELSE
                                    1
                            END =
                            1),
                cnt
                AS
                    (SELECT COUNT (pd_num) AS cnt_err, MAX (pd_num) AS pd_num
                       FROM err)
            SELECT CASE
                       WHEN cnt_err = 1
                       THEN
                              'Спроба виконати дію над рішеннями справ, які не належать ОСЗН '
                           || l_CurrOrg
                           || ' ( рішення № '
                           || pd_num
                           || ' )!'
                       WHEN cnt_err > 1
                       THEN
                              'Спроба виконати дію над рішеннями справ, які не належать ОСЗН '
                           || l_CurrOrg
                           || ' ( рішення № '
                           || pd_num
                           || ' та ще '
                           || cnt_err
                           || ' )!'
                       ELSE
                           ''
                   END    AS err_txt
              INTO l_err_txt
              FROM cnt;
        ELSIF p_level = 2
        THEN
            --3. Затвердження : tools.getcurrorg = 50001 != (pc_decision.com_org) = personalcase.com_org) => OK;
            --   ІОЦ має право перевести рішення з "Призначено" до "Нараховано" і все
            WITH
                err
                AS
                    (SELECT FIRST_VALUE (pd.pd_num) OVER (ORDER BY pd_num)    AS pd_num
                       FROM tmp_chk_ids
                            JOIN pc_decision pd ON pd.pd_id = x_id
                            JOIN personalcase pc ON pc.pc_id = pd.pd_pc
                      WHERE CASE
                                WHEN     l_CurrOrg = 5001
                                     AND pc.com_org = pd.com_org
                                THEN
                                    1
                                ELSE
                                    0
                            END =
                            1),
                cnt
                AS
                    (SELECT COUNT (pd_num) AS cnt_err, MAX (pd_num) AS pd_num
                       FROM err)
            SELECT CASE
                       WHEN cnt_err = 1
                       THEN
                              'Спроба виконати дію над рішеннями справ, які не належать ОСЗН '
                           || l_CurrOrg
                           || ' ( рішення № '
                           || pd_num
                           || ' )!'
                       WHEN cnt_err > 1
                       THEN
                              'Спроба виконати дію над рішеннями справ, які не належать ОСЗН '
                           || l_CurrOrg
                           || ' ( рішення № '
                           || pd_num
                           || ' та ще '
                           || cnt_err
                           || ' )!'
                       ELSE
                           ''
                   END    AS err_txt
              INTO l_err_txt
              FROM cnt;
        ELSIF p_level = 2
        THEN
            --4. Призупинення : (tools.getcurrorg = personalcase.com_org) != pc_decision.com_org => OK;
            --   Рішення Своїх справ, навіть створених в чужих ОСЗН, користувач ОСЗН має право призупинити
            WITH
                err
                AS
                    (SELECT FIRST_VALUE (pd.pd_num) OVER (ORDER BY pd_num)    AS pd_num
                       FROM tmp_chk_ids
                            JOIN pc_decision pd ON pd.pd_id = x_id
                            JOIN personalcase pc ON pc.pc_id = pd.pd_pc
                      WHERE CASE
                                WHEN     l_CurrOrg = pc.com_org
                                     AND l_CurrOrg != pd.com_org
                                THEN
                                    1
                                ELSE
                                    0
                            END =
                            1),
                cnt
                AS
                    (SELECT COUNT (pd_num) AS cnt_err, MAX (pd_num) AS pd_num
                       FROM err)
            SELECT CASE
                       WHEN cnt_err = 1
                       THEN
                              'Спроба виконати дію над рішеннями справ, які не належать ОСЗН '
                           || l_CurrOrg
                           || ' ( рішення № '
                           || pd_num
                           || ' )!'
                       WHEN cnt_err > 1
                       THEN
                              'Спроба виконати дію над рішеннями справ, які не належать ОСЗН '
                           || l_CurrOrg
                           || ' ( рішення № '
                           || pd_num
                           || ' та ще '
                           || cnt_err
                           || ' )!'
                       ELSE
                           ''
                   END    AS err_txt
              INTO l_err_txt
              FROM cnt;
        ELSIF p_level = 2
        THEN
            --5. Поновлення : (tools.getcurrorg = personalcase.com_org) != pc_decision.com_org => OK;
            --   Рішення Своїх справ, навіть створених в чужих ОСЗН, користувач ОСЗН має право поновити
            WITH
                err
                AS
                    (SELECT FIRST_VALUE (pd.pd_num) OVER (ORDER BY pd_num)    AS pd_num
                       FROM tmp_chk_ids
                            JOIN pc_decision pd ON pd.pd_id = x_id
                            JOIN personalcase pc ON pc.pc_id = pd.pd_pc
                      WHERE CASE
                                WHEN     l_CurrOrg = pc.com_org
                                     AND l_CurrOrg != pd.com_org
                                THEN
                                    1
                                ELSE
                                    0
                            END =
                            1),
                cnt
                AS
                    (SELECT COUNT (pd_num) AS cnt_err, MAX (pd_num) AS pd_num
                       FROM err)
            SELECT CASE
                       WHEN cnt_err = 1
                       THEN
                              'Спроба виконати дію над рішеннями справ, які не належать ОСЗН '
                           || l_CurrOrg
                           || ' ( рішення № '
                           || pd_num
                           || ' )!'
                       WHEN cnt_err > 1
                       THEN
                              'Спроба виконати дію над рішеннями справ, які не належать ОСЗН '
                           || l_CurrOrg
                           || ' ( рішення № '
                           || pd_num
                           || ' та ще '
                           || cnt_err
                           || ' )!'
                       ELSE
                           ''
                   END    AS err_txt
              INTO l_err_txt
              FROM cnt;
        END IF;

        IF l_err_txt IS NOT NULL
        THEN
            raise_application_error (-20000, l_err_txt);
        END IF;
    END;

    PROCEDURE init_pc_location_internal (p_mode INTEGER) --1=з комітами - для шед.задачі, 2=без комітів
    IS
        l_hs   histsession.hs_id%TYPE := NULL;
    BEGIN
        IF p_mode = 2
        THEN
            l_hs := TOOLS.GetHistSession;
        END IF;

        --нові справи
        INSERT INTO uss_esr.pc_location (pl_id,
                                         pl_pc,
                                         pl_org,
                                         pl_start_dt,
                                         pl_stop_dt,
                                         history_status,
                                         pl_hs_ins)
            SELECT 0,
                   pc_id,
                   com_org,
                   TO_DATE ('01.01.2000', 'DD.MM.YYYY'),
                   TO_DATE ('31.12.2999', 'DD.MM.YYYY'),
                   'A',
                   l_hs
              FROM uss_esr.personalcase, tmp_work_ids2
             WHERE     x_id = pc_id
                   AND NOT EXISTS
                           (SELECT 1
                              FROM uss_esr.pc_location
                             WHERE pl_pc = pc_id AND history_status = 'A');

        --  IF p_mode = 1 THEN COMMIT; END IF;

        --нові рішення в справах
        INSERT INTO uss_esr.pc_location (pl_id,
                                         pl_pc,
                                         pl_org,
                                         pl_start_dt,
                                         pl_stop_dt,
                                         history_status,
                                         pl_hs_ins)
            SELECT 0,
                   pc_id,
                   x_org,
                   x_dt - x_num,
                   x_dt - x_num,
                   'A',
                   l_hs
              FROM (SELECT pc_id,
                           x_org,
                           ROW_NUMBER ()
                               OVER (PARTITION BY pc_id ORDER BY x_org DESC)
                               x_num,
                           (SELECT MIN (pl_start_dt)
                              FROM uss_esr.pc_location
                             WHERE pl_pc = pc_id)
                               AS x_dt
                      FROM (SELECT pc_id, pd.com_org AS x_org
                              FROM uss_esr.personalcase  pc,
                                   uss_esr.pc_decision   pd,
                                   tmp_work_ids2
                             WHERE pd_pc = pc_id AND x_id = pc_id
                            UNION
                            SELECT pc_id, com_org AS x_org
                              FROM uss_esr.personalcase pc, tmp_work_ids2
                             WHERE x_id = pc_id)
                     WHERE     x_org IS NOT NULL
                           AND NOT EXISTS
                                   (SELECT 1
                                      FROM uss_esr.pc_location
                                     WHERE     pl_pc = pc_id
                                           AND pl_org = x_org
                                           AND history_status = 'A'));

        IF p_mode = 1
        THEN
            COMMIT;
        END IF;
    END;


    PROCEDURE init_pc_location
    IS
    BEGIN
        DELETE FROM tmp_work_ids2
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids2
            SELECT pc_id FROM personalcase;

        init_pc_location_internal (1);
    /*

    --нові справи
    INSERT INTO uss_esr.pc_location (pl_id, pl_pc, pl_org, pl_start_dt, pl_stop_dt, history_status)
      SELECT 0, pc_id, com_org, to_date('01.01.2000', 'DD.MM.YYYY'), to_date('31.12.2999', 'DD.MM.YYYY'), 'A'
      FROM uss_esr.personalcase
      WHERE NOT EXISTS (SELECT 1 FROM uss_esr.pc_location WHERE pl_pc = pc_id AND history_status = 'A');

    COMMIT;

    --нові рішення в справах
    INSERT INTO uss_esr.pc_location (pl_id, pl_pc, pl_org, pl_start_dt, pl_stop_dt, history_status)
      SELECT 0, pc_id, x_org, x_dt - x_num, x_dt - x_num, 'A'
      FROM (SELECT pc_id, x_org, ROW_NUMBER() OVER(PARTITION BY pc_id ORDER BY  x_org DESC) x_num,
                   (SELECT min(pl_start_dt) FROM uss_esr.pc_location WHERE pl_pc = pc_id) AS x_dt
            FROM (SELECT pc_id, pd.com_org AS x_org
                  FROM uss_esr.personalcase pc, uss_esr.pc_decision pd
                  WHERE pd_pc = pc_id
                  UNION
                  SELECT pc_id, com_org AS x_org
                  FROM uss_esr.personalcase pc)
            WHERE NOT EXISTS (SELECT 1
                              FROM uss_esr.pc_location
                              WHERE pl_pc = pc_id
                                AND pl_org = x_org
                                AND history_status = 'A'
                              ));

    COMMIT;
    */
    END;
END API$PC_ATTESTAT;
/