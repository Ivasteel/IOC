/* Formatted on 8/12/2025 5:57:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.DNET$RNSP_PORTAL
IS
    -- Author  : SHOST
    -- Created : 03.03.2023 21:27:02
    -- Purpose : Функції для порталу

    FUNCTION Authenticate (p_Edrpou IN VARCHAR2, p_Rnokpp IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Get_Ap_Attr_Val_Str (p_Ap_Id IN NUMBER, p_Nda_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Rnd_Attr_Val_Str (p_Rnd_Id      IN NUMBER,
                                   p_Nda_Class   IN VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION Get_Kaot_Region (p_Kaot_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Kaot_District (p_Kaot_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Kaot_City (p_Kaot_Id IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE Get_Rnsp_Info (p_Edrpou     IN     VARCHAR2,
                             p_Rnokpp     IN     VARCHAR2,
                             p_Main_Cur      OUT SYS_REFCURSOR,
                             p_Svc_Cur       OUT SYS_REFCURSOR);
END Dnet$rnsp_Portal;
/


GRANT EXECUTE ON USS_RNSP.DNET$RNSP_PORTAL TO II01RC_USS_RNSP_PORTAL
/

GRANT EXECUTE ON USS_RNSP.DNET$RNSP_PORTAL TO PORTAL_PROXY
/
