/* Formatted on 8/12/2025 5:55:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.RDM$DICTIONARIES_WEB
    AUTHID CURRENT_USER
IS
    -- Author  : BOGDAN
    -- Created : 07.06.2021 16:51:52
    -- Purpose : Сервіс для роботи з довідниками на кліенті

    -- контекстний довідник
    PROCEDURE GET_DIC (P_NDC_CODE VARCHAR2, RES_CUR OUT SYS_REFCURSOR);

    -- контекстний довідник з фільтрацією
    PROCEDURE GET_DIC_FILTERED (P_NDC_CODE          VARCHAR2,
                                P_XML        IN     VARCHAR2,
                                res_cur         OUT SYS_REFCURSOR);

    -- універсальний механізм пошуку данних для вибору елементу через модальне вікно з фільтрами і грідом
    PROCEDURE GET_MODAL_SELECT (P_NDC_CODE          VARCHAR2,
                                P_XML        IN     VARCHAR2,
                                RES_CUR         OUT SYS_REFCURSOR);

    -- Ініціалізація кешованих довідників
    PROCEDURE GET_CACHED_DICS (p_sys IN VARCHAR2, p_cursor OUT SYS_REFCURSOR);
END RDM$DICTIONARIES_WEB;
/


GRANT EXECUTE ON USS_NDI.RDM$DICTIONARIES_WEB TO DNET_PROXY
/

GRANT EXECUTE ON USS_NDI.RDM$DICTIONARIES_WEB TO IKIS_RBM
/

GRANT EXECUTE ON USS_NDI.RDM$DICTIONARIES_WEB TO USS_DOC
/

GRANT EXECUTE ON USS_NDI.RDM$DICTIONARIES_WEB TO USS_ESR
/

GRANT EXECUTE ON USS_NDI.RDM$DICTIONARIES_WEB TO USS_PERSON
/

GRANT EXECUTE ON USS_NDI.RDM$DICTIONARIES_WEB TO USS_RNSP
/

GRANT EXECUTE ON USS_NDI.RDM$DICTIONARIES_WEB TO USS_VISIT
/


/* Formatted on 8/12/2025 5:55:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.RDM$DICTIONARIES_WEB
IS
    -- контекстний довідник
    PROCEDURE GET_DIC (P_NDC_CODE VARCHAR2, RES_CUR OUT SYS_REFCURSOR)
    IS
        v_sql   VARCHAR2 (30000);
    BEGIN
        SELECT MAX (t.ndc_sql)
          INTO v_sql
          FROM uss_ndi.v_ndi_dict_config t
         WHERE UPPER (t.ndc_code) = UPPER (P_NDC_CODE);

        --raise_application_error(-20000, v_sql);
        IF (v_sql IS NULL)
        THEN
            raise_application_error (
                -20000,
                'Код ' || P_NDC_CODE || ' не знайдено в налаштуванннях.');
        END IF;

        OPEN RES_CUR FOR v_sql;
    END;

    FUNCTION GET_FILTERS (P_XML IN VARCHAR2)
        RETURN VARCHAR2
    IS
        v_predicate   VARCHAR2 (10000);

        FUNCTION getParamConvertFunc (P_NAME    IN VARCHAR2,
                                      P_TP      IN VARCHAR2,
                                      P_OPER    IN VARCHAR2,
                                      P_FUNC    IN VARCHAR2,
                                      P_VALUE   IN VARCHAR2)
            RETURN VARCHAR2
        IS
            l_func      VARCHAR2 (4000);
            l_is_date   VARCHAR2 (10);

            FUNCTION getDateMask
                RETURN VARCHAR2
            IS
                l_mask   VARCHAR2 (40);
            BEGIN
                IF INSTR (P_VALUE, 'Z', 1) > 0
                THEN
                    l_mask := 'yyyy-mm-dd"T"hh24:mi:ss.ff3"Z"';
                ELSE
                    l_mask := 'dd.mm.yyyy hh24:mi:ss';
                END IF;

                RETURN l_mask;
            END;
        BEGIN
            l_func :=
                CASE P_TP
                    WHEN 'date'
                    THEN
                           q'[TRUNC(CAST(to_timestamp('#VALUE#', ']'
                        || getDateMask
                        || q'[') AS DATE))]'
                    WHEN 'datetime'
                    THEN
                           q'[CAST(to_timestamp('#VALUE#', ']'
                        || getDateMask
                        || q'[') AS DATE)]'
                    WHEN 'number'
                    THEN
                        q'[to_number('#VALUE#')]'
                    WHEN 'boolean'
                    THEN
                        'CASE WHEN q''[#VALUE#]'' = ''true'' THEN ''T'' ELSE ''F'' END'
                    WHEN 'decimal'
                    THEN
                        q'[to_number(replace('#VALUE#', ',', '.'))]'
                    ELSE
                        CASE
                            WHEN P_OPER = 'IN' THEN q'[#VALUE#]'
                            ELSE q'['#VALUE#']'
                        END
                END;
            l_func :=
                REPLACE (l_func, '#VALUE#', REPLACE (p_value, '''', ''''''));
            RETURN l_func;
        END;

        FUNCTION GET_PREDICATE (P_NAME    IN VARCHAR2,
                                P_TP      IN VARCHAR2,
                                P_OPER    IN VARCHAR2,
                                P_FUNC    IN VARCHAR2,
                                P_VALUE   IN VARCHAR2,
                                P_CONST   IN VARCHAR2)
            RETURN VARCHAR2
        IS
            v_sql   VARCHAR2 (4000) := ' and #C# #O# #V#';
            l_val   VARCHAR2 (4100);
        BEGIN
            v_sql := REPLACE (v_sql, '#C#', P_FUNC || '(' || P_NAME || ')');
            v_sql := REPLACE (v_sql, '#O#', NVL (P_OPER, '='));

            l_val :=
                getParamConvertFunc (p_name,
                                     p_tp,
                                     p_oper,
                                     p_func,
                                     p_value);

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
            END IF;

            v_sql := REPLACE (v_sql, '#V#', P_FUNC || '(' || l_val || ')');
            RETURN v_sql;
        END;
    BEGIN
        FOR xx
            IN (    SELECT *
                      FROM XMLTABLE (
                               '/ArrayOfDictionaryFilterModel/DictionaryFilterModel'
                               PASSING xmltype.createXML (p_xml)
                               COLUMNS P_NAME     VARCHAR2 (100) PATH '/DictionaryFilterModel/Name',
                                       P_TP       VARCHAR2 (50) PATH '/DictionaryFilterModel/Type',
                                       P_OPER     VARCHAR2 (50) PATH '/DictionaryFilterModel/Operation',
                                       P_FUNC     VARCHAR2 (50) PATH '/DictionaryFilterModel/FieldFunc',
                                       P_VALUE    VARCHAR2 (4000) PATH '/DictionaryFilterModel/Value',
                                       P_CONST    VARCHAR2 (4000) PATH '/DictionaryFilterModel/Const'))
        LOOP
            v_predicate :=
                   v_predicate
                || GET_PREDICATE (xx.p_name,
                                  xx.p_tp,
                                  xx.p_oper,
                                  xx.p_func,
                                  xx.p_value,
                                  xx.p_const);
        END LOOP;

        RETURN v_predicate;
    END;


    -- контекстний довідник з фільтрацією
    PROCEDURE GET_DIC_FILTERED (P_NDC_CODE          VARCHAR2,
                                P_XML        IN     VARCHAR2,
                                res_cur         OUT SYS_REFCURSOR)
    IS
        v_sql     VARCHAR2 (30000);
        v_where   VARCHAR2 (10000);
    BEGIN
        SELECT MAX (t.ndc_sql)
          INTO v_sql
          FROM uss_ndi.v_ndi_dict_config t
         WHERE UPPER (t.ndc_code) = UPPER (P_NDC_CODE) AND t.ndc_tp = 'DDLB';

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

        OPEN RES_CUR FOR v_sql;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                P_NDC_CODE || '; ' || v_sql || CHR (10) || SQLERRM);
    END;

    -- універсальний механізм пошуку данних для вибору елементу через модальне вікно з фільтрами і грідом
    PROCEDURE GET_MODAL_SELECT (P_NDC_CODE          VARCHAR2,
                                P_XML        IN     VARCHAR2,
                                RES_CUR         OUT SYS_REFCURSOR)
    IS
        v_sql   VARCHAR2 (20000);
    BEGIN
        SELECT MAX (t.ndc_sql)
          INTO v_sql
          FROM uss_ndi.v_ndi_dict_config t
         WHERE UPPER (t.ndc_code) = UPPER (P_NDC_CODE) AND t.ndc_tp = 'MF';

        IF (v_sql IS NULL)
        THEN
            RETURN;                                                -- or error
        END IF;

        v_sql := v_sql || GET_FILTERS (P_XML);

        --raise_application_error(-20000, v_sql);
        OPEN RES_CUR FOR v_sql;
    END;

    PROCEDURE GET_CACHED_DICS (p_sys IN VARCHAR2, p_cursor OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_cursor FOR
            SELECT t.*
              FROM uss_ndi.v_ndi_dict_config t
             WHERE     t.ndc_is_global = 'T'
                   AND (   t.ndc_systems IS NULL
                        OR LOWER (t.ndc_systems) LIKE
                               '%' || LOWER (p_sys) || '%');
    END GET_CACHED_DICS;
BEGIN
    NULL;
END RDM$DICTIONARIES_WEB;
/