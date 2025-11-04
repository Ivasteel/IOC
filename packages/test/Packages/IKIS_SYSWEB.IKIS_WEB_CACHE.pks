/* Formatted on 8/12/2025 6:11:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.IKIS_WEB_CACHE
IS
    -- Author  : VANO
    -- Created : 31.01.2017 15:08:31
    -- Purpose : Масиви зберігання параметрів сесійних

    PROCEDURE GetUserAttr (p_username       w_users.wu_login%TYPE,
                           p_uid        OUT w_users.wu_id%TYPE,
                           p_wut        OUT w_users.wu_wut%TYPE,
                           p_org        OUT w_users.wu_org%TYPE,
                           p_trc        OUT w_users.wu_trc%TYPE,
                           p_ppfu       OUT w_users.wu_org%TYPE);

    FUNCTION is_role_assigned (p_username   IN VARCHAR2,
                               p_role       IN VARCHAR2,
                               p_user_tp       VARCHAR2)
        RETURN BOOLEAN;
END IKIS_WEB_CACHE;
/


/* Formatted on 8/12/2025 6:11:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.IKIS_WEB_CACHE
IS
    TYPE t_cache_usr IS TABLE OF t_row_usr
        INDEX BY VARCHAR2 (30);

    v_cache_usr    t_cache_usr;

    TYPE t_cache_role IS TABLE OF BOOLEAN
        INDEX BY VARCHAR2 (70);

    v_cache_role   t_cache_role;

    PROCEDURE GetUserAttr (p_username       w_users.wu_login%TYPE,
                           p_uid        OUT w_users.wu_id%TYPE,
                           p_wut        OUT w_users.wu_wut%TYPE,
                           p_org        OUT w_users.wu_org%TYPE,
                           p_trc        OUT w_users.wu_trc%TYPE,
                           p_ppfu       OUT w_users.wu_org%TYPE)
    IS
        v_cache_usr_value   t_row_usr;
    BEGIN
        BEGIN
            v_cache_usr_value := v_cache_usr (p_username);
        EXCEPTION
            WHEN OTHERS
            THEN
                BEGIN
                    SELECT wu_id,
                           wu_wut,
                           wu_org,
                           wu_trc,
                           org_org
                      INTO p_uid,
                           p_wut,
                           p_org,
                           p_trc,
                           p_ppfu
                      FROM w_users, v_opfu
                     WHERE wu_login = p_username AND wu_org = org_id;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        p_wut := 0;
                        p_uid := -1;
                        p_org := -1;
                        p_trc := 0;
                        p_ppfu := -1;
                END;

                v_cache_usr_value :=
                    t_row_usr (p_uid,
                               p_wut,
                               p_org,
                               p_trc,
                               p_ppfu);
                v_cache_usr (p_username) := v_cache_usr_value;
        END;
    END GetUserAttr;

    FUNCTION is_role_assigned (p_username   IN VARCHAR2,
                               p_role       IN VARCHAR2,
                               p_user_tp       VARCHAR2)
        RETURN BOOLEAN
    IS
        l_cnt                INTEGER;
        v_idx                VARCHAR2 (70);
        v_cache_role_value   BOOLEAN;
    BEGIN
        v_idx :=
            UPPER (
                   TRIM (p_username)
                || '#'
                || TRIM (p_role)
                || '#'
                || TRIM (p_user_tp));

        BEGIN
            v_cache_role_value := v_cache_role (v_idx);
        EXCEPTION
            WHEN OTHERS
            THEN
                BEGIN
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
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        l_cnt := 0;
                END;

                v_cache_role_value := l_cnt > 0;
                v_cache_role (v_idx) := v_cache_role_value;
        END;

        RETURN v_cache_role_value;
    END;
END IKIS_WEB_CACHE;
/