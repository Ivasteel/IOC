/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_AUD_PROCESS
IS
    -- Author  : VANO
    -- Created : 29.07.2013 16:54:08
    -- Purpose : Функції ядра підсистеми ведення аудиту. Обробка та запис аудиту.
    -- !!!! НЕ ДЕЛАТЬ ССЫЛОК НА IKIS_AUDIT и IKIS_AUDIT_UTL !!!!

    PROCEDURE ProcessTransitMsg (p_msg t_audit_message);

    PROCEDURE ProcessTransitMsgEx (p_msg_body XMLTYPE);

    PROCEDURE SendAuditToMainBuffer;

    PROCEDURE ProcessAuditBuffer;

    PROCEDURE ClearProcessedAuditBuffer;
END IKIS_AUD_PROCESS;
/


/* Formatted on 8/12/2025 6:10:01 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_AUD_PROCESS
IS
    g_session_data    ikis_changes%ROWTYPE;
    g_user_activity   ikis_user_activity%ROWTYPE;
    g_ao_tp           ikis_aud_oper.ao_tp%TYPE;

    c_pwd             VARCHAR2 (8)
        := RPAD (TRIM (BOTH '0' FROM IKIS_COMMON.GetAP_IKIS_OPFU),
                 8,
                 TRIM (BOTH '0' FROM IKIS_COMMON.GetAP_IKIS_OPFU));

    --Життєвий цикл повідомлення:
    ----1. В центральній базі даних (R/T=вставлено|отримано -> X=обробляється -> Z=оброблено, можна видаляти)
    ----2. В інших базах (R=вставлено -> M=передається в центрульну базу -> Z=оброблено, можна видаляти)

    --Инициализация заголовка вставляемой записи аудита.
    PROCEDURE InitSession (p_msg XMLTYPE)
    IS
        v_ao_code   ikis_aud_oper.ao_code%TYPE;
        v_ao_id     ikis_aud_oper.ao_id%TYPE;
    BEGIN
        g_session_data.ich_id := 0;
        g_session_data.ich_ess_id :=
            NVL (
                p_msg.EXTRACT ('/a_envelope/a_header/@a_ess_id').getNumberVal (),
                0);
        g_session_data.ich_date :=
            TO_DATE (
                p_msg.EXTRACT ('/a_envelope/a_header/@a_msg_dt').getStringVal (),
                'DD.MM.YYYY HH24:MI:SS');
        g_session_data.ich_ses :=
            p_msg.EXTRACT ('/a_envelope/a_header/@a_audsesid').getStringVal ();
        g_session_data.ich_org :=
            NVL (
                p_msg.EXTRACT ('/a_envelope/a_header/@a_org').getStringVal (),
                0);
        g_session_data.ich_user :=
            NVL (
                p_msg.EXTRACT ('/a_envelope/a_header/@a_user_id').getStringVal (),
                0);
        g_session_data.ich_user_name :=
            UPPER (
                p_msg.EXTRACT ('/a_envelope/a_header/@a_user_name').getStringVal ());
        g_session_data.ich_web_user :=
            UPPER (
                p_msg.EXTRACT ('/a_envelope/a_header/@a_web_user').getStringVal ());
        g_session_data.ich_host :=
            UPPER (
                p_msg.EXTRACT ('/a_envelope/a_header/@a_host').getStringVal ());
        g_session_data.ich_ip :=
            p_msg.EXTRACT ('/a_envelope/a_header/@a_ip').getStringVal ();
        g_session_data.ich_os_user :=
            UPPER (
                p_msg.EXTRACT ('/a_envelope/a_header/@a_os_user').getStringVal ());
        g_session_data.ich_program :=
            UPPER (
                p_msg.EXTRACT ('/a_envelope/a_header/@a_program').getStringVal ());
        g_session_data.ich_module :=
            UPPER (
                p_msg.EXTRACT ('/a_envelope/a_header/@a_module').getStringVal ());
        v_ao_code :=
            UPPER (
                p_msg.EXTRACT ('/a_envelope/a_header/@a_msg_tp').getStringVal ());

        SELECT MAX (ao_id)
          INTO v_ao_id
          FROM ikis_aud_oper
         WHERE UPPER (TRIM (ao_code)) = UPPER (TRIM (v_ao_code));

        IF v_ao_id IS NULL
        THEN
            INSERT INTO ikis_aud_oper (ao_id,
                                       ao_code,
                                       ao_name,
                                       ao_desc)
                 VALUES (0,
                         v_ao_code,
                         v_ao_code,
                         v_ao_code)
              RETURNING ao_id
                   INTO g_session_data.ich_ao;
        ELSE
            g_session_data.ich_ao := v_ao_id;
        END IF;
    END;

    --Инициализация заголовка вставляемой записи аудита.
    PROCEDURE InitSessionEx1 (p_msg XMLTYPE)
    IS
        v_ao_code   ikis_aud_oper.ao_code%TYPE;
        v_ao_id     ikis_aud_oper.ao_id%TYPE;
    BEGIN
                --  dbms_output.put_line(p_msg.getClobVal());
                SELECT 0,
                       NVL (a_ess_id, 0),
                       TO_DATE (a_msg_dt, 'DD.MM.YYYY HH24:MI:SS'),
                       a_audsesid,
                       a_org,
                       NVL (a_user_id, 0),
                       UPPER (a_user_name),
                       UPPER (a_web_user),
                       UPPER (a_host),
                       a_ip,
                       UPPER (a_os_user),
                       UPPER (a_program),
                       UPPER (a_module),
                       UPPER (a_msg_tp)
                  INTO g_session_data.ich_id,
                       g_session_data.ich_ess_id,
                       g_session_data.ich_date,
                       g_session_data.ich_ses,
                       g_session_data.ich_org,
                       g_session_data.ich_user,
                       g_session_data.ich_user_name,
                       g_session_data.ich_web_user,
                       g_session_data.ich_host,
                       g_session_data.ich_ip,
                       g_session_data.ich_os_user,
                       g_session_data.ich_program,
                       g_session_data.ich_module,
                       v_ao_code
                  FROM XMLTABLE (
                           '/a_envelope/a_header'
                           PASSING p_msg
                           COLUMNS a_ess_id       NUMBER PATH '@a_ess_id',
                                   a_msg_dt       VARCHAR2 (100) PATH '@a_msg_dt',
                                   a_audsesid     VARCHAR2 (100) PATH '@a_audsesid',
                                   a_org          VARCHAR2 (100) PATH '@a_org',
                                   a_user_id      VARCHAR2 (100) PATH '@a_user_id',
                                   a_user_name    VARCHAR2 (100) PATH '@a_user_name',
                                   a_web_user     VARCHAR2 (100) PATH '@a_web_user',
                                   a_host         VARCHAR2 (100) PATH '@a_host',
                                   a_ip           VARCHAR2 (100) PATH '@a_ip',
                                   a_os_user      VARCHAR2 (100) PATH '@a_os_user',
                                   a_program      VARCHAR2 (100) PATH '@a_program',
                                   a_module       VARCHAR2 (100) PATH '@a_module',
                                   a_msg_tp       VARCHAR2 (100) PATH '@a_msg_tp');

        /*  SELECT 0,
                  NVL(p_msg.extract('/a_envelope/a_header/@a_ess_id').getNumberVal(), 0),
                  to_date(p_msg.extract('/a_envelope/a_header/@a_msg_dt').getStringVal(), 'DD.MM.YYYY HH24:MI:SS'),
                  p_msg.extract('/a_envelope/a_header/@a_audsesid').getStringVal(),
                  NVL(p_msg.extract('/a_envelope/a_header/@a_org').getStringVal(), 0),
                  NVL(p_msg.extract('/a_envelope/a_header/@a_user_id').getStringVal(), 0),
                  UPPER(p_msg.extract('/a_envelope/a_header/@a_user_name').getStringVal()),
                  UPPER(p_msg.extract('/a_envelope/a_header/@a_web_user').getStringVal()),
                  UPPER(p_msg.extract('/a_envelope/a_header/@a_host').getStringVal()),
                  p_msg.extract('/a_envelope/a_header/@a_ip').getStringVal(),
                  UPPER(p_msg.extract('/a_envelope/a_header/@a_os_user').getStringVal()),
                  UPPER(p_msg.extract('/a_envelope/a_header/@a_program').getStringVal()),
                  UPPER(p_msg.extract('/a_envelope/a_header/@a_module').getStringVal()),
                  UPPER(p_msg.extract('/a_envelope/a_header/@a_msg_tp').getStringVal())
          INTO g_session_data.ich_id,
               g_session_data.ich_ess_id,
               g_session_data.ich_date,
               g_session_data.ich_ses,
               g_session_data.ich_org,
               g_session_data.ich_user,
               g_session_data.ich_user_name,
               g_session_data.ich_web_user,
               g_session_data.ich_host,
               g_session_data.ich_ip,
               g_session_data.ich_os_user,
               g_session_data.ich_program,
               g_session_data.ich_module,
               v_ao_code
          FROM dual;*/
        SELECT MAX (ao_id)
          INTO v_ao_id
          FROM ikis_aud_oper
         WHERE UPPER (TRIM (ao_code)) = UPPER (TRIM (v_ao_code));

        IF v_ao_id IS NULL
        THEN
            INSERT INTO ikis_aud_oper (ao_id,
                                       ao_code,
                                       ao_name,
                                       ao_desc)
                 VALUES (0,
                         v_ao_code,
                         v_ao_code,
                         v_ao_code)
              RETURNING ao_id
                   INTO g_session_data.ich_ao;
        ELSE
            g_session_data.ich_ao := v_ao_id;
        END IF;
    END;

    --Функция обработки
    PROCEDURE ProcessTransitMsg (p_msg t_audit_message)
    AS
        l_length       INTEGER;
        l_parts        INTEGER;
        l_value_part   VARCHAR2 (4000);
        l_message      CLOB;
    BEGIN
        --  INSERT INTO demo_queue_message_table ( msg_tp, msg_dt, msg_body )
        --    VALUES (to_char(p_msg.msg_dt, 'DD.MM.YYYY HH24:MI:SS'), sysdate, p_msg.msg_body);
        --  COMMIT;
        InitSession (p_msg.msg_body);
        l_message :=
            p_msg.msg_body.EXTRACT ('/a_envelope/a_body/text()').getClobVal ();
        l_message := NVL (l_message, 'EMPTY');
        --Если кто-то вставил <br> - восстанавливаем.
        l_message := REPLACE (l_message, '&lt;br&gt;', '<br>');
        l_length := DBMS_LOB.getlength (l_message);
        l_parts := TRUNC (l_length / 1000);

        IF l_parts * 1000 = l_length
        THEN
            l_parts := l_parts - 1;
        END IF;

        FOR i IN 0 .. l_parts
        LOOP
            l_value_part := DBMS_LOB.SUBSTR (l_message, 1000, 1 + i * 1000);
            g_session_data.ich_value :=
                ikis_crypt.encryptraw (UTL_RAW.CAST_TO_RAW (l_value_part),
                                       UTL_RAW.CAST_TO_RAW (c_pwd));

            INSERT INTO ikis_changes
                 VALUES g_session_data;
        END LOOP;
    END;

    --Функция обработки
    PROCEDURE ProcessTransitMsgEx (p_msg_body XMLTYPE)
    AS
        l_length       INTEGER;
        l_parts        INTEGER;
        l_value_part   VARCHAR2 (4000);
        l_message      CLOB;
        l_ret          NUMBER (20);
    BEGIN
        --  INSERT INTO demo_queue_message_table ( msg_tp, msg_dt, msg_body )
        --    VALUES (to_char(p_msg.msg_dt, 'DD.MM.YYYY HH24:MI:SS'), sysdate, p_msg.msg_body);
        --  COMMIT;
        InitSessionEx1 (p_msg_body);
        l_message :=
            p_msg_body.EXTRACT ('/a_envelope/a_body/text()').getClobVal ();
        l_message := NVL (l_message, 'EMPTY');
        --Если кто-то вставил <br> - восстанавливаем.
        l_message := REPLACE (l_message, '&lt;br&gt;', '<br>');
        l_length := DBMS_LOB.getlength (l_message);
        l_parts := TRUNC (l_length / 1000);

        IF l_parts * 1000 = l_length
        THEN
            l_parts := l_parts - 1;
        END IF;

        FOR i IN 0 .. l_parts
        LOOP
            l_value_part := DBMS_LOB.SUBSTR (l_message, 1000, 1 + i * 1000);
            g_session_data.ich_value :=
                ikis_crypt.encryptraw (UTL_RAW.CAST_TO_RAW (l_value_part),
                                       UTL_RAW.CAST_TO_RAW (c_pwd));

            INSERT INTO ikis_changes
                 VALUES g_session_data
              RETURNING ich_id
                   INTO l_ret;
        --dbms_output.put_line(l_ret);
        END LOOP;
    END;

    --Передача через DB-LINK записів в основний буфер
    PROCEDURE SendAuditToMainBuffer
    IS
        l_lock   ikis_sys.ikis_lock.t_lockhandler;
    BEGIN
        ikis_sys.ikis_lock.Request_Lock (
            p_permanent_name      => 'IKIS_SYS_AUD_MIGRATE',
            p_var_name            => '2',
            p_errmessage          =>
                'Передачу накопиченого аудиту з локального буферу до головного буферу щє не завершено.',
            p_lockhandler         => l_lock,
            p_lockmode            => 6,
            p_timeout             => 0,
            p_release_on_commit   => TRUE);

        --Накопичені і необроблені записи помічаємо як такі, що потрібно мігрувати в центральний буфер
        UPDATE ikis_audit_buffer
           SET iab_st = 'M'
         WHERE iab_st = 'R';

        --Передаємо записи аудиту в центральний буфер
        INSERT INTO ikis_sys.ikis_audit_buffer@lnk_audit (iab_msg_tp,
                                                          iab_org,
                                                          iab_ess_id,
                                                          iab_msg_dt,
                                                          iab_audsesid,
                                                          iab_user_id,
                                                          iab_user_name,
                                                          iab_web_user,
                                                          iab_host,
                                                          iab_ip,
                                                          iab_os_user,
                                                          iab_program,
                                                          iab_module,
                                                          iab_body,
                                                          iab_st)
            SELECT iab_msg_tp,
                   iab_org,
                   iab_ess_id,
                   iab_msg_dt,
                   iab_audsesid,
                   iab_user_id,
                   iab_user_name,
                   iab_web_user,
                   iab_host,
                   iab_ip,
                   iab_os_user,
                   iab_program,
                   iab_module,
                   iab_body,
                   'T'
              FROM ikis_audit_buffer
             WHERE iab_st = 'M';

        --Помічаємо мігровані записи як такі, що можна видаляти
        UPDATE ikis_audit_buffer
           SET iab_st = 'Z'
         WHERE iab_st = 'M';

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                   'IKIS_AUD_PROCESS.SendAuditToMainBuffer:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;

    --Инициализация заголовка вставляемой записи аудита.
    PROCEDURE InitSessionEX (p_msg IKIS_AUDIT_BUFFER%ROWTYPE)
    IS
        v_ao_code   ikis_aud_oper.ao_code%TYPE;
        v_ao_id     ikis_aud_oper.ao_id%TYPE;
    --v_ao_tp   ikis_aud_oper.ao_tp%TYPE;
    BEGIN
        v_ao_code := UPPER (p_msg.iab_msg_tp);

        SELECT MIN (ao_id)
          INTO v_ao_id
          FROM ikis_aud_oper
         WHERE    UPPER (TRIM (ao_code)) = UPPER (TRIM (v_ao_code))
               OR (ao_code IS NULL AND v_ao_code IS NULL);

        IF v_ao_id IS NULL
        THEN
            INSERT INTO ikis_aud_oper (ao_id,
                                       ao_code,
                                       ao_name,
                                       ao_desc,
                                       ao_tp)
                 VALUES (0,
                         v_ao_code,
                         v_ao_code,
                         v_ao_code,
                         NULL)
              RETURNING ao_id
                   INTO v_ao_id;

            g_ao_tp := 'IC';
        ELSE
            SELECT ao_tp
              INTO g_ao_tp
              FROM ikis_aud_oper
             WHERE ao_id = v_ao_id;
        END IF;

        IF NVL (g_ao_tp, 'IC') = 'UA'
        THEN
            g_user_activity.iua_id := 0;
            g_user_activity.iua_org := NVL (p_msg.iab_org, 0);
            g_user_activity.iua_user := NVL (p_msg.iab_user_id, 0);
            g_user_activity.iua_user_name := UPPER (p_msg.iab_user_name);
            g_user_activity.iua_host := UPPER (p_msg.iab_host);
            g_user_activity.iua_ip := p_msg.iab_ip;
            g_user_activity.iua_os_user := UPPER (p_msg.iab_os_user);
            g_user_activity.iua_program := UPPER (p_msg.iab_program);
            g_user_activity.iua_module := UPPER (p_msg.iab_module);
            g_user_activity.iua_web_user := UPPER (p_msg.iab_web_user);
            g_user_activity.iua_date := p_msg.iab_msg_dt;
            --g_user_activity.iua_value,
            g_user_activity.iua_ao := v_ao_id;
        ELSE
            g_session_data.ich_id := 0;
            g_session_data.ich_ess_id := NVL (p_msg.iab_ess_id, 0);
            g_session_data.ich_date := p_msg.iab_msg_dt;
            g_session_data.ich_ses := p_msg.iab_audsesid;
            g_session_data.ich_org := NVL (p_msg.iab_org, 0);
            g_session_data.ich_user := NVL (p_msg.iab_user_id, 0);
            g_session_data.ich_user_name := UPPER (p_msg.iab_user_name);
            g_session_data.ich_web_user := UPPER (p_msg.iab_web_user);
            g_session_data.ich_host := UPPER (p_msg.iab_host);
            g_session_data.ich_ip := p_msg.iab_ip;
            g_session_data.ich_os_user := UPPER (p_msg.iab_os_user);
            g_session_data.ich_program := UPPER (p_msg.iab_program);
            g_session_data.ich_module := UPPER (p_msg.iab_module);
            g_session_data.ich_ao := v_ao_id;
        END IF;
    END;

    --Обробка накопичених записів в буфері
    PROCEDURE ProcessAuditBuffer
    IS
        l_msg          IKIS_AUDIT_BUFFER%ROWTYPE;
        l_length       INTEGER;
        l_parts        INTEGER;
        l_value_part   VARCHAR2 (4000);
        l_message      CLOB;
        l_lock         ikis_sys.ikis_lock.t_lockhandler;
    BEGIN
        ikis_sys.ikis_lock.Request_Lock (
            p_permanent_name      => 'IKIS_SYS_AUD_PROCESS',
            p_var_name            => '1',
            p_errmessage          =>
                'Обробку накопиченого аудиту в буфері щє не завершено.',
            p_lockhandler         => l_lock,
            p_lockmode            => 6,
            p_timeout             => 0,
            p_release_on_commit   => TRUE);

        --Помічаємо локальні записи буферу аудиту та отримані з інших баз, як такі, що потребують обробки - запису в аудит
        UPDATE ikis_audit_buffer
           SET iab_st = 'X'
         WHERE iab_st IN ('R', 'T') AND ROWNUM <= 10000;

        FOR xx IN (SELECT iab_id     AS id
                     FROM ikis_audit_buffer
                    WHERE iab_st = 'X')
        LOOP
            SELECT *
              INTO l_msg
              FROM ikis_audit_buffer
             WHERE iab_id = xx.id;

            InitSessionEX (l_msg);
            l_message := l_msg.iab_body;
            l_message := NVL (l_message, 'EMPTY');
            --Если кто-то вставил <br> - восстанавливаем.
            l_message := REPLACE (l_message, '&lt;br&gt;', '<br>');
            l_length := DBMS_LOB.getlength (l_message);
            l_parts := TRUNC (l_length / 1000);

            IF l_parts * 1000 = l_length
            THEN
                l_parts := l_parts - 1;
            END IF;

            IF NVL (g_ao_tp, 'IC') = 'UA'
            THEN
                FOR i IN 0 .. l_parts
                LOOP
                    l_value_part :=
                        DBMS_LOB.SUBSTR (l_message, 1000, 1 + i * 1000);
                    g_user_activity.iua_value :=
                        ikis_crypt.encryptraw (
                            UTL_RAW.CAST_TO_RAW (l_value_part),
                            UTL_RAW.CAST_TO_RAW (c_pwd));

                    INSERT INTO ikis_user_activity
                         VALUES g_user_activity;
                END LOOP;
            ELSE
                FOR i IN 0 .. l_parts
                LOOP
                    l_value_part :=
                        DBMS_LOB.SUBSTR (l_message, 1000, 1 + i * 1000);
                    g_session_data.ich_value :=
                        ikis_crypt.encryptraw (
                            UTL_RAW.CAST_TO_RAW (l_value_part),
                            UTL_RAW.CAST_TO_RAW (c_pwd));

                    INSERT INTO ikis_changes
                         VALUES g_session_data;
                END LOOP;
            END IF;
        END LOOP;

        --Визначаємо записи в буфері як такі, що можна видаляти
        UPDATE ikis_audit_buffer
           SET iab_st = 'Z'
         WHERE iab_st = 'X';

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                   'IKIS_AUD_PROCESS.ProcessAuditBuffer:'
                || g_session_data.ich_ao
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;

    --Видалення оброблених записів
    PROCEDURE ClearProcessedAuditBuffer
    IS
        l_cnt   INTEGER;
    BEGIN
        --Видаляємо оброблені запису буферу аудиту
        LOOP
            DELETE FROM ikis_audit_buffer
                  WHERE iab_st = 'Z' AND ROWNUM < 1001;

            l_cnt := SQL%ROWCOUNT;
            COMMIT;
            EXIT WHEN l_cnt = 0;
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                   'IKIS_AUD_PROCESS.ClearProcessedAuditBuffer:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;
BEGIN
    NULL;
END IKIS_AUD_PROCESS;
/