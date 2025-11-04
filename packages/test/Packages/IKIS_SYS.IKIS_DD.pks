/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_DD
    AUTHID CURRENT_USER
IS
    modeOutPut        INTEGER := 1;
    modeClob          INTEGER := 2;
    modeIncludeDrop   INTEGER := 1;

    PROCEDURE create_dd_view_i (result OUT VARCHAR2);

    PROCEDURE create_dd_view;

    FUNCTION get_default_value (p_tbl IN VARCHAR2, p_fld VARCHAR2)
        RETURN VARCHAR2;

    PROCEDURE GenerateConstPackage (p_mode INTEGER, p_text OUT CLOB);

    PROCEDURE GenerateNSIConstPackage (
        p_mode                INTEGER,
        p_text            OUT CLOB,
        p_use_max_id   IN     NUMBER := 1000000);

    PROCEDURE GenerateCheckConstraint (
        p_include_drop       NUMBER,
        p_mode               INTEGER,
        p_text           OUT CLOB,
        p_change_only        BOOLEAN DEFAULT FALSE); --генерить только измененное

    PROCEDURE SetChangeVersion (p_version VARCHAR2); --если p_change_only=true, то нужно указать текущую версию, что загружаются

    FUNCTION GetChangeVersion
        RETURN VARCHAR2;

    PROCEDURE ClearMonitoring (p_version VARCHAR2);

    PROCEDURE GenerateDefVal (p_mode           INTEGER,
                              p_text       OUT CLOB,
                              p_not_null       INTEGER := 0);
END IKIS_DD;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_DD FOR IKIS_SYS.IKIS_DD
/


GRANT EXECUTE ON IKIS_SYS.IKIS_DD TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DD TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DD TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DD TO IKIS_SYSWEB WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DD TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DD TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DD TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DD TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DD TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DD TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DD TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DD TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYS.IKIS_DD TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:10:03 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_DD
IS
    gChangeVersion   VARCHAR2 (100);

    PROCEDURE create_dd_view_i (result OUT VARCHAR2)
    IS
    BEGIN
        create_dd_view;
        result := 'View created successfully';
    EXCEPTION
        WHEN OTHERS
        THEN
            result := SQLERRM;
    END;

    PROCEDURE create_dd_view
    IS
        CURSOR c_dd IS
            SELECT didi_id,
                   didi_name,
                   didi_tp,
                   didi_didi,
                   didi_srtordr,
                   didi_descript,
                   didi_viewname
              FROM dic_dd
             WHERE dic_dd.didi_tp = 'D';

        r_dd    c_dd%ROWTYPE;
        c_sql   VARCHAR2 (32760);
    BEGIN
        FOR r_dd IN c_dd
        LOOP
            c_sql :=
                   'create or replace view '
                || r_dd.DIDI_VIEWNAME
                || ' (DIC_DIDI,DIC_CODE,DIC_VALUE,DIC_NAME,DIC_SNAME,DIC_ST,DIC_SRTORDR)'
                || 'as select DIC_DIDI,DIC_CODE,DIC_VALUE,DIC_NAME,DIC_SNAME,DIC_ST,DIC_SRTORDR '
                || 'from dic_dv where DIC_DIDI = '
                || TO_CHAR (r_dd.DIDI_ID);

            EXECUTE IMMEDIATE c_sql;
        END LOOP;
    --exception
    --  when others
    --    then raise_application_error(-20000,'Error in IKIS_DD.create_dd_view'||chr(10)||c_sql||chr(10)||sqlerrm);
    END;

    FUNCTION get_default_value (p_tbl IN VARCHAR2, p_fld VARCHAR2)
        RETURN VARCHAR2
    IS
        l_value   dic_dv.dic_value%TYPE;
    BEGIN
        SELECT dv.dic_value
          INTO l_value
          FROM dic_tbl d, dic_dv dv
         WHERE     d.tbl_didi = dv.dic_didi
               AND d.tbl_def_value = dv.dic_value
               AND UPPER (d.tbl_tbl_name) = UPPER (p_tbl)
               AND UPPER (d.tbl_fld_name) = UPPER (p_fld);

        RETURN l_value;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
        WHEN OTHERS
        THEN
            RAISE;
    END;

    PROCEDURE GenerateConstPackage (p_mode INTEGER, p_text OUT CLOB)
    IS
        ConstPkgName     CONSTANT VARCHAR2 (40) := 'ikis_const';
        PartDiv          CONSTANT VARCHAR2 (70) := RPAD ('--', 70, '*');
        CommentDiv       CONSTANT VARCHAR2 (70) := RPAD ('--', 70, '-');
        ConstPrefix      CONSTANT VARCHAR2 (8) := 'id_';
        TxtConstPrefix   CONSTANT VARCHAR2 (8) := 'txt_';
        ConstType        CONSTANT VARCHAR (12) := 'VARCHAR2(10)';
        TxtConstType     CONSTANT VARCHAR (15) := 'VARCHAR2(100)';
        CommentShift     CONSTANT NUMBER := 40;
        p_Prefix                  VARCHAR2 (40);
        p_Line                    VARCHAR2 (1000);
        p_Name                    VARCHAR2 (40);

        CURSOR cdf IS
                SELECT didi_id,
                       didi_name,
                       didi_tp,
                       didi_didi,
                       didi_srtordr,
                       didi_descript,
                       didi_viewname,
                       LEVEL
                  FROM dic_dd
            START WITH DIDI_DIDI IS NULL
            CONNECT BY PRIOR DIDI_ID = DIDI_DIDI;

        CURSOR cdv (p_DIC_DIDI dic_dv.DIC_DIDI%TYPE)
        IS
              SELECT dic_didi,
                     dic_code,
                     dic_value,
                     dic_name,
                     dic_sname,
                     dic_st,
                     dic_srtordr
                FROM dic_dv
               WHERE DIC_DIDI = p_DIC_DIDI
            ORDER BY dic_dv.dic_srtordr;

        PROCEDURE AddLine (S IN VARCHAR2)
        IS
        BEGIN
            IF p_mode = modeOutPut
            THEN
                DBMS_OUTPUT.put_line (S);
            END IF;

            IF p_mode = modeClob
            THEN
                p_text := p_text || S || CHR (13);
            END IF;
        END;
    BEGIN
        p_text := NULL;
        AddLine ('create or replace package ' || ConstPkgName || ' is');

        FOR df IN cdf
        LOOP
            IF df.didi_tp = 'D'
            THEN
                AddLine (CommentDiv);
                AddLine ('-- ' || 'Справочник:    ' || df.DIDI_NAME);
                AddLine ('-- ' || 'Идентификатор: ' || df.DIDI_ID);
                AddLine ('-- ' || 'Представление: ' || df.DIDI_VIEWNAME);
                AddLine (
                       'DIC_'
                    || df.DIDI_VIEWNAME
                    || ' '
                    || ConstType
                    || ' := '
                    || df.DIDI_ID
                    || ';');

                --       p_Prefix := Replace(df.DIDI_VIEWNAME, 'smz_', ConstPrefix);
                FOR dv IN cdv (df.DIDI_ID)
                LOOP
                    p_Name := dv.DIC_VALUE;
                    p_Line :=
                           df.DIDI_VIEWNAME
                        || '_'
                        || p_Name
                        || ' '
                        || ConstType
                        || ' := '''
                        || dv.DIC_VALUE
                        || ''';';

                    IF LENGTH (p_Line) < CommentShift
                    THEN
                        p_Line := RPAD (P_Line, CommentShift);
                    END IF;

                    p_Line :=
                           p_Line
                        || TxtConstPrefix
                        || df.DIDI_VIEWNAME
                        || '_'
                        || p_Name
                        || ' '
                        || TxtConstType
                        || ' := '''
                        || dv.dic_sname
                        || ''';';
                    AddLine (p_Line);
                END LOOP;
            ELSE
                AddLine (PartDiv);
                AddLine ('-- ' || df.DIDI_NAME);
                NULL;
            END IF;
        END LOOP;

        AddLine ('end ' || ConstPkgName || ';');
        AddLine ('/');
    --exception
    --  when others
    --    then raise_application_error(-20000,'Error in IKIS_DD.GenerateConstPackage'||chr(10)||sqlerrm);
    END GenerateConstPackage;

    PROCEDURE GenerateNSIConstPackage (
        p_mode                INTEGER,
        p_text            OUT CLOB,
        p_use_max_id   IN     NUMBER := 1000000)
    IS
        TYPE TCursor IS REF CURSOR;

        TYPE TNSI_TAB IS RECORD
        (
            F_ID      NUMBER,
            F_NAME    VARCHAR2 (150)
        );

        tab                       TCursor;
        tab_row                   TNSI_TAB;
        ConstPkgName     CONSTANT VARCHAR2 (40) := 'ikis_nsi_const';
        PartDiv          CONSTANT VARCHAR2 (70) := RPAD ('--', 70, '*');
        CommentDiv       CONSTANT VARCHAR2 (70) := RPAD ('--', 70, '-');
        ConstPrefix      CONSTANT VARCHAR2 (8) := 'id_';
        TxtConstPrefix   CONSTANT VARCHAR2 (8) := 'txt_';
        ConstType        CONSTANT VARCHAR (12) := 'number';
        TxtConstType     CONSTANT VARCHAR (15) := 'VARCHAR2(150)';
        CommentShift     CONSTANT NUMBER := 40;
        p_Line                    VARCHAR2 (1000);
        p_ID_Col                  VARCHAR2 (40);
        p_Name_Col                VARCHAR2 (40);
        p_Cont_Name               VARCHAR2 (200);

        PROCEDURE AddLine (S IN VARCHAR2)
        IS
        BEGIN
            IF p_mode = modeOutPut
            THEN
                DBMS_OUTPUT.put_line (S);
            END IF;

            IF p_mode = modeClob
            THEN
                p_text := p_text || S || CHR (13);
            END IF;
        END;
    BEGIN
        p_text := NULL;
        AddLine ('create or replace package ' || ConstPkgName || ' is');

        FOR vNSI IN (SELECT * FROM dic_nsi_tbl)
        LOOP
            AddLine (CommentDiv);
            AddLine ('-- ' || 'Справочник:    ' || vNSI.dnt_name);

            IF TRIM (vNSI.dnt_col_id) IS NULL
            THEN
                SELECT column_name
                  INTO p_ID_col
                  FROM user_tab_columns
                 WHERE     table_name = vNSI.dnt_name
                       AND column_name LIKE '%_ID'
                       AND data_type = 'NUMBER';
            ELSE
                p_ID_col := vNSI.dnt_col_id;
            END IF;

            IF TRIM (vNSI.dnt_col_name) IS NULL
            THEN
                SELECT column_name
                  INTO p_Name_col
                  FROM user_tab_columns
                 WHERE     table_name = vNSI.dnt_name
                       AND column_name LIKE '%NAME'
                       AND NOT column_name LIKE '%SNAME'
                       AND data_type = 'VARCHAR2';
            ELSE
                p_Name_col := vNSI.dnt_col_id;
            END IF;

            OPEN tab FOR
                   'select '
                || p_ID_col
                || ', '
                || p_Name_col
                || ' from '
                || vNSI.dnt_name
                || ' where '
                || p_ID_col
                || '<'
                || p_use_max_id;

            LOOP
                FETCH tab INTO tab_row;

                EXIT WHEN tab%NOTFOUND;
                tab_row.f_name :=
                    REPLACE (REPLACE (tab_row.f_name, '''', '*'), '"', '*');
                p_Cont_Name := vNSI.dnt_name || '_' || tab_row.f_id;
                p_Line :=
                       '    '
                    || p_Cont_Name
                    || ' '
                    || ConstType
                    || ':='
                    || tab_row.f_id
                    || ';      '
                    || TxtConstPrefix
                    || p_Cont_Name
                    || ' '
                    || TxtConstType
                    || ':='''
                    || tab_row.f_name
                    || ''';';
                AddLine (p_line);
            END LOOP;

            CLOSE tab;

            AddLine (PartDiv);
        END LOOP;

        AddLine ('end ' || ConstPkgName || ';');
        AddLine ('/');
    --exception
    --  when others
    --    then raise_application_error(-20000,'Error in IKIS_DD.GenerateNSIConstPackage'||chr(10)||sqlerrm);
    END;

    PROCEDURE ClearMonitoring (p_version VARCHAR2)
    IS
    BEGIN
        DELETE dic_monitor
         WHERE dm_ver = p_version;
    END;

    PROCEDURE SetChangeVersion (p_version VARCHAR2)
    IS
    BEGIN
        gChangeVersion := p_version;
    END;

    FUNCTION GetChangeVersion
        RETURN VARCHAR2
    IS
    BEGIN
        IF gChangeVersion IS NULL
        THEN
            raise_application_error (
                -20000,
                'Не встановлено версії змін для генерування чек констрейнтов.');
        ELSE
            RETURN gChangeVersion;
        END IF;
    END;

    PROCEDURE GenerateCheckConstraint (
        p_include_drop       NUMBER,
        p_mode               INTEGER,
        p_text           OUT CLOB,
        p_change_only        BOOLEAN DEFAULT FALSE)
    IS
        l_lst          VARCHAR2 (1000);

        l_templ1       VARCHAR2 (32760)
            := '  execute immediate ''ALTER TABLE ^<TABLENAME>^ DROP CONSTRAINT ^<CONSTRAINTNAME>^'';';
        l_templ2       VARCHAR2 (32760)
            := 'ALTER TABLE ^<TABLENAME>^ ADD CONSTRAINT ^<CONSTRAINTNAME>^ CHECK (^<FIELDNAME>^ ^<CHECKCONSTR>^)';
        --  l_templ3 varchar2(32760):= 'alter table ^<TABLENAME>^ modify (^<FIELDNAME>^ default ''^<DEFVAL>^'');';
        --  l_templ3 varchar2(32760):= ' modify (^<FIELDNAME>^ default ''^<DEFVAL>^'')';

        l_src1         VARCHAR2 (32760);
        l_src2         VARCHAR2 (32760);
        --  l_src3 varchar2(32760);

        l_is_changes   NUMBER := 0;

        PROCEDURE Output (p_line VARCHAR2)
        IS
        BEGIN
            IF p_mode = modeOutPut
            THEN
                dbms_output_put_lines (p_line);
            END IF;

            IF p_mode = modeClob
            THEN
                p_text := p_text || p_line || CHR (10);
            END IF;
        END;
    BEGIN
        IF p_change_only
        THEN
            IF gChangeVersion IS NULL
            THEN
                raise_application_error (
                    -20000,
                    'Спроба генерувати тільки зміни для check constraints, але не вказано версії.');
            ELSE
                l_is_changes := 1;
                Output ('rem START GENERATE CHANGES for ' || gChangeVersion);
            END IF;
        END IF;

        --Ryaba
        --11.10.2004
        --В назвазние констрейнта добавлено название таблицы
        --для различения констрейнтов полей с одинаковыми
        --названиями в разных таблицах

        FOR tbl
            IN (SELECT x.tbl_fld_name,
                       x.tbl_tbl_name,
                       x.tbl_didi,
                       x.tbl_def_value
                  FROM dic_tbl x
                 WHERE    l_is_changes = 0
                       OR (    l_is_changes = 1
                           AND x.tbl_didi IN
                                   (SELECT dm_dic
                                      FROM dic_monitor
                                     WHERE     dm_ver =
                                               ikis_dd.GetChangeVersion
                                           AND UPPER (x.tbl_tbl_name) =
                                               NVL (dm_table,
                                                    UPPER (x.tbl_tbl_name)))))
        LOOP
            l_lst := NULL;

            FOR lst IN (SELECT dic_didi,
                               dic_code,
                               dic_value,
                               dic_name,
                               dic_sname,
                               dic_st,
                               dic_srtordr
                          FROM dic_dv
                         WHERE dic_dv.dic_didi = tbl.tbl_didi)
            LOOP
                IF l_lst IS NULL
                THEN
                    l_lst := '''' || lst.dic_value || '''';
                ELSE
                    l_lst := l_lst || ',' || '''' || lst.dic_value || '''';
                END IF;
            END LOOP;

            l_src1 :=
                REPLACE (
                    REPLACE (
                        REPLACE (
                            REPLACE (l_templ1,
                                     '^<TABLENAME>^',
                                     UPPER (tbl.tbl_tbl_name)),
                            '^<CONSTRAINTNAME>^',
                            SUBSTR (
                                   'CHK_'
                                || UPPER (tbl.tbl_tbl_name)
                                || '_'
                                || UPPER (tbl.tbl_fld_name),
                                1,
                                30)),
                        '^<FIELDNAME>^',
                        UPPER (tbl.tbl_fld_name)),
                    '^<CHECKCONSTR>^',
                    'in (' || l_lst || ')');
            l_src2 :=
                REPLACE (
                    REPLACE (
                        REPLACE (
                            REPLACE (l_templ2,
                                     '^<TABLENAME>^',
                                     UPPER (tbl.tbl_tbl_name)),
                            '^<CONSTRAINTNAME>^',
                            SUBSTR (
                                   'CHK_'
                                || UPPER (tbl.tbl_tbl_name)
                                || '_'
                                || UPPER (tbl.tbl_fld_name),
                                1,
                                30)),
                        '^<FIELDNAME>^',
                        UPPER (tbl.tbl_fld_name)),
                    '^<CHECKCONSTR>^',
                    'in (' || l_lst || ')');

            --    if tbl.tbl_def_value is not null then
            --      l_src3:=
            --      replace(
            --      replace(
            --      replace(l_templ3,'^<TABLENAME>^',upper(tbl.tbl_tbl_name))
            --                     ,'^<DEFVAL>^',upper(tbl.tbl_def_value))
            --                     ,'^<FIELDNAME>^',upper(tbl.tbl_fld_name));
            --      l_src2:=l_src2||l_src3;
            --    end if;
            Output ('rem Dictionary ' || tbl.tbl_didi);

            IF p_include_drop = modeIncludeDrop
            THEN
                Output ('begin ');
                Output (l_src1);
                Output ('exception when others then null;');
                Output ('end;');
                Output ('/');
                Output (l_src2);
                Output ('/');
            ELSE
                Output (l_src2);
                Output ('/');
            END IF;
        END LOOP;
    --exception
    --  when others
    --    then raise_application_error(-20000,'Error in IKIS_DD.GenerateCheckConstraint'||chr(10)||sqlerrm);
    END GenerateCheckConstraint;

    PROCEDURE GenerateDefVal (p_mode           INTEGER,
                              p_text       OUT CLOB,
                              p_not_null       INTEGER := 0)
    IS
        --+Ryaba
        --Для полей со значением по замовчанню додаю констрейнт NOT NULL
        l_templ3   VARCHAR2 (32760)
            := 'ALTER TABLE ^<TABLENAME>^ modify (^<FIELDNAME>^ default ''^<DEFVAL>^'')';
        l_templ4   VARCHAR2 (32760)
            :=    'DECLARE'
               || CHR (10)
               || ' exc_not_null EXCEPTION;'
               || CHR (10)
               || ' PRAGMA EXCEPTION_INIT(exc_not_null,-1442);'
               || CHR (10)
               || 'BEGIN '
               || CHR (10)
               || ' execute immediate ''ALTER TABLE ^<TABLENAME>^ modify (^<FIELDNAME>^ NOT NULL)''; '
               || CHR (10)
               || ' EXCEPTION '
               || CHR (10)
               || ' WHEN exc_not_null THEN NULL; '
               || CHR (10)
               || 'END;';
        l_templ5   VARCHAR2 (32760)
            := 'UPDATE ^<TABLENAME>^ SET ^<FIELDNAME>^=''^<DEFVAL>^'' WHERE ^<FIELDNAME>^ IS NULL';
        l_src3     VARCHAR2 (32760);

        PROCEDURE Output (p_line VARCHAR2)
        IS
        BEGIN
            IF p_mode = modeOutPut
            THEN
                DBMS_OUTPUT.put_line (p_line);
            END IF;

            IF p_mode = modeClob
            THEN
                p_text := p_text || p_line || CHR (10);
            END IF;
        END;
    BEGIN
        FOR tbl IN (SELECT x.tbl_fld_name,
                           x.tbl_tbl_name,
                           x.tbl_didi,
                           x.tbl_def_value
                      FROM dic_tbl x)
        LOOP
            IF     tbl.tbl_def_value IS NOT NULL
               AND NOT (UPPER (tbl.tbl_tbl_name) = 'INSUR_CHNG_DOC') -- пока без этой таблицы YAP 2005-10-05
            THEN
                l_src3 :=
                    REPLACE (
                        REPLACE (
                            REPLACE (l_templ3,
                                     '^<TABLENAME>^',
                                     UPPER (tbl.tbl_tbl_name)),
                            '^<DEFVAL>^',
                            UPPER (tbl.tbl_def_value)),
                        '^<FIELDNAME>^',
                        UPPER (tbl.tbl_fld_name));
                Output (l_src3);
                Output ('/');

                IF NOT p_not_null = 0
                THEN
                    IF p_not_null = 1
                    THEN
                        l_src3 :=
                            REPLACE (
                                REPLACE (
                                    REPLACE (l_templ5,
                                             '^<TABLENAME>^',
                                             UPPER (tbl.tbl_tbl_name)),
                                    '^<DEFVAL>^',
                                    UPPER (tbl.tbl_def_value)),
                                '^<FIELDNAME>^',
                                UPPER (tbl.tbl_fld_name));
                        Output (l_src3);
                        Output ('/');
                    END IF;

                    l_src3 :=
                        REPLACE (
                            REPLACE (
                                REPLACE (l_templ4,
                                         '^<TABLENAME>^',
                                         UPPER (tbl.tbl_tbl_name)),
                                '^<DEFVAL>^',
                                UPPER (tbl.tbl_def_value)),
                            '^<FIELDNAME>^',
                            UPPER (tbl.tbl_fld_name));
                    Output (l_src3);
                    Output ('/');
                END IF;
            END IF;
        END LOOP;
    --exception
    --  when others
    --    then raise_application_error(-20000,'Error in IKIS_DD.GenerateCheckConstraint'||chr(10)||sqlerrm);
    END GenerateDefVal;
END IKIS_DD;
/