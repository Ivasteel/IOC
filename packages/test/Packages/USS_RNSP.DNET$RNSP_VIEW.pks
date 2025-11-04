/* Formatted on 8/12/2025 5:57:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.DNET$RNSP_VIEW
IS
    -- Author  : VANO
    -- Created : 14.04.2022 15:54:17
    -- Purpose : Запити для отримання даних по реєстру

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
        RNSPDS_NST                   NUMBER,
        IS_MAIN                      NUMBER
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
                     p_is_main                     IN     NUMBER,
                     p_res                            OUT SYS_REFCURSOR);


    -- Список за фільтром на виключення
    PROCEDURE get_exclusion_list (
        p_RNSPM_NUM                   IN     VARCHAR2,
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
        p_is_main                     IN     NUMBER,
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
                        -- p_criteria        out sys_refcursor,
                        p_appeal_log           OUT SYS_REFCURSOR /*,
                              p_address1         out SYS_REFCURSOR,
                              p_address2        out SYS_REFCURSOR,
                              p_address3        out SYS_REFCURSOR,
                              p_address4        out SYS_REFCURSOR*/
                                                                );


    PROCEDURE GetCriteriaList (p_ap_id IN NUMBER, res_cur OUT SYS_REFCURSOR);

    -- ІД активного зрізу
    FUNCTION GetActiveStateId (p_rnspm_id IN NUMBER)
        RETURN NUMBER;

    -- Перевірка що зріз історії документу знаходиться в системі
    PROCEDURE CheckDhId (p_dh_id LONG);

    -- #80965
    PROCEDURE GET_FILIA_LIST (p_rnspm_id   IN     NUMBER,
                              RES_CUR         OUT SYS_REFCURSOR);

    --==========================================================--
    FUNCTION GetAddress_Index (p_rnspa_id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION GetAddress (p_rnspa_id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION GetAddress_Index (p_rnsps_id   IN NUMBER,
                               p_rnspa_tp      VARCHAR2,
                               p_rn            NUMBER)
        RETURN VARCHAR2;

    FUNCTION GetAddress (p_rnsps_id   IN NUMBER,
                         p_rnspa_tp      VARCHAR2,
                         p_rn            NUMBER)
        RETURN VARCHAR2;


    FUNCTION GetIsService (p_RNSPS_ID NUMBER, p_nst_code VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION xml_replace (val VARCHAR2)
        RETURN VARCHAR2;
END DNET$RNSP_VIEW;
/


GRANT EXECUTE ON USS_RNSP.DNET$RNSP_VIEW TO DNET_PROXY
/

GRANT EXECUTE ON USS_RNSP.DNET$RNSP_VIEW TO II01RC_USS_RNSP_WEB
/

GRANT EXECUTE ON USS_RNSP.DNET$RNSP_VIEW TO LMOSTOVENKO
/


/* Formatted on 8/12/2025 5:58:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RNSP.DNET$RNSP_VIEW
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
                     p_is_main                     IN     NUMBER,
                     p_res                            OUT SYS_REFCURSOR)
    IS
        l_filter       DNET$RNSP_VIEW.FILTER;
        l_result_sql   VARCHAR2 (2000);
    BEGIN
        tools.WriteMsg ('DNET$RNSP_VIEW.' || $$PLSQL_UNIT);
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
        l_filter.IS_MAIN := p_is_main;

        UTIL$QUERY.BeginBuild (query      => 'select a.*
    , o.kaot_full_name region_name, o.kaot_id region_id
    , d.kaot_full_name district_name, d.kaot_id district_id
    , c.kaot_full_name city_name, c.kaot_id city_id
    , otp.dic_name as rnspm_org_tp_name
  from uss_rnsp.v_rnsp a
  left join uss_ndi.v_ndi_katottg c
    on a.RNSPA_KAOT = c.kaot_id
  left join uss_ndi.v_ndi_katottg o
    on c.kaot_kaot_l1 = o.kaot_id
    left join uss_ndi.v_ndi_katottg d
    on c.kaot_kaot_l2 = d.kaot_id
  left join uss_ndi.v_ddn_rnsp_org_tp otp on (otp.dic_value = a.rnspm_org_tp)
    ',
                               typeName   => 'uss_rnsp.DNET$RNSP_VIEW.FILTER',
                               needAnd    => FALSE);
        UTIL$QUERY.AddEq (tableField   => 'RNSPM_NUM',
                          typeField    => 'RNSPM_NUM',
                          VALUE        => l_filter.RNSPM_NUM);

        UTIL$QUERY.AddFromTemplate (template    => 'rnspm_st != ''N''',
                                    typeField   => 'rnspm_st',
                                    VALUE       => 'N');
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
                CASE
                    WHEN p_is_main = 0 THEN ' a.rnspm_org_tp = ''PR'' '
                    ELSE '1=1'
                END,
            typeField   => 'p_is_main',
            VALUE       => l_filter.IS_MAIN);

        UTIL$QUERY.AddFromTemplate (
            template    =>
                'exists (select 1 from uss_rnsp.rnsp_dict_service,uss_rnsp.rnsp2service
        where rnsp2s_rnspds = rnspds_id and rnsp2s_rnsps = rnsps_id and rnspds_nst=<param>)',
            typeField   => 'RNSPDS_NST',
            VALUE       => l_filter.RNSPDS_NST);
        UTIL$QUERY.AddRowNum (500);
        UTIL$QUERY.GetResultSql (l_result_sql);

        --raise_application_error(-20000, l_result_sql);


        EXECUTE IMMEDIATE l_result_sql
            USING l_filter, OUT p_res;
    END;

    -- Список за фільтром на виключення
    PROCEDURE get_exclusion_list (
        p_RNSPM_NUM                   IN     VARCHAR2,
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
        p_is_main                     IN     NUMBER,
        p_res                            OUT SYS_REFCURSOR)
    IS
        l_filter       DNET$RNSP_VIEW.FILTER;
        l_result_sql   VARCHAR2 (2000);
    BEGIN
        tools.WriteMsg ('DNET$RNSP_VIEW.' || $$PLSQL_UNIT);
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
        l_filter.IS_MAIN := p_is_main;

        UTIL$QUERY.BeginBuild (query      => 'select a.*
    , o.kaot_full_name region_name, o.kaot_id region_id
    , d.kaot_full_name district_name, d.kaot_id district_id
    , c.kaot_full_name city_name, c.kaot_id city_id
    , otp.dic_name as rnspm_org_tp_name
  from uss_rnsp.v_rnsp a
  left join uss_ndi.v_ndi_katottg c
    on a.RNSPA_KAOT = c.kaot_id
  left join uss_ndi.v_ndi_katottg o
    on c.kaot_kaot_l1 = o.kaot_id
    left join uss_ndi.v_ndi_katottg d
    on c.kaot_kaot_l2 = d.kaot_id
  left join uss_ndi.v_ddn_rnsp_org_tp otp on (otp.dic_value = a.rnspm_org_tp)
    ',
                               typeName   => 'uss_rnsp.DNET$RNSP_VIEW.FILTER',
                               needAnd    => FALSE);
        UTIL$QUERY.AddEq (tableField   => 'RNSPM_NUM',
                          typeField    => 'RNSPM_NUM',
                          VALUE        => l_filter.RNSPM_NUM);

        UTIL$QUERY.AddFromTemplate (template    => 'rnspm_st != ''N''',
                                    typeField   => 'rnspm_st',
                                    VALUE       => 'N');
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
                CASE
                    WHEN p_is_main = 0 THEN ' a.rnspm_org_tp = ''PR'' '
                    ELSE '1=1'
                END,
            typeField   => 'p_is_main',
            VALUE       => l_filter.IS_MAIN);

        UTIL$QUERY.AddFromTemplate (
            template    =>
                'exists (select 1 from uss_rnsp.rnsp_dict_service,uss_rnsp.rnsp2service
        where rnsp2s_rnspds = rnspds_id and rnsp2s_rnsps = rnsps_id and rnspds_nst=<param>)',
            typeField   => 'RNSPDS_NST',
            VALUE       => l_filter.RNSPDS_NST);

        UTIL$QUERY.AddFromTemplate (
            template    =>
                'exists (select * from uss_rnsp.v_rn_document z
       where z.rnd_RNSPM = a.rnspm_id and z.rnd_ap is null and z.rnd_ndt = 730 and z.rnd_st not in (''V'', ''X''))',
            typeField   => 'p_is_main',
            VALUE       => l_filter.IS_MAIN);


        UTIL$QUERY.AddRowNum (500);
        UTIL$QUERY.GetResultSql (l_result_sql);

        --raise_application_error(-20000, l_result_sql);

        EXECUTE IMMEDIATE l_result_sql
            USING l_filter, OUT p_res;
    END;

    PROCEDURE internalGetMain (p_rnspm_id     IN     NUMBER,
                               p_ap_id        IN     NUMBER,
                               p_ap_st        IN     VARCHAR2,
                               p_ap_com_wu    IN     NUMBER,
                               p_ap_com_org   IN     NUMBER,
                               p_res             OUT SYS_REFCURSOR)
    IS
        l_wu   NUMBER := tools.getcurrwu;
    BEGIN
        OPEN p_res FOR
            SELECT t.*,
                   p_ap_id
                       AS ap_id,
                   p_ap_st
                       AS ap_st,
                   p_ap_com_wu
                       AS Ap_Com_Wu,
                   p_ap_com_org
                       AS Ap_Com_org,
                   (SELECT CASE
                               WHEN COUNT (*) > 0 THEN 'T'
                               ELSE 'F'
                           END
                      FROM v_rn_document  zd
                           LEFT JOIN v_rn_document_attr r
                               ON (    r.rnda_rnd = zd.rnd_id
                                   AND r.rnda_nda = 1114
                                   AND r.history_status = 'A')      -- Рішення
                           LEFT JOIN v_rn_document_attr p
                               ON (    p.rnda_rnd = zd.rnd_id
                                   AND p.rnda_nda = 1115
                                   AND p.history_status = 'A') -- Підстави прийняття рішення про повернення на доопрацювання
                     WHERE     zd.rnd_ap = p_ap_id
                           AND zd.rnd_ndt = 730
                           AND r.rnda_val_string = 'P'
                           AND p.rnda_val_string IS NOT NULL
                           AND zd.history_status = 'A')
                       AS can_return_string,
                   (SELECT CASE WHEN COUNT (*) = 0 THEN 'T' ELSE 'F' END
                      FROM v_rn_document zd
                     WHERE     zd.rnd_ap IS NULL
                           AND zd.rnd_RNSPM = t.rnspm_id
                           AND zd.history_status = 'A'-- and z.rnd_st not in ('V', 'X')
                                                      )
                       AS can_Close_String,
                   CASE WHEN l_wu = p_ap_com_wu THEN 'T' ELSE 'F' END
                       AS Can_Edit_String
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
                   u.wu_pib,
                   os.DIC_NAME                         AS rnsps_ownership_name,
                   NVL (es.DIC_NAME, 'Не отримано')    AS rnsps_edr_state_name
              FROM rnsp_state  s
                   JOIN HISTSESSION h ON h.hs_id = RNSPS_HS
                   LEFT JOIN ikis_sysweb.V$ALL_USERS u ON u.wu_id = h.hs_wu
                   LEFT JOIN uss_ndi.V_DDN_RNSP_OWNERSHIP_N os
                       ON (os.DIC_VALUE = s.rnsps_ownership)
                   LEFT JOIN uss_ndi.v_ddn_rnsps_edr_state es
                       ON es.DIC_VALUE = s.rnsps_edr_state
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

    PROCEDURE GetCriteriaList (p_ap_id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
              SELECT t.aprl_id,
                     t.aprl_nrr,
                     rr.nrr_name     AS aprl_nrr_name,
                     t.aprl_Calc_Result,
                     t.aprl_Result,
                     st.nst_name
                FROM ap_right_log t
                     JOIN uss_ndi.v_ndi_right_rule rr
                         ON (rr.nrr_id = t.aprl_nrr)
                     JOIN ap_service s ON (s.aps_id = t.aprl_aps)
                     JOIN uss_ndi.v_ndi_service_type st
                         ON (st.nst_id = s.aps_nst)
               WHERE t.aprl_aps IN
                         (SELECT z.aps_id
                            FROM ap_service z
                           WHERE z.aps_ap = p_ap_id AND z.history_status = 'A')
            ORDER BY t.aprl_id;
    END;

    PROCEDURE Get_Ap_Log (p_Ap_Id            Appeal.Ap_Id%TYPE,
                          p_Log_Cursor   OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.WriteMsg ('Dnet$appeal.Get_Ap_Log');

        OPEN p_Log_Cursor FOR
              SELECT Apl_Id,
                     Apl_Tp,
                     Hs_Dt,
                     o.Dic_Name                                         AS Old_Status_Name,
                     n.Dic_Name                                         AS New_Status_Name,
                     CASE
                         WHEN INSTR (Apl_Message, '#', 1) > 0
                         THEN
                             SUBSTR (Apl_Message,
                                     INSTR (Apl_Message, '#', 1) + 1)
                         ELSE
                             Uss_Ndi.Rdm$msg_Template.Getmessagetext (
                                 Apl_Message)
                     END                                                AS Apl_Message,
                     NVL (Tools.Getuserlogin (Hs_Wu), 'Автоматично')    AS Apl_Hs_Author
                FROM v_Appeal,
                     v_Ap_Log,
                     Uss_Ndi.v_Ddn_Ap_St n,
                     Uss_Ndi.v_Ddn_Ap_St o,
                     Histsession
               WHERE     Apl_St = n.Dic_Value(+)
                     AND Apl_St_Old = o.Dic_Value(+)
                     AND Apl_Hs = Hs_Id(+)
                     AND Apl_Ap = Ap_Id
                     AND Apl_Ap = p_Ap_Id
            ORDER BY Hs_Dt, Apl_Id;
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
                        -- p_criteria        out sys_refcursor,
                        p_appeal_log           OUT SYS_REFCURSOR /*,
                              p_address1        out SYS_REFCURSOR,
                              p_address2        out SYS_REFCURSOR,
                              p_address3        out SYS_REFCURSOR,
                              p_address4        out SYS_REFCURSOR*/
                                                                )
    IS
        l_main_id       NUMBER;
        l_address_id    NUMBER;
        l_address_id1   NUMBER;
        l_address_id2   NUMBER;
        l_address_id3   NUMBER;
        l_address_id4   NUMBER;
        l_other_id      NUMBER;
        l_ap_id         NUMBER;
        l_com_wu        NUMBER;
        l_com_org       NUMBER;
        l_ap_st         VARCHAR2 (10);
    BEGIN
        tools.WriteMsg ('DNET$RNSP_VIEW.' || $$PLSQL_UNIT);

        SELECT rnsps_rnspm,                                   /*rnsps_rnspa,*/
                            rnsps_rnspo --, rnsps_rnspa1, t.rnsps_rnspa2, t.rnsps_rnspa3, t.rnsps_rnspa4
          INTO l_main_id,                                    /*l_address_id,*/
                          l_other_id --, l_address_id1, l_address_id2, l_address_id3, l_address_id4
          FROM rnsp_state t
         WHERE rnsps_id = p_rnsps_id;

        BEGIN
            /*SELECT t.ap_id, t.ap_st, t.com_wu
              into l_ap_id, l_ap_st, l_com_wu
              FROM v_appeal t
             where t.ap_ext_ident = l_main_id
              ORDER BY t.ap_id DESC
              FETCH FIRST ROW ONLY
               --and t.ap_st not in ('X', 'V')
               ;*/
            SELECT t.ap_id,
                   t.ap_st,
                   t.com_wu,
                   t.com_org
              INTO l_ap_id,
                   l_ap_st,
                   l_com_wu,
                   l_com_org
              FROM v_appeal t JOIN rnsp_main m ON (m.rnspm_ap_edit = t.ap_id)
             WHERE m.rnspm_id = l_main_id
             FETCH FIRST ROW ONLY;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        internalGetMain (p_rnspm_id     => l_main_id,
                         p_ap_id        => l_ap_id,
                         p_ap_st        => l_ap_st,
                         p_ap_com_wu    => l_com_wu,
                         p_ap_com_org   => l_com_org,
                         p_res          => p_main);
        internalGetState (p_rnsps_id => p_rnsps_id, p_res => p_state);
        priv$rnsp_other.Get (p_id => l_other_id, p_res => p_other);

        priv$rnsp_address.Get_List (p_rnsps_id   => p_RNSPS_ID,
                                    p_res        => p_address);
        /*priv$rnsp_address.Get(p_id => l_address_id, p_res => p_address);
        priv$rnsp_address.Get(p_id => l_address_id1, p_res => p_address1);
        priv$rnsp_address.Get(p_id => l_address_id2, p_res => p_address2);
        priv$rnsp_address.Get(p_id => l_address_id3, p_res => p_address3);
        priv$rnsp_address.Get(p_id => l_address_id4, p_res => p_address4);*/

        PRIV$RNSP_DICT_SERVICE.Query (p_RNSPS_id   => p_rnsps_id,
                                      p_res        => p_services);
        internalGetDocs (p_rnsps_id => p_rnsps_id, p_res => p_docs);
        internalGetHistory (p_rnspm_id => l_main_id, p_res => p_history);
        internalGetDocsHistory (p_rnspm_id   => l_main_id,
                                p_res        => p_docs_history);
        priv$rnsp_status_register.query (
            p_rnspsr_rnspm   => l_main_id,
            p_res            => p_status_register);

        /* GetCriteriaList(
                                 p_ap_id    => l_ap_id,
                                 res_cur    => p_criteria);*/

        Get_Ap_Log (l_ap_id, p_appeal_log);
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


    -- #80965
    PROCEDURE GET_FILIA_LIST (p_rnspm_id   IN     NUMBER,
                              RES_CUR         OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN RES_CUR FOR
            SELECT t.rnspm_id,
                   t.rnspm_chapter,
                   s.rnsps_last_name                  AS filial_name,
                   (SELECT MAX (az.rnda_val_string)
                      FROM v_appeal  tz
                           JOIN v_rn_document dz
                               ON (dz.rnd_ap = tz.ap_id)
                           JOIN v_rn_document_attr az
                               ON (az.rnda_rnd = dz.rnd_id)
                     WHERE     tz.ap_ext_ident = t.rnspm_id
                           AND dz.rnd_ndt = 700
                           AND az.rnda_nda = 2451)    AS filial_code,
                   (SELECT FIRST_VALUE (
                                  CASE
                                      WHEN     l1_name IS NOT NULL
                                           AND l1_name != kaot_name
                                      THEN
                                          l1_name || ', '
                                  END
                               || CASE
                                      WHEN     l2_name IS NOT NULL
                                           AND l2_name != kaot_name
                                      THEN
                                          l2_name || ', '
                                  END
                               || CASE
                                      WHEN     l3_name IS NOT NULL
                                           AND l3_name != kaot_name
                                      THEN
                                          l3_name || ', '
                                  END
                               || CASE
                                      WHEN     l4_name IS NOT NULL
                                           AND l4_name != kaot_name
                                      THEN
                                          l4_name || ', '
                                  END
                               || CASE
                                      WHEN     l5_name IS NOT NULL
                                           AND l5_name != kaot_name
                                      THEN
                                          l5_name || ', '
                                  END
                               || temp_name
                               || ', '
                               || part)
                               OVER (ORDER BY rnspa_id ASC)
                      FROM (SELECT    ''
                                   || CASE
                                          WHEN d.rnspa_street IS NOT NULL
                                          THEN
                                              ' ' || d.rnspa_street
                                      END
                                   || CASE
                                          WHEN d.rnspa_building IS NOT NULL
                                          THEN
                                              ', буд. ' || d.rnspa_building
                                      END
                                   || CASE
                                          WHEN d.rnspa_korp IS NOT NULL
                                          THEN
                                              ', к. ' || d.rnspa_korp
                                      END
                                   || CASE
                                          WHEN d.rnspa_appartement
                                                   IS NOT NULL
                                          THEN
                                              ', кв. ' || d.rnspa_appartement
                                      END              AS part,
                                   CASE
                                       WHEN Kaot_Kaot_L1 = Kaot_Id
                                       THEN
                                           Kaot_Name
                                       ELSE
                                           (SELECT X1.KAOT_FULL_NAME
                                              FROM uss_ndi.v_Ndi_Katottg X1
                                             WHERE X1.Kaot_Id =
                                                   k.Kaot_Kaot_L1)
                                   END                 AS l1_name,
                                   CASE
                                       WHEN Kaot_Kaot_L2 = Kaot_Id
                                       THEN
                                           Kaot_Name
                                       ELSE
                                           (SELECT X1.KAOT_FULL_NAME
                                              FROM uss_ndi.v_Ndi_Katottg X1
                                             WHERE X1.Kaot_Id =
                                                   k.Kaot_Kaot_L2)
                                   END                 AS l2_name,
                                   CASE
                                       WHEN Kaot_Kaot_L3 = Kaot_Id
                                       THEN
                                           Kaot_Name
                                       ELSE
                                           (SELECT X1.KAOT_FULL_NAME
                                              FROM uss_ndi.v_Ndi_Katottg X1
                                             WHERE X1.Kaot_Id =
                                                   k.Kaot_Kaot_L3)
                                   END                 AS l3_name,
                                   CASE
                                       WHEN Kaot_Kaot_L4 = Kaot_Id
                                       THEN
                                           Kaot_Name
                                       ELSE
                                           (SELECT X1.KAOT_FULL_NAME
                                              FROM uss_ndi.v_Ndi_Katottg X1
                                             WHERE X1.Kaot_Id =
                                                   k.Kaot_Kaot_L4)
                                   END                 AS l4_name,
                                   CASE
                                       WHEN Kaot_Kaot_L5 = Kaot_Id
                                       THEN
                                           Kaot_Name
                                       ELSE
                                           (SELECT X1.KAOT_FULL_NAME
                                              FROM uss_ndi.v_Ndi_Katottg X1
                                             WHERE X1.Kaot_Id =
                                                   k.Kaot_Kaot_L5)
                                   END                 AS l5_name,
                                   k.kaot_name,
                                   k.kaot_full_name    AS temp_name,
                                   d.rnspa_id
                              FROM rnsp_address  d
                                   JOIN rnsp2address sd
                                       ON (sd.rnsp2a_rnspa = d.rnspa_id)
                                   LEFT JOIN uss_ndi.v_ndi_katottg k
                                       ON (k.kaot_id = d.rnspa_kaot)
                             WHERE     sd.rnsp2a_rnsps = s.rnsps_id
                                   AND NVL (d.rnspa_tp, 'S') = 'S')
                     FETCH FIRST ROW ONLY)            AS Address
              FROM rnsp_main  t
                   JOIN rnsp_state s
                       ON (    s.rnsps_rnspm = t.rnspm_id
                           AND s.history_status = 'A')
             WHERE t.rnspm_rnspm = p_rnspm_id;
    END;

    --==========================================================--
    FUNCTION GetAddress_Index (p_rnspa_id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_ret   VARCHAR2 (2000);
    BEGIN
        SELECT MAX (a.Rnspa_Index)
          INTO l_ret
          FROM uss_rnsp.rnsp_address a
         WHERE a.RNSPA_ID = p_rnspa_id;

        RETURN l_ret;
    END;

    --==========================================================--
    FUNCTION GetAddress (p_rnspa_id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_ret   VARCHAR2 (2000);
    BEGIN
        SELECT MAX (
                      CASE
                          WHEN l1_name IS NOT NULL AND l1_name != kaot_name
                          THEN
                              l1_name || ', '
                      END
                   || CASE
                          WHEN l2_name IS NOT NULL AND l2_name != kaot_name
                          THEN
                              l2_name || ', '
                      END
                   || CASE
                          WHEN l3_name IS NOT NULL AND l3_name != kaot_name
                          THEN
                              l3_name || ', '
                      END
                   || CASE
                          WHEN l4_name IS NOT NULL AND l4_name != kaot_name
                          THEN
                              l4_name || ', '
                      END
                   || CASE
                          WHEN l5_name IS NOT NULL AND l5_name != kaot_name
                          THEN
                              l5_name || ', '
                      END
                   || temp_name
                   || ', '
                   || part)
          INTO l_ret
          FROM (SELECT    CASE
                              WHEN TRIM (d.rnspa_street) IS NOT NULL
                              THEN
                                  ' ' || d.rnspa_street
                          END
                       || CASE
                              WHEN TRIM (d.rnspa_building) IS NOT NULL
                              THEN
                                  ', буд. ' || d.rnspa_building
                          END
                       || CASE
                              WHEN TRIM (d.rnspa_korp) IS NOT NULL
                              THEN
                                  ', к. ' || d.rnspa_korp
                          END
                       || CASE
                              WHEN TRIM (d.rnspa_appartement) IS NOT NULL
                              THEN
                                  ', кв. ' || d.rnspa_appartement
                          END              AS part,
                       CASE
                           WHEN k.Kaot_Kaot_L1 = k.Kaot_Id THEN k.Kaot_Name
                           ELSE L1.KAOT_FULL_NAME
                       END                 AS l1_name,
                       CASE
                           WHEN k.Kaot_Kaot_L2 = k.Kaot_Id THEN k.Kaot_Name
                           ELSE L2.KAOT_FULL_NAME
                       END                 AS l2_name,
                       CASE
                           WHEN k.Kaot_Kaot_L3 = k.Kaot_Id THEN k.Kaot_Name
                           ELSE L3.KAOT_FULL_NAME
                       END                 AS l3_name,
                       CASE
                           WHEN k.Kaot_Kaot_L4 = k.Kaot_Id THEN k.Kaot_Name
                           ELSE L4.KAOT_FULL_NAME
                       END                 AS l4_name,
                       CASE
                           WHEN k.Kaot_Kaot_L5 = k.Kaot_Id THEN k.Kaot_Name
                           ELSE L5.KAOT_FULL_NAME
                       END                 AS l5_name,
                       k.kaot_name,
                       k.kaot_full_name    AS temp_name
                  FROM rnsp_address  d
                       LEFT JOIN uss_ndi.v_ndi_katottg k
                           ON (k.kaot_id = d.rnspa_kaot)
                       LEFT JOIN uss_ndi.v_ndi_katottg L1
                           ON L1.Kaot_Id = k.Kaot_Kaot_L1
                       LEFT JOIN uss_ndi.v_ndi_katottg L2
                           ON L2.Kaot_Id = k.Kaot_Kaot_L2
                       LEFT JOIN uss_ndi.v_ndi_katottg L3
                           ON L3.Kaot_Id = k.Kaot_Kaot_L3
                       LEFT JOIN uss_ndi.v_ndi_katottg L4
                           ON L4.Kaot_Id = k.Kaot_Kaot_L4
                       LEFT JOIN uss_ndi.v_ndi_katottg L5
                           ON L5.Kaot_Id = k.Kaot_Kaot_L5
                 WHERE d.rnspa_id = p_rnspa_id);

        RETURN l_ret;
    END;

    --==========================================================--
    FUNCTION GetAddress_Index (p_rnsps_id   IN NUMBER,
                               p_rnspa_tp      VARCHAR2,
                               p_rn            NUMBER)
        RETURN VARCHAR2
    IS
        l_rnspa_id   NUMBER;
    BEGIN
        SELECT MAX (rnspa_id)
          INTO l_rnspa_id
          FROM (SELECT a.rnspa_id,
                       ROW_NUMBER ()
                           OVER (PARTITION BY s2a.rnsp2a_rnsps, a.rnspa_tp
                                 ORDER BY a.rnspa_id ASC)    AS rn
                  FROM rnsp2address  s2a
                       JOIN rnsp_address a ON a.rnspa_id = s2a.rnsp2a_rnspa
                 WHERE     s2a.rnsp2a_rnsps = p_rnsps_id
                       AND a.rnspa_tp = p_rnspa_tp)
         WHERE rn = p_rn;

        RETURN GetAddress_Index (l_rnspa_id);
    END;

    --==========================================================--
    FUNCTION GetAddress (p_rnsps_id   IN NUMBER,
                         p_rnspa_tp      VARCHAR2,
                         p_rn            NUMBER)
        RETURN VARCHAR2
    IS
        l_rnspa_id   NUMBER;
    BEGIN
        SELECT MAX (rnspa_id)
          INTO l_rnspa_id
          FROM (SELECT a.rnspa_id,
                       ROW_NUMBER ()
                           OVER (PARTITION BY s2a.rnsp2a_rnsps, a.rnspa_tp
                                 ORDER BY a.rnspa_id ASC)    AS rn
                  FROM rnsp2address  s2a
                       JOIN rnsp_address a ON a.rnspa_id = s2a.rnsp2a_rnspa
                 WHERE     s2a.rnsp2a_rnsps = p_rnsps_id
                       AND a.rnspa_tp = p_rnspa_tp)
         WHERE rn = p_rn;

        RETURN GetAddress (l_rnspa_id);
    END;

    --==========================================================--
    FUNCTION GetIsService (p_RNSPS_ID NUMBER, p_nst_code VARCHAR2)
        RETURN VARCHAR2
    IS
        l_ret   VARCHAR2 (2000);
    BEGIN
        SELECT CASE WHEN COUNT (1) > 0 THEN 'Так' ELSE 'Ні' END
          INTO l_ret
          FROM rnsp_dict_service  s
               JOIN rnsp2service r2s ON r2s.rnsp2s_rnspds = s.rnspds_id
               JOIN uss_ndi.v_ndi_service_type nst ON nst_id = s.rnspds_nst
         WHERE r2s.rnsp2s_rnsps = p_RNSPS_ID AND nst.nst_code = p_nst_code;

        RETURN l_ret;
    END;

    --==========================================================--
    FUNCTION xml_replace (val VARCHAR2)
        RETURN VARCHAR2
    IS
        ret   VARCHAR2 (2000) := val;
    BEGIN
        ret := REPLACE (ret, '&', '&amp;');
        ret := REPLACE (ret, '''', '&apos;');
        ret := REPLACE (ret, '"', '&quot;');
        ret := REPLACE (ret, '>', '&gt;');
        ret := REPLACE (ret, '<', '&lt;');
        RETURN ret;
    END;
--==========================================================--
END DNET$RNSP_VIEW;
/