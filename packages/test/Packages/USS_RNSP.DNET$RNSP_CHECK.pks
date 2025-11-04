/* Formatted on 8/12/2025 5:57:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.DNET$RNSP_CHECK
IS
    -- Author  : VANO
    -- Created : 14.04.2022 15:29:26
    -- Purpose :

    PROCEDURE Get (p_id IN RNSP_CHECK.RNSPC_ID%TYPE, p_res OUT SYS_REFCURSOR);

    PROCEDURE Save (p_RNSPC_ID      IN     RNSP_CHECK.RNSPC_ID%TYPE,
                    p_RNSPC_RNSPM   IN     RNSP_CHECK.RNSPC_RNSPM%TYPE,
                    p_RNSPC_RES     IN     RNSP_CHECK.RNSPC_RES%TYPE,
                    p_RNSPC_INFO    IN     RNSP_CHECK.RNSPC_INFO%TYPE,
                    p_RNSPC_DATE    IN     RNSP_CHECK.RNSPC_DATE%TYPE,
                    p_rnspc_name    IN     RNSP_CHECK.rnspc_name%TYPE,
                    p_new_id           OUT RNSP_CHECK.RNSPC_ID%TYPE);

    PROCEDURE Delete (p_id RNSP_CHECK.RNSPC_ID%TYPE);

    PROCEDURE Query (p_RNSPC_RNSPM IN NUMBER, p_res OUT SYS_REFCURSOR);
END DNET$RNSP_CHECK;
/


GRANT EXECUTE ON USS_RNSP.DNET$RNSP_CHECK TO DNET_PROXY
/

GRANT EXECUTE ON USS_RNSP.DNET$RNSP_CHECK TO II01RC_USS_RNSP_WEB
/


/* Formatted on 8/12/2025 5:58:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RNSP.DNET$RNSP_CHECK
IS
    PROCEDURE Get (p_id IN RNSP_CHECK.RNSPC_ID%TYPE, p_res OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.WriteMsg ('DNET$RNSP_CHECK.' || $$PLSQL_UNIT);

        OPEN p_res FOR
            SELECT RNSPC_ID,
                   -- RNSP_MAIN
                   RNSPC_RNSPM,
                   RNSPC_RES,
                   RNSPC_INFO,
                   RNSPC_DATE,
                   RNSPC_NAME,
                   r.DIC_NAME     AS RNSPC_RES_NAME
              FROM RNSP_CHECK  t
                   JOIN uss_ndi.v_ddn_rnsp_res r ON r.DIC_VALUE = RNSPC_RES
             WHERE RNSPC_ID = p_id;
    END;

    PROCEDURE Save (p_RNSPC_ID      IN     RNSP_CHECK.RNSPC_ID%TYPE,
                    p_RNSPC_RNSPM   IN     RNSP_CHECK.RNSPC_RNSPM%TYPE,
                    p_RNSPC_RES     IN     RNSP_CHECK.RNSPC_RES%TYPE,
                    p_RNSPC_INFO    IN     RNSP_CHECK.RNSPC_INFO%TYPE,
                    p_RNSPC_DATE    IN     RNSP_CHECK.RNSPC_DATE%TYPE,
                    p_rnspc_name    IN     RNSP_CHECK.rnspc_name%TYPE,
                    p_new_id           OUT RNSP_CHECK.RNSPC_ID%TYPE)
    IS
    BEGIN
        API$RNSP_CHECK.Save (p_rnspc_id,
                             p_rnspc_rnspm,
                             p_rnspc_res,
                             p_rnspc_info,
                             p_rnspc_date,
                             p_rnspc_name,
                             p_new_id);
    END;


    PROCEDURE Delete (p_id RNSP_CHECK.RNSPC_ID%TYPE)
    IS
    BEGIN
        API$RNSP_CHECK.Delete (p_id);
    END;

    -- Список за фільтром
    PROCEDURE Query (p_RNSPC_RNSPM IN NUMBER, p_res OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.WriteMsg ('DNET$RNSP_CHECK.' || $$PLSQL_UNIT);

        OPEN p_res FOR
            SELECT RNSPC_ID,
                   -- RNSP_MAIN
                   RNSPC_RNSPM,
                   RNSPC_RES,
                   RNSPC_INFO,
                   RNSPC_DATE,
                   RNSPC_NAME,
                   r.DIC_VALUE     AS RNSPC_RES_NAME
              FROM RNSP_CHECK
                   JOIN uss_ndi.v_ddn_rnsp_res r ON r.DIC_VALUE = RNSPC_RES
             WHERE RNSPC_RNSPM = p_RNSPC_RNSPM;
    END;
END DNET$RNSP_CHECK;
/