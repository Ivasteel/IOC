/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$IMPORT_FILES
IS
    -- Author  : PAVLO
    -- Created : 26.07.2023 12:27:59
    -- Purpose : обгортка для USS_ESR.API$IMPORT_FILES (Функції обробки завантажених даних)

    PROCEDURE web_get_files_list (p_if_id                  import_files.if_id%TYPE,
                                  p_mode                   INTEGER DEFAULT 2,
                                  p_load_Start_Dt   IN     DATE,
                                  p_load_Stop_Dt    IN     DATE,
                                  p_nfit_Id         IN     NUMBER,
                                  p_files              OUT SYS_REFCURSOR);

    FUNCTION web_get_result (p_if_id import_files.if_id%TYPE)
        RETURN BLOB;

    PROCEDURE web_get_if_log (p_if_id       import_files.if_id%TYPE,
                              p_log     OUT SYS_REFCURSOR);


    -- Протокол
    PROCEDURE get_if_log (p_if_id IN NUMBER, res_cur OUT SYS_REFCURSOR);

    PROCEDURE web_save_file_to_db (p_if_id     OUT import_files.if_id%TYPE,
                                   p_mode          INTEGER DEFAULT 2,
                                   p_if_nfit       import_files.if_nfit%TYPE,
                                   p_if_name       import_files.if_name%TYPE,
                                   p_if_data       import_files.if_data%TYPE,
                                   p_files     OUT SYS_REFCURSOR);

    PROCEDURE web_delete_file (p_if_id       import_files.if_id%TYPE,
                               p_mode        INTEGER DEFAULT 2,
                               p_files   OUT SYS_REFCURSOR);

    PROCEDURE web_get_config_data (
        p_nfit_id         uss_ndi.v_ndi_import_type.nfit_id%TYPE,
        p_nfit_data   OUT SYS_REFCURSOR,
        p_nffc_data   OUT SYS_REFCURSOR,
        p_nfcc_data   OUT SYS_REFCURSOR);

    PROCEDURE web_parse_and_paste_2_tmp2 (
        p_if_id              import_files.if_id%TYPE,
        p_mode               INTEGER DEFAULT 2,
        --p_in_files IN uss_esr.api$import_files.t_files,
        p_in_rows1    IN     uss_esr.api$import_files.t_rows,
        p_in_rows2    IN     uss_esr.api$import_files.t_rows,
        p_in_rows3    IN     uss_esr.api$import_files.t_rows,
        p_in_rows4    IN     uss_esr.api$import_files.t_rows,
        p_in_rows5    IN     uss_esr.api$import_files.t_rows,
        p_in_rows6    IN     uss_esr.api$import_files.t_rows,
        p_in_rows7    IN     uss_esr.api$import_files.t_rows,
        p_in_rows8    IN     uss_esr.api$import_files.t_rows,
        p_in_rows9    IN     uss_esr.api$import_files.t_rows,
        p_in_rows10   IN     uss_esr.api$import_files.t_rows,
        p_in_rows11   IN     uss_esr.api$import_files.t_rows,
        p_in_rows12   IN     uss_esr.api$import_files.t_rows,
        p_in_rows13   IN     uss_esr.api$import_files.t_rows,
        p_in_rows14   IN     uss_esr.api$import_files.t_rows,
        p_in_rows15   IN     uss_esr.api$import_files.t_rows,
        p_in_rows16   IN     uss_esr.api$import_files.t_rows,
        p_in_rows17   IN     uss_esr.api$import_files.t_rows,
        p_in_rows18   IN     uss_esr.api$import_files.t_rows,
        p_in_rows19   IN     uss_esr.api$import_files.t_rows,
        p_in_rows20   IN     uss_esr.api$import_files.t_rows,
        p_in_log      IN     uss_esr.api$import_files.t_rows,
        p_files          OUT SYS_REFCURSOR);

    PROCEDURE web_save_file_rows (
        p_in_rows   IN uss_esr.api$import_files.t_rows);

    PROCEDURE web_save_log (p_if_id        import_files.if_id%TYPE,
                            p_in_rows   IN uss_esr.api$import_files.t_rows);

    PROCEDURE import_data (p_if_id           import_files.if_id%TYPE,
                           p_mode            INTEGER DEFAULT 2,
                           p_imoprt_tp       INTEGER DEFAULT 2,
                           p_files       OUT SYS_REFCURSOR);
END DNET$IMPORT_FILES;
/


GRANT EXECUTE ON USS_ESR.DNET$IMPORT_FILES TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$IMPORT_FILES TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:30 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$IMPORT_FILES
IS
    PROCEDURE web_get_files_list (p_if_id                  import_files.if_id%TYPE,
                                  p_mode                   INTEGER DEFAULT 2,
                                  p_load_Start_Dt   IN     DATE,
                                  p_load_Stop_Dt    IN     DATE,
                                  p_nfit_Id         IN     NUMBER,
                                  p_files              OUT SYS_REFCURSOR)
    IS
    BEGIN
        uss_esr.API$IMPORT_FILES.web_get_files_list (
            p_if_id           => p_if_id,
            p_mode            => p_mode,
            p_files           => p_files,
            p_load_Start_Dt   => p_load_Start_Dt,
            p_load_Stop_Dt    => p_load_Stop_Dt,
            p_nfit_Id         => p_nfit_Id);
    END;

    FUNCTION web_get_result (p_if_id import_files.if_id%TYPE)
        RETURN BLOB
    IS
    BEGIN
        uss_esr.API$IMPORT_FILES.write_if_log (p_if_id, 'Файл вивантажений');
        RETURN uss_esr.API$IMPORT_FILES.web_get_result (p_if_id => p_if_id);
    END;

    PROCEDURE web_get_if_log (p_if_id       import_files.if_id%TYPE,
                              p_log     OUT SYS_REFCURSOR)
    IS
    BEGIN
        uss_esr.API$IMPORT_FILES.web_get_if_log (p_if_id   => p_if_id,
                                                 p_log     => p_log);
    END;


    -- Протокол
    PROCEDURE get_if_log (p_if_id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
              SELECT t.ifl_id                                                   AS log_id,
                     t.ifl_if                                                   AS log_obj,
                     t.ifl_tp                                                   AS log_tp,
                     st.dic_name                                                AS log_st_name,
                     sto.dic_name                                               AS log_st_old_name,
                     hs_dt                                                      AS log_hs_dt,
                     tools.GetUserLogin (hs_wu)                                 AS log_hs_author,
                     uss_ndi.RDM$MSG_TEMPLATE.getmessagetext (t.ifl_message)    AS log_message
                FROM if_log t
                     LEFT JOIN uss_ndi.v_ddn_if_st st
                         ON (st.dic_value = t.ifl_st)
                     LEFT JOIN uss_ndi.v_ddn_if_st sto
                         ON (sto.dic_value = t.ifl_st_old)
                     LEFT JOIN v_histsession ON (hs_id = t.ifl_hs)
               WHERE t.ifl_if = p_if_id
            ORDER BY hs_dt;
    END;


    PROCEDURE web_save_file_to_db (p_if_id     OUT import_files.if_id%TYPE,
                                   p_mode          INTEGER DEFAULT 2,
                                   p_if_nfit       import_files.if_nfit%TYPE,
                                   p_if_name       import_files.if_name%TYPE,
                                   p_if_data       import_files.if_data%TYPE,
                                   p_files     OUT SYS_REFCURSOR)
    IS
    BEGIN
        uss_esr.API$IMPORT_FILES.web_save_file_to_db (
            p_if_id     => p_if_id,
            p_mode      => p_mode,
            p_if_nfit   => p_if_nfit,
            p_if_name   => p_if_name,
            p_if_data   => p_if_data,
            p_files     => p_files);

        uss_esr.API$IMPORT_FILES.write_if_log (p_if_id, 'Файл імпортований');
    END;

    PROCEDURE web_delete_file (p_if_id       import_files.if_id%TYPE,
                               p_mode        INTEGER DEFAULT 2,
                               p_files   OUT SYS_REFCURSOR)
    IS
    BEGIN
        uss_esr.API$IMPORT_FILES.web_delete_file (p_if_id   => p_if_id,
                                                  p_mode    => p_mode,
                                                  p_files   => p_files);
    END;

    PROCEDURE web_get_config_data (
        p_nfit_id         uss_ndi.v_ndi_import_type.nfit_id%TYPE,
        p_nfit_data   OUT SYS_REFCURSOR,
        p_nffc_data   OUT SYS_REFCURSOR,
        p_nfcc_data   OUT SYS_REFCURSOR)
    IS
    BEGIN
        uss_esr.API$IMPORT_FILES.web_get_config_data (
            p_nfit_id     => p_nfit_id,
            p_nfit_data   => p_nfit_data,
            p_nffc_data   => p_nffc_data,
            p_nfcc_data   => p_nfcc_data);
    END;

    PROCEDURE web_parse_and_paste_2_tmp2 (
        p_if_id              import_files.if_id%TYPE,
        p_mode               INTEGER DEFAULT 2,
        --p_in_files IN uss_esr.api$import_files.t_files,
        p_in_rows1    IN     uss_esr.api$import_files.t_rows,
        p_in_rows2    IN     uss_esr.api$import_files.t_rows,
        p_in_rows3    IN     uss_esr.api$import_files.t_rows,
        p_in_rows4    IN     uss_esr.api$import_files.t_rows,
        p_in_rows5    IN     uss_esr.api$import_files.t_rows,
        p_in_rows6    IN     uss_esr.api$import_files.t_rows,
        p_in_rows7    IN     uss_esr.api$import_files.t_rows,
        p_in_rows8    IN     uss_esr.api$import_files.t_rows,
        p_in_rows9    IN     uss_esr.api$import_files.t_rows,
        p_in_rows10   IN     uss_esr.api$import_files.t_rows,
        p_in_rows11   IN     uss_esr.api$import_files.t_rows,
        p_in_rows12   IN     uss_esr.api$import_files.t_rows,
        p_in_rows13   IN     uss_esr.api$import_files.t_rows,
        p_in_rows14   IN     uss_esr.api$import_files.t_rows,
        p_in_rows15   IN     uss_esr.api$import_files.t_rows,
        p_in_rows16   IN     uss_esr.api$import_files.t_rows,
        p_in_rows17   IN     uss_esr.api$import_files.t_rows,
        p_in_rows18   IN     uss_esr.api$import_files.t_rows,
        p_in_rows19   IN     uss_esr.api$import_files.t_rows,
        p_in_rows20   IN     uss_esr.api$import_files.t_rows,
        p_in_log      IN     uss_esr.api$import_files.t_rows,
        p_files          OUT SYS_REFCURSOR)
    IS
    BEGIN
        uss_esr.API$IMPORT_FILES.web_parse_and_paste_2_tmp2 (
            p_if_id       => p_if_id,
            p_mode        => p_mode,
            --p_in_files => p_in_files,
            p_in_rows1    => p_in_rows1,
            p_in_rows2    => p_in_rows2,
            p_in_rows3    => p_in_rows3,
            p_in_rows4    => p_in_rows4,
            p_in_rows5    => p_in_rows5,
            p_in_rows6    => p_in_rows6,
            p_in_rows7    => p_in_rows7,
            p_in_rows8    => p_in_rows8,
            p_in_rows9    => p_in_rows9,
            p_in_rows10   => p_in_rows10,
            p_in_rows11   => p_in_rows11,
            p_in_rows12   => p_in_rows12,
            p_in_rows13   => p_in_rows13,
            p_in_rows14   => p_in_rows14,
            p_in_rows15   => p_in_rows15,
            p_in_rows16   => p_in_rows16,
            p_in_rows17   => p_in_rows17,
            p_in_rows18   => p_in_rows18,
            p_in_rows19   => p_in_rows19,
            p_in_rows20   => p_in_rows20,
            p_in_log      => p_in_log,
            p_files       => p_files);
    END;

    PROCEDURE web_save_file_rows (
        p_in_rows   IN uss_esr.api$import_files.t_rows)
    IS
    BEGIN
        uss_esr.API$IMPORT_FILES.web_save_file_rows (p_in_rows => p_in_rows);
    END;

    PROCEDURE web_save_log (p_if_id        import_files.if_id%TYPE,
                            p_in_rows   IN uss_esr.api$import_files.t_rows)
    IS
    BEGIN
        uss_esr.API$IMPORT_FILES.web_save_log (p_if_id     => p_if_id,
                                               p_in_rows   => p_in_rows);
    END;

    PROCEDURE import_data (p_if_id           import_files.if_id%TYPE,
                           p_mode            INTEGER DEFAULT 2,
                           p_imoprt_tp       INTEGER DEFAULT 2,
                           p_files       OUT SYS_REFCURSOR)
    IS
    BEGIN
        uss_esr.API$IMPORT_FILES.import_data (p_if_id       => p_if_id,
                                              p_mode        => p_mode,
                                              p_imoprt_tp   => p_imoprt_tp,
                                              p_files       => p_files);

        uss_esr.API$IMPORT_FILES.write_if_log (p_if_id, 'Файл оброблений');
    END;
END DNET$IMPORT_FILES;
/