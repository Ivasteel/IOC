/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$STATE_WITHHOLDINGS
IS
    PROCEDURE Get_STATE_WITHHOLDINGS (p_pc_id        PersonalCase.Pc_Id%TYPE,
                                      p_sa_cur   OUT SYS_REFCURSOR,
                                      p_pc_cur   OUT SYS_REFCURSOR);
END dnet$state_withholdings;
/


/* Formatted on 8/12/2025 5:49:56 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$STATE_WITHHOLDINGS
IS
    PROCEDURE Get_STATE_WITHHOLDINGS (p_pc_id        PersonalCase.Pc_Id%TYPE,
                                      p_sa_cur   OUT SYS_REFCURSOR,
                                      p_pc_cur   OUT SYS_REFCURSOR)
    IS
    BEGIN
        --state alimony
        OPEN p_sa_cur FOR
            SELECT sa.ps_id,
                   pp.dpp_name,
                   pp.dpp_tax_code,
                   pp.dpp_address,                -- назва код адресса закладу
                   sa.ps_start_dt,
                   sa.ps_stop_dt,                                  --Діє з..п;
                   ap.ap_num,
                   ap.ap_reg_dt,          --№ + дата звернення (ps_ap) appeal;
                   h.hs_dt, --tools.GetHistSession, --Час створення (ps_hs_ins -> histsession)
                   sa.ps_st,
                   ps.DIC_NAME     AS Ps_St_Name --Стан (uss_ndi.v_ddn_ps_st);
              FROM pc_state_alimony  sa
                   LEFT JOIN Uss_Ndi.v_Ndi_Pay_Person pp
                       ON pp.dpp_id = sa.ps_dpp
                   LEFT JOIN appeal ap ON ap.ap_id = sa.ps_ap
                   LEFT JOIN histsession h ON h.hs_id = sa.ps_hs_ins
                   JOIN uss_ndi.v_ddn_ps_st ps ON ps.DIC_VALUE = sa.ps_st
             WHERE sa.ps_pc = p_pc_id;

        OPEN p_pc_cur FOR
            SELECT cg.psc_id,
                   cg.psc_start_dt,
                   cg.psc_stop_dt,                                --Діє з..по;
                   ap.ap_num,
                   ap.ap_reg_dt,                --№ + дата звернення (psc_ap);
                   cg.psc_tp, --Причина зміни стану (psc_tp -> uss_ndi.v_ddn_psc_tp);
                   cg.psc_dppa,
                   ppa.dppa_description     AS Psc_Dppa_Desc, --Рахунок (psc_dppa -> uss_ndi.ndi_pay_person_acc);
                   h.hs_dt,       --Час створення (psc_hs_ins -> histsession);
                   cg.psc_st,
                   psc.DIC_NAME             AS Psc_St_Name --Стан (uss_ndi.v_ddn_psc_st);
              FROM ps_changes  cg
                   JOIN pc_state_alimony ON ps_id = psc_ps
                   LEFT JOIN histsession h ON h.hs_id = cg.psc_hs_ins
                   LEFT JOIN appeal ap ON ap.ap_id = cg.psc_ap
                   LEFT JOIN uss_ndi.v_ndi_pay_person_acc ppa
                       ON ppa.dppa_id = cg.psc_dppa
                   LEFT JOIN Uss_Ndi.v_ddn_psc_st psc
                       ON psc.DIC_VALUE = cg.psc_st
             WHERE ps_pc = p_pc_id AND cg.history_status = 'A';
    END;
END DNET$STATE_WITHHOLDINGS;
/