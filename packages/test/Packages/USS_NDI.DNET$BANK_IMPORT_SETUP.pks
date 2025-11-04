/* Formatted on 8/12/2025 5:55:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.DNET$BANK_IMPORT_SETUP
IS
    -- Author  : BOGDAN
    -- Created : 02.09.2021 13:15:09
    -- Purpose : Налаштування імпорту/експорту платіжних доручень/банківських виписок по банкам

    -- список банків
    PROCEDURE GET_BANKS_LIST (RES_CUR OUT SYS_REFCURSOR);

    -- вичитати налаштування імпорту по банку
    PROCEDURE GET_BANK_STATEMENT_SETTINGS (p_nbi_id   IN     NUMBER,
                                           RES_CUR       OUT SYS_REFCURSOR);

    -- вичитати налаштування імпорту по банківському рахунку
    PROCEDURE GET_BANK_STATEMENT_SETTINGS_BY_DPPA (
        p_dppa_id   IN     NUMBER,
        RES_CUR        OUT SYS_REFCURSOR);

    -- додати нове налаштування імпорту для банку
    PROCEDURE ADD_NEW_BANK_STATEMENT_SETTINGS (
        P_nbi_ID                         OUT NUMBER,
        P_nbi_NB                      IN     NUMBER,
        P_nbi_TP                      IN     VARCHAR2,
        P_nbi_NAME                    IN     VARCHAR2,
        P_nbi_ENCODING                IN     VARCHAR2,
        P_nbi_IS_DIFF_PAYER           IN     VARCHAR2,
        P_nbi_IN_CODE                 IN     VARCHAR2,
        P_nbi_IN_FIELD                IN     VARCHAR2,
        P_nbi_RECEIP_EDRPOU_FIELD     IN     VARCHAR2,
        P_nbi_PAYER_EDRPOU_FIELD      IN     VARCHAR2,
        P_nbi_PURPOSE_FIELD           IN     VARCHAR2,
        P_nbi_DT_FIELD                IN     VARCHAR2,
        P_nbi_DOC_NUM_FIELD           IN     VARCHAR2,
        P_nbi_RECEIP_NAME_FIELD       IN     VARCHAR2,
        P_nbi_PAYER_NAME_FIELD        IN     VARCHAR2,
        P_nbi_ACCOUNT_FIELD           IN     VARCHAR2,
        P_nbi_CURR_CODE_TP            IN     VARCHAR2,
        P_nbi_CURR_CODE_FIELD         IN     VARCHAR2,
        P_nbi_SUM_FIELD               IN     VARCHAR2,
        P_nbi_SUM_TP                  IN     VARCHAR2,
        P_nbi_SUM_VAL_FIELD           IN     VARCHAR2,
        p_nbi_payer_bnk_mfo_field     IN     VARCHAR2,
        p_nbi_payer_bnk_name_field    IN     VARCHAR2,
        p_nbi_receip_bnk_mfo_field    IN     VARCHAR2,
        p_nbi_receip_bnk_name_field   IN     VARCHAR2,
        p_nbi_payer_bnk_acc_field     IN     VARCHAR2,
        p_nbi_doc_dt_field            IN     VARCHAR2);

    -- редагувати налаштування імпорту для банку
    PROCEDURE EDIT_BANK_STATEMENT_SETTINGS (
        P_nbi_ID                      IN NUMBER,
        P_nbi_NB                      IN NUMBER,
        P_nbi_TP                      IN VARCHAR2,
        P_nbi_NAME                    IN VARCHAR2,
        P_nbi_ENCODING                IN VARCHAR2,
        P_nbi_IS_DIFF_PAYER           IN VARCHAR2,
        P_nbi_IN_CODE                 IN VARCHAR2,
        P_nbi_IN_FIELD                IN VARCHAR2,
        P_nbi_RECEIP_EDRPOU_FIELD     IN VARCHAR2,
        P_nbi_PAYER_EDRPOU_FIELD      IN VARCHAR2,
        P_nbi_PURPOSE_FIELD           IN VARCHAR2,
        P_nbi_DT_FIELD                IN VARCHAR2,
        P_nbi_DOC_NUM_FIELD           IN VARCHAR2,
        P_nbi_RECEIP_NAME_FIELD       IN VARCHAR2,
        P_nbi_PAYER_NAME_FIELD        IN VARCHAR2,
        P_nbi_ACCOUNT_FIELD           IN VARCHAR2,
        P_nbi_CURR_CODE_TP            IN VARCHAR2,
        P_nbi_CURR_CODE_FIELD         IN VARCHAR2,
        P_nbi_SUM_FIELD               IN VARCHAR2,
        P_nbi_SUM_TP                  IN VARCHAR2,
        P_nbi_SUM_VAL_FIELD           IN VARCHAR2,
        p_nbi_payer_bnk_mfo_field     IN VARCHAR2,
        p_nbi_payer_bnk_name_field    IN VARCHAR2,
        p_nbi_receip_bnk_mfo_field    IN VARCHAR2,
        p_nbi_receip_bnk_name_field   IN VARCHAR2,
        p_nbi_payer_bnk_acc_field     IN VARCHAR2,
        p_nbi_doc_dt_field            IN VARCHAR2);

    -- видалити налаштування імпорту по банку
    PROCEDURE DELETE_BANK_STATEMENT_SETTINGS (P_nbi_ID IN NUMBER);
END DNET$BANK_IMPORT_SETUP;
/


GRANT EXECUTE ON USS_NDI.DNET$BANK_IMPORT_SETUP TO DNET_PROXY
/

GRANT EXECUTE ON USS_NDI.DNET$BANK_IMPORT_SETUP TO II01RC_USS_NDI_PORTAL
/

GRANT EXECUTE ON USS_NDI.DNET$BANK_IMPORT_SETUP TO II01RC_USS_NDI_WEB
/

GRANT EXECUTE ON USS_NDI.DNET$BANK_IMPORT_SETUP TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 5:55:29 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.DNET$BANK_IMPORT_SETUP
IS
    -- список банків
    PROCEDURE GET_BANKS_LIST (RES_CUR OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
              SELECT b.nb_id,
                     b.nb_mfo,
                     b.nb_sname,
                     b.nb_name,
                     t.nbi_id
                FROM uss_ndi.v_ndi_bank b
                     LEFT JOIN uss_ndi.v_ndi_bank_cli t ON t.nbi_nb = b.nb_id
            ORDER BY b.nb_mfo;
    END;

    -- вичитати налаштування імпорту по банку
    PROCEDURE GET_BANK_STATEMENT_SETTINGS (p_nbi_id   IN     NUMBER,
                                           RES_CUR       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN RES_CUR FOR SELECT *
                           FROM uss_ndi.v_ndi_bank_cli nc
                          WHERE nc.nbi_id = p_nbi_id;
    END;

    -- вичитати налаштування імпорту по банківському рахунку
    PROCEDURE GET_BANK_STATEMENT_SETTINGS_BY_DPPA (
        p_dppa_id   IN     NUMBER,
        RES_CUR        OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN RES_CUR FOR SELECT *
                           FROM uss_ndi.v_ndi_bank_cli nc
                          WHERE nc.nbi_nb = (SELECT z.dppa_nb
                                               FROM v_ndi_pay_person_acc z
                                              WHERE z.dppa_id = p_dppa_id);
    END;

    -- додати нове налаштування імпорту для банку
    PROCEDURE ADD_NEW_BANK_STATEMENT_SETTINGS (
        P_nbi_ID                         OUT NUMBER,
        P_nbi_NB                      IN     NUMBER,
        P_nbi_TP                      IN     VARCHAR2,
        P_nbi_NAME                    IN     VARCHAR2,
        P_nbi_ENCODING                IN     VARCHAR2,
        P_nbi_IS_DIFF_PAYER           IN     VARCHAR2,
        P_nbi_IN_CODE                 IN     VARCHAR2,
        P_nbi_IN_FIELD                IN     VARCHAR2,
        P_nbi_RECEIP_EDRPOU_FIELD     IN     VARCHAR2,
        P_nbi_PAYER_EDRPOU_FIELD      IN     VARCHAR2,
        P_nbi_PURPOSE_FIELD           IN     VARCHAR2,
        P_nbi_DT_FIELD                IN     VARCHAR2,
        P_nbi_DOC_NUM_FIELD           IN     VARCHAR2,
        P_nbi_RECEIP_NAME_FIELD       IN     VARCHAR2,
        P_nbi_PAYER_NAME_FIELD        IN     VARCHAR2,
        P_nbi_ACCOUNT_FIELD           IN     VARCHAR2,
        P_nbi_CURR_CODE_TP            IN     VARCHAR2,
        P_nbi_CURR_CODE_FIELD         IN     VARCHAR2,
        P_nbi_SUM_FIELD               IN     VARCHAR2,
        P_nbi_SUM_TP                  IN     VARCHAR2,
        P_nbi_SUM_VAL_FIELD           IN     VARCHAR2,
        p_nbi_payer_bnk_mfo_field     IN     VARCHAR2,
        p_nbi_payer_bnk_name_field    IN     VARCHAR2,
        p_nbi_receip_bnk_mfo_field    IN     VARCHAR2,
        p_nbi_receip_bnk_name_field   IN     VARCHAR2,
        p_nbi_payer_bnk_acc_field     IN     VARCHAR2,
        p_nbi_doc_dt_field            IN     VARCHAR2)
    IS
    BEGIN
        INSERT INTO uss_ndi.v_ndi_bank_cli (nbi_id,
                                            nbi_nb,
                                            nbi_tp,
                                            nbi_name,
                                            nbi_encoding,
                                            nbi_is_diff_payer,
                                            nbi_in_code,
                                            nbi_in_field,
                                            nbi_receip_edrpou_field,
                                            nbi_payer_edrpou_field,
                                            nbi_purpose_field,
                                            nbi_dt_field,
                                            nbi_doc_num_field,
                                            nbi_receip_name_field,
                                            nbi_payer_name_field,
                                            nbi_account_field,
                                            nbi_curr_code_tp,
                                            nbi_curr_code_field,
                                            nbi_sum_field,
                                            nbi_sum_tp,
                                            nbi_sum_val_field,
                                            nbi_payer_bnk_mfo_field,
                                            nbi_payer_bnk_name_field,
                                            nbi_payer_bnk_acc_field,
                                            nbi_doc_dt_field,
                                            nbi_receip_bnk_mfo_field,
                                            nbi_receip_bnk_name_field)
             VALUES (p_nbi_id,
                     p_nbi_nb,
                     p_nbi_tp,
                     p_nbi_name,
                     p_nbi_encoding,
                     p_nbi_is_diff_payer,
                     p_nbi_in_code,
                     p_nbi_in_field,
                     p_nbi_receip_edrpou_field,
                     p_nbi_payer_edrpou_field,
                     p_nbi_purpose_field,
                     p_nbi_dt_field,
                     p_nbi_doc_num_field,
                     p_nbi_receip_name_field,
                     p_nbi_payer_name_field,
                     p_nbi_account_field,
                     p_nbi_curr_code_tp,
                     p_nbi_curr_code_field,
                     p_nbi_sum_field,
                     p_nbi_sum_tp,
                     p_nbi_sum_val_field,
                     p_nbi_payer_bnk_mfo_field,
                     p_nbi_payer_bnk_name_field,
                     p_nbi_payer_bnk_acc_field,
                     p_nbi_doc_dt_field,
                     p_nbi_receip_bnk_mfo_field,
                     p_nbi_receip_bnk_name_field)
          RETURNING nbi_id
               INTO P_nbi_ID;
    END;

    -- редагувати налаштування імпорту для банку
    PROCEDURE EDIT_BANK_STATEMENT_SETTINGS (
        P_nbi_ID                      IN NUMBER,
        P_nbi_NB                      IN NUMBER,
        P_nbi_TP                      IN VARCHAR2,
        P_nbi_NAME                    IN VARCHAR2,
        P_nbi_ENCODING                IN VARCHAR2,
        P_nbi_IS_DIFF_PAYER           IN VARCHAR2,
        P_nbi_IN_CODE                 IN VARCHAR2,
        P_nbi_IN_FIELD                IN VARCHAR2,
        P_nbi_RECEIP_EDRPOU_FIELD     IN VARCHAR2,
        P_nbi_PAYER_EDRPOU_FIELD      IN VARCHAR2,
        P_nbi_PURPOSE_FIELD           IN VARCHAR2,
        P_nbi_DT_FIELD                IN VARCHAR2,
        P_nbi_DOC_NUM_FIELD           IN VARCHAR2,
        P_nbi_RECEIP_NAME_FIELD       IN VARCHAR2,
        P_nbi_PAYER_NAME_FIELD        IN VARCHAR2,
        P_nbi_ACCOUNT_FIELD           IN VARCHAR2,
        P_nbi_CURR_CODE_TP            IN VARCHAR2,
        P_nbi_CURR_CODE_FIELD         IN VARCHAR2,
        P_nbi_SUM_FIELD               IN VARCHAR2,
        P_nbi_SUM_TP                  IN VARCHAR2,
        P_nbi_SUM_VAL_FIELD           IN VARCHAR2,
        p_nbi_payer_bnk_mfo_field     IN VARCHAR2,
        p_nbi_payer_bnk_name_field    IN VARCHAR2,
        p_nbi_receip_bnk_mfo_field    IN VARCHAR2,
        p_nbi_receip_bnk_name_field   IN VARCHAR2,
        p_nbi_payer_bnk_acc_field     IN VARCHAR2,
        p_nbi_doc_dt_field            IN VARCHAR2)
    IS
    BEGIN
        UPDATE uss_ndi.v_ndi_bank_cli
           SET nbi_tp = P_nbi_TP,
               nbi_name = P_nbi_NAME,
               nbi_encoding = P_nbi_ENCODING,
               nbi_is_diff_payer = P_nbi_IS_DIFF_PAYER,
               nbi_in_code = P_nbi_IN_CODE,
               nbi_in_field = P_nbi_IN_FIELD,
               nbi_receip_edrpou_field = P_nbi_RECEIP_EDRPOU_FIELD,
               nbi_payer_edrpou_field = P_nbi_PAYER_EDRPOU_FIELD,
               nbi_purpose_field = P_nbi_PURPOSE_FIELD,
               nbi_dt_field = P_nbi_DT_FIELD,
               nbi_doc_num_field = P_nbi_DOC_NUM_FIELD,
               nbi_receip_name_field = P_nbi_RECEIP_NAME_FIELD,
               nbi_payer_name_field = P_nbi_PAYER_NAME_FIELD,
               nbi_account_field = P_nbi_ACCOUNT_FIELD,
               nbi_curr_code_tp = P_nbi_CURR_CODE_TP,
               nbi_curr_code_field = P_nbi_CURR_CODE_FIELD,
               nbi_sum_field = P_nbi_SUM_FIELD,
               nbi_sum_tp = P_nbi_SUM_TP,
               nbi_sum_val_field = P_nbi_SUM_VAL_FIELD,
               nbi_payer_bnk_mfo_field = p_nbi_payer_bnk_mfo_field,
               nbi_payer_bnk_name_field = p_nbi_payer_bnk_name_field,
               nbi_payer_bnk_acc_field = p_nbi_payer_bnk_acc_field,
               nbi_doc_dt_field = p_nbi_doc_dt_field,
               nbi_receip_bnk_mfo_field = p_nbi_receip_bnk_mfo_field,
               nbi_receip_bnk_name_field = p_nbi_receip_bnk_name_field
         WHERE nbi_id = P_nbi_ID AND nbi_nb = P_nbi_NB;
    END;

    -- видалити налаштування імпорту по банку
    PROCEDURE DELETE_BANK_STATEMENT_SETTINGS (P_nbi_ID IN NUMBER)
    IS
    BEGIN
        DELETE FROM uss_ndi.v_ndi_bank_cli
              WHERE nbi_id = P_nbi_ID;
    END;
BEGIN
    NULL;
END DNET$BANK_IMPORT_SETUP;
/