/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$UTILS
IS
    -- Author  : BOGDAN
    -- Created : 25.06.2021 11:26:44
    -- Purpose : Утиліти, версії та інше

    -- список утиліт, документації та релізів на перегляд
    PROCEDURE get_site_info (utils      OUT SYS_REFCURSOR,
                             docs       OUT SYS_REFCURSOR,
                             versions   OUT SYS_REFCURSOR,
                             study      OUT SYS_REFCURSOR);

    -- #75740: к-ство файлов по типам
    PROCEDURE get_site_quick_info (p_res_cur OUT SYS_REFCURSOR);

    -- вивантаження файлу
    PROCEDURE get_file (p_av_id IN NUMBER, p_file_cur OUT SYS_REFCURSOR);

    -- поточна версія утиліти сканування
    PROCEDURE get_agent_version (p_version OUT VARCHAR2);

    -- Логування при підпису
    PROCEDURE WRITE_CRYPTO_LOG (p_event_tp IN VARCHAR2, p_event_info IN CLOB);


    -- #89516
    PROCEDURE get_rtfl_list (p_start_dt   IN     DATE,
                             p_stop_dt    IN     DATE,
                             p_rt_id      IN     NUMBER,
                             p_org_id     IN     NUMBER,
                             res_cur         OUT SYS_REFCURSOR);
END DNET$UTILS;
/


GRANT EXECUTE ON USS_ESR.DNET$UTILS TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$UTILS TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:56 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$UTILS
IS
    -- список утиліт, документації та релізів на перегляд
    PROCEDURE get_site_info (utils      OUT SYS_REFCURSOR,
                             docs       OUT SYS_REFCURSOR,
                             versions   OUT SYS_REFCURSOR,
                             study      OUT SYS_REFCURSOR)
    IS
    BEGIN
        ikis_sys.ikis_app_info.get_site_info ('USS_ESR',
                                              utils,
                                              docs,
                                              versions,
                                              study);
    END;

    -- #75740: к-ство файлов по типам
    PROCEDURE get_site_quick_info (p_res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        ikis_sys.ikis_app_info.get_site_quick_info ('USS_ESR', p_res_cur);
    END;

    -- вивантаження файлу
    PROCEDURE get_file (p_av_id IN NUMBER, p_file_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        ikis_sys.ikis_app_info.get_file ('USS_ESR', p_av_id, p_file_cur);
    END;

    -- поточна версія утиліти сканування
    PROCEDURE get_agent_version (p_version OUT VARCHAR2)
    IS
    BEGIN
        ikis_sys.ikis_app_info.get_agent_version ('USS_ESR', p_version);
    END;

    -- Логування при підпису
    PROCEDURE WRITE_CRYPTO_LOG (p_event_tp IN VARCHAR2, p_event_info IN CLOB)
    IS
        l_id   NUMBER;
    BEGIN
        l_id :=
            IKIS_SYSWEB.write_crypto_log (p_event_tp,
                                          p_event_info,
                                          tools.GetCurrWu);
    END;

    -- #89516
    PROCEDURE get_rtfl_list (p_start_dt   IN     DATE,
                             p_stop_dt    IN     DATE,
                             p_rt_id      IN     NUMBER,
                             p_org_id     IN     NUMBER,
                             res_cur         OUT SYS_REFCURSOR)
    IS
        l_org   NUMBER := tools.GetCurrOrg;
    BEGIN
        OPEN res_cur FOR
              SELECT *
                FROM (SELECT jbr_id,
                             jbr_ss_code,
                             jbr_user,
                             jbr_app_ident,
                             jbr_rpt_code,
                             jbr_status,
                             jbr_start_dt,
                             jbr_stop_dt,
                             jbr_tmpl_id,
                             rt.rt_name    AS jbr_rpt_code_name,
                             CASE
                                 WHEN t.jbr_status = 'READY' THEN 'В процесі'
                                 WHEN t.jbr_status = 'ENDED' THEN 'Побудовано'
                                 WHEN t.jbr_status = 'ERROR' THEN 'Помилка'
                             END           AS jbr_status_name,
                             CASE
                                 WHEN     l_org = u.WU_ORG
                                      AND t.jbr_status = 'ENDED'
                                 THEN
                                     1
                                 ELSE
                                     0
                             END           AS can_download
                        FROM ikis_sysweb.v_w_jobs_reports t
                             JOIN rpt_templates rt
                                 ON (rt.rt_code = t.jbr_rpt_code)
                             JOIN ikis_sysweb.v$all_users u
                                 ON (u.WU_LOGIN = t.jbr_user)
                       WHERE     1 = 1
                             AND TRUNC (t.jbr_start_dt) BETWEEN p_start_dt
                                                            AND p_stop_dt
                             AND t.jbr_ss_code = 'USS_ESR'
                             AND rt.rt_file_tp NOT IN ('SQL')
                             AND (P_RT_ID IS NULL OR rt.rt_id = P_RT_ID)
                             AND (       p_org_id IS NULL
                                     AND u.wu_ORg IN
                                             (SELECT u_org FROM tmp_org)
                                  OR u.WU_ORG = p_org_id)) t
               WHERE ROWNUM <= 500
            ORDER BY t.jbr_start_dt;
    END;
BEGIN
    NULL;
END DNET$UTILS;
/