/* Formatted on 8/12/2025 5:59:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.DNET$CONTEXT
IS
    -- Author  : VANO
    -- Created : 17.05.2021 11:07:15
    -- Purpose : Функції встановлення контексту для .net-додатків

    PROCEDURE SetDnetVisitContext (p_session VARCHAR2);

    PROCEDURE SetDnetRtflContext (p_session    DECIMAL,
                                  p_app_name   VARCHAR2 DEFAULT NULL);
END DNET$CONTEXT;
/


GRANT EXECUTE ON USS_VISIT.DNET$CONTEXT TO DNET_PROXY
/

GRANT EXECUTE ON USS_VISIT.DNET$CONTEXT TO II01RC_USS_VISIT_WEB
/


/* Formatted on 8/12/2025 6:00:01 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.DNET$CONTEXT
IS
    PROCEDURE SetDnetVisitContext (p_session VARCHAR2)
    IS
    BEGIN
        USS_VISIT_CONTEXT.SetDnetVisitContext (p_session);
    END;

    PROCEDURE SetDnetRtflContext (p_session    DECIMAL,
                                  p_app_name   VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        USS_VISIT_CONTEXT.SetDnetRtflContext (p_session, p_app_name);
    END;
END DNET$CONTEXT;
/