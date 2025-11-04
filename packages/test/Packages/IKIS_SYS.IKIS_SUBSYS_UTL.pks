/* Formatted on 8/12/2025 6:10:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_SUBSYS_UTL
IS
    -- Author  : RYABA
    -- Created : 30.11.2004 13:07:04
    -- Purpose : Робота з підсистемами без ініціалізації глобальних змінних

    PROCEDURE Add_SubSys (
        p_ss_code         IN ikis_subsys.ss_code%TYPE,
        p_ss_main         IN ikis_subsys.ss_main%TYPE,
        p_ss_comment      IN ikis_subsys.ss_comment%TYPE,
        p_ss_msys_begin   IN ikis_subsys.ss_msys_begin%TYPE,
        p_ss_msys_end     IN ikis_subsys.ss_msys_end%TYPE);
END IKIS_SUBSYS_UTL;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_SUBSYS_UTL FOR IKIS_SYS.IKIS_SUBSYS_UTL
/


GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTL TO II01RC_IKIS_DESIGN
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTL TO II01RC_IKIS_SUPERUSER
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTL TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTL TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTL TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTL TO IKIS_SYSWEB WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTL TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTL TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTL TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTL TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTL TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTL TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTL TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTL TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_SUBSYS_UTL TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:10:05 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_SUBSYS_UTL
IS
    PROCEDURE Add_SubSys (
        p_ss_code         IN ikis_subsys.ss_code%TYPE,
        p_ss_main         IN ikis_subsys.ss_main%TYPE,
        p_ss_comment      IN ikis_subsys.ss_comment%TYPE,
        p_ss_msys_begin   IN ikis_subsys.ss_msys_begin%TYPE,
        p_ss_msys_end     IN ikis_subsys.ss_msys_end%TYPE)
    IS
        v_res   NUMBER;
    BEGIN
        debug.f ('Start procedure');

        BEGIN
            SELECT COUNT (ROWID)
              INTO v_res
              FROM ikis_subsys
             WHERE ss_code = p_ss_code;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                v_res := 0;
        END;

        IF v_res = 0
        THEN
            INSERT INTO IKIS_SUBSYS (ss_code,
                                     ss_main,
                                     ss_comment,
                                     ss_msys_begin,
                                     ss_msys_end)
                 VALUES (p_ss_code,
                         p_ss_main,
                         p_ss_comment,
                         p_ss_msys_begin,
                         p_ss_msys_end);
        END IF;
    EXCEPTION
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
END IKIS_SUBSYS_UTL;
/