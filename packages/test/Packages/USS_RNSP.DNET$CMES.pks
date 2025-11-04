/* Formatted on 8/12/2025 5:57:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.DNET$CMES
IS
    -- Author  : SHOSTAK
    -- Created : 01.06.2023 9:01:56 PM
    -- Purpose :

    PROCEDURE Get_Rnsp_Journal (p_Pib        IN     VARCHAR2,
                                p_Org_Name   IN     VARCHAR2,
                                Res_Cur         OUT SYS_REFCURSOR,
                                p_Numident   IN     VARCHAR2 DEFAULT NULL);

    FUNCTION Get_Kaot_Region (p_Kaot_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Addr_Text (p_Rnspa_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Kaot_District (p_Kaot_Id IN NUMBER)
        RETURN VARCHAR2
        DETERMINISTIC;

    FUNCTION Get_Kaot_City (p_Kaot_Id IN NUMBER)
        RETURN VARCHAR2
        DETERMINISTIC;

    FUNCTION Get_Kaot_City_Tp (p_Kaot_Id IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE Get_Rnsp_Card (p_Rnspm_Id     IN     NUMBER,
                             Rnsp_Info         OUT SYS_REFCURSOR,
                             Addr_Reg          OUT SYS_REFCURSOR,
                             Addr_Service      OUT SYS_REFCURSOR);
END Dnet$cmes;
/


GRANT EXECUTE ON USS_RNSP.DNET$CMES TO II01RC_USS_RNSP_PORTAL
/

GRANT EXECUTE ON USS_RNSP.DNET$CMES TO PORTAL_PROXY
/
