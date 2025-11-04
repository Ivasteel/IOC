/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.DNET$DICTIONARIES_WEB
IS
    -- Author  : BOGDAN
    -- Created : 08.06.2021 15:57:48
    -- Purpose : Сервіс для роботи з довідниками на кліенті



    -- контекстний довідник
    PROCEDURE Get_Dic (p_Ndc_Code VARCHAR2, Res_Cur OUT SYS_REFCURSOR);

    -- контекстний довідник з фільтрацією
    PROCEDURE Get_Dic_Filtered (p_Ndc_Code          VARCHAR2,
                                p_Xml        IN     VARCHAR2,
                                Res_Cur         OUT SYS_REFCURSOR);

    -- налаштування модального вікна
    PROCEDURE Get_Modal_Select_Setup (p_Ndc_Code       VARCHAR2,
                                      p_Filters    OUT VARCHAR2,
                                      p_Columns    OUT VARCHAR2);

    -- універсальний механізм пошуку данних для вибору елементу через модальне вікно з фільтрами і грідом
    PROCEDURE Get_Modal_Select (p_Ndc_Code          VARCHAR2,
                                p_Xml        IN     VARCHAR2,
                                Res_Cur         OUT SYS_REFCURSOR);

    -- Ініціалізація кешованих довідників
    PROCEDURE Get_Cached_Dics (p_Sys IN VARCHAR2, p_Cursor OUT SYS_REFCURSOR);

    PROCEDURE Get_All_Dics (p_Cursor OUT SYS_REFCURSOR);

    FUNCTION Get_Version
        RETURN VARCHAR2;

    PROCEDURE Get_Service_List_For (p_Code   IN     VARCHAR2,
                                    p_Id     IN     NUMBER,
                                    p_Res       OUT SYS_REFCURSOR);
END Dnet$dictionaries_Web;
/


GRANT EXECUTE ON IKIS_RBM.DNET$DICTIONARIES_WEB TO DNET_PROXY
/

GRANT EXECUTE ON IKIS_RBM.DNET$DICTIONARIES_WEB TO II01RC_RBMWEB_COMMON
/

GRANT EXECUTE ON IKIS_RBM.DNET$DICTIONARIES_WEB TO II01RC_RBM_PORTAL
/

GRANT EXECUTE ON IKIS_RBM.DNET$DICTIONARIES_WEB TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 6:10:49 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.DNET$DICTIONARIES_WEB
IS
    -- контекстний довідник
    PROCEDURE Get_Dic (p_Ndc_Code VARCHAR2, Res_Cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        IF LOWER (p_Ndc_Code) IN ('v_rnsp_all')
        THEN
            Uss_Rnsp.Api$find.Get_Dic (p_Ndc_Code, Res_Cur);
        ELSE
            Uss_Ndi.Dnet$dictionaries_Web.Get_Dic (UPPER (p_Ndc_Code),
                                                   'cmes',
                                                   Res_Cur);
        END IF;
    END;

    -- контекстний довідник з фільтрацією
    PROCEDURE Get_Dic_Filtered (p_Ndc_Code          VARCHAR2,
                                p_Xml        IN     VARCHAR2,
                                Res_Cur         OUT SYS_REFCURSOR)
    IS
    BEGIN
        IF LOWER (p_Ndc_Code) IN ('v_rnsp_all')
        THEN
            Uss_Rnsp.Api$find.Get_Dic_Filtered (p_Ndc_Code, p_Xml, Res_Cur);
        ELSE
            Uss_Ndi.Dnet$dictionaries_Web.Get_Dic_Filtered (
                UPPER (p_Ndc_Code),
                p_Xml,
                'cmes',
                Res_Cur);
        END IF;
    END;



    -- налаштування модального вікна
    PROCEDURE Get_Modal_Select_Setup (p_Ndc_Code       VARCHAR2,
                                      p_Filters    OUT VARCHAR2,
                                      p_Columns    OUT VARCHAR2)
    IS
        l_Filters   VARCHAR2 (4000);
        l_Columns   VARCHAR2 (4000);
    BEGIN
        IF LOWER (p_Ndc_Code) IN ('v_rnsp_all')
        THEN
            Uss_Rnsp.Api$find.Get_Modal_Select_Setup (p_Ndc_Code,
                                                      p_Filters,
                                                      p_Columns);
        ELSE
            Uss_Ndi.Dnet$dictionaries_Web.Get_Modal_Select_Setup (p_Ndc_Code,
                                                                  'cmes',
                                                                  l_Filters,
                                                                  l_Columns);
            p_Filters := l_Filters;
            p_Columns := l_Columns;
        END IF;
    END;

    -- універсальний механізм пошуку данних для вибору елементу через модальне вікно з фільтрами і грідом
    PROCEDURE Get_Modal_Select (p_Ndc_Code          VARCHAR2,
                                p_Xml        IN     VARCHAR2,
                                Res_Cur         OUT SYS_REFCURSOR)
    IS
    BEGIN
        IF LOWER (p_Ndc_Code) IN ('v_rnsp_all')
        THEN
            Uss_Rnsp.Api$find.Get_Modal_Select (p_Ndc_Code, p_Xml, Res_Cur);
        ELSE
            --raise_application_error(-20000, p_Xml);
            -- Uss_Ndi.Dnet$dictionaries_Web.Get_Modal_Select(p_Ndc_Code, p_Xml, 'cmes', Res_Cur);
            Uss_Ndi.Dnet$dictionaries_Web.Get_Modal_Select_V2 (p_Ndc_Code,
                                                               p_Xml,
                                                               'cmes',
                                                               Res_Cur);
        END IF;
    END;


    PROCEDURE Get_Cached_Dics (p_Sys IN VARCHAR2, p_Cursor OUT SYS_REFCURSOR)
    IS
    BEGIN
        Uss_Ndi.Dnet$dictionaries_Web.Get_Cached_Dics (p_Sys, p_Cursor);
    END;

    PROCEDURE Get_All_Dics (p_Cursor OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_Cursor FOR
            SELECT c.Ndc_Code
                       AS Dict_Code,
                   c.Ndc_Tp
                       AS Dict_Tp,
                   CASE WHEN c.Ndc_Tp = 'MF' THEN c.Ndc_Fields END
                       AS Ndc_Fields,
                   c.Ndc_Filter
              FROM Uss_Ndi.v_Ndi_Dict_Config c
             WHERE c.Ndc_Systems LIKE '%#cmes%';
    END;

    FUNCTION Get_Version
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN Ikis_Sysweb.Tools.Get_Last_Patch_Num ('USS_NDI');
    END;

    --отримання переліку послуг для
    --TCTR - акту
    --RNSP - НСП
    PROCEDURE Get_Service_List_For (p_Code   IN     VARCHAR2,
                                    p_Id     IN     NUMBER,
                                    p_Res       OUT SYS_REFCURSOR)
    IS
    BEGIN
        IF UPPER (p_Code) = 'TCTR'
        THEN
            USS_ESR.API$FIND.Get_At_Services_Only (p_Id, p_Res);
        ELSIF UPPER (p_Code) = 'RNSP'
        THEN
            USS_RNSP.API$FIND.Get_Rnsp_Services_Only (p_Id, p_Res);
        ELSE
            raise_application_error (
                -20000,
                'Невідомий код для пошуку послуг ' || p_Code);
        END IF;
    END;
BEGIN
    NULL;
END Dnet$dictionaries_Web;
/