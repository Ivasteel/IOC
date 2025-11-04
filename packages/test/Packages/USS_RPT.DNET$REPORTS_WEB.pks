/* Formatted on 8/12/2025 5:58:56 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RPT.DNET$REPORTS_WEB
IS
    -- Author  : BOGDAN
    -- Created : 09.02.2022 16:54:27
    -- Purpose :

    PROCEDURE GET_REPORTS_LIST (P_NRG_ID     IN     NUMBER,
                                P_RT_ID      IN     NUMBER,
                                P_ST_CODE    IN     VARCHAR2,
                                P_ORG        IN     NUMBER,
                                P_DT_START   IN     DATE,
                                P_DT_STOP    IN     DATE,
                                p_ncs_id     IN     NUMBER,
                                p_nst_id     IN     NUMBER,
                                RES_CUR         OUT SYS_REFCURSOR);

    PROCEDURE GET_REPORT_HIST_LIST (P_RPT_ID   IN     NUMBER,
                                    RES_CUR       OUT SYS_REFCURSOR);

    PROCEDURE GET_REPORT_PARAMS_LIST (P_RPT_ID   IN     NUMBER,
                                      RES_CUR       OUT SYS_REFCURSOR);

    PROCEDURE GET_FILE (P_RPT_ID IN NUMBER, RES_CUR OUT SYS_REFCURSOR);

    PROCEDURE BUILD_REPORT (P_JB            OUT NUMBER,
                            P_RT_ID      IN     NUMBER,
                            P_RPT_TP     IN     VARCHAR2,
                            P_ORG        IN     NUMBER DEFAULT 28000,
                            P_DT_START   IN     DATE,
                            P_DT_STOP    IN     DATE,
                            P_AP_TP      IN     VARCHAR2 DEFAULT NULL,
                            P_AP_NST     IN     NUMBER DEFAULT NULL,
                            p_src_tp     IN     VARCHAR2 DEFAULT NULL,
                            P_NCS_ID     IN     NUMBER DEFAULT NULL);

    PROCEDURE CHECK_JOB_STATUS (P_JB_ID IN NUMBER, P_JB_STATUS OUT VARCHAR2);

    PROCEDURE GET_JOB_INFO (P_JB_ID         IN     NUMBER,
                            RES_CUR            OUT SYS_REFCURSOR,
                            PROTOCOL_INFO      OUT SYS_REFCURSOR);

    -- опис: курсор вертає значанення T або F , для параметрів побудови звіту
    -- за якими блокуються поля в веб інтерфейсі, та примітку що до особливостей побудови звіту
    PROCEDURE GET_PARAMS_ACCESS_STATUS (P_RT_ID   IN     NUMBER,
                                        RES_CUR      OUT SYS_REFCURSOR);
END DNET$REPORTS_WEB;
/


GRANT EXECUTE ON USS_RPT.DNET$REPORTS_WEB TO DNET_PROXY
/

GRANT EXECUTE ON USS_RPT.DNET$REPORTS_WEB TO II01RC_USS_RPT_WEB
/


/* Formatted on 8/12/2025 5:59:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RPT.DNET$REPORTS_WEB
IS
    PROCEDURE GET_REPORTS_LIST (P_NRG_ID     IN     NUMBER,
                                P_RT_ID      IN     NUMBER,
                                P_ST_CODE    IN     VARCHAR2,
                                P_ORG        IN     NUMBER,
                                P_DT_START   IN     DATE,
                                P_DT_STOP    IN     DATE,
                                p_ncs_id     IN     NUMBER,
                                p_nst_id     IN     NUMBER,
                                RES_CUR         OUT SYS_REFCURSOR)
    IS
        sql_q        VARCHAR2 (20000)
            :=    'SELECT
                                    row_number() over(ORDER BY r.rpt_dt DESC) rn,
                                    r.rpt_id,
                                    nrt.rt_name,
                                    nrg.nrg_name,
                                    drs.DIC_NAME rpt_st_name,
                                    r.rpt_dt,
                                    r.com_org,
                                    wu.wu_login  rpt_user_login
                              FROM USS_RPT.V_REPORTS r
                              LEFT JOIN uss_ndi.v_ddn_rpt_st drs ON (drs.DIC_CODE = r.rpt_st)
                              LEFT JOIN uss_ndi.V_NDI_REPORT_TYPE nrt ON (nrt.rt_id = r.rpt_rt)
                              LEFT JOIN uss_ndi.V_NDI_RPT_GROUP nrg ON (nrg.nrg_id = nrt.rt_nrg)
                              LEFT JOIN ikis_sysweb.v$w_users_4gic wu ON (wu.wu_id = r.com_wu)
                              WHERE 1 = 1
                                AND ('
               || NVL (P_ORG,
                       uss_rpt_CONTEXT.GetContext (uss_rpt_CONTEXT.gOPFU))
               || ' = 50000 or r.com_org = '
               || NVL (P_ORG,
                       uss_rpt_CONTEXT.GetContext (uss_rpt_CONTEXT.gOPFU))
               || ')
                                AND ROWNUM <= 500 ';
        sql_params   VARCHAR2 (10000);
    BEGIN
        --USS_RPT.USS_RPT_CONTEXT.SetDnetRptContext(uss_esr.USS_ESR_CONTEXT.GetContext('SESSION'));
        IF P_NRG_ID IS NOT NULL
        THEN
            sql_params :=
                sql_params || 'AND nrg.nrg_id = ' || P_NRG_ID || ' ';
        END IF;

        IF P_RT_ID IS NOT NULL
        THEN
            sql_params := sql_params || 'AND nrt.rt_id = ' || P_RT_ID || ' ';
        END IF;

        IF P_ST_CODE IS NOT NULL
        THEN
            sql_params :=
                sql_params || 'AND r.rpt_st = ''' || P_ST_CODE || ''' ';
        END IF;

        IF P_DT_START IS NOT NULL
        THEN
            sql_params :=
                   sql_params
                || 'AND trunc(r.rpt_dt) >= to_date('''
                || TO_CHAR (P_DT_START, 'DD.MM.YYYY')
                || ''', ''DD.MM.YYYY'') ';
        END IF;

        IF P_DT_STOP IS NOT NULL
        THEN
            sql_params :=
                   sql_params
                || 'AND trunc(r.rpt_dt) <= to_date('''
                || TO_CHAR (P_DT_STOP, 'DD.MM.YYYY')
                || ''', ''DD.MM.YYYY'') ';
        END IF;

        IF p_ncs_id IS NOT NULL
        THEN
            sql_params :=
                   sql_params
                || 'AND exists (select * from rpt_params z
                                                  join uss_ndi.v_ndi_rpt_params zp on (zp.nrp_id = z.rp_nrp)
                                                 where z.rp_rpt = r.rpt_id and zp.nrp_code = ''CHILD'' and z.rp_numvalue = '
                || p_ncs_id
                || ') ';
        END IF;

        IF p_nst_id IS NOT NULL
        THEN
            sql_params :=
                   sql_params
                || 'AND exists (select * from rpt_params z
                                                  join uss_ndi.v_ndi_rpt_params zp on (zp.nrp_id = z.rp_nrp)
                                                 where z.rp_rpt = r.rpt_id and zp.nrp_code = ''AP_NST'' and z.rp_numvalue = '
                || p_nst_id
                || ') ';
        END IF;

        sql_q := sql_q || sql_params;

        --raise_application_error(-20000, sql_q);
        OPEN RES_CUR FOR sql_q;
    END;

    PROCEDURE GET_REPORT_HIST_LIST (P_RPT_ID   IN     NUMBER,
                                    RES_CUR       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN RES_CUR FOR
            SELECT ROWNUM                         rn,
                   rh.rh_id,
                   rh.rh_dt,
                   drs.DIC_SNAME                  rh_st,
                   (SELECT MAX (z.wu_login)
                      FROM ikis_sysweb.v$w_users_4gic z
                     WHERE z.wu_id = rh.rh_wu)    AS rh_user_login,
                   rat.DIC_SNAME                  rh_action,
                   rh.rh_info
              FROM uss_rpt.v_rpt_hist  rh
                   LEFT JOIN uss_ndi.v_ddn_rpt_st drs
                       ON drs.DIC_CODE = rh.rh_rpt_st
                   LEFT JOIN uss_ndi.v_ddn_rpt_action_tp rat
                       ON rat.DIC_CODE = rh.rh_action_tp
             WHERE rh.rh_rpt = P_RPT_ID;
    END;

    PROCEDURE GET_REPORT_PARAMS_LIST (P_RPT_ID   IN     NUMBER,
                                      RES_CUR       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN RES_CUR FOR
            SELECT nrp_name    AS NAME,
                   CASE nrp_data_tp
                       WHEN 'N'
                       THEN
                           CASE
                               WHEN p.rp_numvalue IS NULL THEN '-'
                               ELSE TO_CHAR (p.rp_numvalue)
                           END
                       WHEN 'C'
                       THEN
                           CASE
                               WHEN p.rp_charvalue IS NULL THEN '-'
                               ELSE p.rp_charvalue
                           END
                       WHEN 'D'
                       THEN
                           CASE
                               WHEN p.rp_datevalue IS NULL THEN '-'
                               ELSE TO_CHAR (p.rp_datevalue, 'dd.mm.yyyy')
                           END
                   END         AS caption
              FROM uss_rpt.v_rpt_params  p
                   JOIN uss_ndi.v_ndi_rpt_params np ON nrp_id = rp_nrp
             WHERE rp_rpt = P_RPT_ID;
    END;

    PROCEDURE GET_FILE (P_RPT_ID IN NUMBER, RES_CUR OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN RES_CUR FOR SELECT f.rf_id,
                                f.rf_name                      AS filename,
                                f.rf_data                      AS content,
                                'application/octet-stream'     AS mimetype
                           FROM uss_rpt.v_rpt_files f
                          WHERE f.rf_rpt = P_RPT_ID;
    END;

    PROCEDURE BUILD_REPORT (P_JB            OUT NUMBER,
                            P_RT_ID      IN     NUMBER,
                            P_RPT_TP     IN     VARCHAR2,
                            P_ORG        IN     NUMBER DEFAULT 28000,
                            P_DT_START   IN     DATE,
                            P_DT_STOP    IN     DATE,
                            P_AP_TP      IN     VARCHAR2 DEFAULT NULL,
                            P_AP_NST     IN     NUMBER DEFAULT NULL,
                            p_src_tp     IN     VARCHAR2 DEFAULT NULL,
                            P_NCS_ID     IN     NUMBER DEFAULT NULL)
    IS
        l_nrt_id        NUMBER;
        l_wu_id         NUMBER;
        l_rpt_name      VARCHAR2 (250);
        l_rpt_has_org   NUMBER;
        l_default_org   NUMBER := 50000;
    BEGIN
        SELECT nrt.rt_id,
               nrt.rt_name,
               (SELECT COUNT (*)
                  FROM Uss_Ndi.v_Ndi_Rpt_Params
                 WHERE Nrp_Rt = nrt.rt_id AND Nrp_Code = 'ORG')
          INTO l_nrt_id, l_rpt_name, l_rpt_has_org
          FROM uss_ndi.v_ndi_report_type nrt
         WHERE nrt.rt_id = P_RT_id;

        l_wu_id := uss_rpt_CONTEXT.GetContext (uss_rpt_CONTEXT.gUID);

        IF l_rpt_has_org > 0
        THEN
            l_default_org := NVL (Tools.GetCurrOrg, 50000);
        END IF;

        --raise_application_error( -20000, P_RPT_TP);
        --raise_application_error(-20000, 'l_nrt_id='||l_nrt_id||';l_wu_id='||l_wu_id);
        IF api$rpt_common.check_rpt_user (p_wu_id       => l_wu_id,
                                          p_rt_id       => l_nrt_id,
                                          p_access_tp   => 'CRT')
        THEN
            -------------Submit Schedule
            ikis_sysweb.ikis_sysweb_schedule.SubmitSchedule (
                p_jb            => p_jb,
                p_subsys        => 'USS_RPT',
                p_wjt           => 'BUILD_REPORT',
                P_SCHEMA_NAME   => 'USS_RPT',
                p_what          =>
                    CASE
                        WHEN P_RT_ID IN (-1         /* 'MFRECMON', 'MFRECAN'*/
                                           )
                        THEN
                            'uss_rpt.api$rpt_BUILDER.build_report_xls'
                        WHEN P_RPT_TP = 'CSV'
                        THEN
                            'uss_rpt.api$rpt_BUILDER.build_report'
                        WHEN P_RPT_TP = 'XML-Excel'
                        THEN
                            'uss_rpt.api$rpt_BUILDER.build_report_xls'
                        ELSE
                            'uss_rpt.api$rpt_BUILDER.build_report'
                    END);                                                -----

            ----------------------Add params
            ikis_sysweb.ikis_sysweb_schedule.AddJobParam (
                p_jb_id             => p_jb,
                p_sjp_Name          => 'p_rt_id',
                p_sjp_Value         => '' || l_nrt_id || '',
                p_sjp_Type          => 'NUMBER',
                p_sjp_Format        => NULL,
                p_sjp_Req           => 1,
                p_ReplaceExisting   => FALSE);

            ikis_sysweb.ikis_sysweb_schedule.AddJobParam (
                p_jb_id             => p_jb,
                p_sjp_Name          => 'p_org',
                p_sjp_Value         => '' || NVL (p_org, l_default_org) || '',
                p_sjp_Type          => 'NUMBER',
                p_sjp_Format        => NULL,
                p_sjp_Req           => 1,
                p_ReplaceExisting   => FALSE);

            ikis_sysweb.ikis_sysweb_schedule.AddJobParam (
                p_jb_id             => p_jb,
                p_sjp_Name          => 'p_start_dt',
                p_sjp_Value         =>
                    TO_CHAR (
                        NVL (P_DT_START, ADD_MONTHS (TRUNC (SYSDATE), -12)),
                        'DD.MM.YYYY'),
                p_sjp_Type          => 'DATE',
                p_sjp_Format        => 'DD.MM.YYYY',
                p_sjp_Req           => 1,
                p_ReplaceExisting   => FALSE);

            ikis_sysweb.ikis_sysweb_schedule.AddJobParam (
                p_jb_id             => p_jb,
                p_sjp_Name          => 'p_stop_dt',
                p_sjp_Value         =>
                    TO_CHAR (NVL (P_DT_STOP, TRUNC (SYSDATE)), 'DD.MM.YYYY'),
                p_sjp_Type          => 'DATE',
                p_sjp_Format        => 'DD.MM.YYYY',
                p_sjp_Req           => 1,
                p_ReplaceExisting   => FALSE);

            -- #79113 нові параметри
            -- тип звернення
            ikis_sysweb.ikis_sysweb_schedule.AddJobParam (
                p_jb_id             => p_jb,
                p_sjp_Name          => 'p_ap_tp',
                p_sjp_Value         => '' || p_ap_tp || '',
                p_sjp_Type          => 'VARCHAR2',
                p_sjp_Format        => NULL,
                p_sjp_Req           => 1,
                p_ReplaceExisting   => FALSE);

            -- тип послуги
            ikis_sysweb.ikis_sysweb_schedule.AddJobParam (
                p_jb_id             => p_jb,
                p_sjp_Name          => 'p_ap_nst',
                p_sjp_Value         => '' || p_ap_nst || '',
                p_sjp_Type          => 'NUMBER',
                p_sjp_Format        => NULL,
                p_sjp_Req           => 1,
                p_ReplaceExisting   => FALSE);

            -- Система, до якої передано звернення на опрацювання
            ikis_sysweb.ikis_sysweb_schedule.AddJobParam (
                p_jb_id             => p_jb,
                p_sjp_Name          => 'p_src_tp',
                p_sjp_Value         => '' || p_src_tp || '',
                p_sjp_Type          => 'VARCHAR2',
                p_sjp_Format        => NULL,
                p_sjp_Req           => 1,
                p_ReplaceExisting   => FALSE);

            -- служба у справах дітей
            ikis_sysweb.ikis_sysweb_schedule.AddJobParam (
                p_jb_id             => p_jb,
                p_sjp_Name          => 'p_ncs_id',
                p_sjp_Value         => '' || P_NCS_ID || '',
                p_sjp_Type          => 'NUMBER',
                p_sjp_Format        => NULL,
                p_sjp_Req           => 1,
                p_ReplaceExisting   => FALSE);


            ikis_sysweb.ikis_sysweb_schedule.AddJobParam (
                p_jb_id             => p_jb,
                p_sjp_Name          => 'p_jb',
                p_sjp_Value         => '' || p_jb || '',
                p_sjp_Type          => 'NUMBER',
                p_sjp_Format        => NULL,
                p_sjp_Req           => 1,
                p_ReplaceExisting   => FALSE);


            ikis_sysweb.ikis_sysweb_schedule.AddJobParam (
                p_jb_id             => p_jb,
                p_sjp_Name          => 'p_wu',
                p_sjp_Value         => '' || l_wu_id || '',
                p_sjp_Type          => 'NUMBER',
                p_sjp_Format        => NULL,
                p_sjp_Req           => 1,
                p_ReplaceExisting   => FALSE);

            ----------------------------

            ikis_sysweb.ikis_sysweb_schedule.EnableJob_Univ (p_jb);
        -------------------
        ELSE
            raise_application_error (
                -20000,
                   'Для побудови звіту '''
                || l_rpt_name
                || '''  недостатньо прав доступу!');
        END IF;
    END;

    PROCEDURE CHECK_JOB_STATUS (P_JB_ID IN NUMBER, P_JB_STATUS OUT VARCHAR2)
    IS
    BEGIN
        P_JB_STATUS := ikis_sysweb.ikis_sysweb_jobs.GetJobStatus (P_JB_ID);
    END;

    PROCEDURE GET_JOB_INFO (P_JB_ID         IN     NUMBER,
                            RES_CUR            OUT SYS_REFCURSOR,
                            PROTOCOL_INFO      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN RES_CUR FOR
            SELECT t.jb_start_dt     start_dt,
                   t.jb_stop_dt      stop_dt,
                   st.DIC_NAME       status,
                   t.jb_id           job,
                   t.jb_status       status_code,
                   r.rpt_id          AS entity_id
              FROM v_w_jobs_univ  t
                   LEFT JOIN v_ddn_wjb_st st ON (st.DIC_VALUE = t.jb_status)
                   LEFT JOIN uss_rpt.reports r ON r.rpt_jb = t.jb_id
             WHERE t.jb_id = P_JB_ID;

        OPEN PROTOCOL_INFO FOR
              SELECT x1.*,
                     x2.*,
                     DECODE (X2.jm_tp,
                             'I', 'ІНФО',
                             'E', 'ПОМИЛКА',
                             'W', 'ПОПЕРЕДЖЕННЯ',
                             '-')    MES_TP_STR
                FROM --+ YAP 20081201 другие полиси тут будут v_w_jobs x1,
                     v_w_jobs_univ x1,                        --- YAP 20081201
                                       ikis_sysweb.v_w_jobs_protocol x2
               WHERE x1.jb_id = x2.jm_jb AND x1.jb_id = P_JB_ID
            ORDER BY x2.jm_ts;
    END;

    -- опис: курсор вертає значанення T або F , для параметрів побудови звіту
    -- за якими блокуються поля в веб інтерфейсі, та примітку що до особливостей побудови звіту
    PROCEDURE GET_PARAMS_ACCESS_STATUS (P_RT_ID   IN     NUMBER,
                                        RES_CUR      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN RES_CUR FOR
            SELECT MAX (
                       CASE
                           WHEN p.nrp_code = 'ORG' AND nrt.rt_id > 0 THEN 'T'
                           ELSE 'F'
                       END)             isOrg,
                   MAX (
                       CASE
                           WHEN p.nrp_code = 'START' AND nrt.rt_id > 0
                           THEN
                               'T'
                           ELSE
                               'F'
                       END)             isDtStart,
                   MAX (
                       CASE
                           WHEN p.nrp_code = 'STOP' AND nrt.rt_id > 0
                           THEN
                               'T'
                           ELSE
                               'F'
                       END)             isDtStop,
                   MAX (
                       CASE
                           WHEN p.nrp_code = 'AP_TP' AND nrt.rt_id > 0
                           THEN
                               'T'
                           ELSE
                               'F'
                       END)             IsApTp,
                   MAX (
                       CASE
                           WHEN p.nrp_code = 'AP_NST' AND nrt.rt_id > 0
                           THEN
                               'T'
                           ELSE
                               'F'
                       END)             IsApNst,
                   MAX (
                       CASE
                           WHEN p.nrp_code = 'CHILD' AND nrt.rt_id > 0
                           THEN
                               'T'
                           ELSE
                               'F'
                       END)             isChild,
                   MAX (nrt.rt_desc)    description
              FROM uss_ndi.v_ndi_rpt_params  p
                   JOIN uss_ndi.v_ndi_report_type nrt ON nrt.rt_id = p.nrp_rt
             WHERE nrt.rt_id = P_RT_ID;
    END;
BEGIN
    NULL;
END DNET$REPORTS_WEB;
/