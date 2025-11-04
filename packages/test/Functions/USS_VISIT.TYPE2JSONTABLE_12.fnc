/* Formatted on 8/12/2025 6:00:10 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION USS_VISIT.Type2jsontable_12 (
    p_Pkg_Name    VARCHAR2,
    p_Type_Name   VARCHAR2,
    p_Date_Fmt    VARCHAR2 DEFAULT 'dd.mm.yyyy hh24:mi:ss')
    RETURN VARCHAR2
    RESULT_CACHE
IS
    l_Typecode   VARCHAR2 (100);

    ----------------------------------------------------------------------
    --            ГЕНЕРАЦІЯ ЗАПИТУ ДЛЯ ПАРСИНГУ У RECORD
    ----------------------------------------------------------------------
    FUNCTION Get_Record_Sql (p_Pkg_Name VARCHAR2, p_Type_Name VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Fields   VARCHAR2 (32000);
        l_Sql      VARCHAR2 (32000);
    BEGIN
        l_Sql :=
            q'[
  DECLARE
    l_jo   Json_Object_t;
    l_keys Json_Key_List;
    l_rec  :type;

    FUNCTION Attr2key(p_Attr_Name IN VARCHAR2) RETURN VARCHAR2 IS
      l_Key VARCHAR2(100);
    BEGIN
      SELECT MAX(Column_Value)
        INTO l_Key
        FROM TABLE(l_keys)
       WHERE REPLACE(REPLACE(Upper(Column_Value), '_'), '-') = REPLACE(REPLACE(p_Attr_Name, '_'), '-');

      RETURN l_Key;
    END;

    PROCEDURE Set_Str_Val(p_Attr_Name IN VARCHAR2,
                          p_Attr_Val  IN OUT VARCHAR2) IS
    l_Key VARCHAR2(100);
    BEGIN
      l_Key := Attr2key(p_Attr_Name);
      p_Attr_Val := l_Jo.Get_String(l_Key);
    EXCEPTION
    WHEN OTHERS THEN
      Raise_Application_Error(-20000, 'Помилка парсингу поля ' || l_Key || ': ' || SQLERRM);
    END;

    PROCEDURE Set_Date_Val(p_Attr_Name IN VARCHAR2,
                           p_Attr_Val  OUT DATE) IS
    l_Key VARCHAR2(100);
    BEGIN
      l_Key := Attr2key(p_Attr_Name);
      p_Attr_Val := To_Timestamp(Substr(l_Jo.Get_String(l_Key), 1, Length(':date_fmt')), ':date_fmt');
    EXCEPTION
    WHEN OTHERS THEN
       Raise_Application_Error(-20000, 'Помилка парсингу поля ' || l_Key || ': ' || SQLERRM);
    END;

    PROCEDURE Set_Clob_Val(p_Attr_Name IN VARCHAR2,
                           p_Attr_Val  OUT CLOB) IS
    l_Key VARCHAR2(100);
    BEGIN
      l_Key := Attr2key(p_Attr_Name);
      p_Attr_Val := Convert(l_Jo.Get_Clob(l_Key), 'CL8MSWIN1251', 'AL32UTF8');
    EXCEPTION
    WHEN OTHERS THEN
      Raise_Application_Error(-20000, 'Помилка парсингу поля ' || l_Key || ': ' || SQLERRM);
    END;

    PROCEDURE Set_Num_Val(p_Attr_Name IN VARCHAR2,
                          p_Attr_Val  OUT VARCHAR2) IS
    l_Key VARCHAR2(100);
    BEGIN
      l_Key := Attr2key(p_Attr_Name);
      p_Attr_Val := l_Jo.Get_Number(l_Key);
    EXCEPTION
    WHEN OTHERS THEN
      Raise_Application_Error(-20000, 'Помилка парсингу поля ' || l_Key || ': ' || SQLERRM);
    END;
  BEGIN
    l_jo := Json_Object_t.Parse(convert(:p_Json, 'AL32UTF8'));
    l_keys := l_jo.Get_Keys;
    :fields
    :p_rec := l_rec;
  END;]';

        SELECT LISTAGG (
                   CASE
                       WHEN a.Attr_Type_Name = 'VARCHAR2'
                       THEN
                              'Set_Str_Val('''
                           || a.Attr_Name
                           || ''', l_rec.'
                           || a.Attr_Name
                           || ');'
                       WHEN a.Attr_Type_Name = 'NUMBER'
                       THEN
                              'Set_Num_Val('''
                           || a.Attr_Name
                           || ''', l_rec.'
                           || a.Attr_Name
                           || ');'
                       WHEN a.Attr_Type_Name = 'CLOB'
                       THEN
                              'Set_Clob_Val('''
                           || a.Attr_Name
                           || ''', l_rec.'
                           || a.Attr_Name
                           || ');'
                       WHEN a.Attr_Type_Name = 'DATE'
                       THEN
                              'Set_Date_Val('''
                           || a.Attr_Name
                           || ''', l_rec.'
                           || a.Attr_Name
                           || ');'
                       WHEN a.Attr_Type_Package IS NOT NULL
                       THEN
                              'IF Attr2key('''
                           || a.Attr_Name
                           || ''') IS NOT NULL THEN EXECUTE IMMEDIATE
                       REPLACE(Type2jsontable('''
                           || Attr_Type_Package
                           || ''','''
                           || Attr_Type_Name
                           || ''', '''
                           || p_Date_Fmt
                           || '''), ''convert(:p_Json, ''''AL32UTF8'''')'', '':p_Json'')
                       USING IN l_jo.Get(Attr2key('''
                           || Attr_Name
                           || ''')).To_Clob, OUT l_rec.'
                           || Attr_Name
                           || '; END IF;'
                   END,
                   CHR (13) || CHR (10))
               WITHIN GROUP (ORDER BY a.Attr_No)
          INTO l_Fields
          FROM User_Plsql_Type_Attrs a
         WHERE     a.Package_Name = UPPER (p_Pkg_Name)
               AND a.Type_Name = UPPER (p_Type_Name);

        l_Sql := REPLACE (l_Sql, ':type', p_Pkg_Name || '.' || p_Type_Name);
        l_Sql := REPLACE (l_Sql, ':fields', l_Fields);
        l_Sql := REPLACE (l_Sql, ':date_fmt', p_Date_Fmt);
        RETURN l_Sql;
    END;

    ----------------------------------------------------------------------
    --            ГЕНЕРАЦІЯ ЗАПИТУ ДЛЯ ПАРСИНГУ В COLLECTION
    ----------------------------------------------------------------------
    FUNCTION Get_Collection_Sql (p_Pkg_Name VARCHAR2, p_Type_Name VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Rec_Sql          VARCHAR2 (32000);
        l_Coll_Sql         VARCHAR2 (32000);
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
            l_Rec_Sql := Get_Record_Sql (l_Elem_Type_Pkg, l_Elem_Type_Name);
            l_Rec_Sql :=
                REPLACE (
                    l_Rec_Sql,
                    'Json_Object_t.Parse(convert(:p_Json, ''AL32UTF8''))',
                    'TREAT(l_ja.Get(i) AS JSON_OBJECT_T)');
            l_Rec_Sql := REPLACE (l_Rec_Sql, ':p_rec', 'l_coll(i+1)');
            l_Coll_Sql := q'[
    DECLARE
      l_ja   Json_Array_t;
      l_coll :pkg_name.:type_name;
    BEGIN
      if :p_Json = 'null' then
        return;
      end if;
      l_coll := :pkg_name.:type_name();
      l_ja := Json_Array_t.Parse(convert(:p_Json, ''AL32UTF8''));
      FOR i IN 0 .. l_ja.Get_Size - 1
      LOOP
        l_coll.Extend();
        :rec_sql
      END LOOP;
      :l_coll := l_coll;
    END;]';
            l_Coll_Sql := REPLACE (l_Coll_Sql, ':pkg_name', p_Pkg_Name);
            l_Coll_Sql := REPLACE (l_Coll_Sql, ':type_name', p_Type_Name);
            l_Coll_Sql := REPLACE (l_Coll_Sql, ':rec_sql', l_Rec_Sql);
        ELSE
            l_Coll_Sql := '
    DECLARE
      l_ja Json_Array_t;
      l_coll :pkg_name.:type_name;
    BEGIN
      l_ja := Json_Array_t.Parse(convert(:p_Json, ''AL32UTF8''));
      l_coll := :pkg_name.:type_name();
      FOR i IN 0 .. l_ja.Get_Size - 1
      LOOP
        l_coll.Extend();
        l_coll(i+1) := l_ja.Get_String(i);
      END LOOP;
      :l_coll := l_coll;
    END;';
            l_Coll_Sql := REPLACE (l_Coll_Sql, ':pkg_name', p_Pkg_Name);
            l_Coll_Sql := REPLACE (l_Coll_Sql, ':type_name', p_Type_Name);
        END IF;

        RETURN l_Coll_Sql;
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
END Type2jsontable_12;
/
