/* Formatted on 8/12/2025 5:55:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.API$HIST
IS
    -- Author  : VANO
    -- Created : 13.08.2021 12:12:51
    -- Purpose : Функції маніпуляцій з історією

    SUBTYPE t_decimal14 IS DECIMAL (14, 0);

    -- службова для історії
    TYPE t_unh_modes IS RECORD
    (
        unhm_r_type    INTEGER,
        unhm_mode      INTEGER
    );

    TYPE t_set_unh_modes IS TABLE OF t_unh_modes;

    -- Налаштування режимів
    FUNCTION get_unh_modes
        RETURN t_set_unh_modes
        PIPELINED;

    -- встановлення історії
    PROCEDURE Setup_History (p_id t_decimal14, p_start DATE, p_stop DATE);
END API$HIST;
/


/* Formatted on 8/12/2025 5:55:29 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.API$HIST
IS
    msgCOMMON_EXCEPTION   NUMBER := 2;

    FUNCTION get_unh_modes
        RETURN t_set_unh_modes
        PIPELINED
    IS
        v_unh_modes   t_unh_modes;
    BEGIN
        v_unh_modes.unhm_r_type := 2;
        v_unh_modes.unhm_mode := 2;
        PIPE ROW (v_unh_modes);
        v_unh_modes.unhm_r_type := 3;
        v_unh_modes.unhm_mode := 1;
        PIPE ROW (v_unh_modes);
        v_unh_modes.unhm_r_type := 4;
        v_unh_modes.unhm_mode := 1;
        PIPE ROW (v_unh_modes);
        v_unh_modes.unhm_r_type := 4;
        v_unh_modes.unhm_mode := 2;
        PIPE ROW (v_unh_modes);
        RETURN;
    END;

    PROCEDURE Setup_History (p_id t_decimal14, p_start DATE, p_stop DATE)
    IS
    BEGIN
        DELETE FROM tmp_unh_work_list
              WHERE 1 = 1;

        -- додавання нового значення
        INSERT INTO tmp_unh_work_list (work_obj,
                                       work_hst,
                                       work_begin,
                                       work_end)
             VALUES (p_id,
                     0,
                     p_start,
                     p_stop);

        -- видаляємо некоректні
        DELETE FROM tmp_unh_work_list
              WHERE work_begin > work_end;

        -- пошук граничних значень
        INSERT INTO tmp_real_work_list (wr_obj,
                                        wr_hst,
                                        wr_begin,
                                        wr_end)
            SELECT work_obj,
                   work_hst,
                   work_begin,
                   work_end
              FROM tmp_unh_work_list;

        UPDATE tmp_real_work_list
           SET wr_next_begin =
                   (SELECT MIN (work_begin)
                      FROM tmp_unh_work_list
                     WHERE work_obj = wr_obj AND work_begin > wr_end)
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_unh_work_list
                     WHERE work_obj = wr_obj AND work_begin > wr_end);

        UPDATE tmp_real_work_list
           SET wr_prev_end =
                   (SELECT MAX (work_end)
                      FROM tmp_unh_work_list
                     WHERE work_obj = wr_obj AND work_end < wr_begin)
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_unh_work_list
                     WHERE work_obj = wr_obj AND work_end < wr_begin);

        INSERT INTO tmp_unh_rz_list (rz_obj,
                                     rz_hst,
                                     rz_begin,
                                     rz_end)
            SELECT work_obj,
                   work_hst,
                   work_begin,
                   work_end
              FROM tmp_unh_work_list;

        -- беремо до уваги попередню історію
        INSERT INTO tmp_unh_to_prp (tprp_obj,
                                    tprp_hst,
                                    tprp_begin,
                                    tprp_end,
                                    tprp_r_type,
                                    tprp_new_begin,
                                    tprp_new_end,
                                    tprp_next_begin,
                                    tprp_prev_end)
            SELECT ol_obj,
                   ol_hst,
                   ol_begin,
                   ol_end,
                   CASE
                       WHEN ol_begin >= wr_begin
                       THEN
                           CASE
                               WHEN ol_end <= wr_end OR wr_end IS NULL THEN 1 --] такі стани видяляются бо повністю покриваються новим
                               WHEN ol_end > wr_end OR ol_end IS NULL THEN 2 --] для таких станів буде сгенеровано аналогічний стан, але початок дії - wr_end + 1 units day
                           END
                       ELSE
                           CASE
                               WHEN ol_end <= wr_end OR wr_end IS NULL THEN 3 --] таким станам буде сгенеровано аналогічний стан, але кінець дії - wr_begin - 1 units day
                               WHEN ol_end > wr_end OR ol_end IS NULL THEN 4 --] таким станам буде сгенеровано два стани типів 2 та 3
                           END
                   END,
                   wr_begin,
                   wr_end,
                   wr_next_begin,
                   wr_prev_end
              FROM tmp_unh_old_list, tmp_real_work_list
             WHERE     ol_obj = wr_obj
                   AND (   (    ol_begin >= wr_begin
                            AND (ol_begin <= wr_end OR wr_end IS NULL))
                        OR (    ol_begin < wr_begin
                            AND (ol_end >= wr_begin OR ol_end IS NULL)));

        -- нова історія
        INSERT INTO tmp_unh_rz_list (rz_obj,
                                     rz_hst,
                                     rz_begin,
                                     rz_end)
            SELECT tprp_obj,
                   tprp_hst,
                   CASE
                       WHEN unhm_mode = 1
                       THEN
                           CASE
                               WHEN     tprp_prev_end IS NOT NULL
                                    AND tprp_begin < tprp_prev_end
                               THEN
                                   TRUNC (tprp_prev_end + 1, 'DD')
                               ELSE
                                   TRUNC (tprp_begin, 'DD')
                           END
                       WHEN unhm_mode = 2
                       THEN
                           TRUNC (tprp_new_end + 1, 'DD')
                   END,
                   CASE
                       WHEN unhm_mode = 1
                       THEN
                           TRUNC (tprp_new_begin - 1, 'DD')
                       WHEN unhm_mode = 2
                       THEN
                           CASE
                               WHEN     tprp_next_begin IS NOT NULL
                                    AND tprp_next_begin < tprp_end
                               THEN
                                   TRUNC (tprp_next_begin - 1, 'DD')
                               ELSE
                                   TRUNC (tprp_end, 'DD')
                           END
                   END
              FROM tmp_unh_to_prp, TABLE (get_unh_modes)
             WHERE     tprp_r_type = unhm_r_type
                   AND NOT (    unhm_mode = 2
                            AND tprp_next_begin IS NOT NULL
                            AND tprp_next_begin <= tprp_end);
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'HistSession.Setup_History',
                                               CHR (10) || SQLERRM));
    END;
BEGIN
    NULL;
END API$HIST;
/