/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.PORTAL$API
IS
    -- Author  : Max
    -- Created : 15.02.2023 13:05:26
    -- Purpose :

    PROCEDURE GetDics (p_orgs OUT SYS_REFCURSOR);
END portal$api;
/


GRANT EXECUTE ON IKIS_RBM.PORTAL$API TO II01RC_RBM_PORTAL
/

GRANT EXECUTE ON IKIS_RBM.PORTAL$API TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 6:10:50 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.PORTAL$API
IS
    PROCEDURE GetDics (p_orgs OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_orgs FOR
              SELECT *
                FROM v_opfu
               WHERE org_id BETWEEN 50000 AND 69999 AND org_st = 'A'
            ORDER BY org_code || ' ' || org_name;
    END;
END portal$api;
/