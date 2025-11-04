/* Formatted on 8/12/2025 6:11:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.IKIS_ID_AUTH
IS
    -- Author  : VANO
    -- Created : 09.09.2016 13:16:11
    -- Purpose : Функції роботи з структурами ID-аутентифікації

    c_Wla_St_New       CONSTANT NUMBER := -1;
    c_Wla_St_Handled   CONSTANT NUMBER := 1;
    c_Wla_St_Denied    CONSTANT NUMBER := 2;
    c_Wla_St_Used      CONSTANT NUMBER := 3;

    PROCEDURE Setsessionauthorised (
        p_Wla_Session   w_Login_Attempts.Wla_Session%TYPE,
        p_Wla_Login     w_Login_Attempts.Wla_Logins%TYPE);

    PROCEDURE Setattempthandled (
        p_Wla_Id              w_Login_Attempts.Wla_Id%TYPE,
        p_Wla_Cert_Serial     w_Login_Attempts.Wla_Cert_Serial%TYPE,
        p_Wla_Cert_Issuer     w_Login_Attempts.Wla_Cert_Issuer%TYPE,
        p_Wla_Cert_Fullname   w_Login_Attempts.Wla_Cert_Fullname%TYPE,
        p_Wla_Cert_Drfo       w_Login_Attempts.Wla_Cert_Drfo%TYPE);

    PROCEDURE Setattemptdenied (
        p_Wla_Id            w_Login_Attempts.Wla_Id%TYPE,
        p_Wla_Deny_Reason   w_Login_Attempts.Wla_Deny_Reason%TYPE);

    --Моніторинг
    PROCEDURE Get_Stats (p_Condition IN CLOB, p_Result OUT CLOB);
END Ikis_Id_Auth;
/


GRANT EXECUTE ON IKIS_SYSWEB.IKIS_ID_AUTH TO II01RC_SYSWEB_AUTH
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_ID_AUTH TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 6:11:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.IKIS_ID_AUTH
IS
    PROCEDURE Setsessionauthorised (
        p_Wla_Session   w_Login_Attempts.Wla_Session%TYPE,
        p_Wla_Login     w_Login_Attempts.Wla_Logins%TYPE)
    IS
    BEGIN
        --Визначаємо як "аутентифіковану" та проставляємо перелік логінів, які отримані з картки
        UPDATE w_Login_Attempts
           SET Wla_As = c_Wla_St_Handled,
               Wla_Logins = p_Wla_Login,
               Wla_Confirm_Dt = CURRENT_TIMESTAMP
         WHERE     Wla_Session = p_Wla_Session
               AND Wla_As = c_Wla_St_New
               AND Wla_Create_Dt > SYSDATE - 1 / 144;
    END;

    PROCEDURE Setattempthandled (
        p_Wla_Id              w_Login_Attempts.Wla_Id%TYPE,
        p_Wla_Cert_Serial     w_Login_Attempts.Wla_Cert_Serial%TYPE,
        p_Wla_Cert_Issuer     w_Login_Attempts.Wla_Cert_Issuer%TYPE,
        p_Wla_Cert_Fullname   w_Login_Attempts.Wla_Cert_Fullname%TYPE,
        p_Wla_Cert_Drfo       w_Login_Attempts.Wla_Cert_Drfo%TYPE)
    IS
    BEGIN
        --Помечаем попытку логина как "обработанную" и сохраняем данные сертификата пользователя
        UPDATE w_Login_Attempts
           SET Wla_As = c_Wla_St_Handled,
               Wla_Cert_Serial = p_Wla_Cert_Serial,
               Wla_Cert_Issuer = p_Wla_Cert_Issuer,
               Wla_Cert_Fullname = p_Wla_Cert_Fullname,
               Wla_Cert_Drfo = p_Wla_Cert_Drfo,
               Wla_Confirm_Dt = CURRENT_TIMESTAMP
         WHERE     Wla_Id = p_Wla_Id
               AND Wla_As = c_Wla_St_New
               AND Wla_Login_Tp IN ('SIGN', 'CARD');
    END;

    PROCEDURE Setattemptdenied (
        p_Wla_Id            w_Login_Attempts.Wla_Id%TYPE,
        p_Wla_Deny_Reason   w_Login_Attempts.Wla_Deny_Reason%TYPE)
    IS
    BEGIN
        --Изменение статуса попытки логина на "Доступ запрещен"
        UPDATE w_Login_Attempts
           SET Wla_As = c_Wla_St_Denied,
               Wla_Confirm_Dt = CURRENT_TIMESTAMP,
               Wla_Deny_Reason = p_Wla_Deny_Reason
         WHERE Wla_Id = p_Wla_Id AND Wla_As = c_Wla_St_New;
    END;

    --Моніторинг
    PROCEDURE Get_Stats (p_Condition IN CLOB, p_Result OUT CLOB)
    IS
        v_Denied_Cnt      NUMBER;
        v_Expired_Cnt     NUMBER;
        v_Expire_Min_Dt   DATE;
        v_Today_Cnt       NUMBER;
        v_Is_Crytical     BOOLEAN;
        v_Is_Ok           BOOLEAN;
    BEGIN
        SELECT COUNT (*)
          INTO v_Denied_Cnt
          FROM w_Login_Attempts a
         WHERE     a.Wla_As = c_Wla_St_Denied
               AND a.Wla_Create_Dt >= TRUNC (SYSDATE) - 3;

        SELECT COUNT (*), MIN (a.Wla_Create_Dt)
          INTO v_Expired_Cnt, v_Expire_Min_Dt
          FROM Ikis_Sysweb.w_Login_Attempts a
         WHERE     a.Wla_As = -1
               AND a.Wla_Login_Tp IN ('SIGN', 'CARD')
               AND SYSDATE > a.Wla_Create_Dt + INTERVAL '5' MINUTE;

        SELECT COUNT (*)
          INTO v_Today_Cnt
          FROM w_Login_Attempts a
         WHERE     a.Wla_As = c_Wla_St_Used
               AND a.Wla_Login_Tp IN ('SIGN', 'CARD')
               AND a.Wla_Create_Dt > TRUNC (SYSDATE);

        v_Is_Crytical := v_Denied_Cnt > 0 OR v_Expired_Cnt > 0;

        v_Is_Ok := NOT v_Is_Crytical;

        p_Result :=
               'var authStats = {
			"ok": '
            || CASE WHEN v_Is_Ok THEN 'true' ELSE 'false' END
            || ',
			"isCrytical":'
            || CASE WHEN v_Is_Crytical THEN 'true' ELSE 'false' END
            || ',
			"isWarning": false,
			"deniedCount": '
            || v_Denied_Cnt
            || ',
			"deniedExist": '
            || CASE WHEN v_Denied_Cnt > 0 THEN 'true' ELSE 'false' END
            || ',
			"expiredCount": '
            || v_Expired_Cnt
            || ',
			"expiredMinDate": '
            || CASE
                   WHEN v_Expire_Min_Dt IS NULL
                   THEN
                       'null'
                   ELSE
                          '"'
                       || TO_CHAR (v_Expire_Min_Dt, 'dd.mm.yyyy hh24:mi:ss')
                       || '"'
               END
            || ',
			"expiredExist": '
            || CASE WHEN v_Expired_Cnt > 0 THEN 'true' ELSE 'false' END
            || ',
			"todayCount": '
            || v_Today_Cnt
            || ',
			"statsDate": "'
            || TO_CHAR (SYSDATE, 'dd.mm.yyyy hh24:mi:ss')
            || '"
	}';
    END;
BEGIN
    NULL;
END Ikis_Id_Auth;
/