/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$PAYMENT_LONG_REP
IS
    FUNCTION getMonthName (p_mnum NUMBER, p_vidm CHAR:= 'N' -- N,R,D,Z,O,M,K (називний, родовий, давальний...)
                                                           )
        RETURN VARCHAR2;

    PROCEDURE SET_DSDI_R1 (p_start_dt   IN DATE,
                           p_org_id     IN NUMBER,
                           p_jbr_id     IN DECIMAL);

    PROCEDURE SET_PAY_TP_DECISION_R1 (p_dt        IN DATE,
                                      p_org_ids   IN VARCHAR2,
                                      p_npt_ids   IN VARCHAR2,
                                      p_jbr_id    IN DECIMAL);

    PROCEDURE SET_DISABILITY_INFO_R1 (p_start_dt    IN DATE,
                                      p_org_id      IN NUMBER,
                                      p_inv_gr      IN VARCHAR2,
                                      p_inv_chld    IN VARCHAR2,
                                      p_inv_pers    IN VARCHAR2,
                                      p_kaot_code   IN VARCHAR2,
                                      p_jbr_id      IN DECIMAL);

    PROCEDURE RegisterReport (p_rt_id      IN     NUMBER,
                              p_start_dt   IN     DATE,
                              p_stop_dt    IN     DATE,
                              p_org_id     IN     NUMBER,
                              p_val_1      IN     VARCHAR2,
                              p_val_2      IN     VARCHAR2,
                              p_val_3      IN     VARCHAR2,
                              p_val_4      IN     VARCHAR2,
                              p_jbr_id        OUT DECIMAL);

    PROCEDURE GET_DBF_REPORT (P_NNF_ID      IN     NUMBER,
                              P_IDS         IN     VARCHAR2,
                              P_DT          IN     DATE,
                              P_JBR_ID         OUT NUMBER,
                              P_FILE_NAME      OUT VARCHAR2);

    PROCEDURE BUILD_TAX_1DF_DBF_REPORT (                          -- IC #90202
                                        P_NNF_ID IN NUMBER, P_DT IN DATE);

    PROCEDURE BUILD_NRH_ESV_DBF_REPORT (                          -- IC #90138
                                        P_NNF_ID IN NUMBER, P_DT IN DATE);

    FUNCTION get_doc_string (p_app   ap_document.apd_app%TYPE,
                             p_ap    ap_document.apd_ap%TYPE,
                             p_ndt   ap_document.apd_ndt%TYPE,
                             p_nda   ap_document_attr.apda_nda%TYPE)
        RETURN VARCHAR2;

    -- IC Отримання МЗП на дату
    FUNCTION get_MZP (p_date DATE, p_type VARCHAR2:= 'min')
        RETURN NUMBER;

    FUNCTION phone_clear (p_text IN VARCHAR2)
        RETURN VARCHAR2;
END dnet$payment_long_rep;
/


GRANT EXECUTE ON USS_ESR.DNET$PAYMENT_LONG_REP TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$PAYMENT_LONG_REP TO IKIS_RBM
/

GRANT EXECUTE ON USS_ESR.DNET$PAYMENT_LONG_REP TO USS_PERSON
/

GRANT EXECUTE ON USS_ESR.DNET$PAYMENT_LONG_REP TO USS_RPT
/

GRANT EXECUTE ON USS_ESR.DNET$PAYMENT_LONG_REP TO USS_VISIT
/


/* Formatted on 8/12/2025 5:49:35 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$PAYMENT_LONG_REP
IS
    FUNCTION getMonthName (p_mnum NUMBER, p_vidm CHAR:= 'N' -- N,R,D,Z,O,M,K (називний, родовий, давальний...)
                                                           )
        RETURN VARCHAR2
    IS
        l_mname   VARCHAR2 (16);
    BEGIN
        SELECT CASE p_mnum
                   WHEN 1 THEN 'січень'
                   WHEN 2 THEN 'лютий'
                   WHEN 3 THEN 'березень'
                   WHEN 4 THEN 'квітень'
                   WHEN 5 THEN 'травень'
                   WHEN 6 THEN 'червень'
                   WHEN 7 THEN 'липень'
                   WHEN 8 THEN 'серпень'
                   WHEN 9 THEN 'вересень'
                   WHEN 10 THEN 'жовтень'
                   WHEN 11 THEN 'листопад'
                   WHEN 12 THEN 'грудень'
                   ELSE NULL
               END
          INTO l_mname
          FROM DUAL;

        RETURN l_mname;
    END getMonthName;

    -- IC #91166 Звіт про надання державної соціальної допомоги інвалідам з дитинства та дітям-інвалідам
    PROCEDURE SET_DSDI_R1 (p_start_dt   IN DATE,
                           p_org_id     IN NUMBER,
                           p_jbr_id     IN DECIMAL)
    IS
        l_user_org   NUMBER;

        l_sum        NUMBER;
        l_prc        NUMBER;
        l_tmp        tmp_univ_rpt_data%ROWTYPE;
        l_org_to     NUMBER := tools.GetCurrOrgTo;
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

        DELETE FROM uss_esr.tmp_assign_rpt_data
              WHERE 1 = 1;

        INSERT INTO uss_esr.tmp_assign_rpt_data (a_pc,
                                                 a_pd,
                                                 a_ap,
                                                 pdf_sc,
                                                 a_assing,
                                                 is_new_y,
                                                 is_new,
                                                 year_old,
                                                 inv_pers,
                                                 inv_chld,
                                                 inv_gr,
                                                 inv_subgr,
                                                 is_dutr,
                                                 is_aes,
                                                 is_lon,
                                                 rn,
                                                 nptc_npt)
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
                      WHERE l_org_to = 34 AND org_acc_org = l_user_org)
                SELECT pc_id                                   a_pc,
                       d.pd_id                                 a_pd,
                       d.pd_ap                                 a_ap,
                       f.pdf_sc,
                       NVL (pd.pdd_value, pdp_sum)             a_assing,
                       CASE
                           WHEN d.pd_start_dt >= TRUNC (p_start_dt, 'yy')
                           THEN
                               1
                           ELSE
                               0
                       END                                     is_new_y,
                       CASE
                           WHEN d.pd_start_dt >= TRUNC (p_start_dt, 'mm')
                           THEN
                               1
                           ELSE
                               0
                       END                                     is_new,
                       CASE
                           WHEN f.pdf_birth_dt > ADD_MONTHS (p_start_dt, -72)
                           THEN
                               6
                           WHEN f.pdf_birth_dt >
                                ADD_MONTHS (p_start_dt, -216)
                           THEN
                               18
                           ELSE
                               100
                       END                                     year_old,
                       (SELECT MAX (1)
                          FROM uss_esr.ap_person         pp,
                               uss_esr.ap_document       ad,
                               uss_esr.ap_document_attr  da
                         WHERE     pp.app_sc = f.pdf_sc
                               AND pp.app_ap = d.pd_ap
                               AND pp.app_ap = ad.apd_ap
                               AND pp.app_id = ad.apd_app
                               AND ad.apd_id = da.apda_apd
                               AND da.apda_nda IN (353, -- причина інвалідності
                                                        645) -- Особа з інвалідністю з дитинства
                               AND (   da.apda_val_string = 'ID' -- Інвалідність з дитинства
                                    OR da.apda_nda = 645)
                               AND da.history_status = 'A')    inv_pers,
                       (SELECT MAX (da.apda_val_string) -- DI/DIA (Дитина з інвалідністю/Дитина з інвалідністю підгрупи "А")
                          FROM uss_esr.ap_person         pp,
                               uss_esr.ap_document       ad,
                               uss_esr.ap_document_attr  da
                         WHERE     pp.app_sc = f.pdf_sc
                               AND pp.app_ap = d.pd_ap
                               AND pp.app_ap = ad.apd_ap
                               AND pp.app_id = ad.apd_app
                               AND ad.apd_id = da.apda_apd
                               AND da.apda_nda IN (797)           -- категорія
                               AND da.history_status = 'A')    inv_chld,
                       (SELECT MAX (da.apda_val_string)
                          FROM uss_esr.ap_person         pp,
                               uss_esr.ap_document       ad,
                               uss_esr.ap_document_attr  da
                         WHERE     pp.app_sc = f.pdf_sc
                               AND pp.app_ap = d.pd_ap
                               AND pp.app_ap = ad.apd_ap
                               AND pp.app_id = ad.apd_app
                               AND ad.apd_id = da.apda_apd
                               AND da.apda_nda IN (349, 666, 1790)
                               AND da.apda_val_string IN ('1', '2', '3')
                               AND da.history_status = 'A')    inv_gr,
                       (SELECT MAX (da.apda_val_string)
                          FROM uss_esr.ap_person         pp,
                               uss_esr.ap_document       ad,
                               uss_esr.ap_document_attr  da
                         WHERE     pp.app_sc = f.pdf_sc
                               AND pp.app_ap = d.pd_ap
                               AND pp.app_ap = ad.apd_ap
                               AND pp.app_id = ad.apd_app
                               AND ad.apd_id = da.apda_apd
                               AND da.apda_nda IN (791, 1792, 1792)
                               AND da.apda_val_string = 'A'
                               AND da.history_status = 'A')    inv_subgr,
                       (SELECT MAX (1)
                          FROM uss_esr.ap_person         pp,
                               uss_esr.ap_document       ad,
                               uss_esr.ap_document_attr  da
                         WHERE     pp.app_sc = f.pdf_sc
                               AND pp.app_ap = d.pd_ap
                               AND pp.app_ap = ad.apd_ap
                               AND pp.app_id = ad.apd_app
                               AND ad.apd_id = da.apda_apd
                               AND da.apda_val_string = 'T'
                               AND da.apda_nda IN (677) -- Знаходиться на держутриманні
                               AND da.history_status = 'A')    is_dutr,
                       (SELECT MAX (1)
                          FROM uss_esr.ap_person         pp,
                               uss_esr.ap_document       ad,
                               uss_esr.ap_document_attr  da
                         WHERE     pp.app_sc = f.pdf_sc
                               AND pp.app_ap = d.pd_ap
                               AND pp.app_ap = ad.apd_ap
                               AND pp.app_id = ad.apd_app
                               AND ad.apd_id = da.apda_apd
                               AND da.apda_val_string = 'T'
                               AND da.apda_nda IN (942) -- Дитина з інвалідністю внаслідок аварії на ЧАЕС
                               AND da.history_status = 'A')    is_AES,
                       (SELECT MAX (1)
                          FROM uss_esr.ap_person         pp,
                               uss_esr.ap_document       ad,
                               uss_esr.ap_document_attr  da
                         WHERE /*pp.app_sc = f.pdf_sc
                             and*/
                                   pp.app_ap = d.pd_ap
                               AND pp.app_ap = ad.apd_ap
                               AND pp.app_id = ad.apd_app
                               AND ad.apd_id = da.apda_apd
                               AND da.apda_val_string = 'T'
                               AND da.apda_nda IN (641)    -- Одинока/одинокий
                               AND da.history_status = 'A')    is_lon,
                       --row_number() over(partition by d.pd_id, nnc.nptc_npt, pp.pdp_id order by f.pdf_pd, nnc.nptc_npt)    rn,
                       1                                       rn,
                       NVL (pd.pdd_npt, nnc.nptc_npt)          nptc_npt
                  FROM ikis_sys.v_opfu  o
                       INNER JOIN org ON i_org = org_id
                       INNER JOIN uss_esr.personalcase pc
                           ON pc.com_org = o.org_id
                       INNER JOIN uss_esr.pc_decision d ON d.pd_pc = pc.pc_id
                       INNER JOIN uss_esr.pd_family f
                           ON     f.pdf_pd = d.pd_id
                              AND NOT EXISTS
                                      (SELECT 1
                                         FROM uss_esr.ap_person p
                                        WHERE     p.app_ap = d.pd_ap
                                              AND p.app_sc = f.pdf_sc
                                              AND p.history_status = 'A'
                                              AND p.app_tp = 'P') -- Представник заявника
                       INNER JOIN uss_esr.pd_payment pp
                           ON pp.pdp_pd = d.pd_id
                       INNER JOIN uss_esr.pd_accrual_period pdap
                           ON pdap.pdap_pd = d.pd_id
                       INNER JOIN uss_ndi.v_Ndi_Npt_Config nnc
                           ON nnc.nptc_npt = pp.pdp_npt
                       INNER JOIN uss_ndi.v_ndi_service_type st
                           ON st.nst_id = nnc.nptc_nst
                       LEFT JOIN uss_esr.pd_detail pd
                           ON     pd.pdd_pdp = pp.pdp_id
                              AND pd.pdd_key = f.pdf_id
                 WHERE     o.org_to = 32
                       AND pp.history_status = 'A'
                       AND pdap.history_status = 'A'
                       AND st.nst_id = 248 -- Державна соціальна допомога особам з інвалідністю з дитинства та дітям з інвалідністю
                       AND p_start_dt BETWEEN TRUNC (pdap.pdap_start_dt,
                                                     'mm')
                                          AND pdap.pdap_stop_dt
                       AND p_start_dt BETWEEN TRUNC (pp.pdp_start_dt, 'mm')
                                          AND pp.pdp_stop_dt
                -- and d.pd_id = 701
                UNION ALL
                SELECT pc_id                                   a_pc,
                       d.pd_id                                 a_pd,
                       d.pd_ap                                 a_ap,
                       f.pdf_sc,
                       NVL (pd.pdd_value, pdp_sum)             a_assing,
                       CASE
                           WHEN d.pd_start_dt >= TRUNC (p_start_dt, 'yy')
                           THEN
                               1
                           ELSE
                               0
                       END                                     is_new_y,
                       CASE
                           WHEN d.pd_start_dt >= TRUNC (p_start_dt, 'mm')
                           THEN
                               1
                           ELSE
                               0
                       END                                     is_new,
                       CASE
                           WHEN f.pdf_birth_dt > ADD_MONTHS (p_start_dt, -72)
                           THEN
                               6
                           WHEN f.pdf_birth_dt >
                                ADD_MONTHS (p_start_dt, -216)
                           THEN
                               18
                           ELSE
                               100
                       END                                     year_old,
                       (SELECT MAX (1)
                          FROM uss_esr.ap_person         pp,
                               uss_esr.ap_document       ad,
                               uss_esr.ap_document_attr  da
                         WHERE     pp.app_sc = f.pdf_sc
                               --and pp.app_ap = d.pd_ap
                               AND pp.app_ap = ad.apd_ap
                               AND pp.app_id = ad.apd_app
                               AND ad.apd_id = da.apda_apd
                               AND da.apda_nda IN (353, -- причина інвалідності
                                                        645) -- Особа з інвалідністю з дитинства
                               AND (   da.apda_val_string = 'ID' -- Інвалідність з дитинства
                                    OR da.apda_nda = 645)
                               AND da.history_status = 'A')    inv_pers,
                       (SELECT MAX (da.apda_val_string) -- DI/DIA (Дитина з інвалідністю/Дитина з інвалідністю підгрупи "А")
                          FROM uss_esr.ap_person         pp,
                               uss_esr.ap_document       ad,
                               uss_esr.ap_document_attr  da
                         WHERE     pp.app_sc = f.pdf_sc
                               --and pp.app_ap = d.pd_ap
                               AND pp.app_ap = ad.apd_ap
                               AND pp.app_id = ad.apd_app
                               AND ad.apd_id = da.apda_apd
                               AND da.apda_nda IN (797)           -- категорія
                               AND da.history_status = 'A')    inv_chld,
                       (SELECT MAX (da.apda_val_string)
                          FROM uss_esr.ap_person         pp,
                               uss_esr.ap_document       ad,
                               uss_esr.ap_document_attr  da
                         WHERE     pp.app_sc = f.pdf_sc
                               --and pp.app_ap = d.pd_ap
                               AND pp.app_ap = ad.apd_ap
                               AND pp.app_id = ad.apd_app
                               AND ad.apd_id = da.apda_apd
                               AND da.apda_nda IN (349, 666, 1790)
                               AND da.apda_val_string IN ('1', '2', '3')
                               AND da.history_status = 'A')    inv_gr,
                       (SELECT MAX (da.apda_val_string)
                          FROM uss_esr.ap_person         pp,
                               uss_esr.ap_document       ad,
                               uss_esr.ap_document_attr  da
                         WHERE     pp.app_sc = f.pdf_sc
                               AND pp.app_ap = d.pd_ap
                               AND pp.app_ap = ad.apd_ap
                               AND pp.app_id = ad.apd_app
                               AND ad.apd_id = da.apda_apd
                               AND da.apda_nda IN (791, 1792, 1792)
                               AND da.apda_val_string = 'A'
                               AND da.history_status = 'A')    inv_subgr,
                       (SELECT MAX (1)
                          FROM uss_esr.ap_person         pp,
                               uss_esr.ap_document       ad,
                               uss_esr.ap_document_attr  da
                         WHERE     pp.app_sc = f.pdf_sc
                               --and pp.app_ap = d.pd_ap
                               AND pp.app_ap = ad.apd_ap
                               AND pp.app_id = ad.apd_app
                               AND ad.apd_id = da.apda_apd
                               AND da.apda_val_string = 'T'
                               AND da.apda_nda IN (677) -- Знаходиться на держутриманні
                               AND da.history_status = 'A')    is_dutr,
                       (SELECT MAX (1)
                          FROM uss_esr.ap_person         pp,
                               uss_esr.ap_document       ad,
                               uss_esr.ap_document_attr  da
                         WHERE     pp.app_sc = f.pdf_sc
                               AND pp.app_ap = d.pd_ap
                               AND pp.app_ap = ad.apd_ap
                               AND pp.app_id = ad.apd_app
                               AND ad.apd_id = da.apda_apd
                               AND da.apda_val_string = 'T'
                               AND da.apda_nda IN (942) -- Дитина з інвалідністю внаслідок аварії на ЧАЕС
                               AND da.history_status = 'A')    is_AES,
                       (SELECT MAX (1)
                          FROM uss_esr.ap_person         pp,
                               uss_esr.ap_document       ad,
                               uss_esr.ap_document_attr  da
                         WHERE /*pp.app_sc = f.pdf_sc
                             and*/
                                   pp.app_ap = d.pd_ap
                               AND pp.app_ap = ad.apd_ap
                               AND pp.app_id = ad.apd_app
                               AND ad.apd_id = da.apda_apd
                               AND da.apda_val_string = 'T'
                               AND da.apda_nda IN (641)    -- Одинока/одинокий
                               AND da.history_status = 'A')    is_lon,
                       --row_number() over(partition by d.pd_id, nnc.nptc_npt, pp.pdp_id order by f.pdf_pd, nnc.nptc_npt)    rn,
                       1                                       rn,
                       NVL (pd.pdd_npt, pp.pdp_npt)            nptc_npt
                  FROM ikis_sys.v_opfu  o
                       INNER JOIN org ON i_org = org_id
                       INNER JOIN uss_esr.personalcase pc
                           ON pc.com_org = o.org_id
                       INNER JOIN uss_esr.pc_decision d ON d.pd_pc = pc.pc_id
                       INNER JOIN uss_esr.pd_family f
                           ON     f.pdf_pd = d.pd_id
                              AND NOT EXISTS
                                      (SELECT 1
                                         FROM uss_esr.ap_person p
                                        WHERE     p.app_ap = d.pd_ap
                                              AND p.app_sc = f.pdf_sc
                                              AND p.history_status = 'A'
                                              AND p.app_tp = 'P') -- Представник заявника
                       INNER JOIN uss_esr.pd_payment pp
                           ON pp.pdp_pd = d.pd_id
                       INNER JOIN uss_esr.pd_accrual_period pdap
                           ON pdap.pdap_pd = d.pd_id
                       --inner join uss_ndi.v_Ndi_Npt_Config nnc     on nnc.nptc_npt = pp.pdp_npt
                       --inner join uss_ndi.v_ndi_service_type st    on st.nst_id = nnc.nptc_nst
                       LEFT JOIN uss_esr.pd_detail pd
                           ON     pd.pdd_pdp = pp.pdp_id
                              AND pd.pdd_key = f.pdf_id
                 WHERE     o.org_to = 32
                       AND pp.history_status = 'A'
                       AND pdap.history_status = 'A'
                       AND pp.pdp_npt = 565           -- ДОПОМОГА НА ПОХОВАННЯ
                       --                   AND p_start_dt BETWEEN trunc(pdap.pdap_start_dt,'yy') AND pdap.pdap_stop_dt
                       --                   AND p_start_dt BETWEEN trunc(pp.pdp_start_dt,'yy') AND pp.pdp_stop_dt
                       AND pdap.pdap_start_dt BETWEEN TRUNC (p_start_dt,
                                                             'yy')
                                                  AND LAST_DAY (p_start_dt)
                       AND pp.pdp_start_dt BETWEEN TRUNC (p_start_dt, 'yy')
                                               AND LAST_DAY (p_start_dt);

        DELETE FROM uss_esr.tmp_nrh_rpt_data
              WHERE 1 = 1;

        INSERT INTO uss_esr.tmp_nrh_rpt_data (x_dt,
                                              x_narah,
                                              x_pay,
                                              x_pay_befor,
                                              x_payed,
                                              x_borh_befor,
                                              nptc_npt)
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
                      WHERE l_org_to = 34 AND org_acc_org = l_user_org)
                  SELECT ac.ac_month
                             dt_r,
                         --ac.ac_pc    x_pc,
                         --d.acd_pd    x_pd,
                         SUM (uss_esr.api$accrual.xsign (d.acd_op) * d.acd_sum)
                             x_narah,
                         SUM (
                             CASE
                                 WHEN d.acd_prsd IS NOT NULL
                                 THEN
                                       uss_esr.api$accrual.xsign (d.acd_op)
                                     * d.acd_sum
                                 ELSE
                                     0
                             END)
                             x_pay,
                         SUM (
                             CASE
                                 WHEN     d.acd_prsd IS NOT NULL
                                      AND TRUNC (d.acd_ac_start_dt, 'yy') <
                                          TRUNC (d.acd_start_dt, 'yy')
                                 THEN
                                       uss_esr.api$accrual.xsign (d.acd_op)
                                     * d.acd_sum
                                 ELSE
                                     0
                             END)
                             x_pay_befor,
                         SUM (
                             CASE
                                 WHEN EXISTS
                                          (SELECT 1
                                             FROM uss_esr.payroll pr
                                                  INNER JOIN uss_esr.pr_sheet s
                                                      ON s.prs_pr = pr.pr_id
                                                  INNER JOIN
                                                  uss_esr.pr_sheet_detail sd
                                                      ON sd.prsd_prs = s.prs_id
                                            WHERE     sd.prsd_id = d.acd_prsd
                                                  AND s.prs_st IN
                                                          ('NA', 'KV1', 'KV2')
                                                  AND pr.pr_st IN ('F')
                                                  AND sd.prsd_tp IN
                                                          ('PWI', 'RDN'))
                                 THEN
                                       uss_esr.api$accrual.xsign (d.acd_op)
                                     * d.acd_sum
                                 ELSE
                                     0
                             END)
                             x_payed,
                         SUM (
                             CASE
                                 WHEN     d.acd_prsd IS NULL   -- не виплачено
                                      AND TRUNC (d.acd_ac_start_dt, 'yy') <
                                          TRUNC (d.acd_start_dt, 'yy') -- рік за який нараховується менший року нарахування
                                      AND TRUNC (d.acd_start_dt, 'yy') =
                                          TRUNC (d.acd_start_dt, 'mm') -- на перший місяць звітного року
                                 THEN
                                       uss_esr.api$accrual.xsign (d.acd_op)
                                     * d.acd_sum
                                 ELSE
                                     0
                             END)
                             x_borh_befor,
                         nnc.nptc_npt
                    FROM ikis_sys.v_opfu o
                         INNER JOIN org ON i_org = o.org_id
                         INNER JOIN uss_esr.personalcase pc
                             ON pc.com_org = o.org_id
                         INNER JOIN uss_esr.accrual ac ON ac.ac_pc = pc.pc_id
                         INNER JOIN uss_esr.ac_detail d
                             ON d.acd_ac = ac.ac_id AND d.history_status = 'A'
                         INNER JOIN uss_ndi.v_ndi_op op ON op.op_id = d.acd_op
                         INNER JOIN uss_ndi.v_Ndi_Npt_Config nnc
                             ON nnc.nptc_npt = d.acd_npt
                         INNER JOIN uss_ndi.v_ndi_service_type st
                             ON st.nst_id = nnc.nptc_nst
                   WHERE     o.org_to = 32
                         AND ac.ac_month >= TRUNC (p_start_dt, 'YY')
                         AND ac.ac_month <= TRUNC (p_start_dt, 'MM')
                         AND d.acd_ac_start_dt BETWEEN ac.ac_month
                                                   AND TRUNC (
                                                           LAST_DAY (
                                                               ac.ac_month))
                         AND (d.acd_op IN (1, 2, 3) OR op.op_tp1 IN ('NR'))
                         AND ac.history_status = 'A'
                         AND st.nst_id = 248
                GROUP BY ac.ac_month, nnc.nptc_npt
                -- ДОПОМОГА НА ПОХОВАННЯ
                UNION ALL
                  SELECT ac.ac_month
                             dt_r,
                         --ac.ac_pc    x_pc,
                         --d.acd_pd    x_pd,
                         SUM (uss_esr.api$accrual.xsign (d.acd_op) * d.acd_sum)
                             x_narah,
                         SUM (
                             CASE
                                 WHEN d.acd_prsd IS NOT NULL
                                 THEN
                                       uss_esr.api$accrual.xsign (d.acd_op)
                                     * d.acd_sum
                                 ELSE
                                     0
                             END)
                             x_pay,
                         SUM (
                             CASE
                                 WHEN     d.acd_prsd IS NOT NULL
                                      AND TRUNC (d.acd_ac_start_dt, 'yy') <
                                          TRUNC (d.acd_start_dt, 'yy')
                                 THEN
                                       uss_esr.api$accrual.xsign (d.acd_op)
                                     * d.acd_sum
                                 ELSE
                                     0
                             END)
                             x_pay_befor,
                         SUM (
                             CASE
                                 WHEN EXISTS
                                          (SELECT 1
                                             FROM uss_esr.payroll pr
                                                  INNER JOIN uss_esr.pr_sheet s
                                                      ON s.prs_pr = pr.pr_id
                                                  INNER JOIN
                                                  uss_esr.pr_sheet_detail sd
                                                      ON sd.prsd_prs = s.prs_id
                                            WHERE     sd.prsd_id = d.acd_prsd
                                                  AND s.prs_st IN
                                                          ('NA', 'KV1', 'KV2')
                                                  AND pr.pr_st IN ('F')
                                                  AND sd.prsd_tp IN
                                                          ('PWI', 'RDN'))
                                 THEN
                                       uss_esr.api$accrual.xsign (d.acd_op)
                                     * d.acd_sum
                                 ELSE
                                     0
                             END)
                             x_payed,
                         SUM (
                             CASE
                                 WHEN     d.acd_prsd IS NULL   -- не виплачено
                                      AND TRUNC (d.acd_ac_start_dt, 'yy') <
                                          TRUNC (d.acd_start_dt, 'yy') -- рік за який нараховується менший року нарахування
                                      AND TRUNC (d.acd_start_dt, 'yy') =
                                          TRUNC (d.acd_start_dt, 'mm') -- на перший місяць звітного року
                                 THEN
                                       uss_esr.api$accrual.xsign (d.acd_op)
                                     * d.acd_sum
                                 ELSE
                                     0
                             END)
                             x_borh_befor,
                         d.acd_npt
                    FROM ikis_sys.v_opfu o
                         INNER JOIN org ON i_org = o.org_id
                         INNER JOIN uss_esr.personalcase pc
                             ON pc.com_org = o.org_id
                         INNER JOIN uss_esr.accrual ac ON ac.ac_pc = pc.pc_id
                         INNER JOIN uss_esr.ac_detail d
                             ON d.acd_ac = ac.ac_id AND d.history_status = 'A'
                         INNER JOIN uss_ndi.v_ndi_op op ON op.op_id = d.acd_op
                   --inner join uss_ndi.v_Ndi_Npt_Config nnc     on nnc.nptc_npt = d.acd_npt
                   --inner join uss_ndi.v_ndi_service_type st    on st.nst_id = nnc.nptc_nst
                   WHERE     o.org_to = 32
                         AND ac.ac_month >= TRUNC (p_start_dt, 'YY')
                         AND ac.ac_month <= TRUNC (p_start_dt, 'MM')
                         AND d.acd_ac_start_dt BETWEEN ac.ac_month
                                                   AND TRUNC (
                                                           LAST_DAY (
                                                               ac.ac_month))
                         AND (d.acd_op IN (1, 2, 3) OR op.op_tp1 IN ('NR'))
                         AND ac.history_status = 'A'
                         AND d.acd_npt = 565
                GROUP BY ac.ac_month, d.acd_npt
                UNION ALL
                  -- Нарахування по Надбавка на догляд за особою з інвалідністю з дитинства та дитини з інвалідністю з пропорцій по деталізації призначень
                  SELECT dt_r,
                         ROUND (SUM (x_narah * pdd_value), 2)
                             x_narah,
                         ROUND (SUM (x_pay * pdd_value), 2)
                             x_pay,
                         ROUND (SUM (x_pay_befor * pdd_value), 2)
                             x_pay_befor,
                         ROUND (SUM (x_payed * pdd_value), 2)
                             x_payed,
                         ROUND (SUM (x_borh_befor * pdd_value), 2)
                             x_borh_befor,
                         -1
                             npt_id
                    FROM (  SELECT ac.ac_month                             dt_r,
                                   --ac.ac_pc    x_pc,
                                   d.acd_pd                                x_pd,
                                   SUM (
                                         uss_esr.api$accrual.xsign (d.acd_op)
                                       * d.acd_sum)                        x_narah,
                                   SUM (
                                       CASE
                                           WHEN d.acd_prsd IS NOT NULL
                                           THEN
                                                 uss_esr.api$accrual.xsign (
                                                     d.acd_op)
                                               * d.acd_sum
                                           ELSE
                                               0
                                       END)                                x_pay,
                                   SUM (
                                       CASE
                                           WHEN     d.acd_prsd IS NOT NULL
                                                AND TRUNC (d.acd_ac_start_dt,
                                                           'yy') <
                                                    TRUNC (d.acd_start_dt, 'yy')
                                           THEN
                                                 uss_esr.api$accrual.xsign (
                                                     d.acd_op)
                                               * d.acd_sum
                                           ELSE
                                               0
                                       END)                                x_pay_befor,
                                   SUM (
                                       CASE
                                           WHEN EXISTS
                                                    (SELECT 1
                                                       FROM uss_esr.payroll pr
                                                            INNER JOIN
                                                            uss_esr.pr_sheet s
                                                                ON s.prs_pr =
                                                                   pr.pr_id
                                                            INNER JOIN
                                                            uss_esr.pr_sheet_detail
                                                            sd
                                                                ON sd.prsd_prs =
                                                                   s.prs_id
                                                      WHERE     sd.prsd_id =
                                                                d.acd_prsd
                                                            AND s.prs_st IN
                                                                    ('NA',
                                                                     'KV1',
                                                                     'KV2')
                                                            AND pr.pr_st IN ('F')
                                                            AND sd.prsd_tp IN
                                                                    ('PWI', 'RDN'))
                                           THEN
                                                 uss_esr.api$accrual.xsign (
                                                     d.acd_op)
                                               * d.acd_sum
                                           ELSE
                                               0
                                       END)                                x_payed,
                                   SUM (
                                       CASE
                                           WHEN     d.acd_prsd IS NULL -- не виплачено
                                                AND TRUNC (d.acd_ac_start_dt,
                                                           'yy') <
                                                    TRUNC (d.acd_start_dt, 'yy') -- рік за який нараховується менший року нарахування
                                                AND TRUNC (d.acd_start_dt, 'yy') =
                                                    TRUNC (d.acd_start_dt, 'mm') -- на перший місяць звітного року
                                           THEN
                                                 uss_esr.api$accrual.xsign (
                                                     d.acd_op)
                                               * d.acd_sum
                                           ELSE
                                               0
                                       END)                                x_borh_befor,
                                   (SELECT   SUM (
                                                 CASE
                                                     WHEN pd.pdd_npt = 48
                                                     THEN
                                                         pd.pdd_value
                                                     ELSE
                                                         0
                                                 END)
                                           / SUM (pd.pdd_value)    pdd_value
                                      FROM uss_esr.pd_payment pp,
                                           uss_esr.pd_detail pd
                                     WHERE     pp.pdp_pd = d.acd_pd
                                           AND pp.pdp_npt = 1
                                           AND pd.pdd_pdp = pp.pdp_id
                                           AND pd.pdd_value > 0
                                           AND ac.ac_month BETWEEN TRUNC (
                                                                       pp.pdp_start_dt,
                                                                       'mm')
                                                               AND pp.pdp_stop_dt
                                           AND pp.history_status = 'A')    pdd_value
                              FROM ikis_sys.v_opfu o
                                   INNER JOIN org ON i_org = o.org_id
                                   INNER JOIN uss_esr.personalcase pc
                                       ON pc.com_org = o.org_id
                                   INNER JOIN uss_esr.accrual ac
                                       ON ac.ac_pc = pc.pc_id
                                   INNER JOIN uss_esr.ac_detail d
                                       ON     d.acd_ac = ac.ac_id
                                          AND d.history_status = 'A'
                                   INNER JOIN uss_ndi.v_ndi_op op
                                       ON op.op_id = d.acd_op
                             WHERE     o.org_to = 32
                                   AND ac.ac_month >= TRUNC (p_start_dt, 'YY')
                                   AND ac.ac_month <= TRUNC (p_start_dt, 'MM')
                                   AND d.acd_ac_start_dt BETWEEN ac.ac_month
                                                             AND TRUNC (
                                                                     LAST_DAY (
                                                                         ac.ac_month))
                                   AND (   d.acd_op IN (1, 2, 3)
                                        OR op.op_tp1 IN ('NR'))
                                   AND ac.history_status = 'A'
                                   AND d.acd_npt = 1 -- Державна соціальна допомога особам з інвалідністю з дитинства та дітям з інвалідністю
                                   AND EXISTS
                                           (SELECT 1
                                              FROM uss_esr.pd_payment pp,
                                                   uss_esr.pd_detail pd
                                             WHERE     pp.pdp_pd = d.acd_pd
                                                   AND pp.pdp_npt = 1 -- 48 надбавка групується в загальну суму допомоги
                                                   AND pd.pdd_pdp = pp.pdp_id
                                                   AND ac.ac_month BETWEEN TRUNC (
                                                                               pp.pdp_start_dt,
                                                                               'mm')
                                                                       AND pp.pdp_stop_dt
                                                   AND pp.history_status = 'A'
                                                   AND pd.pdd_npt = 48 -- Надбавка на догляд за особою з інвалідністю з дитинства та дитини з інвалідністю
                                                                      )
                          GROUP BY ac.ac_month, d.acd_pd) a
                GROUP BY dt_r;

        DELETE FROM tmp_univ_rpt_data
              WHERE 1 = 1;

        INSERT INTO tmp_univ_rpt_data (x_string1,         -- CB Категорія осіб
                                       x_id1,                    -- CA № рядка
                                       -- Кількість отримувачів державної соціальної допомоги, осіб
                                       x_id2,                -- CNT_ALL усього
                                       x_id3, -- CNT_DUTR з них: на повному державному утриманні
                                       x_id4, -- CNT_Y кількість отримувачів, яким призначено допомогу з початку поточного року (наростаючим підсумком)
                                       x_id5, -- CNT_M кількість отримувачів, яким призначено допомогу у звітному місяці
                                       -- Сума нарахованої допомоги, тис. грн
                                       x_sum1, -- x_narah   з початку поточного року (наростаючим підсумком)
                                       x_sum2,  -- x_narah_m у звітному місяці
                                       -- Сума фактично профінансованих коштів, тис. грн
                                       x_sum3, -- x_pay (з початку поточного року (наростаючим підсумком))
                                       x_sum4,  -- x_pay_m (у звітному місяці)
                                       x_sum5, -- x_pay_befor (з них: погашено заборгованості за попередні роки)
                                       -- Сума виплаченої допомоги, тис. грн
                                       x_sum6, -- x_payed (з початку поточного року (наростаючим підсумком))
                                       x_sum7, -- x_payed_m (у звітному місяці)
                                       -- Сума заборгованості, тис. грн
                                       x_sum8, -- x_borh_befor (за попередні роки)
                                       -- для розподілу по пропорціям
                                       x_sum9,                     -- a_assing
                                       x_sum10)                  -- a_assing_m
            WITH
                rpt
                AS
                    (SELECT 1                                                                             ca,
                            '1. Усього отримують державну соціальну допомогу  (рядки 2+7),&#10;з них:'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 2                                                                            ca,
                            '1.1. Особа з інвалідністю з дитинства  (рядки 3+5+6),&#10;у тому числі:'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 3 ca, ' І групи' cb FROM DUAL
                     UNION ALL
                     SELECT 4 ca, '<B>з них:</B><Font> підгрупи А</Font>' cb
                       FROM DUAL
                     UNION ALL
                     SELECT 5 ca, 'ІІ групи' cb FROM DUAL
                     UNION ALL
                     SELECT 6 ca, 'ІІІ групи' cb FROM DUAL
                     UNION ALL
                     SELECT 7                                                                  ca,
                            '1.2. Діти з інвалідністю віком до 18 років,&#10;у тому числі:'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 8                                                      ca,
                            ' діти з інвалідністю віком до 18 років підгрупи А'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 9                                                                          ca,
                            'діти з інвалідністю, захворювання яких пов’язане з Чорнобильською АЕС'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 10                                                                                                                                              ca,
                            '<B><I>з них:</I></B><I> діти з інвалідністю, захворювання яких пов’язане з Чорнобильською АЕС, підгрупи <Font html:Size="6.5">А</Font></I>'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 11                                                                                                                      ca,
                            '2. Із загальної кількості отримувачів допомоги – отримують надбавку на догляд  (усього)  (рядки 12+16),&#10;з них:'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 12                                                                                               ca,
                            '2.1. На догляд за особою з інвалідністю з дитинства&#10;(рядки 13+14+15),&#10;у тому числі:'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 13 ca, 'І групи' cb FROM DUAL
                     UNION ALL
                     SELECT 14 ca, 'ІІ групи' cb FROM DUAL
                     UNION ALL
                     SELECT 15 ca, 'ІІІ групи' cb FROM DUAL
                     UNION ALL
                     SELECT 16                                                                            ca,
                            '2.2. На догляд за дитиною з інвалідністю віком до 18 років (рядки 17+18)'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 17                                                   ca,
                            '<B>з них</B><Font>:&#10;віком до 6 років</Font>'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 18 ca, 'віком від 6 до 18 років' cb FROM DUAL
                     UNION ALL
                     SELECT 19                                                                                                                                                           ca,
                            '<I>з рядка 16 </I><Font>–</Font><I><Font html:Size="8.75"> </Font><Font>за дитиною з інвалідністю віком до 18 років підгрупи А (рядки 20+21)</Font></I>'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 20                                                    ca,
                            '<B> з них:</B><Font>&#10;віком до 6 років</Font>'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 21 ca, 'віком від 6 до 18 років ' cb FROM DUAL
                     UNION ALL
                     SELECT 22                                                                                                                                                                                                                      ca,
                            '<I>з рядка 16 </I><Font>–</Font><I><Font html:Size="8.75"> </Font><Font>за дитиною з інвалідністю віком до 18 років, захворювання якої пов</Font></I><Font>’</Font><I>язане з Чорнобильською АЕС (рядки 23+24)</I>'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 23                                                    ca,
                            '<B>з них:&#10;</B><Font> віком до 6 років</Font>'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 24 ca, 'віком від 6 до 18 років' cb FROM DUAL
                     UNION ALL
                     SELECT 25                                                                                                                                                                                      ca,
                            '<I>з рядка 22 </I><Font>–</Font><I> за дитиною з інвалідністю віком до 18 років підгрупи А, захворювання якої пов</I><Font>’</Font><I>язане з Чорнобильською АЕС (рядки 26+27)</I>'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 26                                                   ca,
                            '<B>з них:</B><Font>&#10;віком до 6 років</Font>'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 27 ca, 'віком від 6 до 18 років ' cb FROM DUAL
                     UNION ALL
                     SELECT 28                                                                                                                       ca,
                            '<I>з рядка 16 </I><Font>–</Font><I> за дитиною з інвалідністю до 18 років одинокій матері, батьку (рядки 29+30)</I>'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 29                                                                                                                                                             ca,
                            '<B>з них:                                                                                                               </B><Font>віком до 6 років</Font>'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 30 ca, 'віком від 6 до 18 років' cb FROM DUAL
                     UNION ALL
                     SELECT 31                                                                 ca,
                            '3. Допомога на поховання  (рядки 32+36)                      '    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 32                                                                                                                                                       ca,
                            'у тому числі:                                                                                3.1. Особа з інвалідністю з дитинства (рядки 33+34+35)'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 33                                                                                                                                         ca,
                            '<B>з них:  </B><Font>                                                                                                  І групи</Font>'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 34 ca, 'ІІ групи' cb FROM DUAL
                     UNION ALL
                     SELECT 35 ca, 'ІІІ групи' cb FROM DUAL
                     UNION ALL
                     SELECT 36                                              ca,
                            '3.2. Діти з інвалідністю віком до 18 років'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 37                                                                                                               ca,
                            '4.Отримують державну соціальну допомогу та пенсію у зв’язку з втратою годувальника одночасно  (рядки 38+42)'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 38                                                                              ca,
                            'у тому числі:&#10;4.1  Особа з інвалідністю з дитинства   (рядки 39+40+41)'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 39                                           ca,
                            '<B>з них</B><Font>:&#10;І групи</Font>'     cb
                       FROM DUAL
                     UNION ALL
                     SELECT 40 ca, 'ІІ групи' cb FROM DUAL
                     UNION ALL
                     SELECT 41 ca, 'ІІІ групи' cb FROM DUAL
                     UNION ALL
                     SELECT 42                                             ca,
                            '4.2 Діти з інвалідністю віком до 18 років'    cb
                       FROM DUAL
                     UNION ALL
                     SELECT 43 ca, '5. Інші виплати' cb FROM DUAL)
              -- qq
              SELECT rpt.cb,
                     rpt.ca,
                     a.cnt_all,
                     a.cnt_dutr,
                     a.cnt_y,
                     a.cnt_m,
                     --a.a_assing,
                     --a.a_assing_m,
                     n.x_narah,
                     n.x_narah_m,
                     n.x_pay,
                     n.x_pay_m,
                     n.x_pay_befor,
                     n.x_payed,
                     n.x_payed_m,
                     n.x_borh_befor,
                     a.a_assing,
                     a.a_assing_m
                FROM rpt
                     LEFT JOIN
                     (SELECT 3
                                 npp,
                             COUNT (DISTINCT a.a_pc)
                                 cnt_all,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_dutr = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_dutr,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new_y = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_y,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_m,
                             SUM (
                                 CASE WHEN a.rn = 1 THEN a.a_assing ELSE 0 END)
                                 a_assing,
                             SUM (
                                 CASE
                                     WHEN a.rn = 1 AND a.is_new = 1
                                     THEN
                                         a.a_assing
                                     ELSE
                                         0
                                 END)
                                 a_assing_m
                        FROM uss_esr.tmp_assign_rpt_data a
                       WHERE     inv_pers = 1
                             AND inv_gr = '1'
                             AND a.nptc_npt != 565
                      UNION ALL
                      SELECT 4
                                 npp,
                             COUNT (DISTINCT a.a_pc)
                                 cnt_all,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_dutr = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_dutr,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new_y = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_y,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_m,
                             SUM (
                                 CASE WHEN a.rn = 1 THEN a.a_assing ELSE 0 END)
                                 a_assing,
                             SUM (
                                 CASE
                                     WHEN a.rn = 1 AND a.is_new = 1
                                     THEN
                                         a.a_assing
                                     ELSE
                                         0
                                 END)
                                 a_assing_m
                        FROM uss_esr.tmp_assign_rpt_data a
                       WHERE     inv_pers = 1
                             AND inv_gr = '1'
                             AND inv_subgr = 'A'
                             AND a.nptc_npt != 565
                      UNION ALL
                      SELECT 5
                                 npp,
                             COUNT (DISTINCT a.a_pc)
                                 cnt_all,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_dutr = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_dutr,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new_y = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_y,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_m,
                             SUM (
                                 CASE WHEN a.rn = 1 THEN a.a_assing ELSE 0 END)
                                 a_assing,
                             SUM (
                                 CASE
                                     WHEN a.rn = 1 AND a.is_new = 1
                                     THEN
                                         a.a_assing
                                     ELSE
                                         0
                                 END)
                                 a_assing_m
                        FROM uss_esr.tmp_assign_rpt_data a
                       WHERE     inv_pers = 1
                             AND inv_gr = '2'
                             AND a.nptc_npt != 565
                      UNION ALL
                      SELECT 6
                                 npp,
                             COUNT (DISTINCT a.a_pc)
                                 cnt_all,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_dutr = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_dutr,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new_y = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_y,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_m,
                             SUM (
                                 CASE WHEN a.rn = 1 THEN a.a_assing ELSE 0 END)
                                 a_assing,
                             SUM (
                                 CASE
                                     WHEN a.rn = 1 AND a.is_new = 1
                                     THEN
                                         a.a_assing
                                     ELSE
                                         0
                                 END)
                                 a_assing_m
                        FROM uss_esr.tmp_assign_rpt_data a
                       WHERE     inv_pers = 1
                             AND inv_gr = '3'
                             AND a.nptc_npt != 565
                      UNION ALL
                      SELECT 7
                                 npp,
                             COUNT (DISTINCT a.a_pc)
                                 cnt_all,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_dutr = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_dutr,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new_y = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_y,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_m,
                             SUM (
                                 CASE WHEN a.rn = 1 THEN a.a_assing ELSE 0 END)
                                 a_assing,
                             SUM (
                                 CASE
                                     WHEN a.rn = 1 AND a.is_new = 1
                                     THEN
                                         a.a_assing
                                     ELSE
                                         0
                                 END)
                                 a_assing_m
                        FROM uss_esr.tmp_assign_rpt_data a
                       WHERE inv_chld IN ('DI', 'DIA') AND a.nptc_npt != 565
                      UNION ALL
                      SELECT 8
                                 npp,
                             COUNT (DISTINCT a.a_pc)
                                 cnt_all,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_dutr = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_dutr,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new_y = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_y,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_m,
                             SUM (
                                 CASE WHEN a.rn = 1 THEN a.a_assing ELSE 0 END)
                                 a_assing,
                             SUM (
                                 CASE
                                     WHEN a.rn = 1 AND a.is_new = 1
                                     THEN
                                         a.a_assing
                                     ELSE
                                         0
                                 END)
                                 a_assing_m
                        FROM uss_esr.tmp_assign_rpt_data a
                       WHERE inv_chld IN ('DIA') AND a.nptc_npt != 565
                      UNION ALL
                      SELECT 9
                                 npp,
                             COUNT (DISTINCT a.a_pc)
                                 cnt_all,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_dutr = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_dutr,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new_y = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_y,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_m,
                             SUM (
                                 CASE WHEN a.rn = 1 THEN a.a_assing ELSE 0 END)
                                 a_assing,
                             SUM (
                                 CASE
                                     WHEN a.rn = 1 AND a.is_new = 1
                                     THEN
                                         a.a_assing
                                     ELSE
                                         0
                                 END)
                                 a_assing_m
                        FROM uss_esr.tmp_assign_rpt_data a
                       WHERE     inv_chld IN ('DI', 'DIA')
                             AND is_AES = 1
                             AND a.nptc_npt != 565
                      UNION ALL
                      SELECT 10
                                 npp,
                             COUNT (DISTINCT a.a_pc)
                                 cnt_all,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_dutr = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_dutr,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new_y = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_y,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_m,
                             SUM (
                                 CASE WHEN a.rn = 1 THEN a.a_assing ELSE 0 END)
                                 a_assing,
                             SUM (
                                 CASE
                                     WHEN a.rn = 1 AND a.is_new = 1
                                     THEN
                                         a.a_assing
                                     ELSE
                                         0
                                 END)
                                 a_assing_m
                        FROM uss_esr.tmp_assign_rpt_data a
                       WHERE     inv_chld IN ('DIA')
                             AND is_AES = 1
                             AND a.nptc_npt != 565
                      -- nptc_npt = 48   -- Надбавка на догляд за особою з інвалідністю з дитинства та дитини з інвалідністю (290)
                      UNION ALL
                      SELECT 11
                                 npp,
                             COUNT (DISTINCT a.a_pc)
                                 cnt_all,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_dutr = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_dutr,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new_y = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_y,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_m,
                             SUM (
                                 CASE WHEN a.rn = 1 THEN a.a_assing ELSE 0 END)
                                 a_assing,
                             SUM (
                                 CASE
                                     WHEN a.rn = 1 AND a.is_new = 1
                                     THEN
                                         a.a_assing
                                     ELSE
                                         0
                                 END)
                                 a_assing_m
                        FROM uss_esr.tmp_assign_rpt_data a
                       WHERE a.nptc_npt = 48
                      UNION ALL
                      SELECT 13
                                 npp,
                             COUNT (DISTINCT a.a_pc)
                                 cnt_all,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_dutr = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_dutr,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new_y = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_y,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_m,
                             SUM (
                                 CASE WHEN a.rn = 1 THEN a.a_assing ELSE 0 END)
                                 a_assing,
                             SUM (
                                 CASE
                                     WHEN a.rn = 1 AND a.is_new = 1
                                     THEN
                                         a.a_assing
                                     ELSE
                                         0
                                 END)
                                 a_assing_m
                        FROM uss_esr.tmp_assign_rpt_data a
                       WHERE a.nptc_npt = 48 AND inv_pers = 1 AND inv_gr = '1'
                      UNION ALL
                      SELECT 14
                                 npp,
                             COUNT (DISTINCT a.a_pc)
                                 cnt_all,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_dutr = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_dutr,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new_y = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_y,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_m,
                             SUM (
                                 CASE WHEN a.rn = 1 THEN a.a_assing ELSE 0 END)
                                 a_assing,
                             SUM (
                                 CASE
                                     WHEN a.rn = 1 AND a.is_new = 1
                                     THEN
                                         a.a_assing
                                     ELSE
                                         0
                                 END)
                                 a_assing_m
                        FROM uss_esr.tmp_assign_rpt_data a
                       WHERE a.nptc_npt = 48 AND inv_pers = 1 AND inv_gr = '2'
                      UNION ALL
                      SELECT 15
                                 npp,
                             COUNT (DISTINCT a.a_pc)
                                 cnt_all,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_dutr = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_dutr,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new_y = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_y,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_m,
                             SUM (
                                 CASE WHEN a.rn = 1 THEN a.a_assing ELSE 0 END)
                                 a_assing,
                             SUM (
                                 CASE
                                     WHEN a.rn = 1 AND a.is_new = 1
                                     THEN
                                         a.a_assing
                                     ELSE
                                         0
                                 END)
                                 a_assing_m
                        FROM uss_esr.tmp_assign_rpt_data a
                       WHERE a.nptc_npt = 48 AND inv_pers = 1 AND inv_gr = '3'
                      UNION ALL
                      SELECT 17
                                 npp,
                             COUNT (DISTINCT a.a_pc)
                                 cnt_all,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_dutr = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_dutr,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new_y = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_y,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_m,
                             SUM (
                                 CASE WHEN a.rn = 1 THEN a.a_assing ELSE 0 END)
                                 a_assing,
                             SUM (
                                 CASE
                                     WHEN a.rn = 1 AND a.is_new = 1
                                     THEN
                                         a.a_assing
                                     ELSE
                                         0
                                 END)
                                 a_assing_m
                        FROM uss_esr.tmp_assign_rpt_data a
                       WHERE     inv_chld IN ('DI', 'DIA')
                             AND year_old = 6
                             AND a.nptc_npt = 48
                      UNION ALL
                      SELECT 18
                                 npp,
                             COUNT (DISTINCT a.a_pc)
                                 cnt_all,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_dutr = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_dutr,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new_y = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_y,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_m,
                             SUM (
                                 CASE WHEN a.rn = 1 THEN a.a_assing ELSE 0 END)
                                 a_assing,
                             SUM (
                                 CASE
                                     WHEN a.rn = 1 AND a.is_new = 1
                                     THEN
                                         a.a_assing
                                     ELSE
                                         0
                                 END)
                                 a_assing_m
                        FROM uss_esr.tmp_assign_rpt_data a
                       WHERE     inv_chld IN ('DI', 'DIA')
                             AND year_old = 18
                             AND a.nptc_npt = 48
                      UNION ALL
                      SELECT 20
                                 npp,
                             COUNT (DISTINCT a.a_pc)
                                 cnt_all,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_dutr = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_dutr,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new_y = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_y,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_m,
                             SUM (
                                 CASE WHEN a.rn = 1 THEN a.a_assing ELSE 0 END)
                                 a_assing,
                             SUM (
                                 CASE
                                     WHEN a.rn = 1 AND a.is_new = 1
                                     THEN
                                         a.a_assing
                                     ELSE
                                         0
                                 END)
                                 a_assing_m
                        FROM uss_esr.tmp_assign_rpt_data a
                       WHERE     inv_chld IN ('DIA')
                             AND year_old = 6
                             AND a.nptc_npt = 48
                      UNION ALL
                      SELECT 21
                                 npp,
                             COUNT (DISTINCT a.a_pc)
                                 cnt_all,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_dutr = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_dutr,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new_y = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_y,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_m,
                             SUM (
                                 CASE WHEN a.rn = 1 THEN a.a_assing ELSE 0 END)
                                 a_assing,
                             SUM (
                                 CASE
                                     WHEN a.rn = 1 AND a.is_new = 1
                                     THEN
                                         a.a_assing
                                     ELSE
                                         0
                                 END)
                                 a_assing_m
                        FROM uss_esr.tmp_assign_rpt_data a
                       WHERE     inv_chld IN ('DIA')
                             AND year_old = 18
                             AND a.nptc_npt = 48
                      UNION ALL
                      SELECT 23
                                 npp,
                             COUNT (DISTINCT a.a_pc)
                                 cnt_all,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_dutr = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_dutr,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new_y = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_y,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_m,
                             SUM (
                                 CASE WHEN a.rn = 1 THEN a.a_assing ELSE 0 END)
                                 a_assing,
                             SUM (
                                 CASE
                                     WHEN a.rn = 1 AND a.is_new = 1
                                     THEN
                                         a.a_assing
                                     ELSE
                                         0
                                 END)
                                 a_assing_m
                        FROM uss_esr.tmp_assign_rpt_data a
                       WHERE     inv_chld IN ('DI', 'DIA')
                             AND year_old = 6
                             AND is_AES = 1
                             AND a.nptc_npt = 48
                      UNION ALL
                      SELECT 24
                                 npp,
                             COUNT (DISTINCT a.a_pc)
                                 cnt_all,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_dutr = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_dutr,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new_y = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_y,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_m,
                             SUM (
                                 CASE WHEN a.rn = 1 THEN a.a_assing ELSE 0 END)
                                 a_assing,
                             SUM (
                                 CASE
                                     WHEN a.rn = 1 AND a.is_new = 1
                                     THEN
                                         a.a_assing
                                     ELSE
                                         0
                                 END)
                                 a_assing_m
                        FROM uss_esr.tmp_assign_rpt_data a
                       WHERE     inv_chld IN ('DI', 'DIA')
                             AND year_old = 18
                             AND is_AES = 1
                             AND a.nptc_npt = 48
                      UNION ALL
                      SELECT 26
                                 npp,
                             COUNT (DISTINCT a.a_pc)
                                 cnt_all,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_dutr = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_dutr,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new_y = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_y,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_m,
                             SUM (
                                 CASE WHEN a.rn = 1 THEN a.a_assing ELSE 0 END)
                                 a_assing,
                             SUM (
                                 CASE
                                     WHEN a.rn = 1 AND a.is_new = 1
                                     THEN
                                         a.a_assing
                                     ELSE
                                         0
                                 END)
                                 a_assing_m
                        FROM uss_esr.tmp_assign_rpt_data a
                       WHERE     inv_chld IN ('DIA')
                             AND year_old = 6
                             AND is_AES = 1
                             AND a.nptc_npt = 48
                      UNION ALL
                      SELECT 27
                                 npp,
                             COUNT (DISTINCT a.a_pc)
                                 cnt_all,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_dutr = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_dutr,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new_y = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_y,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_m,
                             SUM (
                                 CASE WHEN a.rn = 1 THEN a.a_assing ELSE 0 END)
                                 a_assing,
                             SUM (
                                 CASE
                                     WHEN a.rn = 1 AND a.is_new = 1
                                     THEN
                                         a.a_assing
                                     ELSE
                                         0
                                 END)
                                 a_assing_m
                        FROM uss_esr.tmp_assign_rpt_data a
                       WHERE     inv_chld IN ('DIA')
                             AND year_old = 18
                             AND is_AES = 1
                             AND a.nptc_npt = 48
                      UNION ALL
                      SELECT 29
                                 npp,
                             COUNT (DISTINCT a.a_pc)
                                 cnt_all,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_dutr = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_dutr,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new_y = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_y,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_m,
                             SUM (
                                 CASE WHEN a.rn = 1 THEN a.a_assing ELSE 0 END)
                                 a_assing,
                             SUM (
                                 CASE
                                     WHEN a.rn = 1 AND a.is_new = 1
                                     THEN
                                         a.a_assing
                                     ELSE
                                         0
                                 END)
                                 a_assing_m
                        FROM uss_esr.tmp_assign_rpt_data a
                       WHERE     inv_chld IN ('DI', 'DIA')
                             AND year_old = 6
                             AND is_lon = 1                -- Одинока/одинокий
                             AND a.nptc_npt = 48
                      UNION ALL
                      SELECT 30
                                 npp,
                             COUNT (DISTINCT a.a_pc)
                                 cnt_all,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_dutr = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_dutr,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new_y = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_y,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_m,
                             SUM (
                                 CASE WHEN a.rn = 1 THEN a.a_assing ELSE 0 END)
                                 a_assing,
                             SUM (
                                 CASE
                                     WHEN a.rn = 1 AND a.is_new = 1
                                     THEN
                                         a.a_assing
                                     ELSE
                                         0
                                 END)
                                 a_assing_m
                        FROM uss_esr.tmp_assign_rpt_data a
                       WHERE     inv_chld IN ('DI', 'DIA')
                             AND year_old = 18
                             AND is_lon = 1
                             AND a.nptc_npt = 48
                      -- nptc_npt = 565   -- ДОПОМОГА НА ПОХОВАННЯ
                      UNION ALL
                      SELECT 31
                                 npp,
                             COUNT (DISTINCT a.a_pc)
                                 cnt_all,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_dutr = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_dutr,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new_y = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_y,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_m,
                             SUM (
                                 CASE WHEN a.rn = 1 THEN a.a_assing ELSE 0 END)
                                 a_assing,
                             SUM (
                                 CASE
                                     WHEN a.rn = 1 AND a.is_new = 1
                                     THEN
                                         a.a_assing
                                     ELSE
                                         0
                                 END)
                                 a_assing_m
                        FROM uss_esr.tmp_assign_rpt_data a
                       WHERE a.nptc_npt = 565
                      UNION ALL
                      SELECT 33
                                 npp,
                             COUNT (DISTINCT a.a_pc)
                                 cnt_all,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_dutr = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_dutr,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new_y = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_y,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_m,
                             SUM (
                                 CASE WHEN a.rn = 1 THEN a.a_assing ELSE 0 END)
                                 a_assing,
                             SUM (
                                 CASE
                                     WHEN a.rn = 1 AND a.is_new = 1
                                     THEN
                                         a.a_assing
                                     ELSE
                                         0
                                 END)
                                 a_assing_m
                        FROM uss_esr.tmp_assign_rpt_data a
                       WHERE a.nptc_npt = 565 AND inv_pers = 1 AND inv_gr = '1'
                      UNION ALL
                      SELECT 34
                                 npp,
                             COUNT (DISTINCT a.a_pc)
                                 cnt_all,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_dutr = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_dutr,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new_y = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_y,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_m,
                             SUM (
                                 CASE WHEN a.rn = 1 THEN a.a_assing ELSE 0 END)
                                 a_assing,
                             SUM (
                                 CASE
                                     WHEN a.rn = 1 AND a.is_new = 1
                                     THEN
                                         a.a_assing
                                     ELSE
                                         0
                                 END)
                                 a_assing_m
                        FROM uss_esr.tmp_assign_rpt_data a
                       WHERE a.nptc_npt = 565 AND inv_pers = 1 AND inv_gr = '2'
                      UNION ALL
                      SELECT 35
                                 npp,
                             COUNT (DISTINCT a.a_pc)
                                 cnt_all,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_dutr = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_dutr,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new_y = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_y,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_m,
                             SUM (
                                 CASE WHEN a.rn = 1 THEN a.a_assing ELSE 0 END)
                                 a_assing,
                             SUM (
                                 CASE
                                     WHEN a.rn = 1 AND a.is_new = 1
                                     THEN
                                         a.a_assing
                                     ELSE
                                         0
                                 END)
                                 a_assing_m
                        FROM uss_esr.tmp_assign_rpt_data a
                       WHERE a.nptc_npt = 565 AND inv_pers = 1 AND inv_gr = '3'
                      UNION ALL
                      SELECT 36
                                 npp,
                             COUNT (DISTINCT a.a_pc)
                                 cnt_all,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_dutr = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_dutr,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new_y = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_y,
                             COUNT (
                                 DISTINCT
                                     CASE
                                         WHEN a.is_new = 1 THEN a.a_pc
                                         ELSE NULL
                                     END)
                                 cnt_m,
                             SUM (
                                 CASE WHEN a.rn = 1 THEN a.a_assing ELSE 0 END)
                                 a_assing,
                             SUM (
                                 CASE
                                     WHEN a.rn = 1 AND a.is_new = 1
                                     THEN
                                         a.a_assing
                                     ELSE
                                         0
                                 END)
                                 a_assing_m
                        FROM uss_esr.tmp_assign_rpt_data a
                       WHERE     inv_chld IN ('DI', 'DIA')
                             AND year_old <= 18
                             AND a.nptc_npt = 565) a
                         ON a.npp = rpt.ca
                     LEFT JOIN
                     (SELECT 1                     npp,
                             SUM (x_narah)         x_narah,
                             SUM (
                                 CASE
                                     WHEN x_dt = TRUNC (p_start_dt, 'mm')
                                     THEN
                                         x_narah
                                     ELSE
                                         0
                                 END)              x_narah_m,
                             SUM (x_pay)           x_pay,
                             SUM (
                                 CASE
                                     WHEN x_dt = TRUNC (p_start_dt, 'mm')
                                     THEN
                                         x_pay
                                     ELSE
                                         0
                                 END)              x_pay_m,
                             SUM (x_pay_befor)     x_pay_befor,
                             SUM (x_payed)         x_payed,
                             SUM (
                                 CASE
                                     WHEN x_dt = TRUNC (p_start_dt, 'mm')
                                     THEN
                                         x_payed
                                     ELSE
                                         0
                                 END)              x_payed_m,
                             SUM (x_borh_befor)    x_borh_befor
                        FROM uss_esr.tmp_nrh_rpt_data
                       WHERE nptc_npt > 0 AND nptc_npt != 565
                      UNION ALL
                      SELECT 11                    npp,
                             SUM (x_narah)         x_narah,
                             SUM (
                                 CASE
                                     WHEN x_dt = TRUNC (p_start_dt, 'mm')
                                     THEN
                                         x_narah
                                     ELSE
                                         0
                                 END)              x_narah_m,
                             SUM (x_pay)           x_pay,
                             SUM (
                                 CASE
                                     WHEN x_dt = TRUNC (p_start_dt, 'mm')
                                     THEN
                                         x_pay
                                     ELSE
                                         0
                                 END)              x_pay_m,
                             SUM (x_pay_befor)     x_pay_befor,
                             SUM (x_payed)         x_payed,
                             SUM (
                                 CASE
                                     WHEN x_dt = TRUNC (p_start_dt, 'mm')
                                     THEN
                                         x_payed
                                     ELSE
                                         0
                                 END)              x_payed_m,
                             SUM (x_borh_befor)    x_borh_befor
                        FROM uss_esr.tmp_nrh_rpt_data
                       WHERE nptc_npt IN (-1, 48) -- Надбавка на догляд за особою з інвалідністю з дитинства та дитини з інвалідністю (290)
                      UNION ALL
                      SELECT 31                    npp,
                             SUM (x_narah)         x_narah,
                             SUM (
                                 CASE
                                     WHEN x_dt = TRUNC (p_start_dt, 'mm')
                                     THEN
                                         x_narah
                                     ELSE
                                         0
                                 END)              x_narah_m,
                             SUM (x_pay)           x_pay,
                             SUM (
                                 CASE
                                     WHEN x_dt = TRUNC (p_start_dt, 'mm')
                                     THEN
                                         x_pay
                                     ELSE
                                         0
                                 END)              x_pay_m,
                             SUM (x_pay_befor)     x_pay_befor,
                             SUM (x_payed)         x_payed,
                             SUM (
                                 CASE
                                     WHEN x_dt = TRUNC (p_start_dt, 'mm')
                                     THEN
                                         x_payed
                                     ELSE
                                         0
                                 END)              x_payed_m,
                             SUM (x_borh_befor)    x_borh_befor
                        FROM uss_esr.tmp_nrh_rpt_data
                       WHERE nptc_npt IN (565)        -- ДОПОМОГА НА ПОХОВАННЯ
                                              ) n
                         ON n.npp = rpt.ca
            ORDER BY 2;

    -- IC #101329 Оновлюємо виплачені суми на дані зі списку відомостей
    FOR c IN (
    WITH org AS (SELECT org_id i_org
                    FROM ikis_sys.v_opfu
                    WHERE l_org_to = 32
                        CONNECT BY PRIOR org_id = org_org
                        START WITH org_id = l_user_org                          -- Org_id Органу ОПФУ
                    UNION ALL
                 SELECT org_id i_org
                    FROM ikis_sys.v_opfu
                    WHERE l_org_to = 34
                        AND org_acc_org = l_user_org),
    dt_rep AS (SELECT TRUNC(
                        p_start_dt,                                             -- Звітний місяць
                        'mm') dtb
                    FROM DUAL),
    nst_rep AS (SELECT c.nptc_npt npt_id, c.nptc_nst nst_id
                    FROM USS_NDI.v_Ndi_Npt_Config c
                    WHERE c.nptc_nst = 248                                      -- nst_id послуги
                    )

    SELECT  1 npp,
            SUM(CASE WHEN prs_st IN ('NA', 'KV1', 'KV2') THEN prsd_sum    -- ручне блокування, IC #117053 Заблоковано по КВ1, KB2
                    ELSE 0 END) x_pay_fact,
            SUM(CASE WHEN pr_month = dt_rep.dtb
                        AND prs_st IN ('NA', 'KV1', 'KV2') THEN prsd_sum
                ELSE 0 END)     x_pay_fact_m,
            SUM(CASE WHEN prsd_month < TRUNC(dt_rep.dtb,'yy')
                        AND prs_st IN ('NA', 'KV1', 'KV2') THEN prsd_sum
                ELSE 0 END)     x_pay_fact_befor_y,
            SUM(prsd_sum)       x_pay,
            SUM(CASE WHEN pr_month = dt_rep.dtb THEN prsd_sum
                ELSE 0 END)     x_pay_m
        FROM org
            INNER JOIN ikis_sys.v_opfu o        ON o.org_id = i_org
            INNER JOIN uss_esr.payroll pr       ON pr.com_org = o.org_id
            INNER JOIN uss_esr.pr_sheet s       ON s.prs_pr = pr.pr_id
            INNER JOIN uss_esr.pr_sheet_detail  ON prsd_prs = s.prs_id
            INNER JOIN dt_rep                   ON pr_month >= TRUNC(dt_rep.dtb,'yy')
                                                    AND pr_month <= dt_rep.dtb
        WHERE prs_st IN ('NA', 'KV1', 'KV2', 'PK1', 'PK2', 'PP')--#100219
            AND prsd_tp IN ('PWI', 'RDN') -- тільки виплата
            AND pr_st IN ('F')
            AND prs_tp IN ('PB', 'PP')
            AND prsd_npt IN (SELECT npt_id FROM nst_rep)
    UNION ALL
    SELECT  11  npp,    -- Надбавка на догляд за особою з інвалідністю з дитинства та дитини з інвалідністю
            SUM(CASE WHEN prs_st IN ('NA', 'KV1', 'KV2') THEN prsd_sum    -- ручне блокування
                    ELSE 0 END) x_pay_fact,
            SUM(CASE WHEN pr_month = dt_rep.dtb
                        AND prs_st IN ('NA', 'KV1', 'KV2') THEN prsd_sum
                ELSE 0 END)     x_pay_fact_m,
            SUM(CASE WHEN prsd_month < TRUNC(dt_rep.dtb,'yy')
                        AND prs_st IN ('NA', 'KV1', 'KV2') THEN prsd_sum
                ELSE 0 END)     x_pay_fact_befor_y,
            SUM(prsd_sum)       x_pay,
            SUM(CASE WHEN pr_month = dt_rep.dtb THEN prsd_sum
                ELSE 0 END)     x_pay_m
        FROM org
            INNER JOIN ikis_sys.v_opfu o        ON o.org_id = i_org
            INNER JOIN uss_esr.payroll pr       ON pr.com_org = o.org_id
            INNER JOIN uss_esr.pr_sheet s       ON s.prs_pr = pr.pr_id
            INNER JOIN uss_esr.pr_sheet_detail  ON prsd_prs = s.prs_id
            INNER JOIN dt_rep                   ON pr_month >= TRUNC(dt_rep.dtb,'yy')
                                                    AND pr_month <= dt_rep.dtb
        WHERE prs_st IN ('NA', 'KV1', 'KV2', 'PK1', 'PK2', 'PP')--#100219
            AND prsd_tp IN ('PWI', 'RDN') -- тільки виплата
            AND pr_st IN ('F')
            AND prs_tp IN ('PB', 'PP')
            AND prsd_npt = 1
            AND EXISTS (SELECT 1
                            FROM uss_esr.ac_detail d,
                                 uss_esr.pd_payment pp,
                                 uss_esr.pd_detail pd
                            WHERE d.acd_prsd = prsd_id
                                  AND pp.pdp_pd = d.acd_pd
                                  AND pp.pdp_id = pd.pdd_pdp
                                  AND pp.history_status = 'A'
                                  AND pr_month BETWEEN TRUNC(pd.pdd_start_dt,'mm') AND pd.pdd_stop_dt
                                  AND pd.pdd_npt = 48)
    UNION ALL
    SELECT  31 npp, -- ДОПОМОГА НА ПОХОВАННЯ
            SUM(CASE WHEN prs_st IN ('NA', 'KV1', 'KV2') THEN prsd_sum    -- ручне блокування
                    ELSE 0 END) x_pay_fact,
            SUM(CASE WHEN pr_month = dt_rep.dtb
                        AND prs_st IN ('NA', 'KV1', 'KV2') THEN prsd_sum
                ELSE 0 END)     x_pay_fact_m,
            SUM(CASE WHEN prsd_month < TRUNC(dt_rep.dtb,'yy')
                        AND prs_st IN ('NA', 'KV1', 'KV2') THEN prsd_sum
                ELSE 0 END)     x_pay_fact_befor_y,
            SUM(prsd_sum)       x_pay,
            SUM(CASE WHEN pr_month = dt_rep.dtb THEN prsd_sum
                ELSE 0 END)     x_pay_m
        FROM org
            INNER JOIN ikis_sys.v_opfu o        ON o.org_id = i_org
            INNER JOIN uss_esr.payroll pr       ON pr.com_org = o.org_id
            INNER JOIN uss_esr.pr_sheet s       ON s.prs_pr = pr.pr_id
            INNER JOIN uss_esr.pr_sheet_detail  ON prsd_prs = s.prs_id
            INNER JOIN dt_rep                   ON pr_month >= TRUNC(dt_rep.dtb,'yy')
                                                    AND pr_month <= dt_rep.dtb
        WHERE prs_st IN ('NA', 'KV1', 'KV2', 'PK1', 'PK2', 'PP')--#100219
            AND prsd_tp IN ('PWI', 'RDN') -- тільки виплата
            AND pr_st IN ('F')
            AND prs_tp IN ('PB', 'PP')
            AND prsd_npt IN (565)
            ) LOOP

        UPDATE tmp_univ_rpt_data
            SET x_sum3 = c.x_pay_fact,
                x_sum4 = c.x_pay_fact_m,
                x_sum5 = 0, --c.x_pay_fact_befor_y,
                x_sum6 = c.x_pay,
                x_sum7 = c.x_pay_m
            WHERE x_id1 = c.npp;

    END LOOP;



        UPDATE tmp_univ_rpt_data
           SET x_id2 = NVL (x_id2, 0),
               x_id3 = NVL (x_id3, 0),
               x_id4 = NVL (x_id4, 0),
               x_id5 = NVL (x_id5, 0),
               x_sum1 = NVL (x_sum1, 0),
               x_sum2 = NVL (x_sum2, 0),
               x_sum3 = NVL (x_sum3, 0),
               x_sum4 = NVL (x_sum4, 0),
               x_sum5 = NVL (x_sum5, 0),
               x_sum6 = NVL (x_sum6, 0),
               x_sum7 = NVL (x_sum7, 0),
               x_sum8 = NVL (x_sum8, 0),
               x_sum9 = NVL (x_sum9, 0),
               x_sum10 = NVL (x_sum10, 0)
         WHERE 1 = 1;

        UPDATE tmp_univ_rpt_data
           SET x_id2 =
                   (SELECT SUM (a.x_id2)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (3, 5, 6)),
               x_id3 =
                   (SELECT SUM (a.x_id3)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (3, 5, 6)),
               x_id4 =
                   (SELECT SUM (a.x_id4)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (3, 5, 6)),
               x_id5 =
                   (SELECT SUM (a.x_id5)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (3, 5, 6)),
               x_sum9 =
                   (SELECT SUM (a.x_sum9)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (3, 5, 6)),
               x_sum10 =
                   (SELECT SUM (a.x_sum10)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (3, 5, 6))
         WHERE x_id1 = 2;

        UPDATE tmp_univ_rpt_data
           SET x_id2 =
                   (SELECT SUM (a.x_id2)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (2, 7)),
               x_id3 =
                   (SELECT SUM (a.x_id3)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (2, 7)),
               x_id4 =
                   (SELECT SUM (a.x_id4)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (2, 7)),
               x_id5 =
                   (SELECT SUM (a.x_id5)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (2, 7)),
               x_sum9 =
                   (SELECT SUM (a.x_sum9)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (2, 7)),
               x_sum10 =
                   (SELECT SUM (a.x_sum10)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (2, 7))
         WHERE x_id1 = 1;

        UPDATE tmp_univ_rpt_data
           SET x_id2 =
                   (SELECT SUM (a.x_id2)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (20, 21)),
               x_id3 =
                   (SELECT SUM (a.x_id3)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (20, 21)),
               x_id4 =
                   (SELECT SUM (a.x_id4)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (20, 21)),
               x_id5 =
                   (SELECT SUM (a.x_id5)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (20, 21)),
               x_sum9 =
                   (SELECT SUM (a.x_sum9)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (20, 21)),
               x_sum10 =
                   (SELECT SUM (a.x_sum10)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (20, 21))
         WHERE x_id1 = 19;

        UPDATE tmp_univ_rpt_data
           SET x_id2 =
                   (SELECT SUM (a.x_id2)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (13, 14, 15)),
               x_id3 =
                   (SELECT SUM (a.x_id3)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (13, 14, 15)),
               x_id4 =
                   (SELECT SUM (a.x_id4)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (13, 14, 15)),
               x_id5 =
                   (SELECT SUM (a.x_id5)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (13, 14, 15)),
               x_sum9 =
                   (SELECT SUM (a.x_sum9)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (13, 14, 15)),
               x_sum10 =
                   (SELECT SUM (a.x_sum10)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (13, 14, 15))
         WHERE x_id1 = 12;

        UPDATE tmp_univ_rpt_data
           SET x_id2 =
                   (SELECT SUM (a.x_id2)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (17, 18)),
               x_id3 =
                   (SELECT SUM (a.x_id3)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (17, 18)),
               x_id4 =
                   (SELECT SUM (a.x_id4)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (17, 18)),
               x_id5 =
                   (SELECT SUM (a.x_id5)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (17, 18)),
               x_sum9 =
                   (SELECT SUM (a.x_sum9)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (17, 18)),
               x_sum10 =
                   (SELECT SUM (a.x_sum10)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (17, 18))
         WHERE x_id1 = 16;

        UPDATE tmp_univ_rpt_data
           SET x_id2 =
                   (SELECT SUM (a.x_id2)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (23, 24)),
               x_id3 =
                   (SELECT SUM (a.x_id3)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (23, 24)),
               x_id4 =
                   (SELECT SUM (a.x_id4)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (23, 24)),
               x_id5 =
                   (SELECT SUM (a.x_id5)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (23, 24)),
               x_sum9 =
                   (SELECT SUM (a.x_sum9)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (23, 24)),
               x_sum10 =
                   (SELECT SUM (a.x_sum10)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (23, 24))
         WHERE x_id1 = 22;

        UPDATE tmp_univ_rpt_data
           SET x_id2 =
                   (SELECT SUM (a.x_id2)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (26, 27)),
               x_id3 =
                   (SELECT SUM (a.x_id3)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (26, 27)),
               x_id4 =
                   (SELECT SUM (a.x_id4)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (26, 27)),
               x_id5 =
                   (SELECT SUM (a.x_id5)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (26, 27)),
               x_sum9 =
                   (SELECT SUM (a.x_sum9)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (26, 27)),
               x_sum10 =
                   (SELECT SUM (a.x_sum10)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (26, 27))
         WHERE x_id1 = 25;

        UPDATE tmp_univ_rpt_data
           SET x_id2 =
                   (SELECT SUM (a.x_id2)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (29, 30)),
               x_id3 =
                   (SELECT SUM (a.x_id3)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (29, 30)),
               x_id4 =
                   (SELECT SUM (a.x_id4)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (29, 30)),
               x_id5 =
                   (SELECT SUM (a.x_id5)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (29, 30)),
               x_sum9 =
                   (SELECT SUM (a.x_sum9)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (29, 30)),
               x_sum10 =
                   (SELECT SUM (a.x_sum10)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (29, 30))
         WHERE x_id1 = 28;

        UPDATE tmp_univ_rpt_data
           SET x_id2 =
                   (SELECT SUM (a.x_id2)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (12, 16)),
               x_id3 =
                   (SELECT SUM (a.x_id3)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (12, 16)),
               x_id4 =
                   (SELECT SUM (a.x_id4)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (12, 16)),
               x_id5 =
                   (SELECT SUM (a.x_id5)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (12, 16)),
               x_sum9 =
                   (SELECT SUM (a.x_sum9)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (12, 16)),
               x_sum10 =
                   (SELECT SUM (a.x_sum10)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (12, 16))
         WHERE x_id1 = 11;

        UPDATE tmp_univ_rpt_data
           SET x_id2 =
                   (SELECT SUM (a.x_id2)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (33, 34, 35)),
               x_id3 =
                   (SELECT SUM (a.x_id3)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (33, 34, 35)),
               x_id4 =
                   (SELECT SUM (a.x_id4)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (33, 34, 35)),
               x_id5 =
                   (SELECT SUM (a.x_id5)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (33, 34, 35)),
               x_sum9 =
                   (SELECT SUM (a.x_sum9)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (33, 34, 35)),
               x_sum10 =
                   (SELECT SUM (a.x_sum10)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (33, 34, 35))
         WHERE x_id1 = 32;

        UPDATE tmp_univ_rpt_data
           SET x_id2 =
                   (SELECT SUM (a.x_id2)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (32, 36)),
               x_id3 =
                   (SELECT SUM (a.x_id3)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (32, 36)),
               x_id4 =
                   (SELECT SUM (a.x_id4)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (32, 36)),
               x_id5 =
                   (SELECT SUM (a.x_id5)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (32, 36)),
               x_sum9 =
                   (SELECT SUM (a.x_sum9)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (32, 36)),
               x_sum10 =
                   (SELECT SUM (a.x_sum10)
                      FROM tmp_univ_rpt_data a
                     WHERE a.x_id1 IN (32, 36))
         WHERE x_id1 = 31;

        --qq
        FOR c IN (SELECT a.*
                    FROM tmp_univ_rpt_data a
                   WHERE x_id1 IN (1)                                -- блок 1
                                     )
        LOOP
            SELECT SUM (x_sum9)
              INTO l_sum
              FROM tmp_univ_rpt_data
             WHERE x_id1 IN (2, 7);

            -- Визначаємо пропорцію інвалідів з дитинства до дітей інвалідів
            IF NVL (l_sum, 0) > 0
            THEN
                SELECT x_sum9 / l_sum
                  INTO l_prc
                  FROM tmp_univ_rpt_data
                 WHERE x_id1 = 2;
            ELSE
                l_prc := 0;
            END IF;

            UPDATE tmp_univ_rpt_data
               SET x_sum1 = ROUND (c.x_sum1 * l_prc, 2),
                   x_sum2 = ROUND (c.x_sum2 * l_prc, 2),
                   x_sum3 = ROUND (c.x_sum3 * l_prc, 2),
                   x_sum4 = ROUND (c.x_sum4 * l_prc, 2),
                   x_sum5 = ROUND (c.x_sum5 * l_prc, 2),
                   x_sum6 = ROUND (c.x_sum6 * l_prc, 2),
                   x_sum7 = ROUND (c.x_sum7 * l_prc, 2),
                   x_sum8 = ROUND (c.x_sum8 * l_prc, 2)
             WHERE x_id1 = 2;

            UPDATE tmp_univ_rpt_data
               SET x_sum1 =
                       (SELECT c.x_sum1 - a.x_sum1
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 = 2),
                   x_sum2 =
                       (SELECT c.x_sum2 - a.x_sum2
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 = 2),
                   x_sum3 =
                       (SELECT c.x_sum3 - a.x_sum3
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 = 2),
                   x_sum4 =
                       (SELECT c.x_sum4 - a.x_sum4
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 = 2),
                   x_sum5 =
                       (SELECT c.x_sum5 - a.x_sum5
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 = 2),
                   x_sum6 =
                       (SELECT c.x_sum6 - a.x_sum6
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 = 2),
                   x_sum7 =
                       (SELECT c.x_sum7 - a.x_sum7
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 = 2),
                   x_sum8 =
                       (SELECT c.x_sum8 - a.x_sum8
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 = 2)
             WHERE x_id1 = 7;
        END LOOP;

        FOR c IN (SELECT *
                    FROM tmp_univ_rpt_data a
                   WHERE x_id1 = 2                                 -- блок 1.1
                                  )
        LOOP
            UPDATE tmp_univ_rpt_data
               SET x_sum1 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum1 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum2 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum2 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum3 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum3 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum4 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum4 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum5 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum5 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum6 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum6 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum7 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum7 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum8 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum8 * (x_sum9 / c.x_sum9)
                           END,
                           2)
             WHERE x_id1 IN (3, 5);

            UPDATE tmp_univ_rpt_data
               SET x_sum1 =
                       (SELECT c.x_sum1 - SUM (a.x_sum1)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (3, 5)),
                   x_sum2 =
                       (SELECT c.x_sum2 - SUM (a.x_sum2)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (3, 5)),
                   x_sum3 =
                       (SELECT c.x_sum3 - SUM (a.x_sum3)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (3, 5)),
                   x_sum4 =
                       (SELECT c.x_sum4 - SUM (a.x_sum4)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (3, 5)),
                   x_sum5 =
                       (SELECT c.x_sum5 - SUM (a.x_sum5)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (3, 5)),
                   x_sum6 =
                       (SELECT c.x_sum6 - SUM (a.x_sum6)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (3, 5)),
                   x_sum7 =
                       (SELECT c.x_sum7 - SUM (a.x_sum7)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (3, 5)),
                   x_sum8 =
                       (SELECT c.x_sum8 - SUM (a.x_sum8)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (3, 5))
             WHERE x_id1 = 6;

            SELECT *
              INTO l_tmp
              FROM tmp_univ_rpt_data
             WHERE x_id1 = 3;

            UPDATE tmp_univ_rpt_data
               SET x_sum1 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum1 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum2 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum2 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum3 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum3 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum4 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum4 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum5 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum5 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum6 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum6 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum7 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum7 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum8 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum8 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2)
             WHERE x_id1 = 4;
        END LOOP;

        FOR c IN (SELECT *
                    FROM tmp_univ_rpt_data a
                   WHERE x_id1 = 7                                 -- блок 1.2
                                  )
        LOOP
            UPDATE tmp_univ_rpt_data
               SET x_sum1 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum1 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum2 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum2 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum3 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum3 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum4 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum4 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum5 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum5 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum6 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum6 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum7 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum7 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum8 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum8 * (x_sum9 / c.x_sum9)
                           END,
                           2)
             WHERE x_id1 IN (8, 9, 10);
        END LOOP;

        FOR c IN (SELECT a.*
                    FROM tmp_univ_rpt_data a
                   WHERE x_id1 IN (11)                               -- блок 2
                                      )
        LOOP
            SELECT SUM (x_sum9)
              INTO l_sum
              FROM tmp_univ_rpt_data
             WHERE x_id1 IN (12, 16);

            -- Визначаємо пропорцію інвалідів з дитинства до дітей інвалідів
            IF NVL (l_sum, 0) > 0
            THEN
                SELECT x_sum9 / l_sum
                  INTO l_prc
                  FROM tmp_univ_rpt_data
                 WHERE x_id1 = 12;
            ELSE
                l_prc := 0;
            END IF;

            UPDATE tmp_univ_rpt_data
               SET x_sum1 = ROUND (c.x_sum1 * l_prc, 2),
                   x_sum2 = ROUND (c.x_sum2 * l_prc, 2),
                   x_sum3 = ROUND (c.x_sum3 * l_prc, 2),
                   x_sum4 = ROUND (c.x_sum4 * l_prc, 2),
                   x_sum5 = ROUND (c.x_sum5 * l_prc, 2),
                   x_sum6 = ROUND (c.x_sum6 * l_prc, 2),
                   x_sum7 = ROUND (c.x_sum7 * l_prc, 2),
                   x_sum8 = ROUND (c.x_sum8 * l_prc, 2)
             WHERE x_id1 = 12;

            UPDATE tmp_univ_rpt_data
               SET x_sum1 =
                       (SELECT c.x_sum1 - a.x_sum1
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 = 12),
                   x_sum2 =
                       (SELECT c.x_sum2 - a.x_sum2
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 = 12),
                   x_sum3 =
                       (SELECT c.x_sum3 - a.x_sum3
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 = 12),
                   x_sum4 =
                       (SELECT c.x_sum4 - a.x_sum4
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 = 12),
                   x_sum5 =
                       (SELECT c.x_sum5 - a.x_sum5
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 = 12),
                   x_sum6 =
                       (SELECT c.x_sum6 - a.x_sum6
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 = 12),
                   x_sum7 =
                       (SELECT c.x_sum7 - a.x_sum7
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 = 12),
                   x_sum8 =
                       (SELECT c.x_sum8 - a.x_sum8
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 = 12)
             WHERE x_id1 = 16;
        END LOOP;

        FOR c IN (SELECT *
                    FROM tmp_univ_rpt_data a
                   WHERE x_id1 = 12                                -- блок 2.1
                                   )
        LOOP
            UPDATE tmp_univ_rpt_data
               SET x_sum1 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum1 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum2 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum2 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum3 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum3 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum4 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum4 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum5 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum5 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum6 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum6 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum7 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum7 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum8 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum8 * (x_sum9 / c.x_sum9)
                           END,
                           2)
             WHERE x_id1 IN (13, 14);

            UPDATE tmp_univ_rpt_data
               SET x_sum1 =
                       (SELECT c.x_sum1 - SUM (a.x_sum1)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (13, 14)),
                   x_sum2 =
                       (SELECT c.x_sum2 - SUM (a.x_sum2)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (13, 14)),
                   x_sum3 =
                       (SELECT c.x_sum3 - SUM (a.x_sum3)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (13, 14)),
                   x_sum4 =
                       (SELECT c.x_sum4 - SUM (a.x_sum4)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (13, 14)),
                   x_sum5 =
                       (SELECT c.x_sum5 - SUM (a.x_sum5)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (13, 14)),
                   x_sum6 =
                       (SELECT c.x_sum6 - SUM (a.x_sum6)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (13, 14)),
                   x_sum7 =
                       (SELECT c.x_sum7 - SUM (a.x_sum7)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (13, 14)),
                   x_sum8 =
                       (SELECT c.x_sum8 - SUM (a.x_sum8)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (13, 14))
             WHERE x_id1 = 15;
        END LOOP;

        FOR c IN (SELECT *
                    FROM tmp_univ_rpt_data a
                   WHERE x_id1 = 16                                -- блок 2.2
                                   )
        LOOP
            UPDATE tmp_univ_rpt_data
               SET x_sum1 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum1 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum2 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum2 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum3 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum3 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum4 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum4 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum5 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum5 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum6 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum6 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum7 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum7 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum8 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum8 * (x_sum9 / c.x_sum9)
                           END,
                           2)
             WHERE x_id1 IN (17);

            UPDATE tmp_univ_rpt_data
               SET x_sum1 =
                       (SELECT c.x_sum1 - SUM (a.x_sum1)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (17)),
                   x_sum2 =
                       (SELECT c.x_sum2 - SUM (a.x_sum2)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (17)),
                   x_sum3 =
                       (SELECT c.x_sum3 - SUM (a.x_sum3)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (17)),
                   x_sum4 =
                       (SELECT c.x_sum4 - SUM (a.x_sum4)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (17)),
                   x_sum5 =
                       (SELECT c.x_sum5 - SUM (a.x_sum5)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (17)),
                   x_sum6 =
                       (SELECT c.x_sum6 - SUM (a.x_sum6)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (17)),
                   x_sum7 =
                       (SELECT c.x_sum7 - SUM (a.x_sum7)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (17)),
                   x_sum8 =
                       (SELECT c.x_sum8 - SUM (a.x_sum8)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (17))
             WHERE x_id1 = 18;

            UPDATE tmp_univ_rpt_data
               SET x_sum1 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum1 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum2 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum2 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum3 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum3 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum4 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum4 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum5 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum5 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum6 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum6 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum7 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum7 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum8 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum8 * (x_sum9 / c.x_sum9)
                           END,
                           2)
             WHERE x_id1 = 19;

            SELECT *
              INTO l_tmp
              FROM tmp_univ_rpt_data
             WHERE x_id1 = 19;

            UPDATE tmp_univ_rpt_data
               SET x_sum1 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum1 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum2 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum2 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum3 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum3 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum4 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum4 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum5 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum5 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum6 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum6 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum7 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum7 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum8 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum8 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2)
             WHERE x_id1 = 20;

            UPDATE tmp_univ_rpt_data
               SET x_sum1 =
                       (SELECT l_tmp.x_sum1 - SUM (a.x_sum1)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (20)),
                   x_sum2 =
                       (SELECT l_tmp.x_sum2 - SUM (a.x_sum2)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (20)),
                   x_sum3 =
                       (SELECT l_tmp.x_sum3 - SUM (a.x_sum3)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (20)),
                   x_sum4 =
                       (SELECT l_tmp.x_sum4 - SUM (a.x_sum4)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (20)),
                   x_sum5 =
                       (SELECT l_tmp.x_sum5 - SUM (a.x_sum5)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (20)),
                   x_sum6 =
                       (SELECT l_tmp.x_sum6 - SUM (a.x_sum6)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (20)),
                   x_sum7 =
                       (SELECT l_tmp.x_sum7 - SUM (a.x_sum7)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (20)),
                   x_sum8 =
                       (SELECT l_tmp.x_sum8 - SUM (a.x_sum8)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (20))
             WHERE x_id1 = 21;

            UPDATE tmp_univ_rpt_data
               SET x_sum1 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum1 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum2 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum2 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum3 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum3 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum4 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum4 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum5 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum5 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum6 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum6 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum7 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum7 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum8 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum8 * (x_sum9 / c.x_sum9)
                           END,
                           2)
             WHERE x_id1 = 22;

            SELECT *
              INTO l_tmp
              FROM tmp_univ_rpt_data
             WHERE x_id1 = 22;

            UPDATE tmp_univ_rpt_data
               SET x_sum1 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum1 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum2 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum2 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum3 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum3 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum4 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum4 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum5 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum5 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum6 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum6 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum7 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum7 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum8 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum8 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2)
             WHERE x_id1 = 23;

            UPDATE tmp_univ_rpt_data
               SET x_sum1 =
                       (SELECT l_tmp.x_sum1 - SUM (a.x_sum1)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (23)),
                   x_sum2 =
                       (SELECT l_tmp.x_sum2 - SUM (a.x_sum2)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (23)),
                   x_sum3 =
                       (SELECT l_tmp.x_sum3 - SUM (a.x_sum3)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (23)),
                   x_sum4 =
                       (SELECT l_tmp.x_sum4 - SUM (a.x_sum4)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (23)),
                   x_sum5 =
                       (SELECT l_tmp.x_sum5 - SUM (a.x_sum5)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (23)),
                   x_sum6 =
                       (SELECT l_tmp.x_sum6 - SUM (a.x_sum6)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (23)),
                   x_sum7 =
                       (SELECT l_tmp.x_sum7 - SUM (a.x_sum7)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (23)),
                   x_sum8 =
                       (SELECT l_tmp.x_sum8 - SUM (a.x_sum8)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (23))
             WHERE x_id1 = 24;

            UPDATE tmp_univ_rpt_data
               SET x_sum1 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum1 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum2 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum2 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum3 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum3 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum4 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum4 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum5 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum5 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum6 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum6 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum7 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum7 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum8 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum8 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2)
             WHERE x_id1 = 25;

            SELECT *
              INTO l_tmp
              FROM tmp_univ_rpt_data
             WHERE x_id1 = 25;

            UPDATE tmp_univ_rpt_data
               SET x_sum1 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum1 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum2 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum2 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum3 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum3 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum4 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum4 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum5 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum5 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum6 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum6 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum7 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum7 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum8 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum8 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2)
             WHERE x_id1 = 26;

            UPDATE tmp_univ_rpt_data
               SET x_sum1 =
                       (SELECT l_tmp.x_sum1 - SUM (a.x_sum1)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (26)),
                   x_sum2 =
                       (SELECT l_tmp.x_sum2 - SUM (a.x_sum2)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (26)),
                   x_sum3 =
                       (SELECT l_tmp.x_sum3 - SUM (a.x_sum3)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (26)),
                   x_sum4 =
                       (SELECT l_tmp.x_sum4 - SUM (a.x_sum4)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (26)),
                   x_sum5 =
                       (SELECT l_tmp.x_sum5 - SUM (a.x_sum5)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (26)),
                   x_sum6 =
                       (SELECT l_tmp.x_sum6 - SUM (a.x_sum6)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (26)),
                   x_sum7 =
                       (SELECT l_tmp.x_sum7 - SUM (a.x_sum7)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (26)),
                   x_sum8 =
                       (SELECT l_tmp.x_sum8 - SUM (a.x_sum8)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (26))
             WHERE x_id1 = 27;

            UPDATE tmp_univ_rpt_data
               SET x_sum1 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum1 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum2 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum2 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum3 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum3 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum4 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum4 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum5 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum5 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum6 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum6 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum7 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum7 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum8 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum8 * (x_sum9 / c.x_sum9)
                           END,
                           2)
             WHERE x_id1 = 28;

            SELECT *
              INTO l_tmp
              FROM tmp_univ_rpt_data
             WHERE x_id1 = 28;

            UPDATE tmp_univ_rpt_data
               SET x_sum1 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum1 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum2 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum2 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum3 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum3 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum4 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum4 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum5 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum5 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum6 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum6 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum7 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum7 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2),
                   x_sum8 =
                       ROUND (
                           CASE
                               WHEN NVL (l_tmp.x_sum9, 0) = 0 THEN 0
                               ELSE l_tmp.x_sum8 * (x_sum9 / l_tmp.x_sum9)
                           END,
                           2)
             WHERE x_id1 = 29;

            UPDATE tmp_univ_rpt_data
               SET x_sum1 =
                       (SELECT l_tmp.x_sum1 - SUM (a.x_sum1)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (29)),
                   x_sum2 =
                       (SELECT l_tmp.x_sum2 - SUM (a.x_sum2)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (29)),
                   x_sum3 =
                       (SELECT l_tmp.x_sum3 - SUM (a.x_sum3)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (29)),
                   x_sum4 =
                       (SELECT l_tmp.x_sum4 - SUM (a.x_sum4)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (29)),
                   x_sum5 =
                       (SELECT l_tmp.x_sum5 - SUM (a.x_sum5)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (29)),
                   x_sum6 =
                       (SELECT l_tmp.x_sum6 - SUM (a.x_sum6)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (29)),
                   x_sum7 =
                       (SELECT l_tmp.x_sum7 - SUM (a.x_sum7)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (29)),
                   x_sum8 =
                       (SELECT l_tmp.x_sum8 - SUM (a.x_sum8)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (29))
             WHERE x_id1 = 30;
        END LOOP;                                                  -- блок 2.2

        FOR c IN (SELECT a.*
                    FROM tmp_univ_rpt_data a
                   WHERE x_id1 IN (31)                               -- блок 3
                                      )
        LOOP
            SELECT SUM (x_sum9)
              INTO l_sum
              FROM tmp_univ_rpt_data
             WHERE x_id1 IN (32, 36);

            -- Визначаємо пропорцію інвалідів з дитинства до дітей інвалідів
            IF NVL (l_sum, 0) > 0
            THEN
                SELECT x_sum9 / l_sum
                  INTO l_prc
                  FROM tmp_univ_rpt_data
                 WHERE x_id1 = 32;
            ELSE
                l_prc := 0;
            END IF;

            UPDATE tmp_univ_rpt_data
               SET x_sum1 = ROUND (c.x_sum1 * l_prc, 2),
                   x_sum2 = ROUND (c.x_sum2 * l_prc, 2),
                   x_sum3 = ROUND (c.x_sum3 * l_prc, 2),
                   x_sum4 = ROUND (c.x_sum4 * l_prc, 2),
                   x_sum5 = ROUND (c.x_sum5 * l_prc, 2),
                   x_sum6 = ROUND (c.x_sum6 * l_prc, 2),
                   x_sum7 = ROUND (c.x_sum7 * l_prc, 2),
                   x_sum8 = ROUND (c.x_sum8 * l_prc, 2)
             WHERE x_id1 = 32;

            UPDATE tmp_univ_rpt_data
               SET x_sum1 =
                       (SELECT c.x_sum1 - a.x_sum1
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 = 32),
                   x_sum2 =
                       (SELECT c.x_sum2 - a.x_sum2
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 = 32),
                   x_sum3 =
                       (SELECT c.x_sum3 - a.x_sum3
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 = 32),
                   x_sum4 =
                       (SELECT c.x_sum4 - a.x_sum4
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 = 32),
                   x_sum5 =
                       (SELECT c.x_sum5 - a.x_sum5
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 = 32),
                   x_sum6 =
                       (SELECT c.x_sum6 - a.x_sum6
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 = 32),
                   x_sum7 =
                       (SELECT c.x_sum7 - a.x_sum7
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 = 32),
                   x_sum8 =
                       (SELECT c.x_sum8 - a.x_sum8
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 = 32)
             WHERE x_id1 = 36;
        END LOOP;                                                    -- блок 3

        FOR c IN (SELECT *
                    FROM tmp_univ_rpt_data a
                   WHERE x_id1 = 32                                -- блок 3.1
                                   )
        LOOP
            UPDATE tmp_univ_rpt_data
               SET x_sum1 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum1 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum2 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum2 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum3 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum3 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum4 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum4 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum5 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum5 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum6 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum6 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum7 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum7 * (x_sum9 / c.x_sum9)
                           END,
                           2),
                   x_sum8 =
                       ROUND (
                           CASE
                               WHEN NVL (c.x_sum9, 0) = 0 THEN 0
                               ELSE c.x_sum8 * (x_sum9 / c.x_sum9)
                           END,
                           2)
             WHERE x_id1 IN (33, 34);

            UPDATE tmp_univ_rpt_data
               SET x_sum1 =
                       (SELECT c.x_sum1 - SUM (a.x_sum1)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (33, 34)),
                   x_sum2 =
                       (SELECT c.x_sum2 - SUM (a.x_sum2)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (33, 34)),
                   x_sum3 =
                       (SELECT c.x_sum3 - SUM (a.x_sum3)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (33, 34)),
                   x_sum4 =
                       (SELECT c.x_sum4 - SUM (a.x_sum4)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (33, 34)),
                   x_sum5 =
                       (SELECT c.x_sum5 - SUM (a.x_sum5)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (33, 34)),
                   x_sum6 =
                       (SELECT c.x_sum6 - SUM (a.x_sum6)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (33, 34)),
                   x_sum7 =
                       (SELECT c.x_sum7 - SUM (a.x_sum7)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (33, 34)),
                   x_sum8 =
                       (SELECT c.x_sum8 - SUM (a.x_sum8)
                          FROM tmp_univ_rpt_data a
                         WHERE a.x_id1 IN (33, 34))
             WHERE x_id1 = 35;
        END LOOP;                                                  -- блок 3.1


        --qq3
        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0" ss:Height="34.199999999999996">
    <Cell ss:StyleID="s160"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
    <Cell ss:StyleID="s161"><Data ss:Type="String">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s162"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s163"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s163"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s164"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s165"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s166"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s165"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s167"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s168"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s165"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s168"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s169"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s167"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s168"><Data ss:Type="Number"></Data></Cell>
   </Row>'
         WHERE x_id1 = 1;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0" ss:Height="31.799999999999997">
    <Cell ss:StyleID="s170"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
    <Cell ss:StyleID="s171"><Data ss:Type="String">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s172"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s173"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s173"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s174"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s175"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s176"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s175"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s177"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s178"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s175"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s178"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s179"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s177"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s178"><Data ss:Type="Number"></Data></Cell>
   </Row>'
         WHERE x_id1 = 2;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0">
    <Cell ss:StyleID="s180"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
    <Cell ss:StyleID="s171"><Data ss:Type="String">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s181"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s182"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s182"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s183"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s185"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s188"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s189"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number"></Data></Cell>
   </Row>'
         WHERE x_id1 = 3;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0">
    <Cell ss:StyleID="s190"><ss:Data ss:Type="String"
      xmlns="http://www.w3.org/TR/REC-html40">'
                   || x_string1
                   || '</ss:Data></Cell>
    <Cell ss:StyleID="s171"><Data ss:Type="String">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s181"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s182"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s182"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s183"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s185"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s188"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s189"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number"></Data></Cell>
   </Row>'
         WHERE x_id1 = 4;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0">
    <Cell ss:StyleID="s180"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
    <Cell ss:StyleID="s171"><Data ss:Type="String">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s181"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s182"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s182"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s183"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s185"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s188"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s189"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number"></Data></Cell>
   </Row>'
         WHERE x_id1 = 5;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0">
    <Cell ss:StyleID="s180"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
    <Cell ss:StyleID="s171"><Data ss:Type="String">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s181"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s182"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s182"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s183"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s185"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s188"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s189"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number"></Data></Cell>
   </Row>'
         WHERE x_id1 = 6;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0" ss:Height="21.45">
    <Cell ss:StyleID="s170"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
    <Cell ss:StyleID="s171"><Data ss:Type="String">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s181"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s182"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s182"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s183"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s185"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s188"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s189"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number"></Data></Cell>
   </Row>'
         WHERE x_id1 = 7;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0">
    <Cell ss:StyleID="s191"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
    <Cell ss:StyleID="s171"><Data ss:Type="String">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s192"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s182"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s182"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s183"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s185"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s188"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s189"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s193"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s194"><Data ss:Type="Number"></Data></Cell>
   </Row>'
         WHERE x_id1 = 8;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0" ss:Height="19.2">
    <Cell ss:StyleID="s191"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
    <Cell ss:StyleID="s171"><Data ss:Type="String">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s192"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s182"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s182"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s183"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s185"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s188"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s189"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s193"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s194"><Data ss:Type="Number">0</Data></Cell>
   </Row>'
         WHERE x_id1 = 9;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0" ss:Height="19.8">
    <Cell ss:StyleID="s195"><ss:Data ss:Type="String"
      xmlns="http://www.w3.org/TR/REC-html40">'
                   || x_string1
                   || '</ss:Data></Cell>
    <Cell ss:StyleID="s196"><Data ss:Type="String">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s197"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s182"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s182"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s183"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s185"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s188"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s189"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s198"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s199"><Data ss:Type="Number">0</Data></Cell>
   </Row>'
         WHERE x_id1 = 10;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0" ss:Height="48.45">
    <Cell ss:StyleID="s200"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
    <Cell ss:StyleID="s201"><Data ss:Type="String">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s202"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s203"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s204"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s205"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s206"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s207"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s206"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s208"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s209"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s206"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s209"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s210"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s208"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s209"><Data ss:Type="Number"></Data></Cell>
   </Row>'
         WHERE x_id1 = 11;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0" ss:Height="31.799999999999997">
    <Cell ss:StyleID="s211"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
    <Cell ss:StyleID="s171"><Data ss:Type="String">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s212"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s213"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s173"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s174"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s175"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s176"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s175"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s177"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s178"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s175"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s178"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s179"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s177"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s178"><Data ss:Type="Number"></Data></Cell>
   </Row>'
         WHERE x_id1 = 12;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0">
    <Cell ss:StyleID="s180"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
    <Cell ss:StyleID="s171"><Data ss:Type="String">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s192"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s214"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s214"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s183"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s185"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s188"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s189"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number"></Data></Cell>
   </Row>'
         WHERE x_id1 = 13;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0">
    <Cell ss:StyleID="s180"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
    <Cell ss:StyleID="s171"><Data ss:Type="String">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s192"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s214"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s214"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s183"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s185"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s188"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s189"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number"></Data></Cell>
   </Row>'
         WHERE x_id1 = 14;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0">
    <Cell ss:StyleID="s180"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
    <Cell ss:StyleID="s171"><Data ss:Type="String">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s192"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s214"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s214"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s183"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s185"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s188"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s189"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number"></Data></Cell>
   </Row>'
         WHERE x_id1 = 15;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0" ss:Height="21.45">
    <Cell ss:StyleID="s211"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
    <Cell ss:StyleID="s171"><Data ss:Type="String">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s212"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s213"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s173"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s174"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s175"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s176"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s175"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s177"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s178"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s175"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s178"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s179"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s177"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s178"><Data ss:Type="Number"></Data></Cell>
   </Row>'
         WHERE x_id1 = 16;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0" ss:Height="20.549999999999997">
    <Cell ss:StyleID="s215"><ss:Data ss:Type="String"
      xmlns="http://www.w3.org/TR/REC-html40">'
                   || x_string1
                   || '</ss:Data></Cell>
    <Cell ss:StyleID="s171"><Data ss:Type="String">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s192"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s214"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s182"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s183"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s185"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s188"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s189"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number"></Data></Cell>
   </Row>'
         WHERE x_id1 = 17;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0">
    <Cell ss:StyleID="s216"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
    <Cell ss:StyleID="s171"><Data ss:Type="String">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s192"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s214"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s182"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s183"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s185"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s188"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s189"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number"></Data></Cell>
   </Row>'
         WHERE x_id1 = 18;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0" ss:Height="21.45">
    <Cell ss:StyleID="s217"><ss:Data ss:Type="String"
      xmlns="http://www.w3.org/TR/REC-html40">'
                   || x_string1
                   || '</ss:Data></Cell>
    <Cell ss:StyleID="s171"><Data ss:Type="String">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s212"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s213"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s173"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s174"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s175"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s176"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s175"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s177"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s178"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s175"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s178"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s179"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s177"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s178"><Data ss:Type="Number"></Data></Cell>
   </Row>'
         WHERE x_id1 = 19;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0" ss:Height="20.549999999999997">
    <Cell ss:StyleID="s218"><ss:Data ss:Type="String"
      xmlns="http://www.w3.org/TR/REC-html40">'
                   || x_string1
                   || '</ss:Data></Cell>
    <Cell ss:StyleID="s171"><Data ss:Type="String">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s192"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s214"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s182"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s183"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s185"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s188"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s189"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number"></Data></Cell>
   </Row>'
         WHERE x_id1 = 20;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0">
    <Cell ss:StyleID="s219"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
    <Cell ss:StyleID="s171"><Data ss:Type="String">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s192"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s214"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s182"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s183"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s185"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s188"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s189"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number"></Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number"></Data></Cell>
   </Row>'
         WHERE x_id1 = 21;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0" ss:Height="31.200000000000003">
    <Cell ss:StyleID="s217"><ss:Data ss:Type="String"
      xmlns="http://www.w3.org/TR/REC-html40">'
                   || x_string1
                   || '</ss:Data></Cell>
    <Cell ss:StyleID="s171"><Data ss:Type="String">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s212"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s213"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s173"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s174"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s175"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s176"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s175"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s177"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s178"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s175"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s178"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s179"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s177"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s178"><Data ss:Type="Number">0</Data></Cell>
   </Row>'
         WHERE x_id1 = 22;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0" ss:Height="20.549999999999997">
    <Cell ss:StyleID="s218"><ss:Data ss:Type="String"
      xmlns="http://www.w3.org/TR/REC-html40">'
                   || x_string1
                   || '</ss:Data></Cell>
    <Cell ss:StyleID="s171"><Data ss:Type="String">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s192"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s214"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s182"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s183"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s185"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s188"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s189"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">0</Data></Cell>
   </Row>'
         WHERE x_id1 = 23;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0">
    <Cell ss:StyleID="s219"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
    <Cell ss:StyleID="s171"><Data ss:Type="String">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s192"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s214"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s182"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s183"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s185"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s188"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s189"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">0</Data></Cell>
   </Row>'
         WHERE x_id1 = 24;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0" ss:Height="28.8">
    <Cell ss:StyleID="s217"><ss:Data ss:Type="String"
      xmlns="http://www.w3.org/TR/REC-html40">'
                   || x_string1
                   || '</ss:Data></Cell>
    <Cell ss:StyleID="s171"><Data ss:Type="String">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s212"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s213"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s173"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s174"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s175"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s176"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s175"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s177"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s178"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s175"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s178"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s179"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s177"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s178"><Data ss:Type="Number">0</Data></Cell>
   </Row>'
         WHERE x_id1 = 25;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0" ss:Height="20.549999999999997">
    <Cell ss:StyleID="s218"><ss:Data ss:Type="String"
      xmlns="http://www.w3.org/TR/REC-html40">'
                   || x_string1
                   || '</ss:Data></Cell>
    <Cell ss:StyleID="s171"><Data ss:Type="String">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s220"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s221"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s222"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s223"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s224"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s225"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s224"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s226"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s227"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s224"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s227"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s228"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s226"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s227"><Data ss:Type="Number">0</Data></Cell>
   </Row>'
         WHERE x_id1 = 26;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0">
    <Cell ss:StyleID="s219"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
    <Cell ss:StyleID="s171"><Data ss:Type="String">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s220"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s221"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s222"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s223"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s224"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s225"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s224"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s226"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s227"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s224"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s227"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s228"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s226"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s227"><Data ss:Type="Number">0</Data></Cell>
   </Row>'
         WHERE x_id1 = 27;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0" ss:Height="19.2">
    <Cell ss:StyleID="s229"><ss:Data ss:Type="String"
      xmlns="http://www.w3.org/TR/REC-html40">'
                   || x_string1
                   || '</ss:Data></Cell>
    <Cell ss:StyleID="s230"><Data ss:Type="Number">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s231"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s213"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s173"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s232"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s175"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s178"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s179"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s177"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s176"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s175"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s178"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s179"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s177"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s178"><Data ss:Type="Number">0</Data></Cell>
   </Row>'
         WHERE x_id1 = 28;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0" ss:Height="20.549999999999997">
    <Cell ss:StyleID="s233"><ss:Data ss:Type="String"
      xmlns="http://www.w3.org/TR/REC-html40">'
                   || x_string1
                   || '</ss:Data></Cell>
    <Cell ss:StyleID="s230"><Data ss:Type="Number">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s234"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s221"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s222"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s235"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s224"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s227"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s228"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s226"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s225"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s224"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s227"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s228"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s226"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s227"><Data ss:Type="Number">0</Data></Cell>
   </Row>'
         WHERE x_id1 = 29;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0" ss:Height="15">
    <Cell ss:StyleID="s236"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
    <Cell ss:StyleID="s237"><Data ss:Type="Number">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s238"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s239"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s240"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s241"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s242"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s243"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s244"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s245"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s246"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s242"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s243"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s244"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s245"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s243"><Data ss:Type="Number">0</Data></Cell>
   </Row>'
         WHERE x_id1 = 30;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0" ss:Height="15">
    <Cell ss:StyleID="s247"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
    <Cell ss:StyleID="s248"><Data ss:Type="Number">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s249"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s203"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s204"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s250"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s206"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s209"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s210"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s208"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s207"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s206"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s209"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s210"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s208"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s209"><Data ss:Type="Number">0</Data></Cell>
   </Row>'
         WHERE x_id1 = 31;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0" ss:Height="31.799999999999997">
    <Cell ss:StyleID="s170"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
    <Cell ss:StyleID="s230"><Data ss:Type="Number">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s231"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s213"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s173"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s232"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s175"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s178"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s179"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s177"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s176"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s175"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s178"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s179"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s177"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s178"><Data ss:Type="Number">0</Data></Cell>
   </Row>'
         WHERE x_id1 = 32;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0" ss:Height="20.549999999999997">
    <Cell ss:StyleID="s251"><ss:Data ss:Type="String"
      xmlns="http://www.w3.org/TR/REC-html40">'
                   || x_string1
                   || '</ss:Data></Cell>
    <Cell ss:StyleID="s230"><Data ss:Type="Number">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s252"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s214"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s182"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s253"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s254"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s255"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s256"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s188"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s189"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">0</Data></Cell>
   </Row>'
         WHERE x_id1 = 33;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0">
    <Cell ss:StyleID="s257"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
    <Cell ss:StyleID="s230"><Data ss:Type="Number">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s252"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s214"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s182"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s253"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s254"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s255"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s256"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s188"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s189"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">0</Data></Cell>
   </Row>'
         WHERE x_id1 = 34;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0">
    <Cell ss:StyleID="s257"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
    <Cell ss:StyleID="s230"><Data ss:Type="Number">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s252"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s214"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s182"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s253"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s184"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s254"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s255"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s256"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s188"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s189"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s186"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s187"><Data ss:Type="Number">0</Data></Cell>
   </Row>'
         WHERE x_id1 = 35;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                      '
   <Row ss:AutoFitHeight="0" ss:Height="15">
    <Cell ss:StyleID="s170"><Data ss:Type="String">'
                   || x_string1
                   || '</Data></Cell>
    <Cell ss:StyleID="s258"><Data ss:Type="Number">'
                   || x_id1
                   || '</Data></Cell>
    <Cell ss:StyleID="s259"><Data ss:Type="Number">'
                   || x_id2
                   || '</Data></Cell>
    <Cell ss:StyleID="s260"><Data ss:Type="Number">'
                   || x_id3
                   || '</Data></Cell>
    <Cell ss:StyleID="s261"><Data ss:Type="Number">'
                   || x_id4
                   || '</Data></Cell>
    <Cell ss:StyleID="s262"><Data ss:Type="Number">'
                   || x_id5
                   || '</Data></Cell>
    <Cell ss:StyleID="s263"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum1, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s264"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum2, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s265"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum3, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s266"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum4, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s267"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum5, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s268"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum6, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s269"><Data ss:Type="Number">'
                   || TO_CHAR (x_sum7, 'FM999999999990.90')
                   || '</Data></Cell>
    <Cell ss:StyleID="s270"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s266"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s269"><Data ss:Type="Number">0</Data></Cell>
   </Row>'
         WHERE x_id1 = 36;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                   '
   <Row ss:AutoFitHeight="0" ss:Height="34.199999999999996">
    <Cell ss:StyleID="s271"><Data ss:Type="String">4.Отримують державну соціальну допомогу та пенсію у зв’язку з втратою годувальника одночасно  (рядки 38+42)</Data></Cell>
    <Cell ss:StyleID="s272"><Data ss:Type="Number">37</Data></Cell>
    <Cell ss:StyleID="s273"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s274"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s274"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s275"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s276"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s277"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s278"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s279"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s280"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s276"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s277"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s278"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s279"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s277"><Data ss:Type="String">Х</Data></Cell>
   </Row>'
         WHERE x_id1 = 37;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                   '
   <Row ss:AutoFitHeight="0" ss:Height="31.799999999999997">
    <Cell ss:StyleID="s170"><Data ss:Type="String">у тому числі:&#10;4.1  Особа з інвалідністю з дитинства   (рядки 39+40+41)</Data></Cell>
    <Cell ss:StyleID="s230"><Data ss:Type="Number">38</Data></Cell>
    <Cell ss:StyleID="s231"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s281"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s281"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s282"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s283"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s284"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s285"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s286"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s287"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s283"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s284"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s285"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s286"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s284"><Data ss:Type="String">Х</Data></Cell>
   </Row>'
         WHERE x_id1 = 38;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                   '
   <Row ss:AutoFitHeight="0" ss:Height="20.549999999999997">
    <Cell ss:StyleID="s251"><ss:Data ss:Type="String"
      xmlns="http://www.w3.org/TR/REC-html40"><B>з них</B><Font>:&#10;І групи</Font></ss:Data></Cell>
    <Cell ss:StyleID="s230"><Data ss:Type="Number">39</Data></Cell>
    <Cell ss:StyleID="s252"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s288"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s288"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s289"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s290"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s291"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s292"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s293"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s294"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s290"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s291"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s292"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s293"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s291"><Data ss:Type="String">Х</Data></Cell>
   </Row>'
         WHERE x_id1 = 39;

        UPDATE tmp_univ_rpt_data
           SET x_string2 = '
   <Row ss:AutoFitHeight="0">
    <Cell ss:StyleID="s257"><Data ss:Type="String">ІІ групи</Data></Cell>
    <Cell ss:StyleID="s230"><Data ss:Type="Number">40</Data></Cell>
    <Cell ss:StyleID="s252"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s288"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s288"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s289"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s290"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s291"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s292"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s293"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s294"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s290"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s291"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s292"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s293"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s291"><Data ss:Type="String">Х</Data></Cell>
   </Row>'
         WHERE x_id1 = 40;

        UPDATE tmp_univ_rpt_data
           SET x_string2 = '
   <Row ss:AutoFitHeight="0">
    <Cell ss:StyleID="s257"><Data ss:Type="String">ІІІ групи</Data></Cell>
    <Cell ss:StyleID="s230"><Data ss:Type="Number">41</Data></Cell>
    <Cell ss:StyleID="s252"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s288"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s288"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s289"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s290"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s291"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s292"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s293"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s294"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s290"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s291"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s292"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s293"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s291"><Data ss:Type="String">Х</Data></Cell>
   </Row>'
         WHERE x_id1 = 41;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                   '
   <Row ss:AutoFitHeight="0" ss:Height="15">
    <Cell ss:StyleID="s170"><Data ss:Type="String">4.2 Діти з інвалідністю віком до 18 років</Data></Cell>
    <Cell ss:StyleID="s258"><Data ss:Type="Number">42</Data></Cell>
    <Cell ss:StyleID="s259"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s295"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s295"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s296"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s297"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s298"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s299"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s300"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s301"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s297"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s298"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s299"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s300"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s298"><Data ss:Type="String">Х</Data></Cell>
   </Row>'
         WHERE x_id1 = 42;

        UPDATE tmp_univ_rpt_data
           SET x_string2 =
                   '
   <Row ss:AutoFitHeight="0" ss:Height="15">
    <Cell ss:StyleID="s271"><Data ss:Type="String">5. Інші виплати</Data></Cell>
    <Cell ss:StyleID="s302"><Data ss:Type="Number">43</Data></Cell>
    <Cell ss:StyleID="s303"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s304"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s304"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s305"><Data ss:Type="String">Х</Data></Cell>
    <Cell ss:StyleID="s306"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s307"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s308"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s309"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s310"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s311"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s312"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s313"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s309"><Data ss:Type="Number">0</Data></Cell>
    <Cell ss:StyleID="s312"><Data ss:Type="Number">0</Data></Cell>
   </Row>'
         WHERE x_id1 = 43;
    END SET_DSDI_R1;

    -- IC #91166 Звіт про надання державної соціальної допомоги інвалідам з дитинства та дітям-інвалідам
    FUNCTION DSDI_R1 (p_start_dt   IN DATE,
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
        tools.WriteMsg ('DNET$PAYMENT_REPORTS.' || $$PLSQL_UNIT);
        l_jbr_id := RDM$RTFL.InitReport (p_rt_id => p_rt_id);

        l_file_name :=
               'DSDI_R1_'
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
            'p_mname',
            getMonthName (TO_NUMBER (TO_CHAR (l_start_dt, 'mm'))));
        RDM$RTFL.AddParam (
            l_jbr_id,
            'p_ym',
               getMonthName (TO_NUMBER (TO_CHAR (l_start_dt, 'mm')))
            || ' '
            || TO_CHAR (l_start_dt, 'yyyy'));

        RDM$RTFL.AddScript (
            l_jbr_id,
            'constants',
               'begin uss_esr.dnet$payment_long_rep.SET_DSDI_R1(to_date('''
            || TO_CHAR (l_start_dt, 'dd.mm.yyyy')
            || ''',''dd.mm.yyyy''), '
            || p_org_id
            || ', '
            || l_jbr_id
            || '); end;');

        l_sql := '
    select  x_string2
        from uss_esr.tmp_univ_rpt_data order by x_id1';

        RDM$RTFL.AddDataSet (l_jbr_id, 'ds', l_sql);

        RDM$RTFL.PutReportToWorkingQueue (p_jbr_id => l_jbr_id);
        RETURN l_jbr_id;
    END DSDI_R1;

    -- #104295 Перелік отримувачів допомог та членів родини зі складу сім’ї. ЄІССС до ДП ІОЦ
    PROCEDURE SET_PAY_TP_DECISION_R1 (p_dt        IN DATE,
                                      p_org_ids   IN VARCHAR2,
                                      p_npt_ids   IN VARCHAR2,
                                      p_jbr_id    IN DECIMAL)
    IS
        l_count   NUMBER;
    BEGIN
        INSERT INTO tmp_work_ids1 (x_id)
                SELECT REGEXP_SUBSTR (p_org_ids,
                                      '[^,]+',
                                      1,
                                      LEVEL)
                  FROM DUAL
            CONNECT BY REGEXP_SUBSTR (p_org_ids,
                                      '[^,]+',
                                      1,
                                      LEVEL)
                           IS NOT NULL;

        l_count := SQL%ROWCOUNT;

        IF l_count = 0
        THEN
            raise_application_error (-20000,
                                     'Поле ''ОСЗН'' повинно бути вказаним.');
        END IF;

        INSERT INTO tmp_work_ids2 (x_id)
                SELECT REGEXP_SUBSTR (p_npt_ids,
                                      '[^,]+',
                                      1,
                                      LEVEL)
                  FROM DUAL
            CONNECT BY REGEXP_SUBSTR (p_npt_ids,
                                      '[^,]+',
                                      1,
                                      LEVEL)
                           IS NOT NULL;

        l_count := SQL%ROWCOUNT;

        IF l_count = 0
        THEN
            raise_application_error (
                -20000,
                'Поле ''Види виплат'' повинно бути вказаним.');
        END IF;

        DELETE FROM uss_esr.tmp_rpt_pay_tp_decision_data
              WHERE 1 = 1;

        --адреса зі звернення пріорітетніша
        INSERT INTO uss_esr.tmp_rpt_pay_tp_decision_data (x_id_fam,
                                                          x_kfn,
                                                          x_surname,
                                                          x_name,
                                                          x_patronymic,
                                                          x_bdate,
                                                          x_n_id,
                                                          x_passport,
                                                          x_phone,
                                                          x_region,
                                                          x_district,
                                                          x_pindex,
                                                          x_address,
                                                          x_iban,
                                                          x_dis)
            WITH
                org
                AS
                    (    SELECT org_id AS i_org, org_org AS i_org_org
                           FROM ikis_sys.v_opfu i1
                          WHERE     org_to = 32
                                AND org_org IN (SELECT x_id FROM tmp_work_ids1)
                     CONNECT BY PRIOR org_id = org_org
                     START WITH org_id = 50000),
                src
                AS
                    (SELECT '1' || pd.com_org || LPAD ('' || pd_id, 13, '0')
                                x_id_fam,
                            npt_code
                                AS x_kfn,
                            pd_id,
                            pc.pc_sc
                                AS x_sc_app,
                            pd.pd_ap
                                AS x_ap,
                            (SELECT b.scb_dt
                               FROM uss_person.v_sc_birth b
                              WHERE b.scb_id = ch.scc_scb)
                                AS x_birth_app,
                            pdf.pdf_sc
                                AS x_sc_child,
                            pdf.pdf_birth_dt
                                AS x_birth_child,
                            (SELECT DENSE_RANK (pdf.pdf_id)
                                        WITHIN GROUP (ORDER BY t.pdf_id)
                               FROM uss_esr.pd_family t
                              WHERE pdf_pd = pd.pd_id)
                                AS x_order_child,
                            phone_clear (
                                (SELECT apda_val_string
                                   FROM uss_esr.ap_document_attr a
                                  WHERE     apda_apd = apd_600_max.apd_id
                                        AND apda_nda = 605
                                        AND a.history_status = 'A'))
                                AS x_phone,
                            (SELECT MAX (l1_kaot_full_name)
                               FROM uss_ndi.mv_ndi_katottg,
                                    uss_ndi.v_ndi_org2kaot
                              WHERE     kaot_id = nok_kaot
                                    AND history_status = 'A'
                                    AND nok_org = pd.com_org)
                                AS x_region,
                            (SELECT MAX (l2_kaot_full_name)
                               FROM uss_ndi.mv_ndi_katottg,
                                    uss_ndi.v_ndi_org2kaot
                              WHERE     kaot_id = nok_kaot
                                    AND history_status = 'A'
                                    AND nok_org = pd.com_org)
                                AS x_district,
                            COALESCE (
                                (SELECT apda_val_string
                                   FROM uss_esr.ap_document_attr
                                  WHERE     apda_apd = apd_600_max.apd_id
                                        AND apda_nda = 599),
                                a.sca_postcode)
                                AS x_pindex,
                            COALESCE (
                                LTRIM (
                                       NVL (
                                           (SELECT apda_val_string
                                              FROM uss_esr.ap_document_attr
                                             WHERE     apda_apd =
                                                       apd_600_max.apd_id
                                                   AND apda_nda = 604),
                                           (SELECT MAX (
                                                       COALESCE (
                                                           l4_kaot_full_name,
                                                           l3_kaot_full_name,
                                                           l2_kaot_full_name))
                                              FROM uss_ndi.mv_ndi_katottg,
                                                   uss_ndi.v_ndi_post_office
                                             WHERE     kaot_id = npo_kaot
                                                   AND npo_index =
                                                       (SELECT apda_val_string
                                                          FROM uss_esr.ap_document_attr
                                                         WHERE     apda_apd =
                                                                   apd_600_max.apd_id
                                                               AND apda_nda =
                                                                   599)))
                                    || '; '
                                    || NVL (
                                           (SELECT apda_val_string
                                              FROM uss_esr.ap_document_attr
                                             WHERE     apda_apd =
                                                       apd_600_max.apd_id
                                                   AND apda_nda = 597),
                                           (SELECT apda_val_string
                                              FROM uss_esr.ap_document_attr
                                             WHERE     apda_apd =
                                                       apd_600_max.apd_id
                                                   AND apda_nda = 788))
                                    || ', '
                                    || (SELECT apda_val_string
                                          FROM uss_esr.ap_document_attr
                                         WHERE     apda_apd =
                                                   apd_600_max.apd_id
                                               AND apda_nda = 596),
                                    '; '),
                                   CASE
                                       WHEN a.sca_kaot IS NOT NULL
                                       THEN
                                           (SELECT MAX (
                                                       COALESCE (
                                                           t.l4_kaot_full_name,
                                                           t.l3_kaot_full_name,
                                                           t.l2_kaot_full_name))
                                              FROM uss_ndi.mv_ndi_katottg t
                                             WHERE kaot_id = a.sca_kaot)
                                       ELSE
                                           a.sca_city
                                   END
                                || '; '
                                || a.sca_street
                                || NVL2 (a.sca_building,
                                         ', ' || a.sca_building,
                                         '')
                                || NVL2 (a.sca_block,
                                         '; корп.' || a.sca_block,
                                         '')
                                || NVL2 (a.sca_apartment,
                                         '; кв.' || a.sca_apartment,
                                         ''))
                                AS x_address,
                            (SELECT pdm_account
                               FROM uss_esr.pd_pay_method pdm
                              WHERE     pdm_pd = pd_id
                                    AND pdm.history_status = 'A'
                                    AND pdm_is_actual = 'T'
                                    AND pdm_pay_tp = 'BANK'
                                    AND LENGTH (pdm_account) = 29 -- для Банк: якщо в параметрах виплати довжина рахунку меньше 29 символів, то не вивантажувати (їм буде зміна виплати на пошту)
                                                                 )
                                AS x_iban
                       FROM org,
                            uss_esr.pc_decision      pd,
                            uss_esr.v_personalcase   pc,
                            uss_esr.pd_family        pdf,
                            uss_person.v_sc_change   ch,
                            uss_person.v_sc_address  a,
                            uss_ndi.v_ndi_npt_config,
                            uss_ndi.v_ndi_payment_type,
                            (  SELECT MAX (apd_id) apd_id, apd_ap
                                 FROM uss_esr.ap_document
                                WHERE history_status = 'A' AND apd_ndt = 600
                             GROUP BY apd_ap) apd_600_max
                      WHERE     pd.com_org = i_org
                            AND pd.pd_st IN ('S', 'PS')
                            AND nptc_nst = pd.pd_nst
                            AND nptc_npt = npt_id
                            AND npt_id IN (SELECT x_id FROM tmp_work_ids2)
                            AND pd.pd_nst = nptc_nst
                            AND EXISTS
                                    (SELECT 1
                                       FROM uss_esr.pd_accrual_period pdap
                                      WHERE     pdap.pdap_pd = pd.pd_id
                                            AND pdap.history_status = 'A'
                                            AND p_dt BETWEEN pdap.pdap_start_dt
                                                         AND pdap.pdap_stop_dt)
                            AND NOT EXISTS
                                    (SELECT 1
                                       FROM uss_ndi.v_ndi_reason_not_pay  r
                                            LEFT JOIN uss_esr.pc_block pcb
                                                ON pd.pd_pcb = pcb.pcb_id
                                      WHERE     r.rnp_id = pcb.pcb_rnp
                                            AND r.rnp_pnp_tp = 'CPX'
                                            AND r.history_status = 'A')
                            AND EXISTS
                                    (SELECT 1
                                       FROM uss_esr.pd_payment pdp
                                      WHERE     pdp_pd = pd_id
                                            AND pdp.pdp_npt = npt_id
                                            AND pdp.history_status = 'A'
                                            AND p_dt BETWEEN pdp.pdp_start_dt
                                                         AND pdp.pdp_stop_dt)
                            AND pc.pc_id = pd.pd_pc
                            AND pdf.pdf_pd = pd_id
                            AND ch.scc_id = pd.pd_scc
                            AND a.sca_id(+) = ch.scc_sca
                            AND apd_600_max.apd_ap(+) = pd.pd_ap),
                src3
                AS              --обєднання заявника та учасника в один список
                    (SELECT DISTINCT x_id_fam,
                                     x_kfn,
                                     x_ap,
                                     '00'            x_order,
                                     x_sc_app        x_sc,
                                     x_birth_app     x_birth,
                                     x_phone,
                                     x_region,
                                     x_district,
                                     x_pindex,
                                     x_address,
                                     x_iban
                       FROM src
                     UNION ALL
                     SELECT x_id_fam,
                            x_kfn,
                            x_ap,
                            LPAD (x_order_child, 2, '0')     x_order,
                            x_sc_child                       x_sc,
                            x_birth_child                    x_birth,
                            NULL,
                            x_region,
                            x_district,
                            NULL,
                            NULL,
                            NULL
                       FROM src t
                      WHERE NOT EXISTS
                                (SELECT 1
                                   FROM src t2
                                  WHERE     t.x_id_fam = t2.x_id_fam
                                        AND t.x_kfn = t2.x_kfn
                                        AND t2.x_sc_app = t.x_sc_child))
            SELECT x_id_fam || x_order
                       "ID_FAM",
                   x_kfn
                       "KFN",
                   sci.sci_ln
                       "SURNAME",
                   sci.sci_fn
                       "NAME",
                   sci.sci_mn
                       "PATRONYMIC",
                   x_birth
                       "BDATE",
                   (SELECT REPLACE (
                               REPLACE (NVL (MAX (scd_number), '0000000000'),
                                        'НЕМАЄ',
                                        '0000000000'),
                               'НІ',
                               '0000000000')
                      FROM uss_person.v_sc_document
                     WHERE scd_sc = x_sc AND scd_ndt = 5 AND scd_st = '1')
                       "N_ID",
                   (SELECT MAX (
                                  scd_seria
                               || DECODE (scd_ndt,
                                          6, LPAD (scd_number, 6, '0'),
                                          7, LPAD (scd_number, 9, '0'),
                                          scd_number))
                      FROM uss_person.v_sc_document
                     WHERE     scd_sc = x_sc
                           AND scd_ndt IN (6,
                                           7,
                                           37,
                                           673)
                           AND scd_st = '1')
                       "PASSPORT",
                   x_phone
                       "PHONЕ",
                   x_region
                       "REGION",
                   x_district
                       "DISTRICT",
                   x_pindex
                       "PINDEX",
                   x_address
                       "ADDRESS",
                   x_iban
                       "IBAN",
                   (SELECT DECODE (SUM (c), 0, 0, 1)
                      FROM (SELECT COUNT (*)     c
                              FROM uss_esr.ap_person    pp,
                                   uss_esr.ap_document  ad
                             WHERE     pp.app_sc = x_sc
                                   AND pp.app_ap = x_ap
                                   AND pp.app_ap = ad.apd_ap
                                   AND pp.app_id = ad.apd_app
                                   AND ad.apd_ndt IN (200, 201)
                            UNION ALL
                            SELECT DECODE (COUNT (*), 0, 0, 1)
                              FROM uss_person.v_sc_document d
                             WHERE     d.scd_st = '1'
                                   AND d.scd_ndt IN (200, 201)
                                   AND d.scd_sc = x_sc
                            UNION ALL
                            SELECT DECODE (COUNT (*), 0, 0, 1)
                              FROM uss_person.v_sc_disability
                             WHERE scy_sc = x_sc AND history_status = 'A'))
                       "DIS"
              FROM src3,
                   uss_person.v_socialcard   sc,
                   uss_person.v_sc_change    scc,
                   uss_person.v_sc_identity  sci
             WHERE     sc.sc_id = x_sc
                   AND scc.scc_id = sc.sc_scc
                   AND scc.scc_sci = sci.sci_id;
    END;

    -- #104295 Перелік отримувачів допомог та членів родини зі складу сім’ї. ЄІССС до ДП ІОЦ
    FUNCTION PAY_TP_DECISION_R1 (p_dt          IN DATE,
                                 p_org_ids     IN VARCHAR2,
                                 p_npt_ids     IN VARCHAR2,
                                 p_name_mask   IN VARCHAR2,
                                 p_rt_id       IN rpt_templates.rt_id%TYPE)
        RETURN DECIMAL
    IS
        l_jbr_id      NUMBER;
        l_file_name   VARCHAR2 (128);
        l_sql         VARCHAR2 (10000);
    BEGIN
        tools.WriteMsg ('DNET$PAYMENT_REPORTS.' || $$PLSQL_UNIT);
        l_jbr_id := RDM$RTFL.InitReport (p_rt_id => p_rt_id);

        l_file_name :=
               'EOC2IOC_'
            || p_name_mask
            || '_'
            || TO_CHAR (p_dt, 'YYYYMMDD')
            || '.csv';
        RDM$RTFL.SetFileName (p_jbr_id => l_jbr_id, p_file_name => l_file_name);

        RDM$RTFL.AddParam (l_jbr_id, 'p_dt', TO_CHAR (p_dt, 'ddmmyyyy'));
        RDM$RTFL.AddParam (l_jbr_id, 'p_org_ids', p_org_ids);
        RDM$RTFL.AddParam (l_jbr_id, 'p_npt_ids', p_npt_ids);
        RDM$RTFL.AddParam (l_jbr_id, 'p_name_mask', p_name_mask);

        RDM$RTFL.AddScript (
            l_jbr_id,
            'constants',
               'begin uss_esr.dnet$payment_long_rep.SET_PAY_TP_DECISION_R1(
      to_date('''
            || TO_CHAR (p_dt, 'dd.mm.yyyy')
            || ''', ''dd.mm.yyyy''),
      '''
            || REPLACE (p_org_ids, '''')
            || ''',
      '''
            || REPLACE (p_npt_ids, '''')
            || ''',
      '
            || l_jbr_id
            || '); end;');

        l_sql :=
            q'{SELECT '"' || REPLACE(x_id_fam, '"', '""') || '"' AS x_id_fam,
                       '"' || REPLACE(x_kfn, '"', '""') || '"' AS x_kfn,
                       '"' || REPLACE(x_surname, '"', '""') || '"' AS x_surname,
                       '"' || REPLACE(x_name, '"', '""') || '"' AS x_name,
                       '"' || REPLACE(x_patronymic, '"', '""') || '"' AS x_patronymic,
                       '"' || to_char(x_bdate, 'dd.mm.yyyy') || '"' AS x_bdate,
                       '"' || REPLACE(x_n_id, '"', '""') || '"' AS x_n_id,
                       '"' || REPLACE(x_passport, '"', '""') || '"' AS x_passport,
                       '"' || REPLACE(x_phone, '"', '""') || '"' AS x_phone,
                       '"' || REPLACE(x_region, '"', '""') || '"' AS x_region,
                       '"' || REPLACE(x_district, '"', '""') || '"' AS x_district,
                       '"' || REPLACE(x_pindex, '"', '""') || '"' AS x_pindex,
                       '"' || REPLACE(x_address, '"', '""') || '"' AS x_address,
                       '"' || REPLACE(x_iban, '"', '""') || '"' AS x_iban,
                       '"' || REPLACE(x_dis, '"', '""') || '"' AS x_dis
                FROM uss_esr.tmp_rpt_pay_tp_decision_data
               ORDER BY x_id_fam}';
        RDM$RTFL.AddDataSet (l_jbr_id, 'ds', l_sql);

        RDM$RTFL.PutReportToWorkingQueue (p_jbr_id => l_jbr_id);
        RETURN l_jbr_id;
    END PAY_TP_DECISION_R1;

    -- #101217 Звіт по особам з інвалідністю
    PROCEDURE SET_DISABILITY_INFO_R1 (p_start_dt    IN DATE,
                                      p_org_id      IN NUMBER,
                                      p_inv_gr      IN VARCHAR2,
                                      p_inv_chld    IN VARCHAR2,
                                      p_inv_pers    IN VARCHAR2,
                                      p_kaot_code   IN VARCHAR2,
                                      p_jbr_id      IN DECIMAL)
    IS
        l_user_org   NUMBER;
    BEGIN
        IF p_org_id = 0
        THEN
            l_user_org := tools.getcurrorg;
        ELSE
            l_user_org := p_org_id;
        END IF;

        l_user_org :=
            CASE WHEN l_user_org = 50001 THEN 50000 ELSE l_user_org END;

        DELETE FROM uss_esr.tmp_univ_rpt_data
              WHERE 1 = 1;

        DELETE FROM uss_esr.tmp_work_set4
              WHERE 1 = 1;

        INSERT ALL
          INTO uss_esr.tmp_univ_rpt_data (x_id1,
                                          x_id2,
                                          x_string1,
                                          x_string2,
                                          x_string3,
                                          x_dt1,
                                          x_id3,
                                          x_string4,
                                          x_dt2,
                                          x_string5,
                                          x_string6,
                                          x_id4,
                                          x_sum1,
                                          x_sum2,
                                          x_sum3)
        VALUES (pdf_sc,
                "Код ОСЗН",
                "Область",
                "Район",
                "ПІБ",
                "Дата народження",
                "Стать",
                "Причина інвалідності",
                "Дата закінчення дії МСЕК",
                "КАТОТТГ місця проживання",
                "Адреса проживання",
                "Наявність надбавки по догляду",
                "Розмір призначеної допомоги",
                "Розмір призначеної доплати на догляд",
                "Розмір нарахованої допомоги")
          INTO uss_esr.tmp_rpt_pay_tp_decision_data (x_dis,
                                                     x_surname,
                                                     x_name)
        VALUES (pdf_sc, "Група інвалідності", "Категорія інвалідності")
            WITH
                org
                AS
                    (    SELECT org_id AS i_org, org_org AS i_org_org
                           FROM ikis_sys.v_opfu
                          WHERE org_to = 32
                     CONNECT BY PRIOR org_id = org_org
                     START WITH org_id = l_user_org)
            SELECT pdf.pdf_sc,
                   i_org
                       AS "Код ОСЗН",
                   NVL (
                       (SELECT MAX (l1_kaot_full_name)
                          FROM uss_ndi.v_ndi_org2kaot, uss_ndi.mv_ndi_katottg
                         WHERE     nok_kaot = kaot_id
                               AND history_status = 'A'
                               AND nok_org = i_org),
                       (SELECT MAX (l1_kaot_full_name)
                          FROM uss_ndi.v_ndi_org2kaot, uss_ndi.mv_ndi_katottg
                         WHERE     nok_kaot = kaot_id
                               AND history_status = 'A'
                               AND nok_org = i_org_org))
                       AS "Область",
                   NVL (
                       (SELECT MAX (l2_kaot_full_name)
                          FROM uss_ndi.v_ndi_org2kaot, uss_ndi.mv_ndi_katottg
                         WHERE     nok_kaot = kaot_id
                               AND history_status = 'A'
                               AND nok_org = i_org),
                       (SELECT MAX (l2_kaot_full_name)
                          FROM uss_ndi.v_ndi_org2kaot, uss_ndi.mv_ndi_katottg
                         WHERE     nok_kaot = kaot_id
                               AND history_status = 'A'
                               AND nok_org = i_org_org))
                       AS "Район",
                   uss_person.api$sc_tools.get_pib (p_sc_id => pdf.pdf_sc)
                       AS "ПІБ",
                   uss_person.api$sc_tools.get_birthdate (
                       p_sc_id   => pdf.pdf_sc)
                       AS "Дата народження",
                   DECODE (sci.sci_gender, 'F', 0, 1)
                       AS "Стать",
                   uss_person.api$sc_tools.get_disability_group (
                       p_sc_id   => pdf.pdf_sc)
                       AS "Група інвалідності",
                   (SELECT NVL (dic_name, inv_child)
                      FROM uss_ndi.v_ddn_inv_child,
                           (SELECT uss_person.api$sc_tools.get_inv_child (
                                       p_sc_id   => pdf.pdf_sc)   inv_child
                              FROM DUAL)
                     WHERE dic_value(+) = inv_child)
                       AS "Категорія інвалідності",
                   (SELECT MAX ( (SELECT dic_name
                                    FROM uss_ndi.v_ddn_inv_reason
                                   WHERE dic_value = da.apda_val_string))
                      FROM uss_esr.ap_person         pp,
                           uss_esr.ap_document       ad,
                           uss_esr.ap_document_attr  da
                     WHERE     pp.app_sc = pdf.pdf_sc
                           AND pp.app_ap = pd.pd_ap
                           AND pp.app_ap = ad.apd_ap
                           AND pp.app_id = ad.apd_app
                           AND pp.history_status = 'A'
                           AND ad.apd_ndt = 201
                           AND ad.apd_id = da.apda_apd
                           AND ad.history_status = 'A'
                           AND da.apda_nda = 353
                           AND da.history_status = 'A')
                       AS "Причина інвалідності",
                   (SELECT MAX (da.apda_val_dt)
                      FROM uss_esr.ap_person         pp,
                           uss_esr.ap_document       ad,
                           uss_esr.ap_document_attr  da
                     WHERE     pp.app_sc = pdf.pdf_sc
                           AND pp.app_ap = pd.pd_ap
                           AND pp.app_ap = ad.apd_ap
                           AND pp.app_id = ad.apd_app
                           AND pp.history_status = 'A'
                           AND ad.apd_ndt = 201
                           AND ad.apd_id = da.apda_apd
                           AND ad.history_status = 'A'
                           AND da.apda_nda = 347
                           AND da.history_status = 'A')
                       AS "Дата закінчення дії МСЕК",
                   (SELECT MAX (k.kaot_code)
                      FROM uss_person.v_sc_address d, uss_ndi.v_ndi_katottg k
                     WHERE     d.sca_sc = pdf.pdf_sc
                           AND d.sca_tp = 2
                           AND d.history_status = 'A'
                           AND d.sca_kaot = k.kaot_id)
                       AS "КАТОТТГ місця проживання",
                   uss_person.api$sc_tools.get_address (
                       p_sc_id    => pdf.pdf_sc,
                       p_sca_tp   => 2)
                       AS "Адреса проживання",
                   (CASE
                        WHEN EXISTS
                                 (SELECT 1
                                    FROM uss_esr.pd_payment  pdp,
                                         uss_esr.pd_detail   pdd
                                   WHERE     pdp.pdp_pd = pd.pd_id
                                         AND p_start_dt BETWEEN TRUNC (
                                                                    pdp.pdp_start_dt,
                                                                    'mm')
                                                            AND pdp.pdp_stop_dt
                                         AND pdp.history_status = 'A'
                                         AND pdd.pdd_pdp = pdp.pdp_id
                                         AND pdd.pdd_npt = 48
                                         AND pdd.pdd_value > 0
                                         AND p_start_dt BETWEEN TRUNC (
                                                                    pdd.pdd_start_dt,
                                                                    'mm')
                                                            AND pdd.pdd_stop_dt)
                        THEN
                            1
                        ELSE
                            0
                    END)
                       AS "Наявність надбавки по догляду",
                   (SELECT SUM (pdp.pdp_sum)
                      FROM uss_esr.pd_payment pdp
                     WHERE     pdp.pdp_pd = pd.pd_id
                           AND p_start_dt BETWEEN TRUNC (pdp.pdp_start_dt,
                                                         'mm')
                                              AND pdp.pdp_stop_dt
                           AND pdp.history_status = 'A')
                       AS "Розмір призначеної допомоги",
                   (SELECT NVL (SUM (pdd.pdd_value), 0)
                      FROM uss_esr.pd_payment pdp, uss_esr.pd_detail pdd
                     WHERE     pdp.pdp_pd = pd.pd_id
                           AND p_start_dt BETWEEN TRUNC (pdp.pdp_start_dt,
                                                         'mm')
                                              AND pdp.pdp_stop_dt
                           AND pdp.history_status = 'A'
                           AND pdd.pdd_pdp = pdp.pdp_id
                           AND pdd.pdd_npt = 48
                           AND p_start_dt BETWEEN TRUNC (pdd.pdd_start_dt,
                                                         'mm')
                                              AND pdd.pdd_stop_dt)
                       AS "Розмір призначеної доплати на догляд",
                   (SELECT SUM (ad.acd_sum)
                      FROM uss_esr.ac_detail ad
                     WHERE     ad.acd_pd = pd.pd_id
                           AND ad.history_status = 'A'
                           AND p_start_dt BETWEEN TRUNC (ad.acd_start_dt,
                                                         'mm')
                                              AND ad.acd_stop_dt)
                       AS "Розмір нарахованої допомоги"
              FROM org,
                   uss_esr.personalcase      pc,
                   uss_esr.pc_decision       pd,
                   uss_esr.pd_family         pdf,
                   uss_person.v_socialcard   sc,
                   uss_person.v_sc_change    scc,
                   uss_person.v_sc_identity  sci
             WHERE     i_org = pc.com_org
                   AND pd.pd_pc = pc.pc_id
                   AND pd.pd_nst = 248
                   AND pd.pd_st IN ('S', 'PS')
                   AND pdf.pdf_pd = pd.pd_id
                   AND sc.sc_id = pdf.pdf_sc
                   AND scc.scc_id = sc.sc_scc
                   AND scc.scc_sci = sci.sci_id
                   AND EXISTS
                           (SELECT 1
                              FROM uss_esr.pd_accrual_period pdap
                             WHERE     pdap.pdap_pd = pd.pd_id
                                   AND pdap.history_status = 'A'
                                   AND p_start_dt BETWEEN TRUNC (
                                                              pdap.pdap_start_dt,
                                                              'MM')
                                                      AND pdap.pdap_stop_dt)
                   AND (   p_inv_gr IS NULL
                        OR uss_person.api$sc_tools.get_disability_group (
                               p_sc_id   => pdf.pdf_sc) =
                           p_inv_gr)
                   AND (   p_inv_chld IS NULL
                        OR uss_person.api$sc_tools.get_inv_child (
                               p_sc_id   => pdf.pdf_sc) =
                           p_inv_chld)
                   AND (   p_inv_pers IS NULL
                        OR EXISTS
                               (SELECT 1
                                  FROM uss_esr.ap_person         pp,
                                       uss_esr.ap_document       ad,
                                       uss_esr.ap_document_attr  da
                                 WHERE     pp.app_sc = pdf.pdf_sc
                                       AND pp.app_ap = pd.pd_ap
                                       AND pp.app_ap = ad.apd_ap
                                       AND pp.app_id = ad.apd_app
                                       AND ad.apd_ndt = 201
                                       AND ad.apd_id = da.apda_apd
                                       AND ad.history_status = 'A'
                                       AND da.apda_nda = 353
                                       AND da.history_status = 'A'
                                       AND da.apda_val_string = p_inv_pers))
                   AND (   p_kaot_code IS NULL
                        OR EXISTS
                               (SELECT 1
                                  FROM uss_person.v_sc_address  d,
                                       uss_ndi.v_ndi_katottg    k
                                 WHERE     d.sca_sc = pdf.pdf_sc
                                       AND d.sca_tp = 2
                                       AND d.history_status = 'A'
                                       AND d.sca_kaot = k.kaot_id
                                       AND k.kaot_code = p_kaot_code));
    END;

    -- #101217 Звіт по особам з інвалідністю
    FUNCTION DISABILITY_INFO_R1 (p_start_dt    IN DATE,
                                 p_org_id      IN NUMBER,
                                 p_inv_gr      IN VARCHAR2,
                                 p_inv_chld    IN VARCHAR2,
                                 p_inv_pers    IN VARCHAR2,
                                 p_kaot_code   IN VARCHAR2,
                                 p_rt_id       IN rpt_templates.rt_id%TYPE)
        RETURN DECIMAL
    IS
        l_jbr_id      NUMBER;
        l_file_name   VARCHAR2 (128);
        l_sql         VARCHAR2 (10000);
        l_start_dt    DATE := TRUNC (p_start_dt, 'mm');
        l_start_str   VARCHAR2 (100)
            :=    'to_date('''
               || TO_CHAR (l_start_dt, 'MM.YYYY')
               || ''', ''MM.YYYY'')';
    BEGIN
        tools.writemsg ('DNET$PAYMENT_REPORTS.' || $$PLSQL_UNIT);
        l_jbr_id := RDM$RTFL.InitReport (p_rt_id => p_rt_id);

        l_file_name :=
               'DISABILITY_INFO_R1_'
            || TO_CHAR (l_start_dt, 'yyyy"_"mm')
            || '_'
            || p_org_id
            || '.csv';
        RDM$RTFL.SetFileName (p_jbr_id => l_jbr_id, p_file_name => l_file_name);

        RDM$RTFL.AddParam (l_jbr_id,
                           'p_start_dt',
                           TO_CHAR (p_start_dt, 'ddmmyyyy'));
        RDM$RTFL.AddParam (l_jbr_id, 'p_org_id', p_org_id);
        RDM$RTFL.AddParam (l_jbr_id, 'p_inv_gr', p_inv_gr);
        RDM$RTFL.AddParam (l_jbr_id, 'p_inv_chld', p_inv_chld);
        RDM$RTFL.AddParam (l_jbr_id, 'p_inv_pers', p_inv_pers);
        RDM$RTFL.AddParam (l_jbr_id, 'p_kaot_code', p_kaot_code);

        RDM$RTFL.AddScript (
            l_jbr_id,
            'constants',
               'begin uss_esr.dnet$payment_long_rep.SET_DISABILITY_INFO_R1(
      to_date('''
            || TO_CHAR (p_start_dt, 'dd.mm.yyyy')
            || ''', ''dd.mm.yyyy''),
      '
            || p_org_id
            || ',
      '''
            || REPLACE (p_inv_gr, '''')
            || ''',
      '''
            || REPLACE (p_inv_chld, '''')
            || ''',
      '''
            || REPLACE (p_inv_pers, '''')
            || ''',
      '''
            || REPLACE (p_kaot_code, '''')
            || ''',
      '
            || l_jbr_id
            || '); end;');

        l_sql :=
            'SELECT u.x_id2 as c1,                                          --Код ОСЗН
                     u.x_string1 as c2,                                      --Область
                     u.x_string2 as c3,                                      --Район
                     u.x_string3 as c4,                                      --ПІБ
                     to_char(u.x_dt1, ''dd.mm.yyyy'') as c5,                 --Дата народження
                     decode(u.x_id3, 0, ''жінка'', ''чоловік'') as c6,       --Стать
                     x_surname as c7,                                      --Група інвалідності
                     x_name as c8,                                      --Категорія інвалідності
                     u.x_string4 as c9,                                      --Причина інвалідності
                     to_char(u.x_dt2, ''dd.mm.yyyy'') as c10,                --Дата закінчення дії МСЕК
                     u.x_string5 as c11,                                     --КАТОТТГ місця проживання
                     u.x_string6 as c12,                                     --Адреса проживання
                     decode(u.x_id4, 1, ''Так'', ''Ні'') as c13,             --Наявність надбавки по догляду
                     u.x_sum1 as c14,                                        --Розмір призначеної допомоги
                     u.x_sum2 as c15,                                        --Розмір призначеної доплати на догляд
                     u.x_sum3 as c16                                         --Розмір нарахованої допомоги
                FROM uss_esr.tmp_univ_rpt_data u, uss_esr.tmp_rpt_pay_tp_decision_data w
               WHERE u.x_id1 = w.x_dis
               ORDER BY u.x_id2';
        RDM$RTFL.AddDataSet (l_jbr_id, 'ds', l_sql);

        RDM$RTFL.PutReportToWorkingQueue (p_jbr_id => l_jbr_id);
        RETURN l_jbr_id;
    END DISABILITY_INFO_R1;

    PROCEDURE RegisterReport (p_rt_id      IN     NUMBER,
                              p_start_dt   IN     DATE,
                              p_stop_dt    IN     DATE,
                              p_org_id     IN     NUMBER,
                              p_val_1      IN     VARCHAR2,
                              p_val_2      IN     VARCHAR2,
                              p_val_3      IN     VARCHAR2,
                              p_val_4      IN     VARCHAR2,
                              p_jbr_id        OUT DECIMAL)
    IS
        l_code       VARCHAR2 (50);
        l_user_org   NUMBER;
    BEGIN
        SELECT t.rt_code
          INTO l_code
          FROM rpt_templates t
         WHERE t.rt_id = p_rt_id;

        IF p_org_id = 0
        THEN
            l_user_org := Tools.GetCurrOrg;
        ELSE
            l_user_org := p_org_id;
        END IF;

        p_jbr_id :=
            CASE
                WHEN l_code = 'DSDI_R1'
                THEN
                    DSDI_R1 (p_start_dt, l_user_org, 173)             --#91166
                WHEN l_code = 'PAY_TP_DECISION_R1'
                THEN
                    PAY_TP_DECISION_R1 (p_start_dt,
                                        p_val_1,
                                        p_val_2,
                                        p_val_3,
                                        p_rt_id)                     --#104295
                WHEN l_code = 'DISABILITY_INFO_R1'
                THEN
                    DISABILITY_INFO_R1 (p_start_dt,
                                        l_user_org,
                                        p_val_1,
                                        p_val_2,
                                        p_val_3,
                                        p_val_4,
                                        p_rt_id)                     --#101217
                ELSE
                    NULL
            END;
    END RegisterReport;


    PROCEDURE BUILD_TAX_1DF_DBF_REPORT (                          -- IC #90202
                                        P_NNF_ID IN NUMBER, P_DT IN DATE)
    IS
        l_tax_code   USS_NDI.v_NDI_PAY_PERSON.dpp_tax_code%TYPE;
        l_rep_date   DATE;
        l_org        NUMBER := tools.getcurrorg;
        l_org_to     NUMBER := tools.GetCurrOrgTo;

        P_FILE       BLOB;
    BEGIN
        TOOLS.JobSaveMessage (
               'Початок формування DBF-файла: '
            || TO_CHAR (SYSDATE, 'dd.mm.yyyy hh24:mi:ss'));

        l_org := CASE WHEN l_org = 50001 THEN 50000 ELSE l_org END;
        l_rep_date := P_DT;

        IF l_rep_date IS NULL
        THEN
            raise_application_error (-20000,
                                     'Введіть дату в форматі DD.MM.YYYY');
        ELSE
            l_rep_date := TRUNC (l_rep_date, 'mm');
        END IF;

        SELECT dpp_tax_code
          INTO l_tax_code
          FROM USS_NDI.v_NDI_PAY_PERSON
         WHERE dpp_tp = 'OSZN' AND dpp_org = tools.getcurrorg;

        DELETE FROM uss_esr.tmp_tax_1df;

        INSERT INTO uss_esr.tmp_tax_1df
            WITH
                org
                AS
                    (    SELECT org_id
                           FROM ikis_sys.v_opfu
                          WHERE l_org_to != 34
                     CONNECT BY PRIOR org_id = org_org
                     START WITH org_id = l_org
                     UNION ALL
                     SELECT org_id
                       FROM ikis_sys.v_opfu
                      WHERE l_org_to = 34 AND org_acc_org = l_org)
              SELECT ROW_NUMBER () OVER (ORDER BY t2.TIN, t2.OZN_DOX)
                         NP                         -- номер за порядком рядка
                           ,
                     2
                         PERIOD                           -- пишемо 2 для всіх
                               ,
                     TO_CHAR (l_rep_date, 'yyyy')
                         RIK                               -- рік з параметрів
                            ,
                     l_tax_code
                         KOD         -- код ЄДРПОУ ОСЗН, в якому формуємо звіт
                            ,
                     0
                         TYP                              -- пишемо 0 для всіх
                            ,
                     t2.TIN,
                     SUM (t2.S_NAR)
                         S_NAR                    -- сума нарахування у місяці
                              ,
                     SUM (t2.S_DOX)
                         S_DOX                        -- сума виплати у місяці
                              ,
                     0
                         S_TAXN                                         -- = 0
                               ,
                     0
                         S_TAXP                                         -- = 0
                               ,
                     t2.OZN_DOX,
                     NULL
                         D_PRIYN                              -- не заповнюємо
                                ,
                     NULL
                         D_ZVILN                              -- не заповнюємо
                                ,
                     0
                         OZN_PILG                                       -- = 0
                                 ,
                     0
                         OZNAKA                                         -- = 0
                               ,
                     0
                         A051                                           -- = 0
                             ,
                     0
                         A05                                             --= 0
                FROM (  SELECT CASE
                                   WHEN t.TIN IS NULL
                                   THEN
                                       (  SELECT d.scd_seria || d.scd_number
                                            FROM uss_person.v_sc_document d,
                                                 USS_NDI.v_ndi_document_type dt
                                           WHERE     scd_sc = t.pc_sc
                                                 AND d.scd_ndt = dt.ndt_id
                                                 AND dt.ndt_ndc IN (2, 13)
                                                 AND d.scd_st IN ('1', 'A')
                                                 AND d.scd_number IS NOT NULL
                                        ORDER BY ndt_order NULLS LAST, ndt_id
                                           FETCH FIRST ROW ONLY)
                                   ELSE
                                       t.TIN
                               END              TIN -- РНОКПП заявника. Якщо РНОКПП порожній, тоді вносимо серію та № паспорту (без пробілів, 8 символів) або ID-картку (9 символів) або серію та № свідоцтва про народження (в залежності того, які є документи по заявнику)
                                                   ,
                               SUM (t.S_NAR)    S_NAR -- сума нарахування у місяці
                                                     ,
                               SUM (t.S_DOX)    S_DOX -- сума виплати у місяці
                                                     ,
                               t.OZN_DOX
                          FROM (  SELECT c.pc_sc,
                                         NULL              TIN,
                                         128               OZN_DOX -- пишемо 128
                                                                  ,
                                         SUM (
                                               uss_esr.api$accrual.xsign (acd_op)
                                             * acd_sum)    S_NAR -- сума нарахування у місяці
                                                                ,
                                         0                 S_DOX
                                    FROM uss_esr.ac_detail ad
                                         INNER JOIN uss_esr.accrual a
                                             ON a.ac_id = ad.acd_ac
                                         INNER JOIN uss_ndi.v_ndi_op op
                                             ON op.op_id = ad.acd_op
                                         INNER JOIN uss_esr.personalcase c
                                             ON c.pc_id = a.ac_pc
                                         INNER JOIN uss_ndi.v_ndi_payment_type pt
                                             ON pt.npt_id = ad.acd_npt
                                   WHERE -- l_rep_date BETWEEN TRUNC(ad.acd_ac_start_dt,'mm') AND LAST_DAY(ad.acd_ac_stop_dt)
                                             -- Ivan, 16:50 Также настоятельно рекомендую переделать условия.
                                             a.ac_month = l_rep_date
                                         AND (   ad.acd_op IN (1, 2, 3)
                                              OR op.op_tp1 IN ('NR'))
                                         AND ad.history_status = 'A'
                                         AND ad.acd_imp_pr_num IS NULL -- Tania, 12:43 виключати з сум звіту ті, де заповнено ACD_IMP_PR_NUM (таблиця ac_detail)
                                         AND EXISTS
                                                 (SELECT 1       -- IC #106203
                                                    FROM uss_esr.pc_decision d,
                                                         uss_esr.pc_account pa,
                                                         org
                                                   WHERE     d.pd_id = ad.acd_pd
                                                         AND pa.pa_id = d.pd_pa
                                                         AND pa.pa_org = org.org_id)
                                         /*
                                         AND EXISTS (SELECT 1 -- IC #97518
                                                          FROM org,
                                                              uss_esr.pc_account pa,
                                                              uss_ndi.v_ndi_npt_config nc
                                                          WHERE pa.pa_pc = c.pc_id
                                                              AND pa.pa_nst = nc.nptc_nst
                                                              AND nc.nptc_npt = pt.npt_id
                                                              AND pa.pa_org = org.org_id)
                                         AND EXISTS (SELECT 1 -- IC #97518
                                                          FROM org
                                                              inner join uss_esr.pc_account pa            on pa.pa_pc = c.pc_id
                                                              inner join uss_ndi.v_ndi_npt_config nc      on nc.nptc_nst = pa.pa_nst
                                                                                                              and nc.nptc_npt = pt.npt_id
                                                              left join uss_ndi.v_ndi_decoding_config o   on o.nddc_code_dest = org.org_id and o.nddc_tp = 'ORG_MIGR'
                                                          WHERE nvl(o.nddc_code_src, org.org_id) = pa.pa_org)
                                         */
                                         AND pt.npt_include_pdfo_rpt = 'T'
                                GROUP BY c.pc_sc
                                UNION ALL -- IC #105522 -- Додати в вивантаження ще аліменти
                                  SELECT c.pc_sc,
                                         pp.dpp_tax_code      TIN,
                                         140                  OZN_DOX -- пишемо 140
                                                                     ,
                                         SUM (ad.acd_sum)     S_NAR -- сума нарахування у місяці
                                                                   ,
                                         SUM (ad.acd_sum)     S_DOX -- сума виплачена у місяці (та сама сума)
                                    FROM uss_esr.ac_detail ad
                                         INNER JOIN uss_esr.accrual a
                                             ON a.ac_id = ad.acd_ac
                                         INNER JOIN uss_esr.deduction dn
                                             ON     dn.dn_id = ad.acd_dn
                                                AND dn.dn_ndn IN (5, 6, 7)
                                         INNER JOIN uss_ndi.v_ndi_pay_person pp
                                             ON     pp.dpp_id = dn.dn_dpp
                                                AND LENGTH (pp.dpp_tax_code) = 10
                                         INNER JOIN uss_esr.personalcase c
                                             ON c.pc_id = a.ac_pc
                                         INNER JOIN uss_ndi.v_ndi_payment_type pt
                                             ON pt.npt_id = ad.acd_npt
                                   WHERE     a.ac_month = l_rep_date
                                         AND ad.history_status = 'A'
                                         AND ad.acd_imp_pr_num IS NULL
                                         AND EXISTS
                                                 (SELECT 1       -- IC #106203
                                                    FROM uss_esr.pc_decision d,
                                                         uss_esr.pc_account pa,
                                                         org
                                                   WHERE     d.pd_id = ad.acd_pd
                                                         AND pa.pa_id = d.pd_pa
                                                         AND pa.pa_org = org.org_id)
                                         AND pt.npt_include_pdfo_rpt = 'T'
                                GROUP BY c.pc_sc, pp.dpp_tax_code
                                UNION ALL
                                  SELECT c.pc_sc,
                                         NULL                  TIN,
                                         128                   OZN_DOX -- пишемо 128
                                                                      ,
                                         0                     S_NAR -- сума нарахування у місяці
                                                                    ,
                                         SUM (sd.prsd_sum)     S_DOX
                                    FROM uss_esr.payroll pr
                                         INNER JOIN uss_esr.pr_sheet s
                                             ON s.prs_pr = pr.pr_id
                                         INNER JOIN uss_esr.personalcase c
                                             ON c.pc_id = s.prs_pc
                                         INNER JOIN uss_esr.pr_sheet_detail sd
                                             ON sd.prsd_prs = s.prs_id
                                         INNER JOIN uss_ndi.v_ndi_payment_type pt
                                             ON pt.npt_id = sd.prsd_npt
                                   WHERE -- l_rep_date BETWEEN TRUNC(s.prs_pay_dt,'mm') AND LAST_DAY(s.prs_pay_dt)
                                             pr_month = l_rep_date
                                         AND s.prs_st IN ('KV1', 'KV2')
                                         AND pr.pr_st IN ('F')
                                         AND sd.prsd_tp IN ('PWI', 'RDN')
                                         AND EXISTS
                                                 (SELECT 1        -- IC #97518
                                                    FROM org, uss_esr.pc_account pa
                                                   WHERE     pa.pa_id = sd.prsd_pa
                                                         AND pa.pa_org = org.org_id)
                                         /*
                                        AND EXISTS (SELECT 1 -- IC #97518
                                                         FROM org
                                                             inner join uss_esr.pc_account pa            on pa.pa_id = sd.prsd_pa
                                                             left join uss_ndi.v_ndi_decoding_config o   on o.nddc_code_dest = org.org_id and o.nddc_tp = 'ORG_MIGR'
                                                         WHERE nvl(o.nddc_code_src, org.org_id) = pa.pa_org)
                                        */
                                         AND pt.npt_include_pdfo_rpt = 'T'
                                GROUP BY c.pc_sc) t
                      GROUP BY t.pc_sc, t.TIN, t.OZN_DOX) t2
            GROUP BY t2.TIN, t2.OZN_DOX
              HAVING SUM (t2.S_NAR) >= 0;

        P_FILE := API$EXPORTS.GetFile (P_NNF_ID);
        ikis_sysweb_schedule.SaveAppData (P_FILE);
        TOOLS.JobSaveMessage (
               'Успішне завершення: '
            || TO_CHAR (SYSDATE, 'dd.mm.yyyy hh24:mi:ss'));
    EXCEPTION
        WHEN OTHERS
        THEN
            TOOLS.JobSaveMessage (
                   'Помилка виконання BUILD_TAX_1DF_DBF_REPORT:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END BUILD_TAX_1DF_DBF_REPORT;

    PROCEDURE BUILD_NRH_ESV_DBF_REPORT_ACD (                      -- IC #90138
                                            P_NNF_ID IN NUMBER, P_DT IN DATE)
    IS
        l_rep_date   DATE;
        --    l_min_zp    NUMBER;
        --    l_max_zp    NUMBER;
        --    l_min_zp_d  NUMBER;
        --    l_max_zp_d  NUMBER;
        l_org        NUMBER := tools.getcurrorg;
        l_org_to     NUMBER := tools.GetCurrOrgTo;

        P_FILE       BLOB;
    BEGIN
        TOOLS.JobSaveMessage (
               'Початок формування DBF-файла: '
            || TO_CHAR (SYSDATE, 'dd.mm.yyyy hh24:mi:ss'));
        l_org := CASE WHEN l_org = 50001 THEN 50000 ELSE l_org END;
        l_rep_date := P_DT;

        IF l_rep_date IS NULL
        THEN
            raise_application_error (-20000,
                                     'Введіть дату в форматі DD.MM.YYYY');
        ELSE
            l_rep_date := TRUNC (l_rep_date, 'mm');
        END IF;

        /*
            SELECT MAX (nmz_month_sum)/TO_NUMBER(TO_CHAR(LAST_DAY(l_rep_date),'dd')),
                   MAX (nmz_month_sum*15)/TO_NUMBER(TO_CHAR(LAST_DAY(l_rep_date),'dd')),
                   MAX (nmz_month_sum),
                   MAX (nmz_month_sum*15)
                INTO    l_min_zp_d,   -- мінімальна сума ЗП за день в звітному місяці
                        l_max_zp_d,   -- На вся випадок закласти і максимальну базу - 15*МінЗП. Загальна сума по допомогам не повинна перевищувати цю суму.
                        l_min_zp,
                        l_max_zp
            FROM uss_ndi.v_ndi_min_zp
            WHERE TRUNC (l_rep_date) BETWEEN nmz_start_dt
                                      AND NVL (nmz_stop_dt, TO_DATE ('2999', 'yyyy'));
        */
        DELETE FROM uss_esr.tmp_nrh_esv;

        INSERT INTO uss_esr.tmp_nrh_esv
            WITH
                dat
                AS
                    (SELECT TRUNC (l_rep_date, 'mm')                             dt_start,
                            LAST_DAY (l_rep_date)                                dt_stop,
                            TO_NUMBER (TO_CHAR (LAST_DAY (l_rep_date), 'dd'))    dt_cnt
                       FROM DUAL),
                org
                AS
                    (    SELECT org_id
                           FROM ikis_sys.v_opfu
                          WHERE l_org_to != 34
                     CONNECT BY PRIOR org_id = org_org
                     START WITH org_id = l_org
                     UNION ALL
                     SELECT org_id
                       FROM ikis_sys.v_opfu
                      WHERE l_org_to = 34 AND org_acc_org = l_org),
                nrh
                AS
                    (SELECT CASE
                                WHEN pt.npt_id = 37 THEN 70 -- 20 - по допомозі по догляду за дитиною
                                WHEN pt.npt_id IN (1, 219) THEN 21 -- 21 - по догляду за дітьми-інвалідами
                                WHEN pt.npt_id = 40 THEN 20 -- 20 - усиновлення
                                ELSE 0
                            END
                                npt_id,
                            ad.acd_stop_dt - ad.acd_start_dt + 1
                                cnt_dt,
                            TO_NUMBER (
                                TO_CHAR (LAST_DAY (ad.acd_stop_dt), 'dd'))
                                cnt_dt_month,
                              --uss_esr.api$accrual.xsign (acd_op) * ad.acd_sum             acd_sum,
                              uss_esr.api$accrual.xsign (acd_op)
                            * CASE
                                  -- IC #101709 якщо в документі 605 атрибут 663 стоїть в "T" для заявника. Сума в звіт потрапляє пропорційно дням призначення
                                  WHEN     pt.npt_id = 37
                                       AND dnet$payment_long_rep.get_doc_string (
                                               NULL,
                                               d.pd_ap,
                                               605,
                                               650) = 'T'
                                  THEN
                                      ROUND (
                                            ad.acd_sum
                                          / TO_NUMBER (
                                                TO_CHAR (
                                                    LAST_DAY (
                                                        ad.acd_start_dt),
                                                    'dd'))
                                          * (  ad.acd_stop_dt
                                             - ad.acd_start_dt
                                             + 1),
                                          2)
                                  -- опікун особи/дитини з інвалідністю підгрупи А + НЕ ПРАЦЮЄ  - ЄСВ нараховується з суми МЗП
                                  WHEN     pt.npt_id IN (1, 219)
                                       AND NVL (dnet$payment_long_rep.get_doc_string (
                                                    NULL,
                                                    d.pd_ap,
                                                    605,
                                                    650),
                                                'F') = 'F'
                                       AND EXISTS
                                               (SELECT 1
                                                  FROM uss_esr.ap_person  pp,
                                                       uss_esr.ap_document ad,
                                                       uss_esr.ap_document_attr
                                                       da
                                                 WHERE     pp.app_ap =
                                                           d.pd_ap
                                                       AND pp.app_ap =
                                                           ad.apd_ap
                                                       AND pp.app_id =
                                                           ad.apd_app
                                                       AND ad.apd_id =
                                                           da.apda_apd
                                                       AND da.apda_nda IN
                                                               (797) -- категорія
                                                       AND da.history_status =
                                                           'A'
                                                       AND da.apda_val_string =
                                                           'DIA')
                                  THEN
                                      ROUND (
                                            get_MZP (ad.acd_start_dt)
                                          / TO_NUMBER (
                                                TO_CHAR (
                                                    LAST_DAY (
                                                        ad.acd_start_dt),
                                                    'dd'))
                                          * (  ad.acd_stop_dt
                                             - ad.acd_start_dt
                                             + 1),
                                          2)
                                  -- 20 - усиновлення (NPT_ID = 40), перевіряти вік дітей по рішенню
                                  WHEN     pt.npt_id = 40
                                       -- Якщо у місяці звіту самій молодшій дитині виконується 3 роки
                                       AND dat.dt_start =
                                           (SELECT ADD_MONTHS (
                                                       MAX (
                                                           TRUNC (
                                                               f.pdf_birth_dt,
                                                               'mm')),
                                                       36)
                                              FROM pd_family f
                                             WHERE     f.pdf_pd = d.pd_id
                                                   AND NVL (f.history_status,
                                                            'A') =
                                                       'A')
                                  -- то сума в колонку SUM_TOTAL та SUM_MAX розраховується пропорційно дням (кількість днів до дати народження)
                                  THEN
                                      ROUND (
                                            ad.acd_sum
                                          / dat.dt_cnt
                                          * (SELECT   MAX (f.pdf_birth_dt)
                                                    - MAX (
                                                          TRUNC (
                                                              f.pdf_birth_dt,
                                                              'mm'))
                                               FROM pd_family f
                                              WHERE     f.pdf_pd = d.pd_id
                                                    AND NVL (
                                                            f.history_status,
                                                            'A') =
                                                        'A'),
                                          2)
                                  ELSE
                                      ad.acd_sum
                              END
                                acd_sum,
                            ad.acd_start_dt,
                            ad.acd_stop_dt,
                            c.pc_sc,
                            c.pc_id,
                            pt.npt_id
                                d_npt_id,
                            CASE
                                WHEN EXISTS
                                         (SELECT 1
                                            FROM uss_esr.ap_person         pp,
                                                 uss_esr.ap_document       ad,
                                                 uss_esr.ap_document_attr  da
                                           WHERE     pp.app_ap = d.pd_ap
                                                 AND pp.app_ap = ad.apd_ap
                                                 AND pp.app_id = ad.apd_app
                                                 AND ad.apd_id = da.apda_apd
                                                 AND da.apda_nda IN (797) -- категорія
                                                 AND da.history_status = 'A'
                                                 AND da.apda_val_string =
                                                     'DIA' -- DI/DIA (Дитина з інвалідністю/Дитина з інвалідністю підгрупи "А")
                                                          )
                                THEN
                                    1
                                ELSE
                                    0
                            END
                                is_dia,
                            NVL (dnet$payment_long_rep.get_doc_string (
                                     NULL,
                                     d.pd_ap,
                                     605,
                                     650),
                                 'F')
                                is_work,
                            /*
                            case when exists(select 1
                                                from pd_family f
                                                where f.pdf_pd = d.pd_id
                                                    and f.pdf_birth_dt <= ADD_MONTHS(dt_start,-720) -- Більше 60 років
                                                    and nvl(f.history_status,'A') = 'A')
                                then 1 else 0 end                   is_pens,
                            */
                            -- ключове - сума не рахується по кількості рішень лише одне повинно бути
                            DENSE_RANK ()
                                OVER (
                                    PARTITION BY c.pc_id, d.pd_nst
                                    ORDER BY d.pd_start_dt DESC, d.pd_id DESC)
                                rn
                       FROM uss_esr.accrual  a
                            INNER JOIN uss_esr.personalcase c
                                ON c.pc_id = a.ac_pc
                            INNER JOIN uss_esr.ac_detail ad
                                ON ad.acd_ac = a.ac_id
                            INNER JOIN uss_esr.pc_decision d
                                ON d.pd_id = ad.acd_pd
                            INNER JOIN uss_ndi.v_ndi_op op
                                ON op.op_id = ad.acd_op
                            INNER JOIN dat
                                ON ad.acd_ac_start_dt BETWEEN dat.dt_start
                                                          AND dat.dt_stop
                            INNER JOIN uss_ndi.v_ndi_payment_type pt
                                ON pt.npt_id = ad.acd_npt
                      WHERE     (   ad.acd_op IN (1, 2, 3)
                                 OR op.op_tp1 IN ('NR'))
                            AND ad.history_status = 'A'
                            AND pt.npt_include_esv_rpt = 'T'
                            AND ad.acd_imp_pr_num IS NULL -- Tania, 12:43 виключати з сум звіту ті, де заповнено ACD_IMP_PR_NUM (таблиця ac_detail)
                            AND ad.acd_sum > 0
                            AND ad.acd_stop_dt >= ad.acd_start_dt
                            -- По допомозі по інвалідам потрібно брати лише тих осіб, по яким є надбавка на догляд (NPT_ID = 48), суму також лише по цій надбавці.
                            AND pt.npt_id NOT IN
                                    (SELECT npt_id
                                       FROM uss_ndi.v_ndi_payment_codes  pc
                                            JOIN
                                            uss_ndi.v_ndi_payment_type pt
                                                ON (pt.npt_npc = pc.npc_id)
                                            JOIN uss_ndi.v_ndi_npt_config nc
                                                ON (nc.nptc_npt = pt.npt_id)
                                            JOIN
                                            uss_ndi.v_ndi_service_type st
                                                ON (st.nst_id = nc.nptc_nst)
                                      WHERE     pc.history_status = 'A'
                                            AND pt.history_status = 'A'
                                            AND st.history_status = 'A'
                                            AND pt.npt_id != 1
                                            AND st.nst_id = 248)
                            -- по догляду за дітьми-інвалідами (NPT_ID = 1, 219)
                            AND (   EXISTS
                                        (SELECT 1
                                           FROM uss_esr.ap_person p
                                          WHERE     p.app_ap = d.pd_ap
                                                AND p.history_status = 'A'
                                                AND p.app_tp NOT IN
                                                        ('P', 'Z')) -- 1 заявник (без утриманців) - ЄСВ не нараховується
                                 OR pt.npt_id NOT IN (1, 219))
                            -- усиновлення (NPT_ID = 40)
                            AND (   EXISTS
                                        (SELECT 1
                                           FROM pd_family f
                                          WHERE     f.pdf_pd = d.pd_id
                                                AND f.pdf_birth_dt >
                                                    ADD_MONTHS (dt_start,
                                                                -48) -- Якщо вік всіх учасників > 3 років у місяці звіту, тоді не включати особу до звіту
                                                AND NVL (f.history_status,
                                                         'A') =
                                                    'A')
                                 OR pt.npt_id != 40)
                            AND (   EXISTS
                                        (SELECT 1
                                           FROM uss_esr.pd_payment  pp,
                                                uss_esr.pd_detail   pd
                                          WHERE     pp.pdp_pd = ad.acd_pd
                                                AND pp.pdp_id = pd.pdd_pdp
                                                AND pp.history_status = 'A'
                                                AND dat.dt_start BETWEEN TRUNC (
                                                                             pd.pdd_start_dt,
                                                                             'mm')
                                                                     AND pd.pdd_stop_dt
                                                AND pd.pdd_npt = 48)
                                 OR pt.npt_id != 1 -- перевірка тільки по допомозі по інвалідам
                                                  )
                            -- IC #101709 Якщо заявник - пенсіонер (більше 60 років), то виключаємо зі звіту
                            AND NOT EXISTS
                                    (SELECT 1
                                       FROM uss_esr.pd_family  f,
                                            uss_esr.ap_person  p
                                      WHERE     p.app_ap = d.pd_ap
                                            AND f.pdf_pd = d.pd_id
                                            AND p.app_sc = f.pdf_sc
                                            AND p.history_status = 'A'
                                            AND f.pdf_birth_dt <=
                                                ADD_MONTHS (dt_start, -720) -- Більше 60 років
                                            AND p.app_tp = 'Z'))
            SELECT TO_CHAR (l_rep_date, 'mm')       PERIOD_M -- числове значення місяця (з параметрів)
                                                            ,
                   TO_CHAR (l_rep_date, 'yyyy')     PERIOD_Y -- числове значення року (з параметрів)
                                                            ,
                   1                                UKR_GROMAD -- виводимо 1 для всіх
                                                              ,
                   t2.NUMIDENT,
                   t2.LN,
                   t2.NM,
                   t2.FTN,
                   t2.ZO,
                   t2.START_DT,
                   t2.STOP_DT,
                   0                                PAY_TP,
                   t2.PAY_MNTH,
                   t2.PAY_YEAR,
                   t2.SUM_TOTAL,
                   t2.SUM_MAX,
                   t2.SUM_INS,
                   ''                               OZN
              FROM (SELECT t1.*,
                           -- Якщо по людині декілька допомог, тоді беремо будь яку з максимальним періодом (по мінімальному ЗО) за місяць.
                           -- Якщо 2 види допомоги, - основним кодом має бути 20 (до 3х років усиновлення чи при народженні),
                           -- після 3х має змінюватись на код догляду (21 чи 70).
                           DENSE_RANK ()
                               OVER (
                                   PARTITION BY t1.pc_sc
                                   ORDER BY
                                       t1.cnt_dt DESC,
                                       CASE
                                           WHEN t1.zo = 0 THEN 10000
                                           ELSE t1.zo
                                       END)    rn
                      FROM (SELECT t.*,
                                     MAX (t.max_dt)
                                         OVER (PARTITION BY t.pc_sc, t.zo)
                                   - MIN (t.min_dt)
                                         OVER (PARTITION BY t.pc_sc, t.zo)    cnt_dt
                              FROM (  SELECT (  SELECT    CASE
                                                              WHEN dt.ndt_id = 6
                                                              THEN
                                                                  'БК' -- Якщо РНОКПП порожній, тоді заповнюємо конкатенацією "БК"+серія та № паспорту (якщо паспорт України)
                                                              WHEN dt.ndt_id = 7
                                                              THEN
                                                                  'П' -- У випадку ID картки конкатенація "П" + № картки
                                                              ELSE
                                                                  ''
                                                          END
                                                       || d.scd_seria
                                                       || d.scd_number  -- 'П'
                                                  FROM uss_person.v_sc_document d,
                                                       USS_NDI.v_ndi_document_type
                                                       dt
                                                 WHERE     scd_sc = nrh.pc_sc
                                                       AND d.scd_ndt = dt.ndt_id
                                                       AND dt.ndt_ndc IN (2, 13)
                                                       AND d.scd_st IN ('1', 'A')
                                                       AND d.scd_number
                                                               IS NOT NULL
                                              ORDER BY ndt_order NULLS LAST,
                                                       ndt_id
                                                 FETCH FIRST ROW ONLY)
                                                 NUMIDENT -- РНОКПП заявника. Якщо РНОКПП порожній, тоді вносимо серію та № паспорту (без пробілів, 8 символів) або ID-картку (9 символів) або серію та № свідоцтва про народження (в залежності того, які є документи по заявнику)
                                                         ,
                                             sci_ln
                                                 LN                -- прізвище
                                                   ,
                                             sci_fn
                                                 NM                    -- ім'я
                                                   ,
                                             sci_mn
                                                 FTN            -- по батькові
                                                    ,
                                             nrh.npt_id
                                                 ZO -- варіанти: 70 - по допомозі по догляду за дитиною (NPT_ID = 37);21 - по догляду за дітьми-інвалідами (NPT_ID = 1, 219)
                                                   ,
                                             TO_CHAR (MIN (nrh.acd_start_dt),
                                                      'dd')
                                                 START_DT -- число з поля ACD_Start_DT (мінімальне, якщо декілька рядків по місяцю)
                                                         ,
                                             TO_CHAR (MAX (nrh.acd_stop_dt),
                                                      'dd')
                                                 STOP_DT -- число з поля ACD_Stop_DT (максимальне, якщо декілька рядків по місяцю)
                                                        --,0                          PAY_TP -- заповнюємо всім 0
                                                        ,
                                             TO_CHAR (
                                                 TRUNC (nrh.acd_start_dt, 'mm'),
                                                 'mm')
                                                 PAY_MNTH -- номер місяця з поля ACD_Start_DT
                                                         ,
                                             TO_CHAR (
                                                 TRUNC (nrh.acd_start_dt, 'mm'),
                                                 'yyyy')
                                                 PAY_YEAR -- рік з поля ACD_Start_DT
                                                         -- IC #94638
                                                         ,
                                             LEAST (
                                                 GREATEST (
                                                     SUM (nrh.acd_sum),
                                                     ROUND (
                                                         SUM (
                                                               get_MZP (
                                                                   nrh.acd_start_dt)
                                                             / nrh.cnt_dt_month
                                                             * nrh.cnt_dt),
                                                         2)),
                                                 ROUND (
                                                     SUM (
                                                           get_MZP (
                                                               nrh.acd_start_dt,
                                                               'max')
                                                         / nrh.cnt_dt_month
                                                         * nrh.cnt_dt),
                                                     2))
                                                 SUM_TOTAL -- нарахована сума за місяць
                                                          ,
                                             SUM (nrh.acd_sum)
                                                 SUM_MAX -- нарахована сума за місяць
                                                        ,
                                             ROUND (SUM (nrh.acd_sum) * 0.22,
                                                    2)
                                                 SUM_INS -- нарахована сума за місяць * 0,22 (округлення до 2 знаків після коми)
                                                        --,null                       OZN -- порожне значенн

                                                        ,
                                             nrh.pc_sc,
                                             MIN (nrh.acd_start_dt)
                                                 min_dt,
                                             MAX (nrh.acd_stop_dt)
                                                 max_dt
                                        FROM nrh
                                             LEFT JOIN
                                             uss_person.v_socialcard sc
                                                 ON sc.sc_id = nrh.pc_sc
                                             LEFT JOIN
                                             uss_person.v_sc_change scc
                                                 ON     scc.scc_sc = sc_id
                                                    AND scc_id = sc_scc
                                             LEFT JOIN uss_person.v_sc_identity
                                                 ON sci_id = scc_sci
                                       WHERE     EXISTS
                                                     (SELECT 1    -- IC #97518
                                                        FROM org,
                                                             uss_esr.pc_account
                                                             pa,
                                                             uss_ndi.v_ndi_npt_config
                                                             nc
                                                       WHERE     pa.pa_pc =
                                                                 nrh.pc_id
                                                             AND pa.pa_nst =
                                                                 nc.nptc_nst
                                                             AND nc.nptc_npt =
                                                                 nrh.d_npt_id
                                                             AND pa.pa_org =
                                                                 org.org_id)
                                             -- Заявник - опікун особи/дитини з інвалідністю підгрупи А
                                             AND CASE
                                                     WHEN     npt_id = 21
                                                          AND is_dia = 1
                                                     THEN
                                                         CASE
                                                             WHEN is_work = 'T'
                                                             THEN
                                                                 0 -- + ПРАЦЮЄ - ЄСВ не нараховується
                                                             -- WHEN is_pens = 1 THEN 0     -- + пенсіонер за віком (60 років по даті народження) - ЄСВ не нараховується
                                                             ELSE
                                                                 1
                                                         END
                                                     ELSE
                                                         1
                                                 END =
                                                 1
                                             AND nrh.rn = 1
                                    GROUP BY nrh.pc_sc,
                                             sci_ln,
                                             sci_fn,
                                             sci_mn,
                                             nrh.npt_id,
                                             TRUNC (nrh.acd_start_dt, 'mm'))
                                   t
                             WHERE t.NUMIDENT IS NOT NULL) t1) t2
             WHERE t2.rn = 1;

        UPDATE uss_esr.tmp_nrh_esv
           SET sum_max = sum_total, sum_ins = ROUND (sum_total * 0.22, 2)
         WHERE 1 = 1;

        P_FILE := API$EXPORTS.GetFile (P_NNF_ID);
        ikis_sysweb_schedule.SaveAppData (P_FILE);
        TOOLS.JobSaveMessage (
               'Успішне завершення: '
            || TO_CHAR (SYSDATE, 'dd.mm.yyyy hh24:mi:ss'));
    EXCEPTION
        WHEN OTHERS
        THEN
            TOOLS.JobSaveMessage (
                   'Помилка виконання BUILD_NRH_ESV_DBF_REPORT:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END BUILD_NRH_ESV_DBF_REPORT_ACD;

    PROCEDURE BUILD_NRH_ESV_DBF_REPORT_01 (                      -- IC #103937
                                           P_NNF_ID IN NUMBER, P_DT IN DATE)
    IS
        l_rep_date   DATE;
        l_org        NUMBER := tools.getcurrorg;
        l_org_to     NUMBER := tools.GetCurrOrgTo;

        P_FILE       BLOB;
    BEGIN
        TOOLS.JobSaveMessage (
               'Початок формування DBF-файла: '
            || TO_CHAR (SYSDATE, 'dd.mm.yyyy hh24:mi:ss'));
        l_org := CASE WHEN l_org = 50001 THEN 50000 ELSE l_org END;
        l_rep_date := P_DT;

        IF l_rep_date IS NULL
        THEN
            raise_application_error (-20000,
                                     'Введіть дату в форматі DD.MM.YYYY');
        ELSE
            l_rep_date := TRUNC (l_rep_date, 'mm');
        END IF;

        DELETE FROM uss_esr.tmp_nrh_esv;

        INSERT INTO uss_esr.tmp_nrh_esv
            WITH
                dat
                AS
                    (SELECT m.nm_month,
                            m.nm_start_dt,
                            m.nm_stop_dt,
                            m.nm_days
                       FROM uss_ndi.v_ndi_months m
                      WHERE l_rep_date BETWEEN m.nm_start_dt AND m.nm_stop_dt),
                org
                AS
                    (    SELECT org_id
                           FROM ikis_sys.v_opfu
                          WHERE l_org_to != 34
                     CONNECT BY PRIOR org_id = org_org
                     START WITH org_id = l_org
                     UNION ALL
                     SELECT org_id
                       FROM ikis_sys.v_opfu
                      WHERE l_org_to = 34 AND org_acc_org = l_org),
                pdap
                AS
                    (SELECT dat.nm_month,
                            d.pd_id,
                            MIN (ap.pdap_start_dt)
                                OVER (PARTITION BY d.pd_id)
                                pdap_start_dt,
                            MAX (ap.pdap_stop_dt) OVER (PARTITION BY d.pd_id)
                                pdap_stop_dt,
                            CASE
                                WHEN     TRUNC (d.pd_dt, 'mm') = dat.nm_month
                                     AND TRUNC (ap.pdap_start_dt, 'mm') <
                                         TRUNC (d.pd_dt, 'mm')
                                THEN
                                    1
                                ELSE
                                    0
                            END
                                is_before,
                            CASE
                                WHEN TRUNC (d.pd_dt, 'mm') > dat.nm_month
                                THEN
                                    1
                                ELSE
                                    0
                            END
                                is_after,
                            ROW_NUMBER ()
                                OVER (
                                    PARTITION BY d.pd_pc, d.pd_nst
                                    ORDER BY d.pd_start_dt DESC, d.pd_id DESC)
                                rn
                       FROM uss_esr.pd_accrual_period  ap,
                            uss_esr.pc_decision        d,
                            dat
                      WHERE     d.pd_id = ap.pdap_pd
                            AND ap.history_status = 'A'
                            AND dat.nm_month BETWEEN TRUNC (ap.pdap_start_dt,
                                                            'mm')
                                                 AND ap.pdap_stop_dt
                            AND EXISTS
                                    (SELECT 1                    -- IC #106203
                                       FROM uss_esr.pc_account pa, org
                                      WHERE     pa.pa_id = d.pd_pa
                                            AND pa.pa_org = org.org_id)
                            -- не потрібно включати в звіт ЄСВ, якщо інвалід по даті народження старше ніж 18 років
                            AND (   EXISTS
                                        (SELECT 1                -- IC #106203
                                           FROM uss_esr.pd_family  f
                                                JOIN uss_esr.ap_person pp1
                                                    ON     pp1.app_ap =
                                                           d.pd_ap
                                                       AND pp1.app_sc =
                                                           f.pdf_sc
                                                       AND pp1.app_tp NOT IN
                                                               ('Z', 'P')
                                                JOIN uss_esr.ap_document ad
                                                    ON     ad.apd_ap =
                                                           pp1.app_ap
                                                       AND ad.apd_app =
                                                           pp1.app_id
                                                       AND ad.apd_ndt IN
                                                               (200, 201) -- Документ про інвалідність
                                          WHERE     f.pdf_pd = d.pd_id
                                                AND f.pdf_birth_dt >
                                                    ADD_MONTHS (dat.nm_month,
                                                                (-12 * 18)) -- не виповнилось 18 років
                                                                           )
                                 OR d.pd_nst != 248)),
                nrh
                AS
                    (SELECT c.pc_id,
                            c.pc_sc,
                            pp.pdp_npt
                                d_npt_id,
                            m.nm_month
                                ac_month,
                            GREATEST (pp.pdp_start_dt, m.nm_start_dt)
                                acd_start_dt,
                            LEAST (pp.pdp_stop_dt, m.nm_stop_dt)
                                acd_stop_dt,
                              LEAST (pp.pdp_stop_dt, m.nm_stop_dt)
                            - GREATEST (pp.pdp_start_dt, m.nm_start_dt)
                            + 1
                                cnt_dt,
                            m.nm_days
                                cnt_dt_month,
                            p.pdap_start_dt,
                            p.pdap_stop_dt,
                            p.pdap_stop_dt - p.pdap_start_dt + 1
                                cnt_dt_pdap,
                            CASE
                                -- IC #103937 Для npt_id = 37 - Розрахунок від МЗП пропорційно дням призначення
                                WHEN pt.npt_id = 37
                                THEN
                                    ROUND (
                                          dnet$payment_long_rep.get_mzp (
                                              GREATEST (pp.pdp_start_dt,
                                                        m.nm_start_dt))
                                        / m.nm_days
                                        * (  LEAST (pp.pdp_stop_dt,
                                                    m.nm_stop_dt)
                                           - GREATEST (pp.pdp_start_dt,
                                                       m.nm_start_dt)
                                           + 1),
                                        2)
                                -- Для npt_id IN (1, 219) - опікун особи/дитини з інвалідністю + НЕ ПРАЦЮЄ - ЄСВ нараховується з суми МЗП пропорційно дням призначення
                                WHEN     pt.npt_id IN (1, 219)
                                     AND NVL (dnet$payment_long_rep.get_doc_string (
                                                  NULL,
                                                  d.pd_ap,
                                                  605,
                                                  650),
                                              'F') = 'F'
                                     AND EXISTS
                                             (SELECT 1
                                                FROM uss_esr.pc_decision  d1
                                                     JOIN uss_esr.pd_family f
                                                         ON f.pdf_pd =
                                                            d1.pd_id
                                                     JOIN
                                                     uss_esr.ap_person pp1
                                                         ON     pp1.app_ap =
                                                                d.pd_ap
                                                            AND pp1.app_sc =
                                                                f.pdf_sc
                                                     JOIN
                                                     uss_esr.ap_document ad
                                                         ON     ad.apd_ap =
                                                                pp1.app_ap
                                                            AND ad.apd_app =
                                                                pp1.app_id
                                                     JOIN
                                                     uss_esr.ap_document_attr
                                                     da
                                                         ON     da.apda_apd =
                                                                ad.apd_id
                                                            AND da.apda_nda IN
                                                                    (797) -- категорія
                                                            AND da.history_status =
                                                                'A'
                                                            AND da.apda_val_string IN
                                                                    ('DI',
                                                                     'DIA') -- Дитина з інвалідністю, дитина з інвалідністю підгрупи А
                                               WHERE     d1.pd_ap = d.pd_ap
                                                     AND f.pdf_birth_dt >
                                                         ADD_MONTHS (
                                                             p.nm_month,
                                                             (-12 * 18))) -- не виповнилось 18 років
                                THEN
                                    ROUND (
                                          dnet$payment_long_rep.get_mzp (
                                              GREATEST (pp.pdp_start_dt,
                                                        m.nm_start_dt))
                                        / m.nm_days
                                        * (  LEAST (pp.pdp_stop_dt,
                                                    m.nm_stop_dt)
                                           - GREATEST (pp.pdp_start_dt,
                                                       m.nm_start_dt)
                                           + 1),
                                        2)
                                -- 20 - усиновлення (NPT_ID = 40), перевіряти вік дітей по рішенню
                                WHEN     pt.npt_id = 40
                                     -- Якщо у місяці звіту самій молодшій дитині виконується 3 роки
                                     AND m.nm_start_dt =
                                         (SELECT ADD_MONTHS (
                                                     MAX (
                                                         TRUNC (
                                                             f.pdf_birth_dt,
                                                             'mm')),
                                                     36)
                                            FROM pd_family f
                                           WHERE     f.pdf_pd = d.pd_id
                                                 AND NVL (f.history_status,
                                                          'A') =
                                                     'A')
                                -- то сума в колонку SUM_TOTAL та SUM_MAX розраховується пропорційно дням (кількість днів до дати народження)
                                THEN
                                    ROUND (
                                          pp.pdp_sum
                                        / m.nm_days
                                        * (SELECT   MAX (f.pdf_birth_dt)
                                                  - MAX (
                                                        TRUNC (
                                                            f.pdf_birth_dt,
                                                            'mm'))
                                             FROM pd_family f
                                            WHERE     f.pdf_pd = d.pd_id
                                                  AND NVL (f.history_status,
                                                           'A') =
                                                      'A'),
                                        2)
                                WHEN COUNT (*)
                                         OVER (
                                             PARTITION BY d.pd_id,
                                                          d.pd_nst,
                                                          m.nm_month) >
                                     1
                                THEN
                                    ROUND (
                                          pp.pdp_sum
                                        / m.nm_days
                                        * (  LEAST (pp.pdp_stop_dt,
                                                    m.nm_stop_dt)
                                           - GREATEST (pp.pdp_start_dt,
                                                       m.nm_start_dt)
                                           + 1),
                                        2)
                                ELSE
                                    pp.pdp_sum
                            END
                                acd_sum,
                            CASE
                                WHEN pt.npt_id = 37 THEN 70 -- 20 - по допомозі по догляду за дитиною
                                WHEN pt.npt_id IN (1, 219) THEN 21 -- 21 - по догляду за дітьми-інвалідами
                                WHEN pt.npt_id = 40 THEN 20 -- 20 - усиновлення
                                ELSE 0
                            END
                                npt_id,
                            CASE
                                WHEN EXISTS
                                         (SELECT 1
                                            FROM uss_esr.pc_decision  d1
                                                 JOIN uss_esr.pd_family f
                                                     ON f.pdf_pd = d1.pd_id
                                                 JOIN uss_esr.ap_person pp1
                                                     ON     pp1.app_ap =
                                                            d.pd_ap
                                                        AND pp1.app_sc =
                                                            f.pdf_sc
                                                 JOIN uss_esr.ap_document ad
                                                     ON     ad.apd_ap =
                                                            pp1.app_ap
                                                        AND ad.apd_app =
                                                            pp1.app_id
                                                 JOIN
                                                 uss_esr.ap_document_attr da
                                                     ON     da.apda_apd =
                                                            ad.apd_id
                                                        AND da.apda_nda IN
                                                                (797) -- категорія
                                                        AND da.history_status =
                                                            'A'
                                                        AND da.apda_val_string IN
                                                                ('DI', 'DIA') -- Дитина з інвалідністю, дитина з інвалідністю підгрупи А
                                           WHERE     d1.pd_ap = d.pd_ap
                                                 AND f.pdf_birth_dt >
                                                     ADD_MONTHS (p.nm_month,
                                                                 (-12 * 18))) -- не виповнилось 18 років
                                THEN
                                    1
                                ELSE
                                    0
                            END
                                is_dia,
                            NVL (dnet$payment_long_rep.get_doc_string (
                                     NULL,
                                     d.pd_ap,
                                     605,
                                     650),
                                 'F')
                                is_work,
                            CASE
                                WHEN EXISTS
                                         (SELECT 1
                                            FROM uss_esr.pc_decision  d1
                                                 JOIN uss_esr.pd_family f
                                                     ON f.pdf_pd = d1.pd_id
                                                 JOIN uss_esr.ap_person pp1
                                                     ON     pp1.app_ap =
                                                            d.pd_ap
                                                        AND pp1.app_sc =
                                                            f.pdf_sc
                                                        AND pp1.app_tp NOT IN
                                                                ('Z', 'P')
                                                 JOIN uss_esr.ap_document ad
                                                     ON     ad.apd_ap =
                                                            pp1.app_ap
                                                        AND ad.apd_app =
                                                            pp1.app_id
                                                 JOIN
                                                 uss_esr.ap_document_attr da
                                                     ON     da.apda_apd =
                                                            ad.apd_id
                                                        AND da.apda_nda IN
                                                                (349,
                                                                 666,
                                                                 1790) -- Група інвалідності
                                                        AND da.history_status =
                                                            'A'
                                                        AND da.apda_val_string IN
                                                                ('1') -- Група інвалідності I
                                           WHERE     d1.pd_ap = d.pd_ap
                                                 AND f.pdf_birth_dt <=
                                                     ADD_MONTHS (p.nm_month,
                                                                 (-12 * 18))) -- виповнилось 18 років
                                THEN
                                    1
                                ELSE
                                    0
                            END
                                is_gr1,
                            pp.pdp_sum
                       FROM pdap  p
                            INNER JOIN uss_esr.pc_decision d
                                ON d.pd_id = p.pd_id
                            INNER JOIN uss_esr.pd_payment pp
                                ON     pp.pdp_pd = d.pd_id
                                   AND pp.history_status = 'A'
                            INNER JOIN uss_esr.personalcase c
                                ON c.pc_id = d.pd_pc
                            INNER JOIN uss_ndi.v_ndi_payment_type pt
                                ON pt.npt_id = pp.pdp_npt
                            --INNER JOIN uss_ndi.v_ndi_months m         ON m.nm_month = p.nm_month
                            INNER JOIN uss_ndi.v_ndi_months m
                                ON     m.nm_month >=
                                       CASE -- Якщо дата рішення більша, ніж дата початку дії рішення в PD_Payment, тоді треба в місяці, коли прийнято рішення, зробити рядки по звіту за всі місяці, які перед місяцем рішення
                                           WHEN     p.is_before = 1
                                                -- Tania, 30.07.2024 14:55 по всім з NPT_ID = 37, 40, 1, 219
                                                AND pt.npt_id IN (37,
                                                                  40,
                                                                  1,
                                                                  219)
                                           THEN
                                               TRUNC (pp.pdp_start_dt, 'mm')
                                           ELSE
                                               p.nm_month
                                       END
                                   AND m.nm_month <= p.nm_month
                      WHERE     p.nm_month BETWEEN TRUNC (pp.pdp_start_dt,
                                                          'mm')
                                               AND pp.pdp_stop_dt
                            AND pp.pdp_stop_dt >= pp.pdp_start_dt
                            AND pp.pdp_sum > 0
                            -- не відображати попередні місяця по рішенням дата яких більше початку періоду нарахувань
                            AND (   p.is_after = 0
                                 OR pt.npt_id NOT IN (37,
                                                      40,
                                                      1,
                                                      219))
                            -- ключове - сума не рахується по кількості рішень лише одне повинно бути
                            AND p.rn = 1
                            AND pt.npt_include_esv_rpt = 'T'
                            -- По допомозі по інвалідам потрібно брати лише тих осіб, по яким є надбавка на догляд (NPT_ID = 48), суму також лише по цій надбавці.
                            AND pt.npt_id NOT IN
                                    (SELECT pt.npt_id
                                       FROM uss_ndi.v_ndi_payment_type  pt
                                            JOIN uss_ndi.v_ndi_npt_config nc
                                                ON (nc.nptc_npt = pt.npt_id)
                                            JOIN
                                            uss_ndi.v_ndi_service_type st
                                                ON (st.nst_id = nc.nptc_nst)
                                      WHERE     pt.history_status = 'A'
                                            AND st.history_status = 'A'
                                            AND pt.npt_id != 1
                                            AND st.nst_id = 248)
                            -- по догляду за дітьми-інвалідами
                            AND CASE
                                    WHEN d.pd_nst != 248
                                    THEN
                                        1
                                    -- 1 заявник (без утриманців) - ЄСВ не нараховується
                                    WHEN NOT EXISTS
                                             (SELECT 1
                                                FROM uss_esr.pd_family  f,
                                                     uss_esr.ap_person  p1
                                               WHERE     f.pdf_pd = d.pd_id
                                                     AND p1.app_ap = d.pd_ap
                                                     AND p1.app_sc = f.pdf_sc
                                                     AND p1.app_tp NOT IN
                                                             ('P', 'Z'))
                                    THEN
                                        0
                                    -- IC #103937 якщо по людині немає рішення, де він лише сам є отримувачем (рішення, де лише один учасник).
                                    WHEN EXISTS
                                             (SELECT 1
                                                FROM uss_esr.pc_decision  d1
                                                     JOIN
                                                     uss_esr.pd_payment pp1
                                                         ON     pp1.pdp_pd =
                                                                d1.pd_id
                                                            AND pp1.history_status =
                                                                'A'
                                                            AND m.nm_month BETWEEN TRUNC (
                                                                                       pp1.pdp_start_dt,
                                                                                       'mm')
                                                                               AND pp1.pdp_stop_dt
                                               WHERE     d1.pd_pc = c.pc_id
                                                     AND d1.pd_id != d.pd_id
                                                     AND NOT EXISTS
                                                             (SELECT 1
                                                                FROM uss_esr.pd_family
                                                                     f,
                                                                     uss_esr.ap_person
                                                                     p1
                                                               WHERE     f.pdf_pd =
                                                                         d1.pd_id
                                                                     AND p1.app_ap =
                                                                         d1.pd_ap
                                                                     AND p1.app_sc =
                                                                         f.pdf_sc
                                                                     AND p1.app_tp NOT IN
                                                                             ('P',
                                                                              'Z')))
                                    THEN
                                        0
                                    -- або немає іншого рішення з іншим інвалідом
                                    WHEN EXISTS
                                             (SELECT 1
                                                FROM uss_esr.pc_decision  d1
                                                     JOIN
                                                     uss_esr.pd_payment pp1
                                                         ON     pp1.pdp_pd =
                                                                d1.pd_id
                                                            AND pp1.history_status =
                                                                'A'
                                                            AND m.nm_month BETWEEN TRUNC (
                                                                                       pp1.pdp_start_dt,
                                                                                       'mm')
                                                                               AND pp1.pdp_stop_dt
                                                     JOIN uss_esr.pd_family f
                                                         ON     d1.pd_id =
                                                                f.pdf_pd
                                                            AND NOT EXISTS
                                                                    (SELECT 1
                                                                       FROM uss_esr.pd_family
                                                                                f1
                                                                      WHERE     f1.pdf_pd =
                                                                                d.pd_id
                                                                            AND f1.pdf_sc =
                                                                                f.pdf_sc)
                                                     JOIN
                                                     uss_esr.ap_person p1
                                                         ON     p1.app_ap =
                                                                d1.pd_ap
                                                            AND p1.app_sc =
                                                                f.pdf_sc
                                                            AND p1.app_tp NOT IN
                                                                    ('P', 'Z')
                                                            AND EXISTS
                                                                    (SELECT 1
                                                                       FROM uss_esr.ap_document
                                                                                ad
                                                                      WHERE     ad.apd_ap =
                                                                                p1.app_ap
                                                                            AND ad.apd_app =
                                                                                p1.app_id
                                                                            AND ad.apd_ndt IN
                                                                                    (200,
                                                                                     201)) -- Документ про інвалідність
                                               WHERE     d1.pd_pc = c.pc_id
                                                     AND d1.pd_id != d.pd_id)
                                    THEN
                                        0
                                    ELSE
                                        1
                                END =
                                1
                            -- усиновлення (NPT_ID = 40)
                            AND (   EXISTS
                                        (SELECT 1
                                           FROM pd_family f
                                          WHERE     f.pdf_pd = d.pd_id
                                                AND f.pdf_birth_dt >
                                                    ADD_MONTHS (p.nm_month,
                                                                (-12 * 3)) -- Якщо вік всіх учасників > 3 років у місяці звіту, тоді не включати особу до звіту
                                                AND NVL (f.history_status,
                                                         'A') =
                                                    'A')
                                 OR pt.npt_id != 40)
                            AND (   EXISTS
                                        (SELECT 1
                                           FROM uss_esr.pd_detail pd
                                          WHERE     pd.pdd_pdp = pp.pdp_id
                                                AND p.nm_month BETWEEN TRUNC (
                                                                           pd.pdd_start_dt,
                                                                           'mm')
                                                                   AND pd.pdd_stop_dt
                                                AND pd.pdd_npt = 48)
                                 OR pt.npt_id != 1 -- перевірка тільки по допомозі по інвалідам
                                                  )
                            -- IC #101709 Якщо заявник - пенсіонер (більше 60 років), то виключаємо зі звіту
                            AND NOT EXISTS
                                    (SELECT 1
                                       FROM uss_esr.pd_family  f,
                                            uss_esr.ap_person  p1
                                      WHERE     p1.app_ap = d.pd_ap
                                            AND f.pdf_pd = d.pd_id
                                            AND p1.app_sc = f.pdf_sc
                                            AND p1.history_status = 'A'
                                            AND f.pdf_birth_dt <=
                                                ADD_MONTHS (p.nm_month,
                                                            (-12 * 60)) -- Більше 60 років
                                            AND p1.app_tp = 'Z'))
              SELECT TO_CHAR (l_rep_date, 'mm')       PERIOD_M -- числове значення місяця (з параметрів)
                                                              ,
                     TO_CHAR (l_rep_date, 'yyyy')     PERIOD_Y -- числове значення року (з параметрів)
                                                              ,
                     1                                UKR_GROMAD -- виводимо 1 для всіх
                                                                ,
                     t2.NUMIDENT,
                     t2.LN,
                     t2.NM,
                     t2.FTN,
                     t2.ZO,
                     t2.START_DT,
                     t2.STOP_DT,
                     0                                PAY_TP,
                     t2.PAY_MNTH,
                     t2.PAY_YEAR,
                     t2.SUM_TOTAL,
                     t2.SUM_MAX,
                     t2.SUM_INS,
                     ''                               OZN
                FROM (SELECT t1.*,
                             -- Якщо по людині декілька допомог, тоді беремо будь яку з максимальним періодом (по мінімальному ЗО) за місяць.
                             -- Якщо 2 види допомоги, - основним кодом має бути 20 (до 3х років усиновлення чи при народженні),
                             -- після 3х має змінюватись на код догляду (21 чи 70).
                             DENSE_RANK ()
                                 OVER (
                                     PARTITION BY t1.pc_sc
                                     ORDER BY
                                         t1.cnt_dt DESC,
                                         CASE
                                             WHEN t1.zo = 0 THEN 10000
                                             ELSE t1.zo
                                         END)    rn
                        FROM (SELECT t.*,
                                     MAX (t.cnt_dt_pdap)
                                         OVER (PARTITION BY t.pc_sc, t.zo)    cnt_dt
                                FROM (  SELECT (  SELECT    CASE
                                                                WHEN dt.ndt_id = 6
                                                                THEN
                                                                    'БК' -- Якщо РНОКПП порожній, тоді заповнюємо конкатенацією "БК"+серія та № паспорту (якщо паспорт України)
                                                                WHEN dt.ndt_id = 7
                                                                THEN
                                                                    'П' -- У випадку ID картки конкатенація "П" + № картки
                                                                ELSE
                                                                    ''
                                                            END
                                                         || d.scd_seria
                                                         || d.scd_number -- 'П'
                                                    FROM uss_person.v_sc_document d,
                                                         USS_NDI.v_ndi_document_type
                                                         dt
                                                   WHERE     scd_sc = nrh.pc_sc
                                                         AND d.scd_ndt = dt.ndt_id
                                                         AND dt.ndt_ndc IN (2, 13)
                                                         AND d.scd_st IN ('1', 'A')
                                                         AND d.scd_number
                                                                 IS NOT NULL
                                                ORDER BY ndt_order NULLS LAST,
                                                         ndt_id
                                                   FETCH FIRST ROW ONLY)
                                                   NUMIDENT -- РНОКПП заявника. Якщо РНОКПП порожній, тоді вносимо серію та № паспорту (без пробілів, 8 символів) або ID-картку (9 символів) або серію та № свідоцтва про народження (в залежності того, які є документи по заявнику)
                                                           ,
                                               sci_ln
                                                   LN              -- прізвище
                                                     ,
                                               sci_fn
                                                   NM                  -- ім'я
                                                     ,
                                               sci_mn
                                                   FTN          -- по батькові
                                                      ,
                                               nrh.npt_id
                                                   ZO -- варіанти: 70 - по допомозі по догляду за дитиною (NPT_ID = 37);21 - по догляду за дітьми-інвалідами (NPT_ID = 1, 219)
                                                     ,
                                               TO_CHAR (MIN (nrh.acd_start_dt),
                                                        'dd')
                                                   START_DT -- число з поля ACD_Start_DT (мінімальне, якщо декілька рядків по місяцю)
                                                           ,
                                               TO_CHAR (MAX (nrh.acd_stop_dt),
                                                        'dd')
                                                   STOP_DT -- число з поля ACD_Stop_DT (максимальне, якщо декілька рядків по місяцю)
                                                          --,0                          PAY_TP -- заповнюємо всім 0
                                                          ,
                                               TO_CHAR (
                                                   TRUNC (nrh.acd_start_dt, 'mm'),
                                                   'mm')
                                                   PAY_MNTH -- номер місяця з поля ACD_Start_DT
                                                           ,
                                               TO_CHAR (
                                                   TRUNC (nrh.acd_start_dt, 'mm'),
                                                   'yyyy')
                                                   PAY_YEAR -- рік з поля ACD_Start_DT
                                                           -- IC #94638
                                                           ,
                                               LEAST (
                                                   GREATEST (
                                                       SUM (nrh.acd_sum),
                                                       ROUND (
                                                           SUM (
                                                                 uss_esr.dnet$payment_long_rep.get_MZP (
                                                                     nrh.acd_start_dt)
                                                               / nrh.cnt_dt_month
                                                               * nrh.cnt_dt),
                                                           2)),
                                                   ROUND (
                                                       SUM (
                                                             uss_esr.dnet$payment_long_rep.get_MZP (
                                                                 nrh.acd_start_dt,
                                                                 'max')
                                                           / nrh.cnt_dt_month
                                                           * nrh.cnt_dt),
                                                       2))
                                                   SUM_TOTAL -- нарахована сума за місяць
                                                            ,
                                               SUM (nrh.acd_sum)
                                                   SUM_MAX -- нарахована сума за місяць
                                                          ,
                                               ROUND (SUM (nrh.acd_sum) * 0.22,
                                                      2)
                                                   SUM_INS -- нарахована сума за місяць * 0,22 (округлення до 2 знаків після коми)
                                                          --,null                       OZN -- порожне значенн

                                                          ,
                                               nrh.pc_sc,
                                               MAX (nrh.cnt_dt_pdap)
                                                   cnt_dt_pdap
                                          FROM nrh
                                               LEFT JOIN
                                               uss_person.v_socialcard sc
                                                   ON sc.sc_id = nrh.pc_sc
                                               LEFT JOIN
                                               uss_person.v_sc_change scc
                                                   ON     scc.scc_sc = sc_id
                                                      AND scc_id = sc_scc
                                               LEFT JOIN uss_person.v_sc_identity
                                                   ON sci_id = scc_sci
                                         WHERE -- Заявник - опікун особи/дитини з інвалідністю
                                               CASE
                                                   WHEN npt_id = 21
                                                   THEN
                                                       CASE
                                                           WHEN is_work = 'T'
                                                           THEN
                                                               0 -- + ПРАЦЮЄ - ЄСВ не нараховується
                                                           WHEN     is_dia = 0
                                                                AND is_gr1 = 0
                                                           THEN
                                                               0 -- якщо інваліду вже є 18 років і це не 1 група інвалідності, тоді теж не включаємо в звіт
                                                           -- WHEN is_pens = 1 THEN 0     -- + пенсіонер за віком (60 років по даті народження) - ЄСВ не нараховується
                                                           ELSE
                                                               1
                                                       END
                                                   ELSE
                                                       1
                                               END =
                                               1
                                      GROUP BY nrh.pc_sc,
                                               sci_ln,
                                               sci_fn,
                                               sci_mn,
                                               nrh.npt_id,
                                               TRUNC (nrh.acd_start_dt, 'mm'))
                                     t
                               WHERE t.NUMIDENT IS NOT NULL) t1) t2
               WHERE t2.rn = 1
            ORDER BY 1, 10, 9;

        UPDATE uss_esr.tmp_nrh_esv
           SET sum_max = sum_total, sum_ins = ROUND (sum_total * 0.22, 2)
         WHERE 1 = 1;

        P_FILE := API$EXPORTS.GetFile (P_NNF_ID);
        ikis_sysweb_schedule.SaveAppData (P_FILE);
        TOOLS.JobSaveMessage (
               'Успішне завершення: '
            || TO_CHAR (SYSDATE, 'dd.mm.yyyy hh24:mi:ss'));
    EXCEPTION
        WHEN OTHERS
        THEN
            TOOLS.JobSaveMessage (
                   'Помилка виконання BUILD_NRH_ESV_DBF_REPORT:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END BUILD_NRH_ESV_DBF_REPORT_01;

    PROCEDURE BUILD_NRH_ESV_DBF_REPORT (                         -- IC #109475
                                        P_NNF_ID IN NUMBER, P_DT IN DATE)
    IS
        l_rep_date   DATE;
        l_org        NUMBER := tools.getcurrorg;
        l_org_to     NUMBER := tools.GetCurrOrgTo;
        l_cnt        NUMBER;
        l_me_id      NUMBER;
        P_FILE       BLOB;
    BEGIN
        TOOLS.JobSaveMessage (
               'Початок формування DBF-файла: '
            || TO_CHAR (SYSDATE, 'dd.mm.yyyy hh24:mi:ss'));
        l_rep_date := P_DT;

        IF l_rep_date IS NULL
        THEN
            raise_application_error (-20000,
                                     'Введіть дату в форматі DD.MM.YYYY');
        ELSE
            l_rep_date := TRUNC (l_rep_date, 'mm');
        END IF;

        SELECT MAX (m.me_id), COUNT (1)
          INTO l_me_id, l_cnt
          FROM uss_esr.mass_exchanges m
         WHERE     m.me_tp = 'ESV'
               AND m.me_month = l_rep_date
               AND m.com_org = l_org
               AND m.me_st = 'R';                       -- Готовий до передачі

        IF l_cnt <> 1
        THEN
            raise_application_error (-20000,
                                     'Не знайдено готовий до передачі пакет');
        END IF;


        DELETE FROM uss_esr.tmp_nrh_esv;

        INSERT INTO uss_esr.tmp_nrh_esv (period_m,
                                         period_y,
                                         ukr_gromad,
                                         numident,
                                         LN,
                                         nm,
                                         ftn,
                                         zo,
                                         start_dt,
                                         stop_dt,
                                         pay_tp,
                                         pay_mnth,
                                         pay_year,
                                         sum_total,
                                         sum_max,
                                         sum_ins,
                                         ozn)
            SELECT meur_period_m,
                   meur_period_y,
                   meur_ukr_gromad,
                   meur_numident,
                   meur_ln,
                   meur_nm,
                   meur_ftn,
                   meur_zo,
                   meur_start_dt,
                   meur_stop_dt,
                   meur_pay_tp,
                   meur_pay_mnth,
                   meur_pay_year,
                   meur_sum_total,
                   meur_sum_max,
                   meur_sum_ins,
                   meur_ozn
              FROM uss_esr.me_esv_unload_rows r
             WHERE r.meur_me = l_me_id/*
                                      -- IC #114347 треба перевіряти наявність вивантаження за цей місяць в попередні періоди
                                      AND NOT EXISTS (SELECT 1 FROM uss_esr.mass_exchanges m, uss_esr.me_esv_unload_rows rr
                                                          WHERE rr.meur_pc = r.meur_pc
                                                              AND rr.meur_me = m.me_id
                                                              AND rr.meur_pay_mnth = r.meur_pay_mnth
                                                              AND rr.meur_pay_year = r.meur_pay_year
                                                              AND m.me_id != l_me_id
                                                              AND m.me_st = 'R')
                                                              */
                                      ;

        IF SQL%ROWCOUNT = 0
        THEN
            raise_application_error (
                -20000,
                'Відсутні зафіксовані записи в пакеті обміну.');
        END IF;

        P_FILE := API$EXPORTS.GetFile (P_NNF_ID);
        ikis_sysweb_schedule.SaveAppData (P_FILE);
        TOOLS.JobSaveMessage (
               'Успішне завершення: '
            || TO_CHAR (SYSDATE, 'dd.mm.yyyy hh24:mi:ss'));
    EXCEPTION
        WHEN OTHERS
        THEN
            TOOLS.JobSaveMessage (
                   'Помилка виконання BUILD_NRH_ESV_DBF_REPORT:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END BUILD_NRH_ESV_DBF_REPORT;

    PROCEDURE START_GENERATION (p_exec VARCHAR2, P_JB_ID OUT NUMBER)
    IS
        l_jb_cnt   NUMBER;
    BEGIN
        TOOLS.SubmitSchedule (p_jb         => P_JB_ID,
                              p_subsys     => 'USS_ESR',
                              p_wjt        => 'EXP_DBF_DATA',
                              p_what       => p_exec,
                              p_nextdate   => SYSDATE);
    END START_GENERATION;

    PROCEDURE GET_DBF_REPORT (P_NNF_ID      IN     NUMBER,
                              P_IDS         IN     VARCHAR2,
                              P_DT          IN     DATE,
                              P_JBR_ID         OUT NUMBER,
                              P_FILE_NAME      OUT VARCHAR2)
    IS
        l_net_code   VARCHAR2 (10);
        l_filename   VARCHAR2 (50);
        l_org        NUMBER := tools.getcurrorg;

        l_sql        VARCHAR2 (1024);
    BEGIN
        SELECT CASE
                   WHEN t.nnf_naming_alg = 'JQ'                      -- #90202
                                                THEN 'J0510408.DBF'
                   WHEN t.nnf_naming_alg = 'JJ'                      -- #90138
                                                THEN 'J0510208.DBF'
               END                                     filename,
                  'begin uss_esr.dnet$payment_long_rep.'
               || CASE e.net_data_tp
                      WHEN 'TAX_1DF' THEN 'BUILD_TAX_1DF_DBF_REPORT('
                      WHEN 'NRH_ESV' THEN 'BUILD_NRH_ESV_DBF_REPORT('
                  END
               || P_NNF_ID
               || ', to_date('''''
               || TO_CHAR (P_DT, 'dd.mm.yyyy')
               || ''''',''''dd.mm.yyyy'''')); end;'    res
          INTO l_filename, l_sql
          FROM uss_ndi.v_ndi_net_files  t
               JOIN uss_ndi.v_ndi_export_type e ON (e.net_id = t.nnf_net)
               LEFT JOIN uss_ndi.v_ndi_acc_setup s ON (s.com_org = l_org)
         WHERE     t.nnf_id = P_NNF_ID
               AND e.net_data_tp IN ('TAX_1DF', 'NRH_ESV');

        P_FILE_NAME := l_filename;
        START_GENERATION (l_sql, P_JBR_ID);
    END GET_DBF_REPORT;

    -- IC Отримання текстового параметру документу по учаснику
    FUNCTION get_doc_string (p_app   ap_document.apd_app%TYPE,
                             p_ap    ap_document.apd_ap%TYPE,
                             p_ndt   ap_document.apd_ndt%TYPE,
                             p_nda   ap_document_attr.apda_nda%TYPE)
        RETURN VARCHAR2
    IS
        l_res   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (apda_val_string)
          INTO l_res
          FROM ap_document, ap_document_attr
         WHERE     apda_apd = apd_id
               AND ap_document.history_status = 'A'
               AND (apd_app = p_app OR p_app IS NULL) -- або шукати тільки по зверненню
               AND apd_ap = p_ap
               AND apd_ndt = p_ndt
               AND apda_nda = p_nda;

        RETURN l_res;
    END get_doc_string;

    -- IC Отримання МЗП на дату
    FUNCTION get_MZP (p_date DATE, p_type VARCHAR2:= 'min')
        RETURN NUMBER
    IS
        l_res   NUMBER;
    BEGIN
        SELECT   MAX (nmz_month_sum)
               * CASE WHEN p_type = 'max' THEN 15 ELSE 1 END -- якщо максимальна
          INTO l_res
          FROM uss_ndi.v_ndi_min_zp
         WHERE TRUNC (p_date) BETWEEN nmz_start_dt
                                  AND NVL (nmz_stop_dt,
                                           TO_DATE ('2999', 'yyyy'));

        RETURN l_res;
    END get_MZP;

    FUNCTION phone_clear (p_text IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_result   VARCHAR2 (32767) := p_text;
    BEGIN
        --l_result := regexp_replace(l_result, ',.*$', ''); --видалення другого номеру
        --l_result := regexp_replace(l_result, '[\()+ -]', ''); --видалення додаткових символів

        --видалення другого номеру
        DECLARE
            l_index   NUMBER;
        BEGIN
            l_index := INSTR (l_result, ',');

            IF l_index > 0
            THEN
                l_result := SUBSTR (l_result, 0, l_index - 1);
            END IF;
        END;

        --видалення додаткових символів
        l_result := REPLACE (l_result, '\', '');
        l_result := REPLACE (l_result, '(', '');
        l_result := REPLACE (l_result, ')', '');
        l_result := REPLACE (l_result, '+', '');
        l_result := REPLACE (l_result, '-', '');
        l_result := REPLACE (l_result, ' ', '');

        l_result := LTRIM (l_result, '38');           --прибирання коду країни

        IF LENGTH (l_result) != 10
        THEN
            RETURN NULL;
        END IF;

        RETURN l_result;
    END phone_clear;
END dnet$payment_long_rep;
/