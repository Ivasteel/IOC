/* Formatted on 8/12/2025 6:11:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.TOOLS
IS
    -- Author  : SHOSTAK
    -- Created : 07.06.2023 4:41:23 PM
    -- Purpose :

    FUNCTION Get_Last_Patch_Num (p_Subsys IN VARCHAR2)
        RETURN VARCHAR2;
END Tools;
/


GRANT EXECUTE ON IKIS_SYSWEB.TOOLS TO IKIS_RBM
/

GRANT EXECUTE ON IKIS_SYSWEB.TOOLS TO USS_NDI
/


/* Formatted on 8/12/2025 6:11:46 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.TOOLS
IS
    FUNCTION Get_Last_Patch_Num (p_Subsys IN VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (30);
    BEGIN
          SELECT r.Wp_Number
            INTO l_Result
            FROM Ikis_Sysweb.w_Patch_Rep r
           WHERE r.Wp_Subsys = 'USS_NDI'
        ORDER BY r.Wp_Stop_Dt DESC
           FETCH FIRST ROW ONLY;

        RETURN l_Result;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
    END;
END Tools;
/