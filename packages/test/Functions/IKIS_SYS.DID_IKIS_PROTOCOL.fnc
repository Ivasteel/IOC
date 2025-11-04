/* Formatted on 8/12/2025 6:10:11 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION IKIS_SYS.DID_IKIS_PROTOCOL (p_id NUMBER)
    RETURN NUMBER
IS
    l_newid    DECIMAL;
    l_curval   DECIMAL;
    l_dtmp     DECIMAL;
BEGIN
    IF (p_id <> 0) AND (p_id IS NOT NULL)
    THEN
        IF     (p_id > DSERIALS.gd_serial_diapason)
           AND (p_id < DSERIALS.gd_serial_diap_max)
        THEN
            BEGIN
                SELECT SQ_DID_IKIS_PROTOCOL.CURRVAL INTO l_curval FROM DUAL;
            EXCEPTION
                WHEN OTHERS
                THEN
                    SELECT SQ_DID_IKIS_PROTOCOL.NEXTVAL
                      INTO l_curval
                      FROM DUAL;
            END;

            l_dtmp := p_id - DSERIALS.gd_serial_diapason;

            IF (l_dtmp > l_curval) OR (l_dtmp <= 0)
            THEN
                raise_application_error (
                    -20000,
                       'Value for ID '
                    || p_id
                    || ' greater of max value generated in sequence. This may cause problem.');
            ELSE
                RETURN p_id;
            END IF;
        ELSE
            RETURN p_id;
        END IF;
    END IF;

    SELECT SQ_DID_IKIS_PROTOCOL.NEXTVAL INTO l_newid FROM DUAL;

    DSERIALS.gd_serial_Last := DSERIALS.gd_serial_diapason + l_newid;
    RETURN DSERIALS.gd_serial_Last;
END;
/
