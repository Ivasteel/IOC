/* Formatted on 8/12/2025 5:55:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.DNET$DIC_DOCUMENT_QQ
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

    PROCEDURE query_post_office (p_npo_index     IN     VARCHAR2,
                                 p_npo_address   IN     VARCHAR2,
                                 p_npo_ncn       IN     NUMBER,
                                 p_npo_kaot      IN     NUMBER,
                                 p_res              OUT SYS_REFCURSOR);

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
    --                NDI_FUNCTIONARY
    --===============================================

    PROCEDURE SAVE_FUNCTIONARY (
        P_FNC_ID      IN     NDI_FUNCTIONARY.FNC_ID%TYPE,
        --p_COM_ORG IN NDI_FUNCTIONARY.COM_ORG%TYPE,
        P_FNC_FN      IN     NDI_FUNCTIONARY.FNC_FN%TYPE,
        P_FNC_LN      IN     NDI_FUNCTIONARY.FNC_LN%TYPE,
        P_FNC_MN      IN     NDI_FUNCTIONARY.FNC_MN%TYPE,
        P_FNC_POST    IN     NDI_FUNCTIONARY.FNC_POST%TYPE,
        P_FNC_PHONE   IN     NDI_FUNCTIONARY.FNC_PHONE%TYPE,
        P_FNC_TP      IN     NDI_FUNCTIONARY.FNC_TP%TYPE,
        P_NEW_ID         OUT NDI_FUNCTIONARY.FNC_ID%TYPE);

    PROCEDURE DELETE_FUNCTIONARY (P_FNC_ID NDI_FUNCTIONARY.FNC_ID%TYPE);

    PROCEDURE GET_FUNCTIONARY (P_FNC_ID   IN     NDI_FUNCTIONARY.FNC_ID%TYPE,
                               P_RES         OUT SYS_REFCURSOR);

    PROCEDURE QUERY_FUNCTIONARY (--p_COM_ORG IN NUMBER,
                                 P_FNC_FN      IN     VARCHAR2,
                                 P_FNC_LN      IN     VARCHAR2,
                                 P_FNC_MN      IN     VARCHAR2,
                                 P_FNC_POST    IN     VARCHAR2,
                                 P_FNC_PHONE   IN     VARCHAR2,
                                 P_FNC_TP      IN     VARCHAR2,
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
        p_new_id               OUT ndi_normative_act.nna_id%TYPE);


    PROCEDURE delete_normative_act (
        p_nna_id   IN ndi_normative_act.nna_id%TYPE);

    PROCEDURE get_normative_act (
        p_nna_id   IN     ndi_normative_act.nna_id%TYPE,
        p_res         OUT SYS_REFCURSOR);

    PROCEDURE query_normative_act (p_nna_dt    IN     DATE,
                                   p_nna_num   IN     VARCHAR2,
                                   p_res          OUT SYS_REFCURSOR);

    PROCEDURE set_street (
        p_ns_id            IN     ndi_street.ns_id%TYPE,
        p_ns_code          IN     ndi_street.ns_code%TYPE,
        p_ns_name          IN     ndi_street.ns_name%TYPE,
        p_ns_kaot          IN     ndi_street.ns_kaot%TYPE,
        p_ns_nsrt          IN     ndi_street.ns_nsrt%TYPE,
        p_ns_org           IN     ndi_street.ns_org%TYPE,
        p_history_status   IN     ndi_street.history_status%TYPE,
        p_new_id              OUT ndi_street.ns_id%TYPE);
END dnet$dic_document_qq;
/
