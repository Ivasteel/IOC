/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$CALC_RIGHT_AT
IS
    gLogSesID   VARCHAR2 (50);

    --========================================--
    --Отримання параметру з документу по зверненню
    --========================================--
    -- Дата
    FUNCTION Get_Ap_Doc_dt (p_Ap        Ap_Document.Apd_Ap%TYPE,
                            p_Ndt       Ap_Document.Apd_Ndt%TYPE,
                            p_Nda       Ap_Document_Attr.Apda_Nda%TYPE,
                            p_Default   VARCHAR2 DEFAULT NULL)
        RETURN DATE;

    -- Строка
    FUNCTION Get_Ap_Doc_String (p_Ap        Ap_Document.Apd_Ap%TYPE,
                                p_Ndt       Ap_Document.Apd_Ndt%TYPE,
                                p_Nda       Ap_Document_Attr.Apda_Nda%TYPE,
                                p_Default   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;

    --========================================--
    --Отримання параметру з документу по Акту
    --========================================--
    --Дата
    FUNCTION Get_At_Doc_String (p_At        At_Document.Atd_at%TYPE,
                                p_Ndt       At_Document.Atd_Ndt%TYPE,
                                p_Nda       At_Document_Attr.Atda_Nda%TYPE,
                                p_Default   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;


    --  Ознака «Категорія отримувача соціальних послуг» - наявність документів
    --==============================================================--
    FUNCTION IsRecip_SS_doc_exists (p_ap_id NUMBER, p_app_id NUMBER)
        RETURN NUMBER;

    FUNCTION Is_Apda_Equal (
        p_ap_id       NUMBER,
        p_app_id      NUMBER,
        p_nda_value   VARCHAR2:= 'T',
        p_list_nda    VARCHAR2:= '1796,2560,1795,1797,1798,1799,1800,1801,1802,1803,1856,1857,1858,1859,1860,1861,1862')
        RETURN NUMBER;

    --Перерахунок результату контроля по послузі після корегування arl_result
    PROCEDURE Recalc_SS_ALG (p_at_id act.at_id%TYPE);


    FUNCTION BOOLEAN_TO_CHAR (STATUS IN BOOLEAN)
        RETURN VARCHAR2;

    --Перевірка наявності права на допомогу
    PROCEDURE init_right_for_act (p_mode           INTEGER, --1=з p_at_id, 2=з таблиці tmp_work_ids
                                  p_at_id          act.at_id%TYPE,
                                  p_messages   OUT SYS_REFCURSOR);


    --+++++++++++++++++++++
    PROCEDURE dbms_output_decision_info (p_id NUMBER);

    PROCEDURE dbms_output_appeal_info (p_id NUMBER);

    PROCEDURE Test_right (id NUMBER);
--+++++++++++++++++++++
--FUNCTION Is_Check_ALG2(p_at_id NUMBER, p_ats_id NUMBER, p_alg VARCHAR2) RETURN number;
END API$CALC_RIGHT_AT;
/


/* Formatted on 8/12/2025 5:48:58 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$CALC_RIGHT_AT
IS
    Is_dbms_output     BOOLEAN := FALSE;
    g_def_arl_result   VARCHAR2 (10);

    --========================================
    PROCEDURE PutLine (p_val VARCHAR2)
    IS
    BEGIN
        IF Is_dbms_output
        THEN
            DBMS_OUTPUT.put_line (p_val);
        END IF;
    END;

    --========================================
    PROCEDURE write_at_log (p_atl_at        at_log.atl_at%TYPE,
                            p_atl_hs        at_log.atl_hs%TYPE,
                            p_atl_st        at_log.atl_st%TYPE,
                            p_atl_message   at_log.atl_message%TYPE,
                            p_atl_st_old    at_log.atl_st_old%TYPE,
                            p_atl_tp        at_log.atl_tp%TYPE:= 'SYS')
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        --l_hs := NVL(p_atl_hs, TOOLS.GetHistSession);
        l_hs := p_atl_hs;

        IF l_hs IS NULL
        THEN
            l_hs := TOOLS.GetHistSession;
        END IF;

        INSERT INTO at_log (atl_id,
                            atl_at,
                            atl_hs,
                            atl_st,
                            atl_message,
                            atl_st_old,
                            atl_tp)
             VALUES (0,
                     p_atl_at,
                     l_hs,
                     p_atl_st,
                     p_atl_message,
                     p_atl_st_old,
                     p_atl_tp);
    END;

    --========================================
    FUNCTION Get_Ap_Doc_dt (p_Ap        Ap_Document.Apd_Ap%TYPE,
                            p_Ndt       Ap_Document.Apd_Ndt%TYPE,
                            p_Nda       Ap_Document_Attr.Apda_Nda%TYPE,
                            p_Default   VARCHAR2 DEFAULT NULL)
        RETURN DATE
    IS
        l_Rez   DATE;
    BEGIN
        SELECT MAX (Apda_Val_dt)
          INTO l_Rez
          FROM Ap_Document, Ap_Document_Attr
         WHERE     Apda_Apd = Apd_Id
               AND Ap_Document.History_Status = 'A'
               AND Ap_Document_Attr.History_Status = 'A'
               AND Apd_Ap = p_Ap
               AND Apd_Ndt = p_Ndt
               AND Apda_Nda = p_Nda;

        RETURN NVL (l_Rez, p_Default);
    END;

    --========================================
    FUNCTION Get_Ap_Doc_String (p_Ap        Ap_Document.Apd_Ap%TYPE,
                                p_Ndt       Ap_Document.Apd_Ndt%TYPE,
                                p_Nda       Ap_Document_Attr.Apda_Nda%TYPE,
                                p_Default   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_Rez   VARCHAR2 (200);
    BEGIN
        SELECT MAX (Apda_Val_string)
          INTO l_Rez
          FROM Ap_Document, Ap_Document_Attr
         WHERE     Apda_Apd = Apd_Id
               AND Ap_Document.History_Status = 'A'
               AND Ap_Document_Attr.History_Status = 'A'
               AND Apd_Ap = p_Ap
               AND Apd_Ndt = p_Ndt
               AND Apda_Nda = p_Nda;

        RETURN NVL (l_Rez, p_Default);
    END;

    --========================================--
    --Отримання параметру з документу по Акту
    --========================================--
    FUNCTION Get_At_Doc_String (p_At        At_Document.Atd_at%TYPE,
                                p_Ndt       At_Document.Atd_Ndt%TYPE,
                                p_Nda       At_Document_Attr.Atda_Nda%TYPE,
                                p_Default   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_Rez   VARCHAR2 (200);
    BEGIN
        SELECT MAX (Atda_Val_string)
          INTO l_Rez
          FROM At_Document
               JOIN At_Document_Attr
                   ON     Atda_Atd = Atd_Id
                      AND At_Document_Attr.History_Status = 'A'
         WHERE     Atd_At = p_At
               AND At_Document_Attr.History_Status = 'A'
               AND Atd_Ndt = p_Ndt
               AND Atda_Nda = p_Nda;

        RETURN NVL (l_Rez, p_Default);
    END;

    --========================================
    PROCEDURE MERGE_tmp_errors_list (id NUMBER, info VARCHAR2)
    IS
    BEGIN
        MERGE INTO tmp_errors_list
             USING (SELECT id id, info info
                      FROM DUAL
                     WHERE info IS NOT NULL)
                ON (id = tel_id)
        WHEN MATCHED
        THEN
            UPDATE SET tel_text = tel_text || ', ' || info
        WHEN NOT MATCHED
        THEN
            INSERT     (tel_id, tel_text)
                VALUES (id, info);
    END;

    --========================================
    PROCEDURE Set_at_right_log (p_nrr_id           NUMBER,
                                p_at_id            NUMBER,
                                p_ats_id           NUMBER,
                                p_def_arl_result   VARCHAR2:= NULL)
    IS
    BEGIN
        MERGE INTO at_right_log
             USING (SELECT x_id                      AS b_at,
                           p_ats_id                  AS b_ats,
                           p_nrr_id                  AS b_nrr,
                           CASE
                               WHEN (SELECT COUNT (*)
                                       FROM tmp_errors_list
                                      WHERE x_id = tel_id) > 0
                               THEN
                                   'F'
                               ELSE
                                   'T'
                           END                       AS b_result,
                           (SELECT MAX (tel_text)
                              FROM tmp_errors_list
                             WHERE x_id = tel_id)    AS b_info
                      FROM tmp_work_ids
                     WHERE x_id = p_at_id)
                ON (arl_at = b_at AND arl_nrr = b_nrr AND arl_ats = b_ats)
        WHEN MATCHED
        THEN
            UPDATE SET arl_calc_result = b_result,
                       arl_hs_rewrite = NULL,
                       arl_result = NVL (p_def_arl_result, b_result),
                       arl_calc_info = b_info
        WHEN NOT MATCHED
        THEN
            INSERT     (arl_id,
                        arl_at,
                        arl_nrr,
                        arl_calc_result,
                        arl_result,
                        arl_calc_info,
                        arl_ats)
                VALUES (0,
                        b_at,
                        b_nrr,
                        b_result,
                        NVL (p_def_arl_result, b_result),
                        b_info,
                        b_ats);
    --COMMIT;
    END;

    --========================================
    PROCEDURE Check_ALG1 (p_nrr_id   NUMBER,
                          p_at_ap    act.at_ap%TYPE,
                          p_at_id    act.at_id%TYPE,
                          p_ats_id   at_service.ats_id%TYPE)
    IS
        l_provide_assistance   VARCHAR2 (20);
        l_pd_cur               SYS_REFCURSOR;
        l_pd_id                VARCHAR2 (20);
    BEGIN
        l_provide_assistance :=
            get_ap_doc_string (p_at_ap,
                               800,
                               3061,
                               '-');

        CASE
            WHEN l_provide_assistance IN ('-')
            THEN
                NULL;
            WHEN l_provide_assistance IN ('Z', 'FM')
            THEN
                FOR rec
                    IN (SELECT app.app_sc, aps.aps_nst
                          FROM ap_person  app
                               JOIN ap_service aps
                                   ON     app_ap = aps_ap
                                      AND Aps.History_Status = 'A'
                         WHERE     App_Ap = p_at_ap
                               AND App_Tp = 'Z'
                               AND App.History_Status = 'A')
                LOOP
                    api$find.Get_Decision (p_sc_id    => rec.app_sc,
                                           p_nst_id   => rec.aps_nst,
                                           p_pd_cur   => l_pd_cur);

                    FETCH l_pd_cur INTO l_pd_id;

                    CLOSE l_pd_cur;
                END LOOP;
            ELSE
                FOR rec
                    IN (SELECT app.app_sc, aps.aps_nst
                          FROM ap_person  app
                               JOIN ap_service aps
                                   ON     app_ap = aps_ap
                                      AND Aps.History_Status = 'A'
                         WHERE     App_Ap = p_at_ap
                               AND App_Tp = 'OS'
                               AND App.History_Status = 'A')
                LOOP
                    uss_esr.api$find.Get_Decision (p_sc_id    => rec.app_sc,
                                                   p_nst_id   => rec.aps_nst,
                                                   p_pd_cur   => l_pd_cur);

                    FETCH l_pd_cur INTO l_pd_id;

                    CLOSE l_pd_cur;
                END LOOP;
        END CASE;

        IF l_pd_id IS NULL
        THEN
            INSERT INTO tmp_errors_list (tel_id, tel_text)
                     VALUES (
                                p_at_id,
                                'Діючих рішень про надання соціальних послуг, зазначених у заяві про відмову, не знайдено.');
        END IF;

        Set_at_right_log (p_nrr_id, p_at_id, p_ats_id);
    END;

    --========================================
    FUNCTION Is_Check_ALG (p_at_id NUMBER, p_ats_id NUMBER, p_alg VARCHAR2)
        RETURN BOOLEAN
    IS
        l_res   VARCHAR2 (2000);
    BEGIN
        --SELECT MAX(arl.arl_calc_result)
        SELECT MAX (arl.arl_result)
          INTO l_res
          FROM at_right_log  arl
               JOIN uss_ndi.v_ndi_right_rule ON nrr_id = arl.arl_nrr
         WHERE     arl.arl_at = p_at_id
               AND arl.arl_ats = p_ats_id
               AND nrr_alg = P_ALG;

        RETURN (NVL (l_res, 'F') = 'T');
    END;

    /*FUNCTION Is_Check_ALG2(p_at_id NUMBER, p_ats_id NUMBER, p_alg VARCHAR2) RETURN number IS
      l_res VARCHAR2(2000);
    BEGIN
      --SELECT MAX(arl.arl_calc_result)
      SELECT MAX(arl.arl_result)
            INTO l_res
      FROM  at_right_log arl
            JOIN uss_ndi.v_ndi_right_rule ON nrr_id = arl.arl_nrr
      WHERE arl.arl_at  = p_at_id
        AND arl.arl_ats = p_ats_id
        AND nrr_alg = P_ALG;
      RETURN case when (nvl(l_res, 'F') = 'T') then 1 else 0 end;
    END;*/

    --==============================================================--
    --  Ознака «Категорія отримувача соціальних послуг» - наявність документів
    --==============================================================--
    FUNCTION IsRecip_SS_doc_exists (p_ap_id NUMBER, p_app_id NUMBER)
        RETURN NUMBER
    IS
        l_rez   NUMBER (10) := 0;
    BEGIN
        SELECT SUM (
                   CASE apda_nda
                       WHEN 1795
                       THEN
                           API$APPEAL.get_doc_list_cnt (apd_app, '820,821')
                       WHEN 1796
                       THEN
                           API$APPEAL.get_doc_list_cnt (
                               apd_app,
                               '822,823,824,825,826,827,828,829')
                       WHEN 1797
                       THEN
                           API$APPEAL.get_doc_list_cnt (
                               apd_app,
                               '203,200,202,676,10038')
                       WHEN 1798
                       THEN
                           API$APPEAL.get_doc_list_cnt (apd_app, '201,809')
                       WHEN 1799
                       THEN
                           API$APPEAL.get_doc_list_cnt (apd_app, '830,831')
                       WHEN 1800
                       THEN
                           API$APPEAL.get_doc_list_cnt (apd_app, '830,831')
                       WHEN 1801
                       THEN
                           API$APPEAL.get_doc_list_cnt (apd_app, '830,831')
                       WHEN 1802
                       THEN
                           API$APPEAL.get_doc_list_cnt (apd_app, '830,831')
                       --WHEN 1803 THEN API$APPEAL.get_doc_list_cnt(apd_app, '660,816')
                       WHEN 1856
                       THEN
                           API$APPEAL.get_doc_list_cnt (apd_app, '660')
                       WHEN 1857
                       THEN
                           API$APPEAL.get_doc_list_cnt (apd_app, '660')
                       WHEN 1858
                       THEN
                           API$APPEAL.get_doc_list_cnt (apd_app, '93')
                       WHEN 1859
                       THEN
                           API$APPEAL.get_doc_list_cnt (apd_app, '660,661')
                       --WHEN 1860 THEN API$APPEAL.get_doc_list_cnt(apd_app, '811')
                       WHEN 1861
                       THEN
                           API$APPEAL.get_doc_list_cnt (apd_app, '669')
                       WHEN 1862
                       THEN
                           API$APPEAL.get_doc_list_cnt (apd_app, '684,10052')
                       WHEN 2560
                       THEN
                           API$APPEAL.get_doc_list_cnt (apd_app, '833')
                       ELSE
                           0
                   END)    AS doc_list_cnt
          INTO l_rez
          FROM ap_document
               JOIN ap_document_attr
                   ON     apda_apd = apd_id
                      AND ap_document_attr.history_status = 'A'
               JOIN uss_ndi.v_ndi_document_attr ON apda_nda = nda_id
         WHERE     apd_ap = p_ap_id
               AND apd_app = p_app_id
               AND apd_ndt = 605                                     -- Анкета
               AND nda_nng = 19    -- «Категорія отримувача соціальних послуг»
               AND CASE
                       WHEN     apda_nda IN (1803, 1860)
                            AND NVL (apda_val_string, 'F') IN ('P', 'B')
                       THEN
                           1
                       WHEN NVL (apda_val_string, 'F') IN ('T')
                       THEN
                           1
                       ELSE
                           0
                   END >
                   0;

        RETURN SIGN (NVL (l_rez, 0));
    END;

    FUNCTION Is_Apda_Equal (
        p_ap_id       NUMBER,
        p_app_id      NUMBER,
        p_nda_value   VARCHAR2:= 'T',
        p_list_nda    VARCHAR2:= '1796,2560,1795,1797,1798,1799,1800,1801,1802,1803,1856,1857,1858,1859,1860,1861,1862')
        RETURN NUMBER
    IS
        l_rez   NUMBER (10) := 0;
    BEGIN
        SELECT SUM (1)     AS doc_list_cnt
          INTO l_rez
          FROM ap_document
               JOIN ap_document_attr
                   ON     apda_apd = apd_id
                      AND ap_document_attr.history_status = 'A'
               JOIN uss_ndi.v_ndi_document_attr ON apda_nda = nda_id
         WHERE     apd_ap = p_ap_id
               AND apd_app = p_app_id
               --AND apd_ndt = 605 -- Анкета
               --AND nda_nng = 19  -- «Категорія отримувача соціальних послуг»
               AND NVL (apda_val_string, '_') IN
                       (    SELECT TRIM (
                                       REGEXP_SUBSTR (
                                           p_nda_value,
                                           '[^,]+',
                                           1,
                                           LEVEL))    AS i_Nda
                              FROM DUAL
                        CONNECT BY LEVEL <=
                                     LENGTH (
                                         REGEXP_REPLACE (p_nda_value,
                                                         '[^,]*'))
                                   + 1)
               AND nda_id IN
                       (    SELECT TRIM (REGEXP_SUBSTR (p_List_Nda,
                                                        '[^,]+',
                                                        1,
                                                        LEVEL))    AS i_Nda
                              FROM DUAL
                        CONNECT BY LEVEL <=
                                     LENGTH (
                                         REGEXP_REPLACE (p_List_Nda, '[^,]*'))
                                   + 1);

        RETURN SIGN (NVL (l_rez, 0));
    END;

    --========================================
    --#88644
    --При опрацюванні документа ndt_id=835:
    -- для перевірки права використовувати тільки правило №2, оскільки дані для застосування інших правил відсутні
    -- автоматичне заповнення поля «Спосіб надання» не виконувати – дані для цього відсутні
    FUNCTION Is_Exists_835 (p_pd_id pc_decision.pd_id%TYPE)
        RETURN BOOLEAN
    IS
        l_res   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_res
          FROM pc_decision
         WHERE pd_id = p_pd_id AND pd_nst = 835;

        RETURN l_res = 1;
    END;

    --========================================
    FUNCTION Get_SS_METHOD_old (p_at_id NUMBER)
        RETURN VARCHAR2
    IS
        l_res   VARCHAR2 (10);
    BEGIN
        SELECT COALESCE (API$APPEAL.get_doc_string (app.app_id, 801, 1869),
                         API$APPEAL.get_doc_string (app.app_id, 836, 3441),
                         '-')
          INTO l_res
          FROM TABLE (API$ANKETA.Get_Anketa_AT) app
         WHERE app.at_id = p_at_id AND app.app_tp = 'Z';

        RETURN l_res;
    END;

    --========================================
    PROCEDURE set_features_10 (p_at_id    NUMBER,
                               p_ats_id   NUMBER,
                               p_val      VARCHAR2)
    IS
        sqlrowcount   NUMBER;
    BEGIN
        UPDATE at_service ats
           SET ats.ats_ss_method = p_val
         WHERE ats.ats_id = p_ats_id;

        UPDATE at_features f
           SET atf_val_string = p_val
         WHERE f.atf_at = p_at_id AND atf_nft = 10;

        sqlrowcount := SQL%ROWCOUNT;

        IF sqlrowcount = 0
        THEN
            INSERT INTO at_features (atf_id,
                                     atf_at,
                                     atf_nft,
                                     atf_val_string)
                 VALUES (0,
                         p_at_id,
                         10,
                         p_val);
        END IF;
    END;

    --========================================
    PROCEDURE Check_SS_ALG01 (p_nrr_id   NUMBER,
                              p_at_ap    act.at_ap%TYPE,
                              p_at_id    act.at_id%TYPE,
                              p_ats_id   at_service.ats_id%TYPE)
    IS
    BEGIN
        IF API$APPEAL.get_ap_doc_list_cnt (p_at_ap, '835') > 0
        THEN
            RETURN;
        END IF;

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              --#110147
              SELECT x_id, x_text
                FROM (SELECT app.AT_ID                            AS x_id,
                             'Випадок не Екстрений (кризовий)'    AS x_text,
                             CASE
                                 WHEN    API$APPEAL.get_doc_string (app.APP_id,
                                                                    801,
                                                                    1870,
                                                                    'F') = 'T'
                                      OR API$APPEAL.get_doc_string (app.APP_id,
                                                                    802,
                                                                    1947,
                                                                    'F') = 'T'
                                      OR API$APPEAL.get_doc_string (app.APP_id,
                                                                    803,
                                                                    2032,
                                                                    'F') = 'T'
                                 THEN
                                     1
                                 ELSE
                                     0
                             END                                  is_crisis
                        FROM TABLE (API$ANKETA.Get_Anketa_AT) app
                             --#102222 + #105585
                             JOIN act a ON a.at_id = app.at_id
                       WHERE app.at_id = p_at_id)
            GROUP BY x_id, x_text
              HAVING SUM (is_crisis) = 0;

        /*
          SELECT x_id, listagg(x_text, ', ' ON OVERFLOW TRUNCATE '...' ) WITHIN GROUP (ORDER BY x_id) AS x_errors_list
          FROM (
                SELECT app.AT_ID as x_id,
                       'Випадок не Екстрений (кризовий)'
                       AS x_text          --1
                FROM  TABLE(API$ANKETA.Get_Anketa_AT) app
                --#102222 + #105585
                JOIN act a
                  ON a.at_id = app.at_id
                WHERE app.at_id = p_at_id
                      --and app_tp IN ('Z')
                      and a.at_sc = app.app_sc
                      and NOT (    API$APPEAL.get_doc_string(app.APP_id, 801, 1870, 'F') = 'T'
                                OR API$APPEAL.get_doc_string(app.APP_id, 802, 1947, 'F') = 'T'
                                OR API$APPEAL.get_doc_string(app.APP_id, 803, 2032, 'F') = 'T'
                              )
                )
          WHERE x_text IS NOT NULL
          GROUP BY x_id;
          */

        Set_at_right_log (p_nrr_id, p_at_id, p_ats_id);
    END;

    --========================================
    PROCEDURE Check_SS_ALG02 (p_nrr_id    NUMBER,
                              p_at_ap     act.at_ap%TYPE,
                              p_at_id     act.at_id%TYPE,
                              p_ats_id    at_service.ats_id%TYPE,
                              p_ats_nst   at_service.ats_nst%TYPE)
    IS
        l_apop_at_id      NUMBER;
        l_oks             NUMBER;
        l_is_no_service   VARCHAR2 (10) := 'F';
    BEGIN
        IF API$APPEAL.get_ap_doc_list_cnt (p_at_ap, '835') > 0
        THEN
            NULL;
        ELSIF Is_Check_ALG (p_at_id, p_ats_id, 'SS.ALG01')
        THEN
            RETURN;
        END IF;

        SELECT CASE WHEN MAX (t.apda_val_string) = 'T' THEN 1 ELSE 0 END
          INTO l_oks
          FROM ap_document_attr t
         WHERE     t.apda_ap = p_at_ap
               AND t.apda_nda = 1870
               AND t.history_status = 'A'
               AND EXISTS
                       (SELECT *
                          FROM ap_service s
                         WHERE     s.aps_ap = p_at_ap
                               AND s.history_status = 'A'
                               AND s.aps_nst = 420);

        IF (l_oks = 1)
        THEN
            SELECT MAX (t.at_id)
              INTO l_apop_at_id
              FROM act t
             WHERE     t.at_tp = 'OKS'
                   --AND t.at_st = 'TS'
                   AND t.at_st = 'TP'
                   AND t.at_main_link = p_at_id;

            IF l_apop_at_id IS NULL
            THEN
                SELECT MAX (t.at_id)
                  INTO l_apop_at_id
                  FROM act t
                 WHERE     t.at_tp = 'OKS'
                       --AND t.at_st = 'TS'
                       AND t.at_st = 'TP'
                       AND t.at_ap = p_at_ap;
            END IF;
        ELSE
            --#111551
            SELECT at_id, NVL (res, 'F')
              INTO l_apop_at_id, l_is_no_service
              FROM (SELECT at_id,
                           CASE
                               WHEN    (    Api$act.Get_Section_Attr_Val_Str (
                                                apop.at_id,
                                                843) =
                                            'T'
                                        AND AT_CONCLUSION_TP = 'V2')
                                    OR (    Api$act.Get_Section_Attr_Val_Str (
                                                apop.at_id,
                                                2062) =
                                            'T'
                                        AND AT_CONCLUSION_TP = 'V1')
                               THEN
                                   'T'
                           END    res
                      FROM act apop
                     WHERE     apop.at_tp = 'APOP'
                           AND apop.at_st = 'AS'
                           AND apop.at_main_link = p_at_id);
        END IF;

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, ', ' ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_at_id                                                AS x_id,
                             'Особа/сім’я не потребує надання соціальних послуг'    AS x_text --1
                        FROM DUAL
                       WHERE    (SELECT COUNT (1)
                                   FROM at_service ats
                                  WHERE     ats.ats_at = l_apop_at_id
                                        AND ats.history_status = 'A'
                                        AND ats.ats_nst = p_ats_nst) =
                                0
                             --#111551
                             OR l_is_no_service = 'T')
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_at_right_log (p_nrr_id, p_at_id, p_ats_id);
    END;

    /*

          UPDATE at_service ats_ SET
            ats_.ats_st =
              (SELECT CASE
                      WHEN Is_ari > 0 THEN 'PR'
                      WHEN is_apop = 0 THEN 'PR'
                      ELSE 'PP'
                      END
                FROM (  SELECT
                          ( SELECT COUNT(1) AS
                            FROM at_reject_info r
                            WHERE r.ari_ats = ats_.ats_id
                          )  AS Is_ari,
                          (SELECT CASE COUNT(1) WHEN 0 THEN 'PR' ELSE ats_.ats_st END
                            FROM at_service ats
                            WHERE ats.ats_at = l_apop_at_id
                              AND ats.history_status = 'A'
                              AND ats.ats_nst = ats.ats_nst
                          ) AS is_apop
                        FROM dual
                     )
              )
          WHERE ats_.ats_at = p_At_Id
            AND ats_.history_status = 'A';
    */

    --========================================
    PROCEDURE Check_SS_ALG03 (p_nrr_id   NUMBER,
                              p_at_ap    act.at_ap%TYPE,
                              p_at_id    act.at_id%TYPE,
                              p_ats_id   at_service.ats_id%TYPE)
    IS
        l_cnt801   NUMBER;
    BEGIN
        IF API$APPEAL.get_ap_doc_list_cnt (p_at_ap, '835') > 0
        THEN
            RETURN;
        ELSIF Is_Check_ALG (p_at_id, p_ats_id, 'SS.ALG01')
        THEN
            RETURN;
        ELSIF API$APPEAL.get_ap_doc_list_cnt (p_at_ap, '801') = 0
        THEN                  --Якщо немає 801 документу, то перевіряти нічого
            RETURN;
        END IF;

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, ', ' ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT app.AT_ID    AS x_id,
                             CASE API$CALC_RIGHT_AT.Get_Ap_Doc_String (
                                      app.at_ap,
                                      801,
                                      1869,
                                      '-')
                                 WHEN 'F'
                                 THEN
                                     'Безоплатно'
                                 WHEN 'C'
                                 THEN
                                     ''
                                 WHEN 'D'
                                 THEN
                                     'З установленням диференційованої плати'
                             END          AS x_text                        --1
                        FROM TABLE (API$ANKETA.Get_Anketa_AT) app
                             --#102222 + #105585
                             JOIN act a ON a.at_id = app.at_id
                       WHERE app.at_id = p_at_id --and app_tp IN ('Z')
                                                 AND a.at_sc = app.app_sc)
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_at_right_log (p_nrr_id, p_at_id, p_ats_id);
    -- Якщо у зверненні встановлено «платно» – результат перевірки = «Так».
    END;

    --========================================
    --Якщо у зверненні встановлено «безоплатно» – результат перевірки = «Так», якщо:
    --========================================
    PROCEDURE Check_SS_ALG04 (p_nrr_id   NUMBER,
                              p_at_ap    act.at_ap%TYPE,
                              p_at_id    act.at_id%TYPE,
                              p_ats_id   at_service.ats_id%TYPE)
    IS
    BEGIN
        IF API$APPEAL.get_ap_doc_list_cnt (p_at_ap, '835') > 0
        THEN
            RETURN;
        ELSIF Is_Check_ALG (p_at_id, p_ats_id, 'SS.ALG01')
        THEN
            RETURN;
        END IF;

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, ', ' ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT app.AT_ID                             AS x_id,
                             'Випадок не Екстрений (кризовий)'     AS x_text --1
                        FROM TABLE (API$ANKETA.Get_Anketa_AT) app
                             --#102222 + #105585
                             JOIN act a ON a.at_id = app.at_id
                       WHERE     app.at_id = p_at_id
                             --and app_tp IN ('Z')
                             AND a.at_sc = app.app_sc
                             AND NOT (   API$CALC_RIGHT_AT.Get_Ap_Doc_String (
                                             app.at_ap,
                                             801,
                                             1870,
                                             'F') = 'T'
                                      OR API$CALC_RIGHT_AT.Get_Ap_Doc_String (
                                             app.at_ap,
                                             802,
                                             1947,
                                             'F') = 'T'
                                      OR API$CALC_RIGHT_AT.Get_Ap_Doc_String (
                                             app.at_ap,
                                             803,
                                             2032,
                                             'F') = 'T'))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_at_right_log (p_nrr_id, p_at_id, p_ats_id);
    -- Якщо у зверненні встановлено «платно» – результат перевірки = «Так».
    END;

    --========================================
    --5) Право на безоплатне надання соціальних послуг підтверджено (послуга безоплатна)
    -- обрана у зверненні соціальна послуга має значення ознаки «Послуга безоплатна для всіх категорій отримувачів» = «Так» ndi_service_type.nst_is_payed=F (файл «Перелік соц_послуг_new.xlsx») --- для результату «Ні» класифікація «попередження»
    PROCEDURE Check_SS_ALG05 (p_nrr_id   NUMBER,
                              p_at_ap    act.at_ap%TYPE,
                              p_at_id    act.at_id%TYPE,
                              p_ats_id   at_service.ats_id%TYPE)
    IS
    BEGIN
        IF API$APPEAL.get_ap_doc_list_cnt (p_at_ap, '835') > 0
        THEN
            RETURN;
        ELSIF Is_Check_ALG (p_at_id, p_ats_id, 'SS.ALG01')
        THEN
            RETURN;
        END IF;

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, ', ' ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_AT_ID AS x_id, 'Послуга платна' AS x_text                --1
                        FROM DUAL
                       WHERE (SELECT COUNT (1)
                                FROM uss_ndi.v_ndi_service_type
                                     JOIN at_service ON ats_nst = nst_id
                               WHERE     ats_at = p_at_id
                                     AND ats_id = p_ats_id
                                     AND nst_is_payed = 'T') >
                             0)
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        FOR d IN (SELECT * FROM tmp_errors_list)
        LOOP
            dbms_output_put_lines (
                   d.tel_text
                || ' at_id = '
                || p_at_id
                || ' ats_id = '
                || p_ats_id);
        END LOOP;

        Set_at_right_log (p_nrr_id, p_at_id, p_ats_id);
    END;

    --========================================
    --6) Право на безоплатне надання соціальних послуг підтверджено (заявник має відповідну категорію)
    -- у документі «Заява про надання соціальних послуг» ndt_id=801 вказано
    --  «Соціальних послуг потребує» nda_id in (1868)=«Особа» &
    --  «Послугу надати» nda_id in (1895)=«мені» (тобто заявнику) &
    -- в його «Анкета учасника звернення» ndt_id=605 хоча б один з атрибутів блоку «Категорія отримувача соціальних послуг» nda_nng in (19)=«Так» &
    --  у зверненні є пов’язаний до заявника документ, що підтверджує вказану категорію відповідно до розв’язки «Категорія отримувача-документ_0506.xlsx» --- для результату «Ні» класифікація «попередження»
    PROCEDURE Check_SS_ALG06 (p_nrr_id   NUMBER,
                              p_at_ap    act.at_ap%TYPE,
                              p_at_id    act.at_id%TYPE,
                              p_ats_id   at_service.ats_id%TYPE)
    IS
        l_def_arl_result   VARCHAR2 (10);
        l_qty              NUMBER;
    BEGIN
        IF API$APPEAL.get_ap_doc_list_cnt (p_at_ap, '835') > 0
        THEN
            RETURN;
        ELSIF Is_Check_ALG (p_at_id, p_ats_id, 'SS.ALG01')
        THEN
            RETURN;
        END IF;

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, ', ' ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_AT_ID                                   AS x_id,
                             'Заявник не має відповідної категорії'    AS x_text                                 --1
                        FROM DUAL
                       WHERE NOT EXISTS
                                 (SELECT 1
                                    FROM TABLE (API$ANKETA.Get_Anketa_AT) app
                                   WHERE     app.at_ap = p_at_ap
                                         AND app_tp IN ('Z')
                                         AND API$CALC_RIGHT_AT.Get_Ap_Doc_String (
                                                 at_ap,
                                                 801,
                                                 1868,
                                                 '-') = 'Z' --Соціальних послуг потребує
                                         AND API$CALC_RIGHT_AT.Get_Ap_Doc_String (
                                                 at_ap,
                                                 801,
                                                 1895,
                                                 '-') = 'Z'   --Послугу надати
                                         AND (   API$CALC_RIGHT_AT.IsRecip_SS_doc_exists (
                                                     app.at_ap,
                                                     app.app_id) >
                                                 0
                                              OR API$CALC_RIGHT_AT.Is_Apda_Equal (
                                                     app.at_ap,
                                                     app.app_id,
                                                     'T',
                                                     '1796, 2560, 1795, 1799, 1800, 1801, 1856, 1857, 3266, 1859') >
                                                 0
                                              OR API$CALC_RIGHT_AT.Is_Apda_Equal (
                                                     app.at_ap,
                                                     app.app_id,
                                                     'P,B',
                                                     '1803, 1860') > 0
                                              OR (    API$CALC_RIGHT_AT.Is_Apda_Equal (
                                                          app.at_ap,
                                                          app.app_id,
                                                          'T',
                                                          '1862') > 0
                                                  AND API$APPEAL.get_doc_list_cnt (
                                                          app.app_id,
                                                          '832') >
                                                      0))))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        SELECT COUNT (*)
          INTO l_qty
          FROM tmp_errors_list
         WHERE p_AT_ID = tel_id;

        --#115283
        IF l_qty = 0
        THEN
            SELECT COUNT (1)
              INTO l_qty
              FROM TABLE (API$ANKETA.Get_Anketa_AT) app
             WHERE     at_id = p_at_id
                   AND app_tp IN ('Z')
                   AND API$CALC_RIGHT_AT.Get_Ap_Doc_String (at_ap,
                                                            801,
                                                            1868,
                                                            '-') = 'Z' --Соціальних послуг потребує
                   AND API$CALC_RIGHT_AT.Get_Ap_Doc_String (at_ap,
                                                            801,
                                                            1895,
                                                            '-') = 'Z' --Послугу надати
                   AND API$CALC_RIGHT_AT.IsRecip_SS_doc_exists (app.at_ap,
                                                                app.app_id) >
                       0;

            IF l_qty = 0
            THEN
                l_def_arl_result := 'F';
                g_def_arl_result := NVL (g_def_arl_result, l_def_arl_result);
            END IF;
        END IF;

        Set_at_right_log (p_nrr_id,
                          p_at_id,
                          p_ats_id,
                          l_def_arl_result);
    END;

    --========================================
    --7) Право на безоплатне надання соціальних послуг підтверджено (особа у заяві має відповідну категорію)
    -- у документі «Заява про надання соціальних послуг» ndt_id=801 вказано
    -- «Соціальних послуг потребує» nda_id in (1868)=«Особа» & значення атрибуту
    -- «Послугу надати» nda_id in (1895)=«моєму(їй) синові (доньці)»/«підопічному(ій)» &
    -- у зверненні є учасник з типом «Особа, що потребує соціальних послуг» & в його «Анкета учасника звернення» ndt_id=605 хоча б один з атрибутів блоку «Категорія отримувача соціальних послуг» nda_nng in (19)=«Так» & у зверненні є пов’язаний до даної особи документ, що підтверджує вказану категорію відповідно до розв’язки «Категорія отримувача-документ_0506.xlsx» --- для результату «Ні» класифікація «попередження»
    PROCEDURE Check_SS_ALG07 (p_nrr_id   NUMBER,
                              p_at_ap    act.at_ap%TYPE,
                              p_at_id    act.at_id%TYPE,
                              p_ats_id   at_service.ats_id%TYPE)
    IS
        l_def_arl_result   VARCHAR2 (10);
        l_qty              NUMBER;
    BEGIN
        IF API$APPEAL.get_ap_doc_list_cnt (p_at_ap, '835') > 0
        THEN
            RETURN;
        ELSIF Is_Check_ALG (p_at_id, p_ats_id, 'SS.ALG01')
        THEN
            RETURN;
        END IF;

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, ', ' ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT P_AT_ID                                  AS x_id,
                             'Особа не має відповідної категорії'     AS x_text                               --1
                        FROM DUAL
                       WHERE NOT EXISTS
                                 (SELECT 1
                                    FROM TABLE (API$ANKETA.Get_Anketa_AT) app
                                   WHERE     app.at_ap = p_at_ap
                                         --#115390
                                         AND app.app_tp IN ('OS')
                                         AND API$CALC_RIGHT_AT.Get_Ap_Doc_String (
                                                 app.at_ap,
                                                 801,
                                                 1868,
                                                 '-') = 'Z' --Соціальних послуг потребує
                                         AND API$CALC_RIGHT_AT.Get_Ap_Doc_String (
                                                 app.at_ap,
                                                 801,
                                                 1895,
                                                 '-') IN ('B', 'CHRG') --Послугу надати
                                         AND (   API$CALC_RIGHT_AT.IsRecip_SS_doc_exists (
                                                     app.at_ap,
                                                     app.app_id) >
                                                 0
                                              OR API$CALC_RIGHT_AT.Is_Apda_Equal (
                                                     app.at_ap,
                                                     app.app_id,
                                                     'T',
                                                     '1796, 2560, 1795, 1799, 1800, 1801, 1856, 1857, 3266, 1859') >
                                                 0
                                              OR API$CALC_RIGHT_AT.Is_Apda_Equal (
                                                     app.at_ap,
                                                     app.app_id,
                                                     'P,B',
                                                     '1803, 1860') > 0
                                              OR (    API$CALC_RIGHT_AT.Is_Apda_Equal (
                                                          app.at_ap,
                                                          app.app_id,
                                                          'T',
                                                          '1862') > 0
                                                  AND API$APPEAL.get_doc_list_cnt (
                                                          app.app_id,
                                                          '832') >
                                                      0))))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        SELECT COUNT (*)
          INTO l_qty
          FROM tmp_errors_list
         WHERE p_AT_ID = tel_id;

        --#115283
        IF l_qty = 0
        THEN
            SELECT COUNT (1)
              INTO l_qty
              FROM TABLE (API$ANKETA.Get_Anketa_AT) app
             WHERE     app.at_ap = p_at_ap
                   --#115390
                   AND app.app_tp IN ('OS')
                   AND API$CALC_RIGHT_AT.Get_Ap_Doc_String (app.at_ap,
                                                            801,
                                                            1868,
                                                            '-') = 'Z' --Соціальних послуг потребує
                   AND API$CALC_RIGHT_AT.Get_Ap_Doc_String (app.at_ap,
                                                            801,
                                                            1895,
                                                            '-') IN
                           ('B', 'CHRG')                      --Послугу надати
                   AND API$CALC_RIGHT_AT.IsRecip_SS_doc_exists (app.at_ap,
                                                                app.app_id) >
                       0;

            IF l_qty = 0
            THEN
                l_def_arl_result := 'F';
                g_def_arl_result := NVL (g_def_arl_result, l_def_arl_result);
            END IF;
        END IF;

        Set_at_right_log (p_nrr_id,
                          p_at_id,
                          p_ats_id,
                          l_def_arl_result);
    END;

    --========================================
    --8) Право на безоплатне надання соціальних послуг підтверджено (особа у повідомленні має відповідну категорію)
    -- у документі «Повідомлення/інформація про сім’ю/особу, яка перебуває у СЖО» ndt_id=802 вказано
    -- «Соціальних послуг потребує» nda_id in (1944)=«Особа» & у зверненні є учасник з типом
    -- «Особа, що потребує соціальних послуг» & в його «Анкета учасника звернення» ndt_id=605 хоча б один з атрибутів блоку «Категорія отримувача соціальних послуг» nda_nng in (19)=«Так» & у зверненні є пов’язаний до даної особи документ, що підтверджує вказану категорію відповідно до розв’язки «Категорія отримувача-документ_0506.xlsx» --- для результату «Ні» класифікація «попередження»
    PROCEDURE Check_SS_ALG08 (p_nrr_id   NUMBER,
                              p_at_ap    act.at_ap%TYPE,
                              p_at_id    act.at_id%TYPE,
                              p_ats_id   at_service.ats_id%TYPE)
    IS
    BEGIN
        IF API$APPEAL.get_ap_doc_list_cnt (p_at_ap, '835') > 0
        THEN
            RETURN;
        ELSIF Is_Check_ALG (p_at_id, p_ats_id, 'SS.ALG01')
        THEN
            RETURN;
        END IF;

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, ', ' ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_at_id                                  AS x_id,
                             'Особа не має відповідної категорії'     AS x_text                               --1
                        FROM DUAL
                       WHERE NOT EXISTS
                                 (SELECT 1
                                    FROM TABLE (API$ANKETA.Get_Anketa_AT) app
                                         JOIN
                                         TABLE (API$ANKETA.Get_Anketa_AT)
                                         app_os
                                             ON app_os.at_id = app.at_id
                                   WHERE     app.at_ap = p_at_ap
                                         AND app.app_tp IN ('Z')
                                         AND app_os.app_tp IN ('OS')
                                         AND API$CALC_RIGHT_AT.Get_Ap_Doc_String (
                                                 app.at_ap,
                                                 802,
                                                 1944,
                                                 '-') = 'Z' --Соціальних послуг потребує
                                         AND API$CALC_RIGHT_AT.IsRecip_SS_doc_exists (
                                                 app_os.at_ap,
                                                 app_os.app_id) >
                                             0))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_at_right_log (p_nrr_id, p_at_id, p_ats_id);
    END;

    --========================================
    --9) Право на безоплатне надання соціальних послуг підтверджено (всі члени сім’ї у заяві мають відповідні категорії)
    -- у документі «Заява про надання соціальних послуг» ndt_id=801 вказано
    -- «Соціальних послуг потребує» nda_id in (1868)=«Сім’я» &
    -- у зверненні є учасник(и) з типом «Особа, що потребує соціальних послуг» або «Член сім’ї» & в його (їх) «Анкета учасника звернення» ndt_id=605 хоча б один з атрибутів блоку «Категорія отримувача соціальних послуг» nda_nng in (19)=«Так» & у зверненні є пов’язані до даних осіб документи, що підтверджують вказану категорію відповідно до розв’язки «Категорія отримувача-документ_0506.xlsx» --- для результату «Ні» класифікація «попередження»
    PROCEDURE Check_SS_ALG09 (p_nrr_id   NUMBER,
                              p_at_ap    act.at_ap%TYPE,
                              p_at_id    act.at_id%TYPE,
                              p_ats_id   at_service.ats_id%TYPE)
    IS
        l_def_arl_result   VARCHAR2 (10);
        l_qty              NUMBER;
    BEGIN
        IF API$APPEAL.get_ap_doc_list_cnt (p_at_ap, '835') > 0
        THEN
            RETURN;
        ELSIF Is_Check_ALG (p_at_id, p_ats_id, 'SS.ALG01')
        THEN
            RETURN;
        END IF;

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, ', ' ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_at_id                                                    AS x_id,
                             'Не всі члени сім’ї у заяві мають відповідні категорії'    AS x_text                                               --1
                        FROM DUAL
                       WHERE NOT EXISTS
                                 (SELECT 1
                                    FROM TABLE (API$ANKETA.Get_Anketa_AT) app
                                   --#115390
                                   WHERE     app.at_ap = p_at_ap
                                         AND app.app_tp IN ('Z', 'AF')
                                         AND API$CALC_RIGHT_AT.Get_Ap_Doc_String (
                                                 app.at_ap,
                                                 801,
                                                 1868,
                                                 '-') = 'FM' --Соціальних послуг потребує
                                         AND API$CALC_RIGHT_AT.Get_Ap_Doc_String (
                                                 app.at_ap,
                                                 801,
                                                 1895,
                                                 '-') IN ('FM')
                                         AND (   API$CALC_RIGHT_AT.IsRecip_SS_doc_exists (
                                                     app.at_ap,
                                                     app.app_id) >
                                                 0
                                              OR API$CALC_RIGHT_AT.Is_Apda_Equal (
                                                     app.at_ap,
                                                     app.app_id,
                                                     'T',
                                                     '1796, 2560, 1795, 1799, 1800, 1801, 1856, 1857, 3266, 1859') >
                                                 0
                                              OR API$CALC_RIGHT_AT.Is_Apda_Equal (
                                                     app.at_ap,
                                                     app.app_id,
                                                     'P,B',
                                                     '1803, 1860') > 0
                                              OR (    API$CALC_RIGHT_AT.Is_Apda_Equal (
                                                          app.at_ap,
                                                          app.app_id,
                                                          'T',
                                                          '1862') > 0
                                                  AND API$APPEAL.get_doc_list_cnt (
                                                          app.app_id,
                                                          '832') >
                                                      0))
                                  UNION ALL
                                  SELECT 1
                                    FROM TABLE (API$ANKETA.Get_Anketa_AT) app_z
                                         JOIN
                                         TABLE (API$ANKETA.Get_Anketa_AT)
                                         app_fm
                                             ON app_z.at_ap = app_fm.at_ap
                                   --#115390
                                   WHERE     app_z.at_ap = p_at_ap
                                         AND app_z.app_tp IN ('Z', 'AF')
                                         AND app_fm.app_tp IN ('FM')
                                         AND API$CALC_RIGHT_AT.Get_Ap_Doc_String (
                                                 app_z.at_ap,
                                                 801,
                                                 1868,
                                                 '-') = 'FM' --Соціальних послуг потребує
                                         AND API$CALC_RIGHT_AT.Get_Ap_Doc_String (
                                                 app_z.at_ap,
                                                 801,
                                                 1895,
                                                 '-') IN ('FM')
                                         AND Api$appeal.Is_Person_Address_Equal (
                                                 app_z.app_id,
                                                 app_fm.app_id) >
                                             0
                                         AND (   API$CALC_RIGHT_AT.IsRecip_SS_doc_exists (
                                                     app_fm.at_ap,
                                                     app_fm.app_id) >
                                                 0
                                              OR API$CALC_RIGHT_AT.Is_Apda_Equal (
                                                     app_fm.at_ap,
                                                     app_fm.app_id,
                                                     'T',
                                                     '1796, 2560, 1795, 1799, 1800, 1801, 1856, 1857, 3266, 1859') >
                                                 0
                                              OR API$CALC_RIGHT_AT.Is_Apda_Equal (
                                                     app_fm.at_ap,
                                                     app_fm.app_id,
                                                     'P,B',
                                                     '1803, 1860') > 0
                                              OR (    API$CALC_RIGHT_AT.Is_Apda_Equal (
                                                          app_fm.at_ap,
                                                          app_fm.app_id,
                                                          'T',
                                                          '1862') > 0
                                                  AND API$APPEAL.get_doc_list_cnt (
                                                          app_fm.app_id,
                                                          '832') >
                                                      0))))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        SELECT COUNT (*)
          INTO l_qty
          FROM tmp_errors_list
         WHERE p_AT_ID = tel_id;

        --#115283
        IF l_qty = 0
        THEN
            SELECT COUNT (1)
              INTO l_qty
              FROM (SELECT 1
                      FROM TABLE (API$ANKETA.Get_Anketa_AT) app
                     --#115390
                     WHERE     app.at_ap = p_at_ap
                           AND app.app_tp IN ('Z', 'AF')
                           AND API$CALC_RIGHT_AT.Get_Ap_Doc_String (
                                   app.at_ap,
                                   801,
                                   1868,
                                   '-') = 'FM'    --Соціальних послуг потребує
                           AND API$CALC_RIGHT_AT.Get_Ap_Doc_String (
                                   app.at_ap,
                                   801,
                                   1895,
                                   '-') IN ('FM')
                           AND API$CALC_RIGHT_AT.IsRecip_SS_doc_exists (
                                   app.at_ap,
                                   app.app_id) >
                               0
                    UNION ALL
                    SELECT 1
                      FROM TABLE (API$ANKETA.Get_Anketa_AT)  app_z
                           JOIN TABLE (API$ANKETA.Get_Anketa_AT) app_fm
                               ON app_z.at_ap = app_fm.at_ap
                     --#115390
                     WHERE     app_z.at_ap = p_at_ap
                           AND app_z.app_tp IN ('Z', 'AF')
                           AND app_fm.app_tp IN ('FM')
                           AND API$CALC_RIGHT_AT.Get_Ap_Doc_String (
                                   app_z.at_ap,
                                   801,
                                   1868,
                                   '-') = 'FM'    --Соціальних послуг потребує
                           AND API$CALC_RIGHT_AT.Get_Ap_Doc_String (
                                   app_z.at_ap,
                                   801,
                                   1895,
                                   '-') IN ('FM')
                           AND Api$appeal.Is_Person_Address_Equal (
                                   app_z.app_id,
                                   app_fm.app_id) >
                               0
                           AND API$CALC_RIGHT_AT.IsRecip_SS_doc_exists (
                                   app_fm.at_ap,
                                   app_fm.app_id) >
                               0);

            IF l_qty = 0
            THEN
                l_def_arl_result := 'F';
                g_def_arl_result := NVL (g_def_arl_result, l_def_arl_result);
            END IF;
        END IF;

        Set_at_right_log (p_nrr_id,
                          p_at_id,
                          p_ats_id,
                          l_def_arl_result);
    END;

    --========================================
    --10) Право на безоплатне надання соціальних послуг підтверджено (особа та всі члени сім’ї у повідомленні мають відповідні категорії)
    -- у документі «Повідомлення/інформація про сім’ю/особу, яка перебуває у СЖО» ndt_id=802 вказано
    -- «Соціальних послуг потребує» nda_id in (1944)=«Сім’я» & у зверненні є учасник(и) з типом
    -- «Особа, що потребує соціальних послуг» або «Член сім’ї» & в його (їх) «Анкета учасника звернення» ndt_id=605 хоча б один з атрибутів блоку «Категорія отримувача соціальних послуг» nda_nng in (19)=«Так» & у зверненні є пов’язані до даних осіб документи, що підтверджують вказану категорію відповідно до розв’язки «Категорія отримувача-документ_0506.xlsx» --- для результату «Ні» класифікація «попередження»
    PROCEDURE Check_SS_ALG10 (p_nrr_id   NUMBER,
                              p_at_ap    act.at_ap%TYPE,
                              p_at_id    act.at_id%TYPE,
                              p_ats_id   at_service.ats_id%TYPE)
    IS
    BEGIN
        IF API$APPEAL.get_ap_doc_list_cnt (p_at_ap, '835') > 0
        THEN
            RETURN;
        ELSIF Is_Check_ALG (p_at_id, p_ats_id, 'SS.ALG01')
        THEN
            RETURN;
        END IF;

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, ', ' ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_at_id                                                                    AS x_id,
                             'Не всі особа та члени сім’ї у повідомленні мають відповідні категорії'    AS x_text                                                             --1
                        FROM DUAL
                       WHERE NOT EXISTS
                                 (SELECT 1
                                    FROM TABLE (API$ANKETA.Get_Anketa_AT) app
                                         JOIN
                                         TABLE (API$ANKETA.Get_Anketa_AT)
                                         app_os
                                             ON app_os.at_id = app.at_id
                                   WHERE     app.at_ap = p_at_ap
                                         AND app.app_tp IN ('Z')
                                         AND app_os.app_tp IN ('OS', 'FM')
                                         AND API$CALC_RIGHT_AT.Get_Ap_Doc_String (
                                                 app.at_ap,
                                                 802,
                                                 1944,
                                                 '-') = 'FM' --Соціальних послуг потребує
                                         AND API$CALC_RIGHT_AT.IsRecip_SS_doc_exists (
                                                 app_os.at_ap,
                                                 app_os.app_id) >
                                             0))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_at_right_log (p_nrr_id, p_at_id, p_ats_id);
    END;

    --========================================
    --11) Право на безоплатне надання соціальних послуг підтверджено (всі члени сім’ї у повідомленні мають відповідні категорії)
    -- у документі «Повідомлення/інформація про сім’ю/особу, яка перебуває у СЖО» ndt_id=802 вказано
    -- «Соціальних послуг потребує» nda_id in (1944)=«Сім’я» & у зверненні
    -- немає учасника з типом «Особа, що потребує соціальних послуг» &
    -- є учасник(и) з типом «Член сім’ї» & в його (їх) «Анкета учасника звернення» ndt_id=605 хоча б один з атрибутів блоку «Категорія отримувача соціальних послуг» nda_nng in (19)=«Так» & у зверненні є пов’язані до даних осіб документи, що підтверджують вказану категорію відповідно до розв’язки «Категорія отримувача-документ_0506.xlsx» --- для результату «Ні» класифікація «попередження»  --========================================
    PROCEDURE Check_SS_ALG11 (p_nrr_id   NUMBER,
                              p_at_ap    act.at_ap%TYPE,
                              p_at_id    act.at_id%TYPE,
                              p_ats_id   at_service.ats_id%TYPE)
    IS
    BEGIN
        IF API$APPEAL.get_ap_doc_list_cnt (p_at_ap, '835') > 0
        THEN
            RETURN;
        ELSIF API$APPEAL.get_ap_doc_list_cnt (p_at_ap, '802') = 0
        THEN
            RETURN;
        ELSIF Is_Check_ALG (p_at_id, p_ats_id, 'SS.ALG01')
        THEN
            RETURN;
        END IF;

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, ', ' ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT DISTINCT
                             p_AT_ID    AS x_id,
                             CASE
                                 WHEN     need_ss_tp = 'FM'
                                      AND SS_doc_exists > 0
                                      AND Is_OS_exists = 0
                                 THEN
                                     ''
                                 ELSE
                                     'Не всі особа та члени сім’ї у повідомленні мають відповідні категорії'
                             END        AS x_text                          --1
                        FROM (SELECT API$CALC_RIGHT_AT.Get_Ap_Doc_String (
                                         app.at_ap,
                                         802,
                                         1944,
                                         '-')                                AS need_ss_tp,
                                     API$CALC_RIGHT_AT.IsRecip_SS_doc_exists (
                                         app_fm.at_ap,
                                         app_fm.app_id)                      AS SS_doc_exists,
                                     (SELECT COUNT (1)
                                        FROM TABLE (API$ANKETA.Get_Anketa_AT)
                                             app_os
                                       WHERE     app_os.at_ap = app.at_ap
                                             AND app_os.app_tp IN ('OS'))    AS Is_OS_exists
                                FROM TABLE (API$ANKETA.Get_Anketa_AT) app
                                     JOIN
                                     TABLE (API$ANKETA.Get_Anketa_AT) app_fm
                                         ON app_fm.at_id = app.at_id
                               WHERE     app.at_ap = p_at_ap
                                     AND app.app_tp IN ('Z')
                                     AND app_fm.app_tp IN ('FM')))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_at_right_log (p_nrr_id, p_at_id, p_ats_id);
    END;

    --========================================
    PROCEDURE Check_SS_ALG12 (p_nrr_id   NUMBER,
                              p_at_ap    act.at_ap%TYPE,
                              p_at_id    act.at_id%TYPE,
                              p_ats_id   at_service.ats_id%TYPE)
    IS
        l_qty   NUMBER;
    BEGIN
        /*
            IF API$APPEAL.get_ap_doc_list_cnt(p_at_ap, '835') > 0 THEN
              RETURN;
            ELSIF Is_Check_ALG(p_at_id, p_ats_id, 'SS.ALG01') THEN
              RETURN;
        --    ELSIF Get_SS_METHOD(p_at_id)!='F' THEN
        --      RETURN;
            END IF;
        */
        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, ', ' ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (SELECT p_AT_ID                        AS x_id,
                             'Не виконано жодну з умов'     AS x_text                          --1
                        FROM DUAL
                       WHERE NOT EXISTS
                                 (SELECT nrr_alg,
                                         arl.arl_calc_result,
                                         arl.arl_calc_info
                                    FROM at_right_log arl
                                         JOIN uss_ndi.v_ndi_right_rule
                                             ON nrr_id = arl.arl_nrr
                                   WHERE     arl.arl_at = p_at_id
                                         AND arl.arl_ats = p_ats_id
                                         AND nrr_alg IN ('SS.ALG01',
                                                         'SS.ALG04',
                                                         'SS.ALG05',
                                                         'SS.ALG06',
                                                         'SS.ALG07',
                                                         'SS.ALG08',
                                                         'SS.ALG09',
                                                         'SS.ALG10',
                                                         'SS.ALG11',
                                                         'SS.ALG13')
                                         AND arl.arl_calc_result = 'T'))
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        SELECT COUNT (*)
          INTO l_qty
          FROM tmp_errors_list
         WHERE p_AT_ID = tel_id;

        Set_at_right_log (p_nrr_id,
                          p_at_id,
                          p_ats_id,
                          g_def_arl_result);
    END;

    --========================================
    PROCEDURE Check_SS_ALG13 (p_nrr_id   NUMBER,
                              p_at_ap    act.at_ap%TYPE,
                              p_at_id    act.at_id%TYPE,
                              p_ats_id   at_service.ats_id%TYPE)
    IS
    BEGIN
        IF API$APPEAL.get_ap_doc_list_cnt (p_at_ap, '835') > 0
        THEN
            RETURN;
        --    ELSIF Get_SS_METHOD(p_at_id)!='F' THEN
        --      RETURN;
        END IF;

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, ', ' ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (WITH
                          lw
                          AS
                              (SELECT ank.at_id,
                                      (SELECT MAX (
                                                  CASE
                                                      WHEN Ank.AgeYear < 6
                                                      THEN
                                                          lw.lgw_6year_sum
                                                      WHEN Ank.AgeYear < 18
                                                      THEN
                                                          lw.lgw_18year_sum
                                                      WHEN    Ank.Workable =
                                                              'F'
                                                           OR Ank.NotWorkable =
                                                              'T'
                                                      THEN
                                                          lw.lgw_work_unable_sum
                                                      ELSE
                                                          lw.lgw_work_able_sum
                                                  END)    AS living_wage
                                         FROM uss_ndi.v_ndi_living_wage lw
                                        WHERE     Ank.calc_dt >=
                                                  lw.lgw_start_dt
                                              AND (   Ank.calc_dt <=
                                                      lw.lgw_stop_dt
                                                   OR lw.lgw_stop_dt IS NULL)
                                              AND lw.history_status = 'A')    AS living_wage
                                 FROM TABLE (api$Anketa.Get_Anketa_at) Ank
                                WHERE     ank.at_id = p_at_id
                                      AND ank.app_tp IN ('Z', 'OS'))
                      SELECT lw.at_id    AS x_id,
                             CASE
                                 WHEN aic_at IS NULL
                                 THEN
                                     'Не розраховано середньомісячний сукупний дохід'
                                 WHEN NOT (aic_member_month_income <=
                                           lw.living_wage * 2)
                                 THEN
                                     --WHEN NOT (pic_member_month_income > lw.living_wage * 2 AND pic_member_month_income <= lw.living_wage * 4) THEN
                                     --WHEN NOT (pic_member_month_income > lw.living_wage * 4) THEN
                                     'Не виконано умову - середньомісячний сукупний дохід < 2 прожиткових мінімумів'
                             END         AS x_text                         --1
                        FROM lw LEFT JOIN at_income_calc ON lw.at_id = aic_at)
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        Set_at_right_log (p_nrr_id, p_at_id, p_ats_id);
    END;

    --========================================

    /*
    create table AT_CALC_RIGHTS_LOG_AUD
  (
    at_id                   NUMBER(14),
    x_text                  VARCHAR2(101),
    ageyear                 NUMBER(10),
    workable                VARCHAR2(10),
    notworkable             VARCHAR2(10),
    calc_dt                 DATE,
    aic_member_month_income NUMBER(18,2),
    living_wage             NUMBER,
    aud_date                DATE,
    nrr_id                  NUMBER,
    ats_id                  NUMBER,
    alg_code                VARCHAR2(50),
    aud_id                  NUMBER generated always as identity,
    aud_log_ses             VARCHAR2(50),
    call_stack              VARCHAR2(4000)
  );
    PROCEDURE Check_SS_ALG14_AUD(p_nrr_id number, p_at_ap act.at_ap%type, p_at_id act.at_id%TYPE, p_ats_id at_service.ats_id%TYPE) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
      insert into at_calc_rights_log_aud
        (at_id, x_text, ageyear, workable, notworkable, calc_dt, aic_member_month_income, living_wage, aud_date, nrr_id, ats_id, alg_code, aud_log_ses, call_stack)
      SELECT *
          FROM (
                  WITH lw AS (
                  SELECT ank.at_id,
                         Ank.AgeYear,
                         Ank.Workable,
                         Ank.NotWorkable,
                         Ank.calc_dt,
                        (SELECT  MAX(CASE
                                     WHEN Ank.AgeYear < 6 THEN lw.lgw_6year_sum
                                     WHEN Ank.AgeYear < 18 THEN lw.lgw_18year_sum
                                     WHEN Ank.Workable = 'F' OR Ank.NotWorkable = 'T'THEN  lw.lgw_work_unable_sum
                                     ELSE lw.lgw_work_able_sum
                                     END
                                    ) AS living_wage
                         FROM uss_ndi.v_ndi_living_wage lw
                         WHERE Ank.calc_dt >= lw.lgw_start_dt AND (Ank.calc_dt <= lw.lgw_stop_dt OR lw.lgw_stop_dt IS NULL) AND lw.history_status = 'A')
                         AS living_wage
                  FROM TABLE(api$Anketa.Get_Anketa_at) Ank
                  WHERE ank.at_id = p_at_id
                    AND ank.app_tp  IN ('Z','OS'))
                SELECT lw.at_id as x_id,
                       CASE
                       WHEN aic_at IS NULL THEN
                         'Не розраховано середньомісячний сукупний дохід'
                       WHEN NOT (aic_member_month_income > lw.living_wage * 4) THEN
                         'Не виконано умову - 2 прожиткові мінімуми < середньомісячний сукупний дохід < 4 прожиткових мінімумів'
                       END AS x_text          --1
                       ,AgeYear
                       ,Workable
                       ,NotWorkable
                       ,calc_dt
                       ,aic_member_month_income
                       ,living_wage
                       ,sysdate aud_date
                       ,p_nrr_id nrr_id
                       ,p_ats_id ats_id
                       ,'SS_ALG14' alg_code
                       ,gLogSesID
                       ,SUBSTR(DBMS_UTILITY.format_call_stack(),121,4000)
                FROM   lw
                  LEFT JOIN at_income_calc ON lw.at_id = aic_at
                );

      COMMIT;
    END;
    */

    PROCEDURE Check_SS_ALG14 (p_nrr_id   NUMBER,
                              p_at_ap    act.at_ap%TYPE,
                              p_at_id    act.at_id%TYPE,
                              p_ats_id   at_service.ats_id%TYPE)
    IS
        l_qty   NUMBER;
    BEGIN
        IF API$APPEAL.get_ap_doc_list_cnt (p_at_ap, '835') > 0
        THEN
            RETURN;
        ELSIF Is_Check_ALG (p_at_id, p_ats_id, 'SS.ALG12')
        THEN
            RETURN;
        --    ELSIF Get_SS_METHOD(p_at_id)!='C' THEN
        --      RETURN;
        END IF;

        --Check_SS_ALG14_AUD(p_nrr_id, p_at_ap, p_at_id, p_ats_id);

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, ', ' ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (WITH
                          lw
                          AS
                              (SELECT ank.at_id,
                                      (SELECT MAX (
                                                  CASE
                                                      WHEN Ank.AgeYear < 6
                                                      THEN
                                                          lw.lgw_6year_sum
                                                      WHEN Ank.AgeYear < 18
                                                      THEN
                                                          lw.lgw_18year_sum
                                                      WHEN    Ank.Workable =
                                                              'F'
                                                           OR Ank.NotWorkable =
                                                              'T'
                                                      THEN
                                                          lw.lgw_work_unable_sum
                                                      ELSE
                                                          lw.lgw_work_able_sum
                                                  END)    AS living_wage
                                         FROM uss_ndi.v_ndi_living_wage lw
                                        WHERE     Ank.calc_dt >=
                                                  lw.lgw_start_dt
                                              AND (   Ank.calc_dt <=
                                                      lw.lgw_stop_dt
                                                   OR lw.lgw_stop_dt IS NULL)
                                              AND lw.history_status = 'A')    AS living_wage
                                 FROM TABLE (api$Anketa.Get_Anketa_at) Ank
                                WHERE     ank.at_id = p_at_id
                                      AND ank.app_tp IN ('Z', 'OS'))
                      SELECT lw.at_id    AS x_id,
                             CASE
                                 WHEN aic_at IS NULL
                                 THEN
                                     'Не розраховано середньомісячний сукупний дохід'
                                 WHEN NOT (aic_member_month_income >
                                           lw.living_wage * 4)
                                 THEN
                                     'Не виконано умову - 2 прожиткові мінімуми < середньомісячний сукупний дохід < 4 прожиткових мінімумів'
                             END         AS x_text                         --1
                        FROM lw LEFT JOIN at_income_calc ON lw.at_id = aic_at)
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        l_qty := SQL%ROWCOUNT;

        Set_at_right_log (p_nrr_id, p_at_id, p_ats_id);
    END;

    --========================================
    /*
    PROCEDURE Check_SS_ALG15_AUD(p_nrr_id number, p_at_ap act.at_ap%type, p_at_id act.at_id%TYPE, p_ats_id at_service.ats_id%TYPE) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
      insert into at_calc_rights_log_aud
        (at_id, x_text, ageyear, workable, notworkable, calc_dt, aic_member_month_income, living_wage, aud_date, nrr_id, ats_id, alg_code, aud_log_ses, call_stack)
      SELECT *
          FROM (
                  WITH lw AS (
                  SELECT ank.at_id,
                         Ank.AgeYear,
                         Ank.Workable,
                         Ank.NotWorkable,
                         Ank.calc_dt,
                        (SELECT  MAX(CASE
                                     WHEN Ank.AgeYear < 6 THEN lw.lgw_6year_sum
                                     WHEN Ank.AgeYear < 18 THEN lw.lgw_18year_sum
                                     WHEN Ank.Workable = 'F' OR Ank.NotWorkable = 'T'THEN  lw.lgw_work_unable_sum
                                     ELSE lw.lgw_work_able_sum
                                     END
                                    ) AS living_wage
                         FROM uss_ndi.v_ndi_living_wage lw
                         WHERE Ank.calc_dt >= lw.lgw_start_dt AND (Ank.calc_dt <= lw.lgw_stop_dt OR lw.lgw_stop_dt IS NULL) AND lw.history_status = 'A')
                         AS living_wage
                  FROM TABLE(api$Anketa.Get_Anketa_at) Ank
                  WHERE ank.at_id = p_at_id
                    AND ank.app_tp  IN ('Z','OS'))
                SELECT lw.at_id as x_id,
                       CASE
                       WHEN aic_at IS NULL THEN
                         'Не розраховано середньомісячний сукупний дохід'
                       WHEN aic_member_month_income <= lw.living_wage * 2 THEN
                         'Не виконано умову - середньомісячний сукупний дохід < 2 прожиткових мінімумів'
                       WHEN aic_member_month_income > lw.living_wage * 4 THEN
                         'Не виконано умову - середньомісячний сукупний дохід > 4 прожиткових мінімумів'
                       END AS x_text          --1
                       ,AgeYear
                       ,Workable
                       ,NotWorkable
                       ,calc_dt
                       ,aic_member_month_income
                       ,living_wage
                       ,sysdate aud_date
                       ,p_nrr_id nrr_id
                       ,p_ats_id ats_id
                       ,'SS_ALG15' alg_code
                       ,gLogSesID
                       ,SUBSTR(DBMS_UTILITY.format_call_stack(),121,4000)
                FROM   lw
                  LEFT JOIN at_income_calc ON lw.at_id = aic_at
                );

      COMMIT;
    END;
    */

    PROCEDURE Check_SS_ALG15 (p_nrr_id   NUMBER,
                              p_at_ap    act.at_ap%TYPE,
                              p_at_id    act.at_id%TYPE,
                              p_ats_id   at_service.ats_id%TYPE)
    IS
        l_qty   NUMBER;
    BEGIN
        IF API$APPEAL.get_ap_doc_list_cnt (p_at_ap, '835') > 0
        THEN
            RETURN;
        ELSIF Is_Check_ALG (p_at_id, p_ats_id, 'SS.ALG12')
        THEN
            RETURN;
        --    ELSIF Get_SS_METHOD(p_at_id)!='D' THEN
        --      RETURN;
        END IF;

        --Check_SS_ALG15_AUD(p_nrr_id, p_at_ap, p_at_id, p_ats_id);

        INSERT INTO tmp_errors_list (tel_id, tel_text)
              SELECT x_id,
                     LISTAGG (x_text, ', ' ON OVERFLOW TRUNCATE '...')
                         WITHIN GROUP (ORDER BY x_id)    AS x_errors_list
                FROM (WITH
                          lw
                          AS
                              (SELECT ank.at_id,
                                      (SELECT MAX (
                                                  CASE
                                                      WHEN Ank.AgeYear < 6
                                                      THEN
                                                          lw.lgw_6year_sum
                                                      WHEN Ank.AgeYear < 18
                                                      THEN
                                                          lw.lgw_18year_sum
                                                      WHEN    Ank.Workable =
                                                              'F'
                                                           OR Ank.NotWorkable =
                                                              'T'
                                                      THEN
                                                          lw.lgw_work_unable_sum
                                                      ELSE
                                                          lw.lgw_work_able_sum
                                                  END)    AS living_wage
                                         FROM uss_ndi.v_ndi_living_wage lw
                                        WHERE     Ank.calc_dt >=
                                                  lw.lgw_start_dt
                                              AND (   Ank.calc_dt <=
                                                      lw.lgw_stop_dt
                                                   OR lw.lgw_stop_dt IS NULL)
                                              AND lw.history_status = 'A')    AS living_wage
                                 FROM TABLE (api$Anketa.Get_Anketa_at) Ank
                                WHERE     ank.at_id = p_at_id
                                      AND ank.app_tp IN ('Z', 'OS'))
                      SELECT lw.at_id    AS x_id,
                             CASE
                                 WHEN aic_at IS NULL
                                 THEN
                                     'Не розраховано середньомісячний сукупний дохід'
                                 WHEN aic_member_month_income <=
                                      lw.living_wage * 2
                                 THEN
                                     'Не виконано умову - середньомісячний сукупний дохід < 2 прожиткових мінімумів'
                                 WHEN aic_member_month_income >
                                      lw.living_wage * 4
                                 THEN
                                     'Не виконано умову - середньомісячний сукупний дохід > 4 прожиткових мінімумів'
                             END         AS x_text                         --1
                        FROM lw LEFT JOIN at_income_calc ON lw.at_id = aic_at)
               WHERE x_text IS NOT NULL
            GROUP BY x_id;

        l_qty := SQL%ROWCOUNT;

        Set_at_right_log (p_nrr_id, p_at_id, p_ats_id);
    END;

    --========================================
    FUNCTION BOOLEAN_TO_CHAR (STATUS IN BOOLEAN)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN CASE STATUS
                   WHEN TRUE THEN 'TRUE'
                   WHEN FALSE THEN 'FALSE'
                   ELSE 'NULL'
               END;
    END;

    /*
    PROCEDURE Check_SS_ALG16_AUD(p_nrr_id number, p_at_ap act.at_ap%type, p_at_id act.at_id%TYPE, p_ats_id at_service.ats_id%TYPE, p_Is_Check_ALG14 in boolean, p_Is_Check_ALG15 in boolean) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
     l_text VARCHAR2(500);
    BEGIN
      l_text :=  'Is_Check_ALG14='||API$CALC_RIGHT_AT.BOOLEAN_TO_CHAR(p_Is_Check_ALG14)||', Is_Check_ALG15='||API$CALC_RIGHT_AT.BOOLEAN_TO_CHAR(p_Is_Check_ALG15);

      insert into at_calc_rights_log_aud
        (at_id, x_text, aud_date, nrr_id, ats_id, alg_code, aud_log_ses, call_stack)
      values(p_at_id
             ,l_Text
             ,sysdate
             ,p_nrr_id
             ,p_ats_id
             ,'SS_ALG16'
             ,gLogSesID
             ,SUBSTR(DBMS_UTILITY.format_call_stack(),121,4000));

      COMMIT;
    END;
    */

    PROCEDURE Check_SS_ALG16 (p_nrr_id   NUMBER,
                              p_at_ap    act.at_ap%TYPE,
                              p_at_id    act.at_id%TYPE,
                              p_ats_id   at_service.ats_id%TYPE)
    IS
        l_Is_Check_ALG14   BOOLEAN;
        l_Is_Check_ALG15   BOOLEAN;
        l_qty              NUMBER;
    BEGIN
        l_Is_Check_ALG14 := Is_Check_ALG (p_at_id, p_ats_id, 'SS.ALG14');
        l_Is_Check_ALG15 := Is_Check_ALG (p_at_id, p_ats_id, 'SS.ALG15');

        --F  безоплатно
        --C  платно
        --D  з установленням диференційованої плати
        --Check_SS_ALG16_AUD(p_nrr_id, p_at_ap, p_at_id, p_ats_id, l_Is_Check_ALG14, l_Is_Check_ALG15);


        IF Is_Check_ALG (p_at_id, p_ats_id, 'SS.ALG12')
        THEN
            set_features_10 (p_at_id, p_ats_id, 'F');
        ELSIF API$APPEAL.get_ap_doc_list_cnt (p_at_ap, '835') > 0
        THEN
            set_features_10 (p_at_id, p_ats_id, 'F');
        ELSIF l_Is_Check_ALG14
        THEN
            set_features_10 (p_at_id, p_ats_id, 'C');
        ELSIF l_Is_Check_ALG15
        THEN
            set_features_10 (p_at_id, p_ats_id, 'D');
        ELSE
            set_features_10 (p_at_id, p_ats_id, NULL);

            INSERT INTO tmp_errors_list (tel_id, tel_text)
                SELECT p_at_id                       AS x_id,
                       'Не визначено тип оплати'     AS x_errors_list
                  FROM DUAL;
        END IF;

        SELECT COUNT (*)
          INTO l_qty
          FROM tmp_errors_list
         WHERE p_AT_ID = tel_id;

        Set_at_right_log (p_nrr_id,
                          p_at_id,
                          p_ats_id,
                          g_def_arl_result);
    END;

    --========================================
    --Перерахунок результату контроля по послузі після корегування arl_result
    PROCEDURE Recalc_SS_ALG (p_at_id act.at_id%TYPE)
    IS
        l_result           VARCHAR2 (2000) := 'T';
        l_info             VARCHAR2 (2000);
        l_at_ap            NUMBER;
        l_Is_Check_ALG14   BOOLEAN;
        l_Is_Check_ALG15   BOOLEAN;

        CURSOR ats IS
            SELECT ats_id, arl_id
              FROM at_service
                   JOIN at_right_log arl ON arl_ats = ats_id
                   JOIN uss_ndi.v_ndi_right_rule
                       ON nrr_id = arl_nrr AND nrr_alg = 'SS.ALG16'
             WHERE ats_at = p_at_id;
    BEGIN
        SELECT t.at_ap
          INTO l_at_ap
          FROM act t
         WHERE t.at_Id = p_at_id;

        --F  безоплатно
        --C  платно
        --D  з установленням диференційованої плати

        FOR rec IN ats
        LOOP
            l_result := 'T';
            l_Is_Check_ALG14 :=
                Is_Check_ALG (p_at_id, rec.ats_id, 'SS.ALG14');
            l_Is_Check_ALG15 :=
                Is_Check_ALG (p_at_id, rec.ats_id, 'SS.ALG15');

            --Check_SS_ALG16_AUD(null, null, p_at_id, rec.ats_id, l_Is_Check_ALG14, l_Is_Check_ALG15);

            IF Is_Check_ALG (p_at_id, rec.ats_id, 'SS.ALG12')
            THEN
                set_features_10 (p_at_id, rec.ats_id, 'F');
            ELSIF API$APPEAL.get_ap_doc_list_cnt (l_at_ap, '835') > 0
            THEN
                set_features_10 (p_at_id, rec.ats_id, 'F');
            ELSIF l_Is_Check_ALG14
            THEN
                set_features_10 (p_at_id, rec.ats_id, 'C');
            ELSIF l_Is_Check_ALG15
            THEN
                set_features_10 (p_at_id, rec.ats_id, 'D');
            ELSE
                l_result := 'F';
                l_info := 'Не визначено тип оплати';
            END IF;

            UPDATE at_right_log arl
               SET arl.arl_calc_result = l_result,
                   arl.arl_result = l_result,
                   arl.arl_calc_info = l_info
             WHERE arl.arl_id = rec.arl_id;

            UPDATE at_service s
               SET s.ats_st =
                       CASE (SELECT COUNT (1)
                               FROM at_right_log  arl
                                    JOIN uss_ndi.v_ndi_right_rule nrr
                                        ON     nrr.nrr_id = arl_nrr
                                           AND nrr.nrr_tp = 'E'
                              WHERE     arl.arl_ats = s.ats_id
                                    AND arl.arl_result = 'F')
                           WHEN 0
                           THEN
                               'PP'
                           ELSE
                               'PR'
                       END
             WHERE s.ats_id = rec.ats_id AND s.ats_st IN ('R', 'PP', 'PR');
        /*
         кнопка «Підтвердити право»:
        - для всіх послуг, надання яких потребує отримувач, зміна N => PP («Проєкт надання»)
        - для всіх послуг, надання яких не потребує отримувач, зміна N => PR («Проєкт відмови»)
        */
        END LOOP;

        api$act.Recalc_Pdsp_Ats_St (p_at_id);
    END;

    --========================================
    PROCEDURE Check_Other (p_nrr_id NUMBER, p_pd pc_decision.pd_id%TYPE)
    IS
    BEGIN
        MERGE INTO pd_right_log
             USING (SELECT x_id AS b_pd, p_nrr_id AS b_nrr, 'F' AS b_result
                      FROM tmp_work_ids
                     WHERE x_id = p_pd)
                ON (prl_pd = b_pd AND prl_nrr = b_nrr)
        WHEN MATCHED
        THEN
            UPDATE SET
                prl_calc_result = b_result,
                prl_hs_rewrite = NULL,
                prl_result = b_result
        WHEN NOT MATCHED
        THEN
            INSERT     (prl_id,
                        prl_pd,
                        prl_nrr,
                        prl_result,
                        prl_calc_result)
                VALUES (0,
                        b_pd,
                        b_nrr,
                        b_result,
                        b_result);
    END;

    --========================================
    PROCEDURE init_right_for_act (p_mode           INTEGER, --1=з p_at_id, 2=з таблиці tmp_work_ids
                                  p_at_id          act.at_id%TYPE,
                                  p_messages   OUT SYS_REFCURSOR)
    IS
        l_messages   TOOLS.t_messages := TOOLS.t_messages ();
        l_cnt        INTEGER;
        l_hs         histsession.hs_id%TYPE;
    BEGIN
        gLogSesID := TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS');
        l_messages.delete;

        IF p_mode = 1 AND p_at_id IS NOT NULL
        THEN
            DELETE FROM tmp_work_ids
                  WHERE 1 = 1;

            INSERT INTO tmp_work_ids (x_id)
                SELECT at_id
                  FROM act
                 WHERE at_id = p_at_id;

            l_cnt := SQL%ROWCOUNT;
        ELSE
            SELECT COUNT (*)
              INTO l_cnt
              FROM tmp_work_ids, act
             WHERE x_id = at_id;
        END IF;

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'В функцію перевірки наявності права на виплату не передано ідентифікаторів проектів рішень на виплату!');
        END IF;

        l_hs := TOOLS.GetHistSession;
        api$anketa.Set_Anketa_at ();

        --Видаляємо ті правила перевірки права, яких немає в налаштуваннях для типу допомоги
        DELETE FROM at_right_log
              WHERE EXISTS
                        (SELECT 1
                           FROM tmp_work_ids
                          WHERE arl_at = x_id);

        g_def_arl_result := NULL;

        --COMMIT;

        --Вставляємо всі правила по типу допомоги або якщо для типу послуги немає налаштуваннь, то ті правила, які не прив`язані до налаштувань
        FOR rec
            IN (  SELECT DISTINCT nrr_id,
                                  nrr_name,
                                  nrr_alg,
                                  nrr_order,
                                  at_ap       AS x_ap,
                                  at_id       AS x_at,
                                  ats_id      AS x_ats,
                                  ats_nst     AS x_nst
                    FROM tmp_work_ids
                         JOIN act ON x_id = at_id
                         JOIN at_service ats
                             ON x_id = ats_at AND ats.history_status = 'A'
                         JOIN appeal ON ap_id = at_ap
                         JOIN uss_ndi.v_ndi_right_rule ON nrr_ap_tp = ap_tp
                         JOIN uss_ndi.v_ndi_nrr_config nruc
                             ON     nruc_nrr = nrr_id
                                AND nruc_nst = ats_nst
                                AND nruc.history_status = 'A'
                   WHERE TRUNC (ap_reg_dt) BETWEEN nruc_start_dt
                                               AND nruc_stop_dt
                ORDER BY nrr_order)
        LOOP
            DELETE FROM tmp_errors_list
                  WHERE 1 = 1;

            CASE rec.nrr_alg
                WHEN 'R.OS.ALG1'
                THEN
                    Check_ALG1 (rec.nrr_id,
                                rec.x_ap,
                                rec.x_at,
                                rec.x_ats);
                WHEN 'R.GS.ALG1'
                THEN
                    Check_ALG1 (rec.nrr_id,
                                rec.x_ap,
                                rec.x_at,
                                rec.x_ats);
                WHEN 'SS.ALG01'
                THEN
                    Check_SS_ALG01 (rec.nrr_id,
                                    rec.x_ap,
                                    rec.x_at,
                                    rec.x_ats);
                WHEN 'SS.ALG02'
                THEN
                    Check_SS_ALG02 (rec.nrr_id,
                                    rec.x_ap,
                                    rec.x_at,
                                    rec.x_ats,
                                    rec.x_nst);
                WHEN 'SS.ALG03'
                THEN
                    Check_SS_ALG03 (rec.nrr_id,
                                    rec.x_ap,
                                    rec.x_at,
                                    rec.x_ats);
                WHEN 'SS.ALG04'
                THEN
                    Check_SS_ALG04 (rec.nrr_id,
                                    rec.x_ap,
                                    rec.x_at,
                                    rec.x_ats);
                WHEN 'SS.ALG05'
                THEN
                    Check_SS_ALG05 (rec.nrr_id,
                                    rec.x_ap,
                                    rec.x_at,
                                    rec.x_ats);
                WHEN 'SS.ALG06'
                THEN
                    Check_SS_ALG06 (rec.nrr_id,
                                    rec.x_ap,
                                    rec.x_at,
                                    rec.x_ats);
                WHEN 'SS.ALG07'
                THEN
                    Check_SS_ALG07 (rec.nrr_id,
                                    rec.x_ap,
                                    rec.x_at,
                                    rec.x_ats);
                WHEN 'SS.ALG08'
                THEN
                    Check_SS_ALG08 (rec.nrr_id,
                                    rec.x_ap,
                                    rec.x_at,
                                    rec.x_ats);
                WHEN 'SS.ALG09'
                THEN
                    Check_SS_ALG09 (rec.nrr_id,
                                    rec.x_ap,
                                    rec.x_at,
                                    rec.x_ats);
                WHEN 'SS.ALG10'
                THEN
                    Check_SS_ALG10 (rec.nrr_id,
                                    rec.x_ap,
                                    rec.x_at,
                                    rec.x_ats);
                WHEN 'SS.ALG11'
                THEN
                    Check_SS_ALG11 (rec.nrr_id,
                                    rec.x_ap,
                                    rec.x_at,
                                    rec.x_ats);
                WHEN 'SS.ALG12'
                THEN
                    Check_SS_ALG12 (rec.nrr_id,
                                    rec.x_ap,
                                    rec.x_at,
                                    rec.x_ats);
                WHEN 'SS.ALG13'
                THEN
                    Check_SS_ALG13 (rec.nrr_id,
                                    rec.x_ap,
                                    rec.x_at,
                                    rec.x_ats);
                WHEN 'SS.ALG14'
                THEN
                    Check_SS_ALG14 (rec.nrr_id,
                                    rec.x_ap,
                                    rec.x_at,
                                    rec.x_ats);
                WHEN 'SS.ALG15'
                THEN
                    Check_SS_ALG15 (rec.nrr_id,
                                    rec.x_ap,
                                    rec.x_at,
                                    rec.x_ats);
                WHEN 'SS.ALG16'
                THEN
                    Check_SS_ALG16 (rec.nrr_id,
                                    rec.x_ap,
                                    rec.x_at,
                                    rec.x_ats);
                ELSE
                    Check_Other (rec.nrr_id, rec.x_at);
            END CASE;

            l_cnt := SQL%ROWCOUNT;
        END LOOP;

        FOR m
            IN (  SELECT    'За правилом "'
                         || nrr.nrr_name
                         || '" не має права в зв''язку із тим, що: '
                         || SUBSTR (arl.arl_calc_info, 1, 3750)    AS text,
                         NVL (nrr.nrr_tp, 'E')                     AS nrr_tp
                    FROM at_right_log arl
                         JOIN tmp_work_ids ON arl_at = x_id
                         LEFT JOIN uss_ndi.v_ndi_right_rule nrr
                             ON nrr.nrr_id = arl_nrr
                   WHERE arl.arl_calc_info IS NOT NULL
                ORDER BY nrr.nrr_order)
        LOOP
            TOOLS.add_message (l_messages, m.nrr_tp, m.text);
        END LOOP;

        FOR xx IN (SELECT x_id, at_st
                     FROM tmp_work_ids JOIN act ON x_id = at_id)
        LOOP
            api$act.Recalc_Pdsp_Ats_St (xx.x_id);

            write_at_log (xx.x_id,
                          l_hs,
                          xx.at_st,
                          CHR (38) || '12',
                          NULL);
        END LOOP;

        OPEN p_Messages FOR SELECT * FROM TABLE (l_Messages);
    END;

    --+++++++++++++++++++++
    PROCEDURE dbms_output_decision_info (p_id NUMBER)
    IS
        CURSOR act IS
            SELECT t.*
              FROM act t
             WHERE at_id = p_id;

        CURSOR Z (p_at_id NUMBER)
        IS
            SELECT app.app_id,
                   app.app_ap,
                   app.app_sc,
                   app.app_tp,
                   app.app_vf,
                   act.at_id,
                   act.at_ap,
                   ap.ap_reg_dt     AS calc_dt
              FROM act  act
                   JOIN ap_person app
                       ON app_ap = at_ap AND app.history_status = 'A'
                   JOIN appeal ap ON ap_id = at_ap
             WHERE at_id = p_at_id AND app_tp IN ('Z', 'O');

        CURSOR FP (p_at_id NUMBER)
        IS
            SELECT app.app_id,
                   app.app_ap,
                   app.app_sc,
                   app.app_tp,
                   app.app_vf,
                   act.at_id,
                   act.at_ap,
                   ap.ap_reg_dt     AS calc_dt
              FROM act  act
                   JOIN ap_person app
                       ON app_ap = at_ap AND app.history_status = 'A'
                   JOIN appeal ap ON ap_id = at_ap
             WHERE at_id = p_at_id AND app_tp IN ('FP');

        CURSOR FM (p_at_id NUMBER)
        IS
            SELECT app.app_id,
                   app.app_ap,
                   app.app_sc,
                   app.app_tp,
                   app.app_vf,
                   act.at_id,
                   act.at_ap,
                   ap.ap_reg_dt     AS calc_dt
              FROM act  act
                   JOIN ap_person app
                       ON app_ap = at_ap AND app.history_status = 'A'
                   JOIN appeal ap ON ap_id = at_ap
             WHERE at_id = p_at_id AND app_tp IN ('FM');

        CURSOR doc (p_app_id NUMBER)
        IS
            SELECT apd.apd_id,
                   apd.apd_app,
                   apd.apd_ndt,
                   ndt.ndt_name_short,
                      /*'apd_app='||rpad( apd.apd_app, 4,' ')||*/
                      ' apd_ndt='
                   || RPAD (apd.apd_ndt, 6, ' ')
                   || ' '
                   || ndt.ndt_name_short    doc
              FROM ap_document  apd
                   INNER JOIN uss_ndi.v_ndi_document_type ndt
                       ON ndt.ndt_id = apd.apd_ndt
             WHERE p_app_id = apd.apd_app AND apd.history_status = 'A';

        CURSOR atr (p_apd_id NUMBER)
        IS
            WITH
                atr
                AS
                    (  SELECT apda.apda_apd,
                              apda.apda_id,
                              CASE pt_data_type
                                  WHEN 'STRING'
                                  THEN
                                      apda_val_string
                                  WHEN 'INTEGER'
                                  THEN
                                      TO_CHAR (apda_val_int)
                                  WHEN 'SUM'
                                  THEN
                                      TO_CHAR (apda_val_sum)
                                  WHEN 'ID'
                                  THEN
                                      TO_CHAR (apda_val_id)
                                  WHEN 'DATE'
                                  THEN
                                      TO_CHAR (apda_val_dt, 'dd.mm.yyyy')
                                  ELSE
                                      '???'
                              END                                  AS apda_val,
                              nda.nda_id,
                              NVL (nda.nda_name, npt.pt_name)      nda_name,
                              nda.nda_nng,
                              (SELECT nng.nng_name
                                 FROM uss_ndi.v_ndi_nda_group nng
                                WHERE nng.nng_id = nda.nda_nng)    nng_name,
                              npt.pt_data_type
                         FROM ap_document_attr apda
                              INNER JOIN uss_ndi.v_ndi_document_attr nda
                                  ON nda.nda_id = apda.apda_nda
                              INNER JOIN uss_ndi.v_ndi_param_type npt
                                  ON npt.pt_id = nda.nda_pt
                        WHERE apda.history_status = 'A'
                     ORDER BY 1, 2)
              SELECT apda_apd,
                     LISTAGG (
                            LPAD (' ', 12, ' ')
                         || nda_nng
                         || '   '
                         || nda_id
                         || '  '
                         || nda_name
                         || ' = '
                         || apda_val,
                         CHR (13) || CHR (10))
                     WITHIN GROUP (ORDER BY apda_apd)    apda_list
                FROM atr
               WHERE apda_val IS NOT NULL AND atr.apda_apd = p_apd_id
            GROUP BY apda_apd;
    BEGIN
        FOR d IN act
        LOOP
            --    dbms_output.put_line('pd_nst='||d.pd_nst);
            FOR p IN Z (d.at_id)
            LOOP
                DBMS_OUTPUT.put_line (
                       '    '
                    || p.app_tp
                    || '  '
                    || p.app_tp
                    || '  '
                    || p.app_tp
                    || '  '
                    || p.app_tp);
                DBMS_OUTPUT.put_line (
                       '    app_id='
                    || RPAD (p.app_id, 4, ' ')
                    || '  '
                    || uss_person.api$sc_tools.get_pib (p.app_sc));

                FOR docum IN doc (p.app_id)
                LOOP
                    DBMS_OUTPUT.put_line ('        ' || docum.doc);

                    FOR a IN atr (docum.apd_id)
                    LOOP
                        DBMS_OUTPUT.put_line (a.apda_list);
                    END LOOP;
                END LOOP;
            END LOOP;

            DBMS_OUTPUT.put_line ('    ');

            FOR p IN FP (d.at_id)
            LOOP
                DBMS_OUTPUT.put_line ('    FP FP FP');
                DBMS_OUTPUT.put_line (
                       '    app_id='
                    || RPAD (p.app_id, 4, ' ')
                    || '  '
                    || uss_person.api$sc_tools.get_pib (p.app_sc));

                FOR docum IN doc (p.app_id)
                LOOP
                    DBMS_OUTPUT.put_line ('        ' || docum.doc);

                    FOR a IN atr (docum.apd_id)
                    LOOP
                        DBMS_OUTPUT.put_line (a.apda_list);
                    END LOOP;
                END LOOP;
            END LOOP;

            DBMS_OUTPUT.put_line ('    ');

            FOR p IN FM (d.at_id)
            LOOP
                DBMS_OUTPUT.put_line ('    FM FM FM');
                DBMS_OUTPUT.put_line (
                       '    app_id='
                    || RPAD (p.app_id, 4, ' ')
                    || '  '
                    || uss_person.api$sc_tools.get_pib (p.app_sc));

                FOR docum IN doc (p.app_id)
                LOOP
                    DBMS_OUTPUT.put_line ('        ' || docum.doc);

                    FOR a IN atr (docum.apd_id)
                    LOOP
                        DBMS_OUTPUT.put_line (a.apda_list);
                    END LOOP;
                END LOOP;
            END LOOP;
        END LOOP;
    END;

    --+++++++++++++++++++++
    PROCEDURE dbms_output_appeal_info (p_id NUMBER)
    IS
        CURSOR ap IS
            SELECT *
              FROM appeal
             WHERE ap_id = p_id;

        CURSOR S (p_ap_id NUMBER)
        IS
            SELECT *
              FROM ap_service
             WHERE aps_ap = p_ap_id AND history_status = 'A';

        CURSOR Z (p_ap_id NUMBER)
        IS
            SELECT *
              FROM ap_person
             WHERE     app_ap = p_ap_id
                   AND app_tp IN ('Z', 'O')
                   AND history_status = 'A';

        CURSOR FP (p_ap_id NUMBER)
        IS
            SELECT *
              FROM ap_person
             WHERE     app_ap = p_ap_id
                   AND app_tp IN ('FP', 'DU')
                   AND history_status = 'A';

        CURSOR FM (p_ap_id NUMBER)
        IS
            SELECT *
              FROM ap_person
             WHERE     app_ap = p_ap_id
                   AND app_tp = 'FM'
                   AND history_status = 'A';

        CURSOR doc (p_app_id NUMBER)
        IS
            SELECT apd.apd_id,
                   apd.apd_app,
                   apd.apd_ndt,
                   ndt.ndt_name_short,
                      /*'apd_app='||rpad( apd.apd_app, 4,' ')||*/
                      ' apd_ndt='
                   || RPAD (apd.apd_ndt, 6, ' ')
                   || ' '
                   || ndt.ndt_name_short    doc
              FROM ap_document  apd
                   INNER JOIN uss_ndi.v_ndi_document_type ndt
                       ON ndt.ndt_id = apd.apd_ndt
             WHERE p_app_id = apd.apd_app AND apd.history_status = 'A';

        CURSOR atr (p_apd_id NUMBER)
        IS
            WITH
                atr
                AS
                    (  SELECT apda.apda_apd,
                              apda.apda_id,
                              CASE pt_data_type
                                  WHEN 'STRING'
                                  THEN
                                      apda_val_string
                                  WHEN 'INTEGER'
                                  THEN
                                      TO_CHAR (apda_val_int)
                                  WHEN 'SUM'
                                  THEN
                                      TO_CHAR (apda_val_sum)
                                  WHEN 'ID'
                                  THEN
                                      TO_CHAR (apda_val_id)
                                  WHEN 'DATE'
                                  THEN
                                      TO_CHAR (apda_val_dt, 'dd.mm.yyyy')
                                  ELSE
                                      '???'
                              END                                AS apda_val,
                              nda.nda_id,
                              NVL (nda.nda_name, npt.pt_name)    nda_name,
                              --nda.nda_nng, (select nng.nng_name from uss_ndi.v_ndi_nda_group nng where nng.nng_id=nda.nda_nng) nng_name,
                              npt.pt_data_type
                         FROM ap_document_attr apda
                              INNER JOIN uss_ndi.v_ndi_document_attr nda
                                  ON nda.nda_id = apda.apda_nda
                              INNER JOIN uss_ndi.v_ndi_param_type npt
                                  ON npt.pt_id = nda.nda_pt
                        WHERE apda.history_status = 'A'
                     ORDER BY 1, 2)
              SELECT apda_apd,
                     LISTAGG (
                            LPAD (' ', 12, ' ')
                         || nda_id
                         || '  '
                         || nda_name
                         || ' = '
                         || apda_val,
                         CHR (13) || CHR (10))
                     WITHIN GROUP (ORDER BY apda_apd)    apda_list
                FROM atr
               WHERE apda_val IS NOT NULL AND atr.apda_apd = p_apd_id
            GROUP BY apda_apd;
    BEGIN
        FOR d IN ap
        LOOP
            FOR p IN S (d.ap_id)
            LOOP
                DBMS_OUTPUT.put_line ('    nst=' || p.aps_nst);
            END LOOP;

            DBMS_OUTPUT.put_line ('    ');

            FOR p IN Z (d.ap_id)
            LOOP
                DBMS_OUTPUT.put_line (
                       '    '
                    || p.app_tp
                    || '  '
                    || p.app_tp
                    || '  '
                    || p.app_tp
                    || '  '
                    || p.app_tp);
                DBMS_OUTPUT.put_line (
                       '    app_id='
                    || RPAD (p.app_id, 4, ' ')
                    || '  '
                    || uss_person.api$sc_tools.get_pib (p.app_sc));

                FOR docum IN doc (p.app_id)
                LOOP
                    DBMS_OUTPUT.put_line ('        ' || docum.doc);

                    FOR a IN atr (docum.apd_id)
                    LOOP
                        DBMS_OUTPUT.put_line (a.apda_list);
                    END LOOP;
                END LOOP;
            END LOOP;

            DBMS_OUTPUT.put_line ('    ');

            FOR p IN FP (d.ap_id)
            LOOP
                DBMS_OUTPUT.put_line ('    FP FP FP');
                DBMS_OUTPUT.put_line (
                       '    app_id='
                    || RPAD (p.app_id, 4, ' ')
                    || '  '
                    || uss_person.api$sc_tools.get_pib (p.app_sc));

                FOR docum IN doc (p.app_id)
                LOOP
                    DBMS_OUTPUT.put_line ('        ' || docum.doc);

                    FOR a IN atr (docum.apd_id)
                    LOOP
                        DBMS_OUTPUT.put_line (a.apda_list);
                    END LOOP;
                END LOOP;
            END LOOP;

            DBMS_OUTPUT.put_line ('    ');

            FOR p IN FM (d.ap_id)
            LOOP
                DBMS_OUTPUT.put_line ('    FM FM FM');
                DBMS_OUTPUT.put_line (
                       '    app_id='
                    || RPAD (p.app_id, 4, ' ')
                    || '  '
                    || uss_person.api$sc_tools.get_pib (p.app_sc));

                FOR docum IN doc (p.app_id)
                LOOP
                    DBMS_OUTPUT.put_line ('        ' || docum.doc);

                    FOR a IN atr (docum.apd_id)
                    LOOP
                        DBMS_OUTPUT.put_line (a.apda_list);
                    END LOOP;
                END LOOP;
            END LOOP;
        END LOOP;
    END;

    --+++++++++++++++++++++
    PROCEDURE Test_right (id NUMBER)
    IS
        p_messages   SYS_REFCURSOR;

        PROCEDURE fetch2andclose (rc IN SYS_REFCURSOR)
        IS
            msg_tp        VARCHAR2 (10);
            msg_tp_name   VARCHAR2 (20);
            msg_text      VARCHAR2 (4000);
        BEGIN
            LOOP
                FETCH rc INTO msg_tp, msg_tp_name, msg_text;

                EXIT WHEN rc%NOTFOUND;
                DBMS_OUTPUT.PUT_LINE (
                    msg_tp || '   ' || msg_tp_name || '   ' || msg_text);
            END LOOP;

            CLOSE rc;
        END;
    BEGIN
        Is_dbms_output := TRUE;
        init_right_for_act (1, id, p_messages);
        fetch2andclose (p_messages);
        dbms_output_decision_info (id);
    --commit;
    END;
--+++++++++++++++++++++
END API$CALC_RIGHT_AT;
/