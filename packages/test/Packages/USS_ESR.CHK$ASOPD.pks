/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.CHK$ASOPD
IS
    -- Author  : OPERVIEIEV
    -- Created : 08.2022
    -- звіряння даних (IMP_PAYROLL+IPR_SHEET) файлу реєстру виплат АСОПД з відповідними даними ЄІССС (PAYROLL+PR_SHEET)

    -- p_writ BITMAP TARGETS RESULTS TO: dbms_output(2) and/or blob(1) and/or protocol table (4) and/or IMP_PAYROLL update (8)

    -- #79392 дані АСОПД "контрольні" і повинні бути присутні в ЄІССС
    -- формування протоколу
    -- параметр - номер щойно завантаженого файлу
    PROCEDURE CMP_Payroll_Bank (p_lfd_id NUMBER, p_writ NUMBER DEFAULT 5);

    -- #80207 дані АСОПД "основні" і не повинні бути присутні ні в попередніх АСОПД ні в ЄІССС
    -- параметр - номер щойно завантаженого файлу
    -- одиночний режим формує протокол і відмічає IMP_PAYROLL як "хороший" F чи "поганий" S
    -- повертає NULL для "хорошої" відомості інакше певний LOG_MSG
    FUNCTION CMP_Payroll_Double (p_lfd_id NUMBER, p_writ NUMBER DEFAULT 5)
        RETURN VARCHAR2;

    -- пакетний режим, викликається лише на останньому файл за весь ZIP
    -- всередині себе викликає ASOPD_Payroll_Apply для "хороших" вхідних відомостей
    FUNCTION CMP_Payroll_Double_Z (p_lfd_id NUMBER, p_writ NUMBER DEFAULT 13)
        RETURN VARCHAR2;

    -- #80207 якщо дані АСОПД "хороші" переносимо їх з тимчасових структур (IMP_PAYROLL+IPR_SHEET) до основних (PAYROLL+PR_SHEET)
    -- має сенс тільки для одиночного режиму
    -- параметр - номер щойно завантаженого файлу, можемо примусово вказати номер цільової відомості (debug)
    PROCEDURE ASOPD_Payroll_Apply (p_lfd_id        NUMBER,
                                   p_force_pr_id   NUMBER DEFAULT NULL);

    -- чого тільки не зробиш, щоб не давати гранти на IMP_PAYROLL схемі USS_EXCH
    TYPE r_IPR_ST IS RECORD
    (
        ipr_id     NUMBER,
        ipr_st     VARCHAR2 (10),
        ipr_lfd    NUMBER
    );

    TYPE t_IPR_ST IS TABLE OF r_IPR_ST;

    FUNCTION Get_IPR_ST (p_lfd_id NUMBER)
        RETURN t_IPR_ST
        PIPELINED;
-- виклики використовуються у SELECT * FROM USS_EXCH.LOAD_FILE_SQL where lfs_tp='L' and lfs_lfv in (19,20)

END CHK$ASOPD;
/


GRANT EXECUTE ON USS_ESR.CHK$ASOPD TO II01RC_USS_ESR_INTERNAL
/

GRANT EXECUTE ON USS_ESR.CHK$ASOPD TO IKIS_RBM
/

GRANT EXECUTE ON USS_ESR.CHK$ASOPD TO USS_PERSON
/

GRANT EXECUTE ON USS_ESR.CHK$ASOPD TO USS_RPT
/

GRANT EXECUTE ON USS_ESR.CHK$ASOPD TO USS_VISIT
/


/* Formatted on 8/12/2025 5:49:18 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.CHK$ASOPD
IS
    TYPE t_Stats IS TABLE OF NUMBER
        INDEX BY VARCHAR2 (30);

    g_writ   NUMBER := 13; -- TARGETS TO: dbms_output(2) and/or blob(1) and/or protocol table (4) and/or IMP_PAYROLL update (8)

    PROCEDURE Write_Ln (p_line                 VARCHAR2,
                        p_blob   IN OUT NOCOPY BLOB,
                        p_writ                 NUMBER DEFAULT g_writ)
    IS
        vCharData   VARCHAR2 (4000);
        vRawData    RAW (4000);
    BEGIN
        IF BITAND (p_writ, 2) != 0
        THEN
            DBMS_OUTPUT.put_line (p_line);
        END IF;

        IF BITAND (p_writ, 1) != 0
        THEN
            vCharData := TRIM (p_line) || CHR (13) || CHR (10);
            vRawData := UTL_RAW.cast_to_raw (vCharData);
            DBMS_LOB.writeappend (p_blob,
                                  FLOOR (LENGTH (vRawData) / 2),
                                  vRawData);
        END IF;
    END Write_Ln;

    PROCEDURE Stats_Init (p_stats IN OUT t_Stats)
    IS
    BEGIN
        p_Stats.Delete;
    END Stats_Init;

    PROCEDURE Stats_Inc (p_stats     IN OUT t_Stats,
                         p_Measure   IN     VARCHAR2,
                         p_num              NUMBER DEFAULT 1)
    IS
    BEGIN
        p_Stats (p_Measure) :=
            CASE
                WHEN p_Stats.EXISTS (p_Measure)
                THEN
                    p_Stats (p_Measure) + p_num
                ELSE
                    p_num
            END;
    END Stats_Inc;

    FUNCTION Stats_Out (p_stats t_Stats, p_template VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_Idx      VARCHAR2 (30);
        l_Result   VARCHAR2 (4000);
    BEGIN
        IF p_template IS NULL
        THEN
            l_Idx := p_Stats.FIRST;

            WHILE (l_Idx IS NOT NULL)
            LOOP
                l_Result :=
                       l_Result
                    || l_Idx
                    || ': '
                    || p_Stats (l_Idx)
                    || CHR (13)
                    || CHR (10);
                l_Idx := p_Stats.NEXT (l_Idx);
            END LOOP;
        ELSIF p_template = 'JSON'
        THEN                                            -- predefined template
            l_result := '{' || CHR (13) || CHR (10);
            l_Idx := p_Stats.FIRST;

            WHILE (l_Idx IS NOT NULL)
            LOOP
                l_Result :=
                       l_Result
                    || '"'
                    || UPPER (REPLACE (l_idx, ' ', '_'))
                    || '":'
                    || p_Stats (l_Idx)
                    || ','
                    || CHR (13)
                    || CHR (10);                          -- stats are numbers
                l_Idx := p_Stats.NEXT (l_Idx);
            END LOOP;

            l_result := RTRIM (l_result, ',') || '}';
        ELSE                                             -- freestyle template
            l_result := p_template;

            FOR ss IN 1 .. REGEXP_COUNT (p_template, '##(.*?)##')
            LOOP
                l_idx :=
                    REPLACE (REGEXP_SUBSTR (p_template,
                                            '##(.*?)##',
                                            1,
                                            ss),
                             '#');
                l_result :=
                    REPLACE (
                        l_result,
                        '##' || l_idx || '##',
                        CASE
                            WHEN p_Stats.EXISTS (l_idx) THEN p_Stats (l_idx)
                            ELSE '##' || l_idx || '##'
                        END);
            END LOOP;
        END IF;

        RETURN l_Result;
    END Stats_Out;

    FUNCTION CHK_IBAN (p_Num IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Sum      NUMBER := 0;
        l_Chars    VARCHAR2 (9);
        l_Number   VARCHAR2 (34)
                       := SUBSTR (p_Num, 5) || '3010' || SUBSTR (p_Num, 3, 2);
    BEGIN
        --  IF NOT Regexp_Like(p_num,'^[U]{1}[A]{1}[0-9]{27}$')
        IF    p_Num IS NULL
           OR SUBSTR (p_Num, 1, 2) != 'UA'
           OR REGEXP_INSTR (l_Number, '\D') > 0
        THEN
            RETURN 'NOT';
        END IF;

        l_Chars := SUBSTR (l_Number, 1, 9);
        l_Sum := MOD (TO_NUMBER (l_Chars), 97);
        l_Chars := l_Sum || SUBSTR (l_Number, 10, 7);
        l_Sum := MOD (TO_NUMBER (l_Chars), 97);
        l_Chars := l_Sum || SUBSTR (l_Number, 17, 7);
        l_Sum := MOD (TO_NUMBER (l_Chars), 97);
        l_Chars := l_Sum || SUBSTR (l_Number, 24, 7);
        l_Sum := MOD (TO_NUMBER (l_Chars), 97);
        l_Chars := l_Sum || SUBSTR (l_Number, LENGTH (l_Number), 1);
        l_Sum := MOD (TO_NUMBER (l_Chars), 97);

        IF l_Sum != 1
        THEN
            RETURN 'BAD';
        END IF;

        RETURN 'OK';
    END CHK_IBAN;

    FUNCTION Get_IPR_ST (p_lfd_id NUMBER)
        RETURN t_IPR_ST
        PIPELINED
    IS
        l_row   r_IPR_ST;
    BEGIN
        FOR cc
            IN (SELECT z.ipr_id, z.ipr_st, z.ipr_lfd
                  FROM imp_payroll  z
                       JOIN imp_payroll l ON l.ipr_lfd_lfd = z.ipr_lfd_lfd
                 WHERE l.ipr_lfd = p_lfd_id)
        LOOP
            l_row.ipr_id := cc.ipr_id;
            l_row.ipr_st := cc.ipr_st;
            l_row.ipr_lfd := cc.ipr_lfd;
            PIPE ROW (l_row);
        END LOOP;

        RETURN;
    END Get_IPR_ST;

    FUNCTION CMP_Payroll_Double_Z (p_lfd_id NUMBER, p_writ NUMBER DEFAULT 13)
        RETURN VARCHAR2
    IS
        l_blob_stat   BLOB;
        l_buf         VARCHAR2 (2000);
        g_Stats       t_Stats;
        l_doubles     t_Stats;                         -- key IPR_ID value CNT
        l_err         VARCHAR2 (2000);
        l_ipr_id      NUMBER;
        l_zip_id      NUMBER;
    BEGIN
        g_writ := NVL (p_writ, g_writ);                  -- writing target(-s)
        DBMS_LOB.createtemporary (l_blob_stat, TRUE);
        stats_init (g_stats);

        -- heading multifile
        Write_Ln ('ЗВІРЯННЯ НА ДУБЛІ АРХІВУ виплатних відомістей АСОПД :',
                  l_blob_stat);

        FOR cf
            IN (  SELECT z.*, p.*
                    FROM uss_exch.v_ls2uss v
                         JOIN uss_exch.v_payroll_bank_heading l
                             ON l.lfd_id = p_lfd_id              -- LAST ENTRY
                         JOIN uss_exch.v_payroll_bank_heading z
                             ON z.lfd_lfd = l.lfd_lfd AND z.lfd_id = v.lfd_id
                         JOIN imp_payroll p
                             ON p.ipr_id = v.ldr_trg AND ipr_src = 20
                   WHERE v.ldr_code = 'USS_ESR.IMP_PAYROLL'
                ORDER BY 1)
        LOOP
            Write_Ln (
                   cf.ipr_id
                || ' = ['
                || cf.lfd_file_name
                || ' : '
                || cf.payer_name
                || ' >> '
                || cf.recipient_name
                || ' , '
                || cf.purpose_payment
                || ']'
                || ' місяць '
                || TO_CHAR (cf.ipr_month, 'MM.YYYY')
                || ' ОСЗН '
                || cf.com_org
                || ' допомога '
                || cf.ipr_npc
                || ' справ '
                || cf.ipr_pc_cnt
                || ' сума '
                || cf.ipr_sum,
                l_blob_stat);

            UPDATE imp_payroll
               SET ipr_lfd = cf.lfd_id, ipr_lfd_lfd = cf.lfd_lfd
             WHERE ipr_id = cf.ipr_id;

            l_zip_id := cf.lfd_lfd;
        END LOOP;

        -- Внутрішні дублі
        FOR c
            IN (SELECT /*+ ORDERED */
                       n.iprs_inn,
                       n.iprs_ln,
                       n.iprs_npt,                                      -- KEY
                       op.com_org,
                       n.iprs_fn,
                       n.iprs_pay_dt,
                       o.iprs_pay_dt      oprs_pay_dt,
                       n.iprs_account,
                       o.iprs_account     oprs_account,
                       n.iprs_ipr,
                       o.iprs_ipr         oprs_ipr
                  FROM ipr_sheet  n
                       JOIN imp_payroll np
                           ON     np.ipr_id = n.iprs_ipr
                              AND np.ipr_lfd_lfd = l_zip_id -- newcomers filter
                       JOIN ipr_sheet o
                           ON     n.iprs_inn = o.iprs_inn
                              AND NVL (n.iprs_npt, 0) = NVL (o.iprs_npt, 0)
                              AND n.iprs_id != o.iprs_id
                              AND                                -- not itself
                                  DECODE (n.iprs_inn,
                                          '0000000000', n.iprs_account,
                                          'X') =
                                  DECODE (o.iprs_inn,
                                          '0000000000', o.iprs_account,
                                          'X')
                              AND TRUNC (n.iprs_pay_dt, 'MM') =
                                  TRUNC (o.iprs_pay_dt, 'MM') -- more conditions here
                       JOIN imp_payroll op
                           ON     op.ipr_id = o.iprs_ipr
                              AND op.ipr_src = 20
                              AND op.ipr_st = 'C'
                 WHERE 1 = 1)
        LOOP
            l_buf :=
                   'Відомість '
                || c.iprs_ipr
                || ' отримувач ['
                || c.iprs_ln
                || ' ІПН '
                || c.iprs_inn
                || ' IBAN '
                || c.iprs_account
                || '] дубль з даними АСОПД '
                || c.oprs_ipr;
            Write_Ln (l_buf, l_blob_stat);
            stats_inc (l_doubles, TO_CHAR (c.iprs_ipr));
            stats_inc (g_stats, 'дублів АСОПД');
        END LOOP;

        -- дублі з наявними основними даними
        FOR c
            IN (SELECT /*+ ORDERED */
                       n.iprs_inn,
                       n.iprs_ln,
                       n.iprs_npt,                                      -- KEY
                       op.com_org,
                       n.iprs_fn,
                       n.iprs_pay_dt,
                       o.prs_pay_dt
                           oprs_pay_dt,
                       n.iprs_account,
                       o.prs_account
                           oprs_account,
                       DECODE (op.pr_src, 0, '', '{імпортованими з АСОПД}')
                           pr_src,
                       op.pr_id,
                       n.iprs_ipr
                  FROM ipr_sheet  n
                       JOIN imp_payroll np
                           ON     np.ipr_id = n.iprs_ipr
                              AND np.ipr_lfd_lfd = l_zip_id -- newcomers filter
                       JOIN pr_sheet o
                           ON     n.iprs_inn = o.prs_inn
                              AND NVL (n.iprs_npt, NVL (o.prs_npt, 0)) =
                                  NVL (o.prs_npt, 0)
                              AND DECODE (n.iprs_inn,
                                          '0000000000', n.iprs_account,
                                          'X') =
                                  DECODE (o.prs_inn,
                                          '0000000000', o.prs_account,
                                          'X')
                              AND o.prs_pay_dt BETWEEN TRUNC (n.iprs_pay_dt,
                                                              'MM')
                                                   AND LAST_DAY (
                                                           n.iprs_pay_dt) -- to use index
                              AND o.prs_st = 'NA'      -- more conditions here
                       JOIN payroll op ON op.pr_id = o.prs_pr
                 WHERE 1 = 1)
        LOOP
            l_buf :=
                   'Відомість '
                || c.iprs_ipr
                || ' отримувач ['
                || c.iprs_ln
                || ' ІПН '
                || c.iprs_inn
                || ' IBAN '
                || c.iprs_account
                || '] дубль з даними ЄІССС '
                || c.pr_src
                || ':'
                || ' АСОПД дата виплати '
                || TO_CHAR (c.iprs_pay_dt, 'DD.MM.YYYY')
                || ' , ЄІССС ОСЗН '
                || c.com_org
                || ' відомість '
                || c.pr_id
                || ' дата виплати '
                || TO_CHAR (c.oprs_pay_dt, 'DD.MM.YYYY');
            Write_Ln (l_buf, l_blob_stat);
            stats_inc (l_doubles, TO_CHAR (c.iprs_ipr));
            stats_inc (g_stats, 'дублів ЄІССС');
        END LOOP;

        -- errors summary
        IF g_Stats.EXISTS ('дублів ЄІССС')
        THEN
            l_err := l_err || ' дублів ЄІССС ' || g_Stats ('дублів ЄІССС');
        END IF;

        IF g_Stats.EXISTS ('дублів АСОПД')
        THEN
            l_err := l_err || ' дублів АСОПД ' || g_Stats ('дублів АСОПД');
        END IF;

        -- final stats
        --  Write_Ln(Stats_Out(g_stats),l_blob_stat);
        --  Write_Ln(Stats_Out(l_doubles),l_blob_stat);

        FOR cp IN (SELECT *
                     FROM imp_payroll
                    WHERE ipr_lfd_lfd = l_zip_id)
        LOOP
            IF l_doubles.EXISTS (cp.ipr_id)
            THEN
                IF BITAND (g_writ, 8) != 0
                THEN                           -- fix output, no data movement
                    UPDATE imp_payroll
                       SET ipr_st = 'S'
                     WHERE ipr_id = cp.ipr_id AND ipr_src = 20;
                END IF;

                Write_Ln (
                       'Відомість '
                    || cp.ipr_id
                    || ' з файлу '
                    || cp.ipr_lfd
                    || ' ВІДХИЛЕНА, дивись протокол',
                    l_blob_stat);
            ELSE                                                 -- GOOD entry
                IF BITAND (g_writ, 8) != 0
                THEN                              -- fix output, data movement
                    UPDATE imp_payroll
                       SET ipr_st = 'F'
                     WHERE ipr_id = cp.ipr_id AND ipr_src = 20;

                    ASOPD_Payroll_Apply (cp.ipr_lfd);
                END IF;

                Write_Ln (
                       'Відомість '
                    || cp.ipr_id
                    || ' з файлу '
                    || cp.ipr_lfd
                    || ' пішла у ЄІССС',
                    l_blob_stat);
            END IF;
        END LOOP;

        IF BITAND (g_writ, 1) != 0 AND BITAND (g_writ, 4) != 0
        THEN                                    -- LOB output + protocol table
            l_ipr_id := NULL;         -- must be empty to get next file number
            uss_exch.load_file_prtcl.InsertProtocol (
                p_lfp_lfd       => l_zip_id,
                p_content       => l_blob_stat,
                p_lfp_name      =>
                       uss_exch.load_file_prtcl.GetFileName (l_zip_id)
                    || '(DOUBLEZ).csv',
                p_lfp_id        => l_ipr_id,        -- IN OUT : NULL >> NUMBER
                p_lfp_lfp       => NULL,
                p_lfp_tp        => NULL,
                p_lfp_comment   => NULL);
            Write_Ln (
                   'Сформовано файловий ['
                || l_ipr_id
                || '] протокол '
                || uss_exch.load_file_prtcl.GetFileName (l_zip_id)
                || '(DOUBLEZ).csv',
                l_blob_stat);
        ELSE
            Write_Ln (
                   'Сформовано віртуальний протокол '
                || uss_exch.load_file_prtcl.GetFileName (l_zip_id)
                || '(DOUBLEZ).csv',
                l_blob_stat);
        END IF;

        COMMIT;
        RETURN l_err;
    EXCEPTION
        WHEN OTHERS
        THEN
            l_err :=
                   'Маємо проблеми у БД:'
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace;
            raise_application_error (-20000, l_err);
            RETURN l_err;
    END CMP_Payroll_Double_Z;

    FUNCTION CMP_Payroll_Double (p_lfd_id NUMBER, p_writ NUMBER DEFAULT 5)
        RETURN VARCHAR2
    IS
        l_lfd         uss_exch.v_payroll_bank_heading%ROWTYPE;
        l_ipr         imp_payroll%ROWTYPE;
        l_ipr_id      NUMBER;
        l_blob_stat   BLOB;
        l_buf         VARCHAR2 (2000);
        g_Stats       t_Stats;
        l_err         VARCHAR2 (2000);
    BEGIN
        g_writ := NVL (p_writ, g_writ);                  -- writing target(-s)
        DBMS_LOB.createtemporary (l_blob_stat, TRUE);
        stats_init (g_stats);

        -- get heading
        SELECT *
          INTO l_lfd
          FROM uss_exch.v_payroll_bank_heading
         WHERE lfd_id = p_lfd_id;

          -- знаходимо iprs_ipr
          SELECT ldr_trg
            INTO l_ipr_id
            FROM uss_exch.v_ls2uss
                 JOIN uss_exch.v_payroll_bank_heading
                     ON lfdp_id = ldr_lfdp AND v_ls2uss.lfd_id = p_lfd_id
           WHERE ldr_code = 'USS_ESR.IMP_PAYROLL'
        ORDER BY 1 DESC
           FETCH FIRST ROW ONLY;

        -- get imp_payroll
        SELECT *
          INTO l_ipr
          FROM imp_payroll
         WHERE ipr_id = l_ipr_id AND ipr_src = 20;

        -- heading
        Write_Ln (
               'ЗВІРЯННЯ НА ДУБЛІ виплатна відомість АСОПД ['
            || l_lfd.lfd_file_name
            || ' : '
            || l_lfd.payer_name
            || ' >> '
            || l_lfd.recipient_name
            || ' , '
            || l_lfd.purpose_payment
            || ']'
            || ' місяць '
            || TO_CHAR (l_ipr.ipr_month, 'MM.YYYY')
            || ' ОСЗН '
            || l_ipr.com_org
            || ' допомога '
            || l_ipr.ipr_npc
            || ' справ '
            || l_ipr.ipr_pc_cnt
            || ' сума '
            || l_ipr.ipr_sum,
            l_blob_stat);

        -- Внутрішні дублі
        FOR c
            IN (SELECT n.iprs_inn,
                       n.iprs_ln,
                       n.iprs_npt,                                      -- KEY
                       op.com_org,
                       n.iprs_fn,
                       n.iprs_pay_dt,
                       o.iprs_pay_dt      oprs_pay_dt,
                       n.iprs_account,
                       o.iprs_account     oprs_account
                  FROM ipr_sheet  n
                       JOIN ipr_sheet o
                           ON     n.iprs_inn = o.iprs_inn
                              AND NVL (n.iprs_npt, 0) = NVL (o.iprs_npt, 0)
                              AND n.iprs_id != o.iprs_id
                              AND                                -- not itself
                                  DECODE (n.iprs_inn,
                                          '0000000000', n.iprs_ln,
                                          'X') =
                                  DECODE (o.iprs_inn,
                                          '0000000000', o.iprs_ln,
                                          'X')
                              AND TRUNC (n.iprs_pay_dt, 'MM') =
                                  TRUNC (o.iprs_pay_dt, 'MM') -- more conditions here
                       JOIN imp_payroll op
                           ON     op.ipr_id = o.iprs_ipr
                              AND op.ipr_src = 20
                              AND op.ipr_st = 'C'
                 WHERE n.iprs_ipr = l_ipr_id)
        LOOP
            l_buf :=
                   'Отримувач ['
                || c.iprs_inn
                || '+'
                || c.iprs_ln
                || '+'
                || c.iprs_npt
                || ']: дубль у даних АСОПД з ОСЗН '
                || c.com_org
                || ' дати виплати нова '
                || TO_CHAR (c.iprs_pay_dt, 'DD.MM.YYYY')
                || ' існуюча '
                || TO_CHAR (c.oprs_pay_dt, 'DD.MM.YYYY')
                || ' рахунок новий '
                || c.iprs_account
                || ' існуючий '
                || c.oprs_account;
            Write_Ln (l_buf, l_blob_stat);
            stats_inc (g_stats, 'дублів АСОПД');
        END LOOP;

        -- дублі з наявними основними даними
        FOR c
            IN (SELECT n.iprs_inn,
                       n.iprs_ln,
                       n.iprs_npt,                                      -- KEY
                       op.com_org,
                       n.iprs_fn,
                       n.iprs_pay_dt,
                       o.prs_pay_dt
                           oprs_pay_dt,
                       n.iprs_account,
                       o.prs_account
                           oprs_account,
                       DECODE (op.pr_src, 0, '', '{імпортованими з АСОПД}')
                           pr_src,
                       op.pr_id
                  FROM ipr_sheet  n
                       JOIN pr_sheet o
                           ON     n.iprs_inn = o.prs_inn
                              AND NVL (n.iprs_npt, NVL (o.prs_npt, 0)) =
                                  NVL (o.prs_npt, 0)
                              AND DECODE (n.iprs_inn,
                                          '0000000000', n.iprs_ln,
                                          'X') =
                                  DECODE (o.prs_inn,
                                          '0000000000', o.prs_ln,
                                          'X')
                              AND TRUNC (n.iprs_pay_dt, 'MM') =
                                  TRUNC (o.prs_pay_dt, 'MM')
                              AND o.prs_st = 'NA'      -- more conditions here
                       JOIN payroll op ON op.pr_id = o.prs_pr
                 WHERE n.iprs_ipr = l_ipr_id)
        LOOP
            l_buf :=
                   'Отримувач ['
                || c.iprs_ln
                || ' ІПН '
                || c.iprs_inn
                || '] дубль з даними ЄІССС '
                || c.pr_src
                || ':'
                || ' АСОПД дата виплати '
                || TO_CHAR (c.iprs_pay_dt, 'DD.MM.YYYY')
                || ' , ЄІССС ОСЗН '
                || c.com_org
                || ' відомість '
                || c.pr_id
                || ' дата виплати '
                || TO_CHAR (c.oprs_pay_dt, 'DD.MM.YYYY');
            Write_Ln (l_buf, l_blob_stat);
            stats_inc (g_stats, 'дублів ЄІССС');
        END LOOP;

        -- errors summary
        IF g_Stats.EXISTS ('дублів ЄІССС')
        THEN
            l_err := l_err || ' дублів ЄІССС ' || g_Stats ('дублів ЄІССС');
        END IF;

        IF g_Stats.EXISTS ('дублів АСОПД')
        THEN
            l_err := l_err || ' дублів АСОПД ' || g_Stats ('дублів АСОПД');
        END IF;

        -- final stats
        Write_Ln (Stats_Out (g_stats), l_blob_stat);

        IF BITAND (g_writ, 1) != 0 AND BITAND (g_writ, 4) != 0
        THEN                                          -- LOB output + REAL RUN
            UPDATE imp_payroll
               SET ipr_st = NVL2 (l_err, 'S', 'F')
             WHERE ipr_id = l_ipr_id AND ipr_src = 20;

            l_ipr_id := NULL;         -- must be empty to get next file number
            uss_exch.load_file_prtcl.InsertProtocol (
                p_lfp_lfd       => l_lfd.lfd_lfd,
                p_content       => l_blob_stat,
                p_lfp_name      =>
                       uss_exch.load_file_prtcl.GetFileName (l_lfd.lfd_lfd)
                    || '(DOUBLE).csv',
                p_lfp_id        => l_ipr_id,        -- IN OUT : NULL >> NUMBER
                p_lfp_lfp       => NULL,
                p_lfp_tp        => NULL,
                p_lfp_comment   => NULL);
        END IF;

        COMMIT;
        RETURN l_err;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            l_err :=
                   'Реєстр виплат АСОПД відповідний вказаному файлу LFD_ID='
                || p_lfd_id
                || (CASE
                        WHEN l_lfd.lfd_id IS NOT NULL
                        THEN
                               ' ['
                            || l_lfd.lfd_file_name
                            || ':'
                            || l_lfd.payer_name
                            || ' >> '
                            || l_lfd.recipient_name
                            || ' , '
                            || l_lfd.purpose_payment
                            || ']'
                    END)
                || ' не знайдено в БД!';
            raise_application_error (-20000, l_err);
            RETURN l_err;
        WHEN OTHERS
        THEN
            l_err :=
                   'Маємо проблеми у БД:'
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace;
            raise_application_error (-20000, l_err);
            RETURN l_err;
    END CMP_Payroll_Double;

    PROCEDURE ASOPD_Payroll_Apply (p_lfd_id        NUMBER,
                                   p_force_pr_id   NUMBER DEFAULT NULL)
    IS
        l_lfd      uss_exch.v_payroll_bank_heading%ROWTYPE;
        l_ipr      imp_payroll%ROWTYPE;
        l_ipr_id   NUMBER;
        g_Stats    t_Stats;
    BEGIN
        stats_init (g_stats);

        -- get heading
        SELECT *
          INTO l_lfd
          FROM uss_exch.v_payroll_bank_heading
         WHERE lfd_id = p_lfd_id;

          -- знаходимо iprs_ipr
          SELECT ldr_trg
            INTO l_ipr_id
            FROM uss_exch.v_ls2uss
                 JOIN uss_exch.v_payroll_bank_heading
                     ON lfdp_id = ldr_lfdp AND v_ls2uss.lfd_id = p_lfd_id
           WHERE ldr_code = 'USS_ESR.IMP_PAYROLL'
        ORDER BY 1 DESC
           FETCH FIRST ROW ONLY;

        -- get imp_payroll
        SELECT *
          INTO l_ipr
          FROM imp_payroll
         WHERE ipr_id = l_ipr_id AND ipr_src = 20;

        -- INSERT PAYROLL
        INSERT INTO payroll (pr_id,
                             com_org,
                             pr_npc,
                             pr_tp,
                             pr_create_dt,
                             pr_sum,
                             pr_send_dt,
                             pr_fix_dt,
                             pr_st,
                             pr_start_dt,
                             pr_stop_dt,
                             pr_pc_cnt,
                             pr_pib_head,
                             pr_pib_bookkeeper,
                             pr_is_blocked,
                             pr_month,
                             pr_start_day,
                             pr_stop_day,
                             pr_pay_tp,
                             pr_src,
                             pr_code)
             VALUES (NVL (p_force_pr_id, 0),
                     l_ipr.com_org,
                     l_ipr.ipr_npc,
                     l_ipr.ipr_tp,
                     l_ipr.ipr_create_dt,
                     l_ipr.ipr_sum,
                     l_ipr.ipr_send_dt,
                     l_ipr.ipr_fix_dt,
                     'V',
                     l_ipr.ipr_start_dt,
                     l_ipr.ipr_stop_dt,
                     l_ipr.ipr_pc_cnt,
                     l_ipr.ipr_pib_head,
                     l_ipr.ipr_pib_bookkeeper,
                     l_ipr.ipr_is_blocked,
                     l_ipr.ipr_month,
                     l_ipr.ipr_start_day,
                     l_ipr.ipr_stop_day,
                     l_ipr.ipr_pay_tp,
                     1,
                     l_ipr.ipr_code)
          RETURNING pr_id
               INTO l_ipr_id;                                -- new value here

        stats_inc (g_stats, '1 - створено реєстр', l_ipr_id);

        -- INSERT SHEETS
        INSERT INTO pr_sheet (prs_pr,
                              prs_pc,
                              prs_pa,
                              prs_num,
                              prs_nb,
                              prs_pc_num,
                              prs_account,
                              prs_fn,
                              prs_ln,
                              prs_mn,
                              prs_index,
                              prs_address,
                              prs_tp,
                              prs_sum,
                              prs_post_sum,
                              prs_post_by_org,
                              prs_max_pro_sum,
                              prs_post_perc,
                              prs_remit_dt,
                              prs_remit_num,
                              prs_inn,
                              prs_transfer_dt,
                              prs_kaot,
                              prs_street,
                              prs_ns,
                              prs_building,
                              prs_block,
                              prs_apartment,
                              prs_pay_dt,
                              prs_npt,
                              prs_doc_num,
                              prs_st,
                              prs_dpp,
                              prs_pcb)
            SELECT l_ipr_id,
                   iprs_pc,
                   iprs_pa,
                   iprs_num,
                   iprs_nb,
                   iprs_pc_num,
                   iprs_account,
                   iprs_fn,
                   iprs_ln,
                   iprs_mn,
                   iprs_index,
                   iprs_address,
                   iprs_tp,
                   iprs_sum,
                   iprs_post_sum,
                   iprs_post_by_org,
                   iprs_max_pro_sum,
                   iprs_post_perc,
                   iprs_remit_dt,
                   iprs_remit_num,
                   iprs_inn,
                   iprs_transfer_dt,
                   iprs_kaot,
                   iprs_street,
                   iprs_ns,
                   iprs_building,
                   iprs_block,
                   iprs_apartment,
                   iprs_pay_dt,
                   iprs_npt,
                   iprs_doc_num,
                   iprs_st,
                   iprs_dpp,
                   iprs_pcb
              FROM ipr_sheet
             WHERE iprs_ipr = l_ipr.ipr_id;

        stats_inc (g_stats, '2 - рядків реєстру', SQL%ROWCOUNT);

        -- possible FK violations - PC and AC - switch it off !!!
        -- DETAILS
        INSERT INTO pr_sheet_detail (prsd_prs,
                                     prsd_pc,
                                     prsd_pa,
                                     prsd_tp,
                                     prsd_pr,
                                     prsd_month,
                                     prsd_sum,
                                     prsd_is_payed,
                                     prsd_full_sum,
                                     prsd_prs_dn)
            SELECT prs_id,
                   iprsd_pc,
                   iprsd_pa,
                   iprsd_tp,
                   l_ipr_id,
                   iprsd_month,
                   iprsd_sum,
                   iprsd_is_payed,
                   iprsd_full_sum,
                   iprsd_iprs_dn
              FROM ipr_sheet_detail  iprsd
                   JOIN pr_sheet prs
                       ON prs_pr = l_ipr_id AND prs_pc = iprsd_pc
             WHERE iprsd_ipr = l_ipr.ipr_id;

        stats_inc (g_stats, '3 - деталей реєстру', SQL%ROWCOUNT);
        COMMIT;

        IF p_force_pr_id IS NOT NULL
        THEN                                                -- debug mode INFO
            DBMS_OUTPUT.put_line (Stats_Out (g_stats));
        ELSE           -- real run >> #80452 FIX PAYROLL = make PAYROLL_REESTR
            CALC$PAYROLL.fix_payroll (l_ipr_id);
            COMMIT;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                   'Реєстр виплат АСОПД відповідний вказаному файлу LFD_ID='
                || p_lfd_id
                || (CASE
                        WHEN l_lfd.lfd_id IS NOT NULL
                        THEN
                               ' ['
                            || l_lfd.lfd_file_name
                            || ':'
                            || l_lfd.payer_name
                            || ' >> '
                            || l_lfd.recipient_name
                            || ' , '
                            || l_lfd.purpose_payment
                            || ']'
                    END)
                || ' не знайдено в БД!');
            RETURN;
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Маємо проблеми у БД:'
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END ASOPD_Payroll_Apply;

    PROCEDURE CMP_Payroll_Bank (p_lfd_id NUMBER, p_writ NUMBER DEFAULT 5)
    IS
        l_lfd         uss_exch.v_payroll_bank_heading%ROWTYPE;
        l_ipr         imp_payroll%ROWTYPE;
        l_ipr_id      NUMBER;
        l_blob_stat   BLOB;
        l_buf         VARCHAR2 (2000);
        g_Stats       t_Stats;
    BEGIN
        g_writ := NVL (p_writ, g_writ);                  -- writing target(-s)
        DBMS_LOB.createtemporary (l_blob_stat, TRUE);
        stats_init (g_stats);

        -- get heading
        SELECT *
          INTO l_lfd
          FROM uss_exch.v_payroll_bank_heading
         WHERE lfd_id = p_lfd_id;

          -- знаходимо iprs_ipr
          SELECT ldr_trg
            INTO l_ipr_id
            FROM uss_exch.v_ls2uss
                 JOIN uss_exch.v_payroll_bank_heading
                     ON lfdp_id = ldr_lfdp AND v_ls2uss.lfd_id = p_lfd_id
           WHERE ldr_code = 'USS_ESR.IMP_PAYROLL'
        ORDER BY 1 DESC
           FETCH FIRST ROW ONLY;

        -- get imp_payroll
        SELECT *
          INTO l_ipr
          FROM imp_payroll
         WHERE ipr_id = l_ipr_id AND ipr_src = 19;

        -- heading
        Write_Ln (
               'ЗВІРЯННЯ НАЯВНОСТІ виплатна відомість АСОПД ['
            || l_lfd.lfd_file_name
            || ' : '
            || l_lfd.payer_name
            || ' >> '
            || l_lfd.recipient_name
            || ' , '
            || l_lfd.purpose_payment
            || ']'
            || ' місяць '
            || TO_CHAR (l_ipr.ipr_month, 'MM.YYYY')
            || ' ОСЗН '
            || l_ipr.com_org
            || ' справ '
            || l_ipr.ipr_pc_cnt
            || ' сума '
            || l_ipr.ipr_sum,
            l_blob_stat);

        FOR c
            IN (SELECT iprs_inn,
                       iprs_account,                                    -- KEY
                       iprs_pc,
                       prs_pc,
                       CASE
                           WHEN NVL (iprs_pc, 0) != NVL (prs_pc, 0)
                           THEN
                                  ' #особова_справа '
                               || NVL (iprs_pc, 0)
                               || '!='
                               || NVL (prs_pc, 0)
                       END    c_pc,
                       iprs_pa,
                       prs_pa,
                       CASE
                           WHEN NVL (iprs_pa, 0) != NVL (prs_pa, 0)
                           THEN
                               ' #особовий рахунок '
                       END    c_pa,                                    -- always different ?!
                       iprs_num,
                       prs_num,
                       CASE
                           WHEN NVL (iprs_num, 0) != NVL (prs_num, 0)
                           THEN
                               ' #номер_по_відомості '
                       END    c_num,
                       iprs_nb,
                       prs_nb,
                       CASE
                           WHEN NVL (iprs_nb, 0) != NVL (prs_nb, 0)
                           THEN
                               ' #код_банку '
                       END    c_nb,
                       iprs_pc_num,
                       prs_pc_num,
                       CASE
                           WHEN NVL (iprs_pc_num, 'X') !=
                                NVL (prs_pc_num, 'X')
                           THEN
                               ' #номер_особової_справи '
                       END    c_pc_num,
                       iprs_fn,
                       prs_fn,
                       CASE
                           WHEN NVL (iprs_fn, 'X') != NVL (prs_fn, 'X')
                           THEN
                                  ' #імя '
                               || NVL (iprs_fn, 'X')
                               || '!='
                               || NVL (prs_fn, 'X')
                       END    c_fn,
                       iprs_ln,
                       prs_ln,
                       CASE
                           WHEN NVL (iprs_ln, 'X') != NVL (prs_ln, 'X')
                           THEN
                                  ' #фамілія '
                               || NVL (iprs_ln, 'X')
                               || '!='
                               || NVL (prs_ln, 'X')
                       END    c_ln,
                       iprs_mn,
                       prs_mn,
                       CASE
                           WHEN NVL (iprs_mn, 'X') != NVL (prs_mn, 'X')
                           THEN
                                  ' #по_батькові '
                               || NVL (iprs_mn, 'X')
                               || '!='
                               || NVL (prs_mn, 'X')
                       END    c_mn,
                       iprs_tp,
                       prs_tp,
                       CASE
                           WHEN NVL (iprs_tp, 'X') != NVL (prs_tp, 'X')
                           THEN
                                  ' #тип '
                               || NVL (iprs_tp, 'X')
                               || '!='
                               || NVL (prs_tp, 'X')
                       END    c_tp,
                       iprs_sum,
                       prs_sum,
                       CASE
                           WHEN NVL (iprs_sum, 0) != NVL (prs_sum, 0)
                           THEN
                                  ' #сума '
                               || NVL (iprs_sum, 0)
                               || '!='
                               || NVL (prs_sum, 0)
                       END    c_sum,
                       iprs_pay_dt,
                       prs_pay_dt,
                       CASE
                           WHEN NVL (iprs_pay_dt, SYSDATE) !=
                                NVL (prs_pay_dt, SYSDATE)
                           THEN
                                  ' #дата '
                               || TO_CHAR (iprs_pay_dt, 'DD.MM.YYYY')
                               || '!='
                               || TO_CHAR (prs_pay_dt, 'DD.MM.YYYY')
                       END    c_pay_dt,
                       iprs_npt,
                       prs_npt,
                       CASE
                           WHEN NVL (iprs_npt, 0) != NVL (prs_npt, 0)
                           THEN
                                  ' #тип_виплати '
                               || NVL (iprs_npt, 0)
                               || '!='
                               || NVL (prs_npt, 0)
                       END    c_npt
                  FROM ipr_sheet  iprs
                       LEFT JOIN pr_sheet prs
                           ON     iprs.iprs_inn = prs.prs_inn
                              AND iprs.iprs_account = prs.prs_account
                              AND TRUNC (iprs_pay_dt, 'MM') =
                                  TRUNC (prs_pay_dt, 'MM') -- more conditions here
                 WHERE iprs_ipr = l_ipr_id)
        LOOP
            IF c.prs_pc IS NULL
            THEN
                l_buf :=
                       'Отримувач ['
                    || c.iprs_inn
                    || '+'
                    || c.iprs_account
                    || ']: '
                    || c.iprs_ln
                    || ' не знайдено у ЄІССС';
                Write_Ln (l_buf, l_blob_stat);
                stats_inc (g_stats, 'рядків не знайдено у ЄІССС');
                stats_inc (g_stats, 'сума не знайдено у ЄІССС', c.iprs_sum);
            -- take into account only VALUABLE attribute difference
            ELSIF /*c.c_pc||c.c_num||c.c_nb||c.c_pc_num||c.c_fn||c.c_ln||c.c_mn||c.c_tp||*/
                  c.c_sum || c.c_pay_dt || c.c_npt IS NOT NULL
            THEN
                l_buf :=
                       'Отримувач ['
                    || c.iprs_inn
                    || '+'
                    || c.iprs_account
                    || ']:';
                l_buf :=
                       l_buf
                    ||               /*c.c_pc||c.c_num||c.c_nb||c.c_pc_num||*/
                       c.c_fn
                    || c.c_ln
                    || c.c_mn
                    || c.c_tp
                    || c.c_sum
                    || c.c_pay_dt
                    || c.c_npt;                   -- list MOST attribute pairs
                Write_Ln (l_buf, l_blob_stat);
                stats_inc (g_stats, 'рядків не співпали атрибути');
                stats_inc (g_stats, 'сума не співпали атрибути', c.iprs_sum);
            ELSE                                          -- count equal stats
                stats_inc (g_stats, 'рядків співпало');
                stats_inc (g_stats, 'сума співпало', c.iprs_sum);
            END IF;
        END LOOP;

        -- final stats
        Write_Ln (Stats_Out (g_stats), l_blob_stat);

        IF BITAND (g_writ, 1) != 0 AND BITAND (g_writ, 4) != 0
        THEN                                                     -- LOB output
            l_ipr_id := NULL;         -- must be empty to get next file number
            uss_exch.load_file_prtcl.InsertProtocol (
                p_lfp_lfd       => l_lfd.lfd_lfd,
                p_content       => l_blob_stat,
                p_lfp_name      =>
                       uss_exch.load_file_prtcl.GetFileName (l_lfd.lfd_lfd)
                    || '(ABSENT).csv',
                p_lfp_id        => l_ipr_id,        -- IN OUT : NULL >> NUMBER
                p_lfp_lfp       => NULL,
                p_lfp_tp        => NULL,
                p_lfp_comment   => NULL);
            COMMIT;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                   'Реєстр виплат АСОПД відповідний вказаному файлу LFD_ID='
                || p_lfd_id
                || (CASE
                        WHEN l_lfd.lfd_id IS NOT NULL
                        THEN
                               ' ['
                            || l_lfd.lfd_file_name
                            || ':'
                            || l_lfd.payer_name
                            || ' >> '
                            || l_lfd.recipient_name
                            || ' , '
                            || l_lfd.purpose_payment
                            || ']'
                    END)
                || ' не знайдено в БД!');
            RETURN;
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Маємо проблеми у БД:'
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END CMP_Payroll_Bank;
BEGIN
    NULL;
END CHK$ASOPD;
/