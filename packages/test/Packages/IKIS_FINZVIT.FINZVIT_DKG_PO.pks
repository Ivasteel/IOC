/* Formatted on 8/12/2025 6:06:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_FINZVIT.FINZVIT_DKG_PO
IS
    -- Author  : MAXYM
    -- Created : 14.12.2017 14:00:49
    -- Purpose : Платіжні доручення з ДКГ

    PROCEDURE InsertRequest (
        p_DPR_DRT               IN     dkg_po_request.dpr_drt%TYPE,
        p_DPR_START_PERIOD_DT   IN     dkg_po_request.DPR_START_PERIOD_DT%TYPE,
        p_DPR_STOP_PERIOD_DT    IN     dkg_po_request.DPR_STOP_PERIOD_DT%TYPE,
        p_DPR_PR_TP             IN     dkg_po_request.DPR_PR_TP%TYPE,
        p_DPR_OTP_TP            IN     dkg_po_request.DPR_OTP_TP%TYPE,
        p_NEW_DPR_ID               OUT dkg_po_request.dpr_id%TYPE);


    PROCEDURE InsertLink (p_DPL_DKG_TP   IN dkg_po_link.dpl_dkg_tp%TYPE,
                          p_DPL_DKG_ID   IN dkg_po_link.DPL_DKG_ID%TYPE,
                          p_DPL_PO       IN dkg_po_link.DPL_PO%TYPE,
                          p_DPL_DPR      IN dkg_po_link.DPL_DPR%TYPE);

    PROCEDURE GetLinkedDkgRows (
        p_DPR_DRT               IN     dkg_po_request.dpr_drt%TYPE,
        p_DPR_START_PERIOD_DT   IN     dkg_po_request.DPR_START_PERIOD_DT%TYPE,
        p_DPR_STOP_PERIOD_DT    IN     dkg_po_request.DPR_STOP_PERIOD_DT%TYPE,
        p_res                      OUT SYS_REFCURSOR);
END FINZVIT_DKG_PO;
/


GRANT EXECUTE ON IKIS_FINZVIT.FINZVIT_DKG_PO TO DNET_PROXY
/


/* Formatted on 8/12/2025 6:06:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_FINZVIT.FINZVIT_DKG_PO
IS
    PROCEDURE InsertRequest (
        p_DPR_DRT               IN     dkg_po_request.dpr_drt%TYPE,
        p_DPR_START_PERIOD_DT   IN     dkg_po_request.DPR_START_PERIOD_DT%TYPE,
        p_DPR_STOP_PERIOD_DT    IN     dkg_po_request.DPR_STOP_PERIOD_DT%TYPE,
        p_DPR_PR_TP             IN     dkg_po_request.DPR_PR_TP%TYPE,
        p_DPR_OTP_TP            IN     dkg_po_request.DPR_OTP_TP%TYPE,
        p_NEW_DPR_ID               OUT dkg_po_request.dpr_id%TYPE)
    IS
    BEGIN
        INSERT INTO dkg_po_request (dpr_create_dt,
                                    com_org,
                                    com_wu,
                                    dpr_drt,
                                    dpr_start_period_dt,
                                    dpr_stop_period_dt,
                                    dpr_pr_tp,
                                    dpr_otp_tp)
             VALUES (
                        SYSDATE,
                        SYS_CONTEXT (ikis_finzvit_context.gContext,
                                     ikis_finzvit_context.gOPFU),
                        SYS_CONTEXT (ikis_finzvit_context.gContext,
                                     ikis_finzvit_context.gUID),
                        p_dpr_drt,
                        p_dpr_start_period_dt,
                        p_dpr_stop_period_dt,
                        p_dpr_pr_tp,
                        p_dpr_otp_tp)
          RETURNING dpr_id
               INTO p_NEW_DPR_ID;
    END;


    PROCEDURE InsertLink (p_DPL_DKG_TP   IN dkg_po_link.dpl_dkg_tp%TYPE,
                          p_DPL_DKG_ID   IN dkg_po_link.DPL_DKG_ID%TYPE,
                          p_DPL_PO       IN dkg_po_link.DPL_PO%TYPE,
                          p_DPL_DPR      IN dkg_po_link.DPL_DPR%TYPE)
    IS
    BEGIN
        INSERT INTO dkg_po_link (dpl_dkg_tp,
                                 dpl_dkg_id,
                                 dpl_po,
                                 dpl_dpr)
             VALUES (p_dpl_dkg_tp,
                     p_dpl_dkg_id,
                     p_dpl_po,
                     p_dpl_dpr);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX
        THEN
            IF (INSTR (SQLERRM, 'XAK_DKG_PO_LINK_DKG') > 0)
            THEN
                raise_application_error (
                    -20000,
                       'Для запису '
                    || p_DPL_DKG_ID
                    || ' вже створено платіжне доручення');
            ELSE
                RAISE;
            END IF;
    END;


    PROCEDURE GetLinkedDkgRows (
        p_DPR_DRT               IN     dkg_po_request.dpr_drt%TYPE,
        p_DPR_START_PERIOD_DT   IN     dkg_po_request.DPR_START_PERIOD_DT%TYPE,
        p_DPR_STOP_PERIOD_DT    IN     dkg_po_request.DPR_STOP_PERIOD_DT%TYPE,
        p_res                      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT l.*
              FROM dkg_po_link  l
                   JOIN dkg_po_request r ON l.dpl_dpr = r.dpr_id
             WHERE     r.com_org =
                       SYS_CONTEXT (ikis_finzvit_context.gContext,
                                    ikis_finzvit_context.gOPFU)
                   AND r.dpr_start_period_dt = p_DPR_START_PERIOD_DT
                   AND r.dpr_stop_period_dt = p_DPR_STOP_PERIOD_DT
                   AND r.DPR_DRT = p_DPR_DRT;
    END;
END FINZVIT_DKG_PO;
/