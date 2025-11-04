/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$DYNAMIC_MENU
IS
    -- Author  : VANO
    -- Created : 15.02.2021 14:46:32
    -- Purpose : Функції видачі меню для веб-додатку

    PROCEDURE get_menu (p_menu OUT SYS_REFCURSOR);

    /*
      PROCEDURE get_submenu(p_nvn_id ikis_sys.appt_nav_node.nvn_id%TYPE,
                            p_cursor OUT SYS_REFCURSOR);
      */
    PROCEDURE get_app_info (p_flag    IN     NUMBER DEFAULT 0,
                            res_cur      OUT SYS_REFCURSOR);
END DNET$DYNAMIC_MENU;
/


GRANT EXECUTE ON USS_ESR.DNET$DYNAMIC_MENU TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$DYNAMIC_MENU TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:29 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$DYNAMIC_MENU
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

    /*PROCEDURE get_menu(p_cursor OUT SYS_REFCURSOR)
    IS
    BEGIN
      OPEN p_cursor FOR
        SELECT nn.NVN_ID,
               nn.NVN_NVN_MASTER,
               nn.NVN_NAME,
               nn.NVN_SNAME,
               nn.NVN_SUBTREEPROC,
               nn.NVN_RSRC_CODE,
               nn.nvn_iconname AS NVN_VCOND,
               nn.nvn_params || nn.nvn_vcond AS NVN_PARAMS
        FROM IKIS_SYS.APPT_NAV_NODE nn
        WHERE nn.nvn_sys = 25010
        ORDER BY nn.nvn_num;
    END;

    PROCEDURE get_submenu(p_nvn_id ikis_sys.appt_nav_node.nvn_id%TYPE,
                          p_cursor OUT SYS_REFCURSOR)
    IS
      l_group ikis_sys.appt_nav_node.NVN_RSRC_CODE%TYPE;
    BEGIN
      SELECT nvn_rsrc_code
      INTO l_group
      FROM ikis_sys.appt_nav_node
      WHERE nvn_id = p_nvn_id;

      IF l_group IS NOT NULL  THEN
          OPEN p_cursor FOR
            SELECT nn.NVN_ID,
                   nn.NVN_NVN_MASTER,
                   nn.NVN_NAME,
                   nn.NVN_SNAME,
                   nn.NVN_SUBTREEPROC,
                   nn.NVN_RSRC_CODE,
                   nn.nvn_iconname AS NVN_VCOND,
                   nn.nvn_params || nn.nvn_vcond AS NVN_PARAMS
            FROM IKIS_SYS.APPT_NAV_NODE nn
            WHERE 1 = 2
            ORDER BY nn.nvn_num;
    \*        SELECT pm.prmm_id NVN_ID,
                   p_nvn_id AS NVN_NVN_MASTER,
                   pm.prmm_name AS NVN_NAME,
                   pm.prmm_sname AS NVN_SNAME,
                   pm.prmm_subtreeproc AS NVN_SUBTREEPROC,
                   pm.prmm_rsrc_code AS NVN_RSRC_CODE,
                   pm.prmm_vcond AS NVN_VCOND,
                   pm.prmm_params AS NVN_PARAMS
            FROM ParamsMenu pm
            WHERE pm.prmm_master_code = l_group
            ORDER BY pm.prmm_num;*\

      END IF;
    END;
    */
    PROCEDURE get_app_info (p_flag    IN     NUMBER DEFAULT 0,
                            res_cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN RES_CUR FOR
            SELECT 'Єдиний соціальний процесінг' /*TOOLS.GetGlobalParameter('WEB_APP_NAME_AT_MENU')*/
                                                       AS header,
                   'Звернення' /*TOOLS.GetGlobalParameter('WEB_APP_NAME_AT_WIN_HEAD')*/
                                                       AS title,
                   'Розробник: ТОВ "НВП МЕДИРЕНТ"' /*TOOLS.GetGlobalParameter('WEB_DEV_NAME_AT_WIN_FOOTER')*/
                                                       AS developer,
                   ''      /*TOOLS.GetGlobalParameter('WEB_SUPPORT_ADDRESS')*/
                                                       AS supportEmail
              FROM DUAL;
    END;
END DNET$DYNAMIC_MENU;
/