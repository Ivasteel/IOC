/* Formatted on 8/12/2025 5:58:56 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RPT.USS_RPT_CONTEXT
IS
    -- Author  :
    -- Created :
    -- Purpose : IKIS_RPT_CONTEXT

    gContext      CONSTANT VARCHAR2 (10) := 'USS_RPT';

    -- Attr
    gUID          CONSTANT VARCHAR2 (10) := 'USSUID';
    gUserTP       CONSTANT VARCHAR2 (10) := 'IUTP';
    gUserTPCode   CONSTANT VARCHAR2 (10) := 'IUTPCODE';
    gOPFU         CONSTANT VARCHAR2 (10) := 'OPFU';
    gOPFU_CODE    CONSTANT VARCHAR2 (10) := 'OPFU_CODE';
    gRPT_BLD      CONSTANT VARCHAR2 (10) := 'W_RPT_BLD';
    gRPT_VIEW     CONSTANT VARCHAR2 (10) := 'W_RPT_VIEW';
    gLogin        CONSTANT VARCHAR2 (50) := 'LOGIN';

    gRptId        CONSTANT VARCHAR2 (50) := 'RPTID';

    gDnetSession           VARCHAR2 (50);
    gDnetUser              VARCHAR2 (50);

    FUNCTION GetContext (pAttr IN VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE SetDnetRptContext (p_session VARCHAR2);

    PROCEDURE SetReportContext (p_rpt_id IN NUMBER);

    PROCEDURE SetJobContext (p_jobname    VARCHAR2,
                             p_app_name   VARCHAR2 DEFAULT NULL);
END USS_RPT_CONTEXT;
/


/* Formatted on 8/12/2025 5:59:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RPT.USS_RPT_CONTEXT
IS
    gUserLogin   VARCHAR2 (30);

    PROCEDURE SetContextInternal
    IS
        l_uid           NUMBER;
        l_wut           NUMBER;
        l_opfu          NUMBER;
        l_opfu_code     VARCHAR (10);
        l_trc           VARCHAR2 (10);
        l_is_RPT_BLD    VARCHAR2 (10) := 'F';
        l_is_RPT_VIEW   VARCHAR2 (10) := 'F';
        l_wut_code      VARCHAR (10);
    BEGIN
        ikis_sysweb.GetUserAttr (p_username   => gUserLogin,
                                 p_uid        => l_uid,
                                 p_wut        => l_wut,
                                 p_org        => l_opfu,
                                 p_trc        => l_trc);

        SELECT wut_code
          INTO l_wut_code
          FROM ikis_sysweb.v_full_user_types
         WHERE wut_id = l_wut;

        --raise_application_error(-20000, 'gUserLogin='||gUserLogin||';l_uid='||l_uid||';l_opfu='||l_opfu);

        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gUID,
                                  VALUE       => l_uid);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gUserTP,
                                  VALUE       => l_wut);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gUserTPCode,
                                  VALUE       => l_wut_code);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gOPFU,
                                  VALUE       => l_opfu);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gOPFU_CODE,
                                  VALUE       => l_opfu_code);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gLogin,
                                  VALUE       => gUserLogin);

        -- щоб проставлявся контекст для рлс вьюх з цієї схеми
        /*dbms_session.set_context(namespace => 'USS_ESR', attribute => gUID,       value => l_uid);
        dbms_session.set_context(namespace => 'USS_ESR', attribute => gUserTP,    value => l_wut);
        DBMS_SESSION.set_context(namespace => 'USS_ESR', attribute => gUserTPCode, VALUE => l_wut_code);
        dbms_session.set_context(namespace => 'USS_ESR', attribute => gOPFU,      value => l_opfu);
        dbms_session.set_context(namespace => 'USS_ESR', attribute => gOPFU_CODE, value => l_opfu_code);
        dbms_session.set_context(namespace => 'USS_ESR', attribute => gLogin, value => gUserLogin);*/

        gDnetUser := gUserLogin;

        IF ikis_sysweb.is_role_assigned (p_username   => gUserLogin,
                                         p_role       => 'W_RPT_BLD',
                                         p_user_tp    => l_wut_code)
        THEN
            l_is_RPT_BLD := 'T';
        END IF;

        IF ikis_sysweb.is_role_assigned (p_username   => gUserLogin,
                                         p_role       => 'W_RPT_VIEW',
                                         p_user_tp    => l_wut_code)
        THEN
            l_is_RPT_VIEW := 'T';
        END IF;

        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gRPT_BLD,
                                  VALUE       => l_is_RPT_BLD);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gRPT_VIEW,
                                  VALUE       => l_is_RPT_VIEW);
    END;

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
                    WHEN 'opfu' THEN gOPFU
                    WHEN 'opfu_code' THEN gOPFU_CODE
                    ELSE UPPER (pAttr)
                END);
        RETURN vValue;
    END;

    PROCEDURE SetDnetRptContext (p_session VARCHAR2)
    IS
        l_user   VARCHAR2 (50);
    BEGIN
        ikis_sysweb.ikis_web_context.SetContextDnet (
            p_app_name   => 'USS_RPT',
            p_session    => p_session);
        ikis_sysweb.ikis_dnet_auth.CheckSession (p_session_id   => p_session,
                                                 p_login        => l_user);
        gUserLogin := l_user;
        APEX_APPLICATION.g_user := l_user;
        SetContextInternal;
        gDnetSession := p_session;
    END;

    PROCEDURE SetReportContext (p_rpt_id IN NUMBER)
    IS
        l_rpt   reports%ROWTYPE;
    BEGIN
        IF p_rpt_id IS NOT NULL
        THEN
            SELECT *
              INTO l_rpt
              FROM reports
             WHERE rpt_id = p_rpt_id AND rpt_st IN ('Q', 'F');

            SELECT wu_login
              INTO gUserLogin
              FROM ikis_sysweb.v$w_users
             WHERE wu_id = l_rpt.com_wu;

            SetContextInternal;
        END IF;
    END;

    PROCEDURE SetJobContext (p_jobname    VARCHAR2,
                             p_app_name   VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        gUserLogin := ikis_sysweb.ikis_sysweb_schedule.GetUser;
        --  gCtxAppName := p_app_name;
        SetContextInternal;
    END;
BEGIN
    NULL;
END USS_RPT_CONTEXT;
/