/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$NT
IS
    -- Author  : VANO
    -- Created : 20.01.2023 12:29:04
    -- Purpose : Функції для обробки запитів веб-інтерфейсу

    -- Повертає список "Група шаблонів"
    PROCEDURE get_nt_template_group_list (
        p_nt_template_group_list   OUT SYS_REFCURSOR);

    -- Повертає список "Завдання на інформування"
    PROCEDURE get_nt_send_task_list (p_nt_send_task_list OUT SYS_REFCURSOR);

    -- Повертає запис "Завдання на інформування" за ID
    PROCEDURE get_nt_send_task_by_id (
        p_ntst_id       uss_person.v_nt_send_task.ntst_id%TYPE,
        main_info   OUT SYS_REFCURSOR,
        protocol    OUT SYS_REFCURSOR,
        messages    OUT SYS_REFCURSOR);

    -- Повертає повідомлення за ID завдання
    PROCEDURE get_nt_message_by_task (
        p_ntst_id       uss_person.v_nt_send_task.ntst_id%TYPE,
        items       OUT SYS_REFCURSOR);

    PROCEDURE get_nt_send_task_by_flt (
        p_ntst_register_dt_start   IN     DATE,
        p_ntst_register_dt_stop    IN     DATE,
        items                         OUT SYS_REFCURSOR);

    -- Повертає протокол обробки за ID завдання
    PROCEDURE get_nt_send_log_by_task (
        p_ntst_id       uss_person.v_nt_send_task.ntst_id%TYPE,
        items       OUT SYS_REFCURSOR);

    -- Повертає протокол обробки за ID повідомлення
    PROCEDURE get_nt_send_log_by_message (
        p_ntmt_id       uss_person.v_nt_send_task.ntst_id%TYPE,
        items       OUT SYS_REFCURSOR);

    -- Повертає запис "Повідомлення ЗО в задачі" за ID
    PROCEDURE get_nt_task_message_by_id (
        p_ntmt_id       uss_person.v_nt_msg2task.ntmt_id%TYPE,
        main_info   OUT SYS_REFCURSOR,
        protocol    OUT SYS_REFCURSOR);

    --Отримання рядків "Оператори інформування" на основі фільтру
    PROCEDURE get_nt_info_provider_by_flt (items OUT SYS_REFCURSOR);

    -- Повертає тарифи за ID оператора інформування
    PROCEDURE get_nt_tarif_by_provider (
        p_nip_id       uss_ndi.v_ndi_nt_info_provider.nip_id%TYPE,
        items      OUT SYS_REFCURSOR);

    --Отримання рядків "Файл повідомлень" на основі фільтру
    PROCEDURE get_nt_ext_file_by_flt (
        p_nte_register_dt_start   IN     DATE,
        p_nte_register_dt_stop    IN     DATE,
        p_nte_file_name           IN     VARCHAR2,
        items                        OUT SYS_REFCURSOR);

    -- Повертає протокол обробки за ID файлу
    PROCEDURE get_nt_send_log_by_file (
        p_nte_id       uss_person.v_nt_ext_file.nte_id%TYPE,
        items      OUT SYS_REFCURSOR);

    --Отримання рядків "Групи шаблонів" на основі фільтру
    PROCEDURE get_nt_template_group_by_flt (items OUT SYS_REFCURSOR);

    -- Повертає шаблони повідомлень за ID групи
    PROCEDURE get_nt_template_by_group (
        p_ntg_id       uss_ndi.v_ndi_nt_template_group.ntg_id%TYPE,
        items      OUT SYS_REFCURSOR);

    --Отримання рядків "Повідомлення, що невідправлені" на основі фільтру
    PROCEDURE get_nt_adm_by_flt (
        p_ntm_register_dt_start   IN     uss_person.v_nt_message.ntm_register_dt%TYPE,
        p_ntm_register_dt_stop    IN     uss_person.v_nt_message.ntm_register_dt%TYPE,
        p_ntm_nte                 IN     uss_person.v_nt_message.ntm_nte%TYPE,
        p_ntst_info_tp            IN     uss_person.v_nt_send_task.ntst_info_tp%TYPE,
        p_ntm_source              IN     uss_person.v_nt_message.ntm_source%TYPE,
        p_ntm_tp                  IN     uss_person.v_nt_message.ntm_tp%TYPE,
        items                        OUT SYS_REFCURSOR);

    --Створення задачі на інформування та повторне отримання рядків "Повідомлення, що невідправлені" на основі фільтру
    PROCEDURE make_send_task_by_flt (
        p_ntm_register_dt_start   IN     uss_person.v_nt_message.ntm_register_dt%TYPE,
        p_ntm_register_dt_stop    IN     uss_person.v_nt_message.ntm_register_dt%TYPE,
        p_ntm_nte                 IN     uss_person.v_nt_message.ntm_nte%TYPE,
        p_ntst_info_tp            IN     uss_person.v_nt_send_task.ntst_info_tp%TYPE,
        p_ntm_source              IN     uss_person.v_nt_message.ntm_source%TYPE,
        p_ntm_tp                  IN     uss_person.v_nt_message.ntm_tp%TYPE,
        p_ntm_code                IN     VARCHAR2,
        items                        OUT SYS_REFCURSOR);

    --Блокування коду на інформування та повторне отримання рядків "Повідомлення, що невідправлені" на основі фільтру
    PROCEDURE block_informing_by_flt (
        p_ntm_register_dt_start   IN     uss_person.v_nt_message.ntm_register_dt%TYPE,
        p_ntm_register_dt_stop    IN     uss_person.v_nt_message.ntm_register_dt%TYPE,
        p_ntm_nte                 IN     uss_person.v_nt_message.ntm_nte%TYPE,
        p_ntst_info_tp            IN     uss_person.v_nt_send_task.ntst_info_tp%TYPE,
        p_ntm_source              IN     uss_person.v_nt_message.ntm_source%TYPE,
        p_ntm_tp                  IN     uss_person.v_nt_message.ntm_tp%TYPE,
        p_ntm_code                IN     VARCHAR2,
        items                        OUT SYS_REFCURSOR);

    --Перевірка тестового повідомлення на основі фільтру
    PROCEDURE check_nt_test_message_by_flt (
        p_ntm_info_tp        IN     VARCHAR2,
        p_ntm_ntt            IN     NUMBER,
        p_ntm_contact               VARCHAR2,
        p_ntm_title                 VARCHAR2,
        p_ntm_text                  VARCHAR2,
        p_ntm_decoded_text          VARCHAR2,
        p_ntm_sc                    NUMBER,
        p_ntm_numident              VARCHAR2,
        items                   OUT SYS_REFCURSOR);

    --Формування тестового повідомлення на основі фільтру
    PROCEDURE send_nt_test_message_by_flt (
        p_ntm_info_tp        IN     VARCHAR2,
        p_ntm_ntt            IN     NUMBER,
        p_ntm_contact               VARCHAR2,
        p_ntm_title                 VARCHAR2,
        p_ntm_text                  VARCHAR2,
        p_ntm_decoded_text          VARCHAR2,
        p_ntm_sc                    NUMBER,
        p_ntm_numident              VARCHAR2,
        items                   OUT SYS_REFCURSOR);

    --Запис файлу в БД
    PROCEDURE save_nt_ext_file (p_file_name          VARCHAR2,
                                p_in_cnt             INTEGER,
                                p_file_data   IN     BLOB,
                                p_nte_id         OUT NUMBER);

    --Запис рядків файлу в тимчасову таблицю
    PROCEDURE save_src_message_by_file_line (p_id         NUMBER,
                                             p_numident   VARCHAR2,
                                             p_title      VARCHAR2,
                                             p_text       VARCHAR2,
                                             p_tp         VARCHAR2,
                                             p_nte        NUMBER);

    --Обробка завантажених рядків файлу
    PROCEDURE process_ext_file (
        p_nte_id       uss_person.v_nt_ext_file.nte_id%TYPE,
        items      OUT SYS_REFCURSOR);
END DNET$NT;
/


GRANT EXECUTE ON USS_ESR.DNET$NT TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$NT TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$NT
IS
    TYPE split_tbl IS TABLE OF VARCHAR2 (32767);

    FUNCTION split (list IN VARCHAR2, delimiter IN VARCHAR2 DEFAULT ',')
        RETURN split_tbl
    AS
        splitted   split_tbl := split_tbl ();
        i          PLS_INTEGER := 0;
        list_      VARCHAR2 (32767) := list;
    BEGIN
        LOOP
            i := INSTR (list_, delimiter);

            IF i > 0
            THEN
                splitted.EXTEND (1);
                splitted (splitted.LAST) := SUBSTR (list_, 1, i - 1);
                list_ := SUBSTR (list_, i + LENGTH (delimiter));
            ELSE
                splitted.EXTEND (1);
                splitted (splitted.LAST) := list_;
                RETURN splitted;
            END IF;
        END LOOP;
    END;

    -- Повертає список "Група шаблонів"
    PROCEDURE get_nt_template_group_list (
        p_nt_template_group_list   OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_nt_template_group_list FOR
            SELECT ntg_id,
                   ntg_is_blocked,
                   ntg_notes,
                   ntg_name,
                   ntg_is_need_confirm
              FROM uss_ndi.v_ndi_nt_template_group;
    END;

    -- Повертає список "Завдання на інформування"
    PROCEDURE get_nt_send_task_list (p_nt_send_task_list OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_nt_send_task_list FOR
            SELECT ntst_id,
                   ntst_nip,
                   com_org,
                   com_wu,
                   ntst_register_dt,
                   ntst_schedule_dt,
                   ntst_cnt,
                   ntst_reason,
                   ntst_st,
                   ntst_info_tp,
                   ntst_delivered_dt,
                   nip_name,
                   DECODE (
                       ntst_info_tp,
                       'SMS', 'СМС-інформування',
                       'EMAIL', 'Повідомлення електронною поштою',
                       'AGENT', 'Передача повідомлень оператору інформування',
                       '-')              AS ntst_info_tp_name,
                   DECODE (ntst_st,
                           'R', 'Створено',
                           'P', 'Підтверджено',
                           'S', 'Надіслано',
                           'C', 'Надіслано частково',
                           'D', 'Відхилено',
                           'UNKNOWN')    AS ntst_st_name
              FROM uss_person.v_nt_send_task, uss_ndi.v_ndi_nt_info_provider
             WHERE ntst_nip = nip_id(+);
    END;

    -- Повертає запис "Завдання на інформування" за ID
    PROCEDURE get_nt_send_task_by_id (
        p_ntst_id       uss_person.v_nt_send_task.ntst_id%TYPE,
        main_info   OUT SYS_REFCURSOR,
        protocol    OUT SYS_REFCURSOR,
        messages    OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN main_info FOR
            SELECT ntst_id,
                   ntst_nip,
                   com_org,
                   com_wu,
                   ntst_register_dt,
                   ntst_schedule_dt,
                   ntst_cnt,
                   ntst_reason,
                   ntst_st,
                   ntst_info_tp,
                   ntst_delivered_dt,
                   DECODE (
                       ntst_info_tp,
                       'SMS', 'СМС-інформування',
                       'EMAIL', 'Повідомлення електронною поштою',
                       'AGENT', 'Передача повідомлень оператору інформування',
                       '-')              AS ntst_info_tp_name,
                   DECODE (ntst_st,
                           'R', 'Створено',
                           'P', 'Підтверджено',
                           'S', 'Надіслано',
                           'C', 'Надіслано частково',
                           'D', 'Відхилено',
                           'UNKNOWN')    AS ntst_st_name,
                   nip_name
              FROM uss_person.v_nt_send_task, uss_ndi.v_ndi_nt_info_provider
             WHERE ntst_nip = nip_id(+) AND ntst_id = p_ntst_id;

        OPEN messages FOR
            SELECT ntmt_id,
                   ntmt_ntst,
                   ntmt_ntm,
                   ntm_id,
                   ntm_sc,
                   ntm_numident,
                   ntm_register_dt,
                   ntm_source,
                   ntm_tp,
                   ntm_st,
                   ntm_req_cnt,
                   ntm_delivered_dt,
                   ntm_title,
                   ntm_text,
                   ntmt_contact,
                   ntm_ntg,
                   ntmt_st,
                   ntmt_delivered_dt,
                   s.sc_unique,
                   DECODE (ntmt_st,
                           'R', 'Зареєстровано',
                           'A', 'Прийнято до відсилки провайдером',
                           'P', 'Надсилається',
                           'D', 'Надіслано',
                           'U', 'Відхилено',
                           '-')    AS ntmt_st_name
              FROM uss_person.v_nt_msg2task  t
                   LEFT JOIN uss_person.v_socialcard s
                       ON (s.sc_id = t.ntm_sc)
             WHERE ntmt_ntst = p_ntst_id;

        OPEN protocol FOR SELECT ntsl_ntst,
                                 ntsl_ntm,
                                 ntsl_id,
                                 hs_dt     AS ntsl_dt,
                                 ntsl_message
                            FROM uss_person.v_nt_send_log, v_histsession
                           WHERE ntsl_ntst = p_ntst_id AND ntsl_hs = hs_id;
    END;

    -- Повертає повідомлення за ID завдання
    PROCEDURE get_nt_message_by_task (
        p_ntst_id       uss_person.v_nt_send_task.ntst_id%TYPE,
        items       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN items FOR
            SELECT ntmt_id,
                   ntmt_ntst,
                   ntmt_ntm,
                   ntm_id,
                   ntm_sc,
                   ntm_numident,
                   ntm_register_dt,
                   ntm_source,
                   ntm_tp,
                   ntm_st,
                   ntm_req_cnt,
                   ntm_delivered_dt,
                   ntm_title,
                   ntm_text,
                   ntmt_contact,
                   ntm_ntg,
                   ntmt_st,
                   ntmt_delivered_dt,
                   DECODE (ntmt_st,
                           'R', 'Зареєстровано',
                           'A', 'Прийнято до відсилки провайдером',
                           'P', 'Надсилається',
                           'D', 'Надіслано',
                           'U', 'Відхилено',
                           '-')    AS ntmt_st_name
              FROM uss_person.v_nt_msg2task
             WHERE ntmt_ntst = p_ntst_id;
    END;

    -- Повертає протокол обробки за ID завдання
    PROCEDURE get_nt_send_log_by_task (
        p_ntst_id       uss_person.v_nt_send_task.ntst_id%TYPE,
        items       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN items FOR
            SELECT ntsl_ntst,
                   ntsl_ntm,
                   ntsl_id,
                   hs_dt     AS ntsl_dt,
                   ntsl_message
              FROM uss_person.v_nt_send_log, uss_person.v_histsession
             WHERE ntsl_ntst = p_ntst_id AND ntsl_hs = hs_id;
    END;

    -- Повертає запис "Повідомлення ЗО в задачі" за ID
    PROCEDURE get_nt_task_message_by_id (
        p_ntmt_id       uss_person.v_nt_msg2task.ntmt_id%TYPE,
        main_info   OUT SYS_REFCURSOR,
        protocol    OUT SYS_REFCURSOR)
    IS
        l_ntm    uss_person.v_nt_message.ntm_id%TYPE;
        l_ntst   uss_person.v_nt_send_task.ntst_id%TYPE;
    BEGIN
        SELECT ntmt_ntm, ntmt_ntst
          INTO l_ntm, l_ntst
          FROM uss_person.v_nt_msg2task
         WHERE ntmt_id = p_ntmt_id;

        OPEN main_info FOR SELECT ntmt_id,
                                  ntmt_ntst,
                                  ntmt_ntm,
                                  ntm_id,
                                  ntm_sc,
                                  ntm_numident,
                                  ntm_register_dt,
                                  ntm_source,
                                  ntm_tp,
                                  ntm_st,
                                  ntm_req_cnt,
                                  ntm_delivered_dt,
                                  ntm_title,
                                  ntm_text,
                                  ntmt_contact,
                                  ntm_ntg,
                                  ntmt_st,
                                  ntmt_delivered_dt
                             FROM uss_person.v_nt_msg2task
                            WHERE ntmt_id = p_ntmt_id;

        OPEN protocol FOR
            SELECT ntsl_ntst,
                   ntsl_ntm,
                   ntsl_id,
                   hs_dt     AS ntsl_dt,
                   ntsl_message
              FROM uss_person.v_nt_send_log,
                   uss_person.v_nt_msg2task,
                   uss_person.v_histsession
             WHERE     ntsl_ntm = ntmt_ntm
                   AND ntmt_id = p_ntmt_id
                   AND ntsl_hs = hs_id
            UNION ALL
            SELECT ntsl_ntst,
                   ntsl_ntm,
                   ntsl_id,
                   hs_dt     AS ntsl_dt,
                   ntsl_message
              FROM uss_person.v_nt_send_log, uss_person.v_histsession
             WHERE ntsl_ntst = l_ntst AND ntsl_hs = hs_id
            UNION ALL
            SELECT -1,
                   ntm_id,
                   -1,
                   ntm_register_dt,
                   'Повідомлення зареєстровано'
              FROM uss_person.v_nt_message
             WHERE ntm_id = l_ntm
            UNION ALL
            SELECT ntsl_ntst,
                   ntsl_ntm,
                   ntsl_id,
                   hs_dt     AS ntsl_dt,
                   ntsl_message
              FROM uss_person.v_nt_send_log,
                   uss_person.v_nt_message,
                   uss_person.v_histsession
             WHERE ntsl_ntm = ntm_id AND ntm_id = l_ntm AND ntsl_hs = hs_id;
    END;

    -- Повертає протокол обробки за ID повідомлення
    PROCEDURE get_nt_send_log_by_message (
        p_ntmt_id       uss_person.v_nt_send_task.ntst_id%TYPE,
        items       OUT SYS_REFCURSOR)
    IS
        l_ntm    uss_person.v_nt_message.ntm_id%TYPE;
        l_ntst   uss_person.v_nt_send_task.ntst_id%TYPE;
    BEGIN
        SELECT ntmt_ntm, ntmt_ntst
          INTO l_ntm, l_ntst
          FROM uss_person.v_nt_msg2task
         WHERE ntmt_id = p_ntmt_id;

        OPEN items FOR
            SELECT ntsl_ntst,
                   ntsl_ntm,
                   ntsl_id,
                   hs_dt     AS ntsl_dt,
                   ntsl_message
              FROM uss_person.v_nt_send_log,
                   uss_person.v_nt_msg2task,
                   uss_person.v_histsession
             WHERE     ntsl_ntm = ntmt_ntm
                   AND ntmt_id = p_ntmt_id
                   AND ntsl_hs = hs_id
            UNION ALL
            SELECT ntsl_ntst,
                   ntsl_ntm,
                   ntsl_id,
                   hs_dt     AS ntsl_dt,
                   ntsl_message
              FROM uss_person.v_nt_send_log, uss_person.v_histsession
             WHERE ntsl_ntst = l_ntst AND ntsl_hs = hs_id
            UNION ALL
            SELECT -1,
                   ntm_id,
                   -1,
                   ntm_register_dt,
                   'Повідомлення зареєстровано'
              FROM uss_person.v_nt_message
             WHERE ntm_id = l_ntm
            UNION ALL
            SELECT ntsl_ntst,
                   ntsl_ntm,
                   ntsl_id,
                   hs_dt     AS ntsl_dt,
                   ntsl_message
              FROM uss_person.v_nt_send_log,
                   uss_person.v_nt_message,
                   uss_person.v_histsession
             WHERE ntsl_ntm = ntm_id AND ntm_id = l_ntm AND ntsl_hs = hs_id;
    END;

    -- Повертає тарифи за ID оператора інформування
    PROCEDURE get_nt_tarif_by_provider (
        p_nip_id       uss_ndi.v_ndi_nt_info_provider.nip_id%TYPE,
        items      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN items FOR
            SELECT ntf_id,
                   ntf_info_tp,
                   ntf_value,
                   TO_CHAR (ntf_start_dt, 'DD.MM.YYYY')    AS ntf_start_dt,
                   TO_CHAR (ntf_stop_dt, 'DD.MM.YYYY')     AS ntf_stop_dt,
                   ntf_tel_code,
                   ntf_nip,
                   ntf_notes,
                   DECODE (
                       ntf_info_tp,
                       'SMS', 'СМС-інформування',
                       'EMAIL', 'Повідомлення електронною поштою',
                       'AGENT', 'Передача повідомлень оператору інформування',
                       '-')                                AS ntf_info_tp_name
              FROM uss_ndi.v_ndi_nt_tarif
             WHERE ntf_nip = p_nip_id;
    END;

    --Отримання рядків "Завдання на інформування" на основі фільтру
    PROCEDURE get_nt_send_task_by_flt (
        p_ntst_register_dt_start   IN     DATE,
        p_ntst_register_dt_stop    IN     DATE,
        items                         OUT SYS_REFCURSOR)
    IS
    -- l_xml_obj XMLTYPE;
    -- l_item ot_nt_send_task_flt;
    BEGIN
        --execute immediate q'[alter session set nls_date_format = 'yyyy-mm-dd"T"hh24:mi:ss"Z"']';
        --l_xml_obj := xmltype.createxml(filter);
        --l_xml_obj.toObject(l_item);

        OPEN items FOR
            SELECT ntst_id,
                   ntst_nip,
                   com_org,
                   com_wu,
                   ntst_register_dt,
                   ntst_schedule_dt,
                   ntst_cnt,
                   ntst_reason,
                   ntst_st,
                   ntst_info_tp,
                   ntst_delivered_dt,
                   nip_name,
                   DECODE (
                       ntst_info_tp,
                       'SMS', 'СМС-інформування',
                       'EMAIL', 'Повідомлення електронною поштою',
                       'AGENT', 'Передача повідомлень оператору інформування',
                       '-')              AS ntst_info_tp_name,
                   DECODE (ntst_st,
                           'R', 'Створено',
                           'P', 'Підтверджено',
                           'S', 'Надіслано',
                           'C', 'Надіслано частково',
                           'D', 'Відхилено',
                           'UNKNOWN')    AS ntst_st_name
              FROM uss_person.v_nt_send_task, uss_ndi.v_ndi_nt_info_provider
             WHERE     ntst_nip = nip_id(+)
                   AND (   p_ntst_register_dt_start IS NULL
                        OR ntst_register_dt >=
                           TRUNC (p_ntst_register_dt_start))
                   AND (   p_ntst_register_dt_stop IS NULL
                        OR ntst_register_dt <
                           TRUNC (p_ntst_register_dt_stop) + 1);
    END;

    --Отримання рядків "Оператори інформування" на основі фільтру
    PROCEDURE get_nt_info_provider_by_flt (items OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN items FOR
            SELECT nip_id,
                   nip_name,
                   nip_sname,
                   nip_notes
              FROM uss_ndi.v_ndi_nt_info_provider;
    END;

    --Отримання рядків "Файл повідомлень" на основі фільтру
    PROCEDURE get_nt_ext_file_by_flt (
        p_nte_register_dt_start   IN     DATE,
        p_nte_register_dt_stop    IN     DATE,
        p_nte_file_name           IN     VARCHAR2,
        items                        OUT SYS_REFCURSOR)
    IS
    --l_xml_obj XMLTYPE;
    --l_item ot_nt_ext_file_flt;
    BEGIN
        OPEN items FOR
            SELECT nte_id,
                   nte_register_dt,
                   nte_st,
                   nte_in_cnt,
                   nte_ok_cnt,
                   nte_gen_dt,
                   nte_file_name
              FROM uss_person.v_nt_ext_file t
             WHERE     1 = 1
                   AND (   p_nte_register_dt_start IS NULL
                        OR nte_register_dt >= TRUNC (p_nte_register_dt_start))
                   AND (   p_nte_register_dt_stop IS NULL
                        OR nte_register_dt <= p_nte_register_dt_stop)
                   AND (   p_nte_file_name IS NULL
                        OR nte_file_name LIKE p_nte_file_name || '%');
    END;

    -- Повертає протокол обробки за ID файлу
    PROCEDURE get_nt_send_log_by_file (
        p_nte_id       uss_person.v_nt_ext_file.nte_id%TYPE,
        items      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN items FOR
            SELECT ntsl_ntst,
                   ntsl_ntm,
                   ntsl_id,
                   hs_dt     AS ntsl_dt,
                   ntsl_message
              FROM uss_person.v_nt_send_log, uss_person.v_histsession
             WHERE ntsl_nte = p_nte_id AND ntsl_hs = hs_id;
    END;

    --Отримання рядків "Групи шаблонів" на основі фільтру
    PROCEDURE get_nt_template_group_by_flt (items OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN items FOR
            SELECT ntg_id,
                   ntg_is_blocked,
                   ntg_notes,
                   ntg_name,
                   ntg_is_need_confirm
              FROM uss_ndi.v_ndi_nt_template_group;
    END;

    -- Повертає шаблони повідомлень за ID групи
    PROCEDURE get_nt_template_by_group (
        p_ntg_id       uss_ndi.v_ndi_nt_template_group.ntg_id%TYPE,
        items      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN items FOR
            SELECT ntt_id,
                   ntt_text,
                   ntt_title,
                   ntt_ntg,
                   ntt_info_tp,
                   DECODE (
                       ntt_info_tp,
                       'SMS', 'СМС-інформування',
                       'EMAIL', 'Повідомлення електронною поштою',
                       'AGENT', 'Передача повідомлень оператору інформування',
                       '-')    AS ntt_info_tp_name
              FROM uss_ndi.v_ndi_nt_template
             WHERE ntt_ntg = p_ntg_id;
    END;

    --Отримання рядків "Повідомлення, що невідправлені" на основі фільтру
    PROCEDURE get_nt_adm_by_flt (
        p_ntm_register_dt_start   IN     uss_person.v_nt_message.ntm_register_dt%TYPE,
        p_ntm_register_dt_stop    IN     uss_person.v_nt_message.ntm_register_dt%TYPE,
        p_ntm_nte                 IN     uss_person.v_nt_message.ntm_nte%TYPE,
        p_ntst_info_tp            IN     uss_person.v_nt_send_task.ntst_info_tp%TYPE,
        p_ntm_source              IN     uss_person.v_nt_message.ntm_source%TYPE,
        p_ntm_tp                  IN     uss_person.v_nt_message.ntm_tp%TYPE,
        items                        OUT SYS_REFCURSOR)
    IS
    --l_xml_obj XMLTYPE;
    --l_item ot_nt_adm_flt;
    BEGIN
        --Встановлення формату дати-часу, в якому поступають відповідні поля з .NET - для машини парсінга XML з параметру filter.
        -- execute immediate q'[alter session set nls_date_format = 'yyyy-mm-dd"T"hh24:mi:ss"Z"']';
        -- l_xml_obj := xmltype.createxml(filter);
        --l_xml_obj.toObject(l_item);

        OPEN items FOR
              SELECT *
                FROM (SELECT ntm_info_tp,
                             dic_name                                 AS ntm_info_tp_name,
                             ntm_day,
                             NVL ( (SELECT dic_name
                                      FROM uss_ndi.v_ddn_nt_source
                                     WHERE ntm_source = dic_value),
                                  'Не визначено')                     AS ntm_source_name,
                             NVL ( (SELECT dic_name
                                      FROM uss_ndi.v_ddn_nt_tp
                                     WHERE ntm_tp = dic_value),
                                  'Не визначено')                     AS ntm_tp_name,
                             NVL ( (SELECT nte_file_name
                                      FROM uss_person.v_nt_ext_file
                                     WHERE ntm_nte = nte_id),
                                  'Не визначено')                     AS ntm_file_name,
                             ntm_cnt,
                                ntm_info_tp
                             || '#'
                             || TO_CHAR (ntm_day, 'dd.mm.yyyy')
                             || '#'
                             || ntm_source
                             || '#'
                             || ntm_tp
                             || '#'
                             || ntm_nte                               AS ntm_code,
                             COUNT (*) OVER (PARTITION BY ntm_day)    AS rspan
                        FROM uss_ndi.v_ddn_nt_info_tp,
                             (  SELECT dic_value                   AS ntm_info_tp,
                                       TRUNC (ntm_register_dt)     AS ntm_day,
                                       NVL (ntm_source, '-')       AS ntm_source,
                                       NVL (ntm_tp, '-')           AS ntm_tp,
                                       ntm_nte,
                                       COUNT (1)                   AS ntm_cnt
                                  FROM uss_ndi.v_ddn_nt_info_tp,
                                       uss_person.v_nt_message z
                                 WHERE     NOT EXISTS
                                               (SELECT 1
                                                  FROM uss_person.v_nt_msg2task,
                                                       uss_person.v_nt_send_task
                                                 WHERE     ntmt_ntm = ntm_id
                                                       AND ntmt_ntst = ntst_id
                                                       AND ntst_info_tp =
                                                           dic_value)
                                       AND EXISTS
                                               (SELECT 1
                                                  FROM uss_person.v_socialcard,
                                                       uss_person.v_sc_change,
                                                       uss_person.v_sc_contact
                                                 WHERE     sc_id = ntm_sc
                                                       AND scc_sc = sc_id
                                                       AND sc_scc = scc_id
                                                       AND scc_sct = sct_id)
                                       AND (   ntm_ntg IS NULL
                                            OR EXISTS
                                                   (SELECT 1
                                                      FROM uss_ndi.v_ndi_nt_template
                                                     WHERE     ntt_ntg = ntm_ntg
                                                           AND ntt_info_tp =
                                                               dic_value))
                                       --Відхилені повідомлення не обробляемо
                                       AND ntm_st <> 'U'
                                       --Тестові повідомлення не обробляемо - по ним вже створені необхідні завдання
                                       AND ntm_source <> 'TEST'
                                       AND (   p_ntm_register_dt_start IS NULL
                                            OR ntm_register_dt >=
                                               TRUNC (p_ntm_register_dt_start))
                                       AND (   p_ntm_register_dt_stop IS NULL
                                            OR ntm_register_dt <
                                               TRUNC (p_ntm_register_dt_stop) + 1)
                                       AND (   p_ntm_source IS NULL
                                            OR ntm_source = p_ntm_source)
                                       AND (p_ntm_tp IS NULL OR ntm_tp = p_ntm_tp)
                                       AND (   p_ntst_info_tp IS NULL
                                            OR dic_value = p_ntst_info_tp)
                                       AND (   p_ntm_nte IS NULL
                                            OR p_ntm_nte = 0
                                            OR ntm_nte = p_ntm_nte)
                              GROUP BY dic_value,
                                       TRUNC (ntm_register_dt),
                                       ntm_source,
                                       ntm_tp,
                                       ntm_nte)
                       WHERE ntm_info_tp = dic_value)
               WHERE NOT EXISTS
                         (SELECT 1
                            FROM uss_person.v_nt_adm_blocked_code
                           WHERE ntm_code = nta_code)
            ORDER BY ntm_day,
                     ntm_info_tp,
                     ntm_source_name,
                     ntm_tp_name,
                     ntm_file_name;
    END;

    --Створення задачі на інформування та повторне отримання рядків "Повідомлення, що невідправлені" на основі фільтру
    PROCEDURE make_send_task_by_flt (
        p_ntm_register_dt_start   IN     uss_person.v_nt_message.ntm_register_dt%TYPE,
        p_ntm_register_dt_stop    IN     uss_person.v_nt_message.ntm_register_dt%TYPE,
        p_ntm_nte                 IN     uss_person.v_nt_message.ntm_nte%TYPE,
        p_ntst_info_tp            IN     uss_person.v_nt_send_task.ntst_info_tp%TYPE,
        p_ntm_source              IN     uss_person.v_nt_message.ntm_source%TYPE,
        p_ntm_tp                  IN     uss_person.v_nt_message.ntm_tp%TYPE,
        p_ntm_code                IN     VARCHAR2,
        items                        OUT SYS_REFCURSOR)
    IS
        --l_xml_obj XMLTYPE;
        --l_item ot_nt_adm_flt;
        dat     split_tbl;
        l_nip   uss_ndi.v_ndi_nt_info_provider.nip_id%TYPE;
    BEGIN
        --Встановлення формату дати-часу, в якому поступають відповідні поля з .NET - для машини парсінга XML з параметру filter.
        --execute immediate q'[alter session set nls_date_format = 'yyyy-mm-dd"T"hh24:mi:ss"Z"']';
        --l_xml_obj := xmltype.createxml(filter);
        --l_xml_obj.toObject(l_item);

        IF p_ntm_code IS NULL
        THEN
            raise_application_error (
                -20000,
                'Не вказано параметрів створення задач інформування!');
        END IF;

        dat := split (p_ntm_code, '#');

        IF dat.LAST < 5
        THEN
            raise_application_error (
                -20000,
                'Параметри створення задачі вказано некоректно!');
        END IF;

        SELECT MIN (nip_id)
          INTO l_nip
          FROM uss_ndi.v_ndi_nt_info_provider, uss_ndi.v_ndi_nt_tarif
         WHERE ntf_nip = nip_id AND ntf_info_tp = dat (1);

        uss_person.API$NT_API.MakeSendTaskByParams (
            p_nip_id     => l_nip,
            p_start_dt   => TO_DATE (dat (2), 'dd.mm.yyyy'),
            p_stop_dt    => TO_DATE (dat (2), 'dd.mm.yyyy') + 86399 / 86400,
            p_ntg_id     => NULL,
            p_info_tp    => dat (1),
            p_source     => dat (3),
            p_tp         => dat (4),
            p_nte        => dat (5));

        get_nt_adm_by_flt (p_ntm_register_dt_start,
                           p_ntm_register_dt_stop,
                           p_ntm_nte,
                           p_ntst_info_tp,
                           p_ntm_source,
                           p_ntm_tp,
                           items);
    END;

    --Блокування коду на інформування та повторне отримання рядків "Повідомлення, що невідправлені" на основі фільтру
    PROCEDURE block_informing_by_flt (
        p_ntm_register_dt_start   IN     uss_person.v_nt_message.ntm_register_dt%TYPE,
        p_ntm_register_dt_stop    IN     uss_person.v_nt_message.ntm_register_dt%TYPE,
        p_ntm_nte                 IN     uss_person.v_nt_message.ntm_nte%TYPE,
        p_ntst_info_tp            IN     uss_person.v_nt_send_task.ntst_info_tp%TYPE,
        p_ntm_source              IN     uss_person.v_nt_message.ntm_source%TYPE,
        p_ntm_tp                  IN     uss_person.v_nt_message.ntm_tp%TYPE,
        p_ntm_code                IN     VARCHAR2,
        items                        OUT SYS_REFCURSOR)
    IS
        --l_xml_obj XMLTYPE;
        -- l_item ot_nt_adm_flt;
        dat     split_tbl;
        l_nip   uss_ndi.v_ndi_nt_info_provider.nip_id%TYPE;
    BEGIN
        --Встановлення формату дати-часу, в якому поступають відповідні поля з .NET - для машини парсінга XML з параметру filter.
        -- execute immediate q'[alter session set nls_date_format = 'yyyy-mm-dd"T"hh24:mi:ss"Z"']';
        --l_xml_obj := xmltype.createxml(filter);
        --l_xml_obj.toObject(l_item);

        IF p_ntm_code IS NULL
        THEN
            raise_application_error (
                -20000,
                'Не вказано параметрів блокування задач інформування!');
        END IF;

        uss_person.API$NT_PROCESS.InsertAdmBlockedCode (p_ntm_code);

        get_nt_adm_by_flt (p_ntm_register_dt_start,
                           p_ntm_register_dt_stop,
                           p_ntm_nte,
                           p_ntst_info_tp,
                           p_ntm_source,
                           p_ntm_tp,
                           items);
    END;

    --Перевірка тестового повідомлення на основі фільтру
    PROCEDURE check_nt_test_message_by_flt (
        p_ntm_info_tp        IN     VARCHAR2,
        p_ntm_ntt            IN     NUMBER,
        p_ntm_contact               VARCHAR2,
        p_ntm_title                 VARCHAR2,
        p_ntm_text                  VARCHAR2,
        p_ntm_decoded_text          VARCHAR2,
        p_ntm_sc                    NUMBER,
        p_ntm_numident              VARCHAR2,
        items                   OUT SYS_REFCURSOR)
    IS
        --l_xml_obj XMLTYPE;
        --l_item ot_nt_test_message_flt;
        l_error   VARCHAR2 (250) := NULL;
    BEGIN
        --l_xml_obj := xmltype.createxml(filter);
        --l_xml_obj.toObject(l_item);

        IF     (p_ntm_info_tp = 'SMS')
           AND (   p_ntm_contact IS NULL
                OR (NOT (    REGEXP_LIKE (p_ntm_contact, '\d{12,}')
                         AND LENGTH (p_ntm_contact) = 12
                         AND REGEXP_LIKE (p_ntm_contact, '^[3][8][0]'))))
        THEN
            l_error :=
                'Телефон вказано невірно - паравильний формат 380NNNNNNNNN';
        END IF;

        IF     (p_ntm_info_tp = 'EMAIL')
           AND (   p_ntm_contact IS NULL
                OR NOT (REGEXP_LIKE (p_ntm_contact, '^(\S+)\@(\S+)\.(\S+)$')))
        THEN
            l_error :=
                'Адреса електронної пошти вказана невірно - правильний формат: <ім`я>@<домен принаймні з 1 крапкою>';
        END IF;

        IF (p_ntm_info_tp = 'EMAIL') AND (p_ntm_title IS NULL)
        THEN
            l_error :=
                'Для повідомлень електронною поштою вкажіть заголовок повідомлення';
        END IF;

        OPEN items FOR
            SELECT p_ntm_info_tp    AS ntm_info_tp,
                   p_ntm_ntt        AS ntm_ntt,
                   p_ntm_contact    AS ntm_contact,
                   p_ntm_title      AS ntm_title,
                   p_ntm_text       AS ntm_text,
                   CASE
                       WHEN l_error IS NULL
                       THEN
                           uss_person.api$nt_process.GetMessageText (
                               1,
                               p_ntm_text,
                               p_ntm_info_tp)
                       ELSE
                           l_error
                   END              AS ntm_decoded_text,
                   NULL             AS ntst_id,
                   l_error          AS error_message
              FROM DUAL;
    END;

    --Формування тестового повідомлення на основі фільтру
    PROCEDURE send_nt_test_message_by_flt (
        p_ntm_info_tp        IN     VARCHAR2,
        p_ntm_ntt            IN     NUMBER,
        p_ntm_contact               VARCHAR2,
        p_ntm_title                 VARCHAR2,
        p_ntm_text                  VARCHAR2,
        p_ntm_decoded_text          VARCHAR2,
        p_ntm_sc                    NUMBER,
        p_ntm_numident              VARCHAR2,
        items                   OUT SYS_REFCURSOR)
    IS
        -- l_xml_obj XMLTYPE;
        --l_item ot_nt_test_message_flt;
        l_ntst_id1       uss_person.v_nt_send_task.ntst_id%TYPE;
        l_ntst_id2       uss_person.v_nt_send_task.ntst_id%TYPE;
        l_ntmt_tel       uss_person.v_nt_msg2task.ntmt_contact%TYPE;
        l_ntmt_email     uss_person.v_nt_msg2task.ntmt_contact%TYPE;


        l_ntm_contact    VARCHAR2 (100) := p_ntm_contact;
        l_ntm_info_tp    VARCHAR2 (10) := p_ntm_info_tp;
        l_ntm_title      VARCHAR2 (100);
        l_ntm_text       VARCHAR2 (4000);
        l_ntm_numident   VARCHAR2 (50);

        l_error          VARCHAR2 (250) := NULL;

        FUNCTION SendMSG
            RETURN NUMBER
        IS
            l_nip       uss_ndi.v_ndi_nt_info_provider.nip_id%TYPE;
            l_ntst_id   uss_person.v_nt_send_task.ntst_id%TYPE;
        BEGIN
            SELECT MIN (nip_id)
              INTO l_nip
              FROM uss_ndi.v_ndi_nt_info_provider, uss_ndi.v_ndi_nt_tarif
             WHERE ntf_nip = nip_id AND ntf_info_tp = p_ntm_info_tp;

            IF l_error IS NULL
            THEN
                uss_person.api$nt_process.sendtestmessage (
                    p_info_tp    => l_ntm_info_tp,
                    p_ntt        => p_ntm_ntt,
                    p_contact    => l_ntm_contact,
                    p_title      => p_ntm_title,
                    p_text       => p_ntm_text,
                    p_nip        => l_nip,
                    p_sc         => p_ntm_sc,
                    p_numident   => p_ntm_numident,
                    p_ntst_id    => l_ntst_id);
            END IF;

            RETURN l_ntst_id;
        END;
    BEGIN
        --l_xml_obj := xmltype.createxml(filter);
        -- l_xml_obj.toObject(l_item);

        IF p_ntm_sc IS NULL
        THEN
            IF     (p_ntm_info_tp = 'SMS')
               AND (   p_ntm_contact IS NULL
                    OR (NOT REGEXP_LIKE (p_ntm_contact,
                                         '^[+]{0,1}[3][8][0][0-9]{9}$')))
            THEN
                l_error :=
                    'Телефон вказано невірно - правильний формат 380NNNNNNNNN';
            END IF;

            IF     (p_ntm_info_tp = 'EMAIL')
               AND (   p_ntm_contact IS NULL
                    OR NOT (REGEXP_LIKE (p_ntm_contact,
                                         '^(\S+)\@(\S+)\.(\S+)$')))
            THEN
                l_error :=
                    'Адреса електронної пошти вказана невірно - правильний формат: <ім`я>@<домен принаймні з 1 крапкою>';
            END IF;

            IF (p_ntm_info_tp = 'EMAIL') AND (p_ntm_title IS NULL)
            THEN
                l_error :=
                    'Для повідомлень електронною поштою вкажіть заголовок повідомлення';
            END IF;

            l_ntst_id1 := SendMSG ();

            OPEN items FOR
                SELECT p_ntm_info_tp    AS ntm_info_tp,
                       p_ntm_ntt        AS ntm_ntt,
                       p_ntm_contact    AS ntm_contact,
                       p_ntm_title      AS ntm_title,
                       p_ntm_text       AS ntm_text,
                       CASE
                           WHEN l_error IS NULL
                           THEN
                               uss_person.api$nt_process.GetMessageText (
                                   1,
                                   p_ntm_text,
                                   p_ntm_info_tp)
                           ELSE
                               l_error
                       END              AS ntm_decoded_text,
                       l_ntst_id1       AS ntst_id,
                       l_error          AS error_message
                  FROM DUAL;
        ELSE
            SELECT sct_phone_mob,
                   sct_email,
                   '&11',
                      '&11#fio='
                   || sco_ln
                   || CASE
                          WHEN sco_fn IS NOT NULL
                          THEN
                              ' ' || SUBSTR (sco_fn, 1, 1) || '.'
                      END
                   || CASE
                          WHEN sco_mn IS NOT NULL
                          THEN
                              ' ' || SUBSTR (sco_mn, 1, 1) || '.'
                      END,
                   sco_numident
              INTO l_ntmt_tel,
                   l_ntmt_email,
                   l_ntm_title,
                   l_ntm_text,
                   l_ntm_numident
              FROM uss_person.v_socialcard,
                   uss_person.v_sc_change,
                   uss_person.v_sc_contact,
                   uss_person.v_sc_info
             WHERE     sc_id = p_ntm_sc
                   AND scc_sc = sc_id
                   AND sc_scc = scc_id
                   AND scc_sct = sct_id
                   AND sco_id = sc_id
                   AND sco_id = p_ntm_sc;

            IF l_ntmt_tel IS NOT NULL
            THEN
                l_ntm_info_tp := 'SMS';
                l_ntm_contact := l_ntmt_tel;
                l_ntst_id1 := SendMSG ();
            END IF;

            IF l_ntmt_email IS NOT NULL
            THEN
                l_ntm_info_tp := 'EMAIL';
                l_ntm_contact := l_ntmt_email;
                l_ntst_id2 := SendMSG ();
            END IF;

            OPEN items FOR
                SELECT l_ntm_info_tp    AS ntm_info_tp,
                       p_ntm_ntt        AS ntm_ntt,
                       l_ntmt_tel       AS ntm_contact,
                       l_ntm_title      AS ntm_title,
                       l_ntm_text       AS ntm_text,
                       CASE
                           WHEN l_error IS NULL
                           THEN
                               uss_person.api$nt_process.GetMessageText (
                                   1,
                                   p_ntm_text,
                                   'SMS')
                           ELSE
                               l_error
                       END              AS ntm_decoded_text,
                       l_ntst_id1       AS ntst_id,
                       l_error          AS error_message
                  FROM DUAL
                 WHERE l_ntst_id1 IS NOT NULL
                UNION ALL
                SELECT l_ntm_info_tp    AS ntm_info_tp,
                       p_ntm_ntt        AS ntm_ntt,
                       l_ntmt_email     AS ntm_contact,
                       l_ntm_title      AS ntm_title,
                       l_ntm_text       AS ntm_text,
                       CASE
                           WHEN l_error IS NULL
                           THEN
                               uss_person.api$nt_process.GetMessageText (
                                   1,
                                   p_ntm_text,
                                   'EMAIL')
                           ELSE
                               l_error
                       END              AS ntm_decoded_text,
                       l_ntst_id2       AS ntst_id,
                       l_error          AS error_message
                  FROM DUAL
                 WHERE l_ntst_id2 IS NOT NULL;
        END IF;
    END;

    --Запис файлу в БД
    PROCEDURE save_nt_ext_file (p_file_name          VARCHAR2,
                                p_in_cnt             INTEGER,
                                p_file_data   IN     BLOB,
                                p_nte_id         OUT NUMBER)
    IS
        --l_xml_obj XMLTYPE;
        l_nte_id   uss_person.v_nt_send_task.ntst_id%TYPE;
        --l_nip uss_ndi.v_ndi_nt_info_provider.nip_id%TYPE;
        --l_error VARCHAR2(250) := NULL;
        l_cnt      INTEGER;
    BEGIN
        SELECT COUNT (1)
          INTO l_cnt
          FROM uss_person.v_nt_ext_file
         WHERE     nte_file_name = p_file_name
               AND nte_register_dt > TRUNC (SYSDATE) - 7;

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                'Файл з ім`ям "' || p_file_name || '" вже оброблявся!');
        END IF;

        p_nte_id :=
            uss_person.api$nt_process.InsertExtFile (p_file_data,
                                                     p_in_cnt,
                                                     p_file_name);
    /*OPEN items FOR
      SELECT nte_id, nte_register_dt, nte_st, nte_in_cnt,
             nte_ok_cnt, nte_gen_dt, nte_file_name
      FROM nt_ext_file
      WHERE nte_id = l_nte_id;*/
    END;

    --Запис рядків файлу в тимчасову таблицю
    PROCEDURE save_src_message_by_file_line (p_id         NUMBER,
                                             p_numident   VARCHAR2,
                                             p_title      VARCHAR2,
                                             p_text       VARCHAR2,
                                             p_tp         VARCHAR2,
                                             p_nte        NUMBER)
    IS
    BEGIN
        INSERT INTO uss_person.tmp_src_nt_message (m_id,
                                                   m_numident,
                                                   m_source,
                                                   m_type,
                                                   m_title,
                                                   m_text,
                                                   m_nte_id,
                                                   m_ntg)
                 VALUES (
                            p_id,
                            p_numident,
                            'FILE',
                            p_tp,
                            p_title,
                            p_text,
                            p_nte,
                            CASE
                                WHEN SUBSTR (p_text, 1, 1) IN ('&', '@')
                                THEN
                                    CASE
                                        WHEN INSTR (p_text, '#') > 0
                                        THEN
                                            SUBSTR (p_text,
                                                    2,
                                                    INSTR (p_text, '#') - 2)
                                        ELSE
                                            SUBSTR (p_text, 2)
                                    END
                                ELSE
                                    NULL
                            END);
    END;

    --Обробка завантажених рядків файлу
    PROCEDURE process_ext_file (
        p_nte_id       uss_person.v_nt_ext_file.nte_id%TYPE,
        items      OUT SYS_REFCURSOR)
    IS
    BEGIN
        uss_person.api$nt_process.process_ext_file (p_nte_id, items);
    END;
BEGIN
    -- Initialization
    NULL;
END DNET$NT;
/