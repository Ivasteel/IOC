/* Formatted on 8/12/2025 6:10:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_SUBSYS_UTIL
IS
    -- Author  : YURA_A
    -- Created : 12.06.2003 13:14:48
    -- Purpose : Ведення підсистем (реєстрація)


    -- Messages for category: SUBSYS_UTIL
    msgUNKNOWN_SUBSYS_CODE       CONSTANT NUMBER := 3;
    msgSUBSYS_ALREDY_REG         CONSTANT NUMBER := 4;
    msgUNKNOWN_USER              CONSTANT NUMBER := 5;
    msgPREF_ALREADY_INST         CONSTANT NUMBER := 6;
    msgMAIN_SUBSYS_ABSENCE       CONSTANT NUMBER := 7;
    msgMAIN_SUBSYS_DOUBLE        CONSTANT NUMBER := 8;
    msgDOUBLE_SUBSYS_IN_SCHEMA   CONSTANT NUMBER := 9;


    -- Назва головної підсистеми
    FUNCTION g_IKIS_SYS
        RETURN VARCHAR2;

    FUNCTION g_IKIS_ROOT_ROLE
        RETURN VARCHAR2;

    PROCEDURE Register_SubSys (p_ss_code    ikis_subsys.ss_code%TYPE,
                               p_ss_owner   ikis_subsys.ss_owner%TYPE);

    PROCEDURE Set_Instance_Prefix (
        p_prefix   ikis_subsys.ss_instance_pref%TYPE);


    FUNCTION GetInstancePref
        RETURN VARCHAR2;

    PROCEDURE Get_SubSys_Attr (p_ss_code       ikis_subsys.ss_code%TYPE,
                               p_cc_attr   OUT ikis_subsys%ROWTYPE);

    PROCEDURE Get_SubSys_Attr_own (
        p_ss_owner       ikis_subsys.ss_owner%TYPE,
        p_cc_attr    OUT ikis_subsys%ROWTYPE);

    PROCEDURE CreateRootRole;
END IKIS_SUBSYS_UTIL;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_SUBSYS_UTIL FOR IKIS_SYS.IKIS_SUBSYS_UTIL
/


GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTIL TO II01RC_IKIS_DESIGN
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTIL TO II01RC_IKIS_SUPERUSER
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTIL TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTIL TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTIL TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTIL TO IKIS_SYSWEB WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTIL TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTIL TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTIL TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTIL TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTIL TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTIL TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTIL TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTIL TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTIL TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:10:05 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_SUBSYS_UTIL
IS
    l_IKIS_SYS              ikis_subsys.ss_code%TYPE := 'IKIS_SYS';
    l_IKIS_ROOT_ROLE        ikis_subsys.ss_root_role%TYPE;
    l_IKIS_ROOT_ROLE_SUFF   VARCHAR2 (10) := '_ROOT_ROLE';
    l_instance_pref         ikis_subsys.ss_instance_pref%TYPE := NULL;

    exAlreadyRegistered     EXCEPTION;
    exUnkUser               EXCEPTION;


    FUNCTION g_IKIS_SYS
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN l_IKIS_SYS;
    END;

    FUNCTION g_IKIS_ROOT_ROLE
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN l_IKIS_ROOT_ROLE;
    END;

    FUNCTION GetInstancePref
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN l_instance_pref;
    END;

    PROCEDURE InitRootRole
    IS
        l_res   ikis_subsys.ss_instance_pref%TYPE;
    BEGIN
        SELECT ss_root_role
          INTO l_IKIS_ROOT_ROLE
          FROM ikis_subsys
         WHERE ss_code = l_IKIS_SYS;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_SUBSYS_UTIL.InitRootRole',
                    SQLERRM));
    END;


    PROCEDURE InitInstancePref
    IS
        l_res   ikis_subsys.ss_instance_pref%TYPE;
    BEGIN
        SELECT a.ss_instance_pref
          INTO l_instance_pref
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
                ikis_message_util.GET_MESSAGE (msgMAIN_SUBSYS_ABSENCE,
                                               l_IKIS_SYS));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_SUBSYS_UTIL.InitInstancePref',
                    SQLERRM));
    END;

    PROCEDURE Init
    IS
    BEGIN
        InitRootRole;
        InitInstancePref;
    END;

    PROCEDURE Register_SubSys (p_ss_code    ikis_subsys.ss_code%TYPE,
                               p_ss_owner   ikis_subsys.ss_owner%TYPE)
    IS
        r_ikis_subsys   ikis_subsys%ROWTYPE;
        l_cnt           INTEGER;
    BEGIN
        debug.f ('Start procedure');
        Get_SubSys_Attr (p_ss_code, r_ikis_subsys);

        IF r_ikis_subsys.ss_owner IS NOT NULL
        THEN
            RAISE exAlreadyRegistered;
        END IF;

        SELECT COUNT (*)
          INTO l_cnt
          FROM all_users
         WHERE UPPER (all_users.username) = UPPER (p_ss_owner);

        IF l_cnt = 1
        THEN
            NULL;
        ELSE
            RAISE exUnkUser;
        END IF;

        UPDATE ikis_subsys
           SET ss_owner = UPPER (p_ss_owner)
         WHERE UPPER (ss_code) = UPPER (p_ss_code);

        COMMIT;
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN exAlreadyRegistered
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgSUBSYS_ALREDY_REG,
                                               p_ss_owner));
        WHEN exUnkUser
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgUNKNOWN_USER, p_ss_owner));
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_SUBSYS_UTIL.Register_SubSys',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE Set_Instance_Prefix (
        p_prefix   ikis_subsys.ss_instance_pref%TYPE)
    IS
        r_ikis_subsys   ikis_subsys%ROWTYPE;
        l_data          VARCHAR2 (32765);
    BEGIN
        debug.f ('Start procedure');
        Get_SubSys_Attr (l_IKIS_SYS, r_ikis_subsys);

        --  if r_ikis_subsys.ss_instance_pref is not null then
        --    raise_application_error(-20000, replace(ikis_message_util.Get_Message(msgPREF_ALREADY_INST),'<P1>',r_ikis_subsys.ss_instance_pref));
        --  end if;
        IF r_ikis_subsys.ss_instance_pref IS NULL
        THEN
            UPDATE ikis_subsys
               SET ss_instance_pref = UPPER (p_prefix)
             WHERE ss_code = l_IKIS_SYS;

            COMMIT;
        END IF;

        --Установка директории для складывания контрольного файла репликации
        ikis_obmf.install;
        --Установка начальных значений контрольных цифр
        --  ikis_obmf.setstr(0);
        --  ikis_obmf.setstr1(0);

        --Установка возможности изменения схем
        l_data :=
            ikis_crypt.encryptraw (UTL_RAW.cast_to_raw ('CAN_DDL'),
                                   UTL_RAW.cast_to_raw ('12345678'));
        --Ryaba
        --03.11.2004
        --Замінено спосіб встановлення та збереження паролю розюлокування операцій DDL
        --ikis_parameter_util.addparameter('DDL_PWD','IKIS_SYS',l_data);
        ikis_ddl.SetDDLParam (l_data);
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_SUBSYS_UTIL.Set_Instance_Prefix',
                    SQLERRM));
    END;



    PROCEDURE Get_SubSys_Attr (p_ss_code       ikis_subsys.ss_code%TYPE,
                               p_cc_attr   OUT ikis_subsys%ROWTYPE)
    IS
    BEGIN
        SELECT *
          INTO p_cc_attr
          FROM ikis_subsys
         WHERE ss_code = p_ss_code;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgUNKNOWN_SUBSYS_CODE,
                                               p_ss_code));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_SUBSYS_UTIL.Get_SubSys_Attr',
                    SQLERRM));
    END;

    PROCEDURE Get_SubSys_Attr_own (
        p_ss_owner       ikis_subsys.ss_owner%TYPE,
        p_cc_attr    OUT ikis_subsys%ROWTYPE)
    IS
    BEGIN
        SELECT *
          INTO p_cc_attr
          FROM ikis_subsys
         WHERE ss_owner = p_ss_owner;
    EXCEPTION
        WHEN TOO_MANY_ROWS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgDOUBLE_SUBSYS_IN_SCHEMA,
                                               p_ss_owner));
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgUNKNOWN_USER, p_ss_owner));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_SUBSYS_UTIL.Get_SubSys_Attr_own',
                    SQLERRM));
    END;

    PROCEDURE CreateRootRole
    IS
        l_pref   ikis_subsys.ss_instance_pref%TYPE;
        l_cmd    VARCHAR2 (32760);
    BEGIN
        debug.f ('Start procedure');
        InitInstancePref;
        l_pref := GetInstancePref;
        l_cmd := 'create role ' || GetInstancePref || l_IKIS_ROOT_ROLE_SUFF;

        EXECUTE IMMEDIATE l_cmd;

        --Ryaba
        --для возможности вешать триггера на схему
        l_cmd :=
               'grant execute on ikis_changes_utl to '
            || GetInstancePref
            || l_IKIS_ROOT_ROLE_SUFF;

        EXECUTE IMMEDIATE l_cmd;

        UPDATE ikis_subsys
           SET ss_root_role = l_pref || l_IKIS_ROOT_ROLE_SUFF
         WHERE ss_code = l_IKIS_SYS;

        COMMIT;
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_SUBSYS_UTIL.CreateRootRole with:',
                    l_cmd || CHR (10) || SQLERRM));
    END;
BEGIN
    init;
END IKIS_SUBSYS_UTIL;
/