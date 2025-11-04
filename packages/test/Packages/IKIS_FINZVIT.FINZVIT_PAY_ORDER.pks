/* Formatted on 8/12/2025 6:06:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_FINZVIT.FINZVIT_PAY_ORDER
IS
    -- Author  : MAXYM
    -- Created : 23.11.2017 11:32:00
    -- Purpose : Платіжні доручення

    PROCEDURE CheckCanChangePOAndLock (p_po_id IN NUMBER);

    PROCEDURE InsertPayOrder (
        --   p_PO_DATE_CREATE        pay_order.PO_DATE_CREATE%type,
        p_PO_DATE_PAY                pay_order.PO_DATE_PAY%TYPE,
        p_PO_SUM                     pay_order.PO_SUM%TYPE,
        --  p_PO_NUMBER            pay_order.PO_NUMBER%type,
        p_COM_ORG_SRC                pay_order.COM_ORG_SRC%TYPE,
        p_COM_ORG_DST                pay_order.COM_ORG_DST%TYPE,
        p_PO_BANK_ACCOUNT_SRC        pay_order.PO_BANK_ACCOUNT_SRC%TYPE,
        p_PO_BANK_ACCOUNT_DEST       pay_order.PO_BANK_ACCOUNT_DEST%TYPE,
        p_PO_BANK_MFO_SRC            pay_order.PO_BANK_MFO_SRC%TYPE,
        p_PO_BANK_MFO_DEST           pay_order.PO_BANK_MFO_DEST%TYPE,
        p_PO_TAX_CODE_SRC            pay_order.PO_TAX_CODE_SRC%TYPE,
        p_PO_TAX_CODE_DEST           pay_order.PO_TAX_CODE_DEST%TYPE,
        p_PO_NAME_SRC                pay_order.PO_NAME_SRC%TYPE,
        p_PO_NAME_DEST               pay_order.PO_NAME_DEST%TYPE,
        p_PO_BANK_NAME_SRC           pay_order.PO_BANK_NAME_SRC%TYPE,
        p_PO_BANK_NAME_DEST          pay_order.PO_BANK_NAME_DEST%TYPE,
        p_PO_SRC                     pay_order.PO_SRC%TYPE,
        --      p_PO_STATUS            pay_order.PO_STATUS%type,
        p_PO_PURPOSE                 pay_order.PO_PURPOSE%TYPE,
        p_PO_BI                      pay_order.PO_BI%TYPE,
        p_new_PO_ID              OUT pay_order.po_id%TYPE);

    PROCEDURE UpdatePayOrder (
        p_PO_ID                  IN pay_order.PO_ID%TYPE,
        p_PO_DATE_PAY            IN pay_order.PO_DATE_PAY%TYPE,
        p_PO_SUM                 IN pay_order.PO_SUM%TYPE,
        p_PO_BANK_ACCOUNT_SRC    IN pay_order.PO_BANK_ACCOUNT_SRC%TYPE,
        p_PO_BANK_ACCOUNT_DEST   IN pay_order.PO_BANK_ACCOUNT_DEST%TYPE,
        p_PO_BANK_MFO_SRC        IN pay_order.PO_BANK_MFO_SRC%TYPE,
        p_PO_BANK_MFO_DEST       IN pay_order.PO_BANK_MFO_DEST%TYPE,
        p_PO_TAX_CODE_SRC        IN pay_order.PO_TAX_CODE_SRC%TYPE,
        p_PO_TAX_CODE_DEST       IN pay_order.PO_TAX_CODE_DEST%TYPE,
        p_PO_NAME_SRC            IN pay_order.PO_NAME_SRC%TYPE,
        p_PO_NAME_DEST           IN pay_order.PO_NAME_DEST%TYPE,
        p_PO_BANK_NAME_SRC       IN pay_order.PO_BANK_NAME_SRC%TYPE,
        p_PO_BANK_NAME_DEST      IN pay_order.PO_BANK_NAME_DEST%TYPE,
        p_PO_PURPOSE             IN pay_order.PO_PURPOSE%TYPE,
        p_COM_ORG_SRC            IN pay_order.COM_ORG_SRC%TYPE,
        p_COM_ORG_DST            IN pay_order.COM_ORG_DST%TYPE,
        p_PO_BI                     pay_order.PO_BI%TYPE);

    PROCEDURE UpdatePayOrderSum (p_PO_ID    pay_order.po_id%TYPE,
                                 p_PO_SUM   pay_order.PO_SUM%TYPE);

    PROCEDURE DeletePayOrder (p_PO_ID pay_order.po_id%TYPE);

    PROCEDURE GetPayOrder (p_po_id IN NUMBER, p_result OUT SYS_REFCURSOR);

    PROCEDURE FixPayOrder (p_po_id IN NUMBER);

    PROCEDURE SetStatusUForDcsy (p_po_id IN NUMBER);

    PROCEDURE IsUStatusForDcsy (p_po_id IN NUMBER);

    PROCEDURE LockForPayOrder;
END FINZVIT_PAY_ORDER;
/


GRANT EXECUTE ON IKIS_FINZVIT.FINZVIT_PAY_ORDER TO DNET_PROXY
/


/* Formatted on 8/12/2025 6:06:33 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_FINZVIT.FINZVIT_PAY_ORDER
IS
    PROCEDURE CheckCanChangePOAndLock (p_po_id IN NUMBER)
    IS
        resource_busy   EXCEPTION;

        PRAGMA EXCEPTION_INIT (resource_busy, -54);
        l_row           v_pay_order%ROWTYPE;
    BEGIN
            SELECT *
              INTO l_row
              FROM v_pay_order
             WHERE po_id = p_po_id
        FOR UPDATE WAIT 30;

        IF (l_row.COM_ORG_SRC !=
            NVL (
                SYS_CONTEXT (ikis_finzvit_context.gContext,
                             ikis_finzvit_context.gOPFU),
                0))
        THEN
            raise_application_error (
                -20000,
                'Заборонено збереження в платіжні доручення іншого ОПФУ.');
        END IF;

        IF (l_row.PO_STATUS != 'E')
        THEN
            raise_application_error (
                -20000,
                'Заборонено збереження в платіжне доручення, яке не знаходиться в статусі "Редагується".');
        END IF;
    EXCEPTION
        WHEN resource_busy
        THEN
            raise_application_error (
                -20000,
                'Платіжне доручення оновлюється іншим користувачем.');
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (-20000,
                                     'Платіжне доручення не знайдено.');
    END;

    PROCEDURE LockForPayOrder
    IS
        l_handler   VARCHAR2 (100);
        l_org       NUMBER
            := SYS_CONTEXT (ikis_finzvit_context.gContext,
                            ikis_finzvit_context.gOPFU);
        l_year      PLS_INTEGER := EXTRACT (YEAR FROM SYSDATE);
    BEGIN
        ikis_sys.ikis_lock.Request_Lock (
            p_errmessage          =>
                'Платіжні доручення зараз формуються іншим користувачем. Зачекайте та повторіть операцію.',
            p_lockhandler         => l_handler,
            p_release_on_commit   => TRUE,
            p_timeout             => 20,
            p_permanent_name      => 'FZPO',
            p_var_name            => l_org || '_' || l_year);
    END;

    PROCEDURE InsertPayOrder (
        --   p_PO_DATE_CREATE        pay_order.PO_DATE_CREATE%type,
        p_PO_DATE_PAY                pay_order.PO_DATE_PAY%TYPE,
        p_PO_SUM                     pay_order.PO_SUM%TYPE,
        --  p_PO_NUMBER            pay_order.PO_NUMBER%type,
        p_COM_ORG_SRC                pay_order.COM_ORG_SRC%TYPE,
        p_COM_ORG_DST                pay_order.COM_ORG_DST%TYPE,
        p_PO_BANK_ACCOUNT_SRC        pay_order.PO_BANK_ACCOUNT_SRC%TYPE,
        p_PO_BANK_ACCOUNT_DEST       pay_order.PO_BANK_ACCOUNT_DEST%TYPE,
        p_PO_BANK_MFO_SRC            pay_order.PO_BANK_MFO_SRC%TYPE,
        p_PO_BANK_MFO_DEST           pay_order.PO_BANK_MFO_DEST%TYPE,
        p_PO_TAX_CODE_SRC            pay_order.PO_TAX_CODE_SRC%TYPE,
        p_PO_TAX_CODE_DEST           pay_order.PO_TAX_CODE_DEST%TYPE,
        p_PO_NAME_SRC                pay_order.PO_NAME_SRC%TYPE,
        p_PO_NAME_DEST               pay_order.PO_NAME_DEST%TYPE,
        p_PO_BANK_NAME_SRC           pay_order.PO_BANK_NAME_SRC%TYPE,
        p_PO_BANK_NAME_DEST          pay_order.PO_BANK_NAME_DEST%TYPE,
        p_PO_SRC                     pay_order.PO_SRC%TYPE,
        --                   p_PO_STATUS            pay_order.PO_STATUS%type,
        p_PO_PURPOSE                 pay_order.PO_PURPOSE%TYPE,
        p_PO_BI                      pay_order.PO_BI%TYPE,
        p_new_PO_ID              OUT pay_order.po_id%TYPE)
    IS
        l_next_num   PLS_INTEGER;
        l_org        NUMBER
            := SYS_CONTEXT (ikis_finzvit_context.gContext,
                            ikis_finzvit_context.gOPFU);
        l_year       PLS_INTEGER := EXTRACT (YEAR FROM SYSDATE);
    BEGIN
        --  raise_application_error(-20000,p_COM_ORG_SRC||'='||l_org);

        IF (p_COM_ORG_SRC IS NOT NULL AND p_COM_ORG_SRC != NVL (l_org, -1))
        THEN
            raise_application_error (
                -20000,
                'Платіжне доручення має належати лише поточному ОПФУ.');
        END IF;

        SELECT NVL (MAX (PO_NUMBER), 0) + 1
          INTO l_next_num
          FROM pay_order
         WHERE     COM_ORG_SRC = l_org
               AND EXTRACT (YEAR FROM PO_DATE_CREATE) = l_year;

        INSERT INTO pay_order (po_date_create,
                               po_date_pay,
                               po_sum,
                               po_number,
                               com_org_src,
                               com_org_dst,
                               po_bank_account_src,
                               po_bank_account_dest,
                               po_bank_mfo_src,
                               po_bank_mfo_dest,
                               po_tax_code_src,
                               po_tax_code_dest,
                               po_name_src,
                               po_name_dest,
                               po_bank_name_src,
                               po_bank_name_dest,
                               po_src,
                               po_status,
                               po_purpose,
                               po_bi)
             VALUES (SYSDATE,
                     p_po_date_pay,
                     p_po_sum,
                     l_next_num,
                     l_org,
                     p_com_org_dst,
                     p_po_bank_account_src,
                     p_po_bank_account_dest,
                     p_po_bank_mfo_src,
                     p_po_bank_mfo_dest,
                     p_po_tax_code_src,
                     p_po_tax_code_dest,
                     p_po_name_src,
                     p_po_name_dest,
                     p_po_bank_name_src,
                     p_po_bank_name_dest,
                     p_po_src,
                     'E',
                     p_po_purpose,
                     p_po_bi)
          RETURNING po_id
               INTO p_new_PO_ID;
    END;

    PROCEDURE UpdatePayOrder (
        p_PO_ID                  IN pay_order.PO_ID%TYPE,
        p_PO_DATE_PAY            IN pay_order.PO_DATE_PAY%TYPE,
        p_PO_SUM                 IN pay_order.PO_SUM%TYPE,
        p_PO_BANK_ACCOUNT_SRC    IN pay_order.PO_BANK_ACCOUNT_SRC%TYPE,
        p_PO_BANK_ACCOUNT_DEST   IN pay_order.PO_BANK_ACCOUNT_DEST%TYPE,
        p_PO_BANK_MFO_SRC        IN pay_order.PO_BANK_MFO_SRC%TYPE,
        p_PO_BANK_MFO_DEST       IN pay_order.PO_BANK_MFO_DEST%TYPE,
        p_PO_TAX_CODE_SRC        IN pay_order.PO_TAX_CODE_SRC%TYPE,
        p_PO_TAX_CODE_DEST       IN pay_order.PO_TAX_CODE_DEST%TYPE,
        p_PO_NAME_SRC            IN pay_order.PO_NAME_SRC%TYPE,
        p_PO_NAME_DEST           IN pay_order.PO_NAME_DEST%TYPE,
        p_PO_BANK_NAME_SRC       IN pay_order.PO_BANK_NAME_SRC%TYPE,
        p_PO_BANK_NAME_DEST      IN pay_order.PO_BANK_NAME_DEST%TYPE,
        p_PO_PURPOSE             IN pay_order.PO_PURPOSE%TYPE,
        p_COM_ORG_SRC            IN pay_order.COM_ORG_SRC%TYPE,
        p_COM_ORG_DST            IN pay_order.COM_ORG_DST%TYPE,
        p_PO_BI                     pay_order.PO_BI%TYPE)
    IS
        l_next_num   PLS_INTEGER;
        l_org        NUMBER
            := SYS_CONTEXT (ikis_finzvit_context.gContext,
                            ikis_finzvit_context.gOPFU);
        l_year       PLS_INTEGER := EXTRACT (YEAR FROM SYSDATE);
        l_status     pay_order.po_status%TYPE;
    BEGIN
        --  raise_application_error(-20000,p_COM_ORG_SRC||'='||l_org);

        IF (p_COM_ORG_SRC IS NOT NULL AND p_COM_ORG_SRC != NVL (l_org, -1))
        THEN
            raise_application_error (
                -20000,
                'Платіжне доручення має належати лише поточному ОПФУ.');
        END IF;

        SELECT PO_STATUS
          INTO l_status
          FROM PAY_ORDER
         WHERE PO_ID = p_PO_ID;

        IF l_status NOT IN ('E', 'U')
        THEN
            raise_application_error (
                -20000,
                'Оновлення данних можливе лише в статусі "Редагується" чи "Вивантажене".');
        END IF;

        /*  select nvl(max(PO_NUMBER), 0) + 1
         into l_next_num
         from pay_order
        where COM_ORG_SRC = l_org
          and EXTRACT(year from PO_DATE_CREATE) = l_year;*/
        UPDATE PAY_ORDER
           SET po_date_pay = p_PO_DATE_PAY,
               po_sum = p_PO_SUM,
               po_bank_account_src = p_PO_BANK_ACCOUNT_SRC,
               po_bank_account_dest = p_PO_BANK_ACCOUNT_DEST,
               po_bank_mfo_src = p_PO_BANK_MFO_SRC,
               po_bank_mfo_dest = p_PO_BANK_MFO_DEST,
               po_tax_code_src = p_PO_TAX_CODE_SRC,
               po_tax_code_dest = p_PO_TAX_CODE_DEST,
               po_name_src = p_PO_NAME_SRC,
               po_name_dest = p_PO_NAME_DEST,
               po_bank_name_src = p_PO_BANK_NAME_SRC,
               po_bank_name_dest = p_PO_BANK_NAME_DEST,
               po_purpose = p_PO_PURPOSE,
               po_status = 'E',
               po_bi = p_po_bi
         WHERE po_id = p_PO_ID;
    END;

    PROCEDURE UpdatePayOrderSum (p_PO_ID    pay_order.po_id%TYPE,
                                 p_PO_SUM   pay_order.PO_SUM%TYPE)
    IS
    BEGIN
        CheckCanChangePOAndLock (p_po_id => p_PO_ID);

        UPDATE pay_order
           SET po_sum = p_PO_SUM
         WHERE po_id = p_PO_ID;
    END;

    PROCEDURE DeletePayOrder (p_PO_ID pay_order.po_id%TYPE)
    IS
    BEGIN
        CheckCanChangePOAndLock (p_po_id => p_PO_ID);

        -- update distrib lines

        UPDATE distrib_line l
           SET l.dl_po_gov = NULL
         WHERE l.dl_po_gov = p_PO_ID;

        UPDATE distrib_line l
           SET l.dl_po_own = NULL
         WHERE l.dl_po_own = p_PO_ID;

        DELETE FROM dkg_po_link l
              WHERE l.dpl_po = p_PO_ID;

        DELETE FROM ppvp_po_link l
              WHERE l.ppl_po = p_PO_ID;

        DELETE PAY_ORDER
         WHERE po_id = p_PO_ID;
    END;

    PROCEDURE GetPayOrder (p_po_id IN NUMBER, p_result OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_result FOR SELECT *
                            FROM V_PAY_ORDER po
                           WHERE po.PO_ID = p_po_id;
    END;

    PROCEDURE FixPayOrder (p_po_id IN NUMBER)
    IS
        l_com_org_src            V_PAY_ORDER.COM_ORG_SRC%TYPE;
        l_po_src                 V_PAY_ORDER.PO_SRC%TYPE;
        l_po_purpose             V_PAY_ORDER.PO_PURPOSE%TYPE;
        l_po_date_create         V_PAY_ORDER.PO_DATE_CREATE%TYPE;
        l_po_sum                 V_PAY_ORDER.PO_SUM%TYPE;
        l_po_bank_account_src    V_PAY_ORDER.PO_BANK_ACCOUNT_SRC%TYPE;
        l_po_bank_mfo_src        V_PAY_ORDER.PO_BANK_MFO_SRC%TYPE;
        l_po_bank_name_src       V_PAY_ORDER.PO_BANK_NAME_SRC%TYPE;
        l_po_tax_code_src        V_PAY_ORDER.PO_TAX_CODE_SRC%TYPE;
        l_po_name_src            V_PAY_ORDER.PO_NAME_SRC%TYPE;
        l_po_bank_account_dest   V_PAY_ORDER.PO_BANK_ACCOUNT_DEST%TYPE;
        l_po_bank_mfo_dest       V_PAY_ORDER.PO_BANK_MFO_DEST%TYPE;
        l_po_bank_name_dest      V_PAY_ORDER.PO_BANK_NAME_DEST%TYPE;
        l_po_tax_code_dest       V_PAY_ORDER.PO_TAX_CODE_DEST%TYPE;
        l_po_name_dest           V_PAY_ORDER.PO_NAME_DEST%TYPE;
        l_po_number              V_PAY_ORDER.PO_NUMBER%TYPE;
        l_po_status              V_PAY_ORDER.PO_STATUS%TYPE;
    BEGIN
        SELECT po.COM_ORG_SRC,
               po.PO_SRC,
               po.PO_PURPOSE,
               po.PO_DATE_CREATE,
               po.PO_SUM,
               po.PO_BANK_ACCOUNT_SRC,
               po.PO_BANK_MFO_SRC,
               po.PO_BANK_NAME_SRC,
               po.PO_TAX_CODE_SRC,
               po.PO_NAME_SRC,
               po.PO_BANK_ACCOUNT_DEST,
               po.PO_BANK_MFO_DEST,
               po.PO_BANK_NAME_DEST,
               po.PO_TAX_CODE_DEST,
               po.PO_NAME_DEST,
               po.PO_NUMBER,
               po.PO_STATUS
          INTO l_com_org_src,
               l_po_src,
               l_po_purpose,
               l_po_date_create,
               l_po_sum,
               l_po_bank_account_src,
               l_po_bank_mfo_src,
               l_po_bank_name_src,
               l_po_tax_code_src,
               l_po_name_src,
               l_po_bank_account_dest,
               l_po_bank_mfo_dest,
               l_po_bank_name_dest,
               l_po_tax_code_dest,
               l_po_name_dest,
               l_po_number,
               l_po_status
          FROM V_PAY_ORDER po
         WHERE po.PO_ID = p_po_id;

        IF (LENGTH (l_po_purpose) > 148 OR LENGTH (l_po_purpose) = 0)
        THEN
            raise_application_error (
                -20000,
                   'Призначення платежу повине бути заповнене та бути не більше 148 символів. Номер платіжного доручення: '
                || l_po_number);
        END IF;

        IF l_po_status NOT IN ('U')
        THEN
            raise_application_error (
                -20000,
                   'Фіксація платіжного доручення можлива лише в статусі "Вивантажене". Номер платіжного доручення: '
                || l_po_number);
        END IF;

        UPDATE PAY_ORDER
           SET PO_STATUS = 'A',
               PO_PURPOSE = '*' || p_po_id || ' ' || l_po_purpose
         WHERE PO_ID = p_po_id;
    END;

    PROCEDURE SetStatusUForDcsy (p_po_id IN NUMBER)
    IS
        l_PO_STATUS   V_PAY_ORDER.PO_STATUS%TYPE;
        l_po_number   V_PAY_ORDER.PO_NUMBER%TYPE;
    BEGIN
        SELECT po.PO_STATUS, po.PO_NUMBER
          INTO l_PO_STATUS, l_po_number
          FROM V_PAY_ORDER po
         WHERE po.PO_ID = p_po_id;

        IF (l_PO_STATUS = 'U')
        THEN
            raise_application_error (
                -20000,
                   'Призначення платежу не може бути в статусі "Вивантажене". Номер платіжного доручення: '
                || l_po_number);
        END IF;

        --- Поки не реалізовано вивантаження в файл зміна статуса закрита
        UPDATE PAY_ORDER
           SET PO_STATUS = 'U'
         WHERE PO_ID = p_po_id;
    END;

    PROCEDURE IsUStatusForDcsy (p_po_id IN NUMBER)
    IS
        l_PO_STATUS   V_PAY_ORDER.PO_STATUS%TYPE;
        l_po_number   V_PAY_ORDER.PO_NUMBER%TYPE;
    BEGIN
        SELECT po.PO_STATUS, po.PO_NUMBER
          INTO l_PO_STATUS, l_po_number
          FROM V_PAY_ORDER po
         WHERE po.PO_ID = p_po_id;

        IF (l_PO_STATUS <> 'U')
        THEN
            raise_application_error (
                -20000,
                   'Повторне вивантаження платіжного дорученя можливе лише в статусі "Вивантажене". Номер платіжного доручення: '
                || l_po_number);
        END IF;
    END;
END FINZVIT_PAY_ORDER;
/