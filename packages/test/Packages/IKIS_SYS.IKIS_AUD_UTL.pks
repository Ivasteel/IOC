/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_AUD_UTL
IS
    -- Author  : VANO
    -- Created : 29.07.2013 16:54:08
    -- Purpose : Функції ядра підсистеми ведення аудиту
    -- !!!! НЕ ДЕЛАТЬ ССЫЛОК НА IKIS_AUDIT_PROCESS !!!!

    PROCEDURE Put (p_msg t_audit_message, p_trans_mode VARCHAR2:= 'EXTERNAL');

    FUNCTION Get (p_consumer_name   VARCHAR2,
                  p_trans_mode      VARCHAR2:= 'EXTERNAL')
        RETURN t_audit_message;

    FUNCTION GetIpAddress
        RETURN VARCHAR2;

    FUNCTION GetMsgHeader
        RETURN XMLTYPE;

    FUNCTION MakeMessage (p_msg_tp       VARCHAR2,
                          p_msg_dt       DATE,
                          p_msg_body     VARCHAR2,
                          p_msg_ess_id   NUMBER:= 0)
        RETURN t_audit_message;

    PROCEDURE PutEX (p_msg          IKIS_AUDIT_BUFFER%ROWTYPE,
                     p_trans_mode   VARCHAR2:= 'EXTERNAL');

    FUNCTION MakeMessageEX (p_msg_tp       VARCHAR2,
                            p_msg_dt       DATE,
                            p_msg_body     VARCHAR2,
                            p_msg_ess_id   NUMBER:= 0)
        RETURN IKIS_AUDIT_BUFFER%ROWTYPE;
END IKIS_AUD_UTL;
/


/* Formatted on 8/12/2025 6:10:01 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_AUD_UTL
IS
    v_msg_tp              VARCHAR2 (32);
    v_msg_dt              DATE;
    v_msg_body            VARCHAR (4000);
    v_msg_ess_id          NUMBER (14, 0);

    v_local_audit_queue   VARCHAR2 (24);
    v_remote_address      VARCHAR2 (50);
    v_subscriber_name     VARCHAR2 (50);
    v_is_remote_store     BOOLEAN;

    --Пишем сообщение во внешней трансакции. Если указана в параметрах "удалённая" очередь - добавляем её в получатели.
    PROCEDURE PutInExternalTrans (p_msg t_audit_message)
    IS
        r_enqueue_options      DBMS_AQ.ENQUEUE_OPTIONS_T;
        r_message_properties   DBMS_AQ.MESSAGE_PROPERTIES_T;
        v_message_handle       RAW (16);
        r_recipients           DBMS_AQ.AQ$_RECIPIENT_LIST_T;
    BEGIN
        IF v_remote_address IS NOT NULL
        THEN
            r_recipients (1) :=
                SYS.AQ$_AGENT (v_subscriber_name, v_remote_address, NULL);
            r_message_properties.recipient_list := r_recipients;
        END IF;

        DBMS_AQ.ENQUEUE (queue_name           => v_local_audit_queue,
                         enqueue_options      => r_enqueue_options,
                         message_properties   => r_message_properties,
                         payload              => p_msg,
                         msgid                => v_message_handle);
    END;

    --Пишем сообщение во внешней трансакции.
    PROCEDURE PutInExternalTransEX (p_msg IKIS_AUDIT_BUFFER%ROWTYPE)
    IS
    BEGIN
        --Raise_Application_Error(-20000, 'IKIS_AUD_UTL.PutInExternalTransEX' ||'   ' ||p_trans_mode);
        INSERT INTO ikis_audit_buffer
             VALUES p_msg;
    END;

    --Пишем сообщение в автономной трансакции
    PROCEDURE PutInAutoTrans (p_msg t_audit_message)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        PutInExternalTrans (p_msg);
        COMMIT;
    END;

    --Пишем сообщение в автономной трансакции
    PROCEDURE PutInAutoTransEX (p_msg IKIS_AUDIT_BUFFER%ROWTYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        PutInExternalTransEX (p_msg);
        COMMIT;
    END;

    --Пишем сообщение в очередь аудита.
    PROCEDURE Put (p_msg t_audit_message, p_trans_mode VARCHAR2:= 'EXTERNAL')
    IS
    BEGIN
        IF p_trans_mode = 'EXTERNAL'
        THEN
            PutInExternalTrans (p_msg);
        ELSIF p_trans_mode = 'AUTO'
        THEN
            PutInAutoTrans (p_msg);
        ELSE
            PutInAutoTrans (p_msg);
        END IF;
    END;

    --Пишем сообщение в очередь аудита.
    PROCEDURE PutEX (p_msg          IKIS_AUDIT_BUFFER%ROWTYPE,
                     p_trans_mode   VARCHAR2:= 'EXTERNAL')
    IS
    BEGIN
        IF p_trans_mode = 'EXTERNAL'
        THEN
            PutInExternalTransEX (p_msg);
        ELSIF p_trans_mode = 'AUTO'
        THEN
            PutInAutoTransEX (p_msg);
        ELSE
            PutInAutoTransEX (p_msg);
        END IF;
    END;

    --Читаем сообщение во внешней трансакции
    FUNCTION GetInExternalTrans (p_consumer_name VARCHAR2)
        RETURN t_audit_message
    IS
        r_dequeue_options      DBMS_AQ.DEQUEUE_OPTIONS_T;
        r_message_properties   DBMS_AQ.MESSAGE_PROPERTIES_T;
        v_message_handle       RAW (16);
        o_payload              t_audit_message;
    BEGIN
        IF p_consumer_name IS NOT NULL
        THEN
            r_dequeue_options.consumer_name := p_consumer_name;
        END IF;

        DBMS_AQ.DEQUEUE (queue_name           => v_local_audit_queue,
                         dequeue_options      => r_dequeue_options,
                         message_properties   => r_message_properties,
                         payload              => o_payload,
                         msgid                => v_message_handle);

        RETURN o_payload;
    END;

    --Читаем сообщение в автономной трансакции
    FUNCTION GetInAutoTrans (p_consumer_name VARCHAR2)
        RETURN t_audit_message
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        o_payload   t_audit_message;
    BEGIN
        o_payload := GetInExternalTrans (p_consumer_name);
        COMMIT;
        RETURN o_payload;
    END;

    --Читаем сообщение
    FUNCTION Get (p_consumer_name   VARCHAR2,
                  p_trans_mode      VARCHAR2:= 'EXTERNAL')
        RETURN t_audit_message
    IS
        o_payload   t_audit_message;
    BEGIN
        IF p_trans_mode = 'EXTERNAL'
        THEN
            o_payload := GetInExternalTrans (p_consumer_name);
        ELSIF p_trans_mode = 'AUTO'
        THEN
            o_payload := GetInAutoTrans (p_consumer_name);
        ELSE
            o_payload := GetInAutoTrans (p_consumer_name);
        END IF;

        RETURN o_payload;
    END;

    FUNCTION GetIpAddress
        RETURN VARCHAR2
    IS
        l_ip   VARCHAR2 (100) := NULL;
    BEGIN
        l_ip := SYS_CONTEXT ('IKISWEBADM', 'LOGINIP');

        IF l_ip IS NOT NULL
        THEN
            RETURN l_ip;
        ELSIF OWA.Num_Cgi_Vars IS NULL
        THEN
            RETURN TRIM (SYS_CONTEXT ('USERENV', 'IP_ADDRESS'));
        ELSE
            RETURN TRIM (OWA_UTIL.Get_Cgi_Env ('REMOTE_ADDR'));
        END IF;
    END;

    --Получаем заготовку сообщения как XML. Вычисляем основные параметры выполнявшего операцию юезра.
    FUNCTION GetMsgHeader
        RETURN XMLTYPE
    IS
        x_header          XMLTYPE;
        l_tp              NUMBER;
        l_pfu             NUMBER;
        l_uid             NUMBER;
        l_trc             VARCHAR2 (10);
        v_web_user_name   VARCHAR2 (30);
        l_str             VARCHAR2 (4000);
    BEGIN
        BEGIN
            v_web_user_name := UPPER (apex_200100.v ('USER'));

            IF v_web_user_name IS NOT NULL
            THEN
                IKIS_SYSWEB.getuserattr (p_username   => v_web_user_name,
                                         p_uid        => l_uid,
                                         p_wut        => l_tp,
                                         p_org        => l_pfu,
                                         p_trc        => l_trc);
            ELSE
                l_pfu := IKIS_COMMON.GetAP_IKIS_OPFU;
            END IF;

            SELECT XMLTYPE (
                          '<a_envelope>'
                       || '<a_header '
                       || 'a_msg_tp="'
                       || v_msg_tp
                       || '" '
                       || 'a_org="'
                       || l_pfu
                       || '" '
                       || 'a_ess_id="'
                       || v_msg_ess_id
                       || '" '
                       || 'a_msg_dt="'
                       || TO_CHAR (NVL (v_msg_dt, SYSDATE),
                                   'DD.MM.YYYY HH24:MI:SS')
                       || '" '
                       || 'a_audsesid="'
                       || SYS_CONTEXT ('USERENV', 'SESSIONID')
                       || '" '
                       || 'a_user_id="'
                       || TRIM (SYS_CONTEXT ('USERENV', 'SESSION_USERID'))
                       || '" '
                       || 'a_user_name="'
                       || TRIM (SYS_CONTEXT ('USERENV', 'SESSION_USER'))
                       || '" '
                       || 'a_web_user="'
                       || v_web_user_name
                       || '" '
                       || 'a_host="'
                       || TRIM (
                              REPLACE (SYS_CONTEXT ('USERENV', 'HOST'),
                                       CHR (0),
                                       ''))
                       || '" '
                       || 'a_ip="'
                       || Ikis_Aud_Utl.GetIpAddress
                       || '" '
                       || 'a_os_user="'
                       || CASE
                              WHEN OWA.num_cgi_vars IS NULL
                              THEN
                                  TRIM (SYS_CONTEXT ('USERENV', 'OS_USER'))
                              ELSE
                                  ''
                          END
                       || '" '
                       || 'a_program="'
                       || (SELECT TRIM (program)
                             FROM v$session
                            WHERE sid = SYS_CONTEXT ('USERENV', 'SID'))
                       || '" '
                       || 'a_module="'
                       || apex_200100.v ('APP_ID')
                       || '">'
                       || '</a_header>'
                       || '<a_body>x</a_body>'
                       || '</a_envelope>')
              INTO x_header
              FROM DUAL;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        RETURN x_header;
    END;

    FUNCTION MakeMessage (p_msg_tp       VARCHAR2,
                          p_msg_dt       DATE,
                          p_msg_body     VARCHAR2,
                          p_msg_ess_id   NUMBER:= 0)
        RETURN t_audit_message
    IS
        v_result   t_audit_message;
    BEGIN
        v_msg_tp := p_msg_tp;
        v_msg_dt := p_msg_dt;
        v_msg_body := p_msg_body;
        v_msg_ess_id := p_msg_ess_id;

        v_result := t_audit_message (v_msg_tp, v_msg_dt, NULL);

        v_result.msg_body := GetMsgHeader;

        SELECT UPDATEXML (v_result.msg_body,
                          '/a_envelope/a_body/text()',
                          v_msg_body)
          INTO v_result.msg_body
          FROM DUAL;

        RETURN v_result;
    END;

    FUNCTION MakeMessageEX (p_msg_tp       VARCHAR2,
                            p_msg_dt       DATE,
                            p_msg_body     VARCHAR2,
                            p_msg_ess_id   NUMBER:= 0)
        RETURN IKIS_AUDIT_BUFFER%ROWTYPE
    IS
        v_result          IKIS_AUDIT_BUFFER%ROWTYPE;
        l_tp              NUMBER;
        l_pfu             NUMBER;
        l_uid             NUMBER;
        l_trc             VARCHAR2 (10);
        v_web_user_name   VARCHAR2 (30);
    BEGIN
        v_web_user_name :=
            UPPER (
                SYS_CONTEXT (namespace => 'IKISWEBADM', attribute => 'LOGIN'));

        IF v_web_user_name IS NULL
        THEN
            v_web_user_name := UPPER (apex_200100.v ('USER'));
        END IF;

        IF v_web_user_name IS NOT NULL
        THEN
            IKIS_SYSWEB.getuserattr (p_username   => v_web_user_name,
                                     p_uid        => l_uid,
                                     p_wut        => l_tp,
                                     p_org        => l_pfu,
                                     p_trc        => l_trc);
        ELSE
            l_pfu := IKIS_COMMON.GetAP_IKIS_OPFU;
        END IF;

        v_result.iab_msg_tp := TRIM (p_msg_tp);
        v_result.iab_org := l_pfu;
        v_result.iab_ess_id := p_msg_ess_id;
        v_result.iab_msg_dt := SYSDATE;
        v_result.iab_audsesid := SYS_CONTEXT ('USERENV', 'SESSIONID');
        v_result.iab_user_id :=
            TRIM (SYS_CONTEXT ('USERENV', 'SESSION_USERID'));
        v_result.iab_user_name :=
            TRIM (SYS_CONTEXT ('USERENV', 'SESSION_USER'));
        v_result.iab_web_user := v_web_user_name;
        v_result.iab_host :=
            TRIM (REPLACE (SYS_CONTEXT ('USERENV', 'HOST'), CHR (0), ''));
        v_result.iab_ip := Ikis_Aud_Utl.GetIpAddress;
        v_result.iab_os_user :=
            CASE
                WHEN OWA.num_cgi_vars IS NULL
                THEN
                    TRIM (SYS_CONTEXT ('USERENV', 'OS_USER'))
                ELSE
                    ''
            END;

        SELECT TRIM (program)
          INTO v_result.iab_program
          FROM v$session
         WHERE sid = SYS_CONTEXT ('USERENV', 'SID');

        v_result.iab_module := apex_200100.v ('APP_ID');
        v_result.iab_body := p_msg_body;
        v_result.iab_st := 'R';
        RETURN v_result;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                   'IKIS_AUD_UTL.MakeMessageEX:'
                || p_msg_tp
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
    v_local_audit_queue := 'ikis_sys.q_audit';
    v_remote_address := 'ikis_sys.q_final_audit@lnk_audit';
    v_is_remote_store := FALSE;
    v_subscriber_name := 'audit_transit_processor';
END IKIS_AUD_UTL;
/