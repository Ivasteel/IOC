/* Formatted on 8/12/2025 6:06:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_FINZVIT.FINZVIT_DIC
AS
    PROCEDURE DELETE_PAYPERSON_ACC (
        p_DPPA_ID   IN DIC_PAY_PERSON_ACC.DPPA_ID%TYPE);

    PROCEDURE INSERT_PAY_PERSON (
        P_DPP_NAME           DIC_PAY_PERSON.DPP_NAME%TYPE,
        P_DPP_ORG            DIC_PAY_PERSON.DPP_ORG%TYPE,
        P_DPP_TAX_CODE       DIC_PAY_PERSON.DPP_TAX_CODE%TYPE,
        P_DPP_ID         OUT DIC_PAY_PERSON.DPP_ID%TYPE);

    PROCEDURE UPDATE_PERSON (
        P_DPP_NAME       DIC_PAY_PERSON.DPP_NAME%TYPE,
        P_DPP_ORG        DIC_PAY_PERSON.DPP_ORG%TYPE,
        P_DPP_TAX_CODE   DIC_PAY_PERSON.DPP_TAX_CODE%TYPE,
        P_DPP_ID         DIC_PAY_PERSON.DPP_ID%TYPE);

    PROCEDURE GET_PAY_PERSON (
        P_DPP_ID         IN     DIC_PAY_PERSON.DPP_ID%TYPE,
        P_DPP_NAME          OUT DIC_PAY_PERSON.DPP_NAME%TYPE,
        P_DPP_ORG           OUT DIC_PAY_PERSON.DPP_ORG%TYPE,
        P_DPP_TAX_CODE      OUT DIC_PAY_PERSON.DPP_TAX_CODE%TYPE);

    PROCEDURE GET_PERSON_ACC (
        P_DPPA_DPP         IN     DIC_PAY_PERSON_ACC.DPPA_DPP%TYPE,
        P_PAY_PERSON_ACC      OUT SYS_REFCURSOR);

    PROCEDURE SAVE_PAYPERSON_ACC (
        p_DPPA_ID             IN DIC_PAY_PERSON_ACC.DPPA_ID%TYPE,
        p_DPPA_DPP            IN DIC_PAY_PERSON_ACC.DPPA_DPP%TYPE,
        p_DPPA_BANK_CODE      IN DIC_PAY_PERSON_ACC.DPPA_BANK_CODE%TYPE,
        p_DPPA_BANK_ACCOUNT   IN DIC_PAY_PERSON_ACC.DPPA_BANK_ACCOUNT%TYPE,
        p_DPPA_IS_MAIN        IN DIC_PAY_PERSON_ACC.DPPA_IS_MAIN%TYPE,
        p_DPPA_BANK_NAME      IN DIC_PAY_PERSON_ACC.DPPA_BANK_NAME%TYPE);

    PROCEDURE GetDistribPurpose (
        p_DPG_ID   IN     DIC_DISTRIB_PURPOSE_GR.DPG_ID%TYPE,
        p_main        OUT SYS_REFCURSOR,
        p_lines       OUT SYS_REFCURSOR);

    PROCEDURE SetDistribPurpose (
        p_DPG_ID         IN     DIC_DISTRIB_PURPOSE_GR.DPG_ID%TYPE,
        p_DPG_NAME       IN     DIC_DISTRIB_PURPOSE_GR.DPG_NAME%TYPE,
        p_DPG_IS_GOV     IN     DIC_DISTRIB_PURPOSE_GR.DPG_IS_GOV%TYPE,
        p_DPG_IS_OWN     IN     DIC_DISTRIB_PURPOSE_GR.DPG_IS_OWN%TYPE,
        p_DPG_TEMPLATE   IN     DIC_DISTRIB_PURPOSE_GR.DPG_TEMPLATE%TYPE,
        p_DPG_TP         IN     DIC_DISTRIB_PURPOSE_GR.DPG_TP%TYPE,
        p_DPG_ID_new        OUT DIC_DISTRIB_PURPOSE_GR.DPG_ID%TYPE);

    PROCEDURE InsertDistribPurposeLine (
        p_DAP_DFA   IN dic_article_in_purpose.DAP_DFA%TYPE,
        p_DAP_DPG   IN dic_article_in_purpose.DAP_DPG%TYPE);

    PROCEDURE DeleteDistribPurposeLine (
        p_DAP_ID   IN dic_article_in_purpose.DAP_ID%TYPE);

    PROCEDURE DeleteDistribPurpose (
        p_DPG_ID   IN DIC_DISTRIB_PURPOSE_GR.DPG_ID%TYPE);

    PROCEDURE GetEmptyDistribPurposeLines (p_lines OUT SYS_REFCURSOR);

    PROCEDURE SetDkgPoTemplate (
        p_DPT_ID         IN     dic_dkg_po_template.Dpt_Id%TYPE,
        p_DPT_TEMPLATE   IN     dic_dkg_po_template.DPT_TEMPLATE%TYPE,
        p_DPT_DRT        IN     dic_dkg_po_template.DPT_DRT%TYPE,
        p_NEW_DPT_ID        OUT dic_dkg_po_template.Dpt_Id%TYPE);

    PROCEDURE DeleteDkgPoTemplate (
        p_DPT_ID   IN dic_dkg_po_template.Dpt_Id%TYPE);

    PROCEDURE GetDkgPoTemplate (
        p_DPT_ID   IN     dic_dkg_po_template.Dpt_Id%TYPE,
        p_res         OUT SYS_REFCURSOR);

    PROCEDURE SetPpvpPoTemplate (
        p_PPT_ID         IN     dic_ppvp_po_template.Ppt_Id%TYPE,
        p_PPT_TEMPLATE   IN     dic_ppvp_po_template.PPT_TEMPLATE%TYPE,
        p_PPT_PRT        IN     dic_ppvp_po_template.PPT_PRT%TYPE,
        p_NEW_PPT_ID        OUT dic_ppvp_po_template.Ppt_Id%TYPE);

    PROCEDURE DeletePPvpPoTemplate (
        p_PPT_ID   IN dic_ppvp_po_template.Ppt_Id%TYPE);

    PROCEDURE GetPpvpPoTemplate (
        p_PPT_ID   IN     dic_ppvp_po_template.Ppt_Id%TYPE,
        p_res         OUT SYS_REFCURSOR);
END FINZVIT_DIC;
/


GRANT EXECUTE ON IKIS_FINZVIT.FINZVIT_DIC TO DNET_PROXY
/


/* Formatted on 8/12/2025 6:06:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_FINZVIT.FINZVIT_DIC
AS
    PROCEDURE INSERT_PAY_PERSON (
        P_DPP_NAME           DIC_PAY_PERSON.DPP_NAME%TYPE,
        P_DPP_ORG            DIC_PAY_PERSON.DPP_ORG%TYPE,
        P_DPP_TAX_CODE       DIC_PAY_PERSON.DPP_TAX_CODE%TYPE,
        P_DPP_ID         OUT DIC_PAY_PERSON.DPP_ID%TYPE)
    IS
    BEGIN
        INSERT INTO DIC_PAY_PERSON (DPP_NAME, DPP_ORG, DPP_TAX_CODE)
             VALUES (P_DPP_NAME, P_DPP_ORG, P_DPP_TAX_CODE)
          RETURNING DPP_ID
               INTO P_DPP_ID;
    END;

    PROCEDURE UPDATE_PERSON (
        P_DPP_NAME       DIC_PAY_PERSON.DPP_NAME%TYPE,
        P_DPP_ORG        DIC_PAY_PERSON.DPP_ORG%TYPE,
        P_DPP_TAX_CODE   DIC_PAY_PERSON.DPP_TAX_CODE%TYPE,
        P_DPP_ID         DIC_PAY_PERSON.DPP_ID%TYPE)
    IS
    BEGIN
        UPDATE DIC_PAY_PERSON
           SET DPP_NAME = P_DPP_NAME,
               DPP_ORG = P_DPP_ORG,
               DPP_TAX_CODE = P_DPP_TAX_CODE
         WHERE DPP_ID = P_DPP_ID;
    END;

    PROCEDURE GET_PAY_PERSON (
        P_DPP_ID         IN     DIC_PAY_PERSON.DPP_ID%TYPE,
        P_DPP_NAME          OUT DIC_PAY_PERSON.DPP_NAME%TYPE,
        P_DPP_ORG           OUT DIC_PAY_PERSON.DPP_ORG%TYPE,
        P_DPP_TAX_CODE      OUT DIC_PAY_PERSON.DPP_TAX_CODE%TYPE)
    IS
    BEGIN
        SELECT DPP_NAME, DPP_ORG, DPP_TAX_CODE
          INTO P_DPP_NAME, P_DPP_ORG, P_DPP_TAX_CODE
          FROM DIC_PAY_PERSON
         WHERE DPP_ID = P_DPP_ID;
    END;

    PROCEDURE GET_PERSON_ACC (
        P_DPPA_DPP         IN     DIC_PAY_PERSON_ACC.DPPA_DPP%TYPE,
        P_PAY_PERSON_ACC      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN P_PAY_PERSON_ACC FOR SELECT *
                                    FROM DIC_PAY_PERSON_ACC dppa
                                   WHERE dppa.DPPA_DPP = P_DPPA_DPP;
    END;

    PROCEDURE SAVE_PAYPERSON_ACC (
        p_DPPA_ID             IN DIC_PAY_PERSON_ACC.DPPA_ID%TYPE,
        p_DPPA_DPP            IN DIC_PAY_PERSON_ACC.DPPA_DPP%TYPE,
        p_DPPA_BANK_CODE      IN DIC_PAY_PERSON_ACC.DPPA_BANK_CODE%TYPE,
        p_DPPA_BANK_ACCOUNT   IN DIC_PAY_PERSON_ACC.DPPA_BANK_ACCOUNT%TYPE,
        p_DPPA_IS_MAIN        IN DIC_PAY_PERSON_ACC.DPPA_IS_MAIN%TYPE,
        p_DPPA_BANK_NAME      IN DIC_PAY_PERSON_ACC.DPPA_BANK_NAME%TYPE)
    IS
    BEGIN
        IF NVL (p_DPPA_ID, 0) = 0
        THEN
            INSERT INTO DIC_PAY_PERSON_ACC (DPPA_DPP,
                                            DPPA_BANK_CODE,
                                            DPPA_BANK_ACCOUNT,
                                            DPPA_IS_MAIN,
                                            DPPA_BANK_NAME)
                 VALUES (p_DPPA_DPP,
                         p_DPPA_BANK_CODE,
                         p_DPPA_BANK_ACCOUNT,
                         p_DPPA_IS_MAIN,
                         p_DPPA_BANK_NAME);
        ELSE
            UPDATE DIC_PAY_PERSON_ACC
               SET DPPA_DPP = p_DPPA_DPP,
                   DPPA_BANK_CODE = p_DPPA_BANK_CODE,
                   DPPA_BANK_ACCOUNT = p_DPPA_BANK_ACCOUNT,
                   DPPA_IS_MAIN = p_DPPA_IS_MAIN,
                   DPPA_BANK_NAME = p_DPPA_BANK_NAME
             WHERE DPPA_ID = p_DPPA_ID;
        END IF;
    END;

    PROCEDURE DELETE_PAYPERSON_ACC (
        p_DPPA_ID   IN DIC_PAY_PERSON_ACC.DPPA_ID%TYPE)
    IS
    BEGIN
        DELETE FROM DIC_PAY_PERSON_ACC
              WHERE DPPA_ID = p_DPPA_ID;
    END;

    PROCEDURE GetDistribPurpose (
        p_DPG_ID   IN     DIC_DISTRIB_PURPOSE_GR.DPG_ID%TYPE,
        p_main        OUT SYS_REFCURSOR,
        p_lines       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_main FOR SELECT *
                          FROM DIC_DISTRIB_PURPOSE_GR
                         WHERE DPG_ID = p_DPG_ID;

        OPEN p_lines FOR
              SELECT dap_id,
                     dfa_id                          dap_dfa,
                     dap_dpg,
                     dfa_name,
                     DECODE (dap_id, NULL, 0, 1)     selected
                FROM dic_fin_article f
                     LEFT JOIN DIC_ARTICLE_IN_PURPOSE a
                         ON a.dap_dpg = p_DPG_ID AND a.dap_dfa = f.dfa_id
            ORDER BY dfa_name;
    END;

    PROCEDURE GetEmptyDistribPurposeLines (p_lines OUT SYS_REFCURSOR)
    IS
        p_main   SYS_REFCURSOR;
    BEGIN
        GetDistribPurpose (-1, p_main, p_lines);

        CLOSE p_main;
    END;

    PROCEDURE SetDistribPurpose (
        p_DPG_ID         IN     DIC_DISTRIB_PURPOSE_GR.DPG_ID%TYPE,
        p_DPG_NAME       IN     DIC_DISTRIB_PURPOSE_GR.DPG_NAME%TYPE,
        p_DPG_IS_GOV     IN     DIC_DISTRIB_PURPOSE_GR.DPG_IS_GOV%TYPE,
        p_DPG_IS_OWN     IN     DIC_DISTRIB_PURPOSE_GR.DPG_IS_OWN%TYPE,
        p_DPG_TEMPLATE   IN     DIC_DISTRIB_PURPOSE_GR.DPG_TEMPLATE%TYPE,
        p_DPG_TP         IN     DIC_DISTRIB_PURPOSE_GR.DPG_TP%TYPE,
        p_DPG_ID_new        OUT DIC_DISTRIB_PURPOSE_GR.DPG_ID%TYPE)
    IS
    BEGIN
        IF (p_DPG_ID IS NULL)
        THEN
            INSERT INTO dic_distrib_purpose_gr (dpg_id,
                                                dpg_name,
                                                dpg_is_gov,
                                                dpg_is_own,
                                                dpg_template,
                                                dpg_tp)
                 VALUES (p_dpg_id,
                         p_dpg_name,
                         p_dpg_is_gov,
                         p_dpg_is_own,
                         p_dpg_template,
                         p_dpg_tp)
              RETURNING dpg_id
                   INTO p_DPG_ID_new;
        ELSE
            p_DPG_ID_new := p_DPG_ID;

            UPDATE dic_distrib_purpose_gr
               SET dpg_name = p_dpg_name,
                   dpg_is_gov = p_dpg_is_gov,
                   dpg_is_own = p_dpg_is_own,
                   dpg_template = p_dpg_template,
                   dpg_tp = p_dpg_tp
             WHERE dpg_id = p_dpg_id;
        END IF;
    END;

    PROCEDURE InsertDistribPurposeLine (
        p_DAP_DFA   IN dic_article_in_purpose.DAP_DFA%TYPE,
        p_DAP_DPG   IN dic_article_in_purpose.DAP_DPG%TYPE)
    IS
    BEGIN
        INSERT INTO dic_article_in_purpose (dap_dfa, dap_dpg)
             VALUES (p_dap_dfa, p_dap_dpg);
    END;

    PROCEDURE DeleteDistribPurposeLine (
        p_DAP_ID   IN dic_article_in_purpose.DAP_ID%TYPE)
    IS
    BEGIN
        DELETE dic_article_in_purpose
         WHERE dap_id = p_dap_id;
    END;

    PROCEDURE DeleteDistribPurpose (
        p_DPG_ID   IN DIC_DISTRIB_PURPOSE_GR.DPG_ID%TYPE)
    IS
    BEGIN
        DELETE dic_article_in_purpose
         WHERE dap_dpg = p_dpg_id;

        DELETE dic_distrib_purpose_gr
         WHERE dpg_id = p_dpg_id;
    END;

    PROCEDURE SetDkgPoTemplate (
        p_DPT_ID         IN     dic_dkg_po_template.Dpt_Id%TYPE,
        p_DPT_TEMPLATE   IN     dic_dkg_po_template.DPT_TEMPLATE%TYPE,
        p_DPT_DRT        IN     dic_dkg_po_template.DPT_DRT%TYPE,
        p_NEW_DPT_ID        OUT dic_dkg_po_template.Dpt_Id%TYPE)
    IS
    BEGIN
        IF (p_DPT_ID IS NULL)
        THEN
            INSERT INTO dic_dkg_po_template (dpt_template, dpt_drt)
                 VALUES (p_dpt_template, p_dpt_drt)
              RETURNING dpt_id
                   INTO p_NEW_DPT_ID;
        ELSE
            p_NEW_DPT_ID := p_DPT_ID;

            UPDATE dic_dkg_po_template
               SET dpt_template = p_dpt_template, dpt_drt = p_dpt_drt
             WHERE dpt_id = p_dpt_id;
        END IF;
    END;

    PROCEDURE DeleteDkgPoTemplate (
        p_DPT_ID   IN dic_dkg_po_template.Dpt_Id%TYPE)
    IS
    BEGIN
        DELETE dic_dkg_po_template
         WHERE dpt_id = p_dpt_id;
    END;

    PROCEDURE GetDkgPoTemplate (
        p_DPT_ID   IN     dic_dkg_po_template.Dpt_Id%TYPE,
        p_res         OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR SELECT *
                         FROM dic_dkg_po_template
                        WHERE DPT_ID = p_DPT_ID;
    END;

    PROCEDURE SetPpvpPoTemplate (
        p_PPT_ID         IN     dic_ppvp_po_template.Ppt_Id%TYPE,
        p_PPT_TEMPLATE   IN     dic_ppvp_po_template.PPT_TEMPLATE%TYPE,
        p_PPT_PRT        IN     dic_ppvp_po_template.PPT_PRT%TYPE,
        p_NEW_PPT_ID        OUT dic_ppvp_po_template.Ppt_Id%TYPE)
    IS
    BEGIN
        IF (p_PPT_ID IS NULL)
        THEN
            INSERT INTO dic_ppvp_po_template (ppt_template, ppt_prt)
                 VALUES (p_ppt_template, p_ppt_prt)
              RETURNING ppt_id
                   INTO p_NEW_PPT_ID;
        ELSE
            p_NEW_PPT_ID := p_PPT_ID;

            UPDATE dic_ppvp_po_template
               SET ppt_template = p_ppt_template, ppt_prt = p_ppt_prt
             WHERE ppt_id = p_ppt_id;
        END IF;
    END;

    PROCEDURE DeletePpvpPoTemplate (
        p_PPT_ID   IN dic_ppvp_po_template.Ppt_Id%TYPE)
    IS
    BEGIN
        DELETE dic_ppvp_po_template
         WHERE ppt_id = p_ppt_id;
    END;

    PROCEDURE GetPpvpPoTemplate (
        p_PPT_ID   IN     dic_ppvp_po_template.Ppt_Id%TYPE,
        p_res         OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR SELECT *
                         FROM dic_ppvp_po_template
                        WHERE PPT_ID = p_PPT_ID;
    END;
END FINZVIT_DIC;
/