/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$SRC_DISABILITY_ASOPD
IS
    -- Author  : KELATEV
    -- Created : 07.03.2024 19:19:19
    -- Purpose : Інформація щодо інвалідності з АСПОД

    PROCEDURE Get_Journal (p_sda_dt_from          IN     DATE,
                           p_sda_dt_to            IN     DATE,
                           p_sda_raj              IN     VARCHAR2,
                           p_sda_ls_nls           IN     VARCHAR2,
                           p_sda_fam_num          IN     VARCHAR2,
                           p_sda_pib              IN     VARCHAR2,
                           p_sda_n_id             IN     VARCHAR2,
                           p_sda_doctype          IN     VARCHAR2,
                           p_sda_series           IN     VARCHAR2,
                           p_sda_bdate_From       IN     DATE,
                           p_sda_bdate_To         IN     DATE,
                           p_sda_sumd_From        IN     NUMBER,
                           p_sda_sumd_To          IN     NUMBER,
                           p_sda_dis_group        IN     VARCHAR2,
                           p_sda_dis_begin_From   IN     DATE,
                           p_sda_dis_begin_To     IN     DATE,
                           p_sda_dis_end_From     IN     DATE,
                           p_sda_dis_end_To       IN     DATE,
                           p_sda_osob_1           IN     VARCHAR2,
                           p_sda_osob_2           IN     VARCHAR2,
                           p_sda_osob_3           IN     VARCHAR2,
                           p_sda_osob_4           IN     VARCHAR2,
                           p_sda_osob_5           IN     VARCHAR2,
                           p_sda_osob_6           IN     VARCHAR2,
                           p_sda_osob_7           IN     VARCHAR2,
                           p_sda_osob_8           IN     VARCHAR2,
                           p_sda_osob_9           IN     VARCHAR2,
                           p_sda_osob_10          IN     VARCHAR2,
                           p_sda_osob_11          IN     VARCHAR2,
                           p_sda_osob_12          IN     VARCHAR2,
                           Res_Cur                   OUT SYS_REFCURSOR);

    FUNCTION Get_Dynamic_Value (p_Col_Name      IN VARCHAR2,
                                p_Col_Data_Tp   IN VARCHAR2,
                                p_Col_Scale     IN NUMBER,
                                p_Ser_Id        IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE Get_Inspector_Card (p_Ser_Id   IN     NUMBER,
                                  Res_Cur       OUT SYS_REFCURSOR);
END Dnet$src_disability_asopd;
/


GRANT EXECUTE ON USS_ESR.DNET$SRC_DISABILITY_ASOPD TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$SRC_DISABILITY_ASOPD TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:56 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$SRC_DISABILITY_ASOPD
IS
    --=================================================================
    PROCEDURE Get_Journal (p_sda_dt_from          IN     DATE,
                           p_sda_dt_to            IN     DATE,
                           p_sda_raj              IN     VARCHAR2,
                           p_sda_ls_nls           IN     VARCHAR2,
                           p_sda_fam_num          IN     VARCHAR2,
                           p_sda_pib              IN     VARCHAR2,
                           p_sda_n_id             IN     VARCHAR2,
                           p_sda_doctype          IN     VARCHAR2,
                           p_sda_series           IN     VARCHAR2,
                           p_sda_bdate_From       IN     DATE,
                           p_sda_bdate_To         IN     DATE,
                           p_sda_sumd_From        IN     NUMBER,
                           p_sda_sumd_To          IN     NUMBER,
                           p_sda_dis_group        IN     VARCHAR2,
                           p_sda_dis_begin_From   IN     DATE,
                           p_sda_dis_begin_To     IN     DATE,
                           p_sda_dis_end_From     IN     DATE,
                           p_sda_dis_end_To       IN     DATE,
                           p_sda_osob_1           IN     VARCHAR2,
                           p_sda_osob_2           IN     VARCHAR2,
                           p_sda_osob_3           IN     VARCHAR2,
                           p_sda_osob_4           IN     VARCHAR2,
                           p_sda_osob_5           IN     VARCHAR2,
                           p_sda_osob_6           IN     VARCHAR2,
                           p_sda_osob_7           IN     VARCHAR2,
                           p_sda_osob_8           IN     VARCHAR2,
                           p_sda_osob_9           IN     VARCHAR2,
                           p_sda_osob_10          IN     VARCHAR2,
                           p_sda_osob_11          IN     VARCHAR2,
                           p_sda_osob_12          IN     VARCHAR2,
                           Res_Cur                   OUT SYS_REFCURSOR)
    IS
        l_Sql   CLOB;
    BEGIN
        l_Sql :=
            'SELECT t.*,
                     if_load_dt,
                     if_name,
                     (SELECT dic_name
                        FROM uss_ndi.V_DDN_SDA_DOCTYPE
                       WHERE dic_value = SDA_DOCTYPE
                         AND dic_st = ''A'') as sda_doctype_name,
                     (SELECT dic_name
                        FROM uss_ndi.V_DDN_SCY_GROUP
                       WHERE dic_value = Uss_Ndi.Tools.Decode_Dict(p_Nddc_Tp       => ''SCY_GROUP'',
                                                                   p_Nddc_Src      => ''ASOPD'',
                                                                   p_Nddc_Dest     => ''USS'',
                                                                   p_Nddc_Code_Src => SDA_DIS_GROUP)
                         AND dic_st = ''A'') as sda_dis_group_name
                FROM SRC_DISABILITY_ASOPD t
                left join import_files if on (if.if_id = t.sda_if)
               WHERE 1 = 1 #
               ORDER BY Sda_If
               FETCH FIRST 502 ROWS ONLY';

        Api$search.Init (l_Sql);
        Api$search.And_ ('sda_dt', '>=', p_Val_Dt => p_sda_dt_From);
        Api$search.And_ ('sda_dt', '<=', p_Val_Dt => p_sda_dt_To);
        --Api$search.And_('sda_org', 'LIKE', p_Val_Str => p_sda_org);
        Api$search.And_ ('sda_raj', 'LIKE', p_Val_Str => p_sda_raj);
        Api$search.And_ ('sda_ls_nls', 'LIKE', p_Val_Str => p_sda_ls_nls);
        Api$search.And_ ('sda_fam_num', 'LIKE', p_Val_Str => p_sda_fam_num);
        Api$search.And_ ('sda_pib', 'LIKE', p_Val_Str => p_sda_pib);
        Api$search.And_ ('sda_n_id', 'LIKE', p_Val_Str => p_sda_n_id);
        Api$search.And_ ('sda_doctype', p_Val_Str => p_sda_doctype);
        Api$search.And_ ('sda_series', 'LIKE', p_Val_Str => p_sda_series);
        Api$search.And_ ('sda_bdate', '>=', p_Val_Dt => p_sda_bdate_From);
        Api$search.And_ ('sda_bdate', '<=', p_Val_Dt => p_sda_bdate_To);
        Api$search.And_ ('sda_sumd', '>=', p_Val_Num => p_sda_sumd_From);
        Api$search.And_ ('sda_sumd', '<=', p_Val_Num => p_sda_sumd_To);

        IF p_sda_dis_group IS NOT NULL
        THEN
            Api$search.And_ ('sda_dis_group',
                             p_Val_Str   => Uss_Ndi.Tools.Decode_Dict_Reverse (
                                               p_Nddc_Tp     => 'SCY_GROUP',
                                               p_Nddc_Src    => 'ASOPD',
                                               p_Nddc_Dest   => 'USS',
                                               p_Nddc_Code_Dest   =>
                                                   p_sda_dis_group));
        END IF;

        Api$search.And_ ('sda_dis_begin',
                         '>=',
                         p_Val_Dt   => p_sda_dis_begin_From);
        Api$search.And_ ('sda_dis_begin',
                         '<=',
                         p_Val_Dt   => p_sda_dis_begin_To);
        Api$search.And_ ('sda_dis_end', '>=', p_Val_Dt => p_sda_dis_end_From);
        Api$search.And_ ('sda_dis_end', '<=', p_Val_Dt => p_sda_dis_end_To);

        IF (p_sda_osob_1 = 'T')
        THEN
            Api$search.And_ ('sda_osob_1', p_Val_Str => 'T');
        END IF;

        IF (p_sda_osob_2 = 'T')
        THEN
            Api$search.And_ ('sda_osob_2', p_Val_Str => 'T');
        END IF;

        IF (p_sda_osob_3 = 'T')
        THEN
            Api$search.And_ ('sda_osob_3', p_Val_Str => 'T');
        END IF;

        IF (p_sda_osob_6 = 'T')
        THEN
            Api$search.And_ ('sda_osob_6', p_Val_Str => 'T');
        END IF;

        IF (p_sda_osob_7 = 'T')
        THEN
            Api$search.And_ ('sda_osob_7', p_Val_Str => 'T');
        END IF;

        IF (p_sda_osob_8 = 'T')
        THEN
            Api$search.And_ ('sda_osob_8', p_Val_Str => 'T');
        END IF;

        IF (p_sda_osob_9 = 'T')
        THEN
            Api$search.And_ ('sda_osob_9', p_Val_Str => 'T');
        END IF;

        IF (p_sda_osob_10 = 'T')
        THEN
            Api$search.And_ ('sda_osob_10', p_Val_Str => 'T');
        END IF;

        IF (p_sda_osob_11 = 'T')
        THEN
            Api$search.And_ ('sda_osob_11', p_Val_Str => 'T');
        END IF;

        IF (p_sda_osob_12 = 'T')
        THEN
            Api$search.And_ ('sda_osob_12', p_Val_Str => 'T');
        END IF;

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
                                WHEN p_Col_Name = 'SDA_DOCTYPE'
                                THEN
                                    '(SELECT dic_name
                             FROM uss_ndi.V_DDN_SDA_DOCTYPE
                            WHERE dic_value = SDA_DOCTYPE
                              AND dic_st = ''A'')'
                                WHEN p_Col_Name = 'SDA_DIS_GROUP'
                                THEN
                                    '(SELECT dic_name
                             FROM uss_ndi.V_DDN_SCY_GROUP
                            WHERE dic_value = Uss_Ndi.Tools.Decode_Dict(p_Nddc_Tp       => ''SCY_GROUP'',
                                                                        p_Nddc_Src      => ''ASOPD'',
                                                                        p_Nddc_Dest     => ''USS'',
                                                                        p_Nddc_Code_Src => SDA_DIS_GROUP)
                              AND dic_st = ''A'')'
                                WHEN p_Col_Name LIKE 'SDA_OSOB_%'
                                THEN
                                       'decode('
                                    || p_Col_Name
                                    || ', ''T'', ''Так'', ''Ні'')'
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
                         FROM uss_esr.SRC_DISABILITY_ASOPD d
                        WHERE d.Sda_Id = :id'
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
               WHERE t.Table_Name = UPPER ('SRC_DISABILITY_ASOPD')
            ORDER BY Ct.Column_Id;
    END;
/*SELECT t.Column_Name, t.Data_Type, t.data_length,
       CASE Data_Type
          WHEN 'VARCHAR2' THEN
           'p_' || Lower(t.Column_Name) || ' IN VARCHAR2,'
          WHEN 'NUMBER' THEN
           'p_' || Lower(t.Column_Name) || ' IN NUMBER,'
          WHEN 'DATE' THEN
           'p_' || Lower(t.Column_Name) || '_From IN DATE,p_' || Lower(t.Column_Name) || '_To IN DATE,'
        END Cmd1,
       CASE Data_Type
          WHEN 'VARCHAR2' THEN
           'Api$search.And_(''' || Lower(t.Column_Name) || ''', ''LIKE'', p_Val_Str => p_' ||
           Lower(t.Column_Name) || ');'
          WHEN 'NUMBER' THEN
           'Api$search.And_(''' || Lower(t.Column_Name) || ''', ''LIKE'', p_Val_Str => p_' ||
           Lower(t.Column_Name) || ');'
          WHEN 'DATE' THEN
           'Api$search.And_(''' || Lower(t.Column_Name) || ''', ''>='', p_Val_Dt => p_' || Lower(t.Column_Name) ||
           '_From);Api$search.And_(''' || Lower(t.Column_Name) || ''', ''<='', p_Val_Dt => p_' ||
           Lower(t.Column_Name) || '_To);'
        END Cmd2,
       Lower(t.Column_Name) || CASE Data_Type
          WHEN 'VARCHAR2' THEN
           ' VARCHAR2(4000),'
          ELSE
           ' ' || lower(t.table_name) || '.' || lower(t.Column_Name) || '%type,'
        END cmd3,
       CASE Data_Type
          WHEN 'VARCHAR2' THEN
           'TRIM(Col0' || TRIM(to_char(Column_Id, '00')) || ') AS ' || lower(t.Column_Name) || ','
          WHEN 'NUMBER' THEN
           'TOOLS.tnumber(Col0' || TRIM(to_char(Column_Id, '00')) || ') AS ' || lower(t.Column_Name) || ','
          WHEN 'DATE' THEN
           'TOOLS.tdate(Col0' || TRIM(to_char(Column_Id, '00')) || ') AS ' || lower(t.Column_Name) || ','
        END cmd4,
       CASE Data_Type
          WHEN 'VARCHAR2' THEN
           'ELSIF Nvl(Length(l_data(i).' || lower(t.Column_Name) ||
           '), 0) > ' || to_char(data_length) || ' THEN Raise_Application_Error(-20000, ''В рядку '' || i || '' поле "' || c.comments ||
           '" не повинно містити більше ' || to_char(data_length) || ' символів'');'
        END cmd5
  FROM All_Tab_Cols t
  LEFT JOIN All_Col_Comments c
    ON c.owner = t.owner
   AND c.table_name = t.table_name
   AND c.column_name = t.column_name
 WHERE t.owner = 'USS_ESR'
   AND t.Table_Name = 'SRC_DISABILITY_ASOPD'
   AND t.Column_Name NOT IN ('SDA_ID', 'SDA_IF', 'SDA_DT')
 ORDER BY t.Column_Id

*/


END Dnet$src_disability_asopd;
/