/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$RPT_HELP_FAMILY
IS
    -- Author  : KELATEV
    -- Created : 10.10.2024 17:56:57
    -- Purpose : Звіти по допомогам сім’ям з дітьми

    --/esr/Reports/Help/FamilyHelp
    --меню Звіти->Звітність по допомогам->Звіт про надання державної допомоги сім’ям з дітьми

    --Виклик звітів у цьому пакету відбувається у dnet$payment_reports.RegisterReport

    PKG   CONSTANT VARCHAR2 (100) := 'API$RPT_HELP_FAMILY';

    PROCEDURE SET_CHILDREN_FML (p_start_dt   IN DATE,
                                p_org_id     IN NUMBER,
                                p_jbr_id     IN DECIMAL);

    PROCEDURE SET_CHILD_ORPHANS (p_start_dt   IN DATE,
                                 p_org_id     IN NUMBER,
                                 p_jbr_id     IN DECIMAL);

    PROCEDURE SET_CHILD_ORPHANS_R2 (p_start_dt   IN DATE,
                                    p_org_id     IN NUMBER,
                                    p_jbr_id     IN DECIMAL);

    PROCEDURE SET_CHILD_ORPHANS_R3 (p_start_dt   IN DATE,
                                    p_org_id     IN NUMBER,
                                    p_jbr_id     IN DECIMAL);

    PROCEDURE SET_CHILD_ORPHANS_R4 (p_start_dt   IN DATE,
                                    p_org_id     IN NUMBER,
                                    p_jbr_id     IN DECIMAL);

    PROCEDURE SET_CHILD_ORPHANS_R5 (p_start_dt   IN DATE,
                                    p_org_id     IN NUMBER,
                                    p_jbr_id     IN DECIMAL);

    PROCEDURE SET_CHILD_ORPHANS_R6 (p_start_dt   IN DATE,
                                    p_org_id     IN NUMBER,
                                    p_jbr_id     IN DECIMAL);

    FUNCTION REP_CHILDREN_FML (p_start_dt   IN DATE,
                               p_org_id     IN NUMBER,
                               p_rt_id      IN rpt_templates.rt_id%TYPE)
        RETURN DECIMAL;

    FUNCTION REP_CHILD_ORPHANS (p_start_dt   IN DATE,
                                p_org_id     IN NUMBER,
                                p_rt_id      IN rpt_templates.rt_id%TYPE)
        RETURN DECIMAL;

    FUNCTION REP_CHILD_ORPHANS_R2 (p_start_dt   IN DATE,
                                   p_org_id     IN NUMBER,
                                   p_rt_id      IN rpt_templates.rt_id%TYPE)
        RETURN DECIMAL;

    FUNCTION REP_CHILD_ORPHANS_R3 (p_start_dt   IN DATE,
                                   p_org_id     IN NUMBER,
                                   p_rt_id      IN rpt_templates.rt_id%TYPE)
        RETURN DECIMAL;

    FUNCTION REP_CHILD_ORPHANS_R4 (p_start_dt   IN DATE,
                                   p_org_id     IN NUMBER,
                                   p_rt_id      IN rpt_templates.rt_id%TYPE)
        RETURN DECIMAL;

    FUNCTION REP_CHILD_ORPHANS_R5 (p_start_dt   IN DATE,
                                   p_org_id     IN NUMBER,
                                   p_rt_id      IN rpt_templates.rt_id%TYPE)
        RETURN DECIMAL;

    FUNCTION REP_CHILD_ORPHANS_R6 (p_start_dt   IN DATE,
                                   p_org_id     IN NUMBER,
                                   p_rt_id      IN rpt_templates.rt_id%TYPE)
        RETURN DECIMAL;
END dnet$rpt_help_family;
/


GRANT EXECUTE ON USS_ESR.DNET$RPT_HELP_FAMILY TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$RPT_HELP_FAMILY TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:51 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$RPT_HELP_FAMILY
IS
    -- IC #88696 Звіт про надання  допомоги сім'ям з дітьми та тимчасової державної допомоги дітям, батьки яких ухиляються від сплати аліментів
    PROCEDURE SET_CHILDREN_FML (p_start_dt   IN DATE,
                                p_org_id     IN NUMBER,
                                p_jbr_id     IN DECIMAL)
    IS
        l_user_org    NUMBER;
        l_org_to      NUMBER := tools.GetCurrOrgTo;

        l_cnt_6y      NUMBER;
        l_cnt_18y     NUMBER;
        l_cnt_23y     NUMBER;
        l_sum         NUMBER;
        l_sum_m       NUMBER;
        l_sum_6y      NUMBER;
        l_sum_18y     NUMBER;
        l_sum_23y     NUMBER;
        l_cnt_chd     NUMBER;
        l_cnt_chd_m   NUMBER;
        l_prc         NUMBER;

        l_dtb         DATE;
        l_dte         DATE;
        l_dty         DATE;
    BEGIN
        IF p_org_id = 0
        THEN
            l_user_org := Tools.GetCurrOrg;
        ELSE
            l_user_org := p_org_id;
        END IF;

        l_user_org :=
            CASE WHEN l_user_org = 50001 THEN 50000 ELSE l_user_org END;

        IF l_org_to = 34
        THEN
            SELECT org_to
              INTO l_org_to
              FROM ikis_sys.v_opfu
             WHERE org_id = l_user_org;
        END IF;

        l_org_to := CASE WHEN l_org_to = 34 THEN 34 ELSE 32 END;

        l_dte := TRUNC (p_start_dt, 'mm');
        l_dtb :=
            CASE
                WHEN TO_CHAR (l_dte, 'mm') = '01' -- якщо перший місяць - беремо з попереднього року
                THEN
                    ADD_MONTHS (TRUNC (l_dte - 1, 'yy'), 1)
                ELSE
                    ADD_MONTHS (TRUNC (l_dte, 'yy'), 1)
            END;
        l_dtb := TRUNC (p_start_dt, 'yy');                           -- #98740
        l_dty := TRUNC (l_dtb, 'yy');

        DELETE FROM tmp_univ_rpt_data
              WHERE 1 = 1;

        INSERT INTO tmp_univ_rpt_data (x_id1,                        -- ca Nзп
                                       x_string1,               -- cb Допомога
                                       x_sum1, -- a_assing (Призначено з початку року)
                                       x_sum2, -- a_assing_m (Призначено звітний місяць)
                                       x_id2, -- cnt_fml_6y (к-ть дітей до шести років)
                                       x_id3, -- cnt_fml_18y (к-ть дітей до 18 років)
                                       x_id4, -- cnt_fml_23y (к-ть дітей до 23 років за умови навчання)
                                       x_sum3, -- x_narah (нараховано допомог)
                                       x_sum4,      -- x_borg (фактичний борг)
                                       x_sum5, -- a_payed (виплачено з початку року)
                                       x_sum6, -- a_payed_m (виплачено за звітний місяць)
                                       x_id5, -- appl_cnt (к-ть звернулися за призначенням)
                                       x_id6, -- a_cnt_y (к-ть осіб призначених з початку року)
                                       x_sum7, -- x_cnt_m (кількість отримувачів допомоги у звітному місяці)
                                       x_sum8, -- x_cnt_m_max (в т.ч. отримують допомогу в максимальному розмірі)
                                       x_sum9, -- x_cnt_child (Кількість дітей, на яких отримують допомогу у звітному місяці (одиниць) Всього)
                                       x_sum10) -- x_cnt_child_max (у тому числі,  на яких отримують допомогу у максимальному розмірі)
            WITH
                org
                AS
                    (    SELECT org_id     i_org
                           FROM ikis_sys.v_opfu
                          WHERE l_org_to = 32
                     CONNECT BY PRIOR org_id = org_org
                     START WITH org_id = l_user_org
                     UNION ALL
                     SELECT org_id     i_org
                       FROM ikis_sys.v_opfu
                      WHERE l_org_to = 34 AND org_acc_org = l_user_org),
                dt_rep
                AS
                    (    SELECT ADD_MONTHS (TRUNC (p_start_dt, 'yy'), LEVEL - 1)    dt_r
                           FROM DUAL
                     CONNECT BY LEVEL <=
                                EXTRACT (MONTH FROM TRUNC (p_start_dt, 'mm'))),
                rpt
                AS
                    (SELECT 1                                                                                          ca,
                            'Всього по  допомозі сім''ям з дітьми (ряд.2 + ряд.3 + ряд.4 + ряд.7 + ряд.10+ ряд.14)'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 2                                                    ca,
                               'В тому числі:'
                            || CHR (10)
                            || 'допомога у зв''язку з вагітністю та пологами'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 3 ca, 'допомога при усиновленні дитини' cb
                       FROM DUAL
                     UNION ALL
                     SELECT 4 ca, 'допомога при народженні дитини' cb
                       FROM DUAL
                     UNION ALL
                     SELECT 5 ca, 'із них: чоловіки' cb FROM DUAL
                     UNION ALL
                     SELECT 6                                                                                                                            ca,
                            'із рядка 4: допомога при народженні дитини за заявами осіб, які надійшли з використанням електронного цифрового підпису'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 7                                                                 ca,
                            'допомога на дітей, над якими встановлено опіку чи піклування'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 8                                  ca,
                               'із них:'
                            || CHR (10)
                            || 'на дітей віком  до 6 років'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 9 ca, 'на дітей віком від 6  до 18 років' cb
                       FROM DUAL
                     UNION ALL
                     SELECT 10 ca, 'допомога на дітей одиноким матерям' cb
                       FROM DUAL
                     UNION ALL
                     SELECT 11                                 ca,
                               '"із них:'
                            || CHR (10)
                            || 'на дітей віком  до 6 років'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 12 ca, 'на дітей віком від 6  до 18 років' cb
                       FROM DUAL
                     UNION ALL
                     SELECT 13                                                        ca,
                            'на дітей віком від 18  до 23 років за умови навчання'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 14                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  ca,
                            'допомога на дітей, хворих на тяжкі перинатальні ураження нервової системи, тяжкі вроджені вади розвитку, рідкісні орфанні захворювання, онкологічні, онкогематологічні захворювання, дитячий церебральний параліч, тяжкі психічні розлади, цукровий діабет I типу (інсулінозалежний), гострі або хронічні захворювання нирок IV ступеня, на дитину, яка отримала тяжку травму, потребує трансплантації органа, потребує паліативної допомоги, яким не встановлено інвалідність'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 15                                                             ca,
                            'Допомога на дітей, які виховуються у багатодітних сім''ях'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 16                                                                                  ca,
                            'Тимчасова державна допомога дітям, батьки яких ухиляються від сплати аліментів'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 17 ca, 'Разом' cb FROM DUAL),
                appl
                AS
                    (SELECT a.ap_id,
                            ap.app_sc                      ap_sc,
                            (SELECT MAX (
                                        CASE
                                            WHEN scb_dt >
                                                 ADD_MONTHS (a.ap_reg_dt,
                                                             -72)
                                            THEN
                                                6
                                            WHEN scb_dt >
                                                 ADD_MONTHS (a.ap_reg_dt,
                                                             -216)
                                            THEN
                                                18
                                            WHEN     scb_dt >
                                                     ADD_MONTHS (a.ap_reg_dt,
                                                                 -276)
                                                 AND EXISTS
                                                         (SELECT 1 -- Довідка про денну і дуальну форму навчання
                                                            FROM uss_esr.ap_document
                                                                 d,
                                                                 uss_esr.ap_document_attr
                                                                 da
                                                           WHERE     ap.app_ap =
                                                                     d.apd_ap
                                                                 AND ap.app_id =
                                                                     d.apd_app
                                                                 AND d.apd_id =
                                                                     da.apda_apd
                                                                 AND da.apda_nda =
                                                                     690
                                                                 AND da.history_status =
                                                                     'A'
                                                                 AND da.apda_val_string IN
                                                                         ('D',
                                                                          'U'))
                                            THEN
                                                23
                                            ELSE
                                                100
                                        END)
                               FROM uss_person.v_sc_birth scb
                              WHERE scb_sc = ap.app_sc)    ap_year_gr,
                            CASE
                                WHEN s.aps_nst = 251
                                THEN
                                    0
                                WHEN EXISTS
                                         (SELECT 1
                                            FROM uss_esr.ap_person         pp,
                                                 uss_person.v_sc_identity  id
                                           WHERE     pp.app_ap = a.ap_id
                                                 AND pp.app_sc = id.sci_sc
                                                 AND pp.app_tp = 'Z'
                                                 AND pp.history_status = 'A'
                                                 AND id.sci_gender = 'M')
                                THEN
                                    1
                                ELSE
                                    0
                            END                            is_man,
                            CASE s.aps_nst
                                WHEN 251 THEN 2
                                WHEN 269 THEN 3
                                WHEN 250 THEN 4
                                WHEN 268 THEN 7
                                WHEN 267 THEN 10
                                WHEN 265 THEN 14
                                WHEN 862 THEN 15
                                ELSE 0
                            END                            rep_row
                       FROM uss_esr.appeal  a
                            INNER JOIN org ON i_org = a.com_org
                            INNER JOIN uss_esr.ap_person ap
                                ON     ap.app_ap = a.ap_id
                                   AND ap.history_status = 'A'
                            INNER JOIN uss_esr.ap_service s
                                ON s.aps_ap = a.ap_id
                      WHERE     a.ap_reg_dt >= l_dty
                            AND a.ap_reg_dt < l_dte
                            AND s.aps_nst IN (250, -- Допомога при народженні дитини
                                              251, -- Допомога у зв’язку з вагітністю та пологами
                                              265, -- Допомога особі, яка доглядає за хворою дитиною
                                              267, -- Допомога на дітей одиноким матерям
                                              268, -- Допомога на дітей, над якими встановлено опіку чи піклування
                                              269, -- Допомога при усиновленні дитини
                                              862)),
                assign
                AS
                    (  SELECT pc_id
                                  a_pc,
                              d.pd_id
                                  a_pd,
                              d.pd_ap
                                  a_ap,
                              SUM (pdp_sum)
                                  a_assing,
                              -- максимальний                     Допомога на дітей одиноким матерям
                              MAX (CASE
                                       WHEN TRUNC (pdp_sum) IN (2272, -- до 6 років
                                                                2833, -- від 6 до 18 років
                                                                2684, -- від 18 до 23 років
                                                                -- Допомога на дітей, над якими встановлено опіку чи піклування
                                                                5680, -- до 6 років (2,5 ПМ)
                                                                7952, -- до 6 років (для дітей з інвалідністю – 3,5 ПМ)
                                                                7082, -- від 6 до 18 років (2,5 ПМ)
                                                                9915 -- від 6 до 18 років (для дітей з інвалідністю - 3,5 ПМ)
                                                                    )
                                       THEN
                                           1
                                       ELSE
                                           0
                                   END)
                                  max_dop,
                              ROW_NUMBER ()
                                  OVER (PARTITION BY d.pd_id ORDER BY NULL)
                                  pd_rn,
                              d.pd_dt,
                              CASE
                                  WHEN st.nst_id = 251
                                  THEN
                                      0
                                  WHEN EXISTS
                                           (SELECT 1
                                              FROM uss_esr.ap_person       pp,
                                                   uss_person.v_sc_identity id
                                             WHERE     pp.app_ap = d.pd_ap
                                                   AND pp.app_sc = id.sci_sc
                                                   AND pp.app_tp = 'Z'
                                                   AND pp.history_status = 'A'
                                                   AND id.sci_gender = 'M')
                                  THEN
                                      1
                                  ELSE
                                      0
                              END
                                  is_man,
                              CASE st.nst_id
                                  WHEN 251 THEN 2
                                  WHEN 269 THEN 3
                                  WHEN 250 THEN 4
                                  WHEN 268 THEN 7
                                  WHEN 267 THEN 10
                                  WHEN 265 THEN 14
                                  WHEN 862 THEN 15
                                  ELSE 0
                              END
                                  rep_row
                         FROM ikis_sys.v_opfu o
                              INNER JOIN org ON i_org = org_id
                              INNER JOIN uss_esr.personalcase pc
                                  ON pc.com_org = o.org_id
                              INNER JOIN uss_esr.pc_decision d
                                  ON d.pd_pc = pc.pc_id
                              INNER JOIN uss_esr.pd_payment pp
                                  ON pp.pdp_pd = d.pd_id
                              INNER JOIN uss_esr.pd_accrual_period pdap
                                  ON pdap.pdap_pd = d.pd_id
                              INNER JOIN uss_ndi.v_Ndi_Npt_Config nnc
                                  ON nnc.nptc_npt = pp.pdp_npt
                              INNER JOIN uss_ndi.v_ndi_service_type st
                                  ON st.nst_id = nnc.nptc_nst
                        WHERE     o.org_to = 32
                              AND pp.history_status = 'A'
                              AND pdap.history_status = 'A'
                              AND p_start_dt BETWEEN TRUNC (pdap.pdap_start_dt,
                                                            'mm')
                                                 AND pdap.pdap_stop_dt
                              AND p_start_dt BETWEEN TRUNC (pp.pdp_start_dt,
                                                            'mm')
                                                 AND pp.pdp_stop_dt
                              AND st.nst_id IN (250, -- Допомога при народженні дитини
                                                251, -- Допомога у зв’язку з вагітністю та пологами
                                                265, -- Допомога особі, яка доглядає за хворою дитиною
                                                267, -- Допомога на дітей одиноким матерям
                                                268, -- Допомога на дітей, над якими встановлено опіку чи піклування
                                                269, -- Допомога при усиновленні дитини
                                                862) -- Допомога на дітей, які виховуються у багатодітних сім'ях
                     GROUP BY pc_id,
                              d.pd_id,
                              d.pd_dt,
                              d.pd_ap,
                              st.nst_id),
                nrh
                AS
                    (  SELECT ac.ac_month
                                  dt_r,
                              ac.ac_pc
                                  x_pc,
                              dnet$payment_reports.getCntFmlByPC (ac.ac_pc,
                                                                  st.nst_id,
                                                                  ac.ac_month,
                                                                  2)
                                  x_cnt_child,
                              dnet$payment_reports.getCntFmlByPC (ac.ac_pc,
                                                                  st.nst_id,
                                                                  ac.ac_month,
                                                                  3)
                                  x_cnt_child_max,
                              --d.acd_pd                                                x_pd,
                              SUM (
                                    uss_esr.api$accrual.xsign (d.acd_op)
                                  * d.acd_sum)
                                  x_narah,
                              SUM (
                                    uss_esr.api$accrual.xsign (d.acd_op)
                                  * NVL2 (d.acd_prsd, 0, d.acd_sum))
                                  x_borg,
                              MAX (
                                  CASE
                                      WHEN TRUNC (acd_sum) IN (2272, -- до 6 років
                                                               2833, -- від 6 до 18 років
                                                               2684, -- від 18 до 23 років
                                                               -- Допомога на дітей, над якими встановлено опіку чи піклування
                                                               5680, -- до 6 років (2,5 ПМ)
                                                               7952, -- до 6 років (для дітей з інвалідністю – 3,5 ПМ)
                                                               7082, -- від 6 до 18 років (2,5 ПМ)
                                                               9915 -- від 6 до 18 років (для дітей з інвалідністю - 3,5 ПМ)
                                                                   )
                                      THEN
                                          1
                                      WHEN EXISTS
                                               (SELECT 1
                                                  FROM uss_esr.pd_payment pp,
                                                       uss_esr.pd_detail dd,
                                                       uss_esr.pd_family f
                                                 WHERE     pp.pdp_pd = d.acd_pd
                                                       AND f.pdf_pd = d.acd_pd
                                                       AND pp.pdp_id =
                                                           dd.pdd_pdp
                                                       AND f.pdf_id =
                                                           dd.pdd_key
                                                       AND pp.history_status =
                                                           'A'
                                                       AND TRUNC (dd.pdd_value) IN
                                                               (2272,
                                                                2833,
                                                                2684,
                                                                5680,
                                                                7952,
                                                                7082,
                                                                9915))
                                      THEN
                                          1
                                      ELSE
                                          0
                                  END)
                                  x_max_dop,
                              MAX (
                                  CASE
                                      WHEN st.nst_id = 251
                                      THEN
                                          0
                                      WHEN EXISTS
                                               (SELECT 1
                                                  FROM uss_esr.pc_decision pd,
                                                       uss_esr.ap_person  pp,
                                                       uss_person.v_sc_identity
                                                       id
                                                 WHERE     pd.pd_id = d.acd_pd
                                                       AND pp.app_ap = pd.pd_ap
                                                       AND pp.app_sc =
                                                           id.sci_sc
                                                       AND pp.app_tp = 'Z'
                                                       AND pp.history_status =
                                                           'A'
                                                       AND id.sci_gender = 'M')
                                      THEN
                                          1
                                      ELSE
                                          0
                                  END)
                                  is_man,
                              CASE st.nst_id
                                  WHEN 251 THEN 2
                                  WHEN 269 THEN 3
                                  WHEN 250 THEN 4
                                  WHEN 268 THEN 7
                                  WHEN 267 THEN 10
                                  WHEN 265 THEN 14
                                  WHEN 862 THEN 15
                                  ELSE 0
                              END
                                  rep_row
                         FROM ikis_sys.v_opfu o
                              INNER JOIN org ON i_org = o.org_id
                              INNER JOIN uss_esr.accrual ac
                                  ON ac.com_org = o.org_id
                              INNER JOIN uss_esr.ac_detail d
                                  ON     d.acd_ac = ac.ac_id
                                     AND d.history_status = 'A'
                              INNER JOIN uss_ndi.v_ndi_op op
                                  ON op.op_id = d.acd_op
                              INNER JOIN uss_ndi.v_Ndi_Npt_Config nnc
                                  ON nnc.nptc_npt = d.acd_npt
                              INNER JOIN uss_ndi.v_ndi_service_type st
                                  ON st.nst_id = nnc.nptc_nst
                        WHERE     o.org_to = 32
                              AND ac.ac_month >= l_dtb
                              AND ac.ac_month <= l_dte
                              AND d.acd_start_dt BETWEEN ac.ac_month
                                                     AND TRUNC (
                                                             LAST_DAY (
                                                                 ac.ac_month))
                              AND (d.acd_op IN (1, 2, 3) OR op.op_tp1 IN ('NR'))
                              AND ac.history_status = 'A'
                              AND st.nst_id IN (250, -- Допомога при народженні дитини
                                                251, -- Допомога у зв’язку з вагітністю та пологами
                                                265, -- Допомога особі, яка доглядає за хворою дитиною
                                                267, -- Допомога на дітей одиноким матерям
                                                268, -- Допомога на дітей, над якими встановлено опіку чи піклування
                                                269, -- Допомога при усиновленні дитини
                                                862) -- Допомога на дітей, які виховуються у багатодітних сім'ях
                     GROUP BY ac.ac_month, st.nst_id, ac.ac_pc),
                payed
                AS
                    (  SELECT pr.pr_month       dt_r,
                              --prs_pc          s_pc,
                              SUM (prsd_sum)    s_sum,
                              CASE st.nst_id
                                  WHEN 251 THEN 2
                                  WHEN 269 THEN 3
                                  WHEN 250 THEN 4
                                  WHEN 268 THEN 7
                                  WHEN 267 THEN 10
                                  WHEN 265 THEN 14
                                  WHEN 862 THEN 15
                                  ELSE 0
                              END               rep_row
                         FROM ikis_sys.v_opfu o
                              INNER JOIN org ON i_org = org_id
                              INNER JOIN uss_esr.payroll pr
                                  ON pr.com_org = o.org_id
                              INNER JOIN uss_esr.pr_sheet s
                                  ON s.prs_pr = pr.pr_id
                              INNER JOIN uss_esr.pr_sheet_detail sd
                                  ON sd.prsd_prs = s.prs_id
                              INNER JOIN uss_esr.v_personalcase pc
                                  ON pc.pc_id = s.prs_pc
                              INNER JOIN uss_ndi.v_Ndi_Npt_Config nnc
                                  ON nnc.nptc_npt = sd.prsd_npt
                              INNER JOIN uss_ndi.v_ndi_service_type st
                                  ON st.nst_id = nnc.nptc_nst
                        WHERE     o.org_to = 32
                              AND pr.pr_month >= l_dtb
                              AND pr.pr_month <= l_dte
                              AND sd.prsd_month = pr.pr_month
                              AND s.prs_st IN ('NA', 'KV1', 'KV2')
                              AND pr.pr_st IN ('F')
                              AND sd.prsd_tp IN ('PWI', 'RDN')
                              AND st.nst_id IN (250, -- Допомога при народженні дитини
                                                251, -- Допомога у зв’язку з вагітністю та пологами
                                                265, -- Допомога особі, яка доглядає за хворою дитиною
                                                267, -- Допомога на дітей одиноким матерям
                                                268, -- Допомога на дітей, над якими встановлено опіку чи піклування
                                                269, -- Допомога при усиновленні дитини
                                                862) -- Допомога на дітей, які виховуються у багатодітних сім'ях
                              AND 1 = 0 -- Поки не вибираємо (підставляємо, як нараховано мінус борг)
                     GROUP BY pr.pr_month, st.nst_id)
              SELECT rpt.ca,
                     rpt.cb,
                     -- a.a_assing,
                     -- a.a_assing_m,
                     n.x_narah_y                  a_assing,
                     n.x_narah_m                  a_assing_m,
                     a.cnt_fml_6y,
                     a.cnt_fml_18y,
                     a.cnt_fml_23y,
                     n.x_narah,
                     n.x_borg,
                     -- p.a_payed,
                     -- p.a_payed_m
                     n.x_narah_y - n.x_borg_y     a_payed,
                     n.x_narah_m - n.x_borg_m     a_payed_m,
                     ap.appl_cnt,
                     a.a_cnt_y,
                     n.x_cnt_m,
                     n.x_cnt_m_max,
                     n.x_cnt_child,
                     n.x_cnt_child_max
                FROM rpt
                     LEFT JOIN
                     (  SELECT rep_row,
                               COUNT (
                                   DISTINCT
                                       CASE
                                           WHEN pd_dt >= l_dty
                                           THEN
                                               a_pc
                                           ELSE
                                               NULL
                                       END)                                         a_cnt_y,
                               SUM (
                                   (SELECT COUNT (DISTINCT pdf_sc)
                                      FROM uss_esr.pd_family f
                                     WHERE     f.pdf_pd = a_pd
                                           AND pd_dt >= l_dty
                                           AND pd_rn = 1))                          cnt_fml_y,
                               SUM (
                                   (SELECT COUNT (DISTINCT pdf_sc)
                                      FROM uss_esr.pd_family f
                                     WHERE     f.pdf_pd = a_pd
                                           AND f.pdf_birth_dt >
                                               ADD_MONTHS (p_start_dt, -72)
                                           AND pd_rn = 1))                          cnt_fml_6y,
                               SUM (
                                   (SELECT COUNT (DISTINCT pdf_sc)
                                      FROM uss_esr.pd_family f
                                     WHERE     f.pdf_pd = a_pd
                                           AND f.pdf_birth_dt >
                                               ADD_MONTHS (p_start_dt, -216)
                                           AND f.pdf_birth_dt <=
                                               ADD_MONTHS (p_start_dt, -72)
                                           AND pd_rn = 1))                          cnt_fml_18y,
                               SUM (
                                   (SELECT COUNT (DISTINCT pdf_sc)
                                      FROM uss_esr.pd_family f
                                     WHERE     f.pdf_pd = a_pd
                                           AND f.pdf_birth_dt >
                                               ADD_MONTHS (p_start_dt, -276)
                                           AND f.pdf_birth_dt <=
                                               ADD_MONTHS (p_start_dt, -216)
                                           AND pd_rn = 1
                                           AND EXISTS
                                                   (SELECT 1 -- Довідка про денну і дуальну форму навчання
                                                      FROM uss_esr.ap_person pp,
                                                           uss_esr.ap_document d,
                                                           uss_esr.ap_document_attr
                                                           da
                                                     WHERE     pp.app_ap = a_ap
                                                           AND pp.app_sc =
                                                               f.pdf_sc
                                                           AND pp.app_ap =
                                                               d.apd_ap
                                                           AND pp.app_id =
                                                               d.apd_app
                                                           AND d.apd_id =
                                                               da.apda_apd
                                                           AND da.apda_nda = 690
                                                           AND da.history_status =
                                                               'A'
                                                           AND da.apda_val_string IN
                                                                   ('D', 'U'))))    cnt_fml_23y
                          FROM assign
                         WHERE 1 = 1
                      GROUP BY rep_row
                      UNION ALL              -- допомога при народженні дитини
                      SELECT 5               rep_row       -- із них: чоловіки
                                                    ,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN pd_dt >= l_dty THEN a_pc
                                         ELSE NULL
                                     END)    a_cnt_y,
                             0               cnt_fml_y,
                             0               cnt_fml_6y,
                             0               cnt_fml_18y,
                             0               cnt_fml_23y
                        FROM assign
                       WHERE rep_row = 4 AND is_man = 1
                      UNION ALL
                        SELECT CASE WHEN rep_row = 7 THEN 8 ELSE 11 END
                                   rep_row,
                               COUNT (
                                   DISTINCT
                                       CASE
                                           WHEN pd_dt >= l_dty THEN a_pc
                                           ELSE NULL
                                       END)
                                   a_cnt_y,
                               0
                                   cnt_fml_y,
                               0
                                   cnt_fml_6y,
                               0
                                   cnt_fml_18y,
                               0
                                   cnt_fml_23y
                          FROM assign
                         WHERE     rep_row IN (7, 10)
                               AND EXISTS
                                       (SELECT 1
                                          FROM uss_esr.pd_family f
                                         WHERE     f.pdf_pd = a_pd
                                               AND f.pdf_birth_dt >
                                                   ADD_MONTHS (p_start_dt, -72))
                      GROUP BY rep_row
                      UNION ALL
                        SELECT CASE WHEN rep_row = 7 THEN 9 ELSE 12 END
                                   rep_row,
                               COUNT (
                                   DISTINCT
                                       CASE
                                           WHEN pd_dt >= l_dty THEN a_pc
                                           ELSE NULL
                                       END)
                                   a_cnt_y,
                               0
                                   cnt_fml_y,
                               0
                                   cnt_fml_6y,
                               0
                                   cnt_fml_18y,
                               0
                                   cnt_fml_23y
                          FROM assign
                         WHERE     rep_row IN (7, 10)
                               AND EXISTS
                                       (SELECT 1
                                          FROM uss_esr.pd_family f
                                         WHERE     f.pdf_pd = a_pd
                                               AND f.pdf_birth_dt >
                                                   ADD_MONTHS (p_start_dt, -216)
                                               AND f.pdf_birth_dt <=
                                                   ADD_MONTHS (p_start_dt, -72))
                      GROUP BY rep_row
                      UNION ALL
                      SELECT 13              rep_row,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN pd_dt >= l_dty THEN a_pc
                                         ELSE NULL
                                     END)    a_cnt_y,
                             0               cnt_fml_y,
                             0               cnt_fml_6y,
                             0               cnt_fml_18y,
                             0               cnt_fml_23y
                        FROM assign
                       WHERE     rep_row = 10
                             AND EXISTS
                                     (SELECT 1
                                        FROM uss_esr.pd_family f
                                       WHERE     f.pdf_pd = a_pd
                                             AND f.pdf_birth_dt >
                                                 ADD_MONTHS (p_start_dt, -276)
                                             AND f.pdf_birth_dt <=
                                                 ADD_MONTHS (p_start_dt, -216)
                                             AND EXISTS
                                                     (SELECT 1 -- Довідка про денну і дуальну форму навчання
                                                        FROM uss_esr.ap_person
                                                             pp,
                                                             uss_esr.ap_document
                                                             d,
                                                             uss_esr.ap_document_attr
                                                             da
                                                       WHERE     pp.app_ap =
                                                                 a_ap
                                                             AND pp.app_sc =
                                                                 f.pdf_sc
                                                             AND pp.app_ap =
                                                                 d.apd_ap
                                                             AND pp.app_id =
                                                                 d.apd_app
                                                             AND d.apd_id =
                                                                 da.apda_apd
                                                             AND da.apda_nda =
                                                                 690
                                                             AND da.history_status =
                                                                 'A'
                                                             AND da.apda_val_string IN
                                                                     ('D', 'U'))))
                     a
                         ON a.rep_row = rpt.ca
                     LEFT JOIN
                     (  SELECT rep_row,
                               COUNT (DISTINCT x_pc)    x_cnt,
                               COUNT (
                                   DISTINCT
                                       CASE
                                           WHEN dt_r = TRUNC (p_start_dt, 'MM')
                                           THEN
                                               x_pc
                                           ELSE
                                               NULL
                                       END)             x_cnt_m,
                               COUNT (
                                   DISTINCT
                                       CASE
                                           WHEN     dt_r =
                                                    TRUNC (p_start_dt, 'MM')
                                                AND x_max_dop > 0
                                           THEN
                                               x_pc
                                           ELSE
                                               NULL
                                       END)             x_cnt_m_max,
                               SUM (
                                   CASE
                                       WHEN dt_r = TRUNC (p_start_dt, 'MM')
                                       THEN
                                           x_cnt_child
                                       ELSE
                                           0
                                   END)                 x_cnt_child,
                               SUM (
                                   CASE
                                       WHEN dt_r = TRUNC (p_start_dt, 'MM')
                                       THEN
                                           x_cnt_child_max
                                       ELSE
                                           0
                                   END)                 x_cnt_child_max,
                               SUM (x_narah)            x_narah,
                               SUM (x_borg)             x_borg,
                               SUM (
                                   CASE
                                       WHEN dt_r < TRUNC (p_start_dt, 'MM')
                                       THEN
                                           x_narah
                                       ELSE
                                           0
                                   END)                 x_narah_y,
                               SUM (
                                   CASE
                                       WHEN dt_r = TRUNC (p_start_dt, 'MM')
                                       THEN
                                           x_narah
                                       ELSE
                                           0
                                   END)                 x_narah_m,
                               SUM (
                                   CASE
                                       WHEN dt_r < TRUNC (p_start_dt, 'MM')
                                       THEN
                                           x_borg
                                       ELSE
                                           0
                                   END)                 x_borg_y,
                               SUM (
                                   CASE
                                       WHEN dt_r = TRUNC (p_start_dt, 'MM')
                                       THEN
                                           x_borg
                                       ELSE
                                           0
                                   END)                 x_borg_m
                          FROM nrh
                         WHERE 1 = 1
                      GROUP BY rep_row
                      UNION ALL              -- допомога при народженні дитини
                      SELECT 5                        rep_row -- із них: чоловіки
                                                             ,
                             COUNT (DISTINCT x_pc)    x_cnt,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN dt_r = TRUNC (p_start_dt, 'MM')
                                         THEN
                                             x_pc
                                         ELSE
                                             NULL
                                     END)             x_cnt_m,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN     dt_r =
                                                  TRUNC (p_start_dt, 'MM')
                                              AND x_max_dop > 0
                                         THEN
                                             x_pc
                                         ELSE
                                             NULL
                                     END)             x_cnt_m_max,
                             SUM (
                                 CASE
                                     WHEN dt_r = TRUNC (p_start_dt, 'MM')
                                     THEN
                                         x_cnt_child
                                     ELSE
                                         0
                                 END)                 x_cnt_child,
                             SUM (
                                 CASE
                                     WHEN dt_r = TRUNC (p_start_dt, 'MM')
                                     THEN
                                         x_cnt_child_max
                                     ELSE
                                         0
                                 END)                 x_cnt_child_max,
                             SUM (x_narah)            x_narah,
                             SUM (x_borg)             x_borg,
                             SUM (
                                 CASE
                                     WHEN dt_r < TRUNC (p_start_dt, 'MM')
                                     THEN
                                         x_narah
                                     ELSE
                                         0
                                 END)                 x_narah_y,
                             SUM (
                                 CASE
                                     WHEN dt_r = TRUNC (p_start_dt, 'MM')
                                     THEN
                                         x_narah
                                     ELSE
                                         0
                                 END)                 x_narah_m,
                             SUM (
                                 CASE
                                     WHEN dt_r < TRUNC (p_start_dt, 'MM')
                                     THEN
                                         x_borg
                                     ELSE
                                         0
                                 END)                 x_borg_y,
                             SUM (
                                 CASE
                                     WHEN dt_r = TRUNC (p_start_dt, 'MM')
                                     THEN
                                         x_borg
                                     ELSE
                                         0
                                 END)                 x_borg_m
                        FROM nrh
                       WHERE rep_row = 4 AND is_man = 1
                      UNION ALL
                        SELECT CASE WHEN rep_row = 7 THEN 8 ELSE 11 END
                                   rep_row,
                               0
                                   x_cnt,
                               COUNT (DISTINCT x_pc)
                                   x_cnt_m,
                               COUNT (
                                   DISTINCT
                                       CASE
                                           WHEN x_max_dop > 0 THEN x_pc
                                           ELSE NULL
                                       END)
                                   x_cnt_m_max,
                               SUM (x_cnt_child)
                                   x_cnt_child,
                               SUM (x_cnt_child_max)
                                   x_cnt_child_max,
                               0
                                   x_narah,
                               0
                                   x_borg,
                               0
                                   x_narah_y,
                               0
                                   x_narah_m,
                               0
                                   x_borg_y,
                               0
                                   x_borg_m
                          FROM nrh
                         WHERE     rep_row IN (7, 10)
                               AND dt_r = TRUNC (p_start_dt, 'MM')
                               AND EXISTS
                                       (SELECT 1
                                          FROM uss_esr.pc_decision pd
                                               INNER JOIN uss_esr.pd_family f
                                                   ON f.pdf_pd = pd.pd_id
                                         WHERE     pd.pd_nst =
                                                   CASE
                                                       WHEN rep_row = 7 THEN 268
                                                       ELSE 267
                                                   END
                                               AND f.pdf_birth_dt >
                                                   ADD_MONTHS (dt_r, -72)
                                               AND pd.pd_pc = x_pc)
                      GROUP BY rep_row
                      UNION ALL
                        SELECT CASE WHEN rep_row = 7 THEN 9 ELSE 12 END
                                   rep_row,
                               0
                                   x_cnt,
                               COUNT (DISTINCT x_pc)
                                   x_cnt_m,
                               COUNT (
                                   DISTINCT
                                       CASE
                                           WHEN x_max_dop > 0 THEN x_pc
                                           ELSE NULL
                                       END)
                                   x_cnt_m_max,
                               SUM (x_cnt_child)
                                   x_cnt_child,
                               SUM (x_cnt_child_max)
                                   x_cnt_child_max,
                               0
                                   x_narah,
                               0
                                   x_borg,
                               0
                                   x_narah_y,
                               0
                                   x_narah_m,
                               0
                                   x_borg_y,
                               0
                                   x_borg_m
                          FROM nrh
                         WHERE     rep_row IN (7, 10)
                               AND dt_r = TRUNC (p_start_dt, 'MM')
                               AND EXISTS
                                       (SELECT 1
                                          FROM uss_esr.pc_decision pd
                                               INNER JOIN uss_esr.pd_family f
                                                   ON f.pdf_pd = pd.pd_id
                                         WHERE     pd.pd_nst =
                                                   CASE
                                                       WHEN rep_row = 7 THEN 268
                                                       ELSE 267
                                                   END
                                               AND f.pdf_birth_dt >
                                                   ADD_MONTHS (dt_r, -216)
                                               AND f.pdf_birth_dt <=
                                                   ADD_MONTHS (dt_r, -72)
                                               AND pd.pd_pc = x_pc)
                      GROUP BY rep_row
                      UNION ALL
                      SELECT 13                       rep_row,
                             0                        x_cnt,
                             COUNT (DISTINCT x_pc)    x_cnt_m,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN x_max_dop > 0 THEN x_pc
                                         ELSE NULL
                                     END)             x_cnt_m_max,
                             SUM (x_cnt_child)        x_cnt_child,
                             SUM (x_cnt_child_max)    x_cnt_child_max,
                             0                        x_narah,
                             0                        x_borg,
                             0                        x_narah_y,
                             0                        x_narah_m,
                             0                        x_borg_y,
                             0                        x_borg_m
                        FROM nrh
                       WHERE     rep_row = 10
                             AND dt_r = TRUNC (p_start_dt, 'MM')
                             AND EXISTS
                                     (SELECT 1
                                        FROM uss_esr.pc_decision pd
                                             INNER JOIN uss_esr.pd_family f
                                                 ON f.pdf_pd = pd.pd_id
                                       WHERE     pd.pd_nst = 267
                                             AND f.pdf_birth_dt >
                                                 ADD_MONTHS (dt_r, -276)
                                             AND f.pdf_birth_dt <=
                                                 ADD_MONTHS (dt_r, -216)
                                             AND EXISTS
                                                     (SELECT 1 -- Довідка про денну і дуальну форму навчання
                                                        FROM uss_esr.ap_person
                                                             pp,
                                                             uss_esr.ap_document
                                                             d,
                                                             uss_esr.ap_document_attr
                                                             da
                                                       WHERE     pp.app_ap =
                                                                 pd.pd_ap
                                                             AND pp.app_sc =
                                                                 f.pdf_sc
                                                             AND pp.app_ap =
                                                                 d.apd_ap
                                                             AND pp.app_id =
                                                                 d.apd_app
                                                             AND d.apd_id =
                                                                 da.apda_apd
                                                             AND da.apda_nda =
                                                                 690
                                                             AND da.history_status =
                                                                 'A'
                                                             AND da.apda_val_string IN
                                                                     ('D', 'U'))
                                             AND pd.pd_pc = x_pc)) n
                         ON n.rep_row = rpt.ca
                     LEFT JOIN
                     (  SELECT rep_row,
                               SUM (
                                   CASE
                                       WHEN dt_r < TRUNC (p_start_dt, 'MM')
                                       THEN
                                           s_sum
                                       ELSE
                                           0
                                   END)    a_payed,
                               SUM (
                                   CASE
                                       WHEN dt_r = TRUNC (p_start_dt, 'MM')
                                       THEN
                                           s_sum
                                       ELSE
                                           0
                                   END)    a_payed_m
                          FROM payed
                         WHERE 1 = 1
                      GROUP BY rep_row) p
                         ON p.rep_row = rpt.ca
                     LEFT JOIN
                     (  SELECT rep_row, COUNT (DISTINCT ap_id) appl_cnt
                          FROM appl
                         WHERE 1 = 1
                      GROUP BY rep_row
                      UNION ALL
                      -- допомога при народженні дитини
                      SELECT 5 rep_row                     -- із них: чоловіки
                                      , COUNT (DISTINCT ap_id) appl_cnt
                        FROM appl
                       WHERE rep_row = 4 AND is_man = 1
                      UNION ALL
                      SELECT 8 rep_row           -- на дітей віком  до 6 років
                                      , COUNT (DISTINCT ap_id) appl_cnt
                        FROM appl
                       WHERE rep_row = 7 AND ap_year_gr = 6
                      UNION ALL
                      SELECT 9 rep_row    -- на дітей віком від 6  до 18 років
                                      , COUNT (DISTINCT ap_id) appl_cnt
                        FROM appl
                       WHERE rep_row = 7 AND ap_year_gr = 18
                      UNION ALL
                      SELECT 11 rep_row, COUNT (DISTINCT ap_id) appl_cnt
                        FROM appl
                       WHERE rep_row = 10 AND ap_year_gr = 6
                      UNION ALL
                      SELECT 12 rep_row, COUNT (DISTINCT ap_id) appl_cnt
                        FROM appl
                       WHERE rep_row = 10 AND ap_year_gr = 18
                      UNION ALL
                      SELECT 13 rep_row, COUNT (DISTINCT ap_id) appl_cnt
                        FROM appl
                       WHERE rep_row = 10 AND ap_year_gr = 23) ap
                         ON ap.rep_row = rpt.ca
            ORDER BY 1;

        UPDATE tmp_univ_rpt_data
           SET x_id5 =
                   (SELECT NVL (SUM (x_id5), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (8, 9)),
               x_id6 =
                   (SELECT NVL (SUM (x_id6), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (8, 9)),
               x_sum7 =
                   (SELECT NVL (SUM (x_sum7), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (8, 9)),
               x_sum8 =
                   (SELECT NVL (SUM (x_sum8), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (8, 9))
         WHERE x_id1 = 7;

        UPDATE tmp_univ_rpt_data
           SET x_id5 =
                   (SELECT NVL (SUM (x_id5), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (11, 12, 13)),
               x_id6 =
                   (SELECT NVL (SUM (x_id6), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (11, 12, 13)),
               x_sum7 =
                   (SELECT NVL (SUM (x_sum7), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (11, 12, 13)),
               x_sum8 =
                   (SELECT NVL (SUM (x_sum8), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (11, 12, 13))
         WHERE x_id1 = 10;

        UPDATE tmp_univ_rpt_data
           SET x_sum1 =
                   (SELECT NVL (SUM (x_sum1), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (2,
                                     3,
                                     4,
                                     7,
                                     10,
                                     14)),
               x_sum2 =
                   (SELECT NVL (SUM (x_sum2), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (2,
                                     3,
                                     4,
                                     7,
                                     10,
                                     14)),
               x_sum3 =
                   (SELECT NVL (SUM (x_sum3), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (2,
                                     3,
                                     4,
                                     7,
                                     10,
                                     14)),
               x_sum4 =
                   (SELECT NVL (SUM (x_sum4), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (2,
                                     3,
                                     4,
                                     7,
                                     10,
                                     14)),
               x_sum5 =
                   (SELECT NVL (SUM (x_sum5), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (2,
                                     3,
                                     4,
                                     7,
                                     10,
                                     14)),
               x_sum6 =
                   (SELECT NVL (SUM (x_sum6), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (2,
                                     3,
                                     4,
                                     7,
                                     10,
                                     14)),
               x_sum7 =
                   (SELECT NVL (SUM (x_sum7), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (2,
                                     3,
                                     4,
                                     7,
                                     10,
                                     14)),
               x_sum8 =
                   (SELECT NVL (SUM (x_sum8), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (7, 10)),
               x_sum9 =
                   (SELECT NVL (SUM (x_sum9), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (3,
                                     4,
                                     7,
                                     10,
                                     14)),
               x_sum10 =
                   (SELECT NVL (SUM (x_sum10), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (7, 10)),
               x_id5 =
                   (SELECT NVL (SUM (x_id5), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (2,
                                     3,
                                     4,
                                     7,
                                     10,
                                     14)),
               x_id6 =
                   (SELECT NVL (SUM (x_id6), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (2,
                                     3,
                                     4,
                                     7,
                                     10,
                                     14))
         WHERE x_id1 = 1;

        UPDATE tmp_univ_rpt_data
           SET x_sum1 =
                   (SELECT NVL (SUM (x_sum1), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (1, 15, 16)),
               x_sum2 =
                   (SELECT NVL (SUM (x_sum2), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (1, 15, 16)),
               x_sum3 =
                   (SELECT NVL (SUM (x_sum3), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (1, 15, 16)),
               x_sum4 =
                   (SELECT NVL (SUM (x_sum4), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (1, 15, 16)),
               x_sum5 =
                   (SELECT NVL (SUM (x_sum5), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (1, 15, 16)),
               x_sum6 =
                   (SELECT NVL (SUM (x_sum6), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (1, 15, 16)),
               x_sum7 =
                   (SELECT NVL (SUM (x_sum7), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (1, 15, 16)),
               x_sum8 =
                   (SELECT NVL (SUM (x_sum8), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (1)),
               x_sum9 =
                   (SELECT NVL (SUM (x_sum9), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (1, 15, 16)),
               x_sum10 =
                   (SELECT NVL (SUM (x_sum10), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (1)),
               x_id5 =
                   (SELECT NVL (SUM (x_id5), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (1, 15, 16)),
               x_id6 =
                   (SELECT NVL (SUM (x_id6), 0)
                      FROM tmp_univ_rpt_data
                     WHERE x_id1 IN (1, 15, 16))
         WHERE x_id1 = 17;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
       <Row ss:AutoFitHeight="0" ss:Height="10">
        <Cell ss:StyleID="s200"><Data ss:Type="Number">1</Data></Cell>
        <Cell ss:MergeAcross="1" ss:StyleID="s202"><Data ss:Type="String">Всього по  допомозі сім''ям з дітьми (ряд.2 + ряд.3 + ряд.4 + ряд.7 + ряд.10+ ряд.14)</Data></Cell>
        <Cell ss:StyleID="s206"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_id5, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s207"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_id6, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s208"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum7, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s209"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum8, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s208"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum9, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s210"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum10, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s211"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum1, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s212"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum2, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s213"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum3, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s214"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum5, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s215"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum6, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s216"><Data ss:Type="Number">0</Data></Cell>
        <Cell ss:StyleID="s216"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum5, 0) + NVL (x_sum6, 0),
                               'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s217"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s217"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s218"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum4, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
       </Row>'
         WHERE x_id1 = 1;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
       <Row ss:AutoFitHeight="0" ss:Height="20">
        <Cell ss:StyleID="s219"><Data ss:Type="Number">2</Data></Cell>
        <Cell ss:MergeAcross="1" ss:StyleID="s221"><ss:Data ss:Type="String"
          xmlns="http://www.w3.org/TR/REC-html40"><U>В тому числі</U><Font>:&#10;</Font><B>допомога у зв''язку з вагітністю та пологами</B></ss:Data></Cell>
        <Cell ss:StyleID="s225"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_id5, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s226"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_id6, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s227"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum7, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s226"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum8, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s227"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum9, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s230"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s231"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum1, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s232"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum2, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s233"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum3, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s234"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum5, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s235"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum6, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s236"><Data ss:Type="Number">0</Data></Cell>
        <Cell ss:StyleID="s237"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum5, 0) + NVL (x_sum6, 0),
                               'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s238"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s238"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s239"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum4, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
       </Row>'
         WHERE x_id1 = 2;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
       <Row ss:AutoFitHeight="0">
        <Cell ss:StyleID="s240"><Data ss:Type="Number">3</Data></Cell>
        <Cell ss:MergeAcross="1" ss:StyleID="s242"><Data ss:Type="String">допомога при усиновленні дитини</Data></Cell>
        <Cell ss:StyleID="s244"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_id5, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s245"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_id6, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s246"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum7, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s245"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum8, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s246"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum9, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s248"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s249"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum1, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s250"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum2, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s251"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum3, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s252"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum5, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s253"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum6, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s254"><Data ss:Type="Number">0</Data></Cell>
        <Cell ss:StyleID="s255"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum5, 0) + NVL (x_sum6, 0),
                               'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s256"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s256"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s257"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum4, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
       </Row>'
         WHERE x_id1 = 3;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
       <Row ss:AutoFitHeight="0">
        <Cell ss:StyleID="s258"><Data ss:Type="Number">4</Data></Cell>
        <Cell ss:MergeAcross="1" ss:StyleID="s260"><Data ss:Type="String">допомога при народженні дитини</Data></Cell>
        <Cell ss:StyleID="s264"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_id5, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s265"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_id6, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s266"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum7, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s265"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum8, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s266"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum9, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s268"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s269"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum1, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s270"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum2, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s271"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum3, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s272"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum5, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s273"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum6, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s274"><Data ss:Type="Number">0</Data></Cell>
        <Cell ss:StyleID="s275"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum5, 0) + NVL (x_sum6, 0),
                               'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s276"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s276"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s277"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum4, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
       </Row>'
         WHERE x_id1 = 4;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
       <Row ss:AutoFitHeight="0">
        <Cell ss:StyleID="s200"><Data ss:Type="Number">5</Data></Cell>
        <Cell ss:MergeAcross="1" ss:StyleID="s279"><Data ss:Type="String">із них: чоловіки</Data></Cell>
        <Cell ss:StyleID="s283"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_id5, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s284"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_id6, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s285"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum7, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s284"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum8, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s285"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum9, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s230"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s286"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum1, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s287"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum2, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s288"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s229"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s228"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s238"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s238"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s289"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s289"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s290"><Data ss:Type="String">X</Data></Cell>
       </Row>'
         WHERE x_id1 = 5;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                   '
       <Row ss:AutoFitHeight="0" ss:Height="20">
        <Cell ss:StyleID="s291"><Data ss:Type="Number">6</Data></Cell>
        <Cell ss:MergeAcross="1" ss:StyleID="s293"><Data ss:Type="String">із рядка 4: допомога при народженні дитини за заявами осіб, які надійшли з використанням електронного цифрового аідпису</Data></Cell>
        <Cell ss:StyleID="s295"><Data ss:Type="Number">0</Data></Cell>
        <Cell ss:StyleID="s296"><Data ss:Type="Number">0</Data></Cell>
        <Cell ss:StyleID="s297"><Data ss:Type="Number">0</Data></Cell>
        <Cell ss:StyleID="s296"><Data ss:Type="String">0</Data></Cell>
        <Cell ss:StyleID="s297"><Data ss:Type="Number">0</Data></Cell>
        <Cell ss:StyleID="s299"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s300"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s299"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s301"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s302"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s298"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s303"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s303"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s304"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s304"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s305"><Data ss:Type="String">X</Data></Cell>
       </Row>'
         WHERE x_id1 = 6;

           UPDATE tmp_univ_rpt_data
              SET x_string2 =
                         '
       <Row ss:AutoFitHeight="0">
        <Cell ss:StyleID="s306"><Data ss:Type="Number">7</Data></Cell>
        <Cell ss:MergeAcross="1" ss:StyleID="s308"><Data ss:Type="String">допомога на дітей, над якими встановлено опіку чи піклування (ряд.8 + ряд.9)</Data></Cell>
        <Cell ss:StyleID="s312"><Data ss:Type="Number">'
                      || TO_CHAR (NVL (x_id5, 0))
                      || '</Data></Cell>
        <Cell ss:StyleID="s313"><Data ss:Type="Number">'
                      || TO_CHAR (NVL (x_id6, 0))
                      || '</Data></Cell>
        <Cell ss:StyleID="s314"><Data ss:Type="Number">'
                      || TO_CHAR (NVL (x_sum7, 0))
                      || '</Data></Cell>
        <Cell ss:StyleID="s315"><Data ss:Type="Number">'
                      || TO_CHAR (NVL (x_sum8, 0))
                      || '</Data></Cell>
        <Cell ss:StyleID="s314"><Data ss:Type="Number">'
                      || TO_CHAR (NVL (x_sum9, 0))
                      || '</Data></Cell>
        <Cell ss:StyleID="s316"><Data ss:Type="Number">'
                      || TO_CHAR (NVL (x_sum10, 0))
                      || '</Data></Cell>
        <Cell ss:StyleID="s317"><Data ss:Type="Number">'
                      || TO_CHAR (NVL (x_sum1, 0), 'FM9999999999990.00')
                      || '</Data></Cell>
        <Cell ss:StyleID="s318"><Data ss:Type="Number">'
                      || TO_CHAR (NVL (x_sum2, 0), 'FM9999999999990.00')
                      || '</Data></Cell>
        <Cell ss:StyleID="s319"><Data ss:Type="Number">'
                      || TO_CHAR (NVL (x_sum3, 0), 'FM9999999999990.00')
                      || '</Data></Cell>
        <Cell ss:StyleID="s320"><Data ss:Type="Number">'
                      || TO_CHAR (NVL (x_sum5, 0), 'FM9999999999990.00')
                      || '</Data></Cell>
        <Cell ss:StyleID="s321"><Data ss:Type="Number">'
                      || TO_CHAR (NVL (x_sum6, 0), 'FM9999999999990.00')
                      || '</Data></Cell>
        <Cell ss:StyleID="s322"><Data ss:Type="Number">0</Data></Cell>
        <Cell ss:StyleID="s323"><Data ss:Type="Number">'
                      || TO_CHAR (NVL (x_sum5, 0) + NVL (x_sum6, 0),
                                  'FM9999999999990.00')
                      || '</Data></Cell>
        <Cell ss:StyleID="s324"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s324"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s325"><Data ss:Type="Number">'
                      || TO_CHAR (NVL (x_sum4, 0), 'FM9999999999990.00')
                      || '</Data></Cell>
       </Row>'
            WHERE x_id1 = 7
        RETURNING x_id2,
                  x_id3,
                  x_id4,
                  x_sum1,
                  x_sum2,
                  x_sum9,
                  x_sum10
             INTO l_cnt_6y,
                  l_cnt_18y,
                  l_cnt_23y,
                  l_sum,
                  l_sum_m,
                  l_cnt_chd,
                  l_cnt_chd_m;

        IF NVL (l_cnt_6y, 0) + NVL (l_cnt_18y, 0) > 0
        THEN
            IF NVL (l_cnt_6y, 0) > 0
            THEN
                l_sum_6y :=
                    ROUND (
                          l_sum
                        * l_cnt_6y
                        / (NVL (l_cnt_6y, 0) + NVL (l_cnt_18y, 0)),
                        2);
                l_sum_18y := NVL (l_sum, 0) - NVL (l_sum_6y, 0);

                UPDATE tmp_univ_rpt_data
                   SET x_sum1 =
                           CASE
                               WHEN x_id1 = 8 THEN l_sum_6y
                               ELSE l_sum_18y
                           END
                 WHERE x_id1 IN (8, 9);

                l_sum_6y :=
                    ROUND (
                          l_sum_m
                        * l_cnt_6y
                        / (NVL (l_cnt_6y, 0) + NVL (l_cnt_18y, 0)),
                        2);
                l_sum_18y := NVL (l_sum_m, 0) - NVL (l_sum_6y, 0);

                UPDATE tmp_univ_rpt_data
                   SET x_sum2 =
                           CASE
                               WHEN x_id1 = 8 THEN l_sum_6y
                               ELSE l_sum_18y
                           END
                 WHERE x_id1 IN (8, 9);
            ELSE
                UPDATE tmp_univ_rpt_data
                   SET x_sum1 = CASE WHEN x_id1 = 8 THEN 0 ELSE l_sum END,
                       x_sum2 = CASE WHEN x_id1 = 8 THEN 0 ELSE l_sum_m END
                 WHERE x_id1 IN (8, 9);
            END IF;
        ELSE
            UPDATE tmp_univ_rpt_data
               SET x_sum1 = 0, x_sum2 = 0
             WHERE x_id1 IN (8, 9);
        END IF;

        IF l_cnt_chd > 0
        THEN
            l_sum_6y :=
                CASE
                    WHEN l_cnt_6y = 0
                    THEN
                        0
                    ELSE
                        ROUND (
                              l_cnt_chd
                            * l_cnt_6y
                            / (NVL (l_cnt_6y, 0) + NVL (l_cnt_18y, 0)))
                END;
            l_sum_18y := l_cnt_chd - NVL (l_sum_6y, 0);

            UPDATE tmp_univ_rpt_data
               SET x_sum9 = l_sum_6y
             WHERE x_id1 = 8;

            UPDATE tmp_univ_rpt_data
               SET x_sum9 = l_sum_18y
             WHERE x_id1 = 9;

            IF l_cnt_chd_m > 0
            THEN
                l_prc := l_cnt_chd_m / l_cnt_chd * 100;

                   UPDATE tmp_univ_rpt_data
                      SET x_sum10 = ROUND (x_sum9 * l_prc * 0.01)
                    WHERE x_id1 = 8
                RETURNING NVL (x_sum10, 0)
                     INTO l_sum_6y;

                UPDATE tmp_univ_rpt_data
                   SET x_sum10 = l_cnt_chd_m - l_sum_6y
                 WHERE x_id1 = 9;
            END IF;
        END IF;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
       <Row ss:AutoFitHeight="0" ss:Height="20">
        <Cell ss:StyleID="s219"><Data ss:Type="Number">8</Data></Cell>
        <Cell ss:MergeAcross="1" ss:StyleID="s327"><Data ss:Type="String">із них:&#10;на дітей віком  до 6 років                    </Data></Cell>
        <Cell ss:StyleID="s283"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_id5, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s284"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_id6, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s285"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum7, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s284"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum8, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s334"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum9, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s335"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum10, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s286"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum1, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s287"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum2, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s288"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s332"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s333"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s289"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s289"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s289"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s289"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s290"><Data ss:Type="String">X</Data></Cell>
       </Row>'
         WHERE x_id1 = 8;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
       <Row ss:AutoFitHeight="0">
        <Cell ss:StyleID="s240"><Data ss:Type="Number">9</Data></Cell>
        <Cell ss:MergeAcross="1" ss:StyleID="s328"><Data ss:Type="String">на дітей віком від 6  до 18 років</Data></Cell>
        <Cell ss:StyleID="s295"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_id5, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s296"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_id6, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s297"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum7, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s296"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum8, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s340"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum9, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s341"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum10, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s249"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum1, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s250"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum2, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s342"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s338"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s339"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s256"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s256"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s256"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s256"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s305"><Data ss:Type="String">X</Data></Cell>
       </Row>'
         WHERE x_id1 = 9;

           UPDATE tmp_univ_rpt_data
              SET x_string2 =
                         '
       <Row ss:AutoFitHeight="0">
        <Cell ss:StyleID="s258"><Data ss:Type="Number">10</Data></Cell>
        <Cell ss:MergeAcross="1" ss:StyleID="s260"><Data ss:Type="String">допомога на дітей одиноким матерям (ряд.11 + ряд.12+ ряд.13) </Data></Cell>
        <Cell ss:StyleID="s264"><Data ss:Type="Number">'
                      || TO_CHAR (NVL (x_id5, 0))
                      || '</Data></Cell>
        <Cell ss:StyleID="s265"><Data ss:Type="Number">'
                      || TO_CHAR (NVL (x_id6, 0))
                      || '</Data></Cell>
        <Cell ss:StyleID="s266"><Data ss:Type="Number">'
                      || TO_CHAR (NVL (x_sum7, 0))
                      || '</Data></Cell>
        <Cell ss:StyleID="s343"><Data ss:Type="Number">'
                      || TO_CHAR (NVL (x_sum8, 0))
                      || '</Data></Cell>
        <Cell ss:StyleID="s266"><Data ss:Type="Number">'
                      || TO_CHAR (NVL (x_sum9, 0))
                      || '</Data></Cell>
        <Cell ss:StyleID="s344"><Data ss:Type="Number">'
                      || TO_CHAR (NVL (x_sum10, 0))
                      || '</Data></Cell>
        <Cell ss:StyleID="s269"><Data ss:Type="Number">'
                      || TO_CHAR (NVL (x_sum1, 0), 'FM9999999999990.00')
                      || '</Data></Cell>
        <Cell ss:StyleID="s270"><Data ss:Type="Number">'
                      || TO_CHAR (NVL (x_sum2, 0), 'FM9999999999990.00')
                      || '</Data></Cell>
        <Cell ss:StyleID="s271"><Data ss:Type="Number">'
                      || TO_CHAR (NVL (x_sum3, 0), 'FM9999999999990.00')
                      || '</Data></Cell>
        <Cell ss:StyleID="s272"><Data ss:Type="Number">'
                      || TO_CHAR (NVL (x_sum5, 0), 'FM9999999999990.00')
                      || '</Data></Cell>
        <Cell ss:StyleID="s273"><Data ss:Type="Number">'
                      || TO_CHAR (NVL (x_sum6, 0), 'FM9999999999990.00')
                      || '</Data></Cell>
        <Cell ss:StyleID="s274"><Data ss:Type="Number">0</Data></Cell>
        <Cell ss:StyleID="s275"><Data ss:Type="Number">'
                      || TO_CHAR (NVL (x_sum5, 0) + NVL (x_sum6, 0),
                                  'FM9999999999990.00')
                      || '</Data></Cell>
        <Cell ss:StyleID="s276"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s276"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s277"><Data ss:Type="Number">'
                      || TO_CHAR (NVL (x_sum4, 0), 'FM9999999999990.00')
                      || '</Data></Cell>
       </Row>'
            WHERE x_id1 = 10
        RETURNING x_id2,
                  x_id3,
                  x_id4,
                  x_sum1,
                  x_sum2,
                  x_sum9,
                  x_sum10
             INTO l_cnt_6y,
                  l_cnt_18y,
                  l_cnt_23y,
                  l_sum,
                  l_sum_m,
                  l_cnt_chd,
                  l_cnt_chd_m;

        IF NVL (l_cnt_6y, 0) + NVL (l_cnt_18y, 0) + NVL (l_cnt_23y, 0) > 0
        THEN
            l_sum_6y :=
                ROUND (
                      l_sum
                    * l_cnt_6y
                    / (  NVL (l_cnt_6y, 0)
                       + NVL (l_cnt_18y, 0)
                       + NVL (l_cnt_23y, 0)),
                    2);
            l_sum_18y :=
                ROUND (
                      l_sum
                    * l_cnt_18y
                    / (  NVL (l_cnt_6y, 0)
                       + NVL (l_cnt_18y, 0)
                       + NVL (l_cnt_23y, 0)),
                    2);
            l_sum_23y :=
                ROUND (
                      l_sum
                    * l_cnt_23y
                    / (  NVL (l_cnt_6y, 0)
                       + NVL (l_cnt_18y, 0)
                       + NVL (l_cnt_23y, 0)),
                    2);

            IF l_sum_6y + l_sum_18y + l_sum_23y != l_sum
            THEN
                IF NVL (l_cnt_6y, 0) > 0
                THEN
                    l_sum_6y := l_sum - l_sum_18y + l_sum_23y;
                ELSIF NVL (l_cnt_18y, 0) > 0
                THEN
                    l_sum_18y := l_sum - l_sum_6y + l_sum_23y;
                ELSE
                    l_sum_23y := l_sum - l_sum_18y + l_sum_6y;
                END IF;
            END IF;

            UPDATE tmp_univ_rpt_data
               SET x_sum1 =
                       CASE x_id1
                           WHEN 11 THEN l_sum_6y
                           WHEN 12 THEN l_sum_18y
                           ELSE l_sum_23y
                       END
             WHERE x_id1 IN (11, 12, 13);

            l_sum_6y :=
                ROUND (
                      l_sum_m
                    * l_cnt_6y
                    / (  NVL (l_cnt_6y, 0)
                       + NVL (l_cnt_18y, 0)
                       + NVL (l_cnt_23y, 0)),
                    2);
            l_sum_18y :=
                ROUND (
                      l_sum_m
                    * l_cnt_18y
                    / (  NVL (l_cnt_6y, 0)
                       + NVL (l_cnt_18y, 0)
                       + NVL (l_cnt_23y, 0)),
                    2);
            l_sum_23y :=
                ROUND (
                      l_sum_m
                    * l_cnt_23y
                    / (  NVL (l_cnt_6y, 0)
                       + NVL (l_cnt_18y, 0)
                       + NVL (l_cnt_23y, 0)),
                    2);

            IF l_sum_6y + l_sum_18y + l_sum_23y != l_sum_m
            THEN
                IF NVL (l_cnt_6y, 0) > 0
                THEN
                    l_sum_6y := l_sum_m - l_sum_18y + l_sum_23y;
                ELSIF NVL (l_cnt_18y, 0) > 0
                THEN
                    l_sum_18y := l_sum_m - l_sum_6y + l_sum_23y;
                ELSE
                    l_sum_23y := l_sum_m - l_sum_18y + l_sum_6y;
                END IF;
            END IF;

            UPDATE tmp_univ_rpt_data
               SET x_sum2 =
                       CASE x_id1
                           WHEN 11 THEN l_sum_6y
                           WHEN 12 THEN l_sum_18y
                           ELSE l_sum_23y
                       END
             WHERE x_id1 IN (11, 12, 13);
        ELSE
            UPDATE tmp_univ_rpt_data
               SET x_sum1 = 0, x_sum2 = 0
             WHERE x_id1 IN (11, 12, 13);
        END IF;

        IF l_cnt_chd > 0
        THEN
            l_sum_6y :=
                CASE
                    WHEN l_cnt_6y = 0
                    THEN
                        0
                    ELSE
                        ROUND (
                              l_cnt_chd
                            * l_cnt_6y
                            / (  NVL (l_cnt_6y, 0)
                               + NVL (l_cnt_18y, 0)
                               + NVL (l_cnt_23y, 0)))
                END;
            l_sum_23y :=
                CASE
                    WHEN l_cnt_23y = 0
                    THEN
                        0
                    ELSE
                        ROUND (
                              l_cnt_chd
                            * l_cnt_23y
                            / (  NVL (l_cnt_6y, 0)
                               + NVL (l_cnt_18y, 0)
                               + NVL (l_cnt_23y, 0)))
                END;
            l_sum_18y := l_cnt_chd - NVL (l_sum_6y, 0) - NVL (l_sum_23y, 0);

            UPDATE tmp_univ_rpt_data
               SET x_sum9 = l_sum_6y
             WHERE x_id1 = 11;

            UPDATE tmp_univ_rpt_data
               SET x_sum9 = l_sum_18y
             WHERE x_id1 = 12;

            UPDATE tmp_univ_rpt_data
               SET x_sum9 = l_sum_23y
             WHERE x_id1 = 13;

            IF l_cnt_chd_m > 0
            THEN
                l_prc := l_cnt_chd_m / l_cnt_chd * 100;

                   UPDATE tmp_univ_rpt_data
                      SET x_sum10 = ROUND (x_sum9 * l_prc * 0.01)
                    WHERE x_id1 = 11
                RETURNING NVL (x_sum10, 0)
                     INTO l_sum_6y;

                   UPDATE tmp_univ_rpt_data
                      SET x_sum10 = ROUND (x_sum9 * l_prc * 0.01)
                    WHERE x_id1 = 13
                RETURNING NVL (x_sum10, 0)
                     INTO l_sum_23y;

                UPDATE tmp_univ_rpt_data
                   SET x_sum10 = l_cnt_chd_m - l_sum_6y - l_sum_23y
                 WHERE x_id1 = 12;
            END IF;
        END IF;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
       <Row ss:AutoFitHeight="0">
        <Cell ss:StyleID="s200"><Data ss:Type="Number">11</Data></Cell>
        <Cell ss:MergeAcross="1" ss:StyleID="s279"><Data ss:Type="String">із них: &#10;на дітей віком  до 6 років                    </Data></Cell>
        <Cell ss:StyleID="s283"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_id5, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s284"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_id6, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s285"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum7, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s284"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum8, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s285"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum9, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s345"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum10, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s286"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum1, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s287"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum2, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s288"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s332"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s333"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s289"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s289"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s289"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s289"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s290"><Data ss:Type="String">X</Data></Cell>
       </Row>'
         WHERE x_id1 = 11;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
       <Row ss:AutoFitHeight="0">
        <Cell ss:StyleID="s219"><Data ss:Type="Number">12</Data></Cell>
        <Cell ss:MergeAcross="1" ss:StyleID="s279"><Data ss:Type="String">на дітей віком від 6  до 18 років</Data></Cell>
        <Cell ss:StyleID="s283"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_id5, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s284"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_id6, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s285"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum7, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s284"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum8, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s285"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum9, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s345"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum10, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s286"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum1, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s287"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum2, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s288"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s332"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s333"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s289"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s289"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s289"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s289"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s290"><Data ss:Type="String">X</Data></Cell>
       </Row>'
         WHERE x_id1 = 12;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
       <Row ss:AutoFitHeight="0">
        <Cell ss:StyleID="s346"><Data ss:Type="Number">13</Data></Cell>
        <Cell ss:MergeAcross="1" ss:StyleID="s293"><Data ss:Type="String">на дітей віком від 18  до 23 років за умови навчання</Data></Cell>
        <Cell ss:StyleID="s295"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_id5, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s296"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_id6, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s297"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum7, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s296"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum8, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s297"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum9, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s350"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum10, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s351"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum1, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s352"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum2, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s353"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s348"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s349"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s304"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s304"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s304"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s304"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s305"><Data ss:Type="String">X</Data></Cell>
       </Row>'
         WHERE x_id1 = 13;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
       <Row ss:AutoFitHeight="0" ss:Height="70">
        <Cell ss:StyleID="s354"><Data ss:Type="Number">14</Data></Cell>
        <Cell ss:MergeAcross="1" ss:StyleID="s356"><Data ss:Type="String">допомога на дітей, хворих на тяжкі перинатальні ураження нервової системи, тяжкі вроджені вади розвитку, рідкісні орфанні захворювання, онкологічні, онкогематологічні захворювання, дитячий церебральний параліч, тяжкі психічні розлади, цукровий діабет I типу (інсулінозалежний), гострі або хронічні захворювання нирок IV ступеня, на дитину, яка отримала тяжку травму, потребує трансплантації органа, потребує паліативної допомоги, яким не встановлено інвалідність </Data></Cell>
        <Cell ss:StyleID="s360"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_id5, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s361"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_id6, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s362"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum7, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s363"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s362"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum9, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s364"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s365"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum1, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s366"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum2, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s367"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum3, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s368"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum5, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s369"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum6, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s370"><Data ss:Type="Number">0</Data></Cell>
        <Cell ss:StyleID="s371"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum5, 0) + NVL (x_sum6, 0),
                               'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s372"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s372"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s373"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum4, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
       </Row>'
         WHERE x_id1 = 14;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
       <Row ss:AutoFitHeight="0">
        <Cell ss:StyleID="s374"><Data ss:Type="Number">15</Data></Cell>
        <Cell ss:MergeAcross="1" ss:StyleID="s376"><Data ss:Type="String">Допомога на дітей, які виховуються у багатодітних сім''ях</Data></Cell>
        <Cell ss:StyleID="s378"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_id5, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s379"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_id6, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s380"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum7, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s381"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s380"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum9, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s382"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s383"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum1, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s384"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum2, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s385"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum3, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s386"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum5, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s387"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum6, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s388"><Data ss:Type="Number">0</Data></Cell>
        <Cell ss:StyleID="s389"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum5, 0) + NVL (x_sum6, 0),
                               'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s390"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s390"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s391"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum4, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
       </Row>'
         WHERE x_id1 = 15;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                   '
       <Row ss:AutoFitHeight="0" ss:Height="20">
        <Cell ss:StyleID="s392"><Data ss:Type="Number">16</Data></Cell>
        <Cell ss:MergeAcross="1" ss:StyleID="s394"><Data ss:Type="String">Тимчасова державна допомога дітям, батьки яких ухиляються від сплати аліментів</Data></Cell>
        <Cell ss:StyleID="s396"><Data ss:Type="Number">0</Data></Cell>
        <Cell ss:StyleID="s397"><Data ss:Type="Number">0</Data></Cell>
        <Cell ss:StyleID="s398"><Data ss:Type="Number">0</Data></Cell>
        <Cell ss:StyleID="s399"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s398"><Data ss:Type="Number">0</Data></Cell>
        <Cell ss:StyleID="s400"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s401"><Data ss:Type="Number">0</Data></Cell>
        <Cell ss:StyleID="s402"><Data ss:Type="Number">0</Data></Cell>
        <Cell ss:StyleID="s403"><Data ss:Type="Number">0</Data></Cell>
        <Cell ss:StyleID="s404"><Data ss:Type="Number">0</Data></Cell>
        <Cell ss:StyleID="s405"><Data ss:Type="Number">0</Data></Cell>
        <Cell ss:StyleID="s406"><Data ss:Type="Number">0</Data></Cell>
        <Cell ss:StyleID="s407"><Data ss:Type="Number">0</Data></Cell>
        <Cell ss:StyleID="s397"><Data ss:Type="Number">0</Data></Cell>
        <Cell ss:StyleID="s406"><Data ss:Type="Number">0</Data></Cell>
        <Cell ss:StyleID="s408"><Data ss:Type="Number">0</Data></Cell>
       </Row>'
         WHERE x_id1 = 16;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
       <Row ss:AutoFitHeight="0">
        <Cell ss:StyleID="s392"><Data ss:Type="Number">17</Data></Cell>
        <Cell ss:MergeAcross="1" ss:StyleID="s394"><Data ss:Type="String">Разом</Data></Cell>
        <Cell ss:StyleID="s396"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_id5, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s397"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_id6, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s398"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum7, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s399"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s398"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum9, 0))
                   || '</Data></Cell>
        <Cell ss:StyleID="s400"><Data ss:Type="String">X</Data></Cell>
        <Cell ss:StyleID="s401"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum1, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s402"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum2, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s403"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum3, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s404"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum5, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s405"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum6, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s406"><Data ss:Type="Number">0</Data></Cell>
        <Cell ss:StyleID="s407"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum5, 0) + NVL (x_sum6, 0),
                               'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s397"><Data ss:Type="Number">0</Data></Cell>
        <Cell ss:StyleID="s406"><Data ss:Type="Number">0</Data></Cell>
        <Cell ss:StyleID="s408"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum4, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
       </Row>'
         WHERE x_id1 = 17;
    END SET_CHILDREN_FML;

    -- #109334 Вибірка щодо ДБСТ - Чисельність (батьки-вихователі)
    PROCEDURE SET_CHILD_ORPHANS (p_start_dt   IN DATE,
                                 p_org_id     IN NUMBER,
                                 p_jbr_id     IN DECIMAL)
    IS
        l_user_org   NUMBER;
        l_org_to     NUMBER := tools.GetCurrOrgTo;
        l_date       DATE;
    BEGIN
        IF p_org_id = 0
        THEN
            l_user_org := tools.GetCurrOrg;
        ELSE
            l_user_org := p_org_id;
        END IF;

        l_user_org :=
            CASE WHEN l_user_org = 50001 THEN 50000 ELSE l_user_org END;

        IF l_org_to = 34
        THEN
            SELECT org_to
              INTO l_org_to
              FROM ikis_sys.v_opfu
             WHERE org_id = l_user_org;
        END IF;

        l_org_to := CASE WHEN l_org_to = 34 THEN 34 ELSE 32 END;

        l_date := TRUNC (p_start_dt, 'mm');

        DELETE FROM tmp_univ_rpt_data
              WHERE 1 = 1;

        INSERT INTO tmp_univ_rpt_data (x_id1,                        -- ca Nзп
                                       x_id2,                     -- x_org_org
                                       x_string1,                    -- o_name
                                       x_id3,                      -- x_pc_516
                                       x_id4,                  -- x_people_516
                                       x_id5,                      -- x_pc_515
                                       x_id6                   -- x_people_515
                                            )
            WITH
                org_list
                AS
                    (    SELECT org_id i_org, org_org i_org_org
                           FROM ikis_sys.v_opfu
                          WHERE l_org_to = 32
                     CONNECT BY PRIOR org_id = org_org
                     START WITH org_id = l_user_org
                     UNION ALL
                     SELECT org_id i_org, org_org i_org_org
                       FROM ikis_sys.v_opfu
                      WHERE l_org_to = 34 AND org_acc_org = l_user_org),
                obl_list
                AS
                    (  SELECT nok_org                     AS o_org,
                              MAX (l1_kaot_full_name)     AS o_name
                         FROM uss_ndi.v_ndi_org2kaot t
                              JOIN uss_ndi.mv_ndi_katottg ON nok_kaot = kaot_id
                        WHERE history_status = 'A'
                     GROUP BY nok_org),
                npt_list
                AS
                    (SELECT npt_id AS x_npt, npt_code AS x_npt_code
                       FROM uss_ndi.v_ndi_payment_type
                      WHERE npt_code IN ('515', '516', '517')),
                pd_list
                AS
                    (SELECT pd_id            AS x_pd,
                            pd_pc            AS x_pc,
                            i_org            AS x_org,
                            i_org_org        AS x_org_org,
                            pd_ap            AS x_ap,
                            ap.ap_ap_main    AS x_ap_ap_main,
                            CASE
                                WHEN EXISTS
                                         (SELECT 1
                                            FROM uss_esr.pd_payment  pdp,
                                                 npt_list
                                           WHERE     pdp.pdp_pd = pd_id
                                                 AND pdp.history_status = 'A'
                                                 AND l_date BETWEEN pdp.pdp_start_dt
                                                                AND pdp.pdp_stop_dt
                                                 AND pdp.pdp_npt = x_npt
                                                 AND x_npt_code = '516')
                                THEN
                                    1
                                ELSE
                                    0
                            END              AS x_npt_516,
                            CASE
                                WHEN EXISTS
                                         (SELECT 1
                                            FROM uss_esr.pd_payment  pdp,
                                                 npt_list
                                           WHERE     pdp.pdp_pd = pd_id
                                                 AND pdp.history_status = 'A'
                                                 AND l_date BETWEEN pdp.pdp_start_dt
                                                                AND pdp.pdp_stop_dt
                                                 AND pdp.pdp_npt = x_npt
                                                 AND x_npt_code = '515')
                                THEN
                                    1
                                ELSE
                                    0
                            END              AS x_npt_515
                       FROM uss_esr.pc_decision  pd,
                            uss_esr.appeal       ap,
                            org_list
                      WHERE     (   pd.pd_st = 'S'              /*Нараховано*/
                                 OR (    pd.pd_st = 'PS' /*Призупинено виплату*/
                                     AND EXISTS
                                             (SELECT 1
                                                FROM uss_ndi.v_ndi_reason_not_pay
                                                     r
                                                     LEFT JOIN
                                                     uss_esr.pc_block pcb
                                                         ON pd.pd_pcb =
                                                            pcb.pcb_id
                                               WHERE     r.rnp_id =
                                                         pcb.pcb_rnp
                                                     AND r.rnp_pnp_tp = 'CPY'
                                                     AND r.history_status =
                                                         'A')))
                            AND pd_nst = 275
                            AND pd.com_org = i_org
                            AND pd_ap = ap_id
                            AND EXISTS
                                    (SELECT 1
                                       FROM uss_esr.pd_accrual_period a
                                      WHERE     a.pdap_pd = pd_id
                                            AND a.history_status = 'A'
                                            AND l_date BETWEEN a.pdap_start_dt
                                                           AND a.pdap_stop_dt)),
                pd_filter
                AS
                    (SELECT *
                       FROM pd_list p
                      WHERE     --скриваємо записи у яких споріднене рішення відсутне (вірогідно не в статусі Нараховано)
                                (   (    x_ap_ap_main IS NOT NULL
                                     AND EXISTS
                                             (SELECT 1
                                                FROM pd_list p2
                                               WHERE p.x_ap_ap_main = p2.x_ap))
                                 OR x_ap_ap_main IS NULL)
                            --скриваємо рішення у яких відсутні актуальні Призначено
                            AND (x_npt_516 > 0 OR x_npt_515 > 0)),
                pd_props_list
                AS
                    (SELECT x_pd,
                            x_org,
                            x_org_org,
                            x_ap,
                            x_ap_ap_main,
                            x_npt_516,
                            x_npt_515,
                            CASE
                                WHEN x_ap_ap_main IS NOT NULL
                                THEN
                                    (SELECT MAX (pd2.x_pc)
                                       FROM pd_filter pd2
                                      WHERE pd2.x_ap = p.x_ap_ap_main)
                                ELSE
                                    x_pc
                            END                                            AS x_pc,
                            (SELECT COUNT (*)
                               FROM uss_esr.pd_payment  pdp,
                                    uss_esr.pd_detail   pdd,
                                    npt_list
                              WHERE     pdp.pdp_pd = x_pd
                                    AND pdp.history_status = 'A'
                                    AND l_date BETWEEN pdp.pdp_start_dt
                                                   AND pdp.pdp_stop_dt
                                    AND pdp.pdp_npt = x_npt
                                    AND x_npt_code = '517'
                                    AND pdd.pdd_pdp = pdp_id
                                    AND l_date BETWEEN pdd.pdd_start_dt
                                                   AND pdd.pdd_stop_dt)    AS x_people_cnt
                       FROM pd_filter p),
                src
                AS
                    (  SELECT x_org_org,
                              MAX (o_name)
                                  AS o_name,
                              COUNT (
                                  DISTINCT
                                      CASE WHEN x_npt_516 = 1 THEN x_pc END)
                                  AS x_pc_516,
                              SUM (
                                  CASE WHEN x_npt_516 = 1 THEN x_people_cnt END)
                                  AS x_people_516,
                              COUNT (
                                  DISTINCT
                                      CASE WHEN x_npt_515 = 1 THEN x_pc END)
                                  AS x_pc_515,
                              SUM (
                                  CASE WHEN x_npt_515 = 1 THEN x_people_cnt END)
                                  AS x_people_515
                         FROM pd_props_list, obl_list
                        WHERE x_people_cnt > 0 --беремо тільки рішення де є утриманці
                                               AND x_org = o_org
                     GROUP BY x_org_org)
                SELECT ROWNUM, s.*
                  FROM src s
                UNION ALL
                SELECT NULL,
                       NULL,
                       'Разом',
                       SUM (x_pc_516),
                       SUM (x_people_516),
                       SUM (x_pc_515),
                       SUM (x_people_515)
                  FROM src s
                ORDER BY 2;

        UPDATE tmp_univ_rpt_data
           SET x_sum1 = NVL (x_id3, 0) + NVL (x_id5, 0),
               x_sum2 = NVL (x_id4, 0) + NVL (x_id6, 0)
         WHERE 1 = 1;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
       <Row ss:AutoFitHeight="0">
        <Cell ss:StyleID="s200"><Data ss:Type="Number">'
                   || TO_CHAR (x_id1)
                   || '</Data></Cell>
        <Cell ss:StyleID="s202"><Data ss:Type="Number">'
                   || TO_CHAR (x_id2)
                   || '</Data></Cell>
        <Cell ss:StyleID="s207"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
        <Cell ss:StyleID="s208"><Data ss:Type="Number">'
                   || TO_CHAR (x_id3)
                   || '</Data></Cell>
        <Cell ss:StyleID="s209"><Data ss:Type="Number">'
                   || TO_CHAR (x_id4)
                   || '</Data></Cell>
        <Cell ss:StyleID="s208"><Data ss:Type="Number">'
                   || TO_CHAR (x_id5)
                   || '</Data></Cell>
        <Cell ss:StyleID="s210"><Data ss:Type="Number">'
                   || TO_CHAR (x_id6)
                   || '</Data></Cell>
        <Cell ss:StyleID="s211"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1)
                   || '</Data></Cell>
        <Cell ss:StyleID="s212"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2)
                   || '</Data></Cell>
       </Row>'
         WHERE x_id1 IS NOT NULL;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
       <Row ss:AutoFitHeight="0">
        <Cell ss:StyleID="s392"></Cell>
        <Cell ss:StyleID="s392"></Cell>
        <Cell ss:StyleID="s394"><Data ss:Type="String">Разом</Data></Cell>
        <Cell ss:StyleID="s396"><Data ss:Type="Number">'
                   || TO_CHAR (x_id3)
                   || '</Data></Cell>
        <Cell ss:StyleID="s398"><Data ss:Type="Number">'
                   || TO_CHAR (x_id4)
                   || '</Data></Cell>
        <Cell ss:StyleID="s397"><Data ss:Type="Number">'
                   || TO_CHAR (x_id5)
                   || '</Data></Cell>
        <Cell ss:StyleID="s398"><Data ss:Type="Number">'
                   || TO_CHAR (x_id6)
                   || '</Data></Cell>
        <Cell ss:StyleID="s401"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1)
                   || '</Data></Cell>
        <Cell ss:StyleID="s402"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2)
                   || '</Data></Cell>
       </Row>'
         WHERE x_id1 IS NULL;
    END SET_CHILD_ORPHANS;

    -- #109460 Вибірка щодо батьків-вихователів
    PROCEDURE SET_CHILD_ORPHANS_R2 (p_start_dt   IN DATE,
                                    p_org_id     IN NUMBER,
                                    p_jbr_id     IN DECIMAL)
    IS
        l_user_org   NUMBER;
        l_org_to     NUMBER := tools.GetCurrOrgTo;
        l_date       DATE;
    BEGIN
        IF p_org_id = 0
        THEN
            l_user_org := tools.GetCurrOrg;
        ELSE
            l_user_org := p_org_id;
        END IF;

        l_user_org :=
            CASE WHEN l_user_org = 50001 THEN 50000 ELSE l_user_org END;

        IF l_org_to = 34
        THEN
            SELECT org_to
              INTO l_org_to
              FROM ikis_sys.v_opfu
             WHERE org_id = l_user_org;
        END IF;

        l_org_to := CASE WHEN l_org_to = 34 THEN 34 ELSE 32 END;

        l_date := TRUNC (p_start_dt, 'mm');

        DELETE FROM tmp_univ_rpt_data
              WHERE 1 = 1;

        INSERT INTO tmp_univ_rpt_data (x_id1,                        -- ca Nзп
                                       x_id2,                     -- x_org_org
                                       x_string1,                    -- o_name
                                       x_id3,                      -- x_pc_516
                                       x_id4,                  -- x_people_516
                                       x_sum1,                    -- x_sum_516
                                       x_sum2,                    -- x_sum_517
                                       x_sum3,                     --x_avg_516
                                       x_sum4                      --x_avg_517
                                             )
            WITH
                org_list
                AS
                    (    SELECT org_id i_org, org_org i_org_org
                           FROM ikis_sys.v_opfu
                          WHERE l_org_to = 32
                     CONNECT BY PRIOR org_id = org_org
                     START WITH org_id = l_user_org
                     UNION ALL
                     SELECT org_id i_org, org_org i_org_org
                       FROM ikis_sys.v_opfu
                      WHERE l_org_to = 34 AND org_acc_org = l_user_org),
                obl_list
                AS
                    (  SELECT nok_org                     AS o_org,
                              MAX (l1_kaot_full_name)     AS o_name
                         FROM uss_ndi.v_ndi_org2kaot t
                              JOIN uss_ndi.mv_ndi_katottg ON nok_kaot = kaot_id
                        WHERE history_status = 'A'
                     GROUP BY nok_org),
                npt_list
                AS
                    (SELECT npt_id AS x_npt, npt_code AS x_npt_code
                       FROM uss_ndi.v_ndi_payment_type
                      WHERE npt_code IN ('516', '517')),
                pd_list
                AS
                    (SELECT pd_id
                                AS x_pd,
                            pd_pc
                                AS x_pc,
                            i_org
                                AS x_org,
                            i_org_org
                                AS x_org_org,
                            pd_ap
                                AS x_ap,
                            ap.ap_ap_main
                                AS x_ap_ap_main,
                            (SELECT COUNT (*)
                               FROM uss_esr.pd_payment  pdp,
                                    uss_esr.pd_detail   pdd,
                                    npt_list
                              WHERE     pdp.pdp_pd = pd_id
                                    AND pdp.history_status = 'A'
                                    AND l_date BETWEEN pdp.pdp_start_dt
                                                   AND pdp.pdp_stop_dt
                                    AND pdp.pdp_npt = x_npt
                                    AND x_npt_code = '517'
                                    AND pdd.pdd_pdp = pdp_id
                                    AND l_date BETWEEN pdd.pdd_start_dt
                                                   AND pdd.pdd_stop_dt)
                                AS x_people_cnt,
                            (SELECT SUM (pdp.pdp_sum)
                               FROM uss_esr.pd_payment pdp, npt_list
                              WHERE     pdp.pdp_pd = pd_id
                                    AND pdp.history_status = 'A'
                                    AND l_date BETWEEN pdp.pdp_start_dt
                                                   AND pdp.pdp_stop_dt
                                    AND pdp.pdp_npt = x_npt
                                    AND x_npt_code = '516')
                                AS x_sum_516,
                            (SELECT SUM (pdp.pdp_sum)
                               FROM uss_esr.pd_payment pdp, npt_list
                              WHERE     pdp.pdp_pd = pd_id
                                    AND pdp.history_status = 'A'
                                    AND l_date BETWEEN pdp.pdp_start_dt
                                                   AND pdp.pdp_stop_dt
                                    AND pdp.pdp_npt = x_npt
                                    AND x_npt_code = '517')
                                AS x_sum_517
                       FROM uss_esr.pc_decision  pd,
                            uss_esr.appeal       ap,
                            org_list
                      WHERE     (   pd.pd_st = 'S'              /*Нараховано*/
                                 OR (    pd.pd_st = 'PS' /*Призупинено виплату*/
                                     AND EXISTS
                                             (SELECT 1
                                                FROM uss_ndi.v_ndi_reason_not_pay
                                                     r
                                                     LEFT JOIN
                                                     uss_esr.pc_block pcb
                                                         ON pd.pd_pcb =
                                                            pcb.pcb_id
                                               WHERE     r.rnp_id =
                                                         pcb.pcb_rnp
                                                     AND r.rnp_pnp_tp = 'CPY'
                                                     AND r.history_status =
                                                         'A')))
                            AND pd_nst = 275
                            AND pd.com_org = i_org
                            AND pd_ap = ap_id
                            AND EXISTS
                                    (SELECT 1
                                       FROM uss_esr.pd_accrual_period a
                                      WHERE     a.pdap_pd = pd_id
                                            AND a.history_status = 'A'
                                            AND l_date BETWEEN a.pdap_start_dt
                                                           AND a.pdap_stop_dt)
                            AND EXISTS
                                    (SELECT 1
                                       FROM uss_esr.pd_payment pdp, npt_list
                                      WHERE     pdp.pdp_pd = pd_id
                                            AND pdp.history_status = 'A'
                                            AND l_date BETWEEN pdp.pdp_start_dt
                                                           AND pdp.pdp_stop_dt
                                            AND pdp.pdp_npt = x_npt
                                            AND x_npt_code = '516')),
                pd_filter
                AS
                    (SELECT *
                       FROM pd_list p
                      WHERE     --скриваємо записи у яких споріднене рішення відсутне (вірогідно не в статусі Нараховано)
                                (   (    x_ap_ap_main IS NOT NULL
                                     AND EXISTS
                                             (SELECT 1
                                                FROM pd_list p2
                                               WHERE p.x_ap_ap_main = p2.x_ap))
                                 OR x_ap_ap_main IS NULL)
                            AND x_people_cnt > 0 --беремо тільки рішення де є утриманці
                                                ),
                pd_props_list
                AS
                    (SELECT x_pd,
                            x_org,
                            x_org_org,
                            x_ap,
                            x_ap_ap_main,
                            CASE
                                WHEN x_ap_ap_main IS NOT NULL
                                THEN
                                    (SELECT MAX (pd2.x_pc)
                                       FROM pd_filter pd2
                                      WHERE pd2.x_ap = p.x_ap_ap_main)
                                ELSE
                                    x_pc
                            END    AS x_pc,
                            x_people_cnt,
                            x_sum_516,
                            x_sum_517
                       FROM pd_filter p),
                src
                AS
                    (  SELECT x_org_org,
                              MAX (o_name)                                       AS o_name,
                              COUNT (DISTINCT x_pc)                              AS x_pc_516,
                              SUM (x_people_cnt)                                 AS x_people_516,
                              SUM (x_sum_516)                                    AS x_sum_516,
                              SUM (x_sum_517)                                    AS x_sum_517,
                              ROUND (SUM (x_sum_516) / COUNT (DISTINCT x_pc),
                                     2)                                          AS x_avg_516,
                              ROUND (SUM (x_sum_517) / SUM (x_people_cnt), 2)    AS x_avg_517
                         FROM pd_props_list, obl_list
                        WHERE x_org = o_org
                     GROUP BY x_org_org)
                SELECT ROWNUM, s.*
                  FROM src s
                UNION ALL
                SELECT NULL,
                       NULL,
                       'Разом',
                       SUM (x_pc_516),
                       SUM (x_people_516),
                       SUM (x_sum_516),
                       SUM (x_sum_517),
                       ROUND (SUM (x_sum_516) / SUM (x_pc_516), 2),
                       ROUND (SUM (x_sum_517) / SUM (x_people_516), 2)
                  FROM src s
                ORDER BY 2;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
       <Row ss:AutoFitHeight="0">
        <Cell ss:StyleID="s200"><Data ss:Type="Number">'
                   || TO_CHAR (x_id1)
                   || '</Data></Cell>
        <Cell ss:StyleID="s202"><Data ss:Type="Number">'
                   || TO_CHAR (x_id2)
                   || '</Data></Cell>
        <Cell ss:StyleID="s207"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
        <Cell ss:StyleID="s208"><Data ss:Type="Number">'
                   || TO_CHAR (x_id3)
                   || '</Data></Cell>
        <Cell ss:StyleID="s209"><Data ss:Type="Number">'
                   || TO_CHAR (x_id4)
                   || '</Data></Cell>
        <Cell ss:StyleID="s211"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum1, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s212"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum2, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s211"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum3, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s212"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum4, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
       </Row>'
         WHERE x_id1 IS NOT NULL;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
       <Row ss:AutoFitHeight="0">
        <Cell ss:StyleID="s392"></Cell>
        <Cell ss:StyleID="s392"></Cell>
        <Cell ss:StyleID="s394"><Data ss:Type="String">Разом</Data></Cell>
        <Cell ss:StyleID="s396"><Data ss:Type="Number">'
                   || TO_CHAR (x_id3)
                   || '</Data></Cell>
        <Cell ss:StyleID="s398"><Data ss:Type="Number">'
                   || TO_CHAR (x_id4)
                   || '</Data></Cell>
        <Cell ss:StyleID="s401"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum1, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s402"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum2, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s401"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum3, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s402"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum4, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
       </Row>'
         WHERE x_id1 IS NULL;
    END SET_CHILD_ORPHANS_R2;

    -- #109460 Вибірка щодо прийомних сімей
    PROCEDURE SET_CHILD_ORPHANS_R3 (p_start_dt   IN DATE,
                                    p_org_id     IN NUMBER,
                                    p_jbr_id     IN DECIMAL)
    IS
        l_user_org   NUMBER;
        l_org_to     NUMBER := tools.GetCurrOrgTo;
        l_date       DATE;
    BEGIN
        IF p_org_id = 0
        THEN
            l_user_org := tools.GetCurrOrg;
        ELSE
            l_user_org := p_org_id;
        END IF;

        l_user_org :=
            CASE WHEN l_user_org = 50001 THEN 50000 ELSE l_user_org END;

        IF l_org_to = 34
        THEN
            SELECT org_to
              INTO l_org_to
              FROM ikis_sys.v_opfu
             WHERE org_id = l_user_org;
        END IF;

        l_org_to := CASE WHEN l_org_to = 34 THEN 34 ELSE 32 END;

        l_date := TRUNC (p_start_dt, 'mm');

        DELETE FROM tmp_univ_rpt_data
              WHERE 1 = 1;

        INSERT INTO tmp_univ_rpt_data (x_id1,                        -- ca Nзп
                                       x_id2,                     -- x_org_org
                                       x_string1,                    -- o_name
                                       x_id3,                      -- x_pc_515
                                       x_id4,                  -- x_people_515
                                       x_sum1,                    -- x_sum_515
                                       x_sum2,                    -- x_sum_517
                                       x_sum3,                     --x_avg_515
                                       x_sum4                      --x_avg_517
                                             )
            WITH
                org_list
                AS
                    (    SELECT org_id i_org, org_org i_org_org
                           FROM ikis_sys.v_opfu
                          WHERE l_org_to = 32
                     CONNECT BY PRIOR org_id = org_org
                     START WITH org_id = l_user_org
                     UNION ALL
                     SELECT org_id i_org, org_org i_org_org
                       FROM ikis_sys.v_opfu
                      WHERE l_org_to = 34 AND org_acc_org = l_user_org),
                obl_list
                AS
                    (  SELECT nok_org                     AS o_org,
                              MAX (l1_kaot_full_name)     AS o_name
                         FROM uss_ndi.v_ndi_org2kaot t
                              JOIN uss_ndi.mv_ndi_katottg ON nok_kaot = kaot_id
                        WHERE history_status = 'A'
                     GROUP BY nok_org),
                npt_list
                AS
                    (SELECT npt_id AS x_npt, npt_code AS x_npt_code
                       FROM uss_ndi.v_ndi_payment_type
                      WHERE npt_code IN ('515', '517')),
                pd_list
                AS
                    (SELECT pd_id
                                AS x_pd,
                            pd_pc
                                AS x_pc,
                            i_org
                                AS x_org,
                            i_org_org
                                AS x_org_org,
                            pd_ap
                                AS x_ap,
                            ap.ap_ap_main
                                AS x_ap_ap_main,
                            (SELECT COUNT (*)
                               FROM uss_esr.pd_payment  pdp,
                                    uss_esr.pd_detail   pdd,
                                    npt_list
                              WHERE     pdp.pdp_pd = pd_id
                                    AND pdp.history_status = 'A'
                                    AND l_date BETWEEN pdp.pdp_start_dt
                                                   AND pdp.pdp_stop_dt
                                    AND pdp.pdp_npt = x_npt
                                    AND x_npt_code = '517'
                                    AND pdd.pdd_pdp = pdp_id
                                    AND l_date BETWEEN pdd.pdd_start_dt
                                                   AND pdd.pdd_stop_dt)
                                AS x_people_cnt,
                            (SELECT SUM (pdp.pdp_sum)
                               FROM uss_esr.pd_payment pdp, npt_list
                              WHERE     pdp.pdp_pd = pd_id
                                    AND pdp.history_status = 'A'
                                    AND l_date BETWEEN pdp.pdp_start_dt
                                                   AND pdp.pdp_stop_dt
                                    AND pdp.pdp_npt = x_npt
                                    AND x_npt_code = '515')
                                AS x_sum_515,
                            (SELECT SUM (pdp.pdp_sum)
                               FROM uss_esr.pd_payment pdp, npt_list
                              WHERE     pdp.pdp_pd = pd_id
                                    AND pdp.history_status = 'A'
                                    AND l_date BETWEEN pdp.pdp_start_dt
                                                   AND pdp.pdp_stop_dt
                                    AND pdp.pdp_npt = x_npt
                                    AND x_npt_code = '517')
                                AS x_sum_517
                       FROM uss_esr.pc_decision  pd,
                            uss_esr.appeal       ap,
                            org_list
                      WHERE     (   pd.pd_st = 'S'              /*Нараховано*/
                                 OR (    pd.pd_st = 'PS' /*Призупинено виплату*/
                                     AND EXISTS
                                             (SELECT 1
                                                FROM uss_ndi.v_ndi_reason_not_pay
                                                     r
                                                     LEFT JOIN
                                                     uss_esr.pc_block pcb
                                                         ON pd.pd_pcb =
                                                            pcb.pcb_id
                                               WHERE     r.rnp_id =
                                                         pcb.pcb_rnp
                                                     AND r.rnp_pnp_tp = 'CPY'
                                                     AND r.history_status =
                                                         'A')))
                            AND pd_nst = 275
                            AND pd.com_org = i_org
                            AND pd_ap = ap_id
                            AND EXISTS
                                    (SELECT 1
                                       FROM uss_esr.pd_accrual_period a
                                      WHERE     a.pdap_pd = pd_id
                                            AND a.history_status = 'A'
                                            AND l_date BETWEEN a.pdap_start_dt
                                                           AND a.pdap_stop_dt)
                            AND EXISTS
                                    (SELECT 1
                                       FROM uss_esr.pd_payment pdp, npt_list
                                      WHERE     pdp.pdp_pd = pd_id
                                            AND pdp.history_status = 'A'
                                            AND l_date BETWEEN pdp.pdp_start_dt
                                                           AND pdp.pdp_stop_dt
                                            AND pdp.pdp_npt = x_npt
                                            AND x_npt_code = '515')),
                pd_filter
                AS
                    (SELECT *
                       FROM pd_list p
                      WHERE     --скриваємо записи у яких споріднене рішення відсутне (вірогідно не в статусі Нараховано)
                                (   (    x_ap_ap_main IS NOT NULL
                                     AND EXISTS
                                             (SELECT 1
                                                FROM pd_list p2
                                               WHERE p.x_ap_ap_main = p2.x_ap))
                                 OR x_ap_ap_main IS NULL)
                            AND x_people_cnt > 0 --беремо тільки рішення де є утриманці
                                                ),
                pd_props_list
                AS
                    (SELECT x_pd,
                            x_org,
                            x_org_org,
                            x_ap,
                            x_ap_ap_main,
                            CASE
                                WHEN x_ap_ap_main IS NOT NULL
                                THEN
                                    (SELECT MAX (pd2.x_pc)
                                       FROM pd_filter pd2
                                      WHERE pd2.x_ap = p.x_ap_ap_main)
                                ELSE
                                    x_pc
                            END    AS x_pc,
                            x_people_cnt,
                            x_sum_515,
                            x_sum_517
                       FROM pd_filter p),
                src
                AS
                    (  SELECT x_org_org,
                              MAX (o_name)                                       AS o_name,
                              COUNT (DISTINCT x_pc)                              AS x_pc_515,
                              SUM (x_people_cnt)                                 AS x_people_515,
                              SUM (x_sum_515)                                    AS x_sum_515,
                              SUM (x_sum_517)                                    AS x_sum_517,
                              ROUND (SUM (x_sum_515) / COUNT (DISTINCT x_pc),
                                     2)                                          AS x_avg_515,
                              ROUND (SUM (x_sum_517) / SUM (x_people_cnt), 2)    AS x_avg_517
                         FROM pd_props_list, obl_list
                        WHERE x_org = o_org
                     GROUP BY x_org_org)
                SELECT ROWNUM, s.*
                  FROM src s
                UNION ALL
                SELECT NULL,
                       NULL,
                       'Разом',
                       SUM (x_pc_515),
                       SUM (x_people_515),
                       SUM (x_sum_515),
                       SUM (x_sum_517),
                       ROUND (SUM (x_sum_515) / SUM (x_pc_515), 2),
                       ROUND (SUM (x_sum_517) / SUM (x_people_515), 2)
                  FROM src s
                ORDER BY 2;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
       <Row ss:AutoFitHeight="0">
        <Cell ss:StyleID="s200"><Data ss:Type="Number">'
                   || TO_CHAR (x_id1)
                   || '</Data></Cell>
        <Cell ss:StyleID="s202"><Data ss:Type="Number">'
                   || TO_CHAR (x_id2)
                   || '</Data></Cell>
        <Cell ss:StyleID="s207"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
        <Cell ss:StyleID="s208"><Data ss:Type="Number">'
                   || TO_CHAR (x_id3)
                   || '</Data></Cell>
        <Cell ss:StyleID="s209"><Data ss:Type="Number">'
                   || TO_CHAR (x_id4)
                   || '</Data></Cell>
        <Cell ss:StyleID="s211"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum1, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s212"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum2, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s211"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum3, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s212"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum4, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
       </Row>'
         WHERE x_id1 IS NOT NULL;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
       <Row ss:AutoFitHeight="0">
        <Cell ss:StyleID="s392"></Cell>
        <Cell ss:StyleID="s392"></Cell>
        <Cell ss:StyleID="s394"><Data ss:Type="String">Разом</Data></Cell>
        <Cell ss:StyleID="s396"><Data ss:Type="Number">'
                   || TO_CHAR (x_id3)
                   || '</Data></Cell>
        <Cell ss:StyleID="s398"><Data ss:Type="Number">'
                   || TO_CHAR (x_id4)
                   || '</Data></Cell>
        <Cell ss:StyleID="s401"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum1, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s402"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum2, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s401"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum3, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s402"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum4, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
       </Row>'
         WHERE x_id1 IS NULL;
    END SET_CHILD_ORPHANS_R3;

    -- #109460 Вибірка щодо патронатних вихователів
    PROCEDURE SET_CHILD_ORPHANS_R4 (p_start_dt   IN DATE,
                                    p_org_id     IN NUMBER,
                                    p_jbr_id     IN DECIMAL)
    IS
        l_user_org   NUMBER;
        l_org_to     NUMBER := tools.GetCurrOrgTo;
        l_date       DATE;
    BEGIN
        IF p_org_id = 0
        THEN
            l_user_org := tools.GetCurrOrg;
        ELSE
            l_user_org := p_org_id;
        END IF;

        l_user_org :=
            CASE WHEN l_user_org = 50001 THEN 50000 ELSE l_user_org END;

        IF l_org_to = 34
        THEN
            SELECT org_to
              INTO l_org_to
              FROM ikis_sys.v_opfu
             WHERE org_id = l_user_org;
        END IF;

        l_org_to := CASE WHEN l_org_to = 34 THEN 34 ELSE 32 END;

        l_date := TRUNC (p_start_dt, 'mm');

        DELETE FROM tmp_univ_rpt_data
              WHERE 1 = 1;

        INSERT INTO tmp_univ_rpt_data (x_id1,                        -- ca Nзп
                                       x_id2,                     -- x_org_org
                                       x_string1,                    -- o_name
                                       x_id3,                      -- x_pc_515
                                       x_id4,                  -- x_people_515
                                       x_sum1,                    -- x_sum_515
                                       x_sum2,                    -- x_sum_517
                                       x_sum3,                     --x_avg_515
                                       x_sum4                      --x_avg_517
                                             )
            WITH
                org_list
                AS
                    (    SELECT org_id i_org, org_org i_org_org
                           FROM ikis_sys.v_opfu
                          WHERE l_org_to = 32
                     CONNECT BY PRIOR org_id = org_org
                     START WITH org_id = l_user_org
                     UNION ALL
                     SELECT org_id i_org, org_org i_org_org
                       FROM ikis_sys.v_opfu
                      WHERE l_org_to = 34 AND org_acc_org = l_user_org),
                obl_list
                AS
                    (  SELECT nok_org                     AS o_org,
                              MAX (l1_kaot_full_name)     AS o_name
                         FROM uss_ndi.v_ndi_org2kaot t
                              JOIN uss_ndi.mv_ndi_katottg ON nok_kaot = kaot_id
                        WHERE history_status = 'A'
                     GROUP BY nok_org),
                npt_list
                AS
                    (SELECT npt_id AS x_npt, npt_code AS x_npt_code
                       FROM uss_ndi.v_ndi_payment_type
                      WHERE npt_code IN ('523', '524')),
                pd_list
                AS
                    (SELECT pd_id
                                AS x_pd,
                            pd_pc
                                AS x_pc,
                            i_org
                                AS x_org,
                            i_org_org
                                AS x_org_org,
                            (SELECT COUNT (*)
                               FROM uss_esr.pd_payment  pdp,
                                    uss_esr.pd_detail   pdd,
                                    npt_list
                              WHERE     pdp.pdp_pd = pd_id
                                    AND pdp.history_status = 'A'
                                    AND l_date BETWEEN pdp.pdp_start_dt
                                                   AND pdp.pdp_stop_dt
                                    AND pdp.pdp_npt = x_npt
                                    AND x_npt_code = '524'
                                    AND pdd.pdd_pdp = pdp_id
                                    AND l_date BETWEEN pdd.pdd_start_dt
                                                   AND pdd.pdd_stop_dt)
                                AS x_people_cnt,
                            (SELECT SUM (pdp.pdp_sum)
                               FROM uss_esr.pd_payment pdp, npt_list
                              WHERE     pdp.pdp_pd = pd_id
                                    AND pdp.history_status = 'A'
                                    AND l_date BETWEEN pdp.pdp_start_dt
                                                   AND pdp.pdp_stop_dt
                                    AND pdp.pdp_npt = x_npt
                                    AND x_npt_code = '523')
                                AS x_sum_523,
                            (SELECT SUM (pdp.pdp_sum)
                               FROM uss_esr.pd_payment pdp, npt_list
                              WHERE     pdp.pdp_pd = pd_id
                                    AND pdp.history_status = 'A'
                                    AND l_date BETWEEN pdp.pdp_start_dt
                                                   AND pdp.pdp_stop_dt
                                    AND pdp.pdp_npt = x_npt
                                    AND x_npt_code = '524')
                                AS x_sum_524
                       FROM uss_esr.pc_decision  pd,
                            uss_esr.appeal       ap,
                            org_list
                      WHERE     (   pd.pd_st = 'S'              /*Нараховано*/
                                 OR (    pd.pd_st = 'PS' /*Призупинено виплату*/
                                     AND EXISTS
                                             (SELECT 1
                                                FROM uss_ndi.v_ndi_reason_not_pay
                                                     r
                                                     LEFT JOIN
                                                     uss_esr.pc_block pcb
                                                         ON pd.pd_pcb =
                                                            pcb.pcb_id
                                               WHERE     r.rnp_id =
                                                         pcb.pcb_rnp
                                                     AND r.rnp_pnp_tp = 'CPY'
                                                     AND r.history_status =
                                                         'A')))
                            AND pd_nst = 901
                            AND pd.com_org = i_org
                            AND pd_ap = ap_id
                            AND EXISTS
                                    (SELECT 1
                                       FROM uss_esr.pd_accrual_period a
                                      WHERE     a.pdap_pd = pd_id
                                            AND a.history_status = 'A'
                                            AND l_date BETWEEN a.pdap_start_dt
                                                           AND a.pdap_stop_dt)
                            --Лишаємо лише тих у кого є утриманці
                            AND EXISTS
                                    (SELECT 1
                                       FROM uss_esr.pd_payment pdp, npt_list
                                      WHERE     pdp.pdp_pd = pd_id
                                            AND pdp.history_status = 'A'
                                            AND l_date BETWEEN pdp.pdp_start_dt
                                                           AND pdp.pdp_stop_dt
                                            AND pdp.pdp_npt = x_npt
                                            AND x_npt_code = '524')),
                src
                AS
                    (  SELECT x_org_org,
                              MAX (o_name)                                       AS o_name,
                              COUNT (DISTINCT x_pc)                              AS x_pc_523,
                              SUM (x_people_cnt)                                 AS x_people_cnt,
                              SUM (x_sum_523)                                    AS x_sum_523,
                              SUM (x_sum_524)                                    AS x_sum_524,
                              ROUND (SUM (x_sum_523) / COUNT (DISTINCT x_pc),
                                     2)                                          AS x_avg_523,
                              ROUND (SUM (x_sum_524) / SUM (x_people_cnt), 2)    AS x_avg_524
                         FROM pd_list, obl_list
                        WHERE x_org = o_org
                     GROUP BY x_org_org)
                SELECT ROWNUM, s.*
                  FROM src s
                UNION ALL
                SELECT NULL,
                       NULL,
                       'Разом',
                       SUM (x_pc_523),
                       SUM (x_people_cnt),
                       SUM (x_sum_523),
                       SUM (x_sum_524),
                       ROUND (SUM (x_sum_523) / SUM (x_pc_523), 2),
                       ROUND (SUM (x_sum_524) / SUM (x_people_cnt), 2)
                  FROM src s
                ORDER BY 2;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
       <Row ss:AutoFitHeight="0">
        <Cell ss:StyleID="s200"><Data ss:Type="Number">'
                   || TO_CHAR (x_id1)
                   || '</Data></Cell>
        <Cell ss:StyleID="s202"><Data ss:Type="Number">'
                   || TO_CHAR (x_id2)
                   || '</Data></Cell>
        <Cell ss:StyleID="s207"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
        <Cell ss:StyleID="s208"><Data ss:Type="Number">'
                   || TO_CHAR (x_id3)
                   || '</Data></Cell>
        <Cell ss:StyleID="s209"><Data ss:Type="Number">'
                   || TO_CHAR (x_id4)
                   || '</Data></Cell>
        <Cell ss:StyleID="s211"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum1, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s212"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum2, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s211"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum3, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s212"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum4, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
       </Row>'
         WHERE x_id1 IS NOT NULL;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
       <Row ss:AutoFitHeight="0">
        <Cell ss:StyleID="s392"></Cell>
        <Cell ss:StyleID="s392"></Cell>
        <Cell ss:StyleID="s394"><Data ss:Type="String">Разом</Data></Cell>
        <Cell ss:StyleID="s396"><Data ss:Type="Number">'
                   || TO_CHAR (x_id3)
                   || '</Data></Cell>
        <Cell ss:StyleID="s398"><Data ss:Type="Number">'
                   || TO_CHAR (x_id4)
                   || '</Data></Cell>
        <Cell ss:StyleID="s401"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum1, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s402"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum2, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s401"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum3, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s402"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum4, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
       </Row>'
         WHERE x_id1 IS NULL;
    END SET_CHILD_ORPHANS_R4;

    -- #109334 Вибірка щодо патронатних вихователів та їх помічників
    PROCEDURE SET_CHILD_ORPHANS_R5 (p_start_dt   IN DATE,
                                    p_org_id     IN NUMBER,
                                    p_jbr_id     IN DECIMAL)
    IS
        l_user_org   NUMBER;
        l_org_to     NUMBER := tools.GetCurrOrgTo;
        l_date       DATE;
    BEGIN
        IF p_org_id = 0
        THEN
            l_user_org := tools.GetCurrOrg;
        ELSE
            l_user_org := p_org_id;
        END IF;

        l_user_org :=
            CASE WHEN l_user_org = 50001 THEN 50000 ELSE l_user_org END;

        IF l_org_to = 34
        THEN
            SELECT org_to
              INTO l_org_to
              FROM ikis_sys.v_opfu
             WHERE org_id = l_user_org;
        END IF;

        l_org_to := CASE WHEN l_org_to = 34 THEN 34 ELSE 32 END;

        l_date := TRUNC (p_start_dt, 'mm');

        DELETE FROM tmp_univ_rpt_data
              WHERE 1 = 1;

        INSERT INTO tmp_univ_rpt_data (x_id1,                        -- ca Nзп
                                       x_id2,                     -- x_org_org
                                       x_string1,                    -- o_name
                                       x_id3,                      -- x_pc_516
                                       x_id4,                  -- x_people_516
                                       x_id5,                      -- x_pc_515
                                       x_id6                   -- x_people_515
                                            )
            WITH
                org_list
                AS
                    (    SELECT org_id i_org, org_org i_org_org
                           FROM ikis_sys.v_opfu
                          WHERE l_org_to = 32
                     CONNECT BY PRIOR org_id = org_org
                     START WITH org_id = l_user_org
                     UNION ALL
                     SELECT org_id i_org, org_org i_org_org
                       FROM ikis_sys.v_opfu
                      WHERE l_org_to = 34 AND org_acc_org = l_user_org),
                obl_list
                AS
                    (  SELECT nok_org                     AS o_org,
                              MAX (l1_kaot_full_name)     AS o_name
                         FROM uss_ndi.v_ndi_org2kaot t
                              JOIN uss_ndi.mv_ndi_katottg ON nok_kaot = kaot_id
                        WHERE history_status = 'A'
                     GROUP BY nok_org),
                npt_list
                AS
                    (SELECT npt_id AS x_npt, npt_code AS x_npt_code
                       FROM uss_ndi.v_ndi_payment_type
                      WHERE npt_code IN ('524')),
                pd_list
                AS
                    (SELECT pd_id         AS x_pd,
                            pd_pc         AS x_pc,
                            pd_ap         AS x_ap,
                            pd_nst        AS x_nst,
                            i_org         AS x_org,
                            i_org_org     AS x_org_org
                       FROM uss_esr.pc_decision  pd,
                            uss_esr.appeal       ap,
                            org_list
                      WHERE     (   pd.pd_st = 'S'              /*Нараховано*/
                                 OR (    pd.pd_st = 'PS' /*Призупинено виплату*/
                                     AND EXISTS
                                             (SELECT 1
                                                FROM uss_ndi.v_ndi_reason_not_pay
                                                     r
                                                     LEFT JOIN
                                                     uss_esr.pc_block pcb
                                                         ON pd.pd_pcb =
                                                            pcb.pcb_id
                                               WHERE     r.rnp_id =
                                                         pcb.pcb_rnp
                                                     AND r.rnp_pnp_tp = 'CPY'
                                                     AND r.history_status =
                                                         'A')))
                            AND pd_nst IN (901, 1221)
                            AND pd.com_org = i_org
                            AND pd_ap = ap_id
                            AND EXISTS
                                    (SELECT 1
                                       FROM uss_esr.pd_accrual_period a
                                      WHERE     a.pdap_pd = pd_id
                                            AND a.history_status = 'A'
                                            AND l_date BETWEEN a.pdap_start_dt
                                                           AND a.pdap_stop_dt)),
                pd_901_list
                AS
                    (SELECT x_pd,
                            x_pc,
                            x_org,
                            x_org_org,
                            (SELECT COUNT (*)
                               FROM uss_esr.pd_payment  pdp,
                                    uss_esr.pd_detail   pdd,
                                    npt_list
                              WHERE     pdp.pdp_pd = x_pd
                                    AND pdp.history_status = 'A'
                                    AND l_date BETWEEN pdp.pdp_start_dt
                                                   AND pdp.pdp_stop_dt
                                    AND pdp.pdp_npt = x_npt
                                    AND x_npt_code = '524'
                                    AND pdd.pdd_pdp = pdp_id
                                    AND l_date BETWEEN pdd.pdd_start_dt
                                                   AND pdd.pdd_stop_dt)    AS x_people_524
                       FROM pd_list
                      WHERE     x_nst = 901
                            --Лишаємо лише тих у кого є утриманці
                            AND EXISTS
                                    (SELECT 1
                                       FROM uss_esr.pd_payment pdp, npt_list
                                      WHERE     pdp.pdp_pd = x_pd
                                            AND pdp.history_status = 'A'
                                            AND l_date BETWEEN pdp.pdp_start_dt
                                                           AND pdp.pdp_stop_dt
                                            AND pdp.pdp_npt = x_npt
                                            AND x_npt_code = '524')),
                src
                AS
                    (  SELECT x_org_org,
                              MAX (o_name)
                                  AS o_name,
                              COUNT (DISTINCT x_pc)
                                  AS x_pc_524,
                              SUM (x_people_524)
                                  AS x_people_524,
                              (SELECT COUNT (DISTINCT pd2.x_pc)
                                 FROM pd_list pd2
                                WHERE     pd2.x_nst = 1221
                                      AND pd2.x_org_org = pd.x_org_org)
                                  AS x_pc_527,
                              (SELECT COUNT (*)
                                 FROM pd_list pd2
                                WHERE     pd2.x_nst = 1221
                                      AND pd2.x_org_org = pd.x_org_org)
                                  AS x_people_527
                         FROM pd_901_list pd, obl_list
                        WHERE x_org = o_org
                     GROUP BY x_org_org)
                SELECT ROWNUM, s.*
                  FROM src s
                UNION ALL
                SELECT NULL,
                       NULL,
                       'Разом',
                       SUM (x_pc_524),
                       SUM (x_people_524),
                       SUM (x_pc_527),
                       SUM (x_people_527)
                  FROM src s
                ORDER BY 2;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
       <Row ss:AutoFitHeight="0">
        <Cell ss:StyleID="s200"><Data ss:Type="Number">'
                   || TO_CHAR (x_id1)
                   || '</Data></Cell>
        <Cell ss:StyleID="s202"><Data ss:Type="Number">'
                   || TO_CHAR (x_id2)
                   || '</Data></Cell>
        <Cell ss:StyleID="s207"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
        <Cell ss:StyleID="s208"><Data ss:Type="Number">'
                   || TO_CHAR (x_id3)
                   || '</Data></Cell>
        <Cell ss:StyleID="s209"><Data ss:Type="Number">'
                   || TO_CHAR (x_id4)
                   || '</Data></Cell>
        <Cell ss:StyleID="s211"><Data ss:Type="Number">'
                   || TO_CHAR (x_id5)
                   || '</Data></Cell>
        <Cell ss:StyleID="s212"><Data ss:Type="Number">'
                   || TO_CHAR (x_id6)
                   || '</Data></Cell>
       </Row>'
         WHERE x_id1 IS NOT NULL;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
       <Row ss:AutoFitHeight="0">
        <Cell ss:StyleID="s392"></Cell>
        <Cell ss:StyleID="s392"></Cell>
        <Cell ss:StyleID="s394"><Data ss:Type="String">Разом</Data></Cell>
        <Cell ss:StyleID="s396"><Data ss:Type="Number">'
                   || TO_CHAR (x_id3)
                   || '</Data></Cell>
        <Cell ss:StyleID="s398"><Data ss:Type="Number">'
                   || TO_CHAR (x_id4)
                   || '</Data></Cell>
        <Cell ss:StyleID="s401"><Data ss:Type="Number">'
                   || TO_CHAR (x_id5)
                   || '</Data></Cell>
        <Cell ss:StyleID="s402"><Data ss:Type="Number">'
                   || TO_CHAR (x_id6)
                   || '</Data></Cell>
       </Row>'
         WHERE x_id1 IS NULL;
    END SET_CHILD_ORPHANS_R5;

    -- #109460 Вибірка щодо помічників патронатних вихователів
    PROCEDURE SET_CHILD_ORPHANS_R6 (p_start_dt   IN DATE,
                                    p_org_id     IN NUMBER,
                                    p_jbr_id     IN DECIMAL)
    IS
        l_user_org   NUMBER;
        l_org_to     NUMBER := tools.GetCurrOrgTo;
        l_date       DATE;
    BEGIN
        IF p_org_id = 0
        THEN
            l_user_org := tools.GetCurrOrg;
        ELSE
            l_user_org := p_org_id;
        END IF;

        l_user_org :=
            CASE WHEN l_user_org = 50001 THEN 50000 ELSE l_user_org END;

        IF l_org_to = 34
        THEN
            SELECT org_to
              INTO l_org_to
              FROM ikis_sys.v_opfu
             WHERE org_id = l_user_org;
        END IF;

        l_org_to := CASE WHEN l_org_to = 34 THEN 34 ELSE 32 END;

        l_date := TRUNC (p_start_dt, 'mm');

        DELETE FROM tmp_univ_rpt_data
              WHERE 1 = 1;

        INSERT INTO tmp_univ_rpt_data (x_id1,                        -- ca Nзп
                                       x_id2,                     -- x_org_org
                                       x_string1,                    -- o_name
                                       x_id3,                          -- x_pc
                                       x_id4,                      -- x_people
                                       x_sum1,                        -- x_sum
                                       x_sum2                         -- x_avg
                                             )
            WITH
                org_list
                AS
                    (    SELECT org_id i_org, org_org i_org_org
                           FROM ikis_sys.v_opfu
                          WHERE l_org_to = 32
                     CONNECT BY PRIOR org_id = org_org
                     START WITH org_id = l_user_org
                     UNION ALL
                     SELECT org_id i_org, org_org i_org_org
                       FROM ikis_sys.v_opfu
                      WHERE l_org_to = 34 AND org_acc_org = l_user_org),
                obl_list
                AS
                    (  SELECT nok_org                     AS o_org,
                              MAX (l1_kaot_full_name)     AS o_name
                         FROM uss_ndi.v_ndi_org2kaot t
                              JOIN uss_ndi.mv_ndi_katottg ON nok_kaot = kaot_id
                        WHERE history_status = 'A'
                     GROUP BY nok_org),
                npt_list
                AS
                    (SELECT npt_id AS x_npt, npt_code AS x_npt_code
                       FROM uss_ndi.v_ndi_payment_type
                      WHERE npt_code IN ('527')),
                pd_list
                AS
                    (SELECT pd_id                              AS x_pd,
                            pd_pc                              AS x_pc,
                            i_org                              AS x_org,
                            i_org_org                          AS x_org_org,
                            (SELECT SUM (pdp.pdp_sum)
                               FROM uss_esr.pd_payment pdp, npt_list
                              WHERE     pdp.pdp_pd = pd_id
                                    AND pdp.history_status = 'A'
                                    AND l_date BETWEEN pdp.pdp_start_dt
                                                   AND pdp.pdp_stop_dt
                                    AND pdp.pdp_npt = x_npt
                                    AND x_npt_code = '527')    AS x_sum
                       FROM uss_esr.pc_decision  pd,
                            uss_esr.appeal       ap,
                            org_list
                      WHERE     (   pd.pd_st = 'S'              /*Нараховано*/
                                 OR (    pd.pd_st = 'PS' /*Призупинено виплату*/
                                     AND EXISTS
                                             (SELECT 1
                                                FROM uss_ndi.v_ndi_reason_not_pay
                                                     r
                                                     LEFT JOIN
                                                     uss_esr.pc_block pcb
                                                         ON pd.pd_pcb =
                                                            pcb.pcb_id
                                               WHERE     r.rnp_id =
                                                         pcb.pcb_rnp
                                                     AND r.rnp_pnp_tp = 'CPY'
                                                     AND r.history_status =
                                                         'A')))
                            AND pd_nst = 1221
                            AND pd.com_org = i_org
                            AND pd_ap = ap_id
                            AND EXISTS
                                    (SELECT 1
                                       FROM uss_esr.pd_accrual_period a
                                      WHERE     a.pdap_pd = pd_id
                                            AND a.history_status = 'A'
                                            AND l_date BETWEEN TRUNC (
                                                                   a.pdap_start_dt,
                                                                   'MM')
                                                           AND a.pdap_stop_dt)),
                src
                AS
                    (  SELECT x_org_org,
                              MAX (o_name)                                      AS o_name,
                              COUNT (DISTINCT x_pc)                             AS x_pc,
                              COUNT (*)                                         AS x_people,
                              SUM (x_sum)                                       AS x_sum,
                              ROUND (SUM (x_sum) / COUNT (DISTINCT x_pc), 2)    AS x_avg_523
                         FROM pd_list, obl_list
                        WHERE x_org = o_org
                     GROUP BY x_org_org)
                SELECT ROWNUM, s.*
                  FROM src s
                UNION ALL
                SELECT NULL,
                       NULL,
                       'Разом',
                       SUM (x_pc),
                       SUM (x_people),
                       SUM (x_sum),
                       ROUND (SUM (x_sum) / SUM (x_pc), 2)
                  FROM src s
                ORDER BY 2;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
       <Row ss:AutoFitHeight="0">
        <Cell ss:StyleID="s200"><Data ss:Type="Number">'
                   || TO_CHAR (x_id1)
                   || '</Data></Cell>
        <Cell ss:StyleID="s202"><Data ss:Type="Number">'
                   || TO_CHAR (x_id2)
                   || '</Data></Cell>
        <Cell ss:StyleID="s207"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
        <Cell ss:StyleID="s208"><Data ss:Type="Number">'
                   || TO_CHAR (x_id3)
                   || '</Data></Cell>
        <Cell ss:StyleID="s209"><Data ss:Type="Number">'
                   || TO_CHAR (x_id4)
                   || '</Data></Cell>
        <Cell ss:StyleID="s211"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum1, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s212"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum2, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
       </Row>'
         WHERE x_id1 IS NOT NULL;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
       <Row ss:AutoFitHeight="0">
        <Cell ss:StyleID="s392"></Cell>
        <Cell ss:StyleID="s392"></Cell>
        <Cell ss:StyleID="s394"><Data ss:Type="String">Разом</Data></Cell>
        <Cell ss:StyleID="s396"><Data ss:Type="Number">'
                   || TO_CHAR (x_id3)
                   || '</Data></Cell>
        <Cell ss:StyleID="s398"><Data ss:Type="Number">'
                   || TO_CHAR (x_id4)
                   || '</Data></Cell>
        <Cell ss:StyleID="s401"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum1, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
        <Cell ss:StyleID="s402"><Data ss:Type="Number">'
                   || TO_CHAR (NVL (x_sum2, 0), 'FM9999999999990.00')
                   || '</Data></Cell>
       </Row>'
         WHERE x_id1 IS NULL;
    END SET_CHILD_ORPHANS_R6;

    -- IC #88696 Звіт про надання  допомоги сім'ям з дітьми та тимчасової державної допомоги дітям, батьки яких ухиляються від сплати аліментів
    FUNCTION REP_CHILDREN_FML (p_start_dt   IN DATE,
                               p_org_id     IN NUMBER,
                               p_rt_id      IN rpt_templates.rt_id%TYPE)
        RETURN DECIMAL
    IS
        l_jbr_id      NUMBER;
        l_file_name   VARCHAR2 (128);
        l_sql         VARCHAR2 (10000);
        l_start_dt    DATE := TRUNC (p_start_dt, 'MM');
        l_org_name    v_opfu.org_name%TYPE;
    BEGIN
        tools.WriteMsg (PKG || '.' || $$PLSQL_UNIT);
        l_jbr_id := RDM$RTFL.InitReport (p_rt_id => p_rt_id);

        l_file_name :=
               'REP_CHILDREN_FML_'
            || TO_CHAR (l_start_dt, 'yyyy')
            || '_'
            || TO_CHAR (l_start_dt, 'mm')
            || '_'
            || p_org_id
            || '.xml.xls';

        ikis_sysweb.REPORTFL_ENGINE_EX.SetFileName (
            p_jbr_id      => l_jbr_id,
            p_file_name   => l_file_name);

        SELECT MAX (org_name)
          INTO l_org_name
          FROM v_opfu
         WHERE org_id =
               CASE
                   WHEN NVL (p_org_id, 0) = 0 THEN Tools.GetCurrOrg
                   ELSE p_org_id
               END;

        RDM$RTFL.AddParam (l_jbr_id, 'p_year', TO_CHAR (l_start_dt, 'yyyy'));
        RDM$RTFL.AddParam (l_jbr_id, 'p_month', TO_CHAR (l_start_dt, 'mm'));
        RDM$RTFL.AddParam (l_jbr_id, 'p_uszn', l_org_name);
        RDM$RTFL.AddParam (
            l_jbr_id,
            'p_ym',
               dnet$payment_reports.getMonthName (
                   TO_NUMBER (TO_CHAR (l_start_dt, 'mm')))
            || ' '
            || TO_CHAR (l_start_dt, 'yyyy'));

        RDM$RTFL.AddScript (
            l_jbr_id,
            'constants',
               'begin uss_esr.dnet$rpt_help_family.SET_CHILDREN_FML(to_date('''
            || TO_CHAR (l_start_dt, 'dd.mm.yyyy')
            || ''',''dd.mm.yyyy''), '
            || p_org_id
            || ', '
            || l_jbr_id
            || '); end;');

        l_sql := '
    select  x_id1 ca,      -- Nзп
            x_string1 cb,  -- Допомога
            x_sum1 a_assing,    -- (Призначено з початку року)
            x_sum2 a_assing_m,  -- (Призначено звітний місяць)
            x_id2 cnt_fml_6y,   -- (к-ть дітей до шести років)
            x_id3 cnt_fml_18y,  -- (к-ть дітей до 18 років)
            x_id4 cnt_fml_23y,  -- (к-ть дітей до 23 років за умови навчання)
            x_sum3 x_narah,     -- (нараховано допомог)
            x_sum4 x_borg,      -- (фактичний борг)
            x_sum5 a_payed,     -- (виплачено з початку року)
            x_sum6 a_payed_m,   -- (виплачено за звітний місяць)
            x_string2
        from uss_esr.tmp_univ_rpt_data order by 1';

        RDM$RTFL.AddDataSet (l_jbr_id, 'ds', l_sql);

        l_sql :=
            '
    select  sum(x_sum1) t_assing,    -- (Призначено з початку року)
            sum(x_sum2) t_assing_m,  -- (Призначено звітний місяць)
            sum(x_id2) t_cnt_fml_6y,   -- (к-ть дітей до шести років)
            sum(x_id3) t_cnt_fml_18y,  -- (к-ть дітей до 18 років)
            sum(x_id4) t_cnt_fml_23y,  -- (к-ть дітей до 23 років за умови навчання)
            sum(x_sum3) t_x_narah,     -- (нараховано допомог)
            sum(x_sum4) t_x_borg,      -- (фактичний борг)
            sum(x_sum5) t_a_payed,     -- (виплачено з початку року)
            sum(x_sum6) t_a_payed_m    -- (виплачено за звітний місяць)
        from uss_esr.tmp_univ_rpt_data';

        RDM$RTFL.AddDataSet (l_jbr_id, 'tds', l_sql);

        RDM$RTFL.PutReportToWorkingQueue (p_jbr_id => l_jbr_id);
        RETURN l_jbr_id;
    END REP_CHILDREN_FML;

    -- #109361 Вибірка щодо ДБСТ - Чисельність (батьки-вихователі)
    FUNCTION REP_CHILD_ORPHANS (p_start_dt   IN DATE,
                                p_org_id     IN NUMBER,
                                p_rt_id      IN rpt_templates.rt_id%TYPE)
        RETURN DECIMAL
    IS
        l_jbr_id      NUMBER;
        l_file_name   VARCHAR2 (128);
        l_sql         VARCHAR2 (10000);
        l_start_dt    DATE := TRUNC (p_start_dt, 'MM');
        l_org_name    v_opfu.org_name%TYPE;
    BEGIN
        tools.WriteMsg (PKG || '.' || $$PLSQL_UNIT);
        l_jbr_id := RDM$RTFL.InitReport (p_rt_id => p_rt_id);

        l_file_name :=
               'REP_CHILD_ORPHANS_'
            || TO_CHAR (l_start_dt, 'yyyy')
            || '_'
            || TO_CHAR (l_start_dt, 'mm')
            || '_'
            || p_org_id
            || '.xml.xls';
        RDM$RTFL.SetFileName (p_jbr_id => l_jbr_id, p_file_name => l_file_name);

        SELECT MAX (org_name)
          INTO l_org_name
          FROM v_opfu
         WHERE org_id =
               CASE
                   WHEN NVL (p_org_id, 0) = 0 THEN tools.getcurrorg
                   ELSE p_org_id
               END;

        RDM$RTFL.AddParam (l_jbr_id, 'p_year', TO_CHAR (l_start_dt, 'yyyy'));
        RDM$RTFL.AddParam (l_jbr_id, 'p_month', TO_CHAR (l_start_dt, 'mm'));
        RDM$RTFL.AddParam (l_jbr_id, 'p_uszn', l_org_name);
        RDM$RTFL.AddParam (
            l_jbr_id,
            'p_ym',
               dnet$payment_reports.getMonthName (
                   TO_NUMBER (TO_CHAR (l_start_dt, 'mm')))
            || ' '
            || TO_CHAR (l_start_dt, 'yyyy'));

        RDM$RTFL.AddScript (
            l_jbr_id,
            'constants',
               'begin uss_esr.dnet$rpt_help_family.SET_CHILD_ORPHANS(to_date('''
            || TO_CHAR (l_start_dt, 'dd.mm.yyyy')
            || ''',''dd.mm.yyyy''), '
            || p_org_id
            || ', '
            || l_jbr_id
            || '); end;');

        l_sql :=
            'select x_string2 from uss_esr.tmp_univ_rpt_data order by x_id1';
        RDM$RTFL.AddDataSet (l_jbr_id, 'ds', l_sql);

        RDM$RTFL.PutReportToWorkingQueue (p_jbr_id => l_jbr_id);
        RETURN l_jbr_id;
    END REP_CHILD_ORPHANS;

    -- #109460 Вибірка щодо батьків-вихователів
    FUNCTION REP_CHILD_ORPHANS_R2 (p_start_dt   IN DATE,
                                   p_org_id     IN NUMBER,
                                   p_rt_id      IN rpt_templates.rt_id%TYPE)
        RETURN DECIMAL
    IS
        l_jbr_id      NUMBER;
        l_file_name   VARCHAR2 (128);
        l_sql         VARCHAR2 (10000);
        l_start_dt    DATE := TRUNC (p_start_dt, 'MM');
        l_org_name    v_opfu.org_name%TYPE;
    BEGIN
        tools.WriteMsg (PKG || '.' || $$PLSQL_UNIT);
        l_jbr_id := RDM$RTFL.InitReport (p_rt_id => p_rt_id);

        l_file_name :=
               'REP_CHILD_ORPHANS_R2_'
            || TO_CHAR (l_start_dt, 'yyyy')
            || '_'
            || TO_CHAR (l_start_dt, 'mm')
            || '_'
            || p_org_id
            || '.xml.xls';
        RDM$RTFL.SetFileName (p_jbr_id => l_jbr_id, p_file_name => l_file_name);

        SELECT MAX (org_name)
          INTO l_org_name
          FROM v_opfu
         WHERE org_id =
               CASE
                   WHEN NVL (p_org_id, 0) = 0 THEN tools.getcurrorg
                   ELSE p_org_id
               END;

        RDM$RTFL.AddParam (l_jbr_id, 'p_year', TO_CHAR (l_start_dt, 'yyyy'));
        RDM$RTFL.AddParam (l_jbr_id, 'p_month', TO_CHAR (l_start_dt, 'mm'));
        RDM$RTFL.AddParam (l_jbr_id, 'p_uszn', l_org_name);
        RDM$RTFL.AddParam (
            l_jbr_id,
            'p_ym',
               dnet$payment_reports.getMonthName (
                   TO_NUMBER (TO_CHAR (l_start_dt, 'mm')))
            || ' '
            || TO_CHAR (l_start_dt, 'yyyy'));

        RDM$RTFL.AddScript (
            l_jbr_id,
            'constants',
               'begin uss_esr.dnet$rpt_help_family.SET_CHILD_ORPHANS_R2(to_date('''
            || TO_CHAR (l_start_dt, 'dd.mm.yyyy')
            || ''',''dd.mm.yyyy''), '
            || p_org_id
            || ', '
            || l_jbr_id
            || '); end;');

        l_sql :=
            'select x_string2 from uss_esr.tmp_univ_rpt_data order by x_id1';
        RDM$RTFL.AddDataSet (l_jbr_id, 'ds', l_sql);

        RDM$RTFL.PutReportToWorkingQueue (p_jbr_id => l_jbr_id);
        RETURN l_jbr_id;
    END REP_CHILD_ORPHANS_R2;

    -- #109460 Вибірка щодо прийомних сімей
    FUNCTION REP_CHILD_ORPHANS_R3 (p_start_dt   IN DATE,
                                   p_org_id     IN NUMBER,
                                   p_rt_id      IN rpt_templates.rt_id%TYPE)
        RETURN DECIMAL
    IS
        l_jbr_id      NUMBER;
        l_file_name   VARCHAR2 (128);
        l_sql         VARCHAR2 (10000);
        l_start_dt    DATE := TRUNC (p_start_dt, 'MM');
        l_org_name    v_opfu.org_name%TYPE;
    BEGIN
        tools.WriteMsg (PKG || '.' || $$PLSQL_UNIT);
        l_jbr_id := RDM$RTFL.InitReport (p_rt_id => p_rt_id);

        l_file_name :=
               'REP_CHILD_ORPHANS_R3_'
            || TO_CHAR (l_start_dt, 'yyyy')
            || '_'
            || TO_CHAR (l_start_dt, 'mm')
            || '_'
            || p_org_id
            || '.xml.xls';
        RDM$RTFL.SetFileName (p_jbr_id => l_jbr_id, p_file_name => l_file_name);

        SELECT MAX (org_name)
          INTO l_org_name
          FROM v_opfu
         WHERE org_id =
               CASE
                   WHEN NVL (p_org_id, 0) = 0 THEN tools.getcurrorg
                   ELSE p_org_id
               END;

        RDM$RTFL.AddParam (l_jbr_id, 'p_year', TO_CHAR (l_start_dt, 'yyyy'));
        RDM$RTFL.AddParam (l_jbr_id, 'p_month', TO_CHAR (l_start_dt, 'mm'));
        RDM$RTFL.AddParam (l_jbr_id, 'p_uszn', l_org_name);
        RDM$RTFL.AddParam (
            l_jbr_id,
            'p_ym',
               dnet$payment_reports.getMonthName (
                   TO_NUMBER (TO_CHAR (l_start_dt, 'mm')))
            || ' '
            || TO_CHAR (l_start_dt, 'yyyy'));

        RDM$RTFL.AddScript (
            l_jbr_id,
            'constants',
               'begin uss_esr.dnet$rpt_help_family.SET_CHILD_ORPHANS_R3(to_date('''
            || TO_CHAR (l_start_dt, 'dd.mm.yyyy')
            || ''',''dd.mm.yyyy''), '
            || p_org_id
            || ', '
            || l_jbr_id
            || '); end;');

        l_sql :=
            'select x_string2 from uss_esr.tmp_univ_rpt_data order by x_id1';
        RDM$RTFL.AddDataSet (l_jbr_id, 'ds', l_sql);

        RDM$RTFL.PutReportToWorkingQueue (p_jbr_id => l_jbr_id);
        RETURN l_jbr_id;
    END REP_CHILD_ORPHANS_R3;

    -- #109460 Вибірка щодо патронатних вихователів
    FUNCTION REP_CHILD_ORPHANS_R4 (p_start_dt   IN DATE,
                                   p_org_id     IN NUMBER,
                                   p_rt_id      IN rpt_templates.rt_id%TYPE)
        RETURN DECIMAL
    IS
        l_jbr_id      NUMBER;
        l_file_name   VARCHAR2 (128);
        l_sql         VARCHAR2 (10000);
        l_start_dt    DATE := TRUNC (p_start_dt, 'MM');
        l_org_name    v_opfu.org_name%TYPE;
    BEGIN
        tools.WriteMsg (PKG || '.' || $$PLSQL_UNIT);
        l_jbr_id := RDM$RTFL.InitReport (p_rt_id => p_rt_id);

        l_file_name :=
               'REP_CHILD_ORPHANS_R4_'
            || TO_CHAR (l_start_dt, 'yyyy')
            || '_'
            || TO_CHAR (l_start_dt, 'mm')
            || '_'
            || p_org_id
            || '.xml.xls';
        RDM$RTFL.SetFileName (p_jbr_id => l_jbr_id, p_file_name => l_file_name);

        SELECT MAX (org_name)
          INTO l_org_name
          FROM v_opfu
         WHERE org_id =
               CASE
                   WHEN NVL (p_org_id, 0) = 0 THEN tools.getcurrorg
                   ELSE p_org_id
               END;

        RDM$RTFL.AddParam (l_jbr_id, 'p_year', TO_CHAR (l_start_dt, 'yyyy'));
        RDM$RTFL.AddParam (l_jbr_id, 'p_month', TO_CHAR (l_start_dt, 'mm'));
        RDM$RTFL.AddParam (l_jbr_id, 'p_uszn', l_org_name);
        RDM$RTFL.AddParam (
            l_jbr_id,
            'p_ym',
               dnet$payment_reports.getMonthName (
                   TO_NUMBER (TO_CHAR (l_start_dt, 'mm')))
            || ' '
            || TO_CHAR (l_start_dt, 'yyyy'));

        RDM$RTFL.AddScript (
            l_jbr_id,
            'constants',
               'begin uss_esr.dnet$rpt_help_family.SET_CHILD_ORPHANS_R4(to_date('''
            || TO_CHAR (l_start_dt, 'dd.mm.yyyy')
            || ''',''dd.mm.yyyy''), '
            || p_org_id
            || ', '
            || l_jbr_id
            || '); end;');

        l_sql :=
            'select x_string2 from uss_esr.tmp_univ_rpt_data order by x_id1';
        RDM$RTFL.AddDataSet (l_jbr_id, 'ds', l_sql);

        RDM$RTFL.PutReportToWorkingQueue (p_jbr_id => l_jbr_id);
        RETURN l_jbr_id;
    END REP_CHILD_ORPHANS_R4;

    -- #109460 Вибірка щодо патронатних вихователів та їх помічників
    FUNCTION REP_CHILD_ORPHANS_R5 (p_start_dt   IN DATE,
                                   p_org_id     IN NUMBER,
                                   p_rt_id      IN rpt_templates.rt_id%TYPE)
        RETURN DECIMAL
    IS
        l_jbr_id      NUMBER;
        l_file_name   VARCHAR2 (128);
        l_sql         VARCHAR2 (10000);
        l_start_dt    DATE := TRUNC (p_start_dt, 'MM');
        l_org_name    v_opfu.org_name%TYPE;
    BEGIN
        tools.WriteMsg (PKG || '.' || $$PLSQL_UNIT);
        l_jbr_id := RDM$RTFL.InitReport (p_rt_id => p_rt_id);

        l_file_name :=
               'REP_CHILD_ORPHANS_R5_'
            || TO_CHAR (l_start_dt, 'yyyy')
            || '_'
            || TO_CHAR (l_start_dt, 'mm')
            || '_'
            || p_org_id
            || '.xml.xls';
        RDM$RTFL.SetFileName (p_jbr_id => l_jbr_id, p_file_name => l_file_name);

        SELECT MAX (org_name)
          INTO l_org_name
          FROM v_opfu
         WHERE org_id =
               CASE
                   WHEN NVL (p_org_id, 0) = 0 THEN tools.getcurrorg
                   ELSE p_org_id
               END;

        RDM$RTFL.AddParam (l_jbr_id, 'p_year', TO_CHAR (l_start_dt, 'yyyy'));
        RDM$RTFL.AddParam (l_jbr_id, 'p_month', TO_CHAR (l_start_dt, 'mm'));
        RDM$RTFL.AddParam (l_jbr_id, 'p_uszn', l_org_name);
        RDM$RTFL.AddParam (
            l_jbr_id,
            'p_ym',
               dnet$payment_reports.getMonthName (
                   TO_NUMBER (TO_CHAR (l_start_dt, 'mm')))
            || ' '
            || TO_CHAR (l_start_dt, 'yyyy'));

        RDM$RTFL.AddScript (
            l_jbr_id,
            'constants',
               'begin uss_esr.dnet$rpt_help_family.SET_CHILD_ORPHANS_R5(to_date('''
            || TO_CHAR (l_start_dt, 'dd.mm.yyyy')
            || ''',''dd.mm.yyyy''), '
            || p_org_id
            || ', '
            || l_jbr_id
            || '); end;');

        l_sql :=
            'select x_string2 from uss_esr.tmp_univ_rpt_data order by x_id1';
        RDM$RTFL.AddDataSet (l_jbr_id, 'ds', l_sql);

        RDM$RTFL.PutReportToWorkingQueue (p_jbr_id => l_jbr_id);
        RETURN l_jbr_id;
    END REP_CHILD_ORPHANS_R5;

    -- #109460 Вибірка щодо помічників патронатних вихователів
    FUNCTION REP_CHILD_ORPHANS_R6 (p_start_dt   IN DATE,
                                   p_org_id     IN NUMBER,
                                   p_rt_id      IN rpt_templates.rt_id%TYPE)
        RETURN DECIMAL
    IS
        l_jbr_id      NUMBER;
        l_file_name   VARCHAR2 (128);
        l_sql         VARCHAR2 (10000);
        l_start_dt    DATE := TRUNC (p_start_dt, 'MM');
        l_org_name    v_opfu.org_name%TYPE;
    BEGIN
        tools.WriteMsg (PKG || '.' || $$PLSQL_UNIT);
        l_jbr_id := RDM$RTFL.InitReport (p_rt_id => p_rt_id);

        l_file_name :=
               'REP_CHILD_ORPHANS_R6_'
            || TO_CHAR (l_start_dt, 'yyyy')
            || '_'
            || TO_CHAR (l_start_dt, 'mm')
            || '_'
            || p_org_id
            || '.xml.xls';
        RDM$RTFL.SetFileName (p_jbr_id => l_jbr_id, p_file_name => l_file_name);

        SELECT MAX (org_name)
          INTO l_org_name
          FROM v_opfu
         WHERE org_id =
               CASE
                   WHEN NVL (p_org_id, 0) = 0 THEN tools.getcurrorg
                   ELSE p_org_id
               END;

        RDM$RTFL.AddParam (l_jbr_id, 'p_year', TO_CHAR (l_start_dt, 'yyyy'));
        RDM$RTFL.AddParam (l_jbr_id, 'p_month', TO_CHAR (l_start_dt, 'mm'));
        RDM$RTFL.AddParam (l_jbr_id, 'p_uszn', l_org_name);
        RDM$RTFL.AddParam (
            l_jbr_id,
            'p_ym',
               dnet$payment_reports.getMonthName (
                   TO_NUMBER (TO_CHAR (l_start_dt, 'mm')))
            || ' '
            || TO_CHAR (l_start_dt, 'yyyy'));

        RDM$RTFL.AddScript (
            l_jbr_id,
            'constants',
               'begin uss_esr.dnet$rpt_help_family.SET_CHILD_ORPHANS_R6(to_date('''
            || TO_CHAR (l_start_dt, 'dd.mm.yyyy')
            || ''',''dd.mm.yyyy''), '
            || p_org_id
            || ', '
            || l_jbr_id
            || '); end;');

        l_sql :=
            'select x_string2 from uss_esr.tmp_univ_rpt_data order by x_id1';
        RDM$RTFL.AddDataSet (l_jbr_id, 'ds', l_sql);

        RDM$RTFL.PutReportToWorkingQueue (p_jbr_id => l_jbr_id);
        RETURN l_jbr_id;
    END REP_CHILD_ORPHANS_R6;
END dnet$rpt_help_family;
/