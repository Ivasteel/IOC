/* Formatted on 8/12/2025 5:57:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.RDM$RTFL
IS
    -- Author  : LEV
    -- Created : 09.03.2022 12:26:41
    -- Purpose : Функції роботи з шаблонними звітами

    --Ініціалізація побудови звіту на основі шаблону (звіт переходить в стан INIT)
    FUNCTION InitReport (p_rt_id           rpt_templates.rt_id%TYPE:= NULL,
                         p_jbr_app_ident   VARCHAR2:= NULL,
                         p_jbr_rpt_code    VARCHAR2:= NULL,
                         p_jbr_ss_code     VARCHAR2:= NULL,
                         p_jbr_user        VARCHAR2:= NULL)
        RETURN DECIMAL;

    --Додавання скрипта підготовки даних (виконуватимуться в порядку вставки в одному з'єднанні з БД). Без параметрів. Контекст виконання - користувача, що визвав побудову звіту
    PROCEDURE AddScript (p_jbr_id        DECIMAL,
                         p_script_name   VARCHAR2,
                         p_script_text   VARCHAR2);

    --Додавання константи
    PROCEDURE AddParam (p_jbr_id        DECIMAL,
                        p_param_name    VARCHAR2,
                        p_param_value   VARCHAR2);

    --Додавання набору даних у вигляді запиту
    PROCEDURE AddDataSet (p_jbr_id    DECIMAL,
                          p_dataset   VARCHAR2,
                          p_sql       VARCHAR2);

    --Додавання пов'язаних наборів даних
    PROCEDURE AddRelation (p_jbr_id       DECIMAL,
                           pMaster        VARCHAR2,
                           pMasterField   VARCHAR2,
                           pDetail        VARCHAR2,
                           pDetailField   VARCHAR2);

    --Додавання саммарі
    PROCEDURE AddSummary (p_jbr_id   DECIMAL,
                          pDataSet   VARCHAR2,
                          pField     VARCHAR2,
                          pType      VARCHAR2,
                          pFormat    VARCHAR2);

    --Встановлення кастомного імені файлу
    PROCEDURE SetFileName (p_jbr_id DECIMAL, p_file_name VARCHAR2);

    --Збереження повідомлення
    PROCEDURE SaveMessage (p_jbr_id       DECIMAL,
                           p_jm_tp        VARCHAR2,
                           p_jm_message   VARCHAR2);

    --Зміна стану звіту на "готовий для обробки в сервері додатків" - тільки для ініціалізованих (звіт переходить в стан READY)
    PROCEDURE PutReportToWorkingQueue (p_jbr_id DECIMAL);


    --Отримання разультату побудови звіту (тільки завершених)
    PROCEDURE GetReportResult (p_jbr_id          DECIMAL,
                               p_file_data   OUT SYS_REFCURSOR);

    PROCEDURE GetReportResultAsync (p_jbr_id          DECIMAL,
                                    p_file_data   OUT SYS_REFCURSOR);
END RDM$RTFL;
/


/* Formatted on 8/12/2025 5:58:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RNSP.RDM$RTFL
IS
    --Ініціалізація побудови звіту на основі шаблону (звіт переходить в стан INIT)
    FUNCTION InitReport (p_rt_id           rpt_templates.rt_id%TYPE:= NULL,
                         p_jbr_app_ident   VARCHAR2:= NULL,
                         p_jbr_rpt_code    VARCHAR2:= NULL,
                         p_jbr_ss_code     VARCHAR2:= NULL,
                         p_jbr_user        VARCHAR2:= NULL)
        RETURN DECIMAL
    IS
        l_templ          BLOB;
        --l_jbr_app_ident VARCHAR2;
        l_jbr_rpt_code   VARCHAR2 (100);
        l_jbr_ss_code    VARCHAR2 (100);
        l_jbr_user       VARCHAR2 (100);
    BEGIN
        l_jbr_user :=
            NVL (p_jbr_user,
                 uss_rnsp_context.GetContext (uss_rnsp_context.gLogin));

        IF p_rt_id IS NULL
        THEN
            SELECT rt_text
              INTO l_templ
              FROM rpt_templates
             WHERE rt_code = p_jbr_rpt_code AND rt_ss_code = p_jbr_ss_code;

            RETURN IKIS_SYSWEB.REPORTFL_ENGINE_EX.InitReport (
                       p_jbr_app_ident      => NVL (p_jbr_app_ident, 'USS_RNSP'),
                       p_jbr_rpt_code       => p_jbr_rpt_code,
                       p_jbr_rpt_template   => l_templ,
                       p_jbr_ss_code        => p_jbr_ss_code,
                       p_jbr_user           => l_jbr_user,
                       p_tmpl_id            => p_rt_id);
        ELSE
            SELECT rt_text, rt_code, rt_ss_code
              INTO l_templ, l_jbr_rpt_code, l_jbr_ss_code
              FROM rpt_templates
             WHERE rt_id = p_rt_id;

            RETURN IKIS_SYSWEB.REPORTFL_ENGINE_EX.InitReport (
                       p_jbr_app_ident      => NVL (p_jbr_app_ident, 'USS_RNSP'),
                       p_jbr_rpt_code       => l_jbr_rpt_code,
                       p_jbr_rpt_template   => l_templ,
                       p_jbr_ss_code        => l_jbr_ss_code,
                       p_jbr_user           => l_jbr_user,
                       p_tmpl_id            => p_rt_id);
        END IF;
    END;

    --Додавання скрипта підготовки даних (виконуватимуться в порядку вставки в одному з'єднанні з БД). Без параметрів. Контекст виконання - користувача, що визвав побудову звіту
    PROCEDURE AddScript (p_jbr_id        DECIMAL,
                         p_script_name   VARCHAR2,
                         p_script_text   VARCHAR2)
    IS
    BEGIN
        IKIS_SYSWEB.REPORTFL_ENGINE_EX.AddScript (
            p_jbr_id        => p_jbr_id,
            p_script_name   => p_script_name,
            p_script_text   => p_script_text);
    END;

    --Додавання константи
    PROCEDURE AddParam (p_jbr_id        DECIMAL,
                        p_param_name    VARCHAR2,
                        p_param_value   VARCHAR2)
    IS
    BEGIN
        IKIS_SYSWEB.REPORTFL_ENGINE_EX.AddParam (
            p_jbr_id        => p_jbr_id,
            p_param_name    => p_param_name,
            p_param_value   => p_param_value);
    END;

    --Додавання набору даних у вигляді запиту
    PROCEDURE AddDataSet (p_jbr_id    DECIMAL,
                          p_dataset   VARCHAR2,
                          p_sql       VARCHAR2)
    IS
    BEGIN
        IKIS_SYSWEB.REPORTFL_ENGINE_EX.AddDataSet (p_jbr_id    => p_jbr_id,
                                                   p_dataset   => p_dataset,
                                                   p_sql       => p_sql);
    END;

    --Додавання пов'язаних наборів даних
    PROCEDURE AddRelation (p_jbr_id       DECIMAL,
                           pMaster        VARCHAR2,
                           pMasterField   VARCHAR2,
                           pDetail        VARCHAR2,
                           pDetailField   VARCHAR2)
    IS
    BEGIN
        IKIS_SYSWEB.REPORTFL_ENGINE_EX.AddRelation (
            p_jbr_id       => p_jbr_id,
            pMaster        => pMaster,
            pMasterField   => pMasterField,
            pDetail        => pDetail,
            pDetailField   => pDetailField);
    END;

    --Додавання саммарі
    PROCEDURE AddSummary (p_jbr_id   DECIMAL,
                          pDataSet   VARCHAR2,
                          pField     VARCHAR2,
                          pType      VARCHAR2,
                          pFormat    VARCHAR2)
    IS
    BEGIN
        IKIS_SYSWEB.REPORTFL_ENGINE_EX.AddSummary (p_jbr_id   => p_jbr_id,
                                                   pDataSet   => pDataSet,
                                                   pField     => pField,
                                                   pType      => pType,
                                                   pFormat    => pFormat);
    END;

    --Встановлення кастомного імені файлу
    PROCEDURE SetFileName (p_jbr_id DECIMAL, p_file_name VARCHAR2)
    IS
    BEGIN
        IKIS_SYSWEB.REPORTFL_ENGINE_EX.SetFileName (p_jbr_id, p_file_name);
    END;

    --Збереження повідомлення
    PROCEDURE SaveMessage (p_jbr_id       DECIMAL,
                           p_jm_tp        VARCHAR2,
                           p_jm_message   VARCHAR2)
    IS
    BEGIN
        IKIS_SYSWEB.REPORTFL_ENGINE_EX.SaveMessage (
            p_jbr_id       => p_jbr_id,
            p_jp_tp        => p_jm_tp,
            p_jp_message   => p_jm_message);
    END;

    --Зміна стану звіту на "готовий для обробки в сервері додатків" - тільки для ініціалізованих (звіт переходить в стан READY)
    PROCEDURE PutReportToWorkingQueue (p_jbr_id DECIMAL)
    IS
    BEGIN
        IKIS_SYSWEB.REPORTFL_ENGINE_EX.PutReportToWorkingQueue (
            p_jbr_id   => p_jbr_id);
    END;


    --Отримання разультату побудови звіту (тільки завершених)
    PROCEDURE GetReportResult (p_jbr_id          DECIMAL,
                               p_file_data   OUT SYS_REFCURSOR)
    IS
        l_tmpl_id          DECIMAL;
        l_file_dt          DATE;
        l_jbr_rpt_result   BLOB;
    BEGIN
        l_jbr_rpt_result :=
            IKIS_SYSWEB.REPORTFL_ENGINE_EX.GetReportResult (p_jbr_id);
        IKIS_SYSWEB.REPORTFL_ENGINE_EX.GetReportInfoSimpl (p_jbr_id,
                                                           l_file_dt,
                                                           l_tmpl_id);

        OPEN p_file_data FOR
            SELECT rt_id,
                   rt_code,
                   rt_file_tp,
                   NVL (
                       IKIS_SYSWEB.REPORTFL_ENGINE_EX.GetFileName (p_jbr_id),
                          TRIM (rt_code)
                       || '_'
                       || TO_CHAR (l_file_dt, 'YYYYMMDDHH24MISS')
                       || '_'
                       || p_jbr_id
                       || '.'
                       || rt_file_tp)    AS rt_file_name,
                   --l_jbr_rpt_result AS p_file_data
                   -- xls - в utf-8
                   CASE
                       WHEN rt_file_tp = 'XLS'
                       THEN
                           TOOLS.ConvertC2BUTF8 (
                               tools.ConvertB2C (l_jbr_rpt_result))
                       ELSE
                           l_jbr_rpt_result
                   END                   AS p_file_data
              FROM rpt_templates
             WHERE rt_id = l_tmpl_id;
    END;

    PROCEDURE GetReportResultAsync (p_jbr_id          DECIMAL,
                                    p_file_data   OUT SYS_REFCURSOR)
    IS
        l_tmpl_id          DECIMAL;
        l_file_dt          DATE;
        l_jbr_rpt_result   BLOB;
    BEGIN
        l_jbr_rpt_result :=
            IKIS_SYSWEB.REPORTFL_ENGINE_EX.GetReportResult (p_jbr_id);

        IKIS_SYSWEB.REPORTFL_ENGINE_EX.GetReportInfoSimpl (p_jbr_id,
                                                           l_file_dt,
                                                           l_tmpl_id);

        OPEN p_file_data FOR
            SELECT NVL (
                       IKIS_SYSWEB.REPORTFL_ENGINE_EX.GetFileName (p_jbr_id),
                          TRIM (rt_code)
                       || '_'
                       || TO_CHAR (l_file_dt, 'YYYYMMDDHH24MISS')
                       || '_'
                       || p_jbr_id
                       || '.'
                       || rt_file_tp)    AS rt_file_name,
                   p_file_data,
                   DBMS_LOB.getlength (p_file_data)
              FROM (SELECT rt_code,
                           rt_file_tp,
                           CASE
                               WHEN rt_file_tp = 'XLS'
                               THEN
                                   TOOLS.ConvertC2BUTF8 (
                                       tools.ConvertB2C (l_jbr_rpt_result)) -- xls - в utf-8
                               ELSE
                                   l_jbr_rpt_result
                           END    AS p_file_data
                      FROM rpt_templates
                     WHERE rt_id = l_tmpl_id);
    END;
END RDM$RTFL;
/