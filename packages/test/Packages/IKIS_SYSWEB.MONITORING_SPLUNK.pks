/* Formatted on 8/12/2025 6:11:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.Monitoring_Splunk
IS
    -- Author  : SHOSTAK
    -- Created : 2019-11-28 15:27:21
    -- Purpose :

    ----------------------------------------------------
    --ÌÎÍÈÒÎÐÈÍÃ ÔÀÉËÎÂÎÃÎ ÊÅØÀ
    ----------------------------------------------------
    FUNCTION Get_Stats_File_Cache
        RETURN NCLOB;

    ----------------------------------------------------
    --ÌÎÍÈÒÎÐÈÍÃ ÀÓÒÅÍÒÈÔÈÊÀÖÈÈ ÏÎ ÅÖÏ
    ----------------------------------------------------
    FUNCTION Get_Stats_Auth_Sign
        RETURN NCLOB;
END Monitoring_Splunk;
/


/* Formatted on 8/12/2025 6:11:45 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.Monitoring_Splunk
IS
    ----------------------------------------------------
    --ÌÎÍÈÒÎÐÈÍÃ ÔÀÉËÎÂÎÃÎ ÊÅØÀ
    ----------------------------------------------------
    FUNCTION Get_Stats_File_Cache
        RETURN NCLOB
    IS
        v_Files_To_Recover_Cnt      NUMBER;
        v_Files_To_Archive_Cnt      NUMBER;
        v_Files_To_Archive_Min_Dt   DATE;
        v_Expired_Exist             BOOLEAN;

        v_Is_Crytical               BOOLEAN;
        v_Is_Warning                BOOLEAN;
        v_Status                    NUMBER;
        v_Msg                       CLOB := '';
        v_Result                    CLOB;

        c_St_Ok            CONSTANT NUMBER := 0;
        c_St_Warning       CONSTANT NUMBER := 1;
        c_St_Crytical      CONSTANT NUMBER := 2;
        c_Msg_Tp_Counter   CONSTANT VARCHAR2 (10) := 'counter';
        c_Msg_Tp_Text      CONSTANT VARCHAR2 (10) := 'text';

        PROCEDURE Add_Row_Json (p_Row_St   NUMBER,
                                p_Type     VARCHAR2,
                                p_Text     VARCHAR2,
                                p_Count    VARCHAR2)
        IS
        BEGIN
            v_Msg :=
                   v_Msg
                || '{"rowst": "'
                || p_Row_St
                || '", "type": "'
                || p_Type
                || '", "text": "'
                || p_Text
                || '", "count": "'
                || p_Count
                || '"},';
        END;
    BEGIN
        --Î÷åðåäü âîññòàíîâëåíèÿ ôàéëîâ
        SELECT COUNT (*)
          INTO v_Files_To_Recover_Cnt
          FROM w_File$info
         WHERE     Wf_Is_Archived = 'Y'
               AND Wf_St = 'V'
               AND Wf_Recovery_Dt IS NULL
               AND Wf_Elarch_Idn IS NOT NULL;

        IF v_Files_To_Recover_Cnt > 5
        THEN
            Add_Row_Json (
                p_Row_St   =>
                    CASE
                        WHEN v_Files_To_Recover_Cnt > 10 THEN c_St_Crytical
                        ELSE c_St_Warning
                    END,
                p_Type    => c_Msg_Tp_Counter,
                p_Text    => 'Ôàéë³â ó ÷åðç³ íà â³äíîâëåííÿ',
                p_Count   => v_Files_To_Recover_Cnt);
        END IF;

        --Î÷åðåäü ôàéëîâ íà àðõèâàöèþ
        SELECT MIN (Wf_Upload_Dt), COUNT (*)
          INTO v_Files_To_Archive_Min_Dt, v_Files_To_Archive_Cnt
          FROM w_File$info
         WHERE Wf_Is_Archived = 'N' AND Wf_Elarch_Idn IS NULL;

        v_Expired_Exist :=
                v_Files_To_Archive_Cnt > 0
            AND SYSDATE >=
                v_Files_To_Archive_Min_Dt + NUMTODSINTERVAL (5, 'minute');

        Add_Row_Json (
            p_Row_St   =>
                CASE
                    WHEN v_Expired_Exist THEN c_St_Crytical
                    WHEN v_Files_To_Archive_Cnt <= 10 THEN c_St_Ok
                    WHEN v_Files_To_Archive_Cnt <= 50 THEN c_St_Warning
                    ELSE c_St_Crytical
                END,
            p_Type    => c_Msg_Tp_Counter,
            p_Text    => 'Ôàéë³â ó ÷åðç³ íà àðõ³âàö³þ',
            p_Count   => v_Files_To_Archive_Cnt);

        IF v_Expired_Exist
        THEN
            Add_Row_Json (
                p_Row_St   => c_St_Crytical,
                p_Type     => c_Msg_Tp_Text,
                p_Text     =>
                       'Ïðîñòîé ÷åðãè àðõ³âàö³¿ ç '
                    || TO_CHAR (v_Files_To_Archive_Min_Dt,
                                'dd.mm.yyyy hh24:mi:ss'),
                p_Count    => '');
        END IF;

        v_Is_Crytical := v_Expired_Exist OR v_Files_To_Recover_Cnt > 10;

        v_Is_Warning := v_Files_To_Recover_Cnt > 5;

        v_Status :=
            CASE
                WHEN v_Is_Crytical THEN c_St_Crytical
                WHEN v_Is_Warning THEN c_St_Warning
                ELSE c_St_Ok
            END;

        v_Msg := TRIM (TRAILING ',' FROM v_Msg);
        v_Result :=
               '{"status": '
            || v_Status
            || ', "date": "'
            || TO_CHAR (SYSDATE, 'dd.mm.yyyy hh24:mi:ss')
            || '", "msg": ['
            || v_Msg
            || ']}';

        RETURN v_Result;
    END;

    ----------------------------------------------------
    --ÌÎÍÈÒÎÐÈÍÃ ÀÓÒÅÍÒÈÔÈÊÀÖÈÈ ÏÎ ÅÖÏ
    ----------------------------------------------------
    FUNCTION Get_Stats_Auth_Sign
        RETURN NCLOB
    IS
        v_Denied_Cnt                NUMBER;
        v_Expired_Cnt               NUMBER;
        v_Expire_Min_Dt             DATE;
        v_Today_Cnt                 NUMBER;
        v_Is_Crytical               BOOLEAN;
        v_Status                    NUMBER;
        v_Msg                       CLOB := '';
        v_Result                    CLOB;

        c_St_Ok            CONSTANT NUMBER := 0;
        c_St_Crytical      CONSTANT NUMBER := 2;
        c_Msg_Tp_Counter   CONSTANT VARCHAR2 (10) := 'counter';
        c_Msg_Tp_Text      CONSTANT VARCHAR2 (10) := 'text';

        PROCEDURE Add_Row_Json (p_Row_St   NUMBER,
                                p_Type     VARCHAR2,
                                p_Text     VARCHAR2,
                                p_Count    VARCHAR2)
        IS
        BEGIN
            v_Msg :=
                   v_Msg
                || '{"rowst": "'
                || p_Row_St
                || '", "type": "'
                || p_Type
                || '", "text": "'
                || p_Text
                || '", "count": "'
                || p_Count
                || '"},';
        END;
    BEGIN
        --Îïðåäåëÿåì êîë-âî îòêëîíåííûõ ïîïûòîê
        SELECT COUNT (*)
          INTO v_Denied_Cnt
          FROM w_Login_Attempts a
         WHERE     a.Wla_As = Ikis_Id_Auth.c_Wla_St_Denied
               AND a.Wla_Create_Dt >= TRUNC (SYSDATE) - 3;

        IF v_Denied_Cnt > 0
        THEN
            Add_Row_Json (p_Row_St   => c_St_Crytical,
                          p_Type     => c_Msg_Tp_Counter,
                          p_Text     => 'Â³äõèëåíî ñïðîá ëîã³íà',
                          p_Count    => v_Denied_Cnt);
        END IF;

        --Îïðåäåëÿåì êîë-âî ïîïûòîê íå îáðàáîòàííûõ âîâðåìÿ
        SELECT COUNT (*), MIN (a.Wla_Create_Dt)
          INTO v_Expired_Cnt, v_Expire_Min_Dt
          FROM Ikis_Sysweb.w_Login_Attempts a
         WHERE     a.Wla_As = -1
               AND a.Wla_Login_Tp IN ('SIGN', 'CARD')
               AND SYSDATE > a.Wla_Create_Dt + INTERVAL '5' MINUTE;

        IF v_Expired_Cnt > 0
        THEN
            Add_Row_Json (
                p_Row_St   => c_St_Crytical,
                p_Type     => c_Msg_Tp_Text,
                p_Text     =>
                       'Ïðîñòîé ÷åðãè îáðîêè ç '
                    || TO_CHAR (v_Expire_Min_Dt, 'dd.mm.yyyy hh24:mi:ss'),
                p_Count    => '');
        END IF;

        --Îïðåäåëÿåì êîë-âî âõîäîâ ïî ÅÖÏ çà äåíü
        SELECT COUNT (*)
          INTO v_Today_Cnt
          FROM w_Login_Attempts a
         WHERE     a.Wla_As = Ikis_Id_Auth.c_Wla_St_Used
               AND a.Wla_Login_Tp IN ('SIGN', 'CARD')
               AND a.Wla_Create_Dt > TRUNC (SYSDATE);

        Add_Row_Json (p_Row_St   => c_St_Ok,
                      p_Type     => c_Msg_Tp_Counter,
                      p_Text     => 'Âõîä³â çà ÅÖÏ ñüîãîäí³',
                      p_Count    => v_Today_Cnt);

        v_Is_Crytical := v_Denied_Cnt > 0 OR v_Expired_Cnt > 0;

        v_Status :=
            CASE WHEN v_Is_Crytical THEN c_St_Crytical ELSE c_St_Ok END;

        v_Msg := TRIM (TRAILING ',' FROM v_Msg);
        v_Result :=
               '{"status": '
            || v_Status
            || ', "date": "'
            || TO_CHAR (SYSDATE, 'dd.mm.yyyy hh24:mi:ss')
            || '", "msg": ['
            || v_Msg
            || ']}';

        RETURN v_Result;
    END;
END Monitoring_Splunk;
/