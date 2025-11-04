/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$PAY_DEDUCTIONS
IS
    PROCEDURE get_queue (p_start_dt   IN     DATE,
                         p_stop_dt    IN     DATE,
                         p_org_id     IN     NUMBER,
                         p_aps_nst    IN     NUMBER,
                         res_cur         OUT SYS_REFCURSOR);
END dnet$pay_deductions;
/


GRANT EXECUTE ON USS_ESR.DNET$PAY_DEDUCTIONS TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$PAY_DEDUCTIONS TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:42 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$PAY_DEDUCTIONS
IS
    /*PROCEDURE get_queue(p_start_dt IN DATE,
                        p_stop_dt  IN DATE,
                        p_org_id   IN NUMBER,
                        p_aps_nst  IN NUMBER,
                        res_cur    OUT SYS_REFCURSOR) IS
    BEGIN
      OPEN res_cur FOR
        SELECT t.*, uss_person.api$sc_tools.get_pib(pc.pc_sc) AS ap_main_pib,
               pc.pc_num AS ap_pc_num
        FROM uss_esr.v_appeal t
        left JOIN v_personalcase pc
        ON (pc.pc_id = t.ap_pc)
        WHERE trunc(t.ap_reg_dt) BETWEEN p_start_dt AND p_stop_dt
        AND (p_org_id IS NULL OR t.com_org = p_org_id)
        AND ( p_aps_nst is null and ( EXISTS (
        SELECT *
        FROM  uss_ndi.v_ndi_service_type st
        WHERE st.history_status = 'A'
        AND st.nst_id IN (621, 603, 602, 601, 600)))
                OR p_aps_nst is not null and (EXISTS (SELECT *
                FROM v_ap_service z
                WHERE z.aps_ap = t.ap_id
                AND z.aps_nst = p_aps_nst
                AND z.history_status = 'A')));

    END;*/

    PROCEDURE get_queue (p_start_dt   IN     DATE,
                         p_stop_dt    IN     DATE,
                         p_org_id     IN     NUMBER,
                         p_aps_nst    IN     NUMBER,
                         res_cur         OUT SYS_REFCURSOR)
    IS
        l_cnt   INTEGER;
    BEGIN
        /*  ikis_sysweb.ikis_debug_pipe.WriteMsg('p_start_dt='||p_start_dt);
          ikis_sysweb.ikis_debug_pipe.WriteMsg('p_stop_dt='||p_stop_dt);
          ikis_sysweb.ikis_debug_pipe.WriteMsg('p_org_id='||p_org_id);
          ikis_sysweb.ikis_debug_pipe.WriteMsg('p_aps_nst='||p_aps_nst);
        */
        tools.WriteMsg ('DNET$PAY_DEDUCTIONS.' || $$PLSQL_UNIT);

        OPEN res_cur FOR
            SELECT t.*,
                   uss_person.api$sc_tools.GET_PIB_SCC (
                       app.app_scc)                 AS ap_main_pib,
                   pc.pc_num                        AS ap_pc_num,
                   pc.pc_id                         AS ap_pc_id,
                   (SELECT MAX (
                                  nst.nst_code
                               || ' '
                               || nst.nst_name)
                      FROM v_ap_service                srv,
                           uss_ndi.v_ndi_service_type  nst
                     WHERE     aps_ap = ap_id
                           AND nst_ap_tp IN ('A', 'O'               /* , 'U'*/
                                                     )
                           AND srv.history_status = 'A'
                           AND aps_nst = nst_id)    AS nst_Name
              FROM uss_esr.v_appeal  t
                   JOIN v_personalcase pc ON pc.pc_id = t.ap_pc
                   JOIN ap_person app
                       ON     app.app_sc = pc.pc_sc
                          AND app.app_ap = t.ap_id
                          AND app.history_status = 'A'
             WHERE     ap_tp IN ('A', 'O')                 --#78670 2022.07.20
                   AND ap_st = 'O'
                   AND TRUNC (t.ap_reg_dt) BETWEEN p_start_dt AND p_stop_dt
                   AND (p_org_id IS NULL OR t.com_org = p_org_id)
                   AND (   p_aps_nst IS NULL
                        OR EXISTS
                               (SELECT 1
                                  FROM v_ap_service                srv,
                                       uss_ndi.v_ndi_service_type  nst
                                 WHERE     aps_ap = ap_id
                                       AND nst_ap_tp IN ('A', 'O'   /* , 'U'*/
                                                                 )
                                       AND srv.history_status = 'A'
                                       AND aps_nst = nst_id))
                   -- #88619 (прибрав звернення з послугами, які використовуються в черзі на призначення)
                   AND NOT EXISTS
                           (SELECT *
                              FROM v_ap_service z
                             WHERE     z.aps_ap = t.ap_id
                                   AND z.aps_nst IN (643,
                                                     645,
                                                     801,
                                                     923,
                                                     924,
                                                     1161)
                                   AND z.history_status = 'A');
    /*AND (p_aps_nst is null
                   and EXISTS (SELECT *
                                 FROM v_ap_service z
                                WHERE z.aps_ap = t.ap_id
                                  AND z.aps_nst IN (621, 603, 602, 601, 600)
                                  AND z.history_status = 'A')
         OR p_aps_nst IS NOT NULL
                   and EXISTS (SELECT *
                                 FROM v_ap_service z
                                WHERE z.aps_ap = t.ap_id
                                  AND z.aps_nst = p_aps_nst
                                  AND z.history_status = 'A')
        );*/

    END;
END dnet$pay_deductions;
/