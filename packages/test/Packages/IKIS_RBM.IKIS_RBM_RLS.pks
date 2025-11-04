/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.IKIS_RBM_RLS
IS
    FUNCTION select_opfu_rbm (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION select_es_rbm (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;
END IKIS_RBM_RLS;
/


/* Formatted on 8/12/2025 6:10:50 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.IKIS_RBM_RLS
IS
    -- old
    FUNCTION GetOPFULst (p_opfu NUMBER)
        RETURN VARCHAR2
    IS
        l_opfulst   VARCHAR2 (1000);
    BEGIN
        FOR i IN (SELECT org_id
                    FROM ikis_sys.v_opfu
                   WHERE org_org = p_opfu)
        LOOP
            l_opfulst := l_opfulst || ',' || i.org_id;
        END LOOP;

        RETURN LTRIM (l_opfulst, ',');
    END;

    -- new
    FUNCTION GetORGLst (p_org NUMBER)
        RETURN VARCHAR2
    IS
        l_orglst   VARCHAR2 (1000);
    BEGIN
        FOR i IN (SELECT org_id
                    FROM v_opfu
                   WHERE org_org = p_org)
        LOOP
            l_orglst := l_orglst || ',' || i.org_id;
        END LOOP;

        RETURN NVL (LTRIM (l_orglst, ','), -1);
    END;

    FUNCTION select_opfu_rbm (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        l_org         NUMBER;
        l_user_type   NUMBER;
        l_pred        VARCHAR2 (4000);
    BEGIN
        IF SYS_CONTEXT ('USERENV', 'SESSION_USER') IN
               ('IKIS_SYSWEB', 'IKIS_RBM')
        /* or -- для тестування. тимчасово на розробці
        upper(sys_context('USERENV', 'DB_NAME')) = 'SONYA12PDB' */
        THEN
            RETURN NULL;
        END IF;

        l_user_type :=
            SYS_CONTEXT (ikis_rbm_context.gContext, ikis_rbm_context.gUserTP);
        l_org :=
            SYS_CONTEXT (ikis_rbm_context.gContext, ikis_rbm_context.gOPFU);

        IF l_org IS NULL
        THEN
            l_pred := '1 = 2';
        ELSE
            IF l_user_type IN ('31', '41')
            THEN
                l_pred := '1 = 1';
            ELSIF l_user_type IN ('33', '35', '37')
            THEN
                --        l_pred := '('||l_pred||' OR com_org IN ('||l_org||','||GetORGLst(l_org)||'))';
                l_pred :=
                    CASE
                        WHEN UPPER (p_object) = 'V_PACKET'
                        THEN
                            'pkt_org IN (SELECT u_org FROM tmp_org)'
                        WHEN UPPER (p_object) != 'V_PACKET'
                        THEN
                            'org_id IN (SELECT u_org FROM tmp_org)'
                        WHEN USER = 'IKIS_RBM'
                        THEN
                            '1 = 1'
                        WHEN l_user_type IN (33)
                        THEN
                            '1 = 1'
                        ELSE
                            '1=2'
                    END;
            ELSE
                l_pred := '1 = 2';
            END IF;
        END IF;

        RETURN l_pred;
    /*  l_usrtp:=sys_context(ikis_rbm_context.gContext,ikis_rbm_context.gUserTP);
      l_opfu:=sys_context(ikis_rbm_context.gContext,ikis_rbm_context.gOPFU);
      --raise_application_error(-20000,p_schema||'#'||p_object||'#'||l_usrtp||'#'||l_opfu);
      case
        --when upper(p_object) = 'V_PACKET' and l_usrtp in (5, 6) then return 'pkt_org in ('|| rtrim(l_opfu || ',' || GetOPFULst(l_opfu), ',')||')';
        when upper(p_object) != 'V_PACKET' and  l_usrtp in (5, 6) then return 'org_id in ('|| rtrim(l_opfu || ',' || GetOPFULst(l_opfu), ',')||')'; --'org_id='||l_opfu;--'pkt_org='||l_opfu;--
        WHEN USER = 'IKIS_RBM' THEN RETURN '1 = 1';
        WHEN l_usrtp in (4) THEN RETURN '1 = 1';
      else
        return '1=2';
      end case;*/
    END;

    FUNCTION select_es_rbm (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        l_uid      NUMBER;
        l_usrtp    NUMBER;
        l_is_adm   VARCHAR2 (10) := ikis_const.V_DDN_BOOLEAN_F;
        l_is_usr   VARCHAR2 (10) := ikis_const.V_DDN_BOOLEAN_F;
    BEGIN
        l_is_usr :=
            SYS_CONTEXT (ikis_rbm_context.gContext,
                         ikis_rbm_context.gRbmUser);
        l_is_adm :=
            SYS_CONTEXT (ikis_rbm_context.gContext,
                         ikis_rbm_context.gRbmAdmin);
        l_usrtp :=
            SYS_CONTEXT (ikis_rbm_context.gContext, ikis_rbm_context.gUserTP);
        l_uid :=
            SYS_CONTEXT (ikis_rbm_context.gContext, ikis_rbm_context.gUID);
        /*
        31  UMC Користувач ЦА Мінсоцполітики
        33  UMR Користувач департаменту соц.захисту обласний
        35  UMD Користувач районного управління соц.захисту
        37  UMV Користувач обласного центру нарахувань та виплат
      */
        /*  case
            when l_is_adm = ikis_const.V_DDN_BOOLEAN_T and l_usrtp in (31, 33, 35, 37) then return '1=1';
            --when l_is_adm = ikis_const.V_DDN_BOOLEAN_T and l_usrtp in (4) then return '1=1';
            when l_is_usr = ikis_const.V_DDN_BOOLEAN_T and l_usrtp in (31, 33, 35, 37) then
                 return '1=1';
               --return 'es_id in (select su_es from v_subsystem2user where su_wu='||l_uid||')';
            --when l_is_usr = ikis_const.V_DDN_BOOLEAN_T and l_usrtp in (4) then return 'es_id in (select su_es from v_subsystem2user where su_wu='||l_uid||')';
          else
            return '1=2';
          end case;*/
        RETURN '1=1';
    END;
END IKIS_RBM_RLS;
/