/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_PARAMETER_UTIL
IS
    -- Author  : YURA_A
    -- Created : 29.09.2003 10:21:57
    -- Purpose : Ведение параметров системы

    valNA   CONSTANT VARCHAR2 (3) := 'N/A';

    ----------------------------------------
    -- YURA_A 29.09.2003 12:05:15
    ----------------------------------------
    -- Назначение : Добавить ран-тайм параметр в ИКИС
    -- Параметры  : 1) код параметра (он же первичный ключ)
    -- 2) код подсистемы (первычный ключ)
    -- 3) значение
    PROCEDURE AddParameter (p_par_code      ikis_parameters.par_code%TYPE,
                            p_par_ss_code   ikis_parameters.par_ss_code%TYPE,
                            p_par_value     ikis_parameters.par_value%TYPE);

    ----------------------------------------
    -- YURA_A 29.09.2003 12:06:19
    ----------------------------------------
    -- Назначение : Изменить значение параметра
    -- Параметры  : 1) код параметра (он же первичный ключ)
    -- 2) код подсистемы (первычный ключ)
    -- 3) значение
    PROCEDURE EditParameter (
        p_par_code      ikis_parameters.par_code%TYPE,
        p_par_ss_code   ikis_parameters.par_ss_code%TYPE,
        p_par_value     ikis_parameters.par_value%TYPE);

    ----------------------------------------
    -- RYABA 29.09.2003 12:06:19
    ----------------------------------------
    -- Назначение : Установить значение параметра
    -- Параметры  : 1) код параметра (он же первичный ключ)
    -- 2) код подсистемы (первычный ключ)
    -- 3) значение
    PROCEDURE SetParameter (p_par_code      ikis_parameters.par_code%TYPE,
                            p_par_ss_code   ikis_parameters.par_ss_code%TYPE,
                            p_par_value     ikis_parameters.par_value%TYPE);


    ----------------------------------------
    -- YURA_A 29.09.2003 12:06:23
    ----------------------------------------
    -- Назначение : Удалить параметр (можно удалять только ран-тайм параметры
    -- Параметры  : 1) код параметра (он же первичный ключ)
    -- 2) код подсистемы (первычный ключ)
    PROCEDURE DropParameter (
        p_par_code      ikis_parameters.par_code%TYPE,
        p_par_ss_code   ikis_parameters.par_ss_code%TYPE);

    ----------------------------------------
    -- YURA_A 29.09.2003 12:06:29
    ----------------------------------------
    -- Назначение : Получить значение параметра
    -- Параметры  : 1) код параметра (он же первичный ключ)
    -- 2) код подсистемы (первычный ключ)
    -- 3) значение
    PROCEDURE GetParameter (
        p_par_code          ikis_parameters.par_code%TYPE,
        p_par_ss_code       ikis_parameters.par_ss_code%TYPE,
        p_par_value     OUT ikis_parameters.par_value%TYPE);

    FUNCTION GetParameter (p_par_code      ikis_parameters.par_code%TYPE,
                           p_par_ss_code   ikis_parameters.par_ss_code%TYPE)
        RETURN VARCHAR2;

    ----------------------------------------
    -- YURA_A 13.12.2005 12:41:38
    ----------------------------------------
    -- Назначение : тоже что и предыд. но если параметра нету, то возвращает N/A (valNA)
    FUNCTION GetParameter1 (p_par_code      ikis_parameters.par_code%TYPE,
                            p_par_ss_code   ikis_parameters.par_ss_code%TYPE)
        RETURN VARCHAR2;
END IKIS_PARAMETER_UTIL;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_PARAMETER_UTIL FOR IKIS_SYS.IKIS_PARAMETER_UTIL
/


GRANT EXECUTE ON IKIS_SYS.IKIS_PARAMETER_UTIL TO II01RC_IKIS_COMMON
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PARAMETER_UTIL TO II01RC_IKIS_REPL
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PARAMETER_UTIL TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PARAMETER_UTIL TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PARAMETER_UTIL TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PARAMETER_UTIL TO IKIS_SYSWEB WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PARAMETER_UTIL TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PARAMETER_UTIL TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PARAMETER_UTIL TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PARAMETER_UTIL TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PARAMETER_UTIL TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PARAMETER_UTIL TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PARAMETER_UTIL TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PARAMETER_UTIL TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_PARAMETER_UTIL TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:10:04 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_PARAMETER_UTIL
IS
    UNIQUE_VIOLATION      EXCEPTION;
    PRAGMA EXCEPTION_INIT (UNIQUE_VIOLATION, -1);

    -- Messages for category: COMMON
    msgCOMMON_EXCEPTION   NUMBER := 2;
    msgParAlreadyExist    NUMBER := 957;
    msgParNotFound        NUMBER := 958;
    msgNotDelDesignPar    NUMBER := 959;

    PROCEDURE AddParameter (p_par_code      ikis_parameters.par_code%TYPE,
                            p_par_ss_code   ikis_parameters.par_ss_code%TYPE,
                            p_par_value     ikis_parameters.par_value%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        debug.f ('Start procedure');

        INSERT INTO ikis_parameters (par_code,
                                     par_ss_code,
                                     par_value,
                                     par_tp,
                                     par_dt,
                                     par_comment)
             VALUES (UPPER (p_par_code),
                     UPPER (p_par_ss_code),
                     p_par_value,
                     ikis_const.v_dds_parameter_tp_r,
                     SYSDATE,
                     NULL);

        COMMIT;
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN UNIQUE_VIOLATION
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgParAlreadyExist,
                                               UPPER (p_par_code),
                                               UPPER (p_par_ss_code)));
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_PARAMETER_UTIL.AddParameter',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE EditParameter (
        p_par_code      ikis_parameters.par_code%TYPE,
        p_par_ss_code   ikis_parameters.par_ss_code%TYPE,
        p_par_value     ikis_parameters.par_value%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        debug.f ('Start procedure');

        UPDATE ikis_parameters
           SET par_value = p_par_value, par_dt = SYSDATE
         WHERE     par_code = UPPER (p_par_code)
               AND par_ss_code = UPPER (p_par_ss_code);

        IF SQL%ROWCOUNT = 0
        THEN
            RAISE NO_DATA_FOUND;
        END IF;

        COMMIT;
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgParNotFound,
                                               UPPER (p_par_code),
                                               UPPER (p_par_ss_code)));
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_PARAMETER_UTIL.EditParameter',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE SetParameter (p_par_code      ikis_parameters.par_code%TYPE,
                            p_par_ss_code   ikis_parameters.par_ss_code%TYPE,
                            p_par_value     ikis_parameters.par_value%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        debug.f ('Start procedure');

        UPDATE ikis_parameters
           SET par_value = p_par_value, par_dt = SYSDATE
         WHERE     par_code = UPPER (p_par_code)
               AND par_ss_code = UPPER (p_par_ss_code);

        IF SQL%ROWCOUNT = 0
        THEN
            INSERT INTO ikis_parameters (par_code,
                                         par_ss_code,
                                         par_value,
                                         par_tp,
                                         par_dt,
                                         par_comment)
                 VALUES (UPPER (p_par_code),
                         UPPER (p_par_ss_code),
                         p_par_value,
                         ikis_const.v_dds_parameter_tp_r,
                         SYSDATE,
                         NULL);
        END IF;

        COMMIT;
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgParNotFound,
                                               UPPER (p_par_code),
                                               UPPER (p_par_ss_code)));
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_PARAMETER_UTIL.EditParameter',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE DropParameter (
        p_par_code      ikis_parameters.par_code%TYPE,
        p_par_ss_code   ikis_parameters.par_ss_code%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_tp                ikis_parameters.par_tp%TYPE;
        exNotDelDesignPar   EXCEPTION;
    BEGIN
        debug.f ('Start procedure');

        SELECT par_tp
          INTO l_tp
          FROM ikis_parameters
         WHERE     par_code = UPPER (p_par_code)
               AND par_ss_code = UPPER (p_par_ss_code);

        IF l_tp = ikis_const.v_dds_parameter_tp_d
        THEN
            RAISE exNotDelDesignPar;
        END IF;

        DELETE ikis_parameters
         WHERE     par_code = UPPER (p_par_code)
               AND par_ss_code = UPPER (p_par_ss_code);

        IF SQL%ROWCOUNT = 0
        THEN
            RAISE NO_DATA_FOUND;
        END IF;

        COMMIT;
        debug.f ('Stop procedure');
    EXCEPTION
        WHEN exNotDelDesignPar
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgNotDelDesignPar,
                                               UPPER (p_par_code),
                                               UPPER (p_par_ss_code)));
        WHEN NO_DATA_FOUND
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgParNotFound,
                                               UPPER (p_par_code),
                                               UPPER (p_par_ss_code)));
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_PARAMETER_UTIL.DropParameter',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE GetParameter (
        p_par_code          ikis_parameters.par_code%TYPE,
        p_par_ss_code       ikis_parameters.par_ss_code%TYPE,
        p_par_value     OUT ikis_parameters.par_value%TYPE)
    IS
    BEGIN
        debug.f ('Start procedure');

        SELECT par_value
          INTO p_par_value
          FROM ikis_parameters
         WHERE     par_code = UPPER (p_par_code)
               AND par_ss_code = UPPER (p_par_ss_code);

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgParNotFound,
                                               UPPER (p_par_code),
                                               UPPER (p_par_ss_code)));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_PARAMETER_UTIL.GetParameter',
                    CHR (10) || SQLERRM));
    END;

    FUNCTION GetParameter1 (p_par_code      ikis_parameters.par_code%TYPE,
                            p_par_ss_code   ikis_parameters.par_ss_code%TYPE)
        RETURN VARCHAR2
    IS
        l_val   ikis_parameters.par_value%TYPE;
    BEGIN
        debug.f ('Start procedure');

        SELECT par_value
          INTO l_val
          FROM ikis_parameters
         WHERE     par_code = UPPER (p_par_code)
               AND par_ss_code = UPPER (p_par_ss_code);

        debug.f ('Stop procedure');
        RETURN l_val;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN valNA;
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_PARAMETER_UTIL.GetParameter',
                    CHR (10) || SQLERRM));
    END;

    FUNCTION GetParameter (p_par_code      ikis_parameters.par_code%TYPE,
                           p_par_ss_code   ikis_parameters.par_ss_code%TYPE)
        RETURN VARCHAR2
    IS
        l_value   ikis_parameters.par_value%TYPE;
    BEGIN
        GetParameter (p_par_code, p_par_ss_code, l_value);
        RETURN l_value;
    END;
END IKIS_PARAMETER_UTIL;
/