/* Formatted on 8/12/2025 6:06:30 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_FINZVIT.DNET$FINZVIT_CONTEXT
IS
    -- Author  : MAXYM
    -- Created : 09.10.2017 16:41:27
    -- Purpose :

    PROCEDURE SetContext (p_session_id IN VARCHAR2);

    FUNCTION GetUserTp
        RETURN PLS_INTEGER;

    FUNCTION GetOpfuOwn
        RETURN PLS_INTEGER;

    PROCEDURE GetCurrUserInfo (p_username   OUT VARCHAR2,
                               p_pib        OUT VARCHAR2,
                               p_wut        OUT NUMBER,
                               p_org        OUT NUMBER,
                               p_org_org    OUT NUMBER,
                               p_trc        OUT VARCHAR2,
                               p_numid      OUT VARCHAR2);
END DNET$FINZVIT_CONTEXT;
/


GRANT EXECUTE ON IKIS_FINZVIT.DNET$FINZVIT_CONTEXT TO DNET_PROXY
/


/* Formatted on 8/12/2025 6:06:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_FINZVIT.DNET$FINZVIT_CONTEXT
IS
    PROCEDURE SetContext (p_session_id IN VARCHAR2)
    IS
        l_login   VARCHAR2 (30);
    BEGIN
        EXECUTE IMMEDIATE 'alter session set NLS_LANGUAGE=''UKRAINIAN''';

        EXECUTE IMMEDIATE 'alter session set NLS_TERRITORY=''UKRAINE''';

        EXECUTE IMMEDIATE 'alter session set NLS_NUMERIC_CHARACTERS = ''.,''';

        --    execute immediate 'alter session set NLS_SORT=UKRAINIAN_CI';
        --  execute immediate 'alter session set NLS_DATE_FORMAT=''DD.MM.RRRR''';


        ikis_sysweb.ikis_dnet_auth.CheckSession (
            p_session_id   => p_session_id,
            p_login        => l_login);
        ikis_finzvit_context.SetContext (p_user => l_login);
    END;


    FUNCTION GetUserTp
        RETURN PLS_INTEGER
    IS
    BEGIN
        RETURN SYS_CONTEXT (IKIS_FINZVIT_CONTEXT.gContext,
                            IKIS_FINZVIT_CONTEXT.gUserTP);
    END;

    FUNCTION GetOpfuOwn
        RETURN PLS_INTEGER
    IS
        l_user_tp   PLS_INTEGER := GetUserTp;
    BEGIN
        IF (l_user_tp IN (4, 5))
        THEN
            RETURN SYS_CONTEXT (IKIS_FINZVIT_CONTEXT.gContext,
                                IKIS_FINZVIT_CONTEXT.gOPFU);
        END IF;

        IF (l_user_tp IN (6))
        THEN
            RETURN SYS_CONTEXT (IKIS_FINZVIT_CONTEXT.gContext,
                                IKIS_FINZVIT_CONTEXT.gPOPFU);
        END IF;

        RETURN NULL;
    END;


    PROCEDURE GetCurrUserInfo (p_username   OUT VARCHAR2,
                               p_pib        OUT VARCHAR2,
                               p_wut        OUT NUMBER,
                               p_org        OUT NUMBER,
                               p_org_org    OUT NUMBER,
                               p_trc        OUT VARCHAR2,
                               p_numid      OUT VARCHAR2)
    IS
    BEGIN
        ikis_sysweb.get_user_attr (
            p_wu_id      =>
                SYS_CONTEXT (IKIS_FINZVIT_CONTEXT.gContext,
                             IKIS_FINZVIT_CONTEXT.gUID),
            p_username   => p_username,
            p_pib        => p_pib,
            p_wut        => p_wut,
            p_org        => p_org,
            p_org_org    => p_org_org,
            p_trc        => p_trc,
            p_numid      => p_numid);
    END;
END DNET$FINZVIT_CONTEXT;
/