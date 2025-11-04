/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.LOAD$INC
IS
    -- Author  : JSHPAK
    -- Created : 24.11.2022 11:18:57
    -- Purpose :
    PROCEDURE Load_Inc (p_lfd_id NUMBER);

    FUNCTION utf8_to_win1251 (i_str IN VARCHAR2)
        RETURN VARCHAR2;

    -- IC #99752
    -- Додати можливість в міграції завантаження даних по студентам
    PROCEDURE Load_Inc_St (p_lfd_id NUMBER);
END load$inc;
/


GRANT EXECUTE ON USS_PERSON.LOAD$INC TO USS_EXCH
/


/* Formatted on 8/12/2025 5:57:03 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.LOAD$INC
IS
    lBuffer            BINARY_INTEGER := 16383;
    cEndOfLine         CHAR (2) := CHR (13) || CHR (10);
    vCharBuffer        VARCHAR2 (32767);

    ex_error_sc_else   EXCEPTION;
    ex_error_sc_1      EXCEPTION;
    ex_error_sc_2      EXCEPTION;

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

    PROCEDURE SetIncLog (p_lfdp NUMBER, p_trg NUMBER, p_code VARCHAR2)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        DELETE FROM uss_exch.v_ls2uss u
              WHERE u.ldr_lfdp = p_lfdp AND u.ldr_trg = -1;

        INSERT INTO uss_exch.v_ls2uss (ldr_lfdp, ldr_trg, ldr_code)
             VALUES (p_lfdp, p_trg, SUBSTR (p_code, 1, 500));

        COMMIT;
    END;

    PROCEDURE Load_Inc (p_lfd_id NUMBER)
    IS
        l_sil_id      NUMBER;
        l_sc_id       NUMBER;
        l_sc_scc      NUMBER;
        l_sc_unique   VARCHAR2 (100);

        l_blob        BLOB;
        l_file_name   VARCHAR2 (255);
        l_prev_cnt    NUMBER;
        l_prev_lfd    NUMBER;
    BEGIN
        DBMS_LOB.createtemporary (l_blob, TRUE);

        -- визначення завантажємого файлу
        SELECT d.lfd_file_name
          INTO l_file_name
          FROM uss_exch.load_file_data d
         WHERE d.lfd_id = p_lfd_id;

        -- визначаємо попередній файл завантаження, та кількість завантажених
        BEGIN
              SELECT d.lfd_id, COUNT (*)
                INTO l_prev_lfd, l_prev_cnt
                FROM sc_income_link t
                     JOIN uss_exch.load_file_data d ON d.lfd_id = t.sil_lfd
               WHERE     UPPER (d.lfd_file_name) = UPPER (l_file_name)
                     AND d.lfd_id <> p_lfd_id
            GROUP BY d.lfd_id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                l_prev_cnt := 0;
        END;

        --dbms_session.set_nls('NLS_DATE_FORMAT', '''dd.mm.yyyy''');
        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''. ''');

        FOR rec_inc
            IN (SELECT TRIM (SUBSTR (inc.inc_fio || '   ',
                                     1,
                                     INSTR (inc.inc_fio || '   ',
                                            ' ',
                                            1,
                                            1)))      AS fio_ln,
                       TRIM (SUBSTR (inc.inc_fio || '   ',
                                     INSTR (inc.inc_fio || '   ',
                                            ' ',
                                            1,
                                            1),
                                       INSTR (inc.inc_fio || '   ',
                                              ' ',
                                              1,
                                              2)
                                     - INSTR (inc.inc_fio || '   ',
                                              ' ',
                                              1,
                                              1)))    AS fio_fn,
                       TRIM (SUBSTR (inc.inc_fio || '   ',
                                     INSTR (inc.inc_fio || '   ',
                                            ' ',
                                            1,
                                            2),
                                     500))            AS fio_sn,
                       inc.*
                  FROM (SELECT LPAD (LPAD (inc.inc_raj, 4, '0'), 5, '5')
                                   AS inc_base_org,
                               COALESCE (
                                   TO_CHAR (o.nddc_code_dest),
                                   LPAD (LPAD (inc.inc_raj, 4, '0'), 5, '5'))
                                   AS inc_org,
                               inc.lfd_id,
                               lfd_lfd,
                               lfd_records,
                               lfd_create_dt,
                               lfd_file_name,
                               lfd_user_id,
                               lfdp_id,
                               rn,
                               TO_NUMBER (inc_raj)
                                   AS inc_raj,
                               TO_NUMBER (inc_num)
                                   AS inc_num,
                               REPLACE (
                                   TRANSLATE (UPPER (inc_fio),
                                              'ETIOPAHKXCBM1',
                                              'ЕТІОРАНКХСВМІ'),
                                   '  ',
                                   ' ')
                                   AS inc_fio,
                               REPLACE (
                                   REPLACE (
                                       TRANSLATE (UPPER (inc_pasp),
                                                  'ETIOPAHKXCBM',
                                                  'ЕТІОРАНКХСВМ'),
                                       '-',
                                       ''),
                                   ' ',
                                   '')
                                   AS inc_pasp,
                               inc_idcode,
                               inc_indots,
                               TO_NUMBER (inc_adrul)
                                   AS inc_adrul,
                               inc_adrdom,
                               inc_adrkorp,
                               inc_adrkv,
                               TO_DATE (inc_acc_dt, 'mmyy')
                                   AS inc_acc_dt,
                               TO_DATE (inc_pay_dt, 'mmyy')
                                   AS inc_pay_dt,
                               TO_NUMBER (inc_sum)
                                   AS inc_sum,
                               TO_NUMBER (inc_code)
                                   AS inc_code,
                               inc_is_work,
                               inc_is_dd,
                               inc_is_resp,
                               CASE
                                   WHEN inc_is_resp = '1' THEN inc_resp_bd
                                   ELSE NULL
                               END
                                   AS inc_resp_bd,
                               inc_resp_doc_tp
                          FROM uss_exch.v_income_data  inc
                               INNER JOIN uss_ndi.V_DDN_SIL_INC d
                                   ON     d.dic_code =
                                          LTRIM (inc.inc_code, '0') -- IC #101461
                                      AND d.dic_code IN ('1',
                                                         '2',
                                                         '3',
                                                         '4',
                                                         '5',
                                                         '7',
                                                         '8',
                                                         '9',
                                                         '10',
                                                         '11',
                                                         '12',
                                                         '13',
                                                         '14',
                                                         '15',
                                                         '16',
                                                         '17',
                                                         '18',
                                                         '19',
                                                         '20',
                                                         '21',
                                                         '22',
                                                         '23',
                                                         '26',
                                                         '28',
                                                         '29',
                                                         '32',
                                                         '33',
                                                         '34',
                                                         '35',
                                                         '36',
                                                         '38',
                                                         '41',
                                                         '44',
                                                         '49',
                                                         '50',
                                                         '52',
                                                         '53',
                                                         '54',
                                                         '55',
                                                         '56',
                                                         '57',
                                                         '58',
                                                         '59',
                                                         '60',
                                                         '61',
                                                         '62',
                                                         '63',
                                                         '64',
                                                         '65',
                                                         '66',
                                                         '67',
                                                         '68',
                                                         '69',
                                                         '72',
                                                         '73',
                                                         '74',
                                                         '75',
                                                         '76',
                                                         '77',
                                                         '78',
                                                         '79',
                                                         '80',
                                                         '81')
                               LEFT JOIN uss_ndi.v_ndi_decoding_config o
                                   ON     o.nddc_code_src =
                                          LPAD (LPAD (inc.inc_raj, 4, '0'),
                                                5,
                                                '5')
                                      AND o.nddc_tp = 'ORG_MIGR'
                               LEFT JOIN sc_income_link sil
                                   ON sil.sil_lfdp = inc.lfdp_id
                         WHERE inc.lfd_id = p_lfd_id AND sil.sil_id IS NULL)
                       inc)
        LOOP
            BEGIN
                l_sc_id := NULL;
                l_sc_scc := NULL;
                l_sc_unique := NULL;

                l_sc_id :=
                    uss_person.load$socialcard.Load_SC_Intrnl (
                        p_fn            => Clear_Name (rec_inc.fio_fn),
                        p_ln            => Clear_Name (rec_inc.fio_ln),
                        p_mn            => Clear_Name (rec_inc.fio_sn),
                        p_gender        => 'V',
                        p_nationality   => -1,
                        p_src_dt        =>
                            COALESCE (rec_inc.inc_pay_dt,
                                      rec_inc.lfd_create_dt),
                        p_birth_dt      =>
                            CASE
                                WHEN rec_inc.inc_is_resp = '1'
                                THEN
                                    TO_DATE (
                                        rec_inc.inc_resp_bd
                                            DEFAULT NULL ON CONVERSION ERROR,
                                        'dd.mm.yyyy')
                                WHEN     rec_inc.inc_is_resp = '0'
                                     AND rec_inc.inc_idcode <> '0000000000'
                                THEN
                                      TO_DATE ('31.12.1899', 'dd.mm.yyyy')
                                    + TO_NUMBER (
                                          SUBSTR (rec_inc.inc_idcode, 1, 5))
                                ELSE
                                    NULL
                            END,
                        -----------------------------------------------------------------------------------------------------------------
                        p_inn_num       =>
                            CASE
                                WHEN     REGEXP_LIKE (rec_inc.inc_idcode,
                                                      '^(\d){10}$')
                                     AND rec_inc.inc_idcode <> '0000000000'
                                THEN
                                    rec_inc.inc_idcode
                                ELSE
                                    NULL
                            END,
                        p_inn_ndt       =>
                            CASE
                                WHEN     REGEXP_LIKE (rec_inc.inc_idcode,
                                                      '^(\d){10}$')
                                     AND rec_inc.inc_idcode <> '0000000000'
                                THEN
                                    5
                                ELSE
                                    NULL
                            END,
                        -----------------------------------------------------------------------------------------------------------------
                        p_doc_ser       =>
                            CASE
                                WHEN REGEXP_LIKE (rec_inc.inc_pasp,
                                                  '^(\d){9}$')
                                THEN
                                    NULL
                                WHEN REGEXP_LIKE (rec_inc.inc_pasp,
                                                  '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                THEN
                                    SUBSTR (rec_inc.inc_pasp, 1, 2)
                                WHEN REGEXP_LIKE (
                                         rec_inc.inc_pasp,
                                         '^[І|I|1]{1}[-]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                THEN
                                    SUBSTR (rec_inc.inc_pasp, 1, 4)
                                WHEN REGEXP_LIKE (
                                         rec_inc.inc_pasp,
                                         '^[І|I|1]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                THEN
                                    SUBSTR (rec_inc.inc_pasp, 1, 3)
                                ELSE
                                    NULL
                            END,
                        p_doc_num       =>
                            CASE
                                WHEN REGEXP_LIKE (rec_inc.inc_pasp,
                                                  '^(\d){9}$')
                                THEN
                                    rec_inc.inc_pasp
                                WHEN REGEXP_LIKE (rec_inc.inc_pasp,
                                                  '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                THEN
                                    SUBSTR (rec_inc.inc_pasp, -6, 6)
                                WHEN REGEXP_LIKE (
                                         rec_inc.inc_pasp,
                                         '^[І|I|1]{1}[-]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                THEN
                                    SUBSTR (rec_inc.inc_pasp, -6, 6)
                                WHEN REGEXP_LIKE (
                                         rec_inc.inc_pasp,
                                         '^[І|I|1]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                THEN
                                    SUBSTR (rec_inc.inc_pasp, -6, 6)
                                ELSE
                                    rec_inc.inc_pasp
                            END,
                        p_doc_ndt       =>
                            CASE
                                WHEN REGEXP_LIKE (rec_inc.inc_pasp,
                                                  '^(\d){9}$')
                                THEN
                                    7                         -- новій паспорт
                                WHEN REGEXP_LIKE (rec_inc.inc_pasp,
                                                  '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                THEN
                                    6                    -- старій паспорт из архива
                                WHEN REGEXP_LIKE (
                                         rec_inc.inc_pasp,
                                         '^[І|I|1]{1}[-]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                THEN
                                    37                    -- свидетельство о рождении
                                WHEN REGEXP_LIKE (
                                         rec_inc.inc_pasp,
                                         '^[І|I|1]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                THEN
                                    37                    -- свидетельство о рождении
                                ELSE
                                    162
                            END,                             -- Інший документ
                        p_doc_unzr      => NULL,
                        p_doc_is        => NULL,
                        p_doc_bdt       => NULL,
                        p_doc_edt       => NULL,
                        p_src           => '721',
                        p_sc            => l_sc_id,
                        p_sc_unique     => l_sc_unique,
                        p_sc_scc        => l_sc_scc,
                        p_Mode          => 3           -- c_Mode_Search_Create
                                            );

                ---------------------------------------------------
                -- для корректно найдених персон створюємо рішення
                IF l_sc_id > 0
                THEN
                    -- IC #99587
                    -- Якщо співпадає ОСЗН, ОР, соцдопомога, місяць нарахування та сума, тоді видаляти рядок, який був, та заміняти на новий, щоб не було подвоєнь
                    UPDATE sc_income_link
                       SET sil_st = 'H'
                     WHERE     sil_raj = rec_inc.inc_raj
                           AND sil_sum = rec_inc.inc_sum
                           AND TRUNC (sil_accrual_dt, 'mm') =
                               TRUNC (rec_inc.inc_acc_dt, 'mm')
                           AND sil_inc = rec_inc.inc_code
                           AND sil_sc = l_sc_id;

                    INSERT INTO sc_income_link (sil_id,
                                                sil_sc,
                                                sil_scc,
                                                sil_raj,
                                                sil_num,
                                                sil_fio,
                                                sil_pdoc,
                                                sil_numident,
                                                sil_ind_code,
                                                sil_street_code,
                                                sil_building,
                                                sil_block,
                                                sil_apartment,
                                                sil_accrual_dt,
                                                sil_pay_dt,
                                                sil_sum,
                                                sil_inc,
                                                com_org,
                                                sil_st,
                                                sil_lfd,
                                                sil_lfdp)
                         VALUES (NULL,
                                 l_sc_id,
                                 l_sc_scc,
                                 rec_inc.inc_raj,
                                 rec_inc.inc_num,
                                 rec_inc.inc_fio,
                                 rec_inc.inc_pasp,
                                 rec_inc.inc_idcode,
                                 rec_inc.inc_indots,
                                 rec_inc.inc_adrul,
                                 rec_inc.inc_adrdom,
                                 rec_inc.inc_adrkorp,
                                 rec_inc.inc_adrkv,
                                 rec_inc.inc_acc_dt,
                                 rec_inc.inc_pay_dt,
                                 rec_inc.inc_sum,
                                 rec_inc.inc_code,
                                 rec_inc.inc_org,
                                 'A',
                                 rec_inc.lfd_id,
                                 rec_inc.lfdp_id)
                      RETURNING sil_id
                           INTO l_sil_id;

                    -- ADDDDD
                    -- Отмечаем вновь созданную или ранее созданную запись в socialcard|PERSONALCASE|PC_ACCOUNT
                    INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                   ldr_trg,
                                                   ldr_code)
                             VALUES (rec_inc.lfdp_id,
                                     l_sc_id,
                                     'USS_PERSON.SOCIALCARD');

                    INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                   ldr_trg,
                                                   ldr_code)
                             VALUES (rec_inc.lfdp_id,
                                     l_sil_id,
                                     'USS_PERSON.SC_INCOME_LINK');
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
                WHEN ex_error_sc_2
                THEN
                    SetIncLog (
                        rec_inc.lfdp_id,
                        -1,
                           rec_inc.inc_num
                        || '; Документи заявника не вказано чи неможливо визначити тип документа;');
                    ROLLBACK;
                WHEN ex_error_sc_1
                THEN
                    SetIncLog (
                        rec_inc.lfdp_id,
                        -1,
                           rec_inc.inc_num
                        || '; За документами заявника знайдено більше однієї персони в ЄСР;');
                    ROLLBACK;
                WHEN ex_error_sc_else
                THEN
                    SetIncLog (
                        rec_inc.lfdp_id,
                        -1,
                           rec_inc.inc_num
                        || '; Помилка визначення персони заявника;');
                    ROLLBACK;
                WHEN OTHERS
                THEN
                    SetIncLog (
                        rec_inc.lfdp_id,
                        -1,
                           rec_inc.inc_num
                        || '; Невизначена помилка;'
                        || SUBSTR (
                                  DBMS_UTILITY.format_error_stack
                               || DBMS_UTILITY.format_error_backtrace,
                               1,
                               3900));
                    ROLLBACK;
            END;
        END LOOP;

        IF l_prev_cnt > 0
        THEN
            DELETE FROM sc_income_link ddd
                  WHERE ddd.sil_lfd = l_prev_lfd;

            IF SQL%ROWCOUNT = l_prev_cnt
            THEN
                WriteLineToBlob (
                    p_line   =>
                           'Видалено за попереднім завантаженням '
                        || l_prev_cnt
                        || ' запис(ів).'
                        || cEndOfLine,
                    p_blob   => l_blob);
            ELSE
                WriteLineToBlob (
                    p_line   =>
                           'Видалено за попереднім завантаженням '
                        || SQL%ROWCOUNT
                        || ' запис(ів) з '
                        || l_prev_cnt
                        || ' раніше завантажених.'
                        || cEndOfLine,
                    p_blob   => l_blob);
            END IF;
        END IF;

        -- лог помилкових рядків
        FOR rec_err
            IN (SELECT u.ldr_code
                  FROM uss_exch.v_income_data  inc
                       JOIN uss_exch.v_ls2uss u
                           ON inc.lfdp_id = u.ldr_lfdp AND u.ldr_trg = -1
                 WHERE inc.lfd_id = p_lfd_id)
        LOOP
            WriteLineToBlob (p_line => rec_err.ldr_code, p_blob => l_blob);
        END LOOP;

        -- якщо блоб не порожный формуэмо протокол
        IF l_blob IS NOT NULL
        THEN
            uss_exch.load_file_prtcl.CheckLoadIncDataList (
                p_lfd_id     => p_lfd_id,
                p_nls_list   => l_blob);
        END IF;
    END;

    FUNCTION utf8_to_win1251 (i_str IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_str   VARCHAR2 (128);
    BEGIN
        IF NOT REGEXP_LIKE (ASCIISTR (CONVERT (i_str, 'cl8mswin1251')),
                            '\FFFD')
        THEN
            IF REGEXP_LIKE (CONVERT (UPPER (i_str), 'cl8mswin1251', 'utf8'),
                            '[А-ЯҐІЇЄ]')
            THEN
                l_str := CONVERT (i_str, 'cl8mswin1251', 'utf8');
            ELSE
                l_str := i_str;
            END IF;
        ELSE
            l_str := i_str;
        END IF;

        IF l_str LIKE '%?%'
        THEN
            l_str := i_str;
        END IF;

        RETURN l_str;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN i_str;
    END utf8_to_win1251;

    -- IC #99752
    -- Додати можливість в міграції завантаження даних по студентам
    PROCEDURE Load_Inc_St (p_lfd_id NUMBER)
    IS
        l_sil_id      NUMBER;
        l_sc_id       NUMBER;
        l_sc_scc      NUMBER;
        l_sc_unique   VARCHAR2 (100);

        l_blob        BLOB;
        l_file_name   VARCHAR2 (255);
        l_prev_cnt    NUMBER;
        l_prev_lfd    NUMBER;
    BEGIN
        DBMS_LOB.createtemporary (l_blob, TRUE);

        -- визначення завантажємого файлу
        SELECT d.lfd_file_name
          INTO l_file_name
          FROM uss_exch.load_file_data d
         WHERE d.lfd_id = p_lfd_id;

        -- визначаємо попередній файл завантаження, та кількість завантажених
        BEGIN
              SELECT d.lfd_id, COUNT (*)
                INTO l_prev_lfd, l_prev_cnt
                FROM sc_income_link t
                     JOIN uss_exch.load_file_data d ON d.lfd_id = t.sil_lfd
               WHERE     UPPER (d.lfd_file_name) = UPPER (l_file_name)
                     AND d.lfd_id <> p_lfd_id
            GROUP BY d.lfd_id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                l_prev_cnt := 0;
        END;

        --dbms_session.set_nls('NLS_DATE_FORMAT', '''dd.mm.yyyy''');
        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''. ''');

        FOR rec_inc
            IN (SELECT LPAD (LPAD (inc.unit, 4, '0'), 5, '5')
                           inc_base_org,
                       COALESCE (TO_CHAR (o.nddc_code_dest),
                                 LPAD (LPAD (inc.unit, 4, '0'), 5, '5'))
                           inc_org,
                       inc.lfd_id,
                       lfd_lfd,
                       lfd_records,
                       lfd_create_dt,
                       lfd_file_name,
                       lfd_user_id,
                       lfdp_id,
                       rn,
                       cardnumber,                            -- для протоколу
                       TO_NUMBER (unit)
                           inc_raj,
                       TO_NUMBER (cardnumber)
                           inc_num,
                       REPLACE (
                           TRANSLATE (UPPER (utf8_to_win1251 (surname)),
                                      'ETIOPAHKXCBM1',
                                      'ЕТІОРАНКХСВМІ'),
                           ' ',
                           '')
                           fio_ln,
                       REPLACE (
                           TRANSLATE (UPPER (utf8_to_win1251 (name)),
                                      'ETIOPAHKXCBM1',
                                      'ЕТІОРАНКХСВМІ'),
                           ' ',
                           '')
                           fio_fn,
                       REPLACE (
                           TRANSLATE (UPPER (utf8_to_win1251 (patronymic)),
                                      'ETIOPAHKXCBM1',
                                      'ЕТІОРАНКХСВМІ'),
                           ' ',
                           '')
                           fio_sn,
                       REPLACE (
                           REPLACE (
                               TRANSLATE (
                                   UPPER (utf8_to_win1251 (doc_seria)),
                                   'ETIOPAHKXCBM1',
                                   'ЕТІОРАНКХСВМІ'),
                               '-',
                               ''),
                           ' ',
                           '')
                           doc_seria,
                       doc_number,
                          REPLACE (
                              REPLACE (
                                  TRANSLATE (
                                      UPPER (utf8_to_win1251 (doc_seria)),
                                      'ETIOPAHKXCBM1',
                                      'ЕТІОРАНКХСВМІ'),
                                  '-',
                                  ''),
                              ' ',
                              '')
                       || REPLACE (doc_number, ' ', '')
                           inc_pasp,
                       CASE
                           WHEN     REGEXP_LIKE (itn, '^(\d){10}$')
                                AND itn <> '0000000000'
                           THEN
                               itn
                           ELSE
                               NULL
                       END
                           inc_idcode,
                       reg_zip
                           inc_indots_r,
                       TO_NUMBER (
                           reg_code_street DEFAULT NULL ON CONVERSION ERROR)
                           inc_adrul_r,
                       utf8_to_win1251 (reg_numbuild)
                           inc_adrdom_r,
                       utf8_to_win1251 (reg_blockbuild)
                           inc_adrkorp_r,
                       utf8_to_win1251 (reg_appartment)
                           inc_adrkv_r,
                       TO_NUMBER (
                           fact_code_street DEFAULT NULL ON CONVERSION ERROR)
                           inc_adrul_f,
                       utf8_to_win1251 (fact_numbuild)
                           inc_adrdom_f,
                       utf8_to_win1251 (fact_blockbuild)
                           inc_adrkorp_f,
                       utf8_to_win1251 (fact_appartment)
                           inc_adrkv_f,
                       TO_DATE (
                           LPAD (month_year, 4, '0')
                               DEFAULT NULL ON CONVERSION ERROR,
                           'mmyy')
                           inc_acc_dt,
                       TO_DATE (inc_pay_dt DEFAULT NULL ON CONVERSION ERROR,
                                'mmyy')
                           inc_pay_dt,
                       TO_NUMBER (sum_inc)
                           inc_sum,
                       TO_NUMBER (sum_ind DEFAULT NULL ON CONVERSION ERROR)
                           ind_sum,
                       100
                           inc_code -- uss_ndi.V_DDN_SIL_INC (100 - стипендія)
                  FROM uss_exch.v_income_st_data  inc
                       LEFT JOIN uss_ndi.v_ndi_decoding_config o
                           ON     o.nddc_code_src =
                                  LPAD (LPAD (inc.unit, 4, '0'), 5, '5')
                              AND o.nddc_tp = 'ORG_MIGR'
                       LEFT JOIN sc_income_link sil
                           ON sil.sil_lfdp = inc.lfdp_id
                 WHERE     inc.lfd_id = p_lfd_id
                       AND sil.sil_id IS NULL
                       AND TO_NUMBER (unit DEFAULT NULL ON CONVERSION ERROR)
                               IS NOT NULL
                       AND TO_NUMBER (
                               cardnumber DEFAULT NULL ON CONVERSION ERROR)
                               IS NOT NULL
                       AND TO_DATE (
                               LPAD (month_year, 4, '0')
                                   DEFAULT NULL ON CONVERSION ERROR,
                               'mmyy')
                               IS NOT NULL
                       AND TO_NUMBER (sum_inc DEFAULT 0 ON CONVERSION ERROR) >
                           0)
        LOOP
            BEGIN
                l_sc_id := NULL;
                l_sc_scc := NULL;
                l_sc_unique := NULL;

                l_sc_id :=
                    uss_person.load$socialcard.Load_SC_Intrnl (
                        p_fn            => Clear_Name (rec_inc.fio_fn),
                        p_ln            => Clear_Name (rec_inc.fio_ln),
                        p_mn            => Clear_Name (rec_inc.fio_sn),
                        p_gender        => 'V',
                        p_nationality   => -1,
                        p_src_dt        =>
                            COALESCE (rec_inc.inc_pay_dt,
                                      rec_inc.lfd_create_dt),
                        p_birth_dt      => NULL,
                        -----------------------------------------------------------------------------------------------------------------
                        p_inn_num       => rec_inc.inc_idcode,
                        p_inn_ndt       =>
                            CASE
                                WHEN rec_inc.inc_idcode IS NOT NULL THEN 5
                                ELSE NULL
                            END,
                        -----------------------------------------------------------------------------------------------------------------
                        p_doc_ser       =>
                            CASE
                                WHEN REGEXP_LIKE (rec_inc.inc_pasp,
                                                  '^(\d){9}$')
                                THEN
                                    NULL
                                WHEN REGEXP_LIKE (rec_inc.inc_pasp,
                                                  '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                THEN
                                    SUBSTR (rec_inc.inc_pasp, 1, 2)
                                WHEN REGEXP_LIKE (
                                         rec_inc.inc_pasp,
                                         '^[І|I|1]{1}[-]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                THEN
                                    SUBSTR (rec_inc.inc_pasp, 1, 4)
                                WHEN REGEXP_LIKE (
                                         rec_inc.inc_pasp,
                                         '^[І|I|1]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                THEN
                                    SUBSTR (rec_inc.inc_pasp, 1, 3)
                                ELSE
                                    NULL
                            END,
                        p_doc_num       =>
                            CASE
                                WHEN REGEXP_LIKE (rec_inc.inc_pasp,
                                                  '^(\d){9}$')
                                THEN
                                    rec_inc.inc_pasp
                                WHEN REGEXP_LIKE (rec_inc.inc_pasp,
                                                  '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                THEN
                                    SUBSTR (rec_inc.inc_pasp, -6, 6)
                                WHEN REGEXP_LIKE (
                                         rec_inc.inc_pasp,
                                         '^[І|I|1]{1}[-]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                THEN
                                    SUBSTR (rec_inc.inc_pasp, -6, 6)
                                WHEN REGEXP_LIKE (
                                         rec_inc.inc_pasp,
                                         '^[І|I|1]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                THEN
                                    SUBSTR (rec_inc.inc_pasp, -6, 6)
                                ELSE
                                    rec_inc.inc_pasp
                            END,
                        p_doc_ndt       =>
                            CASE
                                WHEN REGEXP_LIKE (rec_inc.inc_pasp,
                                                  '^(\d){9}$')
                                THEN
                                    7                         -- новій паспорт
                                WHEN REGEXP_LIKE (rec_inc.inc_pasp,
                                                  '^[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                THEN
                                    6                    -- старій паспорт из архива
                                WHEN REGEXP_LIKE (
                                         rec_inc.inc_pasp,
                                         '^[І|I|1]{1}[-]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                THEN
                                    37                    -- свидетельство о рождении
                                WHEN REGEXP_LIKE (
                                         rec_inc.inc_pasp,
                                         '^[І|I|1]{1}[А-ЯҐІЇЄ]{2}[0-9]{6}$')
                                THEN
                                    37                    -- свидетельство о рождении
                                -- при другом раскладе создаем как инший документ
                                ELSE
                                    162
                            END,
                        p_doc_unzr      => NULL,
                        p_doc_is        => NULL,
                        p_doc_bdt       => NULL,
                        p_doc_edt       => NULL,
                        p_src           => '729',
                        p_sc            => l_sc_id,
                        p_sc_unique     => l_sc_unique,
                        p_sc_scc        => l_sc_scc,
                        p_Mode          => 3           -- c_Mode_Search_Create
                                            );

                ---------------------------------------------------
                -- для корректно найдених персон створюємо рішення
                IF l_sc_id > 0
                THEN
                    -- IC #99587
                    -- Якщо співпадає ОСЗН, ОР, соцдопомога, місяць нарахування та сума, тоді видаляти рядок, який був, та заміняти на новий, щоб не було подвоєнь
                    UPDATE sc_income_link
                       SET sil_st = 'H'
                     WHERE     sil_raj = rec_inc.inc_raj
                           AND sil_sum = rec_inc.inc_sum
                           AND TRUNC (sil_accrual_dt, 'mm') =
                               TRUNC (rec_inc.inc_acc_dt, 'mm')
                           AND sil_inc = rec_inc.inc_code
                           AND sil_sc = l_sc_id;

                    INSERT INTO sc_income_link (sil_id,
                                                sil_sc,
                                                sil_scc,
                                                sil_raj,
                                                sil_num,
                                                sil_fio,
                                                sil_pdoc,
                                                sil_numident,
                                                sil_ind_code,
                                                -- IC #101668 При завантаженні стипендій студентів не завантажувати адреси, бо там багато сміття і нам воно не потрібно
                                                --sil_street_code,sil_building,sil_block,sil_apartment,
                                                sil_accrual_dt,
                                                sil_pay_dt,
                                                sil_sum,
                                                sil_inc,
                                                com_org,
                                                sil_st,
                                                sil_lfd,
                                                sil_lfdp)
                         VALUES (
                                    NULL,
                                    l_sc_id,
                                    l_sc_scc,
                                    rec_inc.inc_raj,
                                    rec_inc.inc_num,
                                       rec_inc.fio_ln
                                    || ' '
                                    || rec_inc.fio_fn
                                    || ' '
                                    || rec_inc.fio_sn,
                                    rec_inc.inc_pasp,
                                    rec_inc.inc_idcode,
                                    rec_inc.inc_indots_r,
                                    --rec_inc.inc_adrul_r,rec_inc.inc_adrdom_r,rec_inc.inc_adrkorp_r,rec_inc.inc_adrkv_r,
                                    rec_inc.inc_acc_dt,
                                    rec_inc.inc_pay_dt,
                                    rec_inc.inc_sum,
                                    rec_inc.inc_code,
                                    rec_inc.inc_org,
                                    'A',
                                    rec_inc.lfd_id,
                                    rec_inc.lfdp_id)
                      RETURNING sil_id
                           INTO l_sil_id;

                    -- ADDDDD
                    -- Отмечаем вновь созданную или ранее созданную запись в socialcard|PERSONALCASE|PC_ACCOUNT
                    INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                   ldr_trg,
                                                   ldr_code)
                             VALUES (rec_inc.lfdp_id,
                                     l_sc_id,
                                     'USS_PERSON.SOCIALCARD');

                    INSERT INTO uss_exch.v_ls2uss (ldr_lfdp,
                                                   ldr_trg,
                                                   ldr_code)
                             VALUES (rec_inc.lfdp_id,
                                     l_sil_id,
                                     'USS_PERSON.SC_INCOME_LINK');
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
                WHEN ex_error_sc_2
                THEN
                    SetIncLog (
                        rec_inc.lfdp_id,
                        -1,
                           rec_inc.cardnumber
                        || '; Документи заявника не вказано чи неможливо визначити тип документа;');
                    ROLLBACK;
                WHEN ex_error_sc_1
                THEN
                    SetIncLog (
                        rec_inc.lfdp_id,
                        -1,
                           rec_inc.cardnumber
                        || '; За документами заявника знайдено більше однієї персони в ЄСР;');
                    ROLLBACK;
                WHEN ex_error_sc_else
                THEN
                    SetIncLog (
                        rec_inc.lfdp_id,
                        -1,
                           rec_inc.cardnumber
                        || '; Помилка визначення персони заявника;');
                    ROLLBACK;
                WHEN OTHERS
                THEN
                    SetIncLog (
                        rec_inc.lfdp_id,
                        -1,
                           rec_inc.cardnumber
                        || '; Невизначена помилка;'
                        || SUBSTR (
                                  DBMS_UTILITY.format_error_stack
                               || DBMS_UTILITY.format_error_backtrace,
                               1,
                               3900));
                    ROLLBACK;
            END;
        END LOOP;

        IF l_prev_cnt > 0
        THEN
            DELETE FROM sc_income_link ddd
                  WHERE ddd.sil_lfd = l_prev_lfd;

            IF SQL%ROWCOUNT = l_prev_cnt
            THEN
                WriteLineToBlob (
                    p_line   =>
                           'Видалено за попереднім завантаженням '
                        || l_prev_cnt
                        || ' запис(ів).'
                        || cEndOfLine,
                    p_blob   => l_blob);
            ELSE
                WriteLineToBlob (
                    p_line   =>
                           'Видалено за попереднім завантаженням '
                        || SQL%ROWCOUNT
                        || ' запис(ів) з '
                        || l_prev_cnt
                        || ' раніше завантажених.'
                        || cEndOfLine,
                    p_blob   => l_blob);
            END IF;
        END IF;

        -- лог помилкових рядків
        FOR rec_err
            IN (SELECT u.ldr_code
                  FROM uss_exch.v_income_st_data  inc
                       JOIN uss_exch.v_ls2uss u
                           ON inc.lfdp_id = u.ldr_lfdp AND u.ldr_trg = -1
                 WHERE inc.lfd_id = p_lfd_id)
        LOOP
            WriteLineToBlob (p_line => rec_err.ldr_code, p_blob => l_blob);
        END LOOP;

        -- якщо блоб не порожный формуэмо протокол
        IF l_blob IS NOT NULL
        THEN
            uss_exch.load_file_prtcl.CheckLoadIncDataList (
                p_lfd_id     => p_lfd_id,
                p_nls_list   => l_blob);
        END IF;
    END Load_Inc_St;
BEGIN
    -- Initialization
    NULL;
END load$inc;
/