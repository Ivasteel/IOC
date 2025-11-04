/* Formatted on 8/12/2025 6:11:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.IKIS_CONTEXT_CACHE
IS
    -- Author  : SBOND
    -- Created : 01.02.2017 13:35:59
    -- Purpose : ѕакет дл€ создани€ кеша на общесистемыне вещи
    --»де€ была в том, что бы сделать сесионные переменные пакета и не делать посто€нный запрос к данным (так как контекст проставл€етьс€ при любом обновлении)
    --и брать провер€ть наличее значени€ в пакете, а если нету делать запос к данным.

    --ѕока что не срабатывает
    --ѕакет не работает так как mod_plsql выполн€ет
    --(wpcs.c, 76) Executed 'begin dbms_session.reset_package; end;' (rc=0)
    --¬ св€зи с этим, состо€ние всех сесионных переменных пакета сбрасываетьс€
    --»дею нужно доразвивать. ѕакет не удал€ть и на пром не ставить. ѕока что.

    PROCEDURE GetUserAttrCache (p_session_id   IN     VARCHAR2,
                                p_username     IN     w_users.wu_login%TYPE,
                                p_uid             OUT w_users.wu_id%TYPE,
                                p_wut             OUT w_users.wu_wut%TYPE,
                                p_org             OUT w_users.wu_org%TYPE,
                                p_trc             OUT w_users.wu_trc%TYPE);

    FUNCTION is_role_assigned_cache (p_session_id   IN VARCHAR2,
                                     p_username     IN VARCHAR2,
                                     p_role         IN VARCHAR2,
                                     p_user_tp         VARCHAR2)
        RETURN BOOLEAN;

    PROCEDURE log_trace (p_session_id   IN VARCHAR2,
                         p_username     IN VARCHAR2,
                         p_text            VARCHAR2);
END IKIS_CONTEXT_CACHE;
/


/* Formatted on 8/12/2025 6:11:42 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.IKIS_CONTEXT_CACHE
IS
    -- Author  : SBOND
    -- Created : 01.02.2017 13:35:59
    -- Purpose : ѕакет дл€ создани€ кеша на общесистемыне вещи
    --»де€ была в том, что бы сделать сесионные переменные пакета и не делать посто€нный запрос к данным (так как контекст проставл€етьс€ при любом обновлении)
    --и брать провер€ть наличее значени€ в пакете, а если нету делать запос к данным.

    --ѕока что не срабатывает
    --ѕакет не работает так как mod_plsql выполн€ет
    --(wpcs.c, 76) Executed 'begin dbms_session.reset_package; end;' (rc=0)
    --¬ св€зи с этим, состо€ние всех сесионных переменных пакета сбрасываетьс€
    --»дею нужно доразвивать. ѕакет не удал€ть и на пром не ставить. ѕока что.

    TYPE tbl_role_assigned IS TABLE OF PLS_INTEGER
        INDEX BY VARCHAR2 (100);

    TYPE t_cache_usr_attr IS RECORD
    (
        f_uid         NUMBER (14),
        f_username    VARCHAR2 (30),
        f_wut         NUMBER (14),
        f_org         NUMBER (5),
        f_trc         VARCHAR2 (10),
        f_roles       tbl_role_assigned
    );

    TYPE tbl_cache_usr_attr IS TABLE OF t_cache_usr_attr
        INDEX BY VARCHAR2 (100);               --масив атрибт≥в по користувачу

    g_user_attr_cache_array   tbl_cache_usr_attr;

    PROCEDURE log_trace (p_session_id   IN VARCHAR2,
                         p_username     IN VARCHAR2,
                         p_text            VARCHAR2)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO trace4test (f_teim,
                                f_sid,
                                f_apex_session,
                                f_apex_user,
                                f_text)
             VALUES (SYSTIMESTAMP,
                     SYS_CONTEXT ('USERENV', 'SID'),
                     p_session_id,
                     p_username,
                     p_text);

        COMMIT;
    END;

    PROCEDURE GetUserAttrCache (p_session_id   IN     VARCHAR2,
                                p_username     IN     w_users.wu_login%TYPE,
                                p_uid             OUT w_users.wu_id%TYPE,
                                p_wut             OUT w_users.wu_wut%TYPE,
                                p_org             OUT w_users.wu_org%TYPE,
                                p_trc             OUT w_users.wu_trc%TYPE)
    IS
    BEGIN
        ikis_sysweb.ikis_context_cache.log_trace (v ('APP_SESSION'),
                                                  v ('USER'),
                                                  'u1');

        --поиск в кеше
        IF g_user_attr_cache_array.EXISTS (p_session_id || '#' || p_username)
        THEN
            p_uid :=
                g_user_attr_cache_array (p_session_id || '#' || p_username).f_uid;
            p_wut :=
                g_user_attr_cache_array (p_session_id || '#' || p_username).f_wut;
            p_org :=
                g_user_attr_cache_array (p_session_id || '#' || p_username).f_org;
            p_trc :=
                g_user_attr_cache_array (p_session_id || '#' || p_username).f_trc;
            ikis_sysweb.ikis_context_cache.log_trace (v ('APP_SESSION'),
                                                      v ('USER'),
                                                      'u2');
        ELSE
            --нет в кеше
            BEGIN
                SELECT wu_id,
                       wu_wut,
                       wu_org,
                       wu_trc
                  INTO p_uid,
                       p_wut,
                       p_org,
                       p_trc
                  FROM w_users
                 WHERE wu_login = p_username;
            EXCEPTION
                WHEN OTHERS
                THEN
                    BEGIN
                        p_wut := 0;
                        p_uid := -1;
                        p_org := -1;
                        p_trc := 0;
                    END;
            END;

            g_user_attr_cache_array (p_session_id || '#' || p_username).f_username :=
                p_username;
            g_user_attr_cache_array (p_session_id || '#' || p_username).f_uid :=
                p_uid;
            g_user_attr_cache_array (p_session_id || '#' || p_username).f_wut :=
                p_wut;
            g_user_attr_cache_array (p_session_id || '#' || p_username).f_org :=
                p_org;
            g_user_attr_cache_array (p_session_id || '#' || p_username).f_trc :=
                p_trc;
            ikis_sysweb.ikis_context_cache.log_trace (v ('APP_SESSION'),
                                                      v ('USER'),
                                                      'u3');
        END IF;

        ikis_sysweb.ikis_context_cache.log_trace (v ('APP_SESSION'),
                                                  v ('USER'),
                                                  'u4');
    END;

    --dbms_output.put_line('test2');
    FUNCTION is_role_assigned_cache (p_session_id   IN VARCHAR2,
                                     p_username     IN VARCHAR2,
                                     p_role         IN VARCHAR2,
                                     p_user_tp         VARCHAR2)
        RETURN BOOLEAN
    AS
        l_cnt   NUMBER := 0;
    BEGIN
        ikis_sysweb.ikis_context_cache.log_trace (v ('APP_SESSION'),
                                                  v ('USER'),
                                                  'r1');

        IF g_user_attr_cache_array.EXISTS (p_session_id || '#' || p_username)
        THEN
            ikis_sysweb.ikis_context_cache.log_trace (v ('APP_SESSION'),
                                                      v ('USER'),
                                                      'r2');

            IF g_user_attr_cache_array (p_session_id || '#' || p_username).f_roles.EXISTS (
                   p_role)
            THEN
                ikis_sysweb.ikis_context_cache.log_trace (v ('APP_SESSION'),
                                                          v ('USER'),
                                                          'r3');

                IF g_user_attr_cache_array (
                       p_session_id || '#' || p_username).f_roles (p_role) =
                   1
                THEN
                    ikis_sysweb.ikis_context_cache.log_trace (
                        v ('APP_SESSION'),
                        v ('USER'),
                        'r4');
                    l_cnt := 1;
                END IF;

                ikis_sysweb.ikis_context_cache.log_trace (v ('APP_SESSION'),
                                                          v ('USER'),
                                                          'r5');
            ELSE
                ikis_sysweb.ikis_context_cache.log_trace (v ('APP_SESSION'),
                                                          v ('USER'),
                                                          'r6');

                SELECT COUNT (1)
                  INTO l_cnt
                  FROM w_usr2roles
                 WHERE     wr_id = (SELECT wr_id
                                      FROM w_roles
                                     WHERE wr_name = UPPER (p_role))
                       AND wu_id =
                           (SELECT wu_id
                              FROM w_users, w_user_type
                             WHERE     wu_login = UPPER (p_username)
                                   AND wu_wut = wut_id
                                   AND wut_code = p_user_tp);

                ikis_sysweb.ikis_context_cache.log_trace (v ('APP_SESSION'),
                                                          v ('USER'),
                                                          'r7');

                IF l_cnt > 0
                THEN
                    g_user_attr_cache_array (
                        p_session_id || '#' || p_username).f_roles (p_role) :=
                        1;
                    ikis_sysweb.ikis_context_cache.log_trace (
                        v ('APP_SESSION'),
                        v ('USER'),
                        'r8');
                ELSE
                    ikis_sysweb.ikis_context_cache.log_trace (
                        v ('APP_SESSION'),
                        v ('USER'),
                        'r9');
                    g_user_attr_cache_array (
                        p_session_id || '#' || p_username).f_roles (p_role) :=
                        0;
                END IF;
            END IF;

            ikis_sysweb.ikis_context_cache.log_trace (v ('APP_SESSION'),
                                                      v ('USER'),
                                                      'r10');
        END IF;

        ikis_sysweb.ikis_context_cache.log_trace (v ('APP_SESSION'),
                                                  v ('USER'),
                                                  'r11');
        RETURN l_cnt > 0;
    END;
END IKIS_CONTEXT_CACHE;
/