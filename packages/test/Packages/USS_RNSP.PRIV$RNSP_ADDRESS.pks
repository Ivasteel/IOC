/* Formatted on 8/12/2025 5:57:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.PRIV$RNSP_ADDRESS
IS
    -- Отримати запис по ідентифікатору
    PROCEDURE Get (p_id    IN     RNSP_ADDRESS.RNSPA_ID%TYPE,
                   p_res      OUT SYS_REFCURSOR);

    -- Отримати запис по ідентифікатору стану
    PROCEDURE Get_List (p_rnsps_id IN NUMBER, p_res OUT SYS_REFCURSOR);

    -- Зберегти
    PROCEDURE Save (
        p_RNSPA_ID            IN     RNSP_ADDRESS.RNSPA_ID%TYPE,
        p_RNSPA_KAOT          IN     RNSP_ADDRESS.RNSPA_KAOT%TYPE,
        p_RNSPA_INDEX         IN     RNSP_ADDRESS.RNSPA_INDEX%TYPE,
        p_RNSPA_STREET        IN     RNSP_ADDRESS.RNSPA_STREET%TYPE,
        p_RNSPA_BUILDING      IN     RNSP_ADDRESS.RNSPA_BUILDING%TYPE,
        p_RNSPA_KORP          IN     RNSP_ADDRESS.RNSPA_KORP%TYPE,
        p_RNSPA_APPARTEMENT   IN     RNSP_ADDRESS.RNSPA_APPARTEMENT%TYPE,
        p_Rnspa_Notes         IN     rnsp_address.rnspa_notes%TYPE,
        p_Rnspa_Tp            IN     rnsp_address.rnspa_tp%TYPE,
        p_new_id                 OUT RNSP_ADDRESS.RNSPA_ID%TYPE);

    -- Вилучити
    PROCEDURE Delete (p_id RNSP_ADDRESS.RNSPA_ID%TYPE);

    -- Адреса не змінилася
    FUNCTION IsNoChanges (
        p_RNSPA_ID            IN RNSP_ADDRESS.RNSPA_ID%TYPE,
        p_RNSPA_KAOT          IN RNSP_ADDRESS.RNSPA_KAOT%TYPE,
        p_RNSPA_INDEX         IN RNSP_ADDRESS.RNSPA_INDEX%TYPE,
        p_RNSPA_STREET        IN RNSP_ADDRESS.RNSPA_STREET%TYPE,
        p_RNSPA_BUILDING      IN RNSP_ADDRESS.RNSPA_BUILDING%TYPE,
        p_RNSPA_KORP          IN RNSP_ADDRESS.RNSPA_KORP%TYPE,
        p_RNSPA_APPARTEMENT   IN RNSP_ADDRESS.RNSPA_APPARTEMENT%TYPE,
        p_Rnspa_Notes         IN rnsp_address.rnspa_notes%TYPE,
        p_Rnspa_Tp            IN rnsp_address.rnspa_tp%TYPE)
        RETURN BOOLEAN;
END PRIV$RNSP_ADDRESS;
/


/* Formatted on 8/12/2025 5:58:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RNSP.PRIV$RNSP_ADDRESS
IS
    -- Отримати запис по ідентифікатору
    PROCEDURE Get (p_id    IN     RNSP_ADDRESS.RNSPA_ID%TYPE,
                   p_res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT RNSPA_ID,
                   -- NDI_KATOTTG
                   RNSPA_KAOT,
                   RNSPA_INDEX,
                   RNSPA_STREET,
                   RNSPA_BUILDING,
                   RNSPA_KORP,
                   RNSPA_APPARTEMENT,
                   t.rnspa_notes,
                   k.kaot_kaot_l1     AS REGION_ID
              FROM RNSP_ADDRESS  t
                   LEFT JOIN uss_ndi.v_ndi_katottg k
                       ON RNSPA_KAOT = k.kaot_id
             WHERE RNSPA_ID = p_id;
    END;


    -- Отримати запис по ідентифікатору стану
    PROCEDURE Get_List (p_rnsps_id IN NUMBER, p_res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
              SELECT t.*,
                     k.kaot_kaot_l1             AS REGION_ID,
                     (SELECT    k.kaot_full_name
                             || ' ('
                             || r.kaot_full_name
                             || ')'
                        FROM uss_ndi.v_ndi_katottg k
                             LEFT JOIN uss_ndi.v_ndi_katottg r
                                 ON r.kaot_id = k.kaot_kaot_l2
                       WHERE /*k.kaot_tp in ('M', 'T', 'C', 'X', 'K') -- #96514
                         AND*/
                             k.kaot_id = t.rnspa_kaot
                       FETCH FIRST ROW ONLY)    AS kaot_name,
                     tp.DIC_NAME                AS rnspa_tp_name
                FROM RNSP_ADDRESS t
                     JOIN rnsp2address a ON (a.rnsp2a_rnspa = t.rnspa_id)
                     LEFT JOIN uss_ndi.v_ndi_katottg k
                         ON RNSPA_KAOT = k.kaot_id
                     LEFT JOIN uss_ndi.v_ddn_rnsp_addr_tp tp
                         ON (tp.DIC_VALUE = t.rnspa_tp)
               WHERE a.rnsp2a_rnsps = p_rnsps_id
            ORDER BY DECODE (rnspa_tp, 'U', 1, 2), rnspa_id;
    END;

    -- Зберегти
    PROCEDURE Save (
        p_RNSPA_ID            IN     RNSP_ADDRESS.RNSPA_ID%TYPE,
        p_RNSPA_KAOT          IN     RNSP_ADDRESS.RNSPA_KAOT%TYPE,
        p_RNSPA_INDEX         IN     RNSP_ADDRESS.RNSPA_INDEX%TYPE,
        p_RNSPA_STREET        IN     RNSP_ADDRESS.RNSPA_STREET%TYPE,
        p_RNSPA_BUILDING      IN     RNSP_ADDRESS.RNSPA_BUILDING%TYPE,
        p_RNSPA_KORP          IN     RNSP_ADDRESS.RNSPA_KORP%TYPE,
        p_RNSPA_APPARTEMENT   IN     RNSP_ADDRESS.RNSPA_APPARTEMENT%TYPE,
        p_Rnspa_Notes         IN     rnsp_address.rnspa_notes%TYPE,
        p_Rnspa_Tp            IN     rnsp_address.rnspa_tp%TYPE,
        p_new_id                 OUT RNSP_ADDRESS.RNSPA_ID%TYPE)
    IS
    BEGIN
        IF p_RNSPA_ID IS NULL
        THEN
            INSERT INTO RNSP_ADDRESS (RNSPA_KAOT,
                                      RNSPA_INDEX,
                                      RNSPA_STREET,
                                      RNSPA_BUILDING,
                                      RNSPA_KORP,
                                      RNSPA_APPARTEMENT,
                                      Rnspa_Notes,
                                      rnspa_tp)
                 VALUES (p_RNSPA_KAOT,
                         p_RNSPA_INDEX,
                         p_RNSPA_STREET,
                         p_RNSPA_BUILDING,
                         p_RNSPA_KORP,
                         p_RNSPA_APPARTEMENT,
                         p_Rnspa_Notes,
                         NVL (p_Rnspa_Tp, 'S'))
              RETURNING RNSPA_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_RNSPA_ID;

            UPDATE RNSP_ADDRESS
               SET RNSPA_KAOT = p_RNSPA_KAOT,
                   RNSPA_INDEX = p_RNSPA_INDEX,
                   RNSPA_STREET = p_RNSPA_STREET,
                   RNSPA_BUILDING = p_RNSPA_BUILDING,
                   RNSPA_KORP = p_RNSPA_KORP,
                   RNSPA_APPARTEMENT = p_RNSPA_APPARTEMENT,
                   Rnspa_Notes = p_Rnspa_Notes
             WHERE RNSPA_ID = p_RNSPA_ID;
        END IF;
    END;

    -- Вилучити
    PROCEDURE Delete (p_id RNSP_ADDRESS.RNSPA_ID%TYPE)
    IS
    BEGIN
        DELETE FROM RNSP_ADDRESS
              WHERE RNSPA_ID = p_id;
    END;

    FUNCTION IsNoChanges (
        p_RNSPA_ID            IN RNSP_ADDRESS.RNSPA_ID%TYPE,
        p_RNSPA_KAOT          IN RNSP_ADDRESS.RNSPA_KAOT%TYPE,
        p_RNSPA_INDEX         IN RNSP_ADDRESS.RNSPA_INDEX%TYPE,
        p_RNSPA_STREET        IN RNSP_ADDRESS.RNSPA_STREET%TYPE,
        p_RNSPA_BUILDING      IN RNSP_ADDRESS.RNSPA_BUILDING%TYPE,
        p_RNSPA_KORP          IN RNSP_ADDRESS.RNSPA_KORP%TYPE,
        p_RNSPA_APPARTEMENT   IN RNSP_ADDRESS.RNSPA_APPARTEMENT%TYPE,
        p_Rnspa_Notes         IN rnsp_address.rnspa_notes%TYPE,
        p_Rnspa_Tp            IN rnsp_address.rnspa_tp%TYPE)
        RETURN BOOLEAN
    IS
        l_rec   RNSP_ADDRESS%ROWTYPE;
    BEGIN
        SELECT *
          INTO l_rec
          FROM RNSP_ADDRESS
         WHERE rnspa_id = p_rnspa_id;

        RETURN (    tools.isequalN (p_RNSPA_KAOT, l_rec.RNSPA_KAOT)
                AND tools.isequalS (p_RNSPA_INDEX, l_rec.RNSPA_INDEX)
                AND tools.isequalS (p_RNSPA_STREET, l_rec.RNSPA_STREET)
                AND tools.isequalS (p_RNSPA_BUILDING, l_rec.RNSPA_BUILDING)
                AND tools.isequalS (p_RNSPA_KORP, l_rec.RNSPA_KORP)
                AND tools.isequalS (p_RNSPA_APPARTEMENT,
                                    l_rec.RNSPA_APPARTEMENT)
                AND tools.isequalS (p_Rnspa_Notes, l_rec.Rnspa_Notes)
                AND tools.isequalS (p_Rnspa_Tp, l_rec.Rnspa_Tp));
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN FALSE;
    END;
END PRIV$RNSP_ADDRESS;
/