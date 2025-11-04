/* Formatted on 8/12/2025 6:10:11 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION IKIS_SYS.testpwd (username   IN VARCHAR2,
                                             password   IN VARCHAR2)
    RETURN CHAR
--authid current_user
IS
    --
    raw_key    RAW (128) := HEXTORAW ('0123456789ABCDEF');
    --
    raw_ip     RAW (128);
    pwd_hash   VARCHAR2 (16);

    --
    CURSOR c_user (cp_name IN VARCHAR2)
    IS
        SELECT password
          FROM sys.user$
         WHERE password IS NOT NULL AND name = cp_name;

    --
    PROCEDURE unicode_str (userpwd IN VARCHAR2, UNISTR OUT RAW)
    IS
        enc_str     VARCHAR2 (124) := '';
        tot_len     NUMBER;
        curr_char   CHAR (1);
        padd_len    NUMBER;
        ch          CHAR (1);
        mod_len     NUMBER;
        debugp      VARCHAR2 (256);
    BEGIN
        tot_len := LENGTH (userpwd);

        FOR i IN 1 .. tot_len
        LOOP
            curr_char := SUBSTR (userpwd, i, 1);
            enc_str := enc_str || CHR (0) || curr_char;
        END LOOP;

        mod_len := MOD ((tot_len * 2), 8);

        IF (mod_len = 0)
        THEN
            padd_len := 0;
        ELSE
            padd_len := 8 - mod_len;
        END IF;

        FOR i IN 1 .. padd_len
        LOOP
            enc_str := enc_str || CHR (0);
        END LOOP;

        UNISTR := UTL_RAW.cast_to_raw (enc_str);
    END;

    --
    FUNCTION crack (userpwd IN RAW)
        RETURN VARCHAR2
    IS
        enc_raw         RAW (2048);
        --
        raw_key2        RAW (128);
        pwd_hash        RAW (2048);
        --
        hexstr          VARCHAR2 (2048);
        len             NUMBER;
        password_hash   VARCHAR2 (16);
    BEGIN
        DBMS_OBFUSCATION_TOOLKIT.DESEncrypt (input            => userpwd,
                                             key              => raw_key,
                                             encrypted_data   => enc_raw);
        hexstr := RAWTOHEX (enc_raw);
        len := LENGTH (hexstr);
        raw_key2 := HEXTORAW (SUBSTR (hexstr, (len - 16 + 1), 16));
        DBMS_OBFUSCATION_TOOLKIT.DESEncrypt (input            => userpwd,
                                             key              => raw_key2,
                                             encrypted_data   => pwd_hash);
        hexstr := HEXTORAW (pwd_hash);
        len := LENGTH (hexstr);
        password_hash := SUBSTR (hexstr, (len - 16 + 1), 16);
        RETURN (password_hash);
    END;
BEGIN
    OPEN c_user (UPPER (username));

    FETCH c_user INTO pwd_hash;

    CLOSE c_user;

    unicode_str (UPPER (username) || UPPER (password), raw_ip);

    IF (pwd_hash = crack (raw_ip))
    THEN
        RETURN ('Y');
    ELSE
        RETURN ('N');
    END IF;
END;
/
