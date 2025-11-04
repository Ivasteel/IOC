/* Formatted on 8/12/2025 5:54:20 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_EXCH.TOOLS
IS
    -- Author  : VANO
    -- Created : 10.06.2021 17:58:31
    -- Purpose : Допоміжні функції

    SUBTYPE t_msg IS VARCHAR2 (4000);

    TYPE r_message IS RECORD
    (
        msg_tp         VARCHAR2 (10),
        msg_tp_name    VARCHAR2 (20),
        msg_text       VARCHAR2 (4000)
    );

    TYPE t_messages IS TABLE OF r_message;


    gINSTANCE_LOCK_NAME   VARCHAR2 (100);

    SUBTYPE t_lockhandler IS VARCHAR2 (100);

    SUBTYPE t_msg IS VARCHAR2 (4000);

    FUNCTION request_lock (p_descr IN VARCHAR2)
        RETURN t_lockhandler;

    FUNCTION request_lock (p_descr               IN VARCHAR2,
                           p_error_msg           IN VARCHAR2,
                           p_release_on_commit   IN BOOLEAN DEFAULT TRUE)
        RETURN t_lockhandler;

    PROCEDURE release_lock (p_lock_handler IN t_lockhandler);

    PROCEDURE Sleep (p_sec NUMBER);

    FUNCTION GetCurrRoot
        RETURN NUMBER;

    FUNCTION GetCurrOrg
        RETURN NUMBER;

    FUNCTION GetCurrOrgName
        RETURN VARCHAR2;

    FUNCTION GetCurrWu
        RETURN NUMBER;

    FUNCTION GetCurrLogin
        RETURN VARCHAR2;

    FUNCTION GetCurrUserPIB (P_MODE IN NUMBER DEFAULT 0)
        RETURN VARCHAR2;

    FUNCTION GetUserLogin (P_WU_ID IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION GetUserPib (P_WU_ID IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE HANDLE_DNET_CONNECTION (p_session_id     VARCHAR2,
                                      p_absolute_url   VARCHAR2);

    FUNCTION get_clean_blob
        RETURN BLOB;

    -- Функції порівняння
    FUNCTION IsEqualS (val1 VARCHAR2, val2 VARCHAR2)
        RETURN BOOLEAN;

    FUNCTION IsEqualN (val1 NUMBER, val2 NUMBER)
        RETURN BOOLEAN;

    FUNCTION IsEqualD (val1 DATE, val2 DATE)
        RETURN BOOLEAN;

    --Функції конвертації типів
    FUNCTION ConvertC2BUTF8 (p_src CLOB)
        RETURN BLOB;

    FUNCTION ConvertC2B (p_src CLOB)
        RETURN BLOB;

    FUNCTION ConvertB2C (p_src BLOB)
        RETURN CLOB;

    PROCEDURE add_message (p_messages   IN OUT t_messages,
                           p_msg_tp     IN     VARCHAR2,
                           p_msg_text   IN     VARCHAR2);
END TOOLS;
/


GRANT EXECUTE ON USS_EXCH.TOOLS TO II01RC_USS_EXCH_WEB
/


/* Formatted on 8/12/2025 5:54:21 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_EXCH.TOOLS
IS
    g_curr_org    NUMBER;
    g_curr_root   NUMBER;

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


    FUNCTION GetCurrRoot
        RETURN NUMBER
    IS
    BEGIN
        --!!! Увага! Це коректно працюватиме лише якщо для кожної сесії ДО аутентифікації буде виконано DBMS_SESSION.RESET_PACKAGES.
        IF g_curr_root IS NULL
        THEN
            BEGIN
                SELECT org_id
                  INTO g_curr_org
                  FROM (    SELECT org_id, CONNECT_BY_ISLEAF AS leaf
                              FROM v_opfu
                        START WITH org_id = g_curr_org
                        CONNECT BY PRIOR org_org = org_id)
                 WHERE leaf = 1;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    g_curr_org := NULL;
            END;
        END IF;

        RETURN g_curr_root;
    END;

    FUNCTION GetCurrOrg
        RETURN NUMBER
    IS
    BEGIN
        RETURN TO_NUMBER (
                   USS_exch_CONTEXT.GetContext (USS_exch_CONTEXT.gORG));
    END;

    FUNCTION GetCurrOrgName
        RETURN VARCHAR2
    IS
        l_name   VARCHAR2 (1000);
    BEGIN
        SELECT org_name
          INTO l_name
          FROM v_opfu
         WHERE org_id = g_curr_org;

        RETURN l_name;
    END;

    FUNCTION GetCurrWu
        RETURN NUMBER
    IS
    BEGIN
        RETURN TO_NUMBER (USS_exch_CONTEXT.GetContext ('uid'));
    END;

    FUNCTION GetCurrLogin
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN USS_exch_CONTEXT.GetContext (USS_exch_CONTEXT.gLogin);
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
          FROM ikis_sysweb.v$w_users4hierarchy
         WHERE wu_id = l_curr_wu;

        RETURN l_pib;
    END;

    FUNCTION GetUserLogin (P_WU_ID IN NUMBER)
        RETURN VARCHAR2
    IS
        l_login   VARCHAR2 (250);
    BEGIN
        SELECT wu_login
          INTO l_login
          FROM ikis_sysweb.v$w_users_4gic
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
          FROM ikis_sysweb.v$w_users4hierarchy
         WHERE wu_id = P_WU_ID;

        RETURN l_pib;
    END;


    PROCEDURE HANDLE_DNET_CONNECTION (p_session_id     VARCHAR2,
                                      p_absolute_url   VARCHAR2)
    IS
    BEGIN
        --DBMS_SESSION.RESET_PACKAGE;
        EXECUTE IMMEDIATE 'ALTER SESSION SET cell_offload_processing=FALSE';

        uss_exch_context.SetDnetEXCHContext (p_session_id);
        DBMS_SESSION.set_identifier (p_absolute_url);
    END;

    FUNCTION get_clean_blob
        RETURN BLOB
    IS
        l_result   BLOB;
    BEGIN
        DBMS_LOB.createTemporary (l_result, TRUE);
        DBMS_LOB.OPEN (l_result, DBMS_LOB.LOB_ReadWrite);
        RETURN l_result;
    END;

    FUNCTION IsEqualS (val1 VARCHAR2, val2 VARCHAR2)
        RETURN BOOLEAN
    IS
    BEGIN
        IF    (val1 IS NULL AND val2 IS NOT NULL)
           OR (val2 IS NULL AND val1 IS NOT NULL)
        THEN
            RETURN FALSE;
        ELSE
            RETURN val1 IS NULL OR val1 = val2;
        END IF;
    END;

    FUNCTION IsEqualN (val1 NUMBER, val2 NUMBER)
        RETURN BOOLEAN
    IS
    BEGIN
        IF    (val1 IS NULL AND val2 IS NOT NULL)
           OR (val2 IS NULL AND val1 IS NOT NULL)
        THEN
            RETURN FALSE;
        ELSE
            RETURN val1 IS NULL OR val1 = val2;
        END IF;
    END;

    FUNCTION IsEqualD (val1 DATE, val2 DATE)
        RETURN BOOLEAN
    IS
    BEGIN
        IF    (val1 IS NULL AND val2 IS NOT NULL)
           OR (val2 IS NULL AND val1 IS NOT NULL)
        THEN
            RETURN FALSE;
        ELSE
            RETURN val1 IS NULL OR val1 = val2;
        END IF;
    END;

    FUNCTION ConvertC2BUTF8 (p_src CLOB)
        RETURN BLOB
    IS
        l_clob_offset    INTEGER;
        l_blob_offset    INTEGER;
        l_lang_context   INTEGER;
        l_convert_warn   INTEGER;

        l_result         BLOB;
    BEGIN
        l_clob_offset := 1;
        l_blob_offset := 1;
        l_lang_context := DBMS_LOB.default_lang_ctx;

        DBMS_LOB.createtemporary (l_result, TRUE);
        DBMS_LOB.convertToBlob (l_result,
                                p_src,
                                DBMS_LOB.lobmaxsize,
                                l_blob_offset,
                                l_clob_offset,
                                NLS_CHARSET_ID ('UTF8'),
                                l_lang_context,
                                l_convert_warn);

        RETURN l_result;
    END;

    FUNCTION ConvertC2B (p_src CLOB)
        RETURN BLOB
    IS
        l_clob_offset    INTEGER;
        l_blob_offset    INTEGER;
        l_lang_context   INTEGER;
        l_convert_warn   INTEGER;

        l_result         BLOB;
    BEGIN
        l_clob_offset := 1;
        l_blob_offset := 1;
        l_lang_context := DBMS_LOB.default_lang_ctx;

        DBMS_LOB.createtemporary (l_result, TRUE);
        DBMS_LOB.convertToBlob (l_result,
                                p_src,
                                DBMS_LOB.lobmaxsize,
                                l_blob_offset,
                                l_clob_offset,
                                DBMS_LOB.default_csid,
                                l_lang_context,
                                l_convert_warn);

        RETURN l_result;
    END;

    FUNCTION ConvertB2C (p_src BLOB)
        RETURN CLOB
    IS
        l_clob           CLOB;
        l_dest_offsset   INTEGER := 1;
        l_src_offsset    INTEGER := 1;
        l_lang_context   INTEGER := DBMS_LOB.default_lang_ctx;
        l_warning        INTEGER;
    BEGIN
        IF p_src IS NULL
        THEN
            RETURN NULL;
        END IF;

        DBMS_LOB.createTemporary (lob_loc => l_clob, cache => FALSE);

        DBMS_LOB.converttoclob (dest_lob       => l_clob,
                                src_blob       => p_src,
                                amount         => DBMS_LOB.lobmaxsize,
                                dest_offset    => l_dest_offsset,
                                src_offset     => l_src_offsset,
                                blob_csid      => DBMS_LOB.default_csid,
                                lang_context   => l_lang_context,
                                warning        => l_warning);

        RETURN l_clob;
    END;

    PROCEDURE add_message (p_messages   IN OUT t_messages,
                           p_msg_tp     IN     VARCHAR2,
                           p_msg_text   IN     VARCHAR2)
    IS
        l_msg   r_message;
    BEGIN
        l_msg.msg_tp := p_msg_tp;

        CASE p_msg_tp
            WHEN 'E'
            THEN
                l_msg.msg_tp_name := 'Помилка';
            WHEN 'W'
            THEN
                l_msg.msg_tp_name := 'Попередження';
            WHEN 'I'
            THEN
                l_msg.msg_tp_name := 'Інформаційне';
            ELSE
                l_msg.msg_tp_name := '-';
        END CASE;

        l_msg.msg_text := p_msg_text;
        p_messages.EXTEND ();
        p_messages (p_messages.COUNT) := l_msg;
    END;
BEGIN
    -- Initialization
    gINSTANCE_LOCK_NAME := 'USS_RNSP:';
    g_curr_org := GetCurrOrg;
END TOOLS;
/