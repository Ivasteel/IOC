/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$CHART
IS
    -- Author  : BOGDAN
    -- Created : 02.08.2022 12:38:55
    -- Purpose : Звіти в вигляді графіків


    -- #79006: Форма "Активність користувачів"
    PROCEDURE GET_USER_ACTIVITY (P_DT             IN     DATE,
                                 P_ONLY_GATEWAY   IN     VARCHAR2 := 'T',
                                 res_cur             OUT SYS_REFCURSOR);
END DNET$CHART;
/


GRANT EXECUTE ON USS_ESR.DNET$CHART TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$CHART TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:29 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$CHART
IS
    g_msp_host_ip   VARCHAR2 (100) := '10.2.0.13';

    -- #79006: Форма "Активність користувачів"
    PROCEDURE GET_USER_ACTIVITY (P_DT             IN     DATE,
                                 P_ONLY_GATEWAY   IN     VARCHAR2 := 'T',
                                 res_cur             OUT SYS_REFCURSOR)
    IS
        l_only_gateway   VARCHAR2 (10);
    BEGIN
        IF P_ONLY_GATEWAY = 'F'
        THEN
            l_only_gateway := 'F';
        ELSE
            l_only_gateway := 'T';
        END IF;

        OPEN res_cur FOR
            WITH
                minute_list
                AS
                    (    SELECT x_Start + LEVEL / (24 * 60)     AS x_minute
                           FROM (SELECT p_dt                       /* + 3/24*/
                                             AS x_start FROM DUAL)
                     CONNECT BY LEVEL <= 1440),
                log_minutes
                AS
                    (  SELECT TRUNC (z.iua_date, 'MI')          AS x_log_minute,
                              COUNT (z.iua_id)                  AS x_count,
                              COUNT (DISTINCT iua_web_user)     AS x_user_count
                         FROM ikis_sys.v_ikis_user_activity z
                        WHERE     z.iua_date BETWEEN TRUNC (p_dt)
                                                 AND   TRUNC (p_dt)
                                                     + 86399 / 86400
                              AND (   (    l_only_gateway = 'T'
                                       AND iua_ip = g_msp_host_ip)
                                   OR l_only_gateway = 'F')
                     GROUP BY TRUNC (z.iua_date, 'MI'))
              SELECT TO_CHAR (m.x_minute, 'HH24:mi')     AS x_axis,
                     /*m.x_minute AS x_axis_alt,*/
                     m.x_minute,
                     NVL (d.x_count, 0)                  AS y_axis,
                     NVL (d.x_user_count, 0)             AS y_axis_user
                FROM minute_list m, log_minutes d
               WHERE x_minute = x_log_minute(+)
            ORDER BY m.x_minute;
    END;
BEGIN
    NULL;
END DNET$CHART;
/