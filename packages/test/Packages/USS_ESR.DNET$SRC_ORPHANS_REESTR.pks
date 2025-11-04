/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$SRC_ORPHANS_REESTR
IS
    -- Author  : KELATEV
    -- Created : 05.03.2024 12:19:19
    -- Purpose : Первинні дані про пенсіонерів з ПФУ

    PROCEDURE Get_Journal (p_sor_child_ln              IN     VARCHAR2,
                           p_sor_child_fn              IN     VARCHAR2,
                           p_sor_child_mn              IN     VARCHAR2,
                           p_sor_child_birth_dt_From   IN     DATE,
                           p_sor_child_birth_dt_To     IN     DATE,
                           p_sor_child_passport        IN     VARCHAR2,
                           p_sor_child_birth_cert      IN     VARCHAR2,
                           p_sor_kaot_code             IN     VARCHAR2,
                           p_sor_live_address          IN     VARCHAR2,
                           p_sor_father_ln             IN     VARCHAR2,
                           p_sor_father_fn             IN     VARCHAR2,
                           p_sor_father_mn             IN     VARCHAR2,
                           p_sor_father_passport       IN     VARCHAR2,
                           p_sor_mother_ln             IN     VARCHAR2,
                           p_sor_mother_fn             IN     VARCHAR2,
                           p_sor_mother_mn             IN     VARCHAR2,
                           p_sor_mother_passport       IN     VARCHAR2,
                           Res_Cur                        OUT SYS_REFCURSOR);

    FUNCTION Get_Dynamic_Value (p_Col_Name      IN VARCHAR2,
                                p_Col_Data_Tp   IN VARCHAR2,
                                p_Col_Scale     IN NUMBER,
                                p_Ser_Id        IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE Get_Inspector_Card (p_Ser_Id   IN     NUMBER,
                                  Res_Cur       OUT SYS_REFCURSOR);
END Dnet$src_orphans_reestr;
/


GRANT EXECUTE ON USS_ESR.DNET$SRC_ORPHANS_REESTR TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$SRC_ORPHANS_REESTR TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:56 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$SRC_ORPHANS_REESTR
IS
    --=================================================================
    PROCEDURE Get_Journal (p_sor_child_ln              IN     VARCHAR2,
                           p_sor_child_fn              IN     VARCHAR2,
                           p_sor_child_mn              IN     VARCHAR2,
                           p_sor_child_birth_dt_From   IN     DATE,
                           p_sor_child_birth_dt_To     IN     DATE,
                           p_sor_child_passport        IN     VARCHAR2,
                           p_sor_child_birth_cert      IN     VARCHAR2,
                           p_sor_kaot_code             IN     VARCHAR2,
                           p_sor_live_address          IN     VARCHAR2,
                           p_sor_father_ln             IN     VARCHAR2,
                           p_sor_father_fn             IN     VARCHAR2,
                           p_sor_father_mn             IN     VARCHAR2,
                           p_sor_father_passport       IN     VARCHAR2,
                           p_sor_mother_ln             IN     VARCHAR2,
                           p_sor_mother_fn             IN     VARCHAR2,
                           p_sor_mother_mn             IN     VARCHAR2,
                           p_sor_mother_passport       IN     VARCHAR2,
                           Res_Cur                        OUT SYS_REFCURSOR)
    IS
        l_Sql   CLOB;
    BEGIN
        l_Sql := 'SELECT t.*,
                     if_import_dt,
                     if_name
                FROM SRC_ORPHANS_REESTR t
                left join import_files if on (if.if_id = t.sor_if)
               WHERE 1 = 1 #
               ORDER BY Sor_If
               FETCH FIRST 502 ROWS ONLY';

        Api$search.Init (l_Sql);
        Api$search.And_ ('sor_child_ln', 'LIKE', p_Val_Str => p_sor_child_ln);
        Api$search.And_ ('sor_child_fn', 'LIKE', p_Val_Str => p_sor_child_fn);
        Api$search.And_ ('sor_child_mn', 'LIKE', p_Val_Str => p_sor_child_mn);
        Api$search.And_ ('sor_child_birth_dt',
                         '>=',
                         p_Val_Dt   => p_sor_child_birth_dt_From);
        Api$search.And_ ('sor_child_birth_dt',
                         '<=',
                         p_Val_Dt   => p_sor_child_birth_dt_To);
        Api$search.And_ ('sor_child_passport',
                         'LIKE',
                         p_Val_Str   => p_sor_child_passport);
        Api$search.And_ ('sor_child_birth_cert',
                         'LIKE',
                         p_Val_Str   => p_sor_child_birth_cert);
        Api$search.And_ ('sor_kaot_code',
                         'LIKE',
                         p_Val_Str   => p_sor_kaot_code);
        Api$search.And_ ('sor_live_address',
                         'LIKE',
                         p_Val_Str   => p_sor_live_address);
        Api$search.And_ ('sor_father_ln',
                         'LIKE',
                         p_Val_Str   => p_sor_father_ln);
        Api$search.And_ ('sor_father_fn',
                         'LIKE',
                         p_Val_Str   => p_sor_father_fn);
        Api$search.And_ ('sor_father_mn',
                         'LIKE',
                         p_Val_Str   => p_sor_father_mn);
        Api$search.And_ ('sor_father_passport',
                         'LIKE',
                         p_Val_Str   => p_sor_father_passport);
        Api$search.And_ ('sor_mother_ln',
                         'LIKE',
                         p_Val_Str   => p_sor_mother_ln);
        Api$search.And_ ('sor_mother_fn',
                         'LIKE',
                         p_Val_Str   => p_sor_mother_fn);
        Api$search.And_ ('sor_mother_mn',
                         'LIKE',
                         p_Val_Str   => p_sor_mother_mn);
        Api$search.And_ ('sor_mother_passport',
                         'LIKE',
                         p_Val_Str   => p_sor_mother_passport);


        Res_Cur := Api$search.Exec;
    END;

    --=================================================================
    FUNCTION Get_Dynamic_Value (p_Col_Name      IN VARCHAR2,
                                p_Col_Data_Tp   IN VARCHAR2,
                                p_Col_Scale     IN NUMBER,
                                p_Ser_Id        IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Res   VARCHAR2 (4000);
    BEGIN
        EXECUTE IMMEDIATE   'SELECT '
                         || CASE
                                WHEN     p_Col_Data_Tp = 'NUMBER'
                                     AND p_Col_Scale IS NOT NULL
                                     AND p_Col_Scale > 0
                                THEN
                                       'to_char('
                                    || p_Col_Name
                                    || ', ''FM9G999G999G999G999G990D00'', ''NLS_NUMERIC_CHARACTERS='''','''''''''')'
                                WHEN p_Col_Data_Tp = 'DATE'
                                THEN
                                       'to_char('
                                    || p_Col_Name
                                    || ', ''DD.MM.YYYY'')'
                                ELSE
                                    p_Col_Name
                            END
                         || '
                         FROM uss_esr.SRC_ORPHANS_REESTR d
                        WHERE d.Sor_Id = :id'
            INTO l_Res
            USING p_Ser_Id;

        RETURN l_Res;
    END;

    --=================================================================
    PROCEDURE Get_Inspector_Card (p_Ser_Id   IN     NUMBER,
                                  Res_Cur       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN Res_Cur FOR
              SELECT t.Comments                      AS NAME,
                     Get_Dynamic_Value (t.Column_Name,
                                        Ct.Data_Type,
                                        Ct.Data_Scale,
                                        p_Ser_Id)    AS VALUE
                FROM All_Col_Comments t
                     JOIN All_Tab_Columns Ct
                         ON     Ct.Table_Name = t.Table_Name
                            AND Ct.Column_Name = t.Column_Name
               WHERE t.Table_Name = UPPER ('SRC_ORPHANS_REESTR')
            ORDER BY Ct.Column_Id;
    END;
/*SELECT t.Column_Name, t.Data_Type,
       CASE Data_Type
          WHEN 'VARCHAR2' THEN
           'p_' || Lower(Column_Name) || ' IN VARCHAR2,'
          WHEN 'NUMBER' THEN
           'p_' || Lower(Column_Name) || ' IN NUMBER,'
          WHEN 'DATE' THEN
           'p_' || Lower(Column_Name) || '_From IN DATE,p_' || Lower(Column_Name) || '_To IN DATE,'
        END Cmd1,
       CASE Data_Type
          WHEN 'VARCHAR2' THEN
           'Api$search.And_(''' || Lower(Column_Name) || ''', ''LIKE'', p_Val_Str => p_' || Lower(Column_Name) || ');'
          WHEN 'NUMBER' THEN
           'Api$search.And_(''' || Lower(Column_Name) || ''', ''LIKE'', p_Val_Str => p_' || Lower(Column_Name) || ');'
          WHEN 'DATE' THEN
           'Api$search.And_(''' || Lower(Column_Name) || ''', ''>='', p_Val_Dt => p_' || Lower(Column_Name) ||
           '_From);Api$search.And_(''' || Lower(Column_Name) || ''', ''<='', p_Val_Dt => p_' ||
           Lower(Column_Name) || '_To);'
        END Cmd2
  FROM All_Tab_Cols t
 WHERE Table_Name = 'SRC_ORPHANS_REESTR'
   AND Column_Name NOT IN ('SOR_ID', 'SOR_IF', 'SOR_SC_CHILD', 'SOR_SC_FATHER', 'SOR_SC_MOTHER', 'SOR_DT', 'SOR_KAOT')
 ORDER BY t.Column_Id
*/


END Dnet$src_orphans_reestr;
/