/* Formatted on 8/12/2025 5:46:29 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION USS_CEA.ID_file_content (p_id NUMBER)
    RETURN NUMBER
IS
    l_curval   NUMBER;
BEGIN
    BEGIN
        IF p_id <> 0
        THEN
            l_curval := p_id;
        ELSE
            SELECT SQ_ID_file_content.NEXTVAL INTO l_curval FROM DUAL;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            SELECT SQ_ID_file_content.NEXTVAL INTO l_curval FROM DUAL;
    END;

    RETURN l_curval;
END;
/
