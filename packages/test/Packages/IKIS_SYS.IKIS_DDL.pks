/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.ikis_ddl
IS
    -- Author  : YURA_A
    -- Created : 27.01.2004 18:11:34
    -- Purpose :

    PROCEDURE CheckDDL;

    PROCEDURE EndDDL;

    PROCEDURE SetDDLParam (pwd IN VARCHAR2);

    PROCEDURE SetDDLPwd (pwd IN VARCHAR2);

    PROCEDURE CheckPWD;
END ikis_ddl;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_DDL FOR IKIS_SYS.IKIS_DDL
/


GRANT EXECUTE ON IKIS_SYS.IKIS_DDL TO II01RC_IKIS_SUPERUSER
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DDL TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DDL TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DDL TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DDL TO IKIS_SYSWEB WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DDL TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DDL TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DDL TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DDL TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DDL TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DDL TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DDL TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DDL TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DDL TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:10:03 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.ikis_ddl
IS
    msgDDLError            NUMBER := 1854;


    c_param_code           VARCHAR2 (2000) := 'DDL_PWD';
    c_sys_code             VARCHAR2 (2000) := 'IKIS_SYS';
    c_ddl_pwd              VARCHAR2 (8) := 'CAN_DDL';

    ora_object_exception   EXCEPTION;
    PRAGMA EXCEPTION_INIT (ora_object_exception, -01434);

    PROCEDURE CheckDDL
    IS
        p_value   VARCHAR2 (2000);
        l_p       VARCHAR2 (8);
    BEGIN
        debug.f ('Start procedure');

        BEGIN
            --execute immediate 'begin ikis_parameter_util.getparameter(:c_param_code,:c_sys_code,:p_value); end;' using in out c_param_code, c_sys_code, p_value;
            EXECUTE IMMEDIATE 'begin select x.par_value into :p_value from ikis_parameters x where x.par_code=:c_param_code and x.par_ss_code=:c_sys_code; end;'
                USING OUT p_value, IN c_param_code, IN c_sys_code;

            l_p := '12345678';

            EXECUTE IMMEDIATE 'begin :p_value:=utl_raw.cast_to_varchar2(ikis_crypt.decryptraw(:p_value,utl_raw.cast_to_raw(:p_p))); end;'
                USING IN OUT p_value, IN l_p;

            IF NOT (p_value = c_ddl_pwd)
            THEN
                RAISE NO_DATA_FOUND;
            END IF;
        END;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgDDLError));
    --raise_application_error(-20000,'Неможливо змінювати структуру БД.');
    END;

    PROCEDURE EndDDL
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        debug.f ('Start procedure');

        EXECUTE IMMEDIATE 'begin delete from ikis_parameters x where x.par_code=:c_param_code and x.par_ss_code=:c_sys_code; end;'
            USING IN c_param_code, IN c_sys_code;

        COMMIT;
        debug.f ('Stop procedure');
    END;

    PROCEDURE SetDDLParam (pwd IN VARCHAR2)                           --пароль
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        debug.f ('Start procedure');
        EndDDL;

        EXECUTE IMMEDIATE 'begin insert into ikis_parameters(par_code, par_ss_code, par_value) values(:c_param_code, :c_ss_code, :c_value); end;'
            USING IN c_param_code, c_sys_code, pwd;

        COMMIT;
        debug.f ('Stop procedure');
    END;

    PROCEDURE SetDDLPwd (pwd IN VARCHAR2)                             --пароль
    IS
        l_data   VARCHAR2 (2000);
        l_p      VARCHAR2 (8);
    BEGIN
        l_p := '12345678';
        l_data :=
            ikis_crypt.encryptraw (UTL_RAW.cast_to_raw (pwd),
                                   UTL_RAW.cast_to_raw (l_p));
        SetDDLParam (l_data);
    END;

    PROCEDURE CheckPWD
    IS
    BEGIN
        EXECUTE IMMEDIATE 'drop synonym ikis_ddl_check_and_not_exists';
    EXCEPTION
        WHEN ora_object_exception
        THEN
            NULL;
        WHEN OTHERS
        THEN
            RAISE;
    END;
END ikis_ddl;
/