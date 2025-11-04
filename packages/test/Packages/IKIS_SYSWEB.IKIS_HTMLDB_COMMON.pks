/* Formatted on 8/12/2025 6:11:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.IKIS_HTMLDB_COMMON
IS
    -- Author  : YURA_A
    -- Created : 05.04.2006 15:42:57
    -- Purpose : Загальні функції

    -- Public type declarations
    NotAdmissibleChr             CONSTANT VARCHAR2 (70)
        := 'ЙЦУКЕНГШЩЗХЇФІВАПРОЛДЖЄЯЧСМИТЬБЮ йцукенгшщзхїфівапролджєячсмитьбю-''"`' ;

    --YUra_AP 20061214 - для утилиты загрузки файлов
    IKIS_SYSWEB_CONTEXT_NAME              VARCHAR2 (10) := 'IKISWEBADM'; --20190425 убираем связи с контекстом
    IKIS_SYSWEB_CONTEXT_UserTP   CONSTANT VARCHAR2 (10) := 'IUTP';
    IKIS_SYSWEB_CONTEXT_OPFU     CONSTANT VARCHAR2 (10) := 'OPFU';
    IKIS_SYSWEB_CONTEXT_UID      CONSTANT VARCHAR2 (10) := 'IKISUID';

    exInvalidCheckForInput                EXCEPTION; --Экзепшн райзится при проверке строки ввода ChkVarchar2,ChkDate,ChkNumber

    TYPE Type_Rec_Keywords IS RECORD
    (
        Word    VARCHAR2 (40),
        lvl     NUMBER (1)
    );

    TYPE Table_Keywords IS TABLE OF Type_Rec_Keywords;

    g_Keywords                            Table_Keywords := Table_Keywords ();

    --+YAP проверка ввода
    PROCEDURE ChkVarchar2 (p_vc2 VARCHAR2);

    PROCEDURE ChkDate (p_date     VARCHAR2,
                       p_format   VARCHAR2 DEFAULT 'dd/mm/yyyy');

    PROCEDURE ChkNumber (p_number VARCHAR2, p_format VARCHAR2 DEFAULT NULL);

    PROCEDURE GetOPFU (p_user           VARCHAR2,
                       P_OPFUCODE   OUT VARCHAR2,
                       P_OPFUNAME   OUT VARCHAR2);

    PROCEDURE pipe_debug (p_sess VARCHAR2, msg VARCHAR2);

    PROCEDURE unzipfile (p_blobfile IN OUT NOCOPY BLOB, p_filename VARCHAR2);

    PROCEDURE unzipfile_spovmz (p_blobfile   IN OUT NOCOPY BLOB,
                                p_filename                 VARCHAR2);

    PROCEDURE unzipfile_1 (p_infile VARCHAR2, p_outdir VARCHAR2);

    PROCEDURE GUnZipFile (p_blobfile      IN OUT NOCOPY BLOB,
                          p_filename                    VARCHAR2,
                          p_outfilename                 VARCHAR2);

    PROCEDURE CreateExternalTable (p_table                 VARCHAR2,
                                   p_listoffields          VARCHAR2,
                                   p_ctllistoffields       VARCHAR2,
                                   p_dirlocation           VARCHAR2,
                                   p_dirbad                VARCHAR2,
                                   p_dirlog                VARCHAR2,
                                   p_datafile              VARCHAR2,
                                   p_delimiter             VARCHAR2,
                                   p_src               OUT CLOB);

    PROCEDURE RenameFile (p_ifile VARCHAR2, p_ofile VARCHAR2);

    FUNCTION GetRoleLst (p_user w_users.wu_login%TYPE)
        RETURN VARCHAR2;

    FUNCTION GetRoleLstID (p_user w_users.wu_login%TYPE)
        RETURN VARCHAR2;

    FUNCTION is_role_assigned (p_username IN VARCHAR2, p_role IN VARCHAR2)
        RETURN BOOLEAN;

    FUNCTION GetVersion (p_subsys VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION GetAdmissibleChr (INSTR VARCHAR2)
        RETURN VARCHAR2;

    --YAP 20080415 - проверка полей ввода для поисковых форм
    FUNCTION CheckString (p_string VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE clear_directory (directory_path   IN VARCHAR2,
                               directory_name   IN VARCHAR2);

    --+YAP для нужд IKIS_QUEUE (и возможно кого еще)
    --возвращает списко ИД пользователей, которым назначены роли определенного приложения
    --приложение определяется контекстом установленным через p_app_name (см. ikis_sysweb.ikis_web_context.setcontext(p_app_name => :p_app_name);
    FUNCTION GetWebAppUserIDLST
        RETURN t_lines
        PIPELINED;

    FUNCTION str2tbl (p_str IN VARCHAR2)
        RETURN t_table_list;

    --========================================
    -- Перевірка текстового параметру на підозру sql injection
    -- return > 0 якщо є підозрілі символи
    --========================================
    FUNCTION validate_param (p_val VARCHAR2, p_lvl NUMBER:= 0)
        RETURN NUMBER;
END IKIS_HTMLDB_COMMON;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_HTMLDB_COMMON FOR IKIS_SYSWEB.IKIS_HTMLDB_COMMON
/


GRANT EXECUTE ON IKIS_SYSWEB.IKIS_HTMLDB_COMMON TO II01RC_SYSWEB_COMM
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_HTMLDB_COMMON TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_HTMLDB_COMMON TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_HTMLDB_COMMON TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_HTMLDB_COMMON TO IKIS_WEBPROXY WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_HTMLDB_COMMON TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_HTMLDB_COMMON TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_HTMLDB_COMMON TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_HTMLDB_COMMON TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_HTMLDB_COMMON TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_HTMLDB_COMMON TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_HTMLDB_COMMON TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_HTMLDB_COMMON TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_HTMLDB_COMMON TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:11:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.IKIS_HTMLDB_COMMON
IS
    msgCOMMON_EXCEPTION   NUMBER := 2;

    FUNCTION GetAdmissibleChr (INSTR VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN (REPLACE (
                    TRANSLATE (INSTR || CHR (0), NotAdmissibleChr, CHR (0)),
                    CHR (0),
                    ''));
    END;

    PROCEDURE GetOPFU (p_user           VARCHAR2,
                       P_OPFUCODE   OUT VARCHAR2,
                       P_OPFUNAME   OUT VARCHAR2)
    IS
    BEGIN
        SELECT x2.org_code, x2.org_name
          INTO P_OPFUCODE, P_OPFUNAME
          FROM w_users x1, v_opfu x2
         WHERE x1.wu_login = UPPER (p_user) AND x1.wu_org = x2.org_id;
    END;

    FUNCTION GetVersion (p_subsys VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN ikis_common.getapptparam (p_name => p_subsys || '_VER');
    END;

    PROCEDURE pipe_debug (p_sess VARCHAR2, msg VARCHAR2)
    AS
        status   NUMBER;
        l_msg    VARCHAR2 (32760);
        l_key    VARCHAR2 (1);
    BEGIN
        /*
        ikis_parameter_util.GetParameter(p_par_code => 'HTML_PIPE_DEBUG',p_par_ss_code => 'IKIS_SKZR',p_par_value => l_key);
        if l_key='Y' then
          l_msg:=to_char(sysdate,'DD/MM/YYYY HH24:MI:SS')||'<'||p_sess||'>: '||msg;
          DBMS_PIPE.PACK_MESSAGE(LENGTH(l_msg));
          DBMS_PIPE.PACK_MESSAGE(l_msg);
          status := DBMS_PIPE.SEND_MESSAGE('html_debug');
          IF not(status = 0) THEN
            raise_application_error(-20099, 'Debug error');
          END IF;
        end if;
        */
        NULL;
        l_msg :=
               TO_CHAR (SYSDATE, 'DD/MM/YYYY HH24:MI:SS')
            || '<'
            || p_sess
            || '>: '
            || msg;
        DBMS_PIPE.PACK_MESSAGE (LENGTH (l_msg));
        DBMS_PIPE.PACK_MESSAGE (l_msg);
        status := DBMS_PIPE.SEND_MESSAGE ('html_debug');

        IF NOT (status = 0)
        THEN
            raise_application_error (-20099, 'Debug error');
        END IF;
    END;

    PROCEDURE RenameFile (p_ifile VARCHAR2, p_ofile VARCHAR2)
    IS
        l_tempdir   VARCHAR2 (1000);
    BEGIN
        l_tempdir :=
            ikis_parameter_util.GetParameter1 (
                p_par_code      => 'HTMLDB_TEMPDATAFILES',
                p_par_ss_code   => 'IKIS_SYSWEB');
        --dbms_output.put_line(l_tempdir);
        --dbms_output.put_line(l_tempdir||'/'||p_ifile);
        --dbms_output.put_line(l_tempdir||'/'||p_ofile);
        viewzip$renamefile (p_ifile   => l_tempdir || '/' || p_ifile,
                            p_ofile   => l_tempdir || '/' || p_ofile);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_HTMLDB_COMMON.RenameFile',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE unzipfile (p_blobfile IN OUT NOCOPY BLOB, p_filename VARCHAR2)
    IS
        v_read_amount   INTEGER := 32765;
        v_read_offset   INTEGER := 1;
        v_buffer        RAW (32767);
        l_file          UTL_FILE.file_type;
        l_outzipdir     VARCHAR2 (1000);
        l_inzipdir      VARCHAR2 (1000);
    BEGIN
        l_file :=
            UTL_FILE.fopen (location       => UPPER ('ikiswebfiles'),
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
        --+YAP 20081111 убран костыль от Вани, первые строки откомментарены, вторые две закомментарены
        l_outzipdir :=
            ikis_parameter_util.GetParameter1 (
                p_par_code      => 'HTMLDB_TEMPDATAFILES',
                p_par_ss_code   => 'IKIS_SYSWEB');
        l_inzipdir :=
               ikis_parameter_util.GetParameter1 (
                   p_par_code      => 'HTMLDB_TEMPZIPFILES',
                   p_par_ss_code   => 'IKIS_SYSWEB')
            || p_filename;
        --l_outzipdir:='/part2/oradata/webfile/temp';
        --l_inzipdir:='/part2/oradata/webfile/'||p_filename;
        ---YAP

        --dbms_output.put_line(l_outzipdir);
        --dbms_output.put_line(l_inzipdir);
        viewzip$unzipall (p_zip => l_inzipdir, p_outdir => l_outzipdir);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_HTMLDB_COMMON.unzipfile',
                    CHR (10) || SQLERRM));
    END;

    --ivanr. Процедура для роззиповки архивов для спов-м
    PROCEDURE unzipfile_spovmz (p_blobfile   IN OUT NOCOPY BLOB,
                                p_filename                 VARCHAR2)
    IS
        v_read_amount   INTEGER := 32765;
        v_read_offset   INTEGER := 1;
        v_buffer        RAW (32767);
        l_file          UTL_FILE.file_type;
        l_outzipdir     VARCHAR2 (1000);
        l_inzipdir      VARCHAR2 (1000);
    BEGIN
        l_file :=
            UTL_FILE.fopen (location       => UPPER ('ikiswebfiles'),
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
        --l_outzipdir:=ikis_parameter_util.GetParameter1(p_par_code => 'HTMLDB_TEMPDATAFILES',p_par_ss_code => 'IKIS_SYSWEB');
        --l_inzipdir:=ikis_parameter_util.GetParameter1(p_par_code => 'HTMLDB_TEMPZIPFILES',p_par_ss_code => 'IKIS_SYSWEB')||p_filename;
        l_outzipdir := '/part2/oradata/webfile/temp/';
        l_inzipdir := '/part2/oradata/webfile/' || p_filename;
        --dbms_output.put_line(l_outzipdir);
        --dbms_output.put_line(l_inzipdir);
        viewzip$unzipall (p_zip => l_inzipdir, p_outdir => l_outzipdir);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_HTMLDB_COMMON.unzipfile',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE unzipfile_1 (p_infile VARCHAR2, p_outdir VARCHAR2)
    IS
    BEGIN
        viewzip$unzipall (p_zip => p_infile, p_outdir => p_outdir);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_HTMLDB_COMMON.unzipfile_1',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE GUnZipFile (p_blobfile      IN OUT NOCOPY BLOB,
                          p_filename                    VARCHAR2,
                          p_outfilename                 VARCHAR2)
    IS
        v_read_amount   INTEGER := 32767;
        v_read_offset   INTEGER := 1;
        v_buffer        RAW (32767);
        l_file          UTL_FILE.file_type;
        l_outzipdir     VARCHAR2 (1000);
        l_inzipdir      VARCHAR2 (1000);
    BEGIN
        l_file :=
            UTL_FILE.fopen (location       => UPPER ('ikiswebfiles'),
                            filename       => p_filename,
                            open_mode      => 'w',
                            max_linesize   => 32767);

        LOOP
            DBMS_LOB.Read (p_blobfile,
                           v_read_amount,
                           v_read_offset,
                           v_buffer);
            UTL_FILE.put_raw (file        => l_file,
                              buffer      => v_buffer,
                              autoflush   => TRUE);
            v_read_offset := v_read_offset + v_read_amount;
            EXIT WHEN v_read_amount < 32767;
            v_read_amount := 32767;
        END LOOP;

        UTL_FILE.fclose (file => l_file);
        l_outzipdir :=
            ikis_parameter_util.GetParameter1 (
                p_par_code      => 'HTMLDB_TEMPDATAFILES',
                p_par_ss_code   => 'IKIS_SYSWEB');
        l_inzipdir :=
               ikis_parameter_util.GetParameter1 (
                   p_par_code      => 'HTMLDB_TEMPZIPFILES',
                   p_par_ss_code   => 'IKIS_SYSWEB')
            || p_filename;
        viewzip$gunzip (p_zip       => l_inzipdir,
                        p_outfile   => l_outzipdir || '/' || p_outfilename);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_HTMLDB_COMMON.GUnZipFile',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE CreateExternalTable (p_table                 VARCHAR2,
                                   p_listoffields          VARCHAR2,
                                   p_ctllistoffields       VARCHAR2,
                                   p_dirlocation           VARCHAR2,
                                   p_dirbad                VARCHAR2,
                                   p_dirlog                VARCHAR2,
                                   p_datafile              VARCHAR2,
                                   p_delimiter             VARCHAR2,
                                   p_src               OUT CLOB)
    IS
        l_template   VARCHAR2 (32760)
            :=    'CREATE TABLE ~<EXTERNALTABLENAME>~ ('
               || CHR (10)
               || '~<LISTOFFIELDS>~'
               || CHR (10)
               || ') ORGANIZATION EXTERNAL '
               || CHR (10)
               || '  ( TYPE ORACLE_LOADER '
               || CHR (10)
               || '    DEFAULT DIRECTORY ~<DIRECTORYLOCATION>~ '
               || CHR (10)
               || '    ACCESS PARAMETERS '
               || CHR (10)
               || '      ( records delimited by newline '
               || CHR (10)
               || '        badfile ~<BADFILEDIRECTORY>~:''~<EXTERNALTABLENAME>~%a_%p.bad'' '
               || CHR (10)
               || '        logfile ~<LOGFILEDIRECTORY>~:''~<EXTERNALTABLENAME>~%a_%p.log'' '
               || CHR (10)
               || '        fields terminated by ''~<LINEDELIMITER>~'' '
               || CHR (10)
               || '        missing field values are null ( '
               || CHR (10)
               || '~<CTLLISTOFFIELDS>~ '
               || CHR (10)
               || '          ))LOCATION (''~<DATAFILE>~'')) PARALLEL REJECT LIMIT 0';
    BEGIN
        l_template := REPLACE (l_template, '~<EXTERNALTABLENAME>~', p_table);
        l_template :=
            REPLACE (l_template, '~<LISTOFFIELDS>~', p_listoffields);
        l_template :=
            REPLACE (l_template, '~<CTLLISTOFFIELDS>~', p_ctllistoffields);

        l_template :=
            REPLACE (l_template, '~<DIRECTORYLOCATION>~', p_dirlocation);
        l_template := REPLACE (l_template, '~<BADFILEDIRECTORY>~', p_dirbad);
        l_template := REPLACE (l_template, '~<LOGFILEDIRECTORY>~', p_dirlog);

        l_template := REPLACE (l_template, '~<LINEDELIMITER>~', p_delimiter);
        l_template := REPLACE (l_template, '~<DATAFILE>~', p_datafile);
        p_src := l_template;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_HTMLDB_COMMON.CreateExternalTable',
                    CHR (10) || SQLERRM));
    END;

    FUNCTION GetWebAppUserIDLST
        RETURN t_lines
        PIPELINED
    IS
    BEGIN
        FOR i
            IN (SELECT DISTINCT y.wu_id
                  FROM w_roles x, w_usr2roles y
                 WHERE     x.wr_id = y.wr_id
                       AND x.wr_ss_code =
                           SYS_CONTEXT ('IKISWEBADM', 'APPNAME')) --20190425 убираю связь с контекстом
        LOOP
            PIPE ROW (i.wu_id);
        END LOOP;

        RETURN;
    END;

    FUNCTION GetRoleLst (p_user w_users.wu_login%TYPE)
        RETURN VARCHAR2
    IS
        --+YAP 20090610
        --l_res varchar2(1000);
        l_res   VARCHAR2 (32760);
    ---YAP 20090610
    BEGIN
        FOR i
            IN (  SELECT wr_descr
                    FROM w_roles,
                         w_usr2roles,
                         w_users,
                         w_roles_group,
                         w_wrg2role                                 --20160524
                   WHERE     w_roles.wr_id = w_usr2roles.wr_id
                         AND w_usr2roles.wu_id = w_users.wu_id
                         AND w_users.wu_login = UPPER (p_user)
                         AND w_roles_group.wrg_id = w_wrg2role.wrgr_wrg
                         AND w_wrg2role.wrgr_wr = w_roles.wr_id
                ORDER BY w_roles_group.wrg_ord, w_wrg2role.wrgr_ord)
        LOOP
            l_res := l_res || i.wr_descr || '<br>';
        END LOOP;

        IF LENGTH (l_res) > 4000
        THEN
            l_res := SUBSTR (l_res, 1, 3900) || '<br> ... вивід скорочено.';
        END IF;                                                               --YAP 20090610

        RETURN RTRIM (NVL (l_res, 'N/A'), '<br>');
    END;

    FUNCTION GetRoleLstID (p_user w_users.wu_login%TYPE)
        RETURN VARCHAR2
    IS
        l_res   VARCHAR2 (1000);
    BEGIN
        FOR i
            IN (SELECT wr_id
                  FROM w_usr2roles, w_users
                 WHERE     w_usr2roles.wu_id = w_users.wu_id
                       AND w_users.wu_login = UPPER (p_user))
        LOOP
            l_res := l_res || i.wr_id || ':';
        END LOOP;

        RETURN RTRIM (NVL (l_res, '0'), ':');
    END;

    FUNCTION is_role_assigned (p_username IN VARCHAR2, p_role IN VARCHAR2)
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN ikis_htmldb_auth.is_role_assigned (p_username, p_role);
    END;


    PROCEDURE ChkVarchar2 (p_vc2 VARCHAR2)
    IS
        l_buff   VARCHAR2 (32760);
    BEGIN
        IF p_vc2 IS NOT NULL
        THEN
            l_buff := UPPER (p_vc2);

            FOR i IN 1 .. LENGTH (l_buff)
            LOOP
                IF SUBSTR (l_buff, i, 1) NOT IN ('A',
                                                 'B',
                                                 'C',
                                                 'D',
                                                 'E',
                                                 'F',
                                                 'G',
                                                 'H',
                                                 'I',
                                                 'J',
                                                 'K',
                                                 'L',
                                                 'M',
                                                 'N',
                                                 'O',
                                                 'P',
                                                 'Q',
                                                 'R',
                                                 'S',
                                                 'T',
                                                 'U',
                                                 'V',
                                                 'W',
                                                 'X',
                                                 'Y',
                                                 'Z',
                                                 'А',
                                                 'Б',
                                                 'В',
                                                 'Г',
                                                 'Д',
                                                 'Е',
                                                 'Ё',
                                                 'Ж',
                                                 'З',
                                                 'И',
                                                 'К',
                                                 'Л',
                                                 'М',
                                                 'Н',
                                                 'О',
                                                 'П',
                                                 'Р',
                                                 'С',
                                                 'Т',
                                                 'У',
                                                 'Ф',
                                                 'Х',
                                                 'Ц',
                                                 'Ч',
                                                 'Ш',
                                                 'Щ',
                                                 'Ъ',
                                                 'Ь',
                                                 'Э',
                                                 'Ю',
                                                 'Я',
                                                 'І',
                                                 'Ї',
                                                 'Є',
                                                 'Ы',
                                                 'Й',
                                                 '-',
                                                 '`',
                                                 '.'       -- +Frolov 20100412
                                                    --,'''' --+YAP 20081020
                                                    ,
                                                 '_',
                                                 '%',
                                                 '/',
                                                 '\',
                                                 ' ',
                                                 '1',
                                                 '2',
                                                 '3',
                                                 '4',
                                                 '5',
                                                 '6',
                                                 '7',
                                                 '8',
                                                 '9',
                                                 '0')
                THEN
                    RAISE exInvalidCheckForInput;
                END IF;
            END LOOP;
        END IF;
    END;

    PROCEDURE ChkDate (p_date     VARCHAR2,
                       p_format   VARCHAR2 DEFAULT 'dd/mm/yyyy')
    IS
        l_date   DATE;
    BEGIN
        l_date := TO_DATE (p_date, p_format);
    EXCEPTION
        WHEN OTHERS
        THEN
            RAISE exInvalidCheckForInput;
    END;

    PROCEDURE ChkNumber (p_number VARCHAR2, p_format VARCHAR2 DEFAULT NULL)
    IS
        l_nmbr   NUMBER;
    BEGIN
        IF p_format IS NULL
        THEN
            l_nmbr := TO_NUMBER (p_number);
        ELSE
            l_nmbr := TO_NUMBER (p_number, p_format);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            RAISE exInvalidCheckForInput;
    END;

    FUNCTION CheckString (p_string VARCHAR2)
        RETURN VARCHAR2
    IS
        l_buff   VARCHAR2 (32760);
    BEGIN
        ChkVarchar2 (p_string);
        RETURN NULL;
    EXCEPTION
        WHEN exInvalidCheckForInput
        THEN
            RETURN 'Некоректне значення для пошуку.';
    END;

    --очистка директории (нужна модификация на прием а качетве параметра названия директории)
    PROCEDURE clear_directory (directory_path   IN VARCHAR2,
                               directory_name   IN VARCHAR2)
    IS
        location    VARCHAR2 (255);
        location2   VARCHAR2 (255);
        filename    VARCHAR2 (255);
        i           INTEGER;
    BEGIN
        --location:='/part2/oradata/webfile';
        --location2:='ikiswebfiles';
        DBMS_OUTPUT.put_line (directory_path);
        DBMS_OUTPUT.put_line (directory_name);
        get_dir_list (directory_path);

        FOR cc IN (SELECT dir_list.filename FROM dir_list)
        LOOP
            IF cc.filename = 'temp'
            THEN
                NULL;
            ELSE
                filename := cc.filename;
                UTL_FILE.FREMOVE (UPPER (directory_name), filename);
                DBMS_OUTPUT.put_line ('Удалили файл - :' || cc.filename);
            END IF;
        END LOOP;

        COMMIT;
    END;

    -- удаление файла из локальной директории
    PROCEDURE delete_file (file_name IN VARCHAR2, location IN VARCHAR2)
    IS
        --location  VARCHAR2(255);
        --filename  VARCHAR2(255);
        i   INTEGER;
    BEGIN
        -- Test statements here
        UTL_FILE.FREMOVE (UPPER ('ikiswebfiles'), file_name);
        DBMS_OUTPUT.put_line ('Удалили файл - :' || file_name);
    END;

    FUNCTION str2tbl (p_str IN VARCHAR2)
        RETURN t_table_list
    AS
        l_str    LONG DEFAULT p_str || ':';
        l_n      NUMBER;
        l_data   t_table_list := t_table_list ();
    BEGIN
        LOOP
            l_n := INSTR (l_str, ':');
            EXIT WHEN (NVL (l_n, 0) = 0);
            l_data.EXTEND;
            l_data (l_data.COUNT) :=
                LTRIM (RTRIM (SUBSTR (l_str, 1, l_n - 1)));
            l_str := SUBSTR (l_str, l_n + 1);
        END LOOP;

        RETURN l_data;
    END;

    --========================================
    PROCEDURE set_Keywords (p_val VARCHAR2, p_lvl NUMBER DEFAULT 5)
    IS
    BEGIN
        g_Keywords.EXTEND;
        g_Keywords (g_Keywords.COUNT).word := p_val;
        g_Keywords (g_Keywords.COUNT).lvl := p_lvl;
    END;

    --========================================
    PROCEDURE Init_Keywords
    IS
    BEGIN
        set_Keywords ('ADD ');
        set_Keywords ('ADD CONSTRAINT');
        set_Keywords ('ALTER');
        --    set_Keywords('ALTER COLUMN');
        --    set_Keywords('ALTER TABLE');
        set_Keywords ('ALL');
        set_Keywords ('AND');
        set_Keywords ('ANY');
        set_Keywords ('AS');
        set_Keywords ('ASC');
        set_Keywords ('BACKUP DATABASE');
        set_Keywords ('BETWEEN');
        set_Keywords ('CASE');
        set_Keywords ('CHECK');
        set_Keywords ('COLUMN');
        set_Keywords ('CONSTRAINT');
        set_Keywords ('CREATE');
        set_Keywords ('CREATE DATABASE');
        set_Keywords ('CREATE INDEX');
        set_Keywords ('CREATE OR REPLACE VIEW');
        set_Keywords ('CREATE TABLE');
        set_Keywords ('CREATE PROCEDURE');
        set_Keywords ('CREATE UNIQUE INDEX');
        set_Keywords ('CREATE VIEW');
        set_Keywords ('DATABASE');
        set_Keywords ('DEFAULT');
        set_Keywords ('DELETE');
        set_Keywords ('DESC');
        set_Keywords ('DISTINCT');
        set_Keywords ('DROP');
        set_Keywords ('DROP COLUMN');
        set_Keywords ('DROP CONSTRAINT');
        set_Keywords ('DROP DATABASE');
        set_Keywords ('DROP DEFAULT');
        set_Keywords ('DROP INDEX');
        set_Keywords ('DROP TABLE');
        set_Keywords ('DROP VIEW');
        set_Keywords ('EXEC');
        set_Keywords ('EXISTS');
        set_Keywords ('FOREIGN KEY');
        set_Keywords ('FROM');
        set_Keywords ('FULL OUTER JOIN');
        set_Keywords ('GROUP BY');
        set_Keywords ('HAVING');
        set_Keywords ('IN', 4);
        set_Keywords ('INDEX');
        set_Keywords ('INNER JOIN');
        set_Keywords ('INSERT INTO');
        set_Keywords ('INSERT INTO SELECT');
        set_Keywords ('IS NULL', 4);                     -- послаблено для НДІ
        set_Keywords ('IS NOT NULL', 4);                 -- послаблено для НДІ
        set_Keywords ('JOIN');
        set_Keywords ('LEFT JOIN');
        set_Keywords ('LIKE', 4);                        -- послаблено для НДІ
        set_Keywords ('LIMIT');
        set_Keywords ('NOT');
        set_Keywords ('NOT NULL', 4);                    -- послаблено для НДІ
        set_Keywords ('OR', 4);
        set_Keywords ('ORDER BY');
        set_Keywords ('OUTER JOIN');
        set_Keywords ('PRIMARY KEY');
        set_Keywords ('PROCEDURE');
        set_Keywords ('RIGHT JOIN');
        set_Keywords ('ROWNUM');
        set_Keywords ('SELECT');
        set_Keywords ('SELECT DISTINCT');
        set_Keywords ('SELECT INTO');
        set_Keywords ('SELECT TOP');
        set_Keywords ('SET');
        set_Keywords ('TABLE');
        set_Keywords ('TOP');
        set_Keywords ('TRUNCATE TABLE');
        set_Keywords ('UNION');
        set_Keywords ('UNION ALL');
        set_Keywords ('UNIQUE');
        set_Keywords ('UPDATE');
        set_Keywords ('VALUES');
        set_Keywords ('VIEW');
        set_Keywords ('WHERE');
        set_Keywords ('DUAL');
        --
        set_Keywords ('--');
        --set_Keywords('''');
        set_Keywords ('NVL');
        set_Keywords ('CHR');
        set_Keywords ('SUBSTR');
        --
        set_Keywords ('USS\_');
        set_Keywords ('IKIS\_');
        set_Keywords ('APEX\_');
        set_Keywords ('SYS');
        set_Keywords ('SYSTEM');
        set_Keywords ('CTXSYS');
        set_Keywords ('MD.');
        set_Keywords ('WMSYS.');
        set_Keywords ('WSUTILS.');
        set_Keywords ('XDB');
        set_Keywords ('DBA');
    END;

    --========================================
    -- Перевірка текстового параметру на підозру sql injection
    -- return > 0 якщо є підозрілі символи
    --========================================
    FUNCTION validate_param (p_val VARCHAR2, p_lvl NUMBER:= 0)
        RETURN NUMBER
    IS
        l_val   VARCHAR2 (4000);
        l_cnt   NUMBER;
        l_lvl   NUMBER := NVL (p_lvl, 0);
    BEGIN
        l_val := REPLACE (p_val, CHR (9), ' ');
        l_val := REPLACE (l_val, CHR (10), ' ');
        l_val := REPLACE (l_val, CHR (13), ' ');
        l_val := RTRIM (LTRIM (l_val));
        l_val := REGEXP_REPLACE (l_val, '( ){2,}', ' ');

        SELECT COUNT (1) INTO l_cnt FROM TABLE (g_Keywords);

        --dbms_output.put_line(l_val);
        --dbms_output.put_line(l_cnt);
        --dbms_output.put_line(l_lvl);
        /*
            SELECT COUNT(1)
              INTO l_cnt
            FROM TABLE(g_Keywords)
            WHERE upper(l_val) LIKE '%'||word||'%' ESCAPE '\'
              AND lvl >= l_lvl;
        */
        SELECT SUM (
                   CASE
                       WHEN REGEXP_LIKE (UPPER (l_val),
                                         '(^|\s|\W)' || word || '($|\s|\W)')
                       THEN
                           1
                       ELSE
                           0
                   END)
          INTO l_cnt
          FROM TABLE (g_Keywords)
         WHERE lvl >= l_lvl;

        --SELECT CASE WHEN regexp_like('CREATE DATABASE', '(^|\s|\W)CREATE DATABASE($|\s|\W)') THEN 1 ELSE 0 END FROM dual;


        RETURN l_cnt;
    END;
--========================================
BEGIN
    -- Initialization
    Init_Keywords;
END IKIS_HTMLDB_COMMON;
/