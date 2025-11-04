/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$ESR_BANKIR
IS
    -- Author  : oivashchuk
    -- Created : 02.11.2021 16:08:49
    -- Purpose : відомості для кібінета банкіра

    PROCEDURE GetBankDics (                --p_prc_codes    out sys_refcursor,
                           p_pr_types        OUT SYS_REFCURSOR,
                           p_pkt_statuses    OUT SYS_REFCURSOR,
                           --p_rr_statuses  out sys_refcursor,
                           --p_st_pr_srv out sys_refcursor,
                           p_st_pr_src       OUT SYS_REFCURSOR,
                           p_pkt_types       OUT SYS_REFCURSOR,
                           p_payment_codes   OUT SYS_REFCURSOR      -- #108215
                                                              );

    -- info: 2.  пошук відомості
    -- params: p_Cert_Serial – Серійний номер сертифікату
    --         p_Cert_Issuer_Cn – АЦСК сертифікату
    --         p_pr_st - статус відомості
    --         p_pr_pay_dt_start - дата виплати з
    --         p_pr_pay_dt_stop  - по
    ------   #67167
    --         p_pr_tp     - тип ВВ  - довідник  uss_esr.st_pr_tp
    --         p_org_id    -- ід ОПФУ
    --         p_npc_id    -- ід Типу допомоги  -- #108215
    -- note: 2. Поиск ведомостей по параметрам:  - статус ведомости;  - дата выплаты (З-ПО);
    --         p_Organizations_Id – Організація (для кабінету банкіра = 3)
    PROCEDURE GetPayrollList (p_cert_serial       IN     VARCHAR2,
                              p_cert_issuer_cn    IN     VARCHAR2,
                              p_pr_st             IN     VARCHAR2,
                              p_pr_pay_dt_start   IN     DATE,
                              p_pr_pay_dt_stop    IN     DATE,
                              p_pr_tp             IN     VARCHAR2,
                              p_org_id            IN     NUMBER,
                              p_pkt_id            IN     NUMBER DEFAULT NULL,
                              p_npc_id            IN     NUMBER DEFAULT NULL, -- #108215
                              p_result               OUT SYS_REFCURSOR);

    -- info: 3. відображення атрибутів відомості
    -- params: p_payroll_id - идентификатор ведомости;
    -- note:   3. Отображение информации по ведомости с атрибутами ведомости
    PROCEDURE GetPayrollInfo (p_cert_serial      IN     VARCHAR2,
                              p_cert_issuer_cn   IN     VARCHAR2,
                              p_payroll_id       IN     NUMBER,
                              p_result              OUT SYS_REFCURSOR,
                              p_kv1_list            OUT SYS_REFCURSOR,
                              p_kv2_list            OUT SYS_REFCURSOR);

    -- info: 4. Вивантаження пакетів ПЕОД даної відомості (лише пакети зашифровані на список одержувачів(сертифікати))
    -- params: p_payroll_id - идентификатор ведомости;
    -- note: 4. Выкачка архива по ведомости (по идентификатору ведомости);
    --  лише за наявності такого пакета
    --  на 20201207 - це лише пакети ВВ зі способом передачі E-mail
    PROCEDURE GetPayrollPackets (p_cert_serial      IN     VARCHAR2,
                                 p_cert_issuer_cn   IN     VARCHAR2,
                                 p_payroll_id       IN     NUMBER,
                                 p_result              OUT BLOB);

    -- info: 5. відображення реєстру відомості по днях
    -- params: p_payroll_id - идентификатор ведомости;
    -- note:   5. Отображение реестра ведомости по дням (по идентификатору ведомости) с данными:
    -- дата;
    -- кол-во людей за день;
    -- общая сумма за день
    --// ПОЗЖЕ еще добавим статус получения банком платежа от ПФУ за этот день – сейчас НЕ НАВОРАЧИВАЕМ этим
    PROCEDURE GetPayrollReestr (p_cert_serial      IN     VARCHAR2,
                                p_cert_issuer_cn   IN     VARCHAR2,
                                p_payroll_id       IN     NUMBER,
                                p_result              OUT SYS_REFCURSOR,
                                p_cor_list            OUT SYS_REFCURSOR);

    -- info: 6. підтвердження Банком факту одержання відомості - зміна статусу з Передано в банк в Отримано в банку.
    -- params: p_payroll_id - идентификатор ведомости;
    --         p_result - повідомлення???
    -- note:  6. подтверждение Банком получения ведомости (по идентификатору ведомости):
    -- дата отримання ведомости = поточная дата;
    -- перевод статуса из Передано в банк в Отримано в банку.
    PROCEDURE SetPayrollReceived (p_cert_serial      IN     VARCHAR2,
                                  p_cert_issuer_cn   IN     VARCHAR2,
                                  p_payroll_id       IN     NUMBER,
                                  p_result              OUT VARCHAR2);



    -- info: Вивантаження пакета ПЕОД  по ід (лише пакети зашифровані на список одержувачів(сертифікати))
    -- params: p_rbm_pkt_id - ід пакета ПЕОД
    -- note:
    --  на 20201207 - це лише пакети ВВ зі способом передачі E-mail
    PROCEDURE GetPayrollPacket (p_cert_serial      IN     VARCHAR2,
                                p_cert_issuer_cn   IN     VARCHAR2,
                                p_rbm_pkt_id       IN     NUMBER,
                                p_pkt_name            OUT VARCHAR,
                                p_pkt_data            OUT BLOB);

    -- info: Зміна статусів в реєстрі зі сторони ПЕОД (для пакетів відомостей, які  передаються через InfoCross)
    -- params: p_pkt_id - ід пакета ПЕОД;
    --         p_pkt_st - стату пакета ПЕОД
    -- note:  st_pr_st
    -- T  Передано в пеод
    -- R  Отримано банком
    -- P  Платіж проведено
    -- C  Платіж відхилено

    PROCEDURE SetPayrollStRbm (p_pkt_id IN NUMBER, p_pkt_st IN VARCHAR2);

    -- info:  Формування пакетів КВ-1 та КВ-2 (PCA, PPR) в ПЕОД
    -- params: p_rbm_pkt_id – ід пакета ВВ в ПЕОД
    --         p_pkt_tp     - тип пакета, що формується
    --         p_filia_name - Назва філії
    --         p_pkt_info   - опис пакета для візуалізації в ПЕОД
    --         p_pkt_blob   - шифрований файл пакета
    -- note:
    PROCEDURE GenKVPackets (p_cert_serial      IN     VARCHAR2,
                            p_cert_issuer_cn   IN     VARCHAR2,
                            p_payroll_id       IN     NUMBER,
                            p_pkt_tp           IN     VARCHAR2,
                            p_pkt_name         IN     VARCHAR2,
                            p_pkt_blob         IN     BLOB,
                            p_pkt_encr_blob    IN     BLOB,
                            p_message             OUT VARCHAR2);


    -- info: 1. Надання банку реєстру платіжних доручень за вказаний період
    -- params: p_Cert_Serial – Серійний номер сертифікату
    --         p_Cert_Issuer_Cn – АЦСК сертифікату
    --         p_po_pay_dt_start - Дата з - дата початку періоду дат ПД
    --         p_po_pay_dt_stop  - Дата по - кінцева дата періоду дат ПД
    -- МФО визначаємо по коду одержувача з довідника банків ППВП : select * from ikis_ppvp.nsi_psb b where b.psb_rbm_code = 'BANK11763';
    -- В перелік включаються платіжні доручення тільки в статусі "Платіж проведено" (Р) + існує посилання на документ в АБ (PO_UD_AB > 0)
    PROCEDURE GetPayOrderList (p_cert_serial         IN     VARCHAR2,
                               p_cert_issuer_cn      IN     VARCHAR2,
                               p_po_date_pay_start   IN     DATE,
                               p_po_date_pay_stop    IN     DATE,
                               p_po_pkt_st           IN     VARCHAR2,
                               p_po_prc_st           IN     VARCHAR2,
                               p_result                 OUT SYS_REFCURSOR);

    -- info: 2. Надання реєстру виплатних списків по платіжному дорученню
    -- params: p_Cert_Serial – Серійний номер сертифікату
    --         p_Cert_Issuer_Cn – АЦСК сертифікату
    --         p_po_pay_dt_start - Дата з - дата початку періоду дат ПД
    --         p_po_pay_dt_stop  - Дата по - кінцева дата періоду дат ПД
    -- МФО визначаємо по коду одержувача з довідника банків ППВП : select * from ikis_ppvp.nsi_psb b where b.psb_rbm_code = 'BANK11763';
    -- В перелік включаються платіжні доручення тільки в статусі "Платіж проведено" (Р) + існує посилання на документ в АБ (PO_UD_AB > 0)
    PROCEDURE GetPayOrderInfo (p_cert_serial      IN     VARCHAR2,
                               p_cert_issuer_cn   IN     VARCHAR2,
                               p_po_id            IN     NUMBER,
                               p_result              OUT SYS_REFCURSOR /*,
                         p_kv_list                    out sys_refcursor*/
                                                                      );

    -- info: 3. Одержання по ід ПД шифрованого файлу реєстру списків платіжного доручення з ПЕОД
    --  ід платіжного доручення (po_id)
    --  в ПЕОД змінюємо статус на "Одержано банком"
    PROCEDURE GetPayOrderPacket (p_cert_serial      IN     VARCHAR2,
                                 p_cert_issuer_cn   IN     VARCHAR2,
                                 p_po_id            IN     NUMBER,
                                 p_result              OUT BLOB);

    -- info: 4. Повідомлення банку про отримання реєстру списків платіжного доручення  -Відповідь банку:
    -- ід платіжного доручення (po_id)
    -- в ПЕОД генеруємо пакет-квитанцію про отримання.
    PROCEDURE SetPayOrderPacketKv (p_cert_serial      IN VARCHAR2,
                                   p_cert_issuer_cn   IN VARCHAR2,
                                   p_po_id            IN NUMBER,
                                   p_po_result        IN NUMBER);


    -- info: 10.  сервіс «Повідомлення банку про платіжне доручення повернення коштів з рахунків пенсіонерів» (post_pd_return)
    -- params: p_Cert_Serial – Серійний номер сертифікату
    --         p_Cert_Issuer_Cn – АЦСК сертифікату
    --         p_pkt_name   - Назва файлу
    --         p_pkt_blob   - файл пакета
    --         p_pkt_blob   - шифрований файл пакета
    --         p_message    - повідомлення про помилку завантаження/збереження. в разі успішного виконання - порожнє.
    -- note:
    PROCEDURE PostPDReturn (p_cert_serial      IN     VARCHAR2,
                            p_cert_issuer_cn   IN     VARCHAR2,
                            p_pkt_name         IN     VARCHAR2,
                            p_pkt_blob         IN     BLOB,
                            p_pkt_encr_blob    IN     BLOB,
                            p_message             OUT VARCHAR2);

    -- Надання банку реєстру платіжних доручень (повідомлення про платіжне доручення повернення коштів) за вказаний період
    -- params: p_Cert_Serial – Серійний номер сертифікату
    --         p_Cert_Issuer_Cn – АЦСК сертифікату
    --         p_rr_pd_date_start - Дата з - дата початку періоду дат ПД
    --         p_rr_pd_date_stop  - Дата по - кінцева дата періоду дат ПД
    --         p_rr_st  - стутус повідомлення про ПД повернення - довідник uss_esr.st_rr_st

    PROCEDURE GetPDReturnList (p_cert_serial        IN     VARCHAR2,
                               p_cert_issuer_cn     IN     VARCHAR2,
                               p_rr_pd_date_start   IN     DATE,
                               p_rr_pd_date_stop    IN     DATE,
                               p_rr_st              IN     VARCHAR2,
                               --p_po_prc_st                   in varchar2,
                               p_result                OUT SYS_REFCURSOR);


    -- перегляд деталей по завантаженому файлу:
    -- params: p_Cert_Serial – Серійний номер сертифікату
    --         p_Cert_Issuer_Cn – АЦСК сертифікату
    --         p_rr_id  - ід завантаженого реєстра повернення

    PROCEDURE GetPDReturnInfo (p_cert_serial      IN     VARCHAR2,
                               p_cert_issuer_cn   IN     VARCHAR2,
                               p_rr_id            IN     NUMBER,
                               p_result              OUT SYS_REFCURSOR);
END API$ESR_BANKIR;
/


GRANT EXECUTE ON USS_ESR.API$ESR_BANKIR TO II01RC_USS_ESR_PORTAL
/

GRANT EXECUTE ON USS_ESR.API$ESR_BANKIR TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:49:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$ESR_BANKIR
IS
    exNoBank   EXCEPTION;

    /*  Коди запитів ikis_cmes:
    •  BANK_PAYROLL_LISTS  Перелік відомостей на банк
    •  BANK_PAYROLL_PACKET_LISTS Перелік пакетів відомостей на банк
    •  BANK_PACKET_REQ_PEOD        Запит пакета відомостей по ідентифікатору в ПЕОД
    •  BANK_CHANGE_ST_RECEIVED  Зміна статусу відомості з «Передано на банк» на «Отримано в банку»
    */
    /*
    --1. Авторизация банкира;
    --   Для порталу (единий підхід який зараз працює):
    Автентифікація  ikis_cmes.Ikis_Cmes4portal.Authenticate Повертає Boolean.
    Параметри :
    •  p_Cert_Serial – Серійний номер сертифікату
    •  p_Cert_Issuer_Cn – АЦСК сертифікату
    •  p_Organizations_Id – Організація (для кабінету банкіра = 3 , для НАБУ = 2, для інспектора праці за замовчанням 1)
    Вихідні параметри:
    •  out p_User_Pib – ПІБ користувача
    •  out p_User_Numident – Податковий номер користувача
    Перелік кодів запитів доступних користувачу
    ikis_cmes.Ikis_Cmes4portal.Get_User_Req_Types
    Параметри :
    • p_Cert_Serial – Серійний номер сертифікату
    • p_Cert_Issuer_Cn – АЦСК сертифікату
    • p_Organizations_Id – Організація (для кабінету банкіра = 3, для НАБУ = 2, для інспектора праці за замовчанням 1)
    Вихідний параметр p_Recordset – курсор
    • Crt_Req_Tp – код запиту
    • Dic_Name – назва запиту
    */


    /*procedure InsertFZLog(
        p_pr_id          in number   default null,
        p_pr_st          in varchar2 default null,
        p_action         in varchar2 default null,
        p_user           in number   default null,
        p_info           in varchar2 default null
      )
      is
        pragma autonomous_transaction;
      begin
         -- dbms_output.put_line('p_info='||p_info);
        insert into pr_log(prl_id, prl_pr, prl_pr_st, prl_action, prl_user, prl_dt, prl_info)
        values (null, p_pr_id, p_pr_st, p_action, p_user, sysdate, p_info);
        commit;
      end;*/

    PROCEDURE GetBankDics (                --p_prc_codes    out sys_refcursor,
                           p_pr_types        OUT SYS_REFCURSOR,
                           p_pkt_statuses    OUT SYS_REFCURSOR,
                           --p_rr_statuses  out sys_refcursor,
                           --p_st_pr_srv out sys_refcursor,
                           p_st_pr_src       OUT SYS_REFCURSOR,
                           p_pkt_types       OUT SYS_REFCURSOR,
                           p_payment_codes   OUT SYS_REFCURSOR      -- #108215
                                                              )
    IS
    BEGIN
        /*  open p_prc_codes for
            select PPC_CODE as ID, PPC_FULL_NAME as name
              from ikis_finzvit.v_rv2pda_prc_codes
             order by 1;*/

        OPEN p_pr_types FOR   SELECT dic_value AS ID, dic_sname AS NAME
                                FROM usS_ndi.v_Ddn_Pe_Tp
                            ORDER BY dic_srtordr;

        OPEN p_pkt_statuses FOR   SELECT dic_value AS ID, dic_sname AS NAME
                                    FROM uss_ndi.v_ddn_packet_st4kb
                                   WHERE dic_value != 'ANS' --   MG : ANS - Отримано відповідь  (після завантаження КВ-1/2) ===НЕ НУЖЕН
                                ORDER BY dic_srtordr;

        /*  open p_rr_statuses for
            select SV_ID as ID, SV_NAME as NAME
              from ikis_finzvit.st_rr_st
             order by sv_ord;*/

        /*  open  p_st_pr_srv for
               select SV_ID as ID, SV_NAME as NAME
              from ikis_finzvit.v_st_pr_srv
             order by sv_ord;*/

        OPEN p_st_pr_src FOR   SELECT dic_value AS ID, dic_sname AS NAME
                                 FROM usS_ndi.v_Ddn_Pe_Src
                             ORDER BY dic_srtordr;

        /*
           p_po_pkt_st  - стутус реєстра списків по ПД в ПЕОД - довідник ikis_finzvit.st_po_pkt_st
                p_po_prc_st  - результат опрацювання файлу з реєстром списків по ПД - довідник ikis_finzvit.v_rv2pda_prc_codes

        */
        OPEN p_pkt_types FOR   SELECT t.pat_id AS ID, t.pat_sname AS NAME
                                 FROM uss_ndi.v_ndi_packet_type t
                                WHERE t.history_status = 'A'
                             ORDER BY 1;

        OPEN p_payment_codes FOR
              SELECT c.npc_id AS ID, c.npc_code || ' ' || c.npc_name AS NAME
                FROM uss_ndi.v_ndi_payment_codes c
               WHERE c.history_status = 'A'
            ORDER BY TO_NUMBER (npc_code);
    END;

    -- info:-- визначаємо КОД реципієнта ПЕОД = Банк.разом з Authenticate_Internal.
    -- params: p_Cert_Serial – Серійний номер сертифікату
    --         p_Cert_Issuer_Cn – АЦСК сертифікату
    -- note: #94282 заміна Get_User_Rec на Get_User_Rm + нові вихідні параметри p_rm_id,  p_com_org
    PROCEDURE GetRecCode (p_cert_serial      IN     VARCHAR2,
                          p_cert_issuer_cn   IN     VARCHAR2,
                          p_rec_id              OUT NUMBER,
                          p_rec_code            OUT VARCHAR2,
                          p_rm_id               OUT NUMBER,
                          p_com_org             OUT NUMBER)
    IS
    BEGIN
        --return p_cert_serial;
        -- визначаємо ід реципієнта ПЕОД = Банк. в тому числі і з Authenticate_Internal.
        p_rm_id :=
            ikis_rbm.RDM$RECIPIENT.Get_User_Rm (
                p_Cert_Serial      => p_cert_serial,
                p_Cert_Issuer_Cn   => p_cert_issuer_cn);

        BEGIN
            SELECT rm.rm_rec, rm.com_org
              INTO p_rec_id, p_com_org
              FROM ikis_rbm.v_recipient_mail rm
             WHERE rm.rm_id = p_rm_id AND rm.rm_st = 'A';
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                p_rec_id := NULL;
                p_rm_id := NULL;
        END;

        --- 4 test !!!!!
        --- p_rec_id := 26882;
        -- якщо банк не визначено - повідомлення про помилку.
        IF p_rec_id IS NULL
        THEN
            RAISE exNoBank;
        ELSE
            SELECT r.rec_code
              INTO p_rec_code
              FROM ikis_rbm.v_recipient r
             WHERE rec_id = p_rec_id;

            IF p_rec_code IS NULL
            THEN
                RAISE exNoBank;
            END IF;
        END IF;
    END;

    /*function GetRecCode(
      p_cert_serial                 in varchar2,
      p_cert_issuer_cn              in varchar2
    ) return varchar2
    is
      l_rec_id    number;
      l_rec_code  varchar2(100);
    begin
      --return p_cert_serial;
      -- визначаємо ід реципієнта ПЕОД = Банк. в тому числі і з Authenticate_Internal.
      l_rec_id :=  ikis_rbm.RDM$RECIPIENT.Get_User_Recipient(p_Cert_Serial      => p_cert_serial,
                                                             p_Cert_Issuer_Cn   => p_cert_issuer_cn,
                                                             p_Cmes_Id => 1);
       -- якщо банк не визначено - повідомлення про помилку.
      if l_rec_id is null then
        raise exNoBank;
      else
        select r.rec_code into l_rec_code
        from ikis_rbm.v_recipient r
        where rec_id = l_rec_id ;

        if l_rec_code is null then
          raise exNoBank;
        end if;
      end if;
      return l_rec_code;
    end;*/

    -- info: 2.  пошук відомості
    -- params: p_Cert_Serial – Серійний номер сертифікату
    --         p_Cert_Issuer_Cn – АЦСК сертифікату
    --         p_pr_st - статус відомості
    --         p_pr_pay_dt_start - дата виплати з
    --         p_pr_pay_dt_stop  - по
    ------   #67167
    --         p_pr_tp     - тип ВВ   uss_esr.st_pr_tp
    --         p_org_id    -- ід УСПЗН
    --         p_npc_id    -- ід Типу допомоги  -- #108215 Кабінет банку - в АПІ пошуку виплатних відомостей додати параметр "Тип допомоги, який виплоачується"
    -- note:   Поиск ведомостей по параметрам:  - статус ведомости;  - дата выплаты (З-ПО);
    --         p_Organizations_Id – Організація (для кабінету банкіра = 3)
    /*4.2. секция отображение ведомостей с полями (АПИ 3 от Сашка):
    - назва відомості; ЯК ПОСИЛАННЯ!!!
    - рік;
    - місяць;
    - загальна сума;
    - загальна кількість рядків;
    - статус;
    */
    /*На відміну від * , в ЄСР пакети формуються уже при фіксації платіжного доручення, зміна статусів пакетів ніяк не впливає на  ЖЦ(окрім розфіксації).
    Можлива ситуація, коли на момент появи та скачування пакета в КБ платіж по ПД уже давно проведений.
    Тобто статуси відомостей по аналогії з * не годяться.
    Поки єдине, що спадає на думку, це замінити статус відомості на пару:
    1. статус пакета (можна і надалі називати його статус відомості)
    2. статус платежу (або виводити дату проведення платежу, якщо це потрібно).*/
    -- io 20230208  на даний момент  pe_src_entity=ef_id свіввідноситься з pkt_id як 1 до 1
    --  тому у нас буде статус "відомості" == pkt_st
    --  відображаються лише пакети в статусах з NVP і вище
    PROCEDURE GetPayrollList (p_cert_serial       IN     VARCHAR2,
                              p_cert_issuer_cn    IN     VARCHAR2,
                              p_pr_st             IN     VARCHAR2,
                              p_pr_pay_dt_start   IN     DATE,
                              p_pr_pay_dt_stop    IN     DATE,
                              p_pr_tp             IN     VARCHAR2,
                              p_org_id            IN     NUMBER,
                              p_pkt_id            IN     NUMBER DEFAULT NULL,
                              p_npc_id            IN     NUMBER DEFAULT NULL, -- #108215
                              p_result               OUT SYS_REFCURSOR)
    IS
        l_rec_id     NUMBER;
        l_rec_code   VARCHAR2 (100);
        l_rm_id      NUMBER;
        l_com_org    NUMBER;
    BEGIN
        -- raise_application_error(-20000, p_cert_serial||' - '|| p_cert_issuer_cn||' - '|| l_rec_code);
        -- визначаємо код реципієнта ПЕОД = Банк. в тому числі і з Authenticate_Internal.
        /*  l_rec_code := GetRecCode(p_Cert_Serial      => p_cert_serial,
                                   p_Cert_Issuer_Cn   => p_cert_issuer_cn);*/
        GetRecCode (p_Cert_Serial      => p_cert_serial,
                    p_Cert_Issuer_Cn   => p_cert_issuer_cn,
                    p_rec_id           => l_rec_id,
                    p_rec_code         => l_rec_code,
                    p_rm_id            => l_rm_id,
                    p_com_org          => l_com_org);

        --raise_application_error(-20000, p_cert_serial||' - '|| p_cert_issuer_cn||' - '|| l_rec_code);;
        --raise_application_error(-20000, 'p_pr_tp = '|| p_pr_tp||', p_pr_st = '|| p_pr_st||', p_org_id = '|| p_org_id||', p_pr_pay_dt_start = '|| p_pr_pay_dt_start||', p_pr_pay_dt_stop = '|| p_pr_pay_dt_stop);
        --  raise_application_error(-20000, 'l_rec_id='|| l_rec_id||', l_rec_code='|| l_rec_code||', l_rm_id='|| l_rm_id||', l_com_org='|| l_com_org);
        --insert into tmp_81025_pkt(x_pkt_id,x_pkt_pkt,x_pr_id,x_pc_name)values(l_rec_id, l_rm_id, l_com_org, l_rec_code);
        -- якщо банк не визначено - повідомлення про помилку.
        IF l_rec_code IS NULL
        THEN
            RAISE exNoBank;
        ELSE
            -- Вводимо поняття статус відомості як мінімальний по ЖЦ статус списків даної відомості
            OPEN p_result FOR
                  SELECT pr.pe_src_entity                    AS pr_payroll_id, -- идентификатор ведомости;
                         pr.pe_name,                       -- назва відомості;
                         EXTRACT (YEAR FROM pe_pay_dt)       AS pay_year, -- рік
                         EXTRACT (MONTH FROM pe_pay_dt)      AS pay_month, -- місяць
                         b.nb_num                            AS pe_bnk_code,
                         b.nb_mfo                            AS pe_bnk_mfo,
                         b.nb_name                           AS pe_bnk_name,
                         SUM (pr.pe_row_cnt)                 AS pr_row_cnt, -- загальна кількість рядків у списках (автосумма по информации по дням);
                         SUM (pr.pe_sum)                     AS pr_sum, -- загальна сума, грн (автосумма по информации по дням);
                         pr.payroll_st                       AS pr_st,
                         pr_status,
                         tp.dic_sname                        AS pr_tp,
                         MAX (
                             (SELECT MIN (h.hs_dt)
                                FROM uss_esr.pe_log prl, histsession h
                               WHERE     prl.pel_pe = pr.pe_id
                                     AND prl.pel_pe_st = 'R'
                                     AND pel_hs = hs_id))    AS pr_receive_dt, -- дата отримання відомості в банку;
                         -- Ознака готовності файлів - перевіряємо чи всі пакети зашифровані (поле pc_encrypt_data - непорожнє)
                         -- і переведені в статус "На відправку" "відправлено", "Одержано"
                         CASE
                             WHEN EXISTS
                                      (SELECT COUNT (pc_pkt)    AS pkt_cnt,
                                              COUNT (
                                                  CASE
                                                      WHEN     pkt_st IN
                                                                   ('NVP',
                                                                    'SND',
                                                                    'RCV')
                                                           AND pc.pc_encrypt_data
                                                                   IS NOT NULL
                                                           AND DBMS_LOB.getlength (
                                                                   pc.pc_encrypt_data) >
                                                               10
                                                      THEN
                                                          pkt_id
                                                      ELSE
                                                          NULL
                                                  END)          AS pkt_encrypt_cnt
                                         FROM uss_esr.payroll_reestr pr2
                                              JOIN ikis_rbm.v_packet p
                                                  ON p.pkt_id = pr2.pe_rbm_pkt
                                              JOIN ikis_rbm.v_packet_content pc
                                                  ON pc.pc_pkt = pr2.pe_rbm_pkt
                                        WHERE     p.pkt_rec = l_rec_id -- pr2.pe_bnk_rbm_code = l_rec_code
                                              AND (   l_com_org = 50000
                                                   OR p.pkt_rm = l_rm_id)
                                              AND pr2.pe_src_entity =
                                                  pr.pe_src_entity
                                       HAVING     COUNT (pc_pkt) =
                                                  COUNT (
                                                      CASE
                                                          WHEN     pkt_st IN
                                                                       ('NVP',
                                                                        'SND',
                                                                        'RCV')
                                                               AND pc.pc_encrypt_data
                                                                       IS NOT NULL
                                                               AND DBMS_LOB.getlength (
                                                                       pc.pc_encrypt_data) >
                                                                   10
                                                          THEN
                                                              pkt_id
                                                          ELSE
                                                              NULL
                                                      END)
                                              AND COUNT (pc_pkt) > 0)
                             THEN
                                 1
                             ELSE
                                 0
                         END                                 AS file_is_ready,
                         MAX (
                             CASE
                                 WHEN o.org_to = 31 THEN o.org_id
                                 ELSE o.org_org
                             END)                            AS com_org, --pr.com_org, -- орган УСПЗН (область);
                         MAX (
                             (SELECT MAX (o2.org_name)
                                FROM v_opfu o2
                               WHERE org_id =
                                     CASE
                                         WHEN o.org_to = 31 THEN o.org_id
                                         ELSE o.org_org
                                     END))                   AS org_name,
                         pr.pe_rbm_pkt,                         -- ід конверта
                         c.npc_name                          AS pr_npc_name --  #107210 + назву послуги, яка виплачується
                    FROM (SELECT pkt_st          AS payroll_st,
                                 s.dic_sname     AS pr_status,
                                 r.*
                            FROM uss_esr.payroll_reestr r
                                 JOIN ikis_rbm.v_packet p
                                     ON pkt_id = r.pe_rbm_pkt
                                 JOIN uss_ndi.v_ddn_packet_st4kb s
                                     ON s.dic_value = p.pkt_st -- показуємо лише підписані
                           WHERE     1 = 1
                                 AND p.pkt_rec = l_rec_id
                                 AND (l_com_org = 50000 OR p.pkt_rm = l_rm_id)
                                 AND (p_pr_st IS NULL OR p.pkt_st = p_pr_st)
                                 AND (   p_pr_pay_dt_start IS NULL
                                      OR r.pe_pay_dt >= p_pr_pay_dt_start)
                                 AND (   p_pr_pay_dt_stop IS NULL
                                      OR r.pe_pay_dt < p_pr_pay_dt_stop + 1)
                                 AND (p_pr_tp IS NULL OR r.pe_tp = p_pr_tp)
                                 AND (   p_pkt_id IS NULL
                                      OR r.pe_rbm_pkt = p_pkt_id)
                                 AND (p_npc_id IS NULL OR r.pe_npc = p_npc_id) -- #108215
                                                                              /*  io 20230208 у нас не може бути різних пакетів на 1 pe_src_entity
                                                                                      and exists (
                                                                                            select 1 from payroll_reestr pr2
                                                                                            where pr2.pe_src_entity = r.pe_src_entity
                                                                                              and (p_pr_st is null or pr2.pe_st = p_pr_st)
                                                                                              and (p_pr_pay_dt_start is null or pr2.pe_pay_dt >= p_pr_pay_dt_start)
                                                                                              and (p_pr_pay_dt_stop is null or pr2.pe_pay_dt <  p_pr_pay_dt_stop + 1)
                                                                                              and (p_pr_tp is null or pr2.pe_tp = p_pr_tp)
                                                                                              and (p_pkt_id is null or pr2.pe_rbm_pkt = p_pkt_id  and p.pkt_id = p_pkt_id
                                                                                                  and exists ( -- показуємо лише підписані
                                                                                                          select 1 from ikis_rbm.v_packet p
                                                                                                          where p.pkt_id = pr2.pe_rbm_pkt
                                                                                                            and p.pkt_st in ('NVP','SND','RCV'))
                                                                                                    ) -- #68348
                                                                                              )  */
                                                                              )
                         pr
                         JOIN v_opfu o ON org_id = com_org
                         JOIN uss_ndi.v_ndi_bank b ON b.nb_id = pr.pe_nb
                         JOIN uss_ndi.v_ddn_pe_tp tp ON pe_tp = tp.DIC_VALUE
                         JOIN uss_ndi.v_ndi_payment_codes c
                             ON pr.pe_npc = c.npc_id
                   WHERE     1 = 1          -- pr.pe_bnk_rbm_code = l_rec_code
                         AND (p_pr_st IS NULL OR pr.payroll_st = p_pr_st)
                         AND (   p_org_id IS NULL
                              OR p_org_id = o.org_id
                              OR p_org_id =
                                 CASE
                                     WHEN o.org_to = 31 THEN o.org_id
                                     ELSE o.org_org
                                 END)
                GROUP BY pr.pe_src_entity,
                         pr_status,
                         b.nb_num,
                         b.nb_mfo,
                         b.nb_name,
                         pr.pe_name,
                         EXTRACT (YEAR FROM pe_pay_dt),
                         EXTRACT (MONTH FROM pe_pay_dt),
                         pr.payroll_st                               /*pr_st*/
                                      ,
                         pr.pe_tp,
                         tp.dic_sname,
                         pr.pe_rbm_pkt,
                         c.npc_name;
        END IF;
    EXCEPTION
        WHEN exNoBank
        THEN
            raise_application_error (-20000, 'Банк не визначено!');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка пошуку відомості: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- info: 3. відображення атрибутів відомості
    -- params: p_payroll_id - идентификатор ведомости;
    -- note:   3. Отображение информации по ведомости с атрибутами ведомости
    --Розгортання запису - відобраєення детальних атрибутів відомості:
    --- назва відомості - як посилання - НИЖЕ пропишу, что там должно отображаться...
    --- рік;
    --- місяць;
    --- загальна сума по відомості;
    --- загальна кількість рядків;
    --- тип відомості (основна; коригуюча; додаткова);
    --- орган УСПЗН;
    --- статус;
    --- дата отримання відомості в банку;
    --- документи – посилання для завантаження відомостей на виплату пенсії (АПИ4);
    PROCEDURE GetPayrollInfo (p_cert_serial      IN     VARCHAR2,
                              p_cert_issuer_cn   IN     VARCHAR2,
                              p_payroll_id       IN     NUMBER,
                              p_result              OUT SYS_REFCURSOR,
                              p_kv1_list            OUT SYS_REFCURSOR,
                              p_kv2_list            OUT SYS_REFCURSOR)
    IS
        l_rec_id     NUMBER;
        l_rec_code   VARCHAR2 (100);
        exNoBank     EXCEPTION;
        l_rm_id      NUMBER;
        l_com_org    NUMBER;
    BEGIN
        -- визначаємо код реципієнта ПЕОД = Банк. в тому числі і з Authenticate_Internal.
        /*  l_rec_code := GetRecCode(p_Cert_Serial      => p_cert_serial,
                                   p_Cert_Issuer_Cn   => p_cert_issuer_cn);*/
        GetRecCode (p_Cert_Serial      => p_cert_serial,
                    p_Cert_Issuer_Cn   => p_cert_issuer_cn,
                    p_rec_id           => l_rec_id,
                    p_rec_code         => l_rec_code,
                    p_rm_id            => l_rm_id,
                    p_com_org          => l_com_org);

        ---   raise_application_error(-20000, p_cert_serial||' - '|| p_cert_issuer_cn ||' - '|| p_payroll_id);
        --  l_rec_code := 'TESTBANK1';
        -- якщо банк не визначено - повідомлення про помилку.
        IF l_rec_code IS NULL
        THEN
            RAISE exNoBank;
        ELSE
            OPEN p_result FOR
                  SELECT pr.pe_src_entity                    AS pr_payroll_id, -- идентификатор ведомости;
                         pr.pe_name,                       -- назва відомості;
                         --pr.pe_bnk_code, /*pr.pr_filia_code,*/
                         --pr.pe_bnk_mfo, pr.pe_bnk_name,
                         b.nb_num                            AS pe_bnk_code,
                         b.nb_mfo                            AS pe_bnk_mfo,
                         b.nb_name                           AS pe_bnk_name,
                         EXTRACT (YEAR FROM pe_pay_dt)       AS pay_year, -- рік
                         EXTRACT (MONTH FROM pe_pay_dt)      AS pay_month, -- місяць
                         SUM (pr.pe_row_cnt)                 AS pr_row_cnt, -- загальна кількість рядків у списках (автосумма по информации по дням);
                         SUM (pr.pe_sum)                     AS pr_sum, -- загальна сума, грн (автосумма по информации по дням);
                         pkt_st                              AS pr_st,
                         /*decode(pr.pe_st, 'T', 'Передано в банк', 'R', 'Отримано банком',
                                          'P', 'Платіж проведено', 'C', 'Платіж відхилено')*/
                         s.dic_sname                         AS pr_status,
                         /*decode(pr.pe_tp, 1, 'Основна', 3, 'Коригуюча', 2, 'додаткова')*/
                         tp.dic_sname                        AS pr_tp, -- тип (основная, корегуюча; додаткова); тип відомості  0 – основна, 1 – коригуюча, 2 – додаткова
                         MAX (
                             (SELECT MIN (h.hs_dt)
                                FROM uss_esr.pe_log prl, histsession h
                               WHERE     prl.pel_pe = pr.pe_id
                                     AND prl.pel_pe_st = 'R'
                                     AND pel_hs = hs_id))    AS pr_receive_dt, -- дата отримання відомості в банку;
                         -- Ознака готовності файлів - перевіряємо чи всі пакети зашифровані (поле pc_encrypt_data - непорожнє)
                         -- і переведені в статус "На відправку" "відправлено", "Одержано"
                         CASE
                             WHEN EXISTS
                                      (SELECT COUNT (pc_pkt)    AS pkt_cnt,
                                              COUNT (
                                                  CASE
                                                      WHEN     pkt_st IN
                                                                   ('NVP',
                                                                    'SND',
                                                                    'RCV')
                                                           AND pc.pc_encrypt_data
                                                                   IS NOT NULL
                                                           AND DBMS_LOB.getlength (
                                                                   pc.pc_encrypt_data) >
                                                               10
                                                      THEN
                                                          pkt_id
                                                      ELSE
                                                          NULL
                                                  END)          AS pkt_encrypt_cnt
                                         FROM uss_esr.payroll_reestr pr
                                              JOIN ikis_rbm.v_packet p
                                                  ON p.pkt_id = pr.pe_rbm_pkt
                                              JOIN ikis_rbm.v_packet_content pc
                                                  ON pc.pc_pkt = pr.pe_rbm_pkt
                                        WHERE     p.pkt_rec = l_rec_id -- pr.pe_bnk_rbm_code = l_rec_code
                                              AND (   l_com_org = 50000
                                                   OR p.pkt_rm = l_rm_id)
                                              AND pr.pe_src_entity =
                                                  p_payroll_id
                                       HAVING     COUNT (pc_pkt) =
                                                  COUNT (
                                                      CASE
                                                          WHEN     pkt_st IN
                                                                       ('NVP',
                                                                        'SND',
                                                                        'RCV')
                                                               AND pc.pc_encrypt_data
                                                                       IS NOT NULL
                                                               AND DBMS_LOB.getlength (
                                                                       pc.pc_encrypt_data) >
                                                                   10
                                                          THEN
                                                              pkt_id
                                                          ELSE
                                                              NULL
                                                      END)
                                              AND COUNT (pc_pkt) > 0)
                             THEN
                                 1
                             ELSE
                                 0
                         END                                 AS file_is_ready,
                         CASE
                             WHEN o.org_to = 31 THEN o.org_id
                             ELSE o.org_org
                         END                                 AS com_org, --pr.com_org, -- орган УСПЗН (область);
                         MAX (
                             (SELECT MAX (o2.org_name)
                                FROM v_opfu o2
                               WHERE org_id =
                                     CASE
                                         WHEN o.org_to = 31 THEN o.org_id
                                         ELSE o.org_org
                                     END))                   AS org_name,
                         pr.pe_rbm_pkt,                         -- ід конверта
                         c.npc_name                          AS pr_npc_name --  #107210 + назву послуги, яка виплачується
                    FROM uss_esr.payroll_reestr pr
                         JOIN v_opfu o ON org_id = com_org
                         JOIN uss_ndi.v_ndi_bank b ON b.nb_id = pr.pe_nb
                         JOIN uss_ndi.v_ddn_pe_tp tp ON pe_tp = tp.DIC_VALUE
                         JOIN ikis_rbm.v_packet p ON pr.pe_rbm_pkt = p.pkt_id
                         JOIN uss_ndi.v_ddn_packet_st4kb s
                             ON s.dic_value = p.pkt_st -- показуємо лише підписані
                         JOIN uss_ndi.v_ndi_payment_codes c
                             ON pr.pe_npc = c.npc_id
                   WHERE     p.pkt_rec = l_rec_id -- pr.pe_bnk_rbm_code = l_rec_code
                         AND (l_com_org = 50000 OR p.pkt_rm = l_rm_id)
                         AND pr.pe_src_entity = p_payroll_id
                         AND p.pkt_rec = l_rec_id
                --      and pe_st in ('T','R','P')
                GROUP BY pr.pe_src_entity,
                         pkt_st,
                         b.nb_num,
                         b.nb_mfo,
                         b.nb_name,
                         EXTRACT (YEAR FROM pe_pay_dt),
                         EXTRACT (MONTH FROM pe_pay_dt),
                         pr.pe_name,
                         pr.pe_tp,
                         pr.pe_st,
                         CASE
                             WHEN o.org_to = 31 THEN o.org_id
                             ELSE o.org_org
                         END,
                         tp.dic_sname,
                         s.dic_sname,
                         pr.pe_rbm_pkt,
                         c.npc_name;

            OPEN p_kv1_list FOR
                  SELECT pe_rbm_pkt,                           -- ід пакета ВВ
                         p.pkt_id                           AS kv_rbm_pkt, -- ід пакета ПЕОД - КВ-1
                         p.pkt_create_dt                    AS kv_create_dt, -- дата формування КВ
                         pst.dic_sname                      AS kv_st_name, -- Статус КВ в ПЕОД
                         --pc.pc_visual_data as kv_visual_data -- Опис КВ
                          (SELECT pc.pc_visual_data
                             FROM ikis_rbm.v_packet_content pc
                            WHERE pc.pc_pkt = p.pkt_id)     AS kv_visual_data, -- Опис КВ
                         (SELECT MAX (f.ef_file_name)
                            FROM uss_esr.exchangefiles f
                           WHERE f.ef_kv_pkt = p.pkt_id)    AS kv_name
                    FROM (  SELECT pe_rbm_pkt, COUNT (1) pr_cnt
                              FROM payroll_reestr pr
                                   JOIN ikis_rbm.v_packet p
                                       ON pkt_id = pr.pe_rbm_pkt
                                   JOIN uss_ndi.v_ddn_packet_st4kb s
                                       ON s.dic_value = p.pkt_st -- показуємо лише підписані
                             WHERE     p.pkt_rec = l_rec_id -- pr.pe_bnk_rbm_code = l_rec_code
                                   AND (l_com_org = 50000 OR p.pkt_rm = l_rm_id)
                                   AND pr.pe_src_entity = p_payroll_id
                          GROUP BY pe_rbm_pkt) pr
                         JOIN ikis_rbm.v_packet_links pl
                             ON pl.pl_pkt_out = pr.pe_rbm_pkt
                         JOIN ikis_rbm.v_packet p
                             ON p.pkt_id = pl.pl_pkt_in AND p.pkt_pat IN (102)
                         LEFT JOIN uss_ndi.v_ddn_packet_st pst
                             ON pst.dic_value = p.pkt_st
                   WHERE 1 = 1
                ORDER BY p.pkt_create_dt DESC;

            OPEN p_kv2_list FOR
                  SELECT pe_rbm_pkt,                           -- ід пакета ВВ
                         p.pkt_id                           AS kv_rbm_pkt, -- ід пакета ПЕОД - КВ-2
                         p.pkt_create_dt                    AS kv_create_dt, -- дата формування КВ
                         pst.dic_sname                      AS kv_st_name, -- Статус КВ в ПЕОД
                         --pc.pc_visual_data as kv_visual_data -- Опис КВ
                          (SELECT pc.pc_visual_data
                             FROM ikis_rbm.v_packet_content pc
                            WHERE pc.pc_pkt = p.pkt_id)     AS kv_visual_data, -- Опис КВ
                         (SELECT MAX (f.ef_file_name)
                            FROM uss_esr.exchangefiles f
                           WHERE f.ef_kv_pkt = p.pkt_id)    AS kv_name
                    FROM (  SELECT pe_rbm_pkt, COUNT (1) pr_cnt
                              FROM payroll_reestr pr
                                   JOIN ikis_rbm.v_packet p
                                       ON pkt_id = pr.pe_rbm_pkt
                                   JOIN uss_ndi.v_ddn_packet_st4kb s
                                       ON s.dic_value = p.pkt_st -- показуємо лише підписані
                             WHERE     p.pkt_rec = l_rec_id -- pr.pe_bnk_rbm_code = l_rec_code
                                   AND (l_com_org = 50000 OR p.pkt_rm = l_rm_id)
                                   AND pr.pe_src_entity = p_payroll_id
                          --     and pe_st in ('T','R','P')
                          GROUP BY pe_rbm_pkt) pr
                         JOIN ikis_rbm.v_packet_links pl
                             ON pl.pl_pkt_out = pr.pe_rbm_pkt
                         JOIN ikis_rbm.v_packet p
                             ON p.pkt_id = pl.pl_pkt_in AND p.pkt_pat IN (103)
                         /*    join ikis_rbm.v_packet_content pc
                               on pc.pc_pkt = p.pkt_id*/
                         LEFT JOIN uss_ndi.v_ddn_packet_st pst
                             ON pst.dic_value = p.pkt_st
                   WHERE 1 = 1
                ORDER BY p.pkt_create_dt DESC;
        END IF;
    EXCEPTION
        WHEN exNoBank
        THEN
            raise_application_error (-20000, 'Банк не визначено!');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка одержання інформації по відомості: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- info: 4. Вивантаження пакетів ПЕОД даної відомості (лише пакети зашифровані на список одержувачів(сертифікати))
    -- params: p_payroll_id - идентификатор ведомости;
    -- note: 4. Выкачка архива по ведомости (по идентификатору ведомости);
    --  лише за наявності такого пакета
    --  на 20201207 - це лише пакети ВВ зі способом передачі E-mail
    PROCEDURE GetPayrollPackets (p_cert_serial      IN     VARCHAR2,
                                 p_cert_issuer_cn   IN     VARCHAR2,
                                 p_payroll_id       IN     NUMBER,
                                 p_result              OUT BLOB)
    IS
        l_rec_id     NUMBER;
        l_rec_code   VARCHAR2 (100);
        exNoBank     EXCEPTION;
        l_pr_pkt     BLOB;
        l_files      ikis_sysweb.tbl_some_files
                         := ikis_sysweb.tbl_some_files ();
        l_pkt_cnt    NUMBER;
        l_rm_id      NUMBER;
        l_com_org    NUMBER;
    -- до патча
    /*FUNCTION GetConvert(p_id NUMBER,
                        p_rec_id VARCHAR2) RETURN CLOB
    IS
      l_result CLOB;
      l_pre_result CLOB;
      l_data CLOB;
      l_header ikis_rbm.v_packet_content.pc_header%TYPE;
      l_st ikis_rbm.v_packet.pkt_st%TYPE;
    BEGIN
      BEGIN
        SELECT XMLELEMENT("paymentlists",
                               XMLELEMENT("id", pkt_id),
                               XMLELEMENT("xXx", 'z'),
                               XMLELEMENT("files_data", 'XX##XX'),
                               XMLELEMENT("ecp_list",
                                 (SELECT XMLAGG(XMLELEMENT("ecp", pce_ecp))
                                  FROM ikis_rbm.v_packet_ecp
                                  WHERE pce_pc = pc_id)
                               )).getclobval()
        INTO l_pre_result
        FROM ikis_rbm.v_packet, ikis_rbm.v_packet_content, ikis_sys.v_opfu
        WHERE pc_pkt = pkt_id
          AND pkt_org = org_id
          AND pkt_id = p_id
          and pc_encrypt_data is not null
          and dbms_lob.getlength(pc_encrypt_data) > 10
          AND pkt_st IN ('NVP', 'SND', 'RCV')   --  #64722 oivashchuk 20201208  RCV -  введено новий статус - Отримано банком
          AND pkt_pat in ( 101 )
          AND EXISTS (SELECT 1 FROM ikis_rbm.v_recipient WHERE pkt_rec = rec_id AND rec_code = p_recipient_code);

        SELECT TOOLS.ConvertBlobToBase64(pc_encrypt_data), pc_header
        INTO l_data, l_header FROM ikis_rbm.v_packet_content pc
        WHERE pc_pkt = p_id
          and pc_encrypt_data is not null
          and dbms_lob.getlength(pc.pc_encrypt_data) > 10;
        l_result := TOOLS.PasteClob(l_pre_result, l_header, '<xXx>z</xXx>');
        l_pre_result := l_result;
        l_result := TOOLS.PasteClob(l_pre_result, l_data, 'XX##XX');

      EXCEPTION
        WHEN no_data_found THEN
          l_result := '<paymentlists></paymentlists>';
      END;
      RETURN l_result;
    END;*/

    BEGIN
        GetRecCode (p_Cert_Serial      => p_cert_serial,
                    p_Cert_Issuer_Cn   => p_cert_issuer_cn,
                    p_rec_id           => l_rec_id,
                    p_rec_code         => l_rec_code,
                    p_rm_id            => l_rm_id,
                    p_com_org          => l_com_org);

        -- якщо банк не визначено - повідомлення про помилку.
        IF l_rec_code IS NULL
        THEN
            RAISE exNoBank;
        ELSE
            FOR pkt
                IN (SELECT pc_pkt,
                           pc.pc_encrypt_data,
                           pc.pc_name || '_' || pc.pc_pkt || '.p7e'    AS pc_file_name
                      -- pc.pc_name|| '_' || pc.pc_pkt || '.xml' as pc_file_name
                      FROM ikis_rbm.v_packet_content  pc
                           JOIN ikis_rbm.v_packet p ON p.pkt_id = pc.pc_pkt
                           JOIN uss_ndi.v_ddn_packet_st4kb s
                               ON s.dic_value = p.pkt_st -- показуємо лише підписані
                     WHERE     1 = 1
                           AND pc.pc_encrypt_data IS NOT NULL
                           AND DBMS_LOB.getlength (pc.pc_encrypt_data) > 10
                           AND p.pkt_rec = l_rec_id
                           AND (l_com_org = 50000 OR p.pkt_rm = l_rm_id)
                           AND EXISTS
                                   (SELECT 1
                                      FROM uss_esr.payroll_reestr pr
                                     WHERE     1 = 1 --pr.pe_bnk_rbm_code = l_rec_code
                                           AND pr.pe_src_entity =
                                               p_payroll_id
                                           AND p.pkt_id = pr.pe_rbm_pkt))
            LOOP
                l_files.EXTEND;
                l_files (l_files.LAST) :=
                    ikis_sysweb.t_some_file_info (pkt.pc_file_name,
                                                  pkt.pc_encrypt_data);
            END LOOP;

            --Выходной архив
            IF l_files.COUNT > 0
            THEN
                p_result :=
                    ikis_sysweb.ikis_web_jutil.getZipFromStrms (l_files);
            END IF;
        /*
            l_pkt_cnt := l_files.Count;

            -- запис в лог про скачування !!!
        /*    insert into pr_log(prl_id, prl_pr, prl_pr_st, prl_action, prl_user, prl_dt)
            values(null, pr_rec.pr_id, 'R', 'S', null, sysdate);*/

        -- видаємо  архів
        /*open p_result for
        select
          p_payroll_id, -- идентификатор ведомости;
          l_pkt_cnt as pkt_cnt,  -- к-ть пакетів, доданих до архіву
          'pr_'||p_payroll_id||'.zip'  as file_name,  -- назва архіву: pr_<ід відомості>.zip
          l_pr_pkt as file_data  -- архів з пакетами
        from dual;*/
        END IF;
    EXCEPTION
        WHEN exNoBank
        THEN
            raise_application_error (-20000, 'Банк не визначено!');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка одержання пакетів відомості: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- info: 5. відображення реєстру відомості по днях
    -- params: p_payroll_id -  идентификатор ведомости;
    -- note:   5. Отображение реестра ведомости по дням (по идентификатору ведомости) с данными:
    -- дата; кол-во людей за день; общая сумма за день // ПОЗЖЕ еще добавим статус получения банком платежа от УСПЗН за этот день – сейчас НЕ НАВОРАЧИВАЕМ этим
    --6.2 отображение грида с данніми:
    -- дата;
    -- загальна сума за день;
    -- загальна кількість рядків за день;
    ---------
    --  p_cor_list                   out sys_refcursor  - курсор з коригуючими по днях
    PROCEDURE GetPayrollReestr (p_cert_serial      IN     VARCHAR2,
                                p_cert_issuer_cn   IN     VARCHAR2,
                                p_payroll_id       IN     NUMBER,
                                p_result              OUT SYS_REFCURSOR,
                                p_cor_list            OUT SYS_REFCURSOR)
    IS
        l_rec_id     NUMBER;
        l_rec_code   VARCHAR2 (100);
        exNoBank     EXCEPTION;
        l_rm_id      NUMBER;
        l_com_org    NUMBER;
    BEGIN
        GetRecCode (p_Cert_Serial      => p_cert_serial,
                    p_Cert_Issuer_Cn   => p_cert_issuer_cn,
                    p_rec_id           => l_rec_id,
                    p_rec_code         => l_rec_code,
                    p_rm_id            => l_rm_id,
                    p_com_org          => l_com_org);

        --   raise_application_error(-20000, p_cert_serial||' - '|| p_cert_issuer_cn||' - '|| l_rec_code||' - '||p_payroll_id);

        -- якщо банк не визначено - повідомлення про помилку.
        IF l_rec_code IS NULL
        THEN
            RAISE exNoBank;
        ELSE
            OPEN p_result FOR
                  SELECT pr.pe_src_entity,         -- идентификатор ведомости;
                         pe_pay_dt,                            -- дата виплати
                         s.dic_sname             AS pdt_st_name, -- статус списків за день виплати
                         SUM (pr.pe_sum)         AS pr_sum, -- загальна сума за день, грн;
                         SUM (pr.pe_row_cnt)     AS pr_row_cnt -- загальна кількість рядків за день у списках
                    FROM uss_esr.payroll_reestr pr
                         JOIN ikis_rbm.v_packet p ON pkt_id = pr.pe_rbm_pkt
                         JOIN uss_ndi.v_ddn_packet_st4kb s
                             ON s.dic_value = p.pkt_st -- показуємо лише підписані
                   WHERE     p.pkt_rec = l_rec_id -- pr.pe_bnk_rbm_code = l_rec_code
                         AND (l_com_org = 50000 OR p.pkt_rm = l_rm_id)
                         AND pr.pe_src_entity = p_payroll_id
                GROUP BY pr.pe_src_entity, pe_pay_dt, s.dic_sname;

            OPEN p_cor_list FOR
                  SELECT pr.pe_src_entity                    AS pr_payroll_id, -- идентификатор ведомости;
                         pe_pay_dt,                            -- дата виплати
                         pr.pe_name,                       -- назва відомості;
                         --pr.pe_bnk_code, /*pr.pr_filia_code,*/
                         --pr.pe_bnk_mfo, pr.pe_bnk_name,
                         b.nb_num                            AS pe_bnk_code,
                         b.nb_mfo                            AS pe_bnk_mfo,
                         b.nb_name                           AS pe_bnk_name,
                         EXTRACT (YEAR FROM pe_pay_dt)       AS pay_year, -- рік
                         EXTRACT (MONTH FROM pe_pay_dt)      AS pay_month, -- місяць
                         SUM (pr.pe_row_cnt)                 AS pr_row_cnt, -- загальна кількість рядків у списках (автосумма по информации по дням);
                         SUM (pr.pe_sum)                     AS pr_sum, -- загальна сума, грн (автосумма по информации по дням);
                         pr.pe_st                            AS pr_st,
                         /*decode(pr.pe_st, 'T', 'Передано в банк', 'R', 'Отримано банком',
                                          'P', 'Платіж проведено', 'C', 'Платіж відхилено')*/
                         st.dic_sname                        AS pr_status,
                         /*decode(pr.pe_tp, 1, 'Основна', 3, 'Коригуюча', 2, 'додаткова')*/
                         tp.dic_sname                        AS pr_tp,
                         MAX (
                             (SELECT MIN (h.hs_dt)
                                FROM uss_esr.pe_log prl, histsession h
                               WHERE     prl.pel_pe = pr.pe_id
                                     AND prl.pel_pe_st = 'R'
                                     AND pel_hs = hs_id))    AS pr_receive_dt, -- дата отримання відомості в банку;
                         -- Ознака готовності файлів - перевіряємо чи всі пакети зашифровані (поле pc_encrypt_data - непорожнє)
                         -- і переведені в статус "На відправку" "відправлено", "Одержано"
                         CASE
                             WHEN EXISTS
                                      (SELECT COUNT (pc_pkt)    AS pkt_cnt,
                                              COUNT (
                                                  CASE
                                                      WHEN     pkt_st IN
                                                                   ('NVP',
                                                                    'SND',
                                                                    'RCV')
                                                           AND pc.pc_encrypt_data
                                                                   IS NOT NULL
                                                           AND DBMS_LOB.getlength (
                                                                   pc.pc_encrypt_data) >
                                                               10
                                                      THEN
                                                          pkt_id
                                                      ELSE
                                                          NULL
                                                  END)          AS pkt_encrypt_cnt
                                         FROM uss_esr.payroll_reestr pr
                                              JOIN ikis_rbm.v_packet p
                                                  ON p.pkt_id = pr.pe_rbm_pkt
                                              JOIN ikis_rbm.v_packet_content pc
                                                  ON pc.pc_pkt = pr.pe_rbm_pkt
                                        WHERE     p.pkt_rec = l_rec_id -- pr.pe_bnk_rbm_code = l_rec_code
                                              AND (   l_com_org = 50000
                                                   OR p.pkt_rm = l_rm_id)
                                              AND pr.pe_src_entity =
                                                  p_payroll_id
                                       HAVING     COUNT (pc_pkt) =
                                                  COUNT (
                                                      CASE
                                                          WHEN     pkt_st IN
                                                                       ('NVP',
                                                                        'SND',
                                                                        'RCV')
                                                               AND pc.pc_encrypt_data
                                                                       IS NOT NULL
                                                               AND DBMS_LOB.getlength (
                                                                       pc.pc_encrypt_data) >
                                                                   10
                                                          THEN
                                                              pkt_id
                                                          ELSE
                                                              NULL
                                                      END)
                                              AND COUNT (pc_pkt) > 0)
                             THEN
                                 1
                             ELSE
                                 0
                         END                                 AS file_is_ready,
                         CASE
                             WHEN o.org_to = 31 THEN o.org_id
                             ELSE o.org_org
                         END                                 AS com_org, --pr.com_org, -- орган УСПЗН (область);
                         MAX (
                             (SELECT MAX (o2.org_name)
                                FROM v_opfu o2
                               WHERE org_id =
                                     CASE
                                         WHEN o.org_to = 31 THEN o.org_id
                                         ELSE o.org_org
                                     END))                   AS org_name
                    FROM uss_esr.payroll_reestr pr
                         JOIN ikis_rbm.v_packet p ON p.pkt_id = pr.pe_rbm_pkt
                         JOIN v_opfu o ON org_id = com_org
                         JOIN uss_ndi.v_ndi_bank b ON b.nb_id = pr.pe_nb
                         JOIN uss_ndi.v_ddn_pe_tp tp ON pe_tp = tp.DIC_VALUE
                         LEFT JOIN uss_ndi.v_ddn_pe_st st
                             ON pe_st = st.DIC_VALUE
                   WHERE     p.pkt_rec = l_rec_id -- pr.pe_bnk_rbm_code = l_rec_code
                         AND (l_com_org = 50000 OR p.pkt_rm = l_rm_id)
                         AND EXISTS
                                 (SELECT 1
                                    FROM uss_esr.payroll_reestr p2
                                   WHERE     p2.pe_src_entity = p_payroll_id
                                         AND p2.pe_id = pr.pe_pe_master)
                GROUP BY pr.pe_src_entity, --pr.pe_bnk_code,/* pr.pr_filia_code,*/ pr.pe_bnk_mfo, pr.pe_bnk_name,
                         b.nb_num,
                         b.nb_mfo,
                         b.nb_name,
                         EXTRACT (YEAR FROM pe_pay_dt),
                         EXTRACT (MONTH FROM pe_pay_dt),
                         pr.pe_name,
                         pr.pe_tp,
                         pr.pe_st,
                         CASE
                             WHEN o.org_to = 31 THEN o.org_id
                             ELSE o.org_org
                         END,
                         pe_pay_dt,
                         tp.dic_sname,
                         st.dic_sname;
        END IF;
    EXCEPTION
        WHEN exNoBank
        THEN
            raise_application_error (-20000, 'Банк не визначено!');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка одержання реєстру по відомості: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- info: 6. підтвердження Банком факту одержання відомості - зміна статусу з Передано в банк в Отримано в банку.
    -- params: p_payroll_id - идентификатор ведомости;
    --         p_result - повідомлення???
    -- note:  6. подтверждение Банком получения ведомости (по идентификатору ведомости):
    -- дата отримання ведомости = поточная дата;
    -- перевод статуса из Передано в банк в Отримано в банку.
    PROCEDURE SetPayrollReceived (p_cert_serial      IN     VARCHAR2,
                                  p_cert_issuer_cn   IN     VARCHAR2,
                                  p_payroll_id       IN     NUMBER,
                                  p_result              OUT VARCHAR2)
    IS
        l_rec_id        NUMBER;
        l_rec_code      VARCHAR2 (100);
        l_err_msg       VARCHAR2 (4000);
        exNoBank        EXCEPTION;
        l_cnt           NUMBER;
        l_hs            NUMBER;
        exPktNotReady   EXCEPTION;
        l_rm_id         NUMBER;
        l_com_org       NUMBER;
    BEGIN
        GetRecCode (p_Cert_Serial      => p_cert_serial,
                    p_Cert_Issuer_Cn   => p_cert_issuer_cn,
                    p_rec_id           => l_rec_id,
                    p_rec_code         => l_rec_code,
                    p_rm_id            => l_rm_id,
                    p_com_org          => l_com_org);

        -- якщо банк не визначено - повідомлення про помилку.
        IF l_rec_code IS NULL
        THEN
            RAISE exNoBank;
        END IF;

        SELECT COUNT (1)
          INTO l_cnt
          FROM uss_esr.payroll_reestr  pr
               JOIN ikis_rbm.v_packet p ON p.pkt_id = pr.pe_rbm_pkt
         WHERE     p.pkt_rec = l_rec_id      --pr.pe_bnk_rbm_code = l_rec_code
               AND (l_com_org = 50000 OR p.pkt_rm = l_rm_id)
               AND pr.pe_src_entity = p_payroll_id
               AND NOT EXISTS
                       (SELECT 1
                          FROM ikis_rbm.v_packet_content pc
                         --join ikis_rbm.v_packet p on p.pkt_id = pc.pc_pkt
                         WHERE     1 = 1
                               AND p.pkt_id = pc.pc_pkt
                               AND pc.pc_encrypt_data IS NOT NULL
                               AND DBMS_LOB.getlength (pc.pc_encrypt_data) >
                                   10
                               --and p.pkt_id = pe_rbm_pkt
                               AND pkt_pat IN (101)
                               AND p.pkt_st IN ('NVP', 'SND', 'RCV'));

        IF l_cnt > 0
        THEN
            RAISE exPktNotReady;
        END IF;

        -- оновлюємо статус пакетів в ПЕОД
        l_hs := tools.GetHistSession;

        FOR pr_rec
            IN (  SELECT                                         /*pr.pe_id,*/
                         pr.pe_rbm_pkt, MIN (pe_id) AS pe_id
                    FROM uss_esr.payroll_reestr pr
                         JOIN ikis_rbm.v_packet p ON pkt_id = pr.pe_rbm_pkt
                   WHERE     p.pkt_rec = l_rec_id -- pr.pe_bnk_rbm_code = l_rec_code
                         AND (l_com_org = 50000 OR p.pkt_rm = l_rm_id)
                         AND pr.pe_src_entity = p_payroll_id
                         AND p.pkt_st IN ('NVP', 'SND')
                GROUP BY pr.pe_rbm_pkt)
        LOOP
            /*    update uss_esr.payroll_reestr pr
                set pe_st = 'R'
                where pr.pe_id = pr_rec.pe_id
                  and pr.pe_st = 'T';

                insert into pe_log(pel_id, pel_pe, pel_pe_st, pel_action, pel_hs)
                values(null, pr_rec.pe_id, 'R', 'S', l_hs);*/
            BEGIN
                ikis_rbm.ikis_rbm_esr.set_pkt_received (
                    p_pkt_id           => pr_rec.pe_rbm_pkt,
                    p_recipient_code   => l_rec_code);
            EXCEPTION
                WHEN OTHERS
                THEN
                    l_err_msg :=
                        SUBSTR (
                               SQLERRM
                            || CHR (10)
                            || DBMS_UTILITY.format_error_backtrace,
                            1,
                            4000);
                    DBMS_OUTPUT.put_line (l_err_msg);

                    INSERT INTO pe_log (pel_id,
                                        pel_pe,
                                        pel_pe_st,
                                        pel_action,
                                        pel_hs,
                                        pel_info)
                         VALUES (NULL,
                                 pr_rec.pe_id,
                                 'R',
                                 'S',
                                 l_hs,
                                 l_err_msg);
            END;
        END LOOP;
    EXCEPTION
        WHEN exNoBank
        THEN
            raise_application_error (-20000, 'Банк не визначено!');
        WHEN exPktNotReady
        THEN
            raise_application_error (-20000,
                                     'Файли відомості не були отримані!');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка зміни статусу відомості: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_backtrace);
    END;



    -- info: Вивантаження пакета ПЕОД  по ід (лише пакети зашифровані на список одержувачів(сертифікати))
    -- params: p_rbm_pkt_id - ід пакета ПЕОД
    -- note:
    --  на 20201207 - це лише пакети ВВ зі способом передачі E-mail
    PROCEDURE GetPayrollPacket (p_cert_serial      IN     VARCHAR2,
                                p_cert_issuer_cn   IN     VARCHAR2,
                                p_rbm_pkt_id       IN     NUMBER,
                                p_pkt_name            OUT VARCHAR,
                                p_pkt_data            OUT BLOB)
    IS
        l_rec_id     NUMBER;
        l_rec_code   VARCHAR2 (100);
        exNoBank     EXCEPTION;
        l_pr_pkt     BLOB;
        l_files      ikis_sysweb.tbl_some_files
                         := ikis_sysweb.tbl_some_files ();
        l_pkt_cnt    NUMBER;
        l_rm_id      NUMBER;
        l_com_org    NUMBER;
    BEGIN
        GetRecCode (p_Cert_Serial      => p_cert_serial,
                    p_Cert_Issuer_Cn   => p_cert_issuer_cn,
                    p_rec_id           => l_rec_id,
                    p_rec_code         => l_rec_code,
                    p_rm_id            => l_rm_id,
                    p_com_org          => l_com_org);

        -- якщо банк не визначено - повідомлення про помилку.
        IF l_rec_code IS NULL
        THEN
            RAISE exNoBank;
        ELSE
            /*    select pc.pc_encrypt_data, pc.pc_name|| '_' || pc.pc_pkt || '.p7e' as pc_file_name
                into p_pkt_data, p_pkt_name
                from uss_esr.payroll_reestr pr
                join ikis_rbm.v_packet_content pc  on pc.pc_pkt = pr.pe_rbm_pkt
                join ikis_rbm.v_packet p on p.pkt_id = pr.pe_rbm_pkt
                where pr.pe_bnk_rbm_code = l_rec_code
                  and pr.pe_rbm_pkt = p_rbm_pkt_id
                  and pc.pc_encrypt_data is not null
                  and p.pkt_st in ('NVP', 'SND', 'RCV');*/

            SELECT pc.pc_encrypt_data,
                   pc.pc_name || '_' || pc.pc_pkt || '.p7e'    AS pc_file_name
              INTO p_pkt_data, p_pkt_name
              FROM ikis_rbm.v_packet_content  pc
                   JOIN ikis_rbm.v_packet p ON p.pkt_id = pc.pc_pkt
             WHERE     1 = 1
                   AND p.pkt_rec = l_rec_id                                 --
                   AND (l_com_org = 50000 OR p.pkt_rm = l_rm_id)
                   AND pc.pc_encrypt_data IS NOT NULL
                   AND DBMS_LOB.getlength (pc.pc_encrypt_data) > 10
                   AND p.pkt_id = p_rbm_pkt_id/*     and (pkt_pat in (1,21) and p.pkt_st in ('NVP', 'SND', 'RCV')
                                                          and exists (
                                                              select 1 from  uss_esr.payroll_reestr pr
                                                              where pr.pe_bnk_rbm_code = l_rec_code
                                                                and pr.pe_rbm_pkt = p_rbm_pkt_id
                                                                and p.pkt_id = pr.pe_rbm_pkt)
                                                            or
                                                        pkt_pat not in (1,21)
                                                        )*/
                                              ;
        END IF;
    EXCEPTION
        WHEN exNoBank
        THEN
            raise_application_error (-20000, 'Банк не визначено!');
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                'Помилка одержання пакета відомості: можливо пакет ще не підписано в ПЕОД!');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка одержання пакета відомості: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- io 20230208 поки не буде ....
    -- info: Зміна статусів в реєстрі зі сторони ПЕОД (для пакетів відомостей, які  передаються через InfoCross)
    -- params: p_pkt_id - ід пакета ПЕОД;
    --         p_pkt_st - стату пакета ПЕОД
    -- note:  st_pr_st
    -- T  Передано в пеод
    -- R  Отримано банком
    -- P  Платіж проведено
    -- C  Платіж відхилено

    PROCEDURE SetPayrollStRbm (p_pkt_id IN NUMBER, p_pkt_st IN VARCHAR2)
    IS
        l_rec_id     NUMBER;
        l_rec_code   VARCHAR2 (100);
        exNoBank     EXCEPTION;
        l_err_msg    VARCHAR2 (4000);
        l_pr_st      VARCHAR2 (10);
        l_hs         NUMBER;
    BEGIN
        NULL;
    /*
      if p_pkt_st = 'RCV' then

        l_hs := tools.GetHistSession;

        for pr_rec in (
          select pr.pe_id, pr.pe_rbm_pkt
          from uss_esr.payroll_reestr pr
          where pr.pe_rbm_pkt = p_pkt_id
            and pr.pe_st = 'T')
        loop
          update uss_esr.payroll_reestr pr
          set pe_st = 'R'
          where pr.pe_id = pr_rec.pe_id
            and pr.pe_st = 'T';

          insert into pe_log(pel_id, pel_pe, pel_pe_st, pel_action, pel_hs)
          values(null, pr_rec.pe_id, 'R', 'RCV', l_hs);
        end loop;
      end if;
    */
    EXCEPTION
        WHEN OTHERS
        THEN
            --raise_application_error(-20000, 'Помилка зміни статусу відомості: '||sqlerrm||chr(10)||dbms_utility.format_error_backtrace);
            NULL;
    END;

    -- info:  Формування пакетів КВ-1 та КВ-2 (PCA, PPR) в ПЕОД
    -- params: p_rbm_pkt_id – ід пакета ВВ в ПЕОД
    --         p_pkt_tp     - тип пакета, що формується  -- uss_esr.ST_RBM_PKT_TP
    --         p_pkt_name   - Назва файлу
    --         p_pkt_info   - опис пакета для візуалізації в ПЕОД
    --         p_pkt_blob   - шифрований файл пакета
    -- note:
    PROCEDURE GenKVPackets (p_cert_serial      IN     VARCHAR2,
                            p_cert_issuer_cn   IN     VARCHAR2,
                            --p_rbm_pkt_id number,
                            p_payroll_id       IN     NUMBER,
                            p_pkt_tp           IN     VARCHAR2,
                            p_pkt_name         IN     VARCHAR2,
                            p_pkt_blob         IN     BLOB,
                            p_pkt_encr_blob    IN     BLOB,
                            p_message             OUT VARCHAR2)
    IS
        l_rec_id        NUMBER;
        l_rec_code      VARCHAR2 (100);
        l_cnt           NUMBER;
        exPktNotReady   EXCEPTION;
        l_rm_id         NUMBER;
        l_com_org       NUMBER;
    BEGIN
        GetRecCode (p_Cert_Serial      => p_cert_serial,
                    p_Cert_Issuer_Cn   => p_cert_issuer_cn,
                    p_rec_id           => l_rec_id,
                    p_rec_code         => l_rec_code,
                    p_rm_id            => l_rm_id,
                    p_com_org          => l_com_org);

        --l_rec_code := 'TESTBANK1';
        -- якщо банк не визначено - повідомлення про помилку.
        IF l_rec_code IS NULL
        THEN
            RAISE exNoBank;
        END IF;

        SELECT COUNT (1)
          INTO l_cnt
          FROM uss_esr.payroll_reestr  pr
               JOIN ikis_rbm.v_packet p ON pkt_id = pr.pe_rbm_pkt
         --  join uss_ndi.v_ddn_packet_st4kb s on s.dic_value = p.pkt_st   -- показуємо лише підписані
         WHERE     p.pkt_rec = l_rec_id     -- pr.pe_bnk_rbm_code = l_rec_code
               AND (l_com_org = 50000 OR p.pkt_rm = l_rm_id)
               AND pr.pe_src_entity = p_payroll_id
               AND p.pkt_st = 'NVP';

        IF l_cnt > 0
        THEN
            RAISE exPktNotReady;
        END IF;

        API$ESR_EXCHANGE.GenKVPackets (     --p_rbm_pkt_id    => p_rbm_pkt_id,
                                       p_payroll_id      => p_payroll_id,
                                       p_pkt_tp          => p_pkt_tp,
                                       p_pkt_name        => p_pkt_name,
                                       p_pkt_blob        => p_pkt_blob,
                                       p_pkt_encr_blob   => p_pkt_encr_blob,
                                       p_message         => p_message);
    /*  FINZVIT_EXCHANGE.GenKVPackets(p_rbm_pkt_id => p_rbm_pkt_id,
                                    p_pkt_tp     => p_pkt_tp,
                                    p_filia_name => p_filia_name,
                                    p_pkt_info   => p_pkt_info,
                                    p_pkt_blob   => p_pkt_blob);*/
    /*   if p_message is not null then
         InsertFZLog(
            p_pr_id  => null,
            p_pr_st  => null,
            p_action => 'GENKV',
            p_user   => null,
            p_info   => 'p_payroll_id='||p_payroll_id||', p_pkt_tp='||p_pkt_tp||', p_pkt_name='||p_pkt_name||
                        ', p_message = '||p_message
         );
       end if;*/

    EXCEPTION
        WHEN exNoBank
        THEN
            raise_application_error (-20000, 'Банк не визначено!');
        WHEN exPktNotReady
        THEN
            raise_application_error (-20000,
                                     'Файли відомості не були отримані!');
        WHEN OTHERS
        THEN
            /*  InsertFZLog(
                 p_pr_id  => null,
                 p_pr_st  => null,
                 p_action => 'GENKV',
                 p_user   => null,
                 p_info   => 'p_payroll_id='||p_payroll_id||', p_pkt_tp='||p_pkt_tp||', p_pkt_name='||p_pkt_name||
                             ', Помилка формування пакета :'||chr(10)||sqlerrm
              );*/
            raise_application_error (
                -20000,
                   'Помилка формування пакета :'
                || CHR (10)
                || SQLERRM
                || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    END;



    -- 1. Надання банку реєстру платіжних доручень за вказаний період
    -- params: p_Cert_Serial – Серійний номер сертифікату
    --         p_Cert_Issuer_Cn – АЦСК сертифікату
    --         p_po_pay_dt_start - Дата з - дата початку періоду дат ПД
    --         p_po_pay_dt_stop  - Дата по - кінцева дата періоду дат ПД
    --         p_po_pkt_st  - стутус реєстра списків по ПД в ПЕОД - довідник uss_esr.st_po_pkt_st
    --     Marina 20210319 15:32  а будет 2 статуса = на видправку = Передано в банк;  + Одержано в банку - после отправки результата отработки
    --         p_po_prc_st  - результат опрацювання файлу з реєстром списків по ПД - довідник uss_esr.v_rv2pda_prc_codes
    -- МФО визначаємо по коду одержувача з довідника банків ППВП : select * from ikis_ppvp.nsi_psb b where b.psb_rbm_code = 'BANK11763';
    -- В перелік включаються платіжні доручення тільки в статусі "Платіж проведено" (Р) + існує посилання на документ в АБ (PO_UD_AB > 0)
    PROCEDURE GetPayOrderList (p_cert_serial         IN     VARCHAR2,
                               p_cert_issuer_cn      IN     VARCHAR2,
                               p_po_date_pay_start   IN     DATE,
                               p_po_date_pay_stop    IN     DATE,
                               p_po_pkt_st           IN     VARCHAR2,
                               p_po_prc_st           IN     VARCHAR2,
                               p_result                 OUT SYS_REFCURSOR)
    IS
        l_rec_id      NUMBER;
        l_rec_code    VARCHAR2 (100);
        l_bnk_mfo     VARCHAR2 (10);
        --  l_msg_err   varchar2(4000);
        exNoBank      EXCEPTION;
        exNoBankMFO   EXCEPTION;
        l_rm_id       NUMBER;
        l_com_org     NUMBER;
    BEGIN
        GetRecCode (p_Cert_Serial      => p_cert_serial,
                    p_Cert_Issuer_Cn   => p_cert_issuer_cn,
                    p_rec_id           => l_rec_id,
                    p_rec_code         => l_rec_code,
                    p_rm_id            => l_rm_id,
                    p_com_org          => l_com_org);
    /*
       -- якщо банк не визначено - повідомлення про помилку.
      if l_rec_code is null then
        raise exNoBank;
      else

        -- Визначаємо МФО по коду одержувача з довідника банків ППВП :
        select max(b.psb_mfo) into l_bnk_mfo
        from uss_ndi.ndi_bank \*ikis_ppvp.nsi_psb*\ b
        where b.psb_rbm_code = l_rec_code;


        -- !!!!! для тестування, оскільки на глаші бардак з МФО ...
        -- перед установкою на пром/тест закоментувати !!!!!!
          -- if l_rec_code = 'TESTBANK1' then l_bnk_mfo := '300465'; end if;
          -- if l_rec_code = 'BANK197' then l_bnk_mfo := '354507'; end if;

        if l_bnk_mfo is null then
          raise exNoBankMFO;
        end if;

        --dbms_output.put_line('l_rec_code='||l_rec_code) ;
        --dbms_output.put_line('l_bnk_mfo='||l_bnk_mfo) ;

        open p_result for
        select
          po_id, -- ID платіжного доручення (PO_ID)
          po_number, -- Номер платіжного доручення (PO_NUMBER)
          ---po_date_create, -- Дата платіжного доручення (PO_DATE_CREATE)
          PO_DATE_PAY, -- Дата проведення платіжного доручення (PO_DATE_PAY)
          (select count(1) from payroll_reestr where pr_po = po_id)as po_pr_cnt, -- Загальна кількість списків в ПД - розраховується
          po_sum, -- Сума (PO_SUM)
          po_bank_account_src, -- Рахунок платника (PO_BANK_ACCOUNT_SRC)
          po_bank_account_dest, -- Рахунок отримувача (PO_BANK_ACCOUNT_DEST)
          -----po_purpose, -- Призначення (PO_PURPROSE)
          dpg.dpg_name as po_purpose, -- Призначення  PO_DPG v_dic_distrib_purpose_gr
          case when  p.pkt_st in ('NVP', 'SND', 'RCV')
                and exists(
                      select 1
                      from ikis_rbm.v_packet_content pc
                      where 1=1
                        and pc.pc_main_tag_name = 'rv2pd_list'
                        and pc.pc_pkt = p.pkt_id
                        and pc.pc_encrypt_data is not null
                        and dbms_lob.getlength(pc.pc_encrypt_data) > 10
                        )

                 \*exists(
                      select 1
                      from ikis_rbm.v_packet_content pc
                      join ikis_rbm.v_packet p on p.pkt_id = pc.pc_pkt
                      join exchangefiles f on ef_id = pc.pc_src_entity -- p.pkt_id = f.ef_pkt
                      where 1=1
                        and pc.pc_main_tag_name = 'rv2pd_list'
                        and p.pkt_pat =  81
                        and ef_po = po_id
                        and pc.pc_encrypt_data is not null
                        and dbms_lob.getlength(pc.pc_encrypt_data) > 10
                        and p.pkt_st in ('NVP', 'SND', 'RCV')
                        )*\
            then 1
            else 0
          end  as file_is_ready,

          case when pkt_st = 'RCV' then 'RCV'
               when pkt_st in ('NVP', 'SND') then 'SND'
               else 'NONE'
          end as po_pkt_st,

          case when pkt_st in ('NVP', 'SND') then (select max(sv_name) from st_po_pkt_st where sv_id = 'SND')
               when pkt_st in ('RCV') then (select max(sv_name) from st_po_pkt_st where sv_id = 'RCV')
               else 'Відсутній'
          end
          as po_pkt_st_name,

          ef_prc_code as po_prc_st,
          (select max(ppc.ppc_name)
           from v_rv2pda_prc_codes ppc
           where ppc_pt=  82
            and ppc_code = ef_prc_code
            and ppc_tp = 'F') as po_prc_st_name

        from pay_order t
        join uss_esr.exchangefiles fp
          on fp.ef_po = po_id
          and fp.ef_main_tag_name = 'rv2pd_list'
        join ikis_rbm.v_packet p
          on p.pkt_id = fp.ef_pkt
          and p.pkt_pat in (81)
          and pkt_st in ('NVP', 'SND', 'RCV')
        join v_dic_distrib_purpose_gr dpg
          on dpg.dpg_id = po_dpg
        where 1 = 1
          and po_bank_mfo_dest = l_bnk_mfo
          and po_status = 'APPR' -- Проведено банком
          and po_ud_ab > 0
          and (p_po_date_pay_start is null or po_date_pay  >= p_po_date_pay_start)
          and (p_po_date_pay_stop is null or po_date_pay <= p_po_date_pay_stop)
          and (p_po_prc_st is null or p_po_prc_st = ef_prc_code)
          and (p_po_pkt_st is null or p_po_pkt_st = case when pkt_st = 'RCV' then 'RCV'
                                                         when pkt_st in ('NVP', 'SND') then 'SND'
                                                         else 'NONE'
                                                     end)
          ;
       end if;
    */
    EXCEPTION
        WHEN exNoBank
        THEN
            raise_application_error (-20000, 'Банк не визначено!');
        WHEN exNoBankMFO
        THEN
            raise_application_error (-20000,
                                     'Не вдалося визначити МФО банк!');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка пошуку відомості: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_backtrace);
    END;


    -- 2. Надання реєстру виплатних списків по платіжному дорученню
    -- params: p_Cert_Serial – Серійний номер сертифікату
    --         p_Cert_Issuer_Cn – АЦСК сертифікату
    --         p_po_id - ід платіжного доручення (po_id)
    -- МФО визначаємо по коду одержувача з довідника банків ППВП : select * from ikis_ppvp.nsi_psb b where b.psb_rbm_code = 'BANK11763';
    -- В перелік включаються платіжні доручення тільки в статусі "Платіж проведено" (Р) + існує посилання на документ в АБ (PO_UD_AB > 0)
    PROCEDURE GetPayOrderInfo (p_cert_serial      IN     VARCHAR2,
                               p_cert_issuer_cn   IN     VARCHAR2,
                               p_po_id            IN     NUMBER,
                               p_result              OUT SYS_REFCURSOR /*,  20210319
                         p_kv_list                    out sys_refcursor*/
                                                                      )
    IS
        l_rec_id             NUMBER;
        l_rec_code           VARCHAR2 (100);
        l_bnk_mfo            VARCHAR2 (10);
        l_po_bank_mfo_dest   pay_order.po_bank_mfo_dest%TYPE;
        l_po_status          pay_order.po_st%TYPE;
        --  l_msg_err   varchar2(4000);
        exNoBank             EXCEPTION;
        exNoBankMFO          EXCEPTION;
        exBadBankMFO         EXCEPTION;
        exBadPoStatus        EXCEPTION;
        l_rm_id              NUMBER;
        l_com_org            NUMBER;
    BEGIN
        GetRecCode (p_Cert_Serial      => p_cert_serial,
                    p_Cert_Issuer_Cn   => p_cert_issuer_cn,
                    p_rec_id           => l_rec_id,
                    p_rec_code         => l_rec_code,
                    p_rm_id            => l_rm_id,
                    p_com_org          => l_com_org);
    /*
       -- якщо банк не визначено - повідомлення про помилку.
      if l_rec_code is null then
        raise exNoBank;
      else

        -- Визначаємо МФО по коду одержувача з довідника банків ППВП :
        select max(b.psb_mfo) into l_bnk_mfo
        from ikis_ppvp.nsi_psb b
        where b.psb_rbm_code = l_rec_code;

        -- !!!!! для тестування, оскільки на глаші бардак з МФО ...
        -- перед установкою на пром/тест закоментувати !!!!!!
              -- if l_rec_code = 'TESTBANK1' then l_bnk_mfo := '300465'; end if;
              -- if l_rec_code = 'BANK197' then l_bnk_mfo := '354507'; l_rec_code := 'TESTBANK1'; end if;

        if l_bnk_mfo is null then
          raise exNoBankMFO;
        end if;

       -- контроль на відповідність ПД банку користувача ?
       select po_bank_mfo_dest, po_st
       into l_po_bank_mfo_dest, l_po_status
       from pay_order po
       where po_id = p_po_id;

       if nvl(l_po_bank_mfo_dest, 'qwerty') != nvl(l_bnk_mfo, 'ytrewq') then
          raise exBadBankMFO;
        end if;

       if l_po_status != 'APPR' then -- Проведено банком
          raise exBadPoStatus;
       end if;

       open p_result for
        select
          pr.pe_po, -- ід платіжного доручення (pr_po)
          \*tp.dic_sname*\
          tp.dic_sname\*||'. '||pr.pe_name*\ as pe_tp, -- Тип відомості (pr_tp)
          pr.pe_pay_dt, -- Дата виплати (pr_day)
          \*sum*\(pr.pe_row_cnt) as pr_row_cnt, -- кількість рядків в списку (pr_row_cnt)
          \*sum*\(pr.pe_sum) as pr_sum -- сума (pr_sum)
        from uss_esr.payroll_reestr pr
        join v_opfu o on org_id = com_org
        join uss_ndi.v_ddn_pe_tp tp on pe_tp = tp.DIC_VALUE
        where pr.pe_bnk_rbm_code = l_rec_code
          and pr.pe_po = p_po_id
        \*group by pr.pr_po, \*pr.pe_tp*\\*tp.dic_sname*\tp.dic_sname||'. '||pr.pe_name, pr.pe_pay_dt*\;

        \*
        open p_kv_list for
        select
           fp.ef_pkt as po_rbm_pkt,  -- ід пакета ПД
           p.pkt_id as kv_rbm_pkt,  -- ід пакета ПЕОД - КВ ПД
           p.pkt_create_dt as kv_create_dt, -- дата формування КВ  ПД
           pst.dic_sname as kv_st_name, -- Статус КВ в ПЕОД
            (
            select  pc.pc_visual_data
            from ikis_rbm.v_packet_content pc
            where  pc.pc_pkt = p.pkt_id
           ) as kv_visual_data, -- Опис КВ
           (select max(f.ef_file_name) from uss_esr.exchangefiles f where f.ef_kv_pkt =  p.pkt_id) as kv_name
        from pay_order po -- where po_status = 'APPR'
        join uss_esr.exchangefiles fp
          on fp.ef_po = po_id
          and fp.ef_main_tag_name = 'rv2pd_list'
        join ikis_rbm.v_packet_links pl
          on pl.pl_pkt_out = fp.ef_pkt
        join ikis_rbm.v_packet p
          on p.pkt_id = pl.pl_pkt_in
          and p.pkt_pat in (82)
        join ikis_rbm.v_packet_content pc on pc.pc_pkt = p.pkt_id
        left join uss_ndi.v_ddn_packet_st pst
          on pst.dic_value = p.pkt_st
        where 1=1
          and po.po_id = p_po_id
        order by p.pkt_create_dt desc;*\

       end if;
    */
    EXCEPTION
        WHEN exNoBank
        THEN
            raise_application_error (-20000, 'Банк не визначено!');
        WHEN exNoBankMFO
        THEN
            raise_application_error (-20000,
                                     'Не вдалося визначити МФО банк!');
        WHEN exBadBankMFO
        THEN
            raise_application_error (
                -20000,
                'МФО банку користувача не відповідає МФО банку ПД!');
        WHEN exBadPoStatus
        THEN
            raise_application_error (
                -20000,
                'Статус ПД відмінний від "Проведено банком "!');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка пошуку відомості: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_backtrace);
    END;


    --3. Одержання по ід ПД шифрованого файлу реєстру списків платіжного доручення з ПЕОД
    --  ід платіжного доручення (po_id)
    --  в ПЕОД змінюємо статус на "Одержано банком"
    PROCEDURE GetPayOrderPacket (p_cert_serial      IN     VARCHAR2,
                                 p_cert_issuer_cn   IN     VARCHAR2,
                                 p_po_id            IN     NUMBER,
                                 p_result              OUT BLOB)
    IS
        l_rec_id             NUMBER;
        l_rec_code           VARCHAR2 (100);
        l_bnk_mfo            VARCHAR2 (10);
        l_po_bank_mfo_dest   pay_order.po_bank_mfo_dest%TYPE;
        l_po_status          pay_order.po_st%TYPE;
        --  l_msg_err   varchar2(4000);
        exNoBank             EXCEPTION;
        exNoBankMFO          EXCEPTION;
        exBadBankMFO         EXCEPTION;
        exBadPoStatus        EXCEPTION;
        l_po_pkt             BLOB;
        l_files              ikis_sysweb.tbl_some_files
                                 := ikis_sysweb.tbl_some_files ();
        l_pkt_cnt            NUMBER;
        l_rm_id              NUMBER;
        l_com_org            NUMBER;
    BEGIN
        GetRecCode (p_Cert_Serial      => p_cert_serial,
                    p_Cert_Issuer_Cn   => p_cert_issuer_cn,
                    p_rec_id           => l_rec_id,
                    p_rec_code         => l_rec_code,
                    p_rm_id            => l_rm_id,
                    p_com_org          => l_com_org);
    /*
      -- якщо банк не визначено - повідомлення про помилку.
    -- якщо банк не визначено - повідомлення про помилку.
      if l_rec_code is null then
        raise exNoBank;
      else

        -- Визначаємо МФО по коду одержувача з довідника банків ППВП :
        select max(b.psb_mfo) into l_bnk_mfo
        from ikis_ppvp.nsi_psb b
        where b.psb_rbm_code = l_rec_code;

        -- !!!!! для тестування, оскільки на глаші бардак з МФО ...
        -- перед установкою на пром/тест закоментувати !!!!!!
              -- if l_rec_code = 'TESTBANK1' then l_bnk_mfo := '300465'; end if;
              -- if l_rec_code = 'BANK197' then l_bnk_mfo := '354507'; end if;

        if l_bnk_mfo is null then
          raise exNoBankMFO;
        end if;

       -- контроль на відповідність ПД банку користувача ?
       select po_bank_mfo_dest, po_st
       into l_po_bank_mfo_dest, l_po_status
       from pay_order po
       where po_id = p_po_id;

       if nvl(l_po_bank_mfo_dest, 'qwerty') != nvl(l_bnk_mfo, 'ytrewq') then
          raise exBadBankMFO;
        end if;

       if l_po_status != 'APPR' then -- Проведено банком
          raise exBadPoStatus;
       end if;

        for pkt in (
              select  pc_pkt, pc.pc_encrypt_data, pc.pc_name|| '_' || pc.pc_pkt || '.p7e' as pc_file_name
              from ikis_rbm.v_packet_content pc
              join ikis_rbm.v_packet p on p.pkt_id = pc.pc_pkt
              join exchangefiles f on ef_id = pc.pc_src_entity -- p.pkt_id = f.ef_pkt
              where 1=1
                and pc.pc_main_tag_name = 'rv2pd_list'
                and p.pkt_pat =  81
                and ef_po = p_po_id
                and p.pkt_st in ('NVP', 'SND', 'RCV')
                and pc.pc_encrypt_data is not null
                and dbms_lob.getlength(pc.pc_encrypt_data) > 10
    \*          select  pc_pkt, pc.pc_encrypt_data, pc.pc_name|| '_' || pc.pc_pkt || '.p7e' as pc_file_name
              from ikis_rbm.v_packet_content pc
              join ikis_rbm.v_packet p on p.pkt_id = pc.pc_pkt
              where 1=1
               and pc.pc_encrypt_data is not null
               and dbms_lob.getlength(pc.pc_encrypt_data) > 10
               and exists (
                select 1 from exchangefiles f
                where ef_po = p_po_id
                  and p.pkt_st in ('NVP', 'SND', 'RCV')
                  and p.pkt_id = f.ef_pkt
                  )*\
                )
        loop
          l_files.extend;
          l_files(l_files.LAST) := ikis_sysweb.t_some_file_info(pkt.pc_file_name, pkt.pc_encrypt_data);
        end loop;

        --Выходной архив
        if l_files.Count > 0 then
          p_result := ikis_sysweb.ikis_web_jutil.getZipFromStrms(l_files);
        end if;

        --  #67447  Задача #67337: Фіксація дати та статусу опрацювання ресєстру
        update pay_order po
        set po.po_bank_get_dt = sysdate
        where po.po_id = p_po_id;

       end if;
    */
    EXCEPTION
        WHEN exNoBank
        THEN
            raise_application_error (-20000, 'Банк не визначено!');
        WHEN exNoBankMFO
        THEN
            raise_application_error (-20000,
                                     'Не вдалося визначити МФО банк!');
        WHEN exBadBankMFO
        THEN
            raise_application_error (
                -20000,
                'МФО банку користувача не відповідає МФО банку ПД!');
        WHEN exBadPoStatus
        THEN
            raise_application_error (
                -20000,
                'Статус ПД відмінний від "Проведено банком "!');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка одержання пакетів відомості: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_backtrace);
    END;

    --4. Повідомлення банку про отримання реєстру списків платіжного доручення  -Відповідь банку:
    -- ід платіжного доручення (po_id)
    -- p_po_result - код результату
    -- в ПЕОД генеруємо пакет-квитанцію про отримання.
    PROCEDURE SetPayOrderPacketKv (p_cert_serial      IN VARCHAR2,
                                   p_cert_issuer_cn   IN VARCHAR2,
                                   p_po_id            IN NUMBER,
                                   p_po_result        IN NUMBER)
    IS
        l_rec_id             NUMBER;
        l_rec_code           VARCHAR2 (100);
        l_bnk_mfo            VARCHAR2 (10);
        l_po_bank_mfo_dest   pay_order.po_bank_mfo_dest%TYPE;
        l_po_status          pay_order.po_st%TYPE;
        --  l_msg_err   varchar2(4000);
        exNoBank             EXCEPTION;
        exNoBankMFO          EXCEPTION;
        exBadBankMFO         EXCEPTION;
        exBadPoStatus        EXCEPTION;
        l_po_kv_blob         BLOB;
        l_files              ikis_sysweb.tbl_some_files
                                 := ikis_sysweb.tbl_some_files ();
        l_pkt_cnt            NUMBER;
        l_po_pr_cnt          NUMBER;
        l_rbm_pkt_id         NUMBER;
        l_res_file_name      VARCHAR2 (1000);
        l_rm_id              NUMBER;
        l_com_org            NUMBER;
    BEGIN
        GetRecCode (p_Cert_Serial      => p_cert_serial,
                    p_Cert_Issuer_Cn   => p_cert_issuer_cn,
                    p_rec_id           => l_rec_id,
                    p_rec_code         => l_rec_code,
                    p_rm_id            => l_rm_id,
                    p_com_org          => l_com_org);
    /*
       -- якщо банк не визначено - повідомлення про помилку.
    -- якщо банк не визначено - повідомлення про помилку.
      if l_rec_code is null then
        raise exNoBank;
      else

        -- Визначаємо МФО по коду одержувача з довідника банків ППВП :
        select max(b.psb_mfo) into l_bnk_mfo
        from ikis_ppvp.nsi_psb b
        where b.psb_rbm_code = l_rec_code;
        -- !!!!! для тестування, оскільки на глаші бардак з МФО ...
        -- перед установкою на пром/тест закоментувати !!!!!!
              -- if l_rec_code = 'TESTBANK1' then l_bnk_mfo := '300465'; end if;
              -- if l_rec_code = 'BANK197' then l_bnk_mfo := '354507'; end if;

        if l_bnk_mfo is null then
          raise exNoBankMFO;
        end if;
     -- dbms_output.put_line('l_bnk_mfo='||l_bnk_mfo) ;

      select nvl(max(\*ppc_name*\ppc_full_name), p_po_result)
      into l_res_file_name
      from v_rv2pda_prc_codes ppc
      where ppc_pt=  82
        and ppc_code = p_po_result
        and ppc_tp = 'F';

         -- dbms_output.put_line('l_res_file_name='||l_res_file_name) ;

         -- dbms_output.put_line('p_po_id='||p_po_id) ;

       -- контроль на відповідність ПД банку користувача ?
       select po_bank_mfo_dest, po_st,
          '<h5>Повідомлення банку про отримання реєстру списків платіжного доручення №'|| po.po_number ||
                ' від '||to_char(po.po_pay_dt\*po_date_create*\,'dd.mm.yyyy') ||' на суму '||po.po_sum||'</h5>'||chr(10)
               || 'Результат опрацювання: ' || l_res_file_name
       into l_po_bank_mfo_dest, l_po_status, l_res_file_name
       from pay_order po
       where po_id = p_po_id;


         -- dbms_output.put_line('l_res_file_name='||l_res_file_name) ;


       if nvl(l_po_bank_mfo_dest, 'qwerty') != nvl(l_bnk_mfo, 'ytrewq') then
          raise exBadBankMFO;
        end if;

       if l_po_status != 'APPR' then -- Проведено банком
          raise exBadPoStatus;
       end if;

       -- Лог в ФС ????


       -- визначаємо ід пакета ПД в ПЕОД
        select  pc_pkt into l_rbm_pkt_id
        from ikis_rbm.v_packet_content pc
        join ikis_rbm.v_packet p on p.pkt_id = pc.pc_pkt
        join exchangefiles f on ef_id = pc.pc_src_entity -- p.pkt_id = f.ef_pkt
        where 1=1
          and pc.pc_main_tag_name = 'rv2pd_list'
          and p.pkt_pat =  81
          and ef_po = p_po_id
          and p.pkt_st in ('NVP', 'SND', 'RCV')
          and pc.pc_encrypt_data is not null
          and dbms_lob.getlength(pc.pc_encrypt_data) > 10;

       -- визначаємо кількість рядків в ПД
       select count(1) into l_po_pr_cnt
       from payroll_reestr pr
       where pr.pe_po = p_po_id;

       -- формуємо КВ   ???  чи все ж таки готову від банка ?????
       l_po_kv_blob := utl_compress.lz_compress(tools.ConvertC2B(
    '<?xml version="1.0" encoding="utf-8"?>
    <post_rv2pd_answer>
    <id>'||l_rbm_pkt_id||'</id>
    <date_time>'||to_char(sysdate,'dd.mm.yyyy hh24:mi:ss') ||'</date_time>
    <full_lines>'||l_po_pr_cnt||'</full_lines>
    <res_file>'||p_po_result||'</res_file>
    </post_rv2pd_answer>'));


       -- заливаємо
         -- Call the procedure
      api$esr_exchange.GenKVPackets82(p_rbm_pkt_id => l_rbm_pkt_id,
                                    p_pkt_tp     => 82, -- rv2pd_answer
                                    p_po_id      => p_po_id,
                                    p_po_result  => p_po_result,
                                    p_pkt_info   => l_res_file_name,
                                    p_pkt_blob   => l_po_kv_blob);

         -- #67447
         update pay_order po
         set po.po_bank_ppc = p_po_result
         where po.po_id = p_po_id;

       end if;
    */
    EXCEPTION
        WHEN exNoBank
        THEN
            raise_application_error (-20000, 'Банк не визначено!');
        WHEN exNoBankMFO
        THEN
            raise_application_error (-20000,
                                     'Не вдалося визначити МФО банк!');
        WHEN exBadBankMFO
        THEN
            raise_application_error (
                -20000,
                'МФО банку користувача не відповідає МФО банку ПД!');
        WHEN exBadPoStatus
        THEN
            raise_application_error (
                -20000,
                'Статус ПД відмінний від "Проведено банком "!');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка одержання пакетів відомості: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- info: 10.  сервіс «Повідомлення банку про платіжне доручення повернення коштів з рахунків пенсіонерів» (post_pd_return)
    -- params: p_Cert_Serial – Серійний номер сертифікату
    --         p_Cert_Issuer_Cn – АЦСК сертифікату
    --         p_pkt_name   - Назва файлу
    --         p_pkt_blob   - файл пакета
    --         p_pkt_blob   - шифрований файл пакета
    --         p_message    - повідомлення про помилку завантаження/збереження. в разі успішного виконання - порожнє.
    -- note:
    PROCEDURE PostPDReturn (p_cert_serial      IN     VARCHAR2,
                            p_cert_issuer_cn   IN     VARCHAR2,
                            p_pkt_name         IN     VARCHAR2,
                            p_pkt_blob         IN     BLOB,
                            p_pkt_encr_blob    IN     BLOB,
                            p_message             OUT VARCHAR2)
    IS
        l_rec_id        NUMBER;
        l_rec_code      VARCHAR2 (100);
        l_cnt           NUMBER;
        exPktNotReady   EXCEPTION;
        l_rm_id         NUMBER;
        l_com_org       NUMBER;
    BEGIN
        GetRecCode (p_Cert_Serial      => p_cert_serial,
                    p_Cert_Issuer_Cn   => p_cert_issuer_cn,
                    p_rec_id           => l_rec_id,
                    p_rec_code         => l_rec_code,
                    p_rm_id            => l_rm_id,
                    p_com_org          => l_com_org);
    /*  --l_rec_code := 'TESTBANK1';
       -- якщо банк не визначено - повідомлення про помилку.
      if l_rec_code is null then
        raise exNoBank;
      end if;

      -- Call the procedure
      api$esr_exchange.PostPDReturn(p_pkt_rec_code  => l_rec_code,
                                    p_pkt_name      => p_pkt_name,
                                    p_pkt_blob      => p_pkt_blob,
                                    p_pkt_encr_blob => p_pkt_encr_blob,
                                    p_message       => p_message);*/
    EXCEPTION
        WHEN exNoBank
        THEN
            raise_application_error (-20000, 'Банк не визначено!');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка формування Повідомлення про ПД повернення коштів :'
                || CHR (10)
                || SQLERRM);
    END;

    /*
    - відображення по завантаженому:
    № платіжного доручення - pd_num;
    дата платіжного доручення (в форматі ddmmyyyy) - pd_date;
    Загальна сума платіжного доручення (в копійках) - pd_sum;
    Загальна кількість рядків в файлі - pd_lines;
    Статус.*/



    -- Надання банку реєстру платіжних доручень (повідомлення про платіжне доручення повернення коштів) за вказаний період
    -- params: p_Cert_Serial – Серійний номер сертифікату
    --         p_Cert_Issuer_Cn – АЦСК сертифікату
    --         p_rr_pd_date_start - Дата з - дата початку періоду дат ПД
    --         p_rr_pd_date_stop  - Дата по - кінцева дата періоду дат ПД
    --         p_rr_st  - стутус повідомлення про ПД повернення - довідник uss_esr.st_rr_st

    PROCEDURE GetPDReturnList (p_cert_serial        IN     VARCHAR2,
                               p_cert_issuer_cn     IN     VARCHAR2,
                               p_rr_pd_date_start   IN     DATE,
                               p_rr_pd_date_stop    IN     DATE,
                               p_rr_st              IN     VARCHAR2,
                               --p_po_prc_st                   in varchar2,
                               p_result                OUT SYS_REFCURSOR)
    IS
        l_rec_id      NUMBER;
        l_rec_code    VARCHAR2 (100);
        l_bnk_mfo     VARCHAR2 (10);
        --  l_msg_err   varchar2(4000);
        exNoBank      EXCEPTION;
        exNoBankMFO   EXCEPTION;
        exNoBankRec   EXCEPTION;
        l_rm_id       NUMBER;
        l_com_org     NUMBER;
    BEGIN
        GetRecCode (p_Cert_Serial      => p_cert_serial,
                    p_Cert_Issuer_Cn   => p_cert_issuer_cn,
                    p_rec_id           => l_rec_id,
                    p_rec_code         => l_rec_code,
                    p_rm_id            => l_rm_id,
                    p_com_org          => l_com_org);
    /*   -- якщо банк не визначено - повідомлення про помилку.
      if l_rec_code is null then
        raise exNoBank;
      else

    \*  -- Визначаємо МФО по коду одержувача з довідника банків ППВП :
      select max(b.psb_mfo) into l_bnk_mfo
      from ikis_ppvp.nsi_psb b
      where b.psb_rbm_code = l_rec_code;*\

      select \*max(r.rec_tp), max(r.rec_name),*\ max(r.rec_id) into \*l_rec_tp, l_rec_name,*\ l_rec_id
      from ikis_rbm.recipient r
      where r.rec_code = l_rec_code;

      if l_rec_id is null then
          raise exNoBankRec;
      end if;

        -- !!!!! для тестування, оскільки на глаші бардак з МФО ...
        -- перед установкою на пром/тест закоментувати !!!!!!
          -- if l_rec_code = 'TESTBANK1' then l_bnk_mfo := '300465'; end if;
          -- if l_rec_code = 'BANK197' then l_bnk_mfo := '354507'; end if;

    \*    if l_bnk_mfo is null then
          raise exNoBankMFO;
        end if;*\

        --dbms_output.put_line('l_rec_code='||l_rec_code) ;
        --dbms_output.put_line('l_bnk_mfo='||l_bnk_mfo) ;

        open p_result for
        select
          rr.rr_id, -- ID повідомлення про платіжне доручення повернення (RR_ID)
          rr.rr_po, -- ID платіжного доручення повернення (PO_ID)
          rr.rr_pd_num as rr_pd_num, -- Номер платіжного доручення (pd_num)
          rr.rr_pd_date as rr_pd_date, -- дата платіжного доручення (pd_date)
          rr.rr_pd_sum as rr_pd_sum, -- Загальна сума платіжного доручення (в копійках) - pd_sum
          rr.rr_pd_lines as rr_pd_lines, -- Загальна кількість рядків в файлі - pd_lines;
          rr.rr_st , -- Статус
          rs.dic_sname as rr_st_name
        from uss_esr.returns_reestr rr
        join ikis_rbm.v_packet p
          on  p.pkt_id = rr.rr_id_rbm
          and p.pkt_pat in (83)
          and pkt_st not in ('D')--in ('NVP', 'SND', 'RCV')
    \*    join uss_esr.exchangefiles fp
          on p.pkt_id = fp.ef_pkt
          and fp.ef_rec = l_rec_id
          and fp.ef_main_tag_name = 'post_pd_return'*\
        left join uss_ndi.v_ddn_rr_st rs
          on rs.DIC_VALUE = rr.rr_st
        where 1 = 1
          and p.pkt_rec = l_rec_id
          and (p_rr_pd_date_start is null or rr.rr_pd_date  >= p_rr_pd_date_start)
          and (p_rr_pd_date_stop is null or rr.rr_pd_date <= p_rr_pd_date_stop)
          and (p_rr_st is null or p_rr_st = rr.rr_st)
          ;
       end if;
    */
    EXCEPTION
        WHEN exNoBank
        THEN
            raise_application_error (-20000, 'Банк не визначено!');
        WHEN exNoBankMFO
        THEN
            raise_application_error (-20000,
                                     'Не вдалося визначити МФО банк!');
        WHEN exNoBankRec
        THEN
            raise_application_error (
                -20000,
                'Не вдалося визначити ідентифікувати  банк як відправника ПЕОД!');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка пошуку відомості: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_backtrace);
    END;


    -- перегляд деталей по завантаженому файлу:
    -- params: p_Cert_Serial – Серійний номер сертифікату
    --         p_Cert_Issuer_Cn – АЦСК сертифікату
    --         p_rr_id  - ід завантаженого реєстра повернення

    PROCEDURE GetPDReturnInfo (p_cert_serial      IN     VARCHAR2,
                               p_cert_issuer_cn   IN     VARCHAR2,
                               p_rr_id            IN     NUMBER,
                               p_result              OUT SYS_REFCURSOR)
    IS
        l_rec_id      NUMBER;
        l_rec_code    VARCHAR2 (100);
        l_bnk_mfo     VARCHAR2 (10);
        --  l_msg_err   varchar2(4000);
        exNoBank      EXCEPTION;
        exNoBankMFO   EXCEPTION;
        exNoBankRec   EXCEPTION;
        l_rm_id       NUMBER;
        l_com_org     NUMBER;
    BEGIN
        GetRecCode (p_Cert_Serial      => p_cert_serial,
                    p_Cert_Issuer_Cn   => p_cert_issuer_cn,
                    p_rec_id           => l_rec_id,
                    p_rec_code         => l_rec_code,
                    p_rm_id            => l_rm_id,
                    p_com_org          => l_com_org);
    /*   -- якщо банк не визначено - повідомлення про помилку.
      if l_rec_code is null then
        raise exNoBank;
      else

    \*  -- Визначаємо МФО по коду одержувача з довідника банків ППВП :
      select max(b.psb_mfo) into l_bnk_mfo
      from ikis_ppvp.nsi_psb b
      where b.psb_rbm_code = l_rec_code;*\

      select \*max(r.rec_tp), max(r.rec_name),*\ max(r.rec_id) into \*l_rec_tp, l_rec_name,*\ l_rec_id
      from ikis_rbm.recipient r
      where r.rec_code = l_rec_code;

      if l_rec_id is null then
          raise exNoBankRec;
      end if;

        -- !!!!! для тестування, оскільки на глаші бардак з МФО ...
        -- перед установкою на пром/тест закоментувати !!!!!!
          -- if l_rec_code = 'TESTBANK1' then l_bnk_mfo := '300465'; end if;
          -- if l_rec_code = 'BANK197' then l_bnk_mfo := '354507'; end if;

    \*    if l_bnk_mfo is null then
          raise exNoBankMFO;
        end if;*\

        --dbms_output.put_line('l_rec_code='||l_rec_code) ;
        --dbms_output.put_line('l_bnk_mfo='||l_bnk_mfo) ;

      open p_result for
        select
          rrl_num, -- порядковий номер - rownum;
          rrl_ln,  -- Прізвище - ln;
          rrl_fn,  -- Ім’я - nm;
          rrl_mn as rrl_ftn, -- По батькові - ftn;
          rrl_numident, -- РНОКПП - numident;
          rrl_ser_num, -- Серія та номер паспорту - ser_num;
          rrl_num_acc, -- Номер банківського рахунку вкладника - num_acc;
          rrl_num_or,  -- Номер особового рахунку пенсіонера - num_or;
          rrl_sum_return, --  Сума повернення - sum_return;
          rrl_rsn_return -- Причина повернення - rsn_return;
    --      rrl_st,  -- статус
    --      rs.dic_sname as rrl_st_name
        from uss_esr.rr_list rrl
    --    left join ST_RRL_ST rs   on rs.sv_id = rrl.rrl_st
        where 1 = 1
          and rrl.rrl_rr = p_rr_id
          ;
       end if;
    */
    EXCEPTION
        WHEN exNoBank
        THEN
            raise_application_error (-20000, 'Банк не визначено!');
        WHEN exNoBankMFO
        THEN
            raise_application_error (-20000,
                                     'Не вдалося визначити МФО банк!');
        WHEN exNoBankRec
        THEN
            raise_application_error (
                -20000,
                'Не вдалося визначити ідентифікувати  банк як відправника ПЕОД!');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка пошуку відомості: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_backtrace);
    END;
BEGIN
    NULL;
END API$ESR_BANKIR;
/