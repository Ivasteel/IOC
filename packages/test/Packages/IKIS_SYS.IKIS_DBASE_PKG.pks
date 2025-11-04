/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.ikis_dbase_pkg
AS
    --http://asktom.oracle.com/pls/ask/f?p=4950:8:::::F4950_P8_DISPLAYID:711825134415

    -- procedure to a load a table with records
    -- from a DBASE file.
    --

    --импорт данных по метаданными ДЕВС
    PROCEDURE ikis_import (p_type    IN ikis_import_types.iit_code%TYPE,
                           p_db_ch   IN NUMBER DEFAULT 1);

    PROCEDURE Initialize_Temp_BLOB (
        p_type   IN ikis_import_types.iit_code%TYPE);

    PROCEDURE UpdateTMPBlob (p_filename VARCHAR2, p_file_content BLOB);

    -- Lysyuk 20101111
    -- экспорт по метаданными ДЕВС
    PROCEDURE ikis_export (p_type      IN ikis_import_types.iit_code%TYPE,
                           p_convert   IN BOOLEAN DEFAULT FALSE);

    PROCEDURE GetTmpBlob (
        p_filename   IN            ikis_import_files.iif_file_name%TYPE,
        p_blob_loc      OUT NOCOPY BLOB);

    -- Lysyuk 20101111
    PROCEDURE ClearBufTables (p_type IN ikis_import_types.iit_code%TYPE);
END ikis_dbase_pkg;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_DBASE_PKG FOR IKIS_SYS.IKIS_DBASE_PKG
/


GRANT EXECUTE ON IKIS_SYS.IKIS_DBASE_PKG TO II01RC_IKIS_COMMON
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DBASE_PKG TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DBASE_PKG TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DBASE_PKG TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DBASE_PKG TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DBASE_PKG TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DBASE_PKG TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DBASE_PKG TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DBASE_PKG TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DBASE_PKG TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DBASE_PKG TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DBASE_PKG TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DBASE_PKG TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:10:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.ikis_dbase_pkg
AS
    -- Might have to change on your platform!!!
    -- Controls the byte order of binary integers read in
    -- from the dbase file
    BIG_ENDIAN   CONSTANT BOOLEAN DEFAULT TRUE;

    G_DB_CHARACTERSET     BOOLEAN := TRUE; -- ТРУ - ЗАРГУЗКА БЕЗ ПЕРЕКОДИРОВКИ, IF FALSE THEN DOS (ПЕРЕКОДИРОВКА ИЗ RU8PC866)
    oem_convert           BOOLEAN DEFAULT FALSE; -- перекодировка при выгрузке из WIN151 в CP866

    DB_CHARSET            VARCHAR2 (100);
    DOC_CHARSET           VARCHAR2 (100) := 'RU8PC866';

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

    -- 17-01-2013 IARIKOV_PM: Изменил тип field_descriptor.name varchar2(11) => varchar2(15)
    TYPE field_descriptor IS RECORD
    (
        name        VARCHAR2 (15),
        TYPE        CHAR (1),
        LENGTH      INT,                                      -- 1 byte length
        decimals    INT                                        -- 1 byte scale
    );

    TYPE field_descriptor_array IS TABLE OF field_descriptor
        INDEX BY BINARY_INTEGER;


    TYPE rowArray IS TABLE OF VARCHAR2 (4000)
        INDEX BY BINARY_INTEGER;


    g_cursor              BINARY_INTEGER DEFAULT DBMS_SQL.open_cursor;



    -- Function to convert a binary unsigned integer
    -- into a PLSQL number

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


    -- Routine to parse the DBASE header record, can get
    -- all of the details of the contents of a dbase file from
    -- this header

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

    FUNCTION GetDBNameFromDBFName (
        p_file_id   ikis_import_fields.iid_iif%TYPE,
        p_name      ikis_import_fields.iid_name_in_file%TYPE)
        RETURN ikis_import_fields.iid_name_in_db%TYPE
    IS
        l_res   ikis_import_fields.iid_name_in_db%TYPE;
    BEGIN
        SELECT iid_name_in_db
          INTO l_res
          FROM ikis_import_fields
         WHERE     iid_iif = p_file_id
               AND UPPER (iid_name_in_file) = UPPER (p_name);

        RETURN l_res;
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

    FUNCTION SearchField (
        p_name          ikis_import_fields.iid_name_in_file%TYPE,
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

    FUNCTION ikis_build_insert (
        p_tname      IN VARCHAR2,
        p_srcnames   IN DBMS_UTILITY.uncl_array,
        p_flds       IN field_descriptor_array,
        p_file          ikis_import_fields.iid_iif%TYPE)
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

    -- p_db_ch : false - перекодировка из ДОС, true - без перекодировки
    PROCEDURE ikis_load_Table (
        p_file       IN VARCHAR2,
        p_tname      IN VARCHAR2,
        p_srcnames      DBMS_UTILITY.uncl_array,
        p_db_ch      IN NUMBER DEFAULT 1,
        p_file_id       ikis_import_fields.iid_iif%TYPE)
    IS
        l_offset      NUMBER DEFAULT 1;
        l_hdr         dbf_header;
        l_flds        field_descriptor_array;
        l_row         rowArray;
        l_sql         VARCHAR2 (32760);
        l_tmp         VARCHAR2 (32760);
        l_tmp1        VARCHAR2 (32760);
        l_curr_row    NUMBER;

        l_blob        BLOB;
        l_sz          NUMBER;
        l_ex_nofile   EXCEPTION;
    BEGIN
        G_DB_CHARACTERSET := p_db_ch = 1;

        SELECT file_content
          INTO l_blob
          FROM tt$blob_dbf_load
         WHERE file_name = UPPER (p_file);

        DBMS_LOB.open (lob_loc => l_blob, open_mode => DBMS_LOB.lob_readonly);
        l_sz := DBMS_LOB.getlength (l_blob);

        IF l_sz = 0
        THEN
            --sbond 20200831
            IF (UPPER (p_file) LIKE 'LP_%') OR (UPPER (p_file) LIKE 'NP_%')
            THEN
                RAISE l_ex_nofile;
            ELSE
                raise_application_error (
                    -20000,
                       'Пустий файл, або неправильне ім`я файлу (перевірте у архіву), повинне бути: '
                    || UPPER (p_file));
            END IF;
        END IF;

        get_header (l_blob,
                    l_offset,
                    l_hdr,
                    l_flds);
        l_sql :=
            ikis_build_insert (p_tname,
                               p_srcnames,
                               l_flds,
                               p_file_id);

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
            --      exception
            --        when others then
            --          raise_application_error(-20000,'Process Row (NAME,TYPE,RAW): '||chr(10)||l_flds(i).name||chr(10)||l_flds(i).TYPE||chr(10)||l_row(i)||chr(10)||sqlerrm);
            END;
        END LOOP;

        DBMS_LOB.close (lob_loc => l_blob);
    EXCEPTION
        WHEN l_ex_nofile
        THEN
            IF (DBMS_LOB.ISOPEN (l_blob) > 0)
            THEN
                DBMS_LOB.close (l_blob);
            END IF;
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


    PROCEDURE ikis_import (p_type    IN ikis_import_types.iit_code%TYPE,
                           p_db_ch   IN NUMBER DEFAULT 1)
    IS
        l_src_flds   DBMS_UTILITY.uncl_array;
    --  L_ss       varchar2(100);
    BEGIN
        FOR i IN (SELECT *
                    FROM ikis_import_files x, ikis_import_types x1
                   WHERE x1.iit_code = p_type AND x1.iit_id = x.iif_iit)
        LOOP
              --    L_ss:=i.iit_subsys;
              SELECT y.iid_name_in_file
                BULK COLLECT INTO l_src_flds
                FROM ikis_import_fields y
               WHERE y.iid_iif = i.iif_id
            ORDER BY y.iid_num_in_file;

            ikis_load_Table (
                p_file       => UPPER (i.iif_file_name),
                p_tname      => i.iit_subsys || '.' || i.iif_buf_table,
                p_srcnames   => l_src_flds,
                p_file_id    => i.iif_id,
                p_db_ch      => p_db_ch);
        END LOOP;
    --  ikis_subsys_util.Get_SubSys_Attr(p_ss_code => L_ss,p_cc_attr => g_attr);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (-20000,
                                     'ikis_import: ' || CHR (10) || SQLERRM);
    END;

    PROCEDURE Initialize_Temp_BLOB (
        p_type   IN ikis_import_types.iit_code%TYPE)
    IS
    BEGIN
        INSERT INTO tt$blob_dbf_load (file_name, file_content)
            SELECT UPPER (x1.iif_file_name), EMPTY_BLOB ()
              FROM ikis_import_types x, ikis_import_files x1
             WHERE x.iit_code = p_type AND x.iit_id = x1.iif_iit;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'Initialize_Temp_BLOB: ' || CHR (10) || SQLERRM);
    END;


    --Slaviq 20071126
    PROCEDURE UpdateTMPBlob (p_filename VARCHAR2, p_file_content BLOB)
    IS
    BEGIN
        UPDATE tt$blob_dbf_load
           SET file_content = p_file_content
         WHERE file_name = p_filename;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    2,
                    'ikis_dbase_pkg.UpdateTMPBlob: ',
                    CHR (10) || SQLERRM));
    END;

    -- Lysyuk 20101111
    PROCEDURE put_header (p_table      IN     ikis_import_files.iif_id%TYPE,
                          p_hdr           OUT dbf_header,
                          p_fileflds      OUT field_descriptor_array,
                          p_dbflds        OUT field_descriptor_array)
    IS
        i        INTEGER := 0;
        l_pos1   INTEGER;
        l_pos2   INTEGER;
        l_pos3   INTEGER;
    BEGIN
        FOR cur IN (  SELECT iid_name_in_file, iid_name_in_db, iid_param_type
                        FROM ikis_sys.v_ikis_import_fields
                       WHERE iid_iif = p_table
                    ORDER BY iid_num_in_file)
        LOOP
            i := i + 1;
            p_fileflds (i).name := cur.iid_name_in_file;
            p_dbflds (i).name := cur.iid_name_in_db;

            IF INSTR (cur.iid_param_type, 'NUMBER') > 0
            THEN
                l_pos1 := INSTR (cur.iid_param_type, '(');
                l_pos2 := INSTR (cur.iid_param_type, ')');
                l_pos3 := INSTR (cur.iid_param_type, ',');

                IF (l_pos1 > 0) AND NOT (l_pos3 > 0) AND (l_pos2 > 0)
                THEN
                    p_fileflds (i).LENGTH :=
                        TO_NUMBER (
                            SUBSTR (cur.iid_param_type,
                                    l_pos1 + 1,
                                    l_pos2 - l_pos1 - 1));
                    p_fileflds (i).decimals := 0;
                ELSIF (l_pos1 > 0) AND (l_pos3 > 0) AND (l_pos2 > 0)
                THEN
                    p_fileflds (i).LENGTH :=
                        SUBSTR (cur.iid_param_type,
                                l_pos1 + 1,
                                l_pos3 - l_pos1 - 1);
                    p_fileflds (i).decimals :=
                        SUBSTR (cur.iid_param_type,
                                l_pos3 + 1,
                                l_pos2 - l_pos3 - 1);
                ELSE
                    p_fileflds (i).LENGTH := 30;
                    p_fileflds (i).decimals := 0;
                END IF;

                p_fileflds (i).TYPE := 'N';
            ELSIF UPPER (cur.iid_param_type) = 'DATE'
            THEN
                p_fileflds (i).TYPE := 'D';
                p_fileflds (i).LENGTH := 8;
                p_fileflds (i).decimals := 0;
            ELSIF INSTR (cur.iid_param_type, 'VARCHAR2') > 0
            THEN
                l_pos1 := INSTR (cur.iid_param_type, '(');
                l_pos2 := INSTR (cur.iid_param_type, ')');

                IF (l_pos1 > 0) AND (l_pos2 > 0)
                THEN
                    p_fileflds (i).LENGTH :=
                        TO_NUMBER (
                            SUBSTR (cur.iid_param_type,
                                    l_pos1 + 1,
                                    l_pos2 - l_pos1 - 1));

                    IF p_fileflds (i).LENGTH > 255
                    THEN
                        raise_application_error (
                            -20000,
                               'Текстовий тип поля "'
                            || cur.iid_param_type
                            || '" не підтримується при експорті');
                    END IF;
                ELSE
                    p_fileflds (i).LENGTH := 255;
                END IF;

                p_fileflds (i).TYPE := 'C';
                p_fileflds (i).decimals := 0;
            ELSE
                raise_application_error (
                    -20000,
                       'Тип поля "'
                    || cur.iid_param_type
                    || '" не підтримується при експорті');
            END IF;
        END LOOP;

        p_hdr.version := '03';
        p_hdr.year := TO_NUMBER (TO_CHAR (SYSDATE, 'yyyy')) - 1900;
        p_hdr.month := TO_NUMBER (TO_CHAR (SYSDATE, 'mm'));
        p_hdr.day := TO_NUMBER (TO_CHAR (SYSDATE, 'dd'));
        p_hdr.no_fields := p_fileflds.COUNT;
        p_hdr.hdr_len := (p_hdr.no_fields * 32) + 33;
        p_hdr.no_records := 0;
        p_hdr.rec_len := 1;

        FOR i IN 1 .. p_fileflds.COUNT
        LOOP
            p_hdr.rec_len := p_hdr.rec_len + p_fileflds (i).LENGTH;
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'Error in put_header: ' || CHR (10) || SQLERRM);
    END;

    -- Lysyuk 20101111
    PROCEDURE put_rows (
        p_table      IN            ikis_import_files.iif_id%TYPE,
        p_blob       IN OUT NOCOPY BLOB,
        p_fileflds   IN            field_descriptor_array,
        p_dbflds     IN            field_descriptor_array,
        l_hdr        IN OUT        dbf_header)
    IS
        TYPE tp_refcur IS REF CURSOR;

        cur               tp_refcur;
        t_raw             RAW (32767);
        l_select_list     VARCHAR2 (32767);
        l_iif_buf_table   ikis_sys.v_ikis_import_files.iif_buf_table%TYPE;
        l_sql_script      VARCHAR2 (4000);
        l_tmp_row         VARCHAR2 (32767);
    BEGIN
        SELECT iif_buf_table
          INTO l_iif_buf_table
          FROM v_ikis_import_files
         WHERE iif_id = p_table;

        IF SUBSTR (l_iif_buf_table, 1, 13) = '<IKIS_SCRIPT>'
        THEN
            BEGIN
                l_iif_buf_table :=
                    TRIM (REPLACE (l_iif_buf_table, '<IKIS_SCRIPT>', ''));

                SELECT '(' || isc_query || ')'
                  INTO l_sql_script
                  FROM ikis_scripts
                 WHERE isc_code = l_iif_buf_table;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    raise_application_error (
                        -20000,
                        'Не знайдено скрипта за кодом ' || l_iif_buf_table);
            END;
        ELSE
            l_sql_script := l_iif_buf_table;
        END IF;

        FOR l IN 1 .. p_fileflds.COUNT
        LOOP
            l_select_list :=
                   l_select_list
                || CASE WHEN l = 1 THEN ''' ''||' ELSE '||' END
                || 'rpad(NVL('
                || CASE
                       WHEN p_fileflds (l).TYPE IN ('D', 'N')
                       THEN
                           'replace(to_char ('
                   END
                || '"'
                || p_dbflds (l).name
                || '"'
                || CASE
                       WHEN p_fileflds (l).TYPE = 'D' THEN ', ''yyyymmdd'''
                   END
                || CASE
                       WHEN p_fileflds (l).TYPE IN ('D', 'N')
                       THEN
                           '),'','',''.'')'
                   END
                || ','' ''),'
                || p_fileflds (l).LENGTH
                || ',chr(0))';
        END LOOP;

        OPEN cur FOR 'select ' || l_select_list || ' from ' || l_sql_script;

        t_raw := '';

        LOOP
            FETCH cur INTO l_tmp_row;

            EXIT WHEN cur%NOTFOUND;

            IF oem_convert
            THEN
                l_tmp_row := CONVERT (l_tmp_row, 'RU8PC866', 'CL8MSWIN1251');
            END IF;

            FOR l IN 0 .. TRUNC (LENGTH (l_tmp_row) / 2000)
            LOOP
                IF UTL_RAW.LENGTH (t_raw) > (32767 - 4000)
                THEN
                    DBMS_LOB.writeappend (p_blob,
                                          UTL_RAW.LENGTH (t_raw),
                                          t_raw);
                    t_raw := '';
                END IF;

                t_raw :=
                    UTL_RAW.CONCAT (
                        t_raw,
                        UTL_RAW.cast_to_raw (
                            SUBSTR (l_tmp_row, 2000 * l + 1, 2000)));
            END LOOP;
        END LOOP;

        l_hdr.no_records := cur%ROWCOUNT;

        IF t_raw IS NOT NULL
        THEN
            DBMS_LOB.writeappend (p_blob, UTL_RAW.LENGTH (t_raw), t_raw);
        END IF;

        CLOSE cur;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'Error in put_rows: ' || CHR (10) || SQLERRM);
    END;

    -- Lysyuk 20101111
    PROCEDURE dump_table (
        p_table      IN ikis_import_files.iif_id%TYPE,
        p_filename   IN ikis_import_files.iif_file_name%TYPE,
        p_convert    IN BOOLEAN DEFAULT FALSE)
    IS
        l_hdr         dbf_header;
        l_fileflds    field_descriptor_array;
        l_dbflds      field_descriptor_array;
        no_rec_hex    VARCHAR2 (8);
        hdr_len_hex   VARCHAR2 (4);
        rec_len_hex   VARCHAR2 (4);
        enc           VARCHAR (2);
        l_buffer      RAW (32767);
        l_blob        BLOB;
    BEGIN
        SELECT file_content
          INTO l_blob
          FROM ikis_sys.tt$blob_dbf_load
         WHERE file_name = UPPER (p_filename);

        DBMS_LOB.open (lob_loc => l_blob, open_mode => DBMS_LOB.lob_readwrite);

        oem_convert := p_convert;

        put_header (p_table,
                    l_hdr,
                    l_fileflds,
                    l_dbflds);

        rec_len_hex := TO_CHAR (l_hdr.rec_len, 'FM000x');
        no_rec_hex := TO_CHAR (l_hdr.no_records, 'FM0000000x');
        hdr_len_hex := TO_CHAR (l_hdr.hdr_len, 'FM000x');

        IF big_endian
        THEN
            rec_len_hex :=
                SUBSTR (rec_len_hex, -2) || SUBSTR (rec_len_hex, 1, 2);

            no_rec_hex :=
                   SUBSTR (no_rec_hex, -2)
                || SUBSTR (no_rec_hex, 5, 2)
                || SUBSTR (no_rec_hex, 3, 2)
                || SUBSTR (no_rec_hex, 1, 2);

            hdr_len_hex :=
                SUBSTR (hdr_len_hex, -2) || SUBSTR (hdr_len_hex, 1, 2);
        END IF;

        IF oem_convert
        THEN
            enc := '26';
        ELSE
            enc := '57';
        END IF;

        l_buffer :=
               RPAD (
                      l_hdr.version
                   || TO_CHAR (l_hdr.year, 'FM0x')
                   || TO_CHAR (l_hdr.month, 'FM0x')
                   || TO_CHAR (l_hdr.day, 'FM0x')
                   || no_rec_hex
                   || hdr_len_hex
                   || rec_len_hex,
                   58,
                   '0')
            || enc
            || '0000';

        --dbms_lob.createtemporary(p_blob, true);
        DBMS_LOB.write (l_blob,
                        UTL_RAW.LENGTH (l_buffer),
                        1,
                        l_buffer);

        FOR i IN 1 .. l_fileflds.COUNT
        LOOP
            l_buffer :=
                   UTL_RAW.cast_to_raw (
                       RPAD (SUBSTR (l_fileflds (i).name, 1, 10),
                             11,
                             CHR (0)))
                || UTL_RAW.cast_to_raw (l_fileflds (i).TYPE)
                || '00000000'
                || TO_CHAR (l_fileflds (i).LENGTH, 'FM0x')
                || TO_CHAR (NVL (l_fileflds (i).decimals, 0), 'FM0x')
                || UTL_RAW.cast_to_raw (RPAD (CHR (0), 14, CHR (0)));
            --dbms_output.put_line(l_buffer);

            DBMS_LOB.writeappend (l_blob,
                                  UTL_RAW.LENGTH (l_buffer),
                                  l_buffer);
        END LOOP;

        -- раздедитель строк
        l_buffer := '0D';
        DBMS_LOB.writeappend (l_blob, UTL_RAW.LENGTH (l_buffer), l_buffer);

        put_rows (p_table,
                  l_blob,
                  l_fileflds,
                  l_dbflds,
                  l_hdr);

        IF l_hdr.no_records > 0
        THEN
            -- записываем в заголовок кол-во строк
            no_rec_hex := TO_CHAR (l_hdr.no_records, 'FM0000000x');

            IF big_endian
            THEN
                no_rec_hex :=
                       SUBSTR (no_rec_hex, -2)
                    || SUBSTR (no_rec_hex, 5, 2)
                    || SUBSTR (no_rec_hex, 3, 2)
                    || SUBSTR (no_rec_hex, 1, 2);
            END IF;

            --dbms_output.put_line(no_rec_hex);
            DBMS_LOB.write (l_blob,
                            UTL_RAW.LENGTH (no_rec_hex),
                            5,
                            no_rec_hex);
        END IF;

        l_buffer := '1A';
        DBMS_LOB.writeappend (l_blob, UTL_RAW.LENGTH (l_buffer), l_buffer);

        DBMS_LOB.close (l_blob);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'Error in dump_table: ' || CHR (10) || SQLERRM);
    END;

    -- Lysyuk 20101111
    PROCEDURE ikis_export (p_type      IN ikis_import_types.iit_code%TYPE,
                           p_convert   IN BOOLEAN DEFAULT FALSE)
    IS
    BEGIN
        FOR i IN (SELECT x.iif_id, x.iif_file_name
                    FROM v_ikis_import_files x, v_ikis_import_types x1
                   WHERE x1.iit_code = p_type AND x1.iit_id = x.iif_iit)
        LOOP
            dump_table (i.iif_id, i.iif_file_name, p_convert);
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'Error in ikis_export: ' || CHR (10) || SQLERRM);
    END;

    -- Lysyuk 20101111
    PROCEDURE GetTmpBlob (
        p_filename   IN            ikis_import_files.iif_file_name%TYPE,
        p_blob_loc      OUT NOCOPY BLOB)
    IS
    BEGIN
        SELECT file_content
          INTO p_blob_loc
          FROM tt$blob_dbf_load
         WHERE file_name = UPPER (p_filename);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'Error in GetTmpBlob: ' || CHR (10) || SQLERRM);
    END;

    -- Lysyuk 20101111
    PROCEDURE ClearBufTables (p_type IN ikis_import_types.iit_code%TYPE)
    IS
    BEGIN
        FOR i
            IN (SELECT x.iif_buf_table, x1.iit_subsys
                  FROM v_ikis_import_files x, v_ikis_import_types x1
                 WHERE     x1.iit_code = p_type
                       AND SUBSTR (x.iif_buf_table, 1, 13) != '<IKIS_SCRIPT>'
                       AND x1.iit_id = x.iif_iit)
        LOOP
            EXECUTE IMMEDIATE   'delete from '
                             || i.iit_subsys
                             || '.'
                             || i.iif_buf_table;
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'Error in ClearBufTables: ' || CHR (10) || SQLERRM);
    END;
BEGIN
    SELECT x.property_value
      INTO DB_CHARSET
      FROM database_properties x
     WHERE x.property_name = 'NLS_CHARACTERSET';
END ikis_dbase_pkg;
/