/* Formatted on 8/12/2025 5:57:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.PRIV$RNSP_STATUS_REGISTER
IS
    -- «берегти
    PROCEDURE Save (
        p_RNSPSR_ID       IN     RNSP_STATUS_REGISTER.RNSPSR_ID%TYPE,
        p_RNSPSR_RNSPM    IN     RNSP_STATUS_REGISTER.RNSPSR_RNSPM%TYPE,
        p_RNSPSR_DATE     IN     RNSP_STATUS_REGISTER.RNSPSR_DATE%TYPE,
        p_RNSPSR_REASON   IN     RNSP_STATUS_REGISTER.RNSPSR_REASON%TYPE,
        p_RNSPSR_HS       IN     RNSP_STATUS_REGISTER.RNSPSR_HS%TYPE,
        p_RNSPSR_ST       IN     RNSP_STATUS_REGISTER.RNSPSR_ST%TYPE,
        p_new_id             OUT RNSP_STATUS_REGISTER.RNSPSR_ID%TYPE);

    -- —писок за ф≥льтром
    PROCEDURE Query (p_RNSPSR_RNSPM IN NUMBER, p_res OUT SYS_REFCURSOR);
END PRIV$RNSP_STATUS_REGISTER;
/


/* Formatted on 8/12/2025 5:58:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RNSP.PRIV$RNSP_STATUS_REGISTER
IS
    -- «берегти
    PROCEDURE Save (
        p_RNSPSR_ID       IN     RNSP_STATUS_REGISTER.RNSPSR_ID%TYPE,
        p_RNSPSR_RNSPM    IN     RNSP_STATUS_REGISTER.RNSPSR_RNSPM%TYPE,
        p_RNSPSR_DATE     IN     RNSP_STATUS_REGISTER.RNSPSR_DATE%TYPE,
        p_RNSPSR_REASON   IN     RNSP_STATUS_REGISTER.RNSPSR_REASON%TYPE,
        p_RNSPSR_HS       IN     RNSP_STATUS_REGISTER.RNSPSR_HS%TYPE,
        p_RNSPSR_ST       IN     RNSP_STATUS_REGISTER.RNSPSR_ST%TYPE,
        p_new_id             OUT RNSP_STATUS_REGISTER.RNSPSR_ID%TYPE)
    IS
    BEGIN
        IF p_RNSPSR_ID IS NULL
        THEN
            INSERT INTO RNSP_STATUS_REGISTER (RNSPSR_RNSPM,
                                              RNSPSR_DATE,
                                              RNSPSR_REASON,
                                              RNSPSR_HS,
                                              RNSPSR_ST)
                 VALUES (p_RNSPSR_RNSPM,
                         p_RNSPSR_DATE,
                         p_RNSPSR_REASON,
                         p_RNSPSR_HS,
                         p_RNSPSR_ST)
              RETURNING RNSPSR_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_RNSPSR_ID;

            UPDATE RNSP_STATUS_REGISTER
               SET RNSPSR_RNSPM = p_RNSPSR_RNSPM,
                   RNSPSR_DATE = p_RNSPSR_DATE,
                   RNSPSR_REASON = p_RNSPSR_REASON,
                   RNSPSR_HS = p_RNSPSR_HS,
                   RNSPSR_ST = p_RNSPSR_ST
             WHERE RNSPSR_ID = p_RNSPSR_ID;
        END IF;
    END;

    -- —писок за ф≥льтром
    PROCEDURE Query (p_RNSPSR_RNSPM IN NUMBER, p_res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT RNSPSR_ID,
                   -- RNSP_MAIN
                   RNSPSR_RNSPM,
                   RNSPSR_DATE,
                   RNSPSR_REASON,
                   RNSPSR_ST,
                   -- HISTSESSION
                   RNSPSR_HS,
                   h.hs_dt,
                   u.wu_id,
                   u.wu_login,
                   u.wu_pib,
                   s.DIC_NAME     AS RNSPSR_ST_NAME
              FROM RNSP_STATUS_REGISTER
                   JOIN HISTSESSION h ON h.hs_id = RNSPSR_HS
                   JOIN uss_ndi.v_ddn_rnsp_st s ON RNSPSR_ST = s.DIC_VALUE
                   LEFT JOIN ikis_sysweb.V$ALL_USERS u ON u.wu_id = h.hs_wu
             WHERE RNSPSR_RNSPM = p_RNSPSR_RNSPM;
    END;
END PRIV$RNSP_STATUS_REGISTER;
/