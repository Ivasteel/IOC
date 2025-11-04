/* Formatted on 8/12/2025 6:11:37 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_SYSWEB.ScheduleWrap (
    p_jb         IN w_jobs.jb_id%TYPE,
    p_what          VARCHAR2,
    p_interval      VARCHAR2)
    AUTHID CURRENT_USER
IS
    l_what   VARCHAR2 (32765) := p_what;
    l_err    VARCHAR2 (4000);
BEGIN
    --ikis_sysweb.ikis_debug_pipe.WriteMsg('ikis_sysweb.ScheduleWrap');
    -- подготовка задачи
    ikis_sysweb.IKIS_SYSWEB_SCHEDULE.PrepareJob (p_jb, l_what, p_interval);

    -- будет вызываться процедура из прикладной схемы
    -- инициализация контекста
    EXECUTE IMMEDIATE 'begin initjobcontext; end;';

    -- исполнение
    --ikis_sysweb.ikis_debug_pipe.WriteMsg(l_what);
    EXECUTE IMMEDIATE l_what;

    -- пост операции
    ikis_sysweb.IKIS_SYSWEB_SCHEDULE.PostJob (p_jb, p_interval);
EXCEPTION
    WHEN ikis_sysweb.IKIS_SYSWEB_SCHEDULE.exInvCheckForInput
    THEN
        l_err := 'Помилка виконання завдання: зверніться до розробника.';
        --ikis_sysweb.IKIS_SYSWEB_SCHEDULE.SetErrStatus(p_jb,l_err);
        ROLLBACK;
        raise_application_error (
            -20000,
               'Sql Injection detected: '
            || p_jb
            || CHR (10)
            || p_what
            || CHR (10)
            || p_interval);
    --  when others then raise_application_error(-20000,'ERR: '||p_jb||chr(10)||l_what||chr(10)||sqlerrm);
    WHEN OTHERS
    THEN
        --+YAP 20081212 по предложению Роговченко
        --l_err:='Помилка виконання завдання: '||sqlerrm;
        l_err :=
               'Помилка виконання завдання: '
            || DBMS_UTILITY.FORMAT_ERROR_STACK
            || ':'
            || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
        ---YAP
        ikis_sysweb.IKIS_SYSWEB_SCHEDULE.SetErrStatus (p_jb, l_err);
        ROLLBACK;
END;
/


CREATE OR REPLACE PUBLIC SYNONYM SCHEDULEWRAP FOR IKIS_SYSWEB.SCHEDULEWRAP
/


GRANT EXECUTE ON IKIS_SYSWEB.SCHEDULEWRAP TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.SCHEDULEWRAP TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.SCHEDULEWRAP TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.SCHEDULEWRAP TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.SCHEDULEWRAP TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.SCHEDULEWRAP TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.SCHEDULEWRAP TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.SCHEDULEWRAP TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.SCHEDULEWRAP TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.SCHEDULEWRAP TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.SCHEDULEWRAP TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.SCHEDULEWRAP TO USS_VISIT WITH GRANT OPTION
/
