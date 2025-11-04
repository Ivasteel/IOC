/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$PAY_ASSIGNMENTS
IS
    -- Author  : BOGDAN
    -- Created : 14.07.2021 17:59:02
    -- Purpose : Призначення

    g_pd_id                 pc_decision.pd_id%TYPE;
    g_message               ap_log.apl_message%TYPE;

    Package_Name   CONSTANT VARCHAR2 (100) := 'DNET$PAY_ASSIGNMENTS';

    c_Xml_Dt_Fmt   CONSTANT VARCHAR2 (30) := 'YYYY-MM-DD"T"HH24:MI:SS';

    TYPE r_pd_features IS RECORD
    (
        pde_id            pd_features.pde_id%TYPE,
        pde_pd            pd_features.pde_pd%TYPE,
        pde_nft           pd_features.pde_nft%TYPE,
        pde_val_int       pd_features.pde_val_int%TYPE,
        pde_val_sum       pd_features.pde_val_sum%TYPE,
        pde_val_id        pd_features.pde_val_id%TYPE,
        pde_val_dt        pd_features.pde_val_dt%TYPE,
        -- pde_val_dt     VARCHAR2(30),
        pde_val_string    pd_features.pde_val_string%TYPE,
        pde_pdf           pd_features.pde_pdf%TYPE,
        New_Id            NUMBER,
        Deleted           NUMBER
    );

    TYPE t_pd_features IS TABLE OF r_pd_features;

    TYPE Type_Rec_pd_st IS RECORD
    (
        to_st         uss_ndi.v_ndi_pd_st_config.npsc_to_st%TYPE,
        action_sql    uss_ndi.v_ndi_pd_st_config.npsc_action_sql%TYPE
    );

    TYPE Type_Table_pd_st IS TABLE OF Type_Rec_pd_st;

    -- Перевірка права
    TYPE r_Pd_Right_Log IS RECORD
    (
        Prl_Id             Pd_Right_Log.Prl_Id%TYPE,
        Prl_Nrr            Pd_Right_Log.Prl_Nrr%TYPE,
        Prl_Calc_Result    Pd_Right_Log.Prl_Calc_Result%TYPE,
        Prl_Result         Pd_Right_Log.Prl_Result%TYPE
    );

    TYPE t_Pd_Right_Log IS TABLE OF r_Pd_Right_Log;

    -- Рішення про відмову
    TYPE r_pd_reject_info IS RECORD
    (
        pri_id     pd_reject_info.pri_id%TYPE,
        pri_nrr    pd_reject_info.pri_nrr%TYPE,
        pri_njr    pd_reject_info.pri_njr%TYPE
    );

    TYPE t_pd_reject_info IS TABLE OF r_pd_reject_info;

    -- Розрахунок доходу
    TYPE r_pd_income_src IS RECORD
    (
        pis_id           pd_income_src.pis_id%TYPE,
        pis_src          pd_income_src.pis_src%TYPE,
        pis_tp           pd_income_src.pis_tp%TYPE,
        pis_final_sum    pd_income_src.pis_final_sum%TYPE,
        pis_esv_paid     pd_income_src.pis_esv_paid%TYPE,
        pis_esv_min      pd_income_src.pis_esv_min%TYPE,
        pis_start_dt     VARCHAR2 (30),
        pis_stop_dt      VARCHAR2 (30),
        pis_app          pd_income_src.pis_app%TYPE,
        pis_sc           pd_income_src.pis_sc%TYPE,
        pis_is_use       pd_income_src.pis_is_use%TYPE,
        pis_use_tp       pd_income_src.pis_use_tp%TYPE,
        pis_tax_sum      pd_income_src.pis_tax_sum%TYPE,
        pis_edrpou       pd_income_src.pis_edrpou%TYPE,
        pis_pin          pd_income_src.pis_pin%TYPE,
        deleted          NUMBER
    );

    TYPE t_pd_income_src IS TABLE OF r_pd_income_src;

    TYPE r_appeal_init IS RECORD
    (
        Pa_Id     NUMBER,
        Nst_Id    NUMBER
    );

    TYPE t_appeal_init IS TABLE OF r_appeal_init;

    TYPE r_decision_UnBlock IS RECORD
    (
        Pdf_Id       NUMBER,
        Pdd_Id       NUMBER,
        Pdd_Value    pd_detail.pdd_value%TYPE,
        Pdd_Op       NUMBER
    );

    TYPE t_decision_UnBlock IS TABLE OF r_decision_UnBlock;

    -- #70335: Призначення\Черга звернень на призначення
    PROCEDURE Get_Queue (p_Start_Dt       IN     DATE,
                         p_Stop_Dt        IN     DATE,
                         p_Org_Id         IN     NUMBER,
                         p_Aps_Nst        IN     NUMBER,
                         p_Ap_Is_Second   IN     VARCHAR2,
                         Res_Cur             OUT SYS_REFCURSOR);

    -- #77560: Призначення\Черга звернень на соціальні послуги
    PROCEDURE GET_QUEUE_SS (p_start_dt       IN     DATE,
                            p_stop_dt        IN     DATE,
                            p_org_id         IN     NUMBER,
                            p_aps_nst        IN     NUMBER,
                            p_ap_is_second   IN     VARCHAR2,
                            P_IS_SCHOOL      IN     VARCHAR2,
                            res_cur             OUT SYS_REFCURSOR);

    -- #87326: Черга звернень на припинення надання СП
    PROCEDURE GET_QUEUE_R (p_start_dt       IN     DATE,
                           p_stop_dt        IN     DATE,
                           p_org_id         IN     NUMBER,
                           p_aps_nst        IN     NUMBER,
                           p_ap_is_second   IN     VARCHAR2,
                           P_IS_SCHOOL      IN     VARCHAR2,
                           res_cur             OUT SYS_REFCURSOR);

    -- #70334: ініціалізація призначення
    PROCEDURE INIT_DECISION_CARD (P_AP_ID   IN     NUMBER,
                                  p_xml     IN     CLOB,
                                  MSG_CUR      OUT SYS_REFCURSOR);

    -- #70520: "Повернути на довведення" звернення
    PROCEDURE RETURN_APPEAL (P_AP_ID IN NUMBER, p_reason IN VARCHAR2:= NULL);

    -- #70334: "Проекти рішень по зверненню"
    PROCEDURE Get_Decision_Card (
        p_Ap_Id             IN     NUMBER,
        P_PA_NUM            IN     VARCHAR2,
        P_PC_NUM            IN     VARCHAR2,
        P_PD_NST            IN     NUMBER,
        P_PD_ST             IN     VARCHAR2,
        p_org_id            IN     NUMBER,
        P_AP_REG_DT_START   IN     DATE,
        P_AP_REG_DT_STOP    IN     DATE,
        P_PD_DT_START       IN     DATE,
        P_PD_DT_STOP        IN     DATE,
        P_Ap_Num            IN     VARCHAR2,
        P_App_Ln            IN     VARCHAR2,
        P_App_Fn            IN     VARCHAR2,
        P_App_Mn            IN     VARCHAR2,
        P_Pd_Pay_Tp         IN     VARCHAR2,
        P_IS_ONLY_RETURN    IN     VARCHAR2,
        P_SCD_SER_NUM       IN     VARCHAR2,
        p_numident          IN     VARCHAR2,
        p_IsAuto            IN     VARCHAR2 DEFAULT 'F',
        p_pd_num            IN     VARCHAR2,
        p_ap_Src            IN     VARCHAR2,
        p_rnp_code          IN     VARCHAR2,
        p_Pcb_Exch_Code     IN     VARCHAR2,
        P_Nis_Id            IN     NUMBER,
        p_is_empty          IN     VARCHAR2 DEFAULT 'F',
        p_pd_org_id         IN     NUMBER,
        info_cur               OUT SYS_REFCURSOR,
        dec_cur                OUT SYS_REFCURSOR);

    PROCEDURE get_decision_info (p_pd_id   IN     NUMBER,
                                 dec_cur      OUT SYS_REFCURSOR);

    -- #86119
    FUNCTION get_right_block_flag (p_pd_id IN NUMBER)
        RETURN VARCHAR2;

    -- #77560: "Проекти рішень по соціальнм послугам"
    PROCEDURE get_decision_card_SS (p_ap_id             IN     NUMBER,
                                    p_pa_num            IN     VARCHAR2,
                                    p_pc_num            IN     VARCHAR2,
                                    p_pd_nst            IN     NUMBER,
                                    p_pd_st             IN     VARCHAR2,
                                    p_org_id            IN     NUMBER,
                                    p_ap_reg_dt_start   IN     DATE,
                                    p_ap_reg_dt_stop    IN     DATE,
                                    p_pd_dt_start       IN     DATE,
                                    p_pd_dt_stop        IN     DATE,
                                    p_ap_num            IN     VARCHAR2,
                                    p_app_ln            IN     VARCHAR2,
                                    p_app_fn            IN     VARCHAR2,
                                    p_app_mn            IN     VARCHAR2,
                                    p_pd_pay_tp         IN     VARCHAR2,
                                    p_is_only_return    IN     VARCHAR2,
                                    p_scd_ser_num       IN     VARCHAR2,
                                    p_numident          IN     VARCHAR2,
                                    info_cur               OUT SYS_REFCURSOR,
                                    dec_cur                OUT SYS_REFCURSOR);

    -- #70334: дані форми визначення права
    PROCEDURE Get_Decision_Rights (p_Pd_Id   IN     NUMBER,
                                   Res_Cur      OUT SYS_REFCURSOR);

    -- ініціалізація визначення права
    PROCEDURE INIT_DECISION_RIGHTS (p_pd_id          pc_decision.pd_id%TYPE,
                                    p_messages   OUT SYS_REFCURSOR);

    -- #70334: збереження форми визначення права
    PROCEDURE SAVE_DECISION_RIGHTS (P_PD_ID   IN NUMBER,
                                    P_PD_ST   IN VARCHAR2,
                                    P_CLOB    IN CLOB);

    -- #81045
    PROCEDURE pd_transfer (p_pd_id        IN     NUMBER,
                           p_pd_st        IN     VARCHAR2,
                           p_msg             OUT VARCHAR2,
                           p_pd_st_next      OUT VARCHAR2);

    -- #70334: дані форми "Рішення про відмову"
    PROCEDURE GET_DECISION_REJECTS (P_PD_ID   IN     NUMBER,
                                    RES_CUR      OUT SYS_REFCURSOR);

    -- #70334: збереження форми "Рішення про відмову"
    PROCEDURE SAVE_DECISION_REJECTS (P_PD_ID     IN     NUMBER,
                                     P_CLOB      IN     CLOB,
                                     P_ST           OUT VARCHAR2,
                                     P_ST_NAME      OUT VARCHAR2);

    -- #71916: Повернути рішення про відмову
    PROCEDURE REJECT_DECISION_REJECT (P_PD_ID     IN     NUMBER,
                                      P_ST           OUT VARCHAR2,
                                      P_ST_NAME      OUT VARCHAR2);

    -- #70334/#70351: вичитка форми "Розрахунок виплати / Виплата"
    PROCEDURE GET_DECISION_PAYMENTS (P_PD_ID      IN     NUMBER,
                                     PAY_CUR         OUT SYS_REFCURSOR,
                                     DET_CUR         OUT SYS_REFCURSOR,
                                     FEAT_CUR        OUT SYS_REFCURSOR,
                                     PERS_CUR        OUT SYS_REFCURSOR,
                                     PARAMS_CUR      OUT SYS_REFCURSOR,
                                     DFEAT_CUR       OUT SYS_REFCURSOR,
                                     BLOCK_CUR       OUT SYS_REFCURSOR,
                                     PERIOD_CUR      OUT SYS_REFCURSOR,
                                     DO_CUR          OUT SYS_REFCURSOR,
                                     CHECK_CUR       OUT SYS_REFCURSOR);

    -- #70334/#70351: ініціалізація форми "Розрахунок виплати / Виплата"
    PROCEDURE INIT_DECISION_PAYMENTS (P_PD_ID   IN     NUMBER,
                                      P_PD_ST   IN     VARCHAR2,
                                      PAY_CUR      OUT SYS_REFCURSOR);

    -- #70334/#70351: затвердити виплати
    PROCEDURE APPROVE_DECISION_PAYMENTS (P_PD_ID   IN NUMBER,
                                         P_PD_ST   IN VARCHAR2);

    PROCEDURE APPROVE_DECISION_PAYMENTS (P_PD_ID IN NUMBER);

    -- #79819: поновити виплати
    PROCEDURE decision_UnBlock (
        p_pd         pc_decision.pd_id%TYPE,
        p_start_dt   pd_accrual_period.pdap_start_dt%TYPE,
        p_stop_dt    pd_accrual_period.pdap_stop_dt%TYPE,
        p_xml        CLOB);

    -- #80861: Функция "Припинення виплати" в картці рішення
    PROCEDURE decision_Block (
        p_pd        pc_decision.pd_id%TYPE,
        p_stop_dt   pd_accrual_period.pdap_stop_dt%TYPE,
        p_PCB_RNP   pc_block.PCB_RNP%TYPE);

    -- #80891 Функція/кнопка "Активувати нарахування"
    PROCEDURE activate_accrual (
        p_pd         pc_decision.pd_id%TYPE,
        p_start_dt   pd_accrual_period.pdap_start_dt%TYPE,
        p_stop_dt    pd_accrual_period.pdap_stop_dt%TYPE);

    -- Поверенення проекту рішення на доопрацювання
    PROCEDURE return_pc_decision (p_pd_id    IN pc_decision.pd_id%TYPE,
                                  p_reason   IN VARCHAR2,
                                  p_pd_st    IN VARCHAR2);

    -- #78434: список "способів виплат" по рішенню
    PROCEDURE GET_PD_PAY_METHODS (P_PD_ID   IN     NUMBER,
                                  RES_CUR      OUT SYS_REFCURSOR);

    -- #70540: збереження "Параметри виплати"
    PROCEDURE SAVE_DECISION_PAYMENTS_PARAMS (
        P_PD_ID          IN NUMBER,
        P_PD_PAY_TP      IN VARCHAR2,
        P_PD_INDEX       IN VARCHAR2,
        P_PD_KAOT        IN NUMBER,
        P_PD_NB          IN NUMBER,
        P_PD_ACCOUNT     IN VARCHAR2,
        p_PD_STREET      IN Pd_Pay_Method.PDM_STREET%TYPE,
        p_PD_NS          IN Pd_Pay_Method.PDM_NS%TYPE,
        p_PD_BUILDING    IN Pd_Pay_Method.PDM_BUILDING%TYPE,
        p_PD_BLOCK       IN Pd_Pay_Method.PDM_BLOCK%TYPE,
        p_PD_APARTMENT   IN Pd_Pay_Method.PDM_APARTMENT%TYPE,
        p_PD_ND          IN Pd_Pay_Method.PDM_ND%TYPE,
        p_PD_PAY_DT      IN Pd_Pay_Method.PDM_PAY_DT%TYPE);

    -- налаштування ознак виплат
    PROCEDURE GET_DECISION_FEATURES_METADATA (RES_CUR OUT SYS_REFCURSOR);

    -- #70334: вичитка форми "розрахунку доходу"
    PROCEDURE GET_DECISION_INCOMES (P_PD_ID    IN     NUMBER,
                                    INFO_CUR      OUT SYS_REFCURSOR,
                                    PERS_CUR      OUT SYS_REFCURSOR,
                                    DET_CUR       OUT SYS_REFCURSOR,
                                    SES_CUR       OUT SYS_REFCURSOR);

    -- #82497 2022.12.28: Блокування кнопки «Розрахунок доходу» для рішень про СП
    FUNCTION Get_IsNeed_Income (p_pd_id NUMBER)
        RETURN NUMBER;

    -- #87142 20230509 Доступність кнопки «Затвердити» у рішеннях по SS-зверненнях
    FUNCTION Get_Is_Block_Approve (p_pd_id NUMBER)
        RETURN NUMBER;

    -- #89735 20230717 Доступність кнопки «Затвердити» у рішеннях по SS-зверненнях при відмові
    FUNCTION Get_Is_Block_Approve_4rej (p_pd_id NUMBER)
        RETURN NUMBER;

    -- #70334: збереження форми "Розрахунок доходу"
    PROCEDURE SAVE_DECISION_INCOMES (P_PD_ID   IN     NUMBER,
                                     P_CLOB    IN     CLOB,
                                     p_mode    IN     NUMBER DEFAULT 0, -- 0 - стандарт, 1 - #99052
                                     MSG_CUR      OUT SYS_REFCURSOR);

    -- #70334: вичитка форми "Дані помісячного розрахунку"
    PROCEDURE GET_PERSON_INFO (P_PIC_ID   IN     NUMBER,
                               P_APP_ID   IN     NUMBER,
                               RES_CUR       OUT SYS_REFCURSOR,
                               LOG_CUR       OUT SYS_REFCURSOR);

    -- #70724: лог виплат
    PROCEDURE GET_DECISION_LOG (P_PD_ID IN NUMBER, RES_CUR OUT SYS_REFCURSOR);

    -- #81873: лог "Впорядкування даних АСОПД"
    PROCEDURE GET_PCO_LOG (P_PCO_ID IN NUMBER, RES_CUR OUT SYS_REFCURSOR);

    -- info:   Підписання документа-рішення
    -- params: p_pd_id - ідентифікатор рішення
    --         p_doc_id - ідентифікатор документа Е/А
    --         p_dh_id - ідентифікатор зрізу документа Е/А
    -- note:   #77050/#78724
    PROCEDURE sign_decision (
        p_pd_id    IN pd_document.pdo_pd%TYPE,
        p_doc_id   IN pd_document.pdo_doc%TYPE DEFAULT NULL,
        p_dh_id    IN pd_document.pdo_dh%TYPE DEFAULT NULL);

    FUNCTION Check_pd_st_config (sqlstr VARCHAR2)
        RETURN NUMBER;

    PROCEDURE SAVE_Features (P_PD_ID IN NUMBER, P_CLOB IN CLOB);



    -- #80572: перенос всіх рішень з одного юзера на іншого
    PROCEDURE MOVE_ALL_TO_USER (P_WU_ID IN NUMBER, P_WU_TO_ID IN NUMBER);

    -- #80572: кількість рішень по юзеру
    PROCEDURE MOVE_DECISION_CNT (P_WU_ID IN NUMBER, P_CNT OUT NUMBER);

    -- #80572: перенос вибраних рішень з одного юзера на іншого
    PROCEDURE MOVE_TO_USER (P_WU_ID IN NUMBER, P_IDS IN VARCHAR2);

    -- #81873 - деталі "Впорядкування даних АСОПД"
    PROCEDURE GET_PCO_DETAILS (p_pco_id IN NUMBER, det_cur OUT SYS_REFCURSOR);

    -- #81873 - збереження і обробка "Впорядкування даних АСОПД"
    PROCEDURE SAVE_PCO_CARD (
        p_pco_id            IN NUMBER,
        p_pco_decision_tp   IN pc_data_ordering.pco_decision_tp%TYPE,
        p_pco_is_need_pay   IN pc_data_ordering.pco_is_need_pay%TYPE,
        p_pco_new_pdp_sum   IN pc_data_ordering.pco_new_pdp_sum%TYPE,
        p_pco_new_acd_sum   IN pc_data_ordering.pco_new_acd_sum%TYPE,
        p_xml               IN CLOB);

    -- #83758: "Особливий" режим редагування мігрованих рішень по ВПО
    PROCEDURE SAVE_MG_PAY_DETAILS (P_PDP_ID   IN NUMBER,
                                   P_PD_ST    IN VARCHAR2,
                                   p_xml      IN CLOB);

    -- #86328
    PROCEDURE delete_mg_detail (p_pdd_id IN NUMBER);

    -- #84435
    PROCEDURE get_acd_sums_to_manipulate (
        p_pd_id          pc_decision.pd_id%TYPE,
        p_acd_data   OUT SYS_REFCURSOR);

    -- #84435
    PROCEDURE manipulate_with_acd (p_pc_id          personalcase.pc_id%TYPE,
                                   p_pd_id          pc_decision.pd_id%TYPE,
                                   p_month          ac_detail.acd_start_dt%TYPE,
                                   p_sum            ac_detail.acd_sum%TYPE,
                                   p_acd_ids_list   VARCHAR2,
                                   p_decision       VARCHAR2);

    -- #92823
    PROCEDURE change_block_reason (p_pd_id IN NUMBER, p_pcb_id IN NUMBER);


    -- #94945: список послуг звернення
    PROCEDURE get_appeal_services (p_ap_id   IN     NUMBER,
                                   res_cur      OUT SYS_REFCURSOR);

    -- #94945: список особових рахунків звернення
    PROCEDURE get_appeal_pc_acc (p_ap_id   IN     NUMBER,
                                 res_cur      OUT SYS_REFCURSOR);

    -- #95765
    PROCEDURE get_pdf_payments (p_pd_id   IN     NUMBER,
                                p_dt      IN     DATE,
                                res_cur      OUT SYS_REFCURSOR);

    -- #96664: Перерахунок з 01.01.2024
    PROCEDURE recalc_pd_2024 (p_pd_id IN NUMBER, msg_cur OUT SYS_REFCURSOR);

    -- #114433: Перерахунок з 01.01.2025
    PROCEDURE recalc_pd_2025 (p_pd_id IN NUMBER, msg_cur OUT SYS_REFCURSOR);

    -- #97206
    PROCEDURE register_transmission (p_ap_id IN NUMBER);

    -- #100803
    PROCEDURE restore_payment_detail (p_pdd_id   IN NUMBER,
                                      p_reason   IN VARCHAR2,
                                      p_op       IN VARCHAR2);
END Dnet$pay_Assignments;
/


GRANT EXECUTE ON USS_ESR.DNET$PAY_ASSIGNMENTS TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$PAY_ASSIGNMENTS TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:42 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$PAY_ASSIGNMENTS
IS
    -- перевірка на консистентність даних
    PROCEDURE check_consistensy (P_PD_ID IN NUMBER, P_PD_ST IN VARCHAR2)
    IS
        l_st   VARCHAR2 (10);
    BEGIN
        SELECT pd_st
          INTO l_st
          FROM pc_decision t
         WHERE t.pd_id = p_pd_id;

        IF (l_st != p_pd_st OR p_pd_st IS NULL)
        THEN
            raise_application_error (
                -20000,
                'Дану операцію неможливо завершити. Дані застарілі. Оновіть сторінку і спробуйте знову.');
        END IF;
    END;

    -- #70335: Призначення\Черга звернень на призначення
    PROCEDURE GET_QUEUE (p_start_dt       IN     DATE,
                         p_stop_dt        IN     DATE,
                         p_org_id         IN     NUMBER,
                         p_aps_nst        IN     NUMBER,
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
                   (SELECT LISTAGG (st.nst_code || '-' || nst_name,
                                    ', ' || CHR (13) || CHR (10))
                           WITHIN GROUP (ORDER BY st.nst_order)
                      FROM v_ap_service  z
                           JOIN uss_ndi.v_ndi_service_type st
                               ON (st.nst_id = z.aps_nst)
                     WHERE z.aps_ap = t.ap_id --rownum < 4
                                              AND z.history_status = 'A')
                       AS Aps_List,
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
                   AND (   ap_tp IN ('V', 'U', 'VV')
                        OR -- прибрав 801 за команди Т.Дзери -- 14.02.2025 поновлено саме для черги на призначення. Дзеря
                           (    ap_tp IN ('O')
                            AND EXISTS
                                    (SELECT *
                                       FROM v_ap_service z
                                      WHERE     z.aps_ap = t.ap_id
                                            AND z.aps_nst IN (643,
                                                              645,
                                                              801,
                                                              923,
                                                              924,
                                                              1161,
                                                              1241)
                                            AND z.history_status = 'A'))
                        OR (    ap_tp IN ('REG')
                            AND EXISTS
                                    (SELECT *
                                       FROM v_ap_service z
                                      WHERE     z.aps_ap = t.ap_id
                                            AND z.aps_nst IN (1021)
                                            AND z.history_status = 'A')))
                   AND NOT EXISTS
                           (SELECT *
                              FROM v_ap_service z
                             WHERE     z.aps_ap = t.ap_id
                                   AND z.aps_nst IN (664)
                                   AND z.history_status = 'A')
                   AND TRUNC (t.ap_reg_dt) BETWEEN p_start_dt AND p_stop_dt
                   AND (   p_org_id IS NULL
                        OR t.com_org = p_org_id
                        OR t.ap_dest_org = p_org_id)
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
    END;

    -- #77560: Призначення\Черга звернень на соціальні послуги
    PROCEDURE GET_QUEUE_SS (p_start_dt       IN     DATE,
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
        --    SELECT COUNT(*) INTO l_cnt FROM tmp_org;
        --    SELECT COUNT(*) INTO l_cnt FROM v_appeal;
        --    SELECT u_org INTO l_cnt FROM tmp_org;
        --    raise_application_error(-20000, 'l_cnt='||l_cnt);
        -- raise_application_error(-20000, 'GET_QUEUE_SS'); pc_decision
        --raise_application_error(-20000, '  p_start_dt='||p_start_dt||'  p_stop_dt='||p_stop_dt||'  p_org_id='||p_org_id||'  p_aps_nst='||p_aps_nst||'  p_ap_is_second='||p_ap_is_second||'  P_IS_SCHOOL='||P_IS_SCHOOL);

        l_org_id := tools.GetCurrOrg;
        l_org_to := tools.GetCurrOrgto;
        --raise_application_error(-20000, '  p_org_id='||p_org_id||'  l_org_id='||l_org_id||'  l_org_to='||l_org_to||'  P_IS_SCHOOL='||P_IS_SCHOOL);
        tools.WriteMsg ('DNET$PAY_ASSIGNMENTS.' || $$PLSQL_UNIT);

        OPEN res_cur FOR
            SELECT t.*,
                   (SELECT dic_sname
                      FROM uss_ndi.v_ddn_ap_st z
                     WHERE z.DIC_VALUE = t.ap_st)
                       AS ap_st_name,
                   uss_person.api$sc_tools.GET_PIB_SCC (app.app_scc)
                       AS app_main_pib,
                   /*(SELECT Listagg(n.Nda_Name || ' ' || a.Apda_Val_String, ' ') Within GROUP(ORDER BY n.Nda_Order)
                      FROM Ap_Document_Attr a
                      JOIN Ap_Document d
                        ON a.Apda_Apd = d.Apd_Id
                           AND d.Apd_Ndt = 600
                           AND d.apd_app IN (SELECT p.app_id
                                               FROM v_ap_person p
                                              WHERE p.app_ap = t.ap_id
                                                AND p.app_tp = CASE WHEN t.ap_tp IN ('U', 'A') THEN 'O' ELSE 'Z' END
                                                AND p.app_sc = pc.pc_sc
                                                AND p.history_status = 'A'
                                              )
                           AND d.History_Status = 'A'
                      JOIN Uss_Ndi.v_Ndi_Document_Attr n
                        ON a.Apda_Nda = n.Nda_Id
                           AND n.Nda_Nng = 2
                     WHERE a.Apda_Ap = t.ap_id
                           AND a.History_Status = 'A'
                   ) AS App_Main_Address,*/
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
             --LEFT JOIN v_Pc_Decision dc ON (dc.pd_ap=t.ap_id and dc.pd_st = 'O.S')
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
                   AND ap_tp IN ('SS')
                   AND TRUNC (t.ap_reg_dt) BETWEEN p_start_dt AND p_stop_dt
                   /*AND ( (p_org_id IS NULL AND t.com_org = l_org_id )
                       OR  t.com_org = p_org_id
                       OR t.com_org = p_org_id
                          t.com_org IN (SELECT  t.org_id
                                        FROM v_opfu t
                                        WHERE t.org_st = 'A'
                                        CONNECT BY PRIOR t.org_id = t.org_org
                                        START WITH t.org_id = p_org_id)
                       )*/
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
        tools.WriteMsg ('DNET$PAY_ASSIGNMENTS.GET_QUEUE_R');

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

    -- #70334: ініціалізація призначення
    PROCEDURE INIT_DECISION_CARD (P_AP_ID   IN     NUMBER,
                                  p_xml     IN     CLOB,
                                  MSG_CUR      OUT SYS_REFCURSOR)
    IS
        l_arr   t_appeal_init := t_appeal_init ();
    BEGIN
        tools.WriteMsg ('DNET$PAY_ASSIGNMENTS.' || $$PLSQL_UNIT);

        --      raise_application_error(-20000, p_xml);
        IF (p_xml IS NOT NULL)
        THEN
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             't_appeal_init',
                                             TRUE,
                                             TRUE)
                BULK COLLECT INTO l_arr
                USING p_xml;

            FORALL i IN INDICES OF l_arr
                INSERT INTO TMP_WORK_PA_IDS (x_pa, x_nst, x_ap)
                     VALUES (l_Arr (i).pa_id, l_Arr (i).nst_id, P_AP_ID);
        END IF;

        api$pd_init.init_pc_decision_by_appeals (1, p_ap_id, MSG_CUR);
        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                ikis_message_util.GET_MESSAGE (
                    2,
                    'Dnet$pay_Assignments.INIT_DECISION_CARD:',
                       CHR (10)
                    || DBMS_UTILITY.format_error_stack
                    || DBMS_UTILITY.format_error_backtrace));
    END;

    -- #70520: "Повернути на довведення" звернення
    PROCEDURE RETURN_APPEAL (P_AP_ID IN NUMBER, p_reason IN VARCHAR2:= NULL)
    IS
        l_err   VARCHAR2 (4000);
    BEGIN
        SELECT LISTAGG (
                      'Згідно звернення '
                   || a.ap_num
                   || ' вже призначено допомогу '
                   || s.nst_name
                   || ' і рішення вже діюче (доведено до статусу "Нараховано")',
                   CHR (13) || CHR (10)
                   ON OVERFLOW TRUNCATE '...')
               WITHIN GROUP (ORDER BY pd_id)
          INTO l_err
          FROM appeal  a
               JOIN pc_decision pd ON pd.pd_ap_reason = a.AP_ID
               JOIN uss_ndi.v_ndi_service_type s ON s.nst_id = pd.pd_nst
         WHERE a.ap_id = P_AP_ID AND pd.pd_st IN ('S', 'PS');

        IF l_err IS NOT NULL
        THEN
            raise_application_error (-20000, l_err);
        END IF;

        api$appeal.return_appeal_to_editing (p_ap_id, p_reason);
    END;

    -- #70334: "Проекти рішень по зверненню"
    PROCEDURE get_decision_card_old (
        p_ap_id             IN     NUMBER,
        p_pa_num            IN     VARCHAR2,
        p_pc_num            IN     VARCHAR2,
        p_pd_nst            IN     NUMBER,
        p_pd_st             IN     VARCHAR2,
        p_org_id            IN     NUMBER,
        p_ap_reg_dt_start   IN     DATE,
        p_ap_reg_dt_stop    IN     DATE,
        p_pd_dt_start       IN     DATE,
        p_pd_dt_stop        IN     DATE,
        p_ap_num            IN     VARCHAR2,
        p_app_ln            IN     VARCHAR2,
        p_app_fn            IN     VARCHAR2,
        p_app_mn            IN     VARCHAR2,
        p_pd_pay_tp         IN     VARCHAR2,
        p_is_only_return    IN     VARCHAR2,
        p_scd_ser_num       IN     VARCHAR2,
        p_numident          IN     VARCHAR2,
        p_IsAuto            IN     VARCHAR2 DEFAULT 'F',
        p_pd_num            IN     VARCHAR2,
        p_ap_Src            IN     VARCHAR2,
        p_rnp_code          IN     VARCHAR2,
        p_Pcb_Exch_Code     IN     VARCHAR2,
        P_Nis_Id            IN     NUMBER,
        p_is_empty          IN     VARCHAR2 DEFAULT 'F',
        info_cur               OUT SYS_REFCURSOR,
        dec_cur                OUT SYS_REFCURSOR)
    IS
        l_init_tp    VARCHAR2 (10);
        l_msg        VARCHAR2 (4000);
        l_cur_oszn   VARCHAR2 (300);
        l_cnt        NUMBER;
        l_org        NUMBER;
        l_nis_part   VARCHAR2 (500) := '';
    BEGIN
        tools.WriteMsg ('DNET$PAY_ASSIGNMENTS.' || $$PLSQL_UNIT);

        IF (p_ap_id IS NOT NULL)
        THEN
            SELECT COUNT (*)
              INTO l_cnt
              FROM ap_service t
             WHERE     t.aps_ap = p_ap_id
                   AND t.aps_nst = 1021
                   AND t.history_status = 'A';

            IF (l_cnt > 0)
            THEN
                SELECT COUNT (*)
                  INTO l_cnt
                  FROM pc_attestat  t
                       JOIN pc_account pa ON (pa.pa_id = t.pca_pa)
                       LEFT JOIN v_opfu p1 ON (p1.org_id = t.pca_org_src)
                       LEFT JOIN v_opfu p2 ON (p2.org_id = t.pca_org_dest)
                 WHERE t.pca_ap_reason = p_ap_id AND t.pca_tp = 'PA';

                IF (l_cnt = 0)
                THEN
                    SELECT p2.org_id || ' ' || p2.org_name
                      INTO l_cur_oszn
                      FROM appeal  t
                           JOIN v_opfu p1 ON (p1.org_id = t.com_org)
                           JOIN v_opfu p2
                               ON (p2.org_id =
                                   DECODE (p1.org_to,
                                           32, p1.org_id,
                                           p1.org_org))
                     WHERE t.ap_id = p_ap_id;

                    SELECT    'За даними зверненням буде створено запит на передачу ОР № '
                           || LISTAGG (txt, '; ') WITHIN GROUP (ORDER BY 1)
                      INTO l_msg
                      FROM (  SELECT    LISTAGG (pa.pa_num, ',')
                                            WITHIN GROUP (ORDER BY 1)
                                     || ' з ОСЗН '
                                     || p1.org_id
                                     || ' '
                                     || p1.org_name
                                     || ' до ОСЗН '
                                     || l_cur_oszn    AS txt
                                FROM ap_document_attr t
                                     JOIN ap_document d
                                         ON (d.apd_id = t.apda_apd)
                                     JOIN appeal p ON (p.ap_id = t.apda_ap)
                                     JOIN pc_account pa ON (pa.pa_pc = p.ap_pc)
                                     LEFT JOIN v_opfu p1
                                         ON (p1.org_id = pa.pa_org)
                               WHERE     t.apda_ap = p_ap_id
                                     AND t.apda_nda = 4375
                                     AND d.apd_ndt = 10292
                                     AND d.history_status = 'A'
                                     AND t.history_status = 'A'
                                     AND pa.pa_nst = t.apda_val_string
                            GROUP BY p1.org_id, p1.org_name);

                    /*  SELECT listagg(pa.pa_num, ', ') within GROUP (ORDER BY 1), MAX(p.com_org)
                        INTO l_msg, l_org
                        FROM ap_document_attr t
                        JOIN ap_document d ON (d.apd_id = t.apda_apd)
                        JOIN appeal p ON (p.ap_id = t.apda_ap)
                        JOIN pc_account pa ON (pa.pa_pc = p.ap_pc)
                       WHERE t.apda_ap = p_ap_id
                         AND t.apda_nda = 4375
                         AND d.apd_ndt = 10292
                         AND d.history_status = 'A'
                         AND t.history_status = 'A'
                         AND pa.pa_nst = t.apda_val_string;*/

                    l_init_tp := 'confirm';
                --l_msg := 'За даними зверненням буде створено запит на передачу ОР № ' || l_msg;

                /*SELECT l_msg || ' з ОСЗН ' || t.org_id || ' ' || t.org_name || ' до ОСЗН ' || p.org_id || ' ' || p.org_name
                  INTO l_msg
                  FROM v_opfu t
                  JOIN v_opfu p ON (p.org_id = t.org_org)
                 WHERE t.org_id = l_org;*/
                ELSE
                    l_init_tp := 'error';
                    l_msg :=
                        'За даним зверненням вже створено запит на передачу ОР - перегляд стану запиту у відповідному реєстрі';
                END IF;
            END IF;
        END IF;

        OPEN INFO_CUR FOR
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
                       AS App_Main_Address/* ,CASE WHEN (t.ap_tp IN ('V', 'U') OR (t.ap_tp IN ('O') AND EXISTS (SELECT * FROM v_ap_service z WHERE z.aps_ap = t.ap_id AND z.aps_nst IN (643,645,801) AND z.history_status = 'A')))
                                                   THEN 'decision'
                                                 WHEN ap_tp IN ('A' , 'O') THEN 'deduction'
                                             END AS card_tp*/
                                          ,
                   l_init_tp
                       AS init_tp,
                   l_msg
                       AS init_msg
              FROM uss_esr.v_appeal  t
                   LEFT OUTER JOIN v_personalcase pc ON (pc.pc_id = t.ap_pc)
                   LEFT OUTER JOIN ap_person app
                       ON     app.app_sc = pc.pc_sc
                          AND app.app_ap = t.ap_id
                          AND app.history_status = 'A'
             WHERE t.ap_id = P_AP_ID;

        --raise_application_error(-20000, 'p_IsAuto='||p_IsAuto|| '    p_pd_st='||p_pd_st );

        DELETE FROM tmp_work_ids1;

        IF P_PC_NUM IS NOT NULL
        THEN
            INSERT INTO tmp_work_ids1 (x_id)
                SELECT pc_id
                  FROM personalcase
                 WHERE pc_num LIKE P_PC_NUM || '%';
        END IF;

        OPEN DEC_CUR FOR
            SELECT /*+ FIRST_ROWS(500) */
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
                   t.com_org
                       AS pd_com_org,
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
                   (SELECT MAX (pdap_stop_dt + 1)
                      FROM pd_accrual_period pp
                     WHERE     pdap_pd = t.pd_id
                           AND pp.history_status = 'A')
                       AS pdap_stop_dt,
                   pa.pa_num,
                   (SELECT nst.nst_code
                      FROM uss_ndi.v_ndi_service_type nst
                     WHERE nst.nst_id = t.pd_nst)
                       AS pd_nst_sname,       -- || ' ' || nst.nst_name #77803
                   (SELECT nst.nst_code || ' ' || nst.nst_name
                      FROM uss_ndi.v_ndi_service_type nst
                     WHERE nst.nst_id = t.pd_nst)
                       AS pd_nst_name,
                   (SELECT z.DIC_NAME
                      FROM uss_ndi.v_ddn_pd_st z
                     WHERE z.DIC_VALUE = t.pd_st)
                       AS pd_st_name,
                   (SELECT hs.hs_dt
                      FROM histsession hs
                     WHERE hs.hs_id = t.pd_hs_return)
                       AS return_dt,
                   (SELECT tools.GetUserPib (hs.hs_wu)
                      FROM histsession hs
                     WHERE hs.hs_id = t.pd_hs_return)
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
                   --uss_person.api$sc_tools.GET_PIB_SCC(t.pd_scc) AS app_main_pib,
                   uss_person.api$sc_tools.GET_PIB_SCC (pm.pdm_scc)
                       AS app_main_pib,
                   uss_person.api$sc_tools.get_numident (pc.pc_sc)
                       AS App_Numident,
                   /*(SELECT Listagg( CASE WHEN t.pd_nst = 664 OR a.Apda_Val_String IS NULL THEN '' ELSE n.Nda_Name || ' ' END || a.Apda_Val_String, ' ') Within GROUP(ORDER BY n.Nda_Order)
                      FROM Ap_Document_Attr a
                      JOIN Ap_Document d
                        ON a.Apda_Apd = d.Apd_Id
                           AND d.Apd_Ndt = CASE WHEN t.pd_nst = 664 THEN 605 ELSE 600 END
                           AND d.apd_app IN (SELECT p.app_id
                                               FROM v_ap_person p
                                              WHERE p.app_ap = ap.ap_id
                                                AND p.app_tp = CASE WHEN ap.ap_tp IN ('U', 'A', 'PP') THEN 'O' ELSE 'Z' END
                                                AND p.app_sc = pc.pc_sc
                                                AND p.history_status = 'A'
                                              )
                           AND d.History_Status = 'A'
                      JOIN Uss_Ndi.v_Ndi_Document_Attr n
                        ON a.Apda_Nda = n.Nda_Id
                           AND n.Nda_Nng = CASE WHEN t.pd_nst = 664 THEN 60 ELSE 2 END
                     WHERE a.Apda_Ap = ap.ap_id
                           AND a.History_Status = 'A'
                   ) AS App_Main_Address,*/
                   tools.get_main_addr (ap.ap_id,
                                        ap.ap_tp,
                                        pc.pc_sc,
                                        t.pd_nst)
                       AS App_Main_Address,
                   pc.pc_num,
                   pc.pc_sc,
                   pc.com_org
                       AS pc_com_Org,
                   (SELECT z.DIC_NAME
                      FROM uss_ndi.v_ddn_pd_src z
                     WHERE z.DIC_VALUE = t.pd_src)
                       AS pd_src_name,
                   NVL (
                       TRIM (
                           BOTH '-' FROM
                               (SELECT    TO_CHAR (MIN (pdap_start_dt),
                                                   'DD.MM.YYYY')
                                       || '-'
                                       || TO_CHAR (MAX (pdap_stop_dt),
                                                   'DD.MM.YYYY')
                                  FROM pd_accrual_period pp
                                 WHERE     pdap_pd = t.pd_id
                                       AND pp.history_status = 'A')),
                          'очік: '
                       || TO_CHAR (pd_start_dt, 'DD.MM.YYYY')
                       || '-'
                       || TO_CHAR (pd_stop_dt, 'DD.MM.YYYY'))
                       AS pd_real_period,
                   /*             NVL((SELECT to_char(pdap_start_dt, 'DD.MM.YYYY')||'-'||to_char(pdap_stop_dt, 'DD.MM.YYYY')
                                     FROM pd_accrual_period pp
                                     WHERE pdap_pd = t.pd_id AND pp.history_status = 'A' AND trunc(SYSDATE) BETWEEN pp.pdap_start_dt AND pp.pdap_stop_dt order by pdap_start_dt desc fetch first row only ), -- OPERVEIEV #80462
                                    'очік: '||to_char(pd_start_dt, 'DD.MM.YYYY')||'-'||to_char(pd_stop_dt, 'DD.MM.YYYY')) AS pd_real_period,*/
                   (CASE
                        WHEN     COALESCE (t.pd_is_signed, 'F') = 'F'
                             AND t.pd_st IN ('P', 'V')
                             AND t.pd_nst IN (664,
                                              269,
                                              268,
                                              267,
                                              265,
                                              249,
                                              248)
                        THEN
                            1
                        ELSE
                            0
                    END)
                       AS approve_with_sign, --#77050/#78724: 1 - кнопка "Затвердити з підписом ЕЦП" доступна/ 0 - НІ
                   (SELECT MAX (z.DIC_NAME)
                      FROM uss_ndi.V_DDN_PD_SUSPEND_REASON z
                     WHERE z.DIC_VALUE = t.pd_suspend_reason)
                       AS pd_suspend_reason_name,
                   (SELECT MAX (z.DIC_NAME)
                      FROM uss_ndi.v_ddn_ap_src z
                     WHERE z.DIC_VALUE = ap.ap_src)
                       AS ap_src_name,
                   t.pd_pcb,
                   (SELECT MAX (zp.rnp_name)
                      FROM pc_block  zb
                           JOIN uss_Ndi.v_Ndi_Reason_Not_Pay zp
                               ON (zp.rnp_id = zb.pcb_rnp)
                     WHERE zb.pcb_id = t.pd_pcb)
                       AS pd_pcb_name,
                   (SELECT MAX (zp.rnp_pnp_tp)
                      FROM pc_block  zb
                           JOIN uss_Ndi.v_Ndi_Reason_Not_Pay zp
                               ON (zp.rnp_id = zb.pcb_rnp)
                     WHERE zb.pcb_id = t.pd_pcb)
                       AS rnp_pnp_tp,
                   (SELECT MAX (zp.rnp_code)
                      FROM pc_block  zb
                           JOIN uss_Ndi.v_Ndi_Reason_Not_Pay zp
                               ON (zp.rnp_id = zb.pcb_rnp)
                     WHERE zb.pcb_id = t.pd_pcb)
                       AS rnp_code,
                   CASE
                       WHEN p_pd_st = 'MOVE'
                       THEN
                           tools.GetUserLogin (t.com_wu)
                   END
                       AS User_Login,
                   (SELECT SUM (zq.pdp_sum)
                      FROM pd_payment  zq
                           JOIN uss_ndi.v_ndi_npt_config zc
                               ON (zc.nptc_npt = zq.pdp_npt)
                     WHERE     zq.pdp_pd = t.pd_id
                           AND zc.nptc_nst = t.pd_nst
                           AND zq.history_status = 'A'
                           AND TRUNC (SYSDATE) BETWEEN zq.pdp_start_dt
                                                   AND zq.pdp_stop_dt
                     FETCH FIRST ROW ONLY)
                       AS help_sum,
                   (  SELECT hsb.hs_dt
                        FROM pc_block zb
                             JOIN histsession hsb
                                 ON (hsb.hs_id = zb.pcb_hs_lock)
                       WHERE zb.pcb_pd = t.pd_id
                    ORDER BY hsb.hs_dt DESC
                       FETCH FIRST ROW ONLY)
                       AS block_dt,
                   (  SELECT hsb.hs_dt
                        FROM pc_block zb
                             JOIN histsession hsb
                                 ON (hsb.hs_id = zb.pcb_hs_unlock)
                       WHERE zb.pcb_pd = t.pd_id
                    ORDER BY hsb.hs_dt DESC
                       FETCH FIRST ROW ONLY)
                       AS unblock_dt,
                   CASE
                       WHEN ap_res.com_org != ap.com_org
                       THEN
                              'Проект рішення створено на підставі звернення '
                           || ap_res.ap_num
                           || ' органу '
                           || ap_res.com_org
                           || ' в зв`язку із тим, що учасник рішення вибув до іншого району'
                   END
                       AS open_appeal_err_msg,
                   (CASE
                        WHEN     t.pd_dt <=
                                 TO_DATE ('20.12.2023', 'DD.MM.YYYY')
                             AND t.pd_st IN ('S')
                             AND t.pd_nst IN (249,
                                              267,
                                              265,
                                              248,
                                              268)
                        THEN
                            1
                        ELSE
                            0
                    END)
                       AS can_recalc_2024 --#96664: 1 - кнопка "Перерахунок з 01.01.2024" доступна/ 0 - НІ
              FROM v_pc_decision  t
                   JOIN Pd_Pay_Method pm
                       ON     pm.pdm_pd = t.pd_id
                          AND pm.pdm_is_actual = 'T'
                          AND pm.history_status = 'A'
                   JOIN pc_account pa ON (pa.pa_id = t.pd_pa)
                   JOIN uss_esr.appeal ap
                       ON     ap.ap_id = t.pd_ap
                          AND (p_org_id IS NULL OR ap.com_org = p_org_id)
                   LEFT OUTER JOIN personalcase pc ON (pc.pc_id = pd_pc)
                   --JOIN ap_person app ON app.app_sc = pc.pc_sc AND app.app_ap = ap.ap_id AND app.history_status = 'A'
                   --JOIN uss_person.v_sc_document sd on (pc.pc_sc=sd.scd_sc and (sd.scd_ndt=5 or sd.scd_ndt=6 ))
                   JOIN appeal ap_res ON (ap_res.ap_id = t.pd_ap_reason)
             WHERE     1 = 1
                   --AND EXISTS (SELECT 1 FROM pc_location rls_pl, tmp_org x  WHERE pd_pc = rls_pl.pl_pc AND rls_pl.history_status = 'A' AND rls_pl.pl_org = x.u_org)
                   AND ap.ap_tp != 'SS'
                   AND (   (p_IsAuto = 'F' AND t.com_wu IS NOT NULL)
                        OR (p_IsAuto = 'T' AND t.com_wu IS NULL)
                        OR p_pd_st IN ('P',
                                       'S',
                                       'PS',
                                       'MASS_CALC_PREP',
                                       'MOVE')
                        OR p_pd_st IS NULL)
                   -- #78648
                   AND (   p_PD_ST IS NULL
                        OR     p_pd_St = 'MASS_CALC_PREP'
                           AND t.pd_st NOT IN ('S', 'V')
                        OR p_pd_St = 'MOVE'
                        OR     p_pd_St != 'MASS_CALC_PREP'
                           AND p_pd_St != 'MOVE'
                           AND t.pd_st = P_PD_ST)
                   AND (       p_ap_id IS NOT NULL
                           AND (t.pd_ap = p_ap_id OR t.pd_ap_reason = p_ap_id)
                        OR     p_ap_id IS NULL
                           AND (   P_PA_NUM IS NULL
                                OR pa.pa_num LIKE P_PA_NUM || '%')
                           AND (   P_PC_NUM IS NULL
                                OR EXISTS
                                       (SELECT 1
                                          FROM tmp_work_ids1
                                         WHERE x_id = pc_id))
                           --AND (P_PC_NUM IS NULL OR pc_num LIKE P_PC_NUM || '%' )
                           AND (P_PD_NST IS NULL OR t.pd_nst = P_PD_NST))
                   AND (   P_IS_ONLY_RETURN = 'F'
                        OR     P_IS_ONLY_RETURN = 'T'
                           AND t.pd_hs_return IS NOT NULL)
                   AND (   p_is_empty = 'F'
                        OR p_is_empty = 'T' AND t.com_wu IS NULL)
                   AND (       P_AP_REG_DT_START IS NULL
                           AND P_AP_REG_DT_STOP IS NULL
                        OR     P_AP_REG_DT_START IS NULL
                           AND P_AP_REG_DT_STOP IS NOT NULL
                           AND ap_res.ap_reg_dt <= P_AP_REG_DT_STOP
                        OR     P_AP_REG_DT_START IS NOT NULL
                           AND P_AP_REG_DT_STOP IS NULL
                           AND ap_res.ap_reg_dt >= P_AP_REG_DT_START
                        OR ap_res.ap_reg_dt BETWEEN P_AP_REG_DT_START
                                                AND P_AP_REG_DT_STOP)
                   AND (   P_PD_DT_START IS NULL AND P_PD_DT_STOP IS NULL
                        OR     P_PD_DT_START IS NULL
                           AND P_PD_DT_STOP IS NOT NULL
                           AND t.pd_dt <= P_PD_DT_STOP
                        OR     P_PD_DT_START IS NOT NULL
                           AND P_PD_DT_STOP IS NULL
                           AND t.pd_dt >= P_PD_DT_START
                        OR t.pd_dt BETWEEN P_PD_DT_START AND P_PD_DT_STOP)
                   AND (   P_Ap_Num IS NULL
                        OR ap.ap_num LIKE p_ap_num || '%'
                        OR ap_res.ap_num LIKE p_ap_num || '%')
                   AND (P_Pd_Pay_Tp IS NULL OR pm.pdm_pay_tp = P_Pd_Pay_Tp)
                   AND (       P_APP_LN IS NULL
                           AND P_App_Fn IS NULL
                           AND P_App_Mn IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM v_ap_person  zz
                                       JOIN uss_person.v_socialcard zs
                                           ON (zs.sc_id = zz.app_sc)
                                       JOIN uss_person.v_sc_change zch
                                           ON (zch.scc_id = zs.sc_scc)
                                       JOIN uss_person.v_sc_identity zi
                                           ON (zi.sci_id = zch.scc_sci)
                                 WHERE     zz.app_ap = ap.ap_id
                                       AND zz.app_tp =
                                           CASE
                                               WHEN ap.ap_tp IN ('U', 'A')
                                               THEN
                                                   'O'
                                               ELSE
                                                   'Z'
                                           END
                                       AND (   p_app_ln IS NULL
                                            OR UPPER (zi.sci_ln) LIKE
                                                      UPPER (TRIM (p_app_ln))
                                                   || '%')
                                       AND (   p_app_fn IS NULL
                                            OR UPPER (zi.sci_fn) LIKE
                                                      UPPER (TRIM (p_app_fn))
                                                   || '%')
                                       AND (   p_app_mn IS NULL
                                            OR UPPER (zi.sci_mn) LIKE
                                                      UPPER (TRIM (p_app_mn))
                                                   || '%')))
                   AND (   P_SCD_SER_NUM IS NULL
                        OR EXISTS
                               (SELECT 1
                                  FROM v_ap_person               zz,
                                       uss_person.v_sc_document  sd
                                 WHERE     pc.pc_sc = sd.scd_sc
                                       AND sd.scd_sc = zz.app_sc
                                       AND pc.pc_sc = zz.app_sc
                                       AND zz.app_ap = ap.ap_id
                                       AND sd.scd_ndt IN (6, 7)
                                       AND sd.scd_st IN ('A', '1')
                                       AND (sd.scd_seria || sd.scd_number =
                                            REPLACE (P_SCD_SER_NUM, ' ', ''))))
                   AND (p_pd_num IS NULL OR pd_num LIKE p_pd_num || '%')
                   --         AND (p_pc_num IS NULL OR p_pc_num IS NOT NULL and pc_num LIKE p_pc_num || '%')
                   AND (p_ap_Src IS NULL OR ap.ap_src = p_ap_Src)
                   AND (   p_Pcb_Exch_Code IS NULL
                        OR EXISTS
                               (SELECT 1
                                  FROM pc_block b
                                 WHERE     b.pcb_id = t.pd_pcb
                                       AND b.pcb_exch_code = p_Pcb_Exch_Code))
                   AND (   p_numident IS NULL
                        OR /*EXISTS (SELECT *
                                   FROM v_ap_person zz
                                     JOIN uss_person.v_socialcard zs ON (zs.sc_id = zz.app_sc)
                                     JOIN uss_person.v_sc_document sd on (pc.pc_sc=sd.scd_sc and (sd.scd_ndt = 5))
                                   WHERE zz.app_ap = ap.ap_id
                                     AND  sd.scd_number = p_numident))*/
                           -- 20220811: по заявці Тетяни Ніконової
                           EXISTS
                               (SELECT *
                                  FROM uss_person.v_sc_document sd
                                 WHERE     sd.scd_ndt = 5
                                       AND pc.pc_sc = sd.scd_sc
                                       AND sd.scd_st IN ('A', '1')
                                       AND sd.scd_number = p_numident))
                   AND (   p_rnp_code IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM uss_ndi.v_ndi_reason_not_pay  z,
                                       pc_block                      b
                                 WHERE     z.rnp_code = p_rnp_code
                                       AND z.rnp_id = b.pcb_rnp
                                       AND b.pcb_id = t.pd_pcb))
                   AND (   P_Nis_Id IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM uss_ndi.v_ndi_nis_users zz
                                 WHERE     zz.nisu_nis = P_Nis_Id
                                       AND zz.nisu_wu = t.com_wu))
                   AND ROWNUM < 502;
    END;

    --================================================================
    PROCEDURE get_decision_card (
        p_ap_id             IN     NUMBER,
        p_pa_num            IN     VARCHAR2,
        p_pc_num            IN     VARCHAR2,
        p_pd_nst            IN     NUMBER,
        p_pd_st             IN     VARCHAR2,
        p_org_id            IN     NUMBER,
        p_ap_reg_dt_start   IN     DATE,
        p_ap_reg_dt_stop    IN     DATE,
        p_pd_dt_start       IN     DATE,
        p_pd_dt_stop        IN     DATE,
        p_ap_num            IN     VARCHAR2,
        p_app_ln            IN     VARCHAR2,
        p_app_fn            IN     VARCHAR2,
        p_app_mn            IN     VARCHAR2,
        p_pd_pay_tp         IN     VARCHAR2,
        p_is_only_return    IN     VARCHAR2,
        p_scd_ser_num       IN     VARCHAR2,
        p_numident          IN     VARCHAR2,
        p_IsAuto            IN     VARCHAR2 DEFAULT 'F',
        p_pd_num            IN     VARCHAR2,
        p_ap_Src            IN     VARCHAR2,
        p_rnp_code          IN     VARCHAR2,
        p_Pcb_Exch_Code     IN     VARCHAR2,
        P_Nis_Id            IN     NUMBER,
        p_is_empty          IN     VARCHAR2 DEFAULT 'F',
        p_pd_org_id         IN     NUMBER,
        info_cur               OUT SYS_REFCURSOR,
        dec_cur                OUT SYS_REFCURSOR)
    IS
        l_init_tp    VARCHAR2 (10);
        l_msg        VARCHAR2 (4000);
        l_cur_oszn   VARCHAR2 (300);
        l_cnt        NUMBER;
        l_org        NUMBER;
        l_sql        VARCHAR2 (8000);
        l_nis_part   VARCHAR2 (500) := '';

        PROCEDURE Add_sql (p_sql VARCHAR2)
        IS
        BEGIN
            l_sql := l_sql || CHR (13) || CHR (10) || p_sql;
        END;
    BEGIN
        tools.WriteMsg ('DNET$PAY_ASSIGNMENTS.' || $$PLSQL_UNIT);

        IF (p_ap_id IS NOT NULL)
        THEN
            SELECT COUNT (*)
              INTO l_cnt
              FROM ap_service t
             WHERE     t.aps_ap = p_ap_id
                   AND t.aps_nst = 1021
                   AND t.history_status = 'A';

            IF (l_cnt > 0)
            THEN
                SELECT COUNT (*)
                  INTO l_cnt
                  FROM pc_attestat  t
                       JOIN pc_account pa ON (pa.pa_id = t.pca_pa)
                       LEFT JOIN v_opfu p1 ON (p1.org_id = t.pca_org_src)
                       LEFT JOIN v_opfu p2 ON (p2.org_id = t.pca_org_dest)
                 WHERE t.pca_ap_reason = p_ap_id AND t.pca_tp = 'PA';

                IF (l_cnt = 0)
                THEN
                    SELECT p2.org_id || ' ' || p2.org_name
                      INTO l_cur_oszn
                      FROM appeal  t
                           JOIN v_opfu p1 ON (p1.org_id = t.com_org)
                           JOIN v_opfu p2
                               ON (p2.org_id =
                                   DECODE (p1.org_to,
                                           32, p1.org_id,
                                           p1.org_org))
                     WHERE t.ap_id = p_ap_id;

                    SELECT    'За даними зверненням буде створено запит на передачу ОР № '
                           || LISTAGG (txt, '; ') WITHIN GROUP (ORDER BY 1)
                      INTO l_msg
                      FROM (  SELECT    LISTAGG (pa.pa_num, ',')
                                            WITHIN GROUP (ORDER BY 1)
                                     || ' з ОСЗН '
                                     || p1.org_id
                                     || ' '
                                     || p1.org_name
                                     || ' до ОСЗН '
                                     || l_cur_oszn    AS txt
                                FROM ap_document_attr t
                                     JOIN ap_document d
                                         ON (d.apd_id = t.apda_apd)
                                     JOIN appeal p ON (p.ap_id = t.apda_ap)
                                     JOIN pc_account pa ON (pa.pa_pc = p.ap_pc)
                                     LEFT JOIN v_opfu p1
                                         ON (p1.org_id = pa.pa_org)
                               WHERE     t.apda_ap = p_ap_id
                                     AND t.apda_nda = 4375
                                     AND d.apd_ndt = 10292
                                     AND d.history_status = 'A'
                                     AND t.history_status = 'A'
                                     AND pa.pa_nst = t.apda_val_string
                            GROUP BY p1.org_id, p1.org_name);

                    l_init_tp := 'confirm';
                ELSE
                    l_init_tp := 'error';
                    l_msg :=
                        'За даним зверненням вже створено запит на передачу ОР - перегляд стану запиту у відповідному реєстрі';
                END IF;
            END IF;
        END IF;

        OPEN INFO_CUR FOR
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
                       AS App_Main_Address/* ,CASE WHEN (t.ap_tp IN ('V', 'U') OR (t.ap_tp IN ('O') AND EXISTS (SELECT * FROM v_ap_service z WHERE z.aps_ap = t.ap_id AND z.aps_nst IN (643,645,801) AND z.history_status = 'A')))
                                                   THEN 'decision'
                                                 WHEN ap_tp IN ('A' , 'O') THEN 'deduction'
                                             END AS card_tp*/
                                          ,
                   l_init_tp
                       AS init_tp,
                   l_msg
                       AS init_msg
              FROM uss_esr.v_appeal  t
                   LEFT OUTER JOIN v_personalcase pc ON (pc.pc_id = t.ap_pc)
                   LEFT OUTER JOIN ap_person app
                       ON     app.app_sc = pc.pc_sc
                          AND app.app_ap = t.ap_id
                          AND app.history_status = 'A'
             WHERE t.ap_id = P_AP_ID;

        --raise_application_error(-20000, 'p_IsAuto='||p_IsAuto|| '    p_pd_st='||p_pd_st );

        DELETE FROM tmp_work_ids1;

        IF P_PC_NUM IS NOT NULL
        THEN
            INSERT INTO tmp_work_ids1 (x_id)
                SELECT pc_id
                  FROM personalcase
                 WHERE pc_num LIKE P_PC_NUM || '%';
        END IF;

        l_sql :=
            q'[
  WITH flt AS
       (SELECT :1  as p_ap_id,
               :2  as p_pa_num,
               :3  as p_pc_num,
               :4  as p_pd_nst,
               :5  as p_pd_st,
               :6  as p_org_id,
               :7  as p_ap_reg_dt_start,
               :8  as p_ap_reg_dt_stop,
               :9  as p_pd_dt_start,
               :10 as p_pd_dt_stop,
               :11 as p_ap_num,
               :12 as p_app_ln,
               :13 as p_app_fn,
               :14 as p_app_mn,
               :15 as p_pd_pay_tp,
               :16 as p_is_only_return,
               :17 as p_scd_ser_num,
               :18 as p_numident,
               :19 as p_pd_num,
               :20 as p_ap_Src,
               :21 as p_rnp_code,
               :22 as p_Pcb_Exch_Code,
               :23 as P_Nis_Id,
               :24 as p_is_empty,
               :25 as p_pd_org_id
        FROM dual
       )
  SELECT /*+ FIRST_ROWS(500) */
         pd_pc, pd_ap, pd_id, pd_pa, pd_dt, pd_st, pd_has_right, pd_hs_right, pd_hs_reject,
         pd_hs_app, pd_hs_mapp, pd_hs_head, pd_start_dt, pd_stop_dt, pd_num, pd_nst, t.com_org AS pd_com_org,
         t.com_wu, pdm_pay_tp, pdm_index, pdm_kaot, pdm_nb, pdm_account, pdm_street, pdm_ns, pdm_building,
         pdm_block, pdm_apartment, pdm_nd, pdm_pay_dt, pd_hs_return, pd_src, pd_ps, pd_src_id, pd_ap_reason,

         (SELECT MAX(pdap_stop_dt + 1)
            FROM pd_accrual_period pp
            WHERE pdap_pd = t.pd_id AND pp.history_status = 'A'
         ) AS pdap_stop_dt,

         pa.pa_num,
         (SELECT nst.nst_code FROM uss_ndi.v_ndi_service_type nst WHERE nst.nst_id = t.pd_nst) AS pd_nst_sname,-- || ' ' || nst.nst_name #77803
         (SELECT nst.nst_code || ' ' || nst.nst_name FROM uss_ndi.v_ndi_service_type nst WHERE nst.nst_id = t.pd_nst) AS pd_nst_name,
         (SELECT z.DIC_NAME FROM uss_ndi.v_ddn_pd_st z WHERE z.DIC_VALUE = t.pd_st) AS pd_st_name,
         (SELECT hs.hs_dt FROM histsession hs WHERE hs.hs_id = t.pd_hs_return) AS return_dt,
         (SELECT tools.GetUserPib(hs.hs_wu) FROM histsession hs WHERE hs.hs_id = t.pd_hs_return) AS return_pib,

         ap.ap_id,
         ap.ap_pc,
         ap.ap_src_id,
         ap.ap_tp,
         NVL(ap_res.ap_reg_dt, ap.ap_reg_dt) AS ap_reg_dt,
         ap.ap_src,
         ap.ap_st,
         ap.ap_is_second,
         NVL(ap_res.ap_num, ap.ap_num) AS ap_num,
         ap.ap_vf,
         (SELECT dic_sname FROM uss_ndi.v_ddn_ap_st z WHERE z.DIC_VALUE = ap.ap_st) AS ap_st_name,
         uss_person.api$sc_tools.GET_PIB_SCC(pm.pdm_scc) AS app_main_pib,
         uss_person.api$sc_tools.get_numident(pc.pc_sc) AS App_Numident,
         tools.get_main_addr(ap.ap_id, ap.ap_tp, pc.pc_sc, t.pd_nst) AS App_Main_Address,

         pc.pc_num,
         pc.pc_sc,
         pc.com_org AS pc_com_Org,
         (SELECT z.DIC_NAME FROM uss_ndi.v_ddn_pd_src z WHERE z.DIC_VALUE = t.pd_src) AS pd_src_name,
         NVL(TRIM(BOTH '-' FROM (SELECT to_char(MIN(pdap_start_dt), 'DD.MM.YYYY')||'-'||to_char(MAX(pdap_stop_dt), 'DD.MM.YYYY')
                                 FROM pd_accrual_period pp
                                 WHERE pdap_pd = t.pd_id AND pp.history_status = 'A')),
             'очік: '||to_char(pd_start_dt, 'DD.MM.YYYY')||'-'||to_char(pd_stop_dt, 'DD.MM.YYYY')) AS pd_real_period,
         (CASE WHEN coalesce(t.pd_is_signed, 'F') = 'F' AND t.pd_st IN ('P', 'V') AND t.pd_nst IN (664, 269, 268, 267, 265, 249, 248) THEN 1 ELSE 0 END) AS approve_with_sign, --#77050/#78724: 1 - кнопка "Затвердити з підписом ЕЦП" доступна/ 0 - НІ
         (SELECT MAX(z.DIC_NAME) FROM uss_ndi.V_DDN_PD_SUSPEND_REASON z WHERE z.DIC_VALUE = t.pd_suspend_reason) AS pd_suspend_reason_name,
         (SELECT MAX(z.DIC_NAME) FROM uss_ndi.v_ddn_ap_src z WHERE z.DIC_VALUE = ap.ap_src) AS ap_src_name,
         t.pd_pcb,
         (SELECT MAX(zp.rnp_name) FROM pc_block zb JOIN uss_Ndi.v_Ndi_Reason_Not_Pay zp ON (zp.rnp_id = zb.pcb_rnp) WHERE zb.pcb_id = t.pd_pcb) AS pd_pcb_name,
         (SELECT MAX(zp.rnp_pnp_tp) FROM pc_block zb JOIN uss_Ndi.v_Ndi_Reason_Not_Pay zp ON (zp.rnp_id = zb.pcb_rnp) WHERE zb.pcb_id = t.pd_pcb) AS rnp_pnp_tp,
         (SELECT MAX(zp.rnp_code) FROM pc_block zb JOIN uss_Ndi.v_Ndi_Reason_Not_Pay zp ON (zp.rnp_id = zb.pcb_rnp) WHERE zb.pcb_id = t.pd_pcb) AS rnp_code,
         CASE WHEN p_pd_st = 'MOVE' THEN tools.GetUserLogin(t.com_wu) END AS User_Login,
         (SELECT SUM(zq.pdp_sum)
            FROM pd_payment zq
            JOIN uss_ndi.v_ndi_npt_config zc ON (zc.nptc_npt = zq.pdp_npt)
           WHERE zq.pdp_pd = t.pd_id
             AND zc.nptc_nst = t.pd_nst
             AND zq.history_status = 'A'
             AND trunc(SYSDATE) BETWEEN zq.pdp_start_dt AND zq.pdp_stop_dt
         FETCH FIRST ROW ONLY) AS help_sum,
         (SELECT hsb.hs_dt
            FROM pc_block zb
            JOIN histsession hsb ON (hsb.hs_id = zb.pcb_hs_lock)
           WHERE zb.pcb_pd = t.pd_id
          ORDER BY hsb.hs_dt DESC
          FETCH FIRST ROW ONLY
         ) AS block_dt,
         (SELECT hsb.hs_dt
            FROM pc_block zb
            JOIN histsession hsb ON (hsb.hs_id = zb.pcb_hs_unlock)
           WHERE zb.pcb_pd = t.pd_id
          ORDER BY hsb.hs_dt DESC
          FETCH FIRST ROW ONLY
         ) AS unblock_dt,
         CASE WHEN ap_res.com_org != ap.com_org THEN 'Проект рішення створено на підставі звернення ' || ap_res.ap_num || ' органу ' || ap_res.com_org || ' в зв`язку із тим, що учасник рішення вибув до іншого району' END AS open_appeal_err_msg,
         (CASE WHEN t.pd_dt <= to_date('20.12.2023', 'DD.MM.YYYY')  AND t.pd_st IN ('S') AND t.pd_nst IN (249,267,265,248,268) THEN 1
               ELSE 0
           END) AS can_recalc_2024, --#96664: 1 - кнопка "Перерахунок з 01.01.2024" доступна/ 0 - НІ
         (CASE WHEN
           (SELECT count(*)
              FROM pd_accrual_period pp
             WHERE pdap_pd = t.pd_id
               AND pp.history_status = 'A'
               and pp.pdap_stop_dt >= to_date('01.01.2025', 'DD.MM.YYYY')
           ) > 0 AND t.pd_st IN ('S') AND t.pd_nst IN (901) THEN 1
              WHEN t.pd_dt between to_date('01.08.2024', 'DD.MM.YYYY') and to_date('25.12.2024', 'DD.MM.YYYY')  AND t.pd_st IN ('S') AND t.pd_nst IN (249) THEN 1
              ELSE 0 END) AS can_recalc_2025 --#114433: 1 - кнопка "Перерахунок з 01.01.2025" доступна/ 0 - НІ
    FROM flt f,
    v_pc_decision t
    JOIN Pd_Pay_Method pm ON pm.pdm_pd = t.pd_id AND  pm.pdm_is_actual='T' AND pm.history_status = 'A'
    JOIN pc_account pa ON (pa.pa_id = t.pd_pa)
    JOIN uss_esr.appeal ap ON ap.ap_id = t.pd_ap
    LEFT OUTER JOIN personalcase pc ON (pc.pc_id = pd_pc)
    JOIN appeal ap_res ON (ap_res.ap_id = t.pd_ap_reason)
   WHERE ap.ap_tp != 'SS'
     AND (p_org_id IS NULL OR ap.com_org = p_org_id)
     AND (p_pd_org_id IS NULL OR t.com_org = p_pd_org_id)
]';

        /*
                      (p_IsAuto = 'F' AND t.com_wu IS NOT NULL)
                      OR
                      (p_IsAuto = 'T' AND t.com_wu IS NULL)
                      OR p_pd_st IN ('P', 'S', 'PS', 'MASS_CALC_PREP', 'MOVE')
                      OR p_pd_st IS NULL
        */
        IF p_pd_st IS NULL
        THEN
            NULL;
        ELSIF p_pd_st IN ('P',
                          'S',
                          'PS',
                          'MASS_CALC_PREP',
                          'MOVE')
        THEN
            NULL;
        ELSIF p_IsAuto = 'F'
        THEN
            Add_sql (q'[AND (t.com_wu IS NOT NULL )]');
        ELSIF p_IsAuto = 'T' AND p_pd_st IS NULL
        THEN
            Add_sql (q'[AND (t.com_wu IS NULL )]');
        END IF;

        /*
            IF    p_IsAuto = 'F' AND p_pd_st IS NULL THEN
              Add_sql(q'[AND (t.com_wu IS NOT NULL )]');
            ELSIF p_IsAuto = 'F' AND p_pd_st IS NOT NULL THEN
              Add_sql(q'[AND (t.com_wu IS NOT NULL OR p_pd_st IN ('P', 'S', 'PS', 'MASS_CALC_PREP', 'MOVE'))]');
            ELSIF p_IsAuto = 'T' AND p_pd_st IS NULL THEN
              Add_sql(q'[AND (t.com_wu IS NULL )]');
            ELSIF p_IsAuto = 'T' AND p_pd_st IS NOT NULL THEN
              Add_sql(q'[AND (t.com_wu IS NULL OR p_pd_st IN ('P', 'S', 'PS', 'MASS_CALC_PREP', 'MOVE'))]');
            END IF;
        */

        -- #78648
        IF p_PD_ST IS NULL
        THEN
            NULL;
        ELSIF p_pd_St = 'MASS_CALC_PREP'
        THEN
            Add_sql (q'[AND (t.pd_st NOT IN ('S', 'V'))]');
        ELSIF p_pd_St = 'MOVE'
        THEN
            NULL;
        ELSE
            Add_sql (q'[AND (t.pd_st = P_PD_ST)]');
        END IF;

        IF p_ap_id IS NOT NULL
        THEN
            Add_sql (
                q'[AND (t.pd_ap = p_ap_id OR t.pd_ap_reason = p_ap_id)]');
        ELSE
            IF P_PA_NUM IS NOT NULL
            THEN
                Add_sql (q'[AND (pa.pa_num LIKE P_PA_NUM || '%' )]');
            END IF;

            IF P_PC_NUM IS NOT NULL
            THEN
                Add_sql (
                    q'[AND EXISTS (SELECT 1 FROM tmp_work_ids1 WHERE x_id = pc_id)]');
            END IF;

            IF P_PD_NST IS NOT NULL
            THEN
                Add_sql (q'[AND (t.pd_nst = P_PD_NST)]');
            END IF;
        END IF;

        IF P_IS_ONLY_RETURN = 'T'
        THEN
            Add_sql (q'[AND ( t.pd_hs_return IS NOT NULL )]');
        END IF;

        IF p_is_empty = 'T'
        THEN
            Add_sql (q'[AND ( t.com_wu IS NULL )]');
        END IF;

        IF P_AP_REG_DT_START IS NULL AND P_AP_REG_DT_STOP IS NOT NULL
        THEN
            Add_sql (q'[AND ( ap_res.ap_reg_dt <= P_AP_REG_DT_STOP )]');
        ELSIF P_AP_REG_DT_START IS NOT NULL AND P_AP_REG_DT_STOP IS NULL
        THEN
            Add_sql (q'[AND ( ap_res.ap_reg_dt >= P_AP_REG_DT_START )]');
        ELSIF P_AP_REG_DT_START IS NOT NULL AND P_AP_REG_DT_STOP IS NOT NULL
        THEN
            Add_sql (
                q'[AND ( ap_res.ap_reg_dt BETWEEN P_AP_REG_DT_START AND P_AP_REG_DT_STOP )]');
        END IF;

        IF P_PD_DT_START IS NULL AND P_PD_DT_STOP IS NOT NULL
        THEN
            Add_sql (q'[AND ( t.pd_dt <= P_PD_DT_STOP )]');
        ELSIF P_PD_DT_START IS NOT NULL AND P_PD_DT_STOP IS NULL
        THEN
            Add_sql (q'[AND ( t.pd_dt >= P_PD_DT_START )]');
        ELSIF P_PD_DT_START IS NOT NULL AND P_PD_DT_STOP IS NOT NULL
        THEN
            Add_sql (
                q'[AND ( t.pd_dt BETWEEN P_PD_DT_START AND P_PD_DT_STOP )]');
        END IF;

        IF P_Ap_Num IS NOT NULL
        THEN
            Add_sql (
                q'[AND ( ap.ap_num LIKE p_ap_num||'%' OR ap_res.ap_num LIKE p_ap_num||'%' )]');
        END IF;

        IF P_Pd_Pay_Tp IS NOT NULL
        THEN
            Add_sql (q'[AND ( pm.pdm_pay_tp = P_Pd_Pay_Tp )]');
        END IF;


        IF    P_APP_LN IS NOT NULL
           OR P_App_Fn IS NOT NULL
           OR P_App_Mn IS NOT NULL
        THEN
            Add_sql (
                q'[AND EXISTS (SELECT 1
                   FROM v_ap_person zz
                   JOIN uss_person.v_socialcard zs ON (zs.sc_id = zz.app_sc)
                   JOIN uss_person.v_sc_change zch ON (zch.scc_id = zs.sc_scc)
                   JOIN uss_person.v_sc_identity zi ON (zi.sci_id = zch.scc_sci)
                  WHERE zz.app_ap = ap.ap_id
                    AND zz.app_tp = CASE WHEN ap.ap_tp IN ('U', 'A') THEN 'O' ELSE 'Z' END
                    AND (p_app_ln IS NULL OR upper(zi.sci_ln) LIKE upper(TRIM(p_app_ln))||'%')
                    AND (p_app_fn IS NULL OR upper(zi.sci_fn) LIKE upper(TRIM(p_app_fn))||'%')
                    AND (p_app_mn IS NULL OR upper(zi.sci_mn) LIKE upper(TRIM(p_app_mn))||'%')
                ) ]');
        END IF;

        IF P_SCD_SER_NUM IS NOT NULL
        THEN
            Add_sql (
                q'[AND EXISTS (SELECT 1
                   FROM v_ap_person zz, uss_person.v_sc_document sd
                   WHERE pc.pc_sc=sd.scd_sc
                     AND sd.scd_sc = zz.app_sc
                     and pc.pc_sc = zz.app_sc
                     and zz.app_ap = ap.ap_id
                     AND sd.scd_ndt IN (6, 7)
                     AND sd.scd_st IN ('A', '1')
                     AND upper(sd.scd_seria || sd.scd_number) = REPLACE(upper(P_SCD_SER_NUM), ' ', '')
                ) ]');
        END IF;

        IF p_pd_num IS NOT NULL
        THEN
            Add_sql (q'[AND ( pd_num LIKE p_pd_num || '%' )]');
        END IF;

        IF p_ap_Src IS NOT NULL
        THEN
            Add_sql (q'[AND ( ap.ap_src = p_ap_Src )]');
        END IF;

        IF p_Pcb_Exch_Code IS NOT NULL
        THEN
            Add_sql (
                q'[AND EXISTS (SELECT 1 FROM pc_block b WHERE b.pcb_id = t.pd_pcb AND b.pcb_exch_code = p_Pcb_Exch_Code)]');
        END IF;

        -- 20220811: по заявці Тетяни Ніконової
        IF p_numident IS NOT NULL
        THEN
            Add_sql (q'[AND EXISTS (SELECT 1
         FROM uss_person.v_sc_document sd
         WHERE sd.scd_ndt = 5
           AND pc.pc_sc = sd.scd_sc
           AND sd.scd_st IN ('A', '1')
           AND  sd.scd_number = p_numident)]');
        END IF;

        IF p_rnp_code IS NOT NULL
        THEN
            Add_sql (q'[AND EXISTS (SELECT 1
         FROM uss_ndi.v_ndi_reason_not_pay z, pc_block b
         WHERE z.rnp_code = p_rnp_code
           AND z.rnp_id = b.pcb_rnp
           AND b.pcb_id = t.pd_pcb )]');
        END IF;

        IF P_Nis_Id IS NOT NULL
        THEN
            Add_sql (q'[AND EXISTS (SELECT 1
         FROM uss_ndi.v_ndi_nis_users zz
         WHERE zz.nisu_nis = P_Nis_Id
           AND zz.nisu_wu = t.com_wu )]');
        END IF;

        OPEN DEC_CUR FOR l_sql
            USING p_ap_id,
        p_pa_num,
        p_pc_num,
        p_pd_nst,
        p_pd_st,
        p_org_id,
        p_ap_reg_dt_start,
        p_ap_reg_dt_stop,
        p_pd_dt_start,
        p_pd_dt_stop,
        p_ap_num,
        p_app_ln,
        p_app_fn,
        p_app_mn,
        p_pd_pay_tp,
        p_is_only_return,
        p_scd_ser_num,
        p_numident,
        p_pd_num,
        p_ap_Src,
        p_rnp_code,
        p_Pcb_Exch_Code,
        P_Nis_Id,
        p_is_empty,
        p_pd_org_id;
    END;

    PROCEDURE get_decision_info (p_pd_id   IN     NUMBER,
                                 dec_cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.WriteMsg ('DNET$PAY_ASSIGNMENTS.' || $$PLSQL_UNIT);

        OPEN DEC_CUR FOR
            SELECT /*+ FIRST_ROWS(500) */
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
                   t.com_org
                       AS pd_com_org,
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
                   (SELECT MAX (pdap_stop_dt + 1)
                      FROM pd_accrual_period pp
                     WHERE     pdap_pd = t.pd_id
                           AND pp.history_status = 'A')
                       AS pdap_stop_dt,
                   pa.pa_num,
                   (SELECT nst.nst_code
                      FROM uss_ndi.v_ndi_service_type nst
                     WHERE nst.nst_id = t.pd_nst)
                       AS pd_nst_sname,       -- || ' ' || nst.nst_name #77803
                   (SELECT nst.nst_code || ' ' || nst.nst_name
                      FROM uss_ndi.v_ndi_service_type nst
                     WHERE nst.nst_id = t.pd_nst)
                       AS pd_nst_name,
                   (SELECT z.DIC_NAME
                      FROM uss_ndi.v_ddn_pd_st z
                     WHERE z.DIC_VALUE = t.pd_st)
                       AS pd_st_name,
                   (SELECT hs.hs_dt
                      FROM histsession hs
                     WHERE hs.hs_id = t.pd_hs_return)
                       AS return_dt,
                   (SELECT tools.GetUserPib (hs.hs_wu)
                      FROM histsession hs
                     WHERE hs.hs_id = t.pd_hs_return)
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
                   --uss_person.api$sc_tools.GET_PIB_SCC(t.pd_scc) AS app_main_pib,
                   uss_person.api$sc_tools.GET_PIB_SCC (pm.pdm_scc)
                       AS app_main_pib,
                   uss_person.api$sc_tools.get_numident (pc.pc_sc)
                       AS App_Numident,
                   /*(SELECT Listagg( CASE WHEN t.pd_nst = 664 OR a.Apda_Val_String IS NULL THEN '' ELSE n.Nda_Name || ' ' END || a.Apda_Val_String, ' ') Within GROUP(ORDER BY n.Nda_Order)
                      FROM Ap_Document_Attr a
                      JOIN Ap_Document d
                        ON a.Apda_Apd = d.Apd_Id
                           AND d.Apd_Ndt = CASE WHEN t.pd_nst = 664 THEN 605 ELSE 600 END
                           AND d.apd_app IN (SELECT p.app_id
                                               FROM v_ap_person p
                                              WHERE p.app_ap = ap.ap_id
                                                AND p.app_tp = CASE WHEN ap.ap_tp IN ('U', 'A', 'PP') THEN 'O' ELSE 'Z' END
                                                AND p.app_sc = pc.pc_sc
                                                AND p.history_status = 'A'
                                              )
                           AND d.History_Status = 'A'
                      JOIN Uss_Ndi.v_Ndi_Document_Attr n
                        ON a.Apda_Nda = n.Nda_Id
                           AND n.Nda_Nng = CASE WHEN t.pd_nst = 664 THEN 60 ELSE 2 END
                     WHERE a.Apda_Ap = ap.ap_id
                           AND a.History_Status = 'A'
                   ) AS App_Main_Address,*/
                   tools.get_main_addr (ap.ap_id,
                                        ap.ap_tp,
                                        pc.pc_sc,
                                        t.pd_nst)
                       AS App_Main_Address,
                   pc.pc_num,
                   pc.pc_sc,
                   pc.com_org
                       AS pc_com_Org,
                   (SELECT z.DIC_NAME
                      FROM uss_ndi.v_ddn_pd_src z
                     WHERE z.DIC_VALUE = t.pd_src)
                       AS pd_src_name,
                   NVL (
                       TRIM (
                           BOTH '-' FROM
                               (SELECT    TO_CHAR (MIN (pdap_start_dt),
                                                   'DD.MM.YYYY')
                                       || '-'
                                       || TO_CHAR (MAX (pdap_stop_dt),
                                                   'DD.MM.YYYY')
                                  FROM pd_accrual_period pp
                                 WHERE     pdap_pd = t.pd_id
                                       AND pp.history_status = 'A')),
                          'очік: '
                       || TO_CHAR (pd_start_dt, 'DD.MM.YYYY')
                       || '-'
                       || TO_CHAR (pd_stop_dt, 'DD.MM.YYYY'))
                       AS pd_real_period,
                   /*             NVL((SELECT to_char(pdap_start_dt, 'DD.MM.YYYY')||'-'||to_char(pdap_stop_dt, 'DD.MM.YYYY')
                                     FROM pd_accrual_period pp
                                     WHERE pdap_pd = t.pd_id AND pp.history_status = 'A' AND trunc(SYSDATE) BETWEEN pp.pdap_start_dt AND pp.pdap_stop_dt order by pdap_start_dt desc fetch first row only ), -- OPERVEIEV #80462
                                    'очік: '||to_char(pd_start_dt, 'DD.MM.YYYY')||'-'||to_char(pd_stop_dt, 'DD.MM.YYYY')) AS pd_real_period,*/
                   (CASE
                        WHEN     COALESCE (t.pd_is_signed, 'F') = 'F'
                             AND t.pd_st IN ('P', 'V')
                             AND t.pd_nst IN (664,
                                              269,
                                              268,
                                              267,
                                              265,
                                              249,
                                              248)
                        THEN
                            1
                        ELSE
                            0
                    END)
                       AS approve_with_sign, --#77050/#78724: 1 - кнопка "Затвердити з підписом ЕЦП" доступна/ 0 - НІ
                   (SELECT MAX (z.DIC_NAME)
                      FROM uss_ndi.V_DDN_PD_SUSPEND_REASON z
                     WHERE z.DIC_VALUE = t.pd_suspend_reason)
                       AS pd_suspend_reason_name,
                   (SELECT MAX (z.DIC_NAME)
                      FROM uss_ndi.v_ddn_ap_src z
                     WHERE z.DIC_VALUE = ap.ap_src)
                       AS ap_src_name,
                   t.pd_pcb,
                   (SELECT MAX (zp.rnp_name)
                      FROM pc_block  zb
                           JOIN uss_Ndi.v_Ndi_Reason_Not_Pay zp
                               ON (zp.rnp_id = zb.pcb_rnp)
                     WHERE zb.pcb_id = t.pd_pcb)
                       AS pd_pcb_name,
                   (SELECT MAX (zp.rnp_pnp_tp)
                      FROM pc_block  zb
                           JOIN uss_Ndi.v_Ndi_Reason_Not_Pay zp
                               ON (zp.rnp_id = zb.pcb_rnp)
                     WHERE zb.pcb_id = t.pd_pcb)
                       AS rnp_pnp_tp,
                   (SELECT MAX (zp.rnp_code)
                      FROM pc_block  zb
                           JOIN uss_Ndi.v_Ndi_Reason_Not_Pay zp
                               ON (zp.rnp_id = zb.pcb_rnp)
                     WHERE zb.pcb_id = t.pd_pcb)
                       AS rnp_code,
                   tools.GetUserLogin (t.com_wu)
                       AS User_Login,
                   (SELECT SUM (zq.pdp_sum)
                      FROM pd_payment  zq
                           JOIN uss_ndi.v_ndi_npt_config zc
                               ON (zc.nptc_npt = zq.pdp_npt)
                     WHERE     zq.pdp_pd = t.pd_id
                           AND zc.nptc_nst = t.pd_nst
                           AND zq.history_status = 'A'
                           AND TRUNC (SYSDATE) BETWEEN zq.pdp_start_dt
                                                   AND zq.pdp_stop_dt
                     FETCH FIRST ROW ONLY)
                       AS help_sum,
                   (  SELECT hsb.hs_dt
                        FROM pc_block zb
                             JOIN histsession hsb
                                 ON (hsb.hs_id = zb.pcb_hs_lock)
                       WHERE zb.pcb_pd = t.pd_id
                    ORDER BY hsb.hs_dt DESC
                       FETCH FIRST ROW ONLY)
                       AS block_dt,
                   (  SELECT hsb.hs_dt
                        FROM pc_block zb
                             JOIN histsession hsb
                                 ON (hsb.hs_id = zb.pcb_hs_unlock)
                       WHERE zb.pcb_pd = t.pd_id
                    ORDER BY hsb.hs_dt DESC
                       FETCH FIRST ROW ONLY)
                       AS unblock_dt,
                   CASE
                       WHEN ap_res.com_org != ap.com_org
                       THEN
                              'Проект рішення створено на підставі звернення '
                           || ap_res.ap_num
                           || ' органу '
                           || ap_res.com_org
                           || ' в зв`язку із тим, що учасник рішення вибув до іншого району'
                   END
                       AS open_appeal_err_msg,
                   (CASE
                        WHEN     t.pd_dt <=
                                 TO_DATE ('20.12.2023', 'DD.MM.YYYY')
                             AND t.pd_st IN ('S')
                             AND t.pd_nst IN (249,
                                              267,
                                              265,
                                              248,
                                              268)
                        THEN
                            1
                        ELSE
                            0
                    END)
                       AS can_recalc_2024 --#96664: 1 - кнопка "Перерахунок з 01.01.2024" доступна/ 0 - НІ
              FROM v_pc_decision  t
                   JOIN Pd_Pay_Method pm
                       ON     pm.pdm_pd = t.pd_id
                          AND pm.pdm_is_actual = 'T'
                          AND pm.history_status = 'A'
                   JOIN pc_account pa ON (pa.pa_id = t.pd_pa)
                   JOIN uss_esr.appeal ap ON ap.ap_id = t.pd_ap
                   LEFT OUTER JOIN personalcase pc ON (pc.pc_id = pd_pc)
                   JOIN appeal ap_res ON (ap_res.ap_id = t.pd_ap_reason)
             WHERE pd_id = p_pd_id;
    END;

    -- #86119
    FUNCTION get_right_block_flag (p_pd_id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_c1   NUMBER;
        l_c2   NUMBER;
        l_c3   NUMBER;
        l_c4   NUMBER;
        l_c5   NUMBER;
    BEGIN
        SELECT (SELECT COUNT (*)
                  FROM v_ap_document z
                 WHERE     z.apd_ap = t.pd_ap
                       AND z.apd_ndt IN (801,
                                         802,
                                         836,
                                         835)
                       AND z.history_status = 'A')       AS c1,
               (SELECT COUNT (*)
                  FROM pd_document d
                 WHERE     d.pdo_pd = t.pd_id
                       AND d.pdo_ndt IN (804                         /*, 818*/
                                            )
                       AND d.history_status = 'A')       AS c2,
               /*(SELECT COUNT(*)
                  FROM pd_document d
                 WHERE d.pdo_pd = t.pd_id
                   AND d.pdo_ndt in (804, 819)
                   AND d.history_status = 'A'
               ) AS c3,*/
                (SELECT COUNT (*)
                   FROM ap_document  d
                        JOIN ap_document_attr da ON (da.apda_apd = d.apd_id)
                  WHERE     d.apd_ap = t.pd_ap
                        AND (   d.apd_ndt IN (801) AND da.apda_nda IN (1871)
                             OR d.apd_ndt IN (802) AND da.apda_nda IN (1948)
                             OR d.apd_ndt IN (803) AND da.apda_nda IN (2528)
                             OR d.apd_ndt IN (836) AND da.apda_nda IN (3446)
                             OR d.apd_ndt IN (835) AND da.apda_nda IN (3265))
                        AND d.history_status = 'A'
                        AND da.apda_val_string = 'T')    AS c4,
               (SELECT COUNT (*)
                  FROM pd_income_calc c
                 WHERE c.pic_pd = t.pd_id)               AS c5
          INTO l_c1,
               l_c2,                                                 /*l_c3,*/
               l_c4,
               l_c5
          FROM v_pc_decision t
         WHERE t.pd_id = p_pd_id;

        RETURN CASE
                   WHEN l_c4 > 0 AND l_c5 = 0 THEN 'T'               -- #87960
                   WHEN l_c1 = 0 THEN 'F'
                   /*WHEN l_c1 > 0 AND (l_c2 = 2 OR l_c3 = 2) THEN 'F'
                   WHEN l_c1 > 0 AND (l_c2 < 2 AND l_c3 < 2) THEN 'T'*/
                   WHEN l_c1 > 0 AND l_c2 = 1 THEN 'F'
                   WHEN l_c1 > 0 AND l_c2 < 1 THEN 'T'
                   ELSE 'F'
               END;
    END;


    -- #77560: "Проекти рішень по соціальнм послугам"
    PROCEDURE get_decision_card_SS (p_ap_id             IN     NUMBER,
                                    p_pa_num            IN     VARCHAR2,
                                    p_pc_num            IN     VARCHAR2,
                                    p_pd_nst            IN     NUMBER,
                                    p_pd_st             IN     VARCHAR2,
                                    p_org_id            IN     NUMBER,
                                    p_ap_reg_dt_start   IN     DATE,
                                    p_ap_reg_dt_stop    IN     DATE,
                                    p_pd_dt_start       IN     DATE,
                                    p_pd_dt_stop        IN     DATE,
                                    p_ap_num            IN     VARCHAR2,
                                    p_app_ln            IN     VARCHAR2,
                                    p_app_fn            IN     VARCHAR2,
                                    p_app_mn            IN     VARCHAR2,
                                    p_pd_pay_tp         IN     VARCHAR2,
                                    p_is_only_return    IN     VARCHAR2,
                                    p_scd_ser_num       IN     VARCHAR2,
                                    p_numident          IN     VARCHAR2,
                                    info_cur               OUT SYS_REFCURSOR,
                                    dec_cur                OUT SYS_REFCURSOR)
    IS
        l_org_id   NUMBER;
        l_org_to   NUMBER;
    BEGIN
        --raise_application_error(-20000, 'p_pd_st = '||p_pd_st);

        tools.WriteMsg ('DNET$PAY_ASSIGNMENTS.' || $$PLSQL_UNIT);

        l_org_id := tools.GetCurrOrg;
        l_org_to := tools.GetCurrOrgTo;

        --raise_application_error(-20000, 'l_org_id = '||l_org_id || '   l_org_to = '||l_org_to);

        OPEN INFO_CUR FOR
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
                   /*(SELECT Listagg(CASE WHEN a.apda_nda NOT IN (1879, 1974, 1645) THEN n.nda_name || ' ' END || a.Apda_Val_String, ' ') Within GROUP(ORDER BY n.Nda_Order)
                      FROM Ap_Document_Attr a
                      JOIN Ap_Document d
                        ON a.Apda_Apd = d.Apd_Id
                          -- AND d.Apd_Ndt IN (801, 802, 803)
                           AND d.apd_app IN (SELECT p.app_id
                                               FROM v_ap_person p
                                              WHERE p.app_ap = ap.ap_id
                                                AND p.app_tp = CASE WHEN ap.ap_tp IN ('U', 'A') THEN 'O' ELSE 'Z' END
                                                AND p.app_sc = pc.pc_sc
                                                AND p.history_status = 'A'
                                              )
                           AND d.History_Status = 'A'
                      JOIN Uss_Ndi.v_Ndi_Document_Attr n
                        ON a.Apda_Nda = n.Nda_Id
                     WHERE a.Apda_Ap = ap.ap_id
                           AND a.History_Status = 'A'
                           AND ((d.apd_ndt = 801 AND a.apda_nda IN ( 1874, 1875, 1876, 1877, 1878, 1879, 1880, 1881, 1882)) OR
                                (d.apd_ndt = 802 AND a.apda_nda IN ( 1969, 1970, 1971, 1972, 1973, 1974, 1975, 1976, 1977)) OR
                                 d.apd_ndt = 803 AND nda_nng = 61 AND nda_id NOT IN (2456, 1494)
                                )
                           AND a.apda_val_string IS NOT NULL
                   ) AS App_Main_Address,*/
                   tools.get_main_addr_ss (t.pd_ap, ap.ap_tp, pc.pc_sc)
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
                   Get_IsNeed_Income (pd_id)
                       AS is_need_income,
                   Get_Is_Block_Approve (pd_id)
                       AS is_block_approve,
                   Get_Is_Block_Approve_4rej (pd_id)
                       AS is_block_approve_4rej,
                   get_right_block_flag (t.pd_id)
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
                   --JOIN uss_esr.v_appeal ap ON (ap.ap_id = t.pd_ap  AND (p_org_id IS NULL OR ap.com_org = p_org_id))
                   JOIN uss_esr.v_appeal ap ON ap.ap_id = t.pd_ap
                   JOIN v_personalcase pc ON (pc.pc_id = pd_pc)
                   --JOIN ap_person app ON app.app_sc = pc.pc_sc AND app.app_ap = ap.ap_id AND app.history_status = 'A'
                   --JOIN uss_person.v_sc_document sd on (pc.pc_sc=sd.scd_sc and (sd.scd_ndt=5 or sd.scd_ndt=6 ))
                   JOIN v_appeal ap_res ON (ap_res.ap_id = t.pd_ap_reason)
             WHERE     1 = 1
                   AND ap.ap_tp = 'SS'
                   AND (   (    l_org_to > 31
                            AND ap.com_org = l_org_id
                            AND t.pd_st IN ('AV',
                                            'P',
                                            'PV',
                                            'R0',
                                            'R1',
                                            'V',
                                            'W',
                                            'WD',
                                            'S'))
                        OR (    l_org_to = 31
                            AND t.pd_st IN ('O.AV',
                                            'O.P',
                                            'O.PV',
                                            'O.R0',
                                            'O.R2',
                                            'O.S',
                                            'O.V',
                                            'O.WD')
                            AND ap.com_org IN
                                    (    SELECT t.org_id
                                           FROM v_opfu t
                                          WHERE t.org_st = 'A'
                                     CONNECT BY PRIOR t.org_id = t.org_org
                                     START WITH t.org_id = l_org_id)))
                   AND (p_PD_ST IS NULL OR t.pd_st = P_PD_ST)
                   AND (       p_ap_id IS NOT NULL
                           AND (t.pd_ap = p_ap_id OR t.pd_ap_reason = p_ap_id)
                        OR     p_ap_id IS NULL
                           AND (   P_PA_NUM IS NULL
                                OR pa.pa_num LIKE P_PA_NUM || '%')
                           AND (   P_PC_NUM IS NULL
                                OR pc.pc_num LIKE P_PC_NUM || '%')
                           AND (P_PD_NST IS NULL OR t.pd_nst = P_PD_NST))
                   AND (   P_IS_ONLY_RETURN = 'F'
                        OR     P_IS_ONLY_RETURN = 'T'
                           AND t.pd_hs_return IS NOT NULL)
                   AND (       P_AP_REG_DT_START IS NULL
                           AND P_AP_REG_DT_STOP IS NULL
                        OR     P_AP_REG_DT_START IS NULL
                           AND P_AP_REG_DT_STOP IS NOT NULL
                           AND ap_res.ap_reg_dt <= P_AP_REG_DT_STOP
                        OR     P_AP_REG_DT_START IS NOT NULL
                           AND P_AP_REG_DT_STOP IS NULL
                           AND ap_res.ap_reg_dt >= P_AP_REG_DT_START
                        OR ap_res.ap_reg_dt BETWEEN P_AP_REG_DT_START
                                                AND P_AP_REG_DT_STOP)
                   AND (   P_PD_DT_START IS NULL AND P_PD_DT_STOP IS NULL
                        OR     P_PD_DT_START IS NULL
                           AND P_PD_DT_STOP IS NOT NULL
                           AND ap_res.ap_reg_dt <= P_PD_DT_STOP
                        OR     P_PD_DT_START IS NOT NULL
                           AND P_PD_DT_STOP IS NULL
                           AND ap_res.ap_reg_dt >= P_PD_DT_START
                        OR ap_res.ap_reg_dt BETWEEN P_PD_DT_START
                                                AND P_PD_DT_STOP)
                   AND (   P_Ap_Num IS NULL
                        OR ap.ap_num LIKE p_ap_num || '%'
                        OR ap_res.ap_num LIKE p_ap_num || '%')
                   AND (P_Pd_Pay_Tp IS NULL OR pm.pdm_pay_tp = P_Pd_Pay_Tp)
                   AND (       P_APP_LN IS NULL
                           AND P_App_Fn IS NULL
                           AND P_App_Mn IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM v_ap_person  zz
                                       JOIN uss_person.v_socialcard zs
                                           ON (zs.sc_id = zz.app_sc)
                                       JOIN uss_person.v_sc_change zch
                                           ON (zch.scc_id = zs.sc_scc)
                                       JOIN uss_person.v_sc_identity zi
                                           ON (zi.sci_id = zch.scc_sci)
                                 WHERE     zz.app_ap = ap.ap_id
                                       AND zz.app_tp =
                                           CASE
                                               WHEN ap.ap_tp IN ('U', 'A')
                                               THEN
                                                   'O'
                                               ELSE
                                                   'Z'
                                           END
                                       AND (   p_app_ln IS NULL
                                            OR UPPER (zi.sci_ln) LIKE
                                                      UPPER (TRIM (p_app_ln))
                                                   || '%')
                                       AND (   p_app_fn IS NULL
                                            OR UPPER (zi.sci_fn) LIKE
                                                      UPPER (TRIM (p_app_fn))
                                                   || '%')
                                       AND (   p_app_mn IS NULL
                                            OR UPPER (zi.sci_mn) LIKE
                                                      UPPER (TRIM (p_app_mn))
                                                   || '%')))
                   AND (   P_SCD_SER_NUM IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM v_ap_person  zz
                                       JOIN uss_person.v_socialcard zs
                                           ON (zs.sc_id = zz.app_sc)
                                       JOIN uss_person.v_sc_document sd
                                           ON (       pc.pc_sc = sd.scd_sc
                                                  AND sd.scd_ndt = 6
                                               OR sd.scd_ndt = 7)
                                 WHERE     zz.app_ap = ap.ap_id
                                       AND (sd.scd_seria || sd.scd_number =
                                            REPLACE (P_SCD_SER_NUM, ' ', ''))))
                   AND (   p_numident IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM v_ap_person  zz
                                       JOIN uss_person.v_socialcard zs
                                           ON (zs.sc_id = zz.app_sc)
                                       JOIN uss_person.v_sc_document sd
                                           ON (    pc.pc_sc = sd.scd_sc
                                               AND (sd.scd_ndt = 5))
                                 WHERE     zz.app_ap = ap.ap_id
                                       AND sd.scd_number = p_numident));
    END;

    -- #70334: дані форми визначення права
    PROCEDURE GET_DECISION_RIGHTS (P_PD_ID   IN     NUMBER,
                                   RES_CUR      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
              SELECT t.*,
                     r.nrr_name             AS prl_nrr_name,
                     NVL (r.nrr_tp, 'E')    AS nrr_tp,
                     CASE
                         WHEN r.nrr_is_critical_error = 'T' THEN 'F'
                         ELSE 'T'
                     END                    AS Can_Set_Result
                FROM pd_right_log t
                     JOIN uss_ndi.v_ndi_right_rule r ON (r.nrr_id = t.prl_nrr)
               WHERE t.prl_pd = p_pd_id
            ORDER BY t.prl_id;
    END;

    -- ініціалізація визначення права
    PROCEDURE INIT_DECISION_RIGHTS (p_pd_id          pc_decision.pd_id%TYPE,
                                    p_messages   OUT SYS_REFCURSOR)
    IS
    BEGIN
        check_consistensy (P_PD_ID, 'R0');
        API$CALC_RIGHT.init_right_for_decision (1, p_pd_id, p_messages);
    END;

    -- #70334: збереження форми визначення права
    PROCEDURE SAVE_DECISION_RIGHTS (P_PD_ID   IN NUMBER,
                                    P_PD_ST   IN VARCHAR2,
                                    P_CLOB    IN CLOB)
    IS
        l_arr   t_pd_right_log;
        l_hs    NUMBER := tools.GetHistSession;
        l_st    VARCHAR2 (10);
    BEGIN
        check_consistensy (P_PD_ID, P_PD_ST);

        EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                         't_pd_right_log',
                                         TRUE,
                                         TRUE)
            BULK COLLECT INTO l_arr
            USING P_CLOB;

        IF (l_arr.COUNT = 0)
        THEN
            RETURN;
        END IF;

        FORALL i IN INDICES OF l_arr
            UPDATE pd_right_log t
               SET t.prl_result = l_arr (i).Prl_Result,
                   t.prl_hs_rewrite =
                       CASE
                           WHEN (t.prl_result != l_arr (i).Prl_Result)
                           THEN
                               l_hs
                           ELSE
                               t.prl_hs_rewrite
                       END
             WHERE t.prl_id = l_arr (i).prl_id;

        UPDATE pc_decision t
           SET t.pd_has_right = 'T',
               t.com_wu = COALESCE (t.com_wu, tools.GetCurrWu)
         WHERE t.pd_id = P_PD_ID;

        API$CALC_RIGHT.Recalc_ALG66 (p_pd_id);

        SELECT t.pd_st
          INTO l_st
          FROM pc_decision t
         WHERE t.pd_Id = p_pd_id;

        API$PC_DECISION.write_pd_log (p_pd_Id,
                                      l_hs,
                                      l_st,
                                      CHR (38) || '15',
                                      l_st);
    END;

    -- #81045
    PROCEDURE pd_transfer (p_pd_id        IN     NUMBER,
                           p_pd_st        IN     VARCHAR2,
                           p_msg             OUT VARCHAR2,
                           p_pd_st_next      OUT VARCHAR2)
    IS
        l_pca_id   NUMBER;
    BEGIN
        check_consistensy (P_PD_ID, P_PD_ST);
        l_pca_id := api$pc_attestat.Registr_Transmission (p_pd_id, p_msg);

        IF (l_pca_id IS NULL)
        THEN
            p_pd_st_next := 'R0';
        --      raise_application_error(-20000, 'Запит на передачу не зареєстровано. Зверніться до розробника!');
        ELSE
            p_pd_st_next := 'TR';
        END IF;
    /*SELECT MAX('Запит створено, № ' || t.pca_doc_num || ' від ' || to_char(t.pca_doc_dt, 'DD.MM.YYYY'))
      INTO p_msg
      FROM pc_attestat t
     WHERE t.pca_id = l_pca_id;*/
    END;

    -- #70334: дані форми "Рішення про відмову"
    PROCEDURE GET_DECISION_REJECTS (P_PD_ID   IN     NUMBER,
                                    RES_CUR      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT t.*
              FROM pd_reject_info t
             WHERE t.pri_pd = p_pd_id
            UNION
            SELECT NULL        AS pri_id,
                   prl_nrr     AS pri_nrr,
                   NULL        AS pri_nrj,
                   prl_pd      AS pri_pd
              FROM pd_right_log t
             WHERE     t.prl_pd = p_pd_Id
                   AND t.prl_result = 'F'
                   AND NOT EXISTS
                           (SELECT *
                              FROM pd_reject_info z
                             WHERE     z.pri_nrr = t.prl_nrr
                                   AND z.pri_pd = t.prl_pd);
    END;


    -- #70334: збереження форми "Рішення про відмову"
    PROCEDURE SAVE_DECISION_REJECTS (P_PD_ID     IN     NUMBER,
                                     P_CLOB      IN     CLOB,
                                     P_ST           OUT VARCHAR2,
                                     P_ST_NAME      OUT VARCHAR2)
    IS
        l_arr          t_pd_reject_info;
        l_hs           NUMBER := tools.GetHistSession;
        l_st           VARCHAR2 (10);
        l_action_sql   VARCHAR2 (2000);
        l_cnt          INTEGER;
        l_pd           v_pc_decision%ROWTYPE;
    BEGIN
        EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                         't_pd_reject_info',
                                         TRUE,
                                         TRUE)
            BULK COLLECT INTO l_arr
            USING P_CLOB;

        IF (l_arr.COUNT = 0)
        THEN
            raise_application_error (-20000,
                                     'Не можна відхиляти без причин!');
        END IF;

        g_pd_id := P_PD_ID;

        SELECT *
          INTO l_pd
          FROM v_pc_decision
         WHERE pd_id = g_pd_id;

        FORALL i IN INDICES OF l_arr
            UPDATE pd_reject_info t
               SET t.pri_nrr = l_arr (i).pri_nrr,
                   t.pri_njr = l_arr (i).pri_njr
             WHERE t.pri_id = l_arr (i).pri_id;

        FOR xx
            IN (SELECT t.pri_id, tt.pri_id AS x_pri_id
                  FROM pd_reject_info  t
                       LEFT JOIN TABLE (l_arr) tt ON tt.pri_id = t.pri_id
                 WHERE t.pri_pd = p_pd_id AND tt.pri_id IS NULL)
        LOOP
            DELETE FROM pd_reject_info t
                  WHERE t.pri_id = xx.pri_id;
        END LOOP;

        /*
            DELETE FROM pd_reject_info t
            WHERE t.pri_pd = p_pd_id
                  AND NOT exists (SELECT 1 FROM TABLE(l_arr) tt WHERE tt.pri_id = t.pri_id);
          */

        /*INSERT INTO pd_reject_info t
        (pri_nrr, pri_njr, pri_pd)
        SELECT t.pri_nrr,
               t.pri_njr,
               p_pd_id
          FROM TABLE(l_arr) t
         WHERE t.pri_id IS NULL;*/

        FOR xx IN (SELECT *
                     FROM TABLE (l_arr)
                    WHERE pri_id IS NULL)
        LOOP
            INSERT INTO pd_reject_info t (pri_nrr, pri_njr, pri_pd)
                 VALUES (xx.pri_nrr, xx.pri_njr, p_pd_id);
        END LOOP;


        /*
        SELECT t.*, st.DIC_SNAME
          INTO l_st, p_st, p_st_name
          FROM (SELECT t.pd_st,
                       CASE WHEN t.pd_st = 'R0' THEN 'PV'
                            WHEN t.pd_st = 'PV' THEN 'AV'
                            WHEN t.pd_st = 'AV' THEN 'V'
                       END AS st_next
                  FROM pc_decision t
                 WHERE t.pd_Id = p_pd_id) t
          JOIN uss_ndi.v_ddn_pd_st st ON (st.DIC_VALUE = st_next);
    */
        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
             VALUES (P_PD_ID);

        --  Функція формування історіі персон та документів звернення
        --  на підставі звернень у tmp_work_ids
        API$ACCOUNT.init_tmp_for_pd;

        SELECT t.pd_st,
               npsc.npsc_to_st,
               dic_name,
               npsc.npsc_action_sql
          INTO l_st,
               p_st,
               p_st_name,
               l_action_sql
          FROM pc_decision  t
               JOIN appeal ON pd_ap = ap_id
               JOIN uss_ndi.v_ddn_pd_st ON pd_st = dic_value
               LEFT JOIN uss_ndi.v_ndi_pd_st_config npsc
                   ON     npsc.npsc_ap_tp =
                          CASE ap_tp WHEN 'SS' THEN 'SS_OLD' ELSE ap_tp END
                      AND npsc.npsc_tp = 'UP_REJECT'
                      AND npsc.npsc_from_st = t.pd_st
                      AND npsc.history_status = 'A'
                      AND Dnet$pay_Assignments.Check_pd_st_config (
                              npsc.npsc_check_sql) =
                          1
         WHERE t.pd_id = P_PD_ID;

        IF (p_st IS NULL)
        THEN
            raise_application_error (
                -20000,
                'Відхилення при поточному статусі неможливе!');
        END IF;

        /*
       SELECT t.pd_st
         INTO l_st
         FROM pc_decision t
        WHERE t.pd_Id = p_pd_id;
        */
        UPDATE pc_decision t
           SET t.pd_hs_reject = l_hs,
               t.pd_st = P_ST,
               t.com_wu = COALESCE (t.com_wu, tools.GetCurrWu)
         WHERE t.pd_id = P_PD_ID;

        g_pd_id := P_PD_ID;

        --g_message := NULL;
        SELECT MAX (apda_val_string)
          INTO g_message
          FROM pc_decision  t
               JOIN ap_document
                   ON     apd_ap = t.pd_ap_reason
                      AND apd_ndt = 10051
                      AND ap_document.history_status = 'A'
               JOIN ap_document_attr
                   ON     apd_id = apda_apd
                      AND apda_nda = 1753
                      AND ap_document_attr.history_status = 'A'
         WHERE t.pd_id = P_PD_ID;

        -- #84924  2023.03.06
        UPDATE pd_accrual_period ac
           SET ac.history_status = 'H', ac.pdap_hs_del = l_hs
         WHERE ac.pdap_pd = P_PD_ID AND ac.history_status = 'A';

        -- #89850 2023.08.21 Інформування про зміну стану рішення по виплаті ВПО
        IF ikis_sys.IKIS_PARAMETER_UTIL.GetParameter1 ('NOTIFY_VPO_ENABLED',
                                                       'IKIS_SYS') =
           'TRUE'
        THEN
            uss_esr.API$AP_SEND_MESSAGE.Notify_VPO_on_Change_Decision (
                p_pd_id   => P_PD_ID,
                p_pd_st   => P_ST);
        END IF;

        IF p_st = 'V' AND l_pd.pd_src = 'SA'
        THEN
            SELECT COUNT (*)
              INTO l_cnt
              FROM pc_state_alimony
             WHERE ps_ap = l_pd.pd_ap_reason;

            IF l_cnt > 0
            THEN
                api$pc_state_alimony.clean_ps_by_ap_reject_pd (
                    l_pd.pd_ap_reason);
            END IF;
        END IF;


        IF g_message IS NULL
        THEN
            API$PC_DECISION.write_pd_log (p_pd_Id,
                                          l_hs,
                                          P_ST,
                                          CHR (38) || '16',
                                          l_st);
        ELSE
            API$PC_DECISION.write_pd_log (p_pd_Id,
                                          l_hs,
                                          P_ST,
                                          CHR (38) || '166#' || g_message,
                                          l_st);
        END IF;

        IF P_ST = 'V' AND g_message IS NULL
        THEN
            API$ESR_Action.PrepareWrite_Visit_ap_log (p_pd_Id,
                                                      CHR (38) || '16',
                                                      NULL,
                                                      tools.GetCurrWu ());
        ELSIF P_ST = 'V' AND g_message IS NOT NULL
        THEN
            API$ESR_Action.PrepareWrite_Visit_ap_log (
                p_pd_Id,
                CHR (38) || '166#' || g_message,
                NULL,
                tools.GetCurrWu ());
        END IF;

        IF l_action_sql IS NOT NULL
        THEN
            EXECUTE IMMEDIATE l_action_sql;
        END IF;
    END;

    -- #71916: Повернути рішення про відмову
    PROCEDURE REJECT_DECISION_REJECT (P_PD_ID     IN     NUMBER,
                                      P_ST           OUT VARCHAR2,
                                      P_ST_NAME      OUT VARCHAR2)
    IS
        l_hs       NUMBER := tools.GetHistSession;
        l_st       VARCHAR2 (10);
        l_st_new   VARCHAR2 (10);
    BEGIN
        /*
            SELECT t.*, st.DIC_SNAME
              INTO l_st, p_st, p_st_name
              FROM (SELECT t.pd_st,
                           CASE WHEN t.pd_st = 'PV' THEN 'R0'
                                WHEN t.pd_st = 'AV' THEN 'PV'
                           END AS st_next
                      FROM pc_decision t
                     WHERE t.pd_Id = p_pd_id) t
              JOIN uss_ndi.v_ddn_pd_st st ON (st.DIC_VALUE = st_next);
        */
        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
             VALUES (P_PD_ID);

        --  Функція формування історіі персон та документів звернення
        --  на підставі звернень у tmp_work_ids
        API$ACCOUNT.init_tmp_for_pd;

        SELECT t.pd_st, npsc.npsc_to_st, dic_name
          INTO l_st, p_st, p_st_name
          FROM pc_decision  t
               JOIN appeal ON pd_ap = ap_id
               JOIN uss_ndi.v_ddn_pd_st ON pd_st = dic_value
               LEFT JOIN uss_ndi.v_ndi_pd_st_config npsc
                   ON     npsc.npsc_ap_tp =
                          CASE ap_tp WHEN 'SS' THEN 'SS_OLD' ELSE ap_tp END
                      AND npsc.npsc_tp = 'DOWN'
                      AND npsc.npsc_from_st = t.pd_st
                      AND npsc.history_status = 'A'
                      AND Dnet$pay_Assignments.Check_pd_st_config (
                              npsc.npsc_check_sql) =
                          1
         WHERE t.pd_id = P_PD_ID;

        IF (p_st IS NULL)
        THEN
            raise_application_error (
                -20000,
                'Повернення при поточному статусі неможливе!');
        END IF;

        UPDATE pc_decision t
           SET t.pd_hs_reject = l_hs, t.pd_st = P_ST
         WHERE t.pd_id = P_PD_ID;


        API$PC_DECISION.write_pd_log (p_pd_Id,
                                      l_hs,
                                      P_ST,
                                      CHR (38) || '16',
                                      l_st);
    END;

    -- #70334/#70351: вичитка форми "Розрахунок виплати / Виплата"
    PROCEDURE GET_DECISION_PAYMENTS (P_PD_ID      IN     NUMBER,
                                     PAY_CUR         OUT SYS_REFCURSOR,
                                     DET_CUR         OUT SYS_REFCURSOR,
                                     FEAT_CUR        OUT SYS_REFCURSOR,
                                     PERS_CUR        OUT SYS_REFCURSOR,
                                     PARAMS_CUR      OUT SYS_REFCURSOR,
                                     DFEAT_CUR       OUT SYS_REFCURSOR,
                                     BLOCK_CUR       OUT SYS_REFCURSOR,
                                     PERIOD_CUR      OUT SYS_REFCURSOR,
                                     DO_CUR          OUT SYS_REFCURSOR,
                                     CHECK_CUR       OUT SYS_REFCURSOR)
    IS
        l_pc   personalcase.pc_id%TYPE;
    BEGIN
        SELECT pd_pc
          INTO l_pc
          FROM pc_decision
         WHERE pd_id = P_PD_ID;

        OPEN pay_cur FOR
              SELECT t.*,
                     pt.npt_code || ' ' || pt.npt_name    AS pdp_npt_name,
                     (CASE
                          WHEN EXISTS
                                   (SELECT a.apda_id
                                      FROM ap_document_attr a
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
                      END)                                AS is_Emergency,
                     (SELECT MAX (zt.DIC_NAME)
                        FROM recalculates z
                             JOIN uss_ndi.v_ddn_rc_tp zt
                                 ON (zt.DIC_VALUE = z.rc_tp)
                       WHERE z.rc_id = t.pdp_rc)          AS rc_tp_name
                FROM pd_payment t
                     JOIN v_pc_decision pd ON (pd.pd_id = t.pdp_pd)
                     JOIN appeal ap ON (ap.ap_id = pd.pd_ap)
                     JOIN uss_ndi.v_ndi_payment_type pt
                         ON (pt.npt_id = t.pdp_npt)
               WHERE t.pdp_pd = p_pd_id AND t.history_status = 'A'
            ORDER BY t.pdp_start_dt ASC;

        OPEN PARAMS_CUR FOR
            SELECT pm.*,
                   k.kaot_name                         AS pdm_kaot_name,
                   d.nd_code || ' ' || d.nd_comment    AS pdm_nd_name,
                      (CASE
                           WHEN nsrt_name IS NOT NULL THEN nsrt_name || ' '
                           ELSE ''
                       END)
                   || s.ns_name                        AS pdm_ns_name --,--#74860  2022.01.24
              --d.ND_COMMENT AS pd_nd_name
              FROM pc_decision  t
                   JOIN Pd_Pay_Method pm
                       ON     pm.pdm_pd = t.pd_id
                          AND pm.pdm_is_actual = 'T'
                          AND pm.history_status = 'A'
                   LEFT JOIN uss_ndi.v_ndi_katottg k
                       ON (k.kaot_id = pm.pdm_kaot)
                   LEFT JOIN uss_ndi.v_ndi_street s ON (s.ns_id = pm.pdm_ns)
                   LEFT JOIN uss_ndi.V_NDI_STREET_TYPE ON s.ns_nsrt = nsrt_id
                   LEFT JOIN uss_ndi.v_ndi_delivery d
                       ON (d.ND_ID = pm.pdm_nd)
             WHERE t.pd_id = p_pd_id;

        OPEN det_cur FOR
            SELECT t.*, rt.ndp_name AS pdd_ndp_name, rc.rc_tp
              FROM v_pd_detail  t
                   JOIN uss_ndi.v_ndi_pd_row_type rt
                       ON (rt.ndp_id = t.pdd_ndp)
                   JOIN pd_payment z
                       ON (z.pdp_id = t.pdd_pdp AND z.history_status = 'A')
                   LEFT JOIN recalculates rc ON (rc.rc_id = z.pdp_rc)
             WHERE z.pdp_pd = p_pd_id;

        -- пока что хардкод, по нормальному через настройку в справочнике настроек
        OPEN feat_cur FOR
            SELECT t.*,
                   pf.pdf_sc                                      AS Pde_Pdf_Sc,
                   uss_person.api$sc_tools.GET_PIB (pf.pdf_sc)    AS Pde_Pdf_Pib
              FROM pd_features  t
                   JOIN uss_ndi.v_ndi_pd_feature_type ft
                       ON (ft.nft_id = t.pde_nft)
                   LEFT JOIN pd_family pf ON t.pde_pdf = pf.pdf_id
             WHERE t.pde_pd = p_pd_id AND ft.nft_view = 'STATIC';

        OPEN dfeat_cur FOR
            SELECT t.*,
                   pf.pdf_sc                                      AS Pde_Pdf_Sc,
                   uss_person.api$sc_tools.GET_PIB (pf.pdf_sc)    AS Pde_Pdf_Pib
              FROM pd_features  t
                   JOIN uss_ndi.v_ndi_pd_feature_type ft
                       ON (ft.nft_id = t.pde_nft)
                   LEFT JOIN pd_family pf ON t.pde_pdf = pf.pdf_id
             WHERE t.pde_pd = p_pd_id AND ft.nft_view = 'SS';

        OPEN pers_cur FOR
            SELECT t.*,
                   uss_person.api$sc_tools.GET_PIB (t.pdf_sc)
                       AS sc_pib,
                   pdf_birth_dt /*uss_person.api$sc_tools.GET_BIRTHDATE(t.pdf_sc)*/
                       AS sc_birthdate,
                   (SELECT MAX (z.sc_unique)
                      FROM uss_person.v_socialcard z
                     WHERE z.sc_id = t.pdf_sc)
                       AS sc_unique,
                   -- #109075
                    (SELECT MAX (za.apda_val_dt)
                       FROM pc_decision  zpd
                            JOIN ap_person zp ON (zp.app_ap = zpd.pd_ap)
                            JOIN ap_document zd
                                ON (    zd.apd_ap = zpd.pd_ap
                                    AND zp.app_id = zd.apd_app)
                            JOIN ap_document_attr za
                                ON (za.apda_apd = zd.apd_id)
                      WHERE     zpd.pd_id = t.pdf_pd
                            AND zp.app_sc = t.pdf_sc
                            AND za.apda_nda IN (2666, 2667))
                       AS placement_dt
              FROM pd_family t
             WHERE t.pdf_pd = p_pd_id AND t.history_status = 'A';


        OPEN BLOCK_CUR FOR
            SELECT t.*,
                   tp.dic_name                        AS pcb_tp_name,
                   bh.hs_dt                           AS pcb_hs_lock_dt,
                   rnp.rnp_name                       AS pcb_rnp_name,
                   cd.DIC_NAME                        AS pcb_exch_code_name,
                   ltp.DIC_NAME                       AS pcb_lock_pnp_tp_name,
                   ultp.DIC_NAME                      AS pcb_unlock_pnp_tp_name,
                   runp.rup_name                      AS pcb_rup_name,
                   ubh.hs_dt                          AS pcb_hs_unlock_dt,
                   tools.GetUserLogin (ubh.hs_wu)     AS pcb_hs_unlock_user
              FROM pc_block  t
                   JOIN histsession bh ON (bh.hs_id = t.pcb_hs_lock)
                   JOIN uss_ndi.v_ndi_reason_not_pay rnp
                       ON (rnp.rnp_id = t.pcb_rnp)
                   LEFT JOIN uss_ndi.v_ddn_pcb_tp tp
                       ON (tp.dic_value = t.pcb_tp)
                   LEFT JOIN uss_ndi.v_ddn_pr_exch_code cd
                       ON (cd.dic_value = t.pcb_exch_code)
                   LEFT JOIN uss_ndi.v_ddn_pnp_tp ltp
                       ON (ltp.dic_value = t.pcb_lock_pnp_tp)
                   LEFT JOIN uss_ndi.v_ddn_pnp_tp ultp
                       ON (ultp.dic_value = t.pcb_unlock_pnp_tp)
                   LEFT JOIN uss_ndi.v_ndi_reason_unlock_pay runp
                       ON (runp.rup_id = t.pcb_rup)
                   LEFT JOIN histsession ubh ON (ubh.hs_id = t.pcb_hs_unlock)
             WHERE t.pcb_pd = p_pd_id;

        OPEN PERIOD_CUR FOR
              SELECT t.*,
                     d.pd_num,
                     a.ap_num,
                     st.DIC_NAME     AS history_status_name
                FROM pd_accrual_period t
                     LEFT JOIN pc_decision d ON (d.pd_id = t.pdap_change_pd)
                     LEFT JOIN appeal a ON (a.ap_id = t.pdap_change_ap)
                     LEFT JOIN uss_ndi.v_ddn_hist_status st
                         ON (st.DIC_VALUE = t.history_status)
               WHERE t.pdap_pd = P_PD_ID
            ORDER BY DECODE (t.history_status, 'A', 1, 2), t.pdap_start_dt;

        OPEN DO_CUR FOR
            SELECT t.*,
                   (SELECT MAX (z.npt_code || ' ' || z.npt_name)
                      FROM uss_ndi.v_ndi_payment_type z
                     WHERE z.npt_id = t.pco_npt)               AS pco_npt_name,
                   (SELECT MAX (z.DIC_NAME)
                      FROM uss_ndi.v_ddn_pco_tp z
                     WHERE z.DIC_VALUE = t.pco_tp)             AS pco_tp_name,
                   (SELECT MAX (z.DIC_NAME)
                      FROM uss_ndi.V_DDN_PCO_ST z
                     WHERE z.DIC_VALUE = t.pco_st)             AS pco_st_name,
                   (SELECT MAX (z.DIC_NAME)
                      FROM uss_ndi.V_DDN_PCO_DECISION_TP z
                     WHERE z.DIC_VALUE = t.pco_decision_tp)    AS pco_decision_tp_name
              FROM pc_data_ordering t
             WHERE (t.pco_pd = p_pd_id OR (pco_tp = 'DUPD' AND pco_pc = l_pc));

        OPEN CHECK_CUR FOR SELECT CASE
                                      WHEN (SELECT COUNT (*)
                                              FROM pc_decision  z
                                                   JOIN pd_features f1
                                                       ON (    f1.pde_pd =
                                                               z.pd_id
                                                           AND f1.pde_nft =
                                                               32)
                                                   JOIN pd_features f2
                                                       ON (    f2.pde_pd =
                                                               z.pd_id
                                                           AND f2.pde_nft =
                                                               33)
                                             WHERE     z.pd_id = P_PD_ID
                                                   AND (       z.pd_st = 'R0'
                                                           AND f1.pde_val_string =
                                                               'T'
                                                           AND f2.pde_val_string =
                                                               'F'
                                                        OR     z.pd_st =
                                                               'O.R0'
                                                           AND f1.pde_val_string =
                                                               'T'
                                                           AND f2.pde_val_string =
                                                               'T')) >
                                           0
                                      THEN
                                          'T'
                                      ELSE
                                          'F'
                                  END    AS Can_Features_Edit
                             FROM DUAL;
    END;

    -- #70334/#70351: ініціалізація форми "Розрахунок виплати / Виплата"
    PROCEDURE INIT_DECISION_PAYMENTS (P_PD_ID   IN     NUMBER,
                                      P_PD_ST   IN     VARCHAR2,
                                      PAY_CUR      OUT SYS_REFCURSOR)
    IS
        l_flag   NUMBER;
    BEGIN
        --raise_application_error(-20000, 'test');
        check_consistensy (P_PD_ID, P_PD_ST);

        /*SELECT COUNT(*)
          INTO l_flag
          FROM pd_pay_method t
         WHERE t.pdm_pd = P_PD_ID
           AND t.pdm_is_actual = 'T'
           AND t.history_status = 'A'
           AND t.pdm_pay_dt IS NOT NULL;

        -- #93648
        IF (l_flag = 0) THEN
          raise_application_error(-20000, 'Для розрахунку потрібно заповнити поле "День виплати"!');
        END IF;*/

        UPDATE pc_decision t
           SET t.com_wu = COALESCE (t.com_wu, tools.GetCurrWu)
         WHERE t.pd_id = P_PD_ID;


        api$calc_pd.calc_pd (1, p_pd_id, pay_cur);
    END;


    -- налаштування ознак виплат
    PROCEDURE GET_DECISION_FEATURES_METADATA (RES_CUR OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT t.*, pt.*, dc.ndc_code
              FROM uss_ndi.v_ndi_pd_feature_type  t
                   JOIN uss_ndi.v_ndi_param_type pt ON (pt.pt_id = t.nft_pt)
                   LEFT JOIN uss_ndi.v_ndi_dict_config dc
                       ON (dc.ndc_id = pt.pt_ndc);
    END;

    PROCEDURE APPROVE_DECISION_PAYMENTS (P_PD_ID   IN NUMBER,
                                         P_PD_ST   IN VARCHAR2)
    IS
        l_cnt   NUMBER;
    BEGIN
        check_consistensy (P_PD_ID, P_PD_ST);

        SELECT COUNT (*)
          INTO l_cnt
          FROM pd_pay_method t
         WHERE     t.pdm_pd = P_PD_ID
               AND t.history_status = 'A'
               AND t.pdm_is_actual = 'T'
               AND t.pdm_pay_tp NOT IN ('BANK', 'POST');

        -- #104105
        IF (l_cnt > 0)
        THEN
            raise_application_error (
                -20000,
                'Тип виплати не "Банк" і не "Пошта", перевірте правильність вибору типу у зверненні');
        END IF;


        APPROVE_DECISION_PAYMENTS (p_pd_id);
    END;

    -- #70334/#70351: затвердити виплати
    PROCEDURE APPROVE_DECISION_PAYMENTS (P_PD_ID IN NUMBER)
    IS
        l_hs           NUMBER := tools.GetHistSession;
        l_st           VARCHAR2 (10);
        l_st_new       VARCHAR2 (10);
        l_ap           appeal.ap_id%TYPE;
        l_ap_tp        appeal.ap_tp%TYPE;
        l_pa           pc_decision.pd_pa%TYPE;
        l_nst          pc_decision.pd_nst%TYPE;
        l_ap_reason    pc_decision.pd_ap_reason%TYPE;
        l_day          pd_pay_method.pdm_pay_dt%TYPE;
        l_pay          pd_payment.pdp_sum%TYPE;
        l_action_sql   VARCHAR2 (2000);
        l_err_str      VARCHAR2 (2000);

        -------------------------------
        PROCEDURE Check_pd_payment (P_PD_ID IN NUMBER)
        IS
            l_sum   NUMBER;
        BEGIN
            SELECT SUM (p.pdp_sum)
              INTO l_sum
              FROM pd_payment p
             WHERE p.pdp_pd = P_PD_ID AND p.history_status = 'A';

            IF NVL (l_sum, 0) = 0
            THEN
                raise_application_error (
                    -20000,
                    'Дану операцію неможливо завершити. Рішення не розраховано.');
            END IF;
        END;
    -------------------------------
    BEGIN
        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
             VALUES (P_PD_ID);

        g_pd_id := P_PD_ID;
        g_message := NULL;
        --  Функція формування історіі персон та документів звернення
        --  на підставі звернень у tmp_work_ids
        API$ACCOUNT.init_tmp_for_pd;

        SELECT ap_id,
               ap_tp,
               t.pd_st,
               pdm_pay_dt,
               pd_nst,
               pd_ap_reason,
               npsc.npsc_to_st,
               pd_pa,
               npsc.npsc_action_sql
          INTO l_ap,
               l_ap_tp,
               l_st,
               l_day,
               l_nst,
               l_ap_reason,
               l_st_new,
               l_pa,
               l_action_sql
          FROM pc_decision  t
               JOIN Pd_Pay_Method pm
                   ON     pm.pdm_pd = t.pd_id
                      AND pm.pdm_is_actual = 'T'
                      AND pm.history_status = 'A'
               JOIN appeal ON pd_ap = ap_id
               LEFT JOIN uss_ndi.v_ndi_pd_st_config npsc
                   ON     npsc.npsc_ap_tp =
                          CASE ap_tp WHEN 'SS' THEN 'SS_OLD' ELSE ap_tp END
                      AND npsc.npsc_tp = 'UP'
                      AND npsc.npsc_from_st = t.pd_st
                      AND npsc.history_status = 'A'
                      AND Dnet$pay_Assignments.Check_pd_st_config (
                              npsc.npsc_check_sql) =
                          1
         WHERE t.pd_id = P_PD_ID;


        IF l_st_new IS NULL
        THEN
            raise_application_error (
                -20000,
                'Виплату неможливо підтвердити. Статус виплати не задовільняє умовам!');
        END IF;

        -- Не чіпати без консультаціїї з Т.Дзеря
        IF l_ap_tp IN ('V', 'VV') AND l_st = 'R0'
        THEN
            l_err_str := API$CALC_RIGHT.Validate_pdm_pay (P_PD_ID);

            IF l_err_str IS NOT NULL
            THEN
                raise_application_error (-20000, l_err_str);
            END IF;
        END IF;


        IF l_ap_tp IN ('V', 'VV') AND l_st IN ('R0')
        THEN
            SELECT NVL (SUM (pdp_sum), 0)
              INTO l_pay
              FROM pd_payment pz
             WHERE pdp_pd = P_PD_ID AND pz.history_status = 'A';

            IF l_pay = 0
            THEN
                raise_application_error (-20000,
                                         'Суму допомоги не призначено!');
            END IF;
        END IF;

        IF     l_ap_tp IN ('V', 'VV')
           AND l_st_new IN ('K', 'S')
           AND l_day IS NULL
        THEN
            raise_application_error (
                -20000,
                'Не вказано день виплати в параметрах виплати!');
        END IF;

        IF l_ap_tp IN ('V', 'VV') AND l_st_new IN ('K')
        THEN
            api$pc_decision.Chec_pdm_nd (P_PD_ID);
        END IF;

        -- Не чіпати без консультаціїї з Т.Дзеря
        --IF l_ap_tp = 'V' AND l_st_new IN ('K', 'S') AND NOT (l_day BETWEEN 1 AND 28) THEN
        IF     l_ap_tp IN ('V', 'VV')
           AND l_st_new IN ('K', 'S')
           AND NOT (l_day BETWEEN 4 AND 25)
        THEN                                                        -- #104238
            raise_application_error (
                -20000,
                'День виплати повинен бути між 1 та 25 числом!');
        END IF;

        -- Перевіряємо стан держутримання для допомоги інвалідам
        IF l_nst = 248 AND l_ap_reason IS NOT NULL
        THEN
            api$pc_state_alimony.Check_state_alimony_for_aprove (l_ap_reason,
                                                                 l_st);
        --блокуваня допомоги померлої особи
        ELSIF l_nst = 1061 AND l_st_new = 'S'
        THEN
            api$pc_decision.decision_block_dead (l_ap, l_hs);
        END IF;


        UPDATE pc_decision t
           SET t.pd_hs_app =
                   CASE WHEN t.pd_st = 'R0' THEN l_hs ELSE t.pd_hs_app END,
               t.pd_hs_mapp =
                   CASE WHEN t.pd_st = 'R1' THEN l_hs ELSE t.pd_hs_mapp END,
               --t.pd_hs_head = CASE WHEN t.pd_st = 'R2' THEN l_hs ELSE t.pd_hs_head END,
               t.pd_st = l_st_new,
               pd_hs_return = NULL
         WHERE t.pd_id = P_PD_ID;

        --Перерахунок реальних періодів дії рішень для кореткного врахування в нарухуваннях
        IF l_ap_tp IN ('V', 'VV') AND l_st_new = 'S'
        THEN
            Check_pd_payment (P_PD_ID);
            API$PC_DECISION.recalc_pd_periods_FS (P_PD_ID, l_hs);
        END IF;

        API$PC_DECISION.write_pd_log (p_pd_Id,
                                      l_hs,
                                      l_st_new,
                                      CHR (38) || '17',
                                      l_st);

        IF l_st_new = 'P'
        THEN
            Api$pc_Decision_Ext.Check_another_solution (p_pd_Id,
                                                        l_hs,
                                                        tools.GetCurrWu ());
        END IF;

        CASE
            --#74615 - прибираємо R2
            /*WHEN 'R2' THEN
              API$ESR_Action.PrepareWrite_Visit_ap_log(p_pd_Id, CHR(38)||'37', NULL, tools.GetCurrWu());*/
            WHEN l_st_new = 'S' AND l_st = 'K'
            THEN
                --Api$pc_Decision_Ext.Check_another_solution(p_pd_Id, l_hs, tools.GetCurrWu());
                API$ESR_Action.PrepareWrite_Visit_ap_log (p_pd_Id,
                                                          CHR (38) || '38',
                                                          NULL,
                                                          tools.GetCurrWu ());
                Api$pc_Decision.set_pa_stage_2 (l_pa, l_hs);
                Api$pc_Decision.Copy_Document2Socialcard (l_ap);
                Api$pc_Decision.Update_pdm_nd (p_pd_Id);
                Api$pc_Decision.Update_pin (p_pd_Id);                --#108496
            WHEN l_st_new = 'S' AND l_st = 'P'
            THEN
                --      Api$pc_Decision_Ext.Check_another_solution(p_pd_Id, l_hs, tools.GetCurrWu());
                API$ESR_Action.PrepareWrite_Visit_ap_log (p_pd_Id,
                                                          CHR (38) || '46',
                                                          NULL,
                                                          tools.GetCurrWu ());
                Api$pc_Decision.set_pa_stage_2 (l_pa, l_hs);
                Api$pc_Decision.Copy_Document2Socialcard (l_ap);
                Api$pc_Decision.Update_pdm_nd (p_pd_Id);
                Api$pc_Decision.Update_pin (p_pd_Id);                --#108496
            WHEN l_st_new = 'S' AND l_st = 'PS'
            THEN
                Api$pc_Decision.decision_Unblock (p_pd_Id, l_hs);
            /*
                WHEN l_st_new = 'P' AND l_st = 'WD' THEN
                  --Api$pc_Decision_Ext.Check_another_solution(p_pd_Id, l_hs, tools.GetCurrWu());
                  API$ESR_Action.PrepareWrite_Visit_ap_log(p_pd_Id, CHR(38)||'46', NULL, tools.GetCurrWu());
            */
            WHEN l_st_new = 'O.P' AND l_st = 'O.WD'
            THEN
                API$ESR_Action.PrepareWrite_Visit_ap_log (p_pd_Id,
                                                          CHR (38) || '46',
                                                          NULL,
                                                          tools.GetCurrWu ());
            ELSE
                NULL;
        END CASE;

        -- #89850 2023.08.21 Інформування про зміну стану рішення по виплаті ВПО
        IF ikis_sys.IKIS_PARAMETER_UTIL.GetParameter1 ('NOTIFY_VPO_ENABLED',
                                                       'IKIS_SYS') =
           'TRUE'
        THEN
            uss_esr.API$AP_SEND_MESSAGE.Notify_VPO_on_Change_Decision (
                p_pd_id   => P_PD_ID,
                p_pd_st   => l_st_new);
        END IF;

        IF l_action_sql IS NOT NULL
        THEN
            EXECUTE IMMEDIATE l_action_sql;
        END IF;
    END;

    -- #79819: поновити виплати
    PROCEDURE decision_UnBlock (
        p_pd         pc_decision.pd_id%TYPE,
        p_start_dt   pd_accrual_period.pdap_start_dt%TYPE,
        p_stop_dt    pd_accrual_period.pdap_stop_dt%TYPE,
        p_xml        CLOB)
    IS
        l_arr   t_decision_UnBlock;
    BEGIN
        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''. ''');

        --raise_application_error(-20000, 'test');
        IF (p_xml IS NOT NULL)
        THEN
            EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                             't_decision_UnBlock',
                                             TRUE,
                                             TRUE)
                BULK COLLECT INTO l_arr
                USING p_xml;

            FORALL i IN INDICES OF l_arr
                INSERT INTO tmp_work_set3 (x_id1,
                                           x_id2,
                                           x_sum1,
                                           x_string1)
                     VALUES (l_Arr (i).pdf_id,
                             l_Arr (i).pdd_id,
                             l_Arr (i).pdd_value,
                             l_Arr (i).pdd_op);
        END IF;

        -- 1 - Подовжити виплату (по-замовчанню)
        -- -1 - Не подовжувати виплату
        api$pc_decision.decision_UnBlock (p_pd, p_start_dt, p_stop_dt);
    END;

    -- #80861: Функция "Припинення виплати" в картці рішення
    PROCEDURE decision_Block (
        p_pd        pc_decision.pd_id%TYPE,
        p_stop_dt   pd_accrual_period.pdap_stop_dt%TYPE,
        p_PCB_RNP   pc_block.PCB_RNP%TYPE)
    IS
    BEGIN
        api$pc_decision.decision_Block (p_pd, p_stop_dt, p_PCB_RNP);
    END;

    -- #80891 Функція/кнопка "Активувати нарахування"
    PROCEDURE activate_accrual (
        p_pd         pc_decision.pd_id%TYPE,
        p_start_dt   pd_accrual_period.pdap_start_dt%TYPE,
        p_stop_dt    pd_accrual_period.pdap_stop_dt%TYPE)
    IS
    BEGIN
        api$pc_decision.activate_accrual (p_pd, p_start_dt, p_stop_dt);
    END;

    -- Поверенення проекту рішення на доопрацювання
    PROCEDURE return_pc_decision (p_pd_id    IN pc_decision.pd_id%TYPE,
                                  p_reason   IN VARCHAR2,
                                  p_pd_st    IN VARCHAR2)
    IS
        l_hs               NUMBER := tools.GetHistSession;
        l_cnt              NUMBER;
        l_st               VARCHAR2 (10);
        l_st_new           VARCHAR2 (10);
        l_st_name          VARCHAR2 (250);
        l_ap               appeal.ap_id%TYPE;
        l_ap_tp            appeal.ap_tp%TYPE;
        l_ap_st            appeal.ap_st%TYPE;
        l_nst              pc_decision.pd_nst%TYPE;
        l_PD_IS_SIGNED     pc_decision.pd_is_signed%TYPE;
        l_ap_reason        pc_decision.pd_ap_reason%TYPE;
        l_tp_reason        appeal.ap_tp%TYPE;
        l_st_reason        appeal.ap_st%TYPE;
        l_ap_num_reason    appeal.ap_num%TYPE;
        l_com_org_reason   appeal.com_org%TYPE;

        l_src              VARCHAR2 (10);
    BEGIN
        check_consistensy (P_PD_ID, P_PD_ST);

        SELECT COUNT (1)
          INTO l_cnt
          FROM pd_document
         WHERE pdo_pd = p_pd_id AND pdo_ndt = 10051 AND history_status = 'A';

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                'Рішення про призначення вже підписано, повертати таке рішення на доопрацювання заборонено!');
        END IF;

        DELETE FROM tmp_work_ids
              WHERE 1 = 1;

        INSERT INTO tmp_work_ids (x_id)
             VALUES (P_PD_ID);

        --  Функція формування історіі персон та документів звернення
        --  на підставі звернень у tmp_work_ids
        API$ACCOUNT.init_tmp_for_pd;

        SELECT ap_id,
               ap_tp,
               ap_st,
               t.pd_st,
               dic_name,
               pd_src,
               PD_nst,
               pd_ap_reason,
               npsc.npsc_to_st,
               PD_IS_SIGNED
          INTO l_ap,
               l_ap_tp,
               l_ap_st,
               l_st,
               l_st_name,
               l_src,
               l_nst,
               l_ap_reason,
               l_st_new,
               l_PD_IS_SIGNED
          FROM pc_decision  t
               JOIN appeal ON pd_ap = ap_id
               JOIN uss_ndi.v_ddn_pd_st ON pd_st = dic_value
               LEFT JOIN uss_ndi.v_ndi_pd_st_config npsc
                   ON     npsc.npsc_ap_tp =
                          CASE ap_tp WHEN 'SS' THEN 'SS_OLD' ELSE ap_tp END
                      AND npsc.npsc_tp = 'DOWN'
                      AND npsc.npsc_from_st = t.pd_st
                      AND npsc.history_status = 'A'
                      AND Dnet$pay_Assignments.Check_pd_st_config (
                              npsc.npsc_check_sql) =
                          1
         WHERE t.pd_id = P_PD_ID;


        IF l_st_new IS NULL
        THEN
            raise_application_error (
                -20000,
                   'Проект рішення неможливо повернути на доопрацювання з статусу '
                || l_st_name
                || '!');
        END IF;

        /*
            IF l_st = 'R0' THEN
              raise_application_error(-20000, 'Проект рішення неможливо повернути на доопрацювання з статусу '||l_st_name||'!');
            END IF;
        */
        -- Перевіряємо стан держутримання для допомоги інвалідам
        IF l_nst = 248 AND l_ap_reason IS NOT NULL
        THEN
            api$pc_state_alimony.Check_state_alimony_for_reject (l_ap_reason,
                                                                 l_st);
        END IF;

        IF l_ap_reason IS NOT NULL AND l_ap != l_ap_reason
        THEN
            SELECT ap_tp,
                   ap_st,
                   ap_num,
                   com_org
              INTO l_tp_reason,
                   l_st_reason,
                   l_ap_num_reason,
                   l_com_org_reason
              FROM appeal
             WHERE ap_id = l_ap_reason;

            IF l_tp_reason = 'O'
            THEN
                l_ap := l_ap_reason;
            END IF;
        END IF;

        IF l_st = 'R0' AND l_ap_reason IS NOT NULL AND l_st_reason = 'V'
        THEN
            raise_application_error (
                -20000,
                   'Заборонено повертати на доопрацювання звернення у статусі "Виконано". '
                || 'Проект рішення створено на підставі звернення '
                || l_ap_num_reason
                || ' органу '
                || l_com_org_reason
                || ' в зв''язку із тим, що учасник вибув до іншого району');
        END IF;

        UPDATE pc_decision t
           SET t.pd_st = l_st_new,
               t.com_wu = COALESCE (t.com_wu, tools.GetCurrWu),
               pd_hs_return =
                   CASE
                       WHEN     l_st_new <> l_st
                            AND l_st_new IN ('R0', 'R1'             /*, 'R2'*/
                                                       , 'P')
                       THEN
                           l_hs
                       ELSE
                           NULL
                   END
         WHERE t.pd_id = p_pd_id;

        API$PC_DECISION.write_pd_log (p_pd_id,
                                      l_hs,
                                      l_st_new,
                                      CHR (38) || '17',
                                      l_st,
                                      'SYS');

        IF p_reason IS NOT NULL
        THEN
            API$PC_DECISION.write_pd_log (p_pd_id,
                                          l_hs,
                                          l_st_new,
                                          p_reason,
                                          l_st,
                                          'USR');
        END IF;

        --#86990 2023.05.05
        --Якщо рішення, в якому вже є наявним документ з накладеним на нього ЕЦП, повертається на доопрацювання,
        --то документи, наявні на вкладці «Документи рішення», переводити в історичний статус
        IF l_st = 'R0' AND NVL (l_PD_IS_SIGNED, 'F') = 'T'
        THEN
            api$documents.delete_pd_document_all (p_pd_id);
        ELSIF                                            /*l_st = 'O.R0' AND*/
              l_st_new = 'R0' AND NVL (l_PD_IS_SIGNED, 'F') = 'T'
        THEN
            api$documents.delete_pd_document_all (p_pd_id);
        END IF;

        IF l_st = 'R0' AND l_src IN ('FS', 'PV', 'RC')
        THEN
            return_appeal (l_ap, p_reason);
        ELSIF l_st = 'R0' AND l_src = 'SA'
        THEN
            return_appeal (l_ap_reason, p_reason);
        END IF;
    END;


    -- #78434: список "способів виплат" по рішенню
    PROCEDURE GET_PD_PAY_METHODS (P_PD_ID   IN     NUMBER,
                                  RES_CUR      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN RES_CUR FOR
              SELECT t.*,
                     tp.DIC_NAME                                        AS Pdm_Pay_Tp_Name,
                     k.kaot_code || ' ' || k.kaot_name                  AS pdm_kaot_name,
                     b.nb_name                                          AS pdm_nb_name,
                     s.ns_name                                          AS pdm_ns_name,
                     d.nd_comment                                       AS pdm_nd_name,
                     ap.ap_num                                          AS pdm_ap_src_name,
                     uss_person.api$sc_tools.GET_PIB_SCC (t.pdm_scc)    AS Pdm_Pib
                FROM pd_pay_method t
                     LEFT JOIN uss_ndi.V_DDN_APM_TP tp
                         ON (tp.DIC_VALUE = t.pdm_pay_tp)
                     LEFT JOIN uss_ndi.v_ndi_katottg k
                         ON (k.kaot_id = t.pdm_kaot)
                     LEFT JOIN uss_ndi.v_ndi_bank b ON (b.nb_id = t.pdm_nb)
                     LEFT JOIN uss_ndi.v_ndi_street s ON (s.ns_id = t.pdm_ns)
                     LEFT JOIN uss_ndi.v_ndi_delivery d ON (d.nd_id = t.pdm_nd)
                     LEFT JOIN appeal ap ON (ap.ap_id = t.pdm_ap_src)
               WHERE t.pdm_pd = p_pd_id AND t.history_status = 'A'
            ORDER BY t.pdm_start_dt;
    END;

    -- #70540: збереження "Параметри виплати"
    PROCEDURE SAVE_DECISION_PAYMENTS_PARAMS (
        P_PD_ID          IN NUMBER,
        P_PD_PAY_TP      IN VARCHAR2,
        P_PD_INDEX       IN VARCHAR2,
        P_PD_KAOT        IN NUMBER,
        P_PD_NB          IN NUMBER,
        P_PD_ACCOUNT     IN VARCHAR2,
        p_PD_STREET      IN Pd_Pay_Method.PDM_STREET%TYPE,
        p_PD_NS          IN Pd_Pay_Method.PDM_NS%TYPE,
        p_PD_BUILDING    IN Pd_Pay_Method.PDM_BUILDING%TYPE,
        p_PD_BLOCK       IN Pd_Pay_Method.PDM_BLOCK%TYPE,
        p_PD_APARTMENT   IN Pd_Pay_Method.PDM_APARTMENT%TYPE,
        p_PD_ND          IN Pd_Pay_Method.PDM_ND%TYPE,
        p_PD_PAY_DT      IN Pd_Pay_Method.PDM_PAY_DT%TYPE)
    IS
        l_hs    NUMBER := tools.GetHistSession;
        l_st    VARCHAR2 (10);
        l_err   VARCHAR2 (2000);
        l_pm    pd_pay_method%ROWTYPE;
    BEGIN
          --raise_application_error(-20000, 'P_PD_ACCOUNT='||P_PD_ACCOUNT||';  p_PD_PAY_DT='||p_PD_PAY_DT||';  P_PD_NB='||P_PD_NB);
          --raise_application_error(-20000, 'P_PD_ID='||P_PD_ID);

          SELECT t.*
            INTO l_pm
            FROM pd_pay_method t
           WHERE t.pdm_pd = P_PD_ID AND t.history_status = 'A'
        ORDER BY t.pdm_start_dt DESC
           FETCH FIRST ROW ONLY;

        UPDATE pd_pay_method t
           SET t.history_status = 'H'
         WHERE t.pdm_id = l_pm.pdm_id;

        l_pm.pdm_id := 0;
        l_pm.pdm_pay_tp := P_PD_PAY_TP;
        l_pm.pdm_index := P_PD_INDEX;
        l_pm.pdm_kaot := P_PD_KAOT;
        l_pm.pdm_nb := P_PD_NB;
        l_pm.pdm_account := P_PD_ACCOUNT;
        l_pm.pdm_street := p_PD_STREET;
        l_pm.pdm_ns := p_PD_NS;
        l_pm.pdm_building := p_PD_BUILDING;
        l_pm.pdm_block := p_PD_BLOCK;
        l_pm.pdm_apartment := p_PD_APARTMENT;
        l_pm.pdm_nd := p_PD_ND;
        l_pm.pdm_pay_dt := p_PD_PAY_DT;
        l_pm.pdm_hs := l_hs;


        INSERT INTO pd_pay_method
             VALUES l_pm;

        l_err := api$calc_right.Validate_pdm_pay (P_PD_ID);

        IF l_err IS NOT NULL
        THEN
            raise_application_error (-20000, l_err);
        END IF;

        api$pc_decision.Check_pd_pay_method (p_pd_id);

        UPDATE pc_decision t
           SET t.com_wu = COALESCE (t.com_wu, tools.GetCurrWu)
         WHERE t.pd_id = p_pd_Id;


        SELECT t.pd_st
          INTO l_st
          FROM pc_decision t
         WHERE t.pd_Id = p_pd_id;

        API$PC_DECISION.write_pd_log (p_pd_Id,
                                      l_hs,
                                      l_st,
                                      CHR (38) || '18',
                                      l_st);
    END;

    -- #70334: вичитка форми "розрахунку доходу"
    PROCEDURE GET_DECISION_INCOMES (P_PD_ID    IN     NUMBER,
                                    INFO_CUR      OUT SYS_REFCURSOR,
                                    PERS_CUR      OUT SYS_REFCURSOR,
                                    DET_CUR       OUT SYS_REFCURSOR,
                                    SES_CUR       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN INFO_CUR FOR SELECT t.*
                            FROM pd_income_calc t
                           WHERE t.pic_pd = p_pd_id;

        OPEN PERS_CUR FOR
            SELECT p.*,
                   uss_person.api$sc_tools.GET_PIB_SCC (
                       p.app_scc)
                       AS app_pib,
                   tp.DIC_SNAME
                       AS app_tp_name,
                   (SELECT SUM (z.pid_fact_sum)
                      FROM pd_income_detail z
                     WHERE     z.pid_app = p.app_id
                           AND z.pid_pin = pis.pin_id
                           AND z.pid_pic IN
                                   (SELECT pic_id
                                      FROM pd_income_calc
                                     WHERE pic_pd = t.pd_id) -- #74105 2021.12.14
                           AND EXISTS
                                   (SELECT *
                                      FROM ap_income zz
                                     WHERE     z.pid_app =
                                               zz.api_app
                                           AND zz.api_month =
                                               z.pid_month
                                           AND (   zz.api_use_tp
                                                       IS NULL
                                                OR zz.api_use_tp IN
                                                       ('V',
                                                        'VS')))      -- #81112
                                                               )
                       AS pid_fact_sum,
                   (SELECT SUM (z.pid_calc_sum)
                      FROM pd_income_detail z
                     WHERE     z.pid_app = p.app_id
                           AND z.pid_pin = pis.pin_id
                           AND z.pid_pic IN (SELECT pic_id
                                               FROM pd_income_calc
                                              WHERE pic_pd = t.pd_id) -- #74105 2021.12.14
                           AND EXISTS
                                   (SELECT *
                                      FROM ap_income zz
                                     WHERE     z.pid_app = zz.api_app
                                           AND zz.api_month = z.pid_month
                                           AND (   zz.api_use_tp IS NULL
                                                OR zz.api_use_tp IN
                                                       ('V', 'VS'))) -- #81112
                                                                    )
                       AS pid_calc_sum,
                   (SELECT MAX (z.pid_is_family_member)
                      FROM pd_income_detail z
                     WHERE z.pid_app = p.app_id AND z.pid_pin = pis.pin_id)
                       AS pid_is_family_member,
                   pis.pin_id
              FROM pc_decision  t
                   JOIN ap_person p
                       ON (    p.app_ap IN (t.pd_ap, t.pd_ap_reason)
                           AND p.history_status = 'A')     --#73632 2021.12.01
                   JOIN uss_ndi.v_ddn_app_tp tp ON (tp.DIC_VALUE = p.app_tp)
                   JOIN pd_income_session pis ON (pis.pin_pd = t.pd_id)
             WHERE t.pd_id = p_pd_id;

        -- #73377       19.11.2021
        OPEN DET_CUR FOR
            SELECT t.pis_id,
                   t.pis_app,
                   t.pis_src,
                   t.pis_start_dt,
                   t.pis_stop_dt,
                   t.pis_fact_sum,
                   t.pis_final_sum,
                   t.pis_is_use,
                   t.pis_use_tp,
                   t.pis_tp,
                   t.pis_exch_tp,
                   t.pis_esv_paid,
                   t.pis_esv_min,
                   t.pis_tax_sum,
                   t.pis_edrpou,
                   src.DIC_SNAME     AS pis_src_name,
                   t.pis_pin
              FROM pd_income_src  t
                   JOIN uss_ndi.v_ddn_pis_src src
                       ON (src.DIC_VALUE = t.pis_src)
             WHERE     t.pis_pd = p_pd_id
                   --        AND EXISTS (SELECT * FROM ap_income zz WHERE t.pis_app = zz.api_app AND (zz.api_use_tp IS NULL OR zz.api_use_tp IN ('V', 'VS'))) -- #81112
                   AND (   EXISTS
                               (SELECT *
                                  FROM ap_income zz
                                 WHERE     t.pis_app = zz.api_app
                                       AND (   zz.api_use_tp IS NULL
                                            OR zz.api_use_tp IN ('V', 'VS'))) -- #81112
                        OR NOT EXISTS
                               (SELECT *
                                  FROM ap_income zz
                                 WHERE t.pis_app = zz.api_app))
            UNION ALL
            SELECT d.aim_apd                  AS pis_id,
                   d.aim_app                  AS pis_app,
                   'DOV'                      AS pis_src,
                   d.aim_month                AS pis_start_dt,
                   LAST_DAY (d.aim_month)     AS pis_stop_dt,
                   d.aim_sum                  AS pis_fact_sum,
                   d.aim_sum                  AS pis_final_sum,
                   'T'                        AS pis_is_use,
                   'STO'                      AS pis_use_tp,
                   d.aim_tp                   AS pis_tp,
                   ''                         AS pis_exch_tp,
                   '1'                        AS pis_esv_paid,
                   '1'                        AS pis_esv_min,
                   NULL                       AS pis_tax_sum,
                   NULL                       AS pis_edrpou,
                   'Довідка'                  AS pis_src_name,
                   NULL                       AS pis_pin
              FROM v_apd_income_month  d
                   JOIN pc_decision pd
                       ON (    pd.pd_ap = d.aim_ap
                           AND pd.pd_nst NOT IN (248, 267)) --#73632 2021.12.01 --#74094  2021.12.14
             WHERE     pd.pd_id = p_pd_id
                   --        AND EXISTS (SELECT * FROM ap_income zz WHERE d.aim_app = zz.api_app AND zz.api_month = d.aim_month AND (zz.api_use_tp IS NULL OR zz.api_use_tp IN ('V', 'VS'))) -- #81112
                   AND (   EXISTS
                               (SELECT *
                                  FROM ap_income zz
                                 WHERE     d.aim_app = zz.api_app
                                       AND zz.api_month = d.aim_month
                                       AND (   zz.api_use_tp IS NULL
                                            OR zz.api_use_tp IN ('V', 'VS'))) -- #81112
                        OR NOT EXISTS
                               (SELECT *
                                  FROM ap_income zz
                                 WHERE d.aim_app = zz.api_app));

        /*
              SELECT t.*,
                     src.DIC_SNAME AS pis_src_name
                FROM pd_income_src t
                JOIN uss_ndi.v_ddn_pis_src src ON (src.DIC_VALUE = t.pis_src)
               WHERE t.pis_pd = p_pd_id;
               */
        OPEN SES_CUR FOR
            SELECT t.*,
                   st.dic_name     AS pin_st_name,
                   tp.dic_name     AS pin_tp_name,
                   rp.dic_name     AS pin_rc_name,
                   hs.hs_dt        AS pib_hs_ins_dt
              FROM pd_income_session  t
                   JOIN uss_ndi.v_ddn_pin_tp tp ON (tp.dic_value = t.pin_tp)
                   JOIN uss_ndi.v_ddn_pin_st st ON (st.dic_value = t.pin_st)
                   LEFT JOIN histsession hs ON (hs.hs_id = t.pin_hs_ins)
                   LEFT JOIN recalculates r
                   JOIN uss_ndi.v_ddn_rc_tp rp
                       ON (rp.DIC_VALUE = r.rc_tp)
                       ON (r.rc_id = t.pin_rc)
             WHERE t.pin_pd = p_pd_id;
    END;

    -- #82497 2022.12.28: Блокування кнопки «Розрахунок доходу» для рішень про СП
    FUNCTION Get_IsNeed_Income (p_pd_id NUMBER)
        RETURN NUMBER
    IS
        l_ap_id   NUMBER (10);
    BEGIN
        SELECT pd_ap
          INTO l_ap_id
          FROM pc_decision
         WHERE pd_id = p_pd_id;

        RETURN API$APPEAL.GET_ISNEED_INCOME (l_ap_id);
    END;

    -- #87142 20230509 Доступність кнопки «Затвердити» у рішеннях по SS-зверненнях при затвердженні
    FUNCTION Get_Is_Block_Approve (p_pd_id NUMBER)
        RETURN NUMBER
    IS
        l_ap_id    NUMBER (10);
        l_ap_tp    VARCHAR2 (10);
        l_pd_st    VARCHAR2 (10);
        l_rez      NUMBER (10);
        l_ndt      NUMBER;
        l_check1   NUMBER;
        l_check2   NUMBER;
        l_check3   NUMBER;
    BEGIN
        -- #88679 - додав обробку для 836 документа
        -- #88656 - додав обробку для 835 документа
        SELECT ap_id,
               ap_tp,
               (SELECT MAX (apd_ndt)
                  FROM ap_document z
                 WHERE     z.apd_ap = ap_id
                       AND apd_ndt IN (801,
                                       802,
                                       836,
                                       835)),
               pd_st
          INTO l_ap_id,
               l_ap_tp,
               l_ndt,
               l_pd_St
          FROM pc_decision JOIN appeal ON ap_id = pd_ap
         WHERE pd_id = p_pd_id;

        IF l_ap_tp != 'SS'
        THEN
            RETURN 0;
        END IF;

        SELECT COUNT (1)
          INTO l_check1
          FROM pd_document t
         --JOIN pd_document z ON (z.pdo_pd = t.pdo_pd AND z.pdo_ndt IN (818, 819))
         WHERE     t.pdo_pd = p_pd_id
               AND t.pdo_ndt = 804
               AND t.history_status = 'A';

        -- #89818
        SELECT CASE
                   WHEN c1 > 0 AND (c2 > 0 AND c3 > 0 OR c2 = 0) AND c4 = 1
                   THEN
                       1
                   ELSE
                       0
               END
          INTO l_check3
          FROM (SELECT (SELECT COUNT (*)
                          FROM v_pd_right_log z
                         WHERE z.prl_pd = t.pd_id)              AS c1,
                       (SELECT COUNT (*)
                          FROM ap_document  d
                               JOIN ap_document_attr da
                                   ON (da.apda_apd = d.apd_id)
                         WHERE     d.apd_ap = t.pd_ap
                               AND (       d.apd_ndt IN (801)
                                       AND da.apda_nda IN (1871)
                                    OR     d.apd_ndt IN (802)
                                       AND da.apda_nda IN (1948)
                                    OR     d.apd_ndt IN (803)
                                       AND da.apda_nda IN (2528)
                                    OR     d.apd_ndt IN (836)
                                       AND da.apda_nda IN (3446)
                                    OR     d.apd_ndt IN (835)
                                       AND da.apda_nda IN (3265))
                               AND d.history_status = 'A'
                               AND da.apda_val_string = 'T')    AS c2,
                       (SELECT COUNT (*)
                          FROM pd_income_calc c
                         WHERE c.pic_pd = t.pd_id)              AS c3,
                       CASE
                           WHEN     f1.pde_val_string = 'T'
                                AND f2.pde_val_string = 'T'
                           THEN
                               1
                           ELSE
                               0
                       END                                      AS c4
                  FROM v_pc_decision  t
                       LEFT JOIN pd_features f1
                           ON (f1.pde_pd = t.pd_id AND f1.pde_nft = 32)
                       LEFT JOIN pd_features f2
                           ON (f2.pde_pd = t.pd_id AND f2.pde_nft = 33)
                 WHERE t.pd_id = p_pd_id);

        --#89818
        /*Задача: для даної комбінації параметрів кнопку «Затвердити» робити активною за умов:
          - є наявним документ «Акт оцінки потреб сім’ї/особи» ndt_id=804
          - виконано розрахунок доходів (за необхідності)
          - виконано визначення права*/

        IF (l_pd_st = 'R0' AND l_check1 = 1 AND l_check3 = 1)
        THEN
            RETURN 0;
        END IF;


        /* Ініціативним документом звернення є «Повідомлення/інформація про сім’ю/особу, яка перебуває у СЖО» ndt_id=802
         1) статус рішення R0 і у рішенні відсутні документи:
         а) - «Акт оцінки потреб сім’ї/особи» ndt_id=804
         та
         б) - «Висновок оцінки потреб сім'ї» ndt_id=818
         або
         - «Висновок оцінки потреб особи» ndt_id=819*/

        IF (l_ndt IN (802, 835) AND l_pd_st = 'R0' AND l_check1 = 0)
        THEN
            RETURN 1;
        END IF;

        SELECT COUNT (1)
          INTO l_check2
          FROM pd_document t JOIN pd_signers s ON (s.pdi_pdo = t.pdo_id)
         WHERE     t.pdo_pd = p_pd_id
               AND t.pdo_ndt IN (850, 854)
               AND t.history_status = 'A'
               AND s.pdi_is_signed = 'T';

        /*Ініціативним документом звернення є «Заява про надання соціальних послуг» ndt_id=801
          1) статус рішення R0/O.R0 і у рішенні відсутні документи:
          а) - «Акт оцінки потреб сім’ї/особи» ndt_id=804
          та
          б) - «Висновок оцінки потреб сім'ї» ndt_id=818
          або
          - «Висновок оцінки потреб особи» ndt_id=819
          та
          в) - «Рішення про надання / відмову в наданні соціальних послуг» ndt_id=850 з накладеним КЕП
          або
          - «Путівка на влаштування до інтернатної(го) установи/закладу» ndt_id=854 з накладеним КЕП*/

        --raise_application_error(-20000, 'l_ndt='||l_ndt||';l_pd_st='||l_pd_st||';l_check1='||l_check1||';l_check2='||l_check2);

        IF (    l_ndt IN (801, 836)
            AND l_pd_st IN ('R0', 'O.R0')
            AND (l_check1 = 0 OR l_check2 = 0))
        THEN
            RETURN 1;
        END IF;

        SELECT COUNT (1)
          INTO l_check1
          FROM pd_document t JOIN pd_signers s ON (s.pdi_pdo = t.pdo_id)
         WHERE     t.pdo_pd = p_pd_id
               AND t.pdo_ndt IN (851)
               AND t.history_status = 'A'
               AND s.pdi_is_signed = 'T';

        SELECT COUNT (1)
          INTO l_check2
          FROM pd_document t JOIN pd_signers s ON (s.pdi_pdo = t.pdo_id)
         WHERE     t.pdo_pd = p_pd_id
               AND t.pdo_ndt IN (852, 853)
               AND t.history_status = 'A'
               AND s.pdi_is_signed = 'T';

        /*статус рішення WD/AV/O.WD/O.AV і у рішенні відсутні документи:
        а) - «Повідомлення про надання / відмову в наданні соціальних послуг» ndt_id=851 з накладеним КЕП
        або
        б) - «Клопотання про влаштування особи з інвалідністю, особи похилого віку до інтернатної(го) установи/закладу» ndt_id=852 з накладеним КЕП
        та
        - «Повідомлення про направлення клопотання про влаштування особи з інвалідністю, особи похилого віку до інтернатної(го) установи/закладу» ndt_id=853 з накладеним КЕП*/

        IF (    l_ndt IN (801, 836)
            AND l_pd_st IN ('WD',
                            'AV',
                            'O.WD',
                            'O.AV')
            AND (l_check1 = 0 AND l_check2 < 2))
        THEN
            RETURN 1;
        END IF;

        RETURN 0;
    END;

    -- #89735 20230717 Доступність кнопки «Затвердити» у рішеннях по SS-зверненнях при відмові
    FUNCTION Get_Is_Block_Approve_4rej (p_pd_id NUMBER)
        RETURN NUMBER
    IS
        l_ap_id    NUMBER (10);
        l_ap_tp    VARCHAR2 (10);
        l_pd_st    VARCHAR2 (10);
        l_rez      NUMBER (10);
        l_ndt      NUMBER;
        l_check1   NUMBER;
        l_check2   NUMBER;
        l_check3   NUMBER;
    BEGIN
        SELECT ap_id,
               ap_tp,
               (SELECT MAX (apd_ndt)
                  FROM ap_document z
                 WHERE     z.apd_ap = ap_id
                       AND apd_ndt IN (801,
                                       802,
                                       836,
                                       835)),
               pd_st
          INTO l_ap_id,
               l_ap_tp,
               l_ndt,
               l_pd_St
          FROM pc_decision JOIN appeal ON ap_id = pd_ap
         WHERE pd_id = p_pd_id;

        IF l_ap_tp != 'SS'
        THEN
            RETURN 0;
        END IF;

        SELECT COUNT (1)
          INTO l_check1
          FROM pd_document t
         WHERE     t.pdo_pd = p_pd_id
               AND t.pdo_ndt = 804
               AND t.history_status = 'A';

        /* Ініціативним документом звернення є «Повідомлення/інформація про сім’ю/особу, яка перебуває у СЖО» ndt_id=802 або «Звернення з кабінету ОСП» ndt_id=835:
           - статус рішення R0 і у рішенні відсутній документ:
           - «Акт оцінки потреб сім’ї/особи» ndt_id=804 */

        IF (l_ndt IN (802, 835) AND l_pd_st = 'R0' AND l_check1 = 0)
        THEN
            RETURN 1;
        END IF;



        SELECT CASE WHEN c1 < 2 OR c2 = 0 THEN 1 ELSE 0 END
          INTO l_check2
          FROM (SELECT (SELECT COUNT (*)
                          FROM pd_signers z
                         WHERE     z.pdi_pdo = t.pdo_id
                               AND z.history_status = 'A')    AS c1,
                       (SELECT COUNT (*)
                          FROM pd_signers z
                         WHERE     z.pdi_pdo = t.pdo_id
                               AND z.history_status = 'A'
                               AND z.pdi_is_signed = 'T')     AS c2
                  FROM pd_document t
                 WHERE     t.pdo_pd = p_pd_id
                       AND t.pdo_ndt IN (850)
                       AND t.history_status = 'A') t;

        SELECT COUNT (1)
          INTO l_check3
          FROM pd_document t JOIN pd_signers s ON (s.pdi_pdo = t.pdo_id)
         WHERE     t.pdo_pd = p_pd_id
               AND t.pdo_ndt IN (851)
               AND t.history_status = 'A'
               AND s.history_status = 'A'
               AND s.pdi_is_signed = 'T';

        /*ІІ Ініціативним документом звернення є «Заява про надання соціальних послуг» ndt_id=801 або «Заява про надання соціальної послуги медіації» ndt_id=836:
            1) статус рішення R0/O.R0:
            - у рішенні відсутні документи:
            -- «Акт оцінки потреб сім’ї/особи» ndt_id=804
            -- «Рішення про надання / відмову в наданні соціальних послуг» ndt_id=850 з накладеним КЕП першого підписанта
            - документу «Рішення про надання / відмову в наданні соціальних послуг» ndt_id=850 не додано другого підписанта
            2) статус рішення AV/O.AV і у рішенні відсутній документ:
            - «Повідомлення про надання / відмову в наданні соціальних послуг» ndt_id=851 з накладеним КЕП*/

        --raise_application_error(-20000, 'l_ndt='||l_ndt||';l_pd_st='||l_pd_st||';l_check1='||l_check1||';l_check2='||l_check2);

        IF (       l_ndt IN (801, 836)
               AND l_pd_st IN ('R0', 'O.R0')
               AND (l_check1 = 0 OR l_check2 = 1)
            OR l_ndt IN (851) AND l_pd_st IN ('AV', 'O.AV') AND l_check3 = 0)
        THEN
            RETURN 1;
        END IF;

        RETURN 0;
    END;

    -- #70334: збереження форми "Розрахунок доходу"
    PROCEDURE SAVE_DECISION_INCOMES (P_PD_ID   IN     NUMBER,
                                     P_CLOB    IN     CLOB,
                                     p_mode    IN     NUMBER DEFAULT 0, -- 0 - стандарт, 1 - #99052
                                     MSG_CUR      OUT SYS_REFCURSOR)
    IS
        l_arr   t_pd_income_src;
        l_hs    NUMBER := tools.GetHistSession;
        l_st    VARCHAR2 (10);
        l_nst   NUMBER;
    BEGIN
        IF Get_IsNeed_Income (P_PD_ID) = 0
        THEN
            raise_application_error (
                -20000,
                'Звернення не потребує виконання розрахунку доходу');
        END IF;

        SELECT pd.pd_st, pd.pd_nst
          INTO l_st, l_nst
          FROM pc_decision pd
         WHERE pd.pd_id = p_pd_id;

        IF l_st NOT IN ('W', 'R0') AND l_nst IN (249, 267, 268)
        THEN
            raise_application_error (
                '-20000',
                'Спроба видалити доходи для рішення не в стані "на розрахунку".');
        END IF;

        --raise_application_error(-20000, p_clob);
        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''. ''');

        EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                         't_pd_income_src',
                                         TRUE,
                                         TRUE)
            BULK COLLECT INTO l_arr
            USING P_CLOB;

        --raise_application_error(-20000, l_arr.count);

        FOR xx
            IN (SELECT *
                  FROM TABLE (l_arr)  t
                       JOIN pd_income_session s ON (s.pin_id = pis_pin)
                 WHERE s.pin_st != 'E')
        LOOP
            raise_application_error (
                -20000,
                'Редагування деталей в сесії доходів не в статусі "редагується" заборонено!');
        END LOOP;


        FORALL i IN INDICES OF l_arr
            DELETE FROM pd_income_src t
                  WHERE     t.pis_id = l_arr (i).pis_id
                        AND l_arr (i).deleted = 1
                        AND l_arr (i).pis_src NOT IN ('PFU', 'DPS');

        FORALL i IN INDICES OF l_arr
            UPDATE pd_income_src t
               SET t.pis_tp = l_arr (i).pis_tp,
                   t.pis_final_sum = l_arr (i).pis_final_sum,
                   t.pis_esv_paid = l_arr (i).pis_esv_paid,
                   t.pis_esv_min = l_arr (i).pis_esv_min,
                   t.pis_start_dt =
                       TO_DATE (l_arr (i).pis_start_dt,
                                'YYYY-MM-DD"T"HH24:MI:SS'),
                   t.pis_stop_dt =
                       TO_DATE (l_arr (i).pis_stop_dt,
                                'YYYY-MM-DD"T"HH24:MI:SS'),
                   t.pis_is_use = l_arr (i).pis_is_use,
                   t.pis_use_tp = l_arr (i).pis_use_tp,
                   --t.pis_tax_sum = l_arr(i).pis_tax_sum,
                   t.pis_edrpou = l_arr (i).pis_edrpou
             WHERE     t.pis_id = l_arr (i).pis_id
                   AND l_arr (i).deleted = 0
                   AND l_arr (i).pis_src NOT IN ('PFU', 'DPS');

        FORALL i IN INDICES OF l_arr
            UPDATE pd_income_src t
               SET t.pis_use_tp = l_arr (i).pis_use_tp
             WHERE     t.pis_id = l_arr (i).pis_id
                   AND l_arr (i).deleted = 0
                   AND l_arr (i).pis_src IN ('PFU', 'DPS');

        FOR xx IN (SELECT *
                     FROM TABLE (l_arr)
                    WHERE pis_id IS NULL AND pis_src NOT IN ('PFU', 'DPS'))
        LOOP
            INSERT INTO pd_income_src t (pis_tp,
                                         pis_src,
                                         pis_final_sum,
                                         pis_sc,
                                         pis_esv_paid,
                                         pis_esv_min,
                                         pis_start_dt,
                                         pis_stop_dt,
                                         pis_pd,
                                         pis_app,
                                         pis_is_use,
                                         pis_edrpou,
                                         pis_use_tp,
                                         pis_pin)
                     VALUES (
                                xx.pis_tp,
                                xx.pis_src,
                                xx.pis_final_sum,
                                xx.pis_sc,
                                xx.pis_esv_paid,
                                xx.pis_esv_min,
                                TO_DATE (xx.pis_start_dt,
                                         'YYYY-MM-DD"T"HH24:MI:SS'),
                                TO_DATE (xx.pis_stop_dt,
                                         'YYYY-MM-DD"T"HH24:MI:SS'),
                                p_pd_id,
                                xx.pis_app,
                                xx.pis_is_use,
                                xx.pis_edrpou,
                                xx.pis_use_tp,
                                xx.pis_pin);
        END LOOP;

        API$PC_DECISION.write_pd_log (p_pd_Id,
                                      l_hs,
                                      l_st,
                                      CHR (38) || '19',
                                      l_st);

        IF l_nst IN (249, 267, 268)
        THEN
            --Видаляємо існуючі деталі розрахунку рішення
            DELETE FROM pd_detail
                  WHERE pdd_pdp IN (SELECT pdp_id
                                      FROM pd_payment
                                     WHERE pdp_pd = P_PD_ID);

            --Видаляємо існуючі розрахунки рішення
            DELETE FROM pd_payment
                  WHERE pdp_pd IN (SELECT pd_id
                                     FROM pc_decision
                                    WHERE pd_ap = P_PD_ID);
        END IF;

        -- #99052
        IF (p_mode = 1)
        THEN
            API$PC_DECISION.calc_income_for_pd_alt (p_pd_id, msg_cur);
        ELSE
            API$PC_DECISION.calc_income_for_pd (1, p_pd_id, msg_cur);
        END IF;
    END;

    -- #70334: вичитка форми "Дані помісячного розрахунку"
    PROCEDURE GET_PERSON_INFO (P_PIC_ID   IN     NUMBER,
                               P_APP_ID   IN     NUMBER,
                               RES_CUR       OUT SYS_REFCURSOR,
                               LOG_CUR       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN RES_CUR FOR   SELECT t.*
                             FROM pd_income_detail t
                            WHERE t.pid_app = P_APP_ID AND t.pid_pic = P_PIC_ID
                         ORDER BY t.pid_month;

        OPEN LOG_CUR FOR
            SELECT t.*
              FROM v_pd_income_log  t
                   JOIN pd_income_detail d ON (d.pid_id = t.pil_pid)
             WHERE d.pid_app = P_APP_ID AND d.pid_pic = P_PIC_ID;
    END;

    -- #70724: лог виплат
    PROCEDURE GET_DECISION_LOG (P_PD_ID IN NUMBER, RES_CUR OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN RES_CUR FOR
              SELECT t.pdl_id
                         AS log_id,
                     t.pdl_pd
                         AS log_obj,
                     t.pdl_tp
                         AS log_tp,
                     st.DIC_NAME
                         AS log_st_name,
                     sto.DIC_NAME
                         AS log_st_old_name,
                     hs.hs_dt
                         AS log_hs_dt,
                     NVL (tools.GetUserLogin (hs.hs_wu), 'Автоматично')
                         AS log_hs_author,
                     Uss_Ndi.Rdm$msg_Template.Getmessagetext (t.pdl_message)
                         AS log_message
                FROM pd_log t
                     LEFT JOIN uss_ndi.v_ddn_pd_st st
                         ON (st.DIC_VALUE = t.pdl_st)
                     LEFT JOIN uss_ndi.v_ddn_pd_st sto
                         ON (sto.DIC_VALUE = t.pdl_st_old)
                     LEFT JOIN v_histsession hs ON (hs.hs_id = t.pdl_hs)
               WHERE t.pdl_pd = P_PD_ID
            ORDER BY hs.hs_dt;
    END;

    -- #81873: лог "Впорядкування даних АСОПД"
    PROCEDURE GET_PCO_LOG (P_PCO_ID IN NUMBER, RES_CUR OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN RES_CUR FOR
              SELECT t.pcol_id
                         AS log_id,
                     t.pcol_pco
                         AS log_obj,
                     t.pcol_tp
                         AS log_tp,
                     st.DIC_NAME
                         AS log_st_name,
                     sto.DIC_NAME
                         AS log_st_old_name,
                     hs.hs_dt
                         AS log_hs_dt,
                     NVL (tools.GetUserLogin (hs.hs_wu), 'Автоматично')
                         AS log_hs_author,
                     Uss_Ndi.Rdm$msg_Template.Getmessagetext (t.pcol_message)
                         AS log_message
                FROM v_pco_log t
                     LEFT JOIN uss_ndi.v_ddn_pco_st st
                         ON (st.DIC_VALUE = t.pcol_st)
                     LEFT JOIN uss_ndi.v_ddn_pco_st sto
                         ON (sto.DIC_VALUE = t.pcol_st_old)
                     LEFT JOIN v_histsession hs ON (hs.hs_id = t.pcol_hs)
               WHERE t.pcol_pco = P_PCO_ID
            ORDER BY hs.hs_dt;
    END;

    -- info:   Підписання документа-рішення
    -- params: p_pd_id - ідентифікатор рішення
    --         p_doc_id - ідентифікатор документа Е/А
    --         p_dh_id - ідентифікатор зрізу документа Е/А
    -- note:   #77050/#78724
    PROCEDURE sign_decision (
        p_pd_id    IN pd_document.pdo_pd%TYPE,
        p_doc_id   IN pd_document.pdo_doc%TYPE DEFAULT NULL,
        p_dh_id    IN pd_document.pdo_dh%TYPE DEFAULT NULL)
    IS
    BEGIN
        UPDATE pc_decision
           SET pd_is_signed = 'T'
         WHERE     pd_id = p_pd_id
               AND COALESCE (pd_is_signed, 'F') = 'F'
               AND pd_st IN ('P', 'V')
               AND pd_nst IN (664,
                              269,
                              268,
                              267,
                              265,
                              249,
                              248);

        --Ініціалізація копіювання документа рішення в звернення
        IF SQL%ROWCOUNT > 0
        THEN
            api$documents.add_decision_doc (p_pd_id, p_doc_id, p_dh_id);
            api$esr_action.preparewrite_visit_ap_log (
                p_pd_id,
                'Підписано документ-рішення');
            api$pc_decision.write_pd_log (p_pd_id,
                                          tools.gethistsession,
                                          'P',
                                          CHR (38) || '49',
                                          'P');
        END IF;
    END;

    FUNCTION Check_pd_st_config (sqlstr VARCHAR2)
        RETURN NUMBER
    IS
        ret   NUMBER;
    BEGIN
        IF sqlstr IS NULL
        THEN
            RETURN 1;
        END IF;

        EXECUTE IMMEDIATE sqlstr
            USING OUT ret;

        RETURN CASE ret WHEN 0 THEN 0 ELSE 1 END;
    END;

    PROCEDURE SAVE_Features (P_PD_ID IN NUMBER, P_CLOB IN CLOB)
    IS
        l_arr   t_pd_features;
        l_nst   NUMBER;
    BEGIN
        SELECT pd_nst
          INTO l_nst
          FROM pc_decision t
         WHERE pd_id = p_pd_id;

        -- raise_application_error(-20000, P_CLOB);
        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''. ''');

        EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                         't_pd_features',
                                         TRUE,
                                         TRUE)
            BULK COLLECT INTO l_arr
            USING P_CLOB;

        FOR i IN 1 .. l_arr.COUNT
        LOOP
            IF     l_arr (i).Deleted IS NOT NULL
               AND l_arr (i).Deleted = 1
               AND l_arr (i).pde_id > 0
            THEN
                API$PC_DECISION.Delete_Features (l_arr (i).pde_id);
            ELSE
                API$PC_DECISION.Save_Features (
                    p_pde_id           => l_arr (i).pde_id,
                    p_pde_pd           => l_arr (i).pde_pd,
                    p_pde_nft          => l_arr (i).pde_nft,
                    p_pde_val_int      => l_arr (i).pde_val_int,
                    p_pde_val_sum      => l_arr (i).pde_val_sum,
                    p_pde_val_id       => l_arr (i).pde_val_id,
                    p_pde_val_dt       => l_arr (i).pde_val_dt /*to_date(l_arr(i).pde_val_dt, c_Xml_Dt_Fmt)*/
                                                              ,
                    p_pde_val_string   => l_arr (i).pde_val_string,
                    p_pde_pdf          => l_arr (i).pde_pdf,
                    p_new_id           => l_arr (i).pde_id,
                    p_pd_nst           => l_nst);
            END IF;
        END LOOP;
    END;

    -- #80572: перенос всіх рішень з одного юзера на іншого
    PROCEDURE MOVE_ALL_TO_USER (P_WU_ID IN NUMBER, P_WU_TO_ID IN NUMBER)
    IS
        l_org      NUMBER;
        l_org_to   NUMBER;
    BEGIN
        SELECT t.wu_org
          INTO l_org
          FROM ikis_sysweb.v$all_users t
         WHERE t.wu_id = p_wu_id;

        SELECT t.wu_org
          INTO l_org_to
          FROM ikis_sysweb.v$all_users t
         WHERE t.wu_id = p_wu_to_id;

        IF (l_org != l_org_to)
        THEN
            raise_application_error (
                -20000,
                'Неможливо переносити рішення між користувачами різних ОСЗН!');
        END IF;

        UPDATE v_pc_decision t
           SET t.com_wu = p_wu_to_id
         WHERE t.com_wu = p_wu_id;

        IF (SQL%ROWCOUNT = 0)
        THEN
            raise_application_error (
                -20000,
                'Не знайдено жодного рішення для вибраного користувача!');
        END IF;
    END;

    -- #80572: кількість рішень по юзеру
    PROCEDURE MOVE_DECISION_CNT (P_WU_ID IN NUMBER, P_CNT OUT NUMBER)
    IS
    BEGIN
        SELECT COUNT (*)
          INTO p_cnt
          FROM v_pc_decision t
         WHERE t.com_wu = p_wu_id;
    END;

    -- #80572: перенос вибраних рішень з одного юзера на іншого
    PROCEDURE MOVE_TO_USER (P_WU_ID IN NUMBER, P_IDS IN VARCHAR2)
    IS
    BEGIN
        UPDATE v_pc_decision t
           SET t.com_wu = p_wu_id
         WHERE t.pd_id IN (    SELECT REGEXP_SUBSTR (text,
                                                     '[^(\,)]+',
                                                     1,
                                                     LEVEL)    AS z_rdt_id
                                 FROM (SELECT P_IDS AS text FROM DUAL)
                           CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                             '[^(\,)]+',
                                                             1,
                                                             LEVEL)) > 0);
    END;

    -- #81873 - деталі "Впорядкування даних АСОПД"
    PROCEDURE GET_PCO_DETAILS (p_pco_id IN NUMBER, det_cur OUT SYS_REFCURSOR)
    IS
        l_tp      VARCHAR2 (10);
        l_pd      NUMBER;
        l_month   DATE;
    BEGIN
        SELECT MAX (t.pco_tp), MAX (t.pco_month)
          INTO l_tp, l_month
          FROM pc_data_ordering t
         WHERE t.pco_id = p_pco_id;

        IF (l_tp = 'DUPD')
        THEN
            OPEN det_cur FOR
                SELECT t.*,
                       NVL (
                           (  SELECT    TO_CHAR (pdap_start_dt,
                                                 'DD.MM.YYYY')
                                     || '-'
                                     || TO_CHAR (pdap_stop_dt,
                                                 'DD.MM.YYYY')
                                FROM pd_accrual_period pp
                               WHERE     pdap_pd = t.pcod_pd
                                     AND pp.history_status = 'A'
                            ORDER BY pdap_start_dt DESC
                               FETCH FIRST ROW ONLY),      -- OPERVEIEV #80462
                              'очік: '
                           || TO_CHAR (pd_start_dt,
                                       'DD.MM.YYYY')
                           || '-'
                           || TO_CHAR (pd_stop_dt, 'DD.MM.YYYY'))
                           AS pd_real_period,
                       d.pd_num,
                       (SELECT SUM (z.pdp_sum)
                          FROM pd_payment z
                         WHERE     z.pdp_pd = d.pd_id
                               AND l_month BETWEEN z.pdp_start_dt
                                               AND z.pdp_stop_dt
                               AND z.history_status = 'A')
                           AS pdp_sum
                  FROM v_pco_detail  t
                       LEFT JOIN pc_decision d ON (d.pd_id = t.pcod_pd)
                       LEFT JOIN ac_detail a ON (a.acd_id = t.pcod_fix_acd)
                       LEFT JOIN accrual ac ON (ac.ac_id = a.acd_ac)
                       LEFT JOIN uss_ndi.v_ndi_op op ON (op.op_id = a.acd_op)
                       LEFT JOIN uss_ndi.v_ndi_payment_type pt
                           ON (pt.npt_id = a.acd_npt)
                 WHERE t.pcod_pco = p_pco_id;
        ELSE
            OPEN det_cur FOR
                SELECT t.*,
                       ac.ac_month,
                       op.op_code || ' ' || op.op_name       AS op_name,
                       pt.npt_code || ' ' || pt.npt_name     AS npt_name,
                       a.acd_imp_pr_num
                  FROM v_pco_detail  t
                       LEFT JOIN v_ac_detail a ON (a.acd_id = t.pcod_fix_acd)
                       LEFT JOIN v_accrual ac ON (ac.ac_id = a.acd_ac)
                       LEFT JOIN uss_ndi.v_ndi_op op ON (op.op_id = a.acd_op)
                       LEFT JOIN uss_ndi.v_ndi_payment_type pt
                           ON (pt.npt_id = a.acd_npt)
                 WHERE t.pcod_pco = p_pco_id;
        END IF;
    END;

    -- #81873 - збереження і обробка "Впорядкування даних АСОПД"
    PROCEDURE SAVE_PCO_CARD (
        p_pco_id            IN NUMBER,
        p_pco_decision_tp   IN pc_data_ordering.pco_decision_tp%TYPE,
        p_pco_is_need_pay   IN pc_data_ordering.pco_is_need_pay%TYPE,
        p_pco_new_pdp_sum   IN pc_data_ordering.pco_new_pdp_sum%TYPE,
        p_pco_new_acd_sum   IN pc_data_ordering.pco_new_acd_sum%TYPE,
        p_xml               IN CLOB)
    IS
        l_tp   VARCHAR2 (10);
    BEGIN
        SELECT MAX (t.pco_tp)
          INTO l_tp
          FROM pc_data_ordering t
         WHERE t.pco_id = p_pco_id;

        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''. ''');

        --raise_application_error(-20000, p_xml);
        UPDATE pc_data_ordering t
           SET t.pco_decision_tp = p_pco_decision_tp,
               t.pco_is_need_pay = p_pco_is_need_pay,
               t.pco_new_pdp_sum = p_pco_new_pdp_sum,
               t.pco_new_acd_sum = p_pco_new_acd_sum
         WHERE t.pco_id = p_pco_id;


        INSERT INTO tmp_work_set1 (x_id1, x_sum1, x_string1)
                     SELECT x_id, x_sum, x_is_correct
                       FROM XMLTABLE (
                                '/ArrayOfDecisionDataOrderingDetailDTO/DecisionDataOrderingDetailDTO'
                                PASSING xmltype (p_xml)
                                COLUMNS x_id            NUMBER PATH 'Pcod_Id',
                                        x_sum           NUMBER PATH 'Pcod_New_Acd_Sum',
                                        x_is_correct    VARCHAR2 (10) PATH 'Pcod_Is_Correct');


        UPDATE pco_detail
           SET pcod_new_acd_sum =
                   CASE
                       WHEN l_tp IN ('AWP', 'PNEA')
                       THEN
                           (SELECT x_sum1
                              FROM tmp_work_set1
                             WHERE pcod_id = x_id1)
                       ELSE
                           pcod_new_acd_sum
                   END,
               pcod_is_correct =
                   CASE
                       WHEN l_tp IN ('DUPD')
                       THEN
                           (SELECT x_string1
                              FROM tmp_work_set1
                             WHERE pcod_id = x_id1)
                       ELSE
                           pcod_is_correct
                   END
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_work_set1
                     WHERE pcod_id = x_id1);

        -- обробка
        api$pc_data_ordering.process_pc_data_ordering (p_pco_id);
    END;

    -- #83758: "Особливий" режим редагування мігрованих рішень по ВПО
    PROCEDURE SAVE_MG_PAY_DETAILS (P_PDP_ID   IN NUMBER,
                                   P_PD_ST    IN VARCHAR2,
                                   p_xml      IN CLOB)
    IS
        l_pd_id     NUMBER;
        l_pdd_id    NUMBER;
        l_check     NUMBER;
        l_new_pdp   NUMBER;
        l_hs        NUMBER := tools.GetHistSession;
        l_row       pd_payment%ROWTYPE;
        l_cnt       INTEGER;
    BEGIN
        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''. ''');

        SELECT *
          INTO l_row
          FROM pd_payment
         WHERE pdp_id = p_pdp_id
        FOR UPDATE;

        SELECT t.pdp_pd,
               CASE
                   WHEN     d.pd_src = 'MG'
                        AND d.pd_ap < 0
                        AND d.pd_St IN ('S', 'PS')
                        AND (       t.pdp_npt = 167
                                AND t.pdp_start_dt >=
                                    TO_DATE ('01.03.2022', 'DD.MM.YYYY')
                             OR     d.pd_nst IN (265, 268)
                                AND t.pdp_start_dt >=
                                    TO_DATE ('01.06.2005', 'DD.MM.YYYY'))
                   THEN
                       1
                   ELSE
                       0
               END
          INTO l_pd_id, l_check
          FROM pd_payment t JOIN pc_decision d ON (d.pd_id = t.pdp_pd)
         WHERE t.pdp_id = p_pdp_id AND t.history_status = 'A';

        IF (l_check != 1)
        THEN
            raise_application_error (
                -20000,
                'Неможливо правити деталі призначення. Одне з умов перевірки не виконане: рішення мігроване, статус рішення - "Призупинено виплату" або "Нараховано", вид послуги - "Допомога переміщеним особам на проживання" або послуги - "Допомога особі, яка доглядає за хворою дитиною" чи "Допомога на дітей, над якими встановлено опіку чи піклування", період >= "01.03.2022"');
        END IF;

        check_consistensy (l_pd_id, p_pd_st);

        SELECT COUNT (*)
          INTO l_check
          FROM pd_payment t JOIN pd_payment q ON (q.pdp_Id = P_PDP_ID)
         WHERE     t.pdp_pd = l_pd_id
               AND t.pdp_id != q.pdp_id
               AND t.pdp_start_dt = q.pdp_start_dt
               AND t.pdp_npt = q.pdp_npt
               AND t.history_status = 'A'
               AND q.history_status = 'A';

        IF (l_check > 0)
        THEN
            raise_application_error (
                -20000,
                'Неможливо правити деталі призначення. Помилка унікальності призначення!');
        END IF;

        UPDATE pd_payment t
           SET t.pdp_hs_del = l_hs, t.history_status = 'H'
         WHERE t.pdp_id = P_PDP_ID AND t.history_status = 'A';

        IF SQL%ROWCOUNT > 0
        THEN
            SELECT *
              INTO l_row
              FROM pd_payment t
             WHERE t.pdp_id = P_PDP_ID;

            INSERT INTO pd_payment t (pdp_pd,
                                      pdp_npt,
                                      pdp_start_dt,
                                      pdp_stop_dt,
                                      pdp_sum,
                                      pdp_hs_ins,
                                      history_status)
                 VALUES (l_row.pdp_pd,
                         l_row.pdp_npt,
                         l_row.pdp_start_dt,
                         l_row.pdp_stop_dt,
                         l_row.pdp_sum,
                         l_hs,
                         'A')
              RETURNING pdp_id
                   INTO l_new_pdp;

            FOR xx
                IN (  SELECT t.*, ROWNUM AS rn
                        FROM XMLTABLE (
                                 '/ArrayOfDecisionPaymentMigratedDetailDTO/DecisionPaymentMigratedDetailDTO'
                                 PASSING xmltype (p_xml)
                                 COLUMNS x_id     NUMBER PATH 'Pdd_Key',
                                         x_sum    NUMBER PATH 'Pdd_Value',
                                         x_bdt    VARCHAR2 (30) PATH 'Birth_Dt',
                                         x_pib    VARCHAR2 (250) PATH 'Pib') t)
            LOOP
                SELECT COUNT (*)
                  INTO l_check
                  FROM pd_detail t
                 WHERE     t.pdd_pdp = l_new_pdp
                       AND t.pdd_ndp = 290
                       AND t.pdd_key = xx.x_id
                       AND t.pdd_value != 0;

                IF (l_check > 0)
                THEN
                    raise_application_error (
                        -20000,
                        'Неможливо правити деталі призначення. Помилка унікальності деталі призначення!');
                END IF;

                -- #86328
                SELECT pdd_id
                  INTO l_pdd_id
                  FROM (SELECT t.pdd_id
                          FROM pd_detail t
                         WHERE     t.pdd_pdp = l_new_pdp
                               AND t.pdd_ndp = 290
                               AND t.pdd_key = xx.x_id
                               AND t.pdd_value = 0
                        UNION ALL
                        SELECT NULL FROM DUAL)
                 FETCH FIRST ROW ONLY;

                IF (l_pdd_id IS NOT NULL)
                THEN
                    UPDATE pd_detail t
                       SET t.pdd_value = xx.x_sum
                     WHERE t.pdd_id = l_pdd_id;
                ELSE
                    INSERT INTO pd_detail (pdd_pdp,
                                           pdd_value,
                                           pdd_key,
                                           pdd_ndp,
                                           pdd_npt,
                                           pdd_start_dt,
                                           pdd_stop_dt,
                                           pdd_row_order,
                                           pdd_row_name)
                             VALUES (
                                        l_new_pdp,
                                        xx.x_sum,
                                        xx.x_id,
                                        290,
                                        l_row.pdp_npt,
                                        l_row.pdp_start_dt,
                                        l_row.pdp_stop_dt,
                                        xx.rn,
                                           '&63#'
                                        || xx.x_pib
                                        || '#'
                                        || TO_CHAR (
                                               TO_DATE (xx.x_bdt,
                                                        c_Xml_Dt_Fmt),
                                               'DD.MM.YYYY'));
                END IF;
            END LOOP;
        END IF;

        SELECT COUNT (*)
          INTO l_cnt
          FROM pd_payment
         WHERE     pdp_pd = l_row.pdp_pd
               AND history_status = 'A'
               AND pdp_npt = l_row.pdp_npt
               AND l_row.pdp_start_dt BETWEEN pdp_start_dt AND pdp_stop_dt;

        IF l_cnt > 1
        THEN
            raise_application_error (
                -20000,
                'Під час збереження призначеного виявлено помилку дублювання, оновіть форму та спробуйте ще раз!');
        END IF;
    END;

    -- #86328
    PROCEDURE delete_mg_detail (p_pdd_id IN NUMBER)
    IS
        l_check   NUMBER;
    BEGIN
        SELECT CASE
                   WHEN     p.pd_src = 'MG'
                        AND p.pd_nst IN (248,
                                         265,
                                         268,
                                         269)
                        AND d.pdd_value = 0
                   THEN
                       1
                   ELSE
                       0
               END
          INTO l_check
          FROM pd_payment  t
               JOIN pd_detail d ON (d.pdd_pdp = t.pdp_id)
               JOIN pc_decision p ON (p.pd_id = t.pdp_pd)
         WHERE d.pdd_id = p_pdd_id;

        IF (l_check = 0)
        THEN
            raise_application_error (
                -20000,
                'Неможливо видалити деталь! одна з умов не виконується.');
        END IF;

        DELETE pd_detail t
         WHERE t.pdd_id = p_pdd_id;
    END;


    -- #84435
    PROCEDURE get_acd_sums_to_manipulate (
        p_pd_id          pc_decision.pd_id%TYPE,
        p_acd_data   OUT SYS_REFCURSOR)
    IS
    BEGIN
        api$accrual.get_acd_sums_to_manipulate (p_pd_id, p_acd_data);
    END;

    -- #84435
    PROCEDURE manipulate_with_acd (p_pc_id          personalcase.pc_id%TYPE,
                                   p_pd_id          pc_decision.pd_id%TYPE,
                                   p_month          ac_detail.acd_start_dt%TYPE,
                                   p_sum            ac_detail.acd_sum%TYPE,
                                   p_acd_ids_list   VARCHAR2,
                                   p_decision       VARCHAR2)
    IS
    BEGIN
        api$accrual.manipulate_with_acd (p_pc_id,
                                         p_pd_id,
                                         p_month,
                                         p_sum,
                                         p_acd_ids_list,
                                         p_decision);
    END;

    -- #92823
    PROCEDURE change_block_reason (p_pd_id IN NUMBER, p_pcb_id IN NUMBER)
    IS
        l_flag     NUMBER;
        l_pay_tp   VARCHAR2 (10);
        l_rnp_id   NUMBER;
        l_pnp_tp   uss_ndi.v_ndi_reason_not_pay.rnp_pnp_tp%TYPE;
    BEGIN
        SELECT CASE
                   WHEN b.pcb_lock_pnp_tp = 'CPX' AND d.pd_st = 'PS' THEN 1
                   ELSE 0
               END
          INTO l_flag
          FROM v_pc_block b JOIN v_pc_decision d ON (d.pd_id = b.pcb_pd)
         WHERE b.pcb_id = p_pcb_id;

        IF (l_flag = 0)
        THEN
            raise_application_error (
                -20000,
                'Спроба змінити причину блокування для рішення не в стані "призупинене" та з типом причине не "без відновлення"');
        END IF;

        SELECT t.rnp_id, b.pcb_rnp, rnp_pnp_tp
          INTO l_rnp_id, l_flag, l_pnp_tp
          FROM uss_ndi.v_ndi_reason_not_pay  t
               JOIN v_pd_pay_method m
                   ON (    m.pdm_pd = p_pd_id
                       AND m.pdm_is_actual = 'T'
                       AND m.history_status = 'A')
               JOIN v_pc_block b ON (b.pcb_id = p_pcb_id)
         WHERE     t.rnp_code = 'PC'
               AND t.rnp_class = 'PAY'
               AND t.history_status = 'A'
               AND m.pdm_pay_tp = t.rnp_pay_tp;

        UPDATE pc_block t
           SET t.pcb_rnp = l_rnp_id, t.pcb_lock_pnp_tp = l_pnp_tp
         WHERE t.pcb_id = p_pcb_id;

        INSERT INTO pd_log (pdl_pd,
                            pdl_hs,
                            pdl_message,
                            pdl_tp)
             VALUES (p_pd_id,
                     tools.GetHistSession,
                     '&259#@4@' || l_flag,
                     'SYS');
    END;

    -- #94945: список послуг звернення
    PROCEDURE get_appeal_services (p_ap_id   IN     NUMBER,
                                   res_cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT t.*, s.nst_name AS aps_nst_name
              FROM ap_service  t
                   JOIN uss_ndi.v_ndi_service_type s
                       ON (s.nst_id = t.aps_nst)
             WHERE t.aps_ap = p_ap_id AND t.history_status = 'A';
    END;

    -- #94945: список особових рахунків звернення
    PROCEDURE get_appeal_pc_acc (p_ap_id   IN     NUMBER,
                                 res_cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT t.*
              FROM pc_account t JOIN appeal p ON (p.ap_pc = t.pa_pc)
             WHERE     p.ap_id = p_ap_id
                   AND t.pa_nst != 732
                   AND (   (    p.ap_tp = 'V'
                            AND EXISTS
                                    (SELECT 1
                                       FROM ap_service s
                                      WHERE     aps_ap = ap_id
                                            AND s.aps_nst = t.pa_nst
                                            AND s.history_status = 'A'))
                        OR (    p.ap_tp = 'O'
                            AND EXISTS
                                    (SELECT 1
                                       FROM ap_service s
                                      WHERE     aps_ap = ap_id
                                            AND s.aps_nst IN (641, 1161) -- #107057: + 1161
                                            AND s.history_status = 'A'))
                        OR (    p.ap_tp = 'O'
                            AND pa_nst IN
                                    (api$appeal.Get_Ap_Doc_Str (ap_id,
                                                                'O',
                                                                2191),
                                     api$appeal.Get_Ap_Doc_Str (ap_id,
                                                                'O',
                                                                2262),
                                     api$appeal.Get_Ap_Doc_Str (ap_id,
                                                                'O',
                                                                2260)))
                        OR (p.ap_tp = 'U' AND pa_nst IN (248)));
    /*      SELECT t.*
            FROM v_pc_account t
            JOIN v_appeal p ON (p.ap_pc = t.pa_pc)
           WHERE p.ap_id = p_ap_id
             AND t.pa_nst != 732;*/

    END;

    -- #95765
    PROCEDURE get_pdf_payments (p_pd_id   IN     NUMBER,
                                p_dt      IN     DATE,
                                res_cur      OUT SYS_REFCURSOR)
    IS
        l_dt   DATE := p_dt;
    BEGIN
        /* SELECT MAX(pdap_stop_dt + 1)
           INTO l_dt
           FROM pd_accrual_period pp
          WHERE pdap_pd = p_pd_id
            AND pp.history_status = 'A'
        ;  */

        OPEN res_cur FOR
            SELECT *
              FROM (SELECT t.pdf_id,
                           uss_person.api$sc_tools.GET_PIB (t.pdf_sc)
                               AS pdf_pib,
                           p.pdd_id,
                           p.pdd_value,
                           1
                               AS pdd_op,
                           --first_value(pp.pdp_start_dt) OVER (ORDER BY pp.pdp_start_dt DESC) AS max_dt,
                           --pp.pdp_start_dt,
                           pp.pdp_start_dt
                               AS pdd_start_dt,
                           pp.pdp_stop_dt
                               AS pdd_stop_dt
                      FROM pc_decision  d
                           JOIN pd_family t ON (t.pdf_pd = d.pd_id)
                           JOIN pd_detail p
                               ON (    p.pdd_key = t.pdf_id
                                   AND pdd_ndp =
                                       CASE
                                           WHEN pd_ap < 0 THEN 290
                                           ELSE 300
                                       END)
                           JOIN pd_payment pp ON (pp.pdp_id = p.pdd_pdp)
                     WHERE     d.pd_id = p_pd_id
                           AND pp.history_status = 'A'
                           AND l_dt < pp.pdp_stop_dt           --p.pdd_stop_dt
                                                    );
    --WHERE max_dt = pdp_start_dt;
    END;

    -- #96664: Перерахунок з 01.01.2024
    PROCEDURE recalc_pd_2024 (p_pd_id IN NUMBER, msg_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        API$PC_DECISION.write_pd_log (
            p_pd_Id,
            NULL,
            'S',
            CHR (38) || '269' || '#' || TO_DATE ('01.01.2024', 'DD.MM.YYYY'),
            '');
        api$calc_pd.calc_pd_RC (p_pd_id,
                                'RC.START_DT',
                                TO_DATE ('01.01.2024', 'DD.MM.YYYY'),
                                msg_cur);
    END;

    -- #114433: Перерахунок з 01.01.2025
    PROCEDURE recalc_pd_2025 (p_pd_id IN NUMBER, msg_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        API$PC_DECISION.write_pd_log (
            p_pd_Id,
            NULL,
            'S',
            CHR (38) || '269' || '#' || TO_DATE ('01.01.2025', 'DD.MM.YYYY'),
            '');
        api$calc_pd.calc_pd_RC (p_pd_id,
                                'RC.START_DT',
                                TO_DATE ('01.01.2025', 'DD.MM.YYYY'),
                                msg_cur);
    END;

    -- #97206
    PROCEDURE register_transmission (p_ap_id IN NUMBER)
    IS
    BEGIN
        --API$PC_DECISION.write_pd_log(p_pd_Id, NULL, 'S', CHR(38)||'269'||'#'||to_date('01.01.2024', 'DD.MM.YYYY'), '');
        API$PC_ATTESTAT.Registr_Transmission (p_ap_id);
    END;

    -- #100803 Необхідно надати можливість поновлювати призначені суми тим, кому допомога була обнулена по перерахунку з типом S_VPO_51
    PROCEDURE restore_payment_detail (p_pdd_id   IN NUMBER,
                                      p_reason   IN VARCHAR2,
                                      p_op       IN VARCHAR2)
    IS
    BEGIN
        API$PC_DECISION.restore_payment_detail (p_pdd_id, p_reason, p_op);
    --    raise_application_error(-20000, 'p_pdd_id='||p_pdd_id||';p_reason='||p_reason||';p_op='||p_op);
    END;
BEGIN
    NULL;
END DNET$PAY_ASSIGNMENTS;
/