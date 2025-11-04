/* Formatted on 8/12/2025 6:06:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_FINZVIT.FINZVIT_METADATA
IS
    -- Author  : MAXYM
    -- Created : 18.10.2017 17:39:29
    -- Purpose : Работа с метаданными

    -- очистка екселевского мусора
    FUNCTION ExcelTrim (val VARCHAR2)
        RETURN VARCHAR2
        DETERMINISTIC;

    -- Очищает непонятные символы, которые добавляет ексель. Раситывает уровни заголовков
    PROCEDURE Setup;

    PROCEDURE GetFullMetadata (p_RptPackTemplate       OUT SYS_REFCURSOR,
                               p_RptTemplate           OUT SYS_REFCURSOR,
                               p_RptInPackTemplate     OUT SYS_REFCURSOR,
                               p_RptFrameTemplate      OUT SYS_REFCURSOR,
                               p_FramesInRptTemplate   OUT SYS_REFCURSOR,
                               p_RptRowTp              OUT SYS_REFCURSOR,
                               p_RptColTp              OUT SYS_REFCURSOR,
                               p_RtpCellSpec           OUT SYS_REFCURSOR,
                               p_RptPackConstraints    OUT SYS_REFCURSOR,
                               p_imports               OUT SYS_REFCURSOR,
                               p_exports               OUT SYS_REFCURSOR);

    PROCEDURE GetUserMenu (p_top      OUT SYS_REFCURSOR,
                           p_detail   OUT SYS_REFCURSOR);


    FUNCTION GetRtId (rtCode IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION GetRftId (rtCode IN VARCHAR2, rrtCode IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION GetRrtId (rtCode IN VARCHAR2, rrtCode IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION GetRctId (rtCode    IN VARCHAR2,
                       rrtCode   IN VARCHAR2,
                       rctCode   IN VARCHAR2)
        RETURN NUMBER;
END FINZVIT_METADATA;
/


GRANT EXECUTE ON IKIS_FINZVIT.FINZVIT_METADATA TO DNET_PROXY
/


/* Formatted on 8/12/2025 6:06:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_FINZVIT.FINZVIT_METADATA
IS
    FUNCTION ExcelTrim (val VARCHAR2)
        RETURN VARCHAR2
        DETERMINISTIC
    IS
    BEGIN
        RETURN LTRIM (RTRIM (val, CHR (160) || ' ' || CHR (10) || CHR (13)),
                      CHR (160) || ' ' || CHR (10) || CHR (13));
    END;

    PROCEDURE SetupRptColTp
    IS
        maxlevel   NUMBER;
    BEGIN
        UPDATE rpt_col_tp t
           SET RCT_LEVEL =
                   (SELECT   (    SELECT MAX (LEVEL) + 1
                                    FROM rpt_col_tp v
                              START WITH v.rct_rft = t.RCT_RFT
                              CONNECT BY PRIOR v.RCT_RCT = v.RCT_ID)
                           - (    SELECT MAX (LEVEL)
                                    FROM rpt_col_tp v
                              START WITH v.RCT_ID = t.RCT_ID
                              CONNECT BY PRIOR v.RCT_RCT = v.RCT_ID)
                      FROM DUAL);

        -- and RCT_LEVEL is null or RCT_COLSPAN is null or   RCT_ROWSPAN is null

        SELECT MAX (RCT_LEVEL) INTO maxlevel FROM rpt_col_tp;

        UPDATE rpt_col_tp
           SET RCT_COLSPAN = 1
         WHERE RCT_LEVEL = 1;

        FOR i IN 2 .. maxlevel
        LOOP
            UPDATE rpt_col_tp t
               SET RCT_COLSPAN =
                       (SELECT NVL (SUM (v.RCT_COLSPAN), 1)
                          FROM rpt_col_tp v
                         WHERE v.rct_rct = t.rct_id)
             WHERE RCT_LEVEL = i;
        END LOOP;

        UPDATE rpt_col_tp t
           SET rct_rowspan = DECODE (RCT_COLSPAN, 1, RCT_LEVEL, 1);

        COMMIT;
    END;

    PROCEDURE Setup
    IS
    BEGIN
        SetupRptColTp;

        UPDATE rpt_row_tp
           SET rrt_code = FINZVIT_METADATA.ExcelTrim (rrt_code);

        UPDATE rpt_col_tp
           SET rct_code = FINZVIT_METADATA.ExcelTrim (rct_code);

        UPDATE rpt_frame_template
           SET rft_name = FINZVIT_METADATA.ExcelTrim (rft_name);

        UPDATE rpt_template
           SET rt_name = FINZVIT_METADATA.ExcelTrim (rt_name),
               rt_code = FINZVIT_METADATA.ExcelTrim (rt_code);
    END;

    PROCEDURE GetFullMetadata (p_RptPackTemplate       OUT SYS_REFCURSOR,
                               p_RptTemplate           OUT SYS_REFCURSOR,
                               p_RptInPackTemplate     OUT SYS_REFCURSOR,
                               p_RptFrameTemplate      OUT SYS_REFCURSOR,
                               p_FramesInRptTemplate   OUT SYS_REFCURSOR,
                               p_RptRowTp              OUT SYS_REFCURSOR,
                               p_RptColTp              OUT SYS_REFCURSOR,
                               p_RtpCellSpec           OUT SYS_REFCURSOR,
                               p_RptPackConstraints    OUT SYS_REFCURSOR,
                               p_imports               OUT SYS_REFCURSOR,
                               p_exports               OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_RptPackTemplate FOR
            SELECT t.*, pg.sv_super_gr pt_super_gr
              FROM rpt_pack_template  t
                   INNER JOIN ST_RPT_PACK_GR pg ON t.pt_gr = sv_id;

        OPEN p_RptTemplate FOR SELECT * FROM rpt_template;

        OPEN p_RptInPackTemplate FOR SELECT * FROM rpt_in_pack_template;

        OPEN p_RptFrameTemplate FOR SELECT * FROM rpt_frame_template;

        OPEN p_FramesInRptTemplate FOR SELECT * FROM frames_in_rpt_template;

        OPEN p_RptRowTp FOR
            SELECT rrt_id,
                   rrt_rft,
                   rrt_code,
                   rrt_name,
                   rrt_row_num,
                   rrt_readonly,
                   rrt_cat,
                   CAST (rrt_formula AS VARCHAR2 (4000))     rrt_formula
              FROM rpt_row_tp;

        OPEN p_RptColTp FOR
            SELECT rct_id,
                   rct_rct,
                   rct_rft,
                   rct_name,
                   rct_col_num,
                   rct_data_field,
                   rct_level,
                   rct_rowspan,
                   rct_colspan,
                   rct_code,
                   CAST (rct_formula AS VARCHAR2 (4000))     rct_formula,
                   rct_text_rotate
              FROM rpt_col_tp;

        OPEN p_RtpCellSpec FOR
            SELECT rcs_rct,
                   rcs_rrt,
                   CAST (rcs_formula AS VARCHAR2 (4000))     rcs_formula,
                   rcs_tp
              FROM rtp_cell_spec;

        OPEN p_RptPackConstraints FOR
              SELECT rpc_id,
                     rpc_message,
                     CAST (rpc_constraint AS VARCHAR2 (4000))
                         rpc_constraint,
                     rpc_ord,
                     rpc_tp,
                     rpc_pt,
                     rpc_is_active
                FROM rpt_pack_constraints c
            ORDER BY c.rpc_pt, c.rpc_ord;

        OPEN p_imports FOR
              SELECT ria_id,
                     ria_rt,
                     ria_sort,
                     a.sv_name     alg_name,
                     a.sv_id       alg_code,
                     a.sv_tp       alg_tp
                FROM rpt_import_alg r
                     JOIN ST_IMPORT_ALG a ON a.sv_id = r.ria_alg
            ORDER BY ria_rt, ria_sort;

        OPEN p_exports FOR
              SELECT rea_id,
                     rea_rt,
                     rea_sort,
                     a.sv_name     alg_name,
                     a.sv_id       alg_code,
                     a.sv_tp       alg_tp
                FROM rpt_export_alg r
                     JOIN ST_export_ALG a ON a.sv_id = r.rea_alg
            ORDER BY rea_rt, rea_sort;
    END;

    PROCEDURE GetUserMenu (p_top      OUT SYS_REFCURSOR,
                           p_detail   OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_top FOR   SELECT s.sv_id SUPER_GR_ID, s.sv_name SUPER_GR_NAME
                           FROM ST_RPT_PACK_SUPER_GR s
                       ORDER BY s.sv_ord;

        OPEN p_detail FOR   SELECT g.sv_super_gr                 SUPER_GR_ID,
                                   g.sv_id                       GR_ID,
                                   g.sv_name                     GR_NAME,
                                   (SELECT MAX (PT_PERIOD)
                                      FROM RPT_PACK_TEMPLATE p
                                     WHERE p.pt_gr = g.sv_id)    GR_PERIOD
                              FROM ST_RPT_PACK_GR g
                          ORDER BY sv_ord;
    END;


    FUNCTION GetRtId (rtCode IN VARCHAR2)
        RETURN NUMBER
    IS
        l_res   NUMBER;
    BEGIN
        SELECT rt_id
          INTO l_res
          FROM rpt_template t
         WHERE t.rt_code = rtCode;

        RETURN l_res;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (-20000,
                                     'Не знайдено звіт з кодом ' || rtCode);
    END;

    FUNCTION GetRftId (rtCode IN VARCHAR2, rrtCode IN VARCHAR2)
        RETURN NUMBER
    IS
        l_res   NUMBER;
    BEGIN
        SELECT rrt_rft
          INTO l_res
          FROM rpt_row_tp r
         WHERE rrt_id = FINZVIT_METADATA.GetRrtId (rtCode, rrtCode);

        RETURN l_res;
    END;

    FUNCTION GetRrtId (rtCode IN VARCHAR2, rrtCode IN VARCHAR2)
        RETURN NUMBER
    IS
        l_res     NUMBER;
        l_rt_id   NUMBER := GetRtId (rtCode);
    BEGIN
        SELECT rrt_id
          INTO l_res
          FROM rpt_row_tp  r
               JOIN rpt_frame_template f ON f.rft_id = r.rrt_rft
               JOIN frames_in_rpt_template t ON t.f2rt_rft = f.rft_id
         WHERE r.rrt_code = rrtCode AND t.f2rt_rt = l_rt_id;

        RETURN l_res;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                   'В звіті з кодом '
                || rtCode
                || ' не знайдено рядок з кодом '
                || rrtCode);
    END;

    FUNCTION GetRctId (rtCode    IN VARCHAR2,
                       rrtCode   IN VARCHAR2,
                       rctCode   IN VARCHAR2)
        RETURN NUMBER
    IS
        l_res   NUMBER;
    BEGIN
        SELECT rct_id
          INTO l_res
          FROM rpt_col_tp c
         WHERE     c.rct_rft = FINZVIT_METADATA.GetRftId (rtCode, rrtCode)
               AND c.rct_code = rctCode;

        RETURN l_res;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            raise_application_error (
                -20000,
                   'В звіті з кодом '
                || rtCode
                || ' не знайдено колонку з кодом '
                || rctCode
                || ', яка відповідає рядку з кодом '
                || rrtCode);
    END;
END FINZVIT_METADATA;
/