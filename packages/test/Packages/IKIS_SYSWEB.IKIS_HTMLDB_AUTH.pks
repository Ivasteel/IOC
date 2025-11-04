/* Formatted on 8/12/2025 6:11:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.IKIS_HTMLDB_AUTH
IS
    -- Author  : YURA_A
    -- Created : 04.04.2006
    -- Purpose : Custom Authentification for HTMLDB (IKIS_SYSWEB)

    -- Public type declarations
    ----------------------------------------
    -- YURA_A 28.02.2006 18:08:47
    ----------------------------------------
    -- Назначение : проверка юзера и его пароля при логие в веб-приложение
    -- Параметры  : юзер, пароль
    FUNCTION Ikis_Auth (p_Username IN VARCHAR2, p_Password IN VARCHAR2)
        RETURN BOOLEAN;

    ----------------------------------------
    -- YURA_A 01.03.2006 10:55:22
    ----------------------------------------
    -- Назначение : пост аутентификация
    -- Параметры  :
    PROCEDURE Ikis_Post_Auth (p_Username IN VARCHAR2);

    ----------------------------------------
    -- YURA_A 28.02.2006 18:09:12
    ----------------------------------------
    -- Назначение : создание пользователя для веб-приложения
    -- Параметры  : логин, пароль, пиб
    PROCEDURE Createuser (
        p_Login          w_Users.Wu_Login%TYPE,
        p_Password       w_Users.Wu_Password%TYPE,
        p_Pib            w_Users.Wu_Pib%TYPE,
        p_Numid          w_Users.Wu_Numid%TYPE,
        p_Opfu           w_Users.Wu_Org%TYPE,
        p_Wut            w_Users.Wu_Wut%TYPE,
        p_Login_Simple   w_Users.Wu_Login_Simple%TYPE,
        p_Login_Card     w_Users.Wu_Login_Card%TYPE,
        p_Ep             w_Users.Wu_Ep%TYPE DEFAULT NULL,
        p_Wtr            w_Users.Wu_Wtr%TYPE DEFAULT NULL,
        p_Login_Sign     w_Users.Wu_Login_Sign%TYPE DEFAULT NULL);

    ----------------------------------------
    -- YURA_A 01.03.2006 11:40:20
    ----------------------------------------
    -- Назначение : назначение пользователю роли
    -- Параметры  : логин, роль
    --procedure GrantRole(p_username in varchar2, p_role in varchar2);
    --procedure GrantRole(p_username in varchar2, p_role in number);

    ----------------------------------------
    -- YURA_A 01.03.2006 11:40:24
    ----------------------------------------
    -- Назначение : удаления назначения роли пользователю
    -- Параметры  : логин, роль
    --procedure RevokeRole(p_username in varchar2, p_role in varchar2);
    --procedure RevokeRole(p_username in varchar2, p_role in number);
    --procedure RevokeAllRole(p_username in varchar2);

    PROCEDURE Processroles (p_Username   IN VARCHAR2,
                            p_Rbegin        VARCHAR2,
                            p_Rend          VARCHAR2);

    ----------------------------------------
    -- YURA_A 28.02.2006 18:09:37
    ----------------------------------------
    -- Назначение : проверка назначения прикладной роли пользователю веб-приложения
    -- Параметры  : логин, название роли
    FUNCTION Is_Role_Assigned (p_Username IN VARCHAR2, p_Role IN VARCHAR2)
        RETURN BOOLEAN;

    FUNCTION Is_Role_Assigned (p_Username   IN VARCHAR2,
                               p_Role       IN VARCHAR2,
                               p_User_Tp       VARCHAR2)
        RETURN BOOLEAN;

    PROCEDURE Getuser (p_Login       w_Users.Wu_Login%TYPE,
                       p_Pib     OUT w_Users.Wu_Pib%TYPE,
                       p_Numid   OUT w_Users.Wu_Numid%TYPE);

    PROCEDURE Setuser (p_Wuid         w_Users.Wu_Id%TYPE,
                       p_Login_Sign   w_Users.Wu_Login_Sign%TYPE);

    PROCEDURE Setuser (
        p_Wuid           w_Users.Wu_Id%TYPE,
        p_Password       w_Users.Wu_Password%TYPE,
        p_Pib            w_Users.Wu_Pib%TYPE,
        p_Numid          w_Users.Wu_Numid%TYPE,
        p_Ep             w_Users.Wu_Ep%TYPE DEFAULT NULL,
        p_Wtr            w_Users.Wu_Wtr%TYPE DEFAULT NULL,
        p_Login_Simple   w_Users.Wu_Login_Simple%TYPE DEFAULT NULL,
        p_Login_Card     w_Users.Wu_Login_Card%TYPE DEFAULT NULL,
        p_Login_Sign     w_Users.Wu_Login_Sign%TYPE DEFAULT NULL);

    PROCEDURE Changepassword (p_Password IN VARCHAR2);

    PROCEDURE Installadminpwd (p_Password IN VARCHAR2);

    PROCEDURE Lockuser (p_Username IN VARCHAR2);

    PROCEDURE Unlockuser (p_Username IN VARCHAR2);

    FUNCTION Getcurrusertp
        RETURN w_Users.Wu_Wut%TYPE;

    PROCEDURE Saveuserhst (p_Wu_Id         w_Users.Wu_Id%TYPE,
                           p_Is_Pwd_Chng   VARCHAR2 DEFAULT 'N');

    PROCEDURE Getremoteuserattr (p_Username       w_Users.Wu_Login%TYPE,
                                 p_Uid        OUT w_Users.Wu_Id%TYPE,
                                 p_Wut        OUT w_Users.Wu_Wut%TYPE,
                                 p_Org        OUT w_Users.Wu_Org%TYPE,
                                 p_Trc        OUT w_Users.Wu_Trc%TYPE);

    PROCEDURE Insertusrcert (
        p_Wcr_Wu            w_Usr_Cert.Wcr_Wu%TYPE,
        p_Wcr_Cert_Serial   w_Usr_Cert.Wcr_Cert_Serial%TYPE,
        p_Wcr_Issuer        w_Usr_Cert.Wcr_Issuer%TYPE,
        p_Wcr_Issuer_Cn     w_Usr_Cert.Wcr_Issuer_Cn%TYPE,
        p_Wcr_Tp            w_Usr_Cert.Wcr_Tp%TYPE,
        p_Wcr_Expire_Dt     w_Usr_Cert.Wcr_Expire_Dt%TYPE,
        p_Wcr_Cert          w_Usr_Cert.Wcr_Cert%TYPE,
        p_Cert_Drfo         VARCHAR2,
        p_Cert_Pib          VARCHAR2);

    PROCEDURE Deleteusrcert (p_Wcr_Id w_Usr_Cert.Wcr_Id%TYPE);

    PROCEDURE Saveroles (p_Wu_Login IN VARCHAR2);

    PROCEDURE Renderloginpage (p_Title VARCHAR2);

    FUNCTION Createloginattempt
        RETURN w_Login_Attempts.Wla_Session%TYPE;

    PROCEDURE Setloginattemptpayload (
        p_Wla_Session    IN w_Login_Attempts.Wla_Session%TYPE,
        p_Wla_Payload    IN w_Login_Attempts.Wla_Payload%TYPE,
        p_Wla_Login_Tp   IN w_Login_Attempts.Wla_Login_Tp%TYPE);

    PROCEDURE Setloginkeytypeactive (
        p_Lkt_Id          w_Login_Key_Type.Lkt_Id%TYPE,
        p_Lkt_Is_Active   w_Login_Key_Type.Lkt_Is_Active%TYPE);

    FUNCTION Getcryptoparams
        RETURN VARCHAR2;

    FUNCTION Getloginkeytypes (p_Login_Tp IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Userpwdexpiredday (p_Wu_Id IN NUMBER)
        RETURN NUMBER;

    FUNCTION Userpwdexpiredday (p_Login IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION Ispwdmatch (p_Login IN VARCHAR2, p_Pwd IN VARCHAR2)
        RETURN BOOLEAN;

    --20190906 Контроль наличия штатной одиниці у іншого користувача
    FUNCTION Existuserepvalue (p_Login      IN     VARCHAR2,
                               p_Ep         IN     NUMBER,
                               l_User_Out      OUT VARCHAR2)
        RETURN BOOLEAN;
END Ikis_Htmldb_Auth;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_HTMLDB_AUTH FOR IKIS_SYSWEB.IKIS_HTMLDB_AUTH
/


GRANT EXECUTE ON IKIS_SYSWEB.IKIS_HTMLDB_AUTH TO II01RC_SYSWEB_COMM
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_HTMLDB_AUTH TO IKIS_RBM
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_HTMLDB_AUTH TO IKIS_WEBPROXY
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_HTMLDB_AUTH TO USS_ESR
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_HTMLDB_AUTH TO USS_EXCH
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_HTMLDB_AUTH TO USS_NDI
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_HTMLDB_AUTH TO USS_PERSON
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_HTMLDB_AUTH TO USS_RNSP
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_HTMLDB_AUTH TO USS_RPT
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_HTMLDB_AUTH TO USS_VISIT
/


/* Formatted on 8/12/2025 6:11:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.IKIS_HTMLDB_AUTH
IS
    msgCOMMON_EXCEPTION   NUMBER := 2;

    -- Messages for category: SJA_WEB
    msgInvUsr             NUMBER := 5312;
    msgUsrExists          NUMBER := 5313;
    msgUsrLocked          NUMBER := 5332;
    msgUsrExpired         NUMBER := 5333;

    -- Messages for category: IKIS_WEB
    msgRoleTypeViol       NUMBER := 5432;
    msgOperAccessViol     NUMBER := 5433;

    exUsrExists           EXCEPTION;
    exOperAccessViol      EXCEPTION;

    exUniqueViolation     EXCEPTION;
    exPwdExpired          EXCEPTION;

    PRAGMA EXCEPTION_INIT (exUniqueViolation, -1);

    FUNCTION is_role_assigned (p_username IN VARCHAR2, p_role IN VARCHAR2)
        RETURN BOOLEAN
    IS
        l_cnt   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_cnt
          FROM w_usr2roles
         WHERE     wr_id = (SELECT wr_id
                              FROM w_roles
                             WHERE wr_name = UPPER (p_role))
               AND wu_id = (SELECT wu_id
                              FROM w_users
                             WHERE wu_login = UPPER (p_username));

        RETURN l_cnt > 0;
    END;

    FUNCTION is_role_assigned (p_username   IN VARCHAR2,
                               p_role       IN VARCHAR2,
                               p_user_tp       VARCHAR2)
        RETURN BOOLEAN
    IS
        l_cnt   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_cnt
          FROM w_usr2roles
         WHERE     wr_id = (SELECT wr_id
                              FROM w_roles
                             WHERE wr_name = UPPER (p_role))
               AND wu_id =
                   (SELECT wu_id
                      FROM w_users, w_user_type
                     WHERE     wu_login = UPPER (p_username)
                           AND wu_wut = wut_id
                           AND wut_code = p_user_tp);

        RETURN l_cnt > 0;
    END;

    PROCEDURE SavePwdHistory (p_wu IN NUMBER, p_pwdhash IN VARCHAR2)
    IS
        l_wu_adm_id   NUMBER (14);
        l_cnt_max     NUMBER (14);
    BEGIN
        --визначаемо користувача що проводить операцію
        l_wu_adm_id := SYS_CONTEXT ('IKISWEBADM', 'IKISUID');

        --історія паролів
        INSERT INTO w_users_pwd_hst (wuph_id,
                                     wuph_wu,
                                     wuph_wh_chg,
                                     wuph_dt,
                                     wuph_password)
             VALUES (NULL,
                     p_wu,
                     l_wu_adm_id,
                     SYSDATE,
                     p_pwdhash);

        --зберігати останні паролі (к-сть)
        BEGIN
            l_cnt_max :=
                TO_NUMBER (
                    ikis_sys.ikis_common.GetApptParam ('WEB_PWD_SAVE_CNT'));
        EXCEPTION
            WHEN OTHERS
            THEN
                l_cnt_max := 5;
        END;

        --видалення стрих записів історії
        DELETE FROM w_users_pwd_hst w1
              WHERE w1.wuph_id IN
                        (SELECT wuph_id
                           FROM (SELECT w.wuph_id,
                                        ROW_NUMBER ()
                                            OVER (
                                                ORDER BY
                                                    w.wuph_dt DESC NULLS LAST)    rn
                                   FROM w_users_pwd_hst w
                                  WHERE w.wuph_wu = p_wu)
                          WHERE rn > l_cnt_max);
    END;

    --отримання часу блокування
    FUNCTION GetExpireDate
        RETURN DATE
    IS
        l_exp_dt   DATE;
    BEGIN
        BEGIN
            l_exp_dt :=
                  SYSDATE
                +   (1 / 1440)
                  * TO_NUMBER (
                        ikis_sys.ikis_common.GetApptParam (
                            'WEB_PWD_EXPIRED_AFTER'));
        EXCEPTION
            WHEN OTHERS
            THEN
                l_exp_dt := SYSDATE;
        END;

        RETURN l_exp_dt;
    END;

    PROCEDURE UpdatePwdExpiredDt (p_wu IN NUMBER)
    IS
        l_exp_dt   DATE;
    BEGIN
        l_exp_dt := GetExpireDate;

        UPDATE w_users wu
           SET wu.wu_pwd_expire_dt = l_exp_dt
         WHERE wu.wu_id = p_wu;
    END;

    PROCEDURE LockUser (p_username IN VARCHAR2)
    IS
        v_id   w_users.wu_id%TYPE;
    BEGIN
        IF NOT (   is_role_assigned (p_username   => v ('USER'),
                                     p_role       => 'W_ADM_IC')
                OR is_role_assigned (p_username   => v ('USER'),
                                     p_role       => 'W_ADM_RE')
                OR is_role_assigned (p_username   => v ('USER'),
                                     p_role       => 'W_ADM_MU'))
        THEN
            RAISE exOperAccessViol;
        END IF;

        UPDATE w_users
           SET wu_locked = ikis_const.V_DDW_YN_Y
         WHERE wu_login = UPPER (p_username);

        --Vano>20130815< Запись аудита.
        SELECT MIN (wu_id)
          INTO v_id
          FROM w_users
         WHERE wu_login = UPPER (p_username);

        IKIS_SYS.IKIS_AUDIT.WriteMsg (
            'WEB_USER_LOCK',
            'Заблоковано користувача <' || UPPER (p_username) || '>',
            v_id);
    EXCEPTION
        WHEN exOperAccessViol
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgOperAccessViol,
                                               'Призначення/Відміна ролі'));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'ikis_htmldb_auth.LockUser',
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE UnLockUser (p_username IN VARCHAR2)
    IS
        v_id   w_users.wu_id%TYPE;
    BEGIN
        IF NOT (   is_role_assigned (p_username   => v ('USER'),
                                     p_role       => 'W_ADM_IC')
                OR is_role_assigned (p_username   => v ('USER'),
                                     p_role       => 'W_ADM_RE')
                OR is_role_assigned (p_username   => v ('USER'),
                                     p_role       => 'W_ADM_MU'))
        THEN
            RAISE exOperAccessViol;
        END IF;

        UPDATE w_users
           SET wu_locked = ikis_const.V_DDW_YN_N
         WHERE wu_login = UPPER (p_username);

        --Vano>20130815< Запись аудита.
        SELECT MIN (wu_id)
          INTO v_id
          FROM w_users
         WHERE wu_login = UPPER (p_username);

        IKIS_SYS.IKIS_AUDIT.WriteMsg (
            'WEB_USER_UNLOCK',
            'Розблоковано користувача <' || UPPER (p_username) || '>',
            v_id);
    EXCEPTION
        WHEN exOperAccessViol
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgOperAccessViol,
                                               'Призначення/Відміна ролі'));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'ikis_htmldb_auth.LockUser',
                                               CHR (10) || SQLERRM));
    END;

    FUNCTION CalcUserPwdHash (p_username IN VARCHAR2, p_password IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_password   VARCHAR2 (4000);
        l_salt       VARCHAR2 (4000) := '651SFG1651lSLKJF894LKDFLKS0SFG';
    BEGIN
        l_password :=
            UTL_RAW.cast_to_raw (
                DBMS_OBFUSCATION_TOOLKIT.md5 (
                    input_string   =>
                           p_password
                        || SUBSTR (l_salt, 10, 13)
                        || p_username
                        || SUBSTR (l_salt, 4, 10)));
        RETURN l_password;
    END;

    PROCEDURE InternalChangePassword (p_user       IN     VARCHAR2,
                                      p_password   IN     VARCHAR2,
                                      p_uid           OUT w_users.wu_id%TYPE)
    IS
        l_hash   VARCHAR2 (1000);
    BEGIN
        --ikis_htmldb_common.pipe_debug(0,'CH PWD 1:'||p_user||','||p_password);
        l_hash := CalcUserPwdHash (UPPER (p_user), p_password);

           UPDATE w_users
              SET wu_password = l_hash
            WHERE wu_login = UPPER (p_user)
        RETURNING wu_id
             INTO p_uid;

        --ikis_htmldb_common.pipe_debug(0,'CH PWD 1 rc:'||sql%rowcount);
        SavePwdHistory (p_uid, l_hash);
        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'ikis_htmldb_auth.InternalChangePassword',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE InstallAdminPwd (p_password IN VARCHAR2)
    IS
        l_uid   w_users.wu_id%TYPE;
    BEGIN
        InternalChangePassword ('ADMIC28000', p_password, l_uid);

        UPDATE w_users
           SET wu_locked = ikis_const.V_DDW_YN_N
         WHERE wu_login = UPPER ('ADMIC28000');

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            RAISE;
    END;

    PROCEDURE ChangePassword (p_password IN VARCHAR2)
    IS
        l_hash     VARCHAR2 (1000);
        l_USERID   w_users.wu_id%TYPE;
    BEGIN
        --ikis_htmldb_common.pipe_debug(0,'CH PWD 1');
        InternalChangePassword (V ('USER'), p_password, l_USERID);
        --ikis_htmldb_common.pipe_debug(0,'CH PWD 2');
        ikis_htmldb_auth.saveuserhst (p_wu_id         => l_USERID,
                                      p_is_pwd_chng   => 'Y');
        UpdatePwdExpiredDt (l_USERID);
        --ikis_htmldb_common.pipe_debug(0,'CH PWD 3');
        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'ikis_htmldb_auth.ChangePassword',
                    CHR (10) || SQLERRM));
    END;


    --------------------------------------------------------------------------
    -- + shost 15.05.2019
    -- Возвращает тип логина, выбранного пользователем в интерфейсе
    --------------------------------------------------------------------------
    FUNCTION GetLoginTp
        RETURN VARCHAR2
    IS
    BEGIN
        --Получаем значение переменной "тип логина", для APEX - через массив apex_application.g_f0x, для .net - через контексты
        RETURN COALESCE (Ikis_Htmldb_Ui.Get_Login_Tp,
                         SYS_CONTEXT ('IKISWEBADM', 'LOGINTP'),
                         'SIMPLE');
    END;

    --------------------------------------------------------------------------
    -- + shost 15.05.2019
    -- Возвращает идентификатор попытки логина
    --------------------------------------------------------------------------
    FUNCTION GetLoginAttempt
        RETURN VARCHAR2
    IS
    BEGIN
        --Получаем значение переменной "идентификатор попытки логина", для APEX - через массив apex_application.g_f0x, для .net - через контексты
        RETURN COALESCE (Ikis_Htmldb_Ui.Get_Attempt_Session,
                         SYS_CONTEXT ('IKISWEBADM', 'LOGINATTEMPT'),
                         'N/A');
    END;

    --------------------------------------------------------------------------
    -- + Sbond 12.09.2019
    -- Проверяет для пользователя не устарел ли его пароль (в
    -- количество дней до устаревания пароля
    --------------------------------------------------------------------------
    FUNCTION UserPwdExpiredDay (p_wu_id IN NUMBER)
        RETURN NUMBER
    IS
        l_result   NUMBER (5);
    BEGIN
        --если админка то пропускаем, возможно нужно не 1 выдавать а 100 например
        IF NVL (v ('APP_ID'), '0') = '301'
        THEN
            RETURN 1;
        ELSE
            --иначе выдаем количетсво дней до експайра
            SELECT CASE
                       WHEN SYSDATE >= NVL (u.wu_pwd_expire_dt, SYSDATE)
                       THEN
                           0
                       ELSE
                           CEIL (
                                 NVL (u.wu_pwd_expire_dt,
                                      SYSDATE + 1 / (24 * 3600))
                               - SYSDATE)
                   END
              INTO l_result
              FROM w_users u
             WHERE u.wu_id = p_wu_id;
        END IF;

        RETURN l_result;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN 0;
    END;

    FUNCTION UserPwdExpiredDay (p_login IN VARCHAR2)
        RETURN NUMBER
    IS
        l_result   NUMBER (5);
        l_wu_id    w_users.wu_id%TYPE;
    BEGIN
        SELECT w.wu_id
          INTO l_wu_id
          FROM w_users w
         WHERE w.wu_login = UPPER (p_login);

        l_result := UserPwdExpiredDay (l_wu_id);
        RETURN l_result;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN 0;
    END;


    --------------------------------------------------------------------------
    -- + Sbond 12.09.2019
    -- Меняет сообщение и статус при логине если пароль устарел
    --------------------------------------------------------------------------
    FUNCTION UserPwdExpiredReject (p_wu_id IN NUMBER)
        RETURN BOOLEAN
    IS
        l_result     BOOLEAN := TRUE;
        l_day_left   NUMBER;
    BEGIN
        IF UserPwdExpiredDay (p_wu_id => p_wu_id) <= 0
        THEN
            IF v ('APP_ID') IS NOT NULL
            THEN
                l_result := TRUE;
                APEX_UTIL.set_authentication_result (p_code => 3);
                APEX_UTIL.set_custom_auth_status (
                    p_status   =>
                        ikis_sys.ikis_common.GetApptParam (
                            'WEB_PWD_EXPIRED_MSG'));
            ELSE
                --.Net
                RAISE exPwdExpired;
            END IF;
        ELSE
            l_result := FALSE;
        END IF;


        RETURN l_result;
    EXCEPTION
        WHEN exPwdExpired
        THEN
            RAISE exPwdExpired;
        WHEN OTHERS
        THEN
            RETURN FALSE;
    END;

    --------------------------------------------------------------------------
    -- + shost 15.05.2019
    -- Аутентификация ЕЦП(key6.dat или ИД карта)
    --------------------------------------------------------------------------
    FUNCTION LoginBySign (p_User                 w_Users%ROWTYPE,
                          p_Audit_Msg_Tp     OUT VARCHAR2,
                          p_Audit_Msg_Text   OUT VARCHAR2)
        RETURN BOOLEAN
    IS
        l_Wla_Session   w_Login_Attempts.Wla_Session%TYPE;
        l_Crt_Serial    w_Login_Attempts.Wla_Cert_Serial%TYPE;
        l_Crt_Issuer    w_Login_Attempts.Wla_Cert_Issuer%TYPE;
        l_Cert_Drfo     w_Login_Attempts.Wla_Cert_Drfo%TYPE;
    BEGIN
        l_Wla_Session := GetLoginAttempt;

        FOR i IN 1 .. 15
        LOOP
            --Знаходимо спробу логіна за guid-ом
            SELECT MAX (Wla.Wla_Cert_Serial),
                   MAX (Wla.Wla_Cert_Issuer),
                   MAX (Wla.Wla_Cert_Drfo)
              INTO l_Crt_Serial, l_Crt_Issuer, l_Cert_Drfo
              FROM w_Login_Attempts Wla
             WHERE     Wla.Wla_Session = l_Wla_Session
                   AND Wla.Wla_As = 1
                   AND Wla.Wla_Expire_Dt > SYSDATE;

            IF l_Crt_Serial IS NOT NULL
            THEN
                --Перевіряємо що ІПН у сертифікаті відповідає ІПНу користувача
                IF l_Cert_Drfo <> p_User.Wu_Numid
                THEN
                    EXIT;
                END IF;

                UPDATE w_Login_Attempts Wla
                   SET Wla.Wla_Login_Dt = CURRENT_TIMESTAMP, Wla.Wla_As = 3 --Помечаем попытку как "использованную"
                 WHERE Wla.Wla_Session = l_Wla_Session AND Wla.Wla_As = 1;

                p_Audit_Msg_Tp := 'WEB_USER_AUTH_SIGN';
                p_Audit_Msg_Text :=
                       'Аутентифіковано користувача <'
                    || UPPER (p_User.Wu_Login)
                    || '> за сертифікатом <'
                    || l_Crt_Serial
                    || '> виданим <'
                    || l_Crt_Issuer
                    || '>';

                RETURN TRUE;
            END IF;

            Ikis_Sys.Ikis_Lock.Sleep (1 / 2);
        END LOOP;

        p_Audit_Msg_Tp := 'WEB_USER_AUTH_SIGN_ERR';
        p_Audit_Msg_Text :=
               'Невдала спроба аутентифікації користувача <'
            || UPPER (p_User.Wu_Login)
            || '>';

        RETURN FALSE;
    END;

    --------------------------------------------------------------------------
    -- + shost 15.05.2019
    -- Завершение входа по логину и паролю
    --------------------------------------------------------------------------
    FUNCTION LoginSimple (p_User                 w_Users%ROWTYPE,
                          p_Audit_Msg_Tp     OUT VARCHAR2,
                          p_Audit_Msg_Text   OUT VARCHAR2)
        RETURN BOOLEAN
    IS
        l_Result   BOOLEAN := FALSE;
    BEGIN
        IF p_User.Wu_Login_Simple = 1 OR v ('APP_ID') IN (1200, 510, 370) --Для всех БД, кроме центральной(ДКГ, ЦЕА, ЦОЕЗ) вход только по логину и паролю(КЕВ 02.05.2019)
        THEN
            l_Result := TRUE;
        ELSIF p_User.Wu_Login_Sign = 1
        THEN
            l_Result := FALSE;
        END IF;

        IF l_Result
        THEN
            p_Audit_Msg_Tp := 'WEB_USER_AUTH';
            p_Audit_Msg_Text :=
                   'Аутентифіковано користувача <'
                || UPPER (p_User.Wu_Login)
                || '>';
        ELSE
            p_Audit_Msg_Tp := 'WEB_USER_AUTH_ERR';
            p_Audit_Msg_Text :=
                   'Невдала спроба аутентифікації користувача <'
                || UPPER (p_User.Wu_Login)
                || '>';
        END IF;

        RETURN l_Result;
    END;

    FUNCTION ikis_auth (p_username IN VARCHAR2, p_password IN VARCHAR2)
        RETURN BOOLEAN
    IS
        l_User             w_Users%ROWTYPE;
        l_Login_Type       w_Login_Attempts.Wla_Login_Tp%TYPE;
        l_Audit_Msg_tp     VARCHAR2 (30);
        l_Audit_Msg_Text   VARCHAR2 (4000);
        l_Result           BOOLEAN := FALSE;
        l_Opfu             ikis_sys.v_opfu%ROWTYPE;
    BEGIN
        --pipe_debug(p_sess => 0,msg => p_username||'/'||p_password);
        SELECT *
          INTO l_User
          FROM w_Users
         WHERE Wu_Login = UPPER (p_Username);

        /*  if l_user.wu_password='XXX' then --Для первого входа и изменения пароля встроеного админа
            InternalChangePassword(p_username,p_password,l_uid);
            UnLockUser(p_username);
            select * into l_user from w_users where wu_login=upper(p_username);
          end if;
        */
        SELECT *
          INTO l_Opfu
          FROM ikis_sys.v_opfu
         WHERE org_id = l_User.Wu_Org;

        IF l_Opfu.org_st IS NULL OR NOT (l_Opfu.org_st = 'A')
        THEN
            l_Audit_Msg_tp := 'WEB_USER_AUTH_ERR';
            l_Audit_Msg_Text :=
                   'Невдала спроба аутентифікації користувача <'
                || UPPER (l_User.Wu_Login)
                || '> - орган не в стані A';
            l_Result := FALSE;
        --Проверяем блокировку и пароль пользователя
        ELSIF     l_User.Wu_Locked <> Ikis_Const.v_Ddw_Yn_y
              AND Calcuserpwdhash (UPPER (p_Username), p_Password) =
                  l_User.Wu_Password
        THEN
            --Получаем тип логина, котрый выбрал пользователь
            l_Login_Type := GetLoginTp;

            --Выполняем дополнительные проверки, в зависимости от выбранного типа логина и настроек пользователя
            IF l_Login_Type = 'SIMPLE'
            THEN
                --Вход по логину и паролю
                l_Result :=
                    LoginSimple (p_User             => l_User,
                                 p_Audit_Msg_Tp     => l_Audit_Msg_tp,
                                 p_Audit_Msg_Text   => l_Audit_Msg_Text);
            ELSIF l_Login_Type IN ('SIGN', 'CARD')
            THEN
                --Вход по ЕЦП
                l_Result :=
                    LoginBySign (p_User             => l_User,
                                 p_Audit_Msg_Tp     => l_Audit_Msg_Tp,
                                 p_Audit_Msg_Text   => l_Audit_Msg_Text);
            ELSE
                l_Audit_Msg_tp := 'WEB_USER_AUTH_ERR';
                l_Audit_Msg_Text :=
                       'Невдала спроба аутентифікації користувача <'
                    || UPPER (l_User.Wu_Login)
                    || '>';
                l_Result := FALSE;
            END IF;
        ELSE
            l_Audit_Msg_tp := 'WEB_USER_AUTH_ERR';
            l_Audit_Msg_Text :=
                   'Невдала спроба аутентифікації користувача <'
                || UPPER (l_User.Wu_Login)
                || '>';
            l_Result := FALSE;
        END IF;

        --20190912
        IF l_Result
        THEN
            IF UserPwdExpiredReject (l_User.Wu_Id)
            THEN
                l_Result := FALSE;
                l_Audit_Msg_tp := 'WEB_USER_AUTH_ERR';
                l_Audit_Msg_Text :=
                       'Невдала спроба аутентифікації користувача <'
                    || UPPER (l_User.Wu_Login)
                    || '>';
            END IF;
        END IF;

        --ikis_debug_pipe.WriteMsg(l_Audit_Msg_Tp||'-'||l_Audit_Msg_Text||'-'||l_User.Wu_Id);
        Ikis_Sys.Ikis_Audit.Writemsg (l_Audit_Msg_Tp,
                                      l_Audit_Msg_Text,
                                      l_User.Wu_Id);

        RETURN l_Result;
    EXCEPTION
        WHEN exPwdExpired
        THEN
            --Пароль для DNet потрібно змінити
            l_Audit_Msg_tp := 'WEB_USER_AUTH_ERR';
            l_Audit_Msg_Text :=
                   'Невдала спроба аутентифікації користувача <'
                || UPPER (l_User.Wu_Login)
                || '>';
            Ikis_Sys.Ikis_Audit.Writemsg (l_Audit_Msg_Tp,
                                          l_Audit_Msg_Text,
                                          l_User.Wu_Id);
            raise_Application_Error (
                -20000,
                ikis_sys.ikis_common.GetApptParam ('WEB_PWD_EXPIRED_MSG'));
        WHEN NO_DATA_FOUND
        THEN
            RETURN FALSE;
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                Ikis_Message_Util.GET_MESSAGE (Msgcommon_Exception,
                                               'ikis_htmldb_auth.ikis_auth',
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE ikis_post_auth (p_username IN VARCHAR2)
    IS
        l_user   w_users%ROWTYPE;
    BEGIN
        --pipe_debug(p_sess => 0,msg => P_UNAME||'/'||P_PASSWORD||'/'||P_SESSION_ID||'/'||P_FLOW_PAGE||'/'||P_ENTRY_POINT);
        /*  wwv_flow_custom_auth_std.login(p_uname => P_UNAME,
                                         p_password => P_PASSWORD,
                                         p_session_id => P_SESSION_ID,
                                         p_flow_page => P_FLOW_PAGE,
                                         p_entry_point => P_ENTRY_POINT,
                                         p_preserve_case => P_PRESERVE_CASE);
        */
        /*  select * into l_user from w_users where wu_login=upper(p_username);
          if l_user.wu_expired_dt<sysdate then
            raise_application_error(-20000,ikis_message_util.get_message(msgUsrExpired,p_username));
          end if;
          if l_user.wu_locked=ikis_const.V_DDN_BOOLEAN_T then
            raise_application_error(-20000,ikis_message_util.get_message(msgUsrLocked,p_username));
          end if;*/
        NULL;
    END;

    PROCEDURE CreateUser (
        p_login          w_users.wu_login%TYPE,
        p_password       w_users.wu_password%TYPE,
        p_pib            w_users.wu_pib%TYPE,
        p_numid          w_users.wu_numid%TYPE,
        p_opfu           w_users.wu_org%TYPE,
        p_wut            w_users.wu_wut%TYPE,
        p_login_simple   w_users.wu_login_simple%TYPE,
        p_login_card     w_users.wu_login_card%TYPE,
        p_ep             w_users.wu_ep%TYPE DEFAULT NULL,
        p_wtr            w_users.wu_wtr%TYPE DEFAULT NULL,
        p_login_sign     w_users.wu_login_sign%TYPE DEFAULT NULL)
    IS
        l_pwd         w_users.wu_password%TYPE;
        l_cnt         NUMBER;
        l_lock        ikis_lock.t_lockhandler;
        l_id          w_users.wu_id%TYPE;
        l_wu_adm_id   NUMBER (14);
    BEGIN
        IF NOT (   is_role_assigned (p_username   => v ('USER'),
                                     p_role       => 'W_ADM_IC')
                OR is_role_assigned (p_username   => v ('USER'),
                                     p_role       => 'W_ADM_RE')
                OR is_role_assigned (p_username   => v ('USER'),
                                     p_role       => 'W_ADM_MU'))
        THEN
            RAISE exOperAccessViol;
        END IF;

        l_wu_adm_id := SYS_CONTEXT ('IKISWEBADM', 'IKISUID');

        ikis_lock.Request_Lock (
            p_permanent_name      => 'SYSEBCREATEUSER',
            p_var_name            => p_login,
            p_errmessage          =>
                'Помилка при створенні користувача: заблоковано',
            p_lockhandler         => l_lock,
            p_timeout             => 5,
            p_release_on_commit   => TRUE);

        SELECT COUNT (1)
          INTO l_cnt
          FROM w_users
         WHERE wu_login = UPPER (p_login);

        IF l_cnt > 0
        THEN
            RAISE exUsrExists;
        END IF;

        l_pwd := CalcUserPwdHash (UPPER (p_login), p_password);
        dserials.GetNextTimestampSQ (l_id);

        INSERT INTO w_users (wu_id,
                             wu_login,
                             wu_password,
                             wu_pib,
                             wu_cr_dt,
                             wu_locked,
                             wu_numid,
                             wu_org,
                             wu_wut,
                             wu_login_simple,
                             wu_login_card,
                             wu_ep,
                             wu_wtr,
                             wu_wu_chg,
                             wu_pwd_expire_dt,
                             wu_login_sign)
                 VALUES (
                            l_id,
                            UPPER (p_login),
                            l_pwd,
                            p_pib,
                            SYSDATE,
                            ikis_const.V_DDW_YN_N,
                            p_numid,
                            p_opfu,
                            p_wut,
                            CASE
                                WHEN     NVL (p_login_card, 0) = 0
                                     AND NVL (p_login_sign, 0) = 0
                                THEN
                                    1
                                ELSE
                                    0
                            END,
                            NVL (p_login_card, 0),
                            p_ep,
                            DECODE (p_wtr, -1, NULL, p_wtr),
                            l_wu_adm_id,
                            NULL,
                            NVL (p_login_sign, 0));

        UpdatePwdExpiredDt (l_id);
        SavePwdHistory (l_id, l_pwd);

        --Vano>20130815< Запись аудита.
        IKIS_SYS.IKIS_AUDIT.WriteMsg (
            'WEB_USER_CR',
               'Створено користувача <'
            || UPPER (p_login)
            || '> для ОПФУ <'
            || p_opfu
            || '> типу <'
            || p_wut
            || '>',
            l_id);
    EXCEPTION
        WHEN exOperAccessViol
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgOperAccessViol,
                                               'Призначення/Відміна ролі'));
        WHEN exUsrExists
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgUsrExists, UPPER (p_login)));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'ikis_htmldb_auth.CreateUser',
                                               CHR (10) || SQLERRM));
    END;

    /*procedure GrantRole(p_username in varchar2, p_role in varchar2)
    is
    begin
      insert into w_usr2roles
        (wr_id, wu_id)
      values
        ((select wr_id from w_roles where wr_name=upper(p_role)),
         (select wu_id from w_users where wu_login=upper(p_username)));
      commit;
    exception
      when exUniqueViolation then null;
      when others then
        rollback;
        raise_application_error(-20000,ikis_message_util.get_message(msgCOMMON_EXCEPTION,'ikis_htmldb_auth.GrantRole',chr(10)||sqlerrm));
    end;*/

    PROCEDURE GrantRole (p_username IN VARCHAR2, p_role IN NUMBER)
    IS
        l_usr_id   w_users.wu_id%TYPE;
    BEGIN
        SELECT wu_id
          INTO l_usr_id
          FROM v$w_roles, w_users
         WHERE     v$w_roles.wr_wut = w_users.wu_wut
               AND v$w_roles.wr_id = p_role
               AND w_users.wu_login = UPPER (p_username);

        INSERT INTO w_usr2roles (wr_id, wu_id)
             VALUES (p_role, l_usr_id);
    --  commit;
    EXCEPTION
        WHEN exUniqueViolation
        THEN
            NULL;
        WHEN NO_DATA_FOUND
        THEN
            --    rollback;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgRoleTypeViol));
        WHEN OTHERS
        THEN
            --    rollback;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'ikis_htmldb_auth.GrantRole',
                                               CHR (10) || SQLERRM));
    END;

    /*procedure RevokeRole(p_username in varchar2, p_role in varchar2)
    is
    begin
      delete w_usr2roles
       where wr_id = (select wr_id from w_roles where wr_name=upper(p_role))
         and wu_id = (select wu_id from w_users where wu_login=upper(p_username));
      commit;
    exception
      when others then
        rollback;
        raise_application_error(-20000,ikis_message_util.get_message(msgCOMMON_EXCEPTION,'ikis_htmldb_auth.RevokeRole',chr(10)||sqlerrm));
    end;*/

    PROCEDURE RevokeRole (p_username IN VARCHAR2, p_role IN NUMBER)
    IS
    BEGIN
        DELETE w_usr2roles
         WHERE     wr_id = (SELECT wr_id
                              FROM w_roles
                             WHERE wr_id = p_role)
               AND wu_id = (SELECT wu_id
                              FROM w_users
                             WHERE wu_login = UPPER (p_username));
    --  commit;
    EXCEPTION
        WHEN OTHERS
        THEN
            --    rollback;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'ikis_htmldb_auth.RevokeRole',
                                               CHR (10) || SQLERRM));
    END;

    /*procedure RevokeAllRole(p_username in varchar2)
    is
    begin
      delete w_usr2roles
       where
         wu_id = (select wu_id from w_users where wu_login=upper(p_username));
    --  commit;
    exception
    --  when others then
        rollback;
        raise_application_error(-20000,ikis_message_util.get_message(msgCOMMON_EXCEPTION,'ikis_htmldb_auth.RevokeRole',chr(10)||sqlerrm));
    end;*/

    PROCEDURE ProcessRoles (p_username   IN VARCHAR2,
                            p_rbegin        VARCHAR2,
                            p_rend          VARCHAR2)
    IS
        t_begin   HTMLDB_APPLICATION_GLOBAL.VC_ARR2;
        t_end     HTMLDB_APPLICATION_GLOBAL.VC_ARR2;
        l_opr     PLS_INTEGER := 0;
        l_rows    PLS_INTEGER := 0;

        FUNCTION SearchVal (p_array   HTMLDB_APPLICATION_GLOBAL.VC_ARR2,
                            p_val     VARCHAR2)
            RETURN BOOLEAN
        IS
        BEGIN
            FOR i IN 1 .. p_array.COUNT
            LOOP
                IF p_array (i) = p_val
                THEN
                    RETURN TRUE;
                END IF;
            END LOOP;

            RETURN FALSE;
        END;
    BEGIN
        IF NOT (   is_role_assigned (p_username   => v ('USER'),
                                     p_role       => 'W_ADM_IC')
                OR is_role_assigned (p_username   => v ('USER'),
                                     p_role       => 'W_ADM_RE')
                OR is_role_assigned (p_username   => v ('USER'),
                                     p_role       => 'W_ADM_MU'))
        THEN
            RAISE exOperAccessViol;
        END IF;

        t_begin := HTMLDB_UTIL.STRING_TO_TABLE (p_rbegin);
        t_end := HTMLDB_UTIL.STRING_TO_TABLE (p_rend);

        --Назначения ролей
        FOR i IN 1 .. t_end.COUNT
        LOOP
            IF NOT (SearchVal (t_begin, t_end (i)))
            THEN
                GrantRole (p_username, TO_NUMBER (t_end (i)));
                l_opr := 1;
            END IF;
        END LOOP;

        --Снятие ролей
        FOR i IN 1 .. t_begin.COUNT
        LOOP
            IF NOT (SearchVal (t_end, t_begin (i)))
            THEN
                RevokeRole (p_username, TO_NUMBER (t_begin (i)));
                l_opr := 1;
            END IF;
        END LOOP;

        IF l_opr > 0
        THEN
            INSERT INTO w_usr2roles_hst (wu2rh_id,
                                         wu2rh_wu,
                                         wu2rh_wr,
                                         wu2rh_wu_chg,
                                         wu2rh_dt)
                SELECT NULL,
                       u.wu_id,
                       wr.wr_id,
                       SYS_CONTEXT ('IKISWEBADM', 'IKISUID'),
                       SYSDATE
                  FROM w_usr2roles wr, w_users u
                 WHERE u.wu_login = UPPER (p_username) AND u.wu_id = wr.wu_id;

            l_rows := SQL%ROWCOUNT;

            IF l_rows = 0
            THEN
                INSERT INTO w_usr2roles_hst (wu2rh_id,
                                             wu2rh_wu,
                                             wu2rh_wr,
                                             wu2rh_wu_chg,
                                             wu2rh_dt)
                    SELECT NULL,
                           u.wu_id,
                           NULL,
                           SYS_CONTEXT ('IKISWEBADM', 'IKISUID'),
                           SYSDATE
                      FROM w_users u
                     WHERE u.wu_login = UPPER (p_username);
            END IF;
        END IF;
    EXCEPTION
        WHEN exOperAccessViol
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgOperAccessViol,
                                               'Призначення/Відміна ролі'));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'ProcessRoles',
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE GetUser (p_login       w_users.wu_login%TYPE,
                       p_pib     OUT w_users.wu_pib%TYPE,
                       p_numid   OUT w_users.wu_numid%TYPE)
    IS
    BEGIN
        SELECT wu_pib, wu_numid
          INTO p_pib, p_numid
          FROM w_users
         WHERE wu_login = UPPER (p_login);
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgInvUsr));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'ikis_htmldb_auth.GetUser',
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE SetUser (p_wuid         w_users.wu_id%TYPE,
                       p_login_sign   w_users.wu_login_sign%TYPE)
    IS
        l_wu_adm_id   NUMBER (14);
    BEGIN
        IF NOT is_role_assigned (p_username   => v ('USER'),
                                 p_role       => 'W_ADM_CERT')
        THEN
            RAISE exOperAccessViol;
        END IF;

        l_wu_adm_id := SYS_CONTEXT ('IKISWEBADM', 'IKISUID');

        UPDATE w_users u
           SET wu_wu_chg = l_wu_adm_id,
               wu_login_simple =
                   CASE
                       WHEN u.wu_login_card = 0 AND NVL (p_login_sign, 0) = 0
                       THEN
                           1
                       ELSE
                           0
                   END,
               wu_login_sign = NVL (p_login_sign, 0)
         WHERE wu_id = p_wuid;
    EXCEPTION
        WHEN exOperAccessViol
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgOperAccessViol,
                                               'Призначення/Відміна ролі'));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'ikis_htmldb_auth.SetUser',
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE SetUser (
        p_wuid           w_users.wu_id%TYPE,
        p_password       w_users.wu_password%TYPE,
        p_pib            w_users.wu_pib%TYPE,
        p_numid          w_users.wu_numid%TYPE,
        p_ep             w_users.wu_ep%TYPE DEFAULT NULL,
        p_wtr            w_users.wu_wtr%TYPE DEFAULT NULL,
        p_login_simple   w_users.wu_login_simple%TYPE DEFAULT NULL,
        p_login_card     w_users.wu_login_card%TYPE DEFAULT NULL,
        p_login_sign     w_users.wu_login_sign%TYPE DEFAULT NULL)
    IS
        l_usr         w_users%ROWTYPE;
        l_id          w_users.wu_id%TYPE;
        l_wu_adm_id   NUMBER (14);
    BEGIN
        IF NOT (   is_role_assigned (p_username   => v ('USER'),
                                     p_role       => 'W_ADM_IC')
                OR is_role_assigned (p_username   => v ('USER'),
                                     p_role       => 'W_ADM_RE')
                OR is_role_assigned (p_username   => v ('USER'),
                                     p_role       => 'W_ADM_MU'))
        THEN
            RAISE exOperAccessViol;
        END IF;

        l_wu_adm_id := SYS_CONTEXT ('IKISWEBADM', 'IKISUID');

        SELECT *
          INTO l_usr
          FROM w_users
         WHERE wu_id = p_wuid;

        IF p_password IS NOT NULL
        THEN
            InternalChangePassword (l_usr.wu_login, p_password, l_id);
            UpdatePwdExpiredDt (p_wuid);
        END IF;

        UPDATE w_users
           SET wu_pib = p_pib,
               wu_numid = p_numid,
               wu_ep = p_ep,
               wu_wtr = DECODE (p_wtr, -1, NULL, p_wtr),
               wu_wu_chg = l_wu_adm_id
         -- wu_login_simple = case when nvl(p_login_card, 0) = 0 and nvl(p_login_sign, 0) = 0 then 1 else 0 end,
         -- wu_login_card = nvl(p_login_card, 0),
         -- wu_login_sign = nvl(p_login_sign, 0)
         WHERE wu_id = p_wuid;
    EXCEPTION
        WHEN exOperAccessViol
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgOperAccessViol,
                                               'Призначення/Відміна ролі'));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'ikis_htmldb_auth.SetUser',
                                               CHR (10) || SQLERRM));
    END;

    FUNCTION GetCurrUserTP
        RETURN w_users.wu_wut%TYPE
    IS
        l_wut   w_users.wu_wut%TYPE;
    BEGIN
        SELECT wu_wut
          INTO l_wut
          FROM w_users
         WHERE wu_login = UPPER (v ('USER'));

        RETURN l_wut;
    END;

    PROCEDURE SaveUserHst (p_wu_id         w_users.wu_id%TYPE,
                           p_is_pwd_chng   VARCHAR2 DEFAULT 'N')
    IS
        v_login        w_users.wu_login%TYPE;
        l_message      VARCHAR2 (32000);
        l_pos          PLS_INTEGER := 1;
        l_length_max   PLS_INTEGER := 3990;
        l_buf          VARCHAR2 (4000);
    BEGIN
        INSERT INTO w_users_hst (wuh_id,
                                 wuh_login_md,
                                 wuh_wu,
                                 wuh_pwd_chng,
                                 wuh_pib,
                                 wuh_auth_dt,
                                 wuh_locked,
                                 wuh_numid,
                                 wuh_roles,
                                 wuh_wut,
                                 wuh_org,
                                 wuh_login_simple,
                                 wuh_login_card,
                                 wuh_card_num,
                                 wuh_login_sign,
                                 wuh_wu_wu_chg)
            SELECT 0,
                   v ('USER'),
                   wu_id,
                   p_is_pwd_chng,
                   wu_pib,
                   SYSDATE,
                   wu_locked,
                   wu_numid,
                   ikis_htmldb_common.getrolelst (wu_login),
                   wu_wut,
                   wu_org,
                   wu_login_simple,
                   wu_login_card,
                   wu_card_num,
                   wu_login_sign,
                   wu_wu_chg
              FROM w_users
             WHERE wu_id = p_wu_id;

        --Vano>20130815< Запись аудита.
        SELECT wu_login
          INTO v_login
          FROM w_users
         WHERE wu_id = p_wu_id;

        l_message :=
               'Змінено параметри користувача <'
            || UPPER (v_login)
            || '>. Нові ролі:<br>'
            || ikis_htmldb_common.getrolelst (v_login)
            || '';

        IF LENGTH (l_message) <= 4000
        THEN
            IKIS_SYS.IKIS_AUDIT.WriteMsg ('WEB_USER_EDIT',
                                          l_message,
                                          p_wu_id);
        ELSE
            --ділення довгого повідомлення на частини
            FOR i IN 1 .. TRUNC (LENGTH (l_message) / l_length_max) + 1
            LOOP
                l_buf := SUBSTR (l_message, l_pos, l_length_max);

                IF i = 1
                THEN
                    l_buf := l_buf || '...';
                ELSIF i = TRUNC (LENGTH (l_message) / l_length_max) + 1
                THEN
                    l_buf := '...' || l_buf;
                ELSE
                    l_buf := '...' || l_buf || '...';
                END IF;

                IKIS_SYS.IKIS_AUDIT.WriteMsg ('WEB_USER_EDIT',
                                              l_buf,
                                              p_wu_id);
                l_pos := l_pos + l_length_max;
                l_buf := '';
            END LOOP;
        END IF;
    --IKIS_SYS.IKIS_AUDIT.WriteMsg('WEB_USER_EDIT', l_message, p_wu_id);
    --ikis_htmldb_common.pipe_debug(0,'CH PWD 2:'||p_wu_id||','||sql%rowcount);
    /*exception
      when others then
        raise_application_error(-20000, sqlerrm||' ' || dbms_utility.format_error_stack || dbms_utility.format_error_backtrace);*/
    END;

    PROCEDURE GetRemoteUserAttr (p_username       w_users.wu_login%TYPE,
                                 p_uid        OUT w_users.wu_id%TYPE,
                                 p_wut        OUT w_users.wu_wut%TYPE,
                                 p_org        OUT w_users.wu_org%TYPE,
                                 p_trc        OUT w_users.wu_trc%TYPE)
    IS
    BEGIN
        BEGIN
            SELECT wu_id,
                   wu_wut,
                   wu_org,
                   wu_trc
              INTO p_uid,
                   p_wut,
                   p_org,
                   p_trc
              FROM w_users
             WHERE wu_login = UPPER (p_username);
        EXCEPTION
            WHEN OTHERS
            THEN
                BEGIN
                    p_wut := -1;
                    p_uid := -1;
                    p_org := -1;
                    p_trc := 0;
                END;
        END;
    END;

    PROCEDURE InsertUsrCert (
        p_Wcr_Wu            w_Usr_Cert.Wcr_Wu%TYPE,
        p_Wcr_Cert_Serial   w_Usr_Cert.Wcr_Cert_Serial%TYPE,
        p_Wcr_Issuer        w_Usr_Cert.Wcr_Issuer%TYPE,
        p_Wcr_Issuer_Cn     w_Usr_Cert.Wcr_Issuer_Cn%TYPE,
        p_Wcr_Tp            w_Usr_Cert.Wcr_Tp%TYPE,
        p_Wcr_Expire_Dt     w_Usr_Cert.Wcr_Expire_Dt%TYPE,
        p_Wcr_Cert          w_Usr_Cert.Wcr_Cert%TYPE,
        p_Cert_Drfo         VARCHAR2,
        p_Cert_Pib          VARCHAR2)
    IS
        v_User_Numid    w_Users.Wu_Numid%TYPE;
        v_User_Pib      w_Users.Wu_Pib%TYPE;
        v_Cert_Exists   NUMBER;
    BEGIN
        --Считываем ИНН пользователя
        SELECT u.Wu_Numid, u.wu_pib
          INTO v_User_Numid, v_User_Pib
          FROM w_Users u
         WHERE u.Wu_Id = p_Wcr_Wu;

        --Не даем сохранить сертификат, если ИНН пользователя не соответствует тому, которий указан в сертификате
        IF     Ikis_Sys.Ikis_Common.GetApptParam ('WEB_CRT_CHECK_NUMIDENT',
                                                  'T') =
               'T'
           AND v_User_Numid <> p_Cert_Drfo
        THEN
            Raise_Application_Error (
                -20001,
                   'Неможливо зберегти сертифікат. ІПН у сертифікаті('
                || p_Cert_Drfo
                || ') відрізняється від ІПН користувача');
        END IF;

        --Не даем сохранить сертификат, если ФИО пользователя не соответствует ФИО в сертификате
        IF     Ikis_Sys.Ikis_Common.GetApptParam ('WEB_CRT_CHECK_NAME', 'T') =
               'T'
           AND INSTR (UPPER (p_Cert_Pib), UPPER (v_User_Pib)) = 0
        THEN
            Raise_Application_Error (
                -20001,
                'Неможливо зберегти сертифікат. ПІБ у сертифікаті відрізняється від ПІБ користувача');
        END IF;

        --Не даем сохранить сертификат, если к пользователю уже привязан сертификат с таким же серийным номером от того же АЦСК
        SELECT DECODE (COUNT (*), 0, 0, 1)
          INTO v_Cert_Exists
          FROM w_Usr_Cert c
         WHERE     c.Wcr_Wu = p_Wcr_Wu
               AND UPPER (c.Wcr_Issuer) = UPPER (p_Wcr_Issuer)
               AND UPPER (c.Wcr_Cert_Serial) = UPPER (p_Wcr_Cert_Serial)
               AND c.Wcr_St = 'A';

        IF v_Cert_Exists = 1
        THEN
            Raise_Application_Error (
                -20001,
                'Неможливо зберегти сертифікат. Обраний сертифікат вже наявний у переліку сертифікатив користувача');
        END IF;

        INSERT INTO w_Usr_Cert (Wcr_Wu,
                                Wcr_Register_Dt,
                                Wcr_St,
                                Wcr_Cert_Serial,
                                Wcr_Issuer,
                                Wcr_Issuer_Cn,
                                Wcr_Tp,
                                Wcr_Expire_Dt,
                                Wcr_Cert)
             VALUES (p_Wcr_Wu,
                     SYSDATE,
                     'A',
                     p_Wcr_Cert_Serial,
                     p_Wcr_Issuer,
                     p_Wcr_Issuer_Cn,
                     p_Wcr_Tp,
                     p_Wcr_Expire_Dt,
                     p_Wcr_Cert);
    END;


    PROCEDURE DeleteUsrCert (p_wcr_id w_usr_cert.wcr_id%TYPE)
    IS
    BEGIN
        UPDATE w_usr_cert
           SET wcr_delete_dt = SYSDATE, wcr_st = 'H'
         WHERE wcr_id = p_wcr_id AND wcr_st = 'A';
    END;

    PROCEDURE SaveRoles (p_wu_login IN VARCHAR2)
    IS
        TYPE t_roles IS TABLE OF NUMBER (14)
            INDEX BY PLS_INTEGER;

        l_t_roles   t_roles;
        l_opr       PLS_INTEGER := 0;
        l_rows      PLS_INTEGER := 0;

        FUNCTION SearchVal (p_array t_roles, p_val NUMBER)
            RETURN BOOLEAN
        IS
        BEGIN
            FOR i IN 1 .. p_array.COUNT
            LOOP
                IF p_array (i) = p_val
                THEN
                    RETURN TRUE;
                END IF;
            END LOOP;

            RETURN FALSE;
        END;

        FUNCTION SearchVal (p_array   htmldb_application_global.vc_arr2,
                            p_val     NUMBER)
            RETURN BOOLEAN
        IS
        BEGIN
            FOR i IN 1 .. p_array.COUNT
            LOOP
                IF p_array (i) = p_val
                THEN
                    RETURN TRUE;
                END IF;
            END LOOP;

            RETURN FALSE;
        END;
    BEGIN
        IF NOT (   ikis_htmldb_common.is_role_assigned (
                       p_username   => v ('USER'),
                       p_role       => 'W_ADM_IC')
                OR ikis_htmldb_common.is_role_assigned (
                       p_username   => v ('USER'),
                       p_role       => 'W_ADM_RE')
                OR ikis_htmldb_common.is_role_assigned (
                       p_username   => v ('USER'),
                       p_role       => 'W_ADM_MU'))
        THEN
            RAISE exOperAccessViol;
        END IF;

        -- выбираем текущие роли
        SELECT r.wr_id
          BULK COLLECT INTO l_t_roles
          FROM v$w_users wu, w_usr2roles ur, w_roles r
         WHERE     wu.wu_login = p_wu_login
               AND wu.wu_id = ur.wu_id
               AND r.wr_id = ur.wr_id;

        FOR i IN 1 .. APEX_APPLICATION.g_f10.COUNT
        LOOP
            IF NOT (SearchVal (l_t_roles, APEX_APPLICATION.g_f10 (i)))
            THEN
                ikis_htmldb_auth.GrantRole (
                    p_wu_login,
                    TO_NUMBER (APEX_APPLICATION.g_f10 (i)));
                l_opr := 1;
            END IF;
        END LOOP;

        FOR i IN 1 .. l_t_roles.COUNT
        LOOP
            IF NOT (SearchVal (APEX_APPLICATION.g_f10, l_t_roles (i)))
            THEN
                ikis_htmldb_auth.RevokeRole (p_wu_login, l_t_roles (i));
                l_opr := 1;
            END IF;
        END LOOP;

        IF l_opr > 0
        THEN
            INSERT INTO w_usr2roles_hst (wu2rh_id,
                                         wu2rh_wu,
                                         wu2rh_wr,
                                         wu2rh_wu_chg,
                                         wu2rh_dt)
                SELECT NULL,
                       u.wu_id,
                       wr.wr_id,
                       SYS_CONTEXT ('IKISWEBADM', 'IKISUID'),
                       SYSDATE
                  FROM w_usr2roles wr, w_users u
                 WHERE u.wu_login = UPPER (p_wu_login) AND u.wu_id = wr.wu_id;

            l_rows := SQL%ROWCOUNT;

            IF l_rows = 0
            THEN
                INSERT INTO w_usr2roles_hst (wu2rh_id,
                                             wu2rh_wu,
                                             wu2rh_wr,
                                             wu2rh_wu_chg,
                                             wu2rh_dt)
                    SELECT NULL,
                           u.wu_id,
                           NULL,
                           SYS_CONTEXT ('IKISWEBADM', 'IKISUID'),
                           SYSDATE
                      FROM w_users u
                     WHERE u.wu_login = UPPER (p_wu_login);
            END IF;
        END IF;
    EXCEPTION
        WHEN exOperAccessViol
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgOperAccessViol,
                                               'Призначення/Відміна ролі'));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'ProcessRoles',
                                               CHR (10) || SQLERRM));
    END;

    --------------------------------------------------------------------------
    -- + shost 15.05.2019
    -- Отрисовка страницы логина для APEX
    --------------------------------------------------------------------------
    PROCEDURE RenderLoginPage (p_Title VARCHAR2)
    IS
        v_Attempt_Session   w_Login_Attempts.Wla_Session%TYPE;
    BEGIN
        v_Attempt_Session := CreateLoginAttempt;
        Ikis_Htmldb_Ui.Render_Login_Page (
            p_Attempt_Session   => v_Attempt_Session,
            p_Title             => p_Title);
    END;

    --------------------------------------------------------------------------
    -- + shost 15.05.2019
    -- Создание попытки логина
    -- Возвращает идентификатор сессии
    --------------------------------------------------------------------------
    FUNCTION CreateLoginAttempt
        RETURN w_Login_Attempts.Wla_Session%TYPE
    IS
        v_Wla_Session   w_Login_Attempts.Wla_Session%TYPE;
    BEGIN
        v_Wla_Session := DBMS_CRYPTO.Randombytes (25);

        INSERT INTO w_Login_Attempts (Wla_Id,
                                      Wla_Session,
                                      Wla_Create_Dt,
                                      Wla_Expire_Dt)
             VALUES (0,
                     v_Wla_Session,
                     CURRENT_TIMESTAMP,
                     CURRENT_TIMESTAMP + INTERVAL '10' MINUTE);

        RETURN v_Wla_Session;
    END;

    --------------------------------------------------------------------------
    -- + shost 15.05.2019
    -- Сохранение шифрованного + подписанного пользователем блока данных
    --------------------------------------------------------------------------
    PROCEDURE SetLoginAttemptPayload (
        p_Wla_Session    IN w_Login_Attempts.Wla_Session%TYPE,
        p_Wla_Payload    IN w_Login_Attempts.Wla_Payload%TYPE,
        p_Wla_Login_Tp   IN w_Login_Attempts.Wla_Login_Tp%TYPE)
    IS
    BEGIN
        --
        IF p_Wla_Session IS NULL
        THEN
            RETURN;
        END IF;

        -- RAISE_application_error(-20000, p_Wla_Session || ';' || p_Wla_Login_Tp || ';' || p_Wla_Payload);


        UPDATE w_Login_Attempts a
           SET a.Wla_Payload = p_Wla_Payload, a.Wla_Login_Tp = p_Wla_Login_Tp
         WHERE a.Wla_Session = p_Wla_Session AND a.Wla_As = -1;

        COMMIT;
    END;

    --------------------------------------------------------------------------
    -- + shost 15.05.2019
    -- Изменение активности определенного типа ключа для входа
    --------------------------------------------------------------------------
    PROCEDURE SetLoginKeyTypeActive (
        p_Lkt_Id          w_Login_Key_Type.Lkt_Id%TYPE,
        p_Lkt_Is_Active   w_Login_Key_Type.Lkt_Is_Active%TYPE)
    IS
        l_Lkt_Name   w_Login_Key_Type.Lkt_Name%TYPE;
    BEGIN
        IF SYS_CONTEXT ('IKISWEBADM', 'IUTP') <> 4
        THEN
            Raise_Application_Error (-20000, 'Доступ заборонено');
        END IF;

           --Изменение активности определенного типа ключа для входа
           UPDATE w_Login_Key_Type t
              SET t.Lkt_Is_Active = p_Lkt_Is_Active
            WHERE t.Lkt_Id = p_Lkt_Id
        RETURNING t.Lkt_Name
             INTO l_Lkt_Name;

        IF p_Lkt_Is_Active = 'A'
        THEN
            Ikis_Sys.Ikis_Audit.Writemsg (
                'WEB_KEY_TP_ACTIVATE',
                'Активовано тип ключа <' || l_Lkt_Name || '>',
                p_Lkt_Id);
        ELSE
            Ikis_Sys.Ikis_Audit.Writemsg (
                'WEB_KEY_TP_DEACTIVATE',
                'Деактивовано тип ключа <' || l_Lkt_Name || '>',
                p_Lkt_Id);
        END IF;
    END;

    --------------------------------------------------------------------------
    -- + shost 25.06.2019
    -- Получение объекта с настройками криптографии
    --------------------------------------------------------------------------
    FUNCTION GetCryptoParams
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN Ikis_Htmldb_Ui.Get_Crypto_Params;
    END;

    --------------------------------------------------------------------------
    -- + shost 25.06.2019
    -- Получение массива АЦСК
    --------------------------------------------------------------------------
    FUNCTION GetLoginKeyTypes (p_Login_Tp IN VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN Ikis_Htmldb_Ui.Get_Key_Types (p_Login_Tp => p_Login_Tp);
    END;

    --Чи співпадає пароль з останнім введеним
    FUNCTION isPwdMatch (p_login IN VARCHAR2, p_pwd IN VARCHAR2)
        RETURN BOOLEAN
    IS
        l_hash             VARCHAR2 (1000);
        l_check            PLS_INTEGER := 0;
        l_wu_id            w_users.wu_id%TYPE;
        --l_wu_password w_users.wu_password%type;
        l_pwd_last_match   PLS_INTEGER := 0;
        l_cnt              PLS_INTEGER := 0;
    BEGIN
        l_check :=
            CASE
                WHEN ikis_sys.ikis_common.GetApptParam ('WEB_MATCH_PWD') =
                     'PROM'
                THEN
                    1
                ELSE
                    0
            END;
        l_pwd_last_match :=
            TO_NUMBER (
                ikis_sys.ikis_common.GetApptParam ('WEB_MATCH_PWD_CNT'));

        IF l_check = 1
        THEN
            l_hash := CalcUserPwdHash (UPPER (p_login), p_pwd);

            SELECT s.wu_id                                   --, s.wu_password
              INTO l_wu_id                                   --, l_wu_password
              FROM w_users s
             WHERE s.wu_login = UPPER (p_login);

            SELECT COUNT (*)
              INTO l_cnt
              FROM (SELECT h.wuph_password,
                           ROW_NUMBER ()
                               OVER (ORDER BY h.wuph_dt DESC NULLS LAST)    rn
                      FROM w_users_pwd_hst h
                     WHERE h.wuph_wu = l_wu_id)
             WHERE rn <= l_pwd_last_match AND wuph_password = l_hash;

            IF                                 /*(l_wu_password = l_hash) or*/
               (l_cnt > 0)
            THEN
                RETURN TRUE;
            ELSE
                RETURN FALSE;
            END IF;
        ELSE
            RETURN FALSE;
        END IF;
    END;

    --20190906 Контроль наличия штатной одиниці у іншого користувача
    FUNCTION ExistUserEpValue (p_login      IN     VARCHAR2,
                               p_ep         IN     NUMBER,
                               l_user_out      OUT VARCHAR2)
        RETURN BOOLEAN
    IS
        l_user   w_users.wu_login%TYPE;
        l_cnt    PLS_INTEGER := 0;
        l_res    BOOLEAN := FALSE;
    BEGIN
        IF NVL (p_ep, 0) > 0
        THEN
            SELECT MAX (s.wu_login), COUNT (s.wu_id) cnt
              INTO l_user, l_cnt
              FROM w_users s
             WHERE     s.wu_ep = p_ep
                   AND s.wu_locked = 'N'
                   AND s.wu_login != UPPER (NVL (p_login, '!~~!'));

            IF l_cnt > 0
            THEN
                l_res := TRUE;
                l_user_out := l_user;
            END IF;
        END IF;

        RETURN l_res;
    END;
END ikis_htmldb_auth;
/