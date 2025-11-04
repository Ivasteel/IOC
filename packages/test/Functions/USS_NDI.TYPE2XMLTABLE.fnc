/* Formatted on 8/12/2025 5:56:03 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION USS_NDI.Type2xmltable (
    p_Pkg_Name     VARCHAR2,
    p_Type_Name    VARCHAR2,
    p_Camel_Case   BOOLEAN DEFAULT FALSE)
    RETURN VARCHAR2
    RESULT_CACHE
IS
    l_Sql              VARCHAR2 (32000);
    l_Typecode         VARCHAR2 (100);
    l_Elem_Type_Pkg    VARCHAR2 (200);
    l_Elem_Type_Name   VARCHAR2 (200);
    l_Xpath            VARCHAR2 (10);

    --Получение перечня полей типа record для парсинга
    FUNCTION Get_Rec_Columns (p_Pkg_Name VARCHAR2, p_Type_Name VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Columns      VARCHAR2 (32000);
        l_Camel_Case   NUMBER := CASE WHEN p_Camel_Case THEN 1 ELSE 0 END;
    BEGIN
        SELECT LISTAGG (
                      a.Attr_Name
                   || ' '
                   || a.Attr_Type_Name
                   || CASE
                          WHEN a.LENGTH IS NOT NULL
                          THEN
                              '(' || a.LENGTH || ')'
                      END
                   || ' Path '
                   || q'[']'
                   || CASE l_Camel_Case
                          WHEN 1 THEN --Преобразование PASCAL_CASE в CamelCase
                                      INITCAP (a.Attr_Name)
                          ELSE a.Attr_Name
                      END
                   || q'[',]',
                   CHR (13) || CHR (10))
               WITHIN GROUP (ORDER BY a.Attr_No)
          INTO l_Columns
          FROM User_Plsql_Type_Attrs a
         WHERE a.Package_Name = p_Pkg_Name AND a.Type_Name = p_Type_Name;

        RETURN RTRIM (l_Columns, ',');
    END Get_Rec_Columns;
BEGIN
    --Получаем код типа
    SELECT t.Typecode
      INTO l_Typecode
      FROM User_Plsql_Types t
     WHERE     t.Type_Name = UPPER (p_Type_Name)
           AND t.Package_Name = UPPER (p_Pkg_Name);

    IF l_Typecode = 'COLLECTION'
    THEN
        --Если тип является коллекцией, то вычитываем название типа элемена коллекции
        SELECT c.Elem_Type_Package, c.Elem_Type_Name
          INTO l_Elem_Type_Pkg, l_Elem_Type_Name
          FROM User_Plsql_Coll_Types c
         WHERE     c.Type_Name = UPPER (p_Type_Name)
               AND c.Package_Name = UPPER (p_Pkg_Name);

        l_Xpath := q'['/*/*']';
    ELSE
        l_Xpath := q'['/*']';
    END IF;

    l_Sql :=
           'SELECT * FROM XMLTABLE('
        || l_Xpath
        || ' passing xmltype(:p_xml) columns '
        || Get_Rec_Columns (
               p_Pkg_Name    => NVL (l_Elem_Type_Pkg, p_Pkg_Name),
               p_Type_Name   => NVL (l_Elem_Type_Name, p_Type_Name))
        || ')';

    --Dbms_Output.Put_Line(l_Sql);
    RETURN l_Sql;
END Type2xmltable;
/
