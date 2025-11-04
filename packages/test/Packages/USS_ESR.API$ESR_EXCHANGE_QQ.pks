/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$ESR_EXCHANGE_QQ
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
END api$esr_exchange_qq;
/
