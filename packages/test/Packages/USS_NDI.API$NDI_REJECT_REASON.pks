/* Formatted on 8/12/2025 5:55:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.API$NDI_REJECT_REASON
IS
    PROCEDURE Save_Reject_Reason (
        p_NJR_ID           IN     NDI_REJECT_REASON.NJR_ID%TYPE,
        p_NJR_CODE         IN     NDI_REJECT_REASON.NJR_CODE%TYPE,
        p_NJR_NAME         IN     NDI_REJECT_REASON.NJR_NAME%TYPE,
        p_NJR_ORDER        IN     NDI_REJECT_REASON.NJR_ORDER%TYPE,
        p_NJR_NST          IN     NDI_REJECT_REASON.NJR_NST%TYPE,
        p_HISTORY_STATUS   IN     NDI_REJECT_REASON.HISTORY_STATUS%TYPE,
        p_NJR_HS_DEL       IN     NDI_REJECT_REASON.NJR_HS_DEL%TYPE,
        p_new_id              OUT NDI_REJECT_REASON.NJR_ID%TYPE);

    PROCEDURE Delete_Reject_Reason (p_NJR_ID NDI_REJECT_REASON.NJR_ID%TYPE);
END Api$ndi_Reject_Reason;
/


/* Formatted on 8/12/2025 5:55:29 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.API$NDI_REJECT_REASON
IS
    PROCEDURE Save_Reject_Reason (
        p_NJR_ID           IN     NDI_REJECT_REASON.NJR_ID%TYPE,
        p_NJR_CODE         IN     NDI_REJECT_REASON.NJR_CODE%TYPE,
        p_NJR_NAME         IN     NDI_REJECT_REASON.NJR_NAME%TYPE,
        p_NJR_ORDER        IN     NDI_REJECT_REASON.NJR_ORDER%TYPE,
        p_NJR_NST          IN     NDI_REJECT_REASON.NJR_NST%TYPE,
        p_HISTORY_STATUS   IN     NDI_REJECT_REASON.HISTORY_STATUS%TYPE,
        p_NJR_HS_DEL       IN     NDI_REJECT_REASON.NJR_HS_DEL%TYPE,
        p_new_id              OUT NDI_REJECT_REASON.NJR_ID%TYPE)
    IS
    BEGIN
        IF p_NJR_ID IS NULL
        THEN
            INSERT INTO NDI_REJECT_REASON (NJR_CODE,
                                           NJR_NAME,
                                           NJR_ORDER,
                                           NJR_NST,
                                           HISTORY_STATUS,
                                           NJR_HS_DEL)
                 VALUES (p_NJR_CODE,
                         p_NJR_NAME,
                         p_NJR_ORDER,
                         p_NJR_NST,
                         p_HISTORY_STATUS,
                         p_NJR_HS_DEL)
              RETURNING NJR_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_NJR_ID;

            UPDATE NDI_REJECT_REASON
               SET NJR_CODE = p_NJR_CODE,
                   NJR_NAME = p_NJR_NAME,
                   NJR_ORDER = p_NJR_ORDER,
                   NJR_NST = p_NJR_NST,
                   HISTORY_STATUS = p_HISTORY_STATUS,
                   NJR_HS_DEL = p_NJR_HS_DEL
             WHERE NJR_ID = p_NJR_ID;
        END IF;
    END;

    PROCEDURE Delete_Reject_Reason (p_NJR_ID NDI_REJECT_REASON.NJR_ID%TYPE)
    IS
    BEGIN
        UPDATE NDI_REJECT_REASON RR
           SET RR.NJR_HS_DEL = tools.GetHistSession, RR.History_Status = 'H'
         WHERE p_NJR_ID = RR.NJR_ID;
    END;
END API$NDI_REJECT_REASON;
/