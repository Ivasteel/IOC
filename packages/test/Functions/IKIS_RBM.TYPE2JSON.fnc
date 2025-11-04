/* Formatted on 8/12/2025 6:10:54 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION IKIS_RBM.Type2json (
    p_Pkg_Name    VARCHAR2,
    p_Type_Name   VARCHAR2,
    p_Date_Fmt    VARCHAR2 DEFAULT 'dd.mm.yyyy hh24:mi:ss',
    p_Case        VARCHAR2 DEFAULT NULL,
    p_Version     VARCHAR2 DEFAULT NULL --Для сбросу кешу (при зміні PL/SQL типу -> зміняти версію)
                                       )
    RETURN VARCHAR2
    RESULT_CACHE
IS
    l_Typecode   VARCHAR2 (100);

    ----------------------------------------------------------------------
    --          ГЕНЕРАЦІЯ ЗАПИТУ ДЛЯ СЕРИАЛІЗАЦІЇ RECORD В JSON
    ----------------------------------------------------------------------
    FUNCTION Get_Record_Sql (p_Pkg_Name VARCHAR2, p_Type_Name VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Sql                VARCHAR2 (32000);
        l_Fields             VARCHAR2 (32000);
        l_Variables          VARCHAR2 (32000);
        l_Variables_Values   VARCHAR2 (32000);
    BEGIN
        l_Sql :=
            q'<DECLARE
l_json CLOB;
l_rec :type;
:variables
FUNCTION ValS(p_val VARCHAR2) RETURN VARCHAR2 IS
BEGIN
RETURN '"'||REPLACE(REPLACE(REPLACE(REPLACE(p_val,'\','\\'),'"','\"'),Chr(13),'\r'),Chr(10),'\n')||'"';
END;
FUNCTION ValN(p_val NUMBER) RETURN VARCHAR2 IS
BEGIN
RETURN Regexp_Replace(Nvl(REPLACE(To_Char(p_val), ',', '.'), 'null'), '^[.]', '0.');
END;
FUNCTION ValD(p_val DATE) RETURN VARCHAR2 IS
BEGIN
IF p_val IS NULL THEN RETURN 'null'; end if;
RETURN '"'||to_char(p_val,':date_fmt')||'"';
END;
FUNCTION ValB(p_val BOOLEAN) RETURN VARCHAR2 IS
BEGIN
RETURN CASE WHEN p_val THEN 'true' WHEN NOT p_val THEN 'false' ELSE 'null' END;
END;
BEGIN
l_rec:=:p_rec; :variable_values :p_json:='{:fields}';
END;>';

        --todo: додати окрему ф-ю екранування для CLOB
        SELECT LISTAGG (
                   CASE
                       WHEN a.Attr_Type_Package IS NOT NULL
                       THEN
                           'l_var_' || a.Attr_Name || ' CLOB;'
                   END,
                   '')
               WITHIN GROUP (ORDER BY a.Attr_No),
               LISTAGG (
                   CASE
                       WHEN a.Attr_Type_Package IS NOT NULL
                       THEN
                              'EXECUTE IMMEDIATE Type2json('''
                           || a.Attr_Type_Package
                           || ''', '''
                           || a.Attr_Type_Name
                           || ''', '''
                           || p_Date_Fmt
                           || ''', '''
                           || p_Case
                           || ''') USING IN l_rec."'
                           || a.Attr_Name
                           || '", OUT l_var_'
                           || a.Attr_Name
                           || ';'
                   END,
                   '')
               WITHIN GROUP (ORDER BY a.Attr_No),
               LISTAGG (
                   CASE
                       WHEN a.Attr_Type_Name IN ('VARCHAR2', 'CLOB')
                       THEN
                              '"'
                           || Field_Name
                           || '": ''||ValS(l_rec."'
                           || a.Attr_Name
                           || '")||'''
                       WHEN a.Attr_Type_Name = 'NUMBER'
                       THEN
                              '"'
                           || Field_Name
                           || '": ''||ValN(l_rec."'
                           || a.Attr_Name
                           || '")||'''
                       WHEN a.Attr_Type_Name = 'DATE'
                       THEN
                              '"'
                           || Field_Name
                           || '": ''||ValD(l_rec."'
                           || a.Attr_Name
                           || '")||'''
                       WHEN a.Attr_Type_Name = 'PL/SQL BOOLEAN'
                       THEN
                              '"'
                           || Field_Name
                           || '": ''||ValB(l_rec."'
                           || a.Attr_Name
                           || '")||'''
                       WHEN a.Attr_Type_Package IS NOT NULL
                       THEN
                              '"'
                           || Field_Name
                           || '": ''||l_var_'
                           || a.Attr_Name
                           || '||'''
                   END,
                   ',')
               WITHIN GROUP (ORDER BY a.Attr_No)
          INTO l_Variables, l_Variables_Values, l_Fields
          FROM (SELECT a.*,
                       CASE
                           WHEN p_Case IS NULL
                           THEN
                               a.Attr_Name
                           WHEN p_Case = 'lowerCamel'
                           THEN
                               (SELECT    LOWER (SUBSTR (Str, 1, 1))
                                       || SUBSTR (Str, 2, LENGTH (Str))
                                  FROM (SELECT REPLACE (
                                                   INITCAP (a.Attr_Name),
                                                   '_')    AS Str
                                          FROM DUAL))
                       END    AS Field_Name
                  FROM User_Plsql_Type_Attrs a
                 WHERE     a.Package_Name = UPPER (p_Pkg_Name)
                       AND a.Type_Name = UPPER (p_Type_Name)) a;

        l_Sql := REPLACE (l_Sql, ':type', p_Pkg_Name || '.' || p_Type_Name);
        l_Sql := REPLACE (l_Sql, ':variables', l_Variables);
        l_Sql := REPLACE (l_Sql, ':variable_values', l_Variables_Values);
        l_Sql := REPLACE (l_Sql, ':fields', l_Fields);
        l_Sql := REPLACE (l_Sql, ':date_fmt', p_Date_Fmt);
        RETURN l_Sql;
    END;

    ----------------------------------------------------------------------
    --          ГЕНЕРАЦІЯ ЗАПИТУ ДЛЯ СЕРИАЛІЗАЦІЇ COLLECTION В JSON
    ----------------------------------------------------------------------
    FUNCTION Get_Collection_Sql (p_Pkg_Name VARCHAR2, p_Type_Name VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Rec_Sql          VARCHAR2 (32000);
        l_Coll_Sql         VARCHAR2 (32000);
        l_Elem_Type_Pkg    VARCHAR2 (200);
        l_Elem_Type_Name   VARCHAR2 (200);
    BEGIN
        --Якщо тип є колекцією, то вичитуємо назву типа елементу колекції
        SELECT c.Elem_Type_Package, c.Elem_Type_Name
          INTO l_Elem_Type_Pkg, l_Elem_Type_Name
          FROM User_Plsql_Coll_Types c
         WHERE     c.Type_Name = UPPER (p_Type_Name)
               AND c.Package_Name = UPPER (p_Pkg_Name);

        IF l_Elem_Type_Pkg IS NOT NULL
        THEN
            l_Rec_Sql := Get_Record_Sql (l_Elem_Type_Pkg, l_Elem_Type_Name);
            l_Rec_Sql :=
                REPLACE (l_Rec_Sql, 'l_rec:=:p_rec;', 'l_rec:=l_col(i);');
            l_Rec_Sql :=
                REPLACE (l_Rec_Sql,
                         ':p_json:=',
                         q'<l_json_arr:=l_json_arr||','||>');
            l_Coll_Sql :=
                q'<
DECLARE
l_col :pkg_name.:type_name:=:p_col;
l_json_arr CLOB;
BEGIN
l_json_arr:='';
IF l_col IS NOT NULL AND l_col.count>0 THEN
FOR i in 1..l_col.count
LOOP
:rec_sql
END LOOP;
END IF;
:p_json:='['||Dbms_Lob.Substr(l_json_arr,dbms_lob.getlength(l_json_arr),2)||']';
END;>';
            l_Coll_Sql := REPLACE (l_Coll_Sql, ':pkg_name', p_Pkg_Name);
            l_Coll_Sql := REPLACE (l_Coll_Sql, ':type_name', p_Type_Name);
            l_Coll_Sql := REPLACE (l_Coll_Sql, ':rec_sql', l_Rec_Sql);
        ELSE
            NULL;
        END IF;

        RETURN l_Coll_Sql;
    END;
BEGIN
    --Отримуємо код типа
    SELECT t.Typecode
      INTO l_Typecode
      FROM User_Plsql_Types t
     WHERE     t.Type_Name = UPPER (p_Type_Name)
           AND t.Package_Name = UPPER (p_Pkg_Name);

    IF l_Typecode = 'COLLECTION'
    THEN
        RETURN Get_Collection_Sql (p_Pkg_Name, p_Type_Name);
    ELSE
        RETURN Get_Record_Sql (p_Pkg_Name, p_Type_Name);
    END IF;
END Type2json;
/
