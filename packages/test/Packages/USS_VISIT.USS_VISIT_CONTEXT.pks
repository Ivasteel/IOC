/* Formatted on 8/12/2025 5:59:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.USS_VISIT_CONTEXT
IS
    -- Author  : VANO
    -- Created : 11.02.2021 18:20:10
    -- Purpose : Контекстний пакет для Єдиного соціального процесінга

    gContext      CONSTANT VARCHAR2 (12) := 'USS_VISIT';
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

    PROCEDURE SetDnetVisitContext (p_session      VARCHAR2,
                                   p_ip_address   VARCHAR2 DEFAULT NULL);

    PROCEDURE SetDnetRtflContext (p_session    DECIMAL,
                                  p_app_name   VARCHAR2 DEFAULT NULL);
END USS_VISIT_CONTEXT;
/


/* Formatted on 8/12/2025 6:00:03 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.USS_VISIT_CONTEXT
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
                    WHEN 'ussuid' THEN gUID
                    WHEN 'iutp' THEN gUserTP
                    WHEN 'iutpcode' THEN gUserTPCode
                    WHEN 'org' THEN gORG
                    WHEN 'org_code' THEN gORG_CODE
                    WHEN 'login' THEN gLOGIN
                END);

        RETURN vValue;
    END;

    PROCEDURE SetTmpOrg (p_org NUMBER)
    IS
        l_org_to    NUMBER;
        l_org_org   NUMBER;
        l_org       NUMBER := p_org;
    BEGIN
        BEGIN
            SELECT org_to, org_org
              INTO l_org_to, l_org_org
              FROM opfu
             WHERE org_id = l_org;
        EXCEPTION
            WHEN OTHERS
            THEN
                l_org_to := NULL;
                l_org_org := NULL;
        END;

        DELETE FROM tmp_org
              WHERE 1 = 1;

        -- для визначення зони видимості. див. uss_esr_rls
        IF l_org_to = 34
        THEN -- MSP_VPL  Обласний центр по нарахуванню та здійсненню соціальних виплат - повинен бачити також і райони
            -- свої + райони своєї області , їх ОТГ ???
            INSERT INTO tmp_org (u_org)
                SELECT org_id
                  FROM (    SELECT CONNECT_BY_ROOT org_id     AS root_rdt_id,
                                   LEVEL                      lvl,
                                   tt.*
                              FROM opfu tt
                             WHERE 1 = 1
                        CONNECT BY NOCYCLE PRIOR tt.org_id = tt.org_org
                        START WITH org_id = l_org_org)
                 WHERE org_id != l_org_org;
        ELSIF l_org_to IN (20, 40)
        THEN
            INSERT INTO tmp_org (u_org)
                SELECT org_id
                  FROM opfu tt
                 WHERE     org_st = 'A'
                       AND org_to IN (30,
                                      31,
                                      32,
                                      33,
                                      34,
                                      35);                           -- #99751
        ELSIF l_org_to IN (21)
        THEN
            INSERT INTO tmp_org (u_org)
                SELECT org_id
                  FROM (    SELECT CONNECT_BY_ROOT org_id     AS root_rdt_id,
                                   LEVEL                      lvl,
                                   tt.*
                              FROM opfu tt
                             WHERE org_st = 'A'
                        CONNECT BY NOCYCLE PRIOR tt.org_id = tt.org_org
                        START WITH org_id IN (SELECT n2d_org_dszn
                                                FROM uss_ndi.v_ndi_nsss2dszn
                                               WHERE n2d_org_nsss = l_org));
        ELSE -- обмежити лише МінСоцПолітики ? l_org_to in (30, 31, 32, 33, 34)
            INSERT INTO tmp_org (u_org)
                SELECT org_id
                  FROM (    SELECT CONNECT_BY_ROOT org_id     AS root_rdt_id,
                                   LEVEL                      lvl,
                                   tt.*
                              FROM opfu tt
                             WHERE org_st = 'A'
                        CONNECT BY NOCYCLE PRIOR tt.org_id = tt.org_org
                        START WITH org_id = l_org);
        END IF;

        COMMIT;
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
        ikis_sysweb.GetUserAttr (p_username   => l_user,
                                 p_uid        => l_uid,
                                 p_wut        => l_wut,
                                 p_org        => l_org,
                                 p_trc        => l_trc);

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
        SetTmpOrg (l_org);
    END SetContext;

    /*
    PROCEDURE SetDnetVisitContext(p_session VARCHAR2) IS
      l_user                     varchar2(50);
      l_uid                      NUMBER;
      l_wut                      NUMBER;
      l_org                      NUMBER;
      l_org_code                 VARCHAR (10);
      l_trc                      VARCHAR2 (10);
      l_wut_code                 VARCHAR (10);
    BEGIN
      DBMS_SESSION.CLEAR_ALL_CONTEXT(gContext);
      ikis_sysweb.ikis_web_context.SetContextDnet(p_app_name => 'USS_VISIT', p_session => p_session);
      ikis_sysweb.ikis_dnet_auth.CheckSession(p_session_id => p_session, p_login => l_user);
      apex_application.g_user := l_user;
      ikis_sysweb.GetUserAttr (p_username => l_user, p_uid => l_uid, p_wut => l_wut, p_org  => l_org, p_trc => l_trc);
      SELECT wut_code INTO l_wut_code FROM ikis_sysweb.v_full_user_types WHERE wut_id = l_wut;

      DBMS_SESSION.set_context (namespace => gContext, attribute => gSession, VALUE        => p_session);
      DBMS_SESSION.set_context (namespace => gContext, attribute => gUID, VALUE        => l_uid);
      DBMS_SESSION.set_context (namespace => gContext, attribute => gUserTP, VALUE     => l_wut);
      DBMS_SESSION.set_context (namespace => gContext, attribute => gUserTPCode, VALUE => l_wut_code);
      DBMS_SESSION.set_context (namespace => gContext, attribute => gORG, VALUE       => l_org);
      DBMS_SESSION.set_context (namespace => gContext, attribute => gORG_CODE, VALUE  => l_org_code);
      DBMS_SESSION.set_context (namespace => gContext, attribute => gLogin, VALUE      => l_user);
      SetTmpOrg(l_org);
    END;*/

    PROCEDURE SetDnetVisitContext (p_session      VARCHAR2,
                                   p_ip_address   VARCHAR2 DEFAULT NULL)
    IS
        l_user       VARCHAR2 (50);
        l_uid        NUMBER;
        l_wut        NUMBER;
        l_org        NUMBER;
        l_org_code   VARCHAR (10);
        l_trc        VARCHAR2 (10);
        l_wut_code   VARCHAR (10);
    BEGIN
        DBMS_SESSION.CLEAR_ALL_CONTEXT (gContext);
        ikis_sysweb.ikis_web_context.SetContextDnetEx (
            p_app_name     => 'USS_VISIT',
            p_session      => p_session,
            p_ip_address   => p_ip_address);
        ikis_sysweb.ikis_dnet_auth.CheckSession (p_session_id   => p_session,
                                                 p_login        => l_user);
        APEX_APPLICATION.g_user := l_user;
        ikis_sysweb.GetUserAttr (p_username   => l_user,
                                 p_uid        => l_uid,
                                 p_wut        => l_wut,
                                 p_org        => l_org,
                                 p_trc        => l_trc);

        SELECT wut_code
          INTO l_wut_code
          FROM ikis_sysweb.v_full_user_types
         WHERE wut_id = l_wut;

        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gSession,
                                  VALUE       => p_session);
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
                                  attribute   => gORG,
                                  VALUE       => l_org);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gORG_CODE,
                                  VALUE       => l_org_code);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gLogin,
                                  VALUE       => l_user);
        SetTmpOrg (l_org);
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
        l_wut_code   VARCHAR (10);
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

        SELECT wut_code
          INTO l_wut_code
          FROM ikis_sysweb.v_full_user_types
         WHERE wut_id = l_wut;

        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gSession,
                                  VALUE       => p_session);
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
                                  attribute   => gORG,
                                  VALUE       => l_org);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gORG_CODE,
                                  VALUE       => l_org_code);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gLogin,
                                  VALUE       => l_user);
        SetTmpOrg (l_org);
    END;
END USS_VISIT_CONTEXT;
/