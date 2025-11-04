/* Formatted on 8/12/2025 5:55:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.API$FIND
IS
    TYPE T_SIMP_DIC_ROW IS RECORD
    (
        d_id      NUMBER (14, 0),
        d_name    VARCHAR2 (250)
    );

    TYPE T_SIMP_DIC IS TABLE OF T_SIMP_DIC_ROW;

    TYPE t_v_ndi_service_type IS TABLE OF v_ndi_service_type%ROWTYPE;

    FUNCTION is_can_get_dict_name_by_id (P_NDA_ID IN NUMBER)
        RETURN NUMBER;

    FUNCTION get_dict_name_by_id_source (P_NDA_ID IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION GET_DICT_NAME_BY_ID (P_NDA_ID IN NUMBER, P_NDA_VAL_ID IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION get_simple_dic_int
        RETURN t_simp_dic
        PIPELINED;

    FUNCTION get_ndi_service_type_int
        RETURN t_v_ndi_service_type
        PIPELINED;

    FUNCTION get_ndi_service_type_int_alt
        RETURN t_v_ndi_service_type
        PIPELINED;
END API$FIND;
/


GRANT EXECUTE ON USS_NDI.API$FIND TO IKIS_RBM
/

GRANT EXECUTE ON USS_NDI.API$FIND TO USS_ESR
/

GRANT EXECUTE ON USS_NDI.API$FIND TO USS_PERSON
/

GRANT EXECUTE ON USS_NDI.API$FIND TO USS_RNSP
/

GRANT EXECUTE ON USS_NDI.API$FIND TO USS_RPT
/

GRANT EXECUTE ON USS_NDI.API$FIND TO USS_VISIT
/


/* Formatted on 8/12/2025 5:55:29 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.API$FIND
IS
    table_not_found   EXCEPTION;
    PRAGMA EXCEPTION_INIT (table_not_found, -942);

    FUNCTION is_can_get_dict_name_by_id (P_NDA_ID IN NUMBER)
        RETURN NUMBER
    IS
        l_res   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_res
          FROM ndi_document_attr  da
               JOIN ndi_param_type pt ON da.nda_pt = pt.pt_id
         WHERE pt.pt_edit_type = 'MF' AND nda_id = P_NDA_ID;

        RETURN l_res;
    END;

    FUNCTION get_dict_name_by_id_source (P_NDA_ID IN NUMBER)
        RETURN VARCHAR2
    IS
        l_res   VARCHAR2 (50);
    BEGIN
        SELECT ndc_code
          INTO l_res
          FROM ndi_document_attr  da
               JOIN ndi_param_type pt ON da.nda_pt = pt.pt_id
               JOIN ndi_dict_config dc ON pt.pt_ndc = dc.ndc_id
         WHERE pt.pt_edit_type = 'MF' AND nda_id = P_NDA_ID;

        IF INSTR (UPPER (l_res), 'V_RNSP') > 0
        THEN
            RETURN 'USS_RNSP';
        ELSE
            RETURN 'USS_NDI';
        END IF;
    END;

    FUNCTION GET_DICT_NAME_BY_ID (P_NDA_ID IN NUMBER, P_NDA_VAL_ID IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Query   VARCHAR2 (32000);
        l_Res     VARCHAR2 (4000);
    BEGIN
        SELECT dc.ndc_sql
          INTO l_Query
          FROM ndi_document_attr  da
               JOIN ndi_param_type pt ON da.nda_pt = pt.pt_id
               JOIN ndi_dict_config dc ON pt.pt_ndc = dc.ndc_id
         WHERE pt.pt_edit_type = 'MF' AND nda_id = P_NDA_ID;

        l_Query :=
            REGEXP_REPLACE (l_Query, 'AND ROWNUM < \d{1,5}', 'AND 1=1');


        l_Query := 'SELECT NAME
       FROM (
       ' || l_Query || '
       )
       WHERE ID = ' || P_NDA_VAL_ID;

        --dbms_output.put_line(l_Query);

        EXECUTE IMMEDIATE l_Query
            INTO l_Res;


        RETURN l_Res;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
        WHEN table_not_found
        THEN
            RETURN NULL;
    END;

    FUNCTION get_simple_dic_int
        RETURN t_simp_dic
        PIPELINED
    IS
    BEGIN
        FOR i IN 1 .. 100000
        LOOP
            PIPE ROW (t_simp_dic_row (i, 'рядок довідника ' || i));
        END LOOP;

        RETURN;
    END get_simple_dic_int;

    FUNCTION get_ndi_service_type_int
        RETURN t_v_ndi_service_type
        PIPELINED
    IS
        l_row   v_ndi_service_type%ROWTYPE;
    BEGIN
        FOR xx IN (SELECT nst_id FROM v_ndi_service_type)
        LOOP
            SELECT *
              INTO l_row
              FROM v_ndi_service_type
             WHERE nst_id = xx.nst_id;

            PIPE ROW (l_row);
        END LOOP;

        RETURN;
    END;

    FUNCTION get_ndi_service_type_int_alt
        RETURN t_v_ndi_service_type
        PIPELINED
    IS
        CURSOR l_out_data IS SELECT * FROM v_ndi_service_type;

        l_out_row   l_out_data%ROWTYPE;
    BEGIN
        OPEN l_out_data;

        LOOP
            FETCH l_out_data INTO l_out_row;

            EXIT WHEN l_out_data%NOTFOUND;
            PIPE ROW (l_out_row);
        END LOOP;

        CLOSE l_out_data;

        RETURN;
    END;
END API$FIND;
/