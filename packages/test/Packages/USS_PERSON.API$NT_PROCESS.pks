/* Formatted on 8/12/2025 5:56:53 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.API$NT_PROCESS
IS
    -- Author  : VANO
    -- Created : 20.01.2023 12:17:41
    -- Purpose : Функції ведення даних підсистеми інформування

    --Функція встановлення стану повідомлення "Передано провайдеру"
    PROCEDURE SetNTDelivered2Provider (p_id            nt_message.ntm_id%TYPE,
                                       p_need_commit   BOOLEAN:= TRUE);

    --Функція встановлення стану повідомлення в задачі "Передано провайдеру"
    PROCEDURE SetNTMTDelivered2Provider (p_id            nt_msg2task.ntmt_id%TYPE,
                                         p_prov_id       INTEGER:= NULL,
                                         p_need_commit   BOOLEAN:= TRUE);

    --Функція встановлення стану повідомлення "Передається особі"
    PROCEDURE SetNTDelivering2Person (p_id            nt_message.ntm_id%TYPE,
                                      p_need_commit   BOOLEAN:= TRUE);

    --Функція встановлення стану повідомлення в задачі "Передається особі"
    PROCEDURE SetNTMTDelivering2Person (p_id            nt_msg2task.ntmt_id%TYPE,
                                        p_need_commit   BOOLEAN:= TRUE);

    --Функція встановлення стану повідомлення "Передано особі"
    PROCEDURE SetNTDelivered2Person (
        p_id             nt_message.ntm_id%TYPE,
        p_delivered_dt   nt_message.ntm_delivered_dt%TYPE,
        p_need_commit    BOOLEAN:= TRUE);

    --Функція встановлення стану повідомлення в задачы "Передано особі"
    PROCEDURE SetNTMTDelivered2Person (
        p_id             nt_msg2task.ntmt_id%TYPE,
        p_delivered_dt   nt_msg2task.ntmt_delivered_dt%TYPE,
        p_need_commit    BOOLEAN:= TRUE);

    --Функція встановлення стану повідомлення "Помилка передачі особі"
    PROCEDURE SetNTUnDelivered2Person (
        p_id            nt_message.ntm_id%TYPE,
        p_hs            nt_send_log.ntsl_hs%TYPE,
        p_message       nt_send_log.ntsl_message%TYPE,
        p_need_commit   BOOLEAN:= TRUE);

    --Функція встановлення стану повідомлення в задачі "Помилка передачі особі"
    PROCEDURE SetNTMTUnDelivered2Person (
        p_id            nt_msg2task.ntmt_id%TYPE,
        p_hs            nt_send_log.ntsl_hs%TYPE,
        p_message       nt_send_log.ntsl_message%TYPE,
        p_need_commit   BOOLEAN:= TRUE);

    PROCEDURE SetNTSTConfirmed (p_id nt_send_task.ntst_id%TYPE);

    PROCEDURE SetNTSTPartProcessedByProvider (p_id nt_send_task.ntst_id%TYPE);

    PROCEDURE SetNTSTFullProcessedByProvider (
        p_id             nt_send_task.ntst_id%TYPE,
        p_delivered_dt   nt_send_task.ntst_delivered_dt%TYPE);

    PROCEDURE SetNTSTNotProcessedByProvider (p_id nt_send_task.ntst_id%TYPE);

    PROCEDURE CheckNTSTState (p_ntst_id nt_send_task.ntst_id%TYPE);

    PROCEDURE CheckNTSTState;

    PROCEDURE SendTestMessage (
        p_info_tp        nt_send_task.ntst_info_tp%TYPE,
        p_ntt            uss_ndi.v_ndi_nt_template.ntt_id%TYPE,
        p_contact        nt_message.ntm_contact%TYPE,
        p_title          nt_message.ntm_title%TYPE := 'PFU TEST',
        p_text           nt_message.ntm_text%TYPE,
        p_nip            nt_send_task.ntst_nip%TYPE,
        p_sc             nt_message.ntm_sc%TYPE := NULL,
        p_numident       nt_message.ntm_numident%TYPE := 'test',
        p_ntst_id    OUT nt_send_task.ntst_id%TYPE);

    FUNCTION GetMessageText (p_mode         INTEGER,
                             p_message   IN VARCHAR2 DEFAULT NULL,
                             p_info_tp   IN VARCHAR2 DEFAULT 'EMAIL')
        RETURN VARCHAR2;


    PROCEDURE InsertAdmBlockedCode (
        p_nta_code   nt_adm_blocked_code.nta_code%TYPE);

    FUNCTION InsertExtFile (p_nte_file_data   nt_ext_file.nte_file_data%TYPE,
                            p_nte_in_cnt      nt_ext_file.nte_in_cnt%TYPE,
                            p_nte_file_name   nt_ext_file.nte_file_name%TYPE)
        RETURN nt_ext_file.nte_id%TYPE;

    PROCEDURE process_ext_file (
        p_nte_id       uss_person.v_nt_ext_file.nte_id%TYPE,
        items      OUT SYS_REFCURSOR);
END API$NT_PROCESS;
/


GRANT EXECUTE ON USS_PERSON.API$NT_PROCESS TO II01RC_USS_PERSON_INT
/

GRANT EXECUTE ON USS_PERSON.API$NT_PROCESS TO USS_ESR
/

GRANT EXECUTE ON USS_PERSON.API$NT_PROCESS TO USS_RNSP
/

GRANT EXECUTE ON USS_PERSON.API$NT_PROCESS TO USS_RPT
/

GRANT EXECUTE ON USS_PERSON.API$NT_PROCESS TO USS_VISIT
/


/* Formatted on 8/12/2025 5:56:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.API$NT_PROCESS
IS
    TYPE cash_table_type IS TABLE OF VARCHAR2 (500)
        INDEX BY VARCHAR2 (40);

    g_templates            cash_table_type;


    c_template1   CONSTANT VARCHAR2 (1) := '&';
    c_template2   CONSTANT VARCHAR2 (1) := '@';
    c_variable    CONSTANT VARCHAR2 (1) := '#';
    c_eq          CONSTANT VARCHAR2 (1) := '=';

    PROCEDURE WriteNtSendLog (
        p_ntst_id   IN nt_send_log.ntsl_ntst%TYPE DEFAULT NULL,
        p_ntm_id    IN nt_send_log.ntsl_ntm%TYPE DEFAULT NULL,
        p_nte_id    IN nt_send_log.ntsl_nte%TYPE DEFAULT NULL,
        p_message   IN nt_send_log.ntsl_message%TYPE,
        p_hs        IN histsession.hs_id%TYPE DEFAULT NULL)
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        IF     NOT (    p_ntst_id IS NULL
                    AND p_ntm_id IS NULL
                    AND p_nte_id IS NULL)
           AND p_message IS NOT NULL
        THEN
            l_hs := NVL (p_hs, TOOLS.GetHistSession);

            INSERT INTO nt_send_log (ntsl_ntst,
                                     ntsl_hs,
                                     ntsl_message,
                                     ntsl_ntm,
                                     ntsl_nte)
                 VALUES (p_ntst_id,
                         l_hs,
                         p_message,
                         p_ntm_id,
                         p_nte_id);
        END IF;
    END;

    --Встановлюємо стан повідомлення
    PROCEDURE SetNTState (
        p_ntm_id           nt_message.ntm_id%TYPE,
        p_ntm_st           nt_message.ntm_st%TYPE,
        p_ntm_deliver_dt   nt_message.ntm_delivered_dt%TYPE:= NULL)
    IS
    BEGIN
        UPDATE nt_message
           SET ntm_st = p_ntm_st
         WHERE ntm_id = p_ntm_id;

        IF p_ntm_deliver_dt IS NOT NULL
        THEN
            UPDATE nt_message
               SET ntm_delivered_dt = p_ntm_deliver_dt
             WHERE ntm_id = p_ntm_id;
        END IF;
    END;

    --Встановлюємо стан повідомлення в задачі
    PROCEDURE SetNTMTState (
        p_ntmt_id           nt_msg2task.ntmt_id%TYPE,
        p_ntmt_st           nt_msg2task.ntmt_st%TYPE,
        p_ntmt_deliver_dt   nt_msg2task.ntmt_delivered_dt%TYPE:= NULL)
    IS
    BEGIN
        UPDATE nt_msg2task
           SET ntmt_st = p_ntmt_st
         WHERE ntmt_id = p_ntmt_id;

        IF p_ntmt_deliver_dt IS NOT NULL
        THEN
            UPDATE nt_msg2task
               SET ntmt_delivered_dt = p_ntmt_deliver_dt
             WHERE ntmt_id = p_ntmt_id;
        END IF;
    END;

    --Функція встановлення стану повідомлення "Передано провайдеру"
    PROCEDURE SetNTDelivered2Provider (p_id            nt_message.ntm_id%TYPE,
                                       p_need_commit   BOOLEAN:= TRUE)
    IS
        l_st   nt_message.ntm_st%TYPE;
    BEGIN
        SELECT ntm_st
          INTO l_st
          FROM nt_message
         WHERE ntm_id = p_id;

        IF l_st = 'R'
        THEN
            SetNTState (p_id, 'A');
            WriteNtSendLog (p_ntm_id    => p_id,
                            p_message   => 'Повідомлення передано оператору');
        END IF;

        IF p_need_commit
        THEN
            COMMIT;
        END IF;
    END;

    --Функція встановлення стану повідомлення в задачі "Передано провайдеру"
    PROCEDURE SetNTMTDelivered2Provider (p_id            nt_msg2task.ntmt_id%TYPE,
                                         p_prov_id       INTEGER:= NULL,
                                         p_need_commit   BOOLEAN:= TRUE)
    IS
        l_st    nt_msg2task.ntmt_st%TYPE;
        l_ntm   nt_msg2task.ntmt_ntm%TYPE;
    BEGIN
        SELECT ntmt_st, ntmt_ntm
          INTO l_st, l_ntm
          FROM nt_msg2task
         WHERE ntmt_id = p_id;

        IF l_st = 'R'
        THEN
            UPDATE nt_msg2task
               SET ntmt_prov_id = p_prov_id
             WHERE ntmt_id = p_id;

            SetNTMTState (p_id, 'A');
            WriteNtSendLog (p_ntm_id    => l_ntm,
                            p_message   => 'Повідомлення передано оператору');
        END IF;

        IF p_need_commit
        THEN
            COMMIT;
        END IF;
    END;

    --Функція встановлення стану повідомлення "Передається особі"
    PROCEDURE SetNTDelivering2Person (p_id            nt_message.ntm_id%TYPE,
                                      p_need_commit   BOOLEAN:= TRUE)
    IS
        l_st   nt_message.ntm_st%TYPE;
    BEGIN
        SELECT ntm_st
          INTO l_st
          FROM nt_message
         WHERE ntm_id = p_id;

        IF l_st IN ('R', 'A')
        THEN
            SetNTState (p_id, 'P');
            WriteNtSendLog (
                p_ntm_id    => p_id,
                p_message   => 'Оператор розпочав передачу повідомлення');
        END IF;

        IF p_need_commit
        THEN
            COMMIT;
        END IF;
    END;

    --Функція встановлення стану повідомлення в задачі "Передається особі"
    PROCEDURE SetNTMTDelivering2Person (p_id            nt_msg2task.ntmt_id%TYPE,
                                        p_need_commit   BOOLEAN:= TRUE)
    IS
        l_st    nt_msg2task.ntmt_st%TYPE;
        l_ntm   nt_msg2task.ntmt_ntm%TYPE;
    BEGIN
        SELECT ntmt_st, ntmt_ntm
          INTO l_st, l_ntm
          FROM nt_msg2task
         WHERE ntmt_id = p_id;

        IF l_st IN ('R', 'A')
        THEN
            SetNTMTState (p_id, 'P');
            WriteNtSendLog (
                p_ntm_id    => l_ntm,
                p_message   => 'Оператор розпочав передачу повідомлення');
        END IF;

        IF p_need_commit
        THEN
            COMMIT;
        END IF;
    END;

    --Функція встановлення стану повідомлення "Передано особі"
    PROCEDURE SetNTDelivered2Person (
        p_id             nt_message.ntm_id%TYPE,
        p_delivered_dt   nt_message.ntm_delivered_dt%TYPE,
        p_need_commit    BOOLEAN:= TRUE)
    IS
        l_st   nt_message.ntm_st%TYPE;
    BEGIN
        SELECT ntm_st
          INTO l_st
          FROM nt_message
         WHERE ntm_id = p_id;

        IF l_st IN ('R', 'A', 'P')
        THEN
            SetNTState (p_id, 'D', p_delivered_dt);
            WriteNtSendLog (p_ntm_id    => p_id,
                            p_message   => 'Повідомлення передано');
        END IF;

        IF p_need_commit
        THEN
            COMMIT;
        END IF;
    END;

    --Функція встановлення стану повідомлення в задачы "Передано особі"
    PROCEDURE SetNTMTDelivered2Person (
        p_id             nt_msg2task.ntmt_id%TYPE,
        p_delivered_dt   nt_msg2task.ntmt_delivered_dt%TYPE,
        p_need_commit    BOOLEAN:= TRUE)
    IS
        l_st    nt_msg2task.ntmt_st%TYPE;
        l_ntm   nt_msg2task.ntmt_ntm%TYPE;
    BEGIN
        SELECT ntmt_st, ntmt_ntm
          INTO l_st, l_ntm
          FROM nt_msg2task
         WHERE ntmt_id = p_id;

        IF l_st IN ('R', 'A', 'P')
        THEN
            SetNTMTState (p_id, 'D', p_delivered_dt);
            WriteNtSendLog (p_ntm_id    => l_ntm,
                            p_message   => 'Повідомлення передано');
        END IF;

        IF p_need_commit
        THEN
            COMMIT;
        END IF;
    END;

    --Функція встановлення стану повідомлення "Помилка передачі особі"
    PROCEDURE SetNTUnDelivered2Person (
        p_id            nt_message.ntm_id%TYPE,
        p_hs            nt_send_log.ntsl_hs%TYPE,
        p_message       nt_send_log.ntsl_message%TYPE,
        p_need_commit   BOOLEAN:= TRUE)
    IS
        l_st   nt_message.ntm_st%TYPE;
    BEGIN
        SELECT ntm_st
          INTO l_st
          FROM nt_message
         WHERE ntm_id = p_id;

        IF l_st IN ('R', 'A', 'P')
        THEN
            SetNTState (p_id, 'U');
            WriteNtSendLog (p_ntm_id => p_id, p_message => p_message);
        END IF;

        IF p_need_commit
        THEN
            COMMIT;
        END IF;
    END;

    --Функція встановлення стану повідомлення в задачі "Помилка передачі особі"
    PROCEDURE SetNTMTUnDelivered2Person (
        p_id            nt_msg2task.ntmt_id%TYPE,
        p_hs            nt_send_log.ntsl_hs%TYPE,
        p_message       nt_send_log.ntsl_message%TYPE,
        p_need_commit   BOOLEAN:= TRUE)
    IS
        l_st    nt_msg2task.ntmt_st%TYPE;
        l_ntm   nt_msg2task.ntmt_ntm%TYPE;
    BEGIN
        SELECT ntmt_st, ntmt_ntm
          INTO l_st, l_ntm
          FROM nt_msg2task
         WHERE ntmt_id = p_id;

        IF l_st IN ('R', 'A', 'P')
        THEN
            SetNTMTState (p_id, 'U');
            WriteNtSendLog (p_ntm_id => l_ntm, p_message => p_message);
        END IF;

        IF p_need_commit
        THEN
            COMMIT;
        END IF;
    END;

    PROCEDURE SetNTSTState (
        p_id        nt_send_task.ntst_id%TYPE,
        p_st        nt_send_task.ntst_st%TYPE,
        p_dt        nt_send_task.ntst_delivered_dt%TYPE:= NULL,
        p_message   nt_send_log.ntsl_message%TYPE:= NULL)
    IS
        l_msg   VARCHAR2 (100);
    BEGIN
        UPDATE nt_send_task z
           SET ntst_st = p_st, ntst_delivered_dt = p_dt
         WHERE ntst_id = p_id;

        IF p_dt IS NOT NULL
        THEN
            UPDATE nt_send_task z
               SET ntst_delivered_dt = p_dt
             WHERE ntst_id = p_id;
        END IF;
    /*  SELECT NVL(p_message, 'Новий стан: <'||DECODE(p_st, 'R', 'Створено', 'P', 'Підтверджено', 'S', 'Надіслано', 'C', 'Надіслано частково', 'D', 'Відхилено', 'UNKNOWN')||'>')
      INTO l_msg
      FROM dual;

      WriteNtSendLog(p_ntst_id => p_id, p_message => NVL(p_message, l_msg));*/
    END;

    PROCEDURE SetNTSTConfirmed (p_id nt_send_task.ntst_id%TYPE)
    IS
    BEGIN
        SetNTSTState (p_id, 'P');
        WriteNtSendLog (p_ntst_id   => p_id,
                        p_message   => 'Завдання отримало дозвіл на обробку');
    END;

    PROCEDURE SetNTSTPartProcessedByProvider (p_id nt_send_task.ntst_id%TYPE)
    IS
    BEGIN
        SetNTSTState (p_id, 'C');
    END;

    PROCEDURE SetNTSTFullProcessedByProvider (
        p_id             nt_send_task.ntst_id%TYPE,
        p_delivered_dt   nt_send_task.ntst_delivered_dt%TYPE)
    IS
    BEGIN
        SetNTSTState (p_id, 'S', p_delivered_dt);
        WriteNtSendLog (
            p_ntst_id   => p_id,
            p_message   =>
                'Завдання повністю оброблене - всі повідомлення надіслані');
    END;

    PROCEDURE SetNTSTNotProcessedByProvider (p_id nt_send_task.ntst_id%TYPE)
    IS
    BEGIN
        SetNTSTState (p_id, 'D');
    END;

    PROCEDURE CheckNTSTState (p_ntst_id nt_send_task.ntst_id%TYPE)
    IS
        l_st            nt_send_task.ntst_st%TYPE;
        l_full_cnt      INTEGER;
        l_delivered     INTEGER;
        l_undelivered   INTEGER;
    BEGIN
        SELECT MIN (ntst_st),
               COUNT (1),
               SUM (DECODE (ntmt_st, 'D', 1, 0))     AS delivered,
               SUM (DECODE (ntmt_st, 'U', 1, 0))     AS undelivered
          INTO l_st,
               l_full_cnt,
               l_delivered,
               l_undelivered
          FROM nt_send_task, nt_msg2task
         WHERE     ntmt_ntst = ntst_id
               AND ntmt_ntst = p_ntst_id
               AND ntst_id = p_ntst_id;

        IF l_st = 'P' AND l_delivered = l_full_cnt
        THEN
            SetNTSTFullProcessedByProvider (p_id             => p_ntst_id,
                                            p_delivered_dt   => SYSDATE);
        ELSIF l_st = 'P' AND l_delivered > 0 AND l_delivered < l_full_cnt
        THEN
            SetNTSTPartProcessedByProvider (p_id => p_ntst_id);
        ELSIF l_st = 'C' AND l_delivered = l_full_cnt
        THEN
            SetNTSTFullProcessedByProvider (p_id             => p_ntst_id,
                                            p_delivered_dt   => SYSDATE);
        ELSIF l_st = 'C' AND (l_undelivered + l_delivered) = l_full_cnt
        THEN
            SetNTSTFullProcessedByProvider (p_id             => p_ntst_id,
                                            p_delivered_dt   => SYSDATE);
        ELSIF l_st IN ('P', 'C') AND l_undelivered = l_full_cnt
        THEN
            SetNTSTNotProcessedByProvider (p_id => p_ntst_id);
        END IF;
    END;

    PROCEDURE CheckNTSTState
    IS
    BEGIN
        FOR xx IN (SELECT ntst_id
                     FROM nt_send_task
                    WHERE ntst_st IN ('P', 'C'))
        LOOP
            CheckNTSTState (xx.ntst_id);
            COMMIT;
        END LOOP;
    END;

    --------------------------------------------------



    FUNCTION GetTemplateStr (p_mode             INTEGER,
                             p_id_template      VARCHAR2,
                             p_info_tp       IN VARCHAR2 DEFAULT 'EMAIL')
        RETURN VARCHAR2
    IS
        --отримуємо шаблон з messagetemplates по id шаблона (використовуємо кеш).
        l_id_template       NUMBER;
        l_id_template_ori   NUMBER;
        l_msg_text          VARCHAR2 (500);
        l_msg_text1         VARCHAR2 (500);
    BEGIN
        IF p_id_template IS NULL
        THEN
            RETURN NULL;
        ELSE
            BEGIN
                l_id_template_ori := TO_NUMBER (p_id_template);

                IF p_mode = 1
                THEN
                    l_id_template := l_id_template_ori;
                ELSE
                    l_id_template := 0 - l_id_template_ori;
                END IF;
            EXCEPTION
                WHEN OTHERS
                THEN
                    raise_application_error (
                        -20000,
                           'Невірний формат id шаблона. id_template ='
                        || p_id_template);
            END;

            BEGIN
                l_msg_text := g_templates (l_id_template || p_info_tp);
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    BEGIN
                        SELECT a.ntt_text, a.ntt_title
                          INTO l_msg_text, l_msg_text1
                          FROM uss_ndi.v_ndi_nt_template  a,
                               uss_ndi.v_ndi_nt_template_group
                         WHERE     a.ntt_ntg = ntg_id
                               AND ntg_id = l_id_template_ori
                               AND ntt_info_tp = p_info_tp;

                        g_templates (l_id_template_ori || p_info_tp) :=
                            l_msg_text;
                        g_templates ((0 - l_id_template_ori) || p_info_tp) :=
                            l_msg_text1;
                        l_msg_text :=
                            g_templates (l_id_template || p_info_tp);
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            l_msg_text :=
                                   'Відсутній шаблон id = '
                                || p_id_template
                                || ' в Довіднику шаблонів.';
                    END;
            END;
        END IF;

        RETURN l_msg_text;
    END GetTemplateStr;

    --проводить розбивку на значення та їх підстановку в шаблон,
    --вхідний параметр типу - '&31#71#27#794.81', або якщо довідник -'&71#@ZTX@132'
    FUNCTION GetMsgByTemplate (p_mode          INTEGER,
                               p_template   IN VARCHAR2,
                               p_tp         IN VARCHAR2,
                               p_info_tp    IN VARCHAR2 DEFAULT 'EMAIL')
        RETURN VARCHAR2
    IS
        l_cnt             NUMBER := 0;
        l_template_text   VARCHAR2 (500);
        l_msg_text        VARCHAR2 (500);
        l_dat_name        VARCHAR2 (100);
        l_dat_value       VARCHAR2 (100);
    BEGIN
        IF p_template IS NOT NULL
        THEN
            FOR cur IN (    SELECT REGEXP_SUBSTR (str,
                                                  '[^' || c_variable || ']+',
                                                  1,
                                                  LEVEL)    str
                              FROM (SELECT p_template str FROM DUAL) t
                        CONNECT BY INSTR (str,
                                          c_variable,
                                          1,
                                          LEVEL - 1) > 0)
            LOOP
                IF l_cnt = 0
                THEN
                    l_template_text :=
                        GetTemplateStr (p_mode, cur.str, p_info_tp);
                ELSE
                    IF p_tp = c_template1
                    THEN
                        l_dat_name :=
                            REGEXP_SUBSTR (cur.str,
                                           '[^' || c_eq || ']+',
                                           1,
                                           1);
                        l_dat_value :=
                            REGEXP_SUBSTR (cur.str,
                                           '[^' || c_eq || ']+',
                                           1,
                                           2);
                        --якщо не з довідника, то проводимо підстановку значень в шаблон
                        l_template_text :=
                            REPLACE (l_template_text,
                                     c_variable || l_dat_name || c_variable,
                                     l_dat_value);
                    ELSIF p_tp = c_template2
                    THEN
                        l_template_text :=
                            REGEXP_REPLACE (l_template_text,
                                            c_variable,
                                            cur.str,
                                            1,
                                            1);
                    END IF;
                END IF;

                l_cnt := l_cnt + 1;
            END LOOP;
        ELSE
            l_template_text := NULL;
        END IF;

        RETURN l_template_text;
    END GetMsgByTemplate;

    --проводить розбивку на шаблони
    FUNCTION GetMsgText (p_mode         INTEGER,
                         p_message   IN VARCHAR2,
                         p_info_tp   IN VARCHAR2 DEFAULT 'EMAIL')
        RETURN VARCHAR2
    IS
        l_msg   VARCHAR2 (500);
    --  l_space VARCHAR2(1);
    BEGIN
        FOR cur IN (    SELECT REGEXP_SUBSTR (
                                   str,
                                      '[^'
                                   || c_template1
                                   || '|'
                                   || c_template2
                                   || ']+',
                                   1,
                                   LEVEL)    str,
                               REGEXP_SUBSTR (
                                   str,
                                      '['
                                   || c_template1
                                   || '|'
                                   || c_template2
                                   || ']',
                                   1,
                                   LEVEL)    tp
                          FROM (SELECT p_message str FROM DUAL) t
                    CONNECT BY INSTR (str,
                                      c_template1 || '|' || c_template2,
                                      1,
                                      LEVEL) > 0)
        LOOP
            l_msg :=
                   l_msg
                || GetMsgByTemplate (p_mode,
                                     cur.str,
                                     cur.tp,
                                     p_info_tp);
        END LOOP;

        RETURN l_msg;
    END GetMsgText;

    --Повертає повідомлення в залежності від даних складу p_message. p_mode=1 - шаблон береться з ntt_text, p_mode=2 - шаблон береться з ntt_title
    FUNCTION GetMessageText (p_mode         INTEGER,
                             p_message   IN VARCHAR2 DEFAULT NULL,
                             p_info_tp   IN VARCHAR2 DEFAULT 'EMAIL')
        RETURN VARCHAR2
    IS
        l_msg_text   VARCHAR2 (4000);
    BEGIN
        IF p_message IS NULL
        THEN
            RETURN NULL;
        ELSE
            --Якщо параметр містить інформацію з id шаблонів
            IF SUBSTR (p_message, 1, 1) IN (c_template1, c_template2)
            THEN
                l_msg_text :=
                    SUBSTR (GetMsgText (p_mode, p_message, p_info_tp),
                            1,
                            3990);
            ELSE
                --якщо стрічка протоколу не починається з &
                l_msg_text := SUBSTR (p_message, 1, 3990);
            END IF;
        END IF;

        RETURN l_msg_text;
    END GetMessageText;

    PROCEDURE SendTestMessage (
        p_info_tp        nt_send_task.ntst_info_tp%TYPE,
        p_ntt            uss_ndi.v_ndi_nt_template.ntt_id%TYPE,
        p_contact        nt_message.ntm_contact%TYPE,
        p_title          nt_message.ntm_title%TYPE := 'PFU TEST',
        p_text           nt_message.ntm_text%TYPE,
        p_nip            nt_send_task.ntst_nip%TYPE,
        p_sc             nt_message.ntm_sc%TYPE := NULL,
        p_numident       nt_message.ntm_numident%TYPE := 'test',
        p_ntst_id    OUT nt_send_task.ntst_id%TYPE)
    IS
        l_id     nt_message.ntm_id%TYPE;
        l_ntst   nt_send_task.ntst_id%TYPE;
    BEGIN
        IF     (p_info_tp = 'SMS')
           AND NOT REGEXP_LIKE (p_contact, '^[+]{0,1}[3][8][0][0-9]{9}$')
        THEN
            raise_application_error (
                -20000,
                'Телефон вказано невірно - правильний формат 380NNNNNNNNN');
        END IF;

        INSERT INTO nt_message (ntm_numident,
                                ntm_sc,
                                ntm_register_dt,
                                ntm_source,
                                ntm_tp,
                                ntm_st,
                                ntm_title,
                                ntm_text,
                                ntm_ntg,
                                ntm_contact)
             VALUES (p_numident,
                     p_sc,
                     SYSDATE,
                     'TEST',
                     'PRI',
                     'R',
                     p_title,
                     p_text,
                     (SELECT ntt_ntg
                        FROM uss_ndi.v_ndi_nt_template
                       WHERE ntt_id = p_ntt),
                     p_contact)
          RETURNING ntm_id
               INTO l_id;

        INSERT INTO nt_send_task (ntst_register_dt,
                                  ntst_cnt,
                                  ntst_reason,
                                  ntst_st,
                                  ntst_nip,
                                  ntst_info_tp)
             VALUES (SYSDATE,
                     1,
                     'TEST',
                     'R',
                     p_nip,
                     p_info_tp)
          RETURNING ntst_id
               INTO l_ntst;

        INSERT INTO nt_msg2task (ntmt_ntst,
                                 ntmt_ntm,
                                 ntmt_st,
                                 ntmt_contact)
             VALUES (l_ntst,
                     l_id,
                     'R',
                     p_contact);

        SetNTSTConfirmed (l_ntst);

        p_ntst_id := l_ntst;
    END;

    PROCEDURE InsertAdmBlockedCode (
        p_nta_code   nt_adm_blocked_code.nta_code%TYPE)
    IS
    BEGIN
        INSERT INTO uss_person.v_nt_adm_blocked_code (nta_code, nta_block_dt)
             VALUES (p_nta_code, SYSDATE);
    END;

    FUNCTION InsertExtFile (p_nte_file_data   nt_ext_file.nte_file_data%TYPE,
                            p_nte_in_cnt      nt_ext_file.nte_in_cnt%TYPE,
                            p_nte_file_name   nt_ext_file.nte_file_name%TYPE)
        RETURN nt_ext_file.nte_id%TYPE
    IS
        l_id   nt_ext_file.nte_id%TYPE;
    BEGIN
        INSERT INTO nt_ext_file (nte_register_dt,
                                 nte_file_data,
                                 nte_st,
                                 nte_in_cnt,
                                 nte_file_name)
             VALUES (SYSDATE,
                     p_nte_file_data,
                     'R',
                     p_nte_in_cnt,
                     p_nte_file_name)
             RETURN nte_id
               INTO l_id;

        RETURN l_id;
    END;

    PROCEDURE process_ext_file (
        p_nte_id       uss_person.v_nt_ext_file.nte_id%TYPE,
        items      OUT SYS_REFCURSOR)
    IS
        l_cnt_ok     INTEGER;
        l_cnt_full   INTEGER;
        l_hs         histsession.hs_id%TYPE;
    BEGIN
        l_hs := TOOLS.GetHistSession;

        INSERT INTO uss_person.v_nt_send_log (ntsl_hs,
                                              ntsl_message,
                                              ntsl_nte)
             VALUES (l_hs, 'Файл збережено в БД. Починаю обробку', p_nte_id);

        uss_person.API$NT_API.SendMultipleByTT;

        SELECT COUNT (1), SUM (CASE WHEN m_error IS NULL THEN 1 ELSE 0 END)
          INTO l_cnt_full, l_cnt_ok
          FROM uss_person.tmp_src_nt_message
         WHERE m_nte_id = p_nte_id;

        FOR rec IN (  SELECT m_type
                        FROM uss_person.tmp_src_nt_message
                       WHERE m_error IS NULL
                    GROUP BY m_type)
        LOOP
            uss_person.API$NT_API.MakeSendTaskByParams (
                p_nip_id     => NULL,
                p_start_dt   => NULL,
                p_stop_dt    => NULL,
                p_ntg_id     => NULL,
                p_info_tp    => 'EMAIL',
                p_source     => 'FILE',
                p_nte        => p_nte_id,
                p_tp         => rec.m_type);
        END LOOP;


        UPDATE nt_ext_file
           SET nte_ok_cnt = l_cnt_ok, nte_gen_dt = SYSDATE
         WHERE nte_id = p_nte_id;

        FOR xx IN (SELECT m_sc,
                          m_ntt,
                          m_numident,
                          m_source,
                          m_type,
                          m_title,
                          m_text,
                          m_contact,
                          m_id,
                          m_error,
                          m_nte_id,
                          m_ntm_id
                     FROM uss_person.tmp_src_nt_message
                    WHERE m_nte_id = m_nte_id AND m_error IS NOT NULL)
        LOOP
            INSERT INTO nt_send_log (ntsl_hs, ntsl_message, ntsl_nte)
                     VALUES (
                                l_hs,
                                   'Помилка обробки рядка з № '
                                || xx.m_id
                                || ': '
                                || xx.m_error,
                                p_nte_id);
        END LOOP;

        INSERT INTO nt_send_log (ntsl_hs, ntsl_message, ntsl_nte)
                 VALUES (
                            l_hs,
                               'Файл оброблено. Повідомлень в файлі: '
                            || l_cnt_full
                            || '. Коректних повідомлень: '
                            || l_cnt_ok,
                            p_nte_id);


        OPEN items FOR SELECT nte_id,
                              nte_register_dt,
                              nte_st,
                              nte_in_cnt,
                              nte_ok_cnt,
                              nte_gen_dt,
                              nte_file_name
                         FROM nt_ext_file
                        WHERE nte_id = p_nte_id;
    END;
BEGIN
    NULL;
END API$NT_PROCESS;
/