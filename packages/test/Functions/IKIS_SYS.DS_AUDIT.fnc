/* Formatted on 8/12/2025 6:10:11 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION IKIS_SYS.DS_AUDIT (NId DECIMAL)
    RETURN DECIMAL
IS
    newid    DECIMAL;
    vID      DECIMAL;
    dtmp     DECIMAL;
    curval   DECIMAL;
BEGIN
    IF (NId <> 0) AND (Nid IS NOT NULL)
    THEN
        IF     (NId > DSERIALS.gd_serial_diapason)
           AND (NId < DSERIALS.gd_serial_diap_max)
        THEN
            SELECT seq_AUDIT_id.CURRVAL INTO curval FROM DUAL;

            dtmp := Nid - DSERIALS.gd_serial_diapason;

            IF (dtmp > curval) OR (dtmp <= 0)
            THEN
                raise_application_error (
                    -746,
                    'Invalid value for psevdoserial column');
            --RAISE AUD_GEN_ID_Except;
            ELSE
                RETURN NId;
            END IF;
        ELSE
            RETURN NId;
        END IF;
    END IF;

    SELECT seq_AUDIT_id.NEXTVAL INTO newid FROM DUAL;

    DSERIALS.gd_serial_Last := DSERIALS.gd_serial_diapason + newid;
    RETURN DSERIALS.gd_serial_Last;
END;
/


CREATE OR REPLACE PUBLIC SYNONYM DS_AUDIT FOR IKIS_SYS.DS_AUDIT
/


GRANT EXECUTE ON IKIS_SYS.DS_AUDIT TO II01RC_IKIS_COMMON
/
