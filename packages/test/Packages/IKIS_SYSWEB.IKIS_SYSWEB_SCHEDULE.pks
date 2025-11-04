/* Formatted on 8/12/2025 6:11:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.IKIS_SYSWEB_SCHEDULE
IS
    -- Author  : Frolov
    -- Created : 20080523
    -- Purpose : IKIS Web Scheduler Management System

    exInvCheckForInput   EXCEPTION;

    PROCEDURE SubmitSchedule (p_jb            OUT w_jobs.jb_id%TYPE,
                              p_subsys            VARCHAR2,
                              p_wjt               w_job_type.wjt_id%TYPE,
                              p_what              VARCHAR2,
                              p_nextdate          DATE DEFAULT SYSDATE,
                              p_interval          VARCHAR2 DEFAULT NULL,
                              p_schema_name       VARCHAR2 DEFAULT NULL,
                              p_end_date          DATE DEFAULT NULL,
                              p_isweb             INTEGER DEFAULT 1);

    --procedure EnableJob(p_jb in number); --YAP must use   *Job_Univ

    --+YAP 20081020 - замена врапилки
    PROCEDURE PrepareJob (p_jb         IN     w_jobs.jb_id%TYPE,
                          p_what       IN OUT VARCHAR2,
                          p_interval          VARCHAR2);

    PROCEDURE PostJob (p_jb IN w_jobs.jb_id%TYPE, p_interval VARCHAR2);

    PROCEDURE SetErrStatus (p_jb IN w_jobs.jb_id%TYPE, p_mess VARCHAR2);

    ---YAP 20081020

    PROCEDURE ScheduleWrap (p_jb         IN w_jobs.jb_id%TYPE,
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

    PROCEDURE GetAppData (p_jb     IN     w_jobs.jb_id%TYPE,
                          p_data      OUT w_jobs.jb_appdata%TYPE);

    PROCEDURE SaveAppData (p_data IN BLOB);

    PROCEDURE EraseAppData (p_ss_code   VARCHAR2,
                            p_wjt       VARCHAR2,
                            p_day       INTEGER);

    FUNCTION IsAppDataNotEmpty (p_jb IN w_jobs.jb_id%TYPE)
        RETURN BOOLEAN;

    FUNCTION IsJobInueue (p_jb IN w_jobs.jb_id%TYPE)
        RETURN BOOLEAN;

    /* procedure GetSchedulerParams(p_jb_id in w_jobs.jb_id%type, p_schp_opfu out varchar2,
                    p_schp_date_start out date, p_schp_charg_year out varchar2,
                    p_schp_rpt_rype out varchar2);

     procedure SetSchedulerParams(p_jb_id in w_jobs.jb_id%type, p_schp_opfu in varchar2,
                    p_schp_date_start in date, p_schp_charg_year in varchar2,
                    p_schp_rpt_rype in varchar2);
    */
    FUNCTION checkSchedulerStartTime (p_start_time    IN VARCHAR2,
                                      p_report_type   IN VARCHAR2)
        RETURN BOOLEAN;

    PROCEDURE EnableJobWithCheckParamCount (
        p_jb            IN NUMBER,
        p_param_count   IN NUMBER,
        p_raise_exptn   IN BOOLEAN DEFAULT TRUE);

    PROCEDURE AddJobParam (
        p_jb_id             IN w_jobs.jb_id%TYPE,
        p_sjp_Name             Scheduler_Job_Params.sjp_Name%TYPE,
        p_sjp_Value            Scheduler_Job_Params.sjp_Value%TYPE,
        p_sjp_Type             Scheduler_Job_Params.sjp_Type%TYPE,
        p_sjp_Format           Scheduler_Job_Params.sjp_Format%TYPE DEFAULT NULL,
        p_sjp_Req              Scheduler_Job_Params.Sjp_Req%TYPE DEFAULT 1,
        p_ReplaceExisting      BOOLEAN DEFAULT FALSE);

    FUNCTION GetJobParam (p_jb_id      IN w_jobs.jb_id%TYPE,
                          p_sjp_Name   IN Scheduler_Job_Params.sjp_Name%TYPE,
                          p_Raise      IN BOOLEAN DEFAULT FALSE)
        RETURN VARCHAR2;

    PROCEDURE EnableJob_Univ (p_jb IN NUMBER); --+ivanr.08.10.2008

    PROCEDURE DropJob_Univ (p_jb IN NUMBER); --+ivanr.08.10.2008

    PROCEDURE DisableJob_Univ (p_jb IN NUMBER); --+ivanr.08.10.2008

    -------------------
    -- + max 15.06.2017
    ---  Информация о джобе
    --------------------
    PROCEDURE GetStatus (p_jb     IN     w_jobs.jb_id%TYPE,
                         p_main      OUT SYS_REFCURSOR,
                         p_msg       OUT SYS_REFCURSOR);
-------------------
-- - max 15.06.2017
--------------------

END IKIS_SYSWEB_SCHEDULE;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_SYSWEB_SCHEDULE FOR IKIS_SYSWEB.IKIS_SYSWEB_SCHEDULE
/


GRANT EXECUTE ON IKIS_SYSWEB.IKIS_SYSWEB_SCHEDULE TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_SYSWEB_SCHEDULE TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_SYSWEB_SCHEDULE TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_SYSWEB_SCHEDULE TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_SYSWEB_SCHEDULE TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_SYSWEB_SCHEDULE TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_SYSWEB_SCHEDULE TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_SYSWEB_SCHEDULE TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_SYSWEB_SCHEDULE TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_SYSWEB_SCHEDULE TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_SYSWEB_SCHEDULE TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_SYSWEB_SCHEDULE TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:11:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.IKIS_SYSWEB_SCHEDULE
IS
    msgCOMMON_EXCEPTION       NUMBER := 2;
    msgAllInstanceExecuting   NUMBER := 6262;
    msgSessionNotFound        NUMBER := 6263;

    gJob                      w_jobs.jb_id%TYPE;
    gUserName                 VARCHAR2 (32760);

    exNotStopImmediately      EXCEPTION;
    PRAGMA EXCEPTION_INIT (exNotStopImmediately, -27365);
    exNotStopNotRun           EXCEPTION;
    PRAGMA EXCEPTION_INIT (exNotStopNotRun, -27366);
    exNotAJob                 EXCEPTION;
    PRAGMA EXCEPTION_INIT (exNotAJob, -27475);
    exNotACreateJob           EXCEPTION;
    PRAGMA EXCEPTION_INIT (exNotACreateJob, -27476);

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
                    'IKIS_SYSWEB_SCHEDULE.SaveMessage',
                    CHR (10) || SQLERRM));
    END;


    -- Процедура проставляет заданному джобу статус ERROR
    PROCEDURE SetErrStatus (p_jb IN w_jobs.jb_id%TYPE, p_mess VARCHAR2)
    IS
    BEGIN
        SetStatus (p_jb, ikis_const.V_DDN_WJB_ST_ERROR);
        SaveMessage (p_mess, 'E');
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
              FROM USER_SCHEDULER_RUNNING_JOBS x1, v_session x2
             WHERE x1.Session_id = x2.sid AND x1.job_name = l_job.jb_job_name;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RAISE exNotRuningJob;
            WHEN OTHERS
            THEN
                RAISE;
        END;

        DBMS_SCHEDULER.drop_job (job_name => l_job.jb_job_name, force => TRUE);

        COMMIT;
    EXCEPTION
        WHEN exNotRuningJob
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgSessionNotFound,
                    'IKIS_SYSWEB_SCHEDULE.StopJob',
                    CHR (10) || SQLERRM));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_SYSWEB_SCHEDULE.StopJob',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE SubmitSchedule (p_jb            OUT w_jobs.jb_id%TYPE,
                              p_subsys            VARCHAR2,
                              p_wjt               w_job_type.wjt_id%TYPE,
                              p_what              VARCHAR2,
                              p_nextdate          DATE DEFAULT SYSDATE,
                              p_interval          VARCHAR2 DEFAULT NULL,
                              p_schema_name       VARCHAR2 DEFAULT NULL,
                              p_end_date          DATE DEFAULT NULL, --+ivanr. 07.10.2008 доработки для работы с интервалами
                              p_isweb             INTEGER DEFAULT 1 -- +Kalev 15.04.2001 запуск из-под web`а
                                                                   )
    IS
        l_st              w_jobs.jb_status%TYPE;
        l_what            VARCHAR2 (32760);
        l_job_name        VARCHAR2 (255);
        l_startdate       DATE;
        l_com_org         w_jobs.com_org%TYPE;
        l_com_wu          w_jobs.com_wu%TYPE;
        l_job_tp          w_job_type%ROWTYPE;
        fl_AfterHour      BOOLEAN; -- флаг, что джоб будет запускатся отложенно
        l_cnt             INTEGER;
        fl_Limit          BOOLEAN;
        l_ShiftSec        INTEGER := 5 * 60; -- 5 минут. время сдвига отчета в очереди. В секундах (раньше было 5 секунд)
        l_startdate_max   DATE;
    BEGIN
        --  ikis_sysweb.ikis_debug_pipe.WriteMsg('ikis_sysweb.SubmitSchedule');

        fl_AfterHour := FALSE;
        fl_Limit := FALSE;
        l_startdate := p_nextdate;
        l_com_org :=
            CASE
                WHEN p_isweb = 1 THEN SYS_CONTEXT ('IKISWEBADM', 'OPFU')
                ELSE '28000'
            END;
        l_com_wu :=
            CASE
                WHEN p_isweb = 1 THEN SYS_CONTEXT ('IKISWEBADM', 'IKISUID')
                ELSE '0'
            END;

        SELECT *
          INTO l_job_tp
          FROM w_job_type wjt
         WHERE wjt.wjt_id = p_wjt;

        -- +Kalev аналіз на години запуску
        -- Отложенный запуск: если текущее время меньше указанного - то в очередь. Иначе - запускается сразу.
        BEGIN
            IF l_startdate IS NULL AND l_job_tp.wjt_after_hour IS NOT NULL
            THEN
                -- если указан отложенный запуск - проверяем время запуска и текущее время:
                CASE
                    WHEN   TO_CHAR (SYSDATE, 'hh24') * 60
                         + TO_CHAR (SYSDATE, 'mi') * 1 <
                           SUBSTR (l_job_tp.wjt_after_hour, 1, 2) * 60
                         + SUBSTR (l_job_tp.wjt_after_hour, 4, 2) * 1
                    THEN
                        BEGIN -- если количество минут текущего дня МЕНЬШЕ количество минут для старта (вычисляется как количество минут в указанном времени старта) - ставим отчет в очередь
                            l_startdate :=
                                TO_DATE (
                                       TO_CHAR (SYSDATE, 'dd.mm.yyyy')
                                    || ' '
                                    || l_job_tp.wjt_after_hour,
                                    'dd.mm.yyyy hh24:mi');
                            fl_AfterHour := TRUE;
                        END;                          -- иначе запускаем сразу
                    ELSE
                        l_startdate := SYSDATE;
                END CASE;

                -- корректировка времени с учетом очереди.
                -- считается кол-во таких же отчетов, ждущих в очереди, и сдвигается время запуска на их количесто * l_ShiftSec
                SELECT MAX (jb.jb_start_dt)
                  INTO l_startdate_max
                  FROM w_jobs jb
                 WHERE     jb.jb_wjt = p_wjt
                       AND jb.jb_status IN (ikis_const.v_ddn_wjb_st_enqueue)
                       AND jb.jb_start_dt >= l_startdate;

                IF l_startdate_max IS NOT NULL
                THEN
                    l_startdate :=
                        l_startdate_max + l_ShiftSec / (24 * 60 * 60);
                END IF;
            END IF;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        IF l_startdate IS NOT NULL
        THEN
            l_st := ikis_const.v_ddn_wjb_st_enqueue; -- Нету стартовой датой - ставим статус в очередь
        ELSE
            l_st := ikis_const.v_ddn_wjb_st_new; -- Иначе ставим статус "новый"
        END IF;

        IF p_schema_name IS NULL
        THEN                                         -- Создаем название джоба
            l_job_name := DBMS_SCHEDULER.generate_job_name ('WSJ$');
        ELSE
            l_job_name :=
                   p_schema_name
                || '.'
                || DBMS_SCHEDULER.generate_job_name ('WSJ$');
        END IF;

        -- Вставляем в таблицу новый джоб
        INSERT INTO w_jobs (jb_id,
                            jb_wjt,
                            jb_ss_code,
                            com_org,
                            com_wu,
                            jb_job_id,
                            jb_start_dt,
                            jb_stop_dt,
                            jb_status,
                            jb_appdata,
                            jb_job_name)
             VALUES (0,
                     p_wjt,
                     p_subsys,
                     l_com_org,
                     l_com_wu,
                     NULL,
                     NULL,
                     NULL,
                     l_st,
                     EMPTY_BLOB (),
                     l_job_name)
          RETURNING jb_id
               INTO p_jb;

        --+YAP 20081020 - замена, чтобы джоб вызывался с правами владельца прикладной схемы
        --l_what:='begin IKIS_SYSWEB_Schedule.ScheduleWrap('||p_jb||','''||p_what||''','''||p_interval||'''); end;';
        l_what :=
               'begin IKIS_SYSWEB.ScheduleWrap('
            || p_jb
            || ','''
            || p_what
            || ''','''
            || p_interval
            || '''); end;';
        ---YAP 20081020
        --ikis_sysweb.ikis_debug_pipe.WriteMsg('ikis_sysweb.ScheduleWrap.l_what:'||l_what);

        gJob := p_jb;

        -- +Kalev Если отложенный запуск и не центральный уровень - проверяем локи по отчетам
        IF fl_AfterHour AND SYS_CONTEXT ('IKISWEBADM', 'IUTP') NOT IN (1, 4)
        THEN
            SELECT COUNT (1)
              INTO l_cnt
              FROM w_jobs jb
             WHERE     jb.jb_wjt = p_wjt
                   AND (   l_job_tp.wjt_is_reg_lock <> 1
                        OR     l_job_tp.wjt_is_reg_lock = 1
                           AND jb.com_org = l_com_org)
                   AND (   l_job_tp.wjt_is_user_lock <> 1
                        OR     l_job_tp.wjt_is_user_lock = 1
                           AND jb.com_wu = l_com_wu)
                   AND jb.jb_status IN (ikis_const.v_ddn_wjb_st_enqueue)
                   AND jb.jb_id <> p_jb;

            fl_Limit := l_cnt >= l_job_tp.wjt_concur_cnt_lock;
        END IF;

        --+ivanr. 07.10.2008 -- доработки для работы с интервалами
        IF NOT fl_Limit
        THEN                 -- Если нету лимита - регистрируем джоб в системе
            DBMS_SCHEDULER.create_job (
                job_name          => l_job_name,
                job_type          => 'PLSQL_BLOCK',
                job_action        => l_what,
                start_date        => l_startdate,
                repeat_interval   => p_interval,
                end_date          => p_end_date,
                job_class         => 'DEFAULT_JOB_CLASS',
                enabled           => FALSE,
                auto_drop         => TRUE); --+YAP 20081024 - поменял на тру, ибо лень чистить
        END IF;

        --+ivanr. 07.10.2008
        UPDATE w_jobs
           SET jb_job_name = l_job_name
         WHERE jb_id = p_jb;

        -- +Kalev
        IF fl_AfterHour
        THEN
            UPDATE w_jobs
               SET jb_start_dt = l_startdate
             WHERE jb_id = p_jb;
        END IF;

        --
        COMMIT;

        -- +Kalev
        IF fl_AfterHour
        THEN
            IF NOT fl_Limit
            THEN
                SaveMessage (
                       'Запущено відкладене завдання. Час початку виконання завдання: '
                    || TO_CHAR (l_startdate, 'dd.mm.yyyy hh24:mi:ss'));
            ELSE
                SetErrStatus (
                    p_jb,
                    'Зареєструвати завдання неможливо: перевищено граничну кількість дозволенних завдань.');
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                   'IKIS_SYSWEB_SCHEDULE.SubmitSchedule: '
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    --raise;
    END;

    PROCEDURE EnableJob (p_jb IN NUMBER)
    IS
        l_job_name   w_jobs.jb_job_name%TYPE;
    BEGIN
        SELECT jb.jb_job_name
          INTO l_job_name
          --+ YAP 20081201 другие полиси тут будут from v_w_jobs jb
          FROM v_w_jobs_univ jb                               --- YAP 20081201
         WHERE jb.jb_id = p_jb;

        BEGIN
            DBMS_SCHEDULER.enable (l_job_name);
        EXCEPTION
            WHEN exNotACreateJob
            THEN
                NULL;
            WHEN OTHERS
            THEN
                RAISE;
        END;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_SYSWEB_SCHEDULE.EnableJob',
                    CHR (10) || 'Ідентифікатор завдання не визначений'));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'IKIS_SYSWEB_SCHEDULE.EnableJob: '
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE EnableJobWithCheckParamCount (
        p_jb            IN NUMBER,
        p_param_count   IN NUMBER,
        p_raise_exptn   IN BOOLEAN DEFAULT TRUE)
    IS
        l_prms_count   INTEGER;
        l_job_name     w_jobs.jb_job_name%TYPE;
    BEGIN
        -- проверяем соответствие количества параметров
        SELECT COUNT (*)
          INTO l_prms_count
          FROM scheduler_job_params sjp
         WHERE sjp.sjp_job = p_jb AND sjp.sjp_req = 1;

        IF l_prms_count = p_param_count
        THEN
            -- пытаемся "включить" job
            EnableJob (p_jb);
        ELSIF p_raise_exptn
        THEN
            -- если нужно - поднимаем exception:
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_SYSWEB_SCHEDULE.EnableJobWithCheckParamCount',
                       CHR (10)
                    || 'Не співпадає кількість параметрів завдання:'
                    || l_prms_count
                    || CHR (10)
                    || p_jb));
        END IF;
    END;

    --+YAP --внимание процедура не используется, см ikis_sysweb.ScheduleWrap
    PROCEDURE ScheduleWrap (p_jb         IN w_jobs.jb_id%TYPE,
                            p_what          VARCHAR2,
                            p_interval      VARCHAR2)
    IS
        l_lock             ikis_lock.t_lockhandler;
        l_lock_cont        ikis_lock.t_lockhandler;
        l_lock_cont1       ikis_lock.t_lockhandler;
        l_job              w_jobs%ROWTYPE;
        l_job_tp           w_job_type%ROWTYPE;
        l_lock_name        VARCHAR2 (100);
        l_err              VARCHAR2 (4000);
        l_receiving        BOOLEAN := FALSE;
        i                  NUMBER;
        j                  NUMBER;
        exNotReceiveSlot   EXCEPTION;
        l_job_params       VARCHAR2 (200);
        l_what             VARCHAR2 (300) := p_what;
        l_smc              VARCHAR2 (2);
        l_value            VARCHAR2 (100);
    BEGIN
        --+YAP 20081020
        raise_application_error (-20000, 'Depricated wrap schedule proc.');

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

        -- +Kalev юзер ЦА может стартовать неограниченно
        IF SYS_CONTEXT ('IKISWEBADM', 'IUTP') NOT IN (1, 4)
        THEN
            IF l_job_tp.wjt_is_reg_lock = 1
            THEN
                l_lock_name := l_lock_name || l_job.com_org;
            END IF;

            IF l_job_tp.wjt_is_user_lock = 1
            THEN
                l_lock_name := l_lock_name || l_job.com_wu;
            END IF;
        ELSE
            l_lock_name :=
                l_lock_name || TO_CHAR (SYSDATE, 'dd.mm.yyyy hh24:mi:ss');
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
            i := 1;

            LOOP                                         -- делаем три попытки
                j := 1;

                LOOP                   -- попытка получить слот для исполнения
                    BEGIN
                        ikis_lock.Request_Lock (
                            p_permanent_name      => 'IKISWEBJOBATLAS',
                            p_var_name            => l_lock_name || j,
                            p_errmessage          => 'XXX',
                            p_lockhandler         => l_lock_cont1,
                            p_lockmode            => 6,
                            p_timeout             => 0,
                            p_release_on_commit   => FALSE); --true sbond 20161101 было но внутри джоба коммит может быть
                        l_receiving := TRUE;
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            NULL;
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
                p_release_on_commit   => FALSE); --true sbond 20161101 было но внутри джоба коммит может быть
        END IF;

        SetStatus (p_jb, ikis_const.V_DDN_WJB_ST_RUNING);

        --+ vano 20190424
        --IKIS_WEB_CONTEXT.SetJobContext(l_job.jb_wjt);
        EXECUTE IMMEDIATE 'begin IKIS_WEB_CONTEXT.SetJobContext(:p1); end;'
            USING l_job.jb_wjt;

        --- vano 20190424

        -- +Frolov здесь формируются параметры процедуры, которую выполняем:
        FOR cJobPars IN (SELECT sjp.sjp_name,
                                sjp.sjp_value,
                                sjp.sjp_type,
                                sjp.sjp_format
                           FROM scheduler_job_params sjp
                          WHERE sjp.sjp_job = p_jb AND sjp.sjp_req = 1)
        LOOP
            SELECT DECODE (l_job_params, '', '', ' ,') INTO l_smc FROM DUAL;

            CASE UPPER (cJobPars.sjp_type)
                WHEN 'NUMBER'
                THEN
                    l_value := cJobPars.sjp_value;
                WHEN 'DATE'
                THEN
                    l_value :=
                           'to_date('''
                        || cJobPars.sjp_value
                        || ''','''
                        || cJobPars.sjp_format
                        || ''')';
                WHEN 'VARCHAR2'
                THEN
                    l_value := '' || cJobPars.sjp_value || '';
            END CASE;

            l_job_params :=
                   l_job_params
                || l_smc
                || cJobPars.sjp_name
                || ' => '
                || CASE
                       WHEN UPPER (cJobPars.sjp_type) = 'DATE' THEN l_value
                       ELSE '''' || l_value || ''''
                   END;
        END LOOP;

        -- +Frolov сделали параметры, конкатенация с названием процедуры:
        IF l_job_params IS NOT NULL
        THEN
            l_what := 'begin ' || p_what || '(' || l_job_params || '); end; ';
        END IF;

        -- +Frolov начинаем выполнять:
        DBMS_APPLICATION_INFO.set_module (module_name   => l_job.jb_wjt,
                                          action_name   => NULL);

        --ikis_sys.ikis_repl_util.startrepltrace(p_script => 'WJOB',
        --                                       p_direction => l_job.jb_wjt);

        EXECUTE IMMEDIATE l_what;

        SetStatus (p_jb, ikis_const.V_DDN_WJB_ST_ENDED);
        COMMIT;
        gUserName := NULL;


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
            l_err := 'Помилка виконання завдання: ' || SQLERRM;
            SetStatus (p_jb, ikis_const.V_DDN_WJB_ST_ERROR);
            SaveMessage (l_err, 'E');
            ROLLBACK;
    END;

    --+YAP 20081020 - замена врапилки
    PROCEDURE PrepareJob (p_jb         IN     w_jobs.jb_id%TYPE,
                          p_what       IN OUT VARCHAR2,
                          p_interval          VARCHAR2)
    IS
        l_lock             ikis_lock.t_lockhandler;
        l_lock_cont        ikis_lock.t_lockhandler;
        l_lock_cont1       ikis_lock.t_lockhandler;
        l_job              w_jobs%ROWTYPE;
        l_job_tp           w_job_type%ROWTYPE;
        l_lock_name        VARCHAR2 (100);
        l_err              VARCHAR2 (4000);
        l_receiving        BOOLEAN := FALSE;
        i                  NUMBER;
        j                  NUMBER;
        exNotReceiveSlot   EXCEPTION;
        l_job_params       VARCHAR2 (2000);
        --l_what              varchar2(300) := p_what;
        l_smc              VARCHAR2 (2);
        l_value            VARCHAR2 (200);
        l_sqlval           ikis_sysweb.scheduler_job_params.sjp_value%TYPE;
        l_sqlfmt           ikis_sysweb.scheduler_job_params.sjp_format%TYPE;
    BEGIN
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

        -- Здесь если пользователь не центрального уровня, то формируем название блокировки
        -- Если центрального, то название = текущее время. Но, так как появились отчеты с
        -- отложенным запуском, стартующие в один момент - получились грабли с запуском.
        -- Потом приравниваем пользователей центрального уровня к обычным
        -- 03.02.2012 - Eugen3d

        --  if sys_context('IKISWEBADM','IUTP') not in (1, 4) then
        l_lock_name := l_job.jb_wjt;

        IF l_job_tp.wjt_is_reg_lock = 1
        THEN
            l_lock_name := l_lock_name || l_job.com_org;
        END IF;

        IF l_job_tp.wjt_is_user_lock = 1
        THEN
            l_lock_name := l_lock_name || l_job.com_wu;
        END IF;

        --  else
        --    l_lock_name := l_lock_name || to_char(sysdate, 'dd.mm.yyyy hh24:mi:ss');
        --  end if;

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
            i := 1;

            LOOP                                         -- делаем три попытки
                j := 1;

                LOOP                   -- попытка получить слот для исполнения
                    BEGIN
                        ikis_lock.Request_Lock (
                            p_permanent_name      => 'IKISWEBJOBATLAS',
                            p_var_name            => l_lock_name || j,
                            p_errmessage          => 'XXX',
                            p_lockhandler         => l_lock_cont1,
                            p_lockmode            => 6,
                            p_timeout             => 0,
                            p_release_on_commit   => FALSE); --true sbond 20170206 было но внутри джоба коммит может быть
                        l_receiving := TRUE;
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            NULL;
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
                p_release_on_commit   => FALSE); --true sbond 20170206 было но внутри джоба коммит может быть
        END IF;

        SetStatus (p_jb, ikis_const.V_DDN_WJB_ST_RUNING);

        --+ vano 20190424
        --IKIS_WEB_CONTEXT.SetJobContext(l_job.jb_wjt);
        EXECUTE IMMEDIATE 'begin IKIS_WEB_CONTEXT.SetJobContext(:p1); end;'
            USING l_job.jb_wjt;

        --- vano 20190424

        --ikis_sys.ikis_repl_util.startrepltrace(p_script => 'WJOB',
        --                                       p_direction => l_job.jb_wjt);

        -- +Frolov здесь формируются параметры процедуры, которую выполняем:
        FOR cJobPars IN (SELECT sjp.sjp_name,
                                sjp.sjp_value,
                                sjp.sjp_type,
                                sjp.sjp_format
                           FROM scheduler_job_params sjp
                          WHERE sjp.sjp_job = p_jb AND sjp.sjp_req = 1)
        LOOP
            SELECT DECODE (l_job_params, '', '', ' ,') INTO l_smc FROM DUAL;

            l_sqlval := cJobPars.sjp_value;
            l_sqlfmt := cJobPars.sjp_format;

            CASE UPPER (cJobPars.sjp_type)
                WHEN 'NUMBER'
                THEN
                    BEGIN
                        IKIS_HTMLDB_COMMON.ChkNumber (l_sqlval);
                        l_value := l_sqlval;
                    END;
                WHEN 'DATE'
                THEN
                    BEGIN
                        IKIS_HTMLDB_COMMON.ChkDate (l_sqlval, l_sqlfmt);
                        l_value :=
                               'to_date('''
                            || l_sqlval
                            || ''','''
                            || l_sqlfmt
                            || ''')';
                    END;
                WHEN 'VARCHAR2'
                THEN
                    BEGIN
                        IKIS_HTMLDB_COMMON.ChkVarchar2 (l_sqlval);
                        l_value := '' || l_sqlval || '';
                    END;
            END CASE;

            --l_job_params := l_job_params || l_smc || cJobPars.sjp_name || ' => ' || '''' || l_value || '''';
            l_job_params :=
                   l_job_params
                || l_smc
                || cJobPars.sjp_name
                || ' => '
                || CASE
                       WHEN UPPER (cJobPars.sjp_type) = 'DATE' THEN l_value
                       ELSE '''' || l_value || ''''
                   END;
        END LOOP;

        -- +Frolov сделали параметры, конкатенация с названием процедуры:
        IF l_job_params IS NOT NULL
        THEN
            p_what := 'begin ' || p_what || '(' || l_job_params || '); end; ';
        ELSE
            p_what := 'begin ' || RTRIM (p_what, ';') || '; end;'; --YAP 20081020 - для общности
        END IF;

        -- +Frolov начинаем выполнять:
        DBMS_APPLICATION_INFO.set_module (module_name   => l_job.jb_wjt,
                                          action_name   => NULL);
    EXCEPTION
        WHEN IKIS_HTMLDB_COMMON.exInvalidCheckForInput
        THEN
            ROLLBACK;
            RAISE exInvCheckForInput;
        WHEN exNotReceiveSlot
        THEN
            SetStatus (p_jb, ikis_const.V_DDN_WJB_ST_ERROR);
            SaveMessage (
                ikis_message_util.GET_MESSAGE (msgAllInstanceExecuting,
                                               l_job_tp.wjt_concur_cnt_lock),
                'E');
            ROLLBACK;
            RAISE;
    END;

    PROCEDURE PostJob (p_jb IN w_jobs.jb_id%TYPE, p_interval VARCHAR2)
    IS
    BEGIN
        SetStatus (p_jb, ikis_const.V_DDN_WJB_ST_ENDED);
        COMMIT;
        gUserName := NULL;


        IF p_interval IS NOT NULL
        THEN
            SetStatus (p_jb, ikis_const.V_DDN_WJB_ST_ENQUEUE);
        END IF;
    END;

    ---YAP 20081020

    -------------------
    -- + max 15.06.2017
    --------------------
    PROCEDURE GetStatus (p_jb     IN     w_jobs.jb_id%TYPE,
                         p_main      OUT SYS_REFCURSOR,
                         p_msg       OUT SYS_REFCURSOR)
    IS
        l_start    DATE;
        l_stop     DATE;
        l_status   VARCHAR2 (100);
        l_module   VARCHAR2 (100);
        l_action   VARCHAR2 (100);
        l_job      VARCHAR2 (30);
        l_st       VARCHAR2 (100);
    BEGIN
        --ikis_sysweb.ikis_debug_pipe.WriteMsg(p_jb);
        SELECT x1.jb_start_dt,
               x1.jb_stop_dt,
               d1.DIC_SNAME,
               x1.jb_job_name,
               jb_status
          INTO l_start,
               l_stop,
               l_status,
               l_job,
               l_st
          FROM --+ YAP 20081201 другие полиси тут будут v_w_jobs x1,
               v_w_jobs_univ x1,                              --- YAP 20081201
                                 v_ddn_wjb_st d1
         WHERE x1.jb_id = p_jb AND x1.jb_status = d1.DIC_VALUE;

        BEGIN
            SELECT x3.MODULE, x3.ACTION
              INTO l_module, l_action
              FROM USER_SCHEDULER_RUNNING_JOBS x2, v_session x3
             WHERE l_job = x2.JOB_name AND x2.Session_id = x3.SID;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        --ikis_sysweb.ikis_debug_pipe.WriteMsg('ok');

        OPEN p_main FOR
            SELECT l_start      start_dt,
                   l_stop       stop_dt,
                   l_status     status,
                   l_job        job,
                   l_module     module,
                   l_action     action,
                   l_st         status_code
              FROM DUAL;

        OPEN p_msg FOR
              SELECT x1.*,
                     x2.*,
                     DECODE (X2.jm_tp,
                             'I', 'ІНФО',
                             'E', 'ПОМИЛКА',
                             'W', 'ПОПЕРЕДЖЕННЯ',
                             '-')    MES_TP_STR
                FROM --+ YAP 20081201 другие полиси тут будут v_w_jobs x1,
                     v_w_jobs_univ x1,                        --- YAP 20081201
                                       w_jobs_protocol x2
               WHERE x1.jb_id = x2.jm_jb AND x1.jb_id = p_jb
            ORDER BY x2.jm_ts;
    END;

    -------------------
    -- - max 15.06.2017
    --------------------

    PROCEDURE PrintStatus (p_jb IN w_jobs.jb_id%TYPE)
    IS
        l_start    DATE;
        l_stop     DATE;
        l_status   VARCHAR2 (100);
        l_module   VARCHAR2 (100);
        l_action   VARCHAR2 (100);
        l_job      VARCHAR2 (30);
    BEGIN
        -- +Frolov 02.04.2008 Добавил обработчик исключиений
        BEGIN
            SELECT x1.jb_start_dt,
                   x1.jb_stop_dt,
                   d1.DIC_SNAME,
                   x1.jb_job_name
              INTO l_start,
                   l_stop,
                   l_status,
                   l_job
              FROM --+ YAP 20081201 другие полиси тут будут v_w_jobs x1,
                   v_w_jobs_univ x1,                          --- YAP 20081201
                                     v_ddn_wjb_st d1
             WHERE x1.jb_id = p_jb AND x1.jb_status = d1.DIC_VALUE;
        EXCEPTION
            WHEN OTHERS
            THEN
                raise_application_error (
                    -20000,
                    ikis_message_util.GET_MESSAGE (
                        msgCOMMON_EXCEPTION,
                        'IKIS_SYSWEB_SCHEDULE.PrintStatus',
                        CHR (10) || SQLERRM));
        END;

        -- -Frolov
        BEGIN
            SELECT x3.MODULE, x3.ACTION
              INTO l_module, l_action
              FROM USER_SCHEDULER_RUNNING_JOBS x2, v_session x3
             WHERE l_job = x2.JOB_name AND x2.Session_id = x3.SID;
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
                    FROM --+ YAP 20081201 другие полиси тут будут v_w_jobs x1,
                         v_w_jobs_univ x1,                    --- YAP 20081201
                                           w_jobs_protocol x2
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

    PROCEDURE DownloadAppData (
        p_wjt           w_job_type.wjt_id%TYPE,
        p_jb         IN w_jobs.jb_id%TYPE DEFAULT NULL,
        p_filename   IN w_job_type.wjt_file_name%TYPE DEFAULT NULL)
    IS
        l_rpt       BLOB;
        l_content   w_job_type.wjt_content_type%TYPE;
        l_file      w_job_type.wjt_file_name%TYPE;
    BEGIN
        IF p_jb IS NULL
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_SYSWEB_SCHEDULE.DownloadAppData',
                    CHR (10) || ': не вказан ідентифікатор завдання!'));
        END IF;

        BEGIN
            SELECT jb_appdata, wjt_content_type, wjt_file_name
              INTO l_rpt, l_content, l_file
              FROM --+ YAP 20081201 другие полиси тут будут v_w_jobs,
                   v_w_jobs_univ,                             --- YAP 20081201
                                  w_job_type
             WHERE wjt_id = jb_wjt AND jb_id = p_jb;

            IF (p_filename IS NOT NULL)
            THEN
                l_file := p_filename;
            END IF;

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
                        'IKIS_SYSWEB_SCHEDULE.DownloadAppData',
                        CHR (10) || SQLERRM));
        END;
    END;

    -- +Kalev 20110512 отримання чистих даних
    PROCEDURE GetAppData (p_jb     IN     w_jobs.jb_id%TYPE,
                          p_data      OUT w_jobs.jb_appdata%TYPE)
    IS
    BEGIN
        SELECT jb.jb_appdata
          INTO p_data
          FROM w_jobs jb
         WHERE jb.jb_id = p_jb;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_SYSWEB_SCHEDULE.GetAppData',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE SaveAppData (p_data IN BLOB)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
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
                    'IKIS_SYSWEB_SCHEDULE.SaveAppData',
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
                    'IKIS_SYSWEB_SCHEDULE.EraseAppData',
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

    /*procedure GetSchedulerParams(p_jb_id in w_jobs.jb_id%type,
                                p_schp_opfu out varchar2,
                                p_schp_date_start out date,
                                p_schp_charg_year out varchar2,
                                p_schp_rpt_rype out varchar2) is
    begin
      select schp.schp_opfu,
             schp.schp_date_start,
             schp.schp_charg_year,
             schp.schp_rpt_rype
        into p_schp_opfu,
             p_schp_date_start,
             p_schp_charg_year,
             p_schp_rpt_rype
        from w_scheduler_params schp
       where schp.schp_job_id = p_jb_id;
    exception
      when others then
        p_schp_opfu := null;
        p_schp_date_start := null;
        p_schp_charg_year := null;
        p_schp_rpt_rype := null;
    end;*/


    FUNCTION checkSchedulerStartTime (p_start_time    IN VARCHAR2,
                                      p_report_type   IN VARCHAR2)
        RETURN BOOLEAN
    IS
        l_cnt    INTEGER;
        l_date   DATE;
    BEGIN
        l_date := TO_DATE (p_start_time, 'DD/MM/YYYY HH24:MI');
        DBMS_OUTPUT.put_line (TO_CHAR (l_date, 'DD.MM.YYYY HH24:MI:SS'));

        IF     TRUNC (l_date) IN (TRUNC (SYSDATE), TRUNC (SYSDATE + 1))
           AND l_date >= SYSDATE
        THEN
            DBMS_OUTPUT.put_line ('in if');

            SELECT COUNT (*)
              INTO l_cnt
              FROM w_scheduler_start_time sst
             WHERE     TO_DATE (
                              TO_CHAR (SYSDATE, 'DD.MM.YYYY ')
                           || TO_CHAR (l_date, 'HH24:MI:SS'),
                           'DD.MM.YYYY HH24:MI:SS') BETWEEN TO_DATE (
                                                                   TO_CHAR (
                                                                       SYSDATE,
                                                                       'DD.MM.YYYY ')
                                                                || sst.sst_time_beg,
                                                                'DD.MM.YYYY HH24:MI:SS')
                                                        AND TO_DATE (
                                                                   TO_CHAR (
                                                                       SYSDATE,
                                                                       'DD.MM.YYYY ')
                                                                || sst.sst_time_end,
                                                                'DD.MM.YYYY HH24:MI:SS')
                   AND sst.sst_rpt_type = p_report_type;

            DBMS_OUTPUT.put_line (
                   l_cnt
                || ' '
                || TO_CHAR (SYSDATE, 'DD.MM.YYYY ')
                || TO_CHAR (l_date, 'HH24:MI:SS'));
            RETURN l_cnt > 0;
        END IF;

        RETURN FALSE;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                       'IKIS_SYSWEB_SCHEDULE.checkSchedulerStartTime: '
                    || 'Помилка під час перевірки параметрів звіту:'
                    || CHR (10)
                    || SQLERRM));
    END;

    /*procedure SetSchedulerParams(p_jb_id in w_jobs.jb_id%type,
                                p_schp_opfu in varchar2,
                                p_schp_date_start in date,
                                p_schp_charg_year in varchar2,
                                p_schp_rpt_rype in varchar2) is
      l_replace integer;
      pragma autonomous_transaction;
    begin
      select count(schp.schp_job_id)
        into l_replace
        from w_scheduler_params schp
       where schp.schp_job_id = p_jb_id;
       if l_replace > 0 then
         update w_scheduler_params schp
            set schp.schp_opfu = p_schp_opfu,
                schp.schp_date_start = p_schp_date_start,
                schp.schp_charg_year = p_schp_charg_year,
                schp.schp_rpt_rype = p_schp_rpt_rype
          where schp.schp_job_id = p_jb_id;
       else
       insert into w_scheduler_params
        (schp_id, schp_job_id, schp_opfu, schp_date_start, schp_charg_year, schp_rpt_rype)
       values
        (0, p_jb_id, p_schp_opfu, p_schp_date_start, p_schp_charg_year, p_schp_rpt_rype);
       end if;
       commit;
    end;*/

    PROCEDURE AddJobParam (
        p_jb_id             IN w_jobs.jb_id%TYPE,
        p_sjp_Name             Scheduler_Job_Params.sjp_Name%TYPE,
        p_sjp_Value            Scheduler_Job_Params.sjp_Value%TYPE,
        p_sjp_Type             Scheduler_Job_Params.sjp_Type%TYPE,
        p_sjp_Format           Scheduler_Job_Params.sjp_Format%TYPE DEFAULT NULL,
        p_sjp_Req              Scheduler_Job_Params.Sjp_Req%TYPE DEFAULT 1,
        p_ReplaceExisting      BOOLEAN DEFAULT FALSE)
    IS
        l_replace   INTEGER;
        l_date      VARCHAR2 (30);
    BEGIN
        SELECT COUNT (sjp.sjp_id)
          INTO l_replace
          FROM scheduler_job_params sjp
         WHERE sjp.sjp_job = p_jb_id AND sjp.sjp_name = p_sjp_name;

        IF l_replace > 0 AND NOT p_ReplaceExisting
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                       'IKIS_SYSWEB_SCHEDULE.AddJobParam: '
                    || 'Спроба створити вже існуючий параметр! '));
        ELSE
            IF l_replace > 0
            THEN
                UPDATE scheduler_job_params sjp
                   SET sjp.sjp_value = p_sjp_Value,
                       sjp.sjp_type = p_sjp_type,
                       sjp.sjp_format = p_sjp_Format,
                       sjp.sjp_req = p_sjp_Req
                 WHERE sjp.sjp_job = p_jb_id AND sjp.sjp_name = p_sjp_Name;
            ELSE
                IF p_sjp_Type = 'DATE' AND p_sjp_Format IS NOT NULL
                THEN
                    l_date :=
                        TO_CHAR (TO_DATE (p_sjp_Value, p_sjp_Format),
                                 p_sjp_Format);
                END IF;

                INSERT INTO scheduler_job_params (sjp_id,
                                                  sjp_name,
                                                  sjp_value,
                                                  sjp_type,
                                                  sjp_format,
                                                  sjp_job,
                                                  sjp_req)
                     VALUES (0,
                             p_sjp_name,
                             DECODE (l_date, '', p_sjp_value, l_date),
                             p_sjp_type,
                             p_sjp_format,
                             p_jb_id,
                             p_sjp_req);
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                       'IKIS_SYSWEB_SCHEDULE.AddJobParam: '
                    || 'Помилка під час додавання параметрів звіту:'
                    || '<br>'
                    || SQLERRM
                    || '<br>'
                    || p_sjp_Name
                    || '<br>'
                    || p_sjp_Value
                    || '<br>|'
                    || p_sjp_Format
                    || '|'));
    END;

    FUNCTION GetJobParam (p_jb_id      IN w_jobs.jb_id%TYPE,
                          p_sjp_Name   IN Scheduler_Job_Params.sjp_Name%TYPE,
                          p_Raise      IN BOOLEAN DEFAULT FALSE)
        RETURN VARCHAR2
    IS
        l_value    VARCHAR2 (100);
        l_type     VARCHAR2 (10);
        l_format   VARCHAR2 (30);
    BEGIN
        SELECT sjp.sjp_value, sjp.sjp_type, sjp.sjp_format
          INTO l_value, l_type, l_format
          FROM scheduler_job_params sjp
         WHERE sjp.sjp_job = p_jb_id AND sjp.sjp_name = p_sjp_name;

        CASE
            WHEN l_type = 'NUMBER'
            THEN
                NULL;
            WHEN l_type = 'DATE'
            THEN
                IF l_format IS NOT NULL
                THEN
                    l_value :=
                        TO_CHAR (TO_DATE (l_value, l_format), l_format);
                END IF;
            WHEN l_type = 'VARCHAR2'
            THEN
                NULL;
            ELSE
                IF p_Raise
                THEN
                    raise_application_error (
                        -20000,
                        ikis_message_util.GET_MESSAGE (
                            msgCOMMON_EXCEPTION,
                               'IKIS_SYSWEB_SCHEDULE.GetJobParam: '
                            || 'Значення типу параметру не визначено!'));
                    RETURN NULL;
                END IF;
        END CASE;

        RETURN (l_value);
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            IF p_Raise
            THEN
                raise_application_error (
                    -20000,
                    ikis_message_util.GET_MESSAGE (
                        msgCOMMON_EXCEPTION,
                           'IKIS_SYSWEB_SCHEDULE.GetJobParam: '
                        || 'Спроба отримати значення неіснуючого параметру:'
                        || p_sjp_Name));
            END IF;

            RETURN NULL;
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

    --+ivanr 08.10.2008 доработки процедур по управлению шедулером
    PROCEDURE EnableJob_Univ (p_jb IN NUMBER)
    IS
        l_job_name   w_jobs.jb_job_name%TYPE;
    BEGIN
        SELECT jb.jb_job_name
          INTO l_job_name
          FROM v_w_jobs_univ jb
         WHERE jb.jb_id = p_jb;

        BEGIN
            DBMS_SCHEDULER.enable (l_job_name);
        EXCEPTION
            WHEN exNotACreateJob
            THEN
                NULL;
            WHEN OTHERS
            THEN
                RAISE;
        END;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_SYSWEB_SCHEDULE.EnableJob_Univ',
                    CHR (10) || 'Ідентифікатор завдання не визначений'));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'IKIS_SYSWEB_SCHEDULE.EnableJob_Univ: '
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE DropJob_Univ (p_jb IN NUMBER)
    IS
        l_job_name   w_jobs.jb_job_name%TYPE;
        l_flDrop     BOOLEAN;
    BEGIN
        SELECT jb.jb_job_name
          INTO l_job_name
          FROM v_w_jobs_univ jb
         WHERE jb.jb_id = p_jb;

        -- +Kalev сперва необходимо тормозить, а затем прибивать
        l_flDrop := TRUE;

        BEGIN
            DBMS_SCHEDULER.stop_job (l_job_name);
        EXCEPTION
            WHEN exNotStopImmediately
            THEN
                l_flDrop := FALSE;
            WHEN exNotStopNotRun
            THEN
                NULL;
            WHEN exNotAJob
            THEN
                NULL;
            WHEN OTHERS
            THEN
                RAISE;
        END;

        IF l_flDrop
        THEN
            BEGIN
                DBMS_SCHEDULER.drop_job (l_job_name);
            EXCEPTION
                WHEN exNotAJob
                THEN
                    NULL;
                WHEN OTHERS
                THEN
                    RAISE;
            END;
        END IF;

        --  +Kalev полная зачистка
        DELETE FROM scheduler_job_params sjp
              WHERE sjp.sjp_job = p_jb;

        DELETE FROM w_jobs_protocol jm
              WHERE jm.jm_jb = p_jb;

        DELETE FROM v_w_jobs_univ jb
              WHERE jb.jb_id = p_jb;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_SYSWEB_SCHEDULE.DropJob_Univ',
                    CHR (10) || 'Ідентифікатор завдання не визначений'));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'IKIS_SYSWEB_SCHEDULE.DropJob_Univ: '
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE DisableJob_Univ (p_jb IN NUMBER)
    IS
        l_job_name   w_jobs.jb_job_name%TYPE;
    BEGIN
        SELECT jb.jb_job_name
          INTO l_job_name
          FROM v_w_jobs_univ jb
         WHERE jb.jb_id = p_jb;

        DBMS_SCHEDULER.disable (l_job_name);
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_SYSWEB_SCHEDULE.DisableJob_Univ',
                    CHR (10) || 'Ідентифікатор завдання не визначений'));
    END;
---ivanr 08.10.2008
END IKIS_SYSWEB_SCHEDULE;
/