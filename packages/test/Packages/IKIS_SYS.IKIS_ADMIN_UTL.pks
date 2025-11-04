/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.ikis_admin_utl
IS
    -- Author  : YURA_A
    -- Created : 21.10.2003 11:58:35
    -- Purpose : Административные процедуры

    PROCEDURE CompileSubSys (p_subsys ikis_subsys.ss_code%TYPE);

    ----------------------------------------
    -- YURA_A 18.12.2003 12:12:55
    ----------------------------------------
    -- Назначение : Создание пользователя ИКИС програмно
    -- Параметры  : имя, пароль, ФИО, нумидент, ид пользователя
    PROCEDURE Create_IKIS_USER (p_iu_username   IN     VARCHAR2,
                                p_iu_password   IN     VARCHAR2,
                                p_iu_name       IN     VARCHAR2,
                                p_iu_numident   IN     VARCHAR2,
                                p_uid              OUT NUMBER);


    ----------------------------------------
    -- RYABA 18.12.2003 13:40:55
    ----------------------------------------
    -- Назначение : Проверяет наличие активного пользователя
    -- Параметры  : имя
    -- Результат : True - если есть такой активный пользователь
    FUNCTION Exists_IKIS_USER (p_iu_username IN VARCHAR2)
        RETURN NUMBER;

    ----------------------------------------
    -- YURA_A 22.12.2003 9:52:28
    ----------------------------------------
    -- Назначение : Создание пользователя, который удален
    -- Параметры  : логин, ПИБ, нумидент, ид пользователя, дата создания, дата удаления
    PROCEDURE Create_IKIS_USER_DROPED (
        p_iu_username   IN     VARCHAR2,
        p_iu_name       IN     VARCHAR2,
        p_iu_numident   IN     VARCHAR2,
        p_uid              OUT NUMBER,
        p_iu_start_dt          DATE DEFAULT SYSDATE,
        p_iu_stop_dt           DATE DEFAULT SYSDATE);

    --Ryaba
    --Функція повертає найбільщий ІД користувача для № ОК ЗО
    FUNCTION GetUserByNumid (p_numident IN VARCHAR2)
        RETURN NUMBER;
END ikis_admin_utl;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_ADMIN_UTL FOR IKIS_SYS.IKIS_ADMIN_UTL
/


GRANT EXECUTE ON IKIS_SYS.IKIS_ADMIN_UTL TO II01RC_IKIS_SUPERUSER
/

GRANT EXECUTE ON IKIS_SYS.IKIS_ADMIN_UTL TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_ADMIN_UTL TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_ADMIN_UTL TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_ADMIN_UTL TO IKIS_SYSWEB WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_ADMIN_UTL TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_ADMIN_UTL TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_ADMIN_UTL TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_ADMIN_UTL TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_ADMIN_UTL TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_ADMIN_UTL TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_ADMIN_UTL TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_ADMIN_UTL TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_ADMIN_UTL TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:10:01 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.ikis_admin_utl
IS
    msgNotAllParCrUsr   NUMBER := 1713;

    PROCEDURE CompileSubSys (p_subsys ikis_subsys.ss_code%TYPE)
    IS
        l_owner   ikis_subsys.ss_owner%TYPE;
        l_cmd     VARCHAR2 (1000);
        l_cnt     NUMBER := 0;
    BEGIN
        debug.f ('Start procedure');
        DBMS_OUTPUT.put_line (
            RPAD ('Compile subsystem ' || p_subsys, 60, '-'));

        SELECT ikis_subsys.ss_owner
          INTO l_owner
          FROM ikis_subsys
         WHERE ikis_subsys.ss_code = p_subsys;

        FOR i_obj IN (  SELECT x.object_name, x.object_type
                          FROM dba_objects x
                         WHERE     x.object_type IN ('VIEW',
                                                     'PACKAGE',
                                                     'PACKAGE BODY',
                                                     'PROCEDURE',
                                                     'FUNCTION',
                                                     'TRIGGER')
                               AND x.status = 'INVALID'
                               AND x.owner = UPPER (l_owner)
                      ORDER BY x.object_type)
        LOOP
            IF i_obj.object_type IN ('PACKAGE', 'PACKAGE BODY')
            THEN
                IF i_obj.object_type = 'PACKAGE'
                THEN
                    l_cmd :=
                           'alter PACKAGE '
                        || l_owner
                        || '.'
                        || i_obj.object_name
                        || ' compile SPECIFICATION';
                ELSE
                    l_cmd :=
                           'alter PACKAGE '
                        || l_owner
                        || '.'
                        || i_obj.object_name
                        || ' compile BODY';
                END IF;
            ELSE
                l_cmd :=
                       'alter '
                    || i_obj.object_type
                    || ' '
                    || l_owner
                    || '.'
                    || i_obj.object_name
                    || ' compile';
            END IF;

            DBMS_OUTPUT.put_line (
                   'Compile: '
                || RPAD (i_obj.object_name, 35, ' ')
                || RPAD (i_obj.object_type, 15, ' '));

            EXECUTE IMMEDIATE l_cmd;

            l_cmd := NULL;
        END LOOP;

        --  dbms_output.disable;
        --  DBMS_UTILITY.COMPILE_SCHEMA (l_owner);
        --  dbms_output.enable;

        DBMS_OUTPUT.put_line (
            RPAD ('Compile subsystem ' || p_subsys || ' complete', 60, '-'));
        DBMS_OUTPUT.put_line (RPAD ('List of invalid objects:', 60, '-'));
        DBMS_OUTPUT.put_line (
               RPAD ('Object name', 35, ' ')
            || RPAD ('Object type', 15, ' ')
            || RPAD ('Status', 10, ' '));

        FOR inv_obg
            IN (SELECT x.object_name, x.object_type, x.status
                  FROM dba_objects x
                 WHERE x.status = 'INVALID' AND x.owner = UPPER (l_owner))
        LOOP
            DBMS_OUTPUT.put_line (
                   RPAD (inv_obg.object_name, 35, ' ')
                || RPAD (inv_obg.object_type, 15, ' ')
                || RPAD (inv_obg.status, 10, ' '));
            l_cnt := l_cnt + 1;
        END LOOP;

        IF l_cnt = 0
        THEN
            DBMS_OUTPUT.put_line (RPAD ('No row selected.', 60, '-'));
        ELSE
            DBMS_OUTPUT.put_line (
                RPAD ('Invalid object: ' || l_cnt, 60, '-'));
        END IF;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            DBMS_OUTPUT.put_line (
                RPAD ('Error on compile subsystem ' || p_subsys, 60, '-'));

            IF l_cmd IS NOT NULL
            THEN
                DBMS_OUTPUT.put_line ('With ' || l_cmd);
            END IF;

            DBMS_OUTPUT.put_line (SUBSTR (SQLERRM, 1, 255));
    END;

    PROCEDURE Create_IKIS_USER (p_iu_username   IN     VARCHAR2,
                                p_iu_password   IN     VARCHAR2,
                                p_iu_name       IN     VARCHAR2,
                                p_iu_numident   IN     VARCHAR2,
                                p_uid              OUT NUMBER)
    IS
        l_iusr_rowid       ROWID;
        l_iusr_id          NUMBER;
        exNotAllParCrUsr   EXCEPTION;
    BEGIN
        debug.f ('Start procedure');

        IF    p_iu_username IS NULL
           OR p_iu_password IS NULL
           OR p_iu_name IS NULL
           OR p_iu_numident IS NULL
        THEN
            RAISE exNotAllParCrUsr;
        END IF;

        debug.f ('Call rdm$ikis_users.create_ikis_user');
        rdm$ikis_users.create_ikis_user (p_iusr_rowid   => l_iusr_rowid,
                                         p_iusr_id      => l_iusr_id);
        COMMIT;
        debug.f ('Call rdm$ikis_users.update_ikis_user');
        rdm$ikis_users.update_ikis_user (
            p_iu_rowid        => l_iusr_rowid,
            p_iu_username     => p_iu_username,
            p_iu_password     => p_iu_password,
            p_iu_status       => ikis_const.v_dds_user_st_a,
            p_iu_is_expired   => ikis_const.v_dds_yn_y,
            p_iu_name         => p_iu_name,
            p_iu_numident     => p_iu_numident,
            p_iu_is_admin     => ikis_const.v_dds_yn_n,
            p_iu_comps        => '');
        COMMIT;

        SELECT ikis_users_attr.iusr_id
          INTO p_uid
          FROM ikis_users_attr
         WHERE ROWID = l_iusr_rowid;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN exNotAllParCrUsr
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgNotAllParCrUsr));
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'ikis_admin_utl.Create_IKIS_USER with ',
                    CHR (10) || SQLERRM));
    END;

    FUNCTION Exists_IKIS_USER (p_iu_username IN VARCHAR2)
        RETURN NUMBER
    IS
        l_res   NUMBER;
        l_cnt   NUMBER;
    BEGIN
        debug.f ('Start procedure');

        BEGIN
            SELECT iu_oraid
              INTO l_res
              FROM v_ikis_users
             WHERE     UPPER (iu_username) = UPPER (p_iu_username)
                   AND iu_status = ikis_const.v_dds_user_st_A;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                l_res := -1;
        END;

        IF l_res = -1
        THEN                              --для миграции спова YuraAP 20061130
            SELECT COUNT (1)
              INTO l_cnt
              FROM dba_users
             WHERE username = UPPER (p_iu_username);

            IF l_cnt > 0
            THEN
                raise_application_error (
                    -20000,
                       'Користувач '
                    || UPPER (p_iu_username)
                    || ' не зареєстрований як користувач ІКІС, але існує в БД. Для успішного проходження міграції, користувача '
                    || UPPER (p_iu_username)
                    || ' необхідно вилучити з БД Oracle.');
            END IF;
        END IF;

        debug.f ('Stop procedure');
        RETURN l_res;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'ikis_admin_utl.Exists_IKIS_USER with ',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE Create_IKIS_USER_DROPED (
        p_iu_username   IN     VARCHAR2,
        p_iu_name       IN     VARCHAR2,
        p_iu_numident   IN     VARCHAR2,
        p_uid              OUT NUMBER,
        p_iu_start_dt          DATE DEFAULT SYSDATE,
        p_iu_stop_dt           DATE DEFAULT SYSDATE)
    IS
    BEGIN
        debug.f ('Start procedure');

        INSERT INTO ikis_users_attr (iusr_id,
                                     iusr_name,
                                     iusr_numident,
                                     iusr_is_admin,
                                     iusr_st,
                                     iusr_comp,
                                     iusr_login,
                                     iusr_internal,
                                     iusr_start_dt,
                                     iusr_stop_dt,
                                     iusr_org)
             VALUES (-1 * sq_oth_default.NEXTVAL,
                     p_iu_name,
                     p_iu_numident,
                     ikis_const.v_dds_yn_n,
                     ikis_const.v_dds_user_st_d,
                     '',
                     p_iu_username,
                     ikis_const.v_dds_yn_n,
                     p_iu_start_dt,
                     p_iu_stop_dt,
                     ikis_common.GetAP_IKIS_OPFU)
          RETURNING iusr_id
               INTO p_uid;

        debug.f ('Stop procedure');
    END;

    FUNCTION GetUserByNumid (p_numident IN VARCHAR2)
        RETURN NUMBER
    IS
        l_usr   NUMBER;
    BEGIN
        debug.f ('Start procedure');

        SELECT CASE WHEN MAX (iusr_id) IS NULL THEN -1 ELSE MAX (iusr_id) END
          INTO l_usr
          FROM ikis_users_attr
         WHERE iusr_numident = p_numident;

        debug.f ('Stop procedure');
        RETURN l_usr;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'ikis_admin_utl.GetUserByNumid with ',
                    CHR (10) || SQLERRM));
    END;
END ikis_admin_utl;
/