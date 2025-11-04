/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$PAY_TERMINATE
IS
    -- Author  : BOGDAN
    -- Created : 17.05.2023 13:01:05
    -- Purpose : Рішення про припинення

    Package_Name   VARCHAR2 (100) := 'DNET$PAY_TERMINATE';

    TYPE r_At_Document_Attr IS RECORD
    (
        Atda_Id            AT_DOCUMENT_ATTR.ATDA_ID%TYPE,
        Atda_Atd           AT_DOCUMENT_ATTR.ATDA_ATD%TYPE,
        Atda_At            AT_DOCUMENT_ATTR.ATDA_AT%TYPE,
        Atda_Nda           AT_DOCUMENT_ATTR.ATDA_NDA%TYPE,
        Atda_Val_Int       AT_DOCUMENT_ATTR.ATDA_VAL_INT%TYPE,
        Atda_Val_Sum       AT_DOCUMENT_ATTR.ATDA_VAL_SUM%TYPE,
        Atda_Val_Id        AT_DOCUMENT_ATTR.ATDA_VAL_ID%TYPE,
        Atda_Val_Dt        TIMESTAMP,
        Atda_Val_String    AT_DOCUMENT_ATTR.ATDA_VAL_STRING%TYPE,
        Deleted            NUMBER
    );

    TYPE t_At_Document_Attrs IS TABLE OF r_At_Document_Attr;

    -- Перевірка права
    TYPE r_At_Right_Log IS RECORD
    (
        Arl_Id             At_Right_Log.Arl_Id%TYPE,
        Arl_Nrr            At_Right_Log.Arl_Nrr%TYPE,
        Arl_Calc_Result    At_Right_Log.Arl_Calc_Result%TYPE,
        Arl_Result         At_Right_Log.Arl_Result%TYPE
    );

    TYPE t_At_Right_Log IS TABLE OF r_At_Right_Log;

    -- #87326: Черга звернень на припинення надання СП
    PROCEDURE GET_QUEUE_R (p_start_dt       IN     DATE,
                           p_stop_dt        IN     DATE,
                           p_org_id         IN     NUMBER,
                           p_aps_nst        IN     NUMBER,
                           p_ap_is_second   IN     VARCHAR2,
                           P_IS_SCHOOL      IN     VARCHAR2,
                           res_cur             OUT SYS_REFCURSOR);

    -- #87417
    PROCEDURE get_act_journal (p_ap_id             IN     NUMBER,
                               p_ap_reg_dt_start   IN     DATE,
                               p_ap_reg_dt_stop    IN     DATE,
                               p_at_dt_start       IN     DATE,
                               p_at_dt_stop        IN     DATE,
                               p_org_id            IN     NUMBER,
                               p_pc_num            IN     VARCHAR2,
                               p_ap_num            IN     VARCHAR2,
                               p_at_num            IN     VARCHAR2,
                               p_pc_rnokpp         IN     VARCHAR2,
                               p_at_rnp            IN     NUMBER,
                               p_at_st             IN     VARCHAR2,
                               appeal_info            OUT SYS_REFCURSOR,
                               res_cur                OUT SYS_REFCURSOR);

    -- #87417: Рішення про припинення допомоги
    PROCEDURE get_act_card (p_at_id    IN     NUMBER,
                            info_cur      OUT SYS_REFCURSOR,
                            dec_cur       OUT SYS_REFCURSOR,
                            serv_cur      OUT SYS_REFCURSOR,
                            doc_cur       OUT SYS_REFCURSOR,
                            attr_cur      OUT SYS_REFCURSOR,
                            file_cur      OUT SYS_REFCURSOR);

    -- #87273
    FUNCTION can_approve_act (p_at_id IN NUMBER)
        RETURN VARCHAR2;

    -- #87269
    PROCEDURE get_ss_act_journal (p_ap_id             IN     NUMBER,
                                  p_ap_reg_dt_start   IN     DATE,
                                  p_ap_reg_dt_stop    IN     DATE,
                                  p_at_dt_start       IN     DATE,
                                  p_at_dt_stop        IN     DATE,
                                  p_org_id            IN     NUMBER,
                                  p_pc_num            IN     VARCHAR2,
                                  p_ap_num            IN     VARCHAR2,
                                  p_at_num            IN     VARCHAR2,
                                  p_pc_rnokpp         IN     VARCHAR2,
                                  p_at_rnp            IN     NUMBER,
                                  p_at_st             IN     VARCHAR2,
                                  appeal_info            OUT SYS_REFCURSOR,
                                  res_cur                OUT SYS_REFCURSOR);

    -- #87270: Рішення про припинення СП
    PROCEDURE get_ss_act_card (p_at_id    IN     NUMBER,
                               info_cur      OUT SYS_REFCURSOR,
                               dec_cur       OUT SYS_REFCURSOR,
                               serv_cur      OUT SYS_REFCURSOR,
                               doc_cur       OUT SYS_REFCURSOR,
                               attr_cur      OUT SYS_REFCURSOR,
                               file_cur      OUT SYS_REFCURSOR);

    -- інформація по рішенню СП
    PROCEDURE get_decision_card_SS (p_pd_id   IN     NUMBER,
                                    dec_cur      OUT SYS_REFCURSOR);

    -- ініціалізація акту по зверненню (з послугою 923)
    PROCEDURE init_act_by_appeal_923 (p_ap_id          appeal.ap_id%TYPE,
                                      p_messages   OUT SYS_REFCURSOR);

    -- ініціалізація акту по зверненню
    PROCEDURE init_act_by_appeal (p_ap_id          appeal.ap_id%TYPE,
                                  p_messages   OUT SYS_REFCURSOR);


    -- #87272: список документів які можна створити
    PROCEDURE get_doc_tp_list (p_at_id IN NUMBER, res_cur OUT SYS_REFCURSOR);

    -- #87272: збереження документу
    PROCEDURE save_Document (p_atd_id          IN OUT NUMBER,
                             p_ATD_AT          IN     AT_DOCUMENT.ATD_AT%TYPE,
                             p_ATD_NDT         IN     AT_DOCUMENT.ATD_NDT%TYPE,
                             p_ATD_ATS         IN     AT_DOCUMENT.ATD_ATS%TYPE,
                             p_ATD_DOC         IN     AT_DOCUMENT.ATD_DOC%TYPE,
                             p_ATD_DH          IN     AT_DOCUMENT.ATD_DH%TYPE,
                             P_ATTR_XML        IN     CLOB,
                             p_FILE_XML        IN     CLOB,
                             p_create_signer   IN     VARCHAR2);

    -- #87271: дані форми визначення права
    PROCEDURE GET_ACT_RIGHTS (P_AT_ID NUMBER, RES_CUR OUT SYS_REFCURSOR);

    -- ініціалізація визначення права
    PROCEDURE INIT_ACT_RIGHTS (p_at_id          act.at_id%TYPE,
                               p_messages   OUT SYS_REFCURSOR);

    -- #70334: збереження форми визначення права
    PROCEDURE SAVE_ACT_RIGHTS (P_AT_ID   IN NUMBER,
                               P_AT_ST   IN VARCHAR2,
                               P_CLOB    IN CLOB);

    -- #87272: список документів по акту
    PROCEDURE get_ss_docs (p_at_id    IN     NUMBER,
                           p_flag        OUT NUMBER,
                           doc_cur       OUT SYS_REFCURSOR,
                           attr_cur      OUT SYS_REFCURSOR,
                           file_cur      OUT SYS_REFCURSOR,
                           sign_cur      OUT SYS_REFCURSOR);

    -- #87272: видалення документу
    PROCEDURE delete_document (p_atd_Id IN NUMBER);

    -- #87272: додавання підписанта до документу
    PROCEDURE add_signer (p_atd_id   IN NUMBER,
                          p_at_id    IN NUMBER,
                          p_wu_id    IN NUMBER DEFAULT NULL);

    -- #87272: проставлення ознаки підпису документа користувачем
    PROCEDURE set_doc_signed (p_atd_id IN NUMBER, p_file_code IN VARCHAR2);

    -- #87272: створення вкладення для документу
    PROCEDURE create_doc_attach (p_atd_id IN NUMBER, p_blob OUT BLOB);


    -- #87272:
    PROCEDURE get_sign_attach_info (p_atd_id   IN     NUMBER,
                                    res_cur       OUT SYS_REFCURSOR);

    -- перевірка на консистентність даних
    PROCEDURE check_consistensy (P_AT_ID IN NUMBER, P_AT_ST IN VARCHAR2);

    --====================================================--
    -- #87417: затвердити act допомоги
    --====================================================--
    PROCEDURE approve_act (p_at_id NUMBER, p_at_st VARCHAR2);

    --====================================================--
    -- #87417: Поверенення акту допомоги на доопрацювання
    --====================================================--
    PROCEDURE return_act (p_at_id NUMBER, p_at_st VARCHAR2);

    --====================================================--
    -- #87417: Відхилення акту допомоги
    --====================================================--
    PROCEDURE reject_act (p_at_id NUMBER, p_at_st VARCHAR2);

    --====================================================--
    -- #86960, #87522: затвердити act
    --====================================================--
    PROCEDURE approve_ss_act (p_at_id NUMBER, p_at_st VARCHAR2);

    --====================================================--
    -- #86960, #87522: Поверенення акту на доопрацювання
    --====================================================--
    PROCEDURE return_ss_act (p_at_id    NUMBER,
                             p_reason   VARCHAR2,
                             p_at_st    VARCHAR2);

    --підписант акта p_order = 1 - перший підпеисант 2-другий підписант
    FUNCTION get_at_signers (p_at_id   NUMBER,
                             p_order   NUMBER,
                             p_ndt     NUMBER:= NULL)
        RETURN NUMBER;
END DNET$PAY_TERMINATE;
/


GRANT EXECUTE ON USS_ESR.DNET$PAY_TERMINATE TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$PAY_TERMINATE TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$PAY_TERMINATE
IS
    -- #87326: Черга звернень на припинення надання СП
    PROCEDURE GET_QUEUE_R (p_start_dt       IN     DATE,
                           p_stop_dt        IN     DATE,
                           p_org_id         IN     NUMBER,
                           p_aps_nst        IN     NUMBER,
                           p_ap_is_second   IN     VARCHAR2,
                           P_IS_SCHOOL      IN     VARCHAR2,
                           res_cur             OUT SYS_REFCURSOR)
    IS
        l_org_id   NUMBER;
        l_org_to   NUMBER;
    BEGIN
        l_org_id := tools.GetCurrOrg;
        l_org_to := tools.GetCurrOrgto;
        --raise_application_error(-20000, '  p_org_id='||p_org_id||'  l_org_id='||l_org_id||'  l_org_to='||l_org_to||'  P_IS_SCHOOL='||P_IS_SCHOOL);
        tools.WriteMsg ('DNET$PAY_TERMINATE.GET_QUEUE_R');

        Tools.LOG (
            p_src      => 'USS_ESR.DNET$PAY_TERMINATE.GET_QUEUE_R',
            p_obj_tp   => NULL,
            p_obj_id   => NULL,
            p_regular_params   =>
                   ' p_start_dt='
                || p_start_dt
                || ' p_stop_dt='
                || p_stop_dt
                || ' p_org_id='
                || p_org_id
                || ' p_aps_nst='
                || p_aps_nst
                || ' p_ap_is_second='
                || p_ap_is_second
                || ' P_IS_SCHOOL='
                || P_IS_SCHOOL
                || ' l_org_id='
                || l_org_id
                || ' l_org_to='
                || l_org_to);


        OPEN res_cur FOR
            SELECT t.*,
                   (SELECT dic_sname
                      FROM uss_ndi.v_ddn_ap_st z
                     WHERE z.DIC_VALUE = t.ap_st)
                       AS ap_st_name,
                   uss_person.api$sc_tools.GET_PIB_SCC (app.app_scc)
                       AS app_main_pib,
                   tools.get_main_addr_ss (t.ap_id, t.ap_tp, pc.pc_sc)
                       AS App_Main_Address,
                   (SELECT LISTAGG (st.nst_code || '-' || nst_name,
                                    ', ' || CHR (13) || CHR (10))
                           WITHIN GROUP (ORDER BY st.nst_order)
                      FROM v_ap_service  z
                           JOIN uss_ndi.v_ndi_service_type st
                               ON (st.nst_id = z.aps_nst)
                     WHERE z.aps_ap = t.ap_id --rownum < 4
                                              AND z.history_status = 'A')
                       AS Aps_List,
                   (CASE
                        WHEN EXISTS
                                 (SELECT a.apda_id
                                    FROM ap_document_attr  a
                                         JOIN ap_document d
                                             ON a.apda_apd = d.apd_id
                                   WHERE     a.apda_ap = t.ap_id
                                         AND (   (    d.apd_ndt = 801
                                                  AND a.apda_nda = 1870)
                                              OR (    d.apd_ndt = 802
                                                  AND a.apda_nda = 1947)
                                              OR (    d.apd_ndt = 803
                                                  AND a.apda_nda = 2032))
                                         AND a.apda_val_string = 'T')
                        THEN
                            1
                        ELSE
                            0
                    END)
                       AS is_Emergency
              FROM uss_esr.v_appeal  t
                   LEFT OUTER JOIN v_personalcase pc ON (pc.pc_id = t.ap_pc)
                   LEFT OUTER JOIN ap_person app
                       ON     app.app_sc = pc.pc_sc
                          AND app.app_ap = t.ap_id
                          AND app.history_status = 'A'
             WHERE     (   (    P_IS_SCHOOL = 'T'
                            AND t.ap_st = 'WD'
                            AND EXISTS
                                    (SELECT 1
                                       FROM v_Pc_Decision dc
                                      WHERE     dc.pd_ap = t.ap_id
                                            AND dc.pd_st = 'O.S')
                            AND t.com_org IN
                                    (    SELECT t.org_id
                                           FROM v_opfu t
                                          WHERE t.org_st = 'A'
                                     CONNECT BY PRIOR t.org_id = t.org_org
                                     START WITH t.org_id = l_org_id)
                            AND (p_org_id IS NULL OR t.com_org = p_org_id))
                        OR (    P_IS_SCHOOL = 'F'
                            AND t.ap_st = 'O'
                            AND t.com_org = l_org_id))
                   AND ap_tp IN ('R.OS', 'R.GS')
                   AND TRUNC (t.ap_reg_dt) BETWEEN p_start_dt AND p_stop_dt
                   AND (   p_aps_nst IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM v_ap_service z
                                 WHERE     z.aps_ap = t.ap_id
                                       AND z.aps_nst = p_aps_nst
                                       AND z.history_status = 'A'))
                   AND (   p_ap_is_second IS NULL
                        OR p_ap_is_second = 'F'
                        OR t.ap_is_second = 'T');
    --raise_application_error(-20000, 'res_cur.count'||res_cur%ROWCOUNT);
    END;

    -- #87417
    PROCEDURE get_act_journal (p_ap_id             IN     NUMBER,
                               p_ap_reg_dt_start   IN     DATE,
                               p_ap_reg_dt_stop    IN     DATE,
                               p_at_dt_start       IN     DATE,
                               p_at_dt_stop        IN     DATE,
                               p_org_id            IN     NUMBER,
                               p_pc_num            IN     VARCHAR2,
                               p_ap_num            IN     VARCHAR2,
                               p_at_num            IN     VARCHAR2,
                               p_pc_rnokpp         IN     VARCHAR2,
                               p_at_rnp            IN     NUMBER,
                               p_at_st             IN     VARCHAR2,
                               appeal_info            OUT SYS_REFCURSOR,
                               res_cur                OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN appeal_info FOR
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
                       AS App_Main_Address
              /* ,CASE WHEN (t.ap_tp IN ('V', 'U') OR (t.ap_tp IN ('O') AND EXISTS (SELECT * FROM v_ap_service z WHERE z.aps_ap = t.ap_id AND z.aps_nst IN (643,645,801) AND z.history_status = 'A')))
                       THEN 'decision'
                     WHEN ap_tp IN ('A' , 'O') THEN 'deduction'
                 END AS card_tp*/
              FROM uss_esr.v_appeal  t
                   LEFT OUTER JOIN v_personalcase pc ON (pc.pc_id = t.ap_pc)
                   LEFT OUTER JOIN ap_person app
                       ON     app.app_sc = pc.pc_sc
                          AND app.app_ap = t.ap_id
                          AND app.history_status = 'A'
             WHERE t.ap_id = P_AP_ID;


        OPEN res_cur FOR
            SELECT t.*,
                   p.pc_num,
                   ap.ap_num,
                   ap.ap_reg_dt,
                   src.DIC_NAME
                       AS ap_src_name,
                   st.DIC_NAME
                       AS at_st_name,
                   uss_person.api$sc_tools.GET_PIB (p.pc_sc)
                       AS pc_pib,
                   --uss_person.api$sc_tools.GET_PIB_SCC(pm.pdm_scc) AS pc_main_pib,
                   uss_person.api$sc_tools.get_numident (p.pc_sc)
                       AS Pc_Rnokpp,
                   r.rnp_name
                       AS At_Rnp_Name
              FROM v_act  t
                   LEFT OUTER JOIN v_personalcase p ON (p.pc_id = t.at_pc)
                   LEFT JOIN v_appeal ap
                       ON (    ap.ap_id = t.at_ap
                           AND (p_org_id IS NULL OR ap.com_org = p_org_id))
                   LEFT JOIN uss_ndi.V_DDN_RSTOPV_ST st
                       ON (st.DIC_VALUE = t.at_st)
                   LEFT JOIN uss_ndi.v_ddn_ap_src src
                       ON (src.DIC_VALUE = ap.ap_src)
                   LEFT JOIN uss_ndi.v_ndi_reason_not_pay r
                       ON (r.rnp_id = t.at_rnp)
             WHERE     1 = 1
                   AND at_tp = 'RSTOPV'
                   AND (P_AP_ID IS NULL OR t.at_ap = P_AP_ID)
                   AND (   p_ap_reg_dt_start IS NULL
                        OR ap.ap_reg_dt >= p_ap_reg_dt_start)
                   AND (   p_ap_reg_dt_stop IS NULL
                        OR ap.ap_reg_dt <= p_ap_reg_dt_stop)
                   AND (p_at_dt_start IS NULL OR t.at_dt >= p_at_dt_start)
                   AND (p_at_dt_stop IS NULL OR t.at_dt <= p_at_dt_stop)
                   AND (p_at_num IS NULL OR t.at_num LIKE p_at_num || '%')
                   AND (p_ap_num IS NULL OR ap.ap_num LIKE p_ap_num || '%')
                   AND (p_pc_num IS NULL OR p.pc_num LIKE p_pc_num || '%')
                   AND (p_at_rnp IS NULL OR t.at_rnp = p_at_rnp)
                   AND (p_at_st IS NULL OR t.at_st = p_at_st)
                   AND (   p_pc_rnokpp IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM uss_person.v_sc_document sd
                                 WHERE     sd.scd_ndt = 5
                                       AND sd.scd_sc = p.pc_sc
                                       AND sd.scd_st IN ('A', '1')
                                       AND sd.scd_number = p_pc_rnokpp));
    END;

    -- #87417: Рішення про припинення допомоги
    PROCEDURE get_act_card (p_at_id    IN     NUMBER,
                            info_cur      OUT SYS_REFCURSOR,
                            dec_cur       OUT SYS_REFCURSOR,
                            serv_cur      OUT SYS_REFCURSOR,
                            doc_cur       OUT SYS_REFCURSOR,
                            attr_cur      OUT SYS_REFCURSOR,
                            file_cur      OUT SYS_REFCURSOR)
    IS
        l_act   act%ROWTYPE;
    BEGIN
        SELECT *
          INTO l_act
          FROM act
         WHERE at_id = p_at_id;

        OPEN info_cur FOR
            SELECT t.*,
                   p.pc_num,
                   p.pc_sc,
                   ap.ap_num,
                   ap.ap_tp,
                   ap.ap_reg_dt,
                   st.DIC_NAME
                       AS at_st_name,
                   src.DIC_NAME
                       AS ap_src_name,
                   uss_person.api$sc_tools.GET_PIB (p.pc_sc)
                       AS pc_pib,
                   uss_person.api$sc_tools.get_numident (p.pc_sc)
                       AS Pc_Rnokpp,
                   r.rnp_name
                       AS At_Rnp_Name
              FROM v_act  t
                   LEFT OUTER JOIN v_personalcase p ON (p.pc_id = t.at_pc)
                   LEFT JOIN v_appeal ap ON (ap.ap_id = t.at_ap)
                   LEFT JOIN uss_ndi.V_DDN_RSTOPV_ST st
                       ON (st.DIC_VALUE = t.at_st)
                   LEFT JOIN uss_ndi.v_ddn_ap_src src
                       ON (src.DIC_VALUE = ap.ap_src)
                   LEFT JOIN uss_ndi.v_ndi_reason_not_pay r
                       ON (r.rnp_id = t.at_rnp)
             WHERE at_id = p_at_id;

        OPEN dec_cur FOR
            SELECT d.pd_id,
                   d.pd_dt,
                   d.pd_num,
                   s.nst_code || ' ' || s.nst_name     AS pd_nst_name,
                   hs.hs_dt                            AS pcb_hs_lock_dt,
                   tools.GetUserPib (hs.hs_wu)         AS pcb_hs_lock_user,
                   Pcb_Acc_Stop_Dt + 1                 AS Pcb_Acc_Stop_Dt
              FROM pc_block  t
                   JOIN pc_decision d ON (t.pcb_pd = d.pd_id)
                   JOIN uss_ndi.v_ndi_service_type s ON (s.nst_id = d.pd_nst)
                   LEFT JOIN histsession hs ON (hs.hs_id = t.pcb_hs_lock)
             WHERE t.pcb_at = p_at_id;

        IF l_act.at_tp = 'RSTOPV'
        THEN
            OPEN serv_cur FOR
                  SELECT --pd_id AS serv_id, pd_nst AS serv_nst, pd_num AS serv_num, s.nst_code || ' ' || s.nst_name AS serv_nst_name
                         pd_id                                           AS ats_id,
                         pd_nst                                          AS ats_nst,
                         pd_num                                          AS doc_num,
                            pd_num
                         || ' ('
                         || nst_code
                         || ' '
                         || nst_name
                         || ')'
                         || ' з '
                         || TO_CHAR (pdap.pdap_start_dt, 'DD.MM.YYYY')
                         || ' по '
                         || TO_CHAR (pdap.pdap_stop_dt, 'DD.MM.YYYY')    AS ats_nst_name
                    FROM pc_decision,
                         uss_ndi.v_ndi_service_type,
                         pd_accrual_period pdap
                   WHERE     pd_pc = l_act.at_pc
                         AND pd_nst = nst_id
                         AND pdap_pd = pd_id
                         AND pdap.history_status = 'A'
                ORDER BY    nst_code
                         || ' '
                         || nst_name
                         || ' з '
                         || TO_CHAR (pdap.pdap_start_dt, 'DD.MM.YYYY')
                         || ' по '
                         || TO_CHAR (pdap.pdap_stop_dt, 'DD.MM.YYYY')--AND LAST_DAY(l_act.at_dt) + 1 BETWEEN pdap_start_dt AND pdap_stop_dt
                                                                     ;
        ELSE
            OPEN serv_cur FOR
                SELECT t.ats_id,
                       t.ats_nst,
                       s.nst_code || ' ' || s.nst_name     AS ats_nst_name
                  FROM at_service  t
                       JOIN uss_ndi.v_ndi_service_type s
                           ON (s.nst_id = t.ats_nst)
                 WHERE t.ats_at = p_at_id;
        END IF;

        DNET$PERSONAL_CASE.Get_Documents_Ap (l_act.at_ap,
                                             Doc_Cur,
                                             attr_cur,
                                             file_cur);
    END;

    -- #87269
    PROCEDURE get_ss_act_journal (p_ap_id             IN     NUMBER,
                                  p_ap_reg_dt_start   IN     DATE,
                                  p_ap_reg_dt_stop    IN     DATE,
                                  p_at_dt_start       IN     DATE,
                                  p_at_dt_stop        IN     DATE,
                                  p_org_id            IN     NUMBER,
                                  p_pc_num            IN     VARCHAR2,
                                  p_ap_num            IN     VARCHAR2,
                                  p_at_num            IN     VARCHAR2,
                                  p_pc_rnokpp         IN     VARCHAR2,
                                  p_at_rnp            IN     NUMBER,
                                  p_at_st             IN     VARCHAR2,
                                  appeal_info            OUT SYS_REFCURSOR,
                                  res_cur                OUT SYS_REFCURSOR)
    IS
        l_org_to   NUMBER := tools.getcurrorgto;
    BEGIN
        OPEN appeal_info FOR
            SELECT t.*,
                   (SELECT dic_sname
                      FROM uss_ndi.v_ddn_ap_st z
                     WHERE z.DIC_VALUE = t.ap_st)
                       AS ap_st_name,
                   uss_person.api$sc_tools.GET_PIB_SCC (app.app_scc)
                       AS app_main_pib,
                   (SELECT LISTAGG (
                                  CASE
                                      WHEN a.apda_nda NOT IN
                                               (1879, 1974, 1645)
                                      THEN
                                          n.nda_name || ' '
                                  END
                               || a.Apda_Val_String,
                               ' ')
                           WITHIN GROUP (ORDER BY n.Nda_Order)
                      FROM Ap_Document_Attr  a
                           JOIN Ap_Document d
                               ON     a.Apda_Apd = d.Apd_Id
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
                               ON a.Apda_Nda = n.Nda_Id
                     WHERE     a.Apda_Ap = t.ap_id
                           AND a.History_Status = 'A'
                           AND (   (    d.apd_ndt = 801
                                    AND a.apda_nda IN (              /*1873,*/
                                                       1874,
                                                       1875,
                                                       1876,
                                                       1877,
                                                       1878,
                                                       1879,
                                                       1880,
                                                       1881,
                                                       1882))
                                OR (    d.apd_ndt = 802
                                    AND a.apda_nda IN (              /*1968,*/
                                                       1969,
                                                       1970,
                                                       1971,
                                                       1972,
                                                       1973,
                                                       1974,
                                                       1975,
                                                       1976,
                                                       1977))
                                OR     d.apd_ndt = 803
                                   AND nda_nng = 61
                                   AND nda_id NOT IN (2456, 1494))
                           AND a.apda_val_string IS NOT NULL/*  AND (d.apd_ndt = 801 AND nda_id between 1873 and 1882
                                                               OR d.apd_ndt = 802 AND nda_id between 1968 and 1977
                                                               OR d.apd_ndt = 803 AND nda_nng = 61 AND nda_id != 2456)*/
                                                            )
                       AS App_Main_Address
              FROM uss_esr.v_appeal  t
                   LEFT OUTER JOIN v_personalcase pc ON (pc.pc_id = t.ap_pc)
                   LEFT OUTER JOIN ap_person app
                       ON     app.app_sc = pc.pc_sc
                          AND app.app_ap = t.ap_id
                          AND app.history_status = 'A'
             WHERE t.ap_id = P_AP_ID;

        OPEN res_cur FOR
            SELECT t.*,
                   p.pc_num,
                   ap.ap_num,
                   ap.ap_reg_dt,
                   st.DIC_NAME
                       AS at_st_name,
                   src.DIC_NAME
                       AS ap_src_name,
                   uss_person.api$sc_tools.GET_PIB (p.pc_sc)
                       AS pc_pib,
                   uss_person.api$sc_tools.get_numident (p.pc_sc)
                       AS Pc_Rnokpp,
                   r.rnp_name
                       AS At_Rnp_Name
              FROM v_act  t
                   LEFT OUTER JOIN v_personalcase p ON (p.pc_id = t.at_pc)
                   JOIN v_appeal ap
                       ON (    ap.ap_id = t.at_ap
                           AND (p_org_id IS NULL OR ap.com_org = p_org_id))
                   LEFT JOIN uss_ndi.V_DDN_AT_RSTOPSS_ST st
                       ON (st.DIC_VALUE = t.at_st)
                   LEFT JOIN uss_ndi.v_ddn_ap_src src
                       ON (src.DIC_VALUE = ap.ap_src)
                   LEFT JOIN uss_ndi.v_ndi_reason_not_pay r
                       ON (r.rnp_id = t.at_rnp)
             WHERE     1 = 1
                   AND at_tp = 'RSTOPSS'
                   AND ap.ap_tp IN ('R.OS', 'R.GS')
                   --AND (l_org_to = 31 AND at_st IN ('O.R0', 'O.WD') OR l_org_to != 31 AND at_st IN ('R0', 'WD'))
                   AND (at_st IN ('RR',
                                  'RS.S',
                                  'RS.B',
                                  'RM.O',
                                  'RA',
                                  'RD'))
                   AND (P_AP_ID IS NULL OR t.at_ap = P_AP_ID)
                   AND (   p_ap_reg_dt_start IS NULL
                        OR ap.ap_reg_dt >= p_ap_reg_dt_start)
                   AND (   p_ap_reg_dt_stop IS NULL
                        OR ap.ap_reg_dt <= p_ap_reg_dt_stop)
                   AND (p_at_dt_start IS NULL OR t.at_dt >= p_at_dt_start)
                   AND (p_at_dt_stop IS NULL OR t.at_dt <= p_at_dt_stop)
                   AND (p_at_num IS NULL OR t.at_num LIKE p_at_num || '%')
                   AND (p_ap_num IS NULL OR ap.ap_num LIKE p_ap_num || '%')
                   AND (p_pc_num IS NULL OR p.pc_num LIKE p_pc_num || '%')
                   AND (p_at_rnp IS NULL OR t.at_rnp = p_at_rnp)
                   AND (p_at_st IS NULL OR t.at_st = p_at_st)
                   AND (   p_pc_rnokpp IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM uss_person.v_sc_document sd
                                 WHERE     sd.scd_ndt = 5
                                       AND sd.scd_sc = p.pc_sc
                                       AND sd.scd_st IN ('A', '1')
                                       AND sd.scd_number = p_pc_rnokpp));
    END;

    -- #87273
    FUNCTION can_approve_act (p_at_id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_check1   NUMBER;
        l_check2   NUMBER;
        l_at_st    VARCHAR2 (10);
    BEGIN
        SELECT at_st
          INTO l_at_st
          FROM act t
         WHERE t.at_id = p_at_id;

        SELECT COUNT (*)
          INTO l_check1
          FROM at_document z
         WHERE     z.atd_at = p_at_id
               AND z.atd_ndt = 860
               AND z.history_status = 'A';

        SELECT COUNT (*)
          INTO l_check2
          FROM at_document z
         WHERE     z.atd_at = p_at_id
               AND z.atd_ndt = 862
               AND z.history_status = 'A';

        RETURN CASE
                   WHEN l_at_st IN ('RS.S') AND l_check1 > 0 THEN 'T'
                   WHEN l_at_st IN ('RM.O') AND l_check2 > 0 THEN 'T'
                   WHEN l_at_st IN ('RS.B', 'RR') THEN 'T'
                   ELSE 'F'
               END;
    END;

    -- #87270: Рішення про припинення СП
    PROCEDURE get_ss_act_card (p_at_id    IN     NUMBER,
                               info_cur      OUT SYS_REFCURSOR,
                               dec_cur       OUT SYS_REFCURSOR,
                               serv_cur      OUT SYS_REFCURSOR,
                               doc_cur       OUT SYS_REFCURSOR,
                               attr_cur      OUT SYS_REFCURSOR,
                               file_cur      OUT SYS_REFCURSOR)
    IS
        l_act        act%ROWTYPE;
        l_tctr_num   VARCHAR2 (100);
    BEGIN
        SELECT *
          INTO l_act
          FROM act
         WHERE at_id = p_at_id;

        l_tctr_num := Api$appeal.Get_Ap_Doc_Str (l_act.at_ap, 'TCTRNUM');

        OPEN info_cur FOR
            SELECT t.*,
                   p.pc_num,
                   ap.ap_num,
                   ap.ap_reg_dt,
                   st.DIC_NAME
                       AS at_st_name,
                   src.DIC_NAME
                       AS ap_src_name,
                   uss_person.api$sc_tools.GET_PIB (p.pc_sc)
                       AS pc_pib,
                   uss_person.api$sc_tools.get_numident (p.pc_sc)
                       AS Pc_Rnokpp,
                   /* (SELECT listagg(s.nst_name, '; ') within GROUP (ORDER BY s.nst_order)
                       FROM (SELECT DISTINCT s.nst_name, s.nst_order
                             FROM at_service ats
                               JOIN uss_ndi.v_ndi_service_type s ON (s.nst_id = ats.ats_nst)
                             WHERE ats.ats_at = p_at_id
                               AND ats.history_status = 'A') s
                    ) AS nst_list,*/
                   can_approve_act (t.at_id)
                       AS can_approve_Act,
                   r.rnp_name
                       AS At_Rnp_Name
              FROM v_act  t
                   LEFT OUTER JOIN v_personalcase p ON (p.pc_id = t.at_pc)
                   JOIN v_appeal ap ON (ap.ap_id = t.at_ap)
                   LEFT JOIN uss_ndi.V_DDN_AT_RSTOPSS_ST st
                       ON (st.DIC_VALUE = t.at_st)
                   LEFT JOIN uss_ndi.v_ddn_ap_src src
                       ON (src.DIC_VALUE = ap.ap_src)
                   LEFT JOIN uss_ndi.v_ndi_reason_not_pay r
                       ON (r.rnp_id = t.at_rnp)
             WHERE at_id = p_at_id;

        OPEN dec_cur FOR
            SELECT d.pd_id,
                   d.pd_dt,
                   d.pd_num,
                   s.nst_code || ' ' || s.nst_name     AS pd_nst_name,
                   hs.hs_dt                            AS pcb_hs_lock_dt,
                   tools.GetUserPib (hs.hs_wu)         AS pcb_hs_lock_user,
                   Pcb_Acc_Stop_Dt + 1                 AS Pcb_Acc_Stop_Dt
              FROM pc_block  t
                   JOIN pc_decision d ON (t.pcb_pd = d.pd_id)
                   JOIN uss_ndi.v_ndi_service_type s ON (s.nst_id = d.pd_nst)
                   LEFT JOIN histsession hs ON (hs.hs_id = t.pcb_hs_lock)
             WHERE t.pcb_at = p_at_id;

        OPEN serv_cur FOR
            WITH
                dat
                AS
                    (SELECT z.*
                       FROM act  z
                            JOIN act c
                                ON (    c.at_main_link = z.at_id
                                    AND c.at_tp = 'TCTR')
                      WHERE z.at_tp = 'PDSP' AND c.at_num = l_tctr_num)
            SELECT t.ats_id,
                   t.ats_nst,
                   s.nst_code || ' ' || s.nst_name     AS ats_nst_name,
                   d.at_num                            AS doc_num,
                   d.at_dt                             AS doc_dt,
                   d.at_id
              FROM at_service  t
                   JOIN dat d ON (d.at_id = t.ats_at)
                   JOIN uss_ndi.v_ndi_service_type s
                       ON (s.nst_id = t.ats_nst)
             WHERE     1 = 1                              --t.ats_at = p_at_id
                   AND t.ats_st IN ('SG', 'SU')
                   AND t.ats_ss_term NOT IN ('O');

        DNET$PERSONAL_CASE.Get_Documents_Ap (l_act.at_ap,
                                             Doc_Cur,
                                             attr_cur,
                                             file_cur);
    END;

    -- інформація по рішенню СП
    PROCEDURE get_decision_card_SS (p_pd_id   IN     NUMBER,
                                    dec_cur      OUT SYS_REFCURSOR)
    IS
        l_org_id   NUMBER;
        l_org_to   NUMBER;
    BEGIN
        tools.WriteMsg ('DNET$PAY_TERMINATE.' || $$PLSQL_UNIT);

        l_org_id := tools.GetCurrOrg;
        l_org_to := tools.GetCurrOrgTo;

        OPEN DEC_CUR FOR
            SELECT                                                      --t.*,
                   pd_pc,
                   pd_ap,
                   pd_id,
                   pd_pa,
                   pd_dt,
                   pd_st,
                   pd_has_right,
                   pd_hs_right,
                   pd_hs_reject,
                   pd_hs_app,
                   pd_hs_mapp,
                   pd_hs_head,
                   pd_start_dt,
                   pd_stop_dt,
                   pd_num,
                   pd_nst,
                   t.com_org,
                   t.com_wu,
                   pdm_pay_tp,
                   pdm_index,
                   pdm_kaot,
                   pdm_nb,
                   pdm_account,
                   pdm_street,
                   pdm_ns,
                   pdm_building,
                   pdm_block,
                   pdm_apartment,
                   pdm_nd,
                   pdm_pay_dt,
                   pd_hs_return,
                   pd_src,
                   pd_ps,
                   pd_src_id,
                   pd_ap_reason,
                   pa.pa_num,
                   nst.nst_code || ' ' || nst.nst_name
                       AS pd_nst_name,
                   st.DIC_SNAME
                       AS pd_st_name,
                   hs.hs_dt
                       AS return_dt,
                   tools.GetUserPib (hs.hs_wu)
                       AS return_pib,
                   ap.ap_id,
                   ap.ap_pc,
                   ap.ap_src_id,
                   ap.ap_tp,
                   NVL (ap_res.ap_reg_dt, ap.ap_reg_dt)
                       AS ap_reg_dt,
                   ap.ap_src,
                   ap.ap_st,
                   ap.ap_is_second,
                   NVL (ap_res.ap_num, ap.ap_num)
                       AS ap_num,
                   ap.ap_vf,
                   (SELECT dic_sname
                      FROM uss_ndi.v_ddn_ap_st z
                     WHERE z.DIC_VALUE = ap.ap_st)
                       AS ap_st_name,
                   uss_person.api$sc_tools.GET_PIB_SCC (t.pd_scc)
                       AS app_main_pib,
                   (SELECT LISTAGG (
                                  CASE
                                      WHEN a.apda_nda NOT IN
                                               (1879, 1974, 1645)
                                      THEN
                                          n.nda_name || ' '
                                  END
                               || a.Apda_Val_String,
                               ' ')
                           WITHIN GROUP (ORDER BY n.Nda_Order)
                      FROM Ap_Document_Attr  a
                           JOIN Ap_Document d
                               ON     a.Apda_Apd = d.Apd_Id
                                  -- AND d.Apd_Ndt IN (801, 802, 803)
                                  AND d.apd_app IN
                                          (SELECT p.app_id
                                             FROM v_ap_person p
                                            WHERE     p.app_ap = ap.ap_id
                                                  AND p.app_tp =
                                                      CASE
                                                          WHEN ap.ap_tp IN
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
                               ON a.Apda_Nda = n.Nda_Id
                     WHERE     a.Apda_Ap = ap.ap_id
                           AND a.History_Status = 'A'
                           AND (   (    d.apd_ndt = 801
                                    AND a.apda_nda IN (              /*1873,*/
                                                       1874,
                                                       1875,
                                                       1876,
                                                       1877,
                                                       1878,
                                                       1879,
                                                       1880,
                                                       1881,
                                                       1882))
                                OR (    d.apd_ndt = 802
                                    AND a.apda_nda IN (              /*1968,*/
                                                       1969,
                                                       1970,
                                                       1971,
                                                       1972,
                                                       1973,
                                                       1974,
                                                       1975,
                                                       1976,
                                                       1977))
                                OR     d.apd_ndt = 803
                                   AND nda_nng = 61
                                   AND nda_id NOT IN (2456, 1494))
                           AND a.apda_val_string IS NOT NULL/*  AND (d.apd_ndt = 801 AND nda_id between 1873 and 1882
                                                                OR d.apd_ndt = 802 AND nda_id between 1968 and 1977
                                                                OR d.apd_ndt = 803 AND nda_nng = 61 AND nda_id != 2456)*/
                                                            )
                       AS App_Main_Address,
                   pc.pc_num,
                   pc.pc_sc,
                   src.dic_name
                       AS pd_src_name,
                   NVL (
                       (  SELECT    TO_CHAR (pdap_start_dt, 'DD.MM.YYYY')
                                 || '-'
                                 || TO_CHAR (pdap_stop_dt, 'DD.MM.YYYY')
                            FROM pd_accrual_period pp
                           WHERE pdap_pd = t.pd_id AND pp.history_status = 'A'
                        ORDER BY pdap_start_dt DESC
                           FETCH FIRST ROW ONLY),          -- OPERVEIEV #80462
                          'очік: '
                       || TO_CHAR (pd_start_dt, 'DD.MM.YYYY')
                       || '-'
                       || TO_CHAR (pd_stop_dt, 'DD.MM.YYYY'))
                       AS pd_real_period,
                   (CASE
                        WHEN     t.pd_nst = 664
                             AND t.pd_st = 'P'
                             AND COALESCE (t.pd_is_signed, 'F') = 'F'
                        THEN
                            1
                        ELSE
                            0
                    END)
                       AS approve_with_sign, --#77050: 1 - кнопка "Затвердити з підписом ЕЦП" доступна/ 0 - НІ
                   (CASE
                        WHEN EXISTS
                                 (SELECT a.apda_id
                                    FROM ap_document_attr  a
                                         JOIN ap_document d
                                             ON a.apda_apd = d.apd_id
                                   WHERE     a.apda_ap = ap.ap_id
                                         AND (   (    d.apd_ndt = 801
                                                  AND a.apda_nda = 1870)
                                              OR (    d.apd_ndt = 802
                                                  AND a.apda_nda = 1947)
                                              OR (    d.apd_ndt = 803
                                                  AND a.apda_nda = 2032))
                                         AND a.apda_val_string = 'T')
                        THEN
                            1
                        ELSE
                            0
                    END)
                       AS is_Emergency,                             --Екстрено
                   (CASE
                        WHEN EXISTS
                                 (SELECT a.apda_id
                                    FROM ap_document_attr  a
                                         JOIN ap_document d
                                             ON a.apda_apd = d.apd_id
                                   WHERE        a.apda_ap = ap.ap_id
                                            AND NOT (    (   (    d.apd_ndt =
                                                                  801
                                                              AND a.apda_nda =
                                                                  1870)
                                                          OR (    d.apd_ndt =
                                                                  802
                                                              AND a.apda_nda =
                                                                  1947)
                                                          OR (    d.apd_ndt =
                                                                  803
                                                              AND a.apda_nda =
                                                                  2032))
                                                     AND a.apda_val_string =
                                                         'T')
                                         OR (d.apd_ndt = 802))
                        THEN
                            1
                        ELSE
                            0
                    END)
                       AS is_Editable_Provider,      --Редагувати поле надавач
                   (CASE
                        WHEN EXISTS
                                 (SELECT a.apda_id
                                    FROM ap_document_attr  a
                                         JOIN ap_document d
                                             ON a.apda_apd = d.apd_id
                                   WHERE     a.apda_ap = ap.ap_id
                                         AND (    d.apd_ndt = 801
                                              AND a.apda_nda = 1872
                                              AND a.apda_val_id IS NOT NULL))
                        THEN
                            1
                        WHEN EXISTS
                                 (SELECT a.apda_id
                                    FROM ap_document_attr  a
                                         JOIN ap_document d
                                             ON a.apda_apd = d.apd_id
                                   WHERE     a.apda_ap = ap.ap_id
                                         AND (    d.apd_ndt = 803
                                              AND a.apda_nda = 2083
                                              AND a.apda_val_id IS NOT NULL))
                        THEN
                            0
                        ELSE
                            NULL
                    END)
                       AS is_Set_Provider,
                   DNET$PAY_ASSIGNMENTS.Get_IsNeed_Income (pd_id)
                       AS is_need_income,
                   DNET$PAY_ASSIGNMENTS.Get_Is_Block_Approve (pd_id)
                       AS is_block_approve,
                   DNET$PAY_ASSIGNMENTS.get_right_block_flag (t.pd_id)
                       AS block_right
              FROM v_pc_decision  t
                   JOIN Pd_Pay_Method pm
                       ON     pm.pdm_pd = t.pd_id
                          AND pm.pdm_is_actual = 'T'
                          AND pm.history_status = 'A'
                   JOIN uss_ndi.v_ddn_pd_st st ON (st.DIC_VALUE = t.pd_st)
                   JOIN uss_ndi.v_ddn_pd_src src
                       ON (src.DIC_VALUE = t.pd_src)
                   JOIN uss_ndi.v_ndi_service_type nst
                       ON (nst.nst_id = t.pd_nst)
                   JOIN pc_account pa ON (pa.pa_id = t.pd_pa)
                   LEFT JOIN histsession hs ON (hs.hs_id = t.pd_hs_return)
                   JOIN uss_esr.v_appeal ap ON ap.ap_id = t.pd_ap
                   LEFT OUTER JOIN v_personalcase pc ON (pc.pc_id = pd_pc)
                   JOIN v_appeal ap_res ON (ap_res.ap_id = t.pd_ap_reason)
             WHERE 1 = 1 AND pd_id = p_pd_id;
    END;

    -- ініціалізація акту по зверненню (з послугою 923)
    PROCEDURE init_act_by_appeal_923 (p_ap_id          appeal.ap_id%TYPE,
                                      p_messages   OUT SYS_REFCURSOR)
    IS
    BEGIN
        API$ERRAND.init_act_by_appeals_923 (1, p_ap_id, p_messages);
    END;

    -- ініціалізація акту по зверненню
    PROCEDURE init_act_by_appeal (p_ap_id          appeal.ap_id%TYPE,
                                  p_messages   OUT SYS_REFCURSOR)
    IS
    BEGIN
        api$act.init_act_by_appeals (1, p_ap_id, p_messages);
    END;

    -- #87271: дані форми визначення права
    PROCEDURE GET_ACT_RIGHTS (P_AT_ID NUMBER, RES_CUR OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT t.*,
                   r.nrr_name             AS arl_nrr_name,
                   NVL (r.nrr_tp, 'E')    AS nrr_tp,
                   CASE
                       WHEN r.nrr_is_critical_error = 'T' THEN 'F'
                       ELSE 'T'
                   END                    AS Can_Set_Result
              FROM at_right_log  t
                   JOIN uss_ndi.v_ndi_right_rule r ON (r.nrr_id = t.arl_nrr)
             WHERE t.arl_at = p_at_id;
    END;

    -- ініціалізація визначення права
    PROCEDURE INIT_ACT_RIGHTS (p_at_id          act.at_id%TYPE,
                               p_messages   OUT SYS_REFCURSOR)
    IS
    BEGIN
        API$CALC_RIGHT_AT.init_right_for_act (1, p_at_id, p_messages);
    END;

    -- #70334: збереження форми визначення права
    PROCEDURE SAVE_ACT_RIGHTS (P_AT_ID   IN NUMBER,
                               P_AT_ST   IN VARCHAR2,
                               P_CLOB    IN CLOB)
    IS
        l_arr   t_at_right_log;
        l_hs    NUMBER := tools.GetHistSession;
        l_st    VARCHAR2 (10);
    BEGIN
        check_consistensy (P_AT_ID, P_AT_ST);

        EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                         't_at_right_log',
                                         TRUE,
                                         TRUE)
            BULK COLLECT INTO l_arr
            USING P_CLOB;

        IF (l_arr.COUNT = 0)
        THEN
            RETURN;
        END IF;

        FORALL i IN INDICES OF l_arr
            UPDATE at_right_log t
               SET t.arl_result = l_arr (i).arl_Result,
                   t.arl_hs_rewrite =
                       CASE
                           WHEN (t.arl_result != l_arr (i).arl_Result)
                           THEN
                               l_hs
                           ELSE
                               t.arl_hs_rewrite
                       END
             WHERE t.arl_id = l_arr (i).arl_id;

        UPDATE act t
           SET --t.at_has_right = 'T',
               t.at_wu = COALESCE (t.at_wu, tools.GetCurrWu)
         WHERE t.at_id = P_AT_ID;

        SELECT t.at_st
          INTO l_st
          FROM act t
         WHERE t.at_Id = p_at_id;

        API$CALC_RIGHT_AT.Recalc_SS_ALG (p_at_id);

        API$ACT.Write_At_Log (p_at_Id,
                              l_hs,
                              l_st,
                              CHR (38) || '15',
                              l_st);
    END;


    -- #87272: список документів які можна створити
    PROCEDURE get_doc_tp_list (p_at_id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
        l_role1   NUMBER
            := CASE
                   WHEN tools.CheckUserRole ('W_ESR_SS_OPER') = TRUE THEN 1
                   ELSE 0
               END;
        l_role2   NUMBER
            := CASE
                   WHEN tools.CheckUserRole ('W_ESR_SS_APPROVE') = TRUE
                   THEN
                       1
                   ELSE
                       0
               END;
    BEGIN
        /*1) ndt_id in (860):
        - рішення по зверненню має статус R0 або O.R0
        - відсутній документ, який намагаються створити, у статусі ‘A’
        - користувач має роль «СП. Спеціаліст з опрацювання справ» (W_ESR_SS_OPER)

        2) ndt_id in (862):
        - рішення по зверненню має статус WD або O.WD
        - відсутній документ, який намагаються створити, у статусі ‘A’
        - користувач має роль «СП. Підписання рішень» (W_ESR_SS_APPROVE)*/
        OPEN res_cur FOR
            SELECT dt.ndt_id               AS id,
                   dt.ndt_name             AS NAME,
                   dt.ndt_is_have_scan     AS code
              FROM act  t
                   JOIN uss_ndi.v_ndi_document_type dt ON (dt.ndt_id = 860)
             WHERE     1 = 1
                   AND t.at_id = p_at_id
                   AND t.at_st IN ('RS.S')
                   AND NOT EXISTS
                           (SELECT *
                              FROM at_document d
                             WHERE     d.atd_at = t.at_id
                                   AND d.atd_ndt = 860
                                   AND d.history_status = 'A')
                   AND l_role1 = 1
            UNION ALL
            SELECT dt.ndt_id               AS id,
                   dt.ndt_name             AS NAME,
                   dt.ndt_is_have_scan     AS code
              FROM v_act  t
                   JOIN uss_ndi.v_ndi_document_type dt ON (dt.ndt_id = 862)
             WHERE     1 = 1
                   AND t.at_id = p_at_id
                   AND t.at_st IN ('RM.O')
                   AND NOT EXISTS
                           (SELECT *
                              FROM at_document d
                             WHERE     d.atd_at = t.at_id
                                   AND d.atd_ndt = 862
                                   AND d.history_status = 'A')
                   AND l_role2 = 1;
    END;

    --повертає персону з переважним типом p_App_Tp, у разі відсутності - кого попало
    FUNCTION Get_App_Sci (p_Ap_Id IN NUMBER, p_App_Tp IN VARCHAR2)
        RETURN Uss_Person.v_Sc_Identity%ROWTYPE
    IS
        l_Sci   Uss_Person.v_Sc_Identity%ROWTYPE;
    BEGIN
        SELECT *
          INTO l_Sci
          FROM (  SELECT i.*
                    FROM Ap_Person p
                         JOIN uss_person.v_socialcard s ON (s.sc_id = p.app_sc)
                         JOIN Uss_Person.v_Sc_Change c ON        /*p.App_Scc*/
                                                          s.sc_scc = c.Scc_Id
                         JOIN Uss_Person.v_Sc_Identity i
                             ON c.Scc_Sci = i.Sci_Id
                   WHERE p.App_Ap = p_Ap_Id AND p.History_Status = 'A'
                ORDER BY DECODE (p.App_Tp, p_App_Tp, 0, 1))
         FETCH FIRST ROW ONLY;

        RETURN l_Sci;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN l_Sci;
    END;

    --повертає персону з переважним типом p_App_Tp, у разі відсутності - кого попало
    FUNCTION Get_App_Sci (p_Ap_Id IN NUMBER)
        RETURN Uss_Person.v_Sc_Identity%ROWTYPE
    IS
        l_Sci   Uss_Person.v_Sc_Identity%ROWTYPE;
    BEGIN
        SELECT *
          INTO l_Sci
          FROM (  SELECT i.*
                    FROM Ap_Person p
                         JOIN uss_person.v_socialcard s ON (s.sc_id = p.app_sc)
                         JOIN Uss_Person.v_Sc_Change c ON        /*p.App_Scc*/
                                                          s.sc_scc = c.Scc_Id
                         JOIN Uss_Person.v_Sc_Identity i
                             ON c.Scc_Sci = i.Sci_Id
                   WHERE p.App_Ap = p_Ap_Id AND p.History_Status = 'A'
                ORDER BY DECODE (p.App_Tp,  'OS', 0,  'Z', 1,  'FMS', 2,  3))
         FETCH FIRST ROW ONLY;

        RETURN l_Sci;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN l_Sci;
    END;

    FUNCTION Get_Atp_Person (p_At_Id IN NUMBER, p_App_Tp IN VARCHAR2)
        RETURN At_Person%ROWTYPE
    IS
        l_Sci   At_Person%ROWTYPE;
    BEGIN
          SELECT p.*
            INTO l_Sci
            FROM At_Person p
           WHERE p.atp_at = p_At_Id AND p.History_Status = 'A'
        ORDER BY DECODE (p.Atp_App_Tp, p_App_Tp, 0, 1)
           FETCH FIRST ROW ONLY;

        RETURN l_Sci;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN l_Sci;
    END;

    -----------------------------------------------------------
    --         ДОДАВАННЯ АТРИБУТУ ДО КОЛЕКЦІЇ
    -----------------------------------------------------------
    PROCEDURE Add_Attr (p_Attrs     IN OUT NOCOPY t_At_Document_Attrs,
                        p_Nda_Id    IN            NUMBER,
                        p_Val_Str   IN            VARCHAR2 DEFAULT NULL,
                        p_Val_Dt    IN            DATE DEFAULT NULL,
                        p_Val_Sum   IN            NUMBER DEFAULT NULL,
                        p_Val_Int   IN            NUMBER DEFAULT NULL,
                        p_Val_Id    IN            NUMBER DEFAULT NULL)
    IS
    BEGIN
        IF p_Nda_Id IS NULL
        THEN
            RETURN;
        END IF;

        IF     p_Val_Str IS NULL
           AND p_Val_Dt IS NULL
           AND p_Val_Id IS NULL
           AND p_Val_Sum IS NULL
           AND p_Val_Int IS NULL
           AND p_Val_Id IS NULL
        THEN
            RETURN;
        END IF;

        IF p_Attrs IS NULL
        THEN
            p_Attrs := t_At_Document_Attrs ();
        END IF;

        p_Attrs.EXTEND ();
        p_Attrs (p_Attrs.COUNT).Atda_Nda := p_Nda_Id;
        p_Attrs (p_Attrs.COUNT).Atda_Val_String := p_Val_Str;
        p_Attrs (p_Attrs.COUNT).Atda_Val_Dt := p_Val_Dt;
        p_Attrs (p_Attrs.COUNT).Atda_Val_Sum := p_Val_Sum;
        p_Attrs (p_Attrs.COUNT).Atda_Val_Int := p_Val_Int;
        p_Attrs (p_Attrs.COUNT).Atda_Val_Id := p_Val_Id;
    END;

    FUNCTION get_AtPerson_id (p_at NUMBER, p_App_Tp VARCHAR2)
        RETURN NUMBER
    IS
        l_id   NUMBER;
    BEGIN
          SELECT p.atp_id
            INTO l_id
            FROM uss_esr.at_person p
           WHERE p.atp_at = p_at
        ORDER BY DECODE (p.Atp_App_Tp, p_App_Tp, 0, 1)
           FETCH FIRST ROW ONLY;

        RETURN l_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    FUNCTION get_AtDocAtrStr (p_at_id NUMBER, p_nda NUMBER)
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT a.atda_val_string
              FROM uss_esr.at_document d, uss_esr.at_document_attr a
             WHERE     d.atd_at = p_at_id
                   AND d.history_status = 'A'
                   AND a.atda_atd = d.atd_id
                   AND a.atda_nda = p_nda
                   AND a.history_status = 'A';

        r   at_document_attr.atda_val_string%TYPE;
    BEGIN
        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        RETURN r;
    END;

    FUNCTION get_AtLinkedDocAtrStr (p_at_id NUMBER, p_nda NUMBER)
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT f.atef_feature
              FROM uss_esr.act  t
                   JOIN uss_esr.at_section_feature f ON (f.atef_at = t.at_id)
             WHERE t.at_main_link = p_at_id AND f.atef_nda = p_nda;

        r   at_document_attr.atda_val_string%TYPE;
    BEGIN
        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        RETURN r;
    END;

    FUNCTION get_AtDocAtrDt (p_at_id NUMBER, p_nda NUMBER)
        RETURN DATE
    IS
        CURSOR cur IS
            SELECT a.atda_val_dt
              FROM uss_esr.at_document d, uss_esr.at_document_attr a
             WHERE     d.atd_at = p_at_id
                   AND d.history_status = 'A'
                   AND a.atda_atd = d.atd_id
                   AND a.atda_nda = p_nda
                   AND a.history_status = 'A';

        r   DATE;
    BEGIN
        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        RETURN r;
    END;

    FUNCTION Get_At_Feature_Str (p_At_Id IN NUMBER, p_Nft_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   at_Features.atf_val_string%TYPE;
    BEGIN
        SELECT MAX (f.atf_val_string)
          INTO l_Result
          FROM at_Features f
         WHERE f.atf_at = p_At_Id AND f.atf_nft = p_Nft_Id;

        RETURN l_Result;
    END;

    FUNCTION Get_At_Feature_Id (p_At_Id IN NUMBER, p_Nft_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Result   At_Features.atf_val_int%TYPE;
    BEGIN
        SELECT MAX (f.atf_val_id)
          INTO l_Result
          FROM at_Features f
         WHERE f.atf_at = p_At_Id AND f.atf_nft = p_Nft_Id;

        RETURN l_Result;
    END;

    --список соц.послуг
    FUNCTION AtSrv_Nst_List (p_at_id act.at_id%TYPE, p_tp NUMBER --1- надати, 0- відмовити
                                                                )
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT LISTAGG (s.ats_nst, ',') WITHIN GROUP (ORDER BY s.ats_nst)
              FROM uss_esr.at_service s         --uss_ndi.v_ddn_tctr_ats_st st
             WHERE     s.ats_at = p_at_id
                   AND s.history_status = 'A'
                   AND CASE
                           WHEN     p_tp = 1
                                AND s.ats_st IN ('PP',
                                                 'SG',
                                                 'P',
                                                 'R')
                           THEN
                               1                                   --1- надати
                           WHEN p_tp = 0 AND s.ats_st IN ('PR', 'V')
                           THEN
                               1                                --0- відмовити
                       END = 1;

        l_res   VARCHAR2 (1000);
    BEGIN
        OPEN cur;

        FETCH cur INTO l_res;

        CLOSE cur;

        RETURN l_res;
    END;

    --метод надання соц.послуг
    FUNCTION AtSrvMetod (p_at_id act.at_id%TYPE)
        RETURN VARCHAR2
    IS
        CURSOR cur IS
            SELECT MIN (s.ats_ss_method)
              FROM uss_esr.at_service s           -- uss_ndi.v_ddn_ss_method m
             WHERE     s.ats_at = p_at_id
                   AND s.history_status = 'A'
                   AND s.ats_st IN ('PP',
                                    'SG',
                                    'P',
                                    'R')                             -- надати
                                        ;

        l_res   VARCHAR2 (10);
    BEGIN
        OPEN cur;

        FETCH cur INTO l_res;

        CLOSE cur;

        RETURN l_res;
    END;

    FUNCTION Get_At_Reject_List (p_At_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_result   VARCHAR2 (4000);
    BEGIN
        SELECT LISTAGG (r.Njr_Name, ', ') WITHIN GROUP (ORDER BY r.Njr_Order)
          INTO l_result
          FROM At_Reject_Info  i
               JOIN Uss_Ndi.v_Ndi_Reject_Reason r ON i.ari_njr = r.Njr_Id
         WHERE i.ari_at = p_At_Id AND r.History_Status = 'A';

        RETURN l_result;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
    END;

    --підписант акта p_order = 1 - перший підпеисант 2-другий підписант
    FUNCTION get_at_signers (p_at_id   NUMBER,
                             p_order   NUMBER,
                             p_ndt     NUMBER:= NULL)
        RETURN NUMBER
    IS
        CURSOR c (p_ndt NUMBER)
        IS
            SELECT COUNT (*)                                       cnt,
                   MAX (DECODE (rn, 1, NVL (ati_wu, ati_cu)))      FIRST_VALUE,
                   MAX (DECODE (rn, cnt, NVL (ati_wu, ati_cu)))    LAST_VALUE
              FROM (SELECT s.ati_wu,
                           s.ati_cu,
                           ROW_NUMBER ()
                               OVER (ORDER BY NVL (s.ati_order, s.ati_id))
                               rn,
                           COUNT (*) OVER ()
                               cnt
                      FROM at_signers s, at_document d
                     WHERE     s.ati_at = p_at_id
                           AND s.history_status = 'A'
                           AND d.atd_id = s.ati_atd
                           AND d.history_status = 'A'
                           AND d.atd_ndt = NVL (p_ndt, d.atd_ndt));

        l_sng1   NUMBER;
        l_sng2   NUMBER;
        l_cnt    NUMBER;
    BEGIN
        OPEN c (p_ndt => p_ndt);

        FETCH c INTO l_cnt, l_sng1, l_sng2;

        CLOSE c;

        IF l_cnt = 0
        THEN
            OPEN c (p_ndt => NULL);

            FETCH c INTO l_cnt, l_sng1, l_sng2;

            CLOSE c;
        END IF;

        RETURN CASE p_order WHEN 1 THEN l_sng1 WHEN 2 THEN l_sng2 END;
    END;

    --надавач послуги
    FUNCTION Get_Nsp_Name (p_Rnspm_Id Uss_Rnsp.v_Rnsp.Rnspm_Id%TYPE)
        RETURN VARCHAR2
    IS
        CURSOR Cur IS
            SELECT TRIM (
                       REPLACE (
                           (CASE r.Rnspm_Tp
                                WHEN 'O'
                                THEN
                                    COALESCE (r.Rnsps_Last_Name,
                                              r.Rnsps_First_Name)
                                ELSE
                                       r.Rnsps_Last_Name
                                    || ' '
                                    || r.Rnsps_First_Name
                                    || ' '
                                    || r.Rnsps_Middle_Name
                            END),
                           '  '))
              FROM Uss_Rnsp.v_Rnsp r
             WHERE r.Rnspm_Id = p_Rnspm_Id;

        RESULT   VARCHAR2 (1000);
    BEGIN
        OPEN Cur;

        FETCH Cur INTO RESULT;

        CLOSE Cur;

        RETURN RESULT;
    END;


    --------------------------------------------------------------------------

    --#91558 Повідомлення про надання / відмову в наданні соціальних послуг»
    FUNCTION Fill_Attrs_850 (p_at_id IN NUMBER)
        RETURN t_At_Document_Attrs
    IS
        l_Attrs         t_At_Document_Attrs;

        CURSOR c_at IS
            SELECT a.at_ap,
                   a.at_pc,
                   a.at_org,
                   a.at_num,
                   a.at_dt,
                   sc.sc_unique,
                   p.atp_id,
                   pc.pc_id,
                   pc.pc_sc,
                   p.atp_app_tp,
                   apop.at_conclusion_tp     AS apop_conclusion_tp
              FROM uss_esr.act              a,
                   uss_esr.personalcase     pc,
                   uss_esr.At_Person        p,
                   uss_person.v_socialcard  sc
                   LEFT JOIN act apop
                       ON (    apop.at_main_link = p_at_id
                           AND apop.at_st NOT IN ('AD', 'AR'))
             WHERE     a.at_id = p_at_id
                   AND pc.pc_id = a.at_pc
                   AND p.atp_at = a.at_id
                   AND p.atp_sc = pc.pc_sc
                   AND sc.sc_id = a.at_sc;

        l_at            c_at%ROWTYPE;

        l_Ap            Appeal%ROWTYPE;
        l_Sci_z         Uss_Person.v_Sc_Identity%ROWTYPE;
        l_Sci_Os        Uss_Person.v_Sc_Identity%ROWTYPE;
        l_At_Calc       At_Income_Calc%ROWTYPE;

        l_Spec_Wu       NUMBER;
        l_Spec_Wu_Pib   Tools.r_Pib;
        l_Boss_Wu       NUMBER;
        l_Cnt           NUMBER;
        l_Boss_Wu_Pib   Tools.r_Pib;
    BEGIN
        --Отримуємо інформацію про рішення
        OPEN c_at;

        FETCH c_at INTO l_at;

        CLOSE c_at;

        --Отримуємо інформацію про звернення
        SELECT *
          INTO l_Ap
          FROM Appeal a
         WHERE a.Ap_Id = l_at.at_ap;

        --Отримуємо ПІБ заявника
        l_Sci_z := Get_App_Sci (l_at.at_ap, 'Z');
        --Отримуємо ПІБ отримувача
        l_Sci_Os := Get_App_Sci (l_at.at_ap, 'OS');

        --Отримуємо інформацію про доходи
        BEGIN
            SELECT *
              INTO l_At_Calc
              FROM At_Income_Calc c
             WHERE c.aic_at = p_at_Id AND c.aic_pc = l_at.pc_id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;

        --Отримуємо інформацію про спеціаліста та керівника
        /*select max(decode(rn, 1, ati_wu)) first_value, max(decode(rn, cnt, ati_wu)) last_value
          INTO l_Spec_Wu, l_Boss_Wu
          from
            (
             select s.ati_wu,
                    row_number() over(order by nvl(s.ati_order, s.ati_id)) rn,
                    count(*) over() cnt
               from at_signers s, at_document d
              where s.ati_at = p_at_id and s.history_status = 'A'
                and d.atd_id = s.ati_atd and d.history_status = 'A'
                and d.atd_ndt = 850
            );*/
        l_Spec_Wu :=
            get_at_signers (p_at_id => p_at_id, p_order => 1, p_ndt => 850);
        l_Boss_Wu :=
            get_at_signers (p_at_id => p_at_id, p_order => 2, p_ndt => 850);

        --Отримуємо інформацію про спеціаліста з опрацювання заяв
        Tools.Split_Pib (Tools.Getuserpib (l_Spec_Wu), l_Spec_Wu_Pib);
        --Отримуємо інформацію про керівника уповноваженого органу
        Tools.Split_Pib (Tools.Getuserpib (l_Boss_Wu), l_Boss_Wu_Pib);

        Add_Attr (l_Attrs, 2934, p_Val_Dt => TRUNC (SYSDATE)    /*l_at.at_Dt*/
                                                            );
        Add_Attr (l_Attrs, 2935, p_Val_Str => l_at.at_num);
        Add_Attr (l_Attrs,
                  2936,
                  p_Val_Str   => tools.GetOrgName (l_at.at_org),
                  p_Val_Id    => l_at.at_org);
        Add_Attr (l_Attrs, 2937, p_Val_Dt => l_Ap.Ap_Reg_Dt);
        Add_Attr (l_Attrs, 2938, p_Val_Str => l_Ap.Ap_Num);
        Add_Attr (l_Attrs, 2939, p_Val_Str => l_Sci_z.Sci_Ln);
        Add_Attr (l_Attrs, 2940, p_Val_Str => l_Sci_z.Sci_Fn);
        Add_Attr (l_Attrs, 2941, p_Val_Str => l_Sci_z.Sci_Mn);
        Add_Attr (l_Attrs, 2942, p_Val_Str => l_Sci_Os.Sci_Ln);
        Add_Attr (l_Attrs, 2943, p_Val_Str => l_Sci_Os.Sci_Fn);
        Add_Attr (l_Attrs, 2944, p_Val_Str => l_Sci_Os.Sci_Mn);

        --Add_Attr(l_Attrs, 2945, p_Val_Str => Coalesce(get_AtDocAtrStr(p_at_id, 2039), get_AtDocAtrStr(p_at_id, 2061)));  --результат оцінювання потреб особи/сім’ї

        SELECT COUNT (*)
          INTO l_cnt
          FROM (  SELECT ROW_NUMBER () OVER (ORDER BY nst.nst_order)     AS rn,
                         nst.nst_name                                    AS c1,
                         --Uss_Ndi.v_Ddn_Ss_Method
                         Api$Act_Rpt.chk_val2 (s.Ats_ss_method, 'F')     AS c2,
                         Api$Act_Rpt.chk_val2 (s.Ats_ss_method, 'C')     AS c3,
                         Api$Act_Rpt.chk_val2 (s.Ats_ss_method, 'D')     AS c4
                    FROM uss_esr.at_service s, Uss_Ndi.v_Ndi_Service_Type nst
                   WHERE     1 = 1
                         AND s.history_status = 'A'
                         AND s.ats_st IN ('PP',
                                          'SG',
                                          'P',
                                          'R')
                         AND nst.nst_id = s.ats_nst
                         AND s.ats_at = p_at_id
                ORDER BY rn) t;

        Add_Attr (
            l_Attrs,
            2945,
            p_Val_Str   =>
                CASE WHEN l_cnt > 0 THEN 'потребує' ELSE 'не потребує' END);                   --результат оцінювання потреб особи/сім’ї
        --Add_Attr(l_Attrs, 2945, p_Val_Str => CASE WHEN CASE WHEN l_at.apop_conclusion_tp = 'V1' THEN get_AtLinkedDocAtrStr(p_at_id, 2061) ELSE get_AtLinkedDocAtrStr(p_at_id, 2039) END = 'T' THEN 'потребує' ELSE 'не потребує' END);  --результат оцінювання потреб особи/сім’ї
        Add_Attr (l_Attrs,
                  2946,
                  p_Val_Id    => Get_At_Feature_Id (p_at_id, 9),
                  p_Val_Str   => Get_At_Feature_Str (p_at_id, 9)); --надавач соціальної послуги
        Add_Attr (l_Attrs, 2947, p_Val_Sum => l_At_Calc.Aic_Total_Income_6m);
        Add_Attr (l_Attrs, 2948, p_Val_Sum => l_At_Calc.Aic_Month_Income);
        Add_Attr (l_Attrs,
                  2949,
                  p_Val_Sum   => l_At_Calc.Aic_Member_Month_Income);
        Add_Attr (l_Attrs, 2950, p_Val_Sum => l_At_Calc.Aic_Limit);
        Add_Attr (l_Attrs, 2951, p_Val_Str => AtSrv_Nst_List (p_at_id, 1)); --надати соціальну послугу
        Add_Attr (l_Attrs, 2953, p_Val_Str => AtSrvMetod (p_at_id)); --uss_ndi.V_DDN_SS_METHOD cпосіб надання соціальних послуг
        Add_Attr (l_Attrs, 4286, p_Val_Str => AtSrv_Nst_List (p_at_id, 0)); --відмовити соціальну послугу
        Add_Attr (l_Attrs, 2954, p_Val_Str => Get_At_Reject_List (p_at_id)); --причина відмови
        Add_Attr (l_Attrs, 3082);      --посада спеціаліста з опрацювання заяв
        Add_Attr (l_Attrs, 2955, p_Val_Str => l_Spec_Wu_Pib.LN);
        Add_Attr (l_Attrs, 2956, p_Val_Str => l_Spec_Wu_Pib.Fn);
        Add_Attr (l_Attrs, 2957, p_Val_Str => l_Spec_Wu_Pib.Mn);
        Add_Attr (l_Attrs, 3083);                           --посада керівника
        Add_Attr (l_Attrs, 2958, p_Val_Str => l_Boss_Wu_Pib.LN);
        Add_Attr (l_Attrs, 2959, p_Val_Str => l_Boss_Wu_Pib.Fn);
        Add_Attr (l_Attrs, 2960, p_Val_Str => l_Boss_Wu_Pib.Mn);
        RETURN l_Attrs;
    END;

    --#91558
    FUNCTION Fill_Attrs_851 (p_at_id IN NUMBER)
        RETURN t_At_Document_Attrs
    IS
        l_Attrs         t_At_Document_Attrs;

        CURSOR c_at IS
            SELECT a.at_ap,
                   a.at_pc,
                   a.at_org,
                   a.at_num,
                   a.at_dt,
                   a.At_Rnspm,
                   sc.sc_unique,
                   p.atp_id,
                   pc.pc_sc,
                   p.atp_app_tp
              FROM uss_esr.act              a,
                   uss_esr.personalcase     pc,
                   uss_esr.At_Person        p,
                   uss_person.v_socialcard  sc
             WHERE     a.at_id = p_at_id
                   AND pc.pc_id = a.at_pc
                   AND p.atp_at = a.at_id
                   AND p.atp_sc = pc.pc_sc
                   AND sc.sc_id = a.at_sc;

        l_at            c_at%ROWTYPE;

        l_Sci_z         Uss_Person.v_Sc_Identity%ROWTYPE;
        l_Sci_Os        Uss_Person.v_Sc_Identity%ROWTYPE;
        l_Boss_Wu       NUMBER;
        l_Boss_Wu_Pib   Tools.r_Pib;
        l_str           VARCHAR2 (500);
    BEGIN
        --Отримуємо інформацію про рішення
        OPEN c_at;

        FETCH c_at INTO l_at;

        CLOSE c_at;

        --Отримуємо ПІБ заявника
        l_Sci_z := Get_App_Sci (l_at.at_ap, 'Z');
        --Отримуємо ПІБ отримувача
        l_Sci_Os := Get_App_Sci (l_at.at_ap, 'OS');

        --Отримуємо інформацію про підписанта(керівника)
        /*select max(decode(rn, cnt, ati_wu)) last_value
          INTO l_Boss_Wu
          from
            (
             select s.ati_wu,
                    row_number() over(order by nvl(s.ati_order, s.ati_id)) rn,
                    count(*) over() cnt
               from at_signers s, at_document d
              where s.ati_at = p_at_id and s.history_status = 'A'
                and d.atd_id = s.ati_atd and d.history_status = 'A'
                and d.atd_ndt = 851
            );*/
        l_Boss_Wu :=
            get_at_signers (p_at_id => p_at_id, p_order => 2, p_ndt => 851);

        --Отримуємо інформацію про керівника уповноваженого органу
        Tools.Split_Pib (Tools.Getuserpib (l_Boss_Wu), l_Boss_Wu_Pib);

        Add_Attr (l_Attrs,
                  2975,
                  p_Val_Id    => l_at.at_org,
                  p_Val_Str   => tools.GetOrgName (l_at.at_org));
        Add_Attr (l_Attrs, 2961, p_Val_Dt => get_AtDocAtrDt (p_at_id, 2934));
        Add_Attr (l_Attrs, 2962, p_Val_Str => l_at.at_num);
        Add_Attr (l_Attrs, 2963, p_Val_Str => l_Sci_z.Sci_Ln);
        Add_Attr (l_Attrs, 2964, p_Val_Str => l_Sci_z.Sci_Fn);
        Add_Attr (l_Attrs, 2965, p_Val_Str => l_Sci_z.Sci_Mn);
        --Індекс проживання
        Add_Attr (
            l_Attrs,
            2966,
            p_Val_Id   => Api$appeal.Get_Ap_z_Doc_Id (l_at.at_ap, 801, 1874),
            p_Val_Str   =>
                Api$appeal.Get_Ap_z_Doc_String (l_at.at_ap, 801, 1874));
        --КАТОТТГ
        Add_Attr (
            l_Attrs,
            2967,
            p_Val_Id   => Api$appeal.Get_Ap_z_Doc_Id (l_at.at_ap, 801, 1873),
            p_Val_Str   =>
                Api$appeal.Get_Ap_z_Doc_String (l_at.at_ap, 801, 1873));

        -- Вулиця
        SELECT MAX (
                      st.nsrt_name
                   || CASE WHEN ns_name IS NOT NULL THEN ' ' END
                   || ns_name)
          INTO l_str
          FROM uss_ndi.v_ndi_street  t
               LEFT JOIN uss_ndi.v_ndi_street_type st
                   ON (st.nsrt_id = t.ns_nsrt)
         WHERE t.ns_id = Api$appeal.Get_Ap_z_Doc_Id (l_at.at_ap, 801, 1879);

        Add_Attr (
            l_Attrs,
            2968,
            p_Val_Id   => Api$appeal.Get_Ap_z_Doc_Id (l_at.at_ap, 801, 1879),
            p_Val_Str   =>
                NVL (l_str,
                     Api$appeal.Get_Ap_z_Doc_String (l_at.at_ap, 801, 1878)));
        --Будинок
        Add_Attr (
            l_Attrs,
            2969,
            p_Val_Str   =>
                Api$appeal.Get_Ap_z_Doc_String (l_at.at_ap, 801, 1880));
        --Корпус
        Add_Attr (
            l_Attrs,
            2970,
            p_Val_Str   =>
                Api$appeal.Get_Ap_z_Doc_String (l_at.at_ap, 801, 1881));
        --Квартира
        Add_Attr (
            l_Attrs,
            2971,
            p_Val_Str   =>
                Api$appeal.Get_Ap_z_Doc_String (l_at.at_ap, 801, 1882));
        --ПІБ отримувача
        Add_Attr (l_Attrs, 2972, p_Val_Str => l_Sci_Os.Sci_Ln);
        Add_Attr (l_Attrs, 2973, p_Val_Str => l_Sci_Os.Sci_Fn);
        Add_Attr (l_Attrs, 2974, p_Val_Str => l_Sci_Os.Sci_Mn);
        --прийняте рішення
        Add_Attr (
            l_Attrs,
            2997,
            p_Val_Str   =>
                CASE
                    WHEN     AtSrv_Nst_List (p_at_id, 1) IS NOT NULL
                         AND AtSrv_Nst_List (p_at_id, 0) IS NULL
                    THEN
                        'T'                         --надати соціальну послугу
                    WHEN     AtSrv_Nst_List (p_at_id, 1) IS NULL
                         AND AtSrv_Nst_List (p_at_id, 0) IS NOT NULL
                    THEN
                        'F'                                        --відмовити
                END);        -- прийняте рішення uss_ndi.V_DDN_RNSP_PROVIDE_SS
        --надавач соціальної послуги
        --Add_Attr(l_Attrs, 3084, p_Val_Id => Get_At_Feature_Id(p_at_id, 9), p_Val_Str => Get_At_Feature_Str(p_at_id, 9));
        Add_Attr (l_Attrs,
                  3084,
                  p_Val_Id    => l_at.At_Rnspm,
                  p_Val_Str   => Get_Nsp_Name (p_Rnspm_Id => l_at.At_Rnspm));
        Add_Attr (l_Attrs, 2976, p_Val_Str => AtSrvMetod (p_at_id)); --uss_ndi.V_DDN_SS_METHOD cпосіб надання соціальних послуг
        Add_Attr (l_Attrs, 2977, Get_At_Reject_List (p_at_id)); --Причина відмови
        Add_Attr (l_Attrs, 3085, NULL);                     --посада керівника
        Add_Attr (l_Attrs, 2978, p_Val_Str => l_Boss_Wu_Pib.LN);
        Add_Attr (l_Attrs, 2979, p_Val_Str => l_Boss_Wu_Pib.Fn);
        Add_Attr (l_Attrs, 2980, p_Val_Str => l_Boss_Wu_Pib.Mn);

        Add_Attr (l_Attrs, 5348, p_Val_Dt => TRUNC (SYSDATE)); --дата повідомлення

        RETURN l_Attrs;
    END;

    --#91558
    FUNCTION Fill_Attrs_852 (p_at_id IN NUMBER)
        RETURN t_At_Document_Attrs
    IS
        l_Attrs          t_At_Document_Attrs;

        CURSOR c_at IS
            SELECT a.at_ap,
                   a.at_pc,
                   a.at_org,
                   a.at_num,
                   a.at_dt,
                   sc.sc_unique,
                   p.atp_id,
                   pc.pc_sc,
                   p.atp_app_tp
              FROM uss_esr.act              a,
                   uss_esr.personalcase     pc,
                   uss_esr.At_Person        p,
                   uss_person.v_socialcard  sc
             WHERE     a.at_id = p_at_id
                   AND pc.pc_id = a.at_pc
                   AND p.atp_at = a.at_id
                   AND p.atp_sc = pc.pc_sc
                   AND sc.sc_id = a.at_sc;

        l_at             c_at%ROWTYPE;

        l_Ap             Appeal%ROWTYPE;
        l_Org_Name       VARCHAR2 (250);
        l_Org_Org_Id     NUMBER;
        l_Org_Org_Name   VARCHAR2 (250);
        l_Sci_z          Uss_Person.v_Sc_Identity%ROWTYPE;
        l_Sci_Os         Uss_Person.v_Sc_Identity%ROWTYPE;
        l_Boss_Wu        NUMBER;
        l_Boss_Wu_Pib    Tools.r_Pib;
    BEGIN
        OPEN c_at;

        FETCH c_at INTO l_at;

        CLOSE c_at;

        --Отримуємо ПІБ заявника
        l_Sci_z := Get_App_Sci (l_at.at_ap, 'Z');
        --Отримуємо ПІБ отримувача
        l_Sci_Os := Get_App_Sci (l_at.at_ap, 'OS');

        --Отримуємо інформацію про звернення
        SELECT *
          INTO l_Ap
          FROM Appeal a
         WHERE a.Ap_Id = l_at.at_ap;

        --Отримуємо назву СПСЗН
        SELECT o.Org_Name,
               CASE
                   WHEN oo.org_to = 31 THEN Oo.Org_Name
                   ELSE oo2.org_name
               END,
               CASE WHEN oo.org_to = 31 THEN Oo.Org_Id ELSE oo2.Org_Id END
          INTO l_Org_Name, l_Org_Org_Name, l_Org_Org_Id
          FROM v_Opfu  o
               LEFT JOIN v_Opfu Oo ON o.Org_Org = Oo.Org_Id
               LEFT JOIN v_Opfu Oo2 ON oo.Org_Org = Oo2.Org_Id
         WHERE o.Org_Id = l_at.at_org;

        --Отримуємо інформацію про підписанта(керівника)
        /*select max(decode(rn, cnt, ati_wu)) last_value
          INTO l_Boss_Wu
          from
            (
             select s.ati_wu,
                    row_number() over(order by nvl(s.ati_order, s.ati_id)) rn,
                    count(*) over() cnt
               from at_signers s, at_document d
              where s.ati_at = p_at_id and s.history_status = 'A'
                and d.atd_id = s.ati_atd and d.history_status = 'A'
                and d.atd_ndt = 852
            );*/

        l_Boss_Wu :=
            get_at_signers (p_at_id => p_at_id, p_order => 2, p_ndt => 852);
        --Отримуємо інформацію про керівника уповноваженого органу
        Tools.Split_Pib (Tools.Getuserpib (l_Boss_Wu), l_Boss_Wu_Pib);

        Add_Attr (l_Attrs,
                  2982,
                  p_Val_Id    => l_Org_Org_Id,
                  p_Val_Str   => l_Org_Org_Name);
        Add_Attr (l_Attrs, 2983, p_Val_Str => l_Sci_z.Sci_Ln);
        Add_Attr (l_Attrs, 2984, p_Val_Str => l_Sci_z.Sci_Fn);
        Add_Attr (l_Attrs, 2985, p_Val_Str => l_Sci_z.Sci_Mn);
        Add_Attr (l_Attrs, 2986, p_Val_Dt => l_Ap.Ap_Reg_Dt);
        Add_Attr (l_Attrs, 2987, p_Val_Str => l_Ap.Ap_Num);
        Add_Attr (l_Attrs,
                  2988,
                  p_Val_Id    => l_at.at_org,
                  p_Val_Str   => l_Org_Name);
        Add_Attr (l_Attrs, 2989, p_Val_Str => l_Sci_Os.Sci_Ln);
        Add_Attr (l_Attrs, 2990, p_Val_Str => l_Sci_Os.Sci_Fn);
        Add_Attr (l_Attrs, 2991, p_Val_Str => l_Sci_Os.Sci_Mn);
        Add_Attr (l_Attrs, 2992, p_Val_Str => AtSrvMetod (p_at_id));
        Add_Attr (l_Attrs, 2993, NULL);                    --посада підписанта
        Add_Attr (l_Attrs, 2994, p_Val_Str => l_Boss_Wu_Pib.LN);
        Add_Attr (l_Attrs, 2995, p_Val_Str => l_Boss_Wu_Pib.Fn);
        Add_Attr (l_Attrs, 2996, p_Val_Str => l_Boss_Wu_Pib.Mn);

        RETURN l_Attrs;
    END;

    --#91558
    FUNCTION Fill_Attrs_853 (p_at_id IN NUMBER)
        RETURN t_At_Document_Attrs
    IS
        l_Attrs          t_At_Document_Attrs;

        CURSOR c_at IS
            SELECT a.at_ap,
                   a.at_pc,
                   a.at_org,
                   a.at_num,
                   a.at_dt,
                   sc.sc_unique,
                   p.atp_id,
                   pc.pc_sc,
                   pc.pc_id,
                   p.atp_app_tp,
                   o.org_name,
                   o.org_to
              FROM uss_esr.act              a,
                   uss_esr.personalcase     pc,
                   uss_esr.At_Person        p,
                   uss_person.v_socialcard  sc,
                   v_opfu                   o
             WHERE     a.at_id = p_at_id
                   AND pc.pc_id = a.at_pc
                   AND p.atp_at = a.at_id
                   AND p.atp_sc = pc.pc_sc
                   AND sc.sc_id = a.at_sc
                   AND o.org_id = a.at_org;

        l_at             c_at%ROWTYPE;

        l_Ap             Appeal%ROWTYPE;
        l_At_Calc        At_Income_Calc%ROWTYPE;
        l_Org_Org_Id     NUMBER;
        l_Org_Org_Name   VARCHAR2 (250);
        l_Sci_z          Uss_Person.v_Sc_Identity%ROWTYPE;
        l_Sci_Os         Uss_Person.v_Sc_Identity%ROWTYPE;
        l_Boss_Wu        NUMBER;
        l_Boss_Wu_Pib    Tools.r_Pib;
    BEGIN
        OPEN c_at;

        FETCH c_at INTO l_at;

        CLOSE c_at;

        --Отримуємо ПІБ заявника
        l_Sci_z := Get_App_Sci (l_at.at_ap, 'Z');
        --Отримуємо ПІБ отримувача
        l_Sci_Os := Get_App_Sci (l_at.at_ap, 'OS');

        --Отримуємо інформацію про звернення
        SELECT *
          INTO l_Ap
          FROM Appeal a
         WHERE a.Ap_Id = l_at.at_ap;

        --Отримуємо інформацію про доходи
        BEGIN
            SELECT *
              INTO l_At_Calc
              FROM At_Income_Calc c
             WHERE c.aic_at = p_at_Id AND c.aic_pc = l_at.pc_id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;

        --Отримуємо інформацію про підписанта(керівника)
        /*select max(decode(rn, cnt, ati_wu)) last_value
          INTO l_Boss_Wu
          from
            (
             select s.ati_wu,
                    row_number() over(order by nvl(s.ati_order, s.ati_id)) rn,
                    count(*) over() cnt
               from at_signers s, at_document d
              where s.ati_at = p_at_id and s.history_status = 'A'
                and d.atd_id = s.ati_atd and d.history_status = 'A'
                and d.atd_ndt = 853
            );*/

        l_Boss_Wu :=
            get_at_signers (p_at_id => p_at_id, p_order => 2, p_ndt => 853);
        Tools.Split_Pib (Tools.Getuserpib (l_Boss_Wu), l_Boss_Wu_Pib);

        IF l_at.org_to > 31
        THEN
                SELECT MAX (CASE WHEN po.org_to IN (31, 34) THEN po.org_name END)
                  INTO l_Org_Org_Name
                  FROM opfu po
                 WHERE po.org_st = 'A'
            START WITH po.org_id = l_at.at_org
            CONNECT BY PRIOR po.org_org = po.org_id;
        ELSE
            l_Org_Org_Name := l_at.org_name;
        END IF;

        Add_Attr (l_Attrs, 2998, p_Val_Str => l_Sci_z.Sci_Ln);
        Add_Attr (l_Attrs, 2999, p_Val_Str => l_Sci_z.Sci_Fn);
        Add_Attr (l_Attrs, 3000, p_Val_Str => l_Sci_z.Sci_Mn);

        --Місце фактичного проживання
        Add_Attr (
            l_Attrs,
            3001,
            p_Val_Str   =>
                Api$appeal.Get_Ap_Doc_Str (l_at.at_ap, l_at.atp_app_tp, 1625)); --Індекс
        Add_Attr (
            l_Attrs,
            3002,
            p_Val_Str   =>
                Api$appeal.Get_Ap_Doc_Str (l_at.at_ap, l_at.atp_app_tp, 1618)); --КАТОТТГ
        Add_Attr (
            l_Attrs,
            3003,
            p_Val_Str   =>
                COALESCE (
                    Api$appeal.Get_Ap_Doc_Str (l_at.at_ap,
                                               l_at.atp_app_tp,
                                               1632),
                    Api$appeal.Get_Ap_Doc_Str (l_at.at_ap,
                                               l_at.atp_app_tp,
                                               1640)));              -- Вулиця
        Add_Attr (
            l_Attrs,
            3004,
            p_Val_Str   =>
                Api$appeal.Get_Ap_Doc_Str (l_at.at_ap, l_at.atp_app_tp, 1648)); --Будинок
        Add_Attr (
            l_Attrs,
            3005,
            p_Val_Str   =>
                Api$appeal.Get_Ap_Doc_Str (l_at.at_ap, l_at.atp_app_tp, 1654)); --Корпус
        Add_Attr (
            l_Attrs,
            3006,
            p_Val_Str   =>
                Api$appeal.Get_Ap_Doc_Str (l_at.at_ap, l_at.atp_app_tp, 1659)); --Квартира

        Add_Attr (l_Attrs,
                  3007,
                  p_Val_Id    => l_at.at_org,
                  p_Val_Str   => l_at.Org_Name); --найменування СПСЗН місцевого рівня
        Add_Attr (l_Attrs, 3008, p_Val_Dt => l_Ap.Ap_Reg_Dt);
        Add_Attr (l_Attrs, 3009, p_Val_Str => l_Ap.Ap_Num);
        Add_Attr (l_Attrs,
                  3010,
                  p_Val_Id    => l_Org_Org_Id,
                  p_Val_Str   => l_Org_Org_Name); --найменування СПСЗН обласного рівня
        Add_Attr (l_Attrs, 3011, p_Val_Dt => SYSDATE);
        Add_Attr (l_Attrs, 3012, p_Val_Str => l_Sci_Os.Sci_Ln);
        Add_Attr (l_Attrs, 3013, p_Val_Str => l_Sci_Os.Sci_Fn);
        Add_Attr (l_Attrs, 3014, p_Val_Str => l_Sci_Os.Sci_Mn);
        Add_Attr (l_Attrs,
                  3015,
                  p_Val_Sum   => l_At_Calc.Aic_Member_Month_Income);
        Add_Attr (l_Attrs, 3016, p_Val_Str => AtSrvMetod (p_at_id)); --uss_ndi.V_DDN_SS_METHOD cпосіб надання соціальних послуг
        Add_Attr (l_Attrs, 3017, p_Val_Str => l_Boss_Wu_Pib.LN);
        Add_Attr (l_Attrs, 3018, p_Val_Str => l_Boss_Wu_Pib.Fn);
        Add_Attr (l_Attrs, 3019, p_Val_Str => l_Boss_Wu_Pib.Mn);

        RETURN l_Attrs;
    END;

    --#91558
    FUNCTION Fill_Attrs_854 (p_at_id IN NUMBER)
        RETURN t_At_Document_Attrs
    IS
        l_Attrs          t_At_Document_Attrs;

        CURSOR c_at IS
            SELECT a.at_ap,
                   a.at_pc,
                   a.at_org,
                   a.at_num,
                   a.at_dt,
                   sc.sc_unique,
                   p.atp_id,
                   pc.pc_id,
                   pc.pc_sc,
                   p.atp_app_tp,
                   p.atp_birth_dt,
                   o.org_name,
                   o.org_to
              FROM uss_esr.act              a,
                   uss_esr.personalcase     pc,
                   uss_esr.At_Person        p,
                   uss_person.v_socialcard  sc,
                   v_opfu                   o
             WHERE     a.at_id = p_at_id
                   AND pc.pc_id = a.at_pc
                   AND p.atp_at = a.at_id
                   AND p.atp_sc = pc.pc_sc
                   AND sc.sc_id = a.at_sc
                   AND o.org_id = a.at_org;

        l_at             c_at%ROWTYPE;

        TYPE tAdr IS RECORD
        (
            indx     AT_DOCUMENT_ATTR.ATDA_VAL_STRING%TYPE,           --Індекс
            katot    AT_DOCUMENT_ATTR.ATDA_VAL_STRING%TYPE,          --КАТОТТГ
            strit    AT_DOCUMENT_ATTR.ATDA_VAL_STRING%TYPE,           --вулиця
            bild     AT_DOCUMENT_ATTR.ATDA_VAL_STRING%TYPE,          --будинок
            korp     AT_DOCUMENT_ATTR.ATDA_VAL_STRING%TYPE,           --Корпус
            apart    AT_DOCUMENT_ATTR.ATDA_VAL_STRING%TYPE          --квартира
        );

        rAdr_reg         tAdr;
        rAdr_fakt        tAdr;

        CURSOR c_ftr IS
            SELECT MAX (DECODE (atf_nft, 3, f.atf_val_string))
                       AS a_3026,                         --група інвалідності
                   MAX (DECODE (atf_nft, 9, f.atf_val_string))
                       AS a_3021,  --найменування інтернатної установи/закладу
                   MAX (DECODE (atf_nft, 9, f.atf_val_id))
                       AS a_3021_id,
                   MAX (DECODE (atf_nft, 11, f.atf_val_dt))
                       AS a_3048,                      --Термін перебування по
                   MAX (DECODE (atf_nft, 12, f.atf_val_dt))
                       AS a_3047,                       --Термін перебування з
                   MAX (DECODE (atf_nft, 13, f.atf_val_dt))
                       AS a_3045,                       --Строк дії путівки по
                   MAX (DECODE (atf_nft, 14, f.atf_val_dt))
                       AS a_3044,                        --Строк дії путівки з
                   MAX (DECODE (atf_nft, 81, f.atf_val_string))
                       AS a_3046                            -- Тип перебування
              FROM at_features f
             WHERE     f.atf_at = p_at_Id
                   AND f.atf_nft IN (3,
                                     9,
                                     11,
                                     12,
                                     13,
                                     14,
                                     81);

        l_ftr            c_ftr%ROWTYPE;

        l_At_Calc        At_Income_Calc%ROWTYPE;
        l_Org_Name       VARCHAR2 (250);
        l_Org_Org_Id     NUMBER;
        l_Org_Org_Name   VARCHAR2 (250);
        l_Sci_Os         Uss_Person.v_Sc_Identity%ROWTYPE;
        l_birth_dt       DATE;
        l_Boss_Wu        NUMBER;
        l_Boss_Wu2       NUMBER;
        l_Boss_Wu_Pib    Tools.r_Pib;
        l_Boss_Wu_Pib2   Tools.r_Pib;
    BEGIN
        OPEN c_at;

        FETCH c_at INTO l_at;

        CLOSE c_at;

        --Отримуємо ПІБ отримувача
        l_Sci_Os := Get_App_Sci (l_at.at_ap, 'OS');

        --день народження
        SELECT MAX (i.sco_birth_dt)
          INTO l_birth_dt
          FROM uss_person.v_sc_info i
         WHERE i.sco_id = l_Sci_Os.sci_sc;

        l_birth_dt := NVL (l_birth_dt, l_at.atp_birth_dt);

        --Отримуємо інформацію про доходи
        BEGIN
            SELECT *
              INTO l_At_Calc
              FROM At_Income_Calc c
             WHERE c.aic_at = p_at_Id AND c.aic_pc = l_at.pc_id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;

        --Отримуємо назву СПСЗН
        SELECT o.Org_Name, Oo.Org_Name, Oo.Org_Id
          INTO l_Org_Name, l_Org_Org_Name, l_Org_Org_Id
          FROM v_Opfu o LEFT JOIN v_Opfu Oo ON o.Org_Org = Oo.Org_Id
         WHERE o.Org_Id = l_at.at_org;

        --Отримуємо інформацію про спеціаліста та керівника
        /*select max(decode(rn, 1, ati_wu)) first_value, max(decode(rn, cnt, ati_wu)) last_value
          INTO l_boss_wu2, l_boss_wu
          from
            (
             select s.ati_wu,
                    row_number() over(order by nvl(s.ati_order, s.ati_id)) rn,
                    count(*) over() cnt
               from at_signers s, at_document d
              where s.ati_at = p_at_id and s.history_status = 'A'
                and d.atd_id = s.ati_atd and d.history_status = 'A'
                and d.atd_ndt = 854
            );*/
        l_boss_wu2 :=
            get_at_signers (p_at_id => p_at_id, p_order => 1, p_ndt => 854);
        l_Boss_Wu :=
            get_at_signers (p_at_id => p_at_id, p_order => 2, p_ndt => 854);

        --Отримуємо інформацію про підписанта(керівника) СПСЗН
        Tools.Split_Pib (Tools.Getuserpib (l_Boss_Wu), l_Boss_Wu_Pib);
        --Отримуємо інформацію про керівника підрозділу з питань діяльності інтернатних установ
        Tools.Split_Pib (Tools.Getuserpib (l_Boss_Wu2), l_Boss_Wu_Pib2);

        -- дані путівки, ets
        OPEN c_ftr;

        FETCH c_ftr INTO l_ftr;

        CLOSE c_ftr;

        --Місце фактичного проживання
        rAdr_fakt.indx :=
            Api$appeal.Get_Ap_Doc_Str (l_at.at_ap, l_at.atp_app_tp, 1625);
        rAdr_fakt.katot :=
            Api$appeal.Get_Ap_Doc_Str (l_at.at_ap, l_at.atp_app_tp, 1618);
        rAdr_fakt.strit :=
            COALESCE (
                Api$appeal.Get_Ap_Doc_Str (l_at.at_ap, l_at.atp_app_tp, 1632),
                Api$appeal.Get_Ap_Doc_Str (l_at.at_ap, l_at.atp_app_tp, 1640));
        rAdr_fakt.bild :=
            Api$appeal.Get_Ap_Doc_Str (l_at.at_ap, l_at.atp_app_tp, 1648);
        rAdr_fakt.korp :=
            Api$appeal.Get_Ap_Doc_Str (l_at.at_ap, l_at.atp_app_tp, 1654);
        rAdr_fakt.apart :=
            Api$appeal.Get_Ap_Doc_Str (l_at.at_ap, l_at.atp_app_tp, 1659);
        --Реєстрація
        rAdr_reg.indx :=
            Api$appeal.Get_Ap_Doc_Str (l_at.at_ap, l_at.atp_app_tp, 1489);
        rAdr_reg.katot :=
            Api$appeal.Get_Ap_Doc_Str (l_at.at_ap, l_at.atp_app_tp, 1488);
        rAdr_reg.strit :=
            COALESCE (
                Api$appeal.Get_Ap_Doc_Str (l_at.at_ap, l_at.atp_app_tp, 1490),
                Api$appeal.Get_Ap_Doc_Str (l_at.at_ap, l_at.atp_app_tp, 1591));
        rAdr_reg.bild :=
            Api$appeal.Get_Ap_Doc_Str (l_at.at_ap, l_at.atp_app_tp, 1599);
        rAdr_reg.korp :=
            Api$appeal.Get_Ap_Doc_Str (l_at.at_ap, l_at.atp_app_tp, 1605);
        rAdr_reg.apart :=
            Api$appeal.Get_Ap_Doc_Str (l_at.at_ap, l_at.atp_app_tp, 1611);

        Add_Attr (l_Attrs, 3020, p_Val_Str => 'П' || p_at_id);
        Add_Attr (l_Attrs,
                  3021,
                  p_Val_Id    => l_ftr.a_3021_id,
                  p_Val_Str   => l_ftr.a_3021); --найменування інтернатної установи/закладу
        --отримувач
        Add_Attr (l_Attrs, 3022, p_Val_Str => l_Sci_Os.Sci_Ln);
        Add_Attr (l_Attrs, 3023, p_Val_Str => l_Sci_Os.Sci_Fn);
        Add_Attr (l_Attrs, 3024, p_Val_Str => l_Sci_Os.Sci_Mn);
        Add_Attr (l_Attrs, 3025, p_Val_Dt => l_birth_dt);
        Add_Attr (
            l_Attrs,
            3026,
            p_Val_Str   =>
                COALESCE (
                    Api$appeal.Get_Ap_Doc_Str (l_at.at_ap,
                                               l_at.atp_app_tp,
                                               1790),
                    Api$appeal.Get_Ap_Doc_Str (l_at.at_ap,
                                               l_at.atp_app_tp,
                                               349),
                    l_ftr.a_3026));                       --група інвалідності
        Add_Attr (l_Attrs, 3027, p_Val_Str => AtSrvMetod (p_at_id));
        Add_Attr (l_Attrs,
                  3028,
                  p_Val_Sum   => l_At_Calc.Aic_Member_Month_Income);
        Add_Attr (l_Attrs, 3029, p_Val_Sum => l_At_Calc.Aic_Limit);
        Add_Attr (l_Attrs, 3030); --"Виплата" - зараз це константа "державної соціальної допомоги" у звіті
        Add_Attr (l_Attrs, 3031, p_Val_Str => l_Org_Name); --виплата проводиться

        --Місце фактичного проживання
        Add_Attr (l_Attrs, 3032, p_Val_Str => rAdr_fakt.indx);        --Індекс
        Add_Attr (l_Attrs, 3033, p_Val_Str => rAdr_fakt.katot);      --КАТОТТГ
        Add_Attr (l_Attrs, 3034, p_Val_Str => rAdr_fakt.strit);      -- Вулиця
        Add_Attr (l_Attrs, 3035, p_Val_Str => rAdr_fakt.bild);       --Будинок
        Add_Attr (l_Attrs, 3036, p_Val_Str => rAdr_fakt.korp);        --Корпус
        Add_Attr (l_Attrs, 3037, p_Val_Str => rAdr_fakt.apart);     --Квартира

        --Реєстрація
        Add_Attr (l_Attrs, 3038, p_Val_Str => rAdr_reg.indx);         --Індекс
        Add_Attr (l_Attrs, 3039, p_Val_Str => rAdr_reg.katot);       --КАТОТТГ
        Add_Attr (l_Attrs, 3040, p_Val_Str => rAdr_reg.strit);       -- Вулиця
        Add_Attr (l_Attrs, 3041, p_Val_Str => rAdr_reg.bild);        --Будинок
        Add_Attr (l_Attrs, 3042, p_Val_Str => rAdr_reg.korp);         --Корпус
        Add_Attr (l_Attrs, 3043, p_Val_Str => rAdr_reg.apart);      --Квартира

        Add_Attr (l_Attrs, 3044, p_Val_Dt => l_ftr.a_3044);
        Add_Attr (l_Attrs, 3045, p_Val_Dt => l_ftr.a_3045);
        Add_Attr (l_Attrs, 3046, p_Val_Str => l_ftr.a_3046);
        Add_Attr (l_Attrs, 3047, p_Val_Dt => l_ftr.a_3047);
        Add_Attr (l_Attrs, 3048, p_Val_Dt => l_ftr.a_3048);
        Add_Attr (l_Attrs, 3049, p_Val_Dt => SYSDATE);
        Add_Attr (l_Attrs, 3050); --Посада керівника підрозділу з питань діяльності інтернатних установ
        Add_Attr (l_Attrs, 3051, p_Val_Str => l_Boss_Wu_Pib2.LN);
        Add_Attr (l_Attrs, 3052, p_Val_Str => l_Boss_Wu_Pib2.Fn);
        Add_Attr (l_Attrs, 3053, p_Val_Str => l_Boss_Wu_Pib2.Mn);
        Add_Attr (l_Attrs, 3055);                     --Посада керівника СПСЗН
        Add_Attr (l_Attrs, 3056, p_Val_Str => l_Boss_Wu_Pib.LN);
        Add_Attr (l_Attrs, 3057, p_Val_Str => l_Boss_Wu_Pib.Fn);
        Add_Attr (l_Attrs, 3058, p_Val_Str => l_Boss_Wu_Pib.Mn);

        RETURN l_Attrs;
    END;

    --91436 Повідомлення СПСЗН про прийняття особи на обслуговування до інтернатного закладу
    FUNCTION Fill_Attrs_855 (p_at_id IN NUMBER)
        RETURN t_At_Document_Attrs
    IS
        l_Attrs   t_At_Document_Attrs;
    BEGIN
        Add_Attr (l_Attrs, 4232, p_Val_Str => get_AtDocAtrStr (p_at_id, 3020)); --Путівка №
        Add_Attr (l_Attrs, 4233, p_Val_Dt => get_AtDocAtrDt (p_at_id, 3049));
        Add_Attr (l_Attrs, 4234, p_Val_Str => get_AtDocAtrStr (p_at_id, 3010)); --найменування СПСЗН обласного рівня
        Add_Attr (l_Attrs, 4235, p_Val_Str => get_AtDocAtrStr (p_at_id, 3022)); --отримувач
        Add_Attr (l_Attrs, 4236, p_Val_Str => get_AtDocAtrStr (p_at_id, 3023)); --отримувач
        Add_Attr (l_Attrs, 4237, p_Val_Str => get_AtDocAtrStr (p_at_id, 3024)); --отримувач
        Add_Attr (l_Attrs, 4238, p_Val_Str => get_AtDocAtrStr (p_at_id, 3021)); --найменування інтернатної установи/закладу
        Add_Attr (l_Attrs, 4239, p_Val_Dt => NULL);              --дата наказу
        Add_Attr (l_Attrs, 4240, p_Val_Str => NULL);                --№ наказу
        Add_Attr (l_Attrs, 4241, p_Val_Str => NULL); --найменування органу ПФУ/СПСЗН
        Add_Attr (l_Attrs, 4242, p_Val_Str => NULL); --Повідомлення направлено
        Add_Attr (l_Attrs, 4243, p_Val_Str => NULL);      --Прізвище директора
        Add_Attr (l_Attrs, 4244, p_Val_Str => NULL);          --Ім’я директора
        Add_Attr (l_Attrs, 4245, p_Val_Str => NULL);   --По батькові директора

        RETURN l_Attrs;
    END;

    --#91438 «Повідомлення органу ПФУ про прийняття на обслуговування до інтернатного закладу»
    FUNCTION Fill_Attrs_856 (p_at_id IN NUMBER)
        RETURN t_At_Document_Attrs
    IS
        l_Attrs   t_At_Document_Attrs;
    BEGIN
        Add_Attr (l_Attrs, 4246, p_Val_Str => NULL); --Місце знаходження органу ПФУ/СППСЗН - КАТОТТГ
        Add_Attr (l_Attrs, 4247, p_Val_Str => NULL);                  --індекс
        Add_Attr (l_Attrs, 4248, p_Val_Str => NULL);
        Add_Attr (l_Attrs, 4249, p_Val_Str => NULL);
        Add_Attr (l_Attrs, 4250, p_Val_Str => NULL);
        Add_Attr (l_Attrs, 4251, p_Val_Str => get_AtDocAtrStr (p_at_id, 3021)); --найменування інтернатної установи/закладу
        Add_Attr (l_Attrs, 4252, p_Val_Str => NULL); --місцезнаходження інтернатної установи/закладу - КАТОТТГ
        Add_Attr (l_Attrs, 4253, p_Val_Str => NULL);                  --індекс
        Add_Attr (l_Attrs, 4254, p_Val_Str => NULL);
        Add_Attr (l_Attrs, 4255, p_Val_Str => NULL);
        Add_Attr (l_Attrs, 4256, p_Val_Str => NULL);
        Add_Attr (l_Attrs, 4257, p_Val_Dt => NULL);              --дата наказу
        Add_Attr (l_Attrs, 4258, p_Val_Str => NULL);                --№ наказу
        Add_Attr (l_Attrs, 4259, p_Val_Dt => NULL); --дата прийняття до інтернатної установи/закладу
        Add_Attr (l_Attrs, 4260, p_Val_Str => get_AtDocAtrStr (p_at_id, 3022)); --отримувач
        Add_Attr (l_Attrs, 4261, p_Val_Str => get_AtDocAtrStr (p_at_id, 3023)); --отримувач
        Add_Attr (l_Attrs, 4262, p_Val_Str => get_AtDocAtrStr (p_at_id, 3024)); --отримувач
        Add_Attr (l_Attrs, 4263, p_Val_Dt => get_AtDocAtrDt (p_at_id, 3025)); --дата народження
        Add_Attr (l_Attrs, 4264, p_Val_Str => get_AtDocAtrStr (p_at_id, 3033)); --отримувач - КАТОТТГ
        Add_Attr (l_Attrs, 4265, p_Val_Str => get_AtDocAtrStr (p_at_id, 3032)); --отримувач - індекс
        Add_Attr (l_Attrs, 4266, p_Val_Str => get_AtDocAtrStr (p_at_id, 3034)); --отримувач - вулиця
        Add_Attr (l_Attrs, 4267, p_Val_Str => get_AtDocAtrStr (p_at_id, 3035)); --отримувач - будинок
        Add_Attr (l_Attrs, 4268, p_Val_Str => get_AtDocAtrStr (p_at_id, 3036)); --отримувач - корпус
        Add_Attr (l_Attrs, 4269, p_Val_Str => get_AtDocAtrStr (p_at_id, 3037)); --отримувач - квартира
        Add_Attr (l_Attrs, 4270, p_Val_Str => NULL);
        Add_Attr (l_Attrs, 4271, p_Val_Str => NULL);
        Add_Attr (l_Attrs, 4272, p_Val_Str => NULL);
        Add_Attr (l_Attrs, 4273, p_Val_Str => NULL); --прізвище отримувача / законного представника
        Add_Attr (l_Attrs, 4274, p_Val_Str => NULL); --ім’я отримувача / законного представника
        Add_Attr (l_Attrs, 4275, p_Val_Str => NULL); --по батькові отримувача / законного представника
        Add_Attr (l_Attrs, 4276, p_Val_Str => NULL); --заява особи чи її законного представника або заява керівника інтернатної(го) установи/закладу
        --ПІБ директора
        Add_Attr (l_Attrs, 4277, p_Val_Str => NULL);
        Add_Attr (l_Attrs, 4278, p_Val_Str => NULL);
        Add_Attr (l_Attrs, 4279, p_Val_Str => NULL);

        RETURN l_Attrs;
    END;

    --#87279 автозаповнення документу 860
    FUNCTION Fill_Attrs_860 (p_at_id IN NUMBER)
        RETURN t_At_Document_Attrs
    IS
        l_atr         t_At_Document_Attrs;

        CURSOR cur IS
            SELECT a.at_ap,
                   ap.ap_tp,
                   TRUNC (SYSDATE)
                       a3080,
                   a.at_num
                       a3081,
                   a.at_org
                       a3086,
                   a.At_Rnspm,
                   NVL (
                       (SELECT MAX (da.apda_val_string)
                          FROM ap_document d, ap_document_attr da
                         WHERE     d.apd_ap = a.at_ap
                               AND d.apd_ndt = 861
                               AND d.history_status = 'A'
                               AND d.apd_id = da.apda_apd
                               AND da.history_status = 'A'
                               AND da.apda_nda = 3068),
                       (SELECT MAX (da.apda_val_string)
                          FROM ap_document d, ap_document_attr da
                         WHERE     d.apd_ap = a.at_ap
                               AND d.apd_ndt = 800
                               AND d.history_status = 'A'
                               AND d.apd_id = da.apda_apd
                               AND da.history_status = 'A'
                               AND da.apda_nda = 3064))
                       a3090,                           -- надавач соц.послуги
                   (SELECT LISTAGG (s.nst_id, ',')
                               WITHIN GROUP (ORDER BY s.nst_order)
                      FROM at_service t, uss_ndi.v_ndi_service_type s
                     WHERE     t.ats_at = a.at_id
                           AND s.nst_id = t.ats_nst
                           AND t.history_status = 'A')
                       a3091,
                   (SELECT MAX (z.at_rnp)
                      FROM act z
                     WHERE z.at_ap = a.at_ap AND z.at_tp = 'IPNP')
                       AS rnp_id,
                   (SELECT MAX (t.rnp_id)
                      FROM ap_document                   d,
                           ap_document_attr              da,
                           uss_ndi.v_ndi_reason_not_pay  t
                     WHERE     d.apd_ap = a.at_ap
                           AND d.history_status = 'A'
                           AND d.apd_id = da.apda_apd
                           AND da.history_status = 'A'
                           AND da.apda_nda IN (3076, 3066)
                           AND t.rnp_id = da.apda_val_string)
                       a3092    --причина припинення надання соціальних послуг
              FROM act a, --uss_ndi.v_ndi_reason_not_pay nrnp,
                          appeal ap
             WHERE a.at_id = p_at_id --and nrnp.rnp_id(+)= a.at_rnp
                                     AND ap.ap_id = a.at_ap;

        r             cur%ROWTYPE;

        l_Sci_Os      Uss_Person.v_Sc_Identity%ROWTYPE;
        l_boss_wu     NUMBER;
        l_boss_wu2    NUMBER;
        l_boss_pib    Tools.r_Pib;
        l_boss_pib2   Tools.r_Pib;
    BEGIN
        --Raise_application_error(-20000, 'акт тест документа 860');
        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        --ПІБ отримувача
        -- якщо звернення типу R.GS - Z і OS повинні бути обов'язково. Тут беремо тільки OS
        -- якщо звернення типу R.OS - Z є обов'язково, а OS може і не бути => треба дивитись на наявність: є OS - беремо, немає OS - беремо Z
        --l_Sci_Os := Get_App_Sci(r.at_ap, 'OS');
        l_Sci_Os := Get_App_Sci (r.at_ap);

        l_boss_wu :=
            get_at_signers (p_at_id => p_at_id, p_order => 1, p_ndt => 860);
        l_boss_wu2 :=
            get_at_signers (p_at_id => p_at_id, p_order => 2, p_ndt => 860);

        --Отримуємо інформацію про спеціаліста з опрацювання заяв
        Tools.Split_Pib (Tools.Getuserpib (l_boss_wu), l_boss_pib);
        --Отримуємо інформацію про керівника уповноваженого органу
        Tools.Split_Pib (Tools.Getuserpib (l_boss_wu2), l_boss_pib2);


        Add_Attr (p_Attrs => l_atr, p_Nda_Id => 3080, p_Val_Dt => r.a3080); --рішення
        Add_Attr (p_Attrs => l_atr, p_Nda_Id => 3081, p_Val_Str => r.a3081);
        Add_Attr (p_Attrs     => l_atr,
                  p_Nda_Id    => 3086,
                  p_Val_Str   => tools.GetOrgName (r.a3086),
                  p_Val_Id    => r.a3086);                --найменування СПСЗН
        --отримувач
        Add_Attr (p_Attrs     => l_atr,
                  p_Nda_Id    => 3087,
                  p_Val_Str   => l_Sci_Os.sci_ln);                   --фамілія
        Add_Attr (p_Attrs     => l_atr,
                  p_Nda_Id    => 3088,
                  p_Val_Str   => l_Sci_Os.sci_fn);                      --ім"я
        Add_Attr (p_Attrs     => l_atr,
                  p_Nda_Id    => 3089,
                  p_Val_Str   => l_Sci_Os.sci_mn);               --по батькові

        --надавач соціальної послуги
        Add_Attr (p_Attrs     => l_atr,
                  p_Nda_Id    => 3090,
                  p_Val_Str   => Get_Nsp_Name (p_Rnspm_Id => r.At_Rnspm)); --r.a3090);
        Add_Attr (p_Attrs => l_atr, p_Nda_Id => 3091, p_Val_Str => r.a3091); --перелік соціальних послуг

        --причина припинення надання соціальних послуг
        Add_Attr (p_Attrs     => l_atr,
                  p_Nda_Id    => 3092,
                  p_Val_Str   => NVL (r.rnp_id, r.a3092));

        Add_Attr (p_Attrs => l_atr, p_Nda_Id => 3093); --посада спеціаліста з опрацювання заяв ???
        Add_Attr (p_Attrs     => l_atr,
                  p_Nda_Id    => 3094,
                  p_Val_Str   => l_boss_pib.fn);                        --ім"я
        Add_Attr (p_Attrs     => l_atr,
                  p_Nda_Id    => 3095,
                  p_Val_Str   => l_boss_pib.LN);                     --фамілія
        Add_Attr (p_Attrs => l_atr, p_Nda_Id => 3096); --посада керівника уповноваженого органу ???
        Add_Attr (p_Attrs     => l_atr,
                  p_Nda_Id    => 3098,
                  p_Val_Str   => l_boss_pib2.LN);                    --фамілія
        Add_Attr (p_Attrs     => l_atr,
                  p_Nda_Id    => 3097,
                  p_Val_Str   => l_boss_pib2.fn);                       --ім"я

        RETURN l_atr;
    END;

    --#87279 автозаповнення документу 862
    FUNCTION Fill_Attrs_862 (p_at_id IN NUMBER)
        RETURN t_At_Document_Attrs
    IS
        CURSOR cur IS
            SELECT a.at_ap,
                   ap.ap_tp,
                   a.at_org                                                 a3108,
                   (SELECT MAX (za.atda_val_dt)
                      FROM at_document  z
                           JOIN at_document_attr za
                               ON (za.atda_atd = z.atd_id)
                     WHERE     z.atd_at = a.at_id
                           AND z.atd_ndt = 860
                           AND z.history_status = 'A'
                           AND za.atda_nda = 3080
                           AND za.history_status = 'A')                     AS a3109,
                   a.at_num                                                 a3110,
                   a.At_Rnspm,
                   /*nvl((select max(da.apda_val_string) from ap_document d, ap_document_attr da
                         where d.apd_ap = a.at_ap and d.apd_ndt = 861 and d.history_status = 'A'
                           and d.apd_id = da.apda_apd and da.history_status = 'A' and da.apda_nda = 3068),
                       (select max(da.apda_val_string) from ap_document d, ap_document_attr da
                         where d.apd_ap = a.at_ap and d.apd_ndt = 800 and d.history_status = 'A'
                           and d.apd_id = da.apda_apd and da.history_status = 'A' and da.apda_nda = 3064)
                      ) a3114,*/
                   -- надавач соц.послуги
                   nrnp.rnp_id,
                   (SELECT MAX (t.rnp_id)
                      FROM ap_document                   d,
                           ap_document_attr              da,
                           uss_ndi.v_ndi_reason_not_pay  t
                     WHERE     d.apd_ap = a.at_ap
                           AND d.history_status = 'A'
                           AND d.apd_id = da.apda_apd
                           AND da.history_status = 'A'
                           AND da.apda_nda IN (3076, 3066)
                           AND t.rnp_id =
                               NVL (da.apda_val_string, da.apda_val_id))    a3115 --причина припинення надання соціальних послуг
              FROM act a, uss_ndi.v_ndi_reason_not_pay nrnp, appeal ap
             WHERE     a.at_id = p_at_id
                   AND nrnp.rnp_id(+) = a.at_rnp
                   AND ap.ap_id = a.at_ap;

        r            cur%ROWTYPE;

        --адреса звернення з персони з переважним типом p_App_Tp
        CURSOR c_adr (p_ap_id NUMBER, p_App_Tp VARCHAR2)
        IS
              SELECT MAX (DECODE (a.apda_nda, 1625, a.apda_val_string))
                         ind,                                         --Індекс
                     MAX (DECODE (a.apda_nda, 1618, a.apda_val_string))
                         katot,                                      --КАТОТТГ
                     MAX (
                         NVL (DECODE (a.apda_nda, 1632, a.apda_val_string),
                              DECODE (a.apda_nda, 1640, a.apda_val_string)))
                         strit,     --Вулиця (вибір із довідника)/Вулиця текст
                     MAX (DECODE (a.apda_nda, 1648, a.apda_val_string))
                         bild,                                       --Будинок
                     MAX (DECODE (a.apda_nda, 1654, a.apda_val_string))
                         korp,                                        --Корпус
                     MAX (DECODE (a.apda_nda, 1659, a.apda_val_string))
                         rv                                         --Квартира
                FROM ap_person p, ap_document d, ap_document_attr a
               WHERE     p.app_ap = p_ap_id
                     AND p.history_status = 'A'
                     AND d.apd_ndt = 605
                     AND d.history_status = 'A'
                     AND d.apd_app = p.app_id
                     AND a.apda_apd = d.apd_id
                     AND a.history_status = 'A'
                     AND apda_nda IN (1618,
                                      1625,
                                      1632,
                                      1640,
                                      1648,
                                      1654,
                                      1659)
            ORDER BY DECODE (p.App_Tp, p_App_Tp, 0, 1);

        TYPE tAdr IS RECORD
        (
            a3102    VARCHAR2 (200),                                  --Індекс
            a3103    VARCHAR2 (200),                                 --КАТОТТГ
            a3104    VARCHAR2 (200),                                  --вулиця
            a3105    VARCHAR2 (200),                                 --будинок
            a3106    VARCHAR2 (200),                                  --Корпус
            a3107    VARCHAR2 (200)                                 --квартира
        );

        rAdr         tAdr;

        l_atr        t_At_Document_Attrs;
        l_Sci_Z      Uss_Person.v_Sc_Identity%ROWTYPE;
        l_Sci_Os     Uss_Person.v_Sc_Identity%ROWTYPE;
        l_Boss_Wu    NUMBER;
        l_boss_pib   Tools.r_Pib;
    BEGIN
        OPEN cur;

        FETCH cur INTO r;

        CLOSE cur;

        l_Sci_Z := Get_App_Sci (r.at_ap, 'Z');                  --ПІБ заявника
        --l_Sci_Os := Get_App_Sci(r.at_ap, 'OS'); --ПІБ отримувача
        l_Sci_Os := Get_App_Sci (r.at_ap);                    --ПІБ отримувача

        --усі дані беремо с отримувача
        IF r.ap_tp = 'R.GS'
        THEN
            l_Sci_Z := Get_App_Sci (r.at_ap, 'OS');

            --адреса ???
            OPEN c_adr (p_ap_id => r.at_ap, p_App_Tp => 'OS');

            FETCH c_adr INTO rAdr;

            CLOSE c_adr;
        ELSIF r.ap_tp = 'R.OS'
        THEN                      --якщо є отримувач, то з нього, інакше - с Z
            --адреса
            --rAdr.a3102:= Api$appeal.Get_Ap_z_Doc_Id(l_Pd.Pd_Ap, 605, 1891);
            OPEN c_adr (p_ap_id => r.at_ap, p_App_Tp => 'OS');

            FETCH c_adr INTO rAdr;

            CLOSE c_adr;
        END IF;

        --Отримуємо інформацію про керівника уповноваженого органу
        /*select --max(decode(rn, 1, ati_wu)) first_value
               max(decode(rn, cnt, ati_wu)) last_value
          INTO l_boss_wu
          from
            (
             select s.ati_wu,
                    row_number() over(order by nvl(s.ati_order, s.ati_id)) rn,
                    count(*) over() cnt
               from at_signers s, at_document d
              where s.ati_at = p_at_id and s.history_status = 'A'
                and d.atd_id = s.ati_atd and d.history_status = 'A'
                and d.atd_ndt = 862
            );*/
        l_boss_wu :=
            get_at_signers (p_at_id => p_at_id, p_order => 2, p_ndt => 862);
        Tools.Split_Pib (Tools.Getuserpib (l_boss_wu), l_boss_pib);

        --заявник
        Add_Attr (p_Attrs     => l_atr,
                  p_Nda_Id    => 3099,
                  p_Val_Str   => l_Sci_Z.sci_ln);                    --фамілія
        Add_Attr (p_Attrs     => l_atr,
                  p_Nda_Id    => 3100,
                  p_Val_Str   => l_Sci_Z.sci_fn);                       --ім"я
        Add_Attr (p_Attrs     => l_atr,
                  p_Nda_Id    => 3101,
                  p_Val_Str   => l_Sci_Z.sci_mn);                --по батькові

        --адреса
        Add_Attr (p_Attrs => l_atr, p_Nda_Id => 3102, p_Val_Str => rAdr.a3102); --Індекс
        Add_Attr (p_Attrs => l_atr, p_Nda_Id => 3103, p_Val_Str => rAdr.a3103); --КАТОТТГ
        Add_Attr (p_Attrs => l_atr, p_Nda_Id => 3104, p_Val_Str => rAdr.a3104); --вулиця
        Add_Attr (p_Attrs => l_atr, p_Nda_Id => 3105, p_Val_Str => rAdr.a3105); --будинок
        Add_Attr (p_Attrs => l_atr, p_Nda_Id => 3106, p_Val_Str => rAdr.a3106); --Корпус
        Add_Attr (p_Attrs => l_atr, p_Nda_Id => 3107, p_Val_Str => rAdr.a3107); --квартира


        Add_Attr (p_Attrs     => l_atr,
                  p_Nda_Id    => 3108,
                  p_Val_Str   => tools.GetOrgName (r.a3108),
                  p_Val_Id    => r.a3108);                --найменування СПСЗН
        Add_Attr (p_Attrs => l_atr, p_Nda_Id => 3109, p_Val_Dt => r.a3109); --рішення
        Add_Attr (p_Attrs => l_atr, p_Nda_Id => 3110, p_Val_Str => r.a3110);

        --отримувач
        Add_Attr (p_Attrs     => l_atr,
                  p_Nda_Id    => 3111,
                  p_Val_Str   => NVL (l_Sci_Os.sci_ln, l_Sci_Z.sci_ln)); --фамілія
        Add_Attr (p_Attrs     => l_atr,
                  p_Nda_Id    => 3112,
                  p_Val_Str   => NVL (l_Sci_Os.sci_fn, l_Sci_Z.sci_fn)); --ім"я
        Add_Attr (p_Attrs     => l_atr,
                  p_Nda_Id    => 3113,
                  p_Val_Str   => NVL (l_Sci_Os.sci_mn, l_Sci_Z.sci_mn)); --по батькові

        Add_Attr (p_Attrs     => l_atr,
                  p_Nda_Id    => 3114,
                  p_Val_Str   => Get_Nsp_Name (p_Rnspm_Id => r.At_Rnspm)); --r.a3114); --надавач соціальної послуги
        Add_Attr (p_Attrs     => l_atr,
                  p_Nda_Id    => 3115,
                  p_Val_Str   => NVL (r.rnp_id, r.a3115)); --підстави припинення надання соціальних послуг

        Add_Attr (p_Attrs => l_atr, p_Nda_Id => 3116); --посада керівника уповноваженого органу
        Add_Attr (p_Attrs     => l_atr,
                  p_Nda_Id    => 3117,
                  p_Val_Str   => l_boss_pib.LN);                     --фамілія
        Add_Attr (p_Attrs     => l_atr,
                  p_Nda_Id    => 3118,
                  p_Val_Str   => l_boss_pib.fn);                        --ім"я

        RETURN l_atr;
    END;

    -- #87272: збереження документу
    PROCEDURE save_Document (p_atd_id          IN OUT NUMBER,
                             p_ATD_AT          IN     AT_DOCUMENT.ATD_AT%TYPE,
                             p_ATD_NDT         IN     AT_DOCUMENT.ATD_NDT%TYPE,
                             p_ATD_ATS         IN     AT_DOCUMENT.ATD_ATS%TYPE,
                             p_ATD_DOC         IN     AT_DOCUMENT.ATD_DOC%TYPE,
                             p_ATD_DH          IN     AT_DOCUMENT.ATD_DH%TYPE,
                             P_ATTR_XML        IN     CLOB,
                             p_FILE_XML        IN     CLOB,
                             p_create_signer   IN     VARCHAR2)
    IS
        l_attr     t_At_Document_Attrs;
        p_new_id   NUMBER := P_Atd_ID;
        l_new_id   NUMBER;
    BEGIN
        IF (p_atd_id IS NULL OR p_atd_id < 0)
        THEN
            SELECT COUNT (*)
              INTO l_new_Id
              FROM at_document t
             WHERE     t.atd_at = p_ATD_AT
                   AND t.atd_ndt = P_ATD_NDT
                   AND t.history_status = 'A';

            IF (l_new_id > 0)
            THEN
                raise_application_error (
                    -20000,
                    'Документ такого типу вже створений. Будь-ласка, редагуйте його!');
            END IF;

            api$documents.save_at_document (NULL,
                                            p_ATD_AT,
                                            p_ATD_NDT,
                                            p_ATD_ATS,
                                            p_ATD_DOC,
                                            p_ATD_DH,
                                            p_new_id);
        ELSE
            SELECT COUNT (*)
              INTO l_new_Id
              FROM at_document t
             WHERE     t.atd_at = p_ATD_AT
                   AND t.atd_ndt = p_ATD_NDT
                   AND t.atd_id != p_ATD_ID
                   AND t.history_status = 'A';

            IF (l_new_id > 0)
            THEN
                raise_application_error (
                    -20000,
                    'Документ такого типу вже створений. Будь-ласка, редагуйте його!');
            END IF;

            api$documents.save_at_document (p_atd_id,
                                            p_ATD_AT,
                                            p_ATD_NDT,
                                            p_ATD_ATS,
                                            p_ATD_DOC,
                                            p_ATD_DH,
                                            p_new_id);
        END IF;

        p_atd_id := p_new_id;

        IF (p_create_signer = 'T')
        THEN
            add_signer (p_atd_id => p_atd_id, p_at_id => p_ATD_AT);
        END IF;

        CASE p_ATD_NDT
            WHEN 850
            THEN
                l_attr := Fill_Attrs_850 (p_ATD_AT);                  --#91558
            WHEN 851
            THEN
                l_attr := Fill_Attrs_851 (p_ATD_AT);                  --#91558
            WHEN 852
            THEN
                l_attr := Fill_Attrs_852 (p_ATD_AT);                  --#91558
            WHEN 853
            THEN
                l_attr := Fill_Attrs_853 (p_ATD_AT);                  --#91558
            WHEN 854
            THEN
                l_attr := Fill_Attrs_854 (p_ATD_AT);                  --#91558
            WHEN 855
            THEN
                l_attr := Fill_Attrs_855 (p_ATD_AT);                  --#91436
            WHEN 856
            THEN
                l_attr := Fill_Attrs_856 (p_ATD_AT);                  --#91438
            WHEN 860
            THEN
                l_attr := Fill_Attrs_860 (p_ATD_AT);                  --#87279
            WHEN 862
            THEN
                l_attr := Fill_Attrs_862 (p_ATD_AT);                  --#87279
            ELSE
                EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                                 't_At_Document_Attrs',
                                                 TRUE,
                                                 TRUE)
                    BULK COLLECT INTO l_attr
                    USING P_ATTR_XML;
        END CASE;

        FOR Rec
            IN (SELECT a.Deleted,
                       NVL (a.Atda_Id, Da.Atda_Id)     AS Atda_Id,
                       a.Atda_Nda,
                       a.Atda_Val_Int                  AS Val_Int,
                       a.Atda_Val_Dt                   AS Val_Dt,
                       a.Atda_Val_String               AS Val_String,
                       a.Atda_Val_Id                   AS Val_Id,
                       a.Atda_Val_Sum                  AS Val_Sum
                  FROM TABLE (l_attr)  a
                       LEFT JOIN At_Document_Attr Da
                           ON     Da.Atda_Atd = p_atd_id
                              AND a.Atda_Nda = Da.Atda_Nda
                              AND Da.History_Status = 'A')
        LOOP
            IF Rec.Deleted = 1 AND Rec.Atda_Id > 0
            THEN
                --Видаляємо атрибут
                api$documents.Delete_At_Document_Attr (p_Id => Rec.atda_id);
            ELSE
                api$documents.Save_At_Document_Attr (
                    p_Atda_Id           => Rec.Atda_Id,
                    p_Atda_Atd          => p_ATd_Id,
                    p_Atda_At           => p_ATD_AT,
                    p_Atda_Nda          => Rec.Atda_Nda,
                    p_Atda_Val_Int      => Rec.Val_Int,
                    p_Atda_Val_Dt       => Rec.Val_Dt,
                    p_Atda_Val_String   => Rec.Val_String,
                    p_Atda_Val_Id       => Rec.Val_Id,
                    p_Atda_Val_Sum      => Rec.Val_Sum,
                    p_New_Id            => l_New_Id);
            END IF;
        END LOOP;

        IF p_FILE_XML IS NOT NULL
        THEN
            --Зберігаємо вкладення документа
            Uss_Doc.Api$documents.Save_Attach_List (
                p_Doc_Id        => p_ATD_DOC,
                p_Dh_Id         => p_ATD_DH,
                p_Attachments   => xmltype (p_FILE_XML));
        END IF;
    END;

    PROCEDURE Get_At_Docs_Files (P_At_ID   IN     NUMBER,
                                 p_mode    IN     NUMBER,
                                 p_Res        OUT SYS_REFCURSOR)
    IS
    BEGIN
        Uss_Doc.Api$documents.Clear_Tmp_Work_Ids;

        INSERT INTO Uss_Doc.Tmp_Work_Ids (x_Id)
            SELECT DISTINCT d.atd_dh
              FROM v_at_document d
             WHERE     d.atd_at = P_AT_ID
                   AND (p_mode = 1 AND d.atd_ndt IN (860, 862))
                   AND History_Status = 'A';

        --отримуємо дані файлів з електронного архіву
        Uss_Doc.Api$documents.Get_Signed_Attachments (p_Res => p_Res);
    --Uss_Doc.Api$documents.Get_Attachments(p_Doc_Id => NULL, p_Dh_Id => NULL, p_Res => p_Res, p_Params_Mode => 3);
    END;

    PROCEDURE Get_Ap_Docs_Files (P_Ap_ID   IN     NUMBER,
                                 p_mode    IN     NUMBER,
                                 p_Res        OUT SYS_REFCURSOR)
    IS
    BEGIN
        Uss_Doc.Api$documents.Clear_Tmp_Work_Ids;

        INSERT INTO Uss_Doc.Tmp_Work_Ids (x_Id)
            SELECT DISTINCT d.atd_dh
              FROM v_at_document d JOIN v_act a ON d.atd_at = a.at_id
             WHERE     a.at_ap = p_Ap_Id
                   AND (p_mode = 1 AND d.atd_ndt IN (860, 862))
                   AND History_Status = 'A';

        --отримуємо дані файлів з електронного архіву
        Uss_Doc.Api$documents.Get_Signed_Attachments (p_Res => p_Res);
    --Uss_Doc.Api$documents.Get_Attachments(p_Doc_Id => NULL, p_Dh_Id => NULL, p_Res => p_Res, p_Params_Mode => 3);
    END;

    -- #87272: список документів по акту
    PROCEDURE get_ss_docs_by_at (p_at_id    IN     NUMBER,
                                 p_flag        OUT NUMBER,
                                 doc_cur       OUT SYS_REFCURSOR,
                                 attr_cur      OUT SYS_REFCURSOR,
                                 file_cur      OUT SYS_REFCURSOR,
                                 sign_cur      OUT SYS_REFCURSOR)
    IS
        l_wu   NUMBER := tools.GetCurrWu;
    BEGIN
        /* SELECT CASE WHEN f1 < 5 AND f2 > 0 THEN 1 ELSE 0 END AS can_add_doc
           INTO p_flag
           FROM (SELECT (SELECT COUNT(*)
                           FROM pd_document t
                          WHERE t.pdo_pd = p_pd_id
                            AND t.pdo_ndt IN (860, 862)
                            AND t.history_status = 'A'
                        ) AS f1,
                        (SELECT COUNT(*)
                           FROM pc_decision t
                           JOIN ap_document d ON (d.apd_ap = t.pd_ap)
                            JOIN ap_document_attr a ON (a.apda_apd = d.apd_id)
                          WHERE t.pd_id = p_pd_id
                            AND d.apd_ndt = 801
                            AND d.history_status = 'A'
                            AND a.apda_nda = 1870
                            AND a.history_status = 'A'
                            AND (a.apda_val_string IS NULL OR a.apda_val_string = 'F')
                        ) AS f2
                   FROM dual
               ) t;*/

        p_flag := 1;

        OPEN doc_cur FOR
            SELECT t.*,
                   tp.ndt_name                                  AS atd_ndt_name,
                   (SELECT CASE
                               WHEN COUNT (*) > 0 THEN 'T'
                               ELSE 'F'
                           END
                      FROM at_signers z
                     WHERE     z.ati_atd = t.atd_id
                           AND z.history_status = 'A'
                           AND z.ati_wu = l_wu
                           AND (   z.ati_is_signed IS NULL
                                OR z.ati_is_signed = 'F')
                           AND NOT EXISTS
                                   (SELECT *
                                      FROM at_signers q
                                     WHERE     q.ati_atd =
                                               z.ati_atd
                                           AND q.history_status =
                                               'A'
                                           AND (   q.ati_is_signed
                                                       IS NULL
                                                OR q.ati_is_signed =
                                                   'F')
                                           AND q.ati_order <
                                               z.ati_order))    AS can_sign,
                   (SELECT CASE WHEN COUNT (*) = 1 THEN 'T' ELSE 'F' END
                      FROM at_signers z
                     WHERE     z.ati_atd = t.atd_id
                           AND z.history_status = 'A'
                           AND (   z.ati_is_signed IS NULL
                                OR z.ati_is_signed = 'F'))      AS last_sign,
                   CASE
                       WHEN atd_ndt IN (860) AND at_st = 'RS.S' THEN 'T'
                       WHEN atd_ndt IN (862) AND at_st = 'RM.O' THEN 'T'
                       ELSE 'F'
                   END                                          AS can_delete
              FROM at_document  t
                   JOIN act a ON (a.at_id = t.atd_at)
                   JOIN uss_ndi.v_ndi_document_type tp
                       ON (tp.ndt_id = t.atd_ndt)
             WHERE     t.atd_at = p_at_id
                   AND t.atd_ndt IN (860, 862)
                   AND t.history_status = 'A';


        OPEN ATTR_CUR FOR
            SELECT attr.*, d.atd_doc AS doc_id, d.atd_dh AS dh_id
              FROM v_at_document  d
                   JOIN v_at_document_attr attr ON (attr.atda_atd = d.atd_id)
             WHERE     d.atd_at = p_at_id
                   AND d.atd_ndt IN (860, 862)
                   AND attr.history_status = 'A';

        Get_At_Docs_Files (p_at_id, 1, file_cur);

        OPEN sign_cur FOR
            SELECT t.*,
                   (SELECT MAX (z.wu_login)
                      FROM v$w_users_4gic z
                     WHERE z.wu_id = t.ati_wu)    AS wu_Pib
              FROM at_signers t
             WHERE t.ati_at = p_at_id AND t.history_status = 'A';
    END;

    PROCEDURE get_ss_docs (p_at_id    IN     NUMBER,
                           p_flag        OUT NUMBER,
                           doc_cur       OUT SYS_REFCURSOR,
                           attr_cur      OUT SYS_REFCURSOR,
                           file_cur      OUT SYS_REFCURSOR,
                           sign_cur      OUT SYS_REFCURSOR)
    IS
        l_wu      NUMBER := tools.GetCurrWu;
        l_Ap_Id   APPEAL.AP_ID%TYPE;
    BEGIN
        SELECT AT_AP
          INTO l_Ap_Id
          FROM Act
         WHERE at_id = p_at_id;

        p_flag := 1;

        OPEN doc_cur FOR
            SELECT t.*,
                   tp.ndt_name                                  AS atd_ndt_name,
                   (SELECT CASE
                               WHEN COUNT (*) > 0 THEN 'T'
                               ELSE 'F'
                           END
                      FROM at_signers z
                     WHERE     z.ati_atd = t.atd_id
                           AND z.history_status = 'A'
                           AND z.ati_wu = l_wu
                           AND (   z.ati_is_signed IS NULL
                                OR z.ati_is_signed = 'F')
                           AND NOT EXISTS
                                   (SELECT *
                                      FROM at_signers q
                                     WHERE     q.ati_atd =
                                               z.ati_atd
                                           AND q.history_status =
                                               'A'
                                           AND (   q.ati_is_signed
                                                       IS NULL
                                                OR q.ati_is_signed =
                                                   'F')
                                           AND q.ati_order <
                                               z.ati_order))    AS can_sign,
                   (SELECT CASE WHEN COUNT (*) = 1 THEN 'T' ELSE 'F' END
                      FROM at_signers z
                     WHERE     z.ati_atd = t.atd_id
                           AND z.history_status = 'A'
                           AND (   z.ati_is_signed IS NULL
                                OR z.ati_is_signed = 'F'))      AS last_sign,
                   CASE
                       WHEN atd_ndt IN (860) AND at_st = 'RS.S' THEN 'T'
                       WHEN atd_ndt IN (862) AND at_st = 'RM.O' THEN 'T'
                       ELSE 'F'
                   END                                          AS can_delete
              FROM at_document  t
                   JOIN act a ON (a.at_id = t.atd_at)
                   JOIN uss_ndi.v_ndi_document_type tp
                       ON (tp.ndt_id = t.atd_ndt)
             WHERE     a.at_ap = l_Ap_Id
                   AND t.atd_ndt IN (860, 862)
                   AND t.history_status = 'A';


        OPEN ATTR_CUR FOR
            SELECT attr.*, d.atd_doc AS doc_id, d.atd_dh AS dh_id
              FROM v_at_document  d
                   JOIN v_at_document_attr attr ON (attr.atda_atd = d.atd_id)
                   JOIN v_act a ON (a.at_id = d.atd_at)
             WHERE     a.at_ap = l_Ap_Id
                   AND d.atd_ndt IN (860, 862)
                   AND attr.history_status = 'A';

        Get_Ap_Docs_Files (l_Ap_Id, 1, file_cur);

        OPEN sign_cur FOR
            SELECT t.*,
                   (SELECT MAX (z.wu_login)
                      FROM v$w_users_4gic z
                     WHERE z.wu_id = t.ati_wu)    AS wu_Pib
              FROM at_signers t JOIN act a ON (a.at_id = t.ati_at)
             WHERE a.at_ap = l_Ap_Id AND t.history_status = 'A';
    END;

    -- #87272: видалення документу
    PROCEDURE delete_document (p_atd_Id IN NUMBER)
    IS
    BEGIN
        api$documents.delete_at_document (p_atd_Id);

        --обробка підписантів документа
        FOR c
            IN (SELECT COUNT (
                           CASE s.ati_is_signed WHEN 'T' THEN s.ati_id END)
                           AS signed,
                       COUNT (
                           CASE COALESCE (s.ati_is_signed, 'F')
                               WHEN 'F' THEN s.ati_id
                           END)
                           AS not_signed
                  FROM v_at_signers s
                 WHERE     s.ati_atd = p_atd_Id
                       AND s.history_status = 'A'
                       AND EXISTS
                               (SELECT 1
                                  FROM v_at_document d
                                 WHERE     d.atd_id = p_atd_Id
                                       AND d.atd_ndt IN (860, 862)
                                       AND d.history_status = 'A'))
        LOOP
            IF c.signed > 1 AND c.not_signed = 0
            THEN
                raise_application_error (
                    -20000,
                    'Заборонено видаляти підписаний документ!');
            ELSE
                UPDATE at_signers
                   SET history_status = 'H'
                 WHERE ati_atd = p_atd_Id AND history_status = 'A';
            --зняття ознаки підписання в рішення
            /*FOR c1 IN (SELECT d.pdo_pd
                         FROM v_at_document d
                        WHERE d.atd_id = p_pdo_id
                          AND d.atd_ndt IN (850, 852)
                          AND d.history_status = 'A')
            LOOP
              UPDATE pc_decision
                 SET pd_is_signed = 'F'
               WHERE pd_id = c1.pdo_pd
                 AND pd_is_signed = 'T';
            END LOOP;*/
            END IF;
        END LOOP;
    END;

    -- #87272: додавання підписанта до документу
    PROCEDURE add_signer (p_atd_id   IN NUMBER,
                          p_at_id    IN NUMBER,
                          p_wu_id    IN NUMBER DEFAULT NULL)
    IS
        l_wu    NUMBER := COALESCE (p_wu_id, tools.GetCurrWu);
        l_cnt   NUMBER;
    BEGIN
        --якщо повторне додавання
        FOR c
            IN (SELECT 1
                  FROM at_signers
                 WHERE     ati_at = p_at_id
                       AND ati_atd = p_atd_id
                       AND ati_wu = l_wu
                       AND history_status = 'A')
        LOOP
            raise_application_error (-20000,
                                     'Повторне додавання підписанта!');
        END LOOP;

        SELECT COUNT (*)
          INTO l_cnt
          FROM at_signers t
         WHERE     t.ati_at = p_at_id
               AND t.ati_atd = p_atd_id
               AND t.history_status = 'A';


        INSERT INTO at_signers t (ati_at,
                                  ati_atd,
                                  ati_wu,
                                  ati_is_signed,
                                  history_status,
                                  ati_order)
             VALUES (p_at_id,
                     p_atd_id,
                     l_wu,
                     'F',
                     'A',
                     NVL (l_cnt, 0) + 1);
    END;

    -- #87272: проставлення ознаки підпису документа користувачем
    PROCEDURE set_doc_signed (p_atd_id IN NUMBER, p_file_code IN VARCHAR2)
    IS
        v_at_id      act.at_id%TYPE;
        v_atd_ndt    at_document.atd_ndt%TYPE;
        v_atd_st     at_document.history_status%TYPE;
        v_rows_cnt   PLS_INTEGER;
    BEGIN
        SELECT atd_at, atd_ndt, history_status
          INTO v_at_id, v_atd_ndt, v_atd_st
          FROM at_document
         WHERE atd_id = p_atd_id;

        IF v_atd_st = 'A'
        THEN
            UPDATE at_signers t
               SET t.ati_is_signed = 'T',
                   t.ati_sign_dt = SYSDATE,
                   t.ati_sign_code = p_file_code
             WHERE     t.ati_atd = p_atd_id
                   AND t.history_status = 'A'
                   AND t.ati_wu = tools.GetCurrWu
                   AND COALESCE (t.ati_is_signed, 'F') = 'F';

            v_rows_cnt := SQL%ROWCOUNT;

            IF v_rows_cnt = 0
            THEN
                raise_application_error (-20000,
                                         'Неуспішне підписання документа!');
            END IF;
        --проставлення ознаки підписання в рішення
        /*IF v_atd_ndt IN (850, 852) AND v_rows_cnt > 0 THEN
          UPDATE pc_decision
             SET pd_is_signed = 'T'
           WHERE pd_id = v_pd_id
             AND coalesce(pd_is_signed, 'F') = 'F';
        END IF;*/
        ELSE
            raise_application_error (
                -20000,
                'Неможливо підписати неактуальний документ!');
        END IF;
    END;


    -- перевірка на консистентність даних
    PROCEDURE check_consistensy (P_AT_ID IN NUMBER, P_AT_ST IN VARCHAR2)
    IS
        l_st   VARCHAR2 (10);
    BEGIN
        SELECT at_st
          INTO l_st
          FROM act t
         WHERE t.at_id = p_at_id;

        IF (l_st != p_at_st OR p_at_st IS NULL)
        THEN
            raise_application_error (
                -20000,
                'Дану операцію неможливо завершити. Дані застарілі. Оновіть сторінку і спробуйте знову.');
        END IF;
    END;

    -- #87272: створення вкладення для документу
    PROCEDURE create_doc_attach (p_atd_id IN NUMBER, p_blob OUT BLOB)
    IS
        v_atd_at           at_document.atd_at%TYPE;
        v_atd_ndt          at_document.atd_ndt%TYPE;
        l_Form_Make_Func   VARCHAR2 (1000);
    BEGIN
        SELECT d.atd_at, d.atd_ndt
          INTO v_atd_at, v_atd_ndt
          FROM at_document d
         WHERE atd_id = p_atd_id;

        SELECT c.Napc_Form_Make_Prc
          INTO l_Form_Make_Func
          FROM Uss_Ndi.v_Ndi_At_Print_Config c
         WHERE c.Napc_At_Tp IS NULL AND c.Napc_Ndt = v_atd_ndt;

        EXECUTE IMMEDIATE   'select '
                         || l_Form_Make_Func
                         || '(:p_At_Id) from dual'
            INTO p_blob
            USING IN v_atd_at;

        --p_blob := dnet$pd_reports.get_act_term_doc_attach(p_at_id => v_atd_at, p_ndt_id => v_atd_ndt);

        IF DBMS_LOB.getlength (p_blob) = 0 OR p_blob IS NULL
        THEN
            raise_application_error (-20000, 'Вкладення не сформовано!');
        END IF;
    END;

    -- #87272:
    PROCEDURE get_sign_attach_info (p_atd_id   IN     NUMBER,
                                    res_cur       OUT SYS_REFCURSOR)
    IS
        v_curr_org   NUMBER (14) := tools.getcurrorg;
    BEGIN
        OPEN res_cur FOR
            SELECT o.org_code || TO_CHAR (a.at_dt, 'YYYY') || d.atd_id
                       AS barcode,
                      o.org_name
                   || ';'
                   || a.at_num
                   || ' від '
                   || TO_CHAR (a.at_dt, 'DD.MM.YYYY')
                       AS qrcode,
                   o.org_name,
                   TO_CHAR (a.at_dt, 'DD.MM.YYYY') || ' ' || a.at_num
                       AS card_info,
                      (SELECT t.ndt_name
                         FROM uss_ndi.v_ndi_document_type t
                        WHERE t.ndt_id = d.atd_ndt)
                   || ' '
                   || TO_CHAR (SYSDATE, 'YYYYMMDDHH24MISS')
                   || '.pdf'
                       AS filename,
                   NULL /*dnet$pd_reports.get_act_term_doc_attach(p_at_id => atd_at, p_ndt_id => atd_ndt)*/
                       AS content,
                   d.atd_doc
                       AS doc_id,
                   d.atd_dh
                       AS dh_id
              FROM v_at_document  d
                   JOIN v_act a ON a.at_id = d.atd_at
                   JOIN ikis_sysweb.v$v_opfu_all o ON o.org_id = v_curr_org
             WHERE d.atd_id = p_atd_id --AND d.atd_ndt IN (860, 862)
                                       AND d.history_status = 'A';
    END;

    --====================================================--
    -- #87417: затвердити act допомоги
    --====================================================--
    PROCEDURE approve_act (p_at_id NUMBER, p_at_st VARCHAR2)
    IS
    BEGIN
        check_consistensy (P_AT_ID, P_AT_ST);
        API$ERRAND.decision_rstopv_approve (p_at_id);
    END;

    --====================================================--
    -- #87417: Поверенення акту допомоги на доопрацювання
    --====================================================--
    PROCEDURE return_act (p_at_id NUMBER, p_at_st VARCHAR2)
    IS
    BEGIN
        check_consistensy (P_AT_ID, P_AT_ST);
        API$ERRAND.decision_rstopv_return (p_at_id);
    END;

    --====================================================--
    -- #87417: Відхилення акту допомоги
    --====================================================--
    PROCEDURE reject_act (p_at_id NUMBER, p_at_st VARCHAR2)
    IS
    BEGIN
        check_consistensy (P_AT_ID, P_AT_ST);
        API$ERRAND.decision_rstopv_reject (p_at_id);
    END;

    --====================================================--
    -- #86960, #87522: затвердити act СП
    --====================================================--
    PROCEDURE approve_ss_act (p_at_id NUMBER, p_at_st VARCHAR2)
    IS
    BEGIN
        check_consistensy (P_AT_ID, P_AT_ST);
        API$ACT.approve_act (p_at_id);
    END;

    --====================================================--
    -- #86960, #87522: Поверенення акту СП на доопрацювання
    --====================================================--
    PROCEDURE return_ss_act (p_at_id    NUMBER,
                             p_reason   VARCHAR2,
                             p_at_st    VARCHAR2)
    IS
    BEGIN
        check_consistensy (P_AT_ID, P_AT_ST);
        API$ACT.return_act (p_at_id, p_reason);
    END;
BEGIN
    NULL;
END DNET$PAY_TERMINATE;
/