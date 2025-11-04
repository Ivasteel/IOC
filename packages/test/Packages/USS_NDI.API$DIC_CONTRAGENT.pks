/* Formatted on 8/12/2025 5:55:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.API$DIC_CONTRAGENT
IS
    -- рахунки
    PROCEDURE get_pay_person_acc_list (p_dpp_id   IN     NUMBER,
                                       res_cur       OUT SYS_REFCURSOR);



    -- Author  : ivashchuk
    -- Created : 26.10.2021

    FUNCTION insert_ndi_pay_person (
        p_dpp_tax_code   ndi_pay_person.dpp_tax_code%TYPE,
        p_dpp_name       ndi_pay_person.dpp_name%TYPE,
        p_dpp_org        ndi_pay_person.dpp_org%TYPE,
        p_dpp_is_ur      ndi_pay_person.dpp_is_ur%TYPE,
        p_dpp_sname      ndi_pay_person.dpp_sname%TYPE,
        p_dpp_address    ndi_pay_person.dpp_address%TYPE,
        p_dpp_tp         ndi_pay_person.dpp_tp%TYPE--,p_history_status  ndi_pay_person.history_status%type
                                                   )
        RETURN ndi_pay_person.dpp_id%TYPE;

    PROCEDURE update_ndi_pay_person (
        p_dpp_id         ndi_pay_person.dpp_id%TYPE,
        p_dpp_tax_code   ndi_pay_person.dpp_tax_code%TYPE,
        p_dpp_name       ndi_pay_person.dpp_name%TYPE,
        p_dpp_org        ndi_pay_person.dpp_org%TYPE,
        p_dpp_is_ur      ndi_pay_person.dpp_is_ur%TYPE,
        p_dpp_sname      ndi_pay_person.dpp_sname%TYPE,
        p_dpp_address    ndi_pay_person.dpp_address%TYPE,
        p_dpp_tp         ndi_pay_person.dpp_tp%TYPE--,p_history_status  ndi_pay_person.history_status%type
                                                   );

    PROCEDURE set_ndi_pay_person_hist_st (
        p_dpp_id           ndi_pay_person.dpp_Id%TYPE,
        p_History_Status   ndi_pay_person.history_status%TYPE);

    FUNCTION insert_ndi_pay_person_acc (
        p_dppa_dpp                     ndi_pay_person_acc.dppa_dpp%TYPE,
        p_dppa_nb                      ndi_pay_person_acc.dppa_nb%TYPE,
        p_dppa_ab_id                   ndi_pay_person_acc.dppa_ab_id%TYPE,
        p_dppa_is_main                 ndi_pay_person_acc.dppa_is_main%TYPE,
        p_dppa_account                 ndi_pay_person_acc.dppa_account%TYPE,
        --p_history_status           ndi_pay_person_acc.history_status%type,
        p_dppa_last_payment_order      ndi_pay_person_acc.dppa_last_payment_order%TYPE,
        p_dppa_nbg                     ndi_pay_person_acc.dppa_nbg%TYPE,
        p_dppa_is_social               ndi_pay_person_acc.dppa_is_social%TYPE,
        p_dppa_description             ndi_pay_person_acc.dppa_description%TYPE,
        p_dppa_nb_filia_num         IN ndi_pay_person_acc.dppa_nb_filia_num%TYPE)
        RETURN ndi_pay_person_acc.dppa_ab_id%TYPE;

    PROCEDURE update_ndi_pay_person_acc (
        p_dppa_id                      ndi_pay_person_acc.dppa_id%TYPE,
        p_dppa_dpp                     ndi_pay_person_acc.dppa_dpp%TYPE,
        p_dppa_nb                      ndi_pay_person_acc.dppa_nb%TYPE,
        p_dppa_is_main                 ndi_pay_person_acc.dppa_is_main%TYPE,
        p_dppa_account                 ndi_pay_person_acc.dppa_account%TYPE,
        --p_history_status           ndi_pay_person_acc.history_status%type,
        p_dppa_last_payment_order      ndi_pay_person_acc.dppa_last_payment_order%TYPE,
        p_dppa_nbg                     ndi_pay_person_acc.dppa_nbg%TYPE,
        p_dppa_is_social               ndi_pay_person_acc.dppa_is_social%TYPE,
        p_dppa_ab_id                   ndi_pay_person_acc.dppa_ab_id%TYPE,
        p_dppa_description             ndi_pay_person_acc.dppa_description%TYPE,
        p_dppa_nb_filia_num         IN ndi_pay_person_acc.dppa_nb_filia_num%TYPE);


    PROCEDURE SET_NDI_PAY_PERSON_ACC_HIST_ST (
        p_dppa_id          ndi_pay_person_acc.dppa_Id%TYPE,
        p_History_Status   ndi_pay_person_acc.history_status%TYPE);
END API$DIC_CONTRAGENT;
/


GRANT EXECUTE ON USS_NDI.API$DIC_CONTRAGENT TO II01RC_USS_NDI_INTERNAL
/

GRANT EXECUTE ON USS_NDI.API$DIC_CONTRAGENT TO IKIS_RBM
/

GRANT EXECUTE ON USS_NDI.API$DIC_CONTRAGENT TO USS_ESR
/

GRANT EXECUTE ON USS_NDI.API$DIC_CONTRAGENT TO USS_PERSON
/

GRANT EXECUTE ON USS_NDI.API$DIC_CONTRAGENT TO USS_RNSP
/

GRANT EXECUTE ON USS_NDI.API$DIC_CONTRAGENT TO USS_RPT
/

GRANT EXECUTE ON USS_NDI.API$DIC_CONTRAGENT TO USS_VISIT
/


/* Formatted on 8/12/2025 5:55:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.API$DIC_CONTRAGENT
IS
    -- рахунки Author: kolio
    PROCEDURE get_pay_person_acc_list (p_dpp_id   IN     NUMBER,
                                       res_cur       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT t.dppa_id AS id, t.dppa_account AS NAME
              FROM ndi_pay_person_acc  t
                   LEFT JOIN ndi_budget_program bp ON bp.nbg_id = t.dppa_nbg
                   LEFT JOIN ndi_bank b ON b.nb_id = t.dppa_nb
             WHERE t.dppa_dpp = p_dpp_id AND t.history_status = 'A';
    END;

    -- Author  : ivashchuk
    -- Created : 26.10.2021

    FUNCTION insert_ndi_pay_person (
        p_dpp_tax_code   ndi_pay_person.dpp_tax_code%TYPE,
        p_dpp_name       ndi_pay_person.dpp_name%TYPE,
        p_dpp_org        ndi_pay_person.dpp_org%TYPE,
        p_dpp_is_ur      ndi_pay_person.dpp_is_ur%TYPE,
        p_dpp_sname      ndi_pay_person.dpp_sname%TYPE,
        p_dpp_address    ndi_pay_person.dpp_address%TYPE,
        p_dpp_tp         ndi_pay_person.dpp_tp%TYPE--,p_history_status  ndi_pay_person.history_status%type
                                                   )
        RETURN ndi_pay_person.dpp_id%TYPE
    IS
        l_out_id   NUMBER;
    BEGIN
        tools.check_user_and_raise (3);

        INSERT INTO ndi_pay_person (dpp_id,
                                    dpp_tax_code,
                                    dpp_name,
                                    dpp_org,
                                    dpp_is_ur,
                                    dpp_sname,
                                    dpp_address,
                                    dpp_tp,
                                    history_status,
                                    dpp_hs_upd)
             VALUES (0,
                     p_dpp_tax_code,
                     p_dpp_name,
                     p_dpp_org,
                     p_dpp_is_ur,
                     p_dpp_sname,
                     p_dpp_address,
                     p_dpp_tp,
                     'A',
                     tools.gethistsession)
          RETURNING dpp_id
               INTO l_out_id;

        RETURN l_out_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'RDM$NDI_PAY_PERSON.insert: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE update_ndi_pay_person (
        p_dpp_id         ndi_pay_person.dpp_id%TYPE,
        p_dpp_tax_code   ndi_pay_person.dpp_tax_code%TYPE,
        p_dpp_name       ndi_pay_person.dpp_name%TYPE,
        p_dpp_org        ndi_pay_person.dpp_org%TYPE,
        p_dpp_is_ur      ndi_pay_person.dpp_is_ur%TYPE,
        p_dpp_sname      ndi_pay_person.dpp_sname%TYPE,
        p_dpp_address    ndi_pay_person.dpp_address%TYPE,
        p_dpp_tp         ndi_pay_person.dpp_tp%TYPE--,p_history_status  ndi_pay_person.history_status%type
                                                   )
    IS
    BEGIN
        tools.check_user_and_raise (3);

        UPDATE ndi_pay_person
           SET dpp_tax_code = p_dpp_tax_code,
               dpp_name = p_dpp_name,
               dpp_org = p_dpp_org,
               dpp_is_ur = p_dpp_is_ur,
               dpp_sname = p_dpp_sname,
               dpp_address = p_dpp_address,
               dpp_tp = p_dpp_tp,
               --,history_status  = p_history_status,
               dpp_hs_upd = tools.gethistsession
         WHERE dpp_id = p_dpp_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'RDM$NDI_PAY_PERSON.update: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE set_ndi_pay_person_hist_st (
        p_dpp_id           ndi_pay_person.dpp_id%TYPE,
        p_history_status   ndi_pay_person.history_status%TYPE)
    IS
    BEGIN
        tools.check_user_and_raise (3);

        UPDATE ndi_pay_person
           SET history_status = p_history_status,
               dpp_hs_upd =
                   CASE
                       WHEN p_history_status = 'A' THEN tools.gethistsession
                       ELSE dpp_hs_upd
                   END,
               dpp_hs_del =
                   CASE
                       WHEN p_history_status = 'H' THEN tools.gethistsession
                       ELSE dpp_hs_del
                   END
         WHERE dpp_id = p_dpp_id;
    END;

    FUNCTION insert_ndi_pay_person_acc (
        p_dppa_dpp                     ndi_pay_person_acc.dppa_dpp%TYPE,
        p_dppa_nb                      ndi_pay_person_acc.dppa_nb%TYPE,
        p_dppa_ab_id                   ndi_pay_person_acc.dppa_ab_id%TYPE,
        p_dppa_is_main                 ndi_pay_person_acc.dppa_is_main%TYPE,
        p_dppa_account                 ndi_pay_person_acc.dppa_account%TYPE,
        --p_history_status           ndi_pay_person_acc.history_status%type,
        p_dppa_last_payment_order      ndi_pay_person_acc.dppa_last_payment_order%TYPE,
        p_dppa_nbg                     ndi_pay_person_acc.dppa_nbg%TYPE,
        p_dppa_is_social               ndi_pay_person_acc.dppa_is_social%TYPE,
        p_dppa_description             ndi_pay_person_acc.dppa_description%TYPE,
        p_dppa_nb_filia_num         IN ndi_pay_person_acc.dppa_nb_filia_num%TYPE)
        RETURN ndi_pay_person_acc.dppa_ab_id%TYPE
    IS
        l_out_id   NUMBER;
    BEGIN
        INSERT INTO ndi_pay_person_acc (dppa_id,
                                        dppa_dpp,
                                        dppa_nb,
                                        dppa_ab_id,
                                        dppa_is_main,
                                        dppa_account,
                                        history_status,
                                        dppa_last_payment_order,
                                        dppa_nbg,
                                        dppa_is_social,
                                        dppa_description,
                                        dppa_hs_upd,
                                        dppa_nb_filia_num)
             VALUES (0,
                     p_dppa_dpp,
                     p_dppa_nb,
                     p_dppa_ab_id,
                     p_dppa_is_main,
                     p_dppa_account,
                     'A',
                     p_dppa_last_payment_order,
                     p_dppa_nbg,
                     p_dppa_is_social,
                     p_dppa_description,
                     tools.gethistsession,
                     p_dppa_nb_filia_num)
          RETURNING dppa_id
               INTO l_out_id;

        RETURN l_out_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'RDM$NDI_PAY_PERSON_ACC.insert: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE update_ndi_pay_person_acc (
        p_dppa_id                      ndi_pay_person_acc.dppa_id%TYPE,
        p_dppa_dpp                     ndi_pay_person_acc.dppa_dpp%TYPE,
        p_dppa_nb                      ndi_pay_person_acc.dppa_nb%TYPE,
        p_dppa_is_main                 ndi_pay_person_acc.dppa_is_main%TYPE,
        p_dppa_account                 ndi_pay_person_acc.dppa_account%TYPE,
        --p_history_status           ndi_pay_person_acc.history_status%type,
        p_dppa_last_payment_order      ndi_pay_person_acc.dppa_last_payment_order%TYPE,
        p_dppa_nbg                     ndi_pay_person_acc.dppa_nbg%TYPE,
        p_dppa_is_social               ndi_pay_person_acc.dppa_is_social%TYPE,
        p_dppa_ab_id                   ndi_pay_person_acc.dppa_ab_id%TYPE,
        p_dppa_description             ndi_pay_person_acc.dppa_description%TYPE,
        p_dppa_nb_filia_num         IN ndi_pay_person_acc.dppa_nb_filia_num%TYPE)
    IS
    BEGIN
        UPDATE ndi_pay_person_acc
           SET dppa_dpp = p_dppa_dpp,
               dppa_nb = p_dppa_nb,
               dppa_is_main = p_dppa_is_main,
               dppa_account = p_dppa_account,
               --history_status           = p_history_status,
               dppa_last_payment_order = p_dppa_last_payment_order,
               dppa_nbg = p_dppa_nbg,
               dppa_is_social = p_dppa_is_social,
               dppa_ab_id = p_dppa_ab_id,
               dppa_description = p_dppa_description,
               dppa_hs_upd = tools.gethistsession,
               dppa_nb_filia_num = p_dppa_nb_filia_num
         WHERE dppa_id = p_dppa_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'RDM$NDI_PAY_PERSON_ACC.update: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE set_ndi_pay_person_acc_hist_st (
        p_dppa_id          ndi_pay_person_acc.dppa_id%TYPE,
        p_history_status   ndi_pay_person_acc.history_status%TYPE)
    IS
    BEGIN
        UPDATE ndi_pay_person_acc
           SET history_status = p_history_status,
               dppa_hs_upd =
                   CASE
                       WHEN p_history_status = 'A' THEN tools.gethistsession
                       ELSE dppa_hs_upd
                   END,
               dppa_hs_del =
                   CASE
                       WHEN p_history_status = 'H' THEN tools.gethistsession
                       ELSE dppa_hs_del
                   END
         WHERE dppa_id = p_dppa_id;
    END;
BEGIN
    NULL;
END api$dic_contragent;
/