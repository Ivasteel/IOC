/* Formatted on 8/12/2025 5:59:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.USS_VISIT_RLS
IS
    -- Author  : VANO
    -- Created : 11.02.2021 18:55:16
    -- Purpose : Функції для політик порядкового розподілу доступу


    FUNCTION comm_pred (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION comm_pred_cs (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;
END USS_VISIT_RLS;
/


/* Formatted on 8/12/2025 6:00:03 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.USS_VISIT_RLS
IS
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

    FUNCTION comm_pred (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        l_org         VARCHAR2 (250);
        l_wu          VARCHAR2 (250);
        l_user_type   VARCHAR2 (250);
        l_pred        VARCHAR2 (1000);
    BEGIN
        IF SYS_CONTEXT ('USERENV', 'SESSION_USER') IN
               ('IKIS_SYSWEB', 'USS_VISIT')
        THEN
            RETURN NULL;
        END IF;

        l_org :=
            SYS_CONTEXT (USS_VISIT_CONTEXT.gContext, USS_VISIT_CONTEXT.gORG);
        l_wu :=
            SYS_CONTEXT (USS_VISIT_CONTEXT.gContext, USS_VISIT_CONTEXT.gUID);
        l_user_type :=
            SYS_CONTEXT (USS_VISIT_CONTEXT.gContext,
                         USS_VISIT_CONTEXT.gUserTP);

        --ikis_sysweb.ikis_debug_pipe.WriteMsg('l_wu='||l_wu);
        --ikis_sysweb.ikis_debug_pipe.WriteMsg('l_org='||l_org);
        --ikis_sysweb.ikis_debug_pipe.WriteMsg('l_user_type='||l_user_type);
        IF l_wu IS NULL
        THEN
            RETURN '1=2';
        ELSE
            IF l_user_type IN ('31', '21', '81')
            THEN
                l_pred := '1 = 1';
            ELSIF l_user_type IN ('35')
            THEN
                l_pred :=
                    'com_wu = NVL(sys_context(''USS_VISIT'', ''USSUID''), -1)';
                l_pred :=
                       '('
                    || l_pred
                    || ' OR com_org IN (SELECT u_org FROM tmp_org) or ap_dest_org in (sys_context(''USS_VISIT'', ''ORG'')))';
            ELSE
                l_pred :=
                    'com_wu = NVL(sys_context(''USS_VISIT'', ''USSUID''), -1)'; --'||l_wu;

                IF l_user_type IN ('33',                             /*'35',*/
                                   '37',
                                   '39',
                                   '41',
                                   '23',
                                   '44',
                                   '83')
                THEN
                    --        l_pred := '('||l_pred||' OR com_org IN ('||l_org||','||GetORGLst(l_org)||'))';
                    l_pred :=
                           '('
                        || l_pred
                        || ' OR com_org IN (SELECT u_org FROM tmp_org))';
                END IF;
            END IF;

            --ikis_sysweb.ikis_debug_pipe.WriteMsg(l_pred);
            RETURN l_pred;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            --ikis_sysweb.ikis_debug_pipe.WriteMsg(sqlerrm);
            RETURN '1=2';
    END;

    FUNCTION comm_pred_cs (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        l_org     VARCHAR2 (250);
        l_usrtp   NUMBER;
    BEGIN
        --ikis_sysweb.ikis_debug_pipe.WriteMsg('p_schema='||p_schema);
        --ikis_sysweb.ikis_debug_pipe.WriteMsg('p_object='||p_object);
        IF SYS_CONTEXT ('USERENV', 'SESSION_USER') IN
               ('USS_VISIT', 'IKIS_SYSWEB')
        THEN
            RETURN NULL;
        END IF;

        l_org :=
            SYS_CONTEXT (USS_VISIT_CONTEXT.gContext, USS_VISIT_CONTEXT.gORG);

        IF l_org IS NULL
        THEN
            RETURN '1=2';
        ELSE
            l_usrtp :=
                SYS_CONTEXT (USS_VISIT_CONTEXT.gContext,
                             USS_VISIT_CONTEXT.gUserTP);

            CASE
                WHEN l_usrtp = 4
                THEN
                    RETURN NULL;
                WHEN l_usrtp = 5
                THEN
                    RETURN    'com_org IN ('
                           || l_org
                           || ','
                           || GetORGLst (l_org)
                           || ')';
                WHEN l_usrtp = 6
                THEN
                    RETURN 'com_org = ' || l_org;
                ELSE
                    RETURN '1 = 2';
            END CASE;
        END IF;
    END;

    FUNCTION Portal_Pred (p_Schema IN VARCHAR2, p_Object VARCHAR2)
        RETURN VARCHAR2
    IS
        l_Edrpou   VARCHAR2 (8);
        l_Ipn      VARCHAR2 (10);
        l_Pasp     VARCHAR2 (10);
        l_Param    VARCHAR2 (100);
        l_Nda_Id   NUMBER;
    BEGIN
        IF SYS_CONTEXT (Uss_Visit_Context.Gcontext, 'CABINET') = 'NSP'
        THEN
            l_Edrpou := SYS_CONTEXT (Uss_Visit_Context.Gcontext, 'EDRPOU');
            l_Ipn := SYS_CONTEXT (Uss_Visit_Context.Gcontext, 'IPN');
            l_Pasp := SYS_CONTEXT (Uss_Visit_Context.Gcontext, 'PASP');

            IF COALESCE (l_Edrpou, l_Ipn, l_Pasp) IS NULL
            THEN
                RETURN '1=2';
            END IF;

            l_Nda_Id :=
                CASE
                    WHEN l_Edrpou IS NOT NULL THEN 955
                    WHEN l_Ipn IS NOT NULL THEN 961
                    WHEN l_Pasp IS NOT NULL THEN 962
                END;

            l_Param := COALESCE (l_Edrpou, l_Ipn, l_Pasp);

            DELETE FROM Tmp_Work_Ids;

            INSERT INTO Tmp_Work_Ids (x_Id)
                SELECT a.Ap_Id
                  FROM Appeal  a
                       JOIN Ap_Document_Attr t ON a.Ap_Id = t.Apda_Ap
                 WHERE     a.Ap_Tp = 'G'
                       AND t.Apda_Nda = 955
                       AND t.Apda_Val_String = l_Param
                       AND t.History_Status = 'A';

            RETURN 'AP_ID IN(SELECT x_Id FROM TMP_WORK_IDS)';
        END IF;

        RETURN '1=2';
    END;
END USS_VISIT_RLS;
/