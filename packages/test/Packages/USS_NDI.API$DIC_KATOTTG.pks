/* Formatted on 8/12/2025 5:55:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.API$DIC_KATOTTG
IS
    TYPE r_kaot_lst IS RECORD
    (
        kaot_id     NUMBER,
        kaots_id    NUMBER
    );

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

    PROCEDURE delete_ndi_kaot_state (
        p_kaots_id         ndi_kaot_state.kaots_id%TYPE,
        p_history_status   ndi_kaot_state.history_status%TYPE);

    FUNCTION get_kaot_name (p_kaot_id IN NUMBER)
        RETURN VARCHAR2;
END API$DIC_KATOTTG;
/


/* Formatted on 8/12/2025 5:55:29 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.API$DIC_KATOTTG
IS
    --Перевірка коректності заповнення історії станів КАТОТТГ
    PROCEDURE check_kaot_state
    IS
        l_err_cnt   INTEGER;
    BEGIN
        --Чи є видалені записи по hs_del але з history_Status = 'A'
        SELECT COUNT (*)
          INTO l_err_cnt
          FROM ndi_kaot_state
         WHERE kaots_hs_del IS NOT NULL AND history_status = 'A';

        IF l_err_cnt > 0
        THEN
            raise_application_error (
                -20000,
                'В історії станів виявлено помилки історії - видалені за сесією видалення записі залишись в актуальному стані! Продовжувати ведення історії не можу!');
        END IF;

        SELECT COUNT (*)
          INTO l_err_cnt
          FROM ndi_kaot_state
         WHERE kaots_hs_del IS NOT NULL AND history_status = 'A';

        IF l_err_cnt > 0
        THEN
            raise_application_error (
                -20000,
                   'В історії станів виявлено помилки історії ('
                || l_err_cnt
                || ' штук) - видалені за сесією видалення записі залишись в актуальному стані! Продовжувати ведення історії не можу!');
        END IF;

        --Чи є на всі дати змін не більше 1 запису історії по типу стану
        WITH
            full_dts
            AS
                (SELECT kaots_kaot         AS x_kaot,
                        kaots_tp           AS x_tp,
                        kaots_start_dt     AS x_dt
                   FROM ndi_kaot_state
                  WHERE history_status = 'A'
                 UNION
                 SELECT kaots_kaot            AS x_kaot,
                        kaots_tp              AS x_tp,
                        kaots_stop_dt + 1     AS x_dt
                   FROM ndi_kaot_state
                  WHERE history_status = 'A' AND kaots_stop_dt IS NOT NULL)
        SELECT COUNT (*)
          INTO l_err_cnt
          FROM full_dts
         WHERE 1 <
               (SELECT COUNT (*)
                  FROM ndi_kaot_state
                 WHERE     kaots_kaot = x_kaot
                       AND kaots_tp = x_tp
                       AND x_dt BETWEEN kaots_start_dt
                                    AND NVL (kaots_stop_dt, x_dt)
                       AND history_status = 'A');

        IF l_err_cnt > 0
        THEN
            raise_application_error (
                -20000,
                   'В історії станів виявлено помилки історії ('
                || l_err_cnt
                || ' штук) - на дату зміни існує декілька актуальних рядків! Продовжувати ведення історії не можу!');
        END IF;
    END;

    PROCEDURE update_ndi_code (p_kaot_id IN ndi_katottg.kaot_id%TYPE)
    IS
        l_level   NUMBER;
        l_idx     NUMBER;
        l_code    VARCHAR2 (3);
    BEGIN
        SELECT CASE
                   WHEN t.kaot_id = t.kaot_kaot_l1 THEN 1
                   WHEN t.kaot_id = t.kaot_kaot_l2 THEN 2
                   WHEN t.kaot_id = t.kaot_kaot_l3 THEN 3
                   WHEN t.kaot_id = t.kaot_kaot_l4 THEN 4
                   WHEN t.kaot_id = t.kaot_kaot_l5 THEN 5
               END    AS lvl,
               CASE
                   WHEN t.kaot_id = t.kaot_kaot_l1
                   THEN
                       SUBSTR (t.kaot_code, 3, 2)
                   WHEN t.kaot_id = t.kaot_kaot_l2
                   THEN
                       SUBSTR (t.kaot_code, 5, 2)
                   WHEN t.kaot_id = t.kaot_kaot_l3
                   THEN
                       SUBSTR (t.kaot_code, 7, 3)
                   WHEN t.kaot_id = t.kaot_kaot_l4
                   THEN
                       SUBSTR (t.kaot_code, 10, 3)
                   WHEN t.kaot_id = t.kaot_kaot_l5
                   THEN
                       SUBSTR (t.kaot_code, 13, 2)
               END    AS code,
               CASE
                   WHEN t.kaot_id = t.kaot_kaot_l1 THEN 3
                   WHEN t.kaot_id = t.kaot_kaot_l2 THEN 5
                   WHEN t.kaot_id = t.kaot_kaot_l3 THEN 7
                   WHEN t.kaot_id = t.kaot_kaot_l4 THEN 10
                   WHEN t.kaot_id = t.kaot_kaot_l5 THEN 13
               END    AS idx
          INTO l_level, l_code, l_idx
          FROM ndi_katottg t
         WHERE t.kaot_id = p_kaot_id;

        EXECUTE IMMEDIATE   '
    update ndi_katottg t
       set t.kaot_code = substr(t.kaot_code, 1, :l_idx - 1) || :l_code || substr(t.kaot_code, :l_idx + length(:l_code))
     where t.kaot_kaot_l'
                         || l_level
                         || ' = :p_kaot_id
       and t.kaot_code is not null
    '
            USING l_idx,
                  l_code,
                  l_idx,
                  l_code,
                  p_kaot_id;
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
        UPDATE v_ndi_katottg t
           SET /*t.kaot_kaot_l1 = p_kaot_kaot_l1,
               t.kaot_kaot_l2 = p_kaot_kaot_l2,
               t.kaot_kaot_l3 = p_kaot_kaot_l3,
               t.kaot_kaot_l4 = p_kaot_kaot_l4,
               t.kaot_kaot_l5 = p_kaot_kaot_l5*/
               t.kaot_name = p_kaot_name,
               t.kaot_code = p_kaot_code,
               t.kaot_Tp = p_kaot_Tp
         WHERE t.kaot_id = p_kaot_id;

        update_ndi_code (p_kaot_id);
    END;


    -- стандартне збереження показника
    PROCEDURE save_ndi_kaot_state_internal (
        p_kaots_id         IN ndi_kaot_state.kaots_id%TYPE,
        p_kaots_kaot       IN ndi_kaot_state.kaots_kaot%TYPE,
        p_kaots_tp         IN ndi_kaot_state.kaots_tp%TYPE,
        p_kaots_state      IN ndi_kaot_state.kaots_state%TYPE,
        p_kaots_start_dt   IN ndi_kaot_state.kaots_start_dt%TYPE,
        p_kaots_stop_dt    IN ndi_kaot_state.kaots_stop_dt%TYPE,
        p_kaots_nna        IN ndi_kaot_state.kaots_nna%TYPE,
        p_hs               IN NUMBER)
    IS
        l_hsid   NUMBER := p_hs;
    BEGIN
        /* raise_application_error(-20009,
                                     ' ! ' || p_kaots_id ||' ! ' || p_kaots_kaot ||' ! ' || p_kaots_tp ||' ! ' || p_kaots_state||' ! ' || p_kaots_start_dt ||' ! ' || p_kaots_stop_dt ||' ! ' ||  p_kaots_nna ||' ! '
                                      );*/
        INSERT INTO tmp_unh_old_list (ol_obj,
                                      ol_hst,
                                      ol_begin,
                                      ol_end)
            SELECT 0,
                   h.kaots_id,
                   h.kaots_start_dt,
                   h.kaots_stop_dt
              FROM v_ndi_kaot_state h
             WHERE     h.history_status = 'A'
                   AND h.kaots_tp = p_kaots_tp
                   AND h.kaots_kaot = p_kaots_kaot
                   AND (p_kaots_id IS NULL OR h.kaots_id != p_kaots_id);

        -- формування історії
        api$hist.setup_history (0, p_kaots_start_dt, p_kaots_stop_dt);

        -- закриття недіючих
        UPDATE v_ndi_kaot_state h
           SET h.kaots_hs_del = l_hsid, h.history_status = 'H'
         WHERE    (EXISTS
                       (SELECT 1
                          FROM tmp_unh_to_prp
                         WHERE tprp_hst = h.kaots_id))
               OR h.kaots_id = p_kaots_id;


        -- додавання нових періодів
        INSERT INTO v_ndi_kaot_state (kaots_id,
                                      kaots_kaot,
                                      kaots_tp,
                                      kaots_state,
                                      kaots_start_dt,
                                      kaots_stop_dt,
                                      kaots_nna,
                                      kaots_hs_ins,
                                      history_status)
            SELECT 0,
                   ho.kaots_kaot,
                   ho.kaots_tp,
                   ho.kaots_state,
                   rz.rz_begin,
                   rz.rz_end,
                   ho.kaots_nna,
                   l_hsid,
                   'A'
              FROM tmp_unh_rz_list rz, v_ndi_kaot_state ho
             WHERE     rz_hst <> 0
                   AND (rz_begin <= rz_end OR rz_end IS NULL)
                   AND ho.kaots_id = rz_hst
            UNION
            SELECT 0,
                   p_kaots_kaot,
                   p_kaots_tp,
                   p_kaots_state,
                   vh_lgwh.rz_begin,
                   vh_lgwh.rz_end,
                   p_kaots_nna,
                   l_hsid,
                   'A'
              FROM tmp_unh_rz_list vh_lgwh
             WHERE rz_hst = 0 AND (rz_begin <= rz_end OR rz_end IS NULL);

        check_kaot_state;
    END;


    -- обробка додавання/оновлення до всіх підлеглих катоттг поточного
    -- якщо редагується показник (і параметри співпадають), то редагування відбувається і для всіх підлеглих.
    -- якщо при редагуванні немає аналогічних записів або додається новий показник, то для всіх підлеглих викликається стандартний механізм додавання нового показника.
    PROCEDURE save_ndi_kaot_state_sub (
        p_kaots_id         IN ndi_kaot_state.kaots_id%TYPE,
        p_kaots_kaot       IN ndi_kaot_state.kaots_kaot%TYPE,
        p_kaots_tp         IN ndi_kaot_state.kaots_tp%TYPE,
        p_kaots_state      IN ndi_kaot_state.kaots_state%TYPE,
        p_kaots_start_dt   IN ndi_kaot_state.kaots_start_dt%TYPE,
        p_kaots_stop_dt    IN ndi_kaot_state.kaots_stop_dt%TYPE,
        p_kaots_nna        IN ndi_kaot_state.kaots_nna%TYPE,
        p_hs               IN NUMBER)
    IS
        l_row          ndi_kaot_state%ROWTYPE;
        l_can_update   NUMBER := 0;

        TYPE t_cur IS REF CURSOR;

        l_cur          t_cur;
        v_sql          VARCHAR2 (1000);
        l_kaot_row     r_kaot_lst;

        l_level        NUMBER;
    BEGIN
        SELECT CASE
                   WHEN t.kaot_id = t.kaot_kaot_l1 THEN 1
                   WHEN t.kaot_id = t.kaot_kaot_l2 THEN 2
                   WHEN t.kaot_id = t.kaot_kaot_l3 THEN 3
                   WHEN t.kaot_id = t.kaot_kaot_l4 THEN 4
                   WHEN t.kaot_id = t.kaot_kaot_l5 THEN 5
               END    AS lvl
          INTO l_level
          FROM ndi_katottg t
         WHERE t.kaot_id = p_kaots_kaot;

        v_sql :=
               '
        SELECT t.kaot_id,
               (SELECT MAX(z.kaots_id)
                  FROM ndi_kaot_state z
                  join ndi_kaot_state q on (q.kaots_id = :p_kaots_id)
                 WHERE z.kaots_kaot = t.kaot_id
                   AND z.history_status = ''A''
                   AND z.kaots_tp = q.kaots_tp-- :p_kaots_tp
                   AND z.kaots_start_dt = q.kaots_start_dt--:p_kaots_start_dt
                   AND z.kaots_nna = q.kaots_nna --:p_kaots_nna
                   AND z.kaots_state = q.kaots_state --:p_kaots_nna
                   AND (z.kaots_stop_dt IS NULL AND q.kaots_stop_dt IS NULL or z.kaots_stop_dt = q.kaots_stop_dt)
               ) AS kaots_id
          FROM ndi_katottg t
         WHERE t.kaot_kaot_l'
            || l_level
            || ' = :p_kaot_id
           AND t.kaot_id != :p_kaot_id
    ';


        /*  IF (p_kaots_id IS NOT NULL) THEN
            SELECT *
              INTO l_row
              FROM ndi_kaot_state t
             WHERE t.kaots_id = p_kaots_id;

            IF (p_kaots_nna = l_row.kaots_nna AND p_kaots_start_dt = l_row.kaots_start_dt
                AND l_row.kaots_stop_dt IS NULL AND p_kaots_tp = l_row.kaots_tp) THEN
              l_can_update := 1;
            END IF;
          END IF;*/

        OPEN l_cur FOR v_sql USING p_kaots_id, p_kaots_kaot, p_kaots_kaot; --, p_kaots_start_dt, p_kaots_nna, p_kaots_kaot, p_kaots_kaot;

        LOOP
            FETCH l_cur INTO l_kaot_row;

            EXIT WHEN l_cur%NOTFOUND;

            save_ndi_kaot_state_internal (l_kaot_row.kaots_id, --CASE WHEN l_can_update = 1 THEN l_kaot_row.kaots_id ELSE NULL END,
                                          l_kaot_row.kaot_Id,
                                          p_kaots_tp,
                                          p_kaots_state,
                                          p_kaots_start_dt,
                                          p_kaots_stop_dt,
                                          p_kaots_nna,
                                          p_hs);

            DELETE FROM tmp_unh_old_list
                  WHERE 1 = 1;

            DELETE FROM tmp_unh_rz_list
                  WHERE 1 = 1;

            DELETE FROM tmp_unh_to_prp
                  WHERE 1 = 1;
        END LOOP;
    END;

    -- виклик збереження показника з вебу
    PROCEDURE save_ndi_kaot_state (
        p_kaots_id         IN ndi_kaot_state.kaots_id%TYPE,
        p_kaots_kaot       IN ndi_kaot_state.kaots_kaot%TYPE,
        p_kaots_tp         IN ndi_kaot_state.kaots_tp%TYPE,
        p_kaots_state      IN ndi_kaot_state.kaots_state%TYPE,
        p_kaots_start_dt   IN ndi_kaot_state.kaots_start_dt%TYPE,
        p_kaots_stop_dt    IN ndi_kaot_state.kaots_stop_dt%TYPE,
        p_kaots_nna        IN ndi_kaot_state.kaots_nna%TYPE)
    IS
        l_hsid   NUMBER := tools.gethistsession;
    BEGIN
        --raise_application_error(-20000, 'test');
        -- оновлення всіх записів нижніх рівнів
        save_ndi_kaot_state_sub (p_kaots_id,
                                 p_kaots_kaot,
                                 p_kaots_tp,
                                 p_kaots_state,
                                 p_kaots_start_dt,
                                 p_kaots_stop_dt,
                                 p_kaots_nna,
                                 l_hsid);

        -- власне оновлення поточного запису
        save_ndi_kaot_state_internal (p_kaots_id,
                                      p_kaots_kaot,
                                      p_kaots_tp,
                                      p_kaots_state,
                                      p_kaots_start_dt,
                                      p_kaots_stop_dt,
                                      p_kaots_nna,
                                      l_hsid);
    END;

    -- групова ініціалізація
    PROCEDURE group_save_ndi_kaot_state (
        p_kaots_tp         IN ndi_kaot_state.kaots_tp%TYPE,
        p_kaots_state      IN ndi_kaot_state.kaots_state%TYPE,
        p_kaots_start_dt   IN ndi_kaot_state.kaots_start_dt%TYPE,
        p_kaots_stop_dt    IN ndi_kaot_state.kaots_stop_dt%TYPE,
        p_kaots_nna        IN ndi_kaot_state.kaots_nna%TYPE,
        p_kaot_id_list     IN VARCHAR2)
    IS
        l_hsid   NUMBER := tools.gethistsession;
    BEGIN
        FOR rec
            IN (    SELECT TO_NUMBER (REGEXP_SUBSTR (p_kaot_id_list,
                                                     '[^,]+',
                                                     1,
                                                     LEVEL))    AS kaot_id
                      FROM DUAL
                CONNECT BY LEVEL <=
                             LENGTH (
                                 REGEXP_REPLACE (p_kaot_id_list, '[^,]*'))
                           + 1)
        LOOP
            /*raise_application_error(-20009,
                                      rec.kaot_id ||' ' || p_kaots_tp ||' ' || p_kaots_state||' ' || p_kaots_start_dt ||' ' || p_kaots_stop_dt ||' ' ||  p_kaots_doc_num ||' ' || p_kaots_doc_dt
                                     );*/
            save_ndi_kaot_state_internal (NULL,
                                          rec.kaot_id,
                                          p_kaots_tp,
                                          p_kaots_state,
                                          p_kaots_start_dt,
                                          p_kaots_stop_dt,
                                          p_kaots_nna,
                                          l_hsid);

            DELETE FROM tmp_unh_old_list
                  WHERE 1 = 1;

            DELETE FROM tmp_unh_rz_list
                  WHERE 1 = 1;

            DELETE FROM tmp_unh_to_prp
                  WHERE 1 = 1;
        END LOOP;
    END;


    PROCEDURE delete_ndi_kaot_state_internal (
        p_kaots_id      ndi_kaot_state.kaots_id%TYPE,
        p_hs         IN NUMBER)
    IS
    BEGIN
        UPDATE v_ndi_kaot_state
           SET history_status = 'H', kaots_hs_del = p_hs
         WHERE kaots_id = p_kaots_id;

        check_kaot_state;
    END;

    -- обробка видалення до всіх підлеглих катоттг поточного
    PROCEDURE delete_ndi_kaot_state_sub (
        p_kaots_id   IN ndi_kaot_state.kaots_id%TYPE,
        p_hs         IN NUMBER)
    IS
        l_row          ndi_kaot_state%ROWTYPE;
        l_can_update   NUMBER := 0;
        l_kaot_id      NUMBER;

        TYPE t_cur IS REF CURSOR;

        l_cur          t_cur;
        v_sql          VARCHAR2 (1000);
        l_kaot_row     r_kaot_lst;

        l_level        NUMBER;
    BEGIN
        SELECT CASE
                   WHEN t.kaot_id = t.kaot_kaot_l1 THEN 1
                   WHEN t.kaot_id = t.kaot_kaot_l2 THEN 2
                   WHEN t.kaot_id = t.kaot_kaot_l3 THEN 3
                   WHEN t.kaot_id = t.kaot_kaot_l4 THEN 4
                   WHEN t.kaot_id = t.kaot_kaot_l5 THEN 5
               END    AS lvl,
               t.kaot_id
          INTO l_level, l_kaot_id
          FROM ndi_kaot_state  s
               JOIN ndi_katottg t ON (t.kaot_id = s.kaots_kaot)
         WHERE s.kaots_id = p_kaots_id;

        v_sql :=
               '
        SELECT t.kaot_id,
               (SELECT MAX(z.kaots_id)
                  FROM ndi_kaot_state z
                  join ndi_kaot_state q on (q.kaots_id = :p_kaots_id)
                 WHERE z.kaots_kaot = t.kaot_id
                   AND z.history_status = ''A''
                   AND z.kaots_tp = q.kaots_tp
                   AND z.kaots_start_dt = q.kaots_start_dt
                   AND z.kaots_nna = q.kaots_nna
                   AND z.kaots_state = q.kaots_state
                   AND (z.kaots_stop_dt IS NULL AND q.kaots_stop_dt IS NULL or z.kaots_stop_dt = q.kaots_stop_dt)
               ) AS kaots_id
          FROM ndi_katottg t
         WHERE t.kaot_kaot_l'
            || l_level
            || ' = :p_kaot_id
           AND t.kaot_id != :p_kaot_id
    ';


        OPEN l_cur FOR v_sql USING p_kaots_id, l_kaot_id, l_kaot_id;

        LOOP
            FETCH l_cur INTO l_kaot_row;

            EXIT WHEN l_cur%NOTFOUND;

            IF (l_kaot_row.kaots_id IS NOT NULL)
            THEN
                delete_ndi_kaot_state_internal (l_kaot_row.kaots_id, p_hs);
            END IF;
        END LOOP;
    END;


    PROCEDURE delete_ndi_kaot_state (
        p_kaots_id         ndi_kaot_state.kaots_id%TYPE,
        p_history_status   ndi_kaot_state.history_status%TYPE)
    IS
        l_hsid   NUMBER;
    BEGIN
        l_hsid := tools.gethistsession;

        delete_ndi_kaot_state_sub (p_kaots_id, l_hsid);
        delete_ndi_kaot_state_internal (p_kaots_id, l_hsid);
    END;


    FUNCTION get_kaot_name (p_kaot_id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_res   VARCHAR2 (4000);
    BEGIN
        SELECT RTRIM (
                      CASE
                          WHEN l1_name IS NOT NULL AND l1_name != l2_name
                          THEN
                              l1_name || ', '
                      END
                   || CASE
                          WHEN l2_name IS NOT NULL AND l2_name != l3_name
                          THEN
                              l2_name || ', '
                      END
                   || CASE
                          WHEN l3_name IS NOT NULL AND l3_name != l4_name
                          THEN
                              l3_name || ', '
                      END
                   || CASE
                          WHEN l4_name IS NOT NULL AND l4_name != l5_name
                          THEN
                              l4_name || ', '
                      END
                   || CASE
                          WHEN l5_name IS NOT NULL AND l5_name != kaot_name
                          THEN
                              l5_name || ', '
                      END
                   || name_temp
                   || ', '
                   || Kaot_Code,
                   ',')    AS name
          INTO l_res
          FROM (SELECT Kaot_Id,
                       CASE
                           WHEN Kaot_Kaot_L1 = Kaot_Id
                           THEN
                               Kaot_Name
                           ELSE
                               (SELECT Dic_Sname || ' ' || X1.Kaot_Name
                                  FROM uss_ndi.v_Ndi_Katottg  X1,
                                       uss_ndi.v_Ddn_Kaot_Tp
                                 WHERE     X1.Kaot_Id = m.Kaot_Kaot_L1
                                       AND Kaot_Tp = Dic_Value)
                       END                                AS l1_name,
                       CASE
                           WHEN Kaot_Kaot_L2 = Kaot_Id
                           THEN
                               Kaot_Name
                           ELSE
                               (SELECT Dic_Sname || ' ' || X1.Kaot_Name
                                  FROM uss_ndi.v_Ndi_Katottg  X1,
                                       uss_ndi.v_Ddn_Kaot_Tp
                                 WHERE     X1.Kaot_Id = m.Kaot_Kaot_L2
                                       AND Kaot_Tp = Dic_Value)
                       END                                AS l2_name,
                       CASE
                           WHEN Kaot_Kaot_L3 = Kaot_Id
                           THEN
                               Kaot_Name
                           ELSE
                               (SELECT Dic_Sname || ' ' || X1.Kaot_Name
                                  FROM uss_ndi.v_Ndi_Katottg  X1,
                                       uss_ndi.v_Ddn_Kaot_Tp
                                 WHERE     X1.Kaot_Id = m.Kaot_Kaot_L3
                                       AND Kaot_Tp = Dic_Value)
                       END                                AS l3_name,
                       CASE
                           WHEN Kaot_Kaot_L4 = Kaot_Id
                           THEN
                               Kaot_Name
                           ELSE
                               (SELECT Dic_Sname || ' ' || X1.Kaot_Name
                                  FROM uss_ndi.v_Ndi_Katottg  X1,
                                       uss_ndi.v_Ddn_Kaot_Tp
                                 WHERE     X1.Kaot_Id = m.Kaot_Kaot_L4
                                       AND Kaot_Tp = Dic_Value)
                       END                                AS l4_name,
                       CASE
                           WHEN Kaot_Kaot_L5 = Kaot_Id
                           THEN
                               Kaot_Name
                           ELSE
                               (SELECT Dic_Sname || ' ' || X1.Kaot_Name
                                  FROM uss_ndi.v_Ndi_Katottg  X1,
                                       uss_ndi.v_Ddn_Kaot_Tp
                                 WHERE     X1.Kaot_Id = m.Kaot_Kaot_L5
                                       AND Kaot_Tp = Dic_Value)
                       END                                AS l5_name,
                       Kaot_Code,
                       Kaot_Tp,
                       t.Dic_Sname                        AS Kaot_Tp_Name,
                       Kaot_Name,
                       Kaot_Start_Dt,
                       Kaot_Stop_Dt,
                       Kaot_St,
                       Kaot_Koatuu,
                       kaot_id                            AS id,
                       t.Dic_Sname || ' ' || kaot_name    AS name_temp
                  FROM uss_ndi.v_Ndi_Katottg  m
                       JOIN uss_ndi.v_Ddn_Kaot_Tp t ON m.Kaot_Tp = t.Dic_Code
                 WHERE Kaot_St = 'A' AND m.kaot_id = p_kaot_id) t;

        RETURN l_res;
    END;
END API$DIC_KATOTTG;
/