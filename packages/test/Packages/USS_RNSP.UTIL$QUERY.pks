/* Formatted on 8/12/2025 5:57:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.UTIL$QUERY
IS
    -- Author  : MAXYM
    -- Created : 06.11.2015 16:40:17
    -- Purpose : -- Создание динамических запросов

    PROCEDURE BeginBuild (query VARCHAR2, typeName VARCHAR2, needAnd BOOLEAN);

    PROCEDURE AddCustom (tableField     VARCHAR2,
                         typeField      VARCHAR2,
                         operation      VARCHAR2,
                         VALUE          VARCHAR2,
                         converToDate   BOOLEAN:= FALSE);

    -- replace string <param> in template
    PROCEDURE AddFromTemplate (template    VARCHAR2,
                               typeField   VARCHAR2,
                               VALUE       VARCHAR2);

    PROCEDURE AddEq (tableField     VARCHAR2,
                     typeField      VARCHAR2,
                     VALUE          VARCHAR2,
                     converToDate   BOOLEAN:= FALSE);

    PROCEDURE AddNotEq (tableField     VARCHAR2,
                        typeField      VARCHAR2,
                        VALUE          VARCHAR2,
                        converToDate   BOOLEAN:= FALSE);

    PROCEDURE AddIn (tableField VARCHAR2, typeField VARCHAR2, VALUE VARCHAR2);

    PROCEDURE AddLike (tableField   VARCHAR2,
                       typeField    VARCHAR2,
                       VALUE        VARCHAR2);

    PROCEDURE AddStartWith (tableField   VARCHAR2,
                            typeField    VARCHAR2,
                            VALUE        VARCHAR2);

    PROCEDURE AddGreaterOrEq (tableField   VARCHAR2,
                              typeField    VARCHAR2,
                              VALUE        VARCHAR2);

    PROCEDURE AddLessOrEq (tableField   VARCHAR2,
                           typeField    VARCHAR2,
                           VALUE        VARCHAR2);

    PROCEDURE AddGreater (tableField   VARCHAR2,
                          typeField    VARCHAR2,
                          VALUE        VARCHAR2);

    PROCEDURE AddLess (tableField   VARCHAR2,
                       typeField    VARCHAR2,
                       VALUE        VARCHAR2);

    PROCEDURE AddBetweenStrDates (tableField          VARCHAR2,
                                  typeDateFieldFrom   VARCHAR2,
                                  typeDateFieldTo     VARCHAR2,
                                  fromValue           VARCHAR2,
                                  toValue             VARCHAR2);

    PROCEDURE AddOrderBy (fields VARCHAR2);

    PROCEDURE AddRowNum (rn PLS_INTEGER);

    PROCEDURE GetResultSql (sqlText          OUT VARCHAR2,
                            customTemplate       VARCHAR2 := NULL);
END UTIL$QUERY;
/


/* Formatted on 8/12/2025 5:58:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RNSP.UTIL$QUERY
IS
    cTeplateSimple   CONSTANT VARCHAR2 (200) := 'declare
 par %<type>% := :p1;
 cur SYS_REFCURSOR;
begin
 open cur for
   %<select>% %<where>% %<orderBy>%;
   :p2 := cur;
end;';

    cTeplateRownum   CONSTANT VARCHAR2 (200) := 'declare
 par %<type>% := :p1;
 cur SYS_REFCURSOR;
begin
 open cur for
  select * from
   (%<select>% %<where>% %<orderBy>%)
  where rownum <= %<rownum>%;
   :p2 := cur;
end;';

    cIn              CONSTANT VARCHAR2 (500) := '%<tableField>% in
  (select regexp_substr(par.%<typeField>%,''[^,]+'', 1, level) from dual
    connect by  regexp_substr(par.%<typeField>%, ''[^,]+'', 1, level)
     is not null)';

    gWhere                    VARCHAR2 (4000) := NULL;
    gOrderBy                  VARCHAR2 (200) := NULL;
    gRowNum                   PLS_INTEGER := NULL;
    gStart                    BOOLEAN := FALSE;
    gQuery                    VARCHAR2 (4000) := NULL;
    gTypeName                 VARCHAR2 (1000) := NULL;

    PROCEDURE BeginBuild (query VARCHAR2, typeName VARCHAR2, needAnd BOOLEAN)
    IS
    BEGIN
        gQuery := query;
        gTypeName := typeName;
        gWhere := NULL;
        gOrderBy := NULL;
        gRowNum := NULL;
        gStart := NOT needAnd;
    END;

    FUNCTION GetOperation
        RETURN VARCHAR2
    IS
    BEGIN
        IF gStart
        THEN
            gStart := FALSE;
            RETURN ' WHERE ';
        ELSE
            RETURN ' AND ';
        END IF;
    END;

    FUNCTION DoIt (VALUE VARCHAR2)
        RETURN BOOLEAN
    IS
    BEGIN
        RETURN VALUE IS NOT NULL;
    END;

    PROCEDURE AddCustom (tableField     VARCHAR2,
                         typeField      VARCHAR2,
                         operation      VARCHAR2,
                         VALUE          VARCHAR2,
                         converToDate   BOOLEAN:= FALSE)
    IS
    BEGIN
        IF DoIt (VALUE)
        THEN
            IF (converToDate)
            THEN
                gWhere :=
                       gWhere
                    || GetOperation ()
                    || tableField
                    || operation
                    || 'to_date(par.'
                    || typeField
                    || ',''DD.MM.YYYY'')';
            ELSE
                gWhere :=
                       gWhere
                    || GetOperation ()
                    || tableField
                    || operation
                    || 'par.'
                    || typeField;
            END IF;
        END IF;
    END;

    PROCEDURE AddFromTemplate (template    VARCHAR2,
                               typeField   VARCHAR2,
                               VALUE       VARCHAR2)
    IS
    BEGIN
        IF DoIt (VALUE)
        THEN
            gWhere :=
                   gWhere
                || GetOperation ()
                || REPLACE (template, '<param>', 'par.' || typeField);
        END IF;
    END;

    PROCEDURE AddEq (tableField     VARCHAR2,
                     typeField      VARCHAR2,
                     VALUE          VARCHAR2,
                     converToDate   BOOLEAN:= FALSE)
    IS
    BEGIN
        AddCustom (tableField,
                   typeField,
                   '=',
                   VALUE,
                   converToDate);
    END;

    PROCEDURE AddNotEq (tableField     VARCHAR2,
                        typeField      VARCHAR2,
                        VALUE          VARCHAR2,
                        converToDate   BOOLEAN:= FALSE)
    IS
    BEGIN
        AddCustom (tableField,
                   typeField,
                   '!=',
                   VALUE,
                   converToDate);
    END;

    PROCEDURE AddLike (tableField   VARCHAR2,
                       typeField    VARCHAR2,
                       VALUE        VARCHAR2)
    IS
    BEGIN
        IF DoIt (VALUE)
        THEN
            gWhere :=
                   gWhere
                || GetOperation ()
                || tableField
                || ' like ''%''||par.'
                || typeField
                || '||''%''';
        END IF;
    END;

    PROCEDURE AddStartWith (tableField   VARCHAR2,
                            typeField    VARCHAR2,
                            VALUE        VARCHAR2)
    IS
    BEGIN
        IF DoIt (VALUE)
        THEN
            gWhere :=
                   gWhere
                || GetOperation ()
                || tableField
                || ' like par.'
                || typeField
                || '||''%''';
        END IF;
    END;

    PROCEDURE AddGreaterOrEq (tableField   VARCHAR2,
                              typeField    VARCHAR2,
                              VALUE        VARCHAR2)
    IS
    BEGIN
        AddCustom (tableField,
                   typeField,
                   '>=',
                   VALUE);
    END;

    PROCEDURE AddLessOrEq (tableField   VARCHAR2,
                           typeField    VARCHAR2,
                           VALUE        VARCHAR2)
    IS
    BEGIN
        AddCustom (tableField,
                   typeField,
                   '<=',
                   VALUE);
    END;

    PROCEDURE AddGreater (tableField   VARCHAR2,
                          typeField    VARCHAR2,
                          VALUE        VARCHAR2)
    IS
    BEGIN
        AddCustom (tableField,
                   typeField,
                   '>',
                   VALUE);
    END;

    PROCEDURE AddLess (tableField   VARCHAR2,
                       typeField    VARCHAR2,
                       VALUE        VARCHAR2)
    IS
    BEGIN
        AddCustom (tableField,
                   typeField,
                   '<',
                   VALUE);
    END;

    PROCEDURE AddIn (tableField VARCHAR2, typeField VARCHAR2, VALUE VARCHAR2)
    IS
    BEGIN
        IF DoIt (VALUE)
        THEN
            gWhere :=
                   gWhere
                || GetOperation ()
                || REPLACE (REPLACE (cIn, '%<tableField>%', tableField),
                            '%<typeField>%',
                            typeField);
        END IF;
    END;

    PROCEDURE AddBetweenStrDates (tableField          VARCHAR2,
                                  typeDateFieldFrom   VARCHAR2,
                                  typeDateFieldTo     VARCHAR2,
                                  fromValue           VARCHAR2,
                                  toValue             VARCHAR2)
    IS
    BEGIN
        IF DoIt (fromValue)
        THEN
            /*      gWhere := gWhere || GetOperation() || tableField ||
            ' >= to_date(par.' || typeDateFieldFrom || ',''DD.MM.YYYY'')';*/
            AddCustom (tableField,
                       typeDateFieldFrom,
                       '>=',
                       fromValue,
                       TRUE);
        END IF;

        IF DoIt (toValue)
        THEN
            gWhere :=
                   gWhere
                || GetOperation ()
                || tableField
                || ' < (to_date(par.'
                || typeDateFieldTo
                || ',''DD.MM.YYYY'')+1)';
        END IF;
    END;

    PROCEDURE AddOrderBy (fields VARCHAR2)
    IS
    BEGIN
        gOrderBy := ' order by ' || fields;
    END;

    PROCEDURE AddRowNum (rn PLS_INTEGER)
    IS
    BEGIN
        gRowNum := rn;
    END;

    PROCEDURE GetResultSql (sqlText          OUT VARCHAR2,
                            customTemplate       VARCHAR2 := NULL)
    IS
        lTemplate   VARCHAR2 (4000) := NULL;
    BEGIN
        IF customTemplate IS NULL
        THEN
            IF (gRowNum IS NULL)
            THEN
                lTemplate := cTeplateSimple;
            ELSE
                lTemplate := REPLACE (cTeplateRownum, '%<rownum>%', gRowNum);
            END IF;
        ELSE
            lTemplate := customTemplate;
        END IF;

        lTemplate := REPLACE (lTemplate, '%<type>%', gTypeName);
        lTemplate := REPLACE (lTemplate, '%<select>%', gQuery);

        sqlText :=
            REPLACE (REPLACE (lTemplate, '%<where>%', gwhere),
                     '%<orderBy>%',
                     gOrderBy);
        DBMS_OUTPUT.put_line (sqlText);
    END;
END UTIL$QUERY;
/