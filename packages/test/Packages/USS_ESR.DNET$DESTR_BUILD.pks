/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$DESTR_BUILD
IS
    -- Author  : BOGDAN
    -- Created : 11.10.2023 12:59:09
    -- Purpose : Реєстр зруйнованого майна

    -- #93062: реєстр
    PROCEDURE get_journal (p_SDP_NUM                IN     VARCHAR2,
                           --p_SDP_TP in VARCHAR2,
                           p_SDP_SUB_TP             IN     VARCHAR2,
                           p_SDP_REGION             IN     VARCHAR2,
                           p_SDP_OTG                IN     VARCHAR2,
                           p_SDP_FULL_ADDRESS       IN     VARCHAR2,
                           p_SDP_BUILDING_NUM       IN     VARCHAR2,
                           -- p_SDP_APARTMENT_NUM in VARCHAR2,
                           p_SDP_CREATE_DT_From     IN     DATE,
                           p_SDP_CREATE_DT_To       IN     DATE,
                           p_SDP_ACT                IN     VARCHAR2,
                           p_SDP_DESTROY_DT_From    IN     DATE,
                           p_SDP_DESTROY_DT_To      IN     DATE,
                           p_SDP_DESTROY_CAT        IN     VARCHAR2,
                           p_SDP_INSPECTION         IN     VARCHAR2,
                           p_SDP_CONDITION_CAT      IN     VARCHAR2,
                           p_Sdp_Kaot_Code          IN     VARCHAR2,
                           p_Sdp_Kaot               IN     VARCHAR2,
                           p_Sdp_Object_Name        IN     VARCHAR2,
                           p_Sdp_Object_Area        IN     NUMBER,
                           p_Sdp_Nb                 IN     VARCHAR2,
                           p_Sdp_Recovery_Status    IN     VARCHAR2,
                           p_Sdp_Reason_St_Change   IN     VARCHAR2,
                           p_Sdp_Is_Full_Destroy    IN     VARCHAR2,
                           p_Sdp_Is_Pzmk            IN     VARCHAR2,
                           res_cur                     OUT SYS_REFCURSOR);

    FUNCTION get_dynamic_value (p_col_name      IN VARCHAR2,
                                p_col_data_tp   IN VARCHAR2,
                                p_col_scale     IN NUMBER,
                                p_sdp_id        IN NUMBER)
        RETURN VARCHAR2;

    -- #93062: інспектор
    PROCEDURE get_inspector_Card (p_sdp_id   IN     NUMBER,
                                  res_cur       OUT SYS_REFCURSOR);
END DNET$DESTR_BUILD;
/


GRANT EXECUTE ON USS_ESR.DNET$DESTR_BUILD TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$DESTR_BUILD TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:29 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$DESTR_BUILD
IS
    -- #93062: реєстр
    PROCEDURE get_journal (p_SDP_NUM                IN     VARCHAR2,
                           --p_SDP_TP in VARCHAR2,
                           p_SDP_SUB_TP             IN     VARCHAR2,
                           p_SDP_REGION             IN     VARCHAR2,
                           p_SDP_OTG                IN     VARCHAR2,
                           p_SDP_FULL_ADDRESS       IN     VARCHAR2,
                           p_SDP_BUILDING_NUM       IN     VARCHAR2,
                           --p_SDP_APARTMENT_NUM in VARCHAR2,
                           p_SDP_CREATE_DT_From     IN     DATE,
                           p_SDP_CREATE_DT_To       IN     DATE,
                           p_SDP_ACT                IN     VARCHAR2,
                           p_SDP_DESTROY_DT_From    IN     DATE,
                           p_SDP_DESTROY_DT_To      IN     DATE,
                           p_SDP_DESTROY_CAT        IN     VARCHAR2,
                           p_SDP_INSPECTION         IN     VARCHAR2,
                           p_SDP_CONDITION_CAT      IN     VARCHAR2,
                           p_Sdp_Kaot_Code          IN     VARCHAR2,
                           p_Sdp_Kaot               IN     VARCHAR2,
                           p_Sdp_Object_Name        IN     VARCHAR2,
                           p_Sdp_Object_Area        IN     NUMBER,
                           p_Sdp_Nb                 IN     VARCHAR2,
                           p_Sdp_Recovery_Status    IN     VARCHAR2,
                           p_Sdp_Reason_St_Change   IN     VARCHAR2,
                           p_Sdp_Is_Full_Destroy    IN     VARCHAR2,
                           p_Sdp_Is_Pzmk            IN     VARCHAR2,
                           res_cur                     OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT t.*
              FROM SRC_DESTROYED_PROP t
             WHERE     1 = 1
                   AND (p_sdp_num IS NULL OR t.sdp_num LIKE p_sdp_num || '%')
                   --AND (p_SDP_SUB_TP is NULL OR t.SDP_SUB_TP LIKE  p_SDP_SUB_TP || '%')
                   AND (   p_SDP_REGION IS NULL
                        OR t.sdp_region LIKE p_SDP_REGION || '%')
                   AND (p_SDP_OTG IS NULL OR t.sdp_otg LIKE p_SDP_OTG || '%')
                   AND (   p_SDP_FULL_ADDRESS IS NULL
                        OR t.sdp_full_address LIKE p_SDP_FULL_ADDRESS || '%')
                   AND (   p_SDP_BUILDING_NUM IS NULL
                        OR t.sdp_building_num LIKE p_SDP_BUILDING_NUM || '%')
                   -- AND (p_SDP_APARTMENT_NUM is NULL OR t.sdp_apartment_num LIKE  p_SDP_APARTMENT_NUM || '%')
                   AND (p_SDP_ACT IS NULL OR t.sdp_act LIKE p_SDP_ACT || '%')
                   AND (   p_SDP_DESTROY_CAT IS NULL
                        OR t.sdp_destroy_cat LIKE p_SDP_DESTROY_CAT || '%')
                   AND (   p_SDP_INSPECTION IS NULL
                        OR t.sdp_inspection LIKE p_SDP_INSPECTION || '%')
                   AND (   p_SDP_CONDITION_CAT IS NULL
                        OR t.sdp_condition_cat LIKE
                               p_SDP_CONDITION_CAT || '%')
                   AND (   p_Sdp_Kaot_Code IS NULL
                        OR t.Sdp_Kaot_Code LIKE p_Sdp_Kaot_Code || '%')
                   AND (p_Sdp_Kaot IS NULL OR t.Sdp_Kaot = p_Sdp_Kaot)
                   AND (   p_Sdp_Object_Name IS NULL
                        OR t.Sdp_Object_Name LIKE p_Sdp_Object_Name || '%')
                   AND (   p_Sdp_Object_Area IS NULL
                        OR t.Sdp_Object_Area = p_Sdp_Object_Area)
                   AND (   p_Sdp_Nb IS NULL
                        OR UPPER (t.Sdp_Nb) LIKE UPPER (p_Sdp_Nb) || '%')
                   AND (   p_Sdp_Recovery_Status IS NULL
                        OR UPPER (t.Sdp_Recovery_Status) LIKE
                               UPPER (p_Sdp_Recovery_Status) || '%')
                   AND (   p_Sdp_Reason_St_Change IS NULL
                        OR UPPER (t.Sdp_Reason_St_Change) LIKE
                               UPPER (p_Sdp_Reason_St_Change) || '%')
                   AND (   p_Sdp_Is_Full_Destroy IS NULL
                        OR UPPER (t.Sdp_Is_Full_Destroy) LIKE
                               UPPER (p_Sdp_Is_Full_Destroy) || '%')
                   AND (   p_Sdp_Is_Pzmk IS NULL
                        OR UPPER (t.Sdp_Is_Pzmk) LIKE
                               UPPER (p_Sdp_Is_Pzmk) || '%')
                   AND (   p_SDP_DESTROY_DT_From IS NULL
                        OR t.sdp_destroy_dt >= p_SDP_DESTROY_DT_From)
                   AND (   p_SDP_DESTROY_DT_To IS NULL
                        OR t.sdp_destroy_dt <= p_SDP_DESTROY_DT_To)
                   AND (   p_SDP_CREATE_DT_From IS NULL
                        OR t.sdp_create_dt >= p_SDP_CREATE_DT_From)
                   AND (   p_SDP_CREATE_DT_To IS NULL
                        OR t.sdp_create_dt <= p_SDP_CREATE_DT_To)
                   AND ROWNUM <= 502;
    END;


    FUNCTION get_dynamic_value (p_col_name      IN VARCHAR2,
                                p_col_data_tp   IN VARCHAR2,
                                p_col_scale     IN NUMBER,
                                p_sdp_id        IN NUMBER)
        RETURN VARCHAR2
    IS
        l_res   VARCHAR2 (4000);
    BEGIN
        EXECUTE IMMEDIATE   'SELECT '
                         || CASE
                                WHEN p_col_name = 'COM_ORG'
                                THEN
                                    '(select org_code || '' '' || org_name from uss_esr.v_opfu z where z.org_id = d.com_org)'
                                WHEN     p_col_data_tp = 'NUMBER'
                                     AND p_col_scale IS NOT NULL
                                     AND p_col_scale > 0
                                THEN
                                       'to_char('
                                    || p_col_name
                                    || ', ''FM9G999G999G999G999G990D00'', ''NLS_NUMERIC_CHARACTERS='''','''''''''')'
                                WHEN p_col_data_tp = 'DATE'
                                THEN
                                       'to_char('
                                    || p_col_name
                                    || ', ''DD.MM.YYYY'')'
                                WHEN p_col_name = 'SDP_KAOT'
                                THEN
                                    'uss_ndi.api$dic_common.Get_Katottg_Name(sdp_kaot)'
                                ELSE
                                    p_col_name
                            END
                         || '
                         FROM uss_esr.SRC_DESTROYED_PROP d
                        WHERE d.sdp_id = :id'
            INTO l_res
            USING p_sdp_id;

        RETURN l_res;
    END;


    -- #93062: інспектор
    PROCEDURE get_inspector_Card (p_sdp_id   IN     NUMBER,
                                  res_cur       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
              SELECT t.comments                      AS NAME,
                     get_dynamic_value (t.column_name,
                                        ct.data_type,
                                        ct.data_scale,
                                        p_sdp_id)    AS VALUE
                FROM all_col_comments t
                     JOIN all_tab_columns ct
                         ON (    ct.table_name = t.table_name
                             AND ct.column_name = t.column_name)
               WHERE     t.table_name = UPPER ('SRC_DESTROYED_PROP')
                     AND NOT EXISTS
                             (SELECT *
                                FROM all_cons_columns z
                               WHERE     z.table_name = t.table_name
                                     AND z.column_name = t.column_name
                                     AND z.column_name != 'SDP_KAOT')
            ORDER BY ct.column_id;
    END;
BEGIN
    NULL;
END DNET$DESTR_BUILD;
/