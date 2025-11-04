/* Formatted on 8/12/2025 5:55:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.API$NDI_EXPORT_TYPE
IS
    TYPE r_ndi_net_src_col IS RECORD
    (
        NNSC_ID             ndi_net_src_cols.NNSC_ID%TYPE,
        NNSC_NET            ndi_net_src_cols.NNSC_NET%TYPE,
        NNSC_COL_NAME       ndi_net_src_cols.NNSC_COL_NAME%TYPE,
        NNSC_DESCRIPTION    ndi_net_src_cols.NNSC_DESCRIPTION%TYPE,
        HISTORY_STATUS      ndi_net_src_cols.HISTORY_STATUS%TYPE
    );

    TYPE t_ndi_net_src_col IS TABLE OF r_ndi_net_src_col;

    -- Отримати запис по ідентифікатору
    PROCEDURE get_export_type (p_id          IN     ndi_export_type.net_id%TYPE,
                               p_res            OUT SYS_REFCURSOR,
                               columns_cur      OUT SYS_REFCURSOR);

    -- Зберегти
    PROCEDURE save_export_type (
        p_net_id           IN     ndi_export_type.net_id%TYPE,
        p_net_data_tp      IN     ndi_export_type.net_data_tp%TYPE,
        p_net_name         IN     ndi_export_type.net_name%TYPE,
        p_net_src_table    IN     ndi_export_type.net_src_table%TYPE,
        p_history_status   IN     ndi_export_type.history_status%TYPE,
        p_xml              IN     CLOB,
        p_new_id              OUT ndi_export_type.net_id%TYPE);

    -- Вилучити
    PROCEDURE delete_export_type (p_id ndi_export_type.net_id%TYPE);

    -- Список за фільтром
    PROCEDURE query_export_type (p_net_data_tp   IN     VARCHAR2,
                                 p_net_name      IN     VARCHAR2,
                                 p_res              OUT SYS_REFCURSOR);
END api$ndi_export_type;
/


/* Formatted on 8/12/2025 5:55:29 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.API$NDI_EXPORT_TYPE
IS
    -- Отримати запис по ідентифікатору
    PROCEDURE get_export_type (p_id          IN     ndi_export_type.net_id%TYPE,
                               p_res            OUT SYS_REFCURSOR,
                               columns_cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR SELECT net_id,
                              net_data_tp,
                              net_name,
                              net_src_table,
                              history_status,
                              net_hs_upd,
                              net_hs_del
                         FROM ndi_export_type
                        WHERE net_id = p_id;

        OPEN columns_cur FOR SELECT *
                               FROM v_ndi_net_src_cols
                              WHERE nnsc_net = p_id AND history_status = 'A';
    END;

    -- Зберегти
    PROCEDURE save_export_type (
        p_net_id           IN     ndi_export_type.net_id%TYPE,
        p_net_data_tp      IN     ndi_export_type.net_data_tp%TYPE,
        p_net_name         IN     ndi_export_type.net_name%TYPE,
        p_net_src_table    IN     ndi_export_type.net_src_table%TYPE,
        p_history_status   IN     ndi_export_type.history_status%TYPE,
        p_xml              IN     CLOB,
        p_new_id              OUT ndi_export_type.net_id%TYPE)
    IS
        l_ids   VARCHAR2 (2000);
        l_arr   t_ndi_net_src_col;
    BEGIN
        --RAISE_APPLICATION_ERROR(-20002, p_xml);
        EXECUTE IMMEDIATE Type2xmltable ('API$NDI_EXPORT_TYPE',
                                         't_ndi_net_src_col',
                                         TRUE)
            BULK COLLECT INTO l_arr
            USING p_xml;

        IF (p_net_id IS NULL OR p_net_id = -1)
        THEN                         --создаем новую запись "тип вивантаження"
            INSERT INTO ndi_export_type (net_data_tp,
                                         net_name,
                                         net_src_table,
                                         history_status,
                                         net_hs_upd,
                                         net_hs_del)
                 VALUES (p_net_data_tp,
                         p_net_name,
                         p_net_src_table,
                         p_history_status,
                         tools.gethistsession,
                         NULL)
              RETURNING net_id
                   INTO p_new_id;

            --вставляем "Стовпчики в таблиці"
            FOR xx IN (SELECT * FROM TABLE (l_arr))
            LOOP
                INSERT INTO ndi_net_src_cols (NNSC_NET,
                                              NNSC_COL_NAME,
                                              NNSC_DESCRIPTION,
                                              HISTORY_STATUS)
                     VALUES (p_new_id,
                             xx.NNSC_COL_NAME,
                             xx.NNSC_DESCRIPTION,
                             'A');
            END LOOP;
        ELSE                             --обновляем запись "тип вивантаження"
            p_new_id := p_net_id;

            UPDATE ndi_export_type
               SET net_data_tp = p_net_data_tp,
                   net_name = p_net_name,
                   net_src_table = p_net_src_table,
                   history_status = p_history_status,
                   net_hs_upd = tools.gethistsession,
                   net_hs_del = NULL
             WHERE net_id = p_net_id;

            --вставляем/обновляем/"удаляем" "Стовпчики в таблиці"
            SELECT LISTAGG (NNSC_ID, ',') WITHIN GROUP (ORDER BY 1)
              INTO l_ids
              FROM TABLE (l_arr)
             WHERE NNSC_ID IS NOT NULL;

            --"Стовпчики в таблиці" был удален
            UPDATE ndi_net_src_cols t
               SET t.history_status = 'H'
             WHERE     t.NNSC_NET = p_new_id
                   AND (   l_ids IS NULL
                        OR t.NNSC_ID NOT IN
                               (    SELECT REGEXP_SUBSTR (
                                               text,
                                               '[^(\,)]+',
                                               1,
                                               LEVEL)    AS z_rdt_id
                                      FROM (SELECT l_ids AS text FROM DUAL)
                                CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                                  '[^(\,)]+',
                                                                  1,
                                                                  LEVEL)) > 0));

            --новый "Стовпчики в таблиці"
            FOR xx IN (SELECT *
                         FROM TABLE (l_arr) t
                        WHERE t.NNSC_ID IS NULL OR t.NNSC_ID < 0)
            LOOP
                INSERT INTO ndi_net_src_cols (NNSC_NET,
                                              NNSC_COL_NAME,
                                              NNSC_DESCRIPTION,
                                              HISTORY_STATUS)
                     VALUES (p_new_id,
                             xx.NNSC_COL_NAME,
                             xx.NNSC_DESCRIPTION,
                             'A');
            END LOOP;

            --"Стовпчики в таблиці" был обновлен
            FOR xx IN (SELECT *
                         FROM TABLE (l_arr) t
                        WHERE t.NNSC_ID > 0)
            LOOP
                UPDATE ndi_net_src_cols
                   SET NNSC_NET = xx.NNSC_NET,
                       NNSC_COL_NAME = xx.NNSC_COL_NAME,
                       NNSC_DESCRIPTION = xx.NNSC_DESCRIPTION
                 WHERE NNSC_ID = xx.NNSC_ID;
            END LOOP;
        END IF;
    END;

    -- Вилучити
    PROCEDURE delete_export_type (p_id ndi_export_type.net_id%TYPE)
    IS
    BEGIN
        UPDATE ndi_export_type
           SET net_hs_del = tools.gethistsession, history_status = 'H'
         WHERE net_id = p_id;
    END;

    -- Список за фільтром
    PROCEDURE query_export_type (p_net_data_tp   IN     VARCHAR2,
                                 p_net_name      IN     VARCHAR2,
                                 p_res              OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT net.net_id,
                   dtp.dic_sname     AS net_data_tp,       -- net.net_data_tp,
                   net.net_name,
                   net.net_src_table,
                   net.history_status,
                   net.net_hs_upd,
                   net.net_hs_del
              FROM ndi_export_type  net
                   LEFT JOIN v_ddn_net_data_tp dtp
                       ON net.net_data_tp = dtp.dic_value
             WHERE     net.history_status = 'A'
                   AND (net.net_name LIKE '%' || p_net_name || '%')
                   AND (   p_net_data_tp IS NULL
                        OR net.net_data_tp = p_net_data_tp);
    END;
END api$ndi_export_type;
/