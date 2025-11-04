/* Formatted on 8/12/2025 5:55:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.DNET$NDI_PAY_PERSON_ACC
IS
    -- рахунки
    PROCEDURE get_pay_person_acc_list (p_dpp_id   IN     NUMBER,
                                       res_cur       OUT SYS_REFCURSOR);
END;
/


GRANT EXECUTE ON USS_NDI.DNET$NDI_PAY_PERSON_ACC TO DNET_PROXY
/


/* Formatted on 8/12/2025 5:55:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.DNET$NDI_PAY_PERSON_ACC
IS
    -- рахунки
    PROCEDURE get_pay_person_acc_list (p_dpp_id   IN     NUMBER,
                                       res_cur       OUT SYS_REFCURSOR)
    IS
    BEGIN
        api$ndi_pay_person_acc.get_pay_person_acc_list (
            p_dpp_id   => p_dpp_id,
            res_cur    => res_cur);
    END;
END;
/