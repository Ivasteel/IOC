/* Formatted on 8/12/2025 6:11:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.IKIS_WEB_TYPICAL_ROLE
IS
    -- Author  : VANO
    -- Created : 07.05.2018 11:12:40
    -- Purpose : Пакет для роботи з типовими ролями з ВЕБ-інтерфейсу

    FUNCTION GetDivisionList
        RETURN T_DICT_TAB
        PIPELINED;

    FUNCTION GetEmployeeList
        RETURN T_DICT_TAB
        PIPELINED;

    FUNCTION GetMonitoringList
        RETURN T_DICT_TAB
        PIPELINED;

    PROCEDURE RolesShowGrid (p_wtr_id IN NUMBER);

    PROCEDURE SaveWTR (
        p_wtr_id         IN OUT w_typical_role.wtr_id%TYPE,
        p_wtr_name              w_typical_role.wtr_name%TYPE,
        p_wtr_st                w_typical_role.wtr_st%TYPE,
        p_wtr_start_dt          w_typical_role.wtr_start_dt%TYPE,
        p_wtr_stop_dt           w_typical_role.wtr_stop_dt%TYPE,
        p_wtr_noc               w_typical_role.wtr_noc%TYPE);

    PROCEDURE SaveWTRR (p_wtr_id IN w_typical_role.wtr_id%TYPE);
END IKIS_WEB_TYPICAL_ROLE;
/


GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_TYPICAL_ROLE TO II01RC_SYSWEB_COMM
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_TYPICAL_ROLE TO IKIS_RBM
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_TYPICAL_ROLE TO IKIS_WEBPROXY
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_TYPICAL_ROLE TO USS_ESR
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_TYPICAL_ROLE TO USS_EXCH
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_TYPICAL_ROLE TO USS_NDI
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_TYPICAL_ROLE TO USS_PERSON
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_TYPICAL_ROLE TO USS_RNSP
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_TYPICAL_ROLE TO USS_RPT
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_TYPICAL_ROLE TO USS_VISIT
/


/* Formatted on 8/12/2025 6:11:45 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.IKIS_WEB_TYPICAL_ROLE
IS
    msgCOMMON_EXCEPTION   NUMBER := 2;
    msgOperAccessViol     NUMBER := 5433;

    exUsrExists           EXCEPTION;
    exOperAccessViol      EXCEPTION;

    FUNCTION GetDivisionList
        RETURN T_DICT_TAB
        PIPELINED
    IS
    BEGIN
        /*FOR xx IN (SELECT noc_id, noc_unit_name
                   FROM ikis_mtacc.v_ndi_org_chart)
        LOOP
          PIPE ROW (T_DICT_ROW(xx.noc_id, '', xx.noc_unit_name, NULL));
        END LOOP;  */
        --vano20210208
        RETURN;
    END;

    FUNCTION GetEmployeeList
        RETURN T_DICT_TAB
        PIPELINED
    IS
        l_flds   T_DICT_FIELDS;
    BEGIN
        FOR zz
            IN (  SELECT fnc_id,
                            'РНОКПП: '
                         || fnc_rnokpp
                         || ' - '
                         || fnc_ln
                         || ' '
                         || SUBSTR (fnc_fn, 1, 1)
                         || '.'
                         || SUBSTR (fnc_mn, 1, 1)
                         || '. ('
                         || nsp_name
                         || ' - '
                         || noc_unit_name
                         || ')'    AS ep_data,
                         nsp_name,
                         fnc_noc,
                         fnc_start_dt,
                         fnc_stop_dt,
                         fnc_rnokpp,
                         fnc_fn,
                         fnc_ln,
                         fnc_mn
                    FROM uss_ndi.v_ndi_functionary_adm
                ORDER BY fnc_ln ASC)
        LOOP
            l_flds := T_DICT_FIELDS ();
            l_flds.EXTEND ();
            l_flds (1) :=
                   'ep_name='
                || zz.fnc_ln
                || ' '
                || zz.fnc_fn
                || ' '
                || zz.fnc_mn;
            l_flds.EXTEND ();
            l_flds (2) := 'ep_nsp_name=' || zz.nsp_name;
            l_flds.EXTEND ();
            l_flds (3) := 'ep_nsp_noc=' || zz.fnc_noc;
            l_flds.EXTEND ();
            l_flds (4) :=
                'ep_release_dt=' || TO_CHAR (zz.fnc_stop_dt, 'DD.MM.YYYY');
            l_flds.EXTEND ();
            l_flds (5) := 'ep_drfo=' || zz.fnc_rnokpp;
            PIPE ROW (T_DICT_ROW (zz.fnc_id,
                                  '',
                                  zz.ep_data,
                                  l_flds));
        END LOOP;

        /*FOR zz IN (SELECT ep_id, '№ '||ep_tab_number||' - '||ins_ln||' '||SUBSTR(ins_fn, 1, 1)||'.'||SUBSTR(ins_mn, 1, 1)||'. ('||nsp_name||' - '||noc_unit_name||')' AS ep_data,
                          nsp_name, nsc_noc, ep_placement_dt, ep_release_dt, in_drfo, ins_fn, ins_ln, ins_mn
                   from ikis_mtacc.v_employee_info_adm --20191219 -Sbond ikis_mtacc.v_employee_info
                   ORDER BY ins_ln ASC)
        LOOP
          l_flds := T_DICT_FIELDS();
          l_flds.extend();
          l_flds(1) := 'ep_name='||zz.ins_ln||' '||zz.ins_fn||' '||zz.ins_mn;
          l_flds.extend();
          l_flds(2) := 'ep_nsp_name='||zz.nsp_name;
          l_flds.extend();
          l_flds(3) := 'ep_nsp_noc='||zz.nsc_noc;
          l_flds.extend();
          l_flds(4) := 'ep_release_dt='||to_char(zz.ep_release_dt, 'DD.MM.YYYY');
          l_flds.extend();
          l_flds(5) := 'ep_drfo='||zz.in_drfo;
          PIPE ROW (T_DICT_ROW(zz.ep_id, '',  zz.ep_data, l_flds));
        END LOOP;  */
        --vano20210208
        RETURN;
    END;

    FUNCTION GetMonitoringList
        RETURN T_DICT_TAB
        PIPELINED
    IS
        l_flds   T_DICT_FIELDS;
    BEGIN
        /*FOR zz IN (SELECT *
                   FROM v$w_users, ikis_mtacc.v_employee_info, v_w_typical_role
                   WHERE (wu_locked = 'N' OR wu_locked IS NULL)
                     AND ep_id = wu_ep
                     AND wu_wtr = wtr_id(+)
                     AND ep_release_dt IS NOT NULL)
        LOOP
          l_flds := T_DICT_FIELDS();
          l_flds.extend();
          l_flds(1) := 'x_login='||zz.wu_login;
          l_flds.extend();
          l_flds(2) := 'x_locked='||CASE WHEN zz.wu_locked = 'Y' THEN 'Заблоковано' ELSE 'Діючий' END;
          l_flds.extend();
          l_flds(3) := 'x_pib='||zz.wu_pib;
          l_flds.extend();
          l_flds(4) := 'x_unit_name='||zz.noc_unit_name;
          l_flds.extend();
          l_flds(5) := 'x_unit_name='||zz.noc_unit_name;
          l_flds.extend();
          l_flds(6) := 'x_position='||zz.nsp_name;
          l_flds.extend();
          l_flds(7) := 'x_numid='||zz.wu_numid;
          l_flds.extend();
          l_flds(8) := 'x_wtr_name='||zz.wtr_name;
          l_flds.extend();
          l_flds(9) := 'x_wtr_stop_dt='||to_char(zz.wtr_stop_dt, 'DD.MM.YYYY');
          l_flds.extend();
          l_flds(10) := 'x_placement_dt='||to_char(zz.ep_placement_dt, 'DD.MM.YYYY');
          l_flds.extend();
          l_flds(11) := 'x_release_dt='||to_char(zz.ep_release_dt, 'DD.MM.YYYY');

          PIPE ROW (T_DICT_ROW(zz.wu_id, 'P01', 'Працівника <'||zz.wu_pib||'> звільнено, але користувач не заблокований', l_flds));
        END LOOP;

        FOR zz IN (SELECT *
                   FROM v$w_users ma, ikis_mtacc.v_employee_info, v_w_typical_role
                   WHERE ep_id = wu_ep
                     AND wu_wtr = wtr_id
                     AND EXISTS (SELECT 1
                                 FROM w_usr2roles sl
                                 WHERE sl.wu_id = ma.wu_id
                                   AND NOT EXISTS (SELECT 1
                                                   FROM w_wtr2role
                                                   WHERE wtrr_wr = sl.wr_id
                                                     AND wtrr_wtr = wtr_id)))
        LOOP
          l_flds := T_DICT_FIELDS();
          l_flds.extend();
          l_flds(1) := 'x_login='||zz.wu_login;
          l_flds.extend();
          l_flds(2) := 'x_locked='||CASE WHEN zz.wu_locked = 'Y' THEN 'Заблоковано' ELSE 'Діючий' END;
          l_flds.extend();
          l_flds(3) := 'x_pib='||zz.wu_pib;
          l_flds.extend();
          l_flds(4) := 'x_unit_name='||zz.noc_unit_name;
          l_flds.extend();
          l_flds(5) := 'x_unit_name='||zz.noc_unit_name;
          l_flds.extend();
          l_flds(6) := 'x_position='||zz.nsp_name;
          l_flds.extend();
          l_flds(7) := 'x_numid='||zz.wu_numid;
          l_flds.extend();
          l_flds(8) := 'x_wtr_name='||zz.wtr_name;
          l_flds.extend();
          l_flds(9) := 'x_wtr_stop_dt='||to_char(zz.wtr_stop_dt, 'DD.MM.YYYY');
          l_flds.extend();
          l_flds(10) := 'x_placement_dt='||to_char(zz.ep_placement_dt, 'DD.MM.YYYY');
          l_flds.extend();
          l_flds(11) := 'x_release_dt='||to_char(zz.ep_release_dt, 'DD.MM.YYYY');

          PIPE ROW (T_DICT_ROW(zz.wu_id, 'P02', 'Працівнику <'||zz.wu_pib||'> надано ролі, яких немає в обраній для нього типовій ролі!', l_flds));
        END LOOP;

        FOR zz IN (SELECT *
                   FROM v$w_users ma, ikis_mtacc.v_employee_info, v_w_typical_role
                   WHERE ep_id = wu_ep
                     AND wu_wtr = wtr_id
                     AND wtr_stop_dt < TRUNC(sysdate))
        LOOP
          l_flds := T_DICT_FIELDS();
          l_flds.extend();
          l_flds(1) := 'x_login='||zz.wu_login;
          l_flds.extend();
          l_flds(2) := 'x_locked='||CASE WHEN zz.wu_locked = 'Y' THEN 'Заблоковано' ELSE 'Діючий' END;
          l_flds.extend();
          l_flds(3) := 'x_pib='||zz.wu_pib;
          l_flds.extend();
          l_flds(4) := 'x_unit_name='||zz.noc_unit_name;
          l_flds.extend();
          l_flds(5) := 'x_unit_name='||zz.noc_unit_name;
          l_flds.extend();
          l_flds(6) := 'x_position='||zz.nsp_name;
          l_flds.extend();
          l_flds(7) := 'x_numid='||zz.wu_numid;
          l_flds.extend();
          l_flds(8) := 'x_wtr_name='||zz.wtr_name;
          l_flds.extend();
          l_flds(9) := 'x_wtr_stop_dt='||to_char(zz.wtr_stop_dt, 'DD.MM.YYYY');
          l_flds.extend();
          l_flds(10) := 'x_placement_dt='||to_char(zz.ep_placement_dt, 'DD.MM.YYYY');
          l_flds.extend();
          l_flds(11) := 'x_release_dt='||to_char(zz.ep_release_dt, 'DD.MM.YYYY');

          PIPE ROW (T_DICT_ROW(zz.wu_id, 'P03', 'Працівнику <'||zz.wu_pib||'> обрано типову роль, яка вже не діє!', l_flds));
        END LOOP;

        FOR zz IN (SELECT *
                   FROM v$w_users ma, ikis_mtacc.v_employee_info, v_w_typical_role
                   WHERE ep_id = wu_ep
                     AND wu_wtr = wtr_id
                     AND EXISTS (SELECT 1
                                 FROM w_usr2roles sl, w_roles rr
                                 WHERE sl.wu_id = ma.wu_id
                                   AND sl.wr_id = rr.wr_id
                                   AND rr.wr_actual = 'D'))
        LOOP
          l_flds := T_DICT_FIELDS();
          l_flds.extend();
          l_flds(1) := 'x_login='||zz.wu_login;
          l_flds.extend();
          l_flds(2) := 'x_locked='||CASE WHEN zz.wu_locked = 'Y' THEN 'Заблоковано' ELSE 'Діючий' END;
          l_flds.extend();
          l_flds(3) := 'x_pib='||zz.wu_pib;
          l_flds.extend();
          l_flds(4) := 'x_unit_name='||zz.noc_unit_name;
          l_flds.extend();
          l_flds(5) := 'x_unit_name='||zz.noc_unit_name;
          l_flds.extend();
          l_flds(6) := 'x_position='||zz.nsp_name;
          l_flds.extend();
          l_flds(7) := 'x_numid='||zz.wu_numid;
          l_flds.extend();
          l_flds(8) := 'x_wtr_name='||zz.wtr_name;
          l_flds.extend();
          l_flds(9) := 'x_wtr_stop_dt='||to_char(zz.wtr_stop_dt, 'DD.MM.YYYY');
          l_flds.extend();
          l_flds(10) := 'x_placement_dt='||to_char(zz.ep_placement_dt, 'DD.MM.YYYY');
          l_flds.extend();
          l_flds(11) := 'x_release_dt='||to_char(zz.ep_release_dt, 'DD.MM.YYYY');

          PIPE ROW (T_DICT_ROW(zz.wu_id, 'P04', 'Працівнику <'||zz.wu_pib||'> надано не діючі ролі!', l_flds));
        END LOOP;

        FOR zz IN (SELECT *
                   FROM v$w_users ma, ikis_mtacc.v_employee_info, v_w_typical_role
                   WHERE ep_id = wu_ep
                     AND wu_wtr = wtr_id
                     AND nsc_noc <> wtr_noc)
        LOOP
          l_flds := T_DICT_FIELDS();
          l_flds.extend();
          l_flds(1) := 'x_login='||zz.wu_login;
          l_flds.extend();
          l_flds(2) := 'x_locked='||CASE WHEN zz.wu_locked = 'Y' THEN 'Заблоковано' ELSE 'Діючий' END;
          l_flds.extend();
          l_flds(3) := 'x_pib='||zz.wu_pib;
          l_flds.extend();
          l_flds(4) := 'x_unit_name='||zz.noc_unit_name;
          l_flds.extend();
          l_flds(5) := 'x_unit_name='||zz.noc_unit_name;
          l_flds.extend();
          l_flds(6) := 'x_position='||zz.nsp_name;
          l_flds.extend();
          l_flds(7) := 'x_numid='||zz.wu_numid;
          l_flds.extend();
          l_flds(8) := 'x_wtr_name='||zz.wtr_name;
          l_flds.extend();
          l_flds(9) := 'x_wtr_stop_dt='||to_char(zz.wtr_stop_dt, 'DD.MM.YYYY');
          l_flds.extend();
          l_flds(10) := 'x_placement_dt='||to_char(zz.ep_placement_dt, 'DD.MM.YYYY');
          l_flds.extend();
          l_flds(11) := 'x_release_dt='||to_char(zz.ep_release_dt, 'DD.MM.YYYY');

          PIPE ROW (T_DICT_ROW(zz.wu_id, 'P05', 'Працівнику <'||zz.wu_pib||'> надоно типову роль для іншого підрозділу!', l_flds));
        END LOOP;*/
        --vano20210208

        /*  FOR zz IN (SELECT 1 AS d_id, 'P01' AS d_tp, 'Працівника <Іванов В.В.> звільнено, але користувач не заблокований!' AS d_name
                     FROM dual
                     UNION ALL
                     \*SELECT 2 AS d_id, 'P02' AS d_tp, 'Працівник <Смирнов Д.К.> має ролі, які не передбачено типовою ролью, яку йому надано!' AS d_name
                     FROM dual
                     UNION ALL*\
                     SELECT 2 AS d_id, 'P03' AS d_tp, 'В типової ролі <Призначення пенсій 2 квартал 2018> закінчився строк дії, але її видано 6 користувачам!' AS d_name
                     FROM dual)
          LOOP
            l_flds := T_DICT_FIELDS();
            l_flds.extend();
            l_flds(1) := 'NAME='||zz.d_name;
            PIPE ROW (T_DICT_ROW(zz.d_id, zz.d_tp, zz.d_name, l_flds));
          END LOOP;  */
        RETURN;
    END;


    PROCEDURE RolesShowGrid (p_wtr_id IN NUMBER)
    IS
        l_usrtp   VARCHAR2 (10);
        l_org     NUMBER (5);
    BEGIN
        l_usrtp :=
            CASE SYS_CONTEXT (ikis_web_context.gContext,
                              ikis_web_context.gUserTP)
                WHEN 1
                THEN
                    4
                WHEN 2
                THEN
                    5
                WHEN 3
                THEN
                    6
            END;
        l_org :=
            TO_NUMBER (
                SYS_CONTEXT (ikis_web_context.gContext,
                             ikis_web_context.gOPFU));

        --Ikis_sysweb.ikis_htmldb_common.pipe_debug(0, p_wtr_id);

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

        FOR groupole
            IN (  SELECT rg.wrg_id, rg.wrg_desc, rg.wrg_actual
                    FROM v_w_roles_group rg
                   WHERE EXISTS
                             (SELECT 1
                                FROM w_roles r, w_wrg2role wrg, w_roles2type rt
                               WHERE     r.wr_id = wrg.wrgr_wr
                                     AND (   r.wr_actual = 'A'
                                          OR EXISTS
                                                 (SELECT 1
                                                    FROM w_wtr2role,
                                                         w_typical_role
                                                   WHERE     wtrr_wtr =
                                                             p_wtr_id
                                                         AND wtrr_wtr = wtr_id
                                                         AND wtr_org = l_org
                                                         AND wtrr_wr = r.wr_id))
                                     AND rg.wrg_id = wrg.wrgr_wrg
                                     AND r.wr_id = rt.wr_id
                                     AND rt.wut_id = l_usrtp)
                ORDER BY rg.wrg_ord)
        LOOP                                                         --#91c58d
            HTP.p (
                   '<h3 style="background: #C5E9C3 none repeat scroll 0 0; border-color: #59495d;" '
                || CASE
                       WHEN groupole.wrg_actual = 'D' THEN ' notact="1" '
                       ELSE ''
                   END
                || '>'
                || groupole.wrg_desc
                || '</h3>');
            HTP.p ('<div><p>');

            FOR roles
                IN (  SELECT r.wr_id,
                             r.wr_descr,
                             r.wr_name,
                             wrg.wrgr_wrg,
                             r.wr_actual,
                             wtrr_id
                        FROM w_roles     r,
                             w_wrg2role  wrg,
                             w_roles2type rt,
                             w_wtr2role  ma
                       WHERE     wrg.wrgr_wrg = groupole.wrg_id
                             AND wrg.wrgr_wr = r.wr_id
                             AND r.wr_id = rt.wr_id
                             AND wtrr_wtr(+) = p_wtr_id
                             AND ma.wtrr_wr(+) = r.wr_id
                             AND rt.wut_id = l_usrtp
                             AND (   r.wr_actual = 'A'
                                  OR EXISTS
                                         (SELECT 1
                                            FROM w_wtr2role sl, w_typical_role
                                           WHERE     sl.wtrr_wtr = p_wtr_id
                                                 AND sl.wtrr_wtr = wtr_id
                                                 AND wtr_org = l_org
                                                 AND sl.wtrr_wr = r.wr_id))
                    ORDER BY wrg.wrgr_ord)
            LOOP
                HTP.p (
                       '<div '
                    || CASE
                           WHEN roles.wr_actual = 'D'
                           THEN
                               'style="color:red"'
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
                                WHEN roles.wtrr_id IS NOT NULL THEN 'checked'
                                ELSE 'unchecked'
                            END));
                HTP.p (roles.wr_descr || '</div>');
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
            /*||case when l_wu_locked = 'Y' then '
           $("#rolesgroup input[type=checkbox]").attr("disabled",true);
           $("#R49020122941177769 input[lkbl]").prop("readonly", true);
           $("#lockstatus").parent().html("<td colspan=''2''><div style=''width: 300px; line-height: 20px; height: 20px; color: rgb(255, 0, 0); '||
           ' text-align:left; vertical-align: middle; font-weight: bold; ''>Заблоковано '||to_char(l_wuh_auth_dt, 'dd.mm.yyyy hh24:mi:ss')||'</div></td>");'
            else '' end*/
            || '
  </script> ');
    END;

    PROCEDURE SaveWTR (
        p_wtr_id         IN OUT w_typical_role.wtr_id%TYPE,
        p_wtr_name              w_typical_role.wtr_name%TYPE,
        p_wtr_st                w_typical_role.wtr_st%TYPE,
        p_wtr_start_dt          w_typical_role.wtr_start_dt%TYPE,
        p_wtr_stop_dt           w_typical_role.wtr_stop_dt%TYPE,
        p_wtr_noc               w_typical_role.wtr_noc%TYPE)
    IS
    BEGIN
        --Збереження налаштування типової ролі - тільки адміністраторами доступу.
        IF NOT (   ikis_htmldb_common.is_role_assigned (
                       p_username   => v ('USER'),
                       p_role       => 'W_ADM_IC')
                OR ikis_htmldb_common.is_role_assigned (
                       p_username   => v ('USER'),
                       p_role       => 'W_ADM_RE')
                OR ikis_htmldb_common.is_role_assigned (
                       p_username   => v ('USER'),
                       p_role       => 'W_ADM_MU'))
        THEN
            RAISE exOperAccessViol;
        END IF;

        --В залежності від того, чи прийшов з інтерфейсу Ід-типової ролі - створюємо нову типову роль або оновлюємо існуючу. При оновленні - додатково обмежуємо "своїм" ОПФУ.
        IF p_wtr_id IS NULL
        THEN
            INSERT INTO w_typical_role (wtr_id,
                                        wtr_org,
                                        wtr_name,
                                        wtr_st,
                                        wtr_start_dt,
                                        wtr_stop_dt,
                                        wtr_noc)
                 VALUES (
                            0,
                            TO_NUMBER (
                                SYS_CONTEXT (ikis_web_context.gContext,
                                             ikis_web_context.gOPFU)),
                            p_wtr_name,
                            p_wtr_st,
                            p_wtr_start_dt,
                            p_wtr_stop_dt,
                            p_wtr_noc)
              RETURNING wtr_id
                   INTO p_wtr_id;
        ELSE
            UPDATE w_typical_role
               SET wtr_name = p_wtr_name,
                   wtr_st = p_wtr_st,
                   wtr_start_dt = p_wtr_start_dt,
                   wtr_stop_dt = p_wtr_stop_dt,
                   wtr_noc = p_wtr_noc
             WHERE     wtr_id = p_wtr_id
                   AND wtr_org =
                       TO_NUMBER (
                           SYS_CONTEXT (ikis_web_context.gContext,
                                        ikis_web_context.gOPFU));
        END IF;
    EXCEPTION
        WHEN exOperAccessViol
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgOperAccessViol,
                                               'Призначення/Відміна ролі'));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgCOMMON_EXCEPTION,
                                               'SaveWTRR',
                                               CHR (10) || SQLERRM));
    END;

    PROCEDURE SaveWTRR (p_wtr_id IN w_typical_role.wtr_id%TYPE)
    IS
        TYPE t_roles IS TABLE OF NUMBER (14)
            INDEX BY PLS_INTEGER;

        l_t_roles   t_roles;
        l_str       VARCHAR2 (250);

        FUNCTION SearchVal (p_array t_roles, p_val NUMBER)
            RETURN BOOLEAN
        IS
        BEGIN
            FOR i IN 1 .. p_array.COUNT
            LOOP
                IF p_array (i) = p_val
                THEN
                    RETURN TRUE;
                END IF;
            END LOOP;

            RETURN FALSE;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL; --Ikis_sysweb.ikis_htmldb_common.pipe_debug(0,'ПОМИЛКА1! шукали='||p_val);
        END;

        FUNCTION SearchVal (p_array   htmldb_application_global.vc_arr2,
                            p_val     NUMBER)
            RETURN BOOLEAN
        IS
        BEGIN
            FOR i IN 1 .. p_array.COUNT
            LOOP
                IF p_array (i) = p_val
                THEN
                    RETURN TRUE;
                END IF;
            END LOOP;

            RETURN FALSE;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL; --Ikis_sysweb.ikis_htmldb_common.pipe_debug(0,'ПОМИЛКА2! шукали='||p_val);
        END;
    BEGIN
        --Збереження налаштування типової ролі - тільки адміністраторами доступу.
        IF NOT (   ikis_htmldb_common.is_role_assigned (
                       p_username   => v ('USER'),
                       p_role       => 'W_ADM_IC')
                OR ikis_htmldb_common.is_role_assigned (
                       p_username   => v ('USER'),
                       p_role       => 'W_ADM_RE')
                OR ikis_htmldb_common.is_role_assigned (
                       p_username   => v ('USER'),
                       p_role       => 'W_ADM_MU'))
        THEN
            RAISE exOperAccessViol;
        END IF;

        --Ikis_sysweb.ikis_htmldb_common.pipe_debug(0,'p_wtr_id='||p_wtr_id);

        SELECT wr_id
          BULK COLLECT INTO l_t_roles
          FROM w_wtr2role, w_roles
         WHERE wtrr_wtr = p_wtr_id AND wtrr_wr = wr_id;

        --Ikis_sysweb.ikis_htmldb_common.pipe_debug(0,'c='||SQL%ROWCOUNT);

        --Додаємо нові ролі в типову роль. Обмеження - тільки для типових ролей "свого" ОПФУ.
        FOR i IN 1 .. APEX_APPLICATION.g_f10.COUNT
        LOOP
            IF NOT (SearchVal (l_t_roles, APEX_APPLICATION.g_f10 (i)))
            THEN
                INSERT INTO w_wtr2role (wtrr_id, wtrr_wr, wtrr_wtr)
                    SELECT 0,
                           TO_NUMBER (APEX_APPLICATION.g_f10 (i)),
                           p_wtr_id
                      FROM w_typical_role
                     WHERE     wtr_id = p_wtr_id
                           AND wtr_org =
                               TO_NUMBER (
                                   SYS_CONTEXT (ikis_web_context.gContext,
                                                ikis_web_context.gOPFU));
            END IF;
        END LOOP;

        --Видаляємо ролі з типової ролі. Обмеження - тільки для типових ролей "свого" ОПФУ.
        FOR i IN 1 .. l_t_roles.COUNT
        LOOP
            IF NOT (SearchVal (APEX_APPLICATION.g_f10, l_t_roles (i)))
            THEN
                --      Ikis_sysweb.ikis_htmldb_common.pipe_debug(0,'видаляємо роль з ід='||l_t_roles(i));
                DELETE FROM w_wtr2role
                      WHERE     wtrr_wr = l_t_roles (i)
                            AND wtrr_wtr = p_wtr_id
                            AND EXISTS
                                    (SELECT 1
                                       FROM w_typical_role
                                      WHERE     wtr_id = wtrr_wtr
                                            AND wtr_org =
                                                TO_NUMBER (
                                                    SYS_CONTEXT (
                                                        ikis_web_context.gContext,
                                                        ikis_web_context.gOPFU)));
            --      Ikis_sysweb.ikis_htmldb_common.pipe_debug(0,'c='||SQL%ROWCOUNT);
            END IF;
        END LOOP;
    EXCEPTION
        WHEN exOperAccessViol
        THEN
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (msgOperAccessViol,
                                               'Призначення/Відміна ролі'));
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'SaveWTRR'
                || CHR (10)
                || SQLERRM
                || DBMS_UTILITY.format_error_backtrace);
    END;
BEGIN
    -- Initialization
    NULL;
END IKIS_WEB_TYPICAL_ROLE;
/