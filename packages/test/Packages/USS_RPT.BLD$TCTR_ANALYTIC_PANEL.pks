/* Formatted on 8/12/2025 5:58:56 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RPT.BLD$TCTR_ANALYTIC_PANEL
IS
    -- Author  : USER
    -- Created : 17.01.2024 12:06:34
    -- Purpose :

    FUNCTION IsDevMode
        RETURN NUMBER;

    PROCEDURE Recalc_Tctr_Analityc_all;

    PROCEDURE Recalc_Tctr_Osp_Analityc_Panel;

    PROCEDURE Recalc_Rnsp_Analityc_Panel;
END BLD$TCTR_ANALYTIC_PANEL;
/


/* Formatted on 8/12/2025 5:58:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RPT.BLD$TCTR_ANALYTIC_PANEL
IS
    FUNCTION IsDevMode
        RETURN NUMBER
    IS
        l_Res   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_Res
          FROM global_name
         WHERE GLOBAL_NAME = 'SONYA12PDB.DEV.UA';

        RETURN l_Res;
    END;

    PROCEDURE Recalc_Tctr_Analityc_all
    IS
    BEGIN
        Recalc_Tctr_Osp_Analityc_Panel;
        Recalc_Rnsp_Analityc_Panel;
    END;

    PROCEDURE Recalc_Tctr_Osp_Analityc_Panel
    IS
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE tctr_osp_services';

        INSERT INTO tctr_osp_services (toas_sc,
                                       toas_nst,
                                       toad_months_amount,
                                       toas_date_end,
                                       toas_kaot,
                                       toas_rnspm,
                                       toas_rnspm_tp,
                                       TOAS_AT,
                                       TOAS_IS_DISABLED,
                                       TOAS_IS_CAPABLE,
                                       TOAS_SCY_GROUP,
                                       TOAS_GENDER,
                                       TOAS_DATE_BIRTH,
                                       TOAS_FULL_YEAR)
            SELECT atp_sc,
                   ats_nst,
                   months_amount,
                   date_end,
                   kaot_id,
                   at_rnspm,
                   RNSPM_TP,
                   at_id,
                   atp_is_disabled,
                   atp_is_capable,
                   disability_group,
                   atp_sex,
                   atp_birth_dt,
                   full_year
              FROM (SELECT atp_sc,
                           ats_nst,
                           months_amount,
                           date_end,
                           kaot_id,
                           at_rnspm,
                           RNSPM_TP,
                           at_id,
                           atp_is_disabled,
                           atp_is_capable,
                           disability_group,
                           atp_sex,
                           atp_birth_dt,
                           full_year,
                           MAX (at_id)
                               OVER (PARTITION BY atp_sc, ats_nst, at_id)    last_at_id
                      FROM (SELECT ap.atp_sc,
                                   ats.ats_nst,
                                   MONTHS_BETWEEN (
                                       a.at_action_stop_dt,
                                       NVL (a.at_action_stop_dt, SYSDATE))
                                       months_amount,
                                   a.at_action_stop_dt
                                       date_end,
                                   CASE
                                       WHEN ats.ats_ss_address_tp IN
                                                ('U', 'P')
                                       THEN
                                           USS_ESR.API$ACT_ANALYTIC_PANELS.Get_Act_Sc_Koat_Id (
                                               a.at_ap,
                                               ap.atp_sc)
                                       WHEN ats.ats_ss_address_tp IN ('S')
                                       THEN
                                           (SELECT ra.RNSPA_KAOT
                                              FROM uss_rnsp.v_rnsp_address ra
                                             WHERE ra.RNSPA_ID =
                                                   ats.ats_rnspa
                                             FETCH FIRST 1 ROWS ONLY)
                                   END
                                       kaot_id,
                                   a.at_rnspm,
                                   r.RNSPM_TP,
                                   a.at_id,
                                   NVL (ap.atp_is_disabled, 'F')
                                       atp_is_disabled,
                                   NVL (ap.atp_is_capable, 'F')
                                       atp_is_capable,
                                   uss_person.Api$sc_Tools.get_disability_group (
                                       ap.atp_sc)
                                       disability_group,
                                   NVL (ap.atp_sex, 'U')
                                       atp_sex,
                                   ap.atp_birth_dt
                                       atp_birth_dt,
                                   TRUNC (
                                         MONTHS_BETWEEN (SYSDATE,
                                                         ap.atp_birth_dt)
                                       / 12)
                                       full_year,
                                   COUNT (ap.atp_id)
                                       OVER (PARTITION BY ap.atp_at)
                                       qty_all,
                                   NVL (
                                       SUM (
                                           CASE
                                               WHEN ap.atp_sc IS NOT NULL
                                               THEN
                                                   1
                                           END)
                                           OVER (PARTITION BY ap.atp_at),
                                       0)
                                       qty_fulled,
                                   CASE
                                       WHEN     uss_Esr.Api$find.Check_Attr_801_Serv_To (
                                                    a.at_ap,
                                                    'Z',
                                                    'Z') =
                                                1
                                            AND ap.ATP_APP_TP = 'Z'
                                       THEN
                                           1
                                       WHEN     (   uss_Esr.Api$find.Check_Attr_801_Serv_To (
                                                        a.at_ap,
                                                        'Z',
                                                        'B') =
                                                    1
                                                 OR uss_Esr.Api$find.Check_Attr_801_Serv_To (
                                                        a.at_ap,
                                                        'Z',
                                                        'CHRG') =
                                                    1)
                                            AND ap.ATP_APP_TP = 'OS'
                                       THEN
                                           1
                                       WHEN uss_Esr.Api$find.Check_Attr_801_Serv_To (
                                                a.at_ap,
                                                'FM',
                                                'FM') =
                                            1
                                       THEN
                                           1
                                   END
                                       is_need_add
                              FROM uss_esr.at_person  ap
                                   JOIN uss_esr.act a ON ap.atp_at = a.at_id
                                   JOIN uss_esr.at_service ats
                                       ON ats_at = a.at_id
                                   LEFT JOIN uss_rnsp.v_rnsp_main r
                                       ON a.at_rnspm = r.RNSPM_ID
                             WHERE     a.at_tp = 'TCTR'
                                   AND a.at_st IN ('DT')
                                   AND ats.history_status = 'A'
                                   --AND a.at_id in (20664, 22882, 21842, 20762, 17402, 17164, 16783, 11164, 10364, 20422, 23022)
                                   AND CASE
                                           WHEN     uss_Esr.Api$find.Check_Attr_801_Serv_To (
                                                        a.at_ap,
                                                        'Z',
                                                        'Z') =
                                                    1
                                                AND ap.ATP_APP_TP = 'Z'
                                           THEN
                                               1
                                           WHEN     (   uss_Esr.Api$find.Check_Attr_801_Serv_To (
                                                            a.at_ap,
                                                            'Z',
                                                            'B') =
                                                        1
                                                     OR uss_Esr.Api$find.Check_Attr_801_Serv_To (
                                                            a.at_ap,
                                                            'Z',
                                                            'CHRG') =
                                                        1)
                                                AND ap.ATP_APP_TP = 'OS'
                                           THEN
                                               1
                                           WHEN uss_Esr.Api$find.Check_Attr_801_Serv_To (
                                                    a.at_ap,
                                                    'FM',
                                                    'FM') =
                                                1
                                           THEN
                                               1
                                       END =
                                       1)
                     WHERE     kaot_id IS NOT NULL
                           AND qty_all = qty_fulled
                           AND qty_fulled > 0
                           AND is_need_add = 1)
             WHERE at_id = last_at_id;

        COMMIT;

        EXECUTE IMMEDIATE 'TRUNCATE TABLE tctr_osp_relatives';

        INSERT INTO tctr_osp_relatives (toar_sc_from,
                                        toar_sc_to,
                                        toar_relation_tp,
                                        toar_date_birth,
                                        toar_full_year)
            SELECT DISTINCT
                   j.nsj_sc,
                   p.njp_sc,
                   p.njp_relation_tp,
                   p.njp_birth_dt,
                   TRUNC (MONTHS_BETWEEN (SYSDATE, p.njp_birth_dt) / 12)    full_year
              FROM uss_esr.V_NSJ_PERSONS  p
                   JOIN uss_esr.v_nsp_sc_journal j ON p.njp_nsj = j.nsj_id
             WHERE     p.history_status = 'A'
                   AND j.nsj_sc <> p.njp_sc
                   AND EXISTS
                           (SELECT 1
                              FROM tctr_osp_services o
                             WHERE p.njp_sc = o.toas_sc);

        COMMIT;

        EXECUTE IMMEDIATE 'TRUNCATE TABLE tctr_osp_family_features';

        INSERT INTO tctr_osp_family_features (toff_sc, toff_rnspm, toff_nff)
            SELECT sj.nsj_sc, sj.nsj_rnspm, nfd.njfd_nff
              FROM uss_esr.V_NSP_SC_JOURNAL  sj
                   JOIN uss_esr.v_nsj_features nf
                       ON sj.nsj_id = nf.njf_nsj AND nf.history_status = 'A'
                   JOIN uss_esr.v_nsj_feature_data nfd
                       ON     nf.njf_id = nfd.njfd_id
                          AND nfd.history_status = 'A'
             WHERE     sj.nsj_st = 'KN'
                   AND EXISTS
                           (SELECT 1
                              FROM tctr_osp_services o
                             WHERE sj.nsj_sc = o.toas_sc);

        COMMIT;
    END;

    --Процедура не актуальна
    /*
    PROCEDURE Recalc_Tctr_Analityc_Panel IS
    BEGIN
      EXECUTE IMMEDIATE 'TRUNCATE TABLE tctr_analytic';


      INSERT INTO tctr_analytic
      (atta_atp, atta_sc, atta_at, atta_nst, atta_kaot, atta_is_disabled, atta_gender, atta_atp_date_birth)

      SELECT  ap.atp_id,
              a.at_sc,
              a.at_id,
              ats.ats_nst,
              USS_ESR.API$ACT_ANALYTIC_PANELS.Get_Act_Sc_Koat_Id(a.at_ap, a.at_sc) kaot_id,
              NVL(ap.atp_is_disabled,'F') atp_is_disabled,
              nvl(ap.atp_sex,'U') atp_sex,
              ap.atp_birth_dt
      FROM uss_esr.at_person ap
      JOIN uss_esr.act a
        ON ap.atp_at = a.at_id
      JOIN uss_esr.at_service ats
        ON ats_at = a.at_id
       AND ats.history_status='A'
      WHERE a.at_tp='TCTR'
        AND a.at_st in ('DT', 'DPU')
        AND ats.history_status='A'
        AND CASE WHEN uss_Esr.Api$find.Check_Attr_801_Serv_To(a.at_ap,'Z','Z') = 1 AND ap.ATP_APP_TP = 'Z' THEN 1
                   WHEN (uss_Esr.Api$find.Check_Attr_801_Serv_To(a.at_ap,'Z','B') = 1 OR uss_Esr.Api$find.Check_Attr_801_Serv_To(a.at_ap,'Z','CHRG') = 1) AND ap.ATP_APP_TP = 'OS' THEN 1
                   WHEN uss_Esr.Api$find.Check_Attr_801_Serv_To(a.at_ap,'FM','FM') = 1 THEN 1 END = 1;

      COMMIT;

      EXECUTE IMMEDIATE 'TRUNCATE TABLE tctr_analytic_panel';
      INSERT INTO tctr_analytic_panel
       (tap_kaot,
        tap_nst,
        tap_rsnp_qty,
        tap_at_qty,
        tap_m_less_18,
        tap_m_between_18_60,
        tap_m_greate_60,
        tap_m_unaged,
        tap_m_is_disabled,
        tap_f_less_18,
        tap_f_between_18_60,
        tap_f_greate_60,
        tap_f_unaged,
        tap_f_is_disabled,
        tap_u_less_18,
        tap_u_between_18_60,
        tap_u_greate_60,
        tap_u_unaged,
        tap_u_is_disabled)
       SELECT atta_kaot,
              atta_nst,
                     (select count(distinct rst.RNSPS_RNSPM)
                        from uss_rnsp.v_rnsp_state rst
                        join uss_rnsp.v_rnsp2service r2s
                          on rst.RNSPS_ID = r2s.rnsp2s_rnsps
                        join uss_rnsp.v_rnsp_dict_service rds
                          on r2s.rnsp2s_rnspds = rds.RNSPDS_ID
                        join uss_rnsp.v_rnsp2address r2a
                          on rst.RNSPS_ID = r2a.RNSP2A_RNSPS
                        join uss_rnsp.v_rnsp_address ra
                          on r2a.RNSP2A_RNSPA = ra.RNSPA_ID
                        where rst.HISTORY_STATUS='A'
                          and ra.RNSPA_TP='U'
                          and ra.RNSPA_KAOT = atta_kaot
                          and rds.RNSPDS_NST = atta_nst) rnsp_qty,
                    at_qty,
                    m_less_18,
                    m_between_18_60,
                    m_great_60,
                    m_unaged,
                    m_is_disabled,
                    f_less_18,
                    f_between_18_60,
                    f_great_60,
                    f_unaged,
                    f_is_disabled,
                    u_less_18,
                    u_between_18_60,
                    u_great_60,
                    u_unaged,
                    u_is_disabled
       FROM (
       SELECT atta_kaot,
              atta_nst,
                    count(distinct atta_at) at_qty,
                    count(distinct case when atta_gender='M' and atta_age<18 then ta.atta_sc end) m_less_18,
                    count(distinct case when atta_gender='M' and atta_age between 18 and 60 then ta.atta_sc end) m_between_18_60,
                    count(distinct case when atta_gender='M' and atta_age>60 then ta.atta_sc end) m_great_60,
                    count(distinct case when atta_gender='M' and nvl(atta_age,0)<=0 then ta.atta_sc end) m_unaged,
                    count(distinct case when atta_gender='M' and atta_is_disabled='T' then ta.atta_sc end) m_is_disabled,
                    count(distinct case when atta_gender='F' and atta_age<18 then ta.atta_sc end) f_less_18,
                    count(distinct case when atta_gender='F' and atta_age between 18 and 60 then ta.atta_sc end) f_between_18_60,
                    count(distinct case when atta_gender='F' and atta_age>60 then ta.atta_sc end) f_great_60,
                    count(distinct case when atta_gender='F' and nvl(atta_age,0)<=0 then ta.atta_sc end) f_unaged,
                    count(distinct case when atta_gender='F' and atta_is_disabled='T' then ta.atta_sc end) f_is_disabled,
                    count(distinct case when atta_gender not in ('F','M') and atta_age<18 then ta.atta_sc end) u_less_18,
                    count(distinct case when atta_gender not in ('F','M') and atta_age between 18 and 60 then ta.atta_sc end) u_between_18_60,
                    count(distinct case when atta_gender not in ('F','M') and atta_age>60 then ta.atta_sc end) u_great_60,
                    count(distinct case when atta_gender not in ('F','M') and nvl(atta_age,0)<=0 then ta.atta_sc end) u_unaged,
                    count(distinct case when atta_gender not in ('F','M') and atta_is_disabled='T' then ta.atta_sc end) u_is_disabled
       FROM (SELECT ta.*, TRUNC(MONTHS_BETWEEN(SYSDATE, ta.atta_atp_date_birth)/12) atta_age FROM tctr_analytic ta) ta
       group by ta.atta_kaot,
                ta.atta_nst);

      COMMIT;
    END;
    */

    PROCEDURE Recalc_Rnsp_Analityc_Panel
    IS
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE RNSP_ANALYTIC_PANEL';

        IF IsDevMode = 1
        THEN
            INSERT INTO rnsp_analytic_panel (rap_rnspm,
                                             rap_rnsps,
                                             rap_numident,
                                             rap_last_name,
                                             rap_phone,
                                             rap_email,
                                             rap_web,
                                             rap_ownership,
                                             rap_ownership_name,
                                             rap_org_tp,
                                             rap_org_tp_name,
                                             rap_head_fio,
                                             rap_addr_s_qty,
                                             rap_service_qty,
                                             rap_receiver_qty,
                                             RAP_ADDRESS_U_STR,
                                             RAP_ADDRESS_S_STR,
                                             RAP_SERVICES_NAMES,
                                             RAP_SERVICES_CONTENTS,
                                             RAP_SERVICES_CONTENTS2,
                                             RAP_SERVICES_SUMS)
                SELECT r.RNSPM_ID
                           RAP_RNSPM,
                       s.RNSPS_ID
                           RAP_RNSPS,
                       s.RNSPS_NUMIDENT
                           RAP_NUMIDENT,
                       s.RNSPS_LAST_NAME
                           RAP_LAST_NAME,
                       o.RNSPO_PHONE
                           RAP_PHONE,
                       o.RNSPO_EMAIL
                           RAP_EMAIL,
                       o.RNSPO_WEB
                           RAP_WEB,
                       s.rnsps_ownership
                           RAP_OWNERSHIP,
                       dow.dic_name
                           RAP_OWNERSHIP_NAME,
                       r.rnspm_org_tp
                           RAP_ORG_TP,
                       ot.DIC_NAME
                           RAP_ORG_TP_NAME,
                       uss_rnsp.Cmes$rnsp.Get_Rnsp_Head_Fio (r.RNSPM_ID)
                           RAP_HEAD_FIO,
                       (SELECT COUNT (DISTINCT ra.RNSPA_ID)
                          FROM uss_rnsp.v_rnsp_address  ra
                               JOIN uss_rnsp.v_rnsp2address r2a
                                   ON r2a.RNSP2A_RNSPA = ra.RNSPA_ID
                         WHERE     ra.RNSPA_TP = 'S'
                               AND r2a.rnsp2a_rnsps = s.RNSPS_ID)
                           RAP_ADDR_S_QTY,
                       (SELECT COUNT (DISTINCT rnspds_nst)
                          FROM uss_rnsp.v_rnsp_dict_service  ds
                               JOIN uss_rnsp.v_rnsp2service r2s
                                   ON ds.rnspds_id = r2s.rnsp2s_rnspds
                         WHERE r2s.rnsp2s_rnsps = s.RNSPS_ID)
                           RAP_SERVICE_QTY,
                       (SELECT COUNT (DISTINCT a.toas_sc)
                          FROM tctr_osp_services a
                         WHERE a.toas_rnspm = r.rnspm_id)
                           RAP_RECEIVER_QTY,
                       USS_ESR.API$ACT_ANALYTIC_PANELS.Get_Rnsp_Address_Analytic_List (
                           s.RNSPS_ID,
                           'U')
                           RAP_ADDRESS_U,
                       USS_ESR.API$ACT_ANALYTIC_PANELS.Get_Rnsp_Address_Analytic_List (
                           s.RNSPS_ID,
                           'S')
                           RAP_ADDRESS_S,
                       USS_ESR.API$ACT_ANALYTIC_PANELS.Get_Rnsp_Service_Analytic_List_Name (
                           s.RNSPS_ID),
                       SUBSTR (
                           USS_ESR.API$ACT_ANALYTIC_PANELS.Get_Rnsp_Service_Analytic_List_Content (
                               s.RNSPS_ID),
                           1,
                           4000),
                       SUBSTR (
                           USS_ESR.API$ACT_ANALYTIC_PANELS.Get_Rnsp_Service_Analytic_List_Content (
                               s.RNSPS_ID),
                           4001,
                           4000),
                       USS_ESR.API$ACT_ANALYTIC_PANELS.Get_Rnsp_Service_Analytic_List_Sum (
                           s.RNSPS_ID)
                  FROM uss_rnsp.v_rnsp_main  r
                       JOIN uss_rnsp.v_rnsp_state s
                           ON     s.RNSPS_RNSPM = r.RNSPM_ID
                              AND s.HISTORY_STATUS = 'A'
                       LEFT JOIN uss_rnsp.V_RNSP_OTHER o
                           ON s.RNSPS_RNSPO = o.RNSPO_ID
                       LEFT OUTER JOIN USS_NDI.V_DDN_RNSP_OWNERSHIP_N dow
                           ON s.rnsps_ownership = dow.dic_value
                       LEFT OUTER JOIN USS_NDI.V_DDN_RNSP_ORG_TP ot
                           ON r.rnspm_org_tp = ot.DIC_VALUE
                 WHERE     1 = 1
                       AND RNSPM_ST = 'A'
                       AND s.RNSPS_NUMIDENT IN
                               ('41177506', '51177506', '41846675')
                       AND ROWNUM <= 100;

            INSERT INTO rnsp_analytic_panel (rap_rnspm,
                                             rap_rnsps,
                                             rap_numident,
                                             rap_last_name,
                                             rap_phone,
                                             rap_email,
                                             rap_web,
                                             rap_ownership,
                                             rap_ownership_name,
                                             rap_org_tp,
                                             rap_org_tp_name,
                                             rap_head_fio,
                                             rap_addr_s_qty,
                                             rap_service_qty,
                                             rap_receiver_qty,
                                             RAP_ADDRESS_U_STR,
                                             RAP_ADDRESS_S_STR,
                                             RAP_SERVICES_NAMES,
                                             RAP_SERVICES_CONTENTS,
                                             RAP_SERVICES_CONTENTS2,
                                             RAP_SERVICES_SUMS)
                SELECT r.RNSPM_ID
                           RAP_RNSPM,
                       s.RNSPS_ID
                           RAP_RNSPS,
                       s.RNSPS_NUMIDENT
                           RAP_NUMIDENT,
                       s.RNSPS_LAST_NAME
                           RAP_LAST_NAME,
                       o.RNSPO_PHONE
                           RAP_PHONE,
                       o.RNSPO_EMAIL
                           RAP_EMAIL,
                       o.RNSPO_WEB
                           RAP_WEB,
                       s.rnsps_ownership
                           RAP_OWNERSHIP,
                       dow.dic_name
                           RAP_OWNERSHIP_NAME,
                       r.rnspm_org_tp
                           RAP_ORG_TP,
                       ot.DIC_NAME
                           RAP_ORG_TP_NAME,
                       uss_rnsp.Cmes$rnsp.Get_Rnsp_Head_Fio (r.RNSPM_ID)
                           RAP_HEAD_FIO,
                       (SELECT COUNT (DISTINCT ra.RNSPA_ID)
                          FROM uss_rnsp.v_rnsp_address  ra
                               JOIN uss_rnsp.v_rnsp2address r2a
                                   ON r2a.RNSP2A_RNSPA = ra.RNSPA_ID
                         WHERE     ra.RNSPA_TP = 'S'
                               AND r2a.rnsp2a_rnsps = s.RNSPS_ID)
                           RAP_ADDR_S_QTY,
                       (SELECT COUNT (DISTINCT rnspds_nst)
                          FROM uss_rnsp.v_rnsp_dict_service  ds
                               JOIN uss_rnsp.v_rnsp2service r2s
                                   ON ds.rnspds_id = r2s.rnsp2s_rnspds
                         WHERE r2s.rnsp2s_rnsps = s.RNSPS_ID)
                           RAP_SERVICE_QTY,
                       (SELECT COUNT (DISTINCT a.toas_sc)
                          FROM tctr_osp_services a
                         WHERE a.toas_rnspm = r.rnspm_id)
                           RAP_RECEIVER_QTY,
                       USS_ESR.API$ACT_ANALYTIC_PANELS.Get_Rnsp_Address_Analytic_List (
                           s.RNSPS_ID,
                           'U')
                           RAP_ADDRESS_U,
                       USS_ESR.API$ACT_ANALYTIC_PANELS.Get_Rnsp_Address_Analytic_List (
                           s.RNSPS_ID,
                           'S')
                           RAP_ADDRESS_S,
                       USS_ESR.API$ACT_ANALYTIC_PANELS.Get_Rnsp_Service_Analytic_List_Name (
                           s.RNSPS_ID),
                       SUBSTR (
                           USS_ESR.API$ACT_ANALYTIC_PANELS.Get_Rnsp_Service_Analytic_List_Content (
                               s.RNSPS_ID),
                           1,
                           4000),
                       SUBSTR (
                           USS_ESR.API$ACT_ANALYTIC_PANELS.Get_Rnsp_Service_Analytic_List_Content (
                               s.RNSPS_ID),
                           4001,
                           4000),
                       USS_ESR.API$ACT_ANALYTIC_PANELS.Get_Rnsp_Service_Analytic_List_Sum (
                           s.RNSPS_ID)
                  FROM uss_rnsp.v_rnsp_main  r
                       JOIN uss_rnsp.v_rnsp_state s
                           ON     s.RNSPS_RNSPM = r.RNSPM_ID
                              AND s.HISTORY_STATUS = 'A'
                       LEFT JOIN uss_rnsp.V_RNSP_OTHER o
                           ON s.RNSPS_RNSPO = o.RNSPO_ID
                       LEFT OUTER JOIN USS_NDI.V_DDN_RNSP_OWNERSHIP_N dow
                           ON s.rnsps_ownership = dow.dic_value
                       LEFT OUTER JOIN USS_NDI.V_DDN_RNSP_ORG_TP ot
                           ON r.rnspm_org_tp = ot.DIC_VALUE
                 WHERE 1 = 1 AND RNSPM_ST = 'A' AND ROWNUM <= 500;
        ELSE
            INSERT INTO rnsp_analytic_panel (rap_rnspm,
                                             rap_rnsps,
                                             rap_numident,
                                             rap_last_name,
                                             rap_phone,
                                             rap_email,
                                             rap_web,
                                             rap_ownership,
                                             rap_ownership_name,
                                             rap_org_tp,
                                             rap_org_tp_name,
                                             rap_head_fio,
                                             rap_addr_s_qty,
                                             rap_service_qty,
                                             rap_receiver_qty,
                                             RAP_ADDRESS_U_STR,
                                             RAP_ADDRESS_S_STR,
                                             RAP_SERVICES_NAMES,
                                             RAP_SERVICES_CONTENTS,
                                             RAP_SERVICES_CONTENTS2,
                                             RAP_SERVICES_SUMS)
                SELECT r.RNSPM_ID
                           RAP_RNSPM,
                       s.RNSPS_ID
                           RAP_RNSPS,
                       s.RNSPS_NUMIDENT
                           RAP_NUMIDENT,
                       s.RNSPS_LAST_NAME
                           RAP_LAST_NAME,
                       o.RNSPO_PHONE
                           RAP_PHONE,
                       o.RNSPO_EMAIL
                           RAP_EMAIL,
                       o.RNSPO_WEB
                           RAP_WEB,
                       s.rnsps_ownership
                           RAP_OWNERSHIP,
                       dow.dic_name
                           RAP_OWNERSHIP_NAME,
                       r.rnspm_org_tp
                           RAP_ORG_TP,
                       ot.DIC_NAME
                           RAP_ORG_TP_NAME,
                       uss_rnsp.Cmes$rnsp.Get_Rnsp_Head_Fio (r.RNSPM_ID)
                           RAP_HEAD_FIO,
                       (SELECT COUNT (DISTINCT ra.RNSPA_ID)
                          FROM uss_rnsp.v_rnsp_address  ra
                               JOIN uss_rnsp.v_rnsp2address r2a
                                   ON r2a.RNSP2A_RNSPA = ra.RNSPA_ID
                         WHERE     ra.RNSPA_TP = 'S'
                               AND r2a.rnsp2a_rnsps = s.RNSPS_ID)
                           RAP_ADDR_S_QTY,
                       (SELECT COUNT (DISTINCT rnspds_nst)
                          FROM uss_rnsp.v_rnsp_dict_service  ds
                               JOIN uss_rnsp.v_rnsp2service r2s
                                   ON ds.rnspds_id = r2s.rnsp2s_rnspds
                         WHERE r2s.rnsp2s_rnsps = s.RNSPS_ID)
                           RAP_SERVICE_QTY,
                       (SELECT COUNT (DISTINCT a.toas_sc)
                          FROM tctr_osp_services a
                         WHERE a.toas_rnspm = r.rnspm_id)
                           RAP_RECEIVER_QTY,
                       USS_ESR.API$ACT_ANALYTIC_PANELS.Get_Rnsp_Address_Analytic_List (
                           s.RNSPS_ID,
                           'U')
                           RAP_ADDRESS_U,
                       USS_ESR.API$ACT_ANALYTIC_PANELS.Get_Rnsp_Address_Analytic_List (
                           s.RNSPS_ID,
                           'S')
                           RAP_ADDRESS_S,
                       USS_ESR.API$ACT_ANALYTIC_PANELS.Get_Rnsp_Service_Analytic_List_Name (
                           s.RNSPS_ID),
                       SUBSTR (
                           USS_ESR.API$ACT_ANALYTIC_PANELS.Get_Rnsp_Service_Analytic_List_Content (
                               s.RNSPS_ID),
                           1,
                           4000),
                       SUBSTR (
                           USS_ESR.API$ACT_ANALYTIC_PANELS.Get_Rnsp_Service_Analytic_List_Content (
                               s.RNSPS_ID),
                           4001,
                           4000),
                       USS_ESR.API$ACT_ANALYTIC_PANELS.Get_Rnsp_Service_Analytic_List_Sum (
                           s.RNSPS_ID)
                  FROM uss_rnsp.v_rnsp_main  r
                       JOIN uss_rnsp.v_rnsp_state s
                           ON     s.RNSPS_RNSPM = r.RNSPM_ID
                              AND s.HISTORY_STATUS = 'A'
                       LEFT JOIN uss_rnsp.V_RNSP_OTHER o
                           ON s.RNSPS_RNSPO = o.RNSPO_ID
                       LEFT OUTER JOIN USS_NDI.V_DDN_RNSP_OWNERSHIP_N dow
                           ON s.rnsps_ownership = dow.dic_value
                       LEFT OUTER JOIN USS_NDI.V_DDN_RNSP_ORG_TP ot
                           ON r.rnspm_org_tp = ot.DIC_VALUE
                 WHERE 1 = 1 AND RNSPM_ST = 'A';
        END IF;

        COMMIT;
    END;
END BLD$TCTR_ANALYTIC_PANEL;
/