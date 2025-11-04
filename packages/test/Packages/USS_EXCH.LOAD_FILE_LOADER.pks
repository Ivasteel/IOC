/* Formatted on 8/12/2025 5:54:20 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_EXCH.LOAD_FILE_LOADER
IS
    -- Author  : ShY
    -- Created : sysdate (3 сентября 2018)
    -- Purpose : Завантаження текстових файлів, парсінг

    -- info: процедура установки текущего работающего задания
    -- parameters: идентификатор файла и идентификатор текущего задания
    --function GetJobState(
    --  p_jb   load_file_data_jobs.lfdj_jb%type
    --) return load_file_data_jobs.lfdj_jb_st%type;

    -- Призначення: Запис даних в таблицю ikis_prson.load_file_data_log
    -- Параметри:   Идентификатор файла, текст сообщения, тип лога, статус файла
    -- Додатково:   запись информации load_file_data_log - автономными транзакциями.
    PROCEDURE InsertLog (
        p_lfdl_lfd       load_file_data_log.lfdl_lfd%TYPE,
        p_lfdl_text      load_file_data_log.lfdl_text%TYPE,
        p_lfdl_tp        load_file_data_log.lfdl_tp%TYPE,
        p_lfdl_file_st   load_file_data_log.lfdl_file_st%TYPE DEFAULT NULL);

    -- Призначення: Функція конвертації розріму файла у строку
    -- Параметри:   Розрім файла;
    FUNCTION FileSizeToChar (p_size IN NUMBER)
        RETURN VARCHAR2;

    -- info: Функція конвертації строки
    FUNCTION ConvertF (p_rn IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Convertblobtoclob (
        p_content   IN BLOB,
        p_charset   IN INTEGER DEFAULT DBMS_LOB.default_csid)
        RETURN CLOB;

    FUNCTION ConvertClobToBlob (p_Clob IN CLOB)
        RETURN BLOB;

    -- Призначення: Перевірка статусу файлу ;
    -- Параметри:   ІД файлу ;
    FUNCTION GetFileState (p_lfd_id   IN load_file_data.lfd_id%TYPE,
                           p_lfd_st   IN load_file_data.lfd_st%TYPE)
        RETURN BOOLEAN;

    -- Призначення: Зміна статусу для файлу ;
    -- Параметри:   ІД файлу ;
    -- 'A' -- Актуальный
    -- 'J' -- Створена задача на парсинг
    -- 'P' -- Парсинг --
    -- 'R' -- Ошибка (Error) --
    -- 'E' -- Пустой (Empty) --
    -- 'C' -- Завершение парсинга (Complete) --
    -- 'Q' -- Початок контроля(Query)
    -- 'V' -- Контроль (verification)
    -- 'L' -- Загрузка (Load) --
    -- 'F' -- Полная обработка Finish --
    -- 'D' -- Удален
    -- 'I' -- Повторение (iteration)
    -- 'O' -- Опционально (информационная запись)
    PROCEDURE SetFileState (p_lfd_id   IN load_file_data.lfd_id%TYPE,
                            p_lfd_st   IN load_file_data.lfd_st%TYPE);

    -- Призначення: Запис файлу для парсинга;
    PROCEDURE InsertFileInfo (
        p_lfd_id          IN OUT load_file_data.lfd_id%TYPE,
        p_lfd_lfd         IN     load_file_data.lfd_lfd%TYPE,
        p_lfd_file_name   IN     load_file_data.lfd_file_name%TYPE,
        p_lfd_lft         IN     load_file_data.lfd_lft%TYPE,
        p_lfd_mime_type   IN     load_file_data.lfd_mime_type%TYPE,
        p_lfd_filesize    IN     load_file_data.lfd_filesize%TYPE,
        p_lfd_create_dt   IN     load_file_data.lfd_create_dt%TYPE,
        p_lfd_user_id     IN     load_file_data.lfd_user_id%TYPE,
        p_lfd_src         IN     load_file_data.lfd_src%TYPE);

    PROCEDURE InsertFile (
        p_lfd_id          IN OUT load_file_data.lfd_id%TYPE,
        p_lfd_lfd         IN     load_file_data.lfd_lfd%TYPE,
        p_lfd_file_name   IN     load_file_data.lfd_file_name%TYPE,
        p_lfd_lft         IN     load_file_data.lfd_lft%TYPE,
        p_lfd_mime_type   IN     load_file_data.lfd_mime_type%TYPE,
        p_lfd_filesize    IN     load_file_data.lfd_filesize%TYPE,
        p_lfd_create_dt   IN     load_file_data.lfd_create_dt%TYPE,
        p_lfd_user_id     IN     load_file_data.lfd_user_id%TYPE,
        p_lfd_src         IN     load_file_data.lfd_src%TYPE);

    -- Призначення: запис вмісту файла для парсинга;
    PROCEDURE InsertData (
        p_lfdc_lfd       IN load_file_data_content.lfdc_lfd%TYPE,
        p_lfdc_content   IN load_file_data_content.content%TYPE);

    -- Призначення: Видалення запису (логічне);
    -- Параметри:   ІД файлу ;
    PROCEDURE DeleteFile (p_lfd_id IN load_file_data.lfd_id%TYPE);

    -- Призначення: Створення завдання для обробки файлу ;
    -- Параметри:   ІД завдання (джоба); ІД файлу ;
    PROCEDURE RegisterProcess (p_jb          OUT NUMBER,
                               p_lfd_id   IN     load_file_data.lfd_id%TYPE,
                               p_isweb    IN     NUMBER);

    PROCEDURE StartProcess (p_lfd_id IN load_file_data.lfd_id%TYPE);

    -- Info:
    -- Params:
    PROCEDURE RegisterProcessControl (
        p_jb          OUT NUMBER,
        p_lfd_id   IN     load_file_data.lfd_id%TYPE,
        p_isweb    IN     NUMBER);

    PROCEDURE StartProcessControl (p_lfd_id IN load_file_data.lfd_id%TYPE);

    -- Info:
    -- Params:
    PROCEDURE RegisterProcessLoad (
        p_jb          OUT NUMBER,
        p_lfd_id   IN     load_file_data.lfd_id%TYPE,
        p_isweb    IN     NUMBER);

    PROCEDURE StartProcessLoad (p_lfd_id IN load_file_data.lfd_id%TYPE);

    -- Призначення: Вивантаження через web-додаток файлу;
    -- Параметри:   ІД файлу ;
    PROCEDURE DownloadContent (p_lfd_id IN load_file_data.lfd_id%TYPE);

    -- Purpose : Обробка задач по подсистеме загрузки файлов
    PROCEDURE DnetStart (plfd NUMBER DEFAULT NULL);

    -- технологычна
    PROCEDURE DeleteLfd (p_lfd NUMBER);

    -- info:   створення нової секції в таблиці load_file_data_pars
    -- params: p_table_name - назва таблиці
    --         p_part_val - ключ секціювання по списку (partition)
    --         p_subpart_val - ключ секціювання по списку (subpartition)
    -- note:
    PROCEDURE Add_Table_Section (p_table_name    IN VARCHAR2,
                                 p_part_val         VARCHAR2,
                                 p_subpart_val      VARCHAR2);
END;
/


GRANT EXECUTE ON USS_EXCH.LOAD_FILE_LOADER TO SHOST
/

GRANT EXECUTE ON USS_EXCH.LOAD_FILE_LOADER TO USS_ESR
/

GRANT EXECUTE ON USS_EXCH.LOAD_FILE_LOADER TO USS_PERSON
/

GRANT EXECUTE ON USS_EXCH.LOAD_FILE_LOADER TO USS_RPT
/


/* Formatted on 8/12/2025 5:54:21 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_EXCH.LOAD_FILE_LOADER
IS
    -- Application constants
    package_name   CONSTANT VARCHAR2 (32) := 'LOAD_FILE_LOADER';
    -- Application variables
    p_lfdl_user_id          load_file_data_log.lfdl_user_id%TYPE;

    -------------------------------------------------------------------
    ---------------  **********  BODY ********** ----------------------
    -------------------------------------------------------------------
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

    -- info:        Запис даних в таблицю ikis_prson.load_file_data_log
    -- parameters:  Идентификатор файла, текст сообщения, тип лога, статус файла
    -- add:         запись информации load_file_data_log - автономными транзакциями.
    PROCEDURE DeleteLog (p_lfdl_lfd load_file_data_log.lfdl_lfd%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        DELETE FROM load_file_data_log l
              WHERE     l.lfdl_lfd = p_lfdl_lfd
                    AND l.lfdl_tp = 'P'
                    AND l.lfdl_text = 'Файл в черзі на обробку';

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionLog (
                package_name,
                'DeleteLog',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- info:        Запис даних в таблицю ikis_prson.load_file_data_log
    -- parameters:  Идентификатор файла, текст сообщения, тип лога, статус файла
    -- add:         запись информации load_file_data_log - автономными транзакциями.
    PROCEDURE InsertLog (
        p_lfdl_lfd       load_file_data_log.lfdl_lfd%TYPE,
        p_lfdl_text      load_file_data_log.lfdl_text%TYPE,
        p_lfdl_tp        load_file_data_log.lfdl_tp%TYPE,
        p_lfdl_file_st   load_file_data_log.lfdl_file_st%TYPE DEFAULT NULL)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO load_file_data_log (lfdl_lfd,
                                        lfdl_text,
                                        lfdl_user_id,
                                        lfdl_tp,
                                        lfdl_file_st)
             VALUES (p_lfdl_lfd,
                     SUBSTR (p_lfdl_text, 1, 4000),
                     p_lfdl_user_id,
                     p_lfdl_tp,
                     p_lfdl_file_st);

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionLog (
                package_name,
                'InsertLog',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- info: Функція конвертації строки
    -- Параметри:   строка;
    FUNCTION ConvertF (p_rn IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_result   load_file_data_pars.f1%TYPE;
    BEGIN
        l_result :=
            TRANSLATE (
                CONVERT (p_rn, 'CL8MSWIN1251', 'RU8PC866'),
                   CHR (161)
                || CHR (175)
                || CHR (63)
                || CHR (176)
                || CHR (162)
                || CHR (191)
                || CHR (183),
                   CHR (178)
                || CHR (170)
                || CHR (146)
                || CHR (175)
                || CHR (179)
                || CHR (186)
                || CHR (191));

        RETURN l_result;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionLog (
                package_name,
                'ConvertF',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- info:       процедура установки текущего работающего задания
    -- parameters: идентификатор файла и идентификатор текущего задания
    -- add:        модернизация атрибутов сущности load_file_data - только автономными транзакциями.
    PROCEDURE SetCurrentJob (p_lfd   load_file_data.lfd_id%TYPE,
                             p_jb    load_file_data_jobs.lfdj_jb%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE load_file_data lfd
           SET lfd.lfd_jb = p_jb,
               lfd.lfd_user_id = COALESCE (p_lfdl_user_id, lfd.lfd_user_id)
         WHERE lfd.lfd_id = p_lfd;

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionLog (
                package_name,
                'SetCurrentJob',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- info:       процедура проставления числа строк файла на этапе парсинга
    -- parameters: идентификатор файла + колличество строк файла
    -- add:        модернизация атрибутов сущности load_file_data - только автономными транзакциями.
    PROCEDURE SetFileRecords (p_lfd   load_file_data.lfd_id%TYPE,
                              p_rc    load_file_data.lfd_records%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE load_file_data lfd
           SET lfd.lfd_records = p_rc
         WHERE lfd.lfd_id = p_lfd;

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionLog (
                package_name,
                'SetFileRecords',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- info: Функція конвертації розріму файла у строку
    -- Параметри:   Розрім файла;
    FUNCTION FileSizeToChar (p_size IN NUMBER)
        RETURN VARCHAR2
    IS
        l_result   VARCHAR2 (100);
    BEGIN
        l_result := '';

        IF (p_size > 1048576)
        THEN
            l_result := TO_CHAR (p_size / 1048576, '9999999990.90') || ' Мб';
        ELSIF (p_size > 1024)
        THEN
            l_result := TO_CHAR (p_size / 1024, '9999999990.90') || ' Кб';
        ELSE
            l_result := TO_CHAR (p_size) || ' байт';
        END IF;

        RETURN l_result;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionLog (
                package_name,
                'FileSizeToChar',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- Призначення: Конвертація BLOB => CLOB;
    -- Параметри:   BLOB;
    FUNCTION Convertblobtoclob (
        p_content   IN BLOB,
        p_charset   IN INTEGER DEFAULT DBMS_LOB.default_csid)
        RETURN CLOB
    IS
        l_dest_offset    INTEGER;
        l_src_offset     INTEGER;
        l_lang_context   INTEGER;
        l_warning        INTEGER;

        l_result         CLOB;
    BEGIN
        l_result := NULL;

        IF (p_content IS NOT NULL)
        THEN
            l_dest_offset := 1;
            l_src_offset := 1;
            l_lang_context := DBMS_LOB.default_lang_ctx;

            DBMS_LOB.createtemporary (lob_loc => l_result, cache => FALSE);

            DBMS_LOB.convertToClob (dest_lob       => l_result,
                                    src_blob       => p_content,
                                    amount         => DBMS_LOB.lobmaxsize,
                                    dest_offset    => l_dest_offset,
                                    src_offset     => l_src_offset,
                                    blob_csid      => p_charset,
                                    lang_context   => l_lang_context,
                                    warning        => l_warning);
        END IF;

        RETURN l_result;
    END;

    FUNCTION ConvertClobToBlob (p_Clob IN CLOB)
        RETURN BLOB
    IS
        v_Blob          BLOB;
        v_Offset        NUMBER DEFAULT 1;
        v_Amount        NUMBER DEFAULT 4096;
        v_Offsetwrite   NUMBER DEFAULT 1;
        v_Amountwrite   NUMBER;
        v_Buffer        VARCHAR2 (4096 CHAR);
    BEGIN
        DBMS_LOB.Createtemporary (v_Blob, TRUE);

        BEGIN
            LOOP
                DBMS_LOB.Read (Lob_Loc   => p_Clob,
                               Amount    => v_Amount,
                               Offset    => v_Offset,
                               Buffer    => v_Buffer);

                v_Amountwrite :=
                    UTL_RAW.LENGTH (r => UTL_RAW.Cast_To_Raw (c => v_Buffer));

                DBMS_LOB.Write (Lob_Loc   => v_Blob,
                                Amount    => v_Amountwrite,
                                Offset    => v_Offsetwrite,
                                Buffer    => UTL_RAW.Cast_To_Raw (v_Buffer));

                v_Offsetwrite := v_Offsetwrite + v_Amountwrite;

                v_Offset := v_Offset + v_Amount;
                v_Amount := 4096;
            END LOOP;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;

        RETURN v_Blob;
    END;

    FUNCTION getstatename (p_code uss_ndi.v_ddn_load_file_st.dic_code%TYPE)
        RETURN uss_ndi.v_ddn_load_file_st.dic_name%TYPE
    IS
        l_name   uss_ndi.v_ddn_load_file_st.dic_name%TYPE;
    BEGIN
        SELECT dic_name
          INTO l_name
          FROM uss_ndi.v_ddn_load_file_st
         WHERE dic_code = p_code;

        RETURN l_name;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN '-';
    END;

    -- Призначення: Зміна статусу для файлу ;
    -- Параметри:   ІД файлу ;
    -- 'A' -- Актуальный
    -- 'J' -- Створена задача на парсинг
    -- 'P' -- Парсинг --
    -- 'R' -- Ошибка (Error) --
    -- 'E' -- Пустой (Empty) --
    -- 'C' -- Завершение парсинга (Complete) --
    -- 'Q' -- Початок контроля(Query)
    -- 'V' -- Контроль (verification)
    -- 'L' -- Загрузка (Load) --
    -- 'F' -- Полная обработка Finish --
    -- 'D' -- Удален
    -- 'I' -- Повторение (iteration)
    -- 'O' -- Опционально (информационная запись)
    PROCEDURE SetFileState (p_lfd_id   IN load_file_data.lfd_id%TYPE,
                            p_lfd_st   IN load_file_data.lfd_st%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_file_name   load_file_data.lfd_file_name%TYPE;
    BEGIN
        IF (p_lfd_id IS NOT NULL)
        THEN
               UPDATE load_file_data lfd
                  SET lfd.lfd_st = p_lfd_st
                WHERE     lfd.lfd_id = p_lfd_id
                      AND lfd.lfd_st NOT IN ('B', 'W')
                      AND lfd.lfd_st <> p_lfd_st
            RETURNING lfd.lfd_file_name
                 INTO l_file_name;

            IF SQL%ROWCOUNT > 0
            THEN
                InsertLog (
                    p_lfd_id,
                       'Стан файлу "'
                    || l_file_name
                    || '" встановлено в "'
                    || getstatename (p_lfd_st)
                    || '"',
                    'P',
                    p_lfd_st);
            END IF;

            COMMIT;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionLog (
                package_name,
                'SetFileState',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- Призначення: Перевірка статусу файлу ;
    -- Параметри:   ІД файлу ;
    FUNCTION GetFileState (p_lfd_id   IN load_file_data.lfd_id%TYPE,
                           p_lfd_st   IN load_file_data.lfd_st%TYPE)
        RETURN BOOLEAN
    IS
        l_result   PLS_INTEGER := 0;
    BEGIN
        IF (p_lfd_id IS NOT NULL)
        THEN
            SELECT COUNT (0)
              INTO l_result
              FROM load_file_data lfd
             WHERE lfd.lfd_id = p_lfd_id AND lfd.lfd_st = p_lfd_st;
        END IF;

        RETURN (l_result > 0);
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionLog (
                package_name,
                'GetFileState',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- Призначення: Определение типа парсинга по разделителю или с фиксированной длиной;
    -- Параметри:   ІД файлу ;
    FUNCTION GetFileParsType (p_lfd_id IN load_file_data.lfd_id%TYPE)
        RETURN load_file_pars_type.lfpt_code%TYPE
    IS
        l_result   load_file_pars_type.lfpt_code%TYPE;
    BEGIN
        IF (p_lfd_id IS NOT NULL)
        THEN
            SELECT lfpt.lfpt_code
              INTO l_result
              FROM load_file_data  lfd
                   JOIN load_file_version lfv
                       ON lfv.lfv_lft = lfd.lfd_lft AND lfv.lfv_st = 'A'
                   JOIN load_file_pars_type lfpt
                       ON lfpt.lfpt_id = lfv.lfv_lfpt AND lfpt.lfpt_st = 'A'
             WHERE lfd.lfd_id = p_lfd_id;
        END IF;

        RETURN l_result;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN 'NIL';
            ExceptionLog (
                package_name,
                'GetFileParsType',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- Призначення: Определение типа парсинга по разделителю или с фиксированной длиной;
    -- Параметри:   ІД файлу ;
    FUNCTION GetFileParsVers (p_lfd_id IN load_file_data.lfd_id%TYPE)
        RETURN load_file_version.lfv_id%TYPE
    IS
        l_result   load_file_version.lfv_id%TYPE;
    BEGIN
        IF (p_lfd_id IS NOT NULL)
        THEN
            SELECT lfv.lfv_id
              INTO l_result
              FROM load_file_data  lfd
                   JOIN load_file_version lfv
                       ON lfv.lfv_lft = lfd.lfd_lft AND lfv.lfv_st = 'A'
             WHERE lfd.lfd_id = p_lfd_id;
        END IF;

        RETURN l_result;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN 'NIL';
            ExceptionLog (
                package_name,
                'GetFileParsVers',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- Призначення: Для парсинга по разделителю, определение типа разделителя ;
    -- Параметри:   ІД файлу ;
    FUNCTION GetFileParsDLM (p_lfd_id IN load_file_data.lfd_id%TYPE)
        RETURN load_file_pars_dlm.lfpd_dlm%TYPE
    IS
        l_result   load_file_pars_dlm.lfpd_dlm%TYPE;
    BEGIN
        IF (p_lfd_id IS NOT NULL)
        THEN
            SELECT dlm.lfpd_dlm
              INTO l_result
              FROM load_file_data  lfd
                   LEFT JOIN load_file_version lfv
                       ON lfv.lfv_lft = lfd.lfd_lft AND lfv.lfv_st = 'A'
                   JOIN load_file_pars_type lfpt
                       ON     lfpt.lfpt_id = lfv.lfv_lfpt
                          AND lfpt.lfpt_code = 'DLM'
                          AND lfpt.lfpt_st = 'A'
                   JOIN load_file_pars_dlm dlm ON dlm.lfpd_lfv = lfv.lfv_id
             WHERE lfd.lfd_id = p_lfd_id;
        END IF;

        RETURN l_result;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN 'N';
            ExceptionLog (
                package_name,
                'GetFileParsDLM',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- Призначення: ;
    -- Параметри:   ;
    PROCEDURE InsertFileInfo (
        p_lfd_id          IN OUT load_file_data.lfd_id%TYPE,
        p_lfd_lfd         IN     load_file_data.lfd_lfd%TYPE,
        p_lfd_file_name   IN     load_file_data.lfd_file_name%TYPE,
        p_lfd_lft         IN     load_file_data.lfd_lft%TYPE,
        p_lfd_mime_type   IN     load_file_data.lfd_mime_type%TYPE,
        p_lfd_filesize    IN     load_file_data.lfd_filesize%TYPE,
        p_lfd_create_dt   IN     load_file_data.lfd_create_dt%TYPE,
        p_lfd_user_id     IN     load_file_data.lfd_user_id%TYPE,
        p_lfd_src         IN     load_file_data.lfd_src%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO load_file_data (lfd_id,
                                    lfd_lfd,
                                    lfd_file_name,
                                    lfd_lft,
                                    lfd_mime_type,
                                    lfd_filesize,
                                    lfd_create_dt,
                                    lfd_user_id,
                                    lfd_src)
             VALUES (p_lfd_id,
                     p_lfd_lfd,
                     p_lfd_file_name,
                     p_lfd_lft,
                     p_lfd_mime_type,
                     p_lfd_filesize,
                     p_lfd_create_dt,
                     p_lfd_user_id,
                     p_lfd_src)
          RETURNING lfd_id
               INTO p_lfd_id;

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            SetFileState (p_lfd_id => p_lfd_lfd, p_lfd_st => 'R');
            ExceptionLog (
                package_name,
                'InsertFileInfo',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- Призначення: ;
    -- Параметри:   ;
    PROCEDURE InsertFile (
        p_lfd_id          IN OUT load_file_data.lfd_id%TYPE,
        p_lfd_lfd         IN     load_file_data.lfd_lfd%TYPE,
        p_lfd_file_name   IN     load_file_data.lfd_file_name%TYPE,
        p_lfd_lft         IN     load_file_data.lfd_lft%TYPE,
        p_lfd_mime_type   IN     load_file_data.lfd_mime_type%TYPE,
        p_lfd_filesize    IN     load_file_data.lfd_filesize%TYPE,
        p_lfd_create_dt   IN     load_file_data.lfd_create_dt%TYPE,
        p_lfd_user_id     IN     load_file_data.lfd_user_id%TYPE,
        p_lfd_src         IN     load_file_data.lfd_src%TYPE)
    IS
    BEGIN
        INSERT INTO load_file_data (lfd_id,
                                    lfd_lfd,
                                    lfd_file_name,
                                    lfd_lft,
                                    lfd_mime_type,
                                    lfd_filesize,
                                    lfd_create_dt,
                                    lfd_user_id,
                                    lfd_src,
                                    lfd_st)
             VALUES (p_lfd_id,
                     p_lfd_lfd,
                     p_lfd_file_name,
                     p_lfd_lft,
                     p_lfd_mime_type,
                     p_lfd_filesize,
                     SYSDATE,
                     p_lfd_user_id,
                     p_lfd_src,
                     'A')
          RETURNING lfd_id
               INTO p_lfd_id;
    --SetFileState(p_lfd_id => p_lfd_id, p_lfd_st => 'A');
    EXCEPTION
        WHEN OTHERS
        THEN
            SetFileState (p_lfd_id => p_lfd_id, p_lfd_st => 'R');
            ExceptionLog (
                package_name,
                'InsertFile',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- Призначення: ;
    -- Параметри:   ;
    PROCEDURE InsertData (
        p_lfdc_lfd       IN load_file_data_content.lfdc_lfd%TYPE,
        p_lfdc_content   IN load_file_data_content.content%TYPE)
    IS
    BEGIN
        INSERT INTO load_file_data_content (lfdc_lfd, content)
             VALUES (p_lfdc_lfd, p_lfdc_content);
    EXCEPTION
        WHEN OTHERS
        THEN
            SetFileState (p_lfd_id => p_lfdc_lfd, p_lfd_st => 'R');
            ExceptionLog (
                package_name,
                'InsertData',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- Призначення: Видалення запису (логічне);
    -- Параметри:   ІД файлу ;
    PROCEDURE DeleteFile (p_lfd_id IN load_file_data.lfd_id%TYPE)
    IS
    BEGIN
        IF (p_lfd_id IS NOT NULL)
        THEN
            DELETE FROM load_file_data_content lfdc
                  WHERE lfdc.lfdc_lfd =
                        (SELECT lfd.lfd_id
                           FROM load_file_data lfd
                          WHERE lfd.lfd_id = p_lfd_id AND lfd.lfd_st = 'A');

            IF SQL%ROWCOUNT > 0
            THEN
                InsertLog (p_lfd_id, 'Видалено вміст файлу', 'U');
            END IF;

            SetFileState (p_lfd_id => p_lfd_id, p_lfd_st => 'D');
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            SetFileState (p_lfd_id => p_lfd_id, p_lfd_st => 'R');
            ExceptionLog (
                package_name,
                'DeleteData',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- Призначення: Видалення застарылоъ інформації після завершення завантаження або при помилці;
    -- Параметри:   лад, колличество дней;
    PROCEDURE ClearOldFile (p_lfd_id    IN load_file_data.lfd_id%TYPE,
                            p_cnt_day   IN NUMBER DEFAULT 30)
    IS
    BEGIN
        NULL;
    EXCEPTION
        WHEN OTHERS
        THEN
            SetFileState (p_lfd_id => p_lfd_id, p_lfd_st => 'R');
            ExceptionLog (
                package_name,
                'ClearOldFile',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- Призначення: Створення завдання для обробки файлу ;
    -- Параметри:   ІД завдання (джоба); ІД файлу ;
    PROCEDURE RegisterProcess (p_jb          OUT NUMBER,
                               p_lfd_id   IN     load_file_data.lfd_id%TYPE,
                               p_isweb    IN     NUMBER)
    IS
        v_lockhandler   VARCHAR2 (100);
    BEGIN
        ikis_sys.ikis_lock.request_lock (
            p_permanent_name      => 'USS_ESR',
            p_var_name            => 'LOAD_FILE_PARS:' || p_lfd_id,
            p_errmessage          =>
                'Парсинг файлу ' || p_lfd_id || ' вже виконується',
            p_lockhandler         => v_lockhandler,
            p_timeout             => 0,
            p_release_on_commit   => TRUE);

        ikis_sysweb.ikis_sysweb_schedule.SubmitSchedule (
            p_jb            => p_jb,
            p_subsys        => 'USS_ESR',
            p_wjt           => 'EXCH_LOAD_FILE_PARS',
            p_schema_name   => 'USS_EXCH',
            p_what          => 'USS_EXCH.LOAD_FILE_LOADER.StartProcess',
            p_nextdate      => NULL,
            p_isweb         => p_isweb);

        ikis_sysweb.ikis_sysweb_schedule.AddJobParam (
            p_jb_id        => p_jb,
            p_sjp_Name     => 'p_lfd_id',
            p_sjp_Value    => p_lfd_id,
            p_sjp_Type     => 'NUMBER',
            p_sjp_Format   => NULL);

        ikis_sysweb.ikis_sysweb_schedule.EnableJob_Univ (p_jb => p_jb);

        -- установка актуального задания
        setcurrentjob (p_lfd_id, p_jb);
        -- запись детальной информации по заданию
        load_file_jbl.insertjoblog (p_lfd_id, p_jb);
        -- изменение статуса
        SetFileState (p_lfd_id => p_lfd_id, p_lfd_st => 'J');
        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionLog (
                package_name,
                'RegisterProcess',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- Призначення: Обробка файлу ;
    -- Параметри:   ІД файлу ;
    FUNCTION ParseFile (p_lfd_id   IN load_file_data.lfd_id%TYPE,
                        p_txt      IN CLOB)
        RETURN NUMBER
    IS
        l_result                 PLS_INTEGER := 0;
        l_txt                    CLOB;
        l_filesize               load_file_data.lfd_filesize%TYPE;
        l_rc                     NUMBER;

        l_lfpt_code              load_file_pars_type.lfpt_code%TYPE;
        l_lfpd_dlm               load_file_pars_dlm.lfpd_dlm%TYPE;
        l_lfv_id                 load_file_version.lfv_id%TYPE;

        l_record                 load_file_data_pars%ROWTYPE;
        l_rownum                 NUMBER := 0;
        l_value                  VARCHAR2 (500);
        text                     VARCHAR2 (32767);
        part_text                VARCHAR2 (32767);

        -- for fix parsing
        TYPE tp_id_num IS TABLE OF NUMBER
            INDEX BY PLS_INTEGER;

        l_id_heading             tp_id_num;
        l_ln_heading             tp_id_num;
        l_start_ln_heading       tp_id_num;
        l_id_work                tp_id_num;
        l_ln_work                tp_id_num;
        l_start_ln_work          tp_id_num;
        l_is_heading             NUMBER;
        l_is_first               NUMBER := 1;

        v_lft_id                 load_file_type.lft_id%TYPE;
        v_prnt_lfd               load_file_data.lfd_id%TYPE;

        -- block exception
        e_err_parsing_type       EXCEPTION;
        e_err_parsing_type_NIL   EXCEPTION;
        e_err_parsing_dlm_NIL    EXCEPTION;

        PROCEDURE SetRecValue (
            p_element   IN     NUMBER,
            p_value     IN     VARCHAR2,
            p_record    IN OUT load_file_data_pars%ROWTYPE)
        IS
        BEGIN
            IF p_element = 1
            THEN
                p_record.f1 := p_value;
            ELSIF p_element = 2
            THEN
                p_record.f2 := p_value;
            ELSIF p_element = 3
            THEN
                p_record.f3 := p_value;
            ELSIF p_element = 4
            THEN
                p_record.f4 := p_value;
            ELSIF p_element = 5
            THEN
                p_record.f5 := p_value;
            ELSIF p_element = 6
            THEN
                p_record.f6 := p_value;
            ELSIF p_element = 7
            THEN
                p_record.f7 := p_value;
            ELSIF p_element = 8
            THEN
                p_record.f8 := p_value;
            ELSIF p_element = 9
            THEN
                p_record.f9 := p_value;
            ELSIF p_element = 10
            THEN
                p_record.f10 := p_value;
            ELSIF p_element = 11
            THEN
                p_record.f11 := p_value;
            ELSIF p_element = 12
            THEN
                p_record.f12 := p_value;
            ELSIF p_element = 13
            THEN
                p_record.f13 := p_value;
            ELSIF p_element = 14
            THEN
                p_record.f14 := p_value;
            ELSIF p_element = 15
            THEN
                p_record.f15 := p_value;
            ELSIF p_element = 16
            THEN
                p_record.f16 := p_value;
            ELSIF p_element = 17
            THEN
                p_record.f17 := p_value;
            ELSIF p_element = 18
            THEN
                p_record.f18 := p_value;
            ELSIF p_element = 19
            THEN
                p_record.f19 := p_value;
            ELSIF p_element = 20
            THEN
                p_record.f20 := p_value;
            ELSIF p_element = 21
            THEN
                p_record.f21 := p_value;
            ELSIF p_element = 22
            THEN
                p_record.f22 := p_value;
            ELSIF p_element = 23
            THEN
                p_record.f23 := p_value;
            ELSIF p_element = 24
            THEN
                p_record.f24 := p_value;
            ELSIF p_element = 25
            THEN
                p_record.f25 := p_value;
            ELSIF p_element = 26
            THEN
                p_record.f26 := p_value;
            ELSIF p_element = 27
            THEN
                p_record.f27 := p_value;
            ELSIF p_element = 28
            THEN
                p_record.f28 := p_value;
            ELSIF p_element = 29
            THEN
                p_record.f29 := p_value;
            ELSIF p_element = 30
            THEN
                p_record.f30 := p_value;
            ELSIF p_element = 31
            THEN
                p_record.f31 := p_value;
            ELSIF p_element = 32
            THEN
                p_record.f32 := p_value;
            ELSIF p_element = 33
            THEN
                p_record.f33 := p_value;
            ELSIF p_element = 34
            THEN
                p_record.f34 := p_value;
            ELSIF p_element = 35
            THEN
                p_record.f35 := p_value;
            ELSIF p_element = 36
            THEN
                p_record.f36 := p_value;
            ELSIF p_element = 37
            THEN
                p_record.f37 := p_value;
            ELSIF p_element = 38
            THEN
                p_record.f38 := p_value;
            ELSIF p_element = 39
            THEN
                p_record.f39 := p_value;
            ELSIF p_element = 40
            THEN
                p_record.f40 := p_value;
            ELSIF p_element = 41
            THEN
                p_record.f41 := p_value;
            ELSIF p_element = 42
            THEN
                p_record.f42 := p_value;
            ELSIF p_element = 43
            THEN
                p_record.f43 := p_value;
            ELSIF p_element = 44
            THEN
                p_record.f44 := p_value;
            ELSIF p_element = 45
            THEN
                p_record.f45 := p_value;
            ELSIF p_element = 46
            THEN
                p_record.f46 := p_value;
            ELSIF p_element = 47
            THEN
                p_record.f47 := p_value;
            ELSIF p_element = 48
            THEN
                p_record.f48 := p_value;
            ELSIF p_element = 49
            THEN
                p_record.f49 := p_value;
            ELSIF p_element = 50
            THEN
                p_record.f50 := p_value;
            ELSIF p_element = 51
            THEN
                p_record.f51 := p_value;
            ELSIF p_element = 52
            THEN
                p_record.f52 := p_value;
            ELSIF p_element = 53
            THEN
                p_record.f53 := p_value;
            ELSIF p_element = 54
            THEN
                p_record.f54 := p_value;
            ELSIF p_element = 55
            THEN
                p_record.f55 := p_value;
            END IF;
        END;
    BEGIN
        -- определяем тип парсинга, по разделителю (DLM) или по фиксированой длине
        l_lfpt_code := GetFileParsType (p_lfd_id);

        IF l_lfpt_code IN ('DLM', 'FIX')
        THEN                                   -- то что является парсингом ))
            -------------------------------------------------инизиализация------------------------------------------------
            IF l_lfpt_code = 'DLM'
            THEN -- для соответствующего типа парсинга выбираем необходимые правила парсинга
                l_lfpd_dlm := GetFileParsDLM (p_lfd_id); -- определение разделителя

                IF l_lfpd_dlm = 'NIL'
                THEN                  -- райс ошибки если разделитель не задан
                    RAISE e_err_parsing_dlm_NIL;
                END IF;
            END IF;

            -------------------------------------------------инизиализация-------------------------------------------------
            IF l_lfpt_code = 'FIX'
            THEN                -- размерность полей при фиксированом парсинге
                l_lfv_id := GetFileParsVers (p_lfd_id);   -- определяем версию

                -- для шапки
                -- определяем наличие парсинга строки шапки
                SELECT COUNT (*)
                  INTO l_is_heading
                  FROM load_file_pars_fix tp
                 WHERE tp.lfpf_lfv = l_lfv_id AND tp.lfpf_is_heading = 1;

                -- если есть модель парсинга первой строки
                IF l_is_heading > 0
                THEN
                      SELECT tp.lfpf_srtord,
                             tp.lfpf_ln,
                               COALESCE (
                                   SUM (tp.lfpf_ln)
                                       OVER (
                                           ORDER BY tp.lfpf_srtord
                                           ROWS BETWEEN UNBOUNDED PRECEDING
                                                AND     1 PRECEDING),
                                   0)
                             + 1
                        BULK COLLECT INTO l_id_heading,
                                          l_ln_heading,
                                          l_start_ln_heading
                        FROM load_file_pars_fix tp
                       WHERE tp.lfpf_lfv = l_lfv_id AND tp.lfpf_is_heading = 1
                    ORDER BY 1;
                END IF;

                  -- для основного тела файла
                  SELECT tp.lfpf_srtord,
                         tp.lfpf_ln,
                           COALESCE (
                               SUM (tp.lfpf_ln)
                                   OVER (
                                       ORDER BY tp.lfpf_srtord
                                       ROWS BETWEEN UNBOUNDED PRECEDING
                                            AND     1 PRECEDING),
                               0)
                         + 1
                    BULK COLLECT INTO l_id_work, l_ln_work, l_start_ln_work
                    FROM load_file_pars_fix tp
                   WHERE tp.lfpf_lfv = l_lfv_id AND tp.lfpf_is_heading = 0
                ORDER BY 1;
            END IF;
        ---------------------------------------------------парсинг---------------------------------------------------------
        ELSIF l_lfpt_code = 'WOP'
        THEN                        -- если без парсинга то игнорим на парсинг
            RETURN 0;
        ELSIF l_lfpt_code = 'NIL'
        THEN
            -- райс ошибки если тип парсинга не задан
            RAISE e_err_parsing_type_NIL;
        ELSE
            -- райс ошибки если недокоментированный тип парсинга
            RAISE e_err_parsing_type;
        END IF;

        l_txt :=
               CASE WHEN l_lfpt_code = 'DLM' THEN l_lfpd_dlm END
            || REPLACE (p_txt, CHR (0)); -- при разборе текстового файла с фиксированой длиной шло накопление символо NUL
        l_filesize := DBMS_LOB.getlength (l_txt);

        -- определяем колличество строк в файле по колличеству переносов строки chr(10)
        BEGIN
            l_rc :=
                  DBMS_LOB.getlength (l_txt || CHR (10))
                - DBMS_LOB.getlength (REPLACE (l_txt, CHR (10)))
                - 1;
            SetFileRecords (p_lfd_id, l_rc);
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        SELECT lfd_lft, COALESCE (lfd_lfd, p_lfd_id)
          INTO v_lft_id, v_prnt_lfd
          FROM load_file_data
         WHERE lfd_id = p_lfd_id;

        FOR i IN 1 .. TRUNC (l_filesize / 4000) + 1
        LOOP
            SELECT DBMS_LOB.SUBSTR (l_txt, 4000, (i - 1) * 4000 + 1)
              INTO part_text
              FROM DUAL;

            text :=
                   text
                || part_text
                || CASE
                       WHEN LENGTH (part_text) < 4000 THEN CHR (10)
                       ELSE ''
                   END;

            WHILE INSTR (text,
                         CHR (10),
                         1,
                         1) > 0
            LOOP
                l_rownum := l_rownum + 1;
                l_record := NULL;
                l_record.lfdp_rn := l_rownum;

                -- for parsing by Delimeter type
                IF l_lfpt_code = 'DLM'
                THEN
                    FOR ii IN 1 ..   INSTR (text,
                                            CHR (10),
                                            1,
                                            1)
                                   - INSTR (REPLACE (text, l_lfpd_dlm),
                                            CHR (10),
                                            1,
                                            1)
                    LOOP
                        IF ii =   INSTR (text,
                                         CHR (10),
                                         1,
                                         1)
                                - INSTR (REPLACE (text, l_lfpd_dlm),
                                         CHR (10),
                                         1,
                                         1)
                        THEN
                            --------------------------------------------------------------------------------------------------------------
                            -- Если при вставки в переменную размерность параметра более 500 символов то обрезаем до 500 и вставляем силой
                            BEGIN
                                l_value :=
                                    SUBSTR (text,
                                              INSTR (text,
                                                     l_lfpd_dlm,
                                                     1,
                                                     ii)
                                            + 1,
                                              CASE
                                                  WHEN INSTR (text,
                                                              CHR (10),
                                                              1,
                                                              1) = 0
                                                  THEN
                                                      1000
                                                  ELSE
                                                      INSTR (text,
                                                             CHR (10),
                                                             1,
                                                             1)
                                              END
                                            - INSTR (text,
                                                     l_lfpd_dlm,
                                                     1,
                                                     ii)
                                            - 1);
                            EXCEPTION
                                WHEN OTHERS
                                THEN
                                    l_value :=
                                        SUBSTR (
                                            SUBSTR (
                                                text,
                                                  INSTR (text,
                                                         l_lfpd_dlm,
                                                         1,
                                                         ii)
                                                + 1,
                                                  CASE
                                                      WHEN INSTR (text,
                                                                  CHR (10),
                                                                  1,
                                                                  1) = 0
                                                      THEN
                                                          1000
                                                      ELSE
                                                          INSTR (text,
                                                                 CHR (10),
                                                                 1,
                                                                 1)
                                                  END
                                                - INSTR (text,
                                                         l_lfpd_dlm,
                                                         1,
                                                         ii)
                                                - 1),
                                            1,
                                            500);
                            END;
                        --------------------------------------------------------------------------------------------------------------
                        ELSE
                            --------------------------------------------------------------------------------------------------------------
                            -- Если при вставки в переменную размерность параметра более 500 символов то обрезаем до 500 и вставляем силой
                            BEGIN
                                l_value :=
                                    SUBSTR (text,
                                              INSTR (text,
                                                     l_lfpd_dlm,
                                                     1,
                                                     ii)
                                            + 1,
                                              INSTR (text,
                                                     l_lfpd_dlm,
                                                     1,
                                                     ii + 1)
                                            - INSTR (text,
                                                     l_lfpd_dlm,
                                                     1,
                                                     ii)
                                            - 1);
                            EXCEPTION
                                WHEN OTHERS
                                THEN
                                    l_value :=
                                        SUBSTR (SUBSTR (text,
                                                          INSTR (text,
                                                                 l_lfpd_dlm,
                                                                 1,
                                                                 ii)
                                                        + 1,
                                                          INSTR (text,
                                                                 l_lfpd_dlm,
                                                                 1,
                                                                 ii + 1)
                                                        - INSTR (text,
                                                                 l_lfpd_dlm,
                                                                 1,
                                                                 ii)
                                                        - 1),
                                                1,
                                                500);
                            END;
                        --------------------------------------------------------------------------------------------------------------
                        END IF;

                        SetRecValue (ii,
                                     TRIM (REPLACE (l_value, CHR (13), ' ')),
                                     l_record);
                    END LOOP;
                -- for parsing by FIXing type
                ELSIF l_lfpt_code = 'FIX'
                THEN
                    IF l_is_heading > 0 AND l_is_first = 1
                    THEN
                        FOR ii IN l_id_heading.FIRST .. l_id_heading.LAST
                        LOOP
                            l_value :=
                                TRIM (
                                    SUBSTR (text,
                                            l_start_ln_heading (ii),
                                            l_ln_heading (ii)));
                            SetRecValue (
                                ii,
                                TRIM (REPLACE (l_value, CHR (13), ' ')),
                                l_record);

                            -- ShY 26112021 для загрузки каждой строки при фиксированой загрузке ставим в последнюю колонку ^ для проверки что не произошло смещение полей за счет спец символов
                            IF ii = l_id_heading.LAST
                            THEN
                                SetRecValue (ii + 1, CHR (94), l_record);
                            END IF;
                        END LOOP;

                        l_is_first := 0;
                    ELSE
                        FOR ii IN l_id_work.FIRST .. l_id_work.LAST
                        LOOP
                            l_value :=
                                TRIM (
                                    SUBSTR (text,
                                            l_start_ln_work (ii),
                                            l_ln_work (ii)));
                            SetRecValue (
                                ii,
                                TRIM (REPLACE (l_value, CHR (13), ' ')),
                                l_record);

                            -- ShY 26112021 для загрузки каждой строки при фиксированой загрузке ставим в последнюю колонку ^ для проверки что не произошло смещение полей за счет спец символов
                            IF ii = l_id_work.LAST
                            THEN
                                SetRecValue (ii + 1, CHR (94), l_record);
                            END IF;
                        END LOOP;
                    END IF;
                ELSE                                     -- for other variants
                    NULL;
                END IF;

                -- последнюю строку, перенос каретки не записываем
                IF NOT (    INSTR (text,
                                   CHR (13),
                                   1,
                                   1) = 0
                        AND l_record.f1 IS NULL)
                THEN
                    INSERT INTO load_file_data_pars (lfdp_lfd,
                                                     lfdp_rn,
                                                     f1,
                                                     f2,
                                                     f3,
                                                     f4,
                                                     f5,
                                                     f6,
                                                     f7,
                                                     f8,
                                                     f9,
                                                     f10,
                                                     f11,
                                                     f12,
                                                     f13,
                                                     f14,
                                                     f15,
                                                     f16,
                                                     f17,
                                                     f18,
                                                     f19,
                                                     f20,
                                                     f21,
                                                     f22,
                                                     f23,
                                                     f24,
                                                     f25,
                                                     f26,
                                                     f27,
                                                     f28,
                                                     f29,
                                                     f30,
                                                     f31,
                                                     f32,
                                                     f33,
                                                     f34,
                                                     f35,
                                                     f36,
                                                     f37,
                                                     f38,
                                                     f39,
                                                     f40,
                                                     f41,
                                                     f42,
                                                     f43,
                                                     f44,
                                                     f45,
                                                     f46,
                                                     f47,
                                                     f48,
                                                     f49,
                                                     f50,
                                                     f51,
                                                     f52,
                                                     f53,
                                                     f54,
                                                     f55)
                         VALUES (p_lfd_id,
                                 l_record.lfdp_rn,
                                 l_record.f1,
                                 l_record.f2,
                                 l_record.f3,
                                 l_record.f4,
                                 l_record.f5,
                                 l_record.f6,
                                 l_record.f7,
                                 l_record.f8,
                                 l_record.f9,
                                 l_record.f10,
                                 l_record.f11,
                                 l_record.f12,
                                 l_record.f13,
                                 l_record.f14,
                                 l_record.f15,
                                 l_record.f16,
                                 l_record.f17,
                                 l_record.f18,
                                 l_record.f19,
                                 l_record.f20,
                                 l_record.f21,
                                 l_record.f22,
                                 l_record.f23,
                                 l_record.f24,
                                 l_record.f25,
                                 l_record.f26,
                                 l_record.f27,
                                 l_record.f28,
                                 l_record.f29,
                                 l_record.f30,
                                 l_record.f31,
                                 l_record.f32,
                                 l_record.f33,
                                 l_record.f34,
                                 l_record.f35,
                                 l_record.f36,
                                 l_record.f37,
                                 l_record.f38,
                                 l_record.f39,
                                 l_record.f40,
                                 l_record.f41,
                                 l_record.f42,
                                 l_record.f43,
                                 l_record.f44,
                                 l_record.f45,
                                 l_record.f46,
                                 l_record.f47,
                                 l_record.f48,
                                 l_record.f49,
                                 l_record.f50,
                                 l_record.f51,
                                 l_record.f52,
                                 l_record.f53,
                                 l_record.f54,
                                 l_record.f55);
                END IF;

                --if mod(l_rownum, 100) = 0  then commit; end if;
                text :=
                       CASE WHEN l_lfpt_code = 'DLM' THEN l_lfpd_dlm END
                    || SUBSTR (
                           text,
                             CASE
                                 WHEN INSTR (text, CHR (10)) = 0 THEN 32766
                                 ELSE INSTR (text, CHR (10))
                             END
                           + 1,
                           32767);
            END LOOP;

            COMMIT;
        END LOOP;

        RETURN l_result;
    EXCEPTION
        WHEN e_err_parsing_type_NIL
        THEN
            ExceptionLog (package_name,
                          'ParseFile',
                          'Не вказано тип парсингу');
            RETURN 1;
        WHEN e_err_parsing_type
        THEN
            ExceptionLog (package_name,
                          'ParseFile',
                          'Недокументований тип парсингу');
            RETURN 1;
        WHEN e_err_parsing_dlm_NIL
        THEN
            ExceptionLog (package_name, 'ParseFile', 'Разделитель не задан');
            RETURN 1;
        WHEN OTHERS
        THEN
            ExceptionLog (
                package_name,
                'ParseFile',
                SUBSTR (
                       DBMS_UTILITY.format_error_stack
                    || DBMS_UTILITY.format_error_backtrace,
                    1,
                    3000),
                p_lfd_id);
            RETURN 1;
    END;

    -- Призначення: Обробка файлу ;
    -- Параметри:   ІД файлу ;
    PROCEDURE StartProcess (p_lfd_id IN load_file_data.lfd_id%TYPE)
    IS
        l_id                   load_file_data.lfd_id%TYPE;
        l_lft                  load_file_data.lfd_lft%TYPE;
        l_mime_type            load_file_data.lfd_mime_type%TYPE;
        l_arch_mime_type       load_file_data.lfd_mime_type%TYPE;
        l_filesize             load_file_data.lfd_filesize%TYPE;
        l_src                  load_file_data.lfd_src%TYPE;
        l_st                   load_file_data.lfd_st%TYPE;
        l_user_id              load_file_data.lfd_user_id%TYPE;
        l_content              BLOB;
        l_files                tbl_file_info;
        txt                    CLOB;
        l_result               PLS_INTEGER; -- переменная для инициализации детального файла парсинга
        l_result_all           PLS_INTEGER := 0; -- переменная для инициализации общего файла
        l_string               VARCHAR2 (100);
        l_is_loadonly          load_file_type.lft_is_loadonly%TYPE;
        l_charset              INTEGER;
        l_files_lv2            tbl_file_info;
        l_id_lv2               load_file_data.lfd_id%TYPE;
        l_arch_mime_type_lv2   load_file_data.lfd_mime_type%TYPE;
        l_cnt_parsing          NUMBER;
    BEGIN
        -- обновляем модули заданий
        load_file_jbl.controljobs;

        -- считаем колличеество заданий в работе с ид меньше чем текущее, когда ментше 3 то запускается в работу это
        SELECT COUNT (*)
          INTO l_cnt_parsing
          FROM load_file_data_jobs  j
               JOIN load_file_data_jobs i
                   ON     i.lfdj_jb_wjt = j.lfdj_jb_wjt
                      AND i.lfdj_lfd = p_lfd_id
                      AND i.lfdj_id <> j.lfdj_id
         WHERE     j.lfdj_jb_wjt = 'EXCH_LOAD_FILE_PARS'
               AND j.lfdj_st = 'RUNING'
               AND j.lfdj_id < i.lfdj_id;

        -- ждем пока колличество распарсиваемых файлов уменьшится до 3
        WHILE l_cnt_parsing > 5
        LOOP
            DeleteLog (p_lfd_id);
            InsertLog (p_lfd_id,
                       'Файл в черзі на обробку',
                       'P',
                       'J');
            -- пауза
            ikis_sys.ikis_lock.sleep (7);
            -- обновляем модули заданий
            load_file_jbl.controljobs;

            -- считаем колличеество заданий в работе с ид меньше чем текущее, когда ментше 3 то запускается в работу это
            SELECT COUNT (*)
              INTO l_cnt_parsing
              FROM load_file_data_jobs  j
                   JOIN load_file_data_jobs i
                       ON     i.lfdj_jb_wjt = j.lfdj_jb_wjt
                          AND i.lfdj_lfd = p_lfd_id
                          AND i.lfdj_id <> j.lfdj_id
             WHERE     j.lfdj_jb_wjt = 'EXCH_LOAD_FILE_PARS'
                   AND j.lfdj_st = 'RUNING'
                   AND j.lfdj_id < i.lfdj_id;
        END LOOP;

        -- пауза
        ikis_sys.ikis_lock.sleep (1);
        -- изменение статуса
        SetFileState (p_lfd_id => p_lfd_id, p_lfd_st => 'P');

        -- инициализация файла
        SELECT lfd.lfd_lft,
               LOWER (COALESCE (lfd_mime_type, 'text/plain')),
               lfd.lfd_filesize,
               lfd.lfd_src,
               lfdc.content,
               lfd.lfd_st,
               lft.lft_is_loadonly,
               lfd.lfd_user_id,
               NVL (NLS_CHARSET_ID (lft.lft_charset), DBMS_LOB.default_csid)
          INTO l_lft,
               l_mime_type,
               l_filesize,
               l_src,
               l_content,
               l_st,
               l_is_loadonly,
               l_user_id,
               l_charset
          FROM load_file_data  lfd
               JOIN load_file_type lft ON lft.lft_id = lfd.lfd_lft
               JOIN load_file_data_content lfdc ON lfdc.lfdc_lfd = lfd.lfd_id
         WHERE lfd.lfd_id = p_lfd_id;

        IF l_is_loadonly = 'F'
        THEN
            -- якщо дійшли до основного этапу парсинга - створюємо секцію під файл  (устаревшее)
            -- если файл будет парситься то именно здесь создаем партиции
            IF l_mime_type IN
                   ('application/zip',
                    'application/x-zip-compressed',
                    'application/octet-stream')
            THEN
                InsertLog (p_lfd_id,
                           'Розпочато розархівацію файлу',
                           'U',
                           'P');

                load_file_java_util.getBlobsFromZip (src     => l_content,
                                                     dst     => l_files,
                                                     bsize   => 256);

                FOR i IN l_files.FIRST .. l_files.LAST
                LOOP
                    InsertLog (p_lfd_id,
                               'Обробка файлу ' || l_files (i).filename,
                               'U',
                               'P');
                    txt :=
                        ConvertBLOBToCLOB (l_files (i).content2, l_charset);
                    -- init id for document
                    l_id := 0;
                    l_arch_mime_type :=
                        CASE
                            WHEN LOWER (l_files (i).filename) LIKE '%.csv'
                            THEN
                                'application/vnd.ms-excel'
                            WHEN LOWER (l_files (i).filename) LIKE '%.json'
                            THEN
                                'application/json'
                            WHEN LOWER (l_files (i).filename) LIKE '%.p7s'
                            THEN
                                'application/pkcs7-signature'
                            WHEN LOWER (l_files (i).filename) LIKE '%/'
                            THEN
                                'application/folder'
                            WHEN LOWER (l_files (i).filename) LIKE '%.zip'
                            THEN
                                'application/x-zip-compressed'
                            WHEN LOWER (l_files (i).filename) LIKE '%.xml'
                            THEN
                                'text/xml'
                            WHEN LOWER (l_files (i).filename) LIKE '%.xlsx'
                            THEN
                                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                            WHEN LOWER (l_files (i).filename) LIKE '%.xls'
                            THEN
                                'application/vnd.ms-excel'
                            ELSE
                                'text/plain'
                        END;
                    ---------------  ВСТАВКА ФАЙЛА ИЗ АРХИВА
                    InsertFileInfo (
                        p_lfd_id          => l_id,
                        p_lfd_lfd         => p_lfd_id,
                        p_lfd_file_name   => l_files (i).filename,
                        p_lfd_lft         => l_lft,
                        p_lfd_mime_type   => l_arch_mime_type,
                        p_lfd_filesize    => DBMS_LOB.getlength (txt),
                        p_lfd_create_dt   => SYSDATE,
                        p_lfd_user_id     => l_user_id,
                        p_lfd_src         => l_src);

                    IF l_arch_mime_type IN ('text/plain',
                                            'application/vnd.ms-excel',
                                            'application/csv',
                                            'application/json')
                    THEN
                        l_result := ParseFile (l_id, txt);

                        -- обновляем статус файла что парсится по результату парсинга
                        IF l_result = 0
                        THEN
                            SetFileState (p_lfd_id => l_id, p_lfd_st => 'C');
                        ELSE
                            SetFileState (p_lfd_id => l_id, p_lfd_st => 'R');
                            l_result_all := l_result;
                        END IF;
                    --elsif l_arch_mime_type in ('application/pkcs7-signature') then  -- если подпись то сохряняем как отдельное вложение ибо потом нужно отправить
                    --  InsertData(p_lfdc_lfd => l_id,
                    --             p_lfdc_content => l_files(i).content2);
                    ELSIF l_arch_mime_type IN
                              ('text/xml',
                               'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                               'application/vnd.ms-excel')
                    THEN
                        InsertData (p_lfdc_lfd       => l_id,
                                    p_lfdc_content   => l_files (i).content2);
                        SetFileState (p_lfd_id => l_id, p_lfd_st => 'C');
                    ELSIF l_arch_mime_type IN
                              ('application/zip',
                               'application/x-zip-compressed',
                               'application/octet-stream')
                    THEN  -- если архив внутри архива - разорхивируем и храним
                        InsertData (p_lfdc_lfd       => l_id,
                                    p_lfdc_content   => l_files (i).content2);
                        ----------------------------------------------------------------------------------------------
                        -- для второго уровня тоже разархивируем и запускаем процесс. Глубже второго уровня не копаем.  !!!!!!!!!!!!!!!!!!!!!!
                        ----------------------------------------------------------------------------------------------
                        load_file_java_util.getBlobsFromZip (
                            src     => l_files (i).content2,
                            dst     => l_files_lv2,
                            bsize   => 256);

                        FOR ii IN l_files_lv2.FIRST .. l_files_lv2.LAST
                        LOOP
                            InsertLog (
                                p_lfd_id,
                                'Обробка файлу ' || l_files_lv2 (ii).filename,
                                'U',
                                'P');
                            txt :=
                                ConvertBLOBToCLOB (l_files_lv2 (ii).content2,
                                                   l_charset);
                            -- init id for document
                            l_id_lv2 := 0;
                            l_arch_mime_type_lv2 :=
                                CASE
                                    WHEN LOWER (l_files_lv2 (ii).filename) LIKE
                                             '%.csv'
                                    THEN
                                        'application/vnd.ms-excel'
                                    WHEN LOWER (l_files_lv2 (ii).filename) LIKE
                                             '%.json'
                                    THEN
                                        'application/json'
                                    WHEN LOWER (l_files_lv2 (ii).filename) LIKE
                                             '%.p7s'
                                    THEN
                                        'application/pkcs7-signature'
                                    WHEN LOWER (l_files_lv2 (ii).filename) LIKE
                                             '%/'
                                    THEN
                                        'application/folder'
                                    WHEN LOWER (l_files_lv2 (ii).filename) LIKE
                                             '%.zip'
                                    THEN
                                        'application/x-zip-compressed'
                                    WHEN LOWER (l_files_lv2 (ii).filename) LIKE
                                             '%.xml'
                                    THEN
                                        'text/xml'
                                    WHEN LOWER (l_files (i).filename) LIKE
                                             '%.xlsx'
                                    THEN
                                        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                                    WHEN LOWER (l_files (i).filename) LIKE
                                             '%.xls'
                                    THEN
                                        'application/vnd.ms-excel'
                                    ELSE
                                        'text/plain'
                                END;
                            ---------------  ВСТАВКА ФАЙЛА ИЗ АРХИВА
                            InsertFileInfo (
                                p_lfd_id          => l_id_lv2,
                                p_lfd_lfd         => p_lfd_id,
                                p_lfd_file_name   => l_files_lv2 (ii).filename,
                                p_lfd_lft         => l_lft,
                                p_lfd_mime_type   => l_arch_mime_type_lv2,
                                p_lfd_filesize    => DBMS_LOB.getlength (txt),
                                p_lfd_create_dt   => SYSDATE,
                                p_lfd_user_id     => l_user_id,
                                p_lfd_src         => l_src);

                            IF l_arch_mime_type_lv2 IN
                                   ('text/plain',
                                    'text/csv',
                                    'application/vnd.ms-excel',
                                    'application/csv',
                                    'application/json')
                            THEN
                                l_result := ParseFile (l_id_lv2, txt);

                                -- обновляем статус файла что парсится по результату парсинга
                                IF l_result = 0
                                THEN
                                    SetFileState (p_lfd_id   => l_id_lv2,
                                                  p_lfd_st   => 'C');
                                ELSE
                                    SetFileState (p_lfd_id   => l_id_lv2,
                                                  p_lfd_st   => 'R');
                                    l_result_all := l_result;
                                END IF;
                            ELSIF l_arch_mime_type_lv2 IN
                                      ('text/xml',
                                       'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                                       'application/vnd.ms-excel')
                            THEN
                                InsertData (
                                    p_lfdc_lfd   => l_id_lv2,
                                    p_lfdc_content   =>
                                        l_files_lv2 (ii).content2);
                                SetFileState (p_lfd_id   => l_id_lv2,
                                              p_lfd_st   => 'C');
                            END IF;
                        END LOOP;
                    ------------------------------------------------------------------------------------------
                    END IF;
                END LOOP;

                -- обновляем статус архива по результату парсинга всех вложенных файлов
                IF l_result_all = 0
                THEN
                    SetFileState (p_lfd_id => p_lfd_id, p_lfd_st => 'C');
                ELSE
                    SetFileState (p_lfd_id => p_lfd_id, p_lfd_st => 'R');
                END IF;
            -- ОБРОБОТКА ФАЙЛА ЕСЛИ ОН НЕ НАХОДИТСЯ В АРХИВЕ
            ELSIF l_mime_type IN ('text/plain',
                                  'text/csv',
                                  'application/vnd.ms-excel',
                                  'application/csv',
                                  'application/json')
            THEN
                txt := convertblobtoclob (l_content, l_charset);
                l_result := ParseFile (p_lfd_id, txt);

                -- обновляем статус файла что парсится по результату парсинга
                IF l_result = 0
                THEN
                    SetFileState (p_lfd_id => p_lfd_id, p_lfd_st => 'C');
                ELSE
                    SetFileState (p_lfd_id => p_lfd_id, p_lfd_st => 'R');
                END IF;
            ELSIF l_mime_type IN ('text/xml')
            THEN
                txt := convertblobtoclob (l_content, l_charset);
                SetFileState (p_lfd_id => p_lfd_id, p_lfd_st => 'C');
            -- ЗАРЕЗЕРВИРОВАННЫЙ БЛОК
            ELSE
                SetFileState (p_lfd_id => p_lfd_id, p_lfd_st => 'R');
                InsertLog (p_lfd_id,
                           'Даний тип файлу не обробляється',
                           'P',
                           'R');
                RETURN;
            END IF;
        ELSE
            -- для просто загруженных файлов сразу ставим статус С
            SetFileState (p_lfd_id => p_lfd_id, p_lfd_st => 'C');
        END IF;

        --ShY 16/10/2020  -- запуск контроля возможен только при успешном выполнении парсинга
        FOR validrec
            IN (SELECT lfd.lfd_id
                  FROM load_file_data  lfd
                       JOIN load_file_type lft
                           ON     lft.lft_id = lfd.lfd_lft
                              AND lft.lft_is_auto_next = 'T'
                 WHERE lfd.lfd_id = p_lfd_id AND lfd.lfd_st = 'C')
        LOOP
            DECLARE
                l_cntrl_jb   NUMBER;
            BEGIN
                RegisterProcessControl (p_jb       => l_cntrl_jb,
                                        p_lfd_id   => p_lfd_id,
                                        p_isweb    => 0);
            END;
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            -- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            -- Устанавливаем статус ошибки при падении
            SetFileState (p_lfd_id => p_lfd_id, p_lfd_st => 'R');
            InsertLog (
                p_lfd_id,
                TRIM (
                    REPLACE (DBMS_UTILITY.format_error_stack,
                             'ORA-20000:',
                             '')),
                'P',
                'R');
            ExceptionLog (
                package_name,
                'StartProcess',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace,
                p_lfd_id);
    END;

    -- Info:   Реєстрація процесу контроля
    -- Params:
    PROCEDURE RegisterProcessControl (
        p_jb          OUT NUMBER,
        p_lfd_id   IN     load_file_data.lfd_id%TYPE,
        p_isweb    IN     NUMBER)
    IS
        v_lockhandler   VARCHAR2 (100);
        exc_not_job     EXCEPTION;
    BEGIN
        FOR validrec
            IN (SELECT lfd.file_id
                  FROM v_load_file_data_full lfd
                 WHERE lfd.file_id = p_lfd_id AND lfd.file_st_code = 'C')
        LOOP
            ikis_sys.ikis_lock.request_lock (
                p_permanent_name      => 'USS_ESR',
                p_var_name            => 'LOAD_FILE_CNTR:' || p_lfd_id,
                p_errmessage          =>
                    'Перевірка файлу ' || p_lfd_id || ' вже виконується',
                p_lockhandler         => v_lockhandler,
                p_timeout             => 0,
                p_release_on_commit   => TRUE);

            ikis_sysweb.ikis_sysweb_schedule.SubmitSchedule (
                p_jb            => p_jb,
                p_subsys        => 'USS_ESR',
                p_wjt           => 'EXCH_LOAD_FILE_CNTR',
                p_schema_name   => 'USS_EXCH',
                p_what          =>
                    'USS_EXCH.LOAD_FILE_LOADER.StartProcessControl',
                p_nextdate      => NULL,
                p_isweb         => p_isweb);

            ikis_sysweb.ikis_sysweb_schedule.AddJobParam (
                p_jb_id        => p_jb,
                p_sjp_Name     => 'p_lfd_id',
                p_sjp_Value    => p_lfd_id,
                p_sjp_Type     => 'NUMBER',
                p_sjp_Format   => NULL);

            ikis_sysweb.ikis_sysweb_schedule.EnableJob_Univ (p_jb => p_jb);

            -- установка актуального задания
            setcurrentjob (p_lfd_id, p_jb);
            -- запись детальной информации по заданию
            load_file_jbl.insertjoblog (p_lfd_id, p_jb);
            -- изменение статуса
            SetFileState (p_lfd_id => p_lfd_id, p_lfd_st => 'J');

            COMMIT;
        END LOOP;

        -- якщо сменился статус файла райзим исключение
        IF p_jb IS NULL
        THEN
            RAISE exc_not_job;
        END IF;
    EXCEPTION
        WHEN exc_not_job
        THEN
            raise_application_error (
                -20000,
                'Контроль файлу вже виконано/виконується. Оновіть будь ласка сторінку.');
        WHEN OTHERS
        THEN
            ExceptionLog (
                package_name,
                'RegisterProcess',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace,
                p_lfd_id);
    END;

    PROCEDURE StartProcessControl (p_lfd_id IN load_file_data.lfd_id%TYPE)
    IS
        l_lft_code   load_file_type.lft_code%TYPE;
        l_sql_str    VARCHAR2 (32767);
        l_string     VARCHAR2 (100);
        l_file_id    load_file_data.lfd_id%TYPE;
        l_ver_id     load_file_version.lfv_id%TYPE;
    BEGIN
        -- обновляем модули заданий
        load_file_jbl.controljobs;
        -- пауза
        ikis_sys.ikis_lock.sleep (1);
        -- изменение статуса
        SetFileState (p_lfd_id => p_lfd_id, p_lfd_st => 'Q');

        -- код типа загрузки
        SELECT t.lft_code
          INTO l_lft_code
          FROM load_file_data  lfd
               JOIN load_file_type t ON t.lft_id = lfd.lfd_lft
         WHERE lfd.lfd_id = p_lfd_id;

        -- определяем версию по которой будем загружать файл
        FOR iii
            IN (SELECT ch.lfd_id,
                       lfv.lfv_id,
                       ch.lfd_file_name,
                       CASE
                           WHEN ROW_NUMBER () OVER (ORDER BY ch.lfd_id) = 1
                           THEN
                               1
                           ELSE
                               0
                       END    AS is_first,
                       CASE
                           WHEN ROW_NUMBER () OVER (ORDER BY ch.lfd_id DESC) =
                                1
                           THEN
                               1
                           ELSE
                               0
                       END    AS is_last
                  FROM load_file_data  lfd
                       JOIN load_file_data ch ON ch.lfd_lfd = lfd.lfd_id
                       JOIN load_file_version lfv
                           ON lfv.lfv_lft = ch.lfd_lft AND lfv.lfv_st = 'A'
                 WHERE     lfd.lfd_id = p_lfd_id
                       AND ch.lfd_st = 'C'
                       AND (   EXISTS
                                   (SELECT 1
                                      FROM load_file_data_pars lfdp
                                     WHERE lfdp.lfdp_lfd = ch.lfd_id)
                            OR (lfv.lfv_lfpt = 0))
                       AND EXISTS
                               (SELECT 2
                                  FROM load_file_sql s
                                 WHERE     s.lfs_lfv = lfv.lfv_id
                                       AND s.lfs_tp = 'C'
                                       AND s.lfs_st = 'A')
                UNION ALL
                SELECT lfd.lfd_id,
                       lfv.lfv_id,
                       lfd.lfd_file_name,
                       1     AS is_first,
                       1     AS is_last
                  FROM load_file_data  lfd
                       JOIN load_file_version lfv
                           ON lfv.lfv_lft = lfd.lfd_lft AND lfv.lfv_st = 'A'
                 WHERE     lfd.lfd_id = p_lfd_id
                       AND lfd.lfd_st = 'Q'
                       AND (   EXISTS
                                   (SELECT 1
                                      FROM load_file_data_pars lfdp
                                     WHERE lfdp.lfdp_lfd = lfd.lfd_id)
                            OR (lfv.lfv_lfpt = 0))
                       AND EXISTS
                               (SELECT 2
                                  FROM load_file_sql s
                                 WHERE     s.lfs_lfv = lfv.lfv_id
                                       AND s.lfs_tp = 'C'
                                       AND s.lfs_st = 'A')
                ORDER BY 1)
        LOOP
            l_file_id := iii.lfd_id;
            l_ver_id := iii.lfv_id;

            InsertLog (p_lfd_id,
                       'Контроль файлу: ' || iii.lfd_file_name,
                       'U');

            -- в цикле выполняем последовательно запросы по данной версии загрузки
            FOR rec
                IN (  SELECT *
                        FROM load_file_sql s
                       WHERE     s.lfs_lfv = l_ver_id
                             AND s.lfs_tp = 'C'
                             AND s.lfs_st = 'A'
                             AND s.lfs_4first <= iii.is_first
                             AND s.lfs_4last <= iii.is_last
                    ORDER BY s.lfs_ord)
            LOOP
                l_sql_str := rec.lfs_sql;

                -- для каждого запроса делаем замены
                FOR cur IN (  SELECT *
                                FROM load_file_sql_replace r
                               WHERE r.lfsr_lfv = l_ver_id AND r.lfsr_st = 'A'
                            ORDER BY LENGTH (r.lfsr_src) DESC)
                LOOP
                    l_sql_str :=
                        REPLACE (l_sql_str, cur.lfsr_src, cur.lfsr_trg);
                END LOOP;

                BEGIN
                    InsertLog (p_lfd_id, rec.lfs_ord, 'T');
                    InsertLog (p_lfd_id, l_sql_str, 'T');
                    InsertLog (p_lfd_id, l_file_id, 'T');

                    --выполнение запроса
                    EXECUTE IMMEDIATE l_sql_str
                        USING IN l_file_id;

                    InsertLog (p_lfd_id, SQL%ROWCOUNT, 'T');
                    InsertLog (
                        p_lfd_id,
                        TRIM (
                               'Крок '
                            || rec.lfs_ord
                            || ' контролю файлу '
                            || iii.lfd_file_name
                            || ' виконано'
                            || CASE
                                   WHEN rec.lfs_comment IS NOT NULL THEN ' ('
                               END
                            || rec.lfs_comment
                            || CASE
                                   WHEN rec.lfs_comment IS NOT NULL THEN ')'
                               END),
                        'U');
                END;
            END LOOP;

            -- устанавливаем статус для вложенного файла
            SetFileState (p_lfd_id => l_file_id, p_lfd_st => 'V');
            InsertLog (
                p_lfd_id,
                'Контроль файлу ' || iii.lfd_file_name || ' завершено',
                'U');
        END LOOP;

        --окончательно обновляем состояние контроля по общему файлу
        IF p_lfd_id <> COALESCE (l_file_id, -1)
        THEN
            SetFileState (p_lfd_id => p_lfd_id, p_lfd_st => 'V');
        END IF;

        -- ShY 16/10/2020  -- запуск загрузки возможентолько при успешном выполнении контроля
        FOR validrec
            IN (SELECT lfd.lfd_id
                  FROM load_file_data  lfd
                       JOIN load_file_type lft
                           ON     lft.lft_id = lfd.lfd_lft
                              AND lft.lft_is_auto_next = 'T'
                 WHERE lfd.lfd_id = p_lfd_id AND lfd.lfd_st = 'V')
        LOOP
            DECLARE
                l_load_jb   NUMBER;
            BEGIN
                RegisterProcessLoad (l_load_jb, p_lfd_id, 0);
            END;
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            -- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
            -- При ошибке устанавливаем статус ошибки для файла что контролировался и для всего общего файла
            SetFileState (p_lfd_id => l_file_id, p_lfd_st => 'R');
            InsertLog (
                p_lfd_id,
                TRIM (
                    REPLACE (DBMS_UTILITY.format_error_stack,
                             'ORA-20000:',
                             '')),
                'P',
                'R');

            IF p_lfd_id <> l_file_id
            THEN
                SetFileState (p_lfd_id => p_lfd_id, p_lfd_st => 'R');
            END IF;

            IF l_lft_code = 'USR'
            THEN
                load_file_prtcl.checklsdata (p_lfd_id);
            END IF;

            ExceptionLog (
                package_name,
                'StartProcessControl',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace,
                p_lfd_id);
    END;

    -- Info:   Реєстрація процесу завантаження
    -- Params:
    PROCEDURE RegisterProcessLoad (
        p_jb          OUT NUMBER,
        p_lfd_id   IN     load_file_data.lfd_id%TYPE,
        p_isweb    IN     NUMBER)
    IS
        v_lockhandler   VARCHAR2 (100);
        exc_not_job     EXCEPTION;
    BEGIN
        FOR validrec
            IN (SELECT lfd.file_id
                  FROM v_load_file_data_full lfd
                 WHERE     lfd.file_id = p_lfd_id
                       AND (   (lfd.file_st_code = 'V')
                            OR (    lfd.file_st_code = 'F'
                                AND lfd.file_type_id = 10
                                AND lfd.cnt_toload > 0)))
        LOOP
            ikis_sys.ikis_lock.request_lock (
                p_permanent_name      => 'USS_ESR',
                p_var_name            => 'LOAD_FILE_LOAD:' || p_lfd_id,
                p_errmessage          =>
                    'Завантаження файлу ' || p_lfd_id || ' вже виконується',
                p_lockhandler         => v_lockhandler,
                p_timeout             => 0,
                p_release_on_commit   => TRUE);

            ikis_sysweb.ikis_sysweb_schedule.SubmitSchedule (
                p_jb            => p_jb,
                p_subsys        => 'USS_ESR',
                p_wjt           => 'EXCH_LOAD_FILE_LOAD',
                p_schema_name   => 'USS_EXCH',
                p_what          =>
                    'USS_EXCH.LOAD_FILE_LOADER.StartProcessLoad',
                p_nextdate      => NULL,
                p_isweb         => p_isweb);

            ikis_sysweb.ikis_sysweb_schedule.AddJobParam (
                p_jb_id        => p_jb,
                p_sjp_Name     => 'p_lfd_id',
                p_sjp_Value    => p_lfd_id,
                p_sjp_Type     => 'NUMBER',
                p_sjp_Format   => NULL);

            ikis_sysweb.ikis_sysweb_schedule.EnableJob_Univ (p_jb => p_jb);

            -- установка актуального задания
            setcurrentjob (p_lfd_id, p_jb);
            -- запись детальной информации по заданию
            load_file_jbl.insertjoblog (p_lfd_id, p_jb);
            -- изменение статуса
            setfilestate (p_lfd_id => p_lfd_id, p_lfd_st => 'J');

            COMMIT;
        END LOOP;

        -- якщо сменился статус файла райзим исключение
        IF p_jb IS NULL
        THEN
            RAISE exc_not_job;
        END IF;
    EXCEPTION
        WHEN exc_not_job
        THEN
            raise_application_error (
                -20000,
                'Завантаження файлу вже виконано/виконується. Оновіть будь ласка сторінку.');
        WHEN OTHERS
        THEN
            ExceptionLog (
                package_name,
                'RegisterProcess',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace,
                p_lfd_id);
    END;

    PROCEDURE StartProcessLoad (p_lfd_id IN load_file_data.lfd_id%TYPE)
    IS
        l_sql_str   VARCHAR2 (32767);
        l_string    VARCHAR2 (100);
        l_file_id   load_file_data.lfd_id%TYPE;
        l_ver_id    load_file_version.lfv_id%TYPE;
    BEGIN
        -- обновляем модули заданий
        load_file_jbl.controljobs;
        -- пауза
        ikis_sys.ikis_lock.sleep (1);
        -- изменение статуса
        SetFileState (p_lfd_id => p_lfd_id, p_lfd_st => 'L');

        -- определяем версию по которой будем загружать файл
        FOR iii
            IN (SELECT ch.lfd_id,
                       lfv.lfv_id,
                       ch.lfd_file_name,
                       CASE
                           WHEN ROW_NUMBER () OVER (ORDER BY ch.lfd_id) = 1
                           THEN
                               1
                           ELSE
                               0
                       END    AS is_first,
                       CASE
                           WHEN ROW_NUMBER () OVER (ORDER BY ch.lfd_id DESC) =
                                1
                           THEN
                               1
                           ELSE
                               0
                       END    AS is_last
                  FROM load_file_data  lfd
                       JOIN load_file_data ch ON ch.lfd_lfd = lfd.lfd_id
                       JOIN load_file_type lft ON lft.lft_id = lfd.lfd_lft
                       JOIN load_file_version lfv
                           ON lfv.lfv_lft = ch.lfd_lft AND lfv.lfv_st = 'A'
                 WHERE     lfd.lfd_id = p_lfd_id
                       AND (   ch.lfd_st IN ('C', 'V')
                            OR (ch.lfd_st IN ('F') AND lfd.lfd_lft = 10)) -- 10 переписать на атрибут в load_file_type
                       AND (   EXISTS
                                   (SELECT 1
                                      FROM load_file_data_pars lfdp
                                     WHERE lfdp.lfdp_lfd = ch.lfd_id)
                            OR (lfv.lfv_lfpt = 0))
                       AND EXISTS
                               (SELECT 2
                                  FROM load_file_sql s
                                 WHERE     s.lfs_lfv = lfv.lfv_id
                                       AND s.lfs_tp = 'L'
                                       AND s.lfs_st = 'A')
                UNION ALL
                SELECT lfd.lfd_id,
                       lfv.lfv_id,
                       lfd.lfd_file_name,
                       1     AS is_first,
                       1     AS is_last
                  FROM load_file_data  lfd
                       JOIN load_file_version lfv
                           ON lfv.lfv_lft = lfd.lfd_lft AND lfv.lfv_st = 'A'
                 WHERE     lfd.lfd_id = p_lfd_id
                       AND lfd.lfd_st IN ('L')
                       AND (   EXISTS
                                   (SELECT 1
                                      FROM load_file_data_pars lfdp
                                     WHERE lfdp.lfdp_lfd = lfd.lfd_id)
                            OR (lfv.lfv_lfpt = 0))
                       AND EXISTS
                               (SELECT 2
                                  FROM load_file_sql s
                                 WHERE     s.lfs_lfv = lfv.lfv_id
                                       AND s.lfs_tp = 'L'
                                       AND s.lfs_st = 'A')
                ORDER BY 1)
        LOOP
            l_file_id := iii.lfd_id;
            l_ver_id := iii.lfv_id;

            SetFileState (p_lfd_id => iii.lfd_id, p_lfd_st => 'L');
            InsertLog (
                p_lfd_id,
                'Завантаження файу ' || iii.lfd_file_name || ' розпочато',
                'U');

            -- в цикле выполняем последовательно запросы по данной версии загрузки
            FOR rec
                IN (  SELECT *
                        FROM load_file_sql s
                       WHERE     s.lfs_lfv = l_ver_id
                             AND s.lfs_tp = 'L'
                             AND s.lfs_st = 'A'
                             AND s.lfs_4first <= iii.is_first
                             AND s.lfs_4last <= iii.is_last
                    ORDER BY s.lfs_ord)
            LOOP
                l_sql_str := rec.lfs_sql;

                -- для каждого запроса делаем замены
                FOR cur IN (  SELECT *
                                FROM load_file_sql_replace r
                               WHERE r.lfsr_lfv = l_ver_id AND r.lfsr_st = 'A'
                            ORDER BY LENGTH (r.lfsr_src) DESC)
                LOOP
                    l_sql_str :=
                        REPLACE (l_sql_str, cur.lfsr_src, cur.lfsr_trg);
                END LOOP;

                BEGIN
                    InsertLog (p_lfd_id, rec.lfs_ord, 'T');
                    InsertLog (p_lfd_id, l_sql_str, 'T');
                    InsertLog (p_lfd_id, l_file_id, 'T');

                    --выполнение запроса
                    EXECUTE IMMEDIATE l_sql_str
                        USING IN l_file_id;

                    InsertLog (p_lfd_id, SQL%ROWCOUNT, 'T');
                    InsertLog (
                        p_lfd_id,
                        TRIM (
                               'Крок '
                            || rec.lfs_ord
                            || ' обробки файлу '
                            || iii.lfd_file_name
                            || ' виконано'
                            || CASE
                                   WHEN rec.lfs_comment IS NOT NULL THEN ' ('
                               END
                            || rec.lfs_comment
                            || CASE
                                   WHEN rec.lfs_comment IS NOT NULL THEN ')'
                               END),
                        'U');
                END;
            END LOOP;

            -- устанавливаем статус для вложенного файла
            SetFileState (p_lfd_id => l_file_id, p_lfd_st => 'F');
            InsertLog (
                p_lfd_id,
                'Завантаження файлу ' || iii.lfd_file_name || ' завершено',
                'U');
        END LOOP;

        --окончательно обновляем состояние завантаження по общему файлу
        IF p_lfd_id <> COALESCE (l_file_id, -1)
        THEN
            SetFileState (p_lfd_id => p_lfd_id, p_lfd_st => 'F');
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            -- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            -- При ошибке устанавливаем статус ошибки для файла что контролировался и для всего общего файла
            SetFileState (p_lfd_id => l_file_id, p_lfd_st => 'R');
            InsertLog (
                p_lfd_id,
                TRIM (
                    REPLACE (DBMS_UTILITY.format_error_stack,
                             'ORA-20000:',
                             '')),
                'P',
                'R');

            IF p_lfd_id <> l_file_id
            THEN
                SetFileState (p_lfd_id => p_lfd_id, p_lfd_st => 'R');
            END IF;

            ExceptionLog (
                package_name,
                'StartProcessLoad',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace,
                p_lfd_id);
    END;

    -- Призначення: Вивантаження через web-додаток файлу;
    -- Параметри:   ІД файлу ;
    -- Примітка: перенести до пакету LOAD_FILE_WEB
    PROCEDURE DownloadContent (p_lfd_id IN load_file_data.lfd_id%TYPE)
    IS
        l_file_name   load_file_data.lfd_file_name%TYPE;
        l_mime_type   load_file_data.lfd_mime_type%TYPE;
        l_content     load_file_data_content.content%TYPE;
    BEGIN
        IF (p_lfd_id IS NOT NULL)
        THEN
            BEGIN
                SELECT lfd.lfd_file_name, lfd.lfd_mime_type, lfdc.content
                  INTO l_file_name, l_mime_type, l_content
                  FROM load_file_data  lfd
                       JOIN load_file_data_content lfdc
                           ON lfdc.lfdc_lfd = lfd.lfd_id
                 WHERE lfd.lfd_id = p_lfd_id;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    l_content := NULL;
            END;

            IF (DBMS_LOB.getlength (l_content) > 0)
            THEN
                HTP.p (
                       'Content-Type: '
                    || l_mime_type
                    || '; name="'
                    || l_file_name
                    || '"');
                HTP.p (
                       'Content-Disposition: attachment; filename="'
                    || l_file_name
                    || '"');
                HTP.p ('Content-Length: ' || DBMS_LOB.getlength (l_content));
                HTP.p ('');

                WPG_DOCLOAD.download_file (l_content);
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionLog (
                package_name,
                'DownloadContent',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- Призначення:
    -- Параметри:   ;
    FUNCTION GetPrmValues (p_code IN paramsexch.prm_code%TYPE)
        RETURN paramsexch.prm_value%TYPE
    IS
        l_result   paramsexch.prm_value%TYPE;
    BEGIN
        l_result := '';

        SELECT p.prm_value
          INTO l_result
          FROM paramsexch p
         WHERE p.prm_code = p_code;

        RETURN l_result;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN '';
    END;

    FUNCTION GetFullTime
        RETURN VARCHAR2
    IS
        l_result   VARCHAR2 (22);
    BEGIN
        l_result := '';

        SELECT ' - ' || TO_CHAR (SYSDATE, 'dd.mm.yyyy hh24:mi:ss')
          INTO l_result
          FROM DUAL;

        RETURN l_result;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN '';
    END;

    -- Призначення:
    -- Параметри:   ;
    PROCEDURE DnetStart (plfd NUMBER DEFAULT NULL)
    IS
        l_runing   SMALLINT := 1;
        l_jb       NUMBER;
    BEGIN
        BEGIN
            l_runing := GetPrmValues ('LOAD_AUTO_JOB_IS');
        EXCEPTION
            WHEN OTHERS
            THEN
                l_runing := 0;
        END;

        IF l_runing = 1
        THEN
            -- загрузка файлов
            -- LOAD_FILE_LOADER.RegisterProcess
            FOR rlfd IN (  SELECT lfd.lfd_id, lfd.lfd_st
                             FROM load_file_data lfd
                                  JOIN paramsexch prm
                                      ON     prm.prm_code IN
                                                 ('LOAD_FILE_PARS_IS',
                                                  'LOAD_FILE_CNTR_IS',
                                                  'LOAD_FILE_LOAD_IS',
                                                  'LOAD_FILE_CJB_IS')
                                         AND prm.prm_value = '1'
                                         AND CASE
                                                 WHEN lfd.lfd_st IN ('A', 'I')
                                                 THEN
                                                     'LOAD_FILE_PARS_IS'
                                                 WHEN lfd.lfd_st IN ('C')
                                                 THEN
                                                     'LOAD_FILE_CNTR_IS'
                                                 WHEN lfd.lfd_st IN ('V')
                                                 THEN
                                                     'LOAD_FILE_LOAD_IS'
                                             END =
                                             prm.prm_code
                            WHERE     lfd.lfd_st IN ('A',
                                                     'I',
                                                     'C',
                                                     'V')
                                  AND lfd.lfd_lfd IS NULL
                                  AND lfd.lfd_id = COALESCE (plfd, lfd.lfd_id)
                         ORDER BY lfd_id)
            LOOP
                CASE
                    WHEN rlfd.lfd_st IN ('A', 'I')
                    THEN
                        load_file_loader.RegisterProcess (l_jb,
                                                          rlfd.lfd_id,
                                                          0);
                    WHEN rlfd.lfd_st IN ('C')
                    THEN
                        load_file_loader.RegisterProcessControl (l_jb,
                                                                 rlfd.lfd_id,
                                                                 0);
                    WHEN rlfd.lfd_st IN ('V')
                    THEN
                        load_file_loader.RegisterProcessLoad (l_jb,
                                                              rlfd.lfd_id,
                                                              0);
                END CASE;
            END LOOP;

            IF GetPrmValues ('LOAD_FILE_CJB_IS') = '1'
            THEN
                -- запускаем ли модуль обновления статусов заданий
                load_file_jbl.controljobs;
            END IF;
        -- поставлено на расписание, запускается раз в 5 минут, ожидание віключено
        END IF;
    END;

    PROCEDURE DeleteLfd (p_lfd NUMBER)
    IS
    BEGIN
        DELETE FROM load_file_protocol p
              WHERE p.lfp_lfd IN (SELECT lfd_id
                                    FROM load_file_data lfd
                                   WHERE COALESCE (lfd_lfd, lfd_id) = p_lfd);

        DELETE FROM load_file_data_jobs j
              WHERE j.lfdj_lfd IN (SELECT lfd_id
                                     FROM load_file_data lfd
                                    WHERE COALESCE (lfd_lfd, lfd_id) = p_lfd);

        DELETE FROM load_file_data_log l
              WHERE l.lfdl_lfd IN (SELECT lfd_id
                                     FROM load_file_data lfd
                                    WHERE COALESCE (lfd_lfd, lfd_id) = p_lfd);

        DELETE FROM load_file_data_log l
              WHERE l.lfdl_lfd IN (SELECT lfd_id
                                     FROM load_file_data lfd
                                    WHERE COALESCE (lfd_lfd, lfd_id) = p_lfd);

        DELETE FROM ls_data_ref r
              WHERE r.ldr_lfdp IN
                        (SELECT p.lfdp_id
                           FROM load_file_data_pars p
                          WHERE p.lfdp_lfd IN
                                    (SELECT lfd_id
                                       FROM load_file_data lfd
                                      WHERE COALESCE (lfd_lfd, lfd_id) =
                                            p_lfd));

        DELETE FROM load_file_data_pars p
              WHERE p.lfdp_lfd IN (SELECT lfd_id
                                     FROM load_file_data lfd
                                    WHERE COALESCE (lfd_lfd, lfd_id) = p_lfd);

        DELETE FROM load_file_data_content l
              WHERE l.lfdc_lfd IN (SELECT lfd_id
                                     FROM load_file_data lfd
                                    WHERE COALESCE (lfd_lfd, lfd_id) = p_lfd);

        DELETE FROM load_file_data lfd
              WHERE COALESCE (lfd_lfd, lfd_id) = p_lfd;
    END;

    -- info:   створення нової секції в таблиці load_file_data_pars
    -- params: p_table_name - назва таблиці
    --         p_part_val - ключ секціювання по списку (partition)
    --         p_subpart_val - ключ секціювання по списку (subpartition)
    -- note:
    PROCEDURE Add_Table_Section (p_table_name    IN VARCHAR2,
                                 p_part_val         VARCHAR2,
                                 p_subpart_val      VARCHAR2)
    IS
    BEGIN
        IF     UPPER (p_table_name) = 'LOAD_FILE_DATA_PARS'
           AND TRIM (p_part_val) IS NOT NULL
           AND TRIM (p_subpart_val) IS NOT NULL
        THEN
            BEGIN
                --1. спроба додати subpartition в існуючу partition
                EXECUTE IMMEDIATE   'ALTER TABLE USS_EXCH.'
                                 || p_table_name
                                 || ' MODIFY PARTITION PART_'
                                 || p_part_val
                                 || ' ADD SUBPARTITION PART_'
                                 || p_part_val
                                 || '_'
                                 || p_subpart_val
                                 || ' VALUES ('
                                 || p_subpart_val
                                 || ')';
            --при виникненні помилки - можливо partition не існує
            EXCEPTION
                WHEN OTHERS
                THEN
                    --2. спроба створити partition та subpartition
                    EXECUTE IMMEDIATE   'ALTER TABLE USS_EXCH.'
                                     || p_table_name
                                     || ' ADD PARTITION PART_'
                                     || p_part_val
                                     || ' VALUES('
                                     || p_part_val
                                     || ') (SUBPARTITION PART_'
                                     || p_part_val
                                     || '_'
                                     || p_subpart_val
                                     || ' VALUES ('
                                     || p_subpart_val
                                     || '))';
            END;
        END IF;
    END;
BEGIN
    -- Initialization
    p_lfdl_user_id := uss_exch_context.getcontext ('uid');
END;
/