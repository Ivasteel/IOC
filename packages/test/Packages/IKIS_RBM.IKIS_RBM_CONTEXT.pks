/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.IKIS_RBM_CONTEXT
IS
    -- Author  : Sbond
    -- Created : 21.07.2010 14:56:59
    -- Purpose : isiv context

    gContext     CONSTANT VARCHAR2 (10) := 'IKISRBM';

    -- Attr
    gUID         CONSTANT VARCHAR2 (10) := 'IKISUID';
    gUserTP      CONSTANT VARCHAR2 (10) := 'IUTP';
    gOPFU        CONSTANT VARCHAR2 (10) := 'OPFU';
    gOPFU_CODE   CONSTANT VARCHAR2 (10) := 'OPFU_CODE';
    gRbmUser     CONSTANT VARCHAR2 (10) := 'RBMUSER';
    gRbmAdmin    CONSTANT VARCHAR2 (10) := 'RBMADMIN';
    gLogin       CONSTANT VARCHAR2 (50) := 'LOGIN';


    PROCEDURE SetContext;

    FUNCTION GetContext (pAttr VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE SetContextUser (puser VARCHAR2);

    -- 20220519 io
    PROCEDURE SetDnetRbmContext (p_session VARCHAR2);
END ikis_rbm_context;
/


GRANT EXECUTE ON IKIS_RBM.IKIS_RBM_CONTEXT TO DNET_PROXY
/

GRANT EXECUTE ON IKIS_RBM.IKIS_RBM_CONTEXT TO II01RC_RBMWEB_COMMON
/

GRANT EXECUTE ON IKIS_RBM.IKIS_RBM_CONTEXT TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 6:10:50 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.IKIS_RBM_CONTEXT
IS
    --msgCOMMON_EXCEPTION number := 2;
    PROCEDURE SetTmpOrg (p_org NUMBER)
    IS
        l_org_to    NUMBER;
        l_org_org   NUMBER;
        l_org       NUMBER := p_org;
    BEGIN
        BEGIN
            SELECT org_to, org_org
              INTO l_org_to, l_org_org
              FROM ikis_sysweb.v$v_opfu_all                           /*opfu*/
             WHERE org_id = l_org;
        EXCEPTION
            WHEN OTHERS
            THEN
                l_org_to := NULL;
                l_org_org := NULL;
        END;

        DELETE FROM tmp_org;

        -- для визначення зони видимості. див. uss_esr_rls
        IF l_org_to = 34
        THEN -- MSP_VPL  Обласний центр по нарахуванню та здійсненню соціальних виплат - повинен бачити також і райони
            -- свої + райони своєї області , їх ОТГ ???
            INSERT INTO tmp_org (u_org)
                SELECT org_id
                  FROM (    SELECT CONNECT_BY_ROOT org_id     AS root_rdt_id,
                                   LEVEL                      lvl,
                                   tt.*
                              FROM ikis_sysweb.v$v_opfu_all           /*opfu*/
                                                            tt
                             WHERE org_st = 'A'
                        CONNECT BY NOCYCLE PRIOR tt.org_id = tt.org_org
                        START WITH org_id = l_org_org)
                 WHERE org_id != l_org_org;
        ELSE -- обмежити лише МінСоцПолітики ? l_org_to in (30, 31, 32, 33, 34)
            INSERT INTO tmp_org (u_org)
                SELECT org_id
                  FROM (    SELECT CONNECT_BY_ROOT org_id     AS root_rdt_id,
                                   LEVEL                      lvl,
                                   tt.*
                              FROM ikis_sysweb.v$v_opfu_all           /*opfu*/
                                                            tt
                             WHERE org_st = 'A'
                        CONNECT BY NOCYCLE PRIOR tt.org_id = tt.org_org
                        START WITH org_id = l_org);
        END IF;

        COMMIT;
    END;

    PROCEDURE SetContext
    IS
        l_uid            NUMBER;
        l_tp             NUMBER;
        l_org            NUMBER;
        l_org_code       VARCHAR (10);
        l_trc            VARCHAR2 (10);
        l_level          VARCHAR2 (10);
        l_is_RBM_USER    VARCHAR2 (10) := ikis_const.V_DDN_BOOLEAN_F;
        l_is_RBM_ADMIN   VARCHAR2 (10) := ikis_const.V_DDN_BOOLEAN_F;
    BEGIN
        SetContextUser (puser => v ('USER'));
    /*  -- users
      ikis_sysweb.GetUserAttr(p_username => v('USER'),
                  p_uid => l_uid,
                  p_wut => l_tp,
                  p_org => l_org,
                  p_trc => l_trc);

      -- set context
      dbms_session.set_context(namespace => gContext, attribute => gUID, value => l_uid);
      dbms_session.set_context(namespace => gContext, attribute => gUserTP, value => l_tp);
      dbms_session.set_context(namespace => gContext, attribute => gOPFU, value => l_org);
      dbms_session.set_context(namespace => gContext, attribute => gOPFU_CODE, value => l_org_code);

      -- UIC / URE / UMU
      --l_level := 'UMR'; --  4 test !!!!!! case when l_tp = 4 then 'UIC' when l_tp = 5 then 'URE' when l_tp = 6 then 'UMU' else null end;

      select ut.wut_code into l_level
      from ikis_sysweb.v_full_user_types ut
      where ut.wut_id = l_tp;
      -- W_ISIV_USER
      if ikis_sysweb.is_role_assigned(p_username => v('USER'), p_role => 'W_RBM_USER', p_user_tp => l_level) then
        l_is_RBM_USER := ikis_const.V_DDN_BOOLEAN_T;
      end if;
      if ikis_sysweb.is_role_assigned(p_username => v('USER'), p_role => 'W_RBM_ADM', p_user_tp => l_level) then
        l_is_RBM_ADMIN := ikis_const.V_DDN_BOOLEAN_T;
      end if;

      dbms_session.set_context(namespace => gContext, attribute => gRbmUser, value => l_is_RBM_USER);
      dbms_session.set_context(namespace => gContext, attribute => gRbmAdmin, value => l_is_RBM_ADMIN);


      -- io 20211025  визначаємо перелік доступних org_id
      SetTmpOrg(l_org);*/
    END;

    FUNCTION GetContext (pAttr VARCHAR2)
        RETURN VARCHAR2
    IS
        vValue   VARCHAR2 (100);
    BEGIN
        CASE
            WHEN LOWER (pAttr) = LOWER ('UID')
            THEN
                vValue := SYS_CONTEXT (gContext, gUID);
            WHEN LOWER (pAttr) = LOWER ('UserTP')
            THEN
                vValue := SYS_CONTEXT (gContext, gUserTP);
            WHEN LOWER (pAttr) = LOWER ('OPFU')
            THEN
                vValue := SYS_CONTEXT (gContext, gOPFU);
            WHEN LOWER (pAttr) = LOWER ('OPFU_CODE')
            THEN
                vValue := SYS_CONTEXT (gContext, gOPFU_CODE);
            WHEN LOWER (pAttr) = LOWER ('LOGIN')
            THEN
                vValue := SYS_CONTEXT (gContext, gLogin);
        END CASE;

        RETURN vValue;
    END;

    PROCEDURE SetContextUser (puser VARCHAR2)
    IS
        l_uid            NUMBER;
        l_tp             NUMBER;
        l_org            NUMBER;
        l_trc            VARCHAR2 (10);
        l_level          VARCHAR2 (10);
        l_is_RBM_USER    VARCHAR2 (10) := ikis_const.V_DDN_BOOLEAN_F;
        l_is_RBM_ADMIN   VARCHAR2 (10) := ikis_const.V_DDN_BOOLEAN_F;
    BEGIN
        -- users
        NULL;
        ikis_sysweb.GetUserAttr (p_username   => puser,
                                 p_uid        => l_uid,
                                 p_wut        => l_tp,
                                 p_org        => l_org,
                                 p_trc        => l_trc);

        DBMS_OUTPUT.put_line (
               'l_uid='
            || l_uid
            || ',l_tp='
            || l_tp
            || ',l_org='
            || l_org
            || ',l_trc='
            || l_trc);

        -- set context
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gUID,
                                  VALUE       => l_uid);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gUserTP,
                                  VALUE       => l_tp);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gOPFU,
                                  VALUE       => l_org);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gOPFU_CODE,
                                  VALUE       => l_org);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gLogin,
                                  VALUE       => puser);

        SELECT ut.wut_code
          INTO l_level
          FROM ikis_sysweb.v_full_user_types ut
         WHERE ut.wut_id = l_tp;


        DBMS_OUTPUT.put_line (
               'l_level='
            || l_level
            || ',usr='
            || APEX_DEBUG.TOCHAR (
                   ikis_sysweb.is_role_assigned (p_username   => puser,
                                                 p_role       => 'W_RBM_USER',
                                                 p_user_tp    => l_level))
            || ',adm='
            || APEX_DEBUG.TOCHAR (
                   ikis_sysweb.is_role_assigned (p_username   => puser,
                                                 p_role       => 'W_RBM_ADM',
                                                 p_user_tp    => l_level)));

        -- W_ISIV_USER
        IF ikis_sysweb.is_role_assigned (p_username   => puser,
                                         p_role       => 'W_RBM_USER',
                                         p_user_tp    => l_level)
        THEN
            l_is_RBM_USER := ikis_const.V_DDN_BOOLEAN_T;
        END IF;

        IF ikis_sysweb.is_role_assigned (p_username   => puser,
                                         p_role       => 'W_RBM_ADM',
                                         p_user_tp    => l_level)
        THEN
            l_is_RBM_ADMIN := ikis_const.V_DDN_BOOLEAN_T;
        END IF;

        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gRbmUser,
                                  VALUE       => l_is_RBM_USER);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gRbmAdmin,
                                  VALUE       => l_is_RBM_ADMIN);


        -- io 20211025  визначаємо перелік доступних org_id
        SetTmpOrg (l_org);
    END;

    -- 20220519 io
    PROCEDURE SetDnetRbmContext (p_session VARCHAR2)
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
        ikis_sysweb.ikis_web_context.SetContextDnet (
            p_app_name   => 'IKIS_RBM',
            p_session    => p_session);
        ikis_sysweb.ikis_dnet_auth.CheckSession (p_session_id   => p_session,
                                                 p_login        => l_user);
        APEX_APPLICATION.g_user := l_user;
        --ikis_sysweb.GetUserAttr (p_username => l_user, p_uid => l_uid, p_wut => l_wut, p_org  => l_org, p_trc => l_trc);

        SetContextUser (puser => l_user);
    END;
END ikis_rbm_context;
/