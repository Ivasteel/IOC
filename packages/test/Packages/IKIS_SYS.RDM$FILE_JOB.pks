/* Formatted on 8/12/2025 6:10:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.RDM$FILE_JOB
IS
    PROCEDURE INS$FILE_JOB (
        P_FJ_ID            OUT FILE_JOB.FJ_ID%TYPE,
        P_FJ_FT                FILE_JOB.FJ_FT%TYPE,
        P_FJ_JOB               FILE_JOB.FJ_JOB%TYPE,
        P_FJ_START_DT_DT       FILE_JOB.FJ_START_DT%TYPE,
        P_FJ_STOP_DT           FILE_JOB.FJ_STOP_DT%TYPE,
        P_FJ_ST                FILE_JOB.FJ_ST%TYPE,
        P_FJ_CREATE_DT         FILE_JOB.FJ_CREATE_DT%TYPE,
        P_FJ_CREATE_USR        FILE_JOB.FJ_CREATE_USR%TYPE);

    PROCEDURE UPD$FILE_JOB (P_FJ_ID           FILE_JOB.FJ_ID%TYPE,
                            P_FJ_FT           FILE_JOB.FJ_FT%TYPE,
                            P_FJ_JOB          FILE_JOB.FJ_JOB%TYPE,
                            P_FJ_START_DT     FILE_JOB.FJ_START_DT%TYPE,
                            P_FJ_STOP_DT      FILE_JOB.FJ_STOP_DT%TYPE,
                            P_FJ_ST           FILE_JOB.FJ_ST%TYPE,
                            P_FJ_CREATE_DT    FILE_JOB.FJ_CREATE_DT%TYPE,
                            P_FJ_CREATE_USR   FILE_JOB.FJ_CREATE_USR%TYPE);

    PROCEDURE DEL$FILE_JOB (P_FJ_ID FILE_JOB.FJ_ID%TYPE);
END RDM$FILE_JOB;
/


CREATE OR REPLACE PUBLIC SYNONYM RDM$FILE_JOB FOR IKIS_SYS.RDM$FILE_JOB
/


GRANT EXECUTE ON IKIS_SYS.RDM$FILE_JOB TO II01RC_IKIS_JOB
/

GRANT EXECUTE ON IKIS_SYS.RDM$FILE_JOB TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.RDM$FILE_JOB TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.RDM$FILE_JOB TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.RDM$FILE_JOB TO IKIS_SYSWEB WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.RDM$FILE_JOB TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.RDM$FILE_JOB TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.RDM$FILE_JOB TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.RDM$FILE_JOB TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.RDM$FILE_JOB TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.RDM$FILE_JOB TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.RDM$FILE_JOB TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.RDM$FILE_JOB TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.RDM$FILE_JOB TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:10:05 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.RDM$FILE_JOB
IS
    -- Messages for category: IKIS_FILE_JOB_PKG
    msgEmptyAtribut          NUMBER := 98;
    msgInvalidFileType       NUMBER := 410;
    msgReqModeLock           NUMBER := 411;
    msgInvalidParTp          NUMBER := 412;
    msgErroSubmitJob         NUMBER := 414;
    msgErrorExec             NUMBER := 415;
    msgInvalidStForce        NUMBER := 416;
    msgDelErr                NUMBER := 418;
    msgErrChPar              NUMBER := 426;
    msgErrChSt               NUMBER := 427;
    msgSaveUndefTaskType     NUMBER := 1083;
    msgCantModifyNotOwnJob   NUMBER := 1221;
    msgInvStatus4Del         NUMBER := 1655;



    PROCEDURE INS$FILE_JOB (
        P_FJ_ID            OUT FILE_JOB.FJ_ID%TYPE,
        P_FJ_FT                FILE_JOB.FJ_FT%TYPE,
        P_FJ_JOB               FILE_JOB.FJ_JOB%TYPE,
        P_FJ_START_DT_DT       FILE_JOB.FJ_START_DT%TYPE,
        P_FJ_STOP_DT           FILE_JOB.FJ_STOP_DT%TYPE,
        P_FJ_ST                FILE_JOB.FJ_ST%TYPE,
        P_FJ_CREATE_DT         FILE_JOB.FJ_CREATE_DT%TYPE,
        P_FJ_CREATE_USR        FILE_JOB.FJ_CREATE_USR%TYPE)
    IS
    BEGIN
        debug.f ('Start procedure');

        INSERT INTO file_job (fj_id,
                              fj_ft,
                              fj_job,
                              fj_start_dt,
                              fj_stop_dt,
                              fj_st,
                              fj_create_dt,
                              fj_create_usr)
             VALUES (0,
                     P_FJ_FT,
                     NULL,
                     P_FJ_START_DT_DT,
                     P_FJ_STOP_DT,
                     ikis_const.v_dds_job_st_new,
                     SYSDATE,
                     getcurrentuserid)
          RETURNING fj_id
               INTO P_FJ_ID;

        --Переливка дефолтных значений параметров для задачи
        IF P_FJ_FT IS NOT NULL
        THEN
            INSERT INTO file_par_value (ftpv_fj, ftpv_ftp, ftpv_value)
                SELECT P_FJ_ID, x.ftp_id, x.ftp_defvalue
                  FROM file_type_parameter x
                 WHERE x.ftp_ft = P_FJ_FT;
        END IF;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'RDM$FILE_JOB.INS$FILE_JOB with ',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE UPD$FILE_JOB (P_FJ_ID           FILE_JOB.FJ_ID%TYPE,
                            P_FJ_FT           FILE_JOB.FJ_FT%TYPE,
                            P_FJ_JOB          FILE_JOB.FJ_JOB%TYPE,
                            P_FJ_START_DT     FILE_JOB.FJ_START_DT%TYPE,
                            P_FJ_STOP_DT      FILE_JOB.FJ_STOP_DT%TYPE,
                            P_FJ_ST           FILE_JOB.FJ_ST%TYPE,
                            P_FJ_CREATE_DT    FILE_JOB.FJ_CREATE_DT%TYPE,
                            P_FJ_CREATE_USR   FILE_JOB.FJ_CREATE_USR%TYPE)
    IS
        l_fj_ft   FILE_JOB.FJ_FT%TYPE;
    BEGIN
        debug.f ('Start procedure');

        SELECT fj_ft
          INTO l_fj_ft
          FROM FILE_JOB
         WHERE fj_id = P_FJ_ID;

        --Ежели меняем тип задачи, то чистим список параметров
        IF NOT (NVL (l_fj_ft, -1) = NVL (P_FJ_FT, -1))
        THEN
            DELETE FROM file_par_value
                  WHERE ftpv_fj = P_FJ_ID;

            --Переливка дефолтных значений параметров для задачи
            IF P_FJ_FT IS NOT NULL
            THEN
                INSERT INTO file_par_value (ftpv_fj, ftpv_ftp, ftpv_value)
                    SELECT P_FJ_ID, x.ftp_id, x.ftp_defvalue
                      FROM file_type_parameter x
                     WHERE x.ftp_ft = P_FJ_FT;
            END IF;
        END IF;

        UPDATE FILE_JOB a
           SET a.fj_ft = P_FJ_FT
         WHERE a.fj_id = P_FJ_ID;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'RDM$FILE_JOB.UPD$FILE_JOB with ',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE DEL$FILE_JOB (P_FJ_ID FILE_JOB.FJ_ID%TYPE)
    IS
        l_job             file_job%ROWTYPE;
        exInvStatus4Del   EXCEPTION;
        exJobIsRunning    EXCEPTION;
        l_st              dic_dv.dic_sname%TYPE;
    BEGIN
        debug.f ('Start procedure');

        SELECT *
          INTO l_job
          FROM file_job
         WHERE fj_id = p_fj_id;

        IF l_job.fj_st IN (ikis_const.v_dds_job_st_executing)
        THEN
            RAISE exJobIsRunning;
        END IF;

        IF l_job.fj_st IN
               (ikis_const.v_dds_job_st_inqueue,
                ikis_const.v_dds_job_st_waitnext,
                ikis_const.v_dds_job_st_disable)
        THEN
            --    DBMS_JOB.REMOVE (l_job.fj_job);
            --    IKIS_JOB_CONTROL.Remove_Job(P_FJ_ID);
            --    delete from file_par_value where file_par_value.ftpv_fj=P_FJ_ID;
            --    delete from file_job_exception where file_job_exception.fje_fj=P_FJ_ID;
            --    delete from file_job where file_job.fj_id=P_FJ_ID;
            --raise_application_error(-20000,'Неможливо видалити в ствні "В черзі", "Очікування наступного" або "Заборонено"');
            CASE l_job.fj_st
                WHEN ikis_const.v_dds_job_st_inqueue
                THEN
                    l_st := ikis_const.txt_v_dds_job_st_inqueue;
                WHEN ikis_const.v_dds_job_st_waitnext
                THEN
                    l_st := ikis_const.txt_v_dds_job_st_waitnext;
                WHEN ikis_const.v_dds_job_st_disable
                THEN
                    l_st := ikis_const.txt_v_dds_job_st_disable;
                ELSE
                    NULL;
            END CASE;

            RAISE exInvStatus4Del;
        END IF;

        IF l_job.fj_st IN (ikis_const.v_dds_job_st_new,
                           ikis_const.v_dds_job_st_complite,
                           ikis_const.v_dds_job_st_removed,
                           ikis_const.v_dds_job_st_errorexec)
        THEN
            DELETE FROM file_par_value
                  WHERE file_par_value.ftpv_fj = P_FJ_ID;

            DELETE FROM file_job_exception
                  WHERE file_job_exception.fje_fj = P_FJ_ID;

            DELETE FROM file_job
                  WHERE file_job.fj_id = P_FJ_ID;
        END IF;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN exInvStatus4Del
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgInvStatus4Del, l_st));
        WHEN exJobIsRunning
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgDelErr));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'RDM$FILE_JOB.DEL$FILE_JOB with ',
                    CHR (10) || SQLERRM));
    END;
END RDM$FILE_JOB;
/