/* Formatted on 8/12/2025 5:59:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.TOOLS
IS
    -- Author  : VANO
    -- Created : 11.02.2021 18:40:37
    -- Purpose : Допоміжні функції

    gINSTANCE_LOCK_NAME   VARCHAR2 (100);

    SUBTYPE t_lockhandler IS VARCHAR2 (100);

    SUBTYPE t_msg IS VARCHAR2 (4000);

    TYPE t_str_array IS TABLE OF VARCHAR2 (32767);

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

    -- перевірка ролі поточного користувача
    -- 1 - є, 0 - нема
    FUNCTION CheckCurrUserRole (p_role IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION GetCurrUserPIB (P_MODE IN NUMBER DEFAULT 0)
        RETURN VARCHAR2;

    FUNCTION GetUserLogin (P_WU_ID IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION GetUserPib (P_WU_ID IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE HANDLE_DNET_CONNECTION (
        p_session_id        VARCHAR2,
        p_absolute_url      VARCHAR2,
        p_ip_address     IN VARCHAR2 DEFAULT NULL);

    PROCEDURE handle_dnet_connection_ex (
        p_session_id        VARCHAR2,
        p_absolute_url      VARCHAR2,
        p_ip_address     IN VARCHAR2 DEFAULT NULL);

    FUNCTION GetHistSession (p_hs_wu histsession.hs_wu%TYPE:= NULL)
        RETURN histsession.hs_id%TYPE;

    FUNCTION GetHistSessionA
        RETURN histsession.hs_id%TYPE;

    FUNCTION GetHistSessionCmes
        RETURN histsession.hs_id%TYPE;

    FUNCTION get_clean_blob
        RETURN BLOB;

    FUNCTION get_clean_number
        RETURN NUMBER;

    PROCEDURE RPT_RESET;

    FUNCTION b64_decode (p_clob CLOB)
        RETURN CLOB;

    FUNCTION ConvertC2B (p_src CLOB)
        RETURN BLOB;

    FUNCTION ConvertB2C (p_src BLOB, p_encoding IN VARCHAR2 DEFAULT NULL)
        RETURN CLOB;

    FUNCTION IfTrue (p_condition   VARCHAR2,
                     p_true_val    VARCHAR2,
                     p_false_val   VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION IfTrue (p_condition VARCHAR2, p_true_val DATE, p_false_val DATE)
        RETURN DATE;

    PROCEDURE WriteMsg (P_SOURCE VARCHAR2, p_message VARCHAR2 DEFAULT NULL);

    -- info:   Установка першого символу кожного слова в верхній регістр
    -- params: p_str - строка
    -- note:   враховано некоректність роботи стандартної функції INITCAP при наявності в словах символів "’''`"
    FUNCTION init_cap (p_str VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Get_Param_Val (p_Prm_Code IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Get_Param_Val_def (p_Prm_Code    IN VARCHAR2,
                                p_Def_Value   IN VARCHAR2 := NULL)
        RETURN VARCHAR2;


    FUNCTION Try_Parse_Dt (p_Val IN VARCHAR2, p_Fmt IN VARCHAR2)
        RETURN DATE;

    FUNCTION Try_Parse_Number (p_Val IN VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Add_Err (p_Condition    IN     BOOLEAN,
                       p_Msg          IN     VARCHAR2,
                       p_Error_List   IN OUT VARCHAR2);

    PROCEDURE LOG (p_src              VARCHAR2,
                   p_obj_tp           VARCHAR2,
                   p_obj_id           NUMBER,
                   p_regular_params   VARCHAR2,
                   p_lob_param        CLOB DEFAULT NULL);

    FUNCTION GetStartPackageName (p_call_stack IN CLOB)
        RETURN VARCHAR2;

    FUNCTION GetAuditStack (p_call_stack IN CLOB)
        RETURN VARCHAR2;

    FUNCTION split_str (p_str IN VARCHAR2, p_delim IN VARCHAR2:= '#')
        RETURN t_str_array
        PIPELINED;

    FUNCTION split_str2 (p_str IN VARCHAR2, p_delim IN VARCHAR2:= '#')
        RETURN VARCHAR2
        SQL_MACRO;

    PROCEDURE validate_param (p_val VARCHAR2);
END TOOLS;
/


GRANT EXECUTE ON USS_VISIT.TOOLS TO DNET_PROXY
/

GRANT EXECUTE ON USS_VISIT.TOOLS TO II01RC_USS_VISIT_WEB
/

GRANT EXECUTE ON USS_VISIT.TOOLS TO IKIS_RBM
/

GRANT EXECUTE ON USS_VISIT.TOOLS TO PORTAL_PROXY
/

GRANT EXECUTE ON USS_VISIT.TOOLS TO SBOND
/

GRANT EXECUTE ON USS_VISIT.TOOLS TO USS_ESR
/

GRANT EXECUTE ON USS_VISIT.TOOLS TO USS_PERSON
/

GRANT EXECUTE ON USS_VISIT.TOOLS TO USS_RNSP
/


/* Formatted on 8/12/2025 6:00:03 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.TOOLS
IS
    g_curr_org    NUMBER;
    g_curr_root   NUMBER;

    PROCEDURE init_tools
    IS
    BEGIN
        gINSTANCE_LOCK_NAME := 'USS_VISIT:';
        g_curr_org := GetCurrOrg;
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
        --ikis_sysweb.ikis_debug_pipe.WriteMsg(p_msg => USS_VISIT_CONTEXT.gORG);
        --ikis_sysweb.ikis_debug_pipe.WriteMsg(p_msg => USS_VISIT_CONTEXT.GetContext(USS_VISIT_CONTEXT.gORG));
        RETURN TO_NUMBER (
                   USS_VISIT_CONTEXT.GetContext (USS_VISIT_CONTEXT.gORG));
    END;

    FUNCTION GetCurrOrgTo
        RETURN NUMBER
    IS
        l_org_to   NUMBER;
    BEGIN
        SELECT MAX (org_to)
          INTO l_org_to
          FROM v_opfu
         WHERE org_id =
               TO_NUMBER (
                   USS_VISIT_CONTEXT.GetContext (USS_VISIT_CONTEXT.gORG));

        RETURN l_org_to;
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
        RETURN TO_NUMBER (
                   USS_VISIT_CONTEXT.GetContext (USS_VISIT_CONTEXT.gUID));
    END;

    FUNCTION GetCurrWut
        RETURN NUMBER
    IS
    BEGIN
        RETURN TO_NUMBER (USS_VISIT_CONTEXT.GetContext ('iutp'));
    END;

    FUNCTION GetCurrLogin
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN USS_VISIT_CONTEXT.GetContext (USS_VISIT_CONTEXT.gLogin);
    END;

    -- перевірка ролі поточного користувача
    -- 1 - є, 0 - нема
    FUNCTION CheckCurrUserRole (p_role IN VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        RETURN CASE
                   WHEN is_role_assigned (
                            USS_VISIT_CONTEXT.GetContext (
                                USS_VISIT_CONTEXT.gLogin),
                            UPPER (p_role),
                            USS_VISIT_CONTEXT.GetContext (
                                USS_VISIT_CONTEXT.gUserTPCode))
                   THEN
                       1
                   ELSE
                       0
               END;
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
          FROM ikis_sysweb.v$all_users
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
          FROM ikis_sysweb.v$all_users
         WHERE wu_id = P_WU_ID;

        RETURN l_pib;
    END;

    PROCEDURE HANDLE_DNET_CONNECTION (
        p_session_id        VARCHAR2,
        p_absolute_url      VARCHAR2,
        p_ip_address     IN VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        --DBMS_SESSION.RESET_PACKAGE;
        EXECUTE IMMEDIATE 'ALTER SESSION SET cell_offload_processing=FALSE';

        uss_visit_context.SetDnetVisitContext (p_session_id);
        DBMS_SESSION.set_identifier (p_absolute_url);
        init_tools;
    END;

    PROCEDURE handle_dnet_connection_ex (
        p_session_id        VARCHAR2,
        p_absolute_url      VARCHAR2,
        p_ip_address     IN VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        --DBMS_SESSION.RESET_PACKAGE;
        EXECUTE IMMEDIATE 'ALTER SESSION SET cell_offload_processing=FALSE';

        uss_visit_context.SetDnetVisitContext (p_session_id, p_ip_address);
        DBMS_SESSION.set_identifier (p_absolute_url);
        init_tools;
    END;

    FUNCTION GetHistSession (p_hs_wu histsession.hs_wu%TYPE:= NULL)
        RETURN histsession.hs_id%TYPE
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        --#73983 2021.12.09
        INSERT INTO histsession (hs_id, hs_wu, hs_dt)
             VALUES (
                        0,
                        NVL (
                            p_hs_wu,
                            USS_VISIT_CONTEXT.GetContext (
                                USS_VISIT_CONTEXT.gUID)),
                        SYSDATE)
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

    FUNCTION GetHistSessionA
        RETURN histsession.hs_id%TYPE
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;

        l_hs   histsession.hs_id%TYPE;
    BEGIN
        l_hs := GetHistSession;

        COMMIT;

        RETURN l_hs;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'TOOLS.GetHistSession: ' || CHR (10) || SQLERRM);
    END;

    FUNCTION GetHistSessionCmes
        RETURN histsession.hs_id%TYPE
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        INSERT INTO histsession (hs_id, hs_cu, hs_dt)
             VALUES (0, ikis_rbm.tools.GetCurrentCu, SYSDATE)
          RETURNING hs_id
               INTO l_hs;

        RETURN l_hs;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'TOOLS.GetHistSessionCmes: ' || CHR (10) || SQLERRM);
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

    FUNCTION get_clean_number
        RETURN NUMBER
    IS
        l_id   NUMBER := NULL;
    BEGIN
        RETURN l_id;
    END;

    PROCEDURE RPT_RESET
    IS
    BEGIN
        ROLLBACK;

        EXECUTE IMMEDIATE 'ALTER SESSION SET cell_offload_processing=FALSE';

        DBMS_SESSION.RESET_PACKAGE ();
    END;

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

    FUNCTION ConvertB2C (p_src BLOB, p_encoding IN VARCHAR2 DEFAULT NULL)
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

        DBMS_LOB.converttoclob (
            dest_lob       => l_clob,
            src_blob       => p_src,
            amount         => DBMS_LOB.lobmaxsize,
            dest_offset    => l_dest_offsset,
            src_offset     => l_src_offsset,
            blob_csid      =>
                CASE
                    WHEN p_encoding IS NULL THEN DBMS_LOB.default_csid
                    ELSE NLS_CHARSET_ID (p_encoding)
                END,
            lang_context   => l_lang_context,
            warning        => l_warning);

        RETURN l_clob;
    END;

    FUNCTION IfTrue (p_condition   VARCHAR2,
                     p_true_val    VARCHAR2,
                     p_false_val   VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN CASE
                   WHEN p_condition = 'T' THEN p_true_val
                   ELSE p_false_val
               END;
    END;

    FUNCTION IfTrue (p_condition VARCHAR2, p_true_val DATE, p_false_val DATE)
        RETURN DATE
    IS
    BEGIN
        RETURN CASE
                   WHEN p_condition = 'T' THEN p_true_val
                   ELSE p_false_val
               END;
    END;

    PROCEDURE WriteMsg (P_SOURCE VARCHAR2, p_message VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        IF p_message IS NULL
        THEN
            IKIS_SYS.IKIS_AUDIT.WriteMsg (
                p_msg_type   => 'USER_ACTIVITY',
                p_msg_text   =>
                       P_SOURCE
                    || '#'
                    || SYS_CONTEXT ('USERENV', 'CLIENT_IDENTIFIER'));
        ELSE
            IKIS_SYS.IKIS_AUDIT.WriteMsg (
                p_msg_type   => 'USER_ACTIVITY',
                p_msg_text   =>
                       P_SOURCE
                    || '#'
                    || SYS_CONTEXT ('USERENV', 'CLIENT_IDENTIFIER')
                    || '#'
                    || p_message);
        END IF;
    END;

    -- info:   Установка першого символу кожного слова в верхній регістр
    -- params: p_str - строка
    -- note:   враховано некоректність роботи стандартної функції INITCAP при наявності в словах символів "’''`"
    FUNCTION init_cap (p_str VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN (REPLACE (INITCAP (REGEXP_REPLACE (p_str, '[’''`]', '666')),
                         '666',
                         '’'));
    END;

    FUNCTION Get_Param_Val (p_Prm_Code IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Prm_Value   Paramsvisit.Prm_Value%TYPE;
    BEGIN
        SELECT v.Prm_Value
          INTO l_Prm_Value
          FROM Paramsvisit v
         WHERE v.Prm_Code = UPPER (p_Prm_Code);

        RETURN l_Prm_Value;
    END;


    FUNCTION Get_Param_Val_Def (p_Prm_Code    IN VARCHAR2,
                                p_Def_Value   IN VARCHAR2 := NULL)
        RETURN VARCHAR2
    IS
        l_Prm_Value   Paramsvisit.Prm_Value%TYPE;
    BEGIN
        SELECT NVL (MAX (v.Prm_Value), p_Def_Value)
          INTO l_Prm_Value
          FROM Paramsvisit v
         WHERE v.Prm_Code = UPPER (p_Prm_Code);

        RETURN l_Prm_Value;
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

    FUNCTION Try_Parse_Number (p_Val IN VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        RETURN TO_NUMBER (p_Val);
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    PROCEDURE Add_Err (p_Condition    IN     BOOLEAN,
                       p_Msg          IN     VARCHAR2,
                       p_Error_List   IN OUT VARCHAR2)
    IS
    BEGIN
        IF p_Condition
        THEN
            p_Error_List := p_Error_List || ' ' || p_Msg || ',';
        END IF;
    END;


    PROCEDURE LOG (p_src              VARCHAR2,
                   p_obj_tp           VARCHAR2,
                   p_obj_id           NUMBER,
                   p_regular_params   VARCHAR2,
                   p_lob_param        CLOB DEFAULT NULL)
    IS
    BEGIN
        IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (UPPER (p_src),
                                         UPPER (p_obj_tp),
                                         p_obj_id,
                                         p_regular_params,
                                         p_lob_param);
    END;

    FUNCTION split_str (p_str IN VARCHAR2, p_delim IN VARCHAR2:= '#')
        RETURN t_str_array
        PIPELINED
    AS
        l_str   LONG := p_str || p_delim;
        l_n     NUMBER;
    BEGIN
        LOOP
            l_n := INSTR (l_str, p_delim);
            EXIT WHEN (NVL (l_n, 0) = 0);
            PIPE ROW (LTRIM (RTRIM (SUBSTR (l_str, 1, l_n - 1))));
            l_str := SUBSTR (l_str, l_n + 1);
        END LOOP;

        RETURN;
    END split_str;

    FUNCTION split_str2 (p_str IN VARCHAR2, p_delim IN VARCHAR2:= '#')
        RETURN VARCHAR2
        SQL_MACRO
    IS
    BEGIN
        RETURN q'{
      select trim(regexp_substr(p_str,'[^' || p_delim || ']+', 1, level)) as substring
      from dual
      connect by regexp_substr(p_str, '[^' || p_delim || ']+', 1, level) is not null
    }';
    END split_str2;

    FUNCTION GetStartPackageName (p_call_stack IN CLOB)
        RETURN VARCHAR2
    IS
        TYPE t_rows IS TABLE OF VARCHAR2 (4000)
            INDEX BY BINARY_INTEGER;

        l_rows   t_rows;
        l_res    VARCHAR2 (1000);
        l_row    VARCHAR2 (1000);
        l_idx    NUMBER;
    BEGIN
        WITH rws AS (SELECT p_call_stack str FROM DUAL)
        SELECT VALUE     AS row_data
          BULK COLLECT INTO l_rows
          FROM (    SELECT REGEXP_SUBSTR (str,
                                          '[^' || CHR (10) || ']+',
                                          1,
                                          LEVEL)    VALUE
                      FROM rws
                CONNECT BY LEVEL <=
                             LENGTH (str)
                           - LENGTH (REPLACE (str, CHR (10)))
                           + 1)
         WHERE TRIM (VALUE) IS NOT NULL;

        IF l_rows.COUNT = 0
        THEN
            RETURN NULL;
        END IF;

        l_idx := l_rows.COUNT;

        WHILE l_row IS NULL AND l_idx > 0
        LOOP
            l_row := l_rows (l_idx);

            IF l_row IS NOT NULL
            THEN
                IF INSTR (LOWER (l_row), 'anonymous') > 0
                THEN
                    l_row := NULL;
                END IF;
            END IF;

            l_idx := l_idx - 1;
        END LOOP;

        BEGIN
              SELECT substring
                INTO l_res
                FROM (SELECT ROWNUM rn, substring
                        FROM (    SELECT TRIM (REGEXP_SUBSTR (l_row,
                                                              '[^' || ' ' || ']+',
                                                              1,
                                                              LEVEL))    AS substring
                                    FROM DUAL
                              CONNECT BY REGEXP_SUBSTR (l_row,
                                                        '[^' || ' ' || ']+',
                                                        1,
                                                        LEVEL)
                                             IS NOT NULL))
            ORDER BY rn DESC
               FETCH FIRST 1 ROWS ONLY;

            RETURN l_res;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RETURN NULL;
        END;
    END;

    FUNCTION GetAuditStack (p_call_stack IN CLOB)
        RETURN VARCHAR2
    IS
        TYPE t_rows IS TABLE OF VARCHAR2 (4000)
            INDEX BY BINARY_INTEGER;

        l_rows      t_rows;
        l_res       VARCHAR2 (4000);
        l_row       VARCHAR2 (1000);
        l_row_res   VARCHAR2 (1000);
    BEGIN
        WITH rws AS (SELECT p_call_stack str FROM DUAL)
        SELECT VALUE     AS row_data
          BULK COLLECT INTO l_rows
          FROM (    SELECT REGEXP_SUBSTR (str,
                                          '[^' || CHR (10) || ']+',
                                          1,
                                          LEVEL)    VALUE
                      FROM rws
                CONNECT BY LEVEL <=
                             LENGTH (str)
                           - LENGTH (REPLACE (str, CHR (10)))
                           + 1)
         WHERE TRIM (VALUE) IS NOT NULL;

        IF l_rows.COUNT = 0
        THEN
            RETURN NULL;
        END IF;

        FOR i IN 4 .. l_rows.COUNT
        LOOP
            l_row := l_rows (i);

            SELECT LISTAGG (substring, ' ')
              INTO l_row_res
              FROM (SELECT ROWNUM    rn,
                           CASE
                               WHEN ROWNUM = 2
                               THEN
                                   LPAD (substring, 10, ' ') || '   '
                               ELSE
                                   substring
                           END       substring
                      FROM (    SELECT TRIM (REGEXP_SUBSTR (l_row,
                                                            '[^' || ' ' || ']+',
                                                            1,
                                                            LEVEL))    AS substring
                                  FROM DUAL
                            CONNECT BY REGEXP_SUBSTR (l_row,
                                                      '[^' || ' ' || ']+',
                                                      1,
                                                      LEVEL)
                                           IS NOT NULL))
             WHERE rn > 1;

            l_res := l_res || l_row_res || CHR (10);
        END LOOP;

        RETURN l_Res;
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
BEGIN
    -- Initialization
    init_tools;
END TOOLS;
/