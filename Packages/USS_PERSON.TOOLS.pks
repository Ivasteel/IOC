/* Formatted on 8/12/2025 5:56:55 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.TOOLS
IS
    -- Author  : VANO
    -- Created : 25.01.2023 18:57:08
    -- Purpose : Допоміжні функції
    gINSTANCE_LOCK_NAME   VARCHAR2 (100);

    SUBTYPE t_lockhandler IS VARCHAR2 (100);

    FUNCTION GetHistSession
        RETURN histsession.hs_id%TYPE;

    FUNCTION ggp (p_code VARCHAR2, p_dt DATE DEFAULT NULL)
        RETURN VARCHAR2;

    FUNCTION ggpd (p_code VARCHAR2, p_dt DATE DEFAULT NULL)
        RETURN DATE;

    FUNCTION ggpn (p_code VARCHAR2, p_dt DATE DEFAULT NULL)
        RETURN NUMBER;

    FUNCTION request_lock (p_descr IN VARCHAR2)
        RETURN t_lockhandler;

    FUNCTION request_lock (p_descr               IN VARCHAR2,
                           p_error_msg           IN VARCHAR2,
                           p_release_on_commit   IN BOOLEAN DEFAULT TRUE)
        RETURN t_lockhandler;

    FUNCTION request_lock_with_timeout (
        p_descr               IN VARCHAR2,
        p_error_msg           IN VARCHAR2,
        p_timeout             IN NUMBER DEFAULT 0,
        p_release_on_commit   IN BOOLEAN DEFAULT TRUE)
        RETURN t_lockhandler;

    PROCEDURE release_lock (p_lock_handler IN t_lockhandler);

    FUNCTION Try_Parse_Dt (p_Val IN VARCHAR2, p_Fmt IN VARCHAR2)
        RETURN DATE;

    FUNCTION tnumber (p_number              VARCHAR2,
                      p_format              VARCHAR2 DEFAULT '999999999999D999',
                      p_decimal_separator   VARCHAR2 DEFAULT '.')
        RETURN NUMBER;

    FUNCTION TrimXMLStr (p_Str IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION GetUserLogin (P_WU_ID IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION GetUserPib (P_WU_ID IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION GetCurrOrg
        RETURN NUMBER;

    FUNCTION GetCurrOrgTo
        RETURN NUMBER;

    FUNCTION GetCurrOrgName
        RETURN VARCHAR2;

    FUNCTION GetCurrWu
        RETURN NUMBER;

    FUNCTION GetCurrWut
        RETURN NUMBER;

    FUNCTION GetCurrLogin
        RETURN VARCHAR2;

    FUNCTION GetCurrUserTp
        RETURN VARCHAR2;

    FUNCTION GetCurrUserPIB (P_MODE IN NUMBER DEFAULT 0)
        RETURN VARCHAR2;

    FUNCTION CheckUserRole (p_role VARCHAR2)
        RETURN BOOLEAN;

    FUNCTION CheckUserRoleStr (p_role VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE LOG (p_Src              VARCHAR2,
                   p_Obj_Tp           VARCHAR2,
                   p_Obj_Id           NUMBER,
                   p_Regular_Params   VARCHAR2,
                   p_Lob_Param        CLOB DEFAULT NULL);

    PROCEDURE validate_param (p_val VARCHAR2);

    FUNCTION b64_decode (p_clob CLOB)
        RETURN CLOB;
END TOOLS;
/


GRANT EXECUTE ON USS_PERSON.TOOLS TO II01RC_USS_PERSON_INT
/

GRANT EXECUTE ON USS_PERSON.TOOLS TO USS_ESR
/

GRANT EXECUTE ON USS_PERSON.TOOLS TO USS_RNSP
/

GRANT EXECUTE ON USS_PERSON.TOOLS TO USS_RPT
/

GRANT EXECUTE ON USS_PERSON.TOOLS TO USS_VISIT
/


/* Formatted on 8/12/2025 5:57:04 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.TOOLS
IS
    FUNCTION GetHistSession
        RETURN histsession.hs_id%TYPE
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        INSERT INTO histsession (hs_id, hs_wu, hs_dt)
             VALUES (0, SYS_CONTEXT ('IKISWEBADM', 'IKISUID'), SYSDATE)
          RETURNING hs_id
               INTO l_hs;

        RETURN l_hs;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'TOOLS.GetHistSession: ' || CHR (10) || SQLERRM);
    END;

    FUNCTION ggp (p_code VARCHAR2, p_dt DATE DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_rez   paramsperson.prm_value%TYPE;
    BEGIN
        SELECT prm_value
          INTO l_rez
          FROM paramsperson
         WHERE prm_code = p_code;

        RETURN l_rez;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    FUNCTION ggpd (p_code VARCHAR2, p_dt DATE DEFAULT NULL)
        RETURN DATE
    IS
        l_rez   DATE;
    BEGIN
        RETURN TO_DATE (tools.ggp (p_code, p_dt), 'DD.MM.YYYY');
    END;

    FUNCTION ggpn (p_code VARCHAR2, p_dt DATE DEFAULT NULL)
        RETURN NUMBER
    IS
        l_rez   NUMBER;
    BEGIN
        RETURN TO_NUMBER (tools.ggp (p_code, p_dt));
    END;

    FUNCTION request_lock (p_descr IN VARCHAR2)
        RETURN t_lockhandler
    IS
        l_lock_handler   t_lockhandler;
    BEGIN
        ikis_sys.ikis_lock.request_lock (
            p_permanent_name      => gINSTANCE_LOCK_NAME,
            p_var_name            => p_descr,
            p_errmessage          => 'BUSY',
            p_lockhandler         => l_lock_handler,
            p_timeout             => 0,
            p_release_on_commit   => TRUE);

        RETURN l_lock_handler;
    END request_lock;

    FUNCTION request_lock (p_descr               IN VARCHAR2,
                           p_error_msg           IN VARCHAR2,
                           p_release_on_commit   IN BOOLEAN DEFAULT TRUE)
        RETURN t_lockhandler
    IS
        l_lock_handler   t_lockhandler;
    BEGIN
        ikis_sys.ikis_lock.request_lock (
            p_permanent_name      => gINSTANCE_LOCK_NAME,
            p_var_name            => p_descr,
            p_errmessage          => p_error_msg,
            p_lockhandler         => l_lock_handler,
            p_timeout             => 0,
            p_release_on_commit   => p_release_on_commit);

        RETURN l_lock_handler;
    END request_lock;

    FUNCTION request_lock_with_timeout (
        p_descr               IN VARCHAR2,
        p_error_msg           IN VARCHAR2,
        p_timeout             IN NUMBER DEFAULT 0,
        p_release_on_commit   IN BOOLEAN DEFAULT TRUE)
        RETURN t_lockhandler
    IS
        l_lock_handler   t_lockhandler;
    BEGIN
        ikis_sys.ikis_lock.request_lock (
            p_permanent_name      => gINSTANCE_LOCK_NAME,
            p_var_name            => p_descr,
            p_errmessage          => p_error_msg,
            p_lockhandler         => l_lock_handler,
            p_timeout             => p_timeout,
            p_release_on_commit   => p_release_on_commit);

        RETURN l_lock_handler;
    END request_lock_with_timeout;


    PROCEDURE release_lock (p_lock_handler IN t_lockhandler)
    IS
    BEGIN
        IF p_lock_handler IS NOT NULL
        THEN
            ikis_sys.ikis_lock.releace_lock (p_lock_handler);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            NULL;
    END release_lock;

    PROCEDURE Sleep (p_sec NUMBER)
    IS
    BEGIN
        IKIS_LOCK.sleep (p_sec);
    END;

    FUNCTION Try_Parse_Dt (p_Val IN VARCHAR2, p_Fmt IN VARCHAR2)
        RETURN DATE
    IS
    BEGIN
        RETURN TO_DATE (p_Val, p_Fmt);
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    --Переведення тексту в число з поверненням NULL, якщо хоч якесь виключення
    FUNCTION tnumber (p_number              VARCHAR2,
                      p_format              VARCHAR2 DEFAULT '999999999999D999',
                      p_decimal_separator   VARCHAR2 DEFAULT '.')
        RETURN NUMBER
    IS
    BEGIN
        RETURN TO_NUMBER (
                   p_number,
                   p_format,
                      'NLS_NUMERIC_CHARACTERS='''
                   || p_decimal_separator
                   || ' ''');
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;


    FUNCTION TrimXMLStr (p_Str IN VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN TRIM (
                   UTL_I18N.raw_to_char (
                       REPLACE (UTL_I18N.string_to_raw (p_Str), '0A', '')));
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    FUNCTION GetUserLogin (P_WU_ID IN NUMBER)
        RETURN VARCHAR2
    IS
        l_login   VARCHAR2 (250);
    BEGIN
        SELECT wu_login
          INTO l_login
          FROM ikis_sysweb.V$ALL_USERS
         WHERE wu_id = P_WU_ID;

        RETURN l_login;
    END;

    FUNCTION GetUserPib (P_WU_ID IN NUMBER)
        RETURN VARCHAR2
    IS
        l_pib   VARCHAR2 (250);
    BEGIN
        SELECT wu_pib
          INTO l_pib
          FROM ikis_sysweb.V$ALL_USERS
         WHERE wu_id = P_WU_ID;

        RETURN l_pib;
    END;

    FUNCTION GetCurrOrg
        RETURN NUMBER
    IS
    BEGIN
        RETURN TO_NUMBER (SYS_CONTEXT ('USS_ESR', 'ORG'));
    END;

    FUNCTION GetCurrOrgName
        RETURN VARCHAR2
    IS
        l_name   VARCHAR2 (1000);
    BEGIN
        SELECT org_name
          INTO l_name
          FROM v_opfu
         WHERE org_id = TO_NUMBER (SYS_CONTEXT ('USS_ESR', 'ORG'));

        RETURN l_name;
    END;

    FUNCTION GetCurrOrgTo
        RETURN NUMBER
    IS
        l_org_to   NUMBER;
    BEGIN
        SELECT MAX (org_to)
          INTO l_org_to
          FROM v_opfu
         WHERE org_id = TO_NUMBER (SYS_CONTEXT ('USS_ESR', 'ORG'));

        RETURN l_org_to;
    END;


    FUNCTION GetCurrWu
        RETURN NUMBER
    IS
    BEGIN
        RETURN TO_NUMBER (SYS_CONTEXT ('USS_ESR', 'USSUID'));
    END;

    FUNCTION GetCurrWut
        RETURN NUMBER
    IS
    BEGIN
        RETURN TO_NUMBER (SYS_CONTEXT ('USS_ESR', 'IUTP'));
    END;

    FUNCTION GetCurrLogin
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN SYS_CONTEXT ('USS_ESR', 'LOGIN');
    END;

    FUNCTION GetCurrUserTp
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN SYS_CONTEXT ('USS_ESR', 'IUTPCODE');
    END;

    FUNCTION GetCurrUserPIB (P_MODE IN NUMBER DEFAULT 0)
        RETURN VARCHAR2
    IS
        l_pib       VARCHAR2 (250);
        l_curr_wu   NUMBER;
    BEGIN
        l_curr_wu := GetCurrWu;

        SELECT wu_pib
          INTO l_pib
          FROM ikis_sysweb.V$ALL_USERS
         WHERE wu_id = l_curr_wu;

        RETURN l_pib;
    END;


    FUNCTION CheckUserRole (p_role VARCHAR2)
        RETURN BOOLEAN
    IS
        l_user_info    SYS_REFCURSOR;
        l_user_roles   SYS_REFCURSOR;
        l_wr_id        NUMBER;
        l_wr_name      VARCHAR2 (200);
        l_wr_wut       VARCHAR2 (200);
        l_wr_descr     VARCHAR2 (2000);
    BEGIN
        ikis_sysweb.ikis_dnet_auth.GetUserInfo (
            p_session_id   => SYS_CONTEXT ('USS_ESR', 'SESSION'),
            p_user_info    => l_user_info,
            p_user_roles   => l_user_roles);

        LOOP
            FETCH l_user_roles
                INTO l_wr_id,
                     l_wr_name,
                     l_wr_wut,
                     l_wr_descr;

            EXIT WHEN l_user_roles%NOTFOUND;

            IF l_wr_name = UPPER (p_role)
            THEN
                CLOSE l_user_roles;

                RETURN TRUE;
            END IF;
        END LOOP;

        CLOSE l_user_roles;

        RETURN FALSE;
    END;

    FUNCTION CheckUserRoleStr (p_role VARCHAR2)
        RETURN VARCHAR2
    IS
        l_user_info    SYS_REFCURSOR;
        l_user_roles   SYS_REFCURSOR;
        l_wr_id        NUMBER;
        l_wr_name      VARCHAR2 (200);
        l_wr_wut       VARCHAR2 (200);
        l_wr_descr     VARCHAR2 (2000);
    BEGIN
        ikis_sysweb.ikis_dnet_auth.GetUserInfo (
            p_session_id   => SYS_CONTEXT ('USS_ESR', 'SESSION'),
            p_user_info    => l_user_info,
            p_user_roles   => l_user_roles);

        LOOP
            FETCH l_user_roles
                INTO l_wr_id,
                     l_wr_name,
                     l_wr_wut,
                     l_wr_descr;

            EXIT WHEN l_user_roles%NOTFOUND;

            IF l_wr_name = UPPER (p_role)
            THEN
                CLOSE l_user_roles;

                RETURN 'T';
            END IF;
        END LOOP;

        CLOSE l_user_roles;

        RETURN 'F';
    END;

    PROCEDURE LOG (p_Src              VARCHAR2,
                   p_Obj_Tp           VARCHAR2,
                   p_Obj_Id           NUMBER,
                   p_Regular_Params   VARCHAR2,
                   p_Lob_Param        CLOB DEFAULT NULL)
    IS
    BEGIN
        Ikis_Sys.Ikis_Procedure_Log.LOG (UPPER (p_Src),
                                         p_Obj_Tp,
                                         p_Obj_Id,
                                         p_Regular_Params,
                                         p_Lob_Param);
    END;

    --========================================
    PROCEDURE validate_param (p_val VARCHAR2)
    IS
        l_val   VARCHAR2 (4000);
        l_cnt   NUMBER;
    BEGIN
        IF Ikis_Sysweb.IKIS_HTMLDB_COMMON.validate_param (p_val) > 0
        THEN
            raise_application_error (-20000, 'Помилка вхідних данних!');
        END IF;
    END;

    --========================================
    FUNCTION b64_decode (p_clob CLOB)
        RETURN CLOB
    IS
        l_clob     CLOB;
        l_len      NUMBER;
        l_pos      NUMBER := 1;
        l_buffer   VARCHAR2 (32767);
        l_amount   NUMBER := 32400;
    BEGIN
        l_len := DBMS_LOB.getlength (p_clob);
        DBMS_LOB.createtemporary (l_clob, TRUE);

        WHILE l_pos <= l_len
        LOOP
            DBMS_LOB.read (p_clob,
                           l_amount,
                           l_pos,
                           l_buffer);
            l_buffer :=
                UTL_ENCODE.text_decode (l_buffer,
                                        encoding   => UTL_ENCODE.base64);
            l_pos := l_pos + l_amount;
            DBMS_LOB.writeappend (l_clob, LENGTH (l_buffer), l_buffer);
        END LOOP;

        RETURN l_clob;
    END;
--========================================
BEGIN
    -- Initialization
    NULL;
END TOOLS;
/