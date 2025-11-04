/* Formatted on 8/12/2025 5:48:24 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$AP_SEND_MESSAGE
IS
    -- Author  : SERHII
    -- Created : 18.08.2023
    -- Purpose : #89850 Підсистема інформування про призупинення виплат (частина для USS_ESR)

    -- для передачі Ід карт, дат, причин та іншого, що можна отримати в точці виклику
    TYPE block_rec IS RECORD
    (
        sc_id      NUMBER (14),
        atr_num    NUMBER (14),
        art_str    VARCHAR2 (250),
        atr_dt     DATE,
        src_prc    VARCHAR2 (250),
        res_txt    VARCHAR2 (4000)
    );

    TYPE block_rec_tbl IS TABLE OF block_rec;

    -- Виклик інформування з API$PC_BLOCK
    PROCEDURE Notify_VPO_on_Block_Payment;

    -- Виклик інформування з Dnet$pay_Assignments.APPROVE_DECISION_PAYMENTS / SAVE_DECISION_REJECTS
    PROCEDURE Notify_VPO_on_Change_Decision (p_pd_id   IN NUMBER,
                                             p_pd_st   IN VARCHAR2);        --

    -- Виклик інформування з API$PAYROLL.kv_proc_pay_int
    PROCEDURE Notify_VPO_on_Payroll;
END API$AP_SEND_MESSAGE;
/


GRANT EXECUTE ON USS_ESR.API$AP_SEND_MESSAGE TO II01RC_USS_ESR_INTERNAL
/

GRANT EXECUTE ON USS_ESR.API$AP_SEND_MESSAGE TO IKIS_RBM
/

GRANT EXECUTE ON USS_ESR.API$AP_SEND_MESSAGE TO USS_PERSON
/

GRANT EXECUTE ON USS_ESR.API$AP_SEND_MESSAGE TO USS_RPT
/

GRANT EXECUTE ON USS_ESR.API$AP_SEND_MESSAGE TO USS_VISIT
/


/* Formatted on 8/12/2025 5:48:50 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$AP_SEND_MESSAGE
IS
    g_debug_pipe   BOOLEAN := FALSE;                                  --  TRUE

    PROCEDURE Notify_VPO_on_Block_Payment
    IS
        l_blck2inf   block_rec_tbl := block_rec_tbl ();
        l_prc_name   VARCHAR2 (250) := 'Notify_VPO_on_Block_Payment';
    BEGIN
        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (l_prc_name || ' started');
        END IF;

          SELECT pc_sc
                     AS sc_id,
                 nddc_code_dest
                     AS atr_num,
                 rnp_name
                     AS art_str,
                 MAX (TRUNC (ADD_MONTHS (ac.pdap_stop_dt, 1), 'MM'))
                     AS atr_dt,
                 l_prc_name
                     AS src_prc,
                 'Initial'
                     AS res_txt
            BULK COLLECT INTO l_blck2inf
            FROM pc_block
                 JOIN tmp_pc_block ON b_id = pcb_id         -- only new blocks
                 JOIN pc_decision
                     ON     pd_id = pcb_pd
                        AND pd_nst IN (265,
                                       267,
                                       269,
                                       664) -- #97308 коди невідповідностей вже містять коди інших трьох допомог
                 JOIN personalcase ON pc_id = pcb_pc
                 JOIN uss_ndi.v_ndi_reason_not_pay
                     ON rnp_id = pcb_rnp AND rnp_is_need_inform = 'T'
                 JOIN uss_ndi.v_ndi_decoding_config
                     ON nddc_code_src = rnp_code AND nddc_tp = 'RESN2TMPL'
                 JOIN pd_accrual_period ac
                     ON pcb_pd = ac.pdap_pd AND ac.history_status = 'A'
           WHERE pcb_tp IN ('HPD', 'MR')
        GROUP BY pc_sc,
                 nddc_code_dest,
                 pcb_rnp,
                 rnp_name;

        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (
                   l_prc_name
                || ' l_blck2inf.count: '
                || TO_CHAR (l_blck2inf.COUNT));
        END IF;

        IF l_blck2inf.COUNT > 0
        THEN
            uss_person.api$ap_send_message.Batch_Notify_VPO (
                p_blck2inf   => l_blck2inf);
        END IF;

        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (l_prc_name || ' finished');
        END IF;
    END Notify_VPO_on_Block_Payment;

    PROCEDURE Notify_VPO_on_Change_Decision (p_pd_id   IN NUMBER,
                                             p_pd_st   IN VARCHAR2)
    IS
        l_blck2inf        block_rec_tbl := block_rec_tbl ();
        l_aprv_templ_id   PLS_INTEGER;
        l_prc_name        VARCHAR2 (250) := 'Notify_VPO_on_Change_Decision';
    BEGIN
        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (l_prc_name || ' started');
        END IF;

        IF p_pd_st = 'S'
        THEN
            l_aprv_templ_id := 150;                         -- Призначення ВПО
        ELSIF p_pd_st = 'V'
        THEN
            l_aprv_templ_id := 155;               -- Відмова в призначенні ВПО
        ELSE
            RETURN;
        END IF;

          SELECT pc_sc,
                 l_aprv_templ_id,
                 NULL,
                 MIN (pm.pdp_start_dt),
                 l_prc_name,
                 'Initial'
            BULK COLLECT INTO l_blck2inf
            FROM pc_decision
                 JOIN personalcase ON pc_id = pd_pc
                 LEFT JOIN pd_payment pm
                     ON pm.pdp_pd = pd_id AND pm.history_status = 'A'
           WHERE pd_id = p_pd_id AND pd_nst = 664 --only: Допомога на проживання внутрішньо переміщеним особам, постанова 332
        GROUP BY pc_sc, l_aprv_templ_id;

        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (
                'Notify_VPO_on_Change_Decision');
        END IF;

        IF l_blck2inf.COUNT > 0
        THEN
            IF g_debug_pipe
            THEN
                ikis_sysweb.ikis_debug_pipe.WriteMsg (
                       l_prc_name
                    || ' l_blck2inf.count: '
                    || TO_CHAR (l_blck2inf.COUNT));
            END IF;

            uss_person.api$ap_send_message.Batch_Notify_VPO (
                p_blck2inf   => l_blck2inf);
        END IF;

        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (l_prc_name || ' finished');
        END IF;
    END Notify_VPO_on_Change_Decision;

    PROCEDURE Notify_VPO_on_Payroll
    IS
        l_blck2inf        block_rec_tbl := block_rec_tbl ();
        l_aprv_templ_id   PLS_INTEGER := 160;
        l_prc_name        VARCHAR2 (250) := 'Notify_VPO_on_Payroll';
    BEGIN
        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (l_prc_name || ' started');
        END IF;

          SELECT pc_sc,
                 l_aprv_templ_id,
                 NULL,
                 prsd_month,
                 l_prc_name,
                 'Initial'
            BULK COLLECT INTO l_blck2inf
            FROM v_pr_sheet_detail
                 JOIN tmp_prs_block ON x_prs = prsd_prs AND x_block_tp = '200'
                 JOIN pr_sheet ON prsd_prs = prs_id AND prs_st = 'KV2'
                 JOIN payroll ON pr_id = prs_pr AND pr_npc = 24 --only: Допомога переміщеним особам на проживання
                 JOIN personalcase ON pc_id = prsd_pc
           WHERE prsd_is_payed = 'T'
        GROUP BY pc_sc, prsd_month;

        IF l_blck2inf.COUNT > 0
        THEN
            IF g_debug_pipe
            THEN
                ikis_sysweb.ikis_debug_pipe.WriteMsg (
                       l_prc_name
                    || ' l_blck2inf.count: '
                    || TO_CHAR (l_blck2inf.COUNT));
            END IF;

            uss_person.api$ap_send_message.Batch_Notify_VPO (
                p_blck2inf   => l_blck2inf);
        END IF;

        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (l_prc_name || ' finished');
        END IF;
    END Notify_VPO_on_Payroll;
BEGIN
    NULL;
END API$AP_SEND_MESSAGE;
/