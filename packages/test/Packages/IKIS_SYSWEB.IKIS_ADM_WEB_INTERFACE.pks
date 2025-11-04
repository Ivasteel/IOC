/* Formatted on 8/12/2025 6:11:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.IKIS_ADM_WEB_INTERFACE
IS
    -- Author  : SBOND
    -- Created : 16.05.2016 15:47:48
    -- Purpose : пакет для рисование ролей

    PROCEDURE RolesShowGrid (p_wu_id    IN NUMBER,
                             p_usrtp    IN VARCHAR2,
                             p_wu_wtr   IN NUMBER DEFAULT -1);

    PROCEDURE SaveRoles (p_wu_login IN VARCHAR2);

    PROCEDURE DrawPopUpWindowWithRole;

    PROCEDURE AjaxReturnRoleTable;

    PROCEDURE DownloadHelpFile (p_code IN VARCHAR2);

    PROCEDURE LoginCardPage;

    PROCEDURE AjaxLoginFnk;
END IKIS_ADM_WEB_INTERFACE;
/


GRANT EXECUTE ON IKIS_SYSWEB.IKIS_ADM_WEB_INTERFACE TO IKIS_WEBPROXY
/


/* Formatted on 8/12/2025 6:11:42 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.IKIS_ADM_WEB_INTERFACE
IS
    --msgCOMMON_EXCEPTION                 number := 2;
    exOperAccessViol   EXCEPTION;

    --msgRoleTypeViol                     number := 5432;
    --msgOperAccessViol                   number := 5433;

    PROCEDURE RolesShowGrid (p_wu_id    IN NUMBER,
                             p_usrtp    IN VARCHAR2,
                             p_wu_wtr   IN NUMBER DEFAULT -1)
    IS
        l_usrtp         VARCHAR2 (10);
        l_login         v$w_users.wu_login%TYPE;
        l_wu_locked     v$w_users.wu_locked%TYPE;
        l_wuh_auth_dt   v$w_users_hst.wuh_auth_dt%TYPE;
        l_wtr           w_users.wu_wtr%TYPE;
    BEGIN
        l_wtr := NVL (p_wu_wtr, -1);
        --Ikis_sysweb.ikis_htmldb_common.pipe_debug(0,'для типової ролі='||l_wtr);
        --raise_application_error(-20000,'TEST='||l_wtr);
        l_usrtp :=
            NVL (
                p_usrtp,
                CASE
                    WHEN SYS_CONTEXT (ikis_web_context.gContext,
                                      ikis_web_context.gUserTP) =
                         1
                    THEN
                        2
                    WHEN SYS_CONTEXT (ikis_web_context.gContext,
                                      ikis_web_context.gUserTP) =
                         2
                    THEN
                        3
                    WHEN SYS_CONTEXT (ikis_web_context.gContext,
                                      ikis_web_context.gUserTP) =
                         3
                    THEN
                        6
                END);

        BEGIN
            SELECT wu.wu_login, wu.wu_locked
              INTO l_login, l_wu_locked
              FROM v$w_users wu
             WHERE wu.wu_id = p_wu_id AND p_wu_id IS NOT NULL;

            IF l_wu_locked = ikis_const.v_ddw_yn_y
            THEN
                SELECT wuh_auth_dt
                  INTO l_wuh_auth_dt
                  FROM (SELECT ROW_NUMBER ()
                                   OVER (ORDER BY x.wuh_auth_dt DESC)    rn,
                               x.*
                          FROM w_users_hst x
                         WHERE     x.wuh_wu = p_wu_id
                               AND x.wuh_locked = ikis_const.v_ddw_yn_n)
                 WHERE rn = 1;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;

        --197, 233, 195
        HTMLDB_APPLICATION.g_f10.delete;

        HTP.p ('<style type="text/css">
   #rolesgroup .ui-accordion-content {
     height: auto !important;
   }
   .ui-accordion .ui-accordion-content {
      padding: 0 2.2em !important;
   }
   .ui-accordion-header {
      font-weight: bold !important;
      font-size: 14px !important;
      color : #000000 !important;
      height: 15px !important;
   }
  </style>');

        HTP.p ('<div id="rolesgroup" style="width: 800px">');

        --ikis_htmldb_common.pipe_debug(0,l_usrtp||'-'||p_wu_id||'-'||l_wtr);
        FOR groupole
            IN (  SELECT rg.wrg_id,
                         rg.wrg_desc,
                         rg.wrg_actual,
                         (SELECT COUNT (*)
                            FROM w_wtr2role xx, w_wrg2role
                           WHERE     xx.wtrr_wtr = l_wtr
                                 AND xx.wtrr_wr = wrgr_wr
                                 AND wrgr_wrg = wrg_id)
                             AS is_in_typical_role,
                         (SELECT COUNT (*)
                            FROM w_usr2roles ur, w_wrg2role
                           WHERE     ur.wr_id = wrgr_wr
                                 AND ur.wu_id = p_wu_id
                                 AND wrgr_wrg = wrg_id
                                 AND NOT EXISTS
                                         (SELECT 1
                                            FROM w_wtr2role
                                           WHERE wtrr_wr = wrgr_wr))
                             AS is_granted_non_wtr
                    FROM v_w_roles_group rg
                   WHERE     EXISTS
                                 (SELECT 1
                                    FROM w_roles     r,
                                         w_wrg2role  wrg,
                                         w_roles2type rt
                                   WHERE     r.wr_id = wrg.wrgr_wr
                                         AND (   (r.wr_actual = 'A')
                                              OR EXISTS
                                                     (SELECT 1
                                                        FROM w_usr2roles ur,
                                                             v$w_users  u
                                                       WHERE     u.wu_login =
                                                                 l_login
                                                             AND l_login
                                                                     IS NOT NULL
                                                             AND u.wu_id =
                                                                 ur.wu_id
                                                             AND ur.wr_id =
                                                                 r.wr_id))
                                         AND rg.wrg_id = wrg.wrgr_wrg
                                         AND r.wr_id = rt.wr_id
                                         AND rt.wut_id = l_usrtp)
                         --Тільки ті групи, які є в типовій ролі або ті, по яким видані права доступу
                         AND (   EXISTS
                                     (SELECT 1
                                        FROM w_wtr2role xx, w_wrg2role
                                       WHERE     xx.wtrr_wtr = l_wtr
                                             AND xx.wtrr_wr = wrgr_wr
                                             AND wrgr_wrg = wrg_id)
                              OR EXISTS
                                     (SELECT 1
                                        FROM w_usr2roles ur, w_wrg2role
                                       WHERE     ur.wr_id = wrgr_wr
                                             AND ur.wu_id = p_wu_id
                                             AND wrgr_wrg = wrg_id)
                              OR l_wtr = -1)
                ORDER BY rg.wrg_ord)
        LOOP                                                         --#91c58d
            --ikis_htmldb_common.pipe_debug(0,groupole.wrg_id);
            HTP.p (
                   '<h3 style="background: #C5E9C3 none repeat scroll 0 0; border-color: #59495d;" '
                || CASE
                       WHEN groupole.wrg_actual = 'D' THEN ' notact="1" '
                       ELSE ''
                   END
                || '>'
                || '<div>'
                || groupole.wrg_desc
                || CASE
                       WHEN     (   groupole.is_granted_non_wtr > 0
                                 OR groupole.is_in_typical_role = 0)
                            AND l_wtr > 0
                       THEN
                           '<img alt="warn" src="r/ikis_web/files/static/v2Y/warn.ico">'
                       ELSE
                           ''
                   END
                || '</div>'
                || '</h3>');
            HTP.p ('<div><p>');

            FOR roles
                IN (  SELECT r.wr_id,
                             r.wr_descr,
                             r.wr_name,
                             wrg.wrgr_wrg,
                             r.wr_actual,
                             (SELECT COUNT (1)
                                FROM w_wtr2role xx
                               WHERE     xx.wtrr_wtr = l_wtr
                                     AND xx.wtrr_wr = r.wr_id)
                                 AS is_in_typical_role,
                             (SELECT COUNT (1)
                                FROM w_usr2roles ur
                               WHERE ur.wr_id = wrgr_wr AND ur.wu_id = p_wu_id)
                                 AS is_already_granted
                        FROM w_roles r, w_wrg2role wrg, w_roles2type rt
                       WHERE     wrg.wrgr_wrg = groupole.wrg_id
                             AND wrg.wrgr_wr = r.wr_id
                             AND r.wr_id = rt.wr_id
                             AND rt.wut_id = l_usrtp
                             AND (   (r.wr_actual = 'A')
                                  OR EXISTS
                                         (SELECT 1
                                            FROM w_usr2roles ur, v$w_users u
                                           WHERE     u.wu_login = l_login
                                                 AND l_login IS NOT NULL
                                                 AND u.wu_id = ur.wu_id
                                                 AND ur.wr_id = r.wr_id))
                             --Тільки ті ролі, які є в типовій ролі
                             AND (   EXISTS
                                         (SELECT 1
                                            FROM w_wtr2role xx
                                           WHERE     xx.wtrr_wtr = l_wtr
                                                 AND xx.wtrr_wr = r.wr_id)
                                  OR EXISTS
                                         (SELECT 1 -- або ті, по яким видані права доступу
                                            FROM w_usr2roles ur
                                           WHERE     ur.wr_id = wrgr_wr
                                                 AND ur.wu_id = p_wu_id)
                                  OR l_wtr = -1)
                    ORDER BY wrg.wrgr_ord)
            LOOP
                HTP.p (
                       '<div '
                    || CASE
                           WHEN roles.wr_actual = 'D'
                           THEN
                               'style="color:red"'
                           WHEN     roles.is_in_typical_role = 0
                                AND roles.is_already_granted > 0
                                AND l_wtr > 0
                           THEN
                               'style="color:orange"'
                           ELSE
                               ''
                       END
                    || '>');
                HTP.p (
                    wwv_flow_item.checkbox (
                        p_idx     => 10,
                        p_value   => roles.wr_id,
                        p_attributes   =>
                            CASE
                                WHEN ikis_htmldb_common.is_role_assigned (
                                         p_username   => l_login,
                                         p_role       => roles.wr_name)
                                THEN
                                    'checked'
                                ELSE
                                    'unchecked'
                            END));
                HTP.p (roles.wr_descr);
                HTP.p ('</div>');
            END LOOP;

            HTP.p ('</p></div>');
        END LOOP;

        HTP.p ('</div>');

        HTP.p (
               '<script type="text/javascript">
    $(function() {
      $("#rolesgroup").accordion({active: false, autoHeight: false, collapsible: true, animate: 10});
    });

    $("#rolesgroup input:checkbox:checked").parent().css({"font-weight":"800"});

   $("#rolesgroup input:checkbox").click(function() {
        if ($(this).is(":checked")) {
          $(this).parent().css({"font-weight":"800"});
        }
        else {
          $(this).parent().css({"font-weight":"normal"});
        }
    });

    '
            || CASE
                   WHEN l_wu_locked = 'Y'
                   THEN
                          '
    $("#rolesgroup input[type=checkbox]").attr("disabled",true);
    $("#R49020122941177769 input[lkbl]").prop("readonly", true);
    $("#lockstatus").parent().html("<td colspan=''2''><div style=''width: 300px; line-height: 20px; height: 20px; color: rgb(255, 0, 0); '
                       || ' text-align:left; vertical-align: middle; font-weight: bold; ''>Заблоковано '
                       || TO_CHAR (l_wuh_auth_dt, 'dd.mm.yyyy hh24:mi:ss')
                       || '</div></td>");'
                   ELSE
                       ''
               END
            || '
  </script> ');
    END;

    PROCEDURE AjaxReturnRoleTable
    IS
        l_wu_id     v$w_users.wu_id%TYPE;
        l_gr_name   v_w_roles_group.wrg_desc%TYPE;
        l_cnt       INTEGER := 0;
        l_str       VARCHAR2 (10000);
        l_user      v$w_users_all.wu_login%TYPE;
    BEGIN
        l_wu_id := APEX_APPLICATION.g_x01;

        BEGIN
            SELECT wu_login
              INTO l_user
              FROM v$w_users_all
             WHERE wu_id = l_wu_id;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;


        HTP.p (
               '<span id="userloginname" style="display:none;">'
            || REPLACE (REPLACE (l_user, '<', ''), '>')
            || '</span>');
        HTP.p ('<table id="userroles"border="1">');
        HTP.p ('<thead>');
        HTP.p ('<tr><th>Підсистема</th><th>Ролі</th></tr>');
        HTP.p ('<thead>');
        HTP.p ('</thead>');
        HTP.p ('<tbody>');

        FOR gr
            IN (  SELECT rg.wrg_id, rg.wrg_desc
                    FROM v_w_roles_group rg
                   WHERE EXISTS
                             (SELECT 1
                                FROM w_roles r, w_wrg2role wrg
                               WHERE     r.wr_id = wrg.wrgr_wr
                                     AND EXISTS
                                             (SELECT 1
                                                FROM w_usr2roles  ur,
                                                     v$w_users_all u
                                               WHERE     u.wu_id = l_wu_id
                                                     AND u.wu_id = ur.wu_id
                                                     AND ur.wr_id = r.wr_id)
                                     AND rg.wrg_id = wrg.wrgr_wrg)
                ORDER BY rg.wrg_ord)
        LOOP
            l_cnt := l_cnt + 1;
            l_gr_name := gr.wrg_desc;

            FOR roles
                IN (  SELECT r.wr_id,
                             r.wr_descr,
                             r.wr_name,
                             wrg.wrgr_wrg
                        FROM w_roles r, w_wrg2role wrg
                       WHERE     wrg.wrgr_wrg = gr.wrg_id
                             AND wrg.wrgr_wr = r.wr_id
                             AND EXISTS
                                     (SELECT 1
                                        FROM w_usr2roles ur, v$w_users_all u
                                       WHERE     u.wu_id = l_wu_id
                                             AND u.wu_id = ur.wu_id
                                             AND ur.wr_id = r.wr_id)
                    ORDER BY wrg.wrgr_ord)
            LOOP
                IF l_cnt != 1
                THEN
                    l_str :=
                        l_str || '<tr><td>' || roles.wr_descr || '</td></tr>';
                ELSE
                    l_str :=
                           l_str
                        || '<tr><td rowspan="X" style="width:50%" >'
                        || gr.wrg_desc
                        || '</td><td style="width:50%" >'
                        || roles.wr_descr
                        || '</td></tr>';
                END IF;

                l_cnt := l_cnt + 1;
            END LOOP;

            l_cnt := l_cnt - 1;
            l_str :=
                REPLACE (l_str, 'rowspan="X"', 'rowspan="' || l_cnt || '"');
            l_cnt := 0;
        END LOOP;

        HTP.p (l_str);
        HTP.p ('<tbody>');
        HTP.p ('</table>');
    END;

    PROCEDURE DrawPopUpWindowWithRole
    IS
    BEGIN
        HTP.p (
            '<div id="rolesdialog" title="Ролі користувача" style=''display:none; width: 600px; ''>');
        HTP.p ('  <div id="roletbl" style="margin:10px" >');
        HTP.p ('  Завантажується');
        HTP.p ('  </div>');
        HTP.p ('</div>');


        HTP.p ('<script type="text/javascript">');
        HTP.p (
               '
    function showwindowroles(val) {

      $.post(''wwv_flow.show'',
         {"p_request"      : "APPLICATION_PROCESS='
            || 'P10_GET_ROLE_TBL'
            || '",
          "p_flow_id"      : '
            || v ('APP_ID')
            || ',
          "p_flow_step_id" : '
            || v ('APP_PAGE_ID')
            || ',
          "p_instance"     : '
            || v ('APP_SESSION')
            || ',
          "x01"            :  val
          },
          function(data){
            $(function() {
              $( "#rolesdialog" ).dialog({
                modal: true,
                autoResize:true,
                buttons: {
                  Закрити : function() {
                    $(this).dialog("close");
                  }
                }
              });
            });

            $("#roletbl").html(data);

            $("#rolesdialog").dialog({ height: 300, width: 600 });
            $("#rolesdialog").position({ position: "center" });
            $("#rolesdialog").dialog("option", "title", "Ролі користувача " + $("#userloginname").text());
          }
      );

   }
  ');
        HTP.p ('</script>');
    END;

    --$("#rolesdialog").siblings(".ui-dialog-buttonpane").hide();

    PROCEDURE SaveRoles (p_wu_login IN VARCHAR2)
    IS
    BEGIN
        ikis_htmldb_auth.SaveRoles (p_wu_login);
    END;

    PROCEDURE DownloadHelpFile (p_code IN VARCHAR2)
    IS
        l_HelpInformation   HelpInformation%ROWTYPE;
    BEGIN
        SELECT *
          INTO l_HelpInformation
          FROM HelpInformation h
         WHERE h.hi_code = p_code;

        HTP.p (
               'Content-Type: '
            || l_HelpInformation.Hi_Type
            || '; name="'
            || l_HelpInformation.Hi_Filename
            || '"');
        HTP.p (
               'Content-Disposition: attachment; filename="'
            || l_HelpInformation.Hi_Filename
            || '"');
        HTP.p (
               'Content-Length: '
            || DBMS_LOB.getlength (l_HelpInformation.Hi_Content));
        HTP.p ('');
        WPG_DOCLOAD.download_file (l_HelpInformation.Hi_Content);
    END;

    FUNCTION rc (p_str VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN REPLACE (p_str, '''', '''''''''');
    END;

    PROCEDURE AjaxLoginFnk
    IS
        l_opr_act        VARCHAR2 (100);
        l_version        VARCHAR2 (100);
        l_server_url     VARCHAR2 (100);
        l_server_port    VARCHAR2 (100);
        l_download_lnk   VARCHAR2 (100);
        l_eidserver      VARCHAR2 (100);
        l_eidport        VARCHAR2 (100);
        l_cert           servercert.cs_cert%TYPE;
    BEGIN
        l_opr_act := APEX_APPLICATION.g_x01;

        IF l_opr_act = 'GETPARAMETRS'
        THEN
            l_version :=
                ikis_sys.ikis_common.GetApptParam ('WEB_CARD_JS_VERSION');
            l_server_url :=
                ikis_sys.ikis_common.GetApptParam ('WEB_CARD_SERVER');
            l_server_port :=
                ikis_sys.ikis_common.GetApptParam ('WEB_CARD_SERVER_PORT');
            l_download_lnk :=
                ikis_sys.ikis_common.GetApptParam ('WEB_CARD_CLIENT_DNL_LNK');
            l_eidserver :=
                ikis_sys.ikis_common.GetApptParam ('WEB_CARD_EIDSERVER');
            l_eidport :=
                ikis_sys.ikis_common.GetApptParam ('WEB_CARD_EIDPORT');

            --l_cert := ikis_sys.ikis_common.GetApptParam('WEB_CARD_CERT');

            SELECT cs_cert
              INTO l_cert
              FROM servercert
             WHERE sc_code = 'WEB_CARD_CERT';

            APEX_UTIL.json_from_sql (
                   'select '''
                || rc (l_version)
                || ''' version, '''
                || rc (l_server_url)
                || ''' serv_url, '''
                || rc (l_server_port)
                || ''' port, '''
                || rc (l_download_lnk)
                || ''' lnk, '''
                || rc (l_eidserver)
                || ''' eids, '''
                || rc (l_eidport)
                || ''' eidp , '''
                || rc (l_cert)
                || ''' cert from dual');
        END IF;
    END;

    /*procedure LoginCardPage_old is
    begin
      htp.p('<script>');
      htp.p('var openpage=1;');
      htp.p('function openTab(evt, tabName) {
        var i, tabcontent, tablinks;
        tabcontent = document.getElementsByClassName("tabcontent");
        for (i = 0; i < tabcontent.length; i++) {
            tabcontent[i].style.display = "none";
        }');
      htp.p('
        tablinks = document.getElementsByClassName("tablinks");
        for (i = 0; i < tablinks.length; i++) {
            tablinks[i].className = tablinks[i].className.replace(" active", "");
        }');
      htp.p('
        document.getElementById(tabName).style.display = "block";
        var content_elem = ''<div id="body">''+document.getElementById("body").innerHTML+''</div>'';
        if (tabName=="login_card") {
          content_elem = content_elem + ''<div id="cardinfo">\
            </div>'';
        }');
      htp.p('
        var elem = document.getElementById("body"); elem.parentNode.removeChild(elem);
        document.getElementById(tabName).innerHTML = content_elem;
        document.getElementById("LOGIN_TYPE").value = tabName;
        evt.currentTarget.className += " active";
        ');
      htp.p('
        if (openpage==0) {
          if (tabName=="login_card") {
            $("#dialog_precheck").dialog({
              resizable: false,
              height: "auto",
              width: 400,
              modal: true,
              open: function(event, ui) {
                $(".ui-dialog-titlebar-close", ui.dialog | ui).hide();
                GetParamsFromServer();
               }
            });
          }
        }
      }');
      htp.p('
      if ((document.getElementById("LOGIN_TYPE").value==null) || (document.getElementById("LOGIN_TYPE").value=="") || (document.getElementById("LOGIN_TYPE").value=="login_simple") )
      {
        document.getElementById(''login_simple_l'').click();
        openpage = 0;
      } else if (document.getElementById("LOGIN_TYPE").value=="login_card") {
        document.getElementById(''login_card_l'').click();
        openpage = 0;
      }
      ');

      htp.p('
        function LongOperation(caption, body_text) {
          var l_content = ''<div id="loader_gif" style="position: relative;"><div class="load_gif" style ="text-align: center;">\
            <img height="55" width="54" border="0" align="top" src="'||V('IMAGE_PREFIX')||'atlas/ersp/ajax-loader.gif">\
            </div></div><p id="dialog_prechek_mess">''+body_text+''</p></div>'';
          $("span.ui-dialog-title").text(caption);
          document.getElementById("dialog_precheck").innerHTML = l_content;
        }
      ');

      htp.p('
        function GoodVersion(res_val) {
          $("span.ui-dialog-title").text("Версія бібліотек: "+res_val);
          $("#dialog_prechek_mess").text("Іде перевірка параметрів серверу...");
        }
      ');
      htp.p('
        function ShowMessageToForm(caption, body) {
          $("span.ui-dialog-title").text(caption);
           document.getElementById("dialog_precheck").innerHTML = body;
        }
        ');

      htp.p('
        function BadVersion(srv_version, local_version, link) {
          $("span.ui-dialog-title").text("Несумістна версія! Наявна :"+local_version+" актульна "+srv_version );
           document.getElementById("dialog_precheck").innerHTML = ''<div id="newversion">Доступна новіша версія клієнту</div>\
           <form action=''+link+''><button type="submit">Скачать без смс и регистрации</button></form><input type="button" value="Оновити" onClick="window.location.reload()">\
           </div>'';
        }
        ');

      --вибір з переілку пристроїв
      htp.p('
        function SelectDevice(params) {
          var l_select = document.getElementById("devchoosersel");
          var l_select_val = l_select.options[l_select.selectedIndex].text;
          var l_content = ''<div id="loader_gif" style="position: relative;"><div class="load_gif" style ="text-align: center;">\
            <img height="55" width="54" border="0" align="top" src="/ersp/ajax-loader.gif">\
            </div></div> <p id="dialog_prechek_mess">Робота з сесією і запит повноважень...</p></div>'';
          ShowMessageToForm("Передача сесії", l_content);
          SendSesionAndDevice(l_select_val, params);
        }
        ');

      htp.p('
        function GetVersion(p_param) {
          var l_continuum =0;
          var l_addr = p_param.localaddr+":"+p_param.localport;
          var markers = ''{"method":"get_version"}'';
          $.ajax({
            type: ''POST'',
            url: l_addr,
            async: false,
            dataType: "json",
            data: markers,
            success: function(msg) {
              var res_val = msg.result.value;
              var mas_res_local = res_val.split(".");
              var mas_res_srv = p_param.version.split(".");
              if ((mas_res_local[0] = mas_res_srv[0]) && (mas_res_local[1] == mas_res_srv[1])) {
                l_continuum = 1;
                GoodVersion(res_val);
              } else {
                BadVersion(p_param.version, res_val, p_param.lnk);
                l_continuum = 0;
              }
            },
            error : function(msg){
              l_continuum = 0;
              alert("Помилка відповіді від локального серверу при записті версії");
            }
          });
          return l_continuum;
        }
        ');

      htp.p('
        function GetParam(p_param) {
           var l_continuum =0;
           var getstatus = ''{"method":"get_params_status"}'';
            $.ajax({
              type: ''POST'',
              url: p_param.localaddr+":"+p_param.localport,
              async: false,
              dataType: "json",
              data: getstatus,
              success: function(msg) {
                var res_val = msg.result.code;
                if (res_val == ''0'') {
                  l_continuum = 1;
                }  else if (res_val == ''1'') {
                  var l_rp = SetParam(p_param);
                  if (l_rp == 1) {
                    l_continuum = 1;
                  } else {
                     l_continuum = 0;
                  }
                } else {
                  l_continuum = 0;
                  var l_message = ''<div id="content">''+res_val + " " + msg.result.message+''</div>'';
                  ShowMessageToForm("Помилка відповіді", l_message);
                }
              },
              error : function(msg){
                alert("Помилка відповіді від локального серверу при запиті статуса");
                l_continuum = 0;
              }
            });
           return l_continuum;
        }
        ');

      htp.p('
        function SetParam(params) {
          var l_continuum =0;
          LongOperation("Встановлення параметрів","Відбувається налагодження локального серверу");
          var setparams = ''{"method":"set_config_params", "parameters":{"address":"''+params.eids+''","port":"''+params.eidp+''","cert":"''+params.cert+''"}}'';
          var l_message;
          $.ajax({
            type: ''POST'',
            url: params.localaddr+":"+params.localport,
            async: false,
            dataType: "json",
            data: setparams,
            success: function(msg) {
              var res_val = msg.result.code;
              if (res_val != "0") {
                var l_message = ''<div id="newversion">''+res_val + " " + msg.result.message+''</div>'';
                ShowMessageToForm("Помилка відповіді", l_message);
                l_continuum = 0;
              } else {
                l_continuum = 1;
              }
            },
            error : function(msg){
              alert("Помилка відповіді від локального серверу при встановленні парметрів");
              l_continuum = 0;
            }
          });
          return l_continuum;
        }
        ');

      htp.p('
        function getDeviceListOk(answer, params) {
              var res_val = answer.result.code;
              if (res_val == 0) {
                var l_select_list = ''<select id="devchoosersel">'';
                for (var i in answer.result.value) {
                  l_select_list += ''<option  value="''+i+''">''+answer.result.value[i]+''</option>''
                }
                l_select_list += ''</select>'';

                var l_for = ''<div id="devchooser" style="width: auto; height: auto; float:left;">\
                  <p>Виберіть пристирій ''+l_select_list+''\
                  <input type="button" value="Обрати" onClick="SelectDevice(&quot;''+params.localaddr+":"+params.localport+''&quot;)">\
                  </p></div>'';
                ShowMessageToForm("Виберіть пристрій", l_for);
              } else {
                var l_message = ''<div id="devchooser">''+res_val + " " + answer.result.message+''</div>'';
                ShowMessageToForm("Помилка відповіді переліку пристроїв", l_message);
              }
        }
        ');

      htp.p('
        function getDeviceList(params) {
          LongOperation("Запит пристроїв","Відбувається запит доступних пристроїв");
          var l_continuum =0;
          var setparams = ''{"method":"get_device_list", "parametrs":{"card_type":"eid"}}'';
          var l_message;
          $.ajax({
            type: ''POST'',
            url: params.localaddr+":"+params.localport,
            async: false,
            dataType: "json",
            data: setparams,
            success: function(answer) {
              var res_val = answer.result.code;
              if (res_val == ''0'') {
                l_continuum = 1;
                getDeviceListOk(answer, params);
              } else {
                l_continuum =0;
                var l_message = ''<div id="content">''+res_val + " " + answer.result.message+''</div>'';
                ShowMessageToForm("Помилка відповіді при отриманні списку пристроїв", l_message);
              }
            },
            error : function(msg) {
              alert("Помилка відповіді від локального серверу при отриманні переліку пристроїв");
              l_continuum =0;
            }
          });
          return l_continuum;
        }
        ');

      htp.p('
        function SubmitAuth(params) {
          var l_code = document.getElementById("pwd").value;
          if ((l_code!=null)&&(l_code!="")) {
            var l_chat="";
            var l_checkboxs = document.getElementById("checks").getElementsByTagName("input");
            for (i = 0; i < l_checkboxs.length; i++) {
              if (l_checkboxs[i].checked) {
                //''"''+l_checkboxs[i].value+''":"''+
                //l_chat += document.getElementById("checkb_"+l_checkboxs[i].value).innerHTML+''",'';
                l_chat += ''"1",''
              } else {
                l_chat += ''"0",''
              }
            }
            if (l_chat.length > 0) {
              l_chat = l_chat.substring(0, l_chat.length - 1);
            }
            var l_send = ''{"method":"put_auth_info", "parameters":{"pin":"''+l_code+''","chat":[''+l_chat+'']}}'';
            LongOperation("Автентифікація користувача","Обмін та перевірка криптограмм між карткою і сервером");
            $.ajax({
              type: ''POST'',
              url: params,
              async: false,
              dataType: "json",
              data: l_send,
              success: function(answer) {
                var res_val = answer.result.code;
                if (res_val == "0") {
                  l_continuum = 1;
                  $(''#dialog_precheck'').dialog(''close'');
                  document.getElementById("cardinfo").innerHTML=''<span>Картка авторизована! Ведіть логін та пароль</span>'';
                  //doSubmit(''LOGIN'');
                } else {
                  var l_message = ''<div id="newversion">''+res_val + " " + answer.result.message+''</div>'';
                  ShowMessageToForm("Помилка відповіді", l_message);
                  l_continuum = 0;
                }
              },
              error : function(msg){
                alert("Помилка відповіді від локального серверу вставноленні остаточних параметрів");
              }
            });

          } else {
            alert("Поле пін обовязкове для заповнення!");
          }
        }
      ');

      htp.p('
        function CheckVal(p_str) {
          p_str.value = p_str.value.replace(/[^\d]/g, '''');
        };

        function DrawWindowOfAuth(params, p_answ_dev) {
          var l_continuum = 0;
          var l_cert_info = p_answ_dev.result.value.certificate_info;
          var l_transaction_info = p_answ_dev.result.value.transaction_info;
          var l_checks = ''<div id="checks">'';

           for (var i in p_answ_dev.result.value.chat) {
              l_checks += ''<input type="checkbox" value="''+i+''" checked><span id="checkb_''+i+''">''+p_answ_dev.result.value.chat[i]+''</span><Br>'';
           }
          l_checks += ''</div>'';
          var l_content = ''<div id="askfrm">\
            <p>Дані сертифікату: ''+l_cert_info+''</p>'';
          if ((l_transaction_info !=null) && (l_transaction_info !="")) {
            l_content +=''<p>Дані транзакції: ''+l_transaction_info+''</p>'';
          }
          l_content +=l_checks+''\
              <p>Введіть пін <input id="pwd" type="password"  onkeyup="return CheckVal(this);" onchange="return CheckVal(this);"></p>\
              <p style="margin-top: 30px;"><input type="button" onClick="SubmitAuth(&quot;''+params+''&quot;)" value="Підтвердити дані" ></p>\
            </div>'';

          ShowMessageToForm("Оберіть дані", l_content);
          return l_continuum;
        }
      ');

      htp.p('
        function SendSesionAndDevice(p_dev, params) {
          var l_continuum = 0;
          LongOperation("Встановлення пристрою","Встановлення пристрою та параметрів сеансу");
          l_sessionguid = document.getElementById("GUIDSES").value;

          var l_send = ''{"method":"put_app_session", "parameters":{"id":"''+l_sessionguid+''","device":"''+p_dev+''"}}'';

          $.ajax({
            type: ''POST'',
            url: params,
            async: false,
            dataType: "json",
            data: l_send,
            success: function(answer) {
              var res_val = answer.result.code;
              if (res_val == "0") {
                l_continuum = 1;
                l_continuum = DrawWindowOfAuth(params, answer);
              } else {
                var l_message = ''<div id="newversion">''+res_val + " " + answer.result.message+''</div>'';
                ShowMessageToForm("Помилка відповіді", l_message);
                l_continuum = 0;
              }
            },
            error : function(msg){
              alert("Помилка відповіді від локального серверу при отриманні сесії");
            }
          });
          return l_continuum;
        }
        ');

      --Основна функція дії
      htp.p('
        function CardWork(p_param) {
          var l_continuum = 0;

          l_continuum = GetVersion(p_param);

          if (l_continuum == 1) {
            l_continuum = 0;
            LongOperation("Запит параметрів","Іде запит усіх необхідних параметрів...");
            l_continuum = GetParam(p_param) ;
          }
          //l_continuum = DrawWindowOfAuth(p_param.localaddr+":"+p_param.localport, "");
          if (l_continuum == 1) {
            l_continuum = getDeviceList(p_param);
          }
        }
      ');


      --запист параметрі з бази
      htp.p('
       function GetParamsFromServer() {
        var params;
         $.post(''wwv_flow.show'',
             {"p_request"      : "APPLICATION_PROCESS='||'LOGIN_CARD'||'",
              "p_flow_id"      : '||v('APP_ID')||',
              "p_flow_step_id" : '||v('APP_PAGE_ID')||',
              "p_instance"     : '||v('APP_SESSION')||',
              "x01"            :  "GETPARAMETRS"
              },
              function(data){
                var res = JSON.parse(data);
                for (i in res.row) {
                  params = {version : res.row[i].VERSION,
                    lnk:res.row[i].LNK,
                    localaddr: res.row[i].SERV_URL,
                    localport: res.row[i].PORT,
                    eids: res.row[i].EIDS,
                    eidp: res.row[i].EIDP,
                    cert: res.row[i].CERT
                  };
                }
                CardWork(params);
              }
          );
        }
      ');

      htp.p('</script>');
    end;*/


    PROCEDURE LoginCardPage
    IS
    BEGIN
        HTP.p ('<style>');
        HTP.p (
            '.selectl
  {
    -moz-appearance: none;
    background-image: url("data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz4NCjwhLS0gR2VuZXJhdG9yOiBBZG9iZSBJbGx1c3RyYXRvciAxNi4wLjQsIFNWRyBFeHBvcnQgUGx1Zy1JbiAuIFNWRyBWZXJzaW9uOiA2LjAwIEJ1aWxkIDApICAtLT4NCjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+DQo8c3ZnIHZlcnNpb249IjEuMSIgaWQ9IkxheWVyXzEiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHg9IjBweCIgeT0iMHB4Ig0KCSB3aWR0aD0iMzZweCIgaGVpZ2h0PSIzNnB4IiB2aWV3Qm94PSIwIDAgMzYgMzYiIGVuYWJsZS1iYWNrZ3JvdW5kPSJuZXcgMCAwIDM2IDM2IiB4bWw6c3BhY2U9InByZXNlcnZlIj4NCjxyZWN0IG9wYWNpdHk9IjUuMDAwMDAwZS0wMiIgZmlsbD0iIzIzMUYyMCIgd2lkdGg9IjM2IiBoZWlnaHQ9IjM2Ii8+DQo8cGF0aCBvcGFjaXR5PSIwLjUiIGZpbGwtcnVsZT0iZXZlbm9kZCIgY2xpcC1ydWxlPSJldmVub2RkIiBmaWxsPSIjMjMxRjIwIiBkPSJNMTgsMTEuOWw0LjUsNS4xaC05TDE4LDExLjl6IE0xOCwyNC4xTDEzLjUsMTloOQ0KCUwxOCwyNC4xeiIvPg0KPHJlY3Qgb3BhY2l0eT0iOS45OTk5OTllLTAyIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiIGNsaXAtcnVsZT0iZXZlbm9kZCIgZmlsbD0iIzIzMUYyMCIgd2lkdGg9IjEiIGhlaWdodD0iMzYiLz4NCjxnPg0KPC9nPg0KPGc+DQo8L2c+DQo8Zz4NCjwvZz4NCjxnPg0KPC9nPg0KPGc+DQo8L2c+DQo8Zz4NCjwvZz4NCjwvc3ZnPg0K");
    background-position: 100% 0;
    background-repeat: no-repeat;
    background-size: contain;
    overflow: hidden;
    padding-right: 3.2rem;
    text-indent: 0.01px;
    text-overflow: " ";
    font-size: 18px;
    height: 48px;
    line-height: 24px;
  }');
        HTP.p ('</style>');
        HTP.p ('<script>');
        HTP.p ('var openpage=1;');

        --запист параметрі з бази
        HTP.p (
               '
   function GetParamsFromServer() {
    var params;

     $.post(''wwv_flow.show'',
         {"p_request"      : "APPLICATION_PROCESS='
            || 'LOGIN_CARD'
            || '",
          "p_flow_id"      : '
            || v ('APP_ID')
            || ',
          "p_flow_step_id" : '
            || v ('APP_PAGE_ID')
            || ',
          "p_instance"     : '
            || v ('APP_SESSION')
            || ',
          "x01"            :  "GETPARAMETRS"
          },
          function(data){
            var res = JSON.parse(data);
            for (i in res.row) {
              params = {version : res.row[i].VERSION,
                lnk:res.row[i].LNK,
                localaddr: res.row[i].SERV_URL,
                localport: res.row[i].PORT,
                eids: res.row[i].EIDS,
                eidp: res.row[i].EIDP,
                cert: res.row[i].CERT
              };
            }
            CardWork(params);
          }
      );
    }
  ');


        HTP.p ('
  function CheckVal(p_str) {
    p_str.value = p_str.value.replace(/[^\d]/g, '''');
  }; ');
        HTP.p (
               '
    function LongOperation(caption, body_text) {
        $("#dialog_precheck").dialog({
          resizable: false,
          height: "auto",
          width: 400,
          modal: true,
          open: function(event, ui) {
            $(".ui-dialog-titlebar-close", ui.dialog | ui).hide();
           }
        });
      var l_content = ''<div id="loader_gif" style="position: relative;"><div class="load_gif" style ="text-align: center;">\
        <img height="55" width="54" border="0" align="top" src="'
            || V ('IMAGE_PREFIX')
            || 'atlas/ersp/ajax-loader.gif">\
        </div></div><p id="dialog_prechek_mess">''+body_text+''</p></div>'';
      $("span.ui-dialog-title").text(caption);
      document.getElementById("dialog_precheck").innerHTML = l_content;
    }
  ');
        HTP.p (
            '
    function ShowMessageToForm(caption, body) {
        $("#dialog_precheck").dialog({
          resizable: false,
          height: "auto",
          width: 500,
          modal: true,
          open: function(event, ui) {
            $(".ui-dialog-titlebar-close", ui.dialog | ui).hide();
           }
        });
      $("span.ui-dialog-title").text(caption);
      $("#dialog_precheck").css({"margin-right": "20px", "margin-bottom": "20px"});
       document.getElementById("dialog_precheck").innerHTML = body;
    }
    ');

        HTP.p ('
    function CloseWindow() {
      $(''#dialog_precheck'').dialog(''close'');
    }
  ');

        HTP.p ('
  function openTab(evt, tabName) {
    evt.preventDefault();
    var i, tabcontent, tablinks;
    tabcontent = document.getElementsByClassName("tabcontent");
    for (i = 0; i < tabcontent.length; i++) {
        tabcontent[i].style.display = "none";
    }');
        HTP.p ('
    tablinks = document.getElementsByClassName("tablinks");
    for (i = 0; i < tablinks.length; i++) {
        tablinks[i].className = tablinks[i].className.replace(" active", "");
    }');
        HTP.p (
            '
    document.getElementById(tabName).style.display = "block";
    var content_elem = ''<div id="body">''+document.getElementById("body").innerHTML+''</div>'';
    if (tabName=="login_card") {
      content_elem = content_elem + ''<div id="cardinfo">\
        </div>'';
    }');
        HTP.p (
            '
    var elem = document.getElementById("body"); elem.parentNode.removeChild(elem);
    document.getElementById(tabName).innerHTML = content_elem;
    document.getElementById("LOGIN_TYPE").value = tabName;
    evt.currentTarget.className += " active";
    ');
        HTP.p (
            '
    if (openpage==0) {
      if (tabName=="login_card") {
        $("tr").remove("#cardrows");
        $(''[id$=_LOGIN]'').hide();
        $("button[class=''t-Button t-Button--hot '']").hide();

        var l_inner_data = ''<tr id="cardrows">\
          <td align="right"></td><td align="left" rowspan="1" colspan="1">\
            <div class="t-Form-inputContainer col-12">\
            <select  disabled id="devchoosersel" \
            style="width:350px;" class="selectlist selectl"  >\
            <option value="-1">Оберіть пристрій</option></select></div></td>\
          </td>\
          <tr id="cardrows"><td colspan="2"><div id="politics"></div></td>\
          <tr id="cardrows"><td align="right"</td><td align="left" rowspan="1" colspan="2" style="width:377px;">\
            <div class="t-Form-fieldContainer t-Form-fieldContainer--hiddenLabel rel-col ">\
            <div class="t-Form-inputContainer col col-null">\
            <input id="pwd" class="text_field" placeholder="пін" disabled type="password" onkeyup="return CheckVal(this);" \
              onchange="return CheckVal(this);" maxlength="14" size="20" style="font-size: 18px; height: 48px; line-height: 24px;">\
            </div>\
            </div>\
            </td>\
            </td>\
          </td>\
          '';
        $("#GUIDSES").parent().parent().parent().append(l_inner_data);


        GetParamsFromServer();
      } else {
        $("tr").remove("#cardrows");
        $(''[id$=_LOGIN]'').show();
        $(''button[class="t-Button t-Button--hot "]'').attr("onClick","javascript:apex.submit(''P101_LOGIN'');");
        $("button[class=''t-Button t-Button--hot '']").show();

      }

    }
  }');
        HTP.p (
            '
  if ((document.getElementById("LOGIN_TYPE").value==null) || (document.getElementById("LOGIN_TYPE").value=="") || (document.getElementById("LOGIN_TYPE").value=="login_simple") )
  {
    document.getElementById(''login_simple_l'').click();
    openpage = 0;
  } else if (document.getElementById("LOGIN_TYPE").value=="login_card") {
    document.getElementById(''login_card_l'').click();
    openpage = 0;
  }
  ');

        HTP.p (
            '
    function BadVersion(srv_version, local_version, link) {
        $("#dialog_precheck").dialog({
          resizable: false,
          height: "auto",
          width: 400,
          modal: true,
          open: function(event, ui) {
            $(".ui-dialog-titlebar-close", ui.dialog | ui).hide();
           }
        });
      $("span.ui-dialog-title").text("Несумістна версія! Наявна :"+local_version+" актульна "+srv_version );
       document.getElementById("dialog_precheck").innerHTML = ''<div id="newversion">Доступна новіша версія клієнту</div>\
       <form action=''+link+''><button type="submit">Завантажити eIDAgent</button></form><input type="button" value="Оновити сторінку" onClick="window.location.reload()">\
       </div>'';
    }
    ');

        HTP.p (
            '
    function GetVersion(p_param) {
      var l_continuum =0;
      var l_addr = p_param.localaddr+":"+p_param.localport;
      var markers = ''{"method":"get_version"}'';
      $.ajax({
        type: ''POST'',
        url: l_addr,
        async: false,
        dataType: "json",
        data: markers,
        success: function(msg) {
          var res_val = msg.result.value;
          var mas_res_local = res_val.split(".");
          var mas_res_srv = p_param.version.split(".");
          if ((mas_res_local[0] = mas_res_srv[0]) && (mas_res_local[1] == mas_res_srv[1])) {
            l_continuum = 1;
          } else {
            BadVersion(p_param.version, res_val, p_param.lnk);
            l_continuum = 0;
          }
        },
        error : function(msg){
          l_continuum = 0;
          var l_text = ''<div><p>Програмне забезпечення для роботи з електронним службовим посвідченням працівника ПФУ (eIDAgent) не знайдено.</p>\
            <p>Будь ласка, скачайте (натиснувши кнопку нижче) необхідне програмне забезпечення та запустіть його на Вашій робочій станції.</p>\
            <p>В подальшому, перед початком використання електронного службового посвідчення працівника ПФУ переконайтесь, що eIDAgent вже виконується.</p>\
            <form action=''+p_param.lnk+''><button type="submit">Завантажити eIDAgent</button></form>\
            </div>'';

          ShowMessageToForm("Помилка при роботі з локальним сервером", l_text);
          //alert("Помилка відповіді від локального серверу при записті версії");
        }
      });
      return l_continuum;
    }
  ');

        --Основна функція дії
        HTP.p ('
    function CardWork(p_param) {
      var l_continuum = 0;

      l_continuum = GetVersion(p_param);

      if (l_continuum == 1) {
        l_continuum = 0;
        l_continuum = GetParam(p_param) ;
      }

      if (l_continuum == 1) {
        l_continuum = getDeviceList(p_param);
      }
    }
  ');

        --вибір з переілку пристроїв
        /*  htp.p('
            function SelectDevice(params) {
              var l_select = document.getElementById("devchoosersel");
              var l_select_val = l_select.options[l_select.selectedIndex].text;
              var l_content = ''<div id="loader_gif" style="position: relative;"><div class="load_gif" style ="text-align: center;">\
                <img height="55" width="54" border="0" align="top" src="#IMAGE_PREFIX#atlas/ersp/ajax-loader.gif">\
                </div></div> <p id="dialog_prechek_mess">Робота з сесією і запит повноважень...</p></div>'';
              ShowMessageToForm("Передача сесії", l_content);
              SendSesionAndDevice(l_select_val, params);
            }
            ');*/

        HTP.p (
            '
    function GetParam(p_param) {
       var l_continuum =0;
       var getstatus = ''{"method":"get_params_status"}'';
        $.ajax({
          type: ''POST'',
          url: p_param.localaddr+":"+p_param.localport,
          async: false,
          dataType: "json",
          data: getstatus,
          success: function(msg) {
            var res_val = msg.result.code;
            if (res_val == ''0'') {
              l_continuum = 1;
            }  else if (res_val == ''1'') {
              var l_rp = SetParam(p_param);
              if (l_rp == 1) {
                l_continuum = 1;
              } else {
                 l_continuum = 0;
              }
            } else {
              l_continuum = 0;
              //var l_message = ''<div id="content">''+res_val + " " + msg.result.message+''</div>'';
              //ShowMessageToForm("Помилка відповіді", l_message);
            }
          },
          error : function(msg){
            alert("Помилка відповіді від локального серверу при запиті статуса");
            l_continuum = 0;
          }
        });
       return l_continuum;
    }
    ');

        HTP.p (
            '
    function SetParam(params) {
      var l_continuum =0;
      LongOperation("Встановлення параметрів","Відбувається налагодження локального серверу");
      var setparams = ''{"method":"set_config_params", "parameters":{"address":"''+params.eids+''","port":"''+params.eidp+''","cert":"''+params.cert+''"}}'';
      var l_message;
      $.ajax({
        type: ''POST'',
        url: params.localaddr+":"+params.localport,
        async: false,
        dataType: "json",
        data: setparams,
        success: function(msg) {
          var res_val = msg.result.code;
          if (res_val != "0") {
            //var l_message = ''<div id="newversion">''+res_val + " " + msg.result.message+''</div>'';
            //ShowMessageToForm("Помилка відповіді", l_message);
            l_continuum = 0;
          } else {
            l_continuum = 1;
            CloseWindow();
          }
        },
        error : function(msg){
          alert("Помилка відповіді від локального серверу при встановленні парметрів");
          l_continuum = 0;
        }
      });
      return l_continuum;
    }
    ');

        HTP.p (
            '
    function getDeviceListOk(answer, params) {
      var res_val = answer.result.code;
      var l_select = document.getElementById("devchoosersel");
      if (res_val == 0) {
        var l_select_list=''<option  value="-1">Не визначено</option>'';
        for (var i in answer.result.value) {
          l_select_list += ''<option  value="''+i+''">''+answer.result.value[i]+''</option>''
        }
        //SendSesionAndDevice onchange="myFunction()"
        l_select.innerHTML= l_select_list;
        l_select.disabled = false;
        l_select.setAttribute("onchange", ''SendSesionAndDevice(this.options[this.selectedIndex].text, "''+params.localaddr+":"+params.localport+''")'');
      } else {
        var l_message = ''<div id="devchooser">''+res_val + " " + answer.result.message+''</div>'';
        ShowMessageToForm("Помилка відповіді переліку пристроїв", l_message);
      }
    }
    ');

        HTP.p (
            '
    function getDeviceList(params) {
      var l_continuum =0;
      var setparams = ''{"method":"get_device_list", "parametrs":{"card_type":"eid"}}'';
      var l_message;
      $.ajax({
        type: ''POST'',
        url: params.localaddr+":"+params.localport,
        async: false,
        dataType: "json",
        data: setparams,
        success: function(answer) {
          var res_val = answer.result.code;
          if (res_val == ''0'') {
            l_continuum = 1;
            getDeviceListOk(answer, params);
          } else {
            l_continuum =0;
            var l_message = ''<div id="content">''+res_val + " " + answer.result.message+''</div>'';
            ShowMessageToForm("Помилка відповіді при отриманні списку пристроїв", l_message);
          }
        },
        error : function(msg) {
          alert("Помилка відповіді від локального серверу при отриманні переліку пристроїв");
          l_continuum =0;
        }
      });
      return l_continuum;
    }
    ');

        HTP.p (
            '
    function SubmitAuth(params) {
      var l_code = document.getElementById("pwd").value;
      var l_user = $(''[id$=_USERNAME]'').val();
      var l_passwd = $(''[id$=PASSWORD]'').val();
      if ((l_code!=null)&&(l_code!="")) {
        if ((l_user!=null)&&(l_user!="")) {
          if ((l_passwd!=null)&&(l_passwd!="")) {
              LongOperation("Автентифікація користувача","Обмін та перевірка криптограмм між карткою і сервером");
              var l_chat="";
              var l_checkboxs = document.getElementById("checks").getElementsByTagName("input");
              for (i = 0; i < l_checkboxs.length; i++) {
                if (l_checkboxs[i].checked) {
                  l_chat += ''"1",''
                } else {
                  l_chat += ''"0",''
                }
              }
              if (l_chat.length > 0) {
                l_chat = l_chat.substring(0, l_chat.length - 1);
              }

              var l_send = ''{"method":"put_auth_info", "parameters":{"pin":"''+l_code+''","chat":[''+l_chat+'']}}'';
              LongOperation("Автентифікація користувача","Обмін та перевірка криптограмм між карткою і сервером");
              $.ajax({
                type: ''POST'',
                url: params,
                async: false,
                dataType: "json",
                data: l_send,
                success: function(answer) {
                  $(''#dialog_precheck'').dialog(''close'');
                  var res_val = answer.result.code;
                  if (res_val == "0") {
                    l_continuum = 1;
                    $("#pwd").remove();
                    apex.submit(''P101_LOGIN'');
                  } else {
                    var l_message = ''<div id="newversion">''+res_val + " " + answer.result.message+''</div>'';
                    ShowMessageToForm("Помилка відповіді", l_message);
                    l_continuum = 0;
                  }
                },
                error : function(msg){
                  alert("Помилка відповіді від локального серверу вставноленні остаточних параметрів");
                }
              });
            } else {
              alert("Поле пароль обовязкове для заповнення!");
            }
        } else {
          alert("Поле користувач обовязкове для заповнення!");
        }
      } else {
        alert("Поле пін обовязкове для заповнення!");
      }
    }
  ');

        HTP.p (
            '


    function DrawWindowOfAuth(params, p_answ_dev) {
      var l_continuum = 0;
      var l_pwd = document.getElementById(''pwd'');
      pwd.disabled = false;

      var l_perm = document.getElementById(''politics'');

      var l_cert_info = p_answ_dev.result.value.certificate_info;
      var l_transaction_info = p_answ_dev.result.value.transaction_info;
      var l_checks = ''<div id="checks">'';

       for (var i in p_answ_dev.result.value.chat) {
          l_checks += ''<input type="checkbox" value="''+i+''" checked><span id="checkb_''+i+''">''+p_answ_dev.result.value.chat[i]+''</span><Br>'';
       }
      l_checks += ''</div>'';
      var l_content = ''<div id="askfrm" style="margin-bottom: 10px;">\
        <p>''+l_cert_info+'' запитує згоду на використання наступних даних:<br>\
        <ul>\
          <li>ID-працівника</li>\
          <li>ПІБ працівника</li>\
          <li>Посада працівника</li>\
        </ul>\
        </p>'';
      if ((l_transaction_info !=null) && (l_transaction_info !="")) {
        l_content +=''<p>Дані транзакції: ''+l_transaction_info+''</p>'';
      }
      //<p style="margin-top: 30px;"><input type="button" onClick="SubmitAuth(&quot;''+params+''&quot;)" value="Вхід" ></p>\
      l_content +=l_checks+''\
        </div>'';

      var l_btn_attr_click = ''SubmitAuth("''+params+''")'';

      $(''button[class="t-Button t-Button--hot "]'').attr("onClick",l_btn_attr_click);
      $("button[class=''t-Button t-Button--hot '']").show();

      document.getElementById("devchoosersel").disabled = true;
      l_perm.innerHTML=l_content;

      $("#checks").hide();

      return l_continuum;
    }
  ');

        HTP.p (
            '
    function SendSesionAndDevice(p_dev, params) {
      var l_continuum = 0;
      document.getElementById(''politics'').innerHTML="";
      document.getElementById(''pwd'').disabled = true;
      if (p_dev !="Не визначено" ) {
        l_sessionguid = document.getElementById("GUIDSES").value;

        var l_send = ''{"method":"put_app_session", "parameters":{"id":"''+l_sessionguid+''","device":"''+p_dev+''"}}'';

        $.ajax({
          type: ''POST'',
          url: params,
          async: false,
          dataType: "json",
          data: l_send,
          success: function(answer) {
            var res_val = answer.result.code;
            if (res_val == "0") {
              l_continuum = 1;
              l_continuum = DrawWindowOfAuth(params, answer);
            } else {
              var l_message = ''<div id="newversion">''+res_val + " " + answer.result.message+''</div>'';
              ShowMessageToForm("Помилка відповіді відправки рідера", l_message);
              l_continuum = 0;
            }
          },
          error : function(msg){
            alert("Помилка відповіді від локального серверу при отриманні сесії");
          }
        });
      }
      return l_continuum;
    }
    ');


        HTP.p ('</script>');
    END;
END IKIS_ADM_WEB_INTERFACE;
/