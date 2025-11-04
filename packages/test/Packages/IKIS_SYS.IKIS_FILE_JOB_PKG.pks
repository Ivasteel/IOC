/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_FILE_JOB_PKG
IS
    -- Author  : YURA_A
    -- Created : 27.03.2003 13:16:56
    -- Purpose : Управление заданиями на обработку файлов

    --Запись сообщения в протокол исполнения задачи
    PROCEDURE SaveJobMessage (p_tp VARCHAR2, p_errormsg VARCHAR2);

    --Установка значения параметра задачи
    PROCEDURE SetParameterValue (
        p_fj_id      file_job.fj_id%TYPE,
        p_ftp_name   file_type_parameter.ftp_name%TYPE,
        p_value      VARCHAR2);

    PROCEDURE SetCurrenJob (p_fj_id file_job.fj_id%TYPE);

    PROCEDURE SetFileJobState (p_fj_id file_job.fj_id%TYPE, p_state VARCHAR2);

    PROCEDURE SaveException (p_fj_id      file_job.fj_id%TYPE,
                             p_tp         VARCHAR2,
                             p_errormsg   VARCHAR2);

    ---------------------------------------
    -- KYB 01.03.2004 14:53:13
    ----------------------------------------
    -- Назначение : Очистка протокола выполнения задания
    -- Параметры : p_fj_id - ид задания
    --             p_fj_dt - до какой даты очищать протоколы, если null, то очищать всё
    PROCEDURE Clear_Job_Protocol (p_fj_id file_job.fj_id%TYPE, p_fj_dt DATE);
END IKIS_FILE_JOB_PKG;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_FILE_JOB_PKG FOR IKIS_SYS.IKIS_FILE_JOB_PKG
/


GRANT EXECUTE ON IKIS_SYS.IKIS_FILE_JOB_PKG TO II01RC_IKIS_JOB
/

GRANT EXECUTE ON IKIS_SYS.IKIS_FILE_JOB_PKG TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_FILE_JOB_PKG TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_FILE_JOB_PKG TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_FILE_JOB_PKG TO IKIS_SYSWEB WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_FILE_JOB_PKG TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_FILE_JOB_PKG TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_FILE_JOB_PKG TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_FILE_JOB_PKG TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_FILE_JOB_PKG TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_FILE_JOB_PKG TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_FILE_JOB_PKG TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_FILE_JOB_PKG TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_FILE_JOB_PKG TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:10:03 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_FILE_JOB_PKG
IS
    g_fj_id              NUMBER;

    -- Messages for category: IKIS_FILE_JOB_PKG
    msgEmptyAtribut      NUMBER := 98;
    msgInvalidFileType   NUMBER := 410;
    msgReqModeLock       NUMBER := 411;
    msgInvalidParTp      NUMBER := 412;
    msgErroSubmitJob     NUMBER := 414;
    msgErrorExec         NUMBER := 415;
    msgInvalidStForce    NUMBER := 416;
    msgDelErr            NUMBER := 418;
    msgErrChPar          NUMBER := 426;
    msgErrChSt           NUMBER := 427;

    exChBlocked          EXCEPTION;
    exInvalidStatus      EXCEPTION;
    exMandatoryPar       EXCEPTION;
    exChStBlocked        EXCEPTION;

    PROCEDURE SetCurrenJob (p_fj_id file_job.fj_id%TYPE)
    IS
    BEGIN
        g_fj_id := p_fj_id;
    END;

    PROCEDURE SaveException (p_fj_id      file_job.fj_id%TYPE,
                             p_tp         VARCHAR2,
                             p_errormsg   VARCHAR2)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO file_job_exception (fje_id,
                                        fje_fj,
                                        fje_errormsg,
                                        fje_dt,
                                        fje_tp)
             VALUES (0,
                     p_fj_id,
                     REPLACE (p_errormsg, 'ORA-20000:', ''),
                     SYSDATE,
                     p_tp);

        COMMIT;
    END;

    PROCEDURE SaveJobMessage (p_tp VARCHAR2, p_errormsg VARCHAR2)
    IS
    BEGIN
        IF g_fj_id IS NOT NULL
        THEN
            SaveException (g_fj_id, p_tp, p_errormsg);
        END IF;
    END;

    FUNCTION GetFileJobState (p_fj_id file_job.fj_id%TYPE)
        RETURN VARCHAR2
    IS
        l_res   file_job.fj_st%TYPE;
    BEGIN
        debug.f ('Start procedure');

        SELECT file_job.fj_st
          INTO l_res
          FROM file_job
         WHERE file_job.fj_id = p_fj_id;

        debug.f ('Stop procedure (%s)', l_res);
        RETURN l_res;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                'Відсутня задача з таким ідентифікатором (' || p_fj_id || ')');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_FILE_JOB_PKG.GetFileJobState with ',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE SetFileJobState (p_fj_id file_job.fj_id%TYPE, p_state VARCHAR2)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_lockhandle   VARCHAR2 (100);
        res            NUMBER;
    BEGIN
        debug.f ('Start procedure');
        DBMS_LOCK.ALLOCATE_UNIQUE (IKIS_LOCK.LFILE_JOB_CHST || p_fj_id,
                                   l_lockhandle);

        IF NOT (DBMS_LOCK.REQUEST (l_lockhandle,
                                   6,
                                   60,
                                   TRUE) = 0)
        THEN
            RAISE exChStBlocked; --_application_error(-20000,'Неможливо встановити статус ('||p_state||'). Операцію заблоковано.');
        END IF;

        IF p_state = ikis_const.v_dds_job_st_executing
        THEN
            UPDATE file_job a
               SET a.fj_stop_dt = NULL,
                   a.fj_start_dt = SYSDATE,
                   a.fj_st = p_state
             WHERE a.fj_id = p_fj_id;
        END IF;

        IF    p_state = ikis_const.v_dds_job_st_complite
           OR p_state = ikis_const.v_dds_job_st_errorexec
           OR p_state = ikis_const.v_dds_job_st_waitnext
        THEN
            UPDATE file_job a
               SET a.fj_stop_dt = SYSDATE, a.fj_st = p_state
             WHERE a.fj_id = p_fj_id;
        END IF;

        IF    p_state = ikis_const.v_dds_job_st_disable
           OR p_state = ikis_const.v_dds_job_st_inqueue
           OR p_state = ikis_const.v_dds_job_st_removed
        THEN
            UPDATE file_job a
               SET a.fj_st = p_state
             WHERE a.fj_id = p_fj_id;
        END IF;

        res := DBMS_LOCK.RELEASE (l_lockhandle);
        COMMIT;
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN exChStBlocked
        THEN
            raise_application_error (
                -20000,
                IKIS_MESSAGE_UTIL.GET_MESSAGE (msgErrChSt));
        WHEN OTHERS
        THEN
            res := DBMS_LOCK.RELEASE (l_lockhandle);
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_FILE_JOB_PKG.SetFileJobState with ',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE SetParameterValue (
        p_fj_id      file_job.fj_id%TYPE,
        p_ftp_name   file_type_parameter.ftp_name%TYPE,
        p_value      VARCHAR2)
    IS
        l_state        file_job.fj_st%TYPE;
        l_lockhandle   VARCHAR2 (100);
        res            NUMBER;
        l_mandatory    file_type_parameter.ftp_mandatory%TYPE;
    BEGIN
        debug.f ('Start procedure');
        DBMS_LOCK.ALLOCATE_UNIQUE (IKIS_LOCK.LFILE_JOB_CHST || p_fj_id,
                                   l_lockhandle);

        IF NOT (DBMS_LOCK.REQUEST (l_lockhandle,
                                   6,
                                   1,
                                   TRUE) = 0)
        THEN
            RAISE exChBlocked; --_application_error(-20000,'Неможливо змінити параметри. Операцію заблоковано.');
        END IF;

        --+ Автор: ABVER 05.08.2003 16:01:31
        --  Описание: Добавлена проверка - не устанавливается ли в
        --  обязательный параметр пустое значение
        IF p_value IS NULL
        THEN
            SELECT ftp_mandatory
              INTO l_mandatory
              FROM file_type_parameter x, file_job y
             WHERE     x.ftp_name = p_ftp_name
                   AND x.ftp_ft = y.fj_ft
                   AND y.fj_id = p_fj_id;

            IF l_mandatory = ikis_const.V_DDS_YN_Y
            THEN
                RAISE exMandatoryPar;
            END IF;
        END IF;

        --- Автор: ABVER 05.08.2003 16:01:34

        --Проверяем статус до и после изменения параметра (transaction read commited)
        l_state := GetFileJobState (p_fj_id);

        IF l_state IN (ikis_const.v_dds_job_st_new,
                       ikis_const.v_dds_job_st_inqueue,
                       ikis_const.v_dds_job_st_disable,
                       ikis_const.v_dds_job_st_waitnext)
        THEN
            UPDATE file_par_value a
               SET a.ftpv_value = p_value
             WHERE     a.ftpv_fj = p_fj_id
                   AND a.ftpv_ftp =
                       (SELECT x.ftp_id
                          FROM file_type_parameter x, file_job y
                         WHERE     x.ftp_name = p_ftp_name
                               AND x.ftp_ft = y.fj_ft
                               AND y.fj_id = p_fj_id);
        ELSE
            RAISE exInvalidStatus; --_application_error(-20000,'Неможливо змінювати параметри коли задача має статус '||l_state);
        END IF;

        res := DBMS_LOCK.RELEASE (l_lockhandle);
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN exMandatoryPar
        THEN
            raise_application_error (
                -20000,
                IKIS_MESSAGE_UTIL.GET_MESSAGE (msgEmptyAtribut, p_ftp_name));
        WHEN exChBlocked
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgErrChPar,
                                               'Операцію заблоковано.'));
        WHEN exInvalidStatus
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgErrChPar,
                    'коли задача має статус ' || l_state));
        WHEN OTHERS
        THEN
            res := DBMS_LOCK.RELEASE (l_lockhandle);
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_FILE_JOB_PKG.SetParameterValue with ',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE Clear_Job_Protocol (p_fj_id file_job.fj_id%TYPE, p_fj_dt DATE)
    IS
        l_err_msg   VARCHAR2 (100);
    BEGIN
        debug.f ('start execute clear ikis job protocol');
        SAVEPOINT one;

        IF p_fj_dt IS NULL
        THEN
            debug.f ('clearing full ikis job %s protocol', p_fj_id);

            DELETE FROM file_job_exception
                  WHERE fje_fj = p_fj_id;
        ELSE
            debug.f ('clearing ikis job %s protocol to date %s',
                     p_fj_id,
                     p_fj_dt);

            DELETE FROM file_job_exception
                  WHERE fje_fj = p_fj_id AND fje_dt < p_fj_dt;
        END IF;

        COMMIT;
        debug.f ('clear ikis job protocol complete');
    EXCEPTION
        WHEN OTHERS
        THEN
            l_err_msg := SQLERRM;
            ROLLBACK TO one;
            debug.f ('exception occured: ' || l_err_msg);
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_JOB_CONTROL.Clear_Job_Protocol with ',
                    CHR (10) || l_err_msg));
    END;
BEGIN
    g_fj_id := NULL;
END IKIS_FILE_JOB_PKG;
/