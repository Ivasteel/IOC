/* Formatted on 8/12/2025 5:55:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.API$DIC_DOCUMENT
IS
    Package_Name   CONSTANT VARCHAR2 (100) := 'API$DIC_DOCUMENT';

    TYPE r_ndi_post_office IS RECORD
    (
        Npo_Id         ndi_post_office.npo_id%TYPE,
        Npo_Org        ndi_post_office.npo_org%TYPE,
        Npo_Index      ndi_post_office.npo_index%TYPE,
        Npo_Address    ndi_post_office.npo_address%TYPE,
        Npo_Ncn        ndi_post_office.npo_ncn%TYPE
    );

    TYPE t_ndi_post_office IS TABLE OF r_ndi_post_office;

    --===============================================
    --                NDI_TYPE
    --===============================================

    PROCEDURE save_ndi_document_type (
        p_ndt_id              IN     ndi_document_type.ndt_id%TYPE,
        p_ndt_ndc             IN     ndi_document_type.ndt_ndc%TYPE,
        p_ndt_name            IN     ndi_document_type.ndt_name%TYPE,
        p_ndt_name_short      IN     ndi_document_type.ndt_name_short%TYPE,
        p_ndt_order           IN     ndi_document_type.ndt_order%TYPE,
        p_ndt_is_have_scan    IN     ndi_document_type.ndt_is_have_scan%TYPE,
        p_ndt_is_vt_visible   IN     ndi_document_type.ndt_is_vt_visible%TYPE,
        p_new_id                 OUT ndi_document_type.ndt_id%TYPE);

    PROCEDURE Delete_Ndi_Document_Type (p_Id NDI_DOCUMENT_TYPE.NDT_ID%TYPE);

    --===============================================
    --                NDI_CLASS
    --===============================================

    PROCEDURE Save_Ndi_Document_Class (
        p_NDC_ID            IN     NDI_DOCUMENT_CLASS.NDC_ID%TYPE,
        p_NDC_NAME          IN     NDI_DOCUMENT_CLASS.NDC_NAME%TYPE,
        p_NDC_NAME_SHORT    IN     NDI_DOCUMENT_CLASS.NDC_NAME_SHORT%TYPE,
        p_NDC_CODE          IN     NDI_DOCUMENT_CLASS.NDC_CODE%TYPE,
        p_NDC_ORDER         IN     NDI_DOCUMENT_CLASS.NDC_ORDER%TYPE,
        p_NDC_DESCRIPTION   IN     NDI_DOCUMENT_CLASS.NDC_DESCRIPTION%TYPE,
        p_new_id               OUT NDI_DOCUMENT_CLASS.NDC_ID%TYPE);

    PROCEDURE Delete_Ndi_Document_Class (p_Id NDI_DOCUMENT_CLASS.NDC_ID%TYPE);

    --===============================================
    --                NDI_NDA_GROUP
    --===============================================

    PROCEDURE Save_Ndi_Nda_Group (
        p_NNG_ID            IN     NDI_NDA_GROUP.NNG_ID%TYPE,
        p_NNG_NAME          IN     NDI_NDA_GROUP.NNG_NAME%TYPE,
        p_NNG_OPEN_BY_DEF   IN     NDI_NDA_GROUP.NNG_OPEN_BY_DEF%TYPE,
        p_NNG_ORDER         IN     NDI_NDA_GROUP.NNG_ORDER%TYPE,
        p_HISTORY_STATUS    IN     NDI_NDA_GROUP.HISTORY_STATUS%TYPE,
        p_new_id               OUT NDI_NDA_GROUP.NNG_ID%TYPE);

    PROCEDURE Delete_Ndi_Nda_Group (
        p_Id               NDI_NDA_GROUP.NNG_ID%TYPE,
        p_History_Status   NDI_NDA_GROUP.HISTORY_STATUS%TYPE);


    --===============================================
    --                NDI_NDA_CONFIG
    --===============================================
    PROCEDURE Save_NDI_NDA_CONFIG (
        p_NAC_NDA     IN NDI_NDA_CONFIG.NAC_NDA%TYPE,
        p_NAC_AP_TP   IN NDI_NDA_CONFIG.NAC_AP_TP%TYPE,
        p_nst_list    IN VARCHAR2);

    PROCEDURE Delete_NDI_NDA_CONFIG (
        p_NAC_NDA   IN NDI_NDA_CONFIG.NAC_NDA%TYPE);

    --===============================================
    --                NDI_DOCUMENT_ATTR
    --===============================================

    PROCEDURE Save_Ndi_Document_Attr (
        p_NDA_ID           IN     NDI_DOCUMENT_ATTR.NDA_ID%TYPE,
        p_NDA_NDT          IN     NDI_DOCUMENT_ATTR.NDA_NDT%TYPE,
        p_NDA_NAME         IN     NDI_DOCUMENT_ATTR.NDA_NAME%TYPE,
        p_NDA_ORDER        IN     NDI_DOCUMENT_ATTR.NDA_ORDER%TYPE,
        p_NDA_IS_KEY       IN     NDI_DOCUMENT_ATTR.NDA_IS_KEY%TYPE,
        p_HISTORY_STATUS   IN     NDI_DOCUMENT_ATTR.HISTORY_STATUS%TYPE,
        p_NDA_PT           IN     NDI_DOCUMENT_ATTR.NDA_PT%TYPE,
        p_NDA_IS_REQ       IN     NDI_DOCUMENT_ATTR.NDA_IS_REQ%TYPE,
        p_NDA_DEF_VALUE    IN     NDI_DOCUMENT_ATTR.NDA_DEF_VALUE%TYPE,
        p_NDA_CAN_EDIT     IN     NDI_DOCUMENT_ATTR.NDA_CAN_EDIT%TYPE,
        p_NDA_NEED_SHOW    IN     NDI_DOCUMENT_ATTR.NDA_NEED_SHOW%TYPE,
        p_NDA_CLASS        IN     NDI_DOCUMENT_ATTR.NDA_CLASS%TYPE,
        p_NDA_NNG          IN     NDI_DOCUMENT_ATTR.NDA_NNG%TYPE,
        p_NAC_AP_TP        IN     NDI_NDA_CONFIG.NAC_AP_TP%TYPE,
        p_nst_list         IN     VARCHAR2,
        p_new_id              OUT NDI_DOCUMENT_ATTR.NDA_ID%TYPE);

    PROCEDURE Delete_Ndi_Document_Attr (
        p_NDA_ID           NDI_DOCUMENT_ATTR.NDA_ID%TYPE,
        p_History_Status   NDI_DOCUMENT_ATTR.HISTORY_STATUS%TYPE);

    --===============================================
    --                NDI_LIVING_WAGE
    --===============================================

    PROCEDURE Save_Ndi_Living_Wage (
        p_LGW_START_DT          IN NDI_LIVING_WAGE.LGW_START_DT%TYPE,
        p_LGW_STOP_DT           IN NDI_LIVING_WAGE.LGW_STOP_DT%TYPE,
        p_LGW_CMN_SUM           IN NDI_LIVING_WAGE.LGW_CMN_SUM%TYPE,
        p_LGW_6YEAR_SUM         IN NDI_LIVING_WAGE.LGW_6YEAR_SUM%TYPE,
        p_LGW_18YEAR_SUM        IN NDI_LIVING_WAGE.LGW_18YEAR_SUM%TYPE,
        p_LGW_WORK_ABLE_SUM     IN NDI_LIVING_WAGE.LGW_WORK_ABLE_SUM%TYPE,
        p_LGW_WORK_UNABLE_SUM   IN NDI_LIVING_WAGE.LGW_WORK_UNABLE_SUM%TYPE);

    PROCEDURE Delete_Ndi_Living_Wage (
        p_LGW_ID           NDI_LIVING_WAGE.LGW_ID%TYPE,
        p_History_Status   NDI_LIVING_WAGE.HISTORY_STATUS%TYPE);

    --===============================================
    --                NDI_POST_OFFICE
    --===============================================

    PROCEDURE save_post_office (
        p_npo_id           IN     ndi_post_office.npo_id%TYPE,
        p_npo_index        IN     ndi_post_office.npo_index%TYPE,
        p_npo_address      IN     ndi_post_office.npo_address%TYPE,
        p_npo_ncn          IN     ndi_post_office.npo_ncn%TYPE,
        p_history_status   IN     ndi_post_office.history_status%TYPE,
        p_npo_kaot         IN     ndi_post_office.npo_kaot%TYPE,
        p_new_id              OUT ndi_post_office.npo_id%TYPE);

    PROCEDURE save_post_office_ncn (
        p_npo_id    IN ndi_post_office.npo_id%TYPE,
        p_npo_ncn   IN ndi_post_office.npo_ncn%TYPE);

    PROCEDURE delete_post_office (
        p_npo_id           ndi_post_office.npo_id%TYPE,
        p_history_status   ndi_post_office.history_status%TYPE);

    --===============================================
    --                NDI_COMM_NODE
    --===============================================

    PROCEDURE Save_Comm_Node (
        p_NCN_ID           IN     NDI_COMM_NODE.NCN_ID%TYPE,
        p_NCN_ORG          IN     NDI_COMM_NODE.NCN_ORG%TYPE,
        p_NCN_CODE         IN     NDI_COMM_NODE.NCN_CODE%TYPE,
        p_NCN_SNAME        IN     NDI_COMM_NODE.NCN_SNAME%TYPE,
        p_NCN_NAME         IN     NDI_COMM_NODE.NCN_NAME%TYPE,
        p_HISTORY_STATUS   IN     NDI_COMM_NODE.HISTORY_STATUS%TYPE,
        p_new_id              OUT NDI_COMM_NODE.NCN_ID%TYPE);

    PROCEDURE Delete_Comm_Node (
        p_NCN_ID           NDI_COMM_NODE.NCN_ID%TYPE,
        p_History_Status   NDI_COMM_NODE.HISTORY_STATUS%TYPE);

    --===============================================
    --                NDI_STREET_TYPE
    --===============================================

    PROCEDURE Save_Street_Type (
        p_NSRT_ID          IN     NDI_STREET_TYPE.NSRT_ID%TYPE,
        p_NSRT_CODE        IN     NDI_STREET_TYPE.NSRT_CODE%TYPE,
        p_NSRT_NAME        IN     NDI_STREET_TYPE.NSRT_NAME%TYPE,
        p_HISTORY_STATUS   IN     NDI_STREET_TYPE.HISTORY_STATUS%TYPE,
        p_new_id              OUT NDI_STREET_TYPE.NSRT_ID%TYPE);

    PROCEDURE Delete_Street_Type (
        p_NSRT_ID          NDI_STREET_TYPE.NSRT_ID%TYPE,
        p_History_Status   NDI_STREET_TYPE.HISTORY_STATUS%TYPE);

    --===============================================
    --                NDI_STREET
    --===============================================

    PROCEDURE Save_Street_card (
        p_NS_ID            IN     NDI_STREET.NS_ID%TYPE,
        p_NS_CODE          IN     NDI_STREET.NS_CODE%TYPE,
        p_NS_NAME          IN     NDI_STREET.NS_NAME%TYPE,
        p_NS_KAOT          IN     NDI_STREET.NS_KAOT%TYPE,
        p_NS_NSRT          IN     NDI_STREET.NS_NSRT%TYPE,
        p_ns_org           IN     ndi_street.ns_org%TYPE,
        p_HISTORY_STATUS   IN     NDI_STREET.HISTORY_STATUS%TYPE,
        p_xml              IN     CLOB,
        p_new_id              OUT NDI_STREET.NS_ID%TYPE);

    PROCEDURE Delete_Street (
        p_NS_ID            NDI_STREET.NS_ID%TYPE,
        p_History_Status   NDI_STREET.HISTORY_STATUS%TYPE);

    PROCEDURE Set_Street_Kaot (p_kaot_id   IN ndi_street.ns_id%TYPE,
                               p_ids       IN VARCHAR2);

    --===============================================
    --                NDI_KEKV
    --===============================================

    PROCEDURE Save_KEKV (
        p_NKV_ID           IN     NDI_KEKV.NKV_ID%TYPE,
        p_NKV_NKV          IN     NDI_KEKV.NKV_NKV%TYPE,
        p_NKV_CODE         IN     NDI_KEKV.NKV_CODE%TYPE,
        p_NKV_NAME         IN     NDI_KEKV.NKV_NAME%TYPE,
        p_NKV_SNAME        IN     NDI_KEKV.NKV_SNAME%TYPE,
        p_HISTORY_STATUS   IN     NDI_KEKV.HISTORY_STATUS%TYPE,
        p_new_id              OUT NDI_KEKV.NKV_ID%TYPE);

    PROCEDURE Delete_KEKV (p_NKV_ID           NDI_KEKV.NKV_ID%TYPE,
                           p_History_Status   NDI_KEKV.HISTORY_STATUS%TYPE);

    --===============================================
    --                NDI_DELIVERY
    --===============================================

    /*PROCEDURE Save_Delivery(
      p_ND_ID IN NDI_DELIVERY.ND_ID%TYPE,
      p_ND_CODE IN NDI_DELIVERY.ND_CODE%TYPE,
      p_ND_COMMENT IN NDI_DELIVERY.ND_COMMENT%TYPE,
      p_ND_NPO IN NDI_DELIVERY.ND_NPO%TYPE,
      p_HISTORY_STATUS IN NDI_DELIVERY.HISTORY_STATUS%TYPE,
      p_ND_TP IN NDI_DELIVERY.ND_TP%TYPE,
      p_new_id out NDI_DELIVERY.ND_ID%TYPE);

     PROCEDURE Delete_Delivery(p_ND_ID NDI_DELIVERY.ND_ID%TYPE,
                           p_History_Status NDI_DELIVERY.HISTORY_STATUS%TYPE);
                           */
    --===============================================
    --                NDI_NB_FILIA
    --===============================================

    PROCEDURE Save_Nb_Filia (
        p_NBF_ID           IN     NDI_NB_FILIA.NBF_ID%TYPE,
        p_NBF_NB           IN     NDI_NB_FILIA.NBF_NB%TYPE,
        p_NBF_NAME         IN     NDI_NB_FILIA.NBF_NAME%TYPE,
        p_NBF_SNAME        IN     NDI_NB_FILIA.NBF_SNAME%TYPE,
        p_NBF_ORG          IN     NDI_NB_FILIA.NBF_ORG%TYPE,
        p_HISTORY_STATUS   IN     NDI_NB_FILIA.HISTORY_STATUS%TYPE,
        p_NBF_CODE         IN     NDI_NB_FILIA.NBF_CODE%TYPE,
        p_new_id              OUT NDI_NB_FILIA.NBF_ID%TYPE);

    PROCEDURE Delete_Nb_Filia (
        p_NBF_ID           NDI_NB_FILIA.NBF_ID%TYPE,
        p_History_Status   NDI_NB_FILIA.HISTORY_STATUS%TYPE);


    --===============================================
    --                NDI_BUDGET
    --===============================================

    PROCEDURE save_budget (
        p_nbu_id           IN     ndi_budget.nbu_id%TYPE,
        p_nbu_tp           IN     ndi_budget.nbu_tp%TYPE,
        p_nbu_code         IN     ndi_budget.nbu_code%TYPE,
        p_nbu_name         IN     ndi_budget.nbu_name%TYPE,
        p_history_status   IN     ndi_budget.history_status%TYPE,
        p_nbu_hs_upd       IN     ndi_budget.nbu_hs_upd%TYPE,
        p_nbu_hs_del       IN     ndi_budget.nbu_hs_del%TYPE,
        p_new_id              OUT ndi_budget.nbu_id%TYPE);

    PROCEDURE delete_budget (p_nbu_id ndi_budget.nbu_id%TYPE);

    --===============================================
    --                NDI_FUNDING_SOURCE
    --===============================================

    PROCEDURE save_funding_source (
        p_nfs_id           IN     ndi_funding_source.nfs_id%TYPE,
        p_nfs_nbg          IN     ndi_funding_source.nfs_nbg%TYPE,
        p_nfs_nbu          IN     ndi_funding_source.nfs_nbu%TYPE,
        p_nfs_name         IN     ndi_funding_source.nfs_name%TYPE,
        p_nfs_tp           IN     ndi_funding_source.nfs_tp%TYPE,
        p_history_status   IN     ndi_funding_source.history_status%TYPE,
        p_nfs_hs_upd       IN     ndi_funding_source.nfs_hs_upd%TYPE,
        p_nfs_hs_del       IN     ndi_funding_source.nfs_hs_del%TYPE,
        p_new_id              OUT ndi_funding_source.nfs_id%TYPE);

    PROCEDURE delete_funding_source (p_nfs_id ndi_funding_source.nfs_id%TYPE);


    --===============================================
    --                NDI_MIN_ZP
    --===============================================

    PROCEDURE save_ndi_min_zp (
        p_nmz_start_dt    IN ndi_min_zp.nmz_start_dt%TYPE,
        p_nmz_stop_dt     IN ndi_min_zp.nmz_stop_dt%TYPE,
        p_nmz_month_sum   IN ndi_min_zp.nmz_month_sum%TYPE,
        p_nmz_hour_sum    IN ndi_min_zp.nmz_hour_sum%TYPE);

    PROCEDURE delete_ndi_min_zp (p_nmz_id ndi_min_zp.nmz_id%TYPE);

    --===============================================
    --                NDI_LGW_SUB_LEVEL
    --===============================================
    PROCEDURE save_lgw_sub_level (
        p_nlsl_start_dt            IN ndi_lgw_sub_level.nlsl_start_dt%TYPE,
        p_nlsl_stop_dt             IN ndi_lgw_sub_level.nlsl_stop_dt%TYPE,
        p_nlsl_18year_level        IN ndi_lgw_sub_level.nlsl_18year_level%TYPE,
        p_nlsl_work_able_level     IN ndi_lgw_sub_level.nlsl_work_able_level%TYPE,
        p_nlsl_work_unable_level   IN ndi_lgw_sub_level.nlsl_work_unable_level%TYPE);

    PROCEDURE delete_lgw_sub_level (p_nlsl_id ndi_lgw_sub_level.nlsl_id%TYPE);

    --===============================================
    --                NDI_FIN_PAY_CONFIG
    --===============================================

    PROCEDURE save_ndi_pay_config (
        p_nfpc_id       IN     ndi_fin_pay_config.nfpc_id%TYPE,
        p_nfpc_pay_tp   IN     ndi_fin_pay_config.nfpc_pay_tp%TYPE,
        p_nfpc_nb       IN     ndi_fin_pay_config.nfpc_nb%TYPE,
        p_nfpc_ncn      IN     ndi_fin_pay_config.nfpc_ncn%TYPE,
        p_nfpc_dppa     IN     ndi_fin_pay_config.nfpc_dppa%TYPE,
        p_new_id           OUT ndi_fin_pay_config.nfpc_id%TYPE);

    PROCEDURE delete_ndi_pay_config (
        p_nfpc_id   ndi_fin_pay_config.nfpc_id%TYPE);

    --===============================================
    --                NDI_SITE + NDI_NIS_USERS
    --===============================================


    PROCEDURE delete_ndi_site (p_nis_id ndi_site.nis_id%TYPE);

    PROCEDURE save_ndi_site (p_nis_id      IN     ndi_site.nis_id%TYPE,
                             p_nis_name    IN     ndi_site.nis_name%TYPE,
                             p_nis_order   IN     ndi_site.nis_order%TYPE,
                             p_new_id         OUT ndi_site.nis_id%TYPE);

    PROCEDURE delete_ndi_nis_user (p_nisu_id ndi_nis_users.nisu_id%TYPE);

    PROCEDURE set_one_user (
        p_wu_id           ikis_sysweb.v$all_users.wu_id%TYPE,
        p_nis_id   IN     ndi_site.nis_id%TYPE,
        p_new_id      OUT ndi_nis_users.nisu_id%TYPE);

    --===============================================
    --                NDI_normative_act
    --===============================================

    PROCEDURE save_normative_act (
        p_nna_id            IN     ndi_normative_act.nna_id%TYPE,
        p_nna_tp            IN     ndi_normative_act.nna_tp%TYPE,
        p_nna_publisher     IN     ndi_normative_act.nna_publisher%TYPE,
        p_nna_dt            IN     ndi_normative_act.nna_dt%TYPE,
        p_nna_num           IN     ndi_normative_act.nna_num%TYPE,
        p_nna_description   IN     ndi_normative_act.nna_description%TYPE,
        p_nna_url           IN     ndi_normative_act.nna_url%TYPE,
        p_nna_asof_dt       IN     ndi_normative_act.nna_asof_dt%TYPE,
        p_nna_start_dt      IN     ndi_normative_act.nna_start_dt%TYPE,
        p_nna_nna_main      IN     ndi_normative_act.nna_nna_main%TYPE,
        p_new_id               OUT ndi_normative_act.nna_id%TYPE);

    PROCEDURE delete_normative_act (p_nna_id ndi_normative_act.nna_id%TYPE);

    FUNCTION Get_Nda_Id (p_Ndt_Id IN NUMBER, p_Nda_Class IN VARCHAR2)
        RETURN NUMBER;

    PROCEDURE set_street (
        p_ns_id            IN     ndi_street.ns_id%TYPE,
        p_ns_code          IN     ndi_street.ns_code%TYPE,
        p_ns_name          IN     ndi_street.ns_name%TYPE,
        p_ns_kaot          IN     ndi_street.ns_kaot%TYPE,
        p_ns_nsrt          IN     ndi_street.ns_nsrt%TYPE,
        p_ns_org           IN     ndi_street.ns_org%TYPE,
        p_history_status   IN     ndi_street.history_status%TYPE,
        p_new_id              OUT ndi_street.ns_id%TYPE);
END API$DIC_DOCUMENT;
/


GRANT EXECUTE ON USS_NDI.API$DIC_DOCUMENT TO II01RC_USS_NDI_INTERNAL
/

GRANT EXECUTE ON USS_NDI.API$DIC_DOCUMENT TO IKIS_RBM
/

GRANT EXECUTE ON USS_NDI.API$DIC_DOCUMENT TO USS_ESR
/

GRANT EXECUTE ON USS_NDI.API$DIC_DOCUMENT TO USS_PERSON
/

GRANT EXECUTE ON USS_NDI.API$DIC_DOCUMENT TO USS_RNSP
/

GRANT EXECUTE ON USS_NDI.API$DIC_DOCUMENT TO USS_RPT
/

GRANT EXECUTE ON USS_NDI.API$DIC_DOCUMENT TO USS_VISIT
/


/* Formatted on 8/12/2025 5:55:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.API$DIC_DOCUMENT
IS
    --===============================================
    --                NDI_TYPE
    --===============================================

    PROCEDURE save_ndi_document_type (
        p_ndt_id              IN     ndi_document_type.ndt_id%TYPE,
        p_ndt_ndc             IN     ndi_document_type.ndt_ndc%TYPE,
        p_ndt_name            IN     ndi_document_type.ndt_name%TYPE,
        p_ndt_name_short      IN     ndi_document_type.ndt_name_short%TYPE,
        p_ndt_order           IN     ndi_document_type.ndt_order%TYPE,
        p_ndt_is_have_scan    IN     ndi_document_type.ndt_is_have_scan%TYPE,
        p_ndt_is_vt_visible   IN     ndi_document_type.ndt_is_vt_visible%TYPE,
        p_new_id                 OUT ndi_document_type.ndt_id%TYPE)
    IS
        l_rec_src   ndi_document_type.record_src%TYPE;
        l_hs        NUMBER := tools.GetHistSession;
    BEGIN
        IF p_ndt_id IS NULL
        THEN
            INSERT INTO NDI_DOCUMENT_TYPE t (ndt_ndc,
                                             ndt_name,
                                             ndt_name_short,
                                             ndt_order,
                                             ndt_is_have_scan,
                                             ndt_is_vt_visible,
                                             history_status,
                                             record_src,
                                             ndt_hs_ins)
                 VALUES (p_ndt_ndc,
                         p_ndt_name,
                         p_ndt_name_short,
                         p_ndt_order,
                         p_ndt_is_have_scan,
                         p_ndt_is_vt_visible,
                         'A',
                         TOOLS.get_record_src,
                         l_hs)
              RETURNING ndt_id
                   INTO p_new_id;

            API$CHANGE_LOG.write_change_log (
                p_ncl_object      => 'NDI_DOCUMENT_TYPE',
                p_ncl_action      => 'C',
                p_ncl_hs          => l_hs,
                p_ncl_record_id   => p_New_Id);
        ELSE
            p_new_id := p_ndt_id;

            SELECT t.record_src
              INTO l_rec_src
              FROM ndi_document_type t
             WHERE t.ndt_id = p_Ndt_Id;

            TOOLS.check_record_src (l_rec_src);

            UPDATE ndi_document_type
               SET ndt_ndc = p_ndt_ndc,
                   ndt_name = p_ndt_name,
                   ndt_name_short = p_ndt_name_short,
                   ndt_order = p_ndt_order,
                   ndt_is_have_scan = p_ndt_is_have_scan,
                   ndt_is_vt_visible = p_ndt_is_vt_visible,
                   history_status = 'A'
             WHERE ndt_id = p_ndt_id;

            API$CHANGE_LOG.write_change_log (
                p_ncl_object      => 'NDI_DOCUMENT_TYPE',
                p_ncl_action      => 'U',
                p_ncl_hs          => l_hs,
                p_ncl_record_id   => p_New_Id);
        END IF;
    END;

    PROCEDURE delete_ndi_document_type (p_id ndi_document_type.ndt_id%TYPE)
    IS
        l_hs        NUMBER := tools.GetHistSession;
        l_rec_src   ndi_document_type.record_src%TYPE;
    BEGIN
        SELECT t.record_src
          INTO l_rec_src
          FROM ndi_document_type t
         WHERE t.ndt_id = p_Id;

        TOOLS.check_record_src (l_rec_src);

        UPDATE ndi_document_type t
           SET history_status = 'H', t.ndt_hs_del = l_hs
         WHERE ndt_id = p_id;

        API$CHANGE_LOG.write_change_log (
            p_ncl_object       => 'NDI_DOCUMENT_TYPE',
            p_ncl_action       => 'D',
            p_ncl_hs           => l_hs,
            p_ncl_decription   => '&322',
            p_ncl_record_id    => p_id);
    END;

    --===============================================
    --                NDI_CLASS
    --===============================================

    PROCEDURE Save_Ndi_Document_Class (
        p_NDC_ID            IN     NDI_DOCUMENT_CLASS.NDC_ID%TYPE,
        p_NDC_NAME          IN     NDI_DOCUMENT_CLASS.NDC_NAME%TYPE,
        p_NDC_NAME_SHORT    IN     NDI_DOCUMENT_CLASS.NDC_NAME_SHORT%TYPE,
        p_NDC_CODE          IN     NDI_DOCUMENT_CLASS.NDC_CODE%TYPE,
        p_NDC_ORDER         IN     NDI_DOCUMENT_CLASS.NDC_ORDER%TYPE,
        p_NDC_DESCRIPTION   IN     NDI_DOCUMENT_CLASS.NDC_DESCRIPTION%TYPE,
        p_new_id               OUT NDI_DOCUMENT_CLASS.NDC_ID%TYPE)
    IS
        l_rec_src   NDI_DOCUMENT_CLASS.record_src%TYPE;
        l_hs        NUMBER := tools.GetHistSession;
    BEGIN
        IF p_NDC_ID IS NULL
        THEN
            INSERT INTO NDI_DOCUMENT_CLASS (NDC_NAME,
                                            NDC_NAME_SHORT,
                                            NDC_CODE,
                                            NDC_ORDER,
                                            NDC_DESCRIPTION,
                                            HISTORY_STATUS,
                                            record_Src,
                                            ndc_hs_ins)
                 VALUES (p_NDC_NAME,
                         p_NDC_NAME_SHORT,
                         p_NDC_CODE,
                         p_NDC_ORDER,
                         p_NDC_DESCRIPTION,
                         'A',
                         TOOLS.get_record_src,
                         l_hs)
              RETURNING NDC_ID
                   INTO p_new_id;

            API$CHANGE_LOG.write_change_log (
                p_ncl_object      => 'NDI_DOCUMENT_CLASS',
                p_ncl_action      => 'C',
                p_ncl_hs          => l_hs,
                p_ncl_record_id   => p_New_Id);
        ELSE
            p_new_id := p_NDC_ID;

            SELECT t.record_src
              INTO l_rec_src
              FROM NDI_DOCUMENT_CLASS t
             WHERE t.ndc_id = p_Ndc_Id;

            TOOLS.check_record_src (l_rec_src);

            UPDATE NDI_DOCUMENT_CLASS t
               SET NDC_NAME = p_NDC_NAME,
                   NDC_NAME_SHORT = p_NDC_NAME_SHORT,
                   NDC_CODE = p_NDC_CODE,
                   NDC_ORDER = p_NDC_ORDER,
                   NDC_DESCRIPTION = p_NDC_DESCRIPTION,
                   HISTORY_STATUS = 'A'
             WHERE NDC_ID = p_NDC_ID;

            API$CHANGE_LOG.write_change_log (
                p_ncl_object      => 'NDI_DOCUMENT_CLASS',
                p_ncl_action      => 'U',
                p_ncl_hs          => l_hs,
                p_ncl_record_id   => p_New_Id);
        END IF;
    END;

    PROCEDURE Delete_Ndi_Document_Class (p_id NDI_DOCUMENT_CLASS.NDC_ID%TYPE)
    IS
        l_hs        NUMBER := tools.GetHistSession;
        l_rec_src   NDI_DOCUMENT_CLASS.record_src%TYPE;
    BEGIN
        SELECT t.record_src
          INTO l_rec_src
          FROM NDI_DOCUMENT_CLASS t
         WHERE t.ndc_id = p_Id;

        TOOLS.check_record_src (l_rec_src);

        UPDATE NDI_DOCUMENT_CLASS t
           SET HISTORY_STATUS = 'H', t.ndc_hs_del = l_hs
         WHERE NDC_ID = p_id;

        API$CHANGE_LOG.write_change_log (
            p_ncl_object       => 'NDI_DOCUMENT_CLASS',
            p_ncl_action       => 'D',
            p_ncl_hs           => l_hs,
            p_ncl_decription   => '&322',
            p_ncl_record_id    => p_id);
    END;

    --===============================================
    --                NDI_NDA_GROUP
    --===============================================

    PROCEDURE Save_Ndi_Nda_Group (
        p_NNG_ID            IN     NDI_NDA_GROUP.NNG_ID%TYPE,
        p_NNG_NAME          IN     NDI_NDA_GROUP.NNG_NAME%TYPE,
        p_NNG_OPEN_BY_DEF   IN     NDI_NDA_GROUP.NNG_OPEN_BY_DEF%TYPE,
        p_NNG_ORDER         IN     NDI_NDA_GROUP.NNG_ORDER%TYPE,
        p_HISTORY_STATUS    IN     NDI_NDA_GROUP.HISTORY_STATUS%TYPE,
        p_new_id               OUT NDI_NDA_GROUP.NNG_ID%TYPE)
    IS
        l_rec_src   NDI_NDA_GROUP.record_src%TYPE;
        l_hs        NUMBER := tools.GetHistSession;
    BEGIN
        IF p_NNG_ID IS NULL
        THEN
            INSERT INTO NDI_NDA_GROUP t (NNG_NAME,
                                         NNG_OPEN_BY_DEF,
                                         NNG_ORDER,
                                         HISTORY_STATUS,
                                         nng_hs_ins,
                                         record_src)
                 VALUES (p_NNG_NAME,
                         p_NNG_OPEN_BY_DEF,
                         p_NNG_ORDER,
                         p_HISTORY_STATUS,
                         l_hs,
                         TOOLS.get_record_src)
              RETURNING NNG_ID
                   INTO p_new_id;

            API$CHANGE_LOG.write_change_log (
                p_ncl_object      => 'NDI_NDA_GROUP',
                p_ncl_action      => 'C',
                p_ncl_hs          => l_hs,
                p_ncl_record_id   => p_New_Id);
        ELSE
            p_new_id := p_NNG_ID;

            SELECT t.record_src
              INTO l_rec_src
              FROM NDI_NDA_GROUP t
             WHERE t.nng_id = p_NNG_ID;

            TOOLS.check_record_src (l_rec_src);

            UPDATE NDI_NDA_GROUP
               SET NNG_NAME = p_NNG_NAME,
                   NNG_OPEN_BY_DEF = p_NNG_OPEN_BY_DEF,
                   NNG_ORDER = p_NNG_ORDER,
                   HISTORY_STATUS = p_HISTORY_STATUS
             WHERE NNG_ID = p_NNG_ID;

            API$CHANGE_LOG.write_change_log (
                p_ncl_object      => 'NDI_NDA_GROUP',
                p_ncl_action      => 'U',
                p_ncl_hs          => l_hs,
                p_ncl_record_id   => p_New_Id);
        END IF;
    END;

    PROCEDURE Delete_Ndi_Nda_Group (
        p_Id               NDI_NDA_GROUP.NNG_ID%TYPE,
        p_History_Status   NDI_NDA_GROUP.HISTORY_STATUS%TYPE)
    IS
        l_hs        NUMBER := tools.GetHistSession;
        l_rec_src   NDI_NDA_GROUP.record_src%TYPE;
    BEGIN
        SELECT t.record_src
          INTO l_rec_src
          FROM NDI_NDA_GROUP t
         WHERE t.nng_id = p_ID;

        TOOLS.check_record_src (l_rec_src);

        UPDATE NDI_NDA_GROUP t
           SET HISTORY_STATUS = p_History_Status, t.nng_hs_del = l_hs
         WHERE NNG_ID = p_Id;

        API$CHANGE_LOG.write_change_log (p_ncl_object       => 'NDI_NDA_GROUP',
                                         p_ncl_action       => 'D',
                                         p_ncl_hs           => l_hs,
                                         p_ncl_decription   => '&322',
                                         p_ncl_record_id    => p_id);
    END;

    --===============================================
    --                NDI_NDA_CONFIG
    --               #77208 20220518
    --===============================================
    PROCEDURE Save_NDI_NDA_CONFIG (
        p_NAC_NDA     IN NDI_NDA_CONFIG.NAC_NDA%TYPE,
        p_NAC_AP_TP   IN NDI_NDA_CONFIG.NAC_AP_TP%TYPE,
        p_nst_list    IN VARCHAR2)
    IS
    BEGIN
        /* raise_application_error(-20009,
                                      p_NAC_NDA ||' ' || p_NAC_AP_TP ||' ' ||
                                      p_nst_list);*/
        UPDATE NDI_NDA_CONFIG
           SET HISTORY_STATUS = 'H'
         WHERE        NAC_AP_TP = P_NAC_AP_TP
                  AND NAC_NDA = P_NAC_NDA
                  AND HISTORY_STATUS = 'A'
                  AND p_nst_list IS NULL
               OR NAC_NST NOT IN
                      (    SELECT REGEXP_SUBSTR (p_nst_list,
                                                 '[^,]+',
                                                 1,
                                                 LEVEL)    AS nst_id
                             FROM DUAL
                       CONNECT BY LEVEL <=
                                    LENGTH (
                                        REGEXP_REPLACE (p_nst_list, '[^,]*'))
                                  + 1);

        MERGE INTO NDI_NDA_CONFIG
             USING (WITH
                        nda_list
                        AS
                            (    SELECT REGEXP_SUBSTR (p_nst_list,
                                                       '[^,]+',
                                                       1,
                                                       LEVEL)    AS nst_id
                                   FROM DUAL
                             CONNECT BY LEVEL <=
                                          LENGTH (
                                              REGEXP_REPLACE (p_nst_list,
                                                              '[^,]*'))
                                        + 1)
                    SELECT p_NAC_AP_TP     AS x_NAC_AP_TP,
                           p_NAC_NDA       AS x_NAC_NDA,
                           nst_id          AS x_NAC_NST
                      FROM nda_list
                     WHERE nst_id IS NOT NULL)
                ON (    NAC_AP_TP = x_NAC_AP_TP
                    AND NAC_NDA = x_NAC_NDA
                    AND NAC_NST = x_NAC_NST
                    AND HISTORY_STATUS = 'A')
        WHEN NOT MATCHED
        THEN
            INSERT     (NAC_ID,
                        NAC_AP_TP,
                        NAC_NST,
                        NAC_NDA,
                        HISTORY_STATUS)
                VALUES (NULL,
                        x_NAC_AP_TP,
                        x_NAC_NST,
                        x_NAC_NDA,
                        'A');
    END;

    PROCEDURE Delete_NDI_NDA_CONFIG (
        p_NAC_NDA   IN NDI_NDA_CONFIG.NAC_NDA%TYPE)
    IS
    BEGIN
        UPDATE NDI_NDA_CONFIG
           SET HISTORY_STATUS = 'H'
         WHERE NAC_NDA = P_NAC_NDA AND HISTORY_STATUS = 'A';
    END;

    --===============================================
    --                NDI_DOCUMENT_ATTR
    --===============================================
    PROCEDURE Save_Ndi_Document_Attr (
        p_NDA_ID           IN     NDI_DOCUMENT_ATTR.NDA_ID%TYPE,
        p_NDA_NDT          IN     NDI_DOCUMENT_ATTR.NDA_NDT%TYPE,
        p_NDA_NAME         IN     NDI_DOCUMENT_ATTR.NDA_NAME%TYPE,
        p_NDA_ORDER        IN     NDI_DOCUMENT_ATTR.NDA_ORDER%TYPE,
        p_NDA_IS_KEY       IN     NDI_DOCUMENT_ATTR.NDA_IS_KEY%TYPE,
        p_HISTORY_STATUS   IN     NDI_DOCUMENT_ATTR.HISTORY_STATUS%TYPE,
        p_NDA_PT           IN     NDI_DOCUMENT_ATTR.NDA_PT%TYPE,
        p_NDA_IS_REQ       IN     NDI_DOCUMENT_ATTR.NDA_IS_REQ%TYPE,
        p_NDA_DEF_VALUE    IN     NDI_DOCUMENT_ATTR.NDA_DEF_VALUE%TYPE,
        p_NDA_CAN_EDIT     IN     NDI_DOCUMENT_ATTR.NDA_CAN_EDIT%TYPE,
        p_NDA_NEED_SHOW    IN     NDI_DOCUMENT_ATTR.NDA_NEED_SHOW%TYPE,
        p_NDA_CLASS        IN     NDI_DOCUMENT_ATTR.NDA_CLASS%TYPE,
        p_NDA_NNG          IN     NDI_DOCUMENT_ATTR.NDA_NNG%TYPE,
        p_NAC_AP_TP        IN     NDI_NDA_CONFIG.NAC_AP_TP%TYPE, -- #77208 20220518
        p_nst_list         IN     VARCHAR2,
        p_new_id              OUT NDI_DOCUMENT_ATTR.NDA_ID%TYPE)
    IS
        l_rec_src   NDI_DOCUMENT_ATTR.record_src%TYPE;
        l_hs        NUMBER := tools.GetHistSession;
    BEGIN
        IF p_NDA_ID IS NULL
        THEN
            INSERT INTO NDI_DOCUMENT_ATTR (NDA_NDT,
                                           NDA_NAME,
                                           NDA_ORDER,
                                           NDA_IS_KEY,
                                           HISTORY_STATUS,
                                           NDA_PT,
                                           NDA_IS_REQ,
                                           NDA_DEF_VALUE,
                                           NDA_CAN_EDIT,
                                           NDA_NEED_SHOW,
                                           NDA_CLASS,
                                           NDA_NNG,
                                           record_src,
                                           nda_hs_ins)
                 VALUES (p_NDA_NDT,
                         p_NDA_NAME,
                         p_NDA_ORDER,
                         p_NDA_IS_KEY,
                         p_HISTORY_STATUS,
                         p_NDA_PT,
                         p_NDA_IS_REQ,
                         p_NDA_DEF_VALUE,
                         p_NDA_CAN_EDIT,
                         p_NDA_NEED_SHOW,
                         p_NDA_CLASS,
                         p_NDA_NNG,
                         TOOLS.get_record_src,
                         l_hs)
              RETURNING NDA_ID
                   INTO p_new_id;

            API$CHANGE_LOG.write_change_log (
                p_ncl_object      => 'NDI_DOCUMENT_ATTR',
                p_ncl_action      => 'C',
                p_ncl_hs          => l_hs,
                p_ncl_record_id   => p_New_Id);
        ELSE
            p_new_id := p_NDA_ID;

            SELECT t.record_src
              INTO l_rec_src
              FROM ndi_document_attr t
             WHERE t.nda_id = p_Nda_Id;

            TOOLS.check_record_src (l_rec_src);

            UPDATE NDI_DOCUMENT_ATTR
               SET NDA_NDT = p_NDA_NDT,
                   NDA_NAME = p_NDA_NAME,
                   NDA_ORDER = p_NDA_ORDER,
                   NDA_IS_KEY = p_NDA_IS_KEY,
                   NDA_PT = p_NDA_PT,
                   NDA_IS_REQ = p_NDA_IS_REQ,
                   NDA_DEF_VALUE = p_NDA_DEF_VALUE,
                   NDA_CAN_EDIT = p_NDA_CAN_EDIT,
                   NDA_NEED_SHOW = p_NDA_NEED_SHOW,
                   NDA_CLASS = p_NDA_CLASS,
                   NDA_NNG = p_NDA_NNG
             WHERE NDA_ID = p_NDA_ID;

            API$CHANGE_LOG.write_change_log (
                p_ncl_object      => 'NDI_DOCUMENT_ATTR',
                p_ncl_action      => 'U',
                p_ncl_hs          => l_hs,
                p_ncl_record_id   => p_New_Id);
        END IF;
    --Save_NDI_NDA_CONFIG( p_new_id, p_NAC_AP_TP, p_nst_list );

    END;

    PROCEDURE Delete_Ndi_Document_Attr (
        p_NDA_ID           NDI_DOCUMENT_ATTR.NDA_ID%TYPE,
        p_History_Status   NDI_DOCUMENT_ATTR.HISTORY_STATUS%TYPE)
    IS
        l_hs        NUMBER := tools.GetHistSession;
        l_rec_src   NDI_DOCUMENT_ATTR.record_src%TYPE;
    BEGIN
        SELECT t.record_src
          INTO l_rec_src
          FROM ndi_document_attr t
         WHERE t.nda_id = p_Nda_Id;

        TOOLS.check_record_src (l_rec_src);

        UPDATE NDI_DOCUMENT_ATTR
           SET HISTORY_STATUS = p_History_Status
         WHERE NDA_ID = p_NDA_ID;

        API$CHANGE_LOG.write_change_log (
            p_ncl_object       => 'NDI_DOCUMENT_ATTR',
            p_ncl_action       => 'D',
            p_ncl_hs           => l_hs,
            p_ncl_decription   => '&322',
            p_ncl_record_id    => p_NDA_ID);
    END;

    --===============================================
    --                NDI_DIC_DV
    --===============================================
    -- Що це за брєд...

    /*
    PROCEDURE Save_Ndi_Living_Wage(
        p_NDA_ID IN NDI_DOCUMENT_ATTR.NDA_ID%TYPE,
        p_NDA_NDT IN NDI_DOCUMENT_ATTR.NDA_NDT%TYPE,
        p_NDA_NAME IN NDI_DOCUMENT_ATTR.NDA_NAME%TYPE,
        p_NDA_ORDER IN NDI_DOCUMENT_ATTR.NDA_ORDER%TYPE,
        p_NDA_IS_KEY IN NDI_DOCUMENT_ATTR.NDA_IS_KEY%TYPE,
        p_HISTORY_STATUS IN NDI_DOCUMENT_ATTR.HISTORY_STATUS%TYPE,
        p_NDA_PT IN NDI_DOCUMENT_ATTR.NDA_PT%TYPE,
        p_NDA_IS_REQ IN NDI_DOCUMENT_ATTR.NDA_IS_REQ%TYPE,
        p_NDA_DEF_VALUE IN NDI_DOCUMENT_ATTR.NDA_DEF_VALUE%TYPE,
        p_NDA_CAN_EDIT IN NDI_DOCUMENT_ATTR.NDA_CAN_EDIT%TYPE,
        p_NDA_NEED_SHOW IN NDI_DOCUMENT_ATTR.NDA_NEED_SHOW%TYPE,
        p_NDA_CLASS IN NDI_DOCUMENT_ATTR.NDA_CLASS%TYPE,
        p_NDA_NNG IN NDI_DOCUMENT_ATTR.NDA_NNG%TYPE,
        p_new_id OUT NDI_DOCUMENT_ATTR.NDA_ID%TYPE) IS
      BEGIN
       IF p_NDA_ID IS NULL THEN
      INSERT INTO NDI_DOCUMENT_ATTR
           (
        NDA_NDT,
        NDA_NAME,
        NDA_ORDER,
        NDA_IS_KEY,
        HISTORY_STATUS,
        NDA_PT,
        NDA_IS_REQ,
        NDA_DEF_VALUE,
        NDA_CAN_EDIT,
        NDA_NEED_SHOW,
        NDA_CLASS,
        NDA_NNG
           )
         VALUES
           (
        p_NDA_NDT,
        p_NDA_NAME,
        p_NDA_ORDER,
        p_NDA_IS_KEY,
        p_HISTORY_STATUS,
        p_NDA_PT,
        p_NDA_IS_REQ,
        p_NDA_DEF_VALUE,
        p_NDA_CAN_EDIT,
        p_NDA_NEED_SHOW,
        p_NDA_CLASS,
        p_NDA_NNG
           )
         RETURNING NDA_ID INTO p_new_id;
       ELSE
         p_new_id := p_NDA_ID;

         UPDATE NDI_DOCUMENT_ATTR
            SET
        NDA_NDT = p_NDA_NDT,
        NDA_NAME = p_NDA_NAME,
        NDA_ORDER = p_NDA_ORDER,
        NDA_IS_KEY = p_NDA_IS_KEY,
        HISTORY_STATUS = p_HISTORY_STATUS,
        NDA_PT = p_NDA_PT,
        NDA_IS_REQ = p_NDA_IS_REQ,
        NDA_DEF_VALUE = p_NDA_DEF_VALUE,
        NDA_CAN_EDIT = p_NDA_CAN_EDIT,
        NDA_NEED_SHOW = p_NDA_NEED_SHOW,
        NDA_CLASS = p_NDA_CLASS,
        NDA_NNG = p_NDA_NNG
        WHERE NDA_ID = p_NDA_ID;
       END IF;
     END;

     PROCEDURE Delete_Ndi_Living_Wage(p_NDA_ID NDI_DOCUMENT_ATTR.NDA_ID%TYPE,
                                        p_History_Status NDI_DOCUMENT_ATTR.HISTORY_STATUS%TYPE) IS
     BEGIN
       UPDATE NDI_DOCUMENT_ATTR
          SET HISTORY_STATUS = p_History_Status
        WHERE NDA_ID = p_NDA_ID;
     END;
     */
    --===============================================
    --                NDI_LIVING_WAGE
    --===============================================

    PROCEDURE Save_Ndi_Living_Wage (
        p_LGW_START_DT          IN NDI_LIVING_WAGE.LGW_START_DT%TYPE,
        p_LGW_STOP_DT           IN NDI_LIVING_WAGE.LGW_STOP_DT%TYPE,
        p_LGW_CMN_SUM           IN NDI_LIVING_WAGE.LGW_CMN_SUM%TYPE,
        p_LGW_6YEAR_SUM         IN NDI_LIVING_WAGE.LGW_6YEAR_SUM%TYPE,
        p_LGW_18YEAR_SUM        IN NDI_LIVING_WAGE.LGW_18YEAR_SUM%TYPE,
        p_LGW_WORK_ABLE_SUM     IN NDI_LIVING_WAGE.LGW_WORK_ABLE_SUM%TYPE,
        p_LGW_WORK_UNABLE_SUM   IN NDI_LIVING_WAGE.LGW_WORK_UNABLE_SUM%TYPE)
    IS
        l_HsId   NUMBER;
    BEGIN
        raise_application_error (
            -20009,
            'Заборонено вносити зміни у довідник прожиткових мінімумів!');

        l_HsId := tools.GetHistSession;

        INSERT INTO tmp_unh_old_list (ol_obj,
                                      ol_hst,
                                      ol_begin,
                                      ol_end)
            SELECT 0,
                   h.lgw_id,
                   h.lgw_start_dt,
                   h.lgw_stop_dt
              FROM v_ndi_living_wage h
             WHERE h.history_status = 'A';

        -- формування історії
        api$hist.Setup_History (0, p_LGW_START_DT, p_LGW_STOP_DT);

        -- закриття недіючих
        UPDATE v_ndi_living_wage h
           SET h.lgw_hs_del = l_HsId, h.history_status = 'H'
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_unh_to_prp
                     WHERE tprp_hst = h.lgw_id);

        -- додавання нових періодів
        INSERT INTO v_ndi_living_wage (lgw_id,
                                       lgw_cmn_sum,
                                       lgw_6year_sum,
                                       lgw_18year_sum,
                                       lgw_work_able_sum,
                                       lgw_work_unable_sum,
                                       lgw_start_dt,
                                       lgw_stop_dt,
                                       lgw_hs_ins,
                                       history_status)
            SELECT 0,
                   ho.lgw_cmn_sum,
                   ho.lgw_6year_sum,
                   ho.lgw_18year_sum,
                   ho.lgw_work_able_sum,
                   ho.lgw_work_unable_sum,
                   rz.rz_begin,
                   rz.rz_end,
                   l_HsId,
                   'A'
              FROM tmp_unh_rz_list rz, v_ndi_living_wage ho
             WHERE     rz_hst <> 0
                   AND (rz_begin <= rz_end OR rz_end IS NULL)
                   AND ho.lgw_id = rz_hst
            UNION
            SELECT 0,
                   p_LGW_CMN_SUM,
                   p_LGW_6YEAR_SUM,
                   p_LGW_18YEAR_SUM,
                   p_LGW_WORK_ABLE_SUM,
                   p_LGW_WORK_UNABLE_SUM,
                   vh_lgwh.rz_begin,
                   vh_lgwh.rz_end,
                   l_HsId,
                   'A'
              FROM tmp_unh_rz_list vh_lgwh
             WHERE rz_hst = 0 AND (rz_begin <= rz_end OR rz_end IS NULL);
    END;

    PROCEDURE Delete_Ndi_Living_Wage (
        p_LGW_ID           NDI_LIVING_WAGE.LGW_ID%TYPE,
        p_History_Status   NDI_LIVING_WAGE.HISTORY_STATUS%TYPE)
    IS
        l_HsId   NUMBER;
    BEGIN
        raise_application_error (
            -20009,
            'Заборонено вносити зміни у довідник прожиткових мінімумів!');
        l_HsId := tools.GetHistSession;

        UPDATE NDI_LIVING_WAGE
           SET HISTORY_STATUS = p_History_Status, LGW_HS_DEL = l_HsId
         WHERE LGW_ID = p_LGW_ID;
    END;

    --===============================================
    --                NDI_POST_OFFICE
    --===============================================

    PROCEDURE save_post_office (
        p_npo_id           IN     ndi_post_office.npo_id%TYPE,
        --p_NPO_ORG IN NDI_POST_OFFICE.NPO_ORG%TYPE,
        p_npo_index        IN     ndi_post_office.npo_index%TYPE,
        p_npo_address      IN     ndi_post_office.npo_address%TYPE,
        p_npo_ncn          IN     ndi_post_office.npo_ncn%TYPE,
        p_history_status   IN     ndi_post_office.history_status%TYPE,
        p_npo_kaot         IN     ndi_post_office.npo_kaot%TYPE,
        p_new_id              OUT ndi_post_office.npo_id%TYPE)
    IS
    BEGIN
        IF p_npo_id IS NULL
        THEN
            INSERT INTO v_ndi_post_office (npo_index,
                                           npo_address,
                                           npo_ncn,
                                           history_status,
                                           npo_kaot)
                 VALUES (p_npo_index,
                         p_npo_address,
                         p_npo_ncn,
                         p_history_status,
                         p_npo_kaot)
              RETURNING npo_id
                   INTO p_new_id;
        ELSE
            p_new_id := p_npo_id;

            UPDATE v_ndi_post_office
               SET                                      --NPO_ORG = p_NPO_ORG,
                   npo_index = p_npo_index,
                   npo_address = p_npo_address,
                   npo_ncn = p_npo_ncn,
                   history_status = p_history_status,
                   npo_kaot = p_npo_kaot
             WHERE npo_id = p_npo_id;
        END IF;
    END;

    PROCEDURE save_post_office_ncn (
        p_npo_id    IN ndi_post_office.npo_id%TYPE,
        p_npo_ncn   IN ndi_post_office.npo_ncn%TYPE)
    IS
    BEGIN
        UPDATE v_ndi_post_office
           SET npo_ncn = p_npo_ncn
         WHERE npo_id = p_npo_id;
    END;

    PROCEDURE Delete_Post_Office (
        p_NPO_ID           NDI_POST_OFFICE.NPO_ID%TYPE,
        p_History_Status   NDI_POST_OFFICE.HISTORY_STATUS%TYPE)
    IS
    BEGIN
        UPDATE V_NDI_POST_OFFICE
           SET HISTORY_STATUS = p_History_Status
         WHERE NPO_ID = p_NPO_ID;
    END;

    --===============================================
    --                NDI_COMM_NODE
    --===============================================

    PROCEDURE Save_Comm_Node (
        p_NCN_ID           IN     NDI_COMM_NODE.NCN_ID%TYPE,
        p_NCN_ORG          IN     NDI_COMM_NODE.NCN_ORG%TYPE,
        p_NCN_CODE         IN     NDI_COMM_NODE.NCN_CODE%TYPE,
        p_NCN_SNAME        IN     NDI_COMM_NODE.NCN_SNAME%TYPE,
        p_NCN_NAME         IN     NDI_COMM_NODE.NCN_NAME%TYPE,
        p_HISTORY_STATUS   IN     NDI_COMM_NODE.HISTORY_STATUS%TYPE,
        p_new_id              OUT NDI_COMM_NODE.NCN_ID%TYPE)
    IS
    BEGIN
        IF p_NCN_ID IS NULL
        THEN
            INSERT INTO NDI_COMM_NODE (NCN_ORG,
                                       NCN_CODE,
                                       NCN_SNAME,
                                       NCN_NAME,
                                       HISTORY_STATUS)
                 VALUES (p_NCN_ORG,
                         p_NCN_CODE,
                         p_NCN_SNAME,
                         p_NCN_NAME,
                         p_HISTORY_STATUS)
              RETURNING NCN_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_NCN_ID;

            UPDATE NDI_COMM_NODE
               SET NCN_ORG = p_NCN_ORG,
                   NCN_CODE = p_NCN_CODE,
                   NCN_SNAME = p_NCN_SNAME,
                   NCN_NAME = p_NCN_NAME,
                   HISTORY_STATUS = p_HISTORY_STATUS
             WHERE NCN_ID = p_NCN_ID;
        END IF;
    END;

    PROCEDURE Delete_Comm_Node (
        p_NCN_ID           NDI_COMM_NODE.NCN_ID%TYPE,
        p_History_Status   NDI_COMM_NODE.HISTORY_STATUS%TYPE)
    IS
    BEGIN
        UPDATE NDI_COMM_NODE
           SET HISTORY_STATUS = p_History_Status
         WHERE NCN_ID = p_NCN_ID;
    END;

    --===============================================
    --                NDI_STREET_TYPE
    --===============================================

    PROCEDURE Save_Street_Type (
        p_NSRT_ID          IN     NDI_STREET_TYPE.NSRT_ID%TYPE,
        p_NSRT_CODE        IN     NDI_STREET_TYPE.NSRT_CODE%TYPE,
        p_NSRT_NAME        IN     NDI_STREET_TYPE.NSRT_NAME%TYPE,
        p_HISTORY_STATUS   IN     NDI_STREET_TYPE.HISTORY_STATUS%TYPE,
        p_new_id              OUT NDI_STREET_TYPE.NSRT_ID%TYPE)
    IS
    BEGIN
        IF p_NSRT_ID IS NULL
        THEN
            INSERT INTO NDI_STREET_TYPE (NSRT_CODE,
                                         NSRT_NAME,
                                         HISTORY_STATUS)
                 VALUES (p_NSRT_CODE, p_NSRT_NAME, p_HISTORY_STATUS)
              RETURNING NSRT_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_NSRT_ID;

            UPDATE NDI_STREET_TYPE
               SET NSRT_CODE = p_NSRT_CODE,
                   NSRT_NAME = p_NSRT_NAME,
                   HISTORY_STATUS = p_HISTORY_STATUS
             WHERE NSRT_ID = p_NSRT_ID;
        END IF;
    END;

    PROCEDURE Delete_Street_Type (
        p_NSRT_ID          NDI_STREET_TYPE.NSRT_ID%TYPE,
        p_History_Status   NDI_STREET_TYPE.HISTORY_STATUS%TYPE)
    IS
    BEGIN
        UPDATE NDI_STREET_TYPE
           SET HISTORY_STATUS = p_History_Status
         WHERE NSRT_ID = p_NSRT_ID;
    END;

    --===============================================
    --                NDI_STREET
    --===============================================

    PROCEDURE save_street_card (
        p_ns_id            IN     ndi_street.ns_id%TYPE,
        p_ns_code          IN     ndi_street.ns_code%TYPE,
        p_ns_name          IN     ndi_street.ns_name%TYPE,
        p_ns_kaot          IN     ndi_street.ns_kaot%TYPE,
        p_ns_nsrt          IN     ndi_street.ns_nsrt%TYPE,
        p_ns_org           IN     ndi_street.ns_org%TYPE,
        p_history_status   IN     ndi_street.history_status%TYPE,
        p_xml              IN     CLOB,
        p_new_id              OUT ndi_street.ns_id%TYPE)
    IS
        l_ids   VARCHAR2 (4000);
        l_arr   t_ndi_post_office;
    BEGIN
        --raise_application_error(-20000, 'p_ns_code='||p_ns_code);
        EXECUTE IMMEDIATE type2xmltable (package_name,
                                         't_ndi_post_office',
                                         TRUE)
            BULK COLLECT INTO l_arr
            USING p_xml;

        IF (p_ns_id IS NULL OR p_ns_id = -1)
        THEN
            INSERT INTO v_ndi_street (ns_code,
                                      ns_name,
                                      ns_kaot,
                                      ns_nsrt,
                                      history_status,
                                      ns_org)
                 VALUES (p_ns_code,
                         p_ns_name,
                         p_ns_kaot,
                         p_ns_nsrt,
                         COALESCE (p_history_status, 'A'),
                         p_ns_org)
              RETURNING ns_id
                   INTO p_new_id;

            FOR xx IN (SELECT * FROM TABLE (l_arr))
            LOOP
                INSERT INTO v_ndi_npo_config (nnc_ns, nnc_npo)
                     VALUES (p_new_id, xx.npo_id);
            END LOOP;
        ELSE
            p_new_id := p_ns_id;

            UPDATE ndi_street
               SET ns_code = p_ns_code,
                   ns_name = p_ns_name,
                   ns_kaot = p_ns_kaot,
                   ns_nsrt = p_ns_nsrt,
                   ns_org = p_ns_org,
                   history_status = p_history_status
             WHERE ns_id = p_ns_id;

            SELECT LISTAGG (npo_id, ',') WITHIN GROUP (ORDER BY 1)
              INTO l_ids
              FROM TABLE (l_arr)
             WHERE npo_id IS NOT NULL;

            -- удаление записей которых нет в новой таблице
            DELETE v_ndi_npo_config t
             WHERE     t.nnc_ns = p_new_id
                   AND (   l_ids IS NULL
                        OR t.nnc_npo NOT IN
                               (    SELECT REGEXP_SUBSTR (
                                               text,
                                               '[^(\,)]+',
                                               1,
                                               LEVEL)    AS z_rdt_id
                                      FROM (SELECT l_ids AS text FROM DUAL)
                                CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                                  '[^(\,)]+',
                                                                  1,
                                                                  LEVEL)) > 0));

            -- добавить новые записи с таблицы с контролем дублей

            /* INSERT INTO v_ndi_npo_config (nnc_ns, nnc_npo)
            SELECT p_new_id  , l.npo_id
            FROM TABLE(l_arr) l
            WHERE NOT EXISTS( select * from v_ndi_npo_config c
                              where c.nnc_npo= l.npo_id and c.nnc_ns=p_new_id); */

            FOR xx
                IN (SELECT *
                      FROM TABLE (l_arr) l
                     WHERE NOT EXISTS
                               (SELECT *
                                  FROM v_ndi_npo_config c
                                 WHERE     c.nnc_npo = l.npo_id
                                       AND c.nnc_ns = p_new_id))
            LOOP
                INSERT INTO v_ndi_npo_config (nnc_ns, nnc_npo)
                     VALUES (p_new_id, xx.npo_id);
            END LOOP;
        -- updated

        /* FOR xx IN (SELECT * FROM TABLE(l_arr) t WHERE t.npo_id > 0) LOOP
          UPDATE v_ndi_npo_config
          SET
            nnc_npo  = xx.npo_id ,
          where nnc_nc = xx.dppa_id;
        END LOOP; */

        END IF;
    END;


    PROCEDURE Delete_Street (
        p_NS_ID            NDI_STREET.NS_ID%TYPE,
        p_History_Status   NDI_STREET.HISTORY_STATUS%TYPE)
    IS
    BEGIN
        UPDATE NDI_STREET
           SET HISTORY_STATUS = p_History_Status
         WHERE NS_ID = p_NS_ID;
    END;

    PROCEDURE Set_Street_Kaot (p_kaot_id   IN ndi_street.ns_id%TYPE,
                               p_ids       IN VARCHAR2)
    IS
    BEGIN
        UPDATE ndi_street t
           SET t.ns_kaot = p_kaot_id
         WHERE t.ns_id IN (    SELECT REGEXP_SUBSTR (text,
                                                     '[^(\,)]+',
                                                     1,
                                                     LEVEL)    AS z_rdt_id
                                 FROM (SELECT p_ids AS text FROM DUAL)
                           CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                             '[^(\,)]+',
                                                             1,
                                                             LEVEL)) > 0);
    END;

    --===============================================
    --                NDI_KEKV
    --===============================================

    PROCEDURE Save_KEKV (
        p_NKV_ID           IN     NDI_KEKV.NKV_ID%TYPE,
        p_NKV_NKV          IN     NDI_KEKV.NKV_NKV%TYPE,
        p_NKV_CODE         IN     NDI_KEKV.NKV_CODE%TYPE,
        p_NKV_NAME         IN     NDI_KEKV.NKV_NAME%TYPE,
        p_NKV_SNAME        IN     NDI_KEKV.NKV_SNAME%TYPE,
        p_HISTORY_STATUS   IN     NDI_KEKV.HISTORY_STATUS%TYPE,
        p_new_id              OUT NDI_KEKV.NKV_ID%TYPE)
    IS
    BEGIN
        IF p_NKV_ID IS NULL
        THEN
            INSERT INTO NDI_KEKV (NKV_NKV,
                                  NKV_CODE,
                                  NKV_NAME,
                                  NKV_SNAME,
                                  HISTORY_STATUS)
                 VALUES (p_NKV_NKV,
                         p_NKV_CODE,
                         p_NKV_NAME,
                         p_NKV_SNAME,
                         p_HISTORY_STATUS)
              RETURNING NKV_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_NKV_ID;

            UPDATE NDI_KEKV
               SET NKV_NKV = p_NKV_NKV,
                   NKV_CODE = p_NKV_CODE,
                   NKV_NAME = p_NKV_NAME,
                   NKV_SNAME = p_NKV_SNAME,
                   HISTORY_STATUS = p_HISTORY_STATUS
             WHERE NKV_ID = p_NKV_ID;
        END IF;
    END;

    PROCEDURE Delete_KEKV (p_NKV_ID           NDI_KEKV.NKV_ID%TYPE,
                           p_History_Status   NDI_KEKV.HISTORY_STATUS%TYPE)
    IS
    BEGIN
        UPDATE NDI_KEKV
           SET HISTORY_STATUS = p_History_Status
         WHERE NKV_ID = p_NKV_ID;
    END;

    --===============================================
    --                NDI_DELIVERY
    --===============================================
    /*
      PROCEDURE Save_Delivery(
        p_ND_ID IN NDI_DELIVERY.ND_ID%TYPE,
        p_ND_CODE IN NDI_DELIVERY.ND_CODE%TYPE,
        p_ND_COMMENT IN NDI_DELIVERY.ND_COMMENT%TYPE,
        p_ND_NPO IN NDI_DELIVERY.ND_NPO%TYPE,
        p_HISTORY_STATUS IN NDI_DELIVERY.HISTORY_STATUS%TYPE,
        p_ND_TP IN NDI_DELIVERY.ND_TP%TYPE,
        p_new_id out NDI_DELIVERY.ND_ID%TYPE)
        IS
      BEGIN
          IF p_ND_ID IS NULL THEN
      INSERT INTO NDI_DELIVERY
           (
        ND_CODE,
        ND_COMMENT,
        ND_NPO,
        ND_ST,
        HISTORY_STATUS,
        ND_TP
           )
         VALUES
           (
        p_ND_CODE,
        p_ND_COMMENT,
        p_ND_NPO,
        'A',
        p_HISTORY_STATUS,
        p_ND_TP
           )
         RETURNING ND_ID INTO p_new_id;
       ELSE
         p_new_id := p_ND_ID;

         UPDATE NDI_DELIVERY
            SET
         ND_CODE = p_ND_CODE,
        ND_COMMENT = p_ND_COMMENT,
        ND_NPO = p_ND_NPO,
        HISTORY_STATUS = p_HISTORY_STATUS,
        ND_TP = p_ND_TP
          WHERE ND_ID = p_ND_ID;
       END IF;
      END;

       PROCEDURE Delete_Delivery(p_ND_ID NDI_DELIVERY.ND_ID%TYPE,
                             p_History_Status NDI_DELIVERY.HISTORY_STATUS%TYPE) IS l_HsId NUMBER;
       BEGIN
         l_HsId := tools.GetHistSession;

       UPDATE NDI_DELIVERY
          SET HISTORY_STATUS = p_History_Status, ND_HS_DEL = l_HsId
        WHERE ND_ID = p_ND_ID;
       END; */

    --===============================================
    --                NDI_NB_FILIA
    --===============================================

    PROCEDURE Save_Nb_Filia (
        p_NBF_ID           IN     NDI_NB_FILIA.NBF_ID%TYPE,
        p_NBF_NB           IN     NDI_NB_FILIA.NBF_NB%TYPE,
        p_NBF_NAME         IN     NDI_NB_FILIA.NBF_NAME%TYPE,
        p_NBF_SNAME        IN     NDI_NB_FILIA.NBF_SNAME%TYPE,
        p_NBF_ORG          IN     NDI_NB_FILIA.NBF_ORG%TYPE,
        p_HISTORY_STATUS   IN     NDI_NB_FILIA.HISTORY_STATUS%TYPE,
        p_NBF_CODE         IN     NDI_NB_FILIA.NBF_CODE%TYPE,
        p_new_id              OUT NDI_NB_FILIA.NBF_ID%TYPE)
    IS
    BEGIN
        IF p_NBF_ID IS NULL
        THEN
            INSERT INTO NDI_NB_FILIA (NBF_NB,
                                      NBF_NAME,
                                      NBF_SNAME,
                                      NBF_ORG,
                                      HISTORY_STATUS,
                                      NBF_CODE)
                 VALUES (p_NBF_NB,
                         p_NBF_NAME,
                         p_NBF_SNAME,
                         p_NBF_ORG,
                         p_HISTORY_STATUS,
                         p_NBF_CODE)
              RETURNING NBF_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_NBF_ID;

            UPDATE NDI_NB_FILIA
               SET NBF_NB = p_NBF_NB,
                   NBF_NAME = p_NBF_NAME,
                   NBF_SNAME = p_NBF_SNAME,
                   NBF_ORG = p_NBF_ORG,
                   HISTORY_STATUS = p_HISTORY_STATUS,
                   NBF_CODE = p_NBF_CODE
             WHERE NBF_ID = p_NBF_ID;
        END IF;
    END;

    PROCEDURE Delete_Nb_Filia (
        p_NBF_ID           NDI_NB_FILIA.NBF_ID%TYPE,
        p_History_Status   NDI_NB_FILIA.HISTORY_STATUS%TYPE)
    IS
    BEGIN
        UPDATE NDI_NB_FILIA
           SET HISTORY_STATUS = p_History_Status
         WHERE NBF_ID = p_NBF_ID;
    END;

    --===============================================
    --                NDI_BUDGET
    --===============================================

    PROCEDURE save_budget (
        p_nbu_id           IN     ndi_budget.nbu_id%TYPE,
        p_nbu_tp           IN     ndi_budget.nbu_tp%TYPE,
        p_nbu_code         IN     ndi_budget.nbu_code%TYPE,
        p_nbu_name         IN     ndi_budget.nbu_name%TYPE,
        p_history_status   IN     ndi_budget.history_status%TYPE,
        p_nbu_hs_upd       IN     ndi_budget.nbu_hs_upd%TYPE,
        p_nbu_hs_del       IN     ndi_budget.nbu_hs_del%TYPE,
        p_new_id              OUT ndi_budget.nbu_id%TYPE)
    IS
    BEGIN
        IF p_nbu_id IS NULL
        THEN
            INSERT INTO ndi_budget (nbu_tp,
                                    nbu_code,
                                    nbu_name,
                                    history_status,
                                    nbu_hs_upd,
                                    nbu_hs_del)
                 VALUES (p_nbu_tp,
                         p_nbu_code,
                         p_nbu_name,
                         p_history_status,
                         p_nbu_hs_upd,
                         p_nbu_hs_del)
              RETURNING nbu_id
                   INTO p_new_id;
        ELSE
            p_new_id := p_nbu_id;

            UPDATE ndi_budget
               SET nbu_tp = p_nbu_tp,
                   nbu_code = p_nbu_code,
                   nbu_name = p_nbu_name,
                   history_status = p_history_status,
                   nbu_hs_upd = tools.gethistsession,
                   nbu_hs_del = p_nbu_hs_del
             WHERE nbu_id = p_nbu_id;
        END IF;
    END;

    PROCEDURE delete_budget (p_nbu_id ndi_budget.nbu_id%TYPE)
    IS
    BEGIN
        UPDATE ndi_budget b
           SET b.nbu_hs_del = tools.gethistsession,
               b.history_status = api$dic_visit.c_history_status_historical
         WHERE b.nbu_id = p_nbu_id;
    END;

    --===============================================
    --                NDI_FUNDING_SOURCE
    --===============================================

    PROCEDURE save_funding_source (
        p_nfs_id           IN     ndi_funding_source.nfs_id%TYPE,
        p_nfs_nbg          IN     ndi_funding_source.nfs_nbg%TYPE,
        p_nfs_nbu          IN     ndi_funding_source.nfs_nbu%TYPE,
        p_nfs_name         IN     ndi_funding_source.nfs_name%TYPE,
        p_nfs_tp           IN     ndi_funding_source.nfs_tp%TYPE,
        p_history_status   IN     ndi_funding_source.history_status%TYPE,
        p_nfs_hs_upd       IN     ndi_funding_source.nfs_hs_upd%TYPE,
        p_nfs_hs_del       IN     ndi_funding_source.nfs_hs_del%TYPE,
        p_new_id              OUT ndi_funding_source.nfs_id%TYPE)
    IS
    BEGIN
        IF p_nfs_id IS NULL
        THEN
            INSERT INTO ndi_funding_source (nfs_nbg,
                                            nfs_nbu,
                                            nfs_name,
                                            nfs_tp,
                                            history_status,
                                            nfs_hs_upd,
                                            nfs_hs_del)
                 VALUES (p_nfs_nbg,
                         p_nfs_nbu,
                         p_nfs_name,
                         p_nfs_tp,
                         p_history_status,
                         p_nfs_hs_upd,
                         p_nfs_hs_del)
              RETURNING nfs_id
                   INTO p_new_id;
        ELSE
            p_new_id := p_nfs_id;

            UPDATE ndi_funding_source
               SET nfs_nbg = p_nfs_nbg,
                   nfs_nbu = p_nfs_nbu,
                   nfs_name = p_nfs_name,
                   nfs_tp = p_nfs_tp,
                   history_status = p_history_status,
                   nfs_hs_upd = tools.gethistsession,
                   nfs_hs_del = p_nfs_hs_del
             WHERE nfs_id = p_nfs_id;
        END IF;
    END;


    PROCEDURE delete_funding_source (p_nfs_id ndi_funding_source.nfs_id%TYPE)
    IS
    BEGIN
        UPDATE ndi_funding_source fc
           SET fc.nfs_hs_del = tools.gethistsession,
               fc.history_status = api$dic_visit.c_history_status_historical
         WHERE fc.nfs_id = p_nfs_id;
    END;


    --===============================================
    --                NDI_MIN_ZP
    --===============================================



    PROCEDURE save_ndi_min_zp (
        p_nmz_start_dt    IN ndi_min_zp.nmz_start_dt%TYPE,
        p_nmz_stop_dt     IN ndi_min_zp.nmz_stop_dt%TYPE,
        p_nmz_month_sum   IN ndi_min_zp.nmz_month_sum%TYPE,
        p_nmz_hour_sum    IN ndi_min_zp.nmz_hour_sum%TYPE)
    IS
        l_hsid   NUMBER;
    BEGIN
        l_hsid := tools.gethistsession;

        INSERT INTO tmp_unh_old_list (ol_obj,
                                      ol_hst,
                                      ol_begin,
                                      ol_end)
            SELECT 0,
                   h.nmz_id,
                   h.nmz_start_dt,
                   h.nmz_stop_dt
              FROM v_ndi_min_zp h
             WHERE h.history_status = 'A';

        -- формування історії
        api$hist.setup_history (0, p_nmz_start_dt, p_nmz_stop_dt);

        -- закриття недіючих
        UPDATE v_ndi_min_zp h
           SET h.nmz_hs_del = l_hsid, h.history_status = 'H'
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_unh_to_prp
                     WHERE tprp_hst = h.nmz_id);

        -- додавання нових періодів
        INSERT INTO v_ndi_min_zp (nmz_id,
                                  nmz_start_dt,
                                  nmz_stop_dt,
                                  nmz_month_sum,
                                  nmz_hour_sum,
                                  nmz_hs_ins,
                                  history_status)
            SELECT 0,
                   rz.rz_begin,
                   rz.rz_end,
                   ho.nmz_month_sum,
                   ho.nmz_hour_sum,
                   l_hsid,
                   'A'
              FROM tmp_unh_rz_list rz, v_ndi_min_zp ho
             WHERE     rz.rz_hst <> 0
                   AND (rz_begin <= rz_end OR rz_end IS NULL)
                   AND ho.nmz_id = rz_hst
            UNION
            SELECT 0,
                   p_nmz_start_dt,
                   p_nmz_stop_dt,
                   p_nmz_month_sum,
                   p_nmz_hour_sum,
                   l_hsid,
                   'A'
              FROM tmp_unh_rz_list rl
             WHERE rz_hst = 0 AND (rz_begin <= rz_end OR rz_end IS NULL);
    END;

    PROCEDURE delete_ndi_min_zp (p_nmz_id ndi_min_zp.nmz_id%TYPE)
    IS
    BEGIN
        UPDATE ndi_min_zp m
           SET m.nmz_hs_del = tools.gethistsession,
               m.history_status = api$dic_visit.c_history_status_historical
         WHERE m.nmz_id = p_nmz_id;
    END;

    --===============================================
    --                NDI_LGW_SUB_LEVEL
    --===============================================
    PROCEDURE save_lgw_sub_level (
        p_nlsl_start_dt            IN ndi_lgw_sub_level.nlsl_start_dt%TYPE,
        p_nlsl_stop_dt             IN ndi_lgw_sub_level.nlsl_stop_dt%TYPE,
        p_nlsl_18year_level        IN ndi_lgw_sub_level.nlsl_18year_level%TYPE,
        p_nlsl_work_able_level     IN ndi_lgw_sub_level.nlsl_work_able_level%TYPE,
        p_nlsl_work_unable_level   IN ndi_lgw_sub_level.nlsl_work_unable_level%TYPE)
    IS
        l_hsid   NUMBER;
    BEGIN
        l_hsid := tools.gethistsession;

        INSERT INTO tmp_unh_old_list (ol_obj,
                                      ol_hst,
                                      ol_begin,
                                      ol_end)
            SELECT 0,
                   h.nlsl_id,
                   h.nlsl_start_dt,
                   h.nlsl_stop_dt
              FROM v_ndi_lgw_sub_level h
             WHERE h.history_status = 'A';

        -- формування історії
        api$hist.setup_history (0, p_nlsl_start_dt, p_nlsl_stop_dt);

        -- закриття недіючих
        UPDATE v_ndi_lgw_sub_level h
           SET h.nlsl_hs_del = l_hsid, h.history_status = 'H'
         WHERE EXISTS
                   (SELECT 1
                      FROM tmp_unh_to_prp
                     WHERE tprp_hst = h.nlsl_id);

        -- додавання нових періодів
        INSERT INTO v_ndi_lgw_sub_level (nlsl_id,
                                         nlsl_start_dt,
                                         nlsl_stop_dt,
                                         nlsl_18year_level,
                                         nlsl_work_able_level,
                                         nlsl_work_unable_level,
                                         nlsl_hs_ins,
                                         history_status)
            SELECT 0,
                   rz.rz_begin,
                   rz.rz_end,
                   ho.nlsl_18year_level,
                   ho.nlsl_work_able_level,
                   ho.nlsl_work_unable_level,
                   l_hsid,
                   'A'
              FROM tmp_unh_rz_list rz, v_ndi_lgw_sub_level ho
             WHERE     rz.rz_hst <> 0
                   AND (rz_begin <= rz_end OR rz_end IS NULL)
                   AND ho.nlsl_id = rz_hst
            UNION
            SELECT 0,
                   p_nlsl_start_dt,
                   p_nlsl_stop_dt,
                   p_nlsl_18year_level,
                   p_nlsl_work_able_level,
                   p_nlsl_work_unable_level,
                   l_hsid,
                   'A'
              FROM tmp_unh_rz_list rl
             WHERE rz_hst = 0 AND (rz_begin <= rz_end OR rz_end IS NULL);
    END;

    PROCEDURE delete_lgw_sub_level (p_nlsl_id ndi_lgw_sub_level.nlsl_id%TYPE)
    IS
    BEGIN
        UPDATE ndi_lgw_sub_level l
           SET l.nlsl_hs_del = tools.gethistsession,
               l.history_status = api$dic_visit.c_history_status_historical
         WHERE l.nlsl_id = p_nlsl_id;
    END;

    --===============================================
    --                NDI_FIN_PAY_CONFIG
    --===============================================

    PROCEDURE save_ndi_pay_config (
        p_nfpc_id       IN     ndi_fin_pay_config.nfpc_id%TYPE,
        p_nfpc_pay_tp   IN     ndi_fin_pay_config.nfpc_pay_tp%TYPE,
        p_nfpc_nb       IN     ndi_fin_pay_config.nfpc_nb%TYPE,
        p_nfpc_ncn      IN     ndi_fin_pay_config.nfpc_ncn%TYPE,
        p_nfpc_dppa     IN     ndi_fin_pay_config.nfpc_dppa%TYPE,
        p_new_id           OUT ndi_fin_pay_config.nfpc_id%TYPE)
    IS
    BEGIN
        IF p_nfpc_id IS NULL
        THEN
            INSERT INTO ndi_fin_pay_config (nfpc_pay_tp,
                                            nfpc_nb,
                                            nfpc_ncn,
                                            nfpc_dppa,
                                            history_status,
                                            nfpc_hs_upd,
                                            nfpc_hs_del,
                                            com_org)
                 VALUES (p_nfpc_pay_tp,
                         p_nfpc_nb,
                         p_nfpc_ncn,
                         p_nfpc_dppa,
                         api$dic_visit.c_history_status_actual,
                         tools.gethistsession,
                         NULL,
                         tools.getcurrorg)
              RETURNING nfpc_id
                   INTO p_new_id;
        ELSE
            p_new_id := p_nfpc_id;

            UPDATE ndi_fin_pay_config
               SET nfpc_pay_tp = p_nfpc_pay_tp,
                   nfpc_nb = p_nfpc_nb,
                   nfpc_ncn = p_nfpc_ncn,
                   nfpc_dppa = p_nfpc_dppa,
                   history_status = api$dic_visit.c_history_status_actual,
                   nfpc_hs_upd = tools.gethistsession,
                   nfpc_hs_del = NULL,
                   com_org = tools.getcurrorg
             WHERE nfpc_id = p_nfpc_id;
        END IF;
    END;

    PROCEDURE delete_ndi_pay_config (
        p_nfpc_id   ndi_fin_pay_config.nfpc_id%TYPE)
    IS
    BEGIN
        UPDATE v_ndi_fin_pay_config fpc
           SET fpc.history_status = api$dic_visit.c_history_status_historical,
               fpc.nfpc_hs_del = tools.gethistsession
         WHERE nfpc_id = p_nfpc_id;
    END;


    PROCEDURE delete_ndi_site (p_nis_id NDI_SITE.NIS_ID%TYPE)
    IS
    BEGIN
        UPDATE NDI_SITE s
           SET s.history_status = api$dic_visit.c_history_status_historical
         WHERE s.nis_id = p_nis_id;
    END;

    PROCEDURE save_ndi_site (p_nis_id      IN     ndi_site.nis_id%TYPE,
                             p_nis_name    IN     ndi_site.nis_name%TYPE,
                             p_nis_order   IN     ndi_site.nis_order%TYPE,
                             p_new_id         OUT ndi_site.nis_id%TYPE)
    IS
    BEGIN
        IF p_nis_id IS NULL
        THEN
            INSERT INTO ndi_site (nis_name,
                                  nis_order,
                                  com_org,
                                  history_status)
                 VALUES (p_nis_name,
                         p_nis_order,
                         tools.GetCurrOrg,
                         api$dic_visit.c_History_Status_Actual)
              RETURNING nis_id
                   INTO p_new_id;
        ELSE
            p_new_id := p_nis_id;

            UPDATE ndi_site
               SET nis_name = p_nis_name, nis_order = p_nis_order
             WHERE nis_id = p_nis_id;
        END IF;
    END;

    PROCEDURE delete_ndi_nis_user (p_nisu_id ndi_nis_users.nisu_id%TYPE)
    IS
    BEGIN
        UPDATE ndi_nis_users nu
           SET nu.history_status = api$dic_visit.c_history_status_historical
         WHERE nu.nisu_id = p_nisu_id;
    END;

    PROCEDURE set_one_user (
        p_wu_id           ikis_sysweb.v$all_users.wu_id%TYPE,
        p_nis_id   IN     ndi_site.nis_id%TYPE,
        p_new_id      OUT ndi_nis_users.nisu_id%TYPE)
    IS
    BEGIN
        UPDATE ndi_nis_users nu
           SET nu.history_status = api$dic_visit.c_history_status_historical
         WHERE     nu.nisu_wu = p_wu_id
               AND nu.history_status = api$dic_visit.c_History_Status_Actual;

        INSERT INTO ndi_nis_users (nisu_nis, nisu_wu, history_status)
             VALUES (p_nis_id,
                     p_wu_id,
                     api$dic_visit.c_History_Status_Actual)
          RETURNING nisu_id
               INTO p_new_id;
    END;

    PROCEDURE save_normative_act (
        p_nna_id            IN     ndi_normative_act.nna_id%TYPE,
        p_nna_tp            IN     ndi_normative_act.nna_tp%TYPE,
        p_nna_publisher     IN     ndi_normative_act.nna_publisher%TYPE,
        p_nna_dt            IN     ndi_normative_act.nna_dt%TYPE,
        p_nna_num           IN     ndi_normative_act.nna_num%TYPE,
        p_nna_description   IN     ndi_normative_act.nna_description%TYPE,
        p_nna_url           IN     ndi_normative_act.nna_url%TYPE,
        p_nna_asof_dt       IN     ndi_normative_act.nna_asof_dt%TYPE,
        p_nna_start_dt      IN     ndi_normative_act.nna_start_dt%TYPE,
        p_nna_nna_main      IN     ndi_normative_act.nna_nna_main%TYPE,
        p_new_id               OUT ndi_normative_act.nna_id%TYPE)
    IS
    BEGIN
        IF p_nna_id IS NULL
        THEN
            INSERT INTO ndi_normative_act (nna_tp,
                                           nna_publisher,
                                           nna_dt,
                                           nna_num,
                                           nna_description,
                                           nna_url,
                                           nna_asof_dt,
                                           nna_hs_upd,
                                           nna_start_dt,
                                           history_status,
                                           nna_nna_main)
                 VALUES (p_nna_tp,
                         p_nna_publisher,
                         p_nna_dt,
                         p_nna_num,
                         p_nna_description,
                         p_nna_url,
                         p_nna_asof_dt,
                         tools.gethistsession,
                         p_nna_start_dt,
                         'A',
                         p_nna_nna_main)
              RETURNING nna_id
                   INTO p_new_id;
        ELSE
            p_new_id := p_nna_id;

            UPDATE ndi_normative_act
               SET nna_tp = p_nna_tp,
                   nna_publisher = p_nna_publisher,
                   nna_dt = p_nna_dt,
                   nna_num = p_nna_num,
                   nna_description = p_nna_description,
                   nna_url = p_nna_url,
                   nna_asof_dt = p_nna_asof_dt,
                   nna_hs_upd = tools.gethistsession,
                   nna_start_dt = p_nna_start_dt,
                   history_status = 'A',
                   nna_nna_main = p_nna_nna_main
             WHERE nna_id = p_nna_id;
        END IF;
    END;

    PROCEDURE delete_normative_act (p_nna_id ndi_normative_act.nna_id%TYPE)
    IS
    BEGIN
        UPDATE ndi_normative_act b
           SET b.nna_hs_del = tools.gethistsession, b.history_status = 'H'
         WHERE b.nna_id = p_nna_id;
    END;

    FUNCTION Get_Nda_Id (p_Ndt_Id IN NUMBER, p_Nda_Class IN VARCHAR2)
        RETURN NUMBER
    IS
        l_Nda_Id   NUMBER;
    BEGIN
        SELECT MAX (a.Nda_Id)
          INTO l_Nda_Id
          FROM Uss_Ndi.v_Ndi_Document_Attr a
         WHERE a.Nda_Ndt = p_Ndt_Id AND a.Nda_Class = p_Nda_Class;

        RETURN l_Nda_Id;
    END;

    -- Завантаження вулиць з АСОПД
    -- IC #90439
    PROCEDURE set_street (
        p_ns_id            IN     ndi_street.ns_id%TYPE,
        p_ns_code          IN     ndi_street.ns_code%TYPE,
        p_ns_name          IN     ndi_street.ns_name%TYPE,
        p_ns_kaot          IN     ndi_street.ns_kaot%TYPE,
        p_ns_nsrt          IN     ndi_street.ns_nsrt%TYPE,
        p_ns_org           IN     ndi_street.ns_org%TYPE,
        p_history_status   IN     ndi_street.history_status%TYPE,
        p_new_id              OUT ndi_street.ns_id%TYPE)
    IS
        l_code_exists   NUMBER;
        l_ns_code       VARCHAR2 (10) := p_ns_code;
    BEGIN
        --Контроль уникальности кода
        SELECT SIGN (COUNT (*))
          INTO l_code_exists
          FROM v_ndi_street nd
         WHERE     nd.ns_code = p_ns_code
               AND nd.ns_org = P_NS_ORG
               AND (p_ns_id IS NULL                 /*OR nd.ns_id != p_ns_id*/
                                   ) -- прибираю, оскільки в довіднику куча дублів
               AND nd.history_status = 'A';

        IF l_code_exists = 1
        THEN
            raise_application_error (
                -20001,
                'Вулиця з кодом: ' || p_ns_code || '  вже існує');
        END IF;

        IF (p_ns_id IS NULL AND p_ns_code IS NULL)
        THEN
            SELECT TO_CHAR (MAX (TO_NUMBER (t.ns_code)) + 1)
              INTO l_ns_code
              FROM ndi_street t
             WHERE t.history_status = 'A';
        ELSE
            l_ns_code := p_ns_code;
        END IF;

        IF NVL (p_ns_id, -1) = -1
        THEN
            INSERT INTO v_ndi_street (ns_code,
                                      ns_name,
                                      ns_kaot,
                                      ns_nsrt,
                                      history_status,
                                      ns_org)
                 VALUES (l_ns_code,
                         p_ns_name,
                         p_ns_kaot,
                         p_ns_nsrt,
                         COALESCE (p_history_status, 'A'),
                         p_ns_org)
              RETURNING ns_id
                   INTO p_new_id;
        ELSE
            p_new_id := p_ns_id;

            INSERT INTO v_ndi_street (ns_code,
                                      ns_name,
                                      ns_kaot,
                                      ns_nsrt,
                                      history_status,
                                      ns_org)
                SELECT ns_code,
                       ns_name,
                       ns_kaot,
                       ns_nsrt,
                       'H'     history_status,
                       ns_org
                  FROM v_ndi_street
                 WHERE ns_id = p_ns_id;

            UPDATE ndi_street
               SET ns_code = NVL (p_ns_code, ns_code),
                   ns_name = NVL (p_ns_name, ns_name),
                   ns_kaot = NVL (p_ns_kaot, ns_kaot),
                   ns_nsrt = NVL (p_ns_nsrt, ns_nsrt),
                   ns_org = NVL (p_ns_org, ns_org),
                   history_status = p_history_status
             WHERE ns_id = p_ns_id;
        END IF;
    END set_street;
END API$DIC_DOCUMENT;
/