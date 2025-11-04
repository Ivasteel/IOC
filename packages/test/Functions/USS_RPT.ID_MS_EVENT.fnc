/* Formatted on 8/12/2025 5:59:02 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION USS_RPT.ID_ms_event (p_id NUMBER)
    RETURN NUMBER
IS
    l_curval   NUMBER;
BEGIN
    BEGIN
        IF p_id <> 0
        THEN
            l_curval := p_id;
        ELSE
            SELECT SQ_ID_ms_event.NEXTVAL INTO l_curval FROM DUAL;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            SELECT SQ_ID_ms_event.NEXTVAL INTO l_curval FROM DUAL;
    END;

    RETURN l_curval;
END;
/
