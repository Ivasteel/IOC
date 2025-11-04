/* Formatted on 8/12/2025 5:57:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.USS_RNSP_RLS
IS
    -- Author  : VANO
    -- Created : 10.06.2021 12:13:27
    -- Purpose : Функції для політик порядкового розподілу доступу

    FUNCTION comm_pred (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION comm_pred_cs (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;
END USS_RNSP_RLS;
/


/* Formatted on 8/12/2025 5:58:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RNSP.USS_RNSP_RLS
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
        l_org   VARCHAR2 (250);
    BEGIN
        IF SYS_CONTEXT ('USERENV', 'SESSION_USER') IN
               ('IKIS_SYSWEB', 'USS_RNSP')
        THEN
            RETURN NULL;
        END IF;

        l_org :=
            SYS_CONTEXT (USS_RNSP_CONTEXT.gContext, USS_RNSP_CONTEXT.gORG);

        IF l_org IS NULL
        THEN
            RETURN '1=2';
        ELSE
            RETURN 'com_org = ' || l_org;
        END IF;
    END;

    FUNCTION comm_pred_cs (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        l_org     VARCHAR2 (250);
        l_usrtp   NUMBER;
    BEGIN
        IF SYS_CONTEXT ('USERENV', 'SESSION_USER') IN
               ('USS_RNSP', 'IKIS_SYSWEB')
        THEN
            RETURN NULL;
        END IF;

        l_org :=
            SYS_CONTEXT (USS_RNSP_CONTEXT.gContext, USS_RNSP_CONTEXT.gORG);

        IF l_org IS NULL
        THEN
            RETURN '1=2';
        ELSE
            l_usrtp :=
                SYS_CONTEXT (USS_RNSP_CONTEXT.gContext,
                             USS_RNSP_CONTEXT.gUserTP);

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
END USS_RNSP_RLS;
/