/* Formatted on 8/12/2025 6:10:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.ikis_secur_utl
IS
    ----------------------------------------
    -- YURA_A 08.08.2003 17:14:09
    ----------------------------------------
    -- Назначение : Утилиты создания ролей по метаданным
    -- Утилиты восстановления ролей по метаданным

    ----------------------------------------
    -- YURA_A 08.08.2003 17:16:17
    ----------------------------------------
    -- Назначение : Создать ресурсы с привилегиями и роли по метаданным для подсистемы
    PROCEDURE CreateRole (p_subsys ikis_subsys.ss_code%TYPE);

    -- Назначение : Создать ресурсы с привилегиями и групы по метаданным для подсистемы
    PROCEDURE CreateGroup (p_subsys ikis_subsys.ss_code%TYPE);

    ----------------------------------------
    -- YURA_A 08.08.2003 17:17:12
    ----------------------------------------
    -- Назначение : Восстановить роли/привилегии для метаданных по подсистеме
    PROCEDURE RepairResourceRole (p_subsys ikis_subsys.ss_code%TYPE);

    --Ryaba 15.12.2004
    --Процедура відновлює синоніми для підсистеми для всіх активних користувачів
    PROCEDURE RepairSubSysSynonym (p_subsys ikis_subsys.ss_code%TYPE);

    --YAP 20071101 - установка игнорирования ошибок отсутствия объектов (для установки в центре, где структура может отличаться от районной)
    PROCEDURE SetIgnoreErr;

    PROCEDURE UnSetIgnoreErr;
END ikis_secur_utl;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_SECUR_UTL FOR IKIS_SYS.IKIS_SECUR_UTL
/


GRANT EXECUTE ON IKIS_SYS.IKIS_SECUR_UTL TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SECUR_UTL TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SECUR_UTL TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SECUR_UTL TO IKIS_SYSWEB WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SECUR_UTL TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SECUR_UTL TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SECUR_UTL TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SECUR_UTL TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SECUR_UTL TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SECUR_UTL TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SECUR_UTL TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SECUR_UTL TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SECUR_UTL TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:10:05 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.ikis_secur_utl
IS
    -- Messages for category: COMMON
    msgUNIQUE_VIOLATION          NUMBER := 1;
    msgCOMMON_EXCEPTION          NUMBER := 2;
    msgAlreadyLocked             NUMBER := 77;
    msgDataChanged               NUMBER := 78;
    msgEstablish                 NUMBER := 79;
    msgGroupControlError         NUMBER := 97;
    msgProgramError              NUMBER := 117;

    -- Messages for category: SUBSYS_UTIL
    msgUNKNOWN_SUBSYS_CODE       NUMBER := 3;
    msgSUBSYS_ALREDY_REG         NUMBER := 4;
    msgUNKNOWN_USER              NUMBER := 5;
    msgPREF_ALREADY_INST         NUMBER := 6;
    msgMAIN_SUBSYS_ABSENCE       NUMBER := 7;
    msgMAIN_SUBSYS_DOUBLE        NUMBER := 8;
    msgDOUBLE_SUBSYS_IN_SCHEMA   NUMBER := 9;
    msgUnkPref                   NUMBER := 496;


    --Статус метаданих

    stValid                      VARCHAR2 (20) := 'VALID';
    stInvalid                    VARCHAR2 (20) := 'INVALID';

    g_Pref                       ikis_subsys.ss_instance_pref%TYPE := NULL;

    --YAP 20071101 - для установки в центре, где структура может отличаться.
    gIgnoreErr                   BOOLEAN := TRUE;

    PROCEDURE SetIgnoreErr
    IS
    BEGIN
        gIgnoreErr := TRUE;
    END;

    PROCEDURE UnSetIgnoreErr
    IS
    BEGIN
        gIgnoreErr := FALSE;
    END;


    ----------------------------------------
    -- YURA_A 15.04.2004 15:11:02
    ----------------------------------------
    -- Назначение : проверка наличия роли
    -- Параметры  : имя роли, возвращает тру если роль есть
    FUNCTION CheckExistRole (p_role VARCHAR2)
        RETURN BOOLEAN
    IS
        l_qnt   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_qnt
          FROM dba_roles x
         WHERE x.role = UPPER (p_role);

        RETURN l_qnt > 0;
    END;

    PROCEDURE InitPref
    IS
        l_res   ikis_subsys.ss_instance_pref%TYPE;
    BEGIN
        SELECT a.ss_instance_pref
          INTO g_Pref
          FROM ikis_subsys a
         WHERE a.ss_main = 'Y';
    EXCEPTION
        WHEN TOO_MANY_ROWS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgMAIN_SUBSYS_DOUBLE));
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgMAIN_SUBSYS_ABSENCE));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'InitPref',
                                               SQLERRM));
    END;

    FUNCTION GetInstancePref
        RETURN VARCHAR2
    IS
        l_res   ikis_subsys.ss_instance_pref%TYPE;
    BEGIN
        IF g_Pref IS NULL
        THEN
            InitPref;

            IF g_Pref IS NULL
            THEN
                raise_application_error (
                    -20000,
                    ikis_message_util.GET_MESSAGE (msgUnkPref));
            END IF;
        END IF;

        RETURN g_Pref;
    END;

    PROCEDURE RepairResource (p_resource ikis_resource%ROWTYPE)
    IS
        l_cmd    VARCHAR2 (32760);
        l_pref   ikis_subsys.ss_instance_pref%TYPE;
    BEGIN
        l_pref := GetInstancePref;

        --+ Автор: YURA_A 15.04.2004 15:13:33
        --  Описание: добавлена проверка
        IF CheckExistRole (l_pref || p_resource.rsrc_name)
        THEN
            DBMS_OUTPUT.put_line (
                   'WARNING! Role '
                || l_pref
                || p_resource.rsrc_name
                || ' for resource '
                || p_resource.rsrc_name
                || ' already exist.');
        ELSE
            --- Автор: YURA_A 15.04.2004 15:13:37
            l_cmd := 'create role ' || l_pref || p_resource.rsrc_name;

            EXECUTE IMMEDIATE l_cmd;
        END IF;

        DECLARE --Если делать не под владельцем подсистемы, то можно отключить роли у исполняющего
            l_owner   VARCHAR2 (100);
        BEGIN
            SELECT x1.ss_owner
              INTO l_owner
              FROM ikis_subsys x1
             WHERE x1.ss_code = p_resource.rsrc_ss_code;

            IF NOT (l_owner = USER)
            THEN
                raise_application_error (
                    -20000,
                       'DEBUG: Not alloved this operation under user '
                    || USER
                    || '. Must be owner of subsystem.');
            END IF;
        END;

        l_cmd := 'alter user ' || USER || ' default role none';

        EXECUTE IMMEDIATE l_cmd;

        l_cmd :=
               'grant '
            || l_pref
            || p_resource.rsrc_name
            || ' to '
            || USER
            || ' with admin option';

        EXECUTE IMMEDIATE l_cmd;
    --  end if;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                       'ikis_secur_utl.RepairResource with '
                    || CHR (10)
                    || l_cmd,
                    SQLERRM));
    END;

    PROCEDURE RepairAttr (p_attr ikis_rsrc_attr%ROWTYPE)
    IS
        l_cmd     VARCHAR2 (32760);
        l_pref    ikis_subsys.ss_instance_pref%TYPE;
        l_owner   ikis_subsys.ss_owner%TYPE;
        l_cnt     NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO l_cnt
          FROM ikis_resource x
         WHERE     x.rsrc_name = p_attr.rat_rsrc
               AND x.rsrc_tp = ikis_const.v_dds_resource_tp_i;

        --gIgnoreErr:=true; --временно для Днепра
        IF l_cnt = 0
        THEN -- Роли и привилегии создаются только для не интерфейсных ролей ИКИСа
            IF     p_attr.rat_object_tp = ikis_const.v_dds_obj_tp_SCHEMA
               AND NOT (p_attr.rat_tp = ikis_const.v_dds_attr_tp_references)
            THEN
                SELECT x.ss_owner
                  INTO l_owner
                  FROM ikis_subsys x, ikis_resource z
                 WHERE     x.ss_code = z.rsrc_ss_code
                       AND z.rsrc_name = p_attr.rat_rsrc;

                l_pref := GetInstancePref;
                l_cmd :=
                       'grant '
                    || p_attr.rat_tp
                    || ' on '
                    || l_owner
                    || '.'
                    || p_attr.rat_object_name
                    || ' to '
                    || l_pref
                    || p_attr.rat_rsrc;

                IF gIgnoreErr
                THEN
                    BEGIN
                        EXECUTE IMMEDIATE l_cmd;
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            DBMS_OUTPUT.put_line (
                                   'WARNING! "'
                                || l_cmd
                                || '" error:'
                                || SQLERRM);
                    END;
                ELSE
                    EXECUTE IMMEDIATE l_cmd;
                END IF;
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'ikis_secur_utl.RepairAttr with ' || CHR (10) || l_cmd,
                    SQLERRM));
    END;

    PROCEDURE RepairRole (p_role ikis_role%ROWTYPE)
    IS
        l_cmd    VARCHAR2 (32760);
        l_prev   ikis_subsys.ss_instance_pref%TYPE;
    BEGIN
        l_prev := GetInstancePref;

        --+ Автор: YURA_A 15.04.2004 15:13:33
        --  Описание: добавлена проверка
        IF CheckExistRole (l_prev || p_role.irl_name)
        THEN
            DBMS_OUTPUT.put_line (
                   'WARNING! Role '
                || l_prev
                || p_role.irl_name
                || ' for role '
                || p_role.irl_name
                || ' already exist.');
        ELSE
            --- Автор: YURA_A 15.04.2004 15:13:37
            l_cmd := 'create role ' || l_prev || p_role.irl_name;

            EXECUTE IMMEDIATE l_cmd;
        END IF;

        DECLARE --Если делать не под владельцем подсистемы, то можно отключить роли у исполняющего
            l_owner   VARCHAR2 (100);
        BEGIN
            SELECT x1.ss_owner
              INTO l_owner
              FROM ikis_subsys x1
             WHERE x1.ss_code = p_role.irl_ss_code;

            IF NOT (l_owner = USER)
            THEN
                raise_application_error (
                    -20000,
                       'DEBUG: Not alloved this operation under user '
                    || USER
                    || '. Must be owner of subsystem.');
            END IF;
        END;

        l_cmd := 'alter user ' || USER || ' default role none';

        EXECUTE IMMEDIATE l_cmd;

        l_cmd :=
               'grant '
            || l_prev
            || p_role.irl_name
            || ' to '
            || USER
            || ' with admin option';

        EXECUTE IMMEDIATE l_cmd;
    --  end if;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'ikis_secur_utl.RepairRole with ' || CHR (10) || l_cmd,
                    SQLERRM));
    END;

    PROCEDURE RepairGroup (p_group ikis_group%ROWTYPE)
    IS
        l_cmd    VARCHAR2 (32760);
        l_prev   ikis_subsys.ss_instance_pref%TYPE;
    BEGIN
        l_prev := GetInstancePref;

        --+ Автор: YURA_A 15.04.2004 15:13:33
        --  Описание: добавлена проверка
        IF CheckExistRole (l_prev || p_group.igrp_name)
        THEN
            DBMS_OUTPUT.put_line (
                   'WARNING! Role '
                || l_prev
                || p_group.igrp_name
                || ' for role '
                || p_group.igrp_name
                || ' already exist.');
        ELSE
            --- Автор: YURA_A 15.04.2004 15:13:37
            l_cmd := 'create role ' || l_prev || p_group.igrp_name;

            EXECUTE IMMEDIATE l_cmd;
        END IF;

        DECLARE --Если делать не под владельцем подсистемы, то можно отключить роли у исполняющего
            l_owner   VARCHAR2 (100);
        BEGIN
            SELECT x1.ss_owner
              INTO l_owner
              FROM ikis_subsys x1
             WHERE x1.ss_code = p_group.igrp_ss_code;

            IF NOT (l_owner = USER)
            THEN
                raise_application_error (
                    -20000,
                       'DEBUG: Not alloved this operation under user '
                    || USER
                    || '. Must be owner of subsystem.');
            END IF;
        END;

        l_cmd := 'alter user ' || USER || ' default role none';

        EXECUTE IMMEDIATE l_cmd;

        l_cmd :=
               'grant '
            || l_prev
            || p_group.igrp_name
            || ' to '
            || USER
            || ' with admin option';

        EXECUTE IMMEDIATE l_cmd;
    --  end if;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'ikis_secur_utl.RepairRole with ' || CHR (10) || l_cmd,
                    SQLERRM));
    END;


    PROCEDURE RepairResourceToRole (p_rs2ro ikis_rsrc2role%ROWTYPE)
    IS
        l_cmd    VARCHAR2 (32760);
        l_prev   ikis_subsys.ss_instance_pref%TYPE;
        l_cnt    NUMBER;
    BEGIN
        --  select count(*)
        --    into l_cnt
        --    from ikis_role x
        --   where x.irl_name=p_rs2ro.rs2r_irl
        --     and x.irl_tp=ikis_const.v_dds_role_tp_i;
        --  if l_cnt=0 then  -- Роли и привилегии создаются только для не интерфейсных ролей ИКИСа
        l_prev := GetInstancePref;
        l_cmd :=
               'grant '
            || l_prev
            || p_rs2ro.rs2r_rsrc
            || ' to '
            || l_prev
            || p_rs2ro.rs2r_irl;

        EXECUTE IMMEDIATE l_cmd;
    --  end if;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'ikis_secur_utl.RepairRole with ' || CHR (10) || l_cmd,
                    SQLERRM));
    END;

    PROCEDURE RepairRoleToGroup (p_rl2grp ikis_role2group%ROWTYPE)
    IS
        l_cmd    VARCHAR2 (32760);
        l_prev   ikis_subsys.ss_instance_pref%TYPE;
        l_cnt    NUMBER;
    BEGIN
        --  select count(*)
        --    into l_cnt
        --    from ikis_role x
        --   where x.irl_name=p_rs2ro.rs2r_irl
        --     and x.irl_tp=ikis_const.v_dds_role_tp_i;
        --  if l_cnt=0 then  -- Роли и привилегии создаются только для не интерфейсных ролей ИКИСа
        l_prev := GetInstancePref;
        l_cmd :=
               'grant '
            || l_prev
            || p_rl2grp.irg2g_irl
            || ' to '
            || l_prev
            || p_rl2grp.irg2g_igrp;

        EXECUTE IMMEDIATE l_cmd;
    --  end if;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'ikis_secur_utl.RepairRole with ' || CHR (10) || l_cmd,
                    SQLERRM));
    END;


    ----------------------------------------
    -- YURA_A 08.08.2003 17:16:17
    ----------------------------------------
    -- Назначение : Создать ресурсы с привилегиями и роли по метаданным для подсистемы
    PROCEDURE CreateRole (p_subsys ikis_subsys.ss_code%TYPE)
    IS
    BEGIN
        FOR rsrc IN (SELECT *
                       FROM ikis_resource
                      WHERE rsrc_ss_code = p_subsys)
        LOOP
            RepairResource (rsrc);
        END LOOP;

        FOR ratt
            IN (SELECT x.*
                  FROM ikis_rsrc_attr x, ikis_resource y
                 WHERE x.rat_rsrc = y.rsrc_name AND y.rsrc_ss_code = p_subsys)
        LOOP
            RepairAttr (ratt);
        END LOOP;

        FOR rrole IN (SELECT *
                        FROM ikis_role
                       WHERE irl_ss_code = p_subsys)
        LOOP
            RepairRole (rrole);
        END LOOP;

        FOR rsrc2role
            IN (SELECT ikis_rsrc2role.*
                  FROM ikis_rsrc2role, ikis_resource
                 WHERE rs2r_rsrc = rsrc_name AND rsrc_ss_code = p_subsys)
        LOOP
            RepairResourceToRole (rsrc2role);
        END LOOP;
    END;

    PROCEDURE CreateGroup (p_subsys ikis_subsys.ss_code%TYPE)
    IS
    BEGIN
        FOR grp IN (SELECT ikis_group.*
                      FROM ikis_group
                     WHERE igrp_ss_code = p_subsys)
        LOOP
            RepairGroup (grp);
        END LOOP;

        FOR rl2grp
            IN (SELECT ikis_role2group.*
                  FROM ikis_group, ikis_role2group, ikis_role
                 WHERE     irg2g_igrp = igrp_name
                       AND irg2g_irl = irl_name
                       AND igrp_ss_code = p_subsys)
        LOOP
            RepairRoleToGroup (rl2grp);
        END LOOP;
    END;

    ----------------------------------------
    -- YURA_A 08.08.2003 17:17:12
    ----------------------------------------
    -- Назначение : Восстановить роли/привилегии для метаданных по подсистеме
    PROCEDURE RepairResourceRole (p_subsys ikis_subsys.ss_code%TYPE)
    IS
        l_cmd     VARCHAR2 (32760);
        l_rsrc    ikis_resource%ROWTYPE;
        l_attr    ikis_rsrc_attr%ROWTYPE;
        l_role    ikis_role%ROWTYPE;
        l_group   ikis_group%ROWTYPE;
        l_rr      ikis_rsrc2role%ROWTYPE;
        l_rg      ikis_role2group%ROWTYPE;
    BEGIN
        IF gIgnoreErr
        THEN
            DBMS_OUTPUT.put_line (
                'Ignore errors is set in ikis_secur_utl.RepairAttr.');
        ELSE
            DBMS_OUTPUT.put_line (
                'Ignore errors is not set in ikis_secur_utl.RepairAttr.');
        END IF;

        --Сначала лишаем привилегий для ролей и ресурсов удаленных метаданных
        -- 1 Назначение ролей группам ревокаем
        FOR a_revoke IN (SELECT *
                           FROM v_all_orole2ikis_role2group x
                          WHERE x.rs2r_status = stInvalid)
        LOOP
            l_cmd :=
                   'revoke '
                || a_revoke.granted_role
                || ' from '
                || a_revoke.role;

            EXECUTE IMMEDIATE l_cmd;
        END LOOP;

        -- 2 Назначения ресуров ролям ревокаем
        FOR a_revoke IN (SELECT *
                           FROM v_all_orole2ikis_resource2role x
                          WHERE x.rs2r_status = stInvalid)
        LOOP
            l_cmd :=
                   'revoke '
                || a_revoke.granted_role
                || ' from '
                || a_revoke.role;

            EXECUTE IMMEDIATE l_cmd;
        END LOOP;

        -- 3 Группы, роли и ресурсы удаляем
        FOR a_revoke
            IN (SELECT *
                  FROM v_all_orole2ikis_role_resource x
                 WHERE x.irl_ss_code = p_subsys AND x.irl_status = stInvalid)
        LOOP
            l_cmd := 'drop role ' || a_revoke.role;

            EXECUTE IMMEDIATE l_cmd;
        END LOOP;

        --Создаем роли привилегии для ресурсов и ролей и назначаем их друг другу
        -- 1 Создаем роли для ресурсов, для которых нету ролей
        FOR a_role
            IN (SELECT *
                  FROM v_all_ikis_resource x
                 WHERE     x.rsrc_ss_code = p_subsys
                       AND x.role_status = stInvalid)
        LOOP
            SELECT *
              INTO l_rsrc
              FROM ikis_resource
             WHERE ROWID = a_role.rsrc_rowid;

            RepairResource (l_rsrc);
        END LOOP;

        -- 2 Делаем привилегии для ресурсов, где отсутствовали привилегии
        FOR a_priv IN (SELECT *
                         FROM v_all_ikis_resource_attrib
                        WHERE rsrc_ss_code = p_subsys AND status = stInvalid)
        LOOP
            SELECT *
              INTO l_attr
              FROM ikis_rsrc_attr
             WHERE ROWID = a_priv.attr_rowid;

            RepairAttr (l_attr);
        END LOOP;

        -- 3 Создаем роли для ролей икис, для тех что не было ролей
        FOR a_role
            IN (SELECT *
                  FROM v_all_ikis_role
                 WHERE irl_ss_code = p_subsys AND role_status = stInvalid)
        LOOP
            SELECT *
              INTO l_role
              FROM ikis_role
             WHERE ROWID = a_role.role_rowid;

            RepairRole (l_role);
        END LOOP;

        -- 4 Созадем группы групп икис, для тех, что не было групп
        FOR a_group
            IN (SELECT *
                  FROM v_all_ikis_group
                 WHERE igrp_ss_code = p_subsys AND group_status = stInvalid)
        LOOP
            SELECT *
              INTO l_group
              FROM ikis_group
             WHERE ROWID = a_group.group_rowid;

            RepairGroup (l_group);
        END LOOP;

        -- 5 Назначаем ролям ресурсы, то что не было назначено
        FOR arr
            IN (SELECT x.*
                  FROM v_all_ikis_resource2role x, ikis_role y
                 WHERE     x.rs2r_irl = y.irl_name
                       AND y.irl_ss_code = p_subsys
                       AND x.rs2r_status = stInvalid)
        LOOP
            SELECT *
              INTO l_rr
              FROM ikis_rsrc2role
             WHERE ROWID = arr.rr_rowid;

            RepairResourceToRole (l_rr);
        END LOOP;

        -- 6 Назначаем группам роли, то что не было назначено
        FOR grl
            IN (SELECT x.*
                  FROM v_all_ikis_role2group x, ikis_group y
                 WHERE     x.irg2g_igrp = y.igrp_name
                       AND y.igrp_ss_code = p_subsys
                       AND x.IRG2G_STATUS = stInvalid)
        LOOP
            SELECT *
              INTO l_rg
              FROM ikis_role2group
             WHERE ROWID = grl.rr_rowid;

            RepairRoleToGroup (l_rg);
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'ikis_secur_utl.RepairRole with ' || CHR (10) || l_cmd,
                    SQLERRM));
    END;

    PROCEDURE RepairSubSysSynonym (p_subsys ikis_subsys.ss_code%TYPE)
    IS
    BEGIN
        raise_application_error (-20000, 'Feature depricated.');

        FOR vUser IN (SELECT *
                        FROM v_ikis_users
                       WHERE iu_status IN ('L', 'A'))
        LOOP
            IKIS_SECURITY.DropSubSysSynonym (p_subsys, vUser.iu_username);
            IKIS_SECURITY.CreateSubSysSynonym (p_subsys, vUser.iu_username);
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                       'IKIS_SECURITY.RepairSubSysSynonym with '
                    || CHR (10)
                    || SQLERRM));
    END;
END ikis_secur_utl;
/