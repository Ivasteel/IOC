/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.BLD$IMPEXP
IS
    -- Author  : VANO
    -- Created : 07.12.2021 16:26:44
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

    PROCEDURE prepare_pkg_script_by_ddl (p_owner          VARCHAR2,
                                         p_pkg_by_comma   VARCHAR2);

    PROCEDURE make_package_export_cmd;
END BLD$IMPEXP;
/


/* Formatted on 8/12/2025 6:10:48 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.BLD$IMPEXP
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
        /*  FOR xx IN (select 'create or replace synonym &PROXY_USR..'||z.rat_object_name||' FOR &PREFIX..'||z.rat_object_name||';' AS z_synonum_create
                     from ikis_sys.ikis_rsrc_attr z
                     where rat_rsrc = 'RC_USS_DOC_WEB')
          LOOP
            WL(xx.z_synonum_create);
          END LOOP;*/
        NULL;
    END;

    PROCEDURE make_data_script (p_owner VARCHAR2, p_type VARCHAR2)
    IS
    BEGIN
        /*FOR xx IN (SELECT 'ALTER TABLE '||owner||'.'||table_name||' DISABLE CONSTRAINT '||constraint_name||';' AS sql_disable,
                          'ALTER TABLE '||owner||'.'||table_name||' ENABLE CONSTRAINT '||constraint_name||';' AS sql_enable
                   FROM dba_constraints
                   WHERE constraint_type = 'R'
                     AND r_owner = UPPER(p_owner))
        LOOP
          WL(CASE WHEN UPPER(p_type) = 'BEFORE' THEN xx.sql_disable WHEN UPPER(p_type) = 'AFTER' THEN xx.sql_enable END);
        END LOOP;*/
        NULL;
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
        WL ('sqlplus ikis_rbm/ikis_rbm@sonya @export_dict_and_config.sql');
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
                   '  IKIS_RBM.BLD$IMPEXP.make_inserts(''ikis_rbm'', '''
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
                IN (SELECT    'ALTER TABLE '
                           || owner
                           || '.'
                           || table_name
                           || ' DISABLE CONSTRAINT '
                           || constraint_name
                           || ';'    AS sql_disable
                      FROM user_constraints
                     WHERE     constraint_type = 'R'
                           AND r_owner = 'IKIS_RBM'
                           AND r_constraint_name IN
                                   ('XPK_' || UPPER (tbs (i)),
                                    'IPK_' || UPPER (tbs (i))))
            LOOP
                WL (zz.sql_disable);
            END LOOP;

            WL (' ');
        END LOOP;

        FOR i IN 1 .. tbs.COUNT
        LOOP
            WL ('prompt Deleting ' || UPPER (tbs (i)) || '...');
            WL (
                'DELETE FROM IKIS_RBM.' || LOWER (tbs (i)) || ' WHERE 1 = 1;');
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
                IN (SELECT    'ALTER TABLE '
                           || owner
                           || '.'
                           || table_name
                           || ' ENABLE CONSTRAINT '
                           || constraint_name
                           || ';'    AS sql_enable
                      FROM user_constraints
                     WHERE     constraint_type = 'R'
                           AND r_owner = 'IKIS_RBM'
                           AND r_constraint_name IN
                                   ('XPK_' || UPPER (tbs (i)),
                                    'IPK_' || UPPER (tbs (i))))
            LOOP
                WL (zz.sql_enable);
            END LOOP;

            WL (' ');
        END LOOP;

        WL ('SET FEEDBACK ON');
        WL ('SET DEFINE ON');
        WL ('PROMPT Done.');
    END;

    PROCEDURE prepare_pkg_script_by_ddl (p_owner          VARCHAR2,
                                         p_pkg_by_comma   VARCHAR2)
    IS
        l_tmp_header   CLOB;
        l_tmp_body     CLOB;
        l_headers      CLOB;
        l_bodies       CLOB;
        l_result       CLOB;
    BEGIN
        DBMS_LOB.createTemporary (l_headers, TRUE);
        DBMS_LOB.OPEN (l_headers, DBMS_LOB.LOB_ReadWrite);
        DBMS_LOB.createTemporary (l_bodies, TRUE);
        DBMS_LOB.OPEN (l_bodies, DBMS_LOB.LOB_ReadWrite);
        DBMS_LOB.createTemporary (l_result, TRUE);
        DBMS_LOB.OPEN (l_result, DBMS_LOB.LOB_ReadWrite);

        DBMS_METADATA.set_transform_param (DBMS_METADATA.SESSION_TRANSFORM,
                                           'PRETTY',
                                           TRUE);
        DBMS_METADATA.set_transform_param (DBMS_METADATA.SESSION_TRANSFORM,
                                           'SQLTERMINATOR',
                                           TRUE);
        DBMS_METADATA.set_transform_param (DBMS_METADATA.SESSION_TRANSFORM,
                                           'CONSTRAINTS_AS_ALTER',
                                           TRUE);
        DBMS_METADATA.set_transform_param (DBMS_METADATA.SESSION_TRANSFORM,
                                           'SEGMENT_ATTRIBUTES',
                                           FALSE);


        FOR xx IN (SELECT TRIM (UPPER (x_data))     AS x_row
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
            WL (xx.x_row);
            l_tmp_header :=
                DBMS_METADATA.get_ddl ('PACKAGE',
                                       TRIM (xx.x_row),
                                       UPPER (p_owner),
                                       '11.2');
            l_tmp_body :=
                DBMS_METADATA.get_ddl ('PACKAGE_BODY',
                                       TRIM (xx.x_row),
                                       UPPER (p_owner),
                                       '11.2');
            DBMS_LOB.append (l_headers, l_tmp_header);
            DBMS_LOB.append (l_headers, CHR (13) || CHR (10));

            DBMS_LOB.append (l_bodies, l_tmp_body);
            DBMS_LOB.append (l_bodies, CHR (13) || CHR (10));
        END LOOP;

        DBMS_LOB.append (
            l_result,
               'prompt NVP Medirent Export User Objects for user IKIS_RBM@sonya'
            || CHR (13)
            || CHR (10));
        DBMS_LOB.append (
            l_result,
               'prompt Created by '
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
              WHERE 1 = 1;

        INSERT INTO tmp_lob (x_id, x_clob)
             VALUES (777, l_result);

        COMMIT;
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
         WHERE     object_type = 'PACKAGE'
               AND object_name NOT LIKE '%$OP'
               AND object_name NOT IN ('API$REQUEST_MSP');

        l_sqlplus_line :=
            'sqlplus ikis_rbm/ikis_rbm@sonya @make_packages_clob.sql';

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
                                   AND object_name NOT IN ('API$REQUEST_MSP')
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