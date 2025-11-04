/* Formatted on 8/12/2025 5:58:56 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RPT.DNET$CONTEXT
IS
    -- Author  : BOGDAN
    -- Created : 09.02.2022 18:59:29
    -- Purpose :

    PROCEDURE SetDnetEsrContext (p_session VARCHAR2);
END DNET$CONTEXT;
/


/* Formatted on 8/12/2025 5:58:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RPT.DNET$CONTEXT
IS
    PROCEDURE SetDnetEsrContext (p_session VARCHAR2)
    IS
    BEGIN
        USS_RPT_CONTEXT.SetDnetRptContext (p_session);
    END;
END DNET$CONTEXT;
/