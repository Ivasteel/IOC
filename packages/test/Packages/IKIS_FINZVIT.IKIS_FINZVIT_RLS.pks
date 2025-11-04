/* Formatted on 8/12/2025 6:06:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_FINZVIT.ikis_finzvit_rls
IS
    -- Author  : MAXYM
    -- Created : 21.11.2017 15:13:10
    -- Purpose : RowLevelSecurity



    FUNCTION finzvit_predix (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;
END ikis_finzvit_rls;
/


/* Formatted on 8/12/2025 6:06:33 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_FINZVIT.ikis_finzvit_rls
IS
    FUNCTION GetOPFULst (p_opfu NUMBER)
        RETURN VARCHAR2
    IS
        l_opfulst   VARCHAR2 (1000);
    BEGIN
        FOR i IN (SELECT org_id
                    FROM v_opfu
                   WHERE org_org = p_opfu)
        LOOP
            l_opfulst := l_opfulst || ',' || i.org_id;
        END LOOP;

        RETURN LTRIM (l_opfulst, ',');
    END;


    FUNCTION finzvit_predix (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        l_uid     NUMBER;
        l_usrtp   NUMBER;
        l_opfu    NUMBER;
    BEGIN
        l_uid :=
            SYS_CONTEXT (ikis_finzvit_context.gContext,
                         ikis_finzvit_context.gUID);
        l_usrtp :=
            SYS_CONTEXT (ikis_finzvit_context.gContext,
                         ikis_finzvit_context.gUserTP);
        l_opfu :=
            SYS_CONTEXT (ikis_finzvit_context.gContext,
                         ikis_finzvit_context.gOPFU);

        IF (UPPER (p_object) = 'V_PAY_ORDER')
        THEN
            CASE
                WHEN l_usrtp = 4
                THEN
                    RETURN NULL;
                WHEN l_usrtp = 5
                THEN
                    BEGIN
                        RETURN 'com_org_src in (' || l_opfu || ')';
                    END;
                WHEN l_usrtp = 6
                THEN
                    BEGIN
                        RETURN 'com_org_src in (' || l_opfu || ')';
                    END;
                ELSE
                    RETURN '1=2';
            END CASE;
        ELSIF (UPPER (p_object) = 'V_BUDGET_PFU')
        THEN
            CASE
                WHEN l_usrtp = 4
                THEN
                    RETURN NULL;
                ELSE
                    RETURN '1=2';
            END CASE;
        ELSIF (UPPER (p_object) = 'V_BUDGET_ORG')
        THEN
            CASE
                WHEN l_usrtp = 4
                THEN
                    RETURN NULL;
                WHEN l_usrtp = 5
                THEN
                    BEGIN
                        RETURN 'bo_org=' || l_opfu;
                    END;
                ELSE
                    RETURN '1=2';
            END CASE;
        ELSE
            CASE
                WHEN l_usrtp = 4
                THEN
                    RETURN NULL;
                WHEN l_usrtp = 5
                THEN
                    BEGIN
                        RETURN    'com_org in ('
                               || l_opfu
                               || ','
                               || GetOPFULst (l_opfu)
                               || ')';
                    END;
                WHEN l_usrtp = 6
                THEN
                    BEGIN
                        RETURN 'com_org in (' || l_opfu || ')';
                    END;
                ELSE
                    RETURN '1=2';
            END CASE;
        END IF;
    END;
END ikis_finzvit_rls;
/