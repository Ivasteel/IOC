/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$CONTEXT
IS
    -- Author  : VANO
    -- Created : 17.05.2021 11:07:15
    -- Purpose : Функції встановлення контексту для .net-додатків

    PROCEDURE SetDnetEsrContext (p_session VARCHAR2);

    PROCEDURE SetDnetRtflContext (p_session    DECIMAL,
                                  p_app_name   VARCHAR2 DEFAULT NULL);
END DNET$CONTEXT;
/


GRANT EXECUTE ON USS_ESR.DNET$CONTEXT TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$CONTEXT TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:29 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$CONTEXT
IS
    PROCEDURE SetDnetEsrContext (p_session VARCHAR2)
    IS
    BEGIN
        USS_ESR_CONTEXT.SetDnetEsrContext (p_session);
    END;

    PROCEDURE SetDnetRtflContext (p_session    DECIMAL,
                                  p_app_name   VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        USS_ESR_CONTEXT.SetDnetRtflContext (p_session, p_app_name);
    END;
END DNET$CONTEXT;
/