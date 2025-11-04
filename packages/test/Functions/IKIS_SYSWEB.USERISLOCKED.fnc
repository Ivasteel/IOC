/* Formatted on 8/12/2025 6:11:36 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION IKIS_SYSWEB.UserIsLocked (
    p_wu_id   w_users.wu_id%TYPE)
    RETURN VARCHAR2
IS
    l_locked   VARCHAR2 (10);
BEGIN
    BEGIN
        SELECT wu.wu_locked
          INTO l_locked
          FROM w_users wu
         WHERE wu.wu_id = p_wu_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            BEGIN
                l_locked := 'Y';
            END;
    END;

    RETURN (l_locked);
END UserIsLocked;
/


GRANT EXECUTE ON IKIS_SYSWEB.USERISLOCKED TO DNET_PROXY
/

GRANT EXECUTE ON IKIS_SYSWEB.USERISLOCKED TO IKIS_WEBPROXY
/
