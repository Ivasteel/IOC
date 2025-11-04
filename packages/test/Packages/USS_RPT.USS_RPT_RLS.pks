/* Formatted on 8/12/2025 5:58:56 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RPT.USS_RPT_RLS
IS
    FUNCTION Select_ByComOrg (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;
END USS_RPT_RLS;
/


/* Formatted on 8/12/2025 5:59:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RPT.USS_RPT_RLS
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


    -- выбор по ком оргу
    FUNCTION Select_ByComOrg (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'com_org = NVL(sys_context(''USS_RPT'', ''OPFU''), -1)';
    END;
END USS_RPT_RLS;
/