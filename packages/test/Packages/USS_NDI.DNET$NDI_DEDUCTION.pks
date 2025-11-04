/* Formatted on 8/12/2025 5:55:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.DNET$NDI_DEDUCTION
IS
    --GET BY ID
    PROCEDURE GET_DEDUCTION (P_NDN_ID   IN     NDI_DEDUCTION.NDN_ID%TYPE,
                             P_RES         OUT SYS_REFCURSOR);

    --LIST
    PROCEDURE QUERY_DEDUCTION (p_NDN_CODE   IN     VARCHAR2,
                               p_NDN_NAME   IN     VARCHAR2,
                               P_RES           OUT SYS_REFCURSOR);

    --DELETE
    PROCEDURE DELETE_DEDUCTION (P_NDN_ID NDI_DEDUCTION.NDN_ID%TYPE);

    --SAVE
    PROCEDURE SAVE_DEDUCTION (
        P_NDN_ID        IN     NDI_DEDUCTION.NDN_ID%TYPE,
        p_NDN_CODE      IN     NDI_DEDUCTION.NDN_CODE%TYPE,
        p_NDN_NAME      IN     NDI_DEDUCTION.NDN_NAME%TYPE,
        p_NDN_MAX_PRC   IN     NDI_DEDUCTION.NDN_MAX_PRC%TYPE,
        p_NDN_ORDER     IN     NDI_DEDUCTION.NDN_ORDER%TYPE,
        P_NEW_ID           OUT NDI_DEDUCTION.NDN_ID%TYPE);
END DNET$NDI_DEDUCTION;
/


GRANT EXECUTE ON USS_NDI.DNET$NDI_DEDUCTION TO DNET_PROXY
/


/* Formatted on 8/12/2025 5:55:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.DNET$NDI_DEDUCTION
IS
    --GET BY ID
    PROCEDURE GET_DEDUCTION (P_NDN_ID   IN     NDI_DEDUCTION.NDN_ID%TYPE,
                             P_RES         OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN P_RES FOR SELECT NDN_ID,
                              NDN_CODE,
                              NDN_NAME,
                              NDN_MAX_PRC,
                              NDN_TP,
                              NDN_START_DT,
                              NDN_STOP_DT,
                              NDN_POST_FEE_TP,
                              NDN_SRC_SUM_TP,
                              -- NDI_OP
                              NDN_OP,
                              HISTORY_STATUS,
                              NDN_ORDER,
                              -- HISTSESSION
                              NDN_HS_DEL,
                              -- HISTSESSION
                              NDN_HS_UPD
                         FROM NDI_DEDUCTION
                        WHERE NDN_ID = P_NDN_ID;
    END;

    --LIST
    PROCEDURE QUERY_DEDUCTION (p_NDN_CODE   IN     VARCHAR2,
                               p_NDN_NAME   IN     VARCHAR2,
                               P_RES           OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN P_RES FOR
            SELECT D.NDN_ID,
                   D.NDN_CODE,
                   D.NDN_NAME,
                   D.NDN_MAX_PRC,
                   D.NDN_TP,
                   D.NDN_START_DT,
                   D.NDN_STOP_DT,
                   D.NDN_POST_FEE_TP,
                   D.NDN_SRC_SUM_TP,
                   -- NDI_OP
                   D.NDN_OP,
                   D.HISTORY_STATUS,
                   D.NDN_ORDER,
                   -- HISTSESSION
                   D.NDN_HS_DEL,
                   -- HISTSESSION
                   D.NDN_HS_UPD
              FROM NDI_DEDUCTION D
             WHERE     D.HISTORY_STATUS = 'A'
                   AND (   p_NDN_CODE IS NULL
                        OR D.NDN_CODE LIKE '%' || p_NDN_CODE || '%'
                        OR D.NDN_CODE LIKE p_NDN_CODE || '%')
                   AND (   p_NDN_NAME IS NULL
                        OR D.NDN_NAME LIKE '%' || p_NDN_NAME || '%'
                        OR D.NDN_NAME LIKE p_NDN_NAME || '%');
    END;

    --DELETE
    PROCEDURE DELETE_DEDUCTION (P_NDN_ID NDI_DEDUCTION.NDN_ID%TYPE)
    IS
    BEGIN
        API$NDI_DEDUCTION.DELETE_DEDUCTION (P_NDN_ID => P_NDN_ID);
    END;

    --SAVE
    PROCEDURE SAVE_DEDUCTION (
        P_NDN_ID        IN     NDI_DEDUCTION.NDN_ID%TYPE,
        p_NDN_CODE      IN     NDI_DEDUCTION.NDN_CODE%TYPE,
        p_NDN_NAME      IN     NDI_DEDUCTION.NDN_NAME%TYPE,
        p_NDN_MAX_PRC   IN     NDI_DEDUCTION.NDN_MAX_PRC%TYPE,
        p_NDN_ORDER     IN     NDI_DEDUCTION.NDN_ORDER%TYPE,
        P_NEW_ID           OUT NDI_DEDUCTION.NDN_ID%TYPE)
    IS
    BEGIN
        API$NDI_DEDUCTION.SAVE_DEDUCTION (
            P_NDN_ID            => P_NDN_ID,
            p_NDN_CODE          => p_NDN_CODE,
            p_NDN_NAME          => p_NDN_NAME,
            p_NDN_MAX_PRC       => p_NDN_MAX_PRC,
            p_NDN_TP            => NULL,
            p_NDN_START_DT      => NULL,
            p_NDN_STOP_DT       => NULL,
            p_NDN_POST_FEE_TP   => NULL,
            p_NDN_SRC_SUM_TP    => NULL,
            p_NDN_OP            => NULL,
            P_HISTORY_STATUS    => API$DIC_VISIT.c_History_Status_Actual,
            p_NDN_ORDER         => p_NDN_ORDER,
            p_NDN_HS_DEL        => NULL,
            p_NDN_HS_UPD        => NULL,
            P_NEW_ID            => P_NEW_ID);
    END;
END DNET$NDI_DEDUCTION;
/