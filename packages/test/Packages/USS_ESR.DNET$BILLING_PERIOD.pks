/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$BILLING_PERIOD
IS
    -- Author  : VANO
    -- Created : 21.06.2022 14:46:01
    -- Purpose : Функції роботи з розрахунковими періодами - інтерфейс для .NET

    PROCEDURE get_billing_period_list (
        p_isonlycurrent   IN     VARCHAR2 DEFAULT 'F',
        p_bp_org          IN     billing_period.com_org%TYPE,
        res_cur              OUT SYS_REFCURSOR);



    -- список осзн
    PROCEDURE get_org_list (res_cur OUT SYS_REFCURSOR);

    PROCEDURE get_log_list (p_bp_id IN NUMBER, res_cur OUT SYS_REFCURSOR);

    PROCEDURE close_period (p_bp_ids     IN     VARCHAR2,
                            p_messages      OUT SYS_REFCURSOR);
END DNET$BILLING_PERIOD;
/


GRANT EXECUTE ON USS_ESR.DNET$BILLING_PERIOD TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$BILLING_PERIOD TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$BILLING_PERIOD
IS
    PROCEDURE get_billing_period_list (
        p_isonlycurrent   IN     VARCHAR2 DEFAULT 'F',
        p_bp_org          IN     billing_period.com_org%TYPE,
        res_cur              OUT SYS_REFCURSOR)
    IS
        l_user_type   VARCHAR2 (250);
        l_bp_class    billing_period.bp_class%TYPE;
    BEGIN
        tools.writemsg ('DNET$BILLING_PERIOD.' || $$PLSQL_UNIT);
        l_user_type :=
            SYS_CONTEXT (uss_esr_context.gcontext, uss_esr_context.gusertp);
        l_bp_class := CASE WHEN l_user_type = '41' THEN 'VPO' ELSE 'V' END;

        calc$payroll.init_com_orgs (NULL);                -- #80637 OPERVIEIEV

        OPEN res_cur FOR
              SELECT t.*,
                     st.dic_name                     AS bp_st_name,
                     c.dic_name                      AS bp_class_name,
                     tp.dic_name                     AS bp_tp_name,
                     hs.hs_dt                        AS bp_hs_close_dt,
                     tools.getuserpib (hs.hs_wu)     AS bp_hs_close_pib,
                     p.org_name                      AS bp_org_name
                FROM v_billing_period t
                     JOIN v_opfu p ON (p.org_id = t.bp_org)
                     JOIN uss_ndi.v_ddn_bp_st st ON (st.dic_value = t.bp_st)
                     JOIN uss_ndi.v_ddn_bp_pr_class c
                         ON (c.dic_value = t.bp_class)
                     JOIN uss_ndi.v_ddn_bp_tp tp ON (tp.dic_value = t.bp_tp)
                     LEFT JOIN histsession hs ON (hs.hs_id = t.bp_hs_close)
               WHERE               -- t.com_org IN (SELECT u_org FROM tmp_org)
                         (   (    l_bp_class = 'VPO'
                              AND t.com_org IN (SELECT u_org FROM tmp_org))
                          OR t.com_org IN (SELECT x_id FROM tmp_com_orgs)) -- #80637 OPERVIEIEV
                     AND (   p_isonlycurrent IS NULL
                          OR p_isonlycurrent = 'F'
                          OR (p_isonlycurrent = 'T' AND t.bp_st = 'R'))
                     AND (   p_bp_org IS NULL
                          OR t.bp_org = p_bp_org
                          OR t.bp_org IN (SELECT op.org_id
                                            FROM v_opfu op
                                           WHERE op.org_org = p_bp_org))
                     AND bp_class = l_bp_class
                     AND org_st = 'A'
            ORDER BY t.bp_month DESC;
    END;

    -- список осзн
    PROCEDURE get_org_list (res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        api$accrual.get_org_list (1, res_cur);
    END;

    PROCEDURE get_log_list (p_bp_id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.WriteMsg ('DNET$BILLING_PERIOD.' || $$PLSQL_UNIT);

        OPEN res_cur FOR
              SELECT t.bpl_id
                         AS log_id,
                     t.bpl_bp
                         AS log_obj,
                     t.bpl_tp
                         AS log_tp,
                     st.DIC_NAME
                         AS log_st_name,
                     sto.DIC_NAME
                         AS log_st_old_name,
                     hs.hs_dt
                         AS log_hs_dt,
                     tools.GetUserPib (hs.hs_wu)
                         AS log_hs_pib,                               --unused
                     NVL (tools.GetUserLogin (hs.hs_wu), 'Автоматично')
                         AS log_hs_author,
                     Uss_Ndi.Rdm$msg_Template.Getmessagetext (t.bpl_message)
                         AS log_message
                FROM v_bp_log t
                     LEFT JOIN uss_ndi.v_ddn_pd_st st
                         ON (st.DIC_VALUE = t.bpl_st)
                     LEFT JOIN uss_ndi.v_ddn_pd_st sto
                         ON (sto.DIC_VALUE = t.bpl_st_old)
                     LEFT JOIN histsession hs ON (hs.hs_id = t.bpl_hs)
               WHERE t.bpl_bp = p_bp_id
            ORDER BY hs.hs_dt;
    END;



    PROCEDURE close_period (p_bp_ids     IN     VARCHAR2,
                            p_messages      OUT SYS_REFCURSOR)
    IS
    BEGIN
        API$BILLING_PERIOD.close_period (p_bp_ids, p_messages);
    END;
END DNET$BILLING_PERIOD;
/