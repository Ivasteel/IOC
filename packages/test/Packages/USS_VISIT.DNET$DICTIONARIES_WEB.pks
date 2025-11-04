/* Formatted on 8/12/2025 5:59:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.DNET$DICTIONARIES_WEB
IS
    -- Author  : BOGDAN
    -- Created : 08.06.2021 15:57:48
    -- Purpose : Сервіс для роботи з довідниками на кліенті

    FUNCTION ignore_apostrof (p_value IN VARCHAR2)
        RETURN VARCHAR2;

    -- контекстний довідник
    PROCEDURE GET_DIC (P_NDC_CODE VARCHAR2, RES_CUR OUT SYS_REFCURSOR);

    -- контекстний довідник з фільтрацією
    PROCEDURE GET_DIC_FILTERED (P_NDC_CODE          VARCHAR2,
                                P_XML        IN     VARCHAR2,
                                RES_CUR         OUT SYS_REFCURSOR);

    -- налаштування модального вікна
    PROCEDURE GET_MODAL_SELECT_SETUP (P_NDC_CODE       VARCHAR2,
                                      P_FILTERS    OUT VARCHAR2,
                                      P_COLUMNS    OUT VARCHAR2);

    -- універсальний механізм пошуку данних для вибору елементу через модальне вікно з фільтрами і грідом
    PROCEDURE GET_MODAL_SELECT (P_NDC_CODE          VARCHAR2,
                                P_XML        IN     VARCHAR2,
                                RES_CUR         OUT SYS_REFCURSOR);

    -- Ініціалізація кешованих довідників
    PROCEDURE GET_CACHED_DICS (p_sys IN VARCHAR2, p_cursor OUT SYS_REFCURSOR);
END DNET$DICTIONARIES_WEB;
/


GRANT EXECUTE ON USS_VISIT.DNET$DICTIONARIES_WEB TO DNET_PROXY
/

GRANT EXECUTE ON USS_VISIT.DNET$DICTIONARIES_WEB TO II01RC_USS_VISIT_PORTAL
/

GRANT EXECUTE ON USS_VISIT.DNET$DICTIONARIES_WEB TO II01RC_USS_VISIT_WEB
/

GRANT EXECUTE ON USS_VISIT.DNET$DICTIONARIES_WEB TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 6:00:01 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.DNET$DICTIONARIES_WEB
IS
    FUNCTION ignore_apostrof (p_value IN VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN UPPER (REGEXP_REPLACE (p_value, '[`''’]', ''));
    END;

    -- контекстний довідник
    PROCEDURE get_dic (p_ndc_code VARCHAR2, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        IF LOWER (p_ndc_code) IN ('v_rnsp_all')
        THEN
            uss_rnsp.api$find.get_dic (p_ndc_code, res_cur);
        ELSE
            uss_ndi.DNET$DICTIONARIES_WEB.get_dic (p_ndc_code,
                                                   'uss_visit',
                                                   res_cur);
        END IF;
    END;

    -- контекстний довідник з фільтрацією
    PROCEDURE get_dic_filtered (p_ndc_code          VARCHAR2,
                                p_xml        IN     VARCHAR2,
                                res_cur         OUT SYS_REFCURSOR)
    IS
    BEGIN
        IF LOWER (p_ndc_code) IN ('v_rnsp_all')
        THEN
            uss_rnsp.api$find.get_dic_filtered (p_ndc_code, p_xml, res_cur);
        ELSE
            uss_ndi.dnet$dictionaries_web.get_dic_filtered (p_ndc_code,
                                                            p_xml,
                                                            'uss_visit',
                                                            res_cur);
        END IF;
    END;

    -- налаштування модального вікна
    PROCEDURE get_modal_select_setup (p_ndc_code       VARCHAR2,
                                      p_filters    OUT VARCHAR2,
                                      p_columns    OUT VARCHAR2)
    IS
        l_filters   VARCHAR2 (4000);
        l_columns   VARCHAR2 (4000);
    BEGIN
        IF LOWER (p_ndc_code) IN ('v_rnsp_all')
        THEN
            uss_rnsp.api$find.get_modal_select_setup (p_ndc_code,
                                                      p_filters,
                                                      p_columns);
        ELSE
            uss_ndi.dnet$dictionaries_web.get_modal_select_setup (
                p_ndc_code,
                'uss_visit',
                l_filters,
                l_columns);
            p_filters := l_filters;
            p_columns := l_columns;
        END IF;
    END;

    -- універсальний механізм пошуку данних для вибору елементу через модальне вікно з фільтрами і грідом
    PROCEDURE get_modal_select (p_ndc_code          VARCHAR2,
                                p_xml        IN     VARCHAR2,
                                res_cur         OUT SYS_REFCURSOR)
    IS
    BEGIN
        IF LOWER (p_ndc_code) IN ('v_rnsp_all')
        THEN
            uss_rnsp.API$FIND.get_modal_select (p_ndc_code, p_xml, res_cur);
        ELSE
            uss_ndi.DNET$DICTIONARIES_WEB.get_modal_select (p_ndc_code,
                                                            p_xml,
                                                            'uss_visit',
                                                            res_cur);
        END IF;
    END;

    PROCEDURE get_cached_dics (p_sys IN VARCHAR2, p_cursor OUT SYS_REFCURSOR)
    IS
    BEGIN
        uss_ndi.DNET$DICTIONARIES_WEB.get_cached_dics (p_sys, p_cursor);
    END;
BEGIN
    NULL;
END DNET$DICTIONARIES_WEB;
/