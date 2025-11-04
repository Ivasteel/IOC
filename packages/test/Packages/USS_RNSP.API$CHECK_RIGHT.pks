/* Formatted on 8/12/2025 5:57:56 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.API$CHECK_RIGHT
IS
    -- Author  : LESHA
    -- Created : 28.03.2022 18:42:58
    -- Purpose : Перевірка складу звернення


    --  tel_ap   NUMBER(14),
    --  tel_aps  NUMBER(14),

    --Послуги
    TYPE R_Errors_List IS RECORD
    (
        --  tel_cnt  NUMBER(10),
        tel_result    VARCHAR2 (20),
        tel_text      VARCHAR2 (2000)
    );

    TYPE T_Errors_List IS TABLE OF R_Errors_List;

    Errors_List   T_Errors_List := T_Errors_List ();


    --==============================================================--
    --  Перевірка наявності документа
    --==============================================================--
    FUNCTION get_doc_count (p_ap    ap_document.apd_ap%TYPE,
                            p_ndt   ap_document.apd_ndt%TYPE)
        RETURN NUMBER;

    FUNCTION get_doclist_count (p_ap         ap_document.apd_ap%TYPE,
                                p_ndt_list   VARCHAR2)
        RETURN NUMBER;

    FUNCTION documents_exists (p_ap    ap_document.apd_ap%TYPE,
                               p_ndt   ap_document.apd_ndt%TYPE)
        RETURN VARCHAR2;

    --  Отримання текстового параметру документу по документу
    FUNCTION get_attr_string (p_ap        ap_document.apd_ap%TYPE,
                              p_ndt       ap_document.apd_ndt%TYPE,
                              p_nda       ap_document_attr.apda_nda%TYPE,
                              p_default   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;


    FUNCTION Check_NRR (sqlstr   VARCHAR2,
                        Cr4      VARCHAR2,
                        Cr5      VARCHAR2,
                        Cr6      VARCHAR2)
        RETURN NUMBER;

    PROCEDURE init_right_for_appeals (p_mode    INTEGER, --1=з p_ap_id, 2=з таблиці tmp_work_ids
                                      p_ap_id   appeal.ap_id%TYPE /*,
                                         p_messages OUT SYS_REFCURSOR*/
                                                                 );

    --========================================
    --  Встановлення ознаки перевірки по послузі.
    --========================================
    PROCEDURE Calck_aps_result (p_mode INTEGER, --1=з p_ap_id, 2=з таблиці tmp_work_ids
                                                p_ap_id appeal.ap_id%TYPE);

    --========================================
    PROCEDURE Calck_aps_result (p_aprl_id ap_right_log.aprl_id%TYPE);
--========================================

END API$CHECK_RIGHT;
/


/* Formatted on 8/12/2025 5:57:58 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RNSP.API$CHECK_RIGHT
IS
    Is_dbms_output   BOOLEAN := FALSE;

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
    PROCEDURE write_ap_log (p_apl_ap        ap_log.apl_ap%TYPE,
                            p_apl_hs        ap_log.apl_hs%TYPE,
                            p_apl_st        ap_log.apl_st%TYPE,
                            p_apl_message   ap_log.apl_message%TYPE,
                            p_apl_st_old    ap_log.apl_st_old%TYPE,
                            p_apl_tp        ap_log.apl_tp%TYPE:= 'SYS')
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        l_hs := NVL (p_apl_hs, TOOLS.GetHistSession);

        INSERT INTO ap_log (apl_id,
                            apl_hs,
                            apl_ap,
                            apl_st,
                            apl_message,
                            apl_st_old,
                            apl_tp)
             VALUES (0,
                     l_hs,
                     p_apl_ap,
                     p_apl_st,
                     p_apl_message,
                     p_apl_st_old,
                     NVL (p_apl_tp, 'SYS'));
    END;

    --========================================
    --  Отримання наявності документу
    --========================================
    FUNCTION get_doc_count (p_ap    ap_document.apd_ap%TYPE,
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

    FUNCTION get_doclist_count (p_ap         ap_document.apd_ap%TYPE,
                                p_ndt_list   VARCHAR2)
        RETURN NUMBER
    IS
        l_rez   NUMBER (10);
    BEGIN
        WITH
            ndt_list
            AS
                (    SELECT REGEXP_SUBSTR (p_ndt_list,
                                           '[^,]+',
                                           1,
                                           LEVEL)    AS i_ndt
                       FROM DUAL
                 CONNECT BY LEVEL <=
                            LENGTH (REGEXP_REPLACE (p_ndt_list, '[^,]*')) + 1)
        SELECT COUNT (1)
          INTO l_rez
          FROM ap_document JOIN ndt_list ON apd_ndt = i_ndt
         WHERE ap_document.history_status = 'A' AND apd_ap = p_ap;

        RETURN l_rez;
    END;

    --==============================================================--
    --  Перевірка наявності документа
    --==============================================================--
    FUNCTION documents_exists (p_ap    ap_document.apd_ap%TYPE,
                               p_ndt   ap_document.apd_ndt%TYPE)
        RETURN VARCHAR2
    IS
        l_err_list   VARCHAR2 (4000);
    BEGIN
        SELECT LISTAGG (ndt.ndt_name_short, ', ') WITHIN GROUP (ORDER BY 1)
          INTO l_err_list
          FROM uss_ndi.v_ndi_document_type  ndt
               LEFT JOIN ap_document apd
                   ON     apd.apd_ndt = ndt.ndt_id
                      AND apd.apd_ap = p_ap
                      AND apd.history_status = 'A'
         WHERE ndt.ndt_id = p_ndt AND apd.apd_id IS NULL;

        RETURN l_err_list;
    END;

    --  Отримання текстового параметру документу по документу
    FUNCTION get_attr_string (p_ap        ap_document.apd_ap%TYPE,
                              p_ndt       ap_document.apd_ndt%TYPE,
                              p_nda       ap_document_attr.apda_nda%TYPE,
                              p_default   VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
        l_rez   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (apda_val_string)
          INTO l_rez
          FROM ap_document
               JOIN ap_document_attr
                   ON     apda_apd = apd_id
                      AND ap_document_attr.history_status = 'A'
         WHERE     apd_ap = p_ap
               AND apd_ndt = p_ndt
               AND ap_document.history_status = 'A';


        IF p_default IS NOT NULL
        THEN
            RETURN NVL (l_rez, p_default);
        END IF;

        RETURN l_rez;
    END;

    --========================================
    PROCEDURE Set_ap_right_log (p_aps NUMBER, p_nrr NUMBER)
    IS
        n3   VARCHAR2 (20);
        v1   VARCHAR2 (200);
    BEGIN
        MERGE INTO ap_right_log
             USING (SELECT p_aps
                               AS b_aps,
                           p_nrr
                               AS b_nrr,
                           CASE tel_cnt WHEN 0 THEN 'T' ELSE 'F' END
                               AS b_result,
                           tel_text
                               AS b_info
                      FROM tmp_errors_list)
                ON (aprl_aps = b_aps AND aprl_nrr = b_nrr)
        WHEN MATCHED
        THEN
            UPDATE SET aprl_result = b_result,
                       aprl_calc_result = b_result,
                       aprl_calc_info = b_info,
                       aprl_hs_rewrite = NULL
        WHEN NOT MATCHED
        THEN
            INSERT     (aprl_id,
                        aprl_aps,
                        aprl_nrr,
                        aprl_result,
                        aprl_calc_result,
                        aprl_calc_info)
                VALUES (0,
                        b_aps,
                        b_nrr,
                        b_result,
                        b_result,
                        b_info);
    END;

    --========================================
    PROCEDURE ALG111 (p_ap NUMBER, p_aps NUMBER, p_nrr NUMBER)
    IS
    BEGIN
        INSERT INTO tmp_errors_list
            SELECT p_aps,
                   SUM (CASE WHEN x_text IS NULL THEN 0 ELSE 1 END)
                       AS tel_cnt,
                   LISTAGG (x_text, ', ') WITHIN GROUP (ORDER BY x_text)
                       AS tel_text
              FROM (SELECT API$Check_Right.documents_exists (p_ap, 711)    AS x_text
                      FROM DUAL);

        Set_ap_right_log (p_aps, p_nrr);
    END;

    --========================================
    PROCEDURE ALG112 (p_ap NUMBER, p_aps NUMBER, p_nrr NUMBER)
    IS
    BEGIN
        INSERT INTO tmp_errors_list
            SELECT p_aps,
                   SUM (CASE WHEN x_text IS NULL THEN 0 ELSE 1 END)
                       AS tel_cnt,
                   LISTAGG (x_text, ', ') WITHIN GROUP (ORDER BY x_text)
                       AS tel_text
              FROM (SELECT 'Не встановлено "Відповідність соціальних послуг державним стандартам"'    AS x_text
                      FROM DUAL
                     WHERE API$Check_Right.get_attr_string (p_ap,
                                                            700,
                                                            1131,
                                                            'F') = 'F');

        Set_ap_right_log (p_aps, p_nrr);
    END;

    --========================================
    PROCEDURE ALG113 (p_ap NUMBER, p_aps NUMBER, p_nrr NUMBER)
    IS
    BEGIN
        INSERT INTO tmp_errors_list
            SELECT p_aps,
                   SUM (CASE WHEN x_text IS NULL THEN 0 ELSE 1 END)
                       AS tel_cnt,
                   LISTAGG (x_text, ', ') WITHIN GROUP (ORDER BY x_text)
                       AS tel_text
              FROM (SELECT API$Check_Right.documents_exists (p_ap, 705)    AS x_text
                      FROM DUAL);

        Set_ap_right_log (p_aps, p_nrr);
    END;

    --========================================
    PROCEDURE ALG114 (p_ap NUMBER, p_aps NUMBER, p_nrr NUMBER)
    IS
    BEGIN
        INSERT INTO tmp_errors_list
            SELECT p_aps,
                   SUM (CASE WHEN x_text IS NULL THEN 0 ELSE 1 END)
                       AS tel_cnt,
                   LISTAGG (x_text, ', ') WITHIN GROUP (ORDER BY x_text)
                       AS tel_text
              FROM (SELECT API$Check_Right.documents_exists (p_ap, 708)    AS x_text
                      FROM DUAL);

        Set_ap_right_log (p_aps, p_nrr);
    END;

    --========================================
    PROCEDURE ALG115 (p_ap NUMBER, p_aps NUMBER, p_nrr NUMBER)
    IS
    BEGIN
        INSERT INTO tmp_errors_list
            SELECT p_aps,
                   SUM (CASE WHEN x_text IS NULL THEN 0 ELSE 1 END)
                       AS tel_cnt,
                   LISTAGG (x_text, ', ') WITHIN GROUP (ORDER BY x_text)
                       AS tel_text
              FROM (SELECT API$Check_Right.documents_exists (p_ap, 707)    AS x_text
                      FROM DUAL);

        Set_ap_right_log (p_aps, p_nrr);
    END;

    --========================================
    PROCEDURE ALG116 (p_ap NUMBER, p_aps NUMBER, p_nrr NUMBER)
    IS
    BEGIN
        INSERT INTO tmp_errors_list
            SELECT p_aps,
                   SUM (CASE WHEN x_text IS NULL THEN 0 ELSE 1 END)
                       AS tel_cnt,
                   LISTAGG (x_text, ', ') WITHIN GROUP (ORDER BY x_text)
                       AS tel_text
              FROM (SELECT API$Check_Right.documents_exists (p_ap, 710)    AS x_text
                      FROM DUAL);

        Set_ap_right_log (p_aps, p_nrr);
    END;

    --========================================
    PROCEDURE ALG117 (p_ap NUMBER, p_aps NUMBER, p_nrr NUMBER)
    IS
    BEGIN
        INSERT INTO tmp_errors_list
            SELECT p_aps,
                   SUM (CASE WHEN x_text IS NULL THEN 0 ELSE 1 END)
                       AS tel_cnt,
                   LISTAGG (x_text, ', ') WITHIN GROUP (ORDER BY x_text)
                       AS tel_text
              FROM (SELECT 'Не встановлено "Заходи з інформування населення"'    AS x_text
                      FROM DUAL
                     WHERE API$Check_Right.get_attr_string (p_ap,
                                                            700,
                                                            1132,
                                                            'F') = 'F');

        Set_ap_right_log (p_aps, p_nrr);
    END;

    --========================================
    PROCEDURE ALG118 (p_ap NUMBER, p_aps NUMBER, p_nrr NUMBER)
    IS
    BEGIN
        INSERT INTO tmp_errors_list
            SELECT p_aps,
                   SUM (CASE WHEN x_text IS NULL THEN 0 ELSE 1 END)
                       AS tel_cnt,
                   LISTAGG (x_text, ', ') WITHIN GROUP (ORDER BY x_text)
                       AS tel_text
              FROM (SELECT API$Check_Right.documents_exists (p_ap, 715)    AS x_text
                      FROM DUAL);

        Set_ap_right_log (p_aps, p_nrr);
    END;

    --========================================
    PROCEDURE ALG201 (p_ap NUMBER, p_aps NUMBER, p_nrr NUMBER)
    IS
    BEGIN
        INSERT INTO tmp_errors_list
            SELECT p_aps,
                   SUM (CASE WHEN x_text IS NULL THEN 0 ELSE 1 END)
                       AS tel_cnt,
                   LISTAGG (x_text, ', ') WITHIN GROUP (ORDER BY x_text)
                       AS tel_text
              FROM (SELECT API$Check_Right.documents_exists (p_ap, 714)    AS x_text
                      FROM DUAL);

        Set_ap_right_log (p_aps, p_nrr);
    END;

    --========================================
    PROCEDURE ALG202 (p_ap NUMBER, p_aps NUMBER, p_nrr NUMBER)
    IS
    BEGIN
        INSERT INTO tmp_errors_list
            SELECT p_aps,
                   SUM (CASE WHEN x_text IS NULL THEN 0 ELSE 1 END)
                       AS tel_cnt,
                   LISTAGG (x_text, ', ') WITHIN GROUP (ORDER BY x_text)
                       AS tel_text
              FROM (SELECT API$Check_Right.documents_exists (p_ap, 713)    AS x_text
                      FROM DUAL);

        Set_ap_right_log (p_aps, p_nrr);
    END;

    --========================================
    PROCEDURE ALG203 (p_ap NUMBER, p_aps NUMBER, p_nrr NUMBER)
    IS
    BEGIN
        INSERT INTO tmp_errors_list
            SELECT p_aps,
                   SUM (CASE WHEN x_text IS NULL THEN 0 ELSE 1 END)
                       AS tel_cnt,
                   LISTAGG (x_text, ', ') WITHIN GROUP (ORDER BY x_text)
                       AS tel_text
              FROM (WITH
                        doc
                        AS
                            (SELECT API$Check_Right.documents_exists (p_ap,
                                                                      '717')
                                        AS ndt717,
                                    API$Check_Right.documents_exists (p_ap,
                                                                      '718')
                                        AS ndt718,
                                    API$Check_Right.documents_exists (p_ap,
                                                                      '719')
                                        AS ndt719
                               --API$Check_Right.get_doc_count(p_ap, '717') AS ndt717,
                               --API$Check_Right.get_doc_count(p_ap, '718') AS ndt718,
                               --API$Check_Right.get_doc_count(p_ap, '719') AS ndt719
                               FROM DUAL)
                    SELECT CASE
                               WHEN     ndt717 IS NOT NULL
                                    AND ndt718 IS NOT NULL
                                    AND ndt719 IS NOT NULL
                               THEN
                                      'Винен бути '
                                   || ndt717
                                   || ' або '
                                   || ndt718
                                   || ', '
                                   || ndt719
                               WHEN ndt717 IS NULL
                               THEN
                                   NULL
                               WHEN ndt718 IS NOT NULL
                               THEN
                                   ndt718
                               WHEN ndt719 IS NOT NULL
                               THEN
                                   ndt719
                               ELSE
                                   NULL
                           END    AS x_text
                      FROM doc);

        Set_ap_right_log (p_aps, p_nrr);
    END;

    --========================================
    PROCEDURE ALG204 (p_ap NUMBER, p_aps NUMBER, p_nrr NUMBER)
    IS
    BEGIN
        INSERT INTO tmp_errors_list
            SELECT p_aps,
                   SUM (CASE WHEN x_text IS NULL THEN 0 ELSE 1 END)
                       AS tel_cnt,
                   LISTAGG (x_text, ', ') WITHIN GROUP (ORDER BY x_text)
                       AS tel_text
              FROM (WITH
                        doc
                        AS
                            (SELECT API$Check_Right.documents_exists (p_ap,
                                                                      '720')
                                        AS ndt720,
                                    API$Check_Right.documents_exists (p_ap,
                                                                      '721')
                                        AS ndt721,
                                    API$Check_Right.documents_exists (p_ap,
                                                                      '722')
                                        AS ndt722
                               FROM DUAL)
                    SELECT CASE
                               WHEN     ndt720 IS NOT NULL
                                    AND ndt721 IS NOT NULL
                                    AND ndt722 IS NOT NULL
                               THEN
                                      'Винен бути '
                                   || ndt720
                                   || ' або '
                                   || ndt721
                                   || ', '
                                   || ndt722
                               WHEN ndt720 IS NULL
                               THEN
                                   NULL
                               WHEN ndt721 IS NOT NULL
                               THEN
                                   ndt721
                               WHEN ndt722 IS NOT NULL
                               THEN
                                   ndt722
                               ELSE
                                   NULL
                           END    AS x_text
                      FROM doc);

        dbms_output_put_lines ('ALG204');

        Set_ap_right_log (p_aps, p_nrr);
    END;

    --========================================
    PROCEDURE ALG205 (p_ap NUMBER, p_aps NUMBER, p_nrr NUMBER)
    IS
    BEGIN
        INSERT INTO tmp_errors_list
            SELECT p_aps,
                   SUM (CASE WHEN x_text IS NULL THEN 0 ELSE 1 END)
                       AS tel_cnt,
                   LISTAGG (x_text, ', ') WITHIN GROUP (ORDER BY x_text)
                       AS tel_text
              FROM (WITH
                        doc
                        AS
                            (SELECT API$Check_Right.documents_exists (p_ap,
                                                                      '723')
                                        AS ndt723,
                                    API$Check_Right.documents_exists (p_ap,
                                                                      '724')
                                        AS ndt724
                               FROM DUAL)
                    SELECT CASE
                               WHEN ndt723 IS NOT NULL AND ndt724 IS NOT NULL
                               THEN
                                      'Винен бути '
                                   || ndt723
                                   || ' або '
                                   || ndt724
                               ELSE
                                   NULL
                           END    AS x_text
                      FROM doc);

        --723 Договір із закладом охорони здоров’я
        --724 Ліцензія на провадження господарської діяльності з медичної практики
        Set_ap_right_log (p_aps, p_nrr);
    END;

    --========================================
    PROCEDURE ALG206 (p_ap NUMBER, p_aps NUMBER, p_nrr NUMBER)
    IS
    BEGIN
        INSERT INTO tmp_errors_list
            SELECT p_aps,
                   SUM (CASE WHEN x_text IS NULL THEN 0 ELSE 1 END)
                       AS tel_cnt,
                   LISTAGG (x_text, ', ') WITHIN GROUP (ORDER BY x_text)
                       AS tel_text
              FROM (SELECT API$Check_Right.documents_exists (p_ap, 725)    AS x_text
                      FROM DUAL);

        Set_ap_right_log (p_aps, p_nrr);
    END;

    --========================================
    FUNCTION Check_NRR (sqlstr   VARCHAR2,
                        Cr4      VARCHAR2,
                        Cr5      VARCHAR2,
                        Cr6      VARCHAR2)
        RETURN NUMBER
    IS
        a1    NUMBER
                  := CASE WHEN NVL (Cr4, '0') IN ('0', 'F') THEN 0 ELSE 1 END;
        a2    NUMBER
                  := CASE WHEN NVL (Cr5, '0') IN ('0', 'F') THEN 0 ELSE 1 END;
        a3    NUMBER
                  := CASE WHEN NVL (Cr6, '0') IN ('0', 'F') THEN 0 ELSE 1 END;
        ret   NUMBER;
    BEGIN
        IF sqlstr IS NULL
        THEN
            RETURN 1;
        END IF;

        EXECUTE IMMEDIATE sqlstr
            INTO ret
            USING a1, a2, a3;

        RETURN CASE ret WHEN 0 THEN 0 ELSE 1 END;
    END;

    --========================================
    PROCEDURE Calck_aps_result (p_mode INTEGER, --1=з p_ap_id, 2=з таблиці tmp_work_ids
                                                p_ap_id appeal.ap_id%TYPE)
    IS
        l_cnt   INTEGER;
    BEGIN
        IF p_mode = 1 AND p_ap_id IS NOT NULL
        THEN
            DELETE FROM tmp_work_ids
                  WHERE 1 = 1;

            INSERT INTO tmp_work_ids (x_id)
                SELECT ap_id
                  FROM appeal
                 WHERE ap_id = p_ap_id;

            l_cnt := SQL%ROWCOUNT;
        ELSE
            SELECT COUNT (*)
              INTO l_cnt
              FROM tmp_work_ids, appeal
             WHERE x_id = ap_id;
        END IF;

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'В функцію перевірки наявності права не передано ідентифікаторів звернень!');
        END IF;

        UPDATE ap_service s
           SET s.aps_result =
                   CASE (SELECT NVL (
                                    SUM (
                                        CASE aprl.aprl_result
                                            WHEN 'F' THEN 1
                                            ELSE 0
                                        END),
                                    1)
                           FROM ap_right_log aprl
                          WHERE aprl.aprl_aps = s.aps_id)
                       WHEN 0
                       THEN
                           'T'
                       ELSE
                           'F'
                   END
         WHERE aps_ap IN (SELECT x_id FROM tmp_work_ids);
    END;

    --========================================
    PROCEDURE Calck_aps_result (p_aprl_id ap_right_log.aprl_id%TYPE)
    IS
        l_ap_id   appeal.ap_id%TYPE;
    BEGIN
        SELECT MAX (aps_ap)
          INTO l_ap_id
          FROM ap_right_log JOIN ap_service ON aps_id = aprl_aps
         WHERE aprl_id = p_aprl_id;

        IF l_ap_id IS NOT NULL
        THEN
            Calck_aps_result (1, l_ap_id);
        END IF;
    END;

    --========================================
    PROCEDURE init_right_for_appeals (p_mode    INTEGER, --1=з p_ap_id, 2=з таблиці tmp_work_ids
                                      p_ap_id   appeal.ap_id%TYPE /*,
                                         p_messages OUT SYS_REFCURSOR*/
                                                                 )
    IS
        l_messages   TOOLS.t_messages := TOOLS.t_messages ();
        l_cnt        INTEGER;
        l_hs         histsession.hs_id%TYPE;
        l_text       VARCHAR2 (4000);
    BEGIN
        l_messages.delete;

        IF p_mode = 1 AND p_ap_id IS NOT NULL
        THEN
            DELETE FROM tmp_work_ids
                  WHERE 1 = 1;

            INSERT INTO tmp_work_ids (x_id)
                SELECT ap_id
                  FROM appeal
                 WHERE ap_id = p_ap_id;

            l_cnt := SQL%ROWCOUNT;
        ELSE
            SELECT COUNT (*)
              INTO l_cnt
              FROM tmp_work_ids, appeal
             WHERE x_id = ap_id;
        END IF;

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'В функцію перевірки наявності права не передано ідентифікаторів звернень!');
        END IF;

        l_hs := TOOLS.GetHistSession;

        --Видаляємо ті правила перевірки права, яких немає в налаштуваннях для типу допомоги
        DELETE FROM ap_right_log aprl
              WHERE EXISTS
                        (SELECT 1
                           FROM tmp_work_ids
                                JOIN ap_service aps ON aps_id = x_id
                          WHERE aprl_aps = aps_id)/*AND NOT EXISTS (SELECT 1
                                                                  FROM uss_ndi.v_ndi_nrr_config, pc_decision, tmp_work_ids
                                                                  WHERE nruc_nst = pd_nst
                                                                    AND pd_id = x_id
                                                                    AND nruc_nrr = prl_nrr)*/
                                                  ;

        --Вставляємо всі правила по типу допомоги
        FOR xx
            IN (  SELECT nrr_id,
                         nrr_name,
                         nrr_alg,
                         aps_nst     AS y_nst,
                         aps_id      AS x_aps,
                         aps_ap      AS x_ap
                    FROM tmp_work_ids
                         JOIN ap_service s ON aps_ap = x_id
                         JOIN uss_ndi.v_ndi_nrr_config nnc
                             ON nruc_nst = aps_nst
                         JOIN uss_ndi.v_ndi_right_rule nrr ON nrr_id = nruc_nrr
                         LEFT JOIN ap_document ON apd_aps = aps_id
                   --WHERE api$check_right.Check_NRR(nnc.nruc_sql, s.aps_sum, s.aps_can_urgant, s.aps_is_inroom )= 1
                   WHERE api$check_right.Check_NRR (
                             nnc.nruc_sql,
                             (SELECT MAX (apda_val_string)
                                FROM ap_document_attr
                                     JOIN uss_ndi.v_ndi_document_attr
                                         ON nda_id = apda_nda AND nda_pt = 245
                               WHERE apda_apd = apd_id),
                             (SELECT MAX (apda_val_string)
                                FROM ap_document_attr
                                     JOIN uss_ndi.v_ndi_document_attr
                                         ON nda_id = apda_nda AND nda_pt = 245
                               WHERE apda_apd = apd_id),
                             (SELECT MAX (apda_val_string)
                                FROM ap_document_attr
                                     JOIN uss_ndi.v_ndi_document_attr
                                         ON nda_id = apda_nda AND nda_pt = 245
                               WHERE apda_apd = apd_id)) = 1
                --               (SELECT max(apda_val_string) FROM ap_document_attr WHERE apda_apd=apd_id AND apda_pt=245)
                ORDER BY nrr_order)
        LOOP
            DELETE FROM TMP_Errors_List
                  WHERE 1 = 1;

            CASE xx.nrr_alg
                WHEN 'G.ALG111'
                THEN
                    ALG111 (xx.x_ap, xx.x_aps, xx.nrr_id);
                WHEN 'G.ALG112'
                THEN
                    ALG112 (xx.x_ap, xx.x_aps, xx.nrr_id);
                WHEN 'G.ALG113'
                THEN
                    ALG113 (xx.x_ap, xx.x_aps, xx.nrr_id);
                WHEN 'G.ALG114'
                THEN
                    ALG114 (xx.x_ap, xx.x_aps, xx.nrr_id);
                WHEN 'G.ALG115'
                THEN
                    ALG115 (xx.x_ap, xx.x_aps, xx.nrr_id);
                WHEN 'G.ALG116'
                THEN
                    ALG116 (xx.x_ap, xx.x_aps, xx.nrr_id);
                WHEN 'G.ALG117'
                THEN
                    ALG117 (xx.x_ap, xx.x_aps, xx.nrr_id);
                WHEN 'G.ALG118'
                THEN
                    ALG118 (xx.x_ap, xx.x_aps, xx.nrr_id);
                WHEN 'G.ALG201'
                THEN
                    ALG201 (xx.x_ap, xx.x_aps, xx.nrr_id);
                WHEN 'G.ALG202'
                THEN
                    ALG202 (xx.x_ap, xx.x_aps, xx.nrr_id);
                WHEN 'G.ALG203'
                THEN
                    ALG203 (xx.x_ap, xx.x_aps, xx.nrr_id);
                WHEN 'G.ALG204'
                THEN
                    ALG204 (xx.x_ap, xx.x_aps, xx.nrr_id);
                WHEN 'G.ALG205'
                THEN
                    ALG205 (xx.x_ap, xx.x_aps, xx.nrr_id);
                WHEN 'G.ALG206'
                THEN
                    ALG206 (xx.x_ap, xx.x_aps, xx.nrr_id);
                ELSE
                    NULL;
            END CASE;


            l_cnt := SQL%ROWCOUNT;

            SELECT MAX (tel_text) INTO l_text FROM tmp_errors_list;

            IF l_text IS NOT NULL
            THEN
                TOOLS.add_message (
                    l_messages,
                    'W',
                       'За правилом "'
                    || xx.nrr_name
                    || '" не має права в зв''язку із тим, що: '
                    || l_text);
            END IF;
        END LOOP;

        Calck_aps_result (2, NULL);

        FOR xx IN (SELECT x_id FROM tmp_work_ids)
        LOOP
            API$CHECK_RIGHT.write_ap_log (xx.x_id,
                                          l_hs,
                                          'A',
                                          CHR (38) || '12',
                                          NULL);
        END LOOP;
    /*
    OPEN p_Messages FOR
     SELECT *
       FROM TABLE(l_Messages);
       */
    END;
END API$CHECK_RIGHT;
/