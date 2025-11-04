/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$DICTIONARIES_WEB
IS
    -- Author  : BOGDAN
    -- Created : 17.06.2021 18:54:05
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


GRANT EXECUTE ON USS_ESR.DNET$DICTIONARIES_WEB TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$DICTIONARIES_WEB TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:29 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$DICTIONARIES_WEB
IS
    FUNCTION ignore_apostrof (p_value IN VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN UPPER (REGEXP_REPLACE (p_value, '[`''’]', ''));
    END;

    -- контекстний довідник
    PROCEDURE GET_DIC (P_NDC_CODE VARCHAR2, RES_CUR OUT SYS_REFCURSOR)
    IS
        v_sql   VARCHAR2 (30000);
    BEGIN
        IF LOWER (p_ndc_code) IN ('v_rnsp_all')
        THEN
            uss_rnsp.api$find.get_dic (p_ndc_code, res_cur);
        ELSE
            uss_ndi.DNET$DICTIONARIES_WEB.get_dic (p_ndc_code,
                                                   'uss_esr',
                                                   res_cur);
        END IF;
    END;

    -- контекстний довідник з фільтрацією
    PROCEDURE GET_DIC_FILTERED (P_NDC_CODE          VARCHAR2,
                                P_XML        IN     VARCHAR2,
                                RES_CUR         OUT SYS_REFCURSOR)
    IS
        v_sql     VARCHAR2 (30000);
        v_where   VARCHAR2 (10000);
    BEGIN
        IF LOWER (p_ndc_code) IN ('v_rnsp_all')
        THEN
            uss_rnsp.api$find.get_dic_filtered (p_ndc_code, p_xml, res_cur);
        ELSE
            uss_ndi.DNET$DICTIONARIES_WEB.GET_DIC_FILTERED (p_ndc_code,
                                                            p_xml,
                                                            'uss_esr',
                                                            RES_CUR);
        END IF;
    END;

    -- налаштування модального вікна
    PROCEDURE GET_MODAL_SELECT_SETUP (P_NDC_CODE       VARCHAR2,
                                      P_FILTERS    OUT VARCHAR2,
                                      P_COLUMNS    OUT VARCHAR2)
    IS
    BEGIN
        IF LOWER (p_ndc_code) IN ('v_rnsp_all')
        THEN
            uss_rnsp.api$find.get_modal_select_setup (p_ndc_code,
                                                      p_filters,
                                                      p_columns);
        ELSE
            uss_ndi.dnet$dictionaries_web.GET_MODAL_SELECT_SETUP (P_NDC_CODE,
                                                                  'uss_esr',
                                                                  P_FILTERS,
                                                                  p_columns);
        END IF;
    END;

    -- універсальний механізм пошуку данних для вибору елементу через модальне вікно з фільтрами і грідом
    PROCEDURE GET_MODAL_SELECT (P_NDC_CODE          VARCHAR2,
                                P_XML        IN     VARCHAR2,
                                RES_CUR         OUT SYS_REFCURSOR)
    IS
        v_sql   VARCHAR2 (20000);
    BEGIN
        --raise_application_error(-20000, p_xml);
        --ikis_sysweb.ikis_debug_pipe.WriteMsg(P_XML);
        IF LOWER (p_ndc_code) IN ('v_rnsp_all')
        THEN
            uss_rnsp.API$FIND.get_modal_select (p_ndc_code, p_xml, res_cur);
        ELSE
            uss_ndi.DNET$DICTIONARIES_WEB.GET_MODAL_SELECT (P_NDC_CODE,
                                                            p_xml,
                                                            'uss_esr',
                                                            RES_CUR);
        END IF;
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