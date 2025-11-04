/* Formatted on 8/12/2025 6:10:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.API$SEARCH
IS
    -- Author  : SHOST
    -- Created : 07.02.2023 18:15:57
    -- Purpose : Виконання пошуку по динамічних фільтрах

    TYPE r_Srch_Var IS RECORD
    (
        Name_      VARCHAR2 (100),
        Val_Num    NUMBER,
        Val_Str    VARCHAR2 (4000),
        Val_Dt     DATE
    );

    TYPE t_Srch_Var_List IS TABLE OF r_Srch_Var;

    PROCEDURE Init (p_Sql IN OUT NOCOPY CLOB);

    PROCEDURE Add_Var (p_Logic        IN VARCHAR2 DEFAULT 'AND',
                       p_Field_Name   IN VARCHAR2,
                       p_Operator     IN VARCHAR2 DEFAULT '=',
                       p_Var_Name     IN VARCHAR2 DEFAULT NULL,
                       p_Val_Num      IN NUMBER DEFAULT NULL,
                       p_Val_Str      IN VARCHAR2 DEFAULT NULL,
                       p_Val_Dt       IN DATE DEFAULT NULL);

    PROCEDURE And_ (p_Field_Name   IN VARCHAR2,
                    p_Operator     IN VARCHAR2 DEFAULT '=',
                    p_Var_Name     IN VARCHAR2 DEFAULT NULL,
                    p_Val_Num      IN NUMBER DEFAULT NULL,
                    p_Val_Str      IN VARCHAR2 DEFAULT NULL,
                    p_Val_Dt       IN DATE DEFAULT NULL);

    PROCEDURE Or_ (p_Field_Name   IN VARCHAR2,
                   p_Operator     IN VARCHAR2 DEFAULT '=',
                   p_Var_Name     IN VARCHAR2 DEFAULT NULL,
                   p_Val_Num      IN NUMBER DEFAULT NULL,
                   p_Val_Str      IN VARCHAR2 DEFAULT NULL,
                   p_Val_Dt       IN DATE DEFAULT NULL);

    PROCEDURE CONCAT (p_Str IN VARCHAR2);

    FUNCTION Exec
        RETURN SYS_REFCURSOR;
END Api$search;
/


/* Formatted on 8/12/2025 6:10:48 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.API$SEARCH
IS
    g_Sql        CLOB;
    g_Var_List   t_Srch_Var_List;

    PROCEDURE Init (p_Sql IN OUT NOCOPY CLOB)
    IS
    BEGIN
        g_Sql := p_Sql;
        g_Var_List := t_Srch_Var_List ();
    END;

    PROCEDURE Add_Var (p_Logic        IN VARCHAR2 DEFAULT 'AND',
                       p_Field_Name   IN VARCHAR2,
                       p_Operator     IN VARCHAR2 DEFAULT '=',
                       p_Var_Name     IN VARCHAR2 DEFAULT NULL,
                       p_Val_Num      IN NUMBER DEFAULT NULL,
                       p_Val_Str      IN VARCHAR2 DEFAULT NULL,
                       p_Val_Dt       IN DATE DEFAULT NULL)
    IS
    BEGIN
        IF p_Val_Num IS NULL AND p_Val_Str IS NULL AND p_Val_Dt IS NULL
        THEN
            RETURN;
        END IF;

        IF g_Var_List IS NULL
        THEN
            g_Var_List := t_Srch_Var_List ();
        END IF;

        g_Var_List.EXTEND ();

        g_Var_List (g_Var_List.COUNT).Name_ := NVL (p_Var_Name, p_Field_Name);
        g_Var_List (g_Var_List.COUNT).Val_Num := p_Val_Num;
        g_Var_List (g_Var_List.COUNT).Val_Str := p_Val_Str;
        g_Var_List (g_Var_List.COUNT).Val_Dt := p_Val_Dt;

        g_Sql :=
            REPLACE (
                g_Sql,
                '#',
                   ' '
                || p_Logic
                || ' '
                || p_Field_Name
                || ' '
                || p_Operator
                || ' :'
                || NVL (p_Var_Name, p_Field_Name)
                || CASE WHEN p_Operator = 'LIKE' THEN q'[||'%']' END
                || '#');
    END;

    PROCEDURE And_ (p_Field_Name   IN VARCHAR2,
                    p_Operator     IN VARCHAR2 DEFAULT '=',
                    p_Var_Name     IN VARCHAR2 DEFAULT NULL,
                    p_Val_Num      IN NUMBER DEFAULT NULL,
                    p_Val_Str      IN VARCHAR2 DEFAULT NULL,
                    p_Val_Dt       IN DATE DEFAULT NULL)
    IS
    BEGIN
        Add_Var (p_Field_Name   => p_Field_Name,
                 p_Logic        => 'AND',
                 p_Var_Name     => p_Var_Name,
                 p_Operator     => p_Operator,
                 p_Val_Num      => p_Val_Num,
                 p_Val_Str      => p_Val_Str,
                 p_Val_Dt       => p_Val_Dt);
    END;

    PROCEDURE Or_ (p_Field_Name   IN VARCHAR2,
                   p_Operator     IN VARCHAR2 DEFAULT '=',
                   p_Var_Name     IN VARCHAR2 DEFAULT NULL,
                   p_Val_Num      IN NUMBER DEFAULT NULL,
                   p_Val_Str      IN VARCHAR2 DEFAULT NULL,
                   p_Val_Dt       IN DATE DEFAULT NULL)
    IS
    BEGIN
        Add_Var (p_Field_Name   => p_Field_Name,
                 p_Logic        => 'OR',
                 p_Var_Name     => p_Var_Name,
                 p_Operator     => p_Operator,
                 p_Val_Num      => p_Val_Num,
                 p_Val_Str      => p_Val_Str,
                 p_Val_Dt       => p_Val_Dt);
    END;

    PROCEDURE CONCAT (p_Str IN VARCHAR2)
    IS
    BEGIN
        g_Sql := REPLACE (g_Sql, '#', p_Str || '#');
    END;

    PROCEDURE Bind_Vars (p_Cur        IN            INTEGER,
                         g_Var_List   IN OUT NOCOPY t_Srch_Var_List)
    IS
    BEGIN
        IF g_Var_List IS NULL
        THEN
            RETURN;
        END IF;

        FOR i IN 1 .. g_Var_List.COUNT
        LOOP
            IF g_Var_List (i).Val_Num IS NOT NULL
            THEN
                DBMS_SQL.Bind_Variable (p_Cur,
                                        g_Var_List (i).Name_,
                                        g_Var_List (i).Val_Num);
            ELSIF g_Var_List (i).Val_Str IS NOT NULL
            THEN
                DBMS_SQL.Bind_Variable (p_Cur,
                                        g_Var_List (i).Name_,
                                        g_Var_List (i).Val_Str);
            ELSIF g_Var_List (i).Val_Dt IS NOT NULL
            THEN
                DBMS_SQL.Bind_Variable (p_Cur,
                                        g_Var_List (i).Name_,
                                        g_Var_List (i).Val_Dt);
            END IF;
        END LOOP;
    END;

    FUNCTION Exec
        RETURN SYS_REFCURSOR
    IS
        l_Cur       INTEGER;
        l_Sql_Out   INTEGER;
    BEGIN
        g_Sql := REPLACE (g_Sql, '#');
        --raise_application_error(-20000, g_Sql);
        --Dbms_Output.Put_Line(g_Sql);
        l_Cur := DBMS_SQL.Open_Cursor;
        DBMS_SQL.Parse (l_Cur, g_Sql, DBMS_SQL.Native);
        Bind_Vars (l_Cur, g_Var_List);
        l_Sql_Out := DBMS_SQL.Execute (l_Cur);
        RETURN DBMS_SQL.To_Refcursor (l_Cur);
    END;
END Api$search;
/