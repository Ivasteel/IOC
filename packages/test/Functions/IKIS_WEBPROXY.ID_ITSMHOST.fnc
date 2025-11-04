/* Formatted on 8/12/2025 6:12:50 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION IKIS_WEBPROXY.ID_ITSMHOST (p_id NUMBER)
    RETURN NUMBER
IS
    l_curval   NUMBER;
BEGIN
    BEGIN
        IF p_id <> 0
        THEN
            SELECT SQ_ID_ITSMHOST.CURRVAL INTO l_curval FROM DUAL;
        ELSE
            SELECT SQ_ID_ITSMHOST.NEXTVAL INTO l_curval FROM DUAL;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            SELECT SQ_ID_ITSMHOST.NEXTVAL INTO l_curval FROM DUAL;
    END;

    RETURN l_curval;
END;
/
