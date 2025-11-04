/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.DNET$MASS_EXCHANGE_INC
IS
    -- Author  : KELATEV
    -- Created : 12.09.2024 18:57:56
    -- Purpose : прослойка для безпечного доступу до uss_esr

    PROCEDURE Handle_Pfu_Incomes_Resp (p_Ur_Id      IN     NUMBER,
                                       p_Response   IN     CLOB,
                                       p_Error      IN OUT VARCHAR2);

    PROCEDURE Handle_Dps_Incomes_Init_Resp (p_Ur_Id      IN     NUMBER,
                                            p_Response   IN     CLOB,
                                            p_Error      IN OUT VARCHAR2);

    PROCEDURE Handle_Dps_Incomes_Resp (p_Ur_Id      IN     NUMBER,
                                       p_Response   IN     CLOB,
                                       p_Error      IN OUT VARCHAR2);

    PROCEDURE Handle_Dps_Background_Resp (p_Ur_Id      IN NUMBER,
                                          p_Response   IN CLOB);
END Dnet$mass_Exchange_Inc;
/


GRANT EXECUTE ON IKIS_RBM.DNET$MASS_EXCHANGE_INC TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 6:10:49 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.DNET$MASS_EXCHANGE_INC
IS
    PROCEDURE Handle_Pfu_Incomes_Resp (p_Ur_Id      IN     NUMBER,
                                       p_Response   IN     CLOB,
                                       p_Error      IN OUT VARCHAR2)
    IS
    BEGIN
        Uss_Esr.Api$mass_Exchange_Inc.Handle_Pfu_Incomes_Resp (
            p_Ur_Id      => p_Ur_Id,
            p_Response   => p_Response,
            p_Error      => p_Error);
    END;

    PROCEDURE Handle_Dps_Incomes_Init_Resp (p_Ur_Id      IN     NUMBER,
                                            p_Response   IN     CLOB,
                                            p_Error      IN OUT VARCHAR2)
    IS
    BEGIN
        Uss_Esr.Api$mass_Exchange_Inc.Handle_Dps_Incomes_Init_Resp (
            p_Ur_Id      => p_Ur_Id,
            p_Response   => p_Response,
            p_Error      => p_Error);
    END;

    PROCEDURE Handle_Dps_Incomes_Resp (p_Ur_Id      IN     NUMBER,
                                       p_Response   IN     CLOB,
                                       p_Error      IN OUT VARCHAR2)
    IS
    BEGIN
        Uss_Esr.Api$mass_Exchange_Inc.Handle_Dps_Incomes_Resp (
            p_Ur_Id      => p_Ur_Id,
            p_Response   => p_Response,
            p_Error      => p_Error);
    END;

    PROCEDURE Handle_Dps_Background_Resp (p_Ur_Id      IN NUMBER,
                                          p_Response   IN CLOB)
    IS
        l_Error   VARCHAR2 (4000);
    BEGIN
        Uss_Esr.Api$mass_Exchange_Inc.Handle_Dps_Incomes_Resp (
            p_Ur_Id      => p_Ur_Id,
            p_Response   => p_Response,
            p_Error      => l_Error);
    END;
END Dnet$mass_Exchange_Inc;
/