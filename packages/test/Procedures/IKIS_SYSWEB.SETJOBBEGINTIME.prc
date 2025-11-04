/* Formatted on 8/12/2025 6:11:37 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_SYSWEB.SetJobBeginTime (
    p_wjb_id      IN     NUMBER,
    l_startdate   IN OUT DATE,
    p_result         OUT NUMBER)
IS
    l_startdate_max   DATE;
    l_jb_wjt          w_job_type.wjt_id%TYPE;
    l_jb_status       w_jobs.jb_status%TYPE;
    l_ShiftSec        NUMBER := 5;
BEGIN
    -- узнаем тип джоба и статус
    SELECT jb.jb_wjt, jb.jb_status
      INTO l_jb_wjt, l_jb_status
      FROM w_jobs jb
     WHERE jb.jb_id = p_wjb_id;

    IF (l_jb_status <> ikis_const.V_DDN_WJB_ST_ERROR)
    THEN
        -- корегування часу з урахуванням черги
        SELECT MAX (jb.jb_start_dt)
          INTO l_startdate_max
          FROM w_jobs jb
         WHERE     jb.jb_wjt = l_jb_wjt
               AND jb.jb_status IN (ikis_const.v_ddn_wjb_st_enqueue)
               AND jb.jb_start_dt >= l_startdate;

        IF l_startdate_max IS NOT NULL
        THEN
            l_startdate := l_startdate_max + l_ShiftSec / (24 * 60 * 60);
        END IF;

        -- проставляем время старта джоба
        UPDATE w_jobs
           SET jb_start_dt = l_startdate
         WHERE jb_id = p_wjb_id;

        p_result := 1;
    ELSE
        p_result := 0;
    END IF;
EXCEPTION
    WHEN OTHERS
    THEN
        raise_application_error (
            -20000,
               'IKIS_SYSWEB.SetJobBeginTime: '
            || CHR (10)
            || DBMS_UTILITY.format_error_stack
            || DBMS_UTILITY.format_error_backtrace);
END SetJobBeginTime;
/
