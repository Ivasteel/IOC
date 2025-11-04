/* Formatted on 8/12/2025 6:06:30 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_FINZVIT.FINZVIT_AGGR
IS
    -- Author  : MAXYM
    -- Created : 26.10.2017 15:46:12
    -- Purpose : Агрегація пакетів звітності

    PROCEDURE GetPacksToInclude (p_RP_ID_DST   IN     rpt_pack.rp_id%TYPE,
                                 p_res            OUT SYS_REFCURSOR);


    PROCEDURE IncludePack (p_RP_ID_DST       IN rpt_pack.rp_id%TYPE,
                           p_CAHNGE_TS_DST   IN rpt_pack.Change_Ts%TYPE,
                           p_RP_ID_SRC       IN rpt_pack.rp_id%TYPE,
                           P_ALG             IN ST_AGGR_ALG.SV_ID%TYPE);

    PROCEDURE ExcludePack (p_RP_ID_DST       IN rpt_pack.rp_id%TYPE,
                           p_CAHNGE_TS_DST   IN rpt_pack.Change_Ts%TYPE,
                           p_RP_ID_SRC       IN rpt_pack.rp_id%TYPE,
                           p_comment         IN VARCHAR2);


    PROCEDURE GetIncluded (p_RPT_ID   IN     report.rpt_id%TYPE,
                           p_res         OUT SYS_REFCURSOR);
END FINZVIT_AGGR;
/


GRANT EXECUTE ON IKIS_FINZVIT.FINZVIT_AGGR TO DNET_PROXY
/


/* Formatted on 8/12/2025 6:06:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_FINZVIT.FINZVIT_AGGR
IS
    PROCEDURE IncludePack (p_RP_ID_DST       IN rpt_pack.rp_id%TYPE,
                           p_CAHNGE_TS_DST   IN rpt_pack.Change_Ts%TYPE,
                           p_RP_ID_SRC       IN rpt_pack.rp_id%TYPE,
                           P_ALG             IN ST_AGGR_ALG.SV_ID%TYPE)
    IS
        l_apt_id   NUMBER;
    BEGIN
        finzvit_report.CheckCanChangePacketAndLock (
            p_rp_id       => p_RP_ID_DST,
            p_change_ts   => p_CAHNGE_TS_DST);

        BEGIN
            SELECT apt_id
              INTO l_apt_id
              FROM aggr_pack_template  a
                   JOIN V_RPT_PACK dst ON dst.RP_PT = a.apt_pt_dest
                   JOIN V_RPT_PACK src ON src.RP_PT = a.apt_pt_src
             WHERE     dst.RP_ID = p_RP_ID_DST
                   AND a.apt_alg = p_ALG
                   AND src.RP_ID = p_RP_ID_SRC
                   AND src.RP_STATUS = 'V'                          -- Поданий
                   AND EXISTS
                           (SELECT *
                              FROM v_opfu o
                             WHERE     o.org_id = src.COM_ORG
                                   AND o.org_org = dst.COM_ORG);
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                raise_application_error (
                    -20000,
                       'Не можливо консолідувати пакети '
                    || p_RP_ID_DST
                    || ' та '
                    || p_RP_ID_SRC);
        END;

        INSERT INTO aggr_pack (ap_rp_dest, ap_rp_src, ap_apt)
             VALUES (p_RP_ID_DST, p_RP_ID_SRC, l_apt_id);

        FINZVIT_PACK_STATUS.ChangeStatus (p_rp_id       => p_RP_ID_SRC,
                                          p_rp_status   => 'I');
    END;

    PROCEDURE ExcludePack (p_RP_ID_DST       IN rpt_pack.rp_id%TYPE,
                           p_CAHNGE_TS_DST   IN rpt_pack.Change_Ts%TYPE,
                           p_RP_ID_SRC       IN rpt_pack.rp_id%TYPE,
                           p_comment         IN VARCHAR2)
    IS
        l_agg_id   NUMBER;
    BEGIN
        finzvit_report.CheckCanChangePacketAndLock (
            p_rp_id       => p_RP_ID_DST,
            p_change_ts   => p_CAHNGE_TS_DST);

        DELETE FROM aggr_pack
              WHERE ap_rp_dest = p_RP_ID_DST AND ap_rp_src = p_RP_ID_SRC;

        IF SQL%ROWCOUNT = 0
        THEN
            raise_application_error (
                -20000,
                   'Пекет '
                || p_RP_ID_SRC
                || ' не консалідован в '
                || p_RP_ID_DST);
        END IF;

        FINZVIT_PACK_STATUS.ChangeStatus (p_rp_id         => p_RP_ID_SRC,
                                          p_rp_status     => 'F',
                                          p_rpj_comment   => p_comment);
    END;

    PROCEDURE GetPacksToInclude (p_RP_ID_DST   IN     rpt_pack.rp_id%TYPE,
                                 p_res            OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT src.RP_ID, src.RP_PT, ap.apt_alg
              FROM V_RPT_PACK  pd
                   JOIN aggr_pack_template ap ON ap.apt_pt_dest = pd.RP_PT
                   JOIN V_OPFU opfu ON opfu.org_org = pd.COM_ORG
                   JOIN V_RPT_PACK src
                       ON     src.COM_ORG = opfu.org_id
                          AND src.RP_PT = ap.apt_pt_src
                          AND src.rp_start_period_dt = pd.RP_START_PERIOD_DT
                          AND pd.RP_TP = src.RP_TP
                          AND src.RP_STATUS = 'V'
             WHERE pd.RP_ID = p_RP_ID_DST;
    END;


    PROCEDURE GetIncluded (p_RPT_ID   IN     report.rpt_id%TYPE,
                           p_res         OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
              SELECT *
                FROM v_aggr_reports ar
               WHERE     ar.RPT_ID_DEST = p_rpt_id
                     AND ar.RP_ID_SRC IS NOT NULL
                     AND ar.RP_STATUS_SRC IN ('I', 'A')
            ORDER BY ar.org_code;
    END;
END FINZVIT_AGGR;
/