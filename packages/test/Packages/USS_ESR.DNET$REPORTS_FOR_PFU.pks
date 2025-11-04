/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$REPORTS_FOR_PFU
IS
    -- Author  : VANO
    -- Created : 14.07.2023 12:48:59
    -- Purpose : API та допопміжні функції для побудови звітів на запити ПФУ

    -- отримання списку завдань з підготовки звітів
    PROCEDURE get_app_list (p_res_cur OUT SYS_REFCURSOR);

    -- отримання blob-файлу звіту
    -- p_ap_id - ідентифікатор завдання
    PROCEDURE get_app_rpt_blob (p_app_id     IN     NUMBER,
                                p_is_error      OUT VARCHAR2,
                                p_doc_name      OUT VARCHAR2,
                                p_blob          OUT BLOB);

    -- збереження файла документа
    -- p_app_id - ідентифікатор звернення
    -- p_doc_id - ідентифікатор документа
    -- p_dh_id - ідентифікатор зрізу документа
    PROCEDURE set_app_doc (p_ap_id    IN NUMBER,
                           p_doc_id   IN NUMBER,
                           p_dh_id    IN NUMBER);
END DNET$REPORTS_FOR_PFU;
/


GRANT EXECUTE ON USS_ESR.DNET$REPORTS_FOR_PFU TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$REPORTS_FOR_PFU TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:48 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$REPORTS_FOR_PFU
IS
    -- отримання списку завдань з підготовки звітів
    PROCEDURE get_app_list (p_res_cur OUT SYS_REFCURSOR)
    IS
        l_blob   BLOB := NULL;
        l_id     NUMBER (14, 0) := 0;
    BEGIN
        OPEN p_res_cur FOR
            SELECT ap_id,
                   ap_id      AS p_ap_id,
                   l_blob     AS p_file,
                   l_id       AS p_doc_id,
                   l_id       AS p_dh_id,
                   ''         AS p_doc_name,
                   ''         AS p_is_error,
                   'RTF'      ori_format,
                   'PDF'      AS dest_format
              FROM appeal, ap_service
             WHERE     aps_ap = ap_id
                   AND ap_tp = 'D'
                   AND ap_st = 'O'
                   AND aps_nst = 981
                   AND history_status = 'A';
    END;

    -- отримання blob-файлу звіту
    -- p_ap_id - ідентифікатор завдання
    PROCEDURE get_app_rpt_blob (p_app_id     IN     NUMBER,
                                p_is_error      OUT VARCHAR2,
                                p_doc_name      OUT VARCHAR2,
                                p_blob          OUT BLOB)
    IS
        l_sc                   NUMBER;
        l_app                  NUMBER;
        l_ap_num               VARCHAR2 (100);
        --  l_blob BLOB;
        l_org_name             VARCHAR2 (500);
        l_num                  VARCHAR2 (200);
        l_cnt                  INTEGER;
        l_sql                  VARCHAR2 (4000);
        l_main_select_fields   VARCHAR2 (4000)
            := 't.pib, t.nbc_name as cat_name, to_char(t.start_dt, ''DD.MM.YYYY'') AS start_dt, to_char(t.stop_dt, ''DD.MM.YYYY'') AS stop_dt ';
        l_template_sql         VARCHAR2 (4000)
            := 'SELECT #CODE#
          FROM (SELECT t.scp3_sc,
                       c.nbc_name,
                       uss_person.api$sc_tools.GET_PIB(t.scp3_sc) AS pib,
                       SUM(nvl(t.scp3_sum_m1, 0) + nvl(t.scp3_sum_m2, 0) + nvl(t.scp3_sum_m3, 0) + nvl(t.scp3_sum_m4, 0) + nvl(t.scp3_sum_m5, 0) + nvl(t.scp3_sum_m6, 0) + nvl(t.scp3_sum_m7, 0) + nvl(t.scp3_sum_m8, 0) + nvl(t.scp3_sum_m9, 0) + nvl(t.scp3_sum_m10, 0) + nvl(t.scp3_sum_m11, 0) + nvl(t.scp3_sum_m12, 0)) AS has_sum,
                       ps.scpp_pfu_pd_start_dt AS start_dt,
                       ps.scpp_pfu_pd_stop_dt AS stop_dt
                  from uss_person.v_sc_pfu_pay_period t
                  JOIN uss_person.v_sc_pfu_pay_summary ps ON (ps.scpp_id = t.scp3_scpp and ps.scpp_pfu_payment_tp = ''BENEFIT'')
                  join uss_ndi.v_ndi_benefit_category c on (c.nbc_id = t.scp3_nbc)
                 WHERE t.scp3_sc = #SC#
                   AND t.scp3_nbc IN (2,20,22,23,26,30,99,40,64,69,15,41,42,43,124,125,48,35,54,55,56,19,17)
                 group by scp3_sc, nbc_name, scpp_pfu_pd_start_dt , scpp_pfu_pd_stop_dt
              ) t
            WHERE has_sum IS NOT null AND has_sum != 0';
    BEGIN
        SELECT MAX (app_sc),
               MAX (app_id),
               MAX (ap_num),
               '',                             --MAX(org_code||' '||org_name),
               MAX (sc.sc_unique || TO_CHAR (SYSDATE, 'DDMMYYYY'))
          INTO l_sc,
               l_app,
               l_ap_num,
               l_org_name,
               l_num
          FROM ap_person
               LEFT JOIN uss_person.v_socialcard sc ON (sc.sc_id = app_sc)
               JOIN appeal ON (ap_id = app_ap)
         --JOIN v_opfu ON (org_id = org_id)
         WHERE app_ap = p_app_id AND app_tp = 'Z';

        IF (l_sc IS NOT NULL)
        THEN
            l_sql :=
                REPLACE (REPLACE (l_template_sql, '#SC#', l_sc),
                         '#CODE#',
                         'COUNT(*)');

            EXECUTE IMMEDIATE l_sql
                INTO l_cnt;

            IF l_cnt > 0
            THEN
                l_sql :=
                    REPLACE (REPLACE (l_template_sql, '#SC#', l_sc),
                             '#CODE#',
                             l_main_select_fields);

                reportfl_engine.InitReport ('USS_ESR', 'BENEFIT_DOVIDKA_R1');

                reportfl_engine.AddParam ('gen_dt',
                                          TO_CHAR (SYSDATE, 'DD.MM.YYYY'));
                reportfl_engine.AddParam ('org_name', l_org_name);
                reportfl_engine.AddParam ('num', l_num);

                reportfl_engine.AddDataSet ('ds', l_sql);

                p_blob := reportfl_engine.PublishReportBlob;
                p_doc_name :=
                       'BENEFIT_DOVIDKA_R1_'
                    || TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS')
                    || '_'
                    || p_app_id
                    || '.pdf';
            ELSE
                p_blob :=
                    TOOLS.ConvertC2B (
                        '{\rtf1\ansi\deff0 {\fonttbl {\f0 Times New Roman; } } \f0\fs60 \f0\fs28\lang1033\langfe1049\langnp1033\langfenp1049 Довідка не надається! }');
                p_doc_name :=
                       'BENEFIT_DOVIDKA_R1_ERROR_'
                    || TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS')
                    || '_'
                    || p_app_id
                    || '.pdf';
            END IF;
        ELSE
            p_blob :=
                TOOLS.ConvertC2B (
                    '{\rtf1\ansi\deff0 {\fonttbl {\f0 Times New Roman; } } \f0\fs60 \f0\fs28\lang1033\langfe1049\langnp1033\langfenp1049 В ЄІССС не знайдено соц. картку заявника! }');
            p_doc_name :=
                   'BENEFIT_DOVIDKA_R1_ERROR_'
                || TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS')
                || '_'
                || p_app_id
                || '.pdf';
        END IF;

        p_is_error := 'F';
    EXCEPTION
        WHEN OTHERS
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (l_sql);
            p_blob :=
                TOOLS.ConvertC2B (
                       '{\rtf1\ansi\deff0 {\fonttbl {\f0 Times New Roman; } } \f0\fs60 \f0\fs28\lang1033\langfe1049\langnp1033\langfenp1049 Сталась не передбачена помилка: '
                    || SQLERRM
                    || ' }');
            p_doc_name :=
                   'BENEFIT_DOVIDKA_R1_ERROR_'
                || TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS')
                || '_'
                || p_app_id
                || '.pdf';
            p_is_error := 'F';
    END;

    -- збереження файла документа
    -- p_app_id - ідентифікатор звернення
    -- p_doc_id - ідентифікатор документа
    -- p_dh_id - ідентифікатор зрізу документа
    PROCEDURE set_app_doc (p_ap_id    IN NUMBER,
                           p_doc_id   IN NUMBER,
                           p_dh_id    IN NUMBER)
    IS
        l_pdo_id   pd_document.pdo_id%TYPE;
    BEGIN
        FOR c
            IN (SELECT ap_id,
                       (SELECT MAX (pdo_id)
                          FROM pd_document dd
                         WHERE     dd.pdo_ap = p_ap_id
                               AND dd.pdo_ndt = 741
                               AND dd.history_status = 'A')    AS pdo_exist
                  FROM appeal, ap_service
                 WHERE     ap_id = p_ap_id
                       AND aps_ap = ap_id
                       AND ap_tp = 'D'
                       AND ap_st = 'O'
                       AND aps_nst = 981
                       AND history_status = 'A')
        LOOP
            --видаленння існуючого документа
            IF c.pdo_exist IS NOT NULL
            THEN
                api$documents.delete_pd_document (c.pdo_exist);
            END IF;

            --збереження сформованої довідки
            api$documents.save_pd_document (p_pdo_id   => NULL,
                                            p_doc_id   => p_doc_id,
                                            p_dh_id    => p_dh_id,
                                            p_ap_id    => p_ap_id,
                                            p_app_id   => NULL,
                                            p_aps_id   => NULL,
                                            p_apd_id   => NULL,
                                            p_ndt_id   => 10227,
                                            p_pd_id    => NULL,
                                            p_new_id   => l_pdo_id);

            --переведення звернення в виконане
            UPDATE appeal
               SET ap_st = 'V'
             WHERE ap_id = p_ap_id;

            --підготовка до зворотнього копіювання сформованої довідки
            api$esr_action.preparecopy_esr2visit (p_ap_id, 'O', NULL);
        END LOOP;
    END;
BEGIN
    NULL;
END DNET$REPORTS_FOR_PFU;
/