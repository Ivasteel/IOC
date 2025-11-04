/* Formatted on 8/12/2025 6:10:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.RDM$IKIS_USERS
IS
    -- Процедура создает запись в таблице IKIS_USERS_ATTR,
    --  т.е. создает пользователя ІКІС, но не создает пользователя ORACLE
    -- Возвращает ROWID и ВРЕМЕННЫЙ идентификатор (он отрицательный) созданной записи
    PROCEDURE Create_IKIS_user (
        p_iusr_rowid   OUT ROWID,
        p_iusr_id      OUT ikis_users_attr.iusr_id%TYPE);



    -- Процедура обновляет данные пользователя ІКІС,
    --           если пользователя ORACLE небыло, то он создается
    -- Параметры: ROWID строки в таблице IKIS_USERS_ATTR;
    --           p_iu_username:  логин ORACLE-пользователя;
    --           p_iu_password:  пароль пользователя (если не пустой, то устанавливается)
    --           p_iu_status:    "A"-активный, "L"-заблокированый;
    --           p_iu_is_expired: "Y" - потребовать смену пароля, иначе - нет;
    --           p_iu_name:       ПІБ пользователя
    --           p_iu_numident:   идентификационный номер пользователя
    --           p_iu_is_admin:   "Y"-администратор, иначе - нет;
    --           p_iu_comps:      компьютеры на которых может работать пользователь
    PROCEDURE Update_IKIS_user (
        p_iu_rowid        IN ROWID,
        p_iu_username        ikis_users_attr.iusr_login%TYPE,
        p_iu_password        VARCHAR2,
        p_iu_status          CHAR,
        p_iu_is_expired      CHAR,
        p_iu_name            ikis_users_attr.iusr_name%TYPE,
        p_iu_numident        ikis_users_attr.iusr_numident%TYPE,
        p_iu_is_admin        CHAR,
        p_iu_comps           ikis_users_attr.iusr_comp%TYPE);

    --Процедура перевіряє на максимально допустипу кількіть ролей,
    --призначених одному користувачеві
    PROCEDURE CheckMaxROLES (p_is_changed_userid NUMBER);

    -- Процедура удаляет ORACLE-пользователя и ІКІС-пользователь становится удаленным
    -- Параметры: ID пользователя
    PROCEDURE Delete_IKIS_user (p_iu_oraid IN NUMBER);

    PROCEDURE Update_IKIS_user_role (p_igr_userid          NUMBER,
                                     p_irl_name            ikis_role.irl_name%TYPE,
                                     p_is_changed_userid   NUMBER);

    PROCEDURE Update_IKIS_user_group (
        p_igr_userid          NUMBER,
        p_igrp_name           ikis_group.igrp_name%TYPE,
        p_is_changed_userid   NUMBER);

    PROCEDURE Drop_IKIS_user_Group (p_group_name ikis_group.igrp_name%TYPE);

    -- Процедура дает пользователю ІКІС квоту (параметр IKIS_REPLUSR_TS_QT)
    -- на дефолтное пространство (параметр IKIS_DEF_USER_TABLESPASE)
    PROCEDURE Grant_ReplQuota (p_iu_rowid ROWID);

    -- Процедура проверяет нужно ли выдавать предупреждение при назначении роли пользователю
    -- Предупреждение нужно выдавать если роль содержит Административные, Специальные или Репликативные ресурсы
    -- Параметры: p_irl_name - роль
    --            p_irl_rsrc_tp - возвращает тип ресурса о котором надо выдать предупреждение
    --                            (если NULL, то предупреждение не нужно)
    PROCEDURE Check_GrantRoleWarn (
        p_irl_name      IN     ikis_role.irl_name%TYPE,
        p_irl_rsrc_tp      OUT VARCHAR2);


    PROCEDURE Update_IKIS_group_role (
        p_irl_name           ikis_role.irl_name%TYPE,
        p_igrp_name          ikis_group.igrp_name%TYPE,
        p_is_changed_group   VARCHAR2);

    PROCEDURE Update_IKIS_group_user (
        p_iu_username        VARCHAR2,
        p_igr_name           ikis_group.igrp_name%TYPE,
        p_is_changed_group   VARCHAR2);

    PROCEDURE Insert_IKIS_user_group (
        p_igrp_name          ikis_group.igrp_name%TYPE,
        p_igrp_comment       ikis_group.igrp_comment%TYPE,
        p_group_rowid    OUT ROWID);

    --Функція та процедура повертають кількість наданих користувачу груп
    FUNCTION Get_user_group_count (p_user IN VARCHAR2)
        RETURN NUMBER;

    PROCEDURE PGet_user_group_count (p_user IN VARCHAR2, p_count OUT NUMBER);
END RDM$IKIS_USERS;
/


CREATE OR REPLACE PUBLIC SYNONYM RDM$IKIS_USERS FOR IKIS_SYS.RDM$IKIS_USERS
/


GRANT EXECUTE ON IKIS_SYS.RDM$IKIS_USERS TO II01RC_IKIS_USERS
/


/* Formatted on 8/12/2025 6:10:05 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.RDM$IKIS_USERS
IS
    g_Audit_Mode                       CHAR (1);

    msgGREAT_MAX_ROLES                 NUMBER := 3353;

    Default_ts_quota          CONSTANT NUMBER := 0;
    Default_is_admin_option   CONSTANT CHAR (1) := ikis_const.V_DDS_YN_N; --пользователь создается как "НеАдмин"
    Default_st_option         CONSTANT CHAR (1) := ikis_const.V_DDS_USER_ST_A; --пользователь создается "Активным"

    c_GRANT_ROLE              CONSTANT NUMBER := 13;
    c_REVOKE_ROLE             CONSTANT NUMBER := 14;
    c_GRANT_GROUP             CONSTANT NUMBER := 16;
    c_REVOKE_GROUP            CONSTANT NUMBER := 17;
    C_CREATE_USER             CONSTANT NUMBER := 15;
    c_DROP_USER               CONSTANT NUMBER := 18;
    c_LOCK_USER               CONSTANT NUMBER := 19;
    c_UNLOCK_USER             CONSTANT NUMBER := 20;

    c_V_IKIS_USER             CONSTANT NUMBER := 74;
    c_OTHER_OPER              CONSTANT NUMBER := 999999;

    c_IKIS_USER                        NUMBER := 74;

    c_IKIS_MAX_ROLES          CONSTANT VARCHAR2 (100) := 'IKIS_MAX_ROLES';

    c_CREATE_USER_MODE_P      CONSTANT CHAR (1) := 'P'; --метод создания пользователя - для ПФУ
    c_CREATE_USER_MODE_N      CONSTANT CHAR (1) := 'N'; --метод создания пользователя - для НПФ

    -- Messages for category: IKIS_USER
    msgNO_IKIS_USER_FOUND              NUMBER := 764;
    msgUserGroupExists                 NUMBER := 3543;
    msgUnknownCreateUserMode           NUMBER := 4364;

    to_many_roles                      EXCEPTION;

    PROCEDURE Create_IKIS_user (
        p_iusr_rowid   OUT ROWID,
        p_iusr_id      OUT ikis_users_attr.iusr_id%TYPE)
    IS
        l_prior_usr_id   NUMBER;
    BEGIN
        SAVEPOINT one;

        SELECT seq_default_id.NEXTVAL INTO p_iusr_id FROM DUAL;

        p_iusr_id := -p_iusr_id;

        INSERT INTO ikis_users_attr (iusr_id,
                                     iusr_is_admin,
                                     iusr_st,
                                     iusr_org)
             VALUES (p_iusr_id,
                     Default_is_admin_option,
                     Default_st_option,
                     ikis_common.getap_ikis_opfu);

        SELECT ROWID
          INTO p_iusr_rowid
          FROM ikis_users_attr
         WHERE iusr_id = p_iusr_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK TO one;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'RDM$IKIS_USERS.Create_IKIS_user',
                    SQLERRM));
            RAISE;
    END;

    -- Процедура создает пользователя ORACLE и дает ему право на CREATE SESSION
    -- параметры: p_usr_login - имя создаваемого пользователя (логин),
    --            p_usr_password - пароль создаваемого пользователя
    -- Возвращает ID созданного пользователя
    PROCEDURE Create_ORACLE_user (p_usr_login      IN     VARCHAR2,
                                  p_usr_password   IN     VARCHAR2,
                                  p_usr_oraid         OUT dba_users%ROWTYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        -- табличное пространство пользователя
        l_Default_usr_ts        VARCHAR2 (250);

        -- табличное пространство для временных данных пользователя
        l_Default_usr_temp_ts   VARCHAR2 (250);

        l_ExecSQL               VARCHAR2 (2000)
            :=    'CREATE USER %<p_usr_login>% IDENTIFIED BY "%<p_usr_password>%" '
               || 'DEFAULT TABLESPACE %<p_usr_ts>% '
               || 'TEMPORARY TABLESPACE %<p_usr_temp_ts>% '
               || 'QUOTA %<p_ts_quota>% ON %<p_usr_ts>% '
               || 'PROFILE %<PROFILE>% '
               || 'ACCOUNT UNLOCK';
        l_cnt                   NUMBER;
    BEGIN
        l_Default_usr_ts :=
            ikis_common.GetApptParam ('IKIS_DEF_USER_TABLESPASE');
        l_Default_usr_temp_ts :=
            ikis_common.GetApptParam ('IKIS_DEF_USER_TEMPTS');

        SELECT COUNT (*)
          INTO l_cnt
          FROM dba_profiles
         WHERE dba_profiles.profile = 'IKIS_USERS';

        IF l_cnt > 0
        THEN
            l_ExecSQL := REPLACE (l_ExecSQL, '%<PROFILE>%', 'IKIS_USERS');
        ELSE
            l_ExecSQL := REPLACE (l_ExecSQL, '%<PROFILE>%', 'DEFAULT');
        END IF;

        l_ExecSQL := REPLACE (l_ExecSQL, '%<p_usr_login>%', p_usr_login);
        l_ExecSQL :=
            REPLACE (l_ExecSQL, '%<p_usr_password>%', p_usr_password);
        l_ExecSQL := REPLACE (l_ExecSQL, '%<p_usr_ts>%', l_Default_usr_ts);
        l_ExecSQL :=
            REPLACE (l_ExecSQL, '%<p_usr_temp_ts>%', l_Default_usr_temp_ts);
        l_ExecSQL := REPLACE (l_ExecSQL, '%<p_ts_quota>%', Default_ts_quota);

        EXECUTE IMMEDIATE l_ExecSQL;

        l_ExecSQL := 'grant create session to ' || UPPER (p_usr_login);

        EXECUTE IMMEDIATE l_ExecSQL;

        --+KYB 07.06.2005
        IF g_Audit_Mode = c_CREATE_USER_MODE_N
        THEN
            ---KYB 07.06.2005
            ikis_changes_utl.change (c_V_IKIS_USER,
                                     0,
                                     c_CREATE_USER,
                                     'USER_LOGIN=' || p_usr_login);
        END IF;

        --+ Автор: YURA_A 24.11.2003 16:05:53
        --  Описание: Более правильно и более полная информация
        --select iu_oraid
        --into p_usr_oraid
        --from v_no_ikis_users
        --where iu_username=upper(p_usr_login);
        SELECT *
          INTO p_usr_oraid
          FROM dba_users
         WHERE dba_users.username = UPPER (p_usr_login);

        COMMIT;
    --- Автор: YURA_A 24.11.2003 16:05:56
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'RDM$IKIS_USERS.Create_ORACLE_user with ' || l_ExecSQL,
                    CHR (10) || SQLERRM));
            RAISE;
    END;

    PROCEDURE Update_IKIS_user (
        p_iu_rowid        IN ROWID,
        p_iu_username        ikis_users_attr.iusr_login%TYPE,
        p_iu_password        VARCHAR2,
        p_iu_status          CHAR,
        p_iu_is_expired      CHAR,
        p_iu_name            ikis_users_attr.iusr_name%TYPE,
        p_iu_numident        ikis_users_attr.iusr_numident%TYPE,
        p_iu_is_admin        CHAR,
        p_iu_comps           ikis_users_attr.iusr_comp%TYPE)
    IS
        l_iu_old_rec    ikis_users_attr%ROWTYPE;
        --  l_iu_id ikis_users_attr.iusr_id%type;
        --  l_iu_login varchar(250);
        l_iu_is_admin   ikis_users_attr.iusr_is_admin%TYPE;
        l_ExecSQL       VARCHAR2 (2000)
            := 'alter user %<p_user_login>% account %<p_lock_option>%';
        l_users         dba_users%ROWTYPE;
        l_lockst        VARCHAR2 (30) := 'USER_STATUS=';
        l_pwdst         VARCHAR2 (30) := 'PASSWORD_STATUS=';

        l_LOGON_TRIG    VARCHAR2 (2000)
            :=    'CREATE OR REPLACE TRIGGER %<TRIGNAME>%'
               || CHR (10)
               || '  AFTER LOGON '
               || CHR (10)
               || '  ON %<p_usr_login>%.SCHEMA   '
               || CHR (10)
               || 'declare       '
               || CHR (10)
               || 'begin         '
               || CHR (10)
               || '  ikis_changes_utl.change_at(999999,0,5,IKIS_CHANGES_UTL.GetSessionParam(''SESSION_USER''));'
               || CHR (10)
               || 'end %<TRIGNAME>%; ';
        l_LOGOFF_TRIG   VARCHAR2 (2000)
            :=    'CREATE OR REPLACE TRIGGER %<TRIGNAME>%'
               || CHR (10)
               || '  BEFORE LOGOFF '
               || CHR (10)
               || '  ON %<p_usr_login>%.SCHEMA   '
               || CHR (10)
               || 'declare       '
               || CHR (10)
               || 'begin         '
               || CHR (10)
               || '  ikis_changes_utl.change_at(999999,0,7,IKIS_CHANGES_UTL.GetSessionParam(''SESSION_USER''));'
               || CHR (10)
               || 'end %<TRIGNAME>%; ';
        l_trig_name     VARCHAR2 (30);
    BEGIN
        SELECT *
          INTO l_iu_old_rec
          FROM ikis_users_attr
         WHERE ROWID = p_iu_rowid;

        --Если ORACLE-пользоватля еще нет
        IF l_iu_old_rec.iusr_id < 0
        THEN
            --создаем ORACLE-пользователя
            DECLARE
                l_mess   VARCHAR2 (2000);
            BEGIN
                Create_ORACLE_user (p_iu_username, p_iu_password, l_users);

                UPDATE ikis_users_attr
                   SET iusr_login = l_users.username,
                       iusr_id = l_users.user_id,
                       iusr_start_dt = l_users.created
                 WHERE ROWID = p_iu_rowid;

                --l_iu_login := upper(p_iu_username);
                --+ Автор: YURA_A 12.09.2003 13:14:52
                --  Описание: Перевожу назначение корневой роли на общую процедуру
                --execute immediate 'grant '||IKIS_SUBSYS_UTIL.g_IKIS_ROOT_ROLE||' to '||l_iu_login;
                ikis_security.GrantIkisRootRole (l_users.username);

                --- Автор: YURA_A 12.09.2003 13:15:10
                FOR synon IN (SELECT ss_code
                                FROM ikis_subsys
                               WHERE ss_owner IS NOT NULL)
                LOOP
                    ikis_security.CreateSubsysSynonym (synon.ss_code,
                                                       l_users.username);
                END LOOP;

                --+KYB 31.05.2005
                IF g_Audit_Mode = c_CREATE_USER_MODE_N
                THEN
                    ---KYB 31.05.2005
                    --Ryaba
                    --Надо все таки происследовать возможноться вешать триггера на схему,а не на БД
                    l_trig_name :=
                        SUBSTR (l_users.username, 1, 22) || '_LOG_ON';
                    l_LOGON_TRIG :=
                        REPLACE (
                            REPLACE (l_LOGON_TRIG,
                                     '%<p_usr_login>%',
                                     l_users.username),
                            '%<TRIGNAME>%',
                            l_trig_name);

                    EXECUTE IMMEDIATE l_LOGON_TRIG;

                    l_trig_name :=
                        SUBSTR (l_users.username, 1, 22) || '_LOG_OFF';
                    l_LOGOFF_TRIG :=
                        REPLACE (
                            REPLACE (l_LOGOFF_TRIG,
                                     '%<p_usr_login>%',
                                     l_users.username),
                            '%<TRIGNAME>%',
                            l_trig_name);

                    EXECUTE IMMEDIATE l_LOGOFF_TRIG;
                END IF;
            EXCEPTION
                WHEN OTHERS
                THEN
                    l_mess := SQLERRM;

                    DELETE FROM ikis_users_attr
                          WHERE ROWID = p_iu_rowid;

                    raise_application_error (
                        -20000,
                        ikis_message_util.GET_MESSAGE (
                            ikis_message_util.msgCOMMON_EXCEPTION,
                            'RDM$IKIS_USERS.Update_IKIS_user',
                            l_mess));
            END;

            DECLARE
                l_mess   VARCHAR2 (2000);
            BEGIN
                --если статус пользователя Активный, то делаем UNLOCK
                IF p_iu_status = ikis_const.v_dds_user_st_a
                THEN
                    l_ExecSQL :=
                        REPLACE (l_ExecSQL,
                                 '%<p_user_login>%',
                                 l_users.username);
                    l_ExecSQL :=
                        REPLACE (l_ExecSQL, '%<p_lock_option>%', 'UNLOCK');

                    EXECUTE IMMEDIATE l_ExecSQL;

                    l_lockst := l_lockst || 'UNLOCK';
                --если статус пользователя Заблокированый, то делаем LOCK
                ELSIF p_iu_status = ikis_const.v_dds_user_st_l
                THEN
                    l_ExecSQL :=
                        REPLACE (l_ExecSQL,
                                 '%<p_user_login>%',
                                 l_users.username);
                    l_ExecSQL :=
                        REPLACE (l_ExecSQL, '%<p_lock_option>%', 'LOCK');

                    EXECUTE IMMEDIATE l_ExecSQL;

                    l_lockst := l_lockst || 'LOCK';
                -- Если статус неопознан, то EXCEPTION
                ELSE
                    ---raise_application_error(-20000,ikis_message_util.Get_Message(ikis_message_util.msgCOMMON_EXCEPTION,'RDM$IKIS_USERS.Update_IKIS_user',sqlerrm));
                    NULL;
                END IF;

                --Если нужно делаем PASSWORD EXPIRE
                l_pwdst := l_pwdst || 'WORK';

                IF p_iu_is_expired = ikis_const.v_dds_yn_y
                THEN
                    l_ExecSQL :=
                           'alter user '
                        || l_users.username
                        || ' password expire';

                    EXECUTE IMMEDIATE l_ExecSQL;

                    l_pwdst := l_pwdst || 'EXPIRE';
                END IF;

                --Определяем значение поля is_admin
                IF p_iu_is_admin = ikis_const.v_dds_yn_y
                THEN
                    l_iu_is_admin := IKIS_CONST.V_DDS_YN_Y;
                ELSE
                    l_iu_is_admin := IKIS_CONST.V_DDS_YN_N;
                END IF;

                -- Выполняем UPDATE полей таблицы IKIS_USERS_ATTR
                BEGIN
                    UPDATE ikis_users_attr
                       SET iusr_name = p_iu_name,
                           iusr_numident = p_iu_numident,
                           iusr_is_admin = l_iu_is_admin,
                           iusr_st = p_iu_status,
                           iusr_comp = p_iu_comps
                     WHERE ROWID = p_iu_rowid;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        ROLLBACK;
                        RAISE;
                END;

                --+KYB 31.05.2005
                IF g_Audit_Mode = c_CREATE_USER_MODE_N
                THEN
                    ---KYB 31.05.2005
                    ikis_changes_utl.savedata (
                        p_actid   => ikis_const.V_DDS_USR_AU_1,
                        p_ibj     => ikis_const.dic_v_dds_usr_au,
                        p_ibjid   => l_users.user_id,
                        p_par1    =>
                               'USER='
                            || p_iu_username
                            || '; '
                            || 'PIB='
                            || p_iu_name
                            || '; '
                            || 'NUMID='
                            || p_iu_numident
                            || '; '
                            || l_lockst
                            || '; '
                            || l_pwdst);
                END IF;
            EXCEPTION
                -- если EXCEPTION, то удаляет только что созданного ORACLE-пользователя
                -- и удаляем строку из таблицы IKIS_USERS_ATTR
                WHEN OTHERS
                THEN
                    l_mess := SQLERRM;
                    --         l_ExecSQL:='drop user '||l_iu_login||' cascade';
                    --         execute immediate l_ExecSQL;
                    --         delete from ikis_users_attr where rowid=p_iu_rowid;
                    raise_application_error (
                        -20000,
                        ikis_message_util.GET_MESSAGE (
                            ikis_message_util.msgCOMMON_EXCEPTION,
                               'RDM$IKIS_USERS.Update_IKIS_user witn '
                            || l_ExecSQL,
                            CHR (10) || l_mess));
            END;
        ELSE
            --    l_iu_id := l_iu_old_rec.iusr_id;
            --    l_iu_login := l_iu_old_rec.iusr_login;
            BEGIN
                --если статус пользователя Активный, то делаем UNLOCK
                IF p_iu_status = 'A'
                THEN
                    l_ExecSQL :=
                        REPLACE (l_ExecSQL,
                                 '%<p_user_login>%',
                                 l_iu_old_rec.iusr_login);
                    l_ExecSQL :=
                        REPLACE (l_ExecSQL, '%<p_lock_option>%', 'UNLOCK');

                    EXECUTE IMMEDIATE l_ExecSQL;

                    --+KYB 03.06.2005
                    IF g_Audit_Mode = c_CREATE_USER_MODE_N
                    THEN
                        ---KYB 03.06.2005
                        ikis_changes_utl.change (
                            c_V_IKIS_USER,
                            0,
                            c_UNLOCK_USER,
                            'USER_LOGIN=' || l_iu_old_rec.iusr_login);
                        ikis_changes_utl.savedata (
                            p_actid   => ikis_const.V_DDS_USR_AU_5,
                            p_ibj     => ikis_const.dic_v_dds_usr_au,
                            p_ibjid   => l_iu_old_rec.iusr_id);
                    END IF;
                --если статус пользователя Заблокированый, то делаем LOCK
                ELSIF p_iu_status = 'L'
                THEN
                    l_ExecSQL :=
                        REPLACE (l_ExecSQL,
                                 '%<p_user_login>%',
                                 l_iu_old_rec.iusr_login);
                    l_ExecSQL :=
                        REPLACE (l_ExecSQL, '%<p_lock_option>%', 'LOCK');

                    EXECUTE IMMEDIATE l_ExecSQL;

                    --+KYB 03.06.2005
                    IF g_Audit_Mode = c_CREATE_USER_MODE_N
                    THEN
                        ---KYB 03.06.2005
                        ikis_changes_utl.change (
                            c_V_IKIS_USER,
                            0,
                            c_LOCK_USER,
                            'USER_LOGIN=' || l_iu_old_rec.iusr_login);

                        ikis_changes_utl.savedata (
                            p_actid   => ikis_const.V_DDS_USR_AU_4,
                            p_ibj     => ikis_const.dic_v_dds_usr_au,
                            p_ibjid   => l_iu_old_rec.iusr_id);
                    END IF;
                -- Если статус неопознан, то EXCEPTION
                ELSE
                    --raise_application_error(-20000,ikis_message_util.Get_Message(ikis_message_util.msgCOMMON_EXCEPTION,'RDM$IKIS_USERS.Update_IKIS_user',sqlerrm));
                    NULL;
                END IF;

                --Если введен пароль, то устанавливаем его
                IF TRIM (BOTH ' ' FROM p_iu_password) IS NOT NULL
                THEN
                    EXECUTE IMMEDIATE   'alter user '
                                     || l_iu_old_rec.iusr_login
                                     || ' identified by "'
                                     || p_iu_password
                                     || '"';
                --raise_application_error(-20000,'alter user '||l_iu_login||' identified by "'||p_iu_password||'"'||chr(10)||sqlerrm);
                END IF;

                --Если нужно делаем PASSWORD EXPIRE
                IF p_iu_is_expired = 'Y'
                THEN
                    l_ExecSQL :=
                           'alter user '
                        || l_iu_old_rec.iusr_login
                        || ' password expire';

                    EXECUTE IMMEDIATE l_ExecSQL;

                    ikis_changes_utl.savedata (
                        p_actid   => ikis_const.V_DDS_USR_AU_6,
                        p_ibj     => ikis_const.dic_v_dds_usr_au,
                        p_ibjid   => l_iu_old_rec.iusr_id);
                END IF;

                --Определяем значение поля is_admin
                IF p_iu_is_admin = 'Y'
                THEN
                    l_iu_is_admin := IKIS_CONST.V_DDS_YN_Y;
                ELSE
                    l_iu_is_admin := IKIS_CONST.V_DDS_YN_N;
                END IF;

                -- Выполняем UPDATE полей таблицы IKIS_USERS_ATTR
                BEGIN
                    UPDATE ikis_users_attr
                       SET iusr_name = p_iu_name,
                           iusr_numident = p_iu_numident,
                           iusr_is_admin = l_iu_is_admin,
                           iusr_st = p_iu_status,
                           iusr_comp = p_iu_comps
                     WHERE ROWID = p_iu_rowid;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        ROLLBACK;
                        RAISE;
                END;
            EXCEPTION
                WHEN OTHERS
                THEN
                    raise_application_error (
                        -20000,
                        ikis_message_util.GET_MESSAGE (
                            ikis_message_util.msgCOMMON_EXCEPTION,
                            'RDM$IKIS_USERS.Update_IKIS_user with ',
                            CHR (10) || SQLERRM));
            END;
        END IF;
    END;

    PROCEDURE Delete_IKIS_user (p_iu_oraid IN NUMBER)
    IS
        l_iu_username   ikis_users_attr.iusr_login%TYPE;
    BEGIN
        SELECT iusr_login
          INTO l_iu_username
          FROM ikis_users_attr
         WHERE iusr_id = p_iu_oraid;

        EXECUTE IMMEDIATE 'drop user ' || l_iu_username || ' cascade';

        UPDATE ikis_users_attr
           SET iusr_st = ikis_const.v_dds_dics_st_d, iusr_stop_dt = SYSDATE
         WHERE iusr_id = p_iu_oraid;

        --+KYB 03.06.2005
        IF g_Audit_Mode = c_CREATE_USER_MODE_N
        THEN
            ---KYB 03.06.2005
            ikis_changes_utl.change (c_V_IKIS_USER,
                                     0,
                                     c_DROP_USER,
                                     'USER_LOGIN=' || l_iu_username);

            ikis_changes_utl.savedata (
                p_actid   => ikis_const.V_DDS_USR_AU_9,
                p_ibj     => ikis_const.dic_v_dds_usr_au,
                p_ibjid   => p_iu_oraid);
        END IF;

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'RDM$IKIS_USERS.Delete_IKIS_user with ',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE CheckMaxROLES (p_is_changed_userid NUMBER)
    IS
        l_user_name   ikis_users_attr.iusr_login%TYPE;
        l_max_roles   NUMBER;
    BEGIN
        SELECT iusr_login
          INTO l_user_name
          FROM ikis_users_attr
         WHERE iusr_id = p_is_changed_userid;

        --Кількість наданих користувачеві ролей
        --не повинна перевищувати задану
        SELECT CASE
                   WHEN (SELECT aptprm_value
                           FROM appt_params
                          WHERE aptprm_name = c_IKIS_MAX_ROLES) >
                        (SELECT COUNT (igr_userid)
                           FROM v_all_ikis_granted_role
                          WHERE igr_username = l_user_name)
                   THEN
                       0
                   ELSE
                       1
               END
          INTO l_max_roles
          FROM DUAL;

        IF l_max_roles = 1
        THEN
            RAISE to_many_roles;
        END IF;
    EXCEPTION
        WHEN to_many_roles
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgGREAT_MAX_ROLES));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'RDM$IKIS_USERS.CheckMaxROLES with ',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE Update_IKIS_user_role (p_igr_userid          NUMBER,
                                     p_irl_name            ikis_role.irl_name%TYPE,
                                     p_is_changed_userid   NUMBER)
    IS
        l_user_name   ikis_users_attr.iusr_login%TYPE;
    BEGIN
        IF NOT (p_is_changed_userid = 0)
        THEN
            SELECT iusr_login
              INTO l_user_name
              FROM ikis_users_attr
             WHERE     iusr_id = p_is_changed_userid
                   AND iusr_org = ikis_common.GetAP_IKIS_OPFU; --Yura_AP 2005-10-10 добавил фильтр по узло (в центре данные из других районов там есть)

            IF p_igr_userid IS NULL
            THEN
                ikis_security.RevokeIkisRole (l_user_name, p_irl_name);

                --      ikis_changes_utl.savedata(p_actid => ikis_const.V_DDS_USR_AU_8,
                --                                p_ibj => ikis_const.dic_v_dds_usr_au,
                --                                p_ibjid => p_is_changed_userid,
                --                                p_par1 => 'ROLE='||ikis_subsys_util.getinstancepref||p_irl_name);
                --+KYB 03.06.2005
                IF g_Audit_Mode = c_CREATE_USER_MODE_N
                THEN
                    ---KYB 03.06.2005
                    ikis_changes_utl.change (
                        c_IKIS_USER,
                        p_is_changed_userid,
                        c_REVOKE_ROLE,
                           'ROLE='
                        || ikis_subsys_util.getinstancepref
                        || p_irl_name
                        || '#@#'
                        || 'USER='
                        || l_user_name);
                END IF;
            ELSE
                ikis_security.GrantIkisRole (l_user_name, p_irl_name);

                --      ikis_changes_utl.savedata(p_actid => ikis_const.V_DDS_USR_AU_7,
                --                                p_ibj => ikis_const.dic_v_dds_usr_au,
                --                                p_ibjid => p_is_changed_userid,
                --                                p_par1 => 'ROLE='||ikis_subsys_util.getinstancepref||p_irl_name);
                --+KYB 03.06.2005
                IF g_Audit_Mode = c_CREATE_USER_MODE_N
                THEN
                    ---KYB 03.06.2005
                    ikis_changes_utl.change (
                        c_IKIS_USER,
                        p_is_changed_userid,
                        c_GRANT_ROLE,
                           'ROLE='
                        || ikis_subsys_util.getinstancepref
                        || p_irl_name
                        || '#@#'
                        || 'USER='
                        || l_user_name);
                END IF;
            END IF;

            COMMIT;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'RDM$IKIS_USERS.Update_IKIS_user_role with ',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE Update_IKIS_user_group (
        p_igr_userid          NUMBER,
        p_igrp_name           ikis_group.igrp_name%TYPE,
        p_is_changed_userid   NUMBER)
    IS
        l_user_name   ikis_users_attr.iusr_login%TYPE;
    BEGIN
        IF NOT (p_is_changed_userid = 0)
        THEN
            SELECT iusr_login
              INTO l_user_name
              FROM ikis_users_attr
             WHERE iusr_id = p_is_changed_userid;

            IF p_igr_userid IS NULL
            THEN
                ikis_security.RevokeIkisGroup (l_user_name, p_igrp_name);
                ikis_changes_utl.change (
                    c_IKIS_USER,
                    p_is_changed_userid,
                    c_REVOKE_GROUP,
                       'GROUP='
                    || ikis_subsys_util.getinstancepref
                    || p_igrp_name
                    || '#@#'
                    || 'USER='
                    || l_user_name);
            ELSE
                ikis_security.GrantIkisGroup (l_user_name, p_igrp_name);
                ikis_changes_utl.change (
                    c_IKIS_USER,
                    p_is_changed_userid,
                    c_GRANT_GROUP,
                       'GROUP='
                    || ikis_subsys_util.getinstancepref
                    || p_igrp_name
                    || '#@#'
                    || 'USER='
                    || l_user_name);
            END IF;

            COMMIT;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'RDM$IKIS_USERS.Update_IKIS_user_group with ',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE Drop_IKIS_user_Group (p_group_name ikis_group.igrp_name%TYPE)
    IS
    BEGIN
        ikis_security_util.Drop_IKIS_Group (p_group_name);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'RDM$IKIS_USERS.Drop_IKIS_user_Group with ',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE Grant_ReplQuota (p_iu_rowid ROWID)
    IS
        l_ExecSQL      VARCHAR2 (2000)
            := 'alter user %<p_username>% quota %<p_quota>% on %<p_tablespace>%';
        l_SetQuota     VARCHAR2 (255);
        l_UserName     VARCHAR2 (255);
        l_TableSpace   VARCHAR2 (255);
    BEGIN
        l_SetQuota := ikis_common.GetApptParam ('IKIS_REPLUSR_TS_QT');
        l_TableSpace := ikis_common.GetApptParam ('IKIS_DEF_USER_TABLESPASE');

        SELECT iusr_login
          INTO l_UserName
          FROM ikis_users_attr
         WHERE ROWID = p_iu_rowid;

        l_ExecSQL := REPLACE (l_ExecSQL, '%<p_username>%', l_UserName);
        l_ExecSQL := REPLACE (l_ExecSQL, '%<p_quota>%', l_SetQuota);
        l_ExecSQL := REPLACE (l_ExecSQL, '%<p_tablespace>%', l_TableSpace);

        EXECUTE IMMEDIATE l_ExecSQL;

        l_ExecSQL := 'grant create table to %<p_username>%';
        l_ExecSQL := REPLACE (l_ExecSQL, '%<p_username>%', l_UserName);

        EXECUTE IMMEDIATE l_ExecSQL;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgNO_IKIS_USER_FOUND));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'RDM$IKIS_USERS.Grant_ReplQuota with ',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE Check_GrantRoleWarn (
        p_irl_name      IN     ikis_role.irl_name%TYPE,
        p_irl_rsrc_tp      OUT VARCHAR2)
    IS
        l_Counter   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO l_Counter
          FROM ikis_resource, ikis_rsrc2role
         WHERE     rsrc_name = rs2r_rsrc
               AND rs2r_irl = p_irl_name
               AND rsrc_tp = ikis_const.v_dds_resource_tp_A;

        IF l_Counter > 0
        THEN
            p_irl_rsrc_tp := ikis_const.txt_v_dds_resource_tp_A;
        ELSE
            SELECT COUNT (*)
              INTO l_Counter
              FROM ikis_resource, ikis_rsrc2role
             WHERE     rsrc_name = rs2r_rsrc
                   AND rs2r_irl = p_irl_name
                   AND rsrc_tp = ikis_const.v_dds_resource_tp_R;

            IF l_Counter > 0
            THEN
                p_irl_rsrc_tp := ikis_const.txt_v_dds_resource_tp_R;
            END IF;
        END IF;
    END;

    PROCEDURE Update_IKIS_group_role (
        p_irl_name           ikis_role.irl_name%TYPE,
        p_igrp_name          ikis_group.igrp_name%TYPE,
        p_is_changed_group   VARCHAR2)
    IS
    BEGIN
        IF NOT (TRIM (BOTH ' ' FROM p_is_changed_group) IS NULL)
        THEN
            IF p_igrp_name IS NULL
            THEN
                ikis_security.RevokeIkisRole2Group (p_irl_name,
                                                    p_is_changed_group);
            --      ikis_changes_utl.change(c_IKIS_USER,
            --                              p_is_changed_userid,
            --                              c_REVOKE_GROUP,
            --                              'GROUP='||ikis_subsys_util.getinstancepref||p_igrp_name||'#@#'||'USER='||l_user_name);
            ELSE
                Ikis_security.GrantIkisRole2Group (p_irl_name, p_igrp_name);
            --      ikis_changes_utl.change(c_IKIS_USER,
            --                              p_is_changed_userid,
            --                              c_GRANT_GROUP,
            --                              'GROUP='||ikis_subsys_util.getinstancepref||p_igrp_name||'#@#'||'USER='||l_user_name);
            END IF;
        --    commit;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'RDM$IKIS_USERS.Update_IKIS_group_role with ',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE Update_IKIS_group_user (
        p_iu_username        VARCHAR2,
        p_igr_name           ikis_group.igrp_name%TYPE,
        p_is_changed_group   VARCHAR2)
    IS
    BEGIN
        IF NOT (TRIM (BOTH ' ' FROM p_is_changed_group) IS NULL)
        THEN
            IF p_igr_name IS NULL
            THEN
                ikis_security.RevokeIkisGroup (p_iu_username,
                                               p_is_changed_group);
            --      ikis_changes_utl.change(c_IKIS_USER,
            --                              p_is_changed_userid,
            --                              c_REVOKE_GROUP,
            --                              'GROUP='||ikis_subsys_util.getinstancepref||p_igrp_name||'#@#'||'USER='||l_user_name);
            ELSE
                Ikis_security.GrantIkisGroup (p_iu_username,
                                              p_is_changed_group);
            --      ikis_changes_utl.change(c_IKIS_USER,
            --                              p_is_changed_userid,
            --                              c_GRANT_GROUP,
            --                              'GROUP='||ikis_subsys_util.getinstancepref||p_igrp_name||'#@#'||'USER='||l_user_name);
            END IF;
        --    commit;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'RDM$IKIS_USERS.Update_IKIS_group_user with ',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE Insert_IKIS_user_group (
        p_igrp_name          ikis_group.igrp_name%TYPE,
        p_igrp_comment       ikis_group.igrp_comment%TYPE,
        p_group_rowid    OUT ROWID)
    IS
        l_cnt   INTEGER;
        l_ss    INTEGER := 1000;
    BEGIN
        SELECT COUNT (*)
          INTO l_cnt
          FROM ikis_group x
         WHERE igrp_name = UPPER (p_igrp_name);

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgUserGroupExists));
        ELSE
            ikis_security_util.add_ikis_group (p_igrp_name,
                                               l_ss,
                                               p_igrp_comment);
        END IF;

        SELECT ROWID
          INTO p_group_rowid
          FROM ikis_group
         WHERE igrp_name = UPPER (p_igrp_name);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'RDM$IKIS_USERS.Insert_IKIS_user_group with ',
                    CHR (10) || SQLERRM));
    END;

    FUNCTION Get_user_group_count (p_user IN VARCHAR2)
        RETURN NUMBER
    IS
        l_count   NUMBER;
    BEGIN
        --  debug.f('Start function Get_user_group_count');
        SELECT COUNT (granted_role)
          INTO l_count
          FROM dba_role_privs
         WHERE     grantee = UPPER (p_user)
               AND granted_role LIKE
                       ikis_subsys_util.getinstancepref || 'GRP%';

        --  debug.f('Stop function Get_user_group_count');
        RETURN l_count;
    EXCEPTION
        WHEN OTHERS
        THEN
            --       debug.f('Exception execution in function Get_user_group_count '||sqlerrm);
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'RDM$IKIS_USERS.Get_user_group_count with ',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE PGet_user_group_count (p_user IN VARCHAR2, p_count OUT NUMBER)
    IS
    BEGIN
        --  debug.f('Start procedure PGet_user_group_count');
        p_count := Get_User_Group_Count (p_user);
    --  debug.f('Stop procedure PGet_user_group_count');
    EXCEPTION
        WHEN OTHERS
        THEN
            --       debug.f('Exception execution in procedure PGet_user_group_count '||sqlerrm);
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    ikis_message_util.msgCOMMON_EXCEPTION,
                    'RDM$IKIS_USERS.Get_user_group_count with',
                    CHR (10) || SQLERRM));
    END;

    PROCEDURE Init
    IS
    BEGIN
        Ikis_Parameter_Util.GetParameter ('AUDIT_MODE',
                                          'IKIS_SYS',
                                          g_Audit_Mode);

        IF NOT g_Audit_Mode IN (c_CREATE_USER_MODE_P, c_CREATE_USER_MODE_N)
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgUnknownCreateUserMode,
                                               g_Audit_Mode));
        END IF;
    END;
BEGIN
    Init;
END RDM$IKIS_USERS;
/