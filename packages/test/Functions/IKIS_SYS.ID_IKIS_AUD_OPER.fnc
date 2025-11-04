/* Formatted on 8/12/2025 6:10:11 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION IKIS_SYS.ID_IKIS_AUD_OPER (p_id NUMBER)
    RETURN NUMBER
IS
    l_curval   NUMBER;
BEGIN
    BEGIN
        IF p_id <> 0
        THEN
            RETURN p_id;
        ELSE
            SELECT SQ_ID_IKIS_AUD_OPER.NEXTVAL INTO l_curval FROM DUAL;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            SELECT SQ_ID_IKIS_AUD_OPER.NEXTVAL INTO l_curval FROM DUAL;
    END;

    RETURN l_curval;
END;
/
