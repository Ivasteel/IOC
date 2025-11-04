/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_MESSAGE_UTIL
IS
    -- Author  : YURA_A
    -- Created : 04.07.2003 9:53:07
    -- Purpose : Работа с сообщениями системы

    TYPE TRefCursor IS REF CURSOR;


    -- Messages for category: COMMON
    msgUNIQUE_VIOLATION   CONSTANT NUMBER := 1;
    msgCOMMON_EXCEPTION   CONSTANT NUMBER := 2;

    --Добавить категорию
    PROCEDURE Add_Category (p_category ikis_messcat.imc_name%TYPE);

    --Добавить сообщение для выбраной подсистемы и категории
    PROCEDURE Add_Message (
        p_ss_code         ikis_messages.ipm_ss_code%TYPE, -- код подсистемы см ikis_subsys
        p_tp              ikis_messages.ipm_tp%TYPE, -- тип сообщения E,W,I ошибка, предупреждение, информация
        p_message         ikis_messages.ipm_message%TYPE,         -- сообщение
        p_cause           ikis_messages.ipm_cause%TYPE, -- причина происшедшего
        p_action          ikis_messages.ipm_action%TYPE,         -- что делать
        p_category        ikis_messages.ipm_category%TYPE,        -- категория
        p_constname       ikis_messages.ipm_constname%TYPE,   -- имя константы
        p_id          OUT ikis_messages.ipm_id%TYPE);

    --Редактировать сообщение
    PROCEDURE Edit_Message (p_ss_code     ikis_messages.ipm_ss_code%TYPE,
                            p_tp          ikis_messages.ipm_tp%TYPE,
                            p_message     ikis_messages.ipm_message%TYPE,
                            p_cause       ikis_messages.ipm_cause%TYPE,
                            p_action      ikis_messages.ipm_action%TYPE,
                            p_category    ikis_messages.ipm_category%TYPE,
                            p_constname   ikis_messages.ipm_constname%TYPE, -- имя константы
                            p_id          ikis_messages.ipm_id%TYPE);

    --Получить сообщение
    FUNCTION GET_MESSAGE (p_id     ikis_messages.ipm_id%TYPE,
                          p_par1   VARCHAR2 DEFAULT NULL,
                          p_par2   VARCHAR2 DEFAULT NULL,
                          p_par3   VARCHAR2 DEFAULT NULL,
                          p_par4   VARCHAR2 DEFAULT NULL,
                          p_par5   VARCHAR2 DEFAULT NULL,
                          p_par6   VARCHAR2 DEFAULT NULL,
                          p_par7   VARCHAR2 DEFAULT NULL,
                          p_par8   VARCHAR2 DEFAULT NULL,
                          p_par9   VARCHAR2 DEFAULT NULL,
                          p_par0   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;

    --Получить сообщение (процедура на клиенте работает стабильнее)
    PROCEDURE PGet_Message (p_id              ikis_messages.ipm_id%TYPE,
                            p_message     OUT VARCHAR2,
                            p_type        OUT VARCHAR2,
                            p_type_name   OUT VARCHAR2,
                            p_par1            VARCHAR2 DEFAULT NULL,
                            p_par2            VARCHAR2 DEFAULT NULL,
                            p_par3            VARCHAR2 DEFAULT NULL,
                            p_par4            VARCHAR2 DEFAULT NULL,
                            p_par5            VARCHAR2 DEFAULT NULL,
                            p_par6            VARCHAR2 DEFAULT NULL,
                            p_par7            VARCHAR2 DEFAULT NULL,
                            p_par8            VARCHAR2 DEFAULT NULL,
                            p_par9            VARCHAR2 DEFAULT NULL,
                            p_par0            VARCHAR2 DEFAULT NULL);

    --Получить все сообщения
    PROCEDURE Get_Messages (p_messages OUT TRefCursor);

    PROCEDURE GetConstForCategory (
        p_category       ikis_messages.ipm_category%TYPE,          --категория
        p_type           INTEGER,      -- тип исходников 1-PL/SQl или 2-Delphi
        p_src        OUT CLOB);                         --текст блока констант
END IKIS_MESSAGE_UTIL;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_MESSAGE_UTIL FOR IKIS_SYS.IKIS_MESSAGE_UTIL
/


GRANT EXECUTE ON IKIS_SYS.IKIS_MESSAGE_UTIL TO II01RC_IKIS_COMMON
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSAGE_UTIL TO II01RC_IKIS_DESIGN
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSAGE_UTIL TO II01RC_IKIS_JOB_EXEC
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSAGE_UTIL TO II01RC_IKIS_REPL
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSAGE_UTIL TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSAGE_UTIL TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSAGE_UTIL TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSAGE_UTIL TO IKIS_SYSWEB WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSAGE_UTIL TO SYSTEM
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSAGE_UTIL TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSAGE_UTIL TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSAGE_UTIL TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSAGE_UTIL TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSAGE_UTIL TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSAGE_UTIL TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSAGE_UTIL TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSAGE_UTIL TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_MESSAGE_UTIL TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:10:03 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_MESSAGE_UTIL
IS
    msgFinalResError       NUMBER := 574;
    msgFinalError          NUMBER := 575;
    msgGroupExecError      NUMBER := 576;
    msgFillMatrisSQL       NUMBER := 877;
    msgGroupControlError   NUMBER := 97;
    msgProgramError        NUMBER := 117;
    msgDDLError            NUMBER := 1854;

    UNIQUE_VIOLATION       EXCEPTION;
    PRAGMA EXCEPTION_INIT (UNIQUE_VIOLATION, -1);


    FUNCTION GET_MESSAGE (p_id     ikis_messages.ipm_id%TYPE,
                          p_par1   VARCHAR2 DEFAULT NULL,
                          p_par2   VARCHAR2 DEFAULT NULL,
                          p_par3   VARCHAR2 DEFAULT NULL,
                          p_par4   VARCHAR2 DEFAULT NULL,
                          p_par5   VARCHAR2 DEFAULT NULL,
                          p_par6   VARCHAR2 DEFAULT NULL,
                          p_par7   VARCHAR2 DEFAULT NULL,
                          p_par8   VARCHAR2 DEFAULT NULL,
                          p_par9   VARCHAR2 DEFAULT NULL,
                          p_par0   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
        --Ryaba
        --+
        PRAGMA AUTONOMOUS_TRANSACTION;
        --+
        l_message     ikis_messages.ipm_message%TYPE;
        l_id          NUMBER (6);
        l_code        NUMBER (6);
        l_debug_msg   VARCHAR2 (4000);
        l_dser        BOOLEAN;
    BEGIN
        --+yap 20071116
        l_dser := dserials.gd_idiap_enabled;
        dserials.gd_idiap_enabled := TRUE;

        SELECT ipm_message, ipm_id, ipm_ecode
          INTO l_message, l_id, l_code
          FROM ikis_messages
         WHERE ipm_id = p_id;

        l_message := GetMessageNum (l_id, l_code) || ': ' || l_message;

        --Ryaba
        --Запис у загальний протокол помилок повідомленнь про програмні помилки
        --+ begin
        IF    p_id = msgCOMMON_EXCEPTION
           OR --помилки у движку контролів
              p_id = msgCOMMON_EXCEPTION
           OR p_id = msgFinalResError
           OR p_id = msgFinalError
           OR p_id = msgGroupExecError
           OR p_id = msgFillMatrisSQL
           OR p_id = msgGroupControlError
           OR p_id = msgDDLError
        THEN
            INSERT INTO ikis_exception_log (iel_ipm,
                                            iel_paramvalue1,
                                            iel_paramvalue2,
                                            iel_paramvalue3,
                                            iel_paramvalue4,
                                            iel_paramvalue5,
                                            iel_paramvalue6,
                                            iel_paramvalue7,
                                            iel_paramvalue8)
                 VALUES (p_id,
                         SUBSTR (p_par1, 1, 4000),
                         SUBSTR (p_par2, 1, 4000),
                         SUBSTR (p_par3, 1, 4000),
                         SUBSTR (p_par4, 1, 4000),
                         SUBSTR (p_par5, 1, 4000),
                         SUBSTR (p_par6, 1, 4000),
                         SUBSTR (p_par7, 1, 4000),
                         SUBSTR (p_par8, 1, 4000));

            COMMIT;

            l_debug_msg :=
                SUBSTR (
                    REPLACE (
                        REPLACE (
                            REPLACE (
                                REPLACE (
                                    REPLACE (
                                        REPLACE (
                                            REPLACE (
                                                REPLACE (
                                                    REPLACE (
                                                        REPLACE (
                                                            REPLACE (
                                                                l_message,
                                                                '<P1>',
                                                                '%s'),
                                                            '<P2>',
                                                            '%s'),
                                                        '<P3>',
                                                        '%s'),
                                                    '<P4>',
                                                    '%s'),
                                                '<P5>',
                                                '%s'),
                                            '<P6>',
                                            '%s'),
                                        '<P7>',
                                        '%s'),
                                    '<P8>',
                                    '%s'),
                                '<P9>',
                                '%s'),
                            '<P10>',
                            '%s'),
                        'ORA-20000:'),
                    1,
                    4000);
            debug.f (l_debug_msg,
                     p_par1,
                     p_par2,
                     p_par3,
                     p_par4,
                     p_par5,
                     p_par6,
                     p_par7,
                     p_par8,
                     p_par9,
                     p_par0);
        END IF;

        --Ryaba
        --+ end
        RETURN SUBSTR (
                   REPLACE (
                       REPLACE (
                           REPLACE (
                               REPLACE (
                                   REPLACE (
                                       REPLACE (
                                           REPLACE (
                                               REPLACE (
                                                   REPLACE (
                                                       REPLACE (
                                                           REPLACE (
                                                               l_message,
                                                               '<P1>',
                                                               p_par1),
                                                           '<P2>',
                                                           p_par2),
                                                       '<P3>',
                                                       p_par3),
                                                   '<P4>',
                                                   p_par4),
                                               '<P5>',
                                               p_par5),
                                           '<P6>',
                                           p_par6),
                                       '<P7>',
                                       p_par7),
                                   '<P8>',
                                   p_par8),
                               '<P9>',
                               p_par9),
                           '<P10>',
                           p_par0),
                       'ORA-20000:'),
                   1,
                   4000);
        dserials.gd_idiap_enabled := l_dser;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            dserials.gd_idiap_enabled := l_dser;
            raise_application_error (
                -20000,
                'DEBUG:<Get_Message>:Невідомий код повідомлення: ' || p_id);
    END;

    PROCEDURE PGet_Message (p_id              ikis_messages.ipm_id%TYPE,
                            p_message     OUT VARCHAR2,
                            p_type        OUT VARCHAR2,
                            p_type_name   OUT VARCHAR2,
                            p_par1            VARCHAR2 DEFAULT NULL,
                            p_par2            VARCHAR2 DEFAULT NULL,
                            p_par3            VARCHAR2 DEFAULT NULL,
                            p_par4            VARCHAR2 DEFAULT NULL,
                            p_par5            VARCHAR2 DEFAULT NULL,
                            p_par6            VARCHAR2 DEFAULT NULL,
                            p_par7            VARCHAR2 DEFAULT NULL,
                            p_par8            VARCHAR2 DEFAULT NULL,
                            p_par9            VARCHAR2 DEFAULT NULL,
                            p_par0            VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        p_message :=
            GET_MESSAGE (p_id,
                         p_par1,
                         p_par2,
                         p_par3,
                         p_par4,
                         p_par5,
                         p_par6,
                         p_par7,
                         p_par8,
                         p_par9,
                         p_par0);

        SELECT b.dic_value, b.dic_sname
          INTO p_type, p_type_name
          FROM ikis_messages a, v_dds_message_tp b
         WHERE a.ipm_tp = b.dic_value AND a.ipm_id = p_id;
    END;

    PROCEDURE Add_Category (p_category ikis_messcat.imc_name%TYPE)
    IS
    BEGIN
        raise_application_error (
            -20000,
            'Додавання категорій тимчасово заблоковано. Зверніться до головного програміста.');

        INSERT INTO ikis_messcat (imc_name)
             VALUES (UPPER (p_category));

        COMMIT;
    EXCEPTION
        WHEN UNIQUE_VIOLATION
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                REPLACE (
                    REPLACE (
                        REPLACE (GET_MESSAGE (msgUNIQUE_VIOLATION),
                                 '<P1>',
                                 'ikis_messcat'),
                        '<P2>',
                        'imc_name'),
                    '<P3>',
                    p_category));
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                REPLACE (
                    REPLACE (GET_MESSAGE (msgCOMMON_EXCEPTION),
                             '<P1>',
                             'Add_Category'),
                    '<P2>',
                    SQLERRM));
    END;

    PROCEDURE Add_Message (
        p_ss_code         ikis_messages.ipm_ss_code%TYPE,
        p_tp              ikis_messages.ipm_tp%TYPE,
        p_message         ikis_messages.ipm_message%TYPE,
        p_cause           ikis_messages.ipm_cause%TYPE,
        p_action          ikis_messages.ipm_action%TYPE,
        p_category        ikis_messages.ipm_category%TYPE,
        p_constname       ikis_messages.ipm_constname%TYPE,   -- имя константы
        p_id          OUT ikis_messages.ipm_id%TYPE)
    IS
        l_id   ikis_messages.ipm_id%TYPE;
    BEGIN
        SELECT sq_id_ikis_messages.NEXTVAL INTO l_id FROM DUAL;

        p_id := l_id;

        INSERT INTO ikis_messages (ipm_id,
                                   ipm_ss_code,
                                   ipm_tp,
                                   ipm_message,
                                   ipm_category,
                                   ipm_cause,
                                   ipm_action,
                                   ipm_constname)
             VALUES (l_id,
                     p_ss_code,
                     p_tp,
                     p_message,
                     p_category,
                     p_cause,
                     p_action,
                     p_constname);

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                REPLACE (
                    REPLACE (GET_MESSAGE (msgCOMMON_EXCEPTION),
                             '<P1>',
                             'Add_Message'),
                    '<P2>',
                    SQLERRM));
    END;

    PROCEDURE Edit_Message (p_ss_code     ikis_messages.ipm_ss_code%TYPE,
                            p_tp          ikis_messages.ipm_tp%TYPE,
                            p_message     ikis_messages.ipm_message%TYPE,
                            p_cause       ikis_messages.ipm_cause%TYPE,
                            p_action      ikis_messages.ipm_action%TYPE,
                            p_category    ikis_messages.ipm_category%TYPE,
                            p_constname   ikis_messages.ipm_constname%TYPE, -- имя константы
                            p_id          ikis_messages.ipm_id%TYPE)
    IS
        l_id   ikis_messages.ipm_id%TYPE;
    BEGIN
        UPDATE ikis_messages
           SET ipm_ss_code = p_ss_code,
               ipm_tp = p_tp,
               ipm_message = p_message,
               ipm_cause = p_cause,
               ipm_action = p_action,
               ipm_category = p_category,
               ipm_constname = p_constname
         WHERE ipm_id = p_id;

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                REPLACE (
                    REPLACE (GET_MESSAGE (msgCOMMON_EXCEPTION),
                             '<P1>',
                             'Edit_Message'),
                    '<P2>',
                    SQLERRM));
    END;


    PROCEDURE Get_Messages (p_messages OUT TRefCursor)
    IS
    BEGIN
        OPEN p_messages FOR
            SELECT ipm_id,
                   ipm_ss_code,
                   ipm_tp,
                   ipm_message,
                   ipm_cause,
                   ipm_action,
                   ipm_category
              FROM ikis_messages;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                REPLACE (
                    REPLACE (GET_MESSAGE (msgCOMMON_EXCEPTION),
                             '<P1>',
                             'Get_Messages'),
                    '<P2>',
                    SQLERRM));
    END;

    PROCEDURE GetConstForCategory (
        p_category       ikis_messages.ipm_category%TYPE,          --категория
        p_type           INTEGER,      -- тип исходников 1-PL/SQl или 2-Delphi
        p_src        OUT CLOB)                          --текст блока констант
    IS
    BEGIN
        IF p_type = 1
        THEN
            p_src :=
                   '  -- Messages for category: '
                || UPPER (p_category)
                || CHR (10);
        END IF;

        IF p_type = 2
        THEN
            p_src :=
                   '  // Messages for category: '
                || UPPER (p_category)
                || CHR (10);
        END IF;

        FOR con IN (  SELECT x.ipm_constname, x.ipm_id
                        FROM ikis_messages x
                       WHERE x.ipm_category = p_category
                    ORDER BY x.ipm_id)
        LOOP
            IF p_type = 1
            THEN
                p_src :=
                       p_src
                    || '  '
                    || RPAD (con.ipm_constname, 35, ' ')
                    || ' number := '
                    || con.ipm_id
                    || ';'
                    || CHR (10);
            END IF;

            IF p_type = 2
            THEN
                p_src :=
                       p_src
                    || '  '
                    || RPAD (con.ipm_constname, 35, ' ')
                    || ' = '
                    || con.ipm_id
                    || ';'
                    || CHR (10);
            END IF;
        END LOOP;
    END;
END IKIS_MESSAGE_UTIL;
/