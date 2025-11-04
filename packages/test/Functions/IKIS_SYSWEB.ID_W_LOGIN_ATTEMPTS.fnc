/* Formatted on 8/12/2025 6:11:35 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION IKIS_SYSWEB.ID_W_LOGIN_ATTEMPTS (p_id NUMBER)
    RETURN NUMBER
IS
    l_curval   NUMBER;
BEGIN
    BEGIN
        IF NVL (p_id, 0) = 0
        THEN
            SELECT SQ_ID_W_LOGIN_ATTEMPTS.NEXTVAL INTO l_curval FROM DUAL;
        ELSE
            l_curval := p_id;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            SELECT SQ_ID_W_LOGIN_ATTEMPTS.NEXTVAL INTO l_curval FROM DUAL;
    END;

    RETURN l_curval;
END;
/
