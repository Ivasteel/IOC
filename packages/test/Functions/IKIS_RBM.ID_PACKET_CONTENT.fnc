/* Formatted on 8/12/2025 6:10:54 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION IKIS_RBM.ID_PACKET_CONTENT (p_id NUMBER)
    RETURN NUMBER
IS
    l_curval   NUMBER;
BEGIN
    BEGIN
        IF p_id <> 0
        THEN
            SELECT SQ_ID_PACKET_CONTENT.CURRVAL INTO l_curval FROM DUAL;
        ELSE
            SELECT SQ_ID_PACKET_CONTENT.NEXTVAL INTO l_curval FROM DUAL;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            SELECT SQ_ID_PACKET_CONTENT.NEXTVAL INTO l_curval FROM DUAL;
    END;

    RETURN l_curval;
END;
/
