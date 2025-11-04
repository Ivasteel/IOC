/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$SRC_PENSION_INFO
IS
    -- Author  : KELATEV
    -- Created : 05.03.2024 12:19:19
    -- Purpose : Первинні дані про пенсіонерів з ПФУ

    PROCEDURE Get_Journal (                   --p_Spi_Id            IN NUMBER,
                           --p_Spi_If            IN NUMBER,
                           p_Spi_Idp                 IN     VARCHAR2,
                           p_Spi_Pib                 IN     VARCHAR2,
                           p_Spi_Inn                 IN     VARCHAR2,
                           p_Spi_Doc_Snum            IN     VARCHAR2,
                           p_Spi_Drog_Dt_In_From     IN     DATE,
                           p_Spi_Drog_Dt_In_To       IN     DATE,
                           p_Spi_Lname_Ppvp          IN     VARCHAR2,
                           p_Spi_Name_Ppvp           IN     VARCHAR2,
                           p_Spi_Father_Ppvp         IN     VARCHAR2,
                           p_Spi_Ls_Idcode_Ppvp      IN     VARCHAR2,
                           p_Spi_Pasp_Ppvp           IN     VARCHAR2,
                           p_Spi_Drog_Dt_Ppvp_From   IN     DATE,
                           p_Spi_Drog_Dt_Ppvp_To     IN     DATE,
                           p_Spi_Ls_Subject_Tp       IN     VARCHAR2,
                           p_Spi_Sum_Zag             IN     NUMBER,
                           p_Spi_Oznaka_Pens         IN     VARCHAR2,
                           p_Spi_Derg_Zab            IN     VARCHAR2,
                           p_Spi_Rab                 IN     VARCHAR2,
                           p_Spi_Inv_Gr              IN     VARCHAR2,
                           p_Spi_Inv_Gr_Dt_From      IN     DATE,
                           p_Spi_Inv_Gr_Dt_To        IN     DATE,
                           p_Spi_Oznak_Prac          IN     VARCHAR2,
                           p_Spi_z_Trud              IN     VARCHAR2,
                           p_Spi_Date_Start_From     IN     DATE,
                           p_Spi_Date_Start_To       IN     DATE,
                           p_Spi_Bez_Trud            IN     VARCHAR2,
                           p_Spi_Lname_Mil           IN     VARCHAR2,
                           p_Spi_Name_Mil            IN     VARCHAR2,
                           p_Spi_Father_Mil          IN     VARCHAR2,
                           p_Spi_Ls_Idcode_Mil       IN     VARCHAR2,
                           p_Spi_Pasp_Mil            IN     VARCHAR2,
                           p_Spi_Drog_Dt_Mil_From    IN     DATE,
                           p_Spi_Drog_Dt_Mil_To      IN     DATE,
                           p_Spi_Ls_Subject_Tp_Mil   IN     VARCHAR2,
                           p_Spi_Sum_Zag_Mil         IN     NUMBER,
                           p_Spi_Oznaka_Pens_Mil     IN     VARCHAR2,
                           p_Spi_Derg_Zab_Mil        IN     VARCHAR2,
                           p_Spi_Inv_Gr_Mil          IN     VARCHAR2,
                           p_Spi_Gr_Dt_Mil_From      IN     DATE,
                           p_Spi_Gr_Dt_Mil_To        IN     DATE,
                           p_Spi_Inv_Stop_Dt_From    IN     DATE,
                           p_Spi_Inv_Stop_Dt_To      IN     DATE,
                           --p_Spi_Sc            IN NUMBER,
                           p_Spi_Month               IN     DATE,
                           p_Sc_Unique               IN     VARCHAR2,
                           Res_Cur                      OUT SYS_REFCURSOR);

    FUNCTION Get_Dynamic_Value (p_Col_Name      IN VARCHAR2,
                                p_Col_Data_Tp   IN VARCHAR2,
                                p_Col_Scale     IN NUMBER,
                                p_Ser_Id        IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE Get_Inspector_Card (p_Ser_Id   IN     NUMBER,
                                  Res_Cur       OUT SYS_REFCURSOR);
END Dnet$src_pension_Info;
/


GRANT EXECUTE ON USS_ESR.DNET$SRC_PENSION_INFO TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$SRC_PENSION_INFO TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:56 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$SRC_PENSION_INFO
IS
    --=================================================================
    PROCEDURE Get_Journal (                   --p_Spi_Id            IN NUMBER,
                           --p_Spi_If            IN NUMBER,
                           p_Spi_Idp                 IN     VARCHAR2,
                           p_Spi_Pib                 IN     VARCHAR2,
                           p_Spi_Inn                 IN     VARCHAR2,
                           p_Spi_Doc_Snum            IN     VARCHAR2,
                           p_Spi_Drog_Dt_In_From     IN     DATE,
                           p_Spi_Drog_Dt_In_To       IN     DATE,
                           p_Spi_Lname_Ppvp          IN     VARCHAR2,
                           p_Spi_Name_Ppvp           IN     VARCHAR2,
                           p_Spi_Father_Ppvp         IN     VARCHAR2,
                           p_Spi_Ls_Idcode_Ppvp      IN     VARCHAR2,
                           p_Spi_Pasp_Ppvp           IN     VARCHAR2,
                           p_Spi_Drog_Dt_Ppvp_From   IN     DATE,
                           p_Spi_Drog_Dt_Ppvp_To     IN     DATE,
                           p_Spi_Ls_Subject_Tp       IN     VARCHAR2,
                           p_Spi_Sum_Zag             IN     NUMBER,
                           p_Spi_Oznaka_Pens         IN     VARCHAR2,
                           p_Spi_Derg_Zab            IN     VARCHAR2,
                           p_Spi_Rab                 IN     VARCHAR2,
                           p_Spi_Inv_Gr              IN     VARCHAR2,
                           p_Spi_Inv_Gr_Dt_From      IN     DATE,
                           p_Spi_Inv_Gr_Dt_To        IN     DATE,
                           p_Spi_Oznak_Prac          IN     VARCHAR2,
                           p_Spi_z_Trud              IN     VARCHAR2,
                           p_Spi_Date_Start_From     IN     DATE,
                           p_Spi_Date_Start_To       IN     DATE,
                           p_Spi_Bez_Trud            IN     VARCHAR2,
                           p_Spi_Lname_Mil           IN     VARCHAR2,
                           p_Spi_Name_Mil            IN     VARCHAR2,
                           p_Spi_Father_Mil          IN     VARCHAR2,
                           p_Spi_Ls_Idcode_Mil       IN     VARCHAR2,
                           p_Spi_Pasp_Mil            IN     VARCHAR2,
                           p_Spi_Drog_Dt_Mil_From    IN     DATE,
                           p_Spi_Drog_Dt_Mil_To      IN     DATE,
                           p_Spi_Ls_Subject_Tp_Mil   IN     VARCHAR2,
                           p_Spi_Sum_Zag_Mil         IN     NUMBER,
                           p_Spi_Oznaka_Pens_Mil     IN     VARCHAR2,
                           p_Spi_Derg_Zab_Mil        IN     VARCHAR2,
                           p_Spi_Inv_Gr_Mil          IN     VARCHAR2,
                           p_Spi_Gr_Dt_Mil_From      IN     DATE,
                           p_Spi_Gr_Dt_Mil_To        IN     DATE,
                           p_Spi_Inv_Stop_Dt_From    IN     DATE,
                           p_Spi_Inv_Stop_Dt_To      IN     DATE,
                           --p_Spi_Sc            IN NUMBER,
                           p_Spi_Month               IN     DATE,
                           p_Sc_Unique               IN     VARCHAR2,
                           Res_Cur                      OUT SYS_REFCURSOR)
    IS
        l_Sql   CLOB;
    BEGIN
        l_Sql := 'SELECT t.*,
                     if_load_dt,
                     if_name,
                     (SELECT dic_name
                        FROM uss_ndi.V_DDN_SPI_LS_SUBJECT_TP
                       WHERE dic_value = SPI_LS_SUBJECT_TP
                         AND dic_st = ''A'') as spi_ls_subject_tp_name,
                     (SELECT dic_name
                        FROM uss_ndi.V_DDN_SPI_LS_SUBJECT_TP
                       WHERE dic_value = SPI_LS_SUBJECT_TP_MIL
                         AND dic_st = ''A'') as spi_ls_subject_tp_mil_name,
                     (SELECT dic_name
                        FROM uss_ndi.V_DDN_SPI_OZNAKA_PENS
                       WHERE dic_value = SPI_OZNAKA_PENS
                         AND dic_st = ''A'') as spi_oznaka_pens_name,
                     (SELECT dic_name
                        FROM uss_ndi.V_DDN_SPI_OZNAKA_PENS
                       WHERE dic_value = SPI_OZNAKA_PENS_MIL
                         AND dic_st = ''A'') as spi_oznaka_pens_mil_name
                FROM src_pension_info t
                left join import_files if on (if.if_id = t.spi_if)
                left join uss_person.v_socialcard sc on (sc.sc_id = t.spi_sc)
               WHERE 1 = 1 #
               ORDER BY Spi_If
               FETCH FIRST 502 ROWS ONLY';

        Api$search.Init (l_Sql);
        --Api$search.And_('Spi_Id', 'LIKE', p_Val_Str => p_Spi_Id);
        --Api$search.And_('Spi_If', 'LIKE', p_Val_Str => p_Spi_If);
        Api$search.And_ ('spi_idp', 'LIKE', p_Val_Str => p_Spi_Idp);
        Api$search.And_ ('spi_pib', 'LIKE', p_Val_Str => p_Spi_Pib);
        Api$search.And_ ('spi_inn', 'LIKE', p_Val_Str => p_Spi_Inn);
        Api$search.And_ ('spi_doc_snum', 'LIKE', p_Val_Str => p_Spi_Doc_Snum);
        Api$search.And_ ('spi_drog_dt_in',
                         '>=',
                         p_Val_Dt   => p_Spi_Drog_Dt_In_From);
        Api$search.And_ ('spi_drog_dt_in',
                         '<=',
                         p_Val_Dt   => p_Spi_Drog_Dt_In_To);
        Api$search.And_ ('spi_lname_ppvp',
                         'LIKE',
                         p_Val_Str   => p_Spi_Lname_Ppvp);
        Api$search.And_ ('spi_name_ppvp',
                         'LIKE',
                         p_Val_Str   => p_Spi_Name_Ppvp);
        Api$search.And_ ('spi_father_ppvp',
                         'LIKE',
                         p_Val_Str   => p_Spi_Father_Ppvp);
        Api$search.And_ ('spi_ls_idcode_ppvp',
                         'LIKE',
                         p_Val_Str   => p_Spi_Ls_Idcode_Ppvp);
        Api$search.And_ ('spi_pasp_ppvp',
                         'LIKE',
                         p_Val_Str   => p_Spi_Pasp_Ppvp);
        Api$search.And_ ('spi_drog_dt_ppvp',
                         '>=',
                         p_Val_Dt   => p_Spi_Drog_Dt_Ppvp_From);
        Api$search.And_ ('spi_drog_dt_ppvp',
                         '<=',
                         p_Val_Dt   => p_Spi_Drog_Dt_Ppvp_To);
        Api$search.And_ ('spi_ls_subject_tp',
                         p_Val_Str   => p_Spi_Ls_Subject_Tp);
        Api$search.And_ ('spi_sum_zag', 'LIKE', p_Val_Str => p_Spi_Sum_Zag);
        Api$search.And_ ('spi_oznaka_pens', p_Val_Str => p_Spi_Oznaka_Pens);
        Api$search.And_ ('spi_derg_zab', 'LIKE', p_Val_Str => p_Spi_Derg_Zab);
        Api$search.And_ ('spi_rab', 'LIKE', p_Val_Str => p_Spi_Rab);
        Api$search.And_ ('spi_inv_gr', 'LIKE', p_Val_Str => p_Spi_Inv_Gr);
        Api$search.And_ ('spi_inv_gr_dt',
                         '>=',
                         p_Val_Dt   => p_Spi_Inv_Gr_Dt_From);
        Api$search.And_ ('spi_inv_gr_dt',
                         '<=',
                         p_Val_Dt   => p_Spi_Inv_Gr_Dt_To);
        Api$search.And_ ('spi_oznak_prac',
                         'LIKE',
                         p_Val_Str   => p_Spi_Oznak_Prac);
        Api$search.And_ ('spi_z_trud', 'LIKE', p_Val_Str => p_Spi_z_Trud);
        Api$search.And_ ('spi_date_start',
                         '>=',
                         p_Val_Dt   => p_Spi_Date_Start_From);
        Api$search.And_ ('spi_date_start',
                         '<=',
                         p_Val_Dt   => p_Spi_Date_Start_To);
        Api$search.And_ ('spi_bez_trud', 'LIKE', p_Val_Str => p_Spi_Bez_Trud);
        Api$search.And_ ('spi_lname_mil',
                         'LIKE',
                         p_Val_Str   => p_Spi_Lname_Mil);
        Api$search.And_ ('spi_name_mil', 'LIKE', p_Val_Str => p_Spi_Name_Mil);
        Api$search.And_ ('spi_father_mil',
                         'LIKE',
                         p_Val_Str   => p_Spi_Father_Mil);
        Api$search.And_ ('spi_ls_idcode_mil',
                         'LIKE',
                         p_Val_Str   => p_Spi_Ls_Idcode_Mil);
        Api$search.And_ ('spi_pasp_mil', 'LIKE', p_Val_Str => p_Spi_Pasp_Mil);
        Api$search.And_ ('spi_drog_dt_mil',
                         '>=',
                         p_Val_Dt   => p_Spi_Drog_Dt_Mil_From);
        Api$search.And_ ('spi_drog_dt_mil',
                         '<=',
                         p_Val_Dt   => p_Spi_Drog_Dt_Mil_To);
        Api$search.And_ ('spi_ls_subject_tp_mil',
                         p_Val_Str   => p_Spi_Ls_Subject_Tp_Mil);
        Api$search.And_ ('spi_sum_zag_mil',
                         'LIKE',
                         p_Val_Str   => p_Spi_Sum_Zag_Mil);
        Api$search.And_ ('spi_oznaka_pens_mil',
                         p_Val_Str   => p_Spi_Oznaka_Pens_Mil);
        Api$search.And_ ('spi_derg_zab_mil',
                         'LIKE',
                         p_Val_Str   => p_Spi_Derg_Zab_Mil);
        Api$search.And_ ('spi_inv_gr_mil',
                         'LIKE',
                         p_Val_Str   => p_Spi_Inv_Gr_Mil);
        Api$search.And_ ('spi_gr_dt_mil',
                         '>=',
                         p_Val_Dt   => p_Spi_Gr_Dt_Mil_From);
        Api$search.And_ ('spi_gr_dt_mil',
                         '<=',
                         p_Val_Dt   => p_Spi_Gr_Dt_Mil_To);
        Api$search.And_ ('spi_inv_stop_dt',
                         '>=',
                         p_Val_Dt   => p_Spi_Inv_Stop_Dt_From);
        Api$search.And_ ('spi_inv_stop_dt',
                         '<=',
                         p_Val_Dt   => p_Spi_Inv_Stop_Dt_To);
        --Api$search.And_('spi_month', '=', p_Val_Dt => p_Spi_Month);
        Api$search.And_ ('Sc_Unique', 'LIKE', p_Val_Dt => p_Sc_Unique);
        --Api$search.And_('Spi_Sc', 'LIKE', p_Val_Str => p_Spi_Sc);

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
                                WHEN p_Col_Name IN
                                         ('SPI_LS_SUBJECT_TP',
                                          'SPI_LS_SUBJECT_TP_MIL')
                                THEN
                                    '(SELECT dic_name
                             FROM uss_ndi.V_DDN_SPI_LS_SUBJECT_TP
                            WHERE dic_value = ' || p_Col_Name || '
                              AND dic_st = ''A'')'
                                WHEN p_Col_Name IN
                                         ('SPI_OZNAKA_PENS',
                                          'SPI_OZNAKA_PENS_MIL')
                                THEN
                                    '(SELECT dic_name
                             FROM uss_ndi.V_DDN_SPI_OZNAKA_PENS
                            WHERE dic_value = ' || p_Col_Name || '
                              AND dic_st = ''A'')'
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
                         FROM uss_esr.SRC_PENSION_INFO d
                        WHERE d.Spi_Id = :id'
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
               WHERE t.Table_Name = UPPER ('SRC_PENSION_INFO')
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
           '_From);Api$search.And_(''' || Lower(Column_Name) || ''', ''<='', p_Val_Dt => p_' || Lower(Column_Name) ||
           '_To);'
        END Cmd2
  FROM All_Tab_Cols t
 WHERE Table_Name = 'SRC_PENSION_INFO'
   AND Column_Name NOT IN ('SPI_ID', 'SPI_IF', 'SPI_SC')
 ORDER BY t.Column_Id*/


END Dnet$src_pension_Info;
/