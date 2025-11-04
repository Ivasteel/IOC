/* Formatted on 8/12/2025 6:11:37 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_SYSWEB.GetSchedulerJobInfo (
    p_jb_id              IN     NUMBER,
    p_start_dt              OUT DATE,
    p_last_end              OUT DATE,
    p_state                 OUT VARCHAR2,
    p_last_oper             OUT VARCHAR2,
    p_log_date              OUT DATE,
    p_log_start_actual      OUT DATE,
    p_error                 OUT VARCHAR2,
    p_last_message          OUT VARCHAR2)
IS
    l_jb_job_name   w_jobs.jb_job_name%TYPE;
BEGIN
    -- вытаскиваем имя физ скедула
    BEGIN
        SELECT UPPER (jb_job_name)
          INTO l_jb_job_name
          FROM w_jobs jb
         WHERE jb.jb_id = p_jb_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            l_jb_job_name := NULL;
    END;

    BEGIN
        SELECT jm_message
          INTO p_last_message
          FROM (SELECT ROW_NUMBER ()
                           OVER (ORDER BY jp.jm_ts DESC, jp.jm_id DESC)
                           rn,
                       jp.jm_message
                  FROM w_jobs_protocol jp
                 WHERE jp.jm_jb = p_jb_id)
         WHERE rn = 1;
    EXCEPTION
        WHEN OTHERS
        THEN
            NULL;
    END;

    IF l_jb_job_name IS NOT NULL
    THEN
        BEGIN
            SELECT dsj.state,
                   CAST (dsj.last_start_date AS DATE),
                   CAST (dsj.start_date + dsj.last_run_duration AS DATE)
              INTO p_state, p_start_dt, p_last_end
              FROM dba_scheduler_jobs dsj
             WHERE dsj.owner || '.' || dsj.job_name = l_jb_job_name;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        BEGIN
            SELECT dsjl.operation
              INTO p_last_oper
              FROM dba_scheduler_job_log dsjl
             WHERE dsjl.owner || '.' || dsjl.job_name = l_jb_job_name;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        BEGIN
            SELECT MAX (dsjrd.errors),
                   MAX (CAST (dsjrd.log_date AS DATE)),
                   MAX (CAST (dsjrd.actual_start_date AS DATE))
              INTO p_error, p_log_date, p_log_start_actual
              FROM dba_scheduler_job_run_details dsjrd
             WHERE dsjrd.owner || '.' || dsjrd.job_name = l_jb_job_name;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;
    END IF;
END GetSchedulerJobInfo;
/
