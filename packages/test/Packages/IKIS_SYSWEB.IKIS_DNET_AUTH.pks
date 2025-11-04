/* Formatted on 8/12/2025 6:11:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.IKIS_DNET_AUTH
IS
    -- Author  : MAXYM
    -- Created : 06.02.2017 11:26:19
    -- Purpose : Спрощена авторизація для .NET аплікацій

    --------------------------------------------------------------------------
    -- + shost 15.05.2019
    -- Создание попытки логина
    --------------------------------------------------------------------------
    FUNCTION CreateLoginAttempt
        RETURN VARCHAR2;

    --------------------------------------------------------------------------
    -- + shost 15.05.2019
    -- Возвращает JS массив с типами ключей для логина
    --------------------------------------------------------------------------
    FUNCTION GetLoginKeyTypes
        RETURN CLOB;

    --------------------------------------------------------------------------
    -- + shost 15.05.2019
    -- Возвращает JS объект с параметрами криптографии для модуля аутентификации
    --------------------------------------------------------------------------
    FUNCTION GetCryptoParams
        RETURN VARCHAR2;

    -- Аутентифікація користувача. В разі наявності повертає інформаціяю про користувача в p_user_info, про його ролі в p_user_roles.
    -- В разі невдалої аутентифікації виникає виключення NO_DATA_FOUND
    PROCEDURE Login (p_username               IN     VARCHAR2,
                     p_password               IN     VARCHAR2,
                     p_session_lifetime_sec   IN     PLS_INTEGER,
                     p_session_id                OUT VARCHAR2,
                     p_user_info                 OUT SYS_REFCURSOR,
                     p_user_roles                OUT SYS_REFCURSOR,
                     p_login_tp               IN     VARCHAR2 DEFAULT NULL,
                     p_attempt                IN     VARCHAR2 DEFAULT NULL,
                     p_attempt_payload        IN     CLOB DEFAULT NULL,
                     p_ip_address             IN     VARCHAR2 DEFAULT NULL);

    -- Перевірка сесії та отримання відповідного їй логіна користувач
    -- В разі відсутності або засторілості сесії виникає виключення NO_DATA_FOUND
    PROCEDURE CheckSession (p_session_id IN VARCHAR2, p_login OUT VARCHAR2);

    -- Перевірка сесії та отримання відповідного їй інформації про користувача
    -- В разі відсутності або засторілості сесії виникає виключення NO_DATA_FOUND
    PROCEDURE GetUserInfo (p_session_id       VARCHAR2,
                           p_user_info    OUT SYS_REFCURSOR,
                           p_user_roles   OUT SYS_REFCURSOR);

    -- Завершення сесії
    PROCEDURE CloseSession (p_session_id IN VARCHAR2);

    -- Перевірка параметрів користувача
    FUNCTION ikis_auth (p_username IN VARCHAR2, p_password IN VARCHAR2)
        RETURN BOOLEAN;
END IKIS_DNET_AUTH;
/


GRANT EXECUTE ON IKIS_SYSWEB.IKIS_DNET_AUTH TO DNET_PROXY
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_DNET_AUTH TO II01RC_SYSWEB_COMM
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_DNET_AUTH TO IKIS_FINZVIT
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_DNET_AUTH TO IKIS_PERSON
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_DNET_AUTH TO IKIS_RBM
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_DNET_AUTH TO IKIS_WEBPROXY
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_DNET_AUTH TO USS_CEA
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_DNET_AUTH TO USS_DOC
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_DNET_AUTH TO USS_ESR
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_DNET_AUTH TO USS_EXCH
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_DNET_AUTH TO USS_NDI
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_DNET_AUTH TO USS_PERSON
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_DNET_AUTH TO USS_RNSP
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_DNET_AUTH TO USS_RPT
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_DNET_AUTH TO USS_VISIT
/


/* Formatted on 8/12/2025 6:11:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.IKIS_DNET_AUTH
IS
    --------------------------------------------------------------------------
    -- + shost 15.05.2019
    -- Создание попытки логина
    --------------------------------------------------------------------------
    FUNCTION CreateLoginAttempt
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN ikis_htmldb_auth.CreateLoginAttempt;
    END;

    --------------------------------------------------------------------------
    -- + shost 15.05.2019
    -- Возвращает JS массив с типами ключей для логина
    --------------------------------------------------------------------------
    FUNCTION GetLoginKeyTypes
        RETURN CLOB
    IS
    BEGIN
        RETURN ikis_htmldb_ui.Get_Key_Types;
    END;

    --------------------------------------------------------------------------
    -- + shost 15.05.2019
    -- Возвращает JS объект с параметрами криптографии для модуля аутентификации
    --------------------------------------------------------------------------
    FUNCTION GetCryptoParams
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN ikis_htmldb_ui.Get_Crypto_Params;
    END;

    -- Створення випадкової частини ключа сесії
    FUNCTION GenerateCode
        RETURN DNET_SESSION.DS_CODE%TYPE
    IS
        l_res   DNET_SESSION.DS_CODE%TYPE;
    BEGIN
        SELECT      ORA_HASH (SYS_GUID () || 'ks12$')
                  * ORA_HASH (
                           TO_CHAR (SYSTIMESTAMP, 'MMYYYYSSDDHH24MISSxFF')
                        || 'As02!')
               || ''
          INTO l_res
          FROM DUAL;

        RETURN l_res;
    END;

    -- Отримання с ідентифікатору сесії випадкової та унікальної частин
    PROCEDURE parseSessId (p_session_id       VARCHAR2,
                           p_id           OUT NUMBER,
                           p_code         OUT VARCHAR2)
    IS
        l_pos   PLS_INTEGER;
    BEGIN
        l_pos := INSTR (p_session_id, '-');

        IF (l_pos <= 0)
        THEN
            RAISE NO_DATA_FOUND;
        END IF;

        p_id := TO_NUMBER (SUBSTR (p_session_id, 1, l_pos - 1));
        p_code := SUBSTR (p_session_id, l_pos + 1);
    END;

    -- Створення запису в таблиці сесій
    PROCEDURE CreateSession (p_login          IN     DNET_SESSION.DS_LOGIN%TYPE,
                             p_lifetime_sec   IN     PLS_INTEGER,
                             p_sess_id           OUT VARCHAR2)
    IS
        l_id         DNET_SESSION.ds_id%TYPE;
        l_code       DNET_SESSION.DS_CODE%TYPE;
        l_start_dt   DATE;
        l_end_dt     DATE;
    BEGIN
        l_code := GenerateCode ();
        l_start_dt := SYSDATE;
        l_end_dt := l_start_dt + p_lifetime_sec / 24 / 60 / 60;

        INSERT INTO DNET_SESSION (ds_code,
                                  ds_start_dt,
                                  ds_end_dt,
                                  history_status,
                                  ds_login)
             VALUES (l_code,
                     l_start_dt,
                     l_end_dt,
                     'A',
                     p_login)
             RETURN ds_id
               INTO l_id;

        p_sess_id := l_id || '-' || l_code;
    END;

    -- Інформація про користувач по логіну
    PROCEDURE getInfoByLogin (l_upper_login   IN     VARCHAR2,
                              p_user_info        OUT SYS_REFCURSOR,
                              p_user_roles       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_user_info FOR
            SELECT wu_id,
                   wu_wut,
                   wu_org,
                   (SELECT org_org
                      FROM v$v_opfu_all
                     WHERE org_id = wu_org)    wu_org_org,
                   (SELECT org_acc_org
                      FROM v_opfu
                     WHERE org_id = wu_org)    wu_org_acc_org,
                   wu_trc,
                   wu_login,
                   wu_pib,
                   wu_numid,
                   wut_code,
                   wut_name,
                   (SELECT org_to
                      FROM v$v_opfu_all
                     WHERE org_id = wu_org)    wu_org_to
              FROM w_users LEFT JOIN W_USER_TYPE ON wu_wut = wut_id
             WHERE wu_login = l_upper_login;

        OPEN p_user_roles FOR SELECT r.wr_id,
                                     r.wr_name,
                                     r.wr_wut,
                                     r.wr_descr
                                FROM w_usr2roles  j
                                     JOIN w_roles r ON j.wr_id = r.wr_id
                                     JOIN w_users u ON j.wu_id = u.wu_id
                               WHERE u.wu_login = l_upper_login;
    END;

    PROCEDURE Login (p_username               IN     VARCHAR2,
                     p_password               IN     VARCHAR2,
                     p_session_lifetime_sec   IN     PLS_INTEGER,
                     p_session_id                OUT VARCHAR2,
                     p_user_info                 OUT SYS_REFCURSOR,
                     p_user_roles                OUT SYS_REFCURSOR,
                     p_login_tp               IN     VARCHAR2 DEFAULT NULL,
                     p_attempt                IN     VARCHAR2 DEFAULT NULL,
                     p_attempt_payload        IN     CLOB DEFAULT NULL,
                     p_ip_address             IN     VARCHAR2 DEFAULT NULL)
    IS
        l_upper_login   VARCHAR2 (30) := UPPER (p_username);
    BEGIN
        -- + shost 15.05.2019
        ikis_web_context.SetContextDnetLogin (
            p_login_tp        => p_login_tp,
            p_login_attempt   => p_attempt,
            p_login_ip        => p_ip_address);

        --Сохраняем шифрованный блок(для аутентификации по ЕЦП) -- + shost 15.05.2019
        ikis_htmldb_auth.SetLoginAttemptPayload (
            p_Wla_Session    => p_attempt,
            p_Wla_Payload    => p_attempt_payload,
            p_Wla_Login_Tp   => p_login_tp);

        IF (NOT ikis_htmldb_auth.ikis_auth (p_username   => l_upper_login,
                                            p_password   => p_password))
        THEN
            RAISE NO_DATA_FOUND;
        END IF;

        CreateSession (p_login          => l_upper_login,
                       p_lifetime_sec   => p_session_lifetime_sec,
                       p_sess_id        => p_session_id);


        --raise_application_error(-20000, 'TEST WU_ORG_TO');
        getInfoByLogin (l_upper_login, p_user_info, p_user_roles);
    END;


    PROCEDURE GetUserInfo (p_session_id       VARCHAR2,
                           p_user_info    OUT SYS_REFCURSOR,
                           p_user_roles   OUT SYS_REFCURSOR)
    IS
        l_upper_login   VARCHAR2 (30);
    BEGIN
        CheckSession (p_session_id, l_upper_login);
        getInfoByLogin (l_upper_login, p_user_info, p_user_roles);
    END;

    PROCEDURE CheckSession (p_session_id IN VARCHAR2, p_login OUT VARCHAR2)
    IS
        l_id     NUMBER;
        l_code   DNET_SESSION.DS_CODE%TYPE;
    BEGIN
        parseSessId (p_session_id, l_id, l_code);

        SELECT ds_login
          INTO p_login
          FROM DNET_SESSION
         WHERE     ds_id = l_id
               AND ds_code = l_code
               AND ds_end_dt >= SYSDATE
               AND history_status = 'A';
    END;

    PROCEDURE CloseSession (p_session_id IN VARCHAR2)
    IS
        l_id     NUMBER;
        l_code   DNET_SESSION.DS_CODE%TYPE;
    BEGIN
        parseSessId (p_session_id, l_id, l_code);

        UPDATE DNET_SESSION
           SET HISTORY_STATUS = 'D'
         WHERE ds_id = l_id AND ds_code = l_code;
    END;

    FUNCTION ikis_auth (p_username IN VARCHAR2, p_password IN VARCHAR2)
        RETURN BOOLEAN
    IS
        l_upper_login   VARCHAR2 (30) := UPPER (p_username);
    BEGIN
        RETURN ikis_htmldb_auth.ikis_auth (p_username   => l_upper_login,
                                           p_password   => p_password);
    END;
END IKIS_DNET_AUTH;
/