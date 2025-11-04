/* Formatted on 8/12/2025 5:50:16 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION USS_ESR.Type2xmltable (
    p_Pkg_Name       VARCHAR2,
    p_Type_Name      VARCHAR2,
    p_Camel_Case     BOOLEAN DEFAULT FALSE,
    p_Clob_Input     BOOLEAN DEFAULT TRUE,
    p_Has_Roor_Tag   BOOLEAN DEFAULT TRUE --Если указать false - исправляет путь при парсинге коллекций(.net core криво сериализует поля типа список/массив и не обрамляет их элементы одним тегом)
                                         )
    RETURN VARCHAR2
    RESULT_CACHE
IS
    l_Sql                   VARCHAR2 (32000);
    l_Typecode              VARCHAR2 (100);
    l_Elem_Type_Pkg         VARCHAR2 (200);
    l_Elem_Type_Name        VARCHAR2 (200);
    l_Xpath                 VARCHAR2 (10);
    l_Clob_Input            NUMBER;

    l_Columns               VARCHAR2 (32000);
    l_Columns_name          VARCHAR2 (32000);

    c_Xml_Dt_Fmt   CONSTANT VARCHAR2 (30) := 'YYYY-MM-DD"T"HH24:MI:SS';

    FUNCTION Bool2int (p_Bool BOOLEAN)
        RETURN NUMBER
    IS
    BEGIN
        RETURN CASE WHEN p_Bool THEN 1 ELSE 0 END;
    END;

    FUNCTION get_value (p_Attr_Name IN VARCHAR2, p_Attr_Type IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_res          VARCHAR2 (500);
        l_Camel_Case   NUMBER := Bool2int (p_Camel_Case);
    BEGIN
        l_res :=
            CASE l_Camel_Case
                WHEN 1 THEN --Преобразование PASCAL_CASE в CamelCase
                            INITCAP (p_Attr_Name)
                ELSE p_Attr_Name
            END;

        IF (p_attr_type = 'DATE')
        THEN
            l_res :=
                   'to_date('
                || l_res
                || ', '''
                || c_Xml_Dt_Fmt
                || ''') as '
                || l_res;
        END IF;

        RETURN l_res;
    END;

    --Получение перечня полей типа record для парсинга
    FUNCTION Get_Rec_Columns1 (p_Pkg_Name VARCHAR2, p_Type_Name VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Columns      VARCHAR2 (32000);
        l_Camel_Case   NUMBER := Bool2int (p_Camel_Case);
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
         WHERE     a.Package_Name = UPPER (p_Pkg_Name)
               AND a.Type_Name = UPPER (p_Type_Name);


        RETURN RTRIM (l_Columns, ',');
    END Get_Rec_Columns1;

    --Получение перечня полей типа record для парсинга
    PROCEDURE Get_Rec_Columns (p_Pkg_Name VARCHAR2, p_Type_Name VARCHAR2)
    IS
        l_Camel_Case   NUMBER := Bool2int (p_Camel_Case);
    BEGIN
        FOR xx
            IN (  SELECT a.*
                    FROM User_Plsql_Type_Attrs a
                   WHERE     a.Package_Name = UPPER (p_Pkg_Name)
                         AND a.Type_Name = UPPER (p_Type_Name)
                ORDER BY a.attr_no)
        LOOP
            l_columns :=
                   l_columns
                || xx.Attr_Name
                || ' '
                || CASE
                       WHEN xx.Attr_Type_Name = 'DATE' THEN 'varchar2(30)'
                       ELSE xx.Attr_Type_Name
                   END
                || CASE
                       WHEN xx.LENGTH IS NOT NULL
                       THEN
                           '(' || xx.LENGTH || ')'
                   END
                || ' Path '
                || q'[']'
                || CASE l_Camel_Case
                       WHEN 1 THEN --Преобразование PASCAL_CASE в CamelCase
                                   INITCAP (xx.Attr_Name)
                       ELSE xx.Attr_Name
                   END
                || q'[',]'
                || CHR (13)
                || CHR (10);
            l_Columns_name :=
                   l_Columns_name
                || get_value (xx.attr_name, xx.attr_type_name)
                || ',';
        END LOOP;

        l_Columns_name := RTRIM (l_Columns_name, ',');
        l_Columns := RTRIM (l_Columns, ',' || CHR (13) || CHR (10));
    --RETURN Rtrim(l_Columns, ',');
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

        IF p_Has_Roor_Tag
        THEN
            l_Xpath := q'['/*/*']';
        ELSE
            l_Xpath := q'['/*']';
        END IF;
    ELSE
        l_Xpath := q'['/*']';
    END IF;

    l_Clob_Input := Bool2int (p_Clob_Input);
    Get_Rec_Columns (p_Pkg_Name    => NVL (l_Elem_Type_Pkg, p_Pkg_Name),
                     p_Type_Name   => NVL (l_Elem_Type_Name, p_Type_Name));
    /* l_Sql := 'SELECT * FROM XMLTABLE(' || l_Xpath || ' passing ' || CASE l_Clob_Input
               WHEN 1 THEN
                'xmltype(:p_xml)'
               ELSE
                ':p_xml'
              END || ' columns ' ||
              Get_Rec_Columns1(p_Pkg_Name => Nvl(l_Elem_Type_Pkg, p_Pkg_Name), p_Type_Name => Nvl(l_Elem_Type_Name, p_Type_Name)) || ')';
    */
    l_Sql :=
           'SELECT '
        || l_Columns_name
        || ' FROM XMLTABLE('
        || l_Xpath
        || ' passing '
        || CASE l_Clob_Input WHEN 1 THEN 'xmltype(:p_xml)' ELSE ':p_xml' END
        || ' columns '
        || l_Columns
        || ')';

    --raise_application_error(-20000, l_Sql);
    --Dbms_Output.Put_Line(l_Sql);
    RETURN l_Sql;
END Type2xmltable;
/
