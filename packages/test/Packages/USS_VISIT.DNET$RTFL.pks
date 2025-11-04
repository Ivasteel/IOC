/* Formatted on 8/12/2025 5:59:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.DNET$RTFL
IS
    -- Author  : VANO
    -- Created : 23.05.2018 14:38:09
    -- Purpose : Обгортка до двигуна звітів на основі шаблонів IKIS_SYSWEB.REPORTFL_ENGINE_EX (побудова в C#)

    -- повертає список шаблонів по коду
    PROCEDURE GetReportList (p_rpt_type   IN     VARCHAR2,
                             res_Cur         OUT SYS_REFCURSOR);

    --Перевірка стану звіту на завершеність (чи звіт в стані ENDED)
    FUNCTION IsReportProcessed (p_jbr_id DECIMAL)
        RETURN BOOLEAN;

    --Отримання стану звіту для можливості побудови інформаційної сторінки про звіт
    PROCEDURE GetReportResult (p_jbr_id          DECIMAL,
                               p_file_data   OUT SYS_REFCURSOR);

    PROCEDURE GetReportResultAsync (p_jbr_id          DECIMAL,
                                    p_file_data   OUT SYS_REFCURSOR);

    --Отримання стану звіту для можливості побудови інформаційної сторінки про звіт
    PROCEDURE GetReportInfo (p_jbr_id                DECIMAL,
                             p_report_data       OUT SYS_REFCURSOR,
                             p_report_protocol   OUT SYS_REFCURSOR);

    --Побудова звіту: виконується зміна статусу запису для можливості роботи серверу додатків та виконується очікування завершення побудови завіту (звіт переходить в стан READY)
    FUNCTION PublishReportBlob (p_jbr_id DECIMAL)
        RETURN BLOB;
END DNET$RTFL;
/


GRANT EXECUTE ON USS_VISIT.DNET$RTFL TO DNET_PROXY
/

GRANT EXECUTE ON USS_VISIT.DNET$RTFL TO II01RC_USS_VISIT_WEB
/


/* Formatted on 8/12/2025 6:00:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.DNET$RTFL
IS
    -- повертає список шаблонів по коду
    PROCEDURE GetReportList (p_rpt_type   IN     VARCHAR2,
                             res_Cur         OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
              SELECT t.rt_id AS id, t.rt_code AS code, t.rt_name AS name
                FROM rpt_templates t
               WHERE t.rt_ss_code = 'USS_VISIT' AND t.rt_doc_tp = p_rpt_type
            ORDER BY t.rt_name;
    END;

    --Отримання стану звіту для можливості побудови інформаційної сторінки про звіт
    PROCEDURE GetReportInfo (p_jbr_id                DECIMAL,
                             p_report_data       OUT SYS_REFCURSOR,
                             p_report_protocol   OUT SYS_REFCURSOR)
    IS
    BEGIN
        IKIS_SYSWEB.REPORTFL_ENGINE_EX.GetReportInfo (p_jbr_id,
                                                      p_report_data,
                                                      p_report_protocol);
    END;



    --Перевірка стану звіту на завершеність (чи звіт в стані ENDED)
    FUNCTION IsReportProcessed (p_jbr_id DECIMAL)
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN IKIS_SYSWEB.REPORTFL_ENGINE_EX.IsReportProcessed (
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
                   l_jbr_rpt_result      AS p_file_data
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
                   l_jbr_rpt_result      AS p_file_data,
                   DBMS_LOB.getlength (l_jbr_rpt_result)
              FROM rpt_templates
             WHERE rt_id = l_tmpl_id;
    END;

    --Побудова звіту: виконується зміна статусу запису для можливості роботи серверу додатків та виконується очікування завершення побудови завіту (звіт переходить в стан READY)
    FUNCTION PublishReportBlob (p_jbr_id DECIMAL)
        RETURN BLOB
    IS
    BEGIN
        RETURN IKIS_SYSWEB.REPORTFL_ENGINE_EX.PublishReportBlob (
                   p_jbr_id   => p_jbr_id);
    END;
END DNET$RTFL;
/