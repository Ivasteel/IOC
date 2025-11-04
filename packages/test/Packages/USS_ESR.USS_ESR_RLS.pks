/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.USS_ESR_RLS
IS
    -- Author  : VANO
    -- Created : 04.06.2021 11:29:38
    -- Purpose : Функції для політик порядкового розподілу доступу

    FUNCTION comm_pred (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION comm_pred_cs (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION comm_pred_pc (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;
END USS_ESR_RLS;
/


/* Formatted on 8/12/2025 5:50:05 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.USS_ESR_RLS
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
        l_user_type   VARCHAR2 (250);
        l_pred        VARCHAR2 (1000);
    BEGIN
        IF SYS_CONTEXT ('USERENV', 'SESSION_USER') IN
               ('IKIS_SYSWEB', 'USS_ESR')
        THEN
            RETURN NULL;
        END IF;

        l_org := SYS_CONTEXT (USS_ESR_CONTEXT.gContext, USS_ESR_CONTEXT.gORG);
        l_user_type :=
            SYS_CONTEXT (USS_ESR_CONTEXT.gContext, USS_ESR_CONTEXT.gUserTP);

        IF l_org IS NULL
        THEN
            l_pred := '1 = 2';
        ELSE
            IF l_user_type IN ('31', '21', '81')
            THEN
                l_pred := '1 = 1';
            ELSIF l_user_type IN ('33',
                                  '35',
                                  '37',
                                  '39',
                                  '41',
                                  '23',
                                  '83')
            THEN
                --        l_pred := '('||l_pred||' OR com_org IN ('||l_org||','||GetORGLst(l_org)||'))';
                l_pred := '(com_org IN (SELECT u_org FROM tmp_org))';
            ELSE
                l_pred := '1 = 2';
            END IF;
        END IF;

        RETURN l_pred;
    END;

    FUNCTION comm_pred_cs (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        l_org     VARCHAR2 (250);
        l_usrtp   NUMBER;
    BEGIN
        IF SYS_CONTEXT ('USERENV', 'SESSION_USER') IN
               ('USS_ESR', 'IKIS_SYSWEB')
        THEN
            RETURN NULL;
        END IF;

        l_org := SYS_CONTEXT (USS_ESR_CONTEXT.gContext, USS_ESR_CONTEXT.gORG);

        IF l_org IS NULL
        THEN
            RETURN '1=2';
        ELSE
            l_usrtp :=
                SYS_CONTEXT (USS_ESR_CONTEXT.gContext,
                             USS_ESR_CONTEXT.gUserTP);

            CASE
                WHEN l_usrtp = 31
                THEN          -- UMC Користувач ЦА Мінсоцполітики - бачить все
                    RETURN NULL;
                WHEN l_usrtp IN (            -- обмежити лише МінСоцПолітики ?
                                 31,       -- UMC Користувач ЦА Мінсоцполітики
                                 33, -- UMR Користувач департаменту соц.захисту обласний
                                 35, -- UMD Користувач райнного управління соц.захисту
                                 37, -- UMV Користувач обласного центру нарахувань та виплат
                                 39)                     -- UMG Користувач ОТГ
                THEN
                    IF UPPER (p_object) IN ('V_RETURNS_REESTR')
                    THEN
                        RETURN 'rr_org in (select u_org from tmp_org)';
                    ELSIF UPPER (p_object) IN ('V_PAY_ORDER')
                    THEN
                        RETURN '(po_src in (''IN'', ''OUT'') and com_org_src in (select u_org from tmp_org) or po_src = ''D'' and com_org_dest in (select u_org from tmp_org))';
                    ELSE
                        RETURN 'com_org in (select u_org from tmp_org)';
                    END IF;
                ELSE
                    RETURN '1 = 2';
            END CASE;
        END IF;
    END;

    FUNCTION comm_pred_pc (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        l_org         VARCHAR2 (250);
        l_user_type   VARCHAR2 (250);
        l_pred        VARCHAR2 (1000);
    BEGIN
        IF SYS_CONTEXT ('USERENV', 'SESSION_USER') IN
               ('IKIS_SYSWEB', 'USS_ESR')
        THEN
            RETURN NULL;
        END IF;

        l_org := SYS_CONTEXT (USS_ESR_CONTEXT.gContext, USS_ESR_CONTEXT.gORG);
        l_user_type :=
            SYS_CONTEXT (USS_ESR_CONTEXT.gContext, USS_ESR_CONTEXT.gUserTP);

        IF l_org IS NULL
        THEN
            l_pred := '1 = 2';
        ELSE
            IF l_user_type IN ('31', '41', '21')
            THEN
                l_pred := '1 = 1';
            ELSIF l_user_type IN ('35', '37', '23')
            THEN
                CASE p_object
                    WHEN 'V_PC_DECISION_BY_PC'
                    THEN
                        l_pred :=
                            'EXISTS (SELECT 1 FROM pc_location rls_pl WHERE pd_pc = rls_pl.pl_pc AND rls_pl.history_status = ''A'' AND rls_pl.pl_org IN (SELECT u_org FROM tmp_org))';
                    WHEN 'V_ACCRUAL_BY_PC'
                    THEN
                        l_pred :=
                            'EXISTS (SELECT 1 FROM pc_location rls_pl WHERE ac_pc = rls_pl.pl_pc AND rls_pl.history_status = ''A'' AND rls_pl.pl_org IN (SELECT u_org FROM tmp_org))';
                    WHEN 'V_APPEAL_BY_PC'
                    THEN
                        l_pred :=
                            'EXISTS (SELECT 1 FROM pc_location rls_pl WHERE ap_pc = rls_pl.pl_pc AND rls_pl.history_status = ''A'' AND rls_pl.pl_org IN (SELECT u_org FROM tmp_org))';
                    WHEN 'V_ERRAND_BY_PC'
                    THEN
                        l_pred :=
                            'EXISTS (SELECT 1 FROM pc_location rls_pl WHERE ed_pc = rls_pl.pl_pc AND rls_pl.history_status = ''A'' AND rls_pl.pl_org IN (SELECT u_org FROM tmp_org))';
                    WHEN 'V_DEDUCTION_BY_PC'
                    THEN
                        l_pred :=
                            'EXISTS (SELECT 1 FROM pc_location rls_pl WHERE dn_pc = rls_pl.pl_pc AND rls_pl.history_status = ''A'' AND rls_pl.pl_org IN (SELECT u_org FROM tmp_org))';
                    ELSE
                        l_pred := '1 = 2';
                END CASE;
            ELSIF l_user_type IN ('33', '39')
            THEN
                l_pred := '(com_org IN (SELECT u_org FROM tmp_org))';
            ELSE
                l_pred := '1 = 2';
            END IF;
        END IF;

        --ikis_sysweb.ikis_debug_pipe.WriteMsg(l_pred);
        RETURN l_pred;
    END;
END USS_ESR_RLS;
/