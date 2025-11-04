/* Formatted on 8/12/2025 5:55:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.DNET$DICTIONARIES_WEB
    AUTHID CURRENT_USER
IS
    -- Author  : BOGDAN
    -- Created : 07.06.2021 16:51:52
    -- Purpose : Сервіс для роботи з довідниками на кліенті

    TYPE r_Filter IS RECORD
    (
        Field         VARCHAR2 (100),
        Input_Type    VARCHAR2 (100),
        Data_Type     VARCHAR2 (100),
        Operator      VARCHAR2 (10),
        Func          VARCHAR2 (50),
        Def_Val       VARCHAR2 (4000),
        Val           VARCHAR2 (4000)
    );

    TYPE t_Filters IS TABLE OF r_Filter;

    TYPE R_DIC_FILTER IS RECORD
    (
        x_id      NUMBER,
        x_oper    VARCHAR2 (200),
        x_dt      DATE,
        x_str     VARCHAR2 (2000),
        x_int     NUMBER,
        x_sum     NUMBER
    );

    TYPE T_DIC_FILTER IS TABLE OF R_DIC_FILTER;

    FUNCTION Get_DF
        RETURN T_DIC_FILTER
        PIPELINED;

    FUNCTION ignore_apostrof (p_value IN VARCHAR2)
        RETURN VARCHAR2;

    -- контекстний довідник
    PROCEDURE GET_DIC (P_NDC_CODE          VARCHAR2,
                       P_SYSTEM     IN     VARCHAR2,
                       RES_CUR         OUT SYS_REFCURSOR);

    --
    PROCEDURE setParamConvert (p_id         IN NUMBER,
                               P_NAME       IN VARCHAR2,
                               P_DATE_TP    IN VARCHAR2,
                               P_OPER       IN VARCHAR2,
                               --P_FUNC IN VARCHAR2,
                               P_VALUE      IN VARCHAR2,
                               P_INPUT_TP   IN VARCHAR2 DEFAULT NULL);

    --
    -- контекстний довідник з фільтрацією
    PROCEDURE GET_DIC_FILTERED (P_NDC_CODE          VARCHAR2,
                                P_XML        IN     VARCHAR2,
                                P_SYSTEM     IN     VARCHAR2,
                                res_cur         OUT SYS_REFCURSOR);

    -- контекстний довідник з фільтрацією
    /*  PROCEDURE GET_DIC_FILTERED_NEW (P_NDC_CODE VARCHAR2,
                                      P_XML IN VARCHAR2,
                                      P_SYSTEM IN VARCHAR2,
                                      res_cur OUT SYS_REFCURSOR);*/

    -- налаштування модального вікна
    PROCEDURE GET_MODAL_SELECT_SETUP (P_NDC_CODE          VARCHAR2,
                                      P_SYSTEM     IN     VARCHAR2,
                                      P_FILTERS       OUT VARCHAR2,
                                      P_COLUMNS       OUT VARCHAR2);

    -- універсальний механізм пошуку данних для вибору елементу через модальне вікно з фільтрами і грідом
    PROCEDURE GET_MODAL_SELECT (P_NDC_CODE          VARCHAR2,
                                P_XML        IN     VARCHAR2,
                                P_SYSTEM     IN     VARCHAR2,
                                RES_CUR         OUT SYS_REFCURSOR);

    PROCEDURE Get_Modal_Select_V2 (p_Ndc_Code          VARCHAR2,
                                   p_Filters    IN     VARCHAR2,
                                   p_System     IN     VARCHAR2,
                                   Res_Cur         OUT SYS_REFCURSOR);

    -- Ініціалізація кешованих довідників
    PROCEDURE GET_CACHED_DICS (p_sys IN VARCHAR2, p_cursor OUT SYS_REFCURSOR);
END DNET$DICTIONARIES_WEB;
/


GRANT EXECUTE ON USS_NDI.DNET$DICTIONARIES_WEB TO DNET_PROXY
/

GRANT EXECUTE ON USS_NDI.DNET$DICTIONARIES_WEB TO II01RC_USS_NDI_INTERNAL
/

GRANT EXECUTE ON USS_NDI.DNET$DICTIONARIES_WEB TO II01RC_USS_NDI_PORTAL
/

GRANT EXECUTE ON USS_NDI.DNET$DICTIONARIES_WEB TO II01RC_USS_NDI_WEB
/

GRANT EXECUTE ON USS_NDI.DNET$DICTIONARIES_WEB TO IKIS_RBM
/

GRANT EXECUTE ON USS_NDI.DNET$DICTIONARIES_WEB TO PORTAL_PROXY
/

GRANT EXECUTE ON USS_NDI.DNET$DICTIONARIES_WEB TO USS_ESR
/

GRANT EXECUTE ON USS_NDI.DNET$DICTIONARIES_WEB TO USS_PERSON
/

GRANT EXECUTE ON USS_NDI.DNET$DICTIONARIES_WEB TO USS_RNSP
/

GRANT EXECUTE ON USS_NDI.DNET$DICTIONARIES_WEB TO USS_RPT
/

GRANT EXECUTE ON USS_NDI.DNET$DICTIONARIES_WEB TO USS_VISIT
/


/* Formatted on 8/12/2025 5:55:30 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.DNET$DICTIONARIES_WEB
IS
    DIC_FILTER   T_DIC_FILTER := T_DIC_FILTER ();

    FUNCTION ignore_apostrof (p_value IN VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN UPPER (REGEXP_REPLACE (p_value, '[`''’]', ''));
    END;

    --========================================
    FUNCTION Get_DF
        RETURN T_DIC_FILTER
        PIPELINED
    IS
    BEGIN
        IF DIC_FILTER.COUNT > 0
        THEN
            FOR i IN DIC_FILTER.FIRST .. DIC_FILTER.LAST
            LOOP
                PIPE ROW (DIC_FILTER (i));
            END LOOP;
        END IF;

        RETURN;
    END;

    --========================================

    -- контекстний довідник
    PROCEDURE GET_DIC (P_NDC_CODE          VARCHAR2,
                       P_SYSTEM     IN     VARCHAR2,
                       RES_CUR         OUT SYS_REFCURSOR)
    IS
        v_sql   VARCHAR2 (30000);
    BEGIN
        SELECT MAX (t.ndc_sql)
          INTO v_sql
          FROM uss_ndi.v_ndi_dict_config t
         WHERE     UPPER (t.ndc_code) = UPPER (P_NDC_CODE)
               AND (   t.ndc_systems IS NULL
                    OR LOWER (t.ndc_systems) LIKE '%' || P_SYSTEM || '%');

        --raise_application_error(-20000, v_sql);
        IF (v_sql IS NULL)
        THEN
            raise_application_error (
                -20000,
                   'Код '
                || P_NDC_CODE
                || ' не знайдено в налаштуванннях для системи '
                || P_SYSTEM
                || '.');
        END IF;

        v_sql := REPLACE (v_sql, '$WHERE$', '');

        --dbms_output.put_line(v_sql);
        OPEN RES_CUR FOR v_sql;
    END;

    --============================================================--
    PROCEDURE setParamConvert (p_id         IN NUMBER,
                               P_NAME       IN VARCHAR2,
                               P_DATE_TP    IN VARCHAR2,
                               P_OPER       IN VARCHAR2,
                               --P_FUNC IN VARCHAR2,
                               P_VALUE      IN VARCHAR2,
                               P_INPUT_TP   IN VARCHAR2 DEFAULT NULL)
    IS
        l_func      VARCHAR2 (4000);
        l_is_date   VARCHAR2 (10);
        DateMask    VARCHAR2 (20);

        FUNCTION getDateMask
            RETURN VARCHAR2
        IS
            l_mask   VARCHAR2 (40);
        BEGIN
            IF (REGEXP_LIKE (p_value, '^\d{4}-\d{1,2}-\d{1,2}$'))
            THEN
                l_mask := 'yyyy-mm-dd';
            ELSIF INSTR (P_VALUE, 'Z', 1) > 0
            THEN
                l_mask := 'yyyy-mm-dd"T"hh24:mi:ss.ff3"Z"';
            ELSE
                l_mask := 'dd.mm.yyyy hh24:mi:ss';
            END IF;

            RETURN l_mask;
        END;
    BEGIN
        CASE
            WHEN P_DATE_TP = 'DATE' AND P_INPUT_TP = 'DTIME'
            THEN
                DateMask := getDateMask;
                DIC_FILTER.EXTEND;
                DIC_FILTER (DIC_FILTER.COUNT).X_ID := p_id;
                DIC_FILTER (DIC_FILTER.COUNT).X_OPER := P_OPER;
                DIC_FILTER (DIC_FILTER.COUNT).X_DT :=
                    CAST (TO_TIMESTAMP (P_VALUE, DateMask) AS DATE);
            --INSERT INTO TMP_DIC_FILTER(X_ID, X_OPER, X_DT) VALUES (p_id, P_OPER, CAST(to_timestamp(P_VALUE, DateMask) AS DATE )  );
            WHEN P_DATE_TP = 'DATE'
            THEN
                DateMask := getDateMask;
                DIC_FILTER.EXTEND;
                DIC_FILTER (DIC_FILTER.COUNT).X_ID := p_id;
                DIC_FILTER (DIC_FILTER.COUNT).X_OPER := P_OPER;
                DIC_FILTER (DIC_FILTER.COUNT).X_DT :=
                    CAST (TO_TIMESTAMP (P_VALUE, DateMask) AS DATE);
            --INSERT INTO TMP_DIC_FILTER(X_ID, X_OPER, X_DT) VALUES (p_id, P_OPER, TRUNC(CAST(to_timestamp(P_VALUE, DateMask) AS DATE))  ) ;
            WHEN P_DATE_TP = 'INTEGER'
            THEN
                DIC_FILTER.EXTEND;
                DIC_FILTER (DIC_FILTER.COUNT).X_ID := p_id;
                DIC_FILTER (DIC_FILTER.COUNT).X_OPER := P_OPER;
                DIC_FILTER (DIC_FILTER.COUNT).X_INT := TO_NUMBER (P_VALUE);
            --INSERT INTO TMP_DIC_FILTER(X_ID, X_OPER, X_INT) VALUES (p_id, P_OPER, to_number(P_VALUE) ) ;
            WHEN P_DATE_TP = 'SUM'
            THEN
                DIC_FILTER.EXTEND;
                DIC_FILTER (DIC_FILTER.COUNT).X_ID := p_id;
                DIC_FILTER (DIC_FILTER.COUNT).X_OPER := P_OPER;
                DIC_FILTER (DIC_FILTER.COUNT).X_sum :=
                    TO_NUMBER (REPLACE (P_VALUE, ',', '.'));
            --INSERT INTO TMP_DIC_FILTER(X_ID, X_OPER, X_SUM) VALUES (p_id, P_OPER, to_number(replace(P_VALUE, ',', '.')) ) ;
            WHEN P_OPER IN ('IN', 'IN_NULL')
            THEN
                FOR rec
                    IN (    SELECT REGEXP_SUBSTR (P_VALUE,
                                                  '[^,]+',
                                                  1,
                                                  LEVEL)    AS X_int
                              FROM DUAL
                        CONNECT BY LEVEL <=
                                     LENGTH (
                                         REGEXP_REPLACE (P_VALUE, '[^,]*'))
                                   + 1)
                LOOP
                    DIC_FILTER.EXTEND;
                    DIC_FILTER (DIC_FILTER.COUNT).X_ID := p_id;
                    DIC_FILTER (DIC_FILTER.COUNT).X_OPER := P_OPER;
                    DIC_FILTER (DIC_FILTER.COUNT).X_INT := rec.x_int;
                END LOOP;
            /*
            INSERT INTO TMP_DIC_FILTER(X_ID, X_OPER, X_INT)
            WITH X_list AS (SELECT REGEXP_SUBSTR (P_VALUE, '[^,]+', 1, level) AS X_int
                            FROM dual
                            CONNECT BY level <= length(regexp_replace(P_VALUE,'[^,]*')) + 1
                           )
            SELECT p_id, P_OPER, X_int
            FROM X_list;*/
            ELSE
                DIC_FILTER.EXTEND;
                DIC_FILTER (DIC_FILTER.COUNT).X_ID := p_id;
                DIC_FILTER (DIC_FILTER.COUNT).X_OPER := P_OPER;
                DIC_FILTER (DIC_FILTER.COUNT).X_str := P_VALUE;
        --INSERT INTO TMP_DIC_FILTER(X_ID, X_OPER, X_STR) VALUES (p_id, P_OPER, P_VALUE) ;
        END CASE;
    END;

    --============================================================--
    FUNCTION GET_FILTERS (P_XML IN VARCHAR2)
        RETURN VARCHAR2
    IS
        v_predicate   VARCHAR2 (10000);

        FUNCTION getParamConvertFunc (P_NAME       IN VARCHAR2,
                                      P_DATE_TP    IN VARCHAR2,
                                      P_OPER       IN VARCHAR2,
                                      P_FUNC       IN VARCHAR2,
                                      P_VALUE      IN VARCHAR2,
                                      P_INPUT_TP   IN VARCHAR2 DEFAULT NULL)
            RETURN VARCHAR2
        IS
            l_func      VARCHAR2 (4000);
            l_is_date   VARCHAR2 (10);

            FUNCTION getDateMask
                RETURN VARCHAR2
            IS
                l_mask   VARCHAR2 (40);
            BEGIN
                IF (REGEXP_LIKE (p_value, '^\d{4}-\d{1,2}-\d{1,2}$'))
                THEN
                    l_mask := 'yyyy-mm-dd';
                ELSIF INSTR (P_VALUE, 'Z', 1) > 0
                THEN
                    l_mask := 'yyyy-mm-dd"T"hh24:mi:ss.ff3"Z"';
                ELSE
                    l_mask := 'dd.mm.yyyy hh24:mi:ss';
                END IF;

                RETURN l_mask;
            END;
        BEGIN
            l_func :=
                CASE
                    WHEN P_DATE_TP = 'DATE' AND P_INPUT_TP = 'DTIME'
                    THEN
                           q'[CAST(to_timestamp('#VALUE#', ']'
                        || getDateMask
                        || q'[') AS DATE)]'
                    WHEN P_DATE_TP = 'DATE'
                    THEN
                           q'[TRUNC(CAST(to_timestamp('#VALUE#', ']'
                        || getDateMask
                        || q'[') AS DATE))]'
                    WHEN P_DATE_TP = 'INTEGER'
                    THEN
                        q'[to_number('#VALUE#')]'
                    --WHEN 'STRING' AND P_INPUT_TP = 'CHECK' THEN 'CASE WHEN q''[#VALUE#]'' = ''true'' THEN ''T'' ELSE ''F'' END'
                    WHEN P_DATE_TP = 'SUM'
                    THEN
                        q'[to_number(replace('#VALUE#', ',', '.'))]'
                    ELSE
                        CASE
                            WHEN P_OPER IN ('IN', 'IN_NULL')
                            THEN
                                q'[#VALUE#]'
                            ELSE
                                q'['#VALUE#']'
                        END
                END;

            IF (P_OPER IN ('IN', 'IN_NULL'))
            THEN
                -- l_func := REPLACE(l_func, '#VALUE#', replace(TRIM(both ',' FROM TRIM(p_value)), '''', ''''''));
                l_func :=
                    REPLACE (l_func,
                             '#VALUE#',
                             TRIM (BOTH ',' FROM TRIM (p_value)));
            ELSE
                l_func :=
                    REPLACE (l_func,
                             '#VALUE#',
                             REPLACE (p_value, '''', ''''''));
            END IF;

            --raise_application_error(-20000, l_func);
            RETURN l_func;
        END;

        FUNCTION GET_PREDICATE (P_NAME       IN VARCHAR2,
                                P_TP         IN VARCHAR2,
                                P_OPER       IN VARCHAR2,
                                P_FUNC       IN VARCHAR2,
                                P_VALUE      IN VARCHAR2,
                                P_CONST      IN VARCHAR2,
                                P_INPUT_TP   IN VARCHAR2)
            RETURN VARCHAR2
        IS
            v_sql     VARCHAR2 (4000) := ' and #C# #O# #V#';
            v_sql_1   VARCHAR2 (4000) := ' and (#C# #O# #V# or #C# is null)';
            l_val     VARCHAR2 (4100);
        BEGIN
            v_sql := REPLACE (v_sql, '#C#', P_FUNC || '(' || P_NAME || ')');

            l_val :=
                getParamConvertFunc (p_name,
                                     p_tp,
                                     p_oper,
                                     p_func,
                                     p_value,
                                     P_INPUT_TP);

            IF (P_OPER = 'LIKE')
            THEN
                l_val := '''%'' || ' || l_val || ' || ''%''';
            ELSIF (    P_OPER IN ('>',
                                  '>=',
                                  '<',
                                  '<=')
                   AND P_TP = 'boolean')
            THEN
                IF (INSTR (l_val, '[true]') > 0)
                THEN
                    l_val := P_CONST;
                ELSE
                    RETURN '';
                END IF;
            ELSIF (P_oper = 'NOTNULL')
            THEN
                v_sql := REPLACE (v_sql, '#O#', 'IS');
                v_sql := REPLACE (v_sql, '#V#', 'NOT NULL');
                RETURN v_sql;
            ELSIF (P_oper = 'NULL')
            THEN
                v_sql := REPLACE (v_sql, '#O#', 'IS');
                v_sql := REPLACE (v_sql, '#V#', 'NULL');
                RETURN v_sql;
            ELSIF (P_oper = 'IN_NULL')
            THEN
                v_sql_1 :=
                    REPLACE (v_sql_1, '#C#', P_FUNC || '(' || P_NAME || ')');
                v_sql_1 := REPLACE (v_sql_1, '#O#', 'IN');
                v_sql_1 :=
                    REPLACE (v_sql_1, '#V#', P_FUNC || '(' || l_val || ')');
                RETURN v_sql_1;
            ELSIF (p_oper = 'PIPELINED')
            THEN
                RETURN P_VALUE;
            END IF;

            v_sql := REPLACE (v_sql, '#O#', NVL (p_oper, '='));
            v_sql := REPLACE (v_sql, '#V#', P_FUNC || '(' || l_val || ')');
            RETURN v_sql;
        END;
    BEGIN
        FOR xx
            IN (       SELECT *
                         FROM XMLTABLE (
                                  '/ArrayOfDictionaryFilterModel/DictionaryFilterModel'
                                  PASSING xmltype.createXML (p_xml)
                                  COLUMNS P_NAME        VARCHAR2 (100) PATH '/DictionaryFilterModel/Name',
                                          P_TP          VARCHAR2 (50) PATH '/DictionaryFilterModel/Type',
                                          P_INPUT_TP    VARCHAR2 (50) PATH '/DictionaryFilterModel/InputType',
                                          P_OPER        VARCHAR2 (50) PATH '/DictionaryFilterModel/Operation',
                                          P_FUNC        VARCHAR2 (50) PATH '/DictionaryFilterModel/FieldFunc',
                                          P_VALUE       VARCHAR2 (4000) PATH '/DictionaryFilterModel/Value',
                                          P_CONST       VARCHAR2 (4000) PATH '/DictionaryFilterModel/Const'))
        LOOP
            tools.validate_param (xx.p_name);
            tools.validate_param (xx.P_TP);
            tools.validate_param (xx.P_INPUT_TP);
            tools.validate_param (xx.P_OPER);
            tools.validate_param (xx.P_FUNC);
            tools.validate_param (xx.P_VALUE);
            tools.validate_param (xx.P_CONST);

            v_predicate :=
                   v_predicate
                || GET_PREDICATE (xx.p_name,
                                  xx.p_tp,
                                  xx.p_oper,
                                  xx.p_func,
                                  xx.p_value,
                                  xx.p_const,
                                  xx.p_input_tp);
        END LOOP;

        RETURN v_predicate;
    END;

    --============================================================--
    FUNCTION GET_FILTERS_NEW (P_XML IN VARCHAR2)
        RETURN VARCHAR2
    IS
        v_predicate   VARCHAR2 (10000);
        v_sql         VARCHAR2 (2000);
        sql_name      VARCHAR2 (2000);
        sql_oper      VARCHAR2 (2000);
        sql_val       VARCHAR2 (2000);

        CURSOR Filter IS
                   SELECT ROWNUM AS i, x.*
                     FROM XMLTABLE (
                              '/ArrayOfDictionaryFilterModel/DictionaryFilterModel'
                              PASSING xmltype.createXML (p_xml)
                              COLUMNS P_NAME        VARCHAR2 (100) PATH '/DictionaryFilterModel/Name',
                                      P_TP          VARCHAR2 (50) PATH '/DictionaryFilterModel/Type',
                                      P_INPUT_TP    VARCHAR2 (50) PATH '/DictionaryFilterModel/InputType',
                                      P_OPER        VARCHAR2 (50) PATH '/DictionaryFilterModel/Operation',
                                      P_FUNC        VARCHAR2 (50) PATH '/DictionaryFilterModel/FieldFunc',
                                      P_VALUE       VARCHAR2 (4000) PATH '/DictionaryFilterModel/Value',
                                      P_CONST       VARCHAR2 (4000) PATH '/DictionaryFilterModel/Const')
                          x;
    BEGIN
        --DELETE FROM TMP_DIC_FILTER WHERE 1=1;
        DIC_FILTER.delete;

        FOR xx IN Filter
        LOOP
            v_sql := '';

            IF xx.P_FUNC IS NULL
            THEN
                sql_name := xx.p_name;
            ELSE
                sql_name := xx.P_FUNC || '(' || xx.p_name || ')';
            END IF;

            sql_oper := '';
            sql_val := '';

            setParamConvert (xx.i,
                             xx.p_name,
                             xx.p_tp,
                             xx.p_oper,
                             xx.p_value,
                             xx.p_input_tp);

            IF xx.P_OPER = 'LIKE'
            THEN
                sql_oper := ' like ';
                sql_val := q'['%'||x_str||'%']';
            ELSIF (    xx.P_OPER IN ('>',
                                     '>=',
                                     '<',
                                     '<=')
                   AND xx.P_TP = 'boolean')
            THEN
                IF (INSTR (xx.P_VALUE, '[true]') > 0)
                THEN
                    sql_oper := xx.P_OPER;
                    sql_val := xx.P_CONST;
                ELSE
                    CONTINUE;
                END IF;
            ELSIF xx.P_oper = 'NOTNULL'
            THEN
                sql_oper := ' IS ';
                sql_val := 'NOT NULL';
            ELSIF xx.P_oper = 'NULL'
            THEN
                sql_oper := ' IS ';
                sql_val := 'NULL';
            ELSIF xx.P_oper = 'IN_NULL'
            THEN
                sql_name := sql_name || ' is null OR ' || sql_name;
                sql_oper := ' = ';
                sql_val := 'x_int';
            ELSIF xx.p_oper = 'PIPELINED'
            THEN
                RETURN xx.p_value;
            ELSE
                sql_oper :=
                    CASE xx.P_oper
                        WHEN '>' THEN ' > '
                        WHEN '>=' THEN ' >= '
                        WHEN '<' THEN ' < '
                        WHEN '<=' THEN ' <= '
                        WHEN 'IN' THEN ' = '
                        WHEN '!=' THEN ' != '
                        ELSE ' = '
                    END;

                CASE
                    WHEN xx.P_TP = 'DATE'
                    THEN
                        sql_val := 'x_dt';
                    WHEN xx.P_TP = 'INTEGER'
                    THEN
                        sql_val := 'x_int';
                    WHEN xx.P_TP = 'SUM'
                    THEN
                        sql_val := 'x_sum';
                    WHEN xx.P_oper = 'IN'
                    THEN
                        sql_val := 'x_int';
                    ELSE
                        sql_val := 'x_str';
                END CASE;
            END IF;

            v_sql :=
                   '  and exists (select 1 from table(uss_ndi.DNET$DICTIONARIES_WEB.Get_DF) where x_id = '
                || xx.i
                || ' and '
                || sql_name
                || sql_oper
                || sql_val
                || ' )';
            dbms_output_put_lines (v_sql);
            v_predicate := v_predicate || v_sql || CHR (13) || CHR (10);
        END LOOP;

        RETURN v_predicate;
    END;

    --============================================================--
    -- контекстний довідник з фільтрацією
    PROCEDURE GET_DIC_FILTERED_old (P_NDC_CODE          VARCHAR2,
                                    P_XML        IN     VARCHAR2,
                                    P_SYSTEM     IN     VARCHAR2,
                                    res_cur         OUT SYS_REFCURSOR)
    IS
        v_sql     VARCHAR2 (30000);
        v_where   VARCHAR2 (10000);
    BEGIN
        /*
            IKIS_SYS.IKIS_PROCEDURE_LOG.log( 'USS_NDI.GET_DIC_FILTERED',
                                            P_NDC_CODE,
                                            NULL,
                                            P_XML,
                                            NULL);
        */
        --raise_application_error(-20000, p_ndc_code);
        SELECT MAX (t.ndc_sql)
          INTO v_sql
          FROM uss_ndi.v_ndi_dict_config t
         WHERE     UPPER (t.ndc_code) = UPPER (P_NDC_CODE)
               AND t.ndc_tp = 'DDLB'
               AND (   t.ndc_systems IS NULL
                    OR LOWER (t.ndc_systems) LIKE '%' || P_SYSTEM || '%');

        IF (v_sql IS NULL)
        THEN
            raise_application_error (
                -20000,
                'Код ' || P_NDC_CODE || ' не знайдено в налаштуванннях.');
        END IF;

        v_where := GET_FILTERS (P_XML);

        IF (INSTR (v_sql, '$WHERE$') > 0)
        THEN
            v_sql := REPLACE (v_sql, '$WHERE$', v_where);
        ELSE
            v_sql := v_sql || v_where;
        END IF;

        --p_sql := v_sql;

        --raise_application_error(-20000, v_sql);
        OPEN RES_CUR FOR v_sql;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'P_NDC_CODE='
                || P_NDC_CODE
                || '; P_XML='
                || P_XML
                || '; SQL='
                || v_sql
                || ';'
                || CHR (10)
                || SQLERRM);
    END;

    -- контекстний довідник з фільтрацією
    PROCEDURE GET_DIC_FILTERED                                        /*_new*/
                               (P_NDC_CODE          VARCHAR2,
                                P_XML        IN     VARCHAR2,
                                P_SYSTEM     IN     VARCHAR2,
                                res_cur         OUT SYS_REFCURSOR)
    IS
        v_sql     VARCHAR2 (30000);
        v_where   VARCHAR2 (10000);
    BEGIN
        /*
            IKIS_SYS.IKIS_PROCEDURE_LOG.log( 'USS_NDI.GET_DIC_FILTERED',
                                            P_NDC_CODE,
                                            NULL,
                                            P_XML,
                                            NULL);
          */
        --raise_application_error(-20000, p_ndc_code);
        SELECT MAX (t.ndc_sql)
          INTO v_sql
          FROM uss_ndi.v_ndi_dict_config t
         WHERE     UPPER (t.ndc_code) = UPPER (P_NDC_CODE)
               AND t.ndc_tp IN ('DDLB', 'MFP')
               -- розблокувати в релізі
               AND (   t.ndc_systems IS NULL
                    OR LOWER (t.ndc_systems) LIKE '%' || P_SYSTEM || '%');

        IF (v_sql IS NULL)
        THEN
            raise_application_error (
                -20000,
                'Код ' || P_NDC_CODE || ' не знайдено в налаштуванннях.');
        END IF;

        v_where := GET_FILTERS_NEW (P_XML);

        IF (INSTR (v_sql, '$WHERE$') > 0)
        THEN
            v_sql := REPLACE (v_sql, '$WHERE$', v_where);
        ELSE
            v_sql := v_sql || v_where;
        END IF;

        --dbms_output.put_line(v_sql);
        --raise_application_error(-20000, v_sql);
        OPEN RES_CUR FOR v_sql;
    --    EXCEPTION WHEN OTHERS THEN
    --      raise_application_error(-20000, 'P_NDC_CODE=' || P_NDC_CODE ||'; P_XML='||P_XML|| '; SQL=' || v_sql || ';' || chr(10) || SQLERRM);
    END;

    --============================================================--
    -- налаштування модального вікна
    PROCEDURE GET_MODAL_SELECT_SETUP (P_NDC_CODE          VARCHAR2,
                                      P_SYSTEM     IN     VARCHAR2,
                                      P_FILTERS       OUT VARCHAR2,
                                      P_COLUMNS       OUT VARCHAR2)
    IS
    BEGIN
        SELECT COALESCE (t.ndc_filter, ' '), t.ndc_fields
          INTO P_FILTERS, P_COLUMNS
          FROM uss_ndi.v_ndi_dict_config t
         WHERE     UPPER (t.ndc_code) = UPPER (P_NDC_CODE)
               AND t.ndc_tp IN ('MF', 'MFP')
               AND (   t.ndc_systems IS NULL
                    OR LOWER (t.ndc_systems) LIKE
                           '%' || LOWER (P_SYSTEM) || '%');
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                P_NDC_CODE || CHR (10) || P_SYSTEM || CHR (10) || SQLERRM);
    END;

    -- універсальний механізм пошуку данних для вибору елементу через модальне вікно з фільтрами і грідом
    PROCEDURE GET_MODAL_SELECT (P_NDC_CODE          VARCHAR2,
                                P_XML        IN     VARCHAR2,
                                P_SYSTEM     IN     VARCHAR2,
                                RES_CUR         OUT SYS_REFCURSOR)
    IS
        v_sql   VARCHAR2 (20000);
    BEGIN
        SELECT MAX (t.ndc_sql)
          INTO v_sql
          FROM uss_ndi.v_ndi_dict_config t
         WHERE     UPPER (t.ndc_code) = UPPER (P_NDC_CODE)
               AND t.ndc_tp IN ('MF', 'MFP')
               AND (   t.ndc_systems IS NULL
                    OR LOWER (t.ndc_systems) LIKE '%' || P_SYSTEM || '%');

        IF (v_sql IS NULL)
        THEN
            RETURN;                                                -- or error
        END IF;

        IF (INSTR (v_sql, '$WHERE$') > 0)
        THEN
            v_sql := REPLACE (v_sql, '$WHERE$', GET_FILTERS (P_XML));
        ELSE
            v_sql :=
                   v_sql
                || CASE WHEN P_XML IS NOT NULL THEN GET_FILTERS (P_XML) END;
        END IF;

        --dbms_output.put_line(v_sql);

        --ikis_sysweb.ikis_debug_pipe.WriteMsg(GET_FILTERS(P_XML));
        --raise_application_error(-20000, substr(v_sql, length(v_sql) - 1000,1000));
        --raise_application_error(-20000, v_sql);
        OPEN RES_CUR FOR v_sql;
    END;

    FUNCTION Filter_Dict (p_Sql             IN OUT VARCHAR2,
                          p_Filters_Cfg     IN     VARCHAR2,
                          p_Filter_Values   IN     VARCHAR2)
        RETURN SYS_REFCURSOR
    IS
        l_Filters_Cfg   t_Filters;
        l_Filters       t_Filters;
        l_Predicate     VARCHAR2 (4000);
        l_Cur           INTEGER;
        l_Sql_Out       INTEGER;

        PROCEDURE Parse_Filters
        IS
        BEGIN
            WITH
                Filters
                AS
                    (    SELECT REGEXP_SUBSTR (p_Filters_Cfg,
                                               '[^;]+',
                                               1,
                                               LEVEL)    AS Filters
                           FROM DUAL
                     CONNECT BY REGEXP_SUBSTR (p_Filters_Cfg,
                                               '[^;]+',
                                               1,
                                               LEVEL)
                                    IS NOT NULL)
                SELECT MAX (
                           CASE
                               WHEN LEVEL = 2
                               THEN
                                   REPLACE (
                                       REGEXP_SUBSTR (
                                           REPLACE (Filters, '#', '|#|'),
                                           '[^#]+',
                                           1,
                                           LEVEL),
                                       '|',
                                       '')
                           END)    AS "Field",
                       MAX (
                           CASE
                               WHEN LEVEL = 3
                               THEN
                                   REPLACE (
                                       REGEXP_SUBSTR (
                                           REPLACE (Filters, '#', '|#|'),
                                           '[^#]+',
                                           1,
                                           LEVEL),
                                       '|',
                                       '')
                           END)    AS "InputType",
                       MAX (
                           CASE
                               WHEN LEVEL = 4
                               THEN
                                   REPLACE (
                                       REGEXP_SUBSTR (
                                           REPLACE (Filters, '#', '|#|'),
                                           '[^#]+',
                                           1,
                                           LEVEL),
                                       '|',
                                       '')
                           END)    AS "DataType",
                       MAX (
                           CASE
                               WHEN LEVEL = 5
                               THEN
                                   REPLACE (
                                       REGEXP_SUBSTR (
                                           REPLACE (Filters, '#', '|#|'),
                                           '[^#]+',
                                           1,
                                           LEVEL),
                                       '|',
                                       '')
                           END)    AS "Operation",
                       MAX (
                           CASE
                               WHEN LEVEL = 6
                               THEN
                                   REPLACE (
                                       REGEXP_SUBSTR (
                                           REPLACE (Filters, '#', '|#|'),
                                           '[^#]+',
                                           1,
                                           LEVEL),
                                       '|',
                                       '')
                           END)    AS "FieldFunc",
                       MAX (
                           CASE
                               WHEN LEVEL = 9
                               THEN
                                   REPLACE (
                                       REGEXP_SUBSTR (
                                           REPLACE (Filters, '#', '|#|'),
                                           '[^#]+',
                                           1,
                                           LEVEL),
                                       '|',
                                       '')
                           END)    AS "DefaultValue",
                       NULL        AS Val
                  BULK COLLECT INTO l_Filters_Cfg
                  FROM Filters
              GROUP BY Filters
            CONNECT BY     LEVEL <= REGEXP_COUNT (Filters, '\#') + 1
                       AND PRIOR (Filters) = Filters
                       AND PRIOR SYS_GUID () IS NOT NULL;

              SELECT f.Field,
                     f.Input_Type,
                     f.Data_Type,
                     f.Operator,
                     f.Func,
                     f.Def_Val,
                     NVL (x.Val, f.Def_Val)
                BULK COLLECT INTO l_Filters
                FROM XMLTABLE (
                         '/ArrayOfDictionaryFilterModel/DictionaryFilterModel'
                         PASSING Xmltype.Createxml (p_Filter_Values)
                         COLUMNS Field    VARCHAR2 (100) PATH '/DictionaryFilterModel/Name',
                                 Val      VARCHAR2 (4000) PATH '/DictionaryFilterModel/Value')
                     x
                     JOIN TABLE (l_Filters_Cfg) f
                         ON UPPER (f.Field) = UPPER (x.Field);
        END;

        PROCEDURE Add_Filter (p_Filter IN OUT NOCOPY r_Filter)
        IS
        BEGIN
            l_Predicate :=
                   l_Predicate
                || ' AND '
                || p_Filter.Func
                || '('
                || p_Filter.Field
                || ') '
                || p_Filter.Operator
                || ' '
                || CASE
                       WHEN p_Filter.Operator = 'LIKE'
                       THEN
                              q'['%'||]'
                           || p_Filter.Func
                           || '(:'
                           || p_Filter.Field
                           || q'[)||'%']'
                       ELSE
                           p_Filter.Func || '(:' || p_Filter.Field || ')'
                   END;
        END;

        FUNCTION Get_Date_Mask (p_Value VARCHAR2)
            RETURN VARCHAR2
        IS
            l_Mask   VARCHAR2 (40);
        BEGIN
            IF (REGEXP_LIKE (p_Value, '^\d{4}-\d{1,2}-\d{1,2}$'))
            THEN
                l_Mask := 'yyyy-mm-dd';
            ELSIF INSTR (p_Value, 'Z', 1) > 0
            THEN
                l_Mask := 'yyyy-mm-dd"T"hh24:mi:ss.ff3"Z"';
            ELSE
                l_Mask := 'dd.mm.yyyy hh24:mi:ss';
            END IF;

            RETURN l_Mask;
        END;

        PROCEDURE Bind_Var (p_Filter IN OUT NOCOPY r_Filter)
        IS
            l_Val_Num   NUMBER;
            l_Val_Dt    DATE;
        BEGIN
            IF p_Filter.Data_Type = 'STRING'
            THEN
                DBMS_SQL.Bind_Variable (l_Cur, p_Filter.Field, p_Filter.Val);
            ELSIF p_Filter.Data_Type = 'NUMBER'
            THEN
                l_Val_Num := TO_NUMBER (REPLACE (p_Filter.Val, ',', '.'));
                DBMS_SQL.Bind_Variable (l_Cur, p_Filter.Field, l_Val_Num);
            ELSIF p_Filter.Data_Type = 'DATE'
            THEN
                l_Val_Dt :=
                    CAST (
                        TO_TIMESTAMP (p_Filter.Val,
                                      Get_Date_Mask (p_Filter.Val))
                            AS DATE);

                IF p_Filter.Input_Type = 'DTIME'
                THEN
                    l_Val_Dt := TRUNC (l_Val_Dt);
                END IF;

                DBMS_SQL.Bind_Variable (l_Cur, p_Filter.Field, l_Val_Dt);
            END IF;
        END;
    BEGIN
        IF p_Filter_Values IS NOT NULL
        THEN
            Parse_Filters;

            FOR i IN 1 .. l_Filters.COUNT
            LOOP
                Add_Filter (l_Filters (i));
            END LOOP;
        END IF;

        IF (INSTR (p_Sql, '$WHERE$') > 0)
        THEN
            p_Sql := REPLACE (p_Sql, '$WHERE$', l_Predicate);
        ELSE
            p_Sql := p_Sql || l_Predicate;
        END IF;

        --Raise_Application_Error(-20000, p_Sql);

        l_Cur := DBMS_SQL.Open_Cursor;
        DBMS_SQL.Parse (l_Cur, p_Sql, DBMS_SQL.Native);

        IF p_Filter_Values IS NOT NULL
        THEN
            FOR i IN 1 .. l_Filters.COUNT
            LOOP
                Bind_Var (l_Filters (i));
            END LOOP;
        END IF;

        l_Sql_Out := DBMS_SQL.Execute (l_Cur);                        --Ignore
        RETURN DBMS_SQL.To_Refcursor (l_Cur);
    END;

    -- універсальний механізм пошуку данних для вибору елементу через модальне вікно з фільтрами і грідом
    --(без ризику SQL ін'єкцій, як у попередній версії)
    PROCEDURE Get_Modal_Select_V2 (p_Ndc_Code          VARCHAR2,
                                   p_Filters    IN     VARCHAR2,
                                   p_System     IN     VARCHAR2,
                                   Res_Cur         OUT SYS_REFCURSOR)
    IS
        l_Sql           Uss_Ndi.v_Ndi_Dict_Config.Ndc_Sql%TYPE;
        l_Filters_Cfg   Uss_Ndi.v_Ndi_Dict_Config.Ndc_Filter%TYPE;
    BEGIN
        BEGIN
            SELECT t.Ndc_Sql, t.Ndc_Filter
              INTO l_Sql, l_Filters_Cfg
              FROM Uss_Ndi.v_Ndi_Dict_Config t
             WHERE     UPPER (t.Ndc_Code) = UPPER (p_Ndc_Code)
                   AND t.Ndc_Tp = 'MF'
                   AND (   t.Ndc_Systems IS NULL
                        OR LOWER (t.Ndc_Systems) LIKE '%' || p_System || '%')
             FETCH FIRST ROW ONLY;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                Raise_Application_Error (
                    -20000,
                    'Довідник ' || p_Ndc_Code || ' не знайдено');
        END;

        IF (l_Sql IS NULL)
        THEN
            Raise_Application_Error (
                -20000,
                   'Некоректно вказано налаштування для довідника '
                || p_Ndc_Code);
        END IF;

        Res_Cur :=
            Filter_Dict (p_Sql             => l_Sql,
                         p_Filters_Cfg     => l_Filters_Cfg,
                         p_Filter_Values   => p_Filters);
    END;

    PROCEDURE GET_CACHED_DICS (p_sys IN VARCHAR2, p_cursor OUT SYS_REFCURSOR)
    IS
    BEGIN
        --raise_application_error(-20000, '-----------!-------------');
        OPEN p_cursor FOR
            SELECT t.ndc_id,
                   t.ndc_tp,
                   t.ndc_code,
                   t.ndc_sql,
                   t.ndc_fields,
                   t.ndc_filter,
                   t.ndc_caption_template,
                   t.ndc_is_client_cache,
                   t.ndc_is_server_cache,
                   t.ndc_is_global,
                   t.ndc_systems
              FROM uss_ndi.v_ndi_dict_config t
             WHERE     t.ndc_is_global = 'T'
                   AND (   t.ndc_systems IS NULL
                        OR LOWER (t.ndc_systems) LIKE
                               '%' || LOWER (p_sys) || '%');
    END GET_CACHED_DICS;
BEGIN
    NULL;
END DNET$DICTIONARIES_WEB;
/