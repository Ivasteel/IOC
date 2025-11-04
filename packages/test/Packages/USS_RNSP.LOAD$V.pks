/* Formatted on 8/12/2025 5:57:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.LOAD$V
IS
    --==============================================
    FUNCTION Get_kaot_id (p_Index VARCHAR2, p_name VARCHAR2)
        RETURN NUMBER;

    FUNCTION Get_building (p_building VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Get_korp (p_korp VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Get_appartement (p_appartement VARCHAR2)
        RETURN VARCHAR2;

    --==============================================
    --
    --==============================================
    PROCEDURE LOAD;

    --==============================================
    --
    --==============================================
    PROCEDURE load_dt;
END LOAD$V;
/
