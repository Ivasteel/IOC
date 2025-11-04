/* Formatted on 8/12/2025 6:11:37 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_SYSWEB.pipe_debug (p_sess   VARCHAR2,
                                                    msg      VARCHAR2)
IS
    status   NUMBER;
    l_msg    VARCHAR2 (32760);
    l_key    VARCHAR2 (1);
BEGIN
    l_msg :=
           TO_CHAR (SYSDATE, 'DD/MM/YYYY HH24:MI:SS')
        || '<'
        || p_sess
        || '>: '
        || msg;
    DBMS_PIPE.PACK_MESSAGE (LENGTH (l_msg));
    DBMS_PIPE.PACK_MESSAGE (l_msg);
    status := DBMS_PIPE.SEND_MESSAGE ('html_debug');

    IF NOT (status = 0)
    THEN
        raise_application_error (-20099, 'Debug error');
    END IF;
END;
/
