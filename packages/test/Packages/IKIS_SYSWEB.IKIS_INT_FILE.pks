/* Formatted on 8/12/2025 6:11:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.IKIS_INT_FILE
IS
    -- Author  : ivashchuk
    -- Created : 17.08.2016 14:30:00
    -- Purpose : Пакет функцій управління внутрішніми файлами
    -- Установлен только на mil и retro

    -- конвертація  base10 в base35
    FUNCTION decimal2base35 (p_number IN INTEGER)
        RETURN VARCHAR2;

    -- генерація ідентифікатора файла
    FUNCTION gen_file_idn (
        p_wfs_code   W_FILE$INFO.WF_WFS_CODE%TYPE,
        p_file_idn   W_FILE$INFO.WF_FILE_IDN%TYPE DEFAULT '')
        RETURN VARCHAR2;

    -- отримання файла по ідентифікатору
    FUNCTION getFile (p_file_idn W_FILE$INFO.WF_FILE_IDN%TYPE)
        RETURN BLOB;

    -- отримання інфо файла по ідентифікатору
    PROCEDURE getFileInfo (
        p_file_idn         IN     W_FILE$INFO.WF_FILE_IDN%TYPE,
        p_wfs_code            OUT v_w_file$info.wf_wfs_code%TYPE,
        p_filename            OUT v_w_file$info.WF_FILENAME%TYPE,
        p_org                 OUT v_w_file$info.com_org%TYPE,
        p_wu                  OUT v_w_file$info.WF_WU%TYPE,
        p_file_upload_dt      OUT W_FILE$INFO.WF_UPLOAD_DT%TYPE);

    -- запис файла
    FUNCTION putFile (
        p_wfs_code    IN v_w_file$info.wf_wfs_code%TYPE,
        p_filename    IN v_w_file$info.WF_FILENAME%TYPE,
        p_org         IN v_w_file$info.com_org%TYPE DEFAULT NULL,
        p_wu          IN v_w_file$info.WF_WU%TYPE DEFAULT NULL,
        p_file_data   IN BLOB)
        RETURN v_w_file$info.wf_file_idn%TYPE;
END IKIS_INT_FILE;
/


/* Formatted on 8/12/2025 6:11:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.IKIS_INT_FILE
IS
    msgCOMMON_EXCEPTION   NUMBER := 2;

    -- конвертація  base10 в base35
    FUNCTION decimal2base35 (p_number IN INTEGER)
        RETURN VARCHAR2
    IS
        charList   VARCHAR2 (35) := '123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        v_number   INTEGER := p_number;
        v_base     INTEGER := 35;
        v_Return   VARCHAR2 (100) := NULL;
        n_Cnt      INTEGER := 0;
        n_Val      INTEGER := 0;
    BEGIN
        IF (v_number = 0)
        THEN
            RETURN '1';
        END IF;

        v_Return := '';
        n_Cnt := 0;

        WHILE (v_number <> 0)
        LOOP
            n_Val :=
                MOD (v_number, (v_base ** (n_Cnt + 1))) / (v_base ** n_cnt);
            v_number := v_number - (n_Val * (v_base ** n_Cnt));
            v_Return := SUBSTR (charList, n_Val + 1, 1) || v_Return;
            n_Cnt := n_Cnt + 1;
        END LOOP;

        RETURN v_Return;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    -- генерація ідентифікатора файла
    FUNCTION gen_file_idn (
        p_wfs_code   W_FILE$INFO.WF_WFS_CODE%TYPE,
        p_file_idn   W_FILE$INFO.WF_FILE_IDN%TYPE DEFAULT '')
        RETURN VARCHAR2
    IS
        l_curval     NUMBER;
        l_file_idn   VARCHAR2 (15);
    BEGIN
        BEGIN
            IF NVL (p_file_idn, '') <> ''
            THEN
                RETURN p_file_idn;
            ELSE
                SELECT IKIS_SYSWEB.SQ_ID_WF_FILE_IDN.NEXTVAL
                  INTO l_curval
                  FROM DUAL;
            END IF;
        EXCEPTION
            WHEN OTHERS
            THEN
                SELECT IKIS_SYSWEB.SQ_ID_WF_FILE_IDN.NEXTVAL
                  INTO l_curval
                  FROM DUAL;
        END;

        l_file_idn :=
            UPPER (
                p_wfs_code || '-' || LPAD (decimal2base35 (l_curval), 9, '0'));
        RETURN l_file_idn;
    END;

    PROCEDURE SetFileToRecover (p_wf_id w_file$info.wf_id%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE w_file$info
           SET wf_st = 'V', wf_recovery_dt = NULL
         WHERE     wf_is_archived = 'Y'
               AND wf_st = 'A'
               AND NOT EXISTS
                       (SELECT 1
                          FROM w_file$download
                         WHERE wfd_wf = wf_id);

        COMMIT;
    END;

    -- отримання файла по ідентифікатору
    FUNCTION getFile (p_file_idn W_FILE$INFO.WF_FILE_IDN%TYPE)
        RETURN BLOB
    IS
        l_file_id     v_w_file$info.wf_id%TYPE;
        l_file_data   BLOB;
        l_wf_st       w_file$info.wf_st%TYPE;
    BEGIN
        IF     LENGTH (p_file_idn) = 15
           AND REGEXP_LIKE (SUBSTR (p_file_idn, 1, 5), '^[0-9A-Za-z]{5}$')
           AND REGEXP_LIKE (SUBSTR (p_file_idn, 7, 9), '^[0-9A-Za-z]{9}$')
           AND SUBSTR (p_file_idn, 6, 1) = '-'
        THEN
            SELECT wf_id, wf_st
              INTO l_file_id, l_wf_st
              FROM ikis_sysweb.v_w_file$info
             WHERE wf_file_idn = p_file_idn;

            IF l_file_id IS NOT NULL
            THEN
                BEGIN
                    SELECT wfd_file_body
                      INTO l_file_data
                      FROM ikis_sysweb.v_w_file$download
                     WHERE wfd_wf = l_file_id;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        --Якщо дані файлу не знайшлись та стан файлу "переміщено в архів" пробуємо його звідти дочекатись.
                        IF l_wf_st = 'A'
                        THEN
                            SetFileToRecover (l_file_id);
                            IKIS_SYS.IKIS_LOCK.Sleep (p_sec => 1);

                            BEGIN
                                SELECT wfd_file_body
                                  INTO l_file_data
                                  FROM ikis_sysweb.v_w_file$download
                                 WHERE wfd_wf = l_file_id;
                            EXCEPTION
                                WHEN NO_DATA_FOUND
                                THEN
                                    raise_application_error (
                                        -20000,
                                        'За 1 сек файл не відновлено, спробуйте ще через декілька секунд!');
                            END;
                        ELSE
                            raise_application_error (
                                -20000,
                                'Помилка пошуку файлу, необхідно звернутись до адміністратора БД!');
                        END IF;
                END;
            END IF;
        END IF;

        RETURN l_file_data;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_INT_FILE.getFile:',
                       SQLERRM
                    || CHR (10)
                    || DBMS_UTILITY.format_error_stack
                    || DBMS_UTILITY.format_error_backtrace));
    END;

    -- отримання інфо файла по ідентифікатору
    PROCEDURE getFileInfo (
        p_file_idn         IN     W_FILE$INFO.WF_FILE_IDN%TYPE,
        p_wfs_code            OUT v_w_file$info.wf_wfs_code%TYPE,
        p_filename            OUT v_w_file$info.WF_FILENAME%TYPE,
        p_org                 OUT v_w_file$info.com_org%TYPE,
        p_wu                  OUT v_w_file$info.WF_WU%TYPE,
        p_file_upload_dt      OUT W_FILE$INFO.WF_UPLOAD_DT%TYPE)
    IS
        l_file_id     v_w_file$info.wf_id%TYPE;
        l_file_data   BLOB;
    BEGIN
        IF NVL (p_file_idn, '') = ''
        THEN
            raise_application_error (-20000,
                                     'File not found: ' || p_file_idn);
        ELSE
            SELECT wf_wfs_code,
                   wf_filename,
                   com_org,
                   wf_wu,
                   wf_upload_dt
              INTO p_wfs_code,
                   p_filename,
                   p_org,
                   p_wu,
                   p_file_upload_dt
              FROM ikis_sysweb.v_w_file$info
             WHERE wf_file_idn = p_file_idn;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_INT_FILE.getFileInfo:',
                       SQLERRM
                    || CHR (10)
                    || DBMS_UTILITY.format_error_stack
                    || DBMS_UTILITY.format_error_backtrace));
    END;

    -- запис файла
    FUNCTION putFile (
        p_wfs_code    IN v_w_file$info.wf_wfs_code%TYPE,
        p_filename    IN v_w_file$info.WF_FILENAME%TYPE,
        p_org         IN v_w_file$info.com_org%TYPE DEFAULT NULL,
        p_wu          IN v_w_file$info.WF_WU%TYPE DEFAULT NULL,
        p_file_data   IN BLOB)
        RETURN v_w_file$info.wf_file_idn%TYPE
    IS
        l_filename   VARCHAR2 (4000);
        l_cnt        NUMBER := 0;
        l_file_id    v_w_file$info.wf_id%TYPE;
        l_org        v_w_file$info.com_org%TYPE;
        l_file_idn   v_w_file$info.wf_file_idn%TYPE;
    BEGIN
        l_filename :=
            TRIM (
                UPPER (
                    SUBSTR (REPLACE (p_filename, '\', '/'),
                            INSTR (p_filename, '/') + 1,
                            10000)));

        --SELECT COUNT(1) INTO l_cnt FROM w_file$info WHERE wf_filename = l_filename;

        IF l_cnt > 0
        THEN
            raise_application_error (-20000,
                                     'File already uploaded: ' || l_filename);
        ELSIF    p_wfs_code IS NULL
              OR LENGTH (p_wfs_code) != 5
              OR NOT REGEXP_LIKE (p_wfs_code, '^[0-9A-Za-z]{5}$')
        THEN
            raise_application_error (
                -20000,
                'Subsystem code is not correct: ' || p_wfs_code);
        ELSE
            l_file_idn := gen_file_idn (p_wfs_code => p_wfs_code);

            INSERT INTO ikis_sysweb.v_w_file$info (wf_id,
                                                   wf_filename,
                                                   wf_st,
                                                   wf_upload_dt,
                                                   com_org,
                                                   wf_wu,
                                                   wf_wfs_code,
                                                   wf_file_idn,
                                                   wf_is_archived)
                 VALUES (0,
                         p_filename,
                         'L',
                         SYSDATE,
                         p_org,
                         p_wu,
                         p_wfs_code,
                         l_file_idn,
                         'N')
              RETURNING wf_id
                   INTO l_file_id;

            INSERT INTO ikis_sysweb.v_w_file$download (wfd_id,
                                                       wfd_wf,
                                                       wfd_file_body)
                 VALUES (0, l_file_id, p_file_data);

            RETURN l_file_idn;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    msgCOMMON_EXCEPTION,
                    'IKIS_INT_FILE.putFile:',
                       SQLERRM
                    || CHR (10)
                    || DBMS_UTILITY.format_error_stack
                    || DBMS_UTILITY.format_error_backtrace));
    END;
END IKIS_INT_FILE;
/