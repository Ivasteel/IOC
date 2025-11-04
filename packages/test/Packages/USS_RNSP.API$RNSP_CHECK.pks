/* Formatted on 8/12/2025 5:57:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.API$RNSP_CHECK
IS
    -- Отримати запис по ідентифікатору
    PROCEDURE Get (p_id IN RNSP_CHECK.RNSPC_ID%TYPE, p_res OUT SYS_REFCURSOR);

    -- Зберегти
    PROCEDURE Save (p_RNSPC_ID      IN     RNSP_CHECK.RNSPC_ID%TYPE,
                    p_RNSPC_RNSPM   IN     RNSP_CHECK.RNSPC_RNSPM%TYPE,
                    p_RNSPC_RES     IN     RNSP_CHECK.RNSPC_RES%TYPE,
                    p_RNSPC_INFO    IN     RNSP_CHECK.RNSPC_INFO%TYPE,
                    p_RNSPC_DATE    IN     RNSP_CHECK.RNSPC_DATE%TYPE,
                    p_rnspc_name    IN     RNSP_CHECK.rnspc_name%TYPE,
                    p_new_id           OUT RNSP_CHECK.RNSPC_ID%TYPE);

    -- Вилучити
    PROCEDURE Delete (p_id RNSP_CHECK.RNSPC_ID%TYPE);

    -- Список за фільтром
    PROCEDURE Query (p_RNSPC_RNSPM IN NUMBER, p_res OUT SYS_REFCURSOR);
END API$RNSP_CHECK;
/


/* Formatted on 8/12/2025 5:57:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RNSP.API$RNSP_CHECK
IS
    -- Отримати запис по ідентифікатору
    PROCEDURE Get (p_id IN RNSP_CHECK.RNSPC_ID%TYPE, p_res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT RNSPC_ID,
                   -- RNSP_MAIN
                   RNSPC_RNSPM,
                   RNSPC_RES,
                   RNSPC_INFO,
                   RNSPC_DATE,
                   t.rnspc_name,
                   r.DIC_NAME     AS RNSPC_RES_NAME
              FROM RNSP_CHECK  t
                   JOIN uss_ndi.v_ddn_rnsp_res r ON r.DIC_VALUE = RNSPC_RES
             WHERE RNSPC_ID = p_id;
    END;

    -- Зберегти
    PROCEDURE Save (p_RNSPC_ID      IN     RNSP_CHECK.RNSPC_ID%TYPE,
                    p_RNSPC_RNSPM   IN     RNSP_CHECK.RNSPC_RNSPM%TYPE,
                    p_RNSPC_RES     IN     RNSP_CHECK.RNSPC_RES%TYPE,
                    p_RNSPC_INFO    IN     RNSP_CHECK.RNSPC_INFO%TYPE,
                    p_RNSPC_DATE    IN     RNSP_CHECK.RNSPC_DATE%TYPE,
                    p_rnspc_name    IN     RNSP_CHECK.rnspc_name%TYPE,
                    p_new_id           OUT RNSP_CHECK.RNSPC_ID%TYPE)
    IS
    BEGIN
        IF p_RNSPC_ID IS NULL
        THEN
            INSERT INTO RNSP_CHECK (RNSPC_RNSPM,
                                    RNSPC_RES,
                                    RNSPC_INFO,
                                    RNSPC_DATE,
                                    rnspc_name)
                 VALUES (p_RNSPC_RNSPM,
                         p_RNSPC_RES,
                         p_RNSPC_INFO,
                         p_RNSPC_DATE,
                         p_rnspc_name)
              RETURNING RNSPC_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_RNSPC_ID;

            UPDATE RNSP_CHECK
               SET RNSPC_RNSPM = p_RNSPC_RNSPM,
                   RNSPC_RES = p_RNSPC_RES,
                   RNSPC_INFO = p_RNSPC_INFO,
                   RNSPC_DATE = p_RNSPC_DATE
             WHERE RNSPC_ID = p_RNSPC_ID;
        END IF;
    END;

    -- Вилучити
    PROCEDURE Delete (p_id RNSP_CHECK.RNSPC_ID%TYPE)
    IS
    BEGIN
        DELETE FROM RNSP_CHECK
              WHERE RNSPC_ID = p_id;
    END;

    -- Список за фільтром
    PROCEDURE Query (p_RNSPC_RNSPM IN NUMBER, p_res OUT SYS_REFCURSOR)
    IS
    BEGIN
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
END API$RNSP_CHECK;
/