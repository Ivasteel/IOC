/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$IMPORT_FILES
IS
    -- Author  : VANO
    -- Created : 24.07.2023 20Ж06
    -- Purpose : Функції обробки завантажених даних з 1С

    TYPE t_Files IS TABLE OF Uss_Ndi.v_Ndi_Import_Files_Config.Nffc_Id%TYPE
        INDEX BY PLS_INTEGER;

    TYPE t_Rows IS TABLE OF VARCHAR2 (4000)
        INDEX BY PLS_INTEGER;

    g_Write_Log   INTEGER := 0;

    PROCEDURE Write_If_Log (p_Ifl_If        If_Log.Ifl_If%TYPE,
                            p_Ifl_Message   If_Log.Ifl_Message%TYPE,
                            p_Ifl_Hs        If_Log.Ifl_Hs%TYPE DEFAULT NULL);

    PROCEDURE Web_Get_Files_List (
        p_If_Id                  Import_Files.If_Id%TYPE,
        p_Mode                   INTEGER DEFAULT 2,
        p_Files              OUT SYS_REFCURSOR,
        p_load_Start_Dt   IN     DATE DEFAULT NULL,
        p_load_Stop_Dt    IN     DATE DEFAULT NULL,
        p_nfit_Id         IN     NUMBER DEFAULT NULL);

    FUNCTION Web_Get_Result (p_If_Id Import_Files.If_Id%TYPE)
        RETURN BLOB;

    PROCEDURE Web_Get_If_Log (p_If_Id       Import_Files.If_Id%TYPE,
                              p_Log     OUT SYS_REFCURSOR);

    PROCEDURE Web_Save_File_To_Db (p_If_Id     OUT Import_Files.If_Id%TYPE,
                                   p_Mode          INTEGER DEFAULT 2,
                                   p_If_Nfit       Import_Files.If_Nfit%TYPE,
                                   p_If_Name       Import_Files.If_Name%TYPE,
                                   p_If_Data       Import_Files.If_Data%TYPE,
                                   p_Files     OUT SYS_REFCURSOR);

    PROCEDURE Web_Delete_File (p_If_Id       Import_Files.If_Id%TYPE,
                               p_Mode        INTEGER DEFAULT 2,
                               p_Files   OUT SYS_REFCURSOR);

    PROCEDURE Web_Get_Config_Data (
        p_Nfit_Id         Uss_Ndi.v_Ndi_Import_Type.Nfit_Id%TYPE,
        p_Nfit_Data   OUT SYS_REFCURSOR,
        p_Nffc_Data   OUT SYS_REFCURSOR,
        p_Nfcc_Data   OUT SYS_REFCURSOR);

    PROCEDURE Web_Parse_And_Paste_2_Tmp (
        p_If_Id            Import_Files.If_Id%TYPE,
        p_Mode             INTEGER DEFAULT 2,
        --p_in_files IN t_files,
        p_In_Rows   IN     t_Rows,
        p_In_Log    IN     t_Rows,
        p_Files        OUT SYS_REFCURSOR);

    PROCEDURE Web_Parse_And_Paste_2_Tmp2 (
        p_If_Id              Import_Files.If_Id%TYPE,
        p_Mode               INTEGER DEFAULT 2,
        --p_in_files IN t_files,
        p_In_Rows1    IN     t_Rows,
        p_In_Rows2    IN     t_Rows,
        p_In_Rows3    IN     t_Rows,
        p_In_Rows4    IN     t_Rows,
        p_In_Rows5    IN     t_Rows,
        p_In_Rows6    IN     t_Rows,
        p_In_Rows7    IN     t_Rows,
        p_In_Rows8    IN     t_Rows,
        p_In_Rows9    IN     t_Rows,
        p_In_Rows10   IN     t_Rows,
        p_In_Rows11   IN     t_Rows,
        p_In_Rows12   IN     t_Rows,
        p_In_Rows13   IN     t_Rows,
        p_In_Rows14   IN     t_Rows,
        p_In_Rows15   IN     t_Rows,
        p_In_Rows16   IN     t_Rows,
        p_In_Rows17   IN     t_Rows,
        p_In_Rows18   IN     t_Rows,
        p_In_Rows19   IN     t_Rows,
        p_In_Rows20   IN     t_Rows,
        p_In_Log      IN     t_Rows,
        p_Files          OUT SYS_REFCURSOR);

    PROCEDURE Web_Save_File_Rows (p_In_Rows IN t_Rows);

    PROCEDURE Web_Save_Log (p_If_Id        Import_Files.If_Id%TYPE,
                            p_In_Rows   IN t_Rows);

    PROCEDURE Import_Data (p_If_Id           Import_Files.If_Id%TYPE,
                           p_Mode            INTEGER DEFAULT 1,
                           p_Imoprt_Tp       INTEGER DEFAULT 2,
                           p_Files       OUT SYS_REFCURSOR);
END Api$import_Files;
/


/* Formatted on 8/12/2025 5:49:04 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$IMPORT_FILES
IS
    g_com_org       import_files.com_org%TYPE;
    g_com_wu        pc_decision.com_wu%TYPE;

    TYPE t_cfg_column IS TABLE OF uss_ndi.v_ndi_import_column_config%ROWTYPE
        INDEX BY PLS_INTEGER;

    g_cfg_column    t_cfg_column;

    TYPE t_cfg_tab IS TABLE OF uss_ndi.v_ndi_import_files_config%ROWTYPE
        INDEX BY PLS_INTEGER;

    g_cfg_tab       t_cfg_tab;

    l_hs            histsession.hs_id%TYPE;
    l_import_data   v_import_files%ROWTYPE;

    --l_msg TOOLS.t_msg;
    l_cnt           INTEGER;

    PROCEDURE WL (p_msg VARCHAR2)
    IS
    BEGIN
        IF g_write_log = 1
        THEN
            DBMS_OUTPUT.put_line (p_msg);
        END IF;
    END;

    PROCEDURE write_if_log (p_ifl_if        if_log.ifl_if%TYPE,
                            p_ifl_message   if_log.ifl_message%TYPE,
                            p_ifl_hs        if_log.ifl_hs%TYPE DEFAULT NULL)
    IS
        ll_hs   histsession.hs_id%TYPE;
    BEGIN
        IF p_ifl_hs IS NULL
        THEN
            ll_hs := tools.GetHistSession ();
        ELSE
            ll_hs := p_ifl_hs;
        END IF;

        --ifl_tp = 'SYS' інакше не видно в інтерфейсі
        INSERT INTO if_log (ifl_id,
                            ifl_message,
                            ifl_hs,
                            ifl_if,
                            ifl_tp)
             VALUES (0,
                     p_ifl_message,
                     ll_hs,
                     p_ifl_if,
                     'SYS');
    END;

    PROCEDURE clear_tmp_tables (p_if_id import_files.if_id%TYPE)
    IS
    BEGIN
        NULL;
    END;

    PROCEDURE web_get_files_list (
        p_if_id                  import_files.if_id%TYPE,
        p_mode                   INTEGER DEFAULT 2,
        p_files              OUT SYS_REFCURSOR,
        p_load_Start_Dt   IN     DATE DEFAULT NULL,
        p_load_Stop_Dt    IN     DATE DEFAULT NULL,
        p_nfit_Id         IN     NUMBER DEFAULT NULL)
    IS
    BEGIN
        OPEN p_files FOR
              SELECT if_id,
                     if_name,
                     if_load_dt,
                     CASE WHEN p_if_id > 0 THEN if_data ELSE NULL END
                         AS if_data,
                     if_nfit,
                     nfit_name
                         AS if_tp_name,
                     dic_name
                         AS if_st_name,
                     if_parse_dt,
                     if_import_dt,
                     if_st
                FROM v_import_files           b,
                     uss_ndi.v_ndi_import_type t,
                     uss_ndi.v_ddn_if_st
               WHERE     (if_id = p_if_id OR p_if_id = -1)
                     AND ((p_mode = 1 AND if_nfit = 6) OR p_mode = 2)
                     AND if_nfit = nfit_id
                     AND if_st = dic_value
                     AND (   p_load_Start_Dt IS NULL
                          OR b.if_load_dt >= p_load_Start_Dt)
                     AND (   p_load_Stop_Dt IS NULL
                          OR b.if_load_dt <= p_load_Stop_Dt)
                     AND (p_nfit_Id IS NULL OR b.if_nfit = p_nfit_Id)
            ORDER BY if_id DESC;
    END;

    FUNCTION web_get_result (p_if_id import_files.if_id%TYPE)
        RETURN BLOB
    IS
        CURSOR cur IS
            SELECT f.if_result
              FROM v_import_files f
             WHERE f.if_id = p_if_id;

        l_result   BLOB;
    BEGIN
        OPEN cur;

        FETCH cur INTO l_result;

        CLOSE cur;

        RETURN l_result;
    END;

    PROCEDURE web_get_if_log (p_if_id       import_files.if_id%TYPE,
                              p_log     OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_log FOR
            SELECT ifl_id, hs_dt AS ifl_dt, ifl_message
              FROM v_import_files b, v_if_log, v_histsession
             WHERE ifl_if = p_if_id AND ifl_if = if_id AND ifl_hs = hs_id;
    END;

    PROCEDURE web_save_file_to_db (p_if_id     OUT import_files.if_id%TYPE,
                                   p_mode          INTEGER DEFAULT 2,
                                   p_if_nfit       import_files.if_nfit%TYPE,
                                   p_if_name       import_files.if_name%TYPE,
                                   p_if_data       import_files.if_data%TYPE,
                                   p_files     OUT SYS_REFCURSOR)
    IS
    BEGIN
        INSERT INTO import_files (if_id,
                                  if_name,
                                  if_data,
                                  if_load_dt,
                                  com_org,
                                  if_nfit,
                                  if_st)
             VALUES (0,
                     p_if_name,
                     p_if_data,
                     SYSDATE,
                     g_com_org,
                     p_if_nfit,
                     'Z')
          RETURNING if_id
               INTO p_if_id;

        web_get_files_list (-1, p_mode, p_files);
    END;

    PROCEDURE web_delete_file (p_if_id       import_files.if_id%TYPE,
                               p_mode        INTEGER DEFAULT 2,
                               p_files   OUT SYS_REFCURSOR)
    IS
        l_st   import_files.if_st%TYPE;
    BEGIN
        SELECT if_st
          INTO l_st
          FROM v_import_files
         WHERE if_id = p_if_id;

        IF l_st = 'I'
        THEN
            raise_application_error (
                -20000,
                'Видаляти файл в стані "Імпортовано" - не можна!');
        END IF;

        --Чистимо псевдо-тимчасові таблиці по файлу.
        --clear_tmp_tables(p_if_id);
        DELETE FROM src_lgot_set1 t
              WHERE t.if_id = p_if_id;

        --Чистимо протокол обробки та сам файл.
        DELETE FROM if_log
              WHERE ifl_if = p_if_id;

        DELETE FROM import_files
              WHERE if_id = p_if_id AND com_org = g_com_org;

        web_get_files_list (-1, p_mode, p_files);
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                'Файлу з вказаним ідентифікатором не існує або Ви не маєте права його видаляти!');
    END;

    PROCEDURE web_get_config_data (
        p_nfit_id         uss_ndi.v_ndi_import_type.nfit_id%TYPE,
        p_nfit_data   OUT SYS_REFCURSOR,
        p_nffc_data   OUT SYS_REFCURSOR,
        p_nfcc_data   OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_nfit_data FOR SELECT nfit_id,
                                    nfit_name,
                                    nfit_column_separator,
                                    nfit_tp,      /*nfit_is_skip_first_row, */
                                    nfit_description,
                                    nfit_separator_replacer,
                                    nfit_is_have_result
                               FROM uss_ndi.v_ndi_import_type
                              WHERE nfit_id = p_nfit_id;

        OPEN p_nffc_data FOR SELECT nffc_id,
                                    nffc_logical_name,
                                    nffc_is_req,
                                    nffc_description,
                                    nffc_nfit,
                                    nffc_name,
                                    nffc_skip_rows_count
                               FROM uss_ndi.v_ndi_import_files_config
                              WHERE nffc_nfit = p_nfit_id;

        OPEN p_nfcc_data FOR
            SELECT nfcc_id,
                   nfcc_src_col_name,
                   nfcc_dest_col_name,
                   nfcc_type,
                   nfcc_is_can_empty,
                   nfcc_order,
                   nfcc_description,
                   nfcc_nffc,
                   nfcc_digits_cnt,
                   nfcc_dt_format,
                   nfcc_digits_separator,
                   nfcc_check_values,
                   nfcc_max_length
              FROM uss_ndi.v_ndi_import_column_config,
                   uss_ndi.v_ndi_import_files_config
             WHERE nfcc_nffc = nffc_id AND nffc_nfit = p_nfit_id;
    END;

    FUNCTION get_column_cfg (
        p_nfcc_id   uss_ndi.v_ndi_import_column_config.nfcc_id%TYPE)
        RETURN uss_ndi.v_ndi_import_column_config%ROWTYPE
    IS
        l_dat   uss_ndi.v_ndi_import_column_config%ROWTYPE;
    BEGIN
        RETURN g_cfg_column (p_nfcc_id);
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            SELECT *
              INTO l_dat
              FROM uss_ndi.v_ndi_import_column_config
             WHERE nfcc_id = p_nfcc_id;

            g_cfg_column (p_nfcc_id) := l_dat;
            RETURN l_dat;
    END;

    FUNCTION get_tab_cfg (
        p_nffc_id   uss_ndi.v_ndi_import_files_config.nffc_id%TYPE)
        RETURN uss_ndi.v_ndi_import_files_config%ROWTYPE
    IS
        l_dat   uss_ndi.v_ndi_import_files_config%ROWTYPE;
    BEGIN
        RETURN g_cfg_tab (p_nffc_id);
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            SELECT *
              INTO l_dat
              FROM uss_ndi.v_ndi_import_files_config
             WHERE nffc_id = p_nffc_id;

            g_cfg_tab (p_nffc_id) := l_dat;
            RETURN l_dat;
    END;

    --Встановлення статусу файлу. 1 - пряме встановлення стану, 2 - встановлення всім іншим файлам даного типу стану "Архівний".
    PROCEDURE set_import_file_status (p_mode    INTEGER,
                                      p_if_id   import_files.if_st%TYPE,
                                      p_if_st   import_files.if_st%TYPE)
    IS
        l_if_nfit   import_files.if_nfit%TYPE;
    BEGIN
        IF p_mode = 1
        THEN
            UPDATE v_import_files
               SET if_st = p_if_st
             WHERE if_id = p_if_id;

            IF p_if_st = 'R'
            THEN
                UPDATE v_import_files
                   SET if_parse_dt = SYSDATE
                 WHERE if_id = p_if_id;
            ELSIF p_if_st = 'I'
            THEN
                UPDATE v_import_files
                   SET if_import_dt = SYSDATE
                 WHERE if_id = p_if_id;
            END IF;
        ELSIF p_mode = 2 AND p_if_st = 'A'
        THEN
            SELECT if_nfit
              INTO l_if_nfit
              FROM v_import_files
             WHERE if_id = p_if_id;

            UPDATE v_import_files
               SET if_st = p_if_st
             WHERE     if_id <> p_if_id
                   AND if_nfit = l_if_nfit
                   AND if_st <> p_if_st
                   AND com_org = g_com_org;
        END IF;
    END;

    PROCEDURE ParseAndPaste (p_if_id import_files.if_id%TYPE)
    IS
        l_column_cfg   uss_ndi.v_ndi_import_column_config%ROWTYPE;
        l_tab_cfg      uss_ndi.v_ndi_import_files_config%ROWTYPE;
        l_imp_cfg      uss_ndi.v_ndi_import_type%ROWTYPE;
        l_rowid        VARCHAR2 (24);
        --  l_first INTEGER;
        l_val          VARCHAR2 (1000);
        l_dec_format   VARCHAR2 (100);
        l_sql          VARCHAR2 (1000);
        l_data         VARCHAR2 (4000);
    BEGIN
        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''. ''');

        --Чистимо псевдо-тимчасові таблиці по файлу.
        clear_tmp_tables (p_if_id);

        SELECT *
          INTO l_imp_cfg
          FROM uss_ndi.v_ndi_import_type
         WHERE nfit_id = 2;

        --Заповнюємо псевдо-тимчасові таблиці по файлу.
        FOR xx IN (SELECT twr_tab_id, twr_data FROM tmp_work_rows1)
        LOOP
            l_data := xx.twr_data;

            IF l_data = 'empty'
            THEN
                CONTINUE;
            END IF;

            l_tab_cfg := get_tab_cfg (xx.twr_tab_id);
            WL ('tab=' || l_tab_cfg.nffc_name || ':');

            EXECUTE IMMEDIATE   'INSERT INTO '
                             || l_tab_cfg.nffc_tab_name
                             || ' (com_org, if_id) VALUES (:1, :2) RETURNING rowid INTO :3'
                USING g_com_org, p_if_id
                RETURNING INTO l_rowid;

            FOR zz
                IN (    SELECT TRIM (REGEXP_SUBSTR (xx.twr_data,
                                                    '[^,]+',
                                                    1,
                                                    LEVEL))    AS data
                          FROM DUAL
                    CONNECT BY LEVEL <= REGEXP_COUNT (xx.twr_data, ',') + 1)
            LOOP
                IF zz.data IS NULL
                THEN
                    CONTINUE;
                END IF;

                l_column_cfg :=
                    get_column_cfg (
                        SUBSTR (zz.data, 1, INSTR (zz.data, '=') - 1));
                l_val :=
                    REPLACE (SUBSTR (zz.data, INSTR (zz.data, '=') + 1),
                             '^$^',
                             ',');
                WL (
                       'col='
                    || l_column_cfg.nfcc_dest_col_name
                    || ', val='
                    || l_val);

                IF l_column_cfg.nfcc_type = 'VARCHAR'
                THEN
                    IF     l_val IS NOT NULL
                       AND INSTR (l_val, l_imp_cfg.nfit_separator_replacer) >
                           0
                    THEN
                        l_val :=
                            REPLACE (l_val,
                                     l_imp_cfg.nfit_separator_replacer,
                                     l_imp_cfg.nfit_column_separator);
                    END IF;

                    l_sql :=
                           'UPDATE '
                        || l_tab_cfg.nffc_tab_name
                        || ' SET '
                        || l_column_cfg.nfcc_dest_col_name
                        || ' = :1 WHERE rowid = :2';

                    EXECUTE IMMEDIATE l_sql
                        USING l_val, l_rowid;
                ELSIF l_column_cfg.nfcc_type = 'DATE'
                THEN
                    IF l_val = '0' OR l_val = '.  .'
                    THEN
                        l_val := '';
                    END IF;

                    l_sql :=
                           'UPDATE '
                        || l_tab_cfg.nffc_tab_name
                        || ' SET '
                        || l_column_cfg.nfcc_dest_col_name
                        || ' = to_date(:1, '''
                        || l_column_cfg.nfcc_dt_format
                        || ''') WHERE rowid = :2';

                    EXECUTE IMMEDIATE l_sql
                        USING l_val, l_rowid;
                ELSIF l_column_cfg.nfcc_type = 'DECIMAL'
                THEN
                    l_dec_format := '9';

                    IF l_column_cfg.nfcc_digits_cnt > 0
                    THEN
                        l_dec_format :=
                            RPAD (l_dec_format || '.',
                                  l_column_cfg.nfcc_digits_cnt + 2,
                                  '9');
                        l_dec_format :=
                            LPAD (l_dec_format,
                                  l_column_cfg.nfcc_max_length + 1,
                                  '9');
                    ELSE
                        l_dec_format :=
                            LPAD (l_dec_format,
                                  l_column_cfg.nfcc_max_length + 1,
                                  '9');
                    END IF;

                    l_sql :=
                           'UPDATE '
                        || l_tab_cfg.nffc_tab_name
                        || ' SET '
                        || l_column_cfg.nfcc_dest_col_name
                        || ' = to_number(:1, '''
                        || l_dec_format
                        || ''') WHERE rowid = :2';

                    EXECUTE IMMEDIATE l_sql
                        USING l_val, l_rowid;
                ELSE
                    IF     l_val IS NOT NULL
                       AND INSTR (l_val, l_imp_cfg.nfit_separator_replacer) >
                           0
                    THEN
                        l_val :=
                            REPLACE (l_val,
                                     l_imp_cfg.nfit_separator_replacer,
                                     l_imp_cfg.nfit_column_separator);
                    END IF;

                    l_sql :=
                           'UPDATE '
                        || l_tab_cfg.nffc_tab_name
                        || ' SET '
                        || l_column_cfg.nfcc_dest_col_name
                        || ' = :1 WHERE rowid = :2';

                    EXECUTE IMMEDIATE l_sql
                        USING l_val, l_rowid;
                END IF;
            END LOOP;
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   l_data
                || '!!nffc_tab_name='
                || l_tab_cfg.nffc_tab_name
                || '!'
                || l_column_cfg.nfcc_dest_col_name
                || '='
                || l_val
                || ';format='
                || l_dec_format
                || ':'
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE web_parse_and_paste_2_tmp (
        p_if_id            import_files.if_id%TYPE,
        p_mode             INTEGER DEFAULT 2,
        --p_in_files IN t_files,
        p_in_rows   IN     t_rows,
        p_in_log    IN     t_rows,
        p_files        OUT SYS_REFCURSOR)
    IS
    --l_cnt INTEGER;
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE tmp_work_rows1';

        FORALL i IN p_in_rows.FIRST .. p_in_rows.LAST
            INSERT INTO tmp_work_rows1 (twr_data)
                 VALUES (p_in_rows (i));


        UPDATE tmp_work_rows1
           SET twr_tab_id = SUBSTR (twr_data, 1, INSTR (twr_data, '=') - 1),
               twr_data = SUBSTR (twr_data, INSTR (twr_data, '=') + 1)
         WHERE 1 = 1;

        DELETE FROM if_log
              WHERE ifl_if = p_if_id;

        web_save_log (p_if_id, p_in_log);

        COMMIT;

        ParseAndPaste (p_if_id);

        web_get_files_list (-1, p_mode, p_files);
    END;

    PROCEDURE web_parse_and_paste_2_tmp2 (
        p_if_id              import_files.if_id%TYPE,
        p_mode               INTEGER DEFAULT 2,
        --p_in_files IN t_files,
        p_in_rows1    IN     t_rows,
        p_in_rows2    IN     t_rows,
        p_in_rows3    IN     t_rows,
        p_in_rows4    IN     t_rows,
        p_in_rows5    IN     t_rows,
        p_in_rows6    IN     t_rows,
        p_in_rows7    IN     t_rows,
        p_in_rows8    IN     t_rows,
        p_in_rows9    IN     t_rows,
        p_in_rows10   IN     t_rows,
        p_in_rows11   IN     t_rows,
        p_in_rows12   IN     t_rows,
        p_in_rows13   IN     t_rows,
        p_in_rows14   IN     t_rows,
        p_in_rows15   IN     t_rows,
        p_in_rows16   IN     t_rows,
        p_in_rows17   IN     t_rows,
        p_in_rows18   IN     t_rows,
        p_in_rows19   IN     t_rows,
        p_in_rows20   IN     t_rows,
        p_in_log      IN     t_rows,
        p_files          OUT SYS_REFCURSOR)
    IS
    --l_cnt INTEGER;
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE tmp_work_rows1';

        FORALL i IN p_in_rows1.FIRST .. p_in_rows1.LAST
            INSERT INTO tmp_work_rows1 (twr_data)
                 VALUES (p_in_rows1 (i));

        FORALL i IN p_in_rows2.FIRST .. p_in_rows2.LAST
            INSERT INTO tmp_work_rows1 (twr_data)
                 VALUES (p_in_rows2 (i));

        FORALL i IN p_in_rows3.FIRST .. p_in_rows3.LAST
            INSERT INTO tmp_work_rows1 (twr_data)
                 VALUES (p_in_rows3 (i));

        FORALL i IN p_in_rows4.FIRST .. p_in_rows4.LAST
            INSERT INTO tmp_work_rows1 (twr_data)
                 VALUES (p_in_rows4 (i));

        FORALL i IN p_in_rows5.FIRST .. p_in_rows5.LAST
            INSERT INTO tmp_work_rows1 (twr_data)
                 VALUES (p_in_rows5 (i));

        FORALL i IN p_in_rows6.FIRST .. p_in_rows6.LAST
            INSERT INTO tmp_work_rows1 (twr_data)
                 VALUES (p_in_rows6 (i));

        FORALL i IN p_in_rows7.FIRST .. p_in_rows7.LAST
            INSERT INTO tmp_work_rows1 (twr_data)
                 VALUES (p_in_rows7 (i));

        FORALL i IN p_in_rows8.FIRST .. p_in_rows8.LAST
            INSERT INTO tmp_work_rows1 (twr_data)
                 VALUES (p_in_rows8 (i));

        FORALL i IN p_in_rows9.FIRST .. p_in_rows9.LAST
            INSERT INTO tmp_work_rows1 (twr_data)
                 VALUES (p_in_rows9 (i));

        FORALL i IN p_in_rows10.FIRST .. p_in_rows10.LAST
            INSERT INTO tmp_work_rows1 (twr_data)
                 VALUES (p_in_rows10 (i));

        FORALL i IN p_in_rows11.FIRST .. p_in_rows11.LAST
            INSERT INTO tmp_work_rows1 (twr_data)
                 VALUES (p_in_rows11 (i));

        FORALL i IN p_in_rows12.FIRST .. p_in_rows12.LAST
            INSERT INTO tmp_work_rows1 (twr_data)
                 VALUES (p_in_rows12 (i));

        FORALL i IN p_in_rows13.FIRST .. p_in_rows13.LAST
            INSERT INTO tmp_work_rows1 (twr_data)
                 VALUES (p_in_rows13 (i));

        FORALL i IN p_in_rows14.FIRST .. p_in_rows14.LAST
            INSERT INTO tmp_work_rows1 (twr_data)
                 VALUES (p_in_rows14 (i));

        FORALL i IN p_in_rows15.FIRST .. p_in_rows15.LAST
            INSERT INTO tmp_work_rows1 (twr_data)
                 VALUES (p_in_rows15 (i));

        FORALL i IN p_in_rows16.FIRST .. p_in_rows16.LAST
            INSERT INTO tmp_work_rows1 (twr_data)
                 VALUES (p_in_rows16 (i));

        FORALL i IN p_in_rows17.FIRST .. p_in_rows17.LAST
            INSERT INTO tmp_work_rows1 (twr_data)
                 VALUES (p_in_rows17 (i));

        FORALL i IN p_in_rows18.FIRST .. p_in_rows18.LAST
            INSERT INTO tmp_work_rows1 (twr_data)
                 VALUES (p_in_rows18 (i));

        FORALL i IN p_in_rows19.FIRST .. p_in_rows19.LAST
            INSERT INTO tmp_work_rows1 (twr_data)
                 VALUES (p_in_rows19 (i));

        FORALL i IN p_in_rows20.FIRST .. p_in_rows20.LAST
            INSERT INTO tmp_work_rows1 (twr_data)
                 VALUES (p_in_rows20 (i));

        UPDATE tmp_work_rows1
           SET twr_tab_id = SUBSTR (twr_data, 1, INSTR (twr_data, '=') - 1),
               twr_data = SUBSTR (twr_data, INSTR (twr_data, '=') + 1)
         WHERE 1 = 1;

        DELETE FROM if_log
              WHERE ifl_if = p_if_id;

        web_save_log (p_if_id, p_in_log);

        COMMIT;

        ParseAndPaste (p_if_id);

        set_import_file_status (1, p_if_id, 'R');

        COMMIT;

        web_get_files_list (-1, p_mode, p_files);
    END;

    PROCEDURE web_save_file_rows (p_in_rows IN t_rows)
    IS
    BEGIN
        FORALL i IN p_in_rows.FIRST .. p_in_rows.LAST
            INSERT INTO tmp_work_rows1 (twr_data)
                 VALUES (p_in_rows (i));
    END;

    PROCEDURE web_save_log (p_if_id        import_files.if_id%TYPE,
                            p_in_rows   IN t_rows)
    IS
        --l_cnt INTEGER;
        l_if   import_files%ROWTYPE;
    BEGIN
        SELECT *
          INTO l_if
          FROM import_files
         WHERE if_id = p_if_id AND com_org = g_com_org;

        l_hs := TOOLS.GetHistSession;

        FORALL i IN p_in_rows.FIRST .. p_in_rows.LAST
            INSERT INTO if_log (ifl_if, ifl_hs, ifl_message)
                 VALUES (l_if.if_id, l_hs, p_in_rows (i));
    END;

    PROCEDURE clear_unused_iss
    IS
    BEGIN
        DELETE FROM tmp_work_ids;
    END;

    --імпорт даних з dbf-файлу в проізвольну оракл-таблицю
    PROCEDURE dbase_fox (p_if_id IN import_files.if_id%TYPE)
    IS
        CURSOR c_imp_dt IS
            SELECT f.*,
                   (SELECT LISTAGG (cc.nfcc_dest_col_name, ',')
                               WITHIN GROUP (ORDER BY cc.nfcc_order)
                      FROM uss_ndi.v_ndi_import_column_config cc
                     WHERE cc.nfcc_nffc = fc.nffc_id)    AS cnames
              FROM uss_esr.import_files               f,
                   uss_ndi.v_ndi_import_type          it,
                   uss_ndi.v_ndi_import_files_config  fc
             WHERE     f.if_id = p_if_id
                   AND it.nfit_id = f.if_nfit
                   AND fc.nffc_nfit = it.nfit_id;

        r_imp_dt    c_imp_dt%ROWTYPE;

        l_def_fld   ikis_sysweb.IKIS_WEB_FILE.r_def_fields;
    BEGIN
        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''. ''');

        --список полів для імпорта
        OPEN c_imp_dt;

        FETCH c_imp_dt INTO r_imp_dt;

        CLOSE c_imp_dt;

        DELETE FROM src_lgot_set1 t
              WHERE t.if_id = p_if_id;

        l_def_fld.Fields := 'if_id, com_org';
        l_def_fld.Fields_value :=
               p_if_id
            || ','
            || NVL (TO_CHAR (uss_esr.TOOLS.GetCurrOrg), 'null');

        ikis_sysweb.IKIS_WEB_FILE.Load_Table_DBF (
            p_blob         => r_imp_dt.if_data,
            p_tname        => 'uss_esr.v_src_lgot_set1',
            p_cnames       => r_imp_dt.cnames,
            p_Def_fields   => l_def_fld,
            p_show         => FALSE);

        set_import_file_status (1, p_if_id, 'R');
    END;

    PROCEDURE chk_ndi_position (p_if_id import_files.if_id%TYPE)
    IS
    BEGIN
        NULL;
    END;


    PROCEDURE imp_ndi_position (p_if_id import_files.if_id%TYPE)
    IS
    BEGIN
        NULL;
    END;

    PROCEDURE import_data_full (p_if_id import_files.if_id%TYPE)
    IS
    BEGIN
        NULL;
    END;

    PROCEDURE Set_Report_tp2 (p_if_id   uss_esr.import_files.if_id%TYPE,
                              p_okpo    VARCHAR2,
                              p_mm      INTEGER,
                              p_yyyy    NUMBER)
    IS
        C_OK   CONSTANT VARCHAR2 (3) := 'ТАК';

        l_notes         VARCHAR2 (32000);
        is_nbc1         BOOLEAN;
        --is_nbc2  boolean;
        is_dt           BOOLEAN;
        --is_sm    boolean;
        l_clb           CLOB;
        l_result        BLOB;

        --#91301
        PROCEDURE Set_SocialCard (p_if_id import_files.if_id%TYPE)
        IS
            CURSOR c_ipn (p_ipn VARCHAR2)
            IS
                  SELECT d.scd_sc
                    FROM uss_person.v_Sc_Document d
                   WHERE     d.Scd_Number = p_ipn
                         AND d.Scd_Ndt = 5
                         AND (   SYSDATE >= d.Scd_Start_Dt
                              OR d.Scd_Start_Dt IS NULL)
                         AND (SYSDATE <= d.Scd_Stop_Dt OR d.Scd_Stop_Dt IS NULL)
                         AND Scd_St IN ('1', 'A')
                ORDER BY (d.Scd_Start_Dt) DESC;

            CURSOR c_pasp (p_pasp VARCHAR2)
            IS
                  SELECT d.scd_sc
                    FROM uss_person.v_Sc_Document d
                   WHERE     d.Scd_Seria || d.Scd_Number = p_pasp
                         AND d.Scd_Ndt = 5
                         AND (   SYSDATE >= d.Scd_Start_Dt
                              OR d.Scd_Start_Dt IS NULL)
                         AND (SYSDATE <= d.Scd_Stop_Dt OR d.Scd_Stop_Dt IS NULL)
                         AND Scd_St IN ('1', 'A')
                ORDER BY (d.Scd_Start_Dt) DESC;

            CURSOR c_pib (p_sc NUMBER)
            IS
                SELECT i.sci_ln || ' ' || i.sci_fn || ' ' || i.sci_mn     pib
                  FROM uss_person.v_socialcard   sc,
                       uss_person.v_sc_change    ch,
                       uss_person.v_sc_identity  i
                 WHERE     sc.sc_id = p_sc
                       AND ch.scc_id = sc.sc_scc
                       AND i.sci_id = ch.scc_sci;

            l_sc_id   NUMBER;
            l_pib     VARCHAR2 (100);
        BEGIN
            FOR c IN (SELECT l.*
                        FROM uss_esr.src_lgot_set1 l
                       WHERE l.if_id = p_if_id)
            LOOP
                l_sc_id := NULL;
                l_pib := NULL;

                --співпадіння ІПН
                OPEN c_ipn (p_ipn => c.sls_idcode);

                FETCH c_ipn INTO l_sc_id;

                CLOSE c_ipn;

                --співпадіння по паспорту
                IF l_sc_id IS NULL
                THEN
                    OPEN c_pasp (p_pasp => c.sls_idcode);

                    FETCH c_pasp INTO l_sc_id;

                    CLOSE c_pasp;
                END IF;

                IF l_sc_id IS NOT NULL
                THEN
                    OPEN c_pib (p_sc => l_sc_id);

                    FETCH c_pib INTO l_pib;

                    CLOSE c_pib;

                    --співпадіння ПІП > 80%
                    IF (  100
                        -   UTL_MATCH.Edit_Distance (UPPER (c.sls_fio),
                                                     UPPER (l_pib))
                          / LENGTH (c.sls_fio)
                          * 100) <
                       80
                    THEN
                        l_sc_id := NULL;
                    END IF;
                END IF;

                UPDATE uss_esr.src_lgot_set1 l
                   SET l.sls_sc = l_sc_id
                 WHERE l.sls_id = c.sls_id;
            END LOOP;
        END Set_SocialCard;
    BEGIN
        DBMS_LOB.createtemporary (lob_loc => l_clb, cache => TRUE);
        DBMS_LOB.open (lob_loc => l_clb, open_mode => DBMS_LOB.lob_readwrite);

        --ідентіфікація пільговика
        /*for c in
        (select l.sls_id, sc.sc_id,
                 nvl(i.sco_numident, i.sco_pasp_seria||i.sco_pasp_number) a,
                 i.sco_ln||' '||i.sco_fn||' '||i.sco_mn b
            from uss_esr.src_lgot_set1 l,
                 uss_person.v_socialcard sc,
                 uss_person.v_sc_info i
           where l.if_id = p_if_id
             and i.sco_id = sc.sc_id
             --співпадіння ІПН
             and (i.sco_numident = l.sls_idcode or i.sco_pasp_seria||i.sco_pasp_number = l.sls_idcode)
             --співпадіння ПІП > 80%
             and (100 - Utl_Match.Edit_Distance(l.sls_fio, i.sco_ln||' '||i.sco_fn||' '||i.sco_mn) / Length(l.sls_fio) * 100) >= 80
        )
        loop
          update uss_esr.src_lgot_set1 l set l.sls_sc = c.sc_id
           where l.sls_id = c.sls_id;
        end loop;*/

        --#91301
        Set_SocialCard (p_if_id);

        --назви полів csv
        --dbms_lob.append(l_clb, 'IDCODE;FIO;LGKAT;LGCODE;DATA1;DATA2;TARIF;SUMM;FLAG;NOTES'||chr(13)||chr(10));
        DBMS_LOB.append (
            l_clb,
               'РНОКПП;ПІБ;Код категорії;Код пільги;Період перевірки з;Період перевірки по;Тариф;Сума нарахувань;Підтверджено;Причина'
            || CHR (13)
            || CHR (10));

        --перевірка можливості виплати
        FOR c
            IN (SELECT CASE
                           WHEN NVL (i.sco_numident,
                                     i.sco_pasp_seria || i.sco_pasp_number)
                                    IS NOT NULL
                           THEN
                               NVL (i.sco_numident,
                                    i.sco_pasp_seria || i.sco_pasp_number)
                           ELSE
                               l.sls_idcode
                       END                 okpo,                     -- РНОКПП
                       NVL2 (i.sco_ln,
                             i.sco_ln || ' ' || i.sco_fn || ' ' || i.sco_mn,
                             l.sls_fio)    pib,                         -- ПІБ
                       l.sls_lgkat         nbc,              --  Код категорії
                       l.sls_lgcode        nbt,                  -- Код пільги
                       l.sls_data1         data1,       --  Період перевірки з
                       l.sls_data2         data2,      --  Період перевірки по
                       l.sls_tarif         tarif,                    --  Тариф
                       l.sls_summ          summ, -- Сума нарахувань – зазначається якщо успішно пройдено перевірку.
                       'Ні '               flag,   --  Підтверджено (ТАК або Ні)
                       l.sls_cdpr,
                       l.sls_monthin,
                       l.sls_yearin,
                       l.sls_lgprc,
                       l.sls_id,
                       l.sls_sc
                  FROM uss_esr.src_lgot_set1 l, --uss_person.v_socialcard sc,
                                                uss_person.v_sc_info i
                 WHERE l.if_id = p_if_id AND i.sco_id(+) = l.sls_sc)
        LOOP
            l_notes := NULL;
            is_nbc1 := FALSE;
            --is_nbc2:= false;
            is_dt := FALSE;

            --is_sm  := false;

            IF --c.sls_monthin = p_mm and c.sls_yearin = p_yyyy and    перевірку по місяцях відключити - можуть бути різні періоди
               c.sls_cdpr = p_okpo
            THEN
                --йдемо по пільгах
                FOR b
                    IN (SELECT nbc.nbc_id,
                               nbc.nbc_code,
                               nbc.nbc_benefit_amount     percent, /*bc.scbc_start_dt, bc.scbc_stop_dt,*/
                                                                   --  Код категорії
                               nbt.nbt_id,
                               nbt.nbt_code,
                               bt.scbt_start_dt,
                               bt.scbt_stop_dt                   -- Код пільги
                          FROM uss_person.v_sc_benefit_category  bc,
                               uss_ndi.v_ndi_benefit_category    nbc,
                               uss_person.v_Sc_Benefit_Type      bt,
                               uss_ndi.v_ndi_benefit_type        nbt
                         WHERE     1 = 1
                               AND bc.scbc_sc(+) = c.sls_sc
                               AND NVL (bc.scbc_st, 'A') = 'A'
                               AND nbc.nbc_id(+) = bc.scbc_nbc
                               AND bt.scbt_sc(+) = c.sls_sc
                               AND bt.scbt_scbc(+) = bc.scbc_id
                               AND NVL (bt.Scbt_St, 'A') = 'A'
                               AND nbt.nbt_id(+) = bt.scbt_nbt
                               AND nbc.nbc_code = c.nbc
                               AND nbt.nbt_code = c.nbt)
                LOOP
                    is_nbc1 := TRUE;

                    IF     b.scbt_start_dt <= c.data1
                       AND b.scbt_stop_dt >= c.data1
                       AND --початок періоду виплати c.e в інтервалі дії пільги
                           b.scbt_start_dt <= c.data2
                       AND b.scbt_stop_dt >= c.data2
                    THEN   --кінець періоду виплати c.f в інтервалі дії пільги
                        is_dt := TRUE;

                        /* для Укртелекома та Укрзалізниці пільги не передаються
                        --пошук суми в призначених пільгах (з ПФУ)
                        for d in
                        (select d.* from uss_person.v_sc_scpp_detail d, uss_ndi.v_ndi_nbt_nppt_setup ndis
                          where d.scpd_sc = c.sls_sc
                            and ndis.nbpt_nppt = d.scpd_nppt
                            and d.scpd_nbc    = b.nbc_id --категорія
                            and ndis.nbpt_nbt = b.nbt_id --пільга
                        )
                        loop
                          is_nbc2:= true;
                          if d.scpd_sum = c.summ  then --сума тарифа співпала ??
                            c.flag:= C_OK;
                            is_sm:= true;
                            exit;
                          end if;
                        end loop;*/

                        c.flag := C_OK;
                    END IF;
                END LOOP;

                IF NOT is_nbc1
                THEN
                    l_notes := l_notes || 'не знайдена категорія/пільга;';
                ELSIF NOT is_dt
                THEN
                    l_notes := l_notes || 'не співпадають дати дії пільги;';
                /*elsif not is_nbc2 then
                  l_notes:= l_notes||'не знайдена призначена пільга;';
                elsif not is_sm then
                  l_notes:= l_notes||'не співпадає сума нарахувань;';*/
                END IF;
            ELSE
                l_notes :=
                       l_notes
                    || 'ЄДРПОУ у назві файла не співпадає з <'
                    || c.sls_cdpr
                    || '>;';
            END IF;

            DBMS_LOB.append (
                l_clb,
                   c.okpo
                || ';'
                || c.pib
                || ';'
                || c.nbc
                || ';'
                || c.nbt
                || ';'
                || TO_CHAR (c.data1, 'dd.mm.yyyy')
                || ';'
                || TO_CHAR (c.data2, 'dd.mm.yyyy')
                || ';'
                || c.tarif
                || ';'
                || CASE WHEN c.flag = C_OK THEN c.summ END
                || ';'
                || TRIM (c.flag)
                || ';'
                || l_notes
                || CHR (13)
                || CHR (10));
        END LOOP;

        l_result := uss_esr.TOOLS.ConvertC2B (p_src => l_clb);

        UPDATE v_import_files f
           SET f.if_result = l_result
         WHERE f.if_id = p_if_id;

        set_import_file_status (1, p_if_id, 'I');
    END Set_Report_tp2;


    PROCEDURE Chk_data_and_import_tp2 (p_if_id import_files.if_id%TYPE)
    IS
        l_okpo   VARCHAR2 (20);
        l_cnt    INTEGER;
    BEGIN
        IF l_import_data.if_nfit <> 2
        THEN
            raise_application_error (
                -20000,
                   'Не можна завантажувати функцією import_data_full файли з типом імпорту <'
                || l_import_data.if_nfit
                || '>!');
        END IF;

        --Обробка даних та контролі
        --chk_ndi_position(p_if_id);
        --imp_ndi_position(p_if_id);

        --дублі файла
        SELECT COUNT (*)
          INTO l_cnt
          FROM v_import_files f
         WHERE     UPPER (f.if_name) = UPPER (l_import_data.if_name)
               AND if_st <> 'A';

        IF l_cnt > 1
        THEN
            raise_application_error (
                -20000,
                'Файл <' || l_import_data.if_name || '> вже завантажен!');
        END IF;

        -- перевірка імені файлу
        --Назва файлу – lgotmmrr_999999999.dbf
        -- Lgot – текст mmrr – місяць (мм) та рік (rr) 99999999 – ЄДРПОУ організації, що направила файл.

        /*-- Mmrr повинні співпадати з поточним місяцем та роком
        begin
          l_str:= '01.'||substr(l_import_data.if_name, 5, 2)||'.20'||substr(l_import_data.if_name, 7, 2);
          if to_date(l_str, 'dd.mm.yyyy') <> trunc(sysdate, 'mm') then
            raise_application_error(-20000, 'Дата файлу <'||l_str||'> не співпадає з поточним місяцем та роком <'||trunc(sysdate, 'mm')||'>');
          end if;
        exception when others then
          raise_application_error(-20000, 'Помилка у даті файлу <'||l_str||'> ');
        end;*/

        -- Контроль ЄДРПОУ здійснюється тільки на наявність цифр та довжину (8 знаків).
        l_okpo :=
            SUBSTR (l_import_data.if_name,
                    INSTR (l_import_data.if_name, '_') + 1);
        l_okpo := SUBSTR (l_okpo, 1, 8);

        IF NOT REGEXP_LIKE (l_okpo, '^\d{8}')
        THEN
            raise_application_error (
                -20000,
                   'Некоректне ЄДРПОУ у назві файлу <'
                || l_import_data.if_name
                || '>');
        END IF;

        dbase_fox (p_if_id);
        set_import_file_status (1, p_if_id, 'Z');

        Set_Report_tp2 (
            p_if_id   => p_if_id,
            p_okpo    => l_okpo,
            p_mm      => SUBSTR (l_import_data.if_name, 5, 2),
            p_yyyy    => '20' || SUBSTR (l_import_data.if_name, 7, 2));
    END;

    PROCEDURE chk_data_and_import_destroyed_prop (
        p_if_id   import_files.if_id%TYPE)
    IS
    BEGIN
        IF l_import_data.if_nfit <> 3
        THEN
            raise_application_error (
                -20000,
                   'Не можна завантажувати функцією chk_data_and_import_destroyed_prop файли з типом імпорту <'
                || l_import_data.if_nfit
                || '>!');
        END IF;

        IF TOOLS.GetCurrOrgTo IN (30, 40)
        THEN
            INSERT INTO tmp_destroyed_prop (sdp_id,
                                            sdp_num,
                                            sdp_sub_tp,
                                            sdp_kaot_code,
                                            sdp_region,
                                            sdp_otg,
                                            sdp_full_address,
                                            sdp_building_num,
                                            sdp_object_name,
                                            sdp_object_area,
                                            sdp_nb,
                                            sdp_recovery_status,
                                            sdp_reason_st_change,
                                            sdp_create_dt,
                                            sdp_act,
                                            sdp_destroy_dt,
                                            sdp_destroy_cat,
                                            sdp_is_full_destroy,
                                            sdp_is_pzmk,
                                            sdp_inspection,
                                            sdp_condition_cat)
                SELECT COL001,
                       COL002,
                       COL003,
                       COL004,
                       COL005,
                       COL006,
                       COL007,
                       COL008,
                       COL009,
                       COL010,
                       COL011,
                       COL012,
                       COL013,
                       COL014,
                       COL015,
                       COL016,
                       COL017,
                       COL018,
                       COL019,
                       COL020,
                       COL021
                  FROM TABLE (
                           csv_util_pkg.clob_to_csv (
                               TOOLS.ConvertB2C (l_import_data.if_data),
                               ';',
                               1));

            IF SQL%ROWCOUNT > 0
            THEN
                DELETE FROM src_destroyed_prop
                      WHERE 1 = 1;

                INSERT INTO src_destroyed_prop (sdp_id,
                                                if_id,
                                                sdp_num,
                                                sdp_sub_tp,
                                                sdp_kaot_code,
                                                sdp_region,
                                                sdp_otg,
                                                sdp_full_address,
                                                sdp_building_num,
                                                sdp_object_name,
                                                sdp_object_area,
                                                sdp_nb,
                                                sdp_recovery_status,
                                                sdp_reason_st_change,
                                                sdp_create_dt,
                                                sdp_act,
                                                sdp_destroy_dt,
                                                sdp_destroy_cat,
                                                sdp_is_full_destroy,
                                                sdp_is_pzmk,
                                                sdp_inspection,
                                                sdp_condition_cat,
                                                sdp_kaot)
                    SELECT tools.tnumber (sdp_id),
                           p_if_id,
                           sdp_num,
                           sdp_sub_tp,
                           sdp_kaot_code,
                           sdp_region,
                           sdp_otg,
                           sdp_full_address,
                           sdp_building_num,
                           sdp_object_name,
                           tools.tnumber (sdp_object_area,
                                          '99999999D99',
                                          ','),
                           sdp_nb,
                           sdp_recovery_status,
                           sdp_reason_st_change,
                           TOOLS.tdate (sdp_create_dt),
                           sdp_act,
                           TOOLS.tdate (sdp_destroy_dt),
                           sdp_destroy_cat,
                           sdp_is_full_destroy,
                           sdp_is_pzmk,
                           sdp_inspection,
                           sdp_condition_cat,
                           (SELECT MIN (kaot_id)
                              FROM uss_ndi.v_ndi_katottg
                             WHERE kaot_code = sdp_kaot_code)
                      FROM tmp_destroyed_prop;
            ELSE
                raise_application_error (
                    -20000,
                    'В завантаженому файлі немає записів!');
            END IF;
        ELSE
            raise_application_error (
                -20000,
                   'Файли з типом імпорту <'
                || l_import_data.if_nfit
                || '> можуть завантажувати тільки користувачі ЦА МСП та ІОЦ!');
        END IF;
    END;


    PROCEDURE chk_data_and_import_evacuees_reestr (
        p_If_Id   Import_Files.If_Id%TYPE)
    IS
        TYPE r_Er IS RECORD
        (
            Ser_Num             VARCHAR2 (4000),
            Ser_Pib             VARCHAR2 (4000),
            Ser_Birth_Dt        VARCHAR2 (100),
            Ser_Document        Src_Evacuees_Reestr.Ser_Document%TYPE,
            Ser_Numident        VARCHAR2 (4000),
            Ser_Live_Address    Src_Evacuees_Reestr.Ser_Live_Address%TYPE,
            Ser_Mob_Phone       VARCHAR2 (4000),
            Ser_Notes           Src_Evacuees_Reestr.Ser_Notes%TYPE,
            Ser_Evac_Dt         Src_Evacuees_Reestr.Ser_Evac_Dt%TYPE,
            Ser_Sc              Src_Evacuees_Reestr.Ser_Sc%TYPE
        );

        TYPE t_Er IS TABLE OF r_Er
            INDEX BY BINARY_INTEGER;

        l_Er   t_Er;
    BEGIN
        IF l_Import_Data.If_Nfit <> 4
        THEN
            Raise_Application_Error (
                -20000,
                   'Не можна завантажувати функцією chk_data_and_import_evacuees_reestr файли з типом імпорту <'
                || l_Import_Data.If_Nfit
                || '>!');
        END IF;

        IF Tools.Getcurrorgto IN (30, 40)
        THEN
            SELECT TRIM (Col001)                                           AS Ser_Num,
                   TRIM (Col002)                                           AS Ser_Pib,
                   TRIM (Col003)                                           AS Ser_Birth_Dt,
                   TRIM (Col004)                                           AS Ser_Document,
                   TRIM (LTRIM (Col005, '*'))                              AS Ser_Numident,
                   TRIM (Col006)                                           AS Ser_Live_Address,
                   TRIM (Col007)                                           AS Ser_Mob_Phone,
                   TRIM (Col008)                                           AS Ser_Notes,
                   TOOLS.tdate (Col009)                                    AS Ser_Evac_Dt,
                   (SELECT MAX (Scd_Sc)
                      FROM Uss_Person.v_Sc_Document
                     WHERE     Scd_Ndt = 5
                           AND Scd_St IN ('1', 'A')
                           AND Scd_Number = TRIM (LTRIM (Col005, '*')) /*Ser_Numident*/
                                                                      )    AS Ser_Sc
              BULK COLLECT INTO l_Er
              FROM TABLE (
                       Csv_Util_Pkg.Clob_To_Csv (
                           REGEXP_REPLACE (
                               Tools.Convertb2c (l_Import_Data.If_Data),
                               '(' || CHR (10) || '|' || CHR (13) || ')+$'),
                           ';',
                           0));

            IF l_Er.COUNT = 0
            THEN
                Raise_Application_Error (
                    -20000,
                    'В завантаженому файлі немає записів!');
            END IF;

            FOR i IN 1 .. l_Er.COUNT
            LOOP
                IF NVL (LENGTH (l_Er (i).Ser_Num), 0) > 20
                THEN
                    Raise_Application_Error (
                        -20000,
                           'В рядку '
                        || i
                        || ' поле "№ з/п" не повинно містити більше 20 символів');
                ELSIF NVL (LENGTH (l_Er (i).Ser_Pib), 0) > 150
                THEN
                    Raise_Application_Error (
                        -20000,
                           'В рядку '
                        || i
                        || ' поле "ПІБ особи" не повинно містити більше 150 символів');
                ELSIF NVL (LENGTH (l_Er (i).Ser_Numident), 0) > 20
                THEN
                    Raise_Application_Error (
                        -20000,
                           'Реєстраційний номер облікової картки платника податків повинен складатися з цифр та його довжина повинна бути 10 символів, допускається внесення номерів інших ідентифікаційних документів (паспорту) у разі відмови особи від отримання № РНОКПП, що засвідчується відміткою в паспорті (рядок '
                        || i
                        || ')');
                ELSIF NVL (LENGTH (l_Er (i).Ser_Mob_Phone), 0) > 100
                THEN
                    Raise_Application_Error (
                        -20000,
                           'В рядку '
                        || i
                        || ' поле "Мобільний номер телефону" не повинно містити більше 100 символів');
                ELSIF l_Er (i).Ser_Evac_Dt IS NULL
                THEN
                    Raise_Application_Error (
                        -20000,
                           'Перевірте заповненність поля "Дата евакуації" (рядок '
                        || i
                        || ')');
                ELSIF l_Er (i).Ser_Evac_Dt NOT BETWEEN TO_DATE ('01.01.2014',
                                                                'dd.mm.yyyy')
                                                   AND TRUNC (SYSDATE)
                THEN
                    Raise_Application_Error (
                        -20000,
                           '"Дата евакуації" це обов`язкове поле, приймаються дати в діапазоні від 01.01.2014 до '
                        || TO_CHAR (SYSDATE, 'dd.mm.yyyy')
                        || ' (рядок '
                        || i
                        || ')');
                END IF;

                IF l_Er (i).Ser_Numident = '-'
                THEN
                    l_Er (i).Ser_Numident := NULL;
                END IF;
            END LOOP;

            FORALL i IN 1 .. l_Er.COUNT
                INSERT INTO Src_Evacuees_Reestr (Ser_Id,
                                                 Ser_If,
                                                 Ser_Num,
                                                 Ser_Pib,
                                                 Ser_Birth_Dt,
                                                 Ser_Document,
                                                 Ser_Numident,
                                                 Ser_Live_Address,
                                                 Ser_Mob_Phone,
                                                 Ser_Notes,
                                                 Ser_Sc,
                                                 Ser_Evac_Dt)
                     VALUES (0,
                             p_If_Id,
                             l_Er (i).Ser_Num,
                             l_Er (i).Ser_Pib,
                             Tools.Tdate (l_Er (i).Ser_Birth_Dt),
                             l_Er (i).Ser_Document,
                             l_Er (i).Ser_Numident,
                             l_Er (i).Ser_Live_Address,
                             l_Er (i).Ser_Mob_Phone,
                             l_Er (i).Ser_Notes,
                             l_Er (i).Ser_Sc,
                             l_Er (i).Ser_Evac_Dt);
        ELSE
            Raise_Application_Error (
                -20000,
                   'Файли з типом імпорту <'
                || l_Import_Data.If_Nfit
                || '> можуть завантажувати тільки користувачі ЦА МСП та ІОЦ!');
        END IF;
    END;

    --#98975, 101094
    PROCEDURE chk_data_and_import_pension_info (
        p_If_Id   Import_Files.If_Id%TYPE)
    IS
        TYPE r_Data IS RECORD
        (
            Spi_Idp                  VARCHAR2 (4000),
            Spi_Pib                  VARCHAR2 (4000),
            Spi_Numident             VARCHAR2 (4000),
            Spi_Doc                  VARCHAR2 (4000),
            Spi_Address              VARCHAR2 (4000),
            spi_date_d               DATE,
            spi_date_o               DATE,
            Spi_Lname_Ppvp           VARCHAR2 (4000),
            Spi_Name_Ppvp            VARCHAR2 (4000),
            Spi_Father_Ppvp          VARCHAR2 (4000),
            Spi_Ls_Subject_Tp        VARCHAR2 (4000),
            Spi_Ls_Idcode_Ppvp       VARCHAR2 (4000),
            Spi_Pasp_Ppvp            VARCHAR2 (4000),
            Spi_Drog_Dt_Ppvp         DATE,
            spi_ls_number            NUMBER,
            Spi_Sum_Zag              VARCHAR2 (4000),
            Spi_Oznaka_Pens          VARCHAR2 (4000),
            Spi_Derg_Zab             VARCHAR2 (4000),
            Spi_Rab                  VARCHAR2 (4000),
            Spi_Inv_Gr               VARCHAR2 (4000),
            Spi_Inv_Gr_Dt            DATE,
            Spi_Oznak_Prac           VARCHAR2 (4000),
            Spi_Otk                  VARCHAR2 (4000),
            Spi_Date_Prac            DATE,
            Pal_Inv_Gr               VARCHAR2 (4000),
            Pal_Inv_Start_Dt         DATE,
            Pal_Inv_Stop_Dt          DATE,
            Spi_Lname_Mil            VARCHAR2 (4000),
            Spi_Name_Mil             VARCHAR2 (4000),
            Spi_Father_Mil           VARCHAR2 (4000),
            Spi_Ls_Idcode_Mil        VARCHAR2 (4000),
            Spi_Pasp_Mil             VARCHAR2 (4000),
            Spi_Drog_Dt_Mil          DATE,
            Spi_Ls_Subject_Tp_Mil    VARCHAR2 (4000),
            Spi_Sum_Zag_Mil          VARCHAR2 (4000),
            Spi_Oznaka_Pens_Mil      VARCHAR2 (4000),
            Spi_Sc                   VARCHAR2 (4000)
        );

        TYPE t_Data IS TABLE OF r_Data
            INDEX BY BINARY_INTEGER;

        l_Data        t_Data;
        l_Clob        CLOB;
        l_Name        VARCHAR2 (32767);
        l_Spi_Month   DATE := SYSDATE;
    BEGIN
        IF l_Import_Data.If_Nfit <> 5
        THEN
            Raise_Application_Error (
                -20000,
                   'Не можна завантажувати функцією chk_data_and_import_pension_info файли з типом імпорту <'
                || l_Import_Data.If_Nfit
                || '>!');
        END IF;

        IF Tools.Getcurrorgto NOT IN (30, 40)
        THEN
            Raise_Application_Error (
                -20000,
                   'Файли з типом імпорту <'
                || l_Import_Data.If_Nfit
                || '> можуть завантажувати тільки користувачі ЦА МСП та ІОЦ!');
        END IF;

        IF UPPER (SUBSTR (l_Import_Data.if_name, -4)) = '.ZIP'
        THEN
            DECLARE
                l_File_Blob   BLOB;
            BEGIN
                Tools.Unzip2 (p_Zip_Blob    => l_Import_Data.If_Data,
                              p_File_Blob   => l_File_Blob,
                              p_File_Name   => l_Name);
                l_Clob := Tools.Convertb2c (l_File_Blob);
            EXCEPTION
                WHEN OTHERS
                THEN
                    Raise_Application_Error (
                        -20000,
                           'Помилка обробки архіву.'
                        || CHR (10)
                        || DBMS_UTILITY.Format_Error_Backtrace
                        || CHR (10)
                        || SQLERRM);
            END;
        ELSE
            l_Clob := Tools.Convertb2c (l_Import_Data.If_Data);
            l_Name := l_Import_Data.if_name;
        END IF;

        l_Spi_Month := Tools.tdate (SUBSTR (l_Name, -12, 8), 'YYYYMMDD');

        IF l_Spi_Month IS NULL
        THEN
            Raise_Application_Error (
                -20000,
                'В назві файлу не вказано період данних! Наприклад: PFU_SPI_YYYYMMDD.csv, де YYYYMMDD – дата формування файлу');
        END IF;

        --Дані будуть перезаписуватись, якщо період існує
        DELETE FROM Src_Pension_Info
              WHERE TRUNC (Spi_Month, 'mm') = TRUNC (l_Spi_Month, 'mm');

        SELECT TRIM (Col001)
                   AS Spi_Idp,
               TRIM (Col002)
                   AS Spi_Pib,
               TRIM (Col003)
                   AS Spi_Numident,
               TRIM (Col004)
                   AS Spi_Doc,
               TRIM (Col005)
                   AS Spi_Address,
               Tools.Tdate (Col006)
                   AS spi_date_d,
               Tools.Tdate (Col007)
                   AS spi_date_o,
               TRIM (Col008)
                   AS Spi_Lname_Ppvp,
               TRIM (Col009)
                   AS Spi_Name_Ppvp,
               TRIM (Col010)
                   AS Spi_Father_Ppvp,
               TRIM (Col011)
                   AS Spi_Ls_Subject_Tp,
               TRIM (Col012)
                   AS Spi_Ls_Idcode_Ppvp,
               TRIM (Col013)
                   AS Spi_Pasp_Ppvp,
               Tools.Tdate (Col014)
                   AS Spi_Drog_Dt_Ppvp,
               Tools.tnumber (Col015)
                   AS spi_ls_number,
               Tools.Tnumber (Col017, p_Decimal_Separator => ',')
                   AS Spi_Sum_Zag,
               TRIM (Col018)
                   AS Spi_Oznaka_Pens,
               DECODE (Col019,  '1', 'T',  '0', 'F',  TRIM (Col019))
                   AS Spi_Derg_Zab,
               DECODE (Col020,  '1', 'T',  '0', 'F',  TRIM (Col020))
                   AS Spi_Rab,
               TRIM (Col021)
                   AS Spi_Inv_Gr,
               Tools.Tdate (Col022)
                   AS Spi_Inv_Gr_Dt,
               DECODE (Col026,  '1', 'T',  '0', 'F',  TRIM (Col026))
                   AS Spi_Oznak_Prac,
               DECODE (Col027,  '1', 'T',  '0', 'F',  TRIM (Col027))
                   AS Spi_Otk,
               Tools.Tdate (Col028)
                   AS Spi_Date_Prac,
               TRIM (Col042)
                   AS Pal_Inv_Gr,
               Tools.Tdate (Col043)
                   AS Pal_Inv_Start_Dt,
               Tools.Tdate (Col044)
                   AS Pal_Inv_Stop_Dt,
               TRIM (Col029)
                   AS Spi_Lname_Mil,
               TRIM (Col030)
                   AS Spi_Name_Mil,
               TRIM (Col031)
                   AS Spi_Father_Mil,
               TRIM (Col032)
                   AS Spi_Ls_Idcode_Mil,
               TRIM (Col033)
                   AS Spi_Pasp_Mil,
               Tools.Tdate (Col034)
                   AS Spi_Drog_Dt_Mil,
               TRIM (Col035)
                   AS Spi_Ls_Subject_Tp_Mil,
               Tools.Tnumber (Col037, p_Decimal_Separator => ',')
                   AS Spi_Sum_Zag_Mil,
               TRIM (Col038)
                   AS Spi_Oznaka_Pens_Mil,
               --#100531
               COALESCE (
                   CASE
                       WHEN     REPLACE (Col012, ' ')   /*Spi_Ls_Idcode_Ppvp*/
                                                      IS NOT NULL
                            AND REPLACE (Col012, ' ')   /*Spi_Ls_Idcode_Ppvp*/
                                                      <>
                                REPLACE (Col003, ' ')         /*Spi_Numident*/
                       THEN
                           (SELECT MAX (Scd_Sc)     Scd_Sc
                              FROM Uss_Person.v_Sc_Document d
                             WHERE     Scd_Ndt IN (6, 7)
                                   AND Scd_St IN ('1', 'A')
                                   AND scd_seria || Scd_Number =
                                       REPLACE (Col004, ' ')  /*Spi_Doc_Snum*/
                                   AND EXISTS
                                           (SELECT 1
                                              FROM uss_esr.personalcase
                                             WHERE pc_sc = Scd_Sc))
                       ELSE
                           (SELECT MAX (Scd_Sc)
                              FROM Uss_Person.v_Sc_Document d
                             WHERE     Scd_Ndt IN (5)
                                   AND Scd_St IN ('1', 'A')
                                   AND scd_seria || Scd_Number =
                                       REPLACE (Col003, ' ')  /*Spi_Numident*/
                                                            )
                   END,
                   (SELECT MAX (Scd_Sc)     Scd_Sc
                      FROM Uss_Person.v_Sc_Document d
                     WHERE     Scd_Ndt IN (6, 7)
                           AND Scd_St IN ('1', 'A')
                           AND scd_seria || Scd_Number =
                               REPLACE (Col004, ' ')          /*Spi_Doc_Snum*/
                                                    ))
                   AS Spi_Sc
          BULK COLLECT INTO l_Data
          FROM TABLE (
                   Csv_Util_Pkg.Clob_To_Csv (
                       REGEXP_REPLACE (
                           l_Clob,
                           '(' || CHR (10) || '|' || CHR (13) || ')+$'),
                       ';',
                       1));

        IF l_Data.COUNT = 0
        THEN
            Raise_Application_Error (-20000,
                                     'В завантаженому файлі немає записів!');
        END IF;

        FOR i IN 1 .. l_Data.COUNT
        LOOP
            IF NVL (LENGTH (l_Data (i).Spi_Idp), 0) > 20
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Ід особи" не повинно містити більше 20 символів');
            ELSIF NVL (LENGTH (l_Data (i).Spi_Pib), 0) > 150
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "ПІБ особи" не повинно містити більше 150 символів');
            ELSIF NVL (LENGTH (l_Data (i).Spi_Numident), 0) > 12
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "РНОКППП" не повинно містити більше 12 символів');
            ELSIF NVL (LENGTH (l_Data (i).Spi_Doc), 0) > 50
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Серія та номер документа посвідчуючий особу" не повинно містити більше 50 символів');
            ELSIF NVL (LENGTH (l_Data (i).Spi_Lname_Ppvp), 0) > 50
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Прізвище ППВП" не повинно містити більше 50 символів');
            ELSIF NVL (LENGTH (l_Data (i).Spi_Name_Ppvp), 0) > 50
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Ім`я ППВП" не повинно містити більше 50 символів');
            ELSIF NVL (LENGTH (l_Data (i).Spi_Father_Ppvp), 0) > 50
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "По-батькові ППВП" не повинно містити більше 50 символів');
            ELSIF NVL (LENGTH (l_Data (i).Spi_Ls_Idcode_Ppvp), 0) > 12
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "РНОКПП ППВП" не повинно містити більше 12 символів');
            ELSIF NVL (LENGTH (l_Data (i).Spi_Pasp_Ppvp), 0) > 20
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Серія та номер паспорту ППВП" не повинно містити більше 20 символів');
            ELSIF NVL (LENGTH (l_Data (i).Spi_Ls_Subject_Tp), 0) > 10
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Тип суб`єкту ППВП" не повинно містити більше 10 символів');
            ELSIF NVL (LENGTH (l_Data (i).Spi_Oznaka_Pens), 0) > 10
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Тип пенсії ППВП" не повинно містити більше 10 символів');
            ELSIF NVL (LENGTH (l_Data (i).Spi_Derg_Zab), 0) > 10
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Ознака перебування на повному держутриманні ППВП" не повинно містити більше 10 символів');
            ELSIF NVL (LENGTH (l_Data (i).Spi_Rab), 0) > 10
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Факт роботи ППВП" не повинно містити більше 10 символів');
            ELSIF NVL (LENGTH (l_Data (i).Spi_Inv_Gr), 0) > 10
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Група інвалідності для пенсій по івнвалідності" не повинно містити більше 10 символів');
            ELSIF NVL (LENGTH (l_Data (i).Spi_Oznak_Prac), 0) > 10
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Ознака працевлаштування" не повинно містити більше 10 символів');
            ELSIF NVL (LENGTH (l_Data (i).Spi_Otk), 0) > 10
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Працевлаштування з трудовою книжкою" не повинно містити більше 10 символів');
            ELSIF NVL (LENGTH (l_Data (i).Spi_Lname_Mil), 0) > 50
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Прізвище ДКГ" не повинно містити більше 50 символів');
            ELSIF NVL (LENGTH (l_Data (i).Spi_Name_Mil), 0) > 50
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Ім`я ДКГ" не повинно містити більше 50 символів');
            ELSIF NVL (LENGTH (l_Data (i).Spi_Father_Mil), 0) > 50
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "По-батькові ДКГ" не повинно містити більше 50 символів');
            ELSIF NVL (LENGTH (l_Data (i).Spi_Ls_Idcode_Mil), 0) > 12
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "РНОКПП ДКГ" не повинно містити більше 12 символів');
            ELSIF NVL (LENGTH (l_Data (i).Spi_Pasp_Mil), 0) > 20
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Серія та номер паспорту ДКГ" не повинно містити більше 20 символів');
            ELSIF NVL (LENGTH (l_Data (i).Spi_Ls_Subject_Tp_Mil), 0) > 12
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Тип суб`єкту ДКГ" не повинно містити більше 12 символів');
            ELSIF NVL (LENGTH (l_Data (i).Spi_Oznaka_Pens_Mil), 0) > 10
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Тип пенсії ДКГ" не повинно містити більше 10 символів');
            ELSIF NVL (LENGTH (l_Data (i).Pal_Inv_Gr), 0) > 10
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Група інвалідності" не повинно містити більше 10 символів');
            ELSIF NVL (LENGTH (l_Data (i).spi_address), 0) > 250
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Адреса місця проживання за довідкою" не повинно містити більше 250 символів');
            END IF;
        END LOOP;

        FORALL i IN 1 .. l_Data.COUNT
            INSERT INTO Src_Pension_Info (Spi_Id,
                                          Spi_If,
                                          Spi_Idp,
                                          Spi_Pib,
                                          Spi_Inn,
                                          Spi_Doc_Snum,
                                          Spi_Lname_Ppvp,
                                          Spi_Name_Ppvp,
                                          Spi_Father_Ppvp,
                                          Spi_Ls_Idcode_Ppvp,
                                          Spi_Pasp_Ppvp,
                                          Spi_Drog_Dt_Ppvp,
                                          Spi_Ls_Subject_Tp,
                                          Spi_Sum_Zag,
                                          Spi_Oznaka_Pens,
                                          Spi_Derg_Zab,
                                          Spi_Rab,
                                          Spi_Inv_Gr,
                                          Spi_Inv_Gr_Dt,
                                          Spi_Oznak_Prac,
                                          Spi_z_Trud,
                                          Spi_Date_Start,
                                          Spi_Lname_Mil,
                                          Spi_Name_Mil,
                                          Spi_Father_Mil,
                                          Spi_Ls_Idcode_Mil,
                                          Spi_Pasp_Mil,
                                          Spi_Drog_Dt_Mil,
                                          Spi_Ls_Subject_Tp_Mil,
                                          Spi_Sum_Zag_Mil,
                                          Spi_Oznaka_Pens_Mil,
                                          Spi_Inv_Gr_Mil,
                                          Spi_Gr_Dt_Mil,
                                          Spi_Inv_Stop_Dt,
                                          Spi_Sc,
                                          Spi_Month,
                                          spi_address,
                                          spi_date_d,
                                          spi_date_o,
                                          spi_ls_number)
                 VALUES (0,
                         p_If_Id,
                         l_Data (i).Spi_Idp,
                         l_Data (i).Spi_Pib,
                         l_Data (i).Spi_Numident,
                         l_Data (i).Spi_Doc,
                         l_Data (i).Spi_Lname_Ppvp,
                         l_Data (i).Spi_Name_Ppvp,
                         l_Data (i).Spi_Father_Ppvp,
                         l_Data (i).Spi_Ls_Idcode_Ppvp,
                         l_Data (i).Spi_Pasp_Ppvp,
                         l_Data (i).Spi_Drog_Dt_Ppvp,
                         l_Data (i).Spi_Ls_Subject_Tp,
                         l_Data (i).Spi_Sum_Zag,
                         l_Data (i).Spi_Oznaka_Pens,
                         l_Data (i).Spi_Derg_Zab,
                         l_Data (i).Spi_Rab,
                         l_Data (i).Spi_Inv_Gr,
                         l_Data (i).Spi_Inv_Gr_Dt,
                         l_Data (i).Spi_Oznak_Prac,
                         l_Data (i).Spi_Otk,
                         l_Data (i).Spi_Date_Prac,
                         l_Data (i).Spi_Lname_Mil,
                         l_Data (i).Spi_Name_Mil,
                         l_Data (i).Spi_Father_Mil,
                         l_Data (i).Spi_Ls_Idcode_Mil,
                         l_Data (i).Spi_Pasp_Mil,
                         l_Data (i).Spi_Drog_Dt_Mil,
                         l_Data (i).Spi_Ls_Subject_Tp_Mil,
                         l_Data (i).Spi_Sum_Zag_Mil,
                         l_Data (i).Spi_Oznaka_Pens_Mil,
                         l_Data (i).Pal_Inv_Gr,
                         l_Data (i).Pal_Inv_Start_Dt,
                         l_Data (i).Pal_Inv_Stop_Dt,
                         l_Data (i).Spi_Sc,
                         l_Spi_Month,
                         l_Data (i).spi_address,
                         l_Data (i).spi_date_d,
                         l_Data (i).spi_date_o,
                         l_Data (i).spi_ls_number);
    END;

    --#98978
    PROCEDURE chk_data_and_import_orphans_reestr (
        p_If_Id   IN Import_Files.If_Id%TYPE)
    IS
        TYPE r_data IS RECORD
        (
            sor_sc_child            src_orphans_reestr.sor_sc_child%TYPE,
            sor_child_ln            VARCHAR2 (4000),
            sor_child_fn            VARCHAR2 (4000),
            sor_child_mn            VARCHAR2 (4000),
            sor_child_birth_dt      DATE,
            sor_child_passport      VARCHAR2 (4000),
            sor_child_birth_cert    VARCHAR2 (4000),
            sor_kaot_code           VARCHAR2 (4000),
            sor_kaot                src_orphans_reestr.sor_kaot%TYPE,
            sor_live_address        VARCHAR2 (4000),
            sor_father_ln           VARCHAR2 (4000),
            sor_father_fn           VARCHAR2 (4000),
            sor_father_mn           VARCHAR2 (4000),
            sor_father_passport     VARCHAR2 (4000),
            sor_sc_father           src_orphans_reestr.sor_sc_father%TYPE,
            sor_mother_ln           VARCHAR2 (4000),
            sor_mother_fn           VARCHAR2 (4000),
            sor_mother_mn           VARCHAR2 (4000),
            sor_mother_passport     VARCHAR2 (4000),
            sor_sc_mother           src_orphans_reestr.sor_sc_mother%TYPE
        );

        TYPE t_data IS TABLE OF r_data
            INDEX BY BINARY_INTEGER;

        l_data     t_data;
        l_Clob     CLOB;
        l_Name     VARCHAR2 (32767);
        l_Sor_Dt   DATE;
    BEGIN
        IF l_Import_Data.If_Nfit <> 6
        THEN
            Raise_Application_Error (
                -20000,
                   'Не можна завантажувати функцією chk_data_and_import_orphans_reestr файли з типом імпорту <'
                || l_Import_Data.If_Nfit
                || '>!');
        END IF;

        IF Tools.Getcurrorgto NOT IN (30, 40)
        THEN
            Raise_Application_Error (
                -20000,
                   'Файли з типом імпорту <'
                || l_Import_Data.If_Nfit
                || '> можуть завантажувати тільки користувачі ЦА МСП та ІОЦ!');
        END IF;

        IF UPPER (SUBSTR (l_Import_Data.if_name, -4)) = '.ZIP'
        THEN
            DECLARE
                l_File_Blob   BLOB;
            BEGIN
                Tools.Unzip2 (p_Zip_Blob    => l_Import_Data.If_Data,
                              p_File_Blob   => l_File_Blob,
                              p_File_Name   => l_Name);
                l_Clob := Tools.Convertb2c (l_File_Blob);
            EXCEPTION
                WHEN OTHERS
                THEN
                    Raise_Application_Error (
                        -20000,
                           'Помилка обробки архіву.'
                        || CHR (10)
                        || DBMS_UTILITY.Format_Error_Backtrace
                        || CHR (10)
                        || SQLERRM);
            END;
        ELSE
            l_Clob := Tools.Convertb2c (l_Import_Data.If_Data);
            l_Name := l_Import_Data.if_name;
        END IF;

        l_Sor_Dt := Tools.tdate (SUBSTR (l_Name, -12, 8), 'YYYYMMDD');

        IF l_Sor_Dt IS NULL
        THEN
            Raise_Application_Error (
                -20000,
                'В назві файлу не вказано період данних! Наприклад: Orphans_YYYYMMDD.csv, де YYYYMMDD – дата формування файлу');
        END IF;

        --Дані будуть перезаписуватись, якщо період існує
        DELETE FROM src_orphans_reestr
              WHERE TRUNC (Sor_dt, 'mm') = TRUNC (l_Sor_Dt, 'mm');

        WITH
            src
            AS
                (SELECT TRIM (Col003)             AS x_child_name,
                        Tools.Tdate (Col004)      AS x_child_birth_dt,
                        REPLACE (Col005, ' ')     AS x_child_doc,
                        TRIM (Col006)             AS x_mother_name,
                        Tools.Tdate (Col007)      AS x_mother_birth_dt,
                        REPLACE (Col008, ' ')     AS x_mother_doc,
                        TRIM (Col009)             AS x_father_name,
                        Tools.Tdate (Col010)      AS x_father_birth_dt,
                        REPLACE (Col011, ' ')     AS x_father_doc,
                        REPLACE (Col012, ' ')     AS x_kaot_code,
                        TRIM (Col013)             AS x_live_address
                   FROM TABLE (
                            Csv_Util_Pkg.Clob_To_Csv (
                                REGEXP_REPLACE (
                                    l_Clob,
                                       '('
                                    || CHR (10)
                                    || '|'
                                    || CHR (13)
                                    || ')+$'),
                                ';',
                                1))),
            src_join
            AS
                (  SELECT x_child_name,
                          x_child_birth_dt,
                          x_child_doc,
                          MAX (x_mother_name)         x_mother_name,
                          MAX (x_mother_birth_dt)     x_mother_birth_dt,
                          MAX (x_mother_doc)          x_mother_doc,
                          MAX (x_father_name)         x_father_name,
                          MAX (x_father_birth_dt)     x_father_birth_dt,
                          MAX (x_father_doc)          x_father_doc,
                          MAX (x_kaot_code)           x_kaot_code,
                          MAX (x_live_address)        x_live_address
                     FROM src
                 GROUP BY x_child_name, x_child_birth_dt, x_child_doc),
            src_full
            AS
                (SELECT SUBSTR (x_child_name,
                                1,
                                INSTR (x_child_name, ' ') - 1)
                            AS x_child_ln,
                        SUBSTR (
                            x_child_name,
                            INSTR (x_child_name, ' ') + 1,
                              INSTR (x_child_name, ' ', -1)
                            - INSTR (x_child_name, ' ')
                            - 1)
                            AS x_child_fn,
                        SUBSTR (x_child_name,
                                INSTR (x_child_name, ' ', -1) + 1)
                            AS x_child_mn,
                        x_child_birth_dt,
                        x_child_doc,
                        SUBSTR (x_mother_name,
                                1,
                                INSTR (x_mother_name, ' ') - 1)
                            AS x_mother_ln,
                        SUBSTR (
                            x_mother_name,
                            INSTR (x_mother_name, ' ') + 1,
                              INSTR (x_mother_name, ' ', -1)
                            - INSTR (x_mother_name, ' ')
                            - 1)
                            AS x_mother_fn,
                        SUBSTR (x_mother_name,
                                INSTR (x_mother_name, ' ', -1) + 1)
                            AS x_mother_mn,
                        x_mother_birth_dt,
                        x_mother_doc,
                        SUBSTR (x_father_name,
                                1,
                                INSTR (x_father_name, ' ') - 1)
                            AS x_father_ln,
                        SUBSTR (
                            x_father_name,
                            INSTR (x_father_name, ' ') + 1,
                              INSTR (x_father_name, ' ', -1)
                            - INSTR (x_father_name, ' ')
                            - 1)
                            AS x_father_fn,
                        SUBSTR (x_father_name,
                                INSTR (x_father_name, ' ', -1) + 1)
                            AS x_father_mn,
                        x_father_birth_dt,
                        x_father_doc,
                        x_kaot_code,
                        x_live_address
                   FROM src_join)
        SELECT (SELECT MAX (Scd_Sc)     Scd_Sc
                  FROM Uss_Person.v_Sc_Document d
                 WHERE     Scd_Ndt IN (6, 7, 37)
                       AND Scd_St IN ('1', 'A')
                       AND scd_seria || Scd_Number = x_child_doc)
                   AS sor_sc_child,
               x_child_ln
                   AS sor_child_ln,
               x_child_fn
                   AS sor_child_fn,
               x_child_mn
                   AS sor_child_mn,
               x_child_birth_dt
                   AS sor_child_birth_dt,
               NULL
                   AS sor_child_passport,
               x_child_doc
                   AS sor_child_birth_cert,
               x_kaot_code
                   AS sor_kaot_code,
               (SELECT MAX (k.kaot_id)
                  FROM uss_ndi.v_ndi_katottg k
                 WHERE k.kaot_code = x_kaot_code AND k.kaot_st = 'A')
                   AS sor_kaot,
               x_live_address
                   AS sor_live_address,
               x_father_ln
                   AS sor_father_ln,
               x_father_fn
                   AS sor_father_fn,
               x_father_mn
                   AS sor_father_mn,
               x_father_doc
                   AS sor_father_passport,
               (SELECT MAX (Scd_Sc)
                  FROM Uss_Person.v_Sc_Document
                 WHERE     Scd_Ndt IN (6, 7)
                       AND Scd_St IN ('1', 'A')
                       AND scd_seria || Scd_Number = x_father_doc)
                   AS sor_sc_father,
               x_mother_ln
                   AS sor_mother_ln,
               x_mother_fn
                   AS sor_mother_fn,
               x_mother_mn
                   AS sor_mother_mn,
               x_mother_doc
                   AS sor_mother_passport,
               (SELECT MAX (Scd_Sc)
                  FROM Uss_Person.v_Sc_Document
                 WHERE     Scd_Ndt IN (6, 7)
                       AND Scd_St IN ('1', 'A')
                       AND scd_seria || Scd_Number = x_mother_doc)
                   AS sor_sc_mother
          BULK COLLECT INTO l_data
          FROM src_full;

        IF l_data.COUNT = 0
        THEN
            Raise_Application_Error (-20000,
                                     'В завантаженому файлі немає записів!');
        END IF;

        FOR i IN 1 .. l_data.COUNT
        LOOP
            IF NVL (LENGTH (l_data (i).sor_child_ln), 0) > 50
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Прізвище дитини" не повинно містити більше 50 символів');
            ELSIF NVL (LENGTH (l_data (i).sor_child_fn), 0) > 50
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Ім`я дитини" не повинно містити більше 50 символів');
            ELSIF NVL (LENGTH (l_data (i).sor_child_mn), 0) > 50
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "По-батькові дитини" не повинно містити більше 50 символів');
            ELSIF NVL (LENGTH (l_data (i).sor_child_passport), 0) > 20
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Пасспорт дитини" не повинно містити більше 20 символів');
            ELSIF NVL (LENGTH (l_data (i).sor_child_birth_cert), 0) > 20
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Свідоцтво про народження дитини" не повинно містити більше 20 символів');
            ELSIF NVL (LENGTH (l_data (i).sor_kaot_code), 0) > 20
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Код КАТОТТГ" не повинно містити більше 20 символів');
            ELSIF NVL (LENGTH (l_data (i).sor_father_ln), 0) > 50
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Прізвище батька" не повинно містити більше 50 символів');
            ELSIF NVL (LENGTH (l_data (i).sor_father_fn), 0) > 50
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Ім`я батька" не повинно містити більше 50 символів');
            ELSIF NVL (LENGTH (l_data (i).sor_father_mn), 0) > 50
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "По-батькові батька" не повинно містити більше 50 символів');
            ELSIF NVL (LENGTH (l_data (i).sor_father_passport), 0) > 20
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Паспорт батька" не повинно містити більше 20 символів');
            ELSIF NVL (LENGTH (l_data (i).sor_mother_ln), 0) > 50
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Прізвище матері" не повинно містити більше 50 символів');
            ELSIF NVL (LENGTH (l_data (i).sor_mother_fn), 0) > 50
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Ім`я матері" не повинно містити більше 50 символів');
            ELSIF NVL (LENGTH (l_data (i).sor_mother_mn), 0) > 50
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "По-батькові матері" не повинно містити більше 50 символів');
            ELSIF NVL (LENGTH (l_data (i).sor_mother_passport), 0) > 20
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Паспорт матері" не повинно містити більше 20 символів');
            END IF;
        END LOOP;

        FORALL i IN 1 .. l_data.COUNT
            INSERT INTO src_orphans_reestr (sor_id,
                                            sor_if,
                                            sor_sc_child,
                                            sor_child_ln,
                                            sor_child_fn,
                                            sor_child_mn,
                                            sor_child_birth_dt,
                                            sor_child_passport,
                                            sor_child_birth_cert,
                                            sor_kaot_code,
                                            sor_kaot,
                                            sor_live_address,
                                            sor_father_ln,
                                            sor_father_fn,
                                            sor_father_mn,
                                            sor_father_passport,
                                            sor_sc_father,
                                            sor_mother_ln,
                                            sor_mother_fn,
                                            sor_mother_mn,
                                            sor_mother_passport,
                                            sor_sc_mother,
                                            sor_dt)
                 VALUES (0,
                         p_If_Id,
                         l_data (i).sor_sc_child,
                         l_data (i).sor_child_ln,
                         l_data (i).sor_child_fn,
                         l_data (i).sor_child_mn,
                         l_data (i).sor_child_birth_dt,
                         l_data (i).sor_child_passport,
                         l_data (i).sor_child_birth_cert,
                         l_data (i).sor_kaot_code,
                         l_data (i).sor_kaot,
                         l_data (i).sor_live_address,
                         l_data (i).sor_father_ln,
                         l_data (i).sor_father_fn,
                         l_data (i).sor_father_mn,
                         l_data (i).sor_father_passport,
                         l_data (i).sor_sc_father,
                         l_data (i).sor_mother_ln,
                         l_data (i).sor_mother_fn,
                         l_data (i).sor_mother_mn,
                         l_data (i).sor_mother_passport,
                         l_data (i).sor_sc_mother,
                         l_Sor_Dt);
    END;

    --#99390
    PROCEDURE chk_data_and_import_disability_asopd (
        p_If_Id   IN Import_Files.If_Id%TYPE)
    IS
        TYPE r_data IS RECORD
        (
            sda_sc           src_disability_asopd.sda_sc%TYPE,
            sda_org          src_disability_asopd.sda_org%TYPE,
            sda_raj          VARCHAR2 (4000),
            sda_ls_nls       VARCHAR2 (4000),
            sda_fam_num      VARCHAR2 (4000),
            sda_pib          VARCHAR2 (4000),
            sda_n_id         VARCHAR2 (4000),
            sda_doctype      VARCHAR2 (4000),
            sda_series       VARCHAR2 (4000),
            sda_bdate        src_disability_asopd.sda_bdate%TYPE,
            sda_sumd         src_disability_asopd.sda_sumd%TYPE,
            sda_dis_group    VARCHAR2 (4000),
            sda_dis_begin    src_disability_asopd.sda_dis_begin%TYPE,
            sda_dis_end      src_disability_asopd.sda_dis_end%TYPE,
            sda_osob_1       VARCHAR2 (4000),
            sda_osob_2       VARCHAR2 (4000),
            sda_osob_3       VARCHAR2 (4000),
            sda_osob_4       VARCHAR2 (4000),
            sda_osob_5       VARCHAR2 (4000),
            sda_osob_6       VARCHAR2 (4000),
            sda_osob_7       VARCHAR2 (4000),
            sda_osob_8       VARCHAR2 (4000),
            sda_osob_9       VARCHAR2 (4000),
            sda_osob_10      VARCHAR2 (4000),
            sda_osob_11      VARCHAR2 (4000),
            sda_osob_12      VARCHAR2 (4000)
        );

        TYPE t_data IS TABLE OF r_data
            INDEX BY BINARY_INTEGER;

        l_data     t_data;
        l_Clob     CLOB;
        l_Name     VARCHAR2 (32767);
        l_Sda_Dt   DATE;
    BEGIN
        IF l_Import_Data.If_Nfit <> 7
        THEN
            Raise_Application_Error (
                -20000,
                   'Не можна завантажувати функцією chk_data_and_import_orphans_reestr файли з типом імпорту <'
                || l_Import_Data.If_Nfit
                || '>!');
        END IF;

        IF Tools.Getcurrorgto NOT IN (30, 40)
        THEN
            Raise_Application_Error (
                -20000,
                   'Файли з типом імпорту <'
                || l_Import_Data.If_Nfit
                || '> можуть завантажувати тільки користувачі ЦА МСП та ІОЦ!');
        END IF;

        IF UPPER (SUBSTR (l_Import_Data.if_name, -4)) = '.ZIP'
        THEN
            DECLARE
                l_File_Blob   BLOB;
            BEGIN
                Tools.Unzip2 (p_Zip_Blob    => l_Import_Data.If_Data,
                              p_File_Blob   => l_File_Blob,
                              p_File_Name   => l_Name);
                l_Clob := Tools.Convertb2c (l_File_Blob);
            EXCEPTION
                WHEN OTHERS
                THEN
                    Raise_Application_Error (
                        -20000,
                           'Помилка обробки архіву.'
                        || CHR (10)
                        || DBMS_UTILITY.Format_Error_Backtrace
                        || CHR (10)
                        || SQLERRM);
            END;
        ELSE
            l_Clob := Tools.Convertb2c (l_Import_Data.If_Data);
            l_Name := l_Import_Data.if_name;
        END IF;

        l_Sda_Dt := Tools.tdate (SUBSTR (l_Name, -12, 8), 'YYYYMMDD');

        IF l_Sda_Dt IS NULL
        THEN
            Raise_Application_Error (
                -20000,
                'В назві файлу не вказано період данних! IOC2EISSS_INV2VPO_YYYYMMDD.csv, де YYYYMMDD – дата формування файлу');
        END IF;

        --Дані будуть перезаписуватись, якщо період існує
        DELETE FROM src_disability_asopd
              WHERE TRUNC (Sda_dt, 'mm') = TRUNC (l_Sda_Dt, 'mm');

        SELECT NVL (
                   (SELECT MAX (Scd_Sc)
                      FROM Uss_Person.v_Sc_Document d
                     WHERE     Scd_Ndt IN (5)
                           AND Scd_St IN ('1', 'A')
                           AND scd_seria || Scd_Number =
                               REPLACE (Col005, ' ')              /*sda_n_id*/
                                                    ),
                   (SELECT MAX (Scd_Sc)     Scd_Sc
                      FROM Uss_Person.v_Sc_Document d
                     WHERE     Scd_Ndt IN (6, 7)
                           AND Scd_St IN ('1', 'A')
                           AND scd_seria || Scd_Number =
                               REPLACE (Col007, ' ')            /*sda_series*/
                                                    ))
                   AS sda_sc,
               TO_NUMBER (
                      '5'
                   || TRIM (
                          TO_CHAR (NVL (TOOLS.tnumber (Col001), 0), '0000')))
                   AS sda_org,
               TRIM (Col001)
                   AS sda_raj,
               TRIM (Col002)
                   AS sda_ls_nls,
               TRIM (Col003)
                   AS sda_fam_num,
               TRIM (Col004)
                   AS sda_pib,
               TRIM (Col005)
                   AS sda_n_id,
               TRIM (Col006)
                   AS sda_doctype,
               TRIM (Col007)
                   AS sda_series,
               TOOLS.tdate (Col008)
                   AS sda_bdate,
               TOOLS.tnumber (Col009, p_decimal_separator => ',')
                   AS sda_sumd,
               TRIM (Col010)
                   AS sda_dis_group,
               TOOLS.tdate (Col011)
                   AS sda_dis_begin,
               TOOLS.tdate (Col012)
                   AS sda_dis_end,
               DECODE (TRIM (Col013),
                       'TRUE', 'T',
                       'FALSE', 'F',
                       TRIM (Col013))
                   AS sda_osob_1,
               DECODE (TRIM (Col014),
                       'TRUE', 'T',
                       'FALSE', 'F',
                       TRIM (Col014))
                   AS sda_osob_2,
               DECODE (TRIM (Col015),
                       'TRUE', 'T',
                       'FALSE', 'F',
                       TRIM (Col015))
                   AS sda_osob_3,
               DECODE (TRIM (Col016),
                       'TRUE', 'T',
                       'FALSE', 'F',
                       TRIM (Col016))
                   AS sda_osob_4,
               DECODE (TRIM (Col017),
                       'TRUE', 'T',
                       'FALSE', 'F',
                       TRIM (Col017))
                   AS sda_osob_5,
               DECODE (TRIM (Col018),
                       'TRUE', 'T',
                       'FALSE', 'F',
                       TRIM (Col018))
                   AS sda_osob_6,
               DECODE (TRIM (Col019),
                       'TRUE', 'T',
                       'FALSE', 'F',
                       TRIM (Col019))
                   AS sda_osob_7,
               DECODE (TRIM (Col020),
                       'TRUE', 'T',
                       'FALSE', 'F',
                       TRIM (Col020))
                   AS sda_osob_8,
               DECODE (TRIM (Col021),
                       'TRUE', 'T',
                       'FALSE', 'F',
                       TRIM (Col021))
                   AS sda_osob_9,
               DECODE (TRIM (Col022),
                       'TRUE', 'T',
                       'FALSE', 'F',
                       TRIM (Col022))
                   AS sda_osob_10,
               DECODE (TRIM (Col023),
                       'TRUE', 'T',
                       'FALSE', 'F',
                       TRIM (Col023))
                   AS sda_osob_11,
               DECODE (TRIM (Col024),
                       'TRUE', 'T',
                       'FALSE', 'F',
                       TRIM (Col024))
                   AS sda_osob_12
          BULK COLLECT INTO l_data
          FROM TABLE (
                   Csv_Util_Pkg.Clob_To_Csv (
                       REGEXP_REPLACE (
                           l_Clob,
                           '(' || CHR (10) || '|' || CHR (13) || ')+$'),
                       ';',
                       1));

        IF l_data.COUNT = 0
        THEN
            Raise_Application_Error (-20000,
                                     'В завантаженому файлі немає записів!');
        END IF;

        FOR i IN 1 .. l_data.COUNT
        LOOP
            IF NVL (LENGTH (l_data (i).sda_raj), 0) > 4
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Код структурного підрозділу" не повинно містити більше 4 символів');
            ELSIF NVL (LENGTH (l_data (i).sda_ls_nls), 0) > 6
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Особовий рахунок отримувача" не повинно містити більше 6 символів');
            ELSIF NVL (LENGTH (l_data (i).sda_fam_num), 0) > 10
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Номер члена родини" не повинно містити більше 10 символів');
            ELSIF NVL (LENGTH (l_data (i).sda_pib), 0) > 100
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "ПІБ" не повинно містити більше 100 символів');
            ELSIF NVL (LENGTH (l_data (i).sda_n_id), 0) > 12
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "РНОКПП" не повинно містити більше 12 символів');
            ELSIF NVL (LENGTH (l_data (i).sda_doctype), 0) > 10
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Тип документу" не повинно містити більше 10 символів');
            ELSIF NVL (LENGTH (l_data (i).sda_series), 0) > 20
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Серія та номер документу що посвідчує особу" не повинно містити більше 20 символів');
            ELSIF NVL (LENGTH (l_data (i).sda_dis_group), 0) > 10
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Група інвалідності" не повинно містити більше 10 символів');
            ELSIF NVL (LENGTH (l_data (i).sda_osob_1), 0) > 10
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Особа, яка доглядає за інвалідом I групи" не повинно містити більше 10 символів');
            ELSIF NVL (LENGTH (l_data (i).sda_osob_2), 0) > 10
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Особа, яка доглядає за особою з інвалідністю I чи II групи внаслідок психічного розладу" не повинно містити більше 10 символів');
            ELSIF NVL (LENGTH (l_data (i).sda_osob_3), 0) > 10
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Особа, яка доглядає за особою, яка досягла 80 років" не повинно містити більше 10 символів');
            ELSIF NVL (LENGTH (l_data (i).sda_osob_4), 0) > 10
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "sda_osob_4" не повинно містити більше 10 символів');
            ELSIF NVL (LENGTH (l_data (i).sda_osob_5), 0) > 10
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "sda_osob_5" не повинно містити більше 10 символів');
            ELSIF NVL (LENGTH (l_data (i).sda_osob_6), 0) > 10
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Особа, яка доглядає за особою з інвалідністю І чи ІІ групи" не повинно містити більше 10 символів');
            ELSIF NVL (LENGTH (l_data (i).sda_osob_7), 0) > 10
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Особа з інвалідністю І групи" не повинно містити більше 10 символів');
            ELSIF NVL (LENGTH (l_data (i).sda_osob_8), 0) > 10
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Особа з інвалідністю І чи ІІ групи внаслідок психічного розладу" не повинно містити більше 10 символів');
            ELSIF NVL (LENGTH (l_data (i).sda_osob_9), 0) > 10
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Особа, яка досягла 80 років" не повинно містити більше 10 символів');
            ELSIF NVL (LENGTH (l_data (i).sda_osob_10), 0) > 10
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Особа з інвалідністю І чи ІІ групи" не повинно містити більше 10 символів');
            ELSIF NVL (LENGTH (l_data (i).sda_osob_11), 0) > 10
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Особа, яка доглядає за дитиною з інвалідністю" не повинно містити більше 10 символів');
            ELSIF NVL (LENGTH (l_data (i).sda_osob_12), 0) > 10
            THEN
                Raise_Application_Error (
                    -20000,
                       'В рядку '
                    || i
                    || ' поле "Дитина з інвалідністю" не повинно містити більше 10 символів');
            END IF;
        END LOOP;

        FORALL i IN 1 .. l_data.COUNT
            INSERT INTO src_disability_asopd (sda_id,
                                              sda_if,
                                              sda_dt,
                                              sda_sc,
                                              sda_org,
                                              sda_raj,
                                              sda_ls_nls,
                                              sda_fam_num,
                                              sda_pib,
                                              sda_n_id,
                                              sda_doctype,
                                              sda_series,
                                              sda_bdate,
                                              sda_sumd,
                                              sda_dis_group,
                                              sda_dis_begin,
                                              sda_dis_end,
                                              sda_osob_1,
                                              sda_osob_2,
                                              sda_osob_3,
                                              sda_osob_4,
                                              sda_osob_5,
                                              sda_osob_6,
                                              sda_osob_7,
                                              sda_osob_8,
                                              sda_osob_9,
                                              sda_osob_10,
                                              sda_osob_11,
                                              sda_osob_12)
                 VALUES (0,
                         p_If_Id,
                         l_Sda_Dt,
                         l_data (i).sda_sc,
                         l_data (i).sda_org,
                         l_data (i).sda_raj,
                         l_data (i).sda_ls_nls,
                         l_data (i).sda_fam_num,
                         l_data (i).sda_pib,
                         l_data (i).sda_n_id,
                         l_data (i).sda_doctype,
                         l_data (i).sda_series,
                         l_data (i).sda_bdate,
                         l_data (i).sda_sumd,
                         l_data (i).sda_dis_group,
                         l_data (i).sda_dis_begin,
                         l_data (i).sda_dis_end,
                         l_data (i).sda_osob_1,
                         l_data (i).sda_osob_2,
                         l_data (i).sda_osob_3,
                         l_data (i).sda_osob_4,
                         l_data (i).sda_osob_5,
                         l_data (i).sda_osob_6,
                         l_data (i).sda_osob_7,
                         l_data (i).sda_osob_8,
                         l_data (i).sda_osob_9,
                         l_data (i).sda_osob_10,
                         l_data (i).sda_osob_11,
                         l_data (i).sda_osob_12);
    END;

    --#102483
    PROCEDURE chk_data_disability (p_If_Id IN Import_Files.If_Id%TYPE)
    IS
        l_count    NUMBER;
        l_clob     CLOB;
        l_name     VARCHAR2 (32767);

        l_clb      CLOB;
        l_result   BLOB;
    BEGIN
        IF l_Import_Data.If_Nfit <> 8
        THEN
            Raise_Application_Error (
                -20000,
                   'Не можна завантажувати функцією chk_data_disability файли з типом імпорту <'
                || l_Import_Data.If_Nfit
                || '>!');
        END IF;

        IF Tools.Getcurrorgto NOT IN (30, 40)
        THEN
            Raise_Application_Error (
                -20000,
                   'Файли з типом імпорту <'
                || l_Import_Data.If_Nfit
                || '> можуть завантажувати тільки користувачі ЦА МСП та ІОЦ!');
        END IF;

        IF UPPER (SUBSTR (l_Import_Data.if_name, -4)) = '.ZIP'
        THEN
            DECLARE
                l_File_Blob   BLOB;
            BEGIN
                Tools.Unzip2 (p_Zip_Blob    => l_Import_Data.If_Data,
                              p_File_Blob   => l_File_Blob,
                              p_File_Name   => l_name);
                l_clob := Tools.Convertb2c (l_File_Blob);
            EXCEPTION
                WHEN OTHERS
                THEN
                    Raise_Application_Error (
                        -20000,
                           'Помилка обробки архіву.'
                        || CHR (10)
                        || DBMS_UTILITY.Format_Error_Backtrace
                        || CHR (10)
                        || SQLERRM);
            END;
        ELSE
            l_clob := Tools.Convertb2c (l_Import_Data.If_Data);
            l_name := l_Import_Data.if_name;
        END IF;

        DELETE FROM tmp_work_set4
              WHERE 1 = 1;

        INSERT INTO tmp_work_set4 (x_string1,
                                   x_dt1,
                                   x_string2,
                                   x_string3,
                                   x_id1)
            SELECT t_full_name,
                   t_birth_dt,
                   t_passport,
                   t_inn,
                   CASE
                       WHEN t_sc IS NOT NULL
                       THEN
                           t_sc
                       WHEN REGEXP_COUNT (t_full_name, ' ') = 1
                       THEN
                           (SELECT MAX (s.sc_id)
                              FROM uss_person.v_socialcard   s,
                                   uss_person.v_sc_change    ch,
                                   uss_person.v_sc_identity  i,
                                   uss_person.v_sc_birth     b
                             WHERE     ch.scc_id = s.sc_scc
                                   AND i.sci_id = ch.scc_sci
                                   AND b.scb_id = ch.scc_scb
                                   AND t_full_name =
                                       i.sci_ln || ' ' || i.sci_fn
                                   AND t_birth_dt = b.scb_dt)
                       ELSE
                           (SELECT MAX (s.sc_id)
                              FROM uss_person.v_socialcard   s,
                                   uss_person.v_sc_change    ch,
                                   uss_person.v_sc_identity  i,
                                   uss_person.v_sc_birth     b
                             WHERE     ch.scc_id = s.sc_scc
                                   AND i.sci_id = ch.scc_sci
                                   AND b.scb_id = ch.scc_scb
                                   AND t_full_name =
                                          i.sci_ln
                                       || ' '
                                       || i.sci_fn
                                       || ' '
                                       || i.sci_mn
                                   AND t_birth_dt = b.scb_dt)
                   END    t_sc
              FROM (SELECT REPLACE (TRIM (Col001), 'I', 'І')
                               AS t_full_name,
                           TOOLS.tdate (Col002)
                               AS t_birth_dt,
                           TRIM (Col003)
                               AS t_passport,
                           TRIM (Col004)
                               AS t_inn,
                           CASE
                               WHEN TRIM (Col004)                      /*INN*/
                                                  IS NOT NULL
                               THEN
                                   (SELECT MAX (scd_sc)
                                      FROM uss_person.v_sc_document d
                                     WHERE     scd_ndt IN (5)
                                           AND scd_st IN ('1', 'A')
                                           AND scd_seria || scd_number =
                                               TRIM (Col004)           /*INN*/
                                                            )
                               ELSE
                                   (SELECT MAX (scd_sc)     scd_sc
                                      FROM uss_person.v_sc_document d
                                     WHERE     scd_ndt IN (6, 7)
                                           AND scd_st IN ('1', 'A')
                                           AND scd_seria || scd_number =
                                               TRIM (Col003)      /*PASSPORT*/
                                                            )
                           END
                               AS t_sc
                      FROM TABLE (
                               Csv_Util_Pkg.Clob_To_Csv (
                                   REGEXP_REPLACE (
                                       l_Clob,
                                          '('
                                       || CHR (10)
                                       || '|'
                                       || CHR (13)
                                       || ')+$'),
                                   ';',
                                   1)));

        l_count := SQL%ROWCOUNT;

        IF l_count = 0
        THEN
            Raise_Application_Error (-20000,
                                     'В завантаженому файлі немає записів!');
        END IF;

        set_import_file_status (1, p_if_id, 'Z');

        DBMS_LOB.createtemporary (lob_loc => l_clb, cache => TRUE);
        DBMS_LOB.open (lob_loc => l_clb, open_mode => DBMS_LOB.lob_readwrite);

        --назви полів csv
        DBMS_LOB.append (
            l_clb,
               '"ПІБ";"Дата народження";"Паспорт";"РНОКПП";"Причина інвалідності";"Група інвалідності";"Номер довідки МСЕК";"Дата встановлення інвалідності";"Дата закінчення дії МСЕК";"Адреса проживання";"Найменування допомоги, яку отримує в ЄІССС"'
            || CHR (13)
            || CHR (10));

        FOR c
            IN (SELECT uss_person.api$sc_tools.get_pib (p_sc_id => s.sc_id)
                           x_pib,
                       TO_CHAR (
                           NVL (
                               uss_person.api$sc_tools.GET_BIRTHDATE (
                                   p_sc_id   => s.sc_id),
                               x_dt1                              /*birth_dt*/
                                    ),
                           'dd.mm.yyyy')
                           x_birth_dt,
                       NVL (
                           uss_person.api$sc_tools.get_doc_num (
                               p_sc_id   => s.sc_id),
                           x_string2                              /*passport*/
                                    )
                           x_passport,
                       NVL (
                           uss_person.api$sc_tools.get_numident (
                               p_sc_id   => s.sc_id),
                           x_string3                                   /*inn*/
                                    )
                           x_inn,
                       COALESCE (
                           (SELECT (SELECT dic_name
                                      FROM uss_ndi.v_ddn_inv_reason
                                     WHERE dic_value = da.apda_val_string)
                              FROM uss_esr.ap_person         pp,
                                   uss_esr.ap_document       ad,
                                   uss_esr.ap_document_attr  da
                             WHERE     pp.app_sc = s.sc_id
                                   AND pp.app_ap = ad.apd_ap
                                   AND pp.app_id = ad.apd_app
                                   AND ad.apd_ndt = 201
                                   AND ad.apd_id = da.apda_apd
                                   AND ad.history_status = 'A'
                                   AND da.apda_nda = 353
                                   AND da.history_status = 'A'
                             FETCH FIRST ROW ONLY),
                           (  SELECT NVL ( (SELECT dic_name
                                              FROM uss_ndi.v_ddn_inv_reason
                                             WHERE dic_value = d.scy_reason),
                                          d.scy_reason)
                                FROM uss_person.v_sc_disability d
                               WHERE     d.scy_sc = s.sc_id
                                     AND d.history_status = 'A'
                            ORDER BY d.scy_id DESC
                               FETCH FIRST ROW ONLY))
                           x_scy_reason,
                       (  SELECT d.scy_group
                            FROM uss_person.v_sc_disability d
                           WHERE d.scy_sc = s.sc_id AND d.history_status = 'A'
                        ORDER BY d.scy_id DESC
                           FETCH FIRST ROW ONLY)
                           x_scy_group,
                       COALESCE (
                           (SELECT da.apda_val_string
                              FROM uss_esr.ap_person         pp,
                                   uss_esr.ap_document       ad,
                                   uss_esr.ap_document_attr  da
                             WHERE     pp.app_sc = s.sc_id
                                   AND pp.app_ap = ad.apd_ap
                                   AND pp.app_id = ad.apd_app
                                   AND ad.apd_ndt = 201
                                   AND ad.apd_id = da.apda_apd
                                   AND ad.history_status = 'A'
                                   AND da.apda_nda = 346
                                   AND da.history_status = 'A'
                             FETCH FIRST ROW ONLY),
                           (SELECT d.scd_number
                              FROM uss_person.v_sc_document d
                             WHERE     d.scd_sc = s.sc_id
                                   AND d.scd_st = '1'
                                   AND scd_ndt = 10135
                             FETCH FIRST ROW ONLY))
                           x_scy_doc,
                       TO_CHAR (
                           (  SELECT d.scy_decision_dt
                                FROM uss_person.v_sc_disability d
                               WHERE     d.scy_sc = s.sc_id
                                     AND d.history_status = 'A'
                            ORDER BY d.scy_id DESC
                               FETCH FIRST ROW ONLY),
                           'dd.mm.yyyy')
                           x_scy_decision_dt,
                       TO_CHAR (
                           (  SELECT d.scy_till_dt
                                FROM uss_person.v_sc_disability d
                               WHERE     d.scy_sc = s.sc_id
                                     AND d.history_status = 'A'
                            ORDER BY d.scy_id DESC
                               FETCH FIRST ROW ONLY),
                           'dd.mm.yyyy')
                           x_scy_till_dt,
                       (SELECT    d.sca_city
                               || ' '
                               || d.sca_street
                               || CASE
                                      WHEN d.sca_building IS NOT NULL
                                      THEN
                                          ' буд. '
                                      ELSE
                                          ' '
                                  END
                               || d.sca_building
                               || CASE
                                      WHEN d.sca_apartment IS NOT NULL
                                      THEN
                                          ' кв. '
                                      ELSE
                                          ' '
                                  END
                               || d.sca_apartment
                          FROM uss_person.v_sc_address d
                         WHERE     d.sca_sc = s.sc_id
                               AND d.sca_tp = 2
                               AND d.history_status = 'A'
                         FETCH FIRST ROW ONLY)
                           x_address,
                       (SELECT LISTAGG (DISTINCT nst.nst_name, '; ')
                                   WITHIN GROUP (ORDER BY nst.nst_id)
                          FROM uss_esr.pc_decision         pd,
                               uss_esr.personalcase        pc,
                               uss_ndi.v_ndi_service_type  nst
                         WHERE     pd.pd_pc = pc.pc_id
                               AND pc.pc_sc = s.sc_id
                               AND pd.pd_nst = nst.nst_id)
                           x_service_type
                  FROM uss_person.v_socialcard s, tmp_work_set4 d
                 WHERE s.sc_id = d.x_id1                                /*sc*/
                                        )
        LOOP
            DBMS_LOB.append (
                l_clb,
                   '"'
                || c.x_pib
                || '";"'
                || c.x_birth_dt
                || '";"'
                || c.x_passport
                || '";"'
                || c.x_inn
                || '";"'
                || c.x_scy_reason
                || '";"'
                || c.x_scy_group
                || '";"'
                || c.x_scy_doc
                || '";"'
                || c.x_scy_decision_dt
                || '";"'
                || c.x_scy_till_dt
                || '";"'
                || c.x_address
                || '";"'
                || c.x_service_type
                || '"'
                || CHR (13)
                || CHR (10));
        END LOOP;

        l_result := uss_esr.TOOLS.ConvertC2B (p_src => l_clb);

        UPDATE v_import_files f
           SET f.if_result = l_result
         WHERE f.if_id = p_if_id;

        set_import_file_status (1, p_if_id, 'I');
    END;

    PROCEDURE import_data (p_if_id           import_files.if_id%TYPE,
                           p_mode            INTEGER DEFAULT 1,
                           p_imoprt_tp       INTEGER DEFAULT 2, --uss_ndi.v_ndi_import_type.nfit_id
                           p_files       OUT SYS_REFCURSOR)
    IS
        l_lock_init   TOOLS.t_lockhandler;
        l_msg         VARCHAR2 (250);
    BEGIN
        l_lock_init :=
            TOOLS.request_lock (
                p_descr   => 'IMPORT_DATA_' || p_if_id,
                p_error_msg   =>
                       'В даний момент вже виконується імпорт файла '
                    || p_if_id
                    || '!');

        SELECT *
          INTO l_import_data
          FROM v_import_files
         WHERE if_id = p_if_id;

        l_hs := TOOLS.GetHistSession;

        CASE
            WHEN l_import_data.if_nfit = 2 AND p_imoprt_tp = 2
            THEN
                chk_data_and_import_tp2 (p_if_id => p_if_id);
            WHEN l_import_data.if_nfit = 3
            THEN
                chk_data_and_import_destroyed_prop (p_if_id => p_if_id);
            WHEN l_import_data.if_nfit = 4
            THEN
                chk_data_and_import_evacuees_reestr (p_if_id => p_if_id);
            WHEN l_import_data.if_nfit = 5
            THEN
                chk_data_and_import_pension_info (p_if_id => p_if_id);
            WHEN l_import_data.if_nfit = 6
            THEN
                chk_data_and_import_orphans_reestr (p_if_id => p_if_id);
            WHEN l_import_data.if_nfit = 7
            THEN
                chk_data_and_import_disability_asopd (p_if_id => p_if_id);
            WHEN l_import_data.if_nfit = 8
            THEN
                chk_data_disability (p_if_id => p_if_id);
            ELSE
                BEGIN
                    ROLLBACK;
                    raise_application_error (
                        -20000,
                           'Режим імпорту  <'
                        || l_import_data.if_nfit
                        || '> не підтримується!');
                END;
        END CASE;

        set_import_file_status (1, p_if_id, 'I');

        web_get_files_list (-1, p_mode, p_files);
        l_import_data := NULL;

        TOOLS.release_lock (l_lock_init);
    EXCEPTION
        WHEN OTHERS
        THEN
            l_msg := SQLERRM;
            l_import_data := NULL;
            ROLLBACK;
            TOOLS.release_lock (l_lock_init);
            raise_application_error (
                -20000,
                   l_msg
                || ':'
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;
BEGIN
    g_com_org := TOOLS.GetCurrOrg;
    g_com_wu := TOOLS.GetCurrWu;
END API$IMPORT_FILES;
/