/* Formatted on 8/12/2025 6:11:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.IKIS_WEB_ADM_RLS
IS
    -- Author  : YURA_A
    -- Created : 18.04.2006 12:20:33
    -- Purpose : RLS function

    FUNCTION GetOPFULst (p_opfu NUMBER)
        RETURN VARCHAR2;

    FUNCTION select_users (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION select_users_all (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION update_users (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION select_users_hst (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION select_user_type (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION select_opfu (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION select_users_4gic (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION select_v_w_jobs_univ (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION select_users_que_an (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION select_users_4spovrz (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION select_users_4rbm (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION select_users_hierarchy (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION select_users_4ppvp (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION select_users_4support (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION select_users_4admreport (p_schema   IN VARCHAR2,
                                      p_object      VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION select_user_roles_list (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION select_users_4spov (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION select_ikis_changes (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    -- +Sbond 20151006 добавил функцию для ikis_websm
    FUNCTION select_users_4websm (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    -- +Sbond 20171212 добавил функцию для ikis_person
    FUNCTION select_users_4person (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    -- +Sbond 20171212 добавил функцию для ikis_ok
    FUNCTION select_users_4ok (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    --+ Vano 201512181207 Для сертифікатів користувача
    FUNCTION select_user_cert (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    --20190625 карточний админ
    FUNCTION select_users4secadm (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    -- 20190626 ivashchuk додав функцію для IKIS_DOCFLOW
    FUNCTION select_users_4docflow (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    -- +Sbond 20200612 добавил функцию для ikis_empbook (но ведут из зверення)
    FUNCTION select_users_4empbook (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;
END IKIS_WEB_ADM_RLS;
/


/* Formatted on 8/12/2025 6:11:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.IKIS_WEB_ADM_RLS
IS
    FUNCTION GetOPFULst (p_opfu NUMBER)
        RETURN VARCHAR2
    IS
        l_opfulst   VARCHAR2 (4000) := NULL;
    BEGIN
        FOR i IN (SELECT org_id
                    FROM v_opfu
                   WHERE org_org = p_opfu)
        LOOP
            l_opfulst := l_opfulst || ',' || i.org_id;
        END LOOP;

        IF l_opfulst IS NOT NULL
        THEN
            RETURN LTRIM (l_opfulst, ',');
        ELSE
            RETURN '-1';
        END IF;
    END;

    FUNCTION select_users (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        l_usrtp      w_users.wu_wut%TYPE;
        l_opfu       w_users.wu_org%TYPE;
        l_predicat   VARCHAR2 (4000);
    BEGIN
        l_usrtp := SYS_CONTEXT ('IKISWEBADM', 'IUTP');
        l_opfu := SYS_CONTEXT ('IKISWEBADM', 'OPFU');
        --ikis_debug_pipe.WriteMsg('wu_wut in (SELECT wh_wut FROM w_wut_hierarchy WHERE wh_wut_creator = '||NVL(l_usrtp, -1)||') and wu_org in ('||GetOPFULst(l_opfu)||','||NVL(l_opfu, -1)||')');
        --RETURN 'wu_wut in (SELECT wh_wut FROM w_wut_hierarchy WHERE wh_wut_creator = '||NVL(l_usrtp, -1)||') and wu_org in ('||GetOPFULst(l_opfu)||','||NVL(l_opfu, -1)||')';

        l_predicat :=
               'wu_wut in (SELECT wh_wut FROM w_wut_hierarchy WHERE wh_wut_creator = '
            || NVL (l_usrtp, -1)
            || ') and wu_org
                IN (SELECT tt.org_id
                          FROM ikis_sys.v_opfu tt
                          WHERE org_st = ''A''
                          CONNECT BY NOCYCLE PRIOR tt.org_id = tt.org_org
                          START WITH tt.org_id = '
            || l_opfu;

        IF l_usrtp = 40
        THEN
            l_predicat :=
                   l_predicat
                || ' UNION ALL SELECT org_id FROM ikis_sys.v_opfu WHERE org_st = ''A'' AND org_to = 31';
        END IF;

        l_predicat := l_predicat || ')';

        RETURN l_predicat;
    /*case
      when l_usrtp=1 then return 'wu_wut in (2,4) and wu_org in ('||GetOPFULst(l_opfu)||','||l_opfu||')';
      when l_usrtp=2 then return 'wu_wut in (3,5) and wu_org in ('||GetOPFULst(l_opfu)||','||l_opfu||')';
      when l_usrtp=3 then return 'wu_wut=6 and wu_org='||l_opfu;
    else
      return '1=2';
    end case;    */
    END;

    --20160512
    FUNCTION select_users_all (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        l_usrtp   w_users.wu_wut%TYPE;
        l_opfu    w_users.wu_org%TYPE;
    BEGIN
        l_usrtp := SYS_CONTEXT ('IKISWEBADM', 'IUTP');
        l_opfu := SYS_CONTEXT ('IKISWEBADM', 'OPFU');
        --ikis_debug_pipe.WriteMsg('wu_wut in (SELECT wh_wut FROM w_wut_hierarchy WHERE wh_wut_creator = '||NVL(l_usrtp, -1)||') and wu_org in ('||GetOPFULst(l_opfu)||','||NVL(l_opfu, -1)||')');
        RETURN    'wu_wut in (SELECT wh_wut FROM w_wut_hierarchy WHERE wh_wut_creator = '
               || NVL (l_usrtp, -1)
               || ') and wu_org in ('
               || GetOPFULst (l_opfu)
               || ','
               || NVL (l_opfu, -1)
               || ')';
    /*  case
      when l_usrtp=1 then return 'wu_wut != 1 ';
      when l_usrtp=2 then return 'wu_wut in (3,5,6) and wu_org in ('||GetOPFULst(l_opfu)||','||l_opfu||')';
      when l_usrtp=3 then return 'wu_wut=6 and wu_org='||l_opfu;
    else
      return '1=2';
    end case;    */
    END;

    FUNCTION select_users_4admreport (p_schema   IN VARCHAR2,
                                      p_object      VARCHAR2)
        RETURN VARCHAR2
    IS
    --l_usrtp w_users.wu_wut%type;
    --l_opfu  w_users.wu_org%type;
    BEGIN
        --l_usrtp:=sys_context('IKISWEBADM','IUTP');
        --l_opfu:=sys_context('IKISWEBADM','OPFU');
        RETURN    'wu_wut in (SELECT wh_wut FROM w_wut_hierarchy connect by nocycle prior wh_wut = wh_wut_creator start with wh_wut = to_number(nvl(sys_context(''IKISWEBADM'',''IUTP''), -1))) '
               || 'and wu_org in (select orgp.org_id from ikis_sys.v_opfu orgp connect by nocycle prior orgp.org_id = orgp.org_org start with orgp.org_id = to_number(nvl(sys_context(''IKISWEBADM'',''OPFU''), -1))) ';
    END;


    FUNCTION select_users_que_an (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        l_usrtp      w_users.wu_wut%TYPE;
        l_opfu       w_users.wu_org%TYPE;

        l_app_pred   VARCHAR2 (1000)
            := 'wu_id in (select y.wu_id from w_roles x,w_usr2roles y
              where x.wr_id=y.wr_id
                and x.wr_ss_code=sys_context(''IKISWEBADM'',''APPNAME''))';
    BEGIN
        l_usrtp := SYS_CONTEXT ('IKISWEBADM', 'IUTP');
        l_opfu := SYS_CONTEXT ('IKISWEBADM', 'OPFU');

        CASE
            WHEN l_usrtp = 4
            THEN
                RETURN l_app_pred || ' and wu_wut in (4,5,6)';
            WHEN l_usrtp = 5
            THEN
                RETURN    l_app_pred
                       || ' and wu_wut in (5,6) and wu_org in ('
                       || GetOPFULst (l_opfu)
                       || ','
                       || l_opfu
                       || ')';
            WHEN l_usrtp = 6
            THEN
                RETURN l_app_pred || ' and wu_wut=6 and wu_org=' || l_opfu;
            ELSE
                RETURN '1=2';
        END CASE;
    END;


    -- +Frolov 20100215 добавил функцию для СПОВ МЗ
    FUNCTION select_users_4spov (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        l_usrtp   w_users.wu_wut%TYPE;
        l_opfu    w_users.wu_org%TYPE;
    BEGIN
        l_usrtp := SYS_CONTEXT ('IKISWEBADM', 'IUTP');
        l_opfu := SYS_CONTEXT ('IKISWEBADM', 'OPFU');

        CASE
            WHEN l_usrtp = 6
            THEN
                RETURN ' wu_wut=6 and wu_org=' || l_opfu;
            ELSE
                RETURN '1=2';
        END CASE;
    END;

    -- +Sbond 20130403 добавил функцию для Веб Спов Р
    FUNCTION select_users_4spovrz (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        l_usrtp      w_users.wu_wut%TYPE;
        l_opfu       w_users.wu_org%TYPE;
        l_app_name   VARCHAR2 (10);
    BEGIN
        l_app_name := SYS_CONTEXT ('IKISWEBADM', 'APPNAME');
        l_usrtp := SYS_CONTEXT ('IKISWEBADM', 'IUTP');
        l_opfu := SYS_CONTEXT ('IKISWEBADM', 'OPFU');

        CASE
            WHEN l_app_name = 'IKIS_SPOVRZ' AND l_usrtp = 4
            THEN
                RETURN ' wu_wut in (4, 5, 6) ';
            WHEN l_app_name = 'IKIS_SPOVRZ' AND l_usrtp = 5
            THEN
                RETURN    ' wu_wut in (5,6) and wu_org in ('
                       || GetOPFULst (l_opfu)
                       || ','
                       || l_opfu
                       || ')';
            WHEN l_app_name = 'IKIS_SPOVRZ' AND l_usrtp = 6
            THEN
                RETURN ' wu_wut =6 and wu_org=' || l_opfu;
            ELSE
                RETURN '1=2';
        END CASE;
    END;

    -- +Sbond 20150702 добавил функцию для ikis_rbm
    FUNCTION select_users_4rbm (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        l_usrtp      w_users.wu_wut%TYPE;
        l_opfu       w_users.wu_org%TYPE;
        l_app_name   VARCHAR2 (10);
    BEGIN
        l_app_name := SYS_CONTEXT ('IKISRBM', 'APPNAME');
        l_usrtp := SYS_CONTEXT ('IKISRBM', 'IUTP');
        l_opfu := SYS_CONTEXT ('IKISRBM', 'OPFU');

        --ikis_debug_pipe.WriteMsg('wu_wut in (SELECT wh_wut FROM w_wut_hierarchy WHERE wh_wut_creator = '||NVL(l_usrtp, -1)||') and wu_org in ('||GetOPFULst(l_opfu)||','||NVL(l_opfu, -1)||')');
        --RETURN 'wu_wut in (SELECT wh_wut FROM w_wut_hierarchy WHERE wh_wut_creator = '||NVL(l_usrtp, -1)||') and wu_org in ('||GetOPFULst(l_opfu)||','||NVL(l_opfu, -1)||')';
        RETURN 'wu_org IN (SELECT tt.org_id
            FROM ikis_sys.v_opfu tt
            WHERE org_st = ''A''
            CONNECT BY NOCYCLE PRIOR tt.org_id = tt.org_org
            START WITH tt.org_id = ' || l_opfu || ')';
    /*  case
        --when 1=1 then return '1=1';
        when l_app_name = 'IKIS_RBM' and l_usrtp=4 then return ' wu_wut in (4, 5, 6) ';
        when l_app_name = 'IKIS_RBM' and l_usrtp=5 then return ' wu_wut in (5,6) and wu_org in ('||GetOPFULst(l_opfu)||','||l_opfu||') ';
        when l_app_name = 'IKIS_RBM' and l_usrtp=6 then return ' wu_wut =6 and wu_org='|| l_opfu ;
      else
        return '1=2';
      end case;*/
    END;

    -- +Sbond 20151006 добавил функцию для ikis_websm
    FUNCTION select_users_4websm (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        l_usrtp      w_users.wu_wut%TYPE;
        l_opfu       w_users.wu_org%TYPE;
        l_app_name   VARCHAR2 (10);
    BEGIN
        l_app_name := SYS_CONTEXT ('IKISWEBADM', 'APPNAME');
        l_usrtp := SYS_CONTEXT ('IKISWEBADM', 'IUTP');
        l_opfu := SYS_CONTEXT ('IKISWEBADM', 'OPFU');

        CASE
            --when 1=1 then return '1=1';
            WHEN l_app_name = 'IKIS_WEBSM'
            THEN
                RETURN NULL;                         --все видят пользователей
            --and l_usrtp=4 then return ' and wu_wut in (4, 5, 6) ';
            --when l_app_name = 'IKIS_WEBSM' and l_usrtp=5 then return ' and wu_wut in (5,6) and wu_org in ('||GetOPFULst(l_opfu)||','||l_opfu||') ';
            --when l_app_name = 'IKIS_WEBSM' and l_usrtp=6 then return ' wu_wut =6 and wu_org='|| l_opfu ;
            ELSE
                RETURN '1=2';
        END CASE;
    END;


    -- -Frolov 20100215

    FUNCTION select_users_4gic (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        l_usrtp   w_users.wu_wut%TYPE;
    --  l_opfu  w_users.wu_org%type;
    BEGIN
        l_usrtp := SYS_CONTEXT ('IKISWEBADM', 'IUTP');

        --  l_opfu:=sys_context('IKISWEBADM','OPFU');
        CASE
            WHEN l_usrtp IN (4, 5)
            THEN
                RETURN NULL;
            ELSE
                RETURN '1=2';
        END CASE;
    END;


    FUNCTION select_users_hierarchy (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        l_usrtp   w_users.wu_wut%TYPE;
        l_opfu    w_users.wu_org%TYPE;
    BEGIN
        l_usrtp := SYS_CONTEXT ('IKISWEBADM', 'IUTP');
        l_opfu := SYS_CONTEXT ('IKISWEBADM', 'OPFU');

        CASE
            WHEN l_usrtp = 4
            THEN
                RETURN NULL;
            WHEN l_usrtp = 5
            THEN
                RETURN    'wu_org in ('
                       || GetOPFULst (l_opfu)
                       || ','
                       || l_opfu
                       || ')';
            WHEN l_usrtp = 6
            THEN
                RETURN 'wu_org=sys_context(''IKISWEBADM'',''OPFU'')';
            ELSE
                RETURN '1=2';
        END CASE;
    END;

    -- +Sbond 20160527 пользователи ппвп
    FUNCTION select_users_4ppvp (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        l_usrtp      w_users.wu_wut%TYPE;
        l_opfu       w_users.wu_org%TYPE;
        l_app_name   VARCHAR2 (10);
    BEGIN
        l_app_name := SYS_CONTEXT ('IKISWEBADM', 'APPNAME');
        l_usrtp := SYS_CONTEXT ('IKISWEBADM', 'IUTP');
        l_opfu := SYS_CONTEXT ('IKISWEBADM', 'OPFU');

        CASE
            WHEN l_app_name = 'IKIS_PPVP' AND l_usrtp = 4
            THEN
                RETURN ' wu_wut in (4, 5, 6) ';
            WHEN l_app_name = 'IKIS_PPVP' AND l_usrtp = 5
            THEN
                RETURN    ' wu_wut in (5,6) and wu_org in ('
                       || GetOPFULst (l_opfu)
                       || ','
                       || l_opfu
                       || ')';
            WHEN l_app_name = 'IKIS_PPVP' AND l_usrtp = 6
            THEN
                RETURN ' wu_wut =6 and wu_org=' || l_opfu;
            ELSE
                RETURN '1=2';
        END CASE;
    END;

    -- +Sbond 20160530 добавил функцию для ikis_support
    FUNCTION select_users_4support (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        --l_usrtp w_users.wu_wut%type;
        --l_opfu  w_users.wu_org%type;
        l_app_name   VARCHAR2 (12);
    BEGIN
        l_app_name := SYS_CONTEXT ('IKISWEBADM', 'APPNAME');

        --l_usrtp:=sys_context('IKISWEBADM','IUTP');
        --l_opfu:=sys_context('IKISWEBADM','OPFU');
        CASE
            WHEN    l_app_name = 'IKIS_SUPPORT'
                 OR (    USER = 'IKIS_SUPPORT'
                     AND SYS_CONTEXT ('userenv', 'db_name') = 'glasha')
            THEN
                RETURN NULL;                         --все видят пользователей
            ELSE
                RETURN '1=2';
        END CASE;
    END;

    -- +Sbond 20171212 добавил функцию для ikis_person
    FUNCTION select_users_4person (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        --l_usrtp w_users.wu_wut%type;
        --l_opfu  w_users.wu_org%type;
        l_app_name   VARCHAR2 (12);
    BEGIN
        l_app_name := SYS_CONTEXT ('IKISWEBADM', 'APPNAME');

        --l_usrtp:=sys_context('IKISWEBADM','IUTP');
        --l_opfu:=sys_context('IKISWEBADM','OPFU');
        CASE
            WHEN    l_app_name = 'IKIS_PERSON'
                 OR (    USER = 'IKIS_PERSON'
                     AND SYS_CONTEXT ('userenv', 'db_name') = 'glasha')
            THEN
                RETURN NULL;                         --все видят пользователей
            ELSE
                RETURN '1=2';
        END CASE;
    END;

    -- +Sbond 20171212 добавил функцию для ikis_ok
    FUNCTION select_users_4ok (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        --l_usrtp w_users.wu_wut%type;
        --l_opfu  w_users.wu_org%type;
        l_app_name   VARCHAR2 (12);
    BEGIN
        l_app_name := SYS_CONTEXT ('IKISWEBADM', 'APPNAME');

        --l_usrtp:=sys_context('IKISWEBADM','IUTP');
        --l_opfu:=sys_context('IKISWEBADM','OPFU');
        CASE
            WHEN    l_app_name = 'IKIS_OK'
                 OR (    USER = 'IKIS_OK'
                     AND SYS_CONTEXT ('userenv', 'db_name') = 'glasha')
            THEN
                RETURN NULL;                         --все видят пользователей
            ELSE
                RETURN '1=2';
        END CASE;
    END;

    FUNCTION update_users (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        l_usrtp      w_users.wu_wut%TYPE;
        l_opfu       w_users.wu_org%TYPE;
        l_uid        w_users.wu_id%TYPE;
        l_wut_code   w_user_type.wut_code%TYPE;
        l_predicat   VARCHAR2 (4000);
    BEGIN
        l_usrtp := SYS_CONTEXT ('IKISWEBADM', 'IUTP');
        l_opfu := SYS_CONTEXT ('IKISWEBADM', 'OPFU');
        l_uid := SYS_CONTEXT ('IKISWEBADM', 'IKISUID');

        IF ikis_htmldb_auth.is_role_assigned (p_username   => V ('USER'),
                                              p_role       => 'W_ADM_CERT')
        THEN
            RETURN    '(wu_wut in (SELECT wh_wut_creator FROM w_wut_hierarchy WHERE wh_wut = '
                   || NVL (l_usrtp, -1)
                   || ') OR wu_wut = '
                   || NVL (l_usrtp, -1)
                   || ') and wu_org in ('
                   || GetOPFULst (l_opfu)
                   || ','
                   || NVL (l_opfu, -1)
                   || ')';
        /*case
          when l_usrtp=4 then return '(wu_id='||l_uid||') or (wu_wut in (2,4) and wu_org in ('||GetOPFULst(l_opfu)||','||l_opfu||'))';
          when l_usrtp=5 then return '(wu_id='||l_uid||') or (wu_wut in (3,5) and wu_org in ('||GetOPFULst(l_opfu)||','||l_opfu||'))';
          when l_usrtp=6 then return '(wu_id='||l_uid||') or (wu_wut=6 and wu_org='||l_opfu||')';
        else
          return '1=2';
        end case; */
        ELSE
            SELECT wut_code
              INTO l_wut_code
              FROM w_user_type
             WHERE wut_id = l_usrtp;

            IF SUBSTR (l_wut_code, 1, 1) = 'U'
            THEN
                RETURN 'wu_id=' || l_uid;
            ELSIF SUBSTR (l_wut_code, 1, 1) = 'A'
            THEN
                --      l_predicat := '(wu_id = '||l_uid||') OR (wu_wut IN (SELECT wh_wut FROM w_wut_hierarchy WHERE wh_wut_creator = '||NVL(l_usrtp, -1)||') AND wu_org IN ('||GetOPFULst(l_opfu)||','||l_opfu||'))';
                l_predicat :=
                       'wu_wut in (SELECT wh_wut FROM w_wut_hierarchy WHERE wh_wut_creator = '
                    || NVL (l_usrtp, -1)
                    || ') and wu_org IN (SELECT tt.org_id
                        FROM ikis_sys.v_opfu tt
                        WHERE org_st = ''A''
                        CONNECT BY NOCYCLE PRIOR tt.org_id = tt.org_org
                        START WITH tt.org_id = '
                    || l_opfu;

                IF l_usrtp = 40
                THEN
                    l_predicat :=
                           l_predicat
                        || ' UNION ALL SELECT org_id FROM ikis_sys.v_opfu WHERE org_st = ''A'' AND org_to = 31';
                END IF;

                l_predicat := l_predicat || ' )';
                --ikis_debug_pipe.WriteMsg(l_predicat);
                RETURN l_predicat;
            ELSE
                RETURN '1=2';
            END IF;
        /*case
          when l_usrtp=1 then return '(wu_id='||l_uid||') or (wu_wut in (2,4) and wu_org in ('||GetOPFULst(l_opfu)||','||l_opfu||'))';
          when l_usrtp=2 then return '(wu_id='||l_uid||') or (wu_wut in (3,5) and wu_org in ('||GetOPFULst(l_opfu)||','||l_opfu||'))';
          when l_usrtp=3 then return '(wu_id='||l_uid||') or (wu_wut=6 and wu_org='||l_opfu||')';
          when l_usrtp=4 then return 'wu_id='||l_uid;
          when l_usrtp=5 then return 'wu_id='||l_uid;
          when l_usrtp=6 then return 'wu_id='||l_uid;
        else
          return '1=2';
        end case; */
        END IF;

        RETURN '1=2';
    END;

    FUNCTION select_user_type (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
    --  l_usrtp w_users.wu_wut%type;
    BEGIN
        --  l_usrtp:=sys_context('IKISWEBADM','IUTP');
        RETURN    'wut_id IN (SELECT wh_wut FROM w_wut_hierarchy WHERE wh_wut_creator = '
               || SYS_CONTEXT ('IKISWEBADM', 'IUTP')
               || ')';
    /* --vano-20210623
    case
      when l_usrtp=1 then return 'wut_id in (2,4)';
      when l_usrtp=2 then return 'wut_id in (3,5)';
      when l_usrtp=3 then return 'wut_id=6';
    else
      return '1=2';
    end case;
    */
    END;

    FUNCTION select_opfu (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        l_usrtp      w_users.wu_wut%TYPE;
        l_opfu       w_users.wu_org%TYPE;
        l_predicat   VARCHAR2 (4000);
    BEGIN
        l_usrtp := SYS_CONTEXT ('IKISWEBADM', 'IUTP');
        l_opfu := SYS_CONTEXT ('IKISWEBADM', 'OPFU');

        l_predicat := 'org_id IN (SELECT tt.org_id
            FROM ikis_sys.v_opfu tt
            WHERE tt.org_st = ''A''
            CONNECT BY NOCYCLE PRIOR tt.org_id = tt.org_org
            START WITH tt.org_id = ' || l_opfu;

        IF l_usrtp = 40
        THEN
            l_predicat :=
                   l_predicat
                || ' UNION ALL SELECT org_id FROM ikis_sys.v_opfu WHERE org_st = ''A'' AND org_to = 31';
        END IF;

        l_predicat := l_predicat || ')';
        --ikis_debug_pipe.WriteMsg(l_predicat);
        RETURN l_predicat;
    END;

    FUNCTION select_users_hst (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        l_usrtp      w_users.wu_wut%TYPE;
        l_opfu       w_users.wu_org%TYPE;
        l_predicat   VARCHAR2 (4000);
    BEGIN
        l_usrtp := SYS_CONTEXT ('IKISWEBADM', 'IUTP');
        l_opfu := SYS_CONTEXT ('IKISWEBADM', 'OPFU');
        l_predicat :=
               'wuh_wut in (SELECT wh_wut FROM w_wut_hierarchy WHERE wh_wut_creator = '
            || NVL (l_usrtp, -1)
            || ') and wuh_org in ('
            || GetOPFULst (l_opfu)
            || ','
            || NVL (l_opfu, -1)
            || ')';
        --ikis_debug_pipe.WriteMsg(l_predicat);
        RETURN l_predicat;
    /* --vano_20210624
    case
      \*
      when l_usrtp=1 then return 'wuh_wut != 1 ';
      when l_usrtp=2 then return 'wuh_wut in (3,5,6) and wuh_org in ('||GetOPFULst(l_opfu)||','||l_opfu||')';
      when l_usrtp=3 then return 'wuh_wut=6 and wuh_org='||l_opfu;
      *\
      --20160512
      when l_usrtp=1 then return 'wuh_wut in (2,4) and wuh_org in ('||GetOPFULst(l_opfu)||','||l_opfu||')';
      when l_usrtp=2 then return 'wuh_wut in (3,5) and wuh_org in ('||GetOPFULst(l_opfu)||','||l_opfu||')';
      when l_usrtp=3 then return 'wuh_wut=6 and wuh_org='||l_opfu;
    else
      return '1=2';
    end case;    */
    END;

    FUNCTION select_user_cert (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        l_usrtp      w_users.wu_wut%TYPE;
        l_opfu       w_users.wu_org%TYPE;
        l_uid        w_users.wu_id%TYPE;
        l_adm_cert   INTEGER := 0;
    BEGIN
        --RETURN '1 = 1 ';
        l_usrtp := SYS_CONTEXT ('IKISWEBADM', 'IUTP');
        l_opfu := SYS_CONTEXT ('IKISWEBADM', 'OPFU');
        l_uid := SYS_CONTEXT ('IKISWEBADM', 'IKISUID');

        IF ikis_htmldb_auth.is_role_assigned (p_username   => V ('USER'),
                                              p_role       => 'W_ADM_CERT')
        THEN
            l_adm_cert := 1;
            --ikis_debug_pipe.WriteMsg('EXISTS (SELECT 1 FROM w_users WHERE wcr_wu = wu_id AND (wu_wut in (SELECT wh_wut_creator FROM w_wut_hierarchy WHERE wh_wut = '||NVL(l_usrtp, -1)||') OR wu_wut = '||NVL(l_usrtp, -1)||') and wu_org in ('||GetOPFULst(l_opfu)||','||NVL(l_opfu, -1)||'))');
            RETURN    'EXISTS (SELECT 1 FROM w_users WHERE wcr_wu = wu_id AND (wu_wut in (SELECT wh_wut_creator FROM w_wut_hierarchy WHERE wh_wut = '
                   || NVL (l_usrtp, -1)
                   || ') OR wu_wut = '
                   || NVL (l_usrtp, -1)
                   || ') and wu_org in ('
                   || GetOPFULst (l_opfu)
                   || ','
                   || NVL (l_opfu, -1)
                   || '))';
        ELSE
            RETURN 'wcr_wu = ' || l_uid;
        END IF;
    /*CASE
      WHEN l_usrtp = 4 and l_adm_cert = 1 THEN RETURN 'EXISTS (SELECT 1 FROM w_users WHERE wcr_wu = wu_id AND ((wu_id = '||l_uid||') OR (wu_wut IN (2, 4) AND wu_org IN ('||GetOPFULst(l_opfu)||', '||l_opfu||'))))';
      WHEN l_usrtp = 5 and l_adm_cert = 1 THEN RETURN 'EXISTS (SELECT 1 FROM w_users WHERE wcr_wu = wu_id AND ((wu_id = '||l_uid||') OR (wu_wut IN (3, 5) AND wu_org IN ('||GetOPFULst(l_opfu)||','||l_opfu||'))))';
      WHEN l_usrtp = 6 and l_adm_cert = 1 THEN RETURN 'EXISTS (SELECT 1 FROM w_users WHERE wcr_wu = wu_id AND ((wu_id = '||l_uid||') OR (wu_wut = 6 AND wu_org = '||l_opfu||')))';
      WHEN l_usrtp IN (1, 2, 3, 4, 5, 6) and l_adm_cert = 0 THEN RETURN 'wcr_wu = '||l_uid;
    ELSE
      RETURN '1 = 2';
    END CASE;    */
    END;


    FUNCTION select_v_w_jobs_univ (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        l_APP   VARCHAR2 (100) := 'NOAPP';
        l_cnt   PLS_INTEGER := 0;
    BEGIN
        l_APP := SYS_CONTEXT ('IKISWEBADM', 'APPNAME');

        --ikis_sysweb.ikis_debug_pipe.WriteMsg(l_APP);
        SELECT COUNT (1)
          INTO l_cnt
          FROM job_subsys_list jsl
         WHERE jsl.jsl_subsys = l_APP AND jsl.jsl_st = 'A';

        --ikis_sysweb.ikis_debug_pipe.WriteMsg(l_cnt);

        CASE
            WHEN l_cnt > 0
            THEN
                RETURN 'jb_ss_code=sys_context(''IKISWEBADM'',''APPNAME'')';
            ELSE
                RETURN '1=2';
        END CASE;
    END;

    FUNCTION select_ikis_changes (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        l_usrtp   w_users.wu_wut%TYPE;
        l_uid     w_users.wu_id%TYPE;
        l_cnt     INTEGER;
    BEGIN
        l_uid := SYS_CONTEXT ('IKISWEBADM', 'IKISUID');
        l_usrtp := SYS_CONTEXT ('IKISWEBADM', 'IUTP');

        --Выдана ли юзеру роль для просмотра аудита
        SELECT COUNT (1)
          INTO l_cnt
          FROM w_usr2roles
         WHERE wr_id = 1020;

        --Разрешаем просмотр только для администраторов доступа центра, а также пользователям IKIS_SYS и SYSTEM (на проме первый - заблокирован).
        CASE
            WHEN l_usrtp = 1 OR l_cnt > 0 OR USER IN ('IKIS_SYS', 'SYSTEM')
            THEN
                RETURN NULL;
            ELSE
                RETURN '1=2';
        END CASE;
    END;

    --20180907 добавил для рзо текущие роли
    FUNCTION select_user_roles_list (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'WU_ID = sys_context(''IKISWEBADM'',''IKISUID'') and WR_SS_CODE = sys_context(''IKISWEBADM'',''APPNAME'') ';
    END;

    --20190625 карточний админ
    FUNCTION select_users4secadm (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        l_usrtp   w_users.wu_wut%TYPE;
        l_opfu    w_users.wu_org%TYPE;
    BEGIN
        IF ikis_htmldb_auth.is_role_assigned (p_username   => V ('USER'),
                                              p_role       => 'W_ADM_CERT')
        THEN
            l_usrtp := SYS_CONTEXT ('IKISWEBADM', 'IUTP');
            l_opfu := SYS_CONTEXT ('IKISWEBADM', 'OPFU');
            --ikis_debug_pipe.WriteMsg('(wu_wut in (SELECT wh_wut_creator FROM w_wut_hierarchy WHERE wh_wut = '||NVL(l_usrtp, -1)||') OR wu_wut = '||NVL(l_usrtp, -1)||') and wu_org in ('||GetOPFULst(l_opfu)||','||NVL(l_opfu, -1)||')');
            RETURN    '(wu_wut in (SELECT wh_wut_creator FROM w_wut_hierarchy WHERE wh_wut = '
                   || NVL (l_usrtp, -1)
                   || ') OR wu_wut = '
                   || NVL (l_usrtp, -1)
                   || ') and wu_org in ('
                   || GetOPFULst (l_opfu)
                   || ','
                   || NVL (l_opfu, -1)
                   || ')';
        /*case
          when l_usrtp=4 then return 'wu_wut in (2,4) and wu_org in ('||GetOPFULst(l_opfu)||','||l_opfu||')';
          when l_usrtp=5 then return 'wu_wut in (3,5) and wu_org in ('||GetOPFULst(l_opfu)||','||l_opfu||')';
          when l_usrtp=6 then return 'wu_wut=6 and wu_org='||l_opfu;
        else
          return '1=2';
        end case;  */
        END IF;

        RETURN '1=2';
    END;

    -- 20190626 ivashchuk додав функцію для IKIS_DOCFLOW
    FUNCTION select_users_4docflow (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        --l_usrtp w_users.wu_wut%type;
        --l_opfu  w_users.wu_org%type;
        l_app_name   VARCHAR2 (12);
    BEGIN
        l_app_name := SYS_CONTEXT ('IKISWEBADM', 'APPNAME');

        --l_usrtp:=sys_context('IKISWEBADM','IUTP');
        --l_opfu:=sys_context('IKISWEBADM','OPFU');
        CASE
            WHEN    l_app_name = 'IKIS_DOCFLOW'
                 OR (    USER = 'IKIS_DOCFLOW'
                     AND SYS_CONTEXT ('userenv', 'db_name') = 'glasha')
            THEN
                RETURN NULL;                         --все видят пользователей
            ELSE
                RETURN '1=2';
        END CASE;
    END;

    -- +Sbond 20200612 добавил функцию для ikis_empbook (но ведут из зверення)
    FUNCTION select_users_4empbook (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        --l_usrtp w_users.wu_wut%type;
        --l_opfu  w_users.wu_org%type;
        l_app_name   VARCHAR2 (12);
    BEGIN
        l_app_name := SYS_CONTEXT ('IKISWEBADM', 'APPNAME');

        --l_usrtp:=sys_context('IKISWEBADM','IUTP');
        --l_opfu:=sys_context('IKISWEBADM','OPFU');
        CASE
            WHEN    l_app_name IN ('IKIS_QUEUE', 'IKIS_EMPBOOK')
                 OR (    USER = 'IKIS_EMPBOOK'
                     AND SYS_CONTEXT ('userenv', 'db_name') = 'GLASHA12PDB')
            THEN
                RETURN NULL;                         --все видят пользователей
            ELSE
                RETURN '1=2';
        END CASE;
    END;
END IKIS_WEB_ADM_RLS;
/