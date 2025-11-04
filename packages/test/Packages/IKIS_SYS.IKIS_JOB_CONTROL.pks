/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_JOB_CONTROL
    AUTHID CURRENT_USER
IS
    -- Author  : YURA_A
    -- Created : 07.09.2003 12:33:23
    -- Purpose : Управление заданиями

    cNA   CONSTANT VARCHAR2 (3) := 'N/A';

    --Процедура ставится в очередь и непосредственно исполняєт обработку файлов
    PROCEDURE Execute_JOB (p_fj_id file_job.fj_id%TYPE);

    --Исполнить немедленно
    PROCEDURE Force_Job (p_fj_id file_job.fj_id%TYPE);

    --Процедура установки в очередь задания
    PROCEDURE Submit_Job (p_fj_id       file_job.fj_id%TYPE,
                          p_next_date   VARCHAR2,
                          p_interval    VARCHAR2);

    ----------------------------------------
    -- ABVER 06.08.2003 11:06:26
    ----------------------------------------
    -- Назначение :
    --            Создает задачу и ставит ее в очередь на сейчас
    -- Параметры  :
    --            p_fj_id    - ид создаваемой задачи
    --            p_fj_ft    - тип создаваемой задачи
    --            p_params   - список имя параметра=значение в двойных кавычках через запятую
    --            передавать значение константы cNA если нету параметров
    --            p_interval - интервал между запусками данной задачи
    PROCEDURE CreateSubmited_Job (
        p_fj_id      OUT file_job.fj_id%TYPE,
        p_fj_ft          file_job.fj_ft%TYPE,
        p_params         VARCHAR2 DEFAULT cNA,
        p_interval       dba_jobs.interval%TYPE DEFAULT NULL);

    --Снять задание
    PROCEDURE Remove_Job (p_fj_id file_job.fj_id%TYPE);

    --Запретить исполнение
    PROCEDURE Disable_Job (p_fj_id file_job.fj_id%TYPE);

    ----------------------------------------
    -- KYB 10.11.2003 12:36:13
    ----------------------------------------
    -- Назначение : Снять задание и удалить его из file_job
    PROCEDURE Full_Remove_Job (p_fj_id file_job.fj_id%TYPE);
END IKIS_JOB_CONTROL;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_JOB_CONTROL FOR IKIS_SYS.IKIS_JOB_CONTROL
/


GRANT EXECUTE ON IKIS_SYS.IKIS_JOB_CONTROL TO II01RC_IKIS_COMMON
/

GRANT EXECUTE ON IKIS_SYS.IKIS_JOB_CONTROL TO II01RC_IKIS_JOB
/

GRANT EXECUTE ON IKIS_SYS.IKIS_JOB_CONTROL TO II01RC_IKIS_JOB_EXEC
/

GRANT EXECUTE ON IKIS_SYS.IKIS_JOB_CONTROL TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_JOB_CONTROL TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_JOB_CONTROL TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_JOB_CONTROL TO IKIS_SYSWEB
/

GRANT EXECUTE ON IKIS_SYS.IKIS_JOB_CONTROL TO SYSTEM
/

GRANT EXECUTE ON IKIS_SYS.IKIS_JOB_CONTROL TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_JOB_CONTROL TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_JOB_CONTROL TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_JOB_CONTROL TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_JOB_CONTROL TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_JOB_CONTROL TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_JOB_CONTROL TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_JOB_CONTROL TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_JOB_CONTROL TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:10:03 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_JOB_CONTROL
IS
    lockhandle               VARCHAR2 (100);


    eJobNotFound             EXCEPTION;
    PRAGMA EXCEPTION_INIT (eJobNotFound, -23421);

    -- Messages for category: IKIS_FILE_JOB_PKG
    msgEmptyAtribut          NUMBER := 98;
    msgInvalidFileType       NUMBER := 410;
    msgReqModeLock           NUMBER := 411;
    msgInvalidParTp          NUMBER := 412;
    msgErroSubmitJob         NUMBER := 414;
    msgErrorExec             NUMBER := 415;
    msgInvalidStForce        NUMBER := 416;
    msgCantModifyNotOwnJob   NUMBER := 1221;

    PROCEDURE Execute_JOB (p_fj_id file_job.fj_id%TYPE)
    IS
        l_pkg_name    file_type.ft_pkg_name%TYPE;
        l_proc_name   file_type.ft_proc_name%TYPE;
        l_tp          file_type.ft_tp%TYPE;
        l_mode        file_type.ft_mode%TYPE;
        l_job         file_job.fj_job%TYPE;
        l_owner       ikis_subsys.ss_owner%TYPE;
        res           NUMBER;
        l_templ       VARCHAR2 (32760)
            := 'begin %<OWNER>%.%<PKGNM>%.%<PROCNM>% %<PARLST>% end;';
        l_parlst      VARCHAR2 (10000) := NULL;
        l_value       VARCHAR2 (10000);
        l_exec_flag   BOOLEAN := TRUE;
        l_msg         VARCHAR2 (2000);
    BEGIN
        --+ Автор: YURA_A 27.02.2004 14:17:50
        --  Описание: Включение сеанса трассировки
        debug.init;
        debug.f ('start execute ikis job');
        --- Автор: YURA_A 27.02.2004 14:17:52

        ikis_file_job_pkg.SetCurrenJob (p_fj_id);

        --ikis_file_job_pkg.savejobmessage('I','1');
        BEGIN
            SELECT a.ft_pkg_name,
                   a.ft_proc_name,
                   a.ft_tp,
                   a.ft_mode,
                   b.fj_job,
                   c.ss_owner
              INTO l_pkg_name,
                   l_proc_name,
                   l_tp,
                   l_mode,
                   l_job,
                   l_owner
              FROM file_type a, file_job b, ikis_subsys c
             WHERE     a.ft_id = b.fj_ft
                   AND b.fj_id = p_fj_id
                   AND a.ft_ss_code = c.ss_code;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                raise_application_error (
                    -20000,
                    ikis_message_util.GET_MESSAGE (msgInvalidFileType));
            WHEN OTHERS
            THEN
                RAISE;
        END;

        --ikis_file_job_pkg.savejobmessage('I','2');
        debug.f ('allocate unique lockhandle');
        DBMS_LOCK.ALLOCATE_UNIQUE (IKIS_LOCK.lFILE_JOB_EXECUTE || l_tp,
                                   lockhandle);
        --ikis_file_job_pkg.savejobmessage('I','3');
        debug.f ('set job status');
        ikis_file_job_pkg.SetFileJobState (p_fj_id,
                                           ikis_const.v_dds_job_st_executing);
        --ikis_file_job_pkg.savejobmessage('I','4');
        debug.f ('request lock');

        IF NOT (DBMS_LOCK.REQUEST (lockhandle, TO_NUMBER (l_mode), 1) = 0)
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgReqModeLock, l_mode));
        END IF;

        --ikis_file_job_pkg.savejobmessage('I','5');
        l_templ :=
            REPLACE (
                REPLACE (REPLACE (l_templ, '%<PKGNM>%', l_pkg_name),
                         '%<PROCNM>%',
                         l_proc_name),
                '%<OWNER>%',
                l_owner);
        debug.f ('job command line: %s', l_templ);

        --ikis_file_job_pkg.savejobmessage('I','6');
        --+ Автор: ABVER 05.08.2003 15:45:22
        --  Описание: Добавлена проверка на присутсвие обязательных параметров
        --
        --  for r_par in (select ftp_name,
        --                       ftp_data_type,
        --                       ftpv_value,
        --                       ftpv_fj,
        --                       ftp_data_fmt
        --                  from file_type_parameter,
        --                       file_par_value
        --                 where ftp_id = ftpv_ftp
        --                   and ftpv_fj=p_fj_id) loop
        FOR r_par IN (SELECT ftp_name,
                             ftp_data_type,
                             ftpv_value,
                             ftpv_fj,
                             ftp_data_fmt,
                             ftp_mandatory
                        FROM file_type_parameter, file_par_value
                       WHERE ftp_id = ftpv_ftp AND ftpv_fj = p_fj_id)
        LOOP
            debug.f ('create job parameter: %s', r_par.ftp_name);

            IF     r_par.ftp_mandatory = ikis_const.V_DDS_YN_Y
               AND r_par.ftpv_value IS NULL
            THEN
                raise_application_error (
                    -20000,
                    IKIS_MESSAGE_UTIL.GET_MESSAGE (msgEmptyAtribut,
                                                   r_par.ftp_name));
            END IF;

            --- Автор: ABVER 05.08.2003 15:45:26
            CASE UPPER (r_par.ftp_data_type)
                WHEN 'NUMBER'
                THEN
                    l_value := r_par.ftpv_value;
                WHEN 'DATE'
                THEN
                    l_value :=
                           'to_date('''
                        || r_par.ftpv_value
                        || ''','''
                        || r_par.ftp_data_fmt
                        || ''')';
                WHEN 'VARCHAR2'
                THEN
                    l_value := '''' || r_par.ftpv_value || '''';
                ELSE
                    raise_application_error (
                        -20000,
                        IKIS_MESSAGE_UTIL.GET_MESSAGE (msgInvalidParTp,
                                                       r_par.ftp_data_type));
            END CASE;

            l_parlst :=
                l_parlst || r_par.ftp_name || ' => ' || l_value || ',';
            debug.f ('created job parameter: %s',
                     r_par.ftp_name || ' => ' || l_value);
        END LOOP;

        --ikis_file_job_pkg.savejobmessage('I','7');


        l_parlst := RTRIM (l_parlst, ',');

        IF l_parlst IS NOT NULL
        THEN
            l_templ :=
                REPLACE (l_templ, '%<PARLST>%', '(' || l_parlst || ');');
        ELSE
            l_templ := REPLACE (l_templ, '%<PARLST>%', ';');
        END IF;

        --ikis_file_job_pkg.savejobmessage('I','8');
        --execute immediate 'begin '||l_pkg_name||'.'||l_proc_name||'; end;';
        DBMS_APPLICATION_INFO.set_module (l_pkg_name || '.' || l_proc_name,
                                          'EXECUTE');
        DBMS_APPLICATION_INFO.set_client_info (l_templ);
        --ikis_file_job_pkg.savejobmessage('I','9');
        debug.f ('begin execute job');

        BEGIN
            EXECUTE IMMEDIATE l_templ;
        EXCEPTION
            WHEN OTHERS
            THEN
                l_msg := SQLERRM;
                l_exec_flag := FALSE;
                debug.f ('exception execute', l_msg);
        END;

        --ikis_file_job_pkg.savejobmessage('I','10');
        debug.f ('release lock');
        res := DBMS_LOCK.RELEASE (lockhandle);

        --ikis_file_job_pkg.savejobmessage('I','11');
        SELECT COUNT (job)
          INTO res
          FROM v_dba_jobs
         WHERE job = l_job AND NOT (UPPER (v_dba_jobs.interval) = 'NULL');

        IF res > 0
        THEN
            IF NOT l_exec_flag
            THEN
                ikis_file_job_pkg.SaveException (
                    p_fj_id,
                    ikis_const.v_dds_message_tp_e,
                    l_msg);
            END IF;

            ikis_file_job_pkg.SetFileJobState (
                p_fj_id,
                ikis_const.v_dds_job_st_waitnext);
            debug.f ('job waiting next start');
        ELSE
            IF NOT l_exec_flag
            THEN
                raise_application_error (
                    -20000,
                    IKIS_MESSAGE_UTIL.GET_MESSAGE (msgErrorExec,
                                                   CHR (10) || l_msg));
            END IF;

            ikis_file_job_pkg.SetFileJobState (
                p_fj_id,
                ikis_const.v_dds_job_st_complite);
            debug.f ('job complete');
        END IF;

        --ikis_file_job_pkg.savejobmessage('I','12');
        debug.f ('end execute job');
    EXCEPTION
        WHEN OTHERS
        THEN
            BEGIN
                ikis_file_job_pkg.SetFileJobState (
                    p_fj_id,
                    ikis_const.v_dds_job_st_errorexec);
                ikis_file_job_pkg.SaveException (
                    p_fj_id,
                    ikis_const.v_dds_message_tp_e,
                    SQLERRM);
                res := DBMS_LOCK.RELEASE (lockhandle);
            END;
    END;

    PROCEDURE Submit_Job (p_fj_id       file_job.fj_id%TYPE,
                          p_next_date   VARCHAR2,
                          p_interval    VARCHAR2)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_job      file_job%ROWTYPE;
        l_fj_job   NUMBER;
        l_trc      NUMBER := 0;
    BEGIN
        debug.f ('Start procedure');

        SELECT *
          INTO l_job
          FROM file_job
         WHERE fj_id = p_fj_id;

        l_trc := 1;

        IF    l_job.FJ_ST = ikis_const.v_dds_job_st_new
           OR l_job.FJ_ST = ikis_const.v_dds_job_st_removed
        THEN
            BEGIN
                l_trc := 2;
                DBMS_JOB.SUBMIT (
                    l_fj_job,
                    'IKIS_JOB_CONTROL.Execute_JOB(' || p_fj_id || ');',
                    TO_DATE (p_next_date, 'DD/MM/YYYY HH24:MI:SS'),
                    p_interval);
                l_trc := 3;

                UPDATE file_job a
                   SET a.fj_job = l_fj_job,
                       a.fj_st = ikis_const.v_dds_job_st_inqueue
                 WHERE a.fj_id = p_fj_id;

                l_trc := 4;
                COMMIT;
            EXCEPTION
                WHEN OTHERS
                THEN
                    ROLLBACK;
                    raise_application_error (
                        -20000,
                        IKIS_MESSAGE_UTIL.GET_MESSAGE (msgErroSubmitJob,
                                                       l_trc,
                                                       CHR (10) || SQLERRM));
            END;
        ELSE
            raise_application_error (
                -20000,
                IKIS_MESSAGE_UTIL.GET_MESSAGE (
                    msgErroSubmitJob,
                    ' якщо статусом відмінний від НОВИЙ, ВИДАЛЕНИЙ.'));
        END IF;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_JOB_CONTROL.Submit_Job with user: ' || USER,
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE Force_Job (p_fj_id file_job.fj_id%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_job   file_job%ROWTYPE;
    BEGIN
        debug.f ('Start procedure');

        SELECT *
          INTO l_job
          FROM file_job
         WHERE fj_id = p_fj_id;

        IF l_job.FJ_ST IN
               (ikis_const.v_dds_job_st_inqueue,
                ikis_const.v_dds_job_st_waitnext,
                ikis_const.v_dds_job_st_disable)
        THEN
            BEGIN
                DBMS_JOB.Run (l_job.fj_job);
            EXCEPTION
                WHEN eJobNotFound
                THEN
                    ROLLBACK;
                    raise_application_error (
                        -20000,
                        IKIS_MESSAGE_UTIL.GET_MESSAGE (
                            msgCantModifyNotOwnJob,
                            'виконати'));
                WHEN OTHERS
                THEN
                    ROLLBACK;
                    raise_application_error (
                        -20000,
                        IKIS_MESSAGE_UTIL.GET_MESSAGE (msgErrorExec,
                                                       CHR (10) || SQLERRM));
            END;
        ELSE
            raise_application_error (
                -20000,
                IKIS_MESSAGE_UTIL.GET_MESSAGE (msgInvalidStForce));
        END IF;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_JOB_CONTROL.Force_Job with ',
                    CHR (10) || SQLERRM));
    END;


    PROCEDURE CreateSubmited_Job (
        p_fj_id      OUT file_job.fj_id%TYPE,
        p_fj_ft          file_job.fj_ft%TYPE,
        p_params         VARCHAR2 DEFAULT cNA,
        p_interval       dba_jobs.interval%TYPE DEFAULT NULL)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;

        my_table   DBMS_UTILITY.Uncl_Array;
        cnt        BINARY_INTEGER;
        p_name     VARCHAR2 (250);
        p_value    VARCHAR2 (250);
    BEGIN
        debug.f ('Start procedure');
        RDM$FILE_JOB.INS$FILE_JOB (p_fj_id,
                                   p_fj_ft,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL);
        COMMIT; --Вообще говоря непонятно почему но без этого не работает Submit_Job (не видит вставленного)

        IF NOT (p_params = cNA)
        THEN
            DBMS_UTILITY.COMMA_TO_TABLE (p_params, cnt, my_table);

            FOR I IN 1 .. cnt
            LOOP
                my_table (I) := TRIM (BOTH '"' FROM my_table (I));
                p_name :=
                    SUBSTR (my_table (I), 1, INSTR (my_table (I), '=') - 1);
                p_value :=
                    SUBSTR (my_table (I), INSTR (my_table (I), '=') + 1);
                IKIS_FILE_JOB_PKG.Setparametervalue (p_fj_id,
                                                     p_name,
                                                     p_value);
            END LOOP;
        END IF;

        Submit_Job (p_fj_id, SYSDATE, p_interval);
        COMMIT;
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_JOB_CONTROL.CreateSubmited_Job with ',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE Remove_Job (p_fj_id file_job.fj_id%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_st    file_job.fj_st%TYPE;
        l_job   file_job.fj_job%TYPE;
    BEGIN
        debug.f ('Start procedure');

        BEGIN
            SELECT b.fj_st, b.fj_job
              INTO l_st, l_job
              FROM file_job b
             WHERE b.fj_id = p_fj_id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                raise_application_error (
                    -20000,
                    'Неможливо визначити тип завдання з таблиці file_type');
            WHEN OTHERS
            THEN
                RAISE;
        END;

        IF l_st IN
               (ikis_const.v_dds_job_st_inqueue,
                ikis_const.v_dds_job_st_waitnext,
                ikis_const.v_dds_job_st_disable)
        THEN
            BEGIN
                DBMS_JOB.REMOVE (l_job);
                IKIS_FILE_JOB_PKG.SetFileJobState (
                    p_fj_id,
                    ikis_const.v_dds_job_st_removed);
                COMMIT;
            EXCEPTION
                WHEN eJobNotFound
                THEN
                    ROLLBACK;
                    raise_application_error (
                        -20000,
                        IKIS_MESSAGE_UTIL.GET_MESSAGE (
                            msgCantModifyNotOwnJob,
                            'видалити'));
                WHEN OTHERS
                THEN
                    ROLLBACK;
                    RAISE;
            END;
        END IF;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_JOB_CONTROL.Remove_Job with ',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE Disable_Job (p_fj_id file_job.fj_id%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_job   file_job%ROWTYPE;
    BEGIN
        debug.f ('Start procedure');

        SELECT *
          INTO l_job
          FROM file_job
         WHERE fj_id = p_fj_id;

        IF l_job.FJ_ST IN
               (ikis_const.v_dds_job_st_inqueue,
                ikis_const.v_dds_job_st_waitnext)
        THEN
            BEGIN
                -- + KYB 24-10-2003
                --      DBMS_JOB.BROKEN (l_job.fj_job,false);
                DBMS_JOB.BROKEN (l_job.fj_job, TRUE);
                -- - KYB 24-10-2003
                IKIS_FILE_JOB_PKG.SetFileJobState (
                    l_job.fj_id,
                    ikis_const.v_dds_job_st_disable);
                COMMIT;
            EXCEPTION
                WHEN eJobNotFound
                THEN
                    ROLLBACK;
                    raise_application_error (
                        -20000,
                        IKIS_MESSAGE_UTIL.GET_MESSAGE (
                            msgCantModifyNotOwnJob,
                            'заборонити'));
                WHEN OTHERS
                THEN
                    ROLLBACK;
                    RAISE;
            END;
        ELSE
            raise_application_error (-20000, 'Неможливо заборонити завдання');
        END IF;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_JOB_CONTROL.Disable_Job with ',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE Full_Remove_Job (p_fj_id file_job.fj_id%TYPE)
    IS
    BEGIN
        debug.f ('Start procedure');
        Remove_Job (p_fj_id);
        RDM$FILE_JOB.DEL$FILE_JOB (p_fj_id);
        debug.f ('Stop procedure');
    END;
END IKIS_JOB_CONTROL;
/