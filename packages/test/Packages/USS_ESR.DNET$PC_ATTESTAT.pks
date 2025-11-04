/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$PC_ATTESTAT
IS
    -- Author  : BOGDAN
    -- Created : 28.10.2022 13:59:34
    -- Purpose : Реєстр запитів на передачу справ

    -- #81051
    PROCEDURE GET_JOURNAL (
        p_pca_doc_num            IN     pc_attestat.pca_doc_num%TYPE,
        p_pc_num                 IN     personalcase.pc_num%TYPE,
        p_ap_num                 IN     appeal.ap_num%TYPE,
        p_pca_doc_dt_from        IN     pc_attestat.pca_doc_dt%TYPE,
        p_pca_doc_dt_to          IN     pc_attestat.pca_doc_dt%TYPE,
        p_pca_ins_dt_from        IN     pc_attestat.pca_doc_dt%TYPE,
        p_pca_ins_dt_to          IN     pc_attestat.pca_doc_dt%TYPE,
        p_pca_Decision_dt_from   IN     pc_attestat.pca_doc_dt%TYPE,
        p_pca_Decision_dt_to     IN     pc_attestat.pca_doc_dt%TYPE,
        p_org_src                IN     Pc_Attestat.Pca_Org_Src%TYPE,
        p_org_dest               IN     Pc_Attestat.Pca_Org_Dest%TYPE,
        p_pca_tp                 IN     pc_attestat.pca_tp%TYPE,
        p_pca_id                 IN     pc_attestat.pca_id%TYPE,
        p_pca_ap_reason          IN     pc_attestat.pca_ap_reason%TYPE,
        -- #101793
        p_app_ln                 IN     VARCHAR2,
        p_app_fn                 IN     VARCHAR2,
        p_app_mn                 IN     VARCHAR2,
        p_numident               IN     VARCHAR2,
        p_scd_ser_num            IN     VARCHAR2,
        res_cur                     OUT SYS_REFCURSOR);

    -- #81051: Лог
    PROCEDURE GET_LOG (P_PCA_ID IN NUMBER, res_cur OUT SYS_REFCURSOR);

    -- #81051: Передати
    PROCEDURE pd_transfer (p_pca_id IN NUMBER);

    -- #81051: Відмовити
    PROCEDURE reject_transfer (p_pca_id IN NUMBER, p_reason IN VARCHAR2);

    -- #81051: Відмінити
    PROCEDURE cancel_transfer (p_pca_id IN NUMBER);
END DNET$PC_ATTESTAT;
/


GRANT EXECUTE ON USS_ESR.DNET$PC_ATTESTAT TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$PC_ATTESTAT TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$PC_ATTESTAT
IS
    /*№ запиту - pca_doc_num - за like;
      № справи - pca_pc - за "=";
      № звернення - pca_ca_reason - за "=";
      Запит з - pca_doc_dt;
      по - pca_doc_dt;
      Створено з - pca_hs_ins -> hs_dt;
      по - pca_hs_ins -> hs_dt;
      Дозвіл/відмова з - pca_hs_decision -> hs_dt;
      по - pca_hs_decision -> hs_dt;
      Запити до - pca_org_src - Випадалка з органів (ОСЗН + 50000) - по "=";
      Запити від - pca_org_dest - Випадалка з органів (ОСЗН + 50000) - по "=";*/

    -- #81051: Журнал
    PROCEDURE GET_JOURNAL (
        p_pca_doc_num            IN     pc_attestat.pca_doc_num%TYPE,
        p_pc_num                 IN     personalcase.pc_num%TYPE,
        p_ap_num                 IN     appeal.ap_num%TYPE,
        p_pca_doc_dt_from        IN     pc_attestat.pca_doc_dt%TYPE,
        p_pca_doc_dt_to          IN     pc_attestat.pca_doc_dt%TYPE,
        p_pca_ins_dt_from        IN     pc_attestat.pca_doc_dt%TYPE,
        p_pca_ins_dt_to          IN     pc_attestat.pca_doc_dt%TYPE,
        p_pca_Decision_dt_from   IN     pc_attestat.pca_doc_dt%TYPE,
        p_pca_Decision_dt_to     IN     pc_attestat.pca_doc_dt%TYPE,
        p_org_src                IN     Pc_Attestat.Pca_Org_Src%TYPE,
        p_org_dest               IN     Pc_Attestat.Pca_Org_Dest%TYPE,
        p_pca_tp                 IN     pc_attestat.pca_tp%TYPE,
        p_pca_id                 IN     pc_attestat.pca_id%TYPE,
        p_pca_ap_reason          IN     pc_attestat.pca_ap_reason%TYPE,
        -- #101793
        p_app_ln                 IN     VARCHAR2,
        p_app_fn                 IN     VARCHAR2,
        p_app_mn                 IN     VARCHAR2,
        p_numident               IN     VARCHAR2,
        p_scd_ser_num            IN     VARCHAR2,
        res_cur                     OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT t.*,
                   c.pc_num,
                   ap.ap_num,
                   ap.ap_tp
                       AS pca_ap_reason_tp,
                   uss_person.api$sc_tools.GET_PIB (c.pc_sc)
                       AS pib,
                   ihs.hs_dt
                       AS pca_hs_ins_dt,
                   tools.GetUserPib (ihs.hs_wu)
                       AS pca_hs_ins_pib,
                   src.org_id || ' - ' || src.org_name
                       AS pca_org_src_name,
                   dest.org_id || ' - ' || dest.org_name
                       AS pca_org_dest_name,
                   src.org_acc_org
                       AS src_acc_org,
                   dest.org_acc_org
                       AS dest_acc_org,
                   (SELECT MAX (dic_name)
                      FROM uss_ndi.v_ddn_pca_tp z
                     WHERE z.dic_value = t.pca_tp)
                       AS pca_tp_name,
                   (SELECT MAX (nst_name)
                      FROM uss_ndi.v_ndi_service_type z
                     WHERE z.nst_id = pa.pa_nst)
                       AS nst_name,
                   CASE
                       WHEN (SELECT COUNT (*)
                               FROM pc_state_alimony a
                              WHERE a.ps_pc = c.pc_id AND a.ps_st = 'R') > 0
                       THEN
                           1
                       ELSE
                           0
                   END
                       AS Alert_Transfer,
                   (SELECT MAX (dpp_Tax_Code)
                      FROM pc_state_alimony  a
                           JOIN uss_ndi.v_ndi_pay_person pp
                               ON (pp.dpp_id = a.ps_dpp)
                     WHERE a.ps_pc = c.pc_id AND a.ps_st = 'R')
                       AS dpp_Tax_Code,
                   pa.pa_num
              FROM v_pc_attestat  t
                   --JOIN v_personalcase c ON (c.pc_id = t.pca_pc)
                   --JOIN v_appeal ap ON (ap.ap_id = t.pca_ap_reason)
                   JOIN personalcase c ON (c.pc_id = t.pca_pc)
                   JOIN appeal ap ON (ap.ap_id = t.pca_ap_reason)
                   LEFT JOIN histsession ihs ON (ihs.hs_id = t.pca_hs_ins)
                   LEFT JOIN histsession dhs
                       ON (dhs.hs_id = t.pca_hs_decision)
                   JOIN v_opfu src ON (src.org_id = t.pca_org_src)
                   JOIN v_opfu dest ON (dest.org_id = t.pca_org_dest)
                   LEFT JOIN v_pc_account pa ON (pa.pa_id = t.pca_pa)
             WHERE     1 = 1
                   AND (   p_pca_doc_num IS NULL
                        OR t.pca_doc_num LIKE p_pca_doc_num || '%')
                   AND (p_pc_num IS NULL OR c.pc_num = p_pc_num)
                   AND (p_ap_num IS NULL OR ap.ap_num = p_ap_num)
                   AND t.pca_doc_dt BETWEEN COALESCE (
                                                p_pca_doc_dt_from,
                                                TO_DATE ('01.01.1900',
                                                         'DD.MM.YYYY'))
                                        AND COALESCE (
                                                p_pca_doc_dt_to,
                                                TO_DATE ('01.01.9999',
                                                         'DD.MM.YYYY'))
                   AND ihs.hs_dt BETWEEN COALESCE (
                                             p_pca_ins_dt_from,
                                             TO_DATE ('01.01.1900',
                                                      'DD.MM.YYYY'))
                                     AND COALESCE (
                                             p_pca_ins_dt_to,
                                             TO_DATE ('01.01.9999',
                                                      'DD.MM.YYYY'))
                   AND (   p_pca_Decision_dt_from IS NULL
                        OR dhs.hs_dt >= p_pca_Decision_dt_from)
                   AND (   p_pca_Decision_dt_to IS NULL
                        OR dhs.hs_dt <= p_pca_Decision_dt_to)
                   AND (p_org_src IS NULL OR t.pca_org_src = p_org_src)
                   AND (p_org_dest IS NULL OR t.pca_org_dest = p_org_dest)
                   AND (p_pca_tp IS NULL OR t.pca_tp = p_pca_tp)
                   AND (p_pca_id IS NULL OR t.pca_id = p_pca_id)
                   AND (   p_pca_ap_reason IS NULL
                        OR t.pca_ap_reason = p_pca_ap_reason)
                   AND EXISTS
                           (SELECT u_org
                              FROM tmp_org
                             WHERE    u_org = t.pca_org_src
                                   OR u_org = t.pca_org_dest)
                   AND (   p_numident IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM uss_person.v_sc_document sd
                                 WHERE     sd.scd_ndt = 5
                                       AND c.pc_sc = sd.scd_sc
                                       AND sd.scd_st IN ('A', '1')
                                       AND sd.scd_number = p_numident))
                   AND (   p_scd_ser_num IS NULL
                        OR EXISTS
                               (SELECT 1
                                  FROM v_ap_person               zz,
                                       uss_person.v_sc_document  sd
                                 WHERE     c.pc_sc = sd.scd_sc
                                       AND sd.scd_sc = zz.app_sc
                                       AND c.pc_sc = zz.app_sc
                                       AND zz.app_ap = ap.ap_id
                                       AND sd.scd_ndt IN (6, 7)
                                       AND sd.scd_st IN ('A', '1')
                                       AND (sd.scd_seria || sd.scd_number =
                                            REPLACE (P_SCD_SER_NUM, ' ', ''))))
                   AND (       P_APP_LN IS NULL
                           AND P_App_Fn IS NULL
                           AND P_App_Mn IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM v_ap_person  zz
                                       JOIN uss_person.v_socialcard zs
                                           ON (zs.sc_id = zz.app_sc)
                                       JOIN uss_person.v_sc_change zch
                                           ON (zch.scc_id = zs.sc_scc)
                                       JOIN uss_person.v_sc_identity zi
                                           ON (zi.sci_id = zch.scc_sci)
                                 WHERE     zz.app_ap = ap.ap_id
                                       AND zz.app_tp =
                                           CASE
                                               WHEN ap.ap_tp IN ('U', 'A')
                                               THEN
                                                   'O'
                                               ELSE
                                                   'Z'
                                           END
                                       AND (   p_app_ln IS NULL
                                            OR UPPER (zi.sci_ln) LIKE
                                                      UPPER (TRIM (p_app_ln))
                                                   || '%')
                                       AND (   p_app_fn IS NULL
                                            OR UPPER (zi.sci_fn) LIKE
                                                      UPPER (TRIM (p_app_fn))
                                                   || '%')
                                       AND (   p_app_mn IS NULL
                                            OR UPPER (zi.sci_mn) LIKE
                                                      UPPER (TRIM (p_app_mn))
                                                   || '%')));
    END;

    -- #81051: Лог
    PROCEDURE GET_LOG (P_PCA_ID IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT t.pcal_id,
                   t.pcal_st,
                   t.pcal_st_old,
                   t.pcal_tp,
                   uss_ndi.RDM$MSG_TEMPLATE.getmessagetext (t.pcal_message)
                       AS pcal_message,
                   hs.hs_dt
                       AS pcal_hs_dt,
                   tools.GetUserPib (hs.hs_wu)
                       AS pcal_hs_pib,
                   st.DIC_NAME
                       AS pcal_st_name,
                   sto.DIC_NAME
                       AS pcal_st_old_name,
                   NULL
                       AS pcal_tp_name
              FROM v_pca_log  t
                   LEFT JOIN histsession hs ON (hs.hs_id = t.pcal_hs)
                   LEFT JOIN uss_ndi.v_ddn_pca_st st
                       ON (st.DIC_VALUE = t.pcal_st)
                   LEFT JOIN uss_ndi.v_ddn_pca_st sto
                       ON (sto.DIC_VALUE = t.pcal_st_old)
             WHERE t.pcal_pca = p_pca_id;
    END;


    -- #81051: Передати
    PROCEDURE pd_transfer (p_pca_id IN NUMBER)
    IS
    BEGIN
        api$pc_attestat.APPROVE_Transmission (p_pca_id);
    END;

    -- #81051: Відмовити
    PROCEDURE reject_transfer (p_pca_id IN NUMBER, p_reason IN VARCHAR2)
    IS
    BEGIN
        api$pc_attestat.REJECT_Transmission (p_pca_id, p_reason);
    END;

    -- #81051: Відмінити
    PROCEDURE cancel_transfer (p_pca_id IN NUMBER)
    IS
    BEGIN
        api$pc_attestat.REJECT_Transmission (p_pca_id);
    END;
BEGIN
    NULL;
END DNET$PC_ATTESTAT;
/