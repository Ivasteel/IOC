/* Formatted on 8/12/2025 5:55:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.USS_NDI_RLS
IS
    -- Author  : VANO
    -- Created : 30.12.2021 17:44:41
    -- Purpose : Функції для політик порядкового розподілу доступу

    FUNCTION comm_pred (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;

    FUNCTION comm_pred_adm (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2;
--  FUNCTION comm_pred_cs (p_schema IN VARCHAR2, p_object VARCHAR2) RETURN VARCHAR2;

END USS_NDI_RLS;
/


/* Formatted on 8/12/2025 5:55:33 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.USS_NDI_RLS
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
        IF SYS_CONTEXT ('USERENV', 'SESSION_USER') IN ('USS_ESR', 'USS_NDI')
        THEN
            RETURN NULL;
        END IF;

        l_org := SYS_CONTEXT ('USS_ESR', 'ORG');

        IF l_org IS NULL
        THEN
            RETURN '1 = 2';
        ELSE
            RETURN 'com_org = sys_context(''USS_ESR'', ''ORG'')';
        END IF;
    END;

    FUNCTION comm_pred_adm (p_schema IN VARCHAR2, p_object VARCHAR2)
        RETURN VARCHAR2
    IS
        l_org   VARCHAR2 (250);
    BEGIN
        IF SYS_CONTEXT ('USERENV', 'SESSION_USER') IN ('USS_NDI')
        THEN
            RETURN NULL;
        END IF;

        l_org := SYS_CONTEXT ('IKISWEBADM', 'OPFU');

        IF l_org IS NULL
        THEN
            RETURN '1 = 2';
        ELSE
            RETURN 'com_org = sys_context(''IKISWEBADM'', ''OPFU'')';
        END IF;
    END;
/*FUNCTION comm_pred_cs (p_schema IN VARCHAR2, p_object VARCHAR2) RETURN VARCHAR2
IS
  l_org  VARCHAR2(250);
  l_usrtp number;
BEGIN

  IF sys_context('USERENV', 'SESSION_USER') IN ('USS_ESR', 'IKIS_SYSWEB') THEN
    RETURN NULL;
  END IF;

  l_org := sys_context(USS_ESR_CONTEXT.gContext,USS_ESR_CONTEXT.gORG);

  IF l_org IS NULL THEN
    RETURN '1=2';
  ELSE
    l_usrtp:=sys_context(USS_ESR_CONTEXT.gContext,USS_ESR_CONTEXT.gUserTP);
    CASE
      WHEN l_usrtp = 31 THEN  -- UMC Користувач ЦА Мінсоцполітики - бачить все
        RETURN NULL;
      WHEN l_usrtp in (  -- обмежити лише МінСоцПолітики ?
              31, -- UMC Користувач ЦА Мінсоцполітики
              33, -- UMR Користувач департаменту соц.захисту обласний
              35, -- UMD Користувач райнного управління соц.захисту
              37, -- UMV Користувач обласного центру нарахувань та виплат
              39) -- UMG Користувач ОТГ
      THEN
        IF UPPER(p_object) IN ('V_RETURNS_REESTR') THEN
          RETURN 'rr_org in (select u_org from tmp_org)';
        ELSIF UPPER(p_object) IN ('V_PAY_ORDER') THEN
          RETURN '(po_src in (''IN'', ''OUT'') and com_org_src in (select u_org from tmp_org) or po_src = ''D'' and com_org_dest in (select u_org from tmp_org))';
        ELSE
          RETURN 'com_org in (select u_org from tmp_org)';
        END IF;
      ELSE
        RETURN '1 = 2';
    END CASE;
  END IF;
END;
*/
END USS_NDI_RLS;
/