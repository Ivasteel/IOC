/* Formatted on 8/12/2025 6:11:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.REPORTFL_ENGINE_EX
IS
    -- Author  : VANO
    -- Created : 28.09.2017 10:59:12
    -- Purpose : Функції роботи з побудовником звітів .net

    --Збереження повідомлення
    PROCEDURE SaveMessage (p_jbr_id       w_jobs_reports.jbr_id%TYPE,
                           p_jp_tp        w_jbr_protocol.jp_tp%TYPE,
                           p_jp_message   w_jbr_protocol.jp_message%TYPE);

    --Ініціалізація побудови звіту на основі шаблону (звіт переходить в стан INIT)
    FUNCTION InitReport (
        p_jbr_app_ident      w_jobs_reports.jbr_app_ident%TYPE,
        p_jbr_rpt_code       w_jobs_reports.jbr_rpt_code%TYPE,
        p_jbr_rpt_template   w_jobs_reports.jbr_rpt_template%TYPE,
        p_jbr_ss_code        w_jobs_reports.jbr_ss_code%TYPE,
        p_jbr_user           w_jobs_reports.jbr_user%TYPE,
        p_tmpl_id            DECIMAL:= NULL,
        p_rpt_name           VARCHAR2 DEFAULT NULL)
        RETURN w_jobs_reports.jbr_id%TYPE;

    --Додавання скрипта підготовки даних (виконуватимуться в порядку вставки в одному з'єднанні з БД). Без параметрів. Контекст виконання - користувача, що визвав побудову звіту
    PROCEDURE AddScript (p_jbr_id        w_jobs_reports.jbr_id%TYPE,
                         p_script_name   VARCHAR2,
                         p_script_text   VARCHAR2);

    --Додавання константи
    PROCEDURE AddParam (p_jbr_id        w_jobs_reports.jbr_id%TYPE,
                        p_param_name    VARCHAR2,
                        p_param_value   VARCHAR2);

    --Додавання набору даних у вигляді запиту
    PROCEDURE AddDataSet (p_jbr_id    w_jobs_reports.jbr_id%TYPE,
                          p_dataset   VARCHAR2,
                          p_sql       VARCHAR2);

    --Додавання пов'язаних наборів даних
    PROCEDURE AddRelation (p_jbr_id       w_jobs_reports.jbr_id%TYPE,
                           pMaster        VARCHAR2,
                           pMasterField   VARCHAR2,
                           pDetail        VARCHAR2,
                           pDetailField   VARCHAR2);

    --Додавання саммарі
    PROCEDURE AddSummary (p_jbr_id   w_jobs_reports.jbr_id%TYPE,
                          pDataSet   VARCHAR2,
                          pField     VARCHAR2,
                          pType      VARCHAR2,
                          pFormat    VARCHAR2);

    --Встановлення кастомного імені файлу
    PROCEDURE SetFileName (p_jbr_id      w_jobs_reports.jbr_id%TYPE,
                           p_file_name   VARCHAR2);

    --Отримання встановленого імені файлу
    FUNCTION GetFileName (p_jbr_id w_jobs_reports.jbr_id%TYPE)
        RETURN VARCHAR2;

    --Отримання параметрів звіту
    PROCEDURE GetReportParams (p_jbr_id       w_jobs_reports.jbr_id%TYPE,
                               p_params   OUT SYS_REFCURSOR);

    --Перевірка стану звіту на завершеність (чи звіт в стані ENDED)
    FUNCTION IsReportProcessed (p_jbr_id w_jobs_reports.jbr_id%TYPE)
        RETURN BOOLEAN;

    --Зміна стану звіту на "готовий для обробки в сервері додатків" - тільки для ініціалізованих (звіт переходить в стан READY)
    PROCEDURE PutReportToWorkingQueue (p_jbr_id w_jobs_reports.jbr_id%TYPE);

    --Отримання разультату побудови звіту (тільки завершених)
    FUNCTION GetReportResult (p_jbr_id w_jobs_reports.jbr_id%TYPE)
        RETURN BLOB;

    --Побудова звіту: виконується зміна статусу запису для можливості роботи серверу додатків та виконується очікування завершення побудови завіту (звіт переходить в стан READY)
    FUNCTION PublishReportBlob (p_jbr_id w_jobs_reports.jbr_id%TYPE)
        RETURN BLOB;

    --Збереження результату побудови звіту (звіт переходить в стан ENDED)
    PROCEDURE SaveReportResult (
        p_jbr_id           w_jobs_reports.jbr_id%TYPE,
        p_jbr_rpt_result   w_jobs_reports.jbr_rpt_result%TYPE);

    --Збереження помилки побудови звіту (звіт переходить в стан ERROR)
    PROCEDURE SaveReportError (
        p_jbr_id          w_jobs_reports.jbr_id%TYPE,
        p_error_message   w_jbr_protocol.jp_message%TYPE);

    --Отримання стану звіту для можливості побудови інформаційної сторінки про звіт
    PROCEDURE GetReportInfo (
        p_jbr_id                ikis_sysweb.w_jobs_reports.jbr_id%TYPE,
        p_report_data       OUT SYS_REFCURSOR,
        p_report_protocol   OUT SYS_REFCURSOR);

    --Отримання разультату побудови звіту (тільки завершених)
    FUNCTION GetReportUser (p_jbr_id w_jobs_reports.jbr_id%TYPE)
        RETURN w_jobs_reports.jbr_user%TYPE;

    --Отримання ідентифікатора шаблону для звіту
    PROCEDURE GetReportInfoSimpl (
        p_jbr_id            ikis_sysweb.w_jobs_reports.jbr_id%TYPE,
        p_jbr_stop_dt   OUT ikis_sysweb.w_jobs_reports.jbr_stop_dt%TYPE,
        p_jbr_tmpl_id   OUT ikis_sysweb.w_jobs_reports.jbr_tmpl_id%TYPE);

    --Очищення BLOB-ів з задач, які старші за строк збереження
    PROCEDURE clean_old_jobs;
END REPORTFL_ENGINE_EX;
/


CREATE OR REPLACE SYNONYM RTFL_PROXY.REPORTFL_ENGINE_EX FOR IKIS_SYSWEB.REPORTFL_ENGINE_EX
/


GRANT EXECUTE ON IKIS_SYSWEB.REPORTFL_ENGINE_EX TO II01RC_SYSWEB_COMM
/

GRANT EXECUTE ON IKIS_SYSWEB.REPORTFL_ENGINE_EX TO IKIS_RBM
/

GRANT EXECUTE ON IKIS_SYSWEB.REPORTFL_ENGINE_EX TO IKIS_WEBPROXY
/

GRANT EXECUTE ON IKIS_SYSWEB.REPORTFL_ENGINE_EX TO RTFL_PROXY
/

GRANT EXECUTE ON IKIS_SYSWEB.REPORTFL_ENGINE_EX TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.REPORTFL_ENGINE_EX TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.REPORTFL_ENGINE_EX TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.REPORTFL_ENGINE_EX TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.REPORTFL_ENGINE_EX TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.REPORTFL_ENGINE_EX TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.REPORTFL_ENGINE_EX TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.REPORTFL_ENGINE_EX TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.REPORTFL_ENGINE_EX TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:11:46 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.REPORTFL_ENGINE_EX
IS
    msgCOMMON_EXCEPTION   NUMBER := 2;

    --Збереження повідомлення
    PROCEDURE SaveMessage (p_jbr_id       w_jobs_reports.jbr_id%TYPE,
                           p_jp_tp        w_jbr_protocol.jp_tp%TYPE,
                           p_jp_message   w_jbr_protocol.jp_message%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO w_jbr_protocol (jp_ts,
                                    jp_tp,
                                    jp_message,
                                    jp_jbr)
             VALUES (SYSDATE,
                     p_jp_tp,
                     p_jp_message,
                     p_jbr_id);

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                   'Помилка в REPORTGL_ENGINE_EX.SaveMessage:'
                || CHR (10)
                || SQLERRM
                || '-'
                || p_jp_message);
    END;

    --Ініціалізація побудови звіту на основі шаблону
    FUNCTION InitReport (
        p_jbr_app_ident      w_jobs_reports.jbr_app_ident%TYPE,
        p_jbr_rpt_code       w_jobs_reports.jbr_rpt_code%TYPE,
        p_jbr_rpt_template   w_jobs_reports.jbr_rpt_template%TYPE,
        p_jbr_ss_code        w_jobs_reports.jbr_ss_code%TYPE,
        p_jbr_user           w_jobs_reports.jbr_user%TYPE,
        p_tmpl_id            DECIMAL:= NULL,
        p_rpt_name           VARCHAR2 DEFAULT NULL)
        RETURN w_jobs_reports.jbr_id%TYPE
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_id   w_jobs_reports.jbr_id%TYPE;
    BEGIN
        INSERT INTO w_jobs_reports (jbr_app_ident,
                                    jbr_rpt_code,
                                    jbr_rpt_template,
                                    jbr_status,
                                    jbr_start_dt,
                                    jbr_user,
                                    jbr_ss_code,
                                    jbr_tmpl_id)
             VALUES (p_jbr_app_ident,
                     p_jbr_rpt_code,
                     p_jbr_rpt_template,
                     'INIT',
                     SYSDATE,
                     p_jbr_user,
                     p_jbr_ss_code,
                     p_tmpl_id)
          RETURNING jbr_id
               INTO l_id;

        COMMIT;
        SaveMessage (
            l_id,
            'I',
               'Ініціалізовано побудову звіту <'
            || NVL (p_rpt_name, p_jbr_rpt_code)
            || '> за шаблоном з прикладним Ід <'
            || NVL (p_jbr_app_ident, ' ')
            || '>');

        ikis_sys.ikis_audit.WriteMsg (
            'ACC_RPT_BUILD',
               'Ініціалізовано побудову звіту <'
            || p_jbr_rpt_code
            || '> за шаблоном з прикладним Ід <'
            || NVL (p_jbr_app_ident, ' ')
            || '>. id задачі = '
            || l_id);
        RETURN l_id;
    END;

    --Додавання скрипта підготовки даних (виконуватимуться в порядку вставки в одному з'єднанні з БД). Без параметрів. Контекст виконання - користувача, що визвав побудову звіту
    PROCEDURE AddScript (p_jbr_id        w_jobs_reports.jbr_id%TYPE,
                         p_script_name   VARCHAR2,
                         p_script_text   VARCHAR2)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO w_jobs_rpt_params (jbp_jbr,
                                       jbp_tp,
                                       jbp_name,
                                       jbp_value)
             VALUES (p_jbr_id,
                     'script',
                     p_script_name,
                     p_script_text);

        COMMIT;
    END;

    --Додавання константи
    PROCEDURE AddParam (p_jbr_id        w_jobs_reports.jbr_id%TYPE,
                        p_param_name    VARCHAR2,
                        p_param_value   VARCHAR2)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO w_jobs_rpt_params (jbp_jbr,
                                       jbp_tp,
                                       jbp_name,
                                       jbp_value)
             VALUES (p_jbr_id,
                     'constant',
                     p_param_name,
                     p_param_value);

        COMMIT;
    END;

    --Додавання набору даних у вигляді запиту
    PROCEDURE AddDataSet (p_jbr_id    w_jobs_reports.jbr_id%TYPE,
                          p_dataset   VARCHAR2,
                          p_sql       VARCHAR2)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO w_jobs_rpt_params (jbp_jbr,
                                       jbp_tp,
                                       jbp_name,
                                       jbp_value)
             VALUES (p_jbr_id,
                     'dataset',
                     p_dataset,
                     p_sql);

        COMMIT;
    END;

    --Додавання пов'язаних наборів даних
    PROCEDURE AddRelation (p_jbr_id       w_jobs_reports.jbr_id%TYPE,
                           pMaster        VARCHAR2,
                           pMasterField   VARCHAR2,
                           pDetail        VARCHAR2,
                           pDetailField   VARCHAR2)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO w_jobs_rpt_params (jbp_jbr,
                                       jbp_tp,
                                       jbp_name,
                                       jbp_value)
             VALUES (p_jbr_id,
                     'relation',
                     pMaster,
                     pMasterField || ';' || pDetail || ';' || pDetailField);

        COMMIT;
    END;

    --Додавання саммарі
    PROCEDURE AddSummary (p_jbr_id   w_jobs_reports.jbr_id%TYPE,
                          pDataSet   VARCHAR2,
                          pField     VARCHAR2,
                          pType      VARCHAR2,
                          pFormat    VARCHAR2)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO w_jobs_rpt_params (jbp_jbr,
                                       jbp_tp,
                                       jbp_name,
                                       jbp_value)
             VALUES (p_jbr_id,
                     'summary',
                     pDataSet,
                     pField || ';' || pType || ';' || pFormat);

        COMMIT;
    END;

    --Встановлення кастомного імені файлу
    PROCEDURE SetFileName (p_jbr_id      w_jobs_reports.jbr_id%TYPE,
                           p_file_name   VARCHAR2)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        MERGE INTO w_jobs_rpt_params
             USING (SELECT p_jbr_id        AS x_id,
                           'file_name'     AS x_tp,
                           p_file_name     AS x_file_name
                      FROM DUAL)
                ON (jbp_jbr = x_id AND x_tp = jbp_tp)
        WHEN MATCHED
        THEN
            UPDATE SET jbp_value = x_file_name
        WHEN NOT MATCHED
        THEN
            INSERT     (jbp_jbr,
                        jbp_tp,
                        jbp_name,
                        jbp_value)
                VALUES (p_jbr_id,
                        'file_name',
                        'file_name',
                        p_file_name);

        COMMIT;
    END;

    --Отримання встановленого імені файлу
    FUNCTION GetFileName (p_jbr_id w_jobs_reports.jbr_id%TYPE)
        RETURN VARCHAR2
    IS
        l_file_name   w_jobs_rpt_params.jbp_value%TYPE;
    BEGIN
        SELECT jbp_value
          INTO l_file_name
          FROM ikis_sysweb.w_jobs_rpt_params
         WHERE jbp_jbr = p_jbr_id AND jbp_tp = 'file_name';

        RETURN l_file_name;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
    END;

    --Отримання параметрів звіту
    PROCEDURE GetReportParams (p_jbr_id       w_jobs_reports.jbr_id%TYPE,
                               p_params   OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_params FOR   SELECT jbp_id,
                                   jbp_jbr,
                                   jbp_tp,
                                   jbp_name,
                                   jbp_value
                              FROM w_jobs_rpt_params
                             WHERE jbp_jbr = p_jbr_id
                          ORDER BY jbp_id ASC;
    END;

    --Отримання параметрів звіту (чи звіт в стані ENDED)
    FUNCTION IsReportProcessed (p_jbr_id w_jobs_reports.jbr_id%TYPE)
        RETURN BOOLEAN
    IS
        l_st   w_jobs_reports.jbr_status%TYPE;
    BEGIN
        SELECT jbr_status
          INTO l_st
          FROM w_jobs_reports
         WHERE jbr_id = p_jbr_id;

        RETURN l_st IN ('ENDED');
    END;

    --Зміна стану звіту на "готовий для обробки в сервері додатків" - тільки для ініціалізованих (звіт переходить в стан READY)
    PROCEDURE PutReportToWorkingQueue (p_jbr_id w_jobs_reports.jbr_id%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_cnt   INTEGER;
    BEGIN
        UPDATE w_jobs_reports
           SET jbr_status = 'READY'
         WHERE jbr_status = 'INIT' AND jbr_id = p_jbr_id;

        l_cnt := SQL%ROWCOUNT;
        COMMIT;

        IF l_cnt > 0
        THEN
            SaveMessage (
                p_jbr_id,
                'I',
                   'Звіт <'
                || p_jbr_id
                || '> поставлено в чергу виконання серверу додатків!');
        END IF;
    END;

    --Отримання разультату побудови звіту (тільки завершених)
    FUNCTION GetReportResult (p_jbr_id w_jobs_reports.jbr_id%TYPE)
        RETURN BLOB
    IS
        l_res   w_jobs_reports.jbr_rpt_result%TYPE;
    BEGIN
        SELECT jbr_rpt_result
          INTO l_res
          FROM w_jobs_reports
         WHERE jbr_status = 'ENDED' AND jbr_id = p_jbr_id;

        SaveMessage (p_jbr_id,
                     'I',
                     'Видано дані звіту <' || p_jbr_id || '>!');

        ikis_sys.ikis_audit.WriteMsg (
            'ACC_RPT_BUILD',
            'Видано файл звіту з id задачі = ' || p_jbr_id || '.');

        RETURN l_res;
    END;

    --Побудова звіту: виконується зміна статусу запису для можливості роботи серверу додатків та виконується очікування завершення побудови завіту
    FUNCTION PublishReportBlob (p_jbr_id w_jobs_reports.jbr_id%TYPE)
        RETURN BLOB
    IS
        l_is_ended   BOOLEAN := FALSE;
    BEGIN
        PutReportToWorkingQueue (p_jbr_id);

        WHILE (NOT l_is_ended)
        LOOP
            ikis_lock.Sleep (p_sec => 1 / 5);
            l_is_ended := IsReportProcessed (p_jbr_id);
        END LOOP;

        RETURN GetReportResult (p_jbr_id);
    --  RETURN utl_compress.lz_compress(GetReportResult(p_jbr_id), 6);
    END;

    --Збереження результату побудови звіту (звіт переходить в стан ENDED)
    PROCEDURE SaveReportResult (
        p_jbr_id           w_jobs_reports.jbr_id%TYPE,
        p_jbr_rpt_result   w_jobs_reports.jbr_rpt_result%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE w_jobs_reports
           SET jbr_rpt_result = p_jbr_rpt_result,
               jbr_stop_dt = SYSDATE,
               jbr_status = 'ENDED'
         WHERE jbr_id = p_jbr_id;

        COMMIT;

        SaveMessage (p_jbr_id, 'I', 'Завершено побудову звіту!');
    END;

    --Збереження помилки побудови звіту (звіт переходить в стан ERROR)
    PROCEDURE SaveReportError (
        p_jbr_id          w_jobs_reports.jbr_id%TYPE,
        p_error_message   w_jbr_protocol.jp_message%TYPE)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE w_jobs_reports
           SET jbr_stop_dt = SYSDATE, jbr_status = 'ERROR'
         WHERE jbr_id = p_jbr_id;

        COMMIT;

        SaveMessage (p_jbr_id, 'E', p_error_message);
    END;


    FUNCTION GetReportUser (p_jbr_id w_jobs_reports.jbr_id%TYPE)
        RETURN w_jobs_reports.jbr_user%TYPE
    IS
        l_res   w_jobs_reports.jbr_user%TYPE;
    BEGIN
        SELECT jbr_user
          INTO l_res
          FROM w_jobs_reports
         WHERE jbr_id = p_jbr_id;

        RETURN l_res;
    END;

    --Отримання стану звіту для можливості побудови інформаційної сторінки про звіт
    PROCEDURE GetReportInfo (
        p_jbr_id                ikis_sysweb.w_jobs_reports.jbr_id%TYPE,
        p_report_data       OUT SYS_REFCURSOR,
        p_report_protocol   OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_report_data FOR SELECT jbr_id,
                                      jbr_app_ident,
                                      jbr_rpt_code,
                                      jbr_status,
                                      jbr_start_dt,
                                      jbr_stop_dt,
                                      jbr_ss_code,
                                      jbr_user
                                 FROM w_jobs_reports
                                WHERE jbr_id = p_jbr_id;

        OPEN p_report_protocol FOR SELECT jp_id          AS jm_id,
                                          jp_ts          AS jm_ts,
                                          jp_tp          AS jm_tp,
                                          jp_message     AS jm_message,
                                          jp_jbr         AS jm_jbr
                                     FROM w_jbr_protocol
                                    WHERE jp_jbr = p_jbr_id;
    END;

    --Отримання ідентифікатора шаблону для звіту
    PROCEDURE GetReportInfoSimpl (
        p_jbr_id            ikis_sysweb.w_jobs_reports.jbr_id%TYPE,
        p_jbr_stop_dt   OUT ikis_sysweb.w_jobs_reports.jbr_stop_dt%TYPE,
        p_jbr_tmpl_id   OUT ikis_sysweb.w_jobs_reports.jbr_tmpl_id%TYPE)
    IS
        l_tmpl_id   DECIMAL;
    BEGIN
        SELECT jbr_tmpl_id, jbr_stop_dt
          INTO p_jbr_tmpl_id, p_jbr_stop_dt
          FROM w_jobs_reports
         WHERE jbr_id = p_jbr_id;
    END;

    --Очищення BLOB-ів з задач, які старші за строк збереження
    PROCEDURE clean_old_jobs
    IS
        l_cnt            INTEGER;
        l_store_months   INTEGER;
        l_tmp            VARCHAR2 (255);
        l_lock_clean     ikis_sys.ikis_lock.t_lockhandler;
    BEGIN
        ikis_sys.ikis_lock.request_lock (
            'RTFL_BLOB_CLEAN',
            NULL,
            'В даний момент вже виконується регламентне очищення старих задач!',
            l_lock_clean,
            DBMS_LOCK.x_mode,
            1,
            FALSE);

        --Проставляємо час останнього
        ikis_parameter_util.SetParameter (
            'RTFL_BLOB_LAST_CLEAN',
            'IKIS_SYSWEB',
            TO_CHAR (SYSDATE, 'DD.MM.YYYY HH24:MI:SS'));
        l_tmp :=
            ikis_parameter_util.GetParameter ('RTFL_RPT_STORE_MONTHS',
                                              'IKIS_SYSWEB');
        l_store_months := TO_NUMBER (l_tmp);

        INSERT INTO tmp_work_ids (x_id)
            SELECT jbr_id
              FROM w_jobs_reports
             WHERE     jbr_start_dt < ADD_MONTHS (SYSDATE, -l_store_months)
                   AND (   jbr_rpt_result IS NOT NULL
                        OR jbr_rpt_result IS NOT NULL);

        DBMS_OUTPUT.put_line (
               TO_CHAR (SYSDATE, 'DD.MM.YYYY HH24:MI:SS')
            || ': total='
            || SQL%ROWCOUNT);

        l_cnt := 1;

        FOR xx IN (SELECT x_id AS job_to_clean FROM tmp_work_ids)
        LOOP
            l_tmp := xx.job_to_clean;

            UPDATE w_jobs_reports
               SET jbr_rpt_result = NULL, jbr_rpt_template = NULL
             WHERE jbr_id = xx.job_to_clean;

            INSERT INTO w_jbr_protocol (jp_ts,
                                        jp_tp,
                                        jp_message,
                                        jp_jbr)
                     VALUES (
                                SYSDATE,
                                'I',
                                'Файли звіту видалено під час регламентної операції очищення',
                                xx.job_to_clean);

            --SaveMessage(xx.job_to_clean, 'I', 'Файли звіту видалено під час регламентної операції очищення');

            l_cnt := l_cnt + 1;

            IF l_cnt > 100
            THEN
                --dbms_output.put_line(to_char(sysdate, 'DD.MM.YYYY HH24:MI:SS')||': +100');
                COMMIT;
                l_cnt := 0;
            END IF;
        END LOOP;

        COMMIT;

        ikis_sys.ikis_lock.releace_lock (l_lock_clean);
    EXCEPTION
        WHEN OTHERS
        THEN
            BEGIN
                DBMS_OUTPUT.put_line (
                       TO_CHAR (SYSDATE, 'DD.MM.YYYY HH24:MI:SS')
                    || ': '
                    || SQLCODE
                    || '-'
                    || SQLERRM
                    || '('
                    || l_tmp
                    || ')');
                ikis_sys.ikis_lock.releace_lock (l_lock_clean);
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;
    END;
END REPORTFL_ENGINE_EX;
/