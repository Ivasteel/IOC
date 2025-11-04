/* Formatted on 8/12/2025 5:56:02 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION USS_NDI.ID_ndi_service_type (p_id NUMBER)
    RETURN NUMBER
IS
    l_curval          NUMBER;
    l_instance_type   VARCHAR2 (255);
BEGIN
    l_instance_type :=
        ikis_parameter_util.GetParameter1 (
            p_par_code      => 'APP_INSTNACE_TYPE',
            p_par_ss_code   => 'IKIS_SYS');

    BEGIN
        IF p_id <> 0
        THEN
            l_curval := p_id;
        ELSE
            SELECT SQ_ID_ndi_service_type.NEXTVAL INTO l_curval FROM DUAL;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            SELECT SQ_ID_ndi_service_type.NEXTVAL INTO l_curval FROM DUAL;
    END;

    IF (p_id IS NULL OR p_id = 0) AND l_instance_type IN ('PROM', 'TEST')
    THEN
        l_curval := l_curval + 1000000;
    END IF;

    RETURN l_curval;
END;
/
