/* Formatted on 8/12/2025 5:57:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.DNET$DYNAMIC_MENU
IS
    -- Author  : VANO
    -- Created : 10.06.2021 13:45:23
    -- Purpose : Функції видачі меню для веб-додатку

    PROCEDURE get_menu (p_menu OUT SYS_REFCURSOR);

    PROCEDURE get_app_info (p_flag    IN     NUMBER DEFAULT 0,
                            res_cur      OUT SYS_REFCURSOR);
END DNET$DYNAMIC_MENU;
/


GRANT EXECUTE ON USS_RNSP.DNET$DYNAMIC_MENU TO DNET_PROXY
/

GRANT EXECUTE ON USS_RNSP.DNET$DYNAMIC_MENU TO II01RC_USS_RNSP_WEB
/


/* Formatted on 8/12/2025 5:58:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RNSP.DNET$DYNAMIC_MENU
IS
    PROCEDURE get_menu (p_menu OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_menu FOR
            SELECT m_id,
                   m_master,
                   m_type,
                   m_order,
                   m_name,
                   m_sname,
                   m_route,
                   m_rights,
                   m_reg_rights,
                   m_newgroup,
                   m_shortcut,
                   m_iconname,
                   m_subtreeproc
              FROM v_app_menu;
    END;

    PROCEDURE get_app_info (p_flag    IN     NUMBER DEFAULT 0,
                            res_cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN RES_CUR FOR
            SELECT 'Реєстр надавачів соціальних послуг' /*TOOLS.GetGlobalParameter('WEB_APP_NAME_AT_MENU')*/
                                                            AS header,
                   'РНСП' /*TOOLS.GetGlobalParameter('WEB_APP_NAME_AT_WIN_HEAD')*/
                                                            AS title,
                   'Розробник: ТОВ "НВП МЕДИРЕНТ"' /*TOOLS.GetGlobalParameter('WEB_DEV_NAME_AT_WIN_FOOTER')*/
                                                            AS developer,
                   ''      /*TOOLS.GetGlobalParameter('WEB_SUPPORT_ADDRESS')*/
                                                            AS supportEmail
              FROM DUAL;
    END;
END DNET$DYNAMIC_MENU;
/