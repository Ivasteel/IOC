/* Formatted on 8/12/2025 5:54:20 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_EXCH.USS_EXCH_CONTEXT
IS
    gContext      CONSTANT VARCHAR2 (12) := 'USS_ESR';
    gUID          CONSTANT VARCHAR2 (10) := 'USSUID';
    gUserTP       CONSTANT VARCHAR2 (10) := 'IUTP';
    gUserTPCode   CONSTANT VARCHAR2 (10) := 'IUTPCODE';
    gORG          CONSTANT VARCHAR2 (10) := 'ORG';
    gORG_CODE     CONSTANT VARCHAR2 (10) := 'ORD_CODE';
    gLogin        CONSTANT VARCHAR2 (50) := 'LOGIN';
    gSession      CONSTANT VARCHAR2 (50) := 'SESSION';

    FUNCTION GetContext (pAttr IN VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE SetContext;

    PROCEDURE SetDnetEXCHContext (p_session VARCHAR2);

    PROCEDURE SetDnetRtflContext (p_session    DECIMAL,
                                  p_app_name   VARCHAR2 DEFAULT NULL);
END USS_EXCH_CONTEXT;
/


/* Formatted on 8/12/2025 5:54:21 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_EXCH.USS_EXCH_CONTEXT
IS
    FUNCTION GetContext (pAttr IN VARCHAR2)
        RETURN VARCHAR2
    IS
        vValue   VARCHAR2 (100);
    BEGIN
        vValue :=
            SYS_CONTEXT (
                gContext,
                CASE LOWER (pAttr)
                    WHEN 'uid' THEN gUID
                    WHEN 'usertp' THEN gUserTP
                    WHEN 'org' THEN gORG
                    WHEN 'org_code' THEN gORG_CODE
                    WHEN 'login' THEN gLOGIN
                END);

        RETURN vValue;
    END;

    PROCEDURE SetContext
    IS
        l_user       VARCHAR2 (50);
        l_uid        NUMBER;
        l_wut        NUMBER;
        l_org        NUMBER;
        l_org_code   VARCHAR (10);
        l_trc        VARCHAR2 (10);
    BEGIN
        DBMS_SESSION.CLEAR_ALL_CONTEXT (gContext);
        l_user := v ('USER');
        -- users
        ikis_sysweb.GetUserAttr (p_username   => l_user,
                                 p_uid        => l_uid,
                                 p_wut        => l_wut,
                                 p_org        => l_org,
                                 p_trc        => l_trc);
        -- set context
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gUID,
                                  VALUE       => l_uid);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gUserTP,
                                  VALUE       => l_wut);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gORG,
                                  VALUE       => l_org);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gORG_CODE,
                                  VALUE       => l_org_code);
    END SetContext;

    PROCEDURE SetDnetEXCHContext (p_session VARCHAR2)
    IS
        l_user       VARCHAR2 (50);
        l_uid        NUMBER;
        l_wut        NUMBER;
        l_org        NUMBER;
        l_org_code   VARCHAR (10);
        l_trc        VARCHAR2 (10);
    BEGIN
        DBMS_SESSION.CLEAR_ALL_CONTEXT (gContext);
        ikis_sysweb.ikis_web_context.SetContextDnet (
            p_app_name   => 'USS_EXCH',
            p_session    => p_session);
        ikis_sysweb.ikis_dnet_auth.CheckSession (p_session_id   => p_session,
                                                 p_login        => l_user);
        APEX_APPLICATION.g_user := l_user;
        ikis_sysweb.GetUserAttr (p_username   => l_user,
                                 p_uid        => l_uid,
                                 p_wut        => l_wut,
                                 p_org        => l_org,
                                 p_trc        => l_trc);

        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gSession,
                                  VALUE       => p_session);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gUID,
                                  VALUE       => l_uid);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gUserTP,
                                  VALUE       => l_wut);
        DBMS_SESSION.set_context (
            namespace   => gContext,
            attribute   => gUserTPCode,
            VALUE       =>
                CASE l_wut
                    WHEN 4 THEN 'UIC'
                    WHEN 5 THEN 'URE'
                    WHEN 6 THEN 'UMU'
                END);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gORG,
                                  VALUE       => l_org);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gORG_CODE,
                                  VALUE       => l_org_code);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gLogin,
                                  VALUE       => l_user);
    END;

    PROCEDURE SetDnetRtflContext (p_session    DECIMAL,
                                  p_app_name   VARCHAR2 DEFAULT NULL)
    IS
        l_user       VARCHAR2 (50);
        l_uid        NUMBER;
        l_wut        NUMBER;
        l_org        NUMBER;
        l_org_code   VARCHAR (10);
        l_trc        VARCHAR2 (10);
    BEGIN
        DBMS_SESSION.CLEAR_ALL_CONTEXT (gContext);
        l_user :=
            ikis_sysweb.REPORTFL_ENGINE_EX.GetReportUser (
                p_jbr_id   => p_session);
        ikis_sysweb.GetUserAttr (p_username   => l_user,
                                 p_uid        => l_uid,
                                 p_wut        => l_wut,
                                 p_org        => l_org,
                                 p_trc        => l_trc);

        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gSession,
                                  VALUE       => p_session);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gUID,
                                  VALUE       => l_uid);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gUserTP,
                                  VALUE       => l_wut);
        DBMS_SESSION.set_context (
            namespace   => gContext,
            attribute   => gUserTPCode,
            VALUE       =>
                CASE l_wut
                    WHEN 4 THEN 'UIC'
                    WHEN 5 THEN 'URE'
                    WHEN 6 THEN 'UMU'
                END);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gORG,
                                  VALUE       => l_org);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gORG_CODE,
                                  VALUE       => l_org_code);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gLogin,
                                  VALUE       => l_user);
    END;
END USS_EXCH_CONTEXT;
/