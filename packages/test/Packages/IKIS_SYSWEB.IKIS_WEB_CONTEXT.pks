/* Formatted on 8/12/2025 6:11:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.IKIS_WEB_CONTEXT
IS
    -- Author  : YURA_A
    -- Created : 18.04.2006 11:56:07
    -- Purpose : Set context for web-application
    gContext        CONSTANT VARCHAR2 (10) := 'IKISWEBADM';

    --Attr
    gLogin          CONSTANT VARCHAR2 (10) := 'LOGIN';
    gUserTP         CONSTANT VARCHAR2 (10) := 'IUTP';
    gOPFU           CONSTANT VARCHAR2 (10) := 'OPFU';
    gUID            CONSTANT VARCHAR2 (10) := 'IKISUID';
    gAPPNAME        CONSTANT VARCHAR2 (10) := 'APPNAME';
    gLoginAttempt   CONSTANT VARCHAR2 (20) := 'LOGINATTEMPT';
    gLoginTp        CONSTANT VARCHAR2 (10) := 'LOGINTP';
    gLoginIp        CONSTANT VARCHAR2 (10) := 'LOGINIP';

    PROCEDURE SetContext (p_app_name VARCHAR2);

    PROCEDURE SetJobContext (p_jobname    VARCHAR2,
                             p_app_name   VARCHAR2 DEFAULT NULL);

    --- Установка контекста по сессии в .Net приложении
    PROCEDURE SetContextDnet (p_app_name VARCHAR2, p_session VARCHAR2);

    PROCEDURE SetContextDnetEx (p_app_name     VARCHAR2,
                                p_session      VARCHAR2,
                                p_ip_address   VARCHAR2);

    --Встановлення контксту на основі сесії побудовника звітів (для .Net побудовника)
    PROCEDURE SetDnetRtflContext (p_session    DECIMAL,
                                  p_app_name   VARCHAR2 DEFAULT NULL);

    PROCEDURE SetContextDnetLogin (p_login_tp        VARCHAR2,
                                   p_login_attempt   VARCHAR2,
                                   p_login_ip        VARCHAR2);
END IKIS_WEB_CONTEXT;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_WEB_CONTEXT FOR IKIS_SYSWEB.IKIS_WEB_CONTEXT
/


GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_CONTEXT TO DNET_PROXY
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_CONTEXT TO II01RC_SYSWEB_COMM
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_CONTEXT TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_CONTEXT TO IKIS_PERSON
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_CONTEXT TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_CONTEXT TO IKIS_WEBPROXY
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_CONTEXT TO SHOST
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_CONTEXT TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_CONTEXT TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_CONTEXT TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_CONTEXT TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_CONTEXT TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_CONTEXT TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_CONTEXT TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_CONTEXT TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_CONTEXT TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:11:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.IKIS_WEB_CONTEXT
IS
    gUserLogin    VARCHAR2 (30);
    gCtxAppName   VARCHAR2 (30);
    gIpAddress    VARCHAR2 (30);

    --Функція встановлення контексту.
    --!!! НЕ ПУБЛІКУВАТИ в хідері пакету. Призначена виключно для внутрішнього використання - необхідно обов'язково перед викликом встановлювати gUserLogin та gCtxAppName
    PROCEDURE SetContextInternal
    IS
        l_tp    w_user_type.wut_id%TYPE;
        l_pfu   w_users.wu_org%TYPE;
        l_uid   w_users.wu_id%TYPE;
        l_trc   w_users.wu_trc%TYPE;
    BEGIN
        getuserattr (p_username   => gUserLogin,
                     p_uid        => l_uid,
                     p_wut        => l_tp,
                     p_org        => l_pfu,
                     p_trc        => l_trc);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gLogin,
                                  VALUE       => gUserLogin);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gUserTP,
                                  VALUE       => l_tp);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gOPFU,
                                  VALUE       => l_pfu);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gUID,
                                  VALUE       => l_uid);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gAPPNAME,
                                  VALUE       => NVL (gCtxAppName, 'N/A'));
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gLoginIp,
                                  VALUE       => gIpAddress);

        ikis_web_trace.StartTrace (p_level => l_trc);
    END;

    PROCEDURE SetContext (p_app_name VARCHAR2)
    IS
    BEGIN
        gUserLogin := v ('USER');
        gCtxAppName := p_app_name;
        SetContextInternal;
    END;

    PROCEDURE SetJobContext (p_jobname    VARCHAR2,
                             p_app_name   VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        gUserLogin :=
            NVL (ikis_sysweb.ikis_sysweb_jobs.GetUser,
                 IKIS_SYSWEB_SCHEDULE.GetUser);
        gCtxAppName := p_app_name;
        gIpAddress := NULL;
        SetContextInternal;
    END;

    ----------------------------------------
    ---  + max 15.06.2107
    --- Установка контекста по сессии в .Net приложении
    ----------------------------------------
    PROCEDURE SetContextDnet (p_app_name VARCHAR2, p_session VARCHAR2)
    IS
    BEGIN
        IKIS_DNET_AUTH.CheckSession (p_session_id   => p_session,
                                     p_login        => gUserLogin);
        gCtxAppName := p_app_name;
        gIpAddress := NULL;
        SetContextInternal;
    END;

    PROCEDURE SetContextDnetEx (p_app_name     VARCHAR2,
                                p_session      VARCHAR2,
                                p_ip_address   VARCHAR2)
    IS
    BEGIN
        IKIS_DNET_AUTH.CheckSession (p_session_id   => p_session,
                                     p_login        => gUserLogin);
        gCtxAppName := p_app_name;
        gIpAddress := p_ip_address;
        SetContextInternal;
    END;

    ----------------------------------------
    ---  - max 15.06.2107
    ----------------------------------------

    --Встановлення контксту на основі сесії побудовника звітів (для .Net побудовника)
    PROCEDURE SetDnetRtflContext (p_session    DECIMAL,
                                  p_app_name   VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        --gUserLogin := reportfl_engine_ex.GetReportUser(p_session);
        EXECUTE IMMEDIATE 'SELECT reportfl_engine_ex.GetReportUser(:p_session) FROM dual'
            INTO gUserLogin
            USING p_session;

        gCtxAppName := p_app_name;
        gIpAddress := NULL;
        SetContextInternal;
    END;

    --------------------------------------------------------------------------
    -- + shost 15.05.2019
    -- Установка контекста, используемого в процессе логина в .Net приложении
    ---------------------------------------------------------------------------
    PROCEDURE SetContextDnetLogin (p_login_tp        VARCHAR2,
                                   p_login_attempt   VARCHAR2,
                                   p_login_ip        VARCHAR2)
    IS
    BEGIN
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gLoginAttempt,
                                  VALUE       => p_login_attempt);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gLoginTp,
                                  VALUE       => p_login_tp);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gLoginIp,
                                  VALUE       => p_login_ip);
    END;
END IKIS_WEB_CONTEXT;
/