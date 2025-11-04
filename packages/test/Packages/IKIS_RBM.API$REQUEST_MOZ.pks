/* Formatted on 8/12/2025 6:10:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.API$REQUEST_MOZ
IS
    -- Author  : KELATEV
    -- Created : 21.02.2025 16:08:46
    -- Purpose : Запити до МОЗ

    c_Pt_Scdi_Id   CONSTANT NUMBER := 509;

    Package_Name   CONSTANT VARCHAR2 (50) := 'API$REQUEST_MOZ';

    TYPE r_Feedback_Response IS RECORD
    (
        Code    VARCHAR2 (100),
        Text    VARCHAR2 (1000)
    );

    PROCEDURE Reg_Feedback_Errors_Req (p_Ur_Id     IN NUMBER,
                                       p_Scdi_Id   IN NUMBER,
                                       p_Req_Id    IN VARCHAR2,
                                       p_Result    IN VARCHAR2,
                                       p_Message   IN VARCHAR2);

    PROCEDURE Handle_Feedback_Req (p_Ur_Id      IN     NUMBER,
                                   p_Response   IN     CLOB,
                                   p_Error      IN OUT VARCHAR2);
END Api$request_Moz;
/


GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MOZ TO SERVICE_PROXY
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MOZ TO USS_ESR
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MOZ TO USS_PERSON
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MOZ TO USS_RNSP
/

GRANT EXECUTE ON IKIS_RBM.API$REQUEST_MOZ TO USS_VISIT
/


/* Formatted on 8/12/2025 6:10:47 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.API$REQUEST_MOZ
IS
    -----------------------------------------------------------------------------
    --    Реєстрація запиту на передачу помилок про імпорт МОЗ
    -----------------------------------------------------------------------------
    PROCEDURE Reg_Feedback_Errors_Req (p_Ur_Id     IN NUMBER,
                                       p_Scdi_Id   IN NUMBER,
                                       p_Req_Id    IN VARCHAR2,
                                       p_Result    IN VARCHAR2,
                                       p_Message   IN VARCHAR2)
    IS
        l_Ur_Id      NUMBER;
        l_Rn_Id      NUMBER;
        l_Req_Clob   CLOB;
    BEGIN
        SELECT Json_Object (
                   'businessProcessDefinitionKey' VALUE
                       'eiccc-feedback-errors',
                   'startVariables' VALUE
                       Json_Object ('reqId' VALUE p_Req_Id,
                                    'result' VALUE p_Result,
                                    'message' VALUE p_Message))
          INTO l_Req_Clob
          FROM DUAL;

        Api$uxp_Request.Register_Out_Request (
            p_Ur_Plan_Dt     => SYSDATE,
            p_Ur_Urt         => 145,
            p_Ur_Create_Wu   => NULL,
            p_Ur_Ext_Id      => p_Req_Id,
            p_Ur_Body        => l_Req_Clob,
            p_New_Id         => l_Ur_Id,
            p_Rn_Nrt         => 145,
            p_Rn_Src         => 'USS',
            p_Rn_Hs_Ins      => Tools.Gethistsession,
            p_New_Rn_Id      => l_Rn_Id);

        Api$request.Save_Rn_Common_Info (p_Rnc_Rn        => l_Rn_Id,
                                         p_Rnc_Pt        => c_Pt_Scdi_Id,
                                         p_Rnc_Val_Int   => p_Scdi_Id);

        --Зберігаємо зв'язок між вхідним запитом та запитом з квитанцією
        INSERT INTO Uxp_Ack (Ua_Id, Ua_Ur_In, Ua_Ur_Out)
             VALUES (0, p_Ur_Id, l_Ur_Id);
    END;

    --------------------------------------------------------------------------
    -- Обробка відповіді на запит на передачу помилок про імпорт МОЗ
    --------------------------------------------------------------------------
    PROCEDURE Handle_Feedback_Req (p_Ur_Id      IN     NUMBER,
                                   p_Response   IN     CLOB,
                                   p_Error      IN OUT VARCHAR2)
    IS
        l_Response   r_Feedback_Response;
    BEGIN
        IF p_Response IS NOT NULL AND DBMS_LOB.Getlength (p_Response) > 0
        THEN
            BEGIN
                EXECUTE IMMEDIATE Type2jsontable (
                                     p_Pkg_Name    => Package_Name,
                                     p_Type_Name   => 'R_FEEDBACK_RESPONSE')
                    USING IN p_Response, OUT l_Response;

                RETURN;
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;
        END IF;

        IF p_Error IS NOT NULL
        THEN
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    => p_Error);
        END IF;
    END;
END Api$request_Moz;
/