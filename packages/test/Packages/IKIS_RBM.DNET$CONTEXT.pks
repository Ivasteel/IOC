/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.DNET$CONTEXT
IS
    -- Author  : SHOSTAK
    -- Created : 24.05.2023 9:30:45 AM
    -- Purpose :

    PROCEDURE Set_Dnet_Cmes_Context (p_Session VARCHAR2);

    PROCEDURE clear_context;
END Dnet$context;
/


GRANT EXECUTE ON IKIS_RBM.DNET$CONTEXT TO DNET_PROXY
/

GRANT EXECUTE ON IKIS_RBM.DNET$CONTEXT TO II01RC_RBMWEB_COMMON
/

GRANT EXECUTE ON IKIS_RBM.DNET$CONTEXT TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 6:10:49 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.DNET$CONTEXT
IS
    PROCEDURE Set_Dnet_Cmes_Context (p_Session VARCHAR2)
    IS
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET cell_offload_processing=FALSE';

        Cmes_Context.Set_Dnet_Cmes_Context (p_Session);
    END;

    PROCEDURE clear_context
    IS
    BEGIN
        Cmes_Context.clear_context;
    END;
END Dnet$context;
/