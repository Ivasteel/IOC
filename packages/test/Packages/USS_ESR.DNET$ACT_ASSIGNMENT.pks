/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$ACT_ASSIGNMENT
IS
    -- Author  : BOGDAN
    -- Created : 07.07.2023 12:05:27
    -- Purpose : інтерфейс актів для СП

    Package_Name            VARCHAR2 (50) := 'DNET$ACT_ASSIGNMENT';

    g_at_id                 act.at_id%TYPE;
    g_message               ap_log.apl_message%TYPE;

    c_Xml_Dt_Fmt   CONSTANT VARCHAR2 (30) := 'YYYY-MM-DD"T"HH24:MI:SS';

    TYPE r_at_features IS RECORD
    (
        atf_id            at_features.atf_id%TYPE,
        atf_at            at_features.atf_at%TYPE,
        atf_nft           at_features.atf_nft%TYPE,
        atf_atp           at_features.atf_atp%TYPE,
        atf_val_int       at_features.atf_val_int%TYPE,
        atf_val_sum       at_features.atf_val_sum%TYPE,
        atf_val_id        at_features.atf_val_id%TYPE,
        atf_val_dt        at_features.atf_val_dt%TYPE,
        atf_val_string    at_features.atf_val_string%TYPE,
        New_Id            NUMBER,
        Deleted           NUMBER
    );

    TYPE t_at_features IS TABLE OF r_at_features;

    -- Перевірка права
    TYPE r_At_Right_Log IS RECORD
    (
        Arl_Id             At_Right_Log.Arl_id%TYPE,
        Arl_Nrr            At_Right_Log.Arl_Nrr%TYPE,
        Arl_Calc_Result    At_Right_Log.Arl_Calc_Result%TYPE,
        Arl_Result         At_Right_Log.Arl_Result%TYPE,
        Arl_Ats            At_Right_Log.Arl_Ats%TYPE
    );

    TYPE t_At_Right_Log IS TABLE OF r_At_Right_Log;

    -- Розрахунок доходу
    TYPE r_at_income_src IS RECORD
    (
        ais_id           at_income_src.ais_id%TYPE,
        ais_src          at_income_src.ais_src%TYPE,
        ais_tp           at_income_src.ais_tp%TYPE,
        ais_final_sum    at_income_src.ais_final_sum%TYPE,
        ais_esv_paid     at_income_src.ais_esv_paid%TYPE,
        ais_esv_min      at_income_src.ais_esv_min%TYPE,
        ais_start_dt     VARCHAR2 (30),
        ais_stop_dt      VARCHAR2 (30),
        ais_app          at_income_src.ais_app%TYPE,
        ais_sc           at_income_src.ais_sc%TYPE,
        ais_is_use       at_income_src.ais_is_use%TYPE,
        deleted          NUMBER
    );

    TYPE t_at_income_src IS TABLE OF r_at_income_src;


    -- Рішення про відмову
    TYPE r_at_reject_info IS RECORD
    (
        ari_id     at_reject_info.ari_id%TYPE,
        ari_nrr    at_reject_info.ari_nrr%TYPE,
        ari_njr    at_reject_info.ari_njr%TYPE
    );

    TYPE t_at_reject_info IS TABLE OF r_at_reject_info;

    -- Секція акту потреб
    TYPE r_at_section IS RECORD
    (
        Ate_Id             at_section.ate_id%TYPE,
        Ate_Atp            at_section.ate_atp%TYPE,
        Ate_At             at_section.ate_at%TYPE,
        Ate_Nng            at_section.ate_nng%TYPE,
        Ate_Chield_Info    at_section.ate_chield_info%TYPE,
        Ate_Parent_Info    at_section.ate_parent_info%TYPE,
        Ate_Notes          at_section.ate_notes%TYPE,
        Features           XMLTYPE
    );

    TYPE t_at_section IS TABLE OF r_at_section;

    -- Фічі Секції акту потреб
    TYPE r_at_section_feature IS RECORD
    (
        atef_id         at_section_feature.atef_id%TYPE,
        atef_ate        at_section_feature.atef_ate%TYPE,
        atef_at         at_section_feature.atef_at%TYPE,
        atef_nda        at_section_feature.atef_nda%TYPE,
        atef_feature    at_section_feature.atef_feature%TYPE,
        atef_notes      at_section_feature.atef_notes%TYPE
    );

    TYPE t_at_section_feature IS TABLE OF r_at_section_feature;

    -- Фічі Секції акту потреб
    TYPE r_at_other_spec IS RECORD
    (
        Atop_Id          AT_OTHER_SPEC.Atop_ID%TYPE,
        Atop_At          AT_OTHER_SPEC.Atop_AT%TYPE,
        Atop_Fn          AT_OTHER_SPEC.Atop_FN%TYPE,
        Atop_Mn          AT_OTHER_SPEC.Atop_MN%TYPE,
        Atop_Ln          AT_OTHER_SPEC.Atop_LN%TYPE,
        Atop_Phone       AT_OTHER_SPEC.Atop_PHONE%TYPE,
        Atop_Atip        AT_OTHER_SPEC.Atop_ATIP%TYPE,
        Atop_Position    AT_OTHER_SPEC.ATOP_POSITION%TYPE,
        Atop_Tp          AT_OTHER_SPEC.ATOP_TP%TYPE
    );

    TYPE t_at_other_spec IS TABLE OF r_at_other_spec;


    PROCEDURE GET_QUEUE (p_start_dt       IN     DATE,
                         p_stop_dt        IN     DATE,
                         p_org_id         IN     NUMBER,
                         p_aps_nst        IN     NUMBER,
                         p_ap_is_second   IN     VARCHAR2,
                         p_is_oblastj     IN     VARCHAR2,
                         p_is_internat    IN     VARCHAR2,
                         res_cur             OUT SYS_REFCURSOR);

    -- #102223
    PROCEDURE GET_QUICK_START_QUEUE (P_START_DT   IN     DATE,
                                     P_STOP_DT    IN     DATE,
                                     P_ORG_ID     IN     NUMBER,
                                     P_APS_NST    IN     NUMBER,
                                     RES_CUR         OUT SYS_REFCURSOR);

    PROCEDURE get_act_journal (p_ap_id             IN     NUMBER,
                               p_pc_num            IN     VARCHAR2,
                               p_at_nst            IN     NUMBER,
                               P_AT_ST             IN     VARCHAR2,
                               p_org_id            IN     NUMBER,
                               p_ap_reg_dt_start   IN     DATE,
                               p_ap_reg_dt_stop    IN     DATE,
                               p_at_dt_start       IN     DATE,
                               p_at_dt_stop        IN     DATE,
                               p_at_num            IN     VARCHAR2,
                               p_ap_num            IN     VARCHAR2,
                               p_app_ln            IN     VARCHAR2,
                               p_app_fn            IN     VARCHAR2,
                               p_app_mn            IN     VARCHAR2,
                               p_scd_ser_num       IN     VARCHAR2,
                               p_numident          IN     VARCHAR2,
                               p_mode              IN     VARCHAR2,
                               p_At_Tp             IN     VARCHAR2,
                               p_is_emergency      IN     VARCHAR2,
                               p_ats_ss_method     IN     VARCHAR2,
                               info_cur               OUT SYS_REFCURSOR,
                               act_cur                OUT SYS_REFCURSOR);

    -- #102223: «Всі звернення»
    PROCEDURE get_all_appeals (p_start_Dt       IN     DATE,
                               p_stop_Dt        IN     DATE,
                               p_nst_Id         IN     NUMBER,
                               p_ap_num         IN     VARCHAR2,
                               p_ap_st          IN     VARCHAR2,
                               p_is_rejected    IN     VARCHAR2,
                               p_correct_tp     IN     VARCHAR2,
                               /*p_kaot_id IN NUMBER,
                               p_index IN VARCHAR2,
                               p_street IN VARCHAR2,
                               p_building IN VARCHAR2,
                               p_korp IN VARCHAR2,
                               p_appartment IN VARCHAR2,*/
                               p_is_emergency   IN     VARCHAR2,
                               res_cur             OUT SYS_REFCURSOR);

    -- ініціалізація акту
    PROCEDURE INIT_ACT_CARD (P_AP_ID IN NUMBER, MSG_CUR OUT SYS_REFCURSOR);

    PROCEDURE INIT_ACT_CARD (P_AP_ID         IN     NUMBER,
                             P_AP_SERVICES   IN     CLOB,
                             MSG_CUR            OUT SYS_REFCURSOR);

    -- ініціалізація акту для швидкого старту
    PROCEDURE INIT_QUICK_START_ACT (P_AP_ID        IN     NUMBER,
                                    p_rnspm_id     IN     NUMBER,
                                    p_rnspm_name   IN     VARCHAR2,
                                    MSG_CUR           OUT SYS_REFCURSOR);

    -- "Повернути на довведення" звернення
    PROCEDURE RETURN_APPEAL (P_AP_ID IN NUMBER, p_reason IN VARCHAR2:= NULL);

    PROCEDURE get_act_card (p_at_id IN NUMBER, act_cur OUT SYS_REFCURSOR);


    FUNCTION Get_IsNeed_Income (p_at_id NUMBER)
        RETURN NUMBER;

    FUNCTION Get_Is_Block_Approve (p_at_id NUMBER)
        RETURN NUMBER;

    FUNCTION Get_Is_Block_Sign (p_at_id NUMBER)
        RETURN NUMBER;

    FUNCTION Get_Is_Block_Approve_4rej (p_at_id NUMBER)
        RETURN NUMBER;

    FUNCTION GET_IS_BLOCK_SIGN_4REJ (P_AT_ID NUMBER)
        RETURN NUMBER;

    FUNCTION get_right_block_flag (p_at_id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION is_emergency (p_ap_id IN NUMBER)
        RETURN NUMBER;

    -- Протокол обробки акту
    PROCEDURE GET_ACT_LOG (P_AT_ID IN NUMBER, RES_CUR OUT SYS_REFCURSOR);

    ------------------------------------------------------------------------
    --------------------------- Визначення права ---------------------------

    -- #70334: дані форми визначення права
    PROCEDURE GET_ACT_RIGHTS (p_at_id IN NUMBER, RES_CUR OUT SYS_REFCURSOR);

    PROCEDURE INIT_ACT_RIGHTS (p_at_id          act.at_id%TYPE,
                               p_messages   OUT SYS_REFCURSOR);

    -- #70334: збереження форми визначення права
    PROCEDURE SAVE_ACT_RIGHTS (p_at_id   IN NUMBER,
                               P_at_st   IN VARCHAR2,
                               P_CLOB    IN CLOB);


    -------------------------------------------------------------------------------
    --------------------------- Рішення про призначення ---------------------------

    PROCEDURE GET_ACT_ASSIGNMENT (p_at_id     IN     NUMBER,
                                  FEAT_CUR       OUT SYS_REFCURSOR,
                                  flags_cur      OUT SYS_REFCURSOR,
                                  doc_cur        OUT SYS_REFCURSOR,
                                  ATTR_CUR       OUT SYS_REFCURSOR,
                                  file_cur       OUT SYS_REFCURSOR,
                                  Serv_Cur       OUT SYS_REFCURSOR);

    PROCEDURE get_act_services (p_at_id IN NUMBER, res_cur OUT SYS_REFCURSOR);

    PROCEDURE GET_NEED_DOCS (p_at_id     IN     NUMBER,
                             flags_cur      OUT SYS_REFCURSOR,
                             doc_cur        OUT SYS_REFCURSOR,
                             ATTR_CUR       OUT SYS_REFCURSOR,
                             file_cur       OUT SYS_REFCURSOR);

    -- "затвердити виплати"
    PROCEDURE APPROVE_ACT (P_AT_ID IN NUMBER, P_AT_ST IN VARCHAR2);

    -- налаштування ознак виплат
    PROCEDURE GET_ACT_FEATURES_METADATA (RES_CUR OUT SYS_REFCURSOR);

    PROCEDURE SAVE_Features (P_AT_ID IN NUMBER, P_CLOB IN CLOB);

    -- Поверенення проекту акту на доопрацювання
    PROCEDURE return_act (p_at_id    IN act.at_id%TYPE,
                          p_reason   IN VARCHAR2,
                          p_at_st    IN VARCHAR2);

    -------------------------------------------------------------------------------
    --------------------------- розрахунку доходу ---------------------------

    -- вичитка форми "розрахунку доходу"
    PROCEDURE GET_ACT_INCOMES (P_AT_ID    IN     NUMBER,
                               INFO_CUR      OUT SYS_REFCURSOR,
                               PERS_CUR      OUT SYS_REFCURSOR,
                               DET_CUR       OUT SYS_REFCURSOR);


    PROCEDURE SAVE_ACT_INCOMES (P_AT_ID   IN     NUMBER,
                                P_CLOB    IN     CLOB,
                                MSG_CUR      OUT SYS_REFCURSOR);

    -- вичитка форми "Дані помісячного розрахунку"
    PROCEDURE GET_PERSON_INFO (P_AIC_ID   IN     NUMBER,
                               P_APP_ID   IN     NUMBER,
                               RES_CUR       OUT SYS_REFCURSOR,
                               LOG_CUR       OUT SYS_REFCURSOR);


    ---------------------------------------------------------------------------
    --------------------------- Рішення про відмову ---------------------------

    -- #70334: дані форми "Рішення про відмову"
    PROCEDURE GET_ACT_REJECTS (P_AT_ID IN NUMBER, RES_CUR OUT SYS_REFCURSOR);

    -- #70334: збереження форми "Рішення про відмову"
    PROCEDURE SAVE_ACT_REJECTS (P_AT_ID IN NUMBER, P_CLOB IN CLOB);

    -- #70334: підтвердження форми "Рішення про відмову"
    PROCEDURE PROVE_ACT_REJECTS (P_AT_ID     IN     NUMBER,
                                 P_ST           OUT VARCHAR2,
                                 P_ST_NAME      OUT VARCHAR2);

    -- #71916: Повернути рішення про відмову
    PROCEDURE REJECT_ACT_REJECT (P_AT_ID     IN     NUMBER,
                                 P_ST           OUT VARCHAR2,
                                 P_ST_NAME      OUT VARCHAR2);

    ----------------------------------------------------------------------
    --------------------------- Документи акту ---------------------------


    -- Документи акту
    PROCEDURE get_ss_docs (p_at_id    IN     NUMBER,
                           p_mode     IN     NUMBER, -- 0 - призначення, 1 - відхилення
                           p_flag        OUT NUMBER,
                           doc_cur       OUT SYS_REFCURSOR,
                           attr_cur      OUT SYS_REFCURSOR,
                           file_cur      OUT SYS_REFCURSOR,
                           sign_cur      OUT SYS_REFCURSOR);

    -- Документи зовнішні
    PROCEDURE GET_SECONDARY_DOCS (P_AT_ID    IN     NUMBER,
                                  P_MODE     IN     NUMBER, -- 2 - «Вторинна оцінка потреб», 3 - «Документи договору»
                                  DOC_CUR       OUT SYS_REFCURSOR,
                                  ATTR_CUR      OUT SYS_REFCURSOR,
                                  FILE_CUR      OUT SYS_REFCURSOR,
                                  SIGN_CUR      OUT SYS_REFCURSOR);

    -- #91319: Список документів які можна створити
    PROCEDURE get_doc_tp_list (P_AT_ID IN NUMBER, res_cur OUT SYS_REFCURSOR);


    -- #89729: Список документів які можна створити
    -- Підписання SS-рішень про відмову в наданні СП
    PROCEDURE get_rej_doc_tp_list (p_at_id   IN     NUMBER,
                                   res_cur      OUT SYS_REFCURSOR);


    PROCEDURE Register_Doc_Hist (p_Doc_Id NUMBER, p_Dh_Id OUT NUMBER);

    PROCEDURE delete_document (p_atd_id IN NUMBER);



    -- #90626
    PROCEDURE GET_ASSESSMENT_NEED_DOC (P_AT_ID    IN     NUMBER,
                                       PERS_CUR      OUT SYS_REFCURSOR,
                                       SECT_CUR      OUT SYS_REFCURSOR,
                                       FEAT_CUR      OUT SYS_REFCURSOR,
                                       SPEC_CUR      OUT SYS_REFCURSOR,
                                       MAIN_CUR      OUT SYS_REFCURSOR);

    PROCEDURE SAVE_ASSESSMENT_NEED_DOC (P_AT_ID           IN NUMBER,
                                        P_SECTION_XML     IN CLOB,
                                        P_SPEC_XML        IN CLOB,
                                        P_AT_CASE_CLASS   IN VARCHAR2);

    -- info: налаштування фіч секцій
    -- params:
    -- note:
    PROCEDURE Get_Ass_Nda_List (p_Nda_Cur OUT SYS_REFCURSOR);

    ---------------------------------------------------------------------
    --                   Налаштування Секцій
    ---------------------------------------------------------------------
    PROCEDURE Get_Ass_Nng_List (p_Nng_Cur OUT SYS_REFCURSOR);


    -- #89467: список послуг звернення
    PROCEDURE appeal_services (p_ap_id IN NUMBER, res_cur OUT SYS_REFCURSOR);

    -- #105150
    PROCEDURE create_act_rejected (p_at_id IN NUMBER);
END DNET$ACT_ASSIGNMENT;
/


GRANT EXECUTE ON USS_ESR.DNET$ACT_ASSIGNMENT TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$ACT_ASSIGNMENT TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$ACT_ASSIGNMENT
IS
    -- перевірка на консистентність даних
    PROCEDURE CHECK_CONSISTENSY (P_AT_ID IN NUMBER, P_AT_ST IN VARCHAR2)
    IS
        L_ST   VARCHAR2 (10);
    BEGIN
        SELECT AT_ST
          INTO L_ST
          FROM ACT T
         WHERE T.AT_ID = P_AT_ID;

        IF (L_ST != P_AT_ST OR P_AT_ST IS NULL)
        THEN
            RAISE_APPLICATION_ERROR (
                -20000,
                'Дану операцію неможливо завершити. Дані застарілі. Оновіть сторінку і спробуйте знову.');
        END IF;
    END;

    -- TODO: поправити пошук
    PROCEDURE GET_QUEUE (P_START_DT       IN     DATE,
                         P_STOP_DT        IN     DATE,
                         P_ORG_ID         IN     NUMBER,
                         P_APS_NST        IN     NUMBER,
                         P_AP_IS_SECOND   IN     VARCHAR2,
                         P_IS_OBLASTJ     IN     VARCHAR2,
                         P_IS_INTERNAT    IN     VARCHAR2,
                         RES_CUR             OUT SYS_REFCURSOR)
    IS
        L_ORG_ID   NUMBER := TOOLS.GETCURRORG;
        L_ORG_TO   NUMBER := TOOLS.GETCURRORGTO;
    BEGIN
        --raise_application_error(-20000, '  p_start_dt='||p_start_dt||'  p_stop_dt='||p_stop_dt||'  l_org_to='||l_org_to||'  p_is_oblastj='||p_is_oblastj);
        TOOLS.WRITEMSG ('DNET$ACT_ASSIGNMENT.GET_QUEUE');

        OPEN RES_CUR FOR
            SELECT T.*,
                   (SELECT DIC_SNAME
                      FROM USS_NDI.V_DDN_AP_ST Z
                     WHERE Z.DIC_VALUE = T.AP_ST)
                       AS AP_ST_NAME,
                   USS_PERSON.API$SC_TOOLS.GET_PIB_SCC (APP.APP_SCC)
                       AS APP_MAIN_PIB,
                   TOOLS.GET_MAIN_ADDR_SS (T.AP_ID, T.AP_TP, PC.PC_SC)
                       AS APP_MAIN_ADDRESS,
                   (SELECT LISTAGG (ST.NST_CODE || '-' || NST_NAME,
                                    ', ' || CHR (13) || CHR (10))
                           WITHIN GROUP (ORDER BY ST.NST_ORDER)
                      FROM V_AP_SERVICE  Z
                           JOIN USS_NDI.V_NDI_SERVICE_TYPE ST
                               ON (ST.NST_ID = Z.APS_NST)
                     WHERE Z.APS_AP = T.AP_ID --rownum < 4
                                              AND Z.HISTORY_STATUS = 'A')
                       AS APS_LIST,
                   (CASE
                        WHEN EXISTS
                                 (SELECT A.APDA_ID
                                    FROM AP_DOCUMENT_ATTR  A
                                         JOIN AP_DOCUMENT D
                                             ON A.APDA_APD = D.APD_ID
                                   WHERE     A.APDA_AP = T.AP_ID
                                         AND (   (    D.APD_NDT = 801
                                                  AND A.APDA_NDA = 1870)
                                              OR (    D.APD_NDT = 802
                                                  AND A.APDA_NDA = 1947)
                                              OR (    D.APD_NDT = 803
                                                  AND A.APDA_NDA = 2032))
                                         AND A.APDA_VAL_STRING = 'T')
                        THEN
                            1
                        ELSE
                            0
                    END)
                       AS IS_EMERGENCY
              FROM USS_ESR.V_APPEAL  T
                   LEFT OUTER JOIN V_PERSONALCASE PC ON (PC.PC_ID = T.AP_PC)
                   LEFT OUTER JOIN AP_PERSON APP
                       ON     APP.APP_SC = PC.PC_SC
                          AND APP.APP_AP = T.AP_ID
                          AND APP.HISTORY_STATUS = 'A'
             WHERE     1 = 1
                   AND AP_TP IN ('SS')
                   AND TRUNC (T.AP_REG_DT) BETWEEN P_START_DT AND P_STOP_DT
                   AND (   (    P_IS_OBLASTJ = 'T'     /* AND T.AP_ST = 'WD'*/
                            AND EXISTS
                                    (SELECT 1
                                       FROM ACT  DC
                                            LEFT JOIN AT_FEATURES ZF
                                                ON (    ZF.ATF_AT = DC.AT_ID
                                                    AND ZF.ATF_NFT = 32)
                                      WHERE     DC.AT_AP = T.AP_ID
                                            AND DC.AT_ST = 'O.SO'
                                            AND ZF.ATF_VAL_STRING =
                                                P_IS_INTERNAT)
                            AND T.COM_ORG IN
                                    (    SELECT T.ORG_ID
                                           FROM V_OPFU T
                                          WHERE T.ORG_ST = 'A'
                                     CONNECT BY PRIOR T.ORG_ID = T.ORG_ORG
                                     START WITH T.ORG_ID = L_ORG_ID)
                            AND (P_ORG_ID IS NULL OR T.COM_ORG = P_ORG_ID))
                        OR (    P_IS_OBLASTJ = 'F'
                            AND T.AP_ST = 'O'
                            AND T.COM_ORG = L_ORG_ID))
                   AND (   P_APS_NST IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM V_AP_SERVICE Z
                                 WHERE     Z.APS_AP = T.AP_ID
                                       AND Z.APS_NST = P_APS_NST
                                       AND Z.HISTORY_STATUS = 'A'))
                   AND (   P_AP_IS_SECOND IS NULL
                        OR P_AP_IS_SECOND = 'F'
                        OR T.AP_IS_SECOND = 'T')
                   AND API$APPEAL.Is_Appeal_Maked_Correct (t.ap_id) = 1/* AND EXISTS (SELECT *
                                                                                      FROM ap_document_attr a
                                                                                     WHERE a.apda_ap = t.ap_id
                                                                                       AND a.apda_nda IN (8415, 8416, 8417, 8418, 8419)
                                                                                       AND NVL(a.apda_val_string,'T') = 'T')*/

                                                                       ;
    --raise_application_error(-20000, 'res_cur.count'||res_cur%ROWCOUNT);
    END;

    -- #102223: «Черга звернень на первинну оцінку потреб»
    PROCEDURE GET_QUICK_START_QUEUE (P_START_DT   IN     DATE,
                                     P_STOP_DT    IN     DATE,
                                     P_ORG_ID     IN     NUMBER,
                                     P_APS_NST    IN     NUMBER,
                                     RES_CUR         OUT SYS_REFCURSOR)
    IS
        L_ORG_ID   NUMBER := TOOLS.GETCURRORG;
        L_ORG_TO   NUMBER := TOOLS.GETCURRORGTO;
    BEGIN
        --raise_application_error(-20000, '  p_start_dt='||p_start_dt||'  p_stop_dt='||p_stop_dt||'  l_org_to='||l_org_to||'  p_is_oblastj='||p_is_oblastj);
        TOOLS.WRITEMSG ('DNET$ACT_ASSIGNMENT.GET_QUICK_START_QUEUE');


        OPEN RES_CUR FOR
            SELECT T.*,
                   (SELECT DIC_SNAME
                      FROM USS_NDI.V_DDN_AP_ST Z
                     WHERE Z.DIC_VALUE = T.AP_ST)
                       AS AP_ST_NAME,
                   (SELECT MAX (
                               CASE
                                   WHEN APP.APP_SCC IS NOT NULL
                                   THEN
                                       USS_PERSON.API$SC_TOOLS.GET_PIB_SCC (
                                           APP.APP_SCC)
                                   ELSE
                                          uss_visit.api$find.get_app_column (
                                              app.app_id,
                                              'app_ln')
                                       || ' '
                                       || uss_visit.api$find.get_app_column (
                                              app.app_id,
                                              'app_fn')
                                       || ' '
                                       || uss_visit.api$find.get_app_column (
                                              app.app_id,
                                              'app_mn')
                               END)
                      FROM AP_PERSON APP
                     WHERE     (   APP.APP_SC = PC.PC_SC
                                OR     PC.PC_SC IS NULL
                                   AND app.app_tp IN ('Z', 'OS'))
                           AND APP.APP_AP = T.AP_ID
                           AND APP.HISTORY_STATUS = 'A'
                     FETCH FIRST ROW ONLY)
                       AS APP_MAIN_PIB,
                   TOOLS.GET_MAIN_ADDR_SS (T.AP_ID, T.AP_TP, PC.PC_SC)
                       AS APP_MAIN_ADDRESS,
                   (SELECT LISTAGG (ST.NST_CODE || '-' || NST_NAME,
                                    ', ' || CHR (13) || CHR (10))
                           WITHIN GROUP (ORDER BY ST.NST_ORDER)
                      FROM V_AP_SERVICE  Z
                           JOIN USS_NDI.V_NDI_SERVICE_TYPE ST
                               ON (ST.NST_ID = Z.APS_NST)
                     WHERE Z.APS_AP = T.AP_ID --rownum < 4
                                              AND Z.HISTORY_STATUS = 'A')
                       AS APS_LIST,
                   (CASE
                        WHEN EXISTS
                                 (SELECT A.APDA_ID
                                    FROM AP_DOCUMENT_ATTR  A
                                         JOIN AP_DOCUMENT D
                                             ON A.APDA_APD = D.APD_ID
                                   WHERE     A.APDA_AP = T.AP_ID
                                         AND (   (    D.APD_NDT = 801
                                                  AND A.APDA_NDA = 1870)
                                              OR (    D.APD_NDT = 802
                                                  AND A.APDA_NDA = 1947)
                                              OR (    D.APD_NDT = 803
                                                  AND A.APDA_NDA = 2032)
                                              OR (    D.APD_NDT = 1015
                                                  AND A.APDA_NDA = 8263))
                                         AND A.APDA_VAL_STRING = 'T')
                        THEN
                            1
                        ELSE
                            0
                    END)
                       AS IS_EMERGENCY,
                   (SELECT MAX (A.APDA_VAL_ID)
                      FROM AP_DOCUMENT_ATTR  A
                           JOIN AP_DOCUMENT D ON A.APDA_APD = D.APD_ID
                     WHERE     A.APDA_AP = T.AP_ID
                           AND (   (D.APD_NDT = 801 AND A.APDA_NDA = 1872)
                                OR (D.APD_NDT = 802 AND A.APDA_NDA = 3689)
                                OR (D.APD_NDT = 835 AND A.APDA_NDA = 3263))
                           AND a.history_status = 'A'
                           AND d.history_status = 'A')
                       AS rnspm_id,
                   (SELECT MAX (A.APDA_VAL_STRING)
                      FROM AP_DOCUMENT_ATTR  A
                           JOIN AP_DOCUMENT D ON A.APDA_APD = D.APD_ID
                     WHERE     A.APDA_AP = T.AP_ID
                           AND (   (D.APD_NDT = 801 AND A.APDA_NDA = 1872)
                                OR (D.APD_NDT = 802 AND A.APDA_NDA = 3689)
                                OR (D.APD_NDT = 835 AND A.APDA_NDA = 3263))
                           AND a.history_status = 'A'
                           AND d.history_status = 'A')
                       AS rnspm_name
              FROM USS_ESR.V_APPEAL  T
                   LEFT JOIN V_PERSONALCASE PC ON (PC.PC_ID = T.AP_PC)
             /*        LEFT JOIN AP_PERSON APP
                       ON ( (APP.APP_SC = PC.PC_SC or PC.PC_SC is null and app.app_tp IN ('Z', 'OS'))
                      AND APP.APP_AP = T.AP_ID
                      AND APP.HISTORY_STATUS = 'A')*/
             WHERE     1 = 1
                   AND AP_TP IN ('SS')
                   AND TRUNC (T.AP_REG_DT) BETWEEN P_START_DT AND P_STOP_DT
                   AND T.AP_ST = 'O'
                   AND T.COM_ORG = L_ORG_ID
                   AND (   P_APS_NST IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM V_AP_SERVICE Z
                                 WHERE     Z.APS_AP = T.AP_ID
                                       AND Z.APS_NST = P_APS_NST
                                       AND Z.HISTORY_STATUS = 'A'))
                   /*
                   AND NOT EXISTS (SELECT *
                                     FROM ap_document_attr a
                                    WHERE a.apda_ap = t.ap_id
                                      AND a.apda_nda IN (8415, 8416, 8417, 8418, 8419)
                                      AND NVL(a.apda_val_string,'T') = 'T')
                   */
                   AND API$APPEAL.Is_Appeal_Maked_Correct (t.ap_id) = 0/* AND (SELECT count(1)
                                                                                         FROM ap_document_attr a
                                                                                        WHERE a.apda_ap = t.ap_id
                                                                                          AND a.apda_nda IN (8415, 8416, 8417, 8418, 8419)
                                                                                          AND NVL(a.apda_val_string,'T') = 'T') > 0*/
                                                                       ;
    --raise_application_error(-20000, 'res_cur.count'||res_cur%ROWCOUNT);
    END;

    PROCEDURE GET_ACT_JOURNAL (P_AP_ID             IN     NUMBER,
                               P_PC_NUM            IN     VARCHAR2,
                               P_AT_NST            IN     NUMBER,
                               P_AT_ST             IN     VARCHAR2,
                               P_ORG_ID            IN     NUMBER,
                               P_AP_REG_DT_START   IN     DATE,
                               P_AP_REG_DT_STOP    IN     DATE,
                               P_AT_DT_START       IN     DATE,
                               P_AT_DT_STOP        IN     DATE,
                               P_AT_NUM            IN     VARCHAR2,
                               P_AP_NUM            IN     VARCHAR2,
                               P_APP_LN            IN     VARCHAR2,
                               P_APP_FN            IN     VARCHAR2,
                               P_APP_MN            IN     VARCHAR2,
                               P_SCD_SER_NUM       IN     VARCHAR2,
                               P_NUMIDENT          IN     VARCHAR2,
                               p_mode              IN     VARCHAR2,
                               p_At_Tp             IN     VARCHAR2,
                               p_is_emergency      IN     VARCHAR2,
                               p_ats_ss_method     IN     VARCHAR2,
                               INFO_CUR               OUT SYS_REFCURSOR,
                               ACT_CUR                OUT SYS_REFCURSOR)
    IS
        L_ORG_ID   NUMBER;
        L_ORG_TO   NUMBER;
    BEGIN
        --raise_application_error(-20000, 'P_AT_ST = '||P_AT_ST);

        TOOLS.WRITEMSG ('DNET$ACT_ASSIGNMENTS.' || $$PLSQL_UNIT);

        L_ORG_ID := TOOLS.GETCURRORG;
        L_ORG_TO := TOOLS.GETCURRORGTO;

        --raise_application_error(-20000, 'l_org_id = '||l_org_id || '   l_org_to = '||l_org_to);

        OPEN INFO_CUR FOR
            SELECT T.*,
                   (SELECT DIC_SNAME
                      FROM USS_NDI.V_DDN_AP_ST Z
                     WHERE Z.DIC_VALUE = T.AP_ST)
                       AS AP_ST_NAME,
                   USS_PERSON.API$SC_TOOLS.GET_PIB_SCC (APP.APP_SCC)
                       AS APP_MAIN_PIB,
                   TOOLS.GET_MAIN_ADDR_SS (T.AP_ID, T.AP_TP, PC.PC_SC)
                       AS APP_MAIN_ADDRESS,
                   (SELECT COUNT (*)
                      FROM ap_service zs
                     WHERE zs.aps_ap = t.ap_id AND zs.history_status = 'A')
                       AS aps_cnt
              FROM USS_ESR.V_APPEAL  T
                   LEFT OUTER JOIN V_PERSONALCASE PC ON (PC.PC_ID = T.AP_PC)
                   LEFT OUTER JOIN AP_PERSON APP
                       ON (    APP.APP_SC = PC.PC_SC
                           AND APP.APP_AP = T.AP_ID
                           AND APP.HISTORY_STATUS = 'A')
             WHERE T.AP_ID = P_AP_ID;

        OPEN ACT_CUR FOR
            SELECT T.*,
                   (SELECT LISTAGG (
                               ZS.NST_CODE || ' ' || ZS.NST_NAME,
                               ', ')
                           WITHIN GROUP (ORDER BY ZS.NST_CODE)
                      FROM AT_SERVICE  Z
                           JOIN USS_NDI.V_NDI_SERVICE_TYPE ZS
                               ON (ZS.NST_ID = Z.ATS_NST)
                     WHERE     Z.ATS_AT = T.AT_ID
                           AND Z.HISTORY_STATUS = 'A')
                       AS AT_NST_LIST_NAME,
                   ST.DIC_SNAME
                       AS AT_ST_NAME,
                   AP.AP_ID,
                   AP.AP_PC,
                   AP.AP_SRC_ID,
                   AP.AP_TP,
                   AP.AP_REG_DT,
                   AP.AP_SRC,
                   AP.AP_ST,
                   AP.AP_IS_SECOND,
                   AP.AP_NUM,
                   AP.AP_VF,
                   (SELECT DIC_SNAME
                      FROM USS_NDI.V_DDN_AP_ST Z
                     WHERE Z.DIC_VALUE = AP.AP_ST)
                       AS AP_ST_NAME,
                   (SELECT MAX (
                               USS_PERSON.API$SC_TOOLS.GET_PIB_SCC (
                                   z.app_scc))
                      FROM v_ap_person z
                     WHERE     z.app_ap = ap.ap_id
                           AND z.app_tp IN ('Z',
                                            'AG',
                                            'OR',
                                            'AF',
                                            'AP'))
                       --USS_PERSON.API$SC_TOOLS.GET_PIB(T.AT_SC)
                       AS APP_MAIN_PIB,
                   USS_PERSON.API$SC_TOOLS.GET_PIB (T.AT_SC)
                       AS at_main_pib,
                   PC.PC_NUM,
                   PC.PC_SC,
                   --src.dic_name AS pd_src_name,
                   (CASE
                        WHEN EXISTS
                                 (SELECT A.APDA_ID
                                    FROM AP_DOCUMENT_ATTR  A
                                         JOIN AP_DOCUMENT D
                                             ON A.APDA_APD = D.APD_ID
                                   WHERE     A.APDA_AP = AP.AP_ID
                                         AND (   (    D.APD_NDT = 801
                                                  AND A.APDA_NDA = 1870)
                                              OR (    D.APD_NDT = 802
                                                  AND A.APDA_NDA = 1947)
                                              OR (    D.APD_NDT = 803
                                                  AND A.APDA_NDA = 2032))
                                         AND A.APDA_VAL_STRING = 'T')
                        THEN
                            1
                        ELSE
                            0
                    END)
                       AS IS_EMERGENCY                              --Екстрено
              FROM V_ACT  T
                   JOIN USS_NDI.V_DDN_AT_PDSP_ST ST
                       ON (ST.DIC_VALUE = T.AT_ST)
                   --JOIN uss_ndi.v_ddn_pd_src src ON (src.DIC_VALUE = t.at_src)
                   JOIN USS_ESR.V_APPEAL AP ON (AP.AP_ID = T.AT_AP)
                   LEFT OUTER JOIN V_PERSONALCASE PC ON (PC.PC_ID = T.AT_PC)
             WHERE     1 = 1
                   AND T.AT_TP = 'PDSP'
                   AND AP.AP_TP = 'SS'
                   AND (   (    L_ORG_TO > 31
                            AND AP.COM_ORG = L_ORG_ID
                            AND t.at_st IN ('SA',
                                            'SC',
                                            'SD',
                                            'SN',
                                            'SP1',
                                            'SP2',
                                            'SI',
                                            'SS',
                                            'SR',
                                            'SV',
                                            'SW',
                                            'W',
                                            'SU',
                                            'SJ',
                                            'SGO',
                                            'SGA',
                                            'SGM',
                                            'SGP',
                                            'SNR'))
                        OR (    L_ORG_TO > 31
                            AND AP.COM_ORG = L_ORG_ID
                            AND p_mode = 'KLOP'
                            AND T.AT_ST IN ('O.SO',
                                            'O.SR',
                                            'O.SW',
                                            'O.SN'))
                        OR (    L_ORG_TO > 31
                            AND AP.COM_ORG = L_ORG_ID
                            AND p_mode IN ('APPOINTED', 'OSZN')
                            AND T.AT_ST IN ('O.SA', 'O.SD'))
                        OR (    L_ORG_TO = 31
                            AND t.at_st IN ('SP2', 'SI', 'SS')
                            AND AP.COM_ORG = L_ORG_ID)
                        OR (    L_ORG_TO = 31
                            AND t.at_st IN ('O.SA',
                                            'O.SD',
                                            'O.SN',
                                            'O.SO',
                                            'O.SR',
                                            'O.SW',
                                            'SU',
                                            'SJ',
                                            'SGO',
                                            'SGA',
                                            'SGM',
                                            'SNR')
                            AND AP.COM_ORG IN
                                    (    SELECT T.ORG_ID
                                           FROM V_OPFU T
                                          WHERE T.ORG_ST = 'A'
                                     CONNECT BY PRIOR T.ORG_ID = T.ORG_ORG
                                     START WITH T.ORG_ID = L_ORG_ID)))
                   AND (P_AT_ST IS NULL OR /* p_at_st = 'PROVIDER' OR
                                            p_at_st = 'PROVIDER_SV' OR
                                            P_AT_ST = 'KLOP' AND T.AT_ST IN ('O.SO', 'O.SR', 'O.SW', 'O.SN') OR
                                            P_AT_ST = 'APPOINTED' AND T.AT_ST IN ('O.SA', 'SA', 'SGO', 'SGA', 'SGM') OR*/
                                           T.AT_ST = P_AT_ST)
                   AND (       p_mode = 'PROVIDER_SV'
                           AND t.at_st = 'SV'
                           AND t.at_org = L_ORG_ID
                        OR     p_mode IN ('APPOINTED')
                           AND t.at_st IN ('SA',
                                           'O.SA',
                                           'SU',
                                           'SJ',
                                           'SGO',
                                           'SGA',
                                           'SGM',
                                           'SNR')
                        OR     p_mode = 'KLOP'
                           AND T.AT_ST IN ('O.SO',
                                           'O.SR',
                                           'O.SW',
                                           'O.SN')
                        OR p_mode = 'WAIT' AND T.AT_ST IN ('SP1', 'SGP')
                        OR     p_mode = 'ALL'
                           AND T.AT_ST IN ('SC',
                                           'SR',
                                           'SW',
                                           'O.SR',
                                           'O.SW')
                        OR     p_mode NOT IN ('PROVIDER_SV',
                                              'APPOINTED',
                                              'KLOP',
                                              'WAIT',
                                              'ALL')
                           AND 1 = 1)
                   AND (P_AP_ID IS NULL OR T.AT_AP = P_AP_ID)
                   AND (P_PC_NUM IS NULL OR pc.pc_num = P_PC_NUM)
                   AND (   P_AT_NST IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM AT_SERVICE Z
                                 WHERE     Z.ATS_AT = T.AT_ID
                                       AND Z.ATS_NST = P_AT_NST
                                       AND Z.HISTORY_STATUS = 'A'))
                   AND (       P_AP_REG_DT_START IS NULL
                           AND P_AP_REG_DT_STOP IS NULL
                        OR     P_AP_REG_DT_START IS NULL
                           AND P_AP_REG_DT_STOP IS NOT NULL
                           AND AP.AP_REG_DT <= P_AP_REG_DT_STOP
                        OR     P_AP_REG_DT_START IS NOT NULL
                           AND P_AP_REG_DT_STOP IS NULL
                           AND AP.AP_REG_DT >= P_AP_REG_DT_START
                        OR AP.AP_REG_DT BETWEEN P_AP_REG_DT_START
                                            AND P_AP_REG_DT_STOP)
                   AND (   P_AT_DT_START IS NULL AND P_AT_DT_STOP IS NULL
                        OR     P_AT_DT_START IS NULL
                           AND P_AT_DT_STOP IS NOT NULL
                           AND T.AT_DT <= P_AT_DT_STOP
                        OR     P_AT_DT_START IS NOT NULL
                           AND P_AT_DT_STOP IS NULL
                           AND T.AT_DT >= P_AT_DT_START
                        OR T.AT_DT BETWEEN P_AT_DT_START AND P_AT_DT_STOP)
                   AND (P_AP_NUM IS NULL OR AP.AP_NUM LIKE P_AP_NUM || '%')
                   AND (P_AT_NUM IS NULL OR T.AT_NUM LIKE P_AT_NUM || '%')
                   AND (       P_APP_LN IS NULL
                           AND P_APP_FN IS NULL
                           AND P_APP_MN IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM V_AP_PERSON  ZZ
                                       JOIN USS_PERSON.V_SOCIALCARD ZS
                                           ON (ZS.SC_ID = ZZ.APP_SC)
                                       JOIN USS_PERSON.V_SC_CHANGE ZCH
                                           ON (ZCH.SCC_ID = ZS.SC_SCC)
                                       JOIN USS_PERSON.V_SC_IDENTITY ZI
                                           ON (ZI.SCI_ID = ZCH.SCC_SCI)
                                 WHERE     ZZ.APP_AP = AP.AP_ID
                                       AND ZZ.APP_TP =
                                           CASE
                                               WHEN AP.AP_TP IN ('U', 'A')
                                               THEN
                                                   'O'
                                               ELSE
                                                   'Z'
                                           END
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
                   AND (   P_SCD_SER_NUM IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM V_AP_PERSON  ZZ
                                       JOIN USS_PERSON.V_SOCIALCARD ZS
                                           ON (ZS.SC_ID = ZZ.APP_SC)
                                       JOIN USS_PERSON.V_SC_DOCUMENT SD
                                           ON (PC.PC_SC = SD.SCD_SC /*AND SD.SCD_NDT = 6 OR
                                              SD.SCD_NDT = 7*/
                                                                   )
                                       JOIN uss_ndi.v_ndi_document_type zt
                                           ON (zt.ndt_id = sd.scd_ndt)
                                 WHERE     ZZ.APP_AP = AP.AP_ID
                                       AND zt.ndt_ndc = 13
                                       AND (SD.SCD_SERIA || SD.SCD_NUMBER =
                                            REPLACE (P_SCD_SER_NUM, ' ', ''))))
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
                                       AND SD.SCD_NUMBER = P_NUMIDENT))
                   AND (       P_MODE IN ('OSZN',
                                          'APPOINTED',
                                          'KLOP',
                                          'WAIT',
                                          'ALL')
                           AND NOT EXISTS
                                   (SELECT *
                                      FROM v_ap_document  zd
                                           JOIN v_ap_document_attr a1
                                               ON (    a1.apda_apd =
                                                       zd.apd_id
                                                   AND a1.apda_nda IN (3688,
                                                                       3687,
                                                                       3261,
                                                                       3686))
                                           JOIN v_ap_document_attr a2
                                               ON (    a2.apda_apd =
                                                       zd.apd_id
                                                   AND a2.apda_nda IN (1872,
                                                                       3689,
                                                                       3263,
                                                                       3690))
                                     WHERE     zd.apd_ap = t.at_ap
                                           AND zd.apd_ndt IN (801,
                                                              802,
                                                              835,
                                                              836)
                                           AND a1.apda_val_string = 'G'
                                           AND a2.apda_val_id IS NOT NULL
                                           AND a1.history_status = 'A'
                                           AND a2.history_status = 'A')
                        OR     P_MODE IN ('PROVIDER', 'PROVIDER_SV')
                           AND EXISTS
                                   (SELECT *
                                      FROM v_ap_document  zd
                                           JOIN v_ap_document_attr a1
                                               ON (    a1.apda_apd =
                                                       zd.apd_id
                                                   AND a1.apda_nda IN (3688,
                                                                       3687,
                                                                       3261,
                                                                       3686))
                                           JOIN v_ap_document_attr a2
                                               ON (    a2.apda_apd =
                                                       zd.apd_id
                                                   AND a2.apda_nda IN (1872,
                                                                       3689,
                                                                       3263,
                                                                       3690))
                                     WHERE     zd.apd_ap = t.at_ap
                                           AND zd.apd_ndt IN (801,
                                                              802,
                                                              835,
                                                              836)
                                           AND a1.apda_val_string = 'G'
                                           AND a2.apda_val_id IS NOT NULL
                                           AND a1.history_status = 'A'
                                           AND a2.history_status = 'A'))
                   AND (   p_At_Tp IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM v_Act cld
                                 WHERE     cld.at_main_link = t.at_id
                                       AND cld.at_tp = p_at_tp
                                       AND cld.at_st NOT IN ('RD',
                                                             'AD',
                                                             'AR',
                                                             'DR',
                                                             'DD',
                                                             'TR',
                                                             'TD',
                                                             'VD',
                                                             'VR',
                                                             'VA',
                                                             'ID',
                                                             'IR',
                                                             'IA',
                                                             'GD',
                                                             'GR',
                                                             'XD',
                                                             'XR',
                                                             'ND',
                                                             'JR',
                                                             'JD')))
                   AND (   p_is_emergency IS NULL
                        OR p_is_emergency = 'T' AND t.at_case_class = 'EM')
                   AND (   p_ats_ss_method IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM AT_SERVICE Z
                                 WHERE     Z.ATS_AT = T.AT_ID
                                       AND Z.ATS_SS_METHOD = p_ats_ss_method
                                       AND Z.HISTORY_STATUS = 'A'));
    END;

    -- #102223: «Всі звернення»
    PROCEDURE get_all_appeals (p_start_Dt       IN     DATE,
                               p_stop_Dt        IN     DATE,
                               p_nst_Id         IN     NUMBER,
                               p_ap_num         IN     VARCHAR2,
                               p_ap_st          IN     VARCHAR2,
                               p_is_rejected    IN     VARCHAR2,
                               p_correct_tp     IN     VARCHAR2,
                               /*p_kaot_id IN NUMBER,
                               p_index IN VARCHAR2,
                               p_street IN VARCHAR2,
                               p_building IN VARCHAR2,
                               p_korp IN VARCHAR2,
                               p_appartment IN VARCHAR2,*/
                               p_is_emergency   IN     VARCHAR2,
                               res_cur             OUT SYS_REFCURSOR)
    IS
        l_Org   NUMBER := tools.GetCurrOrg;
    BEGIN
        OPEN res_cur FOR
            SELECT t.*,
                   at_last_update
                       AS at_id,
                   (SELECT DIC_SNAME
                      FROM USS_NDI.V_DDN_AP_ST Z
                     WHERE Z.DIC_VALUE = T.AP_ST)
                       AS AP_ST_NAME,
                   (SELECT LISTAGG (ST.NST_CODE || '-' || NST_NAME,
                                    ', ' || CHR (13) || CHR (10))
                           WITHIN GROUP (ORDER BY ST.NST_ORDER)
                      FROM V_AP_SERVICE  Z
                           JOIN USS_NDI.V_NDI_SERVICE_TYPE ST
                               ON (ST.NST_ID = Z.APS_NST)
                     WHERE Z.APS_AP = T.AP_ID --rownum < 4
                                              AND Z.HISTORY_STATUS = 'A')
                       AS APS_LIST,
                   (CASE
                        WHEN EXISTS
                                 (SELECT A.APDA_ID
                                    FROM AP_DOCUMENT_ATTR  A
                                         JOIN AP_DOCUMENT D
                                             ON A.APDA_APD = D.APD_ID
                                   WHERE     A.APDA_AP = T.AP_ID
                                         AND (   (    D.APD_NDT = 801
                                                  AND A.APDA_NDA = 1870)
                                              OR (    D.APD_NDT = 802
                                                  AND A.APDA_NDA = 1947)
                                              OR (    D.APD_NDT = 1015
                                                  AND A.APDA_NDA = 8263))
                                         AND A.APDA_VAL_STRING = 'T')
                        THEN
                            1
                        ELSE
                            0
                    END)
                       AS IS_EMERGENCY,
                   CASE
                       WHEN     at.at_st IN ('AR',
                                             'AD',
                                             'TR',
                                             'TD')
                            AND t.is_ap_correct = 0
                       THEN
                           1
                       ELSE
                           0
                   END
                       AS can_create,
                   (SELECT MAX (z.DIC_NAME)
                      FROM (SELECT * FROM uss_ndi.V_DDN_AT_APOP_ST
                            UNION ALL
                            SELECT * FROM uss_ndi.V_DDN_AT_TCTR_ST
                            UNION ALL
                            SELECT * FROM uss_ndi.V_DDN_AT_OKS_ST
                            UNION ALL
                            SELECT * FROM uss_ndi.V_DDN_AT_AVOP_ST
                            UNION ALL
                            SELECT * FROM uss_ndi.V_DDN_AT_IP_ST
                            UNION ALL
                            SELECT * FROM uss_ndi.V_DDN_AT_PPNP_ST
                            UNION ALL
                            SELECT * FROM uss_ndi.V_DDN_AT_IPNP_ST
                            UNION ALL
                            SELECT * FROM uss_ndi.V_DDN_AT_ANPK_ST
                            UNION ALL
                            SELECT * FROM uss_ndi.V_DDN_AT_ANPOE_ST
                            UNION ALL
                            SELECT * FROM uss_ndi.V_DDN_AT_PDSP_ST
                            UNION ALL
                            SELECT * FROM uss_ndi.V_DDN_AT_PWNP_ST
                            UNION ALL
                            SELECT * FROM uss_ndi.V_DDN_AT_ISNP_ST
                            UNION ALL
                            SELECT * FROM uss_ndi.V_DDN_AT_ZRSP_ST
                            UNION ALL
                            SELECT * FROM uss_ndi.V_DDN_AT_NDIS_ST
                            UNION ALL
                            SELECT * FROM uss_ndi.V_DDN_AT_RSTOPSS_ST
                            UNION ALL
                            SELECT * FROM uss_ndi.V_DDN_AT_SHDR_ST
                            UNION ALL
                            SELECT * FROM uss_ndi.V_DDN_AT_APRV_ST
                            UNION ALL
                            SELECT * FROM uss_ndi.V_DDN_AT_ORBD_ST
                            UNION ALL
                            SELECT * FROM uss_ndi.V_DDN_AT_PAO_ST) z
                     WHERE z.DIC_VALUE = at.at_st)
                       AS at_St_name
              FROM (SELECT t.*,
                           USS_PERSON.API$SC_TOOLS.GET_PIB_SCC (APP.APP_SCC)
                               AS APP_MAIN_PIB,
                           TOOLS.GET_MAIN_ADDR_SS (T.AP_ID,
                                                   T.AP_TP,
                                                   PC.PC_SC)
                               AS APP_MAIN_ADDRESS,
                           api$appeal.Is_Appeal_Maked_Correct (t.ap_id)
                               AS is_ap_correct,
                           (SELECT FIRST_VALUE (zl.atl_at)
                                       OVER (ORDER BY hs.hs_dt DESC)
                              FROM act  za
                                   JOIN at_log zl ON (zl.atl_at = za.at_id)
                                   JOIN histsession hs
                                       ON (hs.hs_id = zl.atl_hs)
                             WHERE za.at_ap = t.ap_id
                             FETCH FIRST ROW ONLY)
                               AS at_last_update
                      FROM v_appeal  t
                           LEFT JOIN v_personalcase pc
                               ON (pc.pc_id = t.ap_pc)
                           LEFT JOIN ap_person app
                               ON (    app.app_sc = pc.pc_sc
                                   AND app.app_ap = t.ap_id
                                   AND app.history_status = 'A')
                     WHERE     1 = 1
                           AND ap_tp IN ('SS')
                           AND TRUNC (t.ap_reg_dt) BETWEEN p_start_dt
                                                       AND p_stop_dt
                           AND t.com_org = l_org
                           AND (   p_ap_num IS NULL
                                OR t.ap_num LIKE p_ap_num || '%')
                           AND t.ap_st = NVL (p_ap_st, t.ap_st)
                           AND (   p_nst_Id IS NULL
                                OR EXISTS
                                       (SELECT *
                                          FROM V_AP_SERVICE Z
                                         WHERE     Z.APS_AP = T.AP_ID
                                               AND Z.APS_NST = p_nst_Id
                                               AND Z.HISTORY_STATUS = 'A')))
                   t
                   LEFT JOIN act at ON (at.at_id = t.at_last_update)
             WHERE     (   p_correct_tp IS NULL
                        OR p_correct_tp = 'T' AND is_ap_correct = 1
                        OR p_correct_tp = 'F' AND is_ap_correct = 0)
                   AND (   p_is_rejected IS NULL
                        OR     p_is_rejected = 'T'
                           AND at.at_st IN ('AR',
                                            'AD',
                                            'TR',
                                            'TD'))
                   AND (   p_is_emergency IS NULL
                        OR     p_is_emergency = 'T'
                           AND EXISTS
                                   (SELECT *
                                      FROM ap_document_attr a
                                     WHERE     a.apda_ap = t.ap_id
                                           AND a.apda_nda IN
                                                   (1870, 1947, 8263)
                                           AND NVL (a.apda_val_string, 'F') =
                                               'T'));
    END;

    -- ініціалізація акту
    PROCEDURE INIT_ACT_CARD (P_AP_ID IN NUMBER, MSG_CUR OUT SYS_REFCURSOR)
    IS
    BEGIN
        TOOLS.WRITEMSG ('DNET$ACT_ASSIGNMENTS.' || $$PLSQL_UNIT);
        API$ACT.INIT_ACT_BY_APPEALS (1, P_AP_ID, MSG_CUR);
    --COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            --ROLLBACK;
            RAISE_APPLICATION_ERROR (
                -20000,
                IKIS_MESSAGE_UTIL.GET_MESSAGE (
                    2,
                    'Dnet$Act_Assignments.INIT_ACT_CARD:',
                       CHR (10)
                    || DBMS_UTILITY.FORMAT_ERROR_STACK
                    || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE));
    END;

    -- ініціалізація акту
    PROCEDURE INIT_ACT_CARD (P_AP_ID         IN     NUMBER,
                             P_AP_SERVICES   IN     CLOB,
                             MSG_CUR            OUT SYS_REFCURSOR)
    IS
        l_At_Services   API$ACT.t_At_Services;
    BEGIN
        TOOLS.WRITEMSG ('DNET$ACT_ASSIGNMENTS.' || $$PLSQL_UNIT);


        SELECT NULL,
               aps_nst,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL
          BULK COLLECT INTO l_At_Services
          FROM JSON_TABLE (P_AP_SERVICES,
                           '$[*]'
                           COLUMNS (Aps_Id VARCHAR PATH '$.Aps_Id')) A
               JOIN ap_Service s ON (s.aps_id = a.aps_id);

        API$ACT.g_At_Service_Init_List := NULL;

        IF l_At_Services.COUNT > 0
        THEN
            API$ACT.g_At_Service_Init_List := l_At_Services;
        END IF;

        API$ACT.INIT_ACT_BY_APPEALS (1, P_AP_ID, MSG_CUR);
    --COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            API$ACT.g_At_Service_Init_List := NULL;
            --ROLLBACK;
            RAISE_APPLICATION_ERROR (
                -20000,
                IKIS_MESSAGE_UTIL.GET_MESSAGE (
                    2,
                    'Dnet$Act_Assignments.INIT_ACT_CARD:',
                       CHR (10)
                    || DBMS_UTILITY.FORMAT_ERROR_STACK
                    || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE));
    END;

    -- ініціалізація акту для швидкого старту
    PROCEDURE INIT_QUICK_START_ACT (P_AP_ID        IN     NUMBER,
                                    p_rnspm_id     IN     NUMBER,
                                    p_rnspm_name   IN     VARCHAR2,
                                    MSG_CUR           OUT SYS_REFCURSOR)
    IS
    BEGIN
        TOOLS.WRITEMSG ('DNET$ACT_ASSIGNMENTS.' || $$PLSQL_UNIT);

        /* UPDATE ap_document_attr t
            SET t.apda_val_id = p_rnspm_id,
                t.apda_val_string = p_rnspm_name
          WHERE t.apda_nda IN (1872, 3689, 3263, 3690)
            AND t.apda_apd IN (SELECT z.apd_id FROM ap_document z WHERE z.apd_ap = P_AP_ID AND z.apd_ndt IN (801, 802, 835, 836))
         ;*/

        DELETE FROM tmp_work_set2;

        INSERT INTO tmp_work_set2 (x_id1, x_id2)
             VALUES (p_ap_id, p_rnspm_id);

        API$ACT.INIT_ACT_BY_APPEALS (1, P_AP_ID, MSG_CUR);
    EXCEPTION
        WHEN OTHERS
        THEN
            RAISE_APPLICATION_ERROR (
                -20000,
                IKIS_MESSAGE_UTIL.GET_MESSAGE (
                    2,
                    'Dnet$Act_Assignments.INIT_QUICK_START_ACT:',
                       CHR (10)
                    || DBMS_UTILITY.FORMAT_ERROR_STACK
                    || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE));
    END;

    -- "Повернути на довведення" звернення
    PROCEDURE RETURN_APPEAL (P_AP_ID IN NUMBER, P_REASON IN VARCHAR2:= NULL)
    IS
    BEGIN
        API$APPEAL.RETURN_APPEAL_TO_EDITING (P_AP_ID, P_REASON);
    END;

    PROCEDURE GET_ACT_CARD (P_AT_ID IN NUMBER, ACT_CUR OUT SYS_REFCURSOR)
    IS
    BEGIN
        TOOLS.WRITEMSG ('DNET$ACT_ASSIGNMENTS.' || $$PLSQL_UNIT);

        OPEN ACT_CUR FOR
            SELECT T.*,
                   --pa.pa_num,
                    (SELECT LISTAGG (ZS.NST_ID, ', ')
                            WITHIN GROUP (ORDER BY ZS.NST_ID)
                       FROM AT_SERVICE  Z
                            JOIN USS_NDI.V_NDI_SERVICE_TYPE ZS
                                ON (ZS.NST_ID = Z.ATS_NST)
                      WHERE     Z.ATS_AT = T.AT_ID
                            AND Z.HISTORY_STATUS = 'A')
                       AS AT_NST_LIST,
                   (SELECT LISTAGG (ZS.NST_CODE || ' ' || ZS.NST_NAME, ', ')
                               WITHIN GROUP (ORDER BY ZS.NST_CODE)
                      FROM AT_SERVICE  Z
                           JOIN USS_NDI.V_NDI_SERVICE_TYPE ZS
                               ON (ZS.NST_ID = Z.ATS_NST)
                     WHERE Z.ATS_AT = T.AT_ID AND Z.HISTORY_STATUS = 'A')
                       AS AT_NST_LIST_NAME,
                   ST.DIC_SNAME
                       AS AT_ST_NAME,
                   -- hs.hs_dt AS return_dt,
                   --  tools.GetUserPib(hs.hs_wu) AS return_pib,

                   AP.AP_ID,
                   AP.AP_PC,
                   AP.AP_SRC_ID,
                   AP.AP_TP,
                   AP.AP_REG_DT,
                   AP.AP_SRC,
                   AP.AP_ST,
                   AP.AP_IS_SECOND,
                   AP.AP_NUM,
                   AP.AP_VF,
                   (SELECT DIC_SNAME
                      FROM USS_NDI.V_DDN_AP_ST Z
                     WHERE Z.DIC_VALUE = AP.AP_ST)
                       AS AP_ST_NAME,
                   (SELECT MAX (
                               USS_PERSON.API$SC_TOOLS.GET_PIB_SCC (
                                   z.app_scc))
                      FROM v_ap_person z
                     WHERE     z.app_ap = ap.ap_id
                           AND z.app_tp IN ('Z', 'OR', 'AF'))
                       --USS_PERSON.API$SC_TOOLS.GET_PIB(T.AT_SC)
                       AS APP_MAIN_PIB,
                   USS_PERSON.API$SC_TOOLS.GET_NUMIDENT (T.AT_SC)
                       AS APP_NUMIDENT,
                   USS_PERSON.API$SC_TOOLS.GET_DOC_NUM (T.AT_SC)
                       AS APP_SER_NUM,
                   TOOLS.GET_MAIN_ADDR_SS (T.AT_AP, AP.AP_TP, PC.PC_SC)
                       AS APP_MAIN_ADDRESS,
                   PC.PC_NUM,
                   PC.PC_SC,
                   --   src.dic_name AS pd_src_name,
                   (CASE
                        WHEN EXISTS
                                 (SELECT A.APDA_ID
                                    FROM AP_DOCUMENT_ATTR  A
                                         JOIN AP_DOCUMENT D
                                             ON A.APDA_APD = D.APD_ID
                                   WHERE     A.APDA_AP = AP.AP_ID
                                         AND (   (    D.APD_NDT = 801
                                                  AND A.APDA_NDA = 1870)
                                              OR (    D.APD_NDT = 802
                                                  AND A.APDA_NDA = 1947)
                                              OR (    D.APD_NDT = 803
                                                  AND A.APDA_NDA = 2032))
                                         AND A.APDA_VAL_STRING = 'T')
                        THEN
                            1
                        ELSE
                            0
                    END)
                       AS IS_EMERGENCY,                             --Екстрено
                   (CASE
                        WHEN t.at_st IN ('SC', 'SR', 'O.SR') THEN 1
                        ELSE 0
                    END)
                       AS IS_EDITABLE_PROVIDER,      --Редагувати поле надавач
                   (CASE
                        WHEN EXISTS
                                 (SELECT A.APDA_ID
                                    FROM AP_DOCUMENT_ATTR  A
                                         JOIN AP_DOCUMENT D
                                             ON A.APDA_APD = D.APD_ID
                                   WHERE     A.APDA_AP = AP.AP_ID
                                         AND (    D.APD_NDT = 801
                                              AND A.APDA_NDA = 1872
                                              AND A.APDA_VAL_ID IS NOT NULL))
                        THEN
                            1
                        WHEN EXISTS
                                 (SELECT A.APDA_ID
                                    FROM AP_DOCUMENT_ATTR  A
                                         JOIN AP_DOCUMENT D
                                             ON A.APDA_APD = D.APD_ID
                                   WHERE     A.APDA_AP = AP.AP_ID
                                         AND (    D.APD_NDT = 803
                                              AND A.APDA_NDA = 2083
                                              AND A.APDA_VAL_ID IS NOT NULL))
                        THEN
                            0
                        ELSE
                            NULL
                    END)
                       AS IS_SET_PROVIDER,
                   GET_ISNEED_INCOME (AT_ID)
                       AS IS_NEED_INCOME,
                   GET_IS_BLOCK_APPROVE (AT_ID)
                       AS IS_BLOCK_APPROVE,
                   GET_IS_BLOCK_SIGN (AT_ID)
                       AS IS_BLOCK_SIGN,
                   GET_IS_BLOCK_APPROVE_4REJ (AT_ID)
                       AS IS_BLOCK_APPROVE_4REJ,
                   GET_IS_BLOCK_SIGN_4REJ (AT_ID)
                       AS IS_BLOCK_SIGN_4REJ,
                   GET_RIGHT_BLOCK_FLAG (T.AT_ID)
                       AS BLOCK_RIGHT
              FROM V_ACT  T
                   JOIN USS_NDI.V_DDN_AT_PDSP_ST ST
                       ON (ST.DIC_VALUE = T.AT_ST)
                   JOIN USS_ESR.V_APPEAL AP ON (AP.AP_ID = T.AT_AP)
                   LEFT OUTER JOIN V_PERSONALCASE PC ON (PC.PC_ID = T.AT_PC)
             WHERE 1 = 1 AND T.AT_ID = P_AT_ID AND T.AT_TP = 'PDSP';
    END;

    -- #82497 2022.12.28: Блокування кнопки «Розрахунок доходу» для рішень про СП
    FUNCTION GET_ISNEED_INCOME (P_AT_ID NUMBER)
        RETURN NUMBER
    IS
        L_AP_ID   NUMBER (10);
    BEGIN
        SELECT AT_AP
          INTO L_AP_ID
          FROM V_ACT T
         WHERE AT_ID = P_AT_ID;

        RETURN API$APPEAL.GET_ISNEED_INCOME (L_AP_ID);
    END;

    -- #89477 20230801 Доступність кнопки «Затвердити» у актах по SS-зверненнях
    /*FUNCTION GET_IS_BLOCK_APPROVE(P_AT_ID NUMBER) RETURN NUMBER IS
      L_AP_ID  NUMBER(10);
      L_AP_TP  VARCHAR2(10);
      L_AT_ST  VARCHAR2(10);
      L_REZ    NUMBER(10);
      L_NDT    NUMBER;
      L_CHECK1 NUMBER;
      L_CHECK2 NUMBER;
      L_CHECK3 NUMBER;
    BEGIN
      -- #88679 - додав обробку для 836 документа
      -- #88656 - додав обробку для 835 документа
      SELECT AP_ID,
             AP_TP,
             (SELECT MAX(APD_NDT)
                FROM AP_DOCUMENT Z
               WHERE Z.APD_AP = AP_ID
                 AND APD_NDT IN (801, 802, 836, 835)),
             AT_ST
        INTO L_AP_ID, L_AP_TP, L_NDT, L_AT_ST
        FROM V_ACT
        JOIN APPEAL
          ON (AP_ID = AT_AP)
       WHERE AT_ID = P_AT_ID;

      IF L_AP_TP != 'SS' THEN
        RETURN 0;
      END IF;

      SELECT COUNT(*)
        INTO L_CHECK1
        FROM AT_FEATURES F
       WHERE F.ATF_AT = P_AT_ID
         AND F.ATF_NFT = 9
         AND F.ATF_VAL_ID IS NOT NULL;

      -- #89473
      IF (L_AT_ST = 'SC' AND L_CHECK1 > 0) THEN
        RETURN 0;
      END IF;

      SELECT COUNT(1)
        INTO L_CHECK1
        FROM PD_DOCUMENT T
       WHERE T.PDO_PD = P_AT_ID
         AND T.PDO_NDT = 804
         AND T.HISTORY_STATUS = 'A';

      \* ІІніціативним документом звернення є ndt_id in (802, 835):
      0) [- рішення має статус (SP1)
      - на вкладці «Оцінка потреб» є у наявності Акт оцінки потреб ndt_id=804]

      АБО
      1) [- рішення має статус in (SR, SW, SN)]*\

      IF (L_NDT IN (802, 835) AND
         (\*L_AT_ST = 'SP1' AND L_CHECK1 = 1 OR*\ L_AT_ST IN ('SR', 'SW', 'SN'))) THEN
        RETURN 0;
      END IF;

      \*ІІІ Ініціативним документом звернення є ndt_id in (836):
        0)  [- рішення має статус (SP1)
        - додано Акт оцінки потреб 804] --- тимчасова умова до появи кабінетів
      *\

      IF (L_NDT IN (836) AND L_AT_ST = 'SP1' AND L_CHECK1 = 1) THEN
        RETURN 0;
      END IF;

      SELECT CASE
               WHEN C1 > 0 AND (C2 > 0 AND C3 > 0 OR C2 = 0) THEN
                1
               ELSE
                0
             END
        INTO L_CHECK2
        FROM (SELECT (SELECT COUNT(*)
                        FROM V_AT_RIGHT_LOG Z
                       WHERE Z.ARL_AT = T.AT_ID) AS C1,
                     (SELECT COUNT(*)
                        FROM AP_DOCUMENT D
                        JOIN AP_DOCUMENT_ATTR DA
                          ON (DA.APDA_APD = D.APD_ID)
                       WHERE D.APD_AP = T.AT_AP
                         AND (D.APD_NDT IN (801) AND DA.APDA_NDA IN (1871) OR
                             D.APD_NDT IN (802) AND DA.APDA_NDA IN (1948) OR
                             D.APD_NDT IN (803) AND DA.APDA_NDA IN (2528) OR
                             D.APD_NDT IN (836) AND DA.APDA_NDA IN (3446) OR
                             D.APD_NDT IN (835) AND DA.APDA_NDA IN (3265))
                         AND D.HISTORY_STATUS = 'A'
                         AND DA.APDA_VAL_STRING = 'T') AS C2,
                     (SELECT COUNT(*)
                        FROM AT_INCOME_CALC C
                       WHERE C.AIC_AT = T.AT_ID) AS C3
                FROM V_ACT T
               WHERE T.AT_ID = P_AT_ID);

      SELECT CASE
               WHEN ATD_NDT = 850 AND CNT = 2 THEN
                1
               WHEN ATD_NDT = 854 AND CNT = 1 THEN
                1
               ELSE
                0
             END
        INTO L_CHECK3
        FROM (SELECT COUNT(1) AS CNT, T.ATD_NDT
                FROM AT_DOCUMENT T
                JOIN AT_SIGNERS S
                  ON (S.ATI_ATD = T.ATD_ID)
               WHERE T.ATD_AT = P_AT_ID
                 AND (T.ATD_NDT IN (850) OR
                     T.ATD_NDT IN (854) AND S.ATI_IS_SIGNED = 'T')
                 AND T.HISTORY_STATUS = 'A'
                 AND S.HISTORY_STATUS = 'A'
               GROUP BY T.ATD_NDT) T;

      \*Ініціативним документом звернення є ndt_id in (801):
      0) [- рішення має статус (SP1)
      - додано Акт оцінки потреб 804] --- тимчасова умова до появи кабінетів

      АБО
      1) [- рішення має статус (SR)
      - виконано розрахунок доходів
      - виконано визначення права
      - у рішенні наявний документ:
      або
      а) [-- «Рішення про надання / відмову в наданні соціальних послуг» ndt_id=850, для підпису якого внесено двох користувачів]
      або
      б) [-- «Путівка на влаштування до інтернатної(го) установи/закладу» ndt_id=850, для підпису якого внесено двох користувачів]
      - на документ рішення накладено КЕП першого підписанта]
      *\

      IF (L_NDT IN (801) AND
         (--L_AT_ST IN ('SP1') AND L_CHECK1 > 0 OR
         L_AT_ST IN ('SR') AND L_CHECK2 > 0 AND L_CHECK3 = 1)) THEN
        RETURN 0;
      END IF;

      SELECT CASE
               WHEN C1 > 1 AND C2 > 0 THEN
                1
               ELSE
                0
             END
        INTO L_CHECK1
        FROM (SELECT (SELECT COUNT(*)
                        FROM AT_SIGNERS Z
                       WHERE Z.ATI_ATD = T.ATD_ID
                         AND Z.HISTORY_STATUS = 'A') AS C1,
                     (SELECT COUNT(*)
                        FROM AT_SIGNERS Z
                       WHERE Z.ATI_ATD = T.ATD_ID
                         AND Z.HISTORY_STATUS = 'A'
                         AND Z.ATI_IS_SIGNED = 'T') AS C2
                FROM AT_DOCUMENT T
               WHERE T.ATD_AT = P_AT_ID
                 AND T.ATD_NDT IN (850, 854)
                 AND T.HISTORY_STATUS = 'A') T;

      SELECT COUNT(*)
        INTO L_CHECK2
        FROM AT_DOCUMENT T
        JOIN AT_SIGNERS S
          ON (S.ATI_ATD = T.ATD_ID)
       WHERE T.ATD_AT = P_AT_ID
         AND T.ATD_NDT IN (851)
         AND S.ATI_IS_SIGNED = 'T'
         AND T.HISTORY_STATUS = 'A'
         AND S.HISTORY_STATUS = 'A';

      SELECT CASE
               WHEN C1 > 0 AND C2 > 0 THEN
                1
               ELSE
                0
             END
        INTO L_CHECK3
        FROM (SELECT MAX((SELECT COUNT(*)
                           FROM AT_DOCUMENT ZD
                          WHERE ZD.ATD_AT = P_AT_ID
                            AND ZD.HISTORY_STATUS = 'A'
                            AND ZD.ATD_NDT = 852)) AS C1,
                     COUNT(*) AS C2
                FROM AT_DOCUMENT T
                JOIN AT_SIGNERS S
                  ON (S.ATI_ATD = T.ATD_ID)
               WHERE T.ATD_AT = P_AT_ID
                 AND T.ATD_NDT IN (853)
                 AND S.ATI_IS_SIGNED = 'T'
                 AND T.HISTORY_STATUS = 'A'
                 AND S.HISTORY_STATUS = 'A') T;

      \* АБО
      2) [- рішення має статус (O.SR)
      - у рішенні наявний документ «Путівка на влаштування до інтернатної(го) установи/закладу» ndt_id=854, для підпису якого внесено двох користувачів
      - на документ рішення накладено КЕП першого підписанта]

      АБО
      3) [- рішення має статус (O.SR)
      - у рішенні наявний документ «Рішення про надання / відмову в наданні соціальних послуг» ndt_id=850, для підпису якого внесено двох користувачів
      - на документ рішення накладено КЕП першого підписанта]

      АБО
      4) [статус рішення in (SW, SN)
      - у рішенні наявні документи:
      або
      а) [-- «Повідомлення про надання / відмову в наданні соціальних послуг» ndt_id=851
      -- на документ накладено КЕП]
      або
      б) [-- «Клопотання про влаштування особи з інвалідністю, особи похилого віку до інтернатної(го) установи/закладу» ndt_id=852
      та
      -- «Повідомлення про направлення клопотання про влаштування особи з інвалідністю, особи похилого віку до інтернатної(го) установи/закладу» ndt_id=853
      -- на документи накладено КЕП]]

      АБО
      5) [статус рішення in (O.SW, O.SN)] і у рішенні наявний документ:
      - «Повідомлення про надання / відмову в наданні соціальних послуг» ndt_id=851
      - на документ накладено КЕП]*\

      IF (L_NDT IN (801) AND
         (L_AT_ST IN ('O.SR') AND L_CHECK1 = 1 OR
         L_AT_ST IN ('SW', 'SN') AND (L_CHECK2 > 0 OR L_CHECK3 = 1) OR
         L_AT_ST IN ('O.SW', 'O.SN') AND L_CHECK2 > 0)) THEN
        RETURN 0;
      END IF;

      SELECT CASE
               WHEN C1 > 0 AND (C2 > 0 AND C3 > 0 OR C2 = 0) THEN
                1
               ELSE
                0
             END
        INTO L_CHECK1
        FROM (SELECT (SELECT COUNT(*)
                        FROM V_AT_RIGHT_LOG Z
                       WHERE Z.ARL_AT = T.AT_ID) AS C1,
                     (SELECT COUNT(*)
                        FROM AP_DOCUMENT D
                        JOIN AP_DOCUMENT_ATTR DA
                          ON (DA.APDA_APD = D.APD_ID)
                       WHERE D.APD_AP = T.AT_AP
                         AND (D.APD_NDT IN (801) AND DA.APDA_NDA IN (1871) OR
                             D.APD_NDT IN (802) AND DA.APDA_NDA IN (1948) OR
                             D.APD_NDT IN (803) AND DA.APDA_NDA IN (2528) OR
                             D.APD_NDT IN (836) AND DA.APDA_NDA IN (3446) OR
                             D.APD_NDT IN (835) AND DA.APDA_NDA IN (3265))
                         AND D.HISTORY_STATUS = 'A'
                         AND DA.APDA_VAL_STRING = 'T') AS C2,
                     (SELECT COUNT(*)
                        FROM AT_INCOME_CALC C
                       WHERE C.AIC_AT = T.AT_ID) AS C3
                FROM V_ACT T
               WHERE T.AT_ID = P_AT_ID);

      SELECT CASE
               WHEN C1 > 1 AND C2 > 0 THEN
                1
               ELSE
                0
             END
        INTO L_CHECK2
        FROM (SELECT (SELECT COUNT(*)
                        FROM AT_SIGNERS Z
                       WHERE Z.ATI_ATD = T.ATD_ID
                         AND Z.HISTORY_STATUS = 'A') AS C1,
                     (SELECT COUNT(*)
                        FROM AT_SIGNERS Z
                       WHERE Z.ATI_ATD = T.ATD_ID
                         AND Z.HISTORY_STATUS = 'A'
                         AND Z.ATI_IS_SIGNED = 'T') AS C2
                FROM AT_DOCUMENT T
               WHERE T.ATD_AT = P_AT_ID
                 AND T.ATD_NDT IN (850)
                 AND T.HISTORY_STATUS = 'A') T;

      SELECT COUNT(*)
        INTO L_CHECK3
        FROM AT_DOCUMENT T
        JOIN AT_SIGNERS S
          ON (S.ATI_ATD = T.ATD_ID)
       WHERE T.ATD_AT = P_AT_ID
         AND T.ATD_NDT IN (851)
         AND S.ATI_IS_SIGNED = 'T'
         AND T.HISTORY_STATUS = 'A'
         AND S.HISTORY_STATUS = 'A';

      \*
      ІІІ Ініціативним документом звернення є ndt_id in (836):
        1) [- рішення має статус (SR)
        - виконано розрахунок доходів
        - виконано визначення права
        - у рішенні наявний документ «Рішення про надання / відмову в наданні соціальних послуг» ndt_id=850, для підпису якого внесено двох користувачів
        - на документ рішення накладено КЕП першого підписанта]

        АБО
        2) [статус рішення in (SW, SN) і у рішенні наявний документ:
        - «Повідомлення про надання / відмову в наданні соціальних послуг» ndt_id=851
        - на документ накладено КЕП]
      *\

      IF (L_NDT IN (836) AND
         (L_AT_ST IN ('SR') AND L_CHECK1 = 1 AND L_CHECK2 = 1 OR
         L_AT_ST IN ('SW', 'SN') AND L_CHECK3 > 0)) THEN
        RETURN 0;
      END IF;

      RETURN 1;
    END;*/

    -- #111391, #91937  20230912 Доступність операції «Затвердити» у актах по SS-зверненнях
    FUNCTION GET_IS_BLOCK_APPROVE (P_AT_ID NUMBER)
        RETURN NUMBER
    IS
        L_AP_ID    NUMBER (10);
        L_AP_TP    VARCHAR2 (10);
        L_AT_ST    VARCHAR2 (10);
        L_REZ      NUMBER (10);
        L_NDT      NUMBER;
        L_CHECK1   NUMBER;
        L_CHECK2   NUMBER;
        L_CHECK3   NUMBER;
        L_CHECK4   NUMBER;
        L_CHECK5   NUMBER;
    BEGIN
        -- #88679 - додав обробку для 836 документа
        -- #88656 - додав обробку для 835 документа
        SELECT AP_ID,
               AP_TP,
               (SELECT MAX (APD_NDT)
                  FROM AP_DOCUMENT Z
                 WHERE     Z.APD_AP = AP_ID
                       AND APD_NDT IN (801,
                                       802,
                                       836,
                                       835)),
               AT_ST
          INTO L_AP_ID,
               L_AP_TP,
               L_NDT,
               L_AT_ST
          FROM V_ACT JOIN APPEAL ON (AP_ID = AT_AP)
         WHERE AT_ID = P_AT_ID;

        --RETURN 0;

        IF L_AP_TP != 'SS'
        THEN
            RETURN 0;
        END IF;

        -- якщо більше одного підписанта не підписали то блокувати
        FOR xx
            IN (  SELECT t.atd_id,
                         COUNT (s.ati_id)                                      AS all_sgn,
                         COUNT (CASE WHEN s.ati_is_signed = 'T' THEN 1 END)    AS sign_sgn
                    FROM at_document t
                         JOIN at_signers s ON (s.ati_atd = t.atd_id)
                   WHERE     t.atd_at = P_AT_ID
                         AND t.history_status = 'A'
                         AND s.history_status = 'A'
                         AND t.atd_ndt NOT IN (850)
                GROUP BY atd_id)
        LOOP
            IF (xx.all_sgn > 1 AND (xx.all_sgn - xx.sign_sgn) > 1)
            THEN
                RETURN 1;
            END IF;
        END LOOP;

        SELECT COUNT (*)
          INTO L_CHECK1
          FROM AT_FEATURES F
         WHERE     F.ATF_AT = P_AT_ID
               AND F.ATF_NFT = 9
               AND F.ATF_VAL_ID IS NOT NULL;

        -- #89473
        IF (L_AT_ST = 'SC' AND L_CHECK1 > 0)
        THEN
            RETURN 0;
        END IF;

        SELECT COUNT (1)
          INTO L_CHECK1
          FROM at_features T
         WHERE     t.atf_at = P_AT_ID
               AND T.ATF_NFT = 9
               AND t.atf_val_id IS NOT NULL;

        /* І Ініціативним документом звернення є ndt_id in (802, 835):
          0) [- рішення має статус (SC)
          - на вкладці «Надавач» визначено надавача, який буде виконувати первинну оцінку потреб]
          АБО
          1) [- рішення має статус in (SR, SW, SN)]*/

        IF (    L_NDT IN (802, 835)
            AND (   L_AT_ST = 'SC' AND L_CHECK1 = 1
                 OR L_AT_ST IN ('SR', 'SW', 'SN')))
        THEN
            RETURN 0;
        END IF;

        /*ІІІ Ініціативним документом звернення є ndt_id in (836):
          0) [- рішення має статус (SC)
          - на вкладці «Надавач» визначено надавача, який буде виконувати первинну оцінку потреб]*/

        IF (L_NDT IN (836) AND (L_AT_ST = 'SC' AND L_CHECK1 = 1))
        THEN
            RETURN 0;
        END IF;

        SELECT CASE
                   WHEN C1 > 0 AND (C2 > 0 AND C3 > 0 OR C2 = 0) THEN 1
                   ELSE 0
               END
          INTO L_CHECK2
          FROM (SELECT (SELECT COUNT (*)
                          FROM V_AT_RIGHT_LOG Z
                         WHERE Z.ARL_AT = T.AT_ID)              AS C1,
                       (SELECT COUNT (*)
                          FROM AP_DOCUMENT  D
                               JOIN AP_DOCUMENT_ATTR DA
                                   ON (DA.APDA_APD = D.APD_ID)
                         WHERE     D.APD_AP = T.AT_AP
                               AND (       D.APD_NDT IN (801)
                                       AND DA.APDA_NDA IN (1871)
                                    OR     D.APD_NDT IN (802)
                                       AND DA.APDA_NDA IN (1948)
                                    OR     D.APD_NDT IN (803)
                                       AND DA.APDA_NDA IN (2528)
                                    OR     D.APD_NDT IN (836)
                                       AND DA.APDA_NDA IN (3446)
                                    OR     D.APD_NDT IN (835)
                                       AND DA.APDA_NDA IN (3265))
                               AND D.HISTORY_STATUS = 'A'
                               AND DA.APDA_VAL_STRING = 'T')    AS C2,
                       (SELECT COUNT (*)
                          FROM AT_INCOME_CALC C
                         WHERE C.AIC_AT = T.AT_ID)              AS C3
                  FROM V_ACT T
                 WHERE T.AT_ID = P_AT_ID);

        SELECT MAX (
                   CASE
                       WHEN ATD_NDT = 850 AND CNT > 0 THEN  --AND CNT = 2 THEN
                                                           1
                       WHEN ATD_NDT = 854 AND CNT = 1 THEN 1
                       ELSE 0
                   END)
          INTO L_CHECK3
          FROM (  SELECT COUNT (1) AS CNT, T.ATD_NDT
                    FROM AT_DOCUMENT T
                         JOIN AT_SIGNERS S ON (S.ATI_ATD = T.ATD_ID)
                   WHERE     T.ATD_AT = P_AT_ID
                         AND (T.ATD_NDT IN (850) OR T.ATD_NDT IN (854) /* AND S.ATI_IS_SIGNED = 'T'*/
                                                                      )
                         AND T.HISTORY_STATUS = 'A'
                         AND S.HISTORY_STATUS = 'A'
                GROUP BY T.ATD_NDT) T;

        /*ІІ Ініціативним документом звернення є ndt_id in (801):
           0) [- рішення має статус (SC)
           - на вкладці «Надавач» визначено надавача, який буде виконувати первинну оцінку потреб]
           АБО
           1) [- рішення має статус (SR)
           - виконано розрахунок доходів
           - виконано визначення права
           - у рішенні наявний документ:
           або
           а) [-- «Рішення про надання / відмову в наданні соціальних послуг» ndt_id=850, для підпису якого внесено двох користувачів]
           або
           б) [-- «Путівка на влаштування до інтернатної(го) установи/закладу» ndt_id=854, для підпису якого внесено двох користувачів]
           - на документ накладено КЕП першого підписанта]*/

        IF (    L_NDT IN (801)
            AND (   L_AT_ST = 'SC' AND L_CHECK1 = 1
                 OR L_AT_ST IN ('SR') AND l_check2 = 1 AND l_check3 = 1))
        THEN
            RETURN 0;
        END IF;

        SELECT COUNT (1)
          INTO L_CHECK1
          FROM at_features T
         WHERE     t.atf_at = P_AT_ID
               AND T.ATF_NFT = 33
               AND t.atf_val_string = 'T'-- AND T.HISTORY_STATUS = 'A'
                                         ;

        SELECT /*MAX(CASE
                 WHEN ATD_NDT = 854 AND CNT > 0 THEN --AND CNT = 2 THEN
                  1
                 WHEN ATD_NDT = 850 AND CNT > 0 THEN
                  1
                 ELSE
                  0
               END)*/
               MAX (CASE WHEN ATD_NDT = 854 AND CNT > 0 THEN --AND CNT = 2 THEN
                                                             1 ELSE 0 END)
          INTO L_CHECK3
          FROM (  SELECT COUNT (1) AS CNT, T.ATD_NDT
                    FROM AT_DOCUMENT T
                         JOIN AT_SIGNERS S ON (S.ATI_ATD = T.ATD_ID)
                   WHERE     T.ATD_AT = P_AT_ID
                         AND (T.ATD_NDT IN (854) /*AND S.ATI_IS_SIGNED = 'T' OR
                             T.ATD_NDT IN (850)*/
                                                )
                         AND T.HISTORY_STATUS = 'A'
                         AND S.HISTORY_STATUS = 'A'
                GROUP BY T.ATD_NDT) T;

        /*АБО
          2) [- рішення має статус (SR)
          - виконано розрахунок доходів
          - виконано визначення права
          - встановлено значення фічі «Передати на область» = Так]
          АБО
          3) [- рішення має статус (O.SR)
          - у рішенні наявний документ:
          або
          а) [-- «Путівка на влаштування до інтернатної(го) установи/закладу» ndt_id=850, для підпису якого внесено двох користувачів]
          або
          б) [-- «Рішення про надання / відмову в наданні соціальних послуг» ndt_id=854, для підпису якого внесено двох користувачів]
          - на документ накладено КЕП першого підписанта]*/

        IF (    L_NDT IN (801)
            AND (   L_AT_ST = 'SR' AND L_CHECK2 = 1 AND l_check1 = 1
                 OR L_AT_ST IN ('O.SR') AND l_check3 = 1))
        THEN
            RETURN 0;
        END IF;

        SELECT CASE
                   WHEN     d_850 > 0
                        AND d_850 = d_850_all
                        AND d_851_all > 0
                        AND d_851_all - NVL (d_851, 0) <= 1
                   THEN
                       1
                   ELSE
                       0
               END
          INTO L_CHECK4
          FROM (SELECT (  SELECT COUNT (1)
                            FROM AT_DOCUMENT T
                                 JOIN AT_SIGNERS S ON (S.ATI_ATD = T.ATD_ID)
                           WHERE     T.ATD_AT = P_AT_ID
                                 AND T.ATD_NDT IN (851)
                                 AND S.ATI_IS_SIGNED = 'T'
                                 /*AND S.ATI_IS_SIGNED = 'T'*/
                                 AND T.HISTORY_STATUS = 'A'
                                 AND S.HISTORY_STATUS = 'A'
                        GROUP BY T.ATD_NDT)    AS d_851,
                       (  SELECT COUNT (1)
                            FROM AT_DOCUMENT T
                                 JOIN AT_SIGNERS S ON (S.ATI_ATD = T.ATD_ID)
                           WHERE     T.ATD_AT = P_AT_ID
                                 AND T.ATD_NDT IN (851)
                                 AND T.HISTORY_STATUS = 'A'
                                 AND S.HISTORY_STATUS = 'A'
                        GROUP BY T.ATD_NDT)    AS d_851_all,
                       (  SELECT COUNT (1)
                            FROM AT_DOCUMENT T
                                 JOIN AT_SIGNERS S ON (S.ATI_ATD = T.ATD_ID)
                           WHERE     T.ATD_AT = P_AT_ID
                                 AND T.ATD_NDT IN (850)
                                 AND S.ATI_IS_SIGNED = 'T'
                                 AND T.HISTORY_STATUS = 'A'
                                 AND S.HISTORY_STATUS = 'A'
                        GROUP BY T.ATD_NDT)    AS d_850,
                       (  SELECT COUNT (1)
                            FROM AT_DOCUMENT T
                                 JOIN AT_SIGNERS S ON (S.ATI_ATD = T.ATD_ID)
                           WHERE     T.ATD_AT = P_AT_ID
                                 AND T.ATD_NDT IN (850)
                                 AND T.HISTORY_STATUS = 'A'
                                 AND S.HISTORY_STATUS = 'A'
                        GROUP BY T.ATD_NDT)    AS d_850_all
                  FROM DUAL) T;

        SELECT CASE WHEN d_852 > 0 AND d_853 > 0 THEN 1 ELSE 0 END
          INTO L_CHECK5
          FROM (SELECT (  SELECT COUNT (1)
                            FROM AT_DOCUMENT T
                                 JOIN AT_SIGNERS S ON (S.ATI_ATD = T.ATD_ID)
                           WHERE     T.ATD_AT = P_AT_ID
                                 AND T.ATD_NDT IN (852)
                                 AND S.ATI_IS_SIGNED = 'T'
                                 AND T.HISTORY_STATUS = 'A'
                                 AND S.HISTORY_STATUS = 'A'
                        GROUP BY T.ATD_NDT)    AS d_852,
                       (  SELECT COUNT (1)
                            FROM AT_DOCUMENT T
                                 JOIN AT_SIGNERS S ON (S.ATI_ATD = T.ATD_ID)
                           WHERE     T.ATD_AT = P_AT_ID
                                 AND T.ATD_NDT IN (853)
                                 /*AND S.ATI_IS_SIGNED = 'T'*/
                                 AND T.HISTORY_STATUS = 'A'
                                 AND S.HISTORY_STATUS = 'A'
                        GROUP BY T.ATD_NDT)    AS d_853
                  FROM DUAL) T;

        /*4) [статус рішення in (SW, SN)
         - у рішенні наявні документи:
         або
         а) [-- «Повідомлення про надання / відмову в наданні соціальних послуг» ndt_id=851
         -- на документи 850 (створений у попередньому статусі), 851 накладено КЕП другого підписанта]
         або
         б) [-- «Клопотання про влаштування особи з інвалідністю, особи похилого віку до інтернатної(го) установи/закладу» ndt_id=852
         та
         -- «Повідомлення про направлення клопотання про влаштування особи з інвалідністю, особи похилого віку до інтернатної(го) установи/закладу» ndt_id=853]
         - на документи накладено КЕП]
         АБО
         5) [статус рішення in (O.SW, O.SN) і у рішенні наявний документ:
         - «Повідомлення про надання / відмову в наданні соціальних послуг» ndt_id=851
         - на документи 850 (створений у попередньому статусі), 851 накладено КЕП другого підписанта]*/

        IF (    L_NDT IN (801)
            AND (       l_at_st IN ('SW', 'SN')
                    AND (L_CHECK4 = 1 OR l_check5 = 1)
                 --or l_at_st IN ('O.SW') AND L_CHECK3 = 1
                 OR l_at_st IN ('O.SN') AND l_check4 = 1))
        THEN
            RETURN 0;
        END IF;

        SELECT CASE WHEN cnt > 0 AND cnt = cnt_all THEN 1 ELSE 0 END
          INTO L_CHECK3
          FROM (SELECT (SELECT COUNT (1)     AS CNT
                          FROM AT_DOCUMENT  T
                               JOIN AT_SIGNERS S ON (S.ATI_ATD = T.ATD_ID)
                         WHERE     T.ATD_AT = P_AT_ID
                               AND T.ATD_NDT IN (854)
                               /* AND S.ATI_IS_SIGNED = 'T'*/
                               AND T.HISTORY_STATUS = 'A'
                               AND S.HISTORY_STATUS = 'A')    AS cnt,
                       (SELECT COUNT (1)     AS CNT
                          FROM AT_DOCUMENT  T
                               JOIN AT_SIGNERS S ON (S.ATI_ATD = T.ATD_ID)
                         WHERE     T.ATD_AT = P_AT_ID
                               AND T.ATD_NDT IN (854)
                               AND T.HISTORY_STATUS = 'A'
                               AND S.HISTORY_STATUS = 'A')    AS cnt_all
                  FROM DUAL) T;

        /* АБО
         6) [статус рішення in (SW)
         - у рішенні наявний документ:
         -- «Путівка на влаштування до інтернатної(го) установи/закладу» ndt_id=854, на документ накладено КЕП другого підписанта] */

        IF (L_NDT IN (801) AND l_at_st IN ('SW') AND L_CHECK3 = 1)
        THEN
            RETURN 0;
        END IF;

        /*SELECT CASE WHEN cnt > 0 THEN 1 ELSE 0
               END
          INTO L_CHECK3
          FROM (SELECT COUNT(1) AS CNT
                  FROM AT_DOCUMENT T
                  JOIN AT_SIGNERS S
                    ON (S.ATI_ATD = T.ATD_ID)
                 WHERE T.ATD_AT = P_AT_ID
                   AND T.ATD_NDT IN (854)
                   AND T.HISTORY_STATUS = 'A'
                   AND S.HISTORY_STATUS = 'A') T;*/
        SELECT MAX (
                   CASE
                       WHEN CNT = cnt_sgn THEN              --AND CNT = 2 THEN
                                               1
                       WHEN cnt_sgn > 0 AND cnt > cnt_sgn THEN 1
                       ELSE 0
                   END)
          INTO L_CHECK3
          FROM (  SELECT COUNT (1)                                             AS CNT,
                         COUNT (CASE WHEN s.ati_is_signed = 'T' THEN 1 END)    AS cnt_sgn
                    FROM AT_DOCUMENT T
                         JOIN AT_SIGNERS S ON (S.ATI_ATD = T.ATD_ID)
                   WHERE     T.ATD_AT = P_AT_ID
                         AND (T.ATD_NDT IN (854))
                         AND T.HISTORY_STATUS = 'A'
                         AND S.HISTORY_STATUS = 'A'
                GROUP BY T.ATD_NDT) T;

        /*   [статус рішення in (O.SW)] і у рішенні наявний документ:
            - «Путівка на влаштування до інтернатної(го) установи/закладу» ndt_id=854
            */

        IF (L_NDT IN (801) AND l_at_st IN ('O.SW') AND L_CHECK3 = 1)
        THEN
            RETURN 0;
        END IF;

        SELECT CASE WHEN cnt > 0 THEN 1 ELSE 0 END
          INTO L_CHECK3
          FROM (SELECT COUNT (1)     AS CNT
                  FROM AT_DOCUMENT  T
                       JOIN AT_SIGNERS S ON (S.ATI_ATD = T.ATD_ID)
                 WHERE     T.ATD_AT = P_AT_ID
                       AND T.ATD_NDT IN (850)
                       /*AND S.ATI_IS_SIGNED = 'T'*/
                       AND T.HISTORY_STATUS = 'A'
                       AND S.HISTORY_STATUS = 'A') T;

        /*ІІІ Ініціативним документом звернення є ndt_id in (836):
          АБО
          1) [- рішення має статус (SR)
          - виконано розрахунок доходів
          - виконано визначення права
          - у рішенні наявний документ:
          -- «Рішення про надання / відмову в наданні соціальних послуг» ndt_id=850, для підпису якого внесено двох користувачів
          - на документ накладено КЕП першого підписанта]
          АБО
          2) [- рішення має статус (SR)
          - виконано розрахунок доходів
          - виконано визначення права
          - встановлено значення фічі «Передати на область» = Так]
          АБО
          3) [- рішення має статус (O.SR)
          - у рішенні наявний документ:
          -- «Рішення про надання / відмову в наданні соціальних послуг» ndt_id=850, для підпису якого внесено двох користувачів
          - на документ накладено КЕП першого підписанта]
          АБО
          4) [статус рішення in (SW, SN)
          - у рішенні наявні документи:
          або
          а) [-- «Повідомлення про надання / відмову в наданні соціальних послуг» ndt_id=851
          -- на документи 850 (створений у попередньому статусі), 851 накладено КЕП другого підписанта]
          або
          б) [-- «Клопотання про влаштування особи з інвалідністю, особи похилого віку до інтернатної(го) установи/закладу» ndt_id=852
          та
          -- «Повідомлення про направлення клопотання про влаштування особи з інвалідністю, особи похилого віку до інтернатної(го) установи/закладу» ndt_id=853]
          -- на документи накладено КЕП]
          АБО
          5) [статус рішення in (O.SW, O.SN)] і у рішенні наявний документ:
          - «Повідомлення про надання / відмову в наданні соціальних послуг» ndt_id=851
          - на документи 850 (створений у попередньому статусі), 851 накладено КЕП другого підписанта]
        */

        IF (    L_NDT IN (836)
            AND (   L_AT_ST = 'SR' AND l_check3 = 1 AND L_CHECK2 = 1
                 OR L_AT_ST = 'SR' AND l_check2 = 1 AND L_CHECK1 = 1
                 OR l_at_st IN ('O.SR') AND l_check3 = 1
                 OR     l_at_st IN ('SW', 'SN')
                    AND (l_check4 = 1 OR l_check5 = 1)
                 OR l_at_st IN (                                  /*'O.SW', */
                                'O.SN') AND l_check4 = 1))
        THEN
            RETURN 0;
        END IF;

        RETURN 1;
    END;

    -- #111391, #91937  20230912 Доступність кнопки «Підписати» у актах по SS-зверненнях
    FUNCTION GET_IS_BLOCK_SIGN (P_AT_ID NUMBER)
        RETURN NUMBER
    IS
        L_AP_ID    NUMBER (10);
        L_AP_TP    VARCHAR2 (10);
        L_AT_ST    VARCHAR2 (10);
        L_REZ      NUMBER (10);
        L_NDT      NUMBER;
        L_CHECK1   NUMBER;
        L_CHECK2   NUMBER;
        L_CHECK3   NUMBER;
        L_CHECK4   NUMBER;
        L_CHECK5   NUMBER;
    BEGIN
        -- #88679 - додав обробку для 836 документа
        -- #88656 - додав обробку для 835 документа
        SELECT AP_ID,
               AP_TP,
               (SELECT MAX (APD_NDT)
                  FROM AP_DOCUMENT Z
                 WHERE     Z.APD_AP = AP_ID
                       AND APD_NDT IN (801,
                                       802,
                                       836,
                                       835)),
               AT_ST
          INTO L_AP_ID,
               L_AP_TP,
               L_NDT,
               L_AT_ST
          FROM V_ACT JOIN APPEAL ON (AP_ID = AT_AP)
         WHERE AT_ID = P_AT_ID;

        --RETURN 0;

        IF L_AP_TP != 'SS'
        THEN
            RETURN 0;
        END IF;

        SELECT COUNT (*)
          INTO L_CHECK1
          FROM AT_FEATURES F
         WHERE     F.ATF_AT = P_AT_ID
               AND F.ATF_NFT = 9
               AND F.ATF_VAL_ID IS NOT NULL;

        -- #89473
        IF (L_AT_ST = 'SC' AND L_CHECK1 > 0)
        THEN
            RETURN 0;
        END IF;

        SELECT COUNT (1)
          INTO L_CHECK1
          FROM at_features T
         WHERE     t.atf_at = P_AT_ID
               AND T.ATF_NFT = 9
               AND t.atf_val_id IS NOT NULL;

        /* І Ініціативним документом звернення є ndt_id in (802, 835):
          0) [- рішення має статус (SC)
          - на вкладці «Надавач» визначено надавача, який буде виконувати первинну оцінку потреб]
          АБО
          1) [- рішення має статус in (SR, SW, SN)]*/

        IF (    L_NDT IN (802, 835)
            AND (   L_AT_ST = 'SC' AND L_CHECK1 = 1
                 OR L_AT_ST IN ('SR', 'SW', 'SN')))
        THEN
            RETURN 0;
        END IF;

        /*ІІІ Ініціативним документом звернення є ndt_id in (836):
          0) [- рішення має статус (SC)
          - на вкладці «Надавач» визначено надавача, який буде виконувати первинну оцінку потреб]*/

        IF (L_NDT IN (836) AND (L_AT_ST = 'SC' AND L_CHECK1 = 1))
        THEN
            RETURN 0;
        END IF;

        SELECT CASE
                   WHEN C1 > 0 AND (C2 > 0 AND C3 > 0 OR C2 = 0) THEN 1
                   ELSE 0
               END
          INTO L_CHECK2
          FROM (SELECT (SELECT COUNT (*)
                          FROM V_AT_RIGHT_LOG Z
                         WHERE Z.ARL_AT = T.AT_ID)              AS C1,
                       (SELECT COUNT (*)
                          FROM AP_DOCUMENT  D
                               JOIN AP_DOCUMENT_ATTR DA
                                   ON (DA.APDA_APD = D.APD_ID)
                         WHERE     D.APD_AP = T.AT_AP
                               AND (       D.APD_NDT IN (801)
                                       AND DA.APDA_NDA IN (1871)
                                    OR     D.APD_NDT IN (802)
                                       AND DA.APDA_NDA IN (1948)
                                    OR     D.APD_NDT IN (803)
                                       AND DA.APDA_NDA IN (2528)
                                    OR     D.APD_NDT IN (836)
                                       AND DA.APDA_NDA IN (3446)
                                    OR     D.APD_NDT IN (835)
                                       AND DA.APDA_NDA IN (3265))
                               AND D.HISTORY_STATUS = 'A'
                               AND DA.APDA_VAL_STRING = 'T')    AS C2,
                       (SELECT COUNT (*)
                          FROM AT_INCOME_CALC C
                         WHERE C.AIC_AT = T.AT_ID)              AS C3
                  FROM V_ACT T
                 WHERE T.AT_ID = P_AT_ID);

        SELECT MAX (
                   CASE
                       WHEN ATD_NDT = 850 AND CNT > 0 THEN  --AND CNT = 2 THEN
                                                           1
                       WHEN ATD_NDT = 854 AND CNT = 1 THEN 1
                       ELSE 0
                   END)
          INTO L_CHECK3
          FROM (  SELECT COUNT (1) AS CNT, T.ATD_NDT
                    FROM AT_DOCUMENT T
                         JOIN AT_SIGNERS S ON (S.ATI_ATD = T.ATD_ID)
                   WHERE     T.ATD_AT = P_AT_ID
                         AND (T.ATD_NDT IN (850) OR T.ATD_NDT IN (854) /* AND S.ATI_IS_SIGNED = 'T'*/
                                                                      )
                         AND T.HISTORY_STATUS = 'A'
                         AND S.HISTORY_STATUS = 'A'
                GROUP BY T.ATD_NDT) T;

        /*ІІ Ініціативним документом звернення є ndt_id in (801):
           0) [- рішення має статус (SC)
           - на вкладці «Надавач» визначено надавача, який буде виконувати первинну оцінку потреб]
           АБО
           1) [- рішення має статус (SR)
           - виконано розрахунок доходів
           - виконано визначення права
           - у рішенні наявний документ:
           або
           а) [-- «Рішення про надання / відмову в наданні соціальних послуг» ndt_id=850, для підпису якого внесено двох користувачів]
           або
           б) [-- «Путівка на влаштування до інтернатної(го) установи/закладу» ndt_id=854, для підпису якого внесено двох користувачів]
           - на документ накладено КЕП першого підписанта]*/

        IF (    L_NDT IN (801)
            AND (   L_AT_ST = 'SC' AND L_CHECK1 = 1
                 OR L_AT_ST IN ('SR') AND l_check2 = 1 AND l_check3 = 1))
        THEN
            RETURN 0;
        END IF;

        SELECT COUNT (1)
          INTO L_CHECK1
          FROM at_features T
         WHERE     t.atf_at = P_AT_ID
               AND T.ATF_NFT = 33
               AND t.atf_val_string = 'T'-- AND T.HISTORY_STATUS = 'A'
                                         ;

        SELECT /*MAX(CASE
                 WHEN ATD_NDT = 854 AND CNT > 0 THEN --AND CNT = 2 THEN
                  1
                 WHEN ATD_NDT = 850 AND CNT > 0 THEN
                  1
                 ELSE
                  0
               END)*/
               MAX (CASE WHEN ATD_NDT = 854 AND CNT > 0 THEN --AND CNT = 2 THEN
                                                             1 ELSE 0 END)
          INTO L_CHECK3
          FROM (  SELECT COUNT (1) AS CNT, T.ATD_NDT
                    FROM AT_DOCUMENT T
                         JOIN AT_SIGNERS S ON (S.ATI_ATD = T.ATD_ID)
                   WHERE     T.ATD_AT = P_AT_ID
                         AND (T.ATD_NDT IN (854) /*AND S.ATI_IS_SIGNED = 'T' OR
                             T.ATD_NDT IN (850)*/
                                                )
                         AND T.HISTORY_STATUS = 'A'
                         AND S.HISTORY_STATUS = 'A'
                GROUP BY T.ATD_NDT) T;

        /*АБО
          2) [- рішення має статус (SR)
          - виконано розрахунок доходів
          - виконано визначення права
          - встановлено значення фічі «Передати на область» = Так]
          АБО
          3) [- рішення має статус (O.SR)
          - у рішенні наявний документ:
          або
          а) [-- «Путівка на влаштування до інтернатної(го) установи/закладу» ndt_id=850, для підпису якого внесено двох користувачів]
          або
          б) [-- «Рішення про надання / відмову в наданні соціальних послуг» ndt_id=854, для підпису якого внесено двох користувачів]
          - на документ накладено КЕП першого підписанта]*/

        IF (    L_NDT IN (801)
            AND (   L_AT_ST = 'SR' AND L_CHECK2 = 1 AND l_check1 = 1
                 OR L_AT_ST IN ('O.SR') AND l_check3 = 1))
        THEN
            RETURN 0;
        END IF;

        SELECT CASE
                   WHEN     d_850 > 0
                        AND d_850 <= d_850_all
                        AND d_851 > 0
                        AND d_851 <= d_851_all
                   THEN
                       1
                   WHEN d_850 > 0 AND d_850 <= d_850_all AND d_851 IS NULL
                   THEN
                       1
                   ELSE
                       0
               END
          INTO L_CHECK4
          FROM (SELECT (  SELECT COUNT (1)
                            FROM AT_DOCUMENT T
                                 JOIN AT_SIGNERS S ON (S.ATI_ATD = T.ATD_ID)
                           WHERE     T.ATD_AT = P_AT_ID
                                 AND T.ATD_NDT IN (851)
                                 /*AND S.ATI_IS_SIGNED = 'T'*/
                                 AND T.HISTORY_STATUS = 'A'
                                 AND S.HISTORY_STATUS = 'A'
                        GROUP BY T.ATD_NDT)    AS d_851,
                       (  SELECT COUNT (1)
                            FROM AT_DOCUMENT T
                                 JOIN AT_SIGNERS S ON (S.ATI_ATD = T.ATD_ID)
                           WHERE     T.ATD_AT = P_AT_ID
                                 AND T.ATD_NDT IN (851)
                                 AND T.HISTORY_STATUS = 'A'
                                 AND S.HISTORY_STATUS = 'A'
                        GROUP BY T.ATD_NDT)    AS d_851_all,
                       (  SELECT COUNT (1)
                            FROM AT_DOCUMENT T
                                 JOIN AT_SIGNERS S ON (S.ATI_ATD = T.ATD_ID)
                           WHERE     T.ATD_AT = P_AT_ID
                                 AND T.ATD_NDT IN (850)
                                 AND S.ATI_IS_SIGNED = 'T'
                                 AND T.HISTORY_STATUS = 'A'
                                 AND S.HISTORY_STATUS = 'A'
                        GROUP BY T.ATD_NDT)    AS d_850,
                       (  SELECT COUNT (1)
                            FROM AT_DOCUMENT T
                                 JOIN AT_SIGNERS S ON (S.ATI_ATD = T.ATD_ID)
                           WHERE     T.ATD_AT = P_AT_ID
                                 AND T.ATD_NDT IN (850)
                                 AND T.HISTORY_STATUS = 'A'
                                 AND S.HISTORY_STATUS = 'A'
                        GROUP BY T.ATD_NDT)    AS d_850_all
                  FROM DUAL) T;

        SELECT CASE WHEN d_852 > 0 OR d_853 > 0 THEN 1 ELSE 0 END
          INTO L_CHECK5
          FROM (SELECT (  SELECT COUNT (1)
                            FROM AT_DOCUMENT T
                                 JOIN AT_SIGNERS S ON (S.ATI_ATD = T.ATD_ID)
                           WHERE     T.ATD_AT = P_AT_ID
                                 AND T.ATD_NDT IN (852)
                                 /*AND S.ATI_IS_SIGNED = 'T'*/
                                 AND T.HISTORY_STATUS = 'A'
                                 AND S.HISTORY_STATUS = 'A'
                        GROUP BY T.ATD_NDT)    AS d_852,
                       (  SELECT COUNT (1)
                            FROM AT_DOCUMENT T
                                 JOIN AT_SIGNERS S ON (S.ATI_ATD = T.ATD_ID)
                           WHERE     T.ATD_AT = P_AT_ID
                                 AND T.ATD_NDT IN (853)
                                 /*AND S.ATI_IS_SIGNED = 'T'*/
                                 AND T.HISTORY_STATUS = 'A'
                                 AND S.HISTORY_STATUS = 'A'
                        GROUP BY T.ATD_NDT)    AS d_853
                  FROM DUAL) T;

        /*4) [статус рішення in (SW, SN)
         - у рішенні наявні документи:
         або
         а) [-- «Повідомлення про надання / відмову в наданні соціальних послуг» ndt_id=851
         -- на документи 850 (створений у попередньому статусі), 851 накладено КЕП другого підписанта]
         або
         б) [-- «Клопотання про влаштування особи з інвалідністю, особи похилого віку до інтернатної(го) установи/закладу» ndt_id=852
         та
         -- «Повідомлення про направлення клопотання про влаштування особи з інвалідністю, особи похилого віку до інтернатної(го) установи/закладу» ndt_id=853]
         - на документи накладено КЕП]
         АБО
         5) [статус рішення in (O.SW, O.SN) і у рішенні наявний документ:
         - «Повідомлення про надання / відмову в наданні соціальних послуг» ndt_id=851
         - на документи 850 (створений у попередньому статусі), 851 накладено КЕП другого підписанта]*/

        IF (    L_NDT IN (801)
            AND (       l_at_st IN ('SW', 'SN')
                    AND (L_CHECK4 = 1 OR l_check5 = 1)
                 --OR l_at_st IN ('O.SW') AND l_check3 = 1
                 OR l_at_st IN ('O.SN') AND l_check4 = 1))
        THEN
            RETURN 0;
        END IF;

        SELECT CASE WHEN cnt > 0 AND cnt = cnt_all THEN 1 ELSE 0 END
          INTO L_CHECK3
          FROM (SELECT (SELECT COUNT (1)     AS CNT
                          FROM AT_DOCUMENT  T
                               JOIN AT_SIGNERS S ON (S.ATI_ATD = T.ATD_ID)
                         WHERE     T.ATD_AT = P_AT_ID
                               AND T.ATD_NDT IN (854)
                               /* AND S.ATI_IS_SIGNED = 'T'*/
                               AND T.HISTORY_STATUS = 'A'
                               AND S.HISTORY_STATUS = 'A')    AS cnt,
                       (SELECT COUNT (1)     AS CNT
                          FROM AT_DOCUMENT  T
                               JOIN AT_SIGNERS S ON (S.ATI_ATD = T.ATD_ID)
                         WHERE     T.ATD_AT = P_AT_ID
                               AND T.ATD_NDT IN (854)
                               AND T.HISTORY_STATUS = 'A'
                               AND S.HISTORY_STATUS = 'A')    AS cnt_all
                  FROM DUAL) T;

        /* АБО
         6) [статус рішення in (SW)
         - у рішенні наявний документ:
         -- «Путівка на влаштування до інтернатної(го) установи/закладу» ndt_id=854, на документ накладено КЕП другого підписанта] */

        IF (L_NDT IN (801) AND l_at_st IN ('SW') AND L_CHECK3 = 1)
        THEN
            RETURN 0;
        END IF;

        SELECT MAX (
                   CASE WHEN cnt_sgn > 0 AND cnt > cnt_sgn THEN 1 ELSE 0 END)
          INTO L_CHECK3
          FROM (  SELECT COUNT (1)                                             AS CNT,
                         COUNT (CASE WHEN s.ati_is_signed = 'T' THEN 1 END)    AS cnt_sgn
                    FROM AT_DOCUMENT T
                         JOIN AT_SIGNERS S ON (S.ATI_ATD = T.ATD_ID)
                   WHERE     T.ATD_AT = P_AT_ID
                         AND (T.ATD_NDT IN (854))
                         AND T.HISTORY_STATUS = 'A'
                         AND S.HISTORY_STATUS = 'A'
                GROUP BY T.ATD_NDT) T;

        /*   [статус рішення in (O.SW)] і у рішенні наявний документ:
            - «Путівка на влаштування до інтернатної(го) установи/закладу» ndt_id=854
            */

        IF (L_NDT IN (801) AND l_at_st IN ('O.SW') AND L_CHECK3 = 1)
        THEN
            RETURN 0;
        END IF;

        SELECT CASE WHEN cnt > 0 THEN 1 ELSE 0 END
          INTO L_CHECK3
          FROM (SELECT COUNT (1)     AS CNT
                  FROM AT_DOCUMENT  T
                       JOIN AT_SIGNERS S ON (S.ATI_ATD = T.ATD_ID)
                 WHERE     T.ATD_AT = P_AT_ID
                       AND T.ATD_NDT IN (850)
                       /*AND S.ATI_IS_SIGNED = 'T'*/
                       AND T.HISTORY_STATUS = 'A'
                       AND S.HISTORY_STATUS = 'A') T;

        /*ІІІ Ініціативним документом звернення є ndt_id in (836):
          АБО
          1) [- рішення має статус (SR)
          - виконано розрахунок доходів
          - виконано визначення права
          - у рішенні наявний документ:
          -- «Рішення про надання / відмову в наданні соціальних послуг» ndt_id=850, для підпису якого внесено двох користувачів
          - на документ накладено КЕП першого підписанта]
          АБО
          2) [- рішення має статус (SR)
          - виконано розрахунок доходів
          - виконано визначення права
          - встановлено значення фічі «Передати на область» = Так]
          АБО
          3) [- рішення має статус (O.SR)
          - у рішенні наявний документ:
          -- «Рішення про надання / відмову в наданні соціальних послуг» ndt_id=850, для підпису якого внесено двох користувачів
          - на документ накладено КЕП першого підписанта]
          АБО
          4) [статус рішення in (SW, SN)
          - у рішенні наявні документи:
          або
          а) [-- «Повідомлення про надання / відмову в наданні соціальних послуг» ndt_id=851
          -- на документи 850 (створений у попередньому статусі), 851 накладено КЕП другого підписанта]
          або
          б) [-- «Клопотання про влаштування особи з інвалідністю, особи похилого віку до інтернатної(го) установи/закладу» ndt_id=852
          та
          -- «Повідомлення про направлення клопотання про влаштування особи з інвалідністю, особи похилого віку до інтернатної(го) установи/закладу» ndt_id=853]
          -- на документи накладено КЕП]
          АБО
          5) [статус рішення in (O.SW, O.SN)] і у рішенні наявний документ:
          - «Повідомлення про надання / відмову в наданні соціальних послуг» ndt_id=851
          - на документи 850 (створений у попередньому статусі), 851 накладено КЕП другого підписанта]
        */

        IF (    L_NDT IN (836)
            AND (   L_AT_ST = 'SR' AND l_check3 = 1 AND L_CHECK2 = 1
                 OR L_AT_ST = 'SR' AND l_check2 = 1 AND L_CHECK1 = 1
                 OR l_at_st IN ('O.SR') AND l_check3 = 1
                 OR     l_at_st IN ('SW', 'SN')
                    AND (l_check4 = 1 OR l_check5 = 1)
                 OR l_at_st IN (                                  /*'O.SW', */
                                'O.SN') AND l_check4 = 1))
        THEN
            RETURN 0;
        END IF;

        RETURN 1;
    END;

    -- #89735 20230717 Доступність кнопки «Затвердити» у рішеннях по SS-зверненнях при відмові
    FUNCTION GET_IS_BLOCK_APPROVE_4REJ (P_AT_ID NUMBER)
        RETURN NUMBER
    IS
        L_AP_ID    NUMBER (10);
        L_AP_TP    VARCHAR2 (10);
        L_AT_ST    VARCHAR2 (10);
        L_REZ      NUMBER (10);
        L_NDT      NUMBER;
        L_CHECK1   NUMBER;
        L_CHECK2   NUMBER;
        L_CHECK3   NUMBER;
    BEGIN
        SELECT AP_ID,
               AP_TP,
               (SELECT MAX (APD_NDT)
                  FROM AP_DOCUMENT Z
                 WHERE     Z.APD_AP = AP_ID
                       AND APD_NDT IN (801,
                                       802,
                                       836,
                                       835)),
               AT_ST
          INTO L_AP_ID,
               L_AP_TP,
               L_NDT,
               L_AT_ST
          FROM ACT JOIN APPEAL ON AP_ID = AT_AP
         WHERE AT_ID = P_AT_ID;

        IF L_AP_TP != 'SS'
        THEN
            RETURN 0;
        END IF;

        SELECT COUNT (1)
          INTO L_CHECK1
          FROM act a JOIN AT_DOCUMENT T ON (t.atd_at = a.at_id)
         WHERE     a.at_main_link = P_AT_ID
               AND a.at_tp = 'APOP'
               AND T.ATD_NDT = 804
               AND T.HISTORY_STATUS = 'A';

        /* Ініціативним документом звернення є «Повідомлення/інформація про сім’ю/особу, яка перебуває у СЖО» ndt_id=802 або «Звернення з кабінету ОСП» ndt_id=835:
        - статус рішення SR і у рішенні відсутній документ:
        - «Акт оцінки потреб сім’ї/особи» ndt_id=804 */

        IF (L_NDT IN (802, 835) AND L_AT_ST = 'SR' AND L_CHECK1 = 0)
        THEN
            RETURN 1;
        END IF;

        SELECT MAX (
                   CASE
                       WHEN C1 > 1 AND C2 - C1 = 1 THEN 1
                       WHEN C1 = 1 AND C2 = 0 THEN 1
                       ELSE 0
                   END)
          INTO L_CHECK2
          FROM (SELECT (SELECT COUNT (*)
                          FROM AT_SIGNERS Z
                         WHERE     Z.ATI_ATD = T.ATD_ID
                               AND Z.HISTORY_STATUS = 'A')    AS C1,
                       (SELECT COUNT (*)
                          FROM AT_SIGNERS Z
                         WHERE     Z.ATI_ATD = T.ATD_ID
                               AND Z.HISTORY_STATUS = 'A'
                               AND Z.ATI_IS_SIGNED = 'T')     AS C2
                  FROM AT_DOCUMENT T
                 WHERE     T.ATD_AT = P_AT_ID
                       AND T.ATD_NDT IN (850)
                       AND T.HISTORY_STATUS = 'A') T;

        SELECT MAX (CASE WHEN C1 - C2 = 1 THEN 1 ELSE 0 END)
          INTO L_CHECK3
          FROM (SELECT COUNT (*)                                             AS c1,
                       COUNT (CASE WHEN S.ATI_IS_SIGNED = 'T' THEN 1 END)    AS c2
                  FROM AT_DOCUMENT  T
                       JOIN AT_SIGNERS S ON (S.ATI_ATD = T.ATD_ID)
                 WHERE     T.ATD_AT = P_AT_ID
                       AND T.ATD_NDT IN (851)
                       AND T.HISTORY_STATUS = 'A'
                       AND S.HISTORY_STATUS = 'A');

        /*ІІ Ініціативним документом звернення є «Заява про надання соціальних послуг» ndt_id=801 або «Заява про надання соціальної послуги медіації» ndt_id=836:
        1) статус рішення SR/O.SR:
        - у рішенні відсутні документи:
        -- «Акт оцінки потреб сім’ї/особи» ndt_id=804
        -- «Рішення про надання / відмову в наданні соціальних послуг» ndt_id=850 з накладеним КЕП першого підписанта
        - документу «Рішення про надання / відмову в наданні соціальних послуг» ndt_id=850 не додано другого підписанта
        2) статус рішення SN/O.SN і у рішенні відсутній документ:
        - «Повідомлення про надання / відмову в наданні соціальних послуг» ndt_id=851 з накладеним КЕП*/

        IF (       L_NDT IN (801, 836)
               AND L_AT_ST IN ('SR', 'O.SR')
               AND (L_CHECK1 = 0 AND L_CHECK2 = 1)
            OR     L_NDT IN (801, 836)
               AND L_AT_ST IN ('SN', 'O.SN')
               AND L_CHECK3 = 0)
        THEN
            RETURN 1;
        END IF;

        RETURN 0;
    END;

    -- ##113010 Доступність кнопки «Підписати» у рішеннях по SS-зверненнях при відмові
    FUNCTION GET_IS_BLOCK_SIGN_4REJ (P_AT_ID NUMBER)
        RETURN NUMBER
    IS
        L_AP_ID    NUMBER (10);
        L_AP_TP    VARCHAR2 (10);
        L_AT_ST    VARCHAR2 (10);
        L_REZ      NUMBER (10);
        L_NDT      NUMBER;
        L_CHECK1   NUMBER;
        L_CHECK2   NUMBER;
        L_CHECK3   NUMBER;
        L_CHECK4   NUMBER;
    BEGIN
        SELECT AP_ID,
               AP_TP,
               (SELECT MAX (APD_NDT)
                  FROM AP_DOCUMENT Z
                 WHERE     Z.APD_AP = AP_ID
                       AND APD_NDT IN (801,
                                       802,
                                       836,
                                       835)),
               AT_ST
          INTO L_AP_ID,
               L_AP_TP,
               L_NDT,
               L_AT_ST
          FROM ACT JOIN APPEAL ON AP_ID = AT_AP
         WHERE AT_ID = P_AT_ID;

        IF L_AP_TP != 'SS'
        THEN
            RETURN 0;
        END IF;

        SELECT COUNT (1)
          INTO L_CHECK1
          FROM act a JOIN AT_DOCUMENT T ON (t.atd_at = a.at_id)
         WHERE     a.at_main_link = P_AT_ID
               AND a.at_tp = 'APOP'
               AND T.ATD_NDT = 804
               AND T.HISTORY_STATUS = 'A';

        /* Ініціативним документом звернення є «Повідомлення/інформація про сім’ю/особу, яка перебуває у СЖО» ndt_id=802 або «Звернення з кабінету ОСП» ndt_id=835:
        - статус рішення SR і у рішенні відсутній документ:
        - «Акт оцінки потреб сім’ї/особи» ndt_id=804 */

        IF (L_NDT IN (802, 835) AND L_AT_ST = 'SR' AND L_CHECK1 = 0)
        THEN
            RETURN 1;
        END IF;

        SELECT MAX (CASE WHEN C1 < 2 OR C2 = 0 THEN 1 ELSE 0 END),
               MAX (CASE WHEN C1 > c2 AND c2 > 0 THEN 1 ELSE 0 END)
          INTO L_CHECK2, l_check4
          FROM (SELECT (SELECT COUNT (*)
                          FROM AT_SIGNERS Z
                         WHERE     Z.ATI_ATD = T.ATD_ID
                               AND Z.HISTORY_STATUS = 'A')    AS C1,
                       (SELECT COUNT (*)
                          FROM AT_SIGNERS Z
                         WHERE     Z.ATI_ATD = T.ATD_ID
                               AND Z.HISTORY_STATUS = 'A'
                               AND Z.ATI_IS_SIGNED = 'T')     AS C2
                  FROM AT_DOCUMENT T
                 WHERE     T.ATD_AT = P_AT_ID
                       AND T.ATD_NDT IN (850)
                       AND T.HISTORY_STATUS = 'A') T;

        SELECT MAX (CASE WHEN C2 < C1 THEN 1 ELSE 0 END)
          INTO L_CHECK3
          FROM (SELECT COUNT (*)                                             AS c1,
                       COUNT (CASE WHEN S.ATI_IS_SIGNED = 'T' THEN 1 END)    AS c2
                  FROM AT_DOCUMENT  T
                       JOIN AT_SIGNERS S ON (S.ATI_ATD = T.ATD_ID)
                 WHERE     T.ATD_AT = P_AT_ID
                       AND T.ATD_NDT IN (851)
                       AND T.HISTORY_STATUS = 'A'
                       AND S.HISTORY_STATUS = 'A');

        /*ІІ Ініціативним документом звернення є «Заява про надання соціальних послуг» ndt_id=801 або «Заява про надання соціальної послуги медіації» ndt_id=836:
        1) статус рішення SR/O.SR:
        - у рішенні відсутні документи:
        -- «Акт оцінки потреб сім’ї/особи» ndt_id=804
        -- «Рішення про надання / відмову в наданні соціальних послуг» ndt_id=850 з накладеним КЕП першого підписанта
        - документу «Рішення про надання / відмову в наданні соціальних послуг» ndt_id=850 не додано другого підписанта
        2) статус рішення SN/O.SN і у рішенні відсутній документ:
        - «Повідомлення про надання / відмову в наданні соціальних послуг» ndt_id=851 з накладеним КЕП*/

        IF (       L_NDT IN (801, 836)
               AND L_AT_ST IN ('SR', 'O.SR')
               AND (L_CHECK1 = 0 AND L_CHECK2 = 1)
            OR     L_NDT IN (801, 836)
               AND L_AT_ST IN ('SN', 'O.SN')
               AND (L_CHECK3 = 0 AND L_CHECK4 = 0))
        THEN
            RETURN 1;
        END IF;

        RETURN 0;
    END;

    -- #86119
    FUNCTION GET_RIGHT_BLOCK_FLAG (P_AT_ID IN NUMBER)
        RETURN VARCHAR2
    IS
        L_C1   NUMBER;
        L_C2   NUMBER;
    BEGIN
        SELECT (SELECT COUNT (*)
                  FROM AP_DOCUMENT  D
                       JOIN AP_DOCUMENT_ATTR DA ON (DA.APDA_APD = D.APD_ID)
                 WHERE     D.APD_AP = T.AT_AP
                       AND (   D.APD_NDT IN (801) AND DA.APDA_NDA IN (1871)
                            OR D.APD_NDT IN (802) AND DA.APDA_NDA IN (1948)
                            OR D.APD_NDT IN (803) AND DA.APDA_NDA IN (2528)
                            OR D.APD_NDT IN (836) AND DA.APDA_NDA IN (3446)
                            OR D.APD_NDT IN (835) AND DA.APDA_NDA IN (3265))
                       AND D.HISTORY_STATUS = 'A'
                       AND DA.APDA_VAL_STRING = 'T')    AS C1,
               (SELECT COUNT (*)
                  FROM AT_INCOME_CALC C
                 WHERE C.AIC_AT = T.AT_ID)              AS C2
          INTO L_C1, L_C2
          FROM V_ACT T
         WHERE T.AT_ID = P_AT_ID;

        RETURN CASE
                   WHEN L_C1 > 0 AND L_C2 > 0 THEN 'F'               -- #87960
                   WHEN L_C1 = 0 THEN 'F'
                   ELSE 'T'
               END;
    END;

    -- Протокол обробки акту
    PROCEDURE GET_ACT_LOG (P_AT_ID IN NUMBER, RES_CUR OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN RES_CUR FOR
              SELECT T.ATL_ID
                         AS LOG_ID,
                     T.ATL_AT
                         AS LOG_OBJ,
                     T.ATL_TP
                         AS LOG_TP,
                     ST.DIC_NAME
                         AS LOG_ST_NAME,
                     STO.DIC_NAME
                         AS LOG_ST_OLD_NAME,
                     HS.HS_DT
                         AS LOG_HS_DT,
                     NVL (TOOLS.GETUSERLOGIN (HS.HS_WU), 'Автоматично')
                         AS LOG_HS_AUTHOR,
                     USS_NDI.RDM$MSG_TEMPLATE.GETMESSAGETEXT (T.ATL_MESSAGE)
                         AS LOG_MESSAGE
                FROM AT_LOG T
                     LEFT JOIN USS_NDI.V_DDN_AT_PDSP_ST ST
                         ON (ST.DIC_VALUE = T.ATL_ST)
                     LEFT JOIN USS_NDI.V_DDN_AT_PDSP_ST STO
                         ON (STO.DIC_VALUE = T.ATL_ST_OLD)
                     LEFT JOIN V_HISTSESSION HS ON (HS.HS_ID = T.ATL_HS)
               WHERE T.ATL_AT = P_AT_ID
            ORDER BY HS.HS_DT;
    END;

    ------------------------------------------------------------------------
    --------------------------- Визначення права ---------------------------

    -- #70334: дані форми визначення права
    PROCEDURE GET_ACT_RIGHTS (P_AT_ID IN NUMBER, RES_CUR OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN RES_CUR FOR
              SELECT T.*,
                     st.nst_code || ' ' || R.NRR_NAME    AS ARL_NRR_NAME,
                     NVL (R.NRR_TP, 'E')                 AS NRR_TP,
                     CASE
                         WHEN R.NRR_IS_CRITICAL_ERROR = 'T' THEN 'F'
                         ELSE 'T'
                     END                                 AS CAN_SET_RESULT
                FROM AT_RIGHT_LOG T
                     JOIN at_service ats ON ats.ats_id = arl_ats
                     JOIN USS_NDI.V_NDI_RIGHT_RULE R ON (R.NRR_ID = T.ARL_NRR)
                     JOIN uss_ndi.v_ndi_service_type st ON st.nst_id = ats_nst
               WHERE T.ARL_AT = P_AT_ID
            ORDER BY T.ARL_ID;
    END;

    -- ініціалізація визначення права
    -- TODO: потрібна нова реалізація
    PROCEDURE INIT_ACT_RIGHTS (P_AT_ID          ACT.AT_ID%TYPE,
                               P_MESSAGES   OUT SYS_REFCURSOR)
    IS
    BEGIN
        API$CALC_RIGHT_AT.INIT_RIGHT_FOR_ACT (1, P_AT_ID, P_MESSAGES);
    END;

    -- #70334: збереження форми визначення права
    PROCEDURE SAVE_ACT_RIGHTS (P_AT_ID   IN NUMBER,
                               P_AT_ST   IN VARCHAR2,
                               P_CLOB    IN CLOB)
    IS
        L_ARR         T_AT_RIGHT_LOG;
        L_HS          NUMBER := TOOLS.GETHISTSESSION;
        L_ST          VARCHAR2 (10);
        L_TRUE_AMNT   NUMBER;
    BEGIN
        CHECK_CONSISTENSY (P_AT_ID, P_AT_ST);

        EXECUTE IMMEDIATE TYPE2XMLTABLE (PACKAGE_NAME,
                                         't_at_right_log',
                                         TRUE,
                                         TRUE)
            BULK COLLECT INTO L_ARR
            USING P_CLOB;

        IF (L_ARR.COUNT = 0)
        THEN
            RETURN;
        END IF;



        FORALL I IN INDICES OF L_ARR
            UPDATE AT_RIGHT_LOG T
               SET T.ARL_RESULT = L_ARR (I).ARL_RESULT,
                   T.ARL_HS_REWRITE =
                       CASE
                           WHEN NVL (T.ARL_RESULT, 'N') !=
                                NVL (L_ARR (I).ARL_RESULT, 'N')
                           THEN
                               L_HS
                           ELSE
                               T.ARL_HS_REWRITE
                       END
             WHERE T.ARL_ID = L_ARR (I).ARL_ID;

        -- #94793
        FOR xx IN (SELECT * FROM TABLE (l_arr))
        LOOP
            IF (xx.Arl_Calc_Result != xx.ARL_RESULT)
            THEN
                UPDATE at_service t
                   SET t.ats_hs_decision = l_hs
                 WHERE     t.ats_at = p_at_id
                       AND t.ats_id = (SELECT z.arl_ats
                                         FROM at_right_log z
                                        WHERE z.arl_id = xx.arl_id);
            END IF;
        END LOOP;

        UPDATE ACT T
           SET                                        -- t.pd_has_right = 'T',
               T.AT_WU = COALESCE (T.AT_WU, TOOLS.GETCURRWU)
         WHERE T.AT_ID = P_AT_ID;

        SELECT T.AT_ST
          INTO L_ST
          FROM ACT T
         WHERE T.AT_ID = P_AT_ID;

        Api$act.Recalc_Pdsp_Ats_St (p_at_id);      -- 20240404 додав по запиту

        -- #100810
        FOR xx IN (SELECT * FROM TABLE (l_arr))
        LOOP
            IF (xx.Arl_Nrr = 212)
            THEN
                UPDATE at_service t
                   SET t.ats_st =
                           CASE
                               WHEN xx.Arl_Result = 'T' THEN 'PP'
                               ELSE 'PR'
                           END
                 WHERE t.ats_at = p_at_id AND t.ats_id = xx.arl_ats;
            END IF;
        END LOOP;

        API$CALC_RIGHT_AT.Recalc_SS_ALG (p_at_id);
    --API$PC_DECISION.write_pd_log(p_at_id, l_hs, l_st, CHR(38)||'15', l_st);
    END;

    -------------------------------------------------------------------------------
    --------------------------- Рішення про призначення ---------------------------

    -- info:   Выбор информации об документах (файлы)
    PROCEDURE GET_AT_DOCS_FILES (P_AT_ID   IN     NUMBER,
                                 P_MODE    IN     NUMBER,
                                 P_RES        OUT SYS_REFCURSOR)
    IS
    BEGIN
        USS_DOC.API$DOCUMENTS.CLEAR_TMP_WORK_IDS;

        INSERT INTO USS_DOC.TMP_WORK_IDS (X_ID)
            SELECT DISTINCT D.ATD_DH
              FROM V_AT_DOCUMENT  D
                   JOIN act a ON (a.at_id = d.atd_at)
                   LEFT JOIN at_links l ON (l.atk_at = a.at_id)
             WHERE     (       p_mode IN (2,
                                          4,
                                          5,
                                          6)
                           AND a.at_main_link = p_at_id
                        OR     p_mode IN (3)
                           AND (   a.at_main_link = p_at_id
                                OR l.atk_link_at = P_AT_ID)
                        OR     p_mode NOT IN (2,
                                              3,
                                              4,
                                              5,
                                              6)
                           AND a.at_id = P_AT_ID)
                   AND (   p_mode NOT IN (4, 5)
                        OR     p_mode = 4
                           AND a.at_tp = 'APOP'
                           AND a.at_st NOT IN ('AD', 'AR')
                        OR     p_mode = 5
                           AND a.at_tp IN ('ANPOE',
                                           'OKS',
                                           'ANPK',
                                           'ORBD')
                           AND a.at_st IN ('XN',
                                           'XV',
                                           'XS',
                                           'XP',
                                           'TN',
                                           'TV',
                                           'TS',
                                           'TP',
                                           'GN',
                                           'GV',
                                           'GS',
                                           'GP',
                                           'JN',
                                           'JV',
                                           'JS',
                                           'JP'))
                   AND (   P_MODE = 0 AND D.ATD_NDT IN (804     /*, 818, 819*/
                                                           )
                        OR     P_MODE = 1
                           AND D.ATD_NDT IN (850,
                                             851,
                                             852,
                                             853,
                                             854)
                        OR P_MODE = 2 AND a.at_tp IN ('AVOP')
                        OR     P_MODE = 3
                           AND a.at_tp IN ('TCTR', 'IP')
                           AND a.at_st NOT IN ('DR',
                                               'ID',
                                               'IN',
                                               'IR',
                                               'IV',
                                               'IK')
                        OR p_mode = 4 AND d.atd_ndt = 804
                        OR     p_mode = 5
                           AND d.atd_ndt IN (803,
                                             845,
                                             841,
                                             1000)
                        OR     P_MODE = 6
                           AND a.at_tp IN ('NDIS')
                           AND a.at_st IN ('NN', 'NS', 'NP'))
                   AND HISTORY_STATUS = 'A';

        --отримуємо дані файлів з електронного архіву
        USS_DOC.API$DOCUMENTS.GET_SIGNED_ATTACHMENTS (P_RES => P_RES);
    END;

    -- info:   Выбор информации об документах (файлы)
    -- params: p_ap_id       - ідентифікатор обращения
    -- params: p_first_ap_id - ідентифікатор первичного обращения
    PROCEDURE Get_Documents_Files2 (P_AT_ID   IN     NUMBER,
                                    p_Res        OUT SYS_REFCURSOR)
    IS
    BEGIN
        Uss_Doc.Api$documents.Clear_Tmp_Work_Ids;

        INSERT INTO Uss_Doc.Tmp_Work_Ids (x_Id)
            SELECT DISTINCT Apd_Dh
              FROM v_appeal  t
                   JOIN v_act a ON (a.at_ap = t.ap_id)
                   JOIN v_Ap_Document d ON (d.apd_ap = t.ap_id)
             WHERE     a.at_id = p_at_id
                   AND d.apd_ndt = 804
                   AND History_Status = 'A';

        --отримуємо дані файлів з електронного архіву
        Uss_Doc.Api$documents.Get_Attachments (p_Doc_Id        => NULL,
                                               p_Dh_Id         => NULL,
                                               p_Res           => p_Res,
                                               p_Params_Mode   => 3);
    END;

    FUNCTION is_emergency (p_ap_id IN NUMBER)
        RETURN NUMBER
    IS
        l_cnt   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO l_cnt
          FROM AP_DOCUMENT_ATTR A JOIN AP_DOCUMENT D ON A.APDA_APD = D.APD_ID
         WHERE     A.APDA_AP = p_ap_id
               AND (   (D.APD_NDT = 801 AND A.APDA_NDA = 1870)
                    OR (D.APD_NDT = 802 AND A.APDA_NDA = 1947)
                    OR (D.APD_NDT = 803 AND A.APDA_NDA = 2032))
               AND A.APDA_VAL_STRING = 'T';

        RETURN CASE WHEN l_cnt > 0 THEN 1 ELSE 0 END;
    END;

    PROCEDURE GET_ACT_ASSIGNMENT (P_AT_ID     IN     NUMBER,
                                  FEAT_CUR       OUT SYS_REFCURSOR,
                                  FLAGS_CUR      OUT SYS_REFCURSOR,
                                  DOC_CUR        OUT SYS_REFCURSOR,
                                  ATTR_CUR       OUT SYS_REFCURSOR,
                                  FILE_CUR       OUT SYS_REFCURSOR,
                                  SERV_CUR       OUT SYS_REFCURSOR)
    IS
        L_PC         PERSONALCASE.PC_ID%TYPE;
        l_org_to     NUMBER := tools.getcurrorgto;
        l_has_apop   NUMBER;
    BEGIN
        SELECT AT_PC
          INTO L_PC
          FROM ACT
         WHERE AT_ID = P_AT_ID;

        SELECT CASE WHEN COUNT (*) > 0 THEN 1 ELSE 0 END
          INTO l_has_apop
          FROM act t JOIN act apop ON (apop.at_main_link = t.at_id)
         WHERE apop.at_st NOT IN ('AD', 'AR') AND t.at_id = P_AT_ID;


        OPEN FEAT_CUR FOR
            SELECT T.*
              FROM AT_FEATURES  T
                   JOIN USS_NDI.V_NDI_PD_FEATURE_TYPE FT
                       ON (FT.NFT_ID = T.ATF_NFT)
             WHERE     T.ATF_AT = P_AT_ID
                   AND FT.NFT_VIEW = 'SS'
                   AND t.atf_nft NOT IN (10)
                   AND (       l_org_to IN (33, 32)
                           AND l_has_apop = 1
                           AND t.atf_nft IN (9, 32, 33)
                        OR     l_org_to IN (33, 32)
                           AND l_has_apop = 0
                           AND t.atf_nft IN (9)
                        OR l_org_to NOT IN (33, 32));

        OPEN FLAGS_CUR FOR SELECT CASE
                                      WHEN     (SELECT COUNT (*)
                                                  FROM AT_DOCUMENT Z
                                                 WHERE     Z.ATD_AT = T.AT_ID
                                                       AND Z.ATD_NDT IN (804)
                                                       AND Z.HISTORY_STATUS =
                                                           'A') =
                                               0
                                           AND T.AT_ST = 'SP1'
                                      THEN
                                          1
                                      ELSE
                                          0
                                  END    AS IS_RNSP_NEED_DOC,
                                  CASE
                                      WHEN (SELECT COUNT (*)
                                              FROM AT_FEATURES  F1
                                                   JOIN AT_FEATURES F2
                                                       ON (    F2.ATF_AT =
                                                               T.AT_ID
                                                           AND F2.ATF_NFT =
                                                               33)
                                             WHERE     F1.ATF_AT = T.AT_ID
                                                   AND F1.ATF_NFT = 32
                                                   AND (       T.AT_ST = 'R0'
                                                           AND F1.ATF_VAL_STRING =
                                                               'T'
                                                           AND F2.ATF_VAL_STRING =
                                                               'F'
                                                        OR     T.AT_ST IN
                                                                   ('O.R0',
                                                                    'O.SR')
                                                           AND F1.ATF_VAL_STRING =
                                                               'T'
                                                           AND F2.ATF_VAL_STRING =
                                                               'T')) >
                                           0
                                      THEN
                                          1
                                      ELSE
                                          0
                                  END    AS CAN_FEATURES_EDIT,
                                  CASE
                                      WHEN     (SELECT COUNT (*)
                                                  FROM AT_FEATURES F
                                                 WHERE     F.ATF_AT = T.AT_ID
                                                       AND F.ATF_NFT = 9
                                                       AND F.ATF_VAL_ID
                                                               IS NOT NULL) >
                                               0
                                           AND T.AT_ST = 'SC'
                                      THEN
                                          1
                                      ELSE
                                          0
                                  END    AS CAN_SEND_PROVIDER,
                                  -- #107537
                                  CASE
                                      WHEN T.AT_ST = 'SR'
                                      THEN
                                          CASE
                                              WHEN     (SELECT COUNT (*)
                                                          FROM AT_FEATURES F
                                                         WHERE     F.ATF_AT =
                                                                   T.AT_ID
                                                               AND F.ATF_NFT IN
                                                                       (33)
                                                               AND F.ATF_VAL_STRING =
                                                                   'T') =
                                                       1
                                                   AND is_emergency (t.at_ap) =
                                                       1
                                              THEN
                                                  0
                                              WHEN (SELECT COUNT (*)
                                                      FROM AT_FEATURES F
                                                     WHERE     F.ATF_AT =
                                                               T.AT_ID
                                                           AND F.ATF_NFT IN
                                                                   (32, 33)
                                                           AND F.ATF_VAL_STRING =
                                                               'T') >
                                                   1
                                              THEN
                                                  1
                                          END
                                      ELSE
                                          0
                                  END    AS CAN_PROVE_SR
                             FROM ACT T
                            WHERE T.AT_ID = P_AT_ID;

        OPEN DOC_CUR FOR
            SELECT d.*,
                   t.ap_num
                       AS apd_ap_name,
                   uss_person.api$sc_tools.GET_PIB (pp.app_sc)
                       AS apd_app_name,
                   atp.DIC_NAME
                       AS apd_app_tp_name,
                   tp.ndt_name
                       AS apd_ndt_name,
                   (SELECT MAX (a.Apda_Val_String)
                      FROM V_Ap_Document_Attr  a
                           JOIN Uss_Ndi.v_Ndi_Document_Attr n
                               ON     a.Apda_Nda = n.Nda_Id
                                  AND n.Nda_Class = 'DSN'
                     WHERE a.Apda_Apd = d.Apd_Id AND a.History_Status = 'A')
                       AS apd_Seria_Num,
                   st.DIC_SNAME
                       AS Apd_Vf_Name
              FROM v_appeal  t
                   JOIN v_act a ON (a.at_ap = t.ap_id)
                   JOIN v_ap_document d ON (d.apd_ap = t.ap_id)
                   LEFT JOIN v_ap_person pp
                       ON (pp.app_ap = t.ap_id AND d.apd_app = pp.app_id)
                   LEFT JOIN uss_ndi.v_ddN_app_tp atp
                       ON (atp.DIC_VALUE = pp.app_tp)
                   JOIN uss_ndi.v_ndi_document_type tp
                       ON (tp.ndt_id = d.apd_ndt)
                   LEFT JOIN v_verification v ON (v.vf_id = d.apd_vf)
                   LEFT JOIN uss_ndi.v_ddn_vf_st st
                       ON (st.DIC_VALUE = v.vf_st)
             WHERE     a.at_id = P_AT_ID
                   AND d.apd_ndt = 804
                   AND d.history_status = 'A';


        OPEN ATTR_CUR FOR
            SELECT attr.*
              FROM v_appeal  t
                   JOIN v_act a ON (a.at_ap = t.ap_id)
                   JOIN v_ap_document d ON (d.apd_ap = t.ap_id)
                   JOIN v_ap_document_attr attr ON (attr.apda_apd = d.apd_id)
             WHERE     a.at_id = P_AT_ID
                   AND d.apd_ndt = 804
                   AND attr.history_status = 'A';

        Get_Documents_Files2 (p_at_id, file_cur);

        /* OPEN DOC_CUR FOR
           SELECT T.*,
                  TP.NDT_NAME AS ATD_NDT_NAME,
                  (SELECT MAX(Z.DIC_NAME)
                     FROM ACT A
                     JOIN USS_NDI.V_DDN_CASE_CLASS Z
                       ON (Z.DIC_VALUE = A.AT_CASE_CLASS)
                    WHERE A.AT_ID = T.ATD_AT) AS AT_CASE_CLASS_NAME
             FROM AT_DOCUMENT T
             JOIN act a ON (a.at_id = t.atd_at)
             JOIN USS_NDI.V_NDI_DOCUMENT_TYPE TP
               ON (TP.NDT_ID = T.ATD_NDT)
            WHERE T.ATD_AT = P_AT_ID
              AND T.ATD_NDT IN (804)
              AND T.HISTORY_STATUS = 'A';

         OPEN ATTR_CUR FOR
           SELECT ATTR.*,
                  D.ATD_DOC AS DOC_ID
             FROM V_AT_DOCUMENT D
             JOIN act a ON (a.at_id = d.atd_at)
             JOIN V_AT_DOCUMENT_ATTR ATTR
               ON (ATTR.ATDA_ATD = D.ATD_ID)
            WHERE D.ATD_AT = P_AT_ID
              AND D.ATD_NDT IN (804)
              AND ATTR.HISTORY_STATUS = 'A';

         GET_AT_DOCS_FILES(P_AT_ID, 0, FILE_CUR);*/


        get_act_services (p_at_id, SERV_CUR);
    /*OPEN SERV_CUR FOR
    SELECT S.ATS_ID,
           ST.NST_ID,
           ST.NST_CODE || ' ' || ST.NST_NAME AS NST_NAME,
           'Звернення' AS SRC,
           CC.DIC_NAME AS AT_CASE_CLASS_NAME,
           (CASE
             WHEN EXISTS
              (SELECT *
                     FROM (SELECT REGEXP_SUBSTR(TEXT, '[^(\,)]+', 1, LEVEL) AS NST_ID
                             FROM (SELECT ZT.ATDA_VAL_STRING AS TEXT
                                     FROM AT_DOCUMENT_ATTR ZT
                                    WHERE ZT.ATDA_NDA IN (2111, 2112)
                                      AND ZT.ATDA_AT = T.AT_ID
                                      AND ZT.HISTORY_STATUS = 'A')
                           CONNECT BY LENGTH(REGEXP_SUBSTR(TEXT,
                                                           '[^(\,)]+',
                                                           1,
                                                           LEVEL)) > 0) Z
                    WHERE Z.NST_ID = ST.NST_ID) THEN
              ''
             ELSE
              'Ні'
           END) AS IS_NEED
      FROM ACT T
      LEFT JOIN USS_NDI.V_DDN_CASE_CLASS CC
        ON (CC.DIC_VALUE = T.AT_CASE_CLASS)
      JOIN AT_SERVICE S
        ON (S.ATS_AT = T.AT_ID)
      JOIN USS_NDI.V_NDI_SERVICE_TYPE ST
        ON (ST.NST_ID = S.ATS_NST)
     WHERE 1 = 1
       AND T.AT_ID = P_AT_ID
       AND S.HISTORY_STATUS = 'A'
    UNION
    SELECT NULL AS ATS_ID,
           ST.NST_ID,
           ST.NST_CODE || ' ' || ST.NST_NAME AS NST_NAME,
           'Акт' AS SRC,
           CC.DIC_NAME AS AT_CASE_CLASS_NAME,
           'Так' AS IS_NEED
      FROM ACT T
      LEFT JOIN USS_NDI.V_DDN_CASE_CLASS CC
        ON (CC.DIC_VALUE = T.AT_CASE_CLASS)
      JOIN USS_NDI.V_NDI_SERVICE_TYPE ST
        ON (ST.NST_ID IN
           (SELECT REGEXP_SUBSTR(TEXT, '[^(\,)]+', 1, LEVEL) AS NST_ID
               FROM (SELECT ZT.ATDA_VAL_STRING AS TEXT
                       FROM AT_DOCUMENT_ATTR ZT
                      WHERE ZT.ATDA_NDA IN (2111, 2112)
                        AND ZT.ATDA_AT = T.AT_ID
                        AND ZT.HISTORY_STATUS = 'A') Z
             CONNECT BY LENGTH(REGEXP_SUBSTR(TEXT, '[^(\,)]+', 1, LEVEL)) > 0))
     WHERE T.AT_ID = P_AT_ID;*/

    END;

    PROCEDURE get_act_services (p_at_id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT T.*,
                   ST.NST_CODE || ' ' || ST.NST_NAME                             AS ATS_NST_NAME,
                   S.DIC_NAME                                                    AS ATS_ST_NAME,
                   /*(SELECT MAX(CASE WHEN z.arl_nrr = 222 THEN 'Безоплатно'
                                WHEN z.arl_nrr = 224 THEN 'Платно'
                                WHEN z.arl_nrr = 225 THEN 'Диференційовано'
                           END)
                      FROM at_right_log z
                     WHERE z.arl_ats = t.ats_id
                       AND z.arl_result = 'T'
                       AND z.arl_nrr in (222, 224, 225)
                       AND EXISTS (SELECT * FROM at_right_log zz WHERE zz.arl_at = t.ats_at AND zz.arl_nrr = 381 AND zz.arl_result = 'T')
                    )*/
                   m.DIC_NAME                                                    AS ats_prov_method,
                   NVL (tools.GetUserPib (hs.hs_wu), 'Визначено автоматично')    AS ats_hs_decision_pib
              FROM AT_SERVICE  T
                   LEFT JOIN USS_NDI.V_DDN_TCTR_ATS_ST S
                       ON (S.DIC_VALUE = T.ATS_ST)
                   JOIN USS_NDI.V_NDI_SERVICE_TYPE ST
                       ON (ST.NST_ID = T.ATS_NST)
                   LEFT JOIN uss_ndi.v_ddn_ss_method m
                       ON (m.DIC_VALUE = t.ats_ss_method)
                   LEFT JOIN histsession hs ON (hs.hs_id = t.ats_hs_decision)
             WHERE T.ATS_AT = P_AT_ID;
    END;

    -- FOR DELETE
    PROCEDURE GET_NEED_DOCS (P_AT_ID     IN     NUMBER,
                             FLAGS_CUR      OUT SYS_REFCURSOR,
                             DOC_CUR        OUT SYS_REFCURSOR,
                             ATTR_CUR       OUT SYS_REFCURSOR,
                             FILE_CUR       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN FLAGS_CUR FOR SELECT CASE
                                      WHEN     (SELECT COUNT (*)
                                                  FROM AT_DOCUMENT Z
                                                 WHERE     Z.ATD_AT = T.AT_ID
                                                       AND Z.ATD_NDT IN (804)
                                                       AND Z.HISTORY_STATUS =
                                                           'A') =
                                               0
                                           AND T.AT_ST = 'SP1'
                                      THEN
                                          1
                                      ELSE
                                          0
                                  END    AS IS_RNSP_NEED_DOC
                             FROM ACT T
                            WHERE T.AT_ID = P_AT_ID;

        OPEN DOC_CUR FOR
            SELECT T.*,
                   TP.NDT_NAME                               AS ATD_NDT_NAME,
                   (SELECT MAX (Z.DIC_NAME)
                      FROM USS_NDI.V_DDN_CASE_CLASS Z
                     WHERE Z.DIC_VALUE = A.AT_CASE_CLASS)    AS AT_CASE_CLASS_NAME
              FROM AT_DOCUMENT  T
                   JOIN USS_NDI.V_NDI_DOCUMENT_TYPE TP
                       ON (TP.NDT_ID = T.ATD_NDT)
                   JOIN ACT A ON (A.AT_ID = T.ATD_AT)
             WHERE     T.ATD_AT = P_AT_ID
                   AND T.ATD_NDT IN (804                        /*, 818, 819*/
                                        )
                   AND T.HISTORY_STATUS = 'A';

        OPEN ATTR_CUR FOR
            SELECT ATTR.*, D.ATD_DOC AS DOC_ID
              FROM V_AT_DOCUMENT  D
                   JOIN V_AT_DOCUMENT_ATTR ATTR ON (ATTR.ATDA_ATD = D.ATD_ID)
             WHERE     D.ATD_AT = P_AT_ID
                   AND D.ATD_NDT IN (804                        /*, 818, 819*/
                                        )
                   AND ATTR.HISTORY_STATUS = 'A';

        GET_AT_DOCS_FILES (P_AT_ID, 0, FILE_CUR);
    END;

    -- налаштування ознак виплат
    PROCEDURE GET_ACT_FEATURES_METADATA (RES_CUR OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN RES_CUR FOR
            SELECT T.*, PT.*, DC.NDC_CODE
              FROM USS_NDI.V_NDI_PD_FEATURE_TYPE  T
                   JOIN USS_NDI.V_NDI_PARAM_TYPE PT ON (PT.PT_ID = T.NFT_PT)
                   LEFT JOIN USS_NDI.V_NDI_DICT_CONFIG DC
                       ON (DC.NDC_ID = PT.PT_NDC);
    END;

    PROCEDURE SAVE_FEATURES (P_AT_ID IN NUMBER, P_CLOB IN CLOB)
    IS
        L_ARR   T_AT_FEATURES;
    BEGIN
        -- raise_application_error(-20000, P_CLOB);
        DBMS_SESSION.SET_NLS ('NLS_NUMERIC_CHARACTERS', '''. ''');

        EXECUTE IMMEDIATE TYPE2XMLTABLE (PACKAGE_NAME,
                                         't_at_features',
                                         TRUE,
                                         TRUE)
            BULK COLLECT INTO L_ARR
            USING P_CLOB;

        FOR I IN 1 .. L_ARR.COUNT
        LOOP
            IF     L_ARR (I).DELETED IS NOT NULL
               AND L_ARR (I).DELETED = 1
               AND L_ARR (I).ATF_ID > 0
            THEN
                API$ACT.DELETE_FEATURES (L_ARR (I).ATF_ID);
            ELSE
                API$ACT.SAVE_FEATURES (
                    P_ATF_ID           => L_ARR (I).ATF_ID,
                    P_ATF_AT           => L_ARR (I).ATF_AT,
                    P_ATF_NFT          => L_ARR (I).ATF_NFT,
                    P_ATF_VAL_INT      => L_ARR (I).ATF_VAL_INT,
                    P_ATF_VAL_SUM      => L_ARR (I).ATF_VAL_SUM,
                    P_ATF_VAL_ID       => L_ARR (I).ATF_VAL_ID,
                    P_ATF_VAL_DT       => L_ARR (I).ATF_VAL_DT,
                    P_ATF_VAL_STRING   => L_ARR (I).ATF_VAL_STRING,
                    P_ATF_ATP          => L_ARR (I).ATF_ATP,
                    P_NEW_ID           => L_ARR (I).ATF_ID);
            END IF;

            NULL;
        END LOOP;

        UPDATE ACT
           SET AT_RNSPM =
                   (SELECT ATF_VAL_ID
                      FROM AT_FEATURES
                     WHERE ATF_AT = AT_ID AND ATF_NFT = 9)
         WHERE AT_ID = P_AT_ID;
    END;

    -- "затвердити виплати"
    PROCEDURE APPROVE_ACT (P_AT_ID IN NUMBER, P_AT_ST IN VARCHAR2)
    IS
        l_cnt   NUMBER;
        l_wu    NUMBER := tools.getcurrwu;
    BEGIN
        SELECT COUNT (t.ati_id)
          INTO l_cnt
          FROM at_signers t
         WHERE     t.ati_at = P_AT_ID
               AND t.ati_wu = l_wu
               AND (t.ati_is_signed IS NULL OR t.ati_is_signed = 'F')
               AND t.history_status = 'A';

        IF (l_cnt > 0)
        THEN
            RETURN;
        END IF;

        CHECK_CONSISTENSY (P_AT_ID, P_AT_ST);
        API$ACT.APPROVE_ACT (P_AT_ID);
    END;

    -- Поверенення проекту акту на доопрацювання
    PROCEDURE RETURN_ACT (P_AT_ID    IN ACT.AT_ID%TYPE,
                          P_REASON   IN VARCHAR2,
                          P_AT_ST    IN VARCHAR2)
    IS
    BEGIN
        CHECK_CONSISTENSY (P_AT_ID, P_AT_ST);
        API$ACT.RETURN_ACT (P_AT_ID, P_REASON);
    END;

    -------------------------------------------------------------------------------
    --------------------------- розрахунку доходу ---------------------------

    -- вичитка форми "розрахунку доходу"
    PROCEDURE GET_ACT_INCOMES (P_AT_ID    IN     NUMBER,
                               INFO_CUR      OUT SYS_REFCURSOR,
                               PERS_CUR      OUT SYS_REFCURSOR,
                               DET_CUR       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN INFO_CUR FOR SELECT T.*
                            FROM AT_INCOME_CALC T
                           WHERE T.AIC_AT = P_AT_ID;

        OPEN PERS_CUR FOR
            SELECT P.*,
                   USS_PERSON.API$SC_TOOLS.GET_PIB_SCC (
                       P.APP_SCC)
                       AS APP_PIB,
                   TP.DIC_SNAME
                       AS APP_TP_NAME,
                   (SELECT SUM (Z.AID_FACT_SUM)
                      FROM AT_INCOME_DETAIL Z
                     WHERE     Z.AID_APP = P.APP_ID
                           AND Z.AID_AIC IN
                                   (SELECT AIC_ID
                                      FROM AT_INCOME_CALC
                                     WHERE AIC_AT = T.AT_ID) -- #74105 2021.12.14
                           AND EXISTS
                                   (SELECT *
                                      FROM AP_INCOME ZZ
                                     WHERE     Z.AID_APP =
                                               ZZ.API_APP
                                           AND ZZ.API_MONTH =
                                               Z.AID_MONTH
                                           AND (   ZZ.API_USE_TP
                                                       IS NULL
                                                OR ZZ.API_USE_TP IN
                                                       ('V',
                                                        'VS')))      -- #81112
                                                               )
                       AS AID_FACT_SUM,
                   (SELECT SUM (Z.AID_CALC_SUM)
                      FROM AT_INCOME_DETAIL Z
                     WHERE     Z.AID_APP = P.APP_ID
                           AND Z.AID_AIC IN (SELECT AIC_ID
                                               FROM AT_INCOME_CALC
                                              WHERE AIC_AT = T.AT_ID) -- #74105 2021.12.14
                           AND EXISTS
                                   (SELECT *
                                      FROM AP_INCOME ZZ
                                     WHERE     Z.AID_APP = ZZ.API_APP
                                           AND ZZ.API_MONTH = Z.AID_MONTH
                                           AND (   ZZ.API_USE_TP IS NULL
                                                OR ZZ.API_USE_TP IN
                                                       ('V', 'VS'))) -- #81112
                                                                    )
                       AS AID_CALC_SUM,
                   (SELECT MAX (Z.AID_IS_FAMILY_MEMBER)
                      FROM AT_INCOME_DETAIL Z
                     WHERE Z.AID_APP = P.APP_ID)
                       AS AID_IS_FAMILY_MEMBER
              FROM ACT  T
                   JOIN AP_PERSON P
                       ON (P.APP_AP = T.AT_AP) AND P.HISTORY_STATUS = 'A' --#73632 2021.12.01
                   JOIN USS_NDI.V_DDN_APP_TP TP ON (TP.DIC_VALUE = P.APP_TP)
             WHERE T.AT_ID = P_AT_ID;

        OPEN DET_CUR FOR
            SELECT T.AIS_ID,
                   T.AIS_APP,
                   T.AIS_SRC,
                   T.AIS_START_DT,
                   T.AIS_STOP_DT,
                   T.AIS_FACT_SUM,
                   T.AIS_FINAL_SUM,
                   T.AIS_IS_USE,
                   T.AIS_TP,
                   T.AIS_EXCH_TP,
                   T.AIS_ESV_PAID,
                   T.AIS_ESV_MIN,
                   SRC.DIC_SNAME     AS AIS_SRC_NAME
              FROM AT_INCOME_SRC  T
                   JOIN USS_NDI.V_DDN_PIS_SRC SRC
                       ON (SRC.DIC_VALUE = T.AIS_SRC)
             WHERE     T.AIS_AT = P_AT_ID
                   AND (   EXISTS
                               (SELECT *
                                  FROM AP_INCOME ZZ
                                 WHERE     T.AIS_APP = ZZ.API_APP
                                       AND (   ZZ.API_USE_TP IS NULL
                                            OR ZZ.API_USE_TP IN ('V', 'VS'))) -- #81112
                        OR NOT EXISTS
                               (SELECT *
                                  FROM AP_INCOME ZZ
                                 WHERE T.AIS_APP = ZZ.API_APP))
            UNION ALL
            SELECT D.AIM_APD                  AS AIS_ID,
                   D.AIM_APP                  AS AIS_APP,
                   'DOV'                      AS AIS_SRC,
                   D.AIM_MONTH                AS AIS_START_DT,
                   LAST_DAY (D.AIM_MONTH)     AS AIS_STOP_DT,
                   D.AIM_SUM                  AS AIS_FACT_SUM,
                   D.AIM_SUM                  AS AIS_FINAL_SUM,
                   'T'                        AS AIS_IS_USE,
                   D.AIM_TP                   AS AIS_TP,
                   ''                         AS AIS_EXCH_TP,
                   '1'                        AS AIS_ESV_PAID,
                   '1'                        AS AIS_ESV_MIN,
                   'Довідка'                  AS AIS_SRC_NAME
              FROM V_APD_INCOME_MONTH D JOIN ACT AT ON AT.AT_AP = D.AIM_AP
             WHERE     AT.AT_ID = P_AT_ID
                   AND (   EXISTS
                               (SELECT *
                                  FROM AP_INCOME ZZ
                                 WHERE     D.AIM_APP = ZZ.API_APP
                                       AND ZZ.API_MONTH = D.AIM_MONTH
                                       AND (   ZZ.API_USE_TP IS NULL
                                            OR ZZ.API_USE_TP IN ('V', 'VS'))) -- #81112
                        OR NOT EXISTS
                               (SELECT *
                                  FROM AP_INCOME ZZ
                                 WHERE D.AIM_APP = ZZ.API_APP));
    END;

    PROCEDURE SAVE_ACT_INCOMES (P_AT_ID   IN     NUMBER,
                                P_CLOB    IN     CLOB,
                                MSG_CUR      OUT SYS_REFCURSOR)
    IS
        L_ARR   T_AT_INCOME_SRC;
        L_HS    NUMBER := TOOLS.GETHISTSESSION;
        L_ST    VARCHAR2 (10);
    BEGIN
        IF GET_ISNEED_INCOME (P_AT_ID) = 0
        THEN
            RAISE_APPLICATION_ERROR (
                -20000,
                'Звернення не потребує виконання розрахунку доходу');
        END IF;

        --raise_application_error(-20000, p_clob);
        DBMS_SESSION.SET_NLS ('NLS_NUMERIC_CHARACTERS', '''. ''');

        EXECUTE IMMEDIATE TYPE2XMLTABLE (PACKAGE_NAME,
                                         't_at_income_src',
                                         TRUE,
                                         TRUE)
            BULK COLLECT INTO L_ARR
            USING P_CLOB;

        --raise_application_error(-20000, l_arr.count);

        FORALL I IN INDICES OF L_ARR
            DELETE FROM AT_INCOME_SRC T
                  WHERE T.AIS_ID = L_ARR (I).AIS_ID AND L_ARR (I).DELETED = 1;

        FORALL I IN INDICES OF L_ARR
            UPDATE AT_INCOME_SRC T
               SET T.AIS_TP = L_ARR (I).AIS_TP,
                   T.AIS_FINAL_SUM = L_ARR (I).AIS_FINAL_SUM,
                   T.AIS_ESV_PAID = L_ARR (I).AIS_ESV_PAID,
                   T.AIS_ESV_MIN = L_ARR (I).AIS_ESV_MIN,
                   T.AIS_START_DT =
                       TO_DATE (L_ARR (I).AIS_START_DT,
                                'YYYY-MM-DD"T"HH24:MI:SS'),
                   T.AIS_STOP_DT =
                       TO_DATE (L_ARR (I).AIS_STOP_DT,
                                'YYYY-MM-DD"T"HH24:MI:SS'),
                   T.AIS_IS_USE = L_ARR (I).AIS_IS_USE
             WHERE T.AIS_ID = L_ARR (I).AIS_ID AND L_ARR (I).DELETED = 0;

        FOR XX IN (SELECT *
                     FROM TABLE (L_ARR)
                    WHERE AIS_ID IS NULL)
        LOOP
            INSERT INTO AT_INCOME_SRC T (AIS_TP,
                                         AIS_SRC,
                                         AIS_FINAL_SUM,
                                         AIS_SC,
                                         AIS_ESV_PAID,
                                         AIS_ESV_MIN,
                                         AIS_START_DT,
                                         AIS_STOP_DT,
                                         AIS_AT,
                                         AIS_APP,
                                         AIS_IS_USE)
                     VALUES (
                                XX.AIS_TP,
                                XX.AIS_SRC,
                                XX.AIS_FINAL_SUM,
                                XX.AIS_SC,
                                XX.AIS_ESV_PAID,
                                XX.AIS_ESV_MIN,
                                TO_DATE (XX.AIS_START_DT,
                                         'YYYY-MM-DD"T"HH24:MI:SS'),
                                TO_DATE (XX.AIS_STOP_DT,
                                         'YYYY-MM-DD"T"HH24:MI:SS'),
                                P_AT_ID,
                                XX.AIS_APP,
                                XX.AIS_IS_USE);
        END LOOP;

        SELECT T.AT_ST
          INTO L_ST
          FROM ACT T
         WHERE T.AT_ID = P_AT_ID;

        API$ACT.WRITE_AT_LOG (P_AT_ID,
                              L_HS,
                              L_ST,
                              CHR (38) || '19',
                              L_ST);

        API$CALC_INCOME.CALC_INCOME_FOR_AT (1, P_AT_ID, MSG_CUR);
    --API$PC_DECISION.calc_income_for_pd(1, p_at_id, msg_cur);
    END;

    -- вичитка форми "Дані помісячного розрахунку"
    PROCEDURE GET_PERSON_INFO (P_AIC_ID   IN     NUMBER,
                               P_APP_ID   IN     NUMBER,
                               RES_CUR       OUT SYS_REFCURSOR,
                               LOG_CUR       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN RES_CUR FOR   SELECT T.*
                             FROM AT_INCOME_DETAIL T
                            WHERE T.AID_APP = P_APP_ID AND T.AID_AIC = P_AIC_ID
                         ORDER BY T.AID_MONTH;

        OPEN LOG_CUR FOR
            SELECT T.*
              FROM V_AT_INCOME_LOG  T
                   JOIN AT_INCOME_DETAIL D ON (D.AID_ID = T.AIL_AID)
             WHERE D.AID_APP = P_APP_ID AND D.AID_AIC = P_AIC_ID;
    END;

    ---------------------------------------------------------------------------
    --------------------------- Рішення про відмову ---------------------------

    -- #70334: дані форми "Рішення про відмову"
    PROCEDURE GET_ACT_REJECTS (P_AT_ID IN NUMBER, RES_CUR OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN RES_CUR FOR SELECT T.ARI_ID,
                                T.ARI_AT,
                                T.ARI_NRR,
                                T.ARI_NJR,
                                T.ARI_ATS
                           FROM AT_REJECT_INFO T
                          WHERE T.ARI_AT = P_AT_ID/*UNION
                                                  SELECT NULL    AS ARI_ID,
                                                         ARL_AT  AS ARI_AT,
                                                         ARL_NRR AS ARI_NRR,
                                                         NULL    AS ARI_NJR,
                                                         T.ARL_ATS  AS ARI_ATS
                                                    FROM AT_RIGHT_LOG T
                                                   WHERE T.ARL_AT = P_AT_ID
                                                     AND T.ARL_RESULT = 'F'
                                                     AND NOT EXISTS (SELECT *
                                                            FROM AT_REJECT_INFO Z
                                                           WHERE Z.ARI_NRR = T.ARL_NRR
                                                             AND Z.ARI_AT = T.ARL_AT)*/
                                                  ;
    END;

    -- #70334: збереження форми "Рішення про відмову"
    PROCEDURE SAVE_ACT_REJECTS (P_AT_ID IN NUMBER, P_CLOB IN CLOB)
    IS
    --L_ARR        T_AT_REJECT_INFO;
    --L_HS         NUMBER := TOOLS.GETHISTSESSION;
    --L_ST         VARCHAR2(10);
    --L_ACTION_SQL VARCHAR2(2000);
    BEGIN
        API$ACT.Save_Reject_Infos (P_AT_ID, P_CLOB);
    END;

    -- #70334: підтвердження форми "Рішення про відмову"
    PROCEDURE PROVE_ACT_REJECTS (P_AT_ID     IN     NUMBER,
                                 P_ST           OUT VARCHAR2,
                                 P_ST_NAME      OUT VARCHAR2)
    IS
    --L_ARR        T_AT_REJECT_INFO;
    --L_HS         NUMBER := TOOLS.GETHISTSESSION;
    --L_ST         VARCHAR2(10);
    --L_ACTION_SQL VARCHAR2(2000);
    BEGIN
        Api$act.Recalc_Pdsp_Ats_St (P_AT_ID);
        API$ACT.REJECTS_ACT (P_AT_ID, P_ST, P_ST_NAME);
    END;

    -- #71916: Повернути рішення про відмову
    PROCEDURE REJECT_ACT_REJECT (P_AT_ID     IN     NUMBER,
                                 P_ST           OUT VARCHAR2,
                                 P_ST_NAME      OUT VARCHAR2)
    IS
        L_HS       NUMBER := TOOLS.GETHISTSESSION;
        L_ST       VARCHAR2 (10);
        L_ST_NEW   VARCHAR2 (10);
    BEGIN
        raise_application_error (-20000, 'test');
        API$ACT.REJECT_ACT_REJECT (P_AT_ID, P_ST, P_ST_NAME);
    END;

    ----------------------------------------------------------------------
    --------------------------- Документи акту ---------------------------

    -- Документи акту
    PROCEDURE GET_SS_DOCS (P_AT_ID    IN     NUMBER,
                           P_MODE     IN     NUMBER, -- 0 - призначення, 1 - відхилення
                           P_FLAG        OUT NUMBER,
                           DOC_CUR       OUT SYS_REFCURSOR,
                           ATTR_CUR      OUT SYS_REFCURSOR,
                           FILE_CUR      OUT SYS_REFCURSOR,
                           SIGN_CUR      OUT SYS_REFCURSOR)
    IS
        L_WU   NUMBER := TOOLS.GETCURRWU;
    BEGIN
        SELECT CASE
                   WHEN P_MODE = 1 AND F3 < 2 THEN 1
                   WHEN P_MODE = 0 AND F1 < 5 AND (F2 > 0 OR F4 > 0) THEN 1
                   ELSE 0
               END    AS CAN_ADD_DOC
          INTO P_FLAG
          FROM (SELECT (SELECT COUNT (*)
                          FROM AT_DOCUMENT T
                         WHERE     T.ATD_AT = P_AT_ID
                               AND T.ATD_NDT IN (850,
                                                 851,
                                                 852,
                                                 853,
                                                 854)
                               AND T.HISTORY_STATUS = 'A')    AS F1,
                       (SELECT COUNT (*)
                          FROM AT_DOCUMENT T
                         WHERE     T.ATD_AT = P_AT_ID
                               AND T.ATD_NDT IN (850, 851)
                               AND T.HISTORY_STATUS = 'A')    AS F3,
                       (SELECT COUNT (*)
                          FROM ACT  T
                               JOIN AP_DOCUMENT D ON (D.APD_AP = T.AT_AP)
                         --JOIN AP_DOCUMENT_ATTR A
                         --  ON (A.APDA_APD = D.APD_ID)
                         WHERE     T.AT_ID = P_AT_ID
                               AND D.APD_NDT = 801
                               AND D.HISTORY_STATUS = 'A'-- AND A.APDA_NDA = 1870
                                                         -- AND A.HISTORY_STATUS = 'A'
                                                         /* AND (A.APDA_VAL_STRING IS NULL OR
                                                              A.APDA_VAL_STRING = 'F')*/
                                                         )    AS F2,
                       (SELECT COUNT (*)
                          FROM ACT  T
                               JOIN AP_DOCUMENT D ON (D.APD_AP = T.AT_AP)
                         WHERE     T.AT_ID = P_AT_ID
                               AND D.APD_NDT = 836
                               AND D.HISTORY_STATUS = 'A')    AS F4
                  FROM DUAL) T;

        OPEN DOC_CUR FOR
            SELECT T.*,
                   TP.NDT_NAME                                  AS ATD_NDT_NAME,
                   (SELECT CASE
                               WHEN COUNT (*) > 0 THEN 'T'
                               ELSE 'F'
                           END
                      FROM AT_SIGNERS Z
                     WHERE     Z.ATI_ATD = T.ATD_ID
                           AND Z.HISTORY_STATUS = 'A'
                           AND Z.ATI_WU = L_WU
                           AND (   Z.ATI_IS_SIGNED IS NULL
                                OR Z.ATI_IS_SIGNED = 'F')
                           AND NOT EXISTS
                                   (SELECT *
                                      FROM AT_SIGNERS Q
                                     WHERE     Q.ATI_ATD =
                                               Z.ATI_ATD
                                           AND Q.HISTORY_STATUS =
                                               'A'
                                           AND (   Q.ATI_IS_SIGNED
                                                       IS NULL
                                                OR Q.ATI_IS_SIGNED =
                                                   'F')
                                           AND Q.ATI_ORDER <
                                               Z.ATI_ORDER))    AS CAN_SIGN,
                   (SELECT CASE WHEN COUNT (*) = 1 THEN 'T' ELSE 'F' END
                      FROM AT_SIGNERS Z
                     WHERE     Z.ATI_ATD = T.ATD_ID
                           AND Z.HISTORY_STATUS = 'A'
                           AND (   Z.ATI_IS_SIGNED IS NULL
                                OR Z.ATI_IS_SIGNED = 'F'))      AS LAST_SIGN,
                   CASE
                       WHEN     P_MODE = 1
                            AND T.ATD_NDT IN (850)
                            AND D.AT_ST IN ('SR', 'O.SR')
                       THEN
                           'T'
                       WHEN     P_MODE = 1
                            AND T.ATD_NDT IN (851)
                            AND D.AT_ST IN ('SN', 'O.SN')
                       THEN
                           'T'
                       WHEN     P_MODE = 0
                            AND T.ATD_NDT IN (850, 854)
                            AND D.AT_ST IN ('SR', 'O.SR')
                       THEN
                           'T'
                       WHEN T.ATD_NDT IN (851, 852, 853) AND D.AT_ST = 'WD'
                       THEN
                           'T'
                       /*WHEN T.ATD_NDT IN (850) AND
                            D.AT_ST IN ('SW', 'O.SW') THEN
                        'F'
                       WHEN d.at_st IN ('SA', 'SD', 'O.SA', 'O.SD', 'SGO', 'SU', 'SJ', 'O.SO') THEN
                         'F'
                      WHEN d.at_st IN ('O.SR', 'O.SW', 'O.SN')
                          and exists (SELECT *
                                        FROM at_signers z
                                        join ikis_sysweb.V$ALL_USERS u on (u.wu_id = z.ati_wu)
                                        join v_opfu p on (p.org_id = u.wu_org)
                                       where z.ati_atd = t.atd_id
                                         and z.history_status = 'A'
                                         and z.ati_order = 1
                                         and p.org_to in (32, 33, 34)) THEN
                         'F'*/
                       ELSE
                           'F'                                           --'F'
                   END                                          AS CAN_DELETE
              FROM AT_DOCUMENT  T
                   JOIN USS_NDI.V_NDI_DOCUMENT_TYPE TP
                       ON (TP.NDT_ID = T.ATD_NDT)
                   JOIN ACT D ON (D.AT_ID = T.ATD_AT)
             WHERE     T.ATD_AT = P_AT_ID
                   AND T.ATD_NDT IN (850,
                                     851,
                                     852,
                                     853,
                                     854)
                   AND T.HISTORY_STATUS = 'A';

        OPEN ATTR_CUR FOR
            SELECT ATTR.*, D.ATD_DOC AS DOC_ID
              FROM V_AT_DOCUMENT  D
                   JOIN V_AT_DOCUMENT_ATTR ATTR ON (ATTR.ATDA_ATD = D.ATD_ID)
             WHERE     D.ATD_AT = P_AT_ID
                   AND D.ATD_NDT IN (850,
                                     851,
                                     852,
                                     853,
                                     854)
                   AND ATTR.HISTORY_STATUS = 'A';

        GET_AT_DOCS_FILES (P_AT_ID, 1, FILE_CUR);

        OPEN SIGN_CUR FOR
            SELECT T.*,
                   Api$act.Get_Signer_Name (t.Ati_Sc, t.Ati_Cu, t.Ati_Wu)    AS WU_PIB
              FROM AT_SIGNERS T
             WHERE T.ATI_AT = P_AT_ID AND T.HISTORY_STATUS = 'A';
    END;

    -- Документи зовнішні
    PROCEDURE GET_SECONDARY_DOCS (P_AT_ID    IN     NUMBER,
                                  P_MODE     IN     NUMBER, -- 2 - «Вторинна оцінка потреб», 3 - «Документи договору», 4 - Акт потреб, 5 - #102286: ANPOE/OKS/ANPK/ORBD, 6 - #102290 NDIS
                                  DOC_CUR       OUT SYS_REFCURSOR,
                                  ATTR_CUR      OUT SYS_REFCURSOR,
                                  FILE_CUR      OUT SYS_REFCURSOR,
                                  SIGN_CUR      OUT SYS_REFCURSOR)
    IS
        L_WU   NUMBER := TOOLS.GETCURRWU;
    BEGIN
        OPEN DOC_CUR FOR
            SELECT T.*,
                   TP.NDT_NAME     AS ATD_NDT_NAME,
                   'F'             AS CAN_SIGN,
                   'F'             AS LAST_SIGN,
                   'F'             AS CAN_DELETE
              FROM AT_DOCUMENT  T
                   JOIN act a ON (a.at_id = t.atd_at)
                   LEFT JOIN at_links l ON (l.atk_at = a.at_id)
                   JOIN USS_NDI.V_NDI_DOCUMENT_TYPE TP
                       ON (TP.NDT_ID = T.ATD_NDT)
             WHERE     (       p_mode IN (2,
                                          4,
                                          5,
                                          6)
                           AND a.at_main_link = p_at_id
                        OR     p_mode IN (3)
                           AND (   a.at_main_link = p_at_id
                                OR l.atk_link_at = P_AT_ID)
                        OR     p_mode NOT IN (2,
                                              3,
                                              4,
                                              5,
                                              6)
                           AND a.at_id = P_AT_ID)
                   AND (   p_mode NOT IN (4, 5, 6)
                        OR     p_mode = 4
                           AND a.at_tp = 'APOP'
                           AND a.at_st NOT IN ('AD', 'AR')
                        OR     p_mode = 6
                           AND a.at_tp = 'NDIS'
                           AND a.at_st IN ('NN', 'NS', 'NP')
                        OR     p_mode = 5
                           AND a.at_tp IN ('ANPOE',
                                           'OKS',
                                           'ANPK',
                                           'ORBD')
                           AND a.at_st IN ('XN',
                                           'XV',
                                           'XS',
                                           'XP',
                                           'TN',
                                           'TV',
                                           'TS',
                                           'TP',
                                           'GN',
                                           'GV',
                                           'GS',
                                           'GP',
                                           'JN',
                                           'JV',
                                           'JS',
                                           'JP'))
                   AND (   p_mode = 2 AND a.at_tp = 'AVOP'
                        OR     p_mode = 3
                           AND a.at_tp IN ('TCTR', 'IP')
                           AND a.at_st NOT IN ('DR',
                                               'ID',
                                               'IN',
                                               'IR',
                                               'IV',
                                               'IK')
                        OR p_mode = 4 AND t.atd_ndt = 804
                        OR     p_mode = 5
                           AND t.atd_ndt IN (803,
                                             845,
                                             841,
                                             1000)
                        OR p_mode = 6 AND a.at_tp = 'NDIS'
                        OR 1 = 2)
                   AND T.HISTORY_STATUS = 'A';

        OPEN ATTR_CUR FOR
            SELECT ATTR.*, D.ATD_DOC AS DOC_ID
              FROM V_AT_DOCUMENT  D
                   JOIN act a ON (a.at_id = d.atd_at)
                   LEFT JOIN at_links l ON (l.atk_at = a.at_id)
                   JOIN V_AT_DOCUMENT_ATTR ATTR ON (ATTR.ATDA_ATD = D.ATD_ID)
             WHERE     (       p_mode IN (2,
                                          4,
                                          5,
                                          6)
                           AND a.at_main_link = p_at_id
                        OR     p_mode IN (3)
                           AND (   a.at_main_link = p_at_id
                                OR l.atk_link_at = P_AT_ID)
                        OR     p_mode NOT IN (2,
                                              3,
                                              4,
                                              5,
                                              6)
                           AND a.at_id = P_AT_ID)
                   AND (   p_mode NOT IN (4, 5, 6)
                        OR     p_mode = 4
                           AND a.at_tp = 'APOP'
                           AND a.at_st NOT IN ('AD', 'AR')
                        OR     p_mode = 6
                           AND a.at_tp = 'NDIS'
                           AND a.at_st IN ('NN', 'NS', 'NP')
                        OR     p_mode = 5
                           AND a.at_tp IN ('ANPOE',
                                           'OKS',
                                           'ANPK',
                                           'ORBD')
                           AND a.at_st IN ('XN',
                                           'XV',
                                           'XS',
                                           'XP',
                                           'TN',
                                           'TV',
                                           'TS',
                                           'TP',
                                           'GN',
                                           'GV',
                                           'GS',
                                           'GP',
                                           'JN',
                                           'JV',
                                           'JS',
                                           'JP'))
                   AND (   p_mode = 2 AND a.at_tp = 'AVOP'
                        OR     p_mode = 3
                           AND a.at_tp IN ('TCTR', 'IP')
                           AND a.at_st NOT IN ('DR',
                                               'ID',
                                               'IN',
                                               'IR',
                                               'IV',
                                               'IK')
                        OR p_mode = 4 AND d.atd_ndt = 804
                        OR     p_mode = 5
                           AND d.atd_ndt IN (803,
                                             845,
                                             841,
                                             1000)
                        OR p_mode = 6 AND a.at_tp = 'NDIS'
                        OR 1 = 2)
                   AND ATTR.HISTORY_STATUS = 'A';

        GET_AT_DOCS_FILES (P_AT_ID, p_mode, FILE_CUR);

        OPEN SIGN_CUR FOR
            SELECT T.*,
                   Api$act.Get_Signer_Name (t.Ati_Sc, t.Ati_Cu, t.Ati_Wu)    AS WU_PIB
              FROM AT_SIGNERS  T
                   JOIN at_document d ON (d.atd_id = t.ati_atd)
                   JOIN act a ON (a.at_id = d.atd_at)
                   LEFT JOIN at_links l ON (l.atk_at = a.at_id)
             WHERE     (       p_mode IN (2,
                                          4,
                                          5,
                                          6)
                           AND a.at_main_link = p_at_id
                        OR     p_mode IN (3)
                           AND (   a.at_main_link = p_at_id
                                OR l.atk_link_at = P_AT_ID)
                        OR     p_mode NOT IN (2,
                                              3,
                                              4,
                                              5,
                                              6)
                           AND a.at_id = P_AT_ID)
                   AND (   p_mode NOT IN (4, 5, 6)
                        OR     p_mode = 4
                           AND a.at_tp = 'APOP'
                           AND a.at_st NOT IN ('AD', 'AR')
                        OR     p_mode = 6
                           AND a.at_tp = 'NDIS'
                           AND a.at_st IN ('NN', 'NS', 'NP')
                        OR     p_mode = 5
                           AND a.at_tp IN ('ANPOE',
                                           'OKS',
                                           'ANPK',
                                           'ORBD')
                           AND a.at_st IN ('XN',
                                           'XV',
                                           'XS',
                                           'XP',
                                           'TN',
                                           'TV',
                                           'TS',
                                           'TP',
                                           'GN',
                                           'GV',
                                           'GS',
                                           'GP',
                                           'JN',
                                           'JV',
                                           'JS',
                                           'JP'))
                   AND (   p_mode = 2 AND a.at_tp = 'AVOP'
                        OR     p_mode = 3
                           AND a.at_tp IN ('TCTR', 'IP')
                           AND a.at_st NOT IN ('DR',
                                               'ID',
                                               'IN',
                                               'IR',
                                               'IV',
                                               'IK')
                        OR p_mode = 4 AND d.atd_ndt = 804
                        OR     p_mode = 5
                           AND d.atd_ndt IN (803,
                                             845,
                                             841,
                                             1000)
                        OR p_mode = 6 AND a.at_tp = 'NDIS'
                        OR 1 = 2)
                   AND T.HISTORY_STATUS = 'A';
    END;

    -- #91319: Список документів які можна створити
    PROCEDURE GET_DOC_TP_LIST (P_AT_ID IN NUMBER, RES_CUR OUT SYS_REFCURSOR)
    IS
        L_HAS_R1   NUMBER
            := CASE
                   WHEN TOOLS.CHECKUSERROLE ('W_ESR_SS_OPER') = TRUE THEN 1
                   ELSE 0
               END;
        L_HAS_R2   NUMBER
            := CASE
                   WHEN TOOLS.CHECKUSERROLE ('W_ESR_SS_APPROVE') = TRUE
                   THEN
                       1
                   ELSE
                       0
               END;
        L_ORG_TO   NUMBER := TOOLS.GETCURRORGTO;
    BEGIN
        /*1) «Рішення про надання / відмову в наданні соціальних послуг» ndt_id in (850):
            АБО
            [- рішення по зверненню має статус SR
            - ознака «Надати в інтернатному закладі» = Ні
            - ознака «Передати на область» = Ні
            - відсутній документ, який намагаються створити, у статусі ‘A’
            - користувач має роль «СП. Спеціаліст з опрацювання справ» (W_ESR_SS_OPER)
            - користувач рівня ТГ/району] --- ця та подібні умови є надлишковими? Якщо статус not like (‘O.xx’) – значить рішення не на області; якщо статус like (‘O.xx’) – значить рішення на області
            АБО
            [- рішення по зверненню має статус O.SR
            - ознака «Надати в інтернатному закладі» = Ні
            - відсутній документ, який намагаються створити, у статусі ‘A’
            - користувач має роль «СП. Спеціаліст з опрацювання справ» (W_ESR_SS_OPER)
            - користувач рівня області]

          2) «Повідомлення про надання / відмову в наданні соціальних послуг» ndt_id in (851):
            АБО
            [- рішення по зверненню має статус SW/SN
            - ознака «Надати в інтернатному закладі» = Ні
            - ознака «Передати на область» = Ні
            - відсутній документ, який намагаються створити, у статусі ‘A’
            - користувач має роль «СП. Підписання рішень» (W_ESR_SS_APPROVE)
            - користувач рівня ТГ/району]
            АБО
            [- рішення по зверненню має статус O.SW/O.SN
            - ознака «Надати в інтернатному закладі» = Ні
            - відсутній документ, який намагаються створити, у статусі ‘A’
            - користувач має роль «СП. Підписання рішень» (W_ESR_SS_APPROVE)
            - користувач рівня ТГ/району/області]

          3) «Клопотання про влаштування особи з інвалідністю, особи похилого віку до інтернатної(го) установи/закладу» ndt_id in (852) та
            «Повідомлення про направлення клопотання про влаштування особи з інвалідністю, особи похилого віку до інтернатної(го) установи/закладу» ndt_id in (853):
            [- рішення по зверненню має статус SW
            - ознака «Надати в інтернатному закладі» = Так --- оскільки поки що для формування не існує окремого документа для передачі на область послуг не в інтернатному закладі замість клопотання / повідомлення про клопотання, то цю умову потрібно відмінити. Додати – коли з’явиться окремий документ --- при цьому ознаку необхідно проставляти, щоб рішення відображувалося у потрібному журналі черг області (за цим повинні слідкувати користувачі)
            - ознака «Передати на область» = Так
            - відсутній документ, який намагаються створити, у статусі ‘A’
            - користувач має роль «СП. Підписання рішень» (W_ESR_SS_APPROVE)
            - користувач рівня ТГ/району]

          4) «Путівка на влаштування до інтернатної(го) установи/закладу» ndt_id in (854):
            АБО
            [- рішення по зверненню має статус SR
            - ознака «Надати в інтернатному закладі» = Так
            - ознака «Передати на область» = Ні
            - відсутній документ, який намагаються створити, у статусі ‘A’
            - користувач має роль «СП. Спеціаліст з опрацювання справ» (W_ESR_SS_OPER)
            - користувач рівня ТГ/району]
            АБО
            [- рішення по зверненню має статус O.SR
            - ознака «Надати в інтернатному закладі» = Так
            - відсутній документ, який намагаються створити, у статусі ‘A’
            - користувач має роль «СП. Спеціаліст з опрацювання справ» (W_ESR_SS_OPER)
            - користувач рівня області]*/

        OPEN RES_CUR FOR
            -- 850
            SELECT T.NDT_ID             AS ID,
                   NDT_IS_HAVE_SCAN     AS CODE,
                   T.NDT_NAME           AS NAME
              FROM USS_NDI.V_NDI_DOCUMENT_TYPE T
             WHERE     T.NDT_ID IN (850)
                   AND L_HAS_R1 = 1
                   AND L_ORG_TO IN (32, 33)
                   AND EXISTS
                           (SELECT *
                              FROM act  Z
                                   LEFT JOIN at_features F1
                                       ON (    F1.ATF_AT = Z.AT_ID
                                           AND F1.ATF_NFT = 32)
                                   LEFT JOIN at_features F2
                                       ON (    F2.ATF_AT = Z.AT_ID
                                           AND F2.ATF_NFT = 33)
                             WHERE     Z.AT_ID = P_AT_ID
                                   AND Z.AT_ST = 'SR'
                                   AND (   F1.ATF_VAL_STRING IS NULL
                                        OR F1.ATF_VAL_STRING = 'F')
                                   AND (   F2.ATF_VAL_STRING IS NULL
                                        OR F2.ATF_VAL_STRING = 'F'))
                   AND NOT EXISTS
                           (SELECT *
                              FROM at_document ZZ
                             WHERE     ZZ.ATD_AT = P_AT_ID
                                   AND ZZ.HISTORY_STATUS = 'A'
                                   AND ZZ.ATD_NDT = T.NDT_ID)
            UNION
            SELECT T.NDT_ID             AS ID,
                   NDT_IS_HAVE_SCAN     AS CODE,
                   T.NDT_NAME           AS NAME
              FROM USS_NDI.V_NDI_DOCUMENT_TYPE T
             WHERE     T.NDT_ID IN (850)
                   AND L_HAS_R1 = 1
                   AND L_ORG_TO IN (31)
                   AND EXISTS
                           (SELECT *
                              FROM act  Z
                                   LEFT JOIN at_features F1
                                       ON (    F1.ATF_AT = Z.AT_ID
                                           AND F1.ATF_NFT = 32)
                             WHERE     Z.AT_ID = P_AT_ID
                                   AND Z.AT_ST = 'O.SR'
                                   AND (   F1.ATF_VAL_STRING IS NULL
                                        OR F1.ATF_VAL_STRING = 'F'))
                   AND NOT EXISTS
                           (SELECT *
                              FROM at_document ZZ
                             WHERE     ZZ.ATD_AT = P_AT_ID
                                   AND ZZ.HISTORY_STATUS = 'A'
                                   AND ZZ.ATD_NDT = T.NDT_ID)
            -- 851
            UNION
            SELECT T.NDT_ID             AS ID,
                   NDT_IS_HAVE_SCAN     AS CODE,
                   T.NDT_NAME           AS NAME
              FROM USS_NDI.V_NDI_DOCUMENT_TYPE T
             WHERE     T.NDT_ID IN (851)
                   AND L_HAS_R2 = 1
                   AND L_ORG_TO IN (32, 33)
                   AND EXISTS
                           (SELECT *
                              FROM act  Z
                                   LEFT JOIN at_features F1
                                       ON (    F1.ATF_AT = Z.AT_ID
                                           AND F1.ATF_NFT = 32)
                                   LEFT JOIN at_features F2
                                       ON (    F2.ATF_AT = Z.AT_ID
                                           AND F2.ATF_NFT = 33)
                             WHERE     Z.AT_ID = P_AT_ID
                                   AND Z.AT_ST IN ('SW', 'SN')
                                   AND (   F1.ATF_VAL_STRING IS NULL
                                        OR F1.ATF_VAL_STRING = 'F')
                                   AND (   F2.ATF_VAL_STRING IS NULL
                                        OR F2.ATF_VAL_STRING = 'F'))
                   AND NOT EXISTS
                           (SELECT *
                              FROM at_document ZZ
                             WHERE     ZZ.ATD_AT = P_AT_ID
                                   AND ZZ.HISTORY_STATUS = 'A'
                                   AND ZZ.ATD_NDT = T.NDT_ID)
                   AND EXISTS
                           (  SELECT q.atd_id
                                FROM at_document q
                                     JOIN at_signers zs
                                         ON (zs.ati_atd = q.atd_id)
                               WHERE     q.atd_at = P_AT_ID
                                     AND q.atd_ndt = 850
                                     AND q.history_status = 'A'
                                     AND zs.history_status = 'A'
                            GROUP BY q.atd_id
                              HAVING COUNT (zs.ati_id) =
                                     COUNT (
                                         CASE
                                             WHEN zs.ati_is_signed = 'T'
                                             THEN
                                                 1
                                         END))
            UNION
            SELECT T.NDT_ID             AS ID,
                   NDT_IS_HAVE_SCAN     AS CODE,
                   T.NDT_NAME           AS NAME
              FROM USS_NDI.V_NDI_DOCUMENT_TYPE T
             WHERE     T.NDT_ID IN (851)
                   AND L_HAS_R2 = 1
                   AND L_ORG_TO IN (31)
                   AND EXISTS
                           (SELECT *
                              FROM act  Z
                                   LEFT JOIN at_features F1
                                       ON (    F1.ATF_AT = Z.AT_ID
                                           AND F1.ATF_NFT = 32)
                             WHERE     Z.AT_ID = P_AT_ID
                                   AND Z.AT_ST IN ('O.SW', 'O.SN')
                                   AND (   F1.ATF_VAL_STRING IS NULL
                                        OR F1.ATF_VAL_STRING = 'F'))
                   AND NOT EXISTS
                           (SELECT *
                              FROM at_document ZZ
                             WHERE     ZZ.ATD_AT = P_AT_ID
                                   AND ZZ.HISTORY_STATUS = 'A'
                                   AND ZZ.ATD_NDT = T.NDT_ID)
                   /* and exists ( SELECT *
                                   FROM at_document q
                                   join at_signers zs on (zs.ati_atd = q.atd_id)
                                  where q.atd_at = P_AT_ID
                                    and q.atd_ndt = 850
                                    and q.history_status = 'A'
                                    and zs.ati_is_signed = 'T'
                                    and zs.history_status = 'A'
                               )*/
                   AND EXISTS
                           (  SELECT q.atd_id
                                FROM at_document q
                                     JOIN at_signers zs
                                         ON (zs.ati_atd = q.atd_id)
                               WHERE     q.atd_at = P_AT_ID
                                     AND q.atd_ndt = 850
                                     AND q.history_status = 'A'
                                     AND zs.history_status = 'A'
                            GROUP BY q.atd_id
                              HAVING COUNT (zs.ati_id) =
                                     COUNT (
                                         CASE
                                             WHEN zs.ati_is_signed = 'T'
                                             THEN
                                                 1
                                         END))
            -- 852, 853
            UNION
            SELECT T.NDT_ID             AS ID,
                   NDT_IS_HAVE_SCAN     AS CODE,
                   T.NDT_NAME           AS NAME
              FROM USS_NDI.V_NDI_DOCUMENT_TYPE T
             WHERE     T.NDT_ID IN (852                              /*, 853*/
                                       )
                   AND L_HAS_R2 = 1
                   AND L_ORG_TO IN (32, 33)
                   AND EXISTS
                           (SELECT *
                              FROM act  Z
                                   LEFT JOIN at_features F1
                                       ON (    F1.ATF_AT = Z.AT_ID
                                           AND F1.ATF_NFT = 32)
                                   LEFT JOIN at_features F2
                                       ON (    F2.ATF_AT = Z.AT_ID
                                           AND F2.ATF_NFT = 33)
                             WHERE     Z.AT_ID = P_AT_ID
                                   AND Z.AT_ST IN ('SW')
                                   --AND F1.ATF_VAL_STRING = 'T'
                                   AND F2.ATF_VAL_STRING = 'T')
                   AND NOT EXISTS
                           (SELECT *
                              FROM at_document ZZ
                             WHERE     ZZ.ATD_AT = P_AT_ID
                                   AND ZZ.HISTORY_STATUS = 'A'
                                   AND ZZ.ATD_NDT = T.NDT_ID)
            UNION
            SELECT T.NDT_ID             AS ID,
                   NDT_IS_HAVE_SCAN     AS CODE,
                   T.NDT_NAME           AS NAME
              FROM USS_NDI.V_NDI_DOCUMENT_TYPE T
             WHERE     T.NDT_ID IN (                                 /*852, */
                                    853)
                   AND L_HAS_R2 = 1
                   AND L_ORG_TO IN (32, 33)
                   AND EXISTS
                           (SELECT *
                              FROM act  Z
                                   LEFT JOIN at_features F1
                                       ON (    F1.ATF_AT = Z.AT_ID
                                           AND F1.ATF_NFT = 32)
                                   LEFT JOIN at_features F2
                                       ON (    F2.ATF_AT = Z.AT_ID
                                           AND F2.ATF_NFT = 33)
                             WHERE     Z.AT_ID = P_AT_ID
                                   AND Z.AT_ST IN ('SW')
                                   --AND F1.ATF_VAL_STRING = 'T'
                                   AND F2.ATF_VAL_STRING = 'T')
                   AND NOT EXISTS
                           (SELECT *
                              FROM at_document ZZ
                             WHERE     ZZ.ATD_AT = P_AT_ID
                                   AND ZZ.HISTORY_STATUS = 'A'
                                   AND ZZ.ATD_NDT = T.NDT_ID)
                   AND EXISTS
                           (SELECT *
                              FROM at_document  q
                                   JOIN at_signers zs
                                       ON (zs.ati_atd = q.atd_id)
                             WHERE     q.atd_at = P_AT_ID
                                   AND q.atd_ndt = 852
                                   AND q.history_status = 'A'
                                   AND zs.ati_is_signed = 'T'
                                   AND zs.history_status = 'A')
            -- 854
            --UNION
            /*SELECT T.NDT_ID AS ID, NDT_IS_HAVE_SCAN AS CODE, T.NDT_NAME AS NAME
              FROM USS_NDI.V_NDI_DOCUMENT_TYPE T
             WHERE T.NDT_ID IN (854)
               AND L_HAS_R1 = 1
               AND L_ORG_TO IN (32)--, 33*\) -- #98260
               AND EXISTS (SELECT *
                            FROM act Z
                            LEFT JOIN at_features F1
                              ON (F1.ATF_AT = Z.AT_ID AND F1.ATF_NFT = 32)
                            LEFT JOIN at_features F2
                              ON (F2.ATF_AT = Z.AT_ID AND F2.ATF_NFT = 33)
                           WHERE Z.AT_ID = P_AT_ID
                             AND Z.AT_ST = 'SR'
                             AND F1.ATF_VAL_STRING = 'T'
                             AND (F2.ATF_VAL_STRING IS NULL OR F2.ATF_VAL_STRING = 'F')
                          )
               AND NOT EXISTS ( SELECT *
                                  FROM at_document ZZ
                                 WHERE ZZ.ATD_AT = P_AT_ID
                                   AND ZZ.HISTORY_STATUS = 'A'
                                   AND ZZ.ATD_NDT = T.NDT_ID
                               )*/
            UNION
            SELECT T.NDT_ID             AS ID,
                   NDT_IS_HAVE_SCAN     AS CODE,
                   T.NDT_NAME           AS NAME
              FROM USS_NDI.V_NDI_DOCUMENT_TYPE T
             WHERE     T.NDT_ID IN (854)
                   AND L_HAS_R1 = 1
                   AND L_ORG_TO IN (31)
                   AND EXISTS
                           (SELECT *
                              FROM act  Z
                                   LEFT JOIN at_features F1
                                       ON (    F1.ATF_AT = Z.AT_ID
                                           AND F1.ATF_NFT = 32)
                             WHERE     Z.AT_ID = P_AT_ID
                                   AND Z.AT_ST = 'O.SR'
                                   AND F1.ATF_VAL_STRING = 'T')
                   AND NOT EXISTS
                           (SELECT *
                              FROM at_document ZZ
                             WHERE     ZZ.ATD_AT = P_AT_ID
                                   AND ZZ.HISTORY_STATUS = 'A'
                                   AND ZZ.ATD_NDT = T.NDT_ID);
    END;

    -- #89729: Список документів які можна створити
    -- Підписання SS-рішень про відмову в наданні СП
    PROCEDURE GET_REJ_DOC_TP_LIST (P_AT_ID   IN     NUMBER,
                                   RES_CUR      OUT SYS_REFCURSOR)
    IS
        L_HAS_R1   NUMBER
            := CASE
                   WHEN TOOLS.CHECKUSERROLE ('W_ESR_SS_OPER') = TRUE THEN 1
                   ELSE 0
               END;
        L_HAS_R2   NUMBER
            := CASE
                   WHEN TOOLS.CHECKUSERROLE ('W_ESR_SS_APPROVE') = TRUE
                   THEN
                       1
                   ELSE
                       0
               END;
        L_ORG_TO   NUMBER := TOOLS.GETCURRORGTO;
        l_is_obl   NUMBER;
    BEGIN
        SELECT CASE WHEN COUNT (*) > 1 THEN 1 ELSE 0 END
          INTO l_is_obl
          FROM at_features t
         WHERE     t.atf_at = P_AT_ID
               AND t.atf_nft IN (32, 33)
               AND t.atf_val_string = 'T';

        /*1) ndt_id in (850):
        - рішення по зверненню має статус SR/O.SR

        - відсутній документ, який намагаються створити, у статусі ‘A’
        - користувач має роль «СП. Спеціаліст з опрацювання справ» (W_ESR_SS_OPER)
        - користувач рівня ТГ/району/області

        2) ndt_id in (851):
        - рішення по зверненню має статус SN/O.SN
        - відсутній документ, який намагаються створити, у статусі ‘A’
        - користувач має роль «СП. Спеціаліст з опрацювання справ» (W_ESR_SS_APPROVE)
        - користувач рівня ТГ/району/області*/

        OPEN RES_CUR FOR
            SELECT T.NDT_ID             AS ID,
                   NDT_IS_HAVE_SCAN     AS CODE,
                   T.NDT_NAME           AS NAME
              FROM USS_NDI.V_NDI_DOCUMENT_TYPE T
             WHERE     T.NDT_ID IN (850)
                   AND L_HAS_R1 = 1
                   AND l_is_obl = 0
                   AND L_ORG_TO IN (31, 32, 33)
                   AND EXISTS
                           (SELECT *
                              FROM ACT Z
                             WHERE     Z.AT_ID = P_AT_ID
                                   AND Z.AT_ST IN ('SR', 'O.SR'))
                   AND NOT EXISTS
                           (SELECT *
                              FROM AT_DOCUMENT ZZ
                             WHERE     ZZ.ATD_AT = P_AT_ID
                                   AND ZZ.HISTORY_STATUS = 'A'
                                   AND ZZ.ATD_NDT = T.NDT_ID)
            UNION
            SELECT T.NDT_ID             AS ID,
                   NDT_IS_HAVE_SCAN     AS CODE,
                   T.NDT_NAME           AS NAME
              FROM USS_NDI.V_NDI_DOCUMENT_TYPE T
             WHERE     T.NDT_ID IN (851)
                   AND L_HAS_R2 = 1
                   AND l_is_obl = 0
                   AND L_ORG_TO IN (31, 32, 33)
                   AND EXISTS
                           (SELECT *
                              FROM ACT Z
                             WHERE     Z.AT_ID = P_AT_ID
                                   AND Z.AT_ST IN ('SN', 'O.SN'))
                   AND NOT EXISTS
                           (SELECT *
                              FROM AT_DOCUMENT ZZ
                             WHERE     ZZ.ATD_AT = P_AT_ID
                                   AND ZZ.HISTORY_STATUS = 'A'
                                   AND ZZ.ATD_NDT = T.NDT_ID)
                   AND EXISTS
                           (SELECT *
                              FROM (SELECT COUNT (*)    AS cnt1,
                                           COUNT (
                                               CASE
                                                   WHEN zs.ati_is_signed =
                                                        'T'
                                                   THEN
                                                       1
                                               END)     AS cnt2
                                      FROM AT_DOCUMENT  ZZ
                                           JOIN at_signers zs
                                               ON (zs.ati_atd = zz.atd_id)
                                     WHERE     ZZ.ATD_AT = P_AT_ID
                                           AND ZZ.HISTORY_STATUS = 'A'
                                           AND ZZ.ATD_NDT = 850
                                           AND zs.history_status = 'A')
                             WHERE cnt1 = cnt2);
    END;

    PROCEDURE REGISTER_DOC_HIST (P_DOC_ID NUMBER, P_DH_ID OUT NUMBER)
    IS
    BEGIN
        TOOLS.WRITEMSG (PACKAGE_NAME || '.Register_Doc_Hist');
        USS_DOC.API$DOCUMENTS.SAVE_DOC_HIST (
            P_DH_ID          => NULL,
            P_DH_DOC         => P_DOC_ID,
            P_DH_SIGN_ALG    => NULL,
            P_DH_NDT         => NULL,
            P_DH_SIGN_FILE   => NULL,
            P_DH_ACTUALITY   =>
                USS_DOC.API$DOCUMENTS.C_DOC_ACTUALITY_UNDEFINED,
            P_DH_DT          => SYSDATE,
            P_DH_WU          => TOOLS.GETCURRWU,
            P_DH_SRC         => 'VST',
            P_NEW_ID         => P_DH_ID);
    END;

    PROCEDURE DELETE_DOCUMENT (P_ATD_ID IN NUMBER)
    IS
    BEGIN
        UPDATE AT_SIGNERS T
           SET HISTORY_STATUS = 'H'
         WHERE T.ATI_ATD = P_ATD_ID AND HISTORY_STATUS = 'A';

        API$DOCUMENTS.DELETE_AT_DOCUMENT_ALL (P_ATD_ID);
    END;

    -- #90626
    PROCEDURE GET_ASSESSMENT_NEED_DOC (P_AT_ID    IN     NUMBER,
                                       PERS_CUR      OUT SYS_REFCURSOR,
                                       SECT_CUR      OUT SYS_REFCURSOR,
                                       FEAT_CUR      OUT SYS_REFCURSOR,
                                       SPEC_CUR      OUT SYS_REFCURSOR,
                                       MAIN_CUR      OUT SYS_REFCURSOR)
    IS
        l_at_id   NUMBER;
    BEGIN
        BEGIN
            SELECT t.at_id
              INTO l_at_id
              FROM act t
             WHERE     t.at_main_link = p_at_id
                   AND t.at_tp = 'APOP'
                   AND t.at_st NOT IN ('AR', 'AD');
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        OPEN PERS_CUR FOR
              SELECT T.ATP_ID,
                        T.ATP_LN
                     || ' '
                     || T.ATP_FN
                     || ' '
                     || T.ATP_MN
                     || ' ('
                     || TO_CHAR (T.ATP_BIRTH_DT, 'DD.MM.YYYY')
                     || ')'
                         AS TAB_NAME,
                     LISTAGG ( /*DISTINCT  ЭТО НЕ ПОДДЕРЖИВАЕТСЯ 12й ВЕРСИЕЙ ОРАЦЛЕ*/
                              G.NNG_FORM_TP, ',') WITHIN GROUP (ORDER BY 1)
                         AS NNG_FORM_TPS,
                     TO_CHAR (ATP_ID)
                         AS TAB_ID,
                     T.ATP_ID
                         AS RN
                FROM AT_PERSON T
                     JOIN AT_SECTION S ON (S.ATE_ATP = T.ATP_ID)
                     JOIN USS_NDI.V_NDI_NDA_GROUP G ON (G.NNG_ID = S.ATE_NNG)
               WHERE     T.ATP_AT = l_at_id
                     AND S.ATE_AT = T.ATP_AT
                     AND T.HISTORY_STATUS = 'A'
            GROUP BY T.ATP_ID,
                     T.ATP_FN,
                     T.ATP_MN,
                     T.ATP_LN,
                     T.ATP_BIRTH_DT
            UNION
            SELECT NULL                      AS ATP_ID,
                   'Загальна інформація'     AS TAB_NAME,
                   'MAIN_INFO'               AS NNG_FORM_TPS,
                   'MAIN_INFO'               AS TAB_ID,
                   -1                        AS RN
              FROM ACT T
             WHERE T.AT_ID = l_at_id
            UNION
              SELECT NULL             AS ATP_ID,
                     CASE
                         WHEN G.NNG_FORM_TP = 'FORF'
                         THEN
                             'Фактори сім’ї та середовища'
                     END              AS TAB_NAME,
                     G.NNG_FORM_TP    AS NNG_FORM_TPS,
                     G.NNG_FORM_TP    AS TAB_ID,
                     1                AS RN
                FROM ACT T
                     JOIN USS_NDI.V_NDI_NDA_GROUP G
                         ON (G.NNG_FORM_TP IN ('FORF'))
               WHERE T.AT_ID = l_at_id
            GROUP BY G.NNG_FORM_TP
            UNION
              SELECT NULL             AS ATP_ID,
                     CASE
                         WHEN G.NNG_FORM_TP = 'FORV1'
                         THEN
                             'Висновок оцінки потреб сім`ї'
                         WHEN G.NNG_FORM_TP = 'FORV2'
                         THEN
                             'Висновок оцінки потреб особи'
                     END              AS TAB_NAME,
                     G.NNG_FORM_TP    AS NNG_FORM_TPS,
                     G.NNG_FORM_TP    AS TAB_ID,
                     99999            AS RN
                FROM AT_SECTION T
                     JOIN USS_NDI.V_NDI_NDA_GROUP G ON (G.NNG_ID = T.ATE_NNG)
               WHERE     T.ATE_AT = l_at_id
                     AND G.NNG_FORM_TP IN ('FORV1', 'FORV2')
                     -- #102502
                     AND G.NNG_FORM_TP IN
                             (SELECT CASE
                                         WHEN z.at_conclusion_tp = 'V1'
                                         THEN
                                             'FORV1'
                                         ELSE
                                             'FORV2'
                                     END
                                FROM v_act z
                               WHERE     z.at_main_link = P_AT_ID
                                     AND z.at_tp = 'APOP'
                                     AND z.at_St NOT IN ('AD', 'AR'))
            GROUP BY G.NNG_FORM_TP
            ORDER BY RN;

        OPEN SECT_CUR FOR
              SELECT T.*,
                     G.NNG_NAME          AS ATE_NNG_NAME,
                     G.NNG_FORM_TP,
                     G.NNG_INFO1_SHOW    AS SHOW_ATE_CHIELD_INFO,
                     G.NNG_INFO2_SHOW    AS SHOW_ATE_PARENT_INFO,
                     G.NNG_INFO3_SHOW    AS SHOW_ATE_NOTES,
                     G.NNG_INFO1_NAME    AS NAME_ATE_CHIELD_INFO,
                     G.NNG_INFO2_NAME    AS NAME_ATE_PARENT_INFO,
                     G.NNG_INFO3_NAME    AS NAME_ATE_NOTES,
                     CASE
                         WHEN T.ATE_ATP IS NOT NULL THEN TO_CHAR (T.ATE_ATP)
                         ELSE G.NNG_FORM_TP
                     END                 TAB_ID
                FROM AT_SECTION T
                     JOIN USS_NDI.V_NDI_NDA_GROUP G ON (G.NNG_ID = T.ATE_NNG)
               WHERE T.ATE_AT = l_at_id
            ORDER BY G.NNG_ORDER;

        OPEN FEAT_CUR FOR
            SELECT T.*, a.nda_order
              FROM AT_SECTION_FEATURE  T
                   JOIN uss_ndi.v_ndi_document_attr a
                       ON (a.nda_id = t.atef_nda)
             WHERE T.ATEF_AT = l_at_id
            -- #101737: це технічні атрибути для виводу тексту в блоках, які не зберігаються.
            UNION ALL
            SELECT NULL         AS atef_id,
                   t.ate_id     AS atef_ate,
                   l_at_id      AS atef_at,
                   8304         AS atef_nda,
                   NULL         AS atef_feature,
                   NULL         AS atef_notes,
                   a.nda_order
              FROM at_section  t
                   JOIN uss_ndi.v_ndi_document_attr a ON (a.nda_id = 8304)
             WHERE t.ate_at = l_at_id AND t.ate_nng = 132
            UNION ALL
            SELECT NULL         AS atef_id,
                   t.ate_id     AS atef_ate,
                   l_at_id      AS atef_at,
                   8305         AS atef_nda,
                   NULL         AS atef_feature,
                   NULL         AS atef_notes,
                   a.nda_order
              FROM at_section  t
                   JOIN uss_ndi.v_ndi_document_attr a ON (a.nda_id = 8305)
             WHERE t.ate_at = l_at_id AND t.ate_nng = 132
            ORDER BY nda_order;

        OPEN SPEC_CUR FOR
            SELECT *
              FROM AT_OTHER_SPEC T
             WHERE T.ATOP_AT = l_at_id AND t.history_status = 'A';

        OPEN MAIN_CUR FOR SELECT T.AT_CASE_CLASS
                            FROM ACT T
                           WHERE T.AT_ID = l_at_id;
    END;

    PROCEDURE SAVE_ASSESSMENT_NEED_DOC (P_AT_ID           IN NUMBER,
                                        P_SECTION_XML     IN CLOB,
                                        P_SPEC_XML        IN CLOB,
                                        P_AT_CASE_CLASS   IN VARCHAR2)
    IS
        L_S_ARR      T_AT_SECTION := T_AT_SECTION ();
        L_F_ARR      T_AT_SECTION_FEATURE := T_AT_SECTION_FEATURE ();
        l_spec_arr   t_at_other_spec := t_at_other_spec ();
        L_NEW_ID     NUMBER;
    BEGIN
        UPDATE TMP_LOB
           SET X_CLOB = P_SECTION_XML
         WHERE X_ID = 666;

        COMMIT;

        --raise_application_error(-20000, 'test');

        EXECUTE IMMEDIATE TYPE2XMLTABLE (PACKAGE_NAME, 't_at_section', TRUE)
            BULK COLLECT INTO L_S_ARR
            USING P_SECTION_XML;

        -- збереження секцій
        FOR XX IN (SELECT T.*
                     FROM TABLE (L_S_ARR) T)
        LOOP
            IF (XX.ATE_ID < 0)
            THEN
                INSERT INTO AT_SECTION (ATE_ATP,
                                        ATE_AT,
                                        ATE_NNG,
                                        ATE_CHIELD_INFO,
                                        ATE_PARENT_INFO,
                                        ATE_NOTES)
                     VALUES (XX.ATE_ATP,
                             P_AT_ID,
                             XX.ATE_NNG,
                             XX.ATE_CHIELD_INFO,
                             XX.ATE_PARENT_INFO,
                             XX.ATE_NOTES)
                  RETURNING ATE_ID
                       INTO L_NEW_ID;
            ELSE
                L_NEW_ID := XX.ATE_ID;

                UPDATE AT_SECTION
                   SET ATE_CHIELD_INFO = XX.ATE_CHIELD_INFO,
                       ATE_PARENT_INFO = XX.ATE_PARENT_INFO,
                       ATE_NOTES = XX.ATE_NOTES
                 WHERE ATE_ID = XX.ATE_ID;
            END IF;

            L_F_ARR := T_AT_SECTION_FEATURE ();

            EXECUTE IMMEDIATE TYPE2XMLTABLE (PACKAGE_NAME,
                                             't_at_section_feature',
                                             TRUE,
                                             FALSE,
                                             TRUE)
                BULK COLLECT INTO L_F_ARR
                USING XX.FEATURES;

            -- збереження фіч по секції
            FOR YY IN (SELECT * FROM TABLE (L_F_ARR))
            LOOP
                IF (YY.ATEF_ID < 0)
                THEN
                    INSERT INTO AT_SECTION_FEATURE (ATEF_ATE,
                                                    ATEF_AT,
                                                    ATEF_NDA,
                                                    ATEF_FEATURE,
                                                    ATEF_NOTES)
                         VALUES (L_NEW_ID,
                                 P_AT_ID,
                                 YY.ATEF_NDA,
                                 YY.ATEF_FEATURE,
                                 YY.ATEF_NOTES);
                ELSE
                    UPDATE AT_SECTION_FEATURE
                       SET ATEF_FEATURE = YY.ATEF_FEATURE,
                           ATEF_NOTES = YY.ATEF_NOTES
                     WHERE ATEF_ID = YY.ATEF_ID;
                END IF;
            END LOOP;
        END LOOP;

        EXECUTE IMMEDIATE TYPE2XMLTABLE (PACKAGE_NAME,
                                         't_at_other_spec',
                                         TRUE)
            BULK COLLECT INTO l_spec_arr
            USING P_SPEC_XML;

        DELETE FROM tmp_work_ids1;

        FOR XX IN (SELECT T.*
                     FROM TABLE (l_spec_arr) T)
        LOOP
            IF (xx.atop_id < 0 OR xx.atop_id IS NULL)
            THEN
                INSERT INTO AT_OTHER_SPEC (ATOP_AT,
                                           ATOP_FN,
                                           ATOP_MN,
                                           ATOP_LN,
                                           ATOP_PHONE,
                                           ATOP_ATIP,
                                           ATOP_POSITION,
                                           ATOP_TP)
                     VALUES (p_at_id,
                             xx.ATOP_FN,
                             xx.ATOP_MN,
                             xx.ATOP_LN,
                             xx.ATOP_PHONE,
                             xx.ATOP_ATIP,
                             xx.ATOP_POSITION,
                             xx.ATOP_TP)
                  RETURNING ATOP_ID
                       INTO L_NEW_ID;
            ELSE
                INSERT INTO tmp_work_ids1 (x_id)
                     VALUES (xx.atop_id);

                UPDATE AT_OTHER_SPEC
                   SET ATOP_FN = xx.ATOP_FN,
                       ATOP_MN = xx.ATOP_MN,
                       ATOP_LN = xx.ATOP_LN,
                       ATOP_PHONE = xx.ATOP_PHONE,
                       ATOP_ATIP = xx.ATOP_ATIP,
                       ATOP_POSITION = xx.ATOP_POSITION,
                       ATOP_TP = xx.ATOP_TP
                 WHERE ATOP_ID = xx.ATOP_ID;
            END IF;
        END LOOP;

        DELETE FROM AT_OTHER_SPEC t
              WHERE     t.atop_at = P_AT_ID
                    AND t.atop_id NOT IN (SELECT z.x_id
                                            FROM tmp_work_ids1 z);

        UPDATE act t
           SET t.at_case_class = p_at_case_class
         WHERE t.at_id = p_at_id;
    END;

    -- info: налаштування фіч секцій
    -- params:
    -- note:
    PROCEDURE GET_ASS_NDA_LIST (P_NDA_CUR OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN P_NDA_CUR FOR
              SELECT NDA.NDA_ID,
                     NVL (NDA.NDA_NAME, PT.PT_NAME)
                         AS NDA_NAME,
                     NDA.NDA_IS_KEY,
                     NDA.NDA_NDT,
                     NDA.NDA_ORDER,
                     NDA.NDA_PT,
                     NDA.NDA_IS_REQ,
                     NDA.NDA_DEF_VALUE,
                     NDA.NDA_CAN_EDIT,
                     NDA.NDA_NEED_SHOW,
                     NVL (NDA.NDA_SIZE, 'col-auto')
                         AS NDA_SIZE,
                     PT.PT_ID,
                     PT.PT_CODE,
                     PT.PT_NAME,
                     PT.PT_NDC,
                     PT.PT_EDIT_TYPE,
                     PT.PT_DATA_TYPE,
                     NDC.NDC_CODE,
                     NVL (NDA.NDA_NNG, -1)
                         AS NDA_NNG,
                     (SELECT MAX (Z.NNV_CONDITION)
                        FROM USS_NDI.V_NDI_NDA_VALIDATION Z
                       WHERE Z.NNV_NDA = NDA.NDA_ID AND Z.NNV_TP = 'MASK')
                         AS MASK_SETUP,
                     (SELECT COALESCE (MAX (Z.NNV_CONDITION), 'F')
                        FROM USS_NDI.V_NDI_NDA_VALIDATION Z
                       WHERE Z.NNV_NDA = NDA.NDA_ID AND Z.NNV_TP = 'RESET')
                         AS CAN_RESET
                FROM USS_NDI.V_NDI_DOCUMENT_ATTR NDA
                     JOIN USS_NDI.V_NDI_NDA_GROUP G ON (G.NNG_ID = NDA.NDA_NNG)
                     JOIN USS_NDI.V_NDI_PARAM_TYPE PT ON PT.PT_ID = NDA.NDA_PT
                     LEFT JOIN USS_NDI.V_NDI_DICT_CONFIG NDC
                         ON NDC.NDC_ID = PT.PT_NDC
               WHERE G.NNG_AT_TP = 'APOP'               --Nda_Ndt = 10233--804
            ORDER BY NDA.NDA_ORDER;
    END;

    ---------------------------------------------------------------------
    --                   Налаштування Секцій
    ---------------------------------------------------------------------
    PROCEDURE GET_ASS_NNG_LIST (P_NNG_CUR OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN P_NNG_CUR FOR
              SELECT G.*
                FROM USS_NDI.V_NDI_NDA_GROUP G
               WHERE G.NNG_FORM_TP IS NOT NULL AND G.HISTORY_STATUS = 'A'
            ORDER BY NNG_ORDER;
    END;

    -- #89467: список послуг звернення
    PROCEDURE appeal_services (p_ap_id IN NUMBER, res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT t.aps_id, s.nst_code || ' ' || s.nst_name AS aps_name
              FROM Ap_Service  t
                   JOIN uss_ndi.v_ndi_service_type s
                       ON (s.nst_id = t.aps_nst)
             WHERE t.aps_ap = p_ap_id AND t.history_status = 'A';
    END;

    -- #105150
    PROCEDURE create_act_rejected (p_at_id IN NUMBER)
    IS
        l_at_tp    VARCHAR2 (10);
        l_at_st    VARCHAR2 (10);
        l_new_id   NUMBER;
    BEGIN
        SELECT at_tp, at_st
          INTO l_at_tp, l_at_st
          FROM act t
         WHERE at_id = p_at_id;

        USS_ESR.API$ACT.Copy_At_To_New (p_At_id,
                                        l_at_tp,
                                        l_new_id,
                                        0,
                                        0);

        SELECT at_st
          INTO l_at_st
          FROM act t
         WHERE at_id = l_new_id;


        IF l_at_tp = 'APOP'
        THEN
            Api$act.Set_At_St (p_At_Id          => l_new_id,
                               p_At_St_Old      => l_at_st,
                               p_At_St_New      => 'AN',
                               p_Log_Msg        => CHR (38) || '160',
                               p_Wrong_St_Msg   => 'Створено копію акта');
        ELSIF l_at_tp = 'OKS '
        THEN
            Api$act.Set_At_St (p_At_Id          => l_new_id,
                               p_At_St_Old      => l_at_st,
                               p_At_St_New      => 'TN',
                               p_Log_Msg        => CHR (38) || '160',
                               p_Wrong_St_Msg   => 'Створено копію акта');
        END IF;
    END;
BEGIN
    NULL;
END DNET$ACT_ASSIGNMENT;
/