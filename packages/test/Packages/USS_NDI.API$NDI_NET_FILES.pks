/* Formatted on 8/12/2025 5:55:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.API$NDI_NET_FILES
IS
    Package_Name   CONSTANT VARCHAR2 (100) := 'API$NDI_NET_FILES';

    TYPE r_ndi_net_file_cols IS RECORD
    (
        Nnfc_id                ndi_net_file_cols.nnfc_id%TYPE,
        Nnfc_nnf               ndi_net_file_cols.nnfc_nnf%TYPE,
        Nnfc_nnsc              ndi_net_file_cols.nnfc_nnsc%TYPE,
        Nnfc_dest_col_name     ndi_net_file_cols.nnfc_dest_col_name%TYPE,
        Nnfc_dest_col_type     ndi_net_file_cols.nnfc_dest_col_type%TYPE,
        Nnfc_dest_col_order    ndi_net_file_cols.nnfc_dest_col_order%TYPE,
        Nnfc_description       ndi_net_file_cols.nnfc_description%TYPE,
        History_status         ndi_net_file_cols.history_status%TYPE
    );

    TYPE t_ndi_net_file_cols IS TABLE OF r_ndi_net_file_cols;

    -- Зберегти  unused
    PROCEDURE save_net_files (
        p_nnf_id           IN     ndi_net_files.nnf_id%TYPE,
        p_nnf_nb           IN     ndi_net_files.nnf_nb%TYPE,
        p_nnf_net          IN     ndi_net_files.nnf_net%TYPE,
        p_nnf_name         IN     ndi_net_files.nnf_name%TYPE,
        p_nnf_format_tp    IN     ndi_net_files.nnf_format_tp%TYPE,
        p_nnf_data_order   IN     ndi_net_files.nnf_data_order%TYPE,
        p_nnf_naming_alg   IN     ndi_net_files.nnf_naming_alg%TYPE,
        p_nnf_locale_tp    IN     ndi_net_files.nnf_locale_tp%TYPE,
        p_history_status   IN     ndi_net_files.history_status%TYPE,
        p_nnf_hs_upd       IN     ndi_net_files.nnf_hs_upd%TYPE,
        p_nnf_hs_del       IN     ndi_net_files.nnf_hs_del%TYPE,
        p_new_id              OUT ndi_net_files.nnf_id%TYPE);

    -- Вилучити    unused
    PROCEDURE delete_net_files (p_nnf_id IN ndi_net_files.nnf_id%TYPE);

    PROCEDURE save_net_files_card (
        p_nnf_id           IN     ndi_net_files.nnf_id%TYPE,
        p_nnf_nb           IN     ndi_net_files.nnf_nb%TYPE,
        p_nnf_net          IN     ndi_net_files.nnf_net%TYPE,
        p_nnf_name         IN     ndi_net_files.nnf_name%TYPE,
        p_nnf_format_tp    IN     ndi_net_files.nnf_format_tp%TYPE,
        p_nnf_data_order   IN     ndi_net_files.nnf_data_order%TYPE,
        p_nnf_naming_alg   IN     ndi_net_files.nnf_naming_alg%TYPE,
        p_nnf_locale_tp    IN     ndi_net_files.nnf_locale_tp%TYPE,
        p_history_status   IN     ndi_net_files.history_status%TYPE,
        p_nnf_hs_upd       IN     ndi_net_files.nnf_hs_upd%TYPE,
        p_nnf_hs_del       IN     ndi_net_files.nnf_hs_del%TYPE,
        p_xml              IN     CLOB,
        p_new_id              OUT uss_ndi.ndi_net_files.nnf_id%TYPE);
END api$ndi_net_files;
/


/* Formatted on 8/12/2025 5:55:29 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.API$NDI_NET_FILES
IS
    -- Зберегти unused
    PROCEDURE save_net_files (
        p_nnf_id           IN     ndi_net_files.nnf_id%TYPE,
        p_nnf_nb           IN     ndi_net_files.nnf_nb%TYPE,
        p_nnf_net          IN     ndi_net_files.nnf_net%TYPE,
        p_nnf_name         IN     ndi_net_files.nnf_name%TYPE,
        p_nnf_format_tp    IN     ndi_net_files.nnf_format_tp%TYPE,
        p_nnf_data_order   IN     ndi_net_files.nnf_data_order%TYPE,
        p_nnf_naming_alg   IN     ndi_net_files.nnf_naming_alg%TYPE,
        p_nnf_locale_tp    IN     ndi_net_files.nnf_locale_tp%TYPE,
        p_history_status   IN     ndi_net_files.history_status%TYPE,
        p_nnf_hs_upd       IN     ndi_net_files.nnf_hs_upd%TYPE,
        p_nnf_hs_del       IN     ndi_net_files.nnf_hs_del%TYPE,
        p_new_id              OUT ndi_net_files.nnf_id%TYPE)
    IS
    BEGIN
        IF p_nnf_id IS NULL
        THEN
            INSERT INTO ndi_net_files (nnf_nb,
                                       nnf_net,
                                       nnf_name,
                                       nnf_format_tp,
                                       nnf_data_order,
                                       nnf_naming_alg,
                                       nnf_locale_tp,
                                       history_status,
                                       nnf_hs_upd,
                                       nnf_hs_del)
                 VALUES (p_nnf_nb,
                         p_nnf_net,
                         p_nnf_name,
                         p_nnf_format_tp,
                         p_nnf_data_order,
                         p_nnf_naming_alg,
                         p_nnf_locale_tp,
                         p_history_status,
                         p_nnf_hs_upd,
                         p_nnf_hs_del)
              RETURNING nnf_id
                   INTO p_new_id;
        ELSE
            p_new_id := p_nnf_id;

            UPDATE ndi_net_files
               SET nnf_nb = p_nnf_nb,
                   nnf_net = p_nnf_net,
                   nnf_name = p_nnf_name,
                   nnf_format_tp = p_nnf_format_tp,
                   nnf_data_order = p_nnf_data_order,
                   nnf_naming_alg = p_nnf_naming_alg,
                   nnf_locale_tp = p_nnf_locale_tp,
                   history_status = p_history_status,
                   nnf_hs_upd = tools.gethistsession,
                   nnf_hs_del = p_nnf_hs_del
             WHERE nnf_id = p_nnf_id;
        END IF;
    END;

    -- Вилучити
    PROCEDURE delete_net_files (p_nnf_id IN ndi_net_files.nnf_id%TYPE)
    IS
    BEGIN
        UPDATE ndi_net_files nf
           SET nf.nnf_hs_del = tools.gethistsession,
               nf.history_status = api$dic_visit.c_history_status_historical
         WHERE p_nnf_id = nf.nnf_id;
    END;

    PROCEDURE save_net_files_card (
        p_nnf_id           IN     ndi_net_files.nnf_id%TYPE,
        p_nnf_nb           IN     ndi_net_files.nnf_nb%TYPE,
        p_nnf_net          IN     ndi_net_files.nnf_net%TYPE,
        p_nnf_name         IN     ndi_net_files.nnf_name%TYPE,
        p_nnf_format_tp    IN     ndi_net_files.nnf_format_tp%TYPE,
        p_nnf_data_order   IN     ndi_net_files.nnf_data_order%TYPE,
        p_nnf_naming_alg   IN     ndi_net_files.nnf_naming_alg%TYPE,
        p_nnf_locale_tp    IN     ndi_net_files.nnf_locale_tp%TYPE,
        p_history_status   IN     ndi_net_files.history_status%TYPE,
        p_nnf_hs_upd       IN     ndi_net_files.nnf_hs_upd%TYPE,
        p_nnf_hs_del       IN     ndi_net_files.nnf_hs_del%TYPE,
        p_xml              IN     CLOB,
        p_new_id              OUT uss_ndi.ndi_net_files.nnf_id%TYPE)
    IS
        l_ids   VARCHAR2 (4000);
        l_arr   t_ndi_net_file_cols;
    BEGIN
        EXECUTE IMMEDIATE type2xmltable (Package_Name,
                                         't_ndi_net_file_cols',
                                         TRUE)
            BULK COLLECT INTO l_arr
            USING p_xml;

        -- create
        IF (p_nnf_id IS NULL OR p_nnf_id = -1)
        THEN
            INSERT INTO ndi_net_files (nnf_nb,
                                       nnf_net,
                                       nnf_name,
                                       nnf_format_tp,
                                       nnf_data_order,
                                       nnf_naming_alg,
                                       nnf_locale_tp,
                                       history_status,
                                       nnf_hs_upd,
                                       nnf_hs_del)
                 VALUES (p_nnf_nb,
                         p_nnf_net,
                         p_nnf_name,
                         p_nnf_format_tp,
                         p_nnf_data_order,
                         p_nnf_naming_alg,
                         p_nnf_locale_tp,
                         p_history_status,
                         p_nnf_hs_upd,
                         p_nnf_hs_del)
              RETURNING nnf_id
                   INTO p_new_id;

            FOR xx IN (SELECT * FROM TABLE (l_arr))
            LOOP
                INSERT INTO ndi_net_file_cols (nnfc_nnf,
                                               nnfc_nnsc,
                                               nnfc_dest_col_name,
                                               nnfc_dest_col_type,
                                               nnfc_dest_col_order,
                                               nnfc_description,
                                               history_status)
                     VALUES (p_new_id,
                             xx.nnfc_nnsc,
                             xx.nnfc_dest_col_name,
                             xx.nnfc_dest_col_type,
                             xx.nnfc_dest_col_order,
                             xx.nnfc_description,
                             api$dic_visit.c_history_status_actual);
            END LOOP;
        -- update
        ELSE
            p_new_id := p_nnf_id;

            UPDATE ndi_net_files
               SET nnf_nb = p_nnf_nb,
                   nnf_net = p_nnf_net,
                   nnf_name = p_nnf_name,
                   nnf_format_tp = p_nnf_format_tp,
                   nnf_data_order = p_nnf_data_order,
                   nnf_naming_alg = p_nnf_naming_alg,
                   nnf_locale_tp = p_nnf_locale_tp,
                   history_status = p_history_status,
                   nnf_hs_upd = p_nnf_hs_upd,
                   nnf_hs_del = p_nnf_hs_del
             WHERE nnf_id = p_new_id;

            SELECT LISTAGG (nnfc_id, ',') WITHIN GROUP (ORDER BY 1)
              INTO l_ids
              FROM TABLE (l_arr)
             WHERE nnfc_id IS NOT NULL;

            -- deleted
            UPDATE ndi_net_file_cols t
               SET t.history_status = 'H'
             WHERE     t.nnfc_nnf = p_new_id
                   AND (   l_ids IS NULL
                        OR t.nnfc_id NOT IN
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

            -- new
            FOR xx IN (SELECT *
                         FROM TABLE (l_arr) t
                        WHERE t.nnfc_id IS NULL OR t.nnfc_id < 0)
            LOOP
                INSERT INTO ndi_net_file_cols (nnfc_nnf,
                                               nnfc_nnsc,
                                               nnfc_dest_col_name,
                                               nnfc_dest_col_type,
                                               nnfc_dest_col_order,
                                               nnfc_description,
                                               history_status)
                     VALUES (p_new_id,
                             xx.nnfc_nnsc,
                             xx.nnfc_dest_col_name,
                             xx.nnfc_dest_col_type,
                             xx.nnfc_dest_col_order,
                             xx.nnfc_description,
                             api$dic_visit.c_history_status_actual);
            END LOOP;

            -- updated
            FOR xx IN (SELECT *
                         FROM TABLE (l_arr) t
                        WHERE t.nnfc_id > 0)
            LOOP
                UPDATE ndi_net_file_cols
                   SET nnfc_nnf = xx.nnfc_nnf,
                       nnfc_nnsc = xx.nnfc_nnsc,
                       nnfc_dest_col_name = xx.nnfc_dest_col_name,
                       nnfc_dest_col_type = xx.nnfc_dest_col_type,
                       nnfc_dest_col_order = xx.nnfc_dest_col_order,
                       nnfc_description = xx.nnfc_description,
                       history_status = api$dic_visit.c_history_status_actual
                 WHERE nnfc_id = xx.nnfc_id;
            END LOOP;
        END IF;
    END;
END api$ndi_net_files;
/