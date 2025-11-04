/* Formatted on 8/12/2025 5:54:20 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_EXCH.LOAD_FILE_JBL
IS
    -- info: Запис даних в таблицю ikis_prson.load_file_data_jobs
    PROCEDURE InsertJobLog (p_lfd   load_file_data.lfd_id%TYPE,
                            p_jb    load_file_data_jobs.lfdj_jb%TYPE);

    -- info: Запис даних в таблицю ikis_prson.load_file_data_jobs
    FUNCTION ModifyJobLog (p_jb load_file_data_jobs.lfdj_jb%TYPE)
        RETURN load_file_data_jobs.lfdj_jb_st%TYPE;

    -- info: процедура получения актуального статуса по заданию
    FUNCTION GetJobState (p_jb load_file_data_jobs.lfdj_jb%TYPE)
        RETURN load_file_data_jobs.lfdj_jb_st%TYPE;

    -- info: процедура обработки состояний всех незакончившихся заданий
    PROCEDURE ControlJobs;
END LOAD_FILE_JBL;
/


/* Formatted on 8/12/2025 5:54:20 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_EXCH.LOAD_FILE_JBL
IS
    -- info: Запис даних в таблицю ikis_prson.load_file_data_jobs
    PROCEDURE InsertJobLog (p_lfd   load_file_data.lfd_id%TYPE,
                            p_jb    load_file_data_jobs.lfdj_jb%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO load_file_data_jobs (lfdj_lfd,
                                         lfdj_jb,
                                         lfdj_jb_wjt,
                                         lfdj_jb_name,
                                         lfdj_jb_start,
                                         lfdj_jb_end,
                                         lfdj_jb_st)
            SELECT p_lfd,
                   jb.jb_id,
                   jb.jb_wjt,
                   jb.jb_job_name,
                   jb.jb_start_dt,
                   jb.jb_stop_dt,
                   jb.jb_status
              FROM ikis_sysweb.v_w_jobs jb
             WHERE jb_id = p_jb;

        COMMIT;
    END;

    -- info: Запис даних в таблицю ikis_prson.load_file_data_jobs
    FUNCTION ModifyJobLog (p_jb load_file_data_jobs.lfdj_jb%TYPE)
        RETURN load_file_data_jobs.lfdj_jb_st%TYPE
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_result   load_file_data_jobs.lfdj_jb_st%TYPE;
    BEGIN
        FOR rec IN (SELECT jb.jb_id,
                           jb.jb_start_dt,
                           jb.jb_stop_dt,
                           jb.jb_status
                      FROM ikis_sysweb.v_w_jobs jb
                     WHERE jb_id = p_jb)
        LOOP
               UPDATE load_file_data_jobs lfdj
                  SET lfdj.lfdj_jb_start = rec.jb_start_dt,
                      lfdj.lfdj_jb_end = rec.jb_stop_dt,
                      lfdj.lfdj_jb_st = rec.jb_status,
                      lfdj.lfdj_st =
                          CASE
                              WHEN rec.jb_status IN ('ERROR', 'ENDED') THEN 'H'
                              ELSE lfdj.lfdj_st
                          END
                WHERE     lfdj.lfdj_jb = rec.jb_id
                      AND lfdj.lfdj_st = 'A'
                      AND (   COALESCE (lfdj.lfdj_jb_start,
                                        TO_DATE ('31.12.3000', 'dd.mm.yyyy')) <>
                              COALESCE (rec.jb_start_dt,
                                        TO_DATE ('31.12.3000', 'dd.mm.yyyy'))
                           OR COALESCE (lfdj.lfdj_jb_end,
                                        TO_DATE ('31.12.3000', 'dd.mm.yyyy')) <>
                              COALESCE (rec.jb_stop_dt,
                                        TO_DATE ('31.12.3000', 'dd.mm.yyyy'))
                           OR COALESCE (lfdj.lfdj_jb_st, '-1') <>
                              COALESCE (rec.jb_status, '-1'))
            RETURNING lfdj.lfdj_jb_st
                 INTO l_result;
        END LOOP;

        COMMIT;
        RETURN l_result;
    END;

    -- info: процедура установки текущего работающего задания
    -- parameters: идентификатор файла и идентификатор текущего задания
    FUNCTION GetJobState (p_jb load_file_data_jobs.lfdj_jb%TYPE)
        RETURN load_file_data_jobs.lfdj_jb_st%TYPE
    IS
    BEGIN
        RETURN ModifyJobLog (p_jb);
    END;

    -- info: процедура обработки состояний всех незакончившихся заданий
    -- parameters: -
    PROCEDURE ControlJobs
    IS
        l_jb_st   load_file_data_jobs.lfdj_jb_st%TYPE;
    BEGIN
        FOR rec IN (SELECT jb.lfdj_jb
                      FROM load_file_data_jobs jb
                     WHERE jb.lfdj_jb_st NOT IN ('ERROR', 'ENDED'))
        LOOP
            l_jb_st := GetJobState (rec.lfdj_jb);
        END LOOP;
    END;
BEGIN
    NULL;
END LOAD_FILE_JBL;
/