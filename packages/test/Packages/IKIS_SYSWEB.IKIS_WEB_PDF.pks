/* Formatted on 8/12/2025 6:11:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.ikis_web_pdf
IS
    -- Author  : YURA_A
    -- Created : 18.03.2009 10:13:24
    -- Purpose : Convert to PDF
    PROCEDURE ConvertFILE2PDF (p_infile          BLOB, -- блоб с файлом RTF - входной файл
                               p_outfile     OUT BLOB, -- блоб с файлом PDF - выходной файл
                               p_debug           NUMBER DEFAULT 0, -- режим записи сообщений в серверный файл протокола: 0 пишутся только ошибки, другое значение - пишется расширенный лог
                               p_extension       VARCHAR2 := '.rtf'); -- расширение входящего файла
 -- нужно внимательно проверять чтобы расширение соответствовало типу входящего блоба
                                        -- иначе будут проблемы с конвертацией



    PROCEDURE CleanUpWorkDir; -- очистка рабочего каталога (запускает администратор)
END ikis_web_pdf;
/


GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_PDF TO PUBLIC
/


/* Formatted on 8/12/2025 6:11:45 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.ikis_web_pdf
IS
    gPDF_V1_ROOT      VARCHAR2 (1000);
    gPDF_V1_WORKDIR   VARCHAR2 (1000);
    gPDF_V1_CMD       VARCHAR2 (1000);
    gPDF_V1_CMDDBG    VARCHAR2 (1000);
    gPDF_V1_DIROBJ    VARCHAR2 (1000);
    gPDF_V1_CLEANUP   VARCHAR2 (1000);
    gFILENAME         VARCHAR2 (100);

    gHndl             VARCHAR2 (100);
    gTimeOut          NUMBER := 600;

    FUNCTION Execute_OS_Script (p_command VARCHAR2)
        RETURN NUMBER
    IS
        ----------------------------------------
        -- Author  : YURA_A
        -- Created : 08.04.2003 10:45:51
        ----------------------------------------
        -- Исполнение команды ОС и возврат кода выхода команды
        -- Стандартный поток ошибок интерпретируется как текст для возбуждения исключительной систуации
        l_errmsg   VARCHAR2 (32760) := NULL;
        line       VARCHAR2 (32760);
        l_status   INTEGER := 0;
        retcode    NUMBER;
    BEGIN
        DBMS_JAVA.SET_OUTPUT (1000000);
        --Исполнение Ява-процедуры
        retcode := execcmd (p_command);

        --Вычитывание сообщения об ошибке из потока вывода сервера
        LOOP
            DBMS_OUTPUT.get_line (line, l_status);
            EXIT WHEN l_status <> 0;
            l_errmsg := l_errmsg || CHR (13) || line;
        END LOOP;

        --Ежели сообщение есть, то его раизим
        IF l_errmsg IS NOT NULL
        THEN
            raise_application_error (-20000, l_errmsg);
        END IF;

        RETURN retcode;
    END;

    PROCEDURE GetLock
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_res   NUMBER;
    BEGIN
        DBMS_LOCK.allocate_unique (
            lockname     => 'IKISSYSWEBPDFCONVV1' || USERENV ('INSTANCE'),
            lockhandle   => gHndl);
        l_res :=
            DBMS_LOCK.request (gHndl,
                               DBMS_LOCK.S_MODE,
                               gTimeOut,
                               FALSE);

        IF l_res <> 0
        THEN
            raise_application_error (-20000,
                                     'Error in request lock: ' || l_res);
        END IF;

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            RAISE;
    END;

    PROCEDURE EscalateLock
    IS
        l_res   NUMBER;
    BEGIN
        l_res := DBMS_LOCK.CONVERT (gHndl, DBMS_LOCK.X_MODE, gTimeOut);

        IF l_res <> 0
        THEN
            raise_application_error (-20000,
                                     'Error in escalate lock: ' || l_res);
        END IF;
    END;

    PROCEDURE ReleaseLock
    IS
        l_res   NUMBER;
    BEGIN
        l_res := DBMS_LOCK.release (gHndl);

        IF l_res <> 0
        THEN
            raise_application_error (-20000,
                                     'Error in release lock: ' || l_res);
        END IF;
    END;


    PROCEDURE CleanUpWorkDir
    IS
        retcode   NUMBER;
    BEGIN
        GetLock;
        EscalateLock;
        retcode := Execute_OS_Script (gPDF_V1_ROOT || '/' || gPDF_V1_CLEANUP);

        IF retcode != 0
        THEN
            raise_application_error (-20000,
                                     'CleanUp error. Exit code: ' || retcode);
        END IF;

        ReleaseLock;
    EXCEPTION
        WHEN OTHERS
        THEN
            ReleaseLock;
            RAISE;
    END;

    PROCEDURE SaveBlobToFile (p_infile BLOB, p_filename VARCHAR2)
    IS
        fl         UTL_FILE.file_type;
        l_chnk     NUMBER := 32767;
        l_buffer   RAW (32767);
        l_offset   NUMBER := 1;
        l_lngth    NUMBER;
    BEGIN
        l_lngth := DBMS_LOB.getlength (p_infile);

        IF l_lngth = 0
        THEN
            raise_application_error (-20000, 'LOB is zero length.');
        END IF;

        fl :=
            UTL_FILE.FOPEN (location       => UPPER (gPDF_V1_DIROBJ),
                            filename       => p_filename,
                            open_mode      => 'w',
                            max_linesize   => l_chnk);

        WHILE l_chnk > 0
        LOOP
            DBMS_LOB.read (p_infile,
                           l_chnk,
                           l_offset,
                           l_buffer);
            l_offset := l_offset + l_chnk;
            UTL_FILE.PUT_RAW (file => fl, buffer => l_buffer, autoflush => TRUE);

            IF l_offset > l_lngth
            THEN
                l_chnk := 0;
            END IF;
        END LOOP;

        UTL_FILE.Fclose (fl);
    EXCEPTION
        WHEN OTHERS
        THEN
            IF UTL_FILE.IS_OPEN (fl)
            THEN
                UTL_FILE.Fclose (fl);
            END IF;

            RAISE;
    END;

    PROCEDURE LoadFromFileToBlob (p_outfile OUT BLOB, p_filename VARCHAR2)
    IS
        p_file      BFILE;
        l_soffset   NUMBER := 1;
        l_doffset   NUMBER := 1;
    BEGIN
        p_file := BFILENAME (UPPER (gPDF_V1_DIROBJ), p_filename);
        DBMS_LOB.createtemporary (p_outfile, FALSE, 1);
        DBMS_LOB.open (p_outfile, DBMS_LOB.lob_readwrite);
        DBMS_LOB.open (p_file);
        DBMS_LOB.LOADBLOBFROMFILE (p_outfile,
                                   p_file,
                                   DBMS_LOB.LOBMAXSIZE,
                                   l_soffset,
                                   l_doffset);
        DBMS_LOB.close (p_outfile);
        DBMS_LOB.close (p_file);
    END;

    PROCEDURE ConvertFILE2PDF (p_infile          BLOB,
                               p_outfile     OUT BLOB,
                               p_debug           NUMBER DEFAULT 0,
                               p_extension       VARCHAR2 := '.rtf')
    IS
        retcode   NUMBER;
        cmd       VARCHAR2 (1000);

        l_ifile   VARCHAR2 (100) := gFILENAME || p_extension;
        l_ofile   VARCHAR2 (100) := gFILENAME || '.pdf';
    BEGIN
        GetLock;
        SaveBlobToFile (p_infile, l_ifile);

        IF p_debug = 0
        THEN
            cmd :=
                REPLACE (
                    REPLACE (gPDF_V1_ROOT || '/' || gPDF_V1_CMD,
                             '<IFILE>',
                             gPDF_V1_WORKDIR || '/' || l_ifile),
                    '<OFILE>',
                    gPDF_V1_WORKDIR || '/' || l_ofile);
        ELSE
            cmd :=
                REPLACE (
                    REPLACE (gPDF_V1_ROOT || '/' || gPDF_V1_CMDDBG,
                             '<IFILE>',
                             gPDF_V1_WORKDIR || '/' || l_ifile),
                    '<OFILE>',
                    gPDF_V1_WORKDIR || '/' || l_ofile);
        --    cmd:=gPDF_V1_ROOT||'/e_pdf.sh';
        END IF;

        retcode := Execute_OS_Script (cmd);

        IF retcode != 0
        THEN
            raise_application_error (
                -20000,
                'Convert to PDF error. Exit code: ' || retcode); --||'; Command: '||cmd);
        END IF;

        LoadFromFileToBlob (p_outfile, l_ofile);
        ReleaseLock;
    EXCEPTION
        WHEN OTHERS
        THEN
            ReleaseLock;
            raise_application_error (
                -20000,
                   DBMS_UTILITY.FORMAT_ERROR_STACK
                || ':'
                || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    END;
BEGIN
    gPDF_V1_ROOT :=
        ikis_sys.ikis_parameter_util.GetParameter1 (
            p_par_code      => 'PDF_V1_ROOT',
            p_par_ss_code   => 'IKIS_SYSWEB');
    gPDF_V1_WORKDIR :=
        ikis_sys.ikis_parameter_util.GetParameter1 (
            p_par_code      => 'PDF_V1_WORKDIR',
            p_par_ss_code   => 'IKIS_SYSWEB');
    gPDF_V1_CMD :=
        ikis_sys.ikis_parameter_util.GetParameter1 (
            p_par_code      => 'PDF_V1_CMD',
            p_par_ss_code   => 'IKIS_SYSWEB');
    gPDF_V1_CMDDBG :=
        ikis_sys.ikis_parameter_util.GetParameter1 (
            p_par_code      => 'PDF_V1_CMDDBG',
            p_par_ss_code   => 'IKIS_SYSWEB');
    gPDF_V1_DIROBJ :=
        ikis_sys.ikis_parameter_util.GetParameter1 (
            p_par_code      => 'PDF_V1_DIROBJ',
            p_par_ss_code   => 'IKIS_SYSWEB');
    gPDF_V1_CLEANUP :=
        ikis_sys.ikis_parameter_util.GetParameter1 (
            p_par_code      => 'PDF_V1_CLEANUP',
            p_par_ss_code   => 'IKIS_SYSWEB');

    SELECT 'pdf_' || sid
      INTO gFILENAME
      FROM v$mystat
     WHERE ROWNUM < 2;
-- Котульский В.А. убрал дефолтовое расширение ".rtf" и вінес его как входящий параметр процедуры ConvertFILE2PDF
-- таким образом мы можем конвертировать не только rtf но и html
END ikis_web_pdf;
/