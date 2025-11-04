/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$PORTAL
IS
-- Author  : SHOSTAK
-- Created : 22.03.2023 11:02:28 AM
-- Purpose :

END Dnet$portal;
/


/* Formatted on 8/12/2025 5:49:48 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$PORTAL
IS
    ---------------------------------------------------------------------
    --     Œ“–»Ã¿ÕÕﬂ œ≈–≈À≤ ” «¿ﬂ¬ œŒ“≈Õ÷≤…Õ»’ Œ“–»Ã”¬¿◊≤¬ —Œ÷œŒ—À”√
    --     œŒ Õ¿ƒ¿¬¿◊”
    ---------------------------------------------------------------------
    PROCEDURE Get_Ss_Rec_Appeals (p_Edrpou   IN     VARCHAR2,
                                  p_Rnokpp   IN     VARCHAR2,
                                  p_Res         OUT SYS_REFCURSOR)
    IS
    BEGIN
        NULL;
    END;

    PROCEDURE Save_Act (p_Ap_Id          IN NUMBER,
                        p_Ap_Documents   IN CLOB,
                        p_Edrpou         IN VARCHAR2,
                        p_Rnokpp         IN VARCHAR2)
    IS
    BEGIN
        NULL;
    END;

    PROCEDURE Set_Contract_Signed_By_Prov (p_Ap_Id    IN NUMBER,
                                           p_Edrpou   IN VARCHAR2,
                                           p_Rnokpp   IN VARCHAR2)
    IS
    BEGIN
        NULL;
    END;
END Dnet$portal;
/