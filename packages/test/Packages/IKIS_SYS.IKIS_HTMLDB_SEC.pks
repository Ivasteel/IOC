/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.ikis_htmldb_sec
IS
    -- Author  : YURA_A
    -- Created : 04.11.2005 14:58:55
    -- Purpose : Авторизация в приложениях HTMLDB

    -- Public type declarations
    FUNCTION get_auth (p_user VARCHAR2, p_rsrc VARCHAR2)
        RETURN BOOLEAN;

    FUNCTION is_string_valid (p_str VARCHAR2)
        RETURN BOOLEAN;
END ikis_htmldb_sec;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_HTMLDB_SEC FOR IKIS_SYS.IKIS_HTMLDB_SEC
/


/* Formatted on 8/12/2025 6:10:03 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.ikis_htmldb_sec
IS
    TYPE t_inj_chars IS TABLE OF VARCHAR2 (10);

    inj_chars   t_inj_chars;

    -- Private type declarations
    FUNCTION get_auth (p_user VARCHAR2, p_rsrc VARCHAR2)
        RETURN BOOLEAN
    IS
        l_cnt   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_cnt
          FROM v_all_user_accessed_rsrc x
         WHERE     x.grantee = UPPER (p_user)
               AND x.rat_object_name || '.' || x.rat_stp = p_rsrc;

        RETURN l_cnt > 0;
    END;

    FUNCTION is_string_valid (p_str VARCHAR2)
        RETURN BOOLEAN
    IS
    BEGIN
        FOR ch IN inj_chars.FIRST .. inj_chars.LAST
        LOOP
            IF INSTR (STR1 => LOWER (p_str), STR2 => inj_chars (ch)) > 0
            THEN
                RETURN TRUE;
            END IF;
        END LOOP;

        IF p_str IS NULL
        THEN
            RETURN TRUE;           --так надо для удобства составления фильтра
        ELSE
            RETURN FALSE;
        END IF;
    END;
BEGIN
    inj_chars :=
        t_inj_chars (',',
                     'select',
                     'delete',
                     'update',
                     'insert',
                     'merge',
                     'alter',
                     'create',
                     'drop',
                     'lock',
                     'truncate',
                     'set',
                     'grant',
                     'revoke');
END ikis_htmldb_sec;
/