/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.ikis_crypt
IS
    -- Author  : YURA_A
    -- Created : 12.01.2004 12:50:28
    -- Purpose :

    FUNCTION EncryptRaw (p_data RAW, p_key RAW)
        RETURN RAW;

    FUNCTION DecryptRaw (p_data RAW, p_key RAW)
        RETURN RAW;
END ikis_crypt;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_CRYPT FOR IKIS_SYS.IKIS_CRYPT
/


GRANT EXECUTE ON IKIS_SYS.IKIS_CRYPT TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CRYPT TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CRYPT TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CRYPT TO IKIS_SYSWEB WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CRYPT TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CRYPT TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CRYPT TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CRYPT TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CRYPT TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CRYPT TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CRYPT TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CRYPT TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CRYPT TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:10:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.ikis_crypt
IS
    -- Messages for category: IKIS_ACTIVATE
    msgCOMMON_EXCEPTION     NUMBER := 2;
    msgCertAlreadyUnload    NUMBER := 1807;
    msgActivateAlreadySet   NUMBER := 1808;
    msgFileCertExist        NUMBER := 1809;
    msgInvalPwd             NUMBER := 1810;

    g_charkey               VARCHAR2 (48);

    FUNCTION padraw (p_raw IN RAW)
        RETURN RAW
    IS
        l_len   NUMBER DEFAULT UTL_RAW.LENGTH (p_raw);
    BEGIN
        RETURN UTL_RAW.CONCAT (
                   UTL_RAW.cast_to_raw (TO_CHAR (l_len, 'fm00000009')),
                   p_raw,
                   UTL_RAW.cast_to_raw (
                       RPAD (CHR (0),
                             (8 - MOD (l_len, 8)) * SIGN (MOD (l_len, 8)),
                             CHR (0))));
    END;

    FUNCTION unpadraw (p_raw IN RAW)
        RETURN RAW
    IS
    BEGIN
        RETURN UTL_RAW.SUBSTR (
                   p_raw,
                   9,
                   TO_NUMBER (
                       UTL_RAW.cast_to_varchar2 (
                           UTL_RAW.SUBSTR (p_raw, 1, 8))));
    END;

    PROCEDURE setkey (p_key VARCHAR2)
    IS
    BEGIN
        IF (g_charkey = p_key) OR (p_key IS NULL)
        THEN
            RETURN;
        END IF;

        g_charkey := p_key;

        IF LENGTH (g_charkey) NOT IN (16)
        THEN
            raise_application_error (-20000, 'Поганий пароль.');
        END IF;
    END;

    FUNCTION EncryptRaw (p_data RAW, p_key RAW)
        RETURN RAW
    IS
        l_encrypted   LONG RAW;
    BEGIN
        setkey (p_key);

        EXECUTE IMMEDIATE   'begin '
                         || '  dbms_obfuscation_toolkit.desencrypt('
                         || '    input => :1,'
                         || '    key   => :2,'
                         || '    encrypted_data => :3);'
                         || 'end;'
            USING IN padraw (p_data),
                  IN HEXTORAW (g_charkey),
                  IN OUT l_encrypted;

        RETURN l_encrypted;
    END;

    FUNCTION DecryptRaw (p_data RAW, p_key RAW)
        RETURN RAW
    IS
        l_encrypted   LONG RAW;
    BEGIN
        setkey (p_key);

        EXECUTE IMMEDIATE   'begin '
                         || '  dbms_obfuscation_toolkit.desdecrypt('
                         || '    input => :1,'
                         || '    key   => :2,'
                         || '    decrypted_data => :3);'
                         || 'end;'
            USING IN p_data, IN HEXTORAW (g_charkey), IN OUT l_encrypted;

        RETURN unpadraw (l_encrypted);
    END;
END ikis_crypt;
/