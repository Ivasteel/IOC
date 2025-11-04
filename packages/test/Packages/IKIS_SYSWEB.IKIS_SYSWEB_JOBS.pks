/* Formatted on 8/12/2025 6:11:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.IKIS_SYSWEB_JOBS
IS
    -- Author  : YURA_A
    -- Created : 18.04.2007 10:18:02
    -- Purpose : IKIS Web Job Management System

    PROCEDURE SubmitJob (p_jb         OUT w_jobs.jb_id%TYPE,
                         p_subsys         VARCHAR2,
                         p_wjt            w_job_type.wjt_id%TYPE,
                         p_what           VARCHAR2,
                         p_nextdate       DATE DEFAULT SYSDATE,
                         p_interval       VARCHAR2 DEFAULT NULL,
                         p_isweb          INTEGER DEFAULT 1);

    PROCEDURE JobWrap (p_jb         IN w_jobs.jb_id%TYPE,
                       p_what          VARCHAR2,
                       p_interval      VARCHAR2);

    PROCEDURE StopJob (p_jb IN w_jobs.jb_id%TYPE);

    PROCEDURE SaveMessage (p_mess VARCHAR2, p_type VARCHAR2 DEFAULT 'I');

    FUNCTION GetUser
        RETURN VARCHAR2;

    PROCEDURE PrintStatus (p_jb IN w_jobs.jb_id%TYPE DEFAULT NULL);

    PROCEDURE DownloadAppData (
        p_wjt           w_job_type.wjt_id%TYPE,
        p_jb         IN w_jobs.jb_id%TYPE DEFAULT NULL,
        p_filename   IN w_job_type.wjt_file_name%TYPE DEFAULT NULL);

    -- Author  : Frolov
    -- Created : 20081023
    -- Purpose : возвращает в ВЕБ-приложение запакованный в ZIP блоб
    PROCEDURE DownloadAppDataZipped (
        p_wjt           w_job_type.wjt_id%TYPE,
        p_jb         IN w_jobs.jb_id%TYPE DEFAULT NULL,
        p_filename   IN w_job_type.wjt_file_name%TYPE DEFAULT NULL);

    PROCEDURE SaveAppData (p_data IN BLOB);

    PROCEDURE EraseAppData (p_ss_code   VARCHAR2,
                            p_wjt       VARCHAR2,
                            p_day       INTEGER);

    FUNCTION IsAppDataNotEmpty (p_jb IN w_jobs.jb_id%TYPE)
        RETURN BOOLEAN;

    FUNCTION IsJobInueue (p_jb IN w_jobs.jb_id%TYPE)
        RETURN BOOLEAN;

    FUNCTION GetJobStatus (p_jb_id IN w_jobs.jb_id%TYPE)
        RETURN w_jobs.jb_status%TYPE;
END IKIS_SYSWEB_JOBS;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_SYSWEB_JOBS FOR IKIS_SYSWEB.IKIS_SYSWEB_JOBS
/


GRANT EXECUTE ON IKIS_SYSWEB.IKIS_SYSWEB_JOBS TO II01RC_SYSWEB_COMM
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_SYSWEB_JOBS TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_SYSWEB_JOBS TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_SYSWEB_JOBS TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_SYSWEB_JOBS TO IKIS_WEBPROXY WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_SYSWEB_JOBS TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_SYSWEB_JOBS TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_SYSWEB_JOBS TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_SYSWEB_JOBS TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_SYSWEB_JOBS TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_SYSWEB_JOBS TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_SYSWEB_JOBS TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_SYSWEB_JOBS TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_SYSWEB_JOBS TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:11:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.IKIS_SYSWEB_JOBS
IS
    msgCOMMON_EXCEPTION       NUMBER := 2;
    msgAllInstanceExecuting   NUMBER := 6262;
    msgSessionNotFound        NUMBER := 6263;

    gJob                      w_jobs.jb_id%TYPE;
    gUserName                 VARCHAR2 (32760);

    FUNCTION GetUser
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN gUserName;
    END;

    PROCEDURE SetStatus (p_jb IN w_jobs.jb_id%TYPE, p_st VARCHAR2)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE w_jobs
           SET jb_start_dt =
                   DECODE (p_st,
                           ikis_const.V_DDN_WJB_ST_RUNING, SYSDATE,
                           jb_start_dt),
               jb_stop_dt =
                   DECODE (p_st,
                           ikis_const.V_DDN_WJB_ST_ENDED, SYSDATE,
                           ikis_const.V_DDN_WJB_ST_ERROR, SYSDATE,
                           jb_stop_dt),
               jb_status = p_st
         WHERE jb_id = p_jb;

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            RAISE;
    END;

    PROCEDURE SaveMessage (p_mess VARCHAR2, p_type VARCHAR2 DEFAULT 'I')
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO w_jobs_protocol (jm_id,
                                     jm_jb,
                                     jm_ts,
                                     jm_tp,
                                     jm_message)
             VALUES (0,
                     gJob,
                     SYSDATE,
                     p_type,
                     p_mess);

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_SYSWEB_JOBS.SaveMessage',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE StopJob (p_jb IN w_jobs.jb_id%TYPE)
    IS
        l_job            w_jobs%ROWTYPE;
        l_sid            NUMBER;
        l_serial         NUMBER;
        exNotRuningJob   EXCEPTION;
    BEGIN
        SELECT *
          INTO l_job
          FROM w_jobs
         WHERE jb_id = p_jb;

        BEGIN
            SELECT x2.SID, x2.SERIAL#
              INTO l_sid, l_serial
              FROM v_dba_jobs_running x1, v_session x2
             WHERE x1.SID = x2.SID AND x1.JOB = l_job.jb_job_id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RAISE exNotRuningJob;
            WHEN OTHERS
            THEN
                RAISE;
        END;

        DBMS_JOB.remove (l_job.jb_job_id);

        EXECUTE IMMEDIATE   'alter system kill session '''
                         || l_sid
                         || ','
                         || l_serial
                         || '''';

        --  dbms_lock.sleep(1);
        --  dbms_job.broken(l_job.jb_job_id,true);
        COMMIT;
    EXCEPTION
        WHEN exNotRuningJob
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgSessionNotFound));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'IKIS_SYSWEB_JOBS.StopJob',
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE JobWrap (p_jb         IN w_jobs.jb_id%TYPE,
                       p_what          VARCHAR2,
                       p_interval      VARCHAR2)
    IS
        l_lock             ikis_lock.t_lockhandler;
        l_lock_cont        ikis_lock.t_lockhandler;
        l_lock_cont1       ikis_lock.t_lockhandler;
        l_job              w_jobs%ROWTYPE;
        l_job_tp           w_job_type%ROWTYPE;
        l_lock_name        VARCHAR2 (100);
        l_int              VARCHAR2 (200);
        l_err              VARCHAR2 (4000);
        l_receiving        BOOLEAN := FALSE;
        i                  NUMBER;
        j                  NUMBER;
        exNotReceiveSlot   EXCEPTION;
    BEGIN
        --+YAP 20091125 - пока всем запретить
        EXECUTE IMMEDIATE 'alter session disable parallel query';

        EXECUTE IMMEDIATE 'alter session disable parallel dml';

        ---YAP 20091125 - пока всем запретить

        gJob := p_jb;

        SELECT *
          INTO l_job
          FROM w_jobs
         WHERE jb_id = p_jb;

        SELECT *
          INTO l_job_tp
          FROM w_job_type
         WHERE wjt_id = l_job.jb_wjt;

        SELECT wu_login
          INTO gUserName
          FROM w_users
         WHERE wu_id = l_job.com_wu;

        l_lock_name := l_job.jb_wjt;

        IF l_job_tp.wjt_is_reg_lock = 1
        THEN
            l_lock_name := l_lock_name || l_job.com_org;
        END IF;

        IF l_job_tp.wjt_is_user_lock = 1
        THEN
            l_lock_name := l_lock_name || l_job.com_wu;
        END IF;

        IF l_job_tp.wjt_concur_cnt_lock > 0
        THEN
            --блокировка процесса вычисления конкурентности
            ikis_lock.Request_Lock (
                p_permanent_name      => 'IKISWEBJOBATLAS',
                p_var_name            => l_job.jb_wjt || '0',
                p_errmessage          =>
                    'Неможливо отримати дозвіл на виконання.',
                p_lockhandler         => l_lock_cont,
                p_lockmode            => 6,
                p_timeout             => 30,
                p_release_on_commit   => FALSE);
            --SaveMessage('Locked latch: '||l_lock_cont);
            i := 1;

            LOOP                                         -- делаем три попытки
                --SaveMessage('Try: '||i);
                j := 1;

                LOOP                   -- попытка получить слот для исполнения
                    BEGIN
                        --SaveMessage('Slot: '||j);
                        ikis_lock.Request_Lock (
                            p_permanent_name      => 'IKISWEBJOBATLAS',
                            p_var_name            => l_lock_name || j,
                            p_errmessage          => 'XXX',
                            p_lockhandler         => l_lock_cont1,
                            p_lockmode            => 6,
                            p_timeout             => 0,
                            p_release_on_commit   => TRUE);
                        l_receiving := TRUE;
                    --SaveMessage('Received: '||l_lock_name||j);
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            NULL;       --SaveMessage('Slot '||j||' in use.');
                    END;

                    j := j + 1;
                    EXIT WHEN j > l_job_tp.wjt_concur_cnt_lock;
                    EXIT WHEN l_receiving;
                END LOOP;

                i := i + 1;
                EXIT WHEN l_receiving;
                EXIT WHEN i > 3;
            END LOOP;

            ikis_lock.Releace_Lock (p_lockhandler => l_lock_cont);

            IF NOT l_receiving
            THEN
                RAISE exNotReceiveSlot;
            END IF;
        ELSE
            --по старому алгоритму
            ikis_lock.Request_Lock (
                p_permanent_name      => 'IKISWEBJOBATLAS',
                p_var_name            => l_lock_name,
                p_errmessage          => 'Задача вже виконується.',
                p_lockhandler         => l_lock,
                p_lockmode            => 6,
                p_timeout             => 0,
                p_release_on_commit   => TRUE);
        END IF;

        SetStatus (p_jb, ikis_const.V_DDN_WJB_ST_RUNING);

        --+YAP 20091124 шобы трассировать военных
        --ikis_sys.ikis_repl_util.startrepltrace(p_script => 'WJOB',
        --                                       p_direction => l_job.jb_wjt);
        BEGIN
            ---YAP 20091124 шобы трассировать военных
            IKIS_WEB_CONTEXT.SetJobContext (l_job.jb_wjt);
            --ikis_mil.IKIS_MIL_CONTEXT.SetJobContext;
            DBMS_APPLICATION_INFO.set_module (module_name   => l_job.jb_wjt,
                                              action_name   => NULL);

            EXECUTE IMMEDIATE p_what;

            SetStatus (p_jb, ikis_const.V_DDN_WJB_ST_ENDED);
            COMMIT;
            gUserName := NULL;
        --+YAP 20091127 шобы трассировать военных (делает второй снимок статспака
        --ikis_sys.ikis_repl_util.EndReplTrace(p_script => 'WJOB',
        --                                       p_direction => l_job.jb_wjt);
        EXCEPTION
            WHEN OTHERS
            THEN
                --ikis_sys.ikis_repl_util.EndReplTrace(p_script => 'WJOB',
                --                                       p_direction => l_job.jb_wjt);
                RAISE;
        END;

        ---YAP 20091127 шобы трассировать военных

        --select x.interval into l_int from user_jobs x where x.job=l_job.jb_job_id;
        --SaveMessage(l_int);
        IF p_interval IS NOT NULL
        THEN
            SetStatus (p_jb, ikis_const.V_DDN_WJB_ST_ENQUEUE);
        END IF;
    EXCEPTION
        WHEN exNotReceiveSlot
        THEN
            SetStatus (p_jb, ikis_const.V_DDN_WJB_ST_ERROR);
            SaveMessage (
                ikis_message_util.GET_MESSAGE (msgAllInstanceExecuting,
                                               l_job_tp.wjt_concur_cnt_lock),
                'E');
            ROLLBACK;
        WHEN OTHERS
        THEN
            --l_err:='Помилка виконання завдання: <br>'||p_what||'<br>'||sqlerrm;
            l_err := 'Помилка виконання завдання: ' || SQLERRM;
            SetStatus (p_jb, ikis_const.V_DDN_WJB_ST_ERROR);
            SaveMessage (l_err, 'E');
            ROLLBACK;
    --    raise_application_error(-20000,ikis_message_util.get_message(msgCOMMON_EXCEPTION,'IKIS_SYSWEB_JOBS.JobWrap',chr(10)||l_err));
    END;

    PROCEDURE SubmitJob (p_jb         OUT w_jobs.jb_id%TYPE,
                         p_subsys         VARCHAR2,
                         p_wjt            w_job_type.wjt_id%TYPE,
                         p_what           VARCHAR2,
                         p_nextdate       DATE DEFAULT SYSDATE,
                         p_interval       VARCHAR2 DEFAULT NULL,
                         p_isweb          INTEGER DEFAULT 1)
    IS
        l_jb_job_id   w_jobs.jb_job_id%TYPE;
        l_st          w_jobs.jb_status%TYPE;
        l_what        VARCHAR2 (32760);
    BEGIN
        IF p_nextdate IS NOT NULL
        THEN
            l_st := ikis_const.V_DDN_WJB_ST_ENQUEUE;
        ELSE
            l_st := ikis_const.V_DDN_WJB_ST_NEW;
        END IF;

        INSERT INTO w_jobs (jb_id,
                            jb_wjt,
                            jb_ss_code,
                            com_org,
                            com_wu,
                            jb_job_id,
                            jb_start_dt,
                            jb_stop_dt,
                            jb_status,
                            jb_appdata)
             VALUES (
                        0,
                        p_wjt,
                        p_subsys,
                        CASE
                            WHEN p_isweb = 1
                            THEN
                                SYS_CONTEXT (ikis_web_context.gContext,
                                             ikis_web_context.gOPFU)
                            ELSE
                                '28000'
                        END,
                        CASE
                            WHEN p_isweb = 1
                            THEN
                                SYS_CONTEXT (ikis_web_context.gContext,
                                             ikis_web_context.gUID)
                            ELSE
                                '0'
                        END,
                        l_jb_job_id,
                        NULL,
                        NULL,
                        l_st,
                        EMPTY_BLOB ())
          RETURNING jb_id
               INTO p_jb;

        l_what :=
               'begin IKIS_SYSWEB_JOBS.JobWrap('
            || p_jb
            || ','''
            || p_what
            || ''','''
            || p_interval
            || '''); end;';

        DBMS_JOB.submit (job         => l_jb_job_id,
                         what        => l_what,
                         next_date   => p_nextdate,
                         interval    => p_interval);

        UPDATE w_jobs
           SET jb_job_id = l_jb_job_id
         WHERE jb_id = p_jb;

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_SYSWEB_JOBS.SubmitJob',
                    CHR (10) || l_what || CHR (10) || SQLERRM));
    END;

    PROCEDURE TestJob
    IS
    BEGIN
        SaveMessage ('Повідомлення 1');
        DBMS_APPLICATION_INFO.set_module (module_name   => 'TestJob',
                                          action_name   => 'Крок 1 ІЇЄ');
        SaveMessage ('Повідомлення 2');
        DBMS_LOCK.sleep (seconds => 5);
        SaveMessage ('Повідомлення 3');
        DBMS_APPLICATION_INFO.set_module (module_name   => 'TestJob',
                                          action_name   => 'Крок 2 ІЇЄ');
        SaveMessage ('Повідомлення 4');
        DBMS_LOCK.sleep (seconds => 5);
        SaveMessage ('Повідомлення 5');
        DBMS_APPLICATION_INFO.set_module (module_name   => 'TestJob',
                                          action_name   => 'Крок 3 ІЇЄ');
        SaveMessage ('Повідомлення 6');
        DBMS_LOCK.sleep (seconds => 5);
        SaveMessage ('Повідомлення 7');
    END;

    PROCEDURE PrintStatus (p_jb IN w_jobs.jb_id%TYPE)
    IS
        l_start    DATE;
        l_stop     DATE;
        l_status   VARCHAR2 (100);
        l_module   VARCHAR2 (100);
        l_action   VARCHAR2 (100);
        l_job      NUMBER;
    BEGIN
        -- +Frolov 02.04.2008 Добавил обработчик исключиений
        BEGIN
            SELECT x1.jb_start_dt,
                   x1.jb_stop_dt,
                   d1.DIC_SNAME,
                   x1.jb_job_id
              INTO l_start,
                   l_stop,
                   l_status,
                   l_job
              FROM v_w_jobs x1, v_ddn_wjb_st d1
             WHERE x1.jb_id = p_jb AND x1.jb_status = d1.DIC_VALUE;
        EXCEPTION
            WHEN OTHERS
            THEN
                raise_application_error (
                    -20000,
                    ikis_message_util.GET_MESSAGE (
                        msgCOMMON_EXCEPTION,
                        'IKIS_SYSWEB_JOBS.PrintStatus',
                        CHR (10) || SQLERRM));
        END;

        -- -Frolov
        BEGIN
            SELECT x3.MODULE, x3.ACTION
              INTO l_module, l_action
              FROM dba_jobs_running x2, v_session x3
             WHERE l_job = x2.JOB AND x2.SID = x3.SID;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        HTP.p (
               'Початок виконання: <b>'
            || TO_CHAR (l_start, 'DD.MM.YYYY HH24:MI:SS')
            || '</b>');
        HTP.br;
        HTP.p (
               'Завершення виконання: <b>'
            || TO_CHAR (l_stop, 'DD.MM.YYYY HH24:MI:SS')
            || '</b>');
        HTP.br;
        HTP.p ('Статус: <b>' || l_status || '</b>');
        HTP.br;
        HTP.p ('Модуль: <b>' || l_module || '</b>');
        HTP.br;
        HTP.p ('Етап: <b>' || l_action || '</b>');
        HTP.br;
        HTP.BR;

        FOR i
            IN (  SELECT x1.*,
                         x2.*,
                         DECODE (X2.jm_tp,
                                 'I', 'ІНФО',
                                 'E', '<b>ПОМИЛКА</b>',
                                 'W', 'ПОПЕРЕДЖ',
                                 '-')    MES_TP
                    FROM v_w_jobs x1, w_jobs_protocol x2
                   WHERE x1.jb_id = x2.jm_jb AND x1.jb_id = p_jb
                ORDER BY x2.jm_ts)
        LOOP
            HTP.p (
                   RPAD (I.MES_TP, 16, ' ')
                || TO_CHAR (I.JM_TS, 'DD.MM.YYYY HH24:MI:SS')
                || ': <b>'
                || I.JM_MESSAGE
                || '</b>');
            HTP.BR;
        END LOOP;
    END;

    PROCEDURE DownloadAppDataZipped (
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
        IF p_jb IS NULL
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_SYSWEB_JOBS.DownloadAppData',
                    CHR (10) || ': не вказан ідентифікатор завдання!'));
        END IF;

        BEGIN
            SELECT jb_appdata, wjt_content_type, wjt_file_name
              INTO l_rpt, l_content, l_file
              FROM v_w_jobs, w_job_type
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
                    ikis_message_util.GET_MESSAGE (
                        msgCOMMON_EXCEPTION,
                        'IKIS_SYSWEB_JOBS.DownloadAppData',
                        CHR (10) || SQLERRM));
        END;
    END;

    PROCEDURE DownloadAppData (
        p_wjt           w_job_type.wjt_id%TYPE,
        p_jb         IN w_jobs.jb_id%TYPE DEFAULT NULL,
        -- +Kalev 03.03.2008 имя файла передано
        p_filename   IN w_job_type.wjt_file_name%TYPE DEFAULT NULL-- -Kalev 03.03.2008 имя файла передано
                                                                  )
    IS
        l_rpt       BLOB;
        l_content   w_job_type.wjt_content_type%TYPE;
        l_file      w_job_type.wjt_file_name%TYPE;
        l_jb        w_jobs.jb_id%TYPE;
    BEGIN
        -- вытягиваем все
        IF p_jb IS NULL
        THEN
            -- +Frolov закоментировал запрос! вместо него поднимаю эксепшн
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_SYSWEB_JOBS.DownloadAppData',
                    CHR (10) || ': не вказан ідентифікатор завдання!'));
        /*    select jb_appdata, wjt_content_type, wjt_file_name
              into l_rpt, l_content, l_file
              from v_w_jobs, w_job_type
              where wjt_id = jb_wjt
                and jb_id = (select max(jb_id) from v_w_jobs where jb_wjt = p_wjt);
        */
        END IF;

        BEGIN
            SELECT jb_appdata, wjt_content_type, wjt_file_name
              INTO l_rpt, l_content, l_file
              FROM v_w_jobs, w_job_type
             WHERE wjt_id = jb_wjt AND jb_id = p_jb;

            -- +Kalev 03.03.2008 имя файла передано
            IF (p_filename IS NOT NULL)
            THEN
                l_file := p_filename;
            END IF;

            -- -Kalev 03.03.2008 имя файла передано
            DBMS_LOB.open (lob_loc     => l_rpt,
                           open_mode   => DBMS_LOB.lob_readonly);

            HTP.p (
                'Content-Type: ' || l_content || ' ; name="' || l_file || '"');
            HTP.p (
                   'Content-Disposition: attachment; filename="'
                || l_file
                || '"');
            HTP.p ('Content-Length: ' || DBMS_LOB.getlength (l_rpt));
            HTP.p ('');
            WPG_DOCLOAD.download_file (l_rpt);
            DBMS_LOB.close (l_rpt);
        EXCEPTION
            WHEN OTHERS
            THEN
                IF DBMS_LOB.ISOPEN (lob_loc => l_rpt) > 0
                THEN
                    DBMS_LOB.close (l_rpt);
                END IF;

                raise_application_error (
                    -20000,
                    ikis_message_util.GET_MESSAGE (
                        msgCOMMON_EXCEPTION,
                        'IKIS_SYSWEB_JOBS.DownloadAppData',
                        CHR (10) || SQLERRM));
        END;
    END;

    PROCEDURE SaveAppData (p_data IN BLOB)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_data   BLOB;
    BEGIN
        IF DBMS_LOB.getlength (p_data) > 0
        THEN
            UPDATE w_jobs
               SET jb_appdata = p_data
             WHERE jb_id = gJob;
        END IF;

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_SYSWEB_JOBS.SaveAppData',
                    CHR (10) || SQLERRM));
    END;

    -- +Kalev 12.03.2008
    -- Видалення даних для підсистеми по типу, створених раніше вказаної дати на підставі днів
    PROCEDURE EraseAppData (p_ss_code   VARCHAR2,
                            p_wjt       VARCHAR2,
                            p_day       INTEGER)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE w_jobs j
           SET j.jb_appdata = NULL
         WHERE     j.jb_ss_code = p_ss_code
               AND (p_wjt IS NULL OR p_wjt IS NOT NULL AND j.jb_wjt = p_wjt)
               AND j.jb_start_dt < TRUNC (SYSDATE) - p_day;

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_SYSWEB_JOBS.EraseAppData',
                    CHR (10) || SQLERRM));
    END;

    FUNCTION IsAppDataNotEmpty (p_jb IN w_jobs.jb_id%TYPE)
        RETURN BOOLEAN
    IS
        l_sz   NUMBER;
    BEGIN
        IF p_jb IS NOT NULL
        THEN
            SELECT DBMS_LOB.getlength (w_jobs.jb_appdata)
              INTO l_sz
              FROM w_jobs
             WHERE w_jobs.jb_id = p_jb;

            RETURN l_sz > 0;
        ELSE
            RETURN FALSE;
        END IF;
    END;

    FUNCTION IsJobInueue (p_jb IN w_jobs.jb_id%TYPE)
        RETURN BOOLEAN
    IS
        l_st   VARCHAR2 (100);
    BEGIN
        IF p_jb IS NOT NULL
        THEN
            SELECT w_jobs.jb_status
              INTO l_st
              FROM w_jobs
             WHERE w_jobs.jb_id = p_jb;

            RETURN l_st NOT IN
                       (ikis_const.V_DDN_WJB_ST_RUNING,
                        ikis_const.V_DDN_WJB_ST_ENQUEUE,
                        ikis_const.V_DDN_WJB_ST_NEW);
        ELSE
            RETURN TRUE;
        END IF;
    END;

    FUNCTION GetJobStatus (p_jb_id IN w_jobs.jb_id%TYPE)
        RETURN w_jobs.jb_status%TYPE
    IS
        l_jb_status   w_jobs.jb_status%TYPE;
    BEGIN
        SELECT jb_status
          INTO l_jb_status
          FROM w_jobs
         WHERE jb_id = p_jb_id;

        RETURN l_jb_status;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN '';
    END;
END IKIS_SYSWEB_JOBS;
/