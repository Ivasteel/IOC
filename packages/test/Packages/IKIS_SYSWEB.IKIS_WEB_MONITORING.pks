/* Formatted on 8/12/2025 6:11:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.Ikis_Web_Monitoring
IS
    -- Author  : SHOSTAK
    -- Created : 2019-11-20 14:23:24
    -- Purpose :

    --==============================================================
    --           ÄÀÍÍÛÅ ÄËß ÌÎÍÈÒÎÐÈÍÃÀ ÄÈÑÏÅÒ×ÅÐÀ
    --           ÔÀÉËÎÂÎÃÎ ÊÅØÀ
    --==============================================================
    PROCEDURE Get_File_Cache_Stats (p_Condition IN CLOB, p_Result OUT CLOB);
END Ikis_Web_Monitoring;
/


/* Formatted on 8/12/2025 6:11:45 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.Ikis_Web_Monitoring
IS
    --==============================================================
    --           ÄÀÍÍÛÅ ÄËß ÌÎÍÈÒÎÐÈÍÃÀ ÄÈÑÏÅÒ×ÅÐÀ
    --           ÔÀÉËÎÂÎÃÎ ÊÅØÀ
    --==============================================================
    PROCEDURE Get_File_Cache_Stats (p_Condition IN CLOB, p_Result OUT CLOB)
    IS
        v_Files_To_Recover_Cnt      NUMBER;
        v_Files_To_Archive_Cnt      NUMBER;
        v_Files_To_Archive_Min_Dt   DATE;
        v_Expired_Exist             BOOLEAN;

        v_Is_Crytical               BOOLEAN;
        v_Is_Warning                BOOLEAN;
        v_Is_Ok                     BOOLEAN;
    BEGIN
        --Î÷åðåäü âîññòàíîâëåíèÿ ôàéëîâ
        SELECT COUNT (*)
          INTO v_Files_To_Recover_Cnt
          FROM w_File$info
         WHERE     Wf_Is_Archived = 'Y'
               AND Wf_St = 'V'
               AND Wf_Recovery_Dt IS NULL
               AND Wf_Elarch_Idn IS NOT NULL;

        --Î÷åðåäü ôàéëîâ íà àðõèâàöèþ
        SELECT MIN (Wf_Upload_Dt), COUNT (*)
          INTO v_Files_To_Archive_Min_Dt, v_Files_To_Archive_Cnt
          FROM w_File$info
         WHERE Wf_Is_Archived = 'N' AND Wf_Elarch_Idn IS NULL;

        v_Expired_Exist :=
                v_Files_To_Archive_Cnt > 0
            AND SYSDATE >=
                v_Files_To_Archive_Min_Dt + NUMTODSINTERVAL (5, 'minute');

        v_Is_Crytical := v_Expired_Exist OR v_Files_To_Recover_Cnt > 10;
        v_Is_Warning := v_Files_To_Recover_Cnt > 5;
        v_Is_Ok := NOT v_Is_Warning AND NOT v_Is_Crytical;

        p_Result :=
               'var fileCacheStats = {
      "isCrytical": '
            || CASE WHEN v_Is_Crytical THEN 'true' ELSE 'false' END
            || ',
      "isWarning": '
            || CASE WHEN v_Is_Warning THEN 'true' ELSE 'false' END
            || ',
      "filesToRecoverCount": '
            || v_Files_To_Recover_Cnt
            || ',
      "filesToArchiveCount": '
            || v_Files_To_Archive_Cnt
            || ',
      "filesToArchiveMinDate": '
            || CASE
                   WHEN v_Files_To_Archive_Min_Dt IS NOT NULL
                   THEN
                          '"'
                       || TO_CHAR (v_Files_To_Archive_Min_Dt,
                                   'dd.mm.yyyy hh24:mi:ss')
                       || '"'
                   ELSE
                       'null'
               END
            || ',
      "expiredExist": '
            || CASE WHEN v_Expired_Exist THEN 'true' ELSE 'false' END
            || ',
      "ok": '
            || CASE WHEN v_Is_Ok THEN 'true' ELSE 'false' END
            || ',
      "statsDate": "'
            || TO_CHAR (SYSDATE, 'dd.mm.yyyy hh24:mi:ss')
            || '"
  }';
    END;
END Ikis_Web_Monitoring;
/