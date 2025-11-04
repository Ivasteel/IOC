/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.ikis_params
IS
    -- Author  : YURA_A
    -- Created : 12.09.2003 9:57:38
    -- Purpose : Установка критичных параметров системы

    ----------------------------------------
    -- YURA_A 12.09.2003 10:15:49
    ----------------------------------------
    -- Назначение : Установка органа ПФУ для системы
    -- Параметры  : ид органу ПФУ по справочнику opfu
    PROCEDURE SetOPFU (p_OPFU VARCHAR2);

    ----------------------------------------
    -- YURA_A 22.09.2003 12:37:18
    ----------------------------------------
    -- Назначение : Обработка контрольной суммы некоторых параметров
    FUNCTION GetCheckSum
        RETURN VARCHAR2;

    PROCEDURE SetCheckSum;
END ikis_params;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_PARAMS FOR IKIS_SYS.IKIS_PARAMS
/


GRANT EXECUTE ON IKIS_SYS.IKIS_PARAMS TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PARAMS TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PARAMS TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PARAMS TO IKIS_SYSWEB WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PARAMS TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PARAMS TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PARAMS TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PARAMS TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PARAMS TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PARAMS TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PARAMS TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PARAMS TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PARAMS TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:10:04 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.ikis_params
IS
    g_CentralNode                  INTEGER;
    g_AppLevel_District   CONSTANT CHAR (1) := 'D';
    g_AppLevel_Region     CONSTANT CHAR (1) := 'R';
    g_AppLevel_Center     CONSTANT CHAR (1) := 'C';


    -- Messages for category: COMMON
    msgUNIQUE_VIOLATION            NUMBER := 1;
    msgCOMMON_EXCEPTION            NUMBER := 2;
    msgAlreadyLocked               NUMBER := 77;
    msgDataChanged                 NUMBER := 78;
    msgEstablish                   NUMBER := 79;
    msgGroupControlError           NUMBER := 97;
    msgProgramError                NUMBER := 117;
    msgFEATURENOTENABLED           NUMBER := 213;
    msgParamNotFound               NUMBER := 298;
    msgUnkAppParam                 NUMBER := 517;
    msgChAppParam                  NUMBER := 518;

    -- Messages for category: SUBSYS_UTIL
    msgInvalidOPFU                 NUMBER := 1203;
    msgInvalInstOpfu               NUMBER := 1361;


    PROCEDURE SetApptParams (p_name VARCHAR2, p_value VARCHAR2)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_value   appt_params.aptprm_value%TYPE;
    BEGIN
        debug.f ('Start procedure');

        SELECT x.aptprm_value
          INTO l_value
          FROM appt_params x
         WHERE UPPER (x.aptprm_name) = UPPER (p_name);

        --  if l_value is not null then
        --    dbms_output.put_line(ikis_message_util.get_message(msgChAppParam,upper(p_name),l_value,p_value));
        --  end if;
        UPDATE appt_params
           SET aptprm_value = p_value
         WHERE UPPER (aptprm_name) = UPPER (p_name);

        COMMIT;
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgUnkAppParam,
                                               UPPER (p_name)));
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'ikis_params.SetApptParams',
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE CheckOPFU (p_OPFU VARCHAR2)
    IS
        exInvalidOpfu   EXCEPTION;
        exClosedOPFU    EXCEPTION;
        l_opfu          v_opfu%ROWTYPE;
        l_code          VARCHAR2 (32765);
    BEGIN
        debug.f ('Start procedure');

        BEGIN
            l_code := TO_NUMBER (p_OPFU);
        EXCEPTION
            WHEN OTHERS
            THEN
                RAISE exInvalidOpfu;
        END;

        SELECT *
          INTO l_opfu
          FROM v_opfu x
         WHERE x.org_id = TO_NUMBER (p_OPFU);

        IF    l_opfu.org_stop_dt IS NOT NULL
           OR NOT (l_opfu.org_st = ikis_const.V_DDS_DICS_ST_A)
        THEN
            RAISE exClosedOPFU;
        END IF;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgInvalInstOpfu,
                    'код "' || p_OPFU || '" не знайдено в довіднику'));
        WHEN exInvalidOpfu
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgInvalInstOpfu,
                       ' код "'
                    || p_OPFU
                    || '" неможливо перетворити код в ідентифікатор ОПФУ'));
        WHEN exClosedOPFU
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgInvalInstOpfu,
                    ' ОПФУ з кодом "' || p_OPFU || '" позначено як закритий'));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'ikis_params.CheckOPFU',
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE SetOPFU (p_OPFU VARCHAR2)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_opfu_master   opfu.org_org%TYPE;
        l_old_opfu      opfu.org_org%TYPE;
    BEGIN
        debug.f ('Start procedure');
        -- проверяем код опфу
        CheckOPFU (p_OPFU);
        --Сохраняем старое значение органа пфу
        l_old_opfu := ikis_common.getap_ikis_opfu;

        --Встановлюю код головної організації
        --  SetApptParams('IKIS_CENTRAL_NODE',g_CentralNode);
        --устанавливаем код органа пфу
        SetApptParams ('IKIS_OPFU', p_OPFU);

        --устанавливаем уровень установки приложения
        IF TO_NUMBER (p_OPFU) = g_CentralNode
        THEN
            SetApptParams ('IKIS_APPLEVEL', g_AppLevel_Center);
        ELSE
            BEGIN
                SELECT y.org_org
                  INTO l_opfu_master
                  FROM opfu y
                 WHERE y.org_id = TO_NUMBER (p_OPFU);
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    raise_application_error (
                        -20000,
                        ikis_message_util.GET_MESSAGE (msgInvalidOPFU,
                                                       p_OPFU));
            END;

            IF l_opfu_master = g_CentralNode
            THEN
                SetApptParams ('IKIS_APPLEVEL', g_AppLevel_Region);
            ELSE
                SetApptParams ('IKIS_APPLEVEL', g_AppLevel_District);
            END IF;
        END IF;

        --устанавливаем значение контрольной суммы параметров
        SetCheckSum;

        --+ Автор: YURA_A 10.02.2004 11:49:53
        -- обновляем код органа пфу у пользователей икис
        IF l_old_opfu IS NOT NULL
        THEN
            UPDATE ikis_users_attr
               SET iusr_org = p_OPFU
             WHERE iusr_org = l_old_opfu;
        END IF;

        --- Автор: YURA_A 10.02.2004 11:50:00

        --Установка начальных значений контрольных цифр
        ikis_obmf.setstr (0);
        ikis_obmf.setstr1 (0);

        COMMIT;
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            RAISE;
    END;

    FUNCTION GetCheckSum
        RETURN VARCHAR2
    IS
        l_ss               ikis_subsys.ss_owner%TYPE;
        l_par              VARCHAR2 (2000);

        input_string       VARCHAR2 (255);
        key_string         VARCHAR2 (8);
        encrypted_string   VARCHAR2 (255);
    BEGIN
        debug.f ('Start procedure');

        SELECT ikis_subsys.ss_instance_pref
          INTO l_ss
          FROM ikis_subsys
         WHERE ikis_subsys.ss_code = 'IKIS_SYS';

        FOR imp_par
            IN (SELECT appt_params.aptprm_value
                  FROM appt_params
                 WHERE appt_params.aptprm_name IN
                           ('IKIS_OPFU', 'IKIS_APPLEVEL'))
        LOOP                                             --,'IKIS_ERS_ISCLEAR'
            l_par := l_par || imp_par.aptprm_value;
        END LOOP;

        input_string :=
            RPAD (l_par, (TRUNC (LENGTH (l_par) / 8)) * 8 + 8, l_par);
        key_string := RPAD (l_ss, 8, l_ss);

        DBMS_OBFUSCATION_TOOLKIT.DESEncrypt (
            input_string       => input_string,
            key_string         => key_string,
            encrypted_string   => encrypted_string);
        debug.f ('Stop procedure');
        RETURN RAWTOHEX (UTL_RAW.CAST_TO_RAW (encrypted_string));
    END;

    PROCEDURE SetCheckSum
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_chs   appt_params.aptprm_value%TYPE;
    BEGIN
        debug.f ('Start procedure');
        l_chs := GetCheckSum;

        UPDATE appt_params
           SET appt_params.aptprm_value = l_chs
         WHERE appt_params.aptprm_name = 'IKIS_SYS_CHS';

        COMMIT;
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            RAISE;
    --  dbms_output.put_line(ikis_message_util.get_message(msgChAppParam,upper('IKIS_SYS_CHS'),'NULL','*****'));
    END;

    ----------------------------------------
    -- YURA_A 22.09.2003 12:36:17
    ----------------------------------------
    -- Назначение : Установка отметки о выполнении очищения ЕРС
    -- Параметры  : бп
    --procedure SetERS_CLEAR
    --is
    --begin
    --  SetApptParams('IKIS_ERS_ISCLEAR',ikis_const.v_dds_yn_y);
    --end;
    --Rayba
    --8.11.2004
    --Процедура ініціалізує початкові параметри
    PROCEDURE Init
    IS
    BEGIN
        SELECT org_id
          INTO g_CentralNode
          FROM opfu
         WHERE org_org IS NULL AND opfu.org_st = 'A';
    END;
BEGIN
    Init;
END ikis_params;
/