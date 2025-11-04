/* Formatted on 8/12/2025 5:59:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.RDM$DICTIONARIES_WEB
IS
    -- Author  : BOGDAN
    -- Created : 08.06.2021 15:57:48
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


GRANT EXECUTE ON USS_VISIT.RDM$DICTIONARIES_WEB TO DNET_PROXY
/

GRANT EXECUTE ON USS_VISIT.RDM$DICTIONARIES_WEB TO II01RC_USS_VISIT_WEB
/
