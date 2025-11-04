/* Formatted on 8/12/2025 5:47:12 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_DOC.DNET$CONTEXT
IS
    -- Author  : SHOSTAK
    -- Created : 26.05.2021 8:32:10
    -- Purpose :

    PROCEDURE Set_Context (p_App_Id          NUMBER,
                           p_Session_Id   IN VARCHAR2 DEFAULT NULL);
END Dnet$context;
/


GRANT EXECUTE ON USS_DOC.DNET$CONTEXT TO DNET_PROXY
/

GRANT EXECUTE ON USS_DOC.DNET$CONTEXT TO II01RC_USS_DOC_WEB
/

GRANT EXECUTE ON USS_DOC.DNET$CONTEXT TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 5:47:12 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_DOC.DNET$CONTEXT
IS
    PROCEDURE Set_Context (p_App_Id          NUMBER,
                           p_Session_Id   IN VARCHAR2 DEFAULT NULL)
    IS
        l_Set_Context_Proc   VARCHAR2 (255);
    BEGIN
        Uss_Doc_Context.Set_App_Context (p_App_Id);

        SELECT a.App_Set_Context_Proc
          INTO l_Set_Context_Proc
          FROM Api_Applications a
         WHERE a.App_Id = p_App_Id;

        IF l_Set_Context_Proc IS NOT NULL
        THEN
            EXECUTE IMMEDIATE   'BEGIN '
                             || l_Set_Context_Proc
                             || '(:p_session_id); END;'
                USING IN p_Session_Id;
        END IF;
    END;
END Dnet$context;
/