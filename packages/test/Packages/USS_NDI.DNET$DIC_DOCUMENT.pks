/* Formatted on 8/12/2025 5:55:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.DNET$DIC_DOCUMENT
IS
    -- Author  : OLEH
    -- Created : 15.07.2021 14:31:34
    -- Purpose :

    --===============================================
    --                NDI_TYPE
    --===============================================

    PROCEDURE get_ndi_document_type (
        p_id    IN     ndi_document_type.ndt_id%TYPE,
        p_res      OUT SYS_REFCURSOR);

    PROCEDURE save_ndi_document_type (
        p_ndt_id              IN     ndi_document_type.ndt_id%TYPE,
        p_ndt_ndc             IN     ndi_document_type.ndt_ndc%TYPE,
        p_ndt_name            IN     ndi_document_type.ndt_name%TYPE,
        p_ndt_name_short      IN     ndi_document_type.ndt_name_short%TYPE,
        p_ndt_order           IN     ndi_document_type.ndt_order%TYPE,
        p_ndt_is_have_scan    IN     ndi_document_type.ndt_is_have_scan%TYPE,
        p_ndt_is_vt_visible   IN     ndi_document_type.ndt_is_vt_visible%TYPE,
        p_new_id                 OUT ndi_document_type.ndt_id%TYPE);

    PROCEDURE delete_ndi_document_type (p_id ndi_document_type.ndt_id%TYPE);

    PROCEDURE query_ndi_document_type (
        p_ndt_name            IN     VARCHAR2,
        p_ndt_name_short      IN     VARCHAR2,
        p_ndc_id              IN     NUMBER,
        p_ndt_is_have_scan    IN     VARCHAR2,
        p_ndt_is_vt_visible   IN     VARCHAR2,
        p_res                    OUT SYS_REFCURSOR);

    -- Author  : OLEH
    -- Created : 20.07.2021
    -- Purpose :

    --===============================================
    --                NDI_CLASS
    --===============================================

    PROCEDURE GET_NDI_DOCUMENT_CLASS (
        P_ID    IN     NDI_DOCUMENT_CLASS.NDC_ID%TYPE,
        P_RES      OUT SYS_REFCURSOR);

    PROCEDURE SAVE_NDI_DOCUMENT_CLASS (
        P_NDC_ID            IN     NDI_DOCUMENT_CLASS.NDC_ID%TYPE,
        P_NDC_NAME          IN     NDI_DOCUMENT_CLASS.NDC_NAME%TYPE,
        P_NDC_NAME_SHORT    IN     NDI_DOCUMENT_CLASS.NDC_NAME_SHORT%TYPE,
        P_NDC_CODE          IN     NDI_DOCUMENT_CLASS.NDC_CODE%TYPE,
        P_NDC_ORDER         IN     NDI_DOCUMENT_CLASS.NDC_ORDER%TYPE,
        P_NDC_DESCRIPTION   IN     NDI_DOCUMENT_CLASS.NDC_DESCRIPTION%TYPE,
        P_NEW_ID               OUT NDI_DOCUMENT_CLASS.NDC_ID%TYPE);

    PROCEDURE DELETE_NDI_DOCUMENT_CLASS (P_ID NDI_DOCUMENT_CLASS.NDC_ID%TYPE);

    PROCEDURE QUERY_NDI_DOCUMENT_CLASS (
        P_NDC_NAME          IN     VARCHAR2,
        P_NDC_NAME_SHORT    IN     VARCHAR2,
        P_NDC_DESCRIPTION   IN     VARCHAR2,
        P_NDC_CODE          IN     VARCHAR2,
        P_RES                  OUT SYS_REFCURSOR);

    --===============================================
    --                NDI_NDA_GROUP
    --===============================================

    PROCEDURE GET_NDI_NDA_GROUP (P_ID    IN     NDI_NDA_GROUP.NNG_ID%TYPE,
                                 P_RES      OUT SYS_REFCURSOR);

    PROCEDURE SAVE_NDI_NDA_GROUP (
        P_NNG_ID            IN     NDI_NDA_GROUP.NNG_ID%TYPE,
        P_NNG_NAME          IN     NDI_NDA_GROUP.NNG_NAME%TYPE,
        P_NNG_OPEN_BY_DEF   IN     NDI_NDA_GROUP.NNG_OPEN_BY_DEF%TYPE,
        P_NNG_ORDER         IN     NDI_NDA_GROUP.NNG_ORDER%TYPE,
        P_NEW_ID               OUT NDI_NDA_GROUP.NNG_ID%TYPE);

    PROCEDURE DELETE_NDI_NDA_GROUP (P_ID NDI_NDA_GROUP.NNG_ID%TYPE);

    PROCEDURE QUERY_NDI_NDA_GROUP (P_NNG_NAME          IN     VARCHAR2,
                                   P_NNG_OPEN_BY_DEF   IN     VARCHAR2,
                                   P_RES                  OUT SYS_REFCURSOR);

    --===============================================
    --                NDI_DOCUMENT_ATTR
    --===============================================

    PROCEDURE SAVE_NDI_DOCUMENT_ATTR (
        P_NDA_ID          IN     NDI_DOCUMENT_ATTR.NDA_ID%TYPE,
        P_NDA_NDT         IN     NDI_DOCUMENT_ATTR.NDA_NDT%TYPE,
        P_NDA_NAME        IN     NDI_DOCUMENT_ATTR.NDA_NAME%TYPE,
        P_NDA_ORDER       IN     NDI_DOCUMENT_ATTR.NDA_ORDER%TYPE,
        P_NDA_IS_KEY      IN     NDI_DOCUMENT_ATTR.NDA_IS_KEY%TYPE,
        P_NDA_PT          IN     NDI_DOCUMENT_ATTR.NDA_PT%TYPE,
        P_NDA_IS_REQ      IN     NDI_DOCUMENT_ATTR.NDA_IS_REQ%TYPE,
        P_NDA_DEF_VALUE   IN     NDI_DOCUMENT_ATTR.NDA_DEF_VALUE%TYPE,
        P_NDA_CAN_EDIT    IN     NDI_DOCUMENT_ATTR.NDA_CAN_EDIT%TYPE,
        P_NDA_NEED_SHOW   IN     NDI_DOCUMENT_ATTR.NDA_NEED_SHOW%TYPE,
        P_NDA_CLASS       IN     NDI_DOCUMENT_ATTR.NDA_CLASS%TYPE,
        P_NDA_NNG         IN     NDI_DOCUMENT_ATTR.NDA_NNG%TYPE,
        p_nac_ap_tp       IN     ndi_nda_config.nac_ap_tp%TYPE,
        p_nst_list        IN     VARCHAR2,
        P_NEW_ID             OUT NDI_DOCUMENT_ATTR.NDA_ID%TYPE);

    PROCEDURE DELETE_NDI_DOCUMENT_ATTR (
        P_NDA_ID   NDI_DOCUMENT_ATTR.NDA_ID%TYPE);

    PROCEDURE GET_NDI_DOCUMENT_ATTR (
        P_NDA_ID   IN     NDI_DOCUMENT_ATTR.NDA_ID%TYPE,
        P_RES         OUT SYS_REFCURSOR);

    PROCEDURE QUERY_NDI_DOCUMENT_ATTR (
        P_NDA_NDT         IN     NUMBER,
        P_NDA_NAME        IN     VARCHAR2,
        P_NDA_IS_KEY      IN     VARCHAR2,
        P_NDA_PT          IN     NUMBER,
        P_NDA_IS_REQ      IN     VARCHAR2,
        P_NDA_DEF_VALUE   IN     VARCHAR2,
        P_NDA_CAN_EDIT    IN     VARCHAR2,
        P_NDA_NEED_SHOW   IN     VARCHAR2,
        P_NDA_CLASS       IN     VARCHAR2,
        P_NDA_NNG         IN     NUMBER,
        P_RES                OUT SYS_REFCURSOR);

    --===============================================
    --                NDI_DIC_DV
    --===============================================

    PROCEDURE GET_DIC_DV (P_DIC_DIDI   IN     DIC_DV.DIC_DIDI%TYPE,
                          P_RES           OUT SYS_REFCURSOR);

    --===============================================
    --                NDI_LIVING_WAGE
    --===============================================

    PROCEDURE SAVE_NDI_LIVING_WAGE (
        P_LGW_START_DT          IN NDI_LIVING_WAGE.LGW_START_DT%TYPE,
        P_LGW_STOP_DT           IN NDI_LIVING_WAGE.LGW_STOP_DT%TYPE,
        P_LGW_CMN_SUM           IN NDI_LIVING_WAGE.LGW_CMN_SUM%TYPE,
        P_LGW_6YEAR_SUM         IN NDI_LIVING_WAGE.LGW_6YEAR_SUM%TYPE,
        P_LGW_18YEAR_SUM        IN NDI_LIVING_WAGE.LGW_18YEAR_SUM%TYPE,
        P_LGW_WORK_ABLE_SUM     IN NDI_LIVING_WAGE.LGW_WORK_ABLE_SUM%TYPE,
        P_LGW_WORK_UNABLE_SUM   IN NDI_LIVING_WAGE.LGW_WORK_UNABLE_SUM%TYPE);

    PROCEDURE DELETE_NDI_LIVING_WAGE (P_LGW_ID NDI_LIVING_WAGE.LGW_ID%TYPE);

    PROCEDURE QUERY_NDI_LIVING_WAGE (P_LGW_START_DT   IN     DATE,
                                     P_LGW_STOP_DT    IN     DATE,
                                     P_RES               OUT SYS_REFCURSOR);

    --===============================================
    --                NDI_POST_OFFICE
    --===============================================

    PROCEDURE save_post_office (
        p_npo_id        IN     ndi_post_office.npo_id%TYPE,
        --p_NPO_ORG IN NDI_POST_OFFICE.NPO_ORG%TYPE,
        p_npo_index     IN     ndi_post_office.npo_index%TYPE,
        p_npo_address   IN     ndi_post_office.npo_address%TYPE,
        p_npo_ncn       IN     ndi_post_office.npo_ncn%TYPE,
        p_npo_kaot      IN     ndi_post_office.npo_kaot%TYPE,
        p_new_id           OUT ndi_post_office.npo_id%TYPE);

    PROCEDURE DELETE_POST_OFFICE (P_NPO_ID NDI_POST_OFFICE.NPO_ID%TYPE);

    PROCEDURE GET_POST_OFFICE (P_NPO_ID   IN     NDI_POST_OFFICE.NPO_ID%TYPE,
                               P_RES         OUT SYS_REFCURSOR);

    PROCEDURE query_post_office (p_npo_index       IN     VARCHAR2,
                                 p_npo_address     IN     VARCHAR2,
                                 p_npo_ncn         IN     NUMBER,
                                 p_npo_kaot        IN     NUMBER,
                                 p_is_empty_kaot   IN     VARCHAR2,
                                 p_res                OUT SYS_REFCURSOR);

    --===============================================
    --                NDI_COMM_NODE
    --===============================================

    PROCEDURE SAVE_COMM_NODE (
        P_NCN_ID      IN     NDI_COMM_NODE.NCN_ID%TYPE,
        P_NCN_ORG     IN     NDI_COMM_NODE.NCN_ORG%TYPE,
        P_NCN_CODE    IN     NDI_COMM_NODE.NCN_CODE%TYPE,
        P_NCN_SNAME   IN     NDI_COMM_NODE.NCN_SNAME%TYPE,
        P_NCN_NAME    IN     NDI_COMM_NODE.NCN_NAME%TYPE,
        P_NEW_ID         OUT NDI_COMM_NODE.NCN_ID%TYPE);

    PROCEDURE DELETE_COMM_NODE (P_NCN_ID NDI_COMM_NODE.NCN_ID%TYPE);

    PROCEDURE GET_COMM_NODE (P_NPO_ID   IN     NDI_POST_OFFICE.NPO_ID%TYPE,
                             P_RES         OUT SYS_REFCURSOR);

    PROCEDURE QUERY_COMM_NODE (P_NCN_ORG     IN     NUMBER,
                               P_NCN_CODE    IN     VARCHAR2,
                               P_NCN_SNAME   IN     VARCHAR2,
                               P_NCN_NAME    IN     VARCHAR2,
                               P_RES            OUT SYS_REFCURSOR);

    --===============================================
    --                NDI_STREET_TYPE
    --===============================================

    PROCEDURE SAVE_STREET_TYPE (
        P_NSRT_ID     IN     NDI_STREET_TYPE.NSRT_ID%TYPE,
        P_NSRT_CODE   IN     NDI_STREET_TYPE.NSRT_CODE%TYPE,
        P_NSRT_NAME   IN     NDI_STREET_TYPE.NSRT_NAME%TYPE,
        P_NEW_ID         OUT NDI_STREET_TYPE.NSRT_ID%TYPE);

    PROCEDURE DELETE_STREET_TYPE (P_NSRT_ID NDI_STREET_TYPE.NSRT_ID%TYPE);

    PROCEDURE GET_STREET_TYPE (
        P_NSRT_ID   IN     NDI_STREET_TYPE.NSRT_ID%TYPE,
        P_RES          OUT SYS_REFCURSOR);

    PROCEDURE QUERY_STREET_TYPE (P_RES OUT SYS_REFCURSOR);

    --===============================================
    --                NDI_STREET
    --===============================================

    PROCEDURE SAVE_STREET_CARD (
        P_NS_ID               IN     NDI_STREET.NS_ID%TYPE,
        P_NS_CODE             IN     NDI_STREET.NS_CODE%TYPE,
        P_NS_NAME             IN     NDI_STREET.NS_NAME%TYPE,
        P_NS_KAOT             IN     NDI_STREET.NS_KAOT%TYPE,
        P_NS_NSRT             IN     NDI_STREET.NS_NSRT%TYPE,
        P_NS_ORG              IN     ndi_street.ns_org%TYPE,
        P_NS_HISTORY_STATUS   IN     ndi_street.history_status%TYPE,
        p_xml                 IN     CLOB,
        P_NEW_ID                 OUT NDI_STREET.NS_ID%TYPE);

    PROCEDURE DELETE_STREET (P_NS_ID NDI_STREET.NS_ID%TYPE);

    PROCEDURE Set_Street_Kaot (p_kaot_id   IN ndi_street.ns_id%TYPE,
                               p_ids       IN VARCHAR2);

    PROCEDURE GET_STREET_CARD (P_NS_ID   IN     NDI_STREET_TYPE.NSRT_ID%TYPE,
                               P_RES1       OUT SYS_REFCURSOR,
                               P_RES2       OUT SYS_REFCURSOR);

    --Отримання списку за фільтром
    PROCEDURE QUERY_STREET (P_NS_CODE             IN     VARCHAR2,
                            P_NS_NAME             IN     VARCHAR2,
                            P_NS_KAOT             IN     NUMBER,
                            P_NS_NSRT             IN     NUMBER,
                            p_ns_history_status   IN     VARCHAR2,  ----#77488
                            p_ns_org              IN     NUMBER,      --#77488
                            p_npo_index           IN     VARCHAR2,
                            P_RES                    OUT SYS_REFCURSOR);

    --===============================================
    --                NDI_KEKV
    --===============================================

    PROCEDURE SAVE_KEKV (P_NKV_ID      IN     NDI_KEKV.NKV_ID%TYPE,
                         P_NKV_NKV     IN     NDI_KEKV.NKV_NKV%TYPE,
                         P_NKV_CODE    IN     NDI_KEKV.NKV_CODE%TYPE,
                         P_NKV_NAME    IN     NDI_KEKV.NKV_NAME%TYPE,
                         P_NKV_SNAME   IN     NDI_KEKV.NKV_SNAME%TYPE,
                         P_NEW_ID         OUT NDI_KEKV.NKV_ID%TYPE);

    PROCEDURE DELETE_KEKV (P_NKV_ID NDI_KEKV.NKV_ID%TYPE);

    PROCEDURE GET_KEKV (P_NKV_ID   IN     NDI_KEKV.NKV_ID%TYPE,
                        P_RES         OUT SYS_REFCURSOR);

    PROCEDURE QUERY_KEKV (P_RES OUT SYS_REFCURSOR);

    --===============================================
    --                NDI_DELIVERY
    --===============================================
    /*
      PROCEDURE SAVE_DELIVERY(P_ND_ID      IN NDI_DELIVERY.ND_ID%TYPE,
                              P_ND_CODE    IN NDI_DELIVERY.ND_CODE%TYPE,
                              P_ND_COMMENT IN NDI_DELIVERY.ND_COMMENT%TYPE,
                              P_ND_NPO     IN NDI_DELIVERY.ND_NPO%TYPE,
                              P_ND_TP      IN NDI_DELIVERY.ND_TP%TYPE,
                              P_NEW_ID     OUT NDI_DELIVERY.ND_ID%TYPE);

      PROCEDURE DELETE_DELIVERY(P_ND_ID NDI_DELIVERY.ND_ID%TYPE);

      PROCEDURE GET_DELIVERY(P_ND_ID IN NDI_DELIVERY.ND_ID%TYPE,
                             p_main OUT SYS_REFCURSOR,
                             p_days OUT SYS_REFCURSOR,
                             p_ref OUT SYS_REFCURSOR);

      PROCEDURE QUERY_DELIVERY(P_ND_CODE    IN VARCHAR2,
                               P_ND_COMMENT IN VARCHAR2,
                               P_ND_NPO     IN VARCHAR2,
                               P_ND_TP      IN VARCHAR2,
                               p_org_id     IN NUMBER,
                               p_kaot_id    IN NUMBER,
                               P_RES        OUT SYS_REFCURSOR);

      --NDI_DELIVERY_DAY

      PROCEDURE QUERY_DELIVERY_DAY(P_NDD_ND IN VARCHAR2,
                                   P_RES    OUT SYS_REFCURSOR);
    */
    --NDI_DELIVERY_REF

    --===============================================
    --                NDI_NB_FILIA
    --===============================================

    PROCEDURE SAVE_NB_FILIA (
        P_NBF_ID      IN     NDI_NB_FILIA.NBF_ID%TYPE,
        P_NBF_NB      IN     NDI_NB_FILIA.NBF_NB%TYPE,
        P_NBF_NAME    IN     NDI_NB_FILIA.NBF_NAME%TYPE,
        P_NBF_SNAME   IN     NDI_NB_FILIA.NBF_SNAME%TYPE,
        P_NBF_ORG     IN     NDI_NB_FILIA.NBF_ORG%TYPE,
        P_NBF_CODE    IN     NDI_NB_FILIA.NBF_CODE%TYPE,
        P_NEW_ID         OUT NDI_NB_FILIA.NBF_ID%TYPE);

    PROCEDURE DELETE_NB_FILIA (P_NBF_ID NDI_NB_FILIA.NBF_ID%TYPE);

    PROCEDURE GET_NB_FILIA (P_NBF_ID   IN     NDI_NB_FILIA.NBF_ID%TYPE,
                            P_RES         OUT SYS_REFCURSOR);

    PROCEDURE QUERY_NB_FILIA (P_NBF_NB      IN     VARCHAR2,
                              P_NBF_NAME    IN     VARCHAR2,
                              P_NBF_SNAME   IN     VARCHAR2,
                              P_NBF_CODE    IN     VARCHAR2,
                              P_RES            OUT SYS_REFCURSOR);

    --===============================================
    --                NDI_BUDGET
    --===============================================

    PROCEDURE save_budget (p_nbu_id     IN     ndi_budget.nbu_id%TYPE,
                           p_nbu_tp     IN     ndi_budget.nbu_tp%TYPE,
                           p_nbu_code   IN     ndi_budget.nbu_code%TYPE,
                           p_nbu_name   IN     ndi_budget.nbu_name%TYPE,
                           p_new_id        OUT ndi_budget.nbu_id%TYPE);

    PROCEDURE delete_budget (p_nbu_id ndi_budget.nbu_id%TYPE);

    PROCEDURE get_budget (p_nbu_id   IN     ndi_budget.nbu_id%TYPE,
                          p_res         OUT SYS_REFCURSOR);

    PROCEDURE query_budget (p_nbu_tp     IN     VARCHAR2,
                            p_nbu_code   IN     VARCHAR2,
                            p_nbu_name   IN     VARCHAR2,
                            p_res           OUT SYS_REFCURSOR);

    --===============================================
    --                NDI_FUNDING_SOURCE
    --===============================================

    PROCEDURE save_funding_source (
        p_nfs_id     IN     ndi_funding_source.nfs_id%TYPE,
        p_nfs_nbg    IN     ndi_funding_source.nfs_nbg%TYPE,
        p_nfs_nbu    IN     ndi_funding_source.nfs_nbu%TYPE,
        p_nfs_name   IN     ndi_funding_source.nfs_name%TYPE,
        p_nfs_tp     IN     ndi_funding_source.nfs_tp%TYPE,
        p_new_id        OUT ndi_funding_source.nfs_id%TYPE);

    PROCEDURE delete_funding_source (p_nfs_id ndi_funding_source.nfs_id%TYPE);

    PROCEDURE get_funding_source (
        p_nfs_id   IN     ndi_funding_source.nfs_id%TYPE,
        p_res         OUT SYS_REFCURSOR);

    PROCEDURE query_funding_source (p_nfs_nbg    IN     NUMBER,
                                    p_nfs_nbu    IN     NUMBER,
                                    p_nfs_name   IN     VARCHAR2,
                                    p_nfs_tp     IN     VARCHAR2,
                                    p_res           OUT SYS_REFCURSOR);

    --===============================================
    --                NDI_MIN_ZP
    --===============================================

    PROCEDURE save_ndi_min_zp (
        p_nmz_start_dt    IN ndi_min_zp.nmz_start_dt%TYPE,
        p_nmz_stop_dt     IN ndi_min_zp.nmz_stop_dt%TYPE,
        p_nmz_month_sum   IN ndi_min_zp.nmz_month_sum%TYPE,
        p_nmz_hour_sum    IN ndi_min_zp.nmz_hour_sum%TYPE);

    PROCEDURE delete_ndi_min_zp (p_nmz_id ndi_min_zp.nmz_id%TYPE);

    PROCEDURE query_ndi_min_zp (p_nmz_start_dt   IN     DATE,
                                p_nmz_stop_dt    IN     DATE,
                                p_res               OUT SYS_REFCURSOR);

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

    PROCEDURE query_lgw_sub_level (p_nlsl_start_dt   IN     DATE,
                                   p_nlsl_stop_dt    IN     DATE,
                                   p_res                OUT SYS_REFCURSOR);


    PROCEDURE save_ndi_pay_config (
        p_nfpc_id       IN     ndi_fin_pay_config.nfpc_id%TYPE,
        p_nfpc_pay_tp   IN     ndi_fin_pay_config.nfpc_pay_tp%TYPE,
        p_nfpc_nb       IN     ndi_fin_pay_config.nfpc_nb%TYPE,
        p_nfpc_ncn      IN     ndi_fin_pay_config.nfpc_ncn%TYPE,
        p_nfpc_dppa     IN     ndi_fin_pay_config.nfpc_dppa%TYPE,
        p_new_id           OUT ndi_fin_pay_config.nfpc_id%TYPE);

    PROCEDURE delete_ndi_pay_config (
        p_nfpc_id   ndi_fin_pay_config.nfpc_id%TYPE);

    PROCEDURE query_ndi_pay_config (
        p_nfpc_pay_tp         IN     VARCHAR2,
        p_nfpc_nb_mfo         IN     VARCHAR2,
        p_nfpc_nb_name        IN     VARCHAR2,
        p_nfpc_dpp_name       IN     VARCHAR2,
        p_nfpc_ncn_name       IN     VARCHAR2,
        p_nfpc_dppa_account   IN     VARCHAR2,
        p_dppa_nbg            IN     NUMBER,             -- Бюджетна программа
        p_res                    OUT SYS_REFCURSOR);

    PROCEDURE get_ndi_pay_config (
        p_nfpc_id   IN     ndi_fin_pay_config.nfpc_id%TYPE,
        p_res          OUT SYS_REFCURSOR);


    --===============================================
    --                NDI_SITE + NDI_NIS_USERS
    --===============================================
    PROCEDURE query_ndi_site (p_res OUT SYS_REFCURSOR);

    PROCEDURE get_ndi_site (p_nis_id    IN     ndi_site.nis_id%TYPE,
                            site_cur       OUT SYS_REFCURSOR,
                            users_cur      OUT SYS_REFCURSOR);

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


    PROCEDURE delete_normative_act (
        p_nna_id   IN ndi_normative_act.nna_id%TYPE);

    PROCEDURE get_normative_act (
        p_nna_id   IN     ndi_normative_act.nna_id%TYPE,
        p_res         OUT SYS_REFCURSOR);

    PROCEDURE query_normative_act (p_nna_dt    IN     DATE,
                                   p_nna_num   IN     VARCHAR2,
                                   p_res          OUT SYS_REFCURSOR);
END DNET$DIC_DOCUMENT;
/


GRANT EXECUTE ON USS_NDI.DNET$DIC_DOCUMENT TO DNET_PROXY
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_DOCUMENT TO II01RC_USS_NDI_PORTAL
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_DOCUMENT TO II01RC_USS_NDI_WEB
/

GRANT EXECUTE ON USS_NDI.DNET$DIC_DOCUMENT TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:55:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.DNET$DIC_DOCUMENT
IS
    --===============================================
    --                NDI_TYPE
    --===============================================

    PROCEDURE get_ndi_document_type (
        p_id    IN     ndi_document_type.ndt_id%TYPE,
        p_res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        OPEN p_res FOR
            SELECT ndt.*,
                   (SELECT MAX (z.DIC_NAME)
                      FROM v_ddn_record_src z
                     WHERE z.DIC_VALUE = ndt.record_src)
                       AS record_src_name,
                   tools.can_edit_record (ndt.record_src)
                       AS can_Edit_Record
              FROM ndi_document_type  ndt
                   LEFT JOIN ndi_document_class ndc
                       ON (ndc.ndc_id = ndt.ndt_ndc)
             WHERE ndt.history_status = 'A' AND ndt.ndt_id = p_id;
    END;

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
        l_code_exists   NUMBER;
    BEGIN
        tools.check_user_and_raise (7);

        --Контроль уникальности кода
        SELECT SIGN (COUNT (*))
          INTO l_code_exists
          FROM ndi_document_type t
         WHERE     ndt_name_short = p_ndt_name_short
               AND t.history_status = 'A'
               AND ndt_id <> NVL (p_ndt_id, -999);

        IF l_code_exists = 1
        THEN
            raise_application_error (
                -20002,
                   'Клас послуги з короткою назвою '
                || p_ndt_name_short
                || ' вже існує');
        END IF;

        api$dic_document.save_ndi_document_type (p_ndt_id,
                                                 p_ndt_ndc,
                                                 p_ndt_name,
                                                 p_ndt_name_short,
                                                 p_ndt_order,
                                                 p_ndt_is_have_scan,
                                                 p_ndt_is_vt_visible,
                                                 p_new_id);
    END;

    PROCEDURE delete_ndi_document_type (p_id ndi_document_type.ndt_id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (7);
        api$dic_document.delete_ndi_document_type (p_id);
    END;

    PROCEDURE query_ndi_document_type (
        p_ndt_name            IN     VARCHAR2,
        p_ndt_name_short      IN     VARCHAR2,
        p_ndc_id              IN     NUMBER,
        p_ndt_is_have_scan    IN     VARCHAR2,
        p_ndt_is_vt_visible   IN     VARCHAR2,
        p_res                    OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        OPEN p_res FOR
            SELECT ndt.*,
                   ndc.ndc_name,
                   (SELECT MAX (z.DIC_NAME)
                      FROM v_ddn_record_src z
                     WHERE z.DIC_VALUE = ndt.record_src)
                       AS record_src_name,
                   tools.can_edit_record (ndt.record_src)
                       AS can_Edit_Record
              FROM ndi_document_type  ndt
                   LEFT JOIN ndi_document_class ndc
                       ON (ndc.ndc_id = ndt.ndt_ndc)
             WHERE     ndt.history_status = 'A'
                   AND (   ndt.ndt_name IS NULL
                        OR ndt.ndt_name LIKE '%' || p_ndt_name || '%'
                        OR ndt.ndt_name LIKE p_ndt_name || '%')
                   AND (   ndt.ndt_name_short IS NULL
                        OR ndt.ndt_name_short LIKE
                               '%' || p_ndt_name_short || '%'
                        OR ndt.ndt_name_short LIKE p_ndt_name_short || '%')
                   AND (ndc.ndc_id = p_ndc_id OR p_ndc_id IS NULL)
                   AND (   ndt.ndt_is_have_scan IS NULL
                        OR ndt.ndt_is_have_scan LIKE
                               '%' || p_ndt_is_have_scan || '%')
                   AND (   ndt.ndt_is_vt_visible IS NULL
                        OR ndt.ndt_is_vt_visible LIKE
                               '%' || p_ndt_is_vt_visible || '%');
    END;

    --===============================================
    --                NDI_CLASS
    --===============================================

    PROCEDURE get_ndi_document_class (
        p_id    IN     ndi_document_class.ndc_id%TYPE,
        p_res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        OPEN p_res FOR
            SELECT ndc.*,
                   (SELECT MAX (z.DIC_NAME)
                      FROM v_ddn_record_src z
                     WHERE z.DIC_VALUE = ndc.record_src)
                       AS record_src_name,
                   tools.can_edit_record (ndc.record_src)
                       AS can_Edit_Record
              FROM ndi_document_class ndc
             WHERE ndc.history_status = 'A' AND ndc.ndc_id = p_id;
    END;

    PROCEDURE save_ndi_document_class (
        p_ndc_id            IN     ndi_document_class.ndc_id%TYPE,
        p_ndc_name          IN     ndi_document_class.ndc_name%TYPE,
        p_ndc_name_short    IN     ndi_document_class.ndc_name_short%TYPE,
        p_ndc_code          IN     ndi_document_class.ndc_code%TYPE,
        p_ndc_order         IN     ndi_document_class.ndc_order%TYPE,
        p_ndc_description   IN     ndi_document_class.ndc_description%TYPE,
        p_new_id               OUT ndi_document_class.ndc_id%TYPE)
    IS
        l_code_exists   NUMBER;
    BEGIN
        tools.check_user_and_raise (7);

        --Контроль уникальности кода
        SELECT SIGN (COUNT (*))
          INTO l_code_exists
          FROM ndi_document_class t
         WHERE     ndc_code = p_ndc_code
               AND t.history_status = 'A'
               AND ndc_id <> NVL (p_ndc_id, -999);

        IF l_code_exists = 1
        THEN
            raise_application_error (
                -20001,
                'Класи документів з кодом: ' || p_ndc_code || '  вже існує');
        END IF;

        api$dic_document.save_ndi_document_class (p_ndc_id,
                                                  p_ndc_name,
                                                  p_ndc_name_short,
                                                  p_ndc_code,
                                                  p_ndc_order,
                                                  p_ndc_description,
                                                  p_new_id);
    END;

    PROCEDURE delete_ndi_document_class (p_id ndi_document_class.ndc_id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (7);
        api$dic_document.delete_ndi_document_class (p_id);
    END;

    PROCEDURE query_ndi_document_class (
        p_ndc_name          IN     VARCHAR2,
        p_ndc_name_short    IN     VARCHAR2,
        p_ndc_description   IN     VARCHAR2,
        p_ndc_code          IN     VARCHAR2,
        p_res                  OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        OPEN p_res FOR
            SELECT ndc.*,
                   (SELECT MAX (z.DIC_NAME)
                      FROM v_ddn_record_src z
                     WHERE z.DIC_VALUE = ndc.record_src)
                       AS record_src_name,
                   tools.can_edit_record (ndc.record_src)
                       AS can_Edit_Record
              FROM ndi_document_class ndc
             WHERE     ndc.history_status = 'A'
                   AND (   ndc.ndc_name LIKE '%' || p_ndc_name || '%'
                        OR ndc.ndc_name LIKE p_ndc_name || '%')
                   AND (   ndc.ndc_name_short LIKE
                               '%' || p_ndc_name_short || '%'
                        OR ndc.ndc_name LIKE p_ndc_name_short || '%')
                   AND (   p_ndc_description IS NULL
                        OR ndc.ndc_description LIKE
                               '%' || p_ndc_description || '%'
                        OR ndc.ndc_description LIKE p_ndc_description || '%')
                   AND (   p_ndc_code IS NULL
                        OR ndc.ndc_code LIKE '%' || p_ndc_code || '%');
    END;

    --===============================================
    --                NDI_NDA_GROUP
    --===============================================

    PROCEDURE get_ndi_nda_group (p_id    IN     ndi_nda_group.nng_id%TYPE,
                                 p_res      OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        OPEN p_res FOR
            SELECT nng.*,
                   (SELECT MAX (z.DIC_NAME)
                      FROM v_ddn_record_src z
                     WHERE z.DIC_VALUE = nng.record_src)
                       AS record_src_name,
                   tools.can_edit_record (nng.record_src)
                       AS can_Edit_Record
              FROM ndi_nda_group nng
             WHERE nng.nng_id = p_id;
    END;

    PROCEDURE save_ndi_nda_group (
        p_nng_id            IN     ndi_nda_group.nng_id%TYPE,
        p_nng_name          IN     ndi_nda_group.nng_name%TYPE,
        p_nng_open_by_def   IN     ndi_nda_group.nng_open_by_def%TYPE,
        p_nng_order         IN     ndi_nda_group.nng_order%TYPE,
        p_new_id               OUT ndi_nda_group.nng_id%TYPE)
    IS
        l_code_exists   NUMBER;
    BEGIN
        tools.check_user_and_raise (7);

        --Контроль уникальности кода
        SELECT SIGN (COUNT (*))
          INTO l_code_exists
          FROM ndi_nda_group t
         WHERE     nng_name = p_nng_name
               AND t.history_status = 'A'
               AND nng_id <> NVL (p_nng_id, -999);

        IF l_code_exists = 1
        THEN
            raise_application_error (
                -20002,
                'Групи атрибутів з назвою: ' || p_nng_name || '  вже існує');
        END IF;

        api$dic_document.save_ndi_nda_group (
            p_nng_id            => p_nng_id,
            p_nng_name          => p_nng_name,
            p_nng_open_by_def   => p_nng_open_by_def,
            p_nng_order         => p_nng_order,
            p_history_status    => api$dic_visit.c_history_status_actual,
            p_new_id            => p_new_id);
    END;

    PROCEDURE delete_ndi_nda_group (p_id ndi_nda_group.nng_id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (7);
        api$dic_document.delete_ndi_nda_group (
            p_id               => p_id,
            p_history_status   => api$dic_visit.c_history_status_historical);
    END;

    PROCEDURE query_ndi_nda_group (p_nng_name          IN     VARCHAR2,
                                   p_nng_open_by_def   IN     VARCHAR2,
                                   p_res                  OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        OPEN p_res FOR
            SELECT nng.*,
                   (SELECT MAX (z.DIC_NAME)
                      FROM v_ddn_record_src z
                     WHERE z.DIC_VALUE = nng.record_src)
                       AS record_src_name,
                   tools.can_edit_record (nng.record_src)
                       AS can_Edit_Record
              FROM ndi_nda_group nng
             WHERE     nng.history_status = 'A'
                   AND (   nng.nng_name IS NULL
                        OR UPPER (nng.nng_name) LIKE
                               '%' || UPPER (p_nng_name) || '%'
                        OR nng.nng_name LIKE p_nng_name || '%')
                   AND (   nng.nng_open_by_def IS NULL
                        OR nng.nng_open_by_def LIKE
                               '%' || p_nng_open_by_def || '%');
    END;

    --===============================================
    --                NDI_DOCUMENT_ATTR
    --===============================================

    PROCEDURE save_ndi_document_attr (
        p_nda_id          IN     ndi_document_attr.nda_id%TYPE,
        p_nda_ndt         IN     ndi_document_attr.nda_ndt%TYPE,
        p_nda_name        IN     ndi_document_attr.nda_name%TYPE,
        p_nda_order       IN     ndi_document_attr.nda_order%TYPE,
        p_nda_is_key      IN     ndi_document_attr.nda_is_key%TYPE,
        p_nda_pt          IN     ndi_document_attr.nda_pt%TYPE,
        p_nda_is_req      IN     ndi_document_attr.nda_is_req%TYPE,
        p_nda_def_value   IN     ndi_document_attr.nda_def_value%TYPE,
        p_nda_can_edit    IN     ndi_document_attr.nda_can_edit%TYPE,
        p_nda_need_show   IN     ndi_document_attr.nda_need_show%TYPE,
        p_nda_class       IN     ndi_document_attr.nda_class%TYPE,
        p_nda_nng         IN     ndi_document_attr.nda_nng%TYPE,
        p_nac_ap_tp       IN     ndi_nda_config.nac_ap_tp%TYPE,
        p_nst_list        IN     VARCHAR2,
        p_new_id             OUT ndi_document_attr.nda_id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (7);
        api$dic_document.save_ndi_document_attr (
            p_nda_id           => p_nda_id,
            p_nda_ndt          => p_nda_ndt,
            p_nda_name         => p_nda_name,
            p_nda_order        => p_nda_order,
            p_nda_is_key       => p_nda_is_key,
            p_history_status   => api$dic_visit.c_history_status_actual,
            p_nda_pt           => p_nda_pt,
            p_nda_is_req       => p_nda_is_req,
            p_nda_def_value    => p_nda_def_value,
            p_nda_can_edit     => p_nda_can_edit,
            p_nda_need_show    => p_nda_need_show,
            p_nda_class        => p_nda_class,
            p_nac_ap_tp        => p_nac_ap_tp,
            p_nst_list         => p_nst_list,
            p_nda_nng          => p_nda_nng,
            p_new_id           => p_new_id);
    END;

    PROCEDURE delete_ndi_document_attr (
        p_nda_id   ndi_document_attr.nda_id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (7);
        api$dic_document.delete_ndi_document_attr (
            p_nda_id           => p_nda_id,
            p_history_status   => api$dic_visit.c_history_status_historical);
    END;

    PROCEDURE get_ndi_document_attr (
        p_nda_id   IN     ndi_document_attr.nda_id%TYPE,
        p_res         OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        OPEN p_res FOR
            SELECT t.*,
                   (SELECT MAX (z.DIC_NAME)
                      FROM v_ddn_record_src z
                     WHERE z.DIC_VALUE = t.record_src)     AS record_src_name,
                   tools.can_edit_record (t.record_src)    AS can_Edit_Record
              FROM ndi_document_attr t
             WHERE nda_id = p_nda_id;
    END;

    PROCEDURE query_ndi_document_attr (
        p_nda_ndt         IN     NUMBER,
        p_nda_name        IN     VARCHAR2,
        p_nda_is_key      IN     VARCHAR2,
        p_nda_pt          IN     NUMBER,
        p_nda_is_req      IN     VARCHAR2,
        p_nda_def_value   IN     VARCHAR2,
        p_nda_can_edit    IN     VARCHAR2,
        p_nda_need_show   IN     VARCHAR2,
        p_nda_class       IN     VARCHAR2,
        p_nda_nng         IN     NUMBER,
        p_res                OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        OPEN p_res FOR
            SELECT nda.*,
                   ndt.ndt_name_short,
                      npt.pt_name
                   || ' |  '
                   || npt.pt_edit_type
                   || ' '
                   || npt.pt_data_type
                       AS pt_name,
                   dda.dic_sname,
                   nng.nng_name,
                   (SELECT MAX (z.DIC_NAME)
                      FROM v_ddn_record_src z
                     WHERE z.DIC_VALUE = nda.record_src)
                       AS record_src_name,
                   tools.can_edit_record (nda.record_src)
                       AS can_Edit_Record
              FROM ndi_document_attr  nda
                   LEFT JOIN ndi_document_type ndt
                       ON nda.nda_ndt = ndt.ndt_id
                   LEFT JOIN v_ddn_doc_attr_class dda
                       ON nda.nda_class = dda.dic_code
                   LEFT JOIN v_ndi_nda_group nng ON nda.nda_nng = nng.nng_id
                   LEFT JOIN v_ndi_param_type npt ON nda.nda_pt = npt.pt_id
             WHERE     nda.history_status =
                       api$dic_visit.c_history_status_actual
                   AND (   p_nda_name IS NULL
                        OR UPPER (nda.nda_name) LIKE
                               '%' || UPPER (p_nda_name) || '%')
                   AND (p_nda_ndt IS NULL OR nda.nda_ndt = p_nda_ndt)
                   AND (p_nda_is_key IS NULL OR nda.nda_is_key = p_nda_is_key)
                   AND (p_nda_pt IS NULL OR nda.nda_pt = p_nda_pt)
                   AND (p_nda_is_req IS NULL OR nda.nda_is_req = p_nda_is_req)
                   AND (   p_nda_def_value IS NULL
                        OR nda.nda_def_value LIKE
                               '%' || p_nda_def_value || '%'
                        OR nda.nda_def_value LIKE p_nda_def_value || '%')
                   AND (   p_nda_can_edit IS NULL
                        OR nda.nda_can_edit = p_nda_can_edit)
                   AND (   p_nda_need_show IS NULL
                        OR nda.nda_need_show = p_nda_need_show)
                   AND (p_nda_class IS NULL OR nda.nda_class = p_nda_class)
                   AND (p_nda_nng IS NULL OR nda.nda_nng = p_nda_nng);
    END;

    --===============================================
    --                NDI_DIC_DV
    --===============================================

    PROCEDURE get_dic_dv (p_dic_didi   IN     dic_dv.dic_didi%TYPE,
                          p_res           OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        IF p_dic_didi NOT IN (2002, 2248)
        THEN
            raise_application_error (
                -20009,
                   'Довідник з кодом: '
                || p_dic_didi
                || ' не існує або недоступний');
        END IF;

        OPEN p_res FOR
            SELECT d.dic_didi,
                   d.dic_value,
                   d.dic_code,
                   d.dic_name,
                   d.dic_sname,
                   d.dic_srtordr,
                   dd.didi_name
              FROM dic_dv d LEFT JOIN dic_dd dd ON dd.didi_id = d.dic_didi
             WHERE     d.dic_st = api$dic_visit.c_history_status_actual
                   AND d.dic_didi = p_dic_didi;
    END;

    --===============================================
    --                NDI_LIVING_WAGE
    --===============================================

    PROCEDURE save_ndi_living_wage (
        p_lgw_start_dt          IN ndi_living_wage.lgw_start_dt%TYPE,
        p_lgw_stop_dt           IN ndi_living_wage.lgw_stop_dt%TYPE,
        p_lgw_cmn_sum           IN ndi_living_wage.lgw_cmn_sum%TYPE,
        p_lgw_6year_sum         IN ndi_living_wage.lgw_6year_sum%TYPE,
        p_lgw_18year_sum        IN ndi_living_wage.lgw_18year_sum%TYPE,
        p_lgw_work_able_sum     IN ndi_living_wage.lgw_work_able_sum%TYPE,
        p_lgw_work_unable_sum   IN ndi_living_wage.lgw_work_unable_sum%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (7);

        --Контроль уникальности кода
        IF p_lgw_start_dt > p_lgw_stop_dt
        THEN
            raise_application_error (
                -20010,
                   'Некоректне значення дати: діє з '
                || p_lgw_start_dt
                || ' більше '
                || p_lgw_stop_dt
                || '');
        END IF;

        api$dic_document.save_ndi_living_wage (p_lgw_start_dt,
                                               p_lgw_stop_dt,
                                               p_lgw_cmn_sum,
                                               p_lgw_6year_sum,
                                               p_lgw_18year_sum,
                                               p_lgw_work_able_sum,
                                               p_lgw_work_unable_sum);
    END;

    PROCEDURE delete_ndi_living_wage (p_lgw_id ndi_living_wage.lgw_id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (7);
        api$dic_document.delete_ndi_living_wage (
            p_lgw_id           => p_lgw_id,
            p_history_status   => api$dic_visit.c_history_status_historical);
    END;

    PROCEDURE query_ndi_living_wage (p_lgw_start_dt   IN     DATE,
                                     p_lgw_stop_dt    IN     DATE,
                                     p_res               OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (8);

        IF p_lgw_start_dt > p_lgw_stop_dt
        THEN
            raise_application_error (
                -20010,
                   'Некоректне значення дати: діє з '
                || p_lgw_start_dt
                || ' більше '
                || p_lgw_stop_dt
                || ' ');
        END IF;

        OPEN p_res FOR
            SELECT nlw.lgw_id,
                   nlw.lgw_start_dt,
                   nlw.lgw_stop_dt,
                   nlw.lgw_cmn_sum,
                   nlw.lgw_6year_sum,
                   nlw.lgw_18year_sum,
                   nlw.lgw_work_able_sum,
                   nlw.lgw_work_unable_sum
              FROM ndi_living_wage nlw
             WHERE     nlw.history_status =
                       api$dic_visit.c_history_status_actual
                   AND (   p_lgw_start_dt IS NULL
                        OR p_lgw_start_dt <= nlw.lgw_start_dt)
                   AND (   p_lgw_stop_dt IS NULL
                        OR p_lgw_stop_dt >= nlw.lgw_stop_dt);
    END;

    --===============================================
    --                NDI_POST_OFFICE
    --===============================================

    PROCEDURE save_post_office (
        p_npo_id        IN     ndi_post_office.npo_id%TYPE,
        --p_NPO_ORG IN NDI_POST_OFFICE.NPO_ORG%TYPE,
        p_npo_index     IN     ndi_post_office.npo_index%TYPE,
        p_npo_address   IN     ndi_post_office.npo_address%TYPE,
        p_npo_ncn       IN     ndi_post_office.npo_ncn%TYPE,
        p_npo_kaot      IN     ndi_post_office.npo_kaot%TYPE,
        p_new_id           OUT ndi_post_office.npo_id%TYPE)
    IS
        --
        l_code_exists   NUMBER;
    BEGIN
        tools.check_user_and_raise (4);

        --Контроль уникальности кода
        SELECT SIGN (COUNT (*))
          INTO l_code_exists
          FROM v_ndi_post_office npo
         WHERE     npo.npo_index = p_npo_index
               AND npo.history_status = 'A'
               AND npo.npo_id <> NVL (p_npo_id, -999);

        IF l_code_exists = 1
        THEN
            raise_application_error (
                -20002,
                'Індекс поштового відділення ' || p_npo_index || ' вже існує');
        END IF;

        api$dic_document.save_post_office (
            p_npo_id           => p_npo_id,
            --p_NPO_ORG      => p_NPO_ORG,
            p_npo_index        => p_npo_index,
            p_npo_address      => p_npo_address,
            p_npo_ncn          => p_npo_ncn,
            p_history_status   => api$dic_visit.c_history_status_actual,
            p_npo_kaot         => p_npo_kaot,
            p_new_id           => p_new_id);
    END;

    PROCEDURE delete_post_office (p_npo_id ndi_post_office.npo_id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (4);
        api$dic_document.delete_post_office (
            p_npo_id           => p_npo_id,
            p_history_status   => api$dic_visit.c_history_status_historical);
    END;

    PROCEDURE get_post_office (p_npo_id   IN     ndi_post_office.npo_id%TYPE,
                               p_res         OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (4);

        OPEN p_res FOR
            SELECT npo_id,
                   nk.kaot_name      AS npo_kaot_name,
                   npo_kaot,
                   npo_index,
                   npo_address,
                   -- NDI_COMM_NODE
                   npo_ncn,
                   ncn.ncn_sname     AS npo_ncn_sname
              FROM ndi_post_office  npo
                   LEFT JOIN v_ndi_katottg nk ON nk.kaot_id = npo.npo_kaot
                   LEFT JOIN v_ndi_comm_node ncn ON ncn.ncn_id = npo.npo_ncn
             WHERE npo.npo_id = p_npo_id;
    END;

    PROCEDURE query_post_office (p_npo_index       IN     VARCHAR2,
                                 p_npo_address     IN     VARCHAR2,
                                 p_npo_ncn         IN     NUMBER,
                                 p_npo_kaot        IN     NUMBER,
                                 p_is_empty_kaot   IN     VARCHAR2,
                                 p_res                OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (4);

        OPEN p_res FOR
            SELECT npo.npo_id,
                   (SELECT RTRIM (
                                  CASE
                                      WHEN     l1_name IS NOT NULL
                                           AND l1_name != l2_name
                                      THEN
                                          l1_name || ', '
                                  END
                               || CASE
                                      WHEN     l2_name IS NOT NULL
                                           AND l2_name != l3_name
                                      THEN
                                          l2_name || ', '
                                  END
                               || CASE
                                      WHEN     l3_name IS NOT NULL
                                           AND l3_name != l4_name
                                      THEN
                                          l3_name || ', '
                                  END
                               || CASE
                                      WHEN     l4_name IS NOT NULL
                                           AND l4_name != l5_name
                                      THEN
                                          l4_name || ', '
                                  END
                               || CASE
                                      WHEN     l5_name IS NOT NULL
                                           AND l5_name !=
                                               kaot_name
                                      THEN
                                          l5_name || ', '
                                  END
                               || name_temp,
                               ',')    AS NAME
                      FROM (SELECT kaot_id,
                                   CASE
                                       WHEN kaot_kaot_l1 = kaot_id
                                       THEN
                                           kaot_name
                                       ELSE
                                           (SELECT    dic_sname
                                                   || ' '
                                                   || x1.kaot_name
                                              FROM uss_ndi.v_ndi_katottg
                                                   x1,
                                                   uss_ndi.v_ddn_kaot_tp
                                             WHERE     x1.kaot_id =
                                                       m.kaot_kaot_l1
                                                   AND kaot_tp =
                                                       dic_value)
                                   END                                AS l1_name,
                                   CASE
                                       WHEN kaot_kaot_l2 = kaot_id
                                       THEN
                                           kaot_name
                                       ELSE
                                           (SELECT    dic_sname
                                                   || ' '
                                                   || x1.kaot_name
                                              FROM uss_ndi.v_ndi_katottg
                                                   x1,
                                                   uss_ndi.v_ddn_kaot_tp
                                             WHERE     x1.kaot_id =
                                                       m.kaot_kaot_l2
                                                   AND kaot_tp =
                                                       dic_value)
                                   END                                AS l2_name,
                                   CASE
                                       WHEN kaot_kaot_l3 = kaot_id
                                       THEN
                                           kaot_name
                                       ELSE
                                           (SELECT    dic_sname
                                                   || ' '
                                                   || x1.kaot_name
                                              FROM uss_ndi.v_ndi_katottg
                                                   x1,
                                                   uss_ndi.v_ddn_kaot_tp
                                             WHERE     x1.kaot_id =
                                                       m.kaot_kaot_l3
                                                   AND kaot_tp =
                                                       dic_value)
                                   END                                AS l3_name,
                                   CASE
                                       WHEN kaot_kaot_l4 = kaot_id
                                       THEN
                                           kaot_name
                                       ELSE
                                           (SELECT    dic_sname
                                                   || ' '
                                                   || x1.kaot_name
                                              FROM uss_ndi.v_ndi_katottg
                                                   x1,
                                                   uss_ndi.v_ddn_kaot_tp
                                             WHERE     x1.kaot_id =
                                                       m.kaot_kaot_l4
                                                   AND kaot_tp =
                                                       dic_value)
                                   END                                AS l4_name,
                                   CASE
                                       WHEN kaot_kaot_l5 = kaot_id
                                       THEN
                                           kaot_name
                                       ELSE
                                           (SELECT    dic_sname
                                                   || ' '
                                                   || x1.kaot_name
                                              FROM uss_ndi.v_ndi_katottg
                                                   x1,
                                                   uss_ndi.v_ddn_kaot_tp
                                             WHERE     x1.kaot_id =
                                                       m.kaot_kaot_l5
                                                   AND kaot_tp =
                                                       dic_value)
                                   END                                AS l5_name,
                                   kaot_name,
                                   t.dic_sname || ' ' || kaot_name    AS name_temp
                              FROM uss_ndi.v_ndi_katottg  m
                                   JOIN uss_ndi.v_ddn_kaot_tp t
                                       ON m.kaot_tp = t.dic_code
                             WHERE     kaot_st = 'A'
                                   AND kaot_id = npo.npo_kaot))
                       AS npo_kaot_name,
                   npo.npo_index,
                   npo.npo_address,
                   npo.npo_kaot,
                   npo.npo_ncn,
                   ncn.ncn_code || '. ' || ncn.ncn_sname
                       AS npo_ncn_name,
                   ncn.ncn_sname
                       AS npo_ncn_sname,
                      'Область '
                   || ncn.ncn_org
                   || ' - '
                   || ncn.ncn_code
                   || '. '
                   || ncn.ncn_sname
                       AS npo_ncn_fname
              FROM v_ndi_post_office  npo
                   LEFT JOIN v_ndi_comm_node ncn ON ncn.ncn_id = npo.npo_ncn
             WHERE     npo.history_status =
                       api$dic_visit.c_history_status_actual
                   AND (   p_npo_index IS NULL AND ROWNUM <= 1000
                        OR npo.npo_index LIKE p_npo_index || '%')
                   AND (   p_is_empty_kaot IS NULL
                        OR p_is_empty_kaot = 'F'
                        OR p_is_empty_kaot = 'T' AND npo.npo_kaot IS NULL)
                   AND (   p_npo_kaot IS NULL
                        OR npo.npo_kaot IN
                               (SELECT z.kaot_id
                                  FROM ndi_katottg z
                                 WHERE    z.kaot_id = p_npo_kaot
                                       OR z.kaot_kaot_l1 = p_npo_kaot
                                       OR z.kaot_kaot_l2 = p_npo_kaot
                                       OR z.kaot_kaot_l3 = p_npo_kaot
                                       OR z.kaot_kaot_l4 = p_npo_kaot
                                       OR z.kaot_kaot_l5 = p_npo_kaot))
                   AND (   p_npo_address IS NULL
                        OR UPPER (npo.npo_address) LIKE
                               '%' || UPPER (p_npo_address) || '%'
                        OR UPPER (npo.npo_address) LIKE
                               UPPER (p_npo_address) || '%')
                   AND (p_npo_ncn IS NULL OR npo.npo_ncn = p_npo_ncn);
    END;

    --===============================================
    --                NDI_COMM_NODE
    --===============================================

    PROCEDURE save_comm_node (
        p_ncn_id      IN     ndi_comm_node.ncn_id%TYPE,
        p_ncn_org     IN     ndi_comm_node.ncn_org%TYPE,
        p_ncn_code    IN     ndi_comm_node.ncn_code%TYPE,
        p_ncn_sname   IN     ndi_comm_node.ncn_sname%TYPE,
        p_ncn_name    IN     ndi_comm_node.ncn_name%TYPE,
        p_new_id         OUT ndi_comm_node.ncn_id%TYPE)
    IS                                                 --l_Code_Exists NUMBER;
    BEGIN
        tools.check_user_and_raise (4);
        --Контроль уникальности кода
        /*SELECT Sign(COUNT(*))
          INTO l_Code_Exists
          FROM NDI_COMM_NODE
         WHERE NCN_CODE = p_NCN_CODE
               AND NCN_ID <> Nvl(p_NCN_ID, -999);

        IF l_Code_Exists = 1
        THEN
         Raise_Application_Error(-20001, 'Вузол зв`язку з кодом: ' || p_NCN_CODE || '  вже існує');
        END IF;*/
        api$dic_document.save_comm_node (
            p_ncn_id           => p_ncn_id,
            p_ncn_org          => p_ncn_org,
            p_ncn_code         => p_ncn_code,
            p_ncn_sname        => p_ncn_sname,
            p_ncn_name         => p_ncn_name,
            p_history_status   => api$dic_visit.c_history_status_actual,
            p_new_id           => p_new_id);
    END;

    PROCEDURE delete_comm_node (p_ncn_id ndi_comm_node.ncn_id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (4);
        api$dic_document.delete_comm_node (
            p_ncn_id           => p_ncn_id,
            p_history_status   => api$dic_visit.c_history_status_historical);
    END;

    PROCEDURE get_comm_node (p_npo_id   IN     ndi_post_office.npo_id%TYPE,
                             p_res         OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (4);

        OPEN p_res FOR SELECT ncn_id,
                              -- OPFU
                              ncn_org,
                              ncn_code,
                              ncn_sname,
                              ncn_name
                         FROM ndi_comm_node
                        WHERE ncn_id = p_npo_id;
    END;

    PROCEDURE query_comm_node (p_ncn_org     IN     NUMBER,
                               p_ncn_code    IN     VARCHAR2,
                               p_ncn_sname   IN     VARCHAR2,
                               p_ncn_name    IN     VARCHAR2,
                               p_res            OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (4);

        OPEN p_res FOR
            SELECT ncn.ncn_id,
                   -- OPFU
                   ncn.ncn_org,
                   ncn.ncn_code,
                   ncn.ncn_sname,
                   ncn.ncn_name
              FROM v_ndi_comm_node ncn
             WHERE     ncn.history_status =
                       api$dic_visit.c_history_status_actual
                   AND (p_ncn_code IS NULL OR ncn.ncn_code = p_ncn_code)
                   AND (   p_ncn_sname IS NULL
                        OR ncn.ncn_sname LIKE '%' || p_ncn_sname || '%'
                        OR ncn.ncn_sname LIKE p_ncn_sname || '%')
                   AND (   p_ncn_name IS NULL
                        OR ncn.ncn_name LIKE '%' || p_ncn_name || '%'
                        OR ncn.ncn_name LIKE p_ncn_name || '%')
                   AND (p_ncn_org IS NULL OR ncn.ncn_org = p_ncn_org);
    END;

    --===============================================
    --                NDI_STREET_TYPE
    --===============================================

    PROCEDURE save_street_type (
        p_nsrt_id     IN     ndi_street_type.nsrt_id%TYPE,
        p_nsrt_code   IN     ndi_street_type.nsrt_code%TYPE,
        p_nsrt_name   IN     ndi_street_type.nsrt_name%TYPE,
        p_new_id         OUT ndi_street_type.nsrt_id%TYPE)
    IS
        l_code_exists   NUMBER;
    BEGIN
        tools.check_user_and_raise (4);

        --Контроль уникальности кода
        SELECT SIGN (COUNT (*))
          INTO l_code_exists
          FROM v_ndi_street_type
         WHERE nsrt_code = p_nsrt_code AND nsrt_id <> NVL (p_nsrt_id, -999);

        IF l_code_exists = 1
        THEN
            raise_application_error (
                -20001,
                'Тип вулиці з кодом: ' || p_nsrt_code || '  вже існує');
        END IF;

        api$dic_document.save_street_type (
            p_nsrt_id          => p_nsrt_id,
            p_nsrt_code        => p_nsrt_code,
            p_nsrt_name        => p_nsrt_name,
            p_history_status   => api$dic_visit.c_history_status_actual,
            p_new_id           => p_new_id);
    END;

    PROCEDURE delete_street_type (p_nsrt_id ndi_street_type.nsrt_id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (4);
        api$dic_document.delete_street_type (
            p_nsrt_id          => p_nsrt_id,
            p_history_status   => api$dic_visit.c_history_status_historical);
    END;

    PROCEDURE get_street_type (
        p_nsrt_id   IN     ndi_street_type.nsrt_id%TYPE,
        p_res          OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (4);

        OPEN p_res FOR
            SELECT nt.nsrt_id, nt.nsrt_code, nt.nsrt_name
              FROM ndi_street_type nt
             WHERE     nt.history_status =
                       api$dic_visit.c_history_status_actual
                   AND nsrt_id = p_nsrt_id;
    END;

    PROCEDURE query_street_type (p_res OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (4);

        OPEN p_res FOR
            SELECT st.nsrt_id, st.nsrt_code, st.nsrt_name
              FROM ndi_street_type st
             WHERE st.history_status = api$dic_visit.c_history_status_actual;
    END;

    --===============================================
    --                NDI_STREET
    --===============================================
    -- сохраняем данные улицы
    PROCEDURE save_street_card (
        p_ns_id               IN     ndi_street.ns_id%TYPE,
        p_ns_code             IN     ndi_street.ns_code%TYPE,
        p_ns_name             IN     ndi_street.ns_name%TYPE,
        p_ns_kaot             IN     ndi_street.ns_kaot%TYPE,
        p_ns_nsrt             IN     ndi_street.ns_nsrt%TYPE,
        P_NS_ORG              IN     ndi_street.ns_org%TYPE,
        P_NS_HISTORY_STATUS   IN     ndi_street.history_status%TYPE,
        p_xml                 IN     CLOB,
        p_new_id                 OUT ndi_street.ns_id%TYPE)
    IS
        l_code_exists   NUMBER;
        l_ns_code       VARCHAR2 (10) := p_ns_code;
    BEGIN
        tools.check_user_and_raise (7);

        --Контроль уникальности кода
        SELECT SIGN (COUNT (*))
          INTO l_code_exists
          FROM v_ndi_street nd
         WHERE     nd.ns_code = p_ns_code
               AND nd.ns_org = P_NS_ORG
               AND (p_ns_id IS NULL OR nd.ns_id != p_ns_id)
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
        END IF;


        api$dic_document.save_street_card (
            p_ns_id            => p_ns_id,
            p_ns_code          => l_ns_code,
            p_ns_name          => p_ns_name,
            p_history_status   => P_NS_HISTORY_STATUS,
            p_ns_kaot          => p_ns_kaot,
            p_ns_nsrt          => p_ns_nsrt,
            p_ns_org           => P_NS_ORG,
            p_xml              => p_xml,
            p_new_id           => p_new_id);
    END;

    PROCEDURE delete_street (p_ns_id ndi_street.ns_id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (7);
        api$dic_document.delete_street (
            p_ns_id            => p_ns_id,
            p_history_status   => api$dic_visit.c_history_status_historical);
    END;

    PROCEDURE Set_Street_Kaot (p_kaot_id   IN ndi_street.ns_id%TYPE,
                               p_ids       IN VARCHAR2)
    IS
    BEGIN
        tools.check_user_and_raise (7);
        api$dic_document.Set_Street_Kaot (p_kaot_id   => p_kaot_id,
                                          p_ids       => p_ids);
    END;

    -- улица по id
    PROCEDURE get_street_card (p_ns_id   IN     ndi_street_type.nsrt_id%TYPE,
                               p_res1       OUT SYS_REFCURSOR,
                               p_res2       OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (5);

        OPEN p_res1 FOR
            SELECT ns.ns_id,
                   ns.ns_code,
                      (CASE
                           WHEN nsrt_name IS NOT NULL THEN nsrt_name || ' '
                           ELSE ''
                       END)
                   || ns.ns_name
                       AS ns_full_name,
                   -- NDI_KATOTTG
                   ns.ns_name,
                   ns.ns_kaot,
                   -- NDI_STREET_TYPE
                   ns.ns_nsrt,
                   (SELECT MAX (
                                  CASE
                                      WHEN     l1_name
                                                   IS NOT NULL
                                           AND l1_name !=
                                               kaot_name
                                      THEN
                                          l1_name || ', '
                                  END
                               || CASE
                                      WHEN     l2_name
                                                   IS NOT NULL
                                           AND l2_name !=
                                               kaot_name
                                      THEN
                                          l2_name || ', '
                                  END
                               || CASE
                                      WHEN     l3_name
                                                   IS NOT NULL
                                           AND l3_name !=
                                               kaot_name
                                      THEN
                                          l3_name || ', '
                                  END
                               || CASE
                                      WHEN     l4_name
                                                   IS NOT NULL
                                           AND l4_name !=
                                               kaot_name
                                      THEN
                                          l4_name || ', '
                                  END
                               || CASE
                                      WHEN     l5_name
                                                   IS NOT NULL
                                           AND l5_name !=
                                               kaot_name
                                      THEN
                                          l5_name || ', '
                                  END
                               || temp_name)
                      FROM (SELECT CASE
                                       WHEN Kaot_Kaot_L1 =
                                            Kaot_Id
                                       THEN
                                           Kaot_Name
                                       ELSE
                                           (SELECT X1.KAOT_FULL_NAME
                                              FROM uss_ndi.v_Ndi_Katottg
                                                   X1
                                             WHERE X1.Kaot_Id =
                                                   k.Kaot_Kaot_L1)
                                   END                 AS l1_name,
                                   CASE
                                       WHEN Kaot_Kaot_L2 =
                                            Kaot_Id
                                       THEN
                                           Kaot_Name
                                       ELSE
                                           (SELECT X1.KAOT_FULL_NAME
                                              FROM uss_ndi.v_Ndi_Katottg
                                                   X1
                                             WHERE X1.Kaot_Id =
                                                   k.Kaot_Kaot_L2)
                                   END                 AS l2_name,
                                   CASE
                                       WHEN Kaot_Kaot_L3 =
                                            Kaot_Id
                                       THEN
                                           Kaot_Name
                                       ELSE
                                           (SELECT X1.KAOT_FULL_NAME
                                              FROM uss_ndi.v_Ndi_Katottg
                                                   X1
                                             WHERE X1.Kaot_Id =
                                                   k.Kaot_Kaot_L3)
                                   END                 AS l3_name,
                                   CASE
                                       WHEN Kaot_Kaot_L4 =
                                            Kaot_Id
                                       THEN
                                           Kaot_Name
                                       ELSE
                                           (SELECT X1.KAOT_FULL_NAME
                                              FROM uss_ndi.v_Ndi_Katottg
                                                   X1
                                             WHERE X1.Kaot_Id =
                                                   k.Kaot_Kaot_L4)
                                   END                 AS l4_name,
                                   CASE
                                       WHEN Kaot_Kaot_L5 =
                                            Kaot_Id
                                       THEN
                                           Kaot_Name
                                       ELSE
                                           (SELECT X1.KAOT_FULL_NAME
                                              FROM uss_ndi.v_Ndi_Katottg
                                                   X1
                                             WHERE X1.Kaot_Id =
                                                   k.Kaot_Kaot_L5)
                                   END                 AS l5_name,
                                   k.kaot_name,
                                   k.kaot_full_name    AS temp_name
                              FROM uss_ndi.v_ndi_katottg k
                             WHERE k.kaot_id = ns.ns_kaot))
                       AS ns_kaot_name,
                   ns.history_status
                       AS ns_history_status,                          --#77488
                   ns.ns_org,                                         --#77488
                   (SELECT t.org_code || ' ' || t.org_name
                      FROM v_opfu t
                     WHERE t.org_id = ns.ns_org)
                       AS ns_org_name                                 --#77488
              FROM ndi_street  ns
                   LEFT JOIN uss_ndi.v_ndi_street_type ON ns_nsrt = nsrt_id
             WHERE ns_id = p_ns_id; -- AND ns.history_status = api$dic_visit.c_history_status_actual --#77488

        OPEN p_res2 FOR
            SELECT npo.npo_id          AS npo_id,
                   npo.npo_org         AS npo_org,
                   npo.npo_index       AS npo_index,
                   npo.npo_address     AS npo_address,
                   npo.npo_ncn         AS npo_ncn
              FROM ndi_npo_config  nnc
                   LEFT JOIN uss_ndi.v_ndi_post_office npo
                       ON nnc.nnc_npo = npo.npo_id
             WHERE     npo.history_status =
                       api$dic_visit.c_history_status_actual
                   AND nnc.nnc_ns = p_ns_id;
    END;

    -- список улиц по фильтру
    PROCEDURE query_street (p_ns_code             IN     VARCHAR2,
                            p_ns_name             IN     VARCHAR2,
                            p_ns_kaot             IN     NUMBER,
                            p_ns_nsrt             IN     NUMBER,
                            p_ns_history_status   IN     VARCHAR2,    --#77488
                            p_ns_org              IN     NUMBER,      --#77488
                            p_npo_index           IN     VARCHAR2,
                            p_res                    OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (5);

        OPEN p_res FOR
            SELECT st.ns_id,
                   st.ns_code,
                      (CASE
                           WHEN nsrt_name IS NOT NULL THEN nsrt_name || ' '
                           ELSE ''
                       END)
                   || st.ns_name
                       AS ns_full_name,
                   st.ns_name,
                   -- NDI_KATOTTG
                   st.ns_kaot,
                   -- NDI_STREET_TYPE
                   st.ns_nsrt,
                   (SELECT MAX (
                                  CASE
                                      WHEN     l1_name IS NOT NULL
                                           AND l1_name !=
                                               kaot_name
                                      THEN
                                          l1_name || ', '
                                  END
                               || CASE
                                      WHEN     l2_name IS NOT NULL
                                           AND l2_name !=
                                               kaot_name
                                      THEN
                                          l2_name || ', '
                                  END
                               || CASE
                                      WHEN     l3_name IS NOT NULL
                                           AND l3_name !=
                                               kaot_name
                                      THEN
                                          l3_name || ', '
                                  END
                               || CASE
                                      WHEN     l4_name IS NOT NULL
                                           AND l4_name !=
                                               kaot_name
                                      THEN
                                          l4_name || ', '
                                  END
                               || CASE
                                      WHEN     l5_name IS NOT NULL
                                           AND l5_name !=
                                               kaot_name
                                      THEN
                                          l5_name || ', '
                                  END
                               || temp_name)
                      FROM (SELECT CASE
                                       WHEN Kaot_Kaot_L1 = Kaot_Id
                                       THEN
                                           Kaot_Name
                                       ELSE
                                           (SELECT X1.KAOT_FULL_NAME
                                              FROM uss_ndi.v_Ndi_Katottg
                                                   X1
                                             WHERE X1.Kaot_Id =
                                                   k.Kaot_Kaot_L1)
                                   END                 AS l1_name,
                                   CASE
                                       WHEN Kaot_Kaot_L2 = Kaot_Id
                                       THEN
                                           Kaot_Name
                                       ELSE
                                           (SELECT X1.KAOT_FULL_NAME
                                              FROM uss_ndi.v_Ndi_Katottg
                                                   X1
                                             WHERE X1.Kaot_Id =
                                                   k.Kaot_Kaot_L2)
                                   END                 AS l2_name,
                                   CASE
                                       WHEN Kaot_Kaot_L3 = Kaot_Id
                                       THEN
                                           Kaot_Name
                                       ELSE
                                           (SELECT X1.KAOT_FULL_NAME
                                              FROM uss_ndi.v_Ndi_Katottg
                                                   X1
                                             WHERE X1.Kaot_Id =
                                                   k.Kaot_Kaot_L3)
                                   END                 AS l3_name,
                                   CASE
                                       WHEN Kaot_Kaot_L4 = Kaot_Id
                                       THEN
                                           Kaot_Name
                                       ELSE
                                           (SELECT X1.KAOT_FULL_NAME
                                              FROM uss_ndi.v_Ndi_Katottg
                                                   X1
                                             WHERE X1.Kaot_Id =
                                                   k.Kaot_Kaot_L4)
                                   END                 AS l4_name,
                                   CASE
                                       WHEN Kaot_Kaot_L5 = Kaot_Id
                                       THEN
                                           Kaot_Name
                                       ELSE
                                           (SELECT X1.KAOT_FULL_NAME
                                              FROM uss_ndi.v_Ndi_Katottg
                                                   X1
                                             WHERE X1.Kaot_Id =
                                                   k.Kaot_Kaot_L5)
                                   END                 AS l5_name,
                                   k.kaot_name,
                                   k.kaot_full_name    AS temp_name
                              FROM uss_ndi.v_ndi_katottg k
                             WHERE k.kaot_id = st.ns_kaot))
                       AS ns_kaot_name,
                   nt.nsrt_name,
                   --po.npo_index
                    (SELECT MAX (po.npo_index)
                       FROM ndi_post_office po
                      WHERE     po.npo_kaot = st.ns_kaot
                            AND po.npo_index = p_npo_index)
                       AS npo_index,
                   st.ns_org /*(SELECT MAX(z.org_id || ' ' || z.org_name) FROM v_opfu z WHERE z.org_id = st.ns_org)*/
                       AS ns_org_name
              FROM ndi_street  st
                   LEFT JOIN ndi_street_type nt ON nt.nsrt_id = st.ns_nsrt
             -- LEFT JOIN ndi_post_office po ON (po.npo_kaot = st.ns_kaot AND po.npo_index = p_npo_index)
             WHERE     (   p_ns_history_status IS NULL
                        OR st.history_status = p_ns_history_status)   --#77488
                   AND (   p_ns_name IS NULL
                        OR UPPER (st.ns_name) LIKE
                               '%' || UPPER (p_ns_name) || '%')
                   AND (p_ns_code IS NULL OR st.ns_code LIKE p_ns_code || '%')
                   AND (   p_npo_index IS NULL
                        OR EXISTS
                               (SELECT *
                                  FROM ndi_post_office po
                                 WHERE     po.npo_kaot = st.ns_kaot
                                       AND po.npo_index = p_npo_index))
                   AND (   p_ns_kaot IS NULL
                        OR st.ns_kaot IN
                               (SELECT z.kaot_id
                                  FROM ndi_katottg z
                                 WHERE    z.kaot_id = p_ns_kaot
                                       OR z.kaot_kaot_l1 = p_ns_kaot
                                       OR z.kaot_kaot_l2 = p_ns_kaot
                                       OR z.kaot_kaot_l3 = p_ns_kaot
                                       OR z.kaot_kaot_l4 = p_ns_kaot
                                       OR z.kaot_kaot_l5 = p_ns_kaot))
                   AND (   p_ns_org IS NULL
                        OR st.ns_org IN
                               (    SELECT org_id
                                      FROM v_opfu z
                                CONNECT BY PRIOR z.org_id = z.org_org
                                START WITH z.org_id = p_ns_org))
                   AND (p_ns_nsrt IS NULL OR st.ns_nsrt = p_ns_nsrt)
                   AND ROWNUM <= 1000;
    END;

    --===============================================
    --                NDI_KEKV
    --===============================================

    PROCEDURE save_kekv (p_nkv_id      IN     ndi_kekv.nkv_id%TYPE,
                         p_nkv_nkv     IN     ndi_kekv.nkv_nkv%TYPE,
                         p_nkv_code    IN     ndi_kekv.nkv_code%TYPE,
                         p_nkv_name    IN     ndi_kekv.nkv_name%TYPE,
                         p_nkv_sname   IN     ndi_kekv.nkv_sname%TYPE,
                         p_new_id         OUT ndi_kekv.nkv_id%TYPE)
    IS
        l_code_exists   NUMBER;
    BEGIN
        tools.check_user_and_raise (7);

        --Контроль уникальности кода
        SELECT SIGN (COUNT (*))
          INTO l_code_exists
          FROM ndi_kekv t
         WHERE     nkv_code = p_nkv_code
               AND t.history_status = 'A'
               AND nkv_id <> NVL (p_nkv_id, -999);

        IF l_code_exists = 1
        THEN
            raise_application_error (
                -20001,
                'КЕКВ з кодом: ' || p_nkv_code || '  вже існує');
        END IF;

        api$dic_document.save_kekv (
            p_nkv_id           => p_nkv_id,
            p_nkv_nkv          => p_nkv_nkv,
            p_nkv_code         => p_nkv_code,
            p_history_status   => api$dic_visit.c_history_status_actual,
            p_nkv_name         => p_nkv_name,
            p_nkv_sname        => p_nkv_sname,
            p_new_id           => p_new_id);
    END;

    PROCEDURE delete_kekv (p_nkv_id ndi_kekv.nkv_id%TYPE)
    IS
        l_cnt   NUMBER;
    BEGIN
        tools.check_user_and_raise (7);

        SELECT COUNT (*)
          INTO l_cnt
          FROM ndi_kekv t
         WHERE t.nkv_nkv = p_nkv_id AND t.history_status = 'A';

        IF (l_cnt > 0)
        THEN
            raise_application_error (
                -20000,
                'КЕКВ не може бути видалений, оскільки має підлеглі КЕКВ');
        END IF;

        api$dic_document.delete_kekv (
            p_nkv_id           => p_nkv_id,
            p_history_status   => api$dic_visit.c_history_status_historical);
    END;

    PROCEDURE get_kekv (p_nkv_id   IN     ndi_kekv.nkv_id%TYPE,
                        p_res         OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (5);

        OPEN p_res FOR
            SELECT nk.nkv_id,
                   -- NDI_KEKV
                   nk.nkv_nkv,
                   nk.nkv_code,
                   nk.nkv_name,
                   nk.nkv_sname
              FROM ndi_kekv nk
             WHERE     nk.history_status =
                       api$dic_visit.c_history_status_actual
                   AND nk.nkv_id = p_nkv_id;
    END;

    PROCEDURE query_kekv (p_res OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (5);

        OPEN p_res FOR
            SELECT nk.nkv_id,
                   -- NDI_KEKV
                   nk.nkv_nkv,
                   nk.nkv_code,
                   nk.nkv_name,
                   nk.nkv_sname,
                   vnk.nkv_sname     AS nkv_nkv_name
              FROM ndi_kekv  nk
                   LEFT JOIN v_ndi_kekv vnk ON nk.nkv_nkv = vnk.nkv_id
             WHERE nk.history_status = api$dic_visit.c_history_status_actual;
    END;

    --===============================================
    --                NDI_DELIVERY - DNET$DIC_DELIVERY
    --===============================================

    /*PROCEDURE save_delivery(p_nd_id      IN ndi_delivery.nd_id%TYPE,
                            p_nd_code    IN ndi_delivery.nd_code%TYPE,
                            p_nd_comment IN ndi_delivery.nd_comment%TYPE,
                            p_nd_npo     IN ndi_delivery.nd_npo%TYPE,
                            p_nd_tp      IN ndi_delivery.nd_tp%TYPE,
                            p_new_id     OUT ndi_delivery.nd_id%TYPE) IS
      l_code_exists NUMBER;
    BEGIN
      --Контроль уникальности кода
      SELECT sign(COUNT(*))
      INTO l_code_exists
      FROM ndi_delivery
      WHERE nd_code = p_nd_code
      AND nd_npo = p_nd_npo
      AND nd_id <> nvl(p_nd_id, -999);

      IF l_code_exists = 1 THEN
        raise_application_error(-20001,
                                'Доставна дільниця з кодом: ' || p_nd_code ||
                                ' вже існує');
      END IF;
      api$dic_document.save_delivery(p_nd_id          => p_nd_id,
                                     p_nd_code        => p_nd_code,
                                     p_history_status => api$dic_visit.c_history_status_actual,
                                     p_nd_comment     => p_nd_comment,
                                     p_nd_npo         => p_nd_npo,
                                     p_nd_tp          => p_nd_tp,
                                     p_new_id         => p_new_id);
    END;

    PROCEDURE delete_delivery(p_nd_id ndi_delivery.nd_id%TYPE) IS
    BEGIN
      api$dic_document.delete_delivery(p_nd_id          => p_nd_id,
                                       p_history_status => api$dic_visit.c_history_status_historical);
    END;

    PROCEDURE get_delivery(p_nd_id IN ndi_delivery.nd_id%TYPE,
                           p_main OUT SYS_REFCURSOR,
                           p_days OUT SYS_REFCURSOR,
                           p_ref OUT SYS_REFCURSOR) IS
    BEGIN
  --        tools.check_user_and_raise(1);
      OPEN p_main FOR
        SELECT t.*
          FROM ndi_delivery t
         WHERE t.history_status = api$dic_visit.c_history_status_actual
           AND t.nd_id = p_nd_id;

      OPEN p_days FOR
        SELECT t.*
          FROM ndi_delivery_day t
         WHERE t.ndd_nd = p_nd_id
           AND t.history_status = 'A';

      OPEN p_ref FOR
        SELECT t.*,
               d.ndd_day AS ndr_Ndd_Name,
               (SELECT MAX(zz.nsrt_name || ' ' || z.ns_name) FROM v_ndi_street z JOIN ndi_street_type zz ON (zz.nsrt_id = z.ns_nsrt) WHERE z.ns_id = t.ndr_ns) AS ndr_ns_name,
               (select MAX(
                       rtrim(case when l1_name is not null and l1_name != kaot_name then l1_name || ', ' end ||
                             case when l2_name is not null and l2_name != kaot_name then l2_name || ', ' end ||
                             case when l3_name is not null and l3_name != kaot_name then l3_name || ', ' end ||
                             case when l4_name is not null and l4_name != kaot_name then l4_name || ', ' end ||
                             case when l5_name is not null and l5_name != kaot_name then l5_name || ', ' end ||
                             name_temp
                       , ','))
                  from (SELECT Kaot_Id,
                                CASE
                                 WHEN Kaot_Kaot_L1 = Kaot_Id THEN
                                  Kaot_Name
                                 ELSE
                                  (SELECT Dic_Sname || ' ' || X1.Kaot_Name
                                     FROM uss_ndi.v_Ndi_Katottg X1,
                                          uss_ndi.v_Ddn_Kaot_Tp
                                    WHERE X1.Kaot_Id = m.Kaot_Kaot_L1
                                          AND Kaot_Tp = Dic_Value)
                                END AS l1_name,
                                CASE
                                 WHEN Kaot_Kaot_L2 = Kaot_Id THEN
                                  Kaot_Name
                                 ELSE
                                  (SELECT Dic_Sname || ' ' || X1.Kaot_Name
                                     FROM uss_ndi.v_Ndi_Katottg X1,
                                          uss_ndi.v_Ddn_Kaot_Tp
                                    WHERE X1.Kaot_Id = m.Kaot_Kaot_L2
                                          AND Kaot_Tp = Dic_Value)
                                END AS l2_name,
                                CASE
                                 WHEN Kaot_Kaot_L3 = Kaot_Id THEN
                                  Kaot_Name
                                 ELSE
                                  (SELECT Dic_Sname || ' ' || X1.Kaot_Name
                                     FROM uss_ndi.v_Ndi_Katottg X1,
                                          uss_ndi.v_Ddn_Kaot_Tp
                                    WHERE X1.Kaot_Id = m.Kaot_Kaot_L3
                                          AND Kaot_Tp = Dic_Value)
                                END AS l3_name,
                                CASE
                                 WHEN Kaot_Kaot_L4 = Kaot_Id THEN
                                  Kaot_Name
                                 ELSE
                                  (SELECT Dic_Sname || ' ' || X1.Kaot_Name
                                     FROM uss_ndi.v_Ndi_Katottg X1,
                                          uss_ndi.v_Ddn_Kaot_Tp
                                    WHERE X1.Kaot_Id = m.Kaot_Kaot_L4
                                          AND Kaot_Tp = Dic_Value)
                                END AS l4_name,
                                CASE
                                 WHEN Kaot_Kaot_L5 = Kaot_Id THEN
                                  Kaot_Name
                                 ELSE
                                  (SELECT Dic_Sname || ' ' || X1.Kaot_Name
                                     FROM uss_ndi.v_Ndi_Katottg X1,
                                          uss_ndi.v_Ddn_Kaot_Tp
                                    WHERE X1.Kaot_Id = m.Kaot_Kaot_L5
                                          AND Kaot_Tp = Dic_Value)
                                END AS l5_name,
                                kaot_name,
                                tp.Dic_Sname || ' ' || kaot_name as name_temp
                           FROM uss_ndi.v_Ndi_Katottg m
                           JOIN uss_ndi.v_Ddn_Kaot_Tp tp
                             ON m.Kaot_Tp = tp.Dic_Code
                          WHERE Kaot_id = t.ndr_kaot
                      ) t
                  ) AS ndr_kaot_name
          FROM ndi_delivery_ref t
          JOIN ndi_delivery_day d ON (d.ndd_id = t.ndr_ndd)
         WHERE d.ndd_nd = p_nd_id
           AND t.history_status = 'A';

    END;

    PROCEDURE query_delivery(p_nd_code    IN VARCHAR2,
                             p_nd_comment IN VARCHAR2,
                             p_nd_npo     IN VARCHAR2,
                             p_nd_tp      IN VARCHAR2,
                             p_org_id     IN NUMBER,
                             p_kaot_id    IN NUMBER,
                             p_res        OUT SYS_REFCURSOR) IS
    BEGIN
         --tools.check_user_and_raise(1);
      OPEN p_res FOR
        SELECT nd.nd_id,
               nd.nd_code,
               nd.nd_comment,
               -- NDI_POST_OFFICE
               nd.nd_npo,
               nd.nd_tp,
               dt.dic_sname,
               po.npo_address
          FROM ndi_delivery nd
          LEFT JOIN v_ddn_dlvr_tp dt ON (dt.dic_code = nd.nd_tp)
          LEFT JOIN v_ndi_post_office po ON (po.npo_id = nd.nd_npo)
         WHERE nd.history_status = api$dic_visit.c_history_status_actual
           AND (p_nd_comment IS NULL OR
                 nd.nd_comment LIKE '%' || p_nd_comment || '%' OR
                 nd.nd_comment LIKE p_nd_comment || '%')
           AND (p_nd_code IS NULL OR nd.nd_code = p_nd_code)
           AND (p_nd_npo IS NULL OR nd.nd_npo = p_nd_npo)
           AND (p_nd_tp IS NULL OR nd.nd_tp = p_nd_tp)
           AND (p_org_id IS NULL OR po.npo_org = p_org_id)
           AND (p_kaot_id IS NULL OR po.npo_kaot = p_kaot_id)
           AND rownum <= 500
        ;
    END;

    --NDI_DELIVERY_DAY
    PROCEDURE query_delivery_day(p_ndd_nd IN VARCHAR2,
                                 p_res    OUT SYS_REFCURSOR) IS
    BEGIN
          tools.check_user_and_raise(1);
      OPEN p_res FOR
        SELECT ndd_id,
               -- NDI_DELIVERY
               ndd_nd, ndd_day, po.npo_address
          FROM ndi_delivery_day ndd
          LEFT JOIN ndi_delivery nd ON nd.nd_id = ndd.ndd_nd
          LEFT JOIN v_ndi_post_office po ON po.npo_id = nd.nd_npo
         WHERE ndd.history_status = api$dic_visit.c_history_status_actual
           AND (p_ndd_nd IS NULL OR ndd.ndd_nd = p_ndd_nd)
         ORDER BY ndd.ndd_day;
    END;*/

    --===============================================
    --                NDI_NB_FILIA
    --===============================================

    PROCEDURE save_nb_filia (
        p_nbf_id      IN     ndi_nb_filia.nbf_id%TYPE,
        p_nbf_nb      IN     ndi_nb_filia.nbf_nb%TYPE,
        p_nbf_name    IN     ndi_nb_filia.nbf_name%TYPE,
        p_nbf_sname   IN     ndi_nb_filia.nbf_sname%TYPE,
        p_nbf_org     IN     ndi_nb_filia.nbf_org%TYPE,
        p_nbf_code    IN     ndi_nb_filia.nbf_code%TYPE,
        p_new_id         OUT ndi_nb_filia.nbf_id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (5);
        api$dic_document.save_nb_filia (
            p_nbf_id           => p_nbf_id,
            p_nbf_nb           => p_nbf_nb,
            p_history_status   => api$dic_visit.c_history_status_actual,
            p_nbf_name         => p_nbf_name,
            p_nbf_sname        => p_nbf_sname,
            p_nbf_org          => p_nbf_org,
            p_nbf_code         => p_nbf_code,
            p_new_id           => p_new_id);
    END;

    PROCEDURE delete_nb_filia (p_nbf_id ndi_nb_filia.nbf_id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (5);
        api$dic_document.delete_nb_filia (
            p_nbf_id           => p_nbf_id,
            p_history_status   => api$dic_visit.c_history_status_historical);
    END;

    PROCEDURE get_nb_filia (p_nbf_id   IN     ndi_nb_filia.nbf_id%TYPE,
                            p_res         OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (5);

        OPEN p_res FOR
            SELECT nf.nbf_id,
                   -- NDI_BANK
                   nf.nbf_nb,
                   nf.nbf_name,
                   nf.nbf_sname,
                   nf.nbf_org,
                   nf.nbf_code
              FROM ndi_nb_filia nf
             WHERE     nf.history_status =
                       api$dic_visit.c_history_status_actual
                   AND nf.nbf_id = p_nbf_id;
    END;

    PROCEDURE query_nb_filia (p_nbf_nb      IN     VARCHAR2,
                              p_nbf_name    IN     VARCHAR2,
                              p_nbf_sname   IN     VARCHAR2,
                              p_nbf_code    IN     VARCHAR2,
                              p_res            OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (5);

        OPEN p_res FOR
            SELECT nf.nbf_id,
                   -- NDI_BANK
                   nf.nbf_nb,
                   nf.nbf_name,
                   nf.nbf_sname,
                   nf.nbf_org,
                   nf.nbf_code,
                   nb.nb_sname
              FROM ndi_nb_filia  nf
                   LEFT JOIN v_ndi_bank nb ON nb.nb_id = nf.nbf_nb
             WHERE     nf.history_status =
                       api$dic_visit.c_history_status_actual
                   AND (   p_nbf_name IS NULL
                        OR UPPER (nf.nbf_name) LIKE
                               '%' || UPPER (p_nbf_name) || '%') -- OR nf.nbf_name LIKE p_nbf_name || '%')
                   AND (   p_nbf_sname IS NULL
                        OR UPPER (nf.nbf_sname) LIKE
                               '%' || UPPER (p_nbf_sname) || '%') -- OR nf.nbf_sname LIKE p_nbf_sname || '%')
                   AND (p_nbf_nb IS NULL OR nf.nbf_nb = p_nbf_nb)
                   AND (p_nbf_code IS NULL OR nf.nbf_code = p_nbf_code);
    END;

    --===============================================
    --                NDI_BUDGET
    --===============================================

    PROCEDURE save_budget (p_nbu_id     IN     ndi_budget.nbu_id%TYPE,
                           p_nbu_tp     IN     ndi_budget.nbu_tp%TYPE,
                           p_nbu_code   IN     ndi_budget.nbu_code%TYPE,
                           p_nbu_name   IN     ndi_budget.nbu_name%TYPE,
                           p_new_id        OUT ndi_budget.nbu_id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (7);
        api$dic_document.save_budget (
            p_nbu_id           => p_nbu_id,
            p_nbu_tp           => p_nbu_tp,
            p_nbu_code         => p_nbu_code,
            p_nbu_name         => p_nbu_name,
            p_history_status   => api$dic_visit.c_history_status_actual,
            p_nbu_hs_upd       => NULL,
            p_nbu_hs_del       => NULL,
            p_new_id           => p_new_id);
    END;

    PROCEDURE delete_budget (p_nbu_id ndi_budget.nbu_id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (7);
        api$dic_document.delete_budget (p_nbu_id => p_nbu_id);
    END;

    PROCEDURE get_budget (p_nbu_id   IN     ndi_budget.nbu_id%TYPE,
                          p_res         OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (5);

        OPEN p_res FOR
            SELECT nbu_id,
                   nbu_code,
                   nbu_name,
                   nbu_tp,
                   nt.dic_sname     AS nbu_tp_name
              FROM ndi_budget  b
                   LEFT JOIN v_ddn_nbu_tp nt ON nt.dic_value = b.nbu_tp
             WHERE     b.nbu_id = p_nbu_id
                   AND b.history_status =
                       api$dic_visit.c_history_status_actual;
    END;

    PROCEDURE query_budget (p_nbu_tp     IN     VARCHAR2,
                            p_nbu_code   IN     VARCHAR2,
                            p_nbu_name   IN     VARCHAR2,
                            p_res           OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (5);

        OPEN p_res FOR
              SELECT nbu_id,
                     nbu_code,
                     nbu_name,
                     nbu_tp,
                     nt.dic_sname     AS nbu_tp_name
                FROM ndi_budget b
                     LEFT JOIN v_ddn_nbu_tp nt ON nt.dic_value = b.nbu_tp
               WHERE     b.history_status =
                         api$dic_visit.c_history_status_actual
                     AND (   p_nbu_tp IS NULL
                          OR b.nbu_tp LIKE '%' || p_nbu_tp || '%'
                          OR b.nbu_tp LIKE p_nbu_tp || '%')
                     AND (   p_nbu_code IS NULL
                          OR b.nbu_code LIKE '%' || p_nbu_code || '%'
                          OR b.nbu_code LIKE p_nbu_code || '%')
                     AND (   p_nbu_name IS NULL
                          OR b.nbu_name LIKE '%' || p_nbu_name || '%'
                          OR b.nbu_name LIKE p_nbu_name || '%')
            ORDER BY b.nbu_name, b.nbu_code;
    END;

    --===============================================
    --                NDI_FUNDING_SOURCE
    --===============================================

    PROCEDURE save_funding_source (
        p_nfs_id     IN     ndi_funding_source.nfs_id%TYPE,
        p_nfs_nbg    IN     ndi_funding_source.nfs_nbg%TYPE,
        p_nfs_nbu    IN     ndi_funding_source.nfs_nbu%TYPE,
        p_nfs_name   IN     ndi_funding_source.nfs_name%TYPE,
        p_nfs_tp     IN     ndi_funding_source.nfs_tp%TYPE,
        p_new_id        OUT ndi_funding_source.nfs_id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (7);
        api$dic_document.save_funding_source (
            p_nfs_id           => p_nfs_id,
            p_nfs_nbg          => p_nfs_nbg,
            p_nfs_nbu          => p_nfs_nbu,
            p_nfs_name         => p_nfs_name,
            p_nfs_tp           => p_nfs_tp,
            p_history_status   => api$dic_visit.c_history_status_actual,
            p_nfs_hs_upd       => NULL,
            p_nfs_hs_del       => NULL,
            p_new_id           => p_new_id);
    END;

    PROCEDURE delete_funding_source (p_nfs_id ndi_funding_source.nfs_id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (7);
        api$dic_document.delete_funding_source (p_nfs_id => p_nfs_id);
    END;

    PROCEDURE get_funding_source (
        p_nfs_id   IN     ndi_funding_source.nfs_id%TYPE,
        p_res         OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (5);

        OPEN p_res FOR
            SELECT fs.nfs_id,
                   -- NDI_BUDGET_PROGRAM
                   fs.nfs_nbg,
                   bp.nbg_sname     AS nfs_nbg_sname,
                   bp.nbg_name      AS nfs_nbg_name,
                   -- NDI_BUDGET
                   fs.nfs_nbu,
                   b.nbu_name       AS nfs_nbu_name,
                   fs.nfs_name,
                   fs.nfs_tp,
                   nt.DIC_SNAME     AS nfs_tp_name
              FROM v_ndi_funding_source  fs
                   LEFT JOIN v_ndi_budget_program bp
                       ON fs.nfs_nbg = bp.nbg_id
                   LEFT JOIN v_ndi_budget b ON fs.nfs_nbu = b.nbu_id
                   LEFT JOIN v_ddn_nfs_tp nt ON fs.nfs_tp = nt.DIC_VALUE
             WHERE     fs.nfs_id = p_nfs_id
                   AND fs.history_status =
                       api$dic_visit.c_history_status_actual;
    END;

    PROCEDURE query_funding_source (p_nfs_nbg    IN     NUMBER,
                                    p_nfs_nbu    IN     NUMBER,
                                    p_nfs_name   IN     VARCHAR2,
                                    p_nfs_tp     IN     VARCHAR2,
                                    p_res           OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (5);

        OPEN p_res FOR
              SELECT fs.nfs_id,
                     -- NDI_BUDGET_PROGRAM
                     fs.nfs_nbg,
                     bp.nbg_sname     AS nfs_nbg_sname,
                     bp.nbg_name      AS nfs_nbg_name,
                     -- NDI_BUDGET
                     fs.nfs_nbu,
                     b.nbu_name       AS nfs_nbu_name,
                     fs.nfs_name,
                     fs.nfs_tp,
                     nt.DIC_SNAME     AS nfs_tp_name
                FROM ndi_funding_source fs
                     LEFT JOIN v_ndi_budget_program bp
                         ON fs.nfs_nbg = bp.nbg_id
                     LEFT JOIN v_ndi_budget b ON fs.nfs_nbu = b.nbu_id
                     LEFT JOIN v_ddn_nfs_tp nt ON fs.nfs_tp = nt.DIC_VALUE
               WHERE        fs.history_status =
                            api$dic_visit.c_history_status_actual
                        AND (   p_nfs_name IS NULL
                             OR fs.nfs_name LIKE '%' || p_nfs_name || '%'
                             OR fs.nfs_name LIKE p_nfs_name || '%')
                        AND (   p_nfs_tp IS NULL
                             OR fs.nfs_tp LIKE '%' || p_nfs_tp || '%'
                             OR fs.nfs_tp LIKE p_nfs_tp || '%')
                        AND p_nfs_nbg IS NULL
                     OR fs.nfs_nbg = p_nfs_nbg AND p_nfs_nbu IS NULL
                     OR fs.nfs_nbu = p_nfs_nbu
            ORDER BY b.nbu_name, bp.nbg_name;
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
    BEGIN
        tools.check_user_and_raise (7);

        --Контроль уникальности кода
        IF p_nmz_start_dt > p_nmz_stop_dt
        THEN
            raise_application_error (
                -20010,
                   'Некоректне значення дати: діє з '
                || p_nmz_start_dt
                || ' більше '
                || p_nmz_stop_dt
                || '');
        END IF;

        api$dic_document.save_ndi_min_zp (p_nmz_start_dt,
                                          p_nmz_stop_dt,
                                          p_nmz_month_sum,
                                          p_nmz_hour_sum);
    END;

    PROCEDURE delete_ndi_min_zp (p_nmz_id ndi_min_zp.nmz_id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (7);
        api$dic_document.delete_ndi_min_zp (p_nmz_id => p_nmz_id);
    END;



    PROCEDURE query_ndi_min_zp (p_nmz_start_dt   IN     DATE,
                                p_nmz_stop_dt    IN     DATE,
                                p_res               OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (8);

        IF p_nmz_start_dt > p_nmz_stop_dt
        THEN
            raise_application_error (
                -20010,
                   'Некоректне значення дати: діє з '
                || p_nmz_start_dt
                || ' більше '
                || p_nmz_stop_dt
                || ' ');
        END IF;

        OPEN p_res FOR
              SELECT nmz.*
                FROM v_ndi_min_zp nmz
               WHERE     nmz.history_status =
                         api$dic_visit.c_history_status_actual
                     AND (   p_nmz_start_dt IS NULL
                          OR nmz.nmz_start_dt >= p_nmz_start_dt)
                     AND (   p_nmz_stop_dt IS NULL
                          OR nmz.nmz_stop_dt <= p_nmz_stop_dt)
            ORDER BY nmz_start_dt DESC;
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
    BEGIN
        tools.check_user_and_raise (7);

        --Контроль уникальности кода
        IF p_nlsl_start_dt > p_nlsl_stop_dt
        THEN
            raise_application_error (
                -20010,
                   'Некоректне значення дати: діє з '
                || p_nlsl_start_dt
                || ' більше '
                || p_nlsl_stop_dt
                || '');
        END IF;

        api$dic_document.save_lgw_sub_level (p_nlsl_start_dt,
                                             p_nlsl_stop_dt,
                                             p_nlsl_18year_level,
                                             p_nlsl_work_able_level,
                                             p_nlsl_work_unable_level);
    END;

    PROCEDURE delete_lgw_sub_level (p_nlsl_id ndi_lgw_sub_level.nlsl_id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (7);
        api$dic_document.delete_lgw_sub_level (p_nlsl_id => p_nlsl_id);
    END;

    PROCEDURE query_lgw_sub_level (p_nlsl_start_dt   IN     DATE,
                                   p_nlsl_stop_dt    IN     DATE,
                                   p_res                OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (8);

        IF p_nlsl_start_dt > p_nlsl_stop_dt
        THEN
            raise_application_error (
                -20010,
                   'Некоректне значення дати: діє з '
                || p_nlsl_start_dt
                || ' більше '
                || p_nlsl_stop_dt
                || ' ');
        END IF;

        OPEN p_res FOR
            SELECT nlsl.*
              FROM v_ndi_lgw_sub_level nlsl
             WHERE     nlsl.history_status =
                       api$dic_visit.c_history_status_actual
                   AND (   p_nlsl_start_dt IS NULL
                        OR p_nlsl_start_dt <= nlsl.nlsl_start_dt)
                   AND (   p_nlsl_stop_dt IS NULL
                        OR p_nlsl_stop_dt >= nlsl.nlsl_stop_dt);
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
        tools.check_user_and_raise (3);
        api$dic_document.save_ndi_pay_config (
            p_nfpc_id       => p_nfpc_id,
            p_nfpc_pay_tp   => p_nfpc_pay_tp,
            p_nfpc_nb       => p_nfpc_nb,
            p_nfpc_ncn      => p_nfpc_ncn,
            p_nfpc_dppa     => p_nfpc_dppa,
            p_new_id        => p_new_id);
    END;

    PROCEDURE delete_ndi_pay_config (
        p_nfpc_id   ndi_fin_pay_config.nfpc_id%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (3);
        api$dic_document.delete_ndi_pay_config (p_nfpc_id => p_nfpc_id);
    END;



    PROCEDURE query_ndi_pay_config (
        p_nfpc_pay_tp         IN     VARCHAR2,  --Спосіб виплат - (BANK, POST)
        p_nfpc_nb_mfo         IN     VARCHAR2,                     --МФО банка
        p_nfpc_nb_name        IN     VARCHAR2,                  -- Назва банку
        p_nfpc_dpp_name       IN     VARCHAR2,                   -- Контрагент
        --p_NFPC_NB_ID in NUMBER, --Банк/Філія отримувачів платежів
        p_nfpc_ncn_name       IN     VARCHAR2,                  --вузол з'язку
        p_nfpc_dppa_account   IN     VARCHAR2,                       --рахунок
        p_dppa_nbg            IN     NUMBER,             -- Бюджетна программа
        p_res                    OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (12); -- #76808 Надати доступ до довідників на перегляд для користувачів W_ESR_KPAYROLL та W_ESR_BUDGET_INSP

        OPEN p_res FOR
            SELECT conf.*
              FROM (SELECT fpc.nfpc_id         AS nfpc_id,
                           fpc.nfpc_pay_tp     AS nfpc_pay_tp,
                           fpc.nfpc_nb         AS nfpc_nb,
                           fpc.nfpc_ncn        AS nfpc_ncn,
                           fpc.nfpc_dppa       AS nfpc_dppa,
                           --Спосіб виплати
                           dat.dic_sname       AS nfpc_pay_tp_name,
                           --Банк/філія
                           nb.nb_sname         AS nfpc_nb_name,
                           --Вузол зв'язку
                           ncn.ncn_sname       AS nfpc_ncn_name,
                           --Контрагент
                           npp.dpp_sname       AS nfpc_dpp_name,
                              --Рахунок
                              nppa.dppa_account
                           || CASE
                                  WHEN nppa.dppa_nb_filia_num IS NOT NULL
                                  THEN
                                         '(філія №'
                                      || nppa.dppa_nb_filia_num
                                      || ')'
                              END              AS nfpc_dppa_account,
                           npp.dpp_tax_code    AS nfpc_tax_code,
                           bp.nbg_sname        AS dppa_nbg_name
                      FROM v_ndi_fin_pay_config  fpc
                           LEFT JOIN v_ndi_pay_person_acc nppa
                               ON nppa.dppa_id = fpc.nfpc_dppa
                           LEFT JOIN v_ndi_budget_program bp
                               ON (bp.nbg_id = nppa.dppa_nbg)
                           LEFT JOIN v_ndi_pay_person npp
                               ON npp.dpp_id = nppa.dppa_dpp
                           LEFT JOIN v_ndi_comm_node ncn
                               ON ncn.ncn_id = fpc.nfpc_ncn
                           LEFT JOIN v_ndi_bank nb ON nb.nb_id = fpc.nfpc_nb
                           LEFT JOIN v_ddn_apm_tp dat
                               ON dat.dic_value = fpc.nfpc_pay_tp
                     WHERE     fpc.history_status =
                               api$dic_visit.c_history_status_actual
                           AND (   p_nfpc_pay_tp IS NULL
                                OR dat.dic_value = p_nfpc_pay_tp)
                           AND (   p_nfpc_nb_mfo IS NULL
                                OR nb.nb_mfo = p_nfpc_nb_mfo)
                           AND (   p_nfpc_dppa_account IS NULL
                                OR nppa.dppa_account = p_nfpc_dppa_account
                                OR nppa.dppa_account =
                                   'UA' || p_nfpc_dppa_account)
                           AND (   p_dppa_nbg IS NULL
                                OR nppa.dppa_nbg = p_dppa_nbg)) conf
             WHERE     (   p_nfpc_nb_name IS NULL
                        OR UPPER (nfpc_nb_name) LIKE
                               UPPER ('%' || p_nfpc_nb_name || '%'))
                   AND (   p_nfpc_dpp_name IS NULL
                        OR UPPER (nfpc_dpp_name) LIKE
                               UPPER ('%' || p_nfpc_dpp_name || '%'))
                   AND (   p_nfpc_ncn_name IS NULL
                        OR UPPER (nfpc_ncn_name) LIKE
                               UPPER ('%' || p_nfpc_ncn_name || '%'));
    END;

    PROCEDURE get_ndi_pay_config (
        p_nfpc_id   IN     ndi_fin_pay_config.nfpc_id%TYPE,
        p_res          OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.check_user_and_raise (3); -- #76808 Надати доступ до довідників на перегляд для користувачів W_ESR_KPAYROLL та W_ESR_BUDGET_INSP

        OPEN p_res FOR
            SELECT fpc.nfpc_id           AS nfpc_id,
                   fpc.nfpc_pay_tp       AS nfpc_pay_tp,
                   fpc.nfpc_nb           AS nfpc_nb,
                   fpc.nfpc_ncn          AS nfpc_ncn,
                   fpc.nfpc_dppa         AS nfpc_dppa,
                   --Спосіб виплати
                   dat.DIC_SNAME         AS nfpc_pay_tp_name,
                   --Банк/філія
                   nb.nb_sname           AS nfpc_nb_name,
                   --Вузол зв'язку
                   ncn.ncn_sname         AS nfpc_ncn_name,
                   --Контрагент
                   npp.dpp_sname         AS nfpc_dpp_name,
                   --Рахунок
                   nppa.dppa_account     AS nfpc_dppa_account,
                   npp.dpp_tax_code      AS nfpc_tax_code
              FROM v_ndi_fin_pay_config  fpc
                   LEFT JOIN v_ndi_pay_person_acc nppa
                       ON nppa.dppa_id = fpc.nfpc_dppa
                   LEFT JOIN v_ndi_pay_person npp
                       ON npp.dpp_id = nppa.dppa_dpp
                   LEFT JOIN v_ndi_comm_node ncn ON ncn.ncn_id = fpc.nfpc_ncn
                   LEFT JOIN v_ndi_bank nb ON nb.nb_id = fpc.nfpc_nb
                   LEFT JOIN v_ddn_apm_tp dat
                       ON dat.DIC_VALUE = fpc.nfpc_pay_tp
             WHERE fpc.nfpc_id = p_nfpc_id;
    END;


    --===============================================
    --                NDI_SITE + NDI_NIS_USERS
    --===============================================
    PROCEDURE query_ndi_site (p_res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR SELECT nis_id,
                              nis_name,
                              history_status,
                              nis_order
                         FROM ndi_site st
                        WHERE st.com_org = tools.getcurrorg;
    END;


    PROCEDURE get_ndi_site (p_nis_id    IN     ndi_site.nis_id%TYPE,
                            site_cur       OUT SYS_REFCURSOR,
                            users_cur      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN site_cur FOR SELECT nis_id,
                                 nis_name,
                                 history_status,
                                 nis_order
                            FROM v_ndi_site
                           WHERE nis_id = p_nis_id;


        OPEN users_cur FOR
            SELECT nisu_id,
                   au.wu_pib       AS nisu_wu_pib,
                   au.wu_login     AS nisu_wu_login,
                   history_status
              FROM v_ndi_nis_users  u
                   LEFT JOIN ikis_sysweb.v$all_users au
                       ON au.wu_id = u.nisu_wu
             WHERE u.nisu_nis = p_nis_id;
    END;


    PROCEDURE delete_ndi_site (p_nis_id NDI_SITE.NIS_ID%TYPE)
    IS
    BEGIN
        api$dic_document.delete_ndi_site (p_nis_id => p_nis_id);
    END;

    ----
    PROCEDURE save_ndi_site (p_nis_id      IN     ndi_site.nis_id%TYPE,
                             p_nis_name    IN     ndi_site.nis_name%TYPE,
                             p_nis_order   IN     ndi_site.nis_order%TYPE,
                             p_new_id         OUT ndi_site.nis_id%TYPE)
    IS
    BEGIN
        api$dic_document.save_ndi_site (p_nis_id      => p_nis_id,
                                        p_nis_name    => p_nis_name,
                                        p_nis_order   => p_nis_order,
                                        p_new_id      => p_new_id);
    END;

    PROCEDURE delete_ndi_nis_user (p_nisu_id ndi_nis_users.nisu_id%TYPE)
    IS
    BEGIN
        api$dic_document.delete_ndi_nis_user (p_nisu_id => p_nisu_id);
    END;

    PROCEDURE set_one_user (
        p_wu_id           ikis_sysweb.v$all_users.wu_id%TYPE,
        p_nis_id   IN     ndi_site.nis_id%TYPE,
        p_new_id      OUT ndi_nis_users.nisu_id%TYPE)
    IS
    BEGIN
        api$dic_document.set_one_user (p_wu_id    => p_wu_id,
                                       p_nis_id   => p_nis_id,
                                       p_new_id   => p_new_id);
    END;

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
        p_new_id               OUT ndi_normative_act.nna_id%TYPE)
    IS
    BEGIN
        api$dic_document.save_normative_act (
            p_nna_id            => p_nna_id,
            p_nna_tp            => p_nna_tp,
            p_nna_publisher     => p_nna_publisher,
            p_nna_dt            => p_nna_dt,
            p_nna_num           => p_nna_num,
            p_nna_description   => p_nna_description,
            p_nna_url           => p_nna_url,
            p_nna_asof_dt       => p_nna_asof_dt,
            p_nna_start_dt      => p_nna_start_dt,
            p_nna_nna_main      => p_nna_nna_main,
            p_new_id            => p_new_id);
    END;

    PROCEDURE delete_normative_act (
        p_nna_id   IN ndi_normative_act.nna_id%TYPE)
    IS
    BEGIN
        api$dic_document.delete_normative_act (p_nna_id => p_nna_id);
    END;

    PROCEDURE get_normative_act (
        p_nna_id   IN     ndi_normative_act.nna_id%TYPE,
        p_res         OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR SELECT t.*
                         FROM ndi_normative_act t
                        WHERE t.nna_id = p_nna_id;
    END;

    PROCEDURE query_normative_act (p_nna_dt    IN     DATE,
                                   p_nna_num   IN     VARCHAR2,
                                   p_res          OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR
            SELECT na.*,
                   dnt.dic_name    AS nna_tp_name,
                   CASE
                       WHEN ma.nna_id IS NOT NULL
                       THEN
                              mtp.dic_name
                           || ' №'
                           || ma.nna_num
                           || ' від '
                           || TO_CHAR (ma.nna_dt, 'DD.MM.YYYY')
                   END             AS nna_main_name
              FROM v_ndi_normative_act  na
                   LEFT JOIN v_ddn_nna_tp dnt ON dnt.DIC_VALUE = na.nna_tp
                   LEFT JOIN v_ndi_normative_act ma
                       ON (ma.nna_id = na.nna_nna_main)
                   LEFT JOIN v_ddn_nna_tp mtp ON (mtp.DIC_VALUE = ma.nna_tp)
             WHERE     na.history_status = 'A'
                   AND (p_nna_dt IS NULL OR na.nna_dt = p_nna_dt)
                   AND (p_nna_num IS NULL OR na.nna_num LIKE p_nna_num || '%');
    END;
END dnet$dic_document;
/