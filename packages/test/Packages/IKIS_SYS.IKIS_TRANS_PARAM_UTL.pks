/* Formatted on 8/12/2025 6:10:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_TRANS_PARAM_UTL
IS
    -- Author  : RYABA
    -- Created : 20.11.2004 11:05:54
    -- Purpose : Робота з параметрами транзації

    PROCEDURE SetParam (p_name    IN ikis_trans_param.itp_name%TYPE,
                        p_value   IN ikis_trans_param.itp_value%TYPE);

    FUNCTION GetParam (p_name IN ikis_trans_param.itp_name%TYPE)
        RETURN ikis_trans_param.itp_value%TYPE;

    PROCEDURE PGetParam (p_name    IN     ikis_trans_param.itp_name%TYPE,
                         p_value      OUT ikis_trans_param.itp_value%TYPE);
END IKIS_TRANS_PARAM_UTL;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_TRANS_PARAM_UTL FOR IKIS_SYS.IKIS_TRANS_PARAM_UTL
/


GRANT EXECUTE ON IKIS_SYS.IKIS_TRANS_PARAM_UTL TO II01RC_IKIS_COMMON
/

GRANT EXECUTE ON IKIS_SYS.IKIS_TRANS_PARAM_UTL TO II01RC_IKIS_DESIGN
/

GRANT EXECUTE ON IKIS_SYS.IKIS_TRANS_PARAM_UTL TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_TRANS_PARAM_UTL TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_TRANS_PARAM_UTL TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_TRANS_PARAM_UTL TO IKIS_SYSWEB WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_TRANS_PARAM_UTL TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_TRANS_PARAM_UTL TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_TRANS_PARAM_UTL TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_TRANS_PARAM_UTL TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_TRANS_PARAM_UTL TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_TRANS_PARAM_UTL TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_TRANS_PARAM_UTL TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_TRANS_PARAM_UTL TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_TRANS_PARAM_UTL TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:10:05 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_TRANS_PARAM_UTL
IS
    msgCOMMON_EXCEPTION   NUMBER := 2;
    msgUnkAppParam        NUMBER := 517;

    PROCEDURE SetParam (p_name    IN ikis_trans_param.itp_name%TYPE,
                        p_value   IN ikis_trans_param.itp_value%TYPE)
    IS
        v_res   NUMBER := 0;
    BEGIN
        BEGIN
            SELECT 1
              INTO v_res
              FROM ikis_trans_param
             WHERE itp_name = UPPER (TRIM (p_name));

            UPDATE ikis_trans_param
               SET itp_value = p_value
             WHERE itp_name = TRIM (p_name);
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                INSERT INTO ikis_trans_param (itp_name, itp_value)
                     VALUES (UPPER (TRIM (p_name)), p_value);
        END;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_TRANS_PARAM_UTL.SetParam with ' || SQLERRM));
    END;

    FUNCTION GetParam (p_name IN ikis_trans_param.itp_name%TYPE)
        RETURN ikis_trans_param.itp_value%TYPE
    IS
        v_res   ikis_trans_param.itp_value%TYPE;
    BEGIN
        IF UPPER (TRIM (p_name)) = 'LOCAL_TRANSACTION_ID'
        THEN
            v_res := DBMS_TRANSACTION.LOCAL_TRANSACTION_ID;
        ELSE
            SELECT itp_value
              INTO v_res
              FROM ikis_trans_param
             WHERE itp_name = UPPER (TRIM (p_name));
        END IF;

        RETURN v_res;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgUnkAppParam, p_name));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_TRANS_PARAM_UTL.GetParam with ' || SQLERRM));
    END;

    PROCEDURE PGetParam (p_name    IN     ikis_trans_param.itp_name%TYPE,
                         p_value      OUT ikis_trans_param.itp_value%TYPE)
    IS
    BEGIN
        p_value := GetParam (p_name);
    END;
END IKIS_TRANS_PARAM_UTL;
/