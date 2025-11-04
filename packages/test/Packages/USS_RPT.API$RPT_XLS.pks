/* Formatted on 8/12/2025 5:58:56 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RPT.API$RPT_XLS
IS
    TYPE t_param IS RECORD
    (
        p_name     VARCHAR2 (100),
        p_value    VARCHAR2 (500)
    );

    TYPE t_params IS TABLE OF t_param;

    -- Author  : OIVASHCHUK
    -- Created : 06.05.2019 15:10:27
    -- Purpose : побудова звітів в форматі xml-excel

    PROCEDURE B_PUT_LINE (p_lob IN OUT NOCOPY BLOB, p_str VARCHAR2);

    PROCEDURE start_workbook (p_lob IN OUT NOCOPY BLOB);

    PROCEDURE end_workbook (p_lob IN OUT NOCOPY BLOB);

    PROCEDURE start_worksheet (p_lob         IN OUT NOCOPY BLOB,
                               p_sheetname   IN            VARCHAR2);

    PROCEDURE end_worksheet (p_lob IN OUT NOCOPY BLOB);

    PROCEDURE set_styles (p_lob IN OUT NOCOPY BLOB);

    PROCEDURE run_query (p_lob          IN OUT NOCOPY BLOB,
                         p_sql          IN            VARCHAR2,
                         p_xls_header                 VARCHAR2 DEFAULT NULL,
                         p_captions                   VARCHAR2 DEFAULT 'T',
                         p_params                     t_params,
                         p_cols_width                 VARCHAR2 DEFAULT NULL, -- ширина стовпців. через кому
                         p_cols_wrap                  VARCHAR2 DEFAULT NULL, -- номери стовпців, що потребують переносу рядка. через кому
                         p_rpt_header                 CLOB DEFAULT NULL);
END API$RPT_XLS;
/


/* Formatted on 8/12/2025 5:58:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RPT.API$RPT_XLS
IS
    -------------- для роботи з xls
    PROCEDURE B_PUT_LINE (p_lob IN OUT NOCOPY BLOB, p_str VARCHAR2)
    IS
        l_buff    VARCHAR2 (32760);
        l_phase   INTEGER;
    BEGIN
        l_phase := 0;
        l_buff := p_str || CHR (13) || CHR (10);
        l_phase := 1;
        DBMS_LOB.writeappend (
            lob_loc   => p_lob,
            amount    => DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
            buffer    => UTL_RAW.cast_to_raw (l_buff));
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'B_PUT_LINE.' || l_phase || ': ' || CHR (10) || SQLERRM);
    END;

    PROCEDURE B_PUT_CLOB (p_lob IN OUT NOCOPY BLOB, p_clob CLOB)    --  #63169
    IS
        l_buff    CLOB;
        l_phase   INTEGER;
    BEGIN
        l_phase := 0;
        l_buff := p_clob || CHR (13) || CHR (10);
        l_phase := 1;
        DBMS_LOB.writeappend (
            lob_loc   => p_lob,
            amount    => DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
            buffer    => UTL_RAW.cast_to_raw (l_buff));
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'B_PUT_CLOB.' || l_phase || ': ' || CHR (10) || SQLERRM);
    END;

    --
    PROCEDURE start_workbook (p_lob IN OUT NOCOPY BLOB)
    IS
    BEGIN
        B_PUT_LINE (p_lob, '<?xml version="1.0" encoding="windows-1251"?>');
        B_PUT_LINE (
            p_lob,
            '<ss:Workbook xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">');
    END;

    PROCEDURE end_workbook (p_lob IN OUT NOCOPY BLOB)
    IS
    BEGIN
        B_PUT_LINE (p_lob, '</ss:Workbook>');
    END;

    --
    PROCEDURE start_worksheet (p_lob         IN OUT NOCOPY BLOB,
                               p_sheetname   IN            VARCHAR2)
    IS
    BEGIN
        B_PUT_LINE (p_lob, '<ss:Worksheet ss:Name="' || p_sheetname || '">');
        B_PUT_LINE (p_lob, '<ss:Table>');
    END;

    PROCEDURE end_worksheet (p_lob IN OUT NOCOPY BLOB)
    IS
    BEGIN
        B_PUT_LINE (p_lob, '</ss:Table>');
        B_PUT_LINE (p_lob, '</ss:Worksheet>');
    END;

    /*  PROCEDURE init_collumn(p_lob IN OUT NOCOPY BLOB, p_col_width number) IS
      BEGIN
        B_PUT_LINE(p_lob,'<ss:Column ss:AutoFitWidth="0" ss:Width="'||replace(to_char(p_col_width), ',','.')||'"/>');--84.75
      END;*/
    PROCEDURE init_collumn (p_lob         IN OUT NOCOPY BLOB,
                            p_col_width                 NUMBER,
                            p_col_index                 NUMBER DEFAULT NULL)
    IS
    BEGIN
        B_PUT_LINE (
            p_lob,
               '<ss:Column '
            || CASE
                   WHEN p_col_index > 0
                   THEN
                       'ss:Index="' || p_col_index || '" '
                   ELSE
                       ''
               END
            || 'ss:AutoFitWidth="0" ss:Width="'
            || REPLACE (TO_CHAR (p_col_width), ',', '.')
            || '"/>');                                                 --84.75
    END;

    PROCEDURE put_collumn (p_lob IN OUT NOCOPY BLOB, p_col_name VARCHAR2)
    IS
    BEGIN
        NULL;
    --B_PUT_LINE(p_lob,'<ss:Column ss:AutoFitWidth="0" ss:Width="'||replace(to_char(p_col_width), ',','.')||'"/>');--84.75
    END;

    --
    PROCEDURE set_styles (p_lob IN OUT NOCOPY BLOB)
    IS
    BEGIN
        B_PUT_LINE (p_lob, '<ss:Styles>');
        B_PUT_LINE (p_lob, '<ss:Style ss:ID="OracleDate">');
        B_PUT_LINE (p_lob,
                    '<ss:NumberFormat ss:Format="dd\.mm\.yyyy\ hh:mm:ss"/>');
        B_PUT_LINE (p_lob, '<ss:Borders>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (p_lob, '</ss:Borders>');
        B_PUT_LINE (p_lob, '</ss:Style>');

        B_PUT_LINE (p_lob, '<ss:Style ss:ID="OracleShortDate">');
        B_PUT_LINE (p_lob, '<ss:NumberFormat ss:Format="dd\.mm\.yyyy"/>');
        B_PUT_LINE (p_lob, '<ss:Borders>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (p_lob, '</ss:Borders>');
        B_PUT_LINE (p_lob, '</ss:Style>');

        B_PUT_LINE (p_lob, '<ss:Style ss:ID="Header">');
        B_PUT_LINE (
            p_lob,
            '<ss:Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>');
        B_PUT_LINE (p_lob, '<ss:Borders>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (p_lob, '</ss:Borders>');
        B_PUT_LINE (p_lob, '<ss:Font ss:Bold="1"/>');
        B_PUT_LINE (p_lob, '</ss:Style>');

        B_PUT_LINE (p_lob, '<ss:Style ss:ID="Header12">');
        B_PUT_LINE (
            p_lob,
            '<ss:Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>');
        B_PUT_LINE (p_lob, '<ss:Borders>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (p_lob, '</ss:Borders>');
        B_PUT_LINE (p_lob, '<ss:Font ss:Size="12" ss:Bold="1"/>');
        B_PUT_LINE (p_lob, '</ss:Style>');

        B_PUT_LINE (p_lob, '<ss:Style ss:ID="Caption">');
        B_PUT_LINE (
            p_lob,
            '<ss:Alignment ss:Horizontal="Left" ss:Vertical="Center" ss:WrapText="1"/>');
        B_PUT_LINE (p_lob, '<ss:Font ss:Bold="1"/>');
        B_PUT_LINE (p_lob, '</ss:Style>');

        B_PUT_LINE (p_lob, '<ss:Style ss:ID="Cell">');
        B_PUT_LINE (
            p_lob,
            '<ss:Alignment ss:Horizontal="Right" ss:Vertical="Center" ss:WrapText="0"/>');
        B_PUT_LINE (p_lob, '<ss:Borders>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (p_lob, '</ss:Borders>');
        B_PUT_LINE (p_lob, '</ss:Style>');

        B_PUT_LINE (p_lob, '<ss:Style ss:ID="CellWrp">');
        B_PUT_LINE (
            p_lob,
            '<ss:Alignment ss:Horizontal="Right" ss:Vertical="Center" ss:WrapText="1"/>');
        B_PUT_LINE (p_lob, '<ss:Borders>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (p_lob, '</ss:Borders>');
        B_PUT_LINE (p_lob, '</ss:Style>');

        B_PUT_LINE (p_lob, '<ss:Style ss:ID="Total1">');
        B_PUT_LINE (p_lob, '<ss:Borders>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (p_lob, '</ss:Borders>');
        B_PUT_LINE (p_lob, '<ss:Font ss:Bold="1" ss:Italic="1"/>');
        B_PUT_LINE (p_lob, '</ss:Style>');

        B_PUT_LINE (p_lob, '<ss:Style ss:ID="Total2">');
        B_PUT_LINE (p_lob, '<ss:Borders>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (p_lob, '</ss:Borders>');
        B_PUT_LINE (p_lob, '<ss:Font ss:Bold="1"/>');
        B_PUT_LINE (p_lob, '</ss:Style>');

        B_PUT_LINE (p_lob, '<ss:Style ss:ID="BorderTop">');
        B_PUT_LINE (p_lob, '<ss:Borders>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (p_lob, '</ss:Borders>');
        B_PUT_LINE (p_lob, '</ss:Style>');

        B_PUT_LINE (p_lob, '<ss:Style ss:ID="TextLeft">');
        B_PUT_LINE (
            p_lob,
            '<ss:Alignment ss:Horizontal="Left" ss:Vertical="Center" ss:WrapText="0"/>');
        B_PUT_LINE (p_lob, '<ss:Borders>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (p_lob, '</ss:Borders>');
        B_PUT_LINE (p_lob, '</ss:Style>');


        B_PUT_LINE (p_lob, '<ss:Style ss:ID="TextLeftWrp">');
        B_PUT_LINE (
            p_lob,
            '<ss:Alignment ss:Horizontal="Left" ss:Vertical="Center" ss:WrapText="1"/>');
        B_PUT_LINE (p_lob, '<ss:Borders>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (p_lob, '</ss:Borders>');
        B_PUT_LINE (p_lob, '</ss:Style>');

        B_PUT_LINE (p_lob, '<ss:Style ss:ID="TextRight">');
        B_PUT_LINE (
            p_lob,
            '<ss:Alignment ss:Horizontal="Right" ss:Vertical="Center" ss:WrapText="0"/>');
        B_PUT_LINE (p_lob, '<ss:Borders>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (
            p_lob,
            '<ss:Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>');
        B_PUT_LINE (p_lob, '</ss:Borders>');
        B_PUT_LINE (p_lob, '</ss:Style>');

        B_PUT_LINE (p_lob, '<ss:Style ss:ID="CaptionCentr">');
        B_PUT_LINE (
            p_lob,
            '<ss:Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>');
        B_PUT_LINE (p_lob, '<ss:Font ss:Bold="1"/>');
        B_PUT_LINE (p_lob, '</ss:Style>');

        -- B_PUT_LINE(p_lob,'</ss:Styles>');

        --  #63169
        B_PUT_Clob (
            p_lob,
            TO_CLOB (
                '<ss:Style ss:ID="s73">
   <ss:Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:ShrinkToFit="1"
    ss:WrapText="1"/>
   <ss:Borders>
    <ss:Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
    <ss:Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
    <ss:Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
    <ss:Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
   </ss:Borders>
   <ss:Font ss:FontName="Times New Roman"
    ss:Size="12" ss:Color="#000000" ss:Bold="1"/>
   <ss:Interior ss:Color="#D9D9D9" ss:Pattern="Solid"/>
  </ss:Style>
  <ss:Style ss:ID="s74">
   <ss:Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
   <ss:Borders>
    <ss:Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
    <ss:Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
    <ss:Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
    <ss:Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
   </ss:Borders>
   <ss:Font ss:FontName="Times New Roman"
    ss:Size="12" ss:Color="#000000" ss:Bold="1"/>
   <ss:Interior ss:Color="#D9D9D9" ss:Pattern="Solid"/>
  </ss:Style>
  <ss:Style ss:ID="s75">
   <ss:Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:Rotate="90"
    ss:ShrinkToFit="1" ss:WrapText="1"/>
   <ss:Borders>
    <ss:Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
    <ss:Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
    <ss:Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
    <ss:Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
   </ss:Borders>
   <ss:Font ss:FontName="Times New Roman"
    ss:Size="12" ss:Color="#000000" ss:Bold="1"/>
   <ss:Interior ss:Color="#D9D9D9" ss:Pattern="Solid"/>
  </ss:Style>
  <ss:Style ss:ID="s76">
   <ss:Alignment ss:Horizontal="Left" ss:Vertical="Top" ss:ShrinkToFit="1"
    ss:WrapText="1"/>
   <ss:Borders>
    <ss:Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
    <ss:Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
    <ss:Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
    <ss:Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
   </ss:Borders>
   <ss:Font ss:FontName="Times New Roman"
    ss:Size="12" ss:Color="#000000" ss:Bold="1"/>
   <ss:Interior ss:Color="#D9D9D9" ss:Pattern="Solid"/>
  </ss:Style>
  <ss:Style ss:ID="s77">
   <ss:Alignment ss:Horizontal="Center" ss:Vertical="Top" ss:ShrinkToFit="1"
    ss:WrapText="1"/>
   <ss:Borders>
    <ss:Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
    <ss:Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
    <ss:Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
    <ss:Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
   </ss:Borders>
   <ss:Font ss:FontName="Times New Roman"
    ss:Size="12" ss:Color="#000000" ss:Bold="1"/>
   <ss:Interior ss:Color="#D9D9D9" ss:Pattern="Solid"/>
  </ss:Style>
  <ss:Style ss:ID="s78">
   <ss:Alignment ss:Horizontal="Left" ss:Vertical="Top" ss:ShrinkToFit="1"
    ss:WrapText="1"/>
   <ss:Borders>
    <ss:Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
    <ss:Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
    <ss:Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
    <ss:Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
   </ss:Borders>
   <ss:Font ss:FontName="Times New Roman"
    ss:Size="12" ss:Color="#000000" ss:Bold="1"/>
   <ss:Interior ss:Color="#D9D9D9" ss:Pattern="Solid"/>
  </ss:Style>
  <ss:Style ss:ID="s79">
   <ss:Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
   <ss:Borders>
    <ss:Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
    <ss:Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
    <ss:Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
   </ss:Borders>
   <ss:Font ss:FontName="Times New Roman"
    ss:Size="12" ss:Color="#000000"/>
   <ss:Interior/>
  </ss:Style>'));

        B_PUT_LINE (p_lob, '</ss:Styles>');
    END;

    PROCEDURE run_query (p_lob          IN OUT NOCOPY BLOB,
                         p_sql          IN            VARCHAR2,
                         p_xls_header                 VARCHAR2 DEFAULT NULL,
                         p_captions                   VARCHAR2 DEFAULT 'T',
                         p_params                     t_params,
                         p_cols_width                 VARCHAR2 DEFAULT NULL, -- ширина стовпців. через кому
                         p_cols_wrap                  VARCHAR2 DEFAULT NULL, -- номери стовпців, що потребують переносу рядка. через кому
                         p_rpt_header                 CLOB DEFAULT NULL)
    IS
        v_v_val       VARCHAR2 (4000);
        v_n_val       NUMBER;
        v_d_val       DATE;
        v_ret         NUMBER;
        c_sql         NUMBER;
        l_exec        NUMBER;
        col_cnt       INTEGER;
        rec_tab       DBMS_SQL.desc_tab2; -- DBMS_SQL.DESC_TAB; --25.09.2020 LEV щоб не обмежувати довжину назви колонки до 30
        l_rpt_info    VARCHAR2 (4000);
        l_col_width   NUMBER;
    BEGIN
        c_sql := DBMS_SQL.OPEN_CURSOR;
        -- parse the SQL statement
        DBMS_SQL.PARSE (c_sql, p_sql, DBMS_SQL.NATIVE);
        -- start execution of the SQL statement
        l_exec := DBMS_SQL.EXECUTE (c_sql);

        start_workbook (p_lob);
        set_styles (p_lob);
        start_worksheet (p_lob, 'Звіт');

        -- get a description of the returned columns
        DBMS_SQL.describe_columns2 (c_sql, col_cnt, rec_tab); -- DBMS_SQL.DESCRIBE_COLUMNS(c_sql, col_cnt, rec_tab); --25.09.2020 LEV щоб не обмежувати довжину назви колонки до 30

        -- bind variables to columns

        FOR j IN 1 .. col_cnt
        LOOP
            -- #63169  20201109 перевіряєо чи не прийшли параметри ширини стовпців
            IF p_cols_width IS NOT NULL
            THEN
                BEGIN
                    l_col_width :=
                        TO_NUMBER (
                            SUBSTR (',' || p_cols_width || ',',
                                      INSTR (',' || p_cols_width || ',',
                                             ',',
                                             1,
                                             j)
                                    + 1,
                                      INSTR (',' || p_cols_width || ',',
                                             ',',
                                             1,
                                             j + 1)
                                    - INSTR (',' || p_cols_width || ',',
                                             ',',
                                             1,
                                             j)
                                    - 1));
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        l_col_width := NULL;
                END;
            ELSE
                l_col_width := NULL;
            END IF;

            CASE rec_tab (j).col_type
                WHEN 1
                THEN
                    DBMS_SQL.DEFINE_COLUMN (c_sql,
                                            j,
                                            v_v_val,
                                            4000);
                    init_collumn (
                        p_lob,
                        NVL (
                            l_col_width,
                            CASE
                                WHEN INSTR (UPPER (rec_tab (j).col_name),
                                            'FIO') >
                                     0
                                THEN
                                    200
                                WHEN INSTR (UPPER (rec_tab (j).col_name),
                                            'PIB') >
                                     0
                                THEN
                                    200
                                WHEN INSTR (UPPER (rec_tab (j).col_name),
                                            'NAME') >
                                     0
                                THEN
                                    200
                                ELSE
                                    100
                            END));
                WHEN 2
                THEN
                    DBMS_SQL.DEFINE_COLUMN (c_sql, j, v_n_val);
                    init_collumn (p_lob, NVL (l_col_width, 90));
                WHEN 12
                THEN
                    DBMS_SQL.DEFINE_COLUMN (c_sql, j, v_d_val);
                    init_collumn (p_lob, NVL (l_col_width, 60));
                ELSE
                    DBMS_SQL.DEFINE_COLUMN (c_sql,
                                            j,
                                            v_v_val,
                                            4000);
                    init_collumn (p_lob, NVL (l_col_width, 200));
            END CASE;
        /*      if rec_tab(j).col_type = 1 THEN
                  DBMS_SQL.DEFINE_COLUMN(c_sql,j,v_v_val,4000);
                  init_collumn(p_lob, 75);
              elsif rec_tab(j).col_type = 2 THEN
                  DBMS_SQL.DEFINE_COLUMN(c_sql,j,v_n_val);
                  init_collumn(p_lob, 30);
              elsif rec_tab(j).col_type = 12 THEN
                  DBMS_SQL.DEFINE_COLUMN(c_sql,j,v_d_val);
                  init_collumn(p_lob, 30);
              ELSE
                DBMS_SQL.DEFINE_COLUMN(c_sql,j,v_v_val,4000);
                init_collumn(p_lob, 75);
              END IF;*/
        END LOOP;

        -- Назва
        B_PUT_LINE (p_lob, '<ss:Row ss:AutoFitHeight="0" ss:Height="50">');
        B_PUT_LINE (
            p_lob,
               '<ss:Cell ss:StyleID="Header" ss:MergeAcross="'
            || (col_cnt - 1)     /*(trunc(nvl(length(p_xls_header), 1)/5)+1)*/
            || '">');
        B_PUT_LINE (
            p_lob,
            '<ss:Data ss:Type="String">' || p_xls_header || '</ss:Data>');
        B_PUT_LINE (p_lob, '</ss:Cell>');
        B_PUT_LINE (p_lob, '</ss:Row>');
        -- виконавець
        l_rpt_info :=
               uss_rpt_context.GetContext (uss_rpt_context.gLogin)
            || ';'
            || TO_CHAR (SYSDATE, 'dd.mm.yyyy hh24:mi:ss');
        B_PUT_LINE (p_lob, '<ss:Row>');
        B_PUT_LINE (
            p_lob,
               '<ss:Cell ss:StyleID="Header" ss:MergeAcross="'
            || (col_cnt - 1)       /*(trunc(nvl(length(l_rpt_info), 1)/5)+1)*/
            || '">');
        B_PUT_LINE (
            p_lob,
            '<ss:Data ss:Type="String">' || l_rpt_info || '</ss:Data>');
        B_PUT_LINE (p_lob, '</ss:Cell>');
        B_PUT_LINE (p_lob, '</ss:Row>');

        -- Параметри
        FOR i IN 1 .. p_params.COUNT
        LOOP
            B_PUT_LINE (p_lob, '<ss:Row>');
            B_PUT_LINE (p_lob, '<ss:Cell ss:StyleID="TextLeft">');
            B_PUT_LINE (
                p_lob,
                   '<ss:Data ss:Type="String">'
                || p_params (i).p_name
                || '</ss:Data>');
            B_PUT_LINE (p_lob, '</ss:Cell>');
            B_PUT_LINE (p_lob, '<ss:Cell ss:StyleID="TextRight">');
            B_PUT_LINE (
                p_lob,
                   '<ss:Data ss:Type="String">'
                || p_params (i).p_value
                || '</ss:Data>');
            B_PUT_LINE (p_lob, '</ss:Cell>');
            B_PUT_LINE (p_lob, '</ss:Row>');
        END LOOP;

        ------------------

        IF p_captions = 'T'
        THEN
            -- Output the column headers
            B_PUT_LINE (p_lob, '<ss:Row>');

            FOR j IN 1 .. col_cnt
            LOOP
                B_PUT_LINE (p_lob, '<ss:Cell ss:StyleID="Header">');
                B_PUT_LINE (
                    p_lob,
                       '<ss:Data ss:Type="String">'
                    || rec_tab (j).col_name
                    || '</ss:Data>');
                B_PUT_LINE (p_lob, '</ss:Cell>');
            END LOOP;

            B_PUT_LINE (p_lob, '</ss:Row>');
        ELSIF p_captions = 'B'
        THEN                                    --  #63169  шаблон шапки звіту
            B_PUT_CLOB (p_lob, p_rpt_header);
        END IF;

        -- Output the data
        LOOP
            v_ret := DBMS_SQL.FETCH_ROWS (c_sql);
            EXIT WHEN v_ret = 0;
            B_PUT_LINE (p_lob, '<ss:Row>');

            FOR j IN 1 .. col_cnt
            LOOP
                CASE rec_tab (j).col_type
                    WHEN 1
                    THEN
                        DBMS_SQL.COLUMN_VALUE (c_sql, j, v_v_val);
                        --B_PUT_LINE(p_lob,'<ss:Cell ss:StyleID="TextLeft">');
                        -- #63169 розрив текстового рядка  в клітинці

                        B_PUT_LINE (
                            p_lob,
                               '<ss:Cell ss:StyleID="'
                            || CASE
                                   WHEN INSTR (',' || p_cols_wrap || ',',
                                               ',' || j || ',') >
                                        0
                                   THEN
                                       'TextLeftWrp'
                                   ELSE
                                       'TextLeft'
                               END
                            || '">');

                        B_PUT_LINE (
                            p_lob,
                               '<ss:Data ss:Type="String">'
                            || v_v_val
                            || '</ss:Data>');
                        B_PUT_LINE (p_lob, '</ss:Cell>');
                    WHEN 2
                    THEN
                        DBMS_SQL.COLUMN_VALUE (c_sql, j, v_n_val);
                        B_PUT_LINE (p_lob, '<ss:Cell ss:StyleID="Cell">');
                        B_PUT_LINE (
                            p_lob,
                               '<ss:Data ss:Type="Number">'
                            || REPLACE (TO_CHAR (v_n_val), ',', '.')
                            || '</ss:Data>');
                        B_PUT_LINE (p_lob, '</ss:Cell>');
                    WHEN 12
                    THEN
                        DBMS_SQL.COLUMN_VALUE (c_sql, j, v_d_val);
                        --    B_PUT_LINE(p_lob,'<ss:Cell ss:StyleID="OracleDate">');
                        --    B_PUT_LINE(p_lob,'<ss:Data ss:Type="DateTime">'||to_char(v_d_val,'dd.mm.yyyy hh24:mi:ss')||'</ss:Data>');
                        B_PUT_LINE (
                            p_lob,
                            CASE
                                WHEN v_d_val IS NULL
                                THEN
                                    '<ss:Cell ss:StyleID="Cell">'  -- 20201116
                                WHEN TRIM (v_d_val) = v_d_val
                                THEN
                                    '<ss:Cell ss:StyleID="OracleShortDate">'
                                ELSE
                                    '<ss:Cell ss:StyleID="OracleDate">'
                            END);
                        B_PUT_LINE (
                            p_lob,
                               CASE
                                   WHEN v_d_val IS NULL
                                   THEN
                                       '<ss:Data ss:Type="String">' -- 20201116
                                   WHEN v_d_val <
                                        TO_DATE ('01.01.1900', 'dd.mm.yyyy')
                                   THEN
                                          '<ss:Data ss:Type="String">'
                                       || v_d_val
                                   WHEN TRIM (v_d_val) = v_d_val
                                   THEN
                                          '<ss:Data ss:Type="DateTime">'
                                       || TO_CHAR (v_d_val, 'yyyy-mm-dd')
                                   ELSE
                                          '<ss:Data ss:Type="DateTime">'
                                       || REPLACE (
                                              TO_CHAR (
                                                  v_d_val,
                                                  'yyyy-mm-dd hh24:mi:ss'),
                                              ' ',
                                              'T')
                               END
                            || '</ss:Data>');
                        B_PUT_LINE (p_lob, '</ss:Cell>');
                    ELSE
                        DBMS_SQL.COLUMN_VALUE (c_sql, j, v_v_val);
                        B_PUT_LINE (p_lob, '<ss:Cell>');
                        B_PUT_LINE (
                            p_lob,
                               '<ss:Data ss:Type="String">'
                            || v_v_val
                            || '</ss:Data>');
                        B_PUT_LINE (p_lob, '</ss:Cell>');
                END CASE;
            END LOOP;

            B_PUT_LINE (p_lob, '</ss:Row>');
        END LOOP;

        DBMS_SQL.CLOSE_CURSOR (c_sql);

        end_worksheet (p_lob);
        end_workbook (p_lob);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'run_query: '
                || CHR (10)
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    END;
BEGIN
    -- Initialization
    NULL;
END API$RPT_XLS;
/