/* Formatted on 8/12/2025 5:55:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.API$DIC_COMMON
IS
    -- Author  : SHOSTAK
    -- Created : 19.05.2021 9:52:48
    -- Purpose : Функції для роботи з загальними довідниками

    Package_Name         CONSTANT VARCHAR2 (100) := 'API$DIC_COMMON';

    c_History_Status_Actual       VARCHAR2 (10) := 'A';
    c_History_Status_Historical   VARCHAR2 (10) := 'H';

    TYPE r_Rcukru IS RECORD
    (
        GLB      VARCHAR2 (10),
        Glmfo    VARCHAR2 (10),
        Nb       VARCHAR (250),
        Ikod     VARCHAR2 (10)
    );

    TYPE t_Rcukru IS TABLE OF r_Rcukru;

    TYPE r_ndi_nst_dn_config IS RECORD
    (
        Nnnc_Id           NUMBER,
        Nnnc_Nst          NUMBER,
        Nnnc_Ndn          NUMBER,
        History_Status    VARCHAR2 (10),
        New_Id            NUMBER
    );

    TYPE t_ndi_nst_dn_config IS TABLE OF r_ndi_nst_dn_config;

    TYPE r_ndi_nst_dn_exclude IS RECORD
    (
        Nnde_Id           NUMBER,
        Nnde_Nnnc         NUMBER,
        Nnde_Npt          NUMBER,
        History_Status    VARCHAR2 (10),
        New_Id            NUMBER
    );

    TYPE t_ndi_nst_dn_exclude IS TABLE OF r_ndi_nst_dn_exclude;

    PROCEDURE Load_Ndi_Banks (p_Banks CLOB);

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
        p_History_Status     IN     Ndi_Bank.History_Status%TYPE,
        p_NB_NUM             IN     NDI_BANK.NB_NUM%TYPE,
        p_Nb_Is_Treasury     IN     Ndi_Bank.Nb_Is_Treasury%TYPE,
        p_New_Id                OUT Ndi_Bank.Nb_Id%TYPE);

    PROCEDURE set_nb_contract (p_nbc_start_dt   IN DATE,
                               p_nbc_stop_dt    IN DATE,
                               p_nbc_num        IN VARCHAR2,
                               p_nbc_dt         IN DATE,
                               p_nbc_nb         IN NUMBER);

    PROCEDURE Set_Ndi_Bank_Hist_St (
        p_Nb_Id            IN Ndi_Bank.Nb_Id%TYPE,
        p_History_Status      Ndi_Bank.History_Status%TYPE);

    PROCEDURE Save_Ndi_Country (
        p_Nc_Id            IN     Ndi_Country.Nc_Id%TYPE,
        p_Nc_Code          IN     Ndi_Country.Nc_Code%TYPE,
        p_Nc_Name          IN     Ndi_Country.Nc_Name%TYPE,
        p_Nc_Sname         IN     Ndi_Country.Nc_Sname%TYPE,
        p_History_Status   IN     Ndi_Country.History_Status%TYPE,
        p_New_Id              OUT Ndi_Country.Nc_Id%TYPE);

    PROCEDURE Set_Ndi_Country_Hist_St (
        p_Nc_Id            IN Ndi_Country.Nc_Id%TYPE,
        p_History_Status   IN Ndi_Country.History_Status%TYPE);

    ---------------------------------------------------------------
    ------------------------REJECT REASON--------------------------
    ---------------------------------------------------------------
    PROCEDURE Save_Reject_Reason (
        p_NJR_ID      IN     NDI_REJECT_REASON.NJR_ID%TYPE,
        p_NJR_CODE    IN     NDI_REJECT_REASON.NJR_CODE%TYPE,
        p_NJR_NAME    IN     NDI_REJECT_REASON.NJR_NAME%TYPE,
        p_NJR_ORDER   IN     NDI_REJECT_REASON.NJR_ORDER%TYPE,
        p_NJR_NST     IN     NDI_REJECT_REASON.NJR_NST%TYPE,
        p_new_id         OUT NDI_REJECT_REASON.NJR_ID%TYPE);

    PROCEDURE Delete_Reject_Reason (p_NJR_ID NDI_REJECT_REASON.NJR_ID%TYPE);

    ---------------------------------------------------------------
    ------------------------distrib purpose------------------------
    ---------------------------------------------------------------
    -- Отримати запис по ідентифікатору
    PROCEDURE get_distrib_purpose_gr (
        p_id    IN     ndi_distrib_purpose_gr.dpg_id%TYPE,
        p_res      OUT SYS_REFCURSOR);

    -- Зберегти
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

    -- Вилучити
    PROCEDURE delete_distrib_purpose_gr (
        p_id   ndi_distrib_purpose_gr.dpg_id%TYPE);

    -- Список за фільтром
    PROCEDURE query_distrib_purpose_gr (p_dpg_name   IN     VARCHAR2,
                                        p_res           OUT SYS_REFCURSOR);

    ---------------------------------------------------------------
    ----------------------------deduction--------------------------
    ---------------------------------------------------------------

    PROCEDURE Save_Deduction (
        p_NDN_ID            IN     NDI_DEDUCTION.NDN_ID%TYPE,
        p_NDN_CODE          IN     NDI_DEDUCTION.NDN_CODE%TYPE,
        p_NDN_NAME          IN     NDI_DEDUCTION.NDN_NAME%TYPE,
        p_NDN_MAX_PRC       IN     NDI_DEDUCTION.NDN_MAX_PRC%TYPE,
        p_NDN_TP            IN     NDI_DEDUCTION.NDN_TP%TYPE,
        p_NDN_START_DT      IN     NDI_DEDUCTION.NDN_START_DT%TYPE,
        p_NDN_STOP_DT       IN     NDI_DEDUCTION.NDN_STOP_DT%TYPE,
        p_NDN_POST_FEE_TP   IN     NDI_DEDUCTION.NDN_POST_FEE_TP%TYPE,
        p_NDN_SRC_SUM_TP    IN     NDI_DEDUCTION.NDN_SRC_SUM_TP%TYPE,
        p_NDN_OP            IN     NDI_DEDUCTION.NDN_OP%TYPE,
        p_NDN_ORDER         IN     NDI_DEDUCTION.NDN_ORDER%TYPE,
        p_NDN_CALC_STEP     IN     NDI_DEDUCTION.NDN_CALC_STEP%TYPE,
        p_NDN_DN_TP         IN     NDI_DEDUCTION.NDN_DN_TP%TYPE,
        p_nst_config        IN     CLOB,
        p_npt_config        IN     CLOB,
        p_new_id               OUT NDI_DEDUCTION.NDN_ID%TYPE);

    PROCEDURE Delete_Deduction (p_NDN_ID NDI_DEDUCTION.NDN_ID%TYPE);

    ---------------------------------------------------------------
    ----------------------------NDI_ACC_SETUP ---------------------
    ---------------------------------------------------------------
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

    -----------------------------------------------------------------
    ----------------------------V_OPFU--------- ---------------------
    ---------------------------------------------------------------

    PROCEDURE query_opfu (p_org_id_reg   IN     NUMBER,
                          p_org_id_soc   IN     NUMBER,
                          p_org_id_ter   IN     NUMBER,
                          p_res             OUT SYS_REFCURSOR);



    --Перестворення DDN-представлень
    PROCEDURE recreate_dd_views;

    -- #81615: 'Базовий календар, оновленння
    PROCEDURE UPDATE_NDI_CALENDAR (p_ncb_id            IN NUMBER,
                                   p_NCB_WORK_TP       IN VARCHAR2,
                                   p_NCB_DESCRIPTION   IN VARCHAR2);

    FUNCTION Get_Katottg_Name (p_Kaot_Id IN NUMBER)
        RETURN Ndi_Katottg.Kaot_Name%TYPE;

    FUNCTION Get_Kaot_Region (p_Kaot_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Kaot_District (p_Kaot_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Kaot_City (p_Kaot_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION Get_Kaot_City_Tp (p_Kaot_Id IN NUMBER)
        RETURN VARCHAR2;

    --===============================================
    --                NDI_Org2Kaot
    --===============================================

    PROCEDURE Save_Ndi_Org2Kaot (
        p_NOK_ID           IN     NDI_ORG2KAOT.NOK_ID%TYPE,
        p_NOK_ORG          IN     NDI_ORG2KAOT.NOK_ORG%TYPE,
        p_NOK_KAOT         IN     NDI_ORG2KAOT.NOK_KAOT%TYPE,
        p_History_Status   IN     NDI_ORG2KAOT.History_Status%TYPE,
        p_new_id              OUT NDI_ORG2KAOT.NOK_ID%TYPE);


    PROCEDURE Set_Ndi_Org2Kaot_Hist_St (
        p_Nok_Id           IN NDI_ORG2KAOT.Nok_Id%TYPE,
        p_History_Status   IN NDI_ORG2KAOT.History_Status%TYPE);

    PROCEDURE Save_Ndi_Cbi_Wares (
        p_Wrn_Id           IN     Ndi_Cbi_Wares.Wrn_Id%TYPE,
        p_Wrn_Wt           IN     Ndi_Cbi_Wares.Wrn_Wt%TYPE DEFAULT NULL,
        p_Wrn_Wrn_Main     IN     Ndi_Cbi_Wares.Wrn_Wrn_Main%TYPE DEFAULT NULL,
        p_Wrn_Wrn_Parent   IN     Ndi_Cbi_Wares.Wrn_Wrn_Parent%TYPE DEFAULT NULL,
        p_Wrn_Code         IN     Ndi_Cbi_Wares.Wrn_Code%TYPE DEFAULT NULL,
        p_Wrn_Shifr        IN     Ndi_Cbi_Wares.Wrn_Shifr%TYPE DEFAULT NULL,
        p_Wrn_Art          IN     Ndi_Cbi_Wares.Wrn_Art%TYPE DEFAULT NULL,
        p_Wrn_Name         IN     Ndi_Cbi_Wares.Wrn_Name%TYPE DEFAULT NULL,
        p_Wrn_Duration     IN     Ndi_Cbi_Wares.Wrn_Duration%TYPE DEFAULT NULL,
        p_Wrn_St           IN     Ndi_Cbi_Wares.Wrn_St%TYPE DEFAULT NULL,
        p_History_Status   IN     Ndi_Cbi_Wares.History_Status%TYPE DEFAULT NULL,
        p_Wrn_Count        IN     Ndi_Cbi_Wares.Wrn_Count%TYPE DEFAULT NULL,
        p_Wrn_Candelete    IN     Ndi_Cbi_Wares.Wrn_Candelete%TYPE DEFAULT NULL,
        p_New_Id              OUT Ndi_Cbi_Wares.Wrn_Id%TYPE);
END Api$dic_Common;
/


GRANT EXECUTE ON USS_NDI.API$DIC_COMMON TO IKIS_RBM
/

GRANT EXECUTE ON USS_NDI.API$DIC_COMMON TO USS_ESR
/

GRANT EXECUTE ON USS_NDI.API$DIC_COMMON TO USS_PERSON
/

GRANT EXECUTE ON USS_NDI.API$DIC_COMMON TO USS_RNSP
/

GRANT EXECUTE ON USS_NDI.API$DIC_COMMON TO USS_RPT
/

GRANT EXECUTE ON USS_NDI.API$DIC_COMMON TO USS_VISIT
/


/* Formatted on 8/12/2025 5:55:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.API$DIC_COMMON
IS
    FUNCTION Parse (p_Type_Name      IN VARCHAR2,
                    p_Clob_Input     IN BOOLEAN DEFAULT TRUE,
                    p_Has_Root_Tag   IN BOOLEAN DEFAULT TRUE)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN Type2xmltable (Package_Name, p_Type_Name, TRUE /*, p_Clob_Input, p_Has_Root_Tag*/
                                                             );
    END;


    FUNCTION Parse_Services (p_Xml IN CLOB)
        RETURN t_ndi_nst_dn_config
    IS
        l_Result   t_ndi_nst_dn_config;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN NEW t_ndi_nst_dn_config ();
        END IF;

        EXECUTE IMMEDIATE Parse ('t_ndi_nst_dn_config')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу інформації про послуги в відрахуваннях: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    FUNCTION Parse_Payments (p_Xml IN CLOB)
        RETURN t_ndi_nst_dn_exclude
    IS
        l_Result   t_ndi_nst_dn_exclude;
    BEGIN
        IF p_Xml IS NULL
        THEN
            RETURN NEW t_ndi_nst_dn_exclude ();
        END IF;

        EXECUTE IMMEDIATE Parse ('t_ndi_nst_dn_exclude')
            BULK COLLECT INTO l_Result
            USING p_Xml;

        RETURN l_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            Raise_Application_Error (
                -20000,
                   'Помилка парсингу інформації про типи виплат в відрахуваннях: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;


    --===============================================
    --                NDI_BANK
    --===============================================

    --Загрузка из датасета https://bank.gov.ua/NBU_BankInfo/get_rcukru
    PROCEDURE Load_Ndi_Banks (p_Banks CLOB)
    IS
        l_Banks   Uss_Ndi.Api$dic_Common.t_Rcukru;
    BEGIN
        --Пока реализован вариант с полной перезаливкой
        --Заливка дельты будет реализована, если будут ясны условия сравнения записей
        DELETE FROM Ndi_Bank;

        EXECUTE IMMEDIATE Type2xmltable (Package_Name, 'T_RCUKRU')
            BULK COLLECT INTO l_Banks
            USING p_Banks;

        FOR Rec IN (SELECT *
                      FROM TABLE (l_Banks)
                     WHERE GLB <> '0')
        LOOP
            DECLARE
                l_Nb_Id      NUMBER;
                l_Nd_Chlid   NUMBER;
            BEGIN
                --Сохраняем родительский банк
                Save_Ndi_Bank (p_Nb_Id              => NULL,
                               p_Nb_Nb              => NULL,
                               p_Nb_Mfo             => Rec.Glmfo,
                               p_Nb_Name            => Rec.Nb,
                               p_Nb_Name_En         => NULL,
                               p_Nb_Sname           => Rec.Nb,
                               p_Nb_Ur_Address      => NULL,
                               p_Nb_Ur_Address_En   => NULL,
                               p_Nb_Edrpou          => Rec.Ikod,
                               p_Nb_Is_Authorized   => 'F',
                               p_History_Status     => 'A',
                               p_NB_NUM             => NULL,
                               p_Nb_Is_Treasury     => 'F',
                               p_New_Id             => l_Nb_Id);

                --Сохраняем дочерние банки
                FOR Child IN (SELECT *
                                FROM TABLE (l_Banks)
                               WHERE Glmfo = Rec.Glmfo AND GLB = '0')
                LOOP
                    Save_Ndi_Bank (p_Nb_Id              => NULL,
                                   p_Nb_Nb              => l_Nb_Id,
                                   p_Nb_Mfo             => Child.Glmfo,
                                   p_Nb_Name            => Child.Nb,
                                   p_Nb_Name_En         => NULL,
                                   p_Nb_Sname           => Child.Nb,
                                   p_Nb_Ur_Address      => NULL,
                                   p_Nb_Ur_Address_En   => NULL,
                                   p_Nb_Edrpou          => Child.Ikod,
                                   p_Nb_Is_Authorized   => 'F',
                                   p_History_Status     => 'A',
                                   p_NB_NUM             => NULL,
                                   p_Nb_Is_Treasury     => 'F',
                                   p_New_Id             => l_Nd_Chlid);
                END LOOP;
            END;
        END LOOP;
    END;

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
        p_History_Status     IN     Ndi_Bank.History_Status%TYPE,
        p_NB_NUM             IN     NDI_BANK.NB_NUM%TYPE,
        p_Nb_Is_Treasury     IN     Ndi_Bank.Nb_Is_Treasury%TYPE,
        p_New_Id                OUT Ndi_Bank.Nb_Id%TYPE)
    IS
        l_hs_id    NDI_BANK.nb_hs_upd%TYPE := Tools.GetHistSession;   --#91429
        l_Cur_St   Ndi_Bank.History_Status%TYPE;
    BEGIN
        IF p_Nb_Id IS NULL
        THEN
            INSERT INTO Ndi_Bank (Nb_Nb,
                                  Nb_Mfo,
                                  Nb_Name,
                                  Nb_Name_En,
                                  Nb_Sname,
                                  Nb_Ur_Address,
                                  Nb_Ur_Address_En,
                                  Nb_Edrpou,
                                  Nb_Is_Authorized,
                                  History_Status,
                                  NB_NUM,
                                  nb_hs_upd,
                                  Nb_Is_Treasury)
                 VALUES (p_Nb_Nb,
                         p_Nb_Mfo,
                         p_Nb_Name,
                         p_Nb_Name_En,
                         p_Nb_Sname,
                         p_Nb_Ur_Address,
                         p_Nb_Ur_Address_En,
                         p_Nb_Edrpou,
                         p_Nb_Is_Authorized,
                         p_History_Status,
                         p_NB_NUM,
                         l_hs_id,                                     --#91429
                         p_Nb_Is_Treasury)
              RETURNING Nb_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Nb_Id;

            SELECT Ndi_Bank.History_Status
              INTO l_Cur_St
              FROM Ndi_Bank
             WHERE Nb_Id = p_Nb_Id;

            IF l_Cur_St = c_History_Status_Historical
            THEN
                Raise_Application_Error (
                    -20000,
                    'Неможливо змінити запис, який перебуває в стані логічного видалення!');
            END IF;

            UPDATE Ndi_Bank
               SET Nb_Nb = p_Nb_Nb,
                   Nb_Mfo = p_Nb_Mfo,
                   Nb_Name = p_Nb_Name,
                   Nb_Name_En = p_Nb_Name_En,
                   Nb_Sname = p_Nb_Sname,
                   Nb_Ur_Address = p_Nb_Ur_Address,
                   Nb_Ur_Address_En = p_Nb_Ur_Address_En,
                   Nb_Edrpou = p_Nb_Edrpou,
                   Nb_Is_Authorized = p_Nb_Is_Authorized,
                   NB_NUM = p_NB_NUM,
                   nb_hs_upd = l_hs_id,                               --#91429
                   Nb_Is_Treasury = p_Nb_Is_Treasury
             WHERE Nb_Id = p_Nb_Id;
        END IF;
    END;

    PROCEDURE set_nb_contract (p_nbc_start_dt   IN DATE,
                               p_nbc_stop_dt    IN DATE,
                               p_nbc_num        IN VARCHAR2,
                               p_nbc_dt         IN DATE,
                               p_nbc_nb         IN NUMBER)
    IS
        l_hs    NUMBER := tools.GetHistSession;
        l_org   NUMBER := tools.getcurrorg;
    BEGIN
        INSERT INTO tmp_unh_old_list (ol_obj,
                                      ol_hst,
                                      ol_begin,
                                      ol_end)
            SELECT 0,
                   t.nbc_id,
                   t.nbc_start_dt,
                   t.nbc_stop_dt
              FROM v_ndi_nb_contract t
             WHERE t.history_status = 'A' --AND t.nbc_nb = p_nbc_nb
                                          AND t.com_org = l_org;

        -- формування історії
        api$hist.setup_history (0, p_nbc_start_dt, p_nbc_stop_dt);

        -- закриття недіючих
        UPDATE v_ndi_nb_contract t
           SET t.nbc_hs_del = l_hs, t.history_status = 'H'
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_unh_to_prp
                     WHERE tprp_hst = t.nbc_id);

        -- додавання нових періодів
        INSERT INTO v_ndi_nb_contract (nbc_id,
                                       nbc_start_dt,
                                       nbc_stop_dt,
                                       nbc_num,
                                       nbc_dt,
                                       nbc_nb,
                                       history_status,
                                       nbc_hs_upd,
                                       com_org)
            SELECT 0,
                   rz.rz_begin,
                   rz.rz_end,
                   t.nbc_num,
                   t.nbc_dt,
                   t.nbc_nb,
                   'A',
                   l_hs,
                   l_org
              FROM tmp_unh_rz_list rz, v_ndi_nb_contract t
             WHERE     rz_hst <> 0
                   AND (rz_begin <= rz_end OR rz_end IS NULL)
                   AND t.nbc_id = rz_hst
            UNION
            SELECT 0,
                   p_nbc_start_dt,
                   p_nbc_stop_dt,
                   p_nbc_num,
                   p_nbc_dt,
                   p_nbc_nb,
                   'A',
                   l_hs,
                   l_org
              FROM tmp_unh_rz_list vh_lgwh
             WHERE rz_hst = 0 AND (rz_begin <= rz_end OR rz_end IS NULL);

        UPDATE v_ndi_nb_contract t
           SET t.nbc_is_actual = 'F'
         WHERE t.com_org = l_org--AND t.nbc_nb = p_nbc_nb
                                ;

        UPDATE v_ndi_nb_contract t
           SET t.nbc_is_actual = 'T'
         WHERE t.nbc_id =
               (SELECT FIRST_VALUE (z.nbc_id)
                           OVER (ORDER BY z.nbc_start_dt DESC)
                  FROM v_ndi_nb_contract z
                 WHERE     z.com_org = l_org
                       AND z.nbc_nb = p_nbc_nb
                       AND z.history_status = 'A'
                 FETCH FIRST ROW ONLY);
    END;

    PROCEDURE Set_Ndi_Bank_Hist_St (
        p_Nb_Id            IN Ndi_Bank.Nb_Id%TYPE,
        p_History_Status   IN Ndi_Bank.History_Status%TYPE)
    IS
        l_Cur_St   Ndi_Bank.History_Status%TYPE;                      --#91429
    BEGIN
        SELECT Ndi_Bank.History_Status
          INTO l_Cur_St
          FROM Ndi_Bank
         WHERE Nb_Id = p_Nb_Id;

        IF l_Cur_St = c_History_Status_Historical
        THEN
            Raise_Application_Error (
                -20000,
                'Неможливо змінити запис, який перебуває в стані логічного видалення!');
        END IF;

        IF p_History_Status = c_History_Status_Historical
        THEN
            UPDATE Ndi_Bank
               SET History_Status = p_History_Status,
                   nb_hs_del = Tools.GetHistSession
             WHERE Nb_Id = p_Nb_Id;
        ELSE
            UPDATE Ndi_Bank
               SET History_Status = p_History_Status,
                   nb_hs_upd = Tools.GetHistSession
             WHERE Nb_Id = p_Nb_Id;
        END IF;
    END;

    --===============================================
    --                NDI_COUNTRY
    --===============================================
    PROCEDURE Save_Ndi_Country (
        p_Nc_Id            IN     Ndi_Country.Nc_Id%TYPE,
        p_Nc_Code          IN     Ndi_Country.Nc_Code%TYPE,
        p_Nc_Name          IN     Ndi_Country.Nc_Name%TYPE,
        p_Nc_Sname         IN     Ndi_Country.Nc_Sname%TYPE,
        p_History_Status   IN     Ndi_Country.History_Status%TYPE,
        p_New_Id              OUT Ndi_Country.Nc_Id%TYPE)
    IS
    BEGIN
        IF p_Nc_Id IS NULL
        THEN
            INSERT INTO Ndi_Country (Nc_Code,
                                     Nc_Name,
                                     Nc_Sname,
                                     History_Status)
                 VALUES (p_Nc_Code,
                         p_Nc_Name,
                         p_Nc_Sname,
                         p_History_Status)
              RETURNING Nc_Id
                   INTO p_New_Id;
        ELSE
            p_New_Id := p_Nc_Id;

            UPDATE Ndi_Country
               SET Nc_Code = p_Nc_Code,
                   Nc_Name = p_Nc_Name,
                   Nc_Sname = p_Nc_Sname
             WHERE Nc_Id = p_Nc_Id;
        END IF;
    END;

    PROCEDURE Set_Ndi_Country_Hist_St (
        p_Nc_Id            IN Ndi_Country.Nc_Id%TYPE,
        p_History_Status   IN Ndi_Country.History_Status%TYPE)
    IS
    BEGIN
        UPDATE Ndi_Country
           SET History_Status = p_History_Status
         WHERE Nc_Id = p_Nc_Id;
    END;

    ---------------------------------------------------------------
    ------------------------REJECT REASON--------------------------
    ---------------------------------------------------------------
    PROCEDURE Save_Reject_Reason (
        p_NJR_ID      IN     NDI_REJECT_REASON.NJR_ID%TYPE,
        p_NJR_CODE    IN     NDI_REJECT_REASON.NJR_CODE%TYPE,
        p_NJR_NAME    IN     NDI_REJECT_REASON.NJR_NAME%TYPE,
        p_NJR_ORDER   IN     NDI_REJECT_REASON.NJR_ORDER%TYPE,
        p_NJR_NST     IN     NDI_REJECT_REASON.NJR_NST%TYPE,
        p_new_id         OUT NDI_REJECT_REASON.NJR_ID%TYPE)
    IS
        l_rec_src   ndi_service_type.record_src%TYPE;
        l_hs        NUMBER := tools.GetHistSession;
    BEGIN
        IF p_NJR_ID IS NULL
        THEN
            INSERT INTO NDI_REJECT_REASON (NJR_CODE,
                                           NJR_NAME,
                                           NJR_ORDER,
                                           NJR_NST,
                                           HISTORY_STATUS,
                                           njr_hs_ins,
                                           record_src)
                 VALUES (p_NJR_CODE,
                         p_NJR_NAME,
                         p_NJR_ORDER,
                         p_NJR_NST,
                         'A',
                         l_hs,
                         TOOLS.get_record_src)
              RETURNING NJR_ID
                   INTO p_new_id;

            API$CHANGE_LOG.write_change_log (
                p_ncl_object      => 'NDI_REJECT_REASON',
                p_ncl_action      => 'C',
                p_ncl_hs          => l_hs,
                p_ncl_record_id   => p_New_Id);
        ELSE
            p_new_id := p_NJR_ID;

            SELECT t.record_src
              INTO l_rec_src
              FROM NDI_REJECT_REASON t
             WHERE t.njr_id = p_new_id;

            TOOLS.check_record_src (l_rec_src);

            UPDATE NDI_REJECT_REASON
               SET NJR_CODE = p_NJR_CODE,
                   NJR_NAME = p_NJR_NAME,
                   NJR_ORDER = p_NJR_ORDER,
                   NJR_NST = p_NJR_NST
             WHERE NJR_ID = p_NJR_ID;

            API$CHANGE_LOG.write_change_log (
                p_ncl_object      => 'NDI_REJECT_REASON',
                p_ncl_action      => 'U',
                p_ncl_hs          => l_hs,
                p_ncl_record_id   => p_New_Id);
        END IF;
    END;

    PROCEDURE Delete_Reject_Reason (p_NJR_ID NDI_REJECT_REASON.NJR_ID%TYPE)
    IS
        l_hs   NUMBER := tools.GetHistSession;
    BEGIN
        API$CHANGE_LOG.write_change_log (
            p_ncl_object       => 'NDI_REJECT_REASON',
            p_ncl_action       => 'D',
            p_ncl_hs           => l_hs,
            p_ncl_record_id    => p_NJR_ID,
            p_ncl_decription   => '&322');

        UPDATE NDI_REJECT_REASON t
           SET History_Status = 'H', t.NJR_HS_DEL = l_hs
         WHERE t.njr_id = p_NJR_ID;
    END;

    /*procedure Delete_Reject_Reason (p_NJR_ID NDI_REJECT_REASON.NJR_ID%type) is
    BEGIN
        update NDI_REJECT_REASON RR
        set RR.NJR_HS_DEL = tools.GetHistSession, RR.History_Status='H'
        where p_NJR_ID = RR.NJR_ID;
    end;*/
    ---------------------------------------------------------------
    ------------------------distrib purpose------------------------
    ---------------------------------------------------------------

    -- Отримати запис по ідентифікатору
    PROCEDURE get_distrib_purpose_gr (
        p_id    IN     ndi_distrib_purpose_gr.dpg_id%TYPE,
        p_res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR SELECT dpg_id,
                              dpg_name,
                              dpg_is_gov,
                              dpg_is_own,
                              dpg_template,
                              dpg_tp,
                              dpg_hs_del,
                              dpg_hs_upd,
                              history_status
                         FROM ndi_distrib_purpose_gr
                        WHERE dpg_id = p_id;
    END;

    -- Зберегти
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
        IF p_dpg_id IS NULL
        THEN
            INSERT INTO ndi_distrib_purpose_gr (dpg_name,
                                                dpg_is_gov,
                                                dpg_is_own,
                                                dpg_template,
                                                dpg_tp,
                                                dpg_hs_del,
                                                dpg_hs_upd,
                                                history_status)
                 VALUES (p_dpg_name,
                         p_dpg_is_gov,
                         p_dpg_is_own,
                         p_dpg_template,
                         p_dpg_tp,
                         p_dpg_hs_del,
                         p_dpg_hs_upd,
                         p_history_status)
              RETURNING dpg_id
                   INTO p_new_id;
        ELSE
            p_new_id := p_dpg_id;

            UPDATE ndi_distrib_purpose_gr
               SET dpg_name = p_dpg_name,
                   dpg_is_gov = p_dpg_is_gov,
                   dpg_is_own = p_dpg_is_own,
                   dpg_template = p_dpg_template,
                   dpg_tp = p_dpg_tp,
                   dpg_hs_del = p_dpg_hs_del,
                   dpg_hs_upd = p_dpg_hs_upd,
                   history_status = p_history_status
             WHERE dpg_id = p_dpg_id;
        END IF;
    END;

    -- Вилучити
    PROCEDURE delete_distrib_purpose_gr (
        p_id   ndi_distrib_purpose_gr.dpg_id%TYPE)
    IS
    BEGIN
        UPDATE ndi_distrib_purpose_gr
           SET dpg_hs_del = tools.GetHistSession, history_status = 'H'
         WHERE dpg_id = p_id;
    END;

    -- Список за фільтром
    PROCEDURE query_distrib_purpose_gr (p_dpg_name   IN     VARCHAR2,
                                        p_res           OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT dpg.dpg_id,
                   dpg.dpg_name,
                   b.dic_name       AS bool_dpg_is_gov,      --DPG.DPG_IS_GOV,
                   b2.dic_name      AS bool_dpg_is_own,      --DPG.DPG_IS_OWN,
                   dpg.dpg_template,
                   dtp.dic_name     AS dtp_dpg_tp,               --DPG.DPG_TP,
                   dpg.dpg_hs_del,
                   dpg.dpg_hs_upd,
                   dpg.history_status
              FROM ndi_distrib_purpose_gr  dpg
                   LEFT JOIN v_ddn_dpg_tp dtp ON dpg.dpg_tp = dtp.dic_value
                   LEFT JOIN v_ddn_boolean b ON dpg.dpg_is_gov = b.dic_value
                   LEFT JOIN v_ddn_boolean b2
                       ON dpg.dpg_is_own = b2.dic_value
             WHERE     dpg.history_status = 'A'
                   AND (dpg.dpg_name LIKE '%' || p_dpg_name || '%');
    END;

    ---------------------------------------------------------------
    ----------------------------deduction--------------------------
    ---------------------------------------------------------------

    PROCEDURE Save_Nst_Dn_Config (
        p_NDN_ID   IN     NDI_DEDUCTION.NDN_ID%TYPE,
        p_hs       IN     NUMBER,
        p_config   IN OUT t_ndi_nst_dn_config)
    IS
    BEGIN
        FOR xx
            IN (SELECT t.*, c.history_status AS old_status, ROWNUM AS rn
                  FROM TABLE (p_config)  t
                       LEFT JOIN ndi_nst_dn_config c
                           ON (c.nnnc_id = t.nnnc_id))
        LOOP
            IF (    xx.history_status = 'H'
                AND xx.nnnc_id > 0
                AND xx.old_status = 'A')
            THEN
                UPDATE ndi_nst_dn_config t
                   SET t.history_status = 'H', t.nnnc_hs_del = p_hs
                 WHERE t.nnnc_id = xx.nnnc_id;

                API$CHANGE_LOG.write_change_log (
                    p_ncl_object       => 'NDI_NST_DN_CONFIG',
                    p_ncl_action       => 'D',
                    p_ncl_hs           => p_hs,
                    p_ncl_record_id    => xx.nnnc_id,
                    p_ncl_decription   => '&322');
            ELSIF (xx.nnnc_id < 0)
            THEN
                INSERT INTO ndi_nst_dn_config (nnnc_nst,
                                               nnnc_ndn,
                                               history_status,
                                               nnnc_hs_ins)
                     VALUES (xx.nnnc_nst,
                             p_ndn_id,
                             'A',
                             p_hs)
                  RETURNING nnnc_id
                       INTO p_config (xx.rn).New_id;

                --raise_application_error(-20000, 'xx.nnnc_id='||xx.nnnc_id||';'||p_config(xx.rn).nnnc_id||';'||p_config(xx.rn).new_id);
                API$CHANGE_LOG.write_change_log (
                    p_ncl_object      => 'NDI_NST_DN_CONFIG',
                    p_ncl_action      => 'C',
                    p_ncl_hs          => p_hs,
                    p_ncl_record_id   => p_config (xx.rn).New_id);
            END IF;
        END LOOP;
    END;

    PROCEDURE Save_Nst_Dn_Exclude (p_hs           IN     NUMBER,
                                   p_config       IN OUT t_ndi_nst_dn_exclude,
                                   p_nst_config   IN     t_ndi_nst_dn_config)
    IS
    BEGIN
        FOR xx
            IN (SELECT t.*,
                       c.history_status                              AS old_status,
                       GREATEST (nc.nnnc_id, NVL (nc.new_id, -1))    AS nnnc_id
                  FROM TABLE (p_config)  t
                       LEFT JOIN TABLE (p_nst_config) nc
                           ON (nc.nnnc_id = t.nnde_nnnc)
                       LEFT JOIN ndi_nst_dn_exclude c
                           ON (c.nnde_id = t.nnde_id))
        LOOP
            IF (    xx.history_status = 'H'
                AND xx.nnde_id > 0
                AND xx.old_status = 'A')
            THEN
                UPDATE ndi_nst_dn_exclude t
                   SET t.history_status = 'H', t.nnde_hs_del = p_hs
                 WHERE t.nnde_id = xx.nnde_id;

                API$CHANGE_LOG.write_change_log (
                    p_ncl_object       => 'NDI_NST_DN_EXCLUDE',
                    p_ncl_action       => 'D',
                    p_ncl_hs           => p_hs,
                    p_ncl_record_id    => xx.nnde_id,
                    p_ncl_decription   => '&322');
            ELSIF (xx.nnde_id < 0)
            THEN
                INSERT INTO ndi_nst_dn_exclude (nnde_nnnc,
                                                nnde_npt,
                                                history_status,
                                                nnde_hs_ins)
                     VALUES (xx.nnnc_id,
                             xx.nnde_npt,
                             'A',
                             p_hs)
                  RETURNING nnde_id
                       INTO xx.New_id;

                API$CHANGE_LOG.write_change_log (
                    p_ncl_object      => 'NDI_NST_DN_EXCLUDE',
                    p_ncl_action      => 'C',
                    p_ncl_hs          => p_hs,
                    p_ncl_record_id   => xx.New_id);
            END IF;
        END LOOP;
    END;

    PROCEDURE Save_Deduction (
        p_NDN_ID            IN     NDI_DEDUCTION.NDN_ID%TYPE,
        p_NDN_CODE          IN     NDI_DEDUCTION.NDN_CODE%TYPE,
        p_NDN_NAME          IN     NDI_DEDUCTION.NDN_NAME%TYPE,
        p_NDN_MAX_PRC       IN     NDI_DEDUCTION.NDN_MAX_PRC%TYPE,
        p_NDN_TP            IN     NDI_DEDUCTION.NDN_TP%TYPE,
        p_NDN_START_DT      IN     NDI_DEDUCTION.NDN_START_DT%TYPE,
        p_NDN_STOP_DT       IN     NDI_DEDUCTION.NDN_STOP_DT%TYPE,
        p_NDN_POST_FEE_TP   IN     NDI_DEDUCTION.NDN_POST_FEE_TP%TYPE,
        p_NDN_SRC_SUM_TP    IN     NDI_DEDUCTION.NDN_SRC_SUM_TP%TYPE,
        p_NDN_OP            IN     NDI_DEDUCTION.NDN_OP%TYPE,
        p_NDN_ORDER         IN     NDI_DEDUCTION.NDN_ORDER%TYPE,
        p_NDN_CALC_STEP     IN     NDI_DEDUCTION.NDN_CALC_STEP%TYPE,
        p_NDN_DN_TP         IN     NDI_DEDUCTION.NDN_DN_TP%TYPE,
        p_nst_config        IN     CLOB,
        p_npt_config        IN     CLOB,
        p_new_id               OUT NDI_DEDUCTION.NDN_ID%TYPE)
    IS
        l_hs         NUMBER := tools.GetHistSession;
        l_services   t_ndi_nst_dn_config;
        l_payments   t_ndi_nst_dn_exclude;
    BEGIN
        IF p_NDN_ID IS NULL
        THEN
            INSERT INTO NDI_DEDUCTION (NDN_CODE,
                                       NDN_NAME,
                                       NDN_MAX_PRC,
                                       NDN_TP,
                                       NDN_START_DT,
                                       NDN_STOP_DT,
                                       NDN_POST_FEE_TP,
                                       NDN_SRC_SUM_TP,
                                       NDN_OP,
                                       HISTORY_STATUS,
                                       NDN_ORDER,
                                       NDN_HS_UPD,
                                       NDN_CALC_STEP,
                                       NDN_DN_TP)
                 VALUES (p_NDN_CODE,
                         p_NDN_NAME,
                         p_NDN_MAX_PRC,
                         p_NDN_TP,
                         p_NDN_START_DT,
                         p_NDN_STOP_DT,
                         p_NDN_POST_FEE_TP,
                         p_NDN_SRC_SUM_TP,
                         p_NDN_OP,
                         'A',
                         p_NDN_ORDER,
                         l_hs,
                         p_NDN_CALC_STEP,
                         p_NDN_DN_TP)
              RETURNING NDN_ID
                   INTO p_new_id;

            API$CHANGE_LOG.write_change_log (
                p_ncl_object      => 'NDI_DEDUCTION',
                p_ncl_action      => 'C',
                p_ncl_hs          => l_hs,
                p_ncl_record_id   => P_NEW_ID);
        ELSE
            p_new_id := p_NDN_ID;

            UPDATE NDI_DEDUCTION D
               SET D.NDN_CODE = p_NDN_CODE,
                   D.NDN_NAME = p_NDN_NAME,
                   D.NDN_MAX_PRC = p_NDN_MAX_PRC,
                   D.NDN_TP = p_NDN_TP,
                   D.NDN_START_DT = p_NDN_START_DT,
                   D.NDN_STOP_DT = p_NDN_STOP_DT,
                   D.NDN_POST_FEE_TP = p_NDN_POST_FEE_TP,
                   D.ndn_src_sum_tp = NVL (p_NDN_SRC_SUM_TP, ndn_src_sum_tp),
                   D.NDN_OP = p_NDN_OP,
                   D.NDN_ORDER = p_NDN_ORDER,
                   D.NDN_HS_UPD = l_hs,
                   d.NDN_CALC_STEP = p_NDN_CALC_STEP,
                   d.NDN_DN_TP = p_NDN_DN_TP
             WHERE NDN_ID = p_NDN_ID;

            l_services := Parse_Services (p_nst_config);
            l_payments := Parse_Payments (p_npt_config);

            Save_Nst_Dn_Config (p_new_id, l_hs, l_services);
            Save_Nst_Dn_Exclude (l_hs, l_payments, l_services);

            API$CHANGE_LOG.write_change_log (
                p_ncl_object      => 'NDI_DEDUCTION',
                p_ncl_action      => 'U',
                p_ncl_hs          => l_hs,
                p_ncl_record_id   => p_New_Id);
        END IF;
    END;

    PROCEDURE Delete_Deduction (p_NDN_ID NDI_DEDUCTION.NDN_ID%TYPE)
    IS
        l_hs   NUMBER := tools.GetHistSession;
    BEGIN
        UPDATE NDI_DEDUCTION D
           SET D.NDN_HS_DEL = l_hs,
               D.History_Status = API$DIC_VISIT.c_History_Status_Historical
         WHERE d.ndn_id = p_NDN_ID;

        API$CHANGE_LOG.write_change_log (p_ncl_object       => 'NDI_DEDUCTION',
                                         p_ncl_action       => 'D',
                                         p_ncl_hs           => l_hs,
                                         p_ncl_record_id    => p_NDN_ID,
                                         p_ncl_decription   => '&322');
    END;

    ---------------------------------------------------------------
    ----------------------------NDI_ACC_SETUP ---------------------
    ---------------------------------------------------------------
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
        IF p_acs_id IS NULL
        THEN
            INSERT INTO ndi_acc_setup (com_org,
                                       acs_vat_tp,
                                       acs_fnc_signer,
                                       acs_dpp_dksu,
                                       acs_net_level,
                                       acs_adm_code,
                                       acs_adm_level,
                                       acs_province_code,
                                       acs_dksu_main_code,
                                       acs_dksu_code,
                                       acs_dksu_reg_dt,
                                       acs_dppa_adm,
                                       acs_doer_code,
                                       acs_kvk_code,
                                       acs_doc_close_dt,
                                       acs_fnc_bt_check,
                                       acs_fnc_bt_allow,
                                       acs_hs_upd,
                                       acs_kvk_name)
                 VALUES (tools.getcurrorg,
                         p_acs_vat_tp,
                         p_acs_fnc_signer,
                         p_acs_dpp_dksu,
                         p_acs_net_level,
                         p_acs_adm_code,
                         p_acs_adm_level,
                         p_acs_province_code,
                         p_acs_dksu_main_code,
                         p_acs_dksu_code,
                         p_acs_dksu_reg_dt,
                         p_acs_dppa_adm,
                         p_acs_doer_code,
                         p_acs_kvk_code,
                         p_acs_doc_close_dt,
                         p_acs_fnc_bt_check,
                         p_acs_fnc_bt_allow,
                         tools.gethistsession,
                         p_acs_kvk_name)
              RETURNING acs_id
                   INTO p_new_id;
        ELSE
            p_new_id := p_acs_id;

            UPDATE ndi_acc_setup
               SET acs_vat_tp = p_acs_vat_tp,
                   acs_fnc_signer = p_acs_fnc_signer,
                   acs_dpp_dksu = p_acs_dpp_dksu,
                   acs_net_level = p_acs_net_level,
                   acs_adm_code = p_acs_adm_code,
                   acs_adm_level = p_acs_adm_level,
                   acs_province_code = p_acs_province_code,
                   acs_dksu_main_code = p_acs_dksu_main_code,
                   acs_dksu_code = p_acs_dksu_code,
                   acs_dksu_reg_dt = p_acs_dksu_reg_dt,
                   acs_dppa_adm = p_acs_dppa_adm,
                   acs_doer_code = p_acs_doer_code,
                   acs_kvk_code = p_acs_kvk_code,
                   acs_doc_close_dt = p_acs_doc_close_dt,
                   acs_fnc_bt_check = p_acs_fnc_bt_check,
                   acs_fnc_bt_allow = p_acs_fnc_bt_allow,
                   acs_hs_upd = tools.gethistsession,
                   acs_kvk_name = p_acs_kvk_name
             WHERE acs_id = p_acs_id;
        END IF;
    END;

    -----------------------------------------------------------------
    ----------------------------V_OPFU--------- ---------------------
    ---------------------------------------------------------------

    PROCEDURE query_opfu (p_org_id_reg   IN     NUMBER,
                          p_org_id_soc   IN     NUMBER,
                          p_org_id_ter   IN     NUMBER,
                          p_res             OUT SYS_REFCURSOR)
    IS
    BEGIN
        CASE
            WHEN p_org_id_reg IS NOT NULL
            THEN
                OPEN p_res FOR SELECT o.org_id        AS org_id_reg,
                                      o.org_name      AS org_name_reg,
                                      sc.org_id       AS org_id_soc,
                                      sc.org_name     AS org_name_soc
                                 FROM v_opfu  o
                                      RIGHT JOIN
                                      (SELECT s.org_id, s.org_name, s.org_org
                                         FROM v_opfu s
                                        WHERE     (   s.org_to = 34
                                                   OR s.org_to = 32)
                                              AND (   p_org_id_soc IS NULL
                                                   OR s.org_id = p_org_id_soc)
                                              AND s.org_st = 'A') sc
                                          ON o.org_id = sc.org_org;
            WHEN    p_org_id_reg IS NOT NULL
                 OR p_org_id_soc IS NOT NULL
                 OR p_org_id_ter IS NOT NULL
            THEN
                OPEN p_res FOR
                    SELECT o.org_id        AS org_id_reg,
                           o.org_name      AS org_name_reg,
                           sc.org_id       AS org_id_soc,
                           sc.org_name     AS org_name_soc,
                           tr.org_id       AS org_id_ter,
                           tr.org_name     AS org_name_ter
                      FROM v_opfu  o
                           RIGHT JOIN
                           (SELECT s.org_id, s.org_name, s.org_org
                              FROM v_opfu s
                             WHERE     (   s.org_to = 34
                                        OR s.org_to = 32)
                                   AND (   p_org_id_soc IS NULL
                                        OR s.org_id = p_org_id_soc)
                                   AND s.org_st = 'A') sc
                               ON o.org_id = sc.org_org
                           RIGHT JOIN
                           (SELECT t.org_id, t.org_name, t.org_org
                              FROM v_opfu t
                             WHERE     org_to = 33
                                   AND (   (p_org_id_ter IS NULL)
                                        OR t.org_id = p_org_id_ter)
                                   AND t.org_st = 'A') tr
                               ON p_org_id_soc = tr.org_org
                     WHERE     (   p_org_id_reg IS NULL
                                OR p_org_id_reg = o.org_id)
                           AND o.org_st = 'A';
            ELSE
                OPEN p_res FOR
                    SELECT o.org_id AS org_id_reg, o.org_name AS org_name_reg
                      FROM v_opfu o
                     WHERE     (o.org_to = 31)
                           AND (   p_org_id_reg IS NULL
                                OR p_org_id_reg = o.org_id);
        END CASE;
    END;



    --Перестворення DDN-представлень
    PROCEDURE recreate_dd_views
    IS
    BEGIN
        ikis_sys.ikis_dd.create_dd_view;
    END;


    -- #81615: 'Базовий календар, оновленння
    PROCEDURE UPDATE_NDI_CALENDAR (p_ncb_id            IN NUMBER,
                                   p_NCB_WORK_TP       IN VARCHAR2,
                                   p_NCB_DESCRIPTION   IN VARCHAR2)
    IS
        l_hs   NUMBER := tools.GetHistSession;
    BEGIN
        UPDATE ndi_calendar_base t
           SET t.ncb_work_tp = p_ncb_work_tp,
               t.ncb_description = p_ncb_description,
               t.ncb_hs_upd = l_hs
         WHERE t.ncb_id = p_ncb_id;
    END;

    FUNCTION Get_Katottg_Name (p_Kaot_Id IN NUMBER)
        RETURN Ndi_Katottg.Kaot_Name%TYPE
    IS
        l_Result   Ndi_Katottg.Kaot_Name%TYPE;
    BEGIN
        SELECT MAX (
                   RTRIM (
                          CASE
                              WHEN L1_Name IS NOT NULL AND L1_Name != L2_Name
                              THEN
                                  L1_Name || ', '
                          END
                       || CASE
                              WHEN L2_Name IS NOT NULL AND L2_Name != L3_Name
                              THEN
                                  L2_Name || ', '
                          END
                       || CASE
                              WHEN L3_Name IS NOT NULL AND L3_Name != L4_Name
                              THEN
                                  L3_Name || ', '
                          END
                       || CASE
                              WHEN L4_Name IS NOT NULL AND L4_Name != L5_Name
                              THEN
                                  L4_Name || ', '
                          END
                       || CASE
                              WHEN     L5_Name IS NOT NULL
                                   AND L5_Name != Kaot_Name
                              THEN
                                  L5_Name || ', '
                          END
                       || Name_Temp,
                       ','))
          INTO l_Result
          FROM (SELECT Kaot_Id,
                       CASE
                           WHEN Kaot_Kaot_L1 = Kaot_Id
                           THEN
                               Kaot_Name
                           ELSE
                               (SELECT Dic_Sname || ' ' || X1.Kaot_Name
                                  FROM v_Ndi_Katottg X1, v_Ddn_Kaot_Tp
                                 WHERE     X1.Kaot_Id = m.Kaot_Kaot_L1
                                       AND Kaot_Tp = Dic_Value)
                       END                                AS L1_Name,
                       CASE
                           WHEN Kaot_Kaot_L2 = Kaot_Id
                           THEN
                               Kaot_Name
                           ELSE
                               (SELECT Dic_Sname || ' ' || X1.Kaot_Name
                                  FROM v_Ndi_Katottg X1, v_Ddn_Kaot_Tp
                                 WHERE     X1.Kaot_Id = m.Kaot_Kaot_L2
                                       AND Kaot_Tp = Dic_Value)
                       END                                AS L2_Name,
                       CASE
                           WHEN Kaot_Kaot_L3 = Kaot_Id
                           THEN
                               Kaot_Name
                           ELSE
                               (SELECT Dic_Sname || ' ' || X1.Kaot_Name
                                  FROM v_Ndi_Katottg X1, v_Ddn_Kaot_Tp
                                 WHERE     X1.Kaot_Id = m.Kaot_Kaot_L3
                                       AND Kaot_Tp = Dic_Value)
                       END                                AS L3_Name,
                       CASE
                           WHEN Kaot_Kaot_L4 = Kaot_Id
                           THEN
                               Kaot_Name
                           ELSE
                               (SELECT Dic_Sname || ' ' || X1.Kaot_Name
                                  FROM v_Ndi_Katottg X1, v_Ddn_Kaot_Tp
                                 WHERE     X1.Kaot_Id = m.Kaot_Kaot_L4
                                       AND Kaot_Tp = Dic_Value)
                       END                                AS L4_Name,
                       CASE
                           WHEN Kaot_Kaot_L5 = Kaot_Id
                           THEN
                               Kaot_Name
                           ELSE
                               (SELECT Dic_Sname || ' ' || X1.Kaot_Name
                                  FROM v_Ndi_Katottg X1, v_Ddn_Kaot_Tp
                                 WHERE     X1.Kaot_Id = m.Kaot_Kaot_L5
                                       AND Kaot_Tp = Dic_Value)
                       END                                AS L5_Name,
                       Kaot_Code,
                       Kaot_Tp,
                       t.Dic_Sname                        AS Kaot_Tp_Name,
                       Kaot_Name,
                       Kaot_Start_Dt,
                       Kaot_Stop_Dt,
                       Kaot_St,
                       Kaot_Koatuu,
                       Kaot_Id                            AS Id,
                       t.Dic_Sname || ' ' || Kaot_Name    AS Name_Temp
                  FROM v_Ndi_Katottg  m
                       JOIN v_Ddn_Kaot_Tp t ON m.Kaot_Tp = t.Dic_Code
                 WHERE Kaot_Id = p_Kaot_Id) t;

        RETURN l_Result;
    END;

    -------------------------------------------------------------------
    --      Отримання назви області по ІД КАТОТТГ
    -------------------------------------------------------------------
    FUNCTION Get_Kaot_Region (p_Kaot_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   Uss_Ndi.v_Ndi_Katottg.Kaot_Name%TYPE;
    BEGIN
        SELECT MAX (Kk.Kaot_Name)
          INTO l_Result
          FROM Uss_Ndi.v_Ndi_Katottg  k
               JOIN Uss_Ndi.v_Ndi_Katottg Kk ON k.Kaot_Kaot_L1 = Kk.Kaot_Id
         WHERE k.Kaot_Id = p_Kaot_Id;

        RETURN l_Result;
    END;

    -------------------------------------------------------------------
    --      Отримання назви району по ІД КАТОТТГ
    -------------------------------------------------------------------
    FUNCTION Get_Kaot_District (p_Kaot_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   Uss_Ndi.v_Ndi_Katottg.Kaot_Name%TYPE;
    BEGIN
        SELECT MAX (Kk.Kaot_Name)
          INTO l_Result
          FROM Uss_Ndi.v_Ndi_Katottg  k
               JOIN Uss_Ndi.v_Ndi_Katottg Kk ON k.Kaot_Kaot_L2 = Kk.Kaot_Id
         WHERE k.Kaot_Id = p_Kaot_Id;

        RETURN l_Result;
    END;

    -------------------------------------------------------------------
    --      Отримання назви населеного пункта по ІД КАТОТТГ
    -------------------------------------------------------------------
    FUNCTION Get_Kaot_City (p_Kaot_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   Uss_Ndi.v_Ndi_Katottg.Kaot_Name%TYPE;
    BEGIN
        SELECT MAX (Kk.Kaot_Name)
          INTO l_Result
          FROM Uss_Ndi.v_Ndi_Katottg  k
               JOIN Uss_Ndi.v_Ndi_Katottg Kk ON k.Kaot_Kaot_L4 = Kk.Kaot_Id
         WHERE k.Kaot_Id = p_Kaot_Id;

        RETURN l_Result;
    END;

    -------------------------------------------------------------------
    --      Отримання типу населеного пункта по ІД КАТОТТГ
    -------------------------------------------------------------------
    FUNCTION Get_Kaot_City_Tp (p_Kaot_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (10);
    BEGIN
        SELECT MAX (t.Dic_Sname)
          INTO l_Result
          FROM Uss_Ndi.v_Ndi_Katottg  k
               JOIN Uss_Ndi.v_Ndi_Katottg Kk ON k.Kaot_Kaot_L4 = Kk.Kaot_Id
               JOIN Uss_Ndi.v_Ddn_Kaot_Tp t ON Kk.Kaot_Tp = t.Dic_Value
         WHERE k.Kaot_Id = p_Kaot_Id;

        RETURN l_Result;
    END;

    --===============================================
    --                NDI_Org2Kaot
    --===============================================

    PROCEDURE Save_Ndi_Org2Kaot (
        p_NOK_ID           IN     NDI_ORG2KAOT.NOK_ID%TYPE,
        p_NOK_ORG          IN     NDI_ORG2KAOT.NOK_ORG%TYPE,
        p_NOK_KAOT         IN     NDI_ORG2KAOT.NOK_KAOT%TYPE,
        p_History_Status   IN     NDI_ORG2KAOT.History_Status%TYPE,
        p_new_id              OUT NDI_ORG2KAOT.NOK_ID%TYPE)
    IS
    BEGIN
        IF p_NOK_ID IS NULL
        THEN
            INSERT INTO NDI_ORG2KAOT (NOK_ORG, NOK_KAOT, HISTORY_STATUS)
                 VALUES (p_NOK_ORG, p_NOK_KAOT, p_HISTORY_STATUS)
              RETURNING NOK_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_NOK_ID;

            UPDATE NDI_ORG2KAOT
               SET NOK_ORG = p_NOK_ORG,
                   NOK_KAOT = p_NOK_KAOT,
                   HISTORY_STATUS = p_HISTORY_STATUS
             WHERE NOK_ID = p_NOK_ID;
        END IF;
    END;

    PROCEDURE Set_Ndi_Org2Kaot_Hist_St (
        p_Nok_Id           IN NDI_ORG2KAOT.Nok_Id%TYPE,
        p_History_Status   IN NDI_ORG2KAOT.History_Status%TYPE)
    IS
    BEGIN
        UPDATE NDI_ORG2KAOT
           SET History_Status = p_History_Status
         WHERE Nok_Id = p_Nok_Id;
    END;

    /*
    -- Збереження ДЗР
    */
    PROCEDURE Save_Ndi_Cbi_Wares (
        p_Wrn_Id           IN     Ndi_Cbi_Wares.Wrn_Id%TYPE,
        p_Wrn_Wt           IN     Ndi_Cbi_Wares.Wrn_Wt%TYPE DEFAULT NULL,
        p_Wrn_Wrn_Main     IN     Ndi_Cbi_Wares.Wrn_Wrn_Main%TYPE DEFAULT NULL,
        p_Wrn_Wrn_Parent   IN     Ndi_Cbi_Wares.Wrn_Wrn_Parent%TYPE DEFAULT NULL,
        p_Wrn_Code         IN     Ndi_Cbi_Wares.Wrn_Code%TYPE DEFAULT NULL,
        p_Wrn_Shifr        IN     Ndi_Cbi_Wares.Wrn_Shifr%TYPE DEFAULT NULL,
        p_Wrn_Art          IN     Ndi_Cbi_Wares.Wrn_Art%TYPE DEFAULT NULL,
        p_Wrn_Name         IN     Ndi_Cbi_Wares.Wrn_Name%TYPE DEFAULT NULL,
        p_Wrn_Duration     IN     Ndi_Cbi_Wares.Wrn_Duration%TYPE DEFAULT NULL,
        p_Wrn_St           IN     Ndi_Cbi_Wares.Wrn_St%TYPE DEFAULT NULL,
        p_History_Status   IN     Ndi_Cbi_Wares.History_Status%TYPE DEFAULT NULL,
        p_Wrn_Count        IN     Ndi_Cbi_Wares.Wrn_Count%TYPE DEFAULT NULL,
        p_Wrn_Candelete    IN     Ndi_Cbi_Wares.Wrn_Candelete%TYPE DEFAULT NULL,
        p_New_Id              OUT Ndi_Cbi_Wares.Wrn_Id%TYPE)
    IS
    BEGIN
        INSERT INTO Ndi_Cbi_Wares (Wrn_Id,
                                   Wrn_Wt,
                                   Wrn_Wrn_Main,
                                   Wrn_Wrn_Parent,
                                   Wrn_Code,
                                   Wrn_Shifr,
                                   Wrn_Art,
                                   Wrn_Name,
                                   Wrn_Duration,
                                   Wrn_St,
                                   History_Status,
                                   Wrn_Count,
                                   Wrn_Candelete)
             VALUES (0,
                     p_Wrn_Wt,
                     p_Wrn_Wrn_Main,
                     p_Wrn_Wrn_Parent,
                     p_Wrn_Code,
                     p_Wrn_Shifr,
                     p_Wrn_Art,
                     p_Wrn_Name,
                     p_Wrn_Duration,
                     p_Wrn_St,
                     p_History_Status,
                     p_Wrn_Count,
                     p_Wrn_Candelete)
          RETURNING Wrn_Id
               INTO p_New_Id;
    END;
END Api$dic_Common;
/