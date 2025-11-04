/* Formatted on 8/12/2025 6:11:37 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_SYSWEB.purge_wsj (p_day NUMBER)
IS
BEGIN
    FOR i
        IN (SELECT job_name
              FROM all_scheduler_jobs
             WHERE    (    STATE IN ('SUCCEEDED')
                       AND owner = 'IKIS_SYSWEB'
                       AND job_name LIKE 'WSJ$%'
                       AND SCHEDULE_TYPE = 'ONCE'
                       AND LAST_START_DATE < (SYSDATE - p_day))
                   OR (    STATE IN ('DISABLED')
                       AND owner = 'IKIS_SYSWEB'
                       AND job_name LIKE 'WSJ$%'
                       AND SCHEDULE_TYPE = 'ONCE'))
    LOOP
        DBMS_OUTPUT.put_line ('Purge JOB: ' || i.job_name);
        DBMS_SCHEDULER.DROP_JOB (job_name => i.job_name);
    END LOOP;

    COMMIT;
END;
/
