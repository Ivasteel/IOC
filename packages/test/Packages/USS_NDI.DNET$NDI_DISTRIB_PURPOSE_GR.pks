/* Formatted on 8/12/2025 5:55:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.DNET$NDI_DISTRIB_PURPOSE_GR
IS
    --GET BY ID
    PROCEDURE get_distrib_purpose_gr (
        p_id    IN     ndi_distrib_purpose_gr.dpg_id%TYPE,
        p_res      OUT SYS_REFCURSOR);

    --LIST
    PROCEDURE query_distrib_purpose_gr (p_dpg_name   IN     VARCHAR2,
                                        p_res           OUT SYS_REFCURSOR);

    --DELETE
    PROCEDURE delete_distrib_purpose_gr (
        p_id   ndi_distrib_purpose_gr.dpg_id%TYPE);

    --SAVE
    PROCEDURE save_distrib_purpose_gr (
        p_dpg_id           IN     ndi_distrib_purpose_gr.dpg_id%TYPE,
        p_dpg_name         IN     ndi_distrib_purpose_gr.dpg_name%TYPE,
        p_dpg_is_gov       IN     ndi_distrib_purpose_gr.dpg_is_gov%TYPE,
        p_dpg_is_own       IN     ndi_distrib_purpose_gr.dpg_is_own%TYPE,
        p_dpg_template     IN     ndi_distrib_purpose_gr.dpg_template%TYPE,
        p_dpg_tp           IN     ndi_distrib_purpose_gr.dpg_tp%TYPE,
        p_dpg_hs_del       IN     ndi_distrib_purpose_gr.dpg_hs_del%TYPE,
        p_dpg_hs_upd       IN     ndi_distrib_purpose_gr.dpg_hs_upd%TYPE,
        p_history_status   IN     ndi_distrib_purpose_gr.history_status%TYPE,
        p_new_id              OUT ndi_distrib_purpose_gr.dpg_id%TYPE);
END dnet$ndi_distrib_purpose_gr;
/


GRANT EXECUTE ON USS_NDI.DNET$NDI_DISTRIB_PURPOSE_GR TO DNET_PROXY
/


/* Formatted on 8/12/2025 5:55:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.DNET$NDI_DISTRIB_PURPOSE_GR
IS
    --Отримати запис по ідентифікатору
    PROCEDURE get_distrib_purpose_gr (
        p_id    IN     ndi_distrib_purpose_gr.dpg_id%TYPE,
        p_res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        api$ndi_distrib_purpose_gr.get_distrib_purpose_gr (p_id    => p_id,
                                                           p_res   => p_res);
    END;

    --Список за фільтром
    PROCEDURE query_distrib_purpose_gr (p_dpg_name   IN     VARCHAR2,
                                        p_res           OUT SYS_REFCURSOR)
    IS
    BEGIN
        -- RAISE_APPLICATION_ERROR(-20002, 'test');
        api$ndi_distrib_purpose_gr.query_distrib_purpose_gr (
            p_dpg_name   => p_dpg_name,
            p_res        => p_res);
    END;

    --Вилучити
    PROCEDURE delete_distrib_purpose_gr (
        p_id   ndi_distrib_purpose_gr.dpg_id%TYPE)
    IS
    BEGIN
        api$ndi_distrib_purpose_gr.delete_distrib_purpose_gr (p_id => p_id);
    END;

    --Зберегти
    PROCEDURE save_distrib_purpose_gr (
        p_dpg_id           IN     ndi_distrib_purpose_gr.dpg_id%TYPE,
        p_dpg_name         IN     ndi_distrib_purpose_gr.dpg_name%TYPE,
        p_dpg_is_gov       IN     ndi_distrib_purpose_gr.dpg_is_gov%TYPE,
        p_dpg_is_own       IN     ndi_distrib_purpose_gr.dpg_is_own%TYPE,
        p_dpg_template     IN     ndi_distrib_purpose_gr.dpg_template%TYPE,
        p_dpg_tp           IN     ndi_distrib_purpose_gr.dpg_tp%TYPE,
        p_dpg_hs_del       IN     ndi_distrib_purpose_gr.dpg_hs_del%TYPE,
        p_dpg_hs_upd       IN     ndi_distrib_purpose_gr.dpg_hs_upd%TYPE,
        p_history_status   IN     ndi_distrib_purpose_gr.history_status%TYPE,
        p_new_id              OUT ndi_distrib_purpose_gr.dpg_id%TYPE)
    IS
    BEGIN
        api$ndi_distrib_purpose_gr.save_distrib_purpose_gr (
            p_dpg_id           => p_dpg_id,
            p_dpg_name         => p_dpg_name,
            p_dpg_is_gov       => p_dpg_is_gov,
            p_dpg_is_own       => p_dpg_is_own,
            p_dpg_template     => p_dpg_template,
            p_dpg_tp           => p_dpg_tp,
            p_dpg_hs_del       => NULL,
            p_dpg_hs_upd       => NULL,
            p_history_status   => api$dic_visit.c_history_status_actual,
            p_new_id           => p_new_id);
    END;
END dnet$ndi_distrib_purpose_gr;
/