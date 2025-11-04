/* Formatted on 8/12/2025 6:10:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.SR_ENGINE_EX
IS
    ----------------------------------------
    -- YURA_A 11.08.2003 14:56:17
    ----------------------------------------
    -- Назначение : Определение типа TFields (wrap)

    --Именовані значення полів курсору
    TYPE TFields IS TABLE OF VARCHAR2 (2000)
        INDEX BY VARCHAR2 (100);

    user_control_exception   EXCEPTION;

    --Ryaba 2.09.2004 11.45
    --Функція повертає код підситеми ІКІС для задачу контролю
    FUNCTION GetWorkSS (p_work sr_work.w_id%TYPE)
        RETURN sr_essences.es_code%TYPE;

    --Процедура встановлює значення для параметру завдання
    PROCEDURE SetWorkParam (p_work    IN NUMBER,
                            p_param   IN VARCHAR2,
                            p_value   IN VARCHAR2);

    --Функція повертає значення парметру завдання
    FUNCTION GetWorkParam (p_work IN NUMBER, p_param IN VARCHAR2)
        RETURN VARCHAR2;

    --Процедура повертає значення парметру завдання
    PROCEDURE PGetWorkParam (p_work    IN     NUMBER,
                             p_param   IN     VARCHAR2,
                             p_value      OUT VARCHAR2);
END SR_ENGINE_EX;
/


CREATE OR REPLACE PUBLIC SYNONYM SR_ENGINE_EX FOR IKIS_SYS.SR_ENGINE_EX
/


GRANT EXECUTE ON IKIS_SYS.SR_ENGINE_EX TO II01RC_IKIS_COMMON
/

GRANT EXECUTE ON IKIS_SYS.SR_ENGINE_EX TO II01RC_SR_CONTROL_DESIGN
/

GRANT EXECUTE ON IKIS_SYS.SR_ENGINE_EX TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.SR_ENGINE_EX TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.SR_ENGINE_EX TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.SR_ENGINE_EX TO IKIS_SYSWEB WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.SR_ENGINE_EX TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.SR_ENGINE_EX TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.SR_ENGINE_EX TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.SR_ENGINE_EX TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.SR_ENGINE_EX TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.SR_ENGINE_EX TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.SR_ENGINE_EX TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.SR_ENGINE_EX TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.SR_ENGINE_EX TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:10:05 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.SR_ENGINE_EX
IS
    msgCOMMON_EXCEPTION   NUMBER := 2;

    FUNCTION GetWorkSS (p_work sr_work.w_id%TYPE)
        RETURN sr_essences.es_code%TYPE
    IS
        l_ss   sr_essences.es_code%TYPE;
    BEGIN
        SELECT es_ss_code
          INTO l_ss
          FROM sr_essences, sr_groups, sr_work
         WHERE grp_es = es_code AND w_grp = grp_id AND w_id = p_work;

        RETURN l_ss;
    END;


    PROCEDURE SetWorkParam (p_work    IN NUMBER,
                            p_param   IN VARCHAR2,
                            p_value   IN VARCHAR2)
    IS
    BEGIN
        BEGIN
            INSERT INTO sr_work_params (wps_w, wps_name, wps_value)
                 VALUES (p_work, p_param, p_value);
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
                UPDATE sr_work_params
                   SET wps_value = p_value
                 WHERE wps_w = p_work AND wps_name = p_param;
        END;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'SR_ENGINE_PARAMS.SetWorkParam',
                    CHR (10) || SQLERRM));
    END;

    FUNCTION GetWorkParam (p_work IN NUMBER, p_param IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_value   VARCHAR2 (250);
    BEGIN
        BEGIN
            SELECT wps_value
              INTO l_value
              FROM sr_work_params
             WHERE wps_w = p_work AND wps_name = p_param;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                l_value := NULL;
        END;

        RETURN l_value;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'SR_ENGINE_PARAMS.GetWorkParam',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE PGetWorkParam (p_work    IN     NUMBER,
                             p_param   IN     VARCHAR2,
                             p_value      OUT VARCHAR2)
    IS
    BEGIN
        p_value := GetWorkParam (p_work, p_param);
    END;
END SR_ENGINE_EX;
/