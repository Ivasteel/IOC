/* Formatted on 8/12/2025 5:55:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.DNET$DIC_KATOTTG
IS
    -- Author  : SHOSTAK
    -- Created : 20.05.2021 16:45:40
    -- Purpose :

    -- Отримання списку за фільтром
    PROCEDURE Query_Ndi_Katottg (p_Kaot_Code       IN     VARCHAR2,
                                 p_Kaot_Name       IN     VARCHAR2,
                                 p_Kaot_Koatuu     IN     VARCHAR2,
                                 p_kaot_start_dt   IN     DATE,
                                 p_kaot_tp         IN     VARCHAR2,
                                 p_kaots_nna       IN     NUMBER,
                                 p_Res                OUT SYS_REFCURSOR);

    -- Повертає "КАТОТТГ" за ІД
    PROCEDURE get_ndi_katottg (p_kaot_id NUMBER, p_katottg OUT SYS_REFCURSOR);

    PROCEDURE get_ndi_katottg_his (p_kaot_id            NUMBER,
                                   p_katottg_hist   OUT SYS_REFCURSOR);

    PROCEDURE get_ndi_kaot_state (p_kaot_id          NUMBER,
                                  p_kaot_state   OUT SYS_REFCURSOR);


    PROCEDURE save_ndi_kaot (p_kaot_id     IN ndi_katottg.kaot_id%TYPE,
                             /* p_kaot_kaot_l1 IN ndi_katottg.kaot_kaot_l1%TYPE,
                             p_kaot_kaot_l2 IN ndi_katottg.kaot_kaot_l2%TYPE,
                             p_kaot_kaot_l3 IN ndi_katottg.kaot_kaot_l3%TYPE,
                             p_kaot_kaot_l4 IN ndi_katottg.kaot_kaot_l4%TYPE,
                             p_kaot_kaot_l5 IN ndi_katottg.kaot_kaot_l5%TYPE*/
                             p_kaot_name   IN ndi_katottg.kaot_name%TYPE,
                             p_kaot_code   IN ndi_katottg.kaot_code%TYPE,
                             p_kaot_Tp     IN ndi_katottg.kaot_tp%TYPE);

    PROCEDURE save_ndi_kaot_state (
        p_kaots_id         IN ndi_kaot_state.kaots_id%TYPE,
        p_kaots_kaot       IN ndi_kaot_state.kaots_kaot%TYPE,
        p_kaots_tp         IN ndi_kaot_state.kaots_tp%TYPE,
        p_kaots_state      IN ndi_kaot_state.kaots_state%TYPE,
        p_kaots_start_dt   IN ndi_kaot_state.kaots_start_dt%TYPE,
        p_kaots_stop_dt    IN ndi_kaot_state.kaots_stop_dt%TYPE,
        p_kaots_nna        IN ndi_kaot_state.kaots_nna%TYPE);

    PROCEDURE group_save_ndi_kaot_state (
        p_kaots_tp         IN ndi_kaot_state.kaots_tp%TYPE,
        p_kaots_state      IN ndi_kaot_state.kaots_state%TYPE,
        p_kaots_start_dt   IN ndi_kaot_state.kaots_start_dt%TYPE,
        p_kaots_stop_dt    IN ndi_kaot_state.kaots_stop_dt%TYPE,
        p_kaots_nna        IN ndi_kaot_state.kaots_nna%TYPE,
        p_kaot_id_list     IN VARCHAR2);

    PROCEDURE delete_ndi_kaot_state (p_kaots_id ndi_kaot_state.kaots_id%TYPE);
END Dnet$dic_Katottg;
/


GRANT EXECUTE ON USS_NDI.DNET$DIC_KATOTTG TO DNET_PROXY
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_KATOTTG TO II01RC_USS_NDI_PORTAL
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_KATOTTG TO II01RC_USS_NDI_WEB
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_KATOTTG TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:55:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.DNET$DIC_KATOTTG
IS
    -- Отримання списку за фільтром
    PROCEDURE query_ndi_katottg (p_kaot_code       IN     VARCHAR2,
                                 p_kaot_name       IN     VARCHAR2,
                                 p_kaot_koatuu     IN     VARCHAR2,
                                 p_kaot_start_dt   IN     DATE,
                                 p_kaot_tp         IN     VARCHAR2,
                                 p_kaots_nna       IN     NUMBER,
                                 p_res                OUT SYS_REFCURSOR)
    IS
        l_kaot_name   VARCHAR2 (250)
            := REGEXP_REPLACE (UPPER (p_kaot_name), '[`''’]', '');
    BEGIN
        IF p_kaot_name IS NOT NULL AND LENGTH (p_kaot_name) < 3
        THEN
            raise_application_error (-20000, 'Мінімум 3 символів для назви');
        END IF;

        OPEN p_res FOR
              SELECT kaot_id,
                     CASE
                         WHEN kaot_kaot_l1 = kaot_id
                         THEN
                             kaot_name                                 -- NULL
                         ELSE
                             (SELECT    dic_sname
                                     || ' '
                                     || x1.kaot_name
                                FROM ndi_katottg x1, v_ddn_kaot_tp
                               WHERE     x1.kaot_id = m.kaot_kaot_l1
                                     AND kaot_tp = dic_value)
                     END                          AS l1_name,
                     CASE
                         WHEN kaot_kaot_l2 = kaot_id
                         THEN
                             kaot_name                                 -- NULL
                         ELSE
                             (SELECT    dic_sname
                                     || ' '
                                     || x1.kaot_name
                                FROM ndi_katottg x1, v_ddn_kaot_tp
                               WHERE     x1.kaot_id = m.kaot_kaot_l2
                                     AND kaot_tp = dic_value)
                     END                          AS l2_name,
                     CASE
                         WHEN kaot_kaot_l3 = kaot_id
                         THEN
                             kaot_name                                 -- NULL
                         ELSE
                             (SELECT    dic_sname
                                     || ' '
                                     || x1.kaot_name
                                FROM ndi_katottg x1, v_ddn_kaot_tp
                               WHERE     x1.kaot_id = m.kaot_kaot_l3
                                     AND kaot_tp = dic_value)
                     END                          AS l3_name,
                     CASE
                         WHEN kaot_kaot_l4 = kaot_id
                         THEN
                             kaot_name                                 -- NULL
                         ELSE
                             (SELECT    dic_sname
                                     || ' '
                                     || x1.kaot_name
                                FROM ndi_katottg x1, v_ddn_kaot_tp
                               WHERE     x1.kaot_id = m.kaot_kaot_l4
                                     AND kaot_tp = dic_value)
                     END                          AS l4_name,
                     CASE
                         WHEN kaot_kaot_l5 = kaot_id
                         THEN
                             kaot_name                                 -- NULL
                         ELSE
                             (SELECT    dic_sname
                                     || ' '
                                     || x1.kaot_name
                                FROM ndi_katottg x1, v_ddn_kaot_tp
                               WHERE     x1.kaot_id = m.kaot_kaot_l5
                                     AND kaot_tp = dic_value)
                     END                          AS l5_name,
                     kaot_code,
                     kaot_tp,
                     t.dic_name                   AS kaot_tp_name,
                     kaot_name,
                     (  SELECT t.kaots_start_dt
                          FROM v_ndi_kaot_state t
                         WHERE     t.kaots_kaot = kaot_id
                               AND t.history_status = 'A'
                      ORDER BY t.kaots_start_dt DESC
                         FETCH FIRST ROW ONLY)    AS kaot_start_dt,
                     (  SELECT t.kaots_stop_dt
                          FROM v_ndi_kaot_state t
                         WHERE     t.kaots_kaot = kaot_id
                               AND t.history_status = 'A'
                      ORDER BY t.kaots_stop_dt DESC
                         FETCH FIRST ROW ONLY)    AS kaot_stop_dt,
                     kaot_st,
                     s.dic_name                   AS kaot_st_name,
                     kaot_koatuu
                FROM ndi_katottg m
                     JOIN v_ddn_kaot_tp t ON m.kaot_tp = t.dic_code
                     JOIN v_ddn_hist_status s ON m.kaot_st = s.dic_code
               WHERE     kaot_st = 'A'
                     AND (   p_kaot_name IS NULL
                          OR REGEXP_REPLACE (UPPER (m.kaot_name), '[`''’]', '') LIKE
                                 l_kaot_name || '%')
                     AND (   p_kaot_code IS NULL
                          OR m.kaot_code LIKE p_kaot_code || '%')
                     AND (   p_kaot_koatuu IS NULL
                          OR m.kaot_koatuu = p_kaot_koatuu)
                     /*AND (p_kaot_start_dt IS NULL OR p_kaot_start_dt  =
                     (SELECT t.kaots_start_dt
                            FROM v_ndi_kaot_state t
                           WHERE t.kaots_kaot = kaot_id
                             AND t.history_status = 'A'
                           ORDER BY t.kaots_start_dt DESC
                           FETCH FIRST ROW ONLY))*/
                     AND (   p_kaot_start_dt IS NULL
                          OR EXISTS
                                 (SELECT kaots_id
                                    FROM v_ndi_kaot_state t
                                   WHERE     t.kaots_kaot = kaot_id
                                         AND t.history_status = 'A'
                                         AND t.kaots_start_dt <=
                                             p_kaot_start_dt
                                         AND (   t.kaots_stop_dt IS NULL
                                              OR t.kaots_stop_dt >=
                                                 p_kaot_start_dt)
                                         AND (   p_kaot_tp IS NULL
                                              OR t.kaots_tp = p_kaot_tp)))
                     AND (   p_kaots_nna IS NULL
                          OR EXISTS
                                 (SELECT *
                                    FROM v_ndi_kaot_state z
                                   WHERE     z.kaots_kaot = m.kaot_id
                                         AND z.history_status = 'A'
                                         AND z.kaots_nna = p_kaots_nna))
            --ORDER BY kaot_start_dt DESC
            ORDER BY l1_name,
                     l2_name,
                     l3_name,
                     l4_name,
                     l5_name;
    END;

    -- Повертає "КАТОТТГ" за ІД
    PROCEDURE Get_Ndi_Katottg (p_Kaot_Id NUMBER, p_Katottg OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Katottg FOR
            SELECT kaot_id,
                   CASE
                       WHEN kaot_kaot_l1 = kaot_id
                       THEN
                           kaot_name                                   -- NULL
                       ELSE
                           (SELECT    dic_sname
                                   || ' '
                                   || x1.kaot_name
                              FROM ndi_katottg  x1,
                                   v_ddn_kaot_tp
                             WHERE     x1.kaot_id =
                                       m.kaot_kaot_l1
                                   AND kaot_tp = dic_value)
                   END                          AS l1_name,
                   CASE
                       WHEN kaot_kaot_l2 = kaot_id
                       THEN
                           kaot_name                                   -- NULL
                       ELSE
                           (SELECT    dic_sname
                                   || ' '
                                   || x1.kaot_name
                              FROM ndi_katottg  x1,
                                   v_ddn_kaot_tp
                             WHERE     x1.kaot_id =
                                       m.kaot_kaot_l2
                                   AND kaot_tp = dic_value)
                   END                          AS l2_name,
                   CASE
                       WHEN kaot_kaot_l3 = kaot_id
                       THEN
                           kaot_name                                   -- NULL
                       ELSE
                           (SELECT    dic_sname
                                   || ' '
                                   || x1.kaot_name
                              FROM ndi_katottg  x1,
                                   v_ddn_kaot_tp
                             WHERE     x1.kaot_id =
                                       m.kaot_kaot_l3
                                   AND kaot_tp = dic_value)
                   END                          AS l3_name,
                   CASE
                       WHEN kaot_kaot_l4 = kaot_id
                       THEN
                           kaot_name                                   -- NULL
                       ELSE
                           (SELECT    dic_sname
                                   || ' '
                                   || x1.kaot_name
                              FROM ndi_katottg  x1,
                                   v_ddn_kaot_tp
                             WHERE     x1.kaot_id =
                                       m.kaot_kaot_l4
                                   AND kaot_tp = dic_value)
                   END                          AS l4_name,
                   CASE
                       WHEN kaot_kaot_l5 = kaot_id
                       THEN
                           kaot_name                                   -- NULL
                       ELSE
                           (SELECT    dic_sname
                                   || ' '
                                   || x1.kaot_name
                              FROM ndi_katottg  x1,
                                   v_ddn_kaot_tp
                             WHERE     x1.kaot_id =
                                       m.kaot_kaot_l5
                                   AND kaot_tp = dic_value)
                   END                          AS l5_name,
                   m.kaot_kaot_l1,
                   m.kaot_kaot_l2,
                   m.kaot_kaot_l3,
                   m.kaot_kaot_l4,
                   m.kaot_kaot_l5,
                   kaot_code,
                   kaot_tp,
                   t.dic_name                   AS kaot_tp_name,
                   kaot_name,
                   (  SELECT t.kaots_start_dt
                        FROM v_ndi_kaot_state t
                       WHERE     t.kaots_kaot = kaot_id
                             AND t.history_status = 'A'
                    ORDER BY t.kaots_start_dt DESC
                       FETCH FIRST ROW ONLY)    AS kaot_start_dt,
                   (  SELECT t.kaots_stop_dt
                        FROM v_ndi_kaot_state t
                       WHERE t.kaots_kaot = kaot_id AND t.history_status = 'A'
                    ORDER BY t.kaots_stop_dt DESC
                       FETCH FIRST ROW ONLY)    AS kaot_stop_dt,
                   kaot_st,
                   s.dic_name                   AS kaot_st_name,
                   kaot_koatuu
              FROM ndi_katottg  m
                   JOIN v_ddn_kaot_tp t ON m.kaot_tp = t.dic_code
                   JOIN v_ddn_hist_status s ON m.kaot_st = s.dic_code
             WHERE m.kaot_id = p_kaot_id;
    END;

    PROCEDURE Get_Ndi_Katottg_His (p_Kaot_Id            NUMBER,
                                   p_Katottg_Hist   OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Katottg_Hist FOR
            SELECT Kaoth_Id,
                   CASE
                       WHEN Kaoth_Kaot_L1 = Kaoth_Id
                       THEN
                           NULL
                       ELSE
                           (SELECT    Dic_Sname
                                   || ' '
                                   || X1.Kaoth_Name
                              FROM Ndi_Katottg_Hist  X1,
                                   v_Ddn_Kaot_Tp
                             WHERE     X1.Kaoth_Id =
                                       m.Kaoth_Kaot_L1
                                   AND Kaoth_Tp =
                                       Dic_Value)
                   END           AS L1_Name,
                   CASE
                       WHEN Kaoth_Kaot_L2 = Kaoth_Id
                       THEN
                           NULL
                       ELSE
                           (SELECT    Dic_Sname
                                   || ' '
                                   || X1.Kaoth_Name
                              FROM Ndi_Katottg_Hist  X1,
                                   v_Ddn_Kaot_Tp
                             WHERE     X1.Kaoth_Id =
                                       m.Kaoth_Kaot_L2
                                   AND Kaoth_Tp =
                                       Dic_Value)
                   END           AS L2_Name,
                   CASE
                       WHEN Kaoth_Kaot_L3 = Kaoth_Id
                       THEN
                           NULL
                       ELSE
                           (SELECT    Dic_Sname
                                   || ' '
                                   || X1.Kaoth_Name
                              FROM Ndi_Katottg_Hist  X1,
                                   v_Ddn_Kaot_Tp
                             WHERE     X1.Kaoth_Id =
                                       m.Kaoth_Kaot_L3
                                   AND Kaoth_Tp =
                                       Dic_Value)
                   END           AS L3_Name,
                   CASE
                       WHEN Kaoth_Kaot_L4 = Kaoth_Id
                       THEN
                           NULL
                       ELSE
                           (SELECT    Dic_Sname
                                   || ' '
                                   || X1.Kaoth_Name
                              FROM Ndi_Katottg_Hist  X1,
                                   v_Ddn_Kaot_Tp
                             WHERE     X1.Kaoth_Id =
                                       m.Kaoth_Kaot_L4
                                   AND Kaoth_Tp =
                                       Dic_Value)
                   END           AS L4_Name,
                   CASE
                       WHEN Kaoth_Kaot_L5 = Kaoth_Id
                       THEN
                           NULL
                       ELSE
                           (SELECT    Dic_Sname
                                   || ' '
                                   || X1.Kaoth_Name
                              FROM Ndi_Katottg_Hist  X1,
                                   v_Ddn_Kaot_Tp
                             WHERE     X1.Kaoth_Id =
                                       m.Kaoth_Kaot_L5
                                   AND Kaoth_Tp =
                                       Dic_Value)
                   END           AS L5_Name,
                   Kaoth_Code,
                   Kaoth_Tp,
                   t.Dic_Name    AS Kaoth_Tp_Name,
                   Kaoth_Name,
                   Kaoth_Start_Dt,
                   Kaoth_Stop_Dt
              FROM Ndi_Katottg_Hist  m
                   JOIN v_Ddn_Kaot_Tp t ON m.Kaoth_Tp = t.Dic_Code
             WHERE m.Kaoth_Kaot = p_Kaot_Id;
    END;

    PROCEDURE Get_Ndi_Kaot_State (p_Kaot_Id          NUMBER,
                                  p_Kaot_State   OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_kaot_state FOR
              SELECT kaots_id,
                     kaots_tp,
                     tp.dic_name    AS kaots_tp_name,
                     kaots_state,
                     kaots_start_dt,
                     kaots_stop_dt,
                     hs.hs_dt       AS set_dt,
                     u.wu_pib       AS set_pib,
                     kaots_nna,
                     CASE
                         WHEN     kaots_start_dt IS NULL
                              AND kaots_id =
                                  (LAST_VALUE (kaots_id)
                                       OVER (
                                           PARTITION BY t.kaots_kaot
                                           ORDER BY kaots_id
                                           RANGE BETWEEN UNBOUNDED PRECEDING
                                                 AND     UNBOUNDED FOLLOWING))
                         THEN
                             'T'
                         WHEN kaots_start_dt =
                              (LAST_VALUE (kaots_start_dt)
                                   OVER (
                                       PARTITION BY t.kaots_kaot
                                       ORDER BY kaots_start_dt
                                       RANGE BETWEEN UNBOUNDED PRECEDING
                                             AND     UNBOUNDED FOLLOWING))
                         THEN
                             'T'
                         ELSE
                             'F'
                     END            AS kaots_is_last_record
                FROM ndi_kaot_state t
                     LEFT JOIN uss_ndi.v_ddn_kaots_tp tp
                         ON (t.kaots_tp = tp.dic_code)
                     LEFT JOIN histsession hs ON (hs.hs_id = t.kaots_hs_ins)
                     LEFT JOIN histsession hsd ON (hsd.hs_id = t.kaots_hs_del)
                     LEFT JOIN ikis_sysweb.v$all_users u
                         ON (u.wu_id = hs.hs_wu)
               WHERE t.kaots_kaot = p_kaot_id AND t.history_status = 'A'
            ORDER BY t.kaots_start_dt DESC;
    END;



    PROCEDURE save_ndi_kaot (p_kaot_id     IN ndi_katottg.kaot_id%TYPE,
                             /* p_kaot_kaot_l1 IN ndi_katottg.kaot_kaot_l1%TYPE,
                              p_kaot_kaot_l2 IN ndi_katottg.kaot_kaot_l2%TYPE,
                              p_kaot_kaot_l3 IN ndi_katottg.kaot_kaot_l3%TYPE,
                              p_kaot_kaot_l4 IN ndi_katottg.kaot_kaot_l4%TYPE,
                              p_kaot_kaot_l5 IN ndi_katottg.kaot_kaot_l5%TYPE*/
                             p_kaot_name   IN ndi_katottg.kaot_name%TYPE,
                             p_kaot_code   IN ndi_katottg.kaot_code%TYPE,
                             p_kaot_Tp     IN ndi_katottg.kaot_tp%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        /*api$dic_katottg.save_ndi_kaot(p_kaot_id, p_kaot_kaot_l1, p_kaot_kaot_l2, p_kaot_kaot_l3, p_kaot_kaot_l4, p_kaot_kaot_l5);*/
        api$dic_katottg.save_ndi_kaot (p_kaot_id,
                                       p_kaot_name,
                                       p_kaot_code,
                                       p_kaot_Tp);
    END;

    PROCEDURE save_ndi_kaot_state (
        p_kaots_id         IN ndi_kaot_state.kaots_id%TYPE,
        p_kaots_kaot       IN ndi_kaot_state.kaots_kaot%TYPE,
        p_kaots_tp         IN ndi_kaot_state.kaots_tp%TYPE,
        p_kaots_state      IN ndi_kaot_state.kaots_state%TYPE,
        p_kaots_start_dt   IN ndi_kaot_state.kaots_start_dt%TYPE,
        p_kaots_stop_dt    IN ndi_kaot_state.kaots_stop_dt%TYPE,
        p_kaots_nna        IN ndi_kaot_state.kaots_nna%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (5);

        /* raise_application_error(-20010,
        'data: ' ||
        p_kaots_kaot || ' ' || p_kaots_tp || ' ' || p_kaots_state || ' ' || p_kaots_start_dt    );*/
        IF (p_kaots_start_dt IS NULL)
        THEN
            raise_application_error (
                -20000,
                'Не заповнено дату початку дії показника!');
        END IF;

        --Контроль уникальности кода
        IF p_kaots_start_dt > p_kaots_stop_dt
        THEN
            raise_application_error (
                -20010,
                   'Некоректне значення дати: діє з '
                || p_kaots_start_dt
                || ' більше '
                || p_kaots_stop_dt
                || '');
        END IF;

        api$dic_katottg.save_ndi_kaot_state (p_kaots_id,
                                             p_kaots_kaot,
                                             p_kaots_tp,
                                             p_kaots_state,
                                             p_kaots_start_dt,
                                             p_kaots_stop_dt,
                                             p_kaots_nna);
    END;



    PROCEDURE group_save_ndi_kaot_state (
        p_kaots_tp         IN ndi_kaot_state.kaots_tp%TYPE,
        p_kaots_state      IN ndi_kaot_state.kaots_state%TYPE,
        p_kaots_start_dt   IN ndi_kaot_state.kaots_start_dt%TYPE,
        p_kaots_stop_dt    IN ndi_kaot_state.kaots_stop_dt%TYPE,
        p_kaots_nna        IN ndi_kaot_state.kaots_nna%TYPE,
        p_kaot_id_list     IN VARCHAR2)
    IS
    BEGIN
        /* raise_application_error(-20010,
        'data: ' ||
        p_kaots_kaot || ' ' || p_kaots_tp || ' ' || p_kaots_state || ' ' || p_kaots_start_dt    );*/
        --Контроль уникальности кода
        IF p_kaots_start_dt > p_kaots_stop_dt
        THEN
            raise_application_error (
                -20010,
                   'Некоректне значення дати: діє з '
                || p_kaots_start_dt
                || ' більше '
                || p_kaots_stop_dt
                || '');
        END IF;

        api$dic_katottg.group_save_ndi_kaot_state (p_kaots_tp,
                                                   p_kaots_state,
                                                   p_kaots_start_dt,
                                                   p_kaots_stop_dt,
                                                   p_kaots_nna,
                                                   p_kaot_id_list);
    END;

    PROCEDURE delete_ndi_kaot_state (p_kaots_id ndi_kaot_state.kaots_id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (5);
        api$dic_katottg.delete_ndi_kaot_state (
            p_kaots_id         => p_kaots_id,
            p_history_status   => api$dic_visit.c_history_status_historical);
    END;
END Dnet$dic_Katottg;
/