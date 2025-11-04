/* Formatted on 8/12/2025 6:06:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_FINZVIT.FINZVIT_PPVP_PO
IS
    -- Author  : MAXYM
    -- Created : 11.09.2018 9:37:57
    -- Purpose :

    PROCEDURE InsertRequest (
        p_PPR_PRT             ppvp_po_request.PPR_PRT%TYPE,
        p_PPR_PR_TP           ppvp_po_request.PPR_PR_TP%TYPE,
        p_PPR_YEAR            ppvp_po_request.PPR_YEAR%TYPE,
        p_PPR_MONTH           ppvp_po_request.PPR_MONTH%TYPE,
        p_PPR_DAY_START       ppvp_po_request.PPR_DAY_START%TYPE,
        p_PPR_DAY_END         ppvp_po_request.PPR_DAY_END%TYPE,
        p_PPR_DEST_ORG        ppvp_po_request.PPR_DEST_ORG%TYPE,
        p_PPR_REG_OPFU        ppvp_po_request.PPR_REG_OPFU%TYPE,
        p_NEW_PPR_ID      OUT ppvp_po_request.ppr_id%TYPE);

    PROCEDURE InsertLink (p_PPL_PPVP_ID   IN ppvp_po_link.PPL_PPVP_ID%TYPE,
                          p_PPL_PPR       IN ppvp_po_link.PPL_PPR%TYPE,
                          p_PPL_PO        IN ppvp_po_link.PPL_PO%TYPE);

    PROCEDURE GetLinkedPpvpRows (
        p_PPR_PRT         ppvp_po_request.ppr_prt%TYPE,
        p_PPR_YEAR        ppvp_po_request.PPR_YEAR%TYPE,
        p_PPR_MONTH       ppvp_po_request.PPR_MONTH%TYPE,
        p_res         OUT SYS_REFCURSOR);
END FINZVIT_PPVP_PO;
/


GRANT EXECUTE ON IKIS_FINZVIT.FINZVIT_PPVP_PO TO DNET_PROXY
/


/* Formatted on 8/12/2025 6:06:33 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_FINZVIT.FINZVIT_PPVP_PO
IS
    PROCEDURE InsertRequest (
        p_PPR_PRT             ppvp_po_request.PPR_PRT%TYPE,
        p_PPR_PR_TP           ppvp_po_request.PPR_PR_TP%TYPE,
        p_PPR_YEAR            ppvp_po_request.PPR_YEAR%TYPE,
        p_PPR_MONTH           ppvp_po_request.PPR_MONTH%TYPE,
        p_PPR_DAY_START       ppvp_po_request.PPR_DAY_START%TYPE,
        p_PPR_DAY_END         ppvp_po_request.PPR_DAY_END%TYPE,
        p_PPR_DEST_ORG        ppvp_po_request.PPR_DEST_ORG%TYPE,
        p_PPR_REG_OPFU        ppvp_po_request.PPR_REG_OPFU%TYPE,
        p_NEW_PPR_ID      OUT ppvp_po_request.ppr_id%TYPE)
    IS
    BEGIN
        INSERT INTO ppvp_po_request (ppr_create_dt,
                                     com_org,
                                     com_wu,
                                     ppr_prt,
                                     ppr_pr_tp,
                                     ppr_year,
                                     ppr_month,
                                     ppr_day_start,
                                     ppr_day_end,
                                     ppr_dest_org,
                                     PPR_REG_OPFU)
             VALUES (
                        SYSDATE,
                        SYS_CONTEXT (ikis_finzvit_context.gContext,
                                     ikis_finzvit_context.gOPFU),
                        SYS_CONTEXT (ikis_finzvit_context.gContext,
                                     ikis_finzvit_context.gUID),
                        p_ppr_prt,
                        p_ppr_pr_tp,
                        p_ppr_year,
                        p_ppr_month,
                        p_ppr_day_start,
                        p_ppr_day_end,
                        p_ppr_dest_org,
                        p_PPR_REG_OPFU)
          RETURNING ppr_id
               INTO p_NEW_PPR_ID;
    END;

    PROCEDURE InsertLink (p_PPL_PPVP_ID   IN ppvp_po_link.PPL_PPVP_ID%TYPE,
                          p_PPL_PPR       IN ppvp_po_link.PPL_PPR%TYPE,
                          p_PPL_PO        IN ppvp_po_link.PPL_PO%TYPE)
    IS
    BEGIN
        INSERT INTO ppvp_po_link (ppl_ppvp_id, ppl_ppr, ppl_po)
             VALUES (p_ppl_ppvp_id, p_ppl_ppr, p_ppl_po);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX
        THEN
            IF (INSTR (SQLERRM, 'XAK_PPVP_PO_LINK_PPVP') > 0)
            THEN
                raise_application_error (
                    -20000,
                       'Для запису '
                    || p_PPL_PPVP_ID
                    || ' вже створено платіжне доручення');
            ELSE
                RAISE;
            END IF;
    END;

    PROCEDURE GetLinkedPpvpRows (
        p_PPR_PRT         ppvp_po_request.ppr_prt%TYPE,
        p_PPR_YEAR        ppvp_po_request.PPR_YEAR%TYPE,
        p_PPR_MONTH       ppvp_po_request.PPR_MONTH%TYPE,
        p_res         OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT l.ppl_ppvp_id
              FROM ppvp_po_link  l
                   JOIN ppvp_po_request r ON l.ppl_ppr = r.ppr_id
             WHERE     r.com_org =
                       SYS_CONTEXT (ikis_finzvit_context.gContext,
                                    ikis_finzvit_context.gOPFU)
                   AND r.ppr_year = p_PPR_YEAR
                   AND r.ppr_month = p_PPR_month
                   AND r.PPR_PRT = p_PPR_PRT;
    END;
END FINZVIT_PPVP_PO;
/