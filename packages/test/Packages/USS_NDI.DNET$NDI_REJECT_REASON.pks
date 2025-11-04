/* Formatted on 8/12/2025 5:55:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.DNET$NDI_REJECT_REASON
IS
    --GET BY ID
    PROCEDURE GET_REJECT_REASON (P_ID    IN     NDI_REJECT_REASON.NJR_ID%TYPE,
                                 P_RES      OUT SYS_REFCURSOR);

    --LIST
    PROCEDURE QUERY_REJECT_REASON (p_NJR_CODE   IN     VARCHAR2,
                                   p_NJR_NST    IN     NUMBER,
                                   P_RES           OUT SYS_REFCURSOR);

    --DELETE
    PROCEDURE DELETE_REJECT_REASON (P_NJR_ID NDI_REJECT_REASON.NJR_ID%TYPE);

    --SAVE
    PROCEDURE SAVE_REJECT_REASON (
        P_NJR_ID      IN     NDI_REJECT_REASON.NJR_ID%TYPE,
        P_NJR_CODE    IN     NDI_REJECT_REASON.NJR_CODE%TYPE,
        P_NJR_NAME    IN     NDI_REJECT_REASON.NJR_NAME%TYPE,
        P_NJR_ORDER   IN     NDI_REJECT_REASON.NJR_ORDER%TYPE,
        P_NJR_NST     IN     NDI_REJECT_REASON.NJR_NST%TYPE,
        P_NEW_ID         OUT NDI_REJECT_REASON.NJR_ID%TYPE);
END DNET$NDI_REJECT_REASON;
/


GRANT EXECUTE ON USS_NDI.DNET$NDI_REJECT_REASON TO DNET_PROXY
/


/* Formatted on 8/12/2025 5:55:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.DNET$NDI_REJECT_REASON
IS
    --GET BY ID
    PROCEDURE GET_REJECT_REASON (P_ID    IN     NDI_REJECT_REASON.NJR_ID%TYPE,
                                 P_RES      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN P_RES FOR SELECT NJR_ID,
                              NJR_CODE,
                              NJR_NAME,
                              NJR_ORDER,
                              NJR_NST,
                              HISTORY_STATUS,
                              NJR_HS_DEL
                         FROM NDI_REJECT_REASON
                        WHERE NJR_ID = P_ID;
    END;

    --LIST
    PROCEDURE QUERY_REJECT_REASON (p_NJR_CODE   IN     VARCHAR2,
                                   p_NJR_NST    IN     NUMBER,
                                   P_RES           OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN P_RES FOR
            SELECT RR.NJR_ID,
                   RR.NJR_CODE,
                   RR.NJR_NAME,
                   RR.NJR_ORDER,
                   RR.NJR_NST,
                   RR.HISTORY_STATUS,
                   RR.NJR_HS_DEL,
                   ST.NST_NAME
              FROM NDI_REJECT_REASON  RR
                   LEFT JOIN V_NDI_SERVICE_TYPE ST ON RR.NJR_NST = ST.nst_id
             WHERE     RR.HISTORY_STATUS = 'A'
                   AND (p_NJR_CODE IS NULL OR RR.NJR_CODE = p_NJR_CODE)
                   AND (p_NJR_NST IS NULL OR RR.NJR_NST = p_NJR_NST);
    END;

    --DELETE
    PROCEDURE DELETE_REJECT_REASON (P_NJR_ID NDI_REJECT_REASON.NJR_ID%TYPE)
    IS
    BEGIN
        API$NDI_REJECT_REASON.DELETE_REJECT_REASON (P_NJR_ID => P_NJR_ID);
    END;

    --SAVE
    PROCEDURE save_reject_reason (
        p_njr_id      IN     ndi_reject_reason.njr_id%TYPE,
        p_njr_code    IN     ndi_reject_reason.njr_code%TYPE,
        p_njr_name    IN     ndi_reject_reason.njr_name%TYPE,
        p_njr_order   IN     ndi_reject_reason.njr_order%TYPE,
        p_njr_nst     IN     ndi_reject_reason.njr_nst%TYPE,
        p_new_id         OUT ndi_reject_reason.njr_id%TYPE)
    IS
    BEGIN
        api$ndi_reject_reason.save_reject_reason (
            p_njr_id           => p_njr_id,
            p_njr_code         => p_njr_code,
            p_njr_name         => p_njr_name,
            p_njr_order        => p_njr_order,
            p_njr_nst          => p_njr_nst,
            p_history_status   => api$dic_visit.c_history_status_actual,
            p_njr_hs_del       => NULL,
            p_new_id           => p_new_id);
    END;
END DNET$NDI_REJECT_REASON;
/