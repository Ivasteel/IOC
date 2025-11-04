/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$EXPORTS
IS
    -- Author  : VANO
    -- Created : 22.08.2019 12:17:25
    -- Purpose : Функції вивантаження на основі метабази таблиць ndi_export_type + ndi_net_*

    FUNCTION GetFile (p_nnf_id uss_ndi.v_ndi_net_files.nnf_id%TYPE)
        RETURN BLOB;

    FUNCTION GetFile (p_nnf_id          uss_ndi.v_ndi_net_files.nnf_id%TYPE,
                      p_where           VARCHAR2,
                      p_row_count   OUT INTEGER)
        RETURN BLOB;
END API$EXPORTS;
/


/* Formatted on 8/12/2025 5:49:03 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$EXPORTS
IS
    FUNCTION GetFile (p_nnf_id uss_ndi.v_ndi_net_files.nnf_id%TYPE)
        RETURN BLOB
    IS
        l_file       BLOB;
        l_rows_cnt   INTEGER;
    BEGIN
        l_file := GetFile (p_nnf_id, NULL, l_rows_cnt);
        RETURN l_file;
    END;

    FUNCTION GetFile (p_nnf_id          uss_ndi.v_ndi_net_files.nnf_id%TYPE,
                      p_where           VARCHAR2,
                      p_row_count   OUT INTEGER)
        RETURN BLOB
    IS
        l_table          uss_ndi.v_ndi_export_type.net_src_table%TYPE;
        l_file           BLOB;
        l_columns_list   VARCHAR2 (4000);
        l_order          VARCHAR2 (4000);
        l_convert        INTEGER;
    BEGIN
        SELECT net_src_table,
               nnf_data_order,
               DECODE (nnf_locale_tp,
                       'CP866', 0,
                       'WIN1251', 1,
                       'PUMB_IZVR', 3,
                       2)
          INTO l_table, l_order, l_convert
          FROM uss_ndi.v_ndi_export_type, uss_ndi.v_ndi_net_files
         WHERE nnf_net = net_id AND nnf_id = p_nnf_id;

        SELECT LISTAGG (nnsc_col_name || '=' || nnfc_dest_col_name, ',')
                   WITHIN GROUP (ORDER BY nnfc_dest_col_order)
          INTO l_columns_list
          FROM uss_ndi.v_ndi_net_file_cols t, uss_ndi.v_ndi_net_src_cols
         WHERE     nnfc_nnf = p_nnf_id
               AND nnfc_nnsc = nnsc_id
               AND t.history_status = 'A'  /*
               ORDER BY nnfc_dest_col_order*/
                                         ;

        l_file :=
            API$DBF.make_d4_all (p_tblname       => l_table,
                                 p_column_list   => l_columns_list,
                                 p_where         => NVL (p_where, '1 = 1'),
                                 p_order         => l_order,
                                 p_convert       => l_convert,
                                 p_row_cnt       => p_row_count);

        RETURN l_file;
    END;
BEGIN
    -- Initialization
    NULL;
END API$EXPORTS;
/