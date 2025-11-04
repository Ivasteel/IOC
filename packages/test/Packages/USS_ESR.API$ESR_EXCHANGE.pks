/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$ESR_EXCHANGE
IS
    -- Author  : oivashchuk
    -- Created : 18.02.2021 10:22:49
    -- Purpose : обмін з банками

    -- Скорочення назви органу
    --function get_org_sname(p_org_name varchar2) return varchar2;

    -- info:  Формування пакетів "конверт з реєстром списків по платіжному дорученню" в ПЕОД
    -- params: p_po_id – ід ПД
    -- note:

    FUNCTION GetFiliaFile (p_pr_id          NUMBER,
                           p_nb_id          NUMBER,
                           --p_nb_number VARCHAR2,
                           --p_nb_filia  VARCHAR2,
                           p_prs_pay_dt     DATE,
                           --p_prs_num     NUMBER,
                           p_bnk_cnt        NUMBER,
                           p_bnk_sum        NUMBER,
                           p_convert_symb   VARCHAR2:= 'F',
                           p_pr_code        VARCHAR2:= '00')
        RETURN CLOB;

    -- IC #98707
    FUNCTION getPostFile (p_org_code       NUMBER,
                          p_npo_index      VARCHAR2,
                          p_pr_type        VARCHAR2:= '78',
                          p_filename       VARCHAR2:= '',
                          p_convert_symb   VARCHAR2:= 'F')
        RETURN CLOB;

    FUNCTION BuildAccompSheet_html (
        p_po_id    pay_order.po_id%TYPE,
        p_pr_id    payroll.pr_id%TYPE,
        p_prs_tp   pr_sheet.prs_tp%TYPE,
        --p_prs_nb    pr_sheet.prs_nb%type := null,
        --p_prs_num pr_sheet.prs_num%type := 0,
        p_format   INT:= 14,
        p_nb_id    uss_ndi.v_ndi_bank.nb_id%TYPE:= NULL, -- oivashchuk 20160225 #14354
        p_nb_num   uss_ndi.v_ndi_bank.nb_num%TYPE:= NULL,
        p_nb_mfo   uss_ndi.v_ndi_bank.nb_mfo%TYPE:= NULL)
        RETURN BLOB;

    -- info:  Формування XML пакетів ВВ в ПЕОД
    -- params: p_pr_id – ід ВВ, p_prs_tp - тип виплати,  p_nb_id - ыд банку
    --         p_convert_symb
    -- note:
    PROCEDURE BuildBankExchFiles (
        p_po_id          pay_order.po_id%TYPE,
        p_pr_id          payroll.pr_id%TYPE,
        p_prs_tp         pr_sheet.prs_tp%TYPE,
        p_nb_id          uss_ndi.v_ndi_bank.nb_id%TYPE:= NULL,
        --p_prs_num    pr_sheet.prs_num%TYPE := 0,
        p_convert_symb   VARCHAR2:= 'F'---p_show_migr    varchar2 := 'F'
                                       );

    --   #87334 Обмін з кабінетом банку (допомоги крім ВПО)
    PROCEDURE BuildExchFilesByPo (p_po_id payroll.pr_id%TYPE);

    -- info:  Формування Json пакетів ВВ в ПЕОД.
    -- params: p_po_id – ід ПД, p_pr_id – ід ВВ, p_prs_tp - тип виплати,  p_nb_id - ід банку
    -- note:
    PROCEDURE BuildJsonExchFiles (
        p_po_id    pay_order.po_id%TYPE,
        p_pr_id    payroll.pr_id%TYPE,
        p_prs_tp   pr_sheet.prs_tp%TYPE,
        p_nb_id    uss_ndi.v_ndi_bank.nb_id%TYPE:= NULL);

    -- info:  Формування пакетів зі списками соцвиплат (по ВВ ЄСР) в ПЕОД
    -- params: p_pr_id – ід ВВ, p_prs_tp - тип виплати,  p_nb_id - ід банку
    -- note:  Викликати при фіксації ПД в DNET$PAYMENT_ANALITIC.FIX_SELECTED_ORDERS
    PROCEDURE BuildJsonpktByPo (p_po_id payroll.pr_id%TYPE);

    -- info:  Видалення невідправлених пакетів з ПЕОД
    -- params: p_po_id – ід ПД
    -- note: При натисканні кнопки "Розфіксувати" перевіряється статус пакетів ПЕОД, пов'язаних з цим ПД.
    --    Якщо статус "Новий" або "Підписано" - пакет переводиться в статус "Видалено"
    --    Якщо статус "Відправлено" то користувачу надається повідомлення "Не можливо розфіксувати, оскільки реєстри по цьому документу відправлені в банк".
    PROCEDURE DelPoPackets (p_po_id NUMBER);

    PROCEDURE GenRv2PdPackets (p_po_id NUMBER);

    -- info:  Масове Формування пакетів "конверт з реєстром списків по платіжному дорученню" в ПЕОД
    -- params: p_po_list – список ід ПД через кому
    --         p_err_msg - список ПД з помилками формування реєстра.
    -- note:  реєстр в ПЕОД формується для ПД зі списку, статус яких = 'APPR' і які ще не вивантажувалися в ПЕОД
    PROCEDURE GenRv2PdPacketsMass (p_po_list       VARCHAR2,
                                   p_err_msg   OUT VARCHAR2);

    -- info:  Формування пакетів КВ-1 та КВ-2 (PCA, PPR) в ПЕОД
    -- params: p_rbm_pkt_id – ід пакета ВВ в ПЕОД
    --         p_pkt_tp     - тип пакета, що формується
    --         p_filia_name - Назва філії
    --         p_pkt_info   - опис пакета для візуалізації в ПЕОД
    --         p_pkt_blob   - шифрований файл пакета
    -- note:
    PROCEDURE GenKVPackets (                     --p_rbm_pkt_id     in number,
                            p_payroll_id      IN     NUMBER,
                            p_pkt_tp          IN     VARCHAR2,
                            p_pkt_name        IN     VARCHAR2,
                            p_pkt_blob        IN     BLOB,
                            p_pkt_encr_blob   IN     BLOB,
                            p_message            OUT VARCHAR2);

    PROCEDURE GenKVPackets82 (p_rbm_pkt_id   NUMBER,
                              p_pkt_tp       VARCHAR2,
                              p_po_id        NUMBER,
                              p_po_result    NUMBER,
                              p_pkt_info     CLOB,
                              p_pkt_blob     BLOB);

    -- конверт ВВ по пекету ПЕОД з штфрованими даними
    FUNCTION GetConvert (p_id NUMBER, p_recipient_code VARCHAR2)
        RETURN CLOB;

    -- 67448  Процедура перевірки та встановлення статусу "видалено" ресєтру по ПД в ПЕОД
    PROCEDURE SetPoReestrDel (p_po_id IN NUMBER, --p_pkt_id  out number,
                                                 --p_pkt_st  out varchar2,
                                                 p_msg OUT VARCHAR2);

    -- info:  #67535 Вивантаження реєстру відомостей по ПД в csv
    -- params: p_po_id  – ід ПД
    --         p_fname  - назва файлу архіва з csv
    --         p_result - zip - архів з csv
    -- note:  Формування Csv звіту по ПД //// замість вивантаження пакетів "конверт з реєстром списків по платіжному дорученню" в ПЕОД
    PROCEDURE GenRv2PdCsv (p_po_id    IN     NUMBER,
                           p_fname       OUT VARCHAR2,
                           p_result      OUT BLOB);

    -- 67448  Процедура перевірки можливості видалення реєстру по ПД в ПЕОД
    -- p_can_del -  0/1  = видалення заборонено /  дозволено
    PROCEDURE CheckPoReestrDel (p_po_id IN NUMBER, p_can_del OUT NUMBER);

    -- 10.  СЕРВІС «ПОВІДОМЛЕННЯ БАНКУ ПРО ПЛАТІЖНЕ ДОРУЧЕННЯ ПОВЕРНЕННЯ КОШТІВ З РАХУНКІВ ПЕНСІОНЕРІВ» (POST_PD_RETURN)
    PROCEDURE PostPDReturn (p_pkt_rec_code    IN     VARCHAR2,
                            p_pkt_name        IN     VARCHAR2,
                            p_pkt_blob        IN     BLOB,
                            p_pkt_encr_blob   IN     BLOB,
                            p_message            OUT VARCHAR2);

    -- info:  67730 Обробка невиплат КВ-2
    -- params: p_pkt_rec_code  – Код запитувача ПЕОД
    --         p_pkt_id        - Ід пакета ПЕОД
    --         p_pkt_xml       - xml-вміст блоку "report_data" КВ-2
    PROCEDURE ProcPPRReturn (p_pkt_rec_code   IN VARCHAR2,
                             p_pkt_id         IN NUMBER,
                             p_pkt_xml        IN XMLTYPE);

    -- info: Задача #67447 Фіксація дати та статусу опрацювання ресєстру
    -- params: p_pkt_id        - Ід пакета ПЕОД
    PROCEDURE SetPoBankGetDt (p_pkt_id IN NUMBER);

    --Задача #68327 Пошук ПД при завантаженні реєстрів повернення / КВ-2
    PROCEDURE SetReturnReestrPo (p_rr_id IN NUMBER DEFAULT NULL);

    -- Задача #68510 Ідентифікація пенсіонера в ППВП
    PROCEDURE GetRrlPnfPpvp (p_rr_id IN NUMBER);

    --Задача #68565  Функція пошуку Реєстрів повернень та ідентифікація в ППВП
    PROCEDURE SetPoReturnReestr (p_po_id IN NUMBER);

    -- io 20220727  Обробка пакета КВ-1 post_convert_answer
    PROCEDURE proc_pca_pkt (p_pkt_id IN NUMBER);

    -- io 20220727  Обробка пакета КВ-2 post_payment_reply
    PROCEDURE proc_ppr_pkt (p_pkt_id IN NUMBER);

    -- IC #97478 Обробка квитанції повернення від пошти
    PROCEDURE proc_kpp_pkt (p_pkt_id IN NUMBER);

    --  Процедура автоматичної обробки КВ-1
    PROCEDURE RunProcessPCA;

    -- Процедура автоматичної обробки КВ-2
    PROCEDURE RunProcessPPR;

    -- Процедура обробки КВ-1/2
    PROCEDURE ProcessKV (p_pkt_id IN NUMBER);

    -- #81531 Формування відомостей на Поштув електронному вигляді по 6 допомогам
    PROCEDURE BuildPostFiles (p_pr_ids IN VARCHAR2, p_rpt IN OUT BLOB);

    -- IC #98707 Пакетна обробка відомостей на пошту по типу відомості
    PROCEDURE BuildPostFiles (p_pr_ids     IN     VARCHAR2,
                              p_pkt_type   IN     VARCHAR2 := '80',
                              o_rpt           OUT BLOB);

    -- IC #110218 Вивантаження файлів для пошти з Платіжної інструкції
    PROCEDURE BuildPostFilesPO (p_po_ids IN VARCHAR2, o_rpt OUT BLOB);

    --  #81330 Формування відомостей на банк в електронному вигляді по 6 допомогам
    --  Без запису в ПЕОД, фактично це звіт...
    PROCEDURE BuildBankFiles (p_pr_ids                VARCHAR2,
                              p_convert_symb          VARCHAR2 DEFAULT 'T',
                              p_rpt            IN OUT BLOB);

    -- IC #98707 Формування пакету по виплаті по пошті
    PROCEDURE BuildPostExchFiles (p_pr_id          payroll.pr_id%TYPE,
                                  p_prs_tp         pr_sheet.prs_tp%TYPE:= 'PP',
                                  p_convert_symb   VARCHAR2:= 'F');

    -- IC #98707 Формування пакету по виплаті по пошті (отримання файлу без відправки ПЕОД)
    PROCEDURE BuildPostExchFiles (p_pr_id          IN     payroll.pr_id%TYPE,
                                  p_pkt_tp         IN     VARCHAR2 := '78',
                                  p_convert_symb   IN     VARCHAR2 := 'F',
                                  o_rpt               OUT BLOB);

    -- IC #111345 Формування пакету по виплаті по пошті (в кабінет банку)
    PROCEDURE BuildPostExchFiles (p_po_id          pay_order.po_id%TYPE,
                                  p_pr_id          payroll.pr_id%TYPE,
                                  p_prs_tp         pr_sheet.prs_tp%TYPE,
                                  p_rec_id         NUMBER:= 150, -- АТ "УКРПОШТА"
                                  p_convert_symb   VARCHAR2:= 'F');
END API$ESR_EXCHANGE;
/


/* Formatted on 8/12/2025 5:49:03 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$ESR_EXCHANGE
IS
    exNoBank   EXCEPTION;

    -- info:  Формування текстового файла для пакетів ВВ на банк.   для 6 допомог
    -- params: p_pr_id – ід ВВ
    --         p_nb_id - ід банку
    -- note:  #86609 Повернути старе формування заголовків на рядків файлу (замість МФО - код банку, код філії вказуємо з поля uss_ndi.ndi_pay_person_acc.dppa_nb_filia_num) (тільки цифри)
    FUNCTION GetFiliaFile (p_pr_id          NUMBER,
                           p_nb_id          NUMBER,
                           p_prs_pay_dt     DATE,
                           p_bnk_cnt        NUMBER,
                           p_bnk_sum        NUMBER,
                           p_convert_symb   VARCHAR2:= 'F',
                           p_pr_code        VARCHAR2:= '00')
        RETURN CLOB
    IS
        l_header            VARCHAR2 (500);
        l_header_conv       VARCHAR2 (500);
        l_row               VARCHAR2 (500);
        l_rez               CLOB;
        l_data              BLOB;
        l_use_iban          VARCHAR2 (10) := 'T'; --nvl(tools.GP('USE_IBAN',sysdate), 'F');
        l_acc_length_head   NUMBER;
        l_acc_length_rows   NUMBER;
        l_row_fill          VARCHAR2 (1);
        l_pr_tp             VARCHAR2 (10);
        l_bank_iban         VARCHAR2 (29);
        l_uss_iban          VARCHAR2 (29);
        l_uss_mfo           VARCHAR2 (10);
        l_pr_code           VARCHAR2 (10);
        l_nbg_id            NUMBER;
    BEGIN
        l_acc_length_head := CASE WHEN l_use_iban = 'T' THEN 29 ELSE 9 END;
        l_acc_length_rows := CASE WHEN l_use_iban = 'T' THEN 29 ELSE 19 END;
        l_row_fill := CASE WHEN l_use_iban = 'T' THEN '0' ELSE ' ' END;

        DBMS_LOB.createtemporary (lob_loc => l_data, cache => TRUE);
        DBMS_LOB.open (lob_loc => l_data, open_mode => DBMS_LOB.lob_readwrite);

        SELECT MAX (t.npt_nbg), LPAD (MAX (npc_code), 2, '0')
          INTO l_nbg_id, l_pr_code
          FROM payroll  pr
               JOIN uss_ndi.v_ndi_payment_type t
                   ON t.npt_npc = pr_npc AND t.history_status = 'A'
               JOIN uss_ndi.v_ndi_payment_codes с
                   ON с.npc_id = pr_npc AND t.history_status = 'A'
         WHERE pr_id = p_pr_id;

        -- банк платник
        BEGIN
            SELECT nppa.dppa_account, b.nb_mfo
              INTO l_uss_iban, l_uss_mfo
              FROM uss_ndi.v_ndi_pay_person  p
                   JOIN uss_ndi.v_ndi_pay_person_acc nppa
                       ON (nppa.dppa_dpp = p.dpp_id)
                   JOIN uss_ndi.v_ndi_bank b ON nb_id = nppa.dppa_nb
             WHERE     p.dpp_tp = 'OSZN'
                   AND p.dpp_org = uss_ndi.tools.getcurrorg
                   AND p.history_status = 'A'
                   AND nppa.history_status = 'A'
                   AND nppa.dppa_nbg = l_nbg_id;
        EXCEPTION
            WHEN OTHERS
            THEN
                l_uss_iban := '';
                l_uss_mfo := '';
        END;

        -- Банк одерджувач
        SELECT MAX (nppa.dppa_account)
          INTO l_bank_iban
          FROM uss_ndi.V_NDI_FIN_PAY_CONFIG  fpc
               JOIN uss_ndi.v_ndi_pay_person_acc nppa
                   ON nppa.dppa_id = fpc.nfpc_dppa
         WHERE     1 = 1
               AND fpc.history_status = 'A'
               AND nppa.history_status = 'A'
               AND fpc.nfpc_nb = p_nb_id
               AND nppa.dppa_nbg = l_nbg_id
               AND fpc.com_org = uss_ndi.tools.getcurrorg;

        -- #86609 код філії вказуємо з поля uss_ndi.ndi_pay_person_acc.dppa_nb_filia_num
        --   #82683 io 20230102  номер підзвітної філії - такий самий як центральної філії
        SELECT MAX ( --tools.PR(substr(x_nb_mfo, -6), 6)||'0000'||tools.PR(l_pr_code, 2)||'.'||
 -- #86609 код філії вказуємо з поля uss_ndi.ndi_pay_person_acc.dppa_nb_filia_num
                      tools.PR (x_nb_number, 5)
                   || tools.PR (NVL (x_nb_filia, x_nb_number), 5)
                   || tools.PR (x_prs_pay_dt, 2)
                   || '.'
                   || tools.PR (x_opfu, 3)
                   || DECODE (l_use_iban, 'T', '408', '368')
                   || tools.PR (TO_CHAR (SYSDATE, 'dd/mm/yy'), 8)
                   || tools.PR (TRIM (TO_CHAR (p_bnk_cnt, '000000')), 6)
                   || LPAD (NVL (l_uss_mfo, '0'), 9, '0')
                   || LPAD (NVL (l_uss_iban, '0'), l_acc_length_head, '0')
                   || LPAD (NVL (x_nb_mfo, 0), 9, '0')
                   || LPAD (NVL (l_bank_iban, '0'), l_acc_length_head, '0')
                   || ' '
                   || tools.PR (
                          TRIM (TO_CHAR (p_bnk_sum, '0000000000000000000')),
                          19)
                   || --case when nvl(p_pr_code, '00') = '00' or length(p_pr_code) < 2 then '01' else substr(p_pr_code, -2) end|| --'01'||
                      tools.PR (l_pr_code, 2)                         /*'01'*/
                   || LPAD (' ', 10, ' ')
                   || ' '
                   || tools.PR ( /*DNET$RPT_MATRIX.get_org_sname(b_opfu_name)*/
                                b_org_code, 27)
                   ||                                    -- Коротка назва ОСЗН
                      tools.PR (NVL (x_nb_main_code, ' '), 27)
                   ||                                       -- не заповнюється
                      tools.PR (                               /*b_pr_header*/
                                'ВИПЛАТА ДОПОМОГ'           /*||dat.npc_code*/
                                                 , 160)
                   ||                                                              -- #81330
                      tools.PL (NVL (x_nb_filia,               /*x_nb_number*/
                                                 ' '), 5)
                   || -- не заповнюється -- #86609 код філії вказуємо з поля uss_ndi.ndi_pay_person_acc.dppa_nb_filia_num
                      tools.PR (' ', 45)
                   || CHR (13)
                   || CHR (10)),                           -- #81330   46 ==>>
               MAX (pr_tp)
          INTO l_header, l_pr_tp
          FROM TMP_BANK_TO_EXPORT  t,
               (SELECT SUBSTR (TRIM (TO_CHAR (org_id, '000009')), 1, 3)
                           AS b_opfu,
                       SUBSTR (TOOLS.GetOrgSName (o.org_id), 1, 27)
                           AS b_opfu_name,
                       c.npc_name
                           AS b_pr_header,
                       pr_tp,
                       c.npc_code,
                       o.org_id
                           AS b_org_code
                  FROM payroll, v_opfu o, uss_ndi.v_ndi_payment_codes c
                 WHERE     1 = 1
                       AND pr_id = p_pr_id
                       AND com_org = org_id
                       AND c.npc_id = pr_npc) dat
         WHERE 1 = 1 AND x_nb_id = p_nb_id AND x_prs_pay_dt = p_prs_pay_dt;

        l_header_conv :=
            CONVERT (tools.ReplUKRSmb2Dos (l_header, p_convert_symb),
                     'RU8PC866',
                     'CL8MSWIN1251');

        DBMS_LOB.writeappend (
            l_data,
            DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_header_conv)),
            UTL_RAW.cast_to_raw (l_header_conv));

        FOR cc
            IN (SELECT *
                  FROM TMP_BANK_TO_EXPORT
                 WHERE     1 = 1
                       AND x_nb_id = p_nb_id
                       AND x_prs_pay_dt = p_prs_pay_dt)
        LOOP
            l_row :=
                   LPAD (NVL (cc.x_prs_account, l_row_fill),
                         l_acc_length_rows,
                         l_row_fill)
                ||        --tools.PR(cc.x_prs_account, /*19*/ l_acc_length )||
                   tools.PR (                               /*cc.x_nb_number*/
                             cc.x_nb_filia, 5)
                ||                                             -- Не заполнять
                   '028'
                || tools.PR (
                       TRIM (
                           TO_CHAR (cc.x_prs_sum * 100,
                                    '0000000000000000000')),
                       19)
                || tools.PL (cc.x_prs_pib, 100)
                || tools.PL (cc.x_prs_inn, 10)
                || tools.PR (                              /*cc.x_prs_pay_dt*/
                             '00', 2)
                || -- дату виплати по допомогам замінити на 00 (в друкованій та електронній формі)
                   tools.PR (NVL (cc.x_is_migr, '0'), 1)
                ||                           --1- особа ВПО     0-особа не ВПО
                   CHR (13)
                || CHR (10);    -- 20210326 прибрав склейку останнього пробіла
            l_row :=
                CONVERT (tools.ReplUKRSmb2Dos (l_row, p_convert_symb),
                         'RU8PC866',
                         'CL8MSWIN1251');
            DBMS_LOB.writeappend (
                l_data,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_row)),
                UTL_RAW.cast_to_raw (l_row));
        END LOOP;

        l_rez := tools.ConvertB2C (l_data);
        RETURN l_rez;
    END GetFiliaFile;

    -- IC
    FUNCTION getPostFile (p_org_code       NUMBER,
                          p_npo_index      VARCHAR2,
                          p_pr_type        VARCHAR2:= '78',
                          p_filename       VARCHAR2:= '',
                          p_convert_symb   VARCHAR2:= 'F')
        RETURN CLOB
    IS
        l_row    VARCHAR2 (1024);
        l_rez    CLOB;
        l_data   BLOB;
        l_zip    BLOB;
    BEGIN
        DBMS_LOB.createtemporary (lob_loc => l_data, cache => TRUE);
        DBMS_LOB.open (lob_loc => l_data, open_mode => DBMS_LOB.lob_readwrite);

        FOR c
            IN (SELECT t.*,
                       SUM (t_pp_sum) OVER ()                               sum_total,
                       COUNT (*) OVER ()                                    cnt_total,
                       ROW_NUMBER () OVER (ORDER BY t_prs_num, t_prs_pc)    rn
                  FROM TMP_POST_TO_EXPORT t
                 WHERE t_npo_index = p_npo_index AND t_org_code = p_org_code)
        LOOP
            -- Заголовок (без розділювачів)
            IF c.rn = 1
            THEN
                l_row :=
                       LPAD (c.t_org_code, 5, 0)          -- Код району 5 цифр
                    || LPAD (TO_CHAR (c.t_per_num), 2, '0') -- Номер періоду 2 цифри
                    || LPAD (TO_CHAR (c.t_day_start), 2, '0') -- День початку виплати 2 цифри
                    || LPAD (TO_CHAR (c.t_day_stop), 2, '0') -- День закінчення виплати 2 цифри
                    || LPAD (TO_CHAR (c.t_per_month), 2, '0') -- Місяць виплати 2 цифри
                    || LPAD (TO_CHAR (c.t_per_year), 4, '0') -- Рік виплати 4 цифри
                    || LPAD (p_pr_type, 2, '0')       -- Тип відомості 2 цифри
                    || LPAD (c.t_ved_tp, 2, '0')        -- Вид виплати 2 цифри
                    || LPAD (c.sum_total, 15, '0') -- Загальна сума по району 15 цифр
                    || LPAD (c.cnt_total, 6, '0') -- Кількість отримувачів 6 цифр
                    || CHR (13)
                    || CHR (10);

                DBMS_LOB.writeappend (
                    l_data,
                    DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_row)),
                    UTL_RAW.cast_to_raw (l_row));
            END IF;

            -- Інформаційні рядки  (Розподілювач – «,» (кома)
            l_row :=
                   LPAD (c.t_ncn_code, 2, '0')        -- Вузол зв'язку 2 цифри
                || ','
                || LPAD (c.t_npo_index, 5, '0') -- Індекс відділення зв'язку 2 цифри
                || ','
                || TO_CHAR (c.t_prs_num)           -- Номер відомості -4 цифри
                || ','
                || c.t_pp_day                          -- День виплати 2 цифри
                || ','
                || c.t_pc_number            -- Номер особового рахунку 12 цифр
                || ','
                || TO_CHAR (c.t_pp_sum) -- Сума "Нараховано"(60% или 100%) -9 цифр
                || ','
                || '0'           -- Сума (40% или 0) 9 цифр (За замовченням 0)
                || ','
                || c.t_ul_name                   -- Вулиця (назва) 50 символів
                || ','
                || c.t_adr                         -- Буд;корп.;кв. 23 символа
                || ','
                || c.t_pc_pib     -- Прізвище, ім’я та по-батькові 50 символів
                || ','
                || c.t_dlvr_tp -- Вид доставки 1 символ (D -дом, P -пошта, U - знач.немає в довіднику.)
                || ','
                || TO_CHAR (c.t_dlvr_code) -- Доставча дільниця 2 цифри (* номер доставної дільниці у значенні «50» означає отримання грошей у касі відділення зв’язку.)
                || ','
                || TO_CHAR (c.t_ul_code)                  -- Код вулиці 5 цифр
                || ','
                || c.t_doc_ser -- Серія документа, що посвідчує особу 2 символи** («Серія паспорту» -  обов’язково великі та кириличні букви, якщо серія паспорту відсутня – поле пусте)
                || ','
                || c.t_doc_num -- Номер документа, що посвідчує особу 9 цифр (значення реквізиту доповнюється ведучими нулями до 9-ти знаків)
                || ','
                || c.t_is_poa                 -- Ознака виплати за довіреністю
                || ','
                || LPAD (c.t_npo_index, 5, '0') -- Поштовий індекс населеного пункту 5 цифр
                || CHR (13)
                || CHR (10);
            DBMS_LOB.writeappend (
                l_data,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_row)),
                UTL_RAW.cast_to_raw (l_row));
        END LOOP;

        /*
        l_zip := tools.toZip2(  p_file_blob => l_data,
                                p_file_name => p_filename );
        */
        l_zip := UTL_COMPRESS.lz_compress (l_data, 9);
        l_rez := tools.ConvertBlobToBase64 (l_zip);

        DBMS_LOB.close (l_data);
        DBMS_LOB.freetemporary (l_data);

        RETURN l_rez;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RAISE;
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка побудови файлу.'
                || CHR (10)
                || SQLERRM
                || DBMS_UTILITY.format_error_backtrace);
    END getPostFile;

    FUNCTION GetFiliaFile_01 (p_pr_id          NUMBER,
                              p_nb_id          NUMBER,
                              --p_nb_number VARCHAR2,
                              --p_nb_filia  VARCHAR2,
                              p_prs_pay_dt     DATE,
                              -- p_prs_num     NUMBER, -- io 20220727  це номер по порядку в розрізі дат виплати та банків, а не номер списку в розумінні ДКГ
                              p_bnk_cnt        NUMBER,
                              p_bnk_sum        NUMBER,
                              p_convert_symb   VARCHAR2:= 'F',
                              p_pr_code        VARCHAR2:= '00')
        RETURN CLOB
    IS
        l_header            VARCHAR2 (500);
        l_header_conv       VARCHAR2 (500);
        l_row               VARCHAR2 (500);
        l_rez               CLOB;
        l_data              BLOB;
        l_zip               BLOB;
        l_use_iban          VARCHAR2 (10) := 'T'; --nvl(tools.GP('USE_IBAN',sysdate), 'F');
        l_exch_version      VARCHAR2 (10) := 'V002'; -- nvl(tools.GP('EXCH_VERSION',sysdate), 'V001');
        l_acc_length_head   NUMBER;
        l_acc_length_rows   NUMBER;
        l_row_fill          VARCHAR2 (1);
        l_pr_tp             VARCHAR2 (10);
        l_bank_iban         VARCHAR2 (29);
        l_uss_iban          VARCHAR2 (29);
        l_uss_mfo           VARCHAR2 (10);
        l_pr_code           VARCHAR2 (10);
        l_nbg_id            NUMBER;
    BEGIN
        l_acc_length_head := CASE WHEN l_use_iban = 'T' THEN 29 ELSE 9 END;
        l_acc_length_rows := CASE WHEN l_use_iban = 'T' THEN 29 ELSE 19 END;
        l_row_fill := CASE WHEN l_use_iban = 'T' THEN '0' ELSE ' ' END;

        DBMS_LOB.createtemporary (lob_loc => l_data, cache => TRUE);
        DBMS_LOB.open (lob_loc => l_data, open_mode => DBMS_LOB.lob_readwrite);

        SELECT MAX (t.npt_nbg), LPAD (MAX (npc_code), 2, '0')
          INTO l_nbg_id, l_pr_code
          FROM payroll  pr
               JOIN uss_ndi.v_ndi_payment_type t
                   ON t.npt_npc = pr_npc AND t.history_status = 'A'
               JOIN uss_ndi.v_ndi_payment_codes с
                   ON с.npc_id = pr_npc AND t.history_status = 'A'
         WHERE pr_id = p_pr_id;

        -- банк платник ?????
        BEGIN
            SELECT nppa.dppa_account, b.nb_mfo
              INTO l_uss_iban, l_uss_mfo
              FROM uss_ndi.v_ndi_pay_person  p
                   JOIN uss_ndi.v_ndi_pay_person_acc nppa
                       ON (nppa.dppa_dpp = p.dpp_id)
                   JOIN uss_ndi.v_ndi_bank b ON nb_id = nppa.dppa_nb
             --JOIN uss_ndi.v_ndi_budget_program bp ON (bp.nbg_id = nppa.dppa_nbg)
             WHERE     p.dpp_tp = 'OSZN'
                   AND p.dpp_org = uss_ndi.tools.getcurrorg
                   --and bp.nbg_kpk_code = '2501030'
                   --and bp.history_status = 'A'
                   AND p.history_status = 'A'
                   AND nppa.history_status = 'A'
                   AND nppa.dppa_nbg = l_nbg_id;
        EXCEPTION
            WHEN OTHERS
            THEN
                l_uss_iban := '';
                l_uss_mfo := '';
        END;

        -- Банк одерджувач
        SELECT MAX (nppa.dppa_account)
          INTO l_bank_iban
          FROM uss_ndi.V_NDI_FIN_PAY_CONFIG  fpc
               JOIN uss_ndi.v_ndi_pay_person_acc nppa
                   ON nppa.dppa_id = fpc.nfpc_dppa
         WHERE     1 = 1
               AND fpc.history_status = 'A'
               AND nppa.history_status = 'A'
               AND fpc.nfpc_nb = p_nb_id
               AND nppa.dppa_nbg = l_nbg_id
               AND fpc.com_org = uss_ndi.tools.getcurrorg;

        /*  select max(nb_mfo) into l_bank_mfo
          from uss_ndi.v_ndi_bank
          where nb_id = p_nb_id;*/

        -- #82683 io 20230102  номер підзвітної філії - такий самий як центральної філії
        SELECT MAX (
                      tools.PR (SUBSTR (x_nb_mfo, -6), 6)
                   || '0000'
                   || tools.PR (l_pr_code, 2)
                   || '.'
                   || tools.PR (x_opfu, 3)
                   || DECODE (l_use_iban, 'T', '408', '368')
                   || tools.PR (TO_CHAR (SYSDATE, 'dd/mm/yy'), 8)
                   || tools.PR (TRIM (TO_CHAR (p_bnk_cnt, '000000')), 6)
                   || LPAD (NVL (l_uss_mfo, '0'), 9, '0')
                   || LPAD (NVL (l_uss_iban, '0'), l_acc_length_head, '0')
                   || LPAD (NVL (x_nb_mfo, 0), 9, '0')
                   || LPAD (NVL (l_bank_iban, '0'), l_acc_length_head, '0')
                   || ' '
                   || tools.PR (
                          TRIM (TO_CHAR (p_bnk_sum, '0000000000000000000')),
                          19)
                   || --case when nvl(p_pr_code, '00') = '00' or length(p_pr_code) < 2 then '01' else substr(p_pr_code, -2) end|| --'01'||
                      tools.PR (l_pr_code, 2)                         /*'01'*/
                   || LPAD (' ', 10, ' ')
                   || ' '
                   || tools.PR ( /*DNET$RPT_MATRIX.get_org_sname(b_opfu_name)*/
                                b_org_code, 27)
                   ||                                    -- Коротка назва ОСЗН
                      tools.PR (                            /*x_nb_main_code*/
                                ' ', 27)
                   ||                                       -- не заповнюється
                      tools.PR (                               /*b_pr_header*/
                                'ВИПЛАТА ДОПОМОГ'           /*||dat.npc_code*/
                                                 , 160)
                   ||                                                              -- #81330
                      tools.PL (                                /*x_nb_filia*/
                                                               /*x_nb_number*/
                                ' ', 5)
                   ||                                       -- не заповнюється
                      tools.PR (' ', 45)
                   || CHR (13)
                   || CHR (10)),                           -- #81330   46 ==>>
               MAX (pr_tp)
          INTO l_header, l_pr_tp
          FROM TMP_BANK_TO_EXPORT  t,
               (SELECT SUBSTR (TRIM (TO_CHAR (org_id, '000009')), 1, 3)
                           AS b_opfu,
                       SUBSTR (TOOLS.GetOrgSName (o.org_id), 1, 27)
                           AS b_opfu_name,
                       c.npc_name
                           AS b_pr_header,
                       pr_tp,
                       c.npc_code,
                       o.org_id
                           AS b_org_code
                  FROM payroll, v_opfu o, uss_ndi.v_ndi_payment_codes c
                 WHERE     1 = 1
                       AND pr_id = p_pr_id
                       AND com_org = org_id
                       AND c.npc_id = pr_npc) dat
         WHERE 1 = 1 --  AND x_nb_number = p_nb_number
                     --   AND x_nb_filia = p_nb_filia
                     AND x_nb_id = p_nb_id AND x_prs_pay_dt = p_prs_pay_dt---AND x_prs_num = p_prs_num
                                                                          ;


        -- dbms_output.put_line('l_header='||l_header) ;

        l_header_conv :=
            CONVERT (tools.ReplUKRSmb2Dos (l_header, p_convert_symb),
                     'RU8PC866',
                     'CL8MSWIN1251');

        -- dbms_output.put_line('l_header_conv='||l_header_conv) ;

        DBMS_LOB.writeappend (
            l_data,
            DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_header_conv)),
            UTL_RAW.cast_to_raw (l_header_conv));

        -- dbms_output.put_line('l_header = '||l_header||', l_pr_tp = '||l_pr_tp) ;

        FOR cc
            IN (SELECT *
                  FROM TMP_BANK_TO_EXPORT
                 WHERE     1 = 1
                       AND x_nb_id = p_nb_id
                       AND x_prs_pay_dt = p_prs_pay_dt/*AND x_prs_num = p_prs_num*/
                                                      )
        LOOP
            l_row :=
                   LPAD (NVL (cc.x_prs_account, l_row_fill),
                         l_acc_length_rows,
                         l_row_fill)
                ||        --tools.PR(cc.x_prs_account, /*19*/ l_acc_length )||
                   tools.PR (                               /*cc.x_nb_number*/
                                                                /*x_nb_filia*/
                             ' ', 5)
                ||                                             -- Не заполнять
                   '028'
                || tools.PR (
                       TRIM (
                           TO_CHAR (              /*cc.x_prs_sum*100  #66354*/
                                    /*case when p_pr_code = '103' then 0 else cc.x_prs_sum*100 end*/
                                    cc.x_prs_sum * 100              --  #67214
                                                      ,
                                    '0000000000000000000')),
                       19)
                || tools.PL (cc.x_prs_pib, 100)
                || tools.PL (cc.x_prs_inn, 10)
                || tools.PR (                              /*cc.x_prs_pay_dt*/
                             '00', 2)
                || -- дату виплати по допомогам замінити на 00 (в друкованій та електронній формі)
                   tools.PR (NVL (cc.x_is_migr, '0'), 1)
                ||                           --1- особа ВПО     0-особа не ВПО
                   /*             case when l_exch_version = 'V002' then tools.PR(cc.x_pc_num, 12) else '' end || -- oivashchuk 20210224  #64663
                                case when l_exch_version = 'V002' and l_pr_tp = 'C' then tools.PR(cc.x_cor_rsn, 2)
                                     when l_exch_version = 'V002' then tools.PR('', 2)
                                     else '' end ||*/
                   CHR (13)
                || CHR (10);    -- 20210326 прибрав склейку останнього пробіла
            l_row :=
                CONVERT (tools.ReplUKRSmb2Dos (l_row, p_convert_symb),
                         'RU8PC866',
                         'CL8MSWIN1251');
            DBMS_LOB.writeappend (
                l_data,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_row)),
                UTL_RAW.cast_to_raw (l_row));
        END LOOP;

        --
        -- dbms_output.put_line(tools.ConvertB2C(l_data));
        --insert into tmp_blob(t_name, t_blob) values('z_cor_file',l_data);
        /*    #81330  io прибираємо конвертацію в base64. видаємо файли як є...
          if l_pr_tp = 'O' then -- тимчасово, до реалізації ОБ обміну через ІС
            l_rez := tools.ConvertB2C(l_data);
          else
            l_zip := utl_compress.lz_compress(l_data, 9);

            l_rez := tools.ConvertBlobToBase64(l_zip);
          end if;
          */
        l_rez := tools.ConvertB2C (l_data);
        RETURN l_rez;
    END;

    FUNCTION GetFiliaFile_00 (p_pr_id          NUMBER,
                              p_nb_id          NUMBER,
                              --p_nb_number VARCHAR2,
                              --p_nb_filia  VARCHAR2,
                              p_prs_pay_dt     DATE,
                              -- p_prs_num     NUMBER, -- io 20220727  це номер по порядку в розрізі дат виплати та банків, а не номер списку в розумінні ДКГ
                              p_bnk_cnt        NUMBER,
                              p_bnk_sum        NUMBER,
                              p_convert_symb   VARCHAR2:= 'F',
                              p_pr_code        VARCHAR2:= '00')
        RETURN CLOB
    IS
        l_header            VARCHAR2 (500);
        l_header_conv       VARCHAR2 (500);
        l_row               VARCHAR2 (500);
        l_rez               CLOB;
        l_data              BLOB;
        l_zip               BLOB;
        l_use_iban          VARCHAR2 (10) := 'T'; --nvl(tools.GP('USE_IBAN',sysdate), 'F');
        l_exch_version      VARCHAR2 (10) := 'V002'; -- nvl(tools.GP('EXCH_VERSION',sysdate), 'V001');
        l_acc_length_head   NUMBER;
        l_acc_length_rows   NUMBER;
        l_row_fill          VARCHAR2 (1);
        l_pr_tp             VARCHAR2 (10);
        l_bank_iban         VARCHAR2 (29);
        l_uss_iban          VARCHAR2 (29);
        l_uss_mfo           VARCHAR2 (10);
        l_nbg_id            NUMBER;
    BEGIN
        l_acc_length_head := CASE WHEN l_use_iban = 'T' THEN 29 ELSE 9 END;
        l_acc_length_rows := CASE WHEN l_use_iban = 'T' THEN 29 ELSE 19 END;
        l_row_fill := CASE WHEN l_use_iban = 'T' THEN '0' ELSE ' ' END;

        DBMS_LOB.createtemporary (lob_loc => l_data, cache => TRUE);
        DBMS_LOB.open (lob_loc => l_data, open_mode => DBMS_LOB.lob_readwrite);

        SELECT MAX (t.npt_nbg)
          INTO l_nbg_id
          FROM payroll  pr
               JOIN uss_ndi.v_ndi_payment_type t
                   ON t.npt_npc = pr_npc AND t.history_status = 'A'
         WHERE pr_id = p_pr_id;

        -- банк платник ?????
        BEGIN
            SELECT nppa.dppa_account, b.nb_mfo
              INTO l_uss_iban, l_uss_mfo
              FROM uss_ndi.v_ndi_pay_person  p
                   JOIN uss_ndi.v_ndi_pay_person_acc nppa
                       ON (nppa.dppa_dpp = p.dpp_id)
                   JOIN uss_ndi.v_ndi_bank b ON nb_id = nppa.dppa_nb
             --JOIN uss_ndi.v_ndi_budget_program bp ON (bp.nbg_id = nppa.dppa_nbg)
             WHERE     p.dpp_tp = 'OSZN'
                   AND p.dpp_org = uss_ndi.tools.getcurrorg
                   --and bp.nbg_kpk_code = '2501030'
                   --and bp.history_status = 'A'
                   AND p.history_status = 'A'
                   AND nppa.history_status = 'A'
                   AND nppa.dppa_nbg = l_nbg_id;
        EXCEPTION
            WHEN OTHERS
            THEN
                l_uss_iban := '';
                l_uss_mfo := '';
        END;

        -- Банк одерджувач
        SELECT MAX (nppa.dppa_account)
          INTO l_bank_iban
          FROM uss_ndi.V_NDI_FIN_PAY_CONFIG  fpc
               JOIN uss_ndi.v_ndi_pay_person_acc nppa
                   ON nppa.dppa_id = fpc.nfpc_dppa
         WHERE     1 = 1
               AND fpc.history_status = 'A'
               AND nppa.history_status = 'A'
               AND fpc.nfpc_nb = p_nb_id
               AND nppa.dppa_nbg = l_nbg_id
               AND fpc.com_org = uss_ndi.tools.getcurrorg;

        /*  select max(nb_mfo) into l_bank_mfo
          from uss_ndi.v_ndi_bank
          where nb_id = p_nb_id;*/

        -- #82683 io 20230102  номер підзвітної філії - такий самий як центральної філії
        SELECT MAX (
                      tools.PR (x_nb_number, 5)
                   || tools.PR (x_nb_number                     /*x_nb_filia*/
                                           , 5)
                   || tools.PR (x_prs_pay_dt, 2)
                   || '.'
                   || tools.PR (x_opfu, 3)
                   || DECODE (l_use_iban, 'T', '408', '368')
                   || tools.PR (TO_CHAR (SYSDATE, 'dd/mm/yy'), 8)
                   || tools.PR (TRIM (TO_CHAR (p_bnk_cnt, '000000')), 6)
                   || LPAD (NVL (l_uss_mfo, '0'), 9, '0')
                   || LPAD (NVL (l_uss_iban, '0'), l_acc_length_head, '0')
                   || LPAD (NVL (x_nb_mfo, 0), 9, '0')
                   || LPAD (NVL (l_bank_iban, '0'), l_acc_length_head, '0')
                   || ' '
                   || tools.PR (
                          TRIM (TO_CHAR (p_bnk_sum, '0000000000000000000')),
                          19)
                   || --case when nvl(p_pr_code, '00') = '00' or length(p_pr_code) < 2 then '01' else substr(p_pr_code, -2) end|| --'01'||
                      '01'
                   || LPAD (' ', 10, ' ')
                   || ' '
                   || tools.PR (b_opfu_name, 27)
                   || tools.PR (x_nb_main_code, 27)
                   || tools.PR (                               /*b_pr_header*/
                                'ВИПЛАТА ДОПОМОГ ' || dat.npc_code, 160)
                   ||                                                              -- #81330
                      tools.PL (                                /*x_nb_filia*/
                                x_nb_number, 5)
                   || tools.PR (' ', 45)
                   || CHR (13)
                   || CHR (10)),                           -- #81330   46 ==>>
               MAX (pr_tp)
          INTO l_header, l_pr_tp
          FROM TMP_BANK_TO_EXPORT  t,
               (SELECT SUBSTR (TRIM (TO_CHAR (org_id, '000009')), 1, 3)
                           AS b_opfu,
                       SUBSTR (TOOLS.GetOrgSName (o.org_id), 1, 27)
                           AS b_opfu_name,
                       c.npc_name
                           AS b_pr_header,
                       pr_tp,
                       c.npc_code
                  FROM payroll, v_opfu o, uss_ndi.v_ndi_payment_codes c
                 WHERE     1 = 1
                       AND pr_id = p_pr_id
                       AND com_org = org_id
                       AND c.npc_id = pr_npc) dat
         WHERE 1 = 1 --  AND x_nb_number = p_nb_number
                     --   AND x_nb_filia = p_nb_filia
                     AND x_nb_id = p_nb_id AND x_prs_pay_dt = p_prs_pay_dt---AND x_prs_num = p_prs_num
                                                                          ;


        -- dbms_output.put_line('l_header='||l_header) ;

        l_header_conv :=
            CONVERT (tools.ReplUKRSmb2Dos (l_header, p_convert_symb),
                     'RU8PC866',
                     'CL8MSWIN1251');

        -- dbms_output.put_line('l_header_conv='||l_header_conv) ;

        DBMS_LOB.writeappend (
            l_data,
            DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_header_conv)),
            UTL_RAW.cast_to_raw (l_header_conv));

        -- dbms_output.put_line('l_header = '||l_header||', l_pr_tp = '||l_pr_tp) ;

        FOR cc
            IN (SELECT *
                  FROM TMP_BANK_TO_EXPORT
                 WHERE     1 = 1
                       AND x_nb_id = p_nb_id
                       AND x_prs_pay_dt = p_prs_pay_dt/*AND x_prs_num = p_prs_num*/
                                                      )
        LOOP
            l_row :=
                   LPAD (NVL (cc.x_prs_account, l_row_fill),
                         l_acc_length_rows,
                         l_row_fill)
                ||        --tools.PR(cc.x_prs_account, /*19*/ l_acc_length )||
                   tools.PR (cc.x_nb_number                     /*x_nb_filia*/
                                           , 5)
                || '028'
                || tools.PR (
                       TRIM (
                           TO_CHAR (              /*cc.x_prs_sum*100  #66354*/
                                    /*case when p_pr_code = '103' then 0 else cc.x_prs_sum*100 end*/
                                    cc.x_prs_sum * 100              --  #67214
                                                      ,
                                    '0000000000000000000')),
                       19)
                || tools.PL (cc.x_prs_pib, 100)
                || tools.PL (cc.x_prs_inn, 10)
                || tools.PR (cc.x_prs_pay_dt, 2)
                || tools.PR (NVL (cc.x_is_migr, '0'), 1)
                ||                           --1- особа ВПО     0-особа не ВПО
                   /*             case when l_exch_version = 'V002' then tools.PR(cc.x_pc_num, 12) else '' end || -- oivashchuk 20210224  #64663
                                case when l_exch_version = 'V002' and l_pr_tp = 'C' then tools.PR(cc.x_cor_rsn, 2)
                                     when l_exch_version = 'V002' then tools.PR('', 2)
                                     else '' end ||*/
                   CHR (13)
                || CHR (10);    -- 20210326 прибрав склейку останнього пробіла
            l_row :=
                CONVERT (tools.ReplUKRSmb2Dos (l_row, p_convert_symb),
                         'RU8PC866',
                         'CL8MSWIN1251');
            DBMS_LOB.writeappend (
                l_data,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_row)),
                UTL_RAW.cast_to_raw (l_row));
        END LOOP;

        --
        -- dbms_output.put_line(tools.ConvertB2C(l_data));
        --insert into tmp_blob(t_name, t_blob) values('z_cor_file',l_data);
        /*    #81330  io прибираємо конвертацію в base64. видаємо файли як є...
          if l_pr_tp = 'O' then -- тимчасово, до реалізації ОБ обміну через ІС
            l_rez := tools.ConvertB2C(l_data);
          else
            l_zip := utl_compress.lz_compress(l_data, 9);

            l_rez := tools.ConvertBlobToBase64(l_zip);
          end if;
          */
        l_rez := tools.ConvertB2C (l_data);
        RETURN l_rez;
    END;


    -- info:  Формування текстjвого файла для пакетів ВВ
    -- params: p_pr_id – ід ВВ
    --         p_nb_id - ід банку
    -- note:
    FUNCTION GetPostFile (p_pr_id IN payroll.pr_id%TYPE)
        RETURN BLOB
    IS
        p_asopd        VARCHAR2 (10) := '';
        l_files        ikis_sysweb.tbl_some_files := ikis_sysweb.tbl_some_files ();
        l_is_convert   CHAR (1) := 'T';
        l_new_format   VARCHAR2 (10) := 1;                   -- повний індекс!
        l_rpt          BLOB;

        --
        CURSOR c_file IS
              SELECT t_ved_tp,
                     t_per_num,
                     t_ncn_code,
                     t_npo_index,
                     t_org_code,
                     t_day_start,
                     t_day_stop,
                     t_per_month,
                     t_per_year,
                     t_pay_tp,
                     LPAD (TO_CHAR (SUM (t_pp_sum)), 15, 0)     t_sum_file,
                     LPAD (TO_CHAR (COUNT (1)), 6, 0)           t_cnt_file
                FROM tmp_post_to_export
            GROUP BY t_ved_tp,
                     t_per_num,
                     t_ncn_code,
                     t_npo_index,
                     t_org_code,
                     t_day_start,
                     t_day_stop,
                     t_per_month,
                     t_per_year,
                     t_pay_tp
            ORDER BY t_ved_tp,
                     t_per_num,
                     t_ncn_code,
                     t_npo_index,
                     t_org_code;

        l_file_row     c_file%ROWTYPE;

        CURSOR c_data (p_file_row c_file%ROWTYPE)
        IS
              SELECT t_prs_num,
                     t_pp_day,
                     t_pc_number,
                     t_pp_sum,
                     t_ul_name,
                     t_adr,
                     t_pc_pib,
                     t_dlvr_tp,
                     t_dlvr_code,
                     t_ul_code
                FROM tmp_post_to_export
               WHERE     t_ved_tp = p_file_row.t_ved_tp
                     AND COALESCE (t_per_num, -1) =
                         COALESCE (p_file_row.t_per_num, -1)
                     AND COALESCE (t_ncn_code, '-1') =
                         COALESCE (p_file_row.t_ncn_code, '-1')
                     AND t_npo_index = p_file_row.t_npo_index
                     AND t_org_code = p_file_row.t_org_code
                     AND t_day_start = p_file_row.t_day_start
                     AND t_day_stop = p_file_row.t_day_stop
                     AND t_per_month = p_file_row.t_per_month
                     AND t_per_year = p_file_row.t_per_year
                     AND t_pay_tp = p_file_row.t_pay_tp
            ORDER BY t_pp_day, t_prs_num, t_pc_number;

        l_data_row     c_data%ROWTYPE;

        PROCEDURE WriteAppendBlob (p_data IN OUT NOCOPY BLOB, p_buff IN CLOB)
        IS
            l_buff        CLOB;
            l_clob_part   NUMBER := 0;
            l_buff_size   NUMBER := 32767;
        BEGIN
            IF DBMS_LOB.getlength (p_buff) > 0
            THEN
                LOOP
                    l_buff :=
                        DBMS_LOB.SUBSTR (
                            p_buff,
                              l_buff_size
                            - CASE WHEN l_clob_part = 0 THEN 1 ELSE 0 END,
                              l_clob_part * l_buff_size
                            + CASE WHEN l_clob_part = 0 THEN 1 ELSE 0 END);
                    l_clob_part := l_clob_part + 1;
                    DBMS_LOB.writeappend (
                        p_data,
                        DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                        UTL_RAW.cast_to_raw (l_buff));
                    EXIT WHEN l_clob_part * l_buff_size >=
                              DBMS_LOB.getlength (p_buff);
                END LOOP;
            END IF;
        END WriteAppendBlob;

        -- create temp data
        PROCEDURE create_temp_data
        AS
        BEGIN
            -- file data
            /*    #86973   - породжує задвоєння за рахунок 2+ рішень
            insert into TMP_POST_TO_EXPORT(T_ORG_CODE, T_PER_NUM, T_DAY_START, T_DAY_STOP, T_PER_MONTH, T_PER_YEAR, T_VED_TP, T_PAY_TP,
                                           T_NCN_CODE, t_npo_index, T_PRS_NUM, T_PC_NUMBER, T_PC_PIB, T_PP_DAY, T_PP_SUM, T_PP_SUM_POST,
                                           T_ADR, T_UL_NAME, T_UL_CODE, T_DLVR_TP, T_DLVR_CODE, T_RBM_REC, T_PRS_ID, T_PR_ID, T_PP_DATE,
                                           T_NCN_ID, T_NPO_ID, T_PRS_PC, T_ADR_ID)
            select \*+ INDEX(PP XIF_PP_PSP)*\
                   substr(op.org_code, 1, 5)  t_org_code,
                   \*nvl(pr_per_num, 1) *\ 1              t_per_num,  --- 1 - для теста
                   4  \*pr_start_dt*\               t_day_start,
                   25 \*pr_stop_dt*\                t_day_stop,
                   extract(month from pr_start_dt)   t_per_month,
                   extract(year from pr_start_dt)   t_per_year,
                   \* #86608 case pr_tp when 'M' then '01' when 'A' then '02' end*\
                   lpad(npc.npc_code, 2, '0')  t_ved_tp, -- #86973 1.
                   decode(prs_tp, 'PP', '01', 'PB', '02') t_pay_tp,
                   '01' as ncn_code, lpad(s.prs_index, 5, '0') as npo_index, -- #86654
                   prs_num, prs_pc_num,
                   replace(substr(upper(trim(concat(trim(concat(trim(s.prs_ln)||' ', trim(s.prs_fn)))||' ',TRIM(s.prs_mn)))), 1, 50), ',', '') t_pc_pib,
                   to_char(prs_pay_dt, 'dd')  t_pp_day,
                 sum(coalesce(prs_sum*100, 0))  t_prs_sum,
                   null,
                   replace(s.prs_building||';'||s.prs_block||';'||s.prs_apartment, ',', '') t_adr,
                   substr(upper(replace(ns.ns_name, ',', '')), 1, 50) t_ul_name,
                   ns.ns_code t_ul_code,
                   case \*coalesce(adr_pp_tp,'D') when 'D'*\ when nvl(dd.nd_code, pdm.pdm_nd_num) is not null then 'D' else 'P' end t_dlvr_tp,
                   \*case coalesce(adr_pp_tp,'D')
                     when 'D' then rdm$address_post.DLVR_INFO(pnf_id, 'DD')
                     else null
                   end *\
                   nvl(dd.nd_code, pdm.pdm_nd_num) as t_dlvr_code,
                   null as t_rec,
                   max(prs_id), pr_id, prs_pay_dt,
                   null as ncn_id, null as npo_id, prs_pc,
                   null as adr_id
          from payroll p
          join pr_sheet s on prs_pr=pr_id
          join v_opfu op on op.org_id = p.com_org
          join uss_ndi.v_ndi_payment_codes npc on npc.npc_id = p.pr_npc --  #86608
          -- #86654 join uss_ndi.v_ndi_post_office pi on pi.npo_index = \*s.prs_index*\ lpad(s.prs_index, 5, '0') and pi.history_status = 'A'
               --   #85038  npo_org не заповнене  and pi.npo_org = p.com_org
          -- #86654 join uss_ndi.v_ndi_comm_node cn on cn.ncn_id = pi.npo_ncn and cn.history_status = 'A'
          --left join uss_ndi.v_ndi_katottg kt on kt.kaot_id = s.prs_kaot
          join uss_ndi.v_ndi_street ns on ns.ns_id = s.prs_ns
          join uss_ndi.v_ndi_street_type nst on nst.nsrt_id = ns.ns_nsrt
          left join uss_ndi.v_ndi_delivery dd on dd.nd_id = s.prs_nd
          -- io 20221226 Якщо в ВВ на пошту не вказано ід ДД  (prs_nd), беремо код ДД з pdm_nd_num   (№ доставочної дільниці з асопд )
          join pc_account a on  pa_id = prs_pa
          join pc_decision pd on  prs_pc=pd_pc and pd_nst = pa_nst
          left join pd_pay_method pdm on pd_id= pdm_pd and pdm.history_status = 'A' and pdm_is_actual = 'T'
          where pr_id = p_pr_id
            and pr_pay_tp = 'POST'
        \*    and prs_tp = 'PP'
            and prs_sum != 0*\
            and prs_sum \*!=*\ > 0 -- #85724
            and prs_st not in ('PP')
            and PRS_tp in ('PP') -- Виплата поштою
        group by substr(op.org_code, 1, 5), extract(month from pr_start_dt), extract(year from pr_start_dt),
                case pr_tp when 'M' then '01' when 'A' then '02' end, decode(prs_tp, 'PP', '01', 'PB', '02') ,
                lpad(s.prs_index, 5, '0'), \* #86654 ncn_code, npo_index,*\ prs_num, prs_pc_num,
                replace(substr(upper(trim(concat(trim(concat(trim(s.prs_ln)||' ', trim(s.prs_fn)))||' ',TRIM(s.prs_mn)))), 1, 50), ',', ''),
                to_char(prs_pay_dt, 'dd'),
                replace(s.prs_building||';'||s.prs_block||';'||s.prs_apartment, ',', ''),
                substr(upper(replace(ns.ns_name, ',', '')), 1, 50),
                ns.ns_code,
                case when nvl(dd.nd_code, pdm.pdm_nd_num) is not null then 'D' else 'P' end,
                nvl(dd.nd_code, pdm.pdm_nd_num),
                pr_id, prs_pay_dt,\* ncn_id, npo_id,*\ prs_pc,  npc.npc_code
            ;*/
            ------   #86973  <<<<<<<<<<
            INSERT INTO TMP_POST_TO_EXPORT (T_ORG_CODE,
                                            T_PER_NUM,
                                            T_DAY_START,
                                            T_DAY_STOP,
                                            T_PER_MONTH,
                                            T_PER_YEAR,
                                            T_VED_TP,
                                            T_PAY_TP,
                                            T_NCN_CODE,
                                            t_npo_index,
                                            T_PRS_NUM,
                                            T_PC_NUMBER,
                                            T_PC_PIB,
                                            T_PP_DAY,
                                            T_PP_SUM,
                                            T_PP_SUM_POST,
                                            T_ADR,
                                            T_UL_NAME,
                                            T_UL_CODE,
                                            T_DLVR_TP,
                                            T_DLVR_CODE,
                                            T_RBM_REC,
                                            T_PRS_ID,
                                            T_PR_ID,
                                            T_PP_DATE,
                                            T_NCN_ID,
                                            T_NPO_ID,
                                            T_PRS_PC,
                                            T_ADR_ID)
                  SELECT /*+ INDEX(PP XIF_PP_PSP)*/
                         SUBSTR (op.org_code, 1, 5)
                             t_org_code,
                         /*nvl(pr_per_num, 1) */
                         --1              t_per_num,  --- 1 - для теста
                         MAX (
                             (SELECT NVL (COUNT (1), 0) + 1
                                FROM payroll p2
                               WHERE     p2.pr_month = p.pr_month
                                     AND p2.com_org = p.com_org
                                     AND p2.pr_npc = p.pr_npc
                                     AND p2.pr_pay_tp = p.pr_pay_tp
                                     ---and p2.pr_tp = p.pr_tp --  #89721 TN: нумерація іде підряд не зважаючи на тип основна/додаткова/ тобто основна = 1, додаткові 2,3,4.
                                     AND p2.pr_create_dt < p.pr_create_dt))
                             t_per_num, --  #89721 io  + TN: при формуванні шукаємо по цьому місяцю та по цій послузі максимальний № та + 1. Все
                         4                                     /*pr_start_dt*/
                             t_day_start,
                         25                                     /*pr_stop_dt*/
                             t_day_stop,
                         EXTRACT (MONTH FROM pr_start_dt)
                             t_per_month,
                         EXTRACT (YEAR FROM pr_start_dt)
                             t_per_year,
                         LPAD (npc.npc_code, 2, '0')
                             t_ved_tp,                            -- #86973 1.
                         DECODE (prs_tp,  'PP', '01',  'PB', '02')
                             t_pay_tp,
                         '01'
                             AS ncn_code,
                         LPAD (s.prs_index, 5, '0')
                             AS npo_index,                           -- #86654
                         prs_num,
                         prs_pc_num,
                         REPLACE (
                             SUBSTR (
                                 UPPER (
                                     TRIM (
                                         CONCAT (
                                                TRIM (
                                                    CONCAT (
                                                        TRIM (s.prs_ln) || ' ',
                                                        TRIM (s.prs_fn)))
                                             || ' ',
                                             TRIM (s.prs_mn)))),
                                 1,
                                 50),
                             ',',
                             '')
                             t_pc_pib,
                         TO_CHAR (prs_pay_dt, 'dd')
                             t_pp_day,
                         SUM (COALESCE (prs_sum * 100, 0))
                             t_prs_sum,
                         NULL,
                         REPLACE (
                                s.prs_building
                             || ';'
                             || s.prs_block
                             || ';'
                             || s.prs_apartment,
                             ',',
                             '')
                             t_adr,
                         SUBSTR (
                             UPPER (
                                 REPLACE (NVL (ns.ns_name, s.prs_street),
                                          ',',
                                          '')),
                             1,
                             50)
                             t_ul_name,                          -- ns.ns_name
                         NVL (ns.ns_code, '0')
                             t_ul_code, -- io 20230718 TN: повідомлення від пошти - значення коду вулиці 5 цифр (це можуть бути любі значення, напр. 0 )
                         CASE
                             WHEN dd.nd_code IS NOT NULL THEN 'D'
                             ELSE                                      /*'P'*/
                                  NULL
                         END
                             t_dlvr_tp,
                         dd.nd_code
                             AS t_dlvr_code,
                         NULL
                             AS t_rec,
                         MAX (prs_id),
                         pr_id,
                         prs_pay_dt,
                         NULL
                             AS ncn_id,
                         NULL
                             AS npo_id,
                         prs_pc,
                         NULL
                             AS adr_id
                    FROM payroll p
                         JOIN pr_sheet s ON prs_pr = pr_id
                         JOIN v_opfu op ON op.org_id = p.com_org
                         JOIN uss_ndi.v_ndi_payment_codes npc
                             ON npc.npc_id = p.pr_npc               --  #86608
                         LEFT JOIN uss_ndi.v_ndi_street ns
                             ON ns.ns_id = s.prs_ns
                         LEFT JOIN uss_ndi.v_ndi_street_type nst
                             ON nst.nsrt_id = ns.ns_nsrt            --  #87729
                         LEFT JOIN uss_ndi.v_ndi_delivery dd
                             ON dd.nd_id = s.prs_nd
                   WHERE     pr_id = p_pr_id
                         AND pr_pay_tp = 'POST'
                         AND prs_sum                                    /*!=*/
                                     > 0                             -- #85724
                         AND prs_st NOT IN ('PP')
                         AND PRS_tp IN ('PP')                -- Виплата поштою
                -- and LENGTH(dd.nd_code) <= 2 -- тимчасово для тесту !!!!
                GROUP BY SUBSTR (op.org_code, 1, 5),
                         EXTRACT (MONTH FROM pr_start_dt),
                         EXTRACT (YEAR FROM pr_start_dt),
                         CASE pr_tp WHEN 'M' THEN '01' WHEN 'A' THEN '02' END,
                         DECODE (prs_tp,  'PP', '01',  'PB', '02'),
                         LPAD (s.prs_index, 5, '0'),
                         prs_num,
                         prs_pc_num,
                         REPLACE (
                             SUBSTR (
                                 UPPER (
                                     TRIM (
                                         CONCAT (
                                                TRIM (
                                                    CONCAT (
                                                           TRIM (s.prs_ln)
                                                        || ' ',
                                                        TRIM (s.prs_fn)))
                                             || ' ',
                                             TRIM (s.prs_mn)))),
                                 1,
                                 50),
                             ',',
                             ''),
                         TO_CHAR (prs_pay_dt, 'dd'),
                         REPLACE (
                                s.prs_building
                             || ';'
                             || s.prs_block
                             || ';'
                             || s.prs_apartment,
                             ',',
                             ''),
                         SUBSTR (
                             UPPER (
                                 REPLACE (NVL (ns.ns_name, s.prs_street),
                                          ',',
                                          '')),
                             1,
                             50),
                         NVL (ns.ns_code, '0'),                 -- ns.ns_code,
                         CASE
                             WHEN dd.nd_code IS NOT NULL THEN 'D'
                             ELSE                                      /*'P'*/
                                  NULL
                         END,
                         dd.nd_code,
                         pr_id,
                         prs_pay_dt,                      /* ncn_id, npo_id,*/
                         prs_pc,
                         npc.npc_code;

            IF SQL%ROWCOUNT = 0
            THEN
                RAISE NO_DATA_FOUND;
            END IF;

            -- io 20221226 Якщо в ВВ на пошту не вказано ід ДД  (prs_nd), беремо код ДД з pdm_nd_num   (№ доставочної дільниці з асопд )
            UPDATE TMP_POST_TO_EXPORT t
               SET (t.t_dlvr_tp, t.t_dlvr_code) =
                       (SELECT 'D', pdm_nd_num
                          FROM (SELECT pdm_nd_num,
                                       ROW_NUMBER ()
                                           OVER (
                                               PARTITION BY pd_pc
                                               ORDER BY
                                                   DECODE (pd_st, 'S', 1, 0) DESC,
                                                   pd.pd_start_dt DESC)    AS rn
                                  FROM pr_sheet  s
                                       JOIN pc_account a ON pa_id = prs_pa
                                       JOIN pc_decision pd
                                           ON     prs_pc = pd_pc
                                              AND pd_nst = pa_nst
                                       JOIN pd_pay_method pdm
                                           ON     pd_id = pdm_pd
                                              AND pdm.history_status = 'A'
                                              AND pdm_is_actual = 'T'
                                 WHERE     s.prs_id = t.t_prs_id
                                       AND pdm.pdm_pay_tp = 'POST'
                                       AND pdm.pdm_nd_num IS NOT NULL)
                         WHERE rn = 1)
             WHERE     t.t_dlvr_code IS NULL
                   AND EXISTS
                           (SELECT 1
                              FROM pr_sheet  s
                                   JOIN pc_account a ON pa_id = prs_pa
                                   JOIN pc_decision pd
                                       ON prs_pc = pd_pc AND pd_nst = pa_nst
                                   JOIN pd_pay_method pdm
                                       ON     pd_id = pdm_pd
                                          AND pdm.history_status = 'A'
                                          AND pdm_is_actual = 'T'
                             WHERE     s.prs_id = t.t_prs_id
                                   AND pdm.pdm_pay_tp = 'POST'
                                   AND pdm.pdm_nd_num IS NOT NULL);

            UPDATE TMP_POST_TO_EXPORT t
               SET t.t_dlvr_tp = 'P'
             WHERE t.t_dlvr_code IS NULL AND t.t_dlvr_tp IS NULL;
        ------ >>>>>>  #86973


        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RAISE;
            WHEN OTHERS
            THEN
                raise_application_error (
                    -20000,
                       'Помилка читання даних:'
                    || CHR (10)
                    || SQLERRM
                    || DBMS_UTILITY.format_error_backtrace);
        END create_temp_data;

        -- get file
        PROCEDURE get_file (p_rpt             OUT NOCOPY BLOB,
                            p_file_row     IN            c_file%ROWTYPE,
                            p_is_convert   IN            CHAR DEFAULT 'T')
        AS
            l_is_convert   VARCHAR2 (10 CHAR) DEFAULT '1';
            l_file         ikis_sysweb.tbl_some_files
                               := ikis_sysweb.tbl_some_files ();
            l_file_name    VARCHAR2 (255 CHAR)
                :=                                                 /* #86608*/
                      COALESCE (p_file_row.t_npo_index, '_____')
                   || p_file_row.t_ved_tp
                   || SUBSTR (NVL (p_file_row.t_per_num, '1'), -1, 1)
                   || SUBSTR (p_file_row.t_org_code, -2, 2)
                   || '.txt';
            /*          #86973 3. І до моменту переходу всіх уніфікованих типів, індекс залишається 6 знаків,
               coalesce(p_file_row.t_npo_index,'_____')||p_file_row.t_ved_tp||
                        lpad(nvl(p_file_row.t_per_num, '1'), 2, '0')||p_file_row.t_org_code||'.txt';*/

            l_buff         CLOB
                :=    SUBSTR (p_file_row.t_org_code, -4               /*-5,5*/
                                                       )
                   || --    #86973 3. І до моменту переходу всіх уніфікованих типів, індекс залишається 6 знаків, код району в назві файлу 2 знаки, всередині в заголовку 4 знаки.  #86608  4==>>5  Код району - 5 цифри
                      LPAD (TO_CHAR (p_file_row.t_per_num), 2, '0')
                   ||                              --  Номер періоду - 2 цифри
                      LPAD (TO_CHAR (p_file_row.t_day_start), 2, '0')
                   ||                        -- День початку виплати - 2 цифри
                      LPAD (TO_CHAR (p_file_row.t_day_stop), 2, '0')
                   ||                     -- День закінчення виплати - 2 цифри
                      LPAD (TO_CHAR (p_file_row.t_per_month), 2, '0')
                   ||                              -- Місяць виплати - 2 цифри
                      LPAD (TO_CHAR (p_file_row.t_per_year), 4, '0')
                   ||                                 -- Рік виплати - 4 цифри
                      LPAD (p_file_row.t_ved_tp, 2, '0')
                   ||                               -- Тип відомості - 2 цифри
                      LPAD (p_file_row.t_ved_tp, 2, '0')
                   ||                                  /* #86973 2. t_pay_tp*/
                                    -- Вид виплати - 2 цифри (= тип відомості)
                      LPAD (p_file_row.t_sum_file, 15, '0')
                   ||                     -- Загальна сума по району - 15 цифр
                      LPAD (p_file_row.t_cnt_file, 6, '0')
                   || CHR (13)
                   || CHR (10);             --  Кількість отримувачів - 6 цифр
            l_rpt          BLOB;
        BEGIN
            FOR l_data_row IN c_data (p_file_row)
            LOOP
                l_buff :=
                       l_buff
                    || LPAD (p_file_row.t_ncn_code, 2, '0')
                    || ','
                    ||                               -- Вузол зв'язку -2 цифри
                       LPAD (p_file_row.t_npo_index,                     /*5*/
                                                     6, '0')
                    || ','
                    || --     #86973 3. І до моменту переходу всіх уніфікованих типів, індекс залишається 6 знаків, код району в назві файлу 2 знаки, всередині в заголовку 4 знаки. #86608 Відділення зв'язку -5 цифр --   6==>>5 -- так в наданому прикладі #81531
                       TO_CHAR (l_data_row.t_prs_num)
                    || ','
                    ||                             -- Номер відомості -4 цифри
                       l_data_row.t_pp_day
                    || ','
                    ||                                -- День виплати -2 цифри
                       l_data_row.t_pc_number
                    || ','
                    ||                    -- Номер особового рахунку -15 цифр*
                       TO_CHAR (l_data_row.t_pp_sum)
                    || ','
                    ||              -- Сума "Нараховано"(60% или 100%) -9 цифр
                       '0'
                    || ','
                    ||                             -- Сума (40% или 0) -9 цифр
                       l_data_row.t_ul_name
                    || ','
                    ||                                  -- Вулиця -50 символів
                       l_data_row.t_adr
                    || ','
                    ||                      -- Будинок, корп., кв. -23 символа
                       l_data_row.t_pc_pib
                    || ','
                    ||                                  -- П.І.Б. -50 символів
                       l_data_row.t_dlvr_tp
                    || ','
                    || -- Вид доставки -1 символ(D -дом, P -пошта, U - знач.немає в довіднику.)
                       TO_CHAR (l_data_row.t_dlvr_code)
                    || ','
                    ||                           -- Доставча дільниця -2 цифри
                       TO_CHAR (l_data_row.t_ul_code)
                    || CHR (13)
                    || CHR (10);     -- Код вулиці -5 цифр (не опрацьовується)
            END LOOP;

            --if l_is_convert = '1' then
            l_buff :=
                CONVERT (tools.ReplUKRSmb2Dos (l_buff, 'K'             /*'T'*/
                                                          ),
                         'RU8PC866',
                         'CL8MSWIN1251');
            --end if;
            DBMS_LOB.createtemporary (lob_loc => l_rpt, cache => TRUE);
            DBMS_LOB.open (lob_loc     => l_rpt,
                           open_mode   => DBMS_LOB.lob_readwrite);
            WriteAppendBlob (p_data => l_rpt, p_buff => l_buff);

            l_file.EXTEND;
            l_file (l_file.LAST) :=
                ikis_sysweb.t_some_file_info (l_file_name, l_rpt);

            IF l_file.COUNT > 0
            THEN
                --dbms_output.put_line('l_file.count='||l_file.count);
                p_rpt := ikis_sysweb.ikis_web_jutil.getZipFromStrms (l_file);
            END IF;

            DBMS_LOB.close (l_rpt);
            DBMS_LOB.freetemporary (l_rpt);
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RAISE;
            WHEN OTHERS
            THEN
                raise_application_error (
                    -20000,
                       'Помилка побудови файлу.'
                    || CHR (10)
                    || SQLERRM
                    || DBMS_UTILITY.format_error_backtrace);
        END get_file;

        -- add_file
        PROCEDURE add_file (p_file_row IN c_file%ROWTYPE)
        AS
            l_file_name   VARCHAR2 (255 CHAR);
            l_rpt         BLOB;
        BEGIN
            /*    if l_new_format = '1' then
                    l_file_name  := 'TIP'||p_file_row.t_ved_tp||'P'||p_file_row.t_per_num || '\' ||
                          lpad(coalesce(p_file_row.t_ncn_code,'__'),2,'0') || '\' ||
                          coalesce(p_file_row.t_npo_index,'_____')||p_file_row.t_ved_tp||
                          lpad(to_char(p_file_row.t_per_num),2,'0')||substr(p_file_row.t_org_code,-5,5)||'.zip';
                elsif l_new_format = '2' then
                    l_file_name  := 'TIP'||p_file_row.t_ved_tp||'P'||p_file_row.t_per_num || '\' ||
                          lpad(coalesce(p_file_row.t_ncn_code,'__'),2,'0') || '\' ||
                          coalesce(p_file_row.t_npo_index,'_____')||p_file_row.t_ved_tp||
                          substr(p_file_row.t_per_num,-1,1)||substr(p_file_row.t_org_code,-2,2)||'.zip';
                end if;*/
            l_file_name :=
                   'PR_'
                || p_file_row.t_org_code
                || '_'
                || COALESCE (p_file_row.t_ncn_code, '00')
                || '_'
                || p_pr_id
                || '\'
                || COALESCE (p_file_row.t_npo_index, '_____')
                || p_file_row.t_ved_tp
                || SUBSTR (NVL (p_file_row.t_per_num, '1'), -1, 1)
                || SUBSTR (p_file_row.t_org_code, -2, 2)
                || '.zip';
            /*  #86973 3. І до моменту переходу всіх уніфікованих типів, індекс залишається 6 знаків,
                          код району в назві файлу 2 знаки, всередині в заголовку 4 знаки.
               l_file_name  := 'PR_'||p_file_row.t_org_code||'_'||coalesce(p_file_row.t_ncn_code,'00')||'_'||p_pr_id || '\' ||
                          coalesce(p_file_row.t_npo_index,'_____')||p_file_row.t_ved_tp||
                                                   lpad(nvl(p_file_row.t_per_num, '1'), 2, '0')||p_file_row.t_org_code||'.zip';*/

            get_file (l_rpt, p_file_row);
            l_files.EXTEND;
            l_files (l_files.LAST) :=
                ikis_sysweb.t_some_file_info (l_file_name, l_rpt);

            DBMS_OUTPUT.put_line ('l_files.count=' || l_files.COUNT);

            IF l_rpt IS NOT NULL
            THEN
                IF DBMS_LOB.ISOPEN (lob_loc => l_rpt) > 0
                THEN
                    DBMS_LOB.close (l_rpt);
                END IF;

                DBMS_LOB.freetemporary (l_rpt);
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RAISE;
            WHEN OTHERS
            THEN
                raise_application_error (
                    -20000,
                       'Помилка додавання файлу.'
                    || CHR (10)
                    || SQLERRM
                    || DBMS_UTILITY.format_error_backtrace);
        END;

        --
        PROCEDURE check_errors
        AS
            TYPE tt_varchar2_tab IS TABLE OF VARCHAR2 (32767);

            l_msg     VARCHAR2 (4000);
            l_msg_c   tt_varchar2_tab; --/*t_varchar2_tab*/VARCHAR2_NTT := /*t_varchar2_tab*/VARCHAR2_NTT();
        --n         integer := 1;
        BEGIN
            -- 1. Обовязкові поля. Індекси
            l_msg := NULL;

            FOR i IN (SELECT DISTINCT t_pc_number, t_pc_pib
                        FROM tmp_post_to_export
                       WHERE t_npo_index IS NULL)
            LOOP
                --nsi_utils.debugmess(to_char(n)||' - '||l_msg|| chr(10)|| ', t_pc_number=' || i.t_pc_number|| chr(10) || ', t_pc_number=' || i.t_pc_pib );
                --n := n + 1;
                IF LENGTH (l_msg) > 3600
                THEN
                    EXIT;
                END IF;

                l_msg :=
                       l_msg
                    || CHR (38)
                    || 'nbsp;'
                    || CHR (38)
                    || 'nbsp;'
                    || i.t_pc_number
                    || ' '
                    || i.t_pc_pib
                    || CHR (10);
            END LOOP;

            IF l_msg IS NOT NULL
            THEN
                l_msg_c.EXTEND;
                l_msg_c (l_msg_c.LAST) :=
                       'Будь ласка, заповніть спочатку виплатні параметри одержувача, а потім повторіть формування звіту'
                    || CHR (10)
                    || 'Не заповнений індекс поштового зв`язку в параметрах виплати для слідуючих ОР:'
                    || CHR (10)
                    || RTRIM (l_msg, CHR (10))
                    || CHR (10)
                    || CHR (10);
            END IF;

            -- 1. Обовязкові поля. Вузли звязку
            l_msg := NULL;

            FOR i IN (SELECT DISTINCT TO_CHAR (t_npo_index)     t_npo_index
                        FROM tmp_post_to_export
                       WHERE t_ncn_code IS NULL)
            LOOP
                IF LENGTH (l_msg) > 3600
                THEN
                    EXIT;
                END IF;

                l_msg :=
                       l_msg
                    || CHR (38)
                    || 'nbsp;'
                    || CHR (38)
                    || 'nbsp;'
                    || i.t_npo_index
                    || CHR (10);
            END LOOP;

            IF l_msg IS NOT NULL
            THEN
                l_msg_c.EXTEND;
                l_msg_c (l_msg_c.LAST) :=
                       'Будь ласка, заповніть спочатку вузли зв`язку, а потім повторіть формування звіту'
                    || CHR (10)
                    || 'Не заповнені обовязкові поля вузлів зв`язку для слідуючих поштових індексів:'
                    || CHR (10)
                    || RTRIM (l_msg, CHR (10))
                    || CHR (10)
                    || CHR (10);
            END IF;

            IF l_msg_c.COUNT > 0
            THEN
                l_msg := NULL;

                FOR i IN 1 .. l_msg_c.COUNT
                LOOP
                    l_msg := l_msg || l_msg_c (i);
                END LOOP;

                raise_application_error (-20001, CHR (10) || l_msg);
            END IF;
        EXCEPTION
            WHEN OTHERS
            THEN
                RAISE;
        --raise_application_error(-20002, sqlerrm || ' ' || dbms_utility.format_error_backtrace || ' l_msg='||l_msg);
        END;
    --
    BEGIN
        /* select max(p.rdp_value)
           into l_new_format
         from rpt_data_param p
         where p.rdp_rd=p_rd_id and p.rdp_display_name='P260_FULL_INDEX';
       */
        --- fill_tmp_opfu(p_org_id);
        create_temp_data;

        FOR l_file_row IN c_file
        LOOP
            add_file (l_file_row);
        END LOOP;

        IF l_files.COUNT > 0
        THEN
            l_rpt := ikis_sysweb.ikis_web_jutil.getZipFromStrms (l_files);
        END IF;

        RETURN l_rpt;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20001,
                   'Відсутня інформація для побудови файлу електронних відомостей на пошту'
                || CHR (10)
                || SQLERRM
                || DBMS_UTILITY.format_error_backtrace);
        WHEN OTHERS
        THEN
            IF SQLCODE IN (-20001)
            THEN
                RAISE;
            END IF;

            raise_application_error (
                -20000,
                   'Помилка підготовки даних для побудови файлу електронних відомостей на пошту: '
                || CHR (10)
                || SQLERRM
                || DBMS_UTILITY.format_error_backtrace);
    END GetPostFile;


    FUNCTION BuildAccompSheet_html (
        p_po_id    pay_order.po_id%TYPE,
        p_pr_id    payroll.pr_id%TYPE,
        p_prs_tp   pr_sheet.prs_tp%TYPE,
        p_format   INT:= 14,
        p_nb_id    uss_ndi.v_ndi_bank.nb_id%TYPE:= NULL,
        p_nb_num   uss_ndi.v_ndi_bank.nb_num%TYPE:= NULL,
        p_nb_mfo   uss_ndi.v_ndi_bank.nb_mfo%TYPE:= NULL)
        RETURN BLOB
    IS
        p_rpt                 BLOB;
        l_buff                VARCHAR2 (32760);
        l_opfu_name           v_opfu.ORG_NAME%TYPE;
        l_date_start          VARCHAR2 (10);
        l_date_stop           VARCHAR2 (10);
        l_ved_tp              CHAR (50);
        l_pr_pib_manager      payroll.pr_pib_bookkeeper%TYPE;
        l_pr_pib_bookkeeper   payroll.pr_pib_bookkeeper%TYPE;
        l_pr_header           uss_ndi.v_ndi_payment_codes.npc_name%TYPE;

        l_column_width        NUMBER
            := CASE p_format                                 --Slaviq 20070910
                   WHEN 1 THEN 106                   --1 РЛ - 8 шрифт: 106х203
                   WHEN 2 THEN 74                    --1 РЛ - 10 шрифт: 74х162
                   WHEN 3 THEN 65                    --1 РЛ - 11 шрифт: 65х148
                   WHEN 4 THEN 56                    --1 РЛ - 12 шрифт: 56х135
                   WHEN 11 THEN 203                  --2 РЛ - 8 шрифт: 203х107
                   WHEN 12 THEN 162                  --2 РЛ - 10 шрифт: 162х75
                   WHEN 13 THEN 148                  --2 РЛ - 11 шрифт: 148х66
                   WHEN 14 THEN 132                  --2 РЛ - 12 шрифт: 135х57
               END;
        l_column_height       NUMBER
            := CASE p_format                                 --Slaviq 20070910
                   WHEN 1 THEN 202                   --1 РЛ - 8 шрифт: 106х203
                   WHEN 2 THEN 161                   --1 РЛ - 10 шрифт: 74х162
                   WHEN 3 THEN 147                   --1 РЛ - 11 шрифт: 65х148
                   WHEN 4 THEN 134                   --1 РЛ - 12 шрифт: 56х135
                   WHEN 11 THEN 106                  --2 РЛ - 8 шрифт: 203х107
                   WHEN 12 THEN 74                   --2 РЛ - 10 шрифт: 162х75
                   WHEN 13 THEN 65                   --2 РЛ - 11 шрифт: 148х66
                   WHEN 14 THEN 56                   --2 РЛ - 12 шрифт: 135х57
               END;

        l_header_t            VARCHAR2 (32760)
            :=    '<p style="text-align: center;">Опис електронного файлу'
               || '<br>'
               || '<PR_HEADER>'
               || '<br>'
               || --  'за датами виплати' || '<br>' ||
                  'за період  з <DATE_START> по <DATE_STOP>'
               || '<br>'
               || 'тип відомості <VED_TP>'
               || '<br>'
               || '<OPFU_NAME>'
               || '</p>'
               || '<div class="RptTable"><table><tbody>'
               || '<tr><td>Дата виплати</td><td>Номер установи(філії) банку</td><td>Номер списку</td><td>Кількість одержувачів</td><td>Сума, гривень</td></tr>';
        l_header_tab          VARCHAR2 (32760) := ' '; --'<tr class="text-align: center;"><td>1</td><td>2</td><td>3</td><td>4</td><td>5</td></tr>' ;
        l_date_footer         VARCHAR2 (10000)
            := '<tr><td colspan="3">Разом за датою виплати <CUR_DATE></td><td><CNT_DATE></td><td><SUM_DATE></td></tr>';
        l_bank_footer         VARCHAR2 (10000)
            := '<tr><td colspan="3">Разом за центральною установою</td><td><CNT_BANK></td><td><SUM_BANK></td></tr>';
        l_prt_footer          VARCHAR2 (10000)
            :=    '<tr><td colspan="3">Дата виплати</td><td>Кількість одержувачів</td><td>Сума, гривень</td></tr>'
               || '<tr><td colspan="3"><PR_PAYDT></td><td><PR_CNT></td><td><PR_SUM></td></tr>'
               || '</tbody></table></div>' /*||
                  '<p> Відповідальна особа _____________ ________________________</p>' ||
                  '                        (підпис)     (ініціали, прізвище)         '*/
                                          ;

        l_page_num            NUMBER := 0;
        l_page_num_bank       NUMBER := 0;
        l_row_num             NUMBER := 0;

        l_bnk_num             VARCHAR2 (150);

        l_cur_date            DATE;
        l_date_cnt            INT;
        l_date_sum            payroll.pr_sum%TYPE;
        l_bank_cnt            INT;
        l_bank_sum            payroll.pr_sum%TYPE;
        l_prt_cnt             INT;
        l_prt_sum             payroll.pr_sum%TYPE;

        CURSOR c_rep IS
              SELECT prs_pay_dt,
                     b.nb_num,
                     NULL              AS nb_num_filia,
                     1                 AS prs_num,
                     b.nb_num          bname, -- -- io 20220727   prs_num не є номером списку
                     COUNT (*)         AS c,
                     SUM (prs_sum)     AS s
                FROM payroll, pr_sheet, uss_ndi.v_ndi_bank b
               WHERE     pr_id = p_pr_id
                     AND pr_id = prs_pr
                     AND prs_nb = nb_id
                     AND prs_tp IN ('PB', 'ABP', 'OTP')
                     AND (   (    pr_tp IN ('M', 'A', 'C')
                              AND (   prs_tp IN ('PB') AND prs_sum <> 0
                                   OR prs_tp NOT IN ('PB')))
                          OR                                         -- #67415
                             (pr_tp IN ('O') AND (prs_tp IN ('OTP'))))
                     AND prs_tp = p_prs_tp
                     AND prs_st = 'NA' --  io 20221023  лише статус нараховано, виключаємо блокування вручну і т.д.
                     AND prs_sum > 0
                     AND (   p_nb_id IS NULL
                          OR p_nb_id IS NOT NULL AND     /*nvl(nb_nb, nb_id)*/
                                                     nb_id = p_nb_id)
                     AND EXISTS
                             (SELECT 1
                                FROM payroll_reestr pe
                               WHERE     pe_pr = prs_pr
                                     AND pe_po = p_po_id
                                     AND pe_nb = prs_nb
                                     AND pe_pay_dt = prs_pay_dt)
            GROUP BY prs_pay_dt, b.nb_num
            ORDER BY prs_pay_dt, b.nb_num;

        PROCEDURE PageHeader
        IS
        BEGIN
            l_page_num := l_page_num + 1;
            l_row_num := 1;
        END;

        PROCEDURE PageScrool
        IS
            i   INT;
        BEGIN
            FOR i IN 1 .. l_column_height - l_row_num
            LOOP
                l_buff := l_buff || CHR (10);
            END LOOP;

            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END;

        PROCEDURE StrAppend (l_buff VARCHAR2)
        IS
            l_buff_cv   VARCHAR2 (1000);
        BEGIN
            l_buff_cv := l_buff;
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff_cv)),
                UTL_RAW.cast_to_raw (l_buff_cv));
            l_row_num := l_row_num + 1;
        END;

        PROCEDURE TabHeader (p_mode INT:= 0)
        IS
        BEGIN
            l_buff :=
                   CASE WHEN p_mode = 0 THEN l_header_t ELSE ' ' END
                || l_header_tab;                  -- ivashchuk #15185 20160408
            StrAppend (l_buff);
        END;

        PROCEDURE DateFooter
        IS
        BEGIN
            NULL;
        END;

        PROCEDURE BankFooter
        IS
        BEGIN
            l_buff :=
                REPLACE (REPLACE (l_bank_footer, '<CNT_BANK>', l_bank_cnt), --PrintRight(l_bank_cnt,9)),
                         '<SUM_BANK>',
                         TO_CHAR (l_bank_sum, '9999999990.00'));
            StrAppend (l_buff);
            l_bank_cnt := 0;
            l_bank_sum := 0;
        END;

        PROCEDURE PrtFooter
        IS
        BEGIN
            NULL;
        END;
    BEGIN
        l_column_height := l_column_height + 1;

        --  IKIS_SYSWEB_JOBS.SaveMessage('Розпочато побудову звіту список на виплату банкам');

        SELECT org_name,
               TO_CHAR (pr_start_dt, 'dd.mm.yyyy'),
               TO_CHAR (pr_stop_dt, 'dd.mm.yyyy'),
               t.dic_sname,
               NULL     AS pr_pib_manager,
               pr_pib_bookkeeper,
               npc_name --case when p_prs_tp = 'PB' then pr_header else pr_header_pro end
          INTO l_opfu_name,
               l_date_start,
               l_date_stop,
               l_ved_tp,
               l_pr_pib_manager,
               l_pr_pib_bookkeeper,
               l_pr_header
          FROM payroll                      p,
               IKIS_SYS.V_OPFU              o,
               uss_ndi.v_ndi_payment_codes  c,
               uss_ndi.v_ddn_pr_tp          t
         WHERE     p.pr_id = p_pr_id
               AND p.com_org = o.org_id
               AND c.npc_id = p.pr_npc
               AND t.dic_value = p.pr_tp;

        l_header_t := REPLACE (l_header_t, '<DATE_START>', l_date_start);
        l_header_t := REPLACE (l_header_t, '<DATE_STOP>', l_date_stop);
        l_header_t := REPLACE (l_header_t, '<OPFU_NAME>', l_opfu_name); --PrintCenter(l_opfu_name, l_column_width));
        l_header_t := REPLACE (l_header_t, '<VED_TP>', l_ved_tp);
        l_header_t := REPLACE (l_header_t, '<PER_NUM>', 1);
        l_header_t := REPLACE (l_header_t, '<PR_HEADER>', l_pr_header); --PrintCenter(l_pr_header, l_column_width));

        DBMS_LOB.createtemporary (lob_loc => p_rpt, cache => TRUE);
        DBMS_LOB.open (lob_loc => p_rpt, open_mode => DBMS_LOB.lob_readwrite);

        l_bnk_num := '0';
        l_cur_date := TO_DATE ('01.01.1900', 'DD.MM.YYYY');
        l_date_cnt := 0;
        l_date_sum := 0;
        l_bank_cnt := 0;
        l_bank_sum := 0;
        l_prt_cnt := 0;
        l_prt_sum := 0;

        -- io 20230615 задвоєння шапки в циклі
        PageHeader;
        TabHeader;

        FOR v_rep IN c_rep
        LOOP
            IF l_cur_date <> v_rep.prs_pay_dt
            THEN
                IF l_cur_date <> TO_DATE ('01.01.1900', 'DD.MM.YYYY')
                THEN
                    DateFooter;
                END IF;

                /*      PageHeader;  -- io 20230615 задвоєння шапки в циклі
                      TabHeader;*/
                l_cur_date := v_rep.prs_pay_dt;
            END IF;

            IF l_bnk_num <> v_rep.bname
            THEN
                IF l_bnk_num <> '0'
                THEN
                    -- футер для банка
                    BankFooter;
                END IF;

                l_page_num_bank := l_page_num_bank + 1;
                l_bnk_num := v_rep.nb_num;
            END IF;

            IF l_row_num + 1 > l_column_height
            THEN
                PageHeader;
                TabHeader (1);
            END IF;

            l_buff :=
                   '<tr><td>'
                || TO_CHAR (v_rep.prs_pay_dt, 'DD.MM.YYYY')
                || '</td><td>'
                || v_rep.nb_num_filia
                || '</td><td>'
                || v_rep.prs_num
                || '</td><td>'
                || v_rep.c
                || '</td><td>'
                || TRIM (TO_CHAR (ROUND (v_rep.s, 2), '9999999990.00'))
                || '</td></tr>';
            l_row_num := l_row_num + 1;
            l_bank_sum := l_bank_sum + v_rep.s;
            l_bank_cnt := l_bank_cnt + v_rep.c;

            l_date_cnt :=                                     /*l_date_cnt +*/
                          v_rep.c;
            l_date_sum :=                                    /*l_date_sum + */
                          v_rep.s;

            l_prt_cnt := l_prt_cnt + v_rep.c;
            l_prt_sum := l_prt_sum + v_rep.s;
            --l_buff := l_buff ||chr(10)||l_prt_sum;
            DBMS_LOB.writeappend (
                p_rpt,
                DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                UTL_RAW.cast_to_raw (l_buff));
        END LOOP;

        -- футер для даты

        -- підсумок по банку
        SELECT --prs_pay_dt, -- b.nb_num, b.nb_num_filia, prs_num, b.nb_num bname,
               COUNT (*) AS c, SUM (prs_sum) AS s
          INTO l_prt_cnt, l_prt_sum
          FROM                                                          /*v_*/
               payroll, pr_sheet, uss_ndi.v_ndi_bank b
         WHERE     pr_id = p_pr_id
               AND pr_id = prs_pr
               AND prs_nb = nb_id
               AND prs_tp IN ('PB', 'ABP', 'OTP')
               AND (   (    pr_tp IN ('M', 'A', 'C')
                        AND (   prs_tp IN ('PB') AND prs_sum <> 0
                             OR prs_tp NOT IN ('PB')))
                    OR (pr_tp IN ('O') AND (prs_tp IN ('OTP'))))
               AND prs_tp = p_prs_tp
               AND prs_st = 'NA' --  io 20221023  лише статус нараховано, виключаємо блокування вручну і т.д.
               AND prs_sum                                              /*!=*/
                           > 0                                       -- #85724
               AND (   p_nb_id IS NULL           -- oivashchuk 20160225 #14354
                    OR p_nb_id IS NOT NULL AND          /* nvl(nb_nb, nb_id)*/
                                               nb_id = p_nb_id)
               AND EXISTS
                       (SELECT 1
                          FROM payroll_reestr pe
                         WHERE     pe_pr = prs_pr
                               AND pe_po = p_po_id
                               AND pe_nb = prs_nb
                               AND pe_pay_dt = prs_pay_dt);

        l_date_cnt := l_prt_cnt;
        l_date_sum := l_prt_sum;

        DateFooter;
        BankFooter;

        PrtFooter;
        RETURN p_rpt;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка підготовки даних для звіту "BuildAccompSheet": '
                || CHR (10)
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    END;

    -- info:  Формування пакетів ВВ в ПЕОД
    -- params: p_pr_id – ід ВВ, p_prs_tp - тип виплати,  p_nb_id - ыд банку
    --         p_convert_symb
    -- note:
    PROCEDURE BuildBankExchFiles (
        p_po_id          pay_order.po_id%TYPE,
        p_pr_id          payroll.pr_id%TYPE,
        p_prs_tp         pr_sheet.prs_tp%TYPE,
        p_nb_id          uss_ndi.v_ndi_bank.nb_id%TYPE:= NULL,
        p_convert_symb   VARCHAR2:= 'F')
    IS
        l_filter            VARCHAR2 (250);
        l_ecs               exchcreatesession.ecs_id%TYPE;
        l_cnt               INTEGER;
        l_pkt               NUMBER (14);
        l_use_iban          VARCHAR2 (10) := 'T'; ---parammil.prm_value%TYPE := nvl(tools.GP('USE_IBAN',sysdate), 'F');
        l_acc_length_head   NUMBER;
        l_acc_length_rows   NUMBER;
        l_row_fill          VARCHAR2 (1);
        l_pr_code           VARCHAR2 (10);
        l_pr_name           VARCHAR2 (250);
        l_pr_type           VARCHAR2 (10);
        l_pkt_cor           NUMBER;
        l_pay_dt            DATE;
        l_ef_pr_pr          NUMBER;
        l_pr_pc_cnt         NUMBER;
        --  l_exch_version  VARCHAR2(10) := 'V002'; --parammil.prm_value%TYPE := nvl(tools.GP('EXCH_VERSION',sysdate), 'V001');
        exNoPkt4Cor         EXCEPTION;
        exBadVer4Cor        EXCEPTION;
        exNoRec             EXCEPTION;
        exNoRecRm           EXCEPTION;
        l_rbm_pkt_cnt       NUMBER;
        l_npc_id            NUMBER;
        l_no_rec_cnt        NUMBER;
        l_com_org           NUMBER;
        l_err_msg           VARCHAR2 (10000);
    BEGIN
        ---COMMIT;
        -- 4 test
        DELETE FROM TMP_BANK_TO_EXPORT;

        DELETE FROM ikis_rbm.tmp_exchangefiles_m1;

        l_acc_length_head := CASE WHEN l_use_iban = 'T' THEN 29 ELSE 9 END;
        l_acc_length_rows := CASE WHEN l_use_iban = 'T' THEN 29 ELSE 19 END;
        l_row_fill := CASE WHEN l_use_iban = 'T' THEN '0' ELSE ' ' END;

        --  Ikis_Mil_Common.JobSaveMessage('Розпочато формування файлів для електронного обміну - список на банк (по рахункам)');
        l_filter :=
            p_pr_id || '#' || p_prs_tp || '#' || p_nb_id || '#PO' || p_po_id;

        SELECT COUNT (1)
          INTO l_cnt
          FROM exchcreatesession
         WHERE ecs_filter = l_filter;

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                'Створення файлів з даними параметрами вже виконувалось!');
        END IF;

        INSERT INTO exchcreatesession (ecs_id, ecs_start_dt, ecs_filter)
             VALUES (0, SYSDATE, l_filter)
          RETURNING ecs_id
               INTO l_ecs;

        --  Ikis_Mil_Common.JobSaveMessage('Обробляємо дані відомості');

        -- 1. банки - реципієнти
        INSERT INTO TMP_BANK_TO_EXPORT (X_NB_ID,
                                        X_NB_NUMBER,
                                        X_NB_FILIA,
                                        X_PRS_PAY_DT,
                                        X_PRS_ACCOUNT,
                                        X_PRS_SUM,
                                        X_PRS_PIB,
                                        X_PRS_INN,
                                        X_NB_MFO,
                                        X_NB_MAIN_CODE,
                                        X_OPFU,
                                        X_PRS_NUM,
                                        X_REC,
                                        X_IS_MIGR,
                                        X_PC_NUM,
                                        X_COR_RSN,
                                        X_NB_NAME,
                                        x_last_name,
                                        x_first_name,
                                        x_second_name,
                                        x_prs_id)
            SELECT nb_id,
                   x_nb_number,
                   x_nb_filia,
                   x_pay_dt,
                   prs_account,
                   prs_sum,
                   x_prs_pib,
                   prs_inn,
                   nb_mfo,
                   x_nb_main_code,
                   x_opfu,
                   1     AS prs_num,
                   x_rec,  -- io 20220727  prs_num не є номер списку. це №п.п.
                   x_is_migr,
                   x_pc_number,
                   x_prs_cor_rsn,
                   nb_name,
                   prs_ln,
                   prs_fn,
                   prs_mn,
                   prs_id
              FROM (SELECT b.nb_id,
                           prs_num,
                           s.prs_pay_dt
                               AS x_pay_dt,
                           LPAD (b.nb_num, 5, '0')
                               x_nb_number,
                           LPAD (b.nb_num, 5, '0')
                               AS x_nb_filia,
                           LPAD (b.nb_mfo, 9, '0')
                               nb_mfo,
                           LPAD (NVL (TRIM (prs_account), 0), 29, '0')
                               prs_account,
                           TRIM (prs_ln || ' ' || prs_fn || ' ' || prs_mn)
                               x_prs_pib,
                           prs_sum,
                           prs_pc_num,
                           NVL (
                               CASE
                                   WHEN TRIM (
                                            TRANSLATE (prs_inn,
                                                       '0123456789',
                                                       ' '))
                                            IS NULL
                                   THEN
                                       LPAD (prs_inn, 10, '0')
                                   ELSE
                                       '0000000000'
                               END,
                               '0000000000')
                               prs_inn,
                           NVL (                                 /*b0.nb_num*/
                                '', b.nb_num)
                               AS x_nb_main_code,
                           SUBSTR (TRIM (TO_CHAR (pr.com_org, '000009')),
                                   1,
                                   3)
                               AS x_opfu,
                           rec_id
                               AS x_rec, -- io 20230609  якщо на регіональну філію завели реципієнта, то формуємо на неї пакети!!
                           ''
                               AS x_is_migr,
                           prs_pc_num
                               AS x_pc_number,           --#66415  12 символів
                           /*case when pr_tp = 'C' then prs_cor_rsn else null end*/
                           NULL
                               AS x_prs_cor_rsn,
                           b.nb_name,
                           prs_ln,
                           prs_fn,
                           prs_mn,
                           prs_id
                      -- select *
                      FROM payroll  pr
                           JOIN pr_sheet s ON pr_id = prs_pr
                           JOIN uss_ndi.v_ndi_bank b ON s.prs_nb = b.nb_id
                           LEFT JOIN ikis_rbm.v_recipient r
                               ON r.rec_nb = b.nb_id --  #94979 20231211 + left
                     WHERE     pr_id = p_pr_id
                           AND pr_pay_tp = 'BANK'                --p_pr_pay_tp
                           AND (p_nb_id IS NULL OR  /*nvl(b0.nb_id, b.nb_id)*/
                                                   b.nb_id = p_nb_id) -- io 20230609 b.nb_id
                           AND prs_tp IN ('PB'               /*,'ABP', 'OTP'*/
                                              )
                           AND prs_st = 'NA' --  io 20221023  лише статус нараховано, виключаємо блокування вручну і т.д.
                           AND ((    pr_tp IN ('M', 'A', 'C')
                                 AND (   prs_tp IN ('PB') AND prs_sum <> 0
                                      OR prs_tp NOT IN ('PB'))
                                 AND (   pr_tp IN ('M', 'A') AND prs_sum > 0
                                      OR pr_tp NOT IN ('M', 'A'))   --20210805
                                                                 ))
                           AND prs_sum                                  /*!=*/
                                       > 0                           -- #85724
                           AND (rec_id IS NOT NULL OR nb_nb IS NULL) --  #94979 20231211  всі головні банки + ті, у кого є реципієнт
                           AND EXISTS
                                   (SELECT 1
                                      FROM payroll_reestr pe
                                     WHERE     pe_pr = prs_pr
                                           AND pe_po = p_po_id
                                           AND pe_nb = prs_nb
                                           AND pe_pay_dt = prs_pay_dt));

        --
        DBMS_OUTPUT.put_line ('ins-1 ' || SQL%ROWCOUNT);

        -- 2.  банки-не реципієнти, у яких є головний банк-реципієнт
        INSERT INTO TMP_BANK_TO_EXPORT (X_NB_ID,
                                        X_NB_NUMBER,
                                        X_NB_FILIA,
                                        X_PRS_PAY_DT,
                                        X_PRS_ACCOUNT,
                                        X_PRS_SUM,
                                        X_PRS_PIB,
                                        X_PRS_INN,
                                        X_NB_MFO,
                                        X_NB_MAIN_CODE,
                                        X_OPFU,
                                        X_PRS_NUM,
                                        X_REC,
                                        X_IS_MIGR,
                                        X_PC_NUM,
                                        X_COR_RSN,
                                        X_NB_NAME,
                                        x_last_name,
                                        x_first_name,
                                        x_second_name,
                                        x_prs_id)
            SELECT nb_id,
                   x_nb_number,
                   x_nb_filia,
                   x_pay_dt,
                   prs_account,
                   prs_sum,
                   x_prs_pib,
                   prs_inn,
                   nb_mfo,
                   x_nb_main_code,
                   x_opfu,
                   1     AS prs_num,
                   x_rec,  -- io 20220727  prs_num не є номер списку. це №п.п.
                   x_is_migr,
                   x_pc_number,
                   x_prs_cor_rsn,
                   nb_name,
                   prs_ln,
                   prs_fn,
                   prs_mn,
                   prs_id
              FROM (SELECT NVL (b0.nb_id, b.nb_id)
                               AS nb_id,
                           prs_num,
                           s.prs_pay_dt
                               AS x_pay_dt,
                           LPAD (NVL (b0.nb_num, b.nb_num), 5, '0')
                               x_nb_number,
                           NULL
                               AS x_nb_filia,
                           LPAD (b.nb_mfo, 6, '0')
                               nb_mfo,
                           LPAD (NVL (TRIM (prs_account), 0), 29, '0')
                               prs_account,
                           TRIM (prs_ln || ' ' || prs_fn || ' ' || prs_mn)
                               x_prs_pib,
                           prs_sum,
                           prs_pc_num,
                           NVL (
                               CASE
                                   WHEN TRIM (
                                            TRANSLATE (prs_inn,
                                                       '0123456789',
                                                       ' '))
                                            IS NULL
                                   THEN
                                       LPAD (prs_inn, 10, '0')
                                   ELSE
                                       '0000000000'
                               END,
                               '0000000000')
                               prs_inn,
                           NVL (b0.nb_num, b.nb_num)
                               AS x_nb_main_code,
                           SUBSTR (TRIM (TO_CHAR (pr.com_org, '000009')),
                                   1,
                                   3)
                               AS x_opfu,
                           rec_id
                               AS x_rec, -- io 20230609  якщо на регіональну філію завели реципієнта, то формуємо на неї пакети!!
                           ''
                               AS x_is_migr,
                           prs_pc_num
                               AS x_pc_number,           --#66415  12 символів
                           /*case when pr_tp = 'C' then prs_cor_rsn else null end*/
                           NULL
                               AS x_prs_cor_rsn,
                           b.nb_name,
                           prs_ln,
                           prs_fn,
                           prs_mn,
                           prs_id
                      -- select *
                      FROM payroll  pr
                           JOIN pr_sheet s ON pr_id = prs_pr
                           JOIN uss_ndi.v_ndi_bank b
                               ON s.prs_nb = b.nb_id AND b.nb_nb IS NOT NULL
                           LEFT JOIN ikis_rbm.v_recipient r
                               ON r.rec_nb = b.nb_nb       --  #94979 20231211
                           LEFT JOIN uss_ndi.v_ndi_bank b0
                               ON b.nb_nb = b0.nb_id
                     WHERE     pr_id = p_pr_id
                           AND pr_pay_tp = 'BANK'                --p_pr_pay_tp
                           AND (p_nb_id IS NULL OR  /*nvl(b0.nb_id, b.nb_id)*/
                                                   b.nb_id = p_nb_id) -- io 20230609 b.nb_id
                           AND prs_tp IN ('PB'               /*,'ABP', 'OTP'*/
                                              )
                           AND prs_st = 'NA' --  io 20221023  лише статус нараховано, виключаємо блокування вручну і т.д.
                           AND ((    pr_tp IN ('M', 'A', 'C')
                                 AND (   prs_tp IN ('PB') AND prs_sum <> 0
                                      OR prs_tp NOT IN ('PB'))
                                 AND (   pr_tp IN ('M', 'A') AND prs_sum > 0
                                      OR pr_tp NOT IN ('M', 'A'))   --20210805
                                                                 ))
                           AND prs_sum                                  /*!=*/
                                       > 0                           -- #85724
                           AND NOT EXISTS
                                   (SELECT 1
                                      FROM ikis_rbm.v_recipient r
                                     WHERE r.rec_nb = b.nb_id)
                           AND EXISTS
                                   (SELECT 1
                                      FROM payroll_reestr pe
                                     WHERE     pe_pr = prs_pr
                                           AND pe_po = p_po_id
                                           AND pe_nb = prs_nb --  #94979 20231211 nvl(b0.nb_id, b.nb_id)
                                           AND pe_pay_dt = prs_pay_dt)
                           AND NOT EXISTS
                                   (SELECT 1
                                      FROM TMP_BANK_TO_EXPORT t
                                     WHERE t.x_prs_id = prs_id));

        DBMS_OUTPUT.put_line ('ins-2 ' || SQL%ROWCOUNT);

        -- io 20231211 перевіряємо чи для всіх рядків визначений реципієнт
        SELECT COUNT (1)
          INTO l_no_rec_cnt
          FROM TMP_BANK_TO_EXPORT t
         WHERE t.x_rec IS NULL;

        DBMS_OUTPUT.put_line ('l_no_rec_cnt =  ' || l_no_rec_cnt);

        IF l_no_rec_cnt > 0
        THEN
            SELECT LISTAGG (nb_num || ' ' || nb_name)
                       WITHIN GROUP (ORDER BY nb_id, '')
              INTO l_err_msg
              FROM (SELECT DISTINCT nb_id, nb_num, nb_name
                      FROM TMP_BANK_TO_EXPORT  t
                           JOIN uss_ndi.v_ndi_bank b ON x_nb_id = b.nb_id
                     WHERE t.x_rec IS NULL);

            RAISE exNoRec;
        END IF;

        SELECT com_org
          INTO l_com_org
          FROM payroll pr
         WHERE pr_id = p_pr_id;

        SELECT COUNT (1)
          INTO l_no_rec_cnt
          FROM TMP_BANK_TO_EXPORT t
         WHERE     1 = 1
               AND NOT EXISTS
                       (SELECT *
                          FROM ikis_rbm.v_recipient_mail rm
                         WHERE     rm_rec = x_rec
                               AND rm.rm_st = 'A'
                               AND rm.com_org IN (l_com_org, 50000));

        DBMS_OUTPUT.put_line ('l_no_rec_rm_cnt =  ' || l_no_rec_cnt);

        IF l_no_rec_cnt > 0
        THEN
            RAISE exNoRecRm;
        END IF;

        -- витягуємо номер банку з головного, для тих дирекцій, у кого не вказано...
        UPDATE TMP_BANK_TO_EXPORT t
           SET t.x_nb_number =
                   (SELECT b0.nb_num
                      FROM uss_ndi.v_ndi_bank  b
                           LEFT JOIN uss_ndi.v_ndi_bank b0
                               ON b.nb_nb = b0.nb_id
                     WHERE b.nb_id = x_nb_id)
         WHERE     t.x_nb_number IS NULL
               AND EXISTS
                       (SELECT b0.nb_num
                          FROM uss_ndi.v_ndi_bank  b
                               LEFT JOIN uss_ndi.v_ndi_bank b0
                                   ON b.nb_nb = b0.nb_id
                         WHERE b.nb_id = x_nb_id);

        DELETE FROM TMP_BANK_TO_EXPORT
              WHERE x_rec IS NULL;

        --  Ikis_Mil_Common.JobSaveMessage('Формуємо файли');

        SELECT c.npc_code,
               c.npc_name,
               NULL    AS pr_pay_dt, -- #66415 Доработка функции "Формирование електронных ведомосте":
               CASE
                   WHEN pr_tp = 'M' THEN '01'
                   WHEN pr_tp = 'C' THEN '03'
                   ELSE '02'
               END     AS pr_type,
               pr_pc_cnt,
               c.npc_id
          INTO l_pr_code,
               l_pr_name,
               l_pay_dt,
               l_pr_type,
               l_pr_pc_cnt,
               l_npc_id
          FROM payroll  p
               /*left*/
               JOIN uss_ndi.v_ndi_payment_codes c ON c.npc_id = p.pr_npc
         --left join ndi_payroll_type t on pr_npt = npt_id
         WHERE pr_id = p_pr_id;

        /*  коригуючих поки не буде
        if l_pr_type = '03' then
          --l_pr_code := '';
          select max(f.ef_pkt), max(pr_pr) into l_pkt_cor, l_ef_pr_pr
          from payroll pc
          join exchangefiles f on f. = pc.pr_pr
          where pc.pr_id = p_pr_id
            and pc.pr_tp = 'C';

          if l_exch_version != 'V002' then
            raise exBadVer4Cor;
          end if;

          if l_pkt_cor is null then
            raise exNoPkt4Cor;
          end if;

          -- дата виплати коригуючої = даті виплати ВВ
          select \*case when p.pr_tp in ('A','M') and p.pr_create_dt < p.pr_start_dt then trunc(p.pr_pay_dt, 'MM')+4
                       else p.pr_pay_dt
                  end*\
                  p.pr_pay_dt
          into l_pay_dt
          from payroll p
          left join ndi_payroll_type t on pr_npt = npt_id
          where pr_id = l_ef_pr_pr;

          select count(ef_pkt) into l_rbm_pkt_cnt
          from exchcreatesession s
          join exchangefiles f
            on ef_ecs = ecs_id
          where ef_pr = l_ef_pr_pr
            and s.ecs_filter like l_ef_pr_pr||'#PB#%';
        end if;*/

        IF l_pr_type IN ('01', '02', '03')
        THEN
            INSERT INTO exchangefiles (ef_id,
                                       ef_po,
                                       ef_pr,
                                       com_wu,
                                       com_org,
                                       ef_tp,
                                       ef_name,
                                       ef_data,
                                       ef_visual_data,
                                       ef_header,
                                       ef_main_tag_name,
                                       ef_data_name,
                                       ef_ecp_list_name,
                                       ef_ecp_name,
                                       ef_ecp_alg,
                                       ef_st,
                                       ef_ident_data,
                                       ef_dt,
                                       ef_ecs,
                                       ef_rec)
                SELECT 0,
                       p_po_id,
                       p_pr_id,
                       NULL,
                       b_org_id,
                       'PR',
                       v_f_name,
                       v_file_data,                                    --NULL,
                       v_visual_data,
                       v_file_header,
                       v_file_header_name,
                       v_file_data_name,
                       v_ecp_list_name,
                       v_ecp_name,
                       v_ecp_alg,
                       'Z',
                       v_ident_data,
                       SYSDATE,
                       l_ecs,
                       v_rec
                  FROM (WITH
                            dat
                            AS
                                (SELECT SUBSTR (
                                            TRIM (TO_CHAR (org_id, '000009')),
                                            1,
                                            3)
                                            b_opfu,
                                        SUBSTR (
                                            REPLACE (org_name,
                                                     'Головне управління ',
                                                     'ГУ'),
                                            1,
                                            27)
                                            b_opfu_name,
                                        c.npc_name
                                            AS b_pr_header,
                                        org_id
                                            AS b_org_id,
                                        TOOLS.GetOrgSName (org_id)
                                            AS b_org_name,
                                        pr_create_dt
                                            AS b_pr_dt
                                   FROM payroll                      p,
                                        v_opfu,
                                        uss_ndi.v_ndi_payment_codes  c
                                  WHERE     pr_id = p_pr_id
                                        AND com_org = org_id
                                        AND c.npc_id = p.pr_npc)
                        SELECT    XMLELEMENT ("opfu_code", b_org_id)
                               || XMLELEMENT ("opfu_name",             /*'-'*/
                                              CONVERT (b_org_name, 'UTF8'))
                               || XMLELEMENT ("date_cr",
                                              TO_CHAR (b_pr_dt, 'DDMMYYYY'))
                               || XMLELEMENT ("MFO_filia", z_nb_mfo)
                               || XMLELEMENT ("filia_num", z_nb_num)
                               || XMLELEMENT ("filia_name", '')
                               || XMLELEMENT ("full_sum", z_sum * 100)
                               || XMLELEMENT ("full_lines", z_cnt)
                               || XMLELEMENT ("type", l_pr_type)
                               || XMLELEMENT ("id_cor", z_pkt4cor)
                                   AS v_file_header,
                                  'МФО: '
                               || z_nb_mfo
                               || '; Відділення:'
                               || z_nb_num
                               || '; Сума: '
                               || TO_CHAR (z_sum, '999999999990.00')
                               || '; Рядків: '
                               || z_cnt
                                   AS v_ident_data,
                               'paymentlists'
                                   AS v_file_header_name,
                               'file_data'
                                   AS v_file_data_name,
                               'ecp_list'
                                   AS v_ecp_list_name,
                               'ecp'
                                   AS v_ecp_name,
                               'MD'
                                   AS v_ecp_alg,
                               b_org_id,
                               z_nb_mfo || '.' || b_org_id
                                   AS v_f_name,
                               z_rec
                                   v_rec,
                               UTL_COMPRESS.lz_compress (
                                   tools.ConvertC2B (
                                       (SELECT XMLELEMENT (
                                                   "description_files",
                                                   XMLELEMENT (
                                                       "opfu_code",
                                                       b_org_id),
                                                   XMLELEMENT (
                                                       "opfu_name",
                                                       CONVERT (
                                                           b_org_name,
                                                           'UTF8')),
                                                   XMLELEMENT (
                                                       "date_cr",
                                                       TO_CHAR (
                                                           b_pr_dt,
                                                           'DDMMYYYY')),
                                                   XMLELEMENT (
                                                       "MFO_filia",
                                                       z_nb_mfo),
                                                   XMLELEMENT (
                                                       "filia_num",
                                                       z_nb_num),
                                                   XMLELEMENT (
                                                       "filia_name",
                                                       ''),
                                                   XMLELEMENT (
                                                       "full_sum",
                                                         z_sum
                                                       * 100),     -- 20210328
                                                   XMLELEMENT (
                                                       "full_lines",
                                                       z_cnt),
                                                   XMLELEMENT (
                                                       "type",
                                                       l_pr_type),
                                                   XMLELEMENT (
                                                       "id_cor",
                                                       z_pkt4cor),
                                                   XMLELEMENT (
                                                       "branches",
                                                       XMLAGG (XMLELEMENT (
                                                                   "row",
                                                                   XMLELEMENT (
                                                                       "branch_num",
                                                                       sl.x_nb_filia),
                                                                   XMLELEMENT (
                                                                       "branch_sum",
                                                                         sl.x_sum
                                                                       * 100),
                                                                   XMLELEMENT (
                                                                       "branch_lines",
                                                                       sl.x_cnt),
                                                                   XMLELEMENT (
                                                                       "date_pay",
                                                                       TO_CHAR (
                                                                           sl.x_prs_pay_dt,
                                                                           'DDMMYYYY')),
                                                                   XMLELEMENT (
                                                                       "num_list",
                                                                       x_prs_num),
                                                                   XMLELEMENT (
                                                                       "file_name",
                                                                          tools.PR (
                                                                              x_nb_number,
                                                                              5)
                                                                       || tools.PR (
                                                                              NVL (
                                                                                  x_nb_filia,
                                                                                  x_nb_number),
                                                                              5)
                                                                       || -- #82683 io 20230102  номер підзвітної філії - такий самий як центральної філії
                                                                          tools.PR (
                                                                              x_prs_pay_dt,
                                                                              2)
                                                                       || '.'
                                                                       || tools.PR (
                                                                              x_opfu,
                                                                              3)),
                                                                   XMLELEMENT (
                                                                       "file_data",
                                                                       tools.encode_base64 ( /* io 20240513 utl_compress.lz_compress*/
                                                                           (tools.ConvertC2B (
                                                                                GetFiliaFile (
                                                                                    p_pr_id   =>
                                                                                        p_pr_id,
                                                                                    p_nb_id   =>
                                                                                        x_nb_id,
                                                                                    p_prs_pay_dt   =>
                                                                                        x_prs_pay_dt,
                                                                                    p_bnk_cnt   =>
                                                                                        x_cnt,
                                                                                    p_bnk_sum   =>
                                                                                          x_sum
                                                                                        * 100,
                                                                                    p_convert_symb   =>
                                                                                        p_convert_symb,
                                                                                    p_pr_code   =>
                                                                                        l_pr_code))))),
                                                                   XMLELEMENT (
                                                                       "branch_opfu_code",
                                                                       b_org_id) -- #101884 io 20240501
                                                                                )
                                                               ORDER BY
                                                       x_prs_num))).getClobVal ()
                                          FROM (  SELECT x_opfu,
                                                         x_nb_id,
                                                         x_prs_pay_dt,
                                                         x_nb_number,
                                                         x_nb_filia,
                                                         x_prs_num,
                                                         x_nb_main_code,
                                                         x_nb_mfo,
                                                         COUNT (
                                                             1)
                                                             AS x_cnt,
                                                         SUM (
                                                             x_prs_sum)
                                                             AS x_sum
                                                    FROM TMP_BANK_TO_EXPORT
                                                             vv
                                                GROUP BY x_opfu,
                                                         x_nb_id,
                                                         x_prs_pay_dt,
                                                         x_nb_number,
                                                         x_nb_filia,
                                                         x_prs_num,
                                                         x_nb_main_code,
                                                         x_nb_mfo
                                                ORDER BY x_opfu,
                                                         x_nb_id,
                                                         x_nb_number,
                                                         x_nb_filia,
                                                         x_prs_pay_dt,
                                                         x_prs_num,
                                                         x_nb_main_code,
                                                         x_nb_mfo)
                                               sl
                                         WHERE     sl.x_nb_id =
                                                   z_nb_id
                                               AND (   sl.x_nb_mfo =
                                                       z_nb_mfo
                                                    OR (    sl.x_nb_mfo
                                                                IS NULL
                                                        AND z_nb_mfo
                                                                IS NULL)))))
                                   AS v_file_data,
                               tools.ConvertB2C (
                                   BuildAccompSheet_html (p_po_id,
                                                          p_pr_id,
                                                          p_prs_tp,
                                                          14,      -- p_format
                                                          z_nb_id,
                                                          z_nb_num,
                                                          z_nb_mfo))
                                   AS v_visual_data
                          FROM (  SELECT x_nb_id             AS z_nb_id,
                                         x_nb_number         AS z_nb_num, /* x_prs_pay_dt AS z_pr_pay_dt,*/
                                         x_nb_mfo            AS z_nb_mfo,
                                         x_rec               AS z_rec,
                                         COUNT (1)           AS z_cnt,
                                         SUM (x_prs_sum)     AS z_sum,
                                         /*max((
                                          select max(f.ef_pkt) from exchangefiles f
                                          where ef_pr = l_ef_pr_pr
                                            and instr(ef_header, '<filia_num>'||x_nb_number||'</filia_num>') > 0
                                          ))*/
                                         NULL                AS z_pkt4cor
                                    FROM TMP_BANK_TO_EXPORT ma
                                GROUP BY x_nb_id,
                                         x_nb_number,       /* x_prs_pay_dt,*/
                                         x_nb_mfo,
                                         x_rec),
                               dat);
        --   dbms_output.put_line('222 sql%rowcount = '||sql%rowcount||', l_pr_type = '||l_pr_type||', l_pr_pc_cnt = '||l_pr_pc_cnt||', l_ef_pr_pr='||l_ef_pr_pr||'...') ;
        -- Пакет для коригуючих створюємо навіть якщо к-ть справ = 0
        --- #67415 Доработать формування електрон. додатк. ведомостей на однораз выплаты:
        --- Тимчасово!!!
        --- Додаткові по одноразових з вивантаження файлу зі списками в ПЕОД
        END IF;

        -- #63118 заливаємо дані по відомості в ikis_finzvit  за допомогою ikis_rbm

        INSERT INTO ikis_rbm.tmp_exchangefiles_m1 (ef_id,
                                                   ef_pr,
                                                   com_wu,
                                                   com_org,
                                                   ef_tp,
                                                   ef_name,
                                                   ef_data, -- ivashchuk 20160513 #15516
                                                   ef_visual_data,
                                                   ef_header,
                                                   ef_main_tag_name,
                                                   ef_data_name,
                                                   ef_ecp_list_name,
                                                   ef_ecp_name,
                                                   ef_ecp_alg,
                                                   ef_st,
                                                   ef_dt,
                                                   ef_ident_data,
                                                   ef_ecs,
                                                   ef_rec,
                                                   ef_pr_code,
                                                   ef_pr_name,
                                                   ef_pr_pay_dt,
                                                   ef_pr_pr,
                                                   ef_npc)
            SELECT ef_id,
                   p_pr_id     AS ef_pr,
                   com_wu,
                   com_org,
                   ef_tp,
                   ef_name,
                   ef_data,
                   /*ef_header*/
                   ef_visual_data,
                   ef_header,
                   ef_main_tag_name,
                   ef_data_name,
                   ef_ecp_list_name,
                   ef_ecp_name,
                   ef_ecp_alg,
                   ef_st,
                   ef_dt,
                   ef_ident_data,
                   ef_ecs,
                   ef_rec,
                   l_pr_code,
                   l_pr_name,
                   /*trunc(l_pay_dt, 'MM')+4*/
                   l_pay_dt -- #66415 Доработка функции "Формирование електронных ведомосте":
                           ,
                   l_ef_pr_pr,
                   l_npc_id                                          -- #79230
              FROM exchangefiles
             WHERE ef_ecs = l_ecs;

        ikis_rbm.RDM$APP_EXCHANGE.GenPaketsFromTMPTable; -- ivashchuk 20160513 #15516

        UPDATE exchangefiles f
           SET ef_pkt =
                   (SELECT t.ef_pkt
                      FROM ikis_rbm.tmp_exchangefiles_m1 t
                     WHERE t.ef_id = f.ef_id)
         WHERE     1 = 1                                   --- ef_pr = p_pr_id
               AND ef_ecs = l_ecs
               AND EXISTS
                       (SELECT 1
                          FROM ikis_rbm.tmp_exchangefiles_m1 t
                         WHERE t.ef_id = f.ef_id);

        UPDATE exchcreatesession
           SET ecs_stop_dt = SYSDATE
         WHERE ecs_id = l_ecs;

        -- прописуємо ід сформованого пакета ПЕОД
        -- оскільки пакети по ВВ ПЕОД формуються під час фіксації ПД...
        UPDATE uss_esr.payroll_reestr pr
           SET pr.pe_rbm_pkt =
                   (SELECT MIN (f.ef_pkt)
                      FROM exchangefiles f
                     WHERE     f.ef_po = pr.pe_po
                           AND f.ef_pr = pr.pe_src_entity
                           AND f.ef_po = p_po_id
                           AND f.ef_pr = p_pr_id
                           AND f.ef_ecs = l_ecs)
         WHERE     pr.pe_po = p_po_id
               --- and pr.pe_nbg = l_nbg_id
               AND pr.pe_pay_tp = 2
               AND pr.pe_npc = l_npc_id
               AND pr.pe_src_entity = p_pr_id
               AND pr.pe_nb = p_nb_id
               AND pr.pe_pr = p_pr_id
               AND pr.pe_rbm_pkt IS NULL
               AND EXISTS
                       (SELECT 1
                          FROM exchangefiles f
                         WHERE     f.ef_po = pr.pe_po
                               AND f.ef_pr = pr.pe_src_entity
                               AND f.ef_po = p_po_id
                               AND f.ef_pr = p_pr_id
                               AND f.ef_ecs = l_ecs);
    --  Ikis_Mil_Common.JobSaveMessage('Завершено формування файлів');
    EXCEPTION
        WHEN exNoRec
        THEN
            raise_application_error (
                -20000,
                   'Помилка формування файлів для електронного обміну : не вдалося визначити реципієнта ПЕОД: '
                || l_err_msg);
        WHEN exNoRecRm
        THEN
            raise_application_error (
                -20000,
                   'Помилка формування файлів для електронного обміну : не вдалося визначити одержувачів реципієнта ПЕОД: '
                || l_err_msg);
        WHEN exNoPkt4Cor
        THEN
            raise_application_error (
                -20000,
                'Помилка формування файлів для електронного обміну : Для коригуючої відомості не вдалося визначити ід пакета ПЕОД відповідної породжуючої відоості!');
        WHEN exBadVer4Cor
        THEN
            raise_application_error (
                -20000,
                'Помилка формування файлів для електронного обміну : В даній версії ПЗ не підтримується формування пакетів ПЕОД для коригуючих відомостей!');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка формування файлів для електронного обміну : '
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;

    --   #87334 Обмін з кабінетом банку (допомоги крім ВПО)
    PROCEDURE BuildExchFilesByPo (p_po_id payroll.pr_id%TYPE)
    IS
        l_po_st       uss_esr.pay_order.po_st%TYPE;
        l_nb_id       NUMBER;
        l_nbg_id      NUMBER;
        l_npc_id      NUMBER;
        l_lock_init   TOOLS.t_lockhandler;
    BEGIN                                               -- поки не формуємо!!!
        --
        DBMS_OUTPUT.enable;
        -- dbms_output.disable;
        tools.WriteMsg ('API$ESR_EXCHANGE.' || $$PLSQL_UNIT);

        l_lock_init :=
            TOOLS.request_lock (
                p_descr   => 'BuildJsonpktByPo_' || p_po_id,
                p_error_msg   =>
                    'В даний момент вже виконується створення пакетів!');

        SELECT nbg_id
          INTO l_nbg_id
          FROM uss_ndi.v_ndi_budget_program nbg
         WHERE nbg.nbg_kpk_code = '2501530'         /* TN 20230504 '2501480'*/
                                           ;

        SELECT npc_id
          INTO l_npc_id
          FROM uss_ndi.v_ndi_payment_codes npc
         WHERE npc.npc_code = '29';

        DBMS_OUTPUT.put_line ('p_po_id =  ' || p_po_id);

        BEGIN
            SELECT po_st, po.po_nb_src
              INTO l_po_st, l_nb_id
              FROM uss_esr.pay_order po
             WHERE po_id = p_po_id AND po.po_src = 'OUT' AND po.po_st = 'A';
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RETURN;        -- raise_application_error(-20000, 'po_st!!!');
        END;

        DBMS_OUTPUT.put_line ('l_nb_id =  ' || l_nb_id);

        FOR pe
            IN (  SELECT pe_pr,
                         pe.pe_src_entity,
                         pe_bnk_rbm_code,
                         pe_nb,
                         pe.pe_pay_tp,
                         SUM (pe_row_cnt)     AS pr_pe_row_cnt,
                         SUM (pe_sum)         AS pr_pe_sum
                    FROM uss_esr.payroll_reestr pe
                   WHERE     pe_po = p_po_id
                         AND pe.pe_pay_tp IN (1, 2) -- uss_ndi.v_ddn_pe_pay_tp 1-Post, 2-Bank
                         AND pe.pe_npc != l_npc_id
                         AND pe.pe_rbm_pkt IS NULL -- io 20221111 як додатковий захист від повторного створення пакетів
                         AND EXISTS
                                 (                       -- #94979 io 20231208
                                  SELECT 1
                                    FROM uss_esr.paramsesr prm
                                   WHERE     prm.prm_code = 'CREATE_RBM_PKT'
                                         AND prm.prm_value = 'T'
                                         AND prm.com_org = pe.com_org)
                GROUP BY pe_pr,
                         pe.pe_src_entity,
                         pe_bnk_rbm_code,
                         pe_nb,
                         pe.pe_pay_tp)
        LOOP
            DBMS_OUTPUT.put_line (
                'pe.pe_pr =  ' || pe.pe_pr || ', pe.pe_nb =  ' || pe.pe_nb);

            IF pe.pe_pay_tp = 2
            THEN
                BuildBankExchFiles (p_po_id    => p_po_id,
                                    p_pr_id    => pe.pe_pr,
                                    p_prs_tp   => 'PB',
                                    p_nb_id    => pe.pe_nb);
            END IF;

            IF pe.pe_pay_tp = 1
            THEN                                                 -- IC #111345
                BuildPostExchFiles (p_po_id    => p_po_id,
                                    p_pr_id    => pe.pe_pr,
                                    p_prs_tp   => 'PP',
                                    p_rec_id   => 150         -- АТ "УКРПОШТА"
                                                     );
            END IF;
        /*     uss_esr.api$esr_exchange.BuildJsonExchFiles(p_po_id   => p_po_id,
                                                         p_pr_id   => pe.pe_src_entity,
                                                         p_prs_tp  => 'PB',
                                                         p_nb_id   => pe.pe_nb
                                                         );    */
        END LOOP;
    EXCEPTION
        /*  when exBadPoSt then
            raise_application_error(-20000, 'Помилка формування файлів для електронного обміну : Для коригуючої відомості не вдалос!');
          when exBadVer4Cor then
            raise_application_error(-20000, 'Помилка формування файлів для електронного обміну : В даній версії ПЗ не підтримується формування пакетів ПЕОД для коригуючих відомостей!');    */
        WHEN OTHERS
        THEN
            IF                                             /*sqlcode = 20000*/
               INSTR (SQLERRM, 'ORA-20000') > 0
            THEN
                RAISE;
            ELSE
                raise_application_error (
                    -20000,
                       'Помилка формування файлів для електронного обміну : '
                    || CHR (10)
                    || REPLACE (
                              DBMS_UTILITY.FORMAT_ERROR_STACK
                           || ' => '
                           || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                           'ORA-20000:')
                    || CHR (10)
                    || SQLERRM);
            END IF;
    END;

    -- info:  Формування пакетів зі списками соцвиплат (по ВВ ЄСР) в ПЕОД
    -- params: p_po_id – ід ПД, p_pr_id – ід ВВ, p_prs_tp - тип виплати,  p_nb_id - ід банку
    -- note:  Назва файлу:EMERGQ_AAAA_YYMM_TT_PP_NNNNN.json
    /*де
    EMERGQ – маска реєстру запиту на екстрену виплату;
    AAAA — код району СПСЗН;
    YY — рік, за який нараховано виплату;
    MM — місяць, за який нараховано виплату;
    TT — тип відомості: 98 - на зарахування субсидій , 99 - на зарахування пільг, 96 – на зарахування допомог; 95 - допомога ВПО
    PP - номер партії для випадку поділу на декілька файлів по району, при перевищені кількості записів в одному файлі;*/
    /*
    Json формується по записах v_payroll_reestr, тому вхідні параметри
    + p_po_id, оскільки потрібно  враховувати обрані дні виплати, причому їх може бути більше 1
    */
    PROCEDURE BuildJsonExchFiles (
        p_po_id    pay_order.po_id%TYPE,
        p_pr_id    payroll.pr_id%TYPE,
        p_prs_tp   pr_sheet.prs_tp%TYPE,
        p_nb_id    uss_ndi.v_ndi_bank.nb_id%TYPE:= NULL)
    IS
        l_filter         VARCHAR2 (250);
        l_ecs            exchcreatesession.ecs_id%TYPE;
        l_cnt            INTEGER;
        l_use_iban       VARCHAR2 (10) := 'T'; ---parammil.prm_value%TYPE := nvl(tools.GP('USE_IBAN',sysdate), 'F');
        l_pr_code        VARCHAR2 (10);
        l_pr_name        VARCHAR2 (250);
        l_pr_type        VARCHAR2 (10);
        l_pay_dt         DATE;
        l_ef_pr_pr       NUMBER;
        l_pr_pc_cnt      NUMBER;
        exNoPkt4Cor      EXCEPTION;
        exBadVer4Cor     EXCEPTION;
        l_pr_dt          DATE;
        l_wu             NUMBER
            := SYS_CONTEXT (uss_esr_context.gContext, uss_esr_context.gUID);

        l_portion_size   NUMBER := 999999; -- io 20221110  Знімаємо обмеження, оскільки АСОПД формувало пакети на 163011 : pkt_id=3035627 EMERGQ_3012_2209_95_03_163011.zip
        -- 20000; --20220506 io збільшую до 20К, оскільки на промі є файли в 2К+ записів- порция - єто ограничение до 200 людей. Для обеспечения гарантированной передачи файликов
        l_nbg_id         NUMBER;
        l_npc_id         NUMBER;
    BEGIN
        SELECT nbg_id
          INTO l_nbg_id
          FROM uss_ndi.v_ndi_budget_program nbg
         WHERE nbg.nbg_kpk_code = '2501530'         /* TN 20230504 '2501480'*/
                                           ;

        SELECT npc_id
          INTO l_npc_id
          FROM uss_ndi.v_ndi_payment_codes npc
         WHERE npc.npc_code = '29';

        --  COMMIT;
        DELETE FROM TMP_BANK_TO_EXPORT;

        DELETE FROM ikis_rbm.tmp_exchangefiles_m1;

        -- контроль на уже створені пакети
        SELECT COUNT (1)
          INTO l_cnt
          FROM uss_esr.payroll_reestr pr
         WHERE     pr.pe_po = p_po_id
               AND pr.pe_nbg = l_nbg_id
               AND pr.pe_pay_tp = 2
               AND pr.pe_npc = l_npc_id
               AND pr.pe_src_entity = p_pr_id
               AND pr.pe_nb = p_nb_id
               AND pr.pe_rbm_pkt > 0;

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                'Створення файлів з даними параметрами вже виконувалось: існують пакети ПЕОД по реєсстрах даного ПД!');
        END IF;

        --  Ikis_Mil_Common.JobSaveMessage('Розпочато формування файлів для електронного обміну - список на банк (по рахункам)');
        l_filter :=
               'PO'
            || p_po_id
            || '#'
            || 'PR'
            || p_pr_id
            || '#'
            || p_prs_tp
            || '#'
            || p_nb_id;

        SELECT COUNT (1)
          INTO l_cnt
          FROM exchcreatesession
         WHERE ecs_filter = l_filter;

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                'Створення файлів з даними параметрами вже виконувалось!');
        END IF;

        INSERT INTO exchcreatesession (ecs_id, ecs_start_dt, ecs_filter)
             VALUES (0, SYSDATE, l_filter)
          RETURNING ecs_id
               INTO l_ecs;

        --  Ikis_Mil_Common.JobSaveMessage('Обробляємо дані відомості');
        INSERT INTO TMP_BANK_TO_EXPORT (X_NB_ID,
                                        X_NB_NUMBER,
                                        X_NB_FILIA,
                                        X_PRS_PAY_DT,
                                        X_PRS_ACCOUNT,
                                        X_PRS_SUM,
                                        X_PRS_PIB,
                                        X_PRS_INN,
                                        X_NB_MFO,
                                        X_NB_MAIN_CODE,
                                        X_OPFU,
                                        X_PRS_NUM,
                                        X_REC,
                                        X_IS_MIGR,
                                        X_PC_NUM,
                                        X_COR_RSN,
                                        X_NB_NAME,
                                        x_last_name,
                                        x_first_name,
                                        x_second_name,
                                        x_org,
                                        x_portion,
                                        x_prs_id)
            SELECT nb_id,
                   x_nb_number,
                   x_nb_filia,
                   x_pay_dt,
                   prs_account,
                   prs_sum,
                   x_prs_pib,
                   prs_inn,
                   nb_mfo,
                   x_nb_main_code,
                   x_opfu,
                   prs_num,
                   x_rec,
                   x_is_migr,
                   x_pc_number,
                   x_prs_cor_rsn,
                   nb_name,
                   prs_ln,
                   prs_fn,
                   prs_mn,
                   com_org,
                     TRUNC (
                           (  ROW_NUMBER ()
                                  OVER (
                                      PARTITION BY nb_mfo,
                                                   x_rec,
                                                   com_org,
                                                   TO_CHAR (x_pay_dt, 'YYMM')
                                      ORDER BY prs_num   /*x_pay_dt, prs_inn*/
                                                      )
                            - 1)
                         / l_portion_size)
                   + 1    AS x_part,
                   prs_id
              FROM (SELECT b.nb_id,
                           prs_id,
                           ROW_NUMBER ()
                               OVER (PARTITION BY prs_nb
                                     ORDER BY s.prs_pay_dt, prs_inn, prs_id)
                               AS prs_num, -- io 20220727  на даний момент ==0, тому розраховуємо для банків
                           s.prs_pay_dt
                               AS x_pay_dt,
                           LPAD (b.nb_num, 5, '0')
                               x_nb_number,
                           NULL
                               AS x_nb_filia,
                           LPAD (b.nb_mfo, 9, '0')
                               nb_mfo,
                           LPAD (NVL (TRIM (prs_account), 0),           /*19*/
                                                              29 /*l_acc_length_rows*/
                                                                , '0')
                               prs_account,
                           TRIM (prs_ln || ' ' || prs_fn || ' ' || prs_mn)
                               x_prs_pib,
                           prs_sum,
                           prs_pc_num,
                           /*    #91933    NVL(case when trim(translate(prs_inn, '0123456789', ' ')) is null then lpad(prs_inn, 10, '0')
                                                    else '0000000000' end , '0000000000')  prs_inn,*/
                           -- #91933 З ощаду прийшло повідомлення, що потрібно вказувати по безкоднікам номер паспорту і через це вони блокують цих людей на виплату.
                           CASE
                               WHEN     REGEXP_LIKE (TRIM (prs_inn),
                                                     '^\d{10}$')
                                    AND TRIM (prs_inn) NOT IN ('0000000000')
                               THEN
                                   TRIM (prs_inn)
                               WHEN TRIM (prs_doc_num) IS NOT NULL
                               THEN
                                   TRIM (prs_doc_num)
                               ELSE
                                   '0000000000'
                           END
                               prs_inn,
                           /*null*/
                           NVL (b0.nb_num, b.nb_num)
                               AS x_nb_main_code,
                           SUBSTR (TRIM (TO_CHAR (pr.com_org, '000009')),
                                   1,
                                   3)
                               AS x_opfu,
                           ----------TRIM(to_char(pr.com_org, '00009')) AS x_opfu,
                            (SELECT rec_id
                               FROM ikis_rbm.v_recipient r
                              WHERE r.rec_nb = NVL (b0.nb_id, b.nb_id))
                               AS x_rec,
                           --7 as x_rec,
                           ''
                               AS x_is_migr,
                           prs_pc_num
                               AS x_pc_number,
                           NULL
                               AS x_prs_cor_rsn,
                           b.nb_name,
                           prs_ln,
                           prs_fn,
                           prs_mn,
                           pr.com_org
                      -- select *
                      FROM payroll  pr
                           JOIN pr_sheet s ON pr_id = prs_pr
                           JOIN uss_ndi.v_ndi_bank b ON s.prs_nb = b.nb_id
                           LEFT JOIN uss_ndi.v_ndi_bank b0
                               ON b.nb_nb = b0.nb_id
                           JOIN uss_esr.payroll_reestr pe
                               ON     pe.pe_src_entity = pr_id
                                  AND pe.pe_npc = pr.pr_npc
                                  AND pe.pe_nb = s.prs_nb
                                  AND pe.pe_pay_dt = s.prs_pay_dt
                     WHERE     pr_id = p_pr_id
                           AND pr_pay_tp = 'BANK'                --p_pr_pay_tp
                           AND NVL (b0.nb_id, b.nb_id) = p_nb_id
                           -- AND pr_st IN ('P', 'F', 'FB')
                           AND pe.pe_po = p_po_id
                           AND pe.pe_nbg = l_nbg_id
                           AND pe.pe_pay_tp = 2
                           AND pe.pe_npc = l_npc_id
                           AND prs_tp IN ('PB')
                           AND prs_sum                                   /*<*/
                                       > 0                      -- io 20220727
                           AND prs_st = 'NA' --  io 20221023  лише статус нараховано, виключаємо блокування вручну і т.д.
                                            );

        -- io 20220727 оновлюємо нумерацію списків
        UPDATE pr_sheet s
           SET s.prs_num =
                   (SELECT t.x_prs_num
                      FROM TMP_BANK_TO_EXPORT t
                     WHERE x_prs_id = prs_id)
         WHERE     prs_pr = p_pr_id
               AND prs_tp IN ('PB')
               AND prs_sum <> 0
               AND EXISTS
                       (SELECT 1
                          FROM TMP_BANK_TO_EXPORT t
                         WHERE x_prs_id = prs_id);

        --  Ikis_Mil_Common.JobSaveMessage('Формуємо файли');

        SELECT c.npc_code,                                   /*'ПВП ДКГ: '||*/
               c.npc_name,
               NULL    AS pr_pay_dt, -- #66415 Доработка функции "Формирование електронных ведомосте":
               CASE
                   WHEN pr_tp = 'M'                   /*or t.npt_code = '01'*/
                                    THEN '01'
                   WHEN pr_tp = 'C'                  /*or t.npt_code = '103'*/
                                    THEN '03'
                   -- when pr_tp = 'O' then /*'04'  #68539 */ substr(t.npt_code, -2)
                   ELSE '02'
               END     AS pr_type,
               pr_pc_cnt,
               p.pr_create_dt
          INTO l_pr_code,
               l_pr_name,
               l_pay_dt,
               l_pr_type,
               l_pr_pc_cnt,
               l_pr_dt
          FROM payroll  p
               /*left*/
               JOIN uss_ndi.v_ndi_payment_codes c ON c.npc_id = p.pr_npc
         --left join ndi_payroll_type t on pr_npt = npt_id
         WHERE pr_id = p_pr_id;


        IF l_pr_type IN ('01', '02', '03')
        THEN
            INSERT INTO exchangefiles (ef_id,
                                       ef_po,
                                       ef_pr,
                                       com_wu,
                                       com_org,
                                       ef_tp,
                                       ef_name,
                                       ef_data,
                                       ef_visual_data,
                                       ef_header,
                                       ef_main_tag_name,
                                       ef_data_name,
                                       ef_ecp_list_name,
                                       ef_ecp_name,
                                       ef_ecp_alg,
                                       ef_st,
                                       ef_ident_data,
                                       ef_dt,
                                       ef_ecs,
                                       ef_rec)
                SELECT 0,
                       p_po_id,
                       p_pr_id,
                       l_wu,
                       x_org                                         /*50000*/
                            ,
                       'PR',
                       x_file_name,
                       x_file_data,                                    --NULL,
                       /*x_file_name||chr(10)||
                       'Кількість записів: '||x_cnt||chr(10)||'Сума: '||x_sum*/
                       XMLELEMENT (
                           "div",
                           (SELECT XMLELEMENT (
                                       "div",
                                       XMLELEMENT (
                                           "style",
                                           'table.z, th.z, td.z {border: 1px solid black; border-collapse: collapse; text-align: right;}'),
                                       XMLELEMENT ("p", x_file_name),
                                       XMLELEMENT (
                                           "p",
                                              'Дата створення файлу: '
                                           || TO_CHAR (
                                                  SYSDATE,
                                                  'DD.MM.YYYY HH24:MI:SS')))
                              FROM DUAL
                             WHERE ROWNUM = 1),
                           (SELECT XMLELEMENT (
                                       "table",
                                       XMLATTRIBUTES ('z' AS "class"),
                                       --XMLATTRIBUTES('"font-family:Arial, sans-serif;font-size:14px;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;"' AS "class"),
                                       XMLELEMENT (
                                           "tr",
                                           XMLATTRIBUTES ('z' AS "class"),
                                           XMLELEMENT (
                                               "td",
                                               XMLATTRIBUTES ('z' AS "class"),
                                               'Орган'),
                                           XMLELEMENT (
                                               "td",
                                               XMLATTRIBUTES ('z' AS "class"),
                                               'Дата виплати'),
                                           XMLELEMENT (
                                               "td",
                                               XMLATTRIBUTES ('z' AS "class"),
                                               'Кількість одержувачів'),                     -- CONVERT(ln, 'UTF8')
                                           XMLELEMENT (
                                               "td",
                                               XMLATTRIBUTES ('z' AS "class"),
                                               'Сума, грн.')),
                                       XMLAGG (
                                           XMLELEMENT (
                                               "tr",
                                               XMLELEMENT (
                                                   "td",
                                                   XMLATTRIBUTES (
                                                       'z' AS "class"),
                                                   b.x_org),
                                               XMLELEMENT (
                                                   "td",
                                                   XMLATTRIBUTES (
                                                       'z' AS "class"),
                                                   NVL (
                                                       TO_CHAR (
                                                           b.x_prs_pay_dt,
                                                           'dd.mm.yyyy'),
                                                       'Всього')),
                                               XMLELEMENT (
                                                   "td",
                                                   XMLATTRIBUTES (
                                                       'z' AS "class"),
                                                   x_cnt),
                                               XMLELEMENT (
                                                   "td",
                                                   XMLATTRIBUTES (
                                                       'z' AS "class"),
                                                   TRIM (
                                                       TO_CHAR (
                                                           x_sum,
                                                           '999G999G999G999G999G999G999G990D00'))))))    AS x_visual
                              FROM (  SELECT b.x_org,
                                             b.x_prs_pay_dt,
                                             COUNT (1)             AS x_cnt,
                                             SUM (b.x_prs_sum)     AS x_sum
                                        FROM TMP_BANK_TO_EXPORT b
                                       WHERE     b.x_nb_mfo = t.x_nb_mfo
                                             AND b.x_rec = t.x_rec
                                             AND b.x_portion = t.x_part
                                    GROUP BY ROLLUP (b.x_org, b.x_prs_pay_dt)
                                    ORDER BY b.x_org, b.x_prs_pay_dt) b
                             WHERE     1 = 1
                                   AND (   (    b.x_org IS NOT NULL
                                            AND b.x_prs_pay_dt IS NOT NULL)
                                        OR (    b.x_org IS NULL
                                            AND b.x_prs_pay_dt IS NULL)))).getClobVal ()
                           AS x_visual_data,
                          --XMLELEMENT("opfu_code", x_org)||
                          --XMLELEMENT("opfu_name", /*'-'*/CONVERT(b_org_name, 'UTF8'))||
                          XMLELEMENT ("date_cr",
                                      TO_CHAR (l_pr_dt, 'DDMMYYYY'))
                       || --XMLELEMENT("MFO_filia", z_nb_mfo)||
                          --XMLELEMENT("filia_num", z_nb_num)||XMLELEMENT("filia_name", '')||
                          XMLELEMENT ("full_sum", x_sum * 100)
                       || XMLELEMENT ("full_lines", x_cnt)
                       || XMLELEMENT ("type", l_pr_type)
                       || XMLELEMENT ("code", l_pr_code)             -- #79230
                           AS x_file_header,
                       'paymentlists'
                           AS v_file_header_name,
                       /*'file_data'*/
                       'json'
                           AS v_file_data_name,
                       'p7s'
                           AS v_ecp_list_name,
                       'ecp'
                           AS v_ecp_name,
                       'MD'
                           AS v_ecp_alg,
                       --v_file_header_name, v_file_data_name, v_ecp_list_name,
                       --v_ecp_name, v_ecp_alg,
                       'Z',
                          'МФО: '
                       || x_nb_mfo
                       || '; Сума: '
                       || TO_CHAR (x_sum, '999999999990.00')
                       || '; Рядків: '
                       || x_cnt
                           AS v_ident_data,
                       SYSDATE,
                       l_ecs,
                       x_rec
                  FROM (  SELECT x_nb_mfo,
                                 x_rec,
                                 x_org,                    -- USS or ASOPD ???
                                 x_yymm,
                                 x_pr_tp,                          -- case ???
                                 x_part,
                                    'EMERGQ_'
                                 || SUBSTR (x_org, -4)
                                 || '_'
                                 || x_yymm
                                 || '_'
                                 || x_pr_tp
                                 || '_' --  #77084 код ОСЗН повинен мати 4 цифри. Код ЄІССС скорочуємо на першу цифру.
                                 || LPAD (x_part, 2, '0')
                                 || '_'
                                 || LPAD (MAX (x_rn), 5, '0')    /*||'.json'*/
                                     AS x_file_name,
                                 MAX (x_rn)
                                     rn,
                                 COUNT (1)
                                     AS x_cnt,
                                 SUM (x_prs_sum)
                                     AS x_sum,
                                 --EMERGQ_AAAA_YYMM_TT_PP_NNNNN.json
                                 UTL_COMPRESS.lz_compress (
                                     tools.ConvertC2BUTF8 (
                                         json_arrayagg (
                                             json_object (
                                                 KEY 'REC_ID' VALUE
                                                     t.x_rn,
                                                 KEY 'RNOKPP' VALUE
                                                     t.x_prs_inn,
                                                 KEY 'LAST_NAME' VALUE
                                                     t.x_last_name,
                                                 KEY 'FIRST_NAME' VALUE
                                                     t.x_first_name,
                                                 KEY 'SECOND_NAME' VALUE
                                                     t.x_second_name,
                                                 KEY 'IBAN' VALUE
                                                     t.x_prs_account,
                                                 KEY 'AMOUNT' VALUE
                                                       t.x_prs_sum
                                                     * 100--key 'pkt_create_dt' value to_char(pkt_create_dt,'dd.mm.yyyy hh24:mi:ss')
                                                          )
                                                 FORMAT JSON
                                             ORDER BY
                                                 t.x_rn
                                             RETURNING CLOB)))
                                     AS x_file_data
                            FROM (  SELECT /*row_number()over(partition by t.x_nb_mfo, t.x_rec, t.x_part, t.x_org, t.x_yymm order by t.x_prs_inn) as */
                                           x_rn,
                                           t.x_part,
                                           t.x_org,
                                           t.x_yymm,
                                           t.x_pr_tp,
                                           t.x_prs_inn,
                                           t.x_last_name,
                                           t.x_first_name,
                                           t.x_second_name,
                                           t.x_prs_account,
                                           t.x_prs_sum,
                                           t.x_nb_mfo,
                                           t.x_rec
                                      FROM (SELECT /*  -- io 20220727  використовуємо нумерацію зі списків ВВ
                                                   row_number()over(partition by t.x_portion\*, t.x_nb_mfo, t.x_rec,t.x_org, to_char(t.x_prs_pay_dt, 'YYMM')*\
                                                                    order by t.x_prs_pay_dt, t.x_prs_inn)*/
                                                   t.x_prs_num
                                                       AS x_rn,
                                                   /*trunc((row_number()over(partition by t.x_nb_mfo, t.x_rec, t.x_org, to_char(t.x_prs_pay_dt, 'YYMM')
                                                              order by t.x_prs_inn)-1)/l_portion_size)+1 */
                                                   t.x_portion
                                                       AS x_part,
                                                   t.x_org,
                                                   TO_CHAR (t.x_prs_pay_dt,
                                                            'YYMM')
                                                       AS x_yymm,
                                                   95
                                                       AS x_pr_tp,
                                                   t.x_prs_inn,
                                                   t.x_last_name,
                                                   t.x_first_name,
                                                   t.x_second_name,
                                                   t.x_prs_account,
                                                   t.x_prs_sum,
                                                   t.x_nb_mfo,
                                                   t.x_rec
                                              FROM TMP_BANK_TO_EXPORT t) t
                                  ORDER BY x_rn) t
                        --where pkt_nes = 101
                        GROUP BY t.x_nb_mfo,
                                 t.x_rec,
                                 x_org,
                                 x_yymm,
                                 x_pr_tp,
                                 x_part) t;
        END IF;

        -- #63118 заливаємо дані по відомості в ikis_finzvit  за допомогою ikis_rbm

        INSERT INTO ikis_rbm.tmp_exchangefiles_m1 (ef_id,
                                                   ef_pr,
                                                   com_wu,
                                                   com_org,
                                                   ef_tp,
                                                   ef_name,
                                                   ef_data, -- ivashchuk 20160513 #15516
                                                   ef_visual_data,
                                                   ef_header,
                                                   ef_main_tag_name,
                                                   ef_data_name,
                                                   ef_ecp_list_name,
                                                   ef_ecp_name,
                                                   ef_ecp_alg,
                                                   ef_st,
                                                   ef_dt,
                                                   ef_ident_data,
                                                   ef_ecs,
                                                   ef_rec,
                                                   ef_pr_code,
                                                   ef_pr_name,
                                                   ef_pr_pay_dt,
                                                   ef_pr_pr,
                                                   ef_npc)
            SELECT ef_id,
                   p_pr_id     AS ef_pr,
                   com_wu,
                   com_org,
                   ef_tp,
                   ef_name,
                   ef_data,
                   /*ef_header*/
                   ef_visual_data,
                   ef_header,
                   ef_main_tag_name,
                   ef_data_name,
                   ef_ecp_list_name,
                   ef_ecp_name,
                   ef_ecp_alg,
                   ef_st,
                   ef_dt,
                   ef_ident_data,
                   ef_ecs,
                   ef_rec,
                   l_pr_code,
                   l_pr_name,
                   /*trunc(l_pay_dt, 'MM')+4*/
                   l_pay_dt -- #66415 Доработка функции "Формирование електронных ведомосте":
                           ,
                   l_ef_pr_pr,
                   l_npc_id
              FROM exchangefiles
             WHERE ef_ecs = l_ecs;

        -- ikis_rbm.RDM$APP_EXCHANGE.GenPaketsFromTMPTable@ikis_mil.lnk_to_websok;
        ikis_rbm.RDM$APP_EXCHANGE.GenPaketsFromTMPTable; -- ivashchuk 20160513 #15516

        UPDATE exchangefiles f
           SET ef_pkt =
                   (SELECT t.ef_pkt
                      FROM ikis_rbm.tmp_exchangefiles_m1 t
                     WHERE t.ef_id = f.ef_id)
         WHERE     1 = 1                                   --- ef_pr = p_pr_id
               AND ef_ecs = l_ecs
               AND EXISTS
                       (SELECT 1
                          FROM ikis_rbm.tmp_exchangefiles_m1 t
                         WHERE t.ef_id = f.ef_id);

        UPDATE exchcreatesession
           SET ecs_stop_dt = SYSDATE
         WHERE ecs_id = l_ecs;

        -- прописуємо ід сформованого пакета ПЕОД
        -- оскільки пакети по ВВ ПЕОД формуються під час фіксації ПД,
        -- тобто реєстри уже сформовано, а на пакет є обмеження в 200 записів,
        -- то можлива ситуація, що ми матимемо більше 1 пакета на 1 запис payroll_reestr
        UPDATE uss_esr.payroll_reestr pr
           SET pr.pe_rbm_pkt =
                   (SELECT MIN (f.ef_pkt)
                      FROM exchangefiles f                    -- 20K+  реєстри
                     WHERE     f.ef_po = pr.pe_po
                           AND f.ef_pr = pr.pe_src_entity
                           AND f.ef_po = p_po_id
                           AND f.ef_pr = p_pr_id
                           AND f.ef_ecs = l_ecs)
         WHERE     pr.pe_po = p_po_id
               AND pr.pe_nbg = l_nbg_id
               AND pr.pe_pay_tp = 2
               AND pr.pe_npc = l_npc_id
               AND pr.pe_src_entity = p_pr_id
               AND pr.pe_nb = p_nb_id
               AND pr.pe_rbm_pkt IS NULL
               AND EXISTS
                       (SELECT 1
                          FROM exchangefiles f
                         WHERE     f.ef_po = pr.pe_po
                               AND f.ef_pr = pr.pe_src_entity
                               AND f.ef_po = p_po_id
                               AND f.ef_pr = p_pr_id
                               AND f.ef_ecs = l_ecs);
    --  Ikis_Mil_Common.JobSaveMessage('Завершено формування файлів');
    EXCEPTION
        WHEN exNoPkt4Cor
        THEN
            raise_application_error (
                -20000,
                'Помилка формування файлів для електронного обміну : Для коригуючої відомості не вдалося визначити ід пакета ПЕОД відповідної породжуючої відоості!');
        WHEN exBadVer4Cor
        THEN
            raise_application_error (
                -20000,
                'Помилка формування файлів для електронного обміну : В даній версії ПЗ не підтримується формування пакетів ПЕОД для коригуючих відомостей!');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка формування файлів для електронного обміну : '
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;



    -- info:  Формування пакетів зі списками соцвиплат (по ВВ ЄСР) в ПЕОД
    -- params: p_po_id – ід ПД
    -- note:  Викликати при фіксації ПД в DNET$PAYMENT_ANALITIC.FIX_SELECTED_ORDERS
    PROCEDURE BuildJsonpktByPo (p_po_id payroll.pr_id%TYPE)
    IS
        l_po_st       uss_esr.pay_order.po_st%TYPE;
        l_nb_id       NUMBER;
        l_nbg_id      NUMBER;
        l_npc_id      NUMBER;
        l_lock_init   TOOLS.t_lockhandler;
    BEGIN
        DBMS_OUTPUT.disable;
        tools.WriteMsg ('API$ESR_EXCHANGE.' || $$PLSQL_UNIT);

        l_lock_init :=
            TOOLS.request_lock (
                p_descr   => 'BuildJsonpktByPo_' || p_po_id,
                p_error_msg   =>
                    'В даний момент вже виконується створення пакетів!');

        SELECT nbg_id
          INTO l_nbg_id
          FROM uss_ndi.v_ndi_budget_program nbg
         WHERE nbg.nbg_kpk_code = '2501530'         /* TN 20230504 '2501480'*/
                                           ;

        SELECT npc_id
          INTO l_npc_id
          FROM uss_ndi.v_ndi_payment_codes npc
         WHERE npc.npc_code = '29';

        /*   select npc_id into l_npc_id
           from uss_ndi.v_ndi_payment_type t
           where t.npt_code = '327';*/

        BEGIN
            SELECT po_st, po.po_nb_src
              INTO l_po_st, l_nb_id
              FROM uss_esr.pay_order po
             WHERE po_id = p_po_id AND po.po_src = 'OUT' AND po.po_st = 'A';
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RETURN;        -- raise_application_error(-20000, 'po_st!!!');
        END;

        --dbms_output.put_line('po='||p_po_id||':'||l_po_st||'-'||l_nb_id) ;

        FOR pe
            IN (  SELECT pe.pe_src_entity,
                         pe_bnk_rbm_code,
                         pe_nb,
                         SUM (pe_row_cnt)     AS pr_pe_row_cnt,
                         SUM (pe_sum)         AS pr_pe_sum
                    FROM uss_esr.payroll_reestr pe
                   WHERE     pe_po = p_po_id                                --
                         AND pe.pe_nbg = l_nbg_id
                         AND pe.pe_pay_tp = 2
                         --and pe.pe_tp = 1
                         AND pe.pe_npc = l_npc_id
                         AND pe.pe_rbm_pkt IS NULL -- io 20221111 як додатковий захист від повторного створення пакетів
                GROUP BY pe.pe_src_entity, pe_bnk_rbm_code, pe_nb)
        LOOP
            --  dbms_output.put_line('pr_id='||pe.pe_src_entity) ;

            uss_esr.api$esr_exchange.BuildJsonExchFiles (
                p_po_id    => p_po_id,
                p_pr_id    => pe.pe_src_entity,
                p_prs_tp   => 'PB',
                p_nb_id    => pe.pe_nb);
        END LOOP;
    EXCEPTION
        /*  when exBadPoSt then
            raise_application_error(-20000, 'Помилка формування файлів для електронного обміну : Для коригуючої відомості не вдалос!');
          when exBadVer4Cor then
            raise_application_error(-20000, 'Помилка формування файлів для електронного обміну : В даній версії ПЗ не підтримується формування пакетів ПЕОД для коригуючих відомостей!');    */
        WHEN OTHERS
        THEN
            IF                                             /*sqlcode = 20000*/
               INSTR (SQLERRM, 'ORA-20000') > 0
            THEN
                RAISE;
            ELSE
                raise_application_error (
                    -20000,
                       'Помилка формування файлів для електронного обміну : '
                    || CHR (10)
                    || REPLACE (
                              DBMS_UTILITY.FORMAT_ERROR_STACK
                           || ' => '
                           || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                           'ORA-20000:')
                    || CHR (10)
                    || SQLERRM);
            END IF;
    END;

    -- info:  Видалення невідправлених пакетів з ПЕОД
    -- params: p_po_id – ід ПД
    -- note: При натисканні кнопки "Розфіксувати" перевіряється статус пакетів ПЕОД, пов'язаних з цим ПД.
    --    Якщо статус "Новий" або "Підписано" - пакет переводиться в статус "Видалено"
    --    Якщо статус "Відправлено" то користувачу надається повідомлення "Не можливо розфіксувати, оскільки реєстри по цьому документу відправлені в банк".
    PROCEDURE DelPoPackets (p_po_id NUMBER)
    IS
        l_cnt        NUMBER;
        l_wu         NUMBER
            := SYS_CONTEXT (uss_esr_context.gContext, uss_esr_context.gUID);
        exBadPktSt   EXCEPTION;
    BEGIN
        SELECT COUNT (1)
          INTO l_cnt
          FROM payroll_reestr  pe
               JOIN ikis_rbm.v_packet p ON pe.pe_rbm_pkt = p.pkt_id
         WHERE pe_po = p_po_id AND p.pkt_st NOT IN ('D', 'N', 'SGN');

        IF l_cnt > 0
        THEN
            RAISE exBadPktSt;
        END IF;

        FOR pkt
            IN (SELECT pkt_id,
                       f.ef_id,
                       f.ef_ecs,
                       pe_src_entity,
                       pe_nb,
                       pe_pay_dt
                  FROM payroll_reestr  pe
                       JOIN ikis_rbm.v_packet p ON pe.pe_rbm_pkt = p.pkt_id
                       JOIN exchangefiles f ON f.ef_pkt = p.pkt_id
                 WHERE pe_po = p_po_id AND p.pkt_st IN ('N', 'SGN'))
        LOOP
            ikis_rbm.rdm$packet.Set_Packet_State (
                p_Pkt_Id          => pkt.pkt_id,
                p_Pkt_St          => 'D',
                p_Pkt_Change_Wu   => l_wu,
                p_Pkt_Change_Dt   => SYSDATE);


            UPDATE uss_esr.exchcreatesession s
               SET s.ecs_filter = 'del' || s.ecs_filter
             WHERE     s.ecs_id = pkt.ef_ecs
                   AND SUBSTR (s.ecs_filter, 1, 3) != 'del'
                   AND s.ecs_filter LIKE 'PO' || p_po_id || '%';

            UPDATE uss_esr.exchcreatesession s
               SET s.ecs_filter = 'del' || s.ecs_filter
             WHERE     s.ecs_id = pkt.ef_ecs
                   AND SUBSTR (s.ecs_filter, 1, 3) != 'del'
                   AND s.ecs_filter LIKE '%#PO' || p_po_id || '%';

            UPDATE uss_esr.exchangefiles p                         -- 20220527
               SET ef_po = NULL
             WHERE ef_po = p_po_id;

            UPDATE uss_esr.payroll_reestr r
               SET r.pe_rbm_pkt = NULL
             WHERE r.pe_rbm_pkt = pkt.pkt_id AND r.pe_po = p_po_id;

            -- io 20221023
            -- при розфіксації ПД обнуляємо нумерацію списків
            UPDATE pr_sheet s
               SET s.prs_num = 0
             WHERE     s.prs_num > 0
                   AND s.prs_pr = pkt.pe_src_entity
                   AND s.prs_nb = pkt.pe_nb
                   AND s.prs_pay_dt = pkt.pe_pay_dt;
        END LOOP;
    EXCEPTION
        WHEN exBadPktSt
        THEN
            raise_application_error (
                -20000,
                'Не можливо розфіксувати, оскільки реєстри по цьому документу відправлені в банк!');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка видалення пакетів : '
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;

    -- info:  Формування пакетів "конверт з реєстром списків по платіжному дорученню" в ПЕОД
    -- params: p_po_id – ід ПД
    -- note:
    PROCEDURE GenRv2PdPackets (p_po_id NUMBER)
    IS
        l_Rv2Pd_clob    CLOB;
        l_visual_clob   CLOB;
        l_rec_cnt       INTEGER;
        l_rec_id        INTEGER;
        l_org           NUMBER
            := SYS_CONTEXT (uss_esr_context.gContext, uss_esr_context.gORG);
        l_wu            NUMBER
            := SYS_CONTEXT (uss_esr_context.gContext, uss_esr_context.gUID);
        l_filter        VARCHAR2 (250);
        l_po_st         VARCHAR2 (10);
        l_ecs           exchcreatesession.ecs_id%TYPE;
        l_cnt           INTEGER;
        l_pr_post_cnt   INTEGER;
        exPktExists     EXCEPTION;
        exBadRec        EXCEPTION;
        exBadPoSt       EXCEPTION;
        exPayPost       EXCEPTION;
    BEGIN
        NULL;
    /*
      --  #71240 внести зміни в процедуру вивантаження реєстрів по ПД: для типу виплат "Пошта"
      -- (хоча б одна відомість з прив'язаних до ПД) - заборонити вивантаження ПД та реєстрів по ПД для КБ
      select count(distinct pe_id)
      into l_pr_post_cnt
      from payroll_reestr pr
      where pe_po = p_po_id
        and pr.pe_pay_tp = 1;
      IF l_pr_post_cnt > 0 THEN
        raise exPayPost;
      END IF;

    -- 'Розпочато формування файлів для електронного обміну - Реєстр ПД'
      l_filter := 'rv2pd'||'#'||p_po_id;
      SELECT COUNT(1) INTO l_cnt FROM exchcreatesession WHERE ecs_filter = l_filter;
      IF l_cnt > 0 THEN
        raise exPktExists;
      END IF;

      --тільки для ПД у стані "Проведено банком"
      select max(po.po_st) into l_po_st
      from pay_order po
      where po_id = p_po_id;

      if nvl(l_po_st, 'zzz') != 'APPR' then
        raise exBadPoSt;
      end if;

      INSERT INTO exchcreatesession (ecs_id, ecs_start_dt, ecs_filter)
        VALUES (0, sysdate, l_filter)
      RETURNING ecs_id INTO l_ecs;

      -- визначаємо одержувача
      select count(distinct pkt_rec), max(pkt_rec)
      into l_rec_cnt, l_rec_id
      from payroll_reestr pr
      join ikis_rbm.v_packet p on pr.pe_rbm_pkt = p.pkt_id
      where pe_po = p_po_id;
      \*
      dbms_output.put_line('l_rec_cnt='||l_rec_cnt);
      dbms_output.put_line('l_rec_id='||l_rec_id);
      *\
      IF l_rec_cnt != 1 or nvl(l_rec_id, 0) = 0 THEN
        raise exBadRec;
      END IF;


      select
      xmlconcat(
        (select
           XMLELEMENT("pd_info",
             XMLELEMENT("idpd", po_id),
             XMLELEMENT("pd_date", to_char(po.po_pay_dt, 'DDMMYYYY')),
             XMLELEMENT("pd_num", po.po_number),
             XMLELEMENT("rv_date", to_char(sysdate, 'DDMMYYYY')),
             XMLELEMENT("rv_sum", po.po_sum*100),
             XMLELEMENT("rv_lines", (select sum(pe_row_cnt) from payroll_reestr where pe_po = p_po_id))
            ) as z_pd_info
         from pay_order po
         where po_id = p_po_id
        ),
        (
          select
                 XMLELEMENT("rv_list",
                   XMLAGG(
                     XMLELEMENT("row",
                       XMLELEMENT("idv", pr.pe_rbm_pkt),
                       --(pkt_xml).extract( '/\*[not(*)]'),
                       deletexml(deletexml((pkt_xml),'//source'),'//id_cor').extract( '//*[not(*)]'),
                       XMLELEMENT("excluded_sum", '0'),
                       XMLELEMENT("excluded_lines", '0')
                  )))  as rv_list
          from (
          select
           UPDATEXML(UPDATEXML(UPDATEXML(pc_xml,'/xml/full_lines/text()',pe_row_cnt) ,'/xml/full_sum/text()',pe_sum)
           ,'/xml/opfu_code/text()',pr_org) as pkt_xml,
           tt.*
          from (
           select
              case when rec.rec_tp = 'IC' then  XMLTYPE( '<xml>'||pc.pc_header||'</xml>')
                   else XMLTYPE( '<xml>'||tools.utf8todeflang(pc.pc_header)||'</xml>')
              end as pc_xml,
              pr.*
           from (
              select  pe_po, pe_rbm_pkt, com_org as pr_org,
                 sum(pr.pe_sum*100 * decode(pe_tp, 3, -1, 1)) as pe_sum,
                 sum(pr.pe_row_cnt) as pe_row_cnt
              from  payroll_reestr pr
              where pr.pe_po = p_po_id
              group by pe_po,  pe_rbm_pkt, com_org
              ) pr
              join ikis_rbm.v_packet_content pc
                on pc_pkt = pr.pe_rbm_pkt
              join ikis_rbm.v_packet p
                on pkt_id = pr.pe_rbm_pkt
              join ikis_rbm.v_recipient rec
                on rec.rec_id = p.pkt_rec
          ) tt
          ) pr
        )
        ).getClobVal()
      into l_Rv2Pd_clob
      from dual;

      select '<h5>Реєстр списків по платіжному дорученню №'|| po.po_number ||
                ' від '||to_char(po.po_pay_dt\*po_date_create*\,'dd.mm.yyyy') ||' на суму '||po.po_sum||'</h5>'||chr(10)
               ||
               (XMLELEMENT("div",
                 XMLELEMENT("style", 'table.z, th.z, td.z {border: 1px solid black;    border-collapse: collapse;; text-align:right;}'),
                 XMLELEMENT("style", 'table.hh, th.hh,td.hh {border: 1px solid black;    border-collapse: collapse;; text-align:center;}'),
                 (SELECT XMLELEMENT("table", XMLATTRIBUTES('z' AS "class"),
                    --XMLATTRIBUTES('"font-family:Arial, sans-serif;font-size:14px;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;"' AS "class"),
                            XMLELEMENT("tr", XMLATTRIBUTES('hh' AS "class"),
                              XMLELEMENT("td", XMLATTRIBUTES('hh' AS "class"), '№ п/п'),
                              XMLELEMENT("td", XMLATTRIBUTES('hh' AS "class"), 'Ід. конверта ВВ'),
                              XMLELEMENT("td", XMLATTRIBUTES('hh' AS "class"), 'Дата створення##Br##конверта ВВ'),
                              XMLELEMENT("td", XMLATTRIBUTES('hh' AS "class"), 'Код УСПЗН'),
                              XMLELEMENT("td", XMLATTRIBUTES('hh' AS "class"), 'Назва УСПЗН'),
                              XMLELEMENT("td", XMLATTRIBUTES('hh' AS "class"), 'Тип відомості'),
                              XMLELEMENT("td", XMLATTRIBUTES('hh' AS "class"), 'Кількість рядків##Br##в списках ВВ'),
                              XMLELEMENT("td", XMLATTRIBUTES('hh' AS "class"), 'Сума по##Br##списках ВВ'),
                              XMLAGG(
                                XMLELEMENT("tr", XMLATTRIBUTES('z' AS "class"),
                                  XMLELEMENT("td", XMLATTRIBUTES('z' AS "class"), x_rownum),
                                  XMLELEMENT("td", XMLATTRIBUTES('z' AS "class"), x_idv),
                                  XMLELEMENT("td", XMLATTRIBUTES('z' AS "class"), x_pkt_dt),
                                  XMLELEMENT("td", XMLATTRIBUTES('z' AS "class"), x_pkt_org),--  #63657
                                  XMLELEMENT("td", XMLATTRIBUTES('z' AS "class"), x_opfu_name), -- CONVERT(ln, 'UTF8')
                                  XMLELEMENT("td", XMLATTRIBUTES('z' AS "class"), x_pr_tp),--
                                  XMLELEMENT("td", XMLATTRIBUTES('z' AS "class"), x_full_lines),
                                  XMLELEMENT("td", XMLATTRIBUTES('z' AS "class"), x_full_sum)
                                      ) order by x_rownum)))

                  FROM(
                      select
                        rownum as x_rownum,
                        xx.*
                      from(
                    select
                      x_idv,x_pkt_dt, x_pkt_org,
                      x_opfu_name,\*x_full_lines,x_full_sum,*\
                      x_pr_tp,
                      sum(pr_sum) as x_full_sum ,
                      sum(pe_row_cnt) as x_full_lines
                    from (
                      select
                        pkt_id as x_idv,
                        to_char(p.pkt_create_dt, 'dd.mm.yyyy hh24:mi:ss') as x_pkt_dt,
                        \*p.pkt_org*\ pr.com_org as x_pkt_org,
                        to_char(tools.utf8todeflang(tools.get_xmlattr_clob(pc.pc_header, 'opfu_name'))) as x_opfu_name,
                        to_char(tools.utf8todeflang(tools.get_xmlattr_clob(pc.pc_header, 'full_lines'))) as x_full_lines,
                        to_char(tools.utf8todeflang(tools.get_xmlattr_clob(pc.pc_header, 'full_sum'))) as x_full_sum,
                        ptp.dic_sname as x_pr_tp
                        ,pr.pe_pay_dt,
                        pr.pe_sum * decode(pe_tp, 3, -1, 1) as pr_sum,
                        pr.pe_row_cnt
                      from payroll_reestr pr
                      join uss_ndi.v_ddn_pe_tp ptp on ptp.DIC_VALUE = pr.pe_tp
                      left join ikis_rbm.v_packet p
                        on pkt_id = pr.pe_rbm_pkt
                      join ikis_rbm.v_packet_content pc
                        on pc_pkt= pkt_id
                      where pe_po = p_po_id
                    )
                    group by   x_idv,x_pkt_dt, x_pkt_org,
                      x_opfu_name,\*x_full_lines,x_full_sum,*\x_pr_tp
                          )xx
                        )
                       )
                      )).getClobVal() into  l_visual_clob
        from pay_order po
        where po.po_id = p_po_id;

      INSERT INTO exchangefiles (ef_id, ef_po, com_wu, com_org, ef_tp, ef_name, ef_data, ef_visual_data, ef_header,
                                 ef_main_tag_name, ef_data_name, ef_ecp_list_name, ef_ecp_name, ef_ecp_alg,
                                 ef_st, ef_dt, ef_ident_data, ef_ecs, ef_rec, ef_file_idn, ef_ef)
      select
         null, p_po_id, l_wu, l_org, 'rv2pd_list' as ef_tp, 'RV2PD_LIST_'||po.po_number||'_'||to_char(po.po_pay_dt,'YYYYMMDD_HH24MISS') as ef_name,
         utl_compress.lz_compress( tools.ConvertC2B(l_Rv2Pd_clob), 9) as ef_data,

         replace(l_visual_clob, '##Br##', '<br>') as ef_visual_data,

         XMLELEMENT("idpd", po.po_id)||
         XMLELEMENT("rv_date", to_char(sysdate, 'DDMMYYYY'))||
         XMLELEMENT("rv_sum", po.po_sum*100)||
         XMLELEMENT("rv_lines", (select sum(pe_row_cnt) from payroll_reestr where pe_po = p_po_id))
         as ef_header,
         'rv2pd_list', 'rv_list', 'ecp_list', 'ecp', 'MD',
         'Z', sysdate, 'ПД: '||po.po_number\*||'; МФО: '||po.*\, l_ecs, l_rec_id, null, null
      from  pay_order po
      where po_id = p_po_id;

      -- створюємо пакет в ПЕОД
      INSERT INTO ikis_rbm.tmp_exchangefiles_m3(ef_id, ef_po, com_wu, com_org, ef_tp, ef_name, ef_data,
                                       ef_visual_data, ef_header, ef_main_tag_name, ef_data_name,
                                       ef_ecp_list_name, ef_ecp_name, ef_ecp_alg, ef_st,
                                       ef_dt, ef_ident_data, ef_ecs, ef_rec)
        SELECT ef_id, ef_po, com_wu, com_org, ef_tp, ef_name, ef_data,
               ef_visual_data , ef_header, ef_main_tag_name, ef_data_name,
               ef_ecp_list_name, ef_ecp_name, ef_ecp_alg, ef_st, ef_dt,
               ef_ident_data, ef_ecs, ef_rec
        FROM exchangefiles
        WHERE ef_ecs = l_ecs;

      ikis_rbm.ikis_rbm_esr.GenPaketsFromTMPTable;

        -- витягуємо ід створеного пакета
      update exchangefiles f
      set f.ef_pkt = (select t.ef_pkt from ikis_rbm.tmp_exchangefiles_m3 t where t.ef_id = f.ef_id)
      where ef_ecs = l_ecs
        and f.ef_po = p_po_id;

      update pay_order po -- 20210408
      set po.po_upload_dt = sysdate
      where po.po_id = p_po_id;
    */
    EXCEPTION
        WHEN exPayPost
        THEN
            raise_application_error (
                -20000,
                'Формування реєстрів ПД що містять списки з типом виплати "Пошта" заборонено!');
        WHEN exPktExists
        THEN
            raise_application_error (-20000,
                                     'Реєстр по даному ПД вже вивантажено!');
        WHEN exBadPoSt
        THEN
            raise_application_error (
                -20000,
                'Створення файлів можливе тільки для ПД у стані "Проведено банком"!');
        WHEN exBadRec
        THEN
            raise_application_error (
                -20000,
                'Не вдалося однозначно визначити одержувача реєстру ПД!');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'API$ESR_EXCHANGE.GenRv2PdPackets:'
                ||                                               /*chr(10)||*/
                   REPLACE (     /*DBMS_UTILITY.FORMAT_ERROR_STACK||' => '||*/
                            DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                            'ORA-20000:')        /*||chr(10)||
sqlerrm*/
                                         );
    END;


    -- info:  Масове Формування пакетів "конверт з реєстром списків по платіжному дорученню" в ПЕОД
    -- params: p_po_list – список ід ПД через кому
    --         p_err_msg - список ПД з помилками формування реєстра.
    -- note:  реєстр в ПЕОД формується для ПД зі списку, статус яких = 'APPR' і які ще не вивантажувалися в ПЕОД. решта - в помилку
    PROCEDURE GenRv2PdPacketsMass (p_po_list       VARCHAR2,
                                   p_err_msg   OUT VARCHAR2)
    IS
        exNoPoExists   EXCEPTION;
        l_err_msg      VARCHAR2 (32000);
    BEGIN
        NULL;
    /*
      if nvl(length(replace(trim(p_po_list), ',', '')), 0) = 0 then
        --raise exNoPoExists;
        p_err_msg := 'Список ПД для вивантаження порожній!';
        return;
      end if;
      -- перебираємо список ПД
      for rec in (select po.po_id, po.po_number, po.po_pay_dt
                  from pay_order po
                  join (select regexp_substr(text ,'[^(\,)]+', 1, level)  as z_po_id
                        from (select p_po_list as text from dual)
                              connect by length(regexp_substr(text ,'[^(\,)]+', 1, level)) > 0) z on z.z_po_id = po.po_id
                  \* where po.po_status = 'APPR'
                     and not exists (select 1 from exchcreatesession where ecs_filter =  'rv2pd'||'#'||po.po_id) *\
                   )
      loop
        begin
          GenRv2PdPackets(p_po_id => rec.po_id);
          commit;
        exception
        when others then
          l_err_msg := l_err_msg||'ПД №'||rec.po_number||' від '||to_char(rec.po_pay_dt, 'dd.mm.yyyy')||', '||
                          replace(sqlerrm, 'ORA-20000:'\*'API$ESR_EXCHANGE.GenRv2PdPackets:'*\, 'помилка: ')||
                         '<br>'\*chr(10)*\;
          rollback;
        end;
      end loop;

      p_err_msg := l_err_msg;
    */
    EXCEPTION
        WHEN exNoPoExists
        THEN
            raise_application_error (-20000,
                                     'Список ПД для вивантаження порожній!');
            p_err_msg := 'Список ПД для вивантаження порожній!';
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'API$ESR_EXCHANGE.GenRv2PdPacketsMass:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;

    -- info:  Формування пакетів КВ-1 та КВ-2 (PCA, PPR) в ПЕОД
    -- params: p_rbm_pkt_id – ід пакета ВВ в ПЕОД
    --         p_pkt_tp     - тип пакета, що формується
    --         p_filia_name - Назва філії
    --         p_pkt_info   - опис пакета для візуалізації в ПЕОД
    --         p_pkt_blob   - шифрований файл пакета
    -- note:
    -- p_rbm_pkt_id  Ід пакета ВВ в ПЕОД, на який прийшла відповідь. Якщо його немає, можна ід відомості, ід пакета витягну в xml.
    -- p_pkt_name    Назва файлу
    -- p_pkt_blob    Файл розшифрований Тоді підпункт  предварительный контроль ключевых данных (используя АПИ ИКИСа) можна перемістити в процедуру збереження
    -- p_pkt_encr_blob   Шифрований файл або ЕЦП юзера на файл
    -- p_message - Результат виконання - повідомлення про створення/помилку створення  пакета квитанції в ПЕОД
    PROCEDURE GenKVPackets (                     --p_rbm_pkt_id     in number,
                            p_payroll_id      IN     NUMBER,
                            p_pkt_tp          IN     VARCHAR2,
                            p_pkt_name        IN     VARCHAR2,
                            p_pkt_blob        IN     BLOB,
                            p_pkt_encr_blob   IN     BLOB,
                            p_message            OUT VARCHAR2)
    IS
        l_filter              VARCHAR2 (250);
        l_ecs                 exchcreatesession.ecs_id%TYPE;
        l_cnt                 INTEGER;
        l_ef_header           exchangefiles.ef_header%TYPE;
        l_pkt_row             ikis_rbm.v_packet%ROWTYPE;
        l_create_dt           DATE := SYSDATE;
        --l_visual_data clob;
        l_ef_tag              exchangefiles.ef_main_tag_name%TYPE;
        l_ef_name             exchangefiles.ef_name%TYPE;
        l_ef_data_name        exchangefiles.ef_data_name%TYPE;
        l_ef_data_tag         exchangefiles.ef_data_name%TYPE;
        l_ef_data_etag        exchangefiles.ef_data_name%TYPE;
        --l_pkt_filia_code payroll_reestr.pr_bnk_code%type;
        --l_pr_pkt_id    number;
        l_xml_data            XMLTYPE;
        l_xml_content         XMLTYPE;
        l_pkt_xmltype         XMLTYPE;
        l_rbm_pkt_id          NUMBER;
        l_pr_pkt_cnt          NUMBER;
        l_date_time           DATE;
        l_date_cr             DATE;
        l_filia_num           VARCHAR2 (10);
        l_filia_name          VARCHAR2 (500);
        l_opfu_code           VARCHAR2 (10);
        l_opfu_name           VARCHAR2 (250);
        --l_res_file     varchar2(10);
        l_full_lines          NUMBER;
        l_full_sum            NUMBER;
        l_return_full_sum     NUMBER;
        l_return_full_lines   NUMBER;
        l_pkt_xml             CLOB;
        l_pkt_clob            CLOB;
        --l_pkt_data     BLOB;
        l_ecp                 CLOB;
        l_zip                 BLOB;
        l_unzipped_blob       BLOB;
        l_nb_ab               NUMBER;
        l_kv_pkt              NUMBER;
        l_rr_id               NUMBER;
        l_rrl_cnt             NUMBER;
        --l_unzipped     CLOB;
        --l_xml_prot     xmltype;
        --l_wf_id        number;
        --l_rez_clob     clob;
        --l_rez_xml      clob;
        --l_pkt_id       number;
        l_visual_clob         CLOB;
        --l_rbm_pkt_pt   number;
        l_rec_tp              VARCHAR2 (10);
        l_rec_name            VARCHAR2 (1000);
        l_rec_code            VARCHAR2 (100);
        exPktExists           EXCEPTION;
        exNoPktExists         EXCEPTION;
        exPktFileEmpty        EXCEPTION;
        exBadRec              EXCEPTION;
        exBadPoSt             EXCEPTION;
    BEGIN
        NULL;

        -- 'Розпочато формування файлів для електронного обміну - Реєстр ПД'
        l_filter :=
               'pkt'
            || '#'
            || p_pkt_tp
            || '#'
            || p_payroll_id
            || '#'
            || tools.hash_md5 (p_pkt_blob)                      /*p_pkt_name*/
                                          ;                      -- фільтр ???

        SELECT COUNT (1)
          INTO l_cnt
          FROM exchcreatesession
         WHERE ecs_filter = l_filter;

        IF l_cnt > 0
        THEN
            RAISE exPktExists;
        END IF;

        INSERT INTO exchcreatesession (ecs_id, ecs_start_dt, ecs_filter)
             VALUES (0, l_create_dt, l_filter)
          RETURNING ecs_id
               INTO l_ecs;

        IF p_pkt_blob IS NULL OR DBMS_LOB.getlength (p_pkt_blob) < 10
        THEN
            RAISE exPktFileEmpty;
        END IF;

        /*  select max(pr.pr_bnk_code) into l_pkt_filia_code
          from payroll_reestr pr
          where pr.pe_rbm_pkt = l_pr_pkt_id;*/
        /* pr_filia_code буває незаповнена в ВВ ППВП */

        l_ef_tag :=
            CASE
                WHEN p_pkt_tp = 103 THEN 'post_payment_reply'
                WHEN p_pkt_tp = 102 THEN 'post_convert_answer'
                WHEN p_pkt_tp = 82 THEN 'post_rv2pd_answer'
            END;

        l_ef_data_name :=
            CASE
                WHEN p_pkt_tp = 103 THEN 'report_data'
                WHEN p_pkt_tp = 102 THEN 'pca_data'
                WHEN p_pkt_tp = 82 THEN 'rv_list'
            END;
        l_ef_data_tag := '<' || l_ef_data_name || '>';
        l_ef_data_etag := '</' || l_ef_data_name || '>';
        /*  l_ef_name := case when p_pkt_tp = 22 then 'PPR_'
                            when p_pkt_tp = 23 then 'PCA_'
                            when p_pkt_tp = 82 then 'PR2DA_'
                       end||
                       l_pkt_row.pkt_org||'.'||l_filia_code||'_'||to_char(l_create_dt,'yyyymmddhh24miss')||'_'||p_rbm_pkt_id;
                       */


        DBMS_LOB.createTemporary (l_visual_clob, TRUE);
        DBMS_LOB.OPEN (l_visual_clob, DBMS_LOB.LOB_ReadWrite);

        BEGIN
            BEGIN
                l_pkt_xml :=
                    tools.ConvertB2C (
                        UTL_COMPRESS.lz_uncompress (p_pkt_blob));
            EXCEPTION
                WHEN OTHERS
                THEN
                    l_pkt_xml := tools.ConvertB2C (tools.unZip (p_pkt_blob));
            END;
        EXCEPTION
            WHEN OTHERS
            THEN
                --ikis_rbm.rdm$log_packet.insert_message(p_lp_pkt => p_rbm_pkt,  p_lp_comment => '&102#/paymentlists/pca_data#'||sqlerrm);
                -- raise_application_error(-20000,  'Помилка розархівування вхіднного файлу');
                IF SQLCODE = -20000
                THEN
                    RAISE;
                ELSE
                    --ikis_rbm.rdm$log_packet.insert_message(p_lp_pkt => p_rbm_pkt,  p_lp_comment => '&102#/paymentlists/pca_data#'||sqlerrm);
                    raise_application_error (
                        -20000,
                        'Помилка розархівування вхіднного файлу');
                END IF;
        END;

        BEGIN
            --l_pkt_xml := tools.ConvertB2C(utl_compress.lz_uncompress(p_pkt_blob));
            l_pkt_xmltype := xmltype (l_pkt_xml);
        EXCEPTION
            WHEN OTHERS
            THEN
                --ikis_rbm.rdm$log_packet.insert_message(p_lp_pkt => p_rbm_pkt,  p_lp_comment => '&102#/paymentlists/pca_data#'||sqlerrm);
                raise_application_error (
                    -20000,
                    'Вхідний zip-архів не є xml-структурою'              /*||sqlerrm
||chr(10)||dbms_utility.format_error_stack||dbms_utility.format_error_backtrace*/
                                                           );
        END;

        IF DBMS_LOB.INSTR (UPPER (l_pkt_xml), 'ENCODING="UTF-8"') > 0
        THEN
            l_pkt_xml := tools.utf8todeflang (l_pkt_xml);
        --dbms_output.put_line('encode');
        --dbms_output.put_line(l_pkt_xml) ;
        END IF;

        BEGIN
            l_pkt_clob := tools.get_xmlattr_clob (l_pkt_xml, l_ef_data_name);
        EXCEPTION
            WHEN OTHERS
            THEN
                --ikis_rbm.rdm$log_packet.insert_message(p_lp_pkt => p_rbm_pkt,  p_lp_comment => '&102#/paymentlists/pca_data#'||sqlerrm);
                raise_application_error (
                    -20000,
                       'Параметр '
                    || l_ef_tag
                    || '/'
                    || l_ef_data_name
                    || ' відсутній або порожній');
        END;

        BEGIN
            l_zip := tools.decode_base64 (l_pkt_clob);
        EXCEPTION
            WHEN OTHERS
            THEN
                --ikis_rbm.rdm$log_packet.insert_message(p_lp_pkt => p_rbm_pkt,  p_lp_comment => '&102#/paymentlists/pca_data#'||sqlerrm);
                raise_application_error (
                    -20000,
                       'Параметр '
                    || l_ef_tag
                    || '/'
                    || l_ef_data_name
                    || ' не є base64-кодованою структурою');
        END;

        IF l_zip IS NULL OR DBMS_LOB.getlength (l_zip) = 0
        THEN
            --ikis_rbm.rdm$log_packet.insert_message(p_lp_pkt => p_rbm_pkt,  p_lp_comment => '&111');
            /*RETURN PPRError(l_rbm_pkt_id, 'Параметр /paymentlists/report_data відсутній або порожній');*/
            raise_application_error (
                -20000,
                   'Параметр '
                || l_ef_tag
                || '/'
                || l_ef_data_name
                || ' відсутній або порожній');
        END IF;

        BEGIN
            l_unzipped_blob := UTL_COMPRESS.lz_uncompress (l_zip);
        EXCEPTION
            WHEN OTHERS
            THEN
                --ikis_rbm.rdm$log_packet.insert_message(p_lp_pkt => p_rbm_pkt,  p_lp_comment => '&102#/paymentlists/pca_data#'||sqlerrm);
                raise_application_error (
                    -20000,
                       'base64-кодований вміст параметра '
                    || l_ef_tag
                    || '/'
                    || l_ef_data_name
                    || ' не є zip-архівом'                                                                               /*||sqlerrm
||chr(10)||dbms_utility.format_error_stack||dbms_utility.format_error_backtrace*/
                                          );
        END;

        BEGIN
            l_xml_content := xmltype (tools.ConvertB2C (l_unzipped_blob) /*tools.ConvertB2C(utl_compress.lz_uncompress(l_zip))*/
                                                                        );
        EXCEPTION
            WHEN OTHERS
            THEN
                --ikis_rbm.rdm$log_packet.insert_message(p_lp_pkt => p_rbm_pkt,  p_lp_comment => '&102#/paymentlists/pca_data#'||sqlerrm);
                raise_application_error (
                    -20000,
                    'Вкладений zip-архів не є xml-структурою'              /*||sqlerrm
||chr(10)||dbms_utility.format_error_stack||dbms_utility.format_error_backtrace*/
                                                             );
        END;


        BEGIN
            l_xml_data :=
                xmltype (
                       DBMS_LOB.SUBSTR (
                           l_pkt_xml,
                           DBMS_LOB.INSTR (l_pkt_xml, l_ef_data_tag) + 12,
                           1)
                    || 'Xreport_dataX'
                    || DBMS_LOB.SUBSTR (
                           l_pkt_xml,
                             DBMS_LOB.getlength (l_pkt_xml)
                           - DBMS_LOB.INSTR (l_pkt_xml, l_ef_data_etag)
                           + 1,
                           DBMS_LOB.INSTR (l_pkt_xml, l_ef_data_etag)));
        EXCEPTION
            WHEN OTHERS
            THEN
                --ikis_rbm.rdm$log_packet.insert_message(p_lp_pkt => p_rbm_pkt,  p_lp_comment => '&112#/paymentlists/pca_data '||sqlerrm);
                raise_application_error (
                    -20000,
                       'Помилка перетворення '
                    || l_ef_tag
                    || '/'
                    || l_ef_data_name                                                   /*||': ' ||sqlerrm
||chr(10)||dbms_utility.format_error_stack||dbms_utility.format_error_backtrace*/
                                     );
        END;

        IF p_pkt_tp = 102
        THEN                                                           -- КВ-1
            BEGIN                            -- ??  уніфікувати для КВ1 + КВ-2
                         SELECT x_id,
                                TO_DATE (x_date_time, 'dd.mm.yyyy hh24:mi:ss'),
                                x_filia_num,
                                x_filia_name,
                                x_full_lines,
                                x_opfu_code,
                                x_opfu_name,
                                x_ecp
                           INTO l_rbm_pkt_id,
                                l_date_time,
                                l_filia_num,
                                l_filia_name,
                                l_full_lines,
                                l_opfu_code,
                                l_opfu_name,
                                l_ecp
                           FROM XMLTABLE (
                                    '/paymentlists'
                                    PASSING l_xml_data
                                    COLUMNS x_id            NUMBER PATH 'id',
                                            x_date_time     VARCHAR2 (25) PATH 'date_time',
                                            x_filia_num     VARCHAR2 (10) PATH 'filia_num',
                                            x_filia_name    VARCHAR2 (100) PATH 'filia_name',
                                            x_full_lines    NUMBER PATH 'full_lines',
                                            x_opfu_code     VARCHAR2 (10) PATH 'opfu_code',
                                            x_opfu_name     VARCHAR2 (250) PATH 'opfu_name',
                                            x_ecp           CLOB PATH 'ecp_list/ecp');

                DBMS_LOB.append (
                    l_visual_clob,
                       '<h5>Квитанція банку про опрацювання файлу зі списками від '
                    || TO_CHAR (l_date_time, 'dd.mm.yyyy hh24:mi:ss')
                    || '</h5>'
                    || CHR (10));
                DBMS_LOB.append (
                    l_visual_clob,
                       'УПСЗН: '
                    || l_opfu_code
                    || ' '
                    || l_opfu_name
                    || '<br>'
                    || CHR (10));
                DBMS_LOB.append (
                    l_visual_clob,
                       'Філія: '
                    || l_filia_num
                    || ' '
                    || l_filia_name
                    || '<br>'
                    || CHR (10));
                DBMS_LOB.append (
                    l_visual_clob,
                       'Кількість записів в файлі: '
                    || l_full_lines
                    || '<br>'
                    || CHR (10));
            EXCEPTION
                WHEN OTHERS
                THEN
                    --ikis_rbm.rdm$log_packet.insert_message(p_lp_pkt => p_rbm_pkt,  p_lp_comment => '&102#/paymentlists/#'||sqlerrm);
                    raise_application_error (
                        -20000,
                        'Не вдалось отимати з вхідного запиту параметри /paymentlists/' /*||sqlerrm|| dbms_utility.format_error_backtrace*/
                                                                                       );
            END;
        ELSIF p_pkt_tp = 103
        THEN                                                           -- КВ-2
            BEGIN
                                SELECT x_id,
                                       TO_DATE (x_date_cr, 'dd.mm.yyyy hh24:mi:ss'),
                                       x_filia_num,
                                       x_filia_name,
                                       x_full_lines,
                                       x_opfu_code,
                                       x_opfu_name,
                                       x_full_sum,
                                       x_return_full_sum,
                                       x_return_full_lines
                                  INTO l_rbm_pkt_id,
                                       l_date_cr,
                                       l_filia_num,
                                       l_filia_name,
                                       l_full_lines,
                                       l_opfu_code,
                                       l_opfu_name,
                                       l_full_sum,
                                       l_return_full_sum,
                                       l_return_full_lines
                                  FROM XMLTABLE (
                                           '/paymentlists'
                                           PASSING l_xml_data
                                           COLUMNS x_id                   NUMBER PATH 'id',
                                                   x_date_cr              VARCHAR2 (25) PATH 'date_cr',
                                                   x_filia_num            VARCHAR2 (10) PATH 'filia_num',
                                                   x_filia_name           VARCHAR2 (100) PATH 'filia_name',
                                                   x_full_lines           NUMBER PATH 'full_lines',
                                                   x_opfu_code            VARCHAR2 (10) PATH 'opfu_code',
                                                   x_opfu_name            VARCHAR2 (250) PATH 'opfu_name',
                                                   x_full_sum             VARCHAR2 (250) PATH 'full_sum',
                                                   x_return_full_sum      NUMBER PATH 'return_full_sum',
                                                   x_return_full_lines    NUMBER PATH 'return_full_lines');

                BEGIN
                    l_ecp :=
                        l_xml_data.EXTRACT (
                            '/paymentlists/ecp_list/ecp/text()').getClobVal ();
                --.extract('/paymentlists/ecp_list/ecp/text()').getClobVal();
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        l_ecp := NULL;
                END;

                DBMS_LOB.append (
                    l_visual_clob,
                       '<H5>Відповідь банку з відмітками про зарахування коштів від '
                    || TO_CHAR (l_date_cr, 'dd.mm.yyyy')
                    || '</H5>'
                    || CHR (10));
                DBMS_LOB.append (
                    l_visual_clob,
                       'УПСЗН: '
                    || l_opfu_code
                    || ' '
                    || l_opfu_name
                    || '<br>'
                    || CHR (10));
                DBMS_LOB.append (
                    l_visual_clob,
                       'Філія: '
                    || l_filia_num
                    || ' '
                    || l_filia_name
                    || '<br>'
                    || CHR (10));
                DBMS_LOB.append (
                    l_visual_clob,
                       'Загальна кількість рядків за списками: '
                    || l_full_lines
                    || '<br>'
                    || CHR (10));
                DBMS_LOB.append (
                    l_visual_clob,
                       'Загальна сума за списками в копійках: '
                    || l_full_sum
                    || '<br>'
                    || CHR (10));
                DBMS_LOB.append (
                    l_visual_clob,
                       'Загальна кількість рядків за списками по яким не зараховано кошти: '
                    || l_return_full_lines
                    || '<br>'
                    || CHR (10));
                DBMS_LOB.append (
                    l_visual_clob,
                       'Загальна сума не зарахованих коштів в копійках: '
                    || l_return_full_sum
                    || '<br>'
                    || CHR (10));
            EXCEPTION
                WHEN OTHERS
                THEN
                    --ikis_rbm.rdm$log_packet.insert_message(p_lp_pkt => p_rbm_pkt,  p_lp_comment => '&102#/paymentlists/#'||sqlerrm);
                    raise_application_error (
                        -20000,
                        'Не вдалось отимати з вхідного запиту параметри /paymentlists/'        /*||sqlerrm
||chr(10)||dbms_utility.format_error_stack||dbms_utility.format_error_backtrace*/
                                                                                       );
            END;
        END IF;

        --dbms_output.put_line(l_visual_clob);

        -- перевіряємо, чи є вкладений файл квитанцією на пакет ВВ даної відомості
        IF p_pkt_tp IN (102, 103)
        THEN                                                         -- КВ-1/2
            SELECT COUNT (1)
              INTO l_pr_pkt_cnt
              FROM payroll_reestr pr
             WHERE     pr.pe_src_entity = p_payroll_id
                   AND pr.pe_rbm_pkt = l_rbm_pkt_id;

            IF l_pr_pkt_cnt = 0
            THEN
                raise_application_error (
                    -20000,
                    'Вкладений файл не є квитанцією на пакет ПЕОД вказаної відомості!');
            END IF;

            -- якщо по пакету ПЕОД уже існує КВ-1 в статусі відмінному від "видалено", то "Для даного пакета відомостей уже завантажено КВ-1"
            IF p_pkt_tp IN (102)
            THEN
                SELECT COUNT (1)
                  INTO l_pr_pkt_cnt
                  FROM ikis_rbm.v_packet  p
                       JOIN ikis_rbm.v_packet_links pl
                           ON pl.pl_pkt_in = p.pkt_id
                 WHERE     pl.pl_pkt_out = l_rbm_pkt_id
                       AND p.pkt_pat = 102
                       AND p.pkt_st != 'D';                -- можливо ще M ???

                IF l_pr_pkt_cnt > 0
                THEN
                    raise_application_error (
                        -20000,
                        'Для вказаного в квитанції пакета відомостей уже завантажено КВ-1"!');
                END IF;
            END IF;
        END IF;

        -- визначаємо дані пакета ВВ на який формується відповідь -- одержувача
        BEGIN
            SELECT p.*
              INTO l_pkt_row
              FROM ikis_rbm.v_packet p
             WHERE p.pkt_id = l_rbm_pkt_id                     /*l_pr_pkt_id*/
                                          ;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RAISE exNoPktExists;
        END;

        -- Контролі на пакет ВВ - тип, статус і т.д.
        --  if l_pkt_row.pkt_pt != 21   then
        IF l_pkt_row.pkt_st NOT IN ('NVP', 'SND', 'RCV')
        THEN
            raise_application_error (
                -20000,
                'Пакет ПЕОД, для якого завантажено квитанцію, ще не передавався банку!');
        END IF;

        SELECT MAX (r.rec_tp), MAX (r.rec_name), MAX (r.rec_code)
          INTO l_rec_tp, l_rec_name, l_rec_code
          FROM ikis_rbm.v_recipient r
         WHERE r.rec_id = l_pkt_row.pkt_rec;

        IF NVL (l_rec_tp, 'z') != 'CMES' AND l_rec_code != 'TESTBANK1'
        THEN
            raise_application_error (
                -20000,
                   'Одержувач '
                || l_rec_name
                || ' не може завантажувати квитанції через кабінет банка!');
        END IF;

        /*  -- контроль навідповідність вказаного ід пакета ВВ та ід пакета ВВ в файлі завантаженої КВ
          if l_pr_pkt_id is not null and l_pr_pkt_id != nvl(l_rbm_pkt_id, -1) then
            raise_application_error(-20000, 'ід пакета ВВ <'||l_pr_pkt_id||'> не відповідає ід пакета ВВ в файлі завантаженої КВ <'||l_rbm_pkt_id||'>');
          end if;*/
        -- вичитати з l_xml_data
        l_ef_header :=
            CASE
                WHEN p_pkt_tp = 103
                THEN                                                  -- 'PPR'
                       '<id>'
                    || l_rbm_pkt_id
                    || '</id><opfu_code>'
                    || l_pkt_row.pkt_org
                    || '</opfu_code><date_cr>'
                    || TO_CHAR (l_create_dt, 'yyyymmddhh24miss')
                    || '</date_cr><filia_num>'
                    || l_filia_num
                    || '</filia_num><filia_name>'
                    || l_filia_name
                    || '</filia_name>'
                    || '<full_sum>'
                    || l_full_sum
                    || '</full_sum><full_lines>'
                    || l_full_lines
                    || '</full_lines>'
                    ||                                               -- #72870
                       '<return_full_sum>'
                    || l_return_full_sum
                    || '</return_full_sum><return_full_lines>'
                    || l_return_full_lines
                    || '</return_full_lines>'
                WHEN p_pkt_tp = 102
                THEN                                                  -- 'PCA'
                       '<id>'
                    || l_rbm_pkt_id
                    || '</id><opfu_code>'
                    || l_pkt_row.pkt_org
                    || '</opfu_code><date_time>'
                    || TO_CHAR (l_create_dt, 'yyyymmddhh24miss')
                    || '</date_time><filia_num>'
                    || l_filia_num
                    || '</filia_num><filia_name>'
                    || l_filia_name
                    || '</filia_name>'
                    || '<full_lines>'
                    || l_full_lines
                    || '</full_lines>'                               -- #72870
            END;
        l_ef_name :=
               CASE
                   WHEN p_pkt_tp = 102 THEN 'PCA_'
                   WHEN p_pkt_tp = 103 THEN 'PPR_'
                   WHEN p_pkt_tp = 82 THEN 'PR2DA_'
               END
            || l_pkt_row.pkt_org
            || '.'
            || l_filia_num
            || '_'
            || TO_CHAR (l_create_dt, 'yyyymmddhh24miss')
            || '_'
            || l_rbm_pkt_id;


        -- додати
        -- 1 назва файла
        -- 2 шифрований блоб !!!!
        INSERT INTO exchangefiles (ef_id,
                                   ef_po,
                                   com_wu,
                                   com_org,
                                   ef_tp,
                                   ef_name,
                                   ef_data,
                                   ef_visual_data,
                                   ef_header,
                                   ef_main_tag_name,
                                   ef_data_name,
                                   ef_ecp_list_name,
                                   ef_ecp_name,
                                   ef_ecp_alg,
                                   ef_st,
                                   ef_dt,
                                   ef_ident_data,
                                   ef_ecs,
                                   ef_rec,
                                   ef_file_idn,
                                   ef_ef,
                                   ef_pkt,
                                   ef_file_name,
                                   ef_encr_blob)
            SELECT NULL,
                   NULL,
                   NULL,
                   l_pkt_row.pkt_org,
                   'F'               AS ef_tp,
                   l_ef_name         AS ef_name,
                   l_zip             AS ef_data,
                   l_visual_clob     AS ef_visual_data,
                   l_ef_header       AS ef_header,
                   l_ef_tag,
                   'file_data',
                   'ecp_list',
                   'ecp',
                   'MD',
                   'Z',
                   l_create_dt,
                   'ФС:',
                   l_ecs,
                   l_pkt_row.pkt_rec,
                   NULL,
                   NULL,
                   l_rbm_pkt_id,
                   p_pkt_name,
                   p_pkt_encr_blob
              FROM DUAL;

        -- створюємо пакет в ПЕОД
        INSERT INTO ikis_rbm.tmp_exchangefiles_m3 (ef_id,
                                                   ef_po,
                                                   com_wu,
                                                   com_org,
                                                   ef_tp,
                                                   ef_name,
                                                   ef_data,
                                                   ef_visual_data,
                                                   ef_header,
                                                   ef_main_tag_name,
                                                   ef_data_name,
                                                   ef_ecp_list_name,
                                                   ef_ecp_name,
                                                   ef_ecp_alg,
                                                   ef_st,
                                                   ef_dt,
                                                   ef_ident_data,
                                                   ef_ecs,
                                                   ef_rec,
                                                   ef_pkt,
                                                   ef_encr_blob)
            SELECT ef_id,
                   ef_po,
                   com_wu,
                   com_org,
                   ef_tp,
                   ef_name,
                   ef_data,
                   ef_visual_data,
                   ef_header,
                   ef_main_tag_name,
                   ef_data_name,
                   ef_ecp_list_name,
                   ef_ecp_name,
                   ef_ecp_alg,
                   ef_st,
                   ef_dt,
                   ef_ident_data,
                   ef_ecs,
                   ef_rec,
                   ef_pkt,
                   p_pkt_encr_blob
              FROM exchangefiles
             WHERE ef_ecs = l_ecs;

        ikis_rbm.ikis_rbm_esr.GenPaketsFromTMPTable;

           -- витягуємо ід створеної КВ
           UPDATE exchangefiles f
              SET f.ef_kv_pkt =
                      (SELECT t.ef_kv_pkt
                         FROM ikis_rbm.tmp_exchangefiles_m3 t
                        WHERE t.ef_id = f.ef_id)
            WHERE     ef_ecs = l_ecs
                  AND ef_pkt = l_rbm_pkt_id
                  AND ef_file_name = p_pkt_name
        RETURNING ef_kv_pkt
             INTO l_kv_pkt;
    --- p_message := 'Формування пакетів завершено.';
    /*
        -- #67827  проаналізувати заповнення полів num_return + date_return в КВ-2
        if p_pkt_tp = 102 then -- КВ-2
            if dbms_lob.instr(upper(l_xml_content.getClobVal()), 'ENCODING="UTF-8"') > 0 then  -- 20210524
              l_xml_content := xmltype(tools.utf8todeflang(l_xml_content.getClobVal()));
            end if;

           ProcPPRReturn(p_pkt_rec_code   => l_rec_code,
                         p_pkt_id         => l_kv_pkt,
                         p_pkt_xml        => l_xml_content);
       end if;*/
    EXCEPTION
        WHEN exNoPktExists
        THEN --raise_application_error(-20000, 'Пакет ід = '||l_rbm_pkt_id||' не знайдено в ПЕОД!');
            p_message :=
                'Пакет ід = ' || l_rbm_pkt_id || ' не знайдено в ПЕОД!';
        WHEN exPktExists
        THEN --raise_application_error(-20000, 'Створення файлів з даними параметрами вже виконувалось!');
            p_message :=
                'Завантаження файлів з даними параметрами вже виконувалось!';
        WHEN exPktFileEmpty
        THEN     --raise_application_error(-20000, 'Вкладено порожній файл!');
            p_message := 'Вкладено порожній файл!';
        WHEN exBadPoSt
        THEN --raise_application_error(-20000, 'Створення файлів можливе тільки для ПД у стані "Проведено банком"!');
            p_message :=
                'Створення файлів можливе тільки для ПД у стані "Проведено банком"!';
        WHEN exBadRec
        THEN --raise_application_error(-20000, 'Не вдалося однозначно визначити одержувача реєстру ПД!');
            p_message :=
                'Не вдалося однозначно визначити одержувача реєстру ПД!';
        WHEN OTHERS
        THEN --raise_application_error(-20000, 'API$ESR_EXCHANGE.GenRv2PdPackets:'||chr(10)||replace(DBMS_UTILITY.FORMAT_ERROR_STACK||' => '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,'ORA-20000:')||chr(10)||sqlerrm);
            IF INSTR (SQLERRM, 'ORA-20000') > 0
            THEN
                p_message := REPLACE (SQLERRM, 'ORA-20000:', '');
            ELSE
                raise_application_error (
                    -20000,
                       'API$ESR_EXCHANGE.GenRv2PdPackets:'
                    || CHR (10)
                    || REPLACE (
                              DBMS_UTILITY.FORMAT_ERROR_STACK
                           || ' => '
                           || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                           'ORA-20000:')
                    || CHR (10)
                    || SQLERRM);
            END IF;
    END;


    PROCEDURE GenKVPackets82 (p_rbm_pkt_id   NUMBER,
                              p_pkt_tp       VARCHAR2,
                              p_po_id        NUMBER,
                              p_po_result    NUMBER,
                              p_pkt_info     CLOB,
                              p_pkt_blob     BLOB)
    IS
        l_filter         VARCHAR2 (250);
        l_ecs            exchcreatesession.ecs_id%TYPE;
        l_cnt            INTEGER;
        l_filia_code     VARCHAR2 (10);    ---payroll_reestr.pe_bnk_code%type;
        l_ef_tag         exchangefiles.ef_main_tag_name%TYPE;
        l_ef_name        exchangefiles.ef_name%TYPE;
        l_ef_header      exchangefiles.ef_header%TYPE;
        l_pkt_row        ikis_rbm.v_packet%ROWTYPE;
        l_create_dt      DATE := SYSDATE;
        l_filia_name     VARCHAR2 (500);
        exPktExists      EXCEPTION;
        exNoPktExists    EXCEPTION;
        exPktFileEmpty   EXCEPTION;
        exBadRec         EXCEPTION;
        exBadPoSt        EXCEPTION;
    BEGIN
        NULL;
    /*-- 'Розпочато формування файлів для електронного обміну - Реєстр ПД'
      l_filter := 'rv2pda'||'#'||p_pkt_tp||'#'||p_po_id||'#'||p_rbm_pkt_id;

      SELECT COUNT(1) INTO l_cnt FROM exchcreatesession WHERE ecs_filter = l_filter;
      IF l_cnt > 0 THEN
        raise exPktExists;
      END IF;

      --тільки для ВВ у стані "передано банку"  ????
    \*  select max(po.po_status) into l_po_st
      from pay_order po
      where po_id = p_po_id;

      if nvl(l_po_st, 'zzz') != 'APPR' then
        raise exBadPoSt;
      end if;*\

      INSERT INTO exchcreatesession (ecs_id, ecs_start_dt, ecs_filter)
        VALUES (0, l_create_dt, l_filter)
      RETURNING ecs_id INTO l_ecs;

      -- визначаємо дані пакета ВВ на який формується відповідь -- одержувача
      begin
        select p.* into l_pkt_row
        from ikis_rbm.v_packet p
        where p.pkt_id = p_rbm_pkt_id;
      exception
        when no_data_found then
          raise exNoPktExists;
      end;

      -- Контролі на пакет ВВ - тип, статус і т.д.
    --  if l_pkt_row.pkt_pt != 21   then
    --  if l_pkt_row.pkt_st not in (????'NVP', 'SND', 'RCV')   then

      if p_pkt_blob is null or dbms_lob.getlength(p_pkt_blob) < 10 then
        raise exPktFileEmpty;
      end if;

    \*  select count(distinct pkt_rec), max(pkt_rec)
      into l_rec_cnt, l_rec_id
      from payroll_reestr pr
      join ikis_rbm.v_packet p on pr.pe_rbm_pkt = p.pkt_id
      where pe_po = p_po_id;*\
      \*
      dbms_output.put_line('l_rec_cnt='||l_rec_cnt);
      dbms_output.put_line('l_rec_id='||l_rec_id);
      *\
    \*  IF l_rec_cnt != 1 or nvl(l_rec_id, 0) = 0 THEN
        raise exBadRec;
      END IF;*\

      select max(pr.pr_bnk_code) into l_filia_code   \* pr_filia_code буває незаповнена в ВВ ППВП *\
      from payroll_reestr pr
      where pr.pe_rbm_pkt = p_rbm_pkt_id;

      l_ef_tag := case when p_pkt_tp = 22 then 'post_payment_reply'
                       when p_pkt_tp = 23 then 'post_convert_answer'
                       when p_pkt_tp = 82 then 'post_rv2pd_answer'
                  end;

      l_ef_name := case when p_pkt_tp = 22 then 'PPR_'
                        when p_pkt_tp = 23 then 'PCA_'
                        when p_pkt_tp = 82 then 'PR2DA_'
                   end||
                   l_pkt_row.pkt_org||'.'||l_filia_code||'_'||to_char(l_create_dt,'yyyymmddhh24miss')||'_'||p_rbm_pkt_id;

     \* l_ef_header := case when p_pkt_tp = 22 then -- 'PPR'
                                       '<id>'||p_rbm_pkt_id||'</id><opfu_code>'||l_pkt_row.pkt_org||'</opfu_code><date_cr>'||to_char(l_create_dt,'yyyymmddhh24miss')||
                                       '</date_cr><filia_num>'||l_filia_code||'</filia_num><filia_name>'||p_filia_name||'</filia_name>'
                          when p_pkt_tp = 23 then -- 'PCA'
                                       '<id>'||p_rbm_pkt_id||'</id><opfu_code>'||l_pkt_row.pkt_org||'</opfu_code><date_time>'||to_char(l_create_dt,'yyyymmddhh24miss')||
                                       '</date_time><filia_num>'||l_filia_code||'</filia_num><filia_name>'||p_filia_name||'</filia_name>'
                      end;*\
    \*  l_ef_header := case when p_pkt_tp = 82 then
                           '<id>'||p_rbm_pkt_id||'</id><idpd>'||p_po_id||'</idpd><opfu_code>'||l_pkt_row.pkt_org||'</opfu_code><date_cr>'||to_char(l_create_dt,'yyyymmddhh24miss')
                     end;*\
      INSERT INTO exchangefiles (ef_id, ef_po, com_wu, com_org, ef_tp, ef_name, ef_data, ef_visual_data, ef_header,
                                 ef_main_tag_name, ef_data_name, ef_ecp_list_name, ef_ecp_name, ef_ecp_alg,
                                 ef_st, ef_dt, ef_ident_data, ef_ecs, ef_rec, ef_file_idn, ef_ef, ef_pkt, ef_file_name,
                                 ef_prc_code)
      select
         null, p_po_id, null, l_pkt_row.pkt_org, 'F' as ef_tp,
         l_ef_name as ef_name,
         p_pkt_blob as ef_data,
         p_pkt_info as ef_visual_data,
         l_ef_header as ef_header,
         l_ef_tag, 'file_data', 'ecp_list', 'ecp', 'MD',
         'Z', l_create_dt, 'КВ ПД:'||p_po_id, l_ecs, l_pkt_row.pkt_rec, null, null,
         p_rbm_pkt_id, l_ef_name, p_po_result
      from  dual;

      -- створюємо пакет в ПЕОД
      INSERT INTO ikis_rbm.tmp_exchangefiles_m3(ef_id, ef_po, com_wu, com_org, ef_tp, ef_name, ef_data,
                                       ef_visual_data, ef_header, ef_main_tag_name, ef_data_name,
                                       ef_ecp_list_name, ef_ecp_name, ef_ecp_alg, ef_st,
                                       ef_dt, ef_ident_data, ef_ecs, ef_rec, ef_pkt)
        SELECT ef_id, ef_po, com_wu, com_org, ef_tp, ef_name, ef_data,
               ef_visual_data , ef_header, ef_main_tag_name, ef_data_name,
               ef_ecp_list_name, ef_ecp_name, ef_ecp_alg, ef_st, ef_dt,
               ef_ident_data, ef_ecs, ef_rec, ef_pkt
        FROM exchangefiles
        WHERE ef_ecs = l_ecs;

      ikis_rbm.ikis_rbm_finzvit.GenPaketsFromTMPTable;

        -- витягуємо ід створеної КВ
      update exchangefiles f
      set f.ef_kv_pkt = (select t.ef_kv_pkt from ikis_rbm.tmp_exchangefiles_m3 t where t.ef_id = f.ef_id)
      where ef_ecs = l_ecs
       -- and ef_pkt = p_rbm_pkt_id
        and ef_po = p_po_id;

        -- прописуємо результат обробки на запис реєстру ПД
      update exchangefiles f
      set f.ef_prc_code = p_po_result
      where ef_pkt = p_rbm_pkt_id
        and ef_po = p_po_id;*/
    EXCEPTION
        WHEN exNoPktExists
        THEN
            raise_application_error (
                -20000,
                'Пакет ід = ' || p_rbm_pkt_id || ' не знайдено в ПЕОД!');
        WHEN exPktExists
        THEN
            raise_application_error (
                -20000,
                'Створення файлів з даними параметрами вже виконувалось!');
        WHEN exPktFileEmpty
        THEN
            raise_application_error (-20000, 'Вкладено порожній файл!');
        WHEN exBadPoSt
        THEN
            raise_application_error (
                -20000,
                'Створення файлів можливе тільки для ПД у стані "Проведено банком"!');
        WHEN exBadRec
        THEN
            raise_application_error (
                -20000,
                'Не вдалося однозначно визначити одержувача реєстру ПД!');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'API$ESR_EXCHANGE.GenRv2PdPackets:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;

    PROCEDURE GenKVPackets_0 (p_rbm_pkt_id   NUMBER,
                              p_pkt_tp       VARCHAR2,
                              --p_pkt_rec    varchar2,
                              p_filia_name   VARCHAR2,
                              p_pkt_info     CLOB,
                              p_pkt_blob     BLOB)
    IS
        l_filter         VARCHAR2 (250);
        l_ecs            exchcreatesession.ecs_id%TYPE;
        l_cnt            INTEGER;
        l_filia_code     VARCHAR2 (10);    -- payroll_reestr.pr_bnk_code%type;
        l_ef_tag         exchangefiles.ef_main_tag_name%TYPE;
        l_ef_name        exchangefiles.ef_name%TYPE;
        l_ef_header      exchangefiles.ef_header%TYPE;
        l_pkt_row        ikis_rbm.v_packet%ROWTYPE;
        l_create_dt      DATE := SYSDATE;
        l_filia_name     VARCHAR2 (500);
        exPktExists      EXCEPTION;
        exNoPktExists    EXCEPTION;
        exPktFileEmpty   EXCEPTION;
        exBadRec         EXCEPTION;
        exBadPoSt        EXCEPTION;
    BEGIN
        NULL;
    /*-- 'Розпочато формування файлів для електронного обміну - Реєстр ПД'
      l_filter := 'pkt'||'#'||p_pkt_tp||'#'||p_rbm_pkt_id;

      SELECT COUNT(1) INTO l_cnt FROM exchcreatesession WHERE ecs_filter = l_filter;
      IF l_cnt > 0 THEN
        raise exPktExists;
      END IF;

      --тільки для ВВ у стані "передано банку"  ????
    \*  select max(po.po_status) into l_po_st
      from pay_order po
      where po_id = p_po_id;

      if nvl(l_po_st, 'zzz') != 'APPR' then
        raise exBadPoSt;
      end if;*\

      INSERT INTO exchcreatesession (ecs_id, ecs_start_dt, ecs_filter)
        VALUES (0, l_create_dt, l_filter)
      RETURNING ecs_id INTO l_ecs;

      -- визначаємо дані пакета ВВ на який формується відповідь -- одержувача
      begin
        select p.* into l_pkt_row
        from ikis_rbm.v_packet p
        where p.pkt_id = p_rbm_pkt_id;
      exception
        when no_data_found then
          raise exNoPktExists;
      end;

      -- Контролі на пакет ВВ - тип, статус і т.д.
    --  if l_pkt_row.pkt_pt != 21   then
    --  if l_pkt_row.pkt_st not in (????'NVP', 'SND', 'RCV')   then

      if p_pkt_blob is null or dbms_lob.getlength(p_pkt_blob) < 10 then
        raise exPktFileEmpty;
      end if;

    \*  select count(distinct pkt_rec), max(pkt_rec)
      into l_rec_cnt, l_rec_id
      from payroll_reestr pr
      join ikis_rbm.v_packet p on pr.pe_rbm_pkt = p.pkt_id
      where pe_po = p_po_id;*\
      \*
      dbms_output.put_line('l_rec_cnt='||l_rec_cnt);
      dbms_output.put_line('l_rec_id='||l_rec_id);
      *\
    \*  IF l_rec_cnt != 1 or nvl(l_rec_id, 0) = 0 THEN
        raise exBadRec;
      END IF;*\

      select max(pr.pr_bnk_code) into l_filia_code   \* pr_filia_code буває незаповнена в ВВ ППВП *\
      from payroll_reestr pr
      where pr.pe_rbm_pkt = p_rbm_pkt_id;

      l_ef_tag := case when p_pkt_tp = 22 then 'post_payment_reply'
                       when p_pkt_tp = 23 then 'post_convert_answer'
                       when p_pkt_tp = 82 then 'post_rv2pd_answer'
                  end;

      l_ef_name := case when p_pkt_tp = 22 then 'PPR_'
                        when p_pkt_tp = 23 then 'PCA_'
                        when p_pkt_tp = 82 then 'PR2DA_'
                   end||
                   l_pkt_row.pkt_org||'.'||l_filia_code||'_'||to_char(l_create_dt,'yyyymmddhh24miss')||'_'||p_rbm_pkt_id;

      l_ef_header := case when p_pkt_tp = 22 then -- 'PPR'
                                       '<id>'||p_rbm_pkt_id||'</id><opfu_code>'||l_pkt_row.pkt_org||'</opfu_code><date_cr>'||to_char(l_create_dt,'yyyymmddhh24miss')||
                                       '</date_cr><filia_num>'||l_filia_code||'</filia_num><filia_name>'||p_filia_name||'</filia_name>'
                          when p_pkt_tp = 23 then -- 'PCA'
                                       '<id>'||p_rbm_pkt_id||'</id><opfu_code>'||l_pkt_row.pkt_org||'</opfu_code><date_time>'||to_char(l_create_dt,'yyyymmddhh24miss')||
                                       '</date_time><filia_num>'||l_filia_code||'</filia_num><filia_name>'||p_filia_name||'</filia_name>'
                      end;

      INSERT INTO exchangefiles (ef_id, ef_po, com_wu, com_org, ef_tp, ef_name, ef_data, ef_visual_data, ef_header,
                                 ef_main_tag_name, ef_data_name, ef_ecp_list_name, ef_ecp_name, ef_ecp_alg,
                                 ef_st, ef_dt, ef_ident_data, ef_ecs, ef_rec, ef_file_idn, ef_ef, ef_pkt)
      select
         null, null, null, l_pkt_row.pkt_org, 'F' as ef_tp,
         l_ef_name as ef_name,
         p_pkt_blob as ef_data,
         p_pkt_info as ef_visual_data,
         l_ef_header as ef_header,
         l_ef_tag, 'file_data', 'ecp_list', 'ecp', 'MD',
         'Z', l_create_dt, 'ФС:', l_ecs, l_pkt_row.pkt_rec, null, null,
         p_rbm_pkt_id
      from  dual;

      -- створюємо пакет в ПЕОД
      INSERT INTO ikis_rbm.tmp_exchangefiles_m3(ef_id, ef_po, com_wu, com_org, ef_tp, ef_name, ef_data,
                                       ef_visual_data, ef_header, ef_main_tag_name, ef_data_name,
                                       ef_ecp_list_name, ef_ecp_name, ef_ecp_alg, ef_st,
                                       ef_dt, ef_ident_data, ef_ecs, ef_rec, ef_pkt)
        SELECT ef_id, ef_po, com_wu, com_org, ef_tp, ef_name, ef_data,
               ef_visual_data , ef_header, ef_main_tag_name, ef_data_name,
               ef_ecp_list_name, ef_ecp_name, ef_ecp_alg, ef_st, ef_dt,
               ef_ident_data, ef_ecs, ef_rec, ef_pkt
        FROM exchangefiles
        WHERE ef_ecs = l_ecs;

      ikis_rbm.ikis_rbm_finzvit.GenPaketsFromTMPTable;

    */
    EXCEPTION
        WHEN exNoPktExists
        THEN
            raise_application_error (
                -20000,
                'Пакет ід = ' || p_rbm_pkt_id || ' не знайдено в ПЕОД!');
        WHEN exPktExists
        THEN
            raise_application_error (
                -20000,
                'Створення файлів з даними параметрами вже виконувалось!');
        WHEN exPktFileEmpty
        THEN
            raise_application_error (-20000, 'Вкладено порожній файл!');
        WHEN exBadPoSt
        THEN
            raise_application_error (
                -20000,
                'Створення файлів можливе тільки для ПД у стані "Проведено банком"!');
        WHEN exBadRec
        THEN
            raise_application_error (
                -20000,
                'Не вдалося однозначно визначити одержувача реєстру ПД!');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'API$ESR_EXCHANGE.GenRv2PdPackets:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;


    -- конверт ВВ по пекету ПЕОД з штфрованими даними
    FUNCTION GetConvert (p_id NUMBER, p_recipient_code VARCHAR2)
        RETURN CLOB
    IS
        l_result       CLOB;
        l_pre_result   CLOB;
        l_data         CLOB;
        l_header       ikis_rbm.v_packet_content.pc_header%TYPE;
        l_st           ikis_rbm.v_packet.pkt_st%TYPE;
    BEGIN
        NULL;
        /*  BEGIN
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
              AND pkt_pt in ( 1, 21 ) -- payroll_pvp, payrollpassport_ppvp -- ivashchuk  #24611 20170823 -> #17432 20160823
              AND EXISTS (SELECT 1 FROM ikis_rbm.v_recipient WHERE pkt_rec = rec_id AND rec_code = p_recipient_code);

            SELECT TOOLS.ConvertBlobToBase64(pc_encrypt_data), pc_header
            INTO l_data, l_header FROM ikis_rbm.v_packet_content
            WHERE pc_pkt = p_id
              and pc_encrypt_data is not null
              and dbms_lob.getlength(pc_encrypt_data) > 10;
            l_result := TOOLS.PasteClob(l_pre_result, l_header, '<xXx>z</xXx>');
            l_pre_result := l_result;
            l_result := TOOLS.PasteClob(l_pre_result, l_data, 'XX##XX');

          EXCEPTION
            WHEN no_data_found THEN
              l_result := '<paymentlists></paymentlists>';
          END;*/
        RETURN l_result;
    END;

    -- 67448  Процедура перевірки можливості видалення реєстру по ПД в ПЕОД
    -- p_can_del -  0/1  = видалення заборонено /  дозволено
    PROCEDURE CheckPoReestrDel (p_po_id IN NUMBER, p_can_del OUT NUMBER)
    IS
        l_pkt_id        NUMBER;
        l_pkt_st        VARCHAR2 (10);
        l_pkt_st_name   VARCHAR2 (100);
        l_result        NUMBER;
    BEGIN
        NULL;
    /*p_can_del := 0;

    begin
      select pkt_id, pkt_st
      into l_pkt_id, l_pkt_st
      from ikis_rbm.v_packet p
      join exchangefiles f on ef_pkt = pkt_id and ef_tp = 'rv2pd_list'
      where ef_po = p_po_id
        and pkt_pt = 81
        and pkt_st not in ('D');
     exception when no_data_found
       then
         p_can_del := 1;
     end;

     if nvl(l_pkt_st, 'z') in ('NVP','SND', 'RCV') then
       p_can_del := 0;
     else
       p_can_del := 1;
     end if;*/
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'API$ESR_EXCHANGE.CheckPoReestrDel:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;

    -- 67448  Процедура перевірки та встановлення статусу "видалено" ресєтру по ПД в ПЕОД
    PROCEDURE SetPoReestrDel (p_po_id IN NUMBER, --p_pkt_id  out number,
                                                 --p_pkt_st  out varchar2,
                                                 p_msg OUT VARCHAR2)
    IS
        l_pkt_id        NUMBER;
        l_pkt_st        VARCHAR2 (10);
        l_pkt_st_name   VARCHAR2 (100);
        l_ecp_cnt       NUMBER := 0;
        l_result        NUMBER;
    BEGIN
        NULL;
    /*begin
      select pkt_id, pkt_st
      into l_pkt_id, l_pkt_st
      from ikis_rbm.v_packet p
      join exchangefiles f on ef_pkt = pkt_id and ef_tp = 'rv2pd_list'
      where ef_po = p_po_id
        and pkt_pt = 81
        and pkt_st not in ('D');
     exception when no_data_found
       then
         l_pkt_id := null;
         l_pkt_st := null;
         p_msg    := null;
     end;

     if l_pkt_id >0 and nvl(l_pkt_st, 'z') not in ('NVP','SND', 'RCV') then
      select count(1) into l_ecp_cnt
      from ikis_rbm.v_packet_content, ikis_rbm.v_packet_ecp
      where pce_pc = pc_id
        and pc_pkt = l_pkt_id;
     end if;

     if nvl(l_pkt_st, 'z') in ('NVP','SND', 'RCV') then
       select dic_sname into l_pkt_st_name
       from ikis_rbm.v_ddn_packet_st
       where dic_value = l_pkt_st;

       p_msg := 'Реєстр не може бути видалений, статус реєстру "'||l_pkt_st_name||'"';
     elsif l_ecp_cnt > 0 then
       p_msg := 'Реєстри по ПД підписані в ПЕОД. Видалення ПД не можливе';
     elsif l_pkt_id >0 then
       ikis_rbm.ikis_rbm_finzvit.del_pkt81(l_pkt_id, l_result);
     elsif l_pkt_id is null then
       p_msg := null;-- 'Реєстр не знайдено!';
     end if;*/
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'API$ESR_EXCHANGE.SetPoReestrDel:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;


    -- info:  #67535 Вивантаження реєстру відомостей по ПД в csv
    -- params: p_po_id  – ід ПД
    --         p_fname  - назва файлу архіва з csv
    --         p_result - zip - архів з csv
    -- note:  Формування Csv звіту по ПД //// замість вивантаження пакетів "конверт з реєстром списків по платіжному дорученню" в ПЕОД
    PROCEDURE GenRv2PdCsv (p_po_id    IN     NUMBER,
                           p_fname       OUT VARCHAR2,
                           p_result      OUT BLOB)
    IS
        l_Rv2Pd_clob    CLOB;
        l_visual_clob   CLOB;
        l_rec_cnt       INTEGER;
        l_rec_id        INTEGER;
        l_org           NUMBER
            := SYS_CONTEXT (uss_esr_context.gContext, uss_esr_context.gORG);
        l_wu            NUMBER
            := SYS_CONTEXT (uss_esr_context.gContext, uss_esr_context.gUID);
        l_filter        VARCHAR2 (250);
        l_po_st         VARCHAR2 (10);
        l_cnt           INTEGER;
        exNoPktExists   EXCEPTION;
        exBadRec        EXCEPTION;
        exBadPoSt       EXCEPTION;
        exNoData        EXCEPTION;
        l_file_name     VARCHAR2 (500);
        l_header        VARCHAR2 (32000);
        l_csv_delim     VARCHAR2 (1) := ';';
        l_csv_clob      CLOB;
        l_files         ikis_sysweb.tbl_some_files
                            := ikis_sysweb.tbl_some_files ();
    BEGIN
        NULL;
    /*-- 'Розпочато формування файлів для електронного обміну - Реєстр ПД'
    \*  це альтернатива, вони так і не заберуть з ПЕОД. Не будемо захламляти ПЕОД)
      l_filter := 'rv2pd'||'#'||p_po_id;
      SELECT COUNT(1) INTO l_cnt FROM exchcreatesession WHERE ecs_filter = l_filter;
      IF l_cnt = 0 THEN
        raise exNoPktExists;
      END IF;*\

      --тільки для ПД у стані "Проведено банком"
      select max(po.po_status) into l_po_st
      from pay_order po
      where po_id = p_po_id;

      if nvl(l_po_st, 'zzz') != 'APPR' then
        raise exBadPoSt;
      end if;

    -- Рядок заголовок. відповідає блоку pd_info.
       select
        --pkt_id||l_csv_delim||
        po_id||l_csv_delim||
        to_char(po.po_date_pay, 'DDMMYYYY')||l_csv_delim|| -- pd_date
        po.po_number||l_csv_delim|| -- pd_num
        to_char(sysdate, 'DDMMYYYY')||l_csv_delim|| -- rv_date
        po.po_sum*100||l_csv_delim|| -- rv_sum
        (select sum(pr_row_cnt) from payroll_reestr where pe_po = po_id)||l_csv_delim|| -- rv_lines
        chr(10) ,
        'RV2PD_LIST_'||po.po_number||'_'||to_char(po.po_date_pay,'YYYYMMDD_HH24MISS')
      into l_header, l_file_name
      from pay_order po
    \*  це альтернатива, вони так і не заберуть з ПЕОД. Не будемо захламляти ПЕОД)
      join exchangefiles f  on ef_po = po_id and ef_tp = 'rv2pd_list'
      join ikis_rbm.v_packet on pkt_id= ef_pkt and pkt_pt = 81*\
      where po_id = p_po_id
    ;

    \*  select
        l_header ||
        listagg(
          pr.pe_rbm_pkt||l_csv_delim||
          tools.get_xmlattr_clob(pc_header, 'opfu_code')||l_csv_delim||
          tools.utf8todeflang(tools.get_xmlattr_clob(pc_header, 'opfu_name'))||l_csv_delim||
          tools.get_xmlattr_clob(pc_header, 'date_cr')||l_csv_delim||
          tools.get_xmlattr_clob(pc_header, 'MFO_filia')||l_csv_delim||
          tools.get_xmlattr_clob(pc_header, 'filia_num')||l_csv_delim||
          tools.get_xmlattr_clob(pc_header, 'filia_name')||l_csv_delim||
          tools.get_xmlattr_clob(pc_header, 'full_sum')||l_csv_delim||
          tools.get_xmlattr_clob(pc_header, 'full_lines')||l_csv_delim||
          tools.get_xmlattr_clob(pc_header, 'type')||l_csv_delim||
          '0'||l_csv_delim||  -- excluded_sum
          '0'||l_csv_delim|| -- excluded_lines
          chr(10)
        )
        within group(order by pr.pe_rbm_pkt, '')
      into l_csv_clob
      from payroll_reestr  pr
      join ikis_rbm.v_packet_content pc
        on pc_pkt = pr.pe_rbm_pkt
      where pe_po  = p_po_id
      ;*\
      l_csv_clob := l_header;

      for pp in (
          select distinct  t.*
          from (
    \*         select pe_rbm_pkt,
               to_char(
                pr.pe_rbm_pkt||l_csv_delim||
                tools.get_xmlattr_clob(pc_header, 'opfu_code')||l_csv_delim||
                tools.utf8todeflang(tools.get_xmlattr_clob(pc_header, 'opfu_name'))||l_csv_delim||
                tools.get_xmlattr_clob(pc_header, 'date_cr')||l_csv_delim||
                tools.get_xmlattr_clob(pc_header, 'MFO_filia')||l_csv_delim||
                tools.get_xmlattr_clob(pc_header, 'filia_num')||l_csv_delim||
                tools.get_xmlattr_clob(pc_header, 'filia_name')||l_csv_delim||
                tools.get_xmlattr_clob(pc_header, 'full_sum')||l_csv_delim||
                tools.get_xmlattr_clob(pc_header, 'full_lines')||l_csv_delim||
                tools.get_xmlattr_clob(pc_header, 'type')||l_csv_delim||
                '0'||l_csv_delim||  -- excluded_sum
                '0'||l_csv_delim|| -- excluded_lines
                chr(10))  as p_line
            from payroll_reestr  pr
            join ikis_rbm.v_packet_content pc
              on pc_pkt = pr.pe_rbm_pkt
            where pe_po  = p_po_id*\
           select pe_rbm_pkt,
               to_char(
                pr.pe_rbm_pkt||l_csv_delim||
                \*tools.get_xmlattr_clob(pc_header, 'opfu_code')*\
                pr.com_org||l_csv_delim||
                tools.utf8todeflang(tools.get_xmlattr_clob(pc_header, 'opfu_name'))||l_csv_delim||
                tools.get_xmlattr_clob(pc_header, 'date_cr')||l_csv_delim||
                tools.get_xmlattr_clob(pc_header, 'MFO_filia')||l_csv_delim||
                tools.get_xmlattr_clob(pc_header, 'filia_num')||l_csv_delim||
                tools.utf8todeflang(tools.get_xmlattr_clob(pc_header, 'filia_name'))||l_csv_delim||
                \*tools.get_xmlattr_clob(pc_header, 'full_sum')*\
                pr_sum||l_csv_delim||
                \*tools.get_xmlattr_clob(pc_header, 'full_lines')*\
                pe_row_cnt||l_csv_delim||
                tools.get_xmlattr_clob(pc_header, 'type')||l_csv_delim||
                '0'||l_csv_delim||  -- excluded_sum
                '0'||l_csv_delim|| -- excluded_lines
                chr(10))  as p_line
            from (
              select pe_rbm_pkt, pr.com_org,
                to_char(pc_header) as pc_header,
                sum(pr_sum*100 * decode(pr_tp, 3, -1, 1) ) as pr_sum ,
                sum(pr_row_cnt) as pe_row_cnt
              from payroll_reestr  pr
              join ikis_rbm.v_packet_content pc
                on pc_pkt = pr.pe_rbm_pkt
              where pe_po  = p_po_id
              group by pe_rbm_pkt, to_char(pc_header), pr.com_org
             ) pr
            ) t
            order by pe_rbm_pkt
        )
      loop
        l_csv_clob := l_csv_clob||pp.p_line;
      end loop;

      l_files.extend;
      l_files(l_files.LAST) := ikis_sysweb.t_some_file_info(l_file_name||'.csv', tools.ConvertC2B(l_csv_clob));

      --Выходной архив
      if l_files.Count > 0 then
         p_result := ikis_sysweb.ikis_web_jutil.getZipFromStrms(l_files);
         p_fname := l_file_name||'.zip';
      else
        raise exNoData;
      end if;

    */
    EXCEPTION
        WHEN exNoPktExists
        THEN
            raise_application_error (
                -20000,
                'Реєстр по даному ПД ще не було вивантажено!');
        WHEN exNoData
        THEN
            raise_application_error (
                -20000,
                'Відсутні дані для формування вивантаження!');
        WHEN exBadPoSt
        THEN
            raise_application_error (
                -20000,
                'Створення файлів можливе тільки для ПД у стані "Проведено банком"!');
        WHEN exBadRec
        THEN
            raise_application_error (
                -20000,
                'Не вдалося однозначно визначити одержувача реєстру ПД!');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'API$ESR_EXCHANGE.GenRv2PdCsv:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;

    -- 10.  СЕРВІС «ПОВІДОМЛЕННЯ БАНКУ ПРО ПЛАТІЖНЕ ДОРУЧЕННЯ ПОВЕРНЕННЯ КОШТІВ З РАХУНКІВ ПЕНСІОНЕРІВ» (POST_PD_RETURN)
    PROCEDURE PostPDReturn (p_pkt_rec_code    IN     VARCHAR2,
                            p_pkt_name        IN     VARCHAR2,
                            p_pkt_blob        IN     BLOB,
                            p_pkt_encr_blob   IN     BLOB,
                            p_message            OUT VARCHAR2)
    IS
        l_pkt_tp           NUMBER := 83;                          -- pd_return
        l_filter           VARCHAR2 (250);
        l_ecs              exchcreatesession.ecs_id%TYPE;
        l_cnt              INTEGER;
        l_ef_header        exchangefiles.ef_header%TYPE;
        l_create_dt        DATE := SYSDATE;
        l_ef_tag           exchangefiles.ef_main_tag_name%TYPE;
        l_ef_name          exchangefiles.ef_name%TYPE;
        l_ef_data_name     exchangefiles.ef_data_name%TYPE;
        l_ef_data_tag      exchangefiles.ef_data_name%TYPE;
        l_ef_data_etag     exchangefiles.ef_data_name%TYPE;
        l_ppdr_pkt         exchangefiles.ef_pkt%TYPE;
        l_xml_data         XMLTYPE;
        l_rbm_pkt_id       NUMBER;
        l_rr_id_rbm_cnt    NUMBER;
        l_pkt_xml          CLOB;
        l_visual_clob      CLOB;
        l_rows_cnt         NUMBER;
        l_rows_sum         NUMBER;
        l_rows_minus_cnt   NUMBER;
        l_rows_minus_sum   NUMBER;
        l_rows_plus_cnt    NUMBER;
        l_rows_plus_sum    NUMBER;
        l_pd_num           VARCHAR2 (50);
        l_pd_date          DATE;
        l_pd_sum           NUMBER (19);
        l_pd_lines         NUMBER (8);
        l_err_msg          VARCHAR2 (1000);
        l_rec_tp           VARCHAR2 (10);
        l_rec_name         VARCHAR2 (1000);
        l_rec_id           NUMBER;
        l_rr_id            NUMBER;
        l_nb_ab            NUMBER;
        l_pd_dbl_cnt       NUMBER;
        exPktExists        EXCEPTION;
        exNoPktExists      EXCEPTION;
        exPktFileEmpty     EXCEPTION;
        exBadRec           EXCEPTION;
        exBadPoSt          EXCEPTION;
    BEGIN
        NULL;
    /*-- 'Розпочато формування файлів для електронного обміну - Реєстр ПД'
      l_filter := 'pkt'||'#'||l_pkt_tp||'#'\*||p_payroll_id||'#'*\||tools.hash_md5(p_pkt_blob)\*p_pkt_name*\; -- фільтр ???

      SELECT COUNT(1) INTO l_cnt FROM exchcreatesession WHERE ecs_filter = l_filter;
      IF l_cnt > 0 THEN
        raise exPktExists;
      END IF;

      INSERT INTO exchcreatesession(ecs_id, ecs_start_dt, ecs_filter)
        VALUES (0, l_create_dt, l_filter)
      RETURNING ecs_id INTO l_ecs;

      if p_pkt_blob is null or dbms_lob.getlength(p_pkt_blob) < 10 then
        raise exPktFileEmpty;
      end if;

      -- Визначаємо rr_nb_ab - Ід банку з АльфаБухгалтерії - по коду одержувача через МФО з довідника банків ППВП :

      SELECT min(ab.nb_id) into l_nb_ab
      FROM ikis_mtacc.v_ndi_bank ab
      JOIN ikis_ppvp.nsi_psb psb ON ab.nb_mfo = psb.psb_mfo
      where psb.psb_rbm_code = p_pkt_rec_code;

      if l_nb_ab is null then
        raise_application_error(-20000,  'Не вдалося визначити ідентифікатор банку в АБ');
      end if;

    \*  select max(pr.pr_bnk_code) into l_pkt_filia_code   \* pr_filia_code буває незаповнена в ВВ ППВП *\
      from payroll_reestr pr
      where pr.pe_rbm_pkt = l_pr_pkt_id;*\

      l_ef_tag := case when l_pkt_tp = 83 then 'post_pd_return'
                  end;

      l_ef_data_name := case when l_pkt_tp = 83 then 'pd_data'
                        end;

      l_ef_data_tag := '<'||l_ef_data_name||'>';
      l_ef_data_etag := '</'||l_ef_data_name||'>';

      DBMS_LOB.createTemporary(l_visual_clob , TRUE);
      DBMS_LOB.OPEN(l_visual_clob, DBMS_LOB.LOB_ReadWrite);
    \*  BEGIN
          l_pkt_xml := tools.ConvertB2C(utl_compress.lz_uncompress(p_pkt_blob));
      EXCEPTION
        WHEN OTHERS THEN
          --ikis_rbm.rdm$log_packet.insert_message(p_lp_pkt => p_rbm_pkt,  p_lp_comment => '&102#/paymentlists/pca_data#'||sqlerrm);
           raise_application_error(-20000,  'Вхідний zip-архів не є xml-структурою'\*||sqlerrm
          ||chr(10)||dbms_utility.format_error_stack||dbms_utility.format_error_backtrace*\);
      END;*\
      BEGIN
          begin
            l_pkt_xml := tools.ConvertB2C(utl_compress.lz_uncompress(p_pkt_blob));
          exception
            when others then
             l_pkt_xml := tools.ConvertB2C(tools.unZip(p_pkt_blob));
          end;
          --l_pkt_xml := tools.ConvertB2C(tools.unZip(p_pkt_blob));
          -- raise_application_error(-20000, l_pkt_xml);
      EXCEPTION
        WHEN OTHERS THEN
          if sqlcode = -20000 then
            raise;
          else
          --ikis_rbm.rdm$log_packet.insert_message(p_lp_pkt => p_rbm_pkt,  p_lp_comment => '&102#/paymentlists/pca_data#'||sqlerrm);
           raise_application_error(-20000,  'Помилка розархівування вхіднного файлу');
          end if;
      END;
      --dbms_output.put_line(l_pkt_xml) ;

      if dbms_lob.instr(upper(l_pkt_xml), 'ENCODING="UTF-8"') > 0 \*tools.checkUTF8(l_pkt_xml) = 'T'*\ then
        l_pkt_xml := tools.utf8todeflang(l_pkt_xml);
        --dbms_output.put_line('encode');
        --dbms_output.put_line(l_pkt_xml) ;
      end if;

      BEGIN
          l_xml_data := xmltype(l_pkt_xml);
      EXCEPTION
        WHEN OTHERS THEN
           raise_application_error(-20000,  'Вкладений zip-архів не є xml-структурою');
      END;

      if l_pkt_tp = 83 then -- post_pd_return
        BEGIN
          SELECT x_pd_num, to_date(x_pd_date,'ddmmyyyy'),
                 x_pd_sum, x_pd_lines
          into
                 l_pd_num, l_pd_date,
                 l_pd_sum, l_pd_lines
          FROM xmltable
              ('/post_pd_return'
               PASSING l_xml_data
               COLUMNS
                 x_pd_num   varchar2(50)   PATH 'pd_num',
                 x_pd_date  varchar2(8)    PATH 'pd_date',
                 x_pd_sum   number(19)     PATH 'pd_sum',
                 x_pd_lines number(8)      PATH 'pd_lines'
              );



          dbms_lob.append(l_visual_clob, '<h5>Повідомлення банку про платіжне доручення повернення коштів з рахунків пенсіонерів <br>'
                                               ||'№'||l_pd_num||' від '||to_char(l_pd_date,'dd.mm.yyyy') ||'</h5>'||chr(10));
          dbms_lob.append(l_visual_clob, 'Загальна сума платіжного доручення: '||l_pd_sum/100||' <br>'||chr(10));--(в копійках)
          dbms_lob.append(l_visual_clob, 'Загальна кількість рядків в файлі: '||l_pd_lines||'<br>'||chr(10));
        EXCEPTION
          WHEN OTHERS THEN
           --ikis_rbm.rdm$log_packet.insert_message(p_lp_pkt => p_rbm_pkt,  p_lp_comment => '&102#/paymentlists/#'||sqlerrm\*||sqlerrm|| dbms_utility.format_error_backtrace*\);
           raise_application_error(-20000, 'Не вдалось отимати з вхідного запиту параметри /post_pd_return/');
        END;

        select count(1) into l_pd_dbl_cnt
        from returns_reestr rr
        where rr.rr_nb_ab = l_nb_ab
          and rr.rr_pd_num = l_pd_num
          and rr.rr_st != 'ES'
        ;

        if l_pd_dbl_cnt > 0 then
          raise_application_error(-20000,  'ПД повернення коштів № '||l_pd_num||' уже завантажувалося раніше!');
        end if;

        BEGIN
          SELECT  count(1), sum(x_sum_return),
                  count(case when x_sum_return > 0 then x_rownum else null end),
                  sum(case when x_sum_return > 0 then x_sum_return  else 0 end),
                  count(case when x_sum_return <= 0 then x_rownum else null end),
                  sum(case when x_sum_return <= 0 then x_sum_return  else 0 end)
          into l_rows_cnt, l_rows_sum,
               l_rows_plus_cnt, l_rows_plus_sum,
               l_rows_minus_cnt, l_rows_minus_sum
          FROM xmltable
              ('/post_pd_return/pd_data/row'
               PASSING l_xml_data
               COLUMNS
                 x_rownum         number(7)     PATH 'rownum',
                 x_ln             varchar2(70)  PATH 'ln',
                 x_nm             varchar2(50)  PATH 'nm',
                 x_ftn            varchar2(50)  PATH 'ftn',
                 x_numident       varchar2(10)  PATH 'numident',
                 x_ser_num        varchar2(10)  PATH 'ser_num',
                 x_num_acc        varchar2(29)  PATH 'num_acc',
                 x_num_or         varchar2(12)  PATH 'num_or',
                 x_sum_return     number(19)    PATH 'sum_return',
                 x_rsn_return     varchar2(100) PATH 'rsn_return',
                 x_id_convert     number        PATH 'id_convert'
              );
        EXCEPTION
          WHEN OTHERS THEN
             raise_application_error(-20000,  'Вміст /post_pd_return/pd_data/ не відповідає формату');
        END;

        if l_rows_minus_cnt > 0 then
          raise_application_error(-20000,  'Повідомлення банку про платіжне доручення повернення коштів не може містити нульові або від''ємні суми повернення!');
        end if;

        if nvl(l_pd_lines, -1) != nvl(l_rows_cnt, -2) then
          raise_application_error(-20000,  'Кількість рядків в /post_pd_return/pd_data/ не відповідає значенню /post_pd_return/pd_lines');
        end if;

        if nvl(l_pd_sum, -1) != nvl(l_rows_sum, -2) then
          raise_application_error(-20000,  'Сума повернення в /post_pd_return/pd_data/sum_return не відповідає значенню /post_pd_return/pd_sum');
        end if;

        l_err_msg := l_err_msg||
               case when nvl(l_pd_num, 0) = 0 then '"Номер платіжного доручення повернення коштів" /post_pd_return/pd_num, ' else '' end||
               case when l_pd_date is null then '"Дата платіжного доручення повернення коштів" /post_pd_return/pd_num, ' else '' end||
               case when nvl(l_pd_sum, 0) = 0 then '"Загальна сума платіжного доручення" /post_pd_return/pd_sum, ' else '' end||
               case when nvl(l_pd_lines, 0) = 0 then '"Загальна кількість рядків в файлі" /post_pd_return/pd_lines, ' else '' end;

        if l_err_msg is not null then
          raise_application_error(-20000, 'Значення '||rtrim(l_err_msg, ', ')||' не може бути порожнім!');
        end if;


       if nvl(l_pd_date, to_date('01.01.2020','dd.mm.yyyy')) < to_date('01.04.2021','dd.mm.yyyy') then
         raise_application_error(-20000, 'Некоректна "Дата платіжного доручення повернення коштів" /post_pd_return/pd_num = ' ||
                      to_char(l_pd_date, 'dd.mm.yyyy'));
       end if;
      --dbms_output.put_line(l_visual_clob);

      end if;


      select max(r.rec_tp), max(r.rec_name), max(r.rec_id) into l_rec_tp, l_rec_name, l_rec_id
      from ikis_rbm.v_recipient r
      where r.rec_code = p_pkt_rec_code;

      if nvl(l_rec_tp, 'z') != 'CMES' and p_pkt_rec_code != 'TESTBANK1' then
        raise_application_error(-20000, 'Одержувач '||l_rec_name||' не може завантажувати "Повідомлення банку про платіжне доручення повернення коштів з рахунків пенсіонерів"(post_pd_return) через кабінет банка!');
      end if;


      -- вичитати з l_xml_data
      select (deleteXML(l_xml_data, '/post_pd_return/pd_data')).extract( '/post_pd_return/*' ).getclobVal()
      into l_ef_header
      from dual;

      l_ef_name := case when l_pkt_tp = 83 then 'PPDR_'||l_pd_num||'_'||to_char(l_pd_date, 'ddmmyyyy')   -- PPDR_<pd_num>_<pd_date>
                   end;

      INSERT INTO exchangefiles (ef_id, ef_po, com_wu, com_org, ef_tp, ef_name, ef_data, ef_visual_data, ef_header,
                                 ef_main_tag_name, ef_data_name, ef_ecp_list_name, ef_ecp_name, ef_ecp_alg,
                                 ef_st, ef_dt, ef_ident_data, ef_ecs, ef_rec, ef_file_idn, ef_ef,
                                 ef_pkt, ef_file_name, ef_encr_blob)
      select
         null, null, null, 28000, 'F' as ef_tp,
         l_ef_name as ef_name,
         p_pkt_blob as ef_data,
         l_visual_clob as ef_visual_data,
         l_ef_header as ef_header,
         l_ef_tag, 'file_data', 'ecp_list', 'ecp', 'MD',
         'Z', l_create_dt, 'ФС:', l_ecs, l_rec_id, null, null,
         null, p_pkt_name, p_pkt_encr_blob
      from  dual;

      -- створюємо пакет в ПЕОД
      INSERT INTO ikis_rbm.tmp_exchangefiles_m3(ef_id, ef_po, com_wu, com_org, ef_tp, ef_name, ef_data,
                                       ef_visual_data, ef_header, ef_main_tag_name, ef_data_name,
                                       ef_ecp_list_name, ef_ecp_name, ef_ecp_alg, ef_st,
                                       ef_dt, ef_ident_data, ef_ecs, ef_rec, ef_pkt, ef_encr_blob)
        SELECT ef_id, ef_po, com_wu, com_org, ef_tp, ef_name, ef_data,
               ef_visual_data , ef_header, ef_main_tag_name, ef_data_name,
               ef_ecp_list_name, ef_ecp_name, ef_ecp_alg, ef_st, ef_dt,
               ef_ident_data, ef_ecs, ef_rec, ef_pkt, p_pkt_encr_blob
        FROM exchangefiles
        WHERE ef_ecs = l_ecs;

      ikis_rbm.ikis_rbm_finzvit.GenPaketsFromTMPTable;

        -- витягуємо ід створеного пакета
      update exchangefiles f
      set f.ef_pkt = (select t.ef_pkt from ikis_rbm.tmp_exchangefiles_m3 t where t.ef_id = f.ef_id)
      where ef_ecs = l_ecs
        and f.ef_file_name = p_pkt_name
      returning ef_pkt into l_ppdr_pkt;

      select count(1) into l_rr_id_rbm_cnt
      from returns_reestr
      where rr_id_rbm = l_ppdr_pkt;

      if l_rr_id_rbm_cnt > 0 then
        raise_application_error(-20000, 'Помилка завантаження: повідомлення уже додано до реєстру');
      end if;

      -- реєструємо повідомлення
      --  #69456 окремі реєстри для додатних та від'ємних сум:
      if l_rows_plus_cnt > 0 then
        insert into returns_reestr(rr_id, rr_tp, rr_pd_num, rr_pd_date, rr_pd_sum, rr_pd_lines, rr_po, rr_st, rr_nb_ab, rr_id_rbm,
                                                rr_create_dt, rr_org)
        values(null, 'R', l_pd_num, l_pd_date, \*l_pd_sum*\l_rows_plus_sum / 100, \*l_pd_lines*\l_rows_plus_cnt, null, 'L', l_nb_ab,l_ppdr_pkt, sysdate, null)
        returning rr_id into l_rr_id;

        insert into rr_list(rrl_id, rrl_rr, rrl_num, rrl_ln, rrl_fn, rrl_ftn, rrl_numident, rrl_ser_num,
                        rrl_num_acc, rrl_num_or, rrl_sum_return, rrl_rsn_return, rrl_id_convert, rrl_po,
                        rrl_st, rrl_pnf_ppvp, rrl_pnf_dkg,
                        rrl_create_dt, rrl_pd_num, rrl_pd_date, rrl_nb_ab, rrl_org, rrl_num_list
                        )
        SELECT  null, l_rr_id, x_rownum, x_ln, x_nm, x_ftn, x_numident, x_ser_num,
                x_num_acc, x_num_or, x_sum_return / 100, x_rsn_return, x_id_convert, null,
                'L', null, null,
                sysdate, l_pd_num, l_pd_date,  l_nb_ab, null, null
            FROM xmltable
                ('/post_pd_return/pd_data/row'
                 PASSING l_xml_data
                 COLUMNS
                   x_rownum         number(7)     PATH 'rownum',
                   x_ln             varchar2(70)  PATH 'ln',
                   x_nm             varchar2(50)  PATH 'nm',
                   x_ftn            varchar2(50)  PATH 'ftn',
                   x_numident       varchar2(10)  PATH 'numident',
                   x_ser_num        varchar2(10)  PATH 'ser_num',
                   x_num_acc        varchar2(29)  PATH 'num_acc',
                   x_num_or         varchar2(12)  PATH 'num_or',
                   x_sum_return     number(19)    PATH 'sum_return',
                   x_rsn_return     varchar2(100) PATH 'rsn_return',
                   x_id_convert     number        PATH 'id_convert'
                )
        where x_sum_return > 0;
       --- p_message := 'Формування пакетів завершено.';
         -- Прив'язка ПД повернення до записів реєстру повернень
        SetReturnReestrPo(l_rr_id);
      end if;
      \*
      if l_rows_minus_cnt > 0 then
        insert into returns_reestr(rr_id, rr_tp, rr_pd_num, rr_pd_date, rr_pd_sum, rr_pd_lines, rr_po, rr_st, rr_nb_ab, rr_id_rbm,
                                                rr_create_dt, rr_org)
        values(null, 'R', l_pd_num, l_pd_date, \*l_pd_sum*\l_rows_minus_sum / 100, \*l_pd_lines*\l_rows_minus_cnt, null, 'ES', l_nb_ab,l_ppdr_pkt, sysdate, null)
        returning rr_id into l_rr_id;

        insert into rr_list(rrl_id, rrl_rr, rrl_num, rrl_ln, rrl_fn, rrl_ftn, rrl_numident, rrl_ser_num,
                        rrl_num_acc, rrl_num_or, rrl_sum_return, rrl_rsn_return, rrl_id_convert, rrl_po,
                        rrl_st, rrl_pnf_ppvp, rrl_pnf_dkg,
                        rrl_create_dt, rrl_pd_num, rrl_pd_date, rrl_nb_ab, rrl_org, rrl_num_list
                        )
        SELECT  null, l_rr_id, x_rownum, x_ln, x_nm, x_ftn, x_numident, x_ser_num,
                x_num_acc, x_num_or, x_sum_return / 100, x_rsn_return, x_id_convert, null,
                'L', null, null,
                sysdate, l_pd_num, l_pd_date,  l_nb_ab, null, null
            FROM xmltable
                ('/post_pd_return/pd_data/row'
                 PASSING l_xml_data
                 COLUMNS
                   x_rownum         number(7)     PATH 'rownum',
                   x_ln             varchar2(70)  PATH 'ln',
                   x_nm             varchar2(50)  PATH 'nm',
                   x_ftn            varchar2(50)  PATH 'ftn',
                   x_numident       varchar2(10)  PATH 'numident',
                   x_ser_num        varchar2(10)  PATH 'ser_num',
                   x_num_acc        varchar2(29)  PATH 'num_acc',
                   x_num_or         varchar2(12)  PATH 'num_or',
                   x_sum_return     number(19)    PATH 'sum_return',
                   x_rsn_return     varchar2(100) PATH 'rsn_return',
                   x_id_convert     number        PATH 'id_convert'
                )
          where x_sum_return <= 0;
       --- p_message := 'Формування пакетів завершено.';
         -- Прив'язка ПД повернення до записів реєстру повернень
        SetReturnReestrPo(l_rr_id);
      end if;*\*/

    EXCEPTION
        WHEN exNoPktExists
        THEN --raise_application_error(-20000, 'Пакет ід = '||l_rbm_pkt_id||' не знайдено в ПЕОД!');
            p_message :=
                'Пакет ід = ' || l_rbm_pkt_id || ' не знайдено в ПЕОД!';
        WHEN exPktExists
        THEN --raise_application_error(-20000, 'Створення файлів з даними параметрами вже виконувалось!');
            p_message :=
                'Завантаження файлів з даними параметрами вже виконувалось!';
        WHEN exPktFileEmpty
        THEN     --raise_application_error(-20000, 'Вкладено порожній файл!');
            p_message := 'Вкладено порожній файл!';
        WHEN exBadPoSt
        THEN --raise_application_error(-20000, 'Створення файлів можливе тільки для ПД у стані "Проведено банком"!');
            p_message :=
                'Створення файлів можливе тільки для ПД у стані "Проведено банком"!';
        WHEN exBadRec
        THEN --raise_application_error(-20000, 'Не вдалося однозначно визначити одержувача реєстру ПД!');
            p_message :=
                'Не вдалося однозначно визначити одержувача реєстру ПД!';
        WHEN OTHERS
        THEN --raise_application_error(-20000, 'API$ESR_EXCHANGE.GenRv2PdPackets:'||chr(10)||replace(DBMS_UTILITY.FORMAT_ERROR_STACK||' => '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,'ORA-20000:')||chr(10)||sqlerrm);
            IF INSTR (SQLERRM, 'ORA-20000') > 0
            THEN
                p_message := REPLACE (SQLERRM, 'ORA-20000:', '');
            ELSE
                raise_application_error (
                    -20000,
                       'API$ESR_EXCHANGE.PostPDReturn:'
                    || CHR (10)
                    || REPLACE (
                              DBMS_UTILITY.FORMAT_ERROR_STACK
                           || ' => '
                           || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                           'ORA-20000:')
                    || CHR (10)
                    || SQLERRM);
            END IF;
    END;

    -- info:  67730 Обробка невиплат КВ-2
    -- params: p_pkt_rec_code  – Код запитувача ПЕОД
    --         p_pkt_id        - Ід пакета ПЕОД
    --         p_pkt_xml       - xml-вміст блоку "report_data" КВ-2
    PROCEDURE ProcPPRReturn (p_pkt_rec_code   IN VARCHAR2,
                             p_pkt_id         IN NUMBER,
                             p_pkt_xml        IN XMLTYPE)
    IS
        l_rr_id        NUMBER;
        l_nb_ab        NUMBER;
        l_org          NUMBER;
        l_pd_dbl_cnt   NUMBER;
        l_create_dt    DATE;
    BEGIN
        NULL;
    /*SELECT min(ab.nb_id) into l_nb_ab
      FROM ikis_mtacc.v_ndi_bank ab
      JOIN ikis_ppvp.nsi_psb psb ON ab.nb_mfo = psb.psb_mfo
      WHERE psb.psb_rbm_code = p_pkt_rec_code
      ;

      if l_nb_ab is null then
        raise_application_error(-20000,  'Не вдалося визначити ідентифікатор банку в АБ');
      end if;

      --dbms_output.put_line('l_nb_ab='||l_nb_ab);
      --dbms_output.put_line('p_pkt_xml='||p_pkt_xml.getStringVal());

      select count(1) into l_pd_dbl_cnt
      from returns_reestr rr
      where rr.rr_id_rbm = p_pkt_id
      ;

      if l_pd_dbl_cnt > 0 then
        ---  записати в ЛОГ
        ikis_rbm.rdm$log_packet.insert_message(p_lp_pkt => p_pkt_id, p_lp_comment => 'Спроба повторного опрацювання невиплат КВ-2');
        return;
        --raise_application_error(-20000,  'ПД повернення коштів № '||l_pd_num||' уже завантажувалося раніше!');
      end if;

      select pkt_org, pkt_create_dt
      into l_org, l_create_dt
      from ikis_rbm.v_packet
      where pkt_id = p_pkt_id;

      for rr in (
        SELECT  x_num_return, x_date_return,
                case when x_sum_pay <= 0 then -1 else 1 end as x_sum_tp,
                sum(x_sum_pay) as x_sum, count(1) as x_cnt
        FROM xmltable
                  ('/declar/declarbody/row'
                   PASSING p_pkt_xml
                   COLUMNS
                      x_rownum NUMBER(7) PATH 'rownum',
                      x_id_convert  varchar2(10) PATH 'id_convert',
                      x_num_list  Number(10) PATH 'num_list', --  який було вказано в конверті GET_CONVERT_ANSWER
                      x_ln  varchar2(70)     PATH 'ln',
                      x_nm  varchar2(50)     PATH 'nm',
                      x_ftn varchar2(50)     PATH 'ftn',
                      x_numident  varchar2(10) PATH 'numident', --«Ні» - заповнюються поле «серія та номер паспорту»  для фізичних осіб, які мають відмітку в паспорті про право здійснювати будь-які платежі за серією та номером паспорта
                      x_ser_num varchar2(10)   PATH 'ser_num',  --для старого зразка: між «серія» та «номер» проставляється пробіл, «Серія паспорту» -  обов’язково великі та кириличні букви;
                      x_num_acc varchar2(29)   PATH 'num_acc',
                      x_num_or  varchar2(12) PATH 'num_or', -- -- #66437 поле перейменовано в num_or   #63657  Номер особового рахунку/пенсійної справи
                      x_date_enr  varchar2(8)  PATH 'date_enr',-- в форматі ddmmyyyy
                      x_sum_pay Number(19)     PATH 'sum_pay', -- в копійках
                      x_result  Number(2)      PATH 'result',
                      x_date_return varchar2(8) PATH 'date_return', --  в форматі ddmmyyyy, обов’язкове заповнення у разі проставлення кодів результату опрацювання  3, 4 та 5
                      x_num_return  varchar2(10)  PATH 'num_return' --  обов’язкове заповнення у разі проставлення кодів результату опрацювання  3, 4 та 5
                  )
        where x_result != 0
          and not exists (
                    select 1
                    from returns_reestr r
                    join rr_list rrl on rrl_rr= rr_id
                    where 1=1
                      and nvl(rrl.rrl_numident, 'n/a') = nvl(x_numident, 'n/a')
                      and rrl.rrl_num_acc = x_num_acc
                      and rrl.rrl_id_convert = x_id_convert
                      and rrl.rrl_num_list = x_num_list
                      and r.rr_st != 'ES'
                      --and r.rr_pd_num = x_num_return
                      --and r.rr_pd_date = to_Date(x_date_return, 'ddmmyyyy')
                      --and rrl.rrl_sum_return = x_sum_pay / 100
                      )
        group by x_num_return, x_date_return,
           case when x_sum_pay <= 0 then -1 else 1 end
        )
      loop
        --dbms_output.put_line(' rr.x_num_return='|| rr.x_num_return);
        -- реєструємо
        insert into returns_reestr(rr_id, rr_tp, rr_pd_num, rr_pd_date, rr_pd_sum, rr_pd_lines, rr_po, rr_st, rr_nb_ab, rr_id_rbm,
                                                rr_create_dt, rr_org)
        values(null, 'K', rr.x_num_return, to_Date(rr.x_date_return, 'ddmmyyyy'), rr.x_sum / 100, rr.x_cnt, null,
               case when rr.x_sum_tp = 1 then 'L' else 'ES' end,
               l_nb_ab, p_pkt_id,
               l_create_dt, l_org)
        returning rr_id into l_rr_id;

        insert into rr_list(rrl_id, rrl_rr, rrl_num, rrl_ln, rrl_fn, rrl_ftn, rrl_numident, rrl_ser_num,
                        rrl_num_acc, rrl_num_or, rrl_sum_return, rrl_rsn_return, rrl_id_convert, rrl_po,
                        rrl_st, rrl_pnf_ppvp, rrl_pnf_dkg,
                        rrl_create_dt, rrl_pd_num, rrl_pd_date, rrl_nb_ab, rrl_org, rrl_num_list)
        SELECT  null, l_rr_id, x_rownum, x_ln, x_nm, x_ftn, x_numident,
                nvl(x_ser_num, 'N\A') as x_ser_num,
                x_num_acc,
                nvl(x_num_or, 'N\A') as x_num_or, x_sum_pay / 100 , x_result, x_id_convert, null,
                'L', null, null,
                l_create_dt, rr.x_num_return, to_Date(rr.x_date_return, 'ddmmyyyy'), l_nb_ab, l_org, x_num_list
        FROM xmltable
                ('/declar/declarbody/row'
                 PASSING p_pkt_xml
                 COLUMNS
                    x_rownum NUMBER(7) PATH 'rownum',
                    x_id_convert  varchar2(10) PATH 'id_convert',
                    x_num_list  Number(10) PATH 'num_list', --  який було вказано в конверті GET_CONVERT_ANSWER
                    x_ln  varchar2(70)     PATH 'ln',
                    x_nm  varchar2(50)     PATH 'nm',
                    x_ftn varchar2(50)     PATH 'ftn',
                    x_numident  varchar2(10) PATH 'numident', --«Ні» - заповнюються поле «серія та номер паспорту»  для фізичних осіб, які мають відмітку в паспорті про право здійснювати будь-які платежі за серією та номером паспорта
                    x_ser_num varchar2(10)   PATH 'ser_num',  --для старого зразка: між «серія» та «номер» проставляється пробіл, «Серія паспорту» -  обов’язково великі та кириличні букви;
                    x_num_acc varchar2(29)   PATH 'num_acc',
                    x_num_or  varchar2(12) PATH 'num_or', -- -- #66437 поле перейменовано в num_or   #63657  Номер особового рахунку/пенсійної справи
                    x_date_enr  varchar2(8)  PATH 'date_enr',-- в форматі ddmmyyyy
                    x_sum_pay Number(19)     PATH 'sum_pay', -- в копійках
                    x_result  Number(2)      PATH 'result',
                    x_date_return varchar2(8) PATH 'date_return', --  в форматі ddmmyyyy, обов’язкове заповнення у разі проставлення кодів результату опрацювання  3, 4 та 5
                    x_num_return  varchar2(50)  PATH 'num_return' --  обов’язкове заповнення у разі проставлення кодів результату опрацювання  3, 4 та 5
                ) xx
        where xx.x_result != 0
          and nvl(xx.x_num_return, 'NoNe') = nvl(rr.x_num_return, 'NoNe')
          and nvl(xx.x_date_return, 'NoNe') = nvl(rr.x_date_return, 'NoNe')
          and case when xx.x_sum_pay <= 0 then -1 else 1 end =  rr.x_sum_tp
          and not exists (
                    select 1
                    from returns_reestr r
                    join rr_list rrl on rrl_rr= rr_id
                    where 1=1
                      and nvl(rrl.rrl_numident, 'n/a') = nvl(x_numident, 'n/a')
                      and rrl.rrl_num_acc = x_num_acc
                      and rrl.rrl_id_convert = x_id_convert
                      and rrl.rrl_num_list = x_num_list
                      and r.rr_st != 'ES'
                      --and r.rr_pd_num = x_num_return
                      --and r.rr_pd_date = to_Date(x_date_return, 'ddmmyyyy')
                      --and rrl.rrl_sum_return = x_sum_pay / 100
                      )
          ;

         -- Прив'язка ПД повернення до записів реєстру повернень
         if l_rr_id > 0 and rr.x_num_return is not null and rr.x_sum_tp = 1 then
           SetReturnReestrPo(l_rr_id);
         end if;
      end loop;

    */
    EXCEPTION
        WHEN OTHERS
        THEN
            --null;
            raise_application_error (
                -20000,
                   'ProcPPRReturn:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;

    -- info: Задача #67447 Фіксація дати та статусу опрацювання ресєстру
    -- params: p_pkt_id        - Ід пакета ПЕОД
    PROCEDURE SetPoBankGetDt (p_pkt_id IN NUMBER)
    IS
    BEGIN
        NULL;
    /*    update pay_order po
        set po.po_bank_get_dt = sysdate
        where exists (
           select 1 from exchangefiles f
           where ef_po = po.po_id
             and ef_tp = 'rv2pd_list'
             and ef_pkt = p_pkt_id
             );*/
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'API$ESR_EXCHANGE.SetPoBankGetDt:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;

    --Задача #68327 Пошук ПД при завантаженні реєстрів повернення / КВ-2
    PROCEDURE SetReturnReestrPo (p_rr_id IN NUMBER DEFAULT NULL)
    IS
        l_po_cnt       NUMBER;
        l_hs           NUMBER;
        l_rr_sum       NUMBER;
        l_com_org      NUMBER;
        l_pnf_id       NUMBER;
        l_ab_nb_id     NUMBER;
        l_rr_tp        VARCHAR2 (10);
        l_bank_name    VARCHAR2 (250);
        l_rr_pd_num    VARCHAR2 (50);
        l_rr_nb_ab     NUMBER;
        l_rr_pd_sum    NUMBER;
        l_po_rr_sum    NUMBER;
        l_rr_pd_date   DATE;
    BEGIN
        NULL;
    /*
      select count(rr_po), max(rr_pd_sum), max(rr_pd_date), max(rr_nb_ab), max(rr_pd_num)
      into l_po_cnt, l_rr_pd_sum, l_rr_pd_date, l_rr_nb_ab, l_rr_pd_num
      from returns_reestr rr
      where rr_id = p_rr_id
        \*and rr_po > 0*\;

      if l_po_cnt > 0 then
        return;
      end if;

      select sum(r2.rr_pd_sum) into l_po_rr_sum
      from  returns_reestr r2
      where 1=1
        -- and r2.rr_pd_sum = l_rr_pd_sum
        and r2.rr_pd_num = l_rr_pd_num
        and r2.rr_pd_date = l_rr_pd_date
        and r2.rr_nb_ab = l_rr_nb_ab
        and r2.rr_st != 'ES'
        and r2.rr_po > 0;

        update returns_reestr rr
        set (rr.rr_po, rr.rr_st, rr.rr_src) = (
                  select
                    --po.po_id,
                    case when rr.rr_pd_sum + nvl(l_po_rr_sum, 0) > po.po_sum then null
                         else po.po_id
                    end,
                    case when rr.rr_pd_sum + nvl(l_po_rr_sum, 0) > po.po_sum then 'ES' -- Помилка суми - сума по реєстру не може перевищувати суму ПД повернення
                         else 'F'
                    end,
                    'A'
                  from pay_order po,
                   --returns_reestr rr,
                   ikis_mtacc.v_ndi_bank b
                  where po.po_src = 'AB'
                    and po.po_udd_ab > 0 -- id пд повернення в аБ
                    and rr.rr_nb_ab = b.nb_id
                    and rr.rr_pd_num = po.po_number
                    and rr.rr_pd_date = po.po_date_pay
                    and po.po_bank_mfo_src = b.nb_mfo
                      )
        where (rr_id = p_rr_id
               or p_rr_id is null
                 and rr.rr_create_dt >= trunc(sysdate) - 7)
         and rr_po is null
         and exists (
            select 1
            from pay_order po,
             ikis_mtacc.v_ndi_bank b
            where po.po_src = 'AB'
              and po.po_udd_ab > 0 -- id пд повернення в аБ
              and rr.rr_nb_ab = b.nb_id
              and rr.rr_pd_num = po.po_number
              and rr.rr_pd_date = po.po_date_pay
              and po.po_bank_mfo_src = b.nb_mfo
               )
          returning rr.rr_pd_sum, rr.rr_tp, rr.rr_nb_ab
          into l_rr_sum, l_rr_tp, l_ab_nb_id;

    \*   if  sql%rowcount > 0 then
         l_hs := TOOLS.GetHistSession;
       end if;*\
    \*
      --при связывании реестров нужно обновлять поле "po_rest_sum"
      --po_rest_sum = po_rest_sum - сумма реестра
      --т.е. таким образом получили нераспределнный остаток
      update pay_order po
      set po.po_rest_sum = nvl(po.po_rest_sum, 0)
                            + (select rr.rr_pd_sum
                              from returns_reestr rr
                              where rr.rr_po = po.po_id
                                and rr_id = p_rr_id)
      where exists (select rr.rr_pd_sum
                    from returns_reestr rr
                    where rr.rr_po = po.po_id
                      and rr_id = p_rr_id);*\

        update rr_list rrl
        set (rrl.rrl_po, \*rrl.rrl_hs_ins,*\ rrl.rrl_src, rrl.rrl_st)
             = (select rr.rr_po, \*l_hs,*\ 'A', --  A - автоматично системою
                       'F' -- знайдено ПД
                from returns_reestr rr
                where rr.rr_po is not null
                  and rr.rr_id = rrl.rrl_rr
                  and rr.rr_st = 'F'
                  and (rr_id = p_rr_id
                       or p_rr_id is null
                         and rr.rr_create_dt >= trunc(sysdate) - 7)
                   )
        where (rrl_rr = p_rr_id
               or p_rr_id is null
                 \*and rrl.rr >= trunc(sysdate) - 7*\)
         and rrl_po is null
         and exists (
            select 1
            from returns_reestr rr
            where rr.rr_po is not null
              and rr.rr_id = rrl.rrl_rr
              and rr.rr_st = 'F' -- Якщо помилка суми для реэстру (перевищено) тоді реэстр встановити в статус "Помилка суми" а до ПД не прив'язувати
              and (rr_id = p_rr_id
                   or p_rr_id is null
                     and rr.rr_create_dt >= trunc(sysdate) - 7)
               );
       -- ІД ПД в списках оновлено
       --Якщо при цьому усі деталі встановлені в статус "F", то статус реєстру встановити в "F"
       update returns_reestr r
       set r.rr_st = 'F'
       where r.rr_st in ('L')
         and r.rr_id = p_rr_id
         and exists (
             select 1 from rr_list rrl
             where rrl_rr = rr_id
             having count(1) = count(case when rrl_st = 'F' then rrl_id else null end)
              );


     \*
      p_ppr_ref_tp a. Тип повернення
      p_ppr_lname  b. Прізвище
      p_ppr_name   c. Ім’я
      p_ppr_father d. По батькові
      p_ppr_idcode e. РНОКПП
      p_ppr_pasp   f. Серія та номер паспорту
      p_ppr_bank_num  g.  Номер банківського рахунку пенсіонера
      p_ppr_org_code  h.  Код УСПЗН
      p_ppr_ls_number i.  Номер особового рахунку пенсіонера
      p_ppr_pkt       j.  Ідентифікатор конверту з відомостями
      p_ppr_sum       k.  Сума повернення
      p_ppr_reason    l.  Причина повернення
      p_ppr_bank_name m.  Назва банку
      p_ppr_pd_num    n.  Номер ПД банку
      p_ppr_pd_date   o.  Дата ПД банку
      p_ppr_pd_sum    p.  Сума ПД банку
      p_ppr_rrl       q.  ІД рядку реєстру в ФЗ / a.  ІД рядку реєстру в ФЗ
      p_com_org       b.  код УСПЗН
      p_pnf_id        c.  ІД особового рахунку пенсіонера
      *\
       if \*sql%rowcount > 0 and*\ p_rr_id > 0 then
          GetRrlPnfPpvp(p_rr_id);
       end if;

    */
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'API$ESR_EXCHANGE.SetReturnReestrPo:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;

    -- Задача #68510 Ідентифікація пенсіонера в ППВП
    PROCEDURE GetRrlPnfPpvp (p_rr_id IN NUMBER)
    IS
        l_po_cnt       NUMBER;
        l_hs           NUMBER;
        l_rr_sum       NUMBER;
        l_com_org      NUMBER;
        l_pnf_id       NUMBER;
        l_ab_nb_id     NUMBER;
        l_rr_tp        VARCHAR2 (10);
        l_pnf_number   VARCHAR2 (100);
        --l_bank_name  varchar2(250);
        l_bank_mfo     pay_order.po_bank_mfo_src%TYPE;
    BEGIN
        NULL;
    /*\*
     p_ppr_ref_tp a. Тип повернення
     p_ppr_lname  b. Прізвище
     p_ppr_name   c. Ім’я
     p_ppr_father d. По батькові
     p_ppr_idcode e. РНОКПП
     p_ppr_pasp   f. Серія та номер паспорту
     p_ppr_bank_num  g.  Номер банківського рахунку пенсіонера
     p_ppr_org_code  h.  Код УСПЗН
     p_ppr_ls_number i.  Номер особового рахунку пенсіонера
     p_ppr_pkt       j.  Ідентифікатор конверту з відомостями
     p_ppr_sum       k.  Сума повернення
     p_ppr_reason    l.  Причина повернення
     p_ppr_bank_name m.  Назва банку
     p_ppr_pd_num    n.  Номер ПД банку
     p_ppr_pd_date   o.  Дата ПД банку
     p_ppr_pd_sum    p.  Сума ПД банку
     p_ppr_rrl       q.  ІД рядку реєстру в ФЗ / a.  ІД рядку реєстру в ФЗ
     p_com_org       b.  код УСПЗН
     p_pnf_id        c.  ІД особового рахунку пенсіонера
     *\

   \*  Улучшение #69034 передача МФО в ППВП   в АПИ вместо названия банка передавать МФО
      select b.nb_name, rr_tp, rr_pd_sum into l_bank_name, l_rr_tp, l_rr_sum
      from returns_reestr r, ikis_mtacc.v_ndi_bank b
      where b.nb_id = r.rr_nb_ab
        and r.rr_id = p_rr_id
      ;*\
      begin
        select po.po_bank_mfo_src, rr_tp, rr_pd_sum into l_bank_mfo, l_rr_tp, l_rr_sum
        from returns_reestr r, pay_order po
        where r.rr_po = po_id
          and r.rr_id = p_rr_id;
       exception
         when no_data_found then
           return;
       end;

      for rrl in (
         select r.*,
           po.po_bank_mfo_src,  -- 20210528
           po.po_number,
           po.po_date_pay,
           po.po_sum
         from rr_list r
         join pay_order po on rrl_po = po_id
         where rrl_rr = p_rr_id
           and r.rrl_po > 0
           and r.rrl_pnf_ppvp is null
           and r.rrl_pnf_dkg is null
      ) loop
         l_com_org := null;
         l_pnf_id  := null;
         l_pnf_number := null;

         -- 20210714 про всяк випадок чистимо попередні результати пошуку в ППВП
         begin
           ikis_ppvp.DeleteReturnExternal(p_rrl_id => rrl.rrl_id);
         exception
           when others then
             null;
         end;

         ikis_ppvp.SaveReturnExternal(
                              p_ppr_ref_tp => l_rr_tp,
                              p_ppr_lname => rrl.rrl_ln,
                              p_ppr_name => rrl.rrl_fn,
                              p_ppr_father => rrl.rrl_ftn,
                              p_ppr_idcode => rrl.rrl_numident,
                              p_ppr_pasp => rrl.rrl_ser_num,
                              p_ppr_bank_num => rrl.rrl_num_acc,
                              p_ppr_org_code => rrl.rrl_org,
                              p_ppr_ls_number => rrl.rrl_num_or,
                              p_ppr_pkt => rrl.rrl_id_convert,
                              p_ppr_sum => rrl.rrl_sum_return,
                              p_ppr_reason => rrl.rrl_rsn_return,
                              p_ppr_bank_name => rrl.po_bank_mfo_src\*l_bank_mfo*\,-- l_bank_name Улучшение #69034 передача МФО в ППВП   в АПИ вместо названия банка передавать МФО
                              p_ppr_pd_num => rrl.po_number\*rrl.rrl_pd_num*\,
                              p_ppr_pd_date => rrl.po_date_pay\*rrl.rrl_pd_date*\,
                              p_ppr_pd_sum => rrl.po_sum\*l_rr_sum*\,
                              p_ppr_rrl => rrl.rrl_id,
                              p_com_org => l_com_org,
                              p_pnf_id => l_pnf_id,
                              p_pnf_number => l_pnf_number);

         if l_pnf_id > 0 then
           update rr_list r
           set r.rrl_pnf_ppvp = l_pnf_id,
               r.rrl_org = l_com_org,
               r.rrl_st = 'P', --Якщо в деталі реєстрів записується ІД особового рахунку, який повернуто від ППВП, то статус деталі встановлювати в "Р"
               r.rrl_num_or = nvl(l_pnf_number, r.rrl_num_or)
           where r.rrl_id = rrl.rrl_id;
         end if;
       end loop;

   --Якщо при цьому усі деталі встановлені в статус "Р", то статус реєстру встановити в "Р"
      update returns_reestr r
      set r.rr_st = 'P'
      where 1=1---20210714 r.rr_st in ('F')
        and exists (
            select 1 from rr_list rrl
            where rrl_rr = rr_id
            having count(1) = count(case when rrl_st = 'P' then rrl_id else null end)
             );

   */
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'API$ESR_EXCHANGE.GetRrlPnfPpvp:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;


    --Задача #68565  Функція пошуку Реєстрів повернень та ідентифікація в ППВП
    PROCEDURE SetPoReturnReestr (p_po_id IN NUMBER)
    IS
        l_po_cnt      NUMBER;
        l_hs          NUMBER;
        l_rr_sum      NUMBER;
        l_com_org     NUMBER;
        l_pnf_id      NUMBER;
        l_ab_nb_id    NUMBER;
        l_rr_tp       VARCHAR2 (10);
        l_rr_st       VARCHAR2 (10);
        l_bank_name   VARCHAR2 (250);
        l_po_row      pay_order%ROWTYPE;
        l_po_rr_sum   NUMBER;
    BEGIN
        NULL;
    /*\*  контролі ???
      select count(1) into l_po_cnt
      from returns_reestr rr
      where rr_id = p_rr_id
        and rr_po > 0;

      if l_po_cnt > 0 then
        return;
      end if;*\

     begin
        select *
        into l_po_row
        from pay_order po
        where po.po_src = 'AB'
          and po.po_udd_ab > 0 -- id пд повернення в аБ
          and po.po_id = p_po_id;

     --   dbms_output.put_line(l_po_row.po_id||'-'||l_po_row.po_sum);

        select nb_id into l_ab_nb_id
        from ikis_mtacc.v_ndi_bank b
        where b.nb_mfo = l_po_row.po_bank_mfo_src;


       -- dbms_output.put_line(l_po_row.po_bank_mfo_src||'- l_ab_nb_id='||l_ab_nb_id);

     exception
       when no_data_found then return;
       when others then return;
     end;

     -- перебираємо записи реєстру в порядку створення
     -- якщо отримуємо перевищення суми - Помилка суми
     --if  sql%rowcount > 0 then
       l_hs := TOOLS.GetHistSession;
     --end if;

     for rr in (select * from  returns_reestr rr
                where rr.rr_nb_ab = l_ab_nb_id
                  and rr.rr_pd_num = l_po_row.po_number
                  and rr.rr_pd_date = l_po_row.po_date_pay
                  and rr.rr_po is null
                 order by rr.rr_create_dt
              )
      loop
        l_rr_st := null;
        dbms_output.put_line(rr.rr_id||'-'||rr.rr_pd_sum);
        select sum(r2.rr_pd_sum) into l_po_rr_sum
        from  returns_reestr r2
        where r2.rr_po = p_po_id
          and r2.rr_st != 'ES';

       -- dbms_output.put_line('l_po_rr_sum='||l_po_rr_sum);

        update returns_reestr r3
        set r3.rr_po = case when rr.rr_pd_sum + nvl(l_po_rr_sum, 0) > l_po_row.po_sum then null
                            else l_po_row.po_id
                       end,
            r3.rr_st = case when rr.rr_pd_sum + nvl(l_po_rr_sum, 0) > l_po_row.po_sum then 'ES' -- Помилка суми - сума по реєстру не може перевищувати суму ПД повернення
                            else 'F'
                       end,
            r3.rr_src = 'H'
        where r3.rr_id = rr.rr_id
          and rr_po is null
          returning r3.rr_pd_sum, r3.rr_tp, r3.rr_nb_ab, r3.rr_st
          into l_rr_sum, l_rr_tp, l_ab_nb_id, l_rr_st;

        update rr_list rrl
        set (rrl.rrl_po, rrl.rrl_hs_ins, rrl.rrl_src, rrl.rrl_st)
             = (select r2.rr_po, l_hs, 'H', --  A - автоматично системою
                       'F' -- знайдено ПД
                from returns_reestr r2
                where r2.rr_po is not null
                  and r2.rr_id = rrl.rrl_rr
                  and r2.rr_st = 'F'
                  and rr_id = r2.rr_id)
        where rrl_rr =  rr.rr_id
         and rrl_po is null
         and l_rr_st = 'F';
       -- ІД ПД в списках оновлено
       --Якщо при цьому усі деталі встановлені в статус "F", то статус реєстру встановити в "F"
       update returns_reestr r
       set r.rr_st = 'F'
       where r.rr_st in ('L')
         and r.rr_id = rr.rr_id
         and exists (
             select 1 from rr_list rrl
             where rrl_rr = rr_id
             having count(1) = count(case when rrl_st = 'F' then rrl_id else null end)
              );

       if  \*sql%rowcount > 0*\l_rr_st = 'F' and rr.rr_id > 0 then
          GetRrlPnfPpvp(rr.rr_id);
         end if;
      end loop;

    */
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'API$ESR_EXCHANGE.SetReturnReestrPo:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;

    -- io 20220727  Обробка пакета КВ-1 post_convert_answer
    PROCEDURE proc_pca_pkt (p_pkt_id IN NUMBER)
    IS
        l_zip               BLOB;
        l_file_blob         BLOB;
        l_file_xml          XMLTYPE;
        l_date_time         VARCHAR2 (19);
        l_full_lines        NUMBER;
        l_pr_id             NUMBER;
        l_prs_id            NUMBER;
        l_lock_hs           NUMBER;
        l_file_name         VARCHAR2 (500);
        l_err_msg           VARCHAR2 (500);
        l_kv_result         NUMBER;
        l_cnt               NUMBER;
        l_prc_visual_data   CLOB;
        l_visual_data       CLOB;
        l_pr_tp             VARCHAR2 (10);
        l_com_org           NUMBER;
        l_pr_file_name      VARCHAR2 (500);
        l_res_file          VARCHAR2 (10);
        l_nb_id             NUMBER;
        l_rec_id            NUMBER;
        l_pkt_out           NUMBER;
        l_rows_pay          NUMBER;
        l_rows_notpay       NUMBER;
        l_rows_notproc      NUMBER;
        l_pr_info           VARCHAR2 (500);
    BEGIN
        -- вичитуємо дані КВ-1
        SELECT c.pc_name, c.pc_data, pkt_rec
          INTO l_file_name, l_zip, l_rec_id
          FROM ikis_rbm.v_packet  p
               JOIN ikis_rbm.v_packet_content c ON pc_pkt = pkt_id
         WHERE 1 = 1 --    and pkt_pat =  -- KV-1
                     --    and pkt_st = 'N'  -- status ???
                     AND pkt_id = p_pkt_id;

        -- Вичитуємо дані вихідного пакета на банк
        -- l_pr_id можна отриати також з exchangefiles.ef_pr

        SELECT pkt_id, REPLACE (c.pc_name, '.json', '')
          INTO l_pkt_out, l_pr_file_name
          FROM ikis_rbm.v_packet  p
               JOIN ikis_rbm.v_packet_content c ON pc_pkt = pkt_id
               JOIN ikis_rbm.v_packet_links pl ON pl.pl_pkt_out = p.pkt_id
         WHERE 1 = 1 --    and pkt_pat =  -- KV-1
                     --    and pkt_st = 'N'  -- status ???
                     AND pl.pl_pkt_in = p_pkt_id;

        SELECT ef_pr
          INTO l_pr_id
          FROM exchangefiles
         WHERE     ef_pkt = l_pkt_out
               AND ef_tp = 'PR'
               AND ef_name = l_pr_file_name;

        SELECT MAX (pr_tp),
               MAX (com_org),
               MAX (
                      ' №'
                   || l_pr_id
                   || ' за '
                   || TO_CHAR (p.pr_month, 'mm.yyyy')
                   || ' по '
                   || p.com_org
                   || ' від '
                   || TO_CHAR (pr_create_dt, 'dd.mm.yyyy hh24:mi:ss'))
          INTO l_pr_tp, l_com_org, l_pr_info
          FROM payroll p
         WHERE pr_id = l_pr_id;

        /*
           -- #68043 Перевіряємо наявність коригуючої
           select max(pr_id) into l_pr_cor
           from payroll
           where pr_pr = l_pr_id
             and pr_tp = 'C';*/
        -- визначаємо банк
        SELECT rec_nb
          INTO l_nb_id
          FROM ikis_rbm.v_recipient r
         WHERE r.rec_id = l_rec_id;

        l_file_blob := UTL_COMPRESS.lz_uncompress (l_zip);
        l_file_xml := xmltype (tools.ConvertB2C (l_file_blob));

        /*Атрибути квитанції щодо опрацювання файлу
        1.  Дата та час формування файлу Банком date_time Number(19)  Так В форматі «DD.MM.YYYY HH:MI:SS»
        2.  Кількість записів в файлі full_lines  Number(8)
            */
        BEGIN
            l_date_time :=
                l_file_xml.EXTRACT ('/declar/declarhead/date_time/text()').getstringval ();
            l_full_lines :=
                TO_NUMBER (
                    l_file_xml.EXTRACT (
                        '/declar/declarhead/full_lines/text()').getstringval ());
            l_res_file :=
                TO_NUMBER (
                    l_file_xml.EXTRACT ('/declar/declarhead/res_file/text()').getstringval ());
        EXCEPTION
            WHEN OTHERS
            THEN
                --  логи, протоколи?      -- потрибно писати хоча б в ikis_rbm.log_packet ?
                DBMS_OUTPUT.put_line (
                       'Зміст параметру  /declar/declarhead/ (DECLARHEAD) не містить очікуваної структури : '
                    || SQLERRM);
                RAISE;
        END;

        IF l_res_file != '0'
        THEN                                           -- файл не опрацьовано:
            l_err_msg :=
                CASE l_res_file
                    WHEN '1'
                    THEN
                        '1 - закінчився строк дії сертифікату / сертифікат заблоковано підписувача'
                    WHEN '1'
                    THEN
                        '2 - відсутність однієї з частин файлу'
                    WHEN '1'
                    THEN
                        '3 -  неможливо розархівувати файл DATA'
                    WHEN '1'
                    THEN
                        '4 - невідповідність формату файлу'
                    WHEN '1'
                    THEN
                        '5 - інформація в тезі «lines» не відповідає кількості записів в файлі'
                    ELSE
                        'res_file=<' || l_res_file || '>'
                END;
            ikis_rbm.rdm$log_packet.insert_message (
                p_lp_pkt       => p_pkt_id,
                --p_lp_atp     => ,
                p_lp_comment   => l_err_msg);
        END IF;

        -- dbms_output.put_line(  l_date_time || '#' ||  l_full_lines ) ;
        /*-- Атрибути квитанції щодо опрацювання інформації по вкладникам
        1.  Порядковий номер запису rownum  Number(7) Так номер, що вказано в списках на зарахування (Ідентифікатор рядка в пакеті  REC_ID)
        2.  Номер списку  num_list  Number(10)  Так id – ідентифікатор пакету в прикладній системі обміну документами ЄІССС яким передано список
        3.  Прізвище  ln  Character (70)  Так У випадку розходження ПІБ більше ніж на 20%, зазначати значення Банку
        4.  Ім’я  nm  Character (50)  Так
        5.  По батькові ftn Character (50)  Ні
        6.  РНОКПП отримувача numident  Character(10) Так Формат:
                    ІПН – 10 цифр (з ведучими нулями);
                    паспорт нового зразка - 9 цифр (з ведучими нулями);
                    паспорт старого зразка – 8 знаків: 2 кір. літери + 6 цифр
        7.  Номер рахунку вкладника (що відповідає вказаним реквізитам вкладника) num_acc Character(29) Ні  заповнюється Банком у разі проставлення коду результату опрацювання  «2»
        8.  Результат опрацювання кожного запису файлу  result  Number(2) Так 0-запис опрацьовано;
                    причини не опрацювання:
                    1 - рахунок не відповідає реквізитам по РНОКПП або серія та номер паспорту (тільки для  клієнтів Ощадного банку),
                    2 - рахунок не відповідає реквізитам по ПІБ (тільки для  клієнтів Ощадного банку ),
                    3 - рахунок закритий (тільки для  клієнтів Ощадного банку ),
                    4 - не знайдено по РНОКПП або серія та номер паспорту (тільки для  клієнтів Ощадного банку ),
                    5 – вилучено за списком ЄІССС,
                    6 – рахунок не належить Ощадбанку та не відповідає формату  інших банків*/

        --BEGIN
        INSERT INTO tmp_ppr_info (tpi_pkt,
                                  tpi_pr,
                                  tpi_prs,
                                  tpi_rownum,
                                  tpi_file_name,
                                  tpi_num_list,
                                  tpi_ln,
                                  tpi_nm,
                                  tpi_ftn,
                                  tpi_numident,
                                  tpi_num_acc,
                                  tpi_result)
                    SELECT p_pkt_id,
                           l_pr_id,
                           NULL,
                           x_rownum,
                           x_file_name,
                           x_num_list,
                           x_ln,
                           x_nm,
                           x_ftn,
                           x_numident,
                           x_num_acc,
                           x_result
                      FROM XMLTABLE (
                               '/declar/declarbody/row'
                               PASSING l_file_xml
                               COLUMNS x_file_name    VARCHAR2 (100) PATH 'file_name',
                                       x_rownum       NUMBER (7) PATH 'rownum',
                                       x_num_list     NUMBER (10) PATH 'num_list', --  який було вказано в конверті GET_CONVERT_ANSWER
                                       x_ln           VARCHAR2 (70) PATH 'ln',
                                       x_nm           VARCHAR2 (50) PATH 'nm',
                                       x_ftn          VARCHAR2 (50) PATH 'ftn',
                                       x_numident     VARCHAR2 (10) PATH 'numident',
                                       x_num_acc      VARCHAR2 (29) PATH 'num_acc',
                                       x_result       NUMBER (2) PATH 'result');

        UPDATE tmp_ppr_info t
           SET t.tpi_prs =
                   (SELECT prs_id
                      FROM (SELECT prs.*
                              FROM pr_sheet prs
                             WHERE     prs_pr = l_pr_id
                                   AND prs_tp = 'PB'
                                   AND prs_nb = l_nb_id
                                   AND prs_num = t.tpi_rownum) prs
                     WHERE     1 = 1
                           -- #95021  and nvl(prs.prs_inn, '0000000000') = nvl(t.tpi_numident, '0000000000')
                           AND                             /*prs.prs_account*/
                               LPAD (prs.prs_account, 29, '0') =
                               t.tpi_num_acc)
         WHERE EXISTS
                   (SELECT 1
                      FROM (SELECT prs.*
                              FROM pr_sheet prs
                             WHERE     prs_pr = l_pr_id
                                   AND prs_tp = 'PB'
                                   AND prs_nb = l_nb_id
                                   AND prs_num = t.tpi_rownum) prs
                     WHERE     1 = 1
                           -- #95021  and nvl(prs.prs_inn, '0000000000') = nvl(t.tpi_numident, '0000000000')
                           AND                             /*prs.prs_account*/
                               LPAD (prs.prs_account, 29, '0') =
                               t.tpi_num_acc
                    HAVING COUNT (1) = 1);

        --  Контролі на обов'язкові поля!!!!
        /*     if l_prs_id > 0
             then
                l_err_msg := '';
                if rr.x_rownum  is null then l_err_msg := l_err_msg ||'Порядковий №(rownum),'; end if;
                if rr.x_num_list  is null then l_err_msg := l_err_msg ||'Номер списку(num_list),'; end if;
                if rr.x_Ln  is null then l_err_msg := l_err_msg ||'Прізвище(Ln),'; end if;
               --        if rr.x_Nm is null then l_err_msg := l_err_msg ||'Ім’я(Nm),'; end if;
                --if (rr.x_numident is null and rr.x_ser_num  is null) then l_err_msg := l_err_msg ||'РНОКПП(numident) або Серія та номер паспорту(ser_num),'; end if;
                if rr.x_Result  is null then l_err_msg := l_err_msg ||'Результат опрацювання(Result),'; end if;
        --День зарахування коштів на рахунок вкладника  date_enr
                if length(l_err_msg) > 0
                then
                  \*  insert into PNF_EXCHANGE_LOG(PEL_ID, PEL_PNF, PEL_WF,
                                               PEL_DT, PEL_RESULT, PEL_MESSAGE, PEL_FILE_TP,
                                               PEL_OVER_PRS)
                    select 0, l_pnf_id, \*l_ef_id*\ p_wf_id,
                           sysdate, '', \*'Не заповнені обов''язкові поля: '*\'&100#'||l_err_msg, 'PCA',
                           l_prs_id
                    from dual;*\
                    l_kv_result := 2;
                elsif  rr.x_Result > 7 then
                  l_kv_result := 7;
                else
         */
        -- Блокування в КВ-1. Масове через  API$PAYROLL.kv1_proc_pay
        INSERT INTO tmp_prs_block (x_prs, x_block_tp)
            SELECT tpi_prs, 100 + tpi_result
              FROM tmp_ppr_info t
             WHERE tpi_prs > 0;

        API$PAYROLL.kv1_proc_pay (p_mode => 2); -- =передача параметрів через тимчасову табилцю tmp_prs_block

        ikis_rbm.rdm$packet.Set_Packet_State (p_Pkt_Id          => p_pkt_id,
                                              p_Pkt_St          => 'PRC',
                                              p_Pkt_Change_Wu   => NULL,
                                              p_Pkt_Change_Dt   => SYSDATE);

        /*  select count(1) into l_cnt
          from tmp_ppr_info
          where tpi_prs > 0; --  опрацьовані!*/

        ---'процес "Обробка квитанції банку про опрацювання файлу зі списками": Оброблено '||l_cnt||' записів');
        SELECT                      -- описова інформація,  в т.ч і для звітів
               COUNT (1),
               COUNT (
                   CASE
                       WHEN t.tpi_prs IS NOT NULL AND t.tpi_result > 0 THEN 1
                       ELSE NULL
                   END),
               COUNT (
                   CASE
                       WHEN t.tpi_prs IS NOT NULL AND t.tpi_result = 0 THEN 1
                       ELSE NULL
                   END),
               COUNT (CASE WHEN t.tpi_prs IS NULL THEN 1 ELSE NULL END),
               COUNT (CASE WHEN t.tpi_prs IS NOT NULL THEN 1 ELSE NULL END)
          INTO l_full_lines,
               l_rows_notpay,
               l_rows_pay,
               l_rows_notproc,
               l_cnt
          FROM tmp_ppr_info t;

        -- генеруємо квитанцію в   exchangefiles  ????  чи в ПЕОД ???
        IF                                                       /*l_cnt > 0*/
           1 = 1
        THEN
            -- візуалізація
            SELECT    '<div><H3>КВ-1 на ВВ '
                   || l_pr_info
                   || '</H3>
<p>Всього рядків в квитанції:'
                   || l_full_lines
                   || '</p>
<p>в т.ч.</p>
<ol>
<li>опрацьовано: '
                   || l_cnt
                   || '.  з них:
  <ul style="list-style-type: disc;">
    <li>підтверджено банком: '
                   || l_rows_pay
                   || '</li>
    <li>не підтверджено банком: '
                   || l_rows_notpay
                   || '</li>
  </ul>
  </li>
<li>не опрацьовано: '
                   || l_rows_notproc
                   || '</li>
</ol></div>
'
                   || CASE
                          WHEN l_rows_notproc > 0 OR l_rows_notpay > 0
                          THEN
                              XMLELEMENT (
                                  "div",
                                  XMLELEMENT (
                                      "style",
                                      'table.z, th.z, td.z {border: 1px solid black;    border-collapse: collapse;}'),
                                  /*                    (SELECT XMLELEMENT("div",\*utl_i18n.unescape_reference*\(l_visual_data))
                                           FROM dual
                                           WHERE rownum = 1),*/
                                   (SELECT XMLELEMENT (
                                               "table",
                                               XMLATTRIBUTES ('z' AS "class"),
                                               --XMLATTRIBUTES('"font-family:Arial, sans-serif;font-size:14px;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;"' AS "class"),
                                               XMLELEMENT (
                                                   "tr",
                                                   XMLATTRIBUTES (
                                                       'z' AS "class"),
                                                   XMLELEMENT (
                                                       "td",
                                                       XMLATTRIBUTES (
                                                           'z' AS "class"),
                                                       'Порядковий номер запису'),
                                                   -- XMLELEMENT("td", XMLATTRIBUTES('z' AS "class"), 'Номер списку'), -- CONVERT(ln, 'UTF8')
                                                   -- XMLELEMENT("td", XMLATTRIBUTES('z' AS "class"), 'Номер ПС'), -- CONVERT(ln, 'UTF8')
                                                   XMLELEMENT (
                                                       "td",
                                                       XMLATTRIBUTES (
                                                           'z' AS "class"),
                                                       'Прізвище'),         -- CONVERT(ln, 'UTF8')
                                                   XMLELEMENT (
                                                       "td",
                                                       XMLATTRIBUTES (
                                                           'z' AS "class"),
                                                       'Ім''я'),
                                                   XMLELEMENT (
                                                       "td",
                                                       XMLATTRIBUTES (
                                                           'z' AS "class"),
                                                       'По батькові'),
                                                   XMLELEMENT (
                                                       "td",
                                                       XMLATTRIBUTES (
                                                           'z' AS "class"),
                                                       'РНОКПП'),
                                                   XMLELEMENT (
                                                       "td",
                                                       XMLATTRIBUTES (
                                                           'z' AS "class"),
                                                       'IBAN'),
                                                   XMLELEMENT (
                                                       "td",
                                                       XMLATTRIBUTES (
                                                           'z' AS "class"),
                                                       'Результат опрацювання банком'),
                                                   XMLELEMENT (
                                                       "td",
                                                       XMLATTRIBUTES (
                                                           'z' AS "class"),
                                                       'Помилка опрацювання повідомлення')),
                                               XMLAGG (
                                                   XMLELEMENT (
                                                       "tr",
                                                       XMLATTRIBUTES (
                                                           'z' AS "class"),
                                                       XMLELEMENT (
                                                           "td",
                                                           XMLATTRIBUTES (
                                                               'z' AS "class"),
                                                           tpi_rownum),
                                                       XMLELEMENT (
                                                           "td",
                                                           XMLATTRIBUTES (
                                                               'z' AS "class"),
                                                           tpi_ln), -- CONVERT(ln, 'UTF8')
                                                       XMLELEMENT (
                                                           "td",
                                                           XMLATTRIBUTES (
                                                               'z' AS "class"),
                                                           tpi_nm),
                                                       XMLELEMENT (
                                                           "td",
                                                           XMLATTRIBUTES (
                                                               'z' AS "class"),
                                                           tpi_ftn),
                                                       XMLELEMENT (
                                                           "td",
                                                           XMLATTRIBUTES (
                                                               'z' AS "class"),
                                                           tpi_numident),
                                                       XMLELEMENT (
                                                           "td",
                                                           XMLATTRIBUTES (
                                                               'z' AS "class"),
                                                           tpi_num_acc),
                                                       XMLELEMENT (
                                                           "td",
                                                           XMLATTRIBUTES (
                                                               'z' AS "class"),
                                                           NVL (c.dic_sname,
                                                                tpi_Result)),
                                                       XMLELEMENT (
                                                           "td",
                                                           XMLATTRIBUTES (
                                                               'z' AS "class"),
                                                           tpi_prc_result))))
                                      FROM tmp_ppr_info  t
                                           LEFT JOIN
                                           uss_ndi.v_ddn_pr_exch_code c
                                               ON c.dic_value =
                                                  100 + t.tpi_Result
                                     WHERE    t.tpi_prs IS NULL
                                           OR t.tpi_result != 0)).getClobVal ()
                      END
              INTO l_prc_visual_data
              FROM DUAL;

            --  #95043 io 20231124
            ikis_rbm.RDM$PACKET_CONTENT.set_visual_data (
                p_pc_pkt           => p_pkt_id,
                p_pc_visual_data   => l_prc_visual_data);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            l_err_msg :=
                SUBSTR (
                       REPLACE (
                              DBMS_UTILITY.FORMAT_ERROR_STACK
                           || ' => '
                           || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                           'ORA-20000:')
                    || CHR (10)
                    || SQLERRM,
                    1,
                    500);
            raise_application_error (
                -20000,
                'API$ESR_EXCHANGE.proc_pca_pkt:' || CHR (10) || l_err_msg);
    END;

    -- io 20220727  Обробка пакета КВ-2 post_payment_reply
    PROCEDURE proc_ppr_pkt (p_pkt_id IN NUMBER)
    IS
        l_zip               BLOB;
        l_file_blob         BLOB;
        l_file_xml          XMLTYPE;
        l_date_time         VARCHAR2 (19);
        l_full_lines        NUMBER;
        l_pr_id             NUMBER;
        --l_lock_hs number;
        l_file_name         VARCHAR2 (500);
        l_err_msg           VARCHAR2 (500);
        l_cnt               NUMBER;
        l_prc_visual_data   CLOB;
        l_visual_data       CLOB;
        l_pr_tp             VARCHAR2 (10);
        l_com_org           NUMBER;
        l_pr_file_name      VARCHAR2 (500);
        --l_res_file        varchar2(10);
        l_nb_id             NUMBER;
        l_rec_id            NUMBER;
        l_pkt_out           NUMBER;
        l_header            VARCHAR2 (500);
        l_rows_pay          NUMBER;
        l_rows_notpay       NUMBER;
        l_rows_notproc      NUMBER;
        l_pr_info           VARCHAR2 (500);
    BEGIN
        -- вичитуємо дані КВ-2
        SELECT c.pc_name, c.pc_data, pkt_rec
          INTO l_file_name, l_zip, l_rec_id
          FROM ikis_rbm.v_packet  p
               JOIN ikis_rbm.v_packet_content c ON pc_pkt = pkt_id
         WHERE 1 = 1 --    and pkt_pat =  -- KV-2
                     --    and pkt_st = 'N'  -- status ???
                     AND pkt_id = p_pkt_id;

        -- Вичитуємо дані вихідного пакета на банк
        SELECT pkt_id, REPLACE (c.pc_name, '.json', '')
          INTO l_pkt_out, l_pr_file_name
          FROM ikis_rbm.v_packet  p
               JOIN ikis_rbm.v_packet_content c ON pc_pkt = pkt_id
               JOIN ikis_rbm.v_packet_links pl ON pl.pl_pkt_out = p.pkt_id
         WHERE 1 = 1 --    and pkt_pat =  -- KV-1
                     --    and pkt_st = 'N'  -- status ???
                     AND pl.pl_pkt_in = p_pkt_id;

        SELECT ef_pr
          INTO l_pr_id
          FROM exchangefiles
         WHERE     ef_pkt = l_pkt_out
               AND ef_tp = 'PR'
               AND ef_name = l_pr_file_name;

        SELECT MAX (pr_tp),
               MAX (com_org),
               MAX (
                      ' №'
                   || l_pr_id
                   || ' за '
                   || TO_CHAR (p.pr_month, 'mm.yyyy')
                   || ' по '
                   || p.com_org
                   || ' від '
                   || TO_CHAR (pr_create_dt, 'dd.mm.yyyy hh24:mi:ss'))
          INTO l_pr_tp, l_com_org, l_pr_info
          FROM payroll p
         WHERE pr_id = l_pr_id;

        /*
           -- #68043 Перевіряємо наявність коригуючої
           select max(pr_id) into l_pr_cor
           from payroll
           where pr_pr = l_pr_id
             and pr_tp = 'C';*/
        -- визначаємо банк
        SELECT rec_nb
          INTO l_nb_id
          FROM ikis_rbm.v_recipient r
         WHERE r.rec_id = l_rec_id;

        l_file_blob := UTL_COMPRESS.lz_uncompress (l_zip);
        l_file_xml := xmltype (tools.ConvertB2C (l_file_blob));

        /*Атрибути квитанції щодо опрацювання файлу
        1.  Дата та час формування файлу Банком date_time Number(19)  Так В форматі «DD.MM.YYYY HH:MI:SS»
        2.  Кількість записів в файлі full_lines  Number(8)
            */
        BEGIN
            l_date_time :=
                l_file_xml.EXTRACT ('/declar/declarhead/date_time/text()').getstringval ();
            l_full_lines :=
                TO_NUMBER (
                    l_file_xml.EXTRACT (
                        '/declar/declarhead/full_lines/text()').getstringval ());
            l_file_name :=
                l_file_xml.EXTRACT ('/declar/declarhead/file_name/text()').getstringval ();
        EXCEPTION
            WHEN OTHERS
            THEN
                --  логи, протоколи?
                -- потрибно писати хоча б в ikis_rbm.log_packet ?
                DBMS_OUTPUT.put_line (
                       'Зміст параметру  /declar/declarhead/ (DECLARHEAD) не містить очікуваної структури : '
                    || SQLERRM);
                RAISE;
        END;

        -- dbms_output.put_line(  l_date_time || '#' ||  l_full_lines ) ;
        /*-- Атрибути квитанції щодо опрацювання інформації по вкладникам
        3.  Порядковий номер запису rownum  Number(7) Так номер, що вказано в списках на зарахування (Ідентифікатор рядка в пакеті  REC_ID)
        4.  Номер списку  num_list  Number(10)  Так id – ідентифікатор пакету в прикладній системі обміну документами ЄІССС яким передано список
        5.  Прізвище  ln  Character (70)  Так
        6.  Ім’я  nm  Character (50)  Так
        7.  По батькові ftn Character (50)  Ні
        8.  РНОКПП отримувача  numident  Character(10) Ні  Формат:
                ІПН – 10 цифр (з ведучими нулями);
                паспорт нового зразка - 9 цифр (з ведучими нулями);
                паспорт старого зразка - 8 знаків: 2 кір. літери + 6 цифр
        9.  Номер рахунку вкладника num_acc Character(29) Так
        10. День зарахування коштів на рахунок вкладника (або встановлення поточного значення  result)  date_enr  Character(8)  Ні  в форматі ddmmyyyy
        11. Сума  sum_pay Number(19)  Так Сума в копійках
        12. Результат опрацювання result  Number(1) Так 0 – кошти зараховані на рахунок вкладника;
                причини не зарахування:
                1-платіж не виконано із-за неналежних реквізитів отримувача. Платіж повернуто.
                2-платіж не виконано із-за закритого (або заблокованого рахунку) для клієнтів Ощадного банку.
                3-вилучено з реєстру за списком ЄІССС
        13. Дата платіжного доручення повернення коштів date_return Character(8)  Ні  в форматі ddmmyyyy,
                обов’язкове заповнення у разі проставлення кодів результату опрацювання  1 та 2.
        14. Номер платіжного доручення повернення коштів  num_return  Character(10) Ні
                обов’язкове заповнення у разі проставлення кодів результату опрацювання  1 та 2.
        */

        --BEGIN
        INSERT INTO tmp_ppr_info (tpi_pkt,
                                  tpi_pr,
                                  tpi_prs,
                                  tpi_rownum,
                                  tpi_file_name,
                                  tpi_num_list,
                                  tpi_ln,
                                  tpi_nm,
                                  tpi_ftn,
                                  tpi_numident,
                                  tpi_num_acc,
                                  tpi_result,
                                  tpi_date_enr,
                                  tpi_sum_pay,
                                  tpi_date_return,
                                  tpi_num_return)
                      SELECT p_pkt_id,
                             l_pr_id,
                             NULL,
                             x_rownum,
                             l_file_name,
                             x_num_list,
                             x_ln,
                             x_nm,
                             x_ftn,
                             x_numident,
                             x_num_acc,
                             x_result,
                             x_date_enr,
                             x_sum_pay,
                             x_date_return,
                             x_num_return
                        FROM XMLTABLE (
                                 '/declar/declarbody/row'
                                 PASSING l_file_xml
                                 COLUMNS x_rownum         NUMBER (7) PATH 'rownum',
                                         x_num_list       NUMBER (10) PATH 'num_list', --  який було вказано в конверті GET_CONVERT_ANSWER
                                         x_ln             VARCHAR2 (70) PATH 'ln',
                                         x_nm             VARCHAR2 (50) PATH 'nm',
                                         x_ftn            VARCHAR2 (50) PATH 'ftn',
                                         x_numident       VARCHAR2 (10) PATH 'numident',
                                         x_num_acc        VARCHAR2 (29) PATH 'num_acc',
                                         x_result         NUMBER (2) PATH 'result',
                                         x_date_enr       VARCHAR2 (8) PATH 'date_enr',
                                         x_sum_pay        NUMBER (19) PATH 'sum_pay',
                                         x_date_return    VARCHAR2 (50) PATH 'date_return',
                                         x_num_return     VARCHAR2 (50) PATH 'num_return');

        UPDATE tmp_ppr_info t
           SET t.tpi_prs =
                   (SELECT prs_id
                      FROM (SELECT prs.*
                              FROM pr_sheet prs
                             WHERE     prs_pr = l_pr_id
                                   AND prs_tp = 'PB'
                                   AND prs_nb = l_nb_id
                                   AND prs_num = t.tpi_rownum) prs
                     WHERE     1 = 1
                           -- #95021  and nvl(prs.prs_inn, '0000000000') = nvl(t.tpi_numident, '0000000000')
                           AND                             /*prs.prs_account*/
                               LPAD (prs.prs_account, 29, '0') =
                               t.tpi_num_acc)
         WHERE EXISTS
                   (SELECT 1
                      FROM (SELECT prs.*
                              FROM pr_sheet prs
                             WHERE     prs_pr = l_pr_id
                                   AND prs_tp = 'PB'
                                   AND prs_nb = l_nb_id
                                   AND prs_num = t.tpi_rownum) prs
                     WHERE     1 = 1
                           -- #95021  and nvl(prs.prs_inn, '0000000000') = nvl(t.tpi_numident, '0000000000')
                           AND                             /*prs.prs_account*/
                               LPAD (prs.prs_account, 29, '0') =
                               t.tpi_num_acc
                    HAVING COUNT (1) = 1);

        --  Контролі на обов'язкові поля!!!!
        /*     if l_prs_id > 0
             then
                l_err_msg := '';
                if rr.x_rownum  is null then l_err_msg := l_err_msg ||'Порядковий №(rownum),'; end if;
                if rr.x_num_list  is null then l_err_msg := l_err_msg ||'Номер списку(num_list),'; end if;
                if rr.x_Ln  is null then l_err_msg := l_err_msg ||'Прізвище(Ln),'; end if;
               --        if rr.x_Nm is null then l_err_msg := l_err_msg ||'Ім’я(Nm),'; end if;
                --if (rr.x_numident is null and rr.x_ser_num  is null) then l_err_msg := l_err_msg ||'РНОКПП(numident) або Серія та номер паспорту(ser_num),'; end if;
                if rr.x_Result  is null then l_err_msg := l_err_msg ||'Результат опрацювання(Result),'; end if;
        --День зарахування коштів на рахунок вкладника  date_enr
                if length(l_err_msg) > 0
                then
                  \*  insert into PNF_EXCHANGE_LOG(PEL_ID, PEL_PNF, PEL_WF,
                                               PEL_DT, PEL_RESULT, PEL_MESSAGE, PEL_FILE_TP,
                                               PEL_OVER_PRS)
                    select 0, l_pnf_id, \*l_ef_id*\ p_wf_id,
                           sysdate, '', \*'Не заповнені обов''язкові поля: '*\'&100#'||l_err_msg, 'PCA',
                           l_prs_id
                    from dual;*\
                    l_kv_result := 2;
                elsif  rr.x_Result > 7 then
                  l_kv_result := 7;
                else
         */
        -- Блокування в КВ-2. Масове через  API$PAYROLL.kv1_proc_pay
        INSERT INTO tmp_prs_block (x_prs, x_block_tp, x_dt)
            SELECT tpi_prs,
                   200 + tpi_result,
                   TO_DATE (t.tpi_date_enr, 'ddmmyyyy')
              FROM tmp_ppr_info t
             WHERE tpi_prs > 0;

        -- IC #108218
        -- Дозволити обробляти повторно рядки зі статусом KV2
        UPDATE uss_esr.pr_sheet
           SET prs_st = 'NA'
         WHERE prs_st = 'KV2' AND prs_id IN (SELECT x_prs FROM tmp_prs_block);


        API$PAYROLL.kv2_proc_pay (p_mode => 2); -- =передача параметрів через тимчасову табилцю tmp_prs_block

        ikis_rbm.rdm$packet.Set_Packet_State (p_Pkt_Id          => p_pkt_id,
                                              p_Pkt_St          => 'PRC',
                                              p_Pkt_Change_Wu   => NULL,
                                              p_Pkt_Change_Dt   => SYSDATE);

        SELECT COUNT (1)
          INTO l_cnt
          FROM tmp_ppr_info
         WHERE tpi_prs > 0;                                   --  опрацьовані!

        SELECT                      -- описова інформація,  в т.ч і для звітів
                  XMLELEMENT ("rows_total", COUNT (t.tpi_result))
               || XMLELEMENT ("sum_total", SUM (t.tpi_sum_pay))
               || XMLELEMENT ("rows_notpay",
                              COUNT (NULLIF (t.tpi_result, 0)))
               || XMLELEMENT ("sum_notpay",
                              SUM (t.tpi_sum_pay * SIGN (t.tpi_result))),
               COUNT (1),
               COUNT (
                   CASE
                       WHEN t.tpi_prs IS NOT NULL AND t.tpi_result > 0 THEN 1
                       ELSE NULL
                   END),
               COUNT (
                   CASE
                       WHEN t.tpi_prs IS NOT NULL AND t.tpi_result = 0 THEN 1
                       ELSE NULL
                   END),
               COUNT (CASE WHEN t.tpi_prs IS NULL THEN 1 ELSE NULL END)
          INTO l_header,
               l_full_lines,
               l_rows_notpay,
               l_rows_pay,
               l_rows_notproc
          FROM tmp_ppr_info t;

        ikis_rbm.RDM$PACKET_CONTENT.set_pc_header (p_pc_pkt      => p_pkt_id,
                                                   p_pc_header   => l_header);

        ---'процес "Обробка квитанції банку про опрацювання файлу зі списками": Оброблено '||l_cnt||' записів');

        -- генеруємо квитанцію в   exchangefiles  ????  чи в ПЕОД ???
        IF 1 = 1                                                 /*l_cnt > 0*/
        THEN
            -- візуалізація
            SELECT    '<H3>КВ-2 на ВВ '
                   || l_pr_info
                   || '</H3>
<p>Всього рядків в квитанції:'
                   || l_full_lines
                   || '</p>
<p>в т.ч.</p>
<ol>
<li>опрацьовано: '
                   || l_cnt
                   || '.  з них:
  <ul style="list-style-type: disc;">
    <li>підтверджено банком: '
                   || l_rows_pay
                   || '</li>
    <li>не підтверджено банком: '
                   || l_rows_notpay
                   || '</li>
  </ul>
  </li>
<li>не опрацьовано: '
                   || l_rows_notproc
                   || '</li>
</ol>
'
                   || CASE
                          WHEN l_rows_notproc > 0 OR l_rows_notpay > 0
                          THEN
                              XMLELEMENT (
                                  "div",
                                  XMLELEMENT (
                                      "style",
                                      'table.z, th.z, td.z {border: 1px solid black;    border-collapse: collapse;}'),
                                  /*                    (SELECT XMLELEMENT("div",\*utl_i18n.unescape_reference*\(l_visual_data))
                                           FROM dual
                                           WHERE rownum = 1),*/
                                   (SELECT XMLELEMENT (
                                               "table",
                                               XMLATTRIBUTES ('z' AS "class"),
                                               --XMLATTRIBUTES('"font-family:Arial, sans-serif;font-size:14px;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;"' AS "class"),
                                               XMLELEMENT (
                                                   "tr",
                                                   XMLATTRIBUTES (
                                                       'z' AS "class"),
                                                   XMLELEMENT (
                                                       "td",
                                                       XMLATTRIBUTES (
                                                           'z' AS "class"),
                                                       'Порядковий номер запису'),
                                                   -- XMLELEMENT("td", XMLATTRIBUTES('z' AS "class"), 'Номер списку'), -- CONVERT(ln, 'UTF8')
                                                   -- XMLELEMENT("td", XMLATTRIBUTES('z' AS "class"), 'Номер ПС'), -- CONVERT(ln, 'UTF8')
                                                   XMLELEMENT (
                                                       "td",
                                                       XMLATTRIBUTES (
                                                           'z' AS "class"),
                                                       'Прізвище'),         -- CONVERT(ln, 'UTF8')
                                                   XMLELEMENT (
                                                       "td",
                                                       XMLATTRIBUTES (
                                                           'z' AS "class"),
                                                       'Ім''я'),
                                                   XMLELEMENT (
                                                       "td",
                                                       XMLATTRIBUTES (
                                                           'z' AS "class"),
                                                       'По батькові'),
                                                   XMLELEMENT (
                                                       "td",
                                                       XMLATTRIBUTES (
                                                           'z' AS "class"),
                                                       'РНОКПП'),
                                                   XMLELEMENT (
                                                       "td",
                                                       XMLATTRIBUTES (
                                                           'z' AS "class"),
                                                       'IBAN'),
                                                   XMLELEMENT (
                                                       "td",
                                                       XMLATTRIBUTES (
                                                           'z' AS "class"),
                                                       'День зарахування коштів на рахунок вкладника'),
                                                   XMLELEMENT (
                                                       "td",
                                                       XMLATTRIBUTES (
                                                           'z' AS "class"),
                                                       'Сума'),
                                                   XMLELEMENT (
                                                       "td",
                                                       XMLATTRIBUTES (
                                                           'z' AS "class"),
                                                       'Дата платіжного доручення повернення коштів'),
                                                   XMLELEMENT (
                                                       "td",
                                                       XMLATTRIBUTES (
                                                           'z' AS "class"),
                                                       'Номер платіжного доручення повернення коштів'),
                                                   XMLELEMENT (
                                                       "td",
                                                       XMLATTRIBUTES (
                                                           'z' AS "class"),
                                                       'Результат опрацювання банком'),
                                                   XMLELEMENT (
                                                       "td",
                                                       XMLATTRIBUTES (
                                                           'z' AS "class"),
                                                       'Помилка опрацювання повідомлення')),
                                               XMLAGG (
                                                   XMLELEMENT (
                                                       "tr",
                                                       XMLATTRIBUTES (
                                                           'z' AS "class"),
                                                       XMLELEMENT (
                                                           "td",
                                                           XMLATTRIBUTES (
                                                               'z' AS "class"),
                                                           tpi_rownum),
                                                       XMLELEMENT (
                                                           "td",
                                                           XMLATTRIBUTES (
                                                               'z' AS "class"),
                                                           tpi_ln), -- CONVERT(ln, 'UTF8')
                                                       XMLELEMENT (
                                                           "td",
                                                           XMLATTRIBUTES (
                                                               'z' AS "class"),
                                                           tpi_nm),
                                                       XMLELEMENT (
                                                           "td",
                                                           XMLATTRIBUTES (
                                                               'z' AS "class"),
                                                           tpi_ftn),
                                                       XMLELEMENT (
                                                           "td",
                                                           XMLATTRIBUTES (
                                                               'z' AS "class"),
                                                           tpi_numident),
                                                       XMLELEMENT (
                                                           "td",
                                                           XMLATTRIBUTES (
                                                               'z' AS "class"),
                                                           tpi_num_acc),
                                                       XMLELEMENT (
                                                           "td",
                                                           XMLATTRIBUTES (
                                                               'z' AS "class"),
                                                           tpi_date_enr),
                                                       XMLELEMENT (
                                                           "td",
                                                           XMLATTRIBUTES (
                                                               'z' AS "class"),
                                                           tpi_sum_pay),
                                                       XMLELEMENT (
                                                           "td",
                                                           XMLATTRIBUTES (
                                                               'z' AS "class"),
                                                           tpi_date_return),
                                                       XMLELEMENT (
                                                           "td",
                                                           XMLATTRIBUTES (
                                                               'z' AS "class"),
                                                           tpi_num_return),
                                                       XMLELEMENT (
                                                           "td",
                                                           XMLATTRIBUTES (
                                                               'z' AS "class"),
                                                           NVL (c.dic_sname,
                                                                tpi_Result)),
                                                       XMLELEMENT (
                                                           "td",
                                                           XMLATTRIBUTES (
                                                               'z' AS "class"),
                                                           tpi_prc_result))))
                                      FROM tmp_ppr_info  t
                                           LEFT JOIN
                                           uss_ndi.v_ddn_pr_exch_code c
                                               ON c.DIC_VALUE =
                                                  200 + t.tpi_Result
                                     WHERE    t.tpi_prs IS NULL
                                           OR t.tpi_result != 0)).getClobVal ()
                      END
              INTO l_prc_visual_data
              FROM DUAL;

            --  #95043 io 20231124
            ikis_rbm.RDM$PACKET_CONTENT.set_visual_data (
                p_pc_pkt           => p_pkt_id,
                p_pc_visual_data   => l_prc_visual_data);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'API$ESR_EXCHANGE.proc_ppr_pkt:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;

    -- IC #97478 Обробка квитанції повернення від пошти
    PROCEDURE proc_kpp_pkt (p_pkt_id IN NUMBER)
    IS
        l_zip_blob          ikis_rbm.v_packet_content.pc_data%TYPE;
        l_pc_row            ikis_rbm.v_packet_content%ROWTYPE;
        l_clob              CLOB;
        l_xml               XMLTYPE;
        l_com_wu            NUMBER := tools.GetCurrWu;
        l_file_name         VARCHAR2 (250);
        l_file_blob         BLOB;
        l_prc_visual_data   CLOB;

        l_Pkt_pat           ikis_rbm.v_packet.pkt_pat%TYPE;
        l_Pkt_nes           ikis_rbm.v_packet.pkt_nes%TYPE;
        l_Pkt_org           ikis_rbm.v_packet.pkt_org%TYPE;
        l_Pkt_rec           ikis_rbm.v_packet.pkt_rec%TYPE;

        -- ЗАГОЛОВОК:    (Заголовок без розподілювачів )
        l_code_raj          VARCHAR2 (4);                        -- Код району
        l_num_per           VARCHAR2 (2);                     -- Номер періоду
        l_day_beg           VARCHAR2 (2);              -- День початку виплати
        l_day_end           VARCHAR2 (2);           -- День закінчення виплати
        l_mon_pay           VARCHAR2 (2);                    -- Місяць виплати
        l_year_pay          VARCHAR2 (4);                       -- Рік виплати
        l_code_pay          VARCHAR2 (2); -- Тип відомості (uss_ndi.v_ndi_payment_codes.npc_code)
        l_vid_pay           VARCHAR2 (2);                       -- Вид виплати
        l_sum_total         VARCHAR2 (15) := '0';   -- Загальна сума по району
        l_rec_cnt           VARCHAR2 (6);             -- Кількість отримувачів

        l_code_pos          VARCHAR2 (2);                     -- Вузол зв'язку
        l_ind_num           VARCHAR2 (6);          -- Індекс населеного пункту
        l_num_pr            VARCHAR2 (4);                   -- Номер відомості
        l_num_ac            VARCHAR2 (12);          -- Номер особового рахунку
        l_sum_acc           VARCHAR2 (9);                 -- Сума "Нараховано"
        l_type_op           VARCHAR2 (2); -- Ознака невиплати (01-ВИБУВ, 02-ПОМЕР, 03-ІНШІ)

        l_prs_date          DATE;
        l_cnt_row           NUMBER := 0;
        l_cnt_no_row        NUMBER := 0;
        l_cnt_no_sum        NUMBER := 0;
        l_cnt_err           NUMBER := 0;

        PROCEDURE proc_csv (i_clob IN CLOB)
        AS
        BEGIN
            FOR c IN (SELECT ROW_NUMBER () OVER (ORDER BY NULL) rn, COL001 -- без розподілювачів
                        FROM TABLE (csv_util_pkg.clob_to_csv (i_clob)) p
                       WHERE COL001 IS NOT NULL)
            LOOP
                IF c.rn = 1
                THEN
                    l_code_raj :=
                        LPAD (TRIM (SUBSTR (c.COL001, 1, 4)), 4, '0');
                    l_num_per :=
                        LPAD (TRIM (SUBSTR (c.COL001, 5, 2)), 2, '0');
                    l_day_beg :=
                        LPAD (TRIM (SUBSTR (c.COL001, 7, 2)), 2, '0');
                    l_day_end :=
                        LPAD (TRIM (SUBSTR (c.COL001, 9, 2)), 2, '0');
                    l_mon_pay :=
                        LPAD (TRIM (SUBSTR (c.COL001, 11, 2)), 2, '0');
                    l_year_pay :=
                        LPAD (TRIM (SUBSTR (c.COL001, 13, 4)), 4, '0');
                    l_code_pay :=
                        LPAD (TRIM (SUBSTR (c.COL001, 17, 2)), 2, '0');
                    l_vid_pay :=
                        LPAD (TRIM (SUBSTR (c.COL001, 19, 2)), 2, '0');
                    l_sum_total := TRIM (SUBSTR (c.COL001, 21, 15));
                    l_rec_cnt := TRIM (SUBSTR (c.COL001, 36, 6));

                    l_prs_date :=
                        TO_DATE ('01' || l_mon_pay || l_year_pay, 'ddmmyyyy');
                    l_Pkt_org := TO_NUMBER (LPAD (l_code_raj, 5, '5'));
                --dbms_output.put_line(l_code_raj||l_num_per||l_day_beg||l_day_end||l_mon_pay||l_year_pay||l_code_pay||l_vid_pay||l_sum_total||l_rec_cnt);
                ELSE
                    l_code_pos :=
                        LPAD (TRIM (SUBSTR (c.COL001, 1, 2)), 2, '0');
                    l_ind_num :=
                        LPAD (TRIM (SUBSTR (c.COL001, 3, 6)), 6, '0');
                    l_num_pr := LPAD (TRIM (SUBSTR (c.COL001, 9, 4)), 4, '0');
                    l_num_ac :=
                        LPAD (TRIM (SUBSTR (c.COL001, 13, 12)), 12, '0');
                    l_sum_acc := TRIM (SUBSTR (c.COL001, 25, 9));
                    l_type_op :=
                        LPAD (TRIM (SUBSTR (c.COL001, 34, 2)), 2, '0');
                --dbms_output.put_line(l_code_pos||l_ind_num||l_num_pr||l_num_ac||l_sum_acc||l_type_op);
                END IF;

                --dbms_output.put_line(LPAD(c.rn,3,'0') || ': ' || c.COL001);

                IF c.rn > 1
                THEN
                    l_cnt_row := l_cnt_row + 1;
                    l_cnt_err := 1;

                    FOR cc
                        IN (SELECT SUBSTR (op.org_code, 1, 5)
                                       org_code,
                                   p.pr_month,
                                   LPAD (npc.npc_code, 2, '0')
                                       code_pay,
                                   LPAD (s.prs_index, 5, '0')
                                       npo_index,
                                   prs_num,
                                   prs_pc_num,
                                   SUM (COALESCE (prs_sum * 100, 0))
                                       OVER (
                                           PARTITION BY p.pr_id,
                                                        s.prs_num,
                                                        s.prs_pc_num)
                                       prs_sum,
                                   s.prs_id
                              FROM uss_esr.payroll  p
                                   INNER JOIN uss_esr.pr_sheet s
                                       ON prs_pr = pr_id
                                   INNER JOIN uss_esr.v_opfu op
                                       ON op.org_id = p.com_org
                                   INNER JOIN uss_ndi.v_ndi_payment_codes npc
                                       ON npc.npc_id = p.pr_npc
                             WHERE     prs_sum > 0
                                   AND p.pr_pay_tp = 'POST'
                                   AND prs_tp IN ('PP')      -- Виплата поштою
                                   AND p.pr_month = l_prs_date
                                   AND npc.npc_code = LTRIM (l_code_pay, '0')
                                   AND s.prs_index = LTRIM (l_ind_num, '0')
                                   AND prs_num = TO_NUMBER (l_num_pr)
                                   AND LTRIM (prs_pc_num, '0') =
                                       LTRIM (l_num_ac, '0')
                                   AND op.org_code = l_Pkt_org)
                    LOOP
                        l_cnt_err := -1;

                        IF     cc.prs_sum = l_sum_acc
                           AND l_type_op NOT IN ('01', '02')
                        THEN
                            l_cnt_err := 0;

                            UPDATE uss_esr.pr_sheet
                               SET prs_st =
                                       CASE
                                           WHEN l_type_op = '00' THEN 'KV2'
                                           ELSE 'PK2'
                                       END,
                                   prs_transfer_dt = SYSDATE
                             WHERE prs_id = cc.prs_id;

                            -- Якщо "Ознака невиплати" in ('01', '02'), тоді запускаємо на блокування рішення з вказаною причиною.
                            IF l_type_op IN ('01', '02')
                            THEN
                                INSERT INTO tmp_prs_block (x_prs,
                                                           x_block_tp,
                                                           x_dt)
                                         VALUES (cc.prs_id,
                                                 400 + TO_NUMBER (l_type_op),
                                                 SYSDATE);
                            END IF;
                        END IF;
                    END LOOP;                                            -- cc

                    IF l_cnt_err = -1
                    THEN
                        l_cnt_no_sum := l_cnt_no_sum + 1;
                    ELSIF l_cnt_err = 1
                    THEN
                        l_cnt_no_row := l_cnt_no_row + 1;
                    END IF;
                END IF;                                           -- ir rn > 1
            END LOOP;                                                     -- c
        END proc_csv;

        -- IC #101298 Зробити завантаження квитанцій повернення з пошти
        PROCEDURE proc_xml (i_xml IN XMLTYPE)
        AS
        BEGIN
            DELETE FROM tmp_xpp_info
                  WHERE 1 = 1;

            INSERT INTO tmp_xpp_info (txi_rownum,
                                      txi_id_convert,
                                      txi_num_list,
                                      txi_ln,
                                      txi_ind_vz,
                                      txi_ser,
                                      txi_num,
                                      txi_date_enr,
                                      txi_sum_pay,
                                      txi_result,
                                      txi_date_return,
                                      txi_num_return,
                                      txi_num_or)
                          SELECT xt.*
                            --,to_number(i_xml.extract('/ROWS/FULL_LINES/text()').getstringval()) rn
                            FROM XMLTABLE (
                                     '/ROWS/ROW'
                                     PASSING i_xml
                                     COLUMNS x_rownum         NUMBER (7) PATH 'ROWNUM',
                                             x_id_convert     VARCHAR2 (10) PATH 'ID_CONVERT',
                                             x_num_list       NUMBER (10) PATH 'NUM_LIST',
                                             x_ln             VARCHAR2 (70) PATH 'LN',
                                             x_ind_vz         VARCHAR2 (5) PATH 'IND_VZ',
                                             x_ser            VARCHAR2 (2) PATH 'SER',
                                             x_num            NUMBER (10) PATH 'NUM',
                                             x_date_enr       VARCHAR2 (8) PATH 'DATE_ENR',
                                             x_sum_pay        NUMBER PATH 'SUM_PAY',
                                             x_result         NUMBER (1) PATH 'RESULT',
                                             x_date_return    VARCHAR2 (8) PATH 'DATE_RETURN',
                                             x_num_return     VARCHAR2 (10) PATH 'NUM_RETURN',
                                             x_num_or         VARCHAR2 (50) PATH 'NUM_OR')
                                 xt;

            FOR c
                IN (SELECT x.ROWID,
                           x.txi_result,
                           x.txi_sum_pay,
                           CASE
                               WHEN x.txi_result = 0
                               THEN
                                   TO_DATE (
                                       x.txi_date_enr
                                           DEFAULT NULL ON CONVERSION ERROR,
                                       'ddmmyyyy')
                               ELSE
                                   NULL
                           END    txi_date_enr,
                           s.prs_id,
                           p.com_org,
                           CASE
                               WHEN s.prs_id IS NULL THEN -1
                               WHEN x.txi_sum_pay != s.prs_sum * 100 THEN -2
                               ELSE 0
                           END    txi_err
                      FROM tmp_xpp_info  x
                           INNER JOIN uss_esr.payroll p
                               ON p.pr_id = x.txi_id_convert
                           LEFT JOIN uss_esr.pr_sheet s
                               ON     s.prs_pr = p.pr_id
                                  AND s.prs_pc_num = x.txi_num_or
                                  AND s.prs_index = x.txi_ind_vz
                     WHERE 1 = 1)
            LOOP
                IF l_Pkt_org IS NULL
                THEN
                    l_Pkt_org := c.com_org;
                END IF;

                UPDATE uss_esr.pr_sheet
                   SET prs_st =
                           CASE
                               WHEN c.txi_result = 0 THEN 'KV2'
                               WHEN c.txi_result > 2 THEN 'PK2'
                               ELSE prs_st
                           END,
                       prs_transfer_dt = NVL (c.txi_date_enr, SYSDATE),
                       prs_remit_num = c.txi_result -- Tania, 15.05.2024 17:48 Записувати в PRS_REMIT_NUM
                 WHERE prs_id = c.prs_id --and c.txi_result not in (1, 2)
                                         AND c.txi_err = 0;

                -- Якщо "Ознака невиплати" in ('01', '02'), тоді запускаємо на блокування рішення з вказаною причиною.
                IF c.txi_result IN (1, 2) AND c.txi_err = 0
                THEN
                    INSERT INTO tmp_prs_block (x_prs, x_block_tp, x_dt)
                         VALUES (c.prs_id, 400 + c.txi_result, SYSDATE);
                END IF;

                UPDATE tmp_xpp_info
                   SET txi_err = c.txi_err
                 WHERE ROWID = c.ROWID;
            END LOOP;                                                     -- c

            l_rec_cnt :=
                TO_NUMBER (
                    i_xml.EXTRACT ('/ROWS/FULL_LINES/text()').getstringval ());

            SELECT COUNT (*)
                       cnt_row,
                   SUM (txi_sum_pay) * 0.01
                       sum_total,
                   TO_CHAR (MAX (p.pr_month), 'mm')
                       mon_pay,
                   TO_CHAR (MAX (p.pr_month), 'yyyy')
                       year_pay,
                   SUM (CASE WHEN txi_err = -1 THEN 1 ELSE 0 END)
                       cnt_no_row,
                   SUM (CASE WHEN txi_err = -2 THEN 1 ELSE 0 END)
                       cnt_no_sum
              INTO l_cnt_row,
                   l_sum_total,
                   l_mon_pay,
                   l_year_pay,
                   l_cnt_no_row,
                   l_cnt_no_sum
              FROM tmp_xpp_info  x
                   LEFT JOIN uss_esr.payroll p ON p.pr_id = x.txi_id_convert;
        END proc_xml;
    BEGIN
        SELECT c.pc_data,
               p.pkt_pat,
               p.pkt_nes,
               p.pkt_rec,
               c.pc_id,
               UPPER (c.pc_name),
               p.pkt_org
          INTO l_zip_blob,
               l_Pkt_pat,
               l_Pkt_nes,
               l_Pkt_rec,
               l_pc_row.pc_id,
               l_file_name,
               l_Pkt_org
          FROM ikis_rbm.v_packet  p
               JOIN ikis_rbm.v_packet_content c ON pc_pkt = pkt_id
         WHERE pkt_id = p_pkt_id;

        IF l_file_name LIKE '%.ZIP'
        THEN
            BEGIN
                tools.unZip2 (p_zip_blob    => l_zip_blob,
                              p_file_blob   => l_file_blob,
                              p_file_name   => l_file_name);
                l_clob := tools.ConvertB2C (l_file_blob);
            EXCEPTION
                WHEN OTHERS
                THEN
                    Raise_application_error (
                        -20000,
                           'Помилка обробки архіву.'
                        || CHR (10)
                        || 'Перевірте відповідність файлу "'
                        || l_file_name
                        || '" вимогам протоколу обміну.'
                        || CHR (10)
                        || DBMS_UTILITY.format_error_backtrace
                        || CHR (10)
                        || SQLERRM);
            END;
        ELSE
            l_clob := tools.ConvertB2C (l_zip_blob);
        END IF;

        l_pc_row.pc_name := l_file_name;

        IF UPPER (l_file_name) LIKE '%.XML'
        THEN
            l_code_raj := SUBSTR (l_file_name, 3, 4);
            l_code_pay := SUBSTR (l_file_name, 21, 2);

            BEGIN
                l_xml := xmltype (l_clob);
                proc_xml (l_xml);
            EXCEPTION
                WHEN OTHERS
                THEN
                    Raise_application_error (
                        -20000,
                           'Помилка обробки XML-файлу.'
                        || CHR (10)
                        || 'Перевірте відповідність файлу "'
                        || l_file_name
                        || '" вимогам протоколу обміну.'
                        || CHR (10)
                        || DBMS_UTILITY.format_error_backtrace
                        || CHR (10)
                        || SQLERRM);
            END;
        ELSE
            BEGIN
                proc_csv (l_clob);
            EXCEPTION
                WHEN OTHERS
                THEN
                    Raise_application_error (
                        -20000,
                           'Помилка обробки CSV-файлу.'
                        || CHR (10)
                        || 'Перевірте відповідність файлу "'
                        || l_file_name
                        || '" вимогам протоколу обміну.'
                        || CHR (10)
                        || DBMS_UTILITY.format_error_backtrace
                        || CHR (10)
                        || SQLERRM);
            END;
        END IF;

        BEGIN
            API$PAYROLL.kv2_proc_pay (p_mode => 2); -- =передача параметрів через тимчасову табилцю tmp_prs_block
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        ikis_rbm.rdm$packet.UPDATE_PACKET (p_Pkt_Id          => p_pkt_id,
                                           p_Pkt_pat         => l_Pkt_pat,
                                           p_Pkt_nes         => l_Pkt_nes,
                                           p_Pkt_org         => l_Pkt_org,
                                           p_Pkt_change_wu   => l_com_wu,
                                           p_Pkt_change_dt   => SYSDATE,
                                           p_Pkt_rec         => l_Pkt_rec);
        ikis_rbm.rdm$packet.Set_Packet_State (p_Pkt_Id          => p_pkt_id,
                                              p_Pkt_St          => 'PRC',
                                              p_Pkt_Change_Wu   => l_com_wu,
                                              p_Pkt_Change_Dt   => SYSDATE);

        l_pc_row.pc_visual_data :=
               '<H3>Пвернення від пошти '
            || 'Код району: '
            || l_code_raj
            || '; місяць виплати: '
            || l_mon_pay
            || '.'
            || l_year_pay
            || '; Тип відомості: '
            || l_code_pay
            || '; Загальна сума по району: '
            || l_sum_total
            || '; Кількість отримувачів: '
            || l_rec_cnt
            || '</H3>'
            || '
        <p>Всього рядків в квитанції:'
            || l_cnt_row
            || '</p>
        <p>в т.ч.</p>
        <ol>
        <li>опрацьовано: '
            || TO_CHAR (l_cnt_row - l_cnt_no_sum - l_cnt_no_row)
            || '</li>
        <li>не опрацьовано: '
            || TO_CHAR (l_cnt_no_sum + l_cnt_no_row)
            || '.  з них:
          <ul style="list-style-type: disc;">
            <li>не знайдено у списку відомостей: '
            || l_cnt_no_row
            || '</li>
            <li>не знайдено відповідної суми: '
            || l_cnt_no_sum
            || '</li>
          </ul>
          </li>
        </ol>';

        SELECT MAX (c.npc_id)
          INTO l_pc_row.pc_npc
          FROM uss_ndi.v_ndi_payment_codes c
         WHERE c.npc_code = LTRIM (l_code_pay, '0');

        ikis_rbm.RDM$PACKET_CONTENT.SET_PACKET_CONTENT (l_pc_row,
                                                        l_pc_row.pc_id);
    -- dbms_output.put_line(TO_CHAR(l_prc_visual_data));

    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'api$esr_exchange.proc_kpp_pkt:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END proc_kpp_pkt;

    --  Процедура автоматичної обробки КВ-1
    PROCEDURE RunProcessPCA
    IS
        l_err_msg   VARCHAR2 (500);
    BEGIN
        FOR rr_pca
            IN (SELECT pkt_id
                  FROM ikis_rbm.v_packet p
                 WHERE     1 = 1
                       AND pkt_pat = 102           -- KV-1  payroll_answer_vpo
                       AND pkt_st = 'N'
                       AND EXISTS
                               (SELECT 1
                                  FROM ikis_rbm.v_packet        p1,
                                       ikis_rbm.v_packet_links  pkl
                                 WHERE     pkl.pl_pkt_in = p.pkt_id
                                       AND pkl.pl_pkt_out = p1.pkt_id
                                       AND p1.pkt_pat = 101
                                       AND p1.pkt_create_dt >=
                                           TO_DATE ('24.10.2022',
                                                    'dd.mm.yyyy')))
        LOOP
            BEGIN
                proc_pca_pkt (p_pkt_id => rr_pca.pkt_id);
            EXCEPTION
                WHEN OTHERS
                THEN                    -- створити таблицю для логування ????
                    --'Помилка автоматичної обробки КВ-1: '||sqlerrm|| chr(10) || dbms_utility.format_error_stack || dbms_utility.format_error_backtrace);
                    l_err_msg :=
                        SUBSTR (
                               'ERR:'
                            || SQLERRM
                            || CHR (10)
                            || DBMS_UTILITY.format_error_stack
                            || DBMS_UTILITY.format_error_backtrace,
                            1,
                            500);
                    ikis_rbm.rdm$log_packet.insert_message (
                        p_lp_pkt       => rr_pca.pkt_id,
                        p_lp_comment   => l_err_msg);
            END;

            COMMIT;
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'RunProcessPCA:'
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END RunProcessPCA;

    -- Процедура автоматичної обробки КВ-2
    PROCEDURE RunProcessPPR
    IS
        l_err_msg   VARCHAR2 (500);
    BEGIN
        FOR rr_ppr
            IN (SELECT pkt_id
                  FROM ikis_rbm.v_packet p
                 WHERE     1 = 1
                       AND pkt_pat = 103            -- KV-1  payroll_reply_vpo
                       AND pkt_st = 'N'
                       AND EXISTS
                               (SELECT 1
                                  FROM ikis_rbm.v_packet        p1,
                                       ikis_rbm.v_packet_links  pkl
                                 WHERE     pkl.pl_pkt_in = p.pkt_id
                                       AND pkl.pl_pkt_out = p1.pkt_id
                                       AND p1.pkt_pat = 101
                                       AND p1.pkt_create_dt >=
                                           TO_DATE ('24.10.2022',
                                                    'dd.mm.yyyy')))
        LOOP
            BEGIN
                proc_ppr_pkt (p_pkt_id => rr_ppr.pkt_id);
            EXCEPTION
                WHEN OTHERS
                THEN                    -- створити таблицю для логування ????
                    -- 'Помилка автоматичної обробки КВ-2: '||sqlerrm|| chr(10) || dbms_utility.format_error_stack ||
                    --   dbms_utility.format_error_backtrace);
                    l_err_msg :=
                        SUBSTR (
                               'ERR:'
                            || SQLERRM
                            || CHR (10)
                            || DBMS_UTILITY.format_error_stack
                            || DBMS_UTILITY.format_error_backtrace,
                            1,
                            500);
                    ikis_rbm.rdm$log_packet.insert_message (
                        p_lp_pkt       => rr_ppr.pkt_id,
                        p_lp_comment   => l_err_msg);
            --raise;
            END;

            COMMIT;
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'RunProcessPPR:'
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END RunProcessPPR;


    -- Процедура обробки КВ-1/2
    PROCEDURE ProcessKV (p_pkt_id IN NUMBER)
    IS
        l_pkt_pat   NUMBER;
    BEGIN
        SELECT MAX (pkt_pat)
          INTO l_pkt_pat
          FROM ikis_rbm.v_packet p
         WHERE 1 = 1 AND pkt_st = 'N' AND pkt_id = p_pkt_id;

        IF l_pkt_pat = 102                                             -- KV-1
        THEN
            proc_pca_pkt (p_pkt_id => p_pkt_id);
        ELSIF l_pkt_pat = 103                                          -- KV-2
        THEN
            proc_ppr_pkt (p_pkt_id => p_pkt_id);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'ProcessKV:'
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END ProcessKV;


    -- #81531 Формування відомостей на Поштув електронному вигляді по 6 допомогам
    PROCEDURE BuildPostFiles (p_pr_ids IN VARCHAR2, p_rpt IN OUT BLOB)
    AS
        p_asopd       VARCHAR2 (10) := '';
        --l_files         ikis_sysweb.some_files := ikis_sysweb.some_files();
        l_pr_files    ikis_sysweb.tbl_some_files
                          := ikis_sysweb.tbl_some_files ();
        l_txt_file    CLOB;
        l_zip_file    BLOB;
        l_rpt_file    BLOB;
        l_file_name   VARCHAR2 (250);
    BEGIN
        FOR pp
            IN (  SELECT pr_id,
                            'PR_'
                         || LPAD (p.com_org, 5, '0')
                         || '_'
                         || LPAD (c.npc_code, 2, '0')
                         || '_'
                         || pr_id    AS file_name
                    FROM payroll p
                         JOIN uss_ndi.v_ndi_payment_codes c
                             ON c.npc_id = p.pr_npc
                   WHERE     1 = 1
                         --        and pr_st = ''
                         AND pr_pay_tp = 'POST'                  --p_pr_pay_tp
                         AND pr_id IN
                                 (    SELECT REGEXP_SUBSTR (text,
                                                            '[^(\,)]+',
                                                            1,
                                                            LEVEL)    AS z_po_id
                                        FROM (SELECT p_pr_ids AS text FROM DUAL)
                                  CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                                    '[^(\,)]+',
                                                                    1,
                                                                    LEVEL)) > 0)
                ORDER BY 1)
        LOOP
            -- готуємо дані по ВВ
            DELETE FROM TMP_POST_TO_EXPORT;

            l_zip_file := GetPostFile (pp.pr_id);

            --  Формуємо архів файлів по ВВ
            IF l_zip_file IS NOT NULL
            THEN
                -------------l_zip_file :=  ikis_sysweb.ikis_web_jutil.getZipFromStrms(l_files);
                l_pr_files.EXTEND;
                l_pr_files (l_pr_files.LAST) :=
                    ikis_sysweb.t_some_file_info (pp.file_name || '.zip',
                                                  l_zip_file);
            END IF;
        END LOOP;

        --  Формуємо підсумковий архів файлів по всіх вибраних ВВ
        IF l_pr_files.COUNT > 0
        THEN
            p_rpt := ikis_sysweb.ikis_web_jutil.getZipFromStrms (l_pr_files);
        ELSE
            RAISE NO_DATA_FOUND;                                     -- #85237
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20001,
                'Відсутня інформація для побудови файлу електронних відомостей на пошту');
        WHEN OTHERS
        THEN
            IF SQLCODE IN (-20001)
            THEN
                RAISE;
            END IF;

            raise_application_error (
                -20000,
                   'Помилка підготовки даних для побудови файлу електронних відомостей на пошту: '
                || CHR (10)
                || SQLERRM
                || DBMS_UTILITY.format_error_backtrace);
    END BuildPostFiles;

    -- IC #98707 Пакетна обробка відомостей на пошту по типу відомості
    PROCEDURE BuildPostFiles (p_pr_ids     IN     VARCHAR2,
                              p_pkt_type   IN     VARCHAR2 := '80',
                              o_rpt           OUT BLOB)
    IS
        l_pr_files   ikis_sysweb.tbl_some_files
                         := ikis_sysweb.tbl_some_files ();
        l_rpt_file   BLOB;

        l_xdata      CLOB;
        l_pp_sum     NUMBER;
        l_pp_cnt     NUMBER;
    BEGIN
        FOR pp
            IN (  SELECT pr_id,
                            'PR_'
                         || LPAD (p.com_org, 5, '0')
                         || '_'
                         || LPAD (c.npc_code, 2, '0')
                         || '_'
                         || pr_id
                             AS file_name,
                         LPAD (c.npc_code, 2, '0')
                             npc_code,
                         SUBSTR (TRIM (TO_CHAR (org_id, '000009')), 1, 3)
                             p_opfu,
                         SUBSTR (
                             REPLACE (org_name, 'Головне управління ', 'ГУ'),
                             1,
                             27)
                             p_opfu_name,
                         c.npc_name
                             p_pr_header,
                         org_id
                             p_org_id,
                         TOOLS.GetOrgSName (org_id)
                             p_org_name,
                         pr_create_dt
                             p_pr_dt,
                         pr_start_dt
                    FROM payroll p
                         JOIN v_opfu ON org_id = com_org
                         JOIN uss_ndi.v_ndi_payment_codes c
                             ON c.npc_id = p.pr_npc
                   WHERE     pr_pay_tp = 'POST'
                         AND pr_id IN
                                 (    SELECT REGEXP_SUBSTR (text,
                                                            '[^(\,)]+',
                                                            1,
                                                            LEVEL)    AS z_po_id
                                        FROM (SELECT p_pr_ids AS text FROM DUAL)
                                  CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                                    '[^(\,)]+',
                                                                    1,
                                                                    LEVEL)) > 0)
                ORDER BY 1)
        LOOP
            l_pp_cnt := NULL;
            l_pp_sum := NULL;
            l_rpt_file := NULL;

            API$ESR_EXCHANGE.BuildPostExchFiles (pp.pr_id,
                                                 pp.npc_code,
                                                 'F',
                                                 l_rpt_file);

            SELECT COUNT (*) x_cnt, SUM (s.t_pp_sum) x_sum
              INTO l_pp_cnt, l_pp_sum
              FROM TMP_POST_TO_EXPORT s;

            SELECT XMLELEMENT (
                       "paymentlists",
                       XMLELEMENT ("id", pp.pr_id),
                       XMLELEMENT ("opfu_code", pp.p_org_id),
                       XMLELEMENT ("opfu_name",
                                   CONVERT (pp.p_org_name, 'UTF8')),
                       XMLELEMENT ("date_cr",
                                   TO_CHAR (pp.p_pr_dt, 'DDMMYYYY')),
                       XMLELEMENT ("MFO_filia", ''),
                       XMLELEMENT ("filia_num", ''),
                       XMLELEMENT ("filia_name", ''),
                       XMLELEMENT ("full_sum", l_pp_sum),
                       XMLELEMENT ("full_lines", l_pp_cnt),
                       XMLELEMENT ("type", pp.npc_code),
                       XMLELEMENT ("id_cor", ''),
                       XMLELEMENT (
                           "files_data",
                           tools.ConvertBlobToBase64 (
                               UTL_COMPRESS.lz_compress (l_rpt_file))),
                       XMLELEMENT ("ecp_list", XMLELEMENT ("ecp", ''))).getClobVal ()
              INTO l_xdata
              FROM DUAL;

            l_rpt_file := tools.ConvertC2B (l_xdata);

            --  Формуємо архів файлів по ВВ
            IF l_rpt_file IS NOT NULL
            THEN
                l_pr_files.EXTEND;
                l_pr_files (l_pr_files.LAST) :=
                    ikis_sysweb.t_some_file_info (pp.file_name || '.xml',
                                                  l_rpt_file);
            END IF;
        END LOOP;

        --  Формуємо підсумковий архів файлів по всіх вибраних ВВ
        IF l_pr_files.COUNT > 0
        THEN
            o_rpt := ikis_sysweb.ikis_web_jutil.getZipFromStrms (l_pr_files);
        ELSE
            RAISE NO_DATA_FOUND;
        END IF;
    /*
        o_rpt := tools.toZip2(  p_file_blob => tools.ConvertC2B(l_xdata),
                                p_file_name => 'description_files.xml' );
    */
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20001,
                'Відсутня інформація для побудови файлу електронних відомостей на пошту');
        WHEN OTHERS
        THEN
            IF SQLCODE IN (-20001)
            THEN
                RAISE;
            END IF;

            raise_application_error (
                -20000,
                   'Помилка підготовки даних для побудови файлу електронних відомостей на пошту: '
                || CHR (10)
                || SQLERRM
                || DBMS_UTILITY.format_error_backtrace);
    END BuildPostFiles;

    -- IC #110218 Вивантаження файлів для пошти з Платіжної інструкції
    PROCEDURE BuildPostFilesPO (p_po_ids IN VARCHAR2, o_rpt OUT BLOB)
    IS
        l_pr_files   ikis_sysweb.tbl_some_files
                         := ikis_sysweb.tbl_some_files ();
        l_rpt_file   BLOB;

        l_xdata      CLOB;
        l_pp_sum     NUMBER;
        l_pp_cnt     NUMBER;
    BEGIN
        DELETE FROM tmp_work_set1
              WHERE 1 = 1;

        INSERT INTO tmp_work_set1 (x_id1, x_id2)
            SELECT s.prs_id, s.prs_pr
              FROM uss_esr.pay_order  p
                   JOIN uss_esr.payroll_reestr r ON r.pe_po = p.po_id
                   JOIN uss_esr.payroll pr ON pr.pr_id = r.pe_src_entity
                   JOIN uss_esr.pr_sheet s ON s.prs_pr = pr.pr_id
             WHERE     1 = 1
                   AND s.prs_pay_dt = r.pe_pay_dt
                   AND s.prs_index = r.pe_filia_code
                   AND po_id IN
                           (    SELECT REGEXP_SUBSTR (text,
                                                      '[^(\,)]+',
                                                      1,
                                                      LEVEL)    AS z_po_id
                                  FROM (SELECT p_po_ids AS text FROM DUAL)
                            CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                              '[^(\,)]+',
                                                              1,
                                                              LEVEL)) > 0);

        FOR pp
            IN (  SELECT pr_id,
                            'PR_'
                         || LPAD (p.com_org, 5, '0')
                         || '_'
                         || LPAD (c.npc_code, 2, '0')
                         || '_'
                         || pr_id
                             AS file_name,
                         LPAD (c.npc_code, 2, '0')
                             npc_code,
                         SUBSTR (TRIM (TO_CHAR (org_id, '000009')), 1, 3)
                             p_opfu,
                         SUBSTR (
                             REPLACE (org_name, 'Головне управління ', 'ГУ'),
                             1,
                             27)
                             p_opfu_name,
                         c.npc_name
                             p_pr_header,
                         org_id
                             p_org_id,
                         TOOLS.GetOrgSName (org_id)
                             p_org_name,
                         pr_create_dt
                             p_pr_dt,
                         pr_start_dt
                    FROM payroll p
                         JOIN v_opfu ON org_id = com_org
                         JOIN uss_ndi.v_ndi_payment_codes c
                             ON c.npc_id = p.pr_npc
                   WHERE     pr_pay_tp = 'POST'
                         AND pr_id IN (SELECT DISTINCT x_id2
                                         FROM tmp_work_set1)
                ORDER BY 1)
        LOOP
            l_pp_cnt := NULL;
            l_pp_sum := NULL;
            l_rpt_file := NULL;

            API$ESR_EXCHANGE.BuildPostExchFiles (pp.pr_id,
                                                 pp.npc_code,
                                                 'F',
                                                 l_rpt_file);

            SELECT COUNT (*) x_cnt, SUM (s.t_pp_sum) x_sum
              INTO l_pp_cnt, l_pp_sum
              FROM TMP_POST_TO_EXPORT s;

            SELECT XMLELEMENT (
                       "paymentlists",
                       XMLELEMENT ("id", pp.pr_id),
                       XMLELEMENT ("opfu_code", pp.p_org_id),
                       XMLELEMENT ("opfu_name",
                                   CONVERT (pp.p_org_name, 'UTF8')),
                       XMLELEMENT ("date_cr",
                                   TO_CHAR (pp.p_pr_dt, 'DDMMYYYY')),
                       XMLELEMENT ("MFO_filia", ''),
                       XMLELEMENT ("filia_num", ''),
                       XMLELEMENT ("filia_name", ''),
                       XMLELEMENT ("full_sum", l_pp_sum),
                       XMLELEMENT ("full_lines", l_pp_cnt),
                       XMLELEMENT ("type", pp.npc_code),
                       XMLELEMENT ("id_cor", ''),
                       XMLELEMENT (
                           "files_data",
                           tools.ConvertBlobToBase64 (
                               UTL_COMPRESS.lz_compress (l_rpt_file))),
                       XMLELEMENT ("ecp_list", XMLELEMENT ("ecp", ''))).getClobVal ()
              INTO l_xdata
              FROM DUAL;

            l_rpt_file := tools.ConvertC2B (l_xdata);

            --  Формуємо архів файлів по ВВ
            IF l_rpt_file IS NOT NULL
            THEN
                l_pr_files.EXTEND;
                l_pr_files (l_pr_files.LAST) :=
                    ikis_sysweb.t_some_file_info (pp.file_name || '.xml',
                                                  l_rpt_file);
            END IF;
        END LOOP;

        --  Формуємо підсумковий архів файлів по всіх вибраних ВВ
        IF l_pr_files.COUNT > 0
        THEN
            o_rpt := ikis_sysweb.ikis_web_jutil.getZipFromStrms (l_pr_files);
        ELSE
            RAISE NO_DATA_FOUND;
        END IF;
    /*
        o_rpt := tools.toZip2(  p_file_blob => tools.ConvertC2B(l_xdata),
                                p_file_name => 'description_files.xml' );
    */
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20001,
                'Відсутня інформація для побудови файлу електронних відомостей на пошту');
        WHEN OTHERS
        THEN
            IF SQLCODE IN (-20001)
            THEN
                RAISE;
            END IF;

            raise_application_error (
                -20000,
                   'Помилка підготовки даних для побудови файлу електронних відомостей на пошту: '
                || CHR (10)
                || SQLERRM
                || DBMS_UTILITY.format_error_backtrace);
    END BuildPostFilesPO;

    --  #81330 Формування відомостей на банк в електронному вигляді по 6 допомогам
    --  Без запису в ПЕОД, фактично це звіт...
    PROCEDURE BuildBankFiles (p_pr_ids                VARCHAR2,
                              p_convert_symb          VARCHAR2 DEFAULT 'T',
                              p_rpt            IN OUT BLOB)
    IS
        l_filter            VARCHAR2 (250);
        l_ecs               exchcreatesession.ecs_id%TYPE;
        l_cnt               INTEGER;
        l_pkt               NUMBER (14);
        --l_acc_length number := case when nvl(tools.GP('USE_IBAN',sysdate), 'F') = 'T' then 29 else 19 end; -- #45558 20190702
        l_use_iban          VARCHAR2 (10) := 'T'; ---parammil.prm_value%TYPE := nvl(tools.GP('USE_IBAN',sysdate), 'F');
        l_acc_length_head   NUMBER;
        l_acc_length_rows   NUMBER;
        l_row_fill          VARCHAR2 (1);
        l_pr_code           VARCHAR2 (10);
        l_pr_name           VARCHAR2 (250);
        l_pr_type           VARCHAR2 (10);
        l_pkt_cor           NUMBER;
        l_pay_dt            DATE;
        l_ef_pr_pr          NUMBER;
        l_pr_pc_cnt         NUMBER;
        l_exch_version      VARCHAR2 (10) := 'V002'; --parammil.prm_value%TYPE := nvl(tools.GP('EXCH_VERSION',sysdate), 'V001');
        exNoReestr          EXCEPTION;
        exBadVer4Cor        EXCEPTION;
        l_rbm_pkt_cnt       NUMBER;
        l_npc_id            NUMBER;
        l_files             ikis_sysweb.tbl_some_files
                                := ikis_sysweb.tbl_some_files ();
        l_pr_files          ikis_sysweb.tbl_some_files
                                := ikis_sysweb.tbl_some_files ();
        l_txt_file          CLOB;
        l_zip_file          BLOB;
        l_rpt_file          BLOB;
        l_file_name         VARCHAR2 (250);
        l_pr_id             NUMBER;
    BEGIN
        /*  -- 4 test
          delete from tmp_bnk_to_export;
          delete from tmp_exchangefiles_m1;
        */
        l_acc_length_head := CASE WHEN l_use_iban = 'T' THEN 29 ELSE 9 END;
        l_acc_length_rows := CASE WHEN l_use_iban = 'T' THEN 29 ELSE 19 END;
        l_row_fill := CASE WHEN l_use_iban = 'T' THEN '0' ELSE ' ' END;

        FOR pp
            IN (  SELECT pr_id, -- #85694  'PR_'||lpad(p.com_org, 5, '0')||'_'||c.npc_code||'_'||pr_id  as file_name,
                            c.npc_code
                         || '_'
                         || 'PR_'
                         || LPAD (p.com_org, 5, '0')
                         || '_'
                         || pr_id    AS file_name,
                         c.npc_code                                 --  #85694
                    FROM payroll p
                         JOIN uss_ndi.v_ndi_payment_codes c
                             ON c.npc_id = p.pr_npc
                   WHERE     1 = 1
                         --        and pr_st = ''
                         AND pr_pay_tp = 'BANK'                  --p_pr_pay_tp
                         AND pr_id IN
                                 (    SELECT REGEXP_SUBSTR (text,
                                                            '[^(\,)]+',
                                                            1,
                                                            LEVEL)    AS z_po_id
                                        FROM (SELECT p_pr_ids AS text FROM DUAL)
                                  CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                                    '[^(\,)]+',
                                                                    1,
                                                                    LEVEL)) > 0)
                ORDER BY 1)
        LOOP
            -- контроль на ПД по всіх списках
            SELECT COUNT (1)
              INTO l_cnt
              FROM payroll_reestr
             WHERE pe_pr = pp.pr_id AND pe_po IS NULL;

            /*     #86973  TN прибери поки що, якщо немає прив'язки до ПД може, в електронному виді і не треба буде
                if l_cnt > 0 then
                  l_pr_id := pp.pr_id;
                  raise exNoReestr;
                end if;*/


            l_files := ikis_sysweb.tbl_some_files ();                -- #86411

            SELECT c.npc_code,                               /*'ПВП ДКГ: '||*/
                   c.npc_name,
                   NULL    AS pr_pay_dt, -- #66415 Доработка функции "Формирование електронных ведомосте":
                   CASE
                       WHEN pr_tp = 'M'               /*or t.npt_code = '01'*/
                                        THEN '01'
                       WHEN pr_tp = 'C'              /*or t.npt_code = '103'*/
                                        THEN '03'
                       -- when pr_tp = 'O' then /*'04'  #68539 */ substr(t.npt_code, -2)
                       ELSE '02'
                   END     AS pr_type,
                   pr_pc_cnt,
                   c.npc_id
              INTO l_pr_code,
                   l_pr_name,
                   l_pay_dt,
                   l_pr_type,
                   l_pr_pc_cnt,
                   l_npc_id
              FROM payroll  p
                   JOIN uss_ndi.v_ndi_payment_codes c ON c.npc_id = p.pr_npc
             WHERE pr_id = pp.pr_id;

            -- готуємо дані по ВВ
            DELETE FROM TMP_BANK_TO_EXPORT;

            INSERT INTO TMP_BANK_TO_EXPORT (X_NB_ID,
                                            X_NB_NUMBER,
                                            X_NB_FILIA,
                                            X_PRS_PAY_DT,
                                            X_PRS_ACCOUNT,
                                            X_PRS_SUM,
                                            X_PRS_PIB,
                                            X_PRS_INN,
                                            X_NB_MFO,
                                            X_NB_MAIN_CODE,
                                            X_OPFU,
                                            X_PRS_NUM,
                                            X_REC,
                                            X_IS_MIGR,
                                            X_PC_NUM,
                                            X_COR_RSN,
                                            X_NB_NAME,
                                            x_last_name,
                                            x_first_name,
                                            x_second_name)
                SELECT nb_id,
                       NVL (X_NB_NUMBER, X_NB_MAIN_CODE)     AS x_nb_number, --  io 20230112 #83041
                       x_nb_filia,
                       x_pay_dt,
                       prs_account,
                       prs_sum,
                       x_prs_pib,
                       prs_inn,
                       nb_mfo,
                       x_nb_main_code,
                       x_opfu,
                       1                                     AS prs_num,
                       x_rec, -- io 20220727  prs_num не є номер списку. це №п.п.
                       x_is_migr,
                       x_pc_number,
                       x_prs_cor_rsn,
                       nb_name,
                       prs_ln,
                       prs_fn,
                       prs_mn
                  FROM (-- IC #95535  прибрати пошук та переназначення головного банку
                        --      SELECT  nvl(b0.nb_id, b.nb_id) as nb_id, prs_num,
                        SELECT nb_id,
                               prs_num,
                               TRUNC (s.prs_pay_dt, 'MM') + 5
                                   AS x_pay_dt, -- #85785 io 20230329 зводимо до 1 дня виплати
                               --        LPAD(nvl(b0.nb_num, b.nb_num), 5, '0') x_nb_number,  -- -- #86340  b.nb_num
                               LPAD (nb_num, 5, '0')
                                   x_nb_number,         -- -- #86340  b.nb_num
                               NULL
                                   AS x_nb_filia,
                               --        LPAD( nvl(b0.nb_mfo, b.nb_mfo) , 9, '0') nb_mfo,
                               LPAD (nb_mfo, 9, '0')
                                   nb_mfo,
                               LPAD (NVL (TRIM (prs_account), 0),       /*19*/
                                                                  29 /*l_acc_length_rows*/
                                                                    , '0')
                                   prs_account,
                               TRIM (
                                   prs_ln || ' ' || prs_fn || ' ' || prs_mn)
                                   x_prs_pib,
                               prs_sum,
                               prs_pc_num,
                               NVL (
                                   CASE
                                       WHEN TRIM (
                                                TRANSLATE (prs_inn,
                                                           '0123456789',
                                                           ' '))
                                                IS NULL
                                       THEN
                                           LPAD (prs_inn, 10, '0')
                                       ELSE
                                           '0000000000'
                                   END,
                                   '0000000000')
                                   prs_inn,
                               /*null*/
                               --        nvl(b0.nb_num, b.nb_num) as x_nb_main_code,
                               nb_num
                                   AS x_nb_main_code,
                               SUBSTR (TRIM (TO_CHAR (pr.com_org, '000009')),
                                       -3                             /*1, 3*/
                                         )
                                   AS x_opfu,
                               ----------TRIM(to_char(pr.com_org, '00009')) AS x_opfu,
                                (SELECT rec_id
                                   FROM ikis_rbm.v_recipient r
                                  --        where r.rec_nb = nvl(b0.nb_id, b.nb_id)) as x_rec,
                                  WHERE r.rec_nb = nb_id)
                                   AS x_rec,
                               ''
                                   AS x_is_migr,
                               prs_pc_num
                                   AS x_pc_number,       --#66415  12 символів
                               NULL
                                   AS x_prs_cor_rsn,
                               --        nvl(b0.nb_name, b.nb_name) nb_name,
                               nb_name,
                               prs_ln,
                               prs_fn,
                               prs_mn
                          FROM payroll  pr
                               JOIN pr_sheet s ON pr_id = prs_pr
                               JOIN uss_ndi.v_ndi_bank b
                                   ON s.prs_nb = b.nb_id
                         --left join uss_ndi.v_ndi_bank b0 on b.nb_nb = b0.nb_id
                         WHERE     pr_id = pp.pr_id
                               AND pr_pay_tp = 'BANK'
                               ---AND nvl(b0.nb_id, b.nb_id) = bb.x_nb_id
                               AND prs_tp IN ('PB', 'ABP', 'OTP')
                               AND prs_st = 'NA' --  io 20221023  лише статус нараховано, виключаємо блокування вручну і т.д.
                               AND prs_sum                              /*!=*/
                                           > 0                       -- #85724
                               AND PRS_tp IN ('PB'));

            --   return;

            -- визначаємо код філії/відділення
            UPDATE TMP_BANK_TO_EXPORT t
               SET t.x_nb_filia =
                       (SELECT LPAD (MAX (LTRIM (a.dppa_nb_filia_num, '/')),
                                     5,
                                     '0')
                          FROM payroll_reestr              r,
                               pay_order                   po,
                               uss_ndi.ndi_pay_person_acc  a
                         WHERE     1 = 1
                               AND r.pe_pr = pp.pr_id
                               AND r.pe_nb = t.x_nb_id
                               --- тут дата обрізана до 05.*** and r.pe_pay_dt =
                               AND r.pe_po = po_id
                               AND a.dppa_id = po_dppa_recipient)
             WHERE     1 = 1
                   AND t.x_nb_filia IS NULL
                   AND EXISTS
                           (SELECT 1
                              FROM payroll_reestr              r,
                                   pay_order                   po,
                                   uss_ndi.ndi_pay_person_acc  a
                             WHERE     1 = 1
                                   AND r.pe_pr = pp.pr_id
                                   AND r.pe_nb = t.x_nb_id
                                   --- тут дата обрізана до 05.*** and r.pe_pay_dt =
                                   AND r.pe_po = po_id
                                   AND a.dppa_id = po_dppa_recipient);

            --  #86973 TN: писати, якщо немає прив'язки до ПД, просто 0 в якості філії
            UPDATE TMP_BANK_TO_EXPORT t
               SET t.x_nb_filia = '00000'
             WHERE 1 = 1 AND t.x_nb_filia IS NULL;

            -- формуємо файли по банках та днях виплати з ВВ
            FOR bb
                IN (  SELECT t.x_nb_id,
                             t.x_prs_pay_dt,
                             COUNT (1)                       AS x_cnt,
                             SUM (t.x_prs_sum)               AS x_sum,
                             -- поки не треба   pp.npc_code||'_'
                             /*               max(tools.PR(x_nb_number, 5)||
                                                tools.PR(x_nb_number\*x_nb_filia*\, 5)|| -- #82683 io 20230102  номер підзвітної філії - такий самий як центральної філії
                                                tools.PR(x_prs_pay_dt, 2)||'.'||
                                                tools.PR(x_opfu,3)) as x_file_name*/
                             ---max(tools.PR(substr(x_nb_mfo, -6), 6)||'0000'||lpad(l_pr_code, 2, '0')||'.'||tools.PR(x_opfu,3)) as x_file_name
                             MAX (
                                    tools.PR (x_nb_number, 5)
                                 || tools.PR (NVL (x_nb_filia, x_nb_number), 5)
                                 || -- #82683 io 20230102  номер підзвітної філії - такий самий як центральної філії
                                    tools.PR (x_prs_pay_dt, 2)
                                 || '.'
                                 || tools.PR (x_opfu, 3))    AS x_file_name -- #86609
                        FROM TMP_BANK_TO_EXPORT t
                    --where t.
                    GROUP BY t.x_nb_id, t.x_prs_pay_dt
                    ORDER BY 1, 2)
            LOOP
                /*      dbms_output.put_line('pp.pr_id='||pp.pr_id||' bb.x_nb_id='||bb.x_nb_id||' bb.x_prs_pay_dt='||to_char(bb.x_prs_pay_dt, 'dd.mm.yyyy')||
                                           ' bb.x_cnt='||bb.x_nb_id||' bb.x_sum='||bb.x_sum) ;*/
                --l_file_name  := substr(coalesce(p_file_row.t_npo_index,'_____'), -5, 5)||p_file_row.t_ved_tp||lpad(to_char(p_file_row.t_per_num),2,'0')||substr(p_file_row.t_org_code,-5,5)||'.txt';
                l_txt_file :=
                    GetFiliaFile (p_pr_id          => pp.pr_id,
                                  p_nb_id          => bb.x_nb_id,
                                  p_prs_pay_dt     => bb.x_prs_pay_dt,
                                  p_bnk_cnt        => bb.x_cnt,
                                  p_bnk_sum        => bb.x_sum * 100,
                                  p_convert_symb   => p_convert_symb,
                                  p_pr_code        => l_pr_code);

                -- dbms_output.put_line(dbms_lob.substr(l_txt_file,1000,1) /*l_txt_file*/);

                -- додаємо до колекції файлів по ВВ
                IF l_txt_file IS NOT NULL
                THEN
                    l_files.EXTEND;
                    l_files (l_files.LAST) :=
                        ikis_sysweb.t_some_file_info (
                            bb.x_file_name,
                            tools.ConvertC2B (l_txt_file));
                END IF;
            END LOOP;

            --  Формуємо архів файлів по ВВ
            IF l_files.COUNT > 0
            THEN
                l_zip_file :=
                    ikis_sysweb.ikis_web_jutil.getZipFromStrms (l_files);
                l_pr_files.EXTEND;
                l_pr_files (l_pr_files.LAST) :=
                    ikis_sysweb.t_some_file_info (pp.file_name || '.zip',
                                                  l_zip_file);
            END IF;
        END LOOP;

        --  Формуємо підсумковий архів файлів по всіх вибраних ВВ
        IF l_pr_files.COUNT > 0
        THEN
            p_rpt := ikis_sysweb.ikis_web_jutil.getZipFromStrms (l_pr_files);
        ELSE
            RAISE NO_DATA_FOUND;                                     -- #85237
        END IF;
    EXCEPTION
        WHEN exNoReestr
        THEN
            raise_application_error (
                -20000,
                   'Помилка підготовки даних по ВВ ід = '
                || l_pr_id
                || ': не для всіх списків відомості вдалося визначити ПД з реєстру відомостей');
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20001,
                'Відсутня інформація для побудови файлу електронних відомостей на банк');
        --  when exNoPkt4Cor then
        --    raise_application_error(-20000, 'Помилка формування файлів для електронного обміну : Для коригуючої відомості не вдалося визначити ід пакета ПЕОД відповідної породжуючої відоості!');
        WHEN exBadVer4Cor
        THEN
            raise_application_error (
                -20000,
                'Помилка формування файлів для електронного обміну : В даній версії ПЗ не підтримується формування пакетів ПЕОД для коригуючих відомостей!');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка формування файлів для електронного обміну : '
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;

    PROCEDURE BuildBankFiles_00 (
        p_pr_ids                VARCHAR2,
        p_convert_symb          VARCHAR2 DEFAULT 'T',
        p_rpt            IN OUT BLOB)
    IS
        l_filter            VARCHAR2 (250);
        l_ecs               exchcreatesession.ecs_id%TYPE;
        l_cnt               INTEGER;
        l_pkt               NUMBER (14);
        --l_acc_length number := case when nvl(tools.GP('USE_IBAN',sysdate), 'F') = 'T' then 29 else 19 end; -- #45558 20190702
        l_use_iban          VARCHAR2 (10) := 'T'; ---parammil.prm_value%TYPE := nvl(tools.GP('USE_IBAN',sysdate), 'F');
        l_acc_length_head   NUMBER;
        l_acc_length_rows   NUMBER;
        l_row_fill          VARCHAR2 (1);
        l_pr_code           VARCHAR2 (10);
        l_pr_name           VARCHAR2 (250);
        l_pr_type           VARCHAR2 (10);
        l_pkt_cor           NUMBER;
        l_pay_dt            DATE;
        l_ef_pr_pr          NUMBER;
        l_pr_pc_cnt         NUMBER;
        l_exch_version      VARCHAR2 (10) := 'V002'; --parammil.prm_value%TYPE := nvl(tools.GP('EXCH_VERSION',sysdate), 'V001');
        exNoPkt4Cor         EXCEPTION;
        exBadVer4Cor        EXCEPTION;
        l_rbm_pkt_cnt       NUMBER;
        l_npc_id            NUMBER;
        l_files             ikis_sysweb.tbl_some_files
                                := ikis_sysweb.tbl_some_files ();
        l_pr_files          ikis_sysweb.tbl_some_files
                                := ikis_sysweb.tbl_some_files ();
        l_txt_file          CLOB;
        l_zip_file          BLOB;
        l_rpt_file          BLOB;
        l_file_name         VARCHAR2 (250);
    BEGIN
        /*  -- 4 test
          delete from tmp_bnk_to_export;
          delete from tmp_exchangefiles_m1;
        */
        l_acc_length_head := CASE WHEN l_use_iban = 'T' THEN 29 ELSE 9 END;
        l_acc_length_rows := CASE WHEN l_use_iban = 'T' THEN 29 ELSE 19 END;
        l_row_fill := CASE WHEN l_use_iban = 'T' THEN '0' ELSE ' ' END;

        FOR pp
            IN (  SELECT pr_id, -- #85694  'PR_'||lpad(p.com_org, 5, '0')||'_'||c.npc_code||'_'||pr_id  as file_name,
                            c.npc_code
                         || '_'
                         || 'PR_'
                         || LPAD (p.com_org, 5, '0')
                         || '_'
                         || pr_id    AS file_name,
                         c.npc_code                                 --  #85694
                    FROM payroll p
                         JOIN uss_ndi.v_ndi_payment_codes c
                             ON c.npc_id = p.pr_npc
                   WHERE     1 = 1
                         --        and pr_st = ''
                         AND pr_pay_tp = 'BANK'                  --p_pr_pay_tp
                         AND pr_id IN
                                 (    SELECT REGEXP_SUBSTR (text,
                                                            '[^(\,)]+',
                                                            1,
                                                            LEVEL)    AS z_po_id
                                        FROM (SELECT p_pr_ids AS text FROM DUAL)
                                  CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                                    '[^(\,)]+',
                                                                    1,
                                                                    LEVEL)) > 0)
                ORDER BY 1)
        LOOP
            SELECT c.npc_code,                               /*'ПВП ДКГ: '||*/
                   c.npc_name,
                   NULL    AS pr_pay_dt, -- #66415 Доработка функции "Формирование електронных ведомосте":
                   CASE
                       WHEN pr_tp = 'M'               /*or t.npt_code = '01'*/
                                        THEN '01'
                       WHEN pr_tp = 'C'              /*or t.npt_code = '103'*/
                                        THEN '03'
                       -- when pr_tp = 'O' then /*'04'  #68539 */ substr(t.npt_code, -2)
                       ELSE '02'
                   END     AS pr_type,
                   pr_pc_cnt,
                   c.npc_id
              INTO l_pr_code,
                   l_pr_name,
                   l_pay_dt,
                   l_pr_type,
                   l_pr_pc_cnt,
                   l_npc_id
              FROM payroll  p
                   JOIN uss_ndi.v_ndi_payment_codes c ON c.npc_id = p.pr_npc
             WHERE pr_id = pp.pr_id;

            -- готуємо дані по ВВ
            DELETE FROM TMP_BANK_TO_EXPORT;

            INSERT INTO TMP_BANK_TO_EXPORT (X_NB_ID,
                                            X_NB_NUMBER,
                                            X_NB_FILIA,
                                            X_PRS_PAY_DT,
                                            X_PRS_ACCOUNT,
                                            X_PRS_SUM,
                                            X_PRS_PIB,
                                            X_PRS_INN,
                                            X_NB_MFO,
                                            X_NB_MAIN_CODE,
                                            X_OPFU,
                                            X_PRS_NUM,
                                            X_REC,
                                            X_IS_MIGR,
                                            X_PC_NUM,
                                            X_COR_RSN,
                                            X_NB_NAME,
                                            x_last_name,
                                            x_first_name,
                                            x_second_name)
                SELECT nb_id,
                       NVL (X_NB_NUMBER, X_NB_MAIN_CODE)     AS x_nb_number, -- io 20230112 #83041
                       x_nb_filia,
                       x_pay_dt,
                       prs_account,
                       prs_sum,
                       x_prs_pib,
                       prs_inn,
                       nb_mfo,
                       x_nb_main_code,
                       x_opfu,
                       1                                     AS prs_num,
                       x_rec, -- io 20220727  prs_num не є номер списку. це №п.п.
                       x_is_migr,
                       x_pc_number,
                       x_prs_cor_rsn,
                       nb_name,
                       prs_ln,
                       prs_fn,
                       prs_mn
                  FROM (SELECT b.nb_id,
                               prs_num,
                               TRUNC (s.prs_pay_dt, 'MM') + 5
                                   AS x_pay_dt, -- #85785 io 20230329 зводимо до 1 дня виплати
                               LPAD (b.nb_num, 5, '0')
                                   x_nb_number,
                               NULL
                                   AS x_nb_filia,
                               LPAD (b.nb_mfo, 9, '0')
                                   nb_mfo,
                               LPAD (NVL (TRIM (prs_account), 0),       /*19*/
                                                                  29 /*l_acc_length_rows*/
                                                                    , '0')
                                   prs_account,
                               TRIM (
                                   prs_ln || ' ' || prs_fn || ' ' || prs_mn)
                                   x_prs_pib,
                               prs_sum,
                               prs_pc_num,
                               NVL (
                                   CASE
                                       WHEN TRIM (
                                                TRANSLATE (prs_inn,
                                                           '0123456789',
                                                           ' '))
                                                IS NULL
                                       THEN
                                           LPAD (prs_inn, 10, '0')
                                       ELSE
                                           '0000000000'
                                   END,
                                   '0000000000')
                                   prs_inn,
                               /*null*/
                               NVL (b0.nb_num, b.nb_num)
                                   AS x_nb_main_code,
                               SUBSTR (TRIM (TO_CHAR (pr.com_org, '000009')),
                                       -3                             /*1, 3*/
                                         )
                                   AS x_opfu,
                               ----------TRIM(to_char(pr.com_org, '00009')) AS x_opfu,
                                (SELECT rec_id
                                   FROM ikis_rbm.v_recipient r
                                  WHERE r.rec_nb = NVL (b0.nb_id, b.nb_id))
                                   AS x_rec,
                               ''
                                   AS x_is_migr,
                               prs_pc_num
                                   AS x_pc_number,       --#66415  12 символів
                               NULL
                                   AS x_prs_cor_rsn,
                               b.nb_name,
                               prs_ln,
                               prs_fn,
                               prs_mn
                          FROM payroll  pr
                               JOIN pr_sheet s ON pr_id = prs_pr
                               JOIN uss_ndi.v_ndi_bank b
                                   ON s.prs_nb = b.nb_id
                               LEFT JOIN uss_ndi.v_ndi_bank b0
                                   ON b.nb_nb = b0.nb_id
                         WHERE     pr_id = pp.pr_id
                               AND pr_pay_tp = 'BANK'
                               ---AND nvl(b0.nb_id, b.nb_id) = bb.x_nb_id
                               AND prs_tp IN ('PB', 'ABP', 'OTP')
                               AND prs_st = 'NA' --  io 20221023  лише статус нараховано, виключаємо блокування вручну і т.д.
                               AND prs_sum                              /*!=*/
                                           > 0                       -- #85724
                               AND PRS_tp IN ('PB'));

            --   return;
            -- формуємо файли по банках та днях виплати з ВВ
            FOR bb
                IN (  SELECT t.x_nb_id,
                             t.x_prs_pay_dt,
                             COUNT (1)                       AS x_cnt,
                             SUM (t.x_prs_sum)               AS x_sum,
                             -- поки не треба   pp.npc_code||'_'
                             MAX (
                                    tools.PR (x_nb_number, 5)
                                 || tools.PR (x_nb_number       /*x_nb_filia*/
                                                         , 5)
                                 || -- #82683 io 20230102  номер підзвітної філії - такий самий як центральної філії
                                    tools.PR (x_prs_pay_dt, 2)
                                 || '.'
                                 || tools.PR (x_opfu, 3))    AS x_file_name
                        FROM TMP_BANK_TO_EXPORT t
                    --where t.
                    GROUP BY t.x_nb_id, t.x_prs_pay_dt
                    ORDER BY 1, 2)
            LOOP
                /*      dbms_output.put_line('pp.pr_id='||pp.pr_id||' bb.x_nb_id='||bb.x_nb_id||' bb.x_prs_pay_dt='||to_char(bb.x_prs_pay_dt, 'dd.mm.yyyy')||
                                           ' bb.x_cnt='||bb.x_nb_id||' bb.x_sum='||bb.x_sum) ;*/
                --l_file_name  := substr(coalesce(p_file_row.t_npo_index,'_____'), -5, 5)||p_file_row.t_ved_tp||lpad(to_char(p_file_row.t_per_num),2,'0')||substr(p_file_row.t_org_code,-5,5)||'.txt';
                l_txt_file :=
                    GetFiliaFile (p_pr_id          => pp.pr_id,
                                  p_nb_id          => bb.x_nb_id,
                                  p_prs_pay_dt     => bb.x_prs_pay_dt,
                                  p_bnk_cnt        => bb.x_cnt,
                                  p_bnk_sum        => bb.x_sum * 100,
                                  p_convert_symb   => p_convert_symb,
                                  p_pr_code        => l_pr_code);

                -- dbms_output.put_line(dbms_lob.substr(l_txt_file,1000,1) /*l_txt_file*/);

                -- додаємо до колекції файлів по ВВ
                IF l_txt_file IS NOT NULL
                THEN
                    l_files.EXTEND;
                    l_files (l_files.LAST) :=
                        ikis_sysweb.t_some_file_info (
                            bb.x_file_name,
                            tools.ConvertC2B (l_txt_file));
                END IF;
            END LOOP;

            --  Формуємо архів файлів по ВВ
            IF l_files.COUNT > 0
            THEN
                l_zip_file :=
                    ikis_sysweb.ikis_web_jutil.getZipFromStrms (l_files);
                l_pr_files.EXTEND;
                l_pr_files (l_pr_files.LAST) :=
                    ikis_sysweb.t_some_file_info (pp.file_name || '.zip',
                                                  l_zip_file);
            END IF;
        END LOOP;

        --  Формуємо підсумковий архів файлів по всіх вибраних ВВ
        IF l_pr_files.COUNT > 0
        THEN
            p_rpt := ikis_sysweb.ikis_web_jutil.getZipFromStrms (l_pr_files);
        ELSE
            RAISE NO_DATA_FOUND;                                     -- #85237
        END IF;
    EXCEPTION
        WHEN exNoPkt4Cor
        THEN
            raise_application_error (
                -20000,
                'Помилка формування файлів для електронного обміну : Для коригуючої відомості не вдалося визначити ід пакета ПЕОД відповідної породжуючої відоості!');
        WHEN exBadVer4Cor
        THEN
            raise_application_error (
                -20000,
                'Помилка формування файлів для електронного обміну : В даній версії ПЗ не підтримується формування пакетів ПЕОД для коригуючих відомостей!');
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Помилка формування файлів для електронного обміну : '
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;

    -- IC #98707 Формування пакету по виплаті по пошті
    PROCEDURE BuildPostExchFiles (p_pr_id          payroll.pr_id%TYPE,
                                  p_prs_tp         pr_sheet.prs_tp%TYPE:= 'PP',
                                  p_convert_symb   VARCHAR2:= 'F')
    IS
        l_pkt_type      VARCHAR2 (10) := '78';
        l_filter        VARCHAR2 (250);
        l_ecs           exchcreatesession.ecs_id%TYPE;
        l_cnt           INTEGER;
        l_pp_sum        NUMBER;
        l_pp_cnt        NUMBER;
        l_per_num       TMP_POST_TO_EXPORT.t_per_num%TYPE;
        l_npc_id        NUMBER;
        l_pr_code       uss_ndi.v_ndi_payment_codes.npc_code%TYPE;
        l_pr_name       VARCHAR2 (256);
        l_visual_data   CLOB;

        l_rpt           CLOB;

        PROCEDURE create_temp_data
        AS
        BEGIN
            DELETE FROM TMP_POST_TO_EXPORT
                  WHERE 1 = 1;

            INSERT INTO TMP_POST_TO_EXPORT (T_ORG_CODE,
                                            T_PER_NUM,
                                            T_DAY_START,
                                            T_DAY_STOP,
                                            T_PER_MONTH,
                                            T_PER_YEAR,
                                            T_VED_TP,
                                            T_PAY_TP,
                                            T_NCN_CODE,
                                            t_npo_index,
                                            T_PRS_NUM,
                                            T_PC_NUMBER,
                                            T_PC_PIB,
                                            T_PP_DAY,
                                            T_PP_SUM,
                                            T_PP_SUM_POST,
                                            T_ADR,
                                            T_UL_NAME,
                                            T_UL_CODE,
                                            T_DLVR_TP,
                                            T_DLVR_CODE,
                                            T_RBM_REC,
                                            T_PRS_ID,
                                            T_PR_ID,
                                            T_PP_DATE,
                                            T_NCN_ID,
                                            T_NPO_ID,
                                            T_PRS_PC,
                                            T_ADR_ID,
                                            T_DOC_SER,
                                            T_DOC_NUM,
                                            T_IS_POA)
                  SELECT op.org_code
                             t_org_code,
                         MAX (
                             (SELECT NVL (COUNT (1), 0) + 1
                                FROM payroll p2
                               WHERE     p2.pr_month = p.pr_month
                                     AND p2.com_org = p.com_org
                                     AND p2.pr_npc = p.pr_npc
                                     AND p2.pr_pay_tp = p.pr_pay_tp
                                     AND p2.pr_create_dt < p.pr_create_dt))
                             t_per_num,
                         4                                     /*pr_start_dt*/
                             t_day_start,
                         25                                     /*pr_stop_dt*/
                             t_day_stop,
                         TO_CHAR (pr_start_dt, 'mm')
                             t_per_month,
                         TO_CHAR (pr_start_dt, 'yyyy')
                             t_per_year,
                         LPAD (npc.npc_code, 2, '0')
                             t_ved_tp,
                         '01'
                             t_pay_tp,
                         '01'
                             ncn_code,
                         LPAD (s.prs_index, 5, '0')
                             npo_index,
                         prs_num,
                         prs_pc_num,
                         REPLACE (
                             SUBSTR (
                                 UPPER (
                                     TRIM (
                                         CONCAT (
                                                TRIM (
                                                    CONCAT (
                                                        TRIM (s.prs_ln) || ' ',
                                                        TRIM (s.prs_fn)))
                                             || ' ',
                                             TRIM (s.prs_mn)))),
                                 1,
                                 50),
                             ',',
                             '')
                             t_pc_pib,
                         TO_CHAR (prs_pay_dt, 'dd')
                             t_pp_day,
                         SUM (NVL (prs_sum * 100, 0))
                             t_prs_sum,
                         NULL
                             t_prs_sum_post,
                         REPLACE (
                                s.prs_building
                             || ';'
                             || s.prs_block
                             || ';'
                             || s.prs_apartment,
                             ',',
                             '')
                             t_adr,
                         SUBSTR (
                             UPPER (
                                 REPLACE (NVL (ns.ns_name, s.prs_street),
                                          ',',
                                          '')),
                             1,
                             50)
                             t_ul_name,
                         NVL (ns.ns_code, '0')
                             t_ul_code,
                         NVL2 (dd.nd_code, 'D', '')
                             t_dlvr_tp,
                         dd.nd_code
                             t_dlvr_code,
                         NULL
                             t_rec,
                         MAX (prs_id)
                             prs_id,
                         pr_id,
                         prs_pay_dt,
                         NULL
                             ncn_id,
                         NULL
                             npo_id,
                         prs_pc,
                         NULL
                             adr_id,
                         CASE
                             WHEN REGEXP_LIKE (UPPER (s.prs_doc_num),
                                               '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                             THEN
                                 UPPER (SUBSTR (s.prs_doc_num, 1, 2))
                             ELSE
                                 ''
                         END
                             t_doc_ser,
                         CASE
                             WHEN REGEXP_LIKE (s.prs_doc_num,
                                               '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                             THEN
                                 LPAD (SUBSTR (s.prs_doc_num, -6, 6), 9, '0')       -- старий паспорт
                             WHEN REGEXP_LIKE (s.prs_doc_num, '^(\d){9}$')
                             THEN
                                 s.prs_doc_num                -- новий паспорт
                             ELSE
                                 ''
                         END
                             t_doc_num,
                         CASE
                             WHEN EXISTS
                                      (SELECT 1
                                         FROM uss_esr.appeal   a,
                                              uss_esr.ap_person p
                                        WHERE     a.ap_pc = s.prs_pc
                                              AND p.app_ap = a.ap_id
                                              AND p.history_status = 'A'
                                              AND p.app_tp = 'P') -- Представник заявника )
                             THEN
                                 '1'
                             ELSE
                                 '0'
                         END
                             t_is_poa
                    FROM payroll p
                         JOIN pr_sheet s ON prs_pr = pr_id
                         JOIN v_opfu op ON op.org_id = p.com_org
                         JOIN uss_ndi.v_ndi_payment_codes npc
                             ON npc.npc_id = p.pr_npc
                         LEFT JOIN uss_ndi.v_ndi_street ns
                             ON ns.ns_id = s.prs_ns
                         LEFT JOIN uss_ndi.v_ndi_street_type nst
                             ON nst.nsrt_id = ns.ns_nsrt
                         LEFT JOIN uss_ndi.v_ndi_delivery dd
                             ON dd.nd_id = s.prs_nd
                   --where pr_id = 28053
                   WHERE     pr_id = p_pr_id
                         AND pr_pay_tp = 'POST'
                         AND prs_sum > 0
                         AND prs_st NOT IN ('PP')
                         AND PRS_tp IN ('PP')                -- Виплата поштою
                GROUP BY op.org_code,
                         TO_CHAR (pr_start_dt, 'mm'),
                         TO_CHAR (pr_start_dt, 'yyyy'),
                         CASE pr_tp WHEN 'M' THEN '01' WHEN 'A' THEN '02' END,
                         LPAD (s.prs_index, 5, '0'),
                         prs_num,
                         prs_pc_num,
                         s.prs_doc_num,
                         REPLACE (
                             SUBSTR (
                                 UPPER (
                                     TRIM (
                                         CONCAT (
                                                TRIM (
                                                    CONCAT (
                                                           TRIM (s.prs_ln)
                                                        || ' ',
                                                        TRIM (s.prs_fn)))
                                             || ' ',
                                             TRIM (s.prs_mn)))),
                                 1,
                                 50),
                             ',',
                             ''),
                         TO_CHAR (prs_pay_dt, 'dd'),
                         REPLACE (
                                s.prs_building
                             || ';'
                             || s.prs_block
                             || ';'
                             || s.prs_apartment,
                             ',',
                             ''),
                         SUBSTR (
                             UPPER (
                                 REPLACE (NVL (ns.ns_name, s.prs_street),
                                          ',',
                                          '')),
                             1,
                             50),
                         NVL (ns.ns_code, '0'),
                         CASE
                             WHEN dd.nd_code IS NOT NULL THEN 'D'
                             ELSE NULL
                         END,
                         dd.nd_code,
                         pr_id,
                         prs_pay_dt,
                         prs_pc,
                         npc.npc_code;

            IF SQL%ROWCOUNT = 0
            THEN
                RAISE NO_DATA_FOUND;
            END IF;

            UPDATE TMP_POST_TO_EXPORT t
               SET (t.t_dlvr_tp, t.t_dlvr_code) =
                       (SELECT 'D', pdm_nd_num
                          FROM (SELECT pdm_nd_num,
                                       ROW_NUMBER ()
                                           OVER (
                                               PARTITION BY pd_pc
                                               ORDER BY
                                                   DECODE (pd_st, 'S', 1, 0) DESC,
                                                   pd.pd_start_dt DESC)    AS rn
                                  FROM pr_sheet  s
                                       JOIN pc_account a ON pa_id = prs_pa
                                       JOIN pc_decision pd
                                           ON     prs_pc = pd_pc
                                              AND pd_nst = pa_nst
                                       JOIN pd_pay_method pdm
                                           ON     pd_id = pdm_pd
                                              AND pdm.history_status = 'A'
                                              AND pdm_is_actual = 'T'
                                 WHERE     s.prs_id = t.t_prs_id
                                       AND pdm.pdm_pay_tp = 'POST'
                                       AND pdm.pdm_nd_num IS NOT NULL)
                         WHERE rn = 1)
             WHERE     t.t_dlvr_code IS NULL
                   AND EXISTS
                           (SELECT 1
                              FROM pr_sheet  s
                                   JOIN pc_account a ON pa_id = prs_pa
                                   JOIN pc_decision pd
                                       ON prs_pc = pd_pc AND pd_nst = pa_nst
                                   JOIN pd_pay_method pdm
                                       ON     pd_id = pdm_pd
                                          AND pdm.history_status = 'A'
                                          AND pdm_is_actual = 'T'
                             WHERE     s.prs_id = t.t_prs_id
                                   AND pdm.pdm_pay_tp = 'POST'
                                   AND pdm.pdm_nd_num IS NOT NULL);

            UPDATE TMP_POST_TO_EXPORT t
               SET t.t_dlvr_tp = 'P'
             WHERE t.t_dlvr_code IS NULL AND t.t_dlvr_tp IS NULL;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RAISE;
            WHEN OTHERS
            THEN
                raise_application_error (
                    -20000,
                       'Помилка читання даних:'
                    || CHR (10)
                    || SQLERRM
                    || DBMS_UTILITY.format_error_backtrace);
        END create_temp_data;
    BEGIN
        l_filter := 'PR_' || p_pr_id || '#' || p_prs_tp;

        SELECT COUNT (*)
          INTO l_cnt
          FROM exchcreatesession
         WHERE ecs_filter = l_filter;

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                'Створення файлів з даними параметрами вже виконувалось!');
        END IF;

        INSERT INTO exchcreatesession (ecs_id, ecs_start_dt, ecs_filter)
             VALUES (0, SYSDATE, l_filter)
          RETURNING ecs_id
               INTO l_ecs;

        DELETE FROM ikis_rbm.tmp_exchangefiles_m1;

        create_temp_data;

        SELECT pc.npc_id,
               pc.npc_code,
               pc.npc_code || ' ' || pc.npc_name     pr_name
          INTO l_npc_id, l_pr_code, l_pr_name
          FROM uss_esr.payroll r, uss_ndi.v_ndi_payment_codes pc
         WHERE r.pr_npc = pc.npc_id AND r.pr_id = p_pr_id;

        -- загальні атрибути пакета
        SELECT    '<p style="text-align: center;">Опис вмісту пакета на виплату (пошта)<br>'
               || l_pr_name
               || CHR (10)
               || '</p><div class="RptTable">'
               || '<table><tbody><tr><td>Індекс</td><td>Кількість одержувачів</td><td>Сума, гривень</td></tr>'
               || XMLAGG (
                      XMLELEMENT ("tr",
                                  XMLELEMENT ("td", NVL (x_index, 'Всього')),
                                  XMLELEMENT ("td", x_cnt),
                                  XMLELEMENT ("td", TO_CHAR (x_sum)))).getClobVal ()
               || '</tbody></table></div>'            b_visual_data,
               SUM (DECODE (x_index, NULL, x_cnt))    x_cnt,
               SUM (DECODE (x_index, NULL, x_sum))    x_sum,
               MAX (t_per_num)                        t_per_num
          INTO l_visual_data,
               l_pp_cnt,
               l_pp_sum,
               l_per_num
          FROM (  SELECT s.t_npo_index        x_index,
                         COUNT (*)            x_cnt,
                         SUM (s.t_pp_sum)     x_sum,
                         MAX (t_per_num)      t_per_num
                    FROM TMP_POST_TO_EXPORT s
                GROUP BY ROLLUP (s.t_npo_index)
                ORDER BY 1);

        INSERT INTO exchangefiles (ef_id,
                                   ef_po,
                                   ef_pr,
                                   com_wu,
                                   com_org,
                                   ef_tp,
                                   ef_name,
                                   ef_data,
                                   ef_visual_data,
                                   ef_header,
                                   ef_main_tag_name,
                                   ef_data_name,
                                   ef_ecp_list_name,
                                   ef_ecp_name,
                                   ef_ecp_alg,
                                   ef_st,
                                   ef_ident_data,
                                   ef_dt,
                                   ef_ecs,
                                   ef_rec)
            SELECT 0                 ef_id,
                   NULL              p_po_id,
                   p_pr_id,
                   NULL              com_wu,
                   p_org_id,
                   'PR',
                   v_file_name,
                   v_file_data,
                   l_visual_data     v_visual_data,
                   v_file_header,
                   v_file_header_name,
                   v_file_data_name,
                   v_ecp_list_name,
                   v_ecp_name,
                   v_ecp_alg,
                   'Z'               ef_st,
                   v_ident_data,
                   SYSDATE,
                   l_ecs,
                   160               v_rec -- ikis_rbm.v_recipient.rec_id (VPP_UN ВПП ООН в ЄІССС)
              FROM (WITH
                        dat
                        AS
                            (SELECT SUBSTR (
                                        TRIM (TO_CHAR (org_id, '000009')),
                                        1,
                                        3)                        p_opfu,
                                    SUBSTR (
                                        REPLACE (org_name,
                                                 'Головне управління ',
                                                 'ГУ'),
                                        1,
                                        27)                       p_opfu_name,
                                    c.npc_name                    p_pr_header,
                                    org_id                        p_org_id,
                                    TOOLS.GetOrgSName (org_id)    p_org_name,
                                    pr_create_dt                  p_pr_dt,
                                    pr_start_dt,
                                    l_pp_sum                      p_pr_sum,
                                    l_pp_cnt                      p_pr_cnt
                               FROM uss_esr.payroll              p,
                                    v_opfu,
                                    uss_ndi.v_ndi_payment_codes  c
                              WHERE     pr_id = p_pr_id
                                    AND com_org = org_id
                                    AND c.npc_id = p.pr_npc)
                    SELECT p_org_id,
                              p_org_id
                           || '-'
                           || l_pkt_type
                           || '-'
                           || LPAD (l_per_num, 2, '0')
                           || '-'
                           || TO_CHAR (pr_start_dt, 'mmyyyy')
                               v_file_name,
                              XMLELEMENT ("opfu_code", p_org_id)
                           || XMLELEMENT ("opfu_name",
                                          CONVERT (p_org_name, 'UTF8'))
                           || XMLELEMENT ("date_cr",
                                          TO_CHAR (p_pr_dt, 'DDMMYYYY'))
                           || XMLELEMENT ("MFO_filia", '')
                           || XMLELEMENT ("filia_num", '')
                           || XMLELEMENT ("filia_name", '')
                           || XMLELEMENT ("full_sum", p_pr_sum)
                           || XMLELEMENT ("full_lines", p_pr_cnt)
                           || XMLELEMENT ("type", l_pkt_type)
                           || XMLELEMENT ("id_cor", '')
                               v_file_header,
                              'МФО: '
                           || ''
                           || '; Відділення:'
                           || ''
                           || '; Сума: '
                           || TO_CHAR (p_pr_sum * 0.01, '999999999990.00')
                           || '; Рядків: '
                           || p_pr_cnt
                               v_ident_data,
                           'paymentlists'
                               v_file_header_name,
                           'file_data'
                               v_file_data_name,
                           'ecp_list'
                               v_ecp_list_name,
                           'ecp'
                               v_ecp_name,
                           'MD'
                               v_ecp_alg,
                           UTL_COMPRESS.lz_compress (tools.ConvertC2B (
                                                         (SELECT XMLELEMENT (
                                                                     "description_files",
                                                                     XMLELEMENT (
                                                                         "id",
                                                                         p_pr_id),
                                                                     XMLELEMENT (
                                                                         "opfu_code",
                                                                         p_org_id),
                                                                     XMLELEMENT (
                                                                         "opfu_name",
                                                                         p_org_name),
                                                                     XMLELEMENT (
                                                                         "date_cr",
                                                                         TO_CHAR (
                                                                             p_pr_dt,
                                                                             'DDMMYYYY')),
                                                                     XMLELEMENT (
                                                                         "MFO_filia",
                                                                         ''),
                                                                     XMLELEMENT (
                                                                         "filia_num",
                                                                         ''),
                                                                     XMLELEMENT (
                                                                         "filia_name",
                                                                         ''),
                                                                     XMLELEMENT (
                                                                         "full_sum",
                                                                         p_pr_sum),
                                                                     XMLELEMENT (
                                                                         "full_lines",
                                                                         p_pr_cnt),
                                                                     XMLELEMENT (
                                                                         "type",
                                                                         l_pkt_type),
                                                                     XMLELEMENT (
                                                                         "id_cor",
                                                                         ''),
                                                                     XMLELEMENT (
                                                                         "branches",
                                                                         XMLAGG (XMLELEMENT (
                                                                                     "row",
                                                                                     XMLELEMENT (
                                                                                         "branch_num",
                                                                                         a.t_npo_index),
                                                                                     XMLELEMENT (
                                                                                         "branch_sum",
                                                                                         a.sum_pp),
                                                                                     XMLELEMENT (
                                                                                         "branch_lines",
                                                                                         a.cnt_pp),
                                                                                     XMLELEMENT (
                                                                                         "date_pay",
                                                                                         ''),
                                                                                     XMLELEMENT (
                                                                                         "num_list",
                                                                                         a.rn),
                                                                                     XMLELEMENT (
                                                                                         "file_name",
                                                                                         a.file_name),
                                                                                     XMLELEMENT (
                                                                                         "file_data",
                                                                                         API$ESR_EXCHANGE.getPostFile (
                                                                                             a.t_org_code,
                                                                                             a.t_npo_index)),
                                                                                     XMLELEMENT (
                                                                                         "branch_opfu_code",
                                                                                         t_org_code))
                                                                                 ORDER BY
                                                                         a.rn  ))).getClobVal ()    v_file_data
                                                            FROM (  SELECT t.t_org_code,
                                                                           t.t_npo_index,
                                                                           SUM (
                                                                               t_pp_sum)
                                                                               sum_pp,
                                                                           COUNT (
                                                                               *)
                                                                               cnt_pp,
                                                                              t.t_npo_index -- індекс відділенням зв'язку (5 цифр)
                                                                           || '.'
                                                                           || l_pkt_type -- тип відомості на виплату («78»)
                                                                           || '.'
                                                                           || LPAD (
                                                                                  TO_CHAR (
                                                                                      MAX (
                                                                                          t.t_per_num)),
                                                                                  2,
                                                                                  '0') -- номер періоду (6,7 символ заголовку)
                                                                           || LPAD (
                                                                                  TO_CHAR (
                                                                                      MAX (
                                                                                          t.t_per_month)),
                                                                                  2,
                                                                                  '0')
                                                                           || LPAD (
                                                                                  TO_CHAR (
                                                                                      MAX (
                                                                                          t.t_per_year)),
                                                                                  4,
                                                                                  '0') -- місяць та рік виплатного періоду
                                                                           || '.'
                                                                           || LPAD (
                                                                                  t.t_org_code,
                                                                                  5,
                                                                                  0) -- код району
                                                                               file_name,
                                                                           ROW_NUMBER ()
                                                                               OVER (
                                                                                   ORDER BY
                                                                                       t.t_org_code,
                                                                                       t.t_npo_index)
                                                                               rn
                                                                      FROM TMP_POST_TO_EXPORT
                                                                           t
                                                                  GROUP BY t.t_org_code,
                                                                           t.t_npo_index)
                                                                 a)))
                               v_file_data
                      FROM dat) d;

        -- заливаємо дані по відомості в ikis_finzvit  за допомогою ikis_rbm
        INSERT INTO ikis_rbm.tmp_exchangefiles_m1 (ef_id,
                                                   ef_pr,
                                                   com_wu,
                                                   com_org,
                                                   ef_tp,
                                                   ef_name,
                                                   ef_data,
                                                   ef_visual_data,
                                                   ef_header,
                                                   ef_main_tag_name,
                                                   ef_data_name,
                                                   ef_ecp_list_name,
                                                   ef_ecp_name,
                                                   ef_ecp_alg,
                                                   ef_st,
                                                   ef_dt,
                                                   ef_ident_data,
                                                   ef_ecs,
                                                   ef_rec,
                                                   ef_pr_code,
                                                   ef_pr_name,
                                                   ef_pr_pay_dt,
                                                   ef_pr_pr,
                                                   ef_npc)
            SELECT ef_id,
                   p_pr_id     ef_pr,
                   com_wu,
                   com_org,
                   ef_tp,
                   ef_name,
                   ef_data,
                   ef_visual_data,
                   ef_header,
                   ef_main_tag_name,
                   ef_data_name,
                   ef_ecp_list_name,
                   ef_ecp_name,
                   ef_ecp_alg,
                   ef_st,
                   ef_dt,
                   ef_ident_data,
                   ef_ecs,
                   ef_rec,
                   l_pr_code,
                   l_pr_name,
                   NULL        pay_dt,
                   NULL        ef_pr_pr,
                   l_npc_id
              FROM exchangefiles
             WHERE ef_ecs = l_ecs;

        ikis_rbm.RDM$APP_EXCHANGE.GenPaketsFromTMPTable;

        UPDATE exchangefiles f
           SET ef_pkt =
                   (SELECT t.ef_pkt
                      FROM ikis_rbm.tmp_exchangefiles_m1 t
                     WHERE t.ef_id = f.ef_id)
         WHERE     1 = 1                                   --- ef_pr = p_pr_id
               AND ef_ecs = l_ecs
               AND EXISTS
                       (SELECT 1
                          FROM ikis_rbm.tmp_exchangefiles_m1 t
                         WHERE t.ef_id = f.ef_id);

        UPDATE exchcreatesession
           SET ecs_stop_dt = SYSDATE
         WHERE ecs_id = l_ecs;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20001,
                   'Відсутня інформація для побудови файлу електронних відомостей на пошту'
                || CHR (10)
                || SQLERRM
                || DBMS_UTILITY.format_error_backtrace);
        WHEN OTHERS
        THEN
            IF SQLCODE IN (-20001)
            THEN
                RAISE;
            END IF;

            raise_application_error (
                -20000,
                   'Помилка підготовки даних для побудови файлу електронних відомостей на пошту: '
                || CHR (10)
                || SQLERRM
                || DBMS_UTILITY.format_error_backtrace);
    END BuildPostExchFiles;

    -- IC #98707 Формування пакету по виплаті по пошті (отримання файлу без відправки ПЕОД)
    PROCEDURE BuildPostExchFiles (p_pr_id          IN     payroll.pr_id%TYPE,
                                  p_pkt_tp         IN     VARCHAR2 := '78',
                                  p_convert_symb   IN     VARCHAR2 := 'F',
                                  o_rpt               OUT BLOB)
    IS
        l_filter      VARCHAR2 (250);
        l_ecs         exchcreatesession.ecs_id%TYPE;
        l_cnt         INTEGER;
        l_pp_sum      NUMBER;
        l_pp_cnt      NUMBER;
        l_per_num     TMP_POST_TO_EXPORT.t_per_num%TYPE;
        l_npc_id      NUMBER;
        l_pr_code     uss_ndi.v_ndi_payment_codes.npc_code%TYPE;
        l_pr_name     VARCHAR2 (256);

        l_pr_files    ikis_sysweb.tbl_some_files
                          := ikis_sysweb.tbl_some_files ();
        l_file_name   VARCHAR2 (128);
        l_rpt         CLOB;

        PROCEDURE create_temp_data
        AS
        BEGIN
            SELECT CASE
                       WHEN EXISTS
                                (SELECT 1
                                   FROM tmp_work_set1
                                  WHERE x_id1 IS NOT NULL)
                       THEN
                           1
                       ELSE
                           0
                   END    cnt
              INTO l_cnt
              FROM DUAL;

            DELETE FROM TMP_POST_TO_EXPORT
                  WHERE 1 = 1;

            INSERT INTO TMP_POST_TO_EXPORT (T_ORG_CODE,
                                            T_PER_NUM,
                                            T_DAY_START,
                                            T_DAY_STOP,
                                            T_PER_MONTH,
                                            T_PER_YEAR,
                                            T_VED_TP,
                                            T_PAY_TP,
                                            T_NCN_CODE,
                                            t_npo_index,
                                            T_PRS_NUM,
                                            T_PC_NUMBER,
                                            T_PC_PIB,
                                            T_PP_DAY,
                                            T_PP_SUM,
                                            T_PP_SUM_POST,
                                            T_ADR,
                                            T_UL_NAME,
                                            T_UL_CODE,
                                            T_DLVR_TP,
                                            T_DLVR_CODE,
                                            T_RBM_REC,
                                            T_PRS_ID,
                                            T_PR_ID,
                                            T_PP_DATE,
                                            T_NCN_ID,
                                            T_NPO_ID,
                                            T_PRS_PC,
                                            T_ADR_ID,
                                            T_DOC_SER,
                                            T_DOC_NUM,
                                            T_IS_POA)
                  SELECT op.org_code
                             t_org_code,
                         MAX (
                             (SELECT NVL (COUNT (1), 0) + 1
                                FROM payroll p2
                               WHERE     p2.pr_month = p.pr_month
                                     AND p2.com_org = p.com_org
                                     AND p2.pr_npc = p.pr_npc
                                     AND p2.pr_pay_tp = p.pr_pay_tp
                                     AND p2.pr_create_dt < p.pr_create_dt))
                             t_per_num,
                         4                                     /*pr_start_dt*/
                             t_day_start,
                         25                                     /*pr_stop_dt*/
                             t_day_stop,
                         TO_CHAR (pr_start_dt, 'mm')
                             t_per_month,
                         TO_CHAR (pr_start_dt, 'yyyy')
                             t_per_year,
                         LPAD (npc.npc_code, 2, '0')
                             t_ved_tp,
                         '01'
                             t_pay_tp,
                         '01'
                             ncn_code,
                         LPAD (s.prs_index, 5, '0')
                             npo_index,
                         prs_num,
                         prs_pc_num,
                         REPLACE (
                             SUBSTR (
                                 UPPER (
                                     TRIM (
                                         CONCAT (
                                                TRIM (
                                                    CONCAT (
                                                        TRIM (s.prs_ln) || ' ',
                                                        TRIM (s.prs_fn)))
                                             || ' ',
                                             TRIM (s.prs_mn)))),
                                 1,
                                 50),
                             ',',
                             '')
                             t_pc_pib,
                         TO_CHAR (prs_pay_dt, 'dd')
                             t_pp_day,
                         SUM (NVL (prs_sum * 100, 0))
                             t_prs_sum,
                         NULL
                             t_prs_sum_post,
                         REPLACE (
                                s.prs_building
                             || ';'
                             || s.prs_block
                             || ';'
                             || s.prs_apartment,
                             ',',
                             '')
                             t_adr,
                         SUBSTR (
                             UPPER (
                                 REPLACE (NVL (ns.ns_name, s.prs_street),
                                          ',',
                                          '')),
                             1,
                             50)
                             t_ul_name,
                         NVL (ns.ns_code, '0')
                             t_ul_code,
                         NVL2 (dd.nd_code, 'D', '')
                             t_dlvr_tp,
                         dd.nd_code
                             t_dlvr_code,
                         NULL
                             t_rec,
                         MAX (prs_id)
                             prs_id,
                         pr_id,
                         prs_pay_dt,
                         NULL
                             ncn_id,
                         NULL
                             npo_id,
                         prs_pc,
                         NULL
                             adr_id,
                         CASE
                             WHEN REGEXP_LIKE (UPPER (s.prs_doc_num),
                                               '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                             THEN
                                 UPPER (SUBSTR (s.prs_doc_num, 1, 2))
                             ELSE
                                 ''
                         END
                             t_doc_ser,
                         CASE
                             WHEN REGEXP_LIKE (s.prs_doc_num,
                                               '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                             THEN
                                 LPAD (SUBSTR (s.prs_doc_num, -6, 6), 9, '0')       -- старий паспорт
                             WHEN REGEXP_LIKE (s.prs_doc_num, '^(\d){9}$')
                             THEN
                                 s.prs_doc_num                -- новий паспорт
                             ELSE
                                 ''
                         END
                             t_doc_num,
                         CASE
                             WHEN EXISTS
                                      (SELECT 1
                                         FROM uss_esr.appeal   a,
                                              uss_esr.ap_person p
                                        WHERE     a.ap_pc = s.prs_pc
                                              AND p.app_ap = a.ap_id
                                              AND p.history_status = 'A'
                                              AND p.app_tp = 'P') -- Представник заявника )
                             THEN
                                 '1'
                             ELSE
                                 '0'
                         END
                             t_is_poa
                    FROM payroll p
                         JOIN pr_sheet s ON prs_pr = pr_id
                         JOIN v_opfu op ON op.org_id = p.com_org
                         JOIN uss_ndi.v_ndi_payment_codes npc
                             ON npc.npc_id = p.pr_npc
                         LEFT JOIN uss_ndi.v_ndi_street ns
                             ON ns.ns_id = s.prs_ns
                         LEFT JOIN uss_ndi.v_ndi_street_type nst
                             ON nst.nsrt_id = ns.ns_nsrt
                         LEFT JOIN uss_ndi.v_ndi_delivery dd
                             ON dd.nd_id = s.prs_nd
                   --where pr_id = 28053
                   WHERE     pr_id = p_pr_id
                         AND pr_pay_tp = 'POST'
                         AND prs_sum > 0
                         AND prs_st NOT IN ('PP')
                         AND PRS_tp IN ('PP')                -- Виплата поштою
                         AND (   EXISTS
                                     (SELECT 1
                                        FROM tmp_work_set1
                                       WHERE x_id1 = s.prs_id)
                              OR l_cnt = 0)
                GROUP BY op.org_code,
                         TO_CHAR (pr_start_dt, 'mm'),
                         TO_CHAR (pr_start_dt, 'yyyy'),
                         CASE pr_tp WHEN 'M' THEN '01' WHEN 'A' THEN '02' END,
                         LPAD (s.prs_index, 5, '0'),
                         prs_num,
                         prs_pc_num,
                         s.prs_doc_num,
                         REPLACE (
                             SUBSTR (
                                 UPPER (
                                     TRIM (
                                         CONCAT (
                                                TRIM (
                                                    CONCAT (
                                                           TRIM (s.prs_ln)
                                                        || ' ',
                                                        TRIM (s.prs_fn)))
                                             || ' ',
                                             TRIM (s.prs_mn)))),
                                 1,
                                 50),
                             ',',
                             ''),
                         TO_CHAR (prs_pay_dt, 'dd'),
                         REPLACE (
                                s.prs_building
                             || ';'
                             || s.prs_block
                             || ';'
                             || s.prs_apartment,
                             ',',
                             ''),
                         SUBSTR (
                             UPPER (
                                 REPLACE (NVL (ns.ns_name, s.prs_street),
                                          ',',
                                          '')),
                             1,
                             50),
                         NVL (ns.ns_code, '0'),
                         CASE
                             WHEN dd.nd_code IS NOT NULL THEN 'D'
                             ELSE NULL
                         END,
                         dd.nd_code,
                         pr_id,
                         prs_pay_dt,
                         prs_pc,
                         npc.npc_code;

            IF SQL%ROWCOUNT = 0
            THEN
                RAISE NO_DATA_FOUND;
            END IF;

            UPDATE TMP_POST_TO_EXPORT t
               SET (t.t_dlvr_tp, t.t_dlvr_code) =
                       (SELECT 'D', pdm_nd_num
                          FROM (SELECT pdm_nd_num,
                                       ROW_NUMBER ()
                                           OVER (
                                               PARTITION BY pd_pc
                                               ORDER BY
                                                   DECODE (pd_st, 'S', 1, 0) DESC,
                                                   pd.pd_start_dt DESC)    AS rn
                                  FROM pr_sheet  s
                                       JOIN pc_account a ON pa_id = prs_pa
                                       JOIN pc_decision pd
                                           ON     prs_pc = pd_pc
                                              AND pd_nst = pa_nst
                                       JOIN pd_pay_method pdm
                                           ON     pd_id = pdm_pd
                                              AND pdm.history_status = 'A'
                                              AND pdm_is_actual = 'T'
                                 WHERE     s.prs_id = t.t_prs_id
                                       AND pdm.pdm_pay_tp = 'POST'
                                       AND pdm.pdm_nd_num IS NOT NULL)
                         WHERE rn = 1)
             WHERE     t.t_dlvr_code IS NULL
                   AND EXISTS
                           (SELECT 1
                              FROM pr_sheet  s
                                   JOIN pc_account a ON pa_id = prs_pa
                                   JOIN pc_decision pd
                                       ON prs_pc = pd_pc AND pd_nst = pa_nst
                                   JOIN pd_pay_method pdm
                                       ON     pd_id = pdm_pd
                                          AND pdm.history_status = 'A'
                                          AND pdm_is_actual = 'T'
                             WHERE     s.prs_id = t.t_prs_id
                                   AND pdm.pdm_pay_tp = 'POST'
                                   AND pdm.pdm_nd_num IS NOT NULL);

            UPDATE TMP_POST_TO_EXPORT t
               SET t.t_dlvr_tp = 'P'
             WHERE t.t_dlvr_code IS NULL AND t.t_dlvr_tp IS NULL;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RAISE;
            WHEN OTHERS
            THEN
                raise_application_error (
                    -20000,
                       'Помилка читання даних:'
                    || CHR (10)
                    || SQLERRM
                    || DBMS_UTILITY.format_error_backtrace);
        END create_temp_data;
    BEGIN
        create_temp_data;

        SELECT pc.npc_id,
               pc.npc_code,
               pc.npc_code || ' ' || pc.npc_name     pr_name
          INTO l_npc_id, l_pr_code, l_pr_name
          FROM uss_esr.payroll r, uss_ndi.v_ndi_payment_codes pc
         WHERE r.pr_npc = pc.npc_id AND r.pr_id = p_pr_id;

        -- загальні атрибути пакета
        SELECT COUNT (*)            x_cnt,
               SUM (s.t_pp_sum)     x_sum,
               MAX (t_per_num)      t_per_num
          INTO l_pp_cnt, l_pp_sum, l_per_num
          FROM TMP_POST_TO_EXPORT s;

        WITH
            dat
            AS
                (SELECT SUBSTR (TRIM (TO_CHAR (org_id, '000009')), 1, 3)
                            p_opfu,
                        SUBSTR (
                            REPLACE (org_name, 'Головне управління ', 'ГУ'),
                            1,
                            27)
                            p_opfu_name,
                        c.npc_name
                            p_pr_header,
                        org_id
                            p_org_id,
                        TOOLS.GetOrgSName (org_id)
                            p_org_name,
                        pr_create_dt
                            p_pr_dt,
                        pr_start_dt,
                        l_pp_sum
                            p_pr_sum,
                        l_pp_cnt
                            p_pr_cnt
                   FROM uss_esr.payroll              p,
                        v_opfu,
                        uss_ndi.v_ndi_payment_codes  c
                  WHERE     pr_id = p_pr_id
                        AND com_org = org_id
                        AND c.npc_id = p.pr_npc)
        SELECT    p_org_id
               || '-'
               || p_pkt_tp
               || '-'
               || LPAD (l_per_num, 2, '0')
               || '-'
               || TO_CHAR (pr_start_dt, 'mmyyyy')                   v_file_name,
               (SELECT XMLELEMENT (
                           "description_files",
                           -- XMLELEMENT("id", p_pr_id),
                           XMLELEMENT ("opfu_code", p_org_id),
                           XMLELEMENT ("opfu_name",
                                       CONVERT (p_org_name, 'UTF8')),
                           XMLELEMENT ("date_cr",
                                       TO_CHAR (p_pr_dt, 'DDMMYYYY')),
                           XMLELEMENT ("MFO_filia", ''),
                           XMLELEMENT ("filia_num", ''),
                           XMLELEMENT ("filia_name", ''),
                           XMLELEMENT ("full_sum", p_pr_sum),
                           XMLELEMENT ("full_lines", p_pr_cnt),
                           XMLELEMENT ("type", p_pkt_tp),
                           XMLELEMENT ("id_cor", ''),
                           XMLELEMENT (
                               "branches",
                               XMLAGG (XMLELEMENT (
                                           "row",
                                           XMLELEMENT ("branch_num",
                                                       a.t_npo_index),
                                           XMLELEMENT ("branch_sum",
                                                       a.sum_pp),
                                           XMLELEMENT ("branch_lines",
                                                       a.cnt_pp),
                                           XMLELEMENT ("date_pay", ''),
                                           XMLELEMENT ("num_list", a.rn),
                                           XMLELEMENT ("file_name",
                                                       a.file_name),
                                           XMLELEMENT ("file_data",
                                                       API$ESR_EXCHANGE.getPostFile (
                                                           a.t_org_code,
                                                           a.t_npo_index,
                                                           p_pkt_tp,
                                                           a.file_name)),
                                           XMLELEMENT ("branch_opfu_code",
                                                       t_org_code))
                                       ORDER BY a.rn))).getClobVal ()    v_file_data
                  FROM (  SELECT t.t_org_code,
                                 t.t_npo_index,
                                 SUM (t_pp_sum)                                   sum_pp,
                                 COUNT (*)                                        cnt_pp,
                                    t.t_npo_index -- індекс відділенням зв'язку (5 цифр)
                                 || '.'
                                 || p_pkt_tp -- тип відомості на виплату («78»)
                                 || '.'
                                 || LPAD (TO_CHAR (MAX (t.t_per_num)), 2, '0') -- номер періоду (6,7 символ заголовку)
                                 || LPAD (TO_CHAR (MAX (t.t_per_month)),
                                          2,
                                          '0')
                                 || LPAD (TO_CHAR (MAX (t.t_per_year)), 4, '0') -- місяць та рік виплатного періоду
                                 || '.'
                                 || LPAD (t.t_org_code, 5, 0)    -- код району
                                                                                  file_name,
                                 ROW_NUMBER ()
                                     OVER (
                                         ORDER BY t.t_org_code, t.t_npo_index)    rn
                            FROM TMP_POST_TO_EXPORT t
                        GROUP BY t.t_org_code, t.t_npo_index) a)    v_file_data
          INTO l_file_name, l_rpt
          FROM dat;

        -- Повертаємо блоб тільки для пакетної обробки
        -- l_pr_files.extend;
        -- l_pr_files(l_pr_files.LAST) := ikis_sysweb.t_some_file_info(l_file_name||'.zip', utl_compress.lz_compress(tools.ConvertC2B(l_rpt)));
        -- o_rpt := utl_compress.lz_compress(tools.ConvertC2B(l_rpt));
        o_rpt := tools.ConvertC2B (l_rpt);
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20001,
                   'Відсутня інформація для побудови файлу електронних відомостей на пошту'
                || CHR (10)
                || SQLERRM
                || DBMS_UTILITY.format_error_backtrace);
        WHEN OTHERS
        THEN
            IF SQLCODE IN (-20001)
            THEN
                RAISE;
            END IF;

            raise_application_error (
                -20000,
                   'Помилка підготовки даних для побудови файлу електронних відомостей на пошту: '
                || CHR (10)
                || SQLERRM
                || DBMS_UTILITY.format_error_backtrace);
    END BuildPostExchFiles;

    -- IC #111345 Формування пакету по виплаті по пошті (в кабінет банку)
    PROCEDURE BuildPostExchFiles (p_po_id          pay_order.po_id%TYPE,
                                  p_pr_id          payroll.pr_id%TYPE,
                                  p_prs_tp         pr_sheet.prs_tp%TYPE,
                                  p_rec_id         NUMBER:= 150, -- АТ "УКРПОШТА"
                                  p_convert_symb   VARCHAR2:= 'F')
    IS
        l_filter        VARCHAR2 (250);
        l_ecs           exchcreatesession.ecs_id%TYPE;
        l_cnt           INTEGER;
        l_pkt_id        NUMBER;
        l_pr_code       VARCHAR2 (10);
        l_pr_name       VARCHAR2 (250);
        l_pr_type       VARCHAR2 (10);
        l_pay_dt        DATE;
        l_npc_id        NUMBER;
        l_com_org       NUMBER;

        l_ef_id         NUMBER;
        l_xdata         exchangefiles.ef_header%TYPE;
        l_pp_sum        NUMBER;
        l_pp_cnt        NUMBER;
        l_per_num       TMP_POST_TO_EXPORT.t_per_num%TYPE;
        l_file_name     VARCHAR2 (128);
        l_data          exchangefiles.ef_data%TYPE;
        l_visual_data   exchangefiles.ef_visual_data%TYPE;
        l_pc_row        ikis_rbm.v_packet_content%ROWTYPE;

        PROCEDURE create_temp_data
        AS
        BEGIN
            DELETE FROM TMP_POST_TO_EXPORT
                  WHERE 1 = 1;

            INSERT INTO TMP_POST_TO_EXPORT (T_ORG_CODE,
                                            T_PER_NUM,
                                            T_DAY_START,
                                            T_DAY_STOP,
                                            T_PER_MONTH,
                                            T_PER_YEAR,
                                            T_VED_TP,
                                            T_PAY_TP,
                                            T_NCN_CODE,
                                            t_npo_index,
                                            T_PRS_NUM,
                                            T_PC_NUMBER,
                                            T_PC_PIB,
                                            T_PP_DAY,
                                            T_PP_SUM,
                                            T_PP_SUM_POST,
                                            T_ADR,
                                            T_UL_NAME,
                                            T_UL_CODE,
                                            T_DLVR_TP,
                                            T_DLVR_CODE,
                                            T_RBM_REC,
                                            T_PRS_ID,
                                            T_PR_ID,
                                            T_PP_DATE,
                                            T_NCN_ID,
                                            T_NPO_ID,
                                            T_PRS_PC,
                                            T_ADR_ID,
                                            T_DOC_SER,
                                            T_DOC_NUM,
                                            T_IS_POA)
                  SELECT op.org_code
                             t_org_code,
                         MAX (
                             (SELECT NVL (COUNT (1), 0) + 1
                                FROM payroll p2
                               WHERE     p2.pr_month = p.pr_month
                                     AND p2.com_org = p.com_org
                                     AND p2.pr_npc = p.pr_npc
                                     AND p2.pr_pay_tp = p.pr_pay_tp
                                     AND p2.pr_create_dt < p.pr_create_dt))
                             t_per_num,
                         4                                     /*pr_start_dt*/
                             t_day_start,
                         25                                     /*pr_stop_dt*/
                             t_day_stop,
                         TO_CHAR (pr_start_dt, 'mm')
                             t_per_month,
                         TO_CHAR (pr_start_dt, 'yyyy')
                             t_per_year,
                         LPAD (npc.npc_code, 2, '0')
                             t_ved_tp,
                         '01'
                             t_pay_tp,
                         '01'
                             ncn_code,
                         LPAD (s.prs_index, 5, '0')
                             npo_index,
                         prs_num,
                         prs_pc_num,
                         REPLACE (
                             SUBSTR (
                                 UPPER (
                                     TRIM (
                                         CONCAT (
                                                TRIM (
                                                    CONCAT (
                                                        TRIM (s.prs_ln) || ' ',
                                                        TRIM (s.prs_fn)))
                                             || ' ',
                                             TRIM (s.prs_mn)))),
                                 1,
                                 50),
                             ',',
                             '')
                             t_pc_pib,
                         TO_CHAR (prs_pay_dt, 'dd')
                             t_pp_day,
                         SUM (NVL (prs_sum * 100, 0))
                             t_prs_sum,
                         NULL
                             t_prs_sum_post,
                         REPLACE (
                                s.prs_building
                             || ';'
                             || s.prs_block
                             || ';'
                             || s.prs_apartment,
                             ',',
                             '')
                             t_adr,
                         SUBSTR (
                             UPPER (
                                 REPLACE (NVL (ns.ns_name, s.prs_street),
                                          ',',
                                          '')),
                             1,
                             50)
                             t_ul_name,
                         NVL (ns.ns_code, '0')
                             t_ul_code,
                         NVL2 (dd.nd_code, 'D', '')
                             t_dlvr_tp,
                         dd.nd_code
                             t_dlvr_code,
                         NULL
                             t_rec,
                         MAX (prs_id)
                             prs_id,
                         pr_id,
                         prs_pay_dt,
                         NULL
                             ncn_id,
                         NULL
                             npo_id,
                         prs_pc,
                         NULL
                             adr_id,
                         CASE
                             WHEN REGEXP_LIKE (UPPER (s.prs_doc_num),
                                               '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                             THEN
                                 UPPER (SUBSTR (s.prs_doc_num, 1, 2))
                             ELSE
                                 ''
                         END
                             t_doc_ser,
                         CASE
                             WHEN REGEXP_LIKE (s.prs_doc_num,
                                               '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                             THEN
                                 LPAD (SUBSTR (s.prs_doc_num, -6, 6), 9, '0')       -- старий паспорт
                             WHEN REGEXP_LIKE (s.prs_doc_num, '^(\d){9}$')
                             THEN
                                 s.prs_doc_num                -- новий паспорт
                             ELSE
                                 ''
                         END
                             t_doc_num,
                         CASE
                             WHEN EXISTS
                                      (SELECT 1
                                         FROM uss_esr.appeal   a,
                                              uss_esr.ap_person p
                                        WHERE     a.ap_pc = s.prs_pc
                                              AND p.app_ap = a.ap_id
                                              AND p.history_status = 'A'
                                              AND p.app_tp = 'P') -- Представник заявника )
                             THEN
                                 '1'
                             ELSE
                                 '0'
                         END
                             t_is_poa
                    FROM payroll p
                         JOIN pr_sheet s ON prs_pr = pr_id
                         JOIN v_opfu op ON op.org_id = p.com_org
                         JOIN uss_ndi.v_ndi_payment_codes npc
                             ON npc.npc_id = p.pr_npc
                         LEFT JOIN uss_ndi.v_ndi_street ns
                             ON ns.ns_id = s.prs_ns
                         LEFT JOIN uss_ndi.v_ndi_street_type nst
                             ON nst.nsrt_id = ns.ns_nsrt
                         LEFT JOIN uss_ndi.v_ndi_delivery dd
                             ON dd.nd_id = s.prs_nd
                   --where pr_id = 28053
                   WHERE     pr_id = p_pr_id
                         AND pr_pay_tp = 'POST'
                         AND prs_sum > 0
                         AND prs_st NOT IN ('PP')
                         AND PRS_tp IN ('PP')                -- Виплата поштою
                         AND EXISTS
                                 (SELECT 1
                                    FROM payroll_reestr pe
                                   WHERE     pe.pe_pr = s.prs_pr
                                         AND pe.pe_po = p_po_id
                                         AND pe.pe_filia_code = s.prs_index
                                         AND pe.pe_pay_dt = s.prs_pay_dt)
                GROUP BY op.org_code,
                         TO_CHAR (pr_start_dt, 'mm'),
                         TO_CHAR (pr_start_dt, 'yyyy'),
                         CASE pr_tp WHEN 'M' THEN '01' WHEN 'A' THEN '02' END,
                         LPAD (s.prs_index, 5, '0'),
                         prs_num,
                         prs_pc_num,
                         s.prs_doc_num,
                         REPLACE (
                             SUBSTR (
                                 UPPER (
                                     TRIM (
                                         CONCAT (
                                                TRIM (
                                                    CONCAT (
                                                           TRIM (s.prs_ln)
                                                        || ' ',
                                                        TRIM (s.prs_fn)))
                                             || ' ',
                                             TRIM (s.prs_mn)))),
                                 1,
                                 50),
                             ',',
                             ''),
                         TO_CHAR (prs_pay_dt, 'dd'),
                         REPLACE (
                                s.prs_building
                             || ';'
                             || s.prs_block
                             || ';'
                             || s.prs_apartment,
                             ',',
                             ''),
                         SUBSTR (
                             UPPER (
                                 REPLACE (NVL (ns.ns_name, s.prs_street),
                                          ',',
                                          '')),
                             1,
                             50),
                         NVL (ns.ns_code, '0'),
                         CASE
                             WHEN dd.nd_code IS NOT NULL THEN 'D'
                             ELSE NULL
                         END,
                         dd.nd_code,
                         pr_id,
                         prs_pay_dt,
                         prs_pc,
                         npc.npc_code;

            IF SQL%ROWCOUNT = 0
            THEN
                RAISE NO_DATA_FOUND;
            END IF;

            UPDATE TMP_POST_TO_EXPORT t
               SET (t.t_dlvr_tp, t.t_dlvr_code) =
                       (SELECT 'D', pdm_nd_num
                          FROM (SELECT pdm_nd_num,
                                       ROW_NUMBER ()
                                           OVER (
                                               PARTITION BY pd_pc
                                               ORDER BY
                                                   DECODE (pd_st, 'S', 1, 0) DESC,
                                                   pd.pd_start_dt DESC)    AS rn
                                  FROM pr_sheet  s
                                       JOIN pc_account a ON pa_id = prs_pa
                                       JOIN pc_decision pd
                                           ON     prs_pc = pd_pc
                                              AND pd_nst = pa_nst
                                       JOIN pd_pay_method pdm
                                           ON     pd_id = pdm_pd
                                              AND pdm.history_status = 'A'
                                              AND pdm_is_actual = 'T'
                                 WHERE     s.prs_id = t.t_prs_id
                                       AND pdm.pdm_pay_tp = 'POST'
                                       AND pdm.pdm_nd_num IS NOT NULL)
                         WHERE rn = 1)
             WHERE     t.t_dlvr_code IS NULL
                   AND EXISTS
                           (SELECT 1
                              FROM pr_sheet  s
                                   JOIN pc_account a ON pa_id = prs_pa
                                   JOIN pc_decision pd
                                       ON prs_pc = pd_pc AND pd_nst = pa_nst
                                   JOIN pd_pay_method pdm
                                       ON     pd_id = pdm_pd
                                          AND pdm.history_status = 'A'
                                          AND pdm_is_actual = 'T'
                             WHERE     s.prs_id = t.t_prs_id
                                   AND pdm.pdm_pay_tp = 'POST'
                                   AND pdm.pdm_nd_num IS NOT NULL);

            UPDATE TMP_POST_TO_EXPORT t
               SET t.t_dlvr_tp = 'P'
             WHERE t.t_dlvr_code IS NULL AND t.t_dlvr_tp IS NULL;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RAISE;
            WHEN OTHERS
            THEN
                raise_application_error (
                    -20000,
                       'Помилка читання даних:'
                    || CHR (10)
                    || SQLERRM
                    || DBMS_UTILITY.format_error_backtrace);
        END create_temp_data;
    BEGIN
        DELETE FROM ikis_rbm.tmp_exchangefiles_m1;

        l_filter :=
            p_pr_id || '#' || p_prs_tp || '#' || p_rec_id || '#PO' || p_po_id;

        SELECT COUNT (1)
          INTO l_cnt
          FROM exchcreatesession
         WHERE ecs_filter = l_filter;

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                'Створення файлів з даними параметрами вже виконувалось!');
        END IF;

        INSERT INTO exchcreatesession (ecs_id, ecs_start_dt, ecs_filter)
             VALUES (0, SYSDATE, l_filter)
          RETURNING ecs_id
               INTO l_ecs;

        create_temp_data;

        SELECT c.npc_code,
               c.npc_name,
               NULL                            pr_pay_dt,
               LPAD (c.npc_code, 2, '0')       pr_type,
               c.npc_id,
               com_org,
                  XMLELEMENT ("opfu_code", o.org_id)
               || XMLELEMENT ("opfu_name",
                              CONVERT (TOOLS.GetOrgSName (org_id), 'UTF8'))
               || XMLELEMENT ("date_cr",
                              TO_CHAR (p.pr_create_dt, 'DDMMYYYY'))
               || XMLELEMENT ("MFO_filia", '')
               || XMLELEMENT ("filia_num", '')
               || XMLELEMENT ("filia_name", '')
               || XMLELEMENT ("full_sum", l_pp_sum)
               || XMLELEMENT ("full_lines", l_pp_cnt)
               || XMLELEMENT ("type", LPAD (c.npc_code, 2, '0'))
               || XMLELEMENT ("id_cor", '')    xdata              -- ef_header
          INTO l_pr_code,
               l_pr_name,
               l_pay_dt,
               l_pr_type,
               l_npc_id,
               l_com_org,
               l_xdata
          FROM payroll  p
               JOIN uss_ndi.v_ndi_payment_codes c ON c.npc_id = p.pr_npc
               JOIN v_opfu o ON o.org_id = p.com_org
         WHERE pr_id = p_pr_id;

        -- загальні атрибути пакета
        SELECT    '<p style="text-align: center;">Опис вмісту пакета на виплату (пошта)<br>'
               || l_pr_name
               || CHR (10)
               || '</p><div class="RptTable">'
               || '<table><tbody><tr><td>Індекс</td><td>Кількість одержувачів</td><td>Сума, гривень</td></tr>'
               || XMLAGG (
                      XMLELEMENT ("tr",
                                  XMLELEMENT ("td", NVL (x_index, 'Всього')),
                                  XMLELEMENT ("td", x_cnt),
                                  XMLELEMENT ("td", TO_CHAR (x_sum)))).getClobVal ()
               || '</tbody></table></div>'            b_visual_data,
               SUM (DECODE (x_index, NULL, x_cnt))    x_cnt,
               SUM (DECODE (x_index, NULL, x_sum))    x_sum,
               MAX (t_per_num)                        t_per_num
          INTO l_visual_data,
               l_pp_cnt,
               l_pp_sum,
               l_per_num
          FROM (  SELECT s.t_npo_index        x_index,
                         COUNT (*)            x_cnt,
                         SUM (s.t_pp_sum)     x_sum,
                         MAX (t_per_num)      t_per_num
                    FROM TMP_POST_TO_EXPORT s
                GROUP BY ROLLUP (s.t_npo_index)
                ORDER BY 1);

        WITH
            dat
            AS
                (SELECT SUBSTR (TRIM (TO_CHAR (org_id, '000009')), 1, 3)
                            p_opfu,
                        SUBSTR (
                            REPLACE (org_name, 'Головне управління ', 'ГУ'),
                            1,
                            27)
                            p_opfu_name,
                        c.npc_name
                            p_pr_header,
                        org_id
                            p_org_id,
                        TOOLS.GetOrgSName (org_id)
                            p_org_name,
                        pr_create_dt
                            p_pr_dt,
                        pr_start_dt,
                        l_pp_sum
                            p_pr_sum,
                        l_pp_cnt
                            p_pr_cnt
                   FROM uss_esr.payroll              p,
                        v_opfu,
                        uss_ndi.v_ndi_payment_codes  c
                  WHERE     pr_id = p_pr_id
                        AND com_org = org_id
                        AND c.npc_id = p.pr_npc)
        SELECT    p_org_id
               || '-'
               || l_pr_type
               || '-'
               || LPAD (l_per_num, 2, '0')
               || '-'
               || TO_CHAR (pr_start_dt, 'mmyyyy')            v_file_name,
               UTL_COMPRESS.lz_compress (tools.ConvertC2B (
                                             (SELECT XMLELEMENT (
                                                         "description_files",
                                                         -- XMLELEMENT("id", p_pr_id),
                                                         XMLELEMENT (
                                                             "opfu_code",
                                                             p_org_id),
                                                         XMLELEMENT (
                                                             "opfu_name",
                                                             CONVERT (
                                                                 p_org_name,
                                                                 'UTF8')),
                                                         XMLELEMENT (
                                                             "date_cr",
                                                             TO_CHAR (
                                                                 p_pr_dt,
                                                                 'DDMMYYYY')),
                                                         XMLELEMENT (
                                                             "MFO_filia",
                                                             ''),
                                                         XMLELEMENT (
                                                             "filia_num",
                                                             ''),
                                                         XMLELEMENT (
                                                             "filia_name",
                                                             ''),
                                                         XMLELEMENT (
                                                             "full_sum",
                                                             p_pr_sum),
                                                         XMLELEMENT (
                                                             "full_lines",
                                                             p_pr_cnt),
                                                         XMLELEMENT (
                                                             "type",
                                                             l_pr_type),
                                                         XMLELEMENT (
                                                             "id_cor",
                                                             ''),
                                                         XMLELEMENT (
                                                             "branches",
                                                             XMLAGG (XMLELEMENT (
                                                                         "row",
                                                                         XMLELEMENT (
                                                                             "branch_num",
                                                                             a.t_npo_index),
                                                                         XMLELEMENT (
                                                                             "branch_sum",
                                                                             a.sum_pp),
                                                                         XMLELEMENT (
                                                                             "branch_lines",
                                                                             a.cnt_pp),
                                                                         XMLELEMENT (
                                                                             "date_pay",
                                                                             ''),
                                                                         XMLELEMENT (
                                                                             "num_list",
                                                                             a.rn),
                                                                         XMLELEMENT (
                                                                             "file_name",
                                                                             a.file_name),
                                                                         XMLELEMENT (
                                                                             "file_data",
                                                                             API$ESR_EXCHANGE.getPostFile (
                                                                                 a.t_org_code,
                                                                                 a.t_npo_index,
                                                                                 l_pr_type,
                                                                                 a.file_name)),
                                                                         XMLELEMENT (
                                                                             "branch_opfu_code",
                                                                             t_org_code))
                                                                     ORDER BY
                                                             a.rn  ))).getClobVal ()    v_file_data
                                                FROM (  SELECT t.t_org_code,
                                                               t.t_npo_index,
                                                               SUM (t_pp_sum)
                                                                   sum_pp,
                                                               COUNT (*)
                                                                   cnt_pp,
                                                                  t.t_npo_index -- індекс відділенням зв'язку (5 цифр)
                                                               || '.'
                                                               || l_pr_type -- тип відомості на виплату («78»)
                                                               || '.'
                                                               || LPAD (
                                                                      TO_CHAR (
                                                                          MAX (
                                                                              t.t_per_num)),
                                                                      2,
                                                                      '0') -- номер періоду (6,7 символ заголовку)
                                                               || LPAD (
                                                                      TO_CHAR (
                                                                          MAX (
                                                                              t.t_per_month)),
                                                                      2,
                                                                      '0')
                                                               || LPAD (
                                                                      TO_CHAR (
                                                                          MAX (
                                                                              t.t_per_year)),
                                                                      4,
                                                                      '0') -- місяць та рік виплатного періоду
                                                               || '.'
                                                               || LPAD (
                                                                      t.t_org_code,
                                                                      5,
                                                                      0) -- код району
                                                                   file_name,
                                                               ROW_NUMBER ()
                                                                   OVER (
                                                                       ORDER BY
                                                                           t.t_org_code,
                                                                           t.t_npo_index)
                                                                   rn
                                                          FROM TMP_POST_TO_EXPORT
                                                               t
                                                      GROUP BY t.t_org_code,
                                                               t.t_npo_index)
                                                     a)))    v_file_data
          INTO l_file_name, l_data
          FROM dat;

        INSERT INTO exchangefiles (ef_id,
                                   ef_po,
                                   ef_pr,
                                   com_wu,
                                   com_org,
                                   ef_tp,
                                   ef_name,
                                   ef_data,
                                   ef_visual_data,
                                   ef_header,
                                   ef_main_tag_name,
                                   ef_data_name,
                                   ef_ecp_list_name,
                                   ef_ecp_name,
                                   ef_ecp_alg,
                                   ef_st,
                                   ef_ident_data,
                                   ef_dt,
                                   ef_ecs,
                                   ef_rec)
             VALUES (0,
                     p_po_id,
                     p_pr_id,
                     NULL,
                     l_com_org,
                     p_prs_tp,
                     l_file_name,
                     l_data,
                     l_visual_data,
                     l_xdata,
                     'paymentlists',
                     'file_data',
                     'ecp_list',
                     'ecp',
                     'MD',
                     'Z',
                     'Кількість: ' || l_pp_cnt || '; Сума: ' || l_pp_sum,
                     SYSDATE,
                     l_ecs,
                     p_rec_id)
          RETURNING ef_id
               INTO l_ef_id;

        INSERT INTO ikis_rbm.tmp_exchangefiles_m1 (ef_id,
                                                   ef_pr,
                                                   com_wu,
                                                   com_org,
                                                   ef_tp,
                                                   ef_name,
                                                   ef_data,
                                                   ef_visual_data,
                                                   ef_header,
                                                   ef_main_tag_name,
                                                   ef_data_name,
                                                   ef_ecp_list_name,
                                                   ef_ecp_name,
                                                   ef_ecp_alg,
                                                   ef_st,
                                                   ef_dt,
                                                   ef_ident_data,
                                                   ef_ecs,
                                                   ef_rec,
                                                   ef_pr_code,
                                                   ef_pr_name,
                                                   ef_pr_pay_dt,
                                                   ef_npc)
            SELECT ef_id,
                   p_pr_id     AS ef_pr,
                   com_wu,
                   com_org,
                   ef_tp,
                   ef_name,
                   ef_data,
                   ef_visual_data,
                   ef_header,
                   ef_main_tag_name,
                   ef_data_name,
                   ef_ecp_list_name,
                   ef_ecp_name,
                   ef_ecp_alg,
                   ef_st,
                   ef_dt,
                   ef_ident_data,
                   ef_ecs,
                   ef_rec,
                   l_pr_code,
                   l_pr_name,
                   l_pay_dt,
                   l_npc_id
              FROM exchangefiles
             WHERE ef_id = l_ef_id;

        ikis_rbm.RDM$APP_EXCHANGE.GenPaketsFromTMPTable (l_pkt_id);

        l_file_name := l_file_name || '_' || TO_CHAR (l_pkt_id) || '.p7e';

        UPDATE exchangefiles f
           SET ef_pkt = l_pkt_id, ef_name = l_file_name
         WHERE ef_id = l_ef_id;

        SELECT *
          INTO l_pc_row
          FROM ikis_rbm.v_packet_content
         WHERE pc_pkt = l_pkt_id;

        l_pc_row.pc_name := l_file_name;
        ikis_rbm.RDM$PACKET_CONTENT.SET_PACKET_CONTENT (l_pc_row,
                                                        l_pc_row.pc_id);

        UPDATE exchcreatesession
           SET ecs_stop_dt = SYSDATE
         WHERE ecs_id = l_ecs;

        -- прописуємо ід сформованого пакета ПЕОД
        -- оскільки пакети по ВВ ПЕОД формуються під час фіксації ПД...
        UPDATE uss_esr.payroll_reestr pr
           SET pr.pe_rbm_pkt = l_pkt_id
         WHERE     pr.pe_po = p_po_id
               AND pr.pe_pay_tp = 1
               AND pr.pe_npc = l_npc_id
               AND pr.pe_src_entity = p_pr_id
               AND pr.pe_pr = p_pr_id
               AND pr.pe_rbm_pkt IS NULL;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20001,
                   'Відсутня інформація для побудови файлу електронних відомостей на пошту'
                || CHR (10)
                || SQLERRM
                || DBMS_UTILITY.format_error_backtrace);
        WHEN OTHERS
        THEN
            IF SQLCODE IN (-20001)
            THEN
                RAISE;
            END IF;

            raise_application_error (
                -20000,
                   'Помилка підготовки даних для побудови файлу електронних відомостей на пошту: '
                || CHR (10)
                || SQLERRM
                || DBMS_UTILITY.format_error_backtrace);
    END BuildPostExchFiles;
BEGIN
    NULL;
END API$ESR_EXCHANGE;
/