/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$ERRAND
IS
    -- Author  : BOGDAN
    -- Created : 01.06.2023 17:28:11
    -- Purpose : Доручення на разову виплату

    -- #87514: Реєстр доручень на разову виплату
    PROCEDURE get_errand_journal (p_ap_reg_dt_start   IN     DATE,
                                  p_ap_reg_dt_stop    IN     DATE,
                                  p_ed_dt_start       IN     DATE,
                                  p_ed_dt_stop        IN     DATE,
                                  p_pc_num            IN     VARCHAR2,
                                  p_ap_num            IN     VARCHAR2,
                                  p_at_num            IN     VARCHAR2,
                                  p_ed_num            IN     VARCHAR2,
                                  p_pc_rnokpp         IN     VARCHAR2,
                                  p_ed_st             IN     VARCHAR2,
                                  p_ed_tp             IN     VARCHAR2,
                                  res_cur                OUT SYS_REFCURSOR);

    -- #87514: Картка доручень на разову виплату
    PROCEDURE get_errand_card (p_ed_id    IN     NUMBER,
                               info_cur      OUT SYS_REFCURSOR,
                               pay_cur       OUT SYS_REFCURSOR,
                               pay2_cur      OUT SYS_REFCURSOR,
                               pay3_cur      OUT SYS_REFCURSOR);


    -- #87514: збереження способу виплати по дорученню
    PROCEDURE save_errand_card (p_ed_id          IN NUMBER,
                                p_ED_PAY_TP      IN VARCHAR2,
                                p_ED_INDEX       IN VARCHAR2,
                                p_ED_KAOT        IN NUMBER,
                                p_ED_NB          IN NUMBER,
                                p_ED_ACCOUNT     IN VARCHAR2,
                                p_ED_STREET      IN VARCHAR2,
                                p_ED_NS          IN NUMBER,
                                p_ED_BUILDING    IN VARCHAR2,
                                p_ED_BLOCK       IN VARCHAR2,
                                p_ED_APARTMENT   IN VARCHAR2,
                                p_ED_ND          IN ERRAND.ED_ND%TYPE,
                                p_ED_PAY_DT      IN ERRAND.ED_PAY_DT%TYPE);

    -- #87514: Розрахувати доручення
    PROCEDURE recalc_errand_card (p_ed_id IN NUMBER);

    -- #87514: Затвердити доручення
    PROCEDURE approve_errand_card (p_ed_id IN NUMBER);

    -- #87514: Відхилити доручення
    PROCEDURE reject_errand_card (p_ed_id    IN NUMBER,
                                  p_ed_rnp   IN errand.ed_rnp%TYPE);

    --Повернути доручення
    PROCEDURE return_errand_card (p_ed_id IN NUMBER, p_reason IN VARCHAR2);

    -- #87514: Лог доручення
    PROCEDURE get_errand_log (p_ed_id IN NUMBER, res_cur OUT SYS_REFCURSOR);
END DNET$ERRAND;
/


GRANT EXECUTE ON USS_ESR.DNET$ERRAND TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$ERRAND TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:30 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$ERRAND
IS
    -- #87514: Реєстр доручень на разову виплату
    PROCEDURE get_errand_journal (p_ap_reg_dt_start   IN     DATE,
                                  p_ap_reg_dt_stop    IN     DATE,
                                  p_ed_dt_start       IN     DATE,
                                  p_ed_dt_stop        IN     DATE,
                                  p_pc_num            IN     VARCHAR2,
                                  p_ap_num            IN     VARCHAR2,
                                  p_at_num            IN     VARCHAR2,
                                  p_ed_num            IN     VARCHAR2,
                                  p_pc_rnokpp         IN     VARCHAR2,
                                  p_ed_st             IN     VARCHAR2,
                                  p_ed_tp             IN     VARCHAR2,
                                  res_cur                OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT t.*,
                   p.pc_num,
                   ap.ap_num,
                   ap.ap_reg_dt,
                   src.DIC_NAME
                       AS ap_src_name,
                   st.DIC_NAME
                       AS ed_st_name,
                   tp.DIC_NAME
                       AS ed_tp_name,
                   uss_person.api$sc_tools.GET_PIB (p.pc_sc)
                       AS Owner_pib,
                   --uss_person.api$sc_tools.GET_PIB_SCC(pm.pdm_scc) AS pc_main_pib,
                   uss_person.api$sc_tools.get_numident (p.pc_sc)
                       AS Owner_Rnokpp,
                   uss_person.api$sc_tools.GET_PIB_SCC (t.ed_scc)
                       AS Recipient_pib,
                   uss_person.api$sc_tools.get_numident_scc (t.ed_scc)
                       AS Recipient_Rnokpp,
                   tp.DIC_NAME
                       AS ed_pay_tp_name
              FROM v_errand_by_pc  t
                   LEFT JOIN v_act at ON (at.at_id = t.ed_at)
                   JOIN v_personalcase p ON (p.pc_id = t.ed_pc)
                   LEFT JOIN v_appeal ap ON (ap.ap_id = t.ed_ap)
                   LEFT JOIN uss_ndi.V_DDN_ED_ST st
                       ON (st.DIC_VALUE = t.ed_st)
                   LEFT JOIN uss_ndi.V_DDN_ED_TP tp
                       ON (tp.DIC_VALUE = t.ed_tp)
                   LEFT JOIN uss_ndi.v_ddn_ap_src src
                       ON (src.DIC_VALUE = ap.ap_src)
                   LEFT JOIN uss_ndi.V_DDN_APM_TP tp
                       ON (Tp.DIC_VALUE = t.ed_pay_tp)
             WHERE     1 = 1
                   AND (   p_ap_reg_dt_start IS NULL
                        OR ap.ap_reg_dt >= p_ap_reg_dt_start)
                   AND (   p_ap_reg_dt_stop IS NULL
                        OR ap.ap_reg_dt <= p_ap_reg_dt_stop)
                   AND (p_ed_dt_start IS NULL OR t.ed_dt >= p_ed_dt_start)
                   AND (p_ed_dt_stop IS NULL OR t.ed_dt <= p_ed_dt_stop)
                   AND (p_ed_num IS NULL OR t.ed_num LIKE p_ed_num || '%')
                   AND (p_at_num IS NULL OR at.at_num LIKE p_at_num || '%')
                   AND (p_ap_num IS NULL OR ap.ap_num LIKE p_ap_num || '%')
                   AND (p_pc_num IS NULL OR p.pc_num LIKE p_pc_num || '%')
                   AND (p_ed_st IS NULL OR t.ed_st = p_ed_st)
                   AND (p_ed_tp IS NULL OR t.ed_tp = p_ed_tp)
                   AND (   p_pc_rnokpp IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM uss_person.v_sc_document sd
                                 WHERE     sd.scd_ndt = 5
                                       AND sd.scd_sc = p.pc_sc
                                       AND sd.scd_st IN ('A', '1')
                                       AND sd.scd_number = p_pc_rnokpp));
    END;

    -- #87514: Картка доручень на разову виплату
    PROCEDURE get_errand_card (p_ed_id    IN     NUMBER,
                               info_cur      OUT SYS_REFCURSOR,
                               pay_cur       OUT SYS_REFCURSOR,
                               pay2_cur      OUT SYS_REFCURSOR,
                               pay3_cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN info_cur FOR
            SELECT t.*,
                   p.pc_num,
                   p.pc_sc,
                   ap.ap_tp,
                   ap.ap_num,
                   ap.ap_reg_dt,
                   src.DIC_NAME
                       AS ap_src_name,
                   st.DIC_NAME
                       AS ed_st_name,
                   tp.DIC_NAME
                       AS ed_tp_name,
                   uss_person.api$sc_tools.GET_PIB (p.pc_sc)
                       AS Own_pib,
                   --uss_person.api$sc_tools.GET_PIB_SCC(pm.pdm_scc) AS pc_main_pib,
                   uss_person.api$sc_tools.get_numident (p.pc_sc)
                       AS Own_Rnokpp,
                   uss_person.api$sc_tools.GET_PIB_SCC (t.ed_scc)
                       AS Recipient_pib,
                   uss_person.api$sc_tools.get_numident_scc (t.ed_scc)
                       AS Recipient_Rnokpp,
                   tp.DIC_NAME
                       AS ed_pay_tp_name,
                   k.kaot_code || ' ' || k.kaot_name
                       AS ed_kaot_name,
                   b.nb_name
                       AS ed_nb_name,
                   s.ns_name
                       AS ed_ns_name,
                   d.nd_comment
                       AS ed_nd_name,
                   ap.ap_num
                       AS ed_ap_src_name,
                   d.dn_tp,
                   d.dn_st,
                   d.dn_in_doc_num,
                   dpp.dpp_name
                       AS dn_dpp_name
              FROM v_errand  t
                   JOIN v_personalcase p ON (p.pc_id = t.ed_pc)
                   LEFT JOIN v_act at ON (at.at_id = t.ed_at)
                   LEFT JOIN v_appeal ap ON (ap.ap_id = t.ed_ap)
                   LEFT JOIN deduction d ON (d.dn_id = t.ed_dn)
                   LEFT JOIN uss_ndi.v_ndi_pay_person dpp
                       ON (dpp.dpp_id = d.dn_dpp)
                   LEFT JOIN uss_ndi.V_DDN_ED_ST st
                       ON (st.DIC_VALUE = t.ed_st)
                   LEFT JOIN uss_ndi.V_DDN_ED_TP tp
                       ON (tp.DIC_VALUE = t.ed_tp)
                   LEFT JOIN uss_ndi.v_ddn_ap_src src
                       ON (src.DIC_VALUE = ap.ap_src)
                   LEFT JOIN uss_ndi.V_DDN_APM_TP tp
                       ON (Tp.DIC_VALUE = t.ed_pay_tp)
                   LEFT JOIN uss_ndi.v_ndi_katottg k
                       ON (k.kaot_id = t.ed_kaot)
                   LEFT JOIN uss_ndi.v_ndi_bank b ON (b.nb_id = t.ed_nb)
                   LEFT JOIN uss_ndi.v_ndi_street s ON (s.ns_id = t.ed_ns)
                   LEFT JOIN uss_ndi.v_ndi_delivery d ON (d.nd_id = t.ed_nd)
             WHERE ed_id = p_ed_id;

        OPEN pay_cur FOR
              SELECT t.*,
                     pt.npt_code,
                     pt.npt_name,
                     d.pd_num
                FROM ac_detail t
                     JOIN v_errand e ON (e.ed_id = t.acd_ed)
                     LEFT JOIN uss_ndi.v_ndi_payment_type pt
                         ON (pt.npt_id = t.acd_npt)
                     LEFT JOIN pc_decision d ON (d.pd_id = t.acd_pd)
               WHERE     t.acd_ed = p_ed_id
                     AND (   e.ed_tp IS NULL
                          OR e.ed_tp != 'RETDN'
                          OR e.ed_tp = 'RETDN' AND t.acd_op NOT IN (10, 11))
                     --AND t.acd_op = 6 --125
                     AND t.history_status = 'A'
            ORDER BY t.acd_start_dt;

        OPEN pay2_cur FOR
              SELECT t.*,
                     pt.npt_code,
                     pt.npt_name,
                     d.pd_num
                FROM ac_detail t
                     JOIN v_errand e ON (e.ed_id = t.acd_ed)
                     LEFT JOIN uss_ndi.v_ndi_payment_type pt
                         ON (pt.npt_id = t.acd_npt)
                     LEFT JOIN pc_decision d ON (d.pd_id = t.acd_pd)
               WHERE     t.acd_ed = p_ed_id
                     AND e.ed_tp = 'RETDN'
                     AND t.acd_op IN (10)
                     --AND t.acd_op = 6 --125
                     AND t.history_status = 'A'
            ORDER BY t.acd_start_dt;

        OPEN pay3_cur FOR
              SELECT t.*,
                     pt.npt_code,
                     pt.npt_name,
                     d.pd_num
                FROM ac_detail t
                     JOIN v_errand e ON (e.ed_id = t.acd_ed)
                     LEFT JOIN uss_ndi.v_ndi_payment_type pt
                         ON (pt.npt_id = t.acd_npt)
                     LEFT JOIN pc_decision d ON (d.pd_id = t.acd_pd)
               WHERE     t.acd_ed = p_ed_id
                     AND e.ed_tp = 'RETDN'
                     AND t.acd_op IN (11)
                     --AND t.acd_op = 6 --125
                     AND t.history_status = 'A'
            ORDER BY t.acd_start_dt;
    END;

    -- #87514: збереження способу виплати по дорученню
    PROCEDURE save_errand_card (p_ed_id          IN NUMBER,
                                p_ED_PAY_TP      IN VARCHAR2,
                                p_ED_INDEX       IN VARCHAR2,
                                p_ED_KAOT        IN NUMBER,
                                p_ED_NB          IN NUMBER,
                                p_ED_ACCOUNT     IN VARCHAR2,
                                p_ED_STREET      IN VARCHAR2,
                                p_ED_NS          IN NUMBER,
                                p_ED_BUILDING    IN VARCHAR2,
                                p_ED_BLOCK       IN VARCHAR2,
                                p_ED_APARTMENT   IN VARCHAR2,
                                p_ED_ND          IN ERRAND.ED_ND%TYPE,
                                p_ED_PAY_DT      IN ERRAND.ED_PAY_DT%TYPE)
    IS
        l_st   VARCHAR2 (10);
    BEGIN
        SELECT MAX (t.ed_st)
          INTO l_st
          FROM errand t
         WHERE t.ed_id = p_ed_id;

        IF (l_st IS NULL OR l_st != 'E')
        THEN
            raise_application_error (
                -20000,
                'Статус доручення не дозволяє редагування!');
        END IF;

        UPDATE ERRAND
           SET ED_PAY_TP = p_ED_PAY_TP,
               ED_INDEX = p_ED_INDEX,
               ED_KAOT = p_ED_KAOT,
               ED_NB = p_ED_NB,
               ED_ACCOUNT = p_ED_ACCOUNT,
               ED_STREET = p_ED_STREET,
               ED_NS = p_ED_NS,
               ED_BUILDING = p_ED_BUILDING,
               ED_BLOCK = p_ED_BLOCK,
               ED_APARTMENT = p_ED_APARTMENT,
               ED_ND = p_ED_ND,
               ED_PAY_DT = p_ED_PAY_DT
         WHERE ED_ID = p_ED_ID;
    END;

    -- #87514: Розрахувати доручення
    PROCEDURE recalc_errand_card (p_ed_id IN NUMBER)
    IS
    BEGIN
        API$ERRAND.errand_recalc (p_ed_id);
    END;

    -- #87514: Затвердити доручення
    PROCEDURE approve_errand_card (p_ed_id IN NUMBER)
    IS
    BEGIN
        API$ERRAND.errand_approve (p_ed_id);
    END;

    -- #87514: Відхилити доручення
    PROCEDURE reject_errand_card (p_ed_id    IN NUMBER,
                                  p_ed_rnp   IN errand.ed_rnp%TYPE)
    IS
    BEGIN
        API$ERRAND.errand_reject (p_ed_id, p_ed_rnp);
    END;

    --Повернути доручення
    PROCEDURE return_errand_card (p_ed_id IN NUMBER, p_reason IN VARCHAR2)
    IS
    BEGIN
        API$ERRAND.errand_return (p_ed_id, p_reason);
    END;

    -- #87514: Лог доручення
    PROCEDURE get_errand_log (p_ed_id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
              SELECT t.edl_id                                                   AS log_id,
                     t.edl_ed                                                   AS log_obj,
                     t.edl_tp                                                   AS log_tp,
                     st.dic_name                                                AS log_st_name,
                     sto.dic_name                                               AS log_st_old_name,
                     hs_dt                                                      AS log_hs_dt,
                     tools.GetUserLogin (hs_wu)                                 AS log_hs_author,
                     uss_ndi.RDM$MSG_TEMPLATE.getmessagetext (t.edl_message)    AS log_message
                FROM ed_log t
                     LEFT JOIN uss_ndi.v_ddn_ed_st st
                         ON (st.dic_value = t.edl_st)
                     LEFT JOIN uss_ndi.v_ddn_ed_st sto
                         ON (sto.dic_value = t.edl_st_old)
                     LEFT JOIN v_histsession ON (hs_id = t.edl_hs)
               WHERE t.edl_ed = p_ed_id
            ORDER BY hs_dt;
    END;
BEGIN
    NULL;
END DNET$ERRAND;
/