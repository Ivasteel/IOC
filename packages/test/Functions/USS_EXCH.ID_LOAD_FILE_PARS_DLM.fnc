/* Formatted on 8/12/2025 5:54:13 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION USS_EXCH.id_load_file_pars_dlm (p_id NUMBER)
    RETURN NUMBER
IS
    l_curval   NUMBER;
BEGIN
    BEGIN
        IF p_id <> 0
        THEN
            SELECT sq_id_load_file_pars_dlm.CURRVAL INTO l_curval FROM DUAL;
        ELSE
            SELECT sq_id_load_file_pars_dlm.NEXTVAL INTO l_curval FROM DUAL;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            SELECT sq_id_load_file_pars_dlm.NEXTVAL INTO l_curval FROM DUAL;
    END;

    RETURN l_curval;
END;
/
