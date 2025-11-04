/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.debug
AS
    TYPE Argv IS TABLE OF VARCHAR2 (4000);

    emptyDebugArgv   Argv;

    PROCEDURE init (
        p_modules       IN VARCHAR2 DEFAULT 'ALL',
        p_file          IN VARCHAR2 DEFAULT '/tmp/' || USER || '.dbg',
        p_user          IN VARCHAR2 DEFAULT USER,
        p_show_date     IN VARCHAR2 DEFAULT 'YES',
        p_date_format   IN VARCHAR2 DEFAULT 'MMDDYYYY HH24MISS',
        p_name_len      IN NUMBER DEFAULT 30,
        p_show_sesid    IN VARCHAR2 DEFAULT 'NO');

    PROCEDURE f (p_message   IN VARCHAR2,
                 p_arg1      IN VARCHAR2 DEFAULT NULL,
                 p_arg2      IN VARCHAR2 DEFAULT NULL,
                 p_arg3      IN VARCHAR2 DEFAULT NULL,
                 p_arg4      IN VARCHAR2 DEFAULT NULL,
                 p_arg5      IN VARCHAR2 DEFAULT NULL,
                 p_arg6      IN VARCHAR2 DEFAULT NULL,
                 p_arg7      IN VARCHAR2 DEFAULT NULL,
                 p_arg8      IN VARCHAR2 DEFAULT NULL,
                 p_arg9      IN VARCHAR2 DEFAULT NULL,
                 p_arg10     IN VARCHAR2 DEFAULT NULL);

    PROCEDURE fa (p_message   IN VARCHAR2,
                  p_args      IN Argv DEFAULT emptyDebugArgv);

    PROCEDURE status (p_user   IN VARCHAR2 DEFAULT USER,
                      p_file   IN VARCHAR2 DEFAULT NULL);

    PROCEDURE clear (p_user   IN VARCHAR2 DEFAULT USER,
                     p_file   IN VARCHAR2 DEFAULT NULL);
END debug;
/


CREATE OR REPLACE PUBLIC SYNONYM DEBUG FOR IKIS_SYS.DEBUG
/


GRANT EXECUTE ON IKIS_SYS.DEBUG TO II01RC_IKIS_COMMON
/

GRANT EXECUTE ON IKIS_SYS.DEBUG TO II01RC_IKIS_JOB_EXEC
/

GRANT EXECUTE ON IKIS_SYS.DEBUG TO II01RC_IKIS_REPL
/

GRANT EXECUTE ON IKIS_SYS.DEBUG TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.DEBUG TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.DEBUG TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.DEBUG TO IKIS_SYSWEB WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.DEBUG TO SYSTEM
/

GRANT EXECUTE ON IKIS_SYS.DEBUG TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.DEBUG TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.DEBUG TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.DEBUG TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.DEBUG TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.DEBUG TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.DEBUG TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.DEBUG TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.DEBUG TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:10:01 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.debug
AS
    -- http://asktom.oracle.com/~tkyte/debugf
    g_session_id   VARCHAR2 (2000);

    PROCEDURE who_called_me (o_owner    OUT VARCHAR2,
                             o_object   OUT VARCHAR2,
                             o_lineno   OUT NUMBER)
    IS
        --
        l_call_stack   LONG DEFAULT DBMS_UTILITY.format_call_stack;
        l_line         VARCHAR2 (4000);
    BEGIN
        NULL;
    END who_called_me;

    FUNCTION parse_it (p_message         IN VARCHAR2,
                       p_argv            IN argv,
                       p_header_length   IN NUMBER)
        RETURN VARCHAR2
    IS
        --
        l_message   LONG := NULL;
        l_str       LONG := p_message;
        l_idx       NUMBER := 1;
        l_ptr       NUMBER := 1;
    BEGIN
        RETURN '';
    END parse_it;


    PROCEDURE debug_it (p_message IN VARCHAR2, p_argv IN argv)
    IS
        --
        l_message            LONG := NULL;
        l_header             LONG := NULL;
        call_who_called_me   BOOLEAN := TRUE;
        l_owner              VARCHAR2 (255);
        l_object             VARCHAR2 (255);
        l_lineno             NUMBER;
        l_dummy              BOOLEAN;
    BEGIN
        NULL;
    END debug_it;

    PROCEDURE init (
        p_modules       IN VARCHAR2 DEFAULT 'ALL',
        p_file          IN VARCHAR2 DEFAULT '/tmp/' || USER || '.dbg',
        p_user          IN VARCHAR2 DEFAULT USER,
        p_show_date     IN VARCHAR2 DEFAULT 'YES',
        p_date_format   IN VARCHAR2 DEFAULT 'MMDDYYYY HH24MISS',
        p_name_len      IN NUMBER DEFAULT 30,
        p_show_sesid    IN VARCHAR2 DEFAULT 'NO')
    IS
        --
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_message   LONG;
    BEGIN
        NULL;
    END init;

    PROCEDURE f (p_message   IN VARCHAR2,
                 p_arg1      IN VARCHAR2 DEFAULT NULL,
                 p_arg2      IN VARCHAR2 DEFAULT NULL,
                 p_arg3      IN VARCHAR2 DEFAULT NULL,
                 p_arg4      IN VARCHAR2 DEFAULT NULL,
                 p_arg5      IN VARCHAR2 DEFAULT NULL,
                 p_arg6      IN VARCHAR2 DEFAULT NULL,
                 p_arg7      IN VARCHAR2 DEFAULT NULL,
                 p_arg8      IN VARCHAR2 DEFAULT NULL,
                 p_arg9      IN VARCHAR2 DEFAULT NULL,
                 p_arg10     IN VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        NULL;
    END f;

    PROCEDURE fa (p_message   IN VARCHAR2,
                  p_args      IN Argv DEFAULT emptyDebugArgv)
    IS
    BEGIN
        NULL;
    END fa;

    PROCEDURE clear (p_user   IN VARCHAR2 DEFAULT USER,
                     p_file   IN VARCHAR2 DEFAULT NULL)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        NULL;
    END clear;

    PROCEDURE status (p_user   IN VARCHAR2 DEFAULT USER,
                      p_file   IN VARCHAR2 DEFAULT NULL)
    IS
        --
        l_found   BOOLEAN := FALSE;
    BEGIN
        NULL;
    END status;
BEGIN
    NULL;
END debug;
/