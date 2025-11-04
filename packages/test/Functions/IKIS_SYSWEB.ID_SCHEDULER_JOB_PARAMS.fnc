/* Formatted on 8/12/2025 6:11:35 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION IKIS_SYSWEB.id_scheduler_job_params (
    p_sjp_id   IN NUMBER)
    RETURN NUMBER
IS
    l_curval   NUMBER;
BEGIN
    BEGIN
        IF p_sjp_id <> 0
        THEN
            SELECT Sq_Id_Scheduler_Job_Params.CURRVAL INTO l_curval FROM DUAL;
        ELSE
            SELECT Sq_Id_Scheduler_Job_Params.NEXTVAL INTO l_curval FROM DUAL;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            SELECT Sq_Id_Scheduler_Job_Params.NEXTVAL INTO l_curval FROM DUAL;
    END;

    RETURN l_curval;
END id_scheduler_job_params;
/
