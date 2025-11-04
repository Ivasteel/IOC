/* Formatted on 8/12/2025 5:55:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.API$NDI_DISTRIB_PURPOSE_GR
IS
    -- Отримати запис по ідентифікатору
    PROCEDURE get_distrib_purpose_gr (
        p_id    IN     ndi_distrib_purpose_gr.dpg_id%TYPE,
        p_res      OUT SYS_REFCURSOR);

    -- Зберегти
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

    -- Вилучити
    PROCEDURE delete_distrib_purpose_gr (
        p_id   ndi_distrib_purpose_gr.dpg_id%TYPE);

    -- Список за фільтром
    PROCEDURE query_distrib_purpose_gr (p_dpg_name   IN     VARCHAR2,
                                        p_res           OUT SYS_REFCURSOR);
END api$ndi_distrib_purpose_gr;
/


/* Formatted on 8/12/2025 5:55:29 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.API$NDI_DISTRIB_PURPOSE_GR
IS
    -- Отримати запис по ідентифікатору
    PROCEDURE get_distrib_purpose_gr (
        p_id    IN     ndi_distrib_purpose_gr.dpg_id%TYPE,
        p_res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR SELECT dpg_id,
                              dpg_name,
                              dpg_is_gov,
                              dpg_is_own,
                              dpg_template,
                              dpg_tp,
                              dpg_hs_del,
                              dpg_hs_upd,
                              history_status
                         FROM ndi_distrib_purpose_gr
                        WHERE dpg_id = p_id;
    END;

    -- Зберегти
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
        IF p_dpg_id IS NULL
        THEN
            INSERT INTO ndi_distrib_purpose_gr (dpg_name,
                                                dpg_is_gov,
                                                dpg_is_own,
                                                dpg_template,
                                                dpg_tp,
                                                dpg_hs_del,
                                                dpg_hs_upd,
                                                history_status)
                 VALUES (p_dpg_name,
                         p_dpg_is_gov,
                         p_dpg_is_own,
                         p_dpg_template,
                         p_dpg_tp,
                         p_dpg_hs_del,
                         p_dpg_hs_upd,
                         p_history_status)
              RETURNING dpg_id
                   INTO p_new_id;
        ELSE
            p_new_id := p_dpg_id;

            UPDATE ndi_distrib_purpose_gr
               SET dpg_name = p_dpg_name,
                   dpg_is_gov = p_dpg_is_gov,
                   dpg_is_own = p_dpg_is_own,
                   dpg_template = p_dpg_template,
                   dpg_tp = p_dpg_tp,
                   dpg_hs_del = p_dpg_hs_del,
                   dpg_hs_upd = p_dpg_hs_upd,
                   history_status = p_history_status
             WHERE dpg_id = p_dpg_id;
        END IF;
    END;

    -- Вилучити
    PROCEDURE delete_distrib_purpose_gr (
        p_id   ndi_distrib_purpose_gr.dpg_id%TYPE)
    IS
    BEGIN
        UPDATE ndi_distrib_purpose_gr
           SET dpg_hs_del = tools.GetHistSession, history_status = 'H'
         WHERE dpg_id = p_id;
    END;

    -- Список за фільтром
    PROCEDURE query_distrib_purpose_gr (p_dpg_name   IN     VARCHAR2,
                                        p_res           OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT dpg.dpg_id,
                   dpg.dpg_name,
                   b.dic_name       AS bool_dpg_is_gov,      --DPG.DPG_IS_GOV,
                   b2.dic_name      AS bool_dpg_is_own,      --DPG.DPG_IS_OWN,
                   dpg.dpg_template,
                   dtp.dic_name     AS dtp_dpg_tp,               --DPG.DPG_TP,
                   dpg.dpg_hs_del,
                   dpg.dpg_hs_upd,
                   dpg.history_status
              FROM ndi_distrib_purpose_gr  dpg
                   LEFT JOIN v_ddn_dpg_tp dtp ON dpg.dpg_tp = dtp.dic_value
                   LEFT JOIN v_ddn_boolean b ON dpg.dpg_is_gov = b.dic_value
                   LEFT JOIN v_ddn_boolean b2
                       ON dpg.dpg_is_own = b2.dic_value
             WHERE     dpg.history_status = 'A'
                   AND (dpg.dpg_name LIKE '%' || p_dpg_name || '%');
    END;
END api$ndi_distrib_purpose_gr;
/