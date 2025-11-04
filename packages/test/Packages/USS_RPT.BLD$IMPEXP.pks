/* Formatted on 8/12/2025 5:58:56 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RPT.BLD$IMPEXP
IS
    -- Author  : VANO
    -- Created : 11.03.2019 16:18:35
    -- Purpose : Допоміжні функції для формування оновлень даних в версіях

    TYPE array_t IS TABLE OF VARCHAR2 (10);

    tbs   DBMS_STANDARD.ora_name_list_t;

    PROCEDURE make_inserts (p_owner        VARCHAR2,
                            p_table_name   VARCHAR2,
                            p_where        VARCHAR2);

    PROCEDURE make_synonyms_script;

    PROCEDURE make_data_script (p_owner VARCHAR2, p_type VARCHAR2);

    PROCEDURE make_rtfl_script (p_owner VARCHAR2, p_ids_by_comma VARCHAR2);

    PROCEDURE make_exp_dict_cmd;

    PROCEDURE make_exp_dict_sql;

    PROCEDURE make_load_dict_sql;

    PROCEDURE prepare_pkg_script (p_owner VARCHAR2, p_pkg_by_comma VARCHAR2);

    PROCEDURE prepare_rpt_script (p_owner              VARCHAR2,
                                  p_rpt_ids_by_comma   VARCHAR2);

    PROCEDURE prepare_rpt_script_By_id (p_owner        VARCHAR2,
                                        p_rpt_id       NUMBER,
                                        res_cur    OUT SYS_REFCURSOR);

    --  PROCEDURE import_reports;

    PROCEDURE make_package_export_cmd;
END BLD$IMPEXP;
/


/* Formatted on 8/12/2025 5:58:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RPT.BLD$IMPEXP
IS
    PROCEDURE WL (p_msg VARCHAR)
    IS
    BEGIN
        DBMS_OUTPUT.put_line (p_msg);
    END;

    FUNCTION get_fields_list (p_owner VARCHAR2, p_table_name VARCHAR2)
        RETURN VARCHAR2
    IS
        l_list    VARCHAR2 (4000);
        l_first   INTEGER := 1;
    BEGIN
        FOR xx
            IN (  SELECT column_name
                    FROM all_tab_cols
                   WHERE     table_name = UPPER (p_table_name)
                         AND owner = UPPER (p_owner)
                         AND hidden_column = 'NO'
                ORDER BY column_id)
        LOOP
            l_list :=
                   l_list
                || CASE WHEN l_first = 1 THEN '' ELSE ', ' END
                || LOWER (xx.column_name);

            IF l_first = 1
            THEN
                l_first := 2;
            END IF;
        END LOOP;

        RETURN l_list;
    END;

    FUNCTION get_insert_template (p_owner VARCHAR2, p_table_name VARCHAR2)
        RETURN VARCHAR2
    IS
        l_ins_header   VARCHAR2 (4000);
    BEGIN
        l_ins_header :=
               'INSERT INTO '
            || LOWER (p_owner)
            || '.'
            || LOWER (p_table_name)
            || ' (';
        l_ins_header :=
            l_ins_header || get_fields_list (p_owner, p_table_name);
        l_ins_header := l_ins_header || ')' ||          /*CHR(13)||CHR(10)||*/
                                               '  VALUES (#VAL#);' /*||CHR(13)||CHR(10)*/
                                                                  ;

        RETURN l_ins_header;
    END;

    FUNCTION get_select_template (p_owner        VARCHAR2,
                                  p_table_name   VARCHAR2,
                                  p_where        VARCHAR2)
        RETURN VARCHAR2
    IS
        l_select_sql   VARCHAR2 (4000);
    BEGIN
        l_select_sql := 'SELECT ';
        l_select_sql :=
            l_select_sql || get_fields_list (p_owner, p_table_name);
        l_select_sql :=
               l_select_sql
            || CHR (13)
            || CHR (10)
            || 'FROM '
            || LOWER (p_owner)
            || '.'
            || LOWER (p_table_name)
            || ' '
            || p_where;

        RETURN l_select_sql;
    END;

    FUNCTION get_field_data (p_cursor    NUMBER,
                             p_num       INTEGER,
                             p_rec_tab   DBMS_SQL.desc_tab)
        RETURN VARCHAR2
    IS
        l_str      VARCHAR2 (4000);
        l_dt       DATE;
        l_number   NUMBER;
    BEGIN
        IF p_rec_tab (p_num).col_type <> DBMS_TYPES.TYPECODE_DATE
        THEN
            DBMS_SQL.COLUMN_VALUE (p_cursor, p_num, l_str);

            IF l_str IS NULL
            THEN
                l_str := 'NULL';
            ELSE
                IF p_rec_tab (p_num).col_type IN
                       (DBMS_TYPES.TYPECODE_VARCHAR,
                        DBMS_TYPES.TYPECODE_VARCHAR2)
                THEN
                    l_str := REPLACE (l_str, '''', '''''');
                END IF;

                IF p_rec_tab (p_num).col_type <> DBMS_TYPES.TYPECODE_NUMBER
                THEN
                    l_str := '''' || l_str || '''';
                ELSE
                    l_str := REPLACE (l_str, ',', '.');
                END IF;
            END IF;
        ELSE
            DBMS_SQL.COLUMN_VALUE (p_cursor, p_num, l_dt);

            IF l_dt IS NULL
            THEN
                l_str := 'NULL';
            ELSE
                l_str :=
                       'to_date('''
                    || TO_CHAR (l_dt, 'DD.MM.YYYY')
                    || ''', ''DD.MM.YYYY'')';
            END IF;
        END IF;

        RETURN l_str;
    END;

    PROCEDURE make_inserts (p_owner        VARCHAR2,
                            p_table_name   VARCHAR2,
                            p_where        VARCHAR2)
    IS
        l_select_sql        VARCHAR2 (4000);
        l_insert_template   VARCHAR2 (4000);

        c                   NUMBER;
        d                   NUMBER;
        col_cnt             PLS_INTEGER;
        rec_tab             DBMS_SQL.desc_tab;

        l_cnt               INTEGER;

        l_data_str          VARCHAR2 (4000);
        l_data_dt           DATE;
        l_rows              INTEGER;
        l_field_data        VARCHAR2 (4000);
        l_data_row          VARCHAR2 (4000);
        l_f                 INTEGER;
        l_insert            VARCHAR2 (4000);
        l_rows_cnt          INTEGER := 0;
    BEGIN
        DBMS_OUTPUT.enable (NULL);
        l_insert_template := get_insert_template (p_owner, p_table_name);
        l_select_sql := get_select_template (p_owner, p_table_name, p_where);

        c := DBMS_SQL.open_cursor;
        DBMS_SQL.parse (c, l_select_sql, DBMS_SQL.NATIVE);
        DBMS_SQL.describe_columns (c, col_cnt, rec_tab);

        l_cnt := rec_tab.COUNT;

        FOR l_iter IN 1 .. l_cnt
        LOOP
            --dbms_sql.define_column(c, l_iter, l_data_str, rec_tab(l_iter).col_max_len);
            CASE
                WHEN rec_tab (l_iter).col_type = DBMS_TYPES.TYPECODE_DATE
                THEN
                    DBMS_SQL.define_column (c, l_iter, l_data_dt);
                ELSE
                    DBMS_SQL.define_column (c,
                                            l_iter,
                                            l_data_str,
                                            4000);
            END CASE;
        END LOOP;

        d := DBMS_SQL.execute (c);

        LOOP
            l_rows := DBMS_SQL.fetch_rows (c);
            EXIT WHEN l_rows = 0;

            l_f := 1;
            l_data_row := '';

            FOR l_iter IN 1 .. l_cnt
            LOOP
                l_field_data := get_field_data (c, l_iter, rec_tab);
                l_data_row :=
                       l_data_row
                    || CASE WHEN l_f = 1 THEN '' ELSE ', ' END
                    || l_field_data;

                IF l_f = 1
                THEN
                    l_f := 2;
                END IF;
            END LOOP;

            l_insert := REPLACE (l_insert_template, '#VAL#', l_data_row);
            WL (l_insert);
            l_rows_cnt := l_rows_cnt + 1;
        END LOOP;

        WL ('prompt ' || l_rows_cnt || ' records loaded');
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'l_select_sql=' || l_select_sql || ':' || SQLERRM);
    END;

    PROCEDURE make_synonyms_script
    IS
    BEGIN
        /*FOR xx IN (select 'create or replace synonym &PROXY_USR..'||z.rat_object_name||' FOR &PREFIX..'||z.rat_object_name||';' AS z_synonum_create
                   from ikis_rsrc_attr z
                   where rat_rsrc = 'RC_IKIS_MTACC_WEB')
        LOOP
          WL(xx.z_synonum_create);
        END LOOP;*/
        NULL;
    END;

    PROCEDURE make_data_script (p_owner VARCHAR2, p_type VARCHAR2)
    IS
    BEGIN
        FOR xx
            IN (SELECT    'ALTER TABLE &PREFIX..'
                       || table_name
                       || ' DISABLE CONSTRAINT '
                       || constraint_name
                       || ';'    AS sql_disable,
                          'ALTER TABLE &PREFIX..'
                       || table_name
                       || ' ENABLE CONSTRAINT '
                       || constraint_name
                       || ';'    AS sql_enable
                  FROM all_constraints
                 WHERE constraint_type = 'R' AND r_owner = UPPER (p_owner))
        LOOP
            WL (
                CASE
                    WHEN UPPER (p_type) = 'BEFORE' THEN xx.sql_disable
                    WHEN UPPER (p_type) = 'AFTER' THEN xx.sql_enable
                END);
        END LOOP;
    END;

    PROCEDURE make_rtfl_script (p_owner VARCHAR2, p_ids_by_comma VARCHAR2)
    IS
    BEGIN
        WL ('load data');
        WL ('infile *');
        WL ('replace');
        WL ('into table ' || p_owner || '.tmp$rpt_templates');
        WL ('fields terminated by ''|''');
        WL ('(');
        WL ('  RT_ID,');
        WL ('  RT_SS_CODE,');
        WL ('  RT_TP,');
        WL ('  RT_CODE,');
        WL ('  RT_FILE_TP,');
        WL ('  RT_NAME,');
        WL ('  RT_DOC_TP,');
        WL ('  RT_FILENAME,');
        WL ('  RT_RFILENAME,');
        WL ('  RT_TEXT lobfile(RT_RFILENAME) terminated by eof');
        WL (')');
        WL ('begindata');
    /*FOR xx IN (SELECT rt_id||'|'||rt_ss_code||'|'||'R'||'|'||rt_code||'|'||rt_file_tp||'|'||rt_name||'|'||rt_doc_tp||'|'||rt_code||'.'||rt_file_tp||'|rt_text_'||rt_id||'.dat|'||'rt_text_'||rt_id||'.dat|' AS x_row
               FROM rpt_templates
               WHERE rt_id IN (SELECT regexp_substr(p_ids_by_comma, '[^,]+', 1, level)
                               FROM dual
                               CONNECT BY regexp_substr(p_ids_by_comma, '[^,]+', 1, level) IS NOT NULL))
    LOOP
      WL(xx.x_row);
    END LOOP;*/

    END;

    PROCEDURE make_exp_dict_cmd
    IS
    BEGIN
        WL ('chcp 1251');
        WL ('mkdir exp_tab_data');
        WL ('sqlplus uss_rpt/uss_rpt@sonya @exp_dict_and_config.sql');
    END;

    PROCEDURE make_exp_dict_sql
    IS
    BEGIN
        WL ('SET HEADING OFF');
        WL ('SET PAGESIZE 0');
        WL ('SET LONG 90000');
        WL ('SET linesize 7000');
        WL ('SET FEEDBACK OFF');
        WL ('SET ECHO OFF');
        WL ('SET TRIMSPOOL ON');
        WL ('SET TIMING OFF');
        WL ('set serveroutput on');

        FOR i IN 1 .. tbs.COUNT
        LOOP
            WL ('SPOOL exp_tab_data\tb_' || tbs (i) || '.sql');
            WL ('');
            WL ('BEGIN');
            WL (
                   '  IKIS_MTACC.BLD$IMPEXP.make_inserts(''ikis_mtacc'', '''
                || tbs (i)
                || ''', '' where 1 = 1'');');
            WL ('END;');
            WL ('/');
            WL (' ');
            WL ('SPOOL OFF;');
            WL (' ');
            WL (' ');
        END LOOP;

        WL ('QUIT;');
    END;

    PROCEDURE make_load_dict_sql
    IS
    BEGIN
        WL ('SET FEEDBACK OFF');
        WL ('SET DEFINE OFF');

        FOR i IN 1 .. tbs.COUNT
        LOOP
            WL (
                   'prompt Disabling foreign key constraints for '
                || UPPER (tbs (i))
                || '...');

            FOR zz
                IN (SELECT    'ALTER TABLE IKIS_MTACC.'
                           || table_name
                           || ' DISABLE CONSTRAINT '
                           || constraint_name
                           || ';'    AS sql_disable
                      FROM user_constraints
                     WHERE     constraint_type = 'R'
                           AND r_owner = 'IKIS_MTACC'
                           AND r_constraint_name = 'XPK_' || UPPER (tbs (i)))
            LOOP
                WL (zz.sql_disable);
            END LOOP;

            WL (' ');
        END LOOP;

        FOR i IN 1 .. tbs.COUNT
        LOOP
            WL ('prompt Deleting ' || UPPER (tbs (i)) || '...');
            WL (
                   'DELETE FROM IKIS_MTACC.'
                || LOWER (tbs (i))
                || ' WHERE 1 = 1;');
            WL ('');
        END LOOP;

        FOR i IN 1 .. tbs.COUNT
        LOOP
            WL ('prompt Loading ' || UPPER (tbs (i)) || '...');
            WL ('@exp_tab_data\tb_' || tbs (i) || '.sql');
            WL ('');
        END LOOP;

        FOR i IN 1 .. tbs.COUNT
        LOOP
            WL (
                   'prompt Enabling foreign key constraints for '
                || UPPER (tbs (i))
                || '...');

            FOR zz
                IN (SELECT    'ALTER TABLE IKIS_MTACC.'
                           || table_name
                           || ' ENABLE CONSTRAINT '
                           || constraint_name
                           || ';'    AS sql_enable
                      FROM user_constraints
                     WHERE     constraint_type = 'R'
                           AND r_owner = 'IKIS_MTACC'
                           AND r_constraint_name = 'XPK_' || UPPER (tbs (i)))
            LOOP
                WL (zz.sql_enable);
            END LOOP;

            WL (' ');
        END LOOP;

        WL ('SET FEEDBACK ON');
        WL ('SET DEFINE ON');
        WL ('PROMPT Done.');
    END;

    PROCEDURE prepare_pkg_script (p_owner VARCHAR2, p_pkg_by_comma VARCHAR2)
    IS
        l_tmp_header   CLOB;
        l_tmp_body     CLOB;
        l_headers      CLOB;
        l_bodies       CLOB;
        l_result       CLOB;
        l_num          INTEGER;
    BEGIN
        WL ('Формую скрипт перестворення пакетів за списком');
        DBMS_LOB.createTemporary (l_headers, TRUE);
        DBMS_LOB.OPEN (l_headers, DBMS_LOB.LOB_ReadWrite);
        DBMS_LOB.createTemporary (l_bodies, TRUE);
        DBMS_LOB.OPEN (l_bodies, DBMS_LOB.LOB_ReadWrite);
        DBMS_LOB.createTemporary (l_result, TRUE);
        DBMS_LOB.OPEN (l_result, DBMS_LOB.LOB_ReadWrite);

        FOR xx IN (SELECT DISTINCT TRIM (UPPER (x_data))     AS x_row
                     FROM (    SELECT REGEXP_SUBSTR (p_pkg_by_comma,
                                                     '[^,]+',
                                                     1,
                                                     LEVEL)    AS x_data
                                 FROM DUAL
                           CONNECT BY REGEXP_SUBSTR (p_pkg_by_comma,
                                                     '[^,]+',
                                                     1,
                                                     LEVEL)
                                          IS NOT NULL)
                    WHERE TRIM (UPPER (x_data)) IS NOT NULL)
        LOOP
            WL ('Обробляю пакет ' || xx.x_row || '...');
            l_num := 1;
            DBMS_LOB.createTemporary (l_tmp_header, TRUE);
            DBMS_LOB.OPEN (l_tmp_header, DBMS_LOB.LOB_ReadWrite);
            DBMS_LOB.append (l_tmp_header, 'prompt' || CHR (13) || CHR (10));
            DBMS_LOB.append (
                l_tmp_header,
                   'prompt Creating package spec '
                || xx.x_row
                || CHR (13)
                || CHR (10));
            DBMS_LOB.append (
                l_tmp_header,
                   'prompt ==================================='
                || CHR (13)
                || CHR (10));
            DBMS_LOB.append (l_tmp_header, 'prompt' || CHR (13) || CHR (10));

            FOR yy IN (  SELECT text, line
                           FROM user_source
                          WHERE TYPE = 'PACKAGE' AND name = xx.x_row
                       ORDER BY line)
            LOOP
                DBMS_LOB.append (
                    l_tmp_header,
                    CASE
                        WHEN yy.line = 1
                        THEN
                               'CREATE OR REPLACE '
                            || REPLACE (UPPER (yy.text),
                                        'PACKAGE ',
                                        'PACKAGE ' || LOWER (p_owner) || '.')
                        ELSE
                            yy.text
                    END);
            END LOOP;

            l_num := 1;
            DBMS_LOB.createTemporary (l_tmp_body, TRUE);
            DBMS_LOB.OPEN (l_tmp_body, DBMS_LOB.LOB_ReadWrite);
            DBMS_LOB.append (l_tmp_body, 'prompt' || CHR (13) || CHR (10));
            DBMS_LOB.append (
                l_tmp_body,
                   'prompt Creating package body '
                || xx.x_row
                || CHR (13)
                || CHR (10));
            DBMS_LOB.append (
                l_tmp_body,
                   'prompt ==================================='
                || CHR (13)
                || CHR (10));
            DBMS_LOB.append (l_tmp_body, 'prompt' || CHR (13) || CHR (10));

            DBMS_LOB.append (
                l_tmp_body,
                   'Prompt Processing: PACKAGE BODY: '
                || xx.x_row
                || CHR (13)
                || CHR (10));

            FOR yy IN (  SELECT text, line
                           FROM user_source
                          WHERE TYPE = 'PACKAGE BODY' AND name = xx.x_row
                       ORDER BY line)
            LOOP
                DBMS_LOB.append (
                    l_tmp_body,
                    CASE
                        WHEN yy.line = 1
                        THEN
                               'CREATE OR REPLACE '
                            || REPLACE (
                                   UPPER (yy.text),
                                   'PACKAGE BODY ',
                                   'PACKAGE BODY ' || LOWER (p_owner) || '.')
                        ELSE
                            yy.text
                    END);
            END LOOP;

            DBMS_LOB.append (l_headers, l_tmp_header);
            DBMS_LOB.append (
                l_headers,
                   CHR (13)
                || CHR (10)
                || '/'
                || CHR (13)
                || CHR (10)
                || CHR (13)
                || CHR (10));

            DBMS_LOB.append (l_bodies, l_tmp_body);
            DBMS_LOB.append (
                l_bodies,
                   CHR (13)
                || CHR (10)
                || '/'
                || CHR (13)
                || CHR (10)
                || CHR (13)
                || CHR (10));
        END LOOP;

        DBMS_LOB.append (
            l_result,
               'prompt NVP Medirent (pavlukov) Export User Objects for user '
            || p_owner
            || '@'
            || SYS_CONTEXT ('USERENV', 'INSTANCE_NAME')
            || CHR (13)
            || CHR (10));
        DBMS_LOB.append (
            l_result,
               'prompt prompt Created by '
            || SYS_CONTEXT ('userenv', 'os_user')
            || ' on '
            || TO_CHAR (SYSDATE, 'DD.MM.YYYY HH24:MI:SS')
            || CHR (13)
            || CHR (10));
        DBMS_LOB.append (
            l_result,
            'set define off' || CHR (13) || CHR (10) || CHR (13) || CHR (10));

        DBMS_LOB.append (l_result, l_headers);
        DBMS_LOB.append (l_result, l_bodies);

        DBMS_LOB.append (l_result, CHR (13) || CHR (10));
        DBMS_LOB.append (l_result, CHR (13) || CHR (10));
        DBMS_LOB.append (l_result, 'prompt Done' || CHR (13) || CHR (10));
        DBMS_LOB.append (l_result, 'set define on' || CHR (13) || CHR (10));

        DELETE FROM tmp_lob
              WHERE x_id = 777;

        INSERT INTO tmp_lob (x_id, x_clob)
             VALUES (777, l_result);

        COMMIT;
        WL ('Скрипт зформовано!');
    END;

    PROCEDURE prepare_rpt_script (p_owner              VARCHAR2,
                                  p_rpt_ids_by_comma   VARCHAR2)
    IS
        x_list    VARCHAR2 (4000) := p_rpt_ids_by_comma;
        x_owner   VARCHAR2 (4000) := p_owner;
    BEGIN
        FOR xx IN (SELECT rt_id     AS x_id
                     FROM uss_ndi.v_ndi_report_type
                    WHERE rt_id IN (    SELECT REGEXP_SUBSTR (x_list,
                                                              '[^,]+',
                                                              1,
                                                              LEVEL)
                                          FROM DUAL
                                    CONNECT BY REGEXP_SUBSTR (x_list,
                                                              '[^,]+',
                                                              1,
                                                              LEVEL)
                                                   IS NOT NULL))
        LOOP
            DELETE FROM tmp_lob
                  WHERE x_id = xx.x_id;

            INSERT INTO tmp_lob (x_id, x_clob)
                SELECT xx.x_id,
                       XMLROOT (
                           XMLELEMENT (
                               "report",
                               (SELECT XMLELEMENT (
                                           "ndi_report_type",
                                           XMLELEMENT ("rt_id", rt_id),
                                           XMLELEMENT ("rt_code", rt_code),
                                           XMLELEMENT ("rt_name", rt_name),
                                           XMLELEMENT ("rt_nrg", rt_nrg),
                                           XMLELEMENT ("rt_desc", rt_desc))
                                  FROM uss_ndi.v_ndi_report_type
                                 WHERE rt_id = xx.x_id),
                               (SELECT XMLELEMENT (
                                           "ndi_rpt_group",
                                           XMLELEMENT ("nrg_id", nrg_id),
                                           XMLELEMENT ("nrg_code", nrg_code),
                                           XMLELEMENT ("nrg_name", nrg_name))
                                  FROM uss_ndi.v_ndi_rpt_group,
                                       uss_ndi.v_ndi_report_type
                                 WHERE rt_nrg = nrg_id AND rt_id = xx.x_id),
                               (SELECT XMLELEMENT (
                                           "rpt_access",
                                           XMLAGG (
                                               XMLELEMENT (
                                                   "row",
                                                   XMLELEMENT ("ra_id",
                                                               ra_id),
                                                   XMLELEMENT ("ra_nrg",
                                                               ra_nrg),
                                                   XMLELEMENT ("ra_rt",
                                                               ra_rt),
                                                   XMLELEMENT (
                                                       "ra_start_dt",
                                                       TO_CHAR (
                                                           ra_start_dt,
                                                           'DD.MM.YYYY HH24:MI:SS')),
                                                   XMLELEMENT (
                                                       "ra_stop_dt",
                                                       TO_CHAR (
                                                           ra_stop_dt,
                                                           'DD.MM.YYYY HH24:MI:SS')),
                                                   XMLELEMENT ("ra_tp",
                                                               ra_tp),
                                                   XMLELEMENT ("ra_wr",
                                                               ra_wr))))
                                  FROM (SELECT ra.*
                                          FROM uss_ndi.v_ndi_rpt_access  ra,
                                               uss_ndi.v_ndi_report_type
                                         WHERE     ra_rt = rt_id
                                               AND rt_id = xx.x_id
                                        UNION
                                        SELECT ra.*
                                          FROM uss_ndi.v_ndi_rpt_access  ra,
                                               uss_ndi.v_ndi_report_type
                                         WHERE     ra_nrg = rt_nrg
                                               AND rt_id = xx.x_id
                                               AND ra_rt IS NULL)),
                               (SELECT XMLELEMENT (
                                           "rpt_queries",
                                           XMLELEMENT ("rq_id", rq_id),
                                           XMLELEMENT ("rq_rt", rq_rt),
                                           XMLELEMENT (
                                               "rq_query",
                                               TOOLS.encode_base64 (
                                                   TOOLS.ConvertC2B (
                                                       rq_query))),
                                           XMLELEMENT ("rq_tp", rq_tp),
                                           XMLELEMENT ("rq_st", rq_st),
                                           XMLELEMENT (
                                               "rq_start_dt",
                                               TO_CHAR (
                                                   rq_start_dt,
                                                   'DD.MM.YYYY HH24:MI:SS')),
                                           XMLELEMENT (
                                               "rq_stop_dt",
                                               TO_CHAR (
                                                   rq_stop_dt,
                                                   'DD.MM.YYYY HH24:MI:SS')),
                                           XMLELEMENT (
                                               "rq_rpt_header",
                                               CASE
                                                   WHEN rq_rpt_header IS NULL
                                                   THEN
                                                       NULL
                                                   ELSE
                                                       TOOLS.encode_base64 (
                                                           TOOLS.ConvertC2B (
                                                               rq_rpt_header))
                                               END))
                                  FROM uss_ndi.v_ndi_rpt_queries
                                 WHERE rq_rt = xx.x_id),
                               (SELECT XMLELEMENT (
                                           "ndi_rpt_params",
                                           XMLAGG (
                                               XMLELEMENT (
                                                   "row",
                                                   XMLELEMENT ("nrp_id",
                                                               nrp_id),
                                                   XMLELEMENT ("nrp_rt",
                                                               nrp_rt),
                                                   XMLELEMENT ("nrp_code",
                                                               nrp_code),
                                                   XMLELEMENT ("nrp_name",
                                                               nrp_name),
                                                   XMLELEMENT ("nrp_data_tp",
                                                               nrp_data_tp))))
                                  FROM uss_ndi.v_ndi_rpt_params
                                 WHERE nrp_rt = xx.x_id)),
                           VERSION '1.0" encoding="utf-8').getClobVal ()
                  FROM DUAL;
        END LOOP;

        WL ('load data');
        WL ('infile *');
        WL ('replace');
        WL ('into table ' || x_owner || '.tmp$load_reports');
        WL ('fields terminated by ''|''');
        WL ('(');
        WL ('  r_id,');
        WL ('  r_filename,');
        WL ('  r_text lobfile(r_filename) terminated by eof');
        WL (')');
        WL ('begindata');

        FOR xx
            IN (SELECT    rt_id
                       || '|'
                       || 'x_clob_'
                       || rt_id
                       || '.dat|'
                       || 'x_clob_'
                       || rt_id
                       || '.dat|'    AS x_row
                  FROM uss_ndi.v_ndi_report_type
                 WHERE rt_id IN (    SELECT REGEXP_SUBSTR (x_list,
                                                           '[^,]+',
                                                           1,
                                                           LEVEL)
                                       FROM DUAL
                                 CONNECT BY REGEXP_SUBSTR (x_list,
                                                           '[^,]+',
                                                           1,
                                                           LEVEL)
                                                IS NOT NULL))
        LOOP
            WL (xx.x_row);
        END LOOP;
    END;

    PROCEDURE prepare_rpt_script_By_id (p_owner        VARCHAR2,
                                        p_rpt_id       NUMBER,
                                        res_cur    OUT SYS_REFCURSOR)
    IS
    BEGIN
        prepare_rpt_script (p_owner, p_rpt_id);

        OPEN res_cur FOR
            SELECT t.fn, t.file, DBMS_LOB.getlength (t.file)
              FROM (SELECT 'export_' || t.x_id || '.xml'     AS fn,
                           tools.ConvertC2B (t.x_clob)       AS file
                      FROM tmp_lob t
                     WHERE t.x_id = p_rpt_id) t;
    END;

    /*
    PROCEDURE import_reports
    IS
      l_nrt DECIMAL;
      l_nrg DECIMAL;
      l_data XMLTYPE;
    BEGIN
      WL('Strting load reports!');
      FOR xx IN (SELECT r_id, XMLTYPE(TOOLS.ConvertB2C(r_text)) AS r_text
                 FROM tmp$load_reports)
      LOOP
        l_nrt := xx.r_text.extract('/report/ndi_report_type/nrt_id/text()').getstringval();
        l_nrg := xx.r_text.extract('/report/ndi_rpt_group/nrg_id/text()').getstringval();
        WL('.  r_id='||xx.r_id||', nrt_id='||l_nrt||',nrg_id='||l_nrg||', name='||xx.r_text.extract('/report/ndi_report_type/nrt_name/text()').getstringval());

        MERGE INTO uss_ndi.v_ndi_rpt_group
          USING (SELECT x_id, x_code, x_name
                 FROM xmltable ('/report/ndi_rpt_group'
                   PASSING xx.r_text
                   COLUMNS x_id NUMBER PATH 'nrg_id',
                           x_code VARCHAR2(10) PATH 'nrg_code',
                           x_name VARCHAR2(250) PATH 'nrg_name'))
          ON (nrg_id = x_id)
          WHEN MATCHED THEN
            UPDATE SET nrg_code = x_code, nrg_name = x_name
          WHEN NOT MATCHED THEN
            INSERT (nrg_id, nrg_code, nrg_name)
              VALUES (x_id, x_code, x_name);

        WL('.         ndi_rpt_group. merged rows='||SQL%ROWCOUNT);

        MERGE INTO ikis_rpt.ndi_report_type
          USING (SELECT x_id, x_code, x_name, x_nrg, x_desc
                 FROM xmltable ('/report/ndi_report_type'
                   PASSING xx.r_text
                   COLUMNS x_id NUMBER PATH 'nrt_id',
                           x_code VARCHAR2(10) PATH 'nrt_code',
                           x_name VARCHAR2(250) PATH 'nrt_name',
                           x_nrg NUMBER PATH 'nrt_nrg',
                           x_desc VARCHAR2(500) PATH 'nrt_desc'))
          ON (nrt_id = x_id)
          WHEN MATCHED THEN
            UPDATE SET nrt_code = x_code, nrt_name = x_name, nrt_nrg = x_nrg, nrt_desc = x_desc
          WHEN NOT MATCHED THEN
            INSERT (nrt_id, nrt_code, nrt_name, nrt_nrg, nrt_desc)
              VALUES (x_id, x_code, x_name, x_nrg, x_desc);

        WL('.         ndi_report_type. merged rows='||SQL%ROWCOUNT);

        MERGE INTO ikis_rpt.rpt_queries
          USING (SELECT x_id, x_nrt, ikis_rpt.TOOLS.ConvertB2C(ikis_rpt.TOOLS.decode_base64(x_query)) AS x_query,
                        x_tp, x_st, to_date(x_start_dt, 'DD.MM.YYYY HH24:MI:SS') AS x_start_dt, to_date(x_stop_dt, 'DD.MM.YYYY HH24:MI:SS') AS x_stop_dt,
                        ikis_rpt.TOOLS.ConvertB2C(ikis_rpt.TOOLS.decode_base64(x_rpt_header))  AS x_rpt_header
                 FROM xmltable ('/report/rpt_queries'
                   PASSING xx.r_text
                   COLUMNS x_id NUMBER PATH 'rq_id',
                           x_nrt NUMBER PATH 'rq_nrt',
                           x_query CLOB PATH 'rq_query',
                           x_tp VARCHAR2(10) PATH 'rq_tp',
                           x_st VARCHAR2(10) PATH 'rq_st',
                           x_start_dt VARCHAR2(100) PATH 'rq_start_dt',
                           x_stop_dt VARCHAR2(100) PATH 'rq_stop_dt',
                           x_rpt_header CLOB PATH 'rq_rpt_header'))
          ON (rq_id = x_id)
          WHEN MATCHED THEN
            UPDATE SET rq_nrt = x_nrt,
                       rq_query = x_query,
                       rq_tp = x_tp,
                       rq_st = x_st,
                       rq_start_dt = x_start_dt,
                       rq_stop_dt = x_stop_dt,
                       rq_rpt_header = x_rpt_header
          WHEN NOT MATCHED THEN
            INSERT (rq_id, rq_nrt, rq_query, rq_tp, rq_st, rq_start_dt, rq_stop_dt, rq_rpt_header)
              VALUES (0, x_nrt, x_query, x_tp, x_st, x_start_dt, x_stop_dt, x_rpt_header);

        WL('.         rpt_queries. merged rows='||SQL%ROWCOUNT);

        DELETE FROM ikis_rpt.rpt_access WHERE ra_nrt = l_nrt OR (ra_nrg = l_nrg AND ra_nrt IS NULL);

        WL('.         rpt_access. deleted rows='||SQL%ROWCOUNT);

        INSERT INTO ikis_rpt.rpt_access (ra_id, ra_nrg, ra_nrt, ra_start_dt, ra_stop_dt, ra_tp, ra_wr)
          SELECT 0, x_nrg, x_nrt, x_start_dt, x_stop_dt, x_tp, x_wr
          FROM (SELECT x_id, x_nrg, x_nrt, to_date(x_start_dt, 'DD.MM.YYYY HH24:MI:SS') AS x_start_dt, to_date(x_stop_dt, 'DD.MM.YYYY HH24:MI:SS') AS x_stop_dt, x_tp, x_wr
                FROM xmltable ('/report/rpt_access/row'
                  PASSING xx.r_text
                  COLUMNS x_id NUMBER PATH 'ra_id',
                          x_nrg NUMBER PATH 'ra_nrg',
                          x_nrt NUMBER PATH 'ra_nrt',
                          x_start_dt VARCHAR2(100) PATH 'ra_start_dt',
                          x_stop_dt VARCHAR2(100) PATH 'ra_stop_dt',
                          x_tp VARCHAR2(10) PATH 'ra_tp',
                          x_wr NUMBER PATH 'ra_wr'));

        WL('.         rpt_access. inserted rows='||SQL%ROWCOUNT);

        MERGE INTO ikis_rpt.ndi_rpt_params
          USING (SELECT x_id, x_nrt, x_code, x_name, x_data_tp
                 FROM xmltable ('/report/ndi_rpt_params/row'
                   PASSING xx.r_text
                   COLUMNS x_id NUMBER PATH 'nrp_id',
                           x_nrt NUMBER PATH 'nrp_nrt',
                           x_code VARCHAR2(10) PATH 'nrp_code',
                           x_name VARCHAR2(250) PATH 'nrp_name',
                           x_data_tp VARCHAR2(10) PATH 'nrp_data_tp'))
        ON (nrp_nrt = x_nrt AND nrp_code = x_code)
          WHEN MATCHED THEN
            UPDATE SET nrp_name = x_name,
                       nrp_data_tp = x_data_tp
          WHEN NOT MATCHED THEN
            INSERT (nrp_id, nrp_nrt, nrp_code, nrp_name, nrp_data_tp)
              VALUES (0, x_nrt, x_code, x_name, x_data_tp);

        WL('.         ndi_rpt_params. merged rows='||SQL%ROWCOUNT);
      END LOOP;
      WL('Reports loaded!');

    END;*/


    PROCEDURE make_package_export_cmd
    IS
        l_cnt            INTEGER;
        l_sqlplus_line   VARCHAR2 (250);
    BEGIN
        WL ('REM Кожна змінна listN не може бути більша за 200 символів!!!');
        WL (CHR (10));

        SELECT TRUNC (COUNT (*) / 10) + 1
          INTO l_cnt
          FROM user_objects
         WHERE object_type = 'PACKAGE' AND object_name NOT LIKE '%$OP'--AND object_name NOT IN ('BLD$TCTR_ANALYTIC_PANEL')
                                                                      ;

        l_sqlplus_line :=
            'sqlplus uss_rpt/uss_rpt@sonya @make_packages_clob.sql';

        FOR xx
            IN (  SELECT DISTINCT
                         line,
                            'SET list'
                         || line
                         || '='
                         || LISTAGG (LOWER (object_name), ',')
                                WITHIN GROUP (ORDER BY line, object_name)
                                OVER (PARTITION BY line)    AS y_line
                    FROM (    SELECT LEVEL     AS line
                                FROM DUAL
                          CONNECT BY LEVEL <= l_cnt),
                         (  SELECT object_name,
                                   TRUNC (ROWNUM / (10 + 1)) + 1     AS x_line
                              FROM user_objects
                             WHERE     object_type = 'PACKAGE'
                                   AND object_name NOT LIKE '%$OP'
                          --AND object_name NOT IN ('BLD$TCTR_ANALYTIC_PANEL')
                          ORDER BY object_name)
                   WHERE line = x_line(+)
                ORDER BY 1)
        LOOP
            l_sqlplus_line :=
                l_sqlplus_line || ' ''%list' || xx.line || '%''';
            WL (xx.y_line);
        END LOOP;

        WL (CHR (10));
        WL (l_sqlplus_line);
        WL (CHR (10));
        WL ('ExportLOBs.exe tmp_lob x_id x_clob dat CLOB "x_id = 777"');
        WL (CHR (10));
        WL ('del 008_packages_src.sql');
        WL ('ren x_clob_777.dat 008_packages_src.sql');
    END;
END BLD$IMPEXP;
/