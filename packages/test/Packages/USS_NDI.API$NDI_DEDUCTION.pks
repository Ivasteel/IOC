/* Formatted on 8/12/2025 5:55:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.API$NDI_DEDUCTION
IS
    PROCEDURE Save_Deduction (
        p_NDN_ID            IN     NDI_DEDUCTION.NDN_ID%TYPE,
        p_NDN_CODE          IN     NDI_DEDUCTION.NDN_CODE%TYPE,
        p_NDN_NAME          IN     NDI_DEDUCTION.NDN_NAME%TYPE,
        p_NDN_MAX_PRC       IN     NDI_DEDUCTION.NDN_MAX_PRC%TYPE,
        p_NDN_TP            IN     NDI_DEDUCTION.NDN_TP%TYPE,
        p_NDN_START_DT      IN     NDI_DEDUCTION.NDN_START_DT%TYPE,
        p_NDN_STOP_DT       IN     NDI_DEDUCTION.NDN_STOP_DT%TYPE,
        p_NDN_POST_FEE_TP   IN     NDI_DEDUCTION.NDN_POST_FEE_TP%TYPE,
        p_NDN_SRC_SUM_TP    IN     NDI_DEDUCTION.NDN_SRC_SUM_TP%TYPE,
        p_NDN_OP            IN     NDI_DEDUCTION.NDN_OP%TYPE,
        p_HISTORY_STATUS    IN     NDI_DEDUCTION.HISTORY_STATUS%TYPE,
        p_NDN_ORDER         IN     NDI_DEDUCTION.NDN_ORDER%TYPE,
        p_NDN_HS_DEL        IN     NDI_DEDUCTION.NDN_HS_DEL%TYPE,
        p_NDN_HS_UPD        IN     NDI_DEDUCTION.NDN_HS_UPD%TYPE,
        p_new_id               OUT NDI_DEDUCTION.NDN_ID%TYPE);

    PROCEDURE Delete_Deduction (p_NDN_ID NDI_DEDUCTION.NDN_ID%TYPE);
END Api$ndi_Deduction;
/


/* Formatted on 8/12/2025 5:55:29 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.API$NDI_DEDUCTION
IS
    PROCEDURE Save_Deduction (
        p_NDN_ID            IN     NDI_DEDUCTION.NDN_ID%TYPE,
        p_NDN_CODE          IN     NDI_DEDUCTION.NDN_CODE%TYPE,
        p_NDN_NAME          IN     NDI_DEDUCTION.NDN_NAME%TYPE,
        p_NDN_MAX_PRC       IN     NDI_DEDUCTION.NDN_MAX_PRC%TYPE,
        p_NDN_TP            IN     NDI_DEDUCTION.NDN_TP%TYPE,
        p_NDN_START_DT      IN     NDI_DEDUCTION.NDN_START_DT%TYPE,
        p_NDN_STOP_DT       IN     NDI_DEDUCTION.NDN_STOP_DT%TYPE,
        p_NDN_POST_FEE_TP   IN     NDI_DEDUCTION.NDN_POST_FEE_TP%TYPE,
        p_NDN_SRC_SUM_TP    IN     NDI_DEDUCTION.NDN_SRC_SUM_TP%TYPE,
        p_NDN_OP            IN     NDI_DEDUCTION.NDN_OP%TYPE,
        p_HISTORY_STATUS    IN     NDI_DEDUCTION.HISTORY_STATUS%TYPE,
        p_NDN_ORDER         IN     NDI_DEDUCTION.NDN_ORDER%TYPE,
        p_NDN_HS_DEL        IN     NDI_DEDUCTION.NDN_HS_DEL%TYPE,
        p_NDN_HS_UPD        IN     NDI_DEDUCTION.NDN_HS_UPD%TYPE,
        p_new_id               OUT NDI_DEDUCTION.NDN_ID%TYPE)
    IS
    BEGIN
        IF p_NDN_ID IS NULL
        THEN
            INSERT INTO NDI_DEDUCTION (NDN_CODE,
                                       NDN_NAME,
                                       NDN_MAX_PRC,
                                       NDN_TP,
                                       NDN_START_DT,
                                       NDN_STOP_DT,
                                       NDN_POST_FEE_TP,
                                       NDN_SRC_SUM_TP,
                                       NDN_OP,
                                       HISTORY_STATUS,
                                       NDN_ORDER,
                                       NDN_HS_DEL,
                                       NDN_HS_UPD)
                 VALUES (p_NDN_CODE,
                         p_NDN_NAME,
                         p_NDN_MAX_PRC,
                         p_NDN_TP,
                         p_NDN_START_DT,
                         p_NDN_STOP_DT,
                         p_NDN_POST_FEE_TP,
                         p_NDN_SRC_SUM_TP,
                         p_NDN_OP,
                         p_HISTORY_STATUS,
                         p_NDN_ORDER,
                         p_NDN_HS_DEL,
                         p_NDN_HS_UPD)
              RETURNING NDN_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_NDN_ID;

            UPDATE NDI_DEDUCTION D
               SET D.NDN_CODE = p_NDN_CODE,
                   D.NDN_NAME = p_NDN_NAME,
                   D.NDN_MAX_PRC = p_NDN_MAX_PRC,
                   D.NDN_TP = p_NDN_TP,
                   D.NDN_START_DT = p_NDN_START_DT,
                   D.NDN_STOP_DT = p_NDN_STOP_DT,
                   D.NDN_POST_FEE_TP = p_NDN_POST_FEE_TP,
                   D.NDN_SRC_SUM_TP = p_NDN_SRC_SUM_TP,
                   D.NDN_OP = p_NDN_OP,
                   D.HISTORY_STATUS = p_HISTORY_STATUS,
                   D.NDN_ORDER = p_NDN_ORDER,
                   D.NDN_HS_DEL = p_NDN_HS_DEL,
                   D.NDN_HS_UPD = tools.GetHistSession
             WHERE NDN_ID = p_NDN_ID;
        END IF;
    END;

    PROCEDURE Delete_Deduction (p_NDN_ID NDI_DEDUCTION.NDN_ID%TYPE)
    IS
    BEGIN
        UPDATE NDI_DEDUCTION D
           SET D.NDN_HS_DEL = tools.GetHistSession,
               D.History_Status = API$DIC_VISIT.c_History_Status_Historical
         WHERE p_NDN_ID = d.ndn_id;
    END;
END Api$ndi_Deduction;
/