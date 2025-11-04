/* Formatted on 8/12/2025 6:10:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_LOCK
IS
    -- Author  : YURA_A
    -- Created : 15.04.2003 16:44:43
    -- Purpose : Имена блокировок для ресурсов

    SUBTYPE t_lockhandler IS VARCHAR2 (100);

    --Исполнение задач планировщика
    lFILE_JOB_EXECUTE   CONSTANT VARCHAR2 (35)
        :=    'ATLAS_DPS_IKIS_FILE_JOB_EXECUTE'
           || ikis_subsys_util.getinstancepref ;
    lFILE_JOB_CHST      CONSTANT VARCHAR2 (35)
        := 'ATLAS_DPS_IKIS_FILE_JOB_CHST' || ikis_subsys_util.getinstancepref ;

    gINSTANCE_LOCK_NAME          VARCHAR2 (100);

    PROCEDURE Request_Lock (
        p_permanent_name          VARCHAR2,
        p_var_name                VARCHAR2,
        p_errmessage              VARCHAR2,
        p_lockhandler         OUT t_lockhandler,
        p_lockmode                INTEGER DEFAULT DBMS_LOCK.x_mode,
        p_timeout                 INTEGER DEFAULT DBMS_LOCK.maxwait,
        p_release_on_commit       BOOLEAN DEFAULT FALSE);

    PROCEDURE Releace_Lock (p_lockhandler t_lockhandler);

    PROCEDURE RequestDBLock (p_name              VARCHAR2,
                             p_lockhandler   OUT t_lockhandler);

    PROCEDURE Sleep (p_sec NUMBER);
END IKIS_LOCK;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_LOCK FOR IKIS_SYS.IKIS_LOCK
/


CREATE OR REPLACE SYNONYM USS_CEA.IKIS_LOCK FOR IKIS_SYS.IKIS_LOCK
/


CREATE OR REPLACE SYNONYM USS_DOC.IKIS_LOCK FOR IKIS_SYS.IKIS_LOCK
/


CREATE OR REPLACE SYNONYM USS_ESR.IKIS_LOCK FOR IKIS_SYS.IKIS_LOCK
/


CREATE OR REPLACE SYNONYM USS_EXCH.IKIS_LOCK FOR IKIS_SYS.IKIS_LOCK
/


CREATE OR REPLACE SYNONYM USS_NDI.IKIS_LOCK FOR IKIS_SYS.IKIS_LOCK
/


CREATE OR REPLACE SYNONYM USS_PERSON.IKIS_LOCK FOR IKIS_SYS.IKIS_LOCK
/


CREATE OR REPLACE SYNONYM USS_RNSP.IKIS_LOCK FOR IKIS_SYS.IKIS_LOCK
/


CREATE OR REPLACE SYNONYM USS_RPT.IKIS_LOCK FOR IKIS_SYS.IKIS_LOCK
/


CREATE OR REPLACE SYNONYM USS_VISIT.IKIS_LOCK FOR IKIS_SYS.IKIS_LOCK
/


GRANT EXECUTE ON IKIS_SYS.IKIS_LOCK TO II01RC_IKIS_COMMON
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCK TO II01RC_IKIS_REPL
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCK TO II01RC_IKIS_SYS_REPL
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCK TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCK TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCK TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCK TO IKIS_SYSWEB WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCK TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCK TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCK TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCK TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCK TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCK TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCK TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCK TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_LOCK TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:10:03 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_LOCK
IS
    -- Author  : YURA_A
    -- Created : 15.04.2003 16:44:43
    -- Purpose : Имена блокировок для ресурсов
    msgResourseIsBisy   NUMBER := 3674;

    PROCEDURE Request_Lock (
        p_permanent_name          VARCHAR2,
        p_var_name                VARCHAR2,
        p_errmessage              VARCHAR2,
        p_lockhandler         OUT t_lockhandler,
        p_lockmode                INTEGER DEFAULT DBMS_LOCK.x_mode,
        p_timeout                 INTEGER DEFAULT DBMS_LOCK.maxwait,
        p_release_on_commit       BOOLEAN DEFAULT FALSE)
    IS
        PROCEDURE Alloc (p_name VARCHAR2, p_lock OUT VARCHAR2)
        IS
            PRAGMA AUTONOMOUS_TRANSACTION;
        BEGIN
            DBMS_LOCK.ALLOCATE_UNIQUE (p_name, p_lock, 172800); --SBond 20160516
            COMMIT;
        EXCEPTION
            WHEN OTHERS
            THEN
                ROLLBACK;
                RAISE;
        END;
    BEGIN
        debug.f ('Start procedure');
        --+YAP 20071004 - читать вниматочно документацию (ибо как транзакция здесь заканчивалась)
        --DBMS_LOCK.ALLOCATE_UNIQUE (p_permanent_name||p_var_name,p_lockhandler);
        Alloc (p_permanent_name || p_var_name, p_lockhandler);

        ---
        IF NOT (DBMS_LOCK.REQUEST (p_lockhandler,
                                   p_lockmode,
                                   p_timeout,
                                   p_release_on_commit) = 0)
        THEN
            raise_application_error (-20000, p_errmessage);
        END IF;

        debug.f ('Stop procedure');
    END;

    PROCEDURE Releace_Lock (p_lockhandler t_lockhandler)
    IS
        l_result   INTEGER;
        l_errm     VARCHAR2 (1000) := NULL;
    BEGIN
        debug.f ('Start procedure');
        l_result := DBMS_LOCK.Release (lockhandle => p_lockhandler);

        CASE l_result
            WHEN 3
            THEN
                l_errm := 'Parameter error';
            WHEN 4
            THEN
                l_errm := 'Do not own lock specified by id or lockhandle';
            WHEN 5
            THEN
                l_errm := 'Illegal lock handle';
            ELSE
                RETURN;
        END CASE;

        IF l_errm IS NOT NULL
        THEN
            raise_application_error (
                -20000,
                   'Звільнення блокировки "'
                || p_lockhandler
                || '" завершено з помилкою: '
                || l_errm);
        END IF;

        debug.f ('Stop procedure');
    END;

    PROCEDURE RequestDBLock (p_name              VARCHAR2,
                             p_lockhandler   OUT t_lockhandler)
    IS
    BEGIN
        Request_Lock (gINSTANCE_LOCK_NAME,
                      p_name,
                      IKIS_MESSAGE_UTIL.GET_MESSAGE (msgResourseIsBisy),
                      p_lockhandler,
                      DBMS_LOCK.x_mode,
                      1);
    END;

    PROCEDURE Sleep (p_sec NUMBER)
    IS
    BEGIN
        DBMS_LOCK.sleep (p_sec);
    END;
BEGIN
    gINSTANCE_LOCK_NAME :=
        'ATLAS_DPS_IKIS_' || ikis_subsys_util.GetInstancePref;
END IKIS_LOCK;
/