/* Formatted on 8/12/2025 5:48:24 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$ACCTOOLS
IS
    -- Author  : VANO
    -- Created : 13.03.2023 11:41:59
    -- Purpose : Допоміжні функції розрахунку нарахувань

    --Знак для іду операції
    FUNCTION xsign (p_op_id NUMBER)
        RETURN NUMBER;
END API$ACCTOOLS;
/


GRANT EXECUTE ON USS_ESR.API$ACCTOOLS TO II01RC_USS_ESR_INTERNAL
/

GRANT EXECUTE ON USS_ESR.API$ACCTOOLS TO II01RC_USS_ESR_RPT
/

GRANT EXECUTE ON USS_ESR.API$ACCTOOLS TO IKIS_RBM
/

GRANT EXECUTE ON USS_ESR.API$ACCTOOLS TO USS_PERSON
/

GRANT EXECUTE ON USS_ESR.API$ACCTOOLS TO USS_RPT
/

GRANT EXECUTE ON USS_ESR.API$ACCTOOLS TO USS_VISIT
/


/* Formatted on 8/12/2025 5:48:36 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$ACCTOOLS
IS
    TYPE cache_op_info_type IS TABLE OF VARCHAR2 (10)
        INDEX BY VARCHAR2 (40);

    g_op_info   cache_op_info_type;

    FUNCTION get_op_tp1 (p_op_id NUMBER)
        RETURN VARCHAR2
    IS
        l_op_tp1   VARCHAR2 (10);
    BEGIN
        RETURN g_op_info (p_op_id);
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            BEGIN
                SELECT op_tp1
                  INTO l_op_tp1
                  FROM uss_ndi.v_ndi_op
                 WHERE op_id = p_op_id;

                g_op_info (p_op_id) := l_op_tp1;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    g_op_info (p_op_id) := NULL;
            END;

            RETURN g_op_info (p_op_id);
    END;

    --Знак для іду операції
    FUNCTION xsign (p_op_id NUMBER)
        RETURN NUMBER
    IS
    BEGIN
        RETURN CASE
                   WHEN p_op_id IS NULL
                   THEN
                       0
                   WHEN p_op_id IN (1, 2)
                   THEN
                       1
                   WHEN p_op_id IN (10)
                   THEN
                       1                                   --повернення коштів
                   WHEN p_op_id IN (3,
                                    123,
                                    124,
                                    6)
                   THEN
                       -1
                   WHEN p_op_id IN (30)
                   THEN
                       -1
                   WHEN p_op_id IN (31, 32, 33)
                   THEN
                       1
                   WHEN get_op_tp1 (p_op_id) = 'NR'
                   THEN
                       1
                   WHEN get_op_tp1 (p_op_id) = 'DN'
                   THEN
                       -1
                   ELSE
                       0
               END;
    END;
BEGIN
    -- Initialization
    NULL;
END API$ACCTOOLS;
/