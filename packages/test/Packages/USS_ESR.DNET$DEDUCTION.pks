/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$DEDUCTION
IS
    -- Author  : VANO
    -- Created : 08.12.2021 16:08:12
    -- Purpose : Функції взаємодії сайту з базою по відрахуванням

    Package_Name   VARCHAR2 (20) := 'DNET$DEDUCTION';

    TYPE r_detail IS RECORD
    (
        Acd_Id          ac_detail.acd_id%TYPE,
        Acd_Start_Dt    ac_detail.Acd_Start_Dt%TYPE,
        Acd_Stop_Dt     ac_detail.Acd_Stop_Dt%TYPE,
        Acd_Sum         ac_detail.Acd_Sum%TYPE,
        Acd_Pd          ac_detail.acd_pd%TYPE,
        Acd_Npt         ac_detail.acd_npt%TYPE
    );

    TYPE t_detail IS TABLE OF r_detail;


    -- #79263: Реєстр відрахувань
    PROCEDURE GET_DEDUCTIONS (p_ap_num               IN     VARCHAR2,
                              p_Dn_In_Doc_Num        IN     VARCHAR2,
                              p_dn_ndn               IN     NUMBER,
                              p_dn_st                IN     VARCHAR2,
                              p_dn_in_doc_dt_start   IN     DATE,
                              p_dn_in_doc_dt_stop    IN     DATE,
                              p_pc_num               IN     VARCHAR2,
                              p_dn_start_dt_start    IN     DATE,
                              p_dn_start_dt_stop     IN     DATE,
                              p_nst_id               IN     NUMBER,
                              p_dpp_id               IN     NUMBER,
                              res_cur                   OUT SYS_REFCURSOR);

    -- #79263: Картка відрахувань
    PROCEDURE GET_DEDACTION_CARD (p_dn_id      IN     NUMBER,
                                  dn_cur          OUT SYS_REFCURSOR,
                                  dnd_cur         OUT SYS_REFCURSOR,
                                  pers_cur        OUT SYS_REFCURSOR,
                                  charge_cur      OUT SYS_REFCURSOR);

    -- #92271: Зберегти рішення щодо переплати
    PROCEDURE save_deduction (
        p_dn_id           IN deduction.dn_id%TYPE,
        p_dn_pa           IN deduction.dn_pa%TYPE,
        p_dn_params_src   IN deduction.dn_params_src%TYPE);

    PROCEDURE init_deduction_by_appeal (p_ap_id            appeal.ap_id%TYPE,
                                        p_ap_curr_st   OUT appeal.ap_st%TYPE,
                                        p_messages     OUT SYS_REFCURSOR);

    PROCEDURE approve_deduction (p_dn_id deduction.dn_id%TYPE);

    PROCEDURE reject_deduction (p_dn_id       deduction.dn_id%TYPE,
                                p_reason   IN VARCHAR2 := NULL);

    -----------------------------------------------------------------
    ----------------- Ведення рішень щодо переплат ------------------

    -- #79626: Черга звернень на обробку
    PROCEDURE GET_OVERPAY_QUEUE (p_start_dt   IN     DATE,
                                 p_stop_dt    IN     DATE,
                                 p_org_id     IN     NUMBER,
                                 p_aps_nst    IN     NUMBER,
                                 res_cur         OUT SYS_REFCURSOR);

    -- #79626: Інформація по зверненю в черзі звернень на обробку
    PROCEDURE GET_OVERPAY_QUEUE_INFO (p_ap_id   IN     NUMBER,
                                      res_cur      OUT SYS_REFCURSOR);


    -- #79626: Взяття звернення на обробку
    PROCEDURE process_deduction_by_appeal (
        p_ap_id       appeal.ap_id%TYPE,
        p_dn_id   OUT deduction.dn_id%TYPE);

    -- #79626: Реєстр переплат
    PROCEDURE GET_OVERPAY_LIST (p_ap_num               IN     VARCHAR2,
                                p_Dn_In_Doc_Num        IN     VARCHAR2,
                                p_dn_ndn               IN     NUMBER,
                                p_dn_st                IN     VARCHAR2,
                                p_dn_in_doc_dt_start   IN     DATE,
                                p_dn_in_doc_dt_stop    IN     DATE,
                                p_pc_num               IN     VARCHAR2,
                                p_dn_start_dt_start    IN     DATE,
                                p_dn_start_dt_stop     IN     DATE,
                                p_dn_nst               IN     NUMBER,
                                res_cur                   OUT SYS_REFCURSOR);

    -- #79263: Картка переплат
    PROCEDURE GET_OVERPAY_CARD (p_dn_id      IN     NUMBER,
                                main_cur        OUT SYS_REFCURSOR,
                                det_cur         OUT SYS_REFCURSOR,
                                charge_cur      OUT SYS_REFCURSOR,
                                cond_cur        OUT SYS_REFCURSOR);

    -- #83984
    PROCEDURE create_new_overpay (p_pc_id           IN NUMBER,
                                  p_nst_id          IN NUMBER,
                                  p_dn_debt_total   IN NUMBER);

    -- #83984
    PROCEDURE CREATE_OVERPAY_DETAILS (p_dn_id IN NUMBER, p_xml IN CLOB);

    -- #79263: збереження картки переплат
    PROCEDURE save_overpay_card (
        p_dn_id               IN NUMBER,
        p_dn_reason           IN VARCHAR2,
        p_dn_start_dt         IN DATE,
        p_dn_debt_limit_prc   IN deduction.dn_debt_limit_prc%TYPE,
        p_dn_pa               IN deduction.dn_pa%TYPE);

    -- #79263: Друк
    PROCEDURE registry_report (p_rt_id    IN     NUMBER,
                               p_ids      IN     VARCHAR2,
                               p_jbr_id      OUT NUMBER);


    --Відміна рішення щодо переплати
    PROCEDURE cancel_deduction (p_dn_id       deduction.dn_id%TYPE,
                                p_reason   IN VARCHAR2 := NULL);

    -- #92271: Закрити рішення щодо переплати
    PROCEDURE close_deduction (p_dn_id deduction.dn_id%TYPE, p_close_dt DATE);

    -- #85173
    PROCEDURE get_overpay_decisions (p_dn_id   IN     NUMBER,
                                     res_cur      OUT SYS_REFCURSOR);


    -- #91250 Поновити
    PROCEDURE renew_decision (p_dn_id IN NUMBER, p_renew_dt IN DATE);

    -- Повернути зайво стягнене
    PROCEDURE init_errand_by_deduction (p_ids      IN     VARCHAR2,
                                        p_reason   IN     VARCHAR2,
                                        p_ed_id       OUT NUMBER);

    PROCEDURE manipulate_with_acd_sa (p_acd_id   ac_detail.acd_id%TYPE,
                                      p_action   INTEGER); --1=Встановити ознаку в T, 2=Встановити ознаку в F
END DNET$DEDUCTION;
/


GRANT EXECUTE ON USS_ESR.DNET$DEDUCTION TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$DEDUCTION TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:29 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$DEDUCTION
IS
    -- #79263: Реєстр відрахувань
    PROCEDURE GET_DEDUCTIONS (p_ap_num               IN     VARCHAR2,
                              p_Dn_In_Doc_Num        IN     VARCHAR2,
                              p_dn_ndn               IN     NUMBER,
                              p_dn_st                IN     VARCHAR2,
                              p_dn_in_doc_dt_start   IN     DATE,
                              p_dn_in_doc_dt_stop    IN     DATE,
                              p_pc_num               IN     VARCHAR2,
                              p_dn_start_dt_start    IN     DATE,
                              p_dn_start_dt_stop     IN     DATE,
                              p_nst_id               IN     NUMBER,
                              p_dpp_id               IN     NUMBER,
                              res_cur                   OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT dn.*,
                   ddu.dic_sname                                  AS dn_unit_name,
                   h.hs_dt                                        AS dn_hs_dt,
                   dpp.dpp_name                                   AS dn_dpp_name,
                   dds.dic_sname                                  AS dn_st_name,
                   ndn.ndn_name                                   AS dn_ndn_name,
                   pc.pc_num,
                   ap.ap_num,
                   st.nst_name,
                   uss_person.api$sc_tools.GET_PIB (pc.pc_sc)     AS ap_pib
              FROM v_deduction_by_pc           dn,
                   uss_ndi.v_ddn_dn_unit       ddu,
                   histsession                 h,
                   uss_ndi.v_ndi_pay_person    dpp,
                   uss_ndi.v_ddn_dn_st         dds,
                   uss_ndi.v_ndi_deduction     ndn,
                   appeal                      ap,
                   personalcase                pc,
                   pc_account                  pa,
                   uss_ndi.v_ndi_service_type  st
             WHERE     dn.dn_unit = ddu.dic_value
                   AND dn.dn_hs_return = h.hs_id(+)
                   AND dn.dn_dpp = dpp.dpp_id(+)
                   AND dn.dn_st = dds.dic_value(+)
                   AND dn.dn_ndn = ndn.ndn_id(+)
                   AND dn.dn_pc = pc.pc_id(+)
                   AND dn.dn_ap = ap.ap_id(+)
                   AND dn.dn_pa = pa.pa_id(+)
                   AND pa.pa_nst = st.nst_id(+)
                   AND ROWNUM <= 502
                   AND (dn_tp = 'D' OR dn_tp = 'R' AND dn_st = 'R')
                   AND (p_ap_num IS NULL OR ap.ap_num LIKE p_ap_num || '%')
                   AND (p_pc_num IS NULL OR pc.pc_num LIKE p_pc_num || '%')
                   AND (   p_Dn_In_Doc_Num IS NULL
                        OR dn.dn_in_doc_num LIKE p_Dn_In_Doc_Num || '%')
                   AND (p_dn_ndn IS NULL OR dn.dn_ndn = p_dn_ndn)
                   AND (p_dn_st IS NULL OR dn.dn_st = p_dn_st)
                   AND (p_nst_id IS NULL OR st.nst_id = p_nst_id)
                   AND (p_dpp_id IS NULL OR dn.dn_dpp = p_dpp_id)
                   AND (       p_dn_in_doc_dt_start IS NULL
                           AND p_dn_in_doc_dt_stop IS NULL
                        OR     p_dn_in_doc_dt_start IS NULL
                           AND p_dn_in_doc_dt_stop IS NOT NULL
                           AND dn.dn_in_doc_dt <= p_dn_in_doc_dt_stop
                        OR     p_dn_in_doc_dt_start IS NULL
                           AND p_dn_in_doc_dt_stop IS NULL
                           AND dn.dn_in_doc_dt >= p_dn_in_doc_dt_start
                        OR     p_dn_in_doc_dt_start IS NOT NULL
                           AND p_dn_in_doc_dt_stop IS NOT NULL
                           AND dn.dn_in_doc_dt BETWEEN p_dn_in_doc_dt_start
                                                   AND p_dn_in_doc_dt_stop)
                   AND (       p_dn_start_dt_start IS NULL
                           AND p_dn_start_dt_stop IS NULL
                        OR     p_dn_start_dt_start IS NULL
                           AND p_dn_start_dt_stop IS NOT NULL
                           AND dn.dn_start_dt <= p_dn_start_dt_stop
                        OR     p_dn_start_dt_start IS NULL
                           AND p_dn_start_dt_stop IS NULL
                           AND dn.dn_start_dt >= p_dn_start_dt_start
                        OR     p_dn_start_dt_start IS NOT NULL
                           AND p_dn_start_dt_stop IS NOT NULL
                           AND dn.dn_start_dt BETWEEN p_dn_start_dt_start
                                                  AND p_dn_start_dt_stop);
    END;

    -- #79263: Картка відрахувань
    PROCEDURE GET_DEDACTION_CARD (p_dn_id      IN     NUMBER,
                                  dn_cur          OUT SYS_REFCURSOR,
                                  dnd_cur         OUT SYS_REFCURSOR,
                                  pers_cur        OUT SYS_REFCURSOR,
                                  charge_cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN dn_cur FOR
            SELECT dn.*,
                   ddu.dic_sname                        AS dn_unit_name,
                   h.hs_dt                              AS dn_hs_dt,
                   dpp.dpp_name                         AS dn_dpp_name,
                   dds.dic_sname                        AS dn_st_name,
                   ndn.ndn_name                         AS dn_ndn_name,
                   ndn.ndn_calc_step,
                   pc.pc_num,
                   ap.ap_num,
                   pa.pa_num,
                   (SELECT COUNT (*)
                      FROM ac_detail
                     WHERE     acd_dn = p_dn_id
                           AND acd_op IN (6, 30)
                           AND history_Status = 'A')    AS dn_can_change_pa,
                   p.org_acc_org
              FROM deduction                 dn,
                   uss_ndi.v_ddn_dn_unit     ddu,
                   histsession               h,
                   uss_ndi.v_ndi_pay_person  dpp,
                   uss_ndi.v_ddn_dn_st       dds,
                   uss_ndi.v_ndi_deduction   ndn,
                   appeal                    ap,
                   personalcase              pc,
                   v_pc_account              pa,
                   v_opfu                    p
             WHERE     dn.dn_unit = ddu.dic_value
                   AND dn.dn_hs_return = h.hs_id(+)
                   AND dn.dn_dpp = dpp.dpp_id(+)
                   AND dn.dn_st = dds.dic_value(+)
                   AND dn.dn_ndn = ndn.ndn_id(+)
                   AND dn.dn_pc = pc.pc_id(+)
                   AND dn.dn_ap = ap.ap_id(+)
                   AND dn.dn_pa = pa.pa_id(+)
                   AND p.org_id = dn.com_org
                   AND dn.dn_id = p_dn_id;

        OPEN dnd_cur FOR
            SELECT dnd.*,
                   --Одиниця
                   ddu.dic_sname                      AS dnd_tp_name,
                   --Банк стягувача/отримувача
                   dppa.dppa_nb                       AS dnd_dppa_nb,
                   nb.nb_mfo                          AS dnd_dppa_nb_mfo,
                   nb.nb_sname                        AS dnd_dppa_nb_name,
                   nb.nb_mfo || ' ' || nb.nb_sname    AS dnd_dppa_nb_mfoname,
                   --Рахунок стягувача/отримувача
                   dppa.dppa_account                  AS dnd_dppa_account,
                   (SELECT dic_sname
                      FROM uss_ndi.v_ddn_dn_unit
                     WHERE dic_value = dnd_nl_tp)     AS dnd_nl_tp_name
              FROM v_dn_detail                   dnd,
                   uss_ndi.v_ddn_dn_unit         ddu,
                   uss_ndi.v_ndi_pay_person_acc  dppa,
                   uss_ndi.v_ndi_bank            nb,
                   v_deduction_by_pc             dn
             WHERE     dnd.dnd_tp = ddu.dic_value(+)
                   AND dnd.dnd_dppa = dppa.dppa_id(+)
                   AND dppa.dppa_nb = nb.nb_id(+)
                   AND dnd_dn = dn_id
                   AND dnd.history_status = 'A'
                   AND dn_id = p_dn_id;

        OPEN pers_cur FOR
            SELECT t.*,
                   uss_person.api$sc_tools.GET_PIB (t.dnp_sc)
                       AS dnp_pib,
                   (SELECT MAX (z.DIC_NAME)
                      FROM uss_ndi.v_ddn_inv_state z
                     WHERE z.DIC_VALUE = t.dnp_inv_state)
                       AS dnp_inv_state_name,
                   (SELECT dic_sname
                      FROM uss_ndi.v_ddn_dn_unit
                     WHERE dic_value = dnp_tp)
                       AS dnp_tp_name,
                   (SELECT dic_sname
                      FROM uss_ndi.v_ddn_dn_unit
                     WHERE dic_value = dnp_nl_tp)
                       AS dnp_nl_tp_name
              FROM dn_person t
             WHERE t.history_status = 'A' AND t.dnp_dn = p_dn_id;


        OPEN charge_cur FOR
              SELECT t.acd_id,
                     t.acd_ac,
                     t.acd_op,
                     t.acd_npt,
                     t.acd_start_dt,
                     t.acd_stop_dt,
                     t.acd_sum,
                     t.acd_month_sum,
                     t.acd_delta_recalc,
                     t.acd_delta_pay,
                     t.acd_dn,
                     t.acd_pd,
                     t.acd_ac_start_dt,
                     t.acd_ac_stop_dt,
                     t.acd_is_indexed,
                     t.acd_st,
                     t.history_status,
                     t.acd_payed_sum,
                     t.acd_prsd,
                     t.acd_imp_pr_num,
                     t.acd_can_use_in_pr,
                     t.acd_rrl,
                     t.acd_ed,
                     t.acd_prsd_sa,
                     --t.acd_can_use_in_sa,
                     pt.npt_code,
                     pt.npt_name,
                     ed_num,     --№ документа повернення зайво стягнених сумм
                     CASE WHEN acd_ed IS NOT NULL THEN acd_sum ELSE 0.00 END
                         AS acd_returned_sum,                --сума повернення
                     NVL (acd_can_use_in_sa, 'T')
                         AS acd_can_use_in_sa,
                     CASE
                         WHEN     ndn_calc_step = 'F'
                              AND acd_prsd_sa IS NULL
                              AND acd_can_use_in_sa = 'F'
                         THEN
                             1
                         WHEN     ndn_calc_step = 'F'
                              AND acd_prsd_sa IS NULL
                              AND (   acd_can_use_in_sa = 'T'
                                   OR acd_can_use_in_sa IS NULL)
                         THEN
                             2
                     END
                         possible_action
                FROM ac_detail t
                     LEFT JOIN uss_ndi.v_ndi_payment_type pt
                         ON (pt.npt_id = t.acd_npt)
                     LEFT JOIN errand ed ON (acd_ed = ed_id)
                     LEFT JOIN deduction d ON (acd_dn = dn_id)
                     LEFT JOIN uss_ndi.v_ndi_deduction ndn ON (dn_ndn = ndn_id)
               WHERE     t.acd_dn = p_dn_id
                     AND t.acd_op IN (123, 124                /*, 30, 31, 32*/
                                              )
                     AND t.history_status = 'A'
            ORDER BY t.acd_start_dt;
    END;

    -- #92271: Зберегти рішення щодо переплати
    PROCEDURE save_deduction (
        p_dn_id           IN deduction.dn_id%TYPE,
        p_dn_pa           IN deduction.dn_pa%TYPE,
        p_dn_params_src   IN deduction.dn_params_src%TYPE)
    IS
        l_cnt   NUMBER;
    BEGIN
        tools.WriteMsg ('DNET$DEDUCTION.' || $$PLSQL_UNIT);

        SELECT COUNT (*)
          INTO l_cnt
          FROM deduction t
         WHERE t.dn_id = p_dn_id --AND t.dn_tp = 'D'
                                 AND dn_ndn <> 89 AND t.dn_st IN ('E');

        IF (l_cnt = 0)
        THEN
            raise_application_error (
                -20000,
                'Редагувати рішення щодо переплати у вказаному статусі неможливо!');
        END IF;

        UPDATE deduction t
           SET t.dn_pa = p_dn_pa, t.dn_params_src = p_dn_params_src
         WHERE dn_id = p_dn_id;
    END;


    PROCEDURE init_deduction_by_appeal (p_ap_id            appeal.ap_id%TYPE,
                                        p_ap_curr_st   OUT appeal.ap_st%TYPE,
                                        p_messages     OUT SYS_REFCURSOR)
    IS
        l_st   appeal.ap_st%TYPE;
        l_tp   appeal.ap_tp%TYPE;
    BEGIN
        tools.WriteMsg ('DNET$DEDUCTION.' || $$PLSQL_UNIT);

        SELECT ap_tp
          INTO l_tp
          FROM v_appeal
         WHERE ap_id = p_ap_id AND ap_st = 'O';

        IF l_tp = 'A'
        THEN
            API$DEDUCTION.init_deduction_by_appeals (1, p_ap_id, p_messages);
        ELSIF l_tp = 'O'
        THEN
            API$PD_INIT.init_pc_decision_by_appeals (1, p_ap_id, p_messages);
        ELSIF l_tp = 'U'
        THEN
            API$PC_STATE_ALIMONY.init_pc_state_alimony_by_appeals (
                1,
                p_ap_id,
                p_messages);
        ELSE
            OPEN p_messages FOR SELECT * FROM DUAL;
        END IF;

        SELECT ap_st
          INTO p_ap_curr_st
          FROM v_appeal
         WHERE ap_id = p_ap_id                            /* AND ap_st = 'O'*/
                              ;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                'Не знайдено звернення - відрахування та держутримання ініціалізуються по зверненням з статусом "Очікується відповідь з ОСЗН"!');
    END;

    PROCEDURE approve_deduction (p_dn_id deduction.dn_id%TYPE)
    IS
    BEGIN
        tools.WriteMsg ('DNET$DEDUCTION.' || $$PLSQL_UNIT);

        API$DEDUCTION.approve_deduction (p_dn_id);
    END;

    PROCEDURE reject_deduction (p_dn_id       deduction.dn_id%TYPE,
                                p_reason   IN VARCHAR2 := NULL)
    IS
    BEGIN
        tools.WriteMsg ('DNET$DEDUCTION.' || $$PLSQL_UNIT);
        API$DEDUCTION.reject_deduction (p_dn_id, p_reason);
    END;

    -----------------------------------------------------------------
    ----------------- Ведення рішень щодо переплат ------------------

    -- #79626: Черга звернень на обробку
    PROCEDURE GET_OVERPAY_QUEUE (p_start_dt   IN     DATE,
                                 p_stop_dt    IN     DATE,
                                 p_org_id     IN     NUMBER,
                                 p_aps_nst    IN     NUMBER,
                                 res_cur         OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.WriteMsg ('DNET$DEDUCTION.' || $$PLSQL_UNIT);

        OPEN res_cur FOR
            SELECT t.*,
                   (SELECT dic_sname
                      FROM uss_ndi.v_ddn_ap_st z
                     WHERE z.DIC_VALUE = t.ap_st)
                       AS ap_st_name,
                   uss_person.api$sc_tools.GET_PIB_SCC (app.app_scc)
                       AS app_main_pib,
                   (SELECT LISTAGG (n.Nda_Name || ' ' || a.Apda_Val_String,
                                    ' ')
                           WITHIN GROUP (ORDER BY n.Nda_Order)
                      FROM Ap_Document_Attr  a
                           JOIN Ap_Document d
                               ON     a.Apda_Apd = d.Apd_Id
                                  AND d.Apd_Ndt = 600
                                  AND d.apd_app IN
                                          (SELECT p.app_id
                                             FROM v_ap_person p
                                            WHERE     p.app_ap = t.ap_id
                                                  AND p.app_tp =
                                                      CASE
                                                          WHEN t.ap_tp IN
                                                                   ('A',
                                                                    'U',
                                                                    'O',
                                                                    'PP')
                                                          THEN
                                                              'O'
                                                          ELSE
                                                              'Z'
                                                      END
                                                  AND p.app_sc = pc.pc_sc
                                                  AND p.history_status = 'A')
                                  AND d.History_Status = 'A'
                           JOIN Uss_Ndi.v_Ndi_Document_Attr n
                               ON a.Apda_Nda = n.Nda_Id AND n.Nda_Nng = 2
                     WHERE a.Apda_Ap = t.ap_id AND a.History_Status = 'A')
                       AS App_Main_Address,
                   (SELECT LISTAGG (st.nst_code || '-' || nst_name,
                                    ', ' || CHR (13) || CHR (10))
                           WITHIN GROUP (ORDER BY st.nst_order)
                      FROM v_ap_service  z
                           JOIN uss_ndi.v_ndi_service_type st
                               ON (st.nst_id = z.aps_nst)
                     WHERE z.aps_ap = t.ap_id --rownum < 4
                                              AND z.history_status = 'A')
                       AS Aps_List
              FROM uss_esr.v_appeal  t
                   JOIN v_personalcase pc ON (pc.pc_id = t.ap_pc)
                   JOIN ap_person app
                       ON     app.app_sc = pc.pc_sc
                          AND app.app_ap = t.ap_id
                          AND app.history_status = 'A'
             WHERE     t.ap_st = 'O'
                   AND ap_tp IN ('PP')
                   AND NOT EXISTS
                           (SELECT *
                              FROM v_ap_service z
                             WHERE     z.aps_ap = t.ap_id
                                   AND z.aps_nst IN (664)
                                   AND z.history_status = 'A')
                   AND TRUNC (t.ap_reg_dt) BETWEEN p_start_dt AND p_stop_dt
                   AND (p_org_id IS NULL OR t.com_org = p_org_id)
                   AND (   p_aps_nst IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM v_ap_service z
                                 WHERE     z.aps_ap = t.ap_id
                                       AND z.aps_nst = p_aps_nst
                                       AND z.history_status = 'A'));
    END;

    -- #79626: Інформація по зверненю в черзі звернень на обробку
    PROCEDURE GET_OVERPAY_QUEUE_INFO (p_ap_id   IN     NUMBER,
                                      res_cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.WriteMsg ('DNET$DEDUCTION.' || $$PLSQL_UNIT);

        OPEN res_cur FOR
            SELECT t.*,
                   (SELECT dic_sname
                      FROM uss_ndi.v_ddn_ap_st z
                     WHERE z.DIC_VALUE = t.ap_st)
                       AS ap_st_name,
                   uss_person.api$sc_tools.GET_PIB_SCC (app.app_scc)
                       AS app_main_pib,
                   /*   (SELECT Listagg(n.Nda_Name || ' ' || a.Apda_Val_String, ' ') Within GROUP(ORDER BY n.Nda_Order)
                         FROM Ap_Document_Attr a
                         JOIN Ap_Document d
                           ON a.Apda_Apd = d.Apd_Id
                              AND d.Apd_Ndt = 600
                              AND d.apd_app IN (SELECT p.app_id
                                                  FROM v_ap_person p
                                                 WHERE p.app_ap = t.ap_id
                                                   AND p.app_tp = CASE WHEN t.ap_tp IN ('A', 'U', 'O', 'PP') THEN 'O' ELSE 'Z' END
                                                   AND p.app_sc = pc.pc_sc
                                                   AND p.history_status = 'A'
                                                 )
                              AND d.History_Status = 'A'
                         JOIN Uss_Ndi.v_Ndi_Document_Attr n
                           ON a.Apda_Nda = n.Nda_Id
                              AND n.Nda_Nng = 2
                        WHERE a.Apda_Ap = t.ap_id
                              AND a.History_Status = 'A'
                      ) AS App_Main_Address,*/

                    (SELECT TO_CHAR (MAX (at.apda_val_int),
                                     'FM999G990D00',
                                     'NLS_NUMERIC_CHARACTERS='',''''')
                       FROM ap_document  d
                            JOIN ap_document_attr at
                                ON (at.apda_apd = d.apd_id)
                      WHERE     d.apd_ap = t.ap_id
                            AND d.apd_ndt = 289
                            AND at.apda_nda = 2326)
                       AS Repayment_Percentage,
                   (SELECT MAX (s.nst_name)
                      FROM ap_document  d
                           JOIN ap_document_attr at
                               ON (at.apda_apd = d.apd_id)
                           JOIN uss_ndi.v_ndi_service_type s
                               ON (s.nst_id = at.apda_val_string)
                     WHERE     d.apd_ap = t.ap_id
                           AND d.apd_ndt = 289
                           AND at.apda_nda = 2327)
                       AS nst_help_name,
                   (SELECT MAX (t.DIC_SNAME)
                      FROM uss_ndi.V_DDN_DN_UNIT t
                     WHERE dic_value =
                           api$appeal.get_ap_o_doc_string (t.ap_id,
                                                           289,
                                                           2529))
                       AS attr_2529,
                   api$appeal.get_ap_o_doc_sum (t.ap_id, 289, 2530)
                       AS attr_2530,
                   api$appeal.get_ap_o_doc_sum (t.ap_id, 289, 2531)
                       AS attr_2531
              FROM uss_esr.v_appeal  t
                   JOIN v_personalcase pc ON (pc.pc_id = t.ap_pc)
                   JOIN ap_person app
                       ON     app.app_sc = pc.pc_sc
                          AND app.app_ap = t.ap_id
                          AND app.history_status = 'A'
             WHERE t.ap_id = P_AP_ID;
    END;

    -- #79626: Взяття звернення на обробку
    PROCEDURE process_deduction_by_appeal (
        p_ap_id       appeal.ap_id%TYPE,
        p_dn_id   OUT deduction.dn_id%TYPE)
    IS
    BEGIN
        tools.WriteMsg ('DNET$DEDUCTION.' || $$PLSQL_UNIT);

        api$deduction.process_deduction_by_appeal (1, p_ap_id, p_dn_id);
    END;

    -- #79626: Реєстр переплат
    PROCEDURE GET_OVERPAY_LIST (p_ap_num               IN     VARCHAR2,
                                p_Dn_In_Doc_Num        IN     VARCHAR2,
                                p_dn_ndn               IN     NUMBER,
                                p_dn_st                IN     VARCHAR2,
                                p_dn_in_doc_dt_start   IN     DATE,
                                p_dn_in_doc_dt_stop    IN     DATE,
                                p_pc_num               IN     VARCHAR2,
                                p_dn_start_dt_start    IN     DATE,
                                p_dn_start_dt_stop     IN     DATE,
                                p_dn_nst               IN     NUMBER,
                                res_cur                   OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT dn.*,
                   ddu.dic_sname                                  AS dn_unit_name,
                   h.hs_dt                                        AS dn_hs_dt,
                   dpp.dpp_name                                   AS dn_dpp_name,
                   dds.dic_sname                                  AS dn_st_name,
                   ndn.ndn_name                                   AS dn_ndn_name,
                   r.DIC_NAME                                     AS dn_reason_name,
                   pc.pc_num,
                   st.nst_name,
                   uss_person.api$sc_tools.GET_PIB (pc.pc_sc)     AS ap_pib,
                   ap.ap_num,
                   pa.pa_num
              FROM v_deduction_by_pc           dn,
                   uss_ndi.v_ddn_dn_unit       ddu,
                   histsession                 h,
                   uss_ndi.v_ndi_pay_person    dpp,
                   uss_ndi.v_ddn_dn_st         dds,
                   uss_ndi.v_ndi_deduction     ndn,
                   appeal                      ap,
                   personalcase                pc,
                   pc_account                  pa,
                   uss_ndi.v_ddn_dn_reason     r,
                   uss_ndi.v_ndi_service_type  st
             WHERE     dn.dn_unit = ddu.dic_value(+)
                   AND dn.dn_hs_return = h.hs_id(+)
                   AND dn.dn_dpp = dpp.dpp_id(+)
                   AND dn.dn_st = dds.dic_value(+)
                   AND dn.dn_ndn = ndn.ndn_id(+)
                   AND dn.dn_pc = pc.pc_id(+)
                   AND dn.dn_pa = pa.pa_id(+)
                   AND dn.dn_ap = ap.ap_id(+)
                   AND pa.pa_nst = st.nst_id(+)
                   AND dn.dn_reason = r.DIC_VALUE(+)
                   AND dn_tp IN ('R', 'HM')
                   AND st.nst_id = NVL (p_dn_nst, st.nst_id)
                   AND ROWNUM <= 502
                   AND (p_ap_num IS NULL OR ap.ap_num LIKE p_ap_num || '%')
                   AND (p_pc_num IS NULL OR pc.pc_num LIKE p_pc_num || '%')
                   AND (   p_Dn_In_Doc_Num IS NULL
                        OR dn.dn_in_doc_num LIKE p_Dn_In_Doc_Num || '%')
                   AND (p_dn_ndn IS NULL OR dn.dn_ndn = p_dn_ndn)
                   AND (p_dn_st IS NULL OR dn.dn_st = p_dn_st)
                   AND (       p_dn_in_doc_dt_start IS NULL
                           AND p_dn_in_doc_dt_stop IS NULL
                        OR     p_dn_in_doc_dt_start IS NULL
                           AND p_dn_in_doc_dt_stop IS NOT NULL
                           AND dn.dn_in_doc_dt <= p_dn_in_doc_dt_stop
                        OR     p_dn_in_doc_dt_start IS NULL
                           AND p_dn_in_doc_dt_stop IS NULL
                           AND dn.dn_in_doc_dt >= p_dn_in_doc_dt_start
                        OR     p_dn_in_doc_dt_start IS NOT NULL
                           AND p_dn_in_doc_dt_stop IS NOT NULL
                           AND dn.dn_in_doc_dt BETWEEN p_dn_in_doc_dt_start
                                                   AND p_dn_in_doc_dt_stop)
                   AND (       p_dn_start_dt_start IS NULL
                           AND p_dn_start_dt_stop IS NULL
                        OR     p_dn_start_dt_start IS NULL
                           AND p_dn_start_dt_stop IS NOT NULL
                           AND dn.dn_start_dt <= p_dn_start_dt_stop
                        OR     p_dn_start_dt_start IS NULL
                           AND p_dn_start_dt_stop IS NULL
                           AND dn.dn_start_dt >= p_dn_start_dt_start
                        OR     p_dn_start_dt_start IS NOT NULL
                           AND p_dn_start_dt_stop IS NOT NULL
                           AND dn.dn_start_dt BETWEEN p_dn_start_dt_start
                                                  AND p_dn_start_dt_stop);
    END;

    -- #79263: Картка переплат
    PROCEDURE GET_OVERPAY_CARD (p_dn_id      IN     NUMBER,
                                main_cur        OUT SYS_REFCURSOR,
                                det_cur         OUT SYS_REFCURSOR,
                                charge_cur      OUT SYS_REFCURSOR,
                                cond_cur        OUT SYS_REFCURSOR)
    IS
        l_flag   NUMBER := tools.GetCurrOrg;
    BEGIN
        SELECT CASE
                   WHEN l_flag = op.org_acc_org THEN 1
                   WHEN l_flag = op.org_id THEN 1
                   ELSE 0
               END
          INTO l_flag
          FROM deduction  t
               JOIN personalcase p ON (p.pc_id = t.dn_pc)
               JOIN v_opfu op ON (op.org_id = p.com_org)
         WHERE t.dn_id = p_dn_id AND dn_tp IN ('R', 'HM');

        IF (l_flag = 1)
        THEN
            OPEN main_cur FOR
                SELECT dn.*,
                       ddu.dic_sname
                           AS dn_unit_name,
                       h.hs_dt
                           AS dn_hs_dt,
                       dpp.dpp_name
                           AS dn_dpp_name,
                       dds.dic_sname
                           AS dn_st_name,
                       ndn.ndn_name
                           AS dn_ndn_name,
                       pc.pc_num,
                       pc.pc_id,
                       ap.ap_num,
                       ap.ap_tp,
                       pa.pa_num,
                       st.nst_name,
                       st.nst_id,
                       NVL (dn_debt_total, 0) - NVL (dn_debt_current, 0)
                           AS dn_payed_sum,
                       uss_person.api$sc_tools.GET_PIB (pc.pc_sc)
                           AS ap_pib,
                       uss_person.api$sc_tools.get_numident (pc.pc_sc)
                           AS ap_rnokpp,
                       NULL
                           AS ap_ser_num,
                       tools.get_main_addr (ap.ap_id, ap.ap_tp, pc.pc_sc)
                           AS App_Main_Address,
                       p.org_id,
                       p.org_acc_org
                  FROM deduction                   dn,
                       uss_ndi.v_ddn_dn_unit       ddu,
                       histsession                 h,
                       uss_ndi.v_ndi_pay_person    dpp,
                       uss_ndi.v_ddn_dn_st         dds,
                       uss_ndi.v_ndi_deduction     ndn,
                       appeal                      ap,
                       personalcase                pc,
                       v_opfu                      p,
                       pc_account                  pa,
                       uss_ndi.v_ndi_service_type  st
                 WHERE     dn.dn_unit = ddu.dic_value
                       AND dn.dn_hs_return = h.hs_id(+)
                       AND dn.dn_dpp = dpp.dpp_id(+)
                       AND dn.dn_st = dds.dic_value(+)
                       AND dn.dn_ndn = ndn.ndn_id(+)
                       AND dn.dn_pc = pc.pc_id(+)
                       AND pc.com_org = p.org_id(+)
                       AND dn.dn_pa = pa.pa_id(+)
                       AND pa.pa_nst = st.nst_id(+)
                       AND dn.dn_ap = ap.ap_id(+)
                       AND dn_tp IN ('R', 'HM')
                       AND dn.dn_id = p_dn_id;
        ELSE
            OPEN main_cur FOR
                SELECT dn.*,
                       ddu.dic_sname
                           AS dn_unit_name,
                       h.hs_dt
                           AS dn_hs_dt,
                       dpp.dpp_name
                           AS dn_dpp_name,
                       dds.dic_sname
                           AS dn_st_name,
                       ndn.ndn_name
                           AS dn_ndn_name,
                       pc.pc_num,
                       pc.pc_id,
                       ap.ap_num,
                       ap.ap_tp,
                       pa.pa_num,
                       st.nst_name,
                       NVL (dn_debt_total, 0) - NVL (dn_debt_current, 0)
                           AS dn_payed_sum,
                       uss_person.api$sc_tools.GET_PIB (pc.pc_sc)
                           AS ap_pib,
                       uss_person.api$sc_tools.get_numident (pc.pc_sc)
                           AS ap_rnokpp,
                       NULL
                           AS ap_ser_num,
                       tools.get_main_addr (ap.ap_id, ap.ap_tp, pc.pc_sc)
                           AS App_Main_Address,
                       p.org_id,
                       p.org_acc_org
                  FROM v_deduction_by_pc           dn,
                       uss_ndi.v_ddn_dn_unit       ddu,
                       histsession                 h,
                       uss_ndi.v_ndi_pay_person    dpp,
                       uss_ndi.v_ddn_dn_st         dds,
                       uss_ndi.v_ndi_deduction     ndn,
                       appeal                      ap,
                       personalcase                pc,
                       v_opfu                      p,
                       pc_account                  pa,
                       uss_ndi.v_ndi_service_type  st
                 WHERE     dn.dn_unit = ddu.dic_value
                       AND dn.dn_hs_return = h.hs_id(+)
                       AND dn.dn_dpp = dpp.dpp_id(+)
                       AND dn.dn_st = dds.dic_value(+)
                       AND dn.dn_ndn = ndn.ndn_id(+)
                       AND dn.dn_pc = pc.pc_id(+)
                       AND pc.com_org = p.org_id(+)
                       AND dn.dn_pa = pa.pa_id(+)
                       AND pa.pa_nst = st.nst_id(+)
                       AND dn.dn_ap = ap.ap_id(+)
                       AND dn_tp IN ('R', 'HM')
                       AND dn.dn_id = p_dn_id;
        END IF;

        OPEN det_cur FOR
              SELECT t.*,
                     pt.npt_code,
                     pt.npt_name,
                     d.pd_num
                FROM ac_detail t
                     LEFT JOIN uss_ndi.v_ndi_payment_type pt
                         ON (pt.npt_id = t.acd_npt)
                     LEFT JOIN pc_decision d ON (d.pd_id = t.acd_pd)
               WHERE     (t.acd_dn = p_dn_id OR t.acd_dn_src = p_dn_id)
                     AND t.acd_op IN (6, 30)                             --125
                     AND t.history_status = 'A'
            ORDER BY t.acd_start_dt;

        OPEN charge_cur FOR
              SELECT t.*,
                     pt.npt_code,
                     pt.npt_name,
                     ed_num,     --№ документа повернення зайво стягнених сумм
                     CASE WHEN acd_ed IS NOT NULL THEN acd_sum ELSE 0.00 END    AS acd_returned_sum --сума повернення
                FROM ac_detail t
                     LEFT JOIN uss_ndi.v_ndi_payment_type pt
                         ON (pt.npt_id = t.acd_npt)
                     LEFT JOIN errand ed ON (acd_ed = ed_id)
               WHERE     t.acd_dn = p_dn_id
                     AND t.acd_op IN (123, 124)
                     AND t.history_status = 'A'
            ORDER BY t.acd_start_dt;

        OPEN cond_cur FOR
              SELECT t.dnd_id,
                     t.dnd_start_dt,
                     t.dnd_value,
                     t.dnd_value_prefix,
                     t.dnd_tp,
                     tp.DIC_NAME     AS dnd_tp_name
                FROM dn_detail t
                     LEFT JOIN uss_ndi.v_ddn_dn_unit tp
                         ON (tp.DIC_VALUE = t.dnd_tp)
               WHERE t.dnd_dn = p_dn_id AND t.history_status = 'A'
            ORDER BY t.dnd_start_dt;
    END;

    -- #83984
    PROCEDURE create_new_overpay (p_pc_id           IN NUMBER,
                                  p_nst_id          IN NUMBER,
                                  p_dn_debt_total   IN NUMBER)
    IS
        l_check      NUMBER;
        l_pa_id      NUMBER;
        l_hs         NUMBER := tools.GetHistSession;
        l_org        NUMBER := tools.GetCurrOrg;
        l_nst_name   uss_ndi.v_ndi_service_type.nst_name%TYPE;
        l_num        VARCHAR2 (50);
        l_id         NUMBER;
        l_dpp        deduction.dn_dpp%TYPE;
    BEGIN
        --  IF ikis_parameter_util.GetParameter1(p_par_code => 'APP_INSTNACE_TYPE', p_par_ss_code => 'IKIS_SYS') = 'PROM' THEN
        --    raise_application_error(-20000, 'Знаходиться в розробці');
        --  END IF;

        SELECT COUNT (*)
          INTO l_check
          FROM v_pc_decision t
         WHERE t.pd_pc = p_pc_id AND t.pd_nst = p_nst_Id;

        SELECT MAX (t.pa_id)
          INTO l_pa_id
          FROM v_pc_account t
         WHERE t.pa_pc = p_pc_id AND t.pa_nst = p_nst_id;

        IF (l_check = 0)
        THEN
            SELECT t.nst_name
              INTO l_nst_name
              FROM uss_ndi.v_ndi_service_type t
             WHERE t.nst_id = p_nst_id;

            raise_application_error (
                -20000,
                'В ЕОС відсутні рішення по ' || l_nst_name);
        END IF;

        SELECT (SELECT dpp_id
                  FROM uss_ndi.v_ndi_pay_person
                 WHERE     history_status = 'A'
                       AND dpp_tp = 'OSZN'
                       AND dpp_org = 50000)    AS x_dpp
          INTO l_dpp
          FROM pc_account, personalcase pc
         WHERE pa_id = l_pa_id AND pa_pc = pc_id AND pc_id = p_pc_id;

        INSERT INTO deduction t (dn_tp,
                                 dn_pc,
                                 dn_pa,
                                 history_status,
                                 dn_ndn,
                                 dn_st,
                                 dn_in_doc_dt,
                                 dn_debt_total,
                                 dn_debt_current,
                                 dn_start_dt,
                                 dn_stop_dt,
                                 com_org,
                                 dn_hs_ins,
                                 dn_unit,
                                 dn_debt_limit_prc,
                                 dn_dpp)
             VALUES ('HM',
                     p_pc_id,
                     l_pa_id,
                     'A',
                     89,
                     'E',
                     TRUNC (SYSDATE),
                     p_dn_debt_total,
                     p_dn_debt_total,
                     ADD_MONTHS (TRUNC (SYSDATE, 'MM'), 1),
                     LAST_DAY (ADD_MONTHS (TRUNC (SYSDATE, 'MM'), 1)),
                     l_org,
                     l_hs,
                     'PD',
                     20,
                     l_dpp)
          RETURNING dn_id
               INTO l_id;

        l_num := TO_CHAR (l_org) || '_' || l_id || '_Р';

        UPDATE deduction t
           SET dn_in_doc_num = l_num
         WHERE dn_id = l_id;

        INSERT INTO dn_detail (dnd_dn,
                               dnd_start_dt,
                               dnd_stop_dt,
                               dnd_tp,
                               dnd_value,
                               history_status,
                               dnd_hs_ins)
             VALUES (l_id,
                     ADD_MONTHS (TRUNC (SYSDATE, 'MM'), 1),
                     TO_DATE ('31.12.2099', 'DD.MM.YYYY'),
                     'PD',
                     20,
                     'A',
                     l_hs);
    END;

    -- #83984
    PROCEDURE CREATE_OVERPAY_DETAILS (p_dn_id IN NUMBER, p_xml IN CLOB)
    IS
        l_details      t_detail := t_detail ();
        l_nst          uss_ndi.v_ndi_service_type.nst_id%TYPE;
        l_ac_id        accrual.ac_id%TYPE;
        l_deduction    deduction%ROWTYPE;
        l_org          personalcase.com_org%TYPE;
        l_month_curr   accrual.ac_month%TYPE;
    BEGIN
        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''. ''');

        EXECUTE IMMEDIATE Type2xmltable (Package_Name, 't_detail', TRUE)
            BULK COLLECT INTO l_details
            USING p_xml;

        SELECT *
          INTO l_deduction
          FROM deduction
         WHERE dn_id = p_dn_id;

        SELECT com_org
          INTO l_org
          FROM personalcase
         WHERE pc_id = l_deduction.dn_pc;

        SELECT pa_nst
          INTO l_nst
          FROM deduction, pc_account
         WHERE dn_pa = pa_id AND dn_id = p_dn_id;

        /*  IF l_nst <> 664 THEN
            raise_application_error(-20000, 'Формування деталей для "не ВПО" - тільки після вибору в інтерфейсі рішення про призначення та коду виплати!');
            --!!!! повинно правильно заповнюватися в acd_pd + acd_npt
          END IF;*/

        SELECT bp_month
          INTO l_month_curr
          FROM billing_period
         WHERE     bp_tp = 'PR'
               AND bp_class = DECODE (l_nst, 664, 'VPO', 'V')
               AND bp_org = l_org
               AND bp_st = 'R';

        BEGIN
            SELECT ac_id
              INTO l_ac_id
              FROM accrual
             WHERE ac_pc = l_deduction.dn_pc AND ac_month = l_month_curr;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                INSERT INTO accrual (ac_id,
                                     ac_pc,
                                     ac_month,
                                     ac_st,
                                     history_status,
                                     com_org)
                     VALUES (0,
                             l_deduction.dn_pc,
                             l_month_curr,
                             'E',
                             'A',
                             l_org)
                  RETURNING ac_id
                       INTO l_ac_id;
        END;

        FOR xx IN (SELECT d.*
                     FROM ac_detail d
                    WHERE     d.acd_dn = p_dn_id
                          AND NOT EXISTS
                                  (SELECT *
                                     FROM TABLE (l_details) z
                                    WHERE z.acd_id = d.acd_id)
                          AND acd_op IN (6, 30))
        LOOP
            UPDATE ac_detail t
               SET t.history_status = 'H'
             WHERE     t.acd_id = xx.acd_id
                   AND acd_op = 6
                   AND (acd_dn = p_dn_id OR acd_dn_src = p_dn_id);
        END LOOP;


        FOR xx IN (SELECT *
                     FROM TABLE (l_details) t)
        LOOP
            IF (xx.acd_id IS NULL OR xx.acd_id < 0)
            THEN
                INSERT INTO ac_detail (acd_ac,
                                       acd_start_dt,
                                       acd_stop_dt,
                                       acd_sum,
                                       history_status,
                                       acd_op,
                                       acd_dn,
                                       acd_npt,
                                       acd_ac_start_dt,
                                       acd_ac_stop_dt,
                                       acd_st,
                                       acd_pd)
                     VALUES (l_ac_id,
                             xx.acd_start_dt,
                             LAST_DAY (xx.acd_start_dt)     /*xx.acd_stop_dt*/
                                                       ,
                             xx.acd_sum,
                             'A',
                             6,
                             p_dn_id,
                             DECODE (l_nst, 664, 167, xx.acd_npt),
                             l_month_curr,
                             LAST_DAY (l_month_curr),
                             'H',
                             DECODE (l_nst, 664, NULL, xx.acd_pd)); --!!!! acd_pd заполнять из интерфейса!!!
            ELSE
                UPDATE ac_detail t
                   SET acd_start_dt = xx.acd_start_dt,
                       acd_stop_dt = LAST_DAY (xx.acd_start_dt), /* xx.acd_stop_dt,*/
                       acd_sum = xx.acd_sum,
                       --acd_npt = 167,
                       acd_ac = l_ac_id,
                       acd_ac_start_dt = l_month_curr,
                       acd_ac_stop_dt = LAST_DAY (l_month_curr),
                       acd_pd = DECODE (l_nst, 664, NULL, xx.acd_pd),
                       acd_npt = DECODE (l_nst, 664, 167, xx.acd_npt)
                 WHERE t.acd_id = xx.acd_id AND acd_dn = p_dn_id;
            END IF;
        END LOOP;
    END;

    -- #79263: збереження картки переплат
    PROCEDURE save_overpay_card (
        p_dn_id               IN NUMBER,
        p_dn_reason           IN VARCHAR2,
        p_dn_start_dt         IN DATE,
        p_dn_debt_limit_prc   IN deduction.dn_debt_limit_prc%TYPE,
        p_dn_pa               IN deduction.dn_pa%TYPE)
    IS
    BEGIN
        api$deduction.save_overpay_card (p_dn_id,
                                         p_dn_reason,
                                         p_dn_debt_limit_prc,
                                         p_dn_pa);

        -- #82710
        UPDATE v_dn_detail q
           SET q.dnd_start_dt = COALESCE (p_dn_start_dt, q.dnd_start_dt)
         WHERE q.dnd_dn = p_dn_id AND q.history_status = 'A';
    END;

    FUNCTION OVERPAY_R1 (p_rt_id IN NUMBER, P_dn_id IN NUMBER)
        RETURN DECIMAL
    IS
        l_jbr_id   DECIMAL;
    BEGIN
        l_jbr_id := rdm$rtfl.InitReport (p_rt_id);

        FOR xx
            IN (SELECT t.*,
                       s.nst_name,
                       (SELECT MAX (pz.pdp_sum)
                          FROM pd_payment pz
                         WHERE     pz.pdp_pd = pd.pd_id
                               AND pd.pd_dt BETWEEN pz.pdp_start_dt
                                                AND pz.pdp_stop_dt
                               AND pz.history_status = 'A')    AS serv_sum,
                       p.org_name
                  FROM (SELECT (SELECT LISTAGG (
                                              n.Nda_Name
                                           || ' '
                                           || a.Apda_Val_String,
                                           ' ')
                                       WITHIN GROUP (ORDER BY n.Nda_Order)
                                  FROM Ap_Document_Attr  a
                                       JOIN Ap_Document d
                                           ON     a.Apda_Apd = d.Apd_Id
                                              AND d.Apd_Ndt = 600
                                              AND d.apd_app IN
                                                      (SELECT p.app_id
                                                         FROM v_ap_person p
                                                        WHERE     p.app_ap =
                                                                  ap.ap_id
                                                              AND p.app_tp =
                                                                  'O'
                                                              AND p.history_status =
                                                                  'A')
                                              AND d.History_Status = 'A'
                                       JOIN Uss_Ndi.v_Ndi_Document_Attr n
                                           ON     a.Apda_Nda = n.Nda_Id
                                              AND n.Nda_Nng = 2
                                 WHERE     a.Apda_Ap = ap.ap_id
                                       AND a.History_Status = 'A')
                                   AS main_address,
                               t.dn_in_doc_num,
                               t.dn_in_doc_dt,
                               t.dn_debt_limit_prc,
                               t.dn_reason,
                               (SELECT MAX (z.app_sc)
                                  FROM ap_person z
                                 WHERE z.app_ap = ap.ap_id AND z.app_tp = 'O')
                                   AS app_sc,
                               (SELECT MAX (zd.acd_pd)
                                  FROM ac_detail zd
                                 WHERE     zd.acd_op = 125
                                       AND zd.acd_dn = t.dn_id)
                                   AS pd_id,
                               CASE
                                   WHEN dn_debt_total > 0
                                   THEN
                                       dn_debt_total
                                   ELSE
                                       (SELECT MAX (dnd_value)
                                          FROM dn_detail
                                         WHERE dnd_dn = dn_id)
                               END
                                   AS dn_debt_total,
                               --s.nst_name,
                               t.dn_start_dt,
                               t.dn_stop_dt
                          FROM deduction  t
                               LEFT JOIN appeal ap ON (ap.ap_id = t.dn_ap)
                         WHERE t.dn_id = P_dn_id) t
                       LEFT JOIN pc_decision pd ON (pd.pd_id = t.pd_id)
                       LEFT JOIN uss_ndi.v_ndi_service_type s
                           ON (s.nst_id = pd.pd_nst)
                       LEFT JOIN v_opfu p ON (p.org_id = pd.com_org)-- LEFT JOIN pc_account ac ON (ac.pa_id = t.dn_pa)
                                                                    -- LEFT JOIN uss_ndi.v_ndi_service_type s ON (s.nst_id = ac.pa_nst)
                                                                    )
        LOOP
            RDM$RTFL.AddParam (l_jbr_id,
                               'c_in_dt_day',
                               TO_CHAR (xx.dn_in_doc_dt, 'DD'));
            RDM$RTFL.AddParam (l_jbr_id,
                               'c_in_dt_month',
                               TO_CHAR (xx.dn_in_doc_dt, 'MM'));
            RDM$RTFL.AddParam (l_jbr_id,
                               'c_in_dt_year',
                               TO_CHAR (xx.dn_in_doc_dt, 'YYYY'));
            RDM$RTFL.AddParam (l_jbr_id, 'c_in_num', xx.dn_in_doc_num);
            RDM$RTFL.AddParam (
                l_jbr_id,
                'c_pib',
                CASE
                    WHEN xx.app_sc IS NOT NULL
                    THEN
                        uss_person.api$sc_tools.GET_PIB (xx.app_sc)
                END);
            RDM$RTFL.AddParam (l_jbr_id, 'soc_help', xx.nst_name);
            RDM$RTFL.AddParam (l_jbr_id,
                               'c_dn_debt_limit_prc',
                               xx.dn_debt_limit_prc);
            RDM$RTFL.AddParam (l_jbr_id,
                               'c_per_start',
                               TO_CHAR (xx.dn_start_dt, 'DD.MM'));
            RDM$RTFL.AddParam (l_jbr_id,
                               'c_per_stop',
                               TO_CHAR (xx.dn_stop_dt, 'DD.MM'));
            RDM$RTFL.AddParam (
                l_jbr_id,
                'c_per_year',
                TO_CHAR (NVL (xx.dn_stop_dt, xx.dn_start_dt), 'YYYY'));

            RDM$RTFL.AddParam (
                l_jbr_id,
                'c_overpay_grn',
                TO_CHAR (TRUNC (xx.dn_debt_total),
                         'FM9G999G999G999G999G990',
                         'NLS_NUMERIC_CHARACTERS='','''''));
            RDM$RTFL.AddParam (
                l_jbr_id,
                'c_overpay_cop',
                TO_CHAR ((xx.dn_debt_total - TRUNC (xx.dn_debt_total)) * 100,
                         'FM9G999G999G999G999G990',
                         'NLS_NUMERIC_CHARACTERS='','''''));

            RDM$RTFL.AddParam (
                l_jbr_id,
                'c_pay_grn',
                TO_CHAR (TRUNC (xx.serv_sum),
                         'FM9G999G999G999G999G990',
                         'NLS_NUMERIC_CHARACTERS='','''''));
            RDM$RTFL.AddParam (
                l_jbr_id,
                'c_pay_cop',
                TO_CHAR ((xx.serv_sum - TRUNC (xx.serv_sum)) * 100,
                         'FM9G999G999G999G999G990',
                         'NLS_NUMERIC_CHARACTERS='','''''));
            RDM$RTFL.AddParam (l_jbr_id, 'narah_name', xx.org_name);

            RDM$RTFL.AddParam (l_jbr_id,
                               'dn_reason_1',
                               tools.get_substr (xx.dn_reason,
                                                 ' ',
                                                 1,
                                                 45));
            RDM$RTFL.AddParam (l_jbr_id,
                               'dn_reason_2',
                               tools.get_substr (xx.dn_reason, ' ', 45));
            RDM$RTFL.AddParam (l_jbr_id,
                               'addr_1',
                               tools.get_substr (xx.main_address,
                                                 ' ',
                                                 1,
                                                 26));
            RDM$RTFL.AddParam (l_jbr_id,
                               'addr_2',
                               tools.get_substr (xx.main_address, ' ', 26));
        --    RDM$RTFL.AddParam(l_jbr_id, 'c_', xx.);
        END LOOP;


        rdm$rtfl.PutReportToWorkingQueue (l_jbr_id);
        RETURN l_jbr_id;
    END;


    -- #79263: Друк
    PROCEDURE registry_report (p_rt_id    IN     NUMBER,
                               p_ids      IN     VARCHAR2,
                               p_jbr_id      OUT NUMBER)
    IS
        l_rt_code   VARCHAR2 (30);
    BEGIN
        SELECT t.rt_code
          INTO l_rt_code
          FROM rpt_templates t
         WHERE t.rt_id = p_rt_id;

        p_jbr_id :=
            CASE l_rt_code
                WHEN 'OVERPAY_R1' THEN OVERPAY_R1 (p_rt_id, p_ids)
                ELSE NULL
            END;
    END;

    --Відміна рішення щодо переплати
    PROCEDURE cancel_deduction (p_dn_id       deduction.dn_id%TYPE,
                                p_reason   IN VARCHAR2 := NULL)
    IS
        l_reason   VARCHAR2 (10);
    BEGIN
        tools.WriteMsg ('DNET$DEDUCTION.' || $$PLSQL_UNIT);

        SELECT t.dn_Reason
          INTO l_reason
          FROM deduction t
         WHERE t.dn_id = p_dn_id;

        IF (l_reason IS NULL)
        THEN
            raise_application_error (-20000,
                                     'Необхідно заповнити причину переплати');
        END IF;

        API$DEDUCTION.cancel_deduction (p_dn_id, p_reason);
    END;

    -- #92271: Закрити рішення щодо переплати
    PROCEDURE close_deduction (p_dn_id deduction.dn_id%TYPE, p_close_dt DATE)
    IS
        l_reason   VARCHAR2 (10);
        l_cnt      NUMBER;
    BEGIN
        tools.WriteMsg ('DNET$DEDUCTION.' || $$PLSQL_UNIT);

        /*SELECT t.dn_Reason
          INTO l_reason
          FROM deduction t
         WHERE t.dn_id = p_dn_id;

        IF (l_reason IS NULL) THEN
          raise_application_error(-20000, 'Необхідно заповнити причину переплати');
        END IF;*/

        SELECT COUNT (*)
          INTO l_cnt
          FROM v_deduction t
         WHERE t.dn_id = p_dn_id AND t.dn_st IN ('R') /*
                                  AND t.dn_tp IN ('D')*/
                                                     ;

        IF (l_cnt = 0)
        THEN
            raise_application_error (
                -20000,
                'Закрити рішення щодо переплати у вказаному статусі неможливо!');
        END IF;

        API$DEDUCTION.close_deduction (p_dn_id, p_close_dt);
    END;

    -- #85173
    PROCEDURE get_overpay_decisions (p_dn_id   IN     NUMBER,
                                     res_cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT pt.npt_id                                                 AS id,
                   t.pd_id                                                   AS code,
                   t.pd_num || ', ' || pt.npt_code || ', ' || pt.npt_name    AS NAME
              FROM pc_decision  t
                   JOIN pd_payment p ON (p.pdp_pd = t.pd_id)
                   JOIN uss_ndi.v_ndi_payment_type pt
                       ON (pt.npt_id = p.pdp_npt)
                   JOIN v_deduction_by_pc d ON (d.dn_id = p_dn_id)
                   JOIN v_pc_account pa ON (pa.pa_id = d.dn_pa)
             WHERE     d.dn_pc = t.pd_pc
                   AND t.pd_nst = pa.pa_nst
                   AND t.pd_st IN ('S', 'PS');
    END;


    -- #91250 Поновити
    PROCEDURE renew_decision (p_dn_id IN NUMBER, p_renew_dt IN DATE)
    IS
    BEGIN
        uss_esr.API$DEDUCTION.renew_deduction (p_dn_id, p_renew_dt);
    END;

    -- Повернути зайво стягнене
    PROCEDURE init_errand_by_deduction (p_ids      IN     VARCHAR2,
                                        p_reason   IN     VARCHAR2,
                                        p_ed_id       OUT NUMBER)
    IS
    BEGIN
        IF (p_ids IS NULL)
        THEN
            raise_application_error (-20000, 'Виберіть хоча б одну строку!');
        END IF;

        INSERT INTO tmp_work_ids4 (x_id)
                SELECT REGEXP_SUBSTR (text,
                                      '[^(\,)]+',
                                      1,
                                      LEVEL)
                  FROM (SELECT p_ids AS text FROM DUAL)
            CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                              '[^(\,)]+',
                                              1,
                                              LEVEL)) > 0;

        api$errand.init_errand_by_deduction (p_mode     => 1,
                                             p_ed_id    => p_ed_id,
                                             p_reason   => p_reason);
    END;

    PROCEDURE manipulate_with_acd_sa (p_acd_id   ac_detail.acd_id%TYPE,
                                      p_action   INTEGER) --1=Встановити ознаку в T, 2=Встановити ознаку в F
    IS
    BEGIN
        API$ACCRUAL.manipulate_with_acd_sa (p_acd_id, p_action);
    END;
BEGIN
    -- Initialization
    NULL;
END DNET$DEDUCTION;
/