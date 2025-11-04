/* Formatted on 8/12/2025 6:11:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.IKIS_WEB_ADM_FILE
IS
    -- Author  : VANO
    -- Created : 19.05.2016 14:01:02
    -- Purpose : Пакет функцій управління кешем файлів ЕА

    PROCEDURE RegsiterSubsys (
        p_wfs_code              W_FILE$SUBSYS.WFS_CODE%TYPE,
        p_wfs_name              W_FILE$SUBSYS.WFS_NAME%TYPE DEFAULT '',
        p_wfs_desc              W_FILE$SUBSYS.WFS_DESC%TYPE DEFAULT '',
        p_wfs_days_till_del     W_FILE$SUBSYS.WFS_DAYS_TILL_DEL%TYPE DEFAULT 60,
        p_wfs_days_till_redel   W_FILE$SUBSYS.WFS_DAYS_TILL_REDEL%TYPE DEFAULT 10);

    PROCEDURE ClearFiles;

    --+Shot24072019
    PROCEDURE GetFilesToArchive (p_cnt     IN     NUMBER DEFAULT 100,
                                 p_files      OUT SYS_REFCURSOR);

    PROCEDURE GetFilesToRecover (p_cnt     IN     NUMBER DEFAULT 100,
                                 p_files      OUT SYS_REFCURSOR);

    PROCEDURE SetFileArchived (p_wf_id    IN w_file$info.wf_id%TYPE,
                               p_ea_num      VARCHAR2);

    PROCEDURE RecoverFile (p_wf_id   IN w_file$download.wfd_wf%TYPE,
                           p_data    IN BLOB);

    PROCEDURE GetFileToArchive (p_wf_id   IN     w_file$info.wf_id%TYPE,
                                p_data       OUT BLOB);

    PROCEDURE SetFileCopiedToEA (p_wf_id    IN w_file$info.wf_id%TYPE,
                                 p_ea_num      VARCHAR2);

    PROCEDURE SetFileArchivedInEA (p_ea_num VARCHAR2);

    PROCEDURE GetCopiedButNonArchvedFiles (p_cnt     IN     NUMBER DEFAULT 100,
                                           p_files      OUT SYS_REFCURSOR);
END IKIS_WEB_ADM_FILE;
/


/* Formatted on 8/12/2025 6:11:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.IKIS_WEB_ADM_FILE
IS
    msgCOMMON_EXCEPTION   NUMBER := 2;

    defDaysTillDel        NUMBER := 60;
    defDaysTillReDel      NUMBER := 10;

    PROCEDURE RegsiterSubsys (
        p_wfs_code              W_FILE$SUBSYS.WFS_CODE%TYPE,
        p_wfs_name              W_FILE$SUBSYS.WFS_NAME%TYPE DEFAULT '',
        p_wfs_desc              W_FILE$SUBSYS.WFS_DESC%TYPE DEFAULT '',
        p_wfs_days_till_del     W_FILE$SUBSYS.WFS_DAYS_TILL_DEL%TYPE DEFAULT 60,
        p_wfs_days_till_redel   W_FILE$SUBSYS.WFS_DAYS_TILL_REDEL%TYPE DEFAULT 10)
    IS
        l_cnt    NUMBER;
        l_code   W_FILE$SUBSYS.WFS_CODE%TYPE;
    BEGIN
        l_code := TRIM (p_wfs_code);

        IF l_code IS NULL OR LENGTH (l_code) <> 5
        THEN
            raise_application_error (
                -20000,
                   'Length of code incorrect. Must be 5 chars: <'
                || p_wfs_code
                || '>');
        END IF;

        IF NOT REGEXP_LIKE (p_wfs_code, '^[0-9A-Za-z]{5}$')
        THEN
            raise_application_error (
                -20000,
                   'One or more chars in code incorrect: <'
                || p_wfs_code
                || '>. Symbols must be from [0-9A-Za-z]');
        END IF;

        SELECT COUNT (1)
          INTO l_cnt
          FROM W_FILE$SUBSYS
         WHERE wfs_code = p_wfs_code;

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                'Code already registered: <' || p_wfs_code || '>.');
        END IF;

        IF     LENGTH (p_wfs_code) = 5
           AND REGEXP_LIKE (p_wfs_code, '^[0-9A-Za-z]{5}$')
           AND l_cnt = 0
        THEN
            INSERT INTO W_FILE$SUBSYS (wfs_id,
                                       wfs_code,
                                       wfs_name,
                                       wfs_desc,
                                       wfs_days_till_del,
                                       wfs_days_till_redel)
                 VALUES (0,
                         p_wfs_code,
                         p_wfs_name,
                         p_wfs_desc,
                         p_wfs_days_till_del,
                         p_wfs_days_till_redel);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_WEB_ADM_FILE.add_subsys:',
                       SQLERRM
                    || CHR (10)
                    || DBMS_UTILITY.format_error_stack
                    || DBMS_UTILITY.format_error_backtrace));
    END;

    PROCEDURE ClearFiles
    IS
    BEGIN
        FOR xx
            IN (SELECT wfs_code,
                       NVL (wfs_days_till_del, defDaysTillDel)
                           AS wfs_days_till_del,
                       NVL (wfs_days_till_redel, defDaysTillReDel)
                           AS wfs_days_till_redel
                  FROM w_file$subsys t)
        LOOP
            --Помічаємо як "переміщені в Архів" ті файли, в яких вийшов час зберігання
            UPDATE w_file$info
               SET wf_st = 'A'
             WHERE     wf_upload_dt + xx.wfs_days_till_del <= SYSDATE
                   AND wf_wfs_code = xx.wfs_code
                   AND wf_st = 'L'
                   AND wf_is_archived = 'Y';

            UPDATE w_file$info t
               SET wf_st = 'A'
             WHERE     wf_recovery_dt + xx.wfs_days_till_redel <= SYSDATE
                   AND wf_wfs_code = xx.wfs_code
                   AND wf_st = 'V'
                   AND wf_is_archived = 'Y';

            DELETE FROM w_file$download
                  WHERE EXISTS
                            (SELECT 1
                               FROM w_file$info
                              WHERE     wfd_wf = wf_id
                                    AND wf_wfs_code = xx.wfs_code
                                    AND wf_st = 'A');

            COMMIT;
        END LOOP;
    END;

    --+Shot24072019
    PROCEDURE GetFilesToArchive (p_cnt     IN     NUMBER DEFAULT 100,
                                 p_files      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_files FOR
            SELECT wf_id,
                   wf_filename,
                   wf_upload_dt,
                   wf_tp,
                   wf_wfs_code,
                   wf_file_idn
              FROM w_file$info
             WHERE     wf_is_archived = 'N'
                   AND wf_elarch_idn IS NULL
                   AND ROWNUM <= p_cnt;
    END;


    PROCEDURE GetFilesToRecover (p_cnt     IN     NUMBER DEFAULT 100,
                                 p_files      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_files FOR
            SELECT wf_id,
                   wf_filename,
                   wf_upload_dt,
                   wf_tp,
                   wf_wfs_code,
                   wf_file_idn,
                   wf_elarch_idn
              FROM w_file$info
             WHERE     wf_is_archived = 'Y'
                   AND wf_st = 'V'
                   AND wf_recovery_dt IS NULL
                   AND wf_elarch_idn IS NOT NULL
                   AND ROWNUM <= p_cnt;
    END;

    PROCEDURE SetFileArchived (p_wf_id    IN w_file$info.wf_id%TYPE,
                               p_ea_num      VARCHAR2)
    IS
    BEGIN
        UPDATE w_file$info t
           SET t.wf_is_archived = 'Y',
               t.wf_elarch_idn = p_ea_num,
               t.wf_archive_dt = SYSDATE
         WHERE wf_id = p_wf_id;
    END;

    PROCEDURE RecoverFile (p_wf_id   IN w_file$download.wfd_wf%TYPE,
                           p_data    IN BLOB)
    IS
        l_cnt   INTEGER;
    BEGIN
        UPDATE w_file$info
           SET wf_recovery_dt = SYSDATE
         WHERE wf_id = p_wf_id AND wf_is_archived = 'Y' AND wf_st = 'V';

        l_cnt := SQL%ROWCOUNT;

        IF l_cnt = 1
        THEN
            MERGE INTO w_file$download x
                 USING (SELECT p_wf_id AS x_wf, p_data AS x_data FROM DUAL)
                    ON (wfd_wf = x_wf)
            WHEN MATCHED
            THEN
                UPDATE SET wfd_file_body = x_data
            WHEN NOT MATCHED
            THEN
                INSERT     (wfd_wf, wfd_file_body)
                    VALUES (x_wf, x_data);
        END IF;
    END;

    PROCEDURE GetFileToArchive (p_wf_id   IN     w_file$info.wf_id%TYPE,
                                p_data       OUT BLOB)
    IS
    BEGIN
        BEGIN
            SELECT wfd_file_body
              INTO p_data
              FROM w_file$download
             WHERE wfd_wf = p_wf_id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                p_data := NULL;
        END;
    END;

    PROCEDURE SetFileCopiedToEA (p_wf_id    IN w_file$info.wf_id%TYPE,
                                 p_ea_num      VARCHAR2)
    IS
    BEGIN
        UPDATE w_file$info t
           SET t.wf_elarch_idn = p_ea_num
         WHERE wf_id = p_wf_id;
    END;

    PROCEDURE SetFileArchivedInEA (p_ea_num VARCHAR2)
    IS
    BEGIN
        UPDATE w_file$info t
           SET t.wf_is_archived = 'Y', t.wf_archive_dt = SYSDATE
         WHERE t.wf_elarch_idn = p_ea_num;
    END;

    PROCEDURE GetCopiedButNonArchvedFiles (p_cnt     IN     NUMBER DEFAULT 100,
                                           p_files      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_files FOR
            SELECT wf_id,
                   wf_filename,
                   wf_upload_dt,
                   wf_tp,
                   wf_wfs_code,
                   wf_file_idn,
                   wf_elarch_idn
              FROM w_file$info
             WHERE     wf_is_archived = 'N'
                   AND wf_elarch_idn IS NOT NULL
                   AND wf_st = 'L'
                   AND ROWNUM <= p_cnt;
    END;
END IKIS_WEB_ADM_FILE;
/