/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$DZR_ACT_PROVIDE
IS
    -- Author  : BOGDAN
    -- Created : 25.12.2024 16:36:27
    -- Purpose : Забезпечення ДЗР

    -- #113344: "Черга опрацювання звернень щодо ДЗР"
    /*PROCEDURE GET_QUEUE(p_start_dt IN DATE,
                        p_stop_dt IN DATE,
                        p_org_id IN NUMBER,
                        --p_aps_nst IN NUMBER,
                        p_ap_is_second IN VARCHAR2,
                        res_cur OUT SYS_REFCURSOR);*/

    -- #113397
    PROCEDURE GET_JOURNAL (P_PC_NUM        IN     VARCHAR2,
                           P_SC_UNIQUE     IN     VARCHAR2,
                           P_AT_DT_START   IN     DATE,
                           P_AT_DT_STOP    IN     DATE,
                           P_APP_LN        IN     VARCHAR2,
                           P_APP_FN        IN     VARCHAR2,
                           P_APP_MN        IN     VARCHAR2,
                           P_NUMIDENT      IN     VARCHAR2,
                           P_WRN_ID        IN     NUMBER,
                           P_WRN_SHIFR     IN     VARCHAR2,
                           ACT_CUR            OUT SYS_REFCURSOR);

    -- #113416
    PROCEDURE GET_SC_TAB (P_PC_ID     IN     VARCHAR2,
                          ACT_CUR        OUT SYS_REFCURSOR,
                          WARES_CUR      OUT SYS_REFCURSOR);

    -- Протокол обробки Виробів по заявці на ДЗР
    PROCEDURE GET_ACT_WARES_LOG (P_ATW_ID   IN     NUMBER,
                                 RES_CUR       OUT SYS_REFCURSOR);
END DNET$DZR_ACT_PROVIDE;
/


GRANT EXECUTE ON USS_ESR.DNET$DZR_ACT_PROVIDE TO DNET_PROXY
/


/* Formatted on 8/12/2025 5:49:29 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$DZR_ACT_PROVIDE
IS
    -- #113344: "Черга опрацювання звернень щодо ДЗР"
    PROCEDURE GET_QUEUE (p_start_dt       IN     DATE,
                         p_stop_dt        IN     DATE,
                         p_org_id         IN     NUMBER,
                         --p_aps_nst IN NUMBER,
                         p_ap_is_second   IN     VARCHAR2,
                         res_cur             OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.WriteMsg ('DNET$PAY_ASSIGNMENTS.' || $$PLSQL_UNIT);

        OPEN res_cur FOR
            SELECT t.*,
                   (SELECT dic_sname
                      FROM uss_ndi.v_ddn_ap_st z
                     WHERE z.DIC_VALUE = t.ap_st)
                       AS ap_st_name,
                   uss_person.api$sc_tools.GET_PIB_SCC (app.app_scc)
                       AS app_main_pib,
                   (SELECT LISTAGG (n.Nda_Name || ' ' || a.Apda_Val_String,
                                    ' ')
                           WITHIN GROUP (ORDER BY n.Nda_Order)
                      FROM Ap_Document_Attr  a
                           JOIN Ap_Document d
                               ON     a.Apda_Apd = d.Apd_Id
                                  AND d.Apd_Ndt = 600
                                  AND d.apd_app IN
                                          (SELECT p.app_id
                                             FROM v_ap_person p
                                            WHERE     p.app_ap = t.ap_id
                                                  AND p.app_tp =
                                                      CASE
                                                          WHEN t.ap_tp IN
                                                                   ('U', 'A')
                                                          THEN
                                                              'O'
                                                          ELSE
                                                              'Z'
                                                      END
                                                  AND p.app_sc = pc.pc_sc
                                                  AND p.history_status = 'A')
                                  AND d.History_Status = 'A'
                           JOIN Uss_Ndi.v_Ndi_Document_Attr n
                               ON a.Apda_Nda = n.Nda_Id AND n.Nda_Nng = 2
                     WHERE a.Apda_Ap = t.ap_id AND a.History_Status = 'A')
                       AS App_Main_Address,
                   /*(SELECT listagg(st.nst_code||'-'||nst_name, ', '||CHR(13)||CHR(10)) within GROUP (ORDER BY st.nst_order)
                      FROM v_ap_service z
                      JOIN uss_ndi.v_ndi_service_type st ON (st.nst_id = z.aps_nst)
                     WHERE z.aps_ap = t.ap_id
                       --rownum < 4
                       AND z.history_status = 'A'
                    ) AS Aps_List,*/
                   CASE
                       WHEN (SELECT COUNT (*)
                               FROM v_ap_service z
                              WHERE     z.aps_ap = t.ap_id
                                    AND z.aps_nst IN (923, 924)) >
                            0
                       THEN
                           'terminate'
                       ELSE
                           'default'
                   END
                       AS init_form
              FROM uss_esr.v_appeal  t
                   LEFT OUTER JOIN v_personalcase pc ON (pc.pc_id = t.ap_pc)
                   LEFT OUTER JOIN ap_person app
                       ON     app.app_sc = pc.pc_sc
                          AND app.app_ap = t.ap_id
                          AND app.history_status = 'A'
             WHERE     t.ap_st = 'O'
                   AND (ap_tp IN ('DD'))
                   AND TRUNC (t.ap_reg_dt) BETWEEN p_start_dt AND p_stop_dt
                   AND (   p_org_id IS NULL
                        OR t.com_org = p_org_id
                        OR t.ap_dest_org = p_org_id)
                   /* AND (p_aps_nst IS NULL OR EXISTS (SELECT *
                                                        FROM v_ap_service z
                                                       WHERE z.aps_ap = t.ap_id
                                                         AND z.aps_nst = p_aps_nst
                                                         AND z.history_status = 'A'))*/
                   AND (   p_ap_is_second IS NULL
                        OR p_ap_is_second = 'F'
                        OR t.ap_is_second = 'T');
    END;

    -- #113397
    PROCEDURE GET_JOURNAL (P_PC_NUM        IN     VARCHAR2,
                           P_SC_UNIQUE     IN     VARCHAR2,
                           P_AT_DT_START   IN     DATE,
                           P_AT_DT_STOP    IN     DATE,
                           P_APP_LN        IN     VARCHAR2,
                           P_APP_FN        IN     VARCHAR2,
                           P_APP_MN        IN     VARCHAR2,
                           P_NUMIDENT      IN     VARCHAR2,
                           P_WRN_ID        IN     NUMBER,
                           P_WRN_SHIFR     IN     VARCHAR2,
                           ACT_CUR            OUT SYS_REFCURSOR)
    IS
        l_org_to   NUMBER := tools.GetCurrOrgTo;
        l_org_id   NUMBER := tools.GetCurrOrg;
    BEGIN
        TOOLS.WRITEMSG ('DNET$DZR_ACT_PROVIDE.' || $$PLSQL_UNIT);

        OPEN ACT_CUR FOR
            SELECT T.*,
                   pc.pc_num,
                   pc.pc_sc,
                   sc.sc_unique,
                   USS_PERSON.API$SC_TOOLS.GET_PIB (T.AT_SC)
                       AS at_main_pib,
                   USS_PERSON.API$SC_TOOLS.get_numident (T.AT_SC)
                       AS At_Numident,
                   ap.ap_num,
                   src.DIC_NAME
                       AS at_src_name,
                   NVL (st.DIC_NAME, 'потрібен довідник')
                       AS at_st_name
              FROM V_ACT  T
                   JOIN V_PERSONALCASE PC ON (PC.PC_ID = T.AT_PC)
                   JOIN uss_person.v_socialcard sc ON (sc.sc_id = pc.pc_sc)
                   LEFT JOIN USS_NDI.V_DDN_AT_ST ST
                       ON (ST.DIC_VALUE = T.AT_ST)
                   LEFT JOIN USS_ESR.V_APPEAL AP ON (AP.AP_ID = T.AT_AP)
                   LEFT JOIN uss_ndi.v_ddn_ap_src src
                       ON (src.DIC_VALUE = t.at_src)
             WHERE     1 = 1
                   AND T.AT_TP = 'NDZR'
                   AND (   l_org_to = 81 AND pc.com_org = l_org_id
                        OR l_org_to NOT IN (81))
                   AND (P_PC_NUM IS NULL OR pc.pc_num = P_PC_NUM)
                   AND (   P_AT_DT_START IS NULL AND P_AT_DT_STOP IS NULL
                        OR     P_AT_DT_START IS NULL
                           AND P_AT_DT_STOP IS NOT NULL
                           AND T.AT_DT <= P_AT_DT_STOP
                        OR     P_AT_DT_START IS NOT NULL
                           AND P_AT_DT_STOP IS NULL
                           AND T.AT_DT >= P_AT_DT_START
                        OR T.AT_DT BETWEEN P_AT_DT_START AND P_AT_DT_STOP)
                   AND (       P_APP_LN IS NULL
                           AND P_APP_FN IS NULL
                           AND P_APP_MN IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM USS_PERSON.V_SOCIALCARD  ZS
                                       JOIN USS_PERSON.V_SC_CHANGE ZCH
                                           ON (ZCH.SCC_ID = ZS.SC_SCC)
                                       JOIN USS_PERSON.V_SC_IDENTITY ZI
                                           ON (ZI.SCI_ID = ZCH.SCC_SCI)
                                 WHERE     zs.sc_id = pc.pc_sc
                                       AND (   P_APP_LN IS NULL
                                            OR UPPER (ZI.SCI_LN) LIKE
                                                      UPPER (TRIM (P_APP_LN))
                                                   || '%')
                                       AND (   P_APP_FN IS NULL
                                            OR UPPER (ZI.SCI_FN) LIKE
                                                      UPPER (TRIM (P_APP_FN))
                                                   || '%')
                                       AND (   P_APP_MN IS NULL
                                            OR UPPER (ZI.SCI_MN) LIKE
                                                      UPPER (TRIM (P_APP_MN))
                                                   || '%')))
                   AND (   P_WRN_ID IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM at_wares zw
                                 WHERE     zw.atw_at = t.at_id
                                       AND zw.atw_wrn = P_WRN_ID))
                   AND (   P_WRN_SHIFR IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM at_wares  zw
                                       JOIN uss_ndi.v_NDI_CBI_WARES w
                                           ON (w.wrn_id = zw.atw_wrn)
                                 WHERE     zw.atw_at = t.at_id
                                       AND w.wrn_shifr LIKE
                                               P_WRN_SHIFR || '%'))
                   AND (   P_NUMIDENT IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM V_AP_PERSON  ZZ
                                       JOIN USS_PERSON.V_SOCIALCARD ZS
                                           ON (ZS.SC_ID = ZZ.APP_SC)
                                       JOIN USS_PERSON.V_SC_DOCUMENT SD
                                           ON (    PC.PC_SC = SD.SCD_SC
                                               AND (SD.SCD_NDT = 5))
                                 WHERE     ZZ.APP_AP = AP.AP_ID
                                       AND SD.SCD_NUMBER = P_NUMIDENT));
    END;

    -- #113416
    PROCEDURE GET_SC_TAB (P_PC_ID     IN     VARCHAR2,
                          ACT_CUR        OUT SYS_REFCURSOR,
                          WARES_CUR      OUT SYS_REFCURSOR)
    IS
    BEGIN
        TOOLS.WRITEMSG ('DNET$DZR_ACT_PROVIDE.' || $$PLSQL_UNIT);

        OPEN ACT_CUR FOR
            SELECT T.*,
                   pc.pc_num,
                   pc.pc_sc,
                   sc.sc_unique,
                   USS_PERSON.API$SC_TOOLS.GET_PIB (T.AT_SC)
                       AS at_main_pib,
                   USS_PERSON.API$SC_TOOLS.get_numident (T.AT_SC)
                       AS At_Numident,
                   ap.ap_num,
                   src.DIC_NAME
                       AS at_src_name,
                   NVL (st.DIC_NAME, 'потрібен довідник')
                       AS at_st_name
              FROM V_ACT  T
                   JOIN V_PERSONALCASE PC ON (PC.PC_ID = T.AT_PC)
                   JOIN uss_person.v_socialcard sc ON (sc.sc_id = pc.pc_sc)
                   LEFT JOIN USS_NDI.V_DDN_AT_ST ST
                       ON (ST.DIC_VALUE = T.AT_ST)
                   LEFT JOIN USS_ESR.V_APPEAL AP ON (AP.AP_ID = T.AT_AP)
                   LEFT JOIN uss_ndi.v_ddn_ap_src src
                       ON (src.DIC_VALUE = t.at_src)
             WHERE 1 = 1 AND T.AT_TP = 'NDZR' AND t.at_pc = P_PC_ID;

        OPEN wares_cur FOR
            SELECT t.*,
                   w.wrn_shifr || ' ' || w.wrn_name     AS atw_wrn_name,
                   st.dic_name                          AS atw_st_name
              FROM at_wares  t
                   JOIN act a ON (a.at_id = t.atw_at)
                   JOIN uss_ndi.v_ndi_cbi_wares w ON (w.wrn_id = t.atw_wrn)
                   JOIN uss_ndi.v_ddn_atw_st st ON (st.dic_value = t.atw_st)
             WHERE a.at_pc = p_pc_id AND t.history_status = 'A';
    END;

    -- Протокол обробки Виробів по заявці на ДЗР
    PROCEDURE GET_ACT_WARES_LOG (P_ATW_ID   IN     NUMBER,
                                 RES_CUR       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN RES_CUR FOR
              SELECT T.ATWL_ID
                         AS LOG_ID,
                     T.ATWL_ATW
                         AS LOG_OBJ,
                     T.ATWL_TP
                         AS LOG_TP,
                     ST.DIC_NAME
                         AS LOG_ST_NAME,
                     STO.DIC_NAME
                         AS LOG_ST_OLD_NAME,
                     HS.HS_DT
                         AS LOG_HS_DT,
                     NVL (TOOLS.GETUSERLOGIN (HS.HS_WU), 'Автоматично')
                         AS LOG_HS_AUTHOR,
                     USS_NDI.RDM$MSG_TEMPLATE.GETMESSAGETEXT (T.ATWL_MESSAGE)
                         AS LOG_MESSAGE
                FROM ATW_LOG T
                     LEFT JOIN USS_NDI.V_DDN_ATW_ST ST
                         ON (ST.DIC_VALUE = T.ATWL_ST)
                     LEFT JOIN USS_NDI.V_DDN_ATW_ST STO
                         ON (STO.DIC_VALUE = T.ATWL_ST_OLD)
                     LEFT JOIN V_HISTSESSION HS ON (HS.HS_ID = T.ATWL_HS)
               WHERE T.ATWL_ATW = P_ATW_ID
            ORDER BY HS.HS_DT;
    END;
BEGIN
    NULL;
END DNET$DZR_ACT_PROVIDE;
/