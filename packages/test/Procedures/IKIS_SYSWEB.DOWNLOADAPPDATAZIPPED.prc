/* Formatted on 8/12/2025 6:11:37 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_SYSWEB.DownloadAppDataZipped (
    p_wjt           w_job_type.wjt_id%TYPE,
    p_jb         IN w_jobs.jb_id%TYPE DEFAULT NULL,
    p_filename   IN w_job_type.wjt_file_name%TYPE DEFAULT NULL)
IS
    l_rpt       BLOB;
    l_content   w_job_type.wjt_content_type%TYPE;
    l_file      w_job_type.wjt_file_name%TYPE;
    l_jb        w_jobs.jb_id%TYPE;
    l_fileArr   tbl_some_files := tbl_some_files ();
BEGIN
    --данная процедура являеться костылем, так как в Ikis_Sysweb_Schedule нет выгрузки данных в архиве а нужно повторить функционал
    IF p_jb IS NULL
    THEN
        raise_application_error (
            -20000,
            ikis_message_util.GET_MESSAGE (
                2,
                'DownloadAppDataZipped',
                CHR (10) || ': не вказан ідентифікатор завдання!'));
    END IF;

    BEGIN
        SELECT jb_appdata, wjt_content_type, wjt_file_name
          INTO l_rpt, l_content, l_file
          FROM v_w_jobs_univ, w_job_type
         WHERE wjt_id = jb_wjt AND jb_id = p_jb;

        IF (p_filename IS NOT NULL)
        THEN
            l_file := p_filename;
        END IF;

        l_fileArr.EXTEND;
        l_fileArr (l_fileArr.LAST) :=
            t_some_file_info (filename => l_file, content => l_Rpt);
        l_rpt := ikis_Web_Jutil.getZipFromStrms (l_fileArr);
        HTP.p ('Content-Type: application/zip');
        HTP.p (
               'Content-Disposition: attachment; filename="'
            || l_file
            || '.zip"');
        HTP.p ('Content-Length: ' || DBMS_LOB.getlength (l_rpt));
        HTP.p ('');
        WPG_DOCLOAD.download_file (l_rpt);
    EXCEPTION
        WHEN OTHERS
        THEN
            IF DBMS_LOB.ISOPEN (lob_loc => l_rpt) > 0
            THEN
                DBMS_LOB.close (l_rpt);
            END IF;

            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (2,
                                               'DownloadAppDataZipped',
                                               CHR (10) || SQLERRM));
    END;
END;
/
