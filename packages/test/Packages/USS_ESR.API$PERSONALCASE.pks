/* Formatted on 8/12/2025 5:48:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$PERSONALCASE
IS
    -- Author  : VANO
    -- Created : 15.07.2021 17:11:51
    -- Purpose : Функції роботи з єдиними особовими справами

    --Отримання текстового параметру документу по учаснику
    FUNCTION get_ap_doc_string (p_ap        ap_document.apd_ap%TYPE,
                                p_ndt       ap_document.apd_ndt%TYPE,
                                p_nda       ap_document_attr.apda_nda%TYPE,
                                p_default   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;

    --Отримання наявності документу
    FUNCTION get_ap_doc_cnt (p_ap    ap_document.apd_ap%TYPE,
                             p_ndt   ap_document.apd_ndt%TYPE)
        RETURN NUMBER;

    FUNCTION get_ap_doc_list_cnt (p_ap         ap_document.apd_app%TYPE,
                                  p_list_ndt   VARCHAR2)
        RETURN NUMBER;

    -- отримати app_sc та app_scc за зверненням
    PROCEDURE Get_sc_scc_by_appeal (p_ap_id          NUMBER,
                                    p_ap_tp          VARCHAR2,
                                    p_ap_src         VARCHAR2,
                                    p_app_sc     OUT NUMBER,
                                    p_app_scс   OUT NUMBER);

    -- отримати app_sc за зверненням
    FUNCTION Get_sc_by_appeal (p_ap_id NUMBER)
        RETURN NUMBER;

    FUNCTION Get_sc_by_appeal (p_ap_id NUMBER, p_ap_tp VARCHAR2)
        RETURN NUMBER;

    -- отримати app_scc за зверненням
    FUNCTION Get_scc_by_appeal (p_ap_id NUMBER)
        RETURN NUMBER;

    FUNCTION Get_scc_by_appeal (p_ap_id NUMBER, p_ap_tp VARCHAR2)
        RETURN NUMBER;

    FUNCTION Get_sc_by_appeal (p_ap_id    NUMBER,
                               p_ap_tp    VARCHAR2,
                               p_ap_src   VARCHAR2)
        RETURN NUMBER;

    --Створення ЕОС на основі заявників зверненнь
    PROCEDURE init_pc_by_appeal;


    --Додавання в чергу на перерахунок запису
    PROCEDURE add_pc_accrual_queue (
        p_paq_pc         pc_accrual_queue.paq_pc%TYPE,
        p_paq_tp         pc_accrual_queue.paq_tp%TYPE,
        p_paq_start_dt   pc_accrual_queue.paq_start_dt%TYPE,
        p_paq_stop_dt    pc_accrual_queue.paq_stop_dt%TYPE,
        p_paq_doc        pc_accrual_queue.paq_pd%TYPE,
        p_hs             pc_accrual_queue.paq_hs_ins%TYPE:= NULL);

    -- скасування звернення з превіркою на стан для Є-допомоги
    PROCEDURE calcel_pd_by_appeal (p_ap appeal.ap_id%TYPE, p_ret OUT BOOLEAN);

    FUNCTION Get_pc_by_sc (p_sc IN NUMBER)
        RETURN NUMBER;

    PROCEDURE move_pc_to_other_org (p_pc_id     personalcase.pc_id%TYPE,
                                    p_new_org   personalcase.com_org%TYPE,
                                    p_reason    VARCHAR2);
END API$PERSONALCASE;
/


GRANT EXECUTE ON USS_ESR.API$PERSONALCASE TO II01RC_USS_ESR_AP_COPY
/

GRANT EXECUTE ON USS_ESR.API$PERSONALCASE TO USS_VISIT
/


/* Formatted on 8/12/2025 5:49:16 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$PERSONALCASE
IS
    --Отримання текстового параметру документу по учаснику
    FUNCTION get_ap_doc_string (p_ap        ap_document.apd_ap%TYPE,
                                p_ndt       ap_document.apd_ndt%TYPE,
                                p_nda       ap_document_attr.apda_nda%TYPE,
                                p_default   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_rez   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (apda_val_string)
          INTO l_rez
          FROM ap_document, ap_document_attr
         WHERE     apda_apd = apd_id
               AND ap_document.history_status = 'A'
               AND apd_ap = p_ap
               AND apd_ndt = p_ndt
               AND apda_nda = p_nda;

        IF p_default IS NOT NULL
        THEN
            RETURN NVL (l_rez, p_default);
        END IF;

        RETURN l_rez;
    END;

    --Отримання наявності документу
    FUNCTION get_ap_doc_cnt (p_ap    ap_document.apd_ap%TYPE,
                             p_ndt   ap_document.apd_ndt%TYPE)
        RETURN NUMBER
    IS
        l_rez   NUMBER (10);
    BEGIN
        SELECT COUNT (1)
          INTO l_rez
          FROM ap_document
         WHERE     ap_document.history_status = 'A'
               AND apd_ap = p_ap
               AND apd_ndt = p_ndt;

        RETURN l_rez;
    END;

    FUNCTION get_ap_doc_list_cnt (p_ap         ap_document.apd_app%TYPE,
                                  p_list_ndt   VARCHAR2)
        RETURN NUMBER
    IS
        l_rez   NUMBER (10);
    BEGIN
        WITH
            ndt_list
            AS
                (    SELECT REGEXP_SUBSTR (p_list_ndt,
                                           '[^,]+',
                                           1,
                                           LEVEL)    AS i_ndt
                       FROM DUAL
                 CONNECT BY LEVEL <=
                            LENGTH (REGEXP_REPLACE (p_list_ndt, '[^,]*')) + 1)
        SELECT COUNT (1)
          INTO l_rez
          FROM ap_document JOIN ndt_list ON apd_ndt = i_ndt
         WHERE ap_document.history_status = 'A' AND apd_ap = p_ap;

        RETURN l_rez;
    END;

    --============================================
    -- отримати app_sc за зверненням
    --============================================
    PROCEDURE Get_sc_scc_by_appeal (p_ap_id          NUMBER,
                                    p_ap_tp          VARCHAR2,
                                    p_ap_src         VARCHAR2,
                                    p_app_sc     OUT NUMBER,
                                    p_app_scс   OUT NUMBER)
    IS
        l_ap_tp    VARCHAR2 (10);
        l_is_801   NUMBER (10);
        l_is_802   NUMBER (10);
        l_is_803   NUMBER (10);
        l_is_836   NUMBER (10);
        l_ap_src   VARCHAR2 (10);
    --l_cnt_OS NUMBER(10);
    BEGIN
        IF p_ap_tp IS NULL
        THEN
            SELECT ap_tp
              INTO l_ap_tp
              FROM appeal
             WHERE ap_id = p_ap_id;
        ELSE
            l_ap_tp := p_ap_tp;
        END IF;

        IF p_ap_src IS NULL
        THEN
            SELECT ap_src
              INTO l_ap_src
              FROM appeal
             WHERE ap_id = p_ap_id;
        ELSE
            l_ap_src := p_ap_src;
        END IF;


        --API$PERSONALCASE.get_ap_doc_cnt(p_ap_id, '801')

        IF l_ap_tp IS NULL OR l_ap_tp NOT IN ('SS', 'R.OS', 'R.GS')
        THEN
            SELECT MAX (app_sc), MAX (app_scc)
              INTO p_app_sc, p_app_scс
              FROM ap_person app
             WHERE     app_ap = p_ap_id
                   --AND app_tp IN ( 'Z' , 'O')
                   AND (   app_tp IN ('Z', 'O')
                        OR (    app_tp IN ('ANF')
                            AND NOT EXISTS
                                    (SELECT 1
                                       FROM ap_person t
                                      WHERE     t.app_ap = p_ap_id
                                            AND t.app_tp = 'Z'
                                            AND t.history_status = 'A')))
                   AND app_sc IS NOT NULL
                   AND app.history_status = 'A';

            RETURN;
        ELSIF l_ap_tp IN ('R.OS', 'R.GS')
        THEN
            dbms_output_put_lines (   '3061='
                                   || API$PERSONALCASE.get_ap_doc_string (
                                          p_ap_id,
                                          '800',
                                          3061,
                                          '-'));

            IF API$PERSONALCASE.get_ap_doc_string (p_ap_id,
                                                   '800',
                                                   3061,
                                                   '-') IN ('Z', 'FM')
            THEN
                SELECT MAX (app_sc), MAX (app_scc)
                  INTO p_app_sc, p_app_scс
                  FROM ap_person app
                 WHERE     app_ap = p_ap_id
                       AND app_tp = 'Z'
                       AND app_sc IS NOT NULL
                       AND app.history_status = 'A';
            ELSE
                SELECT MAX (app_sc), MAX (app_scc)
                  INTO p_app_sc, p_app_scс
                  FROM ap_person app
                 WHERE     app_ap = p_ap_id
                       AND app_tp = 'OS'
                       AND app_sc IS NOT NULL
                       AND app.history_status = 'A';
            END IF;

            RETURN;
        END IF;

        l_is_801 := API$PERSONALCASE.get_ap_doc_cnt (p_ap_id, '801');
        l_is_802 := API$PERSONALCASE.get_ap_doc_cnt (p_ap_id, '802');
        l_is_803 := API$PERSONALCASE.get_ap_doc_cnt (p_ap_id, '803');
        l_is_836 := API$PERSONALCASE.get_ap_doc_cnt (p_ap_id, '836');

        dbms_output_put_lines (   '    l_is_801 = '
                               || l_is_801
                               || '    l_is_802 = '
                               || l_is_802
                               || '    l_is_803 = '
                               || l_is_803
                               || '    l_is_836 = '
                               || l_is_836
                               || '    801/1895 = '
                               || API$PERSONALCASE.get_ap_doc_string (
                                      p_ap_id,
                                      801,
                                      1895,
                                      '-')
                               || '    836/3443 = '
                               || API$PERSONALCASE.get_ap_doc_string (
                                      p_ap_id,
                                      836,
                                      3443,
                                      '-'));

        -- #102222
        IF     l_is_801 > 0
           AND API$APPEAL.Get_Attr_801_ChkQty (p_ap_id,
                                               l_ap_src,
                                               'Z',
                                               'Z') > 0
        THEN
            SELECT MAX (app_sc), MAX (app_scc)
              INTO p_app_sc, p_app_scс
              FROM ap_person app
             WHERE     app_ap = p_ap_id
                   AND app_tp = 'Z'
                   AND app_sc IS NOT NULL
                   AND app.history_status = 'A';
        ELSIF     l_is_801 > 0
              AND API$APPEAL.Get_Attr_801_ChkQty (p_ap_id,
                                                  l_ap_src,
                                                  'Z',
                                                  'B') > 0
        THEN
            SELECT MAX (app_sc), MAX (app_scc)
              INTO p_app_sc, p_app_scс
              FROM ap_person app
             WHERE     app_ap = p_ap_id
                   AND app_tp = 'OS'
                   AND app_sc IS NOT NULL
                   AND app.history_status = 'A';
        ELSIF     l_is_801 > 0
              AND API$APPEAL.Get_Attr_801_ChkQty (p_ap_id,
                                                  l_ap_src,
                                                  'Z',
                                                  'CHRG') > 0
        THEN
            SELECT MAX (app_sc), MAX (app_scc)
              INTO p_app_sc, p_app_scс
              FROM ap_person app
             WHERE     app_ap = p_ap_id
                   AND app_tp = 'OS'
                   AND app_sc IS NOT NULL
                   AND app.history_status = 'A';
        ELSIF     l_is_801 > 0
              AND API$APPEAL.Get_Attr_801_ChkQty (p_ap_id,
                                                  l_ap_src,
                                                  'FM',
                                                  'FM') > 0
        THEN
            SELECT MAX (app_sc), MAX (app_scc)
              INTO p_app_sc, p_app_scс
              FROM ap_person app
             WHERE     app_ap = p_ap_id
                   AND app_tp = 'Z'
                   AND app_sc IS NOT NULL
                   AND app.history_status = 'A';

            IF p_app_sc IS NULL
            THEN
                SELECT MAX (app_sc), MAX (app_scc)
                  INTO p_app_sc, p_app_scс
                  FROM ap_person app
                 WHERE     app_ap = p_ap_id
                       AND app_tp = 'AF'                             --#105585
                       AND app_sc IS NOT NULL
                       AND app.history_status = 'A';
            END IF;
        ELSIF     l_is_801 > 0
              AND API$PERSONALCASE.get_ap_doc_string (p_ap_id,
                                                      801,
                                                      1868,
                                                      '-') IN ('FM')
        THEN
            SELECT MAX (app_sc), MAX (app_scc)
              INTO p_app_sc, p_app_scс
              FROM ap_person app
             WHERE     app_ap = p_ap_id
                   AND app_tp = 'Z'
                   AND app_sc IS NOT NULL
                   AND app.history_status = 'A';

            IF p_app_sc IS NULL
            THEN
                SELECT MAX (app_sc), MAX (app_scc)
                  INTO p_app_sc, p_app_scс
                  FROM ap_person app
                 WHERE     app_ap = p_ap_id
                       AND app_tp = 'FMS'
                       AND app_sc IS NOT NULL
                       AND app.history_status = 'A';
            END IF;
        ELSIF     l_is_801 > 0
              AND API$PERSONALCASE.get_ap_doc_string (p_ap_id,
                                                      801,
                                                      1895,
                                                      '-') NOT IN ('Z', 'FM')
        THEN
            SELECT MAX (app_sc), MAX (app_scc)
              INTO p_app_sc, p_app_scс
              FROM ap_person app
             WHERE     app_ap = p_ap_id
                   AND app_tp = 'OS'
                   AND app_sc IS NOT NULL
                   AND app.history_status = 'A';

            IF p_app_sc IS NULL
            THEN
                SELECT MAX (app_sc), MAX (app_scc)
                  INTO p_app_sc, p_app_scс
                  FROM ap_person app
                 WHERE     app_ap = p_ap_id
                       AND app_tp = 'Z'
                       AND app_sc IS NOT NULL
                       AND app.history_status = 'A';
            END IF;
        -- #105581 BEGIN
        ELSIF     l_is_802 > 0
              AND API$APPEAL.Get_Ap_Attr_Str (p_ap_id, 1944, '-') IN ('Z')
              AND API$APPEAL.Get_Ap_Attr_Str (p_ap_id, 1946, '-') IN ('SA')
        THEN
            SELECT MAX (app_sc), MAX (app_scc)
              INTO p_app_sc, p_app_scс
              FROM ap_person app
             WHERE     app_ap = p_ap_id
                   AND app_tp = 'Z'
                   AND app_sc IS NOT NULL
                   AND app.history_status = 'A';
        ELSIF     l_is_802 > 0
              AND API$APPEAL.Get_Ap_Attr_Str (p_ap_id, 1944, '-') IN ('Z')
              AND API$APPEAL.Get_Ap_Attr_Str (p_ap_id, 1946, '-') NOT IN
                      ('SA')
        THEN
            SELECT MAX (app_sc), MAX (app_scc)
              INTO p_app_sc, p_app_scс
              FROM ap_person app
             WHERE     app_ap = p_ap_id
                   AND app_tp = 'OS'
                   AND app_sc IS NOT NULL
                   AND app.history_status = 'A';
        ELSIF     l_is_802 > 0
              AND API$APPEAL.Get_Ap_Attr_Str (p_ap_id, 1944, '-') IN ('FM')
              AND API$APPEAL.Get_Ap_Attr_Str (p_ap_id, 1946, '-') IN ('SA')
        THEN
            SELECT MAX (app_sc), MAX (app_scc)
              INTO p_app_sc, p_app_scс
              FROM ap_person app
             WHERE     app_ap = p_ap_id
                   AND app_tp = 'Z'
                   AND app_sc IS NOT NULL
                   AND app.history_status = 'A';

            IF p_app_sc IS NULL
            THEN
                SELECT MAX (app_sc), MAX (app_scc)
                  INTO p_app_sc, p_app_scс
                  FROM ap_person app
                 WHERE     app_ap = p_ap_id
                       AND app_tp = 'AF'
                       AND app_sc IS NOT NULL
                       AND app.history_status = 'A';
            END IF;
        ELSIF     l_is_802 > 0
              AND API$APPEAL.Get_Ap_Attr_Str (p_ap_id, 1944, '-') IN ('Z')
              AND API$APPEAL.Get_Ap_Attr_Str (p_ap_id, 1946, '-') NOT IN
                      ('SA')
        THEN
            SELECT MAX (app_sc), MAX (app_scc)
              INTO p_app_sc, p_app_scс
              FROM (  SELECT app_sc,
                             app_scc,
                             app_id,
                             ord
                        FROM (SELECT app_sc,
                                     app_scc,
                                     app_id,
                                     CASE
                                         WHEN   MONTHS_BETWEEN (
                                                    SYSDATE,
                                                    Api$appeal.Get_App_Doc_dt (
                                                        p_Ap_Id       => app.App_ap,
                                                        p_App_Id      => app.App_Id,
                                                        p_Nda_CLASS   => 'BDT'))
                                              / 12 >=
                                              18
                                         THEN
                                             0
                                         ELSE
                                             1
                                     END    ord
                                FROM ap_person app
                               WHERE     app_ap = p_ap_id
                                     AND app_tp = 'FM'
                                     AND app_sc IS NOT NULL
                                     AND app.history_status = 'A')
                    ORDER BY ORD, APP_ID)
             WHERE ROWNUM = 1;
        -- #105581 END
        ELSIF     l_is_836 > 0
              AND API$PERSONALCASE.get_ap_doc_string (p_ap_id,
                                                      836,
                                                      3443,
                                                      '-') NOT IN ('Z', 'FM')
        THEN
            SELECT MAX (app_sc), MAX (app_scc)
              INTO p_app_sc, p_app_scс
              FROM ap_person app
             WHERE     app_ap = p_ap_id
                   AND app_tp = 'OS'
                   AND app_sc IS NOT NULL
                   AND app.history_status = 'A';
        ELSIF l_is_802 > 0 OR l_is_803 > 0
        THEN
            SELECT MAX (app_sc), MAX (app_scc)
              INTO p_app_sc, p_app_scс
              FROM ap_person app
             WHERE     app_ap = p_ap_id
                   AND app_tp = 'Z'
                   AND app_sc IS NOT NULL
                   AND app.history_status = 'A';
        ELSE
            SELECT MAX (app_sc), MAX (app_scc)
              INTO p_app_sc, p_app_scс
              FROM ap_person app
             WHERE     app_ap = p_ap_id
                   AND app_tp = 'Z'
                   AND app_sc IS NOT NULL
                   AND app.history_status = 'A';
        END IF;
    /*    CASE
        WHEN l_is_803 > 0 THEN
            SELECT MAX(app_sc), MAX(app_scc) INTO p_app_sc, p_app_scс
            FROM ap_person app
            WHERE app_ap = p_ap_id
                  AND app_tp = 'Z'
                  AND app_sc IS NOT NULL
                  AND app.history_status = 'A';
        WHEN l_is_801 > 0 AND API$PERSONALCASE.get_ap_doc_string(p_ap_id, 801, 1895, '-') IN ('Z', 'FM') THEN
            SELECT MAX(app_sc), MAX(app_scc) INTO p_app_sc, p_app_scс
            FROM ap_person app
            WHERE app_ap = p_ap_id
                  AND app_tp = 'Z'
                  AND app_sc IS NOT NULL
                  AND app.history_status = 'A';
        WHEN l_is_801 > 0 THEN
            SELECT MAX(app_sc), MAX(app_scc) INTO p_app_sc, p_app_scс
             FROM ap_person app
             WHERE app_ap = p_ap_id
                   AND app_tp = 'OS'
                   AND app_sc IS NOT NULL
                   AND app.history_status = 'A';
        WHEN l_is_802 > 0 AND API$PERSONALCASE.get_ap_doc_string(p_ap_id, 802, 1944, '-') IN ('FM') THEN
            SELECT MAX(app_sc), MAX(app_scc) INTO p_app_sc, p_app_scс
            FROM ap_person app
            WHERE app_ap = p_ap_id
                  AND app_tp = 'Z'
                  AND app_sc IS NOT NULL
                  AND app.history_status = 'A';
        WHEN l_is_802 > 0 AND l_cnt_OS  > 0 THEN
            SELECT MAX(app_sc), MAX(app_scc) INTO p_app_sc, p_app_scс
             FROM ap_person app
             WHERE app_ap = p_ap_id
                   AND app_tp = 'OS'
                   AND app_sc IS NOT NULL
                   AND app.history_status = 'A';
        WHEN l_is_802 > 0 THEN
            SELECT MAX(app_sc), MAX(app_scc) INTO p_app_sc, p_app_scс
            FROM ap_person app
            WHERE app_ap = p_ap_id
                  AND app_tp = 'Z'
                  AND app_sc IS NOT NULL
                  AND app.history_status = 'A';
        ELSE
            SELECT MAX(app_sc), MAX(app_scc) INTO p_app_sc, p_app_scс
            FROM ap_person app
            WHERE app_ap = p_ap_id
                  AND app_tp = 'Z'
                  AND app_sc IS NOT NULL
                  AND app.history_status = 'A';
        END CASE;*/

    END;

    --============================================
    -- отримати app_sc за зверненням
    --============================================
    FUNCTION Get_sc_by_appeal (p_ap_id NUMBER)
        RETURN NUMBER
    IS
        l_app_sc    NUMBER (10);
        l_app_scc   NUMBER (10);
    BEGIN
        Get_sc_scc_by_appeal (p_ap_id,
                              NULL,
                              NULL,
                              l_app_sc,
                              l_app_scc);
        RETURN l_app_sc;
    END;

    ----
    FUNCTION Get_sc_by_appeal (p_ap_id NUMBER, p_ap_tp VARCHAR2)
        RETURN NUMBER
    IS
        l_app_sc    NUMBER (10);
        l_app_scc   NUMBER (10);
    BEGIN
        Get_sc_scc_by_appeal (p_ap_id,
                              p_ap_tp,
                              NULL,
                              l_app_sc,
                              l_app_scc);
        RETURN l_app_sc;
    END;

    FUNCTION Get_sc_by_appeal (p_ap_id    NUMBER,
                               p_ap_tp    VARCHAR2,
                               p_ap_src   VARCHAR2)
        RETURN NUMBER
    IS
        l_app_sc    NUMBER (10);
        l_app_scc   NUMBER (10);
    BEGIN
        Get_sc_scc_by_appeal (p_ap_id,
                              p_ap_tp,
                              p_ap_src,
                              l_app_sc,
                              l_app_scc);
        RETURN l_app_sc;
    END;

    --============================================
    -- отримати app_scc за зверненням
    --============================================
    FUNCTION Get_scc_by_appeal (p_ap_id NUMBER)
        RETURN NUMBER
    IS
        l_app_sc    NUMBER (10);
        l_app_scc   NUMBER (10);
    BEGIN
        Get_sc_scc_by_appeal (p_ap_id,
                              NULL,
                              NULL,
                              l_app_sc,
                              l_app_scc);
        RETURN l_app_scc;
    END;

    ----
    FUNCTION Get_scc_by_appeal (p_ap_id NUMBER, p_ap_tp VARCHAR2)
        RETURN NUMBER
    IS
        l_app_sc    NUMBER (10);
        l_app_scc   NUMBER (10);
    BEGIN
        Get_sc_scc_by_appeal (p_ap_id,
                              p_ap_tp,
                              NULL,
                              l_app_sc,
                              l_app_scc);
        RETURN l_app_scc;
    END;

    /*
      FUNCTION Get_scc_by_appeal (p_ap_id NUMBER) RETURN NUMBER IS
        l_app_scc NUMBER(10);
      BEGIN
        SELECT MAX(app_scc)
        INTO l_app_scc
        FROM (
              SELECT app_scc
              FROM appeal
                   JOIN ap_person ON app_ap = ap_id AND history_status = 'A'
              WHERE ap_tp != 'SS'
                    AND ap_id = p_ap_id
                    AND app_tp IN ('Z','O')
              UNION ALL
              SELECT DISTINCT first_value(app_scc) OVER (PARTITION BY ap_id ORDER BY app_id) AS app_scc
              FROM appeal ap
                   JOIN ap_person app ON app_ap = ap_id AND app.history_status = 'A'
              WHERE ap.ap_tp = 'SS'
                    AND ap_id = p_ap_id
                    AND (
                         (API$PERSONALCASE.get_ap_doc_string(ap_id, 801, 1895, '-') IN ('Z', 'FM')
                          AND app_tp = 'Z' )
                          OR
                         (API$PERSONALCASE.get_ap_doc_string(ap_id, 801, 1895, '-') IN ('B', 'CHRG')
                          AND app_tp = 'OS' )
                          OR
                         (API$PERSONALCASE.get_ap_doc_cnt(ap_id, 801) = 0
                          AND API$PERSONALCASE.get_ap_doc_list_cnt(ap_id, '802,803') > 0
                          AND app_tp = 'OS')
                          OR
                         (API$PERSONALCASE.get_ap_doc_string(ap_id, 801, 1895, '-') NOT IN ('Z', 'FM', 'B', 'CHRG')
                          AND API$PERSONALCASE.get_ap_doc_list_cnt(ap_id, '802,803') = 0
                          AND app_tp = 'Z' )
                      )
              );
        RETURN l_app_scc;
      END;
    */
    --Створення ЕОС на основі заявників зверненнь

    PROCEDURE init_pc_by_appeal
    IS
        l_cnt        INTEGER;
        l_messages   SYS_REFCURSOR;
        l_ap_sc      NUMBER;
    BEGIN
        --#78239 20220628
        SELECT COUNT (*)
          INTO l_cnt
          FROM appeal
         WHERE ap_pc IS NULL AND ap_tp NOT IN ('SS', 'R.OS', 'R.GS');

        IF l_cnt > 0
        THEN
            --Створюємо нові ЕОС на основі заявників зверненнь
            DELETE FROM tmp_work_set2
                  WHERE 1 = 1;

            INSERT INTO tmp_work_set2 (x_id1,
                                       x_string1,
                                       x_dt1,
                                       x_id2,
                                       x_string2,
                                       x_id3)
                SELECT id_personalcase (0)     AS x_pc_id,
                       x_pc_num,
                       x_create_dt,
                       x_app_sc,
                       x_pc_st,
                       x_com_org
                  FROM (SELECT    (CASE
                                       WHEN org_to = 33 THEN org_org
                                       WHEN org_to = 35 THEN ap_dest_org
                                       ELSE org_id
                                   END)
                               || '-'
                               || app_id                         AS x_pc_num,
                               SYSDATE                           AS x_create_dt,
                               app_sc                            AS x_app_sc,
                               'R'                               AS x_pc_st,
                               CASE
                                   WHEN org_to = 33 THEN org_org
                                   WHEN org_to = 35 THEN ap_dest_org
                                   ELSE org_id
                               END                               AS x_com_org --nvl(TOOLS.GetCurrOrg, com_org)--#75120  2022.01.28
                                                                             ,
                               COUNT (app_sc)
                                   OVER (PARTITION BY app_sc
                                         ORDER BY app_id ASC)    AS cnt
                          FROM appeal, ap_person, ikis_sys.v_opfu
                         WHERE     app_ap = ap_id
                               AND ap_person.history_status = 'A'
                               AND ap_pc IS NULL
                               --                AND app_tp IN ('Z','O')
                               AND (   app_tp IN ('Z', 'O')
                                    OR (    app_tp IN ('ANF')
                                        AND NOT EXISTS
                                                (SELECT 1
                                                   FROM ap_person t
                                                  WHERE     t.app_ap = ap_id
                                                        AND t.app_tp = 'Z'
                                                        AND t.history_status =
                                                            'A')))
                               AND app_sc IS NOT NULL
                               AND com_org = org_id
                               AND NOT EXISTS
                                       (SELECT 1
                                          FROM personalcase
                                         WHERE pc_sc = app_sc)
                               AND ap_tp NOT IN ('SS', 'R.OS', 'R.GS'))
                 WHERE cnt < 2;

            INSERT INTO personalcase (pc_id,
                                      pc_num,
                                      pc_create_dt,
                                      pc_sc,
                                      pc_st,
                                      com_org)
                SELECT x_id1,
                       x_string1,
                       x_dt1,
                       x_id2,
                       x_string2,
                       x_id3
                  FROM tmp_work_set2;

            INSERT INTO uss_esr.pc_location (pl_id,
                                             pl_pc,
                                             pl_org,
                                             pl_start_dt,
                                             pl_stop_dt,
                                             history_status)
                SELECT 0,
                       x_id1     AS pc_id,
                       x_id3     AS com_org,
                       TO_DATE ('01.01.2000', 'DD.MM.YYYY'),
                       TO_DATE ('31.12.2999', 'DD.MM.YYYY'),
                       'A'
                  FROM tmp_work_set2;

            --Чіпляємо звернення до ЕОС заявника
            UPDATE appeal
               SET ap_pc =
                       (SELECT MAX (pc_id)
                          FROM personalcase, ap_person app
                         WHERE     app_sc = pc_sc
                               AND app_ap = ap_id
                               AND app.history_status = 'A'
                               --AND app_tp IN ('Z','O')
                               AND (   app_tp IN ('Z', 'O')
                                    OR (    app_tp IN ('ANF')
                                        AND NOT EXISTS
                                                (SELECT 1
                                                   FROM ap_person t
                                                  WHERE     t.app_ap = ap_id
                                                        AND t.app_tp = 'Z'
                                                        AND t.history_status =
                                                            'A'))))
             WHERE ap_pc IS NULL AND ap_tp NOT IN ('SS', 'R.OS', 'R.GS');
        END IF;

        --#78239 2022.06.28
        SELECT COUNT (*)
          INTO l_cnt
          FROM appeal
         WHERE ap_pc IS NULL AND ap_tp = 'SS';

        IF l_cnt > 0
        THEN
            --Створюємо нові ЕОС на основі заявників зверненнь
            DELETE FROM tmp_work_set2
                  WHERE 1 = 1;

            INSERT INTO tmp_work_set2 (x_id1,
                                       x_string1,
                                       x_dt1,
                                       x_id2,
                                       x_string2,
                                       x_id3)
                --    INSERT INTO personalcase (pc_id, pc_num, pc_create_dt, pc_sc, pc_st, com_org)
                WITH
                    app
                    AS
                        (SELECT DISTINCT
                                com_org,
                                FIRST_VALUE (app_id)
                                    OVER (PARTITION BY app_sc
                                          ORDER BY app_sc)    AS app_id,
                                app_sc
                           FROM appeal  ap
                                JOIN ap_person app
                                    ON     app_ap = ap_id
                                       AND app_sc IS NOT NULL
                                       AND app.history_status = 'A'
                          WHERE     ap.ap_tp = 'SS'
                                AND ap_pc IS NULL
                                AND app_sc =
                                    api$personalcase.Get_sc_by_appeal (ap_id,
                                                                       ap_tp))
                /*      WITH app AS (
                                    SELECT DISTINCT ap_id, com_org,
                                           first_value(app_id) OVER (PARTITION BY ap_id ORDER BY app_id) AS app_id,
                                           first_value(app_sc) OVER (PARTITION BY ap_id ORDER BY app_id) AS app_sc
                                    FROM appeal ap
                                         JOIN ap_person app ON app_ap = ap_id AND app_sc IS NOT NULL AND app.history_status = 'A'
                                    WHERE ap.ap_tp = 'SS'
                                          AND ap_pc IS NULL
                                          AND app_sc = api$personalcase.Get_sc_by_appeal(ap_id, ap_tp)
                                  )*/
                SELECT 0,
                          (CASE WHEN org_to = 33 THEN org_org ELSE org_id END)
                       || '-'
                       || app_id,
                       SYSDATE,
                       app_sc,
                       'R',
                       CASE WHEN org_to = 33 THEN org_org ELSE org_id END
                  FROM app, ikis_sys.v_opfu
                 WHERE     com_org = org_id
                       AND NOT EXISTS
                               (SELECT 1
                                  FROM personalcase
                                 WHERE pc_sc = app_sc);

            INSERT INTO personalcase (pc_id,
                                      pc_num,
                                      pc_create_dt,
                                      pc_sc,
                                      pc_st,
                                      com_org)
                SELECT x_id1,
                       x_string1,
                       x_dt1,
                       x_id2,
                       x_string2,
                       x_id3
                  FROM tmp_work_set2
                 WHERE x_id1 != 0;

            INSERT INTO uss_esr.pc_location (pl_id,
                                             pl_pc,
                                             pl_org,
                                             pl_start_dt,
                                             pl_stop_dt,
                                             history_status)
                SELECT 0,
                       x_id1     AS pc_id,
                       x_id3     AS com_org,
                       TO_DATE ('01.01.2000', 'DD.MM.YYYY'),
                       TO_DATE ('31.12.2999', 'DD.MM.YYYY'),
                       'A'
                  FROM tmp_work_set2
                 WHERE x_id1 != 0;

            FOR Rec IN (SELECT *
                          FROM tmp_work_set2
                         WHERE x_id1 = 0)
            LOOP
                Rec.x_Id1 := id_personalcase (0);

                INSERT INTO personalcase (pc_id,
                                          pc_num,
                                          pc_create_dt,
                                          pc_sc,
                                          pc_st,
                                          com_org)
                     VALUES (Rec.x_id1,
                             Rec.x_string1,
                             Rec.x_dt1,
                             Rec.x_id2,
                             Rec.x_string2,
                             Rec.x_id3);

                INSERT INTO uss_esr.pc_location (pl_id,
                                                 pl_pc,
                                                 pl_org,
                                                 pl_start_dt,
                                                 pl_stop_dt,
                                                 history_status)
                     VALUES (0,
                             Rec.x_Id1,
                             Rec.x_id3,
                             TO_DATE ('01.01.2000', 'DD.MM.YYYY'),
                             TO_DATE ('31.12.2999', 'DD.MM.YYYY'),
                             'A');
            END LOOP;

            --Чіпляємо звернення до ЕОС заявника

            FOR vI
                IN (SELECT ap_id,
                           api$personalcase.Get_sc_by_appeal (ap_id,
                                                              ap_tp,
                                                              ap_src)    ap_sc
                      FROM appeal
                     WHERE ap_pc IS NULL AND ap_tp = 'SS')
            LOOP
                UPDATE appeal
                   SET ap_pc =
                           (SELECT DISTINCT
                                   FIRST_VALUE (pc.pc_id)
                                       OVER (PARTITION BY app_ap
                                             ORDER BY app_id)    AS pc_id
                              FROM ap_person  app
                                   JOIN personalcase pc ON app_sc = pc_sc
                             WHERE     app.app_ap = ap_id
                                   AND app_sc IS NOT NULL
                                   AND app.history_status = 'A'
                                   AND app_sc = vI.ap_sc)
                 WHERE ap_id = vI.ap_id;
            END LOOP;
        END IF;

        --#78239 2022.06.28
        SELECT COUNT (*)
          INTO l_cnt
          FROM appeal
         WHERE ap_pc IS NULL AND ap_tp IN ('R.OS', 'R.GS');

        IF l_cnt > 0
        THEN
            --Чіпляємо звернення до ЕОС заявника
            FOR vI
                IN (SELECT ap_id,
                           api$personalcase.Get_sc_by_appeal (ap_id,
                                                              ap_tp,
                                                              ap_src)    ap_sc
                      FROM appeal
                     WHERE ap_pc IS NULL AND ap_tp IN ('R.OS', 'R.GS'))
            LOOP
                UPDATE appeal
                   SET ap_pc =
                           (SELECT DISTINCT
                                   FIRST_VALUE (pc.pc_id)
                                       OVER (PARTITION BY app_ap
                                             ORDER BY app_id)    AS pc_id
                              FROM ap_person  app
                                   JOIN personalcase pc ON app_sc = pc_sc
                             WHERE     app.app_ap = ap_id
                                   AND app_sc IS NOT NULL
                                   AND app.history_status = 'A'
                                   AND app_sc = vI.ap_sc)
                 WHERE ap_id = vI.ap_id;
            END LOOP;
        END IF;


        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
            SELECT ap_id
              FROM appeal
             WHERE     ap_st IN ('O')
                   AND EXISTS
                           (SELECT 1
                              FROM pc_decision
                             WHERE pd_ap = ap_id);

        --Навіть якщо станеться якась помилка - звернення будуть в Черзі на створення рішень, доступну користувачеві
        BEGIN
            API$PD_INIT.init_pc_decision_by_appeals (2, NULL, l_messages);
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;
    END;

    PROCEDURE init_pc_by_appeal_old
    IS
        l_cnt        INTEGER;
        l_messages   SYS_REFCURSOR;
    BEGIN
        --#78239 20220628
        SELECT COUNT (*)
          INTO l_cnt
          FROM appeal
         WHERE ap_pc IS NULL AND ap_tp != 'SS';

        IF l_cnt > 0
        THEN
            --Створюємо нові ЕОС на основі заявників зверненнь
            DELETE FROM tmp_work_set2
                  WHERE 1 = 1;

            INSERT INTO tmp_work_set2 (x_id1,
                                       x_string1,
                                       x_dt1,
                                       x_id2,
                                       x_string2,
                                       x_id3)
                SELECT id_personalcase (0)     AS x_pc_id,
                       x_pc_num,
                       x_create_dt,
                       x_app_sc,
                       x_pc_st,
                       x_com_org
                  FROM (SELECT    (CASE
                                       WHEN org_to = 33 THEN org_org
                                       ELSE org_id
                                   END)
                               || '-'
                               || app_id                         AS x_pc_num,
                               SYSDATE                           AS x_create_dt,
                               app_sc                            AS x_app_sc,
                               'R'                               AS x_pc_st,
                               CASE
                                   WHEN org_to = 33 THEN org_org
                                   ELSE org_id
                               END                               AS x_com_org --nvl(TOOLS.GetCurrOrg, com_org)--#75120  2022.01.28
                                                                             ,
                               COUNT (app_sc)
                                   OVER (PARTITION BY app_sc
                                         ORDER BY app_id ASC)    AS cnt
                          FROM appeal, ap_person app, ikis_sys.v_opfu
                         WHERE     app_ap = ap_id
                               AND app.history_status = 'A'
                               AND ap_pc IS NULL
                               AND (   app_tp IN ('Z', 'O')
                                    OR (    app_tp IN ('ANF')
                                        AND NOT EXISTS
                                                (SELECT 1
                                                   FROM ap_person t
                                                  WHERE     t.app_ap = ap_id
                                                        AND t.app_tp = 'Z'
                                                        AND t.history_status =
                                                            'A')))
                               AND app_sc IS NOT NULL
                               AND com_org = org_id
                               AND NOT EXISTS
                                       (SELECT 1
                                          FROM personalcase
                                         WHERE pc_sc = app_sc)
                               AND ap_tp != 'SS')
                 WHERE cnt < 2;

            INSERT INTO personalcase (pc_id,
                                      pc_num,
                                      pc_create_dt,
                                      pc_sc,
                                      pc_st,
                                      com_org)
                SELECT x_id1,
                       x_string1,
                       x_dt1,
                       x_id2,
                       x_string2,
                       x_id3
                  FROM tmp_work_set2;

            INSERT INTO uss_esr.pc_location (pl_id,
                                             pl_pc,
                                             pl_org,
                                             pl_start_dt,
                                             pl_stop_dt,
                                             history_status)
                SELECT 0,
                       x_id1     AS pc_id,
                       x_id3     AS com_org,
                       TO_DATE ('01.01.2000', 'DD.MM.YYYY'),
                       TO_DATE ('31.12.2999', 'DD.MM.YYYY'),
                       'A'
                  FROM tmp_work_set2;

            /*
                INSERT INTO personalcase (pc_id, pc_num, pc_create_dt, pc_sc, pc_st, com_org)
                    SELECT x_pc_id, x_pc_num, x_create_dt, x_app_sc, x_pc_st, x_com_org
                    FROM (      SELECT 0 AS x_pc_id, (CASE WHEN org_to = 33 THEN org_org ELSE org_id END)||'-'||app_id as x_pc_num, sysdate as x_create_dt,
                                 app_sc AS x_app_sc, 'R' AS x_pc_st,
                                 CASE WHEN org_to = 33 THEN org_org ELSE org_id END as x_com_org--nvl(TOOLS.GetCurrOrg, com_org)--#75120  2022.01.28
                                 ,count(app_sc) over (partition by app_sc order by app_id asc) AS cnt
                          FROM appeal, ap_person, ikis_sys.v_opfu
                          WHERE app_ap = ap_id
                            AND ap_person.history_status = 'A'
                            AND ap_pc IS NULL
                            AND app_tp IN ('Z','O')
                            AND app_sc IS NOT NULL
                            AND com_org = org_id
                            AND NOT EXISTS (SELECT 1
                                            FROM personalcase
                                            WHERE pc_sc = app_sc)
                            AND ap_tp != 'SS'
                         )
                    WHERE cnt<2;
            */


            --Чіпляємо звернення до ЕОС заявника
            UPDATE appeal
               SET ap_pc =
                       (SELECT MAX (pc_id)
                          FROM personalcase, ap_person app
                         WHERE     app_sc = pc_sc
                               AND app_ap = ap_id
                               AND app.history_status = 'A'
                               --                     AND app_tp IN ('Z','O')
                               AND (   app_tp IN ('Z', 'O')
                                    OR (    app_tp IN ('ANF')
                                        AND NOT EXISTS
                                                (SELECT 1
                                                   FROM ap_person t
                                                  WHERE     t.app_ap = ap_id
                                                        AND t.app_tp = 'Z'
                                                        AND t.history_status =
                                                            'A'))))
             WHERE ap_pc IS NULL AND ap_tp != 'SS';
        END IF;

        --#78239 2022.06.28
        SELECT COUNT (*)
          INTO l_cnt
          FROM appeal
         WHERE ap_pc IS NULL AND ap_tp = 'SS';

        IF l_cnt > 0
        THEN
            --Створюємо нові ЕОС на основі заявників зверненнь
            DELETE FROM tmp_work_set2
                  WHERE 1 = 1;

            INSERT INTO tmp_work_set2 (x_id1,
                                       x_string1,
                                       x_dt1,
                                       x_id2,
                                       x_string2,
                                       x_id3)
                --    INSERT INTO personalcase (pc_id, pc_num, pc_create_dt, pc_sc, pc_st, com_org)
                WITH
                    app
                    AS
                        (SELECT DISTINCT
                                ap_id,
                                com_org,
                                FIRST_VALUE (app_id)
                                    OVER (PARTITION BY ap_id ORDER BY app_id)
                                    AS app_id,
                                FIRST_VALUE (app_sc)
                                    OVER (PARTITION BY ap_id ORDER BY app_id)
                                    AS app_sc
                           FROM appeal  ap
                                JOIN ap_person app
                                    ON     app_ap = ap_id
                                       AND app_sc IS NOT NULL
                                       AND app.history_status = 'A'
                          WHERE     ap.ap_tp = 'SS'
                                AND ap_pc IS NULL
                                AND (   (    API$PERSONALCASE.get_ap_doc_cnt (
                                                 ap_id,
                                                 801) >
                                             0
                                         AND API$PERSONALCASE.get_ap_doc_string (
                                                 ap_id,
                                                 801,
                                                 1895,
                                                 '-') IN ('Z', 'FM')
                                         AND app_tp = 'Z')
                                     OR (    API$PERSONALCASE.get_ap_doc_cnt (
                                                 ap_id,
                                                 801) >
                                             0
                                         AND API$PERSONALCASE.get_ap_doc_string (
                                                 ap_id,
                                                 801,
                                                 1895,
                                                 '-') IN ('B', 'CHRG')
                                         AND app_tp = 'OS')
                                     OR (    API$PERSONALCASE.get_ap_doc_cnt (
                                                 ap_id,
                                                 801) =
                                             0
                                         AND API$PERSONALCASE.get_ap_doc_list_cnt (
                                                 ap_id,
                                                 '802,803') >
                                             0
                                         AND app_tp = 'OS')
                                     OR (    API$PERSONALCASE.get_ap_doc_string (
                                                 ap_id,
                                                 801,
                                                 1895,
                                                 '-') NOT IN ('Z',
                                                              'FM',
                                                              'B',
                                                              'CHRG')
                                         AND API$PERSONALCASE.get_ap_doc_list_cnt (
                                                 ap_id,
                                                 '802,803') =
                                             0
                                         AND app_tp = 'Z')))
                SELECT 0,
                          (CASE WHEN org_to = 33 THEN org_org ELSE org_id END)
                       || '-'
                       || app_id,
                       SYSDATE,
                       app_sc,
                       'R',
                       CASE WHEN org_to = 33 THEN org_org ELSE org_id END
                  FROM app, ikis_sys.v_opfu
                 WHERE     com_org = org_id
                       AND NOT EXISTS
                               (SELECT 1
                                  FROM personalcase
                                 WHERE pc_sc = app_sc);

            INSERT INTO personalcase (pc_id,
                                      pc_num,
                                      pc_create_dt,
                                      pc_sc,
                                      pc_st,
                                      com_org)
                SELECT x_id1,
                       x_string1,
                       x_dt1,
                       x_id2,
                       x_string2,
                       x_id3
                  FROM tmp_work_set2;

            INSERT INTO uss_esr.pc_location (pl_id,
                                             pl_pc,
                                             pl_org,
                                             pl_start_dt,
                                             pl_stop_dt,
                                             history_status)
                SELECT 0,
                       x_id1     AS pc_id,
                       x_id3     AS com_org,
                       TO_DATE ('01.01.2000', 'DD.MM.YYYY'),
                       TO_DATE ('31.12.2999', 'DD.MM.YYYY'),
                       'A'
                  FROM tmp_work_set2;

            --Чіпляємо звернення до ЕОС заявника
            UPDATE appeal
               SET ap_pc =
                       (SELECT DISTINCT
                               FIRST_VALUE (pc.pc_id)
                                   OVER (PARTITION BY app_ap ORDER BY app_id)    AS pc_id
                          FROM ap_person  app
                               JOIN personalcase pc ON app_sc = pc_sc
                         WHERE     app.app_ap = ap_id
                               AND app_sc IS NOT NULL
                               AND app.history_status = 'A'
                               AND (   (    API$PERSONALCASE.get_ap_doc_cnt (
                                                ap_id,
                                                801) >
                                            0
                                        AND API$PERSONALCASE.get_ap_doc_string (
                                                ap_id,
                                                801,
                                                1895,
                                                '-') IN ('Z', 'FM')
                                        AND app_tp = 'Z')
                                    OR (    API$PERSONALCASE.get_ap_doc_cnt (
                                                ap_id,
                                                801) >
                                            0
                                        AND API$PERSONALCASE.get_ap_doc_string (
                                                ap_id,
                                                801,
                                                1895,
                                                '-') IN ('B', 'CHRG')
                                        AND app_tp = 'OS')
                                    OR (    API$PERSONALCASE.get_ap_doc_cnt (
                                                ap_id,
                                                801) =
                                            0
                                        AND API$PERSONALCASE.get_ap_doc_list_cnt (
                                                ap_id,
                                                '802,803') >
                                            0
                                        AND app_tp = 'OS')
                                    OR (    API$PERSONALCASE.get_ap_doc_string (
                                                ap_id,
                                                801,
                                                1895,
                                                '-') NOT IN ('Z',
                                                             'FM',
                                                             'B',
                                                             'CHRG')
                                        AND API$PERSONALCASE.get_ap_doc_list_cnt (
                                                ap_id,
                                                '802,803') =
                                            0
                                        AND app_tp = 'Z')))
             WHERE ap_pc IS NULL AND ap_tp = 'SS';
        END IF;

        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
            SELECT ap_id
              FROM appeal
             WHERE     ap_st = 'O'
                   AND EXISTS
                           (SELECT 1
                              FROM pc_decision
                             WHERE pd_ap = ap_id);

        --Навіть якщо станеться якась помилка - звернення будуть в Черзі на створення рішень, доступну користувачеві
        BEGIN
            API$PD_INIT.init_pc_decision_by_appeals (2, NULL, l_messages);
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;
    END;

    --Додавання в чергу на перерахунок запису
    PROCEDURE add_pc_accrual_queue (
        p_paq_pc         pc_accrual_queue.paq_pc%TYPE,
        p_paq_tp         pc_accrual_queue.paq_tp%TYPE,
        p_paq_start_dt   pc_accrual_queue.paq_start_dt%TYPE,
        p_paq_stop_dt    pc_accrual_queue.paq_stop_dt%TYPE,
        p_paq_doc        pc_accrual_queue.paq_pd%TYPE,
        p_hs             pc_accrual_queue.paq_hs_ins%TYPE:= NULL)
    IS
        l_hs             histsession.hs_id%TYPE;
        l_paq_start_dt   pc_accrual_queue.paq_start_dt%TYPE;
        l_paq_stop_dt    pc_accrual_queue.paq_start_dt%TYPE;
        l_bp_month       billing_period.bp_month%TYPE;
    BEGIN
        IF p_paq_start_dt < TO_DATE ('01.03.2022', 'DD.MM.YYYY')
        THEN
            l_paq_start_dt := TO_DATE ('01.03.2022', 'DD.MM.YYYY');
        ELSE
            l_paq_start_dt := p_paq_start_dt;
        END IF;

        IF p_paq_stop_dt < TO_DATE ('01.03.2022', 'DD.MM.YYYY')
        THEN
            l_paq_stop_dt := TO_DATE ('31.03.2022', 'DD.MM.YYYY');
        ELSE
            l_paq_stop_dt := p_paq_stop_dt;
        END IF;

        --Якщо прийшов період більший за максимальний відкритий розрахунковий період, розтягуємо період "активації" вниз, до першого відкритого розрахункового періоду
        SELECT MAX (bp_month)
          INTO l_bp_month
          FROM personalcase pc, billing_period
         WHERE pc_id = p_paq_pc AND bp_org = pc.com_org AND bp_st = 'R';

        IF l_bp_month < l_paq_start_dt
        THEN
            l_paq_start_dt := l_bp_month;
        END IF;

        l_hs := NVL (p_hs, TOOLS.GetHistSession);

        INSERT INTO pc_accrual_queue (paq_id,
                                      paq_pc,
                                      paq_tp,
                                      paq_start_dt,
                                      paq_stop_dt,
                                      paq_pd,
                                      paq_dn,
                                      paq_st,
                                      paq_hs_ins)
             VALUES (0,
                     p_paq_pc,
                     p_paq_tp,
                     l_paq_start_dt,
                     l_paq_stop_dt,
                     DECODE (p_paq_tp, 'PD', p_paq_doc),
                     DECODE (p_paq_tp, 'DN', p_paq_doc),
                     'W',
                     l_hs);
    END;

    -- скасування звернення з превіркою на стан для Є-допомоги
    PROCEDURE calcel_pd_by_appeal (p_ap appeal.ap_id%TYPE, p_ret OUT BOOLEAN)
    IS
        l_ap_st   VARCHAR2 (10);
        l_pd_st   VARCHAR2 (10);
        l_ap_tp   appeal.ap_tp%TYPE;
    BEGIN
        p_ret := FALSE;

        SELECT MAX (ap_tp), MAX (ap_st), MAX (pd_st)
          INTO l_ap_tp, l_ap_st, l_pd_st
          FROM appeal LEFT JOIN pc_decision ON ap_id = pd_ap
         WHERE ap_id = p_ap;

        IF l_ap_st = 'S'
        THEN
            --Звернення не оброблено
            UPDATE appeal
               SET ap_st = 'X'
             WHERE ap_id = p_ap AND ap_st = 'S';

            p_ret := (SQL%ROWCOUNT > 0);
        ELSIF l_ap_st = 'WD' AND l_pd_st IS NULL
        THEN
            --Звернення оброблено, але рішення не створене
            UPDATE appeal
               SET ap_st = 'X'
             WHERE ap_id = p_ap AND ap_st = 'WD';

            p_ret := (SQL%ROWCOUNT > 0);
        ELSIF     l_ap_st IN ('WD', 'NS')
              AND (   l_pd_st IN ('R0', 'R1', 'AP')
                   OR (l_ap_tp = 'IA' AND l_pd_st = 'WD')) --Звернення оброблено, рішення створене, але не Передано до міжнародної організації/#85079 в тому числі дубль по учаснику
        THEN
            UPDATE appeal
               SET ap_st = 'X'
             WHERE ap_id = p_ap AND ap_st IN ('WD', 'NS');

            p_ret := (SQL%ROWCOUNT > 0);

            IF p_ret
            THEN
                UPDATE pc_decision
                   SET pd_st = 'V'
                 WHERE pd_ap = p_ap;

                UPDATE ap_service
                   SET aps_st = 'V'
                 WHERE aps_ap = p_ap;
            END IF;
        ELSE
            NULL;
        END IF;
    END;

    FUNCTION Get_pc_by_sc (p_sc IN NUMBER)
        RETURN NUMBER
    IS
        l_Res   NUMBER;
    BEGIN
        SELECT MAX (pc_id)
          INTO l_Res
          FROM personalcase p
         WHERE p.pc_sc = p_sc;

        RETURN l_Res;
    END;

    PROCEDURE move_pc_to_other_org (p_pc_id     personalcase.pc_id%TYPE,
                                    p_new_org   personalcase.com_org%TYPE,
                                    p_reason    VARCHAR2)
    IS
        l_pc    v_personalcase%ROWTYPE;
        l_org   personalcase.com_org%TYPE;
    BEGIN
        --  IF TOOLS.GetCurrOrgTo NOT IN (40) AND NOT tools.is_role_assigned('W_ESR_PAYROLL') THEN
        --    raise_application_error(-20000, 'Тільки користувач ІОЦ з роллю "Технолог виплатних відомостей" може виконувати цю функцію!');
        --  END IF;

        SELECT *
          INTO l_pc
          FROM v_personalcase
         WHERE pc_id = p_pc_id;

        SELECT org_id
          INTO l_org
          FROM opfu
         WHERE org_st = 'A' AND org_to = 32 AND org_id = p_new_org;

        IF l_org = l_pc.com_org
        THEN
            raise_application_error (-20001,
                                     'ЕОС вже перебуває у вказаному ОСЗН!');
        END IF;

        UPDATE personalcase
           SET com_org = l_org
         WHERE pc_id = p_pc_id;

        DELETE FROM tmp_work_ids2
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids2
             VALUES (p_pc_id);

        API$PC_ATTESTAT.init_pc_location_internal (2);

        uss_person.api$socialcard.Write_Sc_Log (l_pc.pc_sc,
                                                NULL,
                                                NULL,
                                                p_reason,
                                                NULL,
                                                'USR');
        uss_person.api$socialcard.Write_Sc_Log (
            l_pc.pc_sc,
            NULL,
            NULL,
            CHR (38) || '306#' || l_pc.com_org || '#' || l_org,
            NULL,
            'SYS');
    END;
END API$PERSONALCASE;
/