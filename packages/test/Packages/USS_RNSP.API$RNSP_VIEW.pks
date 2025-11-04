/* Formatted on 8/12/2025 5:57:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.API$RNSP_VIEW
IS
    -- Author  : MAXYM
    -- Created : 16.06.2021 10:45:15
    -- Purpose :

    TYPE FILTER IS RECORD
    (
        RNSPM_NUM                    VARCHAR2 (50),
        RNSPM_ST                     VARCHAR2 (1),
        RNSPM_TP                     VARCHAR2 (1),
        RNSPS_NUMIDENT               VARCHAR2 (20),
        RNSPS_IS_NUMIDENT_MISSING    VARCHAR2 (1),
        RNSPS_PASS_SERIA             VARCHAR2 (10),
        RNSPS_PASS_NUM               VARCHAR2 (10),
        RNSPS_LAST_NAME              VARCHAR2 (512),
        RNSPS_FIRST_NAME             VARCHAR2 (512),
        RNSPS_NC                     NUMBER,
        RNSPO_SERVICE_LOCATION       VARCHAR2 (255),
        REGION_ID                    NUMBER,
        RNSPDS_NST                   NUMBER
    );

    -- Список за фільтром
    PROCEDURE Query (p_RNSPM_NUM                   IN     VARCHAR2,
                     p_RNSPM_ST                    IN     VARCHAR2,
                     p_RNSPM_TP                    IN     VARCHAR2,
                     p_RNSPS_NUMIDENT              IN     VARCHAR2,
                     p_RNSPS_IS_NUMIDENT_MISSING   IN     VARCHAR2,
                     p_RNSPS_PASS_SERIA            IN     VARCHAR2,
                     p_RNSPS_PASS_NUM              IN     VARCHAR2,
                     p_RNSPS_LAST_NAME             IN     VARCHAR2,
                     p_RNSPS_FIRST_NAME            IN     VARCHAR2,
                     p_RNSPS_NC                    IN     NUMBER,
                     p_RNSPO_SERVICE_LOCATION      IN     VARCHAR2,
                     p_REGION_ID                   IN     NUMBER,
                     p_RNSPDS_NST                  IN     NUMBER,
                     p_res                            OUT SYS_REFCURSOR);

    -- Історичний зріз запиту РНСП
    PROCEDURE GetState (p_RNSPS_ID          IN     rnsp_state.rnsps_id%TYPE,
                        p_main                 OUT SYS_REFCURSOR,
                        p_state                OUT SYS_REFCURSOR,
                        p_other                OUT SYS_REFCURSOR,
                        p_address              OUT SYS_REFCURSOR,
                        p_services             OUT SYS_REFCURSOR,
                        p_docs                 OUT SYS_REFCURSOR,
                        p_history              OUT SYS_REFCURSOR,
                        p_docs_history         OUT SYS_REFCURSOR,
                        p_status_register      OUT SYS_REFCURSOR,
                        p_criteria             OUT SYS_REFCURSOR);

    -- ІД активного зрізу
    FUNCTION GetActiveStateId (p_rnspm_id IN NUMBER)
        RETURN NUMBER;

    -- Перевірка що зріз історії документу знаходиться в системі
    PROCEDURE CheckDhId (p_dh_id LONG);
END API$RNSP_VIEW;
/


/* Formatted on 8/12/2025 5:57:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RNSP.API$RNSP_VIEW
IS
    -- Список за фільтром
    PROCEDURE Query (p_RNSPM_NUM                   IN     VARCHAR2,
                     p_RNSPM_ST                    IN     VARCHAR2,
                     p_RNSPM_TP                    IN     VARCHAR2,
                     p_RNSPS_NUMIDENT              IN     VARCHAR2,
                     p_RNSPS_IS_NUMIDENT_MISSING   IN     VARCHAR2,
                     p_RNSPS_PASS_SERIA            IN     VARCHAR2,
                     p_RNSPS_PASS_NUM              IN     VARCHAR2,
                     p_RNSPS_LAST_NAME             IN     VARCHAR2,
                     p_RNSPS_FIRST_NAME            IN     VARCHAR2,
                     p_RNSPS_NC                    IN     NUMBER,
                     p_RNSPO_SERVICE_LOCATION      IN     VARCHAR2,
                     p_REGION_ID                   IN     NUMBER,
                     p_RNSPDS_NST                  IN     NUMBER,
                     p_res                            OUT SYS_REFCURSOR)
    IS
        l_filter       API$RNSP_VIEW.FILTER;
        l_result_sql   VARCHAR2 (2000);
    BEGIN
        l_filter.RNSPM_NUM := p_RNSPM_NUM;
        l_filter.RNSPM_ST := p_RNSPM_ST;
        l_filter.RNSPM_TP := p_RNSPM_TP;
        l_filter.RNSPS_NUMIDENT := p_RNSPS_NUMIDENT;
        l_filter.RNSPS_IS_NUMIDENT_MISSING := p_RNSPS_IS_NUMIDENT_MISSING;
        l_filter.RNSPS_PASS_SERIA := UPPER (p_RNSPS_PASS_SERIA);
        l_filter.RNSPS_PASS_NUM := p_RNSPS_PASS_NUM;
        l_filter.RNSPS_LAST_NAME := UPPER (p_RNSPS_LAST_NAME);
        l_filter.RNSPS_FIRST_NAME := UPPER (p_RNSPS_FIRST_NAME);
        l_filter.RNSPS_NC := p_RNSPS_NC;
        l_filter.RNSPO_SERVICE_LOCATION := UPPER (p_RNSPO_SERVICE_LOCATION);
        l_filter.REGION_ID := p_REGION_ID;
        l_filter.RNSPDS_NST := p_RNSPDS_NST;

        UTIL$QUERY.BeginBuild (query      => 'select a.*
    , o.kaot_full_name region_name, o.kaot_id region_id
    , d.kaot_full_name district_name, d.kaot_id district_id
    , c.kaot_full_name city_name, c.kaot_id city_id
  from uss_rnsp.v_rnsp a
  left join uss_ndi.v_ndi_katottg c
    on a.RNSPA_KAOT = c.kaot_id
  left join uss_ndi.v_ndi_katottg o
    on c.kaot_kaot_l1 = o.kaot_id
    left join uss_ndi.v_ndi_katottg d
    on c.kaot_kaot_l2 = o.kaot_id',
                               typeName   => 'uss_rnsp.API$RNSP_VIEW.FILTER',
                               needAnd    => FALSE);
        UTIL$QUERY.AddEq (tableField   => 'RNSPM_NUM',
                          typeField    => 'RNSPM_NUM',
                          VALUE        => l_filter.RNSPM_NUM);
        UTIL$QUERY.AddEq (tableField   => 'RNSPM_ST',
                          typeField    => 'RNSPM_ST',
                          VALUE        => l_filter.RNSPM_ST);
        UTIL$QUERY.AddEq (tableField   => 'RNSPM_TP',
                          typeField    => 'RNSPM_TP',
                          VALUE        => l_filter.RNSPM_TP);
        UTIL$QUERY.AddStartWith (tableField   => 'RNSPS_NUMIDENT',
                                 typeField    => 'RNSPS_NUMIDENT',
                                 VALUE        => l_filter.RNSPS_NUMIDENT);
        UTIL$QUERY.AddEq (tableField   => 'RNSPS_IS_NUMIDENT_MISSING',
                          typeField    => 'RNSPS_IS_NUMIDENT_MISSING',
                          VALUE        => l_filter.RNSPS_IS_NUMIDENT_MISSING);
        UTIL$QUERY.AddEq (tableField   => 'RNSPS_PASS_SERIA',
                          typeField    => 'RNSPS_PASS_SERIA',
                          VALUE        => l_filter.RNSPS_PASS_SERIA);
        UTIL$QUERY.AddStartWith (tableField   => 'RNSPS_PASS_NUM',
                                 typeField    => 'RNSPS_PASS_NUM',
                                 VALUE        => l_filter.RNSPS_PASS_NUM);
        UTIL$QUERY.AddStartWith (tableField   => 'RNSPS_LAST_NAME',
                                 typeField    => 'RNSPS_LAST_NAME',
                                 VALUE        => l_filter.RNSPS_LAST_NAME);
        UTIL$QUERY.AddStartWith (tableField   => 'RNSPS_FIRST_NAME',
                                 typeField    => 'RNSPS_FIRST_NAME',
                                 VALUE        => l_filter.RNSPS_FIRST_NAME);
        UTIL$QUERY.AddEq (tableField   => 'RNSPS_NC',
                          typeField    => 'RNSPS_NC',
                          VALUE        => l_filter.RNSPS_NC);
        UTIL$QUERY.AddLike (tableField   => 'upper(RNSPO_SERVICE_LOCATION)',
                            typeField    => 'RNSPO_SERVICE_LOCATION',
                            VALUE        => l_filter.RNSPO_SERVICE_LOCATION);
        UTIL$QUERY.AddEq (tableField   => 'o.KAOT_ID',
                          typeField    => 'REGION_ID',
                          VALUE        => l_filter.REGION_ID);

        UTIL$QUERY.AddFromTemplate (
            template    =>
                'exists (select 1 from uss_rnsp.rnsp_dict_service,uss_rnsp.rnsp2service
        where rnsp2s_rnspds = rnspds_id and rnsp2s_rnsps = rnsps_id and rnspds_nst=<param>)',
            typeField   => 'RNSPDS_NST',
            VALUE       => l_filter.RNSPDS_NST);

        UTIL$QUERY.GetResultSql (l_result_sql);

        EXECUTE IMMEDIATE l_result_sql
            USING l_filter, OUT p_res;
    END;

    PROCEDURE internalGetMain (p_rnspm_id   IN     NUMBER,
                               p_ap_id      IN     NUMBER,
                               p_res           OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR SELECT t.*, p_ap_id AS ap_id
                         FROM rnsp_main t
                        WHERE rnspm_id = p_rnspm_id;
    END;

    PROCEDURE internalGetState (p_rnsps_id   IN     NUMBER,
                                p_res           OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT s.*,
                   h.hs_dt,
                   u.wu_id,
                   u.wu_login,
                   u.wu_pib
              FROM rnsp_state  s
                   JOIN HISTSESSION h ON h.hs_id = RNSPS_HS
                   LEFT JOIN ikis_sysweb.V$ALL_USERS u ON u.wu_id = h.hs_wu
             WHERE s.rnsps_id = p_rnsps_id;
    END;

    PROCEDURE internalGetDocs (p_rnsps_id IN NUMBER, p_res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR SELECT rnsp2d_dh
                         FROM rnsp2doc
                        WHERE rnsp2d_rnsps = p_rnsps_id;
    END;

    PROCEDURE internalGetDocsHistory (p_rnspm_id   IN     NUMBER,
                                      p_res           OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT DISTINCT rnsp2d_dh
              FROM rnsp_state INNER JOIN rnsp2doc ON rnsp2d_rnsps = rnsps_id
             WHERE rnsps_rnspm = p_rnspm_id;
    END;

    PROCEDURE internalGetHistory (p_rnspm_id   IN     NUMBER,
                                  p_res           OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
              SELECT s.*,
                     h.hs_dt,
                     u.wu_id,
                     u.wu_login,
                     u.wu_pib
                FROM rnsp_state s
                     JOIN HISTSESSION h ON h.hs_id = RNSPS_HS
                     LEFT JOIN ikis_sysweb.V$ALL_USERS u ON u.wu_id = h.hs_wu
               WHERE s.rnsps_rnspm = p_rnspm_id
            ORDER BY rnsps_id DESC;
    END;

    PROCEDURE internalGetCriteriaList (p_rnspm_id   IN     NUMBER,
                                       p_ap_id      IN     NUMBER,
                                       res_cur         OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT t.aprl_id,
                   t.aprl_nrr,
                   rr.nrr_name     AS aprl_nrr_name,
                   t.aprl_Calc_Result,
                   t.aprl_Result
              FROM ap_right_log  t
                   JOIN uss_ndi.v_ndi_right_rule rr
                       ON (rr.nrr_id = t.aprl_nrr)
             WHERE t.aprl_aps IN
                       (SELECT z.aps_id
                          FROM ap_service z
                         WHERE z.aps_ap = p_ap_id AND z.history_status = 'A');
    END;

    PROCEDURE GetState (p_RNSPS_ID          IN     rnsp_state.rnsps_id%TYPE,
                        p_main                 OUT SYS_REFCURSOR,
                        p_state                OUT SYS_REFCURSOR,
                        p_other                OUT SYS_REFCURSOR,
                        p_address              OUT SYS_REFCURSOR,
                        p_services             OUT SYS_REFCURSOR,
                        p_docs                 OUT SYS_REFCURSOR,
                        p_history              OUT SYS_REFCURSOR,
                        p_docs_history         OUT SYS_REFCURSOR,
                        p_status_register      OUT SYS_REFCURSOR,
                        p_criteria             OUT SYS_REFCURSOR)
    IS
        l_main_id      NUMBER;
        l_address_id   NUMBER;
        l_other_id     NUMBER;
        l_ap_id        NUMBER;
    BEGIN
        SELECT rnsps_rnspm, rnsps_rnspa, rnsps_rnspo
          INTO l_main_id, l_address_id, l_other_id
          FROM rnsp_state
         WHERE rnsps_id = p_rnsps_id;

        SELECT MAX (t.ap_id)
          INTO l_ap_id
          FROM v_appeal t
         WHERE t.ap_ext_ident = l_main_id AND t.ap_st NOT IN ('X', 'V');

        internalGetMain (p_rnspm_id   => l_main_id,
                         p_ap_id      => l_ap_id,
                         p_res        => p_main);
        internalGetState (p_rnsps_id => p_rnsps_id, p_res => p_state);
        priv$rnsp_other.Get (p_id => l_other_id, p_res => p_other);
        priv$rnsp_address.Get (p_id => l_address_id, p_res => p_address);
        PRIV$RNSP_DICT_SERVICE.Query (p_RNSPS_id   => p_rnsps_id,
                                      p_res        => p_services);
        internalGetDocs (p_rnsps_id => p_rnsps_id, p_res => p_docs);
        internalGetHistory (p_rnspm_id => l_main_id, p_res => p_history);
        internalGetDocsHistory (p_rnspm_id   => l_main_id,
                                p_res        => p_docs_history);
        priv$rnsp_status_register.query (
            p_rnspsr_rnspm   => l_main_id,
            p_res            => p_status_register);

        internalGetCriteriaList (p_rnspm_id   => l_main_id,
                                 p_ap_id      => l_ap_id,
                                 res_cur      => p_criteria);
    END;

    FUNCTION GetActiveStateId (p_rnspm_id IN NUMBER)
        RETURN NUMBER
    IS
        l_res   NUMBER;
    BEGIN
        SELECT rnsps_id
          INTO l_res
          FROM rnsp_state
         WHERE rnsps_rnspm = p_rnspm_id AND HISTORY_STATUS = 'A';

        RETURN l_res;
    END;

    -- Перевірка що зріз історії документу знаходиться в системі
    PROCEDURE CheckDhId (p_dh_id LONG)
    IS
        l_id   NUMBER;
    BEGIN
        SELECT rnsp2d_rnsps
          INTO l_id
          FROM rnsp2doc
         WHERE rnsp2d_dh = p_dh_id AND ROWNUM < 2;
    END;
BEGIN
    NULL;
END API$RNSP_VIEW;
/