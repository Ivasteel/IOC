/* Formatted on 8/12/2025 6:10:54 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION IKIS_RBM.Type2xmltable (
    p_Pkg_Name    VARCHAR2,
    p_Type_Name   VARCHAR2,
    p_Date_Fmt    VARCHAR2 DEFAULT 'dd.mm.yyyy hh24:mi:ss',
    p_Version     VARCHAR2 DEFAULT NULL --Для сбросу кешу (при зміні PL/SQL типу -> зміняти версію)
                                       )
    RETURN VARCHAR2
    RESULT_CACHE
IS
    l_Typecode    VARCHAR2 (100);
    l_Functions   VARCHAR2 (4000)
        := q'[FUNCTION Get_Node(p_Attr IN VARCHAR2) RETURN Xmldom.Domnode IS
BEGIN
FOR i IN 0 .. l_Len - 1
LOOP
DECLARE l_Item Xmldom.Domnode;
BEGIN
l_Item := Xmldom.Item(l_Child, i);
IF REPLACE(Upper(Xmldom.Getnodename(l_Item)), '_') = REPLACE(p_Attr, '_') THEN
RETURN Xmldom.Getfirstchild(l_Item);
END IF;
END;
END LOOP;
RETURN NULL;
END;
PROCEDURE Throw(p_Attr VARCHAR2, p_Err VARCHAR2) IS
BEGIN
  Raise_Application_Error(-20000, 'Помилка парсингу поля ' || p_Attr || ': ' || p_Err);
END;
PROCEDURE Set_Str(p_Attr IN VARCHAR2,p_Val OUT VARCHAR2) IS
l_Node Xmldom.Domnode;
BEGIN
l_Node := Get_Node(p_Attr);
p_Val := To_Char(Xmldom.Getnodevalue(l_Node));
EXCEPTION
WHEN OTHERS THEN Throw(p_Attr, SQLERRM);
END;
PROCEDURE Set_Dt(p_Attr IN VARCHAR2,p_Val OUT DATE) IS
l_Node Xmldom.Domnode;
BEGIN
l_Node := Get_Node(p_Attr);
IF upper(':date_fmt') LIKE '%FF' THEN
p_Val := To_Timestamp(Xmldom.Getnodevalue(l_Node), ':date_fmt');
ELSE
p_Val := To_Date(Xmldom.Getnodevalue(l_Node), ':date_fmt');
END IF;
EXCEPTION
WHEN OTHERS THEN Throw(p_Attr, SQLERRM);
END;
PROCEDURE Set_Num(p_Attr IN VARCHAR2,p_Val OUT NUMBER) IS
l_Node Xmldom.Domnode;
BEGIN
l_Node := Get_Node(p_Attr);
p_Val := To_Number(Xmldom.Getnodevalue(l_Node));
EXCEPTION
WHEN OTHERS THEN Throw(p_Attr, SQLERRM);
END;
PROCEDURE Set_Clob(p_Attr IN VARCHAR2,p_Val OUT CLOB) IS
l_Node Xmldom.Domnode;
BEGIN
l_Node := Get_Node(p_Attr);
Dbms_Lob.Createtemporary(p_Val, TRUE);
Xmldom.Writetoclob(n => l_Node, Cl => p_Val);
EXCEPTION
WHEN OTHERS THEN Throw(p_Attr, SQLERRM);
END;
FUNCTION Node2clob(p_Attr IN VARCHAR2) RETURN CLOB IS
l_Clob CLOB;
BEGIN
FOR i IN 0 .. l_Len - 1
LOOP
DECLARE
l_Item Xmldom.Domnode;
BEGIN
l_Item := Xmldom.Item(l_Child, i);
IF REPLACE(Upper(Xmldom.Getnodename(l_Item)), '_') = REPLACE(p_Attr, '_') THEN
Dbms_Lob.Createtemporary(l_Clob, TRUE);
Xmldom.Writetoclob(l_Item, l_Clob);
RETURN l_Clob;
END IF;
END;
END LOOP;
RETURN NULL;
END;]';

    FUNCTION Get_Fields (p_Pkg_Name VARCHAR2, p_Type_Name VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Fields   VARCHAR2 (32000);
    BEGIN
        SELECT LISTAGG (
                   CASE
                       WHEN a.Attr_Type_Name = 'VARCHAR2'
                       THEN
                              'Set_Str('''
                           || a.Attr_Name
                           || ''', l_rec.'
                           || a.Attr_Name
                           || ');'
                       WHEN a.Attr_Type_Name = 'NUMBER'
                       THEN
                              'Set_Num('''
                           || a.Attr_Name
                           || ''', l_rec.'
                           || a.Attr_Name
                           || ');'
                       WHEN a.Attr_Type_Name = 'CLOB'
                       THEN
                              'Set_Clob('''
                           || a.Attr_Name
                           || ''', l_rec.'
                           || a.Attr_Name
                           || ');'
                       WHEN a.Attr_Type_Name = 'DATE'
                       THEN
                              'Set_Dt('''
                           || a.Attr_Name
                           || ''', l_rec.'
                           || a.Attr_Name
                           || ');'
                       WHEN a.Attr_Type_Package IS NOT NULL
                       THEN
                              'EXECUTE IMMEDIATE Type2xmltable('''
                           || a.Attr_Type_Package
                           || ''','''
                           || a.Attr_Type_Name
                           || ''', '''
                           || p_Date_Fmt
                           || ''') USING IN Node2clob('''
                           || a.Attr_Name
                           || '''), OUT l_rec.'
                           || a.Attr_Name
                           || ';'
                   END,
                   CHR (13) || CHR (10))
               WITHIN GROUP (ORDER BY a.Attr_No)
          INTO l_Fields
          FROM User_Plsql_Type_Attrs a
         WHERE     a.Package_Name = UPPER (p_Pkg_Name)
               AND a.Type_Name = UPPER (p_Type_Name);

        RETURN l_Fields;
    END;

    ----------------------------------------------------------------------
    --            ГЕНЕРАЦІЯ ЗАПИТУ ДЛЯ ПАРСИНГУ У RECORD
    ----------------------------------------------------------------------
    FUNCTION Get_Record_Sql (p_Pkg_Name VARCHAR2, p_Type_Name VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Sql   VARCHAR2 (32000);
    BEGIN
        l_Sql :=
            q'[DECLARE
p Xmlparser.Parser;l_Doc Xmldom.Domdocument;l_Root Xmldom.Domelement;l_Child Xmldom.Domnodelist;l_Len NUMBER;l_rec :type;
:functions
BEGIN
IF :P_XML IS NULL THEN RETURN; END IF;
p := Xmlparser.Newparser;
Xmlparser.Parseclob(p, :p_Xml);
l_Doc := Xmlparser.Getdocument(p);
l_Root := Xmldom.Getdocumentelement(l_Doc);
l_Child := Xmldom.Getchildrenbytagname(l_Root, '*');
l_Len := Xmldom.Getlength(l_Child);
:fields
:p_rec := l_rec;
END;]';

        l_Sql := REPLACE (l_Sql, ':type', p_Pkg_Name || '.' || p_Type_Name);
        l_Sql := REPLACE (l_Sql, ':functions', l_Functions);
        l_Sql :=
            REPLACE (l_Sql, ':fields', Get_Fields (p_Pkg_Name, p_Type_Name));
        l_Sql := REPLACE (l_Sql, ':date_fmt', p_Date_Fmt);
        RETURN l_Sql;
    END;

    ----------------------------------------------------------------------
    --            ГЕНЕРАЦІЯ ЗАПИТУ ДЛЯ ПАРСИНГУ В COLLECTION
    ----------------------------------------------------------------------
    FUNCTION Get_Collection_Sql (p_Pkg_Name VARCHAR2, p_Type_Name VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Sql              VARCHAR2 (32000);
        l_Elem_Type_Pkg    VARCHAR2 (200);
        l_Elem_Type_Name   VARCHAR2 (200);
    BEGIN
        --Если тип является коллекцией, то вычитываем название типа элемена коллекции
        SELECT c.Elem_Type_Package, c.Elem_Type_Name
          INTO l_Elem_Type_Pkg, l_Elem_Type_Name
          FROM User_Plsql_Coll_Types c
         WHERE     c.Type_Name = UPPER (p_Type_Name)
               AND c.Package_Name = UPPER (p_Pkg_Name);

        IF l_Elem_Type_Pkg IS NOT NULL
        THEN
            l_Sql :=
                q'[
DECLARE
l_coll :coltype;p Xmlparser.Parser;l_Doc Xmldom.Domdocument;l_Root Xmldom.Domelement;l_Child_List Xmldom.Domnodelist;
BEGIN
IF :P_XML IS NULL THEN RETURN; END IF;
p := Xmlparser.Newparser;
Xmlparser.Parseclob(p, :p_Xml);
l_Doc := Xmlparser.Getdocument(p);
l_Root := Xmldom.Getdocumentelement(l_Doc);
l_Child_List := Xmldom.Getchildrenbytagname(l_Root, '*');
l_coll := :coltype();
FOR i IN 0 .. Xmldom.Getlength(l_Child_List) - 1
LOOP
DECLARE
l_Item Xmldom.Domnode;l_Child Xmldom.Domnodelist;l_Len NUMBER;l_rec :rectype;
:functions
BEGIN
l_coll.Extend();
l_Item := Xmldom.Item(l_Child_List, i);
l_Child := Xmldom.Getchildnodes(l_Item);
l_Len := Xmldom.Getlength(l_Child);
:fields
l_coll(i+1) := l_rec;
END;
END LOOP;
:l_coll := l_coll;
END;]';
            l_Sql :=
                REPLACE (l_Sql, ':coltype', p_Pkg_Name || '.' || p_Type_Name);
            l_Sql :=
                REPLACE (l_Sql,
                         ':rectype',
                         l_Elem_Type_Pkg || '.' || l_Elem_Type_Name);
            l_Sql := REPLACE (l_Sql, ':functions', l_Functions);
            l_Sql :=
                REPLACE (l_Sql,
                         ':fields',
                         Get_Fields (l_Elem_Type_Pkg, l_Elem_Type_Name));
            l_Sql := REPLACE (l_Sql, ':date_fmt', p_Date_Fmt);
        ELSE
            l_Sql :=
                q'[
DECLARE
l_coll :coltype;p Xmlparser.Parser;l_Doc Xmldom.Domdocument;l_Root Xmldom.Domelement;l_Child_List Xmldom.Domnodelist;
BEGIN
p := Xmlparser.Newparser;
Xmlparser.Parseclob(p, :p_Xml);
l_Doc := Xmlparser.Getdocument(p);
l_Root := Xmldom.Getdocumentelement(l_Doc);
l_Child_List := Xmldom.Getchildrenbytagname(l_Root, '*');
l_coll := :coltype();
FOR i IN 0 .. Xmldom.Getlength(l_Child_List) - 1
LOOP
DECLARE
l_Item Xmldom.Domnode;
BEGIN
l_coll.Extend();
l_Item := Xmldom.Item(l_Child_List, i);
l_Coll(i + 1) := Xmldom.Getnodevalue(Xmldom.Getfirstchild(l_Item));
END;
END LOOP;
:l_coll := l_coll;
END;]';
        END IF;

        RETURN l_Sql;
    END;
----------------------------------------------------------------------
--            ГЕНЕРАЦІЯ ЗАПИТУ ДЛЯ ПАРСИНГУ
----------------------------------------------------------------------
BEGIN
    --Получаем код типа
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
END Type2xmltable;
/
