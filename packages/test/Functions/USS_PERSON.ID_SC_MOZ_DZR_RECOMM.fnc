/* Formatted on 8/12/2025 5:57:17 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION USS_PERSON.ID_sc_moz_dzr_recomm (p_id NUMBER)
    RETURN NUMBER
IS
    l_curval          NUMBER;
    l_instance_type   VARCHAR2 (255);
BEGIN
    BEGIN
        IF p_id <> 0
        THEN
            l_curval := p_id;
        ELSE
            SELECT SQ_ID_sc_moz_dzr_recomm.NEXTVAL INTO l_curval FROM DUAL;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            SELECT SQ_ID_sc_moz_dzr_recomm.NEXTVAL INTO l_curval FROM DUAL;
    END;

    RETURN l_curval;
END;
/
