/* Formatted on 8/12/2025 6:12:50 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION IKIS_WEBPROXY.custom_hash (
    p_username   IN VARCHAR2,
    p_password   IN VARCHAR2)
    RETURN VARCHAR2
IS
    l_password   VARCHAR2 (4000);
    l_salt       VARCHAR2 (4000) := 'OQBGJFIP9DKZD2YQGKRGLF62ZNI3FM';
BEGIN
    -- This function should be wrapped, as the hash algorhythm is exposed here.
    -- You can change the value of l_salt or the method of which to call the
    -- DBMS_OBFUSCATOIN toolkit, but you much reset all of your passwords
    -- if you choose to do this.

    l_password :=
        UTL_RAW.cast_to_raw (
            DBMS_OBFUSCATION_TOOLKIT.md5 (
                input_string   =>
                       p_password
                    || SUBSTR (l_salt, 10, 13)
                    || p_username
                    || SUBSTR (l_salt, 4, 10)));
    RETURN l_password;
END;
/
