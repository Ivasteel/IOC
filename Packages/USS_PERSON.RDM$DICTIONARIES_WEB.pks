/* Formatted on 8/12/2025 5:56:55 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.RDM$DICTIONARIES_WEB
IS
    -- Author  : BOGDAN
    -- Created : 17.06.2021 18:25:09
    -- Purpose : Сервіс для роботи з довідниками на кліенті

    -- контекстний довідник з фільтрацією
    PROCEDURE GET_DIC_FILTERED (P_NDC_CODE          VARCHAR2,
                                P_XML        IN     VARCHAR2,
                                RES_CUR         OUT SYS_REFCURSOR);

    -- універсальний механізм пошуку данних для вибору елементу через модальне вікно з фільтрами і грідом
    PROCEDURE GET_MODAL_SELECT (P_NDC_CODE          VARCHAR2,
                                P_XML        IN     VARCHAR2,
                                RES_CUR         OUT SYS_REFCURSOR);

    -- Ініціалізація кешованих довідників
    PROCEDURE GET_CACHED_DICS (p_sys IN VARCHAR2, p_cursor OUT SYS_REFCURSOR);
END RDM$DICTIONARIES_WEB;
/


/* Formatted on 8/12/2025 5:57:04 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.RDM$DICTIONARIES_WEB
IS
    -- контекстний довідник
    PROCEDURE GET_DIC (P_NDC_CODE VARCHAR2, RES_CUR OUT SYS_REFCURSOR)
    IS
        v_sql   VARCHAR2 (30000);
    BEGIN
        uss_ndi.rdm$dictionaries_web.get_dic (p_ndc_code, res_cur);
    END;

    -- контекстний довідник з фільтрацією
    PROCEDURE GET_DIC_FILTERED (P_NDC_CODE          VARCHAR2,
                                P_XML        IN     VARCHAR2,
                                RES_CUR         OUT SYS_REFCURSOR)
    IS
        v_sql     VARCHAR2 (30000);
        v_where   VARCHAR2 (10000);
    BEGIN
        uss_ndi.rdm$dictionaries_web.GET_DIC_FILTERED (p_ndc_code,
                                                       p_xml,
                                                       RES_CUR);
    END;

    -- універсальний механізм пошуку данних для вибору елементу через модальне вікно з фільтрами і грідом
    PROCEDURE GET_MODAL_SELECT (P_NDC_CODE          VARCHAR2,
                                P_XML        IN     VARCHAR2,
                                RES_CUR         OUT SYS_REFCURSOR)
    IS
        v_sql   VARCHAR2 (20000);
    BEGIN
        raise_application_error (-20000, p_xml);
        uss_ndi.rdm$dictionaries_web.GET_MODAL_SELECT (P_NDC_CODE,
                                                       p_xml,
                                                       RES_CUR);
    END;

    PROCEDURE GET_CACHED_DICS (p_sys IN VARCHAR2, p_cursor OUT SYS_REFCURSOR)
    IS
    BEGIN
        uss_ndi.rdm$dictionaries_web.GET_CACHED_DICS (p_sys, p_cursor);
    END;
BEGIN
    NULL;
END RDM$DICTIONARIES_WEB;
/