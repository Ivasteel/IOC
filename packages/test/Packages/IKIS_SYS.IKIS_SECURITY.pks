/* Formatted on 8/12/2025 6:10:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_SECURITY
IS
    ----------------------------------------
    -- YURA_A 11.08.2003 15:21:55
    ----------------------------------------
    -- Назначение : Процедуры назначения пользователю роли ИКИС и лишения его этой роли
    -- исполняется под привилегиями IKIS_SYS, который среди прочего имеет grant any role

    ----------------------------------------
    -- YURA_A 11.08.2003 15:32:35
    ----------------------------------------
    -- Назначение : Назначить роль икис пользователю оракла, исп. для суперюзера ИКИС
    -- Параметры  : p_user - пользователь оракла, p_ikis_role - роль икис
    PROCEDURE GrantIkisRole (p_user        VARCHAR2,
                             p_ikis_role   ikis_role.irl_name%TYPE);

    PROCEDURE GrantIkisRoleOnType (p_user     VARCHAR2,
                                   p_type     ikis_resource.rsrc_tp%TYPE,
                                   p_subsys   ikis_subsys.ss_code%TYPE);

    ----------------------------------------
    -- YURA_A 11.08.2003 15:32:38
    ----------------------------------------
    -- Назначение : Лишить роли икис пользователя оракла, исп. для суперюзера ИКИС
    -- Параметры  : p_user - пользователь оракла, p_ikis_role - роль икис
    PROCEDURE RevokeIkisRole (p_user        VARCHAR2,
                              p_ikis_role   ikis_role.irl_name%TYPE);

    ----------------------------------------
    -- RYABA 10.11.2004 15:32:38
    ----------------------------------------
    -- Назначение : Назначить роль ИКИС группе ИКИC
    -- Параметры  : p_ikis_role - роль икис, p_ikis_group - группа ИКИС
    PROCEDURE GrantIkisRole2Group (p_ikis_role    ikis_role.irl_name%TYPE,
                                   p_ikis_group   ikis_group.igrp_name%TYPE);

    -- Назначение : Назначить групу ИКИС користувачу
    -- Параметры  : p_user - поьзователь ИКИС, p_ikis_group -  группа ИКИС
    PROCEDURE GrantIkisGroup (p_user         VARCHAR2,
                              p_ikis_group   ikis_group.igrp_name%TYPE);

    -- Назначение : Убрать роль из группы
    -- Параметры  : p_ikis_role - роль икис, p_ikis_group - группа ИКИС
    PROCEDURE RevokeIkisRole2Group (p_ikis_role    ikis_role.irl_name%TYPE,
                                    p_ikis_group   ikis_group.igrp_name%TYPE);

    -- Назначение : Лишить пользователя ИКИС прав группы
    -- Параметры  : p_user - пользователь оракла, p_ikis_group - роль икис
    PROCEDURE RevokeIkisGroup (p_user         VARCHAR2,
                               p_ikis_group   ikis_group.igrp_name%TYPE);

    ----------------------------------------
    -- YURA_A 08.08.2003 14:56:27
    ----------------------------------------
    -- Назначение : Удаление синонимов из схемы на несуществующие объекты
    -- Параметры  : p_sumsys - код подсистемы; p_target_schema - схема где удалять синонимы
    PROCEDURE DropSubSysSynonym (p_subsys          ikis_subsys.ss_code%TYPE,
                                 p_target_schema   VARCHAR2);

    ----------------------------------------
    -- YURA_A 08.08.2003 14:56:27
    ----------------------------------------
    -- Назначение : Создание синонимов подсистемы в другой схеме
    -- Параметры  : p_sumsys - код подсистемы; p_target_schema - схема где создавать синонимы
    PROCEDURE CreateSubSysSynonym (p_subsys          ikis_subsys.ss_code%TYPE,
                                   p_target_schema   VARCHAR2,
                                   p_is_interface    NUMBER DEFAULT 0);

    c_EMPTYLST   CONSTANT VARCHAR2 (10) := 'N/A';

    PROCEDURE CreateSubSysSynonymLst (p_subsys_lst      VARCHAR2,
                                      p_target_schema   VARCHAR2,
                                      p_is_interface    NUMBER DEFAULT 0);

    ----------------------------------------
    -- YURA_A 08.08.2003 17:11:46
    ----------------------------------------
    -- Назначение : Выдать схеме p_target_schema привилегии на использование интерфейса подсистемы p_sumsys
    PROCEDURE GrantSubSysIntPriv (p_subsys          ikis_subsys.ss_code%TYPE,
                                  p_target_schema   VARCHAR2);

    PROCEDURE GrantSubSysIntPrivLst (p_subsys_lst      VARCHAR2,
                                     p_target_schema   VARCHAR2);

    PROCEDURE RevokeSubSysIntPriv (p_subsys          ikis_subsys.ss_code%TYPE,
                                   p_target_schema   VARCHAR2);

    ----------------------------------------
    -- YURA_A 12.09.2003 13:13:40
    ----------------------------------------
    -- Назначение : Назначение корневой роли экзепляра ИКИС пользователю
    -- Параметры  : имя пользователя
    PROCEDURE GrantIkisRootRole (p_user VARCHAR2);
END IKIS_SECURITY;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_SECURITY FOR IKIS_SYS.IKIS_SECURITY
/


GRANT EXECUTE ON IKIS_SYS.IKIS_SECURITY TO II01RC_IKIS_DESIGN
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SECURITY TO II01RC_IKIS_SUPERUSER
/


/* Formatted on 8/12/2025 6:10:04 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_SECURITY
IS
    -- Messages for category: RESOURCE_UTIL
    msgUNKNOWN_ROLE_TP              NUMBER := 150;
    msgNOTROLETYPE                  NUMBER := 151;
    msgUNKNOWN_ATTR_TP              NUMBER := 11;
    msgUNKNOWN_RSRC                 NUMBER := 12;
    msgUNKNOWN_ATTR                 NUMBER := 13;
    msgUNKNOWN_OBJ                  NUMBER := 14;
    msgUNKNOWN_APP_ROLE             NUMBER := 15;
    msgRSRC_ALREADY_EXIST           NUMBER := 16;
    msgAPP_ROLE_ALREADY_EXIST       NUMBER := 17;
    msgCANNOT_CONTROL_NOTOWN_RSRC   NUMBER := 18;
    msgCANNOT_SET_ATTR              NUMBER := 19;
    msgUNKNOWN_APP_GROUP            NUMBER := 3341;

    no_group_found                  EXCEPTION;
    no_role_found                   EXCEPTION;

    PROCEDURE GrantIkisRootRole (p_user VARCHAR2)
    IS
        l_cmd   VARCHAR2 (32760);
    BEGIN
        l_cmd :=
            'grant ' || IKIS_SUBSYS_UTIL.g_IKIS_ROOT_ROLE || ' to ' || p_user;

        EXECUTE IMMEDIATE l_cmd;
    --dbms_output.put_line(l_cmd);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                       'IKIS_SECURITY.GrantIkisRootRole with '
                    || CHR (10)
                    || l_cmd,
                    SQLERRM));
    END;

    PROCEDURE GrantIkisRole (p_user        VARCHAR2,
                             p_ikis_role   ikis_role.irl_name%TYPE)
    IS
        l_cmd    VARCHAR2 (32760);
        l_role   ikis_role.irl_name%TYPE;
    BEGIN
        SELECT irl_name
          INTO l_role
          FROM ikis_role
         WHERE irl_name = UPPER (p_ikis_role); -- and irl_tp=ikis_const.v_dds_role_tp_u;

        l_cmd :=
               'grant '
            || ikis_subsys_util.getinstancepref
            || p_ikis_role
            || ' to '
            || p_user;

        --dbms_output.put_line(l_cmd);
        EXECUTE IMMEDIATE l_cmd;

        FOR spec_attr
            IN (SELECT *
                  FROM ikis_rsrc2role,
                       ikis_resource,
                       ikis_rsrc_attr,
                       ikis_subsys
                 WHERE     rs2r_irl = p_ikis_role
                       AND rs2r_rsrc = rsrc_name
                       AND rsrc_name = rat_rsrc
                       AND rat_object_tp = 'SCHEMA'
                       AND rsrc_tp = 'S'      --ikis_const.v_dds_resource_tp_s
                       AND rsrc_ss_code = ss_code)
        LOOP
            l_cmd :=
                   'grant '
                || spec_attr.rat_tp
                || ' on '
                || spec_attr.ss_owner
                || '.'
                || spec_attr.rat_object_name
                || ' to '
                || p_user;

            BEGIN
                --dbms_output.put_line(l_cmd);
                EXECUTE IMMEDIATE l_cmd;
            EXCEPTION
                WHEN OTHERS
                THEN
                    DBMS_OUTPUT.put_line (
                           'WARNING: '
                        || spec_attr.rat_object_name
                        || '>'
                        || SUBSTR (SQLERRM, 1, 240)); --YAP 20090429 чтобы не райзить при накате более одной версии подряд (да и необходимости райзить особой нету)
            END;
        END LOOP;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgUNKNOWN_APP_ROLE,
                                               p_ikis_role));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_SECURITY.GrantIkisRole with ' || CHR (10) || l_cmd,
                    SQLERRM));
    END;

    PROCEDURE GrantIkisRoleOnType (p_user     VARCHAR2,
                                   p_type     ikis_resource.rsrc_tp%TYPE,
                                   p_subsys   ikis_subsys.ss_code%TYPE)
    IS
        l_role   ikis_role.irl_name%TYPE;
        l_flag   BOOLEAN := FALSE;
    BEGIN
        FOR i_role
            IN (SELECT DISTINCT a.irl_name
                  FROM ikis_role a, ikis_rsrc2role x, ikis_resource y
                 WHERE     a.irl_ss_code = p_subsys
                       AND a.irl_name = x.rs2r_irl
                       AND x.rs2r_rsrc = y.rsrc_name
                       AND y.rsrc_tp = p_type)
        LOOP
            --    dbms_output.put_line('DEBUG: Granted role. p_user: '||p_user||'; i_role.irl_name: '||i_role.irl_name);
            GrantIkisRole (p_user, i_role.irl_name);
            l_flag := TRUE;
        END LOOP;

        IF NOT l_flag
        THEN
            DBMS_OUTPUT.put_line (
                   'DEBUG: No granted role. p_user: '
                || p_user
                || '; p_type: '
                || p_type
                || '; p_subsys: '
                || p_subsys);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgNOTROLETYPE,
                                               p_type,
                                               p_subsys));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_SECURITY.GrantIkisRoleOnType',
                    SQLERRM));
    END;

    PROCEDURE RevokeIkisRole (p_user        VARCHAR2,
                              p_ikis_role   ikis_role.irl_name%TYPE)
    IS
        l_cmd    VARCHAR2 (32760);
        l_role   ikis_role.irl_name%TYPE;
    BEGIN
        SELECT irl_name
          INTO l_role
          FROM ikis_role
         WHERE irl_name = UPPER (p_ikis_role); -- and irl_tp=ikis_const.v_dds_role_tp_u;

        l_cmd :=
               'revoke '
            || ikis_subsys_util.getinstancepref
            || p_ikis_role
            || ' from '
            || p_user;

        EXECUTE IMMEDIATE l_cmd;

        FOR spec_attr
            IN (SELECT *
                  FROM ikis_rsrc2role,
                       ikis_resource,
                       ikis_rsrc_attr,
                       ikis_subsys
                 WHERE     rs2r_irl = p_ikis_role
                       AND rs2r_rsrc = rsrc_name
                       AND rsrc_name = rat_rsrc
                       AND rat_object_tp = 'SCHEMA'
                       AND rsrc_tp = 'S'      --ikis_const.v_dds_resource_tp_s
                       AND rsrc_ss_code = ss_code)
        LOOP
            l_cmd :=
                   'revoke '
                || spec_attr.rat_tp
                || ' on '
                || spec_attr.ss_owner
                || '.'
                || spec_attr.rat_object_name
                || ' from '
                || p_user;

            EXECUTE IMMEDIATE l_cmd;
        END LOOP;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgUNKNOWN_APP_ROLE,
                                               p_ikis_role));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_SECURITY.GrantIkisRole with ' || CHR (10) || l_cmd,
                    SQLERRM));
    END;

    PROCEDURE GrantIkisRole2Group (p_ikis_role    ikis_role.irl_name%TYPE,
                                   p_ikis_group   ikis_group.igrp_name%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_cmd     VARCHAR2 (32760);
        l_group   ikis_group.igrp_name%TYPE;
        l_role    ikis_role.irl_name%TYPE;
    BEGIN
        BEGIN
            SELECT igrp_name
              INTO l_group
              FROM ikis_group
             WHERE igrp_name = UPPER (p_ikis_group); -- and irl_tp=ikis_const.v_dds_role_tp_u;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RAISE no_group_found;
        END;

        BEGIN
            SELECT irl_name
              INTO l_role
              FROM ikis_role
             WHERE irl_name = UPPER (p_ikis_role);
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RAISE no_role_found;
        END;

        INSERT INTO ikis_role2group (irg2g_irl, irg2g_igrp)
             VALUES (UPPER (p_ikis_role), UPPER (p_ikis_group));

        l_cmd :=
               'grant '
            || ikis_subsys_util.getinstancepref
            || p_ikis_role
            || ' to '
            || ikis_subsys_util.getinstancepref
            || p_ikis_group;

        EXECUTE IMMEDIATE l_cmd;

        --dbms_output.put_line(l_cmd);
        COMMIT;
    EXCEPTION
        WHEN no_group_found
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgUNKNOWN_APP_GROUP,
                                               p_ikis_role));
        WHEN no_role_found
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgUNKNOWN_APP_ROLE,
                                               p_ikis_role));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_SECURITY.GrantIkisRole with ' || CHR (10) || l_cmd,
                    SQLERRM));
    END;

    PROCEDURE GrantIkisGroup (p_user         VARCHAR2,
                              p_ikis_group   ikis_group.igrp_name%TYPE)
    IS
        l_cmd     VARCHAR2 (32760);
        l_group   ikis_group.igrp_name%TYPE;
    BEGIN
        SELECT igrp_name
          INTO l_group
          FROM ikis_group
         WHERE igrp_name = UPPER (p_ikis_group); -- and irl_tp=ikis_const.v_dds_role_tp_u;

        l_cmd :=
               'grant '
            || ikis_subsys_util.getinstancepref
            || p_ikis_group
            || ' to '
            || p_user;

        EXECUTE IMMEDIATE l_cmd;

        --dbms_output.put_line(l_cmd);
        FOR spec_attr
            IN (SELECT *
                  FROM ikis_role2group,
                       ikis_rsrc2role,
                       ikis_resource,
                       ikis_rsrc_attr,
                       ikis_subsys
                 WHERE     irg2g_igrp = p_ikis_group
                       AND rs2r_irl = irg2g_irl
                       AND rs2r_rsrc = rsrc_name
                       AND rsrc_name = rat_rsrc
                       AND rat_object_tp = 'SCHEMA'
                       AND rsrc_tp = 'S'      --ikis_const.v_dds_resource_tp_s
                       AND rsrc_ss_code = ss_code)
        LOOP
            l_cmd :=
                   'grant '
                || spec_attr.rat_tp
                || ' on '
                || spec_attr.ss_owner
                || '.'
                || spec_attr.rat_object_name
                || ' to '
                || p_user;

            EXECUTE IMMEDIATE l_cmd;
        --dbms_output.put_line(l_cmd);
        END LOOP;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgUNKNOWN_APP_GROUP,
                                               p_ikis_group));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_SECURITY.GrantIkisRole with ' || CHR (10) || l_cmd,
                    SQLERRM));
    END;

    PROCEDURE RevokeIkisRole2Group (p_ikis_role    ikis_role.irl_name%TYPE,
                                    p_ikis_group   ikis_group.igrp_name%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_cmd     VARCHAR2 (32760);
        l_group   ikis_group.igrp_name%TYPE;
        l_role    ikis_role.irl_name%TYPE;
    BEGIN
        BEGIN
            SELECT igrp_name
              INTO l_group
              FROM ikis_group
             WHERE igrp_name = UPPER (p_ikis_group); -- and irl_tp=ikis_const.v_dds_role_tp_u;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RAISE no_group_found;
        END;

        BEGIN
            SELECT irl_name
              INTO l_role
              FROM ikis_role
             WHERE irl_name = UPPER (p_ikis_role);
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RAISE no_role_found;
        END;

        DELETE FROM ikis_role2group
              WHERE     irg2g_irl = UPPER (p_ikis_role)
                    AND irg2g_igrp = UPPER (p_ikis_group);

        l_cmd :=
               'revoke '
            || ikis_subsys_util.getinstancepref
            || p_ikis_role
            || ' from '
            || ikis_subsys_util.getinstancepref
            || p_ikis_group;

        EXECUTE IMMEDIATE l_cmd;

        FOR vUser IN (SELECT *
                        FROM v_all_ikis_granted_group
                       WHERE igr_name = p_ikis_group)
        LOOP
            RevokeIkisGroup (vUser.igr_username, p_ikis_group);
        END LOOP;

        COMMIT;
    EXCEPTION
        WHEN no_group_found
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgUNKNOWN_APP_GROUP,
                                               p_ikis_role));
        WHEN no_role_found
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgUNKNOWN_APP_ROLE,
                                               p_ikis_role));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                       'IKIS_SECURITY.RevokeIkisRole2Group with '
                    || CHR (10)
                    || l_cmd,
                    SQLERRM));
    END;

    PROCEDURE RevokeIkisGroup (p_user         VARCHAR2,
                               p_ikis_group   ikis_group.igrp_name%TYPE)
    IS
        l_cmd     VARCHAR2 (32760);
        l_group   ikis_group.igrp_name%TYPE;
    BEGIN
        SELECT igrp_name
          INTO l_group
          FROM ikis_group
         WHERE igrp_name = UPPER (p_ikis_group); -- and irl_tp=ikis_const.v_dds_role_tp_u;

        l_cmd :=
               'revoke '
            || ikis_subsys_util.getinstancepref
            || p_ikis_group
            || ' from '
            || p_user;

        EXECUTE IMMEDIATE l_cmd;

        FOR spec_attr
            IN (SELECT *
                  FROM ikis_role2group,
                       ikis_rsrc2role,
                       ikis_resource,
                       ikis_rsrc_attr,
                       ikis_subsys
                 WHERE     irg2g_igrp = p_ikis_group
                       AND rs2r_irl = irg2g_irl
                       AND rs2r_rsrc = rsrc_name
                       AND rsrc_name = rat_rsrc
                       AND rat_object_tp = 'SCHEMA'
                       AND rsrc_tp = 'S'      --ikis_const.v_dds_resource_tp_s
                       AND rsrc_ss_code = ss_code
                       AND NOT rs2r_irl IN
                                   (SELECT igr_name
                                      FROM v_all_ikis_granted_role
                                     WHERE igr_username = UPPER (p_user)))
        LOOP
            l_cmd :=
                   'revoke '
                || spec_attr.rat_tp
                || ' on '
                || spec_attr.ss_owner
                || '.'
                || spec_attr.rat_object_name
                || ' from '
                || p_user;

            EXECUTE IMMEDIATE l_cmd;
        END LOOP;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgUNKNOWN_APP_GROUP,
                                               p_ikis_group));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                       'IKIS_SECURITY.RevokeIkisGroup with '
                    || CHR (10)
                    || l_cmd,
                    SQLERRM));
    END;

    PROCEDURE DropSubSysSynonym (p_subsys          ikis_subsys.ss_code%TYPE,
                                 p_target_schema   VARCHAR2)
    IS
        l_attr   ikis_subsys%ROWTYPE;
        l_cmd    VARCHAR2 (32760);
        l_flag   BOOLEAN := FALSE;
        l_cnt    NUMBER;
    BEGIN
        raise_application_error (-20000, 'Feature depricated.');

        SELECT *
          INTO l_attr
          FROM ikis_subsys
         WHERE ss_code = p_subsys;

        IF NOT (UPPER (l_attr.ss_owner) = UPPER (p_target_schema))
        THEN                                  --самому себе не делаем синонимы
            FOR u_objects
                IN (SELECT object_name
                      FROM all_objects
                     WHERE     object_type IN ('SYNONYM')
                           AND owner = p_target_schema
                           AND NOT object_name LIKE '%IKIS_CONST%'
                           AND NOT object_name LIKE '%IKIS_NSI_CONST%'
                           AND object_name NOT IN
                                   (SELECT object_name
                                      FROM all_objects
                                     WHERE     owner IN
                                                   (SELECT ss_owner
                                                      FROM ikis_subsys
                                                     WHERE ss_owner
                                                               IS NOT NULL)
                                           AND object_type IN ('TABLE',
                                                               'VIEW',
                                                               'PACKAGE',
                                                               'SEQUENCE',
                                                               'PROCEDURE',
                                                               'FUNCTION',
                                                               'TYPE')
                                           AND object_name NOT IN
                                                   ('DIC_DD',
                                                    'DIC_DV',
                                                    'DIC_TBL',
                                                    'DIC_NSI_TBL',
                                                    'BLD$PROJDETAIL',
                                                    'BLD$PROJECTS',
                                                    'BLD$VERSION',
                                                    'SQ$BLD$PROJDETAIL',
                                                    'SQ$BLD$PROJECTS',
                                                    'SQ$BLD$VERSION',
                                                    'PLAN_TABLE')
                                           AND NOT (    object_name LIKE
                                                            'BIN$%'
                                                    AND object_name LIKE
                                                            '%==$0')))
            LOOP
                l_cmd :=
                       'drop synonym '
                    || p_target_schema
                    || '.'
                    || u_objects.object_name;
                --- Автор: YURA_A 01.06.2004 14:47:23
                DBMS_OUTPUT.put_line (l_cmd);

                EXECUTE IMMEDIATE l_cmd;

                l_flag := TRUE;
            END LOOP;
        END IF;

        IF NOT l_flag
        THEN
            DBMS_OUTPUT.put_line (
                   'DEBUG: No dropped synonyms. p_subsys: '
                || p_subsys
                || '; p_target_schema: '
                || p_target_schema
                || '; owner: '
                || l_attr.ss_owner);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_SECURITY.DropSubSysSynonym with ' || l_cmd,
                    CHR (10) || SQLERRM));
    END;


    PROCEDURE CreateSubSysSynonym (p_subsys          ikis_subsys.ss_code%TYPE,
                                   p_target_schema   VARCHAR2,
                                   p_is_interface    NUMBER DEFAULT 0)
    IS
        l_attr   ikis_subsys%ROWTYPE;
        l_cmd    VARCHAR2 (32760);
        l_flag   BOOLEAN := FALSE;
        l_cnt    NUMBER;
    BEGIN
        --if ikis_sys.ikis_common.GetAP_IKIS_APPLEVEL='C' then
        --  raise_application_error(-20000,'Feature depricated.');
        --end if;
        raise_application_error (-20000, 'Feature depricated.');

        --YAP 20081217 - убарана проверка, будет потихоньку становиться полноценной подсистемой
        --if p_subsys='IKIS_DWH_CS_PFU' then
        --  dbms_output.put_line('DEBUG: No created synonym for p_subsys: '||p_subsys||'; p_target_schema: '||p_target_schema);
        --else
        SELECT *
          INTO l_attr
          FROM ikis_subsys
         WHERE ss_code = p_subsys;

        IF NOT (UPPER (l_attr.ss_owner) = UPPER (p_target_schema))
        THEN                                  --самому себе не делаем синонимы
            FOR u_objects
                IN (SELECT object_name, object_type
                      FROM all_objects,
                           (SELECT DISTINCT rat_object_name
                              FROM ikis_resource, ikis_rsrc_attr
                             WHERE     rat_rsrc = rsrc_name
                                   AND rsrc_ss_code = p_subsys
                                   AND rat_object_tp = 'SCHEMA'
                                   AND DECODE (p_is_interface,
                                               0, rsrc_tp,
                                               'I') =
                                       rsrc_tp                  --YAP 20090601
                                              ) aa --YAP 20080812 чтобы не выдавать лишнего (хоть немного сократить)
                     WHERE     owner = l_attr.ss_owner
                           AND object_name = aa.rat_object_name
                           AND object_type IN ('TABLE',
                                               'VIEW',
                                               'PACKAGE',
                                               'SEQUENCE',
                                               'PROCEDURE',
                                               'FUNCTION',
                                               'TYPE')
                           AND object_name NOT IN ('DIC_DD',
                                                   'DIC_DV',
                                                   'DIC_TBL',
                                                   'DIC_NSI_TBL',
                                                   'BLD$PROJDETAIL',
                                                   'BLD$PROJECTS',
                                                   'BLD$VERSION',
                                                   'SQ$BLD$PROJDETAIL',
                                                   'SQ$BLD$PROJECTS',
                                                   'SQ$BLD$VERSION',
                                                   'PLAN_TABLE',
                                                   'BLD$SYSVER')
                           AND NOT (    object_name LIKE 'BIN$%'
                                    AND object_name LIKE '%==$0'))
            LOOP
                --+ Автор: YURA_A 24.11.2003 11:36:40
                --  Описание: если в целевой подсистеме есть объект с таким именем, то в имя синонима включается имя подсистемы
                --+ Автор: YURA_A 01.06.2004 14:46:58
                --  Описание: для объектов совпадающих по именам делаем специальный синоним
                --      if u_objects.object_name='IKIS_CONST' then
                --        l_cmd:='create or replace synonym '||p_target_schema||'.'||p_subsys||'_'||u_objects.object_name||' for '||l_attr.ss_owner||'.'||u_objects.object_name;
                --      else
                --        l_cmd:='create or replace synonym '||p_target_schema||'.'||u_objects.object_name||' for '||l_attr.ss_owner||'.'||u_objects.object_name;
                --      end if;
                SELECT COUNT (1)
                  INTO l_cnt
                  FROM all_objects a
                 WHERE     a.owner = UPPER (p_target_schema)
                       AND a.object_name = u_objects.object_name
                       AND a.object_type = u_objects.object_type;

                IF    l_cnt > 0
                   OR u_objects.object_name = 'IKIS_CONST'
                   OR u_objects.object_name = 'IKIS_NSI_CONST'
                THEN
                    l_cmd :=
                           'create or replace synonym '
                        || p_target_schema
                        || '.'
                        || p_subsys
                        || '_'
                        || u_objects.object_name
                        || ' for '
                        || l_attr.ss_owner
                        || '.'
                        || u_objects.object_name;
                ELSE
                    l_cmd :=
                           'create or replace synonym '
                        || p_target_schema
                        || '.'
                        || u_objects.object_name
                        || ' for '
                        || l_attr.ss_owner
                        || '.'
                        || u_objects.object_name;
                END IF;

                --- Автор: YURA_A 01.06.2004 14:47:23
                --dbms_output.put_line(l_cmd);
                EXECUTE IMMEDIATE l_cmd;

                l_flag := TRUE;
            END LOOP;
        END IF;

        IF NOT l_flag
        THEN
            DBMS_OUTPUT.put_line (
                   'DEBUG: No created synonym. p_subsys: '
                || p_subsys
                || '; p_target_schema: '
                || p_target_schema
                || '; owner: '
                || l_attr.ss_owner);
        END IF;
    --end if;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_SECURITY.CreateSubSysSynonym with ' || l_cmd,
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE CreateSubSysSynonymLst (p_subsys_lst      VARCHAR2,
                                      p_target_schema   VARCHAR2,
                                      p_is_interface    NUMBER DEFAULT 0)
    IS
        par_table   DBMS_UTILITY.Uncl_Array;
        cnt         BINARY_INTEGER;
    BEGIN
        DBMS_UTILITY.COMMA_TO_TABLE (p_subsys_lst, cnt, par_table);

        FOR i IN 1 .. cnt
        LOOP
            par_table (i) := TRIM (BOTH '"' FROM par_table (i));

            IF NOT (c_EMPTYLST = par_table (I))
            THEN
                CreateSubSysSynonym (par_table (I),
                                     p_target_schema,
                                     p_is_interface);
            END IF;
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_SECURITY.CreateSubSysSynonymLst',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE GrantSubSysIntPriv (p_subsys          ikis_subsys.ss_code%TYPE,
                                  p_target_schema   VARCHAR2)
    IS
        l_attr   ikis_subsys%ROWTYPE;
        l_cmd    VARCHAR2 (32760);
        l_cnt    NUMBER;
    BEGIN
        SELECT *
          INTO l_attr
          FROM ikis_subsys
         WHERE ss_code = p_subsys;

        SELECT COUNT (1)
          INTO l_cnt
          FROM ikis_subsys x
         WHERE UPPER (x.ss_owner) = UPPER (p_target_schema);

        IF l_cnt = 0
        THEN                                                    --YAP 20090602
            raise_application_error (
                -20000,
                'Subsystem ' || p_target_schema || ' not register.');
        END IF;

        IF NOT (UPPER (l_attr.ss_owner) = UPPER (p_target_schema))
        THEN                                    --самому себе не делаем гранты
            FOR uss_role
                IN (SELECT b.*
                      FROM ikis_resource a, ikis_rsrc_attr b
                     WHERE     a.rsrc_tp = 'I' --ikis_const.v_dds_resource_tp_i
                           AND a.rsrc_ss_code = p_subsys
                           AND a.rsrc_name = b.rat_rsrc)
            LOOP
                l_cmd :=
                       'grant '
                    || uss_role.rat_tp
                    || ' on '
                    || l_attr.ss_owner
                    || '.'
                    || uss_role.rat_object_name
                    || ' to '
                    || p_target_schema
                    || ' with grant option';

                EXECUTE IMMEDIATE l_cmd;
            END LOOP;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                       'IKIS_SECURITY.GrantSubSysIntPriv with '
                    || CHR (10)
                    || l_cmd,
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE GrantSubSysIntPrivLst (p_subsys_lst      VARCHAR2,
                                     p_target_schema   VARCHAR2)
    IS
        par_table   DBMS_UTILITY.Uncl_Array;
        cnt         BINARY_INTEGER;
    BEGIN
        DBMS_UTILITY.COMMA_TO_TABLE (p_subsys_lst, cnt, par_table);

        FOR i IN 1 .. cnt
        LOOP
            par_table (i) := TRIM (BOTH '"' FROM par_table (i));

            IF NOT (c_EMPTYLST = par_table (I))
            THEN
                GrantSubSysIntPriv (par_table (I), p_target_schema);
            END IF;
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_SECURITY.GrantSubSysIntPrivLst',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE RevokeSubSysIntPriv (p_subsys          ikis_subsys.ss_code%TYPE,
                                   p_target_schema   VARCHAR2)
    IS
        l_attr   ikis_subsys%ROWTYPE;
        l_cmd    VARCHAR2 (32760);
    BEGIN
        ikis_subsys_util.get_subsys_attr (p_subsys, l_attr);

        IF NOT (UPPER (l_attr.ss_owner) = UPPER (p_target_schema))
        THEN                                    --самому себе не делаем гранты
            FOR uss_role
                IN (SELECT b.*
                      FROM ikis_resource a, ikis_rsrc_attr b
                     WHERE     a.rsrc_tp = 'I' --ikis_const.v_dds_resource_tp_i
                           AND a.rsrc_ss_code = p_subsys
                           AND a.rsrc_name = b.rat_rsrc)
            LOOP
                l_cmd :=
                       'revoke '
                    || uss_role.rat_tp
                    || ' on '
                    || l_attr.ss_owner
                    || '.'
                    || uss_role.rat_object_name
                    || ' from '
                    || p_target_schema;

                EXECUTE IMMEDIATE l_cmd;

                DBMS_OUTPUT.put_line ('Executed: ' || l_cmd);
            END LOOP;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                       'IKIS_SECURITY.RevokeSubSysIntPriv with '
                    || CHR (10)
                    || l_cmd,
                    CHR (10) || SQLERRM));
    END;
END IKIS_SECURITY;
/