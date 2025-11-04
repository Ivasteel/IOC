/* Formatted on 8/12/2025 6:11:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.IKIS_DEBUG_PIPE
IS
    -- Author  : VANO
    -- Created : 04.12.2015 17:06:08
    -- Purpose : Функції роботи з DBMS_PIPE

    --Req:
    --grant select on sys.v_$db_pipes to schema;
    --grant execute on sys.dbms_pipe to schema;

    PROCEDURE WriteMsg (p_msg VARCHAR2, p_pipe VARCHAR2:= 'html_debug');

    FUNCTION GetMessage (p_pipe VARCHAR2:= 'html_debug')
        RETURN VARCHAR2;
END IKIS_DEBUG_PIPE;
/


GRANT EXECUTE ON IKIS_SYSWEB.IKIS_DEBUG_PIPE TO II01RC_SYSWEB_COMM
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_DEBUG_PIPE TO IKIS_RBM
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_DEBUG_PIPE TO IKIS_WEBPROXY
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_DEBUG_PIPE TO USS_ESR
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_DEBUG_PIPE TO USS_EXCH
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_DEBUG_PIPE TO USS_NDI
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_DEBUG_PIPE TO USS_PERSON
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_DEBUG_PIPE TO USS_RNSP
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_DEBUG_PIPE TO USS_RPT
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_DEBUG_PIPE TO USS_VISIT
/


/* Formatted on 8/12/2025 6:11:42 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.IKIS_DEBUG_PIPE
IS
    PROCEDURE WriteMsg (p_msg VARCHAR2, p_pipe VARCHAR2:= 'html_debug')
    IS
        status   NUMBER;
        l_msg    VARCHAR2 (32760);
    --  l_key varchar2(1);
    BEGIN
        IF ikis_sys.IKIS_PARAMETER_UTIL.GetParameter1 ('CAN_USE_DEBUG_PIPE',
                                                       'IKIS_SYS') =
           'YES'
        THEN
            l_msg :=
                TO_CHAR (SYSDATE, 'DD.MM.YYYY HH24:MI:SS') || ': ' || p_msg;
            SYS.DBMS_PIPE.pack_message (LENGTH (l_msg));
            SYS.DBMS_PIPE.PACK_MESSAGE (l_msg);
            status := DBMS_PIPE.SEND_MESSAGE (NVL (p_pipe, 'html_debug'));

            IF NOT (status = 0)
            THEN
                raise_application_error (-20099, 'Debug error');
            END IF;
        END IF;
    END;

    FUNCTION GetMessage (p_pipe VARCHAR2:= 'html_debug')
        RETURN VARCHAR2
    IS
        l_stat   PLS_INTEGER := 1;
        l_size   INTEGER;
        l_msg    VARCHAR2 (4096) := '';
    BEGIN
        l_stat :=
            SYS.DBMS_PIPE.RECEIVE_MESSAGE (NVL (p_pipe, 'html_debug'),
                                           timeout   => 0);

        IF l_stat = 0
        THEN
            DBMS_PIPE.unpack_message (l_size);
            DBMS_PIPE.UNPACK_MESSAGE (l_msg);
        END IF;

        RETURN l_msg;
    END;
BEGIN
    NULL;
END IKIS_DEBUG_PIPE;
/