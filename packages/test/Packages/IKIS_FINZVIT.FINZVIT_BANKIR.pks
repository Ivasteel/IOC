/* Formatted on 8/12/2025 6:06:30 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_FINZVIT.FINZVIT_BANKIR
IS
    -- Author  : oivashchuk
    -- Created : 07.12.2020 20:48:49
    -- Purpose : відомості для кібінета банкіра

    -- info: 2.  пошук відомості
    -- params: p_Cert_Serial – Серійний номер сертифікату
    --         p_Cert_Issuer_Cn – АЦСК сертифікату
    --         p_pr_st - статус відомості
    --         p_pr_pay_dt_start - дата виплати з
    --         p_pr_pay_dt_stop  - по
    -- note: 2. Поиск ведомостей по параметрам:  - статус ведомости;  - дата выплаты (З-ПО);
    --         p_Organizations_Id – Організація (для кабінету банкіра = 3)
    PROCEDURE GetPayrollList (p_cert_serial       IN     VARCHAR2,
                              p_cert_issuer_cn    IN     VARCHAR2,
                              p_pr_st             IN     VARCHAR2,
                              p_pr_pay_dt_start   IN     DATE,
                              p_pr_pay_dt_stop    IN     DATE,
                              p_result               OUT SYS_REFCURSOR);

    -- info: 3. відображення атрибутів відомості
    -- params: p_payroll_id - идентификатор ведомости;
    -- note:   3. Отображение информации по ведомости с атрибутами ведомости
    PROCEDURE GetPayrollInfo (p_cert_serial      IN     VARCHAR2,
                              p_cert_issuer_cn   IN     VARCHAR2,
                              p_payroll_id       IN     NUMBER,
                              p_result              OUT SYS_REFCURSOR);

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
                                p_result              OUT SYS_REFCURSOR);

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


    -- info: Зміна статусів в реєстрі зі сторони ПЕОД (для пакетів відомостей, які  передаються через InfoCross)
    -- params: p_pkt_id - ід пакета ПЕОД;
    --         p_pkt_st - стату пакета ПЕОД
    -- note:  st_pr_st
    -- T Передано в пеод
    -- R Отримано банком
    -- P Платіж проведено
    -- C Платіж відхилено

    PROCEDURE SetPayrollStRbm (p_pkt_id IN NUMBER, p_pkt_st IN VARCHAR2);
END FINZVIT_BANKIR;
/


GRANT EXECUTE ON IKIS_FINZVIT.FINZVIT_BANKIR TO IKIS_RBM
/


/* Formatted on 8/12/2025 6:06:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_FINZVIT.FINZVIT_BANKIR
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


    -- info:-- визначаємо КОД реципієнта ПЕОД = Банк.разом з Authenticate_Internal.
    -- params: p_Cert_Serial – Серійний номер сертифікату
    --        p_Cert_Issuer_Cn – АЦСК сертифікату
    -- note:
    FUNCTION GetRecCode (p_cert_serial      IN VARCHAR2,
                         p_cert_issuer_cn   IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_rec_id     NUMBER;
        l_rec_code   VARCHAR2 (100);
    BEGIN
        --return p_cert_serial;
        -- визначаємо ід реципієнта ПЕОД = Банк. в тому числі і з Authenticate_Internal.
        l_rec_id :=
            IKIS_CMES.IKIS_CMES4RBM_FINZVIT.Get_User_Recipient (
                p_Cert_Serial        => p_cert_serial,
                p_Cert_Issuer_Cn     => p_cert_issuer_cn,
                p_Organizations_Id   => 3);

        -- якщо банк не визначено - повідомлення про помилку.
        IF l_rec_id IS NULL
        THEN
            RAISE exNoBank;
        ELSE
            SELECT r.rec_code
              INTO l_rec_code
              FROM ikis_rbm.recipient r
             WHERE rec_id = l_rec_id;

            IF l_rec_code IS NULL
            THEN
                RAISE exNoBank;
            END IF;
        END IF;

        RETURN l_rec_code;
    END;

    -- info: 2.  пошук відомості
    -- params: p_Cert_Serial – Серійний номер сертифікату
    --        p_Cert_Issuer_Cn – АЦСК сертифікату
    --         p_pr_st - статус відомості
    --         p_pr_pay_dt_start - дата виплати з
    --         p_pr_pay_dt_stop  - по
    -- note:   Поиск ведомостей по параметрам:  - статус ведомости;  - дата выплаты (З-ПО);
    --         p_Organizations_Id – Організація (для кабінету банкіра = 3)
    /*4.2. секция отображение ведомостей с полями (АПИ 3 от Сашка):
    - назва відомості; ЯК ПОСИЛАННЯ!!!
    - рік;
    - місяць;
    - загальна сума;
    - загальна кількість рядків;
    - статус;*/
    PROCEDURE GetPayrollList (--  p_organzation_id              in number,  = 3 банк
                              p_cert_serial       IN     VARCHAR2,
                              p_cert_issuer_cn    IN     VARCHAR2,
                              p_pr_st             IN     VARCHAR2,
                              p_pr_pay_dt_start   IN     DATE,
                              p_pr_pay_dt_stop    IN     DATE,
                              p_result               OUT SYS_REFCURSOR)
    IS
        l_rec_id     NUMBER;
        l_rec_code   VARCHAR2 (100);
        --  l_msg_err   varchar2(4000);
        exNoBank     EXCEPTION;
    BEGIN
        -- визначаємо код реципієнта ПЕОД = Банк. в тому числі і з Authenticate_Internal.
        l_rec_code :=
            GetRecCode (p_Cert_Serial      => p_cert_serial,
                        p_Cert_Issuer_Cn   => p_cert_issuer_cn);

        -- якщо банк не визначено - повідомлення про помилку.
        IF l_rec_code IS NULL
        THEN
            RAISE exNoBank;
        ELSE
            -- ??? користувачам КБ доступні всі типи запитів????
            /*  -- перевіряємо доступність запиту
              ikis_cmes.Ikis_Cmes4portal.Get_User_Req_Types();   */
            OPEN p_result FOR
                  SELECT pr.pr_src_entity
                             AS pr_payroll_id,     -- идентификатор ведомости;
                         pr.pr_name,                       -- назва відомості;
                         EXTRACT (YEAR FROM pr_pay_dt)
                             AS pay_year,                               -- рік
                         EXTRACT (MONTH FROM pr_pay_dt)
                             AS pay_month,                           -- місяць
                         --decode(pr.pr_tp, 0, 'Основна', 1, 'Коригуюча', 2, 'додаткова') as pr_tp, -- тип (основная, корегуюча; додаткова); тип відомості  0 – основна, 1 – коригуюча, 2 – додаткова
                         --decode(pr.pr_src, 0, 'ППВП', 1, 'ДКГ') as pr_src, -- подсистема (ППВП/ДКГ);  підсистема 0 – ппвп, 1 - дкг
                         --pr.com_org
                         --case when o.org_to = 3 then org_org else org_id end as com_org, -- орган ПФУ (область);
                         pr.pr_bnk_code,               /*pr.pr_filia_code,  */
                         pr.pr_bnk_mfo,
                         pr.pr_bnk_name, -- данные банка: (код банка, код филии, МФО банка, назва банка – или просто ид-к. Это я не знаю…);
                         --pr.pr_cat, -- категория – не знаю, что это и зачем?
                         ------ дата отримання відомості в банку;
                         SUM (pr.pr_row_cnt)
                             AS pr_row_cnt, -- загальна кількість рядків у списках (автосумма по информации по дням);
                         SUM (pr.pr_sum)
                             AS pr_sum, -- загальна сума, грн (автосумма по информации по дням);
                         pr.pr_st,
                         DECODE (pr.pr_st,
                                 'T', 'Передано в банк',
                                 'R', 'Отримано банком',
                                 'P', 'Платіж проведено',
                                 'C', 'Платіж відхилено')
                             AS pr_status,
                         DECODE (pr.pr_tp,
                                 0, 'Основна',
                                 1, 'Коригуюча',
                                 2, 'додаткова')
                             AS pr_tp,
                         MAX (
                             (SELECT MIN (prl_dt)
                                FROM ikis_finzvit.pr_log prl
                               WHERE     prl.prl_pr = pr.pr_id
                                     AND prl.prl_pr_st = 'R'))
                             AS pr_receive_dt, -- дата отримання відомості в банку;
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
                                                      THEN
                                                          pkt_id
                                                      ELSE
                                                          NULL
                                                  END)          AS pkt_encrypt_cnt
                                         FROM ikis_finzvit.payroll_reestr pr2
                                              JOIN ikis_rbm.packet p
                                                  ON p.pkt_id = pr2.pr_rbm_pkt
                                              JOIN ikis_rbm.packet_content pc
                                                  ON pc.pc_pkt = pr2.pr_rbm_pkt
                                        WHERE     pr2.pr_bnk_rbm_code =
                                                  l_rec_code
                                              AND pr2.pr_src_entity =
                                                  pr.pr_src_entity
                                       HAVING     COUNT (pc_pkt) =
                                                  COUNT (
                                                      CASE
                                                          WHEN     pkt_st IN
                                                                       ('NVP',
                                                                        'SND',
                                                                        'RCV')
                                                               AND pc.pc_encrypt_data
                                                                       IS NOT NULL
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
                         END
                             AS file_is_ready,
                         MAX (
                             CASE
                                 WHEN o.org_to = 3 THEN org_org
                                 ELSE org_id
                             END)
                             AS com_org, --pr.com_org, -- орган ПФУ (область);
                         MAX (
                             (SELECT MAX (o2.org_name)
                                FROM v_opfu o2
                               WHERE org_id =
                                     CASE
                                         WHEN o.org_to = 3 THEN o.org_org
                                         ELSE o.org_id
                                     END))
                             AS org_name
                    FROM ikis_finzvit.payroll_reestr pr
                         JOIN v_opfu o ON org_id = com_org
                   WHERE     pr.pr_bnk_rbm_code = l_rec_code
                         AND (p_pr_st IS NULL OR pr.pr_st = p_pr_st)
                         AND (   p_pr_pay_dt_start IS NULL
                              OR pr.pr_pay_dt >= p_pr_pay_dt_start)
                         AND (   p_pr_pay_dt_stop IS NULL
                              OR pr.pr_pay_dt < p_pr_pay_dt_stop + 1)
                GROUP BY pr.pr_src_entity,
                         pr.pr_bnk_code,                /* pr.pr_filia_code,*/
                         pr.pr_bnk_mfo,
                         pr.pr_bnk_name,
                         pr.pr_name,
                         EXTRACT (YEAR FROM pr_pay_dt),
                         EXTRACT (MONTH FROM pr_pay_dt),
                         pr.pr_st,
                         pr.pr_tp;
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
    --- орган ПФУ;
    --- статус;
    --- дата отримання відомості в банку;
    --- документи – посилання для завантаження відомостей на виплату пенсії (АПИ4);
    PROCEDURE GetPayrollInfo (p_cert_serial      IN     VARCHAR2,
                              p_cert_issuer_cn   IN     VARCHAR2,
                              p_payroll_id       IN     NUMBER,
                              p_result              OUT SYS_REFCURSOR)
    IS
        l_rec_id     NUMBER;
        l_rec_code   VARCHAR2 (100);
        exNoBank     EXCEPTION;
    BEGIN
        -- визначаємо код реципієнта ПЕОД = Банк. в тому числі і з Authenticate_Internal.
        l_rec_code :=
            GetRecCode (p_Cert_Serial      => p_cert_serial,
                        p_Cert_Issuer_Cn   => p_cert_issuer_cn);

        -- якщо банк не визначено - повідомлення про помилку.
        IF l_rec_code IS NULL
        THEN
            RAISE exNoBank;
        ELSE
            OPEN p_result FOR
                  SELECT pr.pr_src_entity
                             AS pr_payroll_id,     -- идентификатор ведомости;
                         pr.pr_name,                       -- назва відомості;
                         pr.pr_bnk_code,                 /*pr.pr_filia_code,*/
                         pr.pr_bnk_mfo,
                         pr.pr_bnk_name,
                         EXTRACT (YEAR FROM pr_pay_dt)
                             AS pay_year,                               -- рік
                         EXTRACT (MONTH FROM pr_pay_dt)
                             AS pay_month,                           -- місяць
                         SUM (pr.pr_row_cnt)
                             AS pr_row_cnt, -- загальна кількість рядків у списках (автосумма по информации по дням);
                         SUM (pr.pr_sum)
                             AS pr_sum, -- загальна сума, грн (автосумма по информации по дням);
                         pr.pr_st,
                         DECODE (pr.pr_st,
                                 'T', 'Передано в банк',
                                 'R', 'Отримано банком',
                                 'P', 'Платіж проведено',
                                 'C', 'Платіж відхилено')
                             AS pr_status,
                         DECODE (pr.pr_tp,
                                 0, 'Основна',
                                 1, 'Коригуюча',
                                 2, 'додаткова')
                             AS pr_tp,                          -- тип (основная, корегуюча; додаткова); тип відомості  0 – основна, 1 – коригуюча, 2 – додаткова
                         MAX (
                             (SELECT MIN (prl_dt)
                                FROM ikis_finzvit.pr_log prl
                               WHERE     prl.prl_pr = pr.pr_id
                                     AND prl.prl_pr_st = 'R'))
                             AS pr_receive_dt, -- дата отримання відомості в банку;
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
                                                      THEN
                                                          pkt_id
                                                      ELSE
                                                          NULL
                                                  END)          AS pkt_encrypt_cnt
                                         FROM ikis_finzvit.payroll_reestr pr
                                              JOIN ikis_rbm.packet p
                                                  ON p.pkt_id = pr.pr_rbm_pkt
                                              JOIN ikis_rbm.packet_content pc
                                                  ON pc.pc_pkt = pr.pr_rbm_pkt
                                        WHERE     pr.pr_bnk_rbm_code =
                                                  l_rec_code
                                              AND pr.pr_src_entity =
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
                         END
                             AS file_is_ready,
                         CASE WHEN o.org_to = 3 THEN org_org ELSE org_id END
                             AS com_org, --pr.com_org, -- орган ПФУ (область);
                         MAX (
                             (SELECT MAX (o2.org_name)
                                FROM v_opfu o2
                               WHERE org_id =
                                     CASE
                                         WHEN o.org_to = 3 THEN o.org_org
                                         ELSE o.org_id
                                     END))
                             AS org_name
                    FROM ikis_finzvit.payroll_reestr pr
                         JOIN v_opfu o ON org_id = com_org
                   WHERE     pr.pr_bnk_rbm_code = l_rec_code
                         AND pr.pr_src_entity = p_payroll_id
                GROUP BY pr.pr_src_entity,
                         pr.pr_bnk_code,                /* pr.pr_filia_code,*/
                         pr.pr_bnk_mfo,
                         pr.pr_bnk_name,
                         EXTRACT (YEAR FROM pr_pay_dt),
                         EXTRACT (MONTH FROM pr_pay_dt),
                         pr.pr_name,
                         pr.pr_tp,
                         pr.pr_st,
                         CASE WHEN o.org_to = 3 THEN org_org ELSE org_id END;
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
    BEGIN
        -- визначаємо код реципієнта ПЕОД = Банк. в тому числі і з Authenticate_Internal.
        l_rec_code :=
            GetRecCode (p_Cert_Serial      => p_cert_serial,
                        p_Cert_Issuer_Cn   => p_cert_issuer_cn);

        -- якщо банк не визначено - повідомлення про помилку.
        IF l_rec_code IS NULL
        THEN
            RAISE exNoBank;
        ELSE
            FOR pkt
                IN (SELECT pc_pkt,
                           pc.pc_encrypt_data,
                           pc.pc_name || '_' || pc.pc_pkt || '.p7e'    AS pc_file_name
                      FROM ikis_finzvit.payroll_reestr  pr
                           JOIN ikis_rbm.packet_content pc
                               ON pc.pc_pkt = pr.pr_rbm_pkt
                           JOIN ikis_rbm.packet p ON p.pkt_id = pr.pr_rbm_pkt
                     WHERE     pr.pr_bnk_rbm_code = l_rec_code
                           AND pr.pr_src_entity = p_payroll_id
                           AND pc.pc_encrypt_data IS NOT NULL
                           AND p.pkt_st IN ('NVP', 'SND', 'RCV'))
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
        \*    insert into pr_log(prl_id, prl_pr, prl_pr_st, prl_action, prl_user, prl_dt)
            values(null, pr_rec.pr_id, 'R', 'S', null, sysdate);*\

            -- видаємо  архів
            open p_result for
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
    -- дата; кол-во людей за день; общая сумма за день // ПОЗЖЕ еще добавим статус получения банком платежа от ПФУ за этот день – сейчас НЕ НАВОРАЧИВАЕМ этим
    --6.2 отображение грида с данніми:
    -- дата;
    -- загальна сума за день;
    -- загальна кількість рядків за день;
    PROCEDURE GetPayrollReestr (p_cert_serial      IN     VARCHAR2,
                                p_cert_issuer_cn   IN     VARCHAR2,
                                p_payroll_id       IN     NUMBER,
                                p_result              OUT SYS_REFCURSOR)
    IS
        l_rec_id     NUMBER;
        l_rec_code   VARCHAR2 (100);
        exNoBank     EXCEPTION;
    BEGIN
        -- визначаємо код реципієнта ПЕОД = Банк. в тому числі і з Authenticate_Internal.
        l_rec_code :=
            GetRecCode (p_Cert_Serial      => p_cert_serial,
                        p_Cert_Issuer_Cn   => p_cert_issuer_cn);

        -- якщо банк не визначено - повідомлення про помилку.
        IF l_rec_code IS NULL
        THEN
            RAISE exNoBank;
        ELSE
            OPEN p_result FOR
                  SELECT pr.pr_src_entity,         -- идентификатор ведомости;
                         pr_pay_dt,                            -- дата виплати
                         SUM (pr.pr_sum)         AS pr_sum, -- загальна сума за день, грн;
                         SUM (pr.pr_row_cnt)     AS pr_row_cnt -- загальна кількість рядків за день у списках
                    FROM ikis_finzvit.payroll_reestr pr
                   WHERE     pr.pr_bnk_rbm_code = l_rec_code
                         AND pr.pr_src_entity = p_payroll_id
                GROUP BY pr.pr_src_entity, pr_pay_dt;
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
        l_rec_id     NUMBER;
        l_rec_code   VARCHAR2 (100);
        exNoBank     EXCEPTION;
        l_err_msg    VARCHAR2 (4000);
    BEGIN
        -- визначаємо код реципієнта ПЕОД = Банк. в тому числі і з Authenticate_Internal.
        l_rec_code :=
            GetRecCode (p_Cert_Serial      => p_cert_serial,
                        p_Cert_Issuer_Cn   => p_cert_issuer_cn);

        -- якщо банк не визначено - повідомлення про помилку.
        IF l_rec_code IS NULL
        THEN
            RAISE exNoBank;
        ELSE
            FOR pr_rec
                IN (SELECT pr.pr_id, pr.pr_rbm_pkt
                      FROM ikis_finzvit.payroll_reestr pr
                     WHERE     pr.pr_bnk_rbm_code = l_rec_code
                           AND pr.pr_src_entity = p_payroll_id
                           AND pr.pr_st = 'T')
            LOOP
                UPDATE ikis_finzvit.payroll_reestr pr
                   SET pr_st = 'R'
                 WHERE pr.pr_id = pr_rec.pr_id AND pr.pr_st = 'T';

                INSERT INTO pr_log (prl_id,
                                    prl_pr,
                                    prl_pr_st,
                                    prl_action,
                                    prl_user,
                                    prl_dt)
                     VALUES (NULL,
                             pr_rec.pr_id,
                             'R',
                             'S',
                             NULL,
                             SYSDATE);

                -- оновлюємо статус пакетів в ПЕОД
                BEGIN
                    ikis_rbm.ikis_rbm_finzvit.set_pkt_received (
                        p_pkt_id           => pr_rec.pr_rbm_pkt,
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

                        INSERT INTO pr_log (prl_id,
                                            prl_pr,
                                            prl_pr_st,
                                            prl_action,
                                            prl_user,
                                            prl_dt,
                                            prl_info)
                             VALUES (NULL,
                                     pr_rec.pr_id,
                                     'R',
                                     'S',
                                     NULL,
                                     SYSDATE,
                                     l_err_msg);
                END;
            END LOOP;
        END IF;
    EXCEPTION
        WHEN exNoBank
        THEN
            raise_application_error (-20000, 'Банк не визначено!');
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
    BEGIN
        -- визначаємо код реципієнта ПЕОД = Банк. в тому числі і з Authenticate_Internal.
        l_rec_code :=
            GetRecCode (p_Cert_Serial      => p_cert_serial,
                        p_Cert_Issuer_Cn   => p_cert_issuer_cn);

        -- якщо банк не визначено - повідомлення про помилку.
        IF l_rec_code IS NULL
        THEN
            RAISE exNoBank;
        ELSE
            SELECT pc.pc_encrypt_data,
                   pc.pc_name || '_' || pc.pc_pkt || '.p7e'    AS pc_file_name
              INTO p_pkt_data, p_pkt_name
              FROM ikis_finzvit.payroll_reestr  pr
                   JOIN ikis_rbm.packet_content pc
                       ON pc.pc_pkt = pr.pr_rbm_pkt
                   JOIN ikis_rbm.packet p ON p.pkt_id = pr.pr_rbm_pkt
             WHERE     pr.pr_bnk_rbm_code = l_rec_code
                   AND pr.pr_rbm_pkt = p_rbm_pkt_id
                   AND pc.pc_encrypt_data IS NOT NULL
                   AND p.pkt_st IN ('NVP', 'SND', 'RCV');
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


    -- info: Зміна статусів в реєстрі зі сторони ПЕОД (для пакетів відомостей, які  передаються через InfoCross)
    -- params: p_pkt_id - ід пакета ПЕОД;
    --         p_pkt_st - стату пакета ПЕОД
    -- note:  st_pr_st
    -- T Передано в пеод
    -- R Отримано банком
    -- P Платіж проведено
    -- C Платіж відхилено

    PROCEDURE SetPayrollStRbm (p_pkt_id IN NUMBER, p_pkt_st IN VARCHAR2)
    IS
        l_rec_id     NUMBER;
        l_rec_code   VARCHAR2 (100);
        exNoBank     EXCEPTION;
        l_err_msg    VARCHAR2 (4000);
        l_pr_st      VARCHAR2 (10);
    BEGIN
        IF p_pkt_st = 'RCV'
        THEN
            FOR pr_rec
                IN (SELECT pr.pr_id, pr.pr_rbm_pkt
                      FROM ikis_finzvit.payroll_reestr pr
                     WHERE pr.pr_rbm_pkt = p_pkt_id AND pr.pr_st = 'T')
            LOOP
                UPDATE ikis_finzvit.payroll_reestr pr
                   SET pr_st = 'R'
                 WHERE pr.pr_id = pr_rec.pr_id AND pr.pr_st = 'T';

                INSERT INTO pr_log (prl_id,
                                    prl_pr,
                                    prl_pr_st,
                                    prl_action,
                                    prl_user,
                                    prl_dt)
                     VALUES (NULL,
                             pr_rec.pr_id,
                             'R',
                             'RCV',
                             NULL,
                             SYSDATE);
            END LOOP;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            --raise_application_error(-20000, 'Помилка зміни статусу відомості: '||sqlerrm||chr(10)||dbms_utility.format_error_backtrace);
            NULL;
    END;
BEGIN
    NULL;
END FINZVIT_BANKIR;
/