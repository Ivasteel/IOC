/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$RPT_BENEFITS
IS
    -- Author  : BOGDAN
    -- Created : 03.06.2023 14:07:13
    -- Purpose : Звіти по пільгам
    FUNCTION sm_all (p_date    DATE,
                     p_sum1    NUMBER,
                     p_sum2    NUMBER,
                     p_sum3    NUMBER,
                     p_sum4    NUMBER,
                     p_sum5    NUMBER,
                     p_sum6    NUMBER,
                     p_sum7    NUMBER,
                     p_sum8    NUMBER,
                     p_sum9    NUMBER,
                     p_sum10   NUMBER,
                     p_sum11   NUMBER,
                     p_sum12   NUMBER)
        RETURN NUMBER;

    FUNCTION cnt_all (p_date DATE, p_period NUMBER, p_sum NUMBER)
        RETURN NUMBER;

    PROCEDURE seed_period (p_start_dt IN DATE, p_stop_dt IN DATE);

    PROCEDURE seed_BENEFIT_RECIPIENTS_CNT (p_start_dt   IN DATE,
                                           p_stop_dt    IN DATE,
                                           p_org_id     IN NUMBER);

    PROCEDURE benefit_detailed_init (p_month    IN DATE,
                                     p_org_id   IN NUMBER,
                                     p_nbc_id   IN NUMBER);

    PROCEDURE get_sc_edarp_dovidka (p_sc_id      IN     NUMBER,
                                    p_start_dt   IN     DATE,
                                    p_stop_dt    IN     DATE,
                                    p_res_doc       OUT SYS_REFCURSOR);

    PROCEDURE get_sc_moz_dovidka (p_sc_id      IN     NUMBER,
                                  p_is_error      OUT VARCHAR2,
                                  p_doc_name      OUT VARCHAR2,
                                  p_blob          OUT BLOB);

    PROCEDURE INIT_JKP_BENEFIT_TYPE_CGTP_JKP (p_start_dt   IN DATE,
                                              p_kaot_id    IN NUMBER,
                                              p_jbr_id     IN NUMBER);

    -- Надання пільг на ЖКП у розрізі житлово-комунальних послуг
    FUNCTION BENEFIT_TYPE_JPK_SQL (p_start_dt IN DATE, p_kaot_id IN NUMBER)
        RETURN SYS_REFCURSOR;

    -- Надання пільг на ЖКП у розрізі житлово-комунальних послуг
    FUNCTION BENEFIT_TYPE_JPK_SQL_TOT (p_start_dt   IN DATE,
                                       p_kaot_id    IN NUMBER)
        RETURN SYS_REFCURSOR;

    PROCEDURE reg_report (p_rt_id      IN     NUMBER,
                          p_start_dt   IN     DATE,
                          p_stop_dt    IN     DATE,
                          p_org_id     IN     NUMBER,
                          p_nbc_id     IN     NUMBER,
                          p_jbr_id        OUT DECIMAL);
END DNET$RPT_BENEFITS;
/


GRANT EXECUTE ON USS_ESR.DNET$RPT_BENEFITS TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$RPT_BENEFITS TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:50 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$RPT_BENEFITS
IS
    PROCEDURE get_kaot_info (p_kaot_id      IN     NUMBER,
                             p_lvl_filter      OUT NUMBER,
                             p_lvl_data        OUT NUMBER,
                             p_lvl_name        OUT VARCHAR2)
    IS
        l_row   uss_ndi.v_ndi_katottg%ROWTYPE;
    BEGIN
        IF (p_kaot_id IS NULL OR p_kaot_id = 0)
        THEN
            p_lvl_filter := 1;
            p_lvl_data := 1;
            p_lvl_name := 'Україна';
            RETURN;
        END IF;

        SELECT *
          INTO l_row
          FROM uss_ndi.v_ndi_katottg t
         WHERE t.kaot_id = p_kaot_id;


        p_lvl_name := 'Всього: ' || l_row.kaot_full_name;

        IF (l_row.kaot_id = l_row.kaot_kaot_l1)
        THEN
            p_lvl_filter := 1;
            p_lvl_data := 2;
        --p_lvl_name := l_row.kaot_full_name;
        ELSIF (l_row.kaot_id = l_row.kaot_kaot_l2)
        THEN
            p_lvl_filter := 2;
            p_lvl_data := 3;
        --p_lvl_name := l_row.kaot_full_name;
        ELSIF (l_row.kaot_id = l_row.kaot_kaot_l3)
        THEN
            p_lvl_filter := 3;
            p_lvl_data := 3;
        ELSIF (l_row.kaot_id = l_row.kaot_kaot_l4)
        THEN
            p_lvl_filter := 4;
            p_lvl_data := 4;
        ELSE
            p_lvl_filter := 5;
            p_lvl_data := 5;
        END IF;

        IF (l_row.kaot_tp = 'K')
        THEN
            p_lvl_filter := 1;
            p_lvl_data := 5;
        END IF;
    END;

    -- info:   Отримання коду шаблону по ідентифікатору
    -- params: p_rt_id - ідентифікатор шаблону
    -- note:
    FUNCTION get_rpt_code (p_rt_id IN rpt_templates.rt_id%TYPE)
        RETURN VARCHAR2
    IS
        v_rt_code   rpt_templates.rt_code%TYPE;
    BEGIN
        SELECT rt_code
          INTO v_rt_code
          FROM v_rpt_templates
         WHERE rt_id = p_rt_id;

        RETURN v_rt_code;
    END;

    -- info:   Отримання ідентифікатора шаблону по коду
    -- params: p_rt_code - коду шаблону
    -- note:
    FUNCTION get_rt_by_code (p_rt_code IN rpt_templates.rt_code%TYPE)
        RETURN NUMBER
    IS
        v_rt_id   rpt_templates.rt_id%TYPE;
    BEGIN
        SELECT rt_id
          INTO v_rt_id
          FROM v_rpt_templates
         WHERE rt_code = p_rt_code;

        RETURN v_rt_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    -- info:   Отримання шаблону звіту по коду
    -- params: p_rt_code - коду шаблону
    -- note:
    FUNCTION get_rpt_blob_by_code (p_rt_code rpt_templates.rt_code%TYPE)
        RETURN BLOB
    IS
        v_rt_blob   rpt_templates.rt_text%TYPE;
    BEGIN
        SELECT rt_text
          INTO v_rt_blob
          FROM v_rpt_templates
         WHERE rt_code = p_rt_code;

        RETURN v_rt_blob;
    END;

    PROCEDURE seed_period (p_start_dt IN DATE, p_stop_dt IN DATE)
    IS
    BEGIN
        DELETE FROM tmp_edarp_period;

        DELETE FROM tmp_treasury;

        INSERT INTO tmp_edarp_period (x_year, x_month)
            SELECT TO_NUMBER (TO_CHAR (dt, 'YYYY')),
                   TO_NUMBER (TO_CHAR (dt, 'MM'))
              FROM (    SELECT ADD_MONTHS (p_start_dt, LEVEL - 1)     AS dt
                          FROM DUAL
                    CONNECT BY LEVEL <=
                               MONTHS_BETWEEN (p_stop_dt + 1, p_start_dt));
    END;

    PROCEDURE seed_BENEFIT_RECIPIENTS_CNT (p_start_dt   IN DATE,
                                           p_stop_dt    IN DATE,
                                           p_org_id     IN NUMBER)
    IS
    BEGIN
        DELETE FROM tmp_edarp_period;

        seed_period (p_start_dt, p_stop_dt);

        INSERT INTO tmp_treasury (x_s1_15, x_s2_15, x_sum4_17_2)
              SELECT t.scbc_nbc                     AS nbc_id,
                     t.scbc_sc                      AS sc_id,
                     SUM (DISTINCT p.lgnac_sum)     AS sc_sum
                FROM uss_person.v_sc_benefit_category t
                     JOIN uss_person.v_x_trg tr
                         ON (    tr.trg_id = t.scbc_id
                             AND tr.trg_code = 'USS_PERSON.SC_BENEFIT_CATEGORY')
                     JOIN uss_person.v_b_katpp k
                         ON (    k.raj = tr.raj
                             AND k.r_ncardp = tr.r_ncardp
                             AND k.katp_cd = t.scbc_nbc)
                     /* join uss_person.v_b_lgp h on (h.raj = tr.raj and h.r_ncardp = tr.r_ncardp and h.LG_CDKAT = t.scbc_nbc)*/
                     JOIN uss_person.v_b_famp b
                         ON     b.raj = tr.raj
                            AND b.r_ncardp = tr.r_ncardp
                            AND b.fam_nomf = 0         -- заявник -- пільговик
                     LEFT JOIN uss_person.v_B_LGNACP p
                     JOIN uss_esr.tmp_edarp_period ep
                         ON (    ep.x_year = p.lgnac_godin
                             AND ep.x_month = p.lgnac_mecin)
                         ON (    p.raj = tr.raj
                             AND p.r_ncardp = tr.r_ncardp
                             AND p.LG_CDKAT = t.scbc_nbc /*and p.LG_CD = h.LG_CD*/
                                                        )
               WHERE     1 = 1
                     AND 1 =
                         CASE
                             WHEN p_start_dt >
                                  TO_DATE ('31.12.2022', 'DD.MM.YYYY')
                             THEN
                                 2
                             ELSE
                                 1
                         END
                     AND t.scbc_stop_dt >= p_start_dt
                     AND t.scbc_start_dt <= p_stop_dt
                     AND (katp_dte IS NULL OR katp_dte >= p_start_dt)
                     AND (LEAST (NVL (b.fam_dtexit, katp_dt), katp_dt) <=
                          p_stop_dt)
                     AND (   p_org_id = 0
                          OR     p_org_id != 0
                             AND tr.com_org IN
                                     (    SELECT org_id
                                            FROM uss_esr.v_opfu t
                                           WHERE t.org_st = 'A'
                                      CONNECT BY PRIOR t.org_id = t.org_org
                                      START WITH t.org_id = p_org_id))
            GROUP BY t.scbc_nbc, t.scbc_sc;

        INSERT INTO tmp_treasury (x_s1_15, x_s2_15, x_sum4_17_2)
              SELECT t.scp3_nbc    AS nbc_id,
                     t.scp3_sc     AS sc_id,
                     SUM (
                         CASE
                             WHEN p.x_month = 1 THEN t.scp3_sum_m1
                             WHEN p.x_month = 2 THEN t.scp3_sum_m2
                             WHEN p.x_month = 3 THEN t.scp3_sum_m3
                             WHEN p.x_month = 4 THEN t.scp3_sum_m4
                             WHEN p.x_month = 5 THEN t.scp3_sum_m5
                             WHEN p.x_month = 6 THEN t.scp3_sum_m6
                             WHEN p.x_month = 7 THEN t.scp3_sum_m7
                             WHEN p.x_month = 8 THEN t.scp3_sum_m8
                             WHEN p.x_month = 9 THEN t.scp3_sum_m9
                             WHEN p.x_month = 10 THEN t.scp3_sum_m10
                             WHEN p.x_month = 11 THEN t.scp3_sum_m11
                             WHEN p.x_month = 12 THEN t.scp3_sum_m12
                         END)      AS sc_sum
                FROM uss_person.v_sc_pfu_pay_period t
                     JOIN uss_person.v_sc_pfu_pay_summary ps
                         ON (    ps.scpp_id = t.scp3_scpp
                             AND ps.scpp_pfu_payment_tp = 'BENEFIT')
                     JOIN uss_esr.tmp_edarp_period p
                         ON (p.x_year = t.scp3_year)
               WHERE     1 = 1
                     AND 1 =
                         CASE
                             WHEN p_start_dt >
                                  TO_DATE ('31.12.2022', 'DD.MM.YYYY')
                             THEN
                                 1
                             ELSE
                                 2
                         END
                     AND (   p_org_id = 0
                          OR     p_org_id != 0
                             AND EXISTS
                                     (SELECT *
                                        FROM uss_person.v_sc_household zh
                                             JOIN uss_person.v_sc_address za
                                                 ON (za.sca_id = zh.schh_sca)
                                             JOIN uss_ndi.v_ndi_org2kaot zs
                                                 ON (zs.nok_kaot = za.sca_kaot)
                                       WHERE     zs.history_status = 'A'
                                             AND zh.schh_sc = t.scp3_sc
                                             --and to_date('01.'||to_char(x_month)||'.'||to_char(x_year), 'DD.MM.YYYY') between nvl(zs.nk2o_start_dt, to_date('01.'||to_char(x_month)||'.'||to_char(x_year), 'DD.MM.YYYY')) and nvl(nk2o_stop_dt, to_date('01.'||to_char(x_month)||'.'||to_char(x_year), 'DD.MM.YYYY'))
                                             AND zs.nok_org IN
                                                     (    SELECT org_id
                                                            FROM uss_esr.v_opfu t
                                                           WHERE t.org_st = 'A'
                                                      CONNECT BY PRIOR t.org_id =
                                                                 t.org_org
                                                      START WITH t.org_id =
                                                                 p_org_id))/*exists (select *
                                                                                        FROM uss_person.v_socialcard zc
                                                                                        JOIN uss_person.v_sc_address za ON (za.sca_sc = zc.sc_id)
                                                                                        JOIN uss_ndi.v_ndi_org2kaot zs ON (zs.nok_kaot = za.sca_kaot)
                                                                                       where za.sca_id = (select max(aa.sca_id) from uss_person.v_sc_address aa
                                                                                                           where aa.sca_sc = zc.sc_id and aa.history_status = 'A' and aa.sca_kaot is not null
                                                                                                             and aa.sca_tp in ('4') --Місце проживання, Місце проживання пільговика
                                                                                                         )
                                                                                         AND zs.history_status = 'A'
                                                                                         and zc.sc_id = t.scp3_sc
                                                                                         --and to_date('01.'||to_char(x_month)||'.'||to_char(x_year), 'DD.MM.YYYY') between nvl(zs.nk2o_start_dt, to_date('01.'||to_char(x_month)||'.'||to_char(x_year), 'DD.MM.YYYY')) and nvl(nk2o_stop_dt, to_date('01.'||to_char(x_month)||'.'||to_char(x_year), 'DD.MM.YYYY'))
                                                                                         and zs.nok_org IN (SELECT org_id
                                                                                                               FROM uss_esr.v_opfu t
                                                                                                              WHERE t.org_st = 'A'
                                                                                                            CONNECT BY PRIOR t.org_id = t.org_org
                                                                                                              START WITH t.org_id = p_org_id)
                                                                                     )*/
                                                                           )
            GROUP BY t.scp3_nbc, t.scp3_sc;
    END;

    FUNCTION BENEFIT_RECIPIENTS_CNT_R1 (p_rt_id      IN NUMBER,
                                        p_start_dt   IN DATE,
                                        p_stop_dt    IN DATE,
                                        p_org_id     IN NUMBER)
        RETURN NUMBER
    IS
        l_jbr_id     NUMBER;
        l_start_dt   DATE := TRUNC (p_start_dt, 'MM');
        l_stop_dt    DATE := ADD_MONTHS (TRUNC (p_stop_dt, 'MM'), 1) - 1;
    BEGIN
        l_jbr_id := rdm$rtfl.initreport (p_rt_id);

        rdm$rtfl.AddScript (
            l_jbr_id,
            'seed_data',
               'begin uss_esr.DNET$RPT_BENEFITS.seed_BENEFIT_RECIPIENTS_CNT(to_date('''
            || TO_CHAR (l_start_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY''),
                                           to_date('''
            || TO_CHAR (l_stop_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY''), '
            || p_org_id
            || ');
        end;');
        --tmp_treasury: nbc_Id => x_s1_15, sc_id => x_s2_15, sc_sum => x_sum4_17_2
        rdm$rtfl.AddDataSet (
            l_jbr_id,
            'ds',
            'select row_number() over (order by t.nbc_id) as rn,
              nbc_code || '' '' || nbc_name as nbc_name, --Категорія пільговика
              nbc_norm_act,
              count(distinct sc_id) AS sc_cnt,
              count(case when sc_sum is not null then 1 end) AS sc_cnt_sum,
              sum(sc_sum) as sc_sum
         from (select x_s1_15 as nbc_Id,
                      x_s2_15 as sc_id,
                      x_sum4_17_2 as sc_sum
                 from uss_esr.tmp_treasury) t
         JOIN uss_ndi.v_ndi_benefit_category c ON (c.nbc_id = t.nbc_id)
        GROUP BY t.nbc_id, nbc_code, nbc_name, nbc_norm_act
        --order by nbc_norm_act
      ');

        rdm$rtfl.AddDataSet (l_jbr_id,
                             'ds_total',
                             'select sum(sc_sum) as sc_sum,
              count(distinct sc_id) AS sc_cnt_sum1,
              count(case when sc_sum is not null then 1 end) AS sc_cnt_sum2
         from (select x_s1_15 as nbc_Id,
                      x_s2_15 as sc_id,
                      x_sum4_17_2 as sc_sum
                 from uss_esr.tmp_treasury) t
      ');

        FOR xx
            IN (SELECT (SELECT    LOWER (dic_sname)
                               || ' '
                               || TO_CHAR (l_start_dt, 'YYYY')
                          FROM uss_ndi.v_ddn_month_names z
                         WHERE z.dic_value = TO_CHAR (l_start_dt, 'MM'))
                           AS start_dt,
                       (SELECT    LOWER (dic_sname)
                               || ' '
                               || TO_CHAR (l_stop_dt, 'YYYY')
                          FROM uss_ndi.v_ddn_month_names z
                         WHERE z.dic_value = TO_CHAR (l_stop_dt, 'MM'))
                           AS stop_dt,
                       (SELECT MAX (t.org_name)
                          FROM v_opfu t
                         WHERE t.org_id = p_org_id)
                           AS org_name
                  FROM DUAL)
        LOOP
            RDM$RTFL.AddParam (l_jbr_id, 'raj', xx.org_name);
            RDM$RTFL.AddParam (l_jbr_id, 'start_dt', xx.start_dt);
            RDM$RTFL.AddParam (l_jbr_id, 'stop_dt', xx.stop_dt);
            RDM$RTFL.AddParam (l_jbr_id,
                               'gen_dt',
                               TO_CHAR (SYSDATE, 'DD.MM.YYYY'));
        END LOOP;

        rdm$rtfl.PutReportToWorkingQueue (l_jbr_id);
        RETURN l_jbr_id;
    END;

    PROCEDURE benefit_detailed_init (p_month    IN DATE,
                                     p_org_id   IN NUMBER,
                                     p_nbc_id   IN NUMBER)
    IS
        l_start_dt   DATE := TRUNC (p_month, 'MM');
        l_stop_dt    DATE := ADD_MONTHS (TRUNC (p_month, 'MM'), 1) - 1;
    BEGIN
        uss_esr.DNET$RPT_BENEFITS.seed_period (l_start_dt, l_stop_dt);

        INSERT INTO uss_person.tmp_sc_reg_info (x_sc)
            SELECT DISTINCT sc_id
              FROM (SELECT t.scbc_sc     AS sc_id
                      FROM uss_person.v_sc_benefit_category  t
                           JOIN uss_person.v_x_trg tr
                               ON (    tr.trg_id = t.scbc_id
                                   AND tr.trg_code =
                                       'USS_PERSON.SC_BENEFIT_CATEGORY')
                           JOIN uss_person.v_b_katpp k
                               ON (    k.raj = tr.raj
                                   AND k.r_ncardp = tr.r_ncardp
                                   AND k.katp_cd = t.scbc_nbc)
                           JOIN uss_person.v_b_famp b
                               ON     b.raj = tr.raj
                                  AND b.r_ncardp = tr.r_ncardp
                                  AND b.fam_nomf = 0   -- заявник -- пільговик
                     /* left join uss_person.v_B_LGNACP p
                             join uss_esr.tmp_edarp_period ep on (ep.x_year = p.lgnac_godin and ep.x_month = p.lgnac_mecin)
                               on (p.raj = tr.raj and p.r_ncardp = tr.r_ncardp and p.LG_CDKAT = t.scbc_nbc)*/
                     WHERE     1 = 1
                           AND p_month < TO_DATE ('01.01.2023', 'DD.MM.YYYY')
                           AND t.scbc_nbc = p_nbc_id
                           AND (t.scbc_stop_dt >= l_start_dt)
                           AND (t.scbc_start_dt <= l_stop_dt)
                           AND (katp_dte IS NULL OR katp_dte >= l_start_dt)
                           AND (LEAST (NVL (b.fam_dtexit, katp_dt), katp_dt) <=
                                l_stop_dt)
                           AND (   p_org_id = 0
                                OR     p_org_id IS NOT NULL
                                   AND tr.com_org IN
                                           (    SELECT org_id
                                                  FROM uss_esr.v_opfu t
                                                 WHERE t.org_st = 'A'
                                            CONNECT BY PRIOR t.org_id =
                                                       t.org_org
                                            START WITH t.org_id = p_org_id))
                    UNION ALL
                    SELECT t.scp3_sc     AS sc_id
                      FROM uss_person.v_sc_pfu_pay_period  t
                           JOIN uss_person.v_sc_pfu_pay_summary ps
                               ON (    ps.scpp_id = t.scp3_scpp
                                   AND ps.scpp_pfu_payment_tp = 'BENEFIT')
                           JOIN uss_esr.tmp_edarp_period p
                               ON (p.x_year = t.scp3_year)
                     WHERE     1 = 1
                           AND p_month > TO_DATE ('31.12.2022', 'DD.MM.YYYY')
                           AND t.scp3_nbc = p_nbc_id
                           AND (   p_org_id = 0
                                OR     p_org_id IS NOT NULL
                                   AND (/* --#91479
                                           exists (select *
                                                    from uss_person.v_sc_benefit_category zc
                                                    JOIN uss_person.v_x_trg ztr ON (ztr.trg_id = zc.scbc_id and ztr.trg_code = 'USS_PERSON.SC_BENEFIT_CATEGORY')
                                                   where zc.scbc_sc = t.scp3_sc
                                                     and ztr.com_org in (SELECT org_id
                                                                           FROM uss_esr.v_opfu zo
                                                                          WHERE zo.org_st = 'A'
                                                                        CONNECT BY PRIOR zo.org_id = zo.org_org
                                                                          START WITH zo.org_id = p_org_id)
                                                  )
                                         OR*/
                                        EXISTS
                                            (SELECT *
                                               FROM uss_person.v_socialcard
                                                    zc
                                                    JOIN
                                                    uss_person.v_sc_address
                                                    za
                                                        ON (za.sca_sc =
                                                            zc.sc_id)
                                                    JOIN
                                                    uss_ndi.v_ndi_org2kaot zs
                                                        ON (zs.nok_kaot =
                                                            za.sca_kaot)
                                              WHERE     za.sca_id =
                                                        (SELECT MAX (
                                                                    aa.sca_id)
                                                           FROM uss_person.v_sc_address
                                                                aa
                                                          WHERE     aa.sca_sc =
                                                                    zc.sc_id
                                                                AND aa.history_status =
                                                                    'A'
                                                                AND aa.sca_kaot
                                                                        IS NOT NULL
                                                                AND aa.sca_tp IN
                                                                        ( /*'2',*/
                                                                         '4') --Місце проживання, Місце проживання пільговика
                                                                             )
                                                    AND zs.history_status =
                                                        'A'
                                                    AND zc.sc_id = t.scp3_sc
                                                    --and to_date('01.'||to_char(x_month)||'.'||to_char(x_year), 'DD.MM.YYYY') between nvl(zs.nk2o_start_dt, to_date('01.'||to_char(x_month)||'.'||to_char(x_year), 'DD.MM.YYYY')) and nvl(nk2o_stop_dt, to_date('01.'||to_char(x_month)||'.'||to_char(x_year), 'DD.MM.YYYY'))
                                                    AND zs.nok_org IN
                                                            (    SELECT org_id
                                                                   FROM uss_esr.v_opfu
                                                                        t
                                                                  WHERE t.org_st =
                                                                        'A'
                                                             CONNECT BY PRIOR t.org_id =
                                                                        t.org_org
                                                             START WITH t.org_id =
                                                                        p_org_id)))));
    -- TODO: запустити логування
    END;

    FUNCTION BENEFIT_RECIPIENTS_DETAILED_R1 (p_rt_id    IN NUMBER,
                                             p_month    IN DATE,
                                             p_org_id   IN NUMBER,
                                             p_nbc_id   IN NUMBER)
        RETURN NUMBER
    IS
        l_sql        VARCHAR2 (32000);
        l_jbr_id     NUMBER;
        l_start_dt   DATE := TRUNC (p_month, 'MM');
        l_stop_dt    DATE := ADD_MONTHS (TRUNC (p_month, 'MM'), 1) - 1;
        l_year       NUMBER := EXTRACT (YEAR FROM p_month);
        l_month      NUMBER := EXTRACT (MONTH FROM p_month);
    BEGIN
        l_jbr_id := rdm$rtfl.initreport (p_rt_id);

        rdm$rtfl.AddScript (
            l_jbr_id,
            'seed_period',
               'begin uss_esr.DNET$RPT_BENEFITS.benefit_detailed_init(to_date('''
            || TO_CHAR (p_month, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY''),
                                           '
            || p_org_id
            || ', '
            || p_nbc_id
            || ');
        end;');

        rdm$rtfl.AddDataSet (
            l_jbr_id,
            'ds',
               'select nbc_code || '' - '' || nbc_name as nbc_name, --Категорія пільговика
              nbc_norm_act,
              count(distinct sc_id) AS sc_cnt,
              count(case when sc_sum is not null then 1 end) AS sc_cnt_sum,
              sum(sc_sum) as sc_sum
         from (SELECT t.scbc_nbc as nbc_id,
                      t.scbc_sc as sc_id,
                      sum(distinct p.lgnac_sum) as sc_sum
                 FROM uss_person.v_sc_benefit_category t
                 JOIN uss_person.v_x_trg tr ON (tr.trg_id = t.scbc_id and tr.trg_code = ''USS_PERSON.SC_BENEFIT_CATEGORY'')
                 join uss_person.tmp_sc_reg_info sci on (sci.x_sc = t.scbc_sc)
                 JOIN uss_person.v_b_katpp k ON (k.raj = tr.raj AND k.r_ncardp = tr.r_ncardp AND k.katp_cd = t.scbc_nbc)
                 join uss_person.v_b_famp b on b.raj = tr.raj and b.r_ncardp = tr.r_ncardp and b.fam_nomf = 0 -- заявник -- пільговик
                 left join uss_person.v_B_LGNACP p
                        join uss_esr.tmp_edarp_period ep on (ep.x_year = p.lgnac_godin and ep.x_month = p.lgnac_mecin)
                          on (p.raj = tr.raj and p.r_ncardp = tr.r_ncardp and p.LG_CDKAT = t.scbc_nbc /*and p.LG_CD = h.LG_CD*/)
              WHERE 1 = 1
                and '
            || CASE
                   WHEN p_month > TO_DATE ('31.12.2022', 'DD.MM.YYYY')
                   THEN
                       ' 1 = 2 '
                   ELSE
                       ' 1 = 1 '
               END
            || '
                and t.scbc_nbc = '
            || p_nbc_id
            || '
                AND (t.scbc_stop_dt >= to_date('''
            || TO_CHAR (l_start_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'') )
                AND (t.scbc_start_dt <= to_date('''
            || TO_CHAR (l_stop_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'') )
                AND (katp_dte is null or katp_dte >= to_date('''
            || TO_CHAR (l_start_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'') )
                AND (least(nvl(b.fam_dtexit, katp_dt), katp_dt) <= to_date('''
            || TO_CHAR (l_stop_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'') )
                '
            || CASE
                   WHEN p_org_id = 0 THEN ''
                   ELSE ' AND tr.com_org
                               IN (SELECT org_id
                                     FROM uss_esr.v_opfu t
                                    WHERE t.org_st = ''A''
                                  CONNECT BY PRIOR t.org_id = t.org_org
                                    START WITH t.org_id = ' || p_org_id || ')'
               END
            || '
              GROUP BY t.scbc_nbc, t.scbc_sc
              union all
              SELECT t.scp3_nbc as nbc_id,
                     t.scp3_sc AS sc_id,
                     SUM(CASE WHEN p.x_month = 1 THEN t.scp3_sum_m1
                              WHEN p.x_month = 2 THEN t.scp3_sum_m2
                              WHEN p.x_month = 3 THEN t.scp3_sum_m3
                              WHEN p.x_month = 4 THEN t.scp3_sum_m4
                              WHEN p.x_month = 5 THEN t.scp3_sum_m5
                              WHEN p.x_month = 6 THEN t.scp3_sum_m6
                              WHEN p.x_month = 7 THEN t.scp3_sum_m7
                              WHEN p.x_month = 8 THEN t.scp3_sum_m8
                              WHEN p.x_month = 9 THEN t.scp3_sum_m9
                              WHEN p.x_month = 10 THEN t.scp3_sum_m10
                              WHEN p.x_month = 11 THEN t.scp3_sum_m11
                              WHEN p.x_month = 12 THEN t.scp3_sum_m12
                          END) AS sc_sum
                from uss_person.v_sc_pfu_pay_period t
                JOIN uss_person.v_sc_pfu_pay_summary ps ON (ps.scpp_id = t.scp3_scpp and ps.scpp_pfu_payment_tp = ''BENEFIT'')
                join uss_person.tmp_sc_reg_info sci on (sci.x_sc = t.scp3_sc)
                JOIN uss_esr.tmp_edarp_period p ON (p.x_year = t.scp3_year)
               where 1 = 1
                and '
            || CASE
                   WHEN p_month > TO_DATE ('31.12.2022', 'DD.MM.YYYY')
                   THEN
                       ' 1 = 1 '
                   ELSE
                       ' 1 = 2 '
               END
            || '
                and t.scp3_nbc = '
            || p_nbc_id
            || '
                '
            || CASE
                   WHEN p_org_id = 0
                   THEN
                       ''
                   ELSE
                          --#91479
                          /*' and ( exists (select *
                                            from uss_person.v_sc_benefit_category zc
                                            JOIN uss_person.v_x_trg ztr ON (ztr.trg_id = zc.scbc_id and ztr.trg_code = ''USS_PERSON.SC_BENEFIT_CATEGORY'')
                                           where zc.scbc_sc = t.scp3_sc
                                             and ztr.com_org in (SELECT org_id
                                                                   FROM uss_esr.v_opfu zo
                                                                  WHERE zo.org_st = ''A''
                                                                CONNECT BY PRIOR zo.org_id = zo.org_org
                                                                  START WITH zo.org_id = ' || p_org_id || ')
                                          )
                                 or exists (select *
                                             FROM uss_person.v_socialcard zc
                                             JOIN uss_person.v_sc_address za ON (za.sca_sc = zc.sc_id)
                                             JOIN uss_ndi.v_ndi_org2kaot zs ON (zs.nok_kaot = za.sca_kaot)
                                            where za.sca_id = (select max(aa.sca_id) from uss_person.v_sc_address aa
                                                                where aa.sca_sc = zc.sc_id and aa.history_status = ''A'' and aa.sca_kaot is not null
                                                                  and aa.sca_tp in (''4'') --Місце проживання, Місце проживання пільговика
                                                              )
                                              AND zs.history_status = ''A''
                                              and zc.sc_id = t.scp3_sc
                                              --and to_date(''01.''||to_char(x_month)||''.''||to_char(x_year), ''DD.MM.YYYY'') between nvl(zs.nk2o_start_dt, to_date(''01.''||to_char(x_month)||''.''||to_char(x_year), ''DD.MM.YYYY'')) and nvl(nk2o_stop_dt, to_date(''01.''||to_char(x_month)||''.''||to_char(x_year), ''DD.MM.YYYY''))
                                              and zs.nok_org IN (SELECT org_id
                                                                    FROM uss_esr.v_opfu t
                                                                   WHERE t.org_st = ''A''
                                                                 CONNECT BY PRIOR t.org_id = t.org_org
                                                                   START WITH t.org_id = ' || p_org_id || ')
                                          )
                               )' */
                          --#91479
                          ' and exists (select *
                                        FROM uss_person.v_socialcard zc
                                        JOIN uss_person.v_sc_address za ON (za.sca_sc = zc.sc_id)
                                        JOIN uss_ndi.v_ndi_org2kaot zs ON (zs.nok_kaot = za.sca_kaot)
                                       where za.sca_id = (select max(aa.sca_id) from uss_person.v_sc_address aa
                                                           where aa.sca_sc = zc.sc_id and aa.history_status = ''A'' and aa.sca_kaot is not null
                                                             and aa.sca_tp in (/*''2'',*/ ''4'') --Місце проживання, Місце проживання пільговика
                                                         )
                                         AND zs.history_status = ''A''
                                         and zc.sc_id = t.scp3_sc
                                         -- and to_date(''01.''||to_char(x_month)||''.''||to_char(x_year), ''DD.MM.YYYY'') between nvl(zs.nk2o_start_dt, to_date(''01.''||to_char(x_month)||''.''||to_char(x_year), ''DD.MM.YYYY'')) and nvl(nk2o_stop_dt, to_date(''01.''||to_char(x_month)||''.''||to_char(x_year), ''DD.MM.YYYY''))
                                         and zs.nok_org IN (SELECT org_id
                                                               FROM uss_esr.v_opfu t
                                                              WHERE t.org_st = ''A''
                                                            CONNECT BY PRIOR t.org_id = t.org_org
                                                              START WITH t.org_id = '
                       || p_org_id
                       || ')
                                  )
                          '
               END
            || '
               GROUP BY t.scp3_nbc, t.scp3_sc
            union all
            select '
            || p_nbc_id
            || ' as nbc_id,
                   null,
                   null
            from dual
         ) t
         JOIN uss_ndi.v_ndi_benefit_category c ON (c.nbc_id = t.nbc_id)
        GROUP BY nbc_code, nbc_name, nbc_norm_act
        order by nbc_norm_act
      ');

        l_sql :=
               '
        select row_number() over (order by nlssort(pib, ''NLS_SORT=ukrainian'')) as num,
               pib,
               doc,
               rnokpp,
               pilg_name,
               termin,
               qnt,
               sum,
               addr,
               acc
          from
        (
           select  --distinct
                  to_char(b.fam_fio) as pib,
                  case when os.osoba_znach2 > 0 then LPAD(to_char(ROUND(os.osoba_znach2)),9,''0'')
                       else to_char(REPLACE(REPLACE(trim(b.fam_pasp),'' '',''''),''-'',''''))
                   end as doc,
                  to_char(b.fam_numtaxp) as rnokpp,
                  to_char(l.lgot_name) AS pilg_name, -- назва пільги
                  to_char(n.lg_dtb, ''DD.MM.YYYY'') || '' - '' || to_char(n.lg_dte, ''DD.MM.YYYY'')  as termin,
                  (select count(*) from uss_person.v_b_famp zb where zb.raj = tr.raj and zb.r_ncardp = tr.r_ncardp) as qnt,
                  lgnac_sum as sum,
                  case when (select count(*) from uss_person.v_b_katpp z where tr.raj = z.raj and tr.r_ncardp = z.r_ncardp and z.katp_cd in (1, 2, 3, 4, 11, 12, 13, 22, 23, 58, 80, 85, 86, 87, 88, 136, 137, 138, 139)) > 0
                         then to_char(trunc(tr.raj,-2) || ''; '' || tr.raj)
                       else
                          to_char(b2.klat_name) ||''; ''|| to_char(b1.klat_name) || ''; '' || to_char(r.r_index) ||''; ''|| to_char(ind.klind_adr) || ''; ''
                          || to_char(ku.klkatul_name) || '' '' || to_char(q.klul_name)|| ''; '' || nvl2(to_char(r.r_house), ''Буд. '' || to_char(r.r_house)
                          || '' '', '''') || to_char(r.r_build) || nvl2(to_char(r.r_apt), ''; кв. '' || to_char(r.r_apt), '''')
                  end AS addr,
                  to_char(n.lg_cdo) AS acc
             FROM uss_person.v_sc_benefit_category t
             JOIN uss_person.v_x_trg tr ON (tr.trg_id = t.scbc_id and tr.trg_code = ''USS_PERSON.SC_BENEFIT_CATEGORY'')
             join uss_person.tmp_sc_reg_info sci on (sci.x_sc = t.scbc_sc)
             JOIN uss_person.v_b_katpp k ON (k.raj = tr.raj AND k.r_ncardp = tr.r_ncardp AND k.katp_cd = t.scbc_nbc)
             JOIN uss_person.v_b_lgp n ON (n.raj = tr.raj and n.r_ncardp = tr.r_ncardp and n.lg_cdkat = t.scbc_nbc)
             left join uss_person.v_B_LGNACP p on (p.raj = tr.raj and p.r_ncardp = tr.r_ncardp
                                                  and p.LG_CDKAT = n.lg_cdkat and p.LG_CD = n.LG_CD
                                                  and p.lgnac_godin = '
            || l_year
            || '
                                                  and p.lgnac_mecin = '
            || l_month
            || ')

             left join uss_person.v_b_lgot l on n.lg_cd = l.lgot_code
             join uss_person.v_b_reestrlg r on n.raj = r.raj and n.r_ncardp = r.r_ncardp
             join uss_person.v_b_famp b on b.raj = r.raj and b.r_ncardp = r.r_ncardp and b.fam_nomf = 0 -- заявник -- пільговик
             left join uss_person.v_b_osobap os on os.raj = b.raj and os.r_ncardp = b.r_ncardp and os.osoba_nfam = b.fam_nomf and os.osoba_code = 50
             --addr
             left join uss_person.v_b_klul q on q.klul_codern = r.raj and q.klul_codeul = r.r_cdul
             left join uss_person.v_b_klkatul ku on ku.klkatul_code = q.klul_codekul
             left join uss_person.v_b_klat b1 on r.raj = b1.klat_code
             left join uss_person.v_b_klat b2 on trunc(r.raj,-2) = b2.klat_code
             left join uss_person.v_b_klind ind on r.r_index = ind.klind_ind
            WHERE 1 = 1
              and '
            || CASE
                   WHEN p_month > TO_DATE ('31.12.2022', 'DD.MM.YYYY')
                   THEN
                       ' 1 = 2 '
                   ELSE
                       ' 1 = 1 '
               END
            || '
              and t.scbc_nbc = '
            || p_nbc_id
            || '
              and lgnac_sum > 0  --#91022
              AND (t.scbc_stop_dt >= to_date('''
            || TO_CHAR (l_start_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'') )
              AND (t.scbc_start_dt <= to_date('''
            || TO_CHAR (l_stop_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'') )
              AND (katp_dte is null or katp_dte >= to_date('''
            || TO_CHAR (l_start_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'') )
              AND (least(nvl(b.fam_dtexit, katp_dt), katp_dt) <= to_date('''
            || TO_CHAR (l_stop_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'') )
              and (n.lg_dte is null or to_date('''
            || TO_CHAR (l_start_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'') <= n.lg_dte)
              and to_date('''
            || TO_CHAR (l_stop_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'') >= n.lg_dtb
               '
            || CASE
                   WHEN p_org_id = 0 THEN ''
                   ELSE ' AND tr.com_org
                               IN (SELECT org_id
                                     FROM uss_esr.v_opfu t
                                    WHERE t.org_st = ''A''
                                  CONNECT BY PRIOR t.org_id = t.org_org
                                    START WITH t.org_id = ' || p_org_id || ')'
               END
            || '

            union all
              SELECT uss_person.api$sc_tools.GET_PIB(t.scp3_sc) as pib,
                     uss_person.api$sc_tools.get_doc_num(t.scp3_sc) as doc,
                     uss_person.api$sc_tools.get_numident(t.scp3_sc) as rnokpp,
                     pt.nppt_name as pilg_name,
                     to_char(ps.scpp_pfu_pd_start_dt , ''DD.MM.YYYY'') || '' - '' || to_char(ps.scpp_pfu_pd_stop_dt , ''DD.MM.YYYY'') as termin,
                     1 as qnt,
                     CASE WHEN '
            || l_month
            || ' = 1 THEN t.scp3_sum_m1
                          WHEN '
            || l_month
            || ' = 2 THEN t.scp3_sum_m2
                          WHEN '
            || l_month
            || ' = 3 THEN t.scp3_sum_m3
                          WHEN '
            || l_month
            || ' = 4 THEN t.scp3_sum_m4
                          WHEN '
            || l_month
            || ' = 5 THEN t.scp3_sum_m5
                          WHEN '
            || l_month
            || ' = 6 THEN t.scp3_sum_m6
                          WHEN '
            || l_month
            || ' = 7 THEN t.scp3_sum_m7
                          WHEN '
            || l_month
            || ' = 8 THEN t.scp3_sum_m8
                          WHEN '
            || l_month
            || ' = 9 THEN t.scp3_sum_m9
                          WHEN '
            || l_month
            || ' = 10 THEN t.scp3_sum_m10
                          WHEN '
            || l_month
            || ' = 11 THEN t.scp3_sum_m11
                          WHEN '
            || l_month
            || ' = 12 THEN t.scp3_sum_m12
                     end AS sum,
                     case when (select count(*) from uss_person.v_sc_pfu_pay_period z where z.scp3_sc = t.scp3_sc and z.scp3_nbc in (1, 2, 3, 4, 11, 12, 13, 22, 23, 58, 80, 85, 86, 87, 88, 136, 137, 138, 139)) > 0 then
                               (select to_char(max(zs.nok_org))
                                  FROM uss_person.v_socialcard zc
                                  JOIN uss_person.v_sc_address za ON (za.sca_sc = zc.sc_id)
                                  JOIN uss_ndi.v_ndi_org2kaot zs ON (zs.nok_kaot = za.sca_kaot)
                                 where za.sca_id = (select max(aa.sca_id) from uss_person.v_sc_address aa
                                                     where aa.sca_sc = zc.sc_id and aa.history_status = ''A'' and aa.sca_kaot is not null
                                                       and aa.sca_tp in (/*''2'',*/ ''4'') --Місце проживання, Місце проживання пільговика
                                                   )
                                   AND zs.history_status = ''A''
                                   and zc.sc_id = t.scp3_sc
                                   --and to_date(''01.'
            || l_month
            || '.'
            || l_year
            || ''', ''DD.MM.YYYY'') between nvl(zs.nk2o_start_dt, to_date(''01.'
            || l_month
            || '.'
            || l_year
            || ''', ''DD.MM.YYYY'')) and nvl(nk2o_stop_dt, to_date(''01.'
            || l_month
            || '.'
            || l_year
            || ''', ''DD.MM.YYYY''))
                               )
                          else nvl(uss_person.api$sc_tools.get_address(t.scp3_sc, ''4''), uss_person.api$sc_tools.get_address(t.scp3_sc, ''2''))
                      end as addr,
                     null as acc
                from uss_person.v_sc_pfu_pay_period t
                join uss_person.tmp_sc_reg_info sci on (sci.x_sc = t.scp3_sc)
                JOIN uss_person.v_sc_pfu_pay_summary ps ON (ps.scpp_id = t.scp3_scpp and ps.scpp_pfu_payment_tp = ''BENEFIT'')
                join uss_ndi.v_ndi_pfu_payment_type pt on (pt.nppt_id = t.scp3_nppt)
               where 1 = 1
                 and '
            || CASE
                   WHEN p_month > TO_DATE ('31.12.2022', 'DD.MM.YYYY')
                   THEN
                       ' 1 = 1 '
                   ELSE
                       ' 1 = 2 '
               END
            || '
                 and t.scp3_year = '
            || l_year
            || '
                 and t.scp3_nbc = '
            || p_nbc_id
            || '
                '
            || CASE
                   WHEN p_org_id = 0
                   THEN
                       ''
                   ELSE
                          /* #91479
                           ' and ( exists (select *
                                          from uss_person.v_sc_benefit_category zc
                                          JOIN uss_person.v_x_trg ztr ON (ztr.trg_id = zc.scbc_id and ztr.trg_code = ''USS_PERSON.SC_BENEFIT_CATEGORY'')
                                         where zc.scbc_sc = t.scp3_sc
                                           and ztr.com_org in (SELECT org_id
                                                                 FROM uss_esr.v_opfu zo
                                                                WHERE zo.org_st = ''A''
                                                              CONNECT BY PRIOR zo.org_id = zo.org_org
                                                                START WITH zo.org_id = ' || p_org_id || ')
                                        )
                             or exists (select *
                                           FROM uss_person.v_socialcard zc
                                           JOIN uss_person.v_sc_address za ON (za.sca_sc = zc.sc_id)
                                           JOIN uss_ndi.v_ndi_org2kaot zs ON (zs.nok_kaot = za.sca_kaot)
                                          where za.sca_id = (select max(aa.sca_id) from uss_person.v_sc_address aa
                                                              where aa.sca_sc = zc.sc_id and aa.history_status = ''A'' and aa.sca_kaot is not null
                                                                and aa.sca_tp in ( ''4'') --Місце проживання, Місце проживання пільговика
                                                            )
                                            AND zs.history_status = ''A''
                                            and zc.sc_id = t.scp3_sc
                                            -- and to_date(''01.' || l_month || '.' || l_year || ''', ''DD.MM.YYYY'') between nvl(zs.nk2o_start_dt, to_date(''01.' || l_month || '.' || l_year || ''', ''DD.MM.YYYY'')) and nvl(nk2o_stop_dt, to_date(''01.' || l_month || '.' || l_year || ''', ''DD.MM.YYYY''))
                                            and zs.nok_org IN (SELECT org_id
                                                                  FROM uss_esr.v_opfu t
                                                                 WHERE t.org_st = ''A''
                                                               CONNECT BY PRIOR t.org_id = t.org_org
                                                                 START WITH t.org_id = ' || p_org_id || ')
                                        )
                               )' */
                          --#91479 дивимось тільки у дані Пенсійного фонду
                          ' and exists (select *
                                        FROM uss_person.v_socialcard zc
                                        JOIN uss_person.v_sc_address za ON (za.sca_sc = zc.sc_id)
                                        JOIN uss_ndi.v_ndi_org2kaot zs ON (zs.nok_kaot = za.sca_kaot)
                                       where za.sca_id = (select max(aa.sca_id) from uss_person.v_sc_address aa
                                                           where aa.sca_sc = zc.sc_id and aa.history_status = ''A'' and aa.sca_kaot is not null
                                                             and aa.sca_tp in ( ''4'') --Місце проживання, Місце проживання пільговика
                                                         )
                                         AND zs.history_status = ''A''
                                         and zc.sc_id = t.scp3_sc
                                         -- and to_date(''01.'
                       || l_month
                       || '.'
                       || l_year
                       || ''', ''DD.MM.YYYY'') between nvl(zs.nk2o_start_dt, to_date(''01.'
                       || l_month
                       || '.'
                       || l_year
                       || ''', ''DD.MM.YYYY'')) and nvl(nk2o_stop_dt, to_date(''01.'
                       || l_month
                       || '.'
                       || l_year
                       || ''', ''DD.MM.YYYY''))
                                         and zs.nok_org IN (SELECT org_id
                                                               FROM uss_esr.v_opfu t
                                                              WHERE t.org_st = ''A''
                                                            CONNECT BY PRIOR t.org_id = t.org_org
                                                              START WITH t.org_id = '
                       || p_org_id
                       || ')
                                     )
                        '
               END
            || '
        ) where sum > 0 --#91022
        --order by pib
     ';


        rdm$rtfl.adddataset (l_jbr_id, 'ds_main', l_sql);


        FOR xx
            IN (SELECT (SELECT    LOWER (dic_sname)
                               || ' '
                               || TO_CHAR (l_start_dt, 'YYYY')
                          FROM uss_ndi.v_ddn_month_names z
                         WHERE z.dic_value = TO_CHAR (l_start_dt, 'MM'))
                           AS start_dt,
                       (SELECT    LOWER (dic_sname)
                               || ' '
                               || TO_CHAR (l_stop_dt, 'YYYY')
                          FROM uss_ndi.v_ddn_month_names z
                         WHERE z.dic_value = TO_CHAR (l_stop_dt, 'MM'))
                           AS stop_dt,
                       (SELECT MAX (t.org_name)
                          FROM v_opfu t
                         WHERE t.org_id = p_org_id)
                           AS org_name
                  FROM DUAL)
        LOOP
            RDM$RTFL.AddParam (l_jbr_id, 'raj', xx.org_name);
            RDM$RTFL.AddParam (l_jbr_id, 'start_dt', xx.start_dt);
            RDM$RTFL.AddParam (l_jbr_id, 'stop_dt', xx.stop_dt);
            RDM$RTFL.AddParam (l_jbr_id,
                               'gen_dt',
                               TO_CHAR (SYSDATE, 'DD.MM.YYYY'));
        END LOOP;

        rdm$rtfl.PutReportToWorkingQueue (l_jbr_id);
        RETURN l_jbr_id;
    END;

    FUNCTION BENEFIT_GAS_INFO_R1 (p_rt_id     IN NUMBER,
                                  p_dt        IN DATE,
                                  p_kaot_id   IN NUMBER)
        RETURN NUMBER
    IS
        l_jbr_id       NUMBER;
        l_monthn       NUMBER := EXTRACT (MONTH FROM p_dt);
        l_month        VARCHAR2 (10) := TO_CHAR (p_dt, 'MM');
        l_year         VARCHAR2 (10) := TO_CHAR (p_dt, 'YYYY');
        --l_org_to NUMBER;
        l_level        NUMBER;
        l_level_data   NUMBER;
        l_level_name   VARCHAR2 (500);
    BEGIN
        l_jbr_id :=
            rdm$rtfl.initreport (
                p_rt_id,
                p_rpt_name   => 'Пільги_тариф_за_викл_опалення_газом_');
        rdm$rtfl.SetFileName (
            l_jbr_id,
               'Пільги_тариф_за_викл_опалення_газом'
            || '_'
            || TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS')
            || '.XLS');

        get_kaot_info (p_kaot_id,
                       l_level,
                       l_level_data,
                       l_level_name);

        IF (    EXTRACT (YEAR FROM p_dt) < 2023
            AND (p_kaot_id IS NULL OR p_kaot_id = 0))
        THEN
            rdm$rtfl.AddDataSet (
                l_jbr_id,
                'ds',
                   'with edarp_dat as ( SELECT distinct b.dic_name as Region,
                                   bc.scbc_sc as sc_id,
                                   t.TAR_COST as tarif
                              FROM uss_person.v_x_trg tr
                              join uss_person.v_sc_benefit_category bc on (bc.scbc_id = tr.TRG_ID and tr.trg_code = ''USS_PERSON.SC_BENEFIT_CATEGORY'')
                              join uss_person.v_b_famp b1 on b1.raj = tr.raj and b1.r_ncardp = tr.r_ncardp and b1.fam_nomf = 0 -- заявник -- пільговик
                              join uss_ndi.V_DDN_EDARP_RAJ_OBL b on (b.dic_value = substr(lpad(tr.raj, 4, ''0''), 1, 2))
                              join uss_person.v_b_lgp l on (l.RAJ = tr.RAJ and l.R_NCARDP = tr.R_NCARDP)
                              join uss_person.v_b_tarif t on (l.raj = t.raj and l.lg_cd = t.tar_cdplg and l.lg_paydservcd = t.tar_serv
                                                              and l.lg_paysys= t.tar_code and trunc(sysdate) between t.tar_dateb and t.tar_datee)
                              join uss_person.v_b_lgnacp h on (L.raj = h.raj and L.r_ncardp = h.r_ncardp and L.lg_cdkat = h.lg_cdkat and l.lg_cd = h.lg_cd and l.lg_dtb = h.lg_dtb)
                            where 1 = 1
                              and h.LGNAC_GOD = '
                || TO_CHAR (p_dt, 'YYYY')
                || '
                              and h.LGNAC_MEC = '
                || l_monthn
                || '
                              and to_date('''
                || TO_CHAR (p_dt, 'DD.MM.YYYY')
                || ''', ''DD.MM.YYYY'') between l.LG_DTB and l.LG_DTE
                              and l.LG_CD in (5031)
                              /*та не включає послугу 5032 (газопостачання на опалення)*/
                              and not exists (select *
                                               from uss_person.v_b_lgp z
                                              where z.RAJ = tr.RAJ and z.R_NCARDP = tr.R_NCARDP
                                                and z.LG_CD in (5032)
                                             )
                          ),
             res as (select 1 + row_number() over (order by DECODE(region, ''невизначено або відсутні дані'', 9999, 0), nlssort(region, ''NLS_SORT=ukrainian'')) as rn,
                            region AS col_2,
                            COUNT(distinct t.sc_id) AS col_3,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif <= 7 THEN t.sc_id END) AS col_4,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 7 AND t.tarif <= 8 THEN t.sc_id END) AS col_5,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 8 AND t.tarif <= 9 THEN t.sc_id END) AS col_6,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 9 AND t.tarif <= 10 THEN t.sc_id END) AS col_7,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 10 AND t.tarif <= 11 THEN t.sc_id END) AS col_8,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 11 AND t.tarif <= 12 THEN t.sc_id END) AS col_9,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 12 AND t.tarif <= 13 THEN t.sc_id END) AS col_10,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 13 THEN t.sc_id END) AS col_11
                       from (select *
                               from edarp_dat
                             ) t
                      GROUP BY region
                      ORDER BY region
                     )
             select rn,
                    col_2,     -- Назва адміністративно-територіальної одиниці
                    col_3,     -- Всього (Кількість пільговиків, які користуються пільгою на оплату послуги;з постачання природного газу за ціною на природний газ для населення; у розмірі грн. за метр куб. з ПДВ)
                    col_4,     -- менше 7,00
                    col_5,     -- 7,01-8,00
                    col_6,     -- 8,01-9,00
                    col_7,     -- 9,01-10,00
                    col_8,     -- 10,01-11,00
                    col_9,     -- 11,01-12,00
                    col_10,    -- 12,01-13,00
                    col_11     -- більше 13,00
               from
             (select rn,
                     case when (lower(col_2)) = ''київ'' then ''м. '' || initCap(col_2)
                          when col_2 is not null then initCap(col_2) || '' обл.''
                     end as col_2,
                     col_3,
                     col_4,
                     col_5,
                     col_6,
                     col_7,
                     col_8,
                     col_9,
                     col_10,
                     col_11
                from res t
               union all
               select 1,
                      ''УКРАЇНА'',
                      sum(col_3),
                      sum(col_4),
                      sum(col_5),
                      sum(col_6),
                      sum(col_7),
                      sum(col_8),
                      sum(col_9),
                      sum(col_10),
                      sum(col_11)
                from res t
             )
                order by rn
      ');
        ELSE
            rdm$rtfl.AddDataSet (
                l_jbr_id,
                'ds',
                   'with dat1 as (select nvl(kd.kaot_full_name, ''невизначено або відсутні дані'') as x_Region,
                            ps.scpp_sc as sc_id,
                            7.96 AS x_Tarif
                       from uss_person.v_sc_pfu_pay_period t
                       JOIN uss_person.v_sc_pfu_pay_summary ps ON (ps.scpp_id = t.scp3_scpp and ps.scpp_pfu_payment_tp = ''BENEFIT'')
                       join uss_ndi.v_ndi_pfu_payment_type pt on (pt.nppt_id = t.scp3_nppt)
                       join uss_person.v_sc_household h on (h.schh_id = ps.scpp_schh)
                       join uss_person.v_sc_address adr on (adr.sca_id = h.schh_sca)
                       JOIN uss_ndi.v_ndi_katottg k on (k.kaot_id = adr.sca_kaot )
                       JOIN uss_ndi.v_ndi_katottg km on (km.kaot_id = k.kaot_kaot_l'
                || l_level
                || ' )
                       left JOIN uss_ndi.v_ndi_katottg kd on (kd.kaot_id = k.kaot_kaot_l'
                || l_level_data
                || ' )
                      where 1 = 1
                        /*and adr.sca_tp = ''4''
                        and adr.history_status = ''A''*/
                        and scpp_pfu_pd_st not in (''PS'', ''V'')
                        and to_date('''
                || TO_CHAR (p_dt, 'DD.MM.YYYY')
                || ''', ''DD.MM.YYYY'')  between scpp_pfu_pd_start_dt and scpp_pfu_pd_stop_dt
                        and t.scp3_year = '
                || TO_CHAR (p_dt, 'YYYY')
                || '
                        and t.scp3_sum_m'
                || l_monthn
                || ' > 0 /*is not null*/
                        '
                || CASE
                       WHEN p_kaot_id IS NOT NULL AND p_kaot_id != 0
                       THEN
                           ' and km.kaot_id = ' || p_kaot_id
                   END
                || '
                        and pt.nppt_id in (10202, 10203)
                        /*та не включає послугу 10201 (газопостачання природного газу: на опалення)*/
                        and not exists (select *
                                         from uss_person.v_sc_pfu_pay_period z
                                         JOIN uss_person.v_sc_pfu_pay_summary zs ON (zs.scpp_id = z.scp3_scpp and zs.scpp_pfu_payment_tp = ''BENEFIT'')
                                        where z.scp3_year = '
                || TO_CHAR (p_dt, 'YYYY')
                || '
                                          and z.scp3_nppt in (10201)
                                          and zs.scpp_sc = ps.scpp_Sc)
                     ),
             dat2 as (select nvl(kd.kaot_full_name, ''невизначено або відсутні дані'') as x_Region,
                            ps.scpp_sc as sc_id,
                            (SELECT MAX(scpd_tariff_sum)
                               FROM uss_person.v_sc_scpp_detail d
                              WHERE d.scpd_scpp = ps.scpp_id
                                AND d.scpd_nppt = a.scpc_nppt
                                AND to_date('''
                || TO_CHAR (p_dt, 'DD.MM.YYYY')
                || ''', ''DD.MM.YYYY'') between d.scpd_start_dt and d.scpd_stop_dt) AS x_Tarif
                       FROM uss_person.v_sc_pfu_pay_summary ps
                       JOIN uss_person.v_sc_pfu_accrual a ON a.scpc_scpp = ps.scpp_id AND a.history_status = ''A''
                       join uss_ndi.v_ndi_pfu_payment_type pt on pt.nppt_id = a.scpc_nppt
                       join uss_person.v_sc_household h on h.schh_id = ps.scpp_schh
                       join uss_person.v_sc_address adr on adr.sca_id = h.schh_sca
                       JOIN uss_ndi.v_ndi_katottg k on k.kaot_id = adr.sca_kaot
                       JOIN uss_ndi.v_ndi_katottg km on (km.kaot_id = k.kaot_kaot_l'
                || l_level
                || ' )
                       left JOIN uss_ndi.v_ndi_katottg kd on (kd.kaot_id = k.kaot_kaot_l'
                || l_level_data
                || ' )
                      where 1 = 1
                        AND ps.scpp_pfu_payment_tp = ''BENEFIT''
                        and scpp_pfu_pd_st NOT IN (''PS'', ''V'')
                        and to_date('''
                || TO_CHAR (p_dt, 'DD.MM.YYYY')
                || ''', ''DD.MM.YYYY'') between scpp_pfu_pd_start_dt and scpp_pfu_pd_stop_dt
                        AND to_date('''
                || TO_CHAR (p_dt, 'DD.MM.YYYY')
                || ''', ''DD.MM.YYYY'') = scpc_acd_dt
                        AND a.scpc_acd_sum > 0
                        '
                || CASE
                       WHEN p_kaot_id IS NOT NULL AND p_kaot_id != 0
                       THEN
                           ' and km.kaot_id = ' || p_kaot_id
                   END
                || '
                        and pt.nppt_id in (10202, 10203)
                        /*та не включає послугу 10201 (газопостачання природного газу: на опалення) у СРКО*/
                        and not exists (select *
                                         from uss_person.v_sc_scpp_detail z
                                         JOIN uss_person.v_sc_pfu_pay_summary zs ON (zs.scpp_id = z.scpd_scpp and zs.scpp_pfu_payment_tp = ''BENEFIT'')
                                        where to_date('''
                || TO_CHAR (p_dt, 'DD.MM.YYYY')
                || ''', ''DD.MM.YYYY'') between z.scpd_start_dt and z.scpd_stop_dt
                                          and z.scpd_nppt in (10201)
                                          and zs.scpp_sc = ps.scpp_Sc)
                     ),
             res as (select 1 + row_number() over (order by DECODE(x_Region, ''невизначено або відсутні дані'', 9999, 0), nlssort(x_Region, ''NLS_SORT=ukrainian'')) as rn,
                            x_Region AS col_2,
                            COUNT(distinct t.sc_id) AS col_3,
                            COUNT(distinct CASE WHEN t.x_Tarif IS NOT NULL AND t.x_Tarif <= 7 THEN t.sc_id END) AS col_4,
                            COUNT(distinct CASE WHEN t.x_Tarif IS NOT NULL AND t.x_Tarif > 7 AND t.x_Tarif <= 8 THEN t.sc_id END) AS col_5,
                            COUNT(distinct CASE WHEN t.x_Tarif IS NOT NULL AND t.x_Tarif > 8 AND t.x_Tarif <= 9 THEN t.sc_id END) AS col_6,
                            COUNT(distinct CASE WHEN t.x_Tarif IS NOT NULL AND t.x_Tarif > 9 AND t.x_Tarif <= 10 THEN t.sc_id END) AS col_7,
                            COUNT(distinct CASE WHEN t.x_Tarif IS NOT NULL AND t.x_Tarif > 10 AND t.x_Tarif <= 11 THEN t.sc_id END) AS col_8,
                            COUNT(distinct CASE WHEN t.x_Tarif IS NOT NULL AND t.x_Tarif > 11 AND t.x_Tarif <= 12 THEN t.sc_id END) AS col_9,
                            COUNT(distinct CASE WHEN t.x_Tarif IS NOT NULL AND t.x_Tarif > 12 AND t.x_Tarif <= 13 THEN t.sc_id END) AS col_10,
                            COUNT(distinct CASE WHEN t.x_Tarif IS NOT NULL AND t.x_Tarif > 13 THEN t.sc_id END) AS col_11
                       FROM (SELECT x_Region, sc_id, x_Tarif FROM dat1
                              UNION ALL
                             SELECT x_Region, sc_id, x_Tarif FROM dat2) t
                      GROUP BY x_Region
                      ORDER BY x_Region
                     )
             select rn,
                    col_2,     -- Назва адміністративно-територіальної одиниці
                    col_3,     -- Всього (Кількість пільговиків, які користуються пільгою на оплату послуги;з постачання природного газу за ціною на природний газ для населення; у розмірі грн. за метр куб. з ПДВ)
                    col_4,     -- менше 7,00
                    col_5,     -- 7,01-8,00
                    col_6,     -- 8,01-9,00
                    col_7,     -- 9,01-10,00
                    col_8,     -- 10,01-11,00
                    col_9,     -- 11,01-12,00
                    col_10,    -- 12,01-13,00
                    col_11     -- більше 13,00
               from
             (select rn,
                     (col_2) as col_2,
                     col_3,
                     col_4,
                     col_5,
                     col_6,
                     col_7,
                     col_8,
                     col_9,
                     col_10,
                     col_11
                from res t
              union all
               select 1,
                      '''
                || l_level_name
                || ''',
                      sum(col_3),
                      sum(col_4),
                      sum(col_5),
                      sum(col_6),
                      sum(col_7),
                      sum(col_8),
                      sum(col_9),
                      sum(col_10),
                      sum(col_11)
                from res t
             )
                order by rn
      ');
        END IF;


        FOR xx IN (SELECT (SELECT LOWER (dic_name)
                             FROM uss_ndi.v_ddn_month_names z
                            WHERE z.dic_value = TO_CHAR (p_dt, 'MM'))    AS month_dt
                     FROM DUAL)
        LOOP
            RDM$RTFL.AddParam (l_jbr_id, 'month', xx.month_dt);
            RDM$RTFL.AddParam (l_jbr_id, 'year', TO_CHAR (p_dt, 'YYYY'));
            RDM$RTFL.AddParam (l_jbr_id,
                               'gen_dt',
                               TO_CHAR (SYSDATE, 'DD.MM.YYYY'));
        END LOOP;

        rdm$rtfl.PutReportToWorkingQueue (l_jbr_id);
        RETURN l_jbr_id;
    END;

    FUNCTION BENEFIT_GAS_INFO_R2 (p_rt_id     IN NUMBER,
                                  p_dt        IN DATE,
                                  p_kaot_id   IN NUMBER)
        RETURN NUMBER
    IS
        l_jbr_id       NUMBER;
        l_monthn       NUMBER := EXTRACT (MONTH FROM p_dt);
        l_month        VARCHAR2 (10) := TO_CHAR (p_dt, 'MM');
        l_year         VARCHAR2 (10) := TO_CHAR (p_dt, 'YYYY');
        --l_org_to NUMBER;
        l_level        NUMBER;
        l_level_data   NUMBER;
        l_level_name   VARCHAR2 (500);
    BEGIN
        l_jbr_id :=
            rdm$rtfl.initreport (
                p_rt_id,
                p_rpt_name   => 'Пільги_тариф_включ_опалення_газом');
        rdm$rtfl.SetFileName (
            l_jbr_id,
               'Пільги_тариф_включ_опалення_газом'
            || '_'
            || TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS')
            || '.XLS');

        get_kaot_info (p_kaot_id,
                       l_level,
                       l_level_data,
                       l_level_name);

        IF (    EXTRACT (YEAR FROM p_dt) < 2023
            AND (p_kaot_id IS NULL OR p_kaot_id = 0))
        THEN
            rdm$rtfl.AddDataSet (
                l_jbr_id,
                'ds',
                   'with edarp_dat as ( SELECT distinct b.dic_name as Region,
                                   bc.scbc_sc as sc_id,
                                   t.TAR_COST as tarif
                              FROM uss_person.v_x_trg tr
                              join uss_person.v_sc_benefit_category bc on (bc.scbc_id = tr.TRG_ID and tr.trg_code = ''USS_PERSON.SC_BENEFIT_CATEGORY'')
                              join uss_person.v_b_famp b1 on b1.raj = tr.raj and b1.r_ncardp = tr.r_ncardp and b1.fam_nomf = 0 -- заявник -- пільговик
                              join uss_ndi.V_DDN_EDARP_RAJ_OBL b on (b.dic_value = substr(lpad(tr.raj, 4, ''0''), 1, 2))
                              join uss_person.v_b_lgp l on (l.RAJ = tr.RAJ and l.R_NCARDP = tr.R_NCARDP)
                              join uss_person.v_b_tarif t on (l.raj = t.raj and l.lg_cd = t.tar_cdplg and l.lg_paydservcd = t.tar_serv
                                                              and l.lg_paysys= t.tar_code and trunc(sysdate) between t.tar_dateb and t.tar_datee)
                              join uss_person.v_b_lgnacp h on (L.raj = h.raj and L.r_ncardp = h.r_ncardp and L.lg_cdkat = h.lg_cdkat and l.lg_cd = h.lg_cd and l.lg_dtb = h.lg_dtb)
                            where 1 = 1
                              and h.LGNAC_GOD = '
                || TO_CHAR (p_dt, 'YYYY')
                || '
                              and h.LGNAC_MEC = '
                || l_monthn
                || '
                              and to_date('''
                || TO_CHAR (p_dt, 'DD.MM.YYYY')
                || ''', ''DD.MM.YYYY'') between l.LG_DTB and l.LG_DTE
                              and l.LG_CD in (5032)
                          ),
             res as (select 1 + row_number() over (order by DECODE(region, ''невизначено або відсутні дані'', 9999, 0), nlssort(region, ''NLS_SORT=ukrainian'')) as rn,
                            region AS col_2,
                            COUNT(distinct t.sc_id) AS col_3,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif <= 7 THEN t.sc_id END) AS col_4,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 7 AND t.tarif <= 8 THEN t.sc_id END) AS col_5,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 8 AND t.tarif <= 9 THEN t.sc_id END) AS col_6,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 9 AND t.tarif <= 10 THEN t.sc_id END) AS col_7,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 10 AND t.tarif <= 11 THEN t.sc_id END) AS col_8,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 11 AND t.tarif <= 12 THEN t.sc_id END) AS col_9,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 12 AND t.tarif <= 13 THEN t.sc_id END) AS col_10,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 13 THEN t.sc_id END) AS col_11
                       from (select *
                               from edarp_dat
                             ) t
                      GROUP BY region
                      ORDER BY region
                     )
             select rn,
                    col_2,     -- Назва адміністративно-територіальної одиниці
                    col_3,     -- Всього (Кількість пільговиків, які користуються пільгою на оплату послуги;з постачання природного газу за ціною на природний газ для населення;у розмірі грн. за метр куб. з ПДВ)
                    col_4,     -- менше 7,00
                    col_5,     -- 7,01-8,00
                    col_6,     -- 8,01-9,00
                    col_7,     -- 9,01-10,00
                    col_8,     -- 10,01-11,00
                    col_9,     -- 11,01-12,00
                    col_10,    -- 12,01-13,00
                    col_11     -- більше 13,00
               from
             (select rn,
                     case when (lower(col_2)) = ''київ'' then ''м. '' || initCap(col_2)
                          when col_2 is not null then initCap(col_2) || '' обл.''
                     end as col_2,
                     col_3,
                     col_4,
                     col_5,
                     col_6,
                     col_7,
                     col_8,
                     col_9,
                     col_10,
                     col_11
                from res t
               union all
               select 1,
                      ''УКРАЇНА'',
                      sum(col_3),
                      sum(col_4),
                      sum(col_5),
                      sum(col_6),
                      sum(col_7),
                      sum(col_8),
                      sum(col_9),
                      sum(col_10),
                      sum(col_11)
                from res t
             )
                order by rn
      ');
        ELSE
            rdm$rtfl.AddDataSet (
                l_jbr_id,
                'ds',
                   'with dat as (select nvl(kd.kaot_full_name, ''невизначено або відсутні дані'') as x_Region,
                            ps.scpp_sc as sc_id,
                            7.96 as x_Tarif
                       from uss_person.v_sc_pfu_pay_period t
                       JOIN uss_person.v_sc_pfu_pay_summary ps ON (ps.scpp_id = t.scp3_scpp and ps.scpp_pfu_payment_tp = ''BENEFIT'')
                       join uss_ndi.v_ndi_pfu_payment_type pt on (pt.nppt_id = t.scp3_nppt)
                       join uss_person.v_sc_household h on (h.schh_id = ps.scpp_schh)
                       join uss_person.v_sc_address adr on (adr.sca_id = h.schh_sca/*adr.sca_sc = t.scp3_sc*/)
                       JOIN uss_ndi.v_ndi_katottg k on (k.kaot_id = adr.sca_kaot )
                       JOIN uss_ndi.v_ndi_katottg km on (km.kaot_id = k.kaot_kaot_l'
                || l_level
                || ' )
                       left JOIN uss_ndi.v_ndi_katottg kd on (kd.kaot_id = k.kaot_kaot_l'
                || l_level_data
                || ' )
                      where 1 = 1
                        /*and adr.sca_tp = ''4''
                        and adr.history_status = ''A''*/
                        and scpp_pfu_pd_st not in (''PS'', ''V'')
                        and to_date('''
                || TO_CHAR (p_dt, 'DD.MM.YYYY')
                || ''', ''DD.MM.YYYY'')  between scpp_pfu_pd_start_dt and scpp_pfu_pd_stop_dt
                        and t.scp3_year = '
                || TO_CHAR (p_dt, 'YYYY')
                || '
                        and t.scp3_sum_m'
                || l_monthn
                || ' > 0'
                || CASE
                       WHEN p_kaot_id IS NOT NULL AND p_kaot_id != 0
                       THEN
                           ' and km.kaot_id = ' || p_kaot_id
                   END
                || '
                        and pt.nppt_id in (10201)
                     ),,
             dat2 as (select nvl(kd.kaot_full_name, ''невизначено або відсутні дані'') as x_Region,
                            ps.scpp_sc as sc_id,
                            (SELECT MAX(scpd_tariff_sum)
                               FROM uss_person.v_sc_scpp_detail d
                              WHERE d.scpd_scpp = ps.scpp_id
                                AND d.scpd_nppt = a.scpc_nppt
                                AND to_date('''
                || TO_CHAR (p_dt, 'DD.MM.YYYY')
                || ''', ''DD.MM.YYYY'') between d.scpd_start_dt and d.scpd_stop_dt) AS x_Tarif
                       FROM uss_person.v_sc_pfu_pay_summary ps
                       JOIN uss_person.v_sc_pfu_accrual a ON a.scpc_scpp = ps.scpp_id AND a.history_status = ''A''
                       join uss_ndi.v_ndi_pfu_payment_type pt on pt.nppt_id = a.scpc_nppt
                       join uss_person.v_sc_household h on h.schh_id = ps.scpp_schh
                       join uss_person.v_sc_address adr on adr.sca_id = h.schh_sca
                       JOIN uss_ndi.v_ndi_katottg k on k.kaot_id = adr.sca_kaot
                       JOIN uss_ndi.v_ndi_katottg km on (km.kaot_id = k.kaot_kaot_l'
                || l_level
                || ' )
                       left JOIN uss_ndi.v_ndi_katottg kd on (kd.kaot_id = k.kaot_kaot_l'
                || l_level_data
                || ' )
                      where 1 = 1
                        AND ps.scpp_pfu_payment_tp = ''BENEFIT''
                        and scpp_pfu_pd_st NOT IN (''PS'', ''V'')
                        and to_date('''
                || TO_CHAR (p_dt, 'DD.MM.YYYY')
                || ''', ''DD.MM.YYYY'') between scpp_pfu_pd_start_dt and scpp_pfu_pd_stop_dt
                        AND to_date('''
                || TO_CHAR (p_dt, 'DD.MM.YYYY')
                || ''', ''DD.MM.YYYY'') = scpc_acd_dt
                        AND a.scpc_acd_sum > 0
                        '
                || CASE
                       WHEN p_kaot_id IS NOT NULL AND p_kaot_id != 0
                       THEN
                           ' and km.kaot_id = ' || p_kaot_id
                   END
                || '
                        and pt.nppt_id in (10201)
                     ),
             res as (select 1 + row_number() over (order by DECODE(x_Region, ''невизначено або відсутні дані'', 9999, 0), nlssort(x_Region, ''NLS_SORT=ukrainian'')) as rn,
                            x_Region AS col_2,
                            COUNT(distinct t.sc_id) AS col_3,
                            COUNT(distinct CASE WHEN t.x_Tarif IS NOT NULL AND t.x_Tarif <= 7 THEN t.sc_id END) AS col_4,
                            COUNT(distinct CASE WHEN t.x_Tarif IS NOT NULL AND t.x_Tarif > 7 AND t.x_Tarif <= 8 THEN t.sc_id END) AS col_5,
                            COUNT(distinct CASE WHEN t.x_Tarif IS NOT NULL AND t.x_Tarif > 8 AND t.x_Tarif <= 9 THEN t.sc_id END) AS col_6,
                            COUNT(distinct CASE WHEN t.x_Tarif IS NOT NULL AND t.x_Tarif > 9 AND t.x_Tarif <= 10 THEN t.sc_id END) AS col_7,
                            COUNT(distinct CASE WHEN t.x_Tarif IS NOT NULL AND t.x_Tarif > 10 AND t.x_Tarif <= 11 THEN t.sc_id END) AS col_8,
                            COUNT(distinct CASE WHEN t.x_Tarif IS NOT NULL AND t.x_Tarif > 11 AND t.x_Tarif <= 12 THEN t.sc_id END) AS col_9,
                            COUNT(distinct CASE WHEN t.x_Tarif IS NOT NULL AND t.x_Tarif > 12 AND t.x_Tarif <= 13 THEN t.sc_id END) AS col_10,
                            COUNT(distinct CASE WHEN t.x_Tarif IS NOT NULL AND t.x_Tarif > 13 THEN t.sc_id END) AS col_11
                       from (SELECT x_Region, sc_id, x_Tarif FROM dat1
                              UNION ALL
                             SELECT x_Region, sc_id, x_Tarif FROM dat2) t
                      GROUP BY x_Region
                      ORDER BY x_Region
                     )
             select rn,
                    col_2,     -- Назва адміністративно-територіальної одиниці
                    col_3,     -- Всього (Кількість пільговиків, які користуються пільгою на оплату послуги;з постачання природного газу за ціною на природний газ для населення;у розмірі грн. за метр куб. з ПДВ)
                    col_4,     -- менше 7,00
                    col_5,     -- 7,01-8,00
                    col_6,     -- 8,01-9,00
                    col_7,     -- 9,01-10,00
                    col_8,     -- 10,01-11,00
                    col_9,     -- 11,01-12,00
                    col_10,    -- 12,01-13,00
                    col_11     -- більше 13,00
               from
             (select rn,
                     (col_2) as col_2,
                     col_3,
                     col_4,
                     col_5,
                     col_6,
                     col_7,
                     col_8,
                     col_9,
                     col_10,
                     col_11
                from res t
              union all
               select 1,
                      '''
                || l_level_name
                || ''',
                      sum(col_3),
                      sum(col_4),
                      sum(col_5),
                      sum(col_6),
                      sum(col_7),
                      sum(col_8),
                      sum(col_9),
                      sum(col_10),
                      sum(col_11)
                from res t
             )
                order by rn
      ');
        END IF;

        FOR xx IN (SELECT (SELECT LOWER (dic_name)
                             FROM uss_ndi.v_ddn_month_names z
                            WHERE z.dic_value = TO_CHAR (p_dt, 'MM'))    AS month_dt
                     FROM DUAL)
        LOOP
            RDM$RTFL.AddParam (l_jbr_id, 'month', xx.month_dt);
            RDM$RTFL.AddParam (l_jbr_id, 'year', TO_CHAR (p_dt, 'YYYY'));
            RDM$RTFL.AddParam (l_jbr_id,
                               'gen_dt',
                               TO_CHAR (SYSDATE, 'DD.MM.YYYY'));
        END LOOP;

        rdm$rtfl.PutReportToWorkingQueue (l_jbr_id);
        RETURN l_jbr_id;
    END;

    FUNCTION BENEFIT_GAS_INFO_R3 (p_rt_id     IN NUMBER,
                                  p_dt        IN DATE,
                                  p_kaot_id   IN NUMBER)
        RETURN NUMBER
    IS
        l_jbr_id       NUMBER;
        l_monthn       NUMBER := EXTRACT (MONTH FROM p_dt);
        l_month        VARCHAR2 (10) := TO_CHAR (p_dt, 'MM');
        l_year         VARCHAR2 (10) := TO_CHAR (p_dt, 'YYYY');
        --l_org_to NUMBER;
        l_level        NUMBER;
        l_level_data   NUMBER;
        l_level_name   VARCHAR2 (500);
    BEGIN
        l_jbr_id :=
            rdm$rtfl.initreport (
                p_rt_id,
                p_rpt_name   => 'Субсидії_тариф_за_викл_опалення');
        rdm$rtfl.SetFileName (
            l_jbr_id,
               'Субсидії_тариф_за_викл_опалення'
            || '_'
            || TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS')
            || '.XLS');

        get_kaot_info (p_kaot_id,
                       l_level,
                       l_level_data,
                       l_level_name);

        /*    SELECT MAX(org_to)
              INTO l_org_to
              FROM v_opfu t
              WHERE org_id = p_org_id;

            IF (p_org_id IS NULL OR p_org_id = 0) THEN
              rdm$rtfl.AddDataSet(l_jbr_id, 'ds',
               'with dat as (select adr.sca_region,
                                    ps.scpp_sc as sc_id,
                                    7.96 as tarif
                               from uss_person.v_sc_pfu_pay_period t
                               JOIN uss_person.v_sc_pfu_pay_summary ps ON (ps.scpp_id = t.scp3_scpp and ps.scpp_pfu_payment_tp = ''SUBSIDY'')
                               join uss_ndi.v_ndi_pfu_payment_type pt on (pt.nppt_id = t.scp3_nppt)
                               join uss_person.v_sc_household h on (h.schh_id = scp3_schh)
                               join uss_person.v_sc_address adr on (adr.sca_sc = t.scp3_sc)
                              where 1 = 1
                                and adr.sca_tp = ''5''
                                and adr.history_status = ''A''
                                and t.scp3_year = ' || to_char(p_dt, 'YYYY') || '
                                and t.scp3_sum_m' || l_monthn || ' is not null
                                and pt.nppt_id in (10202, 10203)
                             ),
                     res as (select 1 + row_number() over (order by nlssort(sca_region, ''NLS_SORT=ukrainian'')) as rn,
                                    sca_region AS col_2,
                                    COUNT(distinct t.sc_id) AS col_3,
                                    COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif <= 7 THEN t.sc_id END) AS col_4,
                                    COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 7 AND t.tarif <= 8 THEN t.sc_id END) AS col_5,
                                    COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 8 AND t.tarif <= 9 THEN t.sc_id END) AS col_6,
                                    COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 9 AND t.tarif <= 10 THEN t.sc_id END) AS col_7,
                                    COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 10 AND t.tarif <= 11 THEN t.sc_id END) AS col_8,
                                    COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 11 AND t.tarif <= 12 THEN t.sc_id END) AS col_9,
                                    COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 12 AND t.tarif <= 13 THEN t.sc_id END) AS col_10,
                                    COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 13 THEN t.sc_id END) AS col_11
                               from dat t
                              GROUP BY sca_region
                              ORDER BY sca_region
                             )
                       select rn,
                            col_2,
                           col_3,
                           col_4,
                           col_5,
                           col_6,
                           col_7,
                           col_8,
                           col_9,
                            col_10,
                            col_11
                       from
                     (select rn,
                             case when (lower(col_2)) = ''київ'' then ''м. '' || initCap(col_2)
                                  when col_2 is not null then initCap(col_2) || '' обл.''
                             end as col_2,
                             col_3,
                             col_4,
                             col_5,
                             col_6,
                             col_7,
                             col_8,
                             col_9,
                             col_10,
                             col_11
                        from res t
                       union all
                       select 1,
                              ''УКРАЇНА'',
                              sum(col_3),
                              sum(col_4),
                              sum(col_5),
                              sum(col_6),
                              sum(col_7),
                              sum(col_8),
                              sum(col_9),
                              sum(col_10),
                              sum(col_11)
                        from res t
                     )
                        order by rn
              ');
            ELSE
              rdm$rtfl.AddDataSet(l_jbr_id, 'ds',
               'with dat as (select --adr.sca_region,
                                    ps.scpp_sc as sc_id,
                                    7.96 as tarif,
                                    nok_org as org_id
                               from uss_person.v_sc_pfu_pay_period t
                               JOIN uss_person.v_sc_pfu_pay_summary ps ON (ps.scpp_id = t.scp3_scpp and ps.scpp_pfu_payment_tp = ''SUBSIDY'')
                               join uss_ndi.v_ndi_pfu_payment_type pt on (pt.nppt_id = t.scp3_nppt)
                               join uss_person.v_sc_household h on (h.schh_id = scp3_schh)
                               join uss_person.v_sc_address adr on (adr.sca_sc = t.scp3_sc)
                               JOIN uss_ndi.v_ndi_org2kaot k ON (k.nok_kaot = adr.sca_kaot and k.history_status = ''A'')
                              where 1 = 1
                                and adr.sca_tp = ''5''
                                and adr.history_status = ''A''
                                and t.scp3_year = ' || to_char(p_dt, 'YYYY') || '
                                and t.scp3_sum_m' || l_monthn || ' is not null
                                --and to_date(''' || to_char(p_Dt, 'DD.MM.YYYY') || ''', ''DD.MM.YYYY'') between
                                --        nvl(k.nk2o_start_dt, to_date(''' || to_char(p_Dt, 'DD.MM.YYYY') || ''', ''DD.MM.YYYY''))
                                --       and
                                --       nvl(k.nk2o_stop_dt, to_date(''' || to_char(p_Dt, 'DD.MM.YYYY') || ''', ''DD.MM.YYYY''))
                                and pt.nppt_id in (10202, 10203)
                             ),
                     res as (select 1 + row_number() over (order by nlssort(pr.org_name, ''NLS_SORT=ukrainian'')) as rn,
                                    pr.org_name AS col_2,
                                    COUNT(distinct t.sc_id) AS col_3,
                                    COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif <= 7 THEN t.sc_id END) AS col_4,
                                    COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 7 AND t.tarif <= 8 THEN t.sc_id END) AS col_5,
                                    COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 8 AND t.tarif <= 9 THEN t.sc_id END) AS col_6,
                                    COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 9 AND t.tarif <= 10 THEN t.sc_id END) AS col_7,
                                    COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 10 AND t.tarif <= 11 THEN t.sc_id END) AS col_8,
                                    COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 11 AND t.tarif <= 12 THEN t.sc_id END) AS col_9,
                                    COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 12 AND t.tarif <= 13 THEN t.sc_id END) AS col_10,
                                    COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 13 THEN t.sc_id END) AS col_11
                               from dat t
                               join v_opfu pr on (pr.org_id = t.org_id)
                               join v_opfu po on (po.org_id = decode(pr.org_to, 32, pr.org_org, pr.org_id))
                              where ' || CASE WHEN l_org_to = 31 THEN 'po.org_id' ELSE 'pr.org_id' END || ' = ' || p_org_id || '
                              GROUP BY pr.org_name
                              ORDER BY pr.org_name
                             )
                       select rn,
                            col_2,
                            col_3,
                            col_4,
                            col_5,
                            col_6,
                            col_7,
                            col_8,
                            col_9,
                             col_10,
                             col_11
                       from
                     (select rn,
                             initcap(col_2) as col_2,
                             col_3,
                             col_4,
                             col_5,
                             col_6,
                             col_7,
                             col_8,
                             col_9,
                             col_10,
                             col_11
                        from res t
                     )
                        order by rn
              ');
            END IF;
            */

        rdm$rtfl.AddDataSet (
            l_jbr_id,
            'ds',
               'with dat as (select nvl(kd.kaot_full_name, ''невизначено або відсутні дані'') as region,
                            ps.scpp_sc as sc_id,
                            7.96 as tarif
                       from uss_person.v_sc_pfu_pay_period t
                       JOIN uss_person.v_sc_pfu_pay_summary ps ON (ps.scpp_id = t.scp3_scpp and ps.scpp_pfu_payment_tp = ''SUBSIDY'')
                       join uss_ndi.v_ndi_pfu_payment_type pt on (pt.nppt_id = t.scp3_nppt)
                       join uss_person.v_sc_address adr on (adr.sca_sc = t.scp3_sc)
                       JOIN uss_ndi.v_ndi_katottg k on (k.kaot_id = adr.sca_kaot )
                       JOIN uss_ndi.v_ndi_katottg km on (km.kaot_id = k.kaot_kaot_l'
            || l_level
            || ' )
                       left JOIN uss_ndi.v_ndi_katottg kd on (kd.kaot_id = k.kaot_kaot_l'
            || l_level_data
            || ' )
                      where 1 = 1
                        and adr.sca_tp = ''5''
                        and adr.history_status = ''A''
                        and scpp_pfu_pd_st not in (''PS'', ''V'')
                        and t.scp3_year = '
            || TO_CHAR (p_dt, 'YYYY')
            || '
                        and t.scp3_sum_m'
            || l_monthn
            || ' > 0 /*is not null*/'
            || CASE
                   WHEN p_kaot_id IS NOT NULL AND p_kaot_id != 0
                   THEN
                       ' and km.kaot_id = ' || p_kaot_id
               END
            || '
                        and pt.nppt_id in (10202, 10203)
                        and to_date('''
            || TO_CHAR (p_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'')  between scpp_pfu_pd_start_dt and scpp_pfu_pd_stop_dt
                        /*та не включає послугу 10201 (газопостачання природного газу: на опалення)*/
                        and not exists (select *
                                         from uss_person.v_sc_pfu_pay_period z
                                         JOIN uss_person.v_sc_pfu_pay_summary zs ON (zs.scpp_id = z.scp3_scpp and zs.scpp_pfu_payment_tp = ''SUBSIDY'')
                                        where z.scp3_year = '
            || TO_CHAR (p_dt, 'YYYY')
            || '
                                          and z.scp3_nppt in (10201)
                                          and zs.scpp_sc = ps.scpp_Sc)
                     ),
             res as (select 1 + row_number() over (order by DECODE(region, ''невизначено або відсутні дані'', 9999, 0), nlssort(region, ''NLS_SORT=ukrainian'')) as rn,
                            region AS col_2,
                            COUNT(distinct t.sc_id) AS col_3,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif <= 7 THEN t.sc_id END) AS col_4,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 7 AND t.tarif <= 8 THEN t.sc_id END) AS col_5,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 8 AND t.tarif <= 9 THEN t.sc_id END) AS col_6,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 9 AND t.tarif <= 10 THEN t.sc_id END) AS col_7,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 10 AND t.tarif <= 11 THEN t.sc_id END) AS col_8,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 11 AND t.tarif <= 12 THEN t.sc_id END) AS col_9,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 12 AND t.tarif <= 13 THEN t.sc_id END) AS col_10,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 13 THEN t.sc_id END) AS col_11
                       from (select Region,
                                    sc_id,
                                    tarif
                               from dat t
                             ) t
                      GROUP BY region
                      ORDER BY region
                     )
             select rn,
                    col_2,     -- Назва адміністративно-територіальної одиниці
                    col_3,     -- Всього (Кількість отримувачів житлової субсидії на оплату послуги;з постачання природного газу за ціною на природний газ для населення&;у розмірі грн. за метр куб. з ПДВ)
                    col_4,     -- менше 7,00
                    col_5,     -- 7,01-8,00
                    col_6,     -- 8,01-9,00
                    col_7,     -- 9,01-10,00
                    col_8,     -- 10,01-11,00
                    col_9,     -- 11,01-12,00
                    col_10,    -- 12,01-13,00
                    col_11     -- більше 13,00
               from
             (select rn,
                     (col_2) as col_2,
                     col_3,
                     col_4,
                     col_5,
                     col_6,
                     col_7,
                     col_8,
                     col_9,
                     col_10,
                     col_11
                from res t
              union all
               select 1,
                      '''
            || l_level_name
            || ''',
                      sum(col_3),
                      sum(col_4),
                      sum(col_5),
                      sum(col_6),
                      sum(col_7),
                      sum(col_8),
                      sum(col_9),
                      sum(col_10),
                      sum(col_11)
                from res t
             )
                order by rn
      ');

        FOR xx IN (SELECT (SELECT LOWER (dic_name)
                             FROM uss_ndi.v_ddn_month_names z
                            WHERE z.dic_value = TO_CHAR (p_dt, 'MM'))    AS month_dt
                     FROM DUAL)
        LOOP
            RDM$RTFL.AddParam (l_jbr_id, 'month', xx.month_dt);
            RDM$RTFL.AddParam (l_jbr_id, 'year', TO_CHAR (p_dt, 'YYYY'));
            RDM$RTFL.AddParam (l_jbr_id,
                               'gen_dt',
                               TO_CHAR (SYSDATE, 'DD.MM.YYYY'));
        END LOOP;

        rdm$rtfl.PutReportToWorkingQueue (l_jbr_id);
        RETURN l_jbr_id;
    END;

    FUNCTION BENEFIT_GAS_INFO_R4 (p_rt_id     IN NUMBER,
                                  p_dt        IN DATE,
                                  p_kaot_id   IN NUMBER)
        RETURN NUMBER
    IS
        l_jbr_id       NUMBER;
        l_month        VARCHAR2 (10) := TO_CHAR (p_dt, 'MM');
        l_monthn       NUMBER := EXTRACT (MONTH FROM p_dt);
        l_year         VARCHAR2 (10) := TO_CHAR (p_dt, 'YYYY');
        --l_org_to NUMBER;
        l_level        NUMBER;
        l_level_data   NUMBER;
        l_level_name   VARCHAR2 (500);
    BEGIN
        l_jbr_id :=
            rdm$rtfl.initreport (
                p_rt_id,
                p_rpt_name   => 'Субсидії_тариф_включ_опалення_газом');
        rdm$rtfl.SetFileName (
            l_jbr_id,
               'Субсидії_тариф_включ_опалення_газом'
            || '_'
            || TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS')
            || '.XLS');

        get_kaot_info (p_kaot_id,
                       l_level,
                       l_level_data,
                       l_level_name);

        /*
        SELECT MAX(org_to)
          INTO l_org_to
          FROM v_opfu t
          WHERE org_id = p_org_id;
       IF (p_org_id IS NULL OR p_org_id = 0) THEN
         rdm$rtfl.AddDataSet(l_jbr_id, 'ds',
           'with dat as (select adr.sca_region,
                                ps.scpp_sc as sc_id,
                                7.96 as tarif
                           from uss_person.v_sc_pfu_pay_period t
                           JOIN uss_person.v_sc_pfu_pay_summary ps ON (ps.scpp_id = t.scp3_scpp and ps.scpp_pfu_payment_tp = ''SUBSIDY'')
                           join uss_ndi.v_ndi_pfu_payment_type pt on (pt.nppt_id = t.scp3_nppt)
                           join uss_person.v_sc_household h on (h.schh_id = scp3_schh)
                           join uss_person.v_sc_address adr on (adr.sca_sc = t.scp3_sc)
                          where 1 = 1
                            and adr.sca_tp = ''5''
                            and adr.history_status = ''A''
                            and t.scp3_year = ' || to_char(p_dt, 'YYYY') || '
                            and t.scp3_sum_m' || l_monthn || ' is not null
                            and pt.nppt_id in (10201)
                         ),
                 res as (select 1 + row_number() over (order by nlssort(sca_region, ''NLS_SORT=ukrainian'')) as rn,
                                sca_region AS col_2,
                                COUNT(distinct t.sc_id) AS col_3,
                                COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif <= 7 THEN t.sc_id END) AS col_4,
                                COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 7 AND t.tarif <= 8 THEN t.sc_id END) AS col_5,
                                COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 8 AND t.tarif <= 9 THEN t.sc_id END) AS col_6,
                                COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 9 AND t.tarif <= 10 THEN t.sc_id END) AS col_7,
                                COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 10 AND t.tarif <= 11 THEN t.sc_id END) AS col_8,
                                COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 11 AND t.tarif <= 12 THEN t.sc_id END) AS col_9,
                                COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 12 AND t.tarif <= 13 THEN t.sc_id END) AS col_10,
                                COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 13 THEN t.sc_id END) AS col_11
                           from dat t
                          GROUP BY sca_region
                          ORDER BY sca_region
                         )
                   select rn,
                        col_2,
                        col_3,
                        col_4,
                        col_5,
                        col_6,
                        col_7,
                        col_8,
                        col_9,
                         col_10,
                         col_11
                   from
                 (select rn,
                         case when (lower(col_2)) = ''київ'' then ''м. '' || initCap(col_2)
                              when col_2 is not null then initCap(col_2) || '' обл.''
                         end as col_2,
                         col_3,
                         col_4,
                         col_5,
                         col_6,
                         col_7,
                         col_8,
                         col_9,
                         col_10,
                         col_11
                    from res t
                   union all
                   select 1,
                          ''УКРАЇНА'',
                          sum(col_3),
                          sum(col_4),
                          sum(col_5),
                          sum(col_6),
                          sum(col_7),
                          sum(col_8),
                          sum(col_9),
                          sum(col_10),
                          sum(col_11)
                    from res t
                 )
                    order by rn
          ');
        ELSE
          rdm$rtfl.AddDataSet(l_jbr_id, 'ds',
           'with dat as (select --adr.sca_region,
                                ps.scpp_sc as sc_id,
                                7.96 as tarif,
                                k.nok_org as org_id
                           from uss_person.v_sc_pfu_pay_period t
                           JOIN uss_person.v_sc_pfu_pay_summary ps ON (ps.scpp_id = t.scp3_scpp and ps.scpp_pfu_payment_tp = ''SUBSIDY'')
                           join uss_ndi.v_ndi_pfu_payment_type pt on (pt.nppt_id = t.scp3_nppt)
                           join uss_person.v_sc_household h on (h.schh_id = scp3_schh)
                           join uss_person.v_sc_address adr on (adr.sca_sc = t.scp3_sc)
                           JOIN uss_ndi.v_ndi_org2kaot k ON (k.nok_kaot = adr.sca_kaot and k.history_status = ''A'')
                          where 1 = 1
                            and adr.sca_tp = ''5''
                            and adr.history_status = ''A''
                            and t.scp3_year = ' || to_char(p_dt, 'YYYY') || '
                            and t.scp3_sum_m' || l_monthn || ' is not null
                            --and to_date(''' || to_char(p_Dt, 'DD.MM.YYYY') || ''', ''DD.MM.YYYY'') between
                            --        nvl(k.nk2o_start_dt, to_date(''' || to_char(p_Dt, 'DD.MM.YYYY') || ''', ''DD.MM.YYYY''))
                            --       and
                            --       nvl(k.nk2o_stop_dt, to_date(''' || to_char(p_Dt, 'DD.MM.YYYY') || ''', ''DD.MM.YYYY''))
                            and pt.nppt_id in (10201)
                         ),
                 res as (select 1 + row_number() over (order by nlssort(pr.org_name, ''NLS_SORT=ukrainian'')) as rn,
                                pr.org_name AS col_2,
                                COUNT(distinct t.sc_id) AS col_3,
                                COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif <= 7 THEN t.sc_id END) AS col_4,
                                COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 7 AND t.tarif <= 8 THEN t.sc_id END) AS col_5,
                                COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 8 AND t.tarif <= 9 THEN t.sc_id END) AS col_6,
                                COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 9 AND t.tarif <= 10 THEN t.sc_id END) AS col_7,
                                COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 10 AND t.tarif <= 11 THEN t.sc_id END) AS col_8,
                                COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 11 AND t.tarif <= 12 THEN t.sc_id END) AS col_9,
                                COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 12 AND t.tarif <= 13 THEN t.sc_id END) AS col_10,
                                COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 13 THEN t.sc_id END) AS col_11
                           from dat t
                           join v_opfu pr on (pr.org_id = t.org_id)
                           join v_opfu po on (po.org_id = decode(pr.org_to, 32, pr.org_org, pr.org_id))
                          where ' || CASE WHEN l_org_to = 31 THEN 'po.org_id' ELSE 'pr.org_id' END || ' = ' || p_org_id || '
                          GROUP BY pr.org_name
                          ORDER BY pr.org_name
                         )
                   select rn,
                        col_2,
                        col_3,
                        col_4,
                        col_5,
                        col_6,
                        col_7,
                        col_8,
                        col_9,
                         col_10,
                         col_11
                   from
                 (select rn,
                         initcap(col_2) as col_2,
                         col_3,
                         col_4,
                         col_5,
                         col_6,
                         col_7,
                         col_8,
                         col_9,
                         col_10,
                         col_11
                    from res t
                 )
                    order by rn
          ');
        END IF;
        */

        rdm$rtfl.AddDataSet (
            l_jbr_id,
            'ds',
               'with dat as (select nvl(kd.kaot_full_name, ''невизначено або відсутні дані'') as region,
                            ps.scpp_sc as sc_id,
                            7.96 as tarif
                       from uss_person.v_sc_pfu_pay_period t
                       JOIN uss_person.v_sc_pfu_pay_summary ps ON (ps.scpp_id = t.scp3_scpp and ps.scpp_pfu_payment_tp = ''SUBSIDY'')
                       join uss_ndi.v_ndi_pfu_payment_type pt on (pt.nppt_id = t.scp3_nppt)
                       join uss_person.v_sc_address adr on (adr.sca_sc = t.scp3_sc)
                       JOIN uss_ndi.v_ndi_katottg k on (k.kaot_id = adr.sca_kaot )
                       JOIN uss_ndi.v_ndi_katottg km on (km.kaot_id = k.kaot_kaot_l'
            || l_level
            || ' )
                       left JOIN uss_ndi.v_ndi_katottg kd on (kd.kaot_id = k.kaot_kaot_l'
            || l_level_data
            || ' )
                      where 1 = 1
                        and adr.sca_tp = ''5''
                        and adr.history_status = ''A''
                        and scpp_pfu_pd_st not in (''PS'', ''V'')
                        and t.scp3_year = '
            || TO_CHAR (p_dt, 'YYYY')
            || '
                        and t.scp3_sum_m'
            || l_monthn
            || ' > 0/*is not null*/
                        and to_date('''
            || TO_CHAR (p_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'')  between scpp_pfu_pd_start_dt and scpp_pfu_pd_stop_dt
                        '
            || CASE
                   WHEN p_kaot_id IS NOT NULL AND p_kaot_id != 0
                   THEN
                       ' and km.kaot_id = ' || p_kaot_id
               END
            || '
                        and pt.nppt_id in (10201)
                     ),
             res as (select 1 + row_number() over (order by DECODE(region, ''невизначено або відсутні дані'', 9999, 0), nlssort(region, ''NLS_SORT=ukrainian'')) as rn,
                            region AS col_2,
                            COUNT(distinct t.sc_id) AS col_3,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif <= 7 THEN t.sc_id END) AS col_4,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 7 AND t.tarif <= 8 THEN t.sc_id END) AS col_5,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 8 AND t.tarif <= 9 THEN t.sc_id END) AS col_6,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 9 AND t.tarif <= 10 THEN t.sc_id END) AS col_7,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 10 AND t.tarif <= 11 THEN t.sc_id END) AS col_8,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 11 AND t.tarif <= 12 THEN t.sc_id END) AS col_9,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 12 AND t.tarif <= 13 THEN t.sc_id END) AS col_10,
                            COUNT(distinct CASE WHEN t.tarif IS NOT NULL AND t.tarif > 13 THEN t.sc_id END) AS col_11
                       from (select Region,
                                    sc_id,
                                    tarif
                               from dat t
                             ) t
                      GROUP BY region
                      ORDER BY region
                     )
             select rn,
                    col_2,     -- Назва адміністративно-територіальної одиниці
                    col_3,     -- Всього (Кількість отримувачів житлової субсидії на оплату послуги ;з постачання природного газу за ціною на природний газ для населення;у розмірі грн. за метр куб. з ПДВ)
                    col_4,     -- менше 7,00
                    col_5,     -- 7,01-8,00
                    col_6,     -- 8,01-9,00
                    col_7,     -- 9,01-10,00
                    col_8,     -- 10,01-11,00
                    col_9,     -- 11,01-12,00
                    col_10,    -- 12,01-13,00
                    col_11     -- більше 13,00
               from
             (select rn,
                     (col_2) as col_2,
                     col_3,
                     col_4,
                     col_5,
                     col_6,
                     col_7,
                     col_8,
                     col_9,
                     col_10,
                     col_11
                from res t
              union all
               select 1,
                      '''
            || l_level_name
            || ''',
                      sum(col_3),
                      sum(col_4),
                      sum(col_5),
                      sum(col_6),
                      sum(col_7),
                      sum(col_8),
                      sum(col_9),
                      sum(col_10),
                      sum(col_11)
                from res t
             )
                order by rn
      ');

        FOR xx IN (SELECT (SELECT LOWER (dic_name)
                             FROM uss_ndi.v_ddn_month_names z
                            WHERE z.dic_value = TO_CHAR (p_dt, 'MM'))    AS month_dt
                     FROM DUAL)
        LOOP
            RDM$RTFL.AddParam (l_jbr_id, 'month', xx.month_dt);
            RDM$RTFL.AddParam (l_jbr_id, 'year', TO_CHAR (p_dt, 'YYYY'));
            RDM$RTFL.AddParam (l_jbr_id,
                               'gen_dt',
                               TO_CHAR (SYSDATE, 'DD.MM.YYYY'));
        END LOOP;

        rdm$rtfl.PutReportToWorkingQueue (l_jbr_id);
        RETURN l_jbr_id;
    END;

    PROCEDURE get_sc_edarp_dovidka (p_sc_id      IN     NUMBER,
                                    p_start_dt   IN     DATE,
                                    p_stop_dt    IN     DATE,
                                    p_res_doc       OUT SYS_REFCURSOR)
    IS
        l_blob          BLOB;
        l_role          NUMBER
            := CASE
                   WHEN tools.CheckUserRole ('W_ESR_BENEFIT_VIEW') THEN 1
                   ELSE 0
               END;
        l_wut           NUMBER := tools.GetCurrWut;
        l_flag          NUMBER := CASE WHEN l_Wut IN (31, 41) THEN 0 ELSE 1 END;
        l_is_permited   NUMBER;
        l_raj           NUMBER;
        l_org           NUMBER := tools.getcurrorg;
        l_org_to        NUMBER := tools.getcurrorgto;
    BEGIN
        IF (p_start_dt IS NULL OR p_stop_dt IS NULL)
        THEN
            raise_application_error (-20000, 'Вкажіть період!');
        END IF;


        WITH
            dat
            AS
                (SELECT t.RAJ, t.R_NCARDP, t.com_org
                   FROM uss_person.v_x_trg  t
                        JOIN uss_person.v_sc_benefit_category c
                            ON     c.scbc_id = t.trg_id
                               AND t.trg_code =
                                   'USS_PERSON.SC_BENEFIT_CATEGORY'
                  WHERE c.scbc_sc = p_sc_id
                  FETCH FIRST ROW ONLY)
        SELECT COUNT (*), MAX (t.com_org)
          INTO l_is_permited, l_raj
          FROM dat  t
               JOIN uss_person.v_b_katpp z
                   ON (t.raj = z.raj AND t.r_ncardp = z.r_ncardp)
         WHERE     1 = 1
               AND (   l_flag = 0
                    OR z.katp_cd NOT IN (1,
                                         2,
                                         3,
                                         4,
                                         11,
                                         12,
                                         13,
                                         22,
                                         23,
                                         58,
                                         80,
                                         85,
                                         86,
                                         87,
                                         88,
                                         136,
                                         137,
                                         138,
                                         139));

        IF (l_is_permited = 0 AND l_flag = 1)
        THEN
            raise_application_error (-20000, 'Доступ до даних обмежено');
        ELSIF (l_role = 0)
        THEN
            uss_person.Api$socialcard.write_sc_log (p_sc_id,
                                                    NULL,
                                                    NULL,
                                                    CHR (38) || '225',
                                                    NULL,
                                                    NULL);
            COMMIT;
            raise_application_error (-20000, 'Побудова витягу недуступна!');
        END IF;

        IF (l_org_to = 32 AND l_raj != l_org)
        THEN
            raise_application_error (
                -20000,
                'Особа, що має право на пільгу, стоїть на обліку в іншому районі!');
        ELSIF (l_org_to = 31)
        THEN
            SELECT CASE WHEN t.org_org = l_org THEN l_raj ELSE l_org END
              INTO l_org
              FROM v_opfu t
             WHERE t.org_id = l_raj;

            IF (l_raj != l_org)
            THEN
                raise_application_error (
                    -20000,
                    'Особа, що має право на пільгу, стоїть на обліку в іншому районі!');
            END IF;
        END IF;

        reportfl_engine.InitReport ('USS_ESR', 'EDARP_DOVIDKA_R2');

        reportfl_engine.AddParam ('user_pib',
                                  uss_esr.tools.GetCurrUserPIB ());
        reportfl_engine.AddParam ('start_dt',
                                  TO_CHAR (p_start_dt, 'DD.MM.YYYY'));
        reportfl_engine.AddParam ('stop_dt',
                                  TO_CHAR (p_stop_dt, 'DD.MM.YYYY'));

        reportfl_engine.adddataset (
            'ds_info',
               '
        WITH dat AS (SELECT t.RAJ, t.R_NCARDP
                       FROM uss_person.v_x_trg t
                       join uss_person.v_sc_benefit_category c on c.scbc_id = t.trg_id and t.trg_code = ''USS_PERSON.SC_BENEFIT_CATEGORY''
                      WHERE c.scbc_sc = '
            || p_sc_id
            || '
                      FETCH FIRST ROW ONLY
                      )
        select distinct to_char(SYSDATE, ''DD.MM.YYYY'')  AS cur_dt,
               ''_______'' AS ap_num,
               to_char(r.R_NAME1) AS last_name,
               to_char(r.R_NAME2) AS first_name,
               to_char(r.R_NAME3) AS middle_name,
               to_char(b.fam_dtbirth, ''DD.MM.YYYY'') AS birth_dt,
               to_char(b.fam_numtaxp) AS rnokpp,
               case when os.osoba_znach2 > 0 then to_char(substr(regexp_replace(os.osoba_strznach, ''\D''), 1, 13)) else null end AS unzr,
               decode(b.fam_pol, 1, ''чоловік'', ''жінка'') AS gender,
               case when os.osoba_znach2 > 0 then LPAD(to_char(ROUND(os.osoba_znach2)), 9, ''0'')
                    else to_char(REPLACE(REPLACE(trim(b.fam_pasp), '' '', ''''), ''-'', ''''))
                END AS pasp_info,
               case when trim(r.r_strtel) is not null and nvl(trim(r.r_kolkat),0) <>0 then to_char(''+380''||nvl(lpad(trim(r.r_kolkat),2,0),''00'')||lpad(trim(r.r_strtel),7,0))
                    else lpad(to_char(trim(r.r_strtel)),7,0)
                END AS phone_num,
               case when (select count(*) from uss_person.v_b_katpp z where t.raj = z.raj and t.r_ncardp = z.r_ncardp '
            || CASE
                   WHEN l_flag = 1
                   THEN
                       ' and z.katp_cd not in (1, 2, 3, 4, 11, 12, 13, 22, 23, 58, 80, 85, 86, 87, 88, 136, 137, 138, 139)'
               END
            || ') > 0 then
                 to_char(b2.klat_name ||''; ''|| b1.klat_name || ''; '' || r.r_index ||''; ''|| ind.klind_adr || ''; '' || ku.klkatul_name
                 || '' '' || q.klul_name || ''; '' || nvl2(r.r_house, ''Буд. '' || r.r_house || '' '', '''') || r.r_build
                 || nvl2(r.r_apt, ''; кв. '' || r.r_apt, '''') )
               end AS addr_reg,
               case when (sel.osoba_code != 9 or sel.osoba_code is null) and (select count(*) from uss_person.v_b_katpp z where t.raj = z.raj and t.r_ncardp = z.r_ncardp '
            || CASE
                   WHEN l_flag = 1
                   THEN
                       ' and z.katp_cd not in (1, 2, 3, 4, 11, 12, 13, 22, 23, 58, 80, 85, 86, 87, 88, 136, 137, 138, 139)'
               END
            || ') > 0 then
                 to_char(b2.klat_name ||''; ''|| b1.klat_name || ''; '' || r.r_index ||''; ''|| ind.klind_adr || ''; '' || ku.klkatul_name
                   || '' '' || q.klul_name || ''; '' || nvl2(r.r_house, ''Буд. '' || r.r_house || '' '', '''') || r.r_build
                   || nvl2(r.r_apt, ''; кв. '' || r.r_apt, '''') )
               end as addr_liv,
               decode(sel.osoba_code, 9, ''ні'', ''так'') AS addr_identical,
               to_char(b.fam_dtbeg , ''DD.MM.YYYY'')  AS get_dt,
               to_char(b.fam_dtexit, ''DD.MM.YYYY'')  AS post_dt,
               to_char(p.klpsn_name) AS post_reason,
               to_char(r.raj||''-''||b1.klat_name) as oszn,
               to_char(t.r_ncardp) AS card_num
         FROM dat t
         JOIN uss_person.v_b_reestrlg r ON (r.raj = t.RAJ AND r.R_NCARDP = t.R_NCARDP)
         join uss_person.v_b_famp b on b.raj = r.raj and b.r_ncardp = r.r_ncardp and b.fam_nomf = 0 -- заявник -- пільговик
         left join uss_person.v_b_klul q on q.klul_codern = r.raj and q.klul_codeul = r.r_cdul
         left join uss_person.v_b_klkatul ku on ku.klkatul_code = q.klul_codekul
         left join uss_person.v_b_klat b1 on r.raj = b1.klat_code
         left join uss_person.v_b_klat b2 on trunc(r.raj,-2) = b2.klat_code
         left join uss_person.v_b_klind ind on r.r_index = ind.klind_ind
         left join uss_person.v_b_osobap os on os.raj = b.raj and os.r_ncardp = b.r_ncardp and os.osoba_nfam = b.fam_nomf and os.osoba_code = 50
         left join (select  distinct o.raj, o.r_ncardp, o.osoba_code from uss_person.v_b_osobap o where o.osoba_code = 9 and o.osoba_cdexit = 0 and o.osoba_znach1 = 0 and o.osoba_dtend is null) sel on sel.raj = r.raj and sel.r_ncardp = r.r_ncardp
         left join uss_person.v_b_klpsn p on b.fam_cdexit = p.klpsn_code -- треба поправити довідник, додам  b_klpsn
        where 1 = 1
          and b.fam_dtbeg <= to_date('''
            || TO_CHAR (p_stop_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'')
          and nvl(b.fam_dtexit, to_date('''
            || TO_CHAR (p_start_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'')) >= to_date('''
            || TO_CHAR (p_start_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'') -- діюча картка пільговика (по заякнику b.fam_nomf = 0)
        union all
        SELECT distinct to_char(SYSDATE, ''DD.MM.YYYY'')  AS cur_dt,
                 ''_______'' AS ap_num,
                 i.sco_ln AS last_name,
                 i.sco_fn AS first_name,
                 i.sco_mn AS middle_name,
                 to_char(i.sco_birth_dt, ''DD.MM.YYYY'') AS birth_dt,
                 i.sco_numident AS rnokpp,
                 '''' AS unzr,
                 i.sco_gender AS gender,
                 i.sco_pasp_seria || i.sco_pasp_number  AS pasp_info,
                 (SELECT MAX(z.sct_phone_mob)
                    FROM uss_person.v_sc_contact z
                   WHERE z.sct_id = ch.scc_sct
                 ) AS phone_num,
                 case when (SELECT COUNT(*)
                              FROM uss_person.v_sc_benefit_category zz
                             WHERE zz.scbc_sc = t.sc_id
                               AND zz.scbc_st = ''A''
                               AND zz.scbc_nbc NOT IN (1, 2, 3, 4, 11, 12, 13, 22, 23, 58, 80, 85, 86, 87, 88, 136, 137, 138, 139)
                            ) > 0 then
                    uss_person.api$sc_tools.get_address(t.sc_id, ''3'')
                 end AS addr_reg,
                 case when (SELECT COUNT(*)
                              FROM uss_person.v_sc_benefit_category zz
                             WHERE zz.scbc_sc = t.sc_id
                               AND zz.scbc_st = ''A''
                               AND zz.scbc_nbc NOT IN (1, 2, 3, 4, 11, 12, 13, 22, 23, 58, 80, 85, 86, 87, 88, 136, 137, 138, 139)
                            ) > 0 then
                    uss_person.api$sc_tools.get_address(t.sc_id, ''2'')
                 end as addr_liv,
                 CASE WHEN uss_person.api$sc_tools.get_address(t.sc_id, ''3'') =
                           uss_person.api$sc_tools.get_address(t.sc_id, ''2'') THEN ''ні'' ELSE ''так''
                  END AS addr_identical,
                 (SELECT to_char(MIN(zz.scbc_start_dt), ''DD.MM.YYYY'')
                    FROM uss_person.v_sc_benefit_category zz
                   WHERE zz.scbc_sc = t.sc_id
                     AND zz.scbc_st = ''A''
                 ) AS get_dt,
                 (SELECT to_char(MAX(zz.scbc_stop_dt), ''DD.MM.YYYY'')
                    FROM uss_person.v_sc_benefit_category zz
                   WHERE zz.scbc_sc = t.sc_id
                     AND zz.scbc_st = ''A''
                 ) AS post_dt,
                 '''' AS post_reason,
                 '''' as oszn,
                 '''' AS card_num
            FROM uss_person.v_socialcard t
            JOIN uss_person.v_sc_change ch ON (ch.scc_id = t.sc_scc)
            JOIN uss_person.v_sc_info i ON (i.sco_id = t.sc_id)
           WHERE t.sc_id = '
            || p_sc_id
            || '
             and exists (SELECT *
                           FROM uss_person.v_sc_benefit_category zz
                          WHERE zz.scbc_sc = t.sc_id
                            AND zz.scbc_st = ''A''
                            and zz.scbc_start_dt <= to_date('''
            || TO_CHAR (p_stop_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'')
                            and nvl(zz.scbc_stop_dt, to_date('''
            || TO_CHAR (p_start_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'')) >= to_date('''
            || TO_CHAR (p_start_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'')
                        )
             and not exists (select *
                               from dat x
                               join uss_person.v_b_famp b on (b.raj = x.raj and b.r_ncardp = x.r_ncardp and b.fam_nomf = 0)
                              where 1 = 1
                                and b.fam_dtbeg <= to_date('''
            || TO_CHAR (p_stop_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'')
                                and nvl(b.fam_dtexit, to_date('''
            || TO_CHAR (p_start_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'')) >= to_date('''
            || TO_CHAR (p_start_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'')
                            )
     ');

        reportfl_engine.adddataset (
            'ds1',
               'WITH dat AS (SELECT t.RAJ, t.R_NCARDP
                           FROM uss_person.v_x_trg t
                           join uss_person.v_sc_benefit_category c on c.scbc_id = t.trg_id and t.trg_code = ''USS_PERSON.SC_BENEFIT_CATEGORY''
                          WHERE c.scbc_sc = '
            || p_sc_id
            || '
                          FETCH FIRST ROW ONLY
                          )

            select b.fam_nomf as rn,
                   to_char(ftp.klfam_name) as fam_tp,
                   to_char(trim(b.fam_fio)) AS pib,
                   to_char(b.fam_dtbirth, ''DD.MM.YYYY'') AS birth_dt,
                   to_char(b.fam_numtaxp) as rnokpp,
                   case when os.osoba_znach2 > 0 then to_char(substr(regexp_replace(os.osoba_strznach,''\D''),1,13)) else null end as unzr,
                   decode(b.fam_pol, 1, ''чоловік'', ''жінка'') as gender,
                   case when os.osoba_znach2 > 0 then LPAD(to_char(ROUND(os.osoba_znach2)), 9, ''0'')
                        else to_char(REPLACE(REPLACE(trim(b.fam_pasp), '' '', ''''), ''-'', ''''))
                    END AS doc_info,
                   to_char(b.fam_dtbeg , ''DD.MM.YYYY'') AS start_dt,
                   to_char(b.fam_dtexit, ''DD.MM.YYYY'') AS stop_dt,
                   to_char(p.klpsn_name) as stop_reason
              FROM dat t
              JOIN uss_person.v_b_reestrlg r ON (r.raj = t.RAJ AND r.R_NCARDP = t.R_NCARDP)
              join uss_person.v_b_famp b on b.raj = r.raj and b.r_ncardp = r.r_ncardp /*and b.fam_nomf != 0 -- заявник -- пільговик*/
              LEFT JOIN uss_person.v_B_klFam ftp ON (ftp.klfam_code = b.FAM_CDRELAT)
              left join uss_person.v_b_osobap os on (os.raj = b.raj and os.r_ncardp = b.r_ncardp and os.osoba_nfam = b.fam_nomf and os.osoba_code = 50)
              left join uss_person.v_b_klpsn p on (p.klpsn_code = b.fam_cdexit)
             where 1 = 1
               --trunc(sysdate) between b.fam_dtbeg and b.fam_dtexit
               and b.fam_dtbeg <= to_date('''
            || TO_CHAR (p_stop_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'')
               and nvl(b.fam_dtexit, to_date('''
            || TO_CHAR (p_start_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'')) >= to_date('''
            || TO_CHAR (p_start_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'')
               and (select count(*) from uss_person.v_b_katpp z where t.raj = z.raj and t.r_ncardp = z.r_ncardp '
            || CASE
                   WHEN l_flag = 1
                   THEN
                       ' and z.katp_cd not in (1, 2, 3, 4, 11, 12, 13, 22, 23, 58, 80, 85, 86, 87, 88, 136, 137, 138, 139)'
               END
            || ') > 0
            union all
            SELECT row_number() over (order by i.sco_ln || '' '' || i.sco_fn || '' '' || i.sco_mn) as rn,
                   r.DIC_NAME AS c1,
                   i.sco_ln || '' '' || i.sco_fn || '' '' || i.sco_mn AS c2,
                   to_char(i.sco_birth_dt, ''DD.MM.YYYY'') AS c3,
                   i.sco_numident AS c4,
                   '''' AS c5,
                   i.sco_gender AS c6,
                   i.sco_pasp_seria || i.sco_pasp_number AS c8,
                   (SELECT to_char(MIN(zz.scbc_start_dt), ''DD.MM.YYYY'')
                      FROM uss_person.v_sc_benefit_category zz
                     WHERE zz.scbc_sc = t.scpf_sc
                       AND zz.scbc_st = ''A''
                   ) AS c9,
                   (SELECT to_char(MAX(zz.scbc_stop_dt), ''DD.MM.YYYY'')
                      FROM uss_person.v_sc_benefit_category zz
                     WHERE zz.scbc_sc = t.scpf_sc
                       AND zz.scbc_st = ''A''
                   ) AS c10,
                   '''' AS c11
              FROM uss_person.v_sc_scpp_family t
              JOIN uss_person.v_sc_info i ON (i.sco_id = t.scpf_sc)
              JOIN uss_ndi.v_ddn_relation_tp r ON (r.DIC_VALUE = t.scpf_relation_tp)
             WHERE t.scpf_sc_main = '
            || p_sc_id
            || '
               and exists (SELECT *
                             FROM uss_person.v_sc_benefit_category zz
                            WHERE zz.scbc_sc = t.scpf_sc_main
                              AND zz.scbc_st = ''A''
                              AND zz.scbc_nbc NOT IN (1, 2, 3, 4, 11, 12, 13, 22, 23, 58, 80, 85, 86, 87, 88, 136, 137, 138, 139)
                              and zz.scbc_start_dt <= to_date('''
            || TO_CHAR (p_stop_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'')
                              and nvl(zz.scbc_stop_dt, to_date('''
            || TO_CHAR (p_start_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'')) >= to_date('''
            || TO_CHAR (p_start_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'')
                          )
             and not exists (select *
                               from dat x
                               join uss_person.v_b_famp b on (b.raj = x.raj and b.r_ncardp = x.r_ncardp and b.fam_nomf = 0)
                              where 1 = 1
                                and b.fam_dtbeg <= to_date('''
            || TO_CHAR (p_stop_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'')
                                and nvl(b.fam_dtexit, to_date('''
            || TO_CHAR (p_start_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'')) >= to_date('''
            || TO_CHAR (p_start_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'')
                            )
            -- order by b.fam_nomf
        ');

        reportfl_engine.adddataset (
            'ds2',
               'WITH dat AS (SELECT t.RAJ, t.R_NCARDP
                           FROM uss_person.v_x_trg t
                           join uss_person.v_sc_benefit_category c on c.scbc_id = t.trg_id and t.trg_code = ''USS_PERSON.SC_BENEFIT_CATEGORY''
                          WHERE c.scbc_sc = '
            || p_sc_id
            || '
                          FETCH FIRST ROW ONLY
                          )

          select k.katp_cd as c0,
                 to_char(l.klplgkat_name||'' (''||k.katp_cd||'')'') as cat_name, -- Категорії пільговика
                 to_char(u.underc_name) as subcat_name, --Підкатегорія
                 to_char(w.kllaw_name) as law_name, --Закон
                 to_char(l.klplgkat_stat) as law_det_name, --Стаття
                 to_char(k.katp_doc) as pasp_info, --серія та номер Посвідчення
                 to_char(k.katp_dt, ''DD.MM.YYYY'') as pasp_dt, --дата видачі
                 to_char(k.katp_dte, ''DD.MM.YYYY'') as pasp_end_dt, --термін дії
                 to_char(k.katp_dep) as pasp_who, --ким видане
                 to_char(sel2.cdd) as type_list, --Перелік видів пільг на які пільговик має право, відповідно до категорії -- тут буде довідник -- працюємо
                 decode(sel2.ozn,1,''так'',null) as is_main_cat
            from dat t
            JOIN uss_person.v_b_famp b ON (b.raj = t.RAJ AND b.R_NCARDP = t.R_NCARDP)
            left join uss_person.v_b_katpp k on b.raj = k.raj and b.r_ncardp = k.r_ncardp
            left join uss_person.v_b_klplgkat l on k.katp_cd = l.klplgkat_code
            left join uss_person.v_b_kllaw w on l.klplgkat_lcd = w.kllaw_code
            left join uss_person.v_b_osobap o on b.raj = o.raj and b.r_ncardp = o.r_ncardp and b.fam_nomf = o.osoba_nfam and o.osoba_code = ''1''||lpad(k.katp_cd,3,0) and o.osoba_dtbeg = to_date(''2000-01-01'',''YYYY-MM-DD'')
            left join uss_person.v_b_underc u on k.katp_cd = u.underc_kat and o.osoba_cdexit = u.underc_ukat
            left join (
            select sel.raj, sel.r_ncardp, sel.lg_cdkat, max(case when sel.tplgot_code in (5,6) then 1 else null end) ozn, LISTAGG(sel.tplgot_name, '', '') WITHIN GROUP (ORDER BY sel.tplgot_name) cdd
              from (select g.raj, g.r_ncardp, g.lg_cdkat, o.tplgot_code, o.tplgot_name
                      from uss_person.v_b_lgp g
                      JOIN dat zd ON (zd.raj = g.raj AND zd.r_ncardp = g.r_ncardp)
                      left join uss_person.v_b_lgot j on g.lg_cd = j.lgot_code
                      left join uss_person.v_b_tplgot o on j.lgot_cdtip = o.tplgot_code
                     where trunc(sysdate) between g.lg_dtb and g.lg_dte
                     group by g.raj, g.r_ncardp, g.lg_cdkat, o.tplgot_code, o.tplgot_name
                   ) sel
             group by sel.raj, sel.r_ncardp, sel.lg_cdkat
            ) sel2 on (b.raj = sel2.raj and b.r_ncardp = sel2.r_ncardp and k.katp_cd = sel2.lg_cdkat) -- тут буде довідник
           where trunc(sysdate) between b.fam_dtbeg and b.fam_dtexit -- діюча картка пільговика (по заякнику b.fam_nomf = 0)
             and b.fam_nomf = 0
                '
            || CASE
                   WHEN l_flag = 1
                   THEN
                       ' and k.katp_cd NOT IN (1, 2, 3, 4, 11, 12, 13, 22, 23, 58, 80, 85, 86, 87, 88, 136, 137, 138, 139)'
               END
            || '
           -- ORDER BY k.katp_cd, l.klplgkat_name
            union
            SELECT bc.nbc_id as c0,
                   bc.nbc_name || '' ('' || bc.nbc_code || '')'' AS c1, --Категорія пільговика
                   NULL AS c2,
                   NULL AS c3,
                   bc.nbc_norm_act AS c4,
                   d.scd_seria || d.scd_number AS c5,
                   to_char(d.scd_issued_dt, ''DD.MM.YYYY'') AS c6,
                   to_char(d.scd_start_dt, ''DD.MM.YYYY'') || '' '' || to_char(d.scd_stop_dt, ''DD.MM.YYYY'') AS c7,
                   d.scd_issued_who AS c8,
                   listagg(nbt.nbt_name, '', '') WITHIN GROUP (ORDER BY nbt.nbt_name) AS c9,
                   NULL AS c10
              FROM uss_person.v_sc_benefit_category t
              JOIN uss_ndi.v_ndi_benefit_category bc ON (nbc_id = scbc_nbc)
              left JOIN uss_person.v_sc_benefit_type bt ON (bt.scbt_scbc = t.scbc_id)
              left JOIN uss_ndi.v_ndi_benefit_type nbt ON (nbt_id = scbt_nbt)
              left JOIN uss_ndi.v_ndi_nbc_setup ON (nbcs_nbt = scbt_nbt AND nbcs_nbc = scbc_nbc)
              LEFT JOIN uss_person.v_sc_benefit_docs bd ON (bd.scbd_scbc = t.scbc_id)
              LEFT JOIN uss_person.v_Sc_Document d ON (d.scd_id = bd.scbd_scd)
             WHERE scbc_sc = '
            || p_sc_id
            || '
               AND scbc_st = ''A''
               and trunc(sysdate) between t.scbc_start_dt and nvl(t.scbc_stop_dt, sysdate)
               '
            || CASE
                   WHEN l_flag = 1
                   THEN
                       ' and bc.nbc_id NOT IN (1, 2, 3, 4, 11, 12, 13, 22, 23, 58, 80, 85, 86, 87, 88, 136, 137, 138, 139)'
               END
            || '
             GROUP BY bc.nbc_id, bc.nbc_code, nbc_name, bc.nbc_norm_act, d.scd_seria || d.scd_number, d.scd_issued_dt, d.scd_issued_who, d.scd_start_dt, d.scd_stop_dt
             ORDER BY c0
            ');

        reportfl_engine.adddataset (
            'ds3',
               'WITH dat AS (SELECT distinct t.RAJ, t.R_NCARDP
                           FROM uss_person.v_x_trg t
                           join uss_person.v_sc_benefit_category c on c.scbc_id = t.trg_id and t.trg_code = ''USS_PERSON.SC_BENEFIT_CATEGORY''
                          WHERE c.scbc_sc = '
            || p_sc_id
            || '
                           '
            || CASE WHEN l_flag = 1 THEN '
                            and t.com_org in (select u_org from tmp_org)
                            ' END
            || '
                          )
           select distinct
                  n.lg_cdkat AS cat_code, -- Категорія пільговика
                  n.lg_cd AS pilg_code, --код пільги
                  l.lgot_name AS pilg_name, -- назва пільги
                  n.lg_dtb,
                  to_char(GREATEST(n.lg_dtb, b.fam_dtbeg), ''DD.MM.YYYY'') ||''-''|| to_char(least(nvl(b.fam_dtexit, n.lg_dte), n.lg_dte), ''DD.MM.YYYY'') AS pilg_period, --Дата початку та кінця надання пільги
                  n.raj||''-''||n.r_ncardp ||''; ''||
                    b2.klat_name ||''; ''|| b1.klat_name || ''; '' || r.r_index ||''; ''|| ind.klind_adr || ''; ''
                    || ku.klkatul_name || '' '' || q.klul_name || ''; '' || nvl2(r.r_house, ''Буд. '' || r.r_house
                    || '' '', '''') || r.r_build || nvl2(r.r_apt, ''; кв. '' || r.r_apt, '''')
                   as addr,
                  t.tplgot_name AS gkp, -- ЖКП/СГТП
                  case when n.lg_kod <> 0 then g.klorgz_name ||'' (''||g.klorgz_code||'')'' else null end AS supplier, -- Організація надавач послуг
                  n.lg_cdo AS acc, --Особовий рахунок
                  s.riznpos_name AS service, --Різновид послуги
                  t.tar_cost AS tarif, --Тариф
                  (select mm.klpsn_name from uss_person.v_b_klpsn mm where mm.klpsn_code = (case when n.lg_cdpsn = 0 and trunc(sysdate) not between n.lg_dtb and n.lg_dte then 15
                     when n.lg_cdpsn <> 0 or (n.lg_cdpsn = 0 and trunc(sysdate) between b.fam_dtbeg and b.fam_dtexit) then n.lg_cdpsn
                     else b.fam_cdexit end)) AS stop_reason--, --Причина припинення пільги
             from dat t
             JOIN uss_person.v_b_lgp n ON (n.raj = t.raj and n.r_ncardp = t.r_ncardp)
             join uss_person.v_b_reestrlg r on n.raj = r.raj and n.r_ncardp = r.r_ncardp
             join uss_person.v_b_famp b on b.raj = r.raj and b.r_ncardp = r.r_ncardp and b.fam_nomf = 0 -- заявник -- пільговик
             left join uss_person.v_b_klul q on q.klul_codern = r.raj and q.klul_codeul = r.r_cdul
             left join uss_person.v_b_klkatul ku on ku.klkatul_code = q.klul_codekul
             left join uss_person.v_b_klat b1 on r.raj = b1.klat_code
             left join uss_person.v_b_klat b2 on trunc(r.raj,-2) = b2.klat_code
             left join uss_person.v_b_klind ind on r.r_index = ind.klind_ind
             left join uss_person.v_b_lgot l on n.lg_cd = l.lgot_code
             left join uss_person.v_b_tplgot t on l.lgot_cdtip = t.tplgot_code
             left join uss_person.v_b_klorgz g on n.raj = g.raj and n.lg_kod = g.klorgz_code  and n.lg_kod <> 0
             left join uss_person.v_b_klrizpos s on n.raj = s.raj and n.lg_cd = s.riznpos_cdpos and n.lg_paydservcd = s.riznpos_code
             left join uss_person.v_b_tarif t on n.raj = t.raj and n.lg_cd = t.tar_cdplg and n.lg_paydservcd = t.tar_serv and n.lg_paysys= t.tar_code and trunc(sysdate) between t.tar_dateb and t.tar_datee
            WHERE 1 = 1
              and (n.lg_dte is null or to_date('''
            || TO_CHAR (p_start_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'') <= n.lg_dte)
              and to_date('''
            || TO_CHAR (p_stop_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'') >= n.lg_dtb
          '
            || CASE
                   WHEN l_flag = 1
                   THEN
                       ' and n.LG_CDKAT NOT IN (1, 2, 3, 4, 11, 12, 13, 22, 23, 58, 80, 85, 86, 87, 88, 136, 137, 138, 139)'
               END
            || '
            order by n.lg_cdkat, n.lg_cd, n.lg_dtb
            ');
        /*
    reportfl_engine.adddataset('ds3',
      'WITH dat AS (SELECT distinct t.RAJ, t.R_NCARDP
                          FROM uss_person.v_x_trg t
                          join uss_person.v_sc_benefit_category c on c.scbc_id = t.trg_id and t.trg_code = ''USS_PERSON.SC_BENEFIT_CATEGORY''
                         WHERE c.scbc_sc = ' || p_sc_id || '
                          ' || CASE WHEN l_flag = 1 THEN '
                           and t.com_org in (select u_org from tmp_org)
                           ' END || '
                         )
          select distinct
                 n.lg_cdkat AS cat_code, -- Категорія пільговика
                 n.lg_cd AS pilg_code, --код пільги
                 l.lgot_name AS pilg_name, -- назва пільги
                 to_char(n.lg_dtb, ''DD.MM.YYYY'') ||''-''|| to_char(n.lg_dte, ''DD.MM.YYYY'') AS pilg_period, --Дата початку та кінця надання пільги
                 t.tplgot_name AS gkp, -- ЖКП/СГТП
                 case when n.lg_kod <> 0 then g.klorgz_name ||'' (''||g.klorgz_code||'')'' else null end AS supplier, -- Організація надавач послуг
                 n.lg_cdo AS acc, --Особовий рахунок
                 s.riznpos_name AS service, --Різновид послуги
                 t.tar_cost AS tarif, --Тариф
                 to_char(n.lg_dtb, ''DD.MM.YYYY'') ||''-''|| to_char(n.lg_dte, ''DD.MM.YYYY'') AS pilg_tp_period, --я незнаю що Вони мали на цувазі, є лише ця
                 p.klpsn_name AS stop_reason--, --Причина припинення пільги
            from dat t
            JOIN uss_person.v_b_lgp n ON (n.raj = t.raj and n.r_ncardp = t.r_ncardp)
            left join  uss_person.v_b_lgot l on n.lg_cd = l.lgot_code
            left join uss_person.v_b_tplgot t on l.lgot_cdtip = t.tplgot_code
            left join uss_person.v_b_klorgz g on n.raj = g.raj and n.lg_kod = g.klorgz_code  and n.lg_kod <> 0
            left join uss_person.v_b_klrizpos s on n.raj = s.raj and n.lg_cd = s.riznpos_cdpos and n.lg_paydservcd = s.riznpos_code
            left join uss_person.v_b_tarif t on n.raj = t.raj and n.lg_cd = t.tar_cdplg and n.lg_paydservcd = t.tar_serv and n.lg_paysys= t.tar_code and trunc(sysdate) between t.tar_dateb and t.tar_datee
            left join uss_person.v_b_klpsn p on n.lg_cdpsn = p.klpsn_code
           WHERE 1 = 1
             and (n.lg_dte is null or to_date(''' || to_char(p_start_dt, 'DD.MM.YYYY') || ''', ''DD.MM.YYYY'') <= n.lg_dte)
             and to_date(''' || to_char(p_stop_dt, 'DD.MM.YYYY') || ''', ''DD.MM.YYYY'') >= n.lg_dtb
         ' || CASE WHEN l_flag = 1 THEN ' and n.LG_CDKAT NOT IN (1, 2, 3, 4, 11, 12, 13, 22, 23, 58, 80, 85, 86, 87, 88, 136, 137, 138, 139)' END || '
           order by n.lg_cdkat, n.lg_cd
           '
     );
        */
        reportfl_engine.adddataset (
            'ds4',
               'WITH dat AS (SELECT distinct t.RAJ, t.R_NCARDP
                           FROM uss_person.v_x_trg t
                           join uss_person.v_sc_benefit_category c on c.scbc_id = t.trg_id and t.trg_code = ''USS_PERSON.SC_BENEFIT_CATEGORY''
                          WHERE c.scbc_sc = '
            || p_sc_id
            || '
                           '
            || CASE
                   WHEN l_flag = 1
                   THEN
                       'and t.com_org in (select u_org from tmp_org)'
               END
            || '
                          )
           select distinct to_char(year) || to_char(month) as main_param,
                  year,
                  month
             from (
             select
                    h.lgnac_godin as year, -- рік нарахування
                    h.lgnac_mecin as month -- місяць нарахування
               from dat t
               JOIN uss_person.v_b_lgp n ON (n.raj = t.raj and n.r_ncardp = t.r_ncardp)
               left join  uss_person.v_b_lgot l on (n.lg_cd = l.lgot_code)
               left join uss_person.v_b_klvposl k on (n.lg_cd = k.klvposl_cdposl)
               left join uss_person.v_b_lgnacp h on (n.raj = h.raj and n.r_ncardp = h.r_ncardp and n.lg_cdkat = h.lg_cdkat and n.lg_cd = h.lg_cd and n.lg_dtb = h.lg_dtb)
              where 1 = 1
                and h.LGNAC_MECIN is not null
                and h.LGNAC_GODIN is not null
                and to_date(''01.''||to_char(h.lgnac_mecin)||''.''||to_char(h.lgnac_godin), ''DD.MM.YYYY'') between to_date('''
            || TO_CHAR (p_start_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'') and to_date('''
            || TO_CHAR (p_stop_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'')
                and nvl(h.lgnac_sum,0) <> 0

          '
            || CASE
                   WHEN l_flag = 1
                   THEN
                       '
              and n.LG_CDKAT NOT IN (1, 2, 3, 4, 11, 12, 13, 22, 23, 58, 80, 85, 86, 87, 88, 136, 137, 138, 139)
                '
               END
            || '
            union all
            SELECT scp3_year as year,
                   to_number(pmonth) as month
             from uss_person.v_sc_pfu_pay_period t
             JOIN uss_person.v_sc_pfu_pay_summary ps ON (ps.scpp_id = t.scp3_scpp and ps.scpp_pfu_payment_tp = ''BENEFIT'')
             left JOIN uss_ndi.v_ndi_benefit_category c ON (c.nbc_id = t.scp3_nbc)
             JOIN uss_ndi.v_ndi_pfu_payment_type p ON (p.nppt_id = t.scp3_nppt)
            unpivot(
             period_sum for pmonth in (
              scp3_sum_m1 as ''1'',
              scp3_sum_m2 as ''2'',
              scp3_sum_m3 as ''3'',
              scp3_sum_m4 as ''4'',
              scp3_sum_m5 as ''5'',
              scp3_sum_m6 as ''6'',
              scp3_sum_m7 as ''7'',
              scp3_sum_m8 as ''8'',
              scp3_sum_m9 as ''9'',
              scp3_sum_m10 as ''10'',
              scp3_sum_m11 as ''11'',
              scp3_sum_m12 as ''12''
             )

            )
            where scp3_sc  = '
            || p_sc_id
            || '
          '
            || CASE
                   WHEN l_flag = 1
                   THEN
                       '
              and (scp3_nbc is null or scp3_nbc NOT IN (1, 2, 3, 4, 11, 12, 13, 22, 23, 58, 80, 85, 86, 87, 88, 136, 137, 138, 139) )
                '
               END
            || '
              and to_date(''01.''||pmonth||''.''||to_char(scp3_year), ''DD.MM.YYYY'') between to_date('''
            || TO_CHAR (p_start_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'') and to_date('''
            || TO_CHAR (p_stop_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'')
        )
        order by year, month
          ');

        reportfl_engine.adddataset (
            'ds4_m',
               'WITH dat AS (SELECT distinct t.RAJ, t.R_NCARDP
                           FROM uss_person.v_x_trg t
                           join uss_person.v_sc_benefit_category c on c.scbc_id = t.trg_id and t.trg_code = ''USS_PERSON.SC_BENEFIT_CATEGORY''
                          WHERE c.scbc_sc = '
            || p_sc_id
            || '
                           '
            || CASE
                   WHEN l_flag = 1
                   THEN
                       'and t.com_org in (select u_org from tmp_org)'
               END
            || '
                          )
           select t.*,
                  to_char(year) || to_char(month) as param,
                  row_number() over (order by year_to, month_to, code) as rn
            from (
             select to_char(n.lg_cd) as code, --код пільги
                    to_char(nvl(l.lgot_name,k.klvposl_name)) as name, -- назва пільги
                    h.lgnac_godin as year, -- рік нарахування
                    h.lgnac_mecin as month, -- місяць нарахування
                    h.lgnac_god as year_to,
                    h.lgnac_mec as month_to,
                    to_char(h.lgnac_sum, ''FM9999999999999990D00'', ''NLS_NUMERIC_CHARACTERS='''','''''''''') as pilg_sum
               from dat t
               JOIN uss_person.v_b_lgp n ON (n.raj = t.raj and n.r_ncardp = t.r_ncardp)
               left join  uss_person.v_b_lgot l on (n.lg_cd = l.lgot_code)
               left join uss_person.v_b_klvposl k on (n.lg_cd = k.klvposl_cdposl)
               left join uss_person.v_b_lgnacp h on (n.raj = h.raj and n.r_ncardp = h.r_ncardp and n.lg_cdkat = h.lg_cdkat and n.lg_cd = h.lg_cd and n.lg_dtb = h.lg_dtb)
              where 1 = 1
                and h.LGNAC_MECIN is not null
                and h.LGNAC_GODIN is not null
                and to_date(''01.''||to_char(h.lgnac_mecin)||''.''||to_char(h.lgnac_godin), ''DD.MM.YYYY'') between to_date('''
            || TO_CHAR (p_start_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'') and to_date('''
            || TO_CHAR (p_stop_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'')
                and nvl(h.lgnac_sum,0) <> 0

          '
            || CASE
                   WHEN l_flag = 1
                   THEN
                       '
              and n.LG_CDKAT NOT IN (1, 2, 3, 4, 11, 12, 13, 22, 23, 58, 80, 85, 86, 87, 88, 136, 137, 138, 139)
                '
               END
            || '
            union
            SELECT nppt_code as code,
                   nppt_name as name,
                   scp3_year as year,
                   to_number(pmonth) as month,
                   scp3_year as year_to,
                   to_number(pmonth) as month_to,
                   to_char(period_sum, ''FM9999999999999990D00'', ''NLS_NUMERIC_CHARACTERS='''','''''''''')  as pilg_sum
             from uss_person.v_sc_pfu_pay_period t
             JOIN uss_person.v_sc_pfu_pay_summary ps ON (ps.scpp_id = t.scp3_scpp and ps.scpp_pfu_payment_tp = ''BENEFIT'')
             left JOIN uss_ndi.v_ndi_benefit_category c ON (c.nbc_id = t.scp3_nbc)
             JOIN uss_ndi.v_ndi_pfu_payment_type p ON (p.nppt_id = t.scp3_nppt)
            unpivot(
             period_sum for pmonth in (
              scp3_sum_m1 as ''1'',
              scp3_sum_m2 as ''2'',
              scp3_sum_m3 as ''3'',
              scp3_sum_m4 as ''4'',
              scp3_sum_m5 as ''5'',
              scp3_sum_m6 as ''6'',
              scp3_sum_m7 as ''7'',
              scp3_sum_m8 as ''8'',
              scp3_sum_m9 as ''9'',
              scp3_sum_m10 as ''10'',
              scp3_sum_m11 as ''11'',
              scp3_sum_m12 as ''12''
             )

            )
            where scp3_sc  = '
            || p_sc_id
            || '
          '
            || CASE
                   WHEN l_flag = 1
                   THEN
                       '
              and (scp3_nbc is null or scp3_nbc NOT IN (1, 2, 3, 4, 11, 12, 13, 22, 23, 58, 80, 85, 86, 87, 88, 136, 137, 138, 139) )
                '
               END
            || '

              and to_date(''01.''||pmonth||''.''||to_char(scp3_year), ''DD.MM.YYYY'') between to_date('''
            || TO_CHAR (p_start_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'') and to_date('''
            || TO_CHAR (p_stop_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'')
        ) t
        where 1 = 1
          ');

        reportfl_engine.adddataset (
            'ds4_t',
               'WITH dat AS (SELECT distinct t.RAJ, t.R_NCARDP
                           FROM uss_person.v_x_trg t
                           join uss_person.v_sc_benefit_category c on c.scbc_id = t.trg_id and t.trg_code = ''USS_PERSON.SC_BENEFIT_CATEGORY''
                          WHERE c.scbc_sc = '
            || p_sc_id
            || '
                           '
            || CASE
                   WHEN l_flag = 1
                   THEN
                       'and t.com_org in (select u_org from tmp_org)'
               END
            || '
                          )
           select t.year,
                  t.month,
                  to_char(year) || to_char(month) as param,
                  to_char(sum(t.pilg_sum), ''FM9999999999999990D00'', ''NLS_NUMERIC_CHARACTERS='''','''''''''') as tot_sum
            from (
             select h.lgnac_godin as year, -- рік нарахування
                    h.lgnac_mecin as month, -- місяць нарахування
                    h.lgnac_sum as pilg_sum
               from dat t
               JOIN uss_person.v_b_lgp n ON (n.raj = t.raj and n.r_ncardp = t.r_ncardp)
               left join  uss_person.v_b_lgot l on (n.lg_cd = l.lgot_code)
               left join uss_person.v_b_klvposl k on (n.lg_cd = k.klvposl_cdposl)
               left join uss_person.v_b_lgnacp h on (n.raj = h.raj and n.r_ncardp = h.r_ncardp and n.lg_cdkat = h.lg_cdkat and n.lg_cd = h.lg_cd and n.lg_dtb = h.lg_dtb)
              where 1 = 1 /*trunc(sysdate) between n.lg_dtb and n.lg_dte*/
                /*and to_date('''
            || TO_CHAR (p_start_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'') <= n.lg_dte
                and to_date('''
            || TO_CHAR (p_stop_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'') >= n.lg_dtb*/
                and h.LGNAC_MECIN is not null
                and h.LGNAC_GODIN is not null
                and to_date(''01.''||to_char(h.lgnac_mecin)||''.''||to_char(h.lgnac_godin), ''DD.MM.YYYY'') between to_date('''
            || TO_CHAR (p_start_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'') and to_date('''
            || TO_CHAR (p_stop_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'')
                and nvl(h.lgnac_sum,0) <> 0

          '
            || CASE
                   WHEN l_flag = 1
                   THEN
                       '
              and n.LG_CDKAT NOT IN (1, 2, 3, 4, 11, 12, 13, 22, 23, 58, 80, 85, 86, 87, 88, 136, 137, 138, 139)
                '
               END
            || '
            union
            SELECT scp3_year as year,
                   to_number(pmonth) as month,
                   period_sum  as pilg_sum
             from uss_person.v_sc_pfu_pay_period t
             JOIN uss_person.v_sc_pfu_pay_summary ps ON (ps.scpp_id = t.scp3_scpp and ps.scpp_pfu_payment_tp = ''BENEFIT'')
             left JOIN uss_ndi.v_ndi_benefit_category c ON (c.nbc_id = t.scp3_nbc)
             JOIN uss_ndi.v_ndi_pfu_payment_type p ON (p.nppt_id = t.scp3_nppt)
            unpivot(
             period_sum for pmonth in (
              scp3_sum_m1 as ''1'',
              scp3_sum_m2 as ''2'',
              scp3_sum_m3 as ''3'',
              scp3_sum_m4 as ''4'',
              scp3_sum_m5 as ''5'',
              scp3_sum_m6 as ''6'',
              scp3_sum_m7 as ''7'',
              scp3_sum_m8 as ''8'',
              scp3_sum_m9 as ''9'',
              scp3_sum_m10 as ''10'',
              scp3_sum_m11 as ''11'',
              scp3_sum_m12 as ''12''
             )

            )
            where scp3_sc  = '
            || p_sc_id
            || '
          '
            || CASE
                   WHEN l_flag = 1
                   THEN
                       '
              and (scp3_nbc is null or scp3_nbc NOT IN (1, 2, 3, 4, 11, 12, 13, 22, 23, 58, 80, 85, 86, 87, 88, 136, 137, 138, 139) )
                '
               END
            || '

              and to_date(''01.''||pmonth||''.''||to_char(scp3_year), ''DD.MM.YYYY'') between to_date('''
            || TO_CHAR (p_start_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'') and to_date('''
            || TO_CHAR (p_stop_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY'')
        ) t
        group by year, month
        having 1 = 1
          ');
        reportfl_engine.AddRelation ('ds4',
                                     'main_param',
                                     'ds4_m',
                                     'param');
        reportfl_engine.AddRelation ('ds4',
                                     'main_param',
                                     'ds4_t',
                                     'param');

        l_blob := reportfl_engine.PublishReportBlob;

        uss_person.Api$socialcard.write_sc_log (p_sc_id,
                                                NULL,
                                                NULL,
                                                CHR (38) || '223',
                                                NULL,
                                                NULL);

        OPEN p_res_doc FOR
            SELECT t.rt_name || '.pdf'     AS FileName,
                   'application/pdf'       AS MimeType,
                   l_blob                  AS Content
              FROM rpt_templates t
             WHERE t.rt_code = 'EDARP_DOVIDKA_R1';
    END;

    PROCEDURE get_sc_moz_dovidka (p_sc_id      IN     NUMBER,
                                  p_is_error      OUT VARCHAR2,
                                  p_doc_name      OUT VARCHAR2,
                                  p_blob          OUT BLOB)
    IS
    BEGIN
        dnet$rpt_annex.get_dovidka_61_rpt_blob (NULL,
                                                p_sc_id,
                                                p_is_error,
                                                p_doc_name,
                                                p_blob);
        uss_person.Api$socialcard.write_sc_log (p_sc_id,
                                                NULL,
                                                NULL,
                                                CHR (38) || '332',
                                                NULL,
                                                NULL);
    END;

    --Отримувачі житлових субсидій на оплату ЖКП за видами опалення  SUBSIDY_TYPE_HEATING
    FUNCTION JKP_SUBSIDY_TYPE_HEATING (
        p_start_dt   IN DATE,
        p_kaot_id    IN NUMBER,
        p_rt_id      IN rpt_templates.rt_id%TYPE)
        RETURN DECIMAL
    IS
        l_jbr_id       NUMBER;
        l_date         DATE := TRUNC (p_start_dt, 'mm');
        l_sql          VARCHAR2 (32000);
        --l_sql_obl varchar2(32000);
        --l_org_to NUMBER;
        l_level        NUMBER;
        l_level_data   NUMBER;
        l_level_name   VARCHAR2 (500);
    BEGIN
        l_jbr_id :=
            RDM$RTFL.InitReport (p_rt_id      => p_rt_id,
                                 p_rpt_name   => 'Субсидії_ЖКП_за_опаленням');
        RDM$RTFL.AddParam (l_jbr_id,
                           'p_date',
                           TO_CHAR (ADD_MONTHS (l_date, 1), 'dd.mm.yyyy'));
        RDM$RTFL.AddParam (l_jbr_id,
                           'gen_dt',
                           TO_CHAR (SYSDATE, 'dd.mm.yyyy'));
        rdm$rtfl.SetFileName (
            l_jbr_id,
               'Субсидії_ЖКП_за_опаленням'
            || '_'
            || TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS')
            || '.XLS');

        get_kaot_info (p_kaot_id,
                       l_level,
                       l_level_data,
                       l_level_name);

        /*SELECT MAX(org_to)
          INTO l_org_to
          FROM v_opfu t
          WHERE org_id = p_org_id;
        l_sql:= q'[
           with
             d as (select :START# dt, extract(YEAR from :START#) yyyy, extract(MONTH from :START#) mm from dual),
             t as
              (
               select
                      row_number() over(order by nlssort(Sca_Region, 'NLS_SORT=ukrainian')) rn,
                      Sca_Region Region,
                      count(distinct case when cnt > 0 then sca_id end) as count_all_all,
                      count(distinct case when cnt > 0 and nppt_code in ('107.1', '102.1', '108.1') then sca_id end) count_all,
                      sum(case when nppt_code in ('107.1', '102.1', '108.1') then sm end) sum_all,

                      --Централізоване теплопостачання: за постачання теплової енергії
                      count(distinct case when nppt_code = '107.1' and cnt > 0 then sca_id end) count_107,
                      sum(case when nppt_code = '107.1' then sm else 0 end) sum_107,

                      --Послуга з постачання природного газу: на опалення
                      count(distinct case when nppt_code = '102.1' and cnt > 0 then sca_id end ) count_102,
                      sum(case when nppt_code = '102.1' then sm else 0 end) sum_102,

                      --Послуга з постачання електричної енергії: на опалення
                      count(distinct case when nppt_code in ('108.1') and cnt > 0 then sca_id end) count_108,
                      sum(case when nppt_code in ('108.1') then sm else 0 end) sum_108,

                      -- некоректні записи: невизначено вид опалення (кількість)
                      count(distinct case when nppt_code is null and cnt > 0 then sca_id end) as err_cnt,
                      -- некоректні записи: невизначено вид опалення (сума)
                      sum(case when nppt_code is null then sm else 0 end)  as err_sum

                 from
                     (select sca.Sca_Region, nppt.nppt_code, sca.sca_id,
                             case d.mm
                               when 1  then p3.scp3_sum_m1
                               when 2  then p3.scp3_sum_m2
                               when 3  then p3.scp3_sum_m3
                               when 4  then p3.scp3_sum_m4
                               when 5  then p3.scp3_sum_m5
                               when 6  then p3.scp3_sum_m6
                               when 7  then p3.scp3_sum_m7
                               when 8  then p3.scp3_sum_m8
                               when 9  then p3.scp3_sum_m9
                               when 10 then p3.scp3_sum_m10
                               when 11 then p3.scp3_sum_m11
                               when 12 then p3.scp3_sum_m12
                               else 0
                             end sm,
                             case
                               when d.mm =  1 and p3.scp3_sum_m1 > 0 then 1
                               when d.mm =  2 and p3.scp3_sum_m2 > 0 then 1
                               when d.mm =  3 and p3.scp3_sum_m3 > 0 then 1
                               when d.mm =  4 and p3.scp3_sum_m4 > 0 then 1
                               when d.mm =  5 and p3.scp3_sum_m5 > 0 then 1
                               when d.mm =  6 and p3.scp3_sum_m6 > 0 then 1
                               when d.mm =  7 and p3.scp3_sum_m7 > 0 then 1
                               when d.mm =  8 and p3.scp3_sum_m8 > 0 then 1
                               when d.mm =  9 and p3.scp3_sum_m9 > 0 then 1
                               when d.mm = 10 and p3.scp3_sum_m10 > 0 then 1
                               when d.mm = 11 and p3.scp3_sum_m11 > 0 then 1
                               when d.mm = 12 and p3.scp3_sum_m12 > 0 then 1
                               else 0
                             end cnt
                        from d,
                             uss_person.v_sc_pfu_pay_period p3,
                             uss_person.v_sc_pfu_pay_summary pps,
                             uss_person.v_sc_household sch,
                             uss_person.v_Sc_Address sca,
                             uss_ndi.v_ndi_pfu_payment_type nppt
                       where p3.scp3_year = d.yyyy
                         and pps.scpp_id = p3.scp3_scpp
                         and pps.scpp_pfu_payment_tp = 'SUBSIDY'
                         and sch.schh_id = pps.scpp_schh
                         --and sca.sca_id = sch.schh_sca
                         and sca.sca_sc = p3.scp3_sc
                         and sca.sca_tp = '5'
                         and sca.history_status = 'A'
                         and nppt.nppt_id(+) = p3.scp3_nppt
                         --and (nppt.nppt_code in ('107.1', '102.1', '108.1') or nppt_code is null )
                         and d.dt between pps.scpp_pfu_pd_start_dt and pps.scpp_pfu_pd_stop_dt
                         and pps.scpp_pfu_pd_st not in ('PS', 'V')
                         and (nppt.nppt_id not in (13000, 14000) or nppt.nppt_id is null)
                     )
                 group by Sca_Region
              )

             select rn,
                    region,--    "назва області",
                    count_all_all,-- " діючих субсидій на оплату ЖКП, всього (домогосподарств)",
                    count_all,-- "кількість домогосподарств, де є послуга опалення",
                    sum_all,--   "розмір нарахованої субсидії, де є послуга опалення, всього (грн)",
                    count_107,-- "централізоване (кількість)",
                    sum_107,--   "централізоване, розмір субсидії (грн)",
                    count_102,-- "газопостачання на опалення (кількість)",
                    sum_102,--   "газопостачання на опалення, розмір субсидії (грн)",
                    count_108,-- "електроенергія на опалення (кількість)",
                    sum_108,--   "електроенергія на опалення, розмір субсидії (грн)",
                    --to_char(dt, 'Month yyyy', 'NLS_DATE_LANGUAGE = ukrainian') "Звітній місяць"
                    err_cnt, -- некоректні записи: невизначено вид опалення (кількість)
                    err_sum -- некоректні записи: невизначено вид опалення (сума)
               from
                    (select rn+1 rn,
                            case when (lower(Region)) = 'київ' then 'м. ' || initCap(Region)
                                when Region is not null then initCap(Region) || ' обл.'
                            end as Region,
                            count_all_all,
                            count_all, sum_all, count_107, sum_107,
                            count_102, sum_102, count_108, sum_108, err_cnt, err_sum
                       from t
                     union all
                     select 1 rn, 'УКРАЇНА', sum(count_all_all), sum(count_all), sum(sum_all),
                            sum(count_107), sum(sum_107), sum(count_102), sum(sum_102),
                            sum(count_108), sum(sum_108), sum(err_cnt), sum(err_sum)
                       from t
                    ), d
            order by rn

        ]';

        l_sql_obl := q'[
           with
             d as (select :START# dt, extract(YEAR from :START#) yyyy, extract(MONTH from :START#) mm from dual),
             t as
              (
               select
                      row_number() over(order by nlssort(Sca_Region, 'NLS_SORT=ukrainian')) rn,
                      Sca_Region Region,
                      count(distinct case when cnt > 0 then sca_id end) count_all_all,
                      count(distinct case when cnt > 0 and nppt_code in ('107.1', '102.1', '108.1') then sca_id end) count_all,
                      sum(case when nppt_code in ('107.1', '102.1', '108.1') then sm end) sum_all,

                      --Централізоване теплопостачання: за постачання теплової енергії
                      count(distinct case when nppt_code = '107.1' and cnt > 0 then sca_id end) count_107,
                      sum(case when nppt_code = '107.1' then sm else 0 end) sum_107,

                      --Послуга з постачання природного газу: на опалення
                      count(distinct case when nppt_code = '102.1' and cnt > 0 then sca_id end ) count_102,
                      sum(case when nppt_code = '102.1' then sm else 0 end) sum_102,

                      --Послуга з постачання електричної енергії: на опалення
                      count(distinct case when nppt_code in ('108.1') and cnt > 0 then sca_id end) count_108,
                      sum(case when nppt_code in ('108.1') then sm else 0 end) sum_108,

                      -- некоректні записи: невизначено вид опалення (кількість)
                      count(distinct case when nppt_code is null and cnt > 0 then sca_id end) as err_cnt,
                      -- некоректні записи: невизначено вид опалення (сума)
                      sum(case when nppt_code is null then sm else 0 end)  as err_sum

                 from
                     (select pr.org_name as Sca_Region, nppt.nppt_code, sca_id,
                             case d.mm
                               when 1  then p3.scp3_sum_m1
                               when 2  then p3.scp3_sum_m2
                               when 3  then p3.scp3_sum_m3
                               when 4  then p3.scp3_sum_m4
                               when 5  then p3.scp3_sum_m5
                               when 6  then p3.scp3_sum_m6
                               when 7  then p3.scp3_sum_m7
                               when 8  then p3.scp3_sum_m8
                               when 9  then p3.scp3_sum_m9
                               when 10 then p3.scp3_sum_m10
                               when 11 then p3.scp3_sum_m11
                               when 12 then p3.scp3_sum_m12
                               else 0
                             end sm,
                             case
                               when d.mm =  1 and p3.scp3_sum_m1 > 0 then 1
                               when d.mm =  2 and p3.scp3_sum_m2 > 0 then 1
                               when d.mm =  3 and p3.scp3_sum_m3 > 0 then 1
                               when d.mm =  4 and p3.scp3_sum_m4 > 0 then 1
                               when d.mm =  5 and p3.scp3_sum_m5 > 0 then 1
                               when d.mm =  6 and p3.scp3_sum_m6 > 0 then 1
                               when d.mm =  7 and p3.scp3_sum_m7 > 0 then 1
                               when d.mm =  8 and p3.scp3_sum_m8 > 0 then 1
                               when d.mm =  9 and p3.scp3_sum_m9 > 0 then 1
                               when d.mm = 10 and p3.scp3_sum_m10 > 0 then 1
                               when d.mm = 11 and p3.scp3_sum_m11 > 0 then 1
                               when d.mm = 12 and p3.scp3_sum_m12 > 0 then 1
                               else 0
                             end cnt
                        from d,
                             uss_person.v_sc_pfu_pay_period p3,
                             uss_person.v_sc_pfu_pay_summary pps,
                             uss_person.v_sc_household sch,
                             uss_person.v_Sc_Address sca,
                             uss_ndi.v_ndi_pfu_payment_type nppt,
                             uss_ndi.v_ndi_org2kaot k,
                             v_opfu pr,
                             v_opfu po
                       where p3.scp3_year = d.yyyy
                         and pps.scpp_id = p3.scp3_scpp
                         and pps.scpp_pfu_payment_tp = 'SUBSIDY'
                         and sch.schh_id = pps.scpp_schh
                         --and sca.sca_id = sch.schh_sca
                         and sca.sca_sc = p3.scp3_sc
                         and sca.sca_tp = '5'
                         and sca.history_status = 'A'
                         and nppt.nppt_id(+) = p3.scp3_nppt
                         --and (nppt.nppt_code in ('107.1', '102.1', '108.1') or nppt_id is null)
                         and d.dt between pps.scpp_pfu_pd_start_dt and pps.scpp_pfu_pd_stop_dt
                         and pps.scpp_pfu_pd_st not in ('PS', 'V')
                         and (nppt.nppt_id not in (13000, 14000) or nppt_id is null)
                         AND k.nok_kaot = sca.sca_kaot
                         and k.history_status = 'A'
                         and nppt.nppt_id = p3.scp3_nppt
                         --and d.dt between nvl(k.nk2o_start_dt, d.dt) AND nvl(k.nk2o_stop_dt, d.dt)
                         AND pr.org_id = k.nok_org
                         AND po.org_id = decode(pr.org_to, 32, pr.org_org, pr.org_id)
                         AND ]' || CASE WHEN l_org_to = 31 THEN ' po.org_id = ' || p_org_id  ELSE ' pr.org_id = ' || p_org_id  END || '
                     )
                 group by Sca_Region
              )

             select rn,
                    region,--    "назва області",
                    count_all_all,-- " діючих субсидій на оплату ЖКП, всього (домогосподарств)",
                    count_all,-- "кількість домогосподарств, де є послуга опалення",
                    sum_all,--   "розмір нарахованої субсидії, де є послуга опалення, всього (грн)",
                    count_107,-- "централізоване (кількість)",
                    sum_107,--   "централізоване, розмір субсидії (грн)",
                    count_102,-- "газопостачання на опалення (кількість)",
                    sum_102,--   "газопостачання на опалення, розмір субсидії (грн)",
                    count_108,-- "електроенергія на опалення (кількість)",
                    sum_108,--   "електроенергія на опалення, розмір субсидії (грн)",
                    --to_char(dt, ''Month yyyy'', ''NLS_DATE_LANGUAGE = ukrainian'') "Звітній місяць"
                    err_cnt, -- некоректні записи: невизначено вид опалення (кількість)
                    err_sum -- некоректні записи: невизначено вид опалення (сума)
               from
                    (select rn+1 rn,
                            Region,
                            count_all_all,
                            count_all, sum_all, count_107, sum_107,
                            count_102, sum_102, count_108, sum_108, err_cnt, err_sum
                       from t
                    ), d
            order by rn

        ';*/

        l_sql :=
               q'[
       with
         d as (select :START# dt, extract(YEAR from :START#) yyyy, extract(MONTH from :START#) mm from dual),
         t as
          (
          select row_number() over(order by DECODE(Region, 'невизначено або відсутні дані', 9999, 0), nlssort(Region, 'NLS_SORT=ukrainian')) rn,
                 Region,
                 count(distinct case when count_all_all > 0 then sca_id end) as count_all_all,
                 count(distinct case when count_all > 0 then sca_id end) as count_all,
                 sum(sum_all) as sum_all,

                  --Централізоване теплопостачання: за постачання теплової енергії
                  count(distinct case when count_107 > 0 then sca_id end) as count_107,
                  sum(sum_107) as sum_107,

                  --Послуга з постачання природного газу: на опалення
                  count(distinct case when count_102 > 0 and count_108 > 0 then null when count_102 > 0 then sca_id end) count_102,
                  sum(case when count_102 > 0 and count_108 > 0 then 0 else sum_102 end) sum_102,

                  --Послуга з постачання електричної енергії: на опалення
                  count(distinct case when count_102 > 0 and count_108 > 0 then null when count_108 > 0 then sca_id end) count_108,
                  sum(case when count_102 > 0 and count_108 > 0 then 0 else sum_108 end) sum_108,

                  -- некоректні записи: невизначено вид опалення (кількість)
                  count(distinct case when err_cnt > 0 then sca_id when count_102 > 0 and count_108 > 0 then sca_id end) as err_cnt,
                  -- некоректні записи: невизначено вид опалення (сума)
                  sum(case when err_sum > 0 then err_sum when count_102 > 0 and count_108 > 0 then nvl(sum_102, 0) + nvl(sum_108, 0) end)  as err_sum
            from (
           select
                  Sca_Region Region,
                  sca_id,
                  count(distinct case when cnt > 0 then sca_id end) as count_all_all,
                  count(distinct case when cnt > 0 and nppt_code in ('107.1', '102.1', '108.1') then sca_id end) count_all,
                  sum(case when nppt_code in ('107.1', '102.1', '108.1') then sm end) sum_all,

                  --Централізоване теплопостачання: за постачання теплової енергії
                  count(distinct case when nppt_code = '107.1' and cnt > 0 then sca_id end) count_107,
                  sum(case when nppt_code = '107.1' then sm else 0 end) sum_107,

                  --Послуга з постачання природного газу: на опалення
                  count(distinct case when nppt_code = '102.1' and cnt > 0 then sca_id end ) count_102,
                  sum(case when nppt_code = '102.1' then sm else 0 end) sum_102,

                  --Послуга з постачання електричної енергії: на опалення
                  count(distinct case when nppt_code in ('108.1') and cnt > 0 then sca_id end) count_108,
                  sum(case when nppt_code in ('108.1') then sm else 0 end) sum_108,

                  -- некоректні записи: невизначено вид опалення (кількість)
                  count(distinct case when nppt_code is null and cnt > 0 then sca_id end) as err_cnt,
                  -- некоректні записи: невизначено вид опалення (сума)
                  sum(case when nppt_code is null then sm else 0 end)  as err_sum

             from
                 (select nvl(kd.kaot_full_name, 'невизначено або відсутні дані') Sca_Region, nppt.nppt_code, sca.sca_id,
                         case d.mm
                           when 1  then p3.scp3_sum_m1
                           when 2  then p3.scp3_sum_m2
                           when 3  then p3.scp3_sum_m3
                           when 4  then p3.scp3_sum_m4
                           when 5  then p3.scp3_sum_m5
                           when 6  then p3.scp3_sum_m6
                           when 7  then p3.scp3_sum_m7
                           when 8  then p3.scp3_sum_m8
                           when 9  then p3.scp3_sum_m9
                           when 10 then p3.scp3_sum_m10
                           when 11 then p3.scp3_sum_m11
                           when 12 then p3.scp3_sum_m12
                           else 0
                         end sm,
                         case
                           when d.mm =  1 and p3.scp3_sum_m1 > 0 then 1
                           when d.mm =  2 and p3.scp3_sum_m2 > 0 then 1
                           when d.mm =  3 and p3.scp3_sum_m3 > 0 then 1
                           when d.mm =  4 and p3.scp3_sum_m4 > 0 then 1
                           when d.mm =  5 and p3.scp3_sum_m5 > 0 then 1
                           when d.mm =  6 and p3.scp3_sum_m6 > 0 then 1
                           when d.mm =  7 and p3.scp3_sum_m7 > 0 then 1
                           when d.mm =  8 and p3.scp3_sum_m8 > 0 then 1
                           when d.mm =  9 and p3.scp3_sum_m9 > 0 then 1
                           when d.mm = 10 and p3.scp3_sum_m10 > 0 then 1
                           when d.mm = 11 and p3.scp3_sum_m11 > 0 then 1
                           when d.mm = 12 and p3.scp3_sum_m12 > 0 then 1
                           else 0
                         end cnt
                    from d,
                         uss_person.v_sc_pfu_pay_period p3,
                         uss_person.v_sc_pfu_pay_summary pps,
                         uss_person.v_sc_household sch,
                         uss_person.v_Sc_Address sca,
                         uss_ndi.v_ndi_pfu_payment_type nppt,
                         uss_ndi.v_ndi_katottg k,
                         uss_ndi.v_ndi_katottg km,
                         uss_ndi.v_ndi_katottg kd
                   where p3.scp3_year = d.yyyy
                     and pps.scpp_id = p3.scp3_scpp
                     and pps.scpp_pfu_payment_tp = 'SUBSIDY'
                     and sch.schh_id = pps.scpp_schh
                     --and sca.sca_id = sch.schh_sca
                     and sca.sca_sc = p3.scp3_sc
                     and sca.sca_tp = '5'
                     and sca.history_status = 'A'
                     and k.kaot_id = sca.sca_kaot
                     and km.kaot_id = k.kaot_kaot_l]'
            || l_level
            || '
                     and kd.kaot_id(+) = k.kaot_kaot_l'
            || l_level_data
            || CASE
                   WHEN p_kaot_id IS NOT NULL AND p_kaot_id != 0
                   THEN
                       ' and km.kaot_id = ' || p_kaot_id
               END
            || '
                     and nppt.nppt_id(+) = p3.scp3_nppt
                     and d.dt between pps.scpp_pfu_pd_start_dt and pps.scpp_pfu_pd_stop_dt
                     and pps.scpp_pfu_pd_st not in (''PS'', ''V'')
                     and (nppt.nppt_id not in (13000, 14000) or nppt.nppt_id is null)
                 )
             group by Sca_Region, sca_Id )
            group by Region
          )

         select rn,
                region,--    "назва області",
                count_all_all,-- " діючих субсидій на оплату ЖКП, всього (домогосподарств)",
                count_all,-- "кількість домогосподарств, де є послуга опалення",
                sum_all,--   "розмір нарахованої субсидії, де є послуга опалення, всього (грн)",
                count_107,-- "централізоване (кількість)",
                sum_107,--   "централізоване, розмір субсидії (грн)",
                count_102,-- "газопостачання на опалення (кількість)",
                sum_102,--   "газопостачання на опалення, розмір субсидії (грн)",
                count_108,-- "електроенергія на опалення (кількість)",
                sum_108,--   "електроенергія на опалення, розмір субсидії (грн)",
                err_cnt, -- некоректні записи: невизначено вид опалення (кількість)
                err_sum -- некоректні записи: невизначено вид опалення (сума)
           from
                (select rn+1 rn,
                        Region,
                        count_all_all,
                        count_all, sum_all, count_107, sum_107,
                        count_102, sum_102, count_108, sum_108, err_cnt, err_sum
                   from t
                 union all
                 select 1 rn, '''
            || l_level_name
            || ''', sum(count_all_all), sum(count_all), sum(sum_all),
                        sum(count_107), sum(sum_107), sum(count_102), sum(sum_102),
                        sum(count_108), sum(sum_108), sum(err_cnt), sum(err_sum)
                   from t
                ), d
        order by rn

    ';

        --підставити параметр
        /*IF (p_org_id IS NULL OR p_org_id = 0) THEN
          l_sql:= replace(l_sql, ':START#', q'[to_date(']'||to_char(l_date, 'dd.mm.yyyy')||q'[', 'dd.mm.yyyy')]');
          RDM$RTFL.AddDataSet(l_jbr_id, 'ds', l_sql);
        ELSE
          l_sql_obl := replace(l_sql_obl, ':START#', q'[to_date(']'||to_char(l_date, 'dd.mm.yyyy')||q'[', 'dd.mm.yyyy')]');
          RDM$RTFL.AddDataSet(l_jbr_id, 'ds', l_sql_obl);
        END IF;*/

        l_sql :=
            REPLACE (
                l_sql,
                ':START#',
                   q'[to_date(']'
                || TO_CHAR (l_date, 'dd.mm.yyyy')
                || q'[', 'dd.mm.yyyy')]');
        RDM$RTFL.AddDataSet (l_jbr_id, 'ds', l_sql);

        RDM$RTFL.PutReportToWorkingQueue (p_jbr_id => l_jbr_id);
        RETURN l_jbr_id;
    END;


    FUNCTION sm_all (p_date    DATE,
                     p_sum1    NUMBER,
                     p_sum2    NUMBER,
                     p_sum3    NUMBER,
                     p_sum4    NUMBER,
                     p_sum5    NUMBER,
                     p_sum6    NUMBER,
                     p_sum7    NUMBER,
                     p_sum8    NUMBER,
                     p_sum9    NUMBER,
                     p_sum10   NUMBER,
                     p_sum11   NUMBER,
                     p_sum12   NUMBER)
        RETURN NUMBER
    IS
        l_period   NUMBER := EXTRACT (MONTH FROM p_date);
        l_sum      NUMBER := 0;
    BEGIN
        IF l_period >= 1
        THEN
            l_sum :=
                l_sum + CASE WHEN p_sum1 > 0 THEN NVL (p_sum1, 0) ELSE 0 END;
        ELSE
            RETURN l_sum;
        END IF;

        IF l_period >= 2
        THEN
            l_sum :=
                l_sum + CASE WHEN p_sum2 > 0 THEN NVL (p_sum2, 0) ELSE 0 END;
        ELSE
            RETURN l_sum;
        END IF;

        IF l_period >= 3
        THEN
            l_sum :=
                l_sum + CASE WHEN p_sum3 > 0 THEN NVL (p_sum3, 0) ELSE 0 END;
        ELSE
            RETURN l_sum;
        END IF;

        IF l_period >= 4
        THEN
            l_sum :=
                l_sum + CASE WHEN p_sum4 > 0 THEN NVL (p_sum4, 0) ELSE 0 END;
        ELSE
            RETURN l_sum;
        END IF;

        IF l_period >= 5
        THEN
            l_sum :=
                l_sum + CASE WHEN p_sum5 > 0 THEN NVL (p_sum5, 0) ELSE 0 END;
        ELSE
            RETURN l_sum;
        END IF;

        IF l_period >= 6
        THEN
            l_sum :=
                l_sum + CASE WHEN p_sum6 > 0 THEN NVL (p_sum6, 0) ELSE 0 END;
        ELSE
            RETURN l_sum;
        END IF;

        IF l_period >= 7
        THEN
            l_sum :=
                l_sum + CASE WHEN p_sum7 > 0 THEN NVL (p_sum7, 0) ELSE 0 END;
        ELSE
            RETURN l_sum;
        END IF;

        IF l_period >= 8
        THEN
            l_sum :=
                l_sum + CASE WHEN p_sum8 > 0 THEN NVL (p_sum8, 0) ELSE 0 END;
        ELSE
            RETURN l_sum;
        END IF;

        IF l_period >= 9
        THEN
            l_sum :=
                l_sum + CASE WHEN p_sum9 > 0 THEN NVL (p_sum9, 0) ELSE 0 END;
        ELSE
            RETURN l_sum;
        END IF;

        IF l_period >= 10
        THEN
            l_sum :=
                  l_sum
                + CASE WHEN p_sum10 > 0 THEN NVL (p_sum10, 0) ELSE 0 END;
        ELSE
            RETURN l_sum;
        END IF;

        IF l_period >= 11
        THEN
            l_sum :=
                  l_sum
                + CASE WHEN p_sum11 > 0 THEN NVL (p_sum11, 0) ELSE 0 END;
        ELSE
            RETURN l_sum;
        END IF;

        IF l_period = 12
        THEN
            l_sum :=
                  l_sum
                + CASE WHEN p_sum12 > 0 THEN NVL (p_sum12, 0) ELSE 0 END;
        END IF;

        RETURN l_sum;
    END;

    FUNCTION cnt_all (p_date DATE, p_period NUMBER, p_sum NUMBER)
        RETURN NUMBER
    IS
    BEGIN
        IF EXTRACT (MONTH FROM p_date) >= p_period AND p_sum > 0
        THEN
            RETURN 1;
        END IF;

        RETURN 0;
    END;

    PROCEDURE INIT_JKP_BENEFIT_TYPE_CGTP_JKP (p_start_dt   IN DATE,
                                              p_kaot_id    IN NUMBER,
                                              p_jbr_id     IN NUMBER)
    IS
        l_year         NUMBER := EXTRACT (YEAR FROM p_start_dt);
        l_month        NUMBER := EXTRACT (MONTH FROM p_start_dt);
        --l_org_to NUMBER;
        l_level        NUMBER;
        l_level_data   NUMBER;
        l_level_name   VARCHAR2 (500);
    BEGIN
        get_kaot_info (p_kaot_id,
                       l_level,
                       l_level_data,
                       l_level_name);

        DELETE FROM tmp_rpt_edarp;

        /*SELECT MAX(org_to)
          INTO l_org_to
          FROM v_opfu t
         WHERE org_id = p_org_id;

        IF (p_org_id IS NULL OR p_org_id = 0) THEN
          IF (l_year > 2022) THEN
            INSERT INTO tmp_rpt_edarp
            (x_region, x_cnt_cur_all, x_sum_cur_all, x_cnt_kmu, x_sum_kmu,
              x_cnt_all_130, x_sum_all_130, x_cnt_cur_130, x_sum_cur_130)
            with
              d as (select p_start_dt dt, l_year yyyy, l_month mm from dual)
             select upper(Sca_Region) Region,
                    count(distinct case when nppt_code not in ('130', '140') and cnt > 0 then scpp_sc end) count_cur_all,
                    sum(case when nppt_code not in ('130', '140') then sm else 0 end) sum_cur_all,

                    count(distinct case when nppt_code in ('21501', '21502') and cnt > 0 then scpp_sc end) cnt_kmu215,
                    sum(case when nppt_code in ('21501', '21502') then sm else 0 end) sum_kmu215,

                    count(distinct case when nppt_code in ('130', '140') and
                             cnt_all(d.dt, 1, scp3_sum_m1)+ cnt_all(d.dt, 2, scp3_sum_m2)+ cnt_all(d.dt, 3, scp3_sum_m3)+
                             cnt_all(d.dt, 4, scp3_sum_m4)+ cnt_all(d.dt, 5, scp3_sum_m5)+ cnt_all(d.dt, 6, scp3_sum_m6)+
                             cnt_all(d.dt, 7, scp3_sum_m7)+ cnt_all(d.dt, 8, scp3_sum_m8)+ cnt_all(d.dt, 9, scp3_sum_m9)+
                             cnt_all(d.dt, 10, scp3_sum_m10)+ cnt_all(d.dt, 11, scp3_sum_m11)+ cnt_all(d.dt, 12, scp3_sum_m12) > 0
                               then sca_id
                          end
                       ) count_all_130,
                    sum(
                        case when nppt_code in ('130', '140') then
                          sm_all(d.dt, scp3_sum_m1, scp3_sum_m2, scp3_sum_m3, scp3_sum_m4, scp3_sum_m5, scp3_sum_m6,
                                 scp3_sum_m7, scp3_sum_m8, scp3_sum_m9, scp3_sum_m10, scp3_sum_m11, scp3_sum_m12)
                        else 0
                        end
                       ) sum_all_130,

                    count(distinct case when nppt_code in ('130', '140') and cnt > 0 then scpp_sc end) count_cur_130,
                    sum(case when nppt_code in ('130', '140') then sm else 0 end) sum_cur_130

                from
                     (select sca.Sca_Region, nppt.nppt_code, sca_id, pps.scpp_sc, p3.*,
                             case d.mm
                               when 1  then p3.scp3_sum_m1
                               when 2  then p3.scp3_sum_m2
                               when 3  then p3.scp3_sum_m3
                               when 4  then p3.scp3_sum_m4
                               when 5  then p3.scp3_sum_m5
                               when 6  then p3.scp3_sum_m6
                               when 7  then p3.scp3_sum_m7
                               when 8  then p3.scp3_sum_m8
                               when 9  then p3.scp3_sum_m9
                               when 10 then p3.scp3_sum_m10
                               when 11 then p3.scp3_sum_m11
                               when 12 then p3.scp3_sum_m12
                               else 0
                             end sm,
                             case
                               when d.mm =  1 and p3.scp3_sum_m1 > 0 then 1
                               when d.mm =  2 and p3.scp3_sum_m2 > 0 then 1
                               when d.mm =  3 and p3.scp3_sum_m3 > 0 then 1
                               when d.mm =  4 and p3.scp3_sum_m4 > 0 then 1
                               when d.mm =  5 and p3.scp3_sum_m5 > 0 then 1
                               when d.mm =  6 and p3.scp3_sum_m6 > 0 then 1
                               when d.mm =  7 and p3.scp3_sum_m7 > 0 then 1
                               when d.mm =  8 and p3.scp3_sum_m8 > 0 then 1
                               when d.mm =  9 and p3.scp3_sum_m9 > 0 then 1
                               when d.mm = 10 and p3.scp3_sum_m10 > 0 then 1
                               when d.mm = 11 and p3.scp3_sum_m11 > 0 then 1
                               when d.mm = 12 and p3.scp3_sum_m12 > 0 then 1
                               else 0
                             end cnt

                        from d,
                             uss_person.v_sc_pfu_pay_period p3,
                             uss_person.v_sc_pfu_pay_summary pps,
                             --uss_person.v_sc_household sch,
                             uss_person.v_Sc_Address sca,
                             uss_ndi.v_ndi_pfu_payment_type nppt
                       where p3.scp3_year = d.yyyy
                         and d.yyyy > 2022
                         and pps.scpp_id = p3.scp3_scpp
                         and pps.scpp_pfu_payment_tp = 'BENEFIT'
                         --and sch.schh_id = pps.scpp_schh
                         and sca.sca_sc = p3.scp3_sc
                         AND sca.sca_tp = '4'
                         AND sca.history_status = 'A'
                         and nppt.nppt_id = p3.scp3_nppt
                         AND sca.history_status = 'A'
                     ),
                     d
              group by Sca_Region;
          ELSE
            INSERT INTO tmp_rpt_edarp
            (x_region, x_cnt_cur_all, x_sum_cur_all, x_cnt_kmu, x_sum_kmu,
              x_cnt_all_130, x_sum_all_130, x_cnt_cur_130, x_sum_cur_130)

            with
              d as (select p_start_dt dt, l_year yyyy, l_month mm from dual)
            SELECT REGION,
                   COUNT(distinct CASE WHEN nbt_id NOT IN (49, 50) AND lgnac_mec = d.mm THEN sc_id END) AS count_cur_all,
                   SUM(CASE WHEN nbt_id NOT IN (49, 50) AND lgnac_mec = d.mm THEN lgnac_sum END) AS sum_cur_all,
                   NULL AS cnt_kmu215,
                   NULL AS sum_kmu215,

                   COUNT(distinct CASE WHEN nbt_id IN (49, 50) THEN sc_id END) AS count_all_130,
                   SUM(CASE WHEN nbt_id IN (49, 50) THEN lgnac_sum END) AS sum_all_130,
                   COUNT(distinct CASE WHEN nbt_id IN (49, 50) AND lgnac_mec = d.mm THEN sc_id END) AS count_cur_130,
                   SUM(CASE WHEN nbt_id IN (49, 50) AND lgnac_mec = d.mm THEN lgnac_sum END) AS sum_cur_130
              FROM (SELECT distinct b.dic_name as Region,
                           bc.scbc_sc as sc_id,
                           bt.nbt_id,
                           g.LGNAC_MEC,
                           g.LGNAC_SUM
                      FROM uss_person.v_x_trg tr
                      JOIN d ON (1 = 1)
                      join uss_person.v_sc_benefit_category bc on (bc.scbc_id = tr.TRG_ID and tr.trg_code = 'USS_PERSON.SC_BENEFIT_CATEGORY')
                      join uss_person.v_b_famp b on b.raj = tr.raj and b.r_ncardp = tr.r_ncardp and b.fam_nomf = 0 -- заявник -- пільговик
                      join uss_ndi.V_DDN_EDARP_RAJ_OBL b on (b.dic_value = substr(lpad(tr.raj, 4, '0'), 1, 2))
                      join uss_person.v_b_lgp l on (l.RAJ = tr.RAJ and l.R_NCARDP = tr.R_NCARDP)
                      JOIN uss_ndi.v_ndi_benefit_type bt ON (bt.nbt_code = l.LG_CD)
                      JOIN uss_person.v_b_lgnacp g ON (g.RAJ = tr.RAJ AND g.R_NCARDP = tr.R_NCARDP
                                                           AND g.LG_CDKAT = l.LG_CDKAT AND g.LG_CD = l.LG_CD
                                                           AND g.LG_DTB = l.LG_DTB)
                      where 1 = 1
                        and d.yyyy < 2023
                        and d.dt between l.LG_DTB and l.LG_DTE
                        AND g.LGNAC_GOD = d.yyyy
                        and bt.nbt_id BETWEEN 17 AND 50
                   ) t
              JOIN d ON (1 = 1)
             group by Region;
          END IF;
        ELSE
          IF (l_year > 2022) THEN
            INSERT INTO tmp_rpt_edarp
            (x_region, x_cnt_cur_all, x_sum_cur_all, x_cnt_kmu, x_sum_kmu,
              x_cnt_all_130, x_sum_all_130, x_cnt_cur_130, x_sum_cur_130)
            with
              d as (select p_start_dt dt, l_year yyyy, l_month mm from dual)
             select upper(Sca_Region) Region,
                    count(distinct case when nppt_code not in ('130', '140') and cnt > 0 then scpp_sc end) count_cur_all,
                    sum(case when nppt_code not in ('130', '140') then sm else 0 end) sum_cur_all,

                    count(distinct case when nppt_code in ('21501', '21502') and cnt > 0 then scpp_sc end) cnt_kmu215,
                    sum(case when nppt_code in ('21501', '21502') then sm else 0 end) sum_kmu215,

                    count(distinct case when nppt_code in ('130', '140') and
                             cnt_all(d.dt, 1, scp3_sum_m1)+ cnt_all(d.dt, 2, scp3_sum_m2)+ cnt_all(d.dt, 3, scp3_sum_m3)+
                             cnt_all(d.dt, 4, scp3_sum_m4)+ cnt_all(d.dt, 5, scp3_sum_m5)+ cnt_all(d.dt, 6, scp3_sum_m6)+
                             cnt_all(d.dt, 7, scp3_sum_m7)+ cnt_all(d.dt, 8, scp3_sum_m8)+ cnt_all(d.dt, 9, scp3_sum_m9)+
                             cnt_all(d.dt, 10, scp3_sum_m10)+ cnt_all(d.dt, 11, scp3_sum_m11)+ cnt_all(d.dt, 12, scp3_sum_m12) > 0
                               then sca_id
                          end
                       ) count_all_130,
                    sum(
                        case when nppt_code in ('130', '140') then
                          sm_all(d.dt, scp3_sum_m1, scp3_sum_m2, scp3_sum_m3, scp3_sum_m4, scp3_sum_m5, scp3_sum_m6,
                                 scp3_sum_m7, scp3_sum_m8, scp3_sum_m9, scp3_sum_m10, scp3_sum_m11, scp3_sum_m12)
                        else 0
                        end
                       ) sum_all_130,

                    count(distinct case when nppt_code in ('130', '140') and cnt > 0 then scpp_sc end) count_cur_130,
                    sum(case when nppt_code in ('130', '140') then sm else 0 end) sum_cur_130

                from
                     (select pr.org_name AS Sca_Region, nppt.nppt_code, sca_id, pps.scpp_sc, p3.*,
                             case d.mm
                               when 1  then p3.scp3_sum_m1
                               when 2  then p3.scp3_sum_m2
                               when 3  then p3.scp3_sum_m3
                               when 4  then p3.scp3_sum_m4
                               when 5  then p3.scp3_sum_m5
                               when 6  then p3.scp3_sum_m6
                               when 7  then p3.scp3_sum_m7
                               when 8  then p3.scp3_sum_m8
                               when 9  then p3.scp3_sum_m9
                               when 10 then p3.scp3_sum_m10
                               when 11 then p3.scp3_sum_m11
                               when 12 then p3.scp3_sum_m12
                               else 0
                             end sm,
                             case
                               when d.mm =  1 and p3.scp3_sum_m1 > 0 then 1
                               when d.mm =  2 and p3.scp3_sum_m2 > 0 then 1
                               when d.mm =  3 and p3.scp3_sum_m3 > 0 then 1
                               when d.mm =  4 and p3.scp3_sum_m4 > 0 then 1
                               when d.mm =  5 and p3.scp3_sum_m5 > 0 then 1
                               when d.mm =  6 and p3.scp3_sum_m6 > 0 then 1
                               when d.mm =  7 and p3.scp3_sum_m7 > 0 then 1
                               when d.mm =  8 and p3.scp3_sum_m8 > 0 then 1
                               when d.mm =  9 and p3.scp3_sum_m9 > 0 then 1
                               when d.mm = 10 and p3.scp3_sum_m10 > 0 then 1
                               when d.mm = 11 and p3.scp3_sum_m11 > 0 then 1
                               when d.mm = 12 and p3.scp3_sum_m12 > 0 then 1
                               else 0
                             end cnt

                        from d,
                             uss_person.v_sc_pfu_pay_period p3,
                             uss_person.v_sc_pfu_pay_summary pps,
                             --uss_person.v_sc_household sch,
                             uss_person.v_Sc_Address sca,
                             uss_ndi.v_ndi_pfu_payment_type nppt,
                             uss_ndi.v_ndi_org2kaot k,
                             v_opfu pr,
                             v_opfu po
                       where p3.scp3_year = d.yyyy
                         and d.yyyy > 2022
                         and pps.scpp_id = p3.scp3_scpp
                         and pps.scpp_pfu_payment_tp = 'BENEFIT'
                         --and sch.schh_id = pps.scpp_schh
                         --and sca.sca_id = sch.schh_sca
                         AND sca.sca_sc = p3.scp3_sc
                         AND sca.sca_tp = '4'
                         AND sca.history_status = 'A'
                         AND k.nok_kaot = sca.sca_kaot
                         and k.history_status = 'A'
                         and nppt.nppt_id = p3.scp3_nppt
                         --and d.dt between nvl(k.nk2o_start_dt, d.dt) AND nvl(k.nk2o_stop_dt, d.dt)
                         AND pr.org_id = k.nok_org
                         AND po.org_id = decode(pr.org_to, 32, pr.org_org, pr.org_id)
                         AND (l_org_to = 31 AND po.org_id = p_org_id OR l_org_to != 31 AND pr.org_id = p_org_id)
                     ),
                     d
              group by Sca_Region;
          ELSE
            INSERT INTO tmp_rpt_edarp
            (x_region, x_cnt_cur_all, x_sum_cur_all, x_cnt_kmu, x_sum_kmu,
              x_cnt_all_130, x_sum_all_130, x_cnt_cur_130, x_sum_cur_130)

            with
              d as (select p_start_dt dt, l_year yyyy, l_month mm from dual)
            SELECT REGION,
                   COUNT(distinct CASE WHEN nbt_id NOT IN (49, 50) AND lgnac_mec = d.mm THEN sc_id END) AS count_cur_all,
                   SUM(CASE WHEN nbt_id NOT IN (49, 50) AND lgnac_mec = d.mm THEN lgnac_sum END) AS sum_cur_all,
                   NULL AS cnt_kmu215,
                   NULL AS sum_kmu215,

                   COUNT(distinct CASE WHEN nbt_id IN (49, 50) THEN sc_id END) AS count_all_130,
                   SUM(CASE WHEN nbt_id IN (49, 50) THEN lgnac_sum END) AS sum_all_130,
                   COUNT(distinct CASE WHEN nbt_id IN (49, 50) AND lgnac_mec = d.mm THEN sc_id END) AS count_cur_130,
                   SUM(CASE WHEN nbt_id IN (49, 50) AND lgnac_mec = d.mm THEN lgnac_sum END) AS sum_cur_130
              FROM (SELECT distinct pr.org_name\*b.dic_name*\ as Region,
                           bc.scbc_sc as sc_id,
                           bt.nbt_id,
                           g.LGNAC_MEC,
                           g.LGNAC_SUM
                      FROM uss_person.v_x_trg tr
                      JOIN d ON (1 = 1)
                      join v_opfu pr on (pr.org_id = tr.com_org)
                      join v_opfu po on (po.org_id = decode(pr.org_to, 32, pr.org_org, pr.org_id))
                      join uss_person.v_sc_benefit_category bc on (bc.scbc_id = tr.TRG_ID and tr.trg_code = 'USS_PERSON.SC_BENEFIT_CATEGORY')
                      join uss_person.v_b_famp b on b.raj = tr.raj and b.r_ncardp = tr.r_ncardp and b.fam_nomf = 0 -- заявник -- пільговик
                      --join uss_ndi.V_DDN_EDARP_RAJ_OBL b on (b.dic_value = substr(lpad(tr.raj, 4, '0'), 1, 2))
                      join uss_person.v_b_lgp l on (l.RAJ = tr.RAJ and l.R_NCARDP = tr.R_NCARDP)
                      JOIN uss_ndi.v_ndi_benefit_type bt ON (bt.nbt_code = l.LG_CD)
                      JOIN uss_person.v_b_lgnacp g ON (g.RAJ = tr.RAJ AND g.R_NCARDP = tr.R_NCARDP
                                                           AND g.LG_CDKAT = l.LG_CDKAT AND g.LG_CD = l.LG_CD
                                                           AND g.LG_DTB = l.LG_DTB)
                      where 1 = 1
                        and d.yyyy < 2023
                        and d.dt between l.LG_DTB and l.LG_DTE
                        AND g.LGNAC_GOD = d.yyyy
                        and bt.nbt_id BETWEEN 17 AND 50
                        AND (l_org_to = 31 AND po.org_id = p_org_id OR l_org_to != 31 AND pr.org_id = p_org_id)
                   ) t
              JOIN d ON (1 = 1)
             group by Region;
          END IF;
        END IF;
      */

        IF (l_year < 2023 AND (p_kaot_id IS NULL OR p_kaot_id = 0))
        THEN
            -- Чистимо допоміжні таблиці
            DELETE FROM tmp_work_set1
                  WHERE 1 = 1;

            DELETE FROM tmp_work_set2
                  WHERE 1 = 1;

            -- Перша скибка, по персонах
            INSERT INTO tmp_work_set1 (x_id1,
                                       x_id2,
                                       x_id3,
                                       x_string1)
                SELECT bc.scbc_sc     AS sc_id,
                       tr.RAJ,
                       tr.R_NCARDP,
                       b.dic_name
                  FROM uss_person.v_x_trg  tr
                       JOIN uss_person.v_sc_benefit_category bc
                           ON (    bc.scbc_id = tr.TRG_ID
                               AND tr.trg_code =
                                   'USS_PERSON.SC_BENEFIT_CATEGORY')
                       JOIN uss_ndi.V_DDN_EDARP_RAJ_OBL b
                           ON (b.dic_value =
                               SUBSTR (LPAD (tr.raj, 4, '0'), 1, 2))
                 WHERE EXISTS
                           (SELECT (1)
                              FROM uss_person.v_b_famp b
                             WHERE     b.raj = tr.raj
                                   AND b.r_ncardp = tr.r_ncardp
                                   AND b.fam_nomf = 0); -- заявник -- пільговик

            -- Друга скибка скибка, поєднали з першою великою таблицею
            INSERT INTO tmp_work_set2 (x_id1,
                                       x_id2,
                                       x_id3,
                                       x_string1,
                                       x_id4,
                                       x_id5,
                                       x_dt1)
                WITH
                    d
                    AS
                        (SELECT p_start_dt dt, l_year yyyy, l_month mm
                           FROM DUAL)
                SELECT tr.sc_id,
                       tr.RAJ,
                       tr.R_NCARDP,
                       tr.Region,
                       l.LG_CDKAT,
                       l.LG_CD,
                       l.LG_DTB
                  FROM (SELECT x_id1         AS sc_id,
                               x_id2         AS RAJ,
                               x_id3         AS R_NCARDP,
                               x_string1     AS Region
                          FROM tmp_work_set1) tr
                       JOIN d ON (1 = 1)
                       JOIN uss_person.v_b_lgp l
                           ON     l.RAJ = tr.RAJ
                              AND l.R_NCARDP = tr.R_NCARDP
                              AND d.dt BETWEEN l.LG_DTB AND l.LG_DTE
                 WHERE EXISTS
                           (SELECT 1
                              FROM uss_ndi.v_ndi_benefit_type bt
                             WHERE     bt.nbt_code = l.LG_CD
                                   AND bt.nbt_id BETWEEN 17 AND 50);

            -- Третя скибка, поєднали з жругою великою таблицею
            INSERT INTO tmp_work_set3 (x_string1,
                                       x_id1,
                                       x_id2,
                                       x_id3,
                                       x_sum1)
                SELECT /*+ index(g IDX_LGNACP_LGCD_SUM1) */
                       DISTINCT tr.Region,
                                tr.sc_id,
                                bt.nbt_id,
                                g.LGNAC_MEC,
                                g.LGNAC_SUM
                  FROM (SELECT x_id1         AS sc_id,
                               x_id2         AS RAJ,
                               x_id3         AS R_NCARDP,
                               x_string1     AS Region,
                               x_id4         AS LG_CDKAT,
                               x_id5         AS LG_CD,
                               x_dt1         AS LG_DTB
                          FROM tmp_work_set2) tr
                       JOIN uss_ndi.v_ndi_benefit_type bt
                           ON bt.nbt_code = tr.LG_CD
                       JOIN uss_person.v_b_lgnacp g
                           ON     g.RAJ = tr.RAJ
                              AND g.R_NCARDP = tr.R_NCARDP
                              AND g.LG_CDKAT = tr.LG_CDKAT
                              AND g.LG_CD = tr.LG_CD
                              AND g.LG_DTB = tr.LG_DTB
                 WHERE g.LGNAC_GOD = l_year AND g.LGNAC_MEC <= l_month;

            -- остаточний результат
            INSERT INTO tmp_rpt_edarp (x_region,
                                       x_cnt_cur_all,
                                       x_sum_cur_all,
                                       x_cnt_kmu,
                                       x_sum_kmu,
                                       x_cnt_all_130,
                                       x_sum_all_130,
                                       x_cnt_cur_130,
                                       x_sum_cur_130)
                WITH
                    d
                    AS
                        (SELECT p_start_dt dt, l_year yyyy, l_month mm
                           FROM DUAL)
                  SELECT REGION,
                         COUNT (
                             DISTINCT
                                 CASE
                                     WHEN     nbt_id NOT IN (49, 50)
                                          AND lgnac_mec = d.mm
                                     THEN
                                         sc_id
                                 END)
                             AS count_cur_all,
                         SUM (
                             CASE
                                 WHEN     nbt_id NOT IN (49, 50)
                                      AND lgnac_mec = d.mm
                                 THEN
                                     lgnac_sum
                             END)
                             AS sum_cur_all,
                         NULL
                             AS cnt_kmu215,
                         NULL
                             AS sum_kmu215,
                         COUNT (
                             DISTINCT
                                 CASE WHEN nbt_id IN (49, 50) THEN sc_id END)
                             AS count_all_130,
                         SUM (CASE WHEN nbt_id IN (49, 50) THEN lgnac_sum END)
                             AS sum_all_130,
                         COUNT (
                             DISTINCT
                                 CASE
                                     WHEN     nbt_id IN (49, 50)
                                          AND lgnac_mec = d.mm
                                     THEN
                                         sc_id
                                 END)
                             AS count_cur_130,
                         SUM (
                             CASE
                                 WHEN nbt_id IN (49, 50) AND lgnac_mec = d.mm
                                 THEN
                                     lgnac_sum
                             END)
                             AS sum_cur_130
                    FROM (SELECT x_string1     AS Region,
                                 x_id1         AS sc_id,
                                 x_id2         AS nbt_id,
                                 x_id3         AS LGNAC_MEC,
                                 x_sum1        AS LGNAC_SUM
                            FROM tmp_work_set3) t
                         JOIN d ON (1 = 1)
                GROUP BY t.Region;
        /*
              INSERT INTO tmp_rpt_edarp
              (x_region, x_cnt_cur_all, x_sum_cur_all, x_cnt_kmu, x_sum_kmu,
                x_cnt_all_130, x_sum_all_130, x_cnt_cur_130, x_sum_cur_130)

              with
                d as (select p_start_dt dt, l_year yyyy, l_month mm from dual)
              SELECT REGION,
                     COUNT(distinct CASE WHEN nbt_id NOT IN (49, 50) AND lgnac_mec = d.mm THEN sc_id END) AS count_cur_all,
                     SUM(CASE WHEN nbt_id NOT IN (49, 50) AND lgnac_mec = d.mm THEN lgnac_sum END) AS sum_cur_all,
                     NULL AS cnt_kmu215,
                     NULL AS sum_kmu215,
                     COUNT(distinct CASE WHEN nbt_id IN (49, 50) THEN sc_id END) AS count_all_130,
                     SUM(CASE WHEN nbt_id IN (49, 50) THEN lgnac_sum END) AS sum_all_130,
                     COUNT(distinct CASE WHEN nbt_id IN (49, 50) AND lgnac_mec = d.mm THEN sc_id END) AS count_cur_130,
                     SUM(CASE WHEN nbt_id IN (49, 50) AND lgnac_mec = d.mm THEN lgnac_sum END) AS sum_cur_130
                FROM (SELECT distinct b.dic_name as Region,
                             bc.scbc_sc as sc_id,
                             bt.nbt_id,
                             g.LGNAC_MEC,
                             g.LGNAC_SUM
                        FROM uss_person.v_x_trg tr
                        JOIN d ON (1 = 1)
                        join uss_person.v_sc_benefit_category bc on (bc.scbc_id = tr.TRG_ID and tr.trg_code = 'USS_PERSON.SC_BENEFIT_CATEGORY')
                        join uss_person.v_b_famp b on b.raj = tr.raj and b.r_ncardp = tr.r_ncardp and b.fam_nomf = 0 -- заявник -- пільговик
                        join uss_ndi.V_DDN_EDARP_RAJ_OBL b on (b.dic_value = substr(lpad(tr.raj, 4, '0'), 1, 2))
                        join uss_person.v_b_lgp l on (l.RAJ = tr.RAJ and l.R_NCARDP = tr.R_NCARDP)
                        JOIN uss_ndi.v_ndi_benefit_type bt ON (bt.nbt_code = l.LG_CD)
                        JOIN uss_person.v_b_lgnacp g ON (g.RAJ = tr.RAJ AND g.R_NCARDP = tr.R_NCARDP
                                                             AND g.LG_CDKAT = l.LG_CDKAT AND g.LG_CD = l.LG_CD
                                                             AND g.LG_DTB = l.LG_DTB)
                        where 1 = 1
                          and d.yyyy < 2023
                          and d.dt between l.LG_DTB and l.LG_DTE
                          AND g.LGNAC_GOD = d.yyyy
                          AND g.LGNAC_MEC <= d.mm
                          and bt.nbt_id BETWEEN 17 AND 50
                     ) t
                JOIN d ON (1 = 1)
               group by Region;
        */

        ELSE
            INSERT INTO tmp_rpt_edarp (x_region,
                                       x_cnt_cur_all,
                                       x_sum_cur_all,
                                       x_cnt_kmu,
                                       x_sum_kmu,
                                       x_cnt_all_130,
                                       x_sum_all_130,
                                       x_cnt_cur_130,
                                       x_sum_cur_130)
                WITH
                    d
                    AS
                        (SELECT p_start_dt dt, l_year yyyy, l_month mm
                           FROM DUAL)
                  SELECT (Sca_Region)    Region,
                         COUNT (
                             DISTINCT
                                 CASE
                                     WHEN     nppt_code NOT IN ('130', '140')
                                          AND cnt > 0
                                     THEN                          /*scpp_sc*/
                                         schh_id
                                 END)    count_cur_all,
                         SUM (
                             CASE
                                 WHEN     nppt_code NOT IN ('130', '140')
                                      AND cnt > 0
                                 THEN
                                     sm
                                 ELSE
                                     0
                             END)        sum_cur_all,
                         COUNT (
                             DISTINCT
                                 CASE
                                     WHEN     nppt_code IN ('21501', '21502')
                                          AND cnt > 0
                                     THEN                          /*scpp_sc*/
                                         schh_id
                                 END)    cnt_kmu215,
                         SUM (
                             CASE
                                 WHEN     nppt_code IN ('21501', '21502')
                                      AND cnt > 0
                                 THEN
                                     sm
                                 ELSE
                                     0
                             END)        sum_kmu215,
                         COUNT (
                             DISTINCT
                                 CASE
                                     WHEN     nppt_code IN ('130', '140')
                                          AND   cnt_all (d.dt, 1, scp3_sum_m1)
                                              + cnt_all (d.dt, 2, scp3_sum_m2)
                                              + cnt_all (d.dt, 3, scp3_sum_m3)
                                              + cnt_all (d.dt, 4, scp3_sum_m4)
                                              + cnt_all (d.dt, 5, scp3_sum_m5)
                                              + cnt_all (d.dt, 6, scp3_sum_m6)
                                              + cnt_all (d.dt, 7, scp3_sum_m7)
                                              + cnt_all (d.dt, 8, scp3_sum_m8)
                                              + cnt_all (d.dt, 9, scp3_sum_m9)
                                              + cnt_all (d.dt,
                                                         10,
                                                         scp3_sum_m10)
                                              + cnt_all (d.dt,
                                                         11,
                                                         scp3_sum_m11)
                                              + cnt_all (d.dt,
                                                         12,
                                                         scp3_sum_m12) >
                                              0
                                     THEN                           /*sca_id*/
                                         schh_id
                                 END)    count_all_130,
                         SUM (CASE
                                  WHEN nppt_code IN ('130', '140')
                                  THEN
                                      sm_all (d.dt,
                                              scp3_sum_m1,
                                              scp3_sum_m2,
                                              scp3_sum_m3,
                                              scp3_sum_m4,
                                              scp3_sum_m5,
                                              scp3_sum_m6,
                                              scp3_sum_m7,
                                              scp3_sum_m8,
                                              scp3_sum_m9,
                                              scp3_sum_m10,
                                              scp3_sum_m11,
                                              scp3_sum_m12)
                                  ELSE
                                      0
                              END)       sum_all_130,
                         COUNT (
                             DISTINCT
                                 CASE
                                     WHEN     nppt_code IN ('130', '140')
                                          AND cnt > 0
                                     THEN                          /*scpp_sc*/
                                         schh_id
                                 END)    count_cur_130,
                         SUM (
                             CASE
                                 WHEN nppt_code IN ('130', '140') AND cnt > 0
                                 THEN
                                     sm
                                 ELSE
                                     0
                             END)        sum_cur_130
                    FROM (SELECT NVL (kd.kaot_full_name,
                                      'невизначено або відсутні дані')
                                     AS Sca_Region,
                                 nppt.nppt_code,
                                 sca_id,
                                 h.schh_id,
                                 pps.scpp_sc,
                                 p3.*,
                                 CASE d.mm
                                     WHEN 1 THEN p3.scp3_sum_m1
                                     WHEN 2 THEN p3.scp3_sum_m2
                                     WHEN 3 THEN p3.scp3_sum_m3
                                     WHEN 4 THEN p3.scp3_sum_m4
                                     WHEN 5 THEN p3.scp3_sum_m5
                                     WHEN 6 THEN p3.scp3_sum_m6
                                     WHEN 7 THEN p3.scp3_sum_m7
                                     WHEN 8 THEN p3.scp3_sum_m8
                                     WHEN 9 THEN p3.scp3_sum_m9
                                     WHEN 10 THEN p3.scp3_sum_m10
                                     WHEN 11 THEN p3.scp3_sum_m11
                                     WHEN 12 THEN p3.scp3_sum_m12
                                     ELSE 0
                                 END
                                     sm,
                                 CASE
                                     WHEN d.mm = 1 AND p3.scp3_sum_m1 > 0
                                     THEN
                                         1
                                     WHEN d.mm = 2 AND p3.scp3_sum_m2 > 0
                                     THEN
                                         1
                                     WHEN d.mm = 3 AND p3.scp3_sum_m3 > 0
                                     THEN
                                         1
                                     WHEN d.mm = 4 AND p3.scp3_sum_m4 > 0
                                     THEN
                                         1
                                     WHEN d.mm = 5 AND p3.scp3_sum_m5 > 0
                                     THEN
                                         1
                                     WHEN d.mm = 6 AND p3.scp3_sum_m6 > 0
                                     THEN
                                         1
                                     WHEN d.mm = 7 AND p3.scp3_sum_m7 > 0
                                     THEN
                                         1
                                     WHEN d.mm = 8 AND p3.scp3_sum_m8 > 0
                                     THEN
                                         1
                                     WHEN d.mm = 9 AND p3.scp3_sum_m9 > 0
                                     THEN
                                         1
                                     WHEN d.mm = 10 AND p3.scp3_sum_m10 > 0
                                     THEN
                                         1
                                     WHEN d.mm = 11 AND p3.scp3_sum_m11 > 0
                                     THEN
                                         1
                                     WHEN d.mm = 12 AND p3.scp3_sum_m12 > 0
                                     THEN
                                         1
                                     ELSE
                                         0
                                 END
                                     cnt
                            FROM d,
                                 uss_person.v_sc_pfu_pay_period p3,
                                 uss_person.v_sc_pfu_pay_summary pps,
                                 uss_person.v_sc_household      h,
                                 uss_person.v_Sc_Address        sca,
                                 uss_ndi.v_ndi_pfu_payment_type nppt,
                                 uss_ndi.v_ndi_katottg          k,
                                 uss_ndi.v_ndi_katottg          km,
                                 uss_ndi.v_ndi_katottg          kd
                           WHERE     p3.scp3_year = d.yyyy
                                 AND d.yyyy > 2022
                                 AND pps.scpp_id = p3.scp3_scpp
                                 AND pps.scpp_pfu_payment_tp = 'BENEFIT'
                                 -- #92093 у нас все правильно, але пфу гади оновлюють дані. тому циферці у ніх плавають...
                                 /*and sca.sca_sc = p3.scp3_sc
                                 AND sca.sca_tp = '4'
                                 AND sca.history_status = 'A'*/
                                 AND scpp_pfu_pd_st NOT IN ('PS', 'V')
                                 AND d.dt BETWEEN scpp_pfu_pd_start_dt
                                              AND scpp_pfu_pd_stop_dt
                                 AND h.schh_id = pps.scpp_schh
                                 AND sca.sca_id = h.schh_sca
                                 AND k.kaot_id = sca.sca_kaot
                                 AND km.kaot_id =
                                     CASE
                                         WHEN l_level = 1 THEN k.kaot_kaot_l1
                                         WHEN l_level = 2 THEN k.kaot_kaot_l2
                                         WHEN l_level = 3 THEN k.kaot_kaot_l3
                                         WHEN l_level = 4 THEN k.kaot_kaot_l4
                                         WHEN l_level = 5 THEN k.kaot_kaot_l5
                                     END
                                 AND kd.kaot_id(+) =
                                     CASE
                                         WHEN l_level_data = 1
                                         THEN
                                             k.kaot_kaot_l1
                                         WHEN l_level_data = 2
                                         THEN
                                             k.kaot_kaot_l2
                                         WHEN l_level_data = 3
                                         THEN
                                             k.kaot_kaot_l3
                                         WHEN l_level_data = 4
                                         THEN
                                             k.kaot_kaot_l4
                                         WHEN l_level_data = 5
                                         THEN
                                             k.kaot_kaot_l5
                                     END
                                 AND (   p_kaot_id IS NULL
                                      OR p_kaot_id = 0
                                      OR     p_kaot_id > 0
                                         AND km.kaot_id = p_kaot_id)
                                 AND nppt.nppt_id = p3.scp3_nppt),
                         d
                GROUP BY Sca_Region;
        END IF;
    END;

    --Інформація про надання пільг СГТП ЖКП
    FUNCTION JKP_BENEFIT_TYPE_CGTP_JKP (
        p_start_dt   IN DATE,
        p_kaot_id    IN NUMBER,
        p_rt_id      IN rpt_templates.rt_id%TYPE)
        RETURN DECIMAL
    IS
        l_jbr_id       NUMBER;
        l_date         DATE := TRUNC (p_start_dt, 'mm');
        l_sql          VARCHAR2 (32000);
        l_level        NUMBER;
        l_level_data   NUMBER;
        l_level_name   VARCHAR2 (500);
    BEGIN
        l_jbr_id :=
            RDM$RTFL.InitReport (p_rt_id      => p_rt_id,
                                 p_rpt_name   => 'Пільги_ЖКП_СГТП');
        RDM$RTFL.AddParam (l_jbr_id,
                           'p_date',
                           TO_CHAR (ADD_MONTHS (l_date, 1), 'dd.mm.yyyy'));
        RDM$RTFL.AddParam (l_jbr_id,
                           'gen_dt',
                           TO_CHAR (SYSDATE, 'dd.mm.yyyy') || 'р.');
        rdm$rtfl.SetFileName (
            l_jbr_id,
               'Пільги_ЖКП_СГТП'
            || '_'
            || TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS')
            || '.XLS');

        get_kaot_info (p_kaot_id,
                       l_level,
                       l_level_data,
                       l_level_name);

        rdm$rtfl.AddScript (
            l_jbr_id,
            'init_data',
               'begin  uss_esr.DNET$RPT_BENEFITS.INIT_JKP_BENEFIT_TYPE_CGTP_JKP(
                                            to_date('''
            || TO_CHAR (p_start_dt, 'DD.MM.YYYY')
            || ''', ''DD.MM.YYYY''),
                                           '
            || NVL (TO_CHAR (p_kaot_id), 'null')
            || ','
            || l_jbr_id
            || '); end;');

        /*l_sql:= q'[

          with
            function sm_all(p_date date,
                            p_sum1 number, p_sum2 number, p_sum3 number, p_sum4 number, p_sum5 number, p_sum6 number,
                            p_sum7 number, p_sum8 number, p_sum9 number, p_sum10 number, p_sum11 number, p_sum12 number) return number is
              l_period number:= extract(month from p_date);
              l_sum number:= 0;
            begin
              if l_period >= 1 then l_sum:= l_sum+ nvl(p_sum1, 0); else return l_sum; end if;
              if l_period >= 2 then l_sum:= l_sum+ nvl(p_sum2, 0); else return l_sum; end if;
              if l_period >= 3 then l_sum:= l_sum+ nvl(p_sum3, 0); else return l_sum; end if;
              if l_period >= 4 then l_sum:= l_sum+ nvl(p_sum4, 0); else return l_sum; end if;
              if l_period >= 5 then l_sum:= l_sum+ nvl(p_sum5, 0); else return l_sum; end if;
              if l_period >= 6 then l_sum:= l_sum+ nvl(p_sum6, 0); else return l_sum; end if;
              if l_period >= 7 then l_sum:= l_sum+ nvl(p_sum7, 0); else return l_sum; end if;
              if l_period >= 8 then l_sum:= l_sum+ nvl(p_sum8, 0); else return l_sum; end if;
              if l_period >= 9 then l_sum:= l_sum+ nvl(p_sum9, 0); else return l_sum; end if;
              if l_period >= 10 then l_sum:= l_sum+ nvl(p_sum10, 0); else return l_sum; end if;
              if l_period >= 11 then l_sum:= l_sum+ nvl(p_sum11, 0); else return l_sum; end if;
              if l_period = 12 then l_sum:= l_sum+ nvl(p_sum12, 0); end if;
              return l_sum;
            end;

            function cnt_all(p_date date, p_period number, p_sum number) return number is
            begin
              if  extract(month from p_date) >= p_period and p_sum > 0 then
               return 1;
              end if;
              return 0;
            end;

            d as (select :START# dt, extract(YEAR from :START#) yyyy, extract(MONTH from :START#) mm from dual),

            t as
            (select row_number() over(order by nlssort(Region, 'NLS_SORT=ukrainian')) rn,
                    region,
                    sum(count_cur_all) as count_cur_all,
                    sum(sum_cur_all) as sum_cur_all,

                    sum(cnt_kmu215) as cnt_kmu215,
                    sum(sum_kmu215) as sum_kmu215,

                    sum(count_all_130) as count_all_130,
                    sum(sum_all_130) as sum_all_130,

                    sum(count_cur_130) as count_cur_130,
                    sum(sum_cur_130) as sum_cur_130
               from (
             select --row_number() over(order by nlssort(Sca_Region, 'NLS_SORT=ukrainian')) rn,
                    upper(Sca_Region) Region,
                    count(distinct case when nppt_code not in ('130', '140') and cnt > 0 then scpp_sc end) count_cur_all,
                    sum(case when nppt_code not in ('130', '140') then sm else 0 end) sum_cur_all,

                    count(distinct case when nppt_code in ('21501', '21502') and cnt > 0 then scpp_sc end) cnt_kmu215,
                    sum(case when nppt_code in ('21501', '21502') then sm else 0 end) sum_kmu215,

                    count(distinct case when nppt_code in ('130', '140') and
                             cnt_all(d.dt, 1, scp3_sum_m1)+ cnt_all(d.dt, 2, scp3_sum_m2)+ cnt_all(d.dt, 3, scp3_sum_m3)+
                             cnt_all(d.dt, 4, scp3_sum_m4)+ cnt_all(d.dt, 5, scp3_sum_m5)+ cnt_all(d.dt, 6, scp3_sum_m6)+
                             cnt_all(d.dt, 7, scp3_sum_m7)+ cnt_all(d.dt, 8, scp3_sum_m8)+ cnt_all(d.dt, 9, scp3_sum_m9)+
                             cnt_all(d.dt, 10, scp3_sum_m10)+ cnt_all(d.dt, 11, scp3_sum_m11)+ cnt_all(d.dt, 12, scp3_sum_m12) > 0
                               then schh_id
                          end
                       ) count_all_130,
                    sum(
                        case when nppt_code in ('130', '140') then
                          sm_all(d.dt, scp3_sum_m1, scp3_sum_m2, scp3_sum_m3, scp3_sum_m4, scp3_sum_m5, scp3_sum_m6,
                                 scp3_sum_m7, scp3_sum_m8, scp3_sum_m9, scp3_sum_m10, scp3_sum_m11, scp3_sum_m12)
                        else 0
                        end
                       ) sum_all_130,

                    count(distinct case when nppt_code in ('130', '140') and cnt > 0 then scpp_sc end) count_cur_130,
                    sum(case when nppt_code in ('130', '140') then sm else 0 end) sum_cur_130

                from
                     (select sca.Sca_Region, nppt.nppt_code, sch.schh_id, pps.scpp_sc, p3.*,
                             case d.mm
                               when 1  then p3.scp3_sum_m1
                               when 2  then p3.scp3_sum_m2
                               when 3  then p3.scp3_sum_m3
                               when 4  then p3.scp3_sum_m4
                               when 5  then p3.scp3_sum_m5
                               when 6  then p3.scp3_sum_m6
                               when 7  then p3.scp3_sum_m7
                               when 8  then p3.scp3_sum_m8
                               when 9  then p3.scp3_sum_m9
                               when 10 then p3.scp3_sum_m10
                               when 11 then p3.scp3_sum_m11
                               when 12 then p3.scp3_sum_m12
                               else 0
                             end sm,
                             case
                               when d.mm =  1 and p3.scp3_sum_m1 > 0 then 1
                               when d.mm =  2 and p3.scp3_sum_m2 > 0 then 1
                               when d.mm =  3 and p3.scp3_sum_m3 > 0 then 1
                               when d.mm =  4 and p3.scp3_sum_m4 > 0 then 1
                               when d.mm =  5 and p3.scp3_sum_m5 > 0 then 1
                               when d.mm =  6 and p3.scp3_sum_m6 > 0 then 1
                               when d.mm =  7 and p3.scp3_sum_m7 > 0 then 1
                               when d.mm =  8 and p3.scp3_sum_m8 > 0 then 1
                               when d.mm =  9 and p3.scp3_sum_m9 > 0 then 1
                               when d.mm = 10 and p3.scp3_sum_m10 > 0 then 1
                               when d.mm = 11 and p3.scp3_sum_m11 > 0 then 1
                               when d.mm = 12 and p3.scp3_sum_m12 > 0 then 1
                               else 0
                             end cnt

                        from d,
                             uss_person.v_sc_pfu_pay_period p3,
                             uss_person.v_sc_pfu_pay_summary pps,
                             uss_person.v_sc_household sch,
                             uss_person.v_Sc_Address sca,
                             uss_ndi.v_ndi_pfu_payment_type nppt
                       where p3.scp3_year = d.yyyy
                         and d.yyyy > 2022
                         and pps.scpp_id = p3.scp3_scpp
                         and pps.scpp_pfu_payment_tp = 'BENEFIT'
                         and sch.schh_id = pps.scpp_schh
                         and sca.sca_id = sch.schh_sca
                         and nppt.nppt_id = p3.scp3_nppt
                     ),
                     d
              group by Sca_Region
              union all
              SELECT REGION,
                     COUNT(distinct CASE WHEN nbt_id NOT IN (49, 50) AND lgnac_mec = d.mm THEN sc_id END) AS count_cur_all,
                     SUM(CASE WHEN nbt_id NOT IN (49, 50) AND lgnac_mec = d.mm THEN lgnac_sum END) AS sum_cur_all,
                     NULL AS cnt_kmu215,
                     NULL AS sum_kmu215,

                     COUNT(distinct CASE WHEN nbt_id IN (49, 50) THEN sc_id END) AS count_all_130,
                     SUM(CASE WHEN nbt_id IN (49, 50) THEN lgnac_sum END) AS sum_all_130,
                     COUNT(distinct CASE WHEN nbt_id IN (49, 50) AND lgnac_mec = d.mm THEN sc_id END) AS count_cur_130,
                     SUM(CASE WHEN nbt_id IN (49, 50) AND lgnac_mec = d.mm THEN lgnac_sum END) AS sum_cur_130
                FROM (SELECT distinct b.dic_name as Region,
                             bc.scbc_sc as sc_id,
                             bt.nbt_id,
                             g.LGNAC_MEC,
                             g.LGNAC_SUM
                        FROM uss_person.v_x_trg tr
                        JOIN d ON (1 = 1)
                        join uss_person.v_sc_benefit_category bc on (bc.scbc_id = tr.TRG_ID and tr.trg_code = 'USS_PERSON.SC_BENEFIT_CATEGORY')
                        join uss_person.v_b_famp b on b.raj = tr.raj and b.r_ncardp = tr.r_ncardp and b.fam_nomf = 0 -- заявник -- пільговик
                        join uss_ndi.V_DDN_EDARP_RAJ_OBL b on (b.dic_value = substr(lpad(tr.raj, 4, '0'), 1, 2))
                        join uss_person.v_b_lgp l on (l.RAJ = tr.RAJ and l.R_NCARDP = tr.R_NCARDP)
                        JOIN uss_ndi.v_ndi_benefit_type bt ON (bt.nbt_code = l.LG_CD)
                        JOIN uss_person.v_b_lgnacp g ON (g.RAJ = tr.RAJ AND g.R_NCARDP = tr.R_NCARDP
                                                             AND g.LG_CDKAT = l.LG_CDKAT AND g.LG_CD = l.LG_CD
                                                             AND g.LG_DTB = l.LG_DTB)
                        where 1 = 1
                          and d.yyyy < 2023
                          and d.dt between l.LG_DTB and l.LG_DTE
                          AND g.LGNAC_GOD = d.yyyy
                          and bt.nbt_id BETWEEN 17 AND 50
                     ) t
                JOIN d ON (1 = 1)
               group by Region
              )
              group by Region
            )

            select rn,--             "1)№ з/п",
                   region,--         "2)Назва адміністративно-територіальної одиниці",
                   to_char(count_cur_all, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS='', ''''') as count_cur_all,--  "3)Чисельність пільговиків, яким нараховано пільги на оплату житлово-комунальних послуг у звітному місяці",
                   to_char(sum_cur_all, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''''')  as sum_cur_all,--    "4)Сума нарахованих пільг на оплату житлово-комунальних послуг у звітному місяці(тис.грн)",
                   to_char(average, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''''')  as average,--        "5)Середній розмір пільги на оплату житлово-комунальних послуг у звітному місяці із зазначених в стовпчику 3(грн)",
                   to_char(count_all_130, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS='', ''''') as count_all_130,--  "6)Чисельність пільговиків, яким нараховано пільги на придбання твердого палива і скрапленого газу(з початку року)",
                   to_char(count_cur_130, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS='', ''''') as count_cur_130,--  "7)Чисельність пільговиків, яким нараховано пільги на придбання твердого палива і скрапленого газу(в т. ч. у звітному місяці)",
                   to_char(sum_all_130, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''''')  as sum_all_130,--    "8)Сума нарахованих пільг на придбання твердого палива і скрапленого газу, тис.грн(з початку року)",
                   to_char(sum_cur_130, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''''')  as sum_cur_130,--    "9)Сума нарахованих пільг на придбання твердого палива і скрапленого газу, тис.грн(в т. ч. у звітному місяці)",
                   to_char(average_all_130, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''''')  as average_all_130,-- "10)Середній розмір пільги на придбання твердого палива і скрапленого газу у звітному місяці із зазначених в стовпчику 6,грн",
                   to_char(average_cur_130, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''''')  as average_cur_130,-- "11)Середній розмір пільги на придбання твердого палива і скрапленого газу у звітному місяці із зазначених в стовпчику 7,грн",
                   --to_char(dt, 'Month yyyy', 'NLS_DATE_LANGUAGE = ukrainian') "Звітній місяць"
                   to_char(cnt_kmu215, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS='', ''''') as cnt_kmu215,       -- 12) Кількість пільговиків, яким пільга надається централізовано по ПКМУ від 07.03.2022 №215
                   to_char(sum_kmu215, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''''')  as sum_kmu215        -- 13) Сума нарахованих пільг по ПКМУ від 07.03.2022 №215 в звітному місяці, тис.грн

              from
                   (select rn+ 1 rn,
                           case when (lower(Region)) = 'київ' then 'м. ' || initCap(Region)
                                when Region is not null then initCap(Region) || ' обл.'
                            end as Region,
                           count_cur_all,
                           round(sum_cur_all/1000) as sum_cur_all,
                           round(decode(count_cur_all, 0, 0, sum_cur_all/count_cur_all)) as average,
                           count_all_130,
                           round(sum_all_130/1000, 2) as sum_all_130,
                           count_cur_130 as count_cur_130,
                           round(sum_cur_130/1000, 2) as sum_cur_130,
                           round(decode(count_all_130, 0, 0, sum_all_130/count_all_130), 2) as average_all_130,
                           round(decode(count_cur_130, 0, 0, sum_cur_130/count_cur_130), 2) as average_cur_130,
                           cnt_kmu215,
                           round(sum_kmu215/1000) sum_kmu215

                      from t
                    union all
                    select 1 rn,
                           'УКРАЇНА' Region,
                           sum(count_cur_all),
                           sum(round(sum_cur_all/1000)),
                           round(decode(sum(count_cur_all), 0, 0, sum(sum_cur_all)/sum(count_cur_all))),
                           sum(count_all_130),
                           round(sum(sum_all_130)/1000, 2),
                           sum(count_cur_130),
                           round(sum(sum_cur_130)/1000, 2),
                           round(decode(sum(count_all_130), 0, 0, sum(sum_all_130)/sum(count_all_130))),
                           round(decode(sum(count_cur_130), 0, 0, sum(sum_cur_130)/sum(count_cur_130))),
                           sum(cnt_kmu215),
                           round(sum(sum_kmu215)/1000, 2)
                      from t
                   ), d
              where region is not null
            order by 1

        ]';
        --підставити параметр
        l_sql:= replace(l_sql, ':START#', q'[to_date(']'||to_char(l_date, 'dd.mm.yyyy')||q'[', 'dd.mm.yyyy')]');

        RDM$RTFL.AddDataSet(l_jbr_id, 'ds', l_sql);*/

        /*IF (p_org_id IS NULL OR p_org_id = 0) THEN
          RDM$RTFL.AddDataSet(l_jbr_id, 'ds',
          q'[
          with t as (select row_number() over(order by nlssort(x_Region, 'NLS_SORT=ukrainian')) rn,
                            x_region as region,
                            sum(x_cnt_cur_all) as count_cur_all,
                            sum(x_sum_cur_all) as sum_cur_all,

                            sum(x_cnt_kmu) as cnt_kmu215,
                            sum(x_sum_kmu) as sum_kmu215,

                            sum(x_cnt_all_130) as count_all_130,
                            sum(x_sum_all_130) as sum_all_130,

                            sum(x_cnt_cur_130) as count_cur_130,
                            sum(x_sum_cur_130) as sum_cur_130
                       from uss_esr.tmp_rpt_edarp
                     group by x_region)

            select rn,--             "1)№ з/п",
                   region,--         "2)Назва адміністративно-територіальної одиниці",
                   count_cur_all,--  "3)Чисельність пільговиків, яким нараховано пільги на оплату житлово-комунальних послуг у звітному місяці",
                   sum_cur_all,--    "4)Сума нарахованих пільг на оплату житлово-комунальних послуг у звітному місяці(тис.грн)",
                   average,--        "5)Середній розмір пільги на оплату житлово-комунальних послуг у звітному місяці із зазначених в стовпчику 3(грн)",
                   count_all_130,--  "6)Чисельність пільговиків, яким нараховано пільги на придбання твердого палива і скрапленого газу(з початку року)",
                   count_cur_130,--  "7)Чисельність пільговиків, яким нараховано пільги на придбання твердого палива і скрапленого газу(в т. ч. у звітному місяці)",
                   sum_all_130,--    "8)Сума нарахованих пільг на придбання твердого палива і скрапленого газу, тис.грн(з початку року)",
                   sum_cur_130,--    "9)Сума нарахованих пільг на придбання твердого палива і скрапленого газу, тис.грн(в т. ч. у звітному місяці)",
                   average_all_130,-- "10)Середній розмір пільги на придбання твердого палива і скрапленого газу у звітному місяці із зазначених в стовпчику 6,грн",
                   average_cur_130,-- "11)Середній розмір пільги на придбання твердого палива і скрапленого газу у звітному місяці із зазначених в стовпчику 7,грн",
                   --to_char(dt, 'Month yyyy', 'NLS_DATE_LANGUAGE = ukrainian') "Звітній місяць"
                   cnt_kmu215,       -- 12) Кількість пільговиків, яким пільга надається централізовано по ПКМУ від 07.03.2022 №215
                   sum_kmu215        -- 13) Сума нарахованих пільг по ПКМУ від 07.03.2022 №215 в звітному місяці, тис.грн

              from
                   (select rn+ 1 rn,
                           case when (lower(Region)) = 'київ' then 'м. ' || initCap(Region)
                                when Region is not null then initCap(Region) || ' обл.'
                            end as Region,
                           count_cur_all,
                           round(sum_cur_all/1000) as sum_cur_all,
                           round(decode(count_cur_all, 0, 0, sum_cur_all/count_cur_all)) as average,
                           count_all_130,
                           round(sum_all_130/1000, 2) as sum_all_130,
                           count_cur_130 as count_cur_130,
                           round(sum_cur_130/1000, 2) as sum_cur_130,
                           round(decode(count_all_130, 0, 0, sum_all_130/count_all_130), 2) as average_all_130,
                           round(decode(count_cur_130, 0, 0, sum_cur_130/count_cur_130), 2) as average_cur_130,
                           cnt_kmu215,
                           round(sum_kmu215/1000) sum_kmu215

                      from t
                    union all
                    select 1 rn,
                           'УКРАЇНА' Region,
                           sum(count_cur_all),
                           sum(round(sum_cur_all/1000)),
                           round(decode(sum(count_cur_all), 0, 0, sum(sum_cur_all)/sum(count_cur_all))),
                           sum(count_all_130),
                           round(sum(sum_all_130)/1000, 2),
                           sum(count_cur_130),
                           round(sum(sum_cur_130)/1000, 2),
                           round(decode(sum(count_all_130), 0, 0, sum(sum_all_130)/sum(count_all_130))),
                           round(decode(sum(count_cur_130), 0, 0, sum(sum_cur_130)/sum(count_cur_130))),
                           sum(cnt_kmu215),
                           round(sum(sum_kmu215)/1000, 2)
                      from t
                   )
              where region is not null
            order by 1
          ]');
        ELSE
          RDM$RTFL.AddDataSet(l_jbr_id, 'ds',
          q'[
          with t as (select row_number() over(order by nlssort(x_Region, 'NLS_SORT=ukrainian')) rn,
                            x_region as region,
                            sum(x_cnt_cur_all) as count_cur_all,
                            sum(x_sum_cur_all) as sum_cur_all,

                            sum(x_cnt_kmu) as cnt_kmu215,
                            sum(x_sum_kmu) as sum_kmu215,

                            sum(x_cnt_all_130) as count_all_130,
                            sum(x_sum_all_130) as sum_all_130,

                            sum(x_cnt_cur_130) as count_cur_130,
                            sum(x_sum_cur_130) as sum_cur_130
                       from uss_esr.tmp_rpt_edarp
                     group by x_region)

            select rn,--             "1)№ з/п",
                   region,--         "2)Назва адміністративно-територіальної одиниці",
                   count_cur_all,--  "3)Чисельність пільговиків, яким нараховано пільги на оплату житлово-комунальних послуг у звітному місяці",
                   sum_cur_all,--    "4)Сума нарахованих пільг на оплату житлово-комунальних послуг у звітному місяці(тис.грн)",
                   average,--        "5)Середній розмір пільги на оплату житлово-комунальних послуг у звітному місяці із зазначених в стовпчику 3(грн)",
                   count_all_130,--  "6)Чисельність пільговиків, яким нараховано пільги на придбання твердого палива і скрапленого газу(з початку року)",
                   count_cur_130,--  "7)Чисельність пільговиків, яким нараховано пільги на придбання твердого палива і скрапленого газу(в т. ч. у звітному місяці)",
                   sum_all_130,--    "8)Сума нарахованих пільг на придбання твердого палива і скрапленого газу, тис.грн(з початку року)",
                   sum_cur_130,--    "9)Сума нарахованих пільг на придбання твердого палива і скрапленого газу, тис.грн(в т. ч. у звітному місяці)",
                   average_all_130,-- "10)Середній розмір пільги на придбання твердого палива і скрапленого газу у звітному місяці із зазначених в стовпчику 6,грн",
                   average_cur_130,-- "11)Середній розмір пільги на придбання твердого палива і скрапленого газу у звітному місяці із зазначених в стовпчику 7,грн",
                   --to_char(dt, 'Month yyyy', 'NLS_DATE_LANGUAGE = ukrainian') "Звітній місяць"
                   cnt_kmu215,       -- 12) Кількість пільговиків, яким пільга надається централізовано по ПКМУ від 07.03.2022 №215
                   sum_kmu215        -- 13) Сума нарахованих пільг по ПКМУ від 07.03.2022 №215 в звітному місяці, тис.грн

              from
                   (select rn rn,
                           initcap(Region) as Region,
                           count_cur_all,
                           round(sum_cur_all/1000) as sum_cur_all,
                           round(decode(count_cur_all, 0, 0, sum_cur_all/count_cur_all)) as average,
                           count_all_130,
                           round(sum_all_130/1000, 2) as sum_all_130,
                           count_cur_130 as count_cur_130,
                           round(sum_cur_130/1000, 2) as sum_cur_130,
                           round(decode(count_all_130, 0, 0, sum_all_130/count_all_130), 2) as average_all_130,
                           round(decode(count_cur_130, 0, 0, sum_cur_130/count_cur_130), 2) as average_cur_130,
                           cnt_kmu215,
                           round(sum_kmu215/1000) sum_kmu215

                      from t
                   )
              where region is not null
            order by 1
          ]');
        END IF; */

        RDM$RTFL.AddDataSet (
            l_jbr_id,
            'ds',
               q'[
      with t as (select row_number() over(order by DECODE(x_region, 'невизначено або відсутні дані', 9999, 0), nlssort(x_Region, 'NLS_SORT=ukrainian')) rn,
                        x_region as region,
                        sum(x_cnt_cur_all) as count_cur_all,
                        sum(x_sum_cur_all) as sum_cur_all,

                        sum(x_cnt_kmu) as cnt_kmu215,
                        sum(x_sum_kmu) as sum_kmu215,

                        sum(x_cnt_all_130) as count_all_130,
                        sum(x_sum_all_130) as sum_all_130,

                        sum(x_cnt_cur_130) as count_cur_130,
                        sum(x_sum_cur_130) as sum_cur_130
                   from uss_esr.tmp_rpt_edarp
                 group by x_region)

        select rn,--             "1)№ з/п",
               region,--         "2)Назва адміністративно-територіальної одиниці",
               count_cur_all,--  "3)Чисельність пільговиків, яким нараховано пільги на оплату житлово-комунальних послуг у звітному місяці",
               sum_cur_all,--    "4)Сума нарахованих пільг на оплату житлово-комунальних послуг у звітному місяці(тис.грн)",
               average,--        "5)Середній розмір пільги на оплату житлово-комунальних послуг у звітному місяці із зазначених в стовпчику 3(грн)",
               count_all_130,--  "6)Чисельність пільговиків, яким нараховано пільги на придбання твердого палива і скрапленого газу(з початку року)",
               count_cur_130,--  "7)Чисельність пільговиків, яким нараховано пільги на придбання твердого палива і скрапленого газу(в т. ч. у звітному місяці)",
               sum_all_130,--    "8)Сума нарахованих пільг на придбання твердого палива і скрапленого газу, тис.грн(з початку року)",
               sum_cur_130,--    "9)Сума нарахованих пільг на придбання твердого палива і скрапленого газу, тис.грн(в т. ч. у звітному місяці)",
               average_all_130,-- "10)Середній розмір пільги на придбання твердого палива і скрапленого газу у звітному місяці із зазначених в стовпчику 6,грн",
               average_cur_130,-- "11)Середній розмір пільги на придбання твердого палива і скрапленого газу у звітному місяці із зазначених в стовпчику 7,грн",
               --to_char(dt, 'Month yyyy', 'NLS_DATE_LANGUAGE = ukrainian') "Звітній місяць"
               cnt_kmu215,       -- 12) Кількість пільговиків, яким пільга надається централізовано по ПКМУ від 07.03.2022 №215
               sum_kmu215        -- 13) Сума нарахованих пільг по ПКМУ від 07.03.2022 №215 в звітному місяці, тис.грн

          from
               (select rn + 1 rn,
                       (Region) as Region,
                       count_cur_all,
                       round(sum_cur_all/1000, 2) as sum_cur_all,
                       round(decode(count_cur_all, 0, 0, round(sum_cur_all/1000, 2)*1000/count_cur_all), 2) as average,
                       count_all_130,
                       round(sum_all_130/1000, 2) as sum_all_130,
                       count_cur_130 as count_cur_130,
                       round(sum_cur_130/1000, 2) as sum_cur_130,
                       round(decode(count_all_130, 0, 0, round(sum_all_130/1000, 2)*1000/count_all_130), 2) as average_all_130,
                       round(decode(count_cur_130, 0, 0, round(sum_cur_130/1000, 2)*1000/count_cur_130), 2) as average_cur_130,
                       cnt_kmu215,
                       round(sum_kmu215/1000, 2) sum_kmu215
                  from t
                union all
                select 1 rn,
                       ']'
            || l_level_name
            || ''' Region,
                       sum(count_cur_all),
                       sum(round(sum_cur_all/1000, 2)),
                       round(decode(sum(count_cur_all), 0, 0, sum(round(sum_cur_all/1000))*1000/sum(count_cur_all)), 2),
                       sum(count_all_130),
                       sum(round(sum_all_130/1000, 2)),
                       sum(count_cur_130),
                       sum(round(sum_cur_130/1000, 2)),
                       round(decode(sum(count_all_130), 0, 0, sum(round(sum_all_130/1000, 2))*1000/sum(count_all_130)), 2),
                       round(decode(sum(count_cur_130), 0, 0, sum(round(sum_cur_130/1000, 2))*1000/sum(count_cur_130)), 2),
                       sum(cnt_kmu215),
                       sum(round(sum_kmu215/1000, 2))
                  from t
               )
          where region is not null
        order by 1
      ');

        RDM$RTFL.PutReportToWorkingQueue (p_jbr_id => l_jbr_id);
        RETURN l_jbr_id;
    END;

    --Кількість призначених житлових субсидій (за видами послуг)
    FUNCTION SUBSIDY_TYPE_JPK (p_start_dt   IN DATE,
                               p_org_id     IN NUMBER,
                               p_rt_id      IN rpt_templates.rt_id%TYPE)
        RETURN DECIMAL
    IS
        l_jbr_id   NUMBER;
        l_date     DATE := TRUNC (p_start_dt, 'mm');
        l_sql      VARCHAR2 (32000);
    BEGIN
        l_jbr_id :=
            RDM$RTFL.InitReport (p_rt_id      => p_rt_id,
                                 p_rpt_name   => 'Субсидії_за_видами_послуг');
        RDM$RTFL.AddParam (l_jbr_id,
                           'p_date',
                           TO_CHAR (ADD_MONTHS (l_date, 1), 'dd.mm.yyyy'));
        RDM$RTFL.AddParam (l_jbr_id,
                           'gen_dt',
                           TO_CHAR (SYSDATE, 'dd.mm.yyyy'));
        rdm$rtfl.SetFileName (
            l_jbr_id,
               'Субсидії_за_видами_послуг'
            || '_'
            || TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS')
            || '.XLS');

        l_sql :=
            q'[
      with
        function sm(p_date date,
                     p_sum1 number, p_sum2 number, p_sum3 number, p_sum4 number, p_sum5 number, p_sum6 number,
                     p_sum7 number, p_sum8 number, p_sum9 number, p_sum10 number, p_sum11 number, p_sum12 number) return number is

          l_period number:= to_char(p_date, 'mm');
        begin
          case l_period
            when 1 then return nvl(p_sum1, 0);
            when 2 then return nvl(p_sum2, 0);
            when 3 then return nvl(p_sum3, 0);
            when 4 then return nvl(p_sum4, 0);
            when 5 then return nvl(p_sum5, 0);
            when 6 then return nvl(p_sum6, 0);
            when 7 then return nvl(p_sum7, 0);
            when 8 then return nvl(p_sum8, 0);
            when 9 then return nvl(p_sum9, 0);
            when 10 then return nvl(p_sum10, 0);
            when 11 then return nvl(p_sum11, 0);
            when 12 then return nvl(p_sum12, 0);
            else return 0;
          end case;
        end;
        function cnt(p_date date,
                     p_sum1 number, p_sum2 number, p_sum3 number, p_sum4 number, p_sum5 number, p_sum6 number,
                     p_sum7 number, p_sum8 number, p_sum9 number, p_sum10 number, p_sum11 number, p_sum12 number) return number is
          l_period number:= to_char(p_date, 'mm');
        begin
          case
            when l_period =  1 and p_sum1 > 0 then return 1;
            when l_period =  2 and p_sum2 > 0 then return 1;
            when l_period =  3 and p_sum3 > 0 then return 1;
            when l_period =  4 and p_sum4 > 0 then return 1;
            when l_period =  5 and p_sum5 > 0 then return 1;
            when l_period =  6 and p_sum6 > 0 then return 1;
            when l_period =  7 and p_sum7 > 0 then return 1;
            when l_period =  8 and p_sum8 > 0 then return 1;
            when l_period =  9 and p_sum9 > 0 then return 1;
            when l_period = 10 and p_sum10 > 0 then return 1;
            when l_period = 11 and p_sum11 > 0 then return 1;
            when l_period = 12 and p_sum12 > 0 then return 1;
            else return 0;
          end case;
        end;

        d as (select :START# dt from dual),
        t as
        (
         select
                row_number() over(order by DECODE(Sca_Region, 'невизначено або відсутні дані', 9999, 0), nlssort(Sca_Region, 'NLS_SORT=ukrainian')) rn,
                sca.Sca_Region Region,
                count(distinct
                       case when
                          cnt(d.dt, p3.scp3_sum_m1, p3.scp3_sum_m2, p3.scp3_sum_m3, p3.scp3_sum_m4, p3.scp3_sum_m5, p3.scp3_sum_m6,
                              p3.scp3_sum_m7, p3.scp3_sum_m8, p3.scp3_sum_m9, p3.scp3_sum_m10, p3.scp3_sum_m11, p3.scp3_sum_m12) > 0 then sch.schh_id
                      end
                   ) count_all,
                sum(sm(d.dt, p3.scp3_sum_m1, p3.scp3_sum_m2, p3.scp3_sum_m3, p3.scp3_sum_m4, p3.scp3_sum_m5, p3.scp3_sum_m6,
                       p3.scp3_sum_m7, p3.scp3_sum_m8, p3.scp3_sum_m9, p3.scp3_sum_m10, p3.scp3_sum_m11, p3.scp3_sum_m12)
                   ) sum_all,

                --оплата користування житлом
                count(distinct
                       case when nppt.nppt_code = '101' and
                          cnt(d.dt, p3.scp3_sum_m1, p3.scp3_sum_m2, p3.scp3_sum_m3, p3.scp3_sum_m4, p3.scp3_sum_m5, p3.scp3_sum_m6,
                              p3.scp3_sum_m7, p3.scp3_sum_m8, p3.scp3_sum_m9, p3.scp3_sum_m10, p3.scp3_sum_m11, p3.scp3_sum_m12) > 0 then sch.schh_id
                      end
                   ) count_101,
                sum(case
                     when nppt.nppt_code = '101' then
                       sm(d.dt, p3.scp3_sum_m1, p3.scp3_sum_m2, p3.scp3_sum_m3, p3.scp3_sum_m4, p3.scp3_sum_m5, p3.scp3_sum_m6,
                          p3.scp3_sum_m7, p3.scp3_sum_m8, p3.scp3_sum_m9, p3.scp3_sum_m10, p3.scp3_sum_m11, p3.scp3_sum_m12)
                     else 0
                   end) sum_101,

                --опалення
                count(distinct
                       case when nppt.nppt_code in ('102.1', '107.1', '108.1') and
                         cnt(d.dt, p3.scp3_sum_m1, p3.scp3_sum_m2, p3.scp3_sum_m3, p3.scp3_sum_m4, p3.scp3_sum_m5, p3.scp3_sum_m6,
                             p3.scp3_sum_m7, p3.scp3_sum_m8, p3.scp3_sum_m9, p3.scp3_sum_m10, p3.scp3_sum_m11, p3.scp3_sum_m12) > 0 then sch.schh_id
                      end
                   ) count_102,
                sum(case when nppt.nppt_code in ('102.1', '107.1', '108.1') then
                      sm(d.dt, p3.scp3_sum_m1, p3.scp3_sum_m2, p3.scp3_sum_m3, p3.scp3_sum_m4, p3.scp3_sum_m5, p3.scp3_sum_m6,
                         p3.scp3_sum_m7, p3.scp3_sum_m8, p3.scp3_sum_m9, p3.scp3_sum_m10, p3.scp3_sum_m11, p3.scp3_sum_m12)
                     else 0
                   end) sum_102,

                --центр.водопостач.гарячої води
                count(distinct
                       case when nppt.nppt_code = '105' and
                         cnt(d.dt, p3.scp3_sum_m1, p3.scp3_sum_m2, p3.scp3_sum_m3, p3.scp3_sum_m4, p3.scp3_sum_m5, p3.scp3_sum_m6,
                              p3.scp3_sum_m7, p3.scp3_sum_m8, p3.scp3_sum_m9, p3.scp3_sum_m10, p3.scp3_sum_m11, p3.scp3_sum_m12) > 0 then sch.schh_id
                      end
                   ) count_105,
                sum(case
                     when nppt.nppt_code = '105' then
                       sm(d.dt, p3.scp3_sum_m1, p3.scp3_sum_m2, p3.scp3_sum_m3, p3.scp3_sum_m4, p3.scp3_sum_m5, p3.scp3_sum_m6,
                          p3.scp3_sum_m7, p3.scp3_sum_m8, p3.scp3_sum_m9, p3.scp3_sum_m10, p3.scp3_sum_m11, p3.scp3_sum_m12)
                     else 0
                   end) sum_105,

                --центр.водопостач. холодної води
                count(distinct
                       case when nppt.nppt_code in ('104.1', '104.2') and
                         cnt(d.dt, p3.scp3_sum_m1, p3.scp3_sum_m2, p3.scp3_sum_m3, p3.scp3_sum_m4, p3.scp3_sum_m5, p3.scp3_sum_m6,
                             p3.scp3_sum_m7, p3.scp3_sum_m8, p3.scp3_sum_m9, p3.scp3_sum_m10, p3.scp3_sum_m11, p3.scp3_sum_m12) > 0 then sch.schh_id
                      end
                   ) count_104,
                sum(case when nppt.nppt_code in ('104.1', '104.2') then
                      sm(d.dt, p3.scp3_sum_m1, p3.scp3_sum_m2, p3.scp3_sum_m3, p3.scp3_sum_m4, p3.scp3_sum_m5, p3.scp3_sum_m6,
                         p3.scp3_sum_m7, p3.scp3_sum_m8, p3.scp3_sum_m9, p3.scp3_sum_m10, p3.scp3_sum_m11, p3.scp3_sum_m12)
                     else 0
                   end) sum_104,

                --газопостачання на приготування їжі\підігріву води
                count(distinct
                       case when nppt.nppt_code in ('102.2', '102.3', '102.4') and
                         cnt(d.dt, p3.scp3_sum_m1, p3.scp3_sum_m2, p3.scp3_sum_m3, p3.scp3_sum_m4, p3.scp3_sum_m5, p3.scp3_sum_m6,
                             p3.scp3_sum_m7, p3.scp3_sum_m8, p3.scp3_sum_m9, p3.scp3_sum_m10, p3.scp3_sum_m11, p3.scp3_sum_m12) > 0 then sch.schh_id
                      end
                   ) count_1022,
                sum(case when nppt.nppt_code in ('102.2', '102.3', '102.4') then
                      sm(d.dt, p3.scp3_sum_m1, p3.scp3_sum_m2, p3.scp3_sum_m3, p3.scp3_sum_m4, p3.scp3_sum_m5, p3.scp3_sum_m6,
                         p3.scp3_sum_m7, p3.scp3_sum_m8, p3.scp3_sum_m9, p3.scp3_sum_m10, p3.scp3_sum_m11, p3.scp3_sum_m12)
                     else 0
                   end) sum_1022,

                --електропостачання
                count(distinct
                       case when nppt.nppt_code in ('108.2', '108.3', '108.4', '108.5') and
                         cnt(d.dt, p3.scp3_sum_m1, p3.scp3_sum_m2, p3.scp3_sum_m3, p3.scp3_sum_m4, p3.scp3_sum_m5, p3.scp3_sum_m6,
                             p3.scp3_sum_m7, p3.scp3_sum_m8, p3.scp3_sum_m9, p3.scp3_sum_m10, p3.scp3_sum_m11, p3.scp3_sum_m12) > 0 then sch.schh_id
                      end
                   ) count_108,
                sum(case when nppt.nppt_code in ('108.2', '108.3', '108.4', '108.5') then
                       sm(d.dt, p3.scp3_sum_m1, p3.scp3_sum_m2, p3.scp3_sum_m3, p3.scp3_sum_m4, p3.scp3_sum_m5, p3.scp3_sum_m6,
                          p3.scp3_sum_m7, p3.scp3_sum_m8, p3.scp3_sum_m9, p3.scp3_sum_m10, p3.scp3_sum_m11, p3.scp3_sum_m12)
                     else 0
                   end) sum_108,


                --вивезення відходів
                count(distinct
                       case when nppt.nppt_code in ('110.1', '110.2', '110.3', '111') and
                         cnt(d.dt, p3.scp3_sum_m1, p3.scp3_sum_m2, p3.scp3_sum_m3, p3.scp3_sum_m4, p3.scp3_sum_m5, p3.scp3_sum_m6,
                             p3.scp3_sum_m7, p3.scp3_sum_m8, p3.scp3_sum_m9, p3.scp3_sum_m10, p3.scp3_sum_m11, p3.scp3_sum_m12) > 0 then sch.schh_id
                      end
                   ) count_110,
                sum(case when nppt.nppt_code in ('110.1', '110.2', '110.3', '111') then
                      sm(d.dt, p3.scp3_sum_m1, p3.scp3_sum_m2, p3.scp3_sum_m3, p3.scp3_sum_m4, p3.scp3_sum_m5, p3.scp3_sum_m6,
                         p3.scp3_sum_m7, p3.scp3_sum_m8, p3.scp3_sum_m9, p3.scp3_sum_m10, p3.scp3_sum_m11, p3.scp3_sum_m12)
                     else 0
                   end) sum_110,

                --водовідведення
                count(distinct
                       case when nppt.nppt_code = '106' and
                         cnt(d.dt, p3.scp3_sum_m1, p3.scp3_sum_m2, p3.scp3_sum_m3, p3.scp3_sum_m4, p3.scp3_sum_m5, p3.scp3_sum_m6,
                             p3.scp3_sum_m7, p3.scp3_sum_m8, p3.scp3_sum_m9, p3.scp3_sum_m10, p3.scp3_sum_m11, p3.scp3_sum_m12) > 0 then sch.schh_id
                      end
                   ) count_106,
                sum(case
                     when nppt.nppt_code = '106' then
                       sm(d.dt, p3.scp3_sum_m1, p3.scp3_sum_m2, p3.scp3_sum_m3, p3.scp3_sum_m4, p3.scp3_sum_m5, p3.scp3_sum_m6,
                          p3.scp3_sum_m7, p3.scp3_sum_m8, p3.scp3_sum_m9, p3.scp3_sum_m10, p3.scp3_sum_m11, p3.scp3_sum_m12)
                     else 0
                   end) sum_106,

                --СГТП
                count(distinct
                       case when nppt.nppt_code in ('130', '140') and
                         cnt(d.dt, p3.scp3_sum_m1, p3.scp3_sum_m2, p3.scp3_sum_m3, p3.scp3_sum_m4, p3.scp3_sum_m5, p3.scp3_sum_m6,
                             p3.scp3_sum_m7, p3.scp3_sum_m8, p3.scp3_sum_m9, p3.scp3_sum_m10, p3.scp3_sum_m11, p3.scp3_sum_m12) > 0 then sch.schh_id
                      end
                   ) count_130,
                sum(case when nppt.nppt_code in ('130', '140') then
                       sm(d.dt, p3.scp3_sum_m1, p3.scp3_sum_m2, p3.scp3_sum_m3, p3.scp3_sum_m4, p3.scp3_sum_m5, p3.scp3_sum_m6,
                          p3.scp3_sum_m7, p3.scp3_sum_m8, p3.scp3_sum_m9, p3.scp3_sum_m10, p3.scp3_sum_m11, p3.scp3_sum_m12)
                     else 0
                   end) sum_130

           from d,
                uss_person.v_sc_pfu_pay_period p3,
                uss_person.v_sc_pfu_pay_summary pps,
                uss_person.v_sc_household sch,
                uss_person.v_Sc_Address sca,
                uss_ndi.v_ndi_pfu_payment_type nppt
          where p3.scp3_year = to_char(d.dt, 'yyyy')
            and pps.scpp_id = p3.scp3_scpp
            and pps.scpp_pfu_payment_tp = 'SUBSIDY'
            and sch.schh_id = pps.scpp_schh
            and sca.sca_id = sch.schh_sca
            and nppt.nppt_id = p3.scp3_nppt
            and nppt.nppt_code in ('101', '102.1', '107.1', '108.1', '105', '104.1', '104.2', '102.2', '102.3', '102.4',
                  '108.2', '108.3', '108.4', '108.5', '110.1', '110.2', '110.3', '111', '106', '130', '140')
          group by sca.Sca_Region
        )

        select rn,
               region   ,-- "назва області",
               /*to_char(count_all, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS='', ''''') as  */count_all,-- "кількість діючих субсидій, за видами послуг, всього (домогосподарств)",
               /*to_char(sum_all, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''''') as */sum_all,-- "сума нарахованих субсидій, за видами послуг, всього (грн)",

               /*to_char(count_101, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS='', ''''') as  */count_101,-- "оплата користування житлом(кількість)",
               /*to_char(sum_101, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''''') as */sum_101,-- "оплата користування житлом(грн)",
               /*to_char(count_102, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS='', ''''') as  */count_102,-- "опалення(кількість)",
               /*to_char(sum_102, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''''') as */sum_102,-- "опалення(грн)",
               /*to_char(count_105, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS='', ''''') as  */count_105,-- "центр.водопостач.гарячої води(кількість)",
               /*to_char(sum_105, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''''') as */sum_105,-- "центр.водопостач.гарячої води(грн)",
               /*to_char(count_104, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS='', ''''') as  */count_104,-- "центр.водопостач. холодної води(кількість)",
               /*to_char(sum_104, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''''') as */sum_104,-- "центр.водопостач. холодної води(грн)",
               /*to_char(count_1022, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS='', ''''') as */count_1022,--"газопостачання на приготування їжі\підігріву водикількість()",
               /*to_char(sum_1022, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''''') as*/ sum_1022,--"газопостачання на приготування їжі\підігріву води(грн)",
               /*to_char(count_108, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS='', ''''') as  */ count_108,--"електропостачання(кількість)",
               /*to_char(sum_108, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''''') as */ sum_108,--"електропостачання(грн)",
               /*to_char(count_110, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS='', ''''') as  */ count_110,--"вивезення відходів(кількість)",
               /*to_char(sum_110, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''''') as */ sum_110, --"вивезення відходів(грн)",
               /*to_char(count_106, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS='', ''''') as  */ count_106,--"водовідведення(кількість)",
               /*to_char(sum_106, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''''') as */ sum_106,--"водовідведення(грн)",
               /*to_char(count_130, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS='', ''''') as  */ count_130,--"СГТП (з числа тих, в кого є комунальні послуги)(кількість)",
               /*to_char(sum_130, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''''') as */ sum_130 --"СГТП (з числа тих, в кого є комунальні послуги)(грн)",
               --to_char(dt, 'Month yyyy', 'NLS_DATE_LANGUAGE = ukrainian') "Звітній місяць"
          from
               (select rn+1 rn,
                       case when (lower(Region)) = 'київ' then 'м. ' || initCap(Region)
                            when Region is not null then initCap(Region) || ' обл.'
                       end as Region,
                       count_all, sum_all,
                       count_101, sum_101, count_102, sum_102,
                       count_105, sum_105, count_104, sum_104,
                       count_1022, sum_1022, count_108, sum_108,
                       count_110, sum_110, count_106, sum_106,
                       count_130, sum_130
                 from t
                union all
                select 1 rn, 'УКРАЇНА' Region, sum(count_all) count_all, sum(sum_all) sum_all,
                       sum(count_101), sum(sum_101), sum(count_102), sum(sum_102),
                       sum(count_105), sum(sum_105), sum(count_104), sum(sum_104),
                       sum(count_1022), sum(sum_1022), sum(count_108), sum(sum_108),
                       sum(count_110), sum(sum_110), sum(count_106), sum(sum_106),
                       sum(count_130), sum(sum_130)
                  from t
               ), d
       order by rn
    ]';
        --підставити параметр
        l_sql :=
            REPLACE (
                l_sql,
                ':START#',
                   q'[to_date(']'
                || TO_CHAR (l_date, 'dd.mm.yyyy')
                || q'[', 'dd.mm.yyyy')]');

        RDM$RTFL.AddDataSet (l_jbr_id, 'ds', l_sql);

        RDM$RTFL.PutReportToWorkingQueue (p_jbr_id => l_jbr_id);
        RETURN l_jbr_id;
    END;

    -- Надання пільг на ЖКП у розрізі житлово-комунальних послуг
    FUNCTION BENEFIT_TYPE_JPK_SQL (p_start_dt IN DATE, p_kaot_id IN NUMBER)
        RETURN SYS_REFCURSOR
    IS
        l_cur          SYS_REFCURSOR;
        l_clob         CLOB;
        l_date         DATE := TRUNC (p_start_dt, 'mm');
        l_month        NUMBER := EXTRACT (MONTH FROM l_date);
        l_year         NUMBER := EXTRACT (YEAR FROM l_date);
        --l_org_to NUMBER;
        l_level        NUMBER;
        l_level_data   NUMBER;
        l_level_name   VARCHAR2 (500);
    BEGIN
        IF (l_year < 2023)
        THEN
            SELECT t.rt_text
              INTO l_clob
              FROM uss_esr.rpt_templates t
             WHERE     t.rt_doc_tp = 'BENEFIT_JKP_SQL_EDARP'
                   AND t.rt_code = 'BENEFIT_TYPE_JPK'
                   AND t.rt_file_tp = 'SQL';

            --підставити дату
            l_clob :=
                REPLACE (
                    l_clob,
                    ':DATE#',
                       q'[to_date(']'
                    || TO_CHAR (l_date, 'dd.mm.yyyy')
                    || q'[', 'dd.mm.yyyy') as dt, ]'
                    || l_month
                    || ' as mm, '
                    || l_year
                    || ' as yyyy');
        ELSE
            SELECT t.rt_text
              INTO l_clob
              FROM uss_esr.rpt_templates t
             WHERE     t.rt_doc_tp = 'BENEFIT_JKP_SQL'
                   AND t.rt_code = 'BENEFIT_TYPE_JPK'
                   AND t.rt_file_tp = 'SQL';

            get_kaot_info (p_kaot_id,
                           l_level,
                           l_level_data,
                           l_level_name);

            --підставити дату
            l_clob :=
                REPLACE (
                    l_clob,
                    ':START#',
                       q'[to_date(']'
                    || TO_CHAR (l_date, 'dd.mm.yyyy')
                    || q'[', 'dd.mm.yyyy')]');
            l_clob :=
                REPLACE (
                    l_clob,
                    ':KAOT_WHERE#',
                       ' and km.kaot_id = k.kaot_kaot_l'
                    || l_level
                    || CASE
                           WHEN p_kaot_id IS NOT NULL AND p_kaot_id != 0
                           THEN
                               ' and km.kaot_id = ' || p_kaot_id
                       END);
        END IF;

        OPEN l_cur FOR l_clob;

        RETURN l_cur;
    END;

    -- Надання пільг на ЖКП у розрізі житлово-комунальних послуг
    FUNCTION BENEFIT_TYPE_JPK_SQL_TOT (p_start_dt   IN DATE,
                                       p_kaot_id    IN NUMBER)
        RETURN SYS_REFCURSOR
    IS
        l_cur          SYS_REFCURSOR;
        l_clob         CLOB;
        l_date         DATE := TRUNC (p_start_dt, 'mm');
        l_month        NUMBER := EXTRACT (MONTH FROM l_date);
        l_year         NUMBER := EXTRACT (YEAR FROM l_date);
        l_org_to       NUMBER;
        l_level        NUMBER;
        l_level_data   NUMBER;
        l_level_name   VARCHAR2 (500);
    BEGIN
        IF (l_year < 2023)
        THEN
            SELECT t.rt_text
              INTO l_clob
              FROM uss_esr.rpt_templates t
             WHERE     t.rt_doc_tp = 'BENEFIT_JKP_SQL_EDARP_TOT'
                   AND t.rt_code = 'BENEFIT_TYPE_JPK'
                   AND t.rt_file_tp = 'SQL';

            --підставити дату
            l_clob :=
                REPLACE (
                    l_clob,
                    ':DATE#',
                       q'[to_date(']'
                    || TO_CHAR (l_date, 'dd.mm.yyyy')
                    || q'[', 'dd.mm.yyyy') as dt, ]'
                    || l_month
                    || ' as mm, '
                    || l_year
                    || ' as yyyy');
        ELSE
            SELECT t.rt_text
              INTO l_clob
              FROM uss_esr.rpt_templates t
             WHERE     t.rt_doc_tp = 'BENEFIT_JKP_SQL_TOT'
                   AND t.rt_code = 'BENEFIT_TYPE_JPK'
                   AND t.rt_file_tp = 'SQL';

            get_kaot_info (p_kaot_id,
                           l_level,
                           l_level_data,
                           l_level_name);

            --підставити дату
            l_clob :=
                REPLACE (
                    l_clob,
                    ':START#',
                       q'[to_date(']'
                    || TO_CHAR (l_date, 'dd.mm.yyyy')
                    || q'[', 'dd.mm.yyyy')]');
            l_clob :=
                REPLACE (
                    l_clob,
                    ':KAOT_WHERE#',
                       ' and km.kaot_id = k.kaot_kaot_l'
                    || l_level
                    || CASE
                           WHEN p_kaot_id IS NOT NULL AND p_kaot_id != 0
                           THEN
                               ' and km.kaot_id = ' || p_kaot_id
                       END);
        END IF;

        OPEN l_cur FOR l_clob;

        RETURN l_cur;
    END;

    -- Надання пільг на ЖКП у розрізі житлово-комунальних послуг
    FUNCTION BENEFIT_TYPE_JPK (p_start_dt   IN DATE,
                               p_kaot_id    IN NUMBER,
                               p_rt_id      IN rpt_templates.rt_id%TYPE)
        RETURN DECIMAL
    IS
        l_jbr_id    NUMBER;
        l_date      DATE := TRUNC (p_start_dt, 'mm');
        l_sql       VARCHAR2 (32000);
        l_sql_tot   VARCHAR2 (32000);
        l_region    VARCHAR2 (250);
    BEGIN
        l_jbr_id :=
            RDM$RTFL.InitReport (p_rt_id      => p_rt_id,
                                 p_rpt_name   => 'Пільги_ЖКП_категорії');
        RDM$RTFL.AddParam (
            l_jbr_id,
            'p_date',
            TO_CHAR (l_date, 'Month yyyy', 'NLS_DATE_LANGUAGE = ukrainian'));
        RDM$RTFL.AddParam (l_jbr_id,
                           'gen_dt',
                           TO_CHAR (SYSDATE, 'dd.mm.yyyy'));

        /* SELECT MAX(t.org_name)
           INTO l_region
           FROM v_opfu t
          WHERE t.org_id = p_org_id;*/
        SELECT MAX (t.kaot_full_name)
          INTO l_region
          FROM uss_ndi.v_ndi_katottg t
         WHERE t.kaot_id = p_kaot_id;

        l_region := CASE WHEN p_kaot_id = 0 THEN 'Україна' ELSE l_region END;
        RDM$RTFL.AddParam (l_jbr_id, 'region', l_region);
        rdm$rtfl.SetFileName (
            l_jbr_id,
               'Пільги_ЖКП_категорії'
            || '_'
            || TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS')
            || '.XLS');

        l_sql :=
            q'[
       select rownum as rn,
              nppt_name,
             /* to_char(count_1, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as   */count_1,
             /* to_char(sum_1, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */sum_1,
             /* to_char(count_2, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as   */count_2,
             /* to_char(sum_2, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */sum_2,
             /* to_char(count_3, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as   */count_3,
             /* to_char(sum_3, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */sum_3,
             /* to_char(count_4, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as   */count_4,
             /* to_char(sum_4, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */sum_4,
             /* to_char(count_11, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_11,
             /* to_char(sum_11, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_11,
             /* to_char(count_12, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_12,
             /* to_char(sum_12, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_12,
             /* to_char(count_13, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_13,
             /* to_char(sum_13, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_13,
             /* to_char(count_14, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_14,
             /* to_char(sum_14, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_14,
             /* to_char(count_20, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_20,
             /* to_char(sum_20, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_20,
             /* to_char(count_22, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_22,
             /* to_char(sum_22, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_22,
             /* to_char(count_23, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_23,
             /* to_char(sum_23, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_23,
             /* to_char(count_37, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_37,
             /* to_char(sum_37, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_37,
             /* to_char(count_38, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_38,
             /* to_char(sum_38, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_38,
             /* to_char(count_39, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_39,
             /* to_char(sum_39, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_39,
             /* to_char(count_44, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_44,
             /* to_char(sum_44, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_44,
             /* to_char(count_45, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_45,
             /* to_char(sum_45, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_45,
             /* to_char(count_46, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_46,
             /* to_char(sum_46, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_46,
             /* to_char(count_80, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_80,
             /* to_char(sum_80, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_80,
             /* to_char(count_81, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_81,
             /* to_char(sum_81, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_81,
             /* to_char(count_90, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_90,
             /* to_char(sum_90, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_90,
             /* to_char(count_91, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_91,
             /* to_char(sum_91, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_91,
             /* to_char(count_94, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_94,
             /* to_char(sum_94, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_94,
             /* to_char(count_97, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_97,
             /* to_char(sum_97, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_97,
             /* to_char(count_98, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_98,
             /* to_char(sum_98, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_98,
             /* to_char(count_99, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_99,
             /* to_char(sum_99, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_99,
             /* to_char(count_101, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ count_101,
             /* to_char(sum_101, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as*/  sum_101,
             /* to_char(count_102, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ count_102,
             /* to_char(sum_102, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as*/  sum_102,
             /* to_char(count_130, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ count_130,
             /* to_char(sum_130, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as*/  sum_130,
             /* to_char(count_131, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ count_131,
             /* to_char(sum_131, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as*/  sum_131,
             /* to_char(count_132, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ count_132,
             /* to_char(sum_132, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as*/  sum_132,
             /* to_char(count_15, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_15,
             /* to_char(sum_15, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_15,
             /* to_char(count_16, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_16,
             /* to_char(sum_16, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_16,
             /* to_char(count_17, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_17,
             /* to_char(sum_17, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_17,
             /* to_char(count_18, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_18,
             /* to_char(sum_18, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_18,
             /* to_char(count_19, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_19,
             /* to_char(sum_19, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_19,
             /* to_char(count_26, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_26,
             /* to_char(sum_26, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_26,
             /* to_char(count_30, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_30,
             /* to_char(sum_30, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_30,
             /* to_char(count_32, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_32,
             /* to_char(sum_32, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_32,
             /* to_char(count_35, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_35,
             /* to_char(sum_35, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_35,
             /* to_char(count_40, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_40,
             /* to_char(sum_40, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_40,
             /* to_char(count_41, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_41,
             /* to_char(sum_41, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_41,
             /* to_char(count_42, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_42,
             /* to_char(sum_42, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_42,
             /* to_char(count_43, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_43,
             /* to_char(sum_43, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_43,
             /* to_char(count_48, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_48,
             /* to_char(sum_48, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_48,
             /* to_char(count_54, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_54,
             /* to_char(sum_54, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_54,
             /* to_char(count_55, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_55,
             /* to_char(sum_55, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_55,
             /* to_char(count_56, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_56,
             /* to_char(sum_56, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_56,
             /* to_char(count_58, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_58,
             /* to_char(sum_58, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_58,
             /* to_char(count_60, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_60,
             /* to_char(sum_60, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_60,
             /* to_char(count_61, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_61,
             /* to_char(sum_61, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_61,
             /* to_char(count_62, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_62,
             /* to_char(sum_62, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_62,
             /* to_char(count_63, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_63,
             /* to_char(sum_63, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_63,
             /* to_char(count_64, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_64,
             /* to_char(sum_64, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_64,
             /* to_char(count_66, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_66,
             /* to_char(sum_66, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_66,
             /* to_char(count_67, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_67,
             /* to_char(sum_67, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_67,
             /* to_char(count_69, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_69,
             /* to_char(sum_69, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_69,
             /* to_char(count_85, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_85,
             /* to_char(sum_85, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_85,
             /* to_char(count_86, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_86,
             /* to_char(sum_86, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_86,
             /* to_char(count_87, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_87,
             /* to_char(sum_87, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_87,
             /* to_char(count_88, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_88,
             /* to_char(sum_88, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_88,
             /* to_char(count_89, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_89,
             /* to_char(sum_89, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_89,
             /* to_char(count_92, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_92,
             /* to_char(sum_92, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_92,
             /* to_char(count_93, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_93,
             /* to_char(sum_93, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_93,
             /* to_char(count_100, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ count_100,
             /* to_char(sum_100, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as*/  sum_100,
             /* to_char(count_120, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ count_120,
             /* to_char(sum_120, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as*/  sum_120,
             /* to_char(count_121, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ count_121,
             /* to_char(sum_121, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as*/  sum_121,
             /* to_char(count_122, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ count_122,
             /* to_char(sum_122, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as*/  sum_122,
             /* to_char(count_123, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ count_123,
             /* to_char(sum_123, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as*/  sum_123,
             /* to_char(count_124, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ count_124,
             /* to_char(sum_124, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as*/  sum_124,
             /* to_char(count_125, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ count_125,
             /* to_char(sum_125, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as*/  sum_125,

              -- NEW #92914
              count_21,--  "21 Сільський педагог працюючий. (кількість осіб) ",
              sum_21,  --  "21 Сільський педагог працюючий. (сума нарах пільг, грн) "
              count_27,--  "27 Сільський бібліотекар працюючий. (кількість осіб) ",
              sum_27,  --  "27 Сільський бібліотекар працюючий. (сума нарах пільг, грн) "
              count_28,--  "28 Сільський медик працюючий. (кількість осіб) ",
              sum_28,  --  "28 Сільський медик працюючий. (сума нарах пільг, грн) "
              count_29,--  "29 Сільський працівник культури працюючий (кількість осіб) ",
              sum_29,  --  "29 Сільський працівник культури працюючий (сума нарах пільг, грн) "
              count_33,--  "33 Ветеран праці. (кількість осіб) ",
              sum_33,  --  "33 Ветеран праці. (сума нарах пільг, грн) "
              count_34,--  "34 Пенсіонер за віком. (кількість осіб) ",
              sum_34,  --  "34 Пенсіонер за віком. (сума нарах пільг, грн) "
              count_36,--  "36 Дитина з багатодітної сім'ї (кількість осіб) ",
              sum_36,  --  "36 Дитина з багатодітної сім'ї (сума нарах пільг, грн) "
              count_95,--  "95 Пожежник на пенсії (кількість осіб) ",
              sum_95,  --  "95 Пожежник на пенсії (сума нарах пільг, грн) "
              count_96,--  "96 Непрацездатний член сім'ї загиблого пожежника (кількість осіб) ",
              sum_96,  --  "96 Непрацездатний член сім'ї загиблого пожежника (сума нарах пільг, грн) "
              count_110,--  "110 Особа з інвалідністю-дитина (кількість осіб) ",
              sum_110,  --  "110 Особа з інвалідністю-дитина (сума нарах пільг, грн) "
              count_111,--  "111 Особа з інвалідністю 1 групи по зору або з ураженням ОРА (кількість осіб) ",
              sum_111,  --  "111 Особа з інвалідністю 1 групи по зору або з ураженням ОРА (сума нарах пільг, грн) "
              count_112,--  "112 Особа з інвалідністю 2 групи по зору або з ураженням ОРА (кількість осіб) ",
              sum_112,  --  "112 Особа з інвалідністю 2 групи по зору або з ураженням ОРА (сума нарах пільг, грн) "
              count_113,--  "113 Особа з інвалідністю 1 групи (крім інвалідів по зору або з ураженням ОРА) (кількість осіб) ",
              sum_113,  --  "113 Особа з інвалідністю 1 групи (крім інвалідів по зору або з ураженням ОРА) (сума нарах пільг, грн) "
              count_114,--  "114 Особа з інвалідністю 2 групи (крім інвалідів по зору або з ураженням ОРА) (кількість осіб) ",
              sum_114,  --  "114 Особа з інвалідністю 2 групи (крім інвалідів по зору або з ураженням ОРА) (сума нарах пільг, грн) "
              count_115,--  "115 Особа з інвалідністю 3 групи (кількість осіб) ",
              sum_115,  --  "115 Особа з інвалідністю 3 групи (сума нарах пільг, грн) "

             /* to_char(count_all, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ count_all,
             /* to_char(sum_all, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as*/  sum_all
 from
        Xmltable('//ROW' Passing xmltype.createxml(uss_esr.DNET$RPT_BENEFITS.BENEFIT_TYPE_JPK_SQL(:START#, :KAOT#)) Columns
                   nppt_name  varchar2(250) Path 'NPPT_NAME',
                   count_1    number Path 'COUNT_1',
                   sum_1      number Path 'SUM_1',
                   count_2    number Path 'COUNT_2',
                   sum_2      number Path 'SUM_2',
                   count_3    number Path 'COUNT_3',
                   sum_3      number Path 'SUM_3',
                   count_4    number Path 'COUNT_4',
                   sum_4      number Path 'SUM_4',
                   count_11 number Path 'COUNT_11',
                   sum_11   number Path 'SUM_11',
                   count_12 number Path 'COUNT_12',
                   sum_12   number Path 'SUM_12',
                   count_13 number Path 'COUNT_13',
                   sum_13   number Path 'SUM_13',
                   count_14 number Path 'COUNT_14',
                   sum_14   number Path 'SUM_14',
                   count_20 number Path 'COUNT_20',
                   sum_20   number Path 'SUM_20',
                   count_22 number Path 'COUNT_22',
                   sum_22   number Path 'SUM_22',
                   count_23 number Path 'COUNT_23',
                   sum_23   number Path 'SUM_23',
                   count_37 number Path 'COUNT_37',
                   sum_37   number Path 'SUM_37',
                   count_38 number Path 'COUNT_38',
                   sum_38   number Path 'SUM_38',
                   count_39 number Path 'COUNT_39',
                   sum_39   number Path 'SUM_39',
                   count_44 number Path 'COUNT_44',
                   sum_44   number Path 'SUM_44',
                   count_45 number Path 'COUNT_45',
                   sum_45   number Path 'SUM_45',
                   count_46 number Path 'COUNT_46',
                   sum_46   number Path 'SUM_46',
                   count_80 number Path 'COUNT_80',
                   sum_80   number Path 'SUM_80',
                   count_81 number Path 'COUNT_81',
                   sum_81   number Path 'SUM_81',
                   count_90 number Path 'COUNT_90',
                   sum_90   number Path 'SUM_90',
                   count_91 number Path 'COUNT_91',
                   sum_91   number Path 'SUM_91',
                   count_94 number Path 'COUNT_94',
                   sum_94   number Path 'SUM_94',
                   count_97 number Path 'COUNT_97',
                   sum_97   number Path 'SUM_97',
                   count_98 number Path 'COUNT_98',
                   sum_98   number Path 'SUM_98',
                   count_99 number Path 'COUNT_99',
                   sum_99   number Path 'SUM_99',
                   count_101 number Path 'COUNT_101',
                   sum_101   number Path 'SUM_101',
                   count_102 number Path 'COUNT_102',
                   sum_102   number Path 'SUM_102',
                   count_130 number Path 'COUNT_130',
                   sum_130   number Path 'SUM_130',
                   count_131 number Path 'COUNT_131',
                   sum_131   number Path 'SUM_131',
                   count_132 number Path 'COUNT_132',
                   sum_132   number Path 'SUM_132',
                   count_15 number Path 'COUNT_15',
                   sum_15   number Path 'SUM_15',
                   count_16 number Path 'COUNT_16',
                   sum_16   number Path 'SUM_16',
                   count_17 number Path 'COUNT_17',
                   sum_17   number Path 'SUM_17',
                   count_18 number Path 'COUNT_18',
                   sum_18   number Path 'SUM_18',
                   count_19 number Path 'COUNT_19',
                   sum_19   number Path 'SUM_19',
                   count_26 number Path 'COUNT_26',
                   sum_26   number Path 'SUM_26',
                   count_30 number Path 'COUNT_30',
                   sum_30   number Path 'SUM_30',
                   count_32 number Path 'COUNT_32',
                   sum_32   number Path 'SUM_32',
                   count_35 number Path 'COUNT_35',
                   sum_35   number Path 'SUM_35',
                   count_40 number Path 'COUNT_40',
                   sum_40   number Path 'SUM_40',
                   count_41 number Path 'COUNT_41',
                   sum_41   number Path 'SUM_41',
                   count_42 number Path 'COUNT_42',
                   sum_42   number Path 'SUM_42',
                   count_43 number Path 'COUNT_43',
                   sum_43   number Path 'SUM_43',
                   count_48 number Path 'COUNT_48',
                   sum_48   number Path 'SUM_48',
                   count_54 number Path 'COUNT_54',
                   sum_54   number Path 'SUM_54',
                   count_55 number Path 'COUNT_55',
                   sum_55   number Path 'SUM_55',
                   count_56 number Path 'COUNT_56',
                   sum_56   number Path 'SUM_56',
                   count_58 number Path 'COUNT_58',
                   sum_58   number Path 'SUM_58',
                   count_60 number Path 'COUNT_60',
                   sum_60   number Path 'SUM_60',
                   count_61 number Path 'COUNT_61',
                   sum_61   number Path 'SUM_61',
                   count_62 number Path 'COUNT_62',
                   sum_62   number Path 'SUM_62',
                   count_63 number Path 'COUNT_63',
                   sum_63   number Path 'SUM_63',
                   count_64 number Path 'COUNT_64',
                   sum_64   number Path 'SUM_64',
                   count_66 number Path 'COUNT_66',
                   sum_66   number Path 'SUM_66',
                   count_67 number Path 'COUNT_67',
                   sum_67   number Path 'SUM_67',
                   count_69 number Path 'COUNT_69',
                   sum_69   number Path 'SUM_69',
                   count_85 number Path 'COUNT_85',
                   sum_85   number Path 'SUM_85',
                   count_86 number Path 'COUNT_86',
                   sum_86   number Path 'SUM_86',
                   count_87 number Path 'COUNT_87',
                   sum_87   number Path 'SUM_87',
                   count_88 number Path 'COUNT_88',
                   sum_88   number Path 'SUM_88',
                   count_89 number Path 'COUNT_89',
                   sum_89   number Path 'SUM_89',
                   count_92 number Path 'COUNT_92',
                   sum_92   number Path 'SUM_92',
                   count_93 number Path 'COUNT_93',
                   sum_93   number Path 'SUM_93',
                   count_100 number Path 'COUNT_100',
                   sum_100   number Path 'SUM_100',
                   count_120 number Path 'COUNT_120',
                   sum_120   number Path 'SUM_120',
                   count_121 number Path 'COUNT_121',
                   sum_121   number Path 'SUM_121',
                   count_122 number Path 'COUNT_122',
                   sum_122   number Path 'SUM_122',
                   count_123 number Path 'COUNT_123',
                   sum_123   number Path 'SUM_123',
                   count_124 number Path 'COUNT_124',
                   sum_124   number Path 'SUM_124',
                   count_125 number Path 'COUNT_125',
                   sum_125   number Path 'SUM_125',

                    -- NEW #92914
                    count_21 number Path 'COUNT_21',
                    sum_21 number Path 'SUM_21',
                    count_27 number Path 'COUNT_27',
                    sum_27 number Path 'SUM_27',
                    count_28 number Path 'COUNT_28',
                    sum_28 number Path 'SUM_28',
                    count_29 number Path 'COUNT_29',
                    sum_29 number Path 'SUM_29',
                    count_33 number Path 'COUNT_33',
                    sum_33 number Path 'SUM_33',
                    count_34 number Path 'COUNT_34',
                    sum_34 number Path 'SUM_34',
                    count_36 number Path 'COUNT_36',
                    sum_36 number Path 'SUM_36',
                    count_95 number Path 'COUNT_95',
                    sum_95 number Path 'SUM_95',
                    count_96 number Path 'COUNT_96',
                    sum_96 number Path 'SUM_96',
                    count_110 number Path 'COUNT_110',
                    sum_110 number Path 'SUM_110',
                    count_111 number Path 'COUNT_111',
                    sum_111 number Path 'SUM_111',
                    count_112 number Path 'COUNT_112',
                    sum_112 number Path 'SUM_112',
                    count_113 number Path 'COUNT_113',
                    sum_113 number Path 'SUM_113',
                    count_114 number Path 'COUNT_114',
                    sum_114 number Path 'SUM_114',
                    count_115 number Path 'COUNT_115',
                    sum_115 number Path 'SUM_115',

                   count_all number Path 'COUNT_ALL',
                   sum_all   number Path 'SUM_ALL'
                )
    ]';

        l_sql_tot :=
            q'[
       select /* to_char(count_1, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as   */count_1,
             /* to_char(sum_1, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */sum_1,
             /* to_char(count_2, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as   */count_2,
             /* to_char(sum_2, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */sum_2,
             /* to_char(count_3, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as   */count_3,
             /* to_char(sum_3, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */sum_3,
             /* to_char(count_4, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as   */count_4,
             /* to_char(sum_4, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */sum_4,
             /* to_char(count_11, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_11,
             /* to_char(sum_11, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_11,
             /* to_char(count_12, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_12,
             /* to_char(sum_12, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_12,
             /* to_char(count_13, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_13,
             /* to_char(sum_13, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_13,
             /* to_char(count_14, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_14,
             /* to_char(sum_14, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_14,
             /* to_char(count_20, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_20,
             /* to_char(sum_20, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_20,
             /* to_char(count_22, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_22,
             /* to_char(sum_22, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_22,
             /* to_char(count_23, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_23,
             /* to_char(sum_23, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_23,
             /* to_char(count_37, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_37,
             /* to_char(sum_37, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_37,
             /* to_char(count_38, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_38,
             /* to_char(sum_38, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_38,
             /* to_char(count_39, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_39,
             /* to_char(sum_39, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_39,
             /* to_char(count_44, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_44,
             /* to_char(sum_44, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_44,
             /* to_char(count_45, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_45,
             /* to_char(sum_45, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_45,
             /* to_char(count_46, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_46,
             /* to_char(sum_46, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_46,
             /* to_char(count_80, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_80,
             /* to_char(sum_80, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_80,
             /* to_char(count_81, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_81,
             /* to_char(sum_81, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_81,
             /* to_char(count_90, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_90,
             /* to_char(sum_90, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_90,
             /* to_char(count_91, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_91,
             /* to_char(sum_91, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_91,
             /* to_char(count_94, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_94,
             /* to_char(sum_94, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_94,
             /* to_char(count_97, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_97,
             /* to_char(sum_97, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_97,
             /* to_char(count_98, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_98,
             /* to_char(sum_98, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_98,
             /* to_char(count_99, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_99,
             /* to_char(sum_99, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_99,
             /* to_char(count_101, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ count_101,
             /* to_char(sum_101, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as*/  sum_101,
             /* to_char(count_102, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ count_102,
             /* to_char(sum_102, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as*/  sum_102,
             /* to_char(count_130, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ count_130,
             /* to_char(sum_130, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as*/  sum_130,
             /* to_char(count_131, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ count_131,
             /* to_char(sum_131, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as*/  sum_131,
             /* to_char(count_132, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ count_132,
             /* to_char(sum_132, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as*/  sum_132,
             /* to_char(count_15, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_15,
             /* to_char(sum_15, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_15,
             /* to_char(count_16, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_16,
             /* to_char(sum_16, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_16,
             /* to_char(count_17, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_17,
             /* to_char(sum_17, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_17,
             /* to_char(count_18, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_18,
             /* to_char(sum_18, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_18,
             /* to_char(count_19, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_19,
             /* to_char(sum_19, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_19,
             /* to_char(count_26, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_26,
             /* to_char(sum_26, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_26,
             /* to_char(count_30, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_30,
             /* to_char(sum_30, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_30,
             /* to_char(count_32, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_32,
             /* to_char(sum_32, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_32,
             /* to_char(count_35, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_35,
             /* to_char(sum_35, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_35,
             /* to_char(count_40, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_40,
             /* to_char(sum_40, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_40,
             /* to_char(count_41, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_41,
             /* to_char(sum_41, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_41,
             /* to_char(count_42, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_42,
             /* to_char(sum_42, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_42,
             /* to_char(count_43, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_43,
             /* to_char(sum_43, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_43,
             /* to_char(count_48, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_48,
             /* to_char(sum_48, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_48,
             /* to_char(count_54, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_54,
             /* to_char(sum_54, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_54,
             /* to_char(count_55, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_55,
             /* to_char(sum_55, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_55,
             /* to_char(count_56, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_56,
             /* to_char(sum_56, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_56,
             /* to_char(count_58, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_58,
             /* to_char(sum_58, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_58,
             /* to_char(count_60, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_60,
             /* to_char(sum_60, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_60,
             /* to_char(count_61, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_61,
             /* to_char(sum_61, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_61,
             /* to_char(count_62, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_62,
             /* to_char(sum_62, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_62,
             /* to_char(count_63, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_63,
             /* to_char(sum_63, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_63,
             /* to_char(count_64, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_64,
             /* to_char(sum_64, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_64,
             /* to_char(count_66, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_66,
             /* to_char(sum_66, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_66,
             /* to_char(count_67, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_67,
             /* to_char(sum_67, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_67,
             /* to_char(count_69, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_69,
             /* to_char(sum_69, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_69,
             /* to_char(count_85, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_85,
             /* to_char(sum_85, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_85,
             /* to_char(count_86, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_86,
             /* to_char(sum_86, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_86,
             /* to_char(count_87, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_87,
             /* to_char(sum_87, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_87,
             /* to_char(count_88, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_88,
             /* to_char(sum_88, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_88,
             /* to_char(count_89, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_89,
             /* to_char(sum_89, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_89,
             /* to_char(count_92, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_92,
             /* to_char(sum_92, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_92,
             /* to_char(count_93, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as  */count_93,
             /* to_char(sum_93, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ sum_93,
             /* to_char(count_100, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ count_100,
             /* to_char(sum_100, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as*/  sum_100,
             /* to_char(count_120, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ count_120,
             /* to_char(sum_120, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as*/  sum_120,
             /* to_char(count_121, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ count_121,
             /* to_char(sum_121, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as*/  sum_121,
             /* to_char(count_122, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ count_122,
             /* to_char(sum_122, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as*/  sum_122,
             /* to_char(count_123, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ count_123,
             /* to_char(sum_123, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as*/  sum_123,
             /* to_char(count_124, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ count_124,
             /* to_char(sum_124, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as*/  sum_124,
             /* to_char(count_125, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ count_125,
             /* to_char(sum_125, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as*/  sum_125,

              -- NEW #92914
              count_21,--  "21 Сільський педагог працюючий. (кількість осіб) ",
              sum_21,  --  "21 Сільський педагог працюючий. (сума нарах пільг, грн) "
              count_27,--  "27 Сільський бібліотекар працюючий. (кількість осіб) ",
              sum_27,  --  "27 Сільський бібліотекар працюючий. (сума нарах пільг, грн) "
              count_28,--  "28 Сільський медик працюючий. (кількість осіб) ",
              sum_28,  --  "28 Сільський медик працюючий. (сума нарах пільг, грн) "
              count_29,--  "29 Сільський працівник культури працюючий (кількість осіб) ",
              sum_29,  --  "29 Сільський працівник культури працюючий (сума нарах пільг, грн) "
              count_33,--  "33 Ветеран праці. (кількість осіб) ",
              sum_33,  --  "33 Ветеран праці. (сума нарах пільг, грн) "
              count_34,--  "34 Пенсіонер за віком. (кількість осіб) ",
              sum_34,  --  "34 Пенсіонер за віком. (сума нарах пільг, грн) "
              count_36,--  "36 Дитина з багатодітної сім'ї (кількість осіб) ",
              sum_36,  --  "36 Дитина з багатодітної сім'ї (сума нарах пільг, грн) "
              count_95,--  "95 Пожежник на пенсії (кількість осіб) ",
              sum_95,  --  "95 Пожежник на пенсії (сума нарах пільг, грн) "
              count_96,--  "96 Непрацездатний член сім'ї загиблого пожежника (кількість осіб) ",
              sum_96,  --  "96 Непрацездатний член сім'ї загиблого пожежника (сума нарах пільг, грн) "
              count_110,--  "110 Особа з інвалідністю-дитина (кількість осіб) ",
              sum_110,  --  "110 Особа з інвалідністю-дитина (сума нарах пільг, грн) "
              count_111,--  "111 Особа з інвалідністю 1 групи по зору або з ураженням ОРА (кількість осіб) ",
              sum_111,  --  "111 Особа з інвалідністю 1 групи по зору або з ураженням ОРА (сума нарах пільг, грн) "
              count_112,--  "112 Особа з інвалідністю 2 групи по зору або з ураженням ОРА (кількість осіб) ",
              sum_112,  --  "112 Особа з інвалідністю 2 групи по зору або з ураженням ОРА (сума нарах пільг, грн) "
              count_113,--  "113 Особа з інвалідністю 1 групи (крім інвалідів по зору або з ураженням ОРА) (кількість осіб) ",
              sum_113,  --  "113 Особа з інвалідністю 1 групи (крім інвалідів по зору або з ураженням ОРА) (сума нарах пільг, грн) "
              count_114,--  "114 Особа з інвалідністю 2 групи (крім інвалідів по зору або з ураженням ОРА) (кількість осіб) ",
              sum_114,  --  "114 Особа з інвалідністю 2 групи (крім інвалідів по зору або з ураженням ОРА) (сума нарах пільг, грн) "
              count_115,--  "115 Особа з інвалідністю 3 групи (кількість осіб) ",
              sum_115,  --  "115 Особа з інвалідністю 3 групи (сума нарах пільг, грн) "


             /* to_char(count_all, 'FM9G999G999G999G999G990', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as */ count_all,
             /* to_char(sum_all, 'FM9G999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''''')  as*/  sum_all
 from
        Xmltable('//ROW' Passing xmltype.createxml(uss_esr.DNET$RPT_BENEFITS.BENEFIT_TYPE_JPK_SQL_TOT(:START#, :KAOT#)) Columns
                   count_1    number Path 'COUNT_1',
                   sum_1      number Path 'SUM_1',
                   count_2    number Path 'COUNT_2',
                   sum_2      number Path 'SUM_2',
                   count_3    number Path 'COUNT_3',
                   sum_3      number Path 'SUM_3',
                   count_4    number Path 'COUNT_4',
                   sum_4      number Path 'SUM_4',
                   count_11 number Path 'COUNT_11',
                   sum_11   number Path 'SUM_11',
                   count_12 number Path 'COUNT_12',
                   sum_12   number Path 'SUM_12',
                   count_13 number Path 'COUNT_13',
                   sum_13   number Path 'SUM_13',
                   count_14 number Path 'COUNT_14',
                   sum_14   number Path 'SUM_14',
                   count_20 number Path 'COUNT_20',
                   sum_20   number Path 'SUM_20',
                   count_22 number Path 'COUNT_22',
                   sum_22   number Path 'SUM_22',
                   count_23 number Path 'COUNT_23',
                   sum_23   number Path 'SUM_23',
                   count_37 number Path 'COUNT_37',
                   sum_37   number Path 'SUM_37',
                   count_38 number Path 'COUNT_38',
                   sum_38   number Path 'SUM_38',
                   count_39 number Path 'COUNT_39',
                   sum_39   number Path 'SUM_39',
                   count_44 number Path 'COUNT_44',
                   sum_44   number Path 'SUM_44',
                   count_45 number Path 'COUNT_45',
                   sum_45   number Path 'SUM_45',
                   count_46 number Path 'COUNT_46',
                   sum_46   number Path 'SUM_46',
                   count_80 number Path 'COUNT_80',
                   sum_80   number Path 'SUM_80',
                   count_81 number Path 'COUNT_81',
                   sum_81   number Path 'SUM_81',
                   count_90 number Path 'COUNT_90',
                   sum_90   number Path 'SUM_90',
                   count_91 number Path 'COUNT_91',
                   sum_91   number Path 'SUM_91',
                   count_94 number Path 'COUNT_94',
                   sum_94   number Path 'SUM_94',
                   count_97 number Path 'COUNT_97',
                   sum_97   number Path 'SUM_97',
                   count_98 number Path 'COUNT_98',
                   sum_98   number Path 'SUM_98',
                   count_99 number Path 'COUNT_99',
                   sum_99   number Path 'SUM_99',
                   count_101 number Path 'COUNT_101',
                   sum_101   number Path 'SUM_101',
                   count_102 number Path 'COUNT_102',
                   sum_102   number Path 'SUM_102',
                   count_130 number Path 'COUNT_130',
                   sum_130   number Path 'SUM_130',
                   count_131 number Path 'COUNT_131',
                   sum_131   number Path 'SUM_131',
                   count_132 number Path 'COUNT_132',
                   sum_132   number Path 'SUM_132',
                   count_15 number Path 'COUNT_15',
                   sum_15   number Path 'SUM_15',
                   count_16 number Path 'COUNT_16',
                   sum_16   number Path 'SUM_16',
                   count_17 number Path 'COUNT_17',
                   sum_17   number Path 'SUM_17',
                   count_18 number Path 'COUNT_18',
                   sum_18   number Path 'SUM_18',
                   count_19 number Path 'COUNT_19',
                   sum_19   number Path 'SUM_19',
                   count_26 number Path 'COUNT_26',
                   sum_26   number Path 'SUM_26',
                   count_30 number Path 'COUNT_30',
                   sum_30   number Path 'SUM_30',
                   count_32 number Path 'COUNT_32',
                   sum_32   number Path 'SUM_32',
                   count_35 number Path 'COUNT_35',
                   sum_35   number Path 'SUM_35',
                   count_40 number Path 'COUNT_40',
                   sum_40   number Path 'SUM_40',
                   count_41 number Path 'COUNT_41',
                   sum_41   number Path 'SUM_41',
                   count_42 number Path 'COUNT_42',
                   sum_42   number Path 'SUM_42',
                   count_43 number Path 'COUNT_43',
                   sum_43   number Path 'SUM_43',
                   count_48 number Path 'COUNT_48',
                   sum_48   number Path 'SUM_48',
                   count_54 number Path 'COUNT_54',
                   sum_54   number Path 'SUM_54',
                   count_55 number Path 'COUNT_55',
                   sum_55   number Path 'SUM_55',
                   count_56 number Path 'COUNT_56',
                   sum_56   number Path 'SUM_56',
                   count_58 number Path 'COUNT_58',
                   sum_58   number Path 'SUM_58',
                   count_60 number Path 'COUNT_60',
                   sum_60   number Path 'SUM_60',
                   count_61 number Path 'COUNT_61',
                   sum_61   number Path 'SUM_61',
                   count_62 number Path 'COUNT_62',
                   sum_62   number Path 'SUM_62',
                   count_63 number Path 'COUNT_63',
                   sum_63   number Path 'SUM_63',
                   count_64 number Path 'COUNT_64',
                   sum_64   number Path 'SUM_64',
                   count_66 number Path 'COUNT_66',
                   sum_66   number Path 'SUM_66',
                   count_67 number Path 'COUNT_67',
                   sum_67   number Path 'SUM_67',
                   count_69 number Path 'COUNT_69',
                   sum_69   number Path 'SUM_69',
                   count_85 number Path 'COUNT_85',
                   sum_85   number Path 'SUM_85',
                   count_86 number Path 'COUNT_86',
                   sum_86   number Path 'SUM_86',
                   count_87 number Path 'COUNT_87',
                   sum_87   number Path 'SUM_87',
                   count_88 number Path 'COUNT_88',
                   sum_88   number Path 'SUM_88',
                   count_89 number Path 'COUNT_89',
                   sum_89   number Path 'SUM_89',
                   count_92 number Path 'COUNT_92',
                   sum_92   number Path 'SUM_92',
                   count_93 number Path 'COUNT_93',
                   sum_93   number Path 'SUM_93',
                   count_100 number Path 'COUNT_100',
                   sum_100   number Path 'SUM_100',
                   count_120 number Path 'COUNT_120',
                   sum_120   number Path 'SUM_120',
                   count_121 number Path 'COUNT_121',
                   sum_121   number Path 'SUM_121',
                   count_122 number Path 'COUNT_122',
                   sum_122   number Path 'SUM_122',
                   count_123 number Path 'COUNT_123',
                   sum_123   number Path 'SUM_123',
                   count_124 number Path 'COUNT_124',
                   sum_124   number Path 'SUM_124',
                   count_125 number Path 'COUNT_125',
                   sum_125   number Path 'SUM_125',

                    -- NEW #92914
                    count_21 number Path 'COUNT_21',
                    sum_21 number Path 'SUM_21',
                    count_27 number Path 'COUNT_27',
                    sum_27 number Path 'SUM_27',
                    count_28 number Path 'COUNT_28',
                    sum_28 number Path 'SUM_28',
                    count_29 number Path 'COUNT_29',
                    sum_29 number Path 'SUM_29',
                    count_33 number Path 'COUNT_33',
                    sum_33 number Path 'SUM_33',
                    count_34 number Path 'COUNT_34',
                    sum_34 number Path 'SUM_34',
                    count_36 number Path 'COUNT_36',
                    sum_36 number Path 'SUM_36',
                    count_95 number Path 'COUNT_95',
                    sum_95 number Path 'SUM_95',
                    count_96 number Path 'COUNT_96',
                    sum_96 number Path 'SUM_96',
                    count_110 number Path 'COUNT_110',
                    sum_110 number Path 'SUM_110',
                    count_111 number Path 'COUNT_111',
                    sum_111 number Path 'SUM_111',
                    count_112 number Path 'COUNT_112',
                    sum_112 number Path 'SUM_112',
                    count_113 number Path 'COUNT_113',
                    sum_113 number Path 'SUM_113',
                    count_114 number Path 'COUNT_114',
                    sum_114 number Path 'SUM_114',
                    count_115 number Path 'COUNT_115',
                    sum_115 number Path 'SUM_115',

                   count_all number Path 'COUNT_ALL',
                   sum_all   number Path 'SUM_ALL'
                )
    ]';

        --підставити параметр
        l_sql :=
            REPLACE (
                l_sql,
                ':START#',
                   q'[to_date(']'
                || TO_CHAR (l_date, 'dd.mm.yyyy')
                || q'[', 'dd.mm.yyyy')]');
        l_sql :=
            REPLACE (
                l_sql,
                ':KAOT#',
                CASE
                    WHEN p_kaot_id = 0 THEN 'NULL'
                    ELSE TO_CHAR (p_kaot_id)
                END);

        l_sql_tot :=
            REPLACE (
                l_sql_tot,
                ':START#',
                   q'[to_date(']'
                || TO_CHAR (l_date, 'dd.mm.yyyy')
                || q'[', 'dd.mm.yyyy')]');
        l_sql_tot :=
            REPLACE (
                l_sql_tot,
                ':KAOT#',
                CASE
                    WHEN p_kaot_id = 0 THEN 'NULL'
                    ELSE TO_CHAR (p_kaot_id)
                END);

        RDM$RTFL.AddDataSet (l_jbr_id, 'ds', l_sql);
        RDM$RTFL.AddDataSet (l_jbr_id, 'ds_tot', l_sql_tot);

        RDM$RTFL.PutReportToWorkingQueue (p_jbr_id => l_jbr_id);
        RETURN l_jbr_id;
    END;

    --#87983 Отримувачі житлових субсидій (мінімум/максимум)
    FUNCTION JKP_SUBSIDY_MAX_MIN (p_start_dt   IN DATE,
                                  p_kaot_id    IN NUMBER,
                                  p_rt_id      IN rpt_templates.rt_id%TYPE)
        RETURN DECIMAL
    IS
        l_jbr_id       NUMBER;
        l_date         DATE := TRUNC (p_start_dt, 'mm');
        l_sql          VARCHAR2 (32000);
        --l_sql_obl varchar2(32000);
        --l_org_to NUMBER;
        l_level        NUMBER;
        l_level_data   NUMBER;
        l_level_name   VARCHAR2 (500);
    BEGIN
        l_jbr_id :=
            RDM$RTFL.InitReport (
                p_rt_id      => p_rt_id,
                p_rpt_name   => 'Субсидії_ЖКП_мінімум_максимум');
        RDM$RTFL.AddParam (l_jbr_id,
                           'p_date',
                           TO_CHAR (ADD_MONTHS (l_date, 1), 'dd.mm.yyyy'));
        RDM$RTFL.AddParam (l_jbr_id,
                           'gen_dt',
                           TO_CHAR (SYSDATE, 'dd.mm.yyyy'));
        rdm$rtfl.SetFileName (
            l_jbr_id,
               'Субсидії_ЖКП_мінімум_максимум'
            || '_'
            || TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS')
            || '.XLS');

        get_kaot_info (p_kaot_id,
                       l_level,
                       l_level_data,
                       l_level_name);
        /*SELECT MAX(org_to)
          INTO l_org_to
          FROM v_opfu t
          WHERE org_id = p_org_id;
        l_sql:= q'[
           with
             d as (select :p_date dt, extract(YEAR from :p_date) yyyy, extract(MONTH from :p_date) mm from dual),
             t0 as  -- діючи рішення
              (
                select
                      dt, Sca_Region Region, sca_id, sum(sm) as sm
                 from
                     (select dt, sca.Sca_Region, sca_id,
                             case d.mm
                               when 1  then p.scp3_sum_m1
                               when 2  then p.scp3_sum_m2
                               when 3  then p.scp3_sum_m3
                               when 4  then p.scp3_sum_m4
                               when 5  then p.scp3_sum_m5
                               when 6  then p.scp3_sum_m6
                               when 7  then p.scp3_sum_m7
                               when 8  then p.scp3_sum_m8
                               when 9  then p.scp3_sum_m9
                               when 10 then p.scp3_sum_m10
                               when 11 then p.scp3_sum_m11
                               when 12 then p.scp3_sum_m12
                               else 0
                             end sm,
                             case
                               when d.mm =  1 and p.scp3_sum_m1 > 0 then 1
                               when d.mm =  2 and p.scp3_sum_m2 > 0 then 1
                               when d.mm =  3 and p.scp3_sum_m3 > 0 then 1
                               when d.mm =  4 and p.scp3_sum_m4 > 0 then 1
                               when d.mm =  5 and p.scp3_sum_m5 > 0 then 1
                               when d.mm =  6 and p.scp3_sum_m6 > 0 then 1
                               when d.mm =  7 and p.scp3_sum_m7 > 0 then 1
                               when d.mm =  8 and p.scp3_sum_m8 > 0 then 1
                               when d.mm =  9 and p.scp3_sum_m9 > 0 then 1
                               when d.mm = 10 and p.scp3_sum_m10 > 0 then 1
                               when d.mm = 11 and p.scp3_sum_m11 > 0 then 1
                               when d.mm = 12 and p.scp3_sum_m12 > 0 then 1
                               else 0
                             end cnt
                        from d,
                             uss_person.v_sc_pfu_pay_summary pps,
                             uss_person.v_sc_pfu_pay_period p,
                             uss_person.v_sc_household sch,
                             uss_person.v_Sc_Address sca,
                             uss_ndi.v_ndi_pfu_payment_type pt
                       where p.scp3_year = d.yyyy
                         AND pps.scpp_pfu_payment_tp = 'SUBSIDY'
                         and d.dt between pps.scpp_pfu_pd_start_dt and pps.scpp_pfu_pd_stop_dt
                         and sch.schh_id = pps.scpp_schh
                         AND p.scp3_scpp = pps.scpp_id
                         --and sca.sca_id = sch.schh_sca
                         and sca.sca_sc = p.scp3_sc
                         and sca.sca_tp = '5'
                         and sca.history_status = 'A'
                         AND pt.nppt_id(+) = p.scp3_nppt
                         and pps.scpp_pfu_pd_st not in ('PS', 'V')
                         and pt.nppt_id not in (13000, 14000)
                     )
                 where cnt > 0
                 group by dt, Sca_Region, sca_id
              ),
         t1 as
              (
               select
                      row_number() over(order by nlssort(Region, 'NLS_SORT=ukrainian')) rn,
                      case when (lower(Region)) = 'київ' then 'м. ' || initCap(Region)
                           when Region is not null then initCap(Region) || ' обл.'
                       end as Region,
                      count(distinct sca_id) count_all,
                      sum(sm) sum_all,
                      min(sm) sum_min,
                      max(sm) sum_max
                 from t0
                 --where sm > 0
               group by Region
              )

             select rn,
                    Region,
                    count_all,
                     sum_min,
                     sum_max,
                     sum_avg
               from
                    (select rn+1 rn,  Region, count_all, sum_min, sum_max, to_number(round(sum_all/count_all, 2)) sum_avg from t1
                     union all
                     select 1 rn, 'УКРАЇНА', sum(count_all), min(sum_min), max(sum_max),
                       to_number(decode(sum(count_all), null, null, 0, null, round(sum(sum_all)/sum(count_all), 2))) sum_avg from t1
                    )
            order by rn
        ]';

        l_sql_obl:= q'[
           with
             d as (select :p_date dt, extract(YEAR from :p_date) yyyy, extract(MONTH from :p_date) mm from dual),
             t0 as  -- діючи рішення
              (
                select
                      dt, Sca_Region Region, sca_id, sum(sm) as sm
                 from
                     (select dt, pr.org_name as Sca_Region, sca_id,
                             case d.mm
                               when 1  then p.scp3_sum_m1
                               when 2  then p.scp3_sum_m2
                               when 3  then p.scp3_sum_m3
                               when 4  then p.scp3_sum_m4
                               when 5  then p.scp3_sum_m5
                               when 6  then p.scp3_sum_m6
                               when 7  then p.scp3_sum_m7
                               when 8  then p.scp3_sum_m8
                               when 9  then p.scp3_sum_m9
                               when 10 then p.scp3_sum_m10
                               when 11 then p.scp3_sum_m11
                               when 12 then p.scp3_sum_m12
                               else 0
                             end sm,
                             case
                               when d.mm =  1 and p.scp3_sum_m1 > 0 then 1
                               when d.mm =  2 and p.scp3_sum_m2 > 0 then 1
                               when d.mm =  3 and p.scp3_sum_m3 > 0 then 1
                               when d.mm =  4 and p.scp3_sum_m4 > 0 then 1
                               when d.mm =  5 and p.scp3_sum_m5 > 0 then 1
                               when d.mm =  6 and p.scp3_sum_m6 > 0 then 1
                               when d.mm =  7 and p.scp3_sum_m7 > 0 then 1
                               when d.mm =  8 and p.scp3_sum_m8 > 0 then 1
                               when d.mm =  9 and p.scp3_sum_m9 > 0 then 1
                               when d.mm = 10 and p.scp3_sum_m10 > 0 then 1
                               when d.mm = 11 and p.scp3_sum_m11 > 0 then 1
                               when d.mm = 12 and p.scp3_sum_m12 > 0 then 1
                               else 0
                             end cnt
                        from d,
                             uss_person.v_sc_pfu_pay_summary pps,
                             uss_person.v_sc_pfu_pay_period p,
                             uss_person.v_sc_household sch,
                             uss_person.v_Sc_Address sca,
                             uss_ndi.v_ndi_pfu_payment_type pt,
                             uss_ndi.v_ndi_org2kaot k,
                             v_opfu pr,
                             v_opfu po
                       where pps.scpp_pfu_payment_tp = 'SUBSIDY'
                         and d.dt between pps.scpp_pfu_pd_start_dt and pps.scpp_pfu_pd_stop_dt
                         and sch.schh_id = pps.scpp_schh
                         AND p.scp3_scpp = pps.scpp_id
                         AND pt.nppt_id = p.scp3_nppt
                         and pps.scpp_pfu_pd_st not in ('PS', 'V')
                         and pt.nppt_id not in (13000, 14000)
                         --and sca.sca_id = sch.schh_sca
                         and sca.sca_sc = p.scp3_sc
                         and sca.sca_tp = '5'
                         and sca.history_status = 'A'
                         AND k.nok_kaot = sca.sca_kaot
                         and k.history_status = 'A'
                         --and d.dt between nvl(k.nk2o_start_dt, d.dt) AND nvl(k.nk2o_stop_dt, d.dt)
                         AND pr.org_id = k.nok_org
                         AND po.org_id = decode(pr.org_to, 32, pr.org_org, pr.org_id)
                         AND ]' || CASE WHEN l_org_to = 31 THEN ' po.org_id = ' || p_org_id  ELSE ' pr.org_id = ' || p_org_id  END || '
                     )
                 where cnt > 0
                 group by dt, Sca_Region, sca_id
              ),
         t1 as
              (
               select
                      row_number() over(order by nlssort(Region, ''NLS_SORT=ukrainian'')) rn,
                      Region,
                      count(distinct sca_id) count_all,
                      sum(sm) sum_all,
                      min(sm) sum_min,
                      max(sm) sum_max
                 from t0
                 --where sm > 0
               group by Region
              )

             select rn,
                    initcap(Region) as Region,
                    count_all,
                    sum_min,
                    sum_max,
                    sum_avg
               from (select rn rn,  Region, count_all, sum_min, sum_max, to_number(round(sum_all/count_all, 2)) sum_avg from t1
                    )
            order by rn
        ';*/

        l_sql :=
               q'[
       with
         d as (select :p_date dt, extract(YEAR from :p_date) yyyy, extract(MONTH from :p_date) mm from dual),
         t0 as  -- діючи рішення
          (
            select
                  dt, Sca_Region Region, sca_id, sum(sm) as sm
             from
                 (select dt,  nvl(kd.kaot_full_name, 'невизначено або відсутні дані') Sca_Region, sca_id,
                         case d.mm
                           when 1  then p.scp3_sum_m1
                           when 2  then p.scp3_sum_m2
                           when 3  then p.scp3_sum_m3
                           when 4  then p.scp3_sum_m4
                           when 5  then p.scp3_sum_m5
                           when 6  then p.scp3_sum_m6
                           when 7  then p.scp3_sum_m7
                           when 8  then p.scp3_sum_m8
                           when 9  then p.scp3_sum_m9
                           when 10 then p.scp3_sum_m10
                           when 11 then p.scp3_sum_m11
                           when 12 then p.scp3_sum_m12
                           else 0
                         end sm,
                         case
                           when d.mm =  1 and p.scp3_sum_m1 > 0 then 1
                           when d.mm =  2 and p.scp3_sum_m2 > 0 then 1
                           when d.mm =  3 and p.scp3_sum_m3 > 0 then 1
                           when d.mm =  4 and p.scp3_sum_m4 > 0 then 1
                           when d.mm =  5 and p.scp3_sum_m5 > 0 then 1
                           when d.mm =  6 and p.scp3_sum_m6 > 0 then 1
                           when d.mm =  7 and p.scp3_sum_m7 > 0 then 1
                           when d.mm =  8 and p.scp3_sum_m8 > 0 then 1
                           when d.mm =  9 and p.scp3_sum_m9 > 0 then 1
                           when d.mm = 10 and p.scp3_sum_m10 > 0 then 1
                           when d.mm = 11 and p.scp3_sum_m11 > 0 then 1
                           when d.mm = 12 and p.scp3_sum_m12 > 0 then 1
                           else 0
                         end cnt
                    from d,
                         uss_person.v_sc_pfu_pay_summary pps,
                         uss_person.v_sc_pfu_pay_period p,
                         uss_person.v_sc_household sch,
                         uss_person.v_Sc_Address sca,
                         uss_ndi.v_ndi_pfu_payment_type pt,
                         uss_ndi.v_ndi_katottg k,
                         uss_ndi.v_ndi_katottg km,
                         uss_ndi.v_ndi_katottg kd
                   where p.scp3_year = d.yyyy
                     AND pps.scpp_pfu_payment_tp = 'SUBSIDY'
                     and d.dt between pps.scpp_pfu_pd_start_dt and pps.scpp_pfu_pd_stop_dt
                     and sch.schh_id = pps.scpp_schh
                     AND p.scp3_scpp = pps.scpp_id
                     --and sca.sca_id = sch.schh_sca
                     and sca.sca_sc = p.scp3_sc
                     and sca.sca_tp = '5'
                     and sca.history_status = 'A'
                     and k.kaot_id = sca.sca_kaot
                     and km.kaot_id = k.kaot_kaot_l]'
            || l_level
            || '
                     and kd.kaot_id(+) = k.kaot_kaot_l'
            || l_level_data
            || CASE
                   WHEN p_kaot_id IS NOT NULL AND p_kaot_id != 0
                   THEN
                       ' and km.kaot_id = ' || p_kaot_id
               END
            || '
                     AND pt.nppt_id(+) = p.scp3_nppt
                     and pps.scpp_pfu_pd_st not in (''PS'', ''V'')
                     and pt.nppt_id not in (13000, 14000)
                 )
             where cnt > 0
             group by dt, Sca_Region, sca_id
          ),
     t1 as
          (
           select
                  row_number() over(order by DECODE(Region, ''невизначено або відсутні дані'', 9999, 0), nlssort(Region, ''NLS_SORT=ukrainian'')) rn,
                  Region,
                  count(distinct sca_id) count_all,
                  sum(sm) sum_all,
                  min(sm) sum_min,
                  max(sm) sum_max
             from t0
             --where sm > 0
           group by Region
          )

         select rn,
                Region,          -- назва області
                count_all,       -- кількість діючих субсидій, всього (домогосподарств)
                sum_min,         -- мінімальний розмір призначеної субсидії
                sum_max,         -- максимальний розмір призначеної субсидії
                sum_avg          -- середній розмір призначеної субсидії
           from
                (select rn+1 rn,  Region, count_all, sum_min, sum_max,
                        to_number(round(sum_all/count_all, 2)) sum_avg
                   from t1
                 union all
                 select 1 rn, '''
            || l_level_name
            || ''', sum(count_all), min(sum_min), max(sum_max),
                        /*to_number(decode(sum(count_all), null, null, 0, null, round(sum(sum_all)/sum(count_all), 2)))*/
                        to_number(decode(count(*), null, null, 0, null, round(sum(round(sum_all/count_all, 2))/count(*), 2))) as sum_avg
                   from t1
                )
        order by rn
    ';

        --підставити параметр
        /*IF (p_org_id IS NULL OR p_org_id = 0) THEN
          l_sql:= replace(l_sql, ':p_date', q'[to_date(']'||to_char(l_date, 'dd.mm.yyyy')||q'[', 'dd.mm.yyyy')]');
          RDM$RTFL.AddDataSet(l_jbr_id, 'ds', l_sql);
        ELSE
          l_sql_obl := replace(l_sql_obl, ':p_date', q'[to_date(']'||to_char(l_date, 'dd.mm.yyyy')||q'[', 'dd.mm.yyyy')]');
          RDM$RTFL.AddDataSet(l_jbr_id, 'ds', l_sql_obl);
        END IF;*/

        l_sql :=
            REPLACE (
                l_sql,
                ':p_date',
                   q'[to_date(']'
                || TO_CHAR (l_date, 'dd.mm.yyyy')
                || q'[', 'dd.mm.yyyy')]');
        RDM$RTFL.AddDataSet (l_jbr_id, 'ds', l_sql);

        RDM$RTFL.PutReportToWorkingQueue (p_jbr_id => l_jbr_id);
        RETURN l_jbr_id;
    END;

    -- #92280 Інформація щодо стану призначення субсидій на оплату житлово-комунальних послуг станом на
    FUNCTION SUBSIDY_INFO_R1 (p_start_dt   IN DATE,
                              p_rt_id      IN rpt_templates.rt_id%TYPE,
                              p_kaot_id    IN NUMBER)
        RETURN DECIMAL
    IS
        l_jbr_id       NUMBER;
        l_date         DATE := TRUNC (p_start_dt, 'mm');
        l_sql          VARCHAR2 (32000);
        --l_sql_obl    varchar2(32000);
        --l_org_to NUMBER;
        l_level        NUMBER;
        l_level_data   NUMBER;
        l_level_name   VARCHAR2 (500);
    BEGIN
        l_jbr_id :=
            RDM$RTFL.InitReport (p_rt_id      => p_rt_id,
                                 p_rpt_name   => 'Субсидії_ЖКП_призначення');
        RDM$RTFL.AddParam (l_jbr_id,
                           'p_date',
                           TO_CHAR (ADD_MONTHS (l_date, 1), 'dd.mm.yyyy'));
        RDM$RTFL.AddParam (l_jbr_id,
                           'gen_dt',
                           TO_CHAR (SYSDATE, 'dd.mm.yyyy'));
        rdm$rtfl.SetFileName (
            l_jbr_id,
               'Субсидії_ЖКП_призначення'
            || '_'
            || TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS')
            || '.XLS');

        get_kaot_info (p_kaot_id,
                       l_level,
                       l_level_data,
                       l_level_name);
        /*SELECT MAX(org_to)
          INTO l_org_to
          FROM v_opfu t
          WHERE org_id = p_org_id;
          l_sql:= q'[
           WITH     d as (select :p_date dt, extract(YEAR from :p_date) yyyy, extract(MONTH from :p_date) mm from dual),
             t as
              (SELECT row_number() over(order by nlssort(Sca_Region, 'NLS_SORT=ukrainian')) rn,
                      Sca_Region AS col_2,
                      COUNT(DISTINCT active_schh) AS col_3,
                      COUNT(DISTINCT CASE WHEN total_sum_by_schh != 0 THEN active_schh END) AS col_4,
                      COUNT(DISTINCT CASE WHEN total_sum_by_schh = 0 THEN active_schh END) AS col_5,

                      case when nvl(COUNT(DISTINCT active_schh), 0) != 0 then
                        ROUND(SUM(cur_sum) / COUNT(DISTINCT active_schh), 2)
                      end AS col_6,
                      case when nvl(COUNT(DISTINCT CASE WHEN total_sum_by_schh != 0 THEN active_schh END), 0) != 0 then
                         ROUND(SUM(cur_sum) / COUNT(DISTINCT CASE WHEN total_sum_by_schh != 0 THEN active_schh END), 2)
                      end AS col_7,

                      COUNT(DISTINCT active_cur_schh) AS col_8,
                      null AS col_9,
                      COUNT(DISTINCT CASE WHEN is_invalid = 1 THEN active_cur_schh END) AS col_10,
                      COUNT(DISTINCT CASE WHEN is_pilg = 1 THEN active_cur_schh END) AS col_11,
                      COUNT(DISTINCT CASE WHEN is_pilg = 0 and is_invalid = 0 and is_vpo = 0 THEN active_cur_schh END) AS col_12,
                      SUM(cur_sum) AS col_13,
                      null AS col_14,

                      COUNT(DISTINCT active_cur_scp3) AS col_15,
                      null AS col_16,
                      COUNT(DISTINCT CASE WHEN is_invalid = 1 THEN active_cur_scp3 END) AS col_17,
                      COUNT(DISTINCT CASE WHEN is_pilg = 1 THEN active_cur_scp3 END) AS col_18,
                      COUNT(DISTINCT CASE WHEN is_pilg = 0 and is_invalid = 0 and is_vpo = 0 THEN active_cur_scp3 END) AS col_19,
                      SUM(cur_pfu_sum) AS col_20,
                      MIN(cur_pfu_sum) AS col_21,
                      MAX(cur_pfu_sum) AS col_22,
                      case when nvl(COUNT(DISTINCT active_cur_scp3), 0) != 0 then
                        ROUND(SUM(cur_pfu_sum) / COUNT(DISTINCT active_cur_scp3), 2)
                      end AS col_23,

                      COUNT(DISTINCT schh_24) AS col_24,
                      COUNT(DISTINCT CASE WHEN is_vpo = 1 THEN schh_24 END) AS col_25,
                      COUNT(DISTINCT CASE WHEN is_n215 = 1 THEN schh_26 END) as col_26,
                      sum(case when is_n215 = 1 THEN cur_sum END) AS col_27
                 FROM (
                     select
                            --row_number() over(order by nlssort(Sca_Region, 'NLS_SORT=ukrainian')) rn,
                            Sca_Region,
                            sca_id,
                            schh_sc,
                            SUM(total_sum) AS total_sum_by_schh,
                            MAX(case when scp3_year = d.yyyy AND cnt > 0 then active_sch end) AS active_schh,
                            MAX(case when cnt > 0 then active_cur_sch end) AS active_cur_schh,
                            MAX(active_cur_scp3) AS active_cur_scp3,
                            MAX(cur_month_sch) AS cur_month_schh,
                            MAX(schh_24) AS schh_24,
                            MAX(schh_26) AS schh_26,

                            SUM(CASE WHEN scp3_year = d.yyyy AND cnt > 0 THEN sm END) AS cur_sum,
                            SUM(CASE WHEN scp3_year = d.yyyy THEN cnt END) AS cur_cnt,
                            SUM(CASE WHEN TRUNC(scpp_pfu_pd_dt, 'MM') = d.dt AND cnt > 0 THEN sm END) AS cur_pfu_sum,


                            max(CASE WHEN nppt_code in ('21501', '21502') THEN 1 else 0 END) AS is_n215,
                           -- max(CASE WHEN nppt_code not in ('21501', '21502') THEN 1 else 0 END) AS is_not_n215,
                            CASE WHEN f.scf_is_migrant = 'T' THEN 1 else 0 END AS is_vpo,
                            CASE WHEN
                              (SELECT COUNT(*)
                                 FROM uss_person.v_Sc_Scpp_Family pf
                                 JOIN uss_person.v_sc_feature zf ON (zf.scf_sc = pf.scpf_sc)
                                WHERE pf.scpf_scpp = scpp_id
                                  AND pf.scpf_sc = schh_sc
                                  AND zf.scf_is_dasabled = 'T'
                              ) > 0 THEN 1 else 0
                            END AS is_invalid,
                            CASE WHEN
                              (SELECT COUNT(*)
                                 FROM uss_person.v_Sc_Scpp_Family pf
                                 JOIN uss_person.v_sc_feature zf ON (zf.scf_sc = pf.scpf_sc)
                                WHERE pf.scpf_scpp = scpp_id
                                  AND pf.scpf_sc = schh_sc
                                  AND (zf.scf_is_singl_parent = 'T' OR zf.scf_is_large_family = 'T' OR zf.scf_is_low_income = 'T')
                              ) > 0 THEN 1 else 0
                            END AS is_pilg
                       from
                           (select sca.Sca_Region, pps.scpp_id, nppt.nppt_code, sca_id, sch.schh_sc,
                                   scp3_year,
                                   scpp_pfu_pd_dt,
                                   case d.mm
                                     when 1  then p3.scp3_sum_m1
                                     when 2  then p3.scp3_sum_m2
                                     when 3  then p3.scp3_sum_m3
                                     when 4  then p3.scp3_sum_m4
                                     when 5  then p3.scp3_sum_m5
                                     when 6  then p3.scp3_sum_m6
                                     when 7  then p3.scp3_sum_m7
                                     when 8  then p3.scp3_sum_m8
                                     when 9  then p3.scp3_sum_m9
                                     when 10 then p3.scp3_sum_m10
                                     when 11 then p3.scp3_sum_m11
                                     when 12 then p3.scp3_sum_m12
                                     else 0
                                   end sm,
                                   case
                                     when d.mm =  1 and p3.scp3_sum_m1 > 0 then 1
                                     when d.mm =  2 and p3.scp3_sum_m2 > 0 then 1
                                     when d.mm =  3 and p3.scp3_sum_m3 > 0 then 1
                                     when d.mm =  4 and p3.scp3_sum_m4 > 0 then 1
                                     when d.mm =  5 and p3.scp3_sum_m5 > 0 then 1
                                     when d.mm =  6 and p3.scp3_sum_m6 > 0 then 1
                                     when d.mm =  7 and p3.scp3_sum_m7 > 0 then 1
                                     when d.mm =  8 and p3.scp3_sum_m8 > 0 then 1
                                     when d.mm =  9 and p3.scp3_sum_m9 > 0 then 1
                                     when d.mm = 10 and p3.scp3_sum_m10 > 0 then 1
                                     when d.mm = 11 and p3.scp3_sum_m11 > 0 then 1
                                     when d.mm = 12 and p3.scp3_sum_m12 > 0 then 1
                                     else 0
                                   end cnt,

                                   CASE WHEN pps.scpp_pfu_pd_st NOT IN ('PS', 'V') AND d.dt < pps.scpp_pfu_pd_stop_dt THEN sca_id END AS active_sch,
                                   CASE WHEN pps.scpp_pfu_pd_st NOT IN ('PS', 'V') AND d.dt BETWEEN pps.scpp_pfu_pd_start_dt AND pps.scpp_pfu_pd_stop_dt THEN sca_id END AS active_cur_sch,
                                   CASE WHEN pps.scpp_pfu_pd_st NOT IN ('PS', 'V') AND TRUNC(pps.scpp_pfu_pd_dt, 'MM') = d.dt THEN scp3_id END AS active_cur_scp3,
                                   CASE WHEN TRUNC(pps.scpp_pfu_pd_dt, 'MM') = d.dt THEN sca_id END AS cur_month_sch,
                                   nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) + nvl(p3.scp3_sum_m9, 0) + nvl(p3.scp3_sum_m10, 0) + nvl(p3.scp3_sum_m11, 0) + nvl(p3.scp3_sum_m12, 0) AS total_sum,

                                   CASE WHEN pps.scpp_pfu_pd_st IN ('V') AND d.dt BETWEEN pps.scpp_pfu_pd_start_dt AND pps.scpp_pfu_pd_stop_dt THEN sca_id END AS schh_24,
                                   CASE WHEN pps.scpp_pfu_pd_st IN ('S') AND d.dt BETWEEN pps.scpp_pfu_pd_start_dt AND pps.scpp_pfu_pd_stop_dt THEN sca_id END AS schh_26
                                   --CASE WHEN pps.scpp_pfu_pd_st IN ('S') AND d.dt BETWEEN pps.scpp_pfu_pd_start_dt AND pps.scpp_pfu_pd_stop_dt THEN scp3_id END AS scp3_27
                              from d,
                                   uss_person.v_sc_pfu_pay_period p3,
                                   uss_person.v_sc_pfu_pay_summary pps,
                                   uss_person.v_sc_household sch,
                                   uss_person.v_Sc_Address sca,
                                   uss_ndi.v_ndi_pfu_payment_type nppt
                             where 1 = 1
                               and pps.scpp_id = p3.scp3_scpp
                               and pps.scpp_pfu_payment_tp = 'SUBSIDY'
                               and sch.schh_id = pps.scpp_schh
                               --and sca.sca_id = sch.schh_sca
                               and sca.sca_sc = p3.scp3_sc
                               and sca.sca_tp = '5'
                               and sca.history_status = 'A'
                               and nppt.nppt_id(+) = p3.scp3_nppt
                               and d.dt between pps.scpp_pfu_pd_start_dt and pps.scpp_pfu_pd_stop_dt
                               and nppt.nppt_id not in (13000, 14000)
                           ) t
                       JOIN d ON (1 = 1)
                       left JOIN uss_person.v_sc_feature f ON (f.scf_sc = t.schh_sc)
                       group by Sca_Region, scpp_id, sca_id, schh_sc, f.scf_is_migrant
                  )
                  group by Sca_Region
              )
             select rn,
                    col_2,--    "назва області",
                    col_3,
                    col_4,
                    col_5,
                    col_6,
                    col_7,
                    col_8,
                    col_9,
                    col_10,
                    col_11,
                    col_12,
                    col_13/1000 as col_13,
                    col_14,
                    col_15,
                    col_16,
                    col_17,
                    col_18,
                    col_19,
                    col_20/1000 as  col_20,
                    col_21,
                    col_22,
                    col_23,
                    col_24,
                    col_25,
                    col_26,
                    col_27/1000 as  col_27
               from
                    (select rn+1 rn,
                            case when (lower(col_2)) = 'київ' then 'м. ' || initCap(col_2)
                                when col_2 is not null then initCap(col_2) || ' обл.'
                            end as col_2, --    "назва області",
                            col_3,
                            col_4,
                            col_5,
                            col_6,
                            col_7,
                            col_8,
                            col_9,
                            col_10,
                            col_11,
                            col_12,
                            col_13,
                            col_14,
                            col_15,
                            col_16,
                            col_17,
                            col_18,
                            col_19,
                            col_20,
                            col_21,
                            col_22,
                            col_23,
                            col_24,
                            col_25,
                            col_26,
                            col_27
                       from t
                     union all
                     select 1 rn,
                            'УКРАЇНА',
                            sum(col_3),
                            sum(col_4),
                            sum(col_5),
                            ROUND(sum(col_6) / COUNT(*), 2),
                            ROUND(sum(col_7) / COUNT(*), 2),
                            sum(col_8),
                            sum(col_9),
                            sum(col_10),
                            sum(col_11),
                            sum(col_12),
                            sum(col_13),
                            sum(col_14),
                            sum(col_15),
                            sum(col_16),
                            sum(col_17),
                            sum(col_18),
                            sum(col_19),
                            sum(col_20),
                            MIN(col_21),
                            MAX(col_22),
                            ROUND(sum(col_23) / COUNT(*), 2),
                            sum(col_24),
                            sum(col_25),
                            sum(col_26),
                            sum(col_27)
                       from t
                    ), d
            order by rn
        ]';

        l_sql_obl:= q'[
           WITH     d as (select :p_date dt, extract(YEAR from :p_date) yyyy, extract(MONTH from :p_date) mm from dual),
             t as
              (SELECT row_number() over(order by nlssort(Sca_Region, 'NLS_SORT=ukrainian')) rn,
                      Sca_Region AS col_2,
                      COUNT(DISTINCT active_schh1) AS col_3,
                      COUNT(DISTINCT CASE WHEN total_sum_by_schh != 0 THEN active_schh END) AS col_4,
                      COUNT(DISTINCT CASE WHEN total_sum_by_schh = 0 THEN active_schh END) AS col_5,

                      case when nvl(COUNT(DISTINCT active_schh), 0) != 0 then
                        ROUND(SUM(cur_sum) / COUNT(DISTINCT active_schh), 2)
                      end AS col_6,
                      case when nvl(COUNT(DISTINCT CASE WHEN total_sum_by_schh != 0 THEN active_schh END), 0) != 0 then
                         ROUND(SUM(cur_sum) / COUNT(DISTINCT CASE WHEN total_sum_by_schh != 0 THEN active_schh END), 2)
                      end AS col_7,

                      COUNT(DISTINCT active_cur_schh) AS col_8,
                      null AS col_9,
                      COUNT(DISTINCT CASE WHEN is_invalid = 1 THEN active_cur_schh END) AS col_10,
                      COUNT(DISTINCT CASE WHEN is_pilg = 1 THEN active_cur_schh END) AS col_11,
                      COUNT(DISTINCT CASE WHEN is_pilg = 0 and is_invalid = 0 and is_vpo = 0 THEN active_cur_schh END) AS col_12,
                      SUM(cur_sum) AS col_13,
                      null AS col_14,

                      COUNT(DISTINCT active_cur_scp3) AS col_15,
                      null AS col_16,
                      COUNT(DISTINCT CASE WHEN is_invalid = 1 THEN active_cur_scp3 END) AS col_17,
                      COUNT(DISTINCT CASE WHEN is_pilg = 1 THEN active_cur_scp3 END) AS col_18,
                      COUNT(DISTINCT CASE WHEN is_pilg = 0 and is_invalid = 0 and is_vpo = 0 THEN active_cur_scp3 END) AS col_19,
                      SUM(cur_pfu_sum) AS col_20,
                      MIN(cur_pfu_sum) AS col_21,
                      MAX(cur_pfu_sum) AS col_22,
                      case when nvl(COUNT(DISTINCT active_cur_scp3), 0) != 0 then
                        ROUND(SUM(cur_pfu_sum) / COUNT(DISTINCT active_cur_scp3), 2)
                      end AS col_23,

                      COUNT(DISTINCT schh_24) AS col_24,
                      COUNT(DISTINCT CASE WHEN is_vpo = 1 THEN schh_24 END) AS col_25,
                      COUNT(DISTINCT CASE WHEN is_n215 = 1 THEN schh_26 END) as col_26,
                      sum(case when is_n215 = 1 THEN cur_sum END) AS col_27
                 FROM (
                     select
                            --row_number() over(order by nlssort(Sca_Region, 'NLS_SORT=ukrainian')) rn,
                            Sca_Region,
                            sca_id,
                            schh_sc,
                            SUM(total_sum) AS total_sum_by_schh,
                            MAX(case when scp3_year = d.yyyy AND cnt > 0 then active_sch end) AS active_schh1,
                            MAX(active_sch) AS active_schh,
                            MAX(case when cnt > 0 then active_cur_sch end) AS active_cur_schh,
                            MAX(active_cur_scp3) AS active_cur_scp3,
                            MAX(cur_month_sch) AS cur_month_schh,
                            MAX(schh_24) AS schh_24,
                            MAX(schh_26) AS schh_26,

                            SUM(CASE WHEN scp3_year = d.yyyy AND cnt > 0 THEN sm END) AS cur_sum,
                            SUM(CASE WHEN scp3_year = d.yyyy THEN cnt END) AS cur_cnt,
                            SUM(CASE WHEN TRUNC(scpp_pfu_pd_dt, 'MM') = d.dt AND cnt > 0 THEN sm END) AS cur_pfu_sum,


                            max(CASE WHEN nppt_code in ('21501', '21502') THEN 1 else 0 END) AS is_n215,
                           -- max(CASE WHEN nppt_code not in ('21501', '21502') THEN 1 else 0 END) AS is_not_n215,
                            CASE WHEN f.scf_is_migrant = 'T' THEN 1 else 0 END AS is_vpo,
                            CASE WHEN
                              (SELECT COUNT(*)
                                 FROM uss_person.v_Sc_Scpp_Family pf
                                 JOIN uss_person.v_sc_feature zf ON (zf.scf_sc = pf.scpf_sc)
                                WHERE pf.scpf_scpp = scpp_id
                                  AND pf.scpf_sc = schh_sc
                                  AND zf.scf_is_dasabled = 'T'
                              ) > 0 THEN 1 else 0
                            END AS is_invalid,
                            CASE WHEN
                              (SELECT COUNT(*)
                                 FROM uss_person.v_Sc_Scpp_Family pf
                                 JOIN uss_person.v_sc_feature zf ON (zf.scf_sc = pf.scpf_sc)
                                WHERE pf.scpf_scpp = scpp_id
                                  AND pf.scpf_sc = schh_sc
                                  AND (zf.scf_is_singl_parent = 'T' OR zf.scf_is_large_family = 'T' OR zf.scf_is_low_income = 'T')
                              ) > 0 THEN 1 else 0
                            END AS is_pilg
                       from
                           (select pr.org_name as Sca_Region, pps.scpp_id, nppt.nppt_code, sca_id, sch.schh_sc,
                                   scp3_year,
                                   scpp_pfu_pd_dt,
                                   case d.mm
                                     when 1  then p3.scp3_sum_m1
                                     when 2  then p3.scp3_sum_m2
                                     when 3  then p3.scp3_sum_m3
                                     when 4  then p3.scp3_sum_m4
                                     when 5  then p3.scp3_sum_m5
                                     when 6  then p3.scp3_sum_m6
                                     when 7  then p3.scp3_sum_m7
                                     when 8  then p3.scp3_sum_m8
                                     when 9  then p3.scp3_sum_m9
                                     when 10 then p3.scp3_sum_m10
                                     when 11 then p3.scp3_sum_m11
                                     when 12 then p3.scp3_sum_m12
                                     else 0
                                   end sm,
                                   case
                                     when d.mm =  1 and p3.scp3_sum_m1 > 0 then 1
                                     when d.mm =  2 and p3.scp3_sum_m2 > 0 then 1
                                     when d.mm =  3 and p3.scp3_sum_m3 > 0 then 1
                                     when d.mm =  4 and p3.scp3_sum_m4 > 0 then 1
                                     when d.mm =  5 and p3.scp3_sum_m5 > 0 then 1
                                     when d.mm =  6 and p3.scp3_sum_m6 > 0 then 1
                                     when d.mm =  7 and p3.scp3_sum_m7 > 0 then 1
                                     when d.mm =  8 and p3.scp3_sum_m8 > 0 then 1
                                     when d.mm =  9 and p3.scp3_sum_m9 > 0 then 1
                                     when d.mm = 10 and p3.scp3_sum_m10 > 0 then 1
                                     when d.mm = 11 and p3.scp3_sum_m11 > 0 then 1
                                     when d.mm = 12 and p3.scp3_sum_m12 > 0 then 1
                                     else 0
                                   end cnt,

                                   CASE WHEN pps.scpp_pfu_pd_st NOT IN ('PS', 'V') AND d.dt < pps.scpp_pfu_pd_stop_dt THEN sca_id END AS active_sch,
                                   CASE WHEN pps.scpp_pfu_pd_st NOT IN ('PS', 'V') AND d.dt BETWEEN pps.scpp_pfu_pd_start_dt AND pps.scpp_pfu_pd_stop_dt THEN sca_id END AS active_cur_sch,
                                   CASE WHEN pps.scpp_pfu_pd_st NOT IN ('PS', 'V') AND TRUNC(pps.scpp_pfu_pd_dt, 'MM') = d.dt THEN scp3_id END AS active_cur_scp3,
                                   CASE WHEN TRUNC(pps.scpp_pfu_pd_dt, 'MM') = d.dt THEN sca_id END AS cur_month_sch,
                                   nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) + nvl(p3.scp3_sum_m9, 0) + nvl(p3.scp3_sum_m10, 0) + nvl(p3.scp3_sum_m11, 0) + nvl(p3.scp3_sum_m12, 0) AS total_sum,

                                   CASE WHEN pps.scpp_pfu_pd_st IN ('V') AND d.dt BETWEEN pps.scpp_pfu_pd_start_dt AND pps.scpp_pfu_pd_stop_dt THEN sca_id END AS schh_24,
                                   CASE WHEN pps.scpp_pfu_pd_st IN ('S') AND d.dt BETWEEN pps.scpp_pfu_pd_start_dt AND pps.scpp_pfu_pd_stop_dt THEN sca_id END AS schh_26
                                   --CASE WHEN pps.scpp_pfu_pd_st IN ('S') AND d.dt BETWEEN pps.scpp_pfu_pd_start_dt AND pps.scpp_pfu_pd_stop_dt THEN scp3_id END AS scp3_27
                              from d,
                                   uss_person.v_sc_pfu_pay_period p3,
                                   uss_person.v_sc_pfu_pay_summary pps,
                                   uss_person.v_sc_household sch,
                                   uss_person.v_Sc_Address sca,
                                   uss_ndi.v_ndi_pfu_payment_type nppt,
                                   uss_ndi.v_ndi_org2kaot k,
                                   v_opfu pr,
                                   v_opfu po
                             where 1 = 1
                               and pps.scpp_id = p3.scp3_scpp
                               and pps.scpp_pfu_payment_tp = 'SUBSIDY'
                               and sch.schh_id = pps.scpp_schh
                               --and sca.sca_id = sch.schh_sca
                               and sca.sca_sc = p3.scp3_sc
                               and sca.sca_tp = '5'
                               and sca.history_status = 'A'
                               and nppt.nppt_id(+) = p3.scp3_nppt
                               and d.dt between pps.scpp_pfu_pd_start_dt and pps.scpp_pfu_pd_stop_dt
                               and nppt.nppt_id not in (13000, 14000)AND k.nok_kaot = sca.sca_kaot
                               and k.history_status = 'A'
                               and nppt.nppt_id = p3.scp3_nppt
                               --and d.dt between nvl(k.nk2o_start_dt, d.dt)
                               --AND nvl(k.nk2o_stop_dt, d.dt)
                               AND pr.org_id = k.nok_org
                               AND po.org_id = decode(pr.org_to, 32, pr.org_org, pr.org_id)
                               AND ]' || CASE WHEN l_org_to = 31 THEN ' po.org_id = ' || p_org_id  ELSE ' pr.org_id = ' || p_org_id  END || '
                           ) t
                       JOIN d ON (1 = 1)
                       left JOIN uss_person.v_sc_feature f ON (f.scf_sc = t.schh_sc)
                       group by Sca_Region, scpp_id, sca_id, schh_sc, f.scf_is_migrant
                  )
                  group by Sca_Region
              )
             select rn,
                    col_2,--    "назва області",
                    col_3,
                    col_4,
                    col_5,
                    col_6,
                    col_7,
                    col_8,
                    col_9,
                    col_10,
                    col_11,
                    col_12,
                    col_13/1000 as col_13,
                    col_14,
                    col_15,
                    col_16,
                    col_17,
                    col_18,
                    col_19,
                    col_20/1000 as  col_20,
                    col_21,
                    col_22,
                    col_23,
                    col_24,
                    col_25,
                    col_26,
                    col_27/1000 as  col_27
               from
                    (select rn rn,
                            initcap(col_2) as col_2, --    "назва області",
                            col_3,
                            col_4,
                            col_5,
                            col_6,
                            col_7,
                            col_8,
                            col_9,
                            col_10,
                            col_11,
                            col_12,
                            col_13,
                            col_14,
                            col_15,
                            col_16,
                            col_17,
                            col_18,
                            col_19,
                            col_20,
                            col_21,
                            col_22,
                            col_23,
                            col_24,
                            col_25,
                            col_26,
                            col_27
                       from t
                    ), d
            order by rn
        ';*/

        l_sql :=
               q'[
       WITH     d as (select :p_date dt, extract(YEAR from :p_date) yyyy, extract(MONTH from :p_date) mm from dual),
         t as
          (SELECT row_number() over(order by DECODE(Sca_Region, 'невизначено або відсутні дані', 9999, 0), nlssort(Sca_Region, 'NLS_SORT=ukrainian')) rn,
                  Sca_Region AS col_2,
                  COUNT(DISTINCT active_schh) AS col_3,
                  COUNT(DISTINCT CASE WHEN total_sum_by_schh != 0 THEN active_schh END) AS col_4,
                  COUNT(DISTINCT CASE WHEN total_sum_by_schh = 0 THEN active_schh END) AS col_5,

                  case when nvl(COUNT(DISTINCT active_schh), 0) != 0 then
                    ROUND(SUM(cur_sum) / COUNT(DISTINCT active_schh), 2)
                  end AS col_6,
                  case when nvl(COUNT(DISTINCT CASE WHEN total_sum_by_schh != 0 THEN active_schh END), 0) != 0 then
                     ROUND(SUM(cur_sum) / COUNT(DISTINCT CASE WHEN total_sum_by_schh != 0 THEN active_schh END), 2)
                  end AS col_7,

                  COUNT(DISTINCT active_cur_schh) AS col_8,
                  null/*COUNT(DISTINCT CASE WHEN is_vpo = 1 THEN active_cur_schh END)*/ AS col_9,
                  null/*COUNT(DISTINCT CASE WHEN is_pilg = 1 THEN active_cur_schh END)*/ AS col_10,
                  null/*COUNT(DISTINCT CASE WHEN is_invalid = 1 THEN active_cur_schh END)*/ AS col_11,
                  null/*COUNT(DISTINCT CASE WHEN is_pilg = 0 and is_invalid = 0 and is_vpo = 0 THEN active_cur_schh END)*/ AS col_12,
                  SUM(cur_sum) AS col_13,
                  null/*COUNT(DISTINCT cur_month_schh)*/ AS col_14,

                  COUNT(DISTINCT active_cur_scp3) AS col_15,
                  null/*COUNT(DISTINCT CASE WHEN is_vpo = 1 THEN active_cur_scp3 END)*/ AS col_16,
                  null/*COUNT(DISTINCT CASE WHEN is_pilg = 1 THEN active_cur_scp3 END)*/ AS col_17,
                  null/*COUNT(DISTINCT CASE WHEN is_invalid = 1 THEN active_cur_scp3 END)*/ AS col_18,
                  null/*COUNT(DISTINCT CASE WHEN is_pilg = 0 and is_invalid = 0 and is_vpo = 0 THEN active_cur_scp3 END)*/ AS col_19,
                  SUM(cur_pfu_sum) AS col_20,
                  MIN(cur_pfu_sum) AS col_21,
                  MAX(cur_pfu_sum) AS col_22,
                  case when nvl(COUNT(DISTINCT active_cur_scp3), 0) != 0 then
                    ROUND(SUM(cur_pfu_sum) / COUNT(DISTINCT active_cur_scp3), 2)
                  end AS col_23,

                  null/*COUNT(DISTINCT schh_24)*/ AS col_24,
                  null/*COUNT(DISTINCT CASE WHEN is_vpo = 1 THEN schh_24 END)*/ AS col_25,
                  COUNT(DISTINCT CASE WHEN is_n215 = 1 THEN schh_26 END) as col_26,
                  sum(case when is_n215 = 1 THEN cur_sum END) AS col_27
             FROM (
                 select
                        --row_number() over(order by DECODE(Sca_Region, 'невизначено або відсутні дані', 9999, 0), nlssort(Sca_Region, 'NLS_SORT=ukrainian')) rn,
                        Sca_Region,
                        sca_id,
                        schh_sc,
                        SUM(total_sum) AS total_sum_by_schh,
                        MAX(case when scp3_year = d.yyyy AND cnt > 0 then active_sch end) AS active_schh,
                        MAX(case when scp3_year = d.yyyy AND cnt > 0 then active_cur_sch end) AS active_cur_schh,
                        MAX(active_cur_scp3) AS active_cur_scp3,
                        MAX(cur_month_sch) AS cur_month_schh,
                        MAX(schh_24) AS schh_24,
                        MAX(schh_26) AS schh_26,

                        SUM(CASE WHEN scp3_year = d.yyyy AND cnt > 0 THEN sm END) AS cur_sum,
                        SUM(CASE WHEN scp3_year = d.yyyy THEN cnt END) AS cur_cnt,
                        SUM(CASE WHEN TRUNC(scpp_pfu_pd_dt, 'MM') = d.dt AND cnt > 0 THEN sm END) AS cur_pfu_sum,


                        max(CASE WHEN nppt_code in ('21501', '21502') THEN 1 else 0 END) AS is_n215,
                       -- max(CASE WHEN nppt_code not in ('21501', '21502') THEN 1 else 0 END) AS is_not_n215,
                        CASE WHEN f.scf_is_migrant = 'T' THEN 1 else 0 END AS is_vpo,
                        CASE WHEN
                          (SELECT COUNT(*)
                             FROM uss_person.v_Sc_Scpp_Family pf
                             JOIN uss_person.v_sc_feature zf ON (zf.scf_sc = pf.scpf_sc)
                            WHERE pf.scpf_scpp = scpp_id
                              AND pf.scpf_sc_main = schh_sc
                              AND zf.scf_is_dasabled = 'T'
                          ) > 0 THEN 1 else 0
                        END AS is_invalid,
                        CASE WHEN
                          (SELECT COUNT(*)
                             FROM uss_person.v_Sc_Scpp_Family pf
                             JOIN uss_person.v_sc_feature zf ON (zf.scf_sc = pf.scpf_sc)
                            WHERE pf.scpf_scpp = scpp_id
                              AND pf.scpf_sc_main = schh_sc
                              AND (zf.scf_is_singl_parent = 'T' OR zf.scf_is_large_family = 'T' OR zf.scf_is_low_income = 'T')
                          ) > 0 THEN 1 else 0
                        END AS is_pilg,
                        /*CASE WHEN
                          (SELECT COUNT(*)
                             FROM uss_person.v_Sc_Scpp_Family pf
                             JOIN uss_person.v_SC_INCOME_LINK zl ON (zl.sil_sc = pf.scpf_sc)
                            WHERE pf.scpf_scpp = scpp_id
                              AND pf.scpf_sc_main = schh_sc
                              and zl.sil_pay_dt = d.dt
                              and zl.sil_sum > 0
                              and zl.sil_inc not in (4, 9, 10, 26)
                          ) > 0 THEN 1 else 0
                        END*/0 AS is_other_pay
                   from
                       (select nvl(kd.kaot_full_name, 'невизначено або відсутні дані') as Sca_Region, pps.scpp_id, nppt.nppt_code, sca_id, sch.schh_sc,
                               scp3_year,
                               scpp_pfu_pd_dt,
                               case d.mm
                                 when 1  then p3.scp3_sum_m1
                                 when 2  then p3.scp3_sum_m2
                                 when 3  then p3.scp3_sum_m3
                                 when 4  then p3.scp3_sum_m4
                                 when 5  then p3.scp3_sum_m5
                                 when 6  then p3.scp3_sum_m6
                                 when 7  then p3.scp3_sum_m7
                                 when 8  then p3.scp3_sum_m8
                                 when 9  then p3.scp3_sum_m9
                                 when 10 then p3.scp3_sum_m10
                                 when 11 then p3.scp3_sum_m11
                                 when 12 then p3.scp3_sum_m12
                                 else 0
                               end sm, -- поточна сума
                               case
                                 when d.mm =  1 and p3.scp3_sum_m1 > 0 then 1
                                 when d.mm =  2 and p3.scp3_sum_m2 > 0 then 1
                                 when d.mm =  3 and p3.scp3_sum_m3 > 0 then 1
                                 when d.mm =  4 and p3.scp3_sum_m4 > 0 then 1
                                 when d.mm =  5 and p3.scp3_sum_m5 > 0 then 1
                                 when d.mm =  6 and p3.scp3_sum_m6 > 0 then 1
                                 when d.mm =  7 and p3.scp3_sum_m7 > 0 then 1
                                 when d.mm =  8 and p3.scp3_sum_m8 > 0 then 1
                                 when d.mm =  9 and p3.scp3_sum_m9 > 0 then 1
                                 when d.mm = 10 and p3.scp3_sum_m10 > 0 then 1
                                 when d.mm = 11 and p3.scp3_sum_m11 > 0 then 1
                                 when d.mm = 12 and p3.scp3_sum_m12 > 0 then 1
                                 else 0
                               end cnt, -- ознака чи була виплата в поточному місяці

                               CASE WHEN pps.scpp_pfu_pd_st NOT IN ('PS', 'V') AND d.dt <= pps.scpp_pfu_pd_stop_dt THEN sca_id END AS active_sch,
                               CASE WHEN pps.scpp_pfu_pd_st NOT IN ('PS', 'V') AND d.dt BETWEEN pps.scpp_pfu_pd_start_dt AND pps.scpp_pfu_pd_stop_dt THEN sca_id END AS active_cur_sch,
                               CASE WHEN pps.scpp_pfu_pd_st NOT IN ('PS', 'V') AND TRUNC(pps.scpp_pfu_pd_dt, 'MM') = d.dt THEN scp3_id END AS active_cur_scp3,
                               CASE WHEN TRUNC(pps.scpp_pfu_pd_dt, 'MM') = d.dt THEN sca_id END AS cur_month_sch,
                               nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) + nvl(p3.scp3_sum_m9, 0) + nvl(p3.scp3_sum_m10, 0) + nvl(p3.scp3_sum_m11, 0) + nvl(p3.scp3_sum_m12, 0) AS total_sum,

                               CASE WHEN pps.scpp_pfu_pd_st IN ('V') AND d.dt BETWEEN pps.scpp_pfu_pd_start_dt AND pps.scpp_pfu_pd_stop_dt THEN sca_id END AS schh_24,
                               CASE WHEN pps.scpp_pfu_pd_st IN ('S') AND d.dt BETWEEN pps.scpp_pfu_pd_start_dt AND pps.scpp_pfu_pd_stop_dt THEN sca_id END AS schh_26
                               --CASE WHEN pps.scpp_pfu_pd_st IN ('S') AND d.dt BETWEEN pps.scpp_pfu_pd_start_dt AND pps.scpp_pfu_pd_stop_dt THEN scp3_id END AS scp3_27
                          from d,
                               uss_person.v_sc_pfu_pay_period p3,
                               uss_person.v_sc_pfu_pay_summary pps,
                               uss_person.v_sc_household sch,
                               uss_person.v_Sc_Address sca,
                               uss_ndi.v_ndi_pfu_payment_type nppt,
                               uss_ndi.v_ndi_katottg k,
                               uss_ndi.v_ndi_katottg km,
                               uss_ndi.v_ndi_katottg kd
                         where 1 = 1
                           and pps.scpp_id = p3.scp3_scpp
                           and pps.scpp_pfu_payment_tp = 'SUBSIDY'
                           and sch.schh_id = pps.scpp_schh
                           --and sca.sca_id = sch.schh_sca
                           and sca.sca_sc = p3.scp3_sc
                           and sca.sca_tp = '5'
                           and sca.history_status = 'A'
                           and k.kaot_id = sca.sca_kaot
                           and km.kaot_id = k.kaot_kaot_l]'
            || l_level
            || ' /*КАОТ ФІЛЬТРУЮЧИЙ*/
                           and kd.kaot_id(+) = k.kaot_kaot_l'
            || l_level_data
            ||                                       /*КАОТ ДЛЯ ВІДОБРАЖЕННЯ*/
               CASE
                   WHEN p_kaot_id IS NOT NULL AND p_kaot_id != 0
                   THEN
                       ' and km.kaot_id = ' || p_kaot_id
               END
            || '
                           and nppt.nppt_id(+) = p3.scp3_nppt
                           and d.dt between pps.scpp_pfu_pd_start_dt and pps.scpp_pfu_pd_stop_dt
                           and nppt.nppt_id not in (13000, 14000)
                           and pps.scpp_pfu_pd_st NOT IN (''PS'', ''V'')
                       ) t
                   JOIN d ON (1 = 1)
                   left JOIN uss_person.v_sc_feature f ON (f.scf_sc = t.schh_sc)
                   group by Sca_Region, scpp_id, sca_id, schh_sc, f.scf_is_migrant
              )
              group by Sca_Region
          )
         select rn,
                col_2,                           -- Назва адміністративно-територіальної одиниці
                col_3,                           -- Кількість діючих субсидій на оплату ЖКП, всього (домогосподарств)
                col_4,                           -- субсидія у розмірі, що більше "0" (у тому числі кількість домогосподарств (з числа призначених у стовпчику 3), яким призначена)
                col_5,                           -- субсидія у розмірі "0"
                col_6,                           -- Середній розмір субсидії у звітному місяці із зазначених в стовпчику 3, грн
                col_7,                           -- Середній розмір субсидії у звітному місяці із зазначених в стовпчику 4, грн
                col_8,                           -- Кількість домогосподарств, яким нараховано субсидію у звітному місяці
                col_9,                           -- ВПО (у тому числі (з числа зазначених у стовпчику 8))
                col_10,                          -- у складі домогосподарства є особи, що мають право на пільги
                col_11,                          -- у складі домогосподарства є особи, що мають інвалідність
                col_12,                          -- у складі домогосподарства є особи, що отримають інші види соціальних виплат (крім зазначених в стовпчиках 9,10,11)
                col_13/1000 as col_13,           -- Сума нарахованих субсидій домогосподарствам, зазначеним в стовпчику 8, тис.грн
                col_14,                          -- Кількість домогосподарств, які звернулися за призначенням субсидії на оплату житлово-комунальних послуг в звітному місяці
                col_15,                          -- Кількість діючих субсидій, всього (домогосподарств), призначених у звітному місяці
                col_16,                          -- ВПО (у тому числі (з числа зазначених у стовпчику 15))
                col_17,                          -- у складі домогосподарства є особи, що мають право на пільги
                col_18,                          -- у складі домогосподарства є особи, що мають інвалідність
                col_19,                          -- у складі домогосподарства є особи, що отримають інші види соціальних виплат (крім зазначених в стовпчиках 16, 17, 18)
                col_20/1000 as  col_20,          -- загальна сума призначених в звітному місяці субсидій на оплату ЖКП (зазначених у стовпчику 15), тис.грн
                col_21,                          -- мінімальний розмір призначеної субсидії, грн
                col_22,                          -- максимальний розмір призначеної субсидії, грн
                col_23,                          -- середній розмір призначеної субсидії
                col_24,                          -- Кількість відмов в призначенні житлової субсидії в поточному місяці
                col_25,                          -- У тому числі ВПО (з числа зазначених у стовпчику 24)
                col_26,                          -- Кількість домогосподарств, яким житлова субсидія надається централізовано по ПКМУ від 07.03.2022 №215
                col_27/1000 as  col_27           -- Сума нарахованих субсидій по ПКМУ від 07.03.2022 №215 в звітному місяці, тис.грн
           from
                (select rn+1 rn,
                        col_2, --    "назва області",
                        col_3,
                        col_4,
                        col_5,
                        col_6,
                        col_7,
                        col_8,
                        col_9,
                        col_10,
                        col_11,
                        col_12,
                        col_13,
                        col_14,
                        col_15,
                        col_16,
                        col_17,
                        col_18,
                        col_19,
                        col_20,
                        col_21,
                        col_22,
                        col_23,
                        col_24,
                        col_25,
                        col_26,
                        col_27
                   from t
                 union all
                 select 1 rn,
                        '''
            || l_level_name
            || ''',
                        sum(col_3),
                        sum(col_4),
                        sum(col_5),
                        case when sum(col_3) is null or sum(col_3) = 0 then null else ROUND(sum(col_13) / sum(col_3), 2) end,
                        case when sum(col_4) is null or sum(col_4) = 0 then null else ROUND(sum(col_13) / sum(col_4), 2) end,
                        sum(col_8),
                        sum(col_9),
                        sum(col_10),
                        sum(col_11),
                        sum(col_12),
                        sum(col_13),
                        sum(col_14),
                        sum(col_15),
                        sum(col_16),
                        sum(col_17),
                        sum(col_18),
                        sum(col_19),
                        sum(col_20),
                        MIN(col_21),
                        MAX(col_22),
                        case when sum(col_15) is null or sum(col_15) = 0 then null else ROUND(sum(col_20) / sum(col_15), 2) end,
                        sum(col_24),
                        sum(col_25),
                        sum(col_26),
                        sum(col_27)
                   from t
                ), d
        order by rn
    ';

        --підставити параметр
        /*IF (p_org_id IS NULL OR p_org_id = 0) THEN
          l_sql:= replace(l_sql, ':p_date', q'[to_date(']'||to_char(l_date, 'dd.mm.yyyy')||q'[', 'dd.mm.yyyy')]');
          RDM$RTFL.AddDataSet(l_jbr_id, 'ds', l_sql);
        ELSE
          l_sql_obl := replace(l_sql_obl, ':p_date', q'[to_date(']'||to_char(l_date, 'dd.mm.yyyy')||q'[', 'dd.mm.yyyy')]');
          RDM$RTFL.AddDataSet(l_jbr_id, 'ds', l_sql_obl);
        END IF;*/

        l_sql :=
            REPLACE (
                l_sql,
                ':p_date',
                   q'[to_date(']'
                || TO_CHAR (l_date, 'dd.mm.yyyy')
                || q'[', 'dd.mm.yyyy')]');
        RDM$RTFL.AddDataSet (l_jbr_id, 'ds', l_sql);

        RDM$RTFL.PutReportToWorkingQueue (p_jbr_id => l_jbr_id);
        RETURN l_jbr_id;
    END;

    -- #92273: Інформація про надання субсидії на придбання твердого палива і скрапленого газу станом на
    FUNCTION SUBSIDY_INFO_R2 (p_start_dt   IN DATE,
                              p_rt_id      IN rpt_templates.rt_id%TYPE,
                              p_kaot_id    IN NUMBER)
        RETURN DECIMAL
    IS
        l_jbr_id       NUMBER;
        l_date         DATE := TRUNC (p_start_dt, 'mm');
        l_sql          VARCHAR2 (32000);
        --l_sql_obl    varchar2(32000);
        --l_org_to NUMBER;
        l_level        NUMBER;
        l_level_data   NUMBER;
        l_level_name   VARCHAR2 (500);
    BEGIN
        l_jbr_id :=
            RDM$RTFL.InitReport (p_rt_id      => p_rt_id,
                                 p_rpt_name   => 'Субсидії_СГТП_призначення');
        RDM$RTFL.AddParam (l_jbr_id,
                           'p_date',
                           TO_CHAR (ADD_MONTHS (l_date, 1), 'dd.mm.yyyy'));
        RDM$RTFL.AddParam (l_jbr_id,
                           'gen_dt',
                           TO_CHAR (SYSDATE, 'dd.mm.yyyy'));
        rdm$rtfl.SetFileName (
            l_jbr_id,
               'Субсидії_СГТП_призначення'
            || '_'
            || TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS')
            || '.XLS');

        get_kaot_info (p_kaot_id,
                       l_level,
                       l_level_data,
                       l_level_name);
        /* SELECT MAX(org_to)
           INTO l_org_to
           FROM v_opfu t
           WHERE org_id = p_org_id;
         l_sql:= q'[
            WITH     d as (select :p_date dt, extract(YEAR from :p_date) yyyy, extract(MONTH from :p_date) mm from dual),
              t as
               (SELECT row_number() over(order by nlssort(Sca_Region, 'NLS_SORT=ukrainian')) rn,
                       Sca_Region AS col_2,
                       COUNT(DISTINCT sca_id) AS col_3,
                       null AS col_4,
                       SUM(sum_from_begin) AS col_5,
                       SUM(sum_cur) AS col_6,
                       COUNT(DISTINCT CASE WHEN cnt_from_begin > 0 THEN sca_id END) AS col_7,
                       COUNT(DISTINCT CASE WHEN cnt_cur > 0 THEN sca_id END) AS col_8,
                       case when nvl(COUNT(DISTINCT CASE WHEN cnt_from_begin > 0 THEN sca_id END), 0) != 0 then
                          SUM(sum_from_begin) / COUNT(DISTINCT CASE WHEN cnt_from_begin > 0 THEN sca_id END)
                       end AS col_9,
                       null AS col_10,
                       null AS col_11,
                       COUNT(DISTINCT cur_month_sch) AS col_12,
                       null AS col_13,
                       NULL AS col_14
                  FROM (select sca.Sca_Region, pps.scpp_id, nppt.nppt_code, sca_id, sch.schh_sc,
                               scp3_year,
                               case d.mm
                                  when 1 then nvl(p3.scp3_sum_m1, 0)
                                  when 2 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0)
                                  when 3 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0)
                                  when 4 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0)
                                  when 5 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0)
                                  when 6 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0)
                                  when 7 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0)
                                  when 8 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0)
                                  when 9 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) + nvl(p3.scp3_sum_m9, 0)
                                  when 10 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) + nvl(p3.scp3_sum_m9, 0) + nvl(p3.scp3_sum_m10, 0)
                                  when 11 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) + nvl(p3.scp3_sum_m9, 0) + nvl(p3.scp3_sum_m10, 0) + nvl(p3.scp3_sum_m11, 0)
                                  when 12 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) + nvl(p3.scp3_sum_m9, 0) + nvl(p3.scp3_sum_m10, 0) + nvl(p3.scp3_sum_m11, 0) + nvl(p3.scp3_sum_m12, 0)
                                  else 0
                              end sum_from_begin,
                              case
                                  when d.mm = 1 AND nvl(p3.scp3_sum_m1, 0) > 0 then 1
                                  when d.mm = 2 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) > 0 then 1
                                  when d.mm = 3 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) > 0 then 1
                                  when d.mm = 4 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) > 0 then 1
                                  when d.mm = 5 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) > 0 then 1
                                  when d.mm = 6 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) > 0 then 1
                                  when d.mm = 7 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) > 0 then 1
                                  when d.mm = 8 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) > 0 then 1
                                  when d.mm = 9 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) + nvl(p3.scp3_sum_m9, 0) > 0 then 1
                                  when d.mm = 10 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) + nvl(p3.scp3_sum_m9, 0) + nvl(p3.scp3_sum_m10, 0) > 0 then 1
                                  when d.mm = 11 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) + nvl(p3.scp3_sum_m9, 0) + nvl(p3.scp3_sum_m10, 0) + nvl(p3.scp3_sum_m11, 0) > 0 then 1
                                  when d.mm = 12 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) + nvl(p3.scp3_sum_m9, 0) + nvl(p3.scp3_sum_m10, 0) + nvl(p3.scp3_sum_m11, 0) + nvl(p3.scp3_sum_m12, 0) > 0 then 1
                                 else 0
                              end cnt_from_begin,
                              case d.mm
                                when 1  then p3.scp3_sum_m1
                                when 2  then p3.scp3_sum_m2
                                when 3  then p3.scp3_sum_m3
                                when 4  then p3.scp3_sum_m4
                                when 5  then p3.scp3_sum_m5
                                when 6  then p3.scp3_sum_m6
                                when 7  then p3.scp3_sum_m7
                                when 8  then p3.scp3_sum_m8
                                when 9  then p3.scp3_sum_m9
                                when 10 then p3.scp3_sum_m10
                                when 11 then p3.scp3_sum_m11
                                when 12 then p3.scp3_sum_m12
                                else 0
                              end sum_cur,
                              case
                                when d.mm =  1 and p3.scp3_sum_m1 > 0 then 1
                                when d.mm =  2 and p3.scp3_sum_m2 > 0 then 1
                                when d.mm =  3 and p3.scp3_sum_m3 > 0 then 1
                                when d.mm =  4 and p3.scp3_sum_m4 > 0 then 1
                                when d.mm =  5 and p3.scp3_sum_m5 > 0 then 1
                                when d.mm =  6 and p3.scp3_sum_m6 > 0 then 1
                                when d.mm =  7 and p3.scp3_sum_m7 > 0 then 1
                                when d.mm =  8 and p3.scp3_sum_m8 > 0 then 1
                                when d.mm =  9 and p3.scp3_sum_m9 > 0 then 1
                                when d.mm = 10 and p3.scp3_sum_m10 > 0 then 1
                                when d.mm = 11 and p3.scp3_sum_m11 > 0 then 1
                                when d.mm = 12 and p3.scp3_sum_m12 > 0 then 1
                                else 0
                              end cnt_cur,
                              CASE WHEN TRUNC(pps.scpp_pfu_pd_dt, 'MM') = d.dt THEN sca_id END AS cur_month_sch,
                              CASE WHEN f.scf_is_migrant = 'T' THEN 1 ELSE 0 END AS is_vpo
                         from d,
                              uss_person.v_sc_pfu_pay_period p3,
                              uss_person.v_sc_pfu_pay_summary pps,
                              uss_person.v_sc_household sch,
                              uss_person.v_Sc_Address sca,
                              uss_ndi.v_ndi_pfu_payment_type nppt,
                              uss_person.v_sc_feature f
                        where 1 = 1
                          and pps.scpp_id = p3.scp3_scpp
                          AND p3.scp3_year = d.yyyy
                          and pps.scpp_pfu_payment_tp = 'SUBSIDY'
                          and sch.schh_id = pps.scpp_schh
                          --and sca.sca_id = sch.schh_sca
                          and sca.sca_sc = p3.scp3_sc
                          and sca.sca_tp = '5'
                          and sca.history_status = 'A'
                          and nppt.nppt_id = p3.scp3_nppt
                          --AND nppt.nppt_id IN (13000, 14000)
                          and pps.scpp_pfu_pd_st not in ('PS', 'V')
                          and d.dt between pps.scpp_pfu_pd_start_dt and pps.scpp_pfu_pd_stop_dt
                          and nppt.nppt_id in (13000, 14000)
                          AND f.scf_sc = schh_sc
                      ) t
                   group by Sca_Region
               )

              select rn,
                     col_2,--    "назва області",
                     col_3,
                     col_4,
                     round(col_5/1000, 2) AS  col_5,
                     round(col_6/1000, 2) AS  col_6,
                     col_7,
                     col_8,
                     round(col_9, 2) as col_9,
                     col_10,
                     round(col_11/1000, 2) AS  col_11,
                     col_12,
                     col_13,
                     col_14
                from
                     (select rn+1 rn,
                             case when (lower(col_2)) = 'київ' then 'м. ' || initCap(col_2)
                                  when col_2 is not null then initCap(col_2) || ' обл.'
                             end as col_2,--    "назва області",
                             col_3,
                             col_4,
                             col_5,
                             col_6,
                             col_7,
                             col_8,
                             col_9,
                             col_10,
                             col_11,
                             col_12,
                             col_13,
                             col_14
                        from t
                      union all
                      select 1 rn,
                             'УКРАЇНА',
                             sum(col_3),
                             sum(col_4),
                             sum(col_5),
                             sum(col_6),
                             sum(col_7),
                             sum(col_8),
                             to_number(decode(sum(col_7), null, null, 0, null, round(sum(col_5)/sum(col_7), 2))),
                             sum(col_10),
                             sum(col_11),
                             sum(col_12),
                             sum(col_13),
                             sum(col_14)
                        from t
                     ), d
             order by rn
         ]';

         l_sql_obl:= q'[
            WITH     d as (select :p_date dt, extract(YEAR from :p_date) yyyy, extract(MONTH from :p_date) mm from dual),
              t as
               (SELECT row_number() over(order by nlssort(Sca_Region, 'NLS_SORT=ukrainian')) rn,
                       Sca_Region AS col_2,
                       COUNT(DISTINCT sca_id) AS col_3,
                       null AS col_4,
                       SUM(sum_from_begin) AS col_5,
                       SUM(sum_cur) AS col_6,
                       COUNT(DISTINCT CASE WHEN cnt_from_begin > 0 THEN sca_id END) AS col_7,
                       COUNT(DISTINCT CASE WHEN cnt_cur > 0 THEN sca_id END) AS col_8,
                       case when nvl(COUNT(DISTINCT CASE WHEN cnt_from_begin > 0 THEN sca_id END), 0) != 0 then
                          SUM(sum_from_begin) / COUNT(DISTINCT CASE WHEN cnt_from_begin > 0 THEN sca_id END)
                       end AS col_9,
                       null AS col_10,
                       null AS col_11,
                       COUNT(DISTINCT cur_month_sch) AS col_12,
                       null AS col_13,
                       NULL AS col_14
                  FROM (select pr.org_name as Sca_Region, pps.scpp_id, nppt.nppt_code, sca_id, sch.schh_sc,
                               scp3_year,
                               case d.mm
                                  when 1 then nvl(p3.scp3_sum_m1, 0)
                                  when 2 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0)
                                  when 3 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0)
                                  when 4 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0)
                                  when 5 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0)
                                  when 6 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0)
                                  when 7 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0)
                                  when 8 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0)
                                  when 9 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) + nvl(p3.scp3_sum_m9, 0)
                                  when 10 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) + nvl(p3.scp3_sum_m9, 0) + nvl(p3.scp3_sum_m10, 0)
                                  when 11 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) + nvl(p3.scp3_sum_m9, 0) + nvl(p3.scp3_sum_m10, 0) + nvl(p3.scp3_sum_m11, 0)
                                  when 12 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) + nvl(p3.scp3_sum_m9, 0) + nvl(p3.scp3_sum_m10, 0) + nvl(p3.scp3_sum_m11, 0) + nvl(p3.scp3_sum_m12, 0)
                                  else 0
                              end sum_from_begin,
                              case
                                  when d.mm = 1 AND nvl(p3.scp3_sum_m1, 0) > 0 then 1
                                  when d.mm = 2 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) > 0 then 1
                                  when d.mm = 3 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) > 0 then 1
                                  when d.mm = 4 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) > 0 then 1
                                  when d.mm = 5 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) > 0 then 1
                                  when d.mm = 6 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) > 0 then 1
                                  when d.mm = 7 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) > 0 then 1
                                  when d.mm = 8 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) > 0 then 1
                                  when d.mm = 9 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) + nvl(p3.scp3_sum_m9, 0) > 0 then 1
                                  when d.mm = 10 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) + nvl(p3.scp3_sum_m9, 0) + nvl(p3.scp3_sum_m10, 0) > 0 then 1
                                  when d.mm = 11 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) + nvl(p3.scp3_sum_m9, 0) + nvl(p3.scp3_sum_m10, 0) + nvl(p3.scp3_sum_m11, 0) > 0 then 1
                                  when d.mm = 12 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) + nvl(p3.scp3_sum_m9, 0) + nvl(p3.scp3_sum_m10, 0) + nvl(p3.scp3_sum_m11, 0) + nvl(p3.scp3_sum_m12, 0) > 0 then 1
                                 else 0
                              end cnt_from_begin,
                              case d.mm
                                when 1  then p3.scp3_sum_m1
                                when 2  then p3.scp3_sum_m2
                                when 3  then p3.scp3_sum_m3
                                when 4  then p3.scp3_sum_m4
                                when 5  then p3.scp3_sum_m5
                                when 6  then p3.scp3_sum_m6
                                when 7  then p3.scp3_sum_m7
                                when 8  then p3.scp3_sum_m8
                                when 9  then p3.scp3_sum_m9
                                when 10 then p3.scp3_sum_m10
                                when 11 then p3.scp3_sum_m11
                                when 12 then p3.scp3_sum_m12
                                else 0
                              end sum_cur,
                              case
                                when d.mm =  1 and p3.scp3_sum_m1 > 0 then 1
                                when d.mm =  2 and p3.scp3_sum_m2 > 0 then 1
                                when d.mm =  3 and p3.scp3_sum_m3 > 0 then 1
                                when d.mm =  4 and p3.scp3_sum_m4 > 0 then 1
                                when d.mm =  5 and p3.scp3_sum_m5 > 0 then 1
                                when d.mm =  6 and p3.scp3_sum_m6 > 0 then 1
                                when d.mm =  7 and p3.scp3_sum_m7 > 0 then 1
                                when d.mm =  8 and p3.scp3_sum_m8 > 0 then 1
                                when d.mm =  9 and p3.scp3_sum_m9 > 0 then 1
                                when d.mm = 10 and p3.scp3_sum_m10 > 0 then 1
                                when d.mm = 11 and p3.scp3_sum_m11 > 0 then 1
                                when d.mm = 12 and p3.scp3_sum_m12 > 0 then 1
                                else 0
                              end cnt_cur,
                              CASE WHEN TRUNC(pps.scpp_pfu_pd_dt, 'MM') = d.dt THEN sca_id END AS cur_month_sch,
                              CASE WHEN f.scf_is_migrant = 'T' THEN 1 ELSE 0 END AS is_vpo
                         from d,
                              uss_person.v_sc_pfu_pay_period p3,
                              uss_person.v_sc_pfu_pay_summary pps,
                              uss_person.v_sc_household sch,
                              uss_person.v_Sc_Address sca,
                              uss_ndi.v_ndi_pfu_payment_type nppt,
                              uss_person.v_sc_feature f,
                              uss_ndi.v_ndi_org2kaot k,
                              v_opfu pr,
                              v_opfu po
                        where 1 = 1
                          and pps.scpp_id = p3.scp3_scpp
                          AND p3.scp3_year = d.yyyy
                          and pps.scpp_pfu_payment_tp = 'SUBSIDY'
                          and sch.schh_id = pps.scpp_schh
                          --and sca.sca_id = sch.schh_sca
                          and sca.sca_sc = p3.scp3_sc
                          and sca.sca_tp = '5'
                          and sca.history_status = 'A'
                          and nppt.nppt_id = p3.scp3_nppt
                          --AND nppt.nppt_id IN (13000, 14000)
                          and pps.scpp_pfu_pd_st not in ('PS', 'V')
                          and d.dt between pps.scpp_pfu_pd_start_dt and pps.scpp_pfu_pd_stop_dt
                          and nppt.nppt_id in (13000, 14000)
                          AND f.scf_sc = schh_sc
                          AND k.nok_kaot = sca.sca_kaot
                          and k.history_status = 'A'
                          and nppt.nppt_id = p3.scp3_nppt
                          --and d.dt between nvl(k.nk2o_start_dt, d.dt) AND nvl(k.nk2o_stop_dt, d.dt)
                          AND pr.org_id = k.nok_org
                          AND po.org_id = decode(pr.org_to, 32, pr.org_org, pr.org_id)
                          AND ]' || CASE WHEN l_org_to = 31 THEN ' po.org_id = ' || p_org_id  ELSE ' pr.org_id = ' || p_org_id  END || '
                      ) t
                   group by Sca_Region
               )

              select rn,
                     col_2,--    "назва області",
                     col_3,
                     col_4,
                     round(col_5/1000, 2) AS  col_5,
                     round(col_6/1000, 2) AS  col_6,
                     col_7,
                     col_8,
                     round(col_9, 2) as col_9,
                     col_10,
                     round(col_11/1000, 2) AS  col_11,
                     col_12,
                     col_13,
                     col_14
                from
                     (select rn rn,
                             initcap(col_2) as col_2,--    "назва області",
                             col_3,
                             col_4,
                             col_5,
                             col_6,
                             col_7,
                             col_8,
                             col_9,
                             col_10,
                             col_11,
                             col_12,
                             col_13,
                             col_14
                        from t
                     ), d
             order by rn
         ';*/

        l_sql :=
               q'[
       WITH     d as (select :p_date dt, extract(YEAR from :p_date) yyyy, extract(MONTH from :p_date) mm from dual),
         t as
          (SELECT row_number() over(order by DECODE(Sca_Region, 'невизначено або відсутні дані', 9999, 0), nlssort(Sca_Region, 'NLS_SORT=ukrainian')) rn,
                  Sca_Region AS col_2,
                  COUNT(DISTINCT sca_id) AS col_3,
                  null/*COUNT(DISTINCT CASE WHEN is_vpo = 1 THEN sca_id END)*/ AS col_4,
                  SUM(CASE WHEN cnt_from_begin > 0 THEN sum_from_begin END) AS col_5,
                  SUM(CASE WHEN cnt_cur > 0 THEN sum_cur END) AS col_6,
                  COUNT(DISTINCT CASE WHEN cnt_from_begin > 0 THEN sca_id END) AS col_7,
                  COUNT(DISTINCT CASE WHEN cnt_cur > 0 THEN sca_id END) AS col_8,
                  /*case when nvl(COUNT(DISTINCT CASE WHEN cnt_from_begin > 0 THEN sca_id END), 0) != 0 then
                     SUM(sum_from_begin) / COUNT(DISTINCT CASE WHEN cnt_from_begin > 0 THEN sca_id END)
                  end AS col_9,*/
                  null/*COUNT(DISTINCT cur_month_sch)*/ AS col_10,
                  null/*COUNT(DISTINCT CASE WHEN cur_month_sch IS NOT NULL THEN sum_cur END)*/ AS col_11,
                  COUNT(DISTINCT cur_month_sch) AS col_12,
                  null/*COUNT(DISTINCT CASE WHEN is_vpo = 1 THEN cur_month_sch END)*/ AS col_13,
                  NULL AS col_14
             FROM (select nvl(kd.kaot_full_name, 'невизначено або відсутні дані') as Sca_Region, pps.scpp_id, nppt.nppt_code, sca_id, sch.schh_sc,
                          scp3_year,
                          case d.mm
                             when 1 then nvl(p3.scp3_sum_m1, 0)
                             when 2 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0)
                             when 3 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0)
                             when 4 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0)
                             when 5 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0)
                             when 6 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0)
                             when 7 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0)
                             when 8 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0)
                             when 9 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) + nvl(p3.scp3_sum_m9, 0)
                             when 10 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) + nvl(p3.scp3_sum_m9, 0) + nvl(p3.scp3_sum_m10, 0)
                             when 11 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) + nvl(p3.scp3_sum_m9, 0) + nvl(p3.scp3_sum_m10, 0) + nvl(p3.scp3_sum_m11, 0)
                             when 12 then nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) + nvl(p3.scp3_sum_m9, 0) + nvl(p3.scp3_sum_m10, 0) + nvl(p3.scp3_sum_m11, 0) + nvl(p3.scp3_sum_m12, 0)
                             else 0
                         end sum_from_begin,
                         case
                             when d.mm = 1 AND nvl(p3.scp3_sum_m1, 0) > 0 then 1
                             when d.mm = 2 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) > 0 then 1
                             when d.mm = 3 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) > 0 then 1
                             when d.mm = 4 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) > 0 then 1
                             when d.mm = 5 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) > 0 then 1
                             when d.mm = 6 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) > 0 then 1
                             when d.mm = 7 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) > 0 then 1
                             when d.mm = 8 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) > 0 then 1
                             when d.mm = 9 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) + nvl(p3.scp3_sum_m9, 0) > 0 then 1
                             when d.mm = 10 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) + nvl(p3.scp3_sum_m9, 0) + nvl(p3.scp3_sum_m10, 0) > 0 then 1
                             when d.mm = 11 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) + nvl(p3.scp3_sum_m9, 0) + nvl(p3.scp3_sum_m10, 0) + nvl(p3.scp3_sum_m11, 0) > 0 then 1
                             when d.mm = 12 AND nvl(p3.scp3_sum_m1, 0) + nvl(p3.scp3_sum_m2, 0) + nvl(p3.scp3_sum_m3, 0) + nvl(p3.scp3_sum_m4, 0) + nvl(p3.scp3_sum_m5, 0) + nvl(p3.scp3_sum_m6, 0) + nvl(p3.scp3_sum_m7, 0) + nvl(p3.scp3_sum_m8, 0) + nvl(p3.scp3_sum_m9, 0) + nvl(p3.scp3_sum_m10, 0) + nvl(p3.scp3_sum_m11, 0) + nvl(p3.scp3_sum_m12, 0) > 0 then 1
                            else 0
                         end cnt_from_begin,
                         case d.mm
                           when 1  then p3.scp3_sum_m1
                           when 2  then p3.scp3_sum_m2
                           when 3  then p3.scp3_sum_m3
                           when 4  then p3.scp3_sum_m4
                           when 5  then p3.scp3_sum_m5
                           when 6  then p3.scp3_sum_m6
                           when 7  then p3.scp3_sum_m7
                           when 8  then p3.scp3_sum_m8
                           when 9  then p3.scp3_sum_m9
                           when 10 then p3.scp3_sum_m10
                           when 11 then p3.scp3_sum_m11
                           when 12 then p3.scp3_sum_m12
                           else 0
                         end sum_cur,
                         case
                           when d.mm =  1 and p3.scp3_sum_m1 > 0 then 1
                           when d.mm =  2 and p3.scp3_sum_m2 > 0 then 1
                           when d.mm =  3 and p3.scp3_sum_m3 > 0 then 1
                           when d.mm =  4 and p3.scp3_sum_m4 > 0 then 1
                           when d.mm =  5 and p3.scp3_sum_m5 > 0 then 1
                           when d.mm =  6 and p3.scp3_sum_m6 > 0 then 1
                           when d.mm =  7 and p3.scp3_sum_m7 > 0 then 1
                           when d.mm =  8 and p3.scp3_sum_m8 > 0 then 1
                           when d.mm =  9 and p3.scp3_sum_m9 > 0 then 1
                           when d.mm = 10 and p3.scp3_sum_m10 > 0 then 1
                           when d.mm = 11 and p3.scp3_sum_m11 > 0 then 1
                           when d.mm = 12 and p3.scp3_sum_m12 > 0 then 1
                           else 0
                         end cnt_cur,
                         CASE WHEN TRUNC(pps.scpp_pfu_pd_dt, 'MM') = d.dt THEN sca_id END AS cur_month_sch,
                         CASE WHEN f.scf_is_migrant = 'T' THEN 1 ELSE 0 END AS is_vpo
                    from d,
                         uss_person.v_sc_pfu_pay_period p3,
                         uss_person.v_sc_pfu_pay_summary pps,
                         uss_person.v_sc_household sch,
                         uss_person.v_Sc_Address sca,
                         uss_ndi.v_ndi_pfu_payment_type nppt,
                         uss_person.v_sc_feature f,
                         uss_ndi.v_ndi_katottg k,
                         uss_ndi.v_ndi_katottg km,
                         uss_ndi.v_ndi_katottg kd
                   where 1 = 1
                     and pps.scpp_id = p3.scp3_scpp
                     AND p3.scp3_year = d.yyyy
                     and pps.scpp_pfu_payment_tp = 'SUBSIDY'
                     and sch.schh_id = pps.scpp_schh
                     --and sca.sca_id = sch.schh_sca
                     and sca.sca_sc = p3.scp3_sc
                     and sca.sca_tp = '5'
                     and sca.history_status = 'A'
                     and k.kaot_id = sca.sca_kaot
                     and km.kaot_id = k.kaot_kaot_l]'
            || l_level
            || '
                     and kd.kaot_id(+) = k.kaot_kaot_l'
            || l_level_data
            || CASE
                   WHEN p_kaot_id IS NOT NULL AND p_kaot_id != 0
                   THEN
                       ' and km.kaot_id = ' || p_kaot_id
               END
            || '
                     and nppt.nppt_id = p3.scp3_nppt
                     --AND nppt.nppt_id IN (13000, 14000)
                     and pps.scpp_pfu_pd_st not in (''PS'', ''V'')
                     and d.dt between pps.scpp_pfu_pd_start_dt and pps.scpp_pfu_pd_stop_dt
                     and nppt.nppt_id in (13000, 14000)
                     AND f.scf_sc = schh_sc
                 ) t
              group by Sca_Region
          )

         select rn,
                col_2,            -- Назва адміністративно-територіальної одиниці
                col_3,            -- Кількість діючих субсидій на оплату СГТП, всього (домогосподарств)
                col_4,            -- у тому числі ВПО з числа зазначених у стовпчику 3
                col_5,            -- Всього з початку року (Сума нарахованих субсидій на придбання твердого палива і скрапленого газу, тис. грн	)
                col_6,            -- в т. ч. у звітному місяці
                col_7,            -- Всього з початку року (Кількість домогосподарств, яким нараховано субсидію на придбання твердого палива і скрапленого газу (крім призначених у розмірі 0,00 грн) з числа зазначених у стовпчику 3)
                col_8,            -- в т. ч. у звітному місяці
                col_9,            -- Середній розмір субсидії  із зазначених в стовпчику 7, грн
                col_10,           -- Кількість домогосподарств, які звернулися за призначенням субсидії на придбання твердого палива і скрапленого газу в звітному місяці
                col_11,           -- Сума нарахованих субсидій домогосподарствам, зазначеним в стовпчику 10, тис.грн
                col_12,           -- Кількість домогосподарств, яким призначено субсидію на придбання твердого палива і скрапленого газу в звітному місяці
                col_13,           -- у тому числі ВПО з числа зазначених у стовпчику 12
                col_14            -- Кількість домогосподарств, яким відмовлено в субсидії субсидію на  придбання твердого палива і скрапленого газу в звітному місяці
           from
                (select rn+1 rn,
                        col_2,--    "назва області",
                        col_3,
                        col_4,
                        round(col_5/1000, 2) AS  col_5,
                        round(col_6/1000, 2) AS  col_6,
                        col_7,
                        col_8,
                        /*round(col_9, 2) as col_9,  */
                        decode(col_7, null, null, 0, null, round(round(col_5/1000, 2)*1000/col_7, 2)) as col_9,
                        col_10,
                        round(col_11/1000, 2) AS col_11,
                        col_12,
                        col_13,
                        col_14
                   from t
                 union all
                 select 1 rn,
                        '''
            || l_level_name
            || ''',
                        sum(col_3),
                        sum(col_4),
                        sum(round(col_5/1000, 2)),
                        sum(round(col_6/1000, 2)),
                        sum(col_7),
                        sum(col_8),
                        decode(sum(col_7), null, null, 0, null, round(sum(round(col_5/1000, 2))*1000/sum(col_7), 2)),
                        sum(col_10),
                        sum(round(col_11/1000, 2)),
                        sum(col_12),
                        sum(col_13),
                        sum(col_14)
                   from t
                ), d
        order by rn
    ';

        --підставити параметр
        /*IF (p_org_id IS NULL OR p_org_id = 0) THEN
          l_sql:= replace(l_sql, ':p_date', q'[to_date(']'||to_char(l_date, 'dd.mm.yyyy')||q'[', 'dd.mm.yyyy')]');
          RDM$RTFL.AddDataSet(l_jbr_id, 'ds', l_sql);
        ELSE
          l_sql_obl := replace(l_sql_obl, ':p_date', q'[to_date(']'||to_char(l_date, 'dd.mm.yyyy')||q'[', 'dd.mm.yyyy')]');
          RDM$RTFL.AddDataSet(l_jbr_id, 'ds', l_sql_obl);
        END IF;*/

        l_sql :=
            REPLACE (
                l_sql,
                ':p_date',
                   q'[to_date(']'
                || TO_CHAR (l_date, 'dd.mm.yyyy')
                || q'[', 'dd.mm.yyyy')]');
        RDM$RTFL.AddDataSet (l_jbr_id, 'ds', l_sql);

        RDM$RTFL.PutReportToWorkingQueue (p_jbr_id => l_jbr_id);
        RETURN l_jbr_id;
    END;

    -- #93677: Отримувачі житлових субсидій (ЖКП+СГТП) (територіальний поділ)
    FUNCTION SUBSIDY_INFO_R3 (p_start_dt   IN DATE,
                              p_rt_id      IN rpt_templates.rt_id%TYPE,
                              p_kaot_id    IN NUMBER)
        RETURN DECIMAL
    IS
        l_jbr_id       NUMBER;
        l_date         DATE := TRUNC (p_start_dt, 'mm');
        l_sql          VARCHAR2 (32000);
        --l_sql_obl varchar2(32000);
        --l_org_to NUMBER;
        l_level        NUMBER;
        l_level_data   NUMBER;
        l_level_name   VARCHAR2 (500);
    BEGIN
        l_jbr_id :=
            RDM$RTFL.InitReport (
                p_rt_id      => p_rt_id,
                p_rpt_name   => 'Субсидії_ЖКП_СГТП_тер_поділ');
        RDM$RTFL.AddParam (l_jbr_id,
                           'p_date',
                           TO_CHAR (ADD_MONTHS (l_date, 1), 'dd.mm.yyyy'));
        RDM$RTFL.AddParam (l_jbr_id,
                           'gen_dt',
                           TO_CHAR (SYSDATE, 'dd.mm.yyyy'));
        rdm$rtfl.SetFileName (
            l_jbr_id,
               'Субсидії_ЖКП_СГТП_тер_поділ'
            || '_'
            || TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS')
            || '.XLS');

        get_kaot_info (p_kaot_id,
                       l_level,
                       l_level_data,
                       l_level_name);
        /*SELECT MAX(org_to)
          INTO l_org_to
          FROM v_opfu t
          WHERE org_id = p_org_id;

          _sql:= q'[
           WITH     d as (select :p_date dt, extract(YEAR from :p_date) yyyy, extract(MONTH from :p_date) mm from dual),
             t as
              (SELECT row_number() over(order by nlssort(Sca_Region, 'NLS_SORT=ukrainian')) rn,
                      Sca_Region AS col_2,
                      COUNT(DISTINCT sca_id) AS col_3,
                      COUNT(DISTINCT CASE WHEN kaot_tp in ('K', 'M', 'B') THEN sca_id END) AS col_4,
                      COUNT(DISTINCT CASE WHEN kaot_tp in ('C', 'X') THEN sca_id END) AS col_5,
                      COUNT(DISTINCT CASE WHEN kaot_tp in ('T') THEN sca_id END) AS col_6,
                      COUNT(DISTINCT CASE WHEN kaot_tp is null or  kaot_tp in ('H', 'P', 'O') THEN sca_id END) AS col_7
                 FROM (select sca_id,
                              k.kaot_tp,
                              sca.sca_region,
                              case
                                when d.mm =  1 and p3.scp3_sum_m1 > 0 then 1
                                when d.mm =  2 and p3.scp3_sum_m2 > 0 then 1
                                when d.mm =  3 and p3.scp3_sum_m3 > 0 then 1
                                when d.mm =  4 and p3.scp3_sum_m4 > 0 then 1
                                when d.mm =  5 and p3.scp3_sum_m5 > 0 then 1
                                when d.mm =  6 and p3.scp3_sum_m6 > 0 then 1
                                when d.mm =  7 and p3.scp3_sum_m7 > 0 then 1
                                when d.mm =  8 and p3.scp3_sum_m8 > 0 then 1
                                when d.mm =  9 and p3.scp3_sum_m9 > 0 then 1
                                when d.mm = 10 and p3.scp3_sum_m10 > 0 then 1
                                when d.mm = 11 and p3.scp3_sum_m11 > 0 then 1
                                when d.mm = 12 and p3.scp3_sum_m12 > 0 then 1
                                else 0
                              end cnt
                       from d,
                            uss_person.v_sc_pfu_pay_period p3,
                            uss_person.v_sc_pfu_pay_summary pps,
                            uss_person.v_sc_household sch,
                            uss_person.v_Sc_Address sca,
                            uss_ndi.v_ndi_pfu_payment_type nppt,
                            uss_ndi.v_ndi_katottg k
                      where 1 = 1
                        and pps.scpp_id = p3.scp3_scpp
                        and pps.scpp_pfu_payment_tp = 'SUBSIDY'
                        and sch.schh_id = pps.scpp_schh
                        --and sca.sca_id = sch.schh_sca
                        and sca.sca_sc = p3.scp3_sc
                        and sca.sca_tp = '5'
                        and sca.history_status = 'A'
                        and nppt.nppt_id(+) = p3.scp3_nppt
                        and k.kaot_id = sca.sca_kaot
                        and d.dt between pps.scpp_pfu_pd_start_dt and pps.scpp_pfu_pd_stop_dt
                        and pps.scpp_pfu_pd_st not in ('PS', 'V')
                  ) t
                  where cnt > 0
                  group by Sca_Region
              )

             select rn as col_1,
                    col_2,--    "назва області",
                    col_3,
                    col_4,
                    col_5,
                    col_6,
                    col_7
               from
                    (select rn+1 rn,
                            case when (lower(col_2)) = 'київ' then 'м. ' || initCap(col_2)
                                 when col_2 is not null then initCap(col_2) || ' обл.'
                            end as col_2,--    "назва області",
                            col_3,
                            col_4,
                            col_5,
                            col_6,
                            col_7
                       from t
                     union all
                     select 1 rn,
                            'УКРАЇНА',
                            sum(col_3),
                            sum(col_4),
                            sum(col_5),
                            sum(col_6),
                            sum(col_7)
                       from t
                    ), d
            order by rn
        ]';

        l_sql_obl:= q'[
           WITH     d as (select :p_date dt, extract(YEAR from :p_date) yyyy, extract(MONTH from :p_date) mm from dual),
             t as
              (SELECT row_number() over(order by nlssort(Sca_Region, 'NLS_SORT=ukrainian')) rn,
                      Sca_Region AS col_2,
                      COUNT(DISTINCT sca_id) AS col_3,
                      COUNT(DISTINCT CASE WHEN kaot_tp in ('K', 'M', 'B') THEN sca_id END) AS col_4,
                      COUNT(DISTINCT CASE WHEN kaot_tp in ('C', 'X') THEN sca_id END) AS col_5,
                      COUNT(DISTINCT CASE WHEN kaot_tp in ('T') THEN sca_id END) AS col_6,
                      COUNT(DISTINCT CASE WHEN kaot_tp is null or  kaot_tp in ('H', 'P', 'O') THEN sca_id END) AS col_7
                 FROM (select sca_id,
                              k.kaot_tp,
                              pr.org_name as sca_region,
                              case
                                when d.mm =  1 and p3.scp3_sum_m1 > 0 then 1
                                when d.mm =  2 and p3.scp3_sum_m2 > 0 then 1
                                when d.mm =  3 and p3.scp3_sum_m3 > 0 then 1
                                when d.mm =  4 and p3.scp3_sum_m4 > 0 then 1
                                when d.mm =  5 and p3.scp3_sum_m5 > 0 then 1
                                when d.mm =  6 and p3.scp3_sum_m6 > 0 then 1
                                when d.mm =  7 and p3.scp3_sum_m7 > 0 then 1
                                when d.mm =  8 and p3.scp3_sum_m8 > 0 then 1
                                when d.mm =  9 and p3.scp3_sum_m9 > 0 then 1
                                when d.mm = 10 and p3.scp3_sum_m10 > 0 then 1
                                when d.mm = 11 and p3.scp3_sum_m11 > 0 then 1
                                when d.mm = 12 and p3.scp3_sum_m12 > 0 then 1
                                else 0
                              end cnt
                       from d,
                            uss_person.v_sc_pfu_pay_period p3,
                            uss_person.v_sc_pfu_pay_summary pps,
                            uss_person.v_sc_household sch,
                            uss_person.v_Sc_Address sca,
                            uss_ndi.v_ndi_pfu_payment_type nppt,
                            uss_ndi.v_ndi_katottg k,
                            uss_ndi.v_ndi_org2kaot kz,
                            v_opfu pr,
                            v_opfu po
                      where 1 = 1
                        and pps.scpp_id = p3.scp3_scpp
                        and pps.scpp_pfu_payment_tp = 'SUBSIDY'
                        and sch.schh_id = pps.scpp_schh
                        --and sca.sca_id = sch.schh_sca
                        and sca.sca_sc = p3.scp3_sc
                        and sca.sca_tp = '5'
                        and sca.history_status = 'A'
                        and nppt.nppt_id(+) = p3.scp3_nppt
                        and k.kaot_id = sca.sca_kaot
                        and d.dt between pps.scpp_pfu_pd_start_dt and pps.scpp_pfu_pd_stop_dt
                        and pps.scpp_pfu_pd_st not in ('PS', 'V')

                        AND kz.nok_kaot = sca.sca_kaot
                        and kz.history_status = 'A'
                        and nppt.nppt_id = p3.scp3_nppt
                        --and d.dt between nvl(kz.nk2o_start_dt, d.dt) AND nvl(kz.nk2o_stop_dt, d.dt)
                        AND pr.org_id = kz.nok_org
                        AND po.org_id = decode(pr.org_to, 32, pr.org_org, pr.org_id)
                        AND ]' || CASE WHEN l_org_to = 31 THEN ' po.org_id = ' || p_org_id  ELSE ' pr.org_id = ' || p_org_id  END || '
                  ) t
                  where cnt > 0
                  group by Sca_Region
              )

             select rn as col_1,
                    col_2,--    "назва області",
                    col_3,
                    col_4,
                    col_5,
                    col_6,
                    col_7
               from
                    (select rn rn,
                            initcap(col_2) as col_2,--    "назва області",
                            col_3,
                            col_4,
                            col_5,
                            col_6,
                            col_7
                       from t
                    ), d
            order by rn
        ';*/

        l_sql :=
               q'[
       WITH     d as (select :p_date dt, extract(YEAR from :p_date) yyyy, extract(MONTH from :p_date) mm from dual),
         t as
          (SELECT row_number() over(order by DECODE(Sca_Region, 'невизначено або відсутні дані', 9999, 0), nlssort(Sca_Region, 'NLS_SORT=ukrainian')) rn,
                  Sca_Region AS col_2,
                  COUNT(DISTINCT sca_id) AS col_3,
                  COUNT(DISTINCT CASE WHEN kaot_tp in ('K', 'M', 'B') THEN sca_id END) AS col_4,
                  COUNT(DISTINCT CASE WHEN kaot_tp in ('C', 'X') THEN sca_id END) AS col_5,
                  COUNT(DISTINCT CASE WHEN kaot_tp in ('T') THEN sca_id END) AS col_6,
                  COUNT(DISTINCT CASE WHEN kaot_tp is null or  kaot_tp in ('H', 'P', 'O') THEN sca_id END) AS col_7
             FROM (select sca_id,
                          k.kaot_tp,
                          nvl(kd.kaot_full_name, 'невизначено або відсутні дані') as sca_region,
                          case
                            when d.mm =  1 and p3.scp3_sum_m1 > 0 then 1
                            when d.mm =  2 and p3.scp3_sum_m2 > 0 then 1
                            when d.mm =  3 and p3.scp3_sum_m3 > 0 then 1
                            when d.mm =  4 and p3.scp3_sum_m4 > 0 then 1
                            when d.mm =  5 and p3.scp3_sum_m5 > 0 then 1
                            when d.mm =  6 and p3.scp3_sum_m6 > 0 then 1
                            when d.mm =  7 and p3.scp3_sum_m7 > 0 then 1
                            when d.mm =  8 and p3.scp3_sum_m8 > 0 then 1
                            when d.mm =  9 and p3.scp3_sum_m9 > 0 then 1
                            when d.mm = 10 and p3.scp3_sum_m10 > 0 then 1
                            when d.mm = 11 and p3.scp3_sum_m11 > 0 then 1
                            when d.mm = 12 and p3.scp3_sum_m12 > 0 then 1
                            else 0
                          end cnt
                   from d,
                        uss_person.v_sc_pfu_pay_period p3,
                        uss_person.v_sc_pfu_pay_summary pps,
                        uss_person.v_sc_household sch,
                        uss_person.v_Sc_Address sca,
                        uss_ndi.v_ndi_pfu_payment_type nppt,
                        uss_ndi.v_ndi_katottg k,
                        uss_ndi.v_ndi_katottg km,
                        uss_ndi.v_ndi_katottg kd
                  where 1 = 1
                    and pps.scpp_id = p3.scp3_scpp
                    and pps.scpp_pfu_payment_tp = 'SUBSIDY'
                    and sch.schh_id = pps.scpp_schh
                    --and sca.sca_id = sch.schh_sca
                    and sca.sca_sc = p3.scp3_sc
                    and sca.sca_tp = '5'
                    and sca.history_status = 'A'
                    and nppt.nppt_id(+) = p3.scp3_nppt
                    and k.kaot_id = sca.sca_kaot
                    and km.kaot_id = k.kaot_kaot_l]'
            || l_level
            || '
                    and kd.kaot_id(+) = k.kaot_kaot_l'
            || l_level_data
            || CASE
                   WHEN p_kaot_id IS NOT NULL AND p_kaot_id != 0
                   THEN
                       ' and km.kaot_id = ' || p_kaot_id
               END
            || '
                    and d.dt between pps.scpp_pfu_pd_start_dt and pps.scpp_pfu_pd_stop_dt
                    and pps.scpp_pfu_pd_st not in (''PS'', ''V'')
              ) t
              where cnt > 0
              group by Sca_Region
          )

         select rn as col_1,
                col_2,    -- назва області
                col_3,    -- кількість діючих субсидій (домогосподарств)
                col_4,    -- місто, з довідника КАТОТТГ тип населеного пункт ''M'' - місто, ''B''-район міста, ''K''-Київ
                col_5,    -- село, з довідника КАТОТТГ тип населеного пункту ''C''-село, ''X''- хутір
                col_6,    -- смт, з довідника КАТОТТГ тип населеного пункту ''T'' смт
                col_7     -- тип населеного пункту відсутній або з довідника КАТОТТГ тип ''H''-тергромада, ''P''-район, ''O''-область
           from
                (select rn+1 rn,
                        col_2,--    "назва області",
                        col_3,
                        col_4,
                        col_5,
                        col_6,
                        col_7
                   from t
                 union all
                 select 1 rn,
                        '''
            || l_level_name
            || ''',
                        sum(col_3),
                        sum(col_4),
                        sum(col_5),
                        sum(col_6),
                        sum(col_7)
                   from t
                ), d
        order by rn
    ';

        --підставити параметр
        /*IF (p_org_id IS NULL OR p_org_id = 0) THEN
          l_sql:= replace(l_sql, ':p_date', q'[to_date(']'||to_char(l_date, 'dd.mm.yyyy')||q'[', 'dd.mm.yyyy')]');
          RDM$RTFL.AddDataSet(l_jbr_id, 'ds', l_sql);
        ELSE
          l_sql_obl := replace(l_sql_obl, ':p_date', q'[to_date(']'||to_char(l_date, 'dd.mm.yyyy')||q'[', 'dd.mm.yyyy')]');
          RDM$RTFL.AddDataSet(l_jbr_id, 'ds', l_sql_obl);
        END IF;*/

        l_sql :=
            REPLACE (
                l_sql,
                ':p_date',
                   q'[to_date(']'
                || TO_CHAR (l_date, 'dd.mm.yyyy')
                || q'[', 'dd.mm.yyyy')]');
        RDM$RTFL.AddDataSet (l_jbr_id, 'ds', l_sql);

        RDM$RTFL.PutReportToWorkingQueue (p_jbr_id => l_jbr_id);
        RETURN l_jbr_id;
    END;

    PROCEDURE reg_report (p_rt_id      IN     NUMBER,
                          p_start_dt   IN     DATE,
                          p_stop_dt    IN     DATE,
                          p_org_id     IN     NUMBER,
                          p_nbc_id     IN     NUMBER,
                          p_jbr_id        OUT DECIMAL)
    IS
        v_rt_code   rpt_templates.rt_code%TYPE := get_rpt_code (p_rt_id);
    BEGIN
        tools.WriteMsg ('DNET$RPT_BENEFITS.' || $$PLSQL_UNIT);
        --ідентифікація процесу
        DBMS_APPLICATION_INFO.set_module (
            module_name   => $$PLSQL_UNIT,
            action_name   =>
                   'p_rt_id='
                || TO_CHAR (p_rt_id)
                || '; p_start_dt='
                || TO_CHAR (p_start_dt)
                || '; p_stop_dt='
                || TO_CHAR (p_stop_dt)
                || '; p_org_id='
                || TO_CHAR (p_org_id));

        p_jbr_id :=
            CASE
                WHEN v_rt_code = 'BENEFIT_RECIPIENTS_CNT_R1'
                THEN
                    BENEFIT_RECIPIENTS_CNT_R1 (p_rt_id,
                                               p_start_dt,
                                               p_stop_dt,
                                               p_org_id)
                WHEN v_rt_code = 'BENEFIT_RECIPIENTS_DETAILED_R1'
                THEN
                    BENEFIT_RECIPIENTS_DETAILED_R1 (p_rt_id,
                                                    p_start_dt,
                                                    p_org_id,
                                                    p_nbc_id)
                WHEN v_rt_code = 'BENEFIT_GAS_INFO_R1'
                THEN
                    BENEFIT_GAS_INFO_R1 (p_rt_id, p_start_dt, p_org_id)
                WHEN v_rt_code = 'BENEFIT_GAS_INFO_R2'
                THEN
                    BENEFIT_GAS_INFO_R2 (p_rt_id, p_start_dt, p_org_id)
                WHEN v_rt_code = 'BENEFIT_GAS_INFO_R3'
                THEN
                    BENEFIT_GAS_INFO_R3 (p_rt_id, p_start_dt, p_org_id)
                WHEN v_rt_code = 'BENEFIT_GAS_INFO_R4'
                THEN
                    BENEFIT_GAS_INFO_R4 (p_rt_id, p_start_dt, p_org_id)
                WHEN v_rt_code = 'SUBSIDY_INFO_R1'
                THEN
                    SUBSIDY_INFO_R1 (p_start_dt, p_rt_id, p_org_id)  -- #92280
                WHEN v_rt_code = 'SUBSIDY_INFO_R2'
                THEN
                    SUBSIDY_INFO_R2 (p_start_dt, p_rt_id, p_org_id)  -- #92273
                WHEN v_rt_code = 'SUBSIDY_INFO_R3'
                THEN
                    SUBSIDY_INFO_R3 (p_start_dt, p_rt_id, p_org_id)  -- #93677
                WHEN v_rt_code = 'JKP_SUBSIDY_TYPE_HEATING'
                THEN
                    JKP_SUBSIDY_TYPE_HEATING (p_start_dt, p_org_id, p_rt_id)
                WHEN v_rt_code = 'JKP_BENEFIT_TYPE_CGTP_JKP'
                THEN
                    JKP_BENEFIT_TYPE_CGTP_JKP (p_start_dt, p_org_id, p_rt_id)
                WHEN v_rt_code = 'SUBSIDY_TYPE_JPK'
                THEN
                    SUBSIDY_TYPE_JPK (p_start_dt, p_org_id, p_rt_id)
                WHEN v_rt_code = 'BENEFIT_TYPE_JPK'
                THEN
                    BENEFIT_TYPE_JPK (p_start_dt, p_org_id, p_rt_id)
                WHEN v_rt_code = 'JKP_SUBSIDY_MAX_MIN'
                THEN
                    JKP_SUBSIDY_MAX_MIN (p_start_dt, p_org_id, p_rt_id)
                ELSE
                    NULL
            END;
    END;
BEGIN
    NULL;
END DNET$RPT_BENEFITS;
/