/* Formatted on 8/12/2025 5:57:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.DNET$DICTIONARIES_WEB
IS
    -- Author  : BOGDAN
    -- Created : 08.06.2021 15:57:48
    -- Purpose : Сервіс для роботи з довідниками на кліенті

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


GRANT EXECUTE ON USS_RNSP.DNET$DICTIONARIES_WEB TO DNET_PROXY
/

GRANT EXECUTE ON USS_RNSP.DNET$DICTIONARIES_WEB TO II01RC_USS_RNSP_WEB
/


/* Formatted on 8/12/2025 5:58:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RNSP.DNET$DICTIONARIES_WEB
IS
    -- контекстний довідник
    PROCEDURE GET_DIC (P_NDC_CODE VARCHAR2, RES_CUR OUT SYS_REFCURSOR)
    IS
    BEGIN
        uss_ndi.DNET$DICTIONARIES_WEB.get_dic (p_ndc_code,
                                               'uss_rnsp',
                                               res_cur);
    END;

    -- контекстний довідник з фільтрацією
    PROCEDURE GET_DIC_FILTERED (P_NDC_CODE          VARCHAR2,
                                P_XML        IN     VARCHAR2,
                                RES_CUR         OUT SYS_REFCURSOR)
    IS
    BEGIN
        uss_ndi.DNET$DICTIONARIES_WEB.GET_DIC_FILTERED (p_ndc_code,
                                                        p_xml,
                                                        'uss_rnsp',
                                                        RES_CUR);
    END;

    -- налаштування модального вікна
    PROCEDURE GET_MODAL_SELECT_SETUP (P_NDC_CODE       VARCHAR2,
                                      P_FILTERS    OUT VARCHAR2,
                                      P_COLUMNS    OUT VARCHAR2)
    IS
    BEGIN
        uss_ndi.dnet$dictionaries_web.GET_MODAL_SELECT_SETUP (P_NDC_CODE,
                                                              'uss_rnsp',
                                                              P_FILTERS,
                                                              p_columns);
    END;

    -- універсальний механізм пошуку данних для вибору елементу через модальне вікно з фільтрами і грідом
    PROCEDURE GET_MODAL_SELECT (P_NDC_CODE          VARCHAR2,
                                P_XML        IN     VARCHAR2,
                                RES_CUR         OUT SYS_REFCURSOR)
    IS
    BEGIN
        uss_ndi.DNET$DICTIONARIES_WEB.GET_MODAL_SELECT (P_NDC_CODE,
                                                        p_xml,
                                                        'uss_rnsp',
                                                        RES_CUR);
    END;

    PROCEDURE GET_CACHED_DICS (p_sys IN VARCHAR2, p_cursor OUT SYS_REFCURSOR)
    IS
    BEGIN
        uss_ndi.DNET$DICTIONARIES_WEB.GET_CACHED_DICS (p_sys, p_cursor);
    END;
BEGIN
    NULL;
END DNET$DICTIONARIES_WEB;
/