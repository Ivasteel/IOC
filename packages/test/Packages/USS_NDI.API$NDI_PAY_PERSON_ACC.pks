/* Formatted on 8/12/2025 5:55:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.API$NDI_PAY_PERSON_ACC
IS
    -- рахунки
    PROCEDURE get_pay_person_acc_list (p_dpp_id   IN     NUMBER,
                                       res_cur       OUT SYS_REFCURSOR);
END;
/


/* Formatted on 8/12/2025 5:55:29 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.API$NDI_PAY_PERSON_ACC
IS
    -- рахунки
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
END;
/