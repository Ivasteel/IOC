/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.ikis_common
IS
    -- Author  : YURA_A
    -- Created : 28.07.2003 18:00:50
    -- Purpose : Общие определения

    -- Указатель на курсор для разнообразных отчетных процедур
    TYPE TReportResult IS REF CURSOR;

    TYPE TCommaTable IS TABLE OF VARCHAR2 (255)
        INDEX BY BINARY_INTEGER;

    SUBTYPE t_ikis_users_attr IS ikis_users_attr%ROWTYPE;

    ----------------------------------------
    -- YURA_A 06.09.2003 16:17:22
    ----------------------------------------
    -- Назначение : Константы уровней установки пролижения
    alDistrict   CONSTANT VARCHAR2 (1) := 'D';
    alRegion     CONSTANT VARCHAR2 (1) := 'R';
    alCenter     CONSTANT VARCHAR2 (1) := 'C';

    max_date              DATE := TO_DATE ('31124712', 'DDMMYYYY');
    --  min_date      date       :=to_date('01014712 BC', 'DDMMYYYY BC');

    ----------------------------------------
    -- KYB 01.04.2004 10:16:21
    ----------------------------------------
    -- Назначение : Константы-границы для позначек "сплачено"
    cached_begin_dt       DATE := TO_DATE ('01012004', 'DDMMYYYY');
    cached_end_dt         DATE := TO_DATE ('31123000', 'DDMMYYYY');

    ----------------------------------------
    -- YURA_A 07.08.2003 14:42:21
    ----------------------------------------
    -- Назначение : Получение скриптов из таблицы ikis_scripts
    -- Параметры  : код скрипта p_code соотв. полю ikis_scripts.isc_code
    -- p_scr_p1 и p_scr_p2 части скрипта
    PROCEDURE Get_Script (p_code         ikis_scripts.isc_code%TYPE,
                          p_scr_p1   OUT ikis_scripts.isc_query%TYPE,
                          p_scr_p2   OUT ikis_scripts.isc_where%TYPE);

    ----------------------------------------
    -- YURA_A 07.08.2003 14:42:18
    ----------------------------------------
    -- Назначение : преобразует секунды в часы минуты секунды (строковое представление)
    -- Параметры  : p_sec - секунды
    FUNCTION SecToFullTime (p_sec NUMBER)
        RETURN VARCHAR2;

    ----------------------------------------
    -- YURA_A 07.08.2003 14:42:16
    ----------------------------------------
    -- Назначение : Получение значеня параметра из appt_params
    -- Параметры  : p_name - название параметра поле appt_params.aptprm_name
    FUNCTION GetApptParam (p_name         appt_params.aptprm_name%TYPE,
                           p_default   IN VARCHAR2 := NULL)
        RETURN appt_params.aptprm_value%TYPE;

    PROCEDURE PGetApptParam (p_name        appt_params.aptprm_name%TYPE,
                             p_value   OUT appt_params.aptprm_value%TYPE);

    ----------------------------------------
    -- YURA_A 04.09.2003 14:19:54
    ----------------------------------------
    -- Назначение : Функции возвращают кешированное значение соотв. параметра
    -- из аппт-парамс (только те что принадлежат ИКИС)
    -- Параметры  : б/п
    FUNCTION GetAP_IKIS_OPFU
        RETURN VARCHAR2;

    FUNCTION GetAP_IKIS_PFU_VERSION (p_recipient VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;

    FUNCTION GetAP_IKIS_APPLEVEL
        RETURN VARCHAR2;

    ----------------------------------------
    -- YURA_A 04.09.2003 15:43:51
    ----------------------------------------
    -- Назначение : Возвращают диапазон ИД выбранного узла
    -- Параметры  : ид узла
    FUNCTION GetNodeDiapLow (p_node VARCHAR2)
        RETURN NUMBER;

    FUNCTION GetNodeDiapHi (p_node VARCHAR2)
        RETURN NUMBER;

    ----------------------------------------
    -- YURA_A 05.09.2003 16:12:20
    ----------------------------------------
    -- Назначение : Парсер списка через запятую в таблицу TCommaTable (см вверху)
    -- Параметры  : список, количество найденных елементов, таблица
    PROCEDURE comma_to_table (p_lst         VARCHAR2,
                              p_cnt     OUT INTEGER,
                              p_table   OUT TCommaTable);

    ----------------------------------------
    -- YURA_A 19.09.2003 14:40:36
    ----------------------------------------
    -- Назначение : Сбор статистики оптимизатора по схеме
    -- Параметры  : имя подсистемы
    PROCEDURE AnalyzeIkisSubSys (p_subsys ikis_subsys.ss_code%TYPE);

    ----------------------------------------
    -- YURA_A 14.04.2004 11:33:23
    ----------------------------------------
    -- Назначение : Сбор статистики оптимизатора по таблице из подсистемы
    -- Параметры  : имя подсистемы, имя таблицы
    PROCEDURE AnalyzeIkisSubSysTable (p_subsys   ikis_subsys.ss_code%TYPE,
                                      p_table    VARCHAR2);

    ----------------------------------------
    -- KYB 19.09.2003 17:30:36
    ----------------------------------------
    -- Назначение : Получение уникального идентификатора для списка
    --   параметров отчета RPT_COMMON (берется из SQ_OTH_RPT_PAR_SES)
    PROCEDURE Get_OthRptPar_Ses (p_par_ses_id OUT NUMBER);

    ----------------------------------------
    -- KYB 19.09.2003 17:30:36
    ----------------------------------------
    -- Назначение : Запись одного(из нескольких) значения параметра отчета RPT_COMMON
    --  в таблицу IKIS_RPT_PAR_LST
    -- Параметры : ид сессии отчета, значение параметра
    PROCEDURE Ins_RptParam (
        p_par_ses_id   IN ikis_rpt_par_lst.rps_id%TYPE,
        p_par_value    IN ikis_rpt_par_lst.rps_value%TYPE);

    ----------------------------------------
    -- YURA_A 22.09.2003 12:37:52
    ----------------------------------------
    -- Назначение : Проверка контрольной суммы некоторых параметров на старте
    -- Параметры  : бп
    PROCEDURE CheckIntegrityParams;

    ----------------------------------------
    -- KYB 30.09.2003 11:39:28
    ----------------------------------------
    -- Назначение : Возвращает данные о текущем пользователе
    -- Параметры  : p_iusr_id - ид пользователя
    --              p_iusr_name - ФИО пользователя
    --              p_iusr_numident - идентификационный номер пользователя
    --              p_iusr_comp - робочее место пользователя
    --              p_iusr_login - логин пользователя
    PROCEDURE Get_CurrUserProps (
        p_iusr_id         OUT ikis_users_attr.iusr_id%TYPE,
        p_iusr_name       OUT ikis_users_attr.iusr_name%TYPE,
        p_iusr_numident   OUT ikis_users_attr.iusr_numident%TYPE,
        p_iusr_comp       OUT ikis_users_attr.iusr_comp%TYPE,
        p_iusr_login      OUT ikis_users_attr.iusr_login%TYPE);

    ----------------------------------------
    -- KYB 06.05.2005 14:08:24
    ----------------------------------------
    -- Назначение : Проверяет выдана ли указанная роль указанному юзеру
    -- Параметры  : ІД юзера, имя роли
    -- Результат  : 1 = роль выдана; 0 = роль НЕ выдана
    FUNCTION IsRoleGrantedToUser (p_user       VARCHAR2,
                                  p_irl_name   ikis_role.irl_name%TYPE)
        RETURN NUMBER;


    ----------------------------------------
    -- YURA_A 07.10.2003 11:17:18
    ----------------------------------------
    -- Назначение : Очистка протоколов
    -- Параметры  : p_option - тип очистки
    -- 0 - все
    -- 1 - то что устарело на 3 месяцa
    PROCEDURE ClearProtocol (p_option INTEGER);

    ----------------------------------------
    -- YURA_A 14.10.2003 10:25:53
    ----------------------------------------
    -- Назначение : Сравнение структуры таблиц из разных схем по спискам
    -- Параметры  : схема 1, список таблиц из схемы 1
    -- схема 2, список таблиц из схемы 2
    PROCEDURE CompareTables (p_owner1      VARCHAR2,
                             p_tablelst1   VARCHAR2,
                             p_owner2      VARCHAR2,
                             p_tablelst2   VARCHAR2);

    ----------------------------------------
    -- YURA_A 21.10.2003 17:54:26
    ----------------------------------------
    -- Назначение : Вывод информации в строку статуса приложения
    -- Параметры  : номер секскии (по порядку), сообщение
    PROCEDURE GetStatusBar (p_section NUMBER, p_msg OUT VARCHAR2);

    ----------------------------------------
    -- YURA_A 31.10.2003 14:35:55
    ----------------------------------------
    -- Назначение : Включение и выключение трассировки SQL_TRACE
    PROCEDURE SetTraceOn;

    PROCEDURE SetTraceOnRegKey (p_devs_sub_sys_lst VARCHAR2);

    PROCEDURE SetTraceOff;

    ----------------------------------------
    -- YURA_A 09.12.2003 11:58:29
    ----------------------------------------
    -- Назначение : Установка статистики  через dbms_stats.set_table_stats
    -- Параметры  : код подсистемы, таблица, кол-во строк, кол-во блоков, средняя длина строки
    PROCEDURE SetStatOnTable (p_ss_code   ikis_subsys.ss_code%TYPE,
                              p_tabname   VARCHAR2,
                              p_numrows   NUMBER,
                              p_numblks   NUMBER,
                              p_avgrlen   NUMBER);

    ----------------------------------------
    -- YURA_A 07.03.2006 15:00:19
    ----------------------------------------
    -- Назначение : получение системных аттрибутов текущей сессии
    -- Параметры  : идентификатор сессии, идентификатор пользователя, имя пользователя,имя компьютера,ip-адрес, имя пользователя ОС
    PROCEDURE GetCurrenUserSysAttr (p_sesid      OUT NUMBER,
                                    p_sesuid     OUT NUMBER,
                                    p_sesusr     OUT VARCHAR2,
                                    p_host       OUT VARCHAR2,
                                    p_ipadress   OUT VARCHAR2,
                                    p_osuser     OUT VARCHAR2);

    --YAP 20070912 обертка для DBMS_OBFUSCATION_TOOLKIT.md5
    FUNCTION MD5 (p_instring VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION GetOpfuParam (p_optp_code IN VARCHAR2, p_orgp_org IN NUMBER)
        RETURN VARCHAR2;
END ikis_common;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_COMMON FOR IKIS_SYS.IKIS_COMMON
/


GRANT EXECUTE ON IKIS_SYS.IKIS_COMMON TO II01RC_IKIS_COMMON
/

GRANT EXECUTE ON IKIS_SYS.IKIS_COMMON TO II01RC_IKIS_DESIGN
/

GRANT EXECUTE ON IKIS_SYS.IKIS_COMMON TO II01RC_IKIS_JOB
/

GRANT EXECUTE ON IKIS_SYS.IKIS_COMMON TO II01RC_IKIS_JOB_EXEC
/

GRANT EXECUTE ON IKIS_SYS.IKIS_COMMON TO II01RC_IKIS_REPL
/

GRANT EXECUTE ON IKIS_SYS.IKIS_COMMON TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_COMMON TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_COMMON TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_COMMON TO IKIS_SYSWEB WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_COMMON TO SYSTEM
/

GRANT EXECUTE ON IKIS_SYS.IKIS_COMMON TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_COMMON TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_COMMON TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_COMMON TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_COMMON TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_COMMON TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_COMMON TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_COMMON TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_COMMON TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:10:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.ikis_common
IS
    g_IKIS_OPFU                  VARCHAR2 (255) := NULL;
    g_IKIS_PFU_VERSION           VARCHAR2 (255) := NULL;
    g_IKIS_APPLEVEL              VARCHAR2 (255) := NULL;


    -- Messages for category: SUBSYS_UTIL
    msgUNKNOWN_SUBSYS_CODE       NUMBER := 3;
    msgSUBSYS_ALREDY_REG         NUMBER := 4;
    msgUNKNOWN_USER              NUMBER := 5;
    msgPREF_ALREADY_INST         NUMBER := 6;
    msgMAIN_SUBSYS_ABSENCE       NUMBER := 7;
    msgMAIN_SUBSYS_DOUBLE        NUMBER := 8;
    msgDOUBLE_SUBSYS_IN_SCHEMA   NUMBER := 9;
    msgUnkPref                   NUMBER := 496;

    -- Messages for category: COMMON
    msgUNIQUE_VIOLATION          NUMBER := 1;
    msgCOMMON_EXCEPTION          NUMBER := 2;
    msgAlreadyLocked             NUMBER := 77;
    msgDataChanged               NUMBER := 78;
    msgEstablish                 NUMBER := 79;
    msgGroupControlError         NUMBER := 97;
    msgProgramError              NUMBER := 117;
    msgFEATURENOTENABLED         NUMBER := 213;
    msgParamNotFound             NUMBER := 298;
    msgUnkAppParam               NUMBER := 517;
    msgChAppParam                NUMBER := 518;
    msgAccessViolation           NUMBER := 689;
    msgNoSelectedDocs            NUMBER := 817;
    msgCommitError               NUMBER := 820;
    msgGetSeqValError            NUMBER := 821;
    msgParamsViol                NUMBER := 861;


    PROCEDURE AnalyzeIkisSubSys (p_subsys ikis_subsys.ss_code%TYPE)
    IS
        l_owner    ikis_subsys.ss_code%TYPE;
        l_subsys   ikis_subsys.ss_code%TYPE;
    BEGIN
        debug.f ('Start procedure');
        l_subsys := RTRIM (p_subsys, 'X');
        ikis_file_job_pkg.savejobmessage (
            'I',
            'Початок збору статистики по ' || l_subsys);

        SELECT ikis_subsys.ss_owner
          INTO l_owner
          FROM ikis_subsys
         WHERE ikis_subsys.ss_code = l_subsys;

        --+http://talk.mail.ru/thread_article.html?ID=29123044
        EXECUTE IMMEDIATE 'alter session set NLS_TERRITORY = ''AMERICA''';

        --
        IF l_subsys = p_subsys
        THEN
            DBMS_STATS.GATHER_SCHEMA_STATS (ownname   => l_owner,
                                            cascade   => TRUE);
            ikis_file_job_pkg.savejobmessage (
                'I',
                'Завершення збору статистики по ' || l_subsys);
        ELSE
            DBMS_STATS.DELETE_SCHEMA_STATS (ownname         => l_owner,
                                            no_invalidate   => FALSE);
            ikis_file_job_pkg.savejobmessage (
                'I',
                'Завершення видалення статистики по ' || l_subsys);
        END IF;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgUNKNOWN_SUBSYS_CODE,
                                               p_subsys));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'ikis_common.AnalyzeIkisSubSys with ' || p_subsys,
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE AnalyzeIkisSubSysTable (p_subsys   ikis_subsys.ss_code%TYPE,
                                      p_table    VARCHAR2)
    IS
        l_owner   ikis_subsys.ss_code%TYPE;
    BEGIN
        debug.f ('Start procedure');
        ikis_file_job_pkg.savejobmessage (
            'I',
               'Початок збору статистики по таблиці'
            || p_subsys
            || '.'
            || p_table);

        SELECT ikis_subsys.ss_owner
          INTO l_owner
          FROM ikis_subsys
         WHERE ikis_subsys.ss_code = p_subsys;

        IF l_owner IS NULL
        THEN
            ikis_file_job_pkg.savejobmessage (
                'I',
                   'Завершення збору статистики по таблиці'
                || p_subsys
                || '.'
                || p_table
                || '. Відсутня зареєстрована подсистема.');
        ELSE
            --+http://talk.mail.ru/thread_article.html?ID=29123044
            EXECUTE IMMEDIATE 'alter session set NLS_TERRITORY = ''AMERICA''';

            --
            DBMS_STATS.GATHER_TABLE_STATS (ownname   => l_owner,
                                           tabname   => p_table,
                                           cascade   => TRUE);
            ikis_file_job_pkg.savejobmessage (
                'I',
                   'Завершення збору статистики по таблиці'
                || p_subsys
                || '.'
                || p_table);
        END IF;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgUNKNOWN_SUBSYS_CODE,
                                               p_subsys));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'ikis_common.AnalyzeIkisSubSys with ' || p_subsys,
                    CHR (10) || SQLERRM));
    END;

    FUNCTION GetApptParam (p_name         appt_params.aptprm_name%TYPE,
                           p_default   IN VARCHAR2 := NULL)
        RETURN appt_params.aptprm_value%TYPE
    IS
        l_res   appt_params.aptprm_value%TYPE;
    BEGIN
        debug.f ('Start procedure');

        SELECT aptprm_value
          INTO l_res
          FROM appt_params x
         WHERE UPPER (aptprm_name) = UPPER (p_name);

        debug.f ('Stop procedure');
        RETURN l_res;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            IF p_default IS NULL
            THEN
                raise_application_error (
                    -20000,
                    ikis_message_util.GET_MESSAGE (msgUnkAppParam, p_name));
            ELSE
                RETURN p_default;
            END IF;
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'ikis_common.GetApptParam',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE PGetApptParam (p_name        appt_params.aptprm_name%TYPE,
                             p_value   OUT appt_params.aptprm_value%TYPE)
    IS
    BEGIN
        p_value := GetApptParam (p_name);
    END;

    PROCEDURE Get_Script (p_code         ikis_scripts.isc_code%TYPE,
                          p_scr_p1   OUT ikis_scripts.isc_query%TYPE,
                          p_scr_p2   OUT ikis_scripts.isc_where%TYPE)
    IS
    BEGIN
        debug.f ('Start procedure');

        SELECT x.isc_query, x.isc_where
          INTO p_scr_p1, p_scr_p2
          FROM ikis_scripts x
         WHERE UPPER (x.isc_code) = UPPER (p_code);

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            NULL;
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'ikis_common.Get_Script',
                    SQLERRM));
    END;

    FUNCTION SecToFullTime (p_sec NUMBER)
        RETURN VARCHAR2
    IS
        l_hour   INTEGER;
        l_min    INTEGER;
        l_sec    INTEGER;
        l_res    VARCHAR2 (100);
        l_psec   NUMBER;
    BEGIN
        l_psec := ROUND (p_sec);
        l_res := '';
        l_hour := TRUNC (l_psec / 3600);
        l_min := TRUNC ((l_psec - l_hour * 3600) / 60);
        l_sec := (l_psec - l_hour * 3600 - l_min * 60);

        IF l_hour > 0
        THEN
            l_res := l_res || l_hour || ' год. ';
        END IF;

        IF l_min > 0
        THEN
            l_res := l_res || l_min || ' хв. ';
        END IF;

        IF l_sec > 0
        THEN
            l_res := l_res || l_sec || ' сек. ';
        END IF;

        RETURN l_res;
    END;

    FUNCTION GetAP_IKIS_OPFU
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN g_IKIS_OPFU;
    END;

    --yura_a 20070605 SPOV внедрение
    FUNCTION GetAP_IKIS_PFU_VERSION (p_recipient VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
    BEGIN
        /*  if p_recipient is null then
            return g_IKIS_PFU_VERSION;
          elsif p_recipient='REPLICATOR' then
            return '1.5.3.2';  --первая пилотная версия икис-спов без обмена с центром.
          elsif p_recipient='IKISDBTOOLS' then
            return g_IKIS_PFU_VERSION;  --!!!
          else
            return 'Invalid parameter value <'||p_recipient||'>';
          end if;*/
        --+YAP 20071019 для версии ИКИС 1,5,3,11 (здесь обновляется скопом все подсистемы)
        IF p_recipient IS NULL
        THEN
            RETURN g_IKIS_PFU_VERSION;
        ELSIF p_recipient = 'REPLICATOR'
        THEN
            RETURN g_IKIS_PFU_VERSION;
        ELSIF p_recipient = 'IKISDBTOOLS'
        THEN
            RETURN g_IKIS_PFU_VERSION;                                   --!!!
        ELSE
            RETURN 'Invalid parameter value <' || p_recipient || '>';
        END IF;
    END;

    FUNCTION GetAP_IKIS_APPLEVEL
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN g_IKIS_APPLEVEL;
    END;


    FUNCTION GetNodeDiapLow (p_node VARCHAR2)
        RETURN NUMBER
    IS
        l_pref   opfu_param.orgp_value%TYPE;
    BEGIN
        debug.f ('Start procedure');

        SELECT orgp_value
          INTO l_pref
          FROM opfu_param, opfu_param_tp
         WHERE     orgp_optp = optp_id
               AND optp_code = 'DIAP_PRFX'
               AND opfu_param.orgp_org = p_node;

        debug.f ('Stop procedure');
        RETURN l_pref * dserials.dimension;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    FUNCTION GetNodeDiapHi (p_node VARCHAR2)
        RETURN NUMBER
    IS
        l_pref   opfu_param.orgp_value%TYPE;
    BEGIN
        debug.f ('Start procedure');

        SELECT orgp_value
          INTO l_pref
          FROM opfu_param, opfu_param_tp
         WHERE     orgp_optp = optp_id
               AND optp_code = 'DIAP_PRFX'
               AND opfu_param.orgp_org = p_node;

        debug.f ('Stop procedure');
        RETURN (l_pref + 1) * dserials.dimension;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    PROCEDURE comma_to_table (p_lst         VARCHAR2,
                              p_cnt     OUT INTEGER,
                              p_table   OUT TCommaTable)
    IS
        l_occurr     INTEGER := 1;
        l_pos        INTEGER := 1;
        l_pos_prev   INTEGER := 1;
        l_delm       VARCHAR2 (1) := ',';
        l_lst        VARCHAR2 (32760);
    BEGIN
        debug.f ('Start procedure');
        --  p_table:=TCommaTable('');
        l_lst := p_lst || l_delm;

        LOOP
            l_pos :=
                INSTR (l_lst,
                       l_delm,
                       1,
                       l_occurr);
            EXIT WHEN l_pos = 0;
            --    p_table.extend(1);
            p_table (l_occurr) :=
                SUBSTR (l_lst, l_pos_prev, l_pos - l_pos_prev);
            l_occurr := l_occurr + 1;
            l_pos_prev := l_pos + 1;
        END LOOP;

        p_cnt := l_occurr - 1;
        debug.f ('Stop procedure');
    END;

    PROCEDURE Get_OthRptPar_Ses (p_par_ses_id OUT NUMBER)
    IS
    BEGIN
        SELECT SQ_OTH_RPT_PAR_SES.NEXTVAL INTO p_par_ses_id FROM DUAL;
    END;

    PROCEDURE Ins_RptParam (
        p_par_ses_id   IN ikis_rpt_par_lst.rps_id%TYPE,
        p_par_value    IN ikis_rpt_par_lst.rps_value%TYPE)
    IS
    BEGIN
        debug.f ('Start procedure');

        INSERT INTO IKIS_RPT_PAR_LST (rps_id, rps_value)
             VALUES (p_par_ses_id, p_par_value);

        debug.f ('Stop procedure');
    END;

    PROCEDURE CheckIntegrityParams
    IS
        l_cnt          INTEGER;
        exParamsViol   EXCEPTION;
    BEGIN
        --+ Автор: YURA_A 27.02.2004 14:17:50
        --  Описание: Включение сеанса трассировки
        debug.init;
        --- Автор: YURA_A 27.02.2004 14:17:52
        debug.f ('Start procedure');


        debug.f ('Check checksum of parameters');

        SELECT COUNT (1)
          INTO l_cnt
          FROM appt_params
         WHERE     appt_params.aptprm_name = 'IKIS_SYS_CHS'
               AND appt_params.aptprm_value = ikis_params.getchecksum;

        IF l_cnt = 0
        THEN
            debug.f ('Invalid checksum');
            RAISE exParamsViol;
        END IF;

        --Проверка целостности контрольных параметров репликатора
        ikis_obmf.compare;

        IF NOT (TRIM (GetApptParam ('IKIS_APPLICATION_CODE', 'UNKNOWN')) =
                'ATLAS SPO')
        THEN
            ikis_activate.checknodeinfo;
        END IF;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN exParamsViol
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgParamsViol));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'ikis_common.CheckIntegrityParams',
                    SQLERRM));
    END;

    PROCEDURE Get_CurrUserProps (
        p_iusr_id         OUT ikis_users_attr.iusr_id%TYPE,
        p_iusr_name       OUT ikis_users_attr.iusr_name%TYPE,
        p_iusr_numident   OUT ikis_users_attr.iusr_numident%TYPE,
        p_iusr_comp       OUT ikis_users_attr.iusr_comp%TYPE,
        p_iusr_login      OUT ikis_users_attr.iusr_login%TYPE)
    IS
    BEGIN
        debug.f ('Start procedure');

        SELECT iusr_id,
               iusr_name,
               iusr_numident,
               iusr_comp,
               iusr_login
          INTO p_iusr_id,
               p_iusr_name,
               p_iusr_numident,
               p_iusr_comp,
               p_iusr_login
          FROM ikis_users_attr
         WHERE iusr_id = UID AND iusr_org = GetAP_IKIS_OPFU;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'ikis_common.Get_CurrUserProps',
                    SQLERRM));
    END;

    FUNCTION IsRoleGrantedToUser (p_user       VARCHAR2,
                                  p_irl_name   ikis_role.irl_name%TYPE)
        RETURN NUMBER
    IS
        l_cnt   INTEGER;
    BEGIN
        SELECT COUNT (*)
          INTO l_cnt
          FROM v_all_ikis_granted_role
         WHERE igr_userid = p_user AND igr_name = p_irl_name;

        IF l_cnt > 1
        THEN
            l_cnt := 1;
        END IF;

        RETURN l_cnt;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'RDM$IKIS_USERS.IsRoleGrantedToUser with ',
                    CHR (10) || SQLERRM));
    END;

    ----------------------------------------
    -- YURA_A 07.10.2003 11:17:18
    ----------------------------------------
    -- Назначение : Очистка протоколов
    -- Параметры  : p_option - тип очистки
    -- 0 - все
    -- 1 - то что устарело на 3 месяцa
    PROCEDURE ClearProtocol (p_option INTEGER)
    IS
        c_full       CONSTANT INTEGER := 0;
        c_OldMonth   CONSTANT INTEGER := 1;
        c_interval            INTEGER := 3 * 31;
    BEGIN
        debug.f ('Start procedure');
        --Yura_AP 17-11-2003 временно, до уточнения постановки
        raise_application_error (
            -20000,
            ikis_message_util.GET_MESSAGE (msgFEATURENOTENABLED));
        --Очистка протокола ikis_protocol
        ikis_file_job_pkg.savejobmessage (ikis_const.V_DDS_MESSAGE_TP_I,
                                          'Початок очищення');

        CASE p_option
            WHEN c_full
            THEN
                BEGIN
                    ikis_file_job_pkg.savejobmessage (
                        ikis_const.V_DDS_MESSAGE_TP_I,
                        'Повне очищення протоколів ІКІС');

                    DELETE FROM ikis_protocol;

                    ikis_file_job_pkg.savejobmessage (
                        ikis_const.V_DDS_MESSAGE_TP_I,
                        'Видалено ' || SQL%ROWCOUNT || ' записів');
                END;
            WHEN c_OldMonth
            THEN
                BEGIN
                    ikis_file_job_pkg.savejobmessage (
                        ikis_const.V_DDS_MESSAGE_TP_I,
                        'Очищення протоколів ІКІС що встаріли на 3 місяця');

                    DELETE FROM ikis_protocol
                          WHERE ikis_protocol.prot_datetime <
                                (SYSDATE - c_interval);

                    ikis_file_job_pkg.savejobmessage (
                        ikis_const.V_DDS_MESSAGE_TP_I,
                        'Видалено ' || SQL%ROWCOUNT || ' записів');
                END;
            ELSE
                NULL;
        END CASE;

        --Очистка протокола file_job_exception
        CASE p_option
            WHEN c_full
            THEN
                BEGIN
                    ikis_file_job_pkg.savejobmessage (
                        ikis_const.V_DDS_MESSAGE_TP_I,
                        'Повне очищення протоколів завданнь');

                    DELETE FROM file_job_exception
                          WHERE fje_fj IN
                                    (SELECT fj_id
                                       FROM file_job
                                      WHERE fj_st IN
                                                (ikis_const.v_dds_job_st_errorexec,
                                                 ikis_const.v_dds_job_st_complite,
                                                 ikis_const.v_dds_job_st_removed));

                    DELETE FROM file_par_value
                          WHERE ftpv_fj IN
                                    (SELECT fj_id
                                       FROM file_job
                                      WHERE fj_st IN
                                                (ikis_const.v_dds_job_st_errorexec,
                                                 ikis_const.v_dds_job_st_complite,
                                                 ikis_const.v_dds_job_st_removed));

                    DELETE FROM file_job
                          WHERE fj_st IN
                                    (ikis_const.v_dds_job_st_errorexec,
                                     ikis_const.v_dds_job_st_complite,
                                     ikis_const.v_dds_job_st_removed);

                    ikis_file_job_pkg.savejobmessage (
                        ikis_const.V_DDS_MESSAGE_TP_I,
                        'Видалено ' || SQL%ROWCOUNT || ' записів');
                END;
            WHEN c_OldMonth
            THEN
                BEGIN
                    ikis_file_job_pkg.savejobmessage (
                        ikis_const.V_DDS_MESSAGE_TP_I,
                        'Очищення протоколів завданнь що встаріли на 3 місяця');

                    DELETE FROM file_job_exception
                          WHERE fje_fj IN
                                    (SELECT fj_id
                                       FROM file_job
                                      WHERE     fj_stop_dt <
                                                (SYSDATE - c_interval)
                                            AND fj_st IN
                                                    (ikis_const.v_dds_job_st_errorexec,
                                                     ikis_const.v_dds_job_st_complite,
                                                     ikis_const.v_dds_job_st_removed));

                    DELETE FROM file_par_value
                          WHERE ftpv_fj IN
                                    (SELECT fj_id
                                       FROM file_job
                                      WHERE     fj_stop_dt <
                                                (SYSDATE - c_interval)
                                            AND fj_st IN
                                                    (ikis_const.v_dds_job_st_errorexec,
                                                     ikis_const.v_dds_job_st_complite,
                                                     ikis_const.v_dds_job_st_removed));

                    DELETE FROM file_job
                          WHERE     fj_stop_dt < (SYSDATE - c_interval)
                                AND fj_st IN
                                        (ikis_const.v_dds_job_st_errorexec,
                                         ikis_const.v_dds_job_st_complite,
                                         ikis_const.v_dds_job_st_removed);

                    ikis_file_job_pkg.savejobmessage (
                        ikis_const.V_DDS_MESSAGE_TP_I,
                        'Видалено ' || SQL%ROWCOUNT || ' записів');
                END;
            ELSE
                NULL;
        END CASE;

        --Очистка протокола ikis_exception_log
        CASE p_option
            WHEN c_full
            THEN
                BEGIN
                    NULL;
                END;
            WHEN c_OldMonth
            THEN
                BEGIN
                    NULL;
                END;
            ELSE
                NULL;
        END CASE;

        COMMIT;
        ikis_file_job_pkg.savejobmessage (ikis_const.V_DDS_MESSAGE_TP_I,
                                          'Очищення завершено');
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'ikis_common.ClearProtocol',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE CompareTables (p_owner1      VARCHAR2,
                             p_tablelst1   VARCHAR2,
                             p_owner2      VARCHAR2,
                             p_tablelst2   VARCHAR2)
    IS
        CURSOR c_cols_nm (p_owner1   VARCHAR2,
                          p_table1   VARCHAR2,
                          p_owner2   VARCHAR2,
                          p_table2   VARCHAR2)
        IS
            SELECT column_name,
                   data_type,
                   data_length,
                   data_precision,
                   data_scale,
                   nullable
              FROM (SELECT x.column_name,
                           x.data_type,
                           x.data_length,
                           x.data_precision,
                           x.data_scale,
                           x.nullable
                      FROM dba_tab_columns x
                     WHERE x.owner = p_owner1 AND x.table_name = p_table1
                    MINUS
                    SELECT x.column_name,
                           x.data_type,
                           x.data_length,
                           x.data_precision,
                           x.data_scale,
                           x.nullable
                      FROM dba_tab_columns x
                     WHERE x.owner = p_owner2 AND x.table_name = p_table2);

        r_cols_nm          c_cols_nm%ROWTYPE;
        par_table1         DBMS_UTILITY.Uncl_Array;
        cnt1               BINARY_INTEGER;
        l_tcnt1            INTEGER;
        par_table2         DBMS_UTILITY.Uncl_Array;
        cnt2               BINARY_INTEGER;
        l_tcnt2            INTEGER;
        l_column_name      VARCHAR2 (30);
        l_data_type        VARCHAR2 (106);
        l_data_length      NUMBER;
        l_data_precision   NUMBER;
        l_data_scale       NUMBER;
        l_nullable         VARCHAR2 (1);

        FUNCTION ldecode (p1   VARCHAR2,
                          p2   VARCHAR2,
                          p3   VARCHAR2,
                          p4   VARCHAR2)
            RETURN VARCHAR2
        IS
        BEGIN
            IF p1 = p2
            THEN
                RETURN p3;
            ELSE
                RETURN p4;
            END IF;
        END;
    BEGIN
        DBMS_UTILITY.COMMA_TO_TABLE (p_tablelst1, cnt1, par_table1);
        DBMS_UTILITY.COMMA_TO_TABLE (p_tablelst2, cnt2, par_table2);

        IF cnt1 <> cnt2
        THEN
            raise_application_error (
                -20000,
                   'Count of tables don''t equal ('
                || cnt1
                || ' and '
                || cnt2
                || ')');
        END IF;

        DBMS_OUTPUT.put_line (
            'Compare tables for owners: ' || p_owner1 || ' and ' || p_owner2);

        FOR i IN 1 .. cnt1
        LOOP
            DBMS_OUTPUT.put_line (RPAD ('*', 120, '*'));
            par_table1 (i) := TRIM (BOTH '"' FROM par_table1 (i));
            par_table2 (i) := TRIM (BOTH '"' FROM par_table2 (i));

            --Поиск таблицы в схеме 1
            SELECT COUNT (*)
              INTO l_tcnt1
              FROM dba_tables
             WHERE owner = p_owner1 AND table_name = par_table1 (i);

            IF l_tcnt1 = 1
            THEN
                DBMS_OUTPUT.put_line (
                       'Found table1 '
                    || par_table1 (i)
                    || ' for owner1 '
                    || p_owner1);

                --Поиск таблицы в схеме 2
                SELECT COUNT (*)
                  INTO l_tcnt2
                  FROM dba_tables
                 WHERE owner = p_owner2 AND table_name = par_table2 (i);

                IF l_tcnt2 = 1
                THEN
                    DBMS_OUTPUT.put_line (
                           'Found table2 '
                        || par_table2 (i)
                        || ' for owner2 '
                        || p_owner2);
                    DBMS_OUTPUT.put_line (RPAD ('*', 120, '*'));
                    DBMS_OUTPUT.put_line (
                           RPAD ('table_name', 17, ' ')
                        || RPAD ('column_name', 17, ' ')
                        || RPAD ('data_type', 17, ' ')
                        || RPAD ('data_length', 17, ' ')
                        || RPAD ('data_precision', 17, ' ')
                        || RPAD ('data_scale', 17, ' ')
                        || RPAD ('nullable', 17, ' '));
                    DBMS_OUTPUT.put_line (RPAD ('*', 120, '*'));

                    OPEN c_cols_nm (p_owner1,
                                    par_table1 (i),
                                    p_owner2,
                                    par_table2 (i));

                    LOOP
                        FETCH c_cols_nm INTO r_cols_nm;

                        EXIT WHEN c_cols_nm%NOTFOUND;

                        --          dbms_output.put_line('For table1 '||par_table1(i)||' of owner1 '||p_owner1);
                        BEGIN
                            SELECT x.column_name,
                                   x.data_type,
                                   x.data_length,
                                   x.data_precision,
                                   x.data_scale,
                                   x.nullable
                              INTO l_column_name,
                                   l_data_type,
                                   l_data_length,
                                   l_data_precision,
                                   l_data_scale,
                                   l_nullable
                              FROM dba_tab_columns x
                             WHERE     x.owner = p_owner2
                                   AND x.table_name = par_table2 (i)
                                   AND x.column_name = r_cols_nm.column_name;
                        EXCEPTION
                            WHEN NO_DATA_FOUND
                            THEN
                                raise_application_error (
                                    -20000,
                                       'Table 1: '
                                    || par_table1 (i)
                                    || ' and table 2: '
                                    || par_table2 (i)
                                    || ' not same');
                            WHEN OTHERS
                            THEN
                                RAISE;
                        END;

                        DBMS_OUTPUT.put_line (
                               RPAD (par_table1 (i), 17, ' ')
                            || RPAD (r_cols_nm.column_name, 17, ' ')
                            || RPAD (ldecode (r_cols_nm.data_type,
                                              l_data_type,
                                              'OK',
                                              r_cols_nm.data_type),
                                     17,
                                     ' ')
                            || RPAD (ldecode (r_cols_nm.data_length,
                                              l_data_length,
                                              'OK',
                                              r_cols_nm.data_length),
                                     17,
                                     ' ')
                            || RPAD (NVL (ldecode (r_cols_nm.data_precision,
                                                   l_data_precision,
                                                   'OK',
                                                   r_cols_nm.data_precision),
                                          '-'),
                                     17,
                                     ' ')
                            || RPAD (NVL (ldecode (r_cols_nm.data_scale,
                                                   l_data_scale,
                                                   'OK',
                                                   r_cols_nm.data_scale),
                                          '-'),
                                     17,
                                     ' ')
                            || RPAD (ldecode (r_cols_nm.nullable,
                                              l_nullable,
                                              'OK',
                                              r_cols_nm.nullable),
                                     17,
                                     ' '));
                        DBMS_OUTPUT.put_line (
                               RPAD (par_table2 (i), 17, ' ')
                            || RPAD (l_column_name, 17, ' ')
                            || RPAD (ldecode (l_data_type,
                                              r_cols_nm.data_type,
                                              'OK',
                                              l_data_type),
                                     17,
                                     ' ')
                            || RPAD (ldecode (l_data_length,
                                              r_cols_nm.data_length,
                                              'OK',
                                              l_data_length),
                                     17,
                                     ' ')
                            || RPAD (NVL (ldecode (l_data_precision,
                                                   r_cols_nm.data_precision,
                                                   'OK',
                                                   l_data_precision),
                                          '-'),
                                     17,
                                     ' ')
                            || RPAD (NVL (ldecode (l_data_scale,
                                                   r_cols_nm.data_scale,
                                                   'OK',
                                                   l_data_scale),
                                          '-'),
                                     17,
                                     ' ')
                            || RPAD (ldecode (l_nullable,
                                              r_cols_nm.nullable,
                                              'OK',
                                              l_nullable),
                                     17,
                                     ' '));
                        DBMS_OUTPUT.put_line (RPAD ('-', 120, '-'));
                    END LOOP;

                    CLOSE c_cols_nm;
                ELSE
                    DBMS_OUTPUT.put_line (
                           'Not found table2 '
                        || par_table2 (i)
                        || ' for owner2 '
                        || p_owner2);
                END IF;
            ELSE
                DBMS_OUTPUT.put_line (
                       'Not found table1 '
                    || par_table1 (i)
                    || ' for owner1 '
                    || p_owner1);
            END IF;
        END LOOP;

        DBMS_OUTPUT.put_line ('Compare tables complete');
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'ikis_common.CompareTables',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE GetStatusBar (p_section NUMBER, p_msg OUT VARCHAR2)
    IS
    BEGIN
        debug.f ('Start procedure');

        CASE p_section
            WHEN 1
            THEN
                p_msg := LPAD (ikis_common.getap_ikis_opfu, 5, '0');
            WHEN 2
            THEN
                SELECT v_opfu.org_name
                  INTO p_msg
                  FROM v_opfu
                 WHERE v_opfu.org_id = ikis_common.getap_ikis_opfu;
            WHEN 3
            THEN
                BEGIN
                    SELECT iu_numident
                      INTO p_msg
                      FROM v_ikis_users
                     WHERE iu_oraid = UID;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        NULL;
                    WHEN OTHERS
                    THEN
                        RAISE;
                END;
            WHEN 4
            THEN
                BEGIN
                    SELECT iu_name
                      INTO p_msg
                      FROM v_ikis_users
                     WHERE iu_oraid = UID;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        NULL;
                    WHEN OTHERS
                    THEN
                        RAISE;
                END;
            WHEN 5
            THEN
                DECLARE
                    l_code   VARCHAR2 (100);
                BEGIN
                    EXECUTE IMMEDIATE 'begin :a1:=ikis_ers.fga$utils.GetCurrentSubSysCode; end;'
                        USING OUT l_code;

                    CASE l_code      --ikis_ers.fga$utils.GetCurrentSubSysCode
                        WHEN 'IKIS_SPOV'
                        THEN
                            p_msg :=
                                   'ІКІС СПОВ '
                                || ikis_common.GetApptParam (
                                       p_name   => 'IKIS_SPOV_VER');
                        WHEN 'IKIS_ERS'
                        THEN
                            p_msg :=
                                   'ІКІС ЄРС '
                                || ikis_common.GetApptParam (
                                       p_name   => 'IKIS_ERS_VER');
                        ELSE
                            p_msg := NULL;
                    END CASE;
                END;
            ELSE
                NULL;
        END CASE;

        debug.f ('Stop procedure');
    END;

    PROCEDURE SetTraceOn
    IS
    BEGIN
        debug.f ('Start procedure');
        --execute immediate 'alter session set timed_statistics=true';
        --execute immediate 'alter session set events ''10046 trace name context forever, level 12''';
        DBMS_APPLICATION_INFO.SET_ACTION ('TRC' || USERENV ('TERMINAL'));

        EXECUTE IMMEDIATE 'alter session set events ''10046 trace name context forever, level 12''';

        --  execute immediate 'alter session set sql_trace=true';
        debug.f ('Stop procedure');
    END;

    PROCEDURE SetTraceOnRegKey (p_devs_sub_sys_lst VARCHAR2)
    IS
        par_table   ikis_common.tcommatable;
        cnt         INTEGER;
    BEGIN
        debug.f ('Start procedure: %s',
                 REPLACE (p_devs_sub_sys_lst, '|', ','));
        ikis_common.comma_to_table (p_devs_sub_sys_lst, cnt, par_table);

        FOR i IN 1 .. cnt
        LOOP
            IF par_table (i) = '1001' OR par_table (i) = '1002'
            THEN
                SetTraceOn;
            END IF;
        END LOOP;

        debug.f ('Stop procedure');
    END;

    PROCEDURE SetTraceOff
    IS
    BEGIN
        debug.f ('Start procedure');

        --execute immediate 'alter session set timed_statistics=false';
        EXECUTE IMMEDIATE 'alter session set events ''10046 trace name context off''';

        --  execute immediate 'alter session set sql_trace=false';
        debug.f ('Stop procedure');
    END;

    PROCEDURE SetStatOnTable (p_ss_code   ikis_subsys.ss_code%TYPE,
                              p_tabname   VARCHAR2,
                              p_numrows   NUMBER,
                              p_numblks   NUMBER,
                              p_avgrlen   NUMBER)
    IS
        l_attr   ikis_subsys%ROWTYPE;
    BEGIN
        debug.f ('Start procedure');
        ikis_subsys_util.get_subsys_attr (p_ss_code, l_attr);
        -- Test statements here
        DBMS_STATS.set_table_stats (ownname   => UPPER (l_attr.ss_owner),
                                    tabname   => UPPER (p_tabname),
                                    numrows   => p_numrows,
                                    numblks   => p_numblks,
                                    avgrlen   => p_avgrlen);
        debug.f ('Stop procedure');
    END;

    PROCEDURE GetCurrenUserSysAttr (p_sesid      OUT NUMBER,
                                    p_sesuid     OUT NUMBER,
                                    p_sesusr     OUT VARCHAR2,
                                    p_host       OUT VARCHAR2,
                                    p_ipadress   OUT VARCHAR2,
                                    p_osuser     OUT VARCHAR2)
    IS
    BEGIN
        p_sesid := SYS_CONTEXT ('USERENV', 'SESSIONID');
        p_sesuid := SYS_CONTEXT ('USERENV', 'SESSION_USERID');
        p_sesusr := SYS_CONTEXT ('USERENV', 'SESSION_USER');
        p_host := SYS_CONTEXT ('USERENV', 'HOST');
        p_ipadress := SYS_CONTEXT ('USERENV', 'IP_ADDRESS');
        p_osuser := SYS_CONTEXT ('USERENV', 'OS_USER');
    END;

    FUNCTION MD5 (p_instring VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN DBMS_OBFUSCATION_TOOLKIT.md5 (input_string => p_instring);
    END;

    FUNCTION GetOpfuParam (p_optp_code IN VARCHAR2, p_orgp_org IN NUMBER)
        RETURN VARCHAR2
    IS
        l_result   opfu_param.ORGP_VALUE%TYPE;
    BEGIN
        SELECT MAX (p.ORGP_VALUE)
          INTO l_result
          FROM opfu_param  p
               JOIN opfu_param_tp t
                   ON p.ORGP_OPTP = t.OPTP_ID AND t.OPTP_CODE = p_optp_code
         WHERE p.ORGP_ORG = p_orgp_org AND p.ORGP_ST = 'A';

        RETURN l_result;
    END;
BEGIN
    debug.f ('Start procedure (initializion)');
    g_IKIS_OPFU := GetApptParam ('IKIS_OPFU');
    g_IKIS_PFU_VERSION := GetApptParam ('IKIS_PFU_VERSION');
    g_IKIS_APPLEVEL := GetApptParam ('IKIS_APPLEVEL');
    debug.f ('Stop procedure (initializion)');
END ikis_common;
/