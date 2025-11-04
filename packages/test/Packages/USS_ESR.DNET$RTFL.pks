/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$RTFL
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


GRANT EXECUTE ON USS_ESR.DNET$RTFL TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$RTFL TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:56 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$RTFL
IS
    -- повертає список шаблонів по коду
    PROCEDURE GetReportList (p_rpt_type   IN     VARCHAR2,
                             res_Cur         OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
              SELECT t.rt_id AS id, t.rt_name AS name
                FROM rpt_templates t
               WHERE t.rt_ss_code = 'USS_ESR' AND t.rt_doc_tp = p_rpt_type
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
        raise_application_error (-20000, '11111111111111111111');
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
                   -- io 20211214 l_jbr_rpt_result AS p_file_data
                   CASE
                       WHEN rt_file_tp = 'XLS'
                       THEN
                           TOOLS.ConvertC2BUTF8 (
                               tools.ConvertB2C (l_jbr_rpt_result)) -- xls - в utf-8
                       ELSE
                           l_jbr_rpt_result
                   END                   AS p_file_data
              FROM rpt_templates
             WHERE rt_id = l_tmpl_id;
    END;

    PROCEDURE GetReportResultAsync (p_jbr_id          DECIMAL,
                                    p_file_data   OUT SYS_REFCURSOR)
    IS
        l_tmpl_id                     DECIMAL;
        l_file_dt                     DATE;
        l_jbr_rpt_src                 BLOB;
        l_jbr_rpt_result              BLOB;
        l_jbr_rpt_result_compressed   BLOB;
        l_size                        INTEGER;
        l_is_compressed               INTEGER := 0;
        l_file_tp                     rpt_templates.rt_file_tp%TYPE;
        l_code                        rpt_templates.rt_code%TYPE;
        l_files                       ikis_sysweb.tbl_some_files
                                          := ikis_sysweb.tbl_some_files ();
        l_file_name                   VARCHAR2 (55);
    BEGIN
        --raise_application_error(-20000, '22222222222222');
        l_jbr_rpt_src :=
            IKIS_SYSWEB.REPORTFL_ENGINE_EX.GetReportResult (p_jbr_id);

        IKIS_SYSWEB.REPORTFL_ENGINE_EX.GetReportInfoSimpl (p_jbr_id,
                                                           l_file_dt,
                                                           l_tmpl_id);

        SELECT rt_file_tp, rt_code
          INTO l_file_tp, l_code
          FROM rpt_templates
         WHERE rt_id = l_tmpl_id;

        IF l_file_tp = 'XLS'
        THEN
            l_jbr_rpt_result :=
                TOOLS.ConvertC2BUTF8 (tools.ConvertB2C (l_jbr_rpt_src));
        ELSE
            l_jbr_rpt_result := l_jbr_rpt_src;
        END IF;

        l_is_compressed := 1;

        l_file_name :=
            NVL (
                IKIS_SYSWEB.REPORTFL_ENGINE_EX.GetFileName (p_jbr_id),
                   SUBSTR (
                          TRIM (l_code)
                       || '_'
                       || TO_CHAR (l_file_dt, 'YYYYMMDDHH24MISS')
                       || '_'
                       || p_jbr_id,
                       1,
                       55 - LENGTH ('.' || l_file_tp))
                || '.'
                || l_file_tp);


        --  IF l_size > 100000 THEN
        l_files.EXTEND;
        l_files (l_files.LAST) :=
            ikis_sysweb.t_some_file_info (l_file_name, l_jbr_rpt_result);

        l_jbr_rpt_result_compressed :=
            ikis_sysweb.ikis_web_jutil.getZipFromStrms (l_files);

        l_size := DBMS_LOB.getlength (l_jbr_rpt_result_compressed);

        --    l_jbr_rpt_result_compressed := utl_compress.lz_compress(l_jbr_rpt_result);
        --  ELSE
        --    l_jbr_rpt_result_compressed := l_jbr_rpt_result;
        --  END IF;

        l_size := DBMS_LOB.getlength (l_jbr_rpt_result);

        OPEN p_file_data FOR
            SELECT    l_file_name
                   || CASE WHEN l_is_compressed = 1 THEN '.zip' END
                       AS rt_file_name,
                   l_jbr_rpt_result_compressed
                       AS p_file_data,
                   l_size
              FROM DUAL;
    /*exception
      when others then
        raise_application_error(-20000, '11111111111111111111');  */
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