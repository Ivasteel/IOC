/* Formatted on 8/12/2025 6:11:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.IKIS_WEB_FILE
    AUTHID CURRENT_USER
IS
    -- Author  : MEL
    -- Created : 12.12.2006 16:02:15
    -- Purpose : Завантаження файлів

    TYPE r_Def_fields IS RECORD
    (
        Fields          VARCHAR2 (4000),
        Fields_value    VARCHAR2 (32000)
    );

    -- +CSV
    TYPE t_column IS RECORD
    (
        ora_name     VARCHAR2 (100),
        csv_name     VARCHAR2 (100),
        col_order    INTEGER
    );

    TYPE t_tab_columns IS TABLE OF t_column;

    -- -CSV
    -- MEL: завантаження файлу з вебу в блоб
    --+MEL: 12.01.07 10:10 добавил параметр p_org
    FUNCTION UploadFile (
        p_filename   IN VARCHAR2,
        p_org        IN v_w_file$info.com_org%TYPE DEFAULT NULL)
        RETURN v_w_file$info.wf_filename%TYPE;

    --Mel: разархивирование файла
    PROCEDURE UnzipFile2Dir (p_blobfile   IN OUT NOCOPY BLOB,
                             p_filename                 VARCHAR2,
                             p_location                 VARCHAR2,
                             p_fl_unzip                 BOOLEAN := TRUE);

    -- MEL: розгортання файлів з блобу в директорію, задану через відповідний параметр для задачі в підсистемі
    FUNCTION ExtractToFiles (p_filename   VARCHAR2,
                             p_ss_code    ikis_subsys.ss_code%TYPE,
                             p_taskcode   VARCHAR2)
        RETURN ikis_lock.t_lockhandler;

    -- MEL: видалення файлу за Ідом. Ід має бути визначений в зовнішній процедурі, як і можливість видалення.
    PROCEDURE DeleteFile (p_file_id w_file$info.wf_id%TYPE);

    --YUra_AP 2006-12-25 Удаление устаревших файлов (у нас не файловое хранилище!)
    PROCEDURE DeleteObsoleteFiles (p_ss_code    ikis_subsys.ss_code%TYPE,
                                   p_taskcode   VARCHAR2);

    --+SLaviq Загрузка ДБФ
    PROCEDURE ikis_load_Table (p_file       IN VARCHAR2,
                               p_tname      IN VARCHAR2,
                               p_srcnames      DBMS_UTILITY.uncl_array,
                               p_db_ch      IN NUMBER DEFAULT 1,
                               p_blob_dbf      BLOB);

    ---
    --+ 20091003 YAP убрано из спецификации по согласованию со Slaviq
    /*--+Slaviq Создание ДБФ Dbase4
    function make_d4_column_script(
      p_tblname varchar2,
      p_where varchar2 := null,
      p_order  varchar2 := null,
      p_convert integer := 0,  --+Slaviq 29122008 Перечень полей которые не учавствуют в выгрузке
      p_ColNotIn varchar2 := null) ---Slaviq
      return varchar2; --0 RU8PC866 -1 CL8MSWIN1251 -2 не конвертить*/

    FUNCTION make_d4_all (p_tblname        VARCHAR2,
                          p_where          VARCHAR2 := NULL,
                          p_order          VARCHAR2 := NULL,
                          p_row_cnt    OUT NUMBER,
                          p_convert        INTEGER := 0, --+Slaviq 29122008 Перечень полей которые не учавствуют в выгрузке
                          p_ColNotIn       VARCHAR2 := NULL)
        RETURN BLOB;

    ---Slaviq

    --ivashchuk 2060506 додавання нової підсистеми W_FILE$SUBSYS
    PROCEDURE add_subsys (p_wfs_code   W_FILE$SUBSYS.WFS_CODE%TYPE,
                          p_wfs_name   VARCHAR2 DEFAULT '',
                          p_wfs_desc   VARCHAR2 DEFAULT '');

    -- конвертація  base10 в base35
    FUNCTION decimal2base35 (p_number IN INTEGER)
        RETURN VARCHAR2;

    --завантаження Dbf
    -- procedure to a load a table with records
    -- from a DBASE file.
    --
    -- Uses a BFILE to read binary data and dbms_sql
    -- to dynamically insert into any table you
    -- have insert on.
    --
    -- p_dir is the name of an ORACLE Directory Object
    --       that was created via the CREATE DIRECTORY
    --       command
    --
    -- p_file is the name of a file in that directory
    --        will be the name of the DBASE file
    --
    -- p_tname is the name of the table to load from
    --
    -- p_cnames is an optional list of comma separated
    --          column names.  If not supplied, this pkg
    --          assumes the column names in the DBASE file
    --          are the same as the column names in the
    --          table
    --
    -- p_show boolean that if TRUE will cause us to just
    --        PRINT (and not insert) what we find in the
    --        DBASE files (not the data, just the info
    --        from the dbase headers....)
    PROCEDURE Load_Table_DBF (p_blob         IN BLOB,
                              p_tname        IN VARCHAR2,
                              p_cnames       IN VARCHAR2 DEFAULT NULL,
                              p_Def_fields   IN r_Def_fields DEFAULT NULL,
                              p_show         IN BOOLEAN DEFAULT FALSE);


    -- +CSV
    FUNCTION GetColumnsList (p_column_list VARCHAR2)
        RETURN t_tab_columns
        PIPELINED;

    FUNCTION make_csv_all (p_tblname           VARCHAR2,
                           p_column_list       VARCHAR2,
                           p_where             VARCHAR2,
                           p_order             VARCHAR2 := NULL,
                           p_convert           INTEGER := 0,
                           p_row_cnt       OUT NUMBER)
        RETURN BLOB;
-- -CSV
END IKIS_WEB_FILE;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_WEB_FILE FOR IKIS_SYSWEB.IKIS_WEB_FILE
/


GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_FILE TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_FILE TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_FILE TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_FILE TO IKIS_WEBPROXY WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_FILE TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_FILE TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_FILE TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_FILE TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_FILE TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_FILE TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_FILE TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_FILE TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_FILE TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:11:45 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.IKIS_WEB_FILE
IS
    msgCOMMON_EXCEPTION   NUMBER := 2;

    BIG_ENDIAN   CONSTANT BOOLEAN DEFAULT TRUE;
    G_DB_CHARACTERSET     BOOLEAN := TRUE; -- ТРУ - ЗАРГУЗКА БЕЗ ПЕРЕКОДИРОВКИ, IF FALSE THEN DOS (ПЕРЕКОДИРОВКА ИЗ RU8PC866)

    DB_CHARSET            VARCHAR2 (100);
    DOC_CHARSET           VARCHAR2 (100) := 'RU8PC866';

    -- +CSV
    g_buff                VARCHAR2 (32760) := '';
    g_is_inited           BOOLEAN := FALSE;
    g_result_data         BLOB;

    -- -CSV

    --g_attr     ikis_subsys%rowtype;

    TYPE dbf_header IS RECORD
    (
        version       VARCHAR2 (25),                   -- dBASE version number
        year          INT,                     -- 1 byte int year, add to 1900
        month         INT,                                     -- 1 byte month
        day           INT,                                       -- 1 byte day
        no_records    INT,                       -- number of records in file,
        -- 4 byte int
        hdr_len       INT,                     -- length of header, 2 byte int
        rec_len       INT,                       -- number of bytes in record,
        -- 2 byte int
        no_fields     INT,                                 -- number of fields
        langdrv       INT                                     -- драйвер языка
    );


    TYPE field_descriptor IS RECORD
    (
        name        VARCHAR2 (11),
        TYPE        CHAR (1),
        LENGTH      INT,                                      -- 1 byte length
        decimals    INT                                        -- 1 byte scale
    );

    TYPE field_descriptor_array IS TABLE OF field_descriptor
        INDEX BY BINARY_INTEGER;


    TYPE rowArray IS TABLE OF VARCHAR2 (4000)
        INDEX BY BINARY_INTEGER;

    g_cursor              BINARY_INTEGER DEFAULT DBMS_SQL.open_cursor;

    --для procedure load_Table
    TYPE rowArrayCLOB IS TABLE OF CLOB
        INDEX BY BINARY_INTEGER;

    --+ 20091003 YAP убрано из спецификации по согласованию со Slaviq и перенесено в форвард-декларацию
    --+Slaviq Создание ДБФ Dbase4
    FUNCTION make_d4_column_script (p_tblname    VARCHAR2,
                                    p_where      VARCHAR2:= NULL,
                                    p_order      VARCHAR2:= NULL,
                                    p_convert    INTEGER:= 0, --+Slaviq 29122008 Перечень полей которые не учавствуют в выгрузке
                                    p_ColNotIn   VARCHAR2:= NULL)    ---Slaviq
        RETURN VARCHAR2;         --0 RU8PC866 -1 CL8MSWIN1251 -2 не конвертить

    -- MEL: завантаження файлу з вебу в блоб
    --+MEL: 12.01.07 10:10 добавил параметр p_org
    FUNCTION UploadFile (
        p_filename   IN VARCHAR2,
        p_org        IN v_w_file$info.com_org%TYPE DEFAULT NULL)
        RETURN v_w_file$info.wf_filename%TYPE
    IS
        l_filename   VARCHAR2 (4000);
        l_cnt        NUMBER;
        l_file_id    v_w_file$info.wf_id%TYPE;
        l_org        v_w_file$info.com_org%TYPE;
    BEGIN
        l_filename :=
            TRIM (
                UPPER (
                    SUBSTR (REPLACE (p_filename, '\', '/'),
                            INSTR (p_filename, '/') + 1,
                            10000)));

        SELECT COUNT (1)
          INTO l_cnt
          FROM w_file$info
         WHERE wf_filename = l_filename;

        IF l_cnt > 0
        THEN
            raise_application_error (-20000,
                                     'File already uploaded: ' || l_filename);
        ELSE
            --+MEL: 12.01.07 10:10 добавил параметр p_org
            IF (p_org IS NULL)
            THEN
                l_org :=
                    SYS_CONTEXT (IKIS_HTMLDB_COMMON.IKIS_SYSWEB_CONTEXT_NAME,
                                 IKIS_HTMLDB_COMMON.IKIS_SYSWEB_CONTEXT_OPFU);
            ELSE
                l_org := p_org;
            END IF;

            INSERT INTO v_w_file$info (wf_id,
                                       wf_filename,
                                       wf_st,
                                       wf_upload_dt,
                                       com_org,
                                       wf_wu)
                 VALUES (
                            0,
                            l_filename,
                            'L',
                            SYSDATE,
                            l_org,
                            SYS_CONTEXT (
                                IKIS_HTMLDB_COMMON.IKIS_SYSWEB_CONTEXT_NAME,
                                IKIS_HTMLDB_COMMON.IKIS_SYSWEB_CONTEXT_UID))
              RETURNING wf_id
                   INTO l_file_id;

            ---MEL: 12.01.07 10:10 добавил параметр p_org
            INSERT INTO v_w_file$download (wfd_id, wfd_wf, wfd_file_body)
                SELECT 0, l_file_id, blob_content
                  FROM wwv_flow_files
                 WHERE name = p_filename;

            RETURN l_filename;
        END IF;

        DELETE wwv_flow_files
         WHERE name = p_filename;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'IKIS_WEB_FILE.UploadFile:'--||sys_context(IKIS_HTMLDB_COMMON.IKIS_SYSWEB_CONTEXT_NAME, IKIS_HTMLDB_COMMON.IKIS_SYSWEB_CONTEXT_OPFU)||','
                                                                          --||sys_context(IKIS_HTMLDB_COMMON.IKIS_SYSWEB_CONTEXT_NAME, IKIS_HTMLDB_COMMON.IKIS_SYSWEB_CONTEXT_UID)
                                                                          ,
                                               CHR (10) || SQLERRM));
    END;

    --Mel: разархивирование файла
    PROCEDURE UnzipFile2Dir (p_blobfile   IN OUT NOCOPY BLOB,
                             p_filename                 VARCHAR2,
                             p_location                 VARCHAR2,
                             p_fl_unzip                 BOOLEAN := TRUE)
    IS
        v_read_amount   INTEGER := 32765;
        v_read_offset   INTEGER := 1;
        v_buffer        RAW (32767);
        l_file          UTL_FILE.file_type;
        l_outzipdir     VARCHAR2 (1000);
        l_inzipdir      VARCHAR2 (1000);
        l_workdirpath   VARCHAR2 (1000);
    BEGIN
        SELECT directory_path
          INTO l_workdirpath
          FROM all_directories
         WHERE directory_name = UPPER (p_location);

        l_outzipdir := l_workdirpath;
        l_inzipdir := l_workdirpath || '/' || p_filename;

        l_file :=
            UTL_FILE.fopen (location       => UPPER (p_location),
                            filename       => p_filename,
                            open_mode      => 'w',
                            max_linesize   => 32767);

        LOOP
            DBMS_LOB.read (p_blobfile,
                           v_read_amount,
                           v_read_offset,
                           v_buffer);
            UTL_FILE.put_raw (file        => l_file,
                              buffer      => v_buffer,
                              autoflush   => TRUE);
            v_read_offset := v_read_offset + v_read_amount;
            EXIT WHEN v_read_amount < 32765;
            v_read_amount := 32765;
        END LOOP;

        UTL_FILE.fclose (file => l_file);

        IF p_fl_unzip
        THEN
            viewzip$unzipall (p_zip => l_inzipdir, p_outdir => l_outzipdir);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'ikis_web_file.UnzipFile2Dir',
                       CHR (10)
                    || DBMS_UTILITY.format_error_stack
                    || DBMS_UTILITY.format_error_backtrace--    ||chr(13)||'111-111'||l_workdirpath||'-'||l_outzipdir||'-'||l_inzipdir||'-'||p_location||'-'||p_filename
                                                          ));
    END;

    -- MEL: розгортання файлів з блобу в директорію, задану через відповідний параметр для задачі в підсистемі
    FUNCTION ExtractToFiles (p_filename   VARCHAR2,
                             p_ss_code    ikis_subsys.ss_code%TYPE,
                             p_taskcode   VARCHAR2)
        RETURN ikis_lock.t_lockhandler
    IS
        l_file          v_w_file$download.wfd_file_body%TYPE;
        l_workdirname   VARCHAR2 (1000);
        l_lock          ikis_lock.t_lockhandler;
    BEGIN
        BEGIN
            SELECT fd.wfd_file_body
              INTO l_file
              FROM v_w_file$download fd, v_w_file$info fi
             WHERE     fi.wf_id = fd.wfd_wf
                   AND fi.wf_filename = UPPER (p_filename);
        EXCEPTION
            WHEN OTHERS
            THEN
                raise_application_error (
                    -20000,
                       'Не знайдено в базі даних тіла файлу: '
                    || UPPER (p_filename));
        END;

        l_workdirname :=
            ikis_parameter_util.GetParameter1 (
                p_par_code      => 'HTMLDB_DIRNAME_' || UPPER (TRIM (p_taskcode)),
                p_par_ss_code   => p_ss_code);

        ikis_lock.request_lock (
            p_permanent_name      => p_ss_code,
            p_var_name            => p_taskcode,
            p_errmessage          =>
                'Зараз вже виконується обробка файлів, спробуйте пізніше.',
            p_lockhandler         => l_lock,
            p_lockmode            => 6,
            p_timeout             => 10,
            p_release_on_commit   => TRUE);

        --Распаковка архива
        --  ikis_htmldb_common.unzipfile(p_blobfile => l_file,p_filename => p_filename);
        UnzipFile2Dir (p_blobfile   => l_file,
                       p_filename   => p_filename,
                       p_location   => l_workdirname);

        RETURN l_lock;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_WEB_FILE.ExtractToFiles',
                    CHR (10) || SQLERRM));
    END;

    -- MEL: видалення файлу за Ідом. Ід має бути визначений в зовнішній процедурі, як і можливість видалення.
    PROCEDURE DeleteFile (p_file_id w_file$info.wf_id%TYPE)
    IS
    BEGIN
        --Видаляємо тіло файла...
        DELETE FROM v_w_file$download
              WHERE wfd_wf = p_file_id;

        --Видаляємо заголовок файла...
        DELETE FROM v_w_file$info
              WHERE wf_id = p_file_id;

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'IKIS_WEB_FILE.DeleteFile: ',
                                               CHR (10) || SQLERRM));
    END;

    --YUra_AP 2006-12-25 Удаление устаревших файлов (у нас не файловое хранилище!)
    PROCEDURE DeleteObsoleteFiles (p_ss_code    ikis_subsys.ss_code%TYPE,
                                   p_taskcode   VARCHAR2)
    IS
        l_policy   NUMBER;
    BEGIN
        BEGIN
            l_policy :=
                TO_NUMBER (
                    ikis_parameter_util.GetParameter1 (
                        p_par_code      =>
                               'FILE_RETENTION_POLICY_'
                            || UPPER (TRIM (p_taskcode)),
                        p_par_ss_code   => p_ss_code));
        EXCEPTION
            WHEN OTHERS
            THEN
                l_policy := 30;
        END;

        ikis_file_job_pkg.SaveJobMessage (
            p_tp         => 'I',
            p_errormsg   => 'Політика: ' || l_policy);

        DELETE FROM v_w_file$download
              WHERE wfd_wf IN (SELECT wf_id
                                 FROM v_w_file$info
                                WHERE (SYSDATE - wf_upload_dt) > l_policy);

        ikis_file_job_pkg.SaveJobMessage (
            p_tp         => 'I',
            p_errormsg   => 'Вилучено файлів: ' || SQL%ROWCOUNT);
        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_WEB_FILE.DeleteObsoleteFiles: ',
                    CHR (10) || SQLERRM));
    END;

    --+Slaviq --общий функционал для загрузки ДБФ
    FUNCTION to_int (p_data IN VARCHAR2)
        RETURN NUMBER
    IS
        l_number   NUMBER DEFAULT 0;
        l_bytes    NUMBER DEFAULT LENGTH (p_data);
    BEGIN
        IF (big_endian)
        THEN
            FOR i IN 1 .. l_bytes
            LOOP
                l_number :=
                      l_number
                    + ASCII (SUBSTR (p_data, i, 1)) * POWER (2, 8 * (i - 1));
            END LOOP;
        ELSE
            FOR i IN 1 .. l_bytes
            LOOP
                l_number :=
                      l_number
                    +   ASCII (SUBSTR (p_data, l_bytes - i + 1, 1))
                      * POWER (2, 8 * (i - 1));
            END LOOP;
        END IF;

        RETURN l_number;
    END;

    FUNCTION mytrim (p_str IN VARCHAR2)
        RETURN VARCHAR2
    IS
        i       NUMBER;
        j       NUMBER;
        v_res   VARCHAR2 (100);
    BEGIN
        FOR i IN 1 .. 11
        LOOP
            IF ASCII (SUBSTR (p_str, i, 1)) = 0
            THEN
                j := i;
                EXIT;
            END IF;
        END LOOP;

        v_res := SUBSTR (p_str, 1, j - 1);
        RETURN v_res;
    END mytrim;

    PROCEDURE get_header (p_bfile          IN     BLOB,
                          p_bfile_offset   IN OUT NUMBER,
                          p_hdr            IN OUT dbf_header,
                          p_flds           IN OUT field_descriptor_array)
    IS
        l_data              VARCHAR2 (100);
        l_hdr_size          NUMBER DEFAULT 32;
        l_field_desc_size   NUMBER DEFAULT 32;
        l_flds              field_descriptor_array;
    BEGIN
        p_flds := l_flds;

        l_data :=
            UTL_RAW.cast_to_varchar2 (
                DBMS_LOB.SUBSTR (p_bfile, l_hdr_size, p_bfile_offset));
        p_bfile_offset := p_bfile_offset + l_hdr_size;

        p_hdr.version := ASCII (SUBSTR (l_data, 1, 1));
        p_hdr.year := 1900 + ASCII (SUBSTR (l_data, 2, 1));
        p_hdr.month := ASCII (SUBSTR (l_data, 3, 1));
        p_hdr.day := ASCII (SUBSTR (l_data, 4, 1));
        p_hdr.no_records := to_int (SUBSTR (l_data, 5, 4));
        p_hdr.hdr_len := to_int (SUBSTR (l_data, 9, 2));
        p_hdr.rec_len := to_int (SUBSTR (l_data, 11, 2));
        p_hdr.no_fields :=
            TRUNC ((p_hdr.hdr_len - l_hdr_size) / l_field_desc_size);
        p_hdr.langdrv := to_int (SUBSTR (l_data, 29, 1));


        FOR i IN 1 .. p_hdr.no_fields
        LOOP
            l_data :=
                UTL_RAW.cast_to_varchar2 (
                    DBMS_LOB.SUBSTR (p_bfile,
                                     l_field_desc_size,
                                     p_bfile_offset));
            p_bfile_offset := p_bfile_offset + l_field_desc_size;

            p_flds (i).name := mytrim (SUBSTR (l_data, 1, 11));
            p_flds (i).TYPE := SUBSTR (l_data, 12, 1);
            p_flds (i).LENGTH := ASCII (SUBSTR (l_data, 17, 1));
            p_flds (i).decimals := ASCII (SUBSTR (l_data, 18, 1));
        END LOOP;

        p_bfile_offset :=
              p_bfile_offset
            + MOD (p_hdr.hdr_len - l_hdr_size, l_field_desc_size);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'get_header (size): '
                || DBMS_LOB.getlength (p_bfile)
                || CHR (10)
                || SQLERRM);
    END;

    FUNCTION GetDBNameFromDBFName (p_file_id VARCHAR2, p_name VARCHAR2)
        RETURN VARCHAR2
    IS
    --l_res varchar2(100);
    BEGIN
        /*select iid_name_in_db into l_res from ikis_import_fields
         where iid_iif=p_file_id and upper(iid_name_in_file)=upper(p_name);
         l_res := p_name;
        return l_res;*/
        RETURN p_name;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'GetDBNameFromDBFName: '
                || p_file_id
                || ' '
                || p_name
                || CHR (10)
                || SQLERRM);
    END;

    FUNCTION SearchField (p_name          VARCHAR2,
                          p_srcnames   IN DBMS_UTILITY.uncl_array)
        RETURN BOOLEAN
    IS
    BEGIN
        FOR i IN 1 .. p_srcnames.COUNT
        LOOP
            IF UPPER (p_srcnames (i)) = UPPER (p_name)
            THEN
                RETURN TRUE;
            END IF;
        END LOOP;

        RETURN FALSE;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (-20000,
                                     'SearchField: ' || CHR (10) || SQLERRM);
    END;

    FUNCTION ikis_build_insert (p_tname      IN VARCHAR2,
                                p_srcnames   IN DBMS_UTILITY.uncl_array,
                                p_flds       IN field_descriptor_array,
                                p_file          VARCHAR2)
        RETURN VARCHAR2
    IS
        l_insert_statement   LONG;
        l_cnt                NUMBER := 1;
        l_tmp                VARCHAR2 (1000);
        l_cnames             VARCHAR2 (32760);
    BEGIN
        l_insert_statement :=
            'insert into ' || p_tname || '( <FLDLST> ) values (';

        FOR i IN 1 .. p_flds.COUNT
        LOOP
            l_tmp := p_flds (i).name;

            IF SearchField (p_flds (i).name, p_srcnames)
            THEN
                IF l_cnames IS NULL
                THEN
                    l_cnames :=
                           l_cnames
                        || GetDBNameFromDBFName (p_file, p_flds (i).name);
                ELSE
                    l_cnames :=
                           l_cnames
                        || ','
                        || GetDBNameFromDBFName (p_file, p_flds (i).name);
                END IF;

                IF (l_cnt <> 1)
                THEN
                    l_insert_statement := l_insert_statement || ',';
                END IF;

                l_cnt := l_cnt + 1;

                IF (p_flds (i).TYPE = 'D')
                THEN
                    l_insert_statement :=
                           l_insert_statement
                        || 'to_date(:b_'
                        || p_flds (i).name
                        || ',''yyyymmdd'' )';
                ELSE
                    l_insert_statement :=
                        l_insert_statement || ':b_' || p_flds (i).name;
                END IF;
            END IF;
        END LOOP;

        l_insert_statement := l_insert_statement || ')';

        RETURN REPLACE (l_insert_statement, '<FLDLST>', l_cnames);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'ikis_build_insert: ' || CHR (10) || SQLERRM);
    END;


    FUNCTION get_row (p_bfile          IN     BLOB,
                      p_bfile_offset   IN OUT NUMBER,
                      p_hdr            IN     dbf_header,
                      p_flds           IN     field_descriptor_array)
        RETURN rowArray
    IS
        l_data        VARCHAR2 (4000);
        l_row         rowArray;
        l_n           NUMBER DEFAULT 2;
        l_NumberRow   NUMBER;                                      -- by Roman
        l_StringRow   VARCHAR2 (255);                              -- by Roman
    BEGIN
        l_data :=
            UTL_RAW.cast_to_varchar2 (
                DBMS_LOB.SUBSTR (p_bfile, p_hdr.rec_len, p_bfile_offset));
        p_bfile_offset := p_bfile_offset + p_hdr.rec_len;

        l_row (0) := SUBSTR (l_data, 1, 1);

        FOR i IN 1 .. p_hdr.no_fields
        LOOP
            BEGIN
                l_row (i) :=
                    RTRIM (LTRIM (SUBSTR (l_data, l_n, p_flds (i).LENGTH)));

                -- by Roman, jan.2004, Slovenia
                -- Because of different NLS_LANG parameters, an error occured with message: INVALID NUMBER.
                -- Because the type rowArray is consisted of strings, we have to change to real (system) decimal character.
                -- Some could use , and someone could use .
                -- So, what I do here:
                -- I convert the string value of number to number value and that back to string value.
                IF (p_flds (i).TYPE = 'F' OR p_flds (i).TYPE = 'N')
                THEN                         -- Only for Float and Number type
                    BEGIN
                        BEGIN
                            l_StringRow := TRIM (l_row (i)); --Save to temporary variable
                            l_StringRow :=
                                TRIM (BOTH CHR (0) FROM l_StringRow);
                            l_StringRow := REPLACE (l_StringRow, ',', '.'); --We change characters

                            IF l_StringRow = '-'
                            THEN
                                l_StringRow := NULL;
                            END IF;                               --кастыль!!!

                            l_NumberRow := TO_NUMBER (l_StringRow); -- try to convert to number
                            l_row (i) := TO_CHAR (l_NumberRow); --If succeded that we have right number value!
                        EXCEPTION
                            WHEN OTHERS
                            THEN
                                l_StringRow := TRIM (l_row (i)); --Save to temporary variable
                                l_StringRow :=
                                    TRIM (BOTH CHR (0) FROM l_StringRow);
                                l_StringRow :=
                                    REPLACE (l_StringRow, '.', ','); --We change characters
                                l_NumberRow := TO_NUMBER (l_StringRow); -- try to convert to number
                                l_row (i) := TO_CHAR (l_NumberRow); --If succeded that we have right number value!
                        END;
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            raise_application_error (
                                -20000,
                                'Error of Number Conversion: ' || SQLERRM);
                    END;
                END IF;

                -- End Roman

                IF NOT G_DB_CHARACTERSET
                THEN
                    IF p_flds (i).TYPE = 'C'
                    THEN
                        l_row (i) :=
                            CONVERT (l_row (i), DB_CHARSET, DOC_CHARSET);
                    END IF;
                END IF;

                IF (p_flds (i).TYPE = 'F' AND l_row (i) = '.')
                THEN
                    l_row (i) := NULL;
                END IF;

                l_n := l_n + p_flds (i).LENGTH;
            EXCEPTION
                WHEN OTHERS
                THEN
                    raise_application_error (
                        -20000,
                           'get_row loop (NAME,TYPE,RAW): '
                        || CHR (10)
                        || p_flds (i).name
                        || CHR (10)
                        || p_flds (i).TYPE
                        || CHR (10)
                        || l_row (i)
                        || CHR (10)
                        || SQLERRM);
            END;
        END LOOP;

        RETURN l_row;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (-20000,
                                     'get_row: ' || CHR (10) || SQLERRM);
    END get_row;

    PROCEDURE ikis_load_Table (p_file       IN VARCHAR2,
                               p_tname      IN VARCHAR2,
                               p_srcnames      DBMS_UTILITY.uncl_array,
                               p_db_ch      IN NUMBER DEFAULT 1,
                               p_blob_dbf      BLOB)
    IS
        l_offset     NUMBER DEFAULT 1;
        l_hdr        dbf_header;
        l_flds       field_descriptor_array;
        l_row        rowArray;
        l_sql        VARCHAR2 (32760);
        l_tmp        VARCHAR2 (32760);
        l_tmp1       VARCHAR2 (32760);
        l_curr_row   NUMBER;

        l_blob       BLOB;
        l_sz         NUMBER;
    BEGIN
        G_DB_CHARACTERSET := p_db_ch = 1;

        l_blob := p_blob_dbf;
        DBMS_LOB.open (lob_loc => l_blob, open_mode => DBMS_LOB.lob_readonly);
        l_sz := DBMS_LOB.getlength (l_blob);

        IF l_sz = 0
        THEN
            raise_application_error (-20000,
                                     'Пустий файл: ' || UPPER (p_file));
        END IF;

        get_header (l_blob,
                    l_offset,
                    l_hdr,
                    l_flds);
        l_sql :=
            ikis_build_insert (p_tname,
                               p_srcnames,
                               l_flds,
                               'x'                               /*p_file_id*/
                                  );
        DBMS_SQL.parse (g_cursor, l_sql, DBMS_SQL.native);

        FOR i IN 1 .. l_hdr.no_records
        LOOP
            l_curr_row := i;
            l_row :=
                get_row (l_blob,
                         l_offset,
                         l_hdr,
                         l_flds);

            BEGIN
                IF (l_row (0) <> '*')                        -- deleted record
                THEN
                    FOR i IN 1 .. l_hdr.no_fields
                    LOOP
                        IF SearchField (l_flds (i).name, p_srcnames)
                        THEN
                            BEGIN
                                l_tmp := l_flds (i).name;
                                l_tmp1 := l_row (i);
                                DBMS_SQL.bind_variable (
                                    g_cursor,
                                    ':b_' || l_flds (i).name,
                                    l_row (i),
                                    4000);
                            EXCEPTION
                                WHEN OTHERS
                                THEN
                                    raise_application_error (
                                        -20000,
                                           'BIND ERROR (NAME,RAW): '
                                        || CHR (10)
                                        || l_flds (i).name
                                        || CHR (10)
                                        || l_row (i)
                                        || CHR (10)
                                        || SQLERRM);
                            END;
                        END IF;
                    END LOOP;

                    BEGIN
                        IF (DBMS_SQL.execute (g_cursor) <> 1)
                        THEN
                            raise_application_error (
                                -20000,
                                'Insert failed: ' || CHR (10) || SQLERRM);
                        END IF;
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            raise_application_error (
                                -20000,
                                   'LOAD INTO BUFFER ERROR: '
                                || CHR (10)
                                || SQLERRM);
                    END;
                END IF;
            EXCEPTION
                WHEN OTHERS
                THEN
                    raise_application_error (
                        -20000,
                           'Process Row (NAME,TYPE,RAW): '
                        || CHR (10)
                        || l_flds (i).name
                        || CHR (10)
                        || l_flds (i).TYPE
                        || CHR (10)
                        || l_row (i)
                        || CHR (10)
                        || SQLERRM);
            END;
        END LOOP;

        IF (DBMS_LOB.ISOPEN (l_blob) > 0)
        THEN
            DBMS_LOB.close (l_blob);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            IF (DBMS_LOB.ISOPEN (l_blob) > 0)
            THEN
                DBMS_LOB.close (l_blob);
            END IF;

            RAISE_APPLICATION_ERROR (
                -20000,
                   'Error in file: '
                || p_file
                || '; row('
                || l_curr_row
                || '):'
                || l_sz
                || CHR (10)
                || SQLERRM);
    END;

    FUNCTION to_ascii (p_number IN NUMBER)
        RETURN VARCHAR2
    IS
        l_number   NUMBER := p_number;
        l_data     VARCHAR2 (8);
        l_bytes    NUMBER;
        l_byte     NUMBER;
    BEGIN
        SELECT VSIZE (l_number) INTO l_bytes FROM DUAL;

        FOR i IN 1 .. l_bytes
        LOOP
            l_byte :=
                TRUNC (
                    MOD (l_number, POWER (2, 8 * i)) / POWER (2, 8 * (i - 1)));
            l_data := l_data || CHR (l_byte);
        END LOOP;

        RETURN l_data;
    END to_ascii;

    FUNCTION make_d4_header (p_tblname        VARCHAR2,
                             p_where          VARCHAR2 := NULL,
                             p_row_cnt    OUT NUMBER,
                             p_convert        INTEGER := 0,
                             --+Slaviq 04032009 добавлена возможность игнора столбцов
                             p_ColNotIn       VARCHAR2 := NULL)
        RETURN VARCHAR2
    ---Slaviq
    IS
        l_header              VARCHAR2 (32767);
        l_number_of_columns   BINARY_INTEGER;
        l_line_length         BINARY_INTEGER;
        l_number_of_records   NUMBER;

        CURSOR c_columns IS
              SELECT c.column_name,
                     DECODE (c.data_type,
                             'VARCHAR2', 'C',
                             'DATE', 'D',
                             'NUMBER', 'N',
                             'C')              data_type,
                     --+Slaviq 04032009 подправлены вывод Нумерик полей
                     --decode(c.data_type, 'DATE', 8, 'NUMBER',nvl(c.data_precision + decode(nvl(c.data_scale,0),0,0,c.data_scale+1),20),c.data_length) data_length,
                     DECODE (c.data_type,
                             'DATE', 8,
                             'NUMBER', NVL (c.data_precision, 20),
                             c.data_length)    data_length,
                     ---Slaviq
                     NVL (c.data_scale, 0)     data_scale
                FROM all_tab_columns c
               WHERE     c.table_name = p_tblname
                     AND UPPER (c.column_name) <> 'KEYFLD'
                     --+Slaviq 04032009 Перечень полей которые не учавствуют в выгрузке
                     AND (   p_ColNotIn IS NULL
                          OR     p_ColNotIn IS NOT NULL
                             AND INSTR (p_ColNotIn,
                                        '''' || column_name || '''') =
                                 0)
            ---Slaviq;
            --+Slaviq Сотировка по порядку
            ORDER BY column_id;

        ---Slaviq
        TYPE cv_typ IS REF CURSOR;

        CV                    cv_typ;
    BEGIN
          --+Slaviq 04032009 исправление формата нумерик поля
          SELECT COUNT (*),
                   SUM (
                       DECODE (c.data_type,
                               'DATE', 8,
                               'NUMBER', NVL (c.data_precision, 20),
                               c.data_length))
                 + 1
            --select count(*), sum(decode(c.data_type, 'DATE', 8, 'NUMBER',nvl(c.data_precision + decode(nvl(c.data_scale,0),0,0,c.data_scale+1),20),c.data_length)) + 1
            ---Slaviq 04032009
            --+1 потому что к строке добавляется символ
            --удалена или нет
            INTO l_number_of_columns, l_line_length
            FROM all_tab_columns c
           WHERE     c.table_name = p_tblname
                 AND UPPER (c.column_name) <> 'KEYFLD'
                 --+Slaviq 04/03/2009 если исключения, то длина записи будет другой
                 AND (   p_ColNotIn IS NULL
                      OR     p_ColNotIn IS NOT NULL
                         AND INSTR (p_ColNotIn, '''' || column_name || '''') =
                             0)
        ---Slaviq 04/03/2009 если исключения, то длина записи будет другой
        --+Slaviq Сотировка по порядку
        ORDER BY column_id;

        ---Slaviq
        OPEN CV FOR
               'select count(*) cnt from '
            || p_tblname
            || ' where 1=1 '
            || CASE WHEN p_where IS NOT NULL THEN 'and ' || p_where END;

        LOOP
            FETCH CV INTO l_number_of_records;

            EXIT WHEN CV%NOTFOUND;
        END LOOP;

        p_row_cnt := l_number_of_records;
        --select count(*) into l_number_of_records from tmp_ecr_ic_answer;
        --ЗАГОЛОВОК
        --№ - номер байта
        -- №0 Версия/ 1 байт
        -- 03 - простая таблица
        l_header := CHR (3);
        -- №1,2,3 Дата последнего обновления таблицы в формате YYMMDD/ 3 байта
        l_header :=
               l_header
            || CHR (TO_NUMBER (TO_CHAR (SYSDATE, 'YY')))
            || CHR (TO_NUMBER (TO_CHAR (SYSDATE, 'MM')))
            || CHR (TO_NUMBER (TO_CHAR (SYSDATE, 'DD')));
        --№4,5,6,7 Количество записей в таблице/ 32 бита = 4 байта
        l_header :=
            l_header || RPAD (to_ascii (l_number_of_records), 4, CHR (0));
        --№8,9 Количество байтов, занимаемых заголовком
        --/16 бит = 2 байта = 32 + 32*n + 1, где n - количество столбцов
        -- а 1 - ограничительный байт
        l_header :=
               l_header
            || RPAD (to_ascii (32 + l_number_of_columns * 32 + 1),
                     2,
                     CHR (0));
        --№10,11 Количество байтов, занимаемых записью/16 бит = 2 байта
        l_header := l_header || RPAD (to_ascii (l_line_length), 2, CHR (0));
        --№12,13 Зарезервировано
        l_header := l_header || RPAD (CHR (0), 2, CHR (0));
        --№14 Транзакция, 1-начало, 0-конец(завершена)
        l_header := l_header || CHR (0);
        --№15 Кодировка: 1-закодировано, 0-нормальная видимость
        l_header := l_header || CHR (0);
        --№16-27 Использование многопользовательского окружения
        l_header := l_header || RPAD (CHR (0), 12, CHR (0));
        --№28 Использование индекса 0-не использовать
        l_header := l_header || CHR (0);

        --№29 Номер драйвера языка
        IF p_convert = 0
        THEN
            l_header := l_header || CHR (38);                          --cp866
        ELSE
            l_header := l_header || CHR (3);                          --cp1251
        END IF;

        --№30,31 Зарезервировано
        l_header := l_header || RPAD (CHR (0), 2, CHR (0));

        --ОПИСАНИЯ ПОЛЕЙ В ЗАГОЛОВКЕ
        FOR i IN c_columns
        LOOP
            --№0-10 Имя поля с 0-завершением/11 байт
            l_header :=
                l_header || RPAD (SUBSTR (i.column_name, 1, 10), 11, CHR (0));
            --№11 Тип поля/1 байт
            l_header := l_header || i.data_type;
            --№12,13,14,15 Игнорируется/4 байта
            l_header := l_header || RPAD (CHR (0), 4, CHR (0));
            --№16 Размер поля/1 байт
            l_header := l_header || CHR (i.data_length);
            --№17 Количество знаков после запятой/1 байт
            l_header := l_header || CHR (i.data_scale);
            --№18,19 Зарезервированная область/2 байта
            l_header := l_header || RPAD (CHR (0), 2, CHR (0));
            --№20 Идентификатор рабочей области/1 байт
            l_header := l_header || CHR (0);
            --№21,22 Многопользовательский dBase/2 байта
            l_header := l_header || RPAD (CHR (0), 2, CHR (0));
            --№23 Установленные поля/1 байт
            l_header := l_header || CHR (0);                         --chr(1);
            --№24 Зарезервировано/7 байт
            l_header := l_header || RPAD (CHR (0), 7, CHR (0));
            --№31 Флаг MDX-поля: 01H если поле имеет метку индекса в MDX-файле, 00H - нет.
            l_header := l_header || CHR (0);
        END LOOP;

        --Завершающий заголовок символ 0D
        l_header := l_header || CHR (13);
        RETURN l_header;
    END make_d4_header;

    FUNCTION make_d4_all (p_tblname        VARCHAR2,
                          p_where          VARCHAR2 := NULL,
                          p_order          VARCHAR2 := NULL,
                          p_row_cnt    OUT NUMBER,
                          p_convert        INTEGER := 0,
                          --+Slaviq 29122008 Перечень полей которые не учавствуют в выгрузке
                          p_ColNotIn       VARCHAR2 := NULL)
        RETURN BLOB
    ---Slaviq
    IS
        --l_columns   varchar2(32767);
        l_blob             BLOB;
        l_header           VARCHAR2 (32767);
        all_columns        SYS_REFCURSOR;
        v_select           VARCHAR2 (32767);
        l_lines            VARCHAR2 (32767);

        TYPE all_columns_pk IS TABLE OF VARCHAR2 (4000)
            INDEX BY BINARY_INTEGER;

        l_all_columns_pk   all_columns_pk;
    BEGIN
        --Формируем заголовок и записываем его
        l_header :=
            make_d4_header (p_tblname    => p_tblname,
                            p_where      => p_where,
                            p_row_cnt    => p_row_cnt,
                            p_convert    => p_convert,
                            --+Slaviq 04032009 Перечень полей которые не учавствуют в выгрузке
                            p_ColNotIn   => p_ColNotIn);
        ---Slaviq
        DBMS_LOB.createtemporary (l_blob, TRUE);

        FOR i IN 1 .. TRUNC (LENGTH (l_header) / 2000) + 1
        LOOP
            DBMS_LOB.append (
                l_blob,
                UTL_RAW.cast_to_raw (SUBSTR (l_header, 1, 2000)));
            l_header := SUBSTR (l_header, 2001);
        END LOOP;

        --формируем данные
        v_select :=
            make_d4_column_script (p_tblname    => p_tblname,
                                   p_where      => p_where,
                                   p_order      => p_order,
                                   p_convert    => p_convert,
                                   --+Slaviq 04032009 Перечень полей которые не учавствуют в выгрузке
                                   p_ColNotIn   => p_ColNotIn);

        ---Slaviq
        /*  open all_columns for v_select;
          fetch all_columns
            into l_columns;
          while all_columns%found loop
            -- Символ CHR (32) обозначает, что записи не удалены
            l_lines := chr(32) || l_columns;
            dbms_lob.append(l_blob, utl_raw.cast_to_raw(l_lines));
            fetch all_columns
              into l_columns;
          end loop;*/
        --Складываем "упаковками" :)
        OPEN all_columns FOR v_select;

        LOOP
            FETCH all_columns BULK COLLECT INTO l_all_columns_pk LIMIT 1000;

            EXIT WHEN l_all_columns_pk.COUNT = 0;
            l_lines := '';

            --Вставляем записи
            FOR i IN l_all_columns_pk.FIRST .. l_all_columns_pk.LAST
            LOOP
                IF LENGTH (l_lines) + LENGTH (l_all_columns_pk (i)) > 32000
                THEN
                    DBMS_LOB.append (l_blob, UTL_RAW.cast_to_raw (l_lines));
                    l_lines := '';
                END IF;

                l_lines := l_lines || CHR (32) || l_all_columns_pk (i);
            END LOOP;

            DBMS_LOB.append (l_blob, UTL_RAW.cast_to_raw (l_lines));
            l_lines := '';
        END LOOP;

        --Символ-метка конца записи и дописіваем все что не попало в предідущем цікле
        DBMS_LOB.append (l_blob, UTL_RAW.cast_to_raw (CHR (26)));
        RETURN l_blob;
        DBMS_LOB.freetemporary (l_blob);
    END make_d4_all;

    FUNCTION make_d4_column_script (p_tblname    VARCHAR2,
                                    p_where      VARCHAR2:= NULL,
                                    p_order      VARCHAR2:= NULL,
                                    p_convert    INTEGER:= 0,
                                    --+Slaviq 04032009 Перечень полей которые не учавствуют в выгрузке
                                    p_ColNotIn   VARCHAR2:= NULL)    ---Slaviq
        RETURN VARCHAR2          --0 RU8PC866 -1 CL8MSWIN1251 -2 не конвертить
    IS
        l_result   VARCHAR2 (4000);
        l_column   VARCHAR2 (4000);

        CURSOR c_all_columns IS --Здесь надо привести свои форматы к формата dbf
              SELECT DECODE (c.data_type,
                             'VARCHAR2', 'C',
                             'DATE', 'D',
                             'NUMBER', 'N',
                             'C')              data_type,
                     --+Slaviq 04032009 Перечень полей которые не учавствуют в выгрузке
                     --decode(c.data_type, 'DATE', 8, 'NUMBER',nvl(c.data_precision + decode(nvl(c.data_scale,0),0,0,c.data_scale+1),20),c.data_length) data_length,
                     DECODE (c.data_type,
                             'DATE', 8,
                             'NUMBER', NVL (c.data_precision, 20),
                             c.data_length)    data_length,
                     ---Slaviq 04032009
                     c.column_name,
                     ROWNUM                    column_seq,
                     c.data_precision,
                     c.data_scale
                FROM all_tab_columns c
               WHERE     c.table_name = p_tblname
                     AND UPPER (c.column_name) <> 'KEYFLD'
                     --+Slaviq 04032009 Перечень полей которые не учавствуют в выгрузке
                     AND (   p_ColNotIn IS NULL
                          OR     p_ColNotIn IS NOT NULL
                             AND INSTR (p_ColNotIn,
                                        '''' || column_name || '''') =
                                 0)
            ---Slaviq
            --+Slaviq Сотировка по порядку
            ORDER BY column_id;
    ---Slaviq
    BEGIN
        FOR rec_all_columns IN c_all_columns
        LOOP
            --Для дат формат должен быть YYYYMMDD
            IF rec_all_columns.data_type = 'D'
            THEN
                l_column :=
                       'TO_CHAR'
                    || '('
                    || rec_all_columns.column_name
                    || ', ''YYYYMMDD'')';
            ELSIF rec_all_columns.data_type = 'N'
            THEN
                --Здесь нужно вставить свой формат чисел
                IF NVL (rec_all_columns.data_scale, 0) = 0
                THEN
                    l_column :=
                           'TRIM(TO_CHAR('
                        || rec_all_columns.column_name
                        || ',''999999999999999999''))';
                ELSE
                    l_column :=
                           'TRIM(TO_CHAR('
                        || rec_all_columns.column_name
                        || ',''9999999999999990.'
                        || TRIM (
                               LPAD (' ',
                                     rec_all_columns.data_scale + 1,
                                     '9'))
                        || '''))';
                END IF;
            ELSE
                l_column := rec_all_columns.column_name;
            END IF;

            --Если вдруг после преобразований получилось,
            --что длина поля больше указанной,
            --обрезаем поле
            l_column :=
                   'nvl(substr('
                || l_column
                || ',1,'
                || rec_all_columns.data_length
                || '),'' '')';

            --Далее для формата dbf необходимо "дописать" значение
            --в колонке до максимальной длины колонки
            IF rec_all_columns.data_type = 'N'
            THEN
                l_column :=
                       'lpad('
                    || l_column
                    || ','
                    || rec_all_columns.data_length
                    || ')';
            ELSE
                l_column :=
                       'rpad('
                    || l_column
                    || ','
                    || rec_all_columns.data_length
                    || ')';
            END IF;

            IF l_result IS NOT NULL
            THEN
                l_result := l_result || ' || ';
            END IF;

            l_result := l_result || l_column;
        END LOOP;

        --Здесь нужно вставить свою кодировку CL8MSWIN1251 или CL8ISO8859P5, например
        l_result :=
               'SELECT '
            || CASE WHEN p_convert IN (0, 1) THEN 'CONVERT(' END
            || l_result
            || CASE
                   WHEN p_convert = 0
                   THEN
                       ',''RU8PC866'') FROM ' || p_tblname
                   WHEN p_convert = 1
                   THEN
                       ',''CL8MSWIN1251'') FROM ' || p_tblname
                   ELSE
                       ' FROM ' || p_tblname
               END
            || ' where 1=1 '
            || CASE WHEN p_where IS NOT NULL THEN 'and ' || p_where END
            || CASE WHEN p_order IS NOT NULL THEN ' order by ' || p_order END;
        RETURN l_result;
    END make_d4_column_script;


    --ivashchuk 2060506 додавання нової підсистеми W_FILE$SUBSYS
    PROCEDURE Add_Subsys (p_wfs_code   W_FILE$SUBSYS.WFS_CODE%TYPE,
                          p_wfs_name   VARCHAR2 DEFAULT '',
                          p_wfs_desc   VARCHAR2 DEFAULT '')
    IS
        l_cnt   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_cnt
          FROM W_FILE$SUBSYS
         WHERE wfs_code = p_wfs_code;

        IF     LENGTH (p_wfs_code) = 5
           AND REGEXP_LIKE (p_wfs_code, '^[0-9A-Za-z]{5}$')
           AND l_cnt = 0
        THEN
            INSERT INTO W_FILE$SUBSYS (wfs_id,
                                       wfs_code,
                                       wfs_name,
                                       wfs_desc)
                 VALUES (0,
                         p_wfs_code,
                         p_wfs_name,
                         p_wfs_desc);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_WEB_FILE.add_subsys:',
                       SQLERRM
                    || CHR (10)
                    || DBMS_UTILITY.format_error_stack
                    || DBMS_UTILITY.format_error_backtrace));
    END;

    -- конвертація  base10 в base35
    FUNCTION decimal2base35 (p_number IN INTEGER)
        RETURN VARCHAR2
    IS
        charList   VARCHAR2 (35) := '123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        v_number   INTEGER := p_number;
        v_base     INTEGER := 35;
        v_Return   VARCHAR2 (100) := NULL;
        n_Cnt      INTEGER := 0;
        n_Val      INTEGER := 0;
    BEGIN
        IF (v_number = 0)
        THEN
            RETURN '1';
        END IF;

        v_Return := '';
        n_Cnt := 0;

        WHILE (v_number <> 0)
        LOOP
            n_Val :=
                MOD (v_number, (v_base ** (n_Cnt + 1))) / (v_base ** n_cnt);
            v_number := v_number - (n_Val * (v_base ** n_Cnt));
            v_Return := SUBSTR (charList, n_Val + 1, 1) || v_Return;
            n_Cnt := n_Cnt + 1;
        END LOOP;

        RETURN v_Return;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    /*
    -- генерація ідентифікатора файла
    FUNCTION gen_file_idn(p_wfs_code W_FILE$INFO.WF_WFS_CODE%TYPE,
                          p_file_idn W_FILE$INFO.WF_FILE_IDN%TYPE DEFAULT '') RETURN VARCHAR2
    IS
     l_curval NUMBER;
     l_file_idn VARCHAR2(15);
    BEGIN
      BEGIN
        IF nvl(p_file_idn,'')<>'' THEN
          RETURN p_file_idn;
        ELSE
          SELECT IKIS_SYSWEB.SQ_ID_WF_FILE_IDN.NEXTVAL INTO l_curval FROM dual;
        END IF;
      EXCEPTION WHEN OTHERS THEN
        SELECT IKIS_SYSWEB.SQ_ID_WF_FILE_IDN.NEXTVAL INTO l_curval FROM dual;
      END;
      l_file_idn := upper(p_wfs_code||'-'||lpad(decimal2base35(l_curval),9,'0'));
      RETURN l_file_idn;
    END;

    PROCEDURE SetFileToRecover(p_wf_id w_file$info.wf_id%TYPE)
    IS
      PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
      UPDATE w_file$info
        SET wf_st = 'V',
            wf_recovery_dt = NULL
        WHERE wf_is_archived = 'Y'
          AND wf_st = 'A'
          AND NOT EXISTS (SELECT 1
                          FROM w_file$download
                          WHERE wfd_wf = wf_id);
    END;

    --функция возвращает существует ли файл в архиве
    --возможность его оперативного использования
    --и по умолчанию ставит его на востановление
    function isFileExists(p_file_idn W_FILE$INFO.WF_FILE_IDN%type, p_get in boolean := true) return boolean
    is
      l_wf_id w_file$info.wf_id%type;
      l_cnt pls_integer :=0;
    begin
      select wf.wf_id
        into l_wf_id
      from w_file$info wf
      where wf.wf_file_idn = p_file_idn;

      select count(*)
        into l_cnt
      from w_file$download
      where wfd_wf = l_wf_id;

      if p_get and l_cnt = 0 then
        SetFileToRecover(l_wf_id);
      end if;

      return (l_cnt > 0);
    end;

    -- отримання файла по ідентифікатору
    FUNCTION getFile(p_file_idn W_FILE$INFO.WF_FILE_IDN%TYPE) RETURN BLOB
    IS
     l_file_id v_w_file$info.wf_id%TYPE;
     l_file_data BLOB;
     l_wf_st w_file$info.wf_st%TYPE;
    BEGIN
      IF length(p_file_idn) = 15 AND regexp_like(substr(p_file_idn,1,5), '^[0-9A-Za-z]{5}$')
          AND regexp_like(substr(p_file_idn,7,9), '^[0-9A-Za-z]{9}$')
          AND substr(p_file_idn,6,1) = '-'  THEN

        SELECT wf_id, wf_st
        INTO l_file_id, l_wf_st
        FROM ikis_sysweb.v_w_file$info
        WHERE wf_file_idn = p_file_idn;

        IF l_file_id IS NOT NULL THEN
          BEGIN
            SELECT wfd_file_body
            INTO l_file_data
            FROM ikis_sysweb.v_w_file$download
            WHERE wfd_wf = l_file_id;
          EXCEPTION
            WHEN no_data_found THEN
              --Якщо дані файлу не знайшлись та стан файлу "переміщено в архів" пробуємо його звідти дочекатись.
              IF l_wf_st = 'A' THEN
                SetFileToRecover(l_file_id);
                IKIS_SYS.IKIS_LOCK.Sleep(p_sec => 1);

                BEGIN
                  SELECT wfd_file_body
                  INTO l_file_data
                  FROM ikis_sysweb.v_w_file$download
                  WHERE wfd_wf = l_file_id;
                EXCEPTION
                  WHEN no_data_found THEN
                    raise_application_error(-20000, 'За 1 сек файл не відновлено, спробуйте ще через декілька секунд!');
                END;
              ELSE
                raise_application_error(-20000, 'Помилка пошуку файлу, необхідно звернутись до адміністратора БД!');
              END IF;
          END;
        END IF;
      END IF;
      RETURN l_file_data;
      EXCEPTION WHEN OTHERS THEN
          raise_application_error(-20000, ikis_message_util.get_message(msgCOMMON_EXCEPTION,'IKIS_WEB_FILE.getFile:',sqlerrm
          || chr(10) || dbms_utility.format_error_stack ||
            dbms_utility.format_error_backtrace));
    END;

    -- отримання інфо файла по ідентифікатору
    PROCEDURE getFileInfo(p_file_idn IN W_FILE$INFO.WF_FILE_IDN%TYPE,
                          p_wfs_code OUT v_w_file$info.wf_wfs_code%TYPE,
                          p_filename OUT v_w_file$info.WF_FILENAME%TYPE,
                          p_org OUT v_w_file$info.com_org%TYPE,
                          p_wu OUT v_w_file$info.WF_WU%TYPE,
                          p_file_upload_dt OUT W_FILE$INFO.WF_UPLOAD_DT%TYPE)
    IS
     l_file_id v_w_file$info.wf_id%TYPE;
     l_file_data BLOB;
    BEGIN
      IF nvl(p_file_idn,'')='' THEN
         raise_application_error(-20000,'File not found: '||p_file_idn);
      ELSE
        SELECT wf_wfs_code, wf_filename, com_org, wf_wu, wf_upload_dt
        INTO p_wfs_code,  p_filename,  p_org,   p_wu,  p_file_upload_dt
        FROM ikis_sysweb.v_w_file$info
        WHERE wf_file_idn = p_file_idn;
      END IF;
      EXCEPTION WHEN OTHERS THEN
          raise_application_error(-20000, ikis_message_util.get_message(msgCOMMON_EXCEPTION,'IKIS_WEB_FILE.putFile:',sqlerrm
          || chr(10) || dbms_utility.format_error_stack ||
            dbms_utility.format_error_backtrace));
    END;

    -- запис файла
    FUNCTION putFile(p_wfs_code IN v_w_file$info.wf_wfs_code%TYPE,
                     p_filename IN v_w_file$info.WF_FILENAME%TYPE,
                     p_org IN v_w_file$info.com_org%type DEFAULT NULL,
                     p_wu IN v_w_file$info.WF_WU%type DEFAULT NULL,
                     p_file_data IN BLOB) RETURN v_w_file$info.wf_file_idn%TYPE
    IS
      l_filename VARCHAR2(4000);
      l_cnt NUMBER := 0;
      l_file_id v_w_file$info.wf_id%TYPE;
      l_org v_w_file$info.com_org%TYPE;
      l_file_idn v_w_file$info.wf_file_idn%TYPE;
    begin
      l_filename := TRIM(upper(substr(REPLACE(p_filename,'\','/'),instr(p_filename,'/')+1,10000)));
      --SELECT COUNT(1) INTO l_cnt FROM w_file$info WHERE wf_filename = l_filename;

      IF l_cnt > 0 THEN
        raise_application_error(-20000, 'File already uploaded: '||l_filename);
      ELSIF p_wfs_code IS NULL OR length(p_wfs_code) != 5 OR NOT regexp_like(p_wfs_code, '^[0-9A-Za-z]{5}$' ) THEN
        raise_application_error(-20000, 'Subsystem code is not correct: '||p_wfs_code);
      ELSE
        l_file_idn := gen_file_idn(p_wfs_code => p_wfs_code);

        INSERT INTO ikis_sysweb.v_w_file$info
          (wf_id, wf_filename, wf_st, wf_upload_dt,
           com_org, wf_wu,
           wf_wfs_code, wf_file_idn, wf_is_archived)
        VALUES
          (0, p_filename, 'L', SYSDATE,
           p_org,  p_wu,
           p_wfs_code, l_file_idn, 'N')
        RETURNING wf_id INTO l_file_id;

        INSERT INTO ikis_sysweb.v_w_file$download (wfd_id, wfd_wf, wfd_file_body)
          VALUES(0, l_file_id, p_file_data);

        RETURN l_file_idn;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
          raise_application_error(-20000, ikis_message_util.get_message(msgCOMMON_EXCEPTION,'IKIS_WEB_FILE.putFile:',sqlerrm
          || chr(10) || dbms_utility.format_error_stack ||
            dbms_utility.format_error_backtrace));
    END;
    */

    -- Routine to parse the DBASE header record, can get
    -- all of the details of the contents of a dbase file from
    -- this header

    PROCEDURE get_header_2 (p_blob          IN     BLOB,
                            p_blob_offset   IN OUT NUMBER,
                            p_hdr           IN OUT dbf_header,
                            p_flds          IN OUT field_descriptor_array)
    IS
        l_data              VARCHAR2 (100);
        l_hdr_size          NUMBER DEFAULT 32;
        l_field_desc_size   NUMBER DEFAULT 32;
        l_flds              field_descriptor_array;
    BEGIN
        p_flds := l_flds;

        l_data :=
            UTL_RAW.cast_to_varchar2 (
                DBMS_LOB.SUBSTR (p_blob, l_hdr_size, p_blob_offset));
        p_blob_offset := p_blob_offset + l_hdr_size;

        p_hdr.version := ASCII (SUBSTR (l_data, 1, 1));
        p_hdr.year := 1900 + ASCII (SUBSTR (l_data, 2, 1));
        p_hdr.month := ASCII (SUBSTR (l_data, 3, 1));
        p_hdr.day := ASCII (SUBSTR (l_data, 4, 1));
        p_hdr.no_records := to_int (SUBSTR (l_data, 5, 4));
        p_hdr.hdr_len := to_int (SUBSTR (l_data, 9, 2));
        p_hdr.rec_len := to_int (SUBSTR (l_data, 11, 2));
        p_hdr.no_fields :=
            TRUNC ((p_hdr.hdr_len - l_hdr_size) / l_field_desc_size);

        FOR i IN 1 .. p_hdr.no_fields
        LOOP
            l_data :=
                UTL_RAW.cast_to_varchar2 (
                    DBMS_LOB.SUBSTR (p_blob,
                                     l_field_desc_size,
                                     p_blob_offset));
            p_blob_offset := p_blob_offset + l_field_desc_size;
            p_flds (i).name := mytrim (SUBSTR (l_data, 1, 11));
            p_flds (i).TYPE := SUBSTR (l_data, 12, 1);
            p_flds (i).LENGTH := ASCII (SUBSTR (l_data, 17, 1));
            p_flds (i).decimals := ASCII (SUBSTR (l_data, 18, 1));
        END LOOP;

        p_blob_offset :=
              p_blob_offset
            + MOD (p_hdr.hdr_len - l_hdr_size, l_field_desc_size);
    --dbms_output.put_line('get_header passed.');
    END;

    FUNCTION build_insert (p_tname        IN VARCHAR2,
                           p_cnames       IN VARCHAR2,
                           p_Def_fields   IN IKIS_WEB_FILE.r_Def_fields,
                           p_flds         IN field_descriptor_array)
        RETURN VARCHAR2
    IS
        l_insert_statement   LONG;
    BEGIN
        l_insert_statement := 'insert into ' || p_tname || '(';

        IF (p_cnames IS NOT NULL)
        THEN
            l_insert_statement :=
                   l_insert_statement
                || p_cnames
                || CASE
                       WHEN p_Def_fields.Fields IS NOT NULL
                       THEN
                           ',' || p_Def_fields.Fields
                   END
                || ') values (';
        ELSE
            FOR i IN 1 .. p_flds.COUNT
            LOOP
                IF (i <> 1)
                THEN
                    l_insert_statement := l_insert_statement || ',';
                END IF;

                l_insert_statement :=
                    l_insert_statement || '"' || p_flds (i).name || '"';
            END LOOP;

            --l_insert_statement := l_insert_statement ||',"UPLOAD_TIME"';    -- Dede+, Jkt, 20091109_1
            l_insert_statement := l_insert_statement || ') values (';
        END IF;

        FOR i IN 1 .. p_flds.COUNT
        LOOP
            IF (i <> 1)
            THEN
                l_insert_statement := l_insert_statement || ',';
            END IF;

            IF (p_flds (i).TYPE = 'D')
            THEN
                l_insert_statement :=
                       l_insert_statement
                    || 'to_date(:bv'
                    || i
                    || ',''yyyymmdd'' )';
            ELSE
                l_insert_statement := l_insert_statement || ':bv' || i;
            END IF;
        END LOOP;

        -- Dede+, Jkt, 20091109_1, START "UPLOAD_TIME"
        --l_insert_statement := l_insert_statement ||',to_date(:bv' || (p_flds.count+1) || ',''yyyymmdd'' )';
        -- Dede+, Jkt, 20091109_1, END
        l_insert_statement :=
               l_insert_statement
            || CASE
                   WHEN p_Def_fields.Fields IS NOT NULL
                   THEN
                       ',' || p_Def_fields.Fields_value
               END
            || ')';

        RETURN l_insert_statement;
    END;

    FUNCTION get_row_2 (p_blob          IN     BLOB,
                        p_blob_offset   IN OUT NUMBER,
                        p_hdr           IN     dbf_header,
                        p_flds          IN     field_descriptor_array /*,
                              f_bfile        in bfile,
                              -- memo_block in number ) return rowArray     -- Dede-, Jkt, 20090828
                              memo_block in number */
                                                                     )
        RETURN rowArrayCLOB                            -- Dede+, Jkt, 20090828
    IS
        --l_data  varchar2(4000);   -- Dede-, Jkt, 20090828
        l_data   CLOB;                                 -- Dede+, Jkt, 20090828
        l_row    rowArrayCLOB;                         -- Dede+, Jkt, 20090828
        l_n      NUMBER DEFAULT 2;
    --f_block number;
    BEGIN
        l_data :=
            UTL_RAW.cast_to_varchar2 (
                DBMS_LOB.SUBSTR (p_blob, p_hdr.rec_len, p_blob_offset));
        l_data := CONVERT (l_data, 'CL8MSWIN1251', 'RU8PC866');

        p_blob_offset := p_blob_offset + p_hdr.rec_len;

        l_row (0) := SUBSTR (l_data, 1, 1);

        FOR i IN 1 .. p_hdr.no_fields
        LOOP
            l_row (i) :=
                RTRIM (LTRIM (SUBSTR (l_data, l_n, p_flds (i).LENGTH)));

            IF (p_flds (i).TYPE = 'F' AND l_row (i) = '.')
            THEN
                l_row (i) := NULL;
            -------------------working with Memo fields
            /*elsif ( p_flds(i).type = 'M' ) then
               --Check is file exists
               if( dbms_lob.isopen( f_bfile ) != 0) then
                  --f_block - memo block length
                  f_block  := Hex2Dec(dbms_lob.substr( f_bfile, 4, to_number(l_row(i))*memo_block+5 ));
                  --to_number(l_row(i))*memo_block+9 - offset in memo file *.fpt, where l_row(i) - number of
                  --memo block in fpt file
                  l_row(i) := utl_raw.cast_to_varchar2(dbms_lob.substr( f_bfile, f_block, to_number(l_row(i))*memo_block+9));
                  --l_row(i) := substr(utl_raw.cast_to_varchar2(dbms_lob.substr( f_bfile, f_block, to_number(l_row(i))*memo_block+9)),1,4000);
               else
                  l_row(i) := NULL;
                  \*
                  dbms_output.put_line('Not found .fpt file');
                  exit;
                  *\
               end if;*/
            -------------------------------------------
            END IF;

            l_n := l_n + p_flds (i).LENGTH;
        END LOOP;

        RETURN l_row;
    END get_row_2;

    PROCEDURE Load_Table_DBF (p_blob         IN BLOB,
                              p_tname        IN VARCHAR2,
                              p_cnames       IN VARCHAR2 DEFAULT NULL,
                              p_Def_fields   IN r_Def_fields DEFAULT NULL,
                              p_show         IN BOOLEAN DEFAULT FALSE)
    IS
        l_offset   NUMBER DEFAULT 1;
        l_hdr      dbf_header;
        l_flds     field_descriptor_array;
        l_row      rowArrayCLOB;                       -- Dede+, Jkt, 20090828
        n_dummy    NUMBER;
    BEGIN
        get_header_2 (p_blob,
                      l_offset,
                      l_hdr,
                      l_flds);

        IF p_show
        THEN
            DBMS_OUTPUT.put_line (build_insert (p_tname,
                                                p_cnames,
                                                p_Def_fields,
                                                l_flds));
        END IF;

        --dbms_output.put_line('before parse(): '||p_tname||'/'||p_cnames);   -- Dede+
        DBMS_SQL.parse (g_cursor,
                        build_insert (p_tname,
                                      p_cnames,
                                      p_Def_fields,
                                      l_flds),
                        DBMS_SQL.native);

        --dbms_output.put_line('after parse()');
        /*--      Memo block size in ftp file
            if ( dbms_lob.isopen( f_bfile ) > 0 ) then
                memo_block := Hex2Dec(dbms_lob.substr(f_bfile, 2, 7));
            else
                memo_block := 0;
            end if;*/

        FOR i IN 1 .. l_hdr.no_records
        LOOP
            --dbms_output.put('fetch row#: '||i);
            l_row :=
                get_row_2 (p_blob,
                           l_offset,
                           l_hdr,
                           l_flds                    /*, f_bfile, memo_block*/
                                 );

            --dbms_output.put_line('..done');
            IF (l_row (0) <> '*')                            -- deleted record
            THEN
                FOR i IN 1 .. l_hdr.no_fields
                LOOP
                    n_dummy := i;

                    -- Dede+, Jkt, 20090828, START
                    IF (LENGTH (l_row (i)) <= 4000)
                    THEN
                        DBMS_SQL.bind_variable (g_cursor,
                                                ':bv' || i,
                                                l_row (i),
                                                4000);
                    ELSE
                        DBMS_SQL.bind_variable (g_cursor,
                                                ':bv' || i,
                                                l_row (i));
                    END IF;
                -- Dede+, Jkt, 20090828, END

                END LOOP;

                --dbms_sql.bind_variable( g_cursor, ':bv'||(l_hdr.no_fields+1), g_process_time ); -- Dede+, Jkt, 20091109_1 "UPLOAD_TIME"

                IF (DBMS_SQL.execute (g_cursor) <> 1)
                THEN
                    raise_application_error (-20001,
                                             'Insert failed ' || SQLERRM);
                END IF;
            END IF;
        END LOOP;
    /*exception
        when others then
            dbms_output.put_line('something error!!!');
            dbms_output.put_line(l_row(1)||' '||l_row(2));
            dbms_output.put_line(l_row(32));
            dbms_output.put_line(l_row(n_dummy));
            \*if ( dbms_lob.isopen( l_bfile ) > 0 ) then
                dbms_lob.fileclose( l_bfile );
            end if;
            if ( dbms_lob.isopen( f_bfile ) > 0 ) then
                dbms_lob.fileclose( f_bfile );
            end if;*\
            RAISE;*/
    END;

    -- +CSV
    PROCEDURE flash_buffer
    IS
    BEGIN
        IF LENGTH (g_buff) > 0
        THEN
            DBMS_LOB.writeappend (
                lob_loc   => g_result_data,
                amount    => DBMS_LOB.getlength (UTL_RAW.cast_to_raw (g_buff)),
                buffer    => UTL_RAW.cast_to_raw (g_buff));
            g_buff := '';
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (-20000,
                                     'b_put_line: ' || CHR (10) || SQLERRM);
    END;

    PROCEDURE b_put (p_str VARCHAR2)
    IS
    BEGIN
        IF LENGTH (g_buff) + LENGTH (p_str) < 32760
        THEN
            g_buff := g_buff || p_str;
        ELSE
            flash_buffer;
            g_buff := p_str;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (-20000,
                                     'b_put_line: ' || CHR (10) || SQLERRM);
    END;

    PROCEDURE b_put_line (p_str VARCHAR2)
    IS
        l_buff   VARCHAR2 (32760);
    BEGIN
        l_buff := p_str || CHR (13) || CHR (10);

        IF LENGTH (g_buff) + LENGTH (l_buff) < 32760
        THEN
            g_buff := g_buff || l_buff;
        ELSE
            flash_buffer;
            g_buff := l_buff;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (-20000,
                                     'b_put_line: ' || CHR (10) || SQLERRM);
    END;

    FUNCTION PublishFile
        RETURN BLOB
    IS
    BEGIN
        flash_buffer;
        RETURN g_result_data;
    END;

    PROCEDURE init_builder
    IS
    BEGIN
        DBMS_LOB.CreateTemporary (lob_loc => g_result_data, cache => TRUE);
        DBMS_LOB.Open (lob_loc     => g_result_data,
                       open_mode   => DBMS_LOB.lob_readwrite);
        g_buff := '';
        g_is_inited := TRUE;
    END;


    FUNCTION make_csv_header (p_tblname           VARCHAR2,
                              p_column_list       VARCHAR2,
                              p_where             VARCHAR2,
                              p_convert           INTEGER := 0,
                              p_row_cnt       OUT NUMBER)
        RETURN VARCHAR2
    IS
        l_header              VARCHAR2 (32767);
        l_number_of_columns   BINARY_INTEGER;
        l_line_length         BINARY_INTEGER;
        l_number_of_records   NUMBER;

        CURSOR c_columns IS
              SELECT c.column_name             AS q_ora_name,
                     DECODE (c.data_type,
                             'VARCHAR2', 'C',
                             'DATE', 'D',
                             'NUMBER', 'N',
                             'C')              data_type,
                     DECODE (c.data_type,
                             'DATE', 8,
                             'NUMBER', NVL (c.data_precision, 20),
                             c.data_length)    data_length,
                     NVL (c.data_scale, 0)     data_scale,
                     csv_name                  AS q_csv_name
                FROM all_tab_columns c, TABLE (GetColumnsList (p_column_list))
               WHERE     c.table_name = p_tblname
                     AND UPPER (c.column_name) <> 'KEYFLD'
                     AND c.column_name = ora_name
            ORDER BY col_order, column_id;
    BEGIN
          SELECT COUNT (*),
                   SUM (
                       DECODE (c.data_type,
                               'DATE', 8,
                               'NUMBER', NVL (c.data_precision, 20),
                               c.data_length))
                 + 1
            INTO l_number_of_columns, l_line_length
            FROM all_tab_columns c, TABLE (GetColumnsList (p_column_list))
           WHERE     c.table_name = p_tblname
                 AND UPPER (c.column_name) <> 'KEYFLD'
                 AND c.column_name = ora_name
        ORDER BY col_order, column_id;

        DBMS_OUTPUT.put_line (
               'select count(*) cnt from '
            || p_tblname
            || ' where 1=1 '
            || CASE WHEN p_where IS NOT NULL THEN 'and ' || p_where END);

        EXECUTE IMMEDIATE   'select count(*) cnt from '
                         || p_tblname
                         || ' where 1=1 '
                         || CASE
                                WHEN p_where IS NOT NULL
                                THEN
                                    'and ' || p_where
                            END
            INTO l_number_of_records;

        p_row_cnt := l_number_of_records;
        DBMS_OUTPUT.put_line (l_number_of_records);

        --ЗАГОЛОВОК
        --Імена стовпчиків через ;
        l_header := '';

        --Поля в заголовку
        FOR i IN c_columns
        LOOP
            l_header := l_header || TRIM (i.q_csv_name) || ';';
        END LOOP;

        RETURN RTRIM (l_header, ';');
    END make_csv_header;

    FUNCTION GetColumnsList (p_column_list VARCHAR2)
        RETURN t_tab_columns
        PIPELINED
    IS
        l_tmp   t_column;
    BEGIN
        FOR cols
            IN (SELECT CASE
                           WHEN INSTR (i_col_name, '=') > 0
                           THEN
                               SUBSTR (i_col_name,
                                       1,
                                       INSTR (i_col_name, '=') - 1)
                           ELSE
                               i_col_name
                       END    AS i_ora_name,
                       CASE
                           WHEN INSTR (i_col_name, '=') > 0
                           THEN
                               SUBSTR (i_col_name,
                                       INSTR (i_col_name, '=') + 1)
                           ELSE
                               i_col_name
                       END    AS i_csv_name,
                       i_col_order
                  FROM (    SELECT UPPER (TRIM (REGEXP_SUBSTR (p_column_list,
                                                               '[^,]+',
                                                               1,
                                                               LEVEL)))
                                       AS i_col_name,
                                   LEVEL
                                       AS i_col_order
                              FROM DUAL
                        CONNECT BY REGEXP_SUBSTR (p_column_list,
                                                  '[^,]+',
                                                  1,
                                                  LEVEL)
                                       IS NOT NULL))
        LOOP
            l_tmp.ora_name := cols.i_ora_name;
            l_tmp.csv_name := cols.i_csv_name;
            l_tmp.col_order := cols.i_col_order;
            PIPE ROW (l_tmp);
        END LOOP;
    END;

    FUNCTION make_csv_column_script (p_tblname       VARCHAR2,
                                     p_column_list   VARCHAR2,
                                     p_where         VARCHAR2,
                                     p_order         VARCHAR2:= NULL,
                                     p_convert       INTEGER:= 0)
        RETURN VARCHAR2          --0 RU8PC866 -1 CL8MSWIN1251 -2 не конвертить
    IS
        l_result   VARCHAR2 (4000);
        l_column   VARCHAR2 (4000);

        CURSOR c_all_columns IS --Здесь надо привести свои форматы к формату CSV
              SELECT c.column_name             AS q_ora_name,
                     DECODE (c.data_type,
                             'VARCHAR2', 'C',
                             'DATE', 'D',
                             'NUMBER', 'N',
                             'C')              data_type,
                     DECODE (c.data_type,
                             'DATE', 8,
                             'NUMBER', NVL (c.data_precision, 20),
                             c.data_length)    data_length,
                     NVL (c.data_scale, 0)     data_scale,
                     csv_name                  AS q_csv_name
                FROM all_tab_columns c, TABLE (GetColumnsList (p_column_list))
               WHERE     c.table_name = p_tblname
                     AND UPPER (c.column_name) <> 'KEYFLD'
                     AND c.column_name = ora_name
            ORDER BY col_order, column_id;
    BEGIN
        FOR rec_all_columns IN c_all_columns
        LOOP
            --Для дат формат должен быть YYYYMMDD
            IF rec_all_columns.data_type = 'D'
            THEN
                l_column :=
                       'TO_CHAR'
                    || '('
                    || rec_all_columns.q_ora_name
                    || ', ''YYYYMMDD'')';
            ELSIF rec_all_columns.data_type = 'N'
            THEN
                --Здесь нужно вставить свой формат чисел
                IF NVL (rec_all_columns.data_scale, 0) = 0
                THEN
                    l_column :=
                           'TRIM(TO_CHAR('
                        || rec_all_columns.q_ora_name
                        || ',''999999999999999999''))';
                ELSE
                    l_column :=
                           'TRIM(TO_CHAR('
                        || rec_all_columns.q_ora_name
                        || ',''9999999999999990.'
                        || TRIM (
                               LPAD (' ',
                                     rec_all_columns.data_scale + 1,
                                     '9'))
                        || '''))';
                END IF;
            ELSE
                l_column :=
                       'REPLACE('
                    || rec_all_columns.q_ora_name
                    || ', '';'', ''|'')';
            END IF;

            --Если вдруг после преобразований получилось,
            --что длина поля больше указанной,
            --обрезаем поле
            l_column :=
                   'nvl(substr('
                || l_column
                || ',1,'
                || rec_all_columns.data_length
                || '),'''')';

            IF l_result IS NOT NULL
            THEN
                l_result := l_result || ' ||'';''|| ';
            END IF;

            l_result := l_result || l_column;
        END LOOP;

        --Здесь нужно вставить свою кодировку CL8MSWIN1251 или CL8ISO8859P5, например
        l_result :=
               'SELECT '
            || CASE WHEN p_convert IN (0, 1, 3) THEN 'CONVERT(' END
            || l_result
            || CASE
                   WHEN p_convert = 0
                   THEN
                       ',''RU8PC866'') FROM ' || p_tblname
                   WHEN p_convert = 1
                   THEN
                       ',''CL8MSWIN1251'') FROM ' || p_tblname
                   WHEN p_convert = 3
                   THEN
                       ',''CL8MSWIN1251'') FROM ' || p_tblname
                   ELSE
                       ' FROM ' || p_tblname
               END
            || ' where 1=1 '
            || CASE WHEN p_where IS NOT NULL THEN 'and ' || p_where END
            || CASE WHEN p_order IS NOT NULL THEN ' order by ' || p_order END;

        RETURN l_result;
    END make_csv_column_script;

    FUNCTION make_csv_all (p_tblname           VARCHAR2,
                           p_column_list       VARCHAR2,
                           p_where             VARCHAR2,
                           p_order             VARCHAR2 := NULL,
                           p_convert           INTEGER := 0,
                           p_row_cnt       OUT NUMBER)
        RETURN BLOB
    IS
        l_header        VARCHAR2 (32767);
        data_to_csv     SYS_REFCURSOR;
        v_select        VARCHAR2 (32767);

        TYPE all_columns_pk IS TABLE OF VARCHAR2 (4000)
            INDEX BY BINARY_INTEGER;

        l_data_row_pk   all_columns_pk;
    BEGIN
        init_builder;
        --Формируем заголовок и записываем его
        l_header :=
            make_csv_header (p_tblname       => p_tblname,
                             p_where         => p_where,
                             p_row_cnt       => p_row_cnt,
                             p_convert       => p_convert,
                             p_column_list   => p_column_list);

        b_put_line (l_header);

        --формируем данные
        v_select :=
            make_csv_column_script (p_tblname       => p_tblname,
                                    p_where         => p_where,
                                    p_order         => p_order,
                                    p_convert       => p_convert,
                                    p_column_list   => p_column_list);

        DBMS_OUTPUT.put_line (v_select);

        --Складываем "упаковками" :)
        OPEN data_to_csv FOR v_select;

        LOOP
            FETCH data_to_csv BULK COLLECT INTO l_data_row_pk LIMIT 1000;

            EXIT WHEN l_data_row_pk.COUNT = 0;

            FOR i IN l_data_row_pk.FIRST .. l_data_row_pk.LAST
            LOOP
                b_put_line (l_data_row_pk (i));
            END LOOP;
        END LOOP;

        RETURN PublishFile;
    END make_csv_all;
-- -CSV

BEGIN
    -- Initialization
    NULL;
END IKIS_WEB_FILE;
/