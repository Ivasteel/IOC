/* Formatted on 8/12/2025 5:55:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.DNET$DIC_COMMON
IS
    -- Author  : SHOSTAK
    -- Created : 20.05.2021 14:34:59
    -- Purpose :

    PROCEDURE Save_Ndi_Bank (
        p_Nb_Id              IN     Ndi_Bank.Nb_Id%TYPE,
        p_Nb_Nb              IN     Ndi_Bank.Nb_Nb%TYPE,
        p_Nb_Mfo             IN     Ndi_Bank.Nb_Mfo%TYPE,
        p_Nb_Name            IN     Ndi_Bank.Nb_Name%TYPE,
        p_Nb_Name_En         IN     Ndi_Bank.Nb_Name_En%TYPE,
        p_Nb_Sname           IN     Ndi_Bank.Nb_Sname%TYPE,
        p_Nb_Ur_Address      IN     Ndi_Bank.Nb_Ur_Address%TYPE,
        p_Nb_Ur_Address_En   IN     Ndi_Bank.Nb_Ur_Address_En%TYPE,
        p_Nb_Edrpou          IN     Ndi_Bank.Nb_Edrpou%TYPE,
        p_Nb_Is_Authorized   IN     Ndi_Bank.Nb_Is_Authorized%TYPE,
        p_NB_NUM             IN     NDI_BANK.NB_NUM%TYPE,
        p_nb_is_treasury     IN     ndi_bank.nb_is_treasury%TYPE,
        p_New_Id                OUT Ndi_Bank.Nb_Id%TYPE);

    PROCEDURE Delete_Ndi_Bank (p_Nb_Id IN Ndi_Bank.Nb_Id%TYPE);

    PROCEDURE Query_Ndi_Bank (p_Nb_Nb              IN     NUMBER,
                              p_Nb_Mfo             IN     VARCHAR2,
                              p_Nb_Name            IN     VARCHAR2,
                              p_Nb_Name_En         IN     VARCHAR2,
                              p_Nb_Edrpou          IN     VARCHAR2,
                              p_Nb_Is_Authorized   IN     VARCHAR2,
                              p_NB_NUM             IN     VARCHAR2,
                              p_Res                   OUT SYS_REFCURSOR);

    PROCEDURE Get_Ndi_Bank (p_Nb_Id   IN     NUMBER,
                            p_Res        OUT SYS_REFCURSOR,
                            p_contr      OUT SYS_REFCURSOR);


    PROCEDURE get_nb_contract_all (p_nb_id   IN     NUMBER,
                                   p_contr      OUT SYS_REFCURSOR);

    PROCEDURE get_nb_contract_banks (p_nb_id   IN     NUMBER,
                                     p_contr      OUT SYS_REFCURSOR);

    PROCEDURE set_nb_contract (p_nbc_start_dt   IN DATE,
                               p_nbc_stop_dt    IN DATE,
                               p_nbc_num        IN VARCHAR2,
                               p_nbc_dt         IN DATE,
                               p_nbc_nb         IN NUMBER);

    PROCEDURE Save_Ndi_Country (
        p_Nc_Id      IN     Ndi_Country.Nc_Id%TYPE,
        p_Nc_Code    IN     Ndi_Country.Nc_Code%TYPE,
        p_Nc_Name    IN     Ndi_Country.Nc_Name%TYPE,
        p_Nc_Sname   IN     Ndi_Country.Nc_Sname%TYPE,
        p_New_Id        OUT Ndi_Country.Nc_Id%TYPE);

    PROCEDURE Delete_Ndi_Country (p_Nc_Id IN Ndi_Country.Nc_Id%TYPE);

    PROCEDURE Query_Ndi_Country (p_Nc_Code   IN     Ndi_Country.Nc_Code%TYPE,
                                 p_Nc_Name   IN     Ndi_Country.Nc_Name%TYPE,
                                 p_Res          OUT SYS_REFCURSOR);

    PROCEDURE Get_Ndi_Country (p_Nc_Id   IN     Ndi_Country.Nc_Id%TYPE,
                               p_Res        OUT SYS_REFCURSOR);

    ---------------------------------------------------------------
    ------------------------REJECT REASON--------------------------
    ---------------------------------------------------------------
    --GET BY ID
    PROCEDURE GET_REJECT_REASON (P_ID    IN     NDI_REJECT_REASON.NJR_ID%TYPE,
                                 P_RES      OUT SYS_REFCURSOR);

    --LIST
    PROCEDURE QUERY_REJECT_REASON (p_NJR_CODE   IN     VARCHAR2,
                                   p_NJR_NAME   IN     VARCHAR2,
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

    ---------------------------------------------------------------
    ------------------------distrib purpose------------------------
    ---------------------------------------------------------------

    --GET BY ID
    PROCEDURE get_distrib_purpose_gr (
        p_id    IN     ndi_distrib_purpose_gr.dpg_id%TYPE,
        p_res      OUT SYS_REFCURSOR);

    --LIST
    PROCEDURE query_distrib_purpose_gr (p_dpg_name   IN     VARCHAR2,
                                        p_res           OUT SYS_REFCURSOR);

    --DELETE
    PROCEDURE delete_distrib_purpose_gr (
        p_id   ndi_distrib_purpose_gr.dpg_id%TYPE);

    --SAVE
    PROCEDURE save_distrib_purpose_gr (
        p_dpg_id           IN     ndi_distrib_purpose_gr.dpg_id%TYPE,
        p_dpg_name         IN     ndi_distrib_purpose_gr.dpg_name%TYPE,
        p_dpg_is_gov       IN     ndi_distrib_purpose_gr.dpg_is_gov%TYPE,
        p_dpg_is_own       IN     ndi_distrib_purpose_gr.dpg_is_own%TYPE,
        p_dpg_template     IN     ndi_distrib_purpose_gr.dpg_template%TYPE,
        p_dpg_tp           IN     ndi_distrib_purpose_gr.dpg_tp%TYPE,
        p_dpg_hs_del       IN     ndi_distrib_purpose_gr.dpg_hs_del%TYPE,
        p_dpg_hs_upd       IN     ndi_distrib_purpose_gr.dpg_hs_upd%TYPE,
        p_history_status   IN     ndi_distrib_purpose_gr.history_status%TYPE,
        p_new_id              OUT ndi_distrib_purpose_gr.dpg_id%TYPE);

    ---------------------------------------------------------------
    ----------------------------deduction--------------------------
    ---------------------------------------------------------------

    --GET BY ID
    PROCEDURE GET_DEDUCTION (P_NDN_ID       IN     NDI_DEDUCTION.NDN_ID%TYPE,
                             P_RES             OUT SYS_REFCURSOR,
                             P_nst_config      OUT SYS_REFCURSOR,
                             p_npt_config      OUT SYS_REFCURSOR);

    --LIST
    PROCEDURE QUERY_DEDUCTION (p_NDN_CODE       IN     VARCHAR2,
                               p_NDN_NAME       IN     VARCHAR2,
                               p_show_deleted   IN     VARCHAR2,
                               P_RES               OUT SYS_REFCURSOR);

    --DELETE
    PROCEDURE DELETE_DEDUCTION (P_NDN_ID NDI_DEDUCTION.NDN_ID%TYPE);

    --SAVE
    PROCEDURE SAVE_DEDUCTION (
        P_NDN_ID          IN     NDI_DEDUCTION.NDN_ID%TYPE,
        p_NDN_CODE        IN     NDI_DEDUCTION.NDN_CODE%TYPE,
        p_NDN_NAME        IN     NDI_DEDUCTION.NDN_NAME%TYPE,
        p_NDN_MAX_PRC     IN     NDI_DEDUCTION.NDN_MAX_PRC%TYPE,
        p_NDN_ORDER       IN     NDI_DEDUCTION.NDN_ORDER%TYPE,
        p_NDN_CALC_STEP   IN     NDI_DEDUCTION.NDN_CALC_STEP%TYPE,
        p_NDN_DN_TP       IN     NDI_DEDUCTION.NDN_DN_TP%TYPE,
        p_nst_config      IN     CLOB,
        p_npt_config      IN     CLOB,
        P_NEW_ID             OUT NDI_DEDUCTION.NDN_ID%TYPE);

    ---------------------------------------------------------------
    ----------------------------NDI_ACC_SETUP ---------------------
    ---------------------------------------------------------------

    PROCEDURE get_acc_setup (p_res OUT SYS_REFCURSOR);

    PROCEDURE save_acc_setup (
        p_acs_id               IN     ndi_acc_setup.acs_id%TYPE,
        p_acs_vat_tp           IN     ndi_acc_setup.acs_vat_tp%TYPE,
        p_acs_fnc_signer       IN     ndi_acc_setup.acs_fnc_signer%TYPE,
        p_acs_dpp_dksu         IN     ndi_acc_setup.acs_dpp_dksu%TYPE,
        p_acs_net_level        IN     ndi_acc_setup.acs_net_level%TYPE,
        p_acs_adm_code         IN     ndi_acc_setup.acs_adm_code%TYPE,
        p_acs_adm_level        IN     ndi_acc_setup.acs_adm_level%TYPE,
        p_acs_province_code    IN     ndi_acc_setup.acs_province_code%TYPE,
        p_acs_dksu_main_code   IN     ndi_acc_setup.acs_dksu_main_code%TYPE,
        p_acs_dksu_code        IN     ndi_acc_setup.acs_dksu_code%TYPE,
        p_acs_dksu_reg_dt      IN     ndi_acc_setup.acs_dksu_reg_dt%TYPE,
        p_acs_dppa_adm         IN     ndi_acc_setup.acs_dppa_adm%TYPE,
        p_acs_doer_code        IN     ndi_acc_setup.acs_doer_code%TYPE,
        p_acs_kvk_code         IN     ndi_acc_setup.acs_kvk_code%TYPE,
        p_acs_doc_close_dt     IN     ndi_acc_setup.acs_doc_close_dt%TYPE,
        p_acs_fnc_bt_check     IN     ndi_acc_setup.acs_fnc_bt_check%TYPE,
        p_acs_fnc_bt_allow     IN     ndi_acc_setup.acs_fnc_bt_allow%TYPE,
        p_acs_kvk_name         IN     ndi_acc_setup.acs_kvk_name%TYPE,
        p_new_id                  OUT ndi_acc_setup.acs_id%TYPE);

    ---------------------------------------------------------------
    ----------------------------V_OPFU-----------------------------
    ---------------------------------------------------------------


    PROCEDURE query_opfu (p_org_id_reg   IN     NUMBER,
                          p_org_id_soc   IN     NUMBER,
                          p_org_id_ter   IN     NUMBER,
                          p_res             OUT SYS_REFCURSOR);

    --#79041
    PROCEDURE query_children_services (
        p_ncs_code         IN     ndi_children_service.ncs_code%TYPE,
        p_ncs_name         IN     ndi_children_service.ncs_name%TYPE,
        p_history_status   IN     ndi_children_service.history_status%TYPE,
        p_res                 OUT SYS_REFCURSOR);

    -- #81615: 'Базовий календар, список
    PROCEDURE GET_NDI_CALENDAR_LIST (p_NCB_DT_From   IN     DATE,
                                     p_NCB_DT_To     IN     DATE,
                                     p_NCB_WORK_TP   IN     VARCHAR2,
                                     p_res              OUT SYS_REFCURSOR);

    -- #81615: 'Базовий календарб картка
    PROCEDURE GET_NDI_CALENDAR_CARD (p_nbc_id   IN     NUMBER,
                                     p_res         OUT SYS_REFCURSOR);

    -- #81615: 'Базовий календар, оновленння
    PROCEDURE UPDATE_NDI_CALENDAR (p_ncb_id            IN NUMBER,
                                   p_NCB_WORK_TP       IN VARCHAR2,
                                   p_NCB_DESCRIPTION   IN VARCHAR2);

    --===============================================
    --                NDI_Org2Kaot
    --===============================================

    PROCEDURE Save_Ndi_Org2Kaot (
        p_NOK_ID     IN     NDI_ORG2KAOT.NOK_ID%TYPE,
        p_NOK_ORG    IN     NDI_ORG2KAOT.NOK_ORG%TYPE,
        p_NOK_KAOT   IN     NDI_ORG2KAOT.NOK_KAOT%TYPE,
        p_new_id        OUT NDI_ORG2KAOT.NOK_ID%TYPE);

    PROCEDURE Delete_Ndi_Org2Kaot (p_Nok_Id IN Ndi_Org2Kaot.Nok_Id%TYPE);

    PROCEDURE Query_Ndi_Org2Kaot (
        p_Nok_Org    IN     Ndi_Org2Kaot.Nok_Org%TYPE,
        p_Nok_Kaot   IN     Ndi_Org2Kaot.Nok_Kaot%TYPE,
        p_Res           OUT SYS_REFCURSOR);

    PROCEDURE Get_Ndi_Org2Kaot (p_Nok_Id   IN     Ndi_Country.Nc_Id%TYPE,
                                p_Res         OUT SYS_REFCURSOR);

    -- #112982
    PROCEDURE get_ddn_inv_reason_list (res_cur OUT SYS_REFCURSOR);

    --===============================================
    --                NDI_CBI_WARES
    --===============================================

    PROCEDURE save_ndi_cbi_wares (
        p_wrn_Id      IN     ndi_cbi_wares.wrn_id%TYPE,
        p_wrn_shifr   IN     VARCHAR2,
        p_wrn_name    IN     VARCHAR2,
        p_new_id         OUT NDI_ORG2KAOT.NOK_ID%TYPE);

    PROCEDURE delete_ndi_cbi_wares (p_wrn_Id IN ndi_cbi_wares.wrn_id%TYPE);

    PROCEDURE get_ndi_cbi_wares (p_wrn_Id   IN     ndi_cbi_wares.wrn_id%TYPE,
                                 p_Res         OUT SYS_REFCURSOR);

    PROCEDURE query_ndi_cbi_wares (p_wrn_shifr   IN     VARCHAR2,
                                   p_wrn_name    IN     VARCHAR2,
                                   res_cur          OUT SYS_REFCURSOR);
END Dnet$dic_Common;
/


GRANT EXECUTE ON USS_NDI.DNET$DIC_COMMON TO DNET_PROXY
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_COMMON TO II01RC_USS_NDI_PORTAL
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_COMMON TO II01RC_USS_NDI_WEB
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_COMMON TO IKIS_RBM
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_COMMON TO PORTAL_PROXY
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_COMMON TO USS_ESR
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_COMMON TO USS_PERSON
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_COMMON TO USS_RNSP
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_COMMON TO USS_RPT
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_COMMON TO USS_VISIT
/


/* Formatted on 8/12/2025 5:55:30 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.DNET$DIC_COMMON
IS
    --===============================================
    --                NDI_BANK
    --===============================================
    PROCEDURE save_ndi_bank (
        p_nb_id              IN     ndi_bank.nb_id%TYPE,
        p_nb_nb              IN     ndi_bank.nb_nb%TYPE,
        p_nb_mfo             IN     ndi_bank.nb_mfo%TYPE,
        p_nb_name            IN     ndi_bank.nb_name%TYPE,
        p_nb_name_en         IN     ndi_bank.nb_name_en%TYPE,
        p_nb_sname           IN     ndi_bank.nb_sname%TYPE,
        p_nb_ur_address      IN     ndi_bank.nb_ur_address%TYPE,
        p_nb_ur_address_en   IN     ndi_bank.nb_ur_address_en%TYPE,
        p_nb_edrpou          IN     ndi_bank.nb_edrpou%TYPE,
        p_nb_is_authorized   IN     ndi_bank.nb_is_authorized%TYPE,
        p_nb_num             IN     ndi_bank.nb_num%TYPE,
        p_nb_is_treasury     IN     ndi_bank.nb_is_treasury%TYPE,
        p_new_id                OUT ndi_bank.nb_id%TYPE)
    IS
        l_mfo_exists      NUMBER;
        l_num_exists      NUMBER;
        l_edrpou_exists   NUMBER;
    BEGIN
        tools.check_user_and_raise (5);

        SELECT SIGN (
                   NVL (SUM (CASE nb_num WHEN p_nb_num THEN 1 ELSE 0 END), 0)),
               SIGN (
                   NVL (SUM (CASE nb_mfo WHEN p_nb_mfo THEN 1 ELSE 0 END), 0)),
               SIGN (
                   NVL (
                       SUM (
                           CASE nb_edrpou WHEN p_nb_edrpou THEN 1 ELSE 0 END),
                       0))
          INTO l_num_exists, l_mfo_exists, l_edrpou_exists
          FROM ndi_bank
         WHERE     (    (   nb_num = p_nb_num
                         OR nb_mfo = p_nb_mfo
                         OR nb_edrpou = p_nb_edrpou)
                    AND (nb_id != p_nb_id OR p_nb_id IS NULL))
               AND history_status = 'A';

        --Могут понадобится
        IF l_num_exists = 1
        THEN
            raise_application_error (
                -20002,
                'Номер банку ' || p_nb_num || ' вже існує');
        END IF;

        /*IF l_edrpou_exists = 1 THEN
         raise_application_error(-20002,
                                 'ЄДРПУ ' || p_nb_edrpou || ' вже існує');
       END IF;*/
        IF l_mfo_exists = 1
        THEN
            raise_application_error (
                -20002,
                'Банк с МФО ' || p_nb_mfo || ' вже існує');
        END IF;

        api$dic_common.save_ndi_bank (
            p_nb_id              => p_nb_id,
            p_nb_nb              => p_nb_nb,
            p_nb_mfo             => p_nb_mfo,
            p_nb_name            => p_nb_name,
            p_nb_name_en         => p_nb_name_en,
            p_nb_sname           => p_nb_sname,
            p_nb_ur_address      => p_nb_ur_address,
            p_nb_ur_address_en   => p_nb_ur_address_en,
            p_nb_edrpou          => p_nb_edrpou,
            p_nb_is_authorized   => p_nb_is_authorized,
            p_history_status     => api$dic_common.c_history_status_actual,
            p_nb_num             => p_nb_num,
            p_nb_is_treasury     => p_nb_is_treasury,
            p_new_id             => p_new_id);

        Api$dic_Common.Set_Ndi_Bank_Hist_St (
            p_Nb_Id            => p_Nb_Id,
            p_History_Status   => Api$dic_Common.c_History_Status_Actual);
    END;

    PROCEDURE Delete_Ndi_Bank (p_Nb_Id IN Ndi_Bank.Nb_Id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (5);
        Api$dic_Common.Set_Ndi_Bank_Hist_St (
            p_Nb_Id            => p_Nb_Id,
            p_History_Status   => Api$dic_Common.c_History_Status_Historical);
    END;

    PROCEDURE Query_Ndi_Bank (p_Nb_Nb              IN     NUMBER,
                              p_Nb_Mfo             IN     VARCHAR2,
                              p_Nb_Name            IN     VARCHAR2,
                              p_Nb_Name_En         IN     VARCHAR2,
                              p_Nb_Edrpou          IN     VARCHAR2,
                              p_Nb_Is_Authorized   IN     VARCHAR2,
                              p_NB_NUM             IN     VARCHAR2,
                              p_Res                   OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (5);

        OPEN p_Res FOR
            SELECT b.Nb_Id,
                   b.Nb_Nb,
                   b.Nb_Mfo,
                   nb.Nb_Mfo || ' ' || nb.nb_sname
                       AS Nb_Main_Name,
                   b.Nb_Name_En,
                   b.Nb_Name,
                   b.Nb_Sname,
                   b.Nb_Ur_Address,
                   b.Nb_Ur_Address_En,
                   b.Nb_Edrpou,
                   b.Nb_Is_Authorized,
                   Bl.Dic_Name
                       AS Nb_Is_Authorized_Name,
                   b.History_Status,
                   s.Dic_Name
                       AS History_Status_Name,
                   b.Nb_Num
              FROM V_Ndi_Bank  b
                   JOIN v_Ddn_Hist_Status s ON b.History_Status = s.Dic_Code
                   JOIN v_Ddn_Boolean Bl ON b.Nb_Is_Authorized = Bl.Dic_Code
                   LEFT JOIN V_Ndi_Bank nb ON nb.nb_id = b.nb_nb
             WHERE     1 = 1
                   --AND b.History_Status = 'A'
                   AND --TODO: изменить условие, когда будут известны фильтры, которые будут заполнятся на интерфейсе
                       (p_Nb_Nb IS NULL OR b.Nb_Nb = p_Nb_Nb)
                   AND (p_Nb_Mfo IS NULL OR b.Nb_Mfo = p_Nb_Mfo)
                   AND (   p_Nb_Name IS NULL
                        OR LOWER (b.Nb_Name) LIKE
                               '%' || LOWER (p_Nb_Name) || '%'
                        OR LOWER (b.Nb_Name) LIKE LOWER (p_Nb_Name) || '%')
                   AND (   p_Nb_Name_En IS NULL
                        OR b.Nb_Name_En LIKE '%' || p_Nb_Name_En || '%'
                        OR b.Nb_Name_En LIKE p_Nb_Name_En || '%')
                   AND (p_Nb_Edrpou IS NULL OR b.Nb_Edrpou = p_Nb_Edrpou)
                   AND (p_NB_NUM IS NULL OR b.Nb_Num = p_NB_NUM)
                   AND b.Nb_Is_Authorized =
                       NVL (p_Nb_Is_Authorized, b.Nb_Is_Authorized);
    END;

    PROCEDURE Get_Ndi_Bank (p_Nb_Id   IN     NUMBER,
                            p_Res        OUT SYS_REFCURSOR,
                            p_contr      OUT SYS_REFCURSOR)
    IS
        l_org   NUMBER := tools.getcurrorg;
    BEGIN
        tools.check_user_and_raise (5);

        OPEN p_Res FOR
            SELECT Nb_Id,
                   Nb_Nb,
                   Nb_Mfo,
                   Nb_Name,
                   Nb_Name_En,
                   Nb_Sname,
                   Nb_Ur_Address,
                   Nb_Ur_Address_En,
                   Nb_Edrpou,
                   Nb_Is_Authorized,
                   Bl.Dic_Name                        AS Nb_Is_Authorized_Name,
                   History_Status,
                   s.Dic_Name                         AS History_Status_Name,
                   Nb_Num,
                   Nb_Is_Treasury,
                   hsi.hs_dt                          AS nb_upd_dt,
                   tools.GetUserLogin (hsi.hs_wu)     AS nb_upd_user,
                   hsd.hs_dt                          AS nb_del_dt,
                   tools.GetUserLogin (hsd.hs_wu)     AS nb_del_user
              FROM Ndi_Bank  b
                   JOIN v_Ddn_Hist_Status s ON b.History_Status = s.Dic_Code
                   JOIN v_Ddn_Boolean Bl ON b.Nb_Is_Authorized = Bl.Dic_Code
                   LEFT JOIN histsession hsi ON (hsi.hs_id = b.nb_hs_upd)
                   LEFT JOIN histsession hsd ON (hsd.hs_id = b.nb_hs_del)
             WHERE Nb_Id = p_Nb_Id;

        OPEN p_contr FOR
            SELECT t.*,
                   hsu.hs_dt                                      AS nbc_hs_upd_dt,
                   tools.GetUserPib (hsu.hs_wu)                   AS nbc_hs_upd_pib,
                   hsd.hs_dt                                      AS nbc_hs_del_dt,
                   tools.GetUserPib (hsd.hs_wu)                   AS nbc_hs_del_pib,
                   'МФО: ' || nb_mfo || '. Назва: ' || nb_name    AS nbc_nb_name
              FROM v_ndi_nb_contract  t
                   JOIN v_ndi_bank b ON (b.nb_id = t.nbc_nb)
                   LEFT JOIN histsession hsu ON (hsu.hs_id = t.nbc_hs_upd)
                   LEFT JOIN histsession hsd ON (hsd.hs_id = t.nbc_hs_del)
             WHERE     t.nbc_nb IN
                           (SELECT nb_id
                              FROM uss_ndi.ndi_bank
                             WHERE nb_nb = p_nb_id OR nb_id = p_nb_id)
                   AND t.com_org = l_org
                   AND t.history_status = 'A';
    END;

    PROCEDURE get_nb_contract_all (p_nb_id   IN     NUMBER,
                                   p_contr      OUT SYS_REFCURSOR)
    IS
        l_org   NUMBER := tools.getcurrorg;
    BEGIN
        tools.check_user_and_raise (5);

        OPEN p_contr FOR
            SELECT t.*,
                   hsu.hs_dt                                      AS nbc_hs_upd_dt,
                   tools.GetUserPib (hsu.hs_wu)                   AS nbc_hs_upd_pib,
                   hsd.hs_dt                                      AS nbc_hs_del_dt,
                   tools.GetUserPib (hsd.hs_wu)                   AS nbc_hs_del_pib,
                   'МФО: ' || nb_mfo || '. Назва: ' || nb_name    AS nbc_nb_name
              FROM v_ndi_nb_contract  t
                   JOIN v_ndi_bank b ON (b.nb_id = t.nbc_nb)
                   LEFT JOIN histsession hsu ON (hsu.hs_id = t.nbc_hs_upd)
                   LEFT JOIN histsession hsd ON (hsd.hs_id = t.nbc_hs_del)
             WHERE     t.nbc_nb IN
                           (SELECT nb_id
                              FROM uss_ndi.ndi_bank
                             WHERE nb_nb = p_nb_id OR nb_id = p_nb_id)
                   AND t.com_org = l_org;
    END;

    PROCEDURE get_nb_contract_banks (p_nb_id   IN     NUMBER,
                                     p_contr      OUT SYS_REFCURSOR)
    IS
        l_org   NUMBER := tools.getcurrorg;
    BEGIN
        tools.check_user_and_raise (9);

        OPEN p_contr FOR
            SELECT t.nb_id                                         AS id,
                   'МФО: ' || nb_mfo || '. Назва: ' || nb_name     AS NAME
              FROM uss_ndi.ndi_bank t
             WHERE nb_nb = p_nb_id OR nb_id = p_nb_id;
    END;

    PROCEDURE set_nb_contract (p_nbc_start_dt   IN DATE,
                               p_nbc_stop_dt    IN DATE,
                               p_nbc_num        IN VARCHAR2,
                               p_nbc_dt         IN DATE,
                               p_nbc_nb         IN NUMBER)
    IS
    BEGIN
        tools.check_user_and_raise (9);
        api$dic_common.set_nb_contract (p_nbc_start_dt   => p_nbc_start_dt,
                                        p_nbc_stop_dt    => p_nbc_stop_dt,
                                        p_nbc_num        => p_nbc_num,
                                        p_nbc_dt         => p_nbc_dt,
                                        p_nbc_nb         => p_nbc_nb);
    END;

    --===============================================
    --                NDI_COUNTRY
    --===============================================
    PROCEDURE Save_Ndi_Country (
        p_Nc_Id      IN     Ndi_Country.Nc_Id%TYPE,
        p_Nc_Code    IN     Ndi_Country.Nc_Code%TYPE,
        p_Nc_Name    IN     Ndi_Country.Nc_Name%TYPE,
        p_Nc_Sname   IN     Ndi_Country.Nc_Sname%TYPE,
        p_New_Id        OUT Ndi_Country.Nc_Id%TYPE)
    IS
        l_Nc_Code_Not_Uniq   NUMBER;
    BEGIN
        tools.check_user_and_raise (7);

        SELECT SIGN (COUNT (*))
          INTO l_Nc_Code_Not_Uniq
          FROM Ndi_Country c
         WHERE     c.Nc_Code = p_Nc_Code
               AND c.history_status = 'A'
               AND c.Nc_Id <> NVL (p_Nc_Id, -999);

        IF l_Nc_Code_Not_Uniq = 1
        THEN
            Raise_Application_Error (
                -20000,
                'Країна з кодом ' || p_Nc_Code || ' вже наявна у довіднику');
        END IF;

        Api$dic_Common.Save_Ndi_Country (
            p_Nc_Id            => p_Nc_Id,
            p_Nc_Code          => p_Nc_Code,
            p_Nc_Name          => p_Nc_Name,
            p_Nc_Sname         => p_Nc_Sname,
            p_History_Status   => Api$dic_Common.c_History_Status_Actual,
            p_New_Id           => p_New_Id);
    END;

    PROCEDURE Delete_Ndi_Country (p_Nc_Id IN Ndi_Country.Nc_Id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        IF p_Nc_Id IN (-1, 0)
        THEN
            Raise_Application_Error (
                -20000,
                'Неможливо виконати видалення. Існують елементи, що посилаються на даний запис!');
        END IF;

        Api$dic_Common.Set_Ndi_Country_Hist_St (
            p_Nc_Id            => p_Nc_Id,
            p_History_Status   => Api$dic_Common.c_History_Status_Historical);
    END;

    PROCEDURE Query_Ndi_Country (p_Nc_Code   IN     Ndi_Country.Nc_Code%TYPE,
                                 p_Nc_Name   IN     Ndi_Country.Nc_Name%TYPE,
                                 p_Res          OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        OPEN p_Res FOR
            SELECT c.Nc_Id,
                   c.Nc_Code,
                   c.Nc_Name,
                   c.Nc_Sname,
                   c.History_Status,
                   s.Dic_Name     AS History_Status_Name
              FROM Ndi_Country  c
                   JOIN Uss_Ndi.v_Ddn_Hist_Status s
                       ON c.History_Status = s.Dic_Value
             WHERE     History_Status = 'A'
                   AND c.Nc_Id > 0
                   AND (   p_Nc_Code IS NULL
                        OR c.Nc_Code LIKE '%' || p_Nc_Code || '%')
                   AND (   p_Nc_Name IS NULL
                        OR c.Nc_Name LIKE '%' || p_Nc_Name || '%');
    END;

    PROCEDURE Get_Ndi_Country (p_Nc_Id   IN     Ndi_Country.Nc_Id%TYPE,
                               p_Res        OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        OPEN p_Res FOR
            SELECT c.Nc_Id,
                   c.Nc_Code,
                   c.Nc_Name,
                   c.Nc_Sname,
                   c.History_Status,
                   s.Dic_Name     AS History_Status_Name
              FROM Ndi_Country  c
                   JOIN Uss_Ndi.v_Ddn_Hist_Status s
                       ON c.History_Status = s.Dic_Value
             WHERE c.Nc_Id = p_Nc_Id;
    END;

    ---------------------------------------------------------------
    ------------------------REJECT REASON--------------------------
    ---------------------------------------------------------------
    --GET BY ID
    PROCEDURE GET_REJECT_REASON (P_ID    IN     NDI_REJECT_REASON.NJR_ID%TYPE,
                                 P_RES      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN P_RES FOR
            SELECT t.*,
                   (SELECT MAX (z.DIC_NAME)
                      FROM v_ddn_record_src z
                     WHERE z.DIC_VALUE = t.record_src)     AS record_src_name,
                   tools.can_edit_record (t.record_src)    AS can_Edit_Record
              FROM NDI_REJECT_REASON t
             WHERE NJR_ID = P_ID;
    END;

    --LIST
    PROCEDURE QUERY_REJECT_REASON (p_NJR_CODE   IN     VARCHAR2,
                                   p_NJR_NAME   IN     VARCHAR2,
                                   p_NJR_NST    IN     NUMBER,
                                   P_RES           OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN P_RES FOR
            SELECT rr.*,
                   (SELECT MAX (z.DIC_NAME)
                      FROM v_ddn_record_src z
                     WHERE z.DIC_VALUE = rr.record_src)
                       AS record_src_name,
                   tools.can_edit_record (rr.record_src)
                       AS can_Edit_Record
              FROM NDI_REJECT_REASON  RR
                   LEFT JOIN V_NDI_SERVICE_TYPE ST
                       ON (RR.NJR_NST = ST.nst_id)
             WHERE     RR.HISTORY_STATUS = 'A'
                   AND (p_NJR_CODE IS NULL OR RR.NJR_CODE = p_NJR_CODE)
                   AND (   p_NJR_NAME IS NULL
                        OR UPPER (RR.NJR_NAME) LIKE
                               '%' || UPPER (p_NJR_NAME) || '%')
                   AND (p_NJR_NST IS NULL OR RR.NJR_NST = p_NJR_NST);
    END;

    --DELETE
    PROCEDURE DELETE_REJECT_REASON (P_NJR_ID NDI_REJECT_REASON.NJR_ID%TYPE)
    IS
    BEGIN
        api$dic_Common.DELETE_REJECT_REASON (P_NJR_ID => P_NJR_ID);
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
        l_cnt   NUMBER (10);
    BEGIN
        --#77115  20220512
        IF p_njr_code IS NULL
        THEN
            raise_application_error (
                -20002,
                'Код причини відмови повинен бути заповнений');
        END IF;

        IF p_njr_id IS NULL
        THEN
            SELECT COUNT (1)
              INTO l_cnt
              FROM NDI_REJECT_REASON
             WHERE njr_code = p_njr_code AND HISTORY_STATUS = 'A';
        ELSIF p_njr_id IS NOT NULL
        THEN
            SELECT COUNT (1)
              INTO l_cnt
              FROM NDI_REJECT_REASON
             WHERE     njr_code = p_njr_code
                   AND njr_id != p_njr_id
                   AND HISTORY_STATUS = 'A';
        END IF;

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20002,
                   'Код причини відмови "'
                || p_njr_code
                || '" вже присутній в довіднику');
        END IF;

        api$dic_Common.save_reject_reason (p_njr_id      => p_njr_id,
                                           p_njr_code    => p_njr_code,
                                           p_njr_name    => p_njr_name,
                                           p_njr_order   => p_njr_order,
                                           p_njr_nst     => p_njr_nst,
                                           p_new_id      => p_new_id);
    END;

    ---------------------------------------------------------------
    ------------------------distrib purpose------------------------
    ---------------------------------------------------------------
    --Отримати запис по ідентифікатору
    PROCEDURE get_distrib_purpose_gr (
        p_id    IN     ndi_distrib_purpose_gr.dpg_id%TYPE,
        p_res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (5);
        Api$dic_Common.get_distrib_purpose_gr (p_id => p_id, p_res => p_res);
    END;

    --Список за фільтром
    PROCEDURE query_distrib_purpose_gr (p_dpg_name   IN     VARCHAR2,
                                        p_res           OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (5);
        -- RAISE_APPLICATION_ERROR(-20002, 'test');
        Api$dic_Common.query_distrib_purpose_gr (p_dpg_name   => p_dpg_name,
                                                 p_res        => p_res);
    END;

    --Вилучити
    PROCEDURE delete_distrib_purpose_gr (
        p_id   ndi_distrib_purpose_gr.dpg_id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (7);
        Api$dic_Common.delete_distrib_purpose_gr (p_id => p_id);
    END;

    --Зберегти
    PROCEDURE save_distrib_purpose_gr (
        p_dpg_id           IN     ndi_distrib_purpose_gr.dpg_id%TYPE,
        p_dpg_name         IN     ndi_distrib_purpose_gr.dpg_name%TYPE,
        p_dpg_is_gov       IN     ndi_distrib_purpose_gr.dpg_is_gov%TYPE,
        p_dpg_is_own       IN     ndi_distrib_purpose_gr.dpg_is_own%TYPE,
        p_dpg_template     IN     ndi_distrib_purpose_gr.dpg_template%TYPE,
        p_dpg_tp           IN     ndi_distrib_purpose_gr.dpg_tp%TYPE,
        p_dpg_hs_del       IN     ndi_distrib_purpose_gr.dpg_hs_del%TYPE,
        p_dpg_hs_upd       IN     ndi_distrib_purpose_gr.dpg_hs_upd%TYPE,
        p_history_status   IN     ndi_distrib_purpose_gr.history_status%TYPE,
        p_new_id              OUT ndi_distrib_purpose_gr.dpg_id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (7);
        Api$dic_Common.save_distrib_purpose_gr (
            p_dpg_id           => p_dpg_id,
            p_dpg_name         => p_dpg_name,
            p_dpg_is_gov       => p_dpg_is_gov,
            p_dpg_is_own       => p_dpg_is_own,
            p_dpg_template     => p_dpg_template,
            p_dpg_tp           => p_dpg_tp,
            p_dpg_hs_del       => NULL,
            p_dpg_hs_upd       => NULL,
            p_history_status   => api$dic_visit.c_history_status_actual,
            p_new_id           => p_new_id);
    END;

    ---------------------------------------------------------------
    ----------------------------deduction--------------------------
    ---------------------------------------------------------------
    --GET BY ID
    PROCEDURE GET_DEDUCTION (P_NDN_ID       IN     NDI_DEDUCTION.NDN_ID%TYPE,
                             P_RES             OUT SYS_REFCURSOR,
                             P_nst_config      OUT SYS_REFCURSOR,
                             p_npt_config      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN P_RES FOR SELECT t.*
                         FROM NDI_DEDUCTION t
                        WHERE NDN_ID = P_NDN_ID;

        OPEN P_nst_config FOR
            SELECT t.*,
                   s.nst_name                      AS nnnc_nst_name,
                   hu.hs_dt                        AS nnnc_hs_ins_Dt,
                   tools.GetUserPib (hu.hs_wu)     AS nnnc_hs_ins_Pib,
                   hd.hs_dt                        AS ndn_Hs_Del_Dt,
                   tools.GetUserPib (hd.hs_wu)     AS ndn_Hs_Del_Pib
              FROM ndi_nst_dn_config  t
                   JOIN uss_ndi.v_ndi_service_type s
                       ON (s.nst_id = t.nnnc_nst)
                   LEFT JOIN histsession hu ON (hu.hs_id = t.nnnc_hs_ins)
                   LEFT JOIN histsession hd ON (hd.hs_id = t.nnnc_hs_del)
             WHERE t.nnnc_ndn = P_NDN_ID;

        OPEN P_npt_config FOR
            SELECT t.*,
                   p.npt_code                      AS nnde_npt_code,
                   p.npt_name                      AS nnde_npt_name,
                   hu.hs_dt                        AS nnnc_hs_ins_Dt,
                   tools.GetUserPib (hu.hs_wu)     AS nnnc_hs_ins_Pib,
                   hd.hs_dt                        AS ndn_Hs_Del_Dt,
                   tools.GetUserPib (hd.hs_wu)     AS ndn_Hs_Del_Pib
              FROM ndi_nst_dn_exclude  t
                   JOIN ndi_payment_type p ON (p.npt_id = t.nnde_npt)
                   JOIN ndi_nst_dn_config c ON (c.nnnc_id = t.nnde_nnnc)
                   LEFT JOIN histsession hu ON (hu.hs_id = t.nnde_hs_ins)
                   LEFT JOIN histsession hd ON (hd.hs_id = t.nnde_hs_del)
             WHERE c.nnnc_ndn = P_NDN_ID;
    END;

    --LIST
    PROCEDURE QUERY_DEDUCTION (p_NDN_CODE       IN     VARCHAR2,
                               p_NDN_NAME       IN     VARCHAR2,
                               p_show_deleted   IN     VARCHAR2,
                               P_RES               OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN P_RES FOR
            SELECT d.*,
                   hu.hs_dt                        AS ndn_Hs_Upd_Dt,
                   tools.GetUserPib (hu.hs_wu)     AS ndn_Hs_Upd_Pib,
                   hd.hs_dt                        AS ndn_Hs_Del_Dt,
                   tools.GetUserPib (hd.hs_wu)     AS ndn_Hs_Del_Pib
              FROM NDI_DEDUCTION  D
                   LEFT JOIN histsession hu ON (hu.hs_id = d.ndn_hs_upd)
                   LEFT JOIN histsession hd ON (hd.hs_id = d.ndn_hs_del)
             WHERE     (   p_show_deleted = 'T'
                        OR p_show_deleted = 'F' AND D.HISTORY_STATUS = 'A')
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
        Api$dic_Common.DELETE_DEDUCTION (P_NDN_ID => P_NDN_ID);
    END;

    --SAVE
    PROCEDURE SAVE_DEDUCTION (
        P_NDN_ID          IN     NDI_DEDUCTION.NDN_ID%TYPE,
        p_NDN_CODE        IN     NDI_DEDUCTION.NDN_CODE%TYPE,
        p_NDN_NAME        IN     NDI_DEDUCTION.NDN_NAME%TYPE,
        p_NDN_MAX_PRC     IN     NDI_DEDUCTION.NDN_MAX_PRC%TYPE,
        p_NDN_ORDER       IN     NDI_DEDUCTION.NDN_ORDER%TYPE,
        p_NDN_CALC_STEP   IN     NDI_DEDUCTION.NDN_CALC_STEP%TYPE,
        p_NDN_DN_TP       IN     NDI_DEDUCTION.NDN_DN_TP%TYPE,
        p_nst_config      IN     CLOB,
        p_npt_config      IN     CLOB,
        P_NEW_ID             OUT NDI_DEDUCTION.NDN_ID%TYPE)
    IS
    BEGIN
        Api$dic_Common.SAVE_DEDUCTION (P_NDN_ID            => P_NDN_ID,
                                       p_NDN_CODE          => p_NDN_CODE,
                                       p_NDN_NAME          => p_NDN_NAME,
                                       p_NDN_MAX_PRC       => p_NDN_MAX_PRC,
                                       p_NDN_TP            => NULL,
                                       p_NDN_START_DT      => NULL,
                                       p_NDN_STOP_DT       => NULL,
                                       p_NDN_POST_FEE_TP   => NULL,
                                       p_NDN_SRC_SUM_TP    => NULL,
                                       p_NDN_OP            => NULL,
                                       p_NDN_ORDER         => p_NDN_ORDER,
                                       p_NDN_CALC_STEP     => p_NDN_CALC_STEP,
                                       p_NDN_DN_TP         => p_NDN_DN_TP,
                                       p_nst_config        => p_nst_config,
                                       p_npt_config        => p_npt_config,
                                       P_NEW_ID            => P_NEW_ID);
    END;

    ---------------------------------------------------------------
    ----------------------------NDI_ACC_SETUP ---------------------
    ---------------------------------------------------------------


    PROCEDURE get_acc_setup (p_res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT nas.acs_id                 AS acs_id,
                   --V_DDN_PDV --тип пдв
                   nas.acs_vat_tp             AS acs_vat_tp,
                   dp.dic_sname               AS acs_vat_tp_name,
                   -- NDI_FUNCTIONARY --керівник для підписання звітності
                   nas.acs_fnc_signer         AS acs_fnc_signer,
                   -- NDI_PAY_PERSON --орган дксу
                   nas.acs_dpp_dksu           AS acs_dpp_dksu,
                   pp.dpp_sname               AS acs_dpp_dksu_name,
                   --рівень мережі
                   nas.acs_net_level          AS acs_net_level,
                   --код розпорядника
                   nas.acs_adm_code           AS acs_adm_code,
                   --рівень розпорядника
                   nas.acs_adm_level          AS acs_adm_level,
                   --код області
                   nas.acs_province_code      AS acs_province_code,
                   --код головного управління дксу
                   nas.acs_dksu_main_code     AS acs_dksu_main_code,
                   --код управління дксу
                   nas.acs_dksu_code          AS acs_dksu_code,
                   --дата реєстрації в дксу
                   nas.acs_dksu_reg_dt        AS acs_dksu_reg_dt,
                   -- NDI_PAY_PERSON_ACC рахунок сзн в дксу
                   nas.acs_dppa_adm           AS acs_dppa_adm,
                   --код відповідального виконавця бюджетних програм
                   nas.acs_doer_code          AS acs_doer_code,
                   --код відомчої класифікації
                   nas.acs_kvk_code           AS acs_kvk_code,
                   --Назва відомчої класифікації
                   nas.acs_kvk_name           AS acs_kvk_name,
                   --дата закриття бюджетного року
                   nas.acs_doc_close_dt       AS acs_doc_close_dt,
                   -- NDI_FUNCTIONARY особа що перевіряє бюджетні обороти
                   acs_fnc_bt_check           AS acs_fnc_bt_check,
                   -- NDI_FUNCTIONARY особа що затверджує бюджетні обороти
                   acs_fnc_bt_allow           AS acs_fnc_bt_allow
              FROM v_ndi_acc_setup  nas
                   LEFT JOIN v_ddn_pdv dp ON dp.dic_value = nas.acs_vat_tp
                   LEFT JOIN ndi_pay_person pp
                       ON pp.dpp_id = nas.acs_dpp_dksu
             WHERE nas.com_org = tools.getcurrorg;
    END;

    PROCEDURE save_acc_setup (
        p_acs_id               IN     ndi_acc_setup.acs_id%TYPE,
        p_acs_vat_tp           IN     ndi_acc_setup.acs_vat_tp%TYPE,
        p_acs_fnc_signer       IN     ndi_acc_setup.acs_fnc_signer%TYPE,
        p_acs_dpp_dksu         IN     ndi_acc_setup.acs_dpp_dksu%TYPE,
        p_acs_net_level        IN     ndi_acc_setup.acs_net_level%TYPE,
        p_acs_adm_code         IN     ndi_acc_setup.acs_adm_code%TYPE,
        p_acs_adm_level        IN     ndi_acc_setup.acs_adm_level%TYPE,
        p_acs_province_code    IN     ndi_acc_setup.acs_province_code%TYPE,
        p_acs_dksu_main_code   IN     ndi_acc_setup.acs_dksu_main_code%TYPE,
        p_acs_dksu_code        IN     ndi_acc_setup.acs_dksu_code%TYPE,
        p_acs_dksu_reg_dt      IN     ndi_acc_setup.acs_dksu_reg_dt%TYPE,
        p_acs_dppa_adm         IN     ndi_acc_setup.acs_dppa_adm%TYPE,
        p_acs_doer_code        IN     ndi_acc_setup.acs_doer_code%TYPE,
        p_acs_kvk_code         IN     ndi_acc_setup.acs_kvk_code%TYPE,
        p_acs_doc_close_dt     IN     ndi_acc_setup.acs_doc_close_dt%TYPE,
        p_acs_fnc_bt_check     IN     ndi_acc_setup.acs_fnc_bt_check%TYPE,
        p_acs_fnc_bt_allow     IN     ndi_acc_setup.acs_fnc_bt_allow%TYPE,
        p_acs_kvk_name         IN     ndi_acc_setup.acs_kvk_name%TYPE,
        p_new_id                  OUT ndi_acc_setup.acs_id%TYPE)
    IS
    BEGIN
        IF (p_acs_dksu_reg_dt > TRUNC (SYSDATE))
        THEN
            raise_application_error (
                -20000,
                'Дата реєстрації в ДКСУ не може перевищувати поточну дату!');
        END IF;

        api$dic_common.save_acc_setup (
            p_acs_id               => p_acs_id,
            p_acs_vat_tp           => p_acs_vat_tp,
            p_acs_fnc_signer       => p_acs_fnc_signer,
            p_acs_dpp_dksu         => p_acs_dpp_dksu,
            p_acs_net_level        => p_acs_net_level,
            p_acs_adm_code         => p_acs_adm_code,
            p_acs_adm_level        => p_acs_adm_level,
            p_acs_province_code    => p_acs_province_code,
            p_acs_dksu_main_code   => p_acs_dksu_main_code,
            p_acs_dksu_code        => p_acs_dksu_code,
            p_acs_dksu_reg_dt      => p_acs_dksu_reg_dt,
            p_acs_dppa_adm         => p_acs_dppa_adm,
            p_acs_doer_code        => p_acs_doer_code,
            p_acs_kvk_code         => p_acs_kvk_code,
            p_acs_doc_close_dt     => p_acs_doc_close_dt,
            p_acs_fnc_bt_check     => p_acs_fnc_bt_check,
            p_acs_fnc_bt_allow     => p_acs_fnc_bt_allow,
            p_acs_kvk_name         => p_acs_kvk_name,
            p_new_id               => p_new_id);
    END;


    ---------------------------------------------------------------
    ----------------------------V_OPFU-----------------------------
    ---------------------------------------------------------------


    PROCEDURE query_opfu (p_org_id_reg   IN     NUMBER,
                          p_org_id_soc   IN     NUMBER,
                          p_org_id_ter   IN     NUMBER,
                          p_res             OUT SYS_REFCURSOR)
    IS
    BEGIN
        --raise_application_error(-20000, 'p_org_id_reg='||p_org_id_reg||';p_org_id_soc='||p_org_id_soc||';p_org_id_ter='||p_org_id_ter);

        OPEN p_res FOR
            SELECT l1.org_id       AS org_id_reg,
                   l1.org_name     AS org_name_reg,
                   l2.org_id       AS org_id_soc,
                   l2.org_name     AS org_name_soc,
                   l3.org_id       AS org_id_ter,
                   l3.org_name     AS org_name_ter
              FROM v_opfu  l1
                   LEFT JOIN v_opfu l2
                       ON (    l2.org_org = l1.org_id
                           AND l2.org_st = 'A'
                           AND (   p_org_id_reg IS NOT NULL
                                OR p_org_id_soc IS NOT NULL
                                OR 1 = 2))
                   LEFT JOIN v_opfu l3
                       ON (    l3.org_org = l2.org_id
                           AND l3.org_st = 'A'
                           AND (   p_org_id_ter IS NOT NULL
                                OR p_org_id_soc IS NOT NULL
                                OR 1 = 2))
             WHERE     1 = 1
                   AND l1.org_st = 'A'
                   AND l1.org_to = 31
                   AND (p_org_id_reg IS NULL OR l1.org_id = p_org_id_reg)
                   AND (p_org_id_soc IS NULL OR l2.org_id = p_org_id_soc)
                   AND (p_org_id_ter IS NULL OR l3.org_id = p_org_id_ter);

        RETURN;
    /*CASE
     WHEN p_org_id_reg IS NOT NULL AND (p_org_id_soc IS NULL OR
           p_org_id_ter IS NULL ) THEN
        OPEN p_res FOR
          SELECT o.org_id    AS org_id_reg,
                 o.org_name  AS org_name_reg,
                 sc.org_id   AS org_id_soc,
                 sc.org_name AS org_name_soc
            FROM v_opfu o
           RIGHT JOIN (SELECT org_id, org_name, org_org
                         FROM v_opfu
                        WHERE org_to = 34
                           OR org_to = 32) sc
              ON o.org_id = sc.org_org
           WHERE p_org_id_reg = o.org_id and o.org_st='A';

      WHEN p_org_id_reg IS NOT NULL OR p_org_id_soc IS NOT NULL OR
           p_org_id_ter IS NOT NULL THEN
        OPEN p_res FOR
          SELECT o.org_id        AS org_id_reg,
                 o.org_name      AS org_name_reg,
                 sc.org_id       AS org_id_soc,
                 sc.org_name     AS org_name_soc,
                 sc.org_id_ter   AS org_id_ter,
                 sc.org_name_ter AS org_name_ter

            FROM v_opfu o
            JOIN (SELECT s.org_id,
                        s.org_name,
                        s.org_org,
                        tr.org_name AS org_name_ter,
                        tr.org_id   AS org_id_ter
                   FROM v_opfu s
                   LEFT JOIN  (SELECT t.org_id, t.org_name, t.org_org
                                 FROM v_opfu t
                                WHERE org_to = 33
                                  AND (p_org_id_ter IS NULL OR t.org_id = p_org_id_ter)
                                  AND t.org_st = 'A'
                               ) tr
                        ON s.org_id = tr.org_org
                  WHERE (s.org_to = 34 OR s.org_to = 32)
                    AND (p_org_id_soc IS NULL OR
                        s.org_id = p_org_id_soc)
                        AND s.org_st='A') sc
        ON o.org_id = sc.org_org
     WHERE (p_org_id_reg IS NULL OR p_org_id_reg = o.org_id) and o.org_st='A';

      ELSE
        OPEN p_res FOR
          SELECT o.org_id AS org_id_reg, o.org_name AS org_name_reg
            FROM v_opfu o
           WHERE (o.org_to = 31) and o.org_st='A'
             AND (p_org_id_reg IS NULL OR p_org_id_reg = o.org_id);
    END CASE;*/

    END;

    PROCEDURE query_children_services (
        p_ncs_code         IN     ndi_children_service.ncs_code%TYPE,
        p_ncs_name         IN     ndi_children_service.ncs_name%TYPE,
        p_history_status   IN     ndi_children_service.history_status%TYPE,
        p_res                 OUT SYS_REFCURSOR)
    IS
    BEGIN
        --RAISE_APPLICATION_ERROR(-20002, p_ncs_name);
        OPEN p_res FOR
            SELECT ncs_code        AS ncs_code,
                   ncs_name        AS ncs_name,
                   ncs_kaot,
                   nk.kaot_name    AS ncs_kaot_name,
                   ncs_address     AS ncs_address,
                   ncs_contacts    AS ncs_contacts,
                   (CASE
                        WHEN history_status = 'A' THEN 'Підключена'
                        ELSE 'Відключена'
                    END)           AS ncs_status,
                   b1.dic_name     AS ncs_is_adopt,
                   b2.dic_name     AS ncs_is_advice,
                   b3.dic_name     AS ncs_is_ps_dbst,
                   b4.dic_name     AS ncs_is_guardianship
              FROM ndi_children_service  cs
                   LEFT JOIN v_ndi_katottg nk ON nk.kaot_id = cs.ncs_kaot
                   LEFT JOIN v_ddn_boolean b1 ON cs.ncs_adopt = b1.dic_value
                   LEFT JOIN v_ddn_boolean b2 ON cs.ncs_advice = b2.dic_value
                   LEFT JOIN v_ddn_boolean b3
                       ON cs.ncs_ps_dbst = b2.dic_value
                   LEFT JOIN v_ddn_boolean b4
                       ON cs.ncs_guardianship = b4.dic_value
             WHERE     (p_ncs_code IS NULL OR cs.ncs_code LIKE p_ncs_code)
                   AND (   p_ncs_name IS NULL
                        OR cs.ncs_name LIKE '%' || p_ncs_name || '%')
                   AND (   p_history_status IS NULL
                        OR cs.history_status = p_history_status);
    END;


    -- #81615: 'Базовий календар, список
    PROCEDURE GET_NDI_CALENDAR_LIST (p_NCB_DT_From   IN     DATE,
                                     p_NCB_DT_To     IN     DATE,
                                     p_NCB_WORK_TP   IN     VARCHAR2,
                                     p_res              OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        OPEN p_res FOR
            SELECT NCB_ID,
                   NCB_DT,
                   NCB_WORK_TP,
                   tp.DIC_NAME                       AS ncb_work_tp_name,
                   NCB_DESCRIPTION,
                   hs.hs_dt                          AS hs_upd_dt,
                   tools.GetUserLogin (hs.hs_wu)     AS hs_upd_user
              FROM NDI_CALENDAR_BASE  t
                   JOIN v_ddn_ncb_work_tp tp
                       ON (tp.DIC_VALUE = t.ncb_work_tp)
                   LEFT JOIN histsession hs ON (hs.hs_id = t.ncb_hs_upd)
             WHERE     1 = 1
                   AND t.ncb_dt BETWEEN p_NCB_DT_From AND p_NCB_DT_To
                   AND t.ncb_work_tp =
                       COALESCE (p_NCB_WORK_TP, t.ncb_work_tp)
                   AND ROWNUM <= 1000;
    END;


    -- #81615: 'Базовий календарб картка
    PROCEDURE GET_NDI_CALENDAR_CARD (p_nbc_id   IN     NUMBER,
                                     p_res         OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        OPEN p_res FOR
            SELECT NCB_ID,
                   NCB_DT,
                   NCB_WORK_TP,
                   tp.DIC_NAME                       AS nbc_work_tp_name,
                   NCB_DESCRIPTION,
                   hs.hs_dt                          AS hs_upd_dt,
                   tools.GetUserLogin (hs.hs_wu)     AS hs_upd_user
              FROM NDI_CALENDAR_BASE  t
                   JOIN v_ddn_ncb_work_tp tp
                       ON (tp.DIC_VALUE = t.ncb_work_tp)
                   LEFT JOIN histsession hs ON (hs.hs_id = t.ncb_hs_upd)
             WHERE t.ncb_id = p_nbc_id;
    END;

    -- #81615: 'Базовий календар, оновленння
    PROCEDURE UPDATE_NDI_CALENDAR (p_ncb_id            IN NUMBER,
                                   p_NCB_WORK_TP       IN VARCHAR2,
                                   p_NCB_DESCRIPTION   IN VARCHAR2)
    IS
    BEGIN
        tools.check_user_and_raise (7);
        Api$dic_Common.UPDATE_NDI_CALENDAR (p_ncb_id,
                                            p_NCB_WORK_TP,
                                            p_NCB_DESCRIPTION);
    END;

    --===============================================
    --                NDI_Org2Kaot
    --===============================================

    PROCEDURE Save_Ndi_Org2Kaot (
        p_NOK_ID     IN     NDI_ORG2KAOT.NOK_ID%TYPE,
        p_NOK_ORG    IN     NDI_ORG2KAOT.NOK_ORG%TYPE,
        p_NOK_KAOT   IN     NDI_ORG2KAOT.NOK_KAOT%TYPE,
        p_new_id        OUT NDI_ORG2KAOT.NOK_ID%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        Api$dic_Common.Save_Ndi_Org2Kaot (
            p_NOK_ID           => p_NOK_ID,
            p_NOK_ORG          => p_NOK_ORG,
            p_NOK_KAOT         => p_NOK_KAOT,
            p_History_Status   => Api$dic_Common.c_History_Status_Actual,
            p_new_id           => p_new_id);
    END;

    PROCEDURE Delete_Ndi_Org2Kaot (p_Nok_Id IN Ndi_Org2Kaot.Nok_Id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        Api$dic_Common.Set_Ndi_Org2Kaot_Hist_St (
            p_Nok_Id           => p_Nok_Id,
            p_History_Status   => Api$dic_Common.c_History_Status_Historical);
    END;

    PROCEDURE Query_Ndi_Org2Kaot (
        p_Nok_Org    IN     Ndi_Org2Kaot.Nok_Org%TYPE,
        p_Nok_Kaot   IN     Ndi_Org2Kaot.Nok_Kaot%TYPE,
        p_Res           OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (13);

        OPEN p_Res FOR
            SELECT c.*,
                   p.org_code || ' ' || p.org_name               AS nok_org_name,
                   api$dic_katottg.get_kaot_name (c.nok_kaot)    AS nok_kaot_name
              FROM Ndi_Org2Kaot  c
                   JOIN v_opfu p ON (p.org_id = c.nok_org)
                   JOIN ndi_katottg k ON (k.kaot_id = c.nok_kaot)
             WHERE     History_Status = 'A'
                   AND (p_Nok_Org IS NULL OR c.nok_org = p_Nok_Org)
                   AND (p_Nok_Kaot IS NULL OR c.nok_kaot = p_Nok_Kaot);
    END;

    PROCEDURE Get_Ndi_Org2Kaot (p_Nok_Id   IN     Ndi_Country.Nc_Id%TYPE,
                                p_Res         OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        OPEN p_Res FOR
            SELECT c.*,
                   p.org_code || ' ' || p.org_name               AS nok_org_name,
                   api$dic_katottg.get_kaot_name (c.nok_kaot)    AS nok_kaot_name
              FROM Ndi_Org2Kaot  c
                   JOIN v_opfu p ON (p.org_id = c.nok_org)
                   JOIN ndi_katottg k ON (k.kaot_id = c.nok_kaot)
             WHERE c.nok_id = p_Nok_Id;
    END;

    -- #112982
    PROCEDURE get_ddn_inv_reason_list (res_cur OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
              SELECT t.*,
                     c.nddc_src,
                     CASE WHEN c.nddc_id IS NOT NULL THEN 'ЦБІ' END
                         AS nddc_src_name,
                     c.nddc_code_src
                FROM v_ddn_inv_reason t
                     LEFT JOIN ndi_decoding_config c
                         ON (    c.nddc_code_dest = t.DIC_VALUE
                             AND c.nddc_tp = 'INV_REASON')
               WHERE t.DIC_ST = 'A'
            ORDER BY t.DIC_SRTORDR;
    END;


    --===============================================
    --                NDI_CBI_WARES
    --===============================================

    PROCEDURE save_ndi_cbi_wares (
        p_wrn_Id      IN     ndi_cbi_wares.wrn_id%TYPE,
        p_wrn_shifr   IN     VARCHAR2,
        p_wrn_name    IN     VARCHAR2,
        p_new_id         OUT NDI_ORG2KAOT.NOK_ID%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        IF p_WRN_ID IS NULL
        THEN
            INSERT INTO NDI_CBI_WARES (WRN_SHIFR,
                                       WRN_NAME,
                                       WRN_ST,
                                       HISTORY_STATUS)
                 VALUES (p_WRN_SHIFR,
                         p_WRN_NAME,
                         'A',
                         'A')
              RETURNING WRN_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_WRN_ID;

            UPDATE NDI_CBI_WARES
               SET WRN_SHIFR = p_WRN_SHIFR, WRN_NAME = p_WRN_NAME
             WHERE WRN_ID = p_WRN_ID;
        END IF;
    END;

    PROCEDURE delete_ndi_cbi_wares (p_wrn_Id IN ndi_cbi_wares.wrn_id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        UPDATE ndi_cbi_wares t
           SET t.history_status = 'H'
         WHERE t.wrn_id = p_wrn_id;
    END;

    PROCEDURE get_ndi_cbi_wares (p_wrn_Id   IN     ndi_cbi_wares.wrn_id%TYPE,
                                 p_Res         OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        OPEN p_Res FOR SELECT t.*
                         FROM ndi_cbi_wares t
                        WHERE t.wrn_id = p_wrn_Id;
    END;

    PROCEDURE query_ndi_cbi_wares (p_wrn_shifr   IN     VARCHAR2,
                                   p_wrn_name    IN     VARCHAR2,
                                   res_cur          OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT t.*
              FROM ndi_cbi_wares t
             WHERE     1 = 1
                   AND (   p_wrn_shifr IS NULL
                        OR t.wrn_shifr LIKE p_wrn_shifr || '%')
                   AND (   p_wrn_name IS NULL
                        OR UPPER (t.wrn_name) LIKE
                               '%' || UPPER (p_wrn_name) || '%');
    END;
END Dnet$dic_Common;
/