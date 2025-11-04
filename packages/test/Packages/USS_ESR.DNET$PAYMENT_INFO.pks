/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$PAYMENT_INFO
IS
    -- Author  : BOGDAN
    -- Created : 22.07.2021 13:13:30
    -- Purpose : Відомості

    -- #70543: Реєстр відомостей на виплату
    PROCEDURE GET_JOURNAL (P_PR_NPC               IN     NUMBER,
                           P_PR_TP                IN     VARCHAR2,
                           P_PR_ST                IN     VARCHAR2,
                           P_PR_PAY_TP            IN     VARCHAR2,
                           P_PR_MONTH_START       IN     DATE,
                           P_PR_MONTH_STOP        IN     DATE,
                           P_PR_CREATE_DT_START   IN     DATE,
                           P_PR_CREATE_DT_STOP    IN     DATE,
                           --P_PR_SEND_DT_START IN DATE, --#75804 kolio
                           --P_PR_SEND_DT_STOP IN DATE, --#75804 kolio
                           P_PR_FIX_DT_START      IN     DATE,
                           P_PR_FIX_DT_STOP       IN     DATE,
                           P_PR_ORG               IN     NUMBER,
                           P_PR_SRC               IN     VARCHAR2,
                           p_pr_nd                IN     NUMBER,
                           p_prs_num              IN     NUMBER,
                           RES_CUR                   OUT SYS_REFCURSOR);

    -- період розрахунку відомості
    PROCEDURE GET_PERIOD (RES_CUR OUT SYS_REFCURSOR);

    -- #70543: запуск джоба на формування відомостей
    PROCEDURE START_GENERATION (p_pr_tp           payroll.pr_tp%TYPE,
                                p_pr_org          payroll.com_org%TYPE,
                                p_month           DATE,
                                p_day_start       INTEGER,
                                p_day_stop        INTEGER,
                                p_pay_tp          VARCHAR2,
                                p_npt_code        NUMBER,
                                p_pe_code         VARCHAR2,
                                P_JB_ID       OUT NUMBER);

    -- #70543: протокол по джобу формування відомостей
    PROCEDURE GET_JOB_LOG (P_JB_ID    IN     NUMBER,
                           INFO_CUR      OUT SYS_REFCURSOR,
                           LOG_CUR       OUT SYS_REFCURSOR);

    -- блоб по джобу
    PROCEDURE GET_JOB_RESULT (P_JB_ID IN NUMBER, P_BLOB OUT BLOB);

    -- #70562: Картка відомості (без списків відомості)
    PROCEDURE GET_CARD (P_PR_ID IN NUMBER, RES_CUR OUT SYS_REFCURSOR);

    -- #70562: Перелік списків відомості
    PROCEDURE GET_CARD_SHEET (P_PR_ID        IN     NUMBER,
                              P_PRS_TP       IN     VARCHAR2,
                              P_PRSD_TP      IN     VARCHAR2,
                              P_Prs_Inn      IN     VARCHAR2,
                              P_PRS_NUM      IN     NUMBER,
                              P_PRS_INDEX    IN     VARCHAR2,
                              P_PRS_NB       IN     NUMBER,
                              P_PRS_PC_NUM   IN     VARCHAR2,
                              P_PRS_LN       IN     VARCHAR2,
                              P_PRS_FN       IN     VARCHAR2,
                              P_PRS_MN       IN     VARCHAR2,
                              p_prs_st       IN     VARCHAR2,
                              RES_CUR           OUT SYS_REFCURSOR, --физ особи
                              RES_CUR2          OUT SYS_REFCURSOR); --юр особи

    PROCEDURE GET_PR_SHEET_INFO (P_PRS_ID   IN     NUMBER,
                                 RES_CUR       OUT SYS_REFCURSOR);

    -- #79347: В картці рядка відомості, якщо заповнено поле prs_pcb, виводити секцію "блокування виплати" з полями з таблиці pd_block
    PROCEDURE GET_SHEET_BLOCK (P_PCB_ID IN NUMBER, res_cur OUT SYS_REFCURSOR);

    -- #75804 Призупинити виплату kolio
    PROCEDURE SHEET_STOP_PAY (P_PRS_ID IN NUMBER, P_RNP_ID IN NUMBER);

    -- #70562: Перелік деталей відомості
    PROCEDURE GET_SHEET_DETAILS (P_PRS_ID   IN     NUMBER,
                                 RES_CUR       OUT SYS_REFCURSOR);

    -- #70562: Провести виплату
    PROCEDURE APPROVE_CARD (P_PR_ID IN NUMBER);

    -- #76596: массово Провести виплату
    PROCEDURE APPROVE_CARDS (PRS_IDS IN VARCHAR2, P_RES OUT SYS_REFCURSOR);

    -- #70562: Зафіксувати виплату
    PROCEDURE FIX_CARD (P_PR_ID IN NUMBER);

    -- #76596: массово Зафіксувати виплату
    PROCEDURE FIX_CARDS (PRS_IDS IN VARCHAR2, P_RES OUT SYS_REFCURSOR);

    -- #70562 #76946: из P (Ключено в потребу) в F (Фіксовано)
    PROCEDURE SEND_CARD (P_PR_ID IN NUMBER);

    -- #76596: #76946: масово из P (Ключено в потребу) в F (Фіксовано)
    PROCEDURE SEND_CARDS (PRS_IDS IN VARCHAR2, P_RES OUT SYS_REFCURSOR);

    -- #88638: розфіксації відомостей
    PROCEDURE UNFIX_CARDS (PRS_IDS IN VARCHAR2);

    -- Видалення відомості
    PROCEDURE delete_payroll (P_PR_ID IN NUMBER);

    -- info:  #78238 можливість вивантаження данних по відомостям в текстовому вигляді
    -- params: p_ids  – ід ПД
    --         p_fname  - назва файлу архіва з файлами
    --         p_result - zip - архів з файлами
    PROCEDURE EXPORT_CARDS (p_ids      IN     VARCHAR2,
                            p_fname       OUT VARCHAR2,
                            p_result      OUT BLOB);

    -- io обробка КВ-1
    PROCEDURE proc_pca_pkt (p_pkt_id IN NUMBER);

    -- io обробка КВ-2
    PROCEDURE proc_ppr_pkt (p_pkt_id IN NUMBER);

    -- io обробка КВ-1/2  в статусі Новий
    PROCEDURE ProcessKV (p_pkt_id IN NUMBER);

    --  #81330 Формування відомостей на банк в електронному вигляді по 6 допомогам
    --  io Без запису в ПЕОД, фактично це звіт...
    PROCEDURE BuildBankFiles (p_pr_ids         VARCHAR2,
                              p_rpt        OUT BLOB,
                              p_rpt_name   OUT VARCHAR2);

    --  #81531 Формування відомостей на Поштув електронному вигляді по 6 допомогам
    --  io Без запису в ПЕОД, фактично це звіт...
    PROCEDURE BuildPostFiles (p_pr_ids         VARCHAR2,
                              p_rpt        OUT BLOB,
                              p_rpt_name   OUT VARCHAR2);

    --  #98707 формування пакету по виплаті по пошті знідно протоколу (поки це буде лише для виплат ВПП ООН)
    PROCEDURE BuildPostFiles2 (p_pr_ids         VARCHAR2,
                               p_rpt        OUT BLOB,
                               p_rpt_name   OUT VARCHAR2);

    -- #110218 формування пакету по ПІ по пошті знідно протоколу
    PROCEDURE BuildPostFilesPO (p_po_ids         VARCHAR2,
                                p_rpt        OUT BLOB,
                                p_rpt_name   OUT VARCHAR2);

    -- #86227
    PROCEDURE set_non_payment (p_prs_id     IN pr_sheet.prs_id%TYPE,
                               p_block_tp   IN VARCHAR2);

    -- #86227
    PROCEDURE error_confirmation (p_prs_id IN pr_sheet.prs_id%TYPE);

    -- #86227
    PROCEDURE error_blocking (p_prs_id IN pr_sheet.prs_id%TYPE);

    -- #86227
    PROCEDURE confirm_payment (p_pr_id payroll.pr_id%TYPE, p_pr_sum DECIMAL);

    FUNCTION get_fiz_sum (p_pr_id payroll.pr_id%TYPE)
        RETURN payroll.pr_sum%TYPE;

    -- #97478 Обробка квитанції повернення від пошти
    PROCEDURE proc_kpp_pkt (p_pkt_id IN NUMBER);

    PROCEDURE get_pr_log (p_pr_id NUMBER, p_res_cur OUT SYS_REFCURSOR);

    PROCEDURE get_prs_log (p_prs_id NUMBER, p_res_cur OUT SYS_REFCURSOR);

    PROCEDURE get_po_list (p_pr_id IN NUMBER, res_cur OUT SYS_REFCURSOR);
END DNET$PAYMENT_INFO;
/


GRANT EXECUTE ON USS_ESR.DNET$PAYMENT_INFO TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$PAYMENT_INFO TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$PAYMENT_INFO
IS
    FUNCTION get_fiz_sum (p_pr_id payroll.pr_id%TYPE)
        RETURN payroll.pr_sum%TYPE
    IS
        l_sum   payroll.pr_sum%TYPE := 0;
    BEGIN
        SELECT SUM (z.prs_sum)
          INTO l_sum
          FROM pr_sheet z
         WHERE     z.prs_pr = p_pr_id
               AND EXISTS
                       (SELECT 1
                          FROM pr_sheet_detail q
                         WHERE     q.prsd_prs = z.prs_id
                               AND prsd_pr = p_pr_id
                               AND q.prsd_tp IN ('PWI',
                                                 'RDN',
                                                 'PRAL',
                                                 'PMT',
                                                 'PROZ',
                                                 'RDN'));

        RETURN l_sum;
    END;

    -- #70543: Реєстр відомостей на виплату
    PROCEDURE GET_JOURNAL (P_PR_NPC               IN     NUMBER,
                           P_PR_TP                IN     VARCHAR2,
                           P_PR_ST                IN     VARCHAR2,
                           P_PR_PAY_TP            IN     VARCHAR2,
                           P_PR_MONTH_START       IN     DATE,
                           P_PR_MONTH_STOP        IN     DATE,
                           P_PR_CREATE_DT_START   IN     DATE,
                           P_PR_CREATE_DT_STOP    IN     DATE,
                           --P_PR_SEND_DT_START IN DATE, --#75804 kolio
                           --P_PR_SEND_DT_STOP IN DATE, --#75804 kolio
                           P_PR_FIX_DT_START      IN     DATE,
                           P_PR_FIX_DT_STOP       IN     DATE,
                           P_PR_ORG               IN     NUMBER,
                           P_PR_SRC               IN     VARCHAR2,
                           p_pr_nd                IN     NUMBER,
                           p_prs_num              IN     NUMBER,      -- pr_id
                           RES_CUR                   OUT SYS_REFCURSOR)
    IS
        l_org      NUMBER := tools.getcurrorg;
        l_org_to   NUMBER := tools.getcurrorgto;
    BEGIN
        tools.WriteMsg ('DNET$PAYMENT_INFO.' || $$PLSQL_UNIT);

        OPEN RES_CUR FOR
            SELECT t.*,
                   tp.DIC_SNAME                              AS pr_tp_name,
                   st.DIC_SNAME                              AS pr_st_name,
                   ptp.DIC_SNAME                             AS pr_pay_tp_name,
                   pc.npc_name                               AS pr_npc_name,
                   s.DIC_NAME                                AS pr_src_name,
                   DNET$PAYMENT_INFO.get_fiz_sum (pr_id)     AS pr_fiz_sum /*,
                          (SELECT MAX(z.prs_num)
                            FROM pr_sheet z
                           WHERE z.prs_pr = t.pr_id
                          ) AS prs_num*/
              FROM v_payroll  t
                   LEFT JOIN v_opfu o ON (o.org_id = t.com_org)
                   LEFT JOIN uss_ndi.v_ndi_payment_codes pc
                       ON (pc.npc_id = t.pr_npc)
                   LEFT JOIN uss_ndi.v_ddn_pr_tp tp
                       ON (tp.DIC_VALUE = t.pr_tp)
                   LEFT JOIN uss_ndi.v_ddn_pr_st st
                       ON (st.DIC_VALUE = t.pr_st)
                   LEFT JOIN uss_ndi.v_ddn_apm_tp ptp
                       ON (ptp.DIC_VALUE = t.pr_pay_tp)
                   LEFT JOIN uss_ndi.v_ddn_pe_src s
                       ON (s.DIC_VALUE = t.pr_src)
             WHERE     1 = 1
                   AND (p_pr_npc IS NULL OR t.pr_npc = p_pr_npc)
                   AND (p_pr_st IS NULL OR t.pr_st = p_pr_st)
                   AND (p_pr_tp IS NULL OR t.pr_tp = p_pr_tp)
                   AND (P_PR_ORG IS NULL OR t.com_org = P_PR_ORG)
                   AND (   l_org_to IN (32) AND t.com_org = l_org
                        OR l_org_to IN (34) AND o.org_acc_org = l_org
                        OR l_org_to NOT IN (32, 34))
                   AND (P_PR_SRC IS NULL OR t.pr_src = P_PR_SRC)
                   AND (   p_pr_nd IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM v_pr_sheet z
                                 WHERE     z.prs_pr = t.pr_id
                                       AND z.prs_nd = p_pr_nd))
                   --AND (p_prs_num IS NULL OR EXISTS (SELECT * FROM v_pr_sheet z WHERE z.prs_pr = t.pr_id AND z.prs_num LIKE p_prs_num || '%'))
                   AND (p_prs_num IS NULL OR pr_id = p_prs_num)
                   AND (P_PR_PAY_TP IS NULL OR t.pr_pay_tp = P_PR_PAY_TP)
                   AND (       P_PR_MONTH_START IS NULL
                           AND P_PR_MONTH_STOP IS NULL
                        OR     P_PR_MONTH_STOP IS NULL
                           AND t.pr_month >= P_PR_MONTH_START
                        OR     P_PR_MONTH_START IS NULL
                           AND t.pr_month <= P_PR_MONTH_STOP
                        OR t.pr_month BETWEEN P_PR_MONTH_START
                                          AND P_PR_MONTH_STOP)
                   AND (       P_PR_CREATE_DT_START IS NULL
                           AND P_PR_CREATE_DT_STOP IS NULL
                        OR     P_PR_CREATE_DT_STOP IS NULL
                           AND t.pr_create_dt >= P_PR_CREATE_DT_START
                        OR     P_PR_CREATE_DT_START IS NULL
                           AND t.pr_create_dt <= P_PR_CREATE_DT_STOP
                        OR t.pr_create_dt BETWEEN P_PR_CREATE_DT_START
                                              AND P_PR_CREATE_DT_STOP)
                   --    AND (P_PR_SEND_DT_START IS NULL AND P_PR_SEND_DT_STOP  IS NULL
                   --          OR P_PR_SEND_DT_STOP  IS NULL AND t.pr_send_dt >= P_PR_SEND_DT_START
                   --          OR P_PR_SEND_DT_START  IS NULL AND t.pr_send_dt <= P_PR_SEND_DT_STOP
                   --          OR t.pr_send_dt BETWEEN P_PR_SEND_DT_START AND P_PR_SEND_DT_STOP)
                   AND (       P_PR_FIX_DT_START IS NULL
                           AND P_PR_FIX_DT_STOP IS NULL
                        OR     P_PR_FIX_DT_STOP IS NULL
                           AND t.pr_fix_dt >= P_PR_FIX_DT_START
                        OR     P_PR_FIX_DT_START IS NULL
                           AND t.pr_fix_dt <= P_PR_FIX_DT_STOP
                        OR t.pr_fix_dt BETWEEN P_PR_FIX_DT_START
                                           AND P_PR_FIX_DT_STOP);
    END;

    -- #70543: період розрахунку відомості
    PROCEDURE GET_PERIOD (RES_CUR OUT SYS_REFCURSOR)
    IS
        l_user_type   VARCHAR2 (250);
        l_com_org     payroll.com_org%TYPE;
    BEGIN
        tools.WriteMsg ('DNET$PAYMENT_INFO.' || $$PLSQL_UNIT);
        l_user_type :=
            SYS_CONTEXT (USS_ESR_CONTEXT.gContext, USS_ESR_CONTEXT.gUserTP);
        l_com_org :=
            SYS_CONTEXT (USS_ESR_CONTEXT.gContext, USS_ESR_CONTEXT.gORG);

        OPEN RES_CUR FOR
            WITH
                periods
                AS
                    (SELECT TO_CHAR (x_dt, 'MM')
                                AS x_curr,
                            x_dt
                                AS x_curr_start,
                            LAST_DAY (x_dt)
                                AS x_curr_stop,
                            TO_CHAR (ADD_MONTHS (x_dt, 1), 'MM')
                                AS x_next,
                            ADD_MONTHS (x_dt, 1)
                                AS x_next_start,
                            LAST_DAY (ADD_MONTHS (x_dt, 1))
                                AS x_next_stop
                       FROM (SELECT DISTINCT
                                    TRUNC (bp_month, 'MM')     AS x_dt
                               FROM billing_period, tmp_org
                              WHERE     bp_st = 'R'
                                    AND bp_tp = 'PR'
                                    AND (   (    l_user_type = '41'
                                             AND bp_class = 'VPO')
                                         OR (    l_user_type <> '41'
                                             AND bp_class = 'V'))
                                    AND bp_org = u_org)),
                pr_types_M
                AS
                    (SELECT 'M' AS w_pr_tp FROM DUAL
                     UNION ALL
                     SELECT 'MD' AS w_pr_tp FROM DUAL),
                pr_types_A
                AS
                    (SELECT 'A' AS w_pr_tp FROM DUAL
                     UNION ALL
                     SELECT 'AD' AS w_pr_tp FROM DUAL)
                SELECT x_curr_start                              AS start_dt,
                       x_curr_stop                               AS stop_dt,
                          LOWER (dic_name)
                       || ' '
                       || TO_CHAR (x_curr_start, 'YYYY')         AS name,
                       w_pr_tp                                   AS pr_tp,
                          'з '
                       || TO_CHAR (x_curr_start, 'DD.MM.YYYY')
                       || ' по '
                       || TO_CHAR (x_curr_stop, 'DD.MM.YYYY')    AS code
                  FROM uss_ndi.v_ddn_month_names, periods, pr_types_A
                 WHERE dic_value = x_curr
                UNION
                SELECT x_curr_start                              AS start_dt,
                       x_curr_stop                               AS stop_dt,
                          LOWER (dic_name)
                       || ' '
                       || TO_CHAR (x_curr_start, 'YYYY')         AS name,
                       w_pr_tp                                   AS pr_tp,
                          'з '
                       || TO_CHAR (x_curr_start, 'DD.MM.YYYY')
                       || ' по '
                       || TO_CHAR (x_curr_stop, 'DD.MM.YYYY')    AS code
                  FROM uss_ndi.v_ddn_month_names, periods, pr_types_M
                 WHERE dic_value = x_curr;
    END;

    -- #70543: запуск джоба на формування відомостей
    PROCEDURE START_GENERATION (p_pr_tp           payroll.pr_tp%TYPE,
                                p_pr_org          payroll.com_org%TYPE,
                                p_month           DATE,
                                p_day_start       INTEGER,
                                p_day_stop        INTEGER,
                                p_pay_tp          VARCHAR2,
                                p_npt_code        NUMBER,
                                p_pe_code         VARCHAR2,
                                P_JB_ID       OUT NUMBER)
    IS
        l_jb_cnt   NUMBER;
    BEGIN
        /*SELECT COUNT(1)
        INTO l_jb_cnt
        FROM v_w_jobs x1, v_w_job_type x2
        WHERE x1.jb_wjt=x2.wjt_id
          AND jb_start_dt between trunc(sysdate) and sysdate
          AND jb_wjt = 'PROCESSPAYROLL'
          AND jb_status in ('NEW','RUNING','ENQUEUE');

        IF l_jb_cnt = 0 THEN */
        TOOLS.SubmitSchedule (
            p_jb       => P_JB_ID,
            p_subsys   => 'USS_ESR',
            p_wjt      => 'PROCESSPAYROLL',
            p_what     =>
                   'begin uss_esr.calc$payroll.create_payroll('''''
                || p_pr_tp
                || ''''',
         '
                || p_pr_org
                || ',
         to_date('''''
                || TO_CHAR (TRUNC (p_month, 'MM'), 'DD.MM.YYYY')
                || ''''', ''''DD.MM.YYYY''''),
         '
                || p_day_start
                || ',
         '
                || p_day_stop
                || ',
         '''''
                || p_pay_tp
                || ''''',
         '
                || p_npt_code
                || ',
         '''''
                || p_pe_code
                || '''''); end;');
    /*ELSE
      raise_application_error(-20000, 'На даний момент уже виконуються завдання даного типу!');
    END IF; */
    END;

    -- #70543: протокол по джобу формування відомостей
    PROCEDURE GET_JOB_LOG (P_JB_ID    IN     NUMBER,
                           INFO_CUR      OUT SYS_REFCURSOR,
                           LOG_CUR       OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.GetScheduleStatus (p_jb_id, info_cur, log_cur);
    END;

    -- блоб по джобу
    PROCEDURE GET_JOB_RESULT (P_JB_ID IN NUMBER, P_BLOB OUT BLOB)
    IS
    BEGIN
        tools.GetScheduleData (p_jb_id, P_BLOB);
    END;

    -- #70562: Картка відомості (без списків відомості)
    PROCEDURE GET_CARD (P_PR_ID IN NUMBER, RES_CUR OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.WriteMsg ('DNET$PAYMENT_INFO.' || $$PLSQL_UNIT);

        OPEN res_cur FOR
            SELECT t.*,
                   tp.DIC_SNAME
                       AS pr_tp_name,
                   st.DIC_SNAME
                       AS pr_st_name,
                   cd.DIC_SNAME
                       AS pr_pay_tp_name,
                   pc.npc_name
                       AS pr_npc_name,
                   t.com_org || ' ' || p.org_name
                       AS Com_Org_Name,
                   s.DIC_NAME
                       AS pr_src_name,
                   c.DIC_NAME
                       AS pr_code_name,
                   (SELECT SUM (z.prs_sum)
                      FROM pr_sheet z
                     WHERE     z.prs_pr = t.pr_id
                           AND EXISTS
                                   (SELECT *
                                      FROM pr_sheet_detail q
                                     WHERE     q.prsd_prs = z.prs_id
                                           AND q.prsd_tp IN ('PWI',
                                                             'RDN',
                                                             'PRAL',
                                                             'PMT',
                                                             'PROZ',
                                                             'RDN')))
                       AS pr_fiz_sum,
                   (SELECT COUNT (z.prs_pc)
                      FROM pr_sheet z
                     WHERE     z.prs_pr = t.pr_id
                           AND EXISTS
                                   (SELECT *
                                      FROM pr_sheet_detail q
                                     WHERE     q.prsd_prs = z.prs_id
                                           AND q.prsd_tp IN ('PWI',
                                                             'RDN',
                                                             'PRAL',
                                                             'PMT',
                                                             'PROZ',
                                                             'RDN')))
                       AS pr_fiz_cnt,
                   CASE
                       WHEN (SELECT COUNT (*)
                               FROM payroll_reestr z
                              WHERE z.pe_pr = t.pr_id AND z.PE_CLASS = 'AID') >
                            0
                       THEN
                           1
                       ELSE
                           0
                   END
                       AS pr_has_pe,
                   (SELECT MAX (zp.com_org_src)
                      FROM payroll_reestr  z
                           JOIN pay_order zp ON (zp.po_id = z.pe_po)
                     WHERE z.pe_pr = t.pr_id AND z.PE_CLASS = 'AID')
                       AS pe_org
              FROM v_payroll  t
                   JOIN v_opfu p ON (p.org_id = t.com_org)
                   LEFT JOIN uss_ndi.v_ndi_payment_codes pc
                       ON (pc.npc_id = t.pr_npc)
                   LEFT JOIN uss_ndi.v_ddn_pr_tp tp
                       ON (tp.DIC_VALUE = t.pr_tp)
                   LEFT JOIN uss_ndi.v_ddn_pr_st st
                       ON (st.DIC_VALUE = t.pr_st)
                   LEFT JOIN uss_ndi.v_ddn_apm_tp cd
                       ON (cd.DIC_VALUE = t.pr_pay_tp)
                   LEFT JOIN uss_ndi.v_ddn_pe_src s
                       ON (s.DIC_VALUE = t.pr_src)
                   LEFT JOIN uss_ndi.v_ddn_pe_code c
                       ON (c.DIC_VALUE = t.pr_code AND c.DIC_ST = 'A')
             WHERE pr_id = p_pr_id;
    END;

    /* cmd.AddCommandParameter("id", id);
            cmd.AddCommandParameter("Prs_Tp", model.Prs_Tp);
            cmd.AddCommandParameter("Prsd_Tp", model.Prsd_Tp);
            cmd.AddCommandParameter("Prs_Transfer_Dt_Tp", model.Prs_Transfer_Dt_Tp);
            cmd.AddCommandParameter("Prs_Num", model.Prs_Num);
            cmd.AddCommandParameter("Prs_Index", model.Prs_Index);
            cmd.AddCommandParameter("Prs_Nb", model.Prs_Nb);
            cmd.AddCommandParameter("Prs_Pc_Num", model.Prs_Pc_Num);*/
    -- #70562: Перелік списків відомості
    PROCEDURE GET_CARD_SHEET (P_PR_ID        IN     NUMBER,
                              P_PRS_TP       IN     VARCHAR2,
                              P_PRSD_TP      IN     VARCHAR2,
                              P_Prs_Inn      IN     VARCHAR2,
                              P_PRS_NUM      IN     NUMBER,
                              P_PRS_INDEX    IN     VARCHAR2,
                              P_PRS_NB       IN     NUMBER,
                              P_PRS_PC_NUM   IN     VARCHAR2,
                              P_PRS_LN       IN     VARCHAR2,
                              P_PRS_FN       IN     VARCHAR2,
                              P_PRS_MN       IN     VARCHAR2,
                              p_prs_st       IN     VARCHAR2,
                              RES_CUR           OUT SYS_REFCURSOR, --физ особи
                              RES_CUR2          OUT SYS_REFCURSOR)  --юр особи
    IS
        l_ca_dpp   pr_sheet.prs_dpp%TYPE;
    BEGIN
        tools.WriteMsg ('DNET$PAYMENT_INFO.' || $$PLSQL_UNIT);

        SELECT dpp_id
          INTO l_ca_dpp
          FROM uss_ndi.v_ndi_pay_person
         WHERE history_status = 'A' AND dpp_tp = 'OSZN' AND dpp_org = 50000;

        --физ особи
        OPEN res_cur FOR
            SELECT t.*,
                   tp.DIC_SNAME
                       AS prs_tp_name,
                      '№'
                   || t.prs_remit_num
                   || ' від '
                   || TO_CHAR (t.prs_remit_dt, 'DD.MM.YYYY')
                       AS Prs_Remit_Dt_Num,
                   t.prs_ln || ' ' || t.prs_fn || ' ' || t.prs_mn
                       AS prs_pib,
                   b.nb_mfo || ' ' || b.nb_name
                       AS Prs_Nb_Name,
                   -- npt_code AS prs_npt_code,
                   --  npt_name AS prs_npt_name,
                    (SELECT MAX (z.DIC_NAME)
                       FROM uss_ndi.v_ddn_prs_st z
                      WHERE z.DIC_VALUE = t.prs_st)
                       AS prs_st_name,
                      nd.nd_code
                   || ' '
                   || nd.nd_comment
                   || CASE
                          WHEN po.npo_id IS NOT NULL
                          THEN
                                 ' ('
                              || po.npo_index
                              || ' '
                              || po.npo_address
                              || ')'
                      END
                       AS prs_nd_name,
                   /*(SELECT MAX(apda.apda_val_string)
                      FROM personalcase pc
                      JOIN v_appeal ap ON (ap.ap_pc = pc.pc_id)
                      JOIN v_ap_document apd ON (apd.apd_ap = ap.ap_id)
                      JOIN V_Ap_Document_Attr apda ON (apda.apda_apd = apd.apd_id)
                      JOIN Uss_Ndi.v_Ndi_Document_Attr nda ON (apda.Apda_Nda = nda.Nda_Id)

                     WHERE pc.pc_id = t.prs_pc
                       AND apd.apd_ndt = 10052
                       AND nda.Nda_Class = 'DSN'
                       AND apda.History_Status = 'A'
                   ) AS vpo_num,*/
                   uss_person.api$sc_tools.get_vpo_num (pc.pc_sc)
                       AS vpo_num
              FROM pr_sheet  t
                   LEFT JOIN personalcase pc ON (pc.pc_id = t.prs_pc)
                   LEFT JOIN uss_ndi.v_ddn_prs_tp tp
                       ON (tp.DIC_VALUE = t.prs_tp)
                   LEFT JOIN uss_ndi.v_ndi_bank b ON (b.nb_id = t.prs_nb)
                   --LEFT JOIN uss_ndi.v_ndi_payment_type p ON (p.npt_id = t.prs_npt)
                   LEFT JOIN uss_ndi.v_ndi_delivery nd
                       ON (nd.nd_id = t.prs_nd)
                   LEFT JOIN uss_ndi.v_ndi_post_office po
                       ON (po.npo_id = nd.nd_npo)
             WHERE     prs_pr = p_pr_id
                   AND (p_prs_tp IS NULL OR t.prs_tp = p_prs_tp)
                   --AND t.prs_tp NOT IN ('AP', 'ABP', 'ABU')--фильтр для физ. лиц
                   -- #85292
                   AND EXISTS
                           (SELECT *
                              FROM pr_sheet_detail q
                             WHERE     q.prsd_prs = t.prs_id
                                   AND q.prsd_tp IN ('PWI',
                                                     'RDN',
                                                     'PRAL',
                                                     'PMT',
                                                     'PROZ',
                                                     'RDN'))
                   AND (P_Prs_Inn IS NULL OR t.prs_inn LIKE P_Prs_Inn || '%')
                   /*AND (P_PRS_TRANSFER_DT_TP IS NULL
                         OR P_PRS_TRANSFER_DT_TP = 'ALL'
                         OR P_PRS_TRANSFER_DT_TP = 'EMPTY' AND t.prs_transfer_dt IS NULL)*/
                   AND (   P_PRSD_TP IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM v_pr_sheet_detail z
                                 WHERE     z.prsd_prs = t.prs_id
                                       AND z.prsd_tp = P_PRSD_TP))
                   AND (P_PRS_NUM IS NULL OR t.prs_num = P_PRS_NUM)
                   AND (P_PRS_INDEX IS NULL OR t.prs_index = P_PRS_INDEX)
                   AND (P_PRS_NB IS NULL OR t.prs_nb = P_PRS_NB)
                   AND (p_prs_st IS NULL OR t.prs_st = p_prs_st)
                   AND (   P_PRS_PC_NUM IS NULL
                        OR t.prs_pc_num LIKE P_PRS_PC_NUM || '%')
                   AND (P_PRS_LN IS NULL OR t.prs_ln LIKE P_PRS_LN || '%')
                   AND (P_PRS_FN IS NULL OR t.prs_fn LIKE P_PRS_FN || '%')
                   AND (P_PRS_MN IS NULL OR t.prs_mn LIKE P_PRS_MN || '%')/*AND (P_PRS_PC_NUM IS NULL OR EXISTS (SELECT *
                                                                                                                 FROM personalcase z
                                                                                                                WHERE z.pc_id = t.prs_pc AND z.pc_num = P_PRS_PC_NUM))*/
                                                                          ;

        --юр особи
        OPEN res_cur2 FOR
            SELECT prs_id,
                   prs_pr,
                   prs_pc,
                   prs_pa,
                   prs_num,
                   prs_nb,
                   prs_pc_num,
                   CASE
                       WHEN prs_dpp = l_ca_dpp
                       THEN
                           'утримання переплат'
                       ELSE
                           prs_account
                   END
                       prs_account,
                   prs_fn,
                   prs_ln,
                   prs_mn,
                   prs_index,
                   prs_address,
                   prs_tp,
                   prs_sum,
                   prs_post_sum,
                   prs_post_by_org,
                   prs_max_pro_sum,
                   prs_post_perc,
                   prs_remit_dt,
                   prs_remit_num,
                   prs_inn,
                   prs_transfer_dt,
                   prs_kaot,
                   prs_street,
                   prs_ns,
                   prs_building,
                   prs_block,
                   prs_apartment,
                   prs_pay_dt,
                   prs_doc_num,
                   prs_st,
                   prs_dpp,
                   prs_pcb,
                   prs_nd,
                   tp.DIC_SNAME
                       AS prs_tp_name,
                      '№'
                   || t.prs_remit_num
                   || ' від '
                   || TO_CHAR (t.prs_remit_dt, 'DD.MM.YYYY')
                       AS Prs_Remit_Dt_Num,
                   t.prs_ln || ' ' || t.prs_fn || ' ' || t.prs_mn
                       AS prs_pib,
                   CASE
                       WHEN prs_dpp = l_ca_dpp THEN 'утримання переплат'
                       ELSE b.nb_mfo || ' ' || b.nb_name
                   END
                       AS Prs_Nb_Name,
                   -- npt_code AS prs_npt_code,
                   -- npt_name AS prs_npt_name,
                    (SELECT MAX (z.DIC_NAME)
                       FROM uss_ndi.v_ddn_prs_st z
                      WHERE z.DIC_VALUE = t.prs_st)
                       AS prs_st_name,
                   /*(SELECT MAX(apda.apda_val_string)
                      FROM personalcase pc
                      JOIN v_appeal ap ON (ap.ap_pc = pc.pc_id)
                      JOIN v_ap_document apd ON (apd.apd_ap = ap.ap_id)
                      JOIN V_Ap_Document_Attr apda ON (apda.apda_apd = apd.apd_id)
                      JOIN Uss_Ndi.v_Ndi_Document_Attr nda ON (apda.Apda_Nda = nda.Nda_Id)

                     WHERE pc.pc_id = t.prs_pc
                       AND apd.apd_ndt = 10052
                       AND nda.Nda_Class = 'DSN'
                       AND apda.History_Status = 'A'
                   ) AS vpo_num*/
                   uss_person.api$sc_tools.get_vpo_num (pc.pc_sc)
                       AS vpo_num
              FROM v_pr_sheet  t
                   LEFT JOIN personalcase pc ON (pc.pc_id = t.prs_pc)
                   LEFT JOIN uss_ndi.v_ddn_prs_tp tp
                       ON (tp.DIC_VALUE = t.prs_tp)
                   LEFT JOIN uss_ndi.v_ndi_bank b ON (b.nb_id = t.prs_nb)
             --LEFT JOIN uss_ndi.v_ndi_payment_type p ON (p.npt_id = t.prs_npt)
             WHERE     prs_pr = p_pr_id
                   AND (p_prs_tp IS NULL OR t.prs_tp = p_prs_tp)
                   AND t.prs_tp IN ('AUU', 'ABU', 'ADV')  --фильтр для юр. лиц
                   --AND t.prs_tp IN ('AP', 'ABP', 'ABU')--фильтр для юр. лиц
                   -- #85292
                   AND NOT EXISTS
                           (SELECT *
                              FROM pr_sheet_detail q
                             WHERE     q.prsd_prs = t.prs_id
                                   AND q.prsd_tp IN ('PWI',
                                                     'RDN',
                                                     'PRAL',
                                                     'PMT',
                                                     'PROZ',
                                                     'RDN'))
                   AND (P_Prs_Inn IS NULL OR t.prs_inn LIKE P_Prs_Inn || '%')
                   /*AND (P_PRS_TRANSFER_DT_TP IS NULL
                         OR P_PRS_TRANSFER_DT_TP = 'ALL'
                         OR P_PRS_TRANSFER_DT_TP = 'EMPTY' AND t.prs_transfer_dt IS NULL)*/
                   AND (   P_PRSD_TP IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM v_pr_sheet_detail z
                                 WHERE     z.prsd_prs = t.prs_id
                                       AND z.prsd_tp = P_PRSD_TP))
                   AND (P_PRS_NUM IS NULL OR t.prs_num = P_PRS_NUM)
                   AND (P_PRS_INDEX IS NULL OR t.prs_index = P_PRS_INDEX)
                   AND (P_PRS_NB IS NULL OR t.prs_nb = P_PRS_NB)
                   AND (   P_PRS_PC_NUM IS NULL
                        OR t.prs_pc_num LIKE P_PRS_PC_NUM || '%')
                   AND (P_PRS_LN IS NULL OR t.prs_ln LIKE P_PRS_LN || '%')
                   AND (P_PRS_FN IS NULL OR t.prs_fn LIKE P_PRS_FN || '%')
                   AND (P_PRS_MN IS NULL OR t.prs_mn LIKE P_PRS_MN || '%')/*AND (P_PRS_PC_NUM IS NULL OR EXISTS (SELECT *
                                                                                                                 FROM personalcase z
                                                                                                                WHERE z.pc_id = t.prs_pc AND z.pc_num = P_PRS_PC_NUM))*/
                                                                          ;
    END;

    PROCEDURE GET_PR_SHEET_INFO (P_PRS_ID   IN     NUMBER,
                                 RES_CUR       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT t.*,
                   tp.DIC_SNAME
                       AS prs_tp_name,
                      '№'
                   || t.prs_remit_num
                   || ' від '
                   || TO_CHAR (t.prs_remit_dt, 'DD.MM.YYYY')
                       AS Prs_Remit_Dt_Num,
                   t.prs_ln || ' ' || t.prs_fn || ' ' || t.prs_mn
                       AS prs_pib,
                   b.nb_mfo || ' ' || b.nb_name
                       AS Prs_Nb_Name,
                   -- npt_code AS prs_npt_code,
                   -- npt_name AS prs_npt_name,
                    (SELECT MAX (z.DIC_NAME)
                       FROM uss_ndi.v_ddn_prs_st z
                      WHERE z.DIC_VALUE = t.prs_st)
                       AS prs_st_name,
                      nd.nd_code
                   || ' '
                   || nd.nd_comment
                   || CASE
                          WHEN po.npo_id IS NOT NULL
                          THEN
                                 ' ('
                              || po.npo_index
                              || ' '
                              || po.npo_address
                              || ')'
                      END
                       AS prs_nd_name,
                   uss_person.api$sc_tools.get_vpo_num (pc.pc_sc)
                       AS vpo_num,
                   pr_Pay_Tp,
                   pr_St,
                   p.com_org
                       AS pr_org,
                   p.pr_npc,
                   CASE
                       WHEN (SELECT COUNT (*)
                               FROM payroll_reestr z
                              WHERE z.pe_pr = pr_id) > 0
                       THEN
                           1
                       ELSE
                           0
                   END
                       AS pr_has_pe,
                   (SELECT MAX (zp.com_org_src)
                      FROM payroll_reestr  z
                           JOIN pay_order zp ON (zp.po_id = z.pe_po)
                     WHERE z.pe_pr = t.prs_pr)
                       AS pe_org
              FROM pr_sheet  t
                   LEFT JOIN payroll p ON (p.pr_id = t.prs_pr)
                   LEFT JOIN personalcase pc ON (pc.pc_id = t.prs_pc)
                   LEFT JOIN uss_ndi.v_ddn_prs_tp tp
                       ON (tp.DIC_VALUE = t.prs_tp)
                   LEFT JOIN uss_ndi.v_ndi_bank b ON (b.nb_id = t.prs_nb)
                   --LEFT JOIN uss_ndi.v_ndi_payment_type p ON (p.npt_id = t.prs_npt)
                   LEFT JOIN uss_ndi.v_ndi_delivery nd
                       ON (nd.nd_id = t.prs_nd)
                   LEFT JOIN uss_ndi.v_ndi_post_office po
                       ON (po.npo_id = nd.nd_npo)
             WHERE prs_id = P_PRS_ID;
    END;

    PROCEDURE GET_PR_SHEET_BY_PC (P_PC_ID   IN     NUMBER,
                                  RES_CUR      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT t.*,
                   tp.DIC_SNAME
                       AS prs_tp_name,
                      '№'
                   || t.prs_remit_num
                   || ' від '
                   || TO_CHAR (t.prs_remit_dt, 'DD.MM.YYYY')
                       AS Prs_Remit_Dt_Num,
                   t.prs_ln || ' ' || t.prs_fn || ' ' || t.prs_mn
                       AS prs_pib,
                   b.nb_mfo || ' ' || b.nb_name
                       AS Prs_Nb_Name,
                   -- npt_code AS prs_npt_code,
                   -- npt_name AS prs_npt_name,
                    (SELECT MAX (z.DIC_NAME)
                       FROM uss_ndi.v_ddn_prs_st z
                      WHERE z.DIC_VALUE = t.prs_st)
                       AS prs_st_name,
                      nd.nd_code
                   || ' '
                   || nd.nd_comment
                   || CASE
                          WHEN po.npo_id IS NOT NULL
                          THEN
                                 ' ('
                              || po.npo_index
                              || ' '
                              || po.npo_address
                              || ')'
                      END
                       AS prs_nd_name,
                   uss_person.api$sc_tools.get_vpo_num (pc.pc_sc)
                       AS vpo_num
              FROM pr_sheet  t
                   LEFT JOIN personalcase pc ON (pc.pc_id = t.prs_pc)
                   LEFT JOIN uss_ndi.v_ddn_prs_tp tp
                       ON (tp.DIC_VALUE = t.prs_tp)
                   LEFT JOIN uss_ndi.v_ndi_bank b ON (b.nb_id = t.prs_nb)
                   -- LEFT JOIN uss_ndi.v_ndi_payment_type p ON (p.npt_id = t.prs_npt)
                   LEFT JOIN uss_ndi.v_ndi_delivery nd
                       ON (nd.nd_id = t.prs_nd)
                   LEFT JOIN uss_ndi.v_ndi_post_office po
                       ON (po.npo_id = nd.nd_npo)
             WHERE prs_pc = P_PC_ID;
    END;

    -- #79347: В картці рядка відомості, якщо заповнено поле prs_pcb, виводити секцію "блокування виплати" з полями з таблиці pd_block
    PROCEDURE GET_SHEET_BLOCK (P_PCB_ID IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT t.*,
                   tp.dic_name                       AS pcb_tp_name,
                   bh.hs_dt                          AS pcb_hs_lock_dt,
                   tools.GetUserLogin (bh.hs_wu)     AS Pcb_Hs_Lock_User,
                   rnp.rnp_name                      AS pcb_rnp_name,
                   cd.DIC_NAME                       AS pcb_exch_code_name
              /*ltp.DIC_NAME AS pcb_lock_pnp_tp_name,
              ultp.DIC_NAME AS pcb_unlock_pnp_tp_name,
              runp.rup_name AS pcb_rup_name,
              ubh.hs_dt AS pcb_hs_unlock_dt*/
              FROM pc_block  t
                   JOIN histsession bh ON (bh.hs_id = t.pcb_hs_lock)
                   JOIN uss_ndi.v_ndi_reason_not_pay rnp
                       ON (rnp.rnp_id = t.pcb_rnp)
                   LEFT JOIN uss_ndi.v_ddn_pcb_tp tp
                       ON (tp.dic_value = t.pcb_tp)
                   LEFT JOIN uss_ndi.v_ddn_pr_exch_code cd
                       ON (cd.dic_value = t.pcb_exch_code)
             /*LEFT JOIN uss_ndi.v_ddn_pnp_tp ltp ON (ltp.dic_value = t.pcb_lock_pnp_tp)
             LEFT JOIN uss_ndi.v_ddn_pnp_tp ultp ON (ultp.dic_value = t.pcb_unlock_pnp_tp)
             LEFT JOIN uss_ndi.v_ndi_reason_unlock_pay runp ON (runp.rup_id = t.pcb_rup)
             LEFT JOIN histsession ubh ON (ubh.hs_id = t.pcb_hs_unlock)*/

             WHERE t.pcb_id = P_PCB_ID;
    END;

    -- #75804 Призупинити виплату kolio
    PROCEDURE SHEET_STOP_PAY (P_PRS_ID IN NUMBER, P_RNP_ID IN NUMBER)
    IS
        l_st   VARCHAR2 (10);
    BEGIN
        SELECT pr_st
          INTO l_st
          FROM v_payroll t
         WHERE t.pr_id = (SELECT prs_pr
                            FROM pr_sheet p
                           WHERE p.prs_id = p_prs_Id);

        IF (l_st IS NULL OR l_st = 'F')
        THEN --нельзя приостанавливать выплату у відомості со статусом "Фиксовано"
            raise_application_error (
                -20000,
                'Неможливо призупинити виплату так як відомість в стані "Фіксовано"');
        END IF;

        API$PAYROLL.sheet_stop_pay (p_prs_Id, P_RNP_ID);
    END;

    -- #70562: Перелік деталей відомості
    PROCEDURE GET_SHEET_DETAILS (P_PRS_ID   IN     NUMBER,
                                 RES_CUR       OUT SYS_REFCURSOR)
    IS
        l_prs_tp   pr_sheet.prs_tp%TYPE;
    BEGIN
        SELECT prs_tp
          INTO l_prs_tp
          FROM pr_sheet
         WHERE prs_id = p_prs_id;

        IF l_prs_tp IN ('PB', 'PP')
        THEN
            OPEN RES_CUR FOR
                  SELECT t.*,
                         tp.DIC_SNAME                                  AS prsd_tp_name,
                         p.npt_code || ' ' || p.npt_name               AS prsd_npt_name,
                         uss_person.api$sc_tools.GET_PIB (pc.pc_sc)    AS prsd_pib
                    FROM pr_sheet_detail t
                         LEFT JOIN uss_ndi.v_ddn_prsd_tp tp
                             ON (tp.DIC_VALUE = t.prsd_tp)
                         LEFT JOIN uss_ndi.v_ndi_payment_type p
                             ON (p.npt_id = t.prsd_npt)
                         LEFT JOIN uss_esr.v_personalcase pc
                             ON (pc.pc_id = t.prsd_pc)
                   WHERE t.prsd_prs = p_prs_id
                ORDER BY prsd_month ASC, tp.DIC_SRTORDR ASC;
        ELSIF l_prs_tp IN ('AUU', 'ABU')
        THEN
            OPEN RES_CUR FOR
                  SELECT t.*,
                         tp.DIC_SNAME                                  AS prsd_tp_name,
                            p.npt_code
                         || ' '
                         || p.npt_name
                         || ' ('
                         || prs_inn
                         || '='
                         || prs_fn
                         || ' '
                         || prs_mn
                         || ' '
                         || prs_ln
                         || ')'                                        AS prsd_npt_name,
                         uss_person.api$sc_tools.GET_PIB (pc.pc_sc)    AS prsd_pib
                    FROM pr_sheet_detail t
                         LEFT JOIN uss_ndi.v_ddn_prsd_tp tp
                             ON (tp.DIC_VALUE = t.prsd_tp)
                         LEFT JOIN uss_ndi.v_ndi_payment_type p
                             ON (p.npt_id = t.prsd_npt)
                         LEFT JOIN uss_esr.v_personalcase pc
                             ON (pc.pc_id = t.prsd_pc)
                         JOIN pr_sheet ON prsd_prs = prs_id
                   WHERE t.prsd_prs_dn = p_prs_id
                ORDER BY prsd_month ASC, tp.DIC_SRTORDR ASC;
        ELSE
            OPEN RES_CUR FOR SELECT * FROM DUAL;
        END IF;
    END;

    -- #70562: Провести виплату
    PROCEDURE APPROVE_CARD (P_PR_ID IN NUMBER)
    IS
        --l_st VARCHAR2(10);
        l_row      v_payroll%ROWTYPE;
        l_new_id   NUMBER;
        l_nbg      NUMBER;
    BEGIN
        SELECT *
          INTO l_row
          FROM v_payroll t
         WHERE t.pr_id = p_pr_Id;

        IF (l_row.pr_st IS NULL OR l_row.pr_st != 'C')
        THEN                                              --переводим из C в P
            raise_application_error (
                -20000,
                'Неможливо провести виплату в поточному стані!');
        END IF;

        SELECT FIRST_VALUE (q.npt_nbg) OVER (ORDER BY t.prsd_id)
          INTO l_nbg
          FROM pr_sheet_detail  t
               JOIN uss_ndi.v_ndi_payment_type q ON (q.npt_id = t.prsd_npt)
         WHERE t.prsd_pr = P_PR_ID
         FETCH FIRST ROW ONLY;

        CALC$PAYROLL.approve_payroll (p_pr_id);           --переводим из C в P

        -- #94837: По кнопці "Для потреби" підключити функціонал по створенню документу власної потреби
        DNET$BUDGETING.INIT_FUNDING_REQUEST (l_row.pr_month,
                                             'MAIN',
                                             l_nbg,
                                             l_new_id);
    END;

    -- #76596 kolio массово Провести виплату
    PROCEDURE APPROVE_CARDS (PRS_IDS IN VARCHAR2, P_RES OUT SYS_REFCURSOR)
    IS
        l_st       VARCHAR2 (10);
        l_row      v_payroll%ROWTYPE;
        l_new_id   NUMBER;
        l_nbg      NUMBER;

        CURSOR ids IS
                SELECT REGEXP_SUBSTR (text,
                                      '[^(\,)]+',
                                      1,
                                      LEVEL)    AS prs
                  FROM (SELECT PRS_IDS AS text FROM DUAL)
            CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                              '[^(\,)]+',
                                              1,
                                              LEVEL)) > 0;
    BEGIN
        OPEN p_res FOR
            SELECT t.pr_id     AS id
              FROM v_payroll t
             WHERE     pr_id IN
                           (    SELECT REGEXP_SUBSTR (text,
                                                      '[^(\,)]+',
                                                      1,
                                                      LEVEL)
                                  FROM (SELECT PRS_IDS AS text FROM DUAL)
                            CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                              '[^(\,)]+',
                                                              1,
                                                              LEVEL)) > 0)
                   AND (t.pr_st IS NULL OR t.pr_st != 'C');

        FOR id IN ids
        LOOP
            SELECT *
              INTO l_row
              FROM v_payroll t
             WHERE t.pr_id = id.prs;

            IF (l_row.pr_st = 'C')
            THEN                                          --переводим из C в P
                CALC$PAYROLL.approve_payroll (id.prs);    --переводим из C в P

                SELECT FIRST_VALUE (q.npt_nbg) OVER (ORDER BY t.prsd_id)
                  INTO l_nbg
                  FROM pr_sheet_detail  t
                       JOIN uss_ndi.v_ndi_payment_type q
                           ON (q.npt_id = t.prsd_npt)
                 WHERE t.prsd_pr = id.prs
                 FETCH FIRST ROW ONLY;

                -- #94837: По кнопці "Для потреби" підключити функціонал по створенню документу власної потреби
                DNET$BUDGETING.INIT_FUNDING_REQUEST (l_row.pr_month,
                                                     'MAIN',
                                                     l_nbg,
                                                     l_new_id);
            END IF;
        END LOOP;
    END;

    -- #70562: Зафіксувати виплату
    PROCEDURE FIX_CARD (P_PR_ID IN NUMBER)
    IS
        l_st   VARCHAR2 (10);
    BEGIN
        SELECT pr_st
          INTO l_st
          FROM v_payroll t
         WHERE t.pr_id = p_pr_Id;

        IF (l_st IS NULL OR l_st != 'V')
        THEN                                             -- переводим из V в F
            raise_application_error (
                -20000,
                'Неможливо провести виплату в поточному стані!');
        END IF;

        CALC$PAYROLL.fix_payroll (p_pr_id);              -- переводим из V в F
    END;

    -- #76596 kolio масово Зафіксувати виплату
    PROCEDURE FIX_CARDS (PRS_IDS IN VARCHAR2, P_RES OUT SYS_REFCURSOR)
    IS
        l_st   VARCHAR2 (10);

        CURSOR ids IS
                SELECT REGEXP_SUBSTR (text,
                                      '[^(\,)]+',
                                      1,
                                      LEVEL)    AS prs
                  FROM (SELECT PRS_IDS AS text FROM DUAL)
            CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                              '[^(\,)]+',
                                              1,
                                              LEVEL)) > 0;
    BEGIN
        OPEN p_res FOR
            SELECT t.pr_id     AS id
              FROM v_payroll t
             WHERE     pr_id IN
                           (    SELECT REGEXP_SUBSTR (text,
                                                      '[^(\,)]+',
                                                      1,
                                                      LEVEL)
                                  FROM (SELECT PRS_IDS AS text FROM DUAL)
                            CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                              '[^(\,)]+',
                                                              1,
                                                              LEVEL)) > 0)
                   AND (t.pr_st IS NULL OR t.pr_st != 'V');

        FOR id IN ids
        LOOP
            SELECT pr_st
              INTO l_st
              FROM v_payroll t
             WHERE t.pr_id = id.prs;

            IF (l_st = 'V')
            THEN                                          --переводим из V в F
                CALC$PAYROLL.fix_payroll (id.prs);        --переводим из V в F
            END IF;
        END LOOP;
    END;

    -- Видалення відомості
    PROCEDURE delete_payroll (P_PR_ID IN NUMBER)
    IS
        l_st   VARCHAR2 (10);
    BEGIN
        SELECT pr_st
          INTO l_st
          FROM v_payroll t
         WHERE t.pr_id = p_pr_Id;

        IF (l_st IS NULL OR l_st != 'C')
        THEN
            raise_application_error (
                -20000,
                'Неможливо видалити відомість в поточному стані!');
        END IF;

        CALC$PAYROLL.delete_payroll (p_pr_id);
    END;

    -- #70562 #76946: из P (Ключено в потребу) в F (Фіксовано)
    PROCEDURE SEND_CARD (P_PR_ID IN NUMBER)
    IS
        l_st   VARCHAR2 (10);
    BEGIN
        SELECT pr_st
          INTO l_st
          FROM v_payroll t
         WHERE t.pr_id = p_pr_Id;

        IF (l_st IS NULL OR l_st != 'P')
        THEN                                             -- переводим из P в F
            raise_application_error (
                -20000,
                'Неможливо провести виплату в поточному стані!');
        END IF;


        CALC$PAYROLL.send_payroll (p_pr_id);             -- переводим из P в V
        CALC$PAYROLL.fix_payroll (p_pr_id);               --переводим из V в F
    END;

    -- #76596 #76946 kolio масово из P (Ключено в потребу) в F (Фіксовано)
    PROCEDURE SEND_CARDS (PRS_IDS IN VARCHAR2, P_RES OUT SYS_REFCURSOR)
    IS
        l_st   VARCHAR2 (10);

        CURSOR ids IS
                SELECT REGEXP_SUBSTR (text,
                                      '[^(\,)]+',
                                      1,
                                      LEVEL)    AS prs
                  FROM (SELECT PRS_IDS AS text FROM DUAL)
            CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                              '[^(\,)]+',
                                              1,
                                              LEVEL)) > 0;
    BEGIN
        OPEN p_res FOR
            SELECT t.pr_id     AS id
              FROM v_payroll t
             WHERE     pr_id IN
                           (    SELECT REGEXP_SUBSTR (text,
                                                      '[^(\,)]+',
                                                      1,
                                                      LEVEL)
                                  FROM (SELECT PRS_IDS AS text FROM DUAL)
                            CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                              '[^(\,)]+',
                                                              1,
                                                              LEVEL)) > 0)
                   AND (t.pr_st IS NULL OR t.pr_st != 'P');

        FOR id IN ids
        LOOP
            SELECT pr_st
              INTO l_st
              FROM v_payroll t
             WHERE t.pr_id = id.prs;

            IF (l_st = 'P')
            THEN          --переводим из P (Ключено в потребу) в F (Фіксовано)
                CALC$PAYROLL.send_payroll (id.prs);       --переводим из P в V
                CALC$PAYROLL.fix_payroll (id.prs);        --переводим из V в F
            END IF;
        END LOOP;
    END;

    -- #88638: розфіксації відомостей
    PROCEDURE UNFIX_CARDS (PRS_IDS IN VARCHAR2)
    IS
        l_st   VARCHAR2 (10);

        CURSOR ids IS
                SELECT REGEXP_SUBSTR (text,
                                      '[^(\,)]+',
                                      1,
                                      LEVEL)    AS prs
                  FROM (SELECT PRS_IDS AS text FROM DUAL)
            CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                              '[^(\,)]+',
                                              1,
                                              LEVEL)) > 0;
    BEGIN
        FOR id IN ids
        LOOP
            CALC$PAYROLL.unfix_payroll (id.prs);
        END LOOP;
    END;

    -- info:  #78238 можливість вивантаження данних по відомостям в текстовому вигляді
    -- params: p_ids  – ід ПД
    --         p_fname  - назва файлу архіва з файлами
    --         p_result - zip - архів з файлами
    PROCEDURE EXPORT_CARDS (p_ids      IN     VARCHAR2,
                            p_fname       OUT VARCHAR2,
                            p_result      OUT BLOB)
    IS
        exEmptyMFOorACCOUNT   EXCEPTION;
        exNoData              EXCEPTION;

        l_txt_clob            CLOB;             --зміст одного з файлів архіву
        l_header              VARCHAR2 (32000);  --заголовок в тексовому файлі
        l_txt_file_name       VARCHAR2 (500); --назва одного з файлів в архіві
        l_files               ikis_sysweb.tbl_some_files
                                  := ikis_sysweb.tbl_some_files (); --перелік файлів в архіві

        oldCOMORG             NUMBER (5); --временная переменная чтобы отличать что пора сменять файл
        oldPayDT              DATE; --временная переменная чтобы отличать что пора сменять файл
        oldFileYearMonth      DATE; --при смене год+месяц сбрасываем счетчик порции в 01
        isNewFile             BOOLEAN; --признак что создается новый файл - заполняем имя файла и его содержимое
        rowsCnt               NUMBER (10); --кол. записей которые запишем в файлы
        tmpIndex              NUMBER (10);
        packetNum             NUMBER (2); --последние цифры в имени файла являются порцией

        --получаем список особ с сортировкой по МФО, дате выплаты, чтобы потом можно было записи распихивать в разные файлы на выход
        CURSOR p_payrolls_res IS
              SELECT p.com_org,
                     p.pr_month,
                     b.nb_mfo,
                     b.nb_num,
                     ps.prs_pay_dt,
                     ps.prs_inn,
                     ps.prs_account,
                     ps.prs_ln || ' ' || ps.prs_fn || ' ' || ps.prs_mn
                         AS prs_pib,
                     ps.prs_sum
                FROM v_payroll p
                     JOIN v_pr_sheet ps ON ps.prs_pr = p.pr_id
                     LEFT JOIN uss_ndi.v_ndi_bank b ON (b.nb_id = ps.prs_nb)
               WHERE p.pr_id IN (    SELECT REGEXP_SUBSTR (text,
                                                           '[^(\,)]+',
                                                           1,
                                                           LEVEL)
                                       FROM (SELECT p_ids AS text FROM DUAL)
                                 CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                                   '[^(\,)]+',
                                                                   1,
                                                                   LEVEL)) > 0)
            ORDER BY p.com_org, ps.prs_pay_dt;
    BEGIN
        --ищем пустые МФО и счета особ
        rowsCnt := 0;

        FOR payroll IN p_payrolls_res
        LOOP
            IF payroll.nb_mfo IS NULL OR payroll.prs_account IS NULL
            THEN
                RAISE exEmptyMFOorACCOUNT;
            END IF;

            rowsCnt := rowsCnt + 1;
        END LOOP;

        --сброс переменных чтобы начать новый файл
        isNewFile := TRUE;
        tmpIndex := 0;
        packetNum := 1;
        oldFileYearMonth := NULL;
        DBMS_LOB.createTemporary (l_txt_clob, TRUE);
        DBMS_LOB.open (l_txt_clob, DBMS_LOB.lob_readwrite);

        FOR p IN p_payrolls_res
        LOOP
            IF oldFileYearMonth IS NULL
            THEN
                oldFileYearMonth := p.pr_month;
            END IF;

            IF isNewFile
            THEN
                oldCOMORG := p.com_org;
                oldPayDT := p.prs_pay_dt;
                l_header := 'test';                                    -- TODO
                DBMS_LOB.append (l_txt_clob,
                                 l_header || CHR (13) || CHR (10));
                isNewFile := FALSE;
            END IF;

            --сменился день выплаты или орган - значит новый файл
            IF oldCOMORG = p.com_org AND oldPayDT = p.prs_pay_dt
            THEN
                DBMS_LOB.append (
                    l_txt_clob,
                       SUBSTR (p.prs_account, 1, 29)
                    || '028'
                    || LPAD (TO_CHAR (p.prs_sum * 100), 19, '0')
                    || RPAD (SUBSTR (p.prs_pib, 1, 100), 100, ' ')
                    || LPAD (SUBSTR (p.prs_inn, 1, 10), 10, '0')
                    || TO_CHAR (p.prs_pay_dt, 'DD')
                    || CHR (13)
                    || CHR (10));

                IF tmpIndex = rowsCnt - 1
                THEN  --последняя запись - нужно добавить файл в будущий архив
                    --строим имя файла
                    l_txt_file_name :=
                           'REQ_'
                        || SUBSTR (TO_CHAR (p.com_org), 2, 4)
                        || '_'
                        || p.nb_mfo
                        || TO_CHAR (p.pr_month, '_YY_MM')
                        || '_95_'
                        || LPAD (TO_CHAR (packetNum), 2, '0')
                        || '.TXT';
                    --добавляем файл к списку на архивацию
                    l_files.EXTEND;
                    l_files (l_files.LAST) :=
                        ikis_sysweb.t_some_file_info (
                            l_txt_file_name,
                            tools.ConvertC2B (l_txt_clob));
                END IF;
            ELSE                    --произошла смена com_org или даты выплаты
                --строим имя файла
                l_txt_file_name :=
                       'REQ_'
                    || SUBSTR (TO_CHAR (oldCOMORG), 2, 4)
                    || '_'
                    || p.nb_mfo
                    || TO_CHAR (oldFileYearMonth, '_YY_MM')
                    || '_95_'
                    || LPAD (TO_CHAR (packetNum), 2, '0')
                    || '.TXT';
                --добавляем файл к списку на архивацию
                l_files.EXTEND;
                l_files (l_files.LAST) :=
                    ikis_sysweb.t_some_file_info (
                        l_txt_file_name,
                        tools.ConvertC2B (l_txt_clob));

                --записываем новую строку в новый файл
                DBMS_LOB.TRIM (l_txt_clob, 0); --очищаем контент для след. файла
                l_header := 'test';                                    -- TODO
                DBMS_LOB.append (l_txt_clob,
                                 l_header || CHR (13) || CHR (10));
                DBMS_LOB.append (
                    l_txt_clob,
                       SUBSTR (p.prs_account, 1, 29)
                    || '028'
                    || LPAD (TO_CHAR (p.prs_sum * 100), 19, '0')
                    || RPAD (SUBSTR (p.prs_pib, 1, 100), 100, ' ')
                    || LPAD (SUBSTR (p.prs_inn, 1, 10), 10, '0')
                    || TO_CHAR (p.prs_pay_dt, 'DD')
                    || CHR (13)
                    || CHR (10));              --добавляем новую строку в файл

                oldPayDT := p.prs_pay_dt;

                IF oldFileYearMonth <> p.pr_month OR oldCOMORG <> p.com_org
                THEN                                            --смена порции
                    packetNum := 1;
                    oldFileYearMonth := p.pr_month;
                    oldCOMORG := p.com_org;
                ELSE
                    packetNum := packetNum + 1;
                END IF;

                IF tmpIndex = rowsCnt - 1
                THEN  --последняя запись - нужно добавить файл в будущий архив
                    --строим имя файла
                    l_txt_file_name :=
                           'REQ_'
                        || SUBSTR (TO_CHAR (p.com_org), 2, 4)
                        || '_'
                        || p.nb_mfo
                        || TO_CHAR (p.pr_month, '_YY_MM')
                        || '_95_'
                        || LPAD (TO_CHAR (packetNum), 2, '0')
                        || '.TXT';
                    --добавляем файл к списку на архивацию
                    l_files.EXTEND;
                    l_files (l_files.LAST) :=
                        ikis_sysweb.t_some_file_info (
                            l_txt_file_name,
                            tools.ConvertC2B (l_txt_clob));
                END IF;
            END IF;

            tmpIndex := tmpIndex + 1;
        END LOOP;

        IF DBMS_LOB.ISOPEN (l_txt_clob) > 0
        THEN
            DBMS_LOB.close (l_txt_clob);
        END IF;

        DBMS_LOB.freetemporary (l_txt_clob);

        --архів
        IF l_files.COUNT > 0
        THEN
            p_result := ikis_sysweb.ikis_web_jutil.getZipFromStrms (l_files);
            p_fname := 'payroll_export.zip';
        ELSE
            RAISE exNoData;
        END IF;
    EXCEPTION
        WHEN exNoData
        THEN
            raise_application_error (
                -20000,
                'Відсутні дані для формування вивантаження');
        WHEN exEmptyMFOorACCOUNT
        THEN
            raise_application_error (
                -20000,
                'Є особи, у яких відсутні дані про банківський рахунок');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'DNET$PAYMENT_INFO.EXPORT_CARDS:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;

    -- io   обробка КВ-1
    PROCEDURE proc_pca_pkt (p_pkt_id IN NUMBER)
    IS
    BEGIN
        API$ESR_EXCHANGE.proc_pca_pkt (p_pkt_id => p_pkt_id);
    END;

    -- io обробка КВ-2
    PROCEDURE proc_ppr_pkt (p_pkt_id IN NUMBER)
    IS
    BEGIN
        API$ESR_EXCHANGE.proc_ppr_pkt (p_pkt_id => p_pkt_id);
    END;

    -- io обробка КВ-1/2  в статусі Новий
    PROCEDURE ProcessKV (p_pkt_id IN NUMBER)
    IS
    BEGIN
        API$ESR_EXCHANGE.ProcessKV (p_pkt_id => p_pkt_id);
    END;

    --  #81330 Формування відомостей на банк в електронному вигляді по 6 допомогам
    --  io Без запису в ПЕОД, фактично це звіт...
    PROCEDURE BuildBankFiles (p_pr_ids         VARCHAR2,
                              p_rpt        OUT BLOB,
                              p_rpt_name   OUT VARCHAR2)
    IS
        l_rpt   BLOB;
    BEGIN
        p_rpt_name :=
            'PR_BANK_' || TO_CHAR (SYSDATE, 'yyyymmdd_hh24miss') || '.zip';
        DBMS_LOB.createtemporary (lob_loc => l_rpt, cache => TRUE);
        DBMS_LOB.open (lob_loc => l_rpt, open_mode => DBMS_LOB.lob_readwrite);

        API$ESR_EXCHANGE.BuildBankFiles (p_pr_ids         => p_pr_ids,
                                         p_convert_symb   => 'K',
                                         p_rpt            => l_rpt);
        p_rpt := l_rpt;
    END;

    --  #81531 Формування відомостей на Поштув електронному вигляді по 6 допомогам
    --  io Без запису в ПЕОД, фактично це звіт...
    PROCEDURE BuildPostFiles (p_pr_ids         VARCHAR2,
                              p_rpt        OUT BLOB,
                              p_rpt_name   OUT VARCHAR2)
    IS
        l_rpt   BLOB;
    BEGIN
        p_rpt_name :=
            'PR_POST_' || TO_CHAR (SYSDATE, 'yyyymmdd_hh24miss') || '.zip';
        DBMS_LOB.createtemporary (lob_loc => l_rpt, cache => TRUE);
        DBMS_LOB.open (lob_loc => l_rpt, open_mode => DBMS_LOB.lob_readwrite);

        API$ESR_EXCHANGE.BuildPostFiles (p_pr_ids => p_pr_ids, p_rpt => l_rpt);
        p_rpt := l_rpt;
    END;

    --  #98707 формування пакету по виплаті по пошті знідно протоколу (поки це буде лише для виплат ВПП ООН)
    PROCEDURE BuildPostFiles2 (p_pr_ids         VARCHAR2,
                               p_rpt        OUT BLOB,
                               p_rpt_name   OUT VARCHAR2)
    IS
        l_rpt   BLOB;
    BEGIN
        p_rpt_name :=
            'PR_POST_' || TO_CHAR (SYSDATE, 'yyyymmdd_hh24miss') || '.zip';
        DBMS_LOB.createtemporary (lob_loc => l_rpt, cache => TRUE);
        DBMS_LOB.open (lob_loc => l_rpt, open_mode => DBMS_LOB.lob_readwrite);

        API$ESR_EXCHANGE.BuildPostFiles (p_pr_ids => p_pr_ids, o_rpt => l_rpt);
        p_rpt := l_rpt;
    END;

    -- #110218 формування пакету по ПІ по пошті знідно протоколу
    PROCEDURE BuildPostFilesPO (p_po_ids         VARCHAR2,
                                p_rpt        OUT BLOB,
                                p_rpt_name   OUT VARCHAR2)
    IS
        l_rpt   BLOB;
    BEGIN
        p_rpt_name :=
            'PI_POST_' || TO_CHAR (SYSDATE, 'yyyymmdd_hh24miss') || '.zip';
        DBMS_LOB.createtemporary (lob_loc => l_rpt, cache => TRUE);
        DBMS_LOB.open (lob_loc => l_rpt, open_mode => DBMS_LOB.lob_readwrite);

        API$ESR_EXCHANGE.BuildPostFilesPO (p_po_ids   => p_po_ids,
                                           o_rpt      => l_rpt);
        p_rpt := l_rpt;
    END;

    -- #86227
    PROCEDURE set_non_payment (p_prs_id     IN pr_sheet.prs_id%TYPE,
                               p_block_tp   IN VARCHAR2)
    IS
    BEGIN
        api$payroll.na_manual_block (p_prs_id     => p_prs_id,
                                     p_block_tp   => p_block_tp);
    END;

    -- #86227
    PROCEDURE error_confirmation (p_prs_id IN pr_sheet.prs_id%TYPE)
    IS
    BEGIN
        api$payroll.kv2_manual_return (p_prs_id => p_prs_id);
    END;

    -- #86227
    PROCEDURE error_blocking (p_prs_id IN pr_sheet.prs_id%TYPE)
    IS
    BEGIN
        api$payroll.pk2_manual_return (p_prs_id => p_prs_id);
    END;

    -- #86227
    PROCEDURE confirm_payment (p_pr_id payroll.pr_id%TYPE, p_pr_sum DECIMAL)
    IS
    BEGIN
        api$payroll.na_manual_confirm (p_pr_id    => p_pr_id,
                                       p_pr_sum   => p_pr_sum);
    END;

    -- #97478 Обробка квитанції повернення від пошти
    PROCEDURE proc_kpp_pkt (p_pkt_id IN NUMBER)
    IS
    BEGIN
        USS_ESR.API$ESR_EXCHANGE.proc_kpp_pkt (p_pkt_id);
    END;

    PROCEDURE get_pr_log (p_pr_id NUMBER, p_res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res_cur FOR
              SELECT prsl_id                                                   AS log_id,
                     prsl_pr                                                   AS log_obj,
                     prsl_tp                                                   AS log_tp,
                     st.dic_name                                               AS log_st_name,
                     sto.dic_name                                              AS log_st_old_name,
                     hs_dt                                                     AS log_hs_dt,
                     tools.GetUserLogin (hs_wu)                                AS log_hs_author,
                     uss_ndi.RDM$MSG_TEMPLATE.getmessagetext (prsl_message)    AS log_message
                FROM prs_log t
                     LEFT JOIN uss_ndi.v_ddn_pr_st st
                         ON (st.dic_value = prsl_st)
                     LEFT JOIN uss_ndi.v_ddn_pr_st sto
                         ON (sto.dic_value = prsl_st_old)
                     LEFT JOIN v_histsession ON (hs_id = prsl_hs)
               WHERE prsl_pr = p_pr_id
            ORDER BY hs_dt;
    END;

    PROCEDURE get_prs_log (p_prs_id NUMBER, p_res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res_cur FOR
              SELECT prsl_id                                                   AS log_id,
                     prsl_prs                                                  AS log_obj,
                     prsl_tp                                                   AS log_tp,
                     st.dic_name                                               AS log_st_name,
                     sto.dic_name                                              AS log_st_old_name,
                     hs_dt                                                     AS log_hs_dt,
                     tools.GetUserLogin (hs_wu)                                AS log_hs_author,
                     uss_ndi.RDM$MSG_TEMPLATE.getmessagetext (prsl_message)    AS log_message
                FROM prs_log t
                     LEFT JOIN uss_ndi.v_ddn_pr_st st
                         ON (st.dic_value = prsl_st)
                     LEFT JOIN uss_ndi.v_ddn_pr_st sto
                         ON (sto.dic_value = prsl_st_old)
                     LEFT JOIN v_histsession ON (hs_id = prsl_hs)
               WHERE prsl_prs = p_prs_id
            ORDER BY hs_dt;
    END;

    PROCEDURE get_po_list (p_pr_id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT DISTINCT r.com_org_src                     AS com_org,
                            p.org_id || ' ' || p.org_name     AS org_name,
                            r.po_pay_dt                       AS po_dt,
                            r.po_name_dest                    AS po_name,
                            r.po_sum,
                            r.po_id
              FROM payroll_reestr  t
                   JOIN pay_order r ON (r.po_id = t.pe_po)
                   JOIN v_opfu p ON (p.org_id = r.com_org_src)
             WHERE t.pe_pr = p_pr_id;
    END;
BEGIN
    NULL;
END DNET$PAYMENT_INFO;
/