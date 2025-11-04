/* Formatted on 8/12/2025 5:55:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.SLF$UTL
IS
    -- Author  : LESHA
    -- Created : 21.05.2022 18:05:23
    -- Purpose :
    TYPE type_rec_str IS RECORD
    (
        i       NUMBER (10),
        str1    VARCHAR2 (1000),
        str2    VARCHAR2 (1000),
        str3    VARCHAR2 (1000)
    );

    TYPE type_tbl_str IS TABLE OF type_rec_str;

    --================================================--
    --  INSERT dic_dd and dic_dv
    --================================================--
    PROCEDURE Insert_Dd_2 (p_Name       VARCHAR2,
                           p_Viewname   VARCHAR2,
                           p_Str_Sql    VARCHAR2);

    --================================================--
    --  INSERT NDI_DICT_CONFIG
    --================================================--
    FUNCTION Insert_Ndc (p_Viewname          VARCHAR2,
                         p_Ndc_Systems       VARCHAR2,
                         p_Is_Client_Cache   VARCHAR2:= 'T',
                         p_Is_Server_Cache   VARCHAR2:= 'T',
                         p_Is_Global         VARCHAR2:= 'T')
        RETURN NUMBER;

    --================================================--
    --  INSERT NDI_PARAM_TYPE
    --================================================--
    FUNCTION Insert_PT (p_pt_name     VARCHAR2,
                        p_pt_ndc      VARCHAR2,
                        p_edit_type   VARCHAR2 DEFAULT 'DDLB')
        RETURN NUMBER;

    FUNCTION Get_PT_id
        RETURN NUMBER;

    --================================================--
    --   створення до param_type
    --================================================--
    PROCEDURE create_attr (p_name         VARCHAR2,            -- наіменування
                           p_view         VARCHAR2, -- представленння v_ddn_***
                           p_systems      VARCHAR2, -- перелік підсистем '#uss_visit#uss_esr#uss_rnsp'
                           pt_edit_type   VARCHAR2:= 'DDLB',  --  pt_edit_type
                           p_list_item    VARCHAR2               -- 'cod#name'
                                                  );

    PROCEDURE create_attr_3 (p_name        VARCHAR2,           -- наіменування
                             p_view        VARCHAR2, -- представленння v_ddn_***
                             p_systems     VARCHAR2, -- перелік підсистем '#uss_visit#uss_esr#uss_rnsp'
                             p_list_item   VARCHAR2              -- 'cod#name'
                                                   );

    PROCEDURE create_attr_from_DD (p_view         VARCHAR2, -- представленння v_ddn_***
                                   p_systems      VARCHAR2, -- перелік підсистем '#uss_visit#uss_esr#uss_rnsp'
                                   pt_edit_type   VARCHAR2:= 'DDLB' --  pt_edit_type
                                                                   );

    --================================================--
    --
    --================================================--
    PROCEDURE Create_Dd_View;

    --================================================--
    --  Опис складу документу в HTML
    --================================================--
    FUNCTION Get_ndt_Info (p_ndt NUMBER)
        RETURN CLOB;

    FUNCTION Get_Ndi_Nst_Docs (p_Nst_Id IN NUMBER)
        RETURN SYS_REFCURSOR;

    FUNCTION Get_Ndi_Nst_Attrs (p_Nst_Id IN NUMBER)
        RETURN SYS_REFCURSOR;

    FUNCTION Get_Nda_Values (p_Ndc_Sql CLOB, p_Ndc_Code VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION get_record_str (txt         VARCHAR2,
                             delimiter   VARCHAR2 DEFAULT CHR (10))
        RETURN type_tbl_str
        PIPELINED;
END Slf$utl;
/


/* Formatted on 8/12/2025 5:55:33 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.SLF$UTL
IS
    g_Ndc_id   NUMBER;
    g_PT_id    NUMBER;

    --================================================--
    --  INSERT dic_dd and dic_dv
    --================================================--
    PROCEDURE Insert_Dd_3 (p_Name       VARCHAR2,
                           p_Viewname   VARCHAR2,
                           p_Str_Sql    VARCHAR2)
    IS
        Dd   Dic_Dd%ROWTYPE;
        Dv   Dic_Dv%ROWTYPE;

        CURSOR Txt2row (Txt VARCHAR2)
        IS
            WITH
                Str
                AS
                    (    SELECT REGEXP_SUBSTR (Txt,
                                               '[^' || CHR (10) || ']+',
                                               1,
                                               LEVEL)    AS Str,
                                LEVEL                    AS i
                           FROM DUAL
                     CONNECT BY LEVEL <=
                                  LENGTH (
                                      REGEXP_REPLACE (
                                          Txt,
                                          '[^' || CHR (10) || ']*'))
                                + 1)
            SELECT REGEXP_SUBSTR (Str.Str,
                                  '[^#]+',
                                  1,
                                  1)    AS Cod,
                   REGEXP_SUBSTR (Str.Str,
                                  '[^#]+',
                                  1,
                                  2)    AS NAME,
                   i
              FROM Str;
    BEGIN
        --dd.didi_id      := ID;
        --dd.didi_srtordr := srtordr;
        Dd.Didi_Didi := 3;

        SELECT MAX (Didi_Id) + 1, MAX (Didi_Srtordr) + 1
          INTO Dd.Didi_Id, Dd.Didi_Srtordr
          FROM Dic_Dd                            /*
                                     WHERE Didi_Didi = 3*/
                     ;

        DBMS_OUTPUT.Put_Line ('didi_id=' || Dd.Didi_Id);
        Dd.Didi_Tp := 'D';
        Dd.Didi_Name := p_Name;
        Dd.Didi_Descript := p_Name;
        Dd.Didi_Viewname := p_Viewname;

        INSERT INTO Dic_Dd
             VALUES Dd;

        FOR d IN Txt2row (p_Str_Sql)
        LOOP
            Dv.Dic_Didi := Dd.Didi_Id;
            Dv.Dic_Value := d.Cod;
            Dv.Dic_Code := d.Cod;
            Dv.Dic_Name := d.Name;
            Dv.Dic_Sname := SUBSTR (d.Name, 1, 100);
            Dv.Dic_Srtordr := d.i;
            Dv.Dic_St := 'A';

            INSERT INTO Dic_Dv
                 VALUES Dv;
        END LOOP;
    END;

    PROCEDURE Insert_Dd_2 (p_Name       VARCHAR2,
                           p_Viewname   VARCHAR2,
                           p_Str_Sql    VARCHAR2)
    IS
        Dd   Dic_Dd%ROWTYPE;
        Dv   Dic_Dv%ROWTYPE;

        CURSOR Txt2row (Txt VARCHAR2)
        IS
            WITH
                Str
                AS
                    (    SELECT REGEXP_SUBSTR (Txt,
                                               '[^' || CHR (10) || ']+',
                                               1,
                                               LEVEL)    AS Str,
                                LEVEL                    AS i
                           FROM DUAL
                     CONNECT BY LEVEL <=
                                  LENGTH (
                                      REGEXP_REPLACE (
                                          Txt,
                                          '[^' || CHR (10) || ']*'))
                                + 1)
            SELECT REGEXP_SUBSTR (Str.Str,
                                  '[^#]+',
                                  1,
                                  1)    AS Cod,
                   REGEXP_SUBSTR (Str.Str,
                                  '[^#]+',
                                  1,
                                  2)    AS NAME,
                   i
              FROM Str;
    BEGIN
        --dd.didi_id      := ID;
        --dd.didi_srtordr := srtordr;
        Dd.Didi_Didi := 2;

        SELECT MAX (Didi_Id) + 1, MAX (Didi_Srtordr) + 1
          INTO Dd.Didi_Id, Dd.Didi_Srtordr
          FROM Dic_Dd
         WHERE Didi_Didi = 2 AND Didi_Id < 3000;

        DBMS_OUTPUT.Put_Line ('didi_id=' || Dd.Didi_Id);
        Dd.Didi_Tp := 'D';
        Dd.Didi_Name := p_Name;
        Dd.Didi_Descript := p_Name;
        Dd.Didi_Viewname := p_Viewname;

        INSERT INTO Dic_Dd
             VALUES Dd;

        FOR d IN Txt2row (p_Str_Sql)
        LOOP
            Dv.Dic_Didi := Dd.Didi_Id;
            Dv.Dic_Value := d.Cod;
            Dv.Dic_Code := d.Cod;
            Dv.Dic_Name := d.Name;
            Dv.Dic_Sname := SUBSTR (d.Name, 1, 100);
            Dv.Dic_Srtordr := d.i;
            Dv.Dic_St := 'A';

            INSERT INTO Dic_Dv
                 VALUES Dv;
        END LOOP;
    END;

    --================================================--
    --  INSERT NDI_DICT_CONFIG
    --================================================--
    FUNCTION Insert_Ndc (p_Viewname          VARCHAR2,
                         p_Ndc_Systems       VARCHAR2,
                         p_Is_Client_Cache   VARCHAR2:= 'T',
                         p_Is_Server_Cache   VARCHAR2:= 'T',
                         p_Is_Global         VARCHAR2:= 'T')
        RETURN NUMBER
    IS
        Dc   Ndi_Dict_Config%ROWTYPE;
    BEGIN
        Dc.Ndc_id := id_ndi_dict_config (0);
        Dc.Ndc_Tp := 'DDLB';
        Dc.Ndc_Code := p_Viewname;
        Dc.Ndc_Sql :=
               'SELECT t.DIC_VALUE AS ID, t.DIC_SNAME AS NAME FROM uss_ndi.'
            || UPPER (p_Viewname)
            || ' t ORDER BY t.DIC_SRTORDR';
        Dc.Ndc_Fields := 'ID,,NAME';
        Dc.Ndc_Caption_Template := '{1}';
        Dc.Ndc_Is_Client_Cache := p_Is_Client_Cache;
        Dc.Ndc_Is_Server_Cache := p_Is_Server_Cache;
        Dc.Ndc_Is_Global := p_Is_Global;
        Dc.Ndc_Systems := p_Ndc_Systems;

        INSERT INTO Ndi_Dict_Config
             VALUES Dc;

        RETURN Dc.Ndc_id;
    END;

    --================================================--
    --  INSERT NDI_PARAM_TYPE
    --================================================--
    FUNCTION Insert_PT (p_pt_name     VARCHAR2,
                        p_pt_ndc      VARCHAR2,
                        p_edit_type   VARCHAR2 DEFAULT 'DDLB')
        RETURN NUMBER
    IS
        pt   NDI_PARAM_TYPE%ROWTYPE;
    BEGIN
        pt.pt_id := id_ndi_param_type (0);
        pt.pt_name := p_pt_name;
        pt.pt_ndc := p_pt_ndc;
        pt.pt_edit_type := p_edit_type;
        pt.pt_data_type := 'STRING';
        pt.history_status := 'A';

        INSERT INTO NDI_PARAM_TYPE
             VALUES pt;

        RETURN pt.pt_id;
    END;

    --================================================--
    FUNCTION Get_PT_id
        RETURN NUMBER
    IS
    BEGIN
        RETURN g_PT_id;
    END;

    --================================================--
    --
    --================================================--
    PROCEDURE create_attr (p_name         VARCHAR2,            -- наіменування
                           p_view         VARCHAR2, -- представленння v_ddn_***
                           p_systems      VARCHAR2, -- перелік підсистем '#uss_visit#uss_esr#uss_rnsp'
                           pt_edit_type   VARCHAR2:= 'DDLB',  --  pt_edit_type
                           p_list_item    VARCHAR2               -- 'cod#name'
                                                  )
    AS
        l_Ndc_id   NUMBER;
    BEGIN
        SLF$UTL.Insert_DD_2 (p_name, p_view, p_list_item);

        l_Ndc_id := SLF$UTL.Insert_NDC (p_view, p_Systems);
        G_PT_id := SLF$UTL.Insert_PT (p_name, l_Ndc_id, pt_edit_type);

        dbms_output_put_lines ('Ndc_id = ' || l_Ndc_id);
        dbms_output_put_lines ('PT_id  = ' || G_PT_id);
    END;

    --================================================--
    --
    --================================================--
    PROCEDURE create_attr_from_DD (p_view         VARCHAR2, -- представленння v_ddn_***
                                   p_systems      VARCHAR2, -- перелік підсистем '#uss_visit#uss_esr#uss_rnsp'
                                   pt_edit_type   VARCHAR2:= 'DDLB' --  pt_edit_type
                                                                   )
    AS
        l_Ndc_id   NUMBER;
        L_name     VARCHAR2 (200);                             -- наіменування
    BEGIN
        SELECT t.didi_name
          INTO L_name
          FROM dic_dd t
         WHERE UPPER (t.didi_viewname) = UPPER (p_view);

        l_Ndc_id := SLF$UTL.Insert_NDC (p_view, p_Systems);
        G_PT_id := SLF$UTL.Insert_PT (l_name, l_Ndc_id, pt_edit_type);

        dbms_output_put_lines ('Ndc_id = ' || l_Ndc_id);
        dbms_output_put_lines ('PT_id  = ' || G_PT_id);
    END;

    --================================================--
    --
    --================================================--
    PROCEDURE create_attr_3 (p_name        VARCHAR2,           -- наіменування
                             p_view        VARCHAR2, -- представленння v_ddn_***
                             p_systems     VARCHAR2, -- перелік підсистем '#uss_visit#uss_esr#uss_rnsp'
                             p_list_item   VARCHAR2              -- 'cod#name'
                                                   )
    AS
        l_Ndc_id   NUMBER;
    BEGIN
        SLF$UTL.Insert_DD_3 (p_name, p_view, p_list_item);

        l_Ndc_id := SLF$UTL.Insert_NDC (p_view, p_Systems);
        G_PT_id := SLF$UTL.Insert_PT (p_name, l_Ndc_id);

        dbms_output_put_lines ('Ndc_id = ' || l_Ndc_id);
        dbms_output_put_lines ('PT_id  = ' || G_PT_id);
    END;

    --================================================--
    --
    --================================================--
    PROCEDURE Create_Dd_View
    IS
    BEGIN
        Ikis_Dd.Create_Dd_View;
    END;

    --================================================--
    --  Опис складу документу в HTML
    --================================================--
    FUNCTION Get_ndt_Info (p_ndt NUMBER)
        RETURN CLOB
    IS
        l_html   CLOB;
    BEGIN
        WITH
            atr
            AS
                (SELECT nda_ndt,
                        NVL (TO_CHAR (nng.nng_id), '_')
                            AS nng_id,
                        NVL (nng.nng_name, '_')
                            AS nng_name,
                        nda.nda_id,
                        NVL (nda.nda_name, npt.pt_name)
                            AS nda_name,
                        npt.pt_data_type,
                        ndc.NDC_CODE,
                        COUNT (1) OVER (PARTITION BY nda_ndt, nng.nng_id)
                            AS nda_count,
                        CASE
                            WHEN FIRST_VALUE (nda.nda_id)
                                     OVER (PARTITION BY nda_ndt, nng.nng_id
                                           ORDER BY nda.nda_id) =
                                 nda.nda_id
                            THEN
                                1
                            ELSE
                                0
                        END
                            AS FIRST_nda
                   FROM uss_ndi.v_ndi_document_attr  nda
                        LEFT JOIN uss_ndi.v_ndi_nda_group nng
                            ON nng.nng_id = nda.nda_nng
                        LEFT JOIN uss_ndi.v_ndi_param_type npt
                            ON npt.pt_id = nda.nda_pt
                        LEFT JOIN uss_ndi.v_NDI_DICT_CONFIG ndc
                            ON ndc.ndc_id = npt.pt_ndc),
            tr
            AS
                (  SELECT nda_ndt,
                          XMLAGG (XMLELEMENT (
                                      "tr",
                                      XMLCONCAT (
                                          CASE
                                              WHEN FIRST_nda = 1
                                              THEN
                                                  XMLELEMENT (
                                                      "td",
                                                      XMLATTRIBUTES (
                                                          nda_count
                                                              AS "rowspan"),
                                                      nng_id)
                                              WHEN nda_count = 1
                                              THEN
                                                  XMLELEMENT ("td", nng_id)
                                          END,
                                          CASE
                                              WHEN FIRST_nda = 1
                                              THEN
                                                  XMLELEMENT (
                                                      "td",
                                                      XMLATTRIBUTES (
                                                          nda_count
                                                              AS "rowspan"),
                                                      nng_name)
                                              WHEN nda_count = 1
                                              THEN
                                                  XMLELEMENT ("td", nng_name)
                                          END,
                                          XMLELEMENT ("td", nda_id),
                                          XMLELEMENT ("td", nda_name),
                                          XMLELEMENT ("td", pt_data_type),
                                          XMLELEMENT ("td", NDC_CODE)))
                                  ORDER BY nng_id, nda_id)    AS xml_tr
                     FROM atr
                 GROUP BY nda_ndt),
            tbl
            AS
                (SELECT nda_ndt,
                        XMLELEMENT (
                            "table",
                            XMLATTRIBUTES (1 AS "border"),
                            XMLCONCAT (
                                XMLELEMENT (
                                    "col",
                                    XMLATTRIBUTES ('2%' AS "width",
                                                   'right' AS "align")),
                                XMLELEMENT (
                                    "col",
                                    XMLATTRIBUTES ('15%' AS "width",
                                                   'left' AS "align")),
                                XMLELEMENT (
                                    "col",
                                    XMLATTRIBUTES ('3%' AS "width",
                                                   'right' AS "align")),
                                XMLELEMENT (
                                    "col",
                                    XMLATTRIBUTES ('40%' AS "width",
                                                   'left' AS "align")),
                                XMLELEMENT ("tb", xml_tr)))    AS xml_table
                   FROM tr)
        SELECT                                     --ndt.ndt_id, ndt.ndt_name,
                  '<!DOCTYPE html>'
               || XMLELEMENT (
                      "html",
                      XMLCONCAT (XMLELEMENT ("head", ''),
                                 XMLELEMENT ("body", xml_table))).getclobval ()    AS "XMLROOT"
          INTO l_html
          FROM uss_ndi.v_ndi_document_type  ndt
               JOIN tbl ON ndt.ndt_id = nda_ndt
         WHERE ndt.ndt_id = p_ndt;

        RETURN l_html;
    END;

    --================================================--
    -- Вивантаження довідників типів документів та
    -- атрибутів в залежності від типу послуги
    --================================================--
    FUNCTION Get_Ndi_Nst_Docs (p_Nst_Id IN NUMBER)
        RETURN SYS_REFCURSOR
    IS
        l_Result   SYS_REFCURSOR;
    BEGIN
        OPEN l_Result FOR
              SELECT ROW_NUMBER () OVER (ORDER BY Ndt_Id)    AS "№ з/п",
                     Ndt_Id                                  AS "Код",
                     Ndt_Name                                AS "Назва",
                     LISTAGG (
                            '('
                         || CASE
                                WHEN c.Nndc_App_Tp IS NOT NULL
                                THEN
                                       '"Тип учасника" = "'
                                    || c.Nndc_App_Tp
                                    || '"'
                            END
                         || CASE
                                WHEN     c.Nndc_App_Tp IS NOT NULL
                                     AND c.Nndc_Val_String IS NOT NULL
                                THEN
                                    ' ТА '
                            END
                         || CASE
                                WHEN c.Nndc_Val_String IS NOT NULL
                                THEN
                                       '"'
                                    || n.Nda_Name
                                    || '" = "'
                                    || c.Nndc_Val_String
                                    || '"'
                            END
                         || ')',
                         ' АБО ')
                     WITHIN GROUP (ORDER BY 1)               "Документ обов'язковий за умови"
                FROM Uss_Ndi.Ndi_Nst_Doc_Config c
                     JOIN Uss_Ndi.Ndi_Document_Type t ON c.Nndc_Ndt = t.Ndt_Id
                     LEFT JOIN Uss_Ndi.v_Ddn_App_Tp a
                         ON c.Nndc_App_Tp = a.Dic_Value
                     LEFT JOIN Uss_Ndi.Ndi_Document_Attr n
                         ON c.Nndc_Nda = n.Nda_Id
               WHERE     c.Nndc_Nst IN (p_Nst_Id)
                     AND c.Nndc_Is_Req = 'T'
                     AND c.History_Status = 'A'
            GROUP BY Ndt_Id, Ndt_Name
            ORDER BY 1;

        RETURN l_Result;
    END;

    FUNCTION Get_Ndi_Nst_Attrs (p_Nst_Id IN NUMBER)
        RETURN SYS_REFCURSOR
    IS
        l_Result   SYS_REFCURSOR;
    BEGIN
        OPEN l_Result FOR
              SELECT ROW_NUMBER () OVER (ORDER BY a.Nda_Ndt, a.Nda_Order)
                         AS "№ з/п",
                     a.Nda_Id
                         AS "Код атрибута",
                     a.Nda_Ndt
                         AS "Код документа",
                     a.Nda_Name
                         AS "Назва атрибута",
                     DECODE (a.Nda_Is_Req, 'T', '+', '-')
                         AS "Обов'язковість",
                     DECODE (p.Pt_Data_Type,
                             'STRING', 'APDA_VAL_STRING',
                             'DATE', 'APDA_VAL_DT',
                             'INTEGER', 'APDA_VAL_INT',
                             'ID', 'APDA_VAL_ID',
                             'SUM', 'APDA_VAL_SUM')
                         AS "Назва тегу в блоці Attribute",
                     Get_Nda_Values (Dc.Ndc_Sql, Dc.Ndc_Code)
                         AS "Можливі значення",
                     a.Nda_Desc
                         AS "Примітка"
                FROM Uss_Ndi.Ndi_Document_Attr a
                     JOIN Uss_Ndi.Ndi_Param_Type p ON a.Nda_Pt = p.Pt_Id
                     LEFT JOIN Uss_Ndi.Ndi_Dict_Config Dc
                         ON p.Pt_Ndc = Dc.Ndc_Id
               WHERE     a.Nda_Ndt IN
                             (SELECT c.Nndc_Ndt
                                FROM Uss_Ndi.Ndi_Nst_Doc_Config c
                               WHERE     c.Nndc_Nst IN (p_Nst_Id)
                                     AND c.Nndc_Is_Req = 'T'
                                     AND c.History_Status = 'A')
                     AND a.History_Status = 'A'
            ORDER BY 1;

        RETURN l_Result;
    END;

    FUNCTION Get_Nda_Values (p_Ndc_Sql CLOB, p_Ndc_Code VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Cur    SYS_REFCURSOR;
        l_Id     VARCHAR2 (100);
        l_Name   VARCHAR2 (4000);
        l_Res    VARCHAR2 (4000) := '';
    BEGIN
        IF p_Ndc_Sql IS NOT NULL
        THEN
            BEGIN
                OPEN l_Cur FOR p_Ndc_Sql;

                LOOP
                    FETCH l_Cur INTO l_Id, l_Name;

                    EXIT WHEN l_Cur%NOTFOUND;
                    l_Res :=
                           l_Res
                        || l_Id
                        || ' - '
                        || REPLACE (REPLACE (l_Name, CHR (13)), CHR (10))
                        || ';';
                END LOOP;
            EXCEPTION
                WHEN OTHERS
                THEN
                    l_Res :=
                           l_Res
                        || 'Довідник '
                        || RTRIM (UPPER (p_Ndc_Code), 'V_');
            END;
        END IF;

        RETURN l_Res;
    END;

    --================================================--
    --
    --================================================--
    FUNCTION get_record_str (txt         VARCHAR2,
                             delimiter   VARCHAR2 DEFAULT CHR (10))
        RETURN type_tbl_str
        PIPELINED
    IS
        CURSOR lesha IS
            WITH
                Str
                AS
                    (    SELECT REGEXP_SUBSTR (txt,
                                               '[^' || delimiter || ']+',
                                               1,
                                               LEVEL)    AS Str,
                                LEVEL                    AS i
                           FROM DUAL
                     CONNECT BY LEVEL <=
                                  LENGTH (
                                      REGEXP_REPLACE (
                                          txt,
                                          '[^' || delimiter || ']*'))
                                + 1)
            SELECT REGEXP_SUBSTR (Str.Str,
                                  '[^#]+',
                                  1,
                                  1)    AS str1,
                   REGEXP_SUBSTR (Str.Str,
                                  '[^#]+',
                                  1,
                                  2)    AS str2,
                   REGEXP_SUBSTR (Str.Str,
                                  '[^#]+',
                                  1,
                                  3)    AS str3,
                   i
              FROM Str;

        rec   type_rec_str;
    BEGIN
        FOR r IN lesha
        LOOP
            rec.i := r.i;
            rec.str1 := TRIM (r.str1);
            rec.str2 := TRIM (r.str2);
            rec.str3 := TRIM (r.str3);
            PIPE ROW (rec);
        END LOOP;

        RETURN;
    END;
END Slf$utl;
/