/* Formatted on 8/12/2025 5:54:20 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_EXCH.LOAD_FILE_PRTCL
IS
    -- Author  : JSHPAK
    -- Created : 13.01.2022 12:27:44
    -- Purpose :

    TYPE t_Stats IS TABLE OF NUMBER
        INDEX BY VARCHAR2 (300);

    -- Назва протоколу
    FUNCTION GetFileName (p_lfd_id IN load_file_data.lfd_id%TYPE)
        RETURN VARCHAR2;

    PROCEDURE WriteLineToBlob (p_line   IN            VARCHAR2,
                               p_blob   IN OUT NOCOPY BLOB,
                               p_buff   IN            BOOLEAN := FALSE);

    -- Призначення: Створення запису Протоколу;
    PROCEDURE InsertProtocol (
        p_lfp_id        IN OUT load_file_protocol.lfp_id%TYPE,
        p_lfp_lfp       IN     load_file_protocol.lfp_lfp%TYPE,
        p_lfp_lfd       IN     load_file_protocol.lfp_lfd%TYPE,
        p_lfp_tp        IN     load_file_protocol.lfp_tp%TYPE,
        p_lfp_name      IN     load_file_protocol.lfp_name%TYPE,
        p_lfp_comment   IN     load_file_protocol.lfp_comment%TYPE,
        p_content       IN     load_file_protocol.content%TYPE);

    PROCEDURE CheckLsData (p_lfd_id IN load_file_data.lfd_id%TYPE);

    PROCEDURE CheckDicData (p_lfd_id IN load_file_data.lfd_id%TYPE);

    PROCEDURE CheckLoadUssData (p_lfd_id     IN load_file_data.lfd_id%TYPE,
                                p_nls_list   IN BLOB DEFAULT NULL);

    PROCEDURE CheckLoadIncData (p_lfd_id IN load_file_data.lfd_id%TYPE);

    PROCEDURE CheckLoadIncStData (p_lfd_id IN load_file_data.lfd_id%TYPE);

    PROCEDURE CheckLoadIncDataList (p_lfd_id     IN load_file_data.lfd_id%TYPE,
                                    p_nls_list   IN BLOB DEFAULT NULL);

    PROCEDURE Stats_Init;

    PROCEDURE Stats_Inc (p_Measure IN VARCHAR2);

    FUNCTION Get_Stats_Text
        RETURN VARCHAR2;
END;
/


GRANT EXECUTE ON USS_EXCH.LOAD_FILE_PRTCL TO USS_ESR
/

GRANT EXECUTE ON USS_EXCH.LOAD_FILE_PRTCL TO USS_PERSON
/


/* Formatted on 8/12/2025 5:54:21 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_EXCH.LOAD_FILE_PRTCL
IS
    -- Application constants
    package_name   CONSTANT VARCHAR2 (32) := 'LOAD_FILE_PRTCL';
    cCSVsep        CONSTANT CHAR (1) := ';';
    --cXLSrows              constant pls_integer  := 65000; -- 65536

    -- Application variables
    lBuffer                 BINARY_INTEGER := 16383;

    vCharBuffer             VARCHAR2 (32767);
    cEndOfLine              CHAR (2) := CHR (13) || CHR (10);

    TYPE tp_record IS RECORD
    (
        name    VARCHAR2 (32000)
    );

    TYPE tp_records IS TABLE OF tp_record;

    g_Stats                 t_Stats;

    -- info:        Запис даних в таблицю ж
    -- parameters:  Зміст помилки; Назва підсистеми; Назва пакету/процедури (де виникла помилка), параметри 4,5,6,7 - не задействованы;
    -- add:         запись информации exception_log - автономными транзакциями.
    PROCEDURE ExceptionLog (p_prm1   IN VARCHAR2 DEFAULT NULL,
                            p_prm2   IN VARCHAR2 DEFAULT NULL,
                            p_prm3   IN VARCHAR2 DEFAULT NULL,
                            p_prm4   IN VARCHAR2 DEFAULT NULL,
                            p_prm5   IN VARCHAR2 DEFAULT NULL,
                            p_prm6   IN VARCHAR2 DEFAULT NULL,
                            p_prm7   IN VARCHAR2 DEFAULT NULL)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO exception_log (el_prm1,
                                   el_prm2,
                                   el_prm3,
                                   el_prm4,
                                   el_prm5,
                                   el_prm6,
                                   el_prm7,
                                   el_date)
             VALUES (p_prm1,
                     p_prm2,
                     p_prm3,
                     p_prm4,
                     p_prm5,
                     p_prm6,
                     p_prm7,
                     SYSDATE);

        COMMIT;
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

    -- Призначення: Створення запису Протоколу;
    -- Параметри:
    PROCEDURE InsertProtocol (
        p_lfp_id        IN OUT load_file_protocol.lfp_id%TYPE,
        p_lfp_lfp       IN     load_file_protocol.lfp_lfp%TYPE,
        p_lfp_lfd       IN     load_file_protocol.lfp_lfd%TYPE,
        p_lfp_tp        IN     load_file_protocol.lfp_tp%TYPE,
        p_lfp_name      IN     load_file_protocol.lfp_name%TYPE,
        p_lfp_comment   IN     load_file_protocol.lfp_comment%TYPE,
        p_content       IN     load_file_protocol.content%TYPE)
    IS
    BEGIN
        INSERT INTO load_file_protocol (lfp_id,
                                        lfp_lfp,
                                        lfp_lfd,
                                        lfp_tp,
                                        lfp_name,
                                        lfp_create_dt,
                                        lfp_user,
                                        lfp_comment,
                                        content)
             VALUES (p_lfp_id,
                     p_lfp_lfp,
                     p_lfp_lfd,
                     p_lfp_tp,
                     p_lfp_name,
                     SYSDATE,
                     NULL,
                     p_lfp_comment,
                     p_content)
          RETURNING lfp_id
               INTO p_lfp_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionLog (
                package_name,
                'InsertProtocol',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace,
                p_lfp_lfd);
    END;

    -- Призначення: ;
    -- Параметри:   Назва файлу протоколу контроля;
    FUNCTION GetFileName (p_lfd_id IN load_file_data.lfd_id%TYPE)
        RETURN VARCHAR2
    IS
        l_result   load_file_protocol.lfp_name%TYPE;
    BEGIN
        IF (p_lfd_id IS NOT NULL)
        THEN
            BEGIN
                -- "Назва файлу"
                SELECT    SUBSTR (lfd.lfd_file_name,
                                  1,
                                  LENGTH (lfd.lfd_file_name) - 4)
                       || '_'
                       || TO_CHAR (SYSDATE, 'ddmmyyyyhh24miss')
                  INTO l_result
                  FROM load_file_data lfd
                 WHERE lfd.lfd_id = p_lfd_id;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    l_result := NULL;
            END;
        END IF;

        RETURN l_result;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionLog (
                package_name,
                'GetFileName',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace,
                p_lfd_id);
    END;

    PROCEDURE CheckLsData (p_lfd_id IN load_file_data.lfd_id%TYPE)
    IS
        l_lfp_id     NUMBER;
        l_lfp_ch     NUMBER;

        l_blob       BLOB;
        l_filename   load_file_protocol.lfp_name%TYPE;
        l_msg        VARCHAR2 (4000);
        l_msg_full   VARCHAR2 (32000);

        --l_lfd_lfd number:= 1001431;
        l_header     VARCHAR2 (4000);
        l_sql        VARCHAR2 (32000);

        l_records    tp_records;
    BEGIN
        IF (p_lfd_id IS NOT NULL)
        THEN
            --
            DBMS_LOB.createtemporary (l_blob, TRUE);
            -- "Назва файлу"
            l_filename := GetFileName (p_lfd_id => p_lfd_id);
            -- Користувач

            WriteLineToBlob (
                p_line   =>
                       '"Протокол сформовано: '
                    || TO_CHAR (SYSDATE, 'dd.mm.yyyy hh24:mi:ss')
                    || '"'
                    || cCSVsep,
                p_blob   => l_blob);

            ---------------------------------------- блок на наявність всіх файлів  ---------------------------------
            SELECT LISTAGG (ls.lft_name, ', ')
                       WITHIN GROUP (ORDER BY ls.lft_id)
              INTO l_msg
              FROM load_file_data  lfd
                   JOIN load_file_version v
                       ON v.lfv_lft = lfd.lfd_lft AND v.lfv_st = 'A'
                   JOIN ls_file_type ls ON ls.lft_lfv = v.lfv_id
                   LEFT JOIN load_file_data ch
                       ON     ch.lfd_lfd = lfd.lfd_id
                          AND UPPER (ch.lfd_file_name) = UPPER (ls.lft_name)
             WHERE lfd.lfd_id = p_lfd_id AND ch.lfd_id IS NULL;

            IF l_msg IS NOT NULL
            THEN
                WriteLineToBlob (
                    p_line   =>
                           'Відсутні файл(и) для завантаження: '
                        || l_msg
                        || cCSVsep,
                    p_blob   => l_blob);
                WriteLineToBlob (
                    p_line   => 'Обробка завершена з помилкою' || cCSVsep,
                    p_blob   => l_blob);
            ELSE
                WriteLineToBlob (
                    p_line   =>
                           'Архів містить повний набір файлів для обробки'
                        || cCSVsep,
                    p_blob   => l_blob);
            END IF;

            ------------------------------------------блок на наявність всіх колонок в файлах-----------------------
            l_msg_full := '';

            FOR rec
                IN (SELECT lfd.lfd_id, lfd.lfd_file_name
                      FROM load_file_data  lfd
                           JOIN load_file_version v
                               ON v.lfv_lft = lfd.lfd_lft AND v.lfv_st = 'A'
                           JOIN ls_file_type ls
                               ON     ls.lft_lfv = v.lfv_id
                                  AND UPPER (lfd.lfd_file_name) =
                                      UPPER (ls.lft_name)
                     WHERE lfd.lfd_lfd = p_lfd_id)
            LOOP
                BEGIN
                      SELECT    t.lft_name
                             || ' ('
                             || LISTAGG (ls.ltf_fcode, ', ')
                                    WITHIN GROUP (ORDER BY ls.ltf_ord)
                             || ')'
                        INTO l_msg
                        FROM load_file_data lfd
                             JOIN ls_file_type t
                                 ON t.lft_name = lfd.lfd_file_name
                             JOIN ls_table_field ls ON ls.ltf_lft = t.lft_id
                       WHERE     lfd_id = rec.lfd_id
                             AND NOT EXISTS
                                     (SELECT 1
                                        FROM load_file_data_pars p
                                       WHERE     lfd.lfd_id = p.lfdp_lfd
                                             AND p.lfdp_rn = 1
                                             AND CASE
                                                     WHEN     ls.ltf_ord = 1
                                                          AND UPPER (p.f1) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 2
                                                          AND UPPER (p.f2) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 3
                                                          AND UPPER (p.f3) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 4
                                                          AND UPPER (p.f4) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 5
                                                          AND UPPER (p.f5) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 6
                                                          AND UPPER (p.f6) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 7
                                                          AND UPPER (p.f7) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 8
                                                          AND UPPER (p.f8) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 9
                                                          AND UPPER (p.f9) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 10
                                                          AND UPPER (p.f10) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 11
                                                          AND UPPER (p.f11) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 12
                                                          AND UPPER (p.f12) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 13
                                                          AND UPPER (p.f13) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 14
                                                          AND UPPER (p.f14) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 15
                                                          AND UPPER (p.f15) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 16
                                                          AND UPPER (p.f16) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 17
                                                          AND UPPER (p.f17) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 18
                                                          AND UPPER (p.f18) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 19
                                                          AND UPPER (p.f19) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 20
                                                          AND UPPER (p.f20) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 21
                                                          AND UPPER (p.f21) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 22
                                                          AND UPPER (p.f22) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 23
                                                          AND UPPER (p.f23) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 24
                                                          AND UPPER (p.f24) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 25
                                                          AND UPPER (p.f25) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 26
                                                          AND UPPER (p.f26) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 27
                                                          AND UPPER (p.f27) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 28
                                                          AND UPPER (p.f28) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 29
                                                          AND UPPER (p.f29) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 30
                                                          AND UPPER (p.f30) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 31
                                                          AND UPPER (p.f31) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 32
                                                          AND UPPER (p.f32) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 33
                                                          AND UPPER (p.f33) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 34
                                                          AND UPPER (p.f34) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 35
                                                          AND UPPER (p.f35) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 36
                                                          AND UPPER (p.f36) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 37
                                                          AND UPPER (p.f37) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 38
                                                          AND UPPER (p.f38) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 39
                                                          AND UPPER (p.f39) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 40
                                                          AND UPPER (p.f40) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 41
                                                          AND UPPER (p.f41) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 42
                                                          AND UPPER (p.f42) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 43
                                                          AND UPPER (p.f43) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 44
                                                          AND UPPER (p.f44) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 45
                                                          AND UPPER (p.f45) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 46
                                                          AND UPPER (p.f46) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 47
                                                          AND UPPER (p.f47) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 48
                                                          AND UPPER (p.f48) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 49
                                                          AND UPPER (p.f49) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     WHEN     ls.ltf_ord = 50
                                                          AND UPPER (p.f50) =
                                                              UPPER (
                                                                  ls.ltf_fcode)
                                                     THEN
                                                         1
                                                     ELSE
                                                         0
                                                 END =
                                                 1)
                    GROUP BY t.lft_name;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        NULL;
                END;

                IF l_msg IS NOT NULL
                THEN
                    l_msg_full :=
                           l_msg_full
                        || cEndOfLine
                        || 'для файла '
                        || rec.lfd_file_name
                        || ': '
                        || l_msg;
                END IF;
            END LOOP;

            IF l_msg_full IS NOT NULL
            THEN
                l_msg_full := 'Відсутні колонки' || l_msg_full;
                WriteLineToBlob (p_line   => l_msg_full || cCSVsep,
                                 p_blob   => l_blob);
            ELSE
                WriteLineToBlob (
                    p_line   =>
                           'Всі файли архіву містять повний набір колонок для обробки'
                        || cCSVsep,
                    p_blob   => l_blob);
            END IF;

            --------------------------------------------блок на контроль даних -------------------------------------------------------
            l_msg_full := '';

            FOR rec
                IN (  SELECT lfd.lfd_id,
                             ls.lft_id,
                             ls.lft_name,
                             e.lfe_code,
                             e.lfe_name,
                             COUNT (*)     AS cnt
                        FROM load_file_data lfd
                             JOIN load_file_version v
                                 ON v.lfv_lft = lfd.lfd_lft AND v.lfv_st = 'A'
                             JOIN ls_file_type ls
                                 ON     ls.lft_lfv = v.lfv_id
                                    AND UPPER (lfd.lfd_file_name) =
                                        UPPER (ls.lft_name)
                             JOIN load_file_data_pars p
                                 ON     p.lfdp_lfd = lfd.lfd_id
                                    AND p.lfdp_st IS NOT NULL
                             JOIN ls_file_error e
                                 ON     COALESCE (e.lfe_lft, ls.lft_id) =
                                        ls.lft_id
                                    AND p.lfdp_st LIKE '%' || e.lfe_code || '%'
                       WHERE lfd.lfd_lfd = p_lfd_id
                    GROUP BY lfd.lfd_id,
                             ls.lft_id,
                             ls.lft_name,
                             e.lfe_code,
                             e.lfe_name
                    ORDER BY 1)
            LOOP
                l_msg_full :=
                       l_msg_full
                    || cEndOfLine
                    || '  для файла '
                    || rec.lft_name
                    || CASE
                           WHEN rec.lfe_code = 'C' THEN ' інформація "'
                           ELSE ' помилка "'
                       END
                    || rec.lfe_name
                    || '" для '
                    || rec.cnt
                    || ' записів;';
            END LOOP;

            IF l_msg_full IS NOT NULL
            THEN
                l_msg_full := 'Помилки контроля даних:' || l_msg_full;
                WriteLineToBlob (p_line   => l_msg_full || cCSVsep,
                                 p_blob   => l_blob);
            END IF;

            -- завантаження архіву
            IF (DBMS_LOB.getlength (l_blob) > 0)
            THEN
                load_file_prtcl.insertprotocol (
                    p_lfp_id        => l_lfp_id,
                    p_lfp_lfp       => NULL,
                    p_lfp_lfd       => p_lfd_id,
                    p_lfp_tp        => NULL,
                    p_lfp_name      =>
                           l_filename
                        || '(загальний протокол контролю)'
                        || '.csv',
                    p_lfp_comment   => NULL,
                    p_content       => l_blob);
            END IF;

            BEGIN
                FOR rec
                    IN (SELECT t.lft_id,
                               'ls_' || t.lft_code     AS lft_code,
                               t.lft_code              AS lft_code_nm
                          FROM ls_file_type t
                         WHERE     t.lft_lfv = 10
                               AND t.lft_code NOT IN ('LS')
                               AND EXISTS
                                       (SELECT *
                                          FROM ls_table_field ff
                                         WHERE     ff.ltf_lft = t.lft_id
                                               AND ff.ltf_func IS NOT NULL)
                        UNION ALL
                        SELECT t.lft_id,
                               t.lft_code,
                               t.lft_code     AS lft_code_nm
                          FROM ls_file_type t
                         WHERE t.lft_lfv = 10 AND t.lft_code IN ('LS'))
                LOOP
                    DBMS_LOB.createtemporary (l_blob, TRUE);
                    l_records := NULL;

                    l_header := '"Номер рядка";';
                    l_sql := 'select rn||'';''||';

                    FOR ff IN (  SELECT *
                                   FROM ls_table_field f
                                  WHERE f.ltf_lft = rec.lft_id
                               ORDER BY 1)
                    LOOP
                        l_header := l_header || ff.ltf_fcode || ';';
                        l_sql := l_sql || ff.ltf_fcode || '||'';''||';
                    END LOOP;

                    l_sql :=
                           l_sql
                        || 'error_name from v_'
                        || rec.lft_code
                        || '_error t where t.lfd_lfd = '
                        || p_lfd_id
                        || ' order by t.rn';

                    --dbms_output.put_line(l_sql);
                    BEGIN
                        EXECUTE IMMEDIATE l_sql
                            BULK COLLECT INTO l_records;

                        FOR i IN l_records.FIRST .. l_records.LAST
                        LOOP
                            -- заполнение шапки
                            IF i = 1
                            THEN
                                WriteLineToBlob (
                                    p_line   =>
                                        l_header || 'Помилка;' || cCSVsep,
                                    p_blob   => l_blob);
                            END IF;

                            --dbms_output.put_line(l_records(i).name);
                            WriteLineToBlob (
                                p_line   => l_records (i).name || cCSVsep,
                                p_blob   => l_blob);
                        END LOOP;

                        IF (DBMS_LOB.getlength (l_blob) > 0)
                        THEN
                            --AddFileToZip(p_filename => l_filename, p_blob => l_blob);*/
                            l_lfp_ch := NULL;
                            load_file_prtcl.insertprotocol (
                                p_lfp_id        => l_lfp_ch,
                                p_lfp_lfp       => l_lfp_id,
                                p_lfp_lfd       => p_lfd_id,
                                p_lfp_tp        => NULL,
                                p_lfp_name      =>
                                       l_filename
                                    || '_'
                                    || rec.lft_code_nm
                                    || '(помилкові рядки).csv',
                                p_lfp_comment   => NULL,
                                p_content       => l_blob);
                        END IF;
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            NULL;
                    END;
                END LOOP;
            END;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionLog (
                package_name,
                'CheckLsData',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace,
                p_lfd_id);
    END;

    PROCEDURE CheckDicData (p_lfd_id IN load_file_data.lfd_id%TYPE)
    IS
        l_lfp_id     NUMBER;
        l_lfp_ch     NUMBER;

        l_blob       BLOB;
        l_filename   load_file_protocol.lfp_name%TYPE;
        l_msg_full   VARCHAR2 (32000);
        --l_lfd_lfd number:= 1001431;
        l_header     VARCHAR2 (4000);
        l_sql        VARCHAR2 (32000);

        l_records    tp_records;
    BEGIN
        IF (p_lfd_id IS NOT NULL)
        THEN
            --
            DBMS_LOB.createtemporary (l_blob, TRUE);
            -- "Назва файлу"
            l_filename := GetFileName (p_lfd_id => p_lfd_id);
            -- Користувач
            WriteLineToBlob (
                p_line   =>
                       '"Протокол сформовано: '
                    || TO_CHAR (SYSDATE, 'dd.mm.yyyy hh24:mi:ss')
                    || '"'
                    || cCSVsep,
                p_blob   => l_blob);
            --------------------------------------------блок на контроль даних -------------------------------------------------------
            l_msg_full := '';

            FOR rec
                IN (  SELECT lfd.lfd_id,
                             ls.lft_id,
                             COALESCE (ls.lft_name, lfd.lfd_file_name)
                                 AS lft_name,
                             COALESCE (e.lfe_code, '0')
                                 AS lfe_code,
                             COALESCE (e.lfe_name, 'Помилкові записи')
                                 lfe_name,
                             lfd.lfd_records,
                             COUNT (p.lfdp_id)
                                 AS cnt
                        FROM load_file_data lfd
                             JOIN load_file_version v
                                 ON v.lfv_lft = lfd.lfd_lft AND v.lfv_st = 'A'
                             JOIN load_file_data_pars p
                                 ON     p.lfdp_lfd = lfd.lfd_id
                                    AND p.lfdp_st IS NOT NULL
                             JOIN ls_file_type ls
                                 ON     ls.lft_lfv = v.lfv_id
                                    AND UPPER (lfd.lfd_file_name) LIKE
                                            '%' || UPPER (ls.lft_name)
                             LEFT JOIN ls_file_error e
                                 ON     COALESCE (e.lfe_lft, ls.lft_id) =
                                        ls.lft_id
                                    AND p.lfdp_st LIKE '%' || e.lfe_code || '%'
                       WHERE lfd.lfd_lfd = p_lfd_id
                    GROUP BY lfd.lfd_id,
                             ls.lft_id,
                             ls.lft_name,
                             lfd.lfd_file_name,
                             e.lfe_code,
                             e.lfe_name,
                             lfd.lfd_records
                    ORDER BY 1)
            LOOP
                l_msg_full :=
                       l_msg_full
                    || cEndOfLine
                    || '  для файла '
                    || rec.lft_name
                    || CASE
                           WHEN rec.lfe_code = 'C' THEN ' інформація "'
                           ELSE ' помилка "'
                       END
                    || rec.lfe_name
                    || '" для '
                    || rec.cnt
                    || ' записів з '
                    || rec.lfd_records
                    || ' записів файла ;';
            END LOOP;

            IF l_msg_full IS NOT NULL
            THEN
                l_msg_full := 'Помилки контроля даних:' || l_msg_full;
                WriteLineToBlob (p_line   => l_msg_full || cCSVsep,
                                 p_blob   => l_blob);
            END IF;

            -- завантаження архіву
            IF (DBMS_LOB.getlength (l_blob) > 0)
            THEN
                load_file_prtcl.insertprotocol (
                    p_lfp_id        => l_lfp_id,
                    p_lfp_lfp       => NULL,
                    p_lfp_lfd       => p_lfd_id,
                    p_lfp_tp        => NULL,
                    p_lfp_name      =>
                           l_filename
                        || '(загальний протокол контролю)'
                        || '.csv',
                    p_lfp_comment   => NULL,
                    p_content       => l_blob);
            END IF;

            BEGIN
                FOR rec
                    IN (SELECT t.lft_id,
                               'b_' || t.lft_code     AS lft_code,
                               t.lft_code             AS lft_code_nm
                          FROM ls_file_type t
                         WHERE     t.lft_lfv = 11
                               AND EXISTS
                                       (SELECT 1
                                          FROM ls_table_field f
                                         WHERE     f.ltf_lft = t.lft_id
                                               AND f.ltf_func IS NOT NULL))
                LOOP
                    DBMS_LOB.createtemporary (l_blob, TRUE);
                    l_records := NULL;

                    l_header := '"Номер рядка";';
                    l_sql := 'select rn||'';''||';

                    FOR ff
                        IN (  SELECT DISTINCT
                                     f.ltf_lft,
                                     UPPER (f.ltf_fcode)                          AS ltf_fcode,
                                     MIN (f.ltf_ord)
                                         OVER (
                                             PARTITION BY UPPER (f.ltf_fcode))    AS ltf_ord
                                FROM ls_table_field f
                               WHERE f.ltf_lft = rec.lft_id
                            ORDER BY 3)
                    LOOP
                        l_header := l_header || '"' || ff.ltf_fcode || '";';
                        l_sql :=
                               l_sql
                            || '''"''||'
                            || ff.ltf_fcode
                            || '||''";''||';
                    END LOOP;

                    l_sql :=
                           l_sql
                        || 'error_name from v_'
                        || rec.lft_code
                        || '_error t where t.lfd_lfd = '
                        || p_lfd_id
                        || ' order by t.rn';

                    --dbms_output.put_line(l_sql);
                    BEGIN
                        --dbms_output.put_line(l_sql);
                        EXECUTE IMMEDIATE l_sql
                            BULK COLLECT INTO l_records;

                        FOR i IN l_records.FIRST .. l_records.LAST
                        LOOP
                            -- заполнение шапки
                            IF i = 1
                            THEN
                                WriteLineToBlob (
                                    p_line   =>
                                        l_header || 'Помилка' || cCSVsep,
                                    p_blob   => l_blob);
                            END IF;

                            --dbms_output.put_line(l_records(i).name);
                            WriteLineToBlob (
                                p_line   => l_records (i).name || cCSVsep,
                                p_blob   => l_blob);
                        END LOOP;

                        IF (DBMS_LOB.getlength (l_blob) > 0)
                        THEN
                            --AddFileToZip(p_filename => l_filename, p_blob => l_blob);*/
                            l_lfp_ch := NULL;
                            load_file_prtcl.insertprotocol (
                                p_lfp_id        => l_lfp_ch,
                                p_lfp_lfp       => l_lfp_id,
                                p_lfp_lfd       => p_lfd_id,
                                p_lfp_tp        => NULL,
                                p_lfp_name      =>
                                       l_filename
                                    || '_'
                                    || rec.lft_code_nm
                                    || '(помилкові рядки).csv',
                                p_lfp_comment   => NULL,
                                p_content       => l_blob);
                        END IF;
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            NULL;
                    END;
                END LOOP;
            END;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionLog (
                package_name,
                'CheckLsData',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace,
                p_lfd_id);
    END;

    PROCEDURE CheckLoadUssData (p_lfd_id     IN load_file_data.lfd_id%TYPE,
                                p_nls_list   IN BLOB DEFAULT NULL)
    IS
        l_lfp_id     NUMBER;
        l_blob       BLOB;
        l_filename   load_file_protocol.lfp_name%TYPE;
        l_msg_full   VARCHAR2 (32000);

        l_work_cnt   NUMBER;
    BEGIN
        IF (p_lfd_id IS NOT NULL)
        THEN
            --
            DBMS_LOB.createtemporary (l_blob, TRUE);
            -- "Назва файлу"
            l_filename := GetFileName (p_lfd_id => p_lfd_id);
            -- Користувач

            WriteLineToBlob (
                p_line   =>
                       '"Протокол сформовано: '
                    || TO_CHAR (SYSDATE, 'dd.mm.yyyy hh24:mi:ss')
                    || '"'
                    || cCSVsep,
                p_blob   => l_blob);

            ---------------------------------------- блок на наявність всіх файлів  ---------------------------------
            --------------------------------------------блок на контроль даних -------------------------------------------------------
            l_msg_full := '';

            --
            SELECT COUNT (*)
              INTO l_work_cnt
              FROM v_ls_data d
             WHERE d.lfd_lfd = p_lfd_id;

            --
            FOR rec
                IN (  SELECT u.ldr_code,
                             lfd.lfd_file_name,
                             lfd.lfd_records - 1    AS trg_cnt,
                             COUNT (u.ldr_trg)      AS result_cnt,
                             CASE
                                 WHEN     UPPER (lfd.lfd_file_name) = 'BLS.CSV'
                                      AND u.ldr_code = 'USS_ESR.PC_ACCOUNT'
                                 THEN
                                     ' особових рахунків оброблено'
                                 WHEN     UPPER (lfd.lfd_file_name) = 'BLS.CSV'
                                      AND u.ldr_code = 'USS_ESR.APPEAL'
                                 THEN
                                     ' звернень для рішень'
                                 WHEN     UPPER (lfd.lfd_file_name) = 'BNP.CSV'
                                      AND u.ldr_code = 'USS_ESR.PC_DECISION'
                                 THEN
                                     ' рішень'
                                 WHEN     UPPER (lfd.lfd_file_name) = 'BNP.CSV'
                                      AND u.ldr_code = 'USS_ESR.PD_PAYMENT'
                                 THEN
                                     ' виплат рішень'
                                 WHEN     UPPER (lfd.lfd_file_name) = 'BNP.CSV'
                                      AND u.ldr_code = 'USS_ESR.PD_DETAIL'
                                 THEN
                                     ' записів деталізації виплат рішень'
                                 WHEN     UPPER (lfd.lfd_file_name) =
                                          'BIGD.CSV'
                                      AND u.ldr_code = 'USS_PERSON.SOCIALCARD'
                                 THEN
                                     ' утриманців для рішень'
                                 WHEN     UPPER (lfd.lfd_file_name) =
                                          'BNAC.CSV'
                                      AND u.ldr_code = 'USS_ESR.ACCRUAL'
                                 THEN
                                     ' нарахувань'
                                 WHEN     UPPER (lfd.lfd_file_name) =
                                          'BNACKFN.CSV'
                                      AND u.ldr_code = 'USS_ESR.AC_DETAIL'
                                 THEN
                                     ' записів деталізації нарахувань'
                                 WHEN     UPPER (lfd.lfd_file_name) =
                                          'BISPL.CSV'
                                      AND u.ldr_code = 'USS_ESR.APPEAL'
                                 THEN
                                     ' звернень для відрахувань'
                                 WHEN     UPPER (lfd.lfd_file_name) =
                                          'BISPL.CSV'
                                      AND u.ldr_code = 'USS_ESR.DEDUCTION'
                                 THEN
                                     ' відрахувань'
                                 WHEN     UPPER (lfd.lfd_file_name) =
                                          'BUDMEC.CSV'
                                      AND u.ldr_code = 'USS_ESR.DN_DETAIL'
                                 THEN
                                     ' записів деталізації відрахувань'
                                 ELSE
                                     NULL
                             END                    AS msg,
                             CASE
                                 WHEN     UPPER (lfd.lfd_file_name) = 'BLS.CSV'
                                      AND u.ldr_code = 'USS_ESR.PC_ACCOUNT'
                                 THEN
                                     1
                                 WHEN     UPPER (lfd.lfd_file_name) = 'BLS.CSV'
                                      AND u.ldr_code = 'USS_ESR.APPEAL'
                                 THEN
                                     1100
                                 WHEN     UPPER (lfd.lfd_file_name) = 'BNP.CSV'
                                      AND u.ldr_code = 'USS_ESR.PC_DECISION'
                                 THEN
                                     1200
                                 WHEN     UPPER (lfd.lfd_file_name) = 'BNP.CSV'
                                      AND u.ldr_code = 'USS_ESR.PD_PAYMENT'
                                 THEN
                                     1300
                                 WHEN     UPPER (lfd.lfd_file_name) = 'BNP.CSV'
                                      AND u.ldr_code = 'USS_ESR.PD_DETAIL'
                                 THEN
                                     1400
                                 WHEN     UPPER (lfd.lfd_file_name) =
                                          'BIGD.CSV'
                                      AND u.ldr_code = 'USS_PERSON.SOCIALCARD'
                                 THEN
                                     1500
                                 WHEN     UPPER (lfd.lfd_file_name) =
                                          'BNAC.CSV'
                                      AND u.ldr_code = 'USS_ESR.ACCRUAL'
                                 THEN
                                     2000
                                 WHEN     UPPER (lfd.lfd_file_name) =
                                          'BNACKFN.CSV'
                                      AND u.ldr_code = 'USS_ESR.AC_DETAIL'
                                 THEN
                                     2100
                                 WHEN     UPPER (lfd.lfd_file_name) =
                                          'BISPL.CSV'
                                      AND u.ldr_code = 'USS_ESR.APPEAL'
                                 THEN
                                     3000
                                 WHEN     UPPER (lfd.lfd_file_name) =
                                          'BISPL.CSV'
                                      AND u.ldr_code = 'USS_ESR.DEDUCTION'
                                 THEN
                                     3100
                                 WHEN     UPPER (lfd.lfd_file_name) =
                                          'BUDMEC.CSV'
                                      AND u.ldr_code = 'USS_ESR.DN_DETAIL'
                                 THEN
                                     3200
                                 ELSE
                                     NULL
                             END                    AS npp
                        FROM uss_exch.load_file_data lfd
                             JOIN uss_exch.load_file_data_pars lfdp
                                 ON lfdp.lfdp_lfd = lfd.lfd_id
                             JOIN uss_exch.v_ls2uss u
                                 ON u.ldr_lfdp = lfdp.lfdp_id
                       WHERE lfd.lfd_lfd = p_lfd_id
                    GROUP BY u.ldr_code, lfd.lfd_file_name, lfd.lfd_records
                    ORDER BY 6)
            LOOP
                IF rec.msg IS NOT NULL
                THEN
                    l_msg_full :=
                           l_msg_full
                        || cEndOfLine
                        || rec.result_cnt
                        || rec.msg
                        || CASE
                               WHEN rec.npp = '1'
                               THEN
                                      ' з '
                                   || rec.trg_cnt
                                   || ' записів завантажених у файлі, та з '
                                   || l_work_cnt
                                   || ' доступних для обробки після контроля.'
                                   || cEndOfLine
                                   || 'Створено:'
                               ELSE
                                   ''
                           END;
                END IF;
            END LOOP;

            IF l_msg_full IS NOT NULL
            THEN
                l_msg_full := 'Результат завантаження даних:' || l_msg_full;
                WriteLineToBlob (p_line => l_msg_full, p_blob => l_blob);
            END IF;

            IF DBMS_LOB.getlength (p_nls_list) > 0
            THEN
                DBMS_LOB.append (dest_lob => l_blob, src_lob => p_nls_list);
            END IF;

            IF (DBMS_LOB.getlength (l_blob) > 0)
            THEN
                load_file_prtcl.insertprotocol (
                    p_lfp_id        => l_lfp_id,
                    p_lfp_lfp       => NULL,
                    p_lfp_lfd       => p_lfd_id,
                    p_lfp_tp        => NULL,
                    p_lfp_name      =>
                           l_filename
                        || '(загальний протокол завантаження)'
                        || '.csv',
                    p_lfp_comment   => NULL,
                    p_content       => l_blob);
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionLog (
                package_name,
                'CheckLoadUssData',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace,
                p_lfd_id);
    END;

    PROCEDURE CheckLoadIncData (p_lfd_id IN load_file_data.lfd_id%TYPE)
    IS
        l_lfp_id     NUMBER;
        l_blob       BLOB;
        l_filename   load_file_protocol.lfp_name%TYPE;
        l_msg_full   VARCHAR2 (32000);
    BEGIN
        IF (p_lfd_id IS NOT NULL)
        THEN
            --
            DBMS_LOB.createtemporary (l_blob, TRUE);
            -- "Назва файлу"
            l_filename := GetFileName (p_lfd_id => p_lfd_id);
            -- Користувач

            WriteLineToBlob (
                p_line   =>
                       '"Протокол сформовано: '
                    || TO_CHAR (SYSDATE, 'dd.mm.yyyy hh24:mi:ss')
                    || '"'
                    || cCSVsep,
                p_blob   => l_blob);

            ---------------------------------------- блок на наявність всіх файлів  ---------------------------------
            --------------------------------------------блок на контроль даних -------------------------------------------------------
            l_msg_full := '';

            --
            FOR rec
                IN (  SELECT u.ldr_code,
                             lfd.lfd_file_name,
                             lfd.lfd_records        AS trg_cnt,
                             COUNT (u.ldr_trg)      AS result_cnt,
                             COUNT (inc.lfdp_id)    AS work_cnt,
                             CASE
                                 WHEN u.ldr_code = 'USS_PERSON.SC_INCOME_LINK'
                                 THEN
                                     ' записів доходів:'
                                 ELSE
                                     NULL
                             END                    AS msg,
                             CASE
                                 WHEN u.ldr_code = 'USS_PERSON.SC_INCOME_LINK'
                                 THEN
                                     1
                                 ELSE
                                     NULL
                             END                    AS npp
                        FROM uss_exch.load_file_data lfd
                             JOIN uss_exch.load_file_data_pars lfdp
                                 ON lfdp.lfdp_lfd = lfd.lfd_id
                             LEFT JOIN v_income_data inc
                                 ON     inc.lfd_id = lfd.lfd_id
                                    AND inc.lfdp_id = lfdp.lfdp_id
                             JOIN uss_exch.v_ls2uss u
                                 ON     u.ldr_lfdp = lfdp.lfdp_id
                                    AND u.ldr_code =
                                        'USS_PERSON.SC_INCOME_LINK'
                       WHERE lfd.lfd_lfd = p_lfd_id
                    GROUP BY u.ldr_code, lfd.lfd_file_name, lfd.lfd_records
                    ORDER BY 6)
            LOOP
                IF rec.msg IS NOT NULL
                THEN
                    l_msg_full :=
                           l_msg_full
                        || cEndOfLine
                        || '  файл '
                        || rec.lfd_file_name
                        || ' завантажено '
                        || rec.result_cnt
                        || rec.msg
                        || CASE
                               WHEN rec.npp = '1'
                               THEN
                                      ' з '
                                   || rec.trg_cnt
                                   || ' записів у файлі, та з '
                                   || rec.work_cnt
                                   || ' доступних для обробки після контроля.'
                               ELSE
                                   ''
                           END;
                END IF;
            END LOOP;

            FOR rec
                IN (  SELECT lfd.lfd_file_name, st.dic_sname AS st_name
                        FROM load_file_data lfd
                             JOIN uss_ndi.v_ddn_load_file_st st
                                 ON st.dic_code = lfd.lfd_st
                       WHERE     lfd.lfd_st IN ('R', 'B', 'W')
                             AND lfd.lfd_lfd = p_lfd_id
                    ORDER BY lfd_id)
            LOOP
                l_msg_full :=
                       l_msg_full
                    || cEndOfLine
                    || '  обробку файла '
                    || rec.lfd_file_name
                    || ' завершено з статусом "'
                    || rec.st_name
                    || '"';
            END LOOP;

            IF l_msg_full IS NOT NULL
            THEN
                l_msg_full := 'Результат завантаження даних:' || l_msg_full;
                WriteLineToBlob (p_line => l_msg_full, p_blob => l_blob);
            END IF;

            IF (DBMS_LOB.getlength (l_blob) > 0)
            THEN
                load_file_prtcl.insertprotocol (
                    p_lfp_id        => l_lfp_id,
                    p_lfp_lfp       => NULL,
                    p_lfp_lfd       => p_lfd_id,
                    p_lfp_tp        => NULL,
                    p_lfp_name      =>
                           l_filename
                        || '(загальний протокол завантаження)'
                        || '.csv',
                    p_lfp_comment   => NULL,
                    p_content       => l_blob);
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionLog (
                package_name,
                'CheckLoadUssData',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace,
                p_lfd_id);
    END;

    PROCEDURE CheckLoadIncStData (p_lfd_id IN load_file_data.lfd_id%TYPE)
    IS
        l_lfp_id     NUMBER;
        l_blob       BLOB;
        l_filename   load_file_protocol.lfp_name%TYPE;
        l_msg_full   VARCHAR2 (32000);
    BEGIN
        IF (p_lfd_id IS NOT NULL)
        THEN
            --
            DBMS_LOB.createtemporary (l_blob, TRUE);
            -- "Назва файлу"
            l_filename := GetFileName (p_lfd_id => p_lfd_id);
            -- Користувач

            WriteLineToBlob (
                p_line   =>
                       '"Протокол сформовано: '
                    || TO_CHAR (SYSDATE, 'dd.mm.yyyy hh24:mi:ss')
                    || '"'
                    || cCSVsep,
                p_blob   => l_blob);

            ---------------------------------------- блок на наявність всіх файлів  ---------------------------------
            --------------------------------------------блок на контроль даних -------------------------------------------------------
            l_msg_full := '';

            --
            FOR rec
                IN (  SELECT u.ldr_code,
                             lfd.lfd_file_name,
                             lfd.lfd_records        AS trg_cnt,
                             COUNT (u.ldr_trg)      AS result_cnt,
                             COUNT (inc.lfdp_id)    AS work_cnt,
                             CASE
                                 WHEN u.ldr_code = 'USS_PERSON.SC_INCOME_LINK'
                                 THEN
                                     ' записів доходів:'
                                 ELSE
                                     NULL
                             END                    AS msg,
                             CASE
                                 WHEN u.ldr_code = 'USS_PERSON.SC_INCOME_LINK'
                                 THEN
                                     1
                                 ELSE
                                     NULL
                             END                    AS npp
                        FROM uss_exch.load_file_data lfd
                             JOIN uss_exch.load_file_data_pars lfdp
                                 ON lfdp.lfdp_lfd = lfd.lfd_id
                             LEFT JOIN v_income_st_data inc
                                 ON     inc.lfd_id = lfd.lfd_id
                                    AND inc.lfdp_id = lfdp.lfdp_id
                             JOIN uss_exch.v_ls2uss u
                                 ON     u.ldr_lfdp = lfdp.lfdp_id
                                    AND u.ldr_code =
                                        'USS_PERSON.SC_INCOME_LINK'
                       WHERE lfd.lfd_id = p_lfd_id
                    GROUP BY u.ldr_code, lfd.lfd_file_name, lfd.lfd_records
                    ORDER BY 6)
            LOOP
                IF rec.msg IS NOT NULL
                THEN
                    l_msg_full :=
                           l_msg_full
                        || cEndOfLine
                        || '  файл '
                        || rec.lfd_file_name
                        || ' завантажено '
                        || rec.result_cnt
                        || rec.msg
                        || CASE
                               WHEN rec.npp = '1'
                               THEN
                                      ' з '
                                   || rec.trg_cnt
                                   || ' записів у файлі, та з '
                                   || rec.work_cnt
                                   || ' доступних для обробки після контроля.'
                               ELSE
                                   ''
                           END;
                END IF;
            END LOOP;

            FOR rec
                IN (  SELECT lfd.lfd_file_name, st.dic_sname AS st_name
                        FROM load_file_data lfd
                             JOIN uss_ndi.v_ddn_load_file_st st
                                 ON st.dic_code = lfd.lfd_st
                       WHERE     lfd.lfd_st IN ('R', 'B', 'W')
                             AND lfd.lfd_id = p_lfd_id
                    ORDER BY lfd_id)
            LOOP
                l_msg_full :=
                       l_msg_full
                    || cEndOfLine
                    || '  обробку файла '
                    || rec.lfd_file_name
                    || ' завершено з статусом "'
                    || rec.st_name
                    || '"';
            END LOOP;

            IF l_msg_full IS NOT NULL
            THEN
                l_msg_full := 'Результат завантаження даних:' || l_msg_full;
                WriteLineToBlob (p_line => l_msg_full, p_blob => l_blob);
            END IF;

            IF (DBMS_LOB.getlength (l_blob) > 0)
            THEN
                load_file_prtcl.insertprotocol (
                    p_lfp_id        => l_lfp_id,
                    p_lfp_lfp       => NULL,
                    p_lfp_lfd       => p_lfd_id,
                    p_lfp_tp        => NULL,
                    p_lfp_name      =>
                           l_filename
                        || '(загальний протокол завантаження)'
                        || '.csv',
                    p_lfp_comment   => NULL,
                    p_content       => l_blob);
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionLog (
                package_name,
                'CheckLoadIncStData',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace,
                p_lfd_id);
    END CheckLoadIncStData;

    PROCEDURE CheckLoadIncDataList (p_lfd_id     IN load_file_data.lfd_id%TYPE,
                                    p_nls_list   IN BLOB DEFAULT NULL)
    IS
        l_lfd_lfd    NUMBER;
        l_lfp_id     NUMBER;
        l_filename   load_file_protocol.lfp_name%TYPE;
        l_work_cnt   NUMBER;
    BEGIN
        l_filename := GetFileName (p_lfd_id => p_lfd_id);

        SELECT COALESCE (d.lfd_lfd, lfd_id)
          INTO l_lfd_lfd
          FROM load_file_data d
         WHERE d.lfd_id = p_lfd_id;

        IF (DBMS_LOB.getlength (p_nls_list) > 0)
        THEN
            load_file_prtcl.insertprotocol (
                p_lfp_id        => l_lfp_id,
                p_lfp_lfp       => NULL,
                p_lfp_lfd       => l_lfd_lfd,
                p_lfp_tp        => NULL,
                p_lfp_name      => l_filename || '(додаткова інформація).csv',
                p_lfp_comment   => NULL,
                p_content       => p_nls_list);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionLog (
                package_name,
                'CheckLoadUssData',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace,
                p_lfd_id);
    END;


    PROCEDURE Stats_Init
    IS
    BEGIN
        g_Stats.Delete;
    END;

    PROCEDURE Stats_Inc (p_Measure IN VARCHAR2)
    IS
    BEGIN
        g_Stats (p_Measure) :=
            CASE
                WHEN g_Stats.EXISTS (p_Measure) THEN g_Stats (p_Measure) + 1
                ELSE 1
            END;
    END;

    FUNCTION Get_Stats_Text
        RETURN VARCHAR2
    IS
        l_Idx      VARCHAR2 (300);
        l_Result   VARCHAR2 (4000) := '';
    BEGIN
        l_Idx := g_Stats.FIRST;

        WHILE (l_Idx IS NOT NULL)
        LOOP
            l_Result :=
                l_Result || l_Idx || ': ' || g_Stats (l_Idx) || cEndOfLine;
            l_Idx := g_Stats.NEXT (l_Idx);
        END LOOP;

        RETURN l_Result;
    END;
BEGIN
    -- Initialization
    NULL;
END;
/