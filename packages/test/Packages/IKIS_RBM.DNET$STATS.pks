/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.DNET$STATS
IS
    -- Author  : SHOSTAK
    -- Created : 12/10/2021 1:09:13 PM
    -- Purpose :

    PROCEDURE Get_Request_Stats (p_Main_Cur     OUT SYS_REFCURSOR,
                                 p_Detail_Cur   OUT SYS_REFCURSOR);

    PROCEDURE Get_Inform_Stats (p_Main_Cur     OUT SYS_REFCURSOR,
                                p_Detail_Cur   OUT SYS_REFCURSOR);
END Dnet$stats;
/


GRANT EXECUTE ON IKIS_RBM.DNET$STATS TO DNET_PROXY
/

GRANT EXECUTE ON IKIS_RBM.DNET$STATS TO II01RC_RBMWEB_COMMON
/

GRANT EXECUTE ON IKIS_RBM.DNET$STATS TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 6:10:49 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.DNET$STATS
IS
    PROCEDURE Get_Request_Stats (p_Main_Cur     OUT SYS_REFCURSOR,
                                 p_Detail_Cur   OUT SYS_REFCURSOR)
    IS
        l_Start_Dt   DATE := TRUNC (SYSDATE) - 6;
    BEGIN
        tools.WriteMsg ('DNET$STATS.' || $$PLSQL_UNIT);

        OPEN p_Main_Cur FOR
              SELECT t.Urt_Id           AS Req_Type_Id,
                     CASE
                         WHEN t.Urt_Id = 9
                         THEN
                             'Збереження звернення від "ДІЯ"'
                         WHEN t.Urt_Id = 8
                         THEN
                             'Верифікація доходів в ПФУ'
                         WHEN t.Urt_Id = 3
                         THEN
                             'Верифікація доходів в ДПС'
                         WHEN t.Urt_Id = 6
                         THEN
                             'Верифікаця свідоцтва про народження в НАІС'
                         WHEN t.Urt_Id = 7
                         THEN
                             'Верифікаця свідоцтва про смерть в НАІС'
                         WHEN t.Urt_Id = 20
                         THEN
                             'Збереження звернення в системі "Соцгромада"'
                     END                AS Req_Type_Name,
                     COUNT (r.Ur_Id)    AS Req_Cnt
                FROM Uss_Ndi.v_Ndi_Uxp_Req_Types t
                     LEFT JOIN Uxp_Request r
                         ON     t.Urt_Id = r.Ur_Urt
                            AND r.Ur_Create_Dt > l_Start_Dt
                            AND r.Ur_St IN ('OK', 'ERR')
               WHERE t.Urt_Id IN (9,
                                  8,
                                  3,
                                  6,
                                  7,
                                  20)
            GROUP BY t.Urt_Id
            ORDER BY 2;

        OPEN p_Detail_Cur FOR
            WITH
                Days
                AS
                    (    SELECT TRUNC (SYSDATE) - LEVEL + 1     AS Dt
                           FROM DUAL
                     CONNECT BY LEVEL <= 7)
              SELECT t.Urt_Id                           AS Req_Type_Id,
                     TO_CHAR (d.Dt, 'dd.mm')            AS Req_Dt,
                     (SELECT COUNT (*)
                        FROM Ikis_Rbm.Uxp_Request o
                       WHERE     t.Urt_Id = o.Ur_Urt
                             AND TRUNC (o.Ur_Create_Dt) = d.Dt
                             AND o.Ur_St IN ('OK'))     AS Ok_Cnt,
                     (SELECT COUNT (*)
                        FROM Ikis_Rbm.Uxp_Request e
                       WHERE     t.Urt_Id = e.Ur_Urt
                             AND TRUNC (e.Ur_Create_Dt) = d.Dt
                             AND e.Ur_St IN ('ERR'))    AS Err_Cnt
                FROM Days d
                     JOIN Uss_Ndi.v_Ndi_Uxp_Req_Types t
                         ON t.Urt_Id IN (9,
                                         8,
                                         3,
                                         6,
                                         7,
                                         20)
            GROUP BY t.Urt_Id, d.Dt
            ORDER BY 1, d.Dt;
    END;

    PROCEDURE Get_Inform_Stats (p_Main_Cur     OUT SYS_REFCURSOR,
                                p_Detail_Cur   OUT SYS_REFCURSOR)
    IS
        l_Start_Dt   DATE := TRUNC (SYSDATE) - 9;
    BEGIN
        tools.WriteMsg ('DNET$STATS.' || $$PLSQL_UNIT);

        OPEN p_Main_Cur FOR
              SELECT t.Urt_Id           AS Req_Type_Id,
                     CASE
                         WHEN t.Urt_Id = 12
                         THEN
                             'Надання інформації щодо інформування особи'
                     END                AS Req_Type_Name,
                     COUNT (r.Ur_Id)    AS Req_Cnt
                FROM Uss_Ndi.v_Ndi_Uxp_Req_Types t
                     LEFT JOIN Uxp_Request r
                         ON     t.Urt_Id = r.Ur_Urt
                            AND r.Ur_Create_Dt > l_Start_Dt
                            AND r.Ur_St IN ('OK', 'ERR')
               WHERE t.Urt_Id IN (12)
            GROUP BY t.Urt_Id;

        OPEN p_Detail_Cur FOR
            WITH
                Days
                AS
                    (    SELECT TRUNC (SYSDATE) - LEVEL + 1     AS Dt
                           FROM DUAL
                     CONNECT BY LEVEL <= 10)
              SELECT t.Urt_Id                           AS Req_Type_Id,
                     TO_CHAR (d.Dt, 'dd.mm')            AS Req_Dt,
                     (SELECT COUNT (*)
                        FROM Ikis_Rbm.Uxp_Request o
                       WHERE     t.Urt_Id = o.Ur_Urt
                             AND TRUNC (o.Ur_Create_Dt) = d.Dt
                             AND o.Ur_St IN ('OK'))     AS Ok_Cnt,
                     (SELECT COUNT (*)
                        FROM Ikis_Rbm.Uxp_Request e
                       WHERE     t.Urt_Id = e.Ur_Urt
                             AND TRUNC (e.Ur_Create_Dt) = d.Dt
                             AND e.Ur_St IN ('ERR'))    AS Err_Cnt
                FROM Days d
                     JOIN Uss_Ndi.v_Ndi_Uxp_Req_Types t ON t.Urt_Id IN (12)
            ORDER BY 1, d.Dt;
    END;
END Dnet$stats;
/