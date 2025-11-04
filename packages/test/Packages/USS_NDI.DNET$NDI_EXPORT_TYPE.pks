/* Formatted on 8/12/2025 5:55:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.DNET$NDI_EXPORT_TYPE
IS
    -- Отримати запис по ідентифікатору
    PROCEDURE get_export_type (p_id          IN     ndi_export_type.net_id%TYPE,
                               p_res            OUT SYS_REFCURSOR,
                               columns_cur      OUT SYS_REFCURSOR);

    -- Список за фільтром
    PROCEDURE query_export_type (p_net_data_tp   IN     VARCHAR2,
                                 p_net_name      IN     VARCHAR2,
                                 p_res              OUT SYS_REFCURSOR);

    -- Вилучити
    PROCEDURE delete_export_type (p_id ndi_export_type.net_id%TYPE);

    -- Зберегти
    PROCEDURE save_export_type (
        p_net_id          IN     ndi_export_type.net_id%TYPE,
        p_net_data_tp     IN     ndi_export_type.net_data_tp%TYPE,
        p_net_name        IN     ndi_export_type.net_name%TYPE,
        p_net_src_table   IN     ndi_export_type.net_src_table%TYPE,
        p_xml             IN     CLOB,
        p_new_id             OUT ndi_export_type.net_id%TYPE);
END dnet$ndi_export_type;
/


GRANT EXECUTE ON USS_NDI.DNET$NDI_EXPORT_TYPE TO DNET_PROXY
/


/* Formatted on 8/12/2025 5:55:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.DNET$NDI_EXPORT_TYPE
IS
    -- Отримати запис по ідентифікатору
    PROCEDURE get_export_type (p_id          IN     ndi_export_type.net_id%TYPE,
                               p_res            OUT SYS_REFCURSOR,
                               columns_cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        api$ndi_export_type.get_export_type (p_id          => p_id,
                                             columns_cur   => columns_cur,
                                             p_res         => p_res);
    END;

    -- Список за фільтром
    PROCEDURE query_export_type (p_net_data_tp   IN     VARCHAR2,
                                 p_net_name      IN     VARCHAR2,
                                 p_res              OUT SYS_REFCURSOR)
    IS
    BEGIN
        api$ndi_export_type.query_export_type (
            p_net_data_tp   => p_net_data_tp,
            p_net_name      => p_net_name,
            p_res           => p_res);
    END;

    -- Вилучити
    PROCEDURE delete_export_type (p_id ndi_export_type.net_id%TYPE)
    IS
    BEGIN
        api$ndi_export_type.delete_export_type (p_id => p_id);
    END;

    -- Зберегти
    PROCEDURE save_export_type (
        p_net_id          IN     ndi_export_type.net_id%TYPE,
        p_net_data_tp     IN     ndi_export_type.net_data_tp%TYPE,
        p_net_name        IN     ndi_export_type.net_name%TYPE,
        p_net_src_table   IN     ndi_export_type.net_src_table%TYPE,
        p_xml             IN     CLOB,
        p_new_id             OUT ndi_export_type.net_id%TYPE)
    IS
    BEGIN
        api$ndi_export_type.save_export_type (
            p_net_id           => p_net_id,
            p_net_data_tp      => p_net_data_tp,
            p_net_name         => p_net_name,
            p_net_src_table    => p_net_src_table,
            p_history_status   => api$dic_visit.c_history_status_actual,
            p_xml              => p_xml,
            p_new_id           => p_new_id);
    END;
END dnet$ndi_export_type;
/