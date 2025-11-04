/* Formatted on 8/12/2025 6:10:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_SECURITY_UTIL
IS
    -- Author  : YURA_A
    -- Created : 13.06.2003 11:08:57
    -- Purpose : Ведення ресурсів доступу

    TYPE TRefCursor IS REF CURSOR;

    -- Типи атрибутів доступу
    c_ATTR_TP_SELECT                 CONSTANT VARCHAR2 (10) := 'SELECT';
    c_ATTR_TP_INSERT                 CONSTANT VARCHAR2 (10) := 'INSERT';
    c_ATTR_TP_UPDATE                 CONSTANT VARCHAR2 (10) := 'UPDATE';
    c_ATTR_TP_DELETE                 CONSTANT VARCHAR2 (10) := 'DELETE';
    c_ATTR_TP_EXECUTE                CONSTANT VARCHAR2 (10) := 'EXECUTE';

    -- Типи об`єктів доступу
    c_OBJ_TP_SCHEMA_OBJ              CONSTANT VARCHAR2 (10) := 'SCHEMA';
    c_OBJ_TP_ABSTRACT                CONSTANT VARCHAR2 (10) := 'ABSTRACT';


    -- Messages for category: RESOURCE_UTIL
    msgUNKNOWN_ATTR_TP               CONSTANT NUMBER := 11;
    msgUNKNOWN_RSRC                  CONSTANT NUMBER := 12;
    msgUNKNOWN_ATTR                  CONSTANT NUMBER := 13;
    msgUNKNOWN_OBJ                   CONSTANT NUMBER := 14;
    msgUNKNOWN_APP_ROLE              CONSTANT NUMBER := 15;
    msgRSRC_ALREADY_EXIST            CONSTANT NUMBER := 16;
    msgAPP_ROLE_ALREADY_EXIST        CONSTANT NUMBER := 17;
    msgCANNOT_CONTROL_NOTOWN_RSRC    CONSTANT NUMBER := 18;
    msgCANNOT_SET_ATTR               CONSTANT NUMBER := 19;
    msgUNKNOWN_GROUP                 CONSTANT NUMBER := 3338;
    msgCANNOT_CONTROL_NOTOWN_GROUP   CONSTANT NUMBER := 3339;
    msgAPP_GROUP_ALREADY_EXISTS      CONSTANT NUMBER := 3340;

    --Статус метаданих

    stValid                          CONSTANT VARCHAR2 (20) := 'VALID';
    stInvalid                        CONSTANT VARCHAR2 (20) := 'INVALID';

    --Додати ресурс доступу
    PROCEDURE Add_Resource (
        p_resourse_name          ikis_resource.rsrc_name%TYPE,
        p_ss_msys         IN OUT ikis_subsys.ss_msys_begin%TYPE,
        p_rsrc_tp                ikis_resource.rsrc_tp%TYPE);

    --Вилучити ресур доступу
    PROCEDURE Drop_Resource (p_resourse_name ikis_resource.rsrc_name%TYPE);

    --Додати атрибут доступу до ресурсу
    PROCEDURE Add_Rsrc_Attr (
        p_resourse_name   ikis_resource.rsrc_name%TYPE,
        p_attr_type       ikis_rsrc_attr.rat_tp%TYPE,
        p_object_name     ikis_rsrc_attr.rat_object_name%TYPE,
        p_object_type     ikis_rsrc_attr.rat_object_tp%TYPE);

    --Вилучити атрибут доступу з ресурсу
    PROCEDURE Drop_Rsrc_Attr (
        p_resourse_name   ikis_resource.rsrc_name%TYPE,
        p_attr_type       ikis_rsrc_attr.rat_tp%TYPE,
        p_object_name     ikis_rsrc_attr.rat_object_name%TYPE);

    --Додати прикладну роль
    PROCEDURE Add_IKIS_Role (
        p_role_name          ikis_role.irl_name%TYPE,
        p_ss_msys     IN OUT ikis_subsys.ss_msys_begin%TYPE,
        p_comment            ikis_role.irl_comment%TYPE);

    --Вилучити прикладну роль
    PROCEDURE Drop_IKIS_Role (p_role_name ikis_role.irl_name%TYPE);

    --Додати прикладну группу
    PROCEDURE Add_IKIS_Group (
        p_group_name          ikis_group.igrp_name%TYPE,
        p_ss_msys      IN OUT ikis_subsys.ss_msys_begin%TYPE,
        p_comment             ikis_group.igrp_comment%TYPE);

    --Додати прикладну группу
    PROCEDURE Drop_IKIS_Group (p_group_name ikis_group.igrp_name%TYPE);

    --Надати ресурс доступу до прикладной ролі
    PROCEDURE Grant_RSRC2ROLE (p_rsrc_name   ikis_resource.rsrc_name%TYPE,
                               p_role_name   ikis_role.irl_name%TYPE);

    --Забрати ресурс доступу з прикладної ролі
    PROCEDURE Revoke_RSRC2ROLE (p_rsrc_name   ikis_resource.rsrc_name%TYPE,
                                p_role_name   ikis_role.irl_name%TYPE);
END IKIS_SECURITY_UTIL;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_SECURITY_UTIL FOR IKIS_SYS.IKIS_SECURITY_UTIL
/


GRANT EXECUTE ON IKIS_SYS.IKIS_SECURITY_UTIL TO II01RC_IKIS_DESIGN
/


/* Formatted on 8/12/2025 6:10:04 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_SECURITY_UTIL
IS
    UNIQUE_VIOLATION       EXCEPTION;
    PRAGMA EXCEPTION_INIT (UNIQUE_VIOLATION, -1);

    msgCANNOTGRANTINTRES   INTEGER := 212;

    PROCEDURE Get_Resource_Attr (
        p_resourse_name       ikis_resource.rsrc_name%TYPE,
        p_owner           OUT ikis_subsys.ss_owner%TYPE,
        p_resource        OUT ikis_resource%ROWTYPE)
    IS
        l_ss_attr   ikis_subsys%ROWTYPE;
    BEGIN
        debug.f ('Start procedure');

        BEGIN
            SELECT y.ss_owner,
                   x.rsrc_name,
                   x.rsrc_ss_code,
                   x.rsrc_msys,
                   x.rsrc_tp
              INTO p_owner,
                   p_resource.rsrc_name,
                   p_resource.rsrc_ss_code,
                   p_resource.rsrc_msys,
                   p_resource.rsrc_tp
              FROM ikis_resource x, ikis_subsys y
             WHERE     x.rsrc_ss_code = y.ss_code
                   AND x.rsrc_name = UPPER (p_resourse_name);
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                raise_application_error (
                    -20000,
                    ikis_message_util.GET_MESSAGE (msgUNKNOWN_RSRC,
                                                   p_resourse_name));
            WHEN OTHERS
            THEN
                raise_application_error (
                    -20000,
                    ikis_message_util.GET_MESSAGE (
                        ikis_message_util.msgCOMMON_EXCEPTION,
                        'Get_Resource_Attr',
                        CHR (10) || SQLERRM));
        END;

        debug.f ('Stop procedure');
    END;

    PROCEDURE Get_Role_Attr (p_role_name       ikis_resource.rsrc_name%TYPE,
                             p_owner       OUT ikis_subsys.ss_owner%TYPE)
    IS
        l_ss_attr   ikis_subsys%ROWTYPE;
    BEGIN
        debug.f ('Start procedure');

        BEGIN
            SELECT y.ss_owner
              INTO p_owner
              FROM ikis_role x, ikis_subsys y
             WHERE     x.irl_ss_code = y.ss_code
                   AND x.irl_name = UPPER (p_role_name);
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                raise_application_error (
                    -20000,
                    ikis_message_util.GET_MESSAGE (msgUNKNOWN_APP_ROLE,
                                                   p_role_name));
            WHEN OTHERS
            THEN
                raise_application_error (
                    -20000,
                    ikis_message_util.GET_MESSAGE (
                        ikis_message_util.msgCOMMON_EXCEPTION,
                        'Get_Role_Attr',
                        CHR (10) || SQLERRM));
        END;

        debug.f ('Stop procedure');
    END;

    PROCEDURE Get_Group_Attr (p_group_name       ikis_group.igrp_name%TYPE,
                              p_owner        OUT ikis_subsys.ss_owner%TYPE)
    IS
        l_ss_attr   ikis_subsys%ROWTYPE;
    BEGIN
        debug.f ('Start procedure');

        BEGIN
            SELECT y.ss_owner
              INTO p_owner
              FROM ikis_group x, ikis_subsys y
             WHERE     x.igrp_ss_code = y.ss_code
                   AND x.igrp_name = UPPER (p_group_name);
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                raise_application_error (
                    -20000,
                    ikis_message_util.GET_MESSAGE (msgUNKNOWN_GROUP,
                                                   p_group_name));
            WHEN OTHERS
            THEN
                raise_application_error (
                    -20000,
                    ikis_message_util.GET_MESSAGE (
                        ikis_message_util.msgCOMMON_EXCEPTION,
                        'Get_Group_Attr',
                        CHR (10) || SQLERRM));
        END;

        debug.f ('Stop procedure');
    END;

    PROCEDURE Add_Resource (
        p_resourse_name          ikis_resource.rsrc_name%TYPE,
        p_ss_msys         IN OUT ikis_subsys.ss_msys_begin%TYPE,
        p_rsrc_tp                ikis_resource.rsrc_tp%TYPE)
    IS
        l_ss_attr    ikis_subsys%ROWTYPE;
        l_sys_attr   ikis_subsys%ROWTYPE;
    BEGIN
        debug.f ('Start procedure');
        ikis_subsys_util.Get_SubSys_Attr_own (USER, l_ss_attr);
        ikis_subsys_util.get_subsys_attr (ikis_subsys_util.g_ikis_sys,
                                          l_sys_attr);

        IF NOT (NVL (p_ss_msys, 0) BETWEEN l_ss_attr.ss_msys_begin
                                       AND l_ss_attr.ss_msys_end)
        THEN
            p_ss_msys := l_ss_attr.ss_msys_begin;
        END IF;

        INSERT INTO ikis_resource (rsrc_name,
                                   rsrc_ss_code,
                                   rsrc_msys,
                                   rsrc_tp)
             VALUES (UPPER (p_resourse_name),
                     l_ss_attr.ss_code,
                     p_ss_msys,
                     p_rsrc_tp);

        EXECUTE IMMEDIATE   'create role '
                         || l_sys_attr.ss_instance_pref
                         || p_resourse_name;

        EXECUTE IMMEDIATE   'alter user '
                         || l_sys_attr.ss_owner
                         || ' default role none';

        EXECUTE IMMEDIATE   'grant '
                         || l_sys_attr.ss_instance_pref
                         || p_resourse_name
                         || ' to '
                         || USER
                         || ' with admin option';

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN UNIQUE_VIOLATION
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgRSRC_ALREADY_EXIST,
                                               p_resourse_name));
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'Add_Resource',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE Drop_Resource (p_resourse_name ikis_resource.rsrc_name%TYPE)
    IS
        l_owner             ikis_subsys.ss_owner%TYPE;
        l_root_role         ikis_subsys.ss_root_role%TYPE;
        l_instance_prefix   ikis_subsys.ss_instance_pref%TYPE;
        l_sys_attr          ikis_subsys%ROWTYPE;
        l_resource          ikis_resource%ROWTYPE;
    BEGIN
        debug.f ('Start procedure');
        Get_Resource_Attr (p_resourse_name, l_owner, l_resource);

        IF NOT (l_owner = USER)
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCANNOT_CONTROL_NOTOWN_RSRC,
                                               USER));
        END IF;

        FOR ra IN (SELECT rat_tp, rat_object_name
                     FROM ikis_rsrc_attr
                    WHERE rat_rsrc = UPPER (p_resourse_name))
        LOOP
            Drop_Rsrc_Attr (p_resourse_name, ra.rat_tp, ra.rat_object_name);
        END LOOP;

        ikis_subsys_util.get_subsys_attr (ikis_subsys_util.g_ikis_sys,
                                          l_sys_attr);

        EXECUTE IMMEDIATE   'drop role '
                         || l_sys_attr.ss_instance_pref
                         || p_resourse_name;

        DELETE FROM ikis_resource
              WHERE UPPER (ikis_resource.rsrc_name) = UPPER (p_resourse_name);

        COMMIT;
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'Drop_Resource',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE Add_Rsrc_Attr (
        p_resourse_name   ikis_resource.rsrc_name%TYPE,
        p_attr_type       ikis_rsrc_attr.rat_tp%TYPE,
        p_object_name     ikis_rsrc_attr.rat_object_name%TYPE,
        p_object_type     ikis_rsrc_attr.rat_object_tp%TYPE)
    IS
        l_owner       ikis_subsys.ss_owner%TYPE;
        l_root_role   ikis_subsys.ss_root_role%TYPE;
        l_sys_attr    ikis_subsys%ROWTYPE;
        l_resource    ikis_resource%ROWTYPE;
    BEGIN
        debug.f ('Start procedure');
        Get_Resource_Attr (p_resourse_name, l_owner, l_resource);

        IF NOT (l_owner = USER)
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCANNOT_CONTROL_NOTOWN_RSRC,
                                               USER));
        END IF;

        --  if not (p_attr_type in (c_ATTR_TP_SELECT,c_ATTR_TP_INSERT,c_ATTR_TP_UPDATE,c_ATTR_TP_DELETE,c_ATTR_TP_EXECUTE)) then
        --    raise_application_error(-20000,ikis_message_util.Get_Message(msgUNKNOWN_ATTR_TP,p_attr_type));
        --  end if;

        --  if not (p_object_type in (c_OBJ_TP_SCHEMA_OBJ,c_OBJ_TP_ABSTRACT)) then
        --    raise_application_error(-20000,ikis_message_util.Get_Message(msgUNKNOWN_OBJ,p_object_type));
        --  end if;

        ikis_subsys_util.get_subsys_attr (ikis_subsys_util.g_ikis_sys,
                                          l_sys_attr);

        IF     p_object_type = c_OBJ_TP_SCHEMA_OBJ
           AND NOT (p_attr_type = ikis_const.v_dds_attr_tp_references)
           AND NOT (l_resource.rsrc_tp = ikis_const.v_dds_resource_tp_i)
        THEN
            EXECUTE IMMEDIATE   'grant '
                             || p_attr_type
                             || ' on '
                             || l_owner
                             || '.'
                             || p_object_name
                             || ' to '
                             || l_sys_attr.ss_instance_pref
                             || p_resourse_name;
        END IF;

        INSERT INTO ikis_rsrc_attr (rat_rsrc,
                                    rat_tp,
                                    rat_object_name,
                                    rat_object_tp)
             VALUES (UPPER (p_resourse_name),
                     p_attr_type,
                     UPPER (p_object_name),
                     p_object_type);

        COMMIT;
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'Add_Rsrc_Attr',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE Drop_Rsrc_Attr (
        p_resourse_name   ikis_resource.rsrc_name%TYPE,
        p_attr_type       ikis_rsrc_attr.rat_tp%TYPE,
        p_object_name     ikis_rsrc_attr.rat_object_name%TYPE)
    IS
        l_object_tp   ikis_rsrc_attr.rat_object_tp%TYPE;
        l_owner       ikis_subsys.ss_owner%TYPE;
        l_root_role   ikis_subsys.ss_root_role%TYPE;
        l_sys_attr    ikis_subsys%ROWTYPE;
        l_status      VARCHAR2 (20);
        l_resource    ikis_resource%ROWTYPE;
    BEGIN
        debug.f ('Start procedure');
        Get_Resource_Attr (p_resourse_name, l_owner, l_resource);

        IF NOT (l_owner = USER)
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCANNOT_CONTROL_NOTOWN_RSRC,
                                               USER));
        END IF;

        --  if not (p_attr_type in (c_ATTR_TP_SELECT,c_ATTR_TP_INSERT,c_ATTR_TP_UPDATE,c_ATTR_TP_DELETE,c_ATTR_TP_EXECUTE)) then
        --    raise_application_error(-20000,ikis_message_util.Get_Message(msgUNKNOWN_ATTR_TP,p_attr_type));
        --  end if;
        BEGIN
            SELECT x.rat_object_tp
              INTO l_object_tp
              FROM ikis_rsrc_attr x
             WHERE     x.rat_rsrc = UPPER (p_resourse_name)
                   AND x.rat_tp = UPPER (p_attr_type)
                   AND x.rat_object_name = UPPER (p_object_name);
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                raise_application_error (
                    -20000,
                    ikis_message_util.GET_MESSAGE (
                        msgUNKNOWN_ATTR,
                           p_resourse_name
                        || ', '
                        || p_attr_type
                        || ', '
                        || p_object_name));
            WHEN OTHERS
            THEN
                RAISE;
        END;

        ikis_subsys_util.get_subsys_attr (ikis_subsys_util.g_ikis_sys,
                                          l_sys_attr);

        IF     l_object_tp = c_OBJ_TP_SCHEMA_OBJ
           AND NOT (p_attr_type = ikis_const.v_dds_attr_tp_references)
        THEN
            SELECT x.status
              INTO l_status
              FROM v_all_ikis_resource_attrib x
             WHERE     x.rsrc_name = p_resourse_name
                   AND x.rat_tp = p_attr_type
                   AND x.rat_object_name = p_object_name;

            IF     l_status = stValid
               AND NOT (l_resource.rsrc_tp = ikis_const.v_dds_resource_tp_i)
            THEN
                EXECUTE IMMEDIATE   'revoke '
                                 || p_attr_type
                                 || ' on '
                                 || l_owner
                                 || '.'
                                 || p_object_name
                                 || ' from '
                                 || l_sys_attr.ss_instance_pref
                                 || p_resourse_name;
            END IF;
        END IF;

        DELETE FROM ikis_rsrc_attr
              WHERE     ikis_rsrc_attr.rat_rsrc = UPPER (p_resourse_name)
                    AND ikis_rsrc_attr.rat_tp = UPPER (p_attr_type)
                    AND ikis_rsrc_attr.rat_object_name =
                        UPPER (p_object_name);

        COMMIT;
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'Drop_Rsrc_Attr',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE Add_IKIS_Role (
        p_role_name          ikis_role.irl_name%TYPE,
        p_ss_msys     IN OUT ikis_subsys.ss_msys_begin%TYPE,
        p_comment            ikis_role.irl_comment%TYPE)
    IS
        l_ss_attr    ikis_subsys%ROWTYPE;
        l_sys_attr   ikis_subsys%ROWTYPE;
    BEGIN
        debug.f ('Start procedure');
        ikis_subsys_util.Get_SubSys_Attr_own (USER, l_ss_attr);
        ikis_subsys_util.get_subsys_attr (ikis_subsys_util.g_ikis_sys,
                                          l_sys_attr);

        IF NOT (p_ss_msys BETWEEN l_ss_attr.ss_msys_begin
                              AND l_ss_attr.ss_msys_end)
        THEN
            p_ss_msys := l_ss_attr.ss_msys_begin;
        END IF;

        INSERT INTO ikis_role (irl_name,
                               irl_ss_code,
                               irl_msys,
                               irl_comment)
             VALUES (UPPER (p_role_name),
                     UPPER (l_ss_attr.ss_code),
                     p_ss_msys,
                     p_comment);

        EXECUTE IMMEDIATE   'create role '
                         || l_sys_attr.ss_instance_pref
                         || p_role_name;

        EXECUTE IMMEDIATE   'alter user '
                         || l_sys_attr.ss_owner
                         || ' default role none';

        EXECUTE IMMEDIATE   'grant '
                         || l_sys_attr.ss_instance_pref
                         || p_role_name
                         || ' to '
                         || USER
                         || ' with admin option';

        COMMIT;
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN UNIQUE_VIOLATION
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgAPP_ROLE_ALREADY_EXIST,
                                               p_role_name));
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'Add_IKIS_Role',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE Drop_IKIS_Role (p_role_name ikis_role.irl_name%TYPE)
    IS
        l_ss_attr    ikis_subsys%ROWTYPE;
        l_ss_msys    ikis_subsys.ss_msys_begin%TYPE;
        l_owner      ikis_subsys.ss_owner%TYPE;
        l_sys_attr   ikis_subsys%ROWTYPE;
    BEGIN
        debug.f ('Start procedure');
        Get_Role_Attr (p_role_name, l_owner);

        IF NOT (l_owner = USER)
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCANNOT_CONTROL_NOTOWN_RSRC,
                                               USER));
        END IF;

        FOR roles IN (SELECT rs2r_rsrc
                        FROM ikis_rsrc2role
                       WHERE rs2r_irl = UPPER (p_role_name))
        LOOP
            Revoke_RSRC2ROLE (roles.rs2r_rsrc, p_role_name);
        END LOOP;

        ikis_subsys_util.get_subsys_attr (ikis_subsys_util.g_ikis_sys,
                                          l_sys_attr);

        EXECUTE IMMEDIATE   'drop role '
                         || l_sys_attr.ss_instance_pref
                         || p_role_name;

        DELETE FROM ikis_role
              WHERE UPPER (irl_name) = UPPER (p_role_name);

        COMMIT;
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'Drop_IKIS_Role',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE Add_IKIS_Group (
        p_group_name          ikis_group.igrp_name%TYPE,
        p_ss_msys      IN OUT ikis_subsys.ss_msys_begin%TYPE,
        p_comment             ikis_group.igrp_comment%TYPE)
    IS
        l_ss_attr    ikis_subsys%ROWTYPE;
        l_sys_attr   ikis_subsys%ROWTYPE;
        l_main_ss    VARCHAR2 (50);
    BEGIN
        debug.f ('Start procedure');

        BEGIN
            ikis_subsys_util.Get_SubSys_Attr_own (USER, l_ss_attr);
        EXCEPTION
            WHEN OTHERS
            THEN
                SELECT ss_owner
                  INTO l_main_ss
                  FROM ikis_subsys
                 WHERE ss_main = ikis_const.V_DDS_YN_Y;

                ikis_subsys_util.Get_SubSys_Attr_own (l_main_ss, l_ss_attr);
        END;

        ikis_subsys_util.get_subsys_attr (ikis_subsys_util.g_ikis_sys,
                                          l_sys_attr);

        -- + KYB 10.12.2004
        -- если создавать новую группу в ПО ATLS SPO, то всегда ikis_subsys_util.g_ikis_sys=IKIS_ATLAS_SPO,
        -- тогда как пользовательские группы должны создаваться в подсистеме IKIS_SYS
        --  if not(p_ss_msys between l_ss_attr.ss_msys_begin and l_ss_attr.ss_msys_end) then
        --    p_ss_msys:=l_ss_attr.ss_msys_begin;
        --  end if;
        -- - KYB 10.12.2004
        INSERT INTO ikis_group (igrp_name,
                                igrp_ss_code,
                                igrp_msys,
                                igrp_comment)
             VALUES (UPPER (p_group_name),
                     UPPER (l_ss_attr.ss_code),
                     p_ss_msys,
                     p_comment);

        EXECUTE IMMEDIATE   'create role '
                         || l_sys_attr.ss_instance_pref
                         || p_group_name;

        EXECUTE IMMEDIATE   'alter user '
                         || l_sys_attr.ss_owner
                         || ' default role none';

        --+YAP 20081211 - Ваня Павлюков нашел багу
        --execute immediate 'grant '||l_sys_attr.ss_instance_pref||p_group_name||' to '||user||' with admin option';
        EXECUTE IMMEDIATE   'grant '
                         || l_sys_attr.ss_instance_pref
                         || p_group_name
                         || ' to '
                         || l_sys_attr.ss_owner
                         || ' with admin option';

        ---
        COMMIT;
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN UNIQUE_VIOLATION
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgAPP_GROUP_ALREADY_EXISTS,
                                               p_group_name));
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_SECURITY_UTIL.Add_IKIS_Group',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE Drop_IKIS_Group (p_group_name ikis_group.igrp_name%TYPE)
    IS
        l_ss_attr    ikis_subsys%ROWTYPE;
        l_ss_msys    ikis_subsys.ss_msys_begin%TYPE;
        l_owner      ikis_subsys.ss_owner%TYPE;
        l_sys_attr   ikis_subsys%ROWTYPE;
        l_cnt        INTEGER;
    BEGIN
        debug.f ('Start procedure');
        Get_Group_Attr (p_group_name, l_owner);

        IF NOT (l_owner = USER)
        THEN
            --+ KYB 09.12.2004
            SELECT COUNT (*)
              INTO l_cnt
              FROM v_all_ikis_granted_role
             WHERE     igr_username = USER
                   AND igr_st = 'VALID'
                   AND igr_name = 'RO_IKIS_SUPERUSER';

            IF l_cnt < 1
            THEN
                raise_application_error (
                    -20000,
                    ikis_message_util.GET_MESSAGE (
                        msgCANNOT_CONTROL_NOTOWN_GROUP,
                        USER));
            END IF;
        --  raise_application_error(-20000,ikis_message_util.Get_Message(msgCANNOT_CONTROL_NOTOWN_GROUP,user));
        --- KYB 09.12.2004
        END IF;

        ikis_subsys_util.get_subsys_attr (ikis_subsys_util.g_ikis_sys,
                                          l_sys_attr);

        FOR vUser IN (SELECT *
                        FROM v_all_ikis_granted_group
                       WHERE igr_name = p_group_name)
        LOOP
            ikis_security.RevokeIkisGroup (vUser.igr_username, p_group_name);
        END LOOP;

        FOR vGroup IN (SELECT *
                         FROM v_all_ikis_role2group
                        WHERE irg2g_igrp = p_group_name)
        LOOP
            ikis_security.Revokeikisrole2group (vGroup.irg2g_irl,
                                                p_group_name);
        END LOOP;

        EXECUTE IMMEDIATE   'drop role '
                         || l_sys_attr.ss_instance_pref
                         || p_group_name;

        DELETE FROM ikis_group
              WHERE UPPER (igrp_name) = UPPER (p_group_name);

        COMMIT;
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_SECURITY_UTIL.Drop_IKIS_Group',
                    CHR (10) || SQLERRM));
    END;


    PROCEDURE Grant_RSRC2ROLE (p_rsrc_name   ikis_resource.rsrc_name%TYPE,
                               p_role_name   ikis_role.irl_name%TYPE)
    IS
        l_owner1     ikis_subsys.ss_owner%TYPE;
        l_owner2     ikis_subsys.ss_owner%TYPE;
        l_sys_attr   ikis_subsys%ROWTYPE;
        l_resource   ikis_resource%ROWTYPE;
    BEGIN
        debug.f ('Start procedure');
        Get_Resource_Attr (p_rsrc_name, l_owner1, l_resource);

        IF l_resource.rsrc_tp = ikis_const.v_dds_resource_tp_i
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCANNOTGRANTINTRES));
        END IF;

        Get_Role_Attr (p_role_name, l_owner2);

        IF NOT (l_owner1 = l_owner2)
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCANNOT_SET_ATTR));
        END IF;

        IF NOT (l_owner1 = USER)
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCANNOT_CONTROL_NOTOWN_RSRC,
                                               USER));
        END IF;

        ikis_subsys_util.get_subsys_attr (ikis_subsys_util.g_ikis_sys,
                                          l_sys_attr);

        INSERT INTO ikis_rsrc2role (rs2r_rsrc, rs2r_irl)
             VALUES (UPPER (p_rsrc_name), UPPER (p_role_name));

        EXECUTE IMMEDIATE   'grant '
                         || l_sys_attr.ss_instance_pref
                         || p_rsrc_name
                         || ' to '
                         || l_sys_attr.ss_instance_pref
                         || p_role_name;

        COMMIT;
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'Grant_RSRC2ROLE',
                    SQLERRM));
    END;

    PROCEDURE Revoke_RSRC2ROLE (p_rsrc_name   ikis_resource.rsrc_name%TYPE,
                                p_role_name   ikis_role.irl_name%TYPE)
    IS
        l_owner1     ikis_subsys.ss_owner%TYPE;
        l_owner2     ikis_subsys.ss_owner%TYPE;
        l_sys_attr   ikis_subsys%ROWTYPE;
        l_resource   ikis_resource%ROWTYPE;
    BEGIN
        debug.f ('Start procedure');
        Get_Resource_Attr (p_rsrc_name, l_owner1, l_resource);
        Get_Role_Attr (p_role_name, l_owner2);

        IF NOT (l_owner1 = l_owner2)
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCANNOT_SET_ATTR));
        END IF;

        IF NOT (l_owner1 = USER)
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCANNOT_CONTROL_NOTOWN_RSRC,
                                               USER));
        END IF;

        ikis_subsys_util.get_subsys_attr (ikis_subsys_util.g_ikis_sys,
                                          l_sys_attr);

        EXECUTE IMMEDIATE   'revoke '
                         || l_sys_attr.ss_instance_pref
                         || p_rsrc_name
                         || ' from '
                         || l_sys_attr.ss_instance_pref
                         || p_role_name;

        DELETE FROM ikis_rsrc2role
              WHERE     rs2r_rsrc = UPPER (p_rsrc_name)
                    AND rs2r_irl = UPPER (p_role_name);

        COMMIT;
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'Revoke_RSRC2ROLE',
                    CHR (10) || SQLERRM));
    END;
END IKIS_SECURITY_UTIL;
/