/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_CHANGES_UTL
IS
    -- Author  : RYABA
    -- Created : 25.12.2003 14:31:58
    g_EMPTY_FIELD   VARCHAR2 (10);

    g_log_state     BOOLEAN := TRUE;

    PROCEDURE Change (p_ess_ead     IN ikis_changes.ich_ead%TYPE,
                      p_ess_id      IN ikis_changes.ich_ess_id%TYPE,
                      p_operation   IN ikis_changes.ich_ao%TYPE,
                      p_value       IN VARCHAR2 := NULL);

    PROCEDURE SetAuditChangesState (p_pwd     IN VARCHAR2,
                                    p_state   IN BOOLEAN := TRUE);

    PROCEDURE Change_at (p_ess_ead     IN ikis_changes.ich_ead%TYPE,
                         p_ess_id      IN ikis_changes.ich_ess_id%TYPE,
                         p_operation   IN ikis_changes.ich_ao%TYPE,
                         p_value       IN VARCHAR2 := NULL);

    PROCEDURE ChangeEssCode (p_ess_code    IN VARCHAR2,
                             p_ess_id      IN ikis_changes.ich_ess_id%TYPE,
                             p_operation   IN ikis_changes.ich_ao%TYPE,
                             p_value       IN VARCHAR2 := NULL);

    FUNCTION GetChangeValue (p_in IN VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE State_of_change;

    PROCEDURE SetLogState (p_state BOOLEAN:= TRUE);

    PROCEDURE LoadChange (p_user        IN ikis_changes.ich_user%TYPE,
                          p_ess_ead     IN ikis_changes.ich_ead%TYPE,
                          p_ess_id      IN ikis_changes.ich_ess_id%TYPE,
                          p_operation   IN ikis_changes.ich_ao%TYPE);

    PROCEDURE SaveData (p_actid   ikis_utait.ut_actid%TYPE,
                        p_ibj     ikis_utait.ut_obj%TYPE,
                        p_ibjid   ikis_utait.ut_ibjid%TYPE,
                        p_par1    ikis_utait.ut_par1%TYPE DEFAULT NULL,
                        p_par2    ikis_utait.ut_par2%TYPE DEFAULT NULL);

    FUNCTION GetSessionParam (p_name IN VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE UpdateDeleteError;
END IKIS_CHANGES_UTL;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_CHANGES_UTL FOR IKIS_SYS.IKIS_CHANGES_UTL
/


GRANT EXECUTE ON IKIS_SYS.IKIS_CHANGES_UTL TO II01_ROOT_ROLE
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CHANGES_UTL TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CHANGES_UTL TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CHANGES_UTL TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CHANGES_UTL TO IKIS_SYSWEB WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CHANGES_UTL TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CHANGES_UTL TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CHANGES_UTL TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CHANGES_UTL TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CHANGES_UTL TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CHANGES_UTL TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CHANGES_UTL TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CHANGES_UTL TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_CHANGES_UTL TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:10:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_CHANGES_UTL
IS
    -- Purpose : аудит измененй БД
    g_session_data                ikis_utait%ROWTYPE;

    msgChangeDelete               NUMBER := 1846;
    msgNO_UPDATE_OR_DELETE        NUMBER := 3413;
    --msgNO_IKIS_USER_FOUND               number := 764;
    msgAuditPwdError              NUMBER := 3739;

    g_Audit_changes               BOOLEAN := TRUE;
    c_Audit_pwd                   VARCHAR2 (100) := 'IKIS_AUDIT';
    c_pwd                         VARCHAR2 (8)
        := RPAD (TRIM (BOTH '0' FROM IKIS_COMMON.GetAP_IKIS_OPFU),
                 8,
                 TRIM (BOTH '0' FROM IKIS_COMMON.GetAP_IKIS_OPFU));

    g_USE_GLOBAL_CHANGE_SETTING   CHAR (1);
    g_USER_NAME                   VARCHAR2 (250);


    --Процедура вносить запис про зміни:
    --Параметри:код суттєвості (визначається по довіднику)
    --          ІД суттєвості (ІД таблиці)
    --          Тип виконаної операції
    --          Значення зміни
    PROCEDURE Change (p_ess_ead     IN ikis_changes.ich_ead%TYPE,
                      p_ess_id      IN ikis_changes.ich_ess_id%TYPE,
                      p_operation   IN ikis_changes.ich_ao%TYPE,
                      p_value       IN VARCHAR2 := NULL)
    IS
        l_org           NUMBER := IKIS_COMMON.GetAP_IKIS_OPFU;
        l_value         VARCHAR2 (4000);
        l_main_doc_id   VARCHAR2 (100);
    BEGIN
        debug.f ('Start CHANGE');

        IF g_Audit_changes
        THEN
            IF p_value IS NULL
            THEN
                l_value := g_EMPTY_FIELD;
            ELSE
                l_value := p_value;
            END IF;

            IF g_USE_GLOBAL_CHANGE_SETTING = IKIS_CONST.V_DDS_YN_Y
            THEN
                BEGIN
                    l_main_doc_id :=
                        ikis_trans_param_utl.Getparam ('MAIN_DOC_ID');
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        l_main_doc_id := NULL;
                END;
            END IF;

            debug.f ('Crypt value');
            l_value :=
                ikis_crypt.encryptraw (UTL_RAW.CAST_TO_RAW (l_value),
                                       UTL_RAW.CAST_TO_RAW (c_pwd));
            debug.f ('add data');

            INSERT INTO ikis_changes (ich_id,
                                      ich_ses,
                                      ich_org,
                                      ich_user,
                                      ich_user_name,
                                      ich_host,
                                      ich_ip,
                                      ich_os_user,
                                      ich_program,
                                      ich_module,
                                      ich_main_ess_id,
                                      ich_ead,
                                      ich_ess_id,
                                      ich_ao,
                                      ich_date,
                                      ich_value)
                 VALUES (0,
                         g_session_data.ut_ses,
                         l_org,
                         g_session_data.ut_usid,
                         g_session_data.ut_usr,
                         g_session_data.ut_hst,
                         g_session_data.ut_ipa,
                         g_session_data.ut_osu,
                         g_session_data.ut_program,
                         g_session_data.ut_module,
                         l_main_doc_id,
                         p_ess_ead,
                         p_ess_id,
                         p_operation,
                         SYSDATE,
                         l_value);
        END IF;

        debug.f ('Stop CHANGE');
    END;

    PROCEDURE SetAuditChangesState (p_pwd     IN VARCHAR2,
                                    p_state   IN BOOLEAN := TRUE)
    IS
        l_pwd   VARCHAR2 (100);
    BEGIN
        l_pwd :=
            UTL_RAW.CAST_TO_VARCHAR2 (
                ikis_crypt.decryptraw (p_pwd, UTL_RAW.CAST_TO_RAW (c_pwd)));

        IF l_pwd = c_Audit_Pwd
        THEN
            g_Audit_changes := p_state;
        ELSE
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgAuditPwdError));
        END IF;
    END;

    FUNCTION GetChangeValue (p_in IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_res   VARCHAR2 (4000);
    BEGIN
        l_res :=
            UTL_RAW.CAST_TO_VARCHAR2 (
                ikis_crypt.decryptraw (p_in, UTL_RAW.CAST_TO_RAW (c_pwd)));
        RETURN REPLACE (l_res, '#@#', CHR (10));
    END;

    PROCEDURE Change_at (p_ess_ead     IN ikis_changes.ich_ead%TYPE,
                         p_ess_id      IN ikis_changes.ich_ess_id%TYPE,
                         p_operation   IN ikis_changes.ich_ao%TYPE,
                         p_value       IN VARCHAR2 := NULL)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        Change (p_ess_ead,
                p_ess_id,
                p_operation,
                p_value);
        COMMIT;
    END;

    PROCEDURE ChangeEssCode (p_ess_code    IN VARCHAR2,
                             p_ess_id      IN ikis_changes.ich_ess_id%TYPE,
                             p_operation   IN ikis_changes.ich_ao%TYPE,
                             p_value       IN VARCHAR2 := NULL)
    IS
        v_ead_id   ikis_changes.ich_ead%TYPE;
    BEGIN
        SELECT ead_id
          INTO v_ead_id
          FROM ikis_ess_aud_code
         WHERE    ead_table = UPPER (p_ess_code)
               OR (    ead_table =
                       UPPER (SUBSTR (p_ess_code, 3, LENGTH (p_ess_code)))
                   AND 'V_' = UPPER (SUBSTR (p_ess_code, 1, 2)));

        Change (v_ead_id,
                p_ess_id,
                p_operation,
                p_value);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'IKIS_CHANGES_UTL.ChangeEssCode',
                    SQLERRM));
    END;

    PROCEDURE State_of_change
    IS
    BEGIN
        IF dserials.gd_ts_enabled
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgChangeDelete));
        END IF;
    END;

    PROCEDURE SetLogState (p_state BOOLEAN:= TRUE)
    IS
    BEGIN
        g_log_state := p_state;
    END;

    --Процедура для заповнення таблиці пи завантаження документів СПОВ
    PROCEDURE LoadChange (p_user        IN ikis_changes.ich_user%TYPE,
                          p_ess_ead     IN ikis_changes.ich_ead%TYPE,
                          p_ess_id      IN ikis_changes.ich_ess_id%TYPE,
                          p_operation   IN ikis_changes.ich_ao%TYPE)
    IS
        l_org   NUMBER := IKIS_COMMON.GetAP_IKIS_OPFU;
    BEGIN
        INSERT INTO ikis_changes (ich_org,
                                  ich_user,
                                  ich_ead,
                                  ich_ess_id,
                                  ich_ao,
                                  ich_date)
             VALUES (l_org,
                     p_user,
                     p_ess_ead,
                     p_ess_id,
                     p_operation,
                     SYSDATE);
    END;

    FUNCTION GetSessionParam (p_name IN VARCHAR2)
        RETURN VARCHAR2
    IS
        v_res   VARCHAR2 (200);
    BEGIN
        v_res :=
            CASE
                WHEN UPPER (p_name) = 'SESSIONID'
                THEN
                    TO_CHAR (g_session_data.ut_ses)
                WHEN UPPER (p_name) = 'SESSION_USERID'
                THEN
                    TO_CHAR (g_session_data.ut_usid)
                WHEN UPPER (p_name) = 'SESSION_USER'
                THEN
                    TO_CHAR (g_session_data.ut_usr)
                WHEN UPPER (p_name) = 'HOST'
                THEN
                    TO_CHAR (g_session_data.ut_hst)
                WHEN UPPER (p_name) = 'IP_ADDRESS'
                THEN
                    TO_CHAR (g_session_data.ut_ipa)
                WHEN UPPER (p_name) = 'NETWORK_PROTOCOL'
                THEN
                    TO_CHAR (g_session_data.ut_prot)
                WHEN UPPER (p_name) = 'ISDBA'
                THEN
                    TO_CHAR (g_session_data.ut_isdba)
                WHEN UPPER (p_name) = 'OS_USER'
                THEN
                    TO_CHAR (g_session_data.ut_osu)
                WHEN UPPER (p_name) = 'USE_GLOBAL_CHANGE_SETTING'
                THEN
                    g_USE_GLOBAL_CHANGE_SETTING
                WHEN UPPER (p_name) = 'PROGRAM'
                THEN
                    TO_CHAR (g_session_data.ut_program)
                WHEN UPPER (p_name) = 'MODULE'
                THEN
                    TO_CHAR (g_session_data.ut_module)
                WHEN UPPER (p_name) = 'USER_NAME'
                THEN
                    g_USER_NAME
                ELSE
                    'UNKNOWN'
            END;
        v_res := TRIM (CHR (0) FROM v_res);
        RETURN v_res;
    END;

    PROCEDURE SetSessionModule (p_module IN VARCHAR2)
    IS
    BEGIN
        g_session_data.ut_module := p_module;
    END;

    PROCEDURE InitSession
    IS
    BEGIN
        debug.f ('Start InitSession');
        c_pwd :=
            CASE WHEN TRIM (c_pwd) IS NULL THEN '12345678' ELSE c_pwd END;
        g_session_data.ut_ses := SYS_CONTEXT ('USERENV', 'SESSIONID');
        g_session_data.ut_usid := SYS_CONTEXT ('USERENV', 'SESSION_USERID');
        g_session_data.ut_usr := SYS_CONTEXT ('USERENV', 'SESSION_USER');
        g_session_data.ut_hst := SYS_CONTEXT ('USERENV', 'HOST');
        g_session_data.ut_ipa := SYS_CONTEXT ('USERENV', 'IP_ADDRESS');
        g_session_data.ut_isdba := SYS_CONTEXT ('USERENV', 'ISDBA');
        g_session_data.ut_prot := SYS_CONTEXT ('USERENV', 'NETWORK_PROTOCOL');
        g_session_data.ut_osu := SYS_CONTEXT ('USERENV', 'OS_USER');

        SELECT program
          INTO g_session_data.ut_program
          FROM v$session
         WHERE sid = (SELECT sid
                        FROM v$mystat
                       WHERE ROWNUM < 2);

        --  where audsid=g_session_data.ut_ses; --Yuraap 2005-12-02 в лжобе SESSIONID не работает

        BEGIN
            SELECT iu_name INTO g_USER_NAME FROM v_ikis_users_curr;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                g_USER_NAME := g_session_data.ut_usr;
            WHEN TOO_MANY_ROWS
            THEN
                g_USER_NAME := g_session_data.ut_usr;
            WHEN OTHERS
            THEN
                g_USER_NAME := g_session_data.ut_usr; --Yura_ap 2005-06-07 мутировать может таблица
        END;

        IF    INSTR (UPPER (g_session_data.ut_program), 'DEVS_CLI') > 0
           OR INSTR (UPPER (g_session_data.ut_program), 'DEVS_SRV') > 0
           OR INSTR (UPPER (g_session_data.ut_program), 'DEVS_PRT') > 0
        THEN
            BEGIN
                SELECT aptprm_value
                  INTO g_session_data.ut_module
                  FROM appt_params
                 WHERE aptprm_name = 'IKIS_APPLICATION_CODE';
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    g_session_data.ut_module := 'IKIS APPLICATION';
            END;
        ELSE
            g_session_data.ut_module := 'UNKNOWN APPLICATION';
        END IF;

        BEGIN
            g_USE_GLOBAL_CHANGE_SETTING :=
                IKIS_PARAMETER_UTIL.GETPARAMETER (
                    'USE_GLOBAL_CHANGE_SETTING',
                    'IKIS_SYS');
        EXCEPTION
            WHEN OTHERS
            THEN
                g_USE_GLOBAL_CHANGE_SETTING := IKIS_CONST.V_DDS_YN_N;
        END;

        debug.f ('Stop InitSession');
    END;

    PROCEDURE SaveData (p_actid   ikis_utait.ut_actid%TYPE,
                        p_ibj     ikis_utait.ut_obj%TYPE,
                        p_ibjid   ikis_utait.ut_ibjid%TYPE,
                        p_par1    ikis_utait.ut_par1%TYPE DEFAULT NULL,
                        p_par2    ikis_utait.ut_par2%TYPE DEFAULT NULL)
    IS
    BEGIN
        debug.f ('Start procedure');

        INSERT INTO ikis_utait (ut_id,
                                ut_ses,
                                ut_usid,
                                ut_usr,
                                ut_hst,
                                ut_ipa,
                                ut_isdba,
                                ut_prot,
                                ut_osu,
                                ut_ts,
                                ut_actid,
                                ut_ibjid,
                                ut_par1,
                                ut_par2,
                                ut_obj)
             VALUES (0,
                     g_session_data.ut_ses,
                     g_session_data.ut_usid,
                     g_session_data.ut_usr,
                     g_session_data.ut_hst,
                     g_session_data.ut_ipa,
                     g_session_data.ut_isdba,
                     g_session_data.ut_prot,
                     g_session_data.ut_osu,
                     SYSTIMESTAMP,
                     p_actid,
                     p_ibjid,
                     p_par1,
                     p_par2,
                     p_ibj);

        IF g_session_data.ut_usr IS NOT NULL
        THEN
            g_session_data.ut_usr := '';
            g_session_data.ut_hst := '';
            g_session_data.ut_ipa := '';
            g_session_data.ut_isdba := '';
            g_session_data.ut_prot := '';
            g_session_data.ut_osu := '';
        END IF;

        debug.f ('Stop procedure');
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (2,
                                               'IKIS_CHANGES_UTL.SaveData',
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE UpdateDeleteError
    IS
    BEGIN
        raise_application_error (
            -20000,
            ikis_message_util.GET_MESSAGE (msgNO_UPDATE_OR_DELETE));
    END;
BEGIN
    InitSession;
    g_EMPTY_FIELD := 'EMPTY';
END IKIS_CHANGES_UTL;
/