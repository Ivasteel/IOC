/* Formatted on 8/12/2025 5:56:53 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.API$NT_API
IS
    -- Author  : VANO
    -- Created : 20.01.2023 11:37:18
    -- Purpose : Функції ведення повідомлень та завдань модуля інформування

    PROCEDURE Sendrnspmail (p_Rnspm_Id   IN NUMBER,
                            p_Source        Nt_Message.Ntm_Source%TYPE,
                            p_Title         Nt_Message.Ntm_Title%TYPE,
                            p_Text          Nt_Message.Ntm_Text%TYPE);

    PROCEDURE Sendcmesmessage (p_Cu2r_Id   NUMBER,
                               p_Source    Nt_Message.Ntm_Source%TYPE,
                               p_Title     Nt_Message.Ntm_Title%TYPE,
                               p_Text      Nt_Message.Ntm_Text%TYPE);

    PROCEDURE SendCmesReqMessage (p_Crr_Id   NUMBER,
                                  p_Source   Nt_Message.Ntm_Source%TYPE,
                                  p_Title    Nt_Message.Ntm_Title%TYPE,
                                  p_Text     Nt_Message.Ntm_Text%TYPE);

    PROCEDURE SendRcMessage (p_email    Nt_Message.Ntm_Contact%TYPE,
                             p_source   nt_message.ntm_source%TYPE,
                             p_title    nt_message.ntm_title%TYPE,
                             p_text     nt_message.ntm_text%TYPE);

    PROCEDURE Sendmonitoringmessage (
        p_Rec_Id       Uss_Ndi.v_Ndi_Ms_Recipient.Rec_Id%TYPE,
        p_Source       Nt_Message.Ntm_Source%TYPE,
        p_Title        Nt_Message.Ntm_Title%TYPE,
        p_Text         Nt_Message.Ntm_Text%TYPE,
        p_Ntm_Id   OUT Nt_Message.Ntm_Id%TYPE);

    PROCEDURE Sendonebynumident (
        p_Numident       Nt_Message.Ntm_Numident%TYPE,
        p_Sc             Nt_Message.Ntm_Sc%TYPE := NULL,
        p_Source         Nt_Message.Ntm_Source%TYPE := NULL,
        p_Type           Nt_Message.Ntm_Tp%TYPE := NULL,
        p_Ntg            Nt_Message.Ntm_Ntg%TYPE := NULL,
        p_Contact        Nt_Message.Ntm_Contact%TYPE := NULL,
        p_Title          Nt_Message.Ntm_Title%TYPE := NULL,
        p_Text           Nt_Message.Ntm_Text%TYPE := NULL,
        p_Nte            Nt_Ext_File.Nte_Id%TYPE := NULL,
        p_Id         OUT Nt_Message.Ntm_Id%TYPE,
        p_Error      OUT Nt_Message.Ntm_Contact%TYPE);

    /* -- функция для вызыва из РЗО, для отправки сообщения с прикрепленным файлом
     PROCEDURE Sendstrongbynumident(p_numident  nt_message.ntm_numident%TYPE,
                                    p_ip        nt_message.ntm_sc%TYPE := NULL,
                                    p_source    nt_message.ntm_source%TYPE := NULL, --'RZO'
                                    p_type      nt_message.ntm_tp%TYPE := NULL, --'PRI'
                                    p_ntg       nt_message.ntm_ntg%TYPE := NULL, --NULL
                                    p_contact   nt_message.ntm_contact%TYPE := NULL, -- NULL
                                    p_title     nt_message.ntm_title%TYPE := NULL, -- 'Індивідуальне текстове повідомлення'
                                    p_text      nt_message.ntm_text%TYPE := NULL, -- то что ввел ...
                                    p_nte       nt_ext_file.nte_id%TYPE := NULL, --нул
                                    p_file_name nt_message_content.ntmc_file_name%TYPE,
                                    p_mime_type nt_message_content.ntmc_mime_type%TYPE,
                                    p_file_size nt_message_content.ntmc_file_size%TYPE,
                                    p_content   nt_message_content.content%TYPE,
                                    p_id        out nt_message.ntm_id%TYPE, -- если ошибка то нул
                                    p_error     out nt_message.ntm_contact%TYPE);
    */
    PROCEDURE Sendmultiplebytt;

    --Формування завдань на відсилку з автоматичним підтвердженням
    PROCEDURE Makesendtaskbyparams (
        p_Nip_Id     Nt_Send_Task.Ntst_Nip%TYPE,
        p_Start_Dt   DATE,
        p_Stop_Dt    DATE,
        p_Ntg_Id     Nt_Message.Ntm_Ntg%TYPE,
        p_Info_Tp    Nt_Send_Task.Ntst_Info_Tp%TYPE,
        p_Source     Nt_Message.Ntm_Source%TYPE:= NULL,
        p_Tp         Nt_Message.Ntm_Tp%TYPE:= NULL,
        p_Nte        Nt_Ext_File.Nte_Id%TYPE:= NULL,
        p_Ntm        Nt_Message.Ntm_Id%TYPE:= NULL);

    FUNCTION Getsccontact (p_Sc_Id     Nt_Message.Ntm_Sc%TYPE,
                           p_Info_Tp   Nt_Send_Task.Ntst_Info_Tp%TYPE)
        RETURN VARCHAR2;

    PROCEDURE Initsendtasks;
END Api$nt_Api;
/


GRANT EXECUTE ON USS_PERSON.API$NT_API TO II01RC_USS_PERSON_INT
/

GRANT EXECUTE ON USS_PERSON.API$NT_API TO II01RC_USS_PERSON_RBM
/

GRANT EXECUTE ON USS_PERSON.API$NT_API TO IKIS_RBM
/

GRANT EXECUTE ON USS_PERSON.API$NT_API TO USS_ESR
/

GRANT EXECUTE ON USS_PERSON.API$NT_API TO USS_RNSP
/

GRANT EXECUTE ON USS_PERSON.API$NT_API TO USS_RPT
/

GRANT EXECUTE ON USS_PERSON.API$NT_API TO USS_VISIT
/


/* Formatted on 8/12/2025 5:56:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.API$NT_API
IS
    PROCEDURE SendRnspMail (p_Rnspm_Id   IN NUMBER,
                            p_Source        Nt_Message.Ntm_Source%TYPE,
                            p_Title         Nt_Message.Ntm_Title%TYPE,
                            p_Text          Nt_Message.Ntm_Text%TYPE)
    IS
        l_Email    VARCHAR2 (100);
        l_ntm_id   NUMBER;
    BEGIN
        l_Email := Uss_Rnsp.Api$find.Get_Nsp_Email (p_Rnspm_Id);

        IF l_Email IS NULL
        THEN
            RETURN;
        END IF;

        --Регистрируем сообщение
        INSERT INTO Nt_Message (Ntm_Sc,
                                Ntm_Numident,
                                Ntm_Register_Dt,
                                Ntm_Source,
                                Ntm_Tp,
                                Ntm_St,
                                Ntm_Title,
                                Ntm_Text,
                                Ntm_Ntg,
                                Ntm_Nte,
                                Ntm_Contact)
             VALUES (NULL,
                     NULL,
                     SYSDATE,
                     p_Source,
                     'PRI',
                     'R',
                     p_Title,
                     p_Text,
                     NULL,
                     NULL,
                     l_Email)
          RETURNING Ntm_Id
               INTO l_Ntm_Id;

        --Формируем задание на отправку сообщения
        Makesendtaskbyparams (p_Nip_Id     => 1,               --ИД провайдера
                              p_Start_Dt   => TRUNC (SYSDATE),
                              p_Stop_Dt    => TRUNC (SYSDATE) + 1,
                              p_Ntg_Id     => NULL,
                              p_Info_Tp    => 'EMAIL',
                              p_Source     => p_Source,
                              p_Tp         => 'PRI',
                              p_Nte        => NULL,
                              p_Ntm        => l_Ntm_Id);
    END;

    PROCEDURE SendCmesMessage (p_cu2r_id   NUMBER,
                               p_source    nt_message.ntm_source%TYPE,
                               p_title     nt_message.ntm_title%TYPE,
                               p_text      nt_message.ntm_text%TYPE)
    IS
        l_email    VARCHAR2 (100);
        l_ntm_id   NUMBER;
    BEGIN
        SELECT r.Cu2r_Email
          INTO l_Email
          FROM Ikis_Rbm.v_Cu_Users2roles r
         WHERE r.Cu2r_Id = p_Cu2r_Id;

        IF l_Email IS NULL
        THEN
            RETURN;
        END IF;

        --Регистрируем сообщение
        INSERT INTO Nt_Message (Ntm_Sc,
                                Ntm_Numident,
                                Ntm_Register_Dt,
                                Ntm_Source,
                                Ntm_Tp,
                                Ntm_St,
                                Ntm_Title,
                                Ntm_Text,
                                Ntm_Ntg,
                                Ntm_Nte,
                                Ntm_Contact)
             VALUES (NULL,
                     NULL,
                     SYSDATE,
                     p_Source,
                     'PRI',
                     'R',
                     p_Title,
                     p_Text,
                     NULL,
                     NULL,
                     l_Email)
          RETURNING Ntm_Id
               INTO l_Ntm_Id;

        --Формируем задание на отправку сообщения
        Makesendtaskbyparams (p_Nip_Id     => 1,               --ИД провайдера
                              p_Start_Dt   => TRUNC (SYSDATE),
                              p_Stop_Dt    => TRUNC (SYSDATE) + 1,
                              p_Ntg_Id     => NULL,
                              p_Info_Tp    => 'EMAIL',
                              p_Source     => p_Source,
                              p_Tp         => 'PRI',
                              p_Nte        => NULL,
                              p_Ntm        => l_Ntm_Id);
    END;

    PROCEDURE SendCmesReqMessage (p_Crr_Id   NUMBER,
                                  p_Source   Nt_Message.Ntm_Source%TYPE,
                                  p_Title    Nt_Message.Ntm_Title%TYPE,
                                  p_Text     Nt_Message.Ntm_Text%TYPE)
    IS
        l_Email    VARCHAR2 (100);
        l_Ntm_Id   NUMBER;
    BEGIN
        SELECT r.Crr_Email
          INTO l_Email
          FROM Ikis_Rbm.v_Cu_Role_Request r
         WHERE r.Crr_Id = p_Crr_Id;

        IF l_Email IS NULL
        THEN
            RETURN;
        END IF;

        --Регистрируем сообщение
        INSERT INTO Nt_Message (Ntm_Sc,
                                Ntm_Numident,
                                Ntm_Register_Dt,
                                Ntm_Source,
                                Ntm_Tp,
                                Ntm_St,
                                Ntm_Title,
                                Ntm_Text,
                                Ntm_Ntg,
                                Ntm_Nte,
                                Ntm_Contact)
             VALUES (NULL,
                     NULL,
                     SYSDATE,
                     p_Source,
                     'PRI',
                     'R',
                     p_Title,
                     p_Text,
                     NULL,
                     NULL,
                     l_Email)
          RETURNING Ntm_Id
               INTO l_Ntm_Id;

        --Формируем задание на отправку сообщения
        Makesendtaskbyparams (p_Nip_Id     => 1,               --ИД провайдера
                              p_Start_Dt   => TRUNC (SYSDATE),
                              p_Stop_Dt    => TRUNC (SYSDATE) + 1,
                              p_Ntg_Id     => NULL,
                              p_Info_Tp    => 'EMAIL',
                              p_Source     => p_Source,
                              p_Tp         => 'PRI',
                              p_Nte        => NULL,
                              p_Ntm        => l_Ntm_Id);
    END;

    PROCEDURE SendRcMessage (p_email    Nt_Message.Ntm_Contact%TYPE,
                             p_source   nt_message.ntm_source%TYPE,
                             p_title    nt_message.ntm_title%TYPE,
                             p_text     nt_message.ntm_text%TYPE)
    IS
        l_ntm_id   NUMBER;
    BEGIN
        IF p_email IS NULL
        THEN
            RETURN;
        END IF;

        --Регистрируем сообщение
        INSERT INTO Nt_Message (Ntm_Sc,
                                Ntm_Numident,
                                Ntm_Register_Dt,
                                Ntm_Source,
                                Ntm_Tp,
                                Ntm_St,
                                Ntm_Title,
                                Ntm_Text,
                                Ntm_Ntg,
                                Ntm_Nte,
                                Ntm_Contact)
             VALUES (NULL,
                     NULL,
                     SYSDATE,
                     p_Source,
                     'PRI',
                     'R',
                     p_Title,
                     p_Text,
                     NULL,
                     NULL,
                     p_email)
          RETURNING Ntm_Id
               INTO l_Ntm_Id;

        --Формируем задание на отправку сообщения
        Makesendtaskbyparams (p_Nip_Id     => 1,               --ИД провайдера
                              p_Start_Dt   => TRUNC (SYSDATE),
                              p_Stop_Dt    => TRUNC (SYSDATE) + 1,
                              p_Ntg_Id     => NULL,
                              p_Info_Tp    => 'EMAIL',
                              p_Source     => p_Source,
                              p_Tp         => 'PRI',
                              p_Nte        => NULL,
                              p_Ntm        => l_Ntm_Id);
    END;

    PROCEDURE SendMonitoringMessage (
        p_rec_id       uss_ndi.v_ndi_ms_recipient.rec_id%TYPE,
        p_source       nt_message.ntm_source%TYPE,
        p_title        nt_message.ntm_title%TYPE,
        p_text         nt_message.ntm_text%TYPE,
        p_ntm_id   OUT nt_message.ntm_id%TYPE)
    IS
    BEGIN
        FOR Rec IN (SELECT r.Rec_Email
                      FROM Uss_Ndi.v_Ndi_Ms_Recipient r
                     WHERE r.Rec_Id = p_Rec_Id AND r.Rec_Email IS NOT NULL)
        LOOP
            --Регистрируем сообщение
            INSERT INTO Nt_Message (Ntm_Sc,
                                    Ntm_Numident,
                                    Ntm_Register_Dt,
                                    Ntm_Source,
                                    Ntm_Tp,
                                    Ntm_St,
                                    Ntm_Title,
                                    Ntm_Text,
                                    Ntm_Ntg,
                                    Ntm_Nte,
                                    Ntm_Contact)
                 VALUES (NULL,
                         NULL,
                         SYSDATE,
                         p_Source,
                         'PRI',
                         'R',
                         p_Title,
                         p_Text,
                         NULL,
                         NULL,
                         rec.rec_email)
              RETURNING Ntm_Id
                   INTO p_Ntm_Id;
        END LOOP;

        IF p_Ntm_Id IS NULL
        THEN
            Raise_Application_Error (-20000, 'Не знайдено отримувача');
        END IF;

        --Формируем задание на отправку сообщения
        Makesendtaskbyparams (p_Nip_Id     => 1,               --ИД провайдера
                              p_Start_Dt   => TRUNC (SYSDATE),
                              p_Stop_Dt    => TRUNC (SYSDATE) + 1,
                              p_Ntg_Id     => NULL,
                              p_Info_Tp    => 'EMAIL',
                              p_Source     => p_Source,
                              p_Tp         => 'PRI',
                              p_Nte        => NULL,
                              p_Ntm        => p_Ntm_Id);
    END;

    --Надсилання повідомлення за параметрами
    PROCEDURE SendOneByNumident (
        p_numident       nt_message.ntm_numident%TYPE,
        p_sc             nt_message.ntm_sc%TYPE := NULL,
        p_source         nt_message.ntm_source%TYPE := NULL,
        p_type           nt_message.ntm_tp%TYPE := NULL,
        p_ntg            nt_message.ntm_ntg%TYPE := NULL,
        p_contact        nt_message.ntm_contact%TYPE := NULL,
        p_title          nt_message.ntm_title%TYPE := NULL,
        p_text           nt_message.ntm_text%TYPE := NULL,
        p_nte            nt_ext_file.nte_id%TYPE := NULL,
        p_id         OUT nt_message.ntm_id%TYPE,
        p_error      OUT nt_message.ntm_contact%TYPE)
    IS
        l_contacts_cnt   INTEGER := 0;
        l_cnt            INTEGER := 0;
        l_error          nt_message.ntm_contact%TYPE := NULL;
        l_sc             uss_person.v_socialcard.sc_id%TYPE;
    BEGIN
        -- якщо явно вказано контакт, повідомлення відразу
        IF p_contact IS NOT NULL AND NVL (p_sc, -1) > 0
        THEN
            l_contacts_cnt := 1;
            l_cnt := 1;
            l_sc := p_sc;
        --Якщо не вказано контакту - пробуємо знайти контакт в РЗО по IP
        ELSIF p_sc IS NOT NULL
        THEN
            l_sc := p_sc;

            --Шукаємо контакт в контактах ЗО з ознакою дозволю використовувати для інформування
            SELECT SUM (
                       CASE
                           WHEN sct_id = -1
                           THEN
                               0
                           WHEN    (    sct_phone_mob IS NOT NULL
                                    AND sct_is_mob_inform = 'T')
                                OR (    sct_email IS NOT NULL
                                    AND sct_is_email_inform = 'T')
                           THEN
                               1
                           ELSE
                               0
                       END)     contacts_cnt,
                   COUNT (1)    cnt
              INTO l_contacts_cnt, l_cnt
              FROM uss_person.v_socialcard,
                   uss_person.v_sc_change,
                   uss_person.v_sc_contact  cd
             WHERE     sc_id = l_sc
                   AND scc_sc = sc_id
                   AND sc_scc = scc_id
                   AND scc_sct = sct_id;
        ELSIF p_numident IS NOT NULL
        THEN
            --Шукаємо контакт в контактах ЗО з ознакою дозволю використовувати для інформування, а саме ЗО шукаємо по документах ЗО
            SELECT SUM (
                       CASE
                           WHEN sct_id = -1
                           THEN
                               0
                           WHEN    (    sct_phone_mob IS NOT NULL
                                    AND sct_is_mob_inform = 'T')
                                OR (    sct_email IS NOT NULL
                                    AND sct_is_email_inform = 'T')
                           THEN
                               1
                           ELSE
                               0
                       END)       contacts_cnt,
                   COUNT (1)      cnt,
                   MAX (sc_id)    sc
              INTO l_contacts_cnt, l_cnt, l_sc
              FROM uss_person.v_sc_info,
                   uss_person.v_socialcard,
                   uss_person.v_sc_change,
                   uss_person.v_sc_contact
             WHERE     scc_sct = sct_id
                   AND sco_id = sc_id
                   AND scc_sc = sc_id
                   AND sc_scc = scc_id
                   AND sco_numident = p_numident;
        END IF;

        IF l_cnt = 0
        THEN
            l_error :=
                'Не знайдено особи за вказаним індентифікатором РНОКПП!';
        ELSIF l_contacts_cnt = 0
        THEN
            l_error :=
                'Не знайдено дозволів на інформування за вказаним індентифікатором особи!';
        END IF;

        IF l_contacts_cnt > 0
        THEN
            --raise_application_error(-20000, l_contacts_cnt);

            INSERT INTO nt_message (ntm_sc,
                                    ntm_numident,
                                    ntm_register_dt,
                                    ntm_source,
                                    ntm_tp,
                                    ntm_st,
                                    ntm_title,
                                    ntm_text,
                                    ntm_ntg,
                                    ntm_nte,
                                    ntm_contact)
                 VALUES (l_sc,
                         p_numident,
                         SYSDATE,
                         p_source,
                         p_type,
                         'R',
                         p_title,
                         p_text,
                         p_ntg,
                         p_nte,
                         TRIM ('+' FROM p_contact))
              RETURNING ntm_id
                   INTO p_id;
        ELSE
            p_id := NULL;
        END IF;

        p_error := l_error;
    END;

    /*
    PROCEDURE SendStrongByNumident(p_numident nt_message.ntm_numident%TYPE,
                                   p_ip nt_message.ntm_ip%TYPE := NULL,
                                   p_source nt_message.ntm_source%TYPE := NULL,
                                   p_type nt_message.ntm_tp%TYPE := NULL,
                                   p_ntg nt_template_group.ntg_id%TYPE := NULL,
                                   p_contact nt_message.ntm_contact%TYPE := NULL,
                                   p_title nt_message.ntm_title%TYPE := NULL,
                                   p_text nt_message.ntm_text%TYPE := NULL,
                                   p_nte nt_ext_file.nte_id%TYPE := NULL,
                                   p_file_name nt_message_content.ntmc_file_name%type,
                                   p_mime_type nt_message_content.ntmc_mime_type%type,
                                   p_file_size nt_message_content.ntmc_file_size%type,
                                   p_content nt_message_content.content%type,
                                   p_id OUT nt_message.ntm_id%TYPE,
                                   p_error OUT nt_message.ntm_contact%TYPE)
    is
      l_id nt_message.ntm_id%type;
      l_error nt_message.ntm_contact%TYPE;
    begin

        SendOneByNumident(p_numident => p_numident,
                        p_ip       => p_ip,
                        p_source   => p_source,
                        p_type     => p_type,
                        p_ntg      => p_ntg,
                        p_contact  => p_contact,
                        p_title    => p_title,
                        p_text     => p_text,
                        p_nte      => p_nte,
                        p_id       => l_id,
                        p_error    => l_error);

      p_id:= l_id;
      p_error:= l_error;

      if p_id is not null and p_content is not null then
        insert into nt_message_content(ntmc_id, ntmc_ntm, ntmc_file_name, ntmc_mime_type, ntmc_file_size, content)
        values (l_id, l_id, p_file_name, p_mime_type, p_file_size, p_content);
      end if;

    exception when others then
      p_error := p_error || chr(10) || dbms_utility.format_error_stack || dbms_utility.format_error_backtrace;
    end;*/

    --Надсилання повідомленнь з таблиці tmp_src_nt_message
    PROCEDURE SendMultipleByTT
    IS
        l_id      nt_message.ntm_id%TYPE;
        l_error   nt_message.ntm_contact%TYPE := NULL;
    BEGIN
        FOR xx IN (SELECT m_sc,
                          m_numident,
                          m_source,
                          m_type,
                          m_title,
                          m_text,
                          m_ntt,
                          m_contact,
                          x.ROWID     AS m_rowid,
                          m_nte_id,
                          m_ntg
                     FROM tmp_src_nt_message x)
        LOOP
            SendOneByNumident (xx.m_numident,
                               xx.m_sc,
                               xx.m_source,
                               xx.m_type,
                               xx.m_ntg,
                               TRIM ('+' FROM xx.m_contact),
                               xx.m_title,
                               xx.m_text,
                               xx.m_nte_id,
                               l_id,
                               l_error);

            UPDATE tmp_src_nt_message
               SET m_ntm_id = l_id, m_error = l_error
             WHERE ROWID = xx.m_rowid;
        END LOOP;
    END;

    FUNCTION GetSCContact (p_sc_id     nt_message.ntm_sc%TYPE,
                           p_info_tp   nt_send_task.ntst_info_tp%TYPE)
        RETURN VARCHAR2
    IS
        l_res   nt_msg2task.ntmt_contact%TYPE;
    BEGIN
        SELECT CASE
                   WHEN p_info_tp = 'SMS' THEN TRIM ('+' FROM sct_phone_mob)
                   WHEN p_info_tp = 'EMAIL' THEN sct_email
                   WHEN p_info_tp = 'AGENT' THEN ''
               END
          INTO l_res
          FROM uss_person.v_socialcard,
               uss_person.v_sc_change,
               uss_person.v_sc_contact
         WHERE     sc_id = p_sc_id
               AND scc_sc = sc_id
               AND sc_scc = scc_id
               AND scc_sct = sct_id;

        RETURN l_res;
    END;

    --Формування завдань на відсилку з автоматичним підтвердженням
    PROCEDURE MakeSendTaskByParams (
        p_nip_id     nt_send_task.ntst_nip%TYPE,
        p_start_dt   DATE,
        p_stop_dt    DATE,
        p_ntg_id     nt_message.ntm_ntg%TYPE,
        p_info_tp    nt_send_task.ntst_info_tp%TYPE,
        p_source     nt_message.ntm_source%TYPE:= NULL,
        p_tp         nt_message.ntm_tp%TYPE:= NULL,
        p_nte        nt_ext_file.nte_id%TYPE:= NULL,
        p_ntm        nt_message.ntm_id%TYPE:= NULL)
    IS
        l_ntst          nt_send_task.ntst_id%TYPE;
        l_ntm_contact   nt_message.ntm_contact%TYPE;
    BEGIN
        --Створюємо завдання.
        INSERT INTO nt_send_task (ntst_id,
                                  ntst_register_dt,
                                  ntst_st,
                                  ntst_nip,
                                  ntst_info_tp)
             VALUES (0,
                     SYSDATE,
                     'R',
                     p_nip_id,
                     p_info_tp)
          RETURNING ntst_id
               INTO l_ntst;

        IF p_ntm IS NOT NULL
        THEN
            --20190508 Sbond "кривые" номера создают бесконечные попытки обработать. Добавляю проверку формата если SMS
            IF p_info_tp = 'SMS'
            THEN
                SELECT COALESCE (TRIM ('+' FROM ntm.ntm_contact),
                                 GetScContact (ntm.ntm_sc, p_info_tp))
                  INTO l_ntm_contact
                  FROM nt_message ntm
                 WHERE ntm.ntm_id = p_ntm;

                IF    l_ntm_contact IS NULL
                   OR LENGTH (l_ntm_contact) != 12
                   OR NOT (REGEXP_LIKE (l_ntm_contact, '\d{12,}'))
                   OR NOT (REGEXP_LIKE (l_ntm_contact, '^[3][8][0]'))
                THEN
                    raise_application_error (
                        -20000,
                        'Телефон вказано невірно - правильний формат 380NNNNNNNNN');
                END IF;
            END IF;

            -- при регистрации на портале на информирование сразу известно ид сообщения, контакт записан в nt_message
            INSERT INTO nt_msg2task (ntmt_ntst,
                                     ntmt_ntm,
                                     ntmt_st,
                                     ntmt_contact)
                SELECT l_ntst,
                       ntm.ntm_id,
                       'R',
                       COALESCE (TRIM ('+' FROM ntm.ntm_contact),
                                 GetScContact (ntm.ntm_sc, p_info_tp))
                  FROM nt_message ntm
                 WHERE ntm.ntm_id = p_ntm;
        ELSE
            -- первоначальная реализация определение задач в группу для типа информирования
            INSERT INTO nt_msg2task (ntmt_ntst,
                                     ntmt_ntm,
                                     ntmt_st,
                                     ntmt_contact)
                SELECT l_ntst,
                       ntm_id,
                       'R',
                       GetScContact (ntm_sc, p_info_tp)
                  FROM nt_message
                 WHERE     ntm_st = 'R'
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
                                           AND ntt_info_tp = p_info_tp))
                       AND ntm_sc IS NOT NULL
                       AND (ntm_ntg = p_ntg_id OR p_ntg_id IS NULL)
                       AND (   p_start_dt IS NULL
                            OR (    ntm_register_dt >= p_start_dt
                                AND ntm_register_dt <= p_stop_dt))
                       AND (   ntm_source = p_source
                            OR (p_source IS NULL AND ntm_source IS NULL))
                       AND (   ntm_tp = p_tp
                            OR (p_tp IS NULL AND ntm_tp IS NULL))
                       AND (   ntm_nte = p_nte
                            OR (p_nte IS NULL AND ntm_nte IS NULL))
                       AND NOT EXISTS
                               (SELECT 1
                                  FROM nt_send_task, nt_msg2task
                                 WHERE     ntst_id = ntmt_ntst
                                       AND ntst_info_tp = p_info_tp
                                       AND ntmt_ntm = ntm_id);
        END IF;

        UPDATE nt_send_task
           SET ntst_cnt =
                   (SELECT COUNT (1)
                      FROM nt_msg2task
                     WHERE ntmt_ntst = ntst_id)
         WHERE ntst_id = l_ntst;

        API$NT_PROCESS.SetNTSTConfirmed (p_id => l_ntst);
    END;

    PROCEDURE InitSendTasks
    IS
    BEGIN
        RETURN;

        --Групуємо задачі за годиною реєстрації, джерелом та типом повідомлення
        FOR xx
            IN (  SELECT TRUNC (ntm_register_dt, 'HH24')     AS x_hour,
                         ntm_source                          AS x_source,
                         ntm_tp                              AS x_type
                    FROM nt_message
                   WHERE     ntm_st = 'R'
                         AND NOT EXISTS
                                 (SELECT 1
                                    FROM nt_msg2task
                                   WHERE ntmt_ntm = ntm_id)
                GROUP BY TRUNC (ntm_register_dt, 'HH24'), ntm_source, ntm_tp)
        LOOP
            NULL; --MakeSendTaskByParams(1, xx.x_hour, xx.x_source, xx.x_type);
        END LOOP;

        COMMIT;
    END;
BEGIN
    -- Initialization
    NULL;
END API$NT_API;
/