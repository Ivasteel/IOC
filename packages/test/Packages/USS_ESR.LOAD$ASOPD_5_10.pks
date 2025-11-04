/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.LOAD$ASOPD_5_10
IS
    -- Author  : IChekerenda
    -- Created : 06.02.2023
    -- Purpose :

    PROCEDURE Load_LS (p_lfd_lfd NUMBER, p_migration_force NUMBER DEFAULT 0);

    PROCEDURE Load_Decision (p_lfd_lfd       NUMBER,
                             p_ls_lfdp       NUMBER,
                             p_pc            NUMBER,
                             p_sc            NUMBER,
                             p_pa            NUMBER,
                             p_ls_nls        VARCHAR2,
                             p_ls_org        VARCHAR2,
                             p_ls_spos       VARCHAR2,
                             p_ls_indots     VARCHAR2,
                             p_ls_adrul      VARCHAR2,
                             p_ls_adrdom     VARCHAR2,
                             p_ls_adrkorp    VARCHAR2,
                             p_ls_adrkv      VARCHAR2,
                             p_nptc_nst      NUMBER,
                             p_ls_base_org   VARCHAR2,
                             p_sc_scc        NUMBER,
                             p_wu            NUMBER,
                             p_wu_txt        VARCHAR2);

    PROCEDURE Load_Deduction (p_lfd_lfd       NUMBER,
                              p_sc            NUMBER,
                              p_pc            NUMBER,
                              p_ap            NUMBER,
                              p_pa            NUMBER,
                              p_ls_nls        VARCHAR2,
                              p_ls_org        VARCHAR2,
                              p_ls_base_org   VARCHAR2);

    PROCEDURE Load_Accrual (p_lfd_lfd   NUMBER,
                            p_pc        NUMBER,
                            p_pd        NUMBER,
                            p_ls_nls    VARCHAR2,
                            p_ls_org    VARCHAR2);
END;
/


/* Formatted on 8/12/2025 5:50:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.LOAD$ASOPD_5_10
IS
    lBuffer                     BINARY_INTEGER := 16383;
    cEndOfLine                  CHAR (2) := CHR (13) || CHR (10);
    vCharBuffer                 VARCHAR2 (32767);

    ex_error_Clear_LS           EXCEPTION;
    ex_error_acd_period         EXCEPTION;
    ex_error_stage_not1         EXCEPTION;
    ex_error_sc_2               EXCEPTION;
    ex_error_sc_1               EXCEPTION;
    ex_error_sc_else            EXCEPTION;
    ex_error_igd_doc_decision   EXCEPTION;
    ex_error_igd_2sc_decision   EXCEPTION;
    ex_error_igd_decision       EXCEPTION;
    ex_error_op_accrual         EXCEPTION;
    ex_error_npt_accrual        EXCEPTION;
    ex_error_klovud_deduction   EXCEPTION;
    ex_error_kud_deduction      EXCEPTION;
    ex_error_nf_bank            EXCEPTION;
    ex_error_nf_npo             EXCEPTION;
    ex_error_nf_ns              EXCEPTION;
    ex_error_create_pd          EXCEPTION;

    ex_error_34_period_out      EXCEPTION;
    ex_error_34_period_exists   EXCEPTION;

    l_error_prm                 VARCHAR2 (1000);

    PROCEDURE SetAction (p_message VARCHAR2)
    IS
    BEGIN
        DBMS_APPLICATION_INFO.set_action (action_name => p_message);
    END;

    -- Призначення: ;
    -- Параметри:   ;
    PROCEDURE WriteLineToBlob (p_line   IN            VARCHAR2,
                               p_blob   IN OUT NOCOPY BLOB,
                               p_buff   IN            BOOLEAN := FALSE)
    IS
        vCharData     VARCHAR2 (32767);
        vRawData      RAW (32767);
        vDataLength   BINARY_INTEGER := 32767;
    BEGIN
        vCharData := TRIM (p_line) || cEndOfLine;

        -- Buffer --
        IF (NOT p_buff) OR (LENGTH (vCharData) > lBuffer)
        THEN
            vRawData := UTL_RAW.cast_to_raw (vCharData);
            vDataLength := LENGTH (vRawData) / 2;
            DBMS_LOB.writeappend (p_blob, vDataLength, vRawData);
        ELSE
            IF LENGTH (vCharBuffer || vCharData) > lBuffer
            THEN
                vRawData := UTL_RAW.cast_to_raw (vCharBuffer);
                vDataLength := LENGTH (vRawData) / 2;
                DBMS_LOB.writeappend (p_blob, vDataLength, vRawData);
                vCharBuffer := vCharData;
            ELSE
                vCharBuffer := vCharBuffer || vCharData;
            END IF;
        END IF;
    END;

    PROCEDURE SetNlsLog (p_lfdp NUMBER, p_trg NUMBER, p_code VARCHAR2)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        DELETE FROM uss_exch.v_ls2uss u
              WHERE u.ldr_lfdp = p_lfdp AND u.ldr_trg = -1;

        INSERT INTO uss_exch.v_ls2uss (ldr_lfdp, ldr_trg, ldr_code)
             VALUES (p_lfdp, p_trg, SUBSTR (p_code, 1, 500));

        COMMIT;
    END;

    PROCEDURE Load_LS (p_lfd_lfd NUMBER, p_migration_force NUMBER DEFAULT 0)
    IS
        l_sc_id       NUMBER;
        l_sc_scc      NUMBER;
        l_sc_unique   VARCHAR2 (100);
        l_pc_id       NUMBER;
        l_pa_id       pc_account.pa_id%TYPE;
        l_pa_stage    pc_account.pa_stage%TYPE;
        l_pa_org      pc_account.pa_org%TYPE;

        l_flag        NUMBER := 0; -- флаг для проверки что есть что поданному файлу отрабатівать или нет
        l_blob        BLOB;

        l_error_msg   VARCHAR2 (4000);
        l_lock        TOOLS.t_lockhandler;
        l_cnt         NUMBER := 0;
    BEGIN
        DBMS_LOB.createtemporary (l_blob, TRUE);

        WriteLineToBlob (p_line   => cEndOfLine || 'Помилкові записи: ',
                         p_blob   => l_blob);

        --dbms_session.set_nls('NLS_DATE_FORMAT', '''dd.mm.yyyy''');
        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''. ''');

        FOR rec_ls
            IN (SELECT DISTINCT
                       COUNT (DISTINCT ls.lfdp_id) OVER ()
                           AS cnt,
                       TRIM (SUBSTR (ls.ls_fio || '   ',
                                     1,
                                     INSTR (ls.ls_fio || '   ',
                                            ' ',
                                            1,
                                            1)))
                           AS fio_ln,
                       TRIM (SUBSTR (ls.ls_fio || '   ',
                                     INSTR (ls.ls_fio || '   ',
                                            ' ',
                                            1,
                                            1),
                                       INSTR (ls.ls_fio || '   ',
                                              ' ',
                                              1,
                                              2)
                                     - INSTR (ls.ls_fio || '   ',
                                              ' ',
                                              1,
                                              1)))
                           AS fio_fn,
                       TRIM (SUBSTR (ls.ls_fio || '   ',
                                     INSTR (ls.ls_fio || '   ',
                                            ' ',
                                            1,
                                            2),
                                     500))
                           AS fio_sn,
                       LPAD (LPAD (ls.ls_raj, 4, '0'), 5, '5')
                           AS ls_base_org,
                       COALESCE (TO_CHAR (o.nddc_code_dest),
                                 LPAD (LPAD (ls.ls_raj, 4, '0'), 5, '5'))
                           AS ls_org,
                       ls.*,
                       nnc.nptc_nst,
                       nnc.nptc_npt,
                       CASE WHEN sc.ls_nls IS NOT NULL THEN 1 ELSE 0 END
                           AS is_migr,
                       u.wu_login,
                       u.wu_pib,
                       u.wu_pib || '(' || u.wu_login || ')'
                           AS wu_txt
                  FROM uss_exch.v_ls_data  ls
                       LEFT JOIN uss_exch.v_ls2sc sc
                           ON     sc.ls_nls = ls.ls_nls
                              AND sc.ls_raj = ls.ls_raj
                              AND sc.lfd_lfd = ls.lfd_lfd
                       JOIN uss_ndi.v_ndi_payment_type npt
                           ON     npt.npt_code = ls.ls_kfn
                              AND npt.history_status = 'A'
                       JOIN uss_ndi.v_ndi_npt_config nnc
                           ON     nnc.nptc_npt = npt.npt_id
                              AND nnc.nptc_nst = 664             -- только ВПО
                       LEFT JOIN uss_ndi.v_ndi_decoding_config o
                           ON     o.nddc_code_src =
                                  LPAD (LPAD (ls.ls_raj, 4, '0'), 5, '5')
                              AND o.nddc_tp = 'ORG_MIGR'
                       LEFT JOIN ikis_sysweb.v$all_users u
                           ON u.wu_id = ls.lfd_user_id
                 WHERE     ls.lfd_lfd = p_lfd_lfd
                       --and ls.ls_nls in ('654532')
                       AND (sc.ls_nls IS NULL OR p_migration_force = 1))
        LOOP
            BEGIN
                l_cnt := l_cnt + 1;
                SetAction (
                       'ОР №'
                    || rec_ls.ls_base_org
                    || '_'
                    || rec_ls.ls_nls
                    || '. Запис '
                    || l_cnt
                    || ' з '
                    || rec_ls.cnt);

                l_flag := 1;
                l_error_prm := '';
                l_error_msg := '';
                l_sc_id := NULL;
                l_sc_scc := NULL;
                l_sc_unique := NULL;

                l_sc_id :=
                    uss_person.load$socialcard.Load_SC_Intrnl (
                        p_fn          =>
                            TRANSLATE (UPPER (rec_ls.fio_fn),
                                       'ETIOPAHKXCBM1',
                                       'ЕТІОРАНКХСВМІ'),
                        p_ln          =>
                            TRANSLATE (UPPER (rec_ls.fio_ln),
                                       'ETIOPAHKXCBM1',
                                       'ЕТІОРАНКХСВМІ'),
                        p_mn          =>
                            TRANSLATE (UPPER (rec_ls.fio_sn),
                                       'ETIOPAHKXCBM1',
                                       'ЕТІОРАНКХСВМІ'),
                        p_gender      =>
                            CASE
                                WHEN rec_ls.ls_pol = 1 THEN 'M'
                                WHEN rec_ls.ls_pol = 2 THEN 'F'
                                ELSE 'V'
                            END,
                        p_nationality   =>
                            CASE WHEN rec_ls.ls_grjd = '1' THEN 1 ELSE -1 END,
                        p_src_dt      => rec_ls.lfd_create_dt,
                        p_birth_dt    =>
                            TO_DATE (
                                rec_ls.ls_drog
                                    DEFAULT NULL ON CONVERSION ERROR,
                                'dd.mm.yyyy'),
                        p_inn_num     =>
                            CASE
                                WHEN REGEXP_LIKE (rec_ls.ls_idcode,
                                                  '^(\d){10}$')
                                THEN
                                    rec_ls.ls_idcode
                                ELSE
                                    NULL
                            END,
                        p_inn_ndt     =>
                            CASE
                                WHEN REGEXP_LIKE (rec_ls.ls_idcode,
                                                  '^(\d){10}$')
                                THEN
                                    5
                                ELSE
                                    NULL
                            END,                              -- тип из архива
                        p_doc_ser     =>
                            CASE
                                WHEN REGEXP_LIKE (rec_ls.ls_pasp,
                                                  '^(\d){9}$')
                                THEN
                                    NULL
                                WHEN REGEXP_LIKE (rec_ls.ls_pasp,
                                                  '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                THEN
                                    SUBSTR (rec_ls.ls_pasp, 1, 2)
                                WHEN REGEXP_LIKE (
                                         rec_ls.ls_pasp,
                                         '^[І|I|1]{1}[-]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                THEN
                                    SUBSTR (rec_ls.ls_pasp, 1, 4)
                                ELSE
                                    NULL
                            END,
                        p_doc_num     =>
                            CASE
                                WHEN REGEXP_LIKE (rec_ls.ls_pasp,
                                                  '^(\d){9}$')
                                THEN
                                    rec_ls.ls_pasp
                                WHEN REGEXP_LIKE (rec_ls.ls_pasp,
                                                  '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                THEN
                                    SUBSTR (rec_ls.ls_pasp, -6, 6)
                                WHEN REGEXP_LIKE (
                                         rec_ls.ls_pasp,
                                         '^[І|I|1]{1}[-]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                THEN
                                    SUBSTR (rec_ls.ls_pasp, -6, 6)
                                ELSE
                                    NULL
                            END,
                        p_doc_ndt     =>
                            CASE
                                WHEN REGEXP_LIKE (rec_ls.ls_pasp,
                                                  '^(\d){9}$')
                                THEN
                                    7                         -- новій паспорт
                                WHEN REGEXP_LIKE (rec_ls.ls_pasp,
                                                  '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                THEN
                                    6                    -- старій паспорт из архива
                                WHEN REGEXP_LIKE (
                                         rec_ls.ls_pasp,
                                         '^[І|I|1]{1}[-]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                THEN
                                    37                    -- свидетельство о рождении
                                ELSE
                                    NULL
                            END,
                        p_doc_unzr    =>
                            CASE
                                WHEN rec_ls.ls_pasp = rec_ls.p_docsn
                                THEN
                                    rec_ls.p_docunzr
                            END,
                        p_doc_is      =>
                            CASE
                                WHEN rec_ls.ls_pasp = rec_ls.p_docsn
                                THEN
                                    rec_ls.p_docis
                            END,
                        p_doc_bdt     =>
                            CASE
                                WHEN rec_ls.ls_pasp = rec_ls.p_docsn
                                THEN
                                    TO_DATE (
                                        rec_ls.p_docdt
                                            DEFAULT NULL ON CONVERSION ERROR,
                                        'dd.mm.yyyy')
                            END,
                        p_doc_edt     =>
                            CASE
                                WHEN rec_ls.ls_pasp = rec_ls.p_docsn
                                THEN
                                    TO_DATE (
                                        rec_ls.p_docend
                                            DEFAULT NULL ON CONVERSION ERROR,
                                        'dd.mm.yyyy')
                            END,
                        p_src         => '710',
                        p_sc          => l_sc_id,
                        p_sc_unique   => l_sc_unique,
                        p_sc_scc      => l_sc_scc,
                        p_Mode        => 3             -- c_Mode_Search_Create
                                          );

                ---------------------------------------------------
                -- для корректно найдених персон створюємо рішення
                IF l_sc_id > 0
                THEN
                    BEGIN
                        SELECT pc_id
                          INTO l_pc_id
                          FROM personalcase pc
                         WHERE pc.pc_sc = l_sc_id;

                        -- перемиграция по районам
                        UPDATE personalcase pc
                           SET pc.com_org = rec_ls.ls_org
                         WHERE     pc.pc_id = l_pc_id
                               AND COALESCE (pc.com_org, -1) <> rec_ls.ls_org;

                        UPDATE personalcase pc
                           SET pc.pc_num = l_sc_unique
                         WHERE     pc.pc_id = l_pc_id
                               AND pc.pc_num <> l_sc_unique;
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            INSERT INTO personalcase (pc_id,
                                                      pc_num,
                                                      pc_create_dt,
                                                      pc_sc,
                                                      pc_st,
                                                      com_org)
                                 VALUES (NULL,
                                         l_sc_unique,
                                         rec_ls.lfd_create_dt,
                                         l_sc_id,
                                         'R',
                                         rec_ls.ls_org)
                              RETURNING pc_id
                                   INTO l_pc_id;
                    END;

                    --------- особовий рахкнок
                    BEGIN
                        SELECT pa.pa_id, pa.pa_stage, pa_org
                          INTO l_pa_id, l_pa_stage, l_pa_org
                          FROM pc_account pa
                         WHERE     pa.pa_pc = l_pc_id
                               AND pa.pa_nst = rec_ls.nptc_nst;

                        -- маркируем услугу за текущим оргом
                        UPDATE pc_account ddd
                           SET ddd.pa_org = rec_ls.ls_base_org,
                               ddd.pa_stage = '1'
                         WHERE     ddd.pa_id = l_pa_id
                               AND COALESCE (ddd.pa_org, -1) <>
                                   rec_ls.ls_base_org;

                        -- записіваем информацию по услуге, откуда грузили и на какую дату последнего нарахування у нас виплата в вігрузке
                        INSERT INTO pa_log (pal_id,
                                            pal_pa,
                                            pal_hs,
                                            pal_st,
                                            pal_message,
                                            pal_st_old,
                                            pal_tp)
                                 VALUES (
                                            NULL,
                                            l_pa_id,
                                            NULL,
                                            NULL,
                                               CHR (38)
                                            || '92#'
                                            || rec_ls.lfd_lfd
                                            || '#'
                                            || rec_ls.ls_nls
                                            || '#'
                                            || rec_ls.ls_kfn
                                            || '#'
                                            || rec_ls.ls_dnac
                                            || '#'
                                            || rec_ls.ls_org
                                            || '#'
                                            || rec_ls.ls_base_org
                                            || '#'
                                            || rec_ls.wu_txt
                                            || '#'
                                            || TO_CHAR (
                                                   SYSDATE,
                                                   'dd.mm.yyyy hh24:mi:ss'),
                                            NULL,
                                            'SYS');
                    -- не нашли услугу (особовій рахунок)
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            INSERT INTO pc_account (pa_id,
                                                    pa_pc,
                                                    pa_num,
                                                    pa_nst,
                                                    pa_stage,
                                                    pa_org)
                                 VALUES (NULL,
                                         l_pc_id,
                                         rec_ls.ls_nls,
                                         rec_ls.nptc_nst,
                                         '1',
                                         rec_ls.ls_base_org)
                              RETURNING pa_id, pa_stage, pa_org
                                   INTO l_pa_id, l_pa_stage, l_pa_org;

                            -- записіваем информацию по услуге, откуда грузили и на какую дату последнего нарахування у нас виплата в вігрузке
                            INSERT INTO pa_log (pal_id,
                                                pal_pa,
                                                pal_hs,
                                                pal_st,
                                                pal_message,
                                                pal_st_old,
                                                pal_tp)
                                     VALUES (
                                                NULL,
                                                l_pa_id,
                                                NULL,
                                                NULL,
                                                   CHR (38)
                                                || '92#'
                                                || rec_ls.lfd_lfd
                                                || '#'
                                                || rec_ls.ls_nls
                                                || '#'
                                                || rec_ls.ls_kfn
                                                || '#'
                                                || rec_ls.ls_dnac
                                                || '#'
                                                || rec_ls.ls_org
                                                || '#'
                                                || rec_ls.ls_base_org
                                                || '#'
                                                || rec_ls.wu_txt
                                                || '#'
                                                || TO_CHAR (
                                                       SYSDATE,
                                                       'dd.mm.yyyy hh24:mi:ss'),
                                                NULL,
                                                'SYS');
                    END;

                    l_lock :=
                        tools.request_lock_with_timeout (
                            p_descr               => 'MIGR_PA_' || l_pa_id,
                            p_error_msg           =>
                                'В данний час вже виконуються завантаження для особового рахунку, спробуйте дозавантажити пізніше.',
                            p_timeout             => 13,
                            p_release_on_commit   => TRUE);

                    -- ADDDDD
                    -- Отмечаем вновь созданную или ранее созданную запись в socialcard|PERSONALCASE|PC_ACCOUNT
                    INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                   ldr_trg,
                                                   ldr_code)
                             VALUES (rec_ls.lfdp_id,
                                     l_sc_id,
                                     'USS_PERSON.SOCIALCARD');

                    INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                   ldr_trg,
                                                   ldr_code)
                             VALUES (rec_ls.lfdp_id,
                                     l_pc_id,
                                     'USS_ESR.PERSONALCASE');

                    INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                   ldr_trg,
                                                   ldr_code)
                             VALUES (rec_ls.lfdp_id,
                                     l_pa_id,
                                     'USS_ESR.PC_ACCOUNT');

                    -- понеслась ....
                    -- первая часть марлезонского балета - РЕШЕНИЯ
                    Load_Decision (p_lfd_lfd       => p_lfd_lfd,
                                   p_ls_lfdp       => rec_ls.lfdp_id,
                                   p_pc            => l_pc_id,
                                   p_sc            => l_sc_id,
                                   p_pa            => l_pa_id,
                                   p_ls_nls        => rec_ls.ls_nls,
                                   p_ls_org        => rec_ls.ls_org,
                                   p_ls_spos       => rec_ls.ls_spos,
                                   p_ls_indots     => rec_ls.ls_indots,
                                   p_ls_adrul      => rec_ls.ls_adrul,
                                   p_ls_adrdom     => rec_ls.ls_adrdom,
                                   p_ls_adrkorp    => rec_ls.ls_adrkorp,
                                   p_ls_adrkv      => rec_ls.ls_adrkv,
                                   p_nptc_nst      => rec_ls.nptc_nst,
                                   p_ls_base_org   => rec_ls.ls_base_org,
                                   p_sc_scc        => l_sc_scc,
                                   p_wu            => rec_ls.lfd_user_id,
                                   p_wu_txt        => rec_ls.wu_txt);
                ----------------
                ELSIF l_sc_id = -2
                THEN
                    RAISE ex_error_sc_2;
                ELSIF l_sc_id = -1
                THEN
                    RAISE ex_error_sc_1;
                ELSE
                    RAISE ex_error_sc_else;
                END IF;

                -- явный комит по каждому НЛС (короткие транзакции)
                COMMIT;
            EXCEPTION
                WHEN ex_error_Clear_LS
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Помилка переміграції особового рахунку. Особовий рахунок взято в роботу!;';
                WHEN ex_error_stage_not1
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Особовий рахунок взято в роботу, завантаження/перезавантаження неможливе;';
                WHEN ex_error_sc_2
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Документи заявника не вказано чи неможливо визначити тип документа;';
                WHEN ex_error_sc_1
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; За документами заявника знайдено більше однієї персони в ЄСР;';
                WHEN ex_error_sc_else
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Помилка визначення персони заявника;';
                WHEN ex_error_igd_doc_decision
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Документи утриманця не вказано чи неможливо визначити тип документа;';
                WHEN ex_error_igd_2sc_decision
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; За документами утриманця знайдено більше однієї персони в ЄСР;';
                WHEN ex_error_igd_decision
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Помилка визначення персони утриманця;';
                WHEN ex_error_op_accrual
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Невідомий код операції для нарахувань;'
                        || l_error_prm;
                WHEN ex_error_npt_accrual
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Невідомий код нарахувань (неоплата за місяць.рік);'
                        || l_error_prm;
                WHEN ex_error_klovud_deduction
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Відсутне інформація щодо стягувача;'
                        || l_error_prm;
                WHEN ex_error_kud_deduction
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Відсутня інформація за вказаним кодом утримання;'
                        || l_error_prm;
                WHEN ex_error_nf_bank
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Неможливо визначити банк, код банку/відділення;'
                        || l_error_prm;
                WHEN ex_error_nf_npo
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Неможливо визначити індекс в довіднику;'
                        || l_error_prm;
                WHEN ex_error_nf_ns
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Неможливо визначити вулицю в довіднику;'
                        || l_error_prm;
                WHEN ex_error_create_pd
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Помилка створення рішення;'
                        || l_error_prm;
                WHEN ex_error_acd_period
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Особовий рахунок містить періоди дії послуги, які перетинаються с іншими періодами цієї послуги.;'
                        || l_error_prm;
                WHEN ex_error_34_period_out
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Особовий рахунок містить періоди дії послуги за межами "01.05.2022" та "31.10.2022";';
                WHEN ex_error_34_period_exists
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Особовий рахунок містить періоди дії послуги які перетинаються з періодом "01.05.2022" та "31.10.2022";';
                WHEN OTHERS
                THEN
                    l_error_msg :=
                           rec_ls.ls_nls
                        || '; Невизначена помилка;'
                        || DBMS_UTILITY.format_error_stack
                        || DBMS_UTILITY.format_error_backtrace;
            END;

            -- запись ошибки
            IF l_error_msg IS NOT NULL
            THEN
                BEGIN                                 -- если потеряли хендлер
                    tools.release_lock (p_lock_handler => l_lock);
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        NULL;
                END;

                ROLLBACK;
                WriteLineToBlob (p_line => l_error_msg, p_blob => l_blob);
                SetNlsLog (rec_ls.lfdp_id, -1, l_error_msg);
            END IF;
        END LOOP;

        IF l_flag = 1
        THEN
            NULL;
            --dbms_output.put_line(l_error_msg);
            uss_exch.load_file_prtcl.checkloadussdata (
                p_lfd_id     => p_lfd_lfd,
                p_nls_list   => l_blob);
        END IF;
    END;

    PROCEDURE AddPdFamily (p_lfd_lfd     NUMBER,
                           p_ls_nls      VARCHAR2,
                           p_ap_id       NUMBER,
                           p_aps_id      NUMBER,
                           p_pd_id       NUMBER,
                           p_nptc_nst    NUMBER,
                           p_np_dnprav   DATE)
    IS
        l_igd_sc_id       NUMBER;
        l_igd_sc_unique   VARCHAR2 (100);
        l_igd_sc_scc      NUMBER;
        l_pdf_id          NUMBER;

        l_ns_id           NUMBER;
        l_ns_kaot         NUMBER;
        l_ns_name         VARCHAR2 (250);
        l_nsrt_name       VARCHAR2 (250);

        l_pdp_start_dt    DATE;
        l_pdp_stop_dt     DATE;
    BEGIN
        FOR rec_igd
            IN (SELECT TRIM (SUBSTR (i.igd_fio || '   ',
                                     1,
                                     INSTR (i.igd_fio || '   ',
                                            ' ',
                                            1,
                                            1)))                  AS fio_ln,
                       TRIM (SUBSTR (i.igd_fio || '   ',
                                     INSTR (i.igd_fio || '   ',
                                            ' ',
                                            1,
                                            1),
                                       INSTR (i.igd_fio || '   ',
                                              ' ',
                                              1,
                                              2)
                                     - INSTR (i.igd_fio || '   ',
                                              ' ',
                                              1,
                                              1)))                AS fio_fn,
                       TRIM (SUBSTR (i.igd_fio || '   ',
                                     INSTR (i.igd_fio || '   ',
                                            ' ',
                                            1,
                                            2),
                                     500))                        AS fio_sn,
                       CASE
                           WHEN igd_nomig = '0' THEN 'Z'
                           ELSE 'FP'
                       END                                        AS igd_app_tp,
                       CASE
                           WHEN igd_katrod = '5' THEN 'GC'
                           WHEN igd_katrod = '6' THEN 'GP'
                           WHEN igd_katrod = '7' THEN 'SP'
                           WHEN igd_katrod = '8' THEN 'SC'
                           WHEN igd_katrod = '65' THEN 'PILM'
                           WHEN igd_katrod = '66' THEN 'PILF'
                           WHEN igd_katrod = '52' THEN 'CHRG'
                           WHEN igd_katrod = '61' THEN 'GGC'
                           WHEN igd_katrod = '62' THEN 'CIL'
                           WHEN igd_katrod = '63' THEN 'NC'
                           WHEN igd_katrod = '64' THEN 'UN'
                           WHEN igd_katrod = '68' THEN 'OTHER'
                           WHEN igd_katrod = '2' THEN 'HW'
                           WHEN igd_katrod = '4' THEN 'BS'
                           WHEN igd_katrod = '3' THEN 'B'
                           WHEN igd_katrod = '51' THEN 'GUARD'
                           WHEN igd_katrod = '1' THEN 'P'
                           WHEN igd_katrod = '0' THEN 'Z'
                           WHEN igd_katrod = '67' THEN NULL
                       END                                        AS igd_apd_katrod,
                       i.lfd_lfd,
                       i.lfd_create_dt,
                       i.lfdp_id,
                       i.ls_nls,
                       i.igd_nomig,
                       i.igd_katrod,
                       i.igd_katnetr,
                       i.igd_dusn,
                       i.igd_fio,
                       i.igd_drog,
                       i.igd_pol,
                       i.p_doct,
                       i.p_docsn,
                       i.p_docunzr,
                       i.p_docis,
                       i.p_docdt,
                       i.p_docend,
                       i.p_ipn,
                       i.igd_psn,
                       i.igd_dso,
                       ls.ls_adrul,
                       ls.ls_adrdom,
                       ls.ls_adrkorp,
                       ls.ls_adrkv,
                       --s.ns_id,
                       --s.ns_kaot,
                       --s.ns_name,
                       LPAD (LPAD (ls.ls_raj, 4, '0'), 5, '5')    AS ls_org,
                       ls.ls_rab
                  FROM uss_exch.v_ls_igd_data  i
                       LEFT JOIN uss_exch.v_ls_data ls
                           ON     ls.lfd_lfd = i.lfd_lfd
                              AND ls.ls_nls = i.ls_nls
                              AND i.igd_nomig = 0
                 --left join uss_ndi.v_ndi_street s on s.ns_code = ls.ls_adrul and s.ns_org = lpad(lpad(ls.ls_raj,4,'0'),5,'5') and s.history_status = 'A'
                 --  and s.history_status = 'A'
                 WHERE i.lfd_lfd = p_lfd_lfd AND i.ls_nls = p_ls_nls
                UNION
                SELECT TRIM (SUBSTR (ls.ls_fio || '   ',
                                     1,
                                     INSTR (ls.ls_fio || '   ',
                                            ' ',
                                            1,
                                            1)))                  AS fio_ln,
                       TRIM (SUBSTR (ls.ls_fio || '   ',
                                     INSTR (ls.ls_fio || '   ',
                                            ' ',
                                            1,
                                            1),
                                       INSTR (ls.ls_fio || '   ',
                                              ' ',
                                              1,
                                              2)
                                     - INSTR (ls.ls_fio || '   ',
                                              ' ',
                                              1,
                                              1)))                AS fio_fn,
                       TRIM (SUBSTR (ls.ls_fio || '   ',
                                     INSTR (ls.ls_fio || '   ',
                                            ' ',
                                            1,
                                            2),
                                     500))                        AS fio_sn,
                       'Z'                                        AS igd_app_tp,
                       'Z'                                        AS igd_apd_katrod,
                       ls.lfd_lfd,
                       ls.lfd_create_dt,
                       ls.lfdp_id,
                       ls.ls_nls,
                       '0'                                        AS igd_nomig,
                       '0'                                        AS igd_katrod,
                       '0'                                        AS igd_katnetr,
                       NULL                                       AS Igd_Dusn,
                       ls.ls_fio                                  AS igd_fio,
                       ls.ls_drog                                 AS igd_drog,
                       ls.ls_pol                                  AS igd_pol,
                       ls.p_doct,
                       ls.p_docsn,
                       ls.p_docunzr,
                       ls.p_docis,
                       ls.p_docdt,
                       ls.p_docend,
                       ls.ls_idcode                               AS p_ipn,
                       '0'                                        AS igd_psn,
                       NULL                                       AS igd_dso,
                       ls.ls_adrul,
                       ls.ls_adrdom,
                       ls.ls_adrkorp,
                       ls.ls_adrkv,
                       --s.ns_id,
                       --s.ns_kaot,
                       --s.ns_name,
                       LPAD (LPAD (ls.ls_raj, 4, '0'), 5, '5')    AS ls_org,
                       ls.ls_rab
                  FROM uss_exch.v_ls_data ls
                 --left join uss_ndi.v_ndi_street s on s.ns_code = ls.ls_adrul and to_char(s.ns_org) = lpad(lpad(ls.ls_raj,4,'0'),5,'5') and s.history_status = 'A'
                 --  and s.history_status = 'A'
                 WHERE     ls.lfd_lfd = p_lfd_lfd
                       AND ls.ls_nls = p_ls_nls
                       AND NOT EXISTS
                               (SELECT igd.lfdp_id
                                  FROM uss_exch.v_ls_igd_data igd
                                 WHERE     ls.lfd_lfd = igd.lfd_lfd
                                       AND ls.ls_nls = igd.ls_nls
                                       AND igd.igd_nomig = '0'))
        LOOP
            ------------------------------------------------------------------------------------------------------
            l_igd_sc_id := NULL;
            l_igd_sc_scc := NULL;
            l_igd_sc_unique := NULL;

            l_igd_sc_id :=
                uss_person.load$socialcard.Load_SC_Intrnl (
                    p_fn            =>
                        TRANSLATE (UPPER (rec_igd.fio_fn),
                                   'ETIOPAHKXCBM1',
                                   'ЕТІОРАНКХСВМІ'),
                    p_ln            =>
                        TRANSLATE (UPPER (rec_igd.fio_ln),
                                   'ETIOPAHKXCBM1',
                                   'ЕТІОРАНКХСВМІ'),
                    p_mn            =>
                        TRANSLATE (UPPER (rec_igd.fio_sn),
                                   'ETIOPAHKXCBM1',
                                   'ЕТІОРАНКХСВМІ'),
                    p_gender        =>
                        CASE
                            WHEN rec_igd.igd_pol = 1 THEN 'M'
                            WHEN rec_igd.igd_pol = 2 THEN 'F'
                            ELSE 'V'
                        END,
                    p_nationality   => -1,
                    p_src_dt        => rec_igd.lfd_create_dt,
                    p_birth_dt      =>
                        TO_DATE (
                            rec_igd.igd_drog DEFAULT NULL ON CONVERSION ERROR,
                            'dd.mm.yyyy'),
                    p_inn_num       =>
                        CASE
                            WHEN REGEXP_LIKE (rec_igd.p_ipn, '^(\d){10}$')
                            THEN
                                rec_igd.p_ipn
                            ELSE
                                NULL
                        END,
                    p_inn_ndt       =>
                        CASE
                            WHEN REGEXP_LIKE (rec_igd.p_ipn, '^(\d){10}$')
                            THEN
                                5
                            ELSE
                                NULL
                        END,                                  -- тип из архива
                    p_doc_ser       =>
                        CASE
                            WHEN     rec_igd.p_doct = '1'
                                 AND REGEXP_LIKE (rec_igd.p_docsn,
                                                  '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                            THEN
                                SUBSTR (rec_igd.p_docsn, 1, 2)
                            WHEN     rec_igd.p_doct = '3'
                                 AND REGEXP_LIKE (
                                         rec_igd.p_docsn,
                                         '^[І|I|1]{1}{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                            THEN
                                SUBSTR (rec_igd.p_docsn, 1, 3)
                            WHEN     rec_igd.p_doct IN ('3', '5', '6')
                                 AND REGEXP_LIKE (
                                         rec_igd.p_docsn,
                                         '^[І|I|1]{1}[-]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                            THEN
                                SUBSTR (rec_igd.p_docsn, 1, 4)
                            ELSE
                                NULL
                        END,
                    p_doc_num       =>
                        CASE
                            WHEN     rec_igd.p_doct = '1'
                                 AND REGEXP_LIKE (rec_igd.p_docsn,
                                                  '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                            THEN
                                SUBSTR (rec_igd.p_docsn, -6, 6)
                            WHEN     rec_igd.p_doct = '2'
                                 AND REGEXP_LIKE (rec_igd.p_docsn,
                                                  '^(\d){9}$')
                            THEN
                                rec_igd.p_docsn
                            WHEN     rec_igd.p_doct = '3'
                                 AND REGEXP_LIKE (
                                         rec_igd.p_docsn,
                                         '^[І|I|1]{1}{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                            THEN
                                SUBSTR (rec_igd.p_docsn, -6, 6)
                            WHEN     rec_igd.p_doct IN ('3', '5', '6')
                                 AND REGEXP_LIKE (
                                         rec_igd.p_docsn,
                                         '^[І|I|1]{1}[-]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                            THEN
                                SUBSTR (rec_igd.p_docsn, -6, 6)
                            WHEN rec_igd.p_doct IN ('3',
                                                    '4',
                                                    '5',
                                                    '6')
                            THEN
                                rec_igd.p_docsn
                            ELSE
                                rec_igd.p_docsn
                        END,
                    p_doc_ndt       =>
                        CASE
                            WHEN rec_igd.p_doct = '1' THEN 6
                            WHEN rec_igd.p_doct = '2' THEN 7
                            WHEN rec_igd.p_doct IN ('3', '5', '6') THEN 37
                            WHEN rec_igd.p_doct = '4' THEN 601
                            ELSE 684
                        END,
                    p_doc_unzr      => rec_igd.p_docunzr,
                    p_doc_is        => rec_igd.p_docis,
                    p_doc_bdt       =>
                        TO_DATE (
                            rec_igd.p_docdt DEFAULT NULL ON CONVERSION ERROR,
                            'dd.mm.yyyy'),
                    p_doc_edt       =>
                        TO_DATE (
                            rec_igd.p_docend DEFAULT NULL ON CONVERSION ERROR,
                            'dd.mm.yyyy'),
                    p_src           => '710',
                    p_sc            => l_igd_sc_id,
                    p_sc_unique     => l_igd_sc_unique,
                    p_sc_scc        => l_igd_sc_scc,
                    p_Mode          => 3               -- c_Mode_Search_Create
                                        );

            ---------------------------------------------------------------------------------------------------
            IF l_igd_sc_id > 0 OR l_igd_sc_id = -2
            THEN
                IF l_igd_sc_id = -2
                THEN
                    l_igd_sc_id := NULL;
                ELSE
                    -- заполнение идентификатора иждивенца
                    INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                   ldr_trg,
                                                   ldr_code)
                             VALUES (rec_igd.lfdp_id,
                                     l_igd_sc_id,
                                     'USS_PERSON.SOCIALCARD');
                END IF;

                -- інформація по вулицям
                BEGIN
                      SELECT ns_id,
                             s.ns_kaot,
                             ns_name,
                             st.nsrt_name
                        INTO l_ns_id,
                             l_ns_kaot,
                             l_ns_name,
                             l_nsrt_name
                        FROM uss_ndi.v_ndi_street s
                             LEFT JOIN uss_ndi.v_ndi_street_type st
                                 ON s.ns_nsrt = st.nsrt_id
                       WHERE     s.ns_code = rec_igd.ls_adrul
                             AND TO_CHAR (s.ns_org) = rec_igd.ls_org
                             AND s.history_status = 'A'
                    ORDER BY ns_id
                       FETCH FIRST ROWS ONLY;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        l_ns_id := NULL;
                        l_ns_kaot := NULL;
                        l_ns_name := rec_igd.ls_adrul;
                        l_nsrt_name := NULL;
                END;

                -- IC #101375
                SELECT MIN (p.pdp_start_dt), MAX (p.pdp_stop_dt)
                  INTO l_pdp_start_dt, l_pdp_stop_dt
                  FROM pd_payment p
                 WHERE p.pdp_pd = p_pd_id AND p.history_status = 'A';

                INSERT INTO pd_family (pdf_id,
                                       pdf_sc,
                                       pdf_pd,
                                       pdf_birth_dt,
                                       pdf_start_dt,
                                       pdf_stop_dt,
                                       history_status,
                                       pdf_src,
                                       pdf_tp)
                     VALUES (
                                NULL,
                                l_igd_sc_id,
                                p_pd_id,
                                TO_DATE (
                                    rec_igd.igd_drog
                                        DEFAULT NULL ON CONVERSION ERROR,
                                    'dd.mm.yyyy'),
                                l_pdp_start_dt,
                                l_pdp_stop_dt,
                                'A',
                                'MG',
                                'CALC')                -- uss_ndi.v_ddn_pdf_tp
                  RETURNING pdf_id
                       INTO l_pdf_id;

                INSERT INTO uss_exch.v_ls2uss (ldr_lfdp, ldr_trg, ldr_code)
                     VALUES (rec_igd.lfdp_id, l_pdf_id, 'USS_ESR.PD_FAMILY');

                INSERT INTO pd_features (pde_id,
                                         pde_pd,
                                         pde_nft,
                                         pde_val_string,
                                         pde_pdf)
                     VALUES (NULL,
                             p_pd_id,
                             21,
                             rec_igd.igd_nomig,
                             l_pdf_id);

                INSERT INTO pd_features (pde_id,
                                         pde_pd,
                                         pde_nft,
                                         pde_val_string,
                                         pde_pdf)
                     VALUES (NULL,
                             p_pd_id,
                             34,
                             rec_igd.igd_katnetr,
                             l_pdf_id);

                INSERT INTO pd_features (pde_id,
                                         pde_pd,
                                         pde_nft,
                                         pde_val_string,
                                         pde_pdf)
                     VALUES (NULL,
                             p_pd_id,
                             36,
                             rec_igd.igd_fio,
                             l_pdf_id);

                IF rec_igd.igd_psn <> '0'
                THEN
                    INSERT INTO pd_features (pde_id,
                                             pde_pd,
                                             pde_nft,
                                             pde_val_string,
                                             pde_val_dt,
                                             pde_pdf)
                             VALUES (
                                        NULL,
                                        p_pd_id,
                                        35,
                                        'T',
                                        TO_DATE (
                                            rec_igd.igd_dso
                                                DEFAULT NULL ON CONVERSION ERROR,
                                            'dd.mm.yyyy'),
                                        l_pdf_id);
                END IF;

                --+++++++++++++++++++++++++++++++++++++++++ ДОПОЛНЕНИЕ К ЗВЕРНЕННЮ
                DECLARE
                    l_app_id       NUMBER;
                    l_apd_605_id   NUMBER;
                    l_inv_cnt      NUMBER;

                    l_apd_5_id     NUMBER;
                    l_apd_6_id     NUMBER;
                    l_apd_7_id     NUMBER;
                    l_apd_37_id    NUMBER;
                    l_apd_601_id   NUMBER;
                BEGIN
                    INSERT INTO ap_person (app_id,
                                           app_ap,
                                           app_sc,
                                           app_tp,
                                           history_status,
                                           app_scc)
                         VALUES (NULL,
                                 p_ap_id,
                                 l_igd_sc_id,
                                 rec_igd.igd_app_tp,
                                 'A',
                                 l_igd_sc_scc)
                      RETURNING app_id
                           INTO l_app_id;

                    INSERT INTO ap_document (apd_id,
                                             apd_ap,
                                             apd_app,
                                             apd_ndt,
                                             history_status,
                                             apd_aps)
                         VALUES (NULL,
                                 p_ap_id,
                                 l_app_id,
                                 605,
                                 'A',
                                 p_aps_id)
                      RETURNING apd_id
                           INTO l_apd_605_id;

                    -- адреса
                    IF rec_igd.igd_nomig = 0
                    THEN
                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_605_id,
                                     1780,
                                     rec_igd.ls_adrkv,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_605_id,
                                     1781,
                                     l_ns_kaot,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_id,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_605_id,
                                     1783,
                                     l_ns_id,
                                     l_nsrt_name || ' ' || l_ns_name,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_605_id,
                                     1784,
                                     rec_igd.ls_adrdom,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_605_id,
                                     1787,
                                     rec_igd.ls_adrkorp,
                                     'A');
                    END IF;

                    -- 1772 605 Заявник - особа з інвалідністю
                    SELECT COUNT (*)
                      INTO l_inv_cnt
                      FROM uss_exch.v_ls_inv_data i
                     WHERE     i.lfd_lfd = rec_igd.lfd_lfd
                           AND i.ls_nls = rec_igd.ls_nls
                           AND i.Inv_Nomig = rec_igd.igd_nomig;

                    IF l_inv_cnt > 0
                    THEN
                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_605_id,
                                     1772,
                                     'T',
                                     'A');
                    END IF;

                    -- 649  605 Ступінь родинного зв’язку
                    INSERT INTO ap_document_attr (apda_id,
                                                  apda_ap,
                                                  apda_apd,
                                                  apda_nda,
                                                  apda_val_string,
                                                  history_status)
                         VALUES (NULL,
                                 p_ap_id,
                                 l_apd_605_id,
                                 649,
                                 rec_igd.igd_apd_katrod,
                                 'A');

                    -- ONLY VPO
                    IF     rec_igd.igd_nomig = 0
                       AND TO_DATE (
                               rec_igd.igd_drog
                                   DEFAULT NULL ON CONVERSION ERROR,
                               'dd.mm.yyyy')
                               IS NOT NULL
                       AND p_nptc_nst = 664
                    THEN
                        -- 1768 605 Внутрішньо переміщена особа (повнолітня)
                        -- 1770 605 Внутрішньо переміщена особа (неповнолітня)
                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                                 VALUES (
                                            NULL,
                                            p_ap_id,
                                            l_apd_605_id,
                                            CASE
                                                WHEN ADD_MONTHS (
                                                         TO_DATE (
                                                             rec_igd.igd_drog,
                                                             'dd.mm.yyyy'),
                                                         18 * 12) >
                                                     p_np_dnprav
                                                THEN
                                                    1770
                                                WHEN ADD_MONTHS (
                                                         TO_DATE (
                                                             rec_igd.igd_drog,
                                                             'dd.mm.yyyy'),
                                                         18 * 12) <=
                                                     p_np_dnprav
                                                THEN
                                                    1768
                                            END,
                                            'T',
                                            'A');
                    END IF;

                    IF NOT REGEXP_LIKE (rec_igd.p_ipn, '^(\d){10}$')
                    THEN
                        -- 640  605 Відмова від використання РНОКПП
                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_605_id,
                                     640,
                                     'T',
                                     'A');

                        -- 812  605 Відмова від використання РНОКПП
                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_605_id,
                                     812,
                                     'T',
                                     'A');
                    ELSIF REGEXP_LIKE (rec_igd.p_ipn, '^(\d){10}$')
                    THEN
                        -- INN
                        INSERT INTO ap_document (apd_id,
                                                 apd_ap,
                                                 apd_app,
                                                 apd_ndt,
                                                 history_status,
                                                 apd_aps)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_app_id,
                                     5,
                                     'A',
                                     p_aps_id)
                          RETURNING apd_id
                               INTO l_apd_5_id;

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_5_id,
                                     1,
                                     rec_igd.p_ipn,
                                     'A');
                    END IF;

                    IF rec_igd.p_doct = '1'
                    THEN
                        INSERT INTO ap_document (apd_id,
                                                 apd_ap,
                                                 apd_app,
                                                 apd_ndt,
                                                 history_status,
                                                 apd_aps)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_app_id,
                                     6,
                                     'A',
                                     p_aps_id)
                          RETURNING apd_id
                               INTO l_apd_6_id;

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_6_id,
                                     3,
                                     rec_igd.p_docsn,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_dt,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_6_id,
                                     5,
                                     TO_DATE (rec_igd.p_docdt, 'dd.mm.yyyy'),
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_6_id,
                                     7,
                                     rec_igd.p_docis,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_dt,
                                                      history_status)
                                 VALUES (
                                            NULL,
                                            p_ap_id,
                                            l_apd_6_id,
                                            606,
                                            TO_DATE (rec_igd.igd_drog,
                                                     'dd.mm.yyyy'),
                                            'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_6_id,
                                     2373,
                                     rec_igd.fio_sn,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_6_id,
                                     2374,
                                     rec_igd.fio_fn,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_6_id,
                                     2375,
                                     rec_igd.fio_ln,
                                     'A');
                    ELSIF rec_igd.p_doct = '2'
                    THEN
                        INSERT INTO ap_document (apd_id,
                                                 apd_ap,
                                                 apd_app,
                                                 apd_ndt,
                                                 history_status,
                                                 apd_aps)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_app_id,
                                     7,
                                     'A',
                                     p_aps_id)
                          RETURNING apd_id
                               INTO l_apd_7_id;

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_7_id,
                                     9,
                                     rec_igd.p_docsn,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_dt,
                                                      history_status)
                                 VALUES (
                                            NULL,
                                            p_ap_id,
                                            l_apd_7_id,
                                            10,
                                            TO_DATE (rec_igd.p_docend,
                                                     'dd.mm.yyyy'),
                                            'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_7_id,
                                     13,
                                     rec_igd.p_docis,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_dt,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_7_id,
                                     14,
                                     TO_DATE (rec_igd.p_docdt, 'dd.mm.yyyy'),
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_dt,
                                                      history_status)
                                 VALUES (
                                            NULL,
                                            p_ap_id,
                                            l_apd_7_id,
                                            607,
                                            TO_DATE (rec_igd.igd_drog,
                                                     'dd.mm.yyyy'),
                                            'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_7_id,
                                     810,
                                     rec_igd.p_docunzr,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_7_id,
                                     2378,
                                     rec_igd.fio_sn,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_7_id,
                                     2377,
                                     rec_igd.fio_fn,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_7_id,
                                     2376,
                                     rec_igd.fio_ln,
                                     'A');
                    ELSIF rec_igd.p_doct IN ('3', '5', '6')
                    THEN
                        INSERT INTO ap_document (apd_id,
                                                 apd_ap,
                                                 apd_app,
                                                 apd_ndt,
                                                 history_status,
                                                 apd_aps)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_app_id,
                                     37,
                                     'A',
                                     p_aps_id)
                          RETURNING apd_id
                               INTO l_apd_37_id;

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_37_id,
                                     90,
                                     rec_igd.p_docsn,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_dt,
                                                      history_status)
                                 VALUES (
                                            NULL,
                                            p_ap_id,
                                            l_apd_37_id,
                                            91,
                                            TO_DATE (rec_igd.igd_drog,
                                                     'dd.mm.yyyy'),
                                            'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_37_id,
                                     92,
                                     rec_igd.igd_fio,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_37_id,
                                     93,
                                     rec_igd.p_docis,
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_dt,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_37_id,
                                     94,
                                     TO_DATE (rec_igd.p_docdt, 'dd.mm.yyyy'),
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_37_id,
                                     2293,
                                     'АСОПД',
                                     'A');

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_dt,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_37_id,
                                     2294,
                                     SYSDATE,
                                     'A');
                    ELSIF rec_igd.p_doct = '4'
                    THEN
                        INSERT INTO ap_document (apd_id,
                                                 apd_ap,
                                                 apd_app,
                                                 apd_ndt,
                                                 history_status,
                                                 apd_aps)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_app_id,
                                     601,
                                     'A',
                                     p_aps_id)
                          RETURNING apd_id
                               INTO l_apd_601_id;

                        INSERT INTO ap_document_attr (apda_id,
                                                      apda_ap,
                                                      apda_apd,
                                                      apda_nda,
                                                      apda_val_string,
                                                      history_status)
                             VALUES (NULL,
                                     p_ap_id,
                                     l_apd_601_id,
                                     90,
                                     rec_igd.p_docsn,
                                     'A');
                    END IF;
                END;
            ELSIF l_igd_sc_id = -2
            THEN
                RAISE ex_error_igd_doc_decision;
            ELSIF l_igd_sc_id = -1
            THEN
                RAISE ex_error_igd_2sc_decision;
            ELSE
                RAISE ex_error_igd_decision;
            END IF;
        END LOOP;
    END;

    PROCEDURE Load_Decision (p_lfd_lfd       NUMBER,   -- группа файлов(архив)
                             p_ls_lfdp       NUMBER, -- идентификатор строки инициатора элемеента миграции
                             p_pc            NUMBER,           -- personalcase
                             p_sc            NUMBER, -- персона (отримувач допомоги)
                             p_pa            NUMBER,             -- pc_account
                             p_ls_nls        VARCHAR2,
                             p_ls_org        VARCHAR2,
                             p_ls_spos       VARCHAR2,
                             p_ls_indots     VARCHAR2,
                             p_ls_adrul      VARCHAR2,
                             p_ls_adrdom     VARCHAR2,
                             p_ls_adrkorp    VARCHAR2,
                             p_ls_adrkv      VARCHAR2,
                             p_nptc_nst      NUMBER,
                             p_ls_base_org   VARCHAR2,
                             p_sc_scc        NUMBER,
                             p_wu            NUMBER,
                             p_wu_txt        VARCHAR2)
    IS
        l_ap_id             NUMBER;
        l_aps_id            NUMBER;
        l_pd_id             NUMBER;
        l_pdp_id            NUMBER;
        l_pdd_id            NUMBER;
        l_pcb_id            NUMBER;
        l_np_dnprav         DATE;

        rec_v_ls_sv1_data   uss_exch.v_ls_sv1_data%ROWTYPE;
        rec_v_ls_sv2_data   uss_exch.v_ls_sv2_data%ROWTYPE;

        l_npo4sv1           NUMBER;
        l_ns4sv1            NUMBER;
        l_bank_id           NUMBER;
    BEGIN
        FOR rec_np
            IN (  SELECT lfdp_id,
                         ls_nls,
                         np_kfn,
                         np_dnprav,
                         np_dkprav,
                         np_snadp,
                         ROW_NUMBER ()
                             OVER (PARTITION BY ls_nls
                                   ORDER BY
                                       np_dnprav,
                                       np_dkprav,
                                       npt_id,
                                       lfdp_id)
                             AS is_first,
                         ROW_NUMBER ()
                             OVER (PARTITION BY ls_nls
                                   ORDER BY
                                       np_dnprav DESC,
                                       np_dkprav DESC,
                                       npt_id DESC,
                                       lfdp_id DESC)
                             AS is_last,
                         MIN (np_dnprav) OVER (PARTITION BY ls_nls)
                             AS min_dt,
                         MAX (np_dkprav) OVER (PARTITION BY ls_nls)
                             AS max_dt,
                         np_snadp
                             AS sum_grp,
                         ROW_NUMBER ()
                             OVER (PARTITION BY ls_nls,
                                                np_kfn,
                                                np_dnprav,
                                                np_dkprav
                                   ORDER BY npt_id, lfdp_id)
                             AS npp,
                         npt.npt_id,
                         np_block_psn,
                         ls_kfn,
                         ls_fio,
                         ls_drog
                    FROM (WITH
                              tper
                              AS
                                  (  SELECT /*+ materialize */
                                            p.lfd_id,
                                            p.lfd_lfd,
                                            p.lfdp_id,
                                            p.per_kfn,
                                            p.per_rnaz,
                                            p.ls_nls,
                                            p.per_dnpen,
                                            p.per_psn,
                                            ls.ls_kfn,
                                            ls_fio,
                                            ls_drog
                                       FROM uss_exch.v_ls_per_data p
                                            JOIN uss_exch.v_ls_data ls
                                                ON     ls.lfd_lfd = p.lfd_lfd
                                                   AND ls.ls_nls = p.ls_nls
                                      WHERE     p.ls_nls = p_ls_nls
                                            AND p.lfd_lfd = p_lfd_lfd
                                   ORDER BY TO_DATE (p.per_dnpen, 'dd.mm.yyyy'))
                          SELECT DISTINCT
                                 p.lfdp_id,
                                 p.ls_nls,
                                 p.per_kfn
                                     AS np_kfn,
                                 p.ls_kfn,
                                 p.ls_fio,
                                 p.ls_drog,
                                 TO_DATE (p.per_dnpen, 'dd.mm.yyyy')
                                     AS np_dnprav,
                                 LEAST (
                                     COALESCE (
                                         FIRST_VALUE (
                                               TO_DATE (po.per_dnpen,
                                                        'dd.mm.yyyy')
                                             - 1)
                                             OVER (
                                                 PARTITION BY p.lfdp_id,
                                                              p.ls_nls,
                                                              p.per_kfn,
                                                              p.per_dnpen,
                                                              p.per_rnaz
                                                 ORDER BY
                                                     TO_DATE (po.per_dnpen,
                                                              'dd.mm.yyyy')),
                                         FIRST_VALUE (
                                               TO_DATE (pp.per_dnpen,
                                                        'dd.mm.yyyy')
                                             - 1)
                                             OVER (
                                                 PARTITION BY p.lfdp_id,
                                                              p.ls_nls,
                                                              p.per_kfn,
                                                              p.per_dnpen,
                                                              p.per_rnaz
                                                 ORDER BY
                                                     TO_DATE (pp.per_dnpen,
                                                              'dd.mm.yyyy')),
                                         TO_DATE ('31.12.2022', 'dd.mm.yyyy')),
                                     COALESCE (
                                         FIRST_VALUE (
                                               TO_DATE (pp.per_dnpen,
                                                        'dd.mm.yyyy')
                                             - 1)
                                             OVER (
                                                 PARTITION BY p.lfdp_id,
                                                              p.ls_nls,
                                                              p.per_kfn,
                                                              p.per_dnpen,
                                                              p.per_rnaz
                                                 ORDER BY
                                                     TO_DATE (pp.per_dnpen,
                                                              'dd.mm.yyyy')),
                                         FIRST_VALUE (
                                               TO_DATE (po.per_dnpen,
                                                        'dd.mm.yyyy')
                                             - 1)
                                             OVER (
                                                 PARTITION BY p.lfdp_id,
                                                              p.ls_nls,
                                                              p.per_kfn,
                                                              p.per_dnpen,
                                                              p.per_rnaz
                                                 ORDER BY
                                                     TO_DATE (po.per_dnpen,
                                                              'dd.mm.yyyy')),
                                         TO_DATE ('31.12.2022', 'dd.mm.yyyy')))
                                     AS np_dkprav,
                                 FIRST_VALUE (pp.per_psn)
                                     OVER (
                                         PARTITION BY p.lfdp_id,
                                                      p.ls_nls,
                                                      p.per_kfn,
                                                      p.per_dnpen,
                                                      p.per_rnaz
                                         ORDER BY
                                             TO_DATE (pp.per_dnpen,
                                                      'dd.mm.yyyy'))
                                     np_block_psn,
                                 p.per_rnaz
                                     AS np_snadp
                            FROM tper p
                                 LEFT JOIN tper pp
                                     ON     p.lfd_lfd = pp.lfd_lfd
                                        AND p.ls_nls = pp.ls_nls
                                        AND p.per_kfn = pp.per_kfn
                                        AND pp.per_psn NOT IN ('0')
                                        AND TO_DATE (pp.per_dnpen,
                                                     'dd.mm.yyyy') >
                                            TO_DATE (p.per_dnpen, 'dd.mm.yyyy')
                                 LEFT JOIN tper po
                                     ON     p.lfd_lfd = po.lfd_lfd
                                        AND p.ls_nls = po.ls_nls
                                        AND p.per_kfn = po.per_kfn
                                        AND po.per_psn IN ('0')
                                        AND TO_DATE (po.per_dnpen,
                                                     'dd.mm.yyyy') >
                                            TO_DATE (p.per_dnpen, 'dd.mm.yyyy')
                           WHERE p.per_psn = '0')
                         LEFT JOIN uss_ndi.v_ndi_payment_type npt
                             ON     npt.npt_code = np_kfn
                                AND npt.history_status = 'A'
                ORDER BY np_dnprav,
                         np_dkprav,
                         npt_id,
                         npp)
        LOOP
            -- для первой записи создаем обращение
            IF rec_np.is_first = 1
            THEN
                --------------------------------------------------------  СОЗДАНИЕ APPEAL -------------------------------------------------------------------------
                -- создание обращения (ПРОСТО СОЗДАЕМ НОВОЕ ОБРАЩЕНИЕ, ЕСЛИ СЮДА ПОПАЛИ ТО ЄТО ПЕРЕМИГРАЦИЯ ПОСЛЕ ОЧИСТКИ ИЛИ ПЕРЕМИГРАЦИЯ ДРУГИМ ФАЙЛОМ)
                INSERT INTO appeal (ap_id,
                                    ap_pc,
                                    ap_tp,
                                    ap_reg_dt,
                                    ap_src,
                                    com_org,
                                    ap_num,
                                    ap_st)
                     VALUES (NULL,
                             p_pc,
                             'V',
                             rec_np.np_dnprav,
                             'ASOPD',
                             p_ls_org,
                             p_ls_base_org || '_' || p_ls_nls,
                             'N')
                  RETURNING ap_id
                       INTO l_ap_id;

                INSERT INTO ap_service (aps_id,
                                        aps_ap,
                                        aps_st,
                                        history_status,
                                        aps_nst)
                     VALUES (NULL,
                             l_ap_id,
                             'R',
                             'A',
                             p_nptc_nst)
                  RETURNING aps_id
                       INTO l_aps_id;

                -- ADDDDD
                INSERT INTO uss_exch.v_ls2uss (ldr_lfdp, ldr_trg, ldr_code)
                     VALUES (p_ls_lfdp, l_ap_id, 'USS_ESR.APPEAL');

                -------------------------------------------------------------------------------------------------------------------------------------------------
                IF p_ls_spos = 1
                THEN
                    -----------------------------------------------------  ДЛЯ ДОСТАВОЧНОГО УЧАСТКА ------------------------------------------------------------------
                    SELECT sv1.*
                      INTO rec_v_ls_sv1_data
                      FROM uss_exch.v_ls_sv1_data sv1
                     WHERE sv1.lfd_lfd = p_lfd_lfd AND sv1.ls_nls = p_ls_nls;

                    IF NULLIF (rec_v_ls_sv1_data.sv1_os, '0') IS NOT NULL
                    THEN
                        BEGIN -- определяем индкекс для связи с оргом, если нет то ищем для базового орга, если нет то ищем для индекса без привязки к оргу
                            SELECT o.npo_id
                              INTO l_npo4sv1
                              FROM uss_ndi.v_ndi_post_office o
                             WHERE     o.npo_index =
                                       LPAD (rec_v_ls_sv1_data.sv1_os,
                                             5,
                                             '0')
                                   AND o.npo_org = p_ls_base_org;
                        EXCEPTION
                            WHEN NO_DATA_FOUND
                            THEN
                                BEGIN
                                    SELECT o.npo_id
                                      INTO l_npo4sv1
                                      FROM uss_ndi.v_ndi_post_office o
                                     WHERE     o.npo_index =
                                               LPAD (
                                                   rec_v_ls_sv1_data.sv1_os,
                                                   5,
                                                   '0')
                                           AND o.npo_org = p_ls_org;
                                EXCEPTION
                                    WHEN NO_DATA_FOUND
                                    THEN
                                        BEGIN
                                            SELECT o.npo_id
                                              INTO l_npo4sv1
                                              FROM uss_ndi.v_ndi_post_office
                                                   o
                                             WHERE     o.npo_index =
                                                       LPAD (
                                                           rec_v_ls_sv1_data.sv1_os,
                                                           5,
                                                           '0')
                                                   AND o.npo_org IS NULL
                                                   AND ROWNUM = 1;
                                        EXCEPTION
                                            WHEN OTHERS
                                            THEN
                                                l_error_prm :=
                                                    rec_v_ls_sv1_data.sv1_os;
                                                RAISE ex_error_nf_npo;
                                        END;
                                END;
                        END;

                        BEGIN -- определяем улицу по тем же правилам с привязкой к оргу, с привязкой к базовому оргу
                              SELECT s.ns_id
                                INTO l_ns4sv1
                                FROM uss_ndi.v_ndi_street s
                               WHERE     s.ns_code = p_ls_adrul
                                     AND s.ns_org = p_ls_base_org
                                     AND s.history_status = 'A'
                            ORDER BY ns_id
                               FETCH FIRST ROWS ONLY;
                        EXCEPTION
                            WHEN NO_DATA_FOUND
                            THEN
                                BEGIN
                                      SELECT s.ns_id
                                        INTO l_ns4sv1
                                        FROM uss_ndi.v_ndi_street s
                                       WHERE     s.ns_code = p_ls_adrul
                                             AND s.ns_org = p_ls_org
                                             AND s.history_status = 'A'
                                    ORDER BY ns_id
                                       FETCH FIRST ROWS ONLY;
                                EXCEPTION
                                    WHEN OTHERS
                                    THEN
                                        l_error_prm := p_ls_adrul;
                                        RAISE ex_error_nf_ns;
                                END;
                        END;

                        -- заполняем развязку индекса и улиці, если небіло
                        INSERT INTO uss_ndi.ndi_npo_config (nnc_ns, nnc_npo)
                            SELECT l_ns4sv1, l_npo4sv1
                              FROM DUAL
                             WHERE NOT EXISTS
                                       (SELECT *
                                          FROM uss_ndi.ndi_npo_config g
                                         WHERE     g.nnc_ns = l_ns4sv1
                                               AND g.nnc_npo = l_npo4sv1);
                    END IF;

                    -- находим решение (при отсутствии создаем новое)  -- (ЕСЛИ СЮДА ЗАШЛИ СОЗДАЕМ НОВОЕ)
                    INSERT INTO pc_decision (pd_pc,
                                             pd_ap,
                                             pd_id,
                                             pd_pa,
                                             pd_dt,
                                             pd_st,
                                             pd_has_right,
                                             pd_hs_right,
                                             pd_hs_reject,
                                             pd_hs_app,
                                             pd_hs_mapp,
                                             pd_hs_head,
                                             pd_start_dt,
                                             pd_stop_dt,
                                             pd_num,
                                             pd_nst,
                                             com_org,
                                             com_wu,
                                             pd_hs_return,
                                             pd_src,
                                             pd_ps,
                                             pd_src_id,
                                             pd_ap_reason,
                                             pd_scc)
                         VALUES (p_pc,
                                 l_ap_id,
                                 NULL,
                                 p_pa,
                                 rec_np.min_dt,
                                 'P',
                                 'T',
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 rec_np.min_dt,
                                 rec_np.max_dt,
                                 p_ls_base_org || '_' || rec_np.ls_nls,
                                 p_nptc_nst,
                                 p_ls_org,
                                 p_wu,
                                 NULL,
                                 'MG',
                                 NULL,
                                 NULL,
                                 l_ap_id,
                                 p_sc_scc)
                      RETURNING pd_id, pd_start_dt
                           INTO l_pd_id, l_np_dnprav;

                    -- информация по віплатнім реквизитам
                    INSERT INTO pd_pay_method (pdm_id,
                                               pdm_pd,
                                               pdm_start_dt,
                                               pdm_stop_dt,
                                               history_status,
                                               pdm_ap_src,
                                               pdm_pay_tp,
                                               pdm_index,
                                               pdm_kaot,
                                               pdm_nb,
                                               pdm_account,
                                               pdm_street,
                                               pdm_ns,
                                               pdm_building,
                                               pdm_block,
                                               pdm_apartment,
                                               pdm_nd,
                                               pdm_pay_dt,
                                               pdm_scc,
                                               pdm_is_actual)
                             VALUES (
                                        NULL,
                                        l_pd_id,
                                        rec_np.min_dt,
                                        rec_np.max_dt,
                                        'A',
                                        l_ap_id,
                                        'POST',
                                        p_ls_indots,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        l_ns4sv1,
                                        p_ls_adrdom,
                                        p_ls_adrkorp,
                                        p_ls_adrkv,
                                        NULL,
                                        --
                                        CASE
                                            WHEN TO_NUMBER (
                                                     rec_v_ls_sv1_data.sv1_dvipl) BETWEEN 1
                                                                                      AND 31
                                            THEN
                                                TO_NUMBER (
                                                    rec_v_ls_sv1_data.sv1_dvipl)
                                            WHEN COALESCE (
                                                     TO_NUMBER (
                                                         TO_CHAR (
                                                             rec_np.min_dt,
                                                             'dd')),
                                                     0) <
                                                 4
                                            THEN
                                                4
                                            WHEN COALESCE (
                                                     TO_NUMBER (
                                                         TO_CHAR (
                                                             rec_np.min_dt,
                                                             'dd')),
                                                     0) >
                                                 25
                                            THEN
                                                25
                                            ELSE
                                                TO_NUMBER (
                                                    TO_CHAR (rec_np.min_dt,
                                                             'dd'))
                                        END,
                                        p_sc_scc,
                                        'T');

                    INSERT INTO pd_log (pdl_id,
                                        pdl_pd,
                                        pdl_hs,
                                        pdl_st,
                                        pdl_message,
                                        pdl_st_old,
                                        pdl_tp)
                             VALUES (
                                        NULL,
                                        l_pd_id,
                                        NULL,
                                        NULL,
                                           CHR (38)
                                        || '94#'
                                        || p_wu_txt
                                        || '#'
                                        || TO_CHAR (SYSDATE,
                                                    'dd.mm.yyyy hh24:mi:ss'),
                                        NULL,
                                        'SYS');

                    -- ADDDDD
                    INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                   ldr_trg,
                                                   ldr_code)
                             VALUES (rec_np.lfdp_id,
                                     l_pd_id,
                                     'USS_ESR.PC_DECISION');
                ELSIF p_ls_spos = 2
                THEN
                    ------------------------------------------------------------  ДЛЯ БАНКА -----------------------------------------------------------------------
                    BEGIN
                        -- значения из віплат банка (SV2)
                        SELECT sv2.*
                          INTO rec_v_ls_sv2_data
                          FROM uss_exch.v_ls_sv2_data sv2
                         WHERE     sv2.lfd_lfd = p_lfd_lfd
                               AND sv2.ls_nls = p_ls_nls;

                        IF     NULLIF (rec_v_ls_sv2_data.sv2_ncsbb, '0')
                                   IS NOT NULL
                           AND NULLIF (rec_v_ls_sv2_data.sv2_npsbb, '0')
                                   IS NOT NULL
                        THEN
                            -- вібор банка в подсистеме усс по коду баенка и отделению банка с привязкой к оргу,потом с привязкой к базовому оргу, потом без привязки к оргу просто по отделению и коду банка.
                            BEGIN
                                SELECT bb.nbb_nb
                                  INTO l_bank_id
                                  FROM uss_exch.v_ls_nb_branch_ref  bb
                                       JOIN uss_ndi.v_ndi_bank b
                                           ON     b.nb_id = bb.NBB_NB
                                              AND b.history_status = 'A'
                                 WHERE     rec_v_ls_sv2_data.sv2_ncsbb =
                                           bb.nbb_ncsbb
                                       AND rec_v_ls_sv2_data.sv2_npsbb =
                                           bb.nbb_code
                                       AND bb.nbb_org = p_ls_base_org;
                            EXCEPTION
                                WHEN NO_DATA_FOUND
                                THEN
                                    BEGIN
                                        SELECT bb.nbb_nb
                                          INTO l_bank_id
                                          FROM uss_exch.v_ls_nb_branch_ref bb
                                               JOIN uss_ndi.v_ndi_bank b
                                                   ON     b.nb_id = bb.NBB_NB
                                                      AND b.history_status =
                                                          'A'
                                         WHERE     rec_v_ls_sv2_data.sv2_ncsbb =
                                                   bb.nbb_ncsbb
                                               AND rec_v_ls_sv2_data.sv2_npsbb =
                                                   bb.nbb_code
                                               AND bb.nbb_org = p_ls_org;
                                    EXCEPTION
                                        WHEN NO_DATA_FOUND
                                        THEN
                                            IF     rec_v_ls_sv2_data.sv2_ncsbb =
                                                   '10026'
                                               AND rec_v_ls_sv2_data.sv2_npsbb =
                                                   '10026'
                                            THEN
                                                l_bank_id := 26;
                                            ELSE
                                                l_error_prm :=
                                                       rec_v_ls_sv2_data.sv2_ncsbb
                                                    || '/'
                                                    || rec_v_ls_sv2_data.sv2_npsbb;
                                                RAISE ex_error_nf_bank;
                                            END IF;
                                    END;
                            END;
                        END IF;
                    END;

                    IF    rec_np.min_dt <
                          TO_DATE ('01.05.2022', 'dd.mm.yyyy')
                       OR rec_np.max_dt >
                          TO_DATE ('31.10.2022', 'dd.mm.yyyy')
                    THEN
                        RAISE ex_error_34_period_out;
                    END IF;

                    -- создаем новое решение
                    INSERT INTO pc_decision (pd_pc,
                                             pd_ap,
                                             pd_id,
                                             pd_pa,
                                             pd_dt,
                                             pd_st,
                                             pd_has_right,
                                             pd_hs_right,
                                             pd_hs_reject,
                                             pd_hs_app,
                                             pd_hs_mapp,
                                             pd_hs_head,
                                             pd_start_dt,
                                             pd_stop_dt,
                                             pd_num,
                                             pd_nst,
                                             com_org,
                                             com_wu,
                                             pd_hs_return,
                                             pd_src,
                                             pd_ps,
                                             pd_src_id,
                                             pd_ap_reason,
                                             pd_scc)
                         VALUES (p_pc,
                                 l_ap_id,
                                 NULL,
                                 p_pa,
                                 rec_np.min_dt,
                                 'P',
                                 'T',
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 rec_np.min_dt,
                                 rec_np.max_dt,
                                 p_ls_base_org || '_' || rec_np.ls_nls,
                                 p_nptc_nst,
                                 p_ls_org,
                                 p_wu,
                                 NULL,
                                 'MG',
                                 NULL,
                                 NULL,
                                 l_ap_id,
                                 p_sc_scc)
                      RETURNING pd_id, pd_start_dt
                           INTO l_pd_id, l_np_dnprav;

                    -- информация по віплатнім реквизитам
                    INSERT INTO pd_pay_method (pdm_id,
                                               pdm_pd,
                                               pdm_start_dt,
                                               pdm_stop_dt,
                                               history_status,
                                               pdm_ap_src,
                                               pdm_pay_tp,
                                               pdm_index,
                                               pdm_kaot,
                                               pdm_nb,
                                               pdm_account,
                                               pdm_street,
                                               pdm_ns,
                                               pdm_building,
                                               pdm_block,
                                               pdm_apartment,
                                               pdm_nd,
                                               pdm_pay_dt,
                                               pdm_scc,
                                               pdm_is_actual)
                             VALUES (
                                        NULL,
                                        l_pd_id,
                                        rec_np.min_dt,
                                        rec_np.max_dt,
                                        'A',
                                        l_ap_id,
                                        'BANK',
                                        p_ls_indots,
                                        NULL,
                                        l_bank_id,
                                        rec_v_ls_sv2_data.sv2_vklad,
                                        NULL,
                                        l_ns4sv1,
                                        p_ls_adrdom,
                                        p_ls_adrkorp,
                                        p_ls_adrkv,
                                        NULL,
                                        CASE
                                            WHEN COALESCE (
                                                     TO_NUMBER (
                                                         TO_CHAR (
                                                             rec_np.min_dt,
                                                             'dd')),
                                                     0) <
                                                 4
                                            THEN
                                                4
                                            WHEN COALESCE (
                                                     TO_NUMBER (
                                                         TO_CHAR (
                                                             rec_np.min_dt,
                                                             'dd')),
                                                     0) >
                                                 25
                                            THEN
                                                25
                                            ELSE
                                                TO_NUMBER (
                                                    TO_CHAR (rec_np.min_dt,
                                                             'dd'))
                                        END,
                                        p_sc_scc,
                                        'T');

                    INSERT INTO pd_log (pdl_id,
                                        pdl_pd,
                                        pdl_hs,
                                        pdl_st,
                                        pdl_message,
                                        pdl_st_old,
                                        pdl_tp)
                             VALUES (
                                        NULL,
                                        l_pd_id,
                                        NULL,
                                        NULL,
                                           CHR (38)
                                        || '94#'
                                        || p_wu_txt
                                        || '#'
                                        || TO_CHAR (SYSDATE,
                                                    'dd.mm.yyyy hh24:mi:ss'),
                                        NULL,
                                        'SYS');

                    -- ADDDDD
                    INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                   ldr_trg,
                                                   ldr_code)
                             VALUES (rec_np.lfdp_id,
                                     l_pd_id,
                                     'USS_ESR.PC_DECISION');
                END IF;                          -- if rec_ls.ls_spos = 1 then

                ------------------------------------------------------------ОКОНЧАНИЕ БЛОКА ДЛЯ БАНКА -----------------------------------------------------------------------
                -- если решение не создалось
                IF l_pd_id IS NULL
                THEN
                    RAISE ex_error_create_pd;
                END IF;
            END IF;                             -- if rec_np.is_first = 1 then

            -- создаем віплату
            IF rec_np.npp = 1
            THEN
                INSERT INTO pd_payment (pdp_id,
                                        pdp_pd,
                                        pdp_npt,
                                        pdp_start_dt,
                                        pdp_stop_dt,
                                        pdp_sum,
                                        history_status,
                                        pdp_src)
                     VALUES (
                                NULL,
                                l_pd_id,
                                rec_np.npt_id,
                                rec_np.np_dnprav,
                                COALESCE (
                                    rec_np.np_dkprav,
                                    TO_DATE ('31.12.2099', 'dd.mm.yyyy')),
                                rec_np.sum_grp,
                                'A',
                                'MG')
                  RETURNING pdp_id
                       INTO l_pdp_id;
            END IF;                                  -- if rec_np.npp = 1 then

            -- создаем детали віплат
            INSERT INTO pd_detail (pdd_id,
                                   pdd_pdp,
                                   pdd_value,
                                   pdd_ndp,
                                   pdd_start_dt,
                                   pdd_stop_dt,
                                   pdd_row_name,
                                   pdd_npt)
                 VALUES (
                            NULL,
                            l_pdp_id,
                            rec_np.np_snadp,
                            290,
                            rec_np.np_dnprav,
                            rec_np.np_dkprav,
                               CHR (38)
                            || '63#'
                            || rec_np.ls_fio
                            || '#'
                            || rec_np.ls_drog,
                            rec_np.npt_id)
              RETURNING pdd_id
                   INTO l_pdd_id;

            -- акруал период создаем только для основного КФН
            IF rec_np.np_kfn = rec_np.ls_kfn
            THEN
                FOR vpo34
                    IN (SELECT *
                          FROM pc_decision  d
                               JOIN pd_accrual_period pap
                                   ON     pap.pdap_pd = d.pd_id
                                      AND pap.history_status = 'A'
                                      AND (   rec_np.np_dnprav BETWEEN pap.pdap_start_dt
                                                                   AND pap.pdap_stop_dt
                                           OR rec_np.np_dkprav BETWEEN pap.pdap_start_dt
                                                                   AND pap.pdap_stop_dt)
                         WHERE d.pd_pa = p_pa)
                LOOP
                    RAISE ex_error_34_period_exists;
                END LOOP;

                INSERT INTO pd_accrual_period (pdap_id,
                                               pdap_pd,
                                               pdap_start_dt,
                                               pdap_stop_dt,
                                               history_status,
                                               pdap_reason_stop)
                         VALUES (
                                    NULL,
                                    l_pd_id,
                                    rec_np.np_dnprav,
                                    rec_np.np_dkprav,
                                    'A',
                                    CASE
                                        WHEN     rec_np.np_dkprav <
                                                 LAST_DAY (TRUNC (SYSDATE))
                                             AND rec_np.np_block_psn <> '0'
                                        THEN
                                            'RMR' || rec_np.np_block_psn
                                        ELSE
                                            NULL
                                    END);
            END IF;

            IF     rec_np.np_dkprav < LAST_DAY (TRUNC (SYSDATE))
               AND rec_np.np_block_psn <> '0'
               AND rec_np.is_last = 1
            THEN
                INSERT INTO pc_block (pcb_id,
                                      pcb_pc,
                                      pcb_pd,
                                      pcb_tp,
                                      pcb_rnp,
                                      pcb_lock_pnp_tp,
                                      pcb_ap_src)
                     VALUES (NULL,
                             p_pc,
                             l_pd_id,
                             'MG',
                             20,
                             'CPY',
                             l_ap_id)
                  RETURNING pcb_id
                       INTO l_pcb_id;

                UPDATE pc_decision ddd
                   SET ddd.pd_pcb = l_pcb_id, ddd.pd_st = 'PS'
                 WHERE ddd.pd_id = l_pd_id;
            END IF;
        END LOOP;                                    -- конец массива НП (ПЕР)

        -- если решение не создалось
        IF l_pd_id IS NULL
        THEN
            RAISE ex_error_create_pd;
        END IF;

        -- для всех иждивенцев с ИНН создаем карточки
        AddPdFamily (p_lfd_lfd     => p_lfd_lfd,
                     p_ls_nls      => p_ls_nls,
                     p_nptc_nst    => p_nptc_nst,
                     p_pd_id       => l_pd_id,
                     p_ap_id       => l_ap_id,
                     p_aps_id      => l_aps_id,
                     p_np_dnprav   => l_np_dnprav);

        -- Начисления
        Load_Accrual (p_lfd_lfd   => p_lfd_lfd,
                      p_pc        => p_pc,
                      p_pd        => l_pd_id,
                      p_ls_nls    => p_ls_nls,
                      p_ls_org    => p_ls_org);

        -- Отчисления
        Load_Deduction (p_lfd_lfd       => p_lfd_lfd,
                        p_sc            => p_sc,
                        p_pc            => p_pc,
                        p_ap            => l_ap_id,
                        p_pa            => p_pa,
                        p_ls_nls        => p_ls_nls,
                        p_ls_org        => p_ls_org,
                        p_ls_base_org   => p_ls_base_org);
    END;

    -- заполнение начислений
    PROCEDURE Load_Accrual (p_lfd_lfd   NUMBER,
                            p_pc        NUMBER,
                            p_pd        NUMBER,
                            p_ls_nls    VARCHAR2,
                            p_ls_org    VARCHAR2)
    IS
        l_ac    NUMBER;
        l_acd   NUMBER;
    BEGIN
        -- init block
        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''. ''');

        DELETE FROM tmp_work_ids1;

        -- верхний цикл по НАКам
        FOR rec_nac
            IN (  SELECT ROW_NUMBER ()
                             OVER (PARTITION BY nac.nac_mec, nac.nac_god
                                   ORDER BY TO_NUMBER (nac.nac_npp), lfdp_id)
                             AS m_rn,
                         --min(to_date(lpad(nac.nac_mec,2,'0')||'.'||nac.nac_god DEFAULT Null ON CONVERSION ERROR, 'mm.yyyy')) over () as start_nac,  -- пока ненужно
                         --max(to_date(lpad(nac.nac_mec,2,'0')||'.'||nac.nac_god DEFAULT Null ON CONVERSION ERROR, 'mm.yyyy')) over () as end_nac,    -- пока ненужно
                         TO_DATE (
                             LPAD (nac.nac_mec, 2, '0') || '.' || nac.nac_god
                                 DEFAULT NULL ON CONVERSION ERROR,
                             'mm.yyyy')
                             AS nac_dt,
                         nac.*
                    FROM ( -- блок данных на основании НАККФН (за отсутствия НАК)
                            SELECT nac.lfd_id,
                                   nac.lfd_lfd,
                                   nac.lfd_create_dt,
                                   MIN (nac.lfdp_id)
                                       AS lfdp_id,
                                   MIN (nac.rn)
                                       AS rn,
                                   nac.ls_nls,
                                   TO_CHAR (
                                       EXTRACT (
                                           YEAR FROM TO_DATE (
                                                         nac.nac_datop
                                                             DEFAULT NULL ON CONVERSION ERROR,
                                                         'dd.mm.yyyy')))
                                       AS nac_god,
                                   TO_CHAR (
                                       EXTRACT (
                                           MONTH FROM TO_DATE (
                                                          nac.nac_datop
                                                              DEFAULT NULL ON CONVERSION ERROR,
                                                          'dd.mm.yyyy')))
                                       AS nac_mec,
                                   NULL
                                       AS nac_npp,
                                   NULL
                                       AS nac_sved,
                                   NULL
                                       AS nac_nved,
                                   NULL
                                       AS nac_datspis,
                                   NULL
                                       AS bj_neop,
                                   NULL
                                       AS bj_tved,
                                   NULL
                                       AS bj_spos,
                                   NULL
                                       AS nac_indots,
                                   NULL
                                       AS nac_mecn,
                                   NULL
                                       AS nac_godn,
                                   NULL
                                       AS nac_nppn,
                                   NULL
                                       AS nac_tip,
                                   NULL
                                       AS nac_tved
                              FROM uss_exch.v_ls_nackfn_data nac
                             WHERE     nac.lfd_lfd = p_lfd_lfd
                                   AND nac.ls_nls = p_ls_nls
                                   AND nac.nac_god = '0'
                                   AND nac.nac_mec = '0'
                                   AND TO_DATE (
                                           nac.nac_datop
                                               DEFAULT NULL ON CONVERSION ERROR,
                                           'dd.mm.yyyy')
                                           IS NOT NULL
                                   AND NOT EXISTS
                                           (SELECT 1
                                              FROM uss_exch.v_ls_nac_data n
                                             WHERE     n.lfd_lfd = nac.lfd_lfd
                                                   AND n.ls_nls = nac.ls_nls
                                                   AND TO_DATE (
                                                              LPAD (n.nac_mec,
                                                                    2,
                                                                    '0')
                                                           || '.'
                                                           || n.nac_god
                                                               DEFAULT NULL ON CONVERSION ERROR,
                                                           'mm.yyyy') =
                                                       TRUNC (
                                                           TO_DATE (
                                                               nac.nac_datop
                                                                   DEFAULT NULL ON CONVERSION ERROR,
                                                               'dd.mm.yyyy'),
                                                           'month'))
                          GROUP BY nac.lfd_id,
                                   nac.lfd_lfd,
                                   nac.lfd_create_dt,
                                   nac.ls_nls,
                                   nac.nac_datop
                          UNION    -- БЛОК нормальнных данных на основании НАК
                          SELECT nac.lfd_id,
                                 nac.lfd_lfd,
                                 nac.lfd_create_dt,
                                 nac.lfdp_id,
                                 nac.rn,
                                 nac.ls_nls,
                                 nac.nac_god,
                                 nac.nac_mec,
                                 nac.nac_npp,
                                 nac.nac_sved,
                                 nac.nac_nved,
                                 nac.nac_datspis,
                                 nac.bj_neop,
                                 nac.bj_tved,
                                 nac.bj_spos,
                                 nac.nac_indots,
                                 nac.nac_mecn,
                                 nac.nac_godn,
                                 nac.nac_nppn,
                                 nac.nac_tip,
                                 nac.nac_tved
                            FROM uss_exch.v_ls_nac_data nac
                           WHERE     nac.lfd_lfd = p_lfd_lfd
                                 AND nac.ls_nls = p_ls_nls
                                 AND TO_DATE (
                                            LPAD (nac.nac_mec, 2, '0')
                                         || '.'
                                         || nac.nac_god
                                             DEFAULT NULL ON CONVERSION ERROR,
                                         'mm.yyyy')
                                         IS NOT NULL) nac
                ORDER BY nac_dt, m_rn)
        LOOP
            -- https://redmine.medirent.com.ua/redmine/issues/79599 (2)
            IF rec_nac.m_rn = 1
            THEN
                BEGIN
                    -- вибираем ранее внесенній контейнер по акруалам
                    SELECT ac_id
                      INTO l_ac
                      FROM accrual ac
                     WHERE ac.ac_pc = p_pc AND ac_month = rec_nac.nac_dt;

                    -- заменяем орг на актуальній
                    UPDATE accrual aaa
                       SET aaa.com_org = p_ls_org
                     WHERE aaa.ac_id = l_ac AND aaa.com_org <> p_ls_org;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        -- если не найденно инсертив акруал
                        INSERT INTO accrual (ac_id,
                                             ac_pc,
                                             ac_month,
                                             ac_st,
                                             history_status,
                                             com_org)
                             VALUES (NULL,
                                     p_pc,
                                     rec_nac.nac_dt,
                                     'R',
                                     'A',
                                     p_ls_org)
                          RETURNING ac_id
                               INTO l_ac;
                END;

                INSERT INTO tmp_work_ids1
                     VALUES (l_ac);

                -- АДДДДДДДД
                INSERT INTO uss_exch.v_ls2uss (ldr_lfdp, ldr_trg, ldr_code)
                     VALUES (rec_nac.lfdp_id, l_ac, 'USS_ESR.ACCRUAL');
            END IF;

            -- детальна інформація щодо нарахувань.
            FOR rec_nackfn
                IN (  SELECT nk.*,
                             o.op_id,
                             o.op_tp1,
                             npt.npt_id,
                             TO_DATE (
                                 LPAD (nk.nac_mec, 2, '0') || '.' || nk.nac_god
                                     DEFAULT NULL ON CONVERSION ERROR,
                                 'mm.yyyy')    AS nackfn_dt,
                             TO_DATE (
                                    LPAD (nk.nac_mecf, 2, '0')
                                 || '.'
                                 || nk.nac_godf
                                     DEFAULT NULL ON CONVERSION ERROR,
                                 'mm.yyyy')    AS nackfn_f_dt
                        FROM uss_exch.v_ls_nackfn_data nk
                             LEFT JOIN uss_ndi.v_ndi_op o
                                 ON o.op_code = nk.nac_op
                             LEFT JOIN uss_ndi.v_ndi_payment_type npt
                                 ON     npt.npt_code = nk.nac_kfn
                                    AND npt.history_status = 'A'
                       WHERE     nk.lfd_lfd = rec_nac.lfd_lfd
                             AND nk.ls_nls = rec_nac.ls_nls
                             --and nk.nac_god = rec_nac.nac_god
                             --and nk.nac_mec = rec_nac.nac_mec
                             --and nk.nac_npp = rec_nac.nac_npp
                             -- 11_10_2022 убрал данные три строки как привязку к дате операции, так как большинство записей
                             -- ссылаются на ошибочные записи из массива НАК
                             -- 18.10.2022 вернул но для верхнего цикла создаю записи на основании даты операции из масива v_ls_nackfn_data
                             AND COALESCE (NULLIF (nk.nac_god, '0'),
                                           SUBSTR (nk.nac_datop, 7, 4)) =
                                 rec_nac.nac_god
                             AND COALESCE (
                                     NULLIF (nk.nac_mec, '0'),
                                     TO_CHAR (
                                         TO_NUMBER (
                                             SUBSTR (nk.nac_datop, 4, 2)))) =
                                 rec_nac.nac_mec
                             -- 21102022 - хомут для долгов, вызвано тем что неодназначно определен за номером по попорядку контейнер к которому можно присоединить долг
                             -- присоединяем к тому который по номеру по порядку определен как первый
                             -- and coalesce(nullif(nk.nac_npp,'0'),'1') = rec_nac.nac_npp
                             AND (   (nk.nac_npp = rec_nac.nac_npp)
                                  OR (    nk.nac_god = '0'
                                      AND nk.nac_mec = '0'
                                      AND rec_nac.m_rn = 1))
                    ORDER BY nackfn_dt, nackfn_f_dt)
            LOOP
                -- https://redmine.medirent.com.ua/redmine/issues/79966  (3)
                IF rec_nackfn.nac_op = '5010' AND rec_nackfn.nac_kfn = '0'
                THEN
                    NULL;
                ELSE
                    IF rec_nackfn.op_id IS NULL
                    THEN
                        l_error_prm := rec_nackfn.nac_op;
                        RAISE ex_error_op_accrual;
                    END IF;

                    IF rec_nackfn.npt_id IS NULL
                    THEN
                        l_error_prm :=
                            rec_nackfn.nac_mecf || '.' || rec_nackfn.nac_godf;
                        RAISE ex_error_npt_accrual;
                    END IF;

                    INSERT INTO ac_detail (acd_id,
                                           acd_ac,
                                           acd_op,
                                           acd_npt,
                                           acd_start_dt,
                                           acd_stop_dt,
                                           acd_sum,
                                           acd_month_sum,
                                           acd_delta_recalc,
                                           acd_delta_pay,
                                           acd_dn,
                                           acd_pd,
                                           acd_ac_start_dt,
                                           acd_ac_stop_dt,
                                           acd_is_indexed,
                                           acd_st,
                                           history_status,
                                           acd_payed_sum,
                                           acd_imp_pr_num)
                         VALUES (
                                    NULL,
                                    l_ac,
                                    rec_nackfn.op_id,
                                    rec_nackfn.npt_id,
                                    rec_nackfn.nackfn_f_dt,
                                      ADD_MONTHS (rec_nackfn.nackfn_f_dt, 1)
                                    - 1,
                                    rec_nackfn.nac_snac,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    p_pd,
                                    rec_nac.nac_dt,
                                    ADD_MONTHS (rec_nac.nac_dt, 1) - 1,
                                    'F',
                                    'R',
                                    'A',
                                    CASE
                                        WHEN     rec_nac.Bj_Neop = 0
                                             AND rec_nackfn.nac_god <> 0
                                             AND rec_nackfn.nac_mec <> 0
                                             AND rec_nackfn.nac_npp <> 0
                                        THEN
                                            rec_nackfn.nac_snac
                                        WHEN     rec_nac.Bj_Neop = 1
                                             AND rec_nac.nac_godn <> 0
                                             AND rec_nac.nac_mecn <> 0
                                             AND rec_nac.nac_nppn <> 0
                                             AND rec_nackfn.nac_god <> 0
                                             AND rec_nackfn.nac_mec <> 0
                                             AND rec_nackfn.nac_npp <> 0
                                        THEN
                                            rec_nackfn.nac_snac
                                        ELSE
                                            NULL
                                    END,
                                    CASE
                                        WHEN     rec_nac.Bj_Neop = 0
                                             AND rec_nackfn.nac_god <> 0
                                             AND rec_nackfn.nac_mec <> 0
                                             AND rec_nackfn.nac_npp <> 0
                                        THEN
                                            rec_nac.nac_nved
                                        WHEN     rec_nac.Bj_Neop = 1
                                             AND rec_nac.nac_nppn <> 0
                                             AND rec_nackfn.nac_god <> 0
                                             AND rec_nackfn.nac_mec <> 0
                                             AND rec_nackfn.nac_npp <> 0
                                        THEN
                                            rec_nac.nac_nppn
                                        ELSE
                                            NULL
                                    END)
                      RETURNING acd_id
                           INTO l_acd;

                    INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                   ldr_trg,
                                                   ldr_code)
                             VALUES (rec_nackfn.lfdp_id,
                                     l_acd,
                                     'USS_ESR.AC_DETAIL');

                    -- за даним рішенням є наразування, тобто переводемо рішення в статус Нараховано = S
                    -- убрал по команде КЕВ также как и поставил по команде КЕВ
                    -- поставил по команде КЕВ
                    UPDATE pc_decision ddd
                       SET ddd.pd_st = 'S'
                     WHERE     ddd.pd_id = p_pd
                           AND rec_nackfn.op_tp1 = 'NR'
                           AND ddd.pd_st = 'P';
                END IF;
            END LOOP;
        END LOOP;
    -- от Павлюкова и Никоновой какое то апи через tmp_work_ids1
    --api$accrual.actuilize_payed_sum(2);
    END;

    PROCEDURE Load_Deduction (p_lfd_lfd       NUMBER,  -- группа файлов(архив)
                              p_sc            NUMBER,            -- socialcard
                              p_pc            NUMBER,          -- personalcase
                              p_ap            NUMBER,                -- appeal
                              p_pa            NUMBER,
                              p_ls_nls        VARCHAR2,
                              p_ls_org        VARCHAR2,
                              p_ls_base_org   VARCHAR2)
    IS
        --l_ap          number;
        l_ps     NUMBER;
        l_dn     NUMBER;
        l_dnd    NUMBER;
        l_ndn    NUMBER;
        l_unit   VARCHAR2 (10);
        l_dpp    NUMBER;
        l_dppa   NUMBER;
        l_nb     NUMBER;
    BEGIN
        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''. ''');

        FOR rec_ispl
            IN (  SELECT --+ index(i) index(u) index(v) use_nl(i u) use_nl(i v)
                         ROWNUM
                             AS is_first,
                         i.lfd_id,
                         i.lfd_lfd,
                         i.lfd_records,
                         i.lfd_create_dt,
                         i.lfdp_id,
                         i.rn,
                         i.ls_nls,
                         i.ispl_kud,
                         i.ispl_num,
                         TO_DATE (i.ispl_dpd, 'dd.mm.yyyy')
                             AS ispl_dpd,
                         i.ispl_vhn,
                         i.ispl_kd,
                         i.ispl_nd,
                         TO_DATE (i.ispl_dv, 'dd.mm.yyyy')
                             AS ispl_dv,
                         i.ispl_ksud,
                         i.ispl_kvz,
                         i.ispl_kold,
                         TO_DATE (i.ispl_datast, 'dd.mm.yyyy')
                             AS ispl_datast,
                         i.ispl_postdolg,
                         i.ispl_dolg,
                         i.ispl_sp,
                         i.ispl_sumud,
                         i.ispl_srud,
                         i.ispl_persud,
                         i.ispl_persud1,
                         TO_DATE (i.ispl_datu, 'dd.mm.yyyy')
                             AS ispl_datu,
                         --lead(to_date(i.ispl_datu, 'dd.mm.yyyy')) over (partition by i.lfd_lfd, i.Ls_Nls, i.ispl_kud order by i.ispl_kud, i.ispl_num)-1 as ispl_datu_end,
                         TO_DATE (i.ispl_displ, 'dd.mm.yyyy')
                             AS ispl_displ,
                         --lead(to_date(i.ispl_displ, 'dd.mm.yyyy')) over (partition by i.lfd_lfd, i.Ls_Nls, i.ispl_kud order by i.ispl_kud, i.ispl_num)-1 as ispl_displ_end,
                         i.ispl_spos,
                         i.ispl_kdp,
                         i.ispl_ost,
                         i.ispl_rudp,
                         i.ispl_rud,
                         i.ispl_gor,
                         i.ispl_kin,
                         TO_DATE (i.ispl_datin, 'dd.mm.yyyy')
                             AS ispl_datin,
                         u.ud_psn,
                         TO_DATE (u.ud_dso, 'dd.mm.yyyy')
                             AS ud_dso,
                         v.klovud_code,
                         v.klovud_name,
                         v.klovud_nrsb,
                         v.klovud_nrso,
                         v.klovud_dopnr,
                         v.klovud_privo,
                         v.klovud_nameb,
                         v.klovud_mfo,
                         v.klovud_indpo,
                         v.klovud_adr,
                         v.klovud_prim,
                         (SELECT ppl_prizn
                            FROM uss_exch.v_ls_ppl_data ppl
                           WHERE     ppl.lfd_lfd = i.lfd_lfd
                                 AND ppl.ls_nls = i.Ls_Nls
                                 AND ppl_sum = ispl_dolg
                           FETCH FIRST ROW ONLY)
                             AS ppl_prizn
                    FROM uss_exch.v_ls_ispl_data i
                         LEFT JOIN uss_exch.v_ls_ud_data u
                             ON     u.lfd_lfd = i.lfd_lfd
                                AND u.ls_nls = i.ls_nls
                                AND u.ispl_kud = i.ispl_kud
                                AND u.ispl_num = i.ispl_num
                         LEFT JOIN uss_exch.v_b_klovud v
                             ON     v.klovud_code = i.ispl_kvz
                                AND v.lfd_lfd = i.lfd_lfd
                   WHERE i.lfd_lfd = p_lfd_lfd AND i.ls_nls = p_ls_nls
                ORDER BY i.ispl_kud, i.ispl_num)
        LOOP
            --if rec_ispl.is_first = 1 then
            --      -- СОЗДАНИЕ ОБРАЩЕНИЯ
            --      insert into appeal (ap_id,ap_pc,ap_tp,
            --                          ap_reg_dt,com_org,ap_num)
            --      values (null,p_pc,'V',
            --              rec_ispl.ispl_dpd,p_ls_org,p_ls_base_org||'_'||p_ls_nls)
            --      returning ap_id into l_ap;
            --      -- ADDDDD
            --      insert into uss_exch.v_ls2uss(ldr_lfdp,ldr_trg,ldr_code) values(rec_ispl.lfdp_id,l_ap,'USS_ESR.APPEAL');
            --end if;
            l_dpp := NULL;
            l_dppa := NULL;
            l_nb := NULL;
            l_ndn := NULL;

            IF rec_ispl.ispl_kvz > 0
            THEN
                IF rec_ispl.klovud_code IS NOT NULL
                THEN
                    -- отримувачі та платники (справочник отримувачыв та платникыв) - если нет записи добавляем
                    BEGIN
                        SELECT npp.dpp_id
                          INTO l_dpp
                          FROM uss_ndi.v_ndi_pay_person npp
                         WHERE     npp.dpp_tax_code = rec_ispl.klovud_nrsb
                               AND npp.dpp_org = p_ls_base_org
                               AND ROWNUM = 1;
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                            BEGIN
                                SELECT npp.dpp_id
                                  INTO l_dpp
                                  FROM uss_ndi.v_ndi_pay_person npp
                                 WHERE     npp.dpp_tax_code =
                                           rec_ispl.klovud_nrsb
                                       AND npp.dpp_org = p_ls_org
                                       AND ROWNUM = 1;
                            EXCEPTION
                                WHEN NO_DATA_FOUND
                                THEN
                                    INSERT INTO uss_ndi.ndi_pay_person (
                                                    dpp_id,
                                                    dpp_tax_code,
                                                    dpp_name,
                                                    dpp_org,
                                                    history_status,
                                                    dpp_sname,
                                                    dpp_address,
                                                    dpp_tp,
                                                    dpp_is_ur,
                                                    dpp_hs_upd,
                                                    dpp_hs_del)
                                         VALUES (
                                                    NULL,
                                                    rec_ispl.klovud_nrsb,
                                                    rec_ispl.klovud_name,
                                                    p_ls_org,
                                                    'A',
                                                    rec_ispl.klovud_code,
                                                       rec_ispl.klovud_indpo
                                                    || ', '
                                                    || rec_ispl.klovud_adr,
                                                    'STAL',
                                                    'TRUE',
                                                    NULL,
                                                    NULL)
                                      RETURNING dpp_id
                                           INTO l_dpp;
                            END;
                    END;

                    -- рассчетніе счета для отримувача та платника
                    BEGIN
                        SELECT nppa.dppa_id
                          INTO l_dppa
                          FROM uss_ndi.ndi_pay_person_acc nppa
                         WHERE     nppa.dppa_dpp = l_dpp
                               AND nppa.dppa_account = rec_ispl.klovud_nrso
                               AND ROWNUM = 1;
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN -- не найдені рассчетніе счета для отримувача та платника - необходимо дозаполнить
                            -- находим банк по мфо
                            BEGIN
                                SELECT b.nb_id
                                  INTO l_nb
                                  FROM uss_ndi.v_ndi_bank b
                                 WHERE     b.nb_mfo =
                                           COALESCE (
                                               NULLIF (rec_ispl.klovud_mfo,
                                                       '0'),
                                               SUBSTR (rec_ispl.klovud_nrso,
                                                       5,
                                                       6))
                                       AND b.history_status = 'A';
                            EXCEPTION
                                WHEN NO_DATA_FOUND
                                THEN
                                    l_nb := NULL;
                            END;

                            -- если ненайдено то вствавляем инфу про банки
                            INSERT INTO uss_ndi.ndi_pay_person_acc (
                                            dppa_id,
                                            dppa_dpp,
                                            dppa_nb,
                                            dppa_is_main,
                                            dppa_ab_id,
                                            history_status,
                                            dppa_account,
                                            dppa_nbg,
                                            dppa_is_social,
                                            dppa_last_payment_order,
                                            dppa_hs_upd,
                                            dppa_hs_del,
                                            dppa_description)
                                 VALUES (NULL,
                                         l_dpp,
                                         l_nb,
                                         NULL,
                                         NULL,
                                         'A',
                                         rec_ispl.klovud_nrso,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         rec_ispl.klovud_prim)
                              RETURNING dppa_id
                                   INTO l_dppa;
                    END;
                ELSE
                    l_error_prm := rec_ispl.ispl_kvz;
                    RAISE ex_error_klovud_deduction;
                END IF;
            END IF;

            -- держутримання
            INSERT INTO pc_state_alimony (ps_id,
                                          ps_pc,
                                          ps_dpp,
                                          ps_start_dt,
                                          ps_stop_dt,
                                          ps_ap,
                                          ps_hs_ins,
                                          ps_st,
                                          ps_sc)
                 VALUES (NULL,
                         p_pc,
                         l_dpp,
                         rec_ispl.Ispl_DatU,
                         rec_ispl.Ud_Dso,
                         p_ap,
                         NULL,
                         'R',
                         p_sc)
              RETURNING ps_id
                   INTO l_ps;

            -- инициализация дополнительніх справочников
            BEGIN
                SELECT dic.ndn_id
                  INTO l_ndn
                  FROM uss_ndi.v_ndi_deduction dic
                 WHERE dic.ndn_code = rec_ispl.ispl_kud;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    l_error_prm := rec_ispl.ispl_kud;
                    RAISE ex_error_kud_deduction;
            END;

            l_unit :=
                CASE
                    WHEN rec_ispl.ispl_sp = 1 THEN 'PD'
                    WHEN rec_ispl.ispl_sp = 2 THEN 'AS'
                    WHEN rec_ispl.ispl_sp = 3 THEN 'SD'
                    WHEN rec_ispl.ispl_sp = 4 THEN 'AS'
                    ELSE ''
                END;

            ----------------------------------------------------------------------------------------------
            IF rec_ispl.Ud_Dso IS NOT NULL
            THEN
                -- вставка утримань
                INSERT INTO deduction (dn_id,
                                       dn_pc,
                                       dn_ndn,
                                       dn_in_doc_tp,
                                       dn_in_doc_num,
                                       dn_in_doc_dt,
                                       dn_out_doc_num,
                                       dn_out_doc_dt,
                                       dn_unit,
                                       dn_st,
                                       history_status,
                                       dn_debt_total,
                                       dn_debt_current,
                                       dn_is_min_pay,
                                       dn_debt_post,
                                       dn_prc_above,
                                       dn_block_dt,
                                       dn_block_reason,
                                       dn_start_dt,
                                       dn_stop_dt,
                                       dn_unlock_dt,
                                       com_org,
                                       dn_ps,
                                       dn_ap,
                                       dn_dpp,
                                       dn_tp,
                                       dn_pa,
                                       dn_reason)
                     VALUES (NULL,
                             p_pc,
                             l_ndn,
                             rec_ispl.ispl_kd,
                             rec_ispl.Ispl_Vhn,
                             rec_ispl.Ispl_Dpd,
                             rec_ispl.Ispl_Nd,
                             NULL,
                             l_unit,
                             'R',
                             'A',
                             rec_ispl.Ispl_Dolg,
                             rec_ispl.Ispl_Ost,
                             'F',
                             rec_ispl.Ispl_PostDolg,
                             NULL,
                             rec_ispl.Ud_Dso,
                             rec_ispl.Ud_Psn,
                             rec_ispl.Ispl_DatU,
                             rec_ispl.Ud_Dso,
                             NULL,
                             p_ls_org,
                             l_ps,
                             p_ap,
                             l_dpp,
                             CASE WHEN l_dpp IS NULL THEN 'R' ELSE NULL END,
                             p_pa,
                             rec_ispl.ppl_prizn)
                  RETURNING dn_id
                       INTO l_dn;

                -- ADDDDD
                INSERT INTO uss_exch.v_ls2uss (ldr_lfdp, ldr_trg, ldr_code)
                     VALUES (rec_ispl.lfdp_id, l_dn, 'USS_ESR.DEDUCTION');

                INSERT INTO dn_detail (dnd_id,
                                       dnd_dn,
                                       dnd_start_dt,
                                       dnd_stop_dt,
                                       dnd_tp,
                                       dnd_value,
                                       history_status,
                                       dnd_psc,
                                       dnd_value_prefix,
                                       dnd_dppa)
                     VALUES (NULL,
                             l_dn,
                             rec_ispl.Ispl_DatU,
                             rec_ispl.Ud_Dso,
                             l_unit,
                             rec_ispl.ispl_persud,
                             'A',
                             NULL,
                             rec_ispl.ispl_persud1,
                             NULL)
                  RETURNING dnd_id
                       INTO l_dnd;

                INSERT INTO uss_exch.v_ls2uss (ldr_lfdp, ldr_trg, ldr_code)
                     VALUES (rec_ispl.lfdp_id, l_dnd, 'USS_ESR.DN_DETAIL');
            ELSE
                -- вставка утримань
                INSERT INTO deduction (dn_id,
                                       dn_pc,
                                       dn_ndn,
                                       dn_in_doc_tp,
                                       dn_in_doc_num,
                                       dn_in_doc_dt,
                                       dn_out_doc_num,
                                       dn_out_doc_dt,
                                       dn_unit,
                                       dn_st,
                                       history_status,
                                       dn_debt_total,
                                       dn_debt_current,
                                       dn_is_min_pay,
                                       dn_debt_post,
                                       dn_prc_above,
                                       dn_block_dt,
                                       dn_block_reason,
                                       dn_start_dt,
                                       dn_stop_dt,
                                       dn_unlock_dt,
                                       com_org,
                                       dn_ps,
                                       dn_ap,
                                       dn_dpp,
                                       dn_debt_limit_prc,
                                       dn_tp,
                                       dn_pa)
                     VALUES (NULL,
                             p_pc,
                             l_ndn,
                             rec_ispl.ispl_kd,
                             rec_ispl.Ispl_Vhn,
                             rec_ispl.Ispl_Dpd,
                             rec_ispl.Ispl_Nd,
                             NULL,
                             l_unit,
                             'R',
                             'A',
                             rec_ispl.Ispl_Dolg,
                             rec_ispl.Ispl_Ost,
                             'F',
                             rec_ispl.Ispl_PostDolg,
                             NULL,
                             rec_ispl.Ud_Dso,
                             rec_ispl.Ud_Psn,
                             rec_ispl.Ispl_DatU,
                             rec_ispl.Ud_Dso,
                             NULL,
                             p_ls_org,
                             l_ps,
                             p_ap,
                             l_dpp,
                             rec_ispl.ispl_persud,
                             CASE WHEN l_dpp IS NULL THEN 'R' ELSE NULL END,
                             p_pa)
                  RETURNING dn_id
                       INTO l_dn;

                -- ADDDDD
                INSERT INTO uss_exch.v_ls2uss (ldr_lfdp, ldr_trg, ldr_code)
                     VALUES (rec_ispl.lfdp_id, l_dn, 'USS_ESR.DEDUCTION');

                INSERT INTO dn_detail (dnd_id,
                                       dnd_dn,
                                       dnd_start_dt,
                                       dnd_stop_dt,
                                       dnd_tp,
                                       dnd_value,
                                       history_status,
                                       dnd_psc,
                                       dnd_value_prefix,
                                       dnd_dppa)
                     VALUES (NULL,
                             l_dn,
                             TRUNC (SYSDATE, 'month'),
                             LAST_DAY (TRUNC (SYSDATE)),
                             'AS',
                             rec_ispl.Ispl_Ost,
                             'A',
                             NULL,
                             rec_ispl.ispl_persud1,
                             NULL)
                  RETURNING dnd_id
                       INTO l_dnd;
            END IF;

            -------------------------------------------------------------------------------------------------------------

            -- по косвеннім методам развязіваем відрахування сотрицительніми нарахуваннями  o.op_code like '6___')
            UPDATE ac_detail ddd
               SET ddd.acd_dn = l_dn
             WHERE     ddd.acd_pd IN (SELECT pd_id
                                        FROM pc_decision pd
                                       WHERE pd.pd_ap = p_ap)
                   AND ddd.acd_start_dt BETWEEN rec_ispl.Ispl_DatU
                                            AND COALESCE (rec_ispl.Ud_Dso,
                                                          SYSDATE)
                   AND ddd.acd_op IN (SELECT o.op_id
                                        FROM uss_ndi.v_ndi_op o
                                       WHERE o.op_tp1 = 'DN');
        END LOOP;
    END;
BEGIN
    -- Initialization
    NULL;
END;
/