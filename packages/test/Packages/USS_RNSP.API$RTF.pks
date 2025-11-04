/* Formatted on 8/12/2025 5:57:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.API$RTF
IS
    -- Author  : LESHA
    -- Created : 30.03.2022 10:55:20
    -- Purpose :

    FUNCTION get_decision_approve_blob (p_ap_id IN NUMBER)
        RETURN BLOB;

    FUNCTION get_decision_return_blob (p_ap_id IN NUMBER)
        RETURN BLOB;

    FUNCTION get_decision_blob (p_ap_id IN NUMBER, p_apd_id IN NUMBER)
        RETURN BLOB;

    FUNCTION get_decision_blob_rnd (p_rnd_id IN NUMBER)
        RETURN BLOB;
END api$rtf;
/


/* Formatted on 8/12/2025 5:57:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RNSP.API$RTF
IS
    --===================================================================--
    FUNCTION get_template_by_code (p_code IN VARCHAR2)
        RETURN BLOB
    IS
        l_blob   BLOB;
    BEGIN
        SELECT rt_text
          INTO l_blob
          FROM v_rpt_templates
         WHERE rt_code = p_code
         FETCH FIRST 1 ROW ONLY;

        RETURN l_blob;
    END;

    --===================================================================--
    -- info:   заміна частини CLOB файлу на CLOB розміром більше 32K (>32767)
    -- params: in_source - текст в якому необхідно виконати заміну
    --         in_search - текст який необхідно замінити
    --         in_replace - текст на який необхідно замінити
    -- note:
    FUNCTION replace_clob (in_source    IN CLOB,
                           in_search    IN VARCHAR2,
                           in_replace   IN CLOB)
        RETURN CLOB
    IS
        l_pos   PLS_INTEGER;
    BEGIN
        l_pos := INSTR (in_source, in_search);

        IF l_pos > 0
        THEN
            RETURN    SUBSTR (in_source, 1, l_pos - 1)
                   || in_replace
                   || SUBSTR (in_source, l_pos + LENGTH (in_search));
        END IF;

        RETURN in_source;
    END replace_clob;

    --===================================================================--
    PROCEDURE add_main_info_to_decision (p_ap_id   IN     NUMBER,
                                         p_clob    IN     CLOB,
                                         v_clob       OUT CLOB)
    IS
        rnsp_decision   VARCHAR2 (250);
        fop_p           VARCHAR2 (250);
        fop_i           VARCHAR2 (250);
        fop_b           VARCHAR2 (250);
        agent_p         VARCHAR2 (250);
        agent_i         VARCHAR2 (250);
        agent_b         VARCHAR2 (250);
        received_p      VARCHAR2 (250);
        received_i      VARCHAR2 (250);
        received_b      VARCHAR2 (250);
        v_nsp_tp        VARCHAR2 (1);
        v_org_code      VARCHAR2 (10);
        v_org_name      VARCHAR2 (250);
        l_ap_st         VARCHAR2 (10);
        l_hs            NUMBER;
    BEGIN
        v_clob := p_clob;
        l_hs := tools.GetHistSessionA;

        SELECT ap_st
          INTO l_ap_st
          FROM appeal
         WHERE ap_id = p_ap_id;

        DNET$RNSP_JOURNALS.Write_LogA (p_Apl_Ap        => p_ap_id,
                                       p_Apl_Hs        => l_hs,
                                       p_Apl_St        => l_ap_st,
                                       p_Apl_Message   => 'Побудова рішення');

        api$document.get_useropfu (v_org_code, v_org_name);

        v_clob := replace_clob (v_clob, '#curr_org_name#', v_org_name);
        v_org_name := NULL;

        FOR data_rec IN (SELECT a.ap_num,
                                tda.apda_nda,
                                tda.apda_val_int,
                                tda.apda_val_dt,
                                tda.apda_val_string
                           FROM v_appeal  a
                                LEFT JOIN
                                (SELECT da.apda_nda,
                                        da.apda_val_int,
                                        da.apda_val_dt,
                                        da.apda_val_string
                                   FROM v_ap_document  d
                                        JOIN v_ap_document_attr da
                                            ON     da.apda_apd = d.apd_id
                                               AND da.apda_ap = p_ap_id
                                               AND da.history_status = 'A'
                                  WHERE     d.apd_ap = p_ap_id
                                        AND d.apd_ndt = 700
                                        AND d.history_status = 'A'
                                 UNION ALL
                                 SELECT rnda.rnda_nda,
                                        rnda.rnda_val_int,
                                        rnda.rnda_val_dt,
                                        rnda.rnda_val_string
                                   FROM v_rn_document  rnd
                                        JOIN v_rn_document_attr rnda
                                            ON     rnda.rnda_rnd = rnd.rnd_id
                                               AND rnda.history_status = 'A'
                                  WHERE     rnd.rnd_ap = p_ap_id
                                        AND rnd.rnd_ndt = 730
                                        AND rnd.history_status = 'A') tda
                                    ON 1 = 1
                          WHERE a.ap_id = p_ap_id)
        LOOP
            CASE data_rec.apda_nda
                WHEN 1112
                THEN
                    v_clob :=
                        replace_clob (v_clob, '#regnum#', data_rec.ap_num);
                    v_clob :=
                        replace_clob (v_clob,
                                      '#num#',
                                      TO_CHAR (data_rec.apda_val_int));
                WHEN 953
                THEN
                    v_nsp_tp := data_rec.apda_val_string;
                WHEN 956
                THEN
                    v_org_name := TRIM (data_rec.apda_val_string);
                WHEN 963
                THEN
                    fop_p := TRIM (data_rec.apda_val_string);
                WHEN 964
                THEN
                    fop_i := TRIM (data_rec.apda_val_string);
                WHEN 965
                THEN
                    fop_b := TRIM (data_rec.apda_val_string);
                WHEN 1113
                THEN
                    v_clob :=
                        replace_clob (
                            v_clob,
                            '#date#',
                            TO_CHAR (data_rec.apda_val_dt, 'DD.MM.YYYY'));
                WHEN 1114
                THEN
                    rnsp_decision := data_rec.apda_val_string;
                WHEN 1115
                THEN
                    v_clob :=
                        replace_clob (v_clob,
                                      '#rej_reasons#',
                                      TRIM (data_rec.apda_val_string));
                WHEN 1116
                THEN
                    v_clob :=
                        replace_clob (v_clob,
                                      '#agent.position#',
                                      TRIM (data_rec.apda_val_string));
                WHEN 1117
                THEN
                    agent_p := TRIM (data_rec.apda_val_string);
                WHEN 1118
                THEN
                    agent_i := TRIM (data_rec.apda_val_string);
                WHEN 1119
                THEN
                    agent_b := TRIM (data_rec.apda_val_string);
                WHEN 1120
                THEN
                    v_clob :=
                        replace_clob (
                            v_clob,
                            '#received.position#',
                               '____________________________________\par'
                            || '(посада керівника юридичної особи / фізична особа —\par'
                            || '____________________________________\par'
                            || ' підприємець / документ, що підтверджує повноваження\par'
                            || '____________________________________\par'
                            || ' уповноваженої особи)');
                WHEN 1121
                THEN
                    received_p := TRIM (data_rec.apda_val_string);
                WHEN 1122
                THEN
                    received_i := TRIM (data_rec.apda_val_string);
                WHEN 1123
                THEN
                    received_b := TRIM (data_rec.apda_val_string);
                WHEN 1133
                THEN
                    v_clob :=
                        replace_clob (v_clob, '#received.document#', '');
                ELSE
                    NULL;
            END CASE;
        END LOOP;

        IF rnsp_decision = 'V'
        THEN
            v_clob :=
                replace_clob (
                    v_clob,
                    '#T#',
                    '{\rtlch\fcs1 \af0 \ltrch\fcs0 \lang1033\langfe1033\langnp1033\insrsid16478594 {\field{\*\fldinst SYMBOL 80 \\f "Wingdings 2" \\s 11}{\fldrslt\f157\fs22}}}');
            v_clob :=
                replace_clob (
                    v_clob,
                    '#nametrue#',
                    (CASE v_nsp_tp
                         WHEN 'O' THEN v_org_name
                         WHEN 'F' THEN fop_p || ' ' || fop_i || ' ' || fop_b
                     END));
            v_clob := replace_clob (v_clob, '#F#', '');
            v_clob := replace_clob (v_clob, '#namefalse#', '');
        ELSIF rnsp_decision = 'P'
        THEN
            v_clob := replace_clob (v_clob, '#T#', '');
            v_clob := replace_clob (v_clob, '#nametrue#', '');
            v_clob :=
                replace_clob (
                    v_clob,
                    '#F#',
                    '{\rtlch\fcs1 \af0 \ltrch\fcs0 \lang1033\langfe1033\langnp1033\insrsid16478594 {\field{\*\fldinst SYMBOL 80 \\f "Wingdings 2" \\s 11}{\fldrslt\f157\fs22}}}');
            v_clob :=
                replace_clob (
                    v_clob,
                    '#namefalse#',
                    (CASE v_nsp_tp
                         WHEN 'O'
                         THEN
                             v_org_name
                         WHEN 'F'
                         THEN
                             TRIM (
                                 LTRIM (
                                        fop_p
                                     || ' '
                                     || LTRIM (fop_i || ' ' || fop_b)))
                     END));
        ELSE
            v_clob := replace_clob (v_clob, '#T#', '');
            v_clob := replace_clob (v_clob, '#nametrue#', '');
            v_clob := replace_clob (v_clob, '#F#', '');
            v_clob := replace_clob (v_clob, '#namefalse#', '');
        /*
              v_clob := REPLACE(v_clob, '#T#');
              v_clob := REPLACE(v_clob, '#nametrue#');
              v_clob := REPLACE(v_clob, '#F#');
              v_clob := REPLACE(v_clob, '#namefalse#');
        */
        END IF;

        v_clob :=
            replace_clob (
                v_clob,
                '#applicantname#',
                (CASE v_nsp_tp
                     WHEN 'O'
                     THEN
                         v_org_name
                     WHEN 'F'
                     THEN
                         TRIM (
                             LTRIM (
                                    fop_p
                                 || ' '
                                 || LTRIM (fop_i || ' ' || fop_b)))
                 END));
        v_clob :=
            replace_clob (
                v_clob,
                '#agent.pib#',
                TRIM (
                    LTRIM (
                        agent_p || ' ' || LTRIM (agent_i || ' ' || agent_b))));
        v_clob :=
            replace_clob (
                v_clob,
                '#received.pib#',
                   '__________________\par'
                || '(прізвище, ім’я, по батькові\par'
                || '(за наявності)');
        v_clob :=
            replace_clob (v_clob,
                          '#received.date#',
                          '___ ____________ 20__ р.');
        v_clob :=
            replace_clob (
                v_clob,
                '#received.position#',
                   '____________________________________\par'
                || '(посада керівника юридичної особи / фізична особа —\par'
                || '____________________________________\par'
                || ' підприємець / документ, що підтверджує повноваження\par'
                || '____________________________________\par'
                || ' уповноваженої особи)');
        v_clob := replace_clob (v_clob, '#received.document#', '');
    EXCEPTION
        WHEN OTHERS
        THEN
            DNET$RNSP_JOURNALS.Write_LogA (
                p_Apl_Ap   => p_ap_id,
                p_Apl_Hs   => l_hs,
                p_Apl_St   => l_ap_st,
                p_Apl_Message   =>
                    'Помилка побудови рішення' || CHR (10) || SQLERRM);

            RAISE;
    END;

    --===================================================================--
    FUNCTION add_rnd_to_decision (p_rnd_id IN NUMBER, p_clob IN CLOB)
        RETURN CLOB
    IS
        v_clob          CLOB := p_clob;
        rnsp_decision   VARCHAR2 (250);
        fop_p           VARCHAR2 (250);
        fop_i           VARCHAR2 (250);
        fop_b           VARCHAR2 (250);
        agent_p         VARCHAR2 (250);
        agent_i         VARCHAR2 (250);
        agent_b         VARCHAR2 (250);
        received_p      VARCHAR2 (250);
        received_i      VARCHAR2 (250);
        received_b      VARCHAR2 (250);
        v_nsp_tp        VARCHAR2 (1);
        v_org_code      VARCHAR2 (10);
        v_org_name      VARCHAR2 (250);
    BEGIN
        api$document.get_useropfu (v_org_code, v_org_name);

        v_clob := replace_clob (v_clob, '#curr_org_name#', v_org_name);
        v_org_name := NULL;

        FOR data_rec
            IN (SELECT NULL     AS ap_num,
                       rnda.rnda_nda,
                       rnda.rnda_val_int,
                       rnda.rnda_val_dt,
                       rnda.rnda_val_string
                  FROM v_rn_document  rnd
                       LEFT JOIN v_rn_document_attr rnda
                           ON     rnda.rnda_rnd = rnd.rnd_id
                              AND rnda.history_status = 'A'
                 WHERE rnd.rnd_id = p_rnd_id)
        LOOP
            CASE data_rec.rnda_nda
                WHEN 1112
                THEN
                    v_clob :=
                        replace_clob (v_clob, '#regnum#', data_rec.ap_num);
                    v_clob :=
                        replace_clob (v_clob,
                                      '#num#',
                                      TO_CHAR (data_rec.rnda_val_int));
                WHEN 953
                THEN
                    v_nsp_tp := data_rec.rnda_val_string;
                WHEN 956
                THEN
                    v_org_name := TRIM (data_rec.rnda_val_string);
                WHEN 963
                THEN
                    fop_p := TRIM (data_rec.rnda_val_string);
                WHEN 964
                THEN
                    fop_i := TRIM (data_rec.rnda_val_string);
                WHEN 965
                THEN
                    fop_b := TRIM (data_rec.rnda_val_string);
                WHEN 1113
                THEN
                    v_clob :=
                        replace_clob (
                            v_clob,
                            '#date#',
                            TO_CHAR (data_rec.rnda_val_dt, 'DD.MM.YYYY'));
                WHEN 1114
                THEN
                    rnsp_decision := data_rec.rnda_val_string;
                WHEN 1115
                THEN
                    v_clob :=
                        replace_clob (v_clob,
                                      '#rej_reasons#',
                                      TRIM (data_rec.rnda_val_string));
                WHEN 1116
                THEN
                    v_clob :=
                        replace_clob (v_clob,
                                      '#agent.position#',
                                      TRIM (data_rec.rnda_val_string));
                WHEN 1117
                THEN
                    agent_p := TRIM (data_rec.rnda_val_string);
                WHEN 1118
                THEN
                    agent_i := TRIM (data_rec.rnda_val_string);
                WHEN 1119
                THEN
                    agent_b := TRIM (data_rec.rnda_val_string);
                WHEN 1120
                THEN
                    v_clob :=
                        replace_clob (
                            v_clob,
                            '#received.position#',
                               '____________________________________\par'
                            || '(посада керівника юридичної особи / фізична особа —\par'
                            || '____________________________________\par'
                            || ' підприємець / документ, що підтверджує повноваження\par'
                            || '____________________________________\par'
                            || ' уповноваженої особи)');
                WHEN 1121
                THEN
                    received_p := TRIM (data_rec.rnda_val_string);
                WHEN 1122
                THEN
                    received_i := TRIM (data_rec.rnda_val_string);
                WHEN 1123
                THEN
                    received_b := TRIM (data_rec.rnda_val_string);
                WHEN 1133
                THEN
                    v_clob :=
                        replace_clob (v_clob, '#received.document#', '');
                ELSE
                    NULL;
            END CASE;
        END LOOP;

        IF rnsp_decision = 'V'
        THEN
            v_clob :=
                replace_clob (
                    v_clob,
                    '#T#',
                    '{\rtlch\fcs1 \af0 \ltrch\fcs0 \lang1033\langfe1033\langnp1033\insrsid16478594 {\field{\*\fldinst SYMBOL 80 \\f "Wingdings 2" \\s 11}{\fldrslt\f157\fs22}}}');
            v_clob :=
                replace_clob (
                    v_clob,
                    '#nametrue#',
                    (CASE v_nsp_tp
                         WHEN 'O' THEN v_org_name
                         WHEN 'F' THEN fop_p || ' ' || fop_i || ' ' || fop_b
                     END));
            v_clob := replace_clob (v_clob, '#F#', '');
            v_clob := replace_clob (v_clob, '#namefalse#', '');
        ELSIF rnsp_decision = 'P'
        THEN
            v_clob := replace_clob (v_clob, '#T#', '');
            v_clob := replace_clob (v_clob, '#nametrue#', '');
            v_clob :=
                replace_clob (
                    v_clob,
                    '#F#',
                    '{\rtlch\fcs1 \af0 \ltrch\fcs0 \lang1033\langfe1033\langnp1033\insrsid16478594 {\field{\*\fldinst SYMBOL 80 \\f "Wingdings 2" \\s 11}{\fldrslt\f157\fs22}}}');
            v_clob :=
                replace_clob (
                    v_clob,
                    '#namefalse#',
                    (CASE v_nsp_tp
                         WHEN 'O'
                         THEN
                             v_org_name
                         WHEN 'F'
                         THEN
                             TRIM (
                                 LTRIM (
                                        fop_p
                                     || ' '
                                     || LTRIM (fop_i || ' ' || fop_b)))
                     END));
        ELSE
            v_clob := REPLACE (v_clob, '#T#');
            v_clob := REPLACE (v_clob, '#nametrue#');
            v_clob := REPLACE (v_clob, '#F#');
            v_clob := REPLACE (v_clob, '#namefalse#');
        END IF;

        v_clob :=
            replace_clob (
                v_clob,
                '#applicantname#',
                (CASE v_nsp_tp
                     WHEN 'O'
                     THEN
                         v_org_name
                     WHEN 'F'
                     THEN
                         TRIM (
                             LTRIM (
                                    fop_p
                                 || ' '
                                 || LTRIM (fop_i || ' ' || fop_b)))
                 END));
        v_clob :=
            replace_clob (
                v_clob,
                '#agent.pib#',
                TRIM (
                    LTRIM (
                        agent_p || ' ' || LTRIM (agent_i || ' ' || agent_b))));
        v_clob :=
            replace_clob (
                v_clob,
                '#received.pib#',
                   '__________________\par'
                || '(прізвище, ім’я, по батькові\par'
                || '(за наявності)');
        v_clob :=
            replace_clob (v_clob,
                          '#received.date#',
                          '___ ____________ 20__ р.');
        v_clob :=
            replace_clob (
                v_clob,
                '#received.position#',
                   '____________________________________\par'
                || '(посада керівника юридичної особи / фізична особа —\par'
                || '____________________________________\par'
                || ' підприємець / документ, що підтверджує повноваження\par'
                || '____________________________________\par'
                || ' уповноваженої особи)');
        v_clob := replace_clob (v_clob, '#received.document#', '');

        RETURN v_clob;
    END;

    --===================================================================--

    FUNCTION get_decision_approve_blob (p_ap_id IN NUMBER)
        RETURN BLOB
    IS
        v_clob       CLOB;
        v_out_clob   CLOB;
    BEGIN
        v_clob :=
            tools.convertb2c (get_template_by_code ('DECISION_APPROVE'));
        add_main_info_to_decision (p_ap_id, v_clob, v_out_clob);

        IF DBMS_LOB.getlength (v_out_clob) = 0
        THEN
            Raise_Application_Error (-20001,
                                     'Не сформовано друковану форму!');
        END IF;

        RETURN tools.convertc2b (v_out_clob);
    END;

    FUNCTION get_decision_return_blob (p_ap_id IN NUMBER)
        RETURN BLOB
    IS
        v_clob       CLOB;
        v_out_clob   CLOB;
    BEGIN
        v_clob := tools.convertb2c (get_template_by_code ('DECISION_RETURN'));
        add_main_info_to_decision (p_ap_id, v_clob, v_out_clob);

        IF DBMS_LOB.getlength (v_out_clob) = 0
        THEN
            Raise_Application_Error (-20001,
                                     'Не сформовано друковану форму!');
        END IF;

        RETURN tools.convertc2b (v_out_clob);
    END;

    FUNCTION get_decision_blob (p_ap_id IN NUMBER, p_apd_id IN NUMBER)
        RETURN BLOB
    IS
        v_clob       CLOB;
        v_out_clob   CLOB;
    BEGIN
        v_clob := tools.convertb2c (get_template_by_code ('DECISION'));
        add_main_info_to_decision (p_ap_id, v_clob, v_out_clob);

        IF DBMS_LOB.getlength (v_out_clob) = 0
        THEN
            Raise_Application_Error (-20001,
                                     'Не сформовано друковану форму!');
        END IF;

        RETURN tools.convertc2b (v_out_clob);
    END;

    --===================================================================--
    FUNCTION get_decision_blob_rnd (p_rnd_id IN NUMBER)
        RETURN BLOB
    IS
        v_clob   CLOB;
    BEGIN
        v_clob := tools.convertb2c (get_template_by_code ('DECISION_RETURN'));
        v_clob := add_rnd_to_decision (p_rnd_id, v_clob);

        RETURN tools.convertc2b (v_clob);
    END;
--===================================================================--
END api$rtf;
/