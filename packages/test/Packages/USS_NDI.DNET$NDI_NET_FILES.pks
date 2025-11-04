/* Formatted on 8/12/2025 5:55:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.DNET$NDI_NET_FILES
IS
    -- Отримати запис по ідентифікатору
    PROCEDURE get_net_files (p_nnf_id   IN     ndi_net_files.nnf_id%TYPE,
                             p_res         OUT SYS_REFCURSOR);

    -- Список за фільтром
    PROCEDURE query_net_files (p_nnf_nb     IN     NUMBER,
                               p_nnf_net    IN     NUMBER,
                               p_nnf_name   IN     VARCHAR2,
                               p_res           OUT SYS_REFCURSOR);

    PROCEDURE delete_net_files (p_nnf_id IN ndi_net_files.nnf_id%TYPE);

    PROCEDURE save_net_files (
        p_nnf_id           IN     ndi_net_files.nnf_id%TYPE,
        p_nnf_nb           IN     ndi_net_files.nnf_nb%TYPE,
        p_nnf_net          IN     ndi_net_files.nnf_net%TYPE,
        p_nnf_name         IN     ndi_net_files.nnf_name%TYPE,
        p_nnf_format_tp    IN     ndi_net_files.nnf_format_tp%TYPE,
        p_nnf_data_order   IN     ndi_net_files.nnf_data_order%TYPE,
        p_nnf_naming_alg   IN     ndi_net_files.nnf_naming_alg%TYPE,
        p_nnf_locale_tp    IN     ndi_net_files.nnf_locale_tp%TYPE,
        p_new_id              OUT ndi_net_files.nnf_id%TYPE);

    -- картка
    PROCEDURE get_net_files_card (p_nnf_id   IN     NUMBER,
                                  res_cur       OUT SYS_REFCURSOR,
                                  col_cur       OUT SYS_REFCURSOR,
                                  src_cur       OUT SYS_REFCURSOR);

    PROCEDURE save_net_files_card (
        p_nnf_id           IN     ndi_net_files.nnf_id%TYPE,
        p_nnf_nb           IN     ndi_net_files.nnf_nb%TYPE,
        p_nnf_net          IN     ndi_net_files.nnf_net%TYPE,
        p_nnf_name         IN     ndi_net_files.nnf_name%TYPE,
        p_nnf_format_tp    IN     ndi_net_files.nnf_format_tp%TYPE,
        p_nnf_data_order   IN     ndi_net_files.nnf_data_order%TYPE,
        p_nnf_naming_alg   IN     ndi_net_files.nnf_naming_alg%TYPE,
        p_nnf_locale_tp    IN     ndi_net_files.nnf_locale_tp%TYPE,
        p_xml              IN     CLOB,
        p_new_id              OUT uss_ndi.ndi_net_files.nnf_id%TYPE);

    PROCEDURE get_src_cols (p_nnf_id   IN     ndi_net_files.nnf_id%TYPE,
                            p_net_id   IN     ndi_export_type.net_id%TYPE,
                            p_res         OUT SYS_REFCURSOR);
END dnet$ndi_net_files;
/


GRANT EXECUTE ON USS_NDI.DNET$NDI_NET_FILES TO DNET_PROXY
/


/* Formatted on 8/12/2025 5:55:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.DNET$NDI_NET_FILES
IS
    -- unused
    PROCEDURE get_net_files (p_nnf_id   IN     ndi_net_files.nnf_id%TYPE,
                             p_res         OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR SELECT nnf_id,
                              -- NDI_BANK
                              nnf_nb,
                              -- NDI_EXPORT_TYPE
                              nnf_net,
                              nnf_name,
                              nnf_format_tp,
                              nnf_data_order,
                              nnf_naming_alg,
                              nnf_locale_tp,
                              history_status,
                              -- HISTSESSION
                              nnf_hs_upd,
                              -- HISTSESSION
                              nnf_hs_del
                         FROM ndi_net_files
                        WHERE nnf_id = p_nnf_id;
    END;

    -- Список за фільтром
    PROCEDURE query_net_files (p_nnf_nb     IN     NUMBER,
                               p_nnf_net    IN     NUMBER,
                               p_nnf_name   IN     VARCHAR2,
                               p_res           OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT nf.nnf_id,
                   -- NDI_BANK
                   nf.nnf_nb,
                   -- NDI_EXPORT_TYPE
                   nf.nnf_net,
                   nf.nnf_name,
                   nf.nnf_format_tp,
                   nf.nnf_data_order,
                   nf.nnf_naming_alg,
                   nf.nnf_locale_tp,
                   nf.history_status,
                   -- HISTSESSION
                   nf.nnf_hs_upd,
                   -- HISTSESSION
                   nf.nnf_hs_del,
                   nb.nb_name,
                   et.net_name,
                   ---
                   lt.dic_name     AS nnf_lt_name
              FROM ndi_net_files  nf
                   LEFT JOIN ndi_bank nb ON nf.nnf_nb = nb.nb_id
                   LEFT JOIN ndi_export_type et ON nf.nnf_net = et.net_id
                   LEFT JOIN v_ddn_nnf_locale_tp lt
                       ON (nf.nnf_locale_tp = lt.dic_value)
             WHERE     nf.history_status = 'A'
                   AND (p_nnf_nb IS NULL OR nf.nnf_nb = p_nnf_nb)
                   AND (p_nnf_net IS NULL OR nf.nnf_net = p_nnf_net)
                   AND (   p_nnf_name IS NULL
                        OR nf.nnf_name LIKE '%' || p_nnf_name || '%'
                        OR nf.nnf_name LIKE p_nnf_name || '%');
    END;

    PROCEDURE delete_net_files (p_nnf_id IN ndi_net_files.nnf_id%TYPE)
    IS
    BEGIN
        api$ndi_net_files.delete_net_files (p_nnf_id => p_nnf_id);
    END;

    --unused
    PROCEDURE save_net_files (
        p_nnf_id           IN     ndi_net_files.nnf_id%TYPE,
        p_nnf_nb           IN     ndi_net_files.nnf_nb%TYPE,
        p_nnf_net          IN     ndi_net_files.nnf_net%TYPE,
        p_nnf_name         IN     ndi_net_files.nnf_name%TYPE,
        p_nnf_format_tp    IN     ndi_net_files.nnf_format_tp%TYPE,
        p_nnf_data_order   IN     ndi_net_files.nnf_data_order%TYPE,
        p_nnf_naming_alg   IN     ndi_net_files.nnf_naming_alg%TYPE,
        p_nnf_locale_tp    IN     ndi_net_files.nnf_locale_tp%TYPE,
        p_new_id              OUT ndi_net_files.nnf_id%TYPE)
    IS
    BEGIN
        api$ndi_net_files.save_net_files (
            p_nnf_id           => p_nnf_id,
            p_nnf_nb           => p_nnf_nb,
            p_nnf_net          => p_nnf_net,
            p_nnf_name         => p_nnf_name,
            p_nnf_format_tp    => p_nnf_format_tp,
            p_nnf_data_order   => p_nnf_data_order,
            p_nnf_naming_alg   => p_nnf_naming_alg,
            p_nnf_locale_tp    => p_nnf_locale_tp,
            p_history_status   => api$dic_visit.c_history_status_actual,
            p_nnf_hs_upd       => NULL,
            p_nnf_hs_del       => NULL,
            p_new_id           => p_new_id);
    END;

    -- картка
    PROCEDURE get_net_files_card (p_nnf_id   IN     NUMBER,
                                  res_cur       OUT SYS_REFCURSOR,
                                  col_cur       OUT SYS_REFCURSOR,
                                  src_cur       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR SELECT f.*
                           /*  ,
                           lt.dic_name AS nnf_lt_name,
                            na.dic_name AS nnf_na_name,
                            ft.dic_name AS nnf_ft_name*/
                           FROM ndi_net_files f
                          /* LEFT JOIN v_ddn_nnf_locale_tp lt
                          ON (f.nnf_locale_tp = lt.dic_value)
                          LEFT JOIN v_ddn_nnf_naming_alg na
                          ON (f.nnf_naming_alg = na.dic_value)
                          LEFT JOIN v_ddn_nnf_format_tp ft
                          ON (f.nnf_format_tp = ft.dic_value)*/
                          WHERE f.nnf_id = p_nnf_id;

        OPEN col_cur FOR
            SELECT fc.*, sc.nnsc_col_name AS nnfc_nnsc_name
              FROM ndi_net_file_cols  fc
                   LEFT JOIN ndi_net_src_cols sc ON sc.nnsc_id = fc.nnfc_nnsc
             WHERE fc.nnfc_nnf = p_nnf_id AND fc.history_status = 'A';

        OPEN src_cur FOR SELECT sc.*
                           FROM ndi_net_src_cols sc
                          WHERE sc.nnsc_net IN (SELECT nf.nnf_net
                                                  FROM ndi_net_files nf
                                                 WHERE nf.nnf_id = p_nnf_id);
    END;

    -- збереження картки
    PROCEDURE save_net_files_card (
        p_nnf_id           IN     ndi_net_files.nnf_id%TYPE,
        p_nnf_nb           IN     ndi_net_files.nnf_nb%TYPE,
        p_nnf_net          IN     ndi_net_files.nnf_net%TYPE,
        p_nnf_name         IN     ndi_net_files.nnf_name%TYPE,
        p_nnf_format_tp    IN     ndi_net_files.nnf_format_tp%TYPE,
        p_nnf_data_order   IN     ndi_net_files.nnf_data_order%TYPE,
        p_nnf_naming_alg   IN     ndi_net_files.nnf_naming_alg%TYPE,
        p_nnf_locale_tp    IN     ndi_net_files.nnf_locale_tp%TYPE,
        p_xml              IN     CLOB,
        p_new_id              OUT uss_ndi.ndi_net_files.nnf_id%TYPE)
    IS
    BEGIN
        api$ndi_net_files.save_net_files_card (
            p_nnf_id           => p_nnf_id,
            p_nnf_nb           => p_nnf_nb,
            p_nnf_net          => p_nnf_net,
            p_nnf_name         => p_nnf_name,
            p_nnf_format_tp    => p_nnf_format_tp,
            p_nnf_data_order   => p_nnf_data_order,
            p_nnf_naming_alg   => p_nnf_naming_alg,
            p_nnf_locale_tp    => p_nnf_locale_tp,
            p_history_status   => api$dic_visit.c_history_status_actual,
            p_nnf_hs_upd       => NULL,
            p_nnf_hs_del       => NULL,
            p_xml              => p_xml,
            p_new_id           => p_new_id);
    END;

    PROCEDURE get_src_cols (p_nnf_id   IN     ndi_net_files.nnf_id%TYPE,
                            p_net_id   IN     ndi_export_type.net_id%TYPE,
                            p_res         OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR SELECT sc.*
                         FROM ndi_net_src_cols sc
                        WHERE sc.nnsc_net = p_net_id;
    END;
END dnet$ndi_net_files;
/