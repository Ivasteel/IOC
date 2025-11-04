/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.DSERIALS
AS
    INVALID_VALUE4DIAPCOLUMN   EXCEPTION;

    gd_serial_Last             NUMBER := NULL;

    FUNCTION gd_serial_diapason
        RETURN NUMBER;

    FUNCTION gd_serial_diap_max
        RETURN NUMBER;

    FUNCTION dimension
        RETURN NUMBER;


    gd_ts_enabled              BOOLEAN := TRUE;
    gd_tp_enabled              BOOLEAN := TRUE;
    gd_idiap_enabled           BOOLEAN := TRUE;

    --Возвращает 0 для репликатора 3.1.1
    PROCEDURE GetNextTimestamp (p_timestamp OUT NUMBER);

    --Дергает сиквенсу SQ_OTH_TIMESTAMP и возвращает полученное значение
    PROCEDURE GetNextTimestampSQ (p_timestamp OUT NUMBER);
END DSERIALS;
/


CREATE OR REPLACE PUBLIC SYNONYM DSERIALS FOR IKIS_SYS.DSERIALS
/


GRANT EXECUTE ON IKIS_SYS.DSERIALS TO II01RC_IKIS_COMMON
/

GRANT EXECUTE ON IKIS_SYS.DSERIALS TO II01RC_IKIS_DESIGN
/

GRANT EXECUTE ON IKIS_SYS.DSERIALS TO II01RC_IKIS_REPL
/

GRANT EXECUTE ON IKIS_SYS.DSERIALS TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.DSERIALS TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.DSERIALS TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.DSERIALS TO IKIS_SYSWEB WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.DSERIALS TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.DSERIALS TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.DSERIALS TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.DSERIALS TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.DSERIALS TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.DSERIALS TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.DSERIALS TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.DSERIALS TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.DSERIALS TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:10:01 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.DSERIALS
AS
    l_gd_serial_diapason   NUMBER := NULL;
    l_gd_serial_diap_max   NUMBER := NULL;

    l_dimension            NUMBER := 10000000000;

    -- Messages for category: COMMON"
    msgUNIQUE_VIOLATION    NUMBER := 1;
    msgCOMMON_EXCEPTION    NUMBER := 2;
    msgAlreadyLocked       NUMBER := 77;
    msgDataChanged         NUMBER := 78;
    msgEstablish           NUMBER := 79;
    msgGroupControlError   NUMBER := 97;
    msgProgramError        NUMBER := 117;

    FUNCTION dimension
        RETURN NUMBER
    IS
    BEGIN
        RETURN l_dimension;
    END;

    FUNCTION gd_serial_diapason
        RETURN NUMBER
    IS
    BEGIN
        RETURN l_gd_serial_diapason;
    END;

    FUNCTION gd_serial_diap_max
        RETURN NUMBER
    IS
    BEGIN
        RETURN l_gd_serial_diap_max;
    END;

    PROCEDURE DSerialInitGlob
    IS
        l_dtmp   NUMBER;
    BEGIN
        debug.f ('Start DSerialInitGlob');

        --Шаблон
        BEGIN
            SELECT c.orgp_value
              INTO l_dtmp
              FROM appt_params    a,
                   opfu           b,
                   opfu_param     c,
                   opfu_param_tp  d
             WHERE     a.aptprm_name = 'IKIS_OPFU'
                   AND a.aptprm_value = b.org_id
                   AND b.org_id = c.orgp_org
                   AND c.orgp_optp = d.optp_id
                   AND d.optp_code = 'DIAP_PRFX'
                   AND d.optp_st = ikis_const.V_DDS_DICS_ST_A
                   AND c.orgp_st = ikis_const.V_DDS_DICS_ST_A;

            debug.f ('l_dtmp %s', l_dtmp);
        EXCEPTION
            WHEN OTHERS
            THEN
                raise_application_error (
                    -20000,
                    ikis_message_util.GET_MESSAGE (
                        msgCOMMON_EXCEPTION,
                        'DSERIALS.DSerialInitGlob',
                        CHR (10) || SQLERRM));
        END;

        l_gd_serial_diapason := l_dimension;
        --    l_dtmp:=1;

        l_gd_serial_diap_max := (l_dtmp + 1) * l_gd_serial_diapason;
        l_gd_serial_diapason := l_dtmp * l_gd_serial_diapason;

        debug.f ('l_gd_serial_diap_max %s; l_gd_serial_diapason %s',
                 l_gd_serial_diap_max,
                 l_gd_serial_diapason);
        debug.f ('Stop DSerialInitGlob');
    END DSerialInitGlob;

    PROCEDURE GetNextTimestamp (p_timestamp OUT NUMBER)
    IS
    BEGIN
        /*select SQ_OTH_TIMESTAMP.NEXTVAL into p_timestamp from DUAL;*/
        --Переход на новый репликатор ver. 3.1.1
        --p_timestamp:=0; !!Согласовано с Максом 2005-11-30
        p_timestamp := -1;
    END;


    PROCEDURE GetNextTimestampSQ (p_timestamp OUT NUMBER)
    IS
    BEGIN
        SELECT SQ_OTH_TIMESTAMP.NEXTVAL INTO p_timestamp FROM DUAL;
    END;
BEGIN
    DSerialInitGlob;
END;
/