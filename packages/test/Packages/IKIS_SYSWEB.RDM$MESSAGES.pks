/* Formatted on 8/12/2025 6:11:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.RDM$MESSAGES
IS
    -- Author  : Slaviq
    -- Created : 26.07.2007 15:31:28
    -- Purpose : Пакет для работы с пользовательскими сообщениями

    PROCEDURE Print_W_Message;

    PROCEDURE SaveMessage;

    FUNCTION CntMsg4User (p_login VARCHAR2)
        RETURN NUMBER;
END RDM$MESSAGES;
/


CREATE OR REPLACE PUBLIC SYNONYM RDM$MESSAGES FOR IKIS_SYSWEB.RDM$MESSAGES
/


GRANT EXECUTE ON IKIS_SYSWEB.RDM$MESSAGES TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.RDM$MESSAGES TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.RDM$MESSAGES TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.RDM$MESSAGES TO IKIS_WEBPROXY WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.RDM$MESSAGES TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.RDM$MESSAGES TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.RDM$MESSAGES TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.RDM$MESSAGES TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.RDM$MESSAGES TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.RDM$MESSAGES TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.RDM$MESSAGES TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.RDM$MESSAGES TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.RDM$MESSAGES TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:11:45 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.RDM$MESSAGES
IS
    BadSimbol   EXCEPTION;

    FUNCTION GetAlternateButton (pCaption VARCHAR2, pLink VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN    '<table summary="" class="t8ButtonAlternative3" border="0" cellpadding="0" cellspacing="0">'
               || '<tr>'
               || '<td valign="middle"><a href="'
               || pLink
               || '"><img src="/i/themes/theme_8/t8bullet01.gif" width="10" height="10" style="margin-left:3px;margin-right:3px;" alt=""/></a></td>'
               || '<td class="t8R" align="right" valign="top"><a href="'
               || pLink
               || '"><img src="/i/themes/theme_8/spacer.gif" alt="" height="14" width="14"></a></td>'
               || '<td class="t8C"><a href="'
               || pLink
               || '" class="t8C">'
               || pCaption
               || '</a></td>'
               || '<td class="t8L" align="right" valign="top"><span class="t8R"><a href="'
               || pLink
               || '"><img src="/i/themes/theme_8/spacer.gif" alt="" height="14" width="14"></a></span></td>'
               || '</tr>'
               || '</table>';
    END;

    FUNCTION CntMsg4User (p_login VARCHAR2)
        RETURN NUMBER
    IS
        l_cnt   NUMBER;
    BEGIN
        NULL;
    END;

    FUNCTION IsAdmin (p_login VARCHAR2)
        RETURN CHAR
    IS
        l_flag   CHAR (1) := 'F';                               --number := 0;
    BEGIN
        SELECT DECODE (COUNT (*), 0, 'F', 'T')
          INTO l_flag
          FROM w_users      u,
               w_user_type  ut,
               w_roles      r,
               w_usr2roles  ur
         WHERE     wu_wut = ut.wut_id
               AND ur.wu_id = u.wu_id
               AND r.wr_id = ur.wr_id
               AND wu_login = UPPER (p_login)
               AND (   r.wr_name = 'W_PWP_ADMIN'
                    OR r.wr_name = 'W_PWP_MINSP' AND u.wu_org = 28000);

        RETURN l_flag;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN 'F';
    END;

    PROCEDURE Print_W_Message
    IS
        l_lookup_sql     VARCHAR2 (250);
        --l_is_admin boolean;
        l_is_admin       CHAR (1) := 'F';
        l_com_org_cntr   VARCHAR2 (10) := 'NO';
        l_com_org        v_opfu.org_id%TYPE;
        u                NUMBER;

        CURSOR c_sql IS
              SELECT ROWNUM,
                     wms_id,
                     wm.wms_wu,
                     wm.wms_begin_dt,
                     wm.wms_end_dt,
                     wms_create_dt,
                     wms_message,
                     wmp_org,
                     wmp_wr,
                     wmp_wut,
                     wmp_user_login,
                     wm.wms_st,
                     CASE
                         WHEN     (l_is_admin = 'T')
                              AND (u.wu_id = wm.wms_wu OR wp.wmp_org = u.wu_org)
                         THEN
                             'T'
                         ELSE
                             'F'
                     END    st_edt
                FROM w_messages wm, w_message_params wp, w_users u
               WHERE     wmp_wms = wms_id
                     AND wu_login = UPPER (v ('USER'))
                     AND (       (   wp.wmp_org = -1
                                  OR wp.wmp_org <> -1 AND wp.wmp_org = u.wu_org)
                             AND (   wp.wmp_wr = -1
                                  OR     wp.wmp_wr <> -1
                                     AND EXISTS
                                             (SELECT 1
                                                FROM w_usr2roles ur
                                               WHERE     ur.wu_id = u.wu_id
                                                     AND ur.wr_id = wp.wmp_wr))
                             AND (   wp.wmp_wut = -1
                                  OR     wp.wmp_wut <> -1
                                     AND EXISTS
                                             (SELECT 1
                                                FROM v_full_user_types ut
                                               WHERE ut.wut_id = u.wu_wut))
                             AND (   l_is_admin = 'T'
                                  OR     l_is_admin <> 'T'
                                     AND wm.wms_st = 'A'
                                     AND TO_DATE (SYSDATE, 'dd.mm.yyyy') BETWEEN wms_begin_dt
                                                                             AND wms_end_dt)
                          OR l_is_admin = 'T' AND u.wu_id = wm.wms_wu
                          OR l_is_admin = 'T' AND l_com_org = 28000)
                     AND wms_create_dt >= TRUNC (SYSDATE, 'YYYY') - 10
            ORDER BY wms_create_dt DESC;
    BEGIN
        --проверяем администратор или нет
        l_is_admin := IsAdmin (v ('USER'));

        --l_com_org := sys_context(IKIS_MIL.IKIS_MIL_CONTEXT.gContext,IKIS_MIL.IKIS_MIL_CONTEXT.gOPFU);
        IF l_is_admin = 'T'
        THEN                                    --Управляющее меню для админов
            HTP.p ('<script language="JavaScript" type="text/javascript">');
            HTP.p ('/*<![CDATA[*/');
            --Функция Очистки
            HTP.p ('function SetClear() { ');
            --htp.p('  document.forms[0]["f11"].value = "-1";');
            --htp.p('  document.forms[0]["f12"].value = "'||to_char(sysdate,'DD.MM.YYYY')||'";');
            HTP.p ('  document.forms[0]["f20"].value = "-1";');
            HTP.p (
                   '  document.forms[0]["f21"].value = "'
                || TO_CHAR (SYSDATE, 'DD.MM.YYYY')
                || '";');
            HTP.p (
                   '  document.forms[0]["f22"].value = "'
                || TO_CHAR (SYSDATE, 'DD.MM.YYYY')
                || '";');

            IF l_com_org = 28000
            THEN
                HTP.p ('  document.forms[0]["f23"].value = "-1";');
            ELSE
                HTP.p (
                       '  document.forms[0]["f23"].value = "'
                    || l_com_org
                    || '";');
            END IF;

            HTP.p ('  document.forms[0]["f24"].value = "-1";');
            HTP.p ('  document.forms[0]["f25"].value = "-1";');
            HTP.p ('  document.forms[0]["f26"].value = "";');
            HTP.p ('  document.forms[0]["f27"].value = "A";');
            HTP.p (' }');
            --Функция выколупывает параметры в форму с параметрами из "массива"
            HTP.p ('function SetPrm(i1) { ');
            --htp.p('  document.forms[0]["f11"].value = document.forms["wwv_flow"]["f30"][i1].value;');
            HTP.p (
                '  document.forms[0]["f20"].value = document.forms["wwv_flow"]["f30"][i1].value;');
            HTP.p (
                '  document.forms[0]["f21"].value = document.forms["wwv_flow"]["f31"][i1].value;');
            HTP.p (
                '  document.forms[0]["f22"].value = document.forms["wwv_flow"]["f32"][i1].value;');
            HTP.p (
                '  document.forms[0]["f23"].value = document.forms["wwv_flow"]["f33"][i1].value;');
            HTP.p (
                '  document.forms[0]["f24"].value = document.forms["wwv_flow"]["f34"][i1].value;');
            HTP.p (
                '  document.forms[0]["f25"].value = document.forms["wwv_flow"]["f35"][i1].value;');
            HTP.p (
                '  document.forms[0]["f26"].value = document.forms["wwv_flow"]["f36"][i1].value;');
            HTP.p (
                '  document.forms[0]["f27"].value = document.forms["wwv_flow"]["f37"][i1].value;');
            --htp.p('  document.forms[0]["f12"].value = document.forms["wwv_flow"]["f38"][i1].value;');
            --htp.p('alert (document.forms["wwv_flow"]["f33"][i1].value); ');
            HTP.p (' }');
            --заполняем "массив"
            HTP.p ('function SetD(a1, i1, v1) {');
            HTP.p ('  document.forms["wwv_flow"]["f"+i1][a1].value=v1;');
            HTP.p ('}');
            HTP.p ('/*]]>*/');
            HTP.p ('</script>');
            HTP.FORMHIDDEN (cname => 'f20', cvalue => -1);
            HTP.p (
                '<table width=200 cellpadding="0" border="0" cellspacing="0" summary="" class="t8standard">');
            HTP.p (
                '<tr><td><th align="right" width=25 class="t8ReportHeader">');
            /*htp.p(htf.bold('Код повідомленя'));
            htp.p('</td><td>&nbsp');
            htp.p('</td><td align="left" width=25>');
            htp.formText('f11');
            --htp.p(wwv_flow_item.text(p_idx => 11));
            htp.p('</tr><tr><td><th align="right" width=25 class="t8ReportHeader">');
            htp.p(htf.bold('Дата створеня'));
            htp.p('</td><td>&nbsp');
            htp.p('</td><td align="left" width=25 class="">');
            htp.formText('f12');
            htp.p('</tr><tr><td><th align="right" width=25 class="t8ReportHeader">');   */
            HTP.p (HTF.bold ('Дата початку актуальності'));
            HTP.p ('</td><td>&nbsp');
            HTP.p ('</td><td align="left" width=25>');
            HTP.p (wwv_flow_item.date_popup (
                       p_idx           => 21,
                       p_value         => TO_CHAR (SYSDATE, 'DD.MM.YYYY'),
                       p_date_format   => 'DD.MM.YYYY',
                       p_size          => 15));
            HTP.p (
                '</tr><tr><td><th align="right" width=25 class="t8ReportHeader">');
            HTP.p (HTF.bold ('Дата закінченя актуальності'));
            HTP.p ('</td><td>&nbsp');
            HTP.p ('</td><td align="left" width=25>');
            HTP.p (wwv_flow_item.date_popup (
                       p_idx           => 22,
                       p_value         => TO_CHAR (SYSDATE, 'DD.MM.YYYY'),
                       p_date_format   => 'DD.MM.YYYY',
                       p_size          => 15));
            HTP.p (
                '<td></tr><tr><td><th align="right" width=80 class="t8ReportHeader">');
            HTP.p (HTF.bold ('Регіон'));
            HTP.p ('</td><td>&nbsp');
            HTP.p ('</td><td align="left" width=50>');
            l_lookup_sql :=
                   'SELECT d, r FROM (SELECT trim(org_code)||'' - ''||trim(org_name) d, org_id r '
                || ' FROM V_MIL$OPFU where org_org = 28000 ';

            IF l_com_org = 28000
            THEN
                l_com_org_cntr := 'YES';
                l_lookup_sql := l_lookup_sql || ')';
            ELSE
                l_com_org_cntr := 'NO';
                l_lookup_sql :=
                    l_lookup_sql || ' and org_id = ' || l_com_org || ' )';
            END IF;

            HTP.p (wwv_flow_item.select_list_from_query (
                       p_idx          => 23,
                       p_value        => NULL,
                       p_query        => l_lookup_sql,
                       p_show_null    => l_com_org_cntr,              --'YES',
                       p_null_value   => '-1',
                       p_null_text    => 'ВСІ',
                       p_show_extra   => 'NO',
                       p_attributes   => 'style="width: 450px"'));
            HTP.p (
                '</tr><tr><td><th align="right" width=70 class="t8ReportHeader">');
            HTP.p (HTF.bold ('Роль користувача'));
            HTP.p ('</td><td>&nbsp');
            HTP.p ('</td><td align="left" width=50>');
            l_lookup_sql :=
                   'SELECT d, r FROM (SELECT distinct wr_descr d, wr_id r from V$W_ROLES w WHERE wr_ss_code = '
                || '''IKIS_MIL'''
                || ' )';
            HTP.p (wwv_flow_item.select_list_from_query (
                       p_idx          => 24,
                       p_value        => NULL,
                       p_query        => l_lookup_sql,
                       p_show_null    => 'YES',
                       p_null_value   => '-1',
                       p_null_text    => 'ВСІ',
                       p_show_extra   => 'NO',
                       p_attributes   => 'style="width: 400px"'));
            HTP.p (
                '</tr><tr><td><th align="right" width=70 class="t8ReportHeader">');
            HTP.p (HTF.bold (' Тип користувача '));
            HTP.p ('</td><td>&nbsp');
            HTP.p ('</td><td align="left" width=50>');
            l_lookup_sql :=
                'SELECT d, r FROM (SELECT wut_name d, wut_id r FROM v_Full_User_Types w)';
            HTP.p (wwv_flow_item.select_list_from_query (
                       p_idx          => 25,
                       p_value        => NULL,
                       p_query        => l_lookup_sql,
                       p_show_null    => 'YES',
                       p_null_value   => '-1',
                       p_null_text    => 'ВСІ',
                       p_show_extra   => 'NO',
                       p_attributes   => 'style="width: 400px"'));
            HTP.p (
                '</tr><tr><td><th align="right" width=70 class="t8ReportHeader">');
            HTP.p (HTF.bold (' Повідомлення '));
            HTP.p ('</td><td>&nbsp');
            HTP.p ('</td><td align="left" width=50>');
            HTP.p (wwv_flow_item.textarea (
                       p_idx          => 26,
                       p_value        => NULL,
                       p_rows         => 3,
                       p_cols         => 6,
                       p_attributes   => 'style="width: 450px"'));
            HTP.p (
                '</tr><tr><td><th align="right" width=70 class="t8ReportHeader">');
            HTP.p (HTF.bold (' Статус '));
            HTP.p ('</td><td>&nbsp');
            HTP.p ('</td><td align="left" width=50>');
            l_lookup_sql :=
                   'SELECT d, r '
                || 'FROM (select '
                || '''Опубліковане'''
                || 'd, '
                || '''A'''
                || ' r '
                || ' from dual '
                || ' union all select '
                || '''Не опубліковане'''
                || 'd, '
                || '''D'''
                || ' r '
                || ' from dual )';
            HTP.p (wwv_flow_item.select_list_from_query (
                       p_idx          => 27,
                       p_value        => NULL,
                       p_query        => l_lookup_sql,
                       p_show_null    => 'NO',
                       p_null_value   => '-1',
                       p_null_text    => 'НЕ ВИЗНАЧЕНО',
                       p_show_extra   => 'NO',
                       p_attributes   => 'style="width: 120px"'));
            HTP.p ('</tr>');
            HTP.p ('</table>');
            --Кнопарики управления
            HTP.p (
                   '&nbsp&nbsp&nbsp&nbsp&nbsp'
                || GetAlternateButton (
                       'Очистити/форма для нового повідомлення',
                       'javascript:SetClear()')
                || '&nbsp'
                || GetAlternateButton ('Зберегти',
                                       'javascript:doSubmit(''SAVEDATA'')'));

            --Объявляю параметры сообщения
            FOR Cur IN c_sql
            LOOP
                HTP.formhidden ('f30');
                HTP.formhidden ('f31');
                HTP.formhidden ('f32');
                HTP.formhidden ('f33');
                HTP.formhidden ('f34');
                HTP.formhidden ('f35');
                HTP.formhidden ('f36');
                HTP.formhidden ('f37');
            --HTP.FORMHIDDEN('f38');
            END LOOP;

            --нулевой индекс - не выводится, по этому просто заполняем его
            HTP.formhidden ('f30');
            HTP.formhidden ('f31');
            HTP.formhidden ('f32');
            HTP.formhidden ('f33');
            HTP.formhidden ('f34');
            HTP.formhidden ('f35');
            HTP.formhidden ('f36');
            HTP.formhidden ('f37');
            HTP.p ('<script language="JavaScript" type="text/javascript">');
            HTP.p ('SetD(0,30,"1");');
            HTP.p ('SetD(0,31,"07.07.2007");');
            HTP.p ('SetD(0,32,"07.07.2007");');
            HTP.p ('SetD(0,33,"-1");');
            HTP.p ('SetD(0,34,"-1");');
            HTP.p ('SetD(0,35,"-1");');
            HTP.p ('SetD(0,36,"aa");');
            HTP.p ('SetD(0,37,"A");');

            --Заполняю массив параметров сообщения
            FOR Cur IN c_sql
            LOOP
                u := cur.ROWNUM;                                          --1;
                HTP.p ('SetD("' || u || '","30","' || cur.wms_id || '");');
                HTP.p (
                       'SetD("'
                    || u
                    || '","31","'
                    || TO_CHAR (cur.wms_begin_dt, 'DD.MM.YYYY')
                    || '");');
                HTP.p (
                       'SetD("'
                    || u
                    || '","32","'
                    || TO_CHAR (cur.wms_end_dt, 'DD.MM.YYYY')
                    || '");');
                HTP.p (
                       'SetD("'
                    || u
                    || '","33","'
                    || NVL (cur.wmp_org, -1)
                    || '");');
                HTP.p (
                       'SetD("'
                    || u
                    || '","34","'
                    || NVL (cur.wmp_wr, -1)
                    || '");');
                HTP.p (
                       'SetD("'
                    || u
                    || '","35","'
                    || NVL (cur.wmp_wut, -1)
                    || '");');
                HTP.p (
                    'SetD("' || u || '","36","' || cur.wms_message || '");');
                HTP.p ('SetD("' || u || '","37","' || cur.wms_st || '");');
            --htp.p('SetD("'||u||'","38","'||cur.wms_create_dt||'");');
            END LOOP;

            HTP.p ('</script>');
            HTP.p ('<br><br>');
        END IF;

        --Список сообщений
        HTP.p (
            '<table width=700 cellpadding="0" border="0" cellspacing="0" summary="" class="t8standard">');
        HTP.p ('<tr><th align="center" width=10% class="t8ReportHeader">');
        HTP.p (HTF.bold ('Дата') || '</th>');
        HTP.p ('<th align="center" width=80% class="t8ReportHeader">');
        HTP.p (HTF.bold ('Текст') || '</th>');

        IF l_Is_Admin = 'T'
        THEN
            HTP.p ('<th align="center" width=10% class="t8ReportHeader">');
            HTP.p (HTF.bold ('') || '</th>');
        END IF;

        HTP.p ('</tr>');

        FOR cur IN c_sql
        -- or wmp_user = v('USER')
        LOOP
            HTP.p ('<tr>');
            HTP.p (
                   '<td align="leftr"  class="t8data">'
                || TO_CHAR (Cur.Wms_Create_Dt, 'DD.MM.YYYY')
                || '</td>');
            HTP.p (
                   '<td align="leftr"  class="t8data">'
                || Cur.Wms_Message
                || '</td>');

            IF cur.st_edt = 'T'
            THEN
                HTP.p (
                       '<td align="leftr"  class="t8data">'
                    || GetAlternateButton (
                           'Редагувати',
                              'javascript:SetPrm('
                           || TO_CHAR (cur.ROWNUM                                 /*-1*/
                                                 )
                           || ')')
                    || '</td>');
                HTP.p ('</tr>');
            END IF;
        END LOOP;

        HTP.p ('</table>');
    END;

    PROCEDURE Insert_W_Message (
        p_wms_id           OUT w_messages.wms_id%TYPE,
        p_wms_wu               w_messages.wms_wu%TYPE,
        p_wms_begin_dt         w_messages.wms_begin_dt%TYPE,
        p_wms_end_dt           w_messages.wms_end_dt%TYPE,
        p_wms_st               w_messages.wms_st%TYPE,
        p_wms_message          w_messages.wms_message%TYPE,
        p_wmp_wr               w_message_params.wmp_wr%TYPE,
        p_wmp_wut              w_message_params.wmp_wut%TYPE,
        p_wmp_org              w_message_params.wmp_org%TYPE,
        p_wmp_user_login       w_message_params.wmp_user_login%TYPE)
    IS
    BEGIN
        --вставка сообщения
        INSERT INTO w_messages (wms_id,
                                wms_wu,
                                wms_create_dt,
                                wms_begin_dt,
                                wms_end_dt,
                                wms_st,
                                wms_message)
             VALUES (0,
                     p_wms_wu,
                     SYSDATE,
                     p_wms_begin_dt,
                     p_wms_end_dt,
                     p_wms_st,
                     p_wms_message)
          RETURNING wms_id
               INTO p_wms_id;

        --вставка параметров сообщения
        INSERT INTO w_message_params (wmp_id,
                                      wmp_wut,
                                      wmp_wr,
                                      wmp_org,
                                      wmp_wms,
                                      wmp_user_login)
             VALUES (0,
                     p_wmp_wut,
                     p_wmp_wr,
                     p_wmp_org,
                     p_wms_id,
                     p_wmp_user_login);
    --returning wmp_id into p_wmp_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'RDM$MESSAGES.Insert_W_Message' || CHR (10) || SQLERRM);
    END;

    PROCEDURE SaveMessage
    IS
        l_wms_id   w_messages.wms_id%TYPE;
        l_wu_id    w_users.wu_id%TYPE;
    BEGIN
        IF INSTR (HTMLDB_APPLICATION.g_f26 (1), '"') > 0
        THEN
            RAISE BadSimbol;
        END IF;

        l_wms_id := HTMLDB_APPLICATION.g_f20 (1);

        SELECT wu_id
          INTO l_wu_id                              --Получаем ИД пользователя
          FROM w_users
         WHERE wu_login = UPPER (v ('USER'));

        IF NVL (l_wms_id, -1) = -1
        THEN                                                  --если вставляем
            Insert_W_Message (
                p_wms_id           => l_wms_id,
                p_wms_wu           => l_wu_id,
                p_wms_begin_dt     =>
                    TO_DATE (HTMLDB_APPLICATION.g_f21 (1), 'DD.MM.YYYY'),
                p_wms_end_dt       =>
                    TO_DATE (HTMLDB_APPLICATION.g_f22 (1), 'DD.MM.YYYY'),
                p_wms_st           => HTMLDB_APPLICATION.g_f27 (1),
                p_wms_message      => HTMLDB_APPLICATION.g_f26 (1),
                p_wmp_wr           => HTMLDB_APPLICATION.g_f24 (1),
                p_wmp_wut          => HTMLDB_APPLICATION.g_f25 (1),
                p_wmp_org          => HTMLDB_APPLICATION.g_f23 (1),
                p_wmp_user_login   => NULL);
        ELSE                                                   --если апдейтим
            UPDATE w_messages w
               SET w.wms_begin_dt =
                       TO_DATE (HTMLDB_APPLICATION.g_f21 (1), 'DD.MM.YYYY'),
                   w.wms_end_dt =
                       TO_DATE (HTMLDB_APPLICATION.g_f22 (1), 'DD.MM.YYYY'),
                   w.wms_st = HTMLDB_APPLICATION.g_f27 (1),
                   --w.wms_wu = v('USER')
                   wms_message = HTMLDB_APPLICATION.g_f26 (1)
             WHERE wms_id = l_wms_id;

            UPDATE w_message_params p
               SET p.wmp_wut = HTMLDB_APPLICATION.g_f25 (1),
                   p.wmp_wr = HTMLDB_APPLICATION.g_f24 (1),
                   p.wmp_org = HTMLDB_APPLICATION.g_f23 (1)
             --p.wmp_user_login = htmldb_application.g_f2..(1),
             WHERE wmp_wms = l_wms_id;
        END IF;
    EXCEPTION
        WHEN BadSimbol
        THEN
            raise_application_error (
                -20000,
                   'Неприпустимий символ в тексті повідомленя '
                || CHR (10)
                || SQLERRM);
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'RDM$MESSAGES.SaveMessge' || CHR (10) || SQLERRM);
    END;
END RDM$MESSAGES;
/