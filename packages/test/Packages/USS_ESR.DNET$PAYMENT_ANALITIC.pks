/* Formatted on 8/12/2025 5:48:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.DNET$PAYMENT_ANALITIC
IS
    -- Author  : BOGDAN
    -- Created : 06.07.2021 12:19:36
    -- Purpose :

    Package_Name   VARCHAR2 (100) := 'DNET$PAYMENT_ANALITIC';

    TYPE t_arr IS TABLE OF NUMBER;


    TYPE r_rpo_deduction IS RECORD
    (
        Dn_Id           deduction.dn_id%TYPE,
        Month_Period    DATE,
        Sum_Tp          VARCHAR2 (10),
        Dn_Sum          NUMBER
    );

    TYPE t_rpo_deduction IS TABLE OF r_rpo_deduction;


    -- повертає призначення ПД з шаблона
    FUNCTION get_purpose (p_po_id IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE GET_PAYMENT_ANAL_FORM (p_dt                 DATE,
                                     p_pe_nb       IN     NUMBER,
                                     p_pe_dpp      IN     NUMBER,
                                     p_pe_tp       IN     VARCHAR2,
                                     p_pe_st       IN     VARCHAR2,
                                     p_pe_pay_tp   IN     VARCHAR2,
                                     p_pe_npc      IN     NUMBER,
                                     p_pe_nbg      IN     NUMBER,
                                     p_pe_src      IN     VARCHAR2,
                                     res_cur          OUT SYS_REFCURSOR);

    -- Видае список виплат для аналітичної форми
    PROCEDURE GET_PAYROL_REESTR (p_dt                 DATE,
                                 p_pe_nb       IN     NUMBER,
                                 p_pe_dpp      IN     NUMBER,
                                 p_pe_tp       IN     VARCHAR2,
                                 p_pe_st       IN     VARCHAR2,
                                 p_pe_pay_tp   IN     VARCHAR2,
                                 p_pe_npc      IN     NUMBER,
                                 p_pe_nbg      IN     NUMBER,
                                 p_pe_src      IN     VARCHAR2,
                                 P_WHERE       IN     VARCHAR2,
                                 RES_CUR          OUT SYS_REFCURSOR);

    -- Пошук реквізитів платника/отримувача
    PROCEDURE Search_Props (p_code           IN     VARCHAR2,
                            p_dpp_tp         IN     VARCHAR2,
                            p_dppa_nbg       IN     NUMBER,
                            p_dppa_account   IN     VARCHAR2,
                            p_nb_name        IN     VARCHAR2,
                            p_dpp_tax_code   IN     VARCHAR2,
                            p_nb_mfo         IN     VARCHAR2,
                            res_cur             OUT SYS_REFCURSOR);

    -- Створення ПД по вибраним ячейкам аналітичної карточки "Списки на виплату"
    PROCEDURE CREATE_PAY_ORDERS (
        p_dt                        DATE,
        p_pe_nb                  IN NUMBER,
        p_pe_tp                  IN VARCHAR2,
        p_pe_st                  IN VARCHAR2,
        p_pe_pay_tp              IN VARCHAR2,
        p_pe_npc                 IN NUMBER,
        p_pe_nbg                 IN NUMBER,
        p_pe_src                 IN VARCHAR2,
        P_WHERE                  IN VARCHAR2,
        p_PO_DATE_PAY            IN pay_order.po_pay_dt%TYPE,
        P_PO_DPPA_PAYER          IN pay_order.po_dppa_payer%TYPE,
        p_PO_BANK_ACCOUNT_SRC    IN pay_order.PO_BANK_ACCOUNT_SRC%TYPE,
        p_PO_BANK_MFO_SRC        IN pay_order.PO_BANK_MFO_SRC%TYPE,
        p_PO_TAX_CODE_SRC        IN pay_order.PO_TAX_CODE_SRC%TYPE,
        p_PO_NAME_SRC            IN pay_order.PO_NAME_SRC%TYPE,
        p_PO_BANK_NAME_SRC       IN pay_order.PO_BANK_NAME_SRC%TYPE,
        P_PO_DPPA_RECIPIENT      IN pay_order.po_dppa_recipient%TYPE,
        p_PO_BANK_ACCOUNT_DEST   IN pay_order.PO_BANK_ACCOUNT_DEST%TYPE,
        p_PO_BANK_MFO_DEST       IN pay_order.PO_BANK_MFO_DEST%TYPE,
        p_PO_TAX_CODE_DEST       IN pay_order.PO_TAX_CODE_DEST%TYPE,
        p_PO_NAME_DEST           IN pay_order.PO_NAME_DEST%TYPE,
        p_PO_BANK_NAME_DEST      IN pay_order.PO_BANK_NAME_DEST%TYPE,
        p_PO_DPG                 IN pay_order.PO_DPG%TYPE,
        p_PO_NIE_AB              IN pay_order.Po_Nie_Ab%TYPE,
        p_Is_Ur_Obligation       IN NUMBER);

    --------------------------------------------------------------------------
    --------------------------- Платіжне доручення ---------------------------

    -- журнал ПД
    PROCEDURE GET_PAY_ORDER_JOURNAL (
        P_PO_DT_START       IN     DATE,
        P_PO_DT_STOP        IN     DATE,
        P_PO_PAY_DT_START   IN     DATE,
        P_PO_PAY_DT_STOP    IN     DATE,
        P_PO_NUMBER         IN     VARCHAR2,
        P_PO_ST             IN     VARCHAR2,
        P_NB_ID             IN     NUMBER,
        P_PO_SRC            IN     VARCHAR2,
        RES_CUR                OUT SYS_REFCURSOR);

    -- запит на видачу даних для картки ПД
    PROCEDURE GET_PAY_ORDER_CARD (P_PO_ID   IN     NUMBER,
                                  PO_CUR       OUT SYS_REFCURSOR,
                                  PR_CUR       OUT SYS_REFCURSOR);

    -- редагування ПД
    PROCEDURE UPDATE_PAY_ORDER (
        P_PO_ID                  IN NUMBER,
        p_PO_PAY_DT              IN pay_order.PO_PAY_DT%TYPE,
        p_PO_BANK_ACCOUNT_DEST   IN pay_order.PO_BANK_ACCOUNT_DEST%TYPE,
        p_PO_NAME_DEST           IN pay_order.PO_NAME_DEST%TYPE,
        --p_PO_DPG               IN pay_order.PO_DPG%type,
        p_PO_PURPOSE             IN pay_order.PO_PURPOSE%TYPE,
        --p_PO_NIE_AB            IN pay_order.po_nie_ab%TYPE,
        p_po_dppa_recipient      IN pay_order.po_dppa_recipient%TYPE,
        p_Po_Circ_Tp             IN pay_order.Po_Circ_Tp%TYPE,
        p_po_cto                 IN pay_order.po_cto%TYPE);

    -- зафіксувати вибрані ПД
    PROCEDURE FIX_SELECTED_ORDERS (P_IDS IN VARCHAR2);

    -- розфіксувати вибрані ПД
    PROCEDURE UNFIX_SELECTED_ORDERS (P_IDS IN VARCHAR2);

    -- перевести в статус "Проведено банком" вибрані ПД
    PROCEDURE PROVE_SELECTED_ORDERS (P_IDS IN VARCHAR2);

    -- видалити вибрані ПД
    PROCEDURE DELETE_SELECTED_ORDERS (P_IDS IN VARCHAR2);

    -- видалити вибрані відомості ПД
    PROCEDURE DELETE_SELECTED_STATEMENTS (P_IDS     IN VARCHAR2,
                                          P_PO_ID   IN NUMBER);

    -- #70238: Додати функцію імпорту банківської виписки (аналогічно, як в АБ).
    PROCEDURE IMPORT_BANK_DATA (
        P_Nbi_Is_Diff_Payer               IN VARCHAR2,
        P_Nbi_In_Field_Val                IN VARCHAR2,
        P_Nbi_Receip_Edrpou_Field_Val     IN VARCHAR2,
        P_Nbi_Payer_Edrpou_Field_Val      IN VARCHAR2,
        P_Nbi_Purpose_Field_Val           IN VARCHAR2,
        P_Nbi_Dt_Field_Val                IN DATE,
        P_Nbi_Doc_Num_Field_Val           IN VARCHAR2,
        P_Nbi_Receip_Name_Field_Val       IN VARCHAR2,
        P_Nbi_Payer_Name_Field_Val        IN VARCHAR2,
        P_Nbi_Account_Field_Val           IN VARCHAR2,
        P_Nbi_Curr_Code_Tp                IN VARCHAR2,
        P_Nbi_Curr_Code_Field_Val         IN VARCHAR2,
        P_Nbi_Sum_Field_Val               IN VARCHAR2,
        P_Nbi_Sum_Val_Field_Val           IN VARCHAR2,
        P_Nbi_Payer_Bnk_Mfo_Field_Val     IN VARCHAR2,
        P_Nbi_Payer_Bnk_Name_Field_Val    IN VARCHAR2,
        P_Nbi_Receip_Bnk_Mfo_Field_Val    IN VARCHAR2,
        P_Nbi_Receip_Bnk_Name_Field_Val   IN VARCHAR2,
        P_Nbi_Payer_Bnk_Acc_Field_Val     IN VARCHAR2,
        P_Nbi_Doc_Dt_Field_Val            IN DATE,
        P_Nbi_Id                          IN NUMBER,
        p_dppa_id                         IN NUMBER);


    -------------------------------------------------------------------------
    --------------------------- RETURN PAY ORDER  ---------------------------
    -------------------------------------------------------------------------


    -- #73055 - Журнал ПД повернення
    PROCEDURE GET_RETURN_PAY_ORDER_JOURNAL (
        P_PO_DT_START       IN     DATE,
        P_PO_DT_STOP        IN     DATE,
        P_PO_PAY_DT_START   IN     DATE,
        P_PO_PAY_DT_STOP    IN     DATE,
        P_PO_NUMBER         IN     VARCHAR2,
        P_PO_ST             IN     VARCHAR2,
        P_NB_ID             IN     NUMBER,
        P_PO_SRC            IN     VARCHAR2,
        RES_CUR                OUT SYS_REFCURSOR);

    -- #73055 - запит на видачу даних для картки ПД повернення
    PROCEDURE GET_RETURN_PAY_ORDER_CARD (P_PO_ID   IN     NUMBER,
                                         PO_CUR       OUT SYS_REFCURSOR,
                                         RRL_CUR      OUT SYS_REFCURSOR);

    -- #73055 - видає список невикористаних записів returns_reestr для звязки з ПД
    PROCEDURE GET_UNSELECT_RETURN_REESTR (p_po_id   IN     NUMBER,
                                          res_cur      OUT SYS_REFCURSOR);

    -- #73055 - привязати реєстр до ПД повернення
    PROCEDURE LINK_RR_TO_PD (p_po_id IN NUMBER, p_ids IN VARCHAR2);

    -- #73055 - обробка реэстрів повернень
    PROCEDURE SEND_TO_PROCESS (p_ids IN VARCHAR2);

    -- #73055 - зняти привязку реєстра до ПД повернення
    PROCEDURE RELEASE_REESTR (p_rrl_id IN NUMBER);

    -- #73055 - видалити реєстр, створений вручну
    PROCEDURE DELETE_REESTR (p_rr_id IN NUMBER);

    -- #73055 - Зняти прив'язку до ОР
    PROCEDURE DELETE_REESTR_PNF (p_rrl_id IN uss_esr.rr_list.rrl_id%TYPE);

    -- #73055 - створення реєстру повернення
    PROCEDURE CREATE_REESTR (P_PO_ID         IN     NUMBER,
                             P_RR_PD_LINES   IN     NUMBER,
                             P_RR_PD_SUM     IN     NUMBER,
                             P_RR_ID            OUT NUMBER);

    -- #73055 - створення повернення
    PROCEDURE CREATE_REESTR_DETAIL (
        p_rrl_rr           IN uss_esr.rr_list.rrl_rr%TYPE,
        p_rrl_num          IN uss_esr.rr_list.rrl_num%TYPE,
        p_rrl_ln           IN uss_esr.rr_list.rrl_ln%TYPE,
        p_rrl_fn           IN uss_esr.rr_list.rrl_fn%TYPE,
        p_rrl_mn           IN uss_esr.rr_list.rrl_mn%TYPE,
        p_rrl_numident     IN uss_esr.rr_list.rrl_numident%TYPE,
        p_rrl_ser_num      IN uss_esr.rr_list.rrl_ser_num%TYPE,
        p_rrl_num_acc      IN uss_esr.rr_list.rrl_num_acc%TYPE,
        p_rrl_sum_return   IN uss_esr.rr_list.rrl_sum_return%TYPE,
        p_rrl_rsn_return   IN uss_esr.rr_list.rrl_rsn_return%TYPE,
        p_rrl_org          IN uss_esr.rr_list.rrl_org%TYPE,
        p_rrl_num_or       IN uss_esr.rr_list.rrl_num_or%TYPE);

    -- #73301 - редагування повернення
    PROCEDURE UPDATE_REESTR_DETAIL (
        p_rrl_id           IN uss_esr.rr_list.rrl_id%TYPE,
        p_rrl_num          IN uss_esr.rr_list.rrl_num%TYPE,
        p_rrl_ln           IN uss_esr.rr_list.rrl_ln%TYPE,
        p_rrl_fn           IN uss_esr.rr_list.rrl_fn%TYPE,
        p_rrl_mn           IN uss_esr.rr_list.rrl_mn%TYPE,
        p_rrl_numident     IN uss_esr.rr_list.rrl_numident%TYPE,
        p_rrl_ser_num      IN uss_esr.rr_list.rrl_ser_num%TYPE,
        p_rrl_num_acc      IN uss_esr.rr_list.rrl_num_acc%TYPE,
        p_rrl_sum_return   IN uss_esr.rr_list.rrl_sum_return%TYPE,
        p_rrl_rsn_return   IN uss_esr.rr_list.rrl_rsn_return%TYPE,
        p_rrl_org          IN uss_esr.rr_list.rrl_org%TYPE,
        p_rrl_num_or       IN uss_esr.rr_list.rrl_num_or%TYPE);

    -- #81594: неоплата АСОПД, журнал
    PROCEDURE get_notpay_list (p_org_id     IN     NUMBER,
                               p_dt_start   IN     DATE,
                               p_dt_stop    IN     DATE,
                               res_cur         OUT SYS_REFCURSOR);


    -- #81594: неоплата АСОПД, картка
    PROCEDURE get_notpay_card (p_rr_id   IN     NUMBER,
                               res_cur      OUT SYS_REFCURSOR,
                               det_cur      OUT SYS_REFCURSOR);

    -- #81594: неоплата АСОПД, дані для опрацювання
    -- mode: 0 - по всіх параметрах пошук
    --       1 - по ПІБ + РНОКПП
    --       2 - по ПІБ + ІБАН
    --       3 - по РНОКПП + ІБАН
    PROCEDURE get_process_data (p_rrl_id   IN     NUMBER,
                                p_mode     IN     NUMBER,
                                res_cur       OUT SYS_REFCURSOR);

    -- #81594: неоплата АСОПД, опрацювання вибраних нарахувань
    PROCEDURE PROCESS_RRL (p_rrl_id IN NUMBER, p_list IN VARCHAR2);


    ----------------------------------------------------------------------------------------
    ----------------- #86318: Ручне введення "Платіжне доручення повернення коштів" --------

    PROCEDURE create_return_pd (
        p_po_number              IN     pay_order.po_number%TYPE,
        p_PO_PAY_DT              IN     pay_order.po_pay_dt%TYPE,
        p_po_sum                 IN     pay_order.po_sum%TYPE,
        p_po_purpose             IN     pay_order.po_purpose%TYPE,
        --P_PO_DPPA_PAYER        IN pay_order.po_dppa_payer%TYPE,
        p_PO_BANK_ACCOUNT_SRC    IN     pay_order.PO_BANK_ACCOUNT_SRC%TYPE,
        p_PO_BANK_MFO_SRC        IN     pay_order.PO_BANK_MFO_SRC%TYPE,
        p_PO_TAX_CODE_SRC        IN     pay_order.PO_TAX_CODE_SRC%TYPE,
        p_PO_NAME_SRC            IN     pay_order.PO_NAME_SRC%TYPE,
        p_PO_BANK_NAME_SRC       IN     pay_order.PO_BANK_NAME_SRC%TYPE,
        P_PO_DPPA_RECIPIENT      IN     pay_order.po_dppa_recipient%TYPE,
        p_PO_BANK_ACCOUNT_DEST   IN     pay_order.PO_BANK_ACCOUNT_DEST%TYPE,
        p_PO_BANK_MFO_DEST       IN     pay_order.PO_BANK_MFO_DEST%TYPE,
        p_PO_TAX_CODE_DEST       IN     pay_order.PO_TAX_CODE_DEST%TYPE,
        p_PO_NAME_DEST           IN     pay_order.PO_NAME_DEST%TYPE,
        p_PO_BANK_NAME_DEST      IN     pay_order.PO_BANK_NAME_DEST%TYPE,
        p_new_id                    OUT pay_order.po_id%TYPE);

    PROCEDURE update_return_pd (
        p_po_id                  IN pay_order.po_id%TYPE,
        p_po_number              IN pay_order.po_number%TYPE,
        p_PO_PAY_DT              IN pay_order.po_pay_dt%TYPE,
        p_po_sum                 IN pay_order.po_sum%TYPE,
        p_po_purpose             IN pay_order.po_purpose%TYPE,
        --P_PO_DPPA_PAYER        IN pay_order.po_dppa_payer%TYPE,
        p_PO_BANK_ACCOUNT_SRC    IN pay_order.PO_BANK_ACCOUNT_SRC%TYPE,
        p_PO_BANK_MFO_SRC        IN pay_order.PO_BANK_MFO_SRC%TYPE,
        p_PO_TAX_CODE_SRC        IN pay_order.PO_TAX_CODE_SRC%TYPE,
        p_PO_NAME_SRC            IN pay_order.PO_NAME_SRC%TYPE,
        p_PO_BANK_NAME_SRC       IN pay_order.PO_BANK_NAME_SRC%TYPE,
        P_PO_DPPA_RECIPIENT      IN pay_order.po_dppa_recipient%TYPE,
        p_PO_BANK_ACCOUNT_DEST   IN pay_order.PO_BANK_ACCOUNT_DEST%TYPE,
        p_PO_BANK_MFO_DEST       IN pay_order.PO_BANK_MFO_DEST%TYPE,
        p_PO_TAX_CODE_DEST       IN pay_order.PO_TAX_CODE_DEST%TYPE,
        p_PO_NAME_DEST           IN pay_order.PO_NAME_DEST%TYPE,
        p_PO_BANK_NAME_DEST      IN pay_order.PO_BANK_NAME_DEST%TYPE);

    -- видалення
    PROCEDURE delete_return_po (p_po_id IN NUMBER);

    -- пошук ЕОС
    PROCEDURE search_pc (p_rrl_id       IN     NUMBER,
                         p_Found_Cnt       OUT INTEGER,
                         p_Show_Modal      OUT NUMBER,
                         RES_CUR           OUT SYS_REFCURSOR);


    -- прив"язка ЕОС до реєстру ПД
    PROCEDURE save_rrl_pc (p_rrl_id   IN NUMBER,
                           p_pc_id    IN NUMBER,
                           p_pc_num   IN VARCHAR2,
                           p_pc_ln    IN VARCHAR2,
                           p_pc_fn    IN VARCHAR2,
                           p_pc_mn    IN VARCHAR2);

    -- список утримань для реєстру ПД
    PROCEDURE get_rrl_deduction_list (p_rrl_id   IN     NUMBER,
                                      RES_CUR       OUT SYS_REFCURSOR);

    -- обробка списку утримань по реєстру ПД
    PROCEDURE process_rrl_deduction_list (p_rrl_id IN NUMBER, p_xml IN CLOB);



    ---------------------------------------------------------
    -------------------- відрахування -----------------------

    PROCEDURE GET_DDS_PAYMENT_ANAL_FORM (p_dt                 DATE,
                                         p_pe_dpp      IN     NUMBER,
                                         p_pe_dpp_Tp   IN     VARCHAR2,
                                         p_pe_tp       IN     VARCHAR2,
                                         p_pe_st       IN     VARCHAR2,
                                         p_pe_npc      IN     NUMBER,
                                         p_pe_nbg      IN     NUMBER,
                                         p_pe_src      IN     VARCHAR2,
                                         res_cur          OUT SYS_REFCURSOR);


    PROCEDURE GET_DDS_PAYROL_REESTR (p_dt                 DATE,
                                     p_pe_dpp      IN     NUMBER,
                                     p_pe_dpp_Tp   IN     VARCHAR2,
                                     p_pe_tp       IN     VARCHAR2,
                                     p_pe_st       IN     VARCHAR2,
                                     p_pe_npc      IN     NUMBER,
                                     p_pe_nbg      IN     NUMBER,
                                     p_pe_src      IN     VARCHAR2,
                                     P_WHERE       IN     VARCHAR2,
                                     RES_CUR          OUT SYS_REFCURSOR);

    PROCEDURE CREATE_DDS_PAY_ORDERS (
        p_dt                        DATE,
        p_pe_dpp                 IN NUMBER,
        p_pe_dpp_Tp              IN VARCHAR2,
        p_pe_tp                  IN VARCHAR2,
        p_pe_st                  IN VARCHAR2,
        p_pe_npc                 IN NUMBER,
        p_pe_nbg                 IN NUMBER,
        p_pe_src                 IN VARCHAR2,
        P_WHERE                  IN VARCHAR2,
        p_PO_DATE_PAY            IN pay_order.po_pay_dt%TYPE,
        P_PO_DPPA_PAYER          IN pay_order.po_dppa_payer%TYPE,
        p_PO_BANK_ACCOUNT_SRC    IN pay_order.PO_BANK_ACCOUNT_SRC%TYPE,
        p_PO_BANK_MFO_SRC        IN pay_order.PO_BANK_MFO_SRC%TYPE,
        p_PO_TAX_CODE_SRC        IN pay_order.PO_TAX_CODE_SRC%TYPE,
        p_PO_NAME_SRC            IN pay_order.PO_NAME_SRC%TYPE,
        p_PO_BANK_NAME_SRC       IN pay_order.PO_BANK_NAME_SRC%TYPE,
        P_PO_DPPA_RECIPIENT      IN pay_order.po_dppa_recipient%TYPE,
        p_PO_BANK_ACCOUNT_DEST   IN pay_order.PO_BANK_ACCOUNT_DEST%TYPE,
        p_PO_BANK_MFO_DEST       IN pay_order.PO_BANK_MFO_DEST%TYPE,
        p_PO_TAX_CODE_DEST       IN pay_order.PO_TAX_CODE_DEST%TYPE,
        p_PO_NAME_DEST           IN pay_order.PO_NAME_DEST%TYPE,
        p_PO_BANK_NAME_DEST      IN pay_order.PO_BANK_NAME_DEST%TYPE,
        p_PO_DPG                 IN pay_order.PO_DPG%TYPE,
        p_PO_NIE_AB              IN pay_order.Po_Nie_Ab%TYPE,
        p_Is_Ur_Obligation       IN NUMBER);
END DNET$PAYMENT_ANALITIC;
/


GRANT EXECUTE ON USS_ESR.DNET$PAYMENT_ANALITIC TO DNET_PROXY
/

GRANT EXECUTE ON USS_ESR.DNET$PAYMENT_ANALITIC TO II01RC_USS_ESR_WEB
/


/* Formatted on 8/12/2025 5:49:32 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.DNET$PAYMENT_ANALITIC
IS
    -------------------------------------------------------------------------
    --------------------------- Списки на виплату ---------------------------

    -- повертає призначення ПД з шаблона
    FUNCTION get_purpose (p_po_id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_res    VARCHAR (4000);
        l_temp   VARCHAR2 (1000);
        l_row    pay_order%ROWTYPE;
    BEGIN
        SELECT *
          INTO l_row
          FROM pay_order t
         WHERE t.po_id = p_po_id;

        SELECT t.dpg_template
          INTO l_res
          FROM uss_ndi.v_ndi_distrib_purpose_gr t
         WHERE t.dpg_id = l_row.po_dpg;

        l_res := REPLACE (l_res, '<РІК>', TO_CHAR (l_row.po_pay_dt, 'YYYY'));
        l_res := REPLACE (l_res, '<№ СПИСКУ>', l_row.po_num);
        l_res :=
            REPLACE (l_res, '<РОБОЧА ДАТА>', TO_CHAR (SYSDATE, 'DD.MM.YYYY'));

        SELECT z.dic_name
          INTO l_temp
          FROM uss_ndi.v_ddn_month_names z
         WHERE z.dic_value = TO_CHAR (l_row.po_pay_dt, 'MM');

        l_res := REPLACE (l_res, '<МІСЯЦЬ>', l_temp);
        l_res := REPLACE (l_res, '<ОТРИМУВАЧ_НАЗВА>', l_row.po_name_dest);
        l_res :=
            REPLACE (l_res, '<ОТРИМУВАЧ_ЄДРПОУ>', l_row.po_tax_code_dest);
        l_res := REPLACE (l_res, '<ОСЗН>', tools.getcurrorg);

        SELECT MAX (c.npc_code)
          INTO l_temp
          FROM payroll_reestr  t
               JOIN uss_ndi.v_ndi_payment_codes c ON (c.npc_id = t.pe_npc)
         WHERE t.pe_po = p_po_id AND ROWNUM <= 1;

        l_res := REPLACE (l_res, '<ТИП_ВИПЛАТИ>', l_temp);
        l_res := REPLACE (l_res, '<НОМЕР_СПИСКУ>', l_row.po_num);

        SELECT LISTAGG (dt, ',') WITHIN GROUP (ORDER BY dt)
          INTO l_temp
          FROM (SELECT DISTINCT TO_CHAR (zz.pe_pay_dt, 'DD')     AS dt
                  FROM v_payroll_reestr zz
                 WHERE zz.pe_po = p_po_id);

        l_res := REPLACE (l_res, '<ДНІ>', l_temp);

        SELECT CASE WHEN cnt = 1 THEN n ELSE NULL END
          INTO l_temp
          FROM (SELECT MAX (c.npc_name)              AS n,
                       COUNT (DISTINCT c.npc_id)     AS cnt
                  FROM v_payroll_reestr  z
                       JOIN uss_ndi.v_ndi_payment_codes c
                           ON (c.npc_id = z.pe_npc)
                 WHERE z.pe_po = p_po_id);

        l_res := REPLACE (l_res, '<НАЗВА_ВІДОМОСТІ>', l_temp);
        RETURN l_res;
    END;

    PROCEDURE GET_PAYMENT_ANAL_FORM (p_dt                 DATE,
                                     p_pe_nb       IN     NUMBER,
                                     p_pe_dpp      IN     NUMBER,
                                     p_pe_tp       IN     VARCHAR2,
                                     p_pe_st       IN     VARCHAR2,
                                     p_pe_pay_tp   IN     VARCHAR2,
                                     p_pe_npc      IN     NUMBER,
                                     p_pe_nbg      IN     NUMBER,
                                     p_pe_src      IN     VARCHAR2,
                                     res_cur          OUT SYS_REFCURSOR)
    IS
        l_first_date   DATE := TRUNC (P_DT, 'MM');
        l_last_date    DATE := LAST_DAY (l_first_date);
        l_last_day     NUMBER := EXTRACT (DAY FROM l_last_date);
        l_org_to       NUMBER := tools.getcurrorgto;
        l_org_id       NUMBER := tools.getcurrorg;
        l_org_acc      NUMBER := tools.GetCurrOrgAcc;
    BEGIN
        tools.WriteMsg ('DNET$PAYMENT_ANALITIC.' || $$PLSQL_UNIT);

        OPEN RES_CUR FOR
            SELECT t.*
              FROM (  SELECT po.org_name,
                             po.org_id,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d01,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 1
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d02,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 2
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d03,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 3
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d04,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 4
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d05,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 5
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d06,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 6
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d07,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 7
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d08,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 8
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d09,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 9
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d10,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 10
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d11,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 11
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d12,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 12
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d13,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 13
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d14,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 14
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d15,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 15
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d16,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 16
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d17,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 17
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d18,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 18
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d19,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 19
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d20,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 20
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d21,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 21
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d22,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 22
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d23,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 23
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d24,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 24
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d25,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 25
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d26,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 26
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d27,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 27
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d28,
                             CASE
                                 WHEN l_last_day >= 29
                                 THEN
                                     SUM (
                                         CASE
                                             WHEN t.pe_pay_dt =
                                                  l_first_date + 28
                                             THEN
                                                 t.pe_sum
                                         END)
                             END               AS sum_d29,
                             CASE
                                 WHEN l_last_day >= 30
                                 THEN
                                     SUM (
                                         CASE
                                             WHEN t.pe_pay_dt =
                                                  l_first_date + 29
                                             THEN
                                                 t.pe_sum
                                         END)
                             END               AS sum_d30,
                             CASE
                                 WHEN l_last_day >= 31
                                 THEN
                                     SUM (
                                         CASE
                                             WHEN t.pe_pay_dt =
                                                  l_first_date + 30
                                             THEN
                                                 t.pe_sum
                                         END)
                             END               AS sum_d31,
                             SUM (t.pe_sum)    AS total_sum
                        FROM v_payroll_reestr t
                             JOIN v_opfu p ON (p.org_id = t.com_org)
                             -- #81443
                             /*LEFT JOIN v_opfu po ON (po.org_id = decode(l_org_to, 31, p.org_id, 32, p.org_id,
                                  DECODE(p.org_to, 1, p.org_id, 2, p.org_id, NULL, p.org_id, p.org_org)) ) */
                             LEFT JOIN v_opfu po
                                 ON (po.org_id =
                                     DECODE (l_org_to,
                                             31, p.org_acc_org,
                                             32, p.org_id,
                                             34, p.org_acc_org,
                                             p.org_org))
                             LEFT JOIN uss_ndi.v_ndi_bank b
                                 ON (b.nb_id = t.pe_nb)
                       WHERE     t.pe_pay_dt BETWEEN l_first_date
                                                 AND l_last_date
                             AND t.pe_class = 'AID'
                             AND (p_pe_tp IS NULL OR t.pe_tp = p_pe_tp)
                             AND (   p_pe_pay_tp IS NULL
                                  OR t.pe_pay_tp = p_pe_pay_tp)
                             -----#81443
                             --- #89275 20230703
                             --AND (l_org_id = 56525 AND t.pe_npc = 57 OR l_org_to = 30 AND t.pe_npc = 24 OR l_org_to != 30 AND (t.pe_npc IS NULL OR t.pe_npc != 24 AND t.pe_npc != 57))
                             AND (   l_org_to = 30 AND t.pe_npc = 24
                                  OR     l_org_to != 30
                                     AND (t.pe_npc IS NULL OR t.pe_npc != 24))
                             AND (       p_pe_npc = 57
                                     AND po.org_acc_org = l_org_id
                                  OR p_pe_npc IS NULL
                                  OR p_pe_npc != 57)
                             -- #86647
                             /* AND (l_org_to != 32 AND l_org_to != 34
                                       OR l_org_to = 32 AND ( l_org_id = l_org_acc AND po.org_acc_org = p.org_id OR l_org_id != l_org_acc AND po.org_id = p.org_id)
                                       OR l_org_to = 34 AND p.org_acc_org = l_org_id)*/
                             --------
                             --AND (p_pe_st IS NULL OR t.pe_st = p_pe_st)
                             AND (   p_pe_st IS NULL
                                  OR     p_pe_st = 'NEW'
                                     AND t.pe_st = p_pe_st
                                     AND t.pe_po IS NULL
                                     AND (   p_pe_pay_tp IS NULL
                                          OR p_pe_pay_tp != 2
                                          OR     p_pe_pay_tp = 2
                                             AND t.pe_nb IS NOT NULL)
                                  OR     p_pe_st = 'SELECTED'
                                     AND t.pe_po IS NOT NULL
                                     AND EXISTS
                                             (SELECT *
                                                FROM pay_order z
                                               WHERE     z.po_id = t.pe_po
                                                     AND z.po_st != 'APPR')
                                  OR     p_pe_st = 'PROVE'
                                     AND t.pe_po IS NOT NULL
                                     AND EXISTS
                                             (SELECT *
                                                FROM pay_order z
                                               WHERE     z.po_id = t.pe_po
                                                     AND z.po_st = 'APPR'))
                             AND (p_pe_nbg IS NULL OR t.pe_nbg = p_pe_nbg)
                             AND (p_pe_npc IS NULL OR t.pe_npc = p_pe_npc)
                             AND (p_pe_src IS NULL OR t.pe_src = p_pe_src)
                             AND (p_pe_nb IS NULL OR p_pe_nb IN (b.nb_id /*, b.nb_nb*/
                                                                        ))
                             AND (   p_pe_dpp IS NULL
                                  OR (       t.pe_po IS NULL
                                         AND EXISTS
                                                 (SELECT *
                                                    FROM uss_ndi.v_ndi_pay_person
                                                         zp
                                                   WHERE     zp.dpp_id =
                                                             p_pe_dpp
                                                         AND po.org_id =
                                                             zp.dpp_org)
                                      OR     t.pe_po IS NOT NULL
                                         AND EXISTS
                                                 (SELECT *
                                                    FROM pay_order z
                                                         JOIN
                                                         uss_ndi.v_ndi_pay_person
                                                         zp
                                                             ON (zp.dpp_tax_code =
                                                                 z.po_tax_code_dest)
                                                   WHERE     zp.dpp_id =
                                                             p_pe_dpp
                                                         AND z.po_id = t.pe_po)))
                    GROUP BY po.org_name, po.org_id
                    ORDER BY po.org_id, po.org_name) t
             WHERE t.total_sum IS NOT NULL AND t.total_sum != 0;
    END;

    -- Видае список виплат для аналітичної форми
    PROCEDURE GET_PAYROL_REESTR (p_dt                 DATE,
                                 p_pe_nb       IN     NUMBER,
                                 p_pe_dpp      IN     NUMBER,
                                 p_pe_tp       IN     VARCHAR2,
                                 p_pe_st       IN     VARCHAR2,
                                 p_pe_pay_tp   IN     VARCHAR2,
                                 p_pe_npc      IN     NUMBER,
                                 p_pe_nbg      IN     NUMBER,
                                 p_pe_src      IN     VARCHAR2,
                                 P_WHERE       IN     VARCHAR2,
                                 RES_CUR          OUT SYS_REFCURSOR)
    IS
        l_org_to    NUMBER := tools.getcurrorgto;
        l_org_id    NUMBER := tools.getcurrorg;
        l_org_acc   NUMBER := tools.GetCurrOrgAcc;

        v_sql       VARCHAR2 (30000)
            :=    'SELECT t.pe_id,
                                     t.pe_src_entity,
                                     t.pe_rbm_pkt,
                                     t.pe_bnk_rbm_code,
                                     t.com_org,
                                     t.pe_tp,
                                     t.pe_code,
                                     t.pe_name,
                                     t.pe_pay_tp,
                                     ptp.dic_sname AS pe_pay_tp_name,
                                     nb.nb_name,
                                     nb.nb_mfo,
                                     t.pe_pay_dt,
                                     t.pe_row_cnt,
                                     t.pe_sum,
                                     t.pe_st,
                                     t.pe_po,
                                     t.pe_dt,
                                     t.pe_src_create_dt,
                                     cd.npc_name AS pe_code_name,
                                     tp.dic_sname AS pe_tp_name,
                                     st.dic_sname AS pe_st_name,
                                     p.org_name AS com_org_name
                                FROM v_payroll_reestr t
                                JOIN v_opfu p ON (p.org_id = t.com_org)
                                /*LEFT JOIN v_opfu po ON (po.org_id = decode('
               || l_org_to
               || ', 31, p.org_id,  32, p.org_id,
                                             DECODE(p.org_to, 1, p.org_id, 2, p.org_id, NULL, p.org_id, p.org_org)) )*/
                                LEFT JOIN v_opfu po ON (po.org_id = decode('
               || l_org_to
               || ', 31, p.org_acc_org, 32, p.org_id, 34, p.org_acc_org, p.org_org) )
                                left join uss_ndi.v_ndi_bank nb on (nb.nb_id = t.pe_nb)
                               /* LEFT JOIN uss_ndi.v_ddn_pe_code cd ON (cd.dic_value = t.pe_code and cd.dic_st = ''A'')*/
                                LEFT JOIN uss_ndi.v_ndi_payment_codes cd ON (cd.npc_code = t.pe_code)
                                LEFT JOIN uss_ndi.v_ddn_pe_tp tp ON (tp.dic_value = t.pe_tp)
                                LEFT JOIN uss_ndi.v_ddn_pe_st st ON (st.dic_value = t.pe_st)
                                left join uss_ndi.v_ddn_pe_pay_tp ptp on (t.pe_pay_tp = ptp.dic_value)
                                '
               || CASE
                      WHEN p_pe_nb IS NOT NULL
                      THEN
                          'LEFT JOIN uss_ndi.v_ndi_bank b ON (b.nb_id = t.pe_nb)'
                  END
               || '
                               WHERE 1 = 1
                                 AND t.pe_class = ''AID''
                                 -----#81443

                                '
               || CASE
                      WHEN p_pe_nb IS NOT NULL
                      THEN
                          '  AND t.pe_nb IN (b.nb_id/*, b.nb_nb*/) '
                  END
               || CASE
                      WHEN P_pe_TP IS NOT NULL
                      THEN
                          ' and t.pe_tp = ''' || P_pe_TP || ''''
                  END
               -----#81443
               || CASE --WHEN l_org_to = 32 AND l_org_id != l_org_acc THEN ' and po.org_acc_org = p.org_id '
 --WHEN l_org_to = 32 AND l_org_id = l_org_acc THEN ' and po.org_id = p.org_id '
                   WHEN l_org_to = 32 THEN ' and po.org_id = p.org_id ' -- WHEN l_org_to = 34 THEN ' and p.org_acc_org = ' || l_org_id
                                                                        END
               || CASE
                      WHEN l_org_to = 30 THEN ' AND (t.pe_npc = 24) '
                      ELSE ' AND (t.pe_npc IS NULL OR t.pe_npc != 24) '
                  END
               || CASE
                      WHEN p_pe_npc = 57
                      THEN
                          ' AND po.org_acc_org = ' || l_org_id
                  END
               || CASE
                      WHEN p_pe_pay_tp IS NOT NULL
                      THEN
                          ' and t.pe_pay_tp = ''' || p_pe_pay_tp || ''''
                  END
               || CASE
                      WHEN p_pe_st = 'NEW'
                      THEN
                             ' and t.pe_st = ''NEW'' AND t.pe_po IS NULL '
                          || CASE
                                 WHEN p_pe_pay_tp = '2'
                                 THEN
                                     ' AND t.pe_nb IS NOT NULL'
                             END
                      WHEN p_pe_st = 'SELECTED'
                      THEN
                          ' AND t.pe_po IS NOT NULL AND EXISTS (SELECT * FROM pay_order z WHERE z.po_id = t.pe_po AND z.po_st != ''APPR'')'
                      WHEN p_pe_st = 'PROVE'
                      THEN
                          ' AND t.pe_po IS NOT NULL AND EXISTS (SELECT * FROM pay_order z WHERE z.po_id = t.pe_po AND z.po_st = ''APPR'')'
                  END
               || CASE
                      WHEN p_pe_nbg IS NOT NULL
                      THEN
                          ' and t.pe_nbg = ' || p_pe_nbg
                  END
               || CASE
                      WHEN p_pe_npc IS NOT NULL
                      THEN
                          ' and t.pe_npc = ' || p_pe_npc
                  END
               || CASE
                      WHEN p_pe_src IS NOT NULL
                      THEN
                          ' and t.pe_src = ''' || p_pe_src || ''''
                  END
               || CASE
                      WHEN p_pe_dpp IS NOT NULL
                      THEN
                             ' AND (t.pe_po IS NULL AND EXISTS (SELECT *
                                                                        FROM uss_ndi.v_ndi_pay_person zp
                                                                       WHERE zp.dpp_id = '
                          || p_pe_dpp
                          || '
                                                                         AND po.org_id = zp.dpp_org)
                                         OR t.pe_po IS NOT NULL AND EXISTS (SELECT *
                                                                              FROM pay_order z
                                                                              JOIN uss_ndi.v_ndi_pay_person zp ON (zp.dpp_tax_code = z.po_tax_code_dest)
                                                                             WHERE zp.dpp_id = '
                          || p_pe_dpp
                          || '
                                                                               AND  z.po_id = t.pe_po)
                                    )'
                  END
               || P_WHERE
               || ' order by pe_dt';
    BEGIN
        tools.WriteMsg ('DNET$PAYMENT_ANALITIC.' || $$PLSQL_UNIT);

        TOOLS.validate_param (p_pe_tp);
        TOOLS.validate_param (p_pe_st);
        TOOLS.validate_param (p_pe_pay_tp);
        TOOLS.validate_param (p_pe_src);

        --TOOLS.validate_param(P_WHERE);

        --raise_application_error(-20000, substr(v_sql, length(v_sql) - 1000, 1000));
        OPEN RES_CUR FOR v_sql;
    END;


    -- Пошук реквізитів платника/отримувача
    PROCEDURE Search_Props (p_code           IN     VARCHAR2,
                            p_dpp_tp         IN     VARCHAR2,
                            p_dppa_nbg       IN     NUMBER,
                            p_dppa_account   IN     VARCHAR2,
                            p_nb_name        IN     VARCHAR2,
                            p_dpp_tax_code   IN     VARCHAR2,
                            p_nb_mfo         IN     VARCHAR2,
                            res_cur             OUT SYS_REFCURSOR)
    IS
        l_org   NUMBER := tools.getcurrorg;
    BEGIN
        tools.WriteMsg ('DNET$PAYMENT_ANALITIC.' || $$PLSQL_UNIT);

        --raise_application_error(-20000, tools.getcurrorg);

        IF (p_code = 'POST')
        THEN
            OPEN res_cur FOR
                SELECT dppa.dppa_account,
                       nb.nb_id,
                       nb.nb_mfo,
                       nb.nb_name,
                       dpp.dpp_tax_code,
                       dpp.dpp_name,
                       dppa.dppa_id,
                       bp.nbg_kpk_code
                  FROM uss_ndi.V_NDI_PAY_PERSON  dpp
                       JOIN uss_ndi.V_NDI_PAY_PERSON_ACC dppa
                           ON (dpp.dpp_id = dppa.dppa_dpp)
                       JOIN uss_ndi.v_ndi_fin_pay_config c
                           ON (c.nfpc_dppa = dppa.dppa_id)
                       LEFT JOIN uss_ndi.v_ndi_bank nb
                           ON (nb.nb_id = dppa.dppa_nb)
                       LEFT JOIN uss_ndi.v_ndi_budget_program bp
                           ON (bp.nbg_id = dppa.dppa_nbg)
                 WHERE     1 = 1
                       AND c.com_org = l_org
                       AND c.nfpc_pay_tp = 'POST'
                       AND (p_dpp_tp IS NULL OR dpp.dpp_tp = p_dpp_tp)
                       --AND (p_dppa_nbg IS NULL OR dppa.dppa_nbg = p_dppa_nbg) -- #90666
                       AND (   p_dppa_account IS NULL
                            OR dppa.dppa_account = p_dppa_account)
                       AND (   p_nb_name IS NULL
                            OR nb.nb_name LIKE '%' || p_nb_name || '%')
                       AND (   p_dpp_tax_code IS NULL
                            OR dpp.dpp_tax_code = p_dpp_tax_code)
                       AND (p_nb_mfo IS NULL OR nb.nb_mfo = p_nb_mfo)
                       AND dppa.history_status = 'A'
                       AND dpp.history_status = 'A'
                       AND dppa_is_social = 'T'--AND dppa.dppa_ab_id IS NOT NULL
                                               ;
        ELSE
            OPEN res_cur FOR
                SELECT dppa.dppa_account,
                       nb.nb_mfo,
                       nb.nb_name,
                       dpp.dpp_tax_code,
                       dpp.dpp_name,
                       dppa.dppa_id,
                       bp.nbg_kpk_code
                  FROM uss_ndi.V_NDI_PAY_PERSON  dpp
                       JOIN uss_ndi.V_NDI_PAY_PERSON_ACC dppa
                           ON (dpp.dpp_id = dppa.dppa_dpp)
                       LEFT JOIN uss_ndi.v_ndi_bank nb
                           ON (nb.nb_id = dppa.dppa_nb)
                       LEFT JOIN uss_ndi.v_ndi_budget_program bp
                           ON (bp.nbg_id = dppa.dppa_nbg)
                 WHERE     1 = 1
                       AND (   p_code IS NULL
                            OR p_code != 'SRC'
                            OR p_code = 'SRC' AND dpp.dpp_org = l_org)
                       AND (p_dpp_tp IS NULL OR dpp.dpp_tp = p_dpp_tp)
                       AND (p_dppa_nbg IS NULL OR dppa.dppa_nbg = p_dppa_nbg)
                       AND (   p_dppa_account IS NULL
                            OR dppa.dppa_account = p_dppa_account)
                       AND (   p_nb_name IS NULL
                            OR nb.nb_name LIKE '%' || p_nb_name || '%')
                       AND (   p_dpp_tax_code IS NULL
                            OR dpp.dpp_tax_code = p_dpp_tax_code)
                       AND (p_nb_mfo IS NULL OR nb.nb_mfo = p_nb_mfo)
                       AND dppa.history_status = 'A'
                       AND dpp.history_status = 'A'
                       AND dppa_is_social = 'T'--AND dppa.dppa_ab_id IS NOT NULL
                                               ;
        END IF;
    END;

    -- Створення ПД по вибраним ячейкам аналітичної карточки "Списки на виплату"
    PROCEDURE CREATE_PAY_ORDERS (
        p_dt                        DATE,
        p_pe_nb                  IN NUMBER,
        p_pe_tp                  IN VARCHAR2,
        p_pe_st                  IN VARCHAR2,
        p_pe_pay_tp              IN VARCHAR2,
        p_pe_npc                 IN NUMBER,
        p_pe_nbg                 IN NUMBER,
        p_pe_src                 IN VARCHAR2,
        P_WHERE                  IN VARCHAR2,
        p_PO_DATE_PAY            IN pay_order.po_pay_dt%TYPE,
        P_PO_DPPA_PAYER          IN pay_order.po_dppa_payer%TYPE,
        p_PO_BANK_ACCOUNT_SRC    IN pay_order.PO_BANK_ACCOUNT_SRC%TYPE,
        p_PO_BANK_MFO_SRC        IN pay_order.PO_BANK_MFO_SRC%TYPE,
        p_PO_TAX_CODE_SRC        IN pay_order.PO_TAX_CODE_SRC%TYPE,
        p_PO_NAME_SRC            IN pay_order.PO_NAME_SRC%TYPE,
        p_PO_BANK_NAME_SRC       IN pay_order.PO_BANK_NAME_SRC%TYPE,
        P_PO_DPPA_RECIPIENT      IN pay_order.po_dppa_recipient%TYPE,
        p_PO_BANK_ACCOUNT_DEST   IN pay_order.PO_BANK_ACCOUNT_DEST%TYPE,
        p_PO_BANK_MFO_DEST       IN pay_order.PO_BANK_MFO_DEST%TYPE,
        p_PO_TAX_CODE_DEST       IN pay_order.PO_TAX_CODE_DEST%TYPE,
        p_PO_NAME_DEST           IN pay_order.PO_NAME_DEST%TYPE,
        p_PO_BANK_NAME_DEST      IN pay_order.PO_BANK_NAME_DEST%TYPE,
        p_PO_DPG                 IN pay_order.PO_DPG%TYPE,
        p_PO_NIE_AB              IN pay_order.Po_Nie_Ab%TYPE,
        p_Is_Ur_Obligation       IN NUMBER)
    IS
        l_arr         t_arr := t_arr ();
        l_org_to      NUMBER := tools.getcurrorgto;
        l_org         NUMBER := tools.getcurrorg;
        l_year        PLS_INTEGER := EXTRACT (YEAR FROM SYSDATE);
        l_ba_id       NUMBER;
        l_cto_ur_id   NUMBER;
        l_tot_sum     NUMBER;

        l_sql         VARCHAR2 (30000)
            :=    'SELECT DISTINCT t.pe_nb as nb_id
                                FROM v_payroll_reestr t
                                JOIN v_opfu p ON (p.org_id = t.com_org)
                                /*LEFT JOIN v_opfu po ON (po.org_id = decode('
               || l_org_to
               || ', 31, p.org_id, 32, p.org_id,
                                             DECODE(p.org_to, 1, p.org_id, 2, p.org_id, NULL, p.org_id, p.org_org)) ) */
                                LEFT JOIN v_opfu po ON (po.org_id = decode('
               || l_org_to
               || ', 31, p.org_acc_org, 32, p.org_id, 34, p.org_acc_org, p.org_org) )
                               WHERE 1 = 1
                               AND t.pe_class = ''AID''
                                 and t.pe_po is null
                                 and pe_nb is not null
                                 AND t.pe_st = ''NEW'''
               || CASE
                      WHEN p_pe_tp IS NOT NULL
                      THEN
                          ' and t.pe_tp = ''' || p_pe_tp || ''''
                  END
               -----#81443
               /* || CASE WHEN l_org_to = 32 THEN ' and po.org_acc_org = p.org_id '
                        WHEN l_org_to = 34 THEN ' and p.org_acc_org = ' || l_org END*/
               || CASE
                      WHEN l_org_to = 30 THEN ' and t.pe_npc = 24 '
                      ELSE ' AND (t.pe_npc IS NULL OR t.pe_npc != 24) '
                  END
               || CASE
                      WHEN p_pe_npc = 57
                      THEN
                          ' AND po.org_acc_org = ' || l_org
                  END
               || CASE
                      WHEN p_pe_src IS NOT NULL
                      THEN
                          ' and t.pe_src = ''' || p_pe_src || ''''
                  END
               || CASE
                      WHEN p_pe_pay_tp IS NOT NULL
                      THEN
                          ' and t.pe_pay_tp = ''' || p_pe_pay_tp || ''''
                  END
               || CASE
                      WHEN p_pe_npc IS NOT NULL
                      THEN
                          ' and t.pe_npc = ' || p_pe_npc
                  END
               || CASE
                      WHEN p_pe_nbg IS NOT NULL
                      THEN
                          ' and t.pe_nbg = ' || p_pe_nbg
                  END
               || P_WHERE;

        PROCEDURE CREATE_UR_OBLIGATION
        IS
            l_nfs_id        NUMBER;
            l_nkv_id        NUMBER;
            l_dt            DATE
                := TO_DATE ('31.12.' || TO_CHAR (SYSDATE, 'YYYY'),
                            'DD.MM.YYYY');
            l_cto_tp        VARCHAR2 (10) := 'LEG_OBLIG';
            l_cto_oper_tp   VARCHAR2 (10) := 'LEG_OBL';
        BEGIN
            SELECT MAX (t.nfs_id)
              INTO l_nfs_id
              FROM uss_ndi.v_ndi_funding_source t
             WHERE t.nfs_nbg = p_pe_nbg;

            SELECT MAX (c.npc_nkv)
              INTO l_nkv_id
              FROM uss_ndi.v_ndi_payment_codes c
             WHERE c.npc_id = p_pe_npc;

            INSERT INTO obligation (cto_tp,
                                    cto_oper_tp,
                                    com_org,
                                    cto_nfs,
                                    cto_nkv,
                                    cto_pdv_tp,
                                    cto_sum,
                                    cto_sum_without_pdv,
                                    cto_sum_pdv,
                                    cto_dksu_unload_dt,
                                    cto_dksu_get_dt,
                                    cto_dt,
                                    cto_dppa_own,
                                    cto_st,
                                    cto_last_pay_dt,
                                    cto_term_dt,
                                    cto_reestr_dt,
                                    cto_acc_oper)
                 VALUES (l_cto_tp,
                         l_cto_oper_tp,
                         tools.getcurrorg,
                         l_nfs_id,
                         l_nkv_id,
                         'N',
                         0,
                         0,
                         0,
                         TRUNC (SYSDATE),
                         TRUNC (SYSDATE),
                         TRUNC (SYSDATE),
                         P_PO_DPPA_PAYER,
                         'IP',
                         l_dt,
                         l_dt,
                         TRUNC (SYSDATE),
                         'GET')
              RETURNING cto_id
                   INTO l_cto_ur_id;
        END;

        FUNCTION CREATE_OBLIGATION (p_po_id      IN NUMBER,
                                    p_dppa_id    IN NUMBER,
                                    p_dpp_id1    IN NUMBER,
                                    p_dppa_id1   IN NUMBER,
                                    p_sum        IN NUMBER,
                                    p_num        IN VARCHAR2,
                                    p_po_num     IN VARCHAR2)
            RETURN NUMBER
        IS
            l_cto_id        NUMBER;
            l_nfs_id        NUMBER;
            l_nkv_id        NUMBER;
            l_dt            DATE
                := TO_DATE ('31.12.' || TO_CHAR (SYSDATE, 'YYYY'),
                            'DD.MM.YYYY');
            l_cto_tp        VARCHAR2 (10) := 'FIN_OBLIG'; --CASE WHEN p_Is_Ur_Obligation = 1 THEN 'LEG_OBLIG' ELSE 'FIN_OBLIG' END;
            l_cto_oper_tp   VARCHAR2 (10) := 'FIN_OBL'; --CASE WHEN p_Is_Ur_Obligation = 1 THEN 'LEG_OBL' ELSE 'FIN_OBL' END;
        BEGIN
            SELECT MAX (t.nfs_id)
              INTO l_nfs_id
              FROM uss_ndi.v_ndi_funding_source t
             WHERE t.nfs_nbg = p_pe_nbg;

            SELECT MAX (c.npc_nkv)
              INTO l_nkv_id
              FROM payroll_reestr  t
                   JOIN uss_ndi.v_ndi_payment_codes c
                       ON (c.npc_id = t.pe_npc)
             WHERE t.pe_po = p_po_id
             FETCH FIRST ROW ONLY;

            INSERT INTO obligation (cto_tp,
                                    cto_oper_tp,
                                    com_org,
                                    cto_nfs,
                                    cto_dppa_own,
                                    cto_pdv_tp,
                                    cto_sum,
                                    cto_sum_without_pdv,
                                    cto_sum_pdv,
                                    cto_reestr_num,
                                    cto_num,
                                    cto_dksu_unload_dt,
                                    cto_dksu_get_dt,
                                    cto_dt,
                                    cto_dppa_ca,
                                    cto_dpp,
                                    cto_nkv,
                                    cto_st,
                                    cto_last_pay_dt,
                                    cto_term_dt,
                                    cto_reestr_dt,
                                    cto_acc_oper,
                                    cto_cto_ur)
                 VALUES (l_cto_tp,
                         l_cto_oper_tp,
                         tools.getcurrorg,
                         l_nfs_id,
                         p_dppa_id,
                         'N',
                         p_sum,
                         p_sum,
                         0,
                         p_num,
                         p_po_num,
                         TRUNC (SYSDATE),
                         TRUNC (SYSDATE),
                         TRUNC (SYSDATE),
                         p_dppa_id1,
                         p_dpp_id1,
                         l_nkv_id,
                         'IP',
                         l_dt,
                         l_dt,
                         TRUNC (SYSDATE),
                         'GET',
                         l_cto_ur_id)
              RETURNING cto_id
                   INTO l_cto_id;

            RETURN l_cto_id;
        END;

        FUNCTION SEED_PO (P_NB_ID IN NUMBER)
            RETURN NUMBER
        IS
            l_po_id            NUMBER;
            l_sum              NUMBER;
            l_cto_id           NUMBER;
            l_num              NUMBER
                := uss_ndi.tools.get_last_pay_order_num (P_PO_DPPA_PAYER);
            l_row              uss_ndi.v_ndi_bank%ROWTYPE;
            l_dpp_row          uss_ndi.v_ndi_pay_person%ROWTYPE;
            l_acc_row          uss_ndi.v_ndi_pay_person_acc%ROWTYPE;
            l_bank_row         uss_ndi.v_ndi_bank%ROWTYPE;
            l_purpose          pay_order.po_purpose%TYPE;
            l_payer_bank_row   uss_ndi.v_ndi_bank%ROWTYPE;     --банк платника
            l_po_num           NUMBER;
        BEGIN
            SELECT *
              INTO l_row
              FROM uss_ndi.v_ndi_bank t
             WHERE t.nb_id = p_nb_id;

            --raise_application_error(-20000, l_row.nb_edrpou);
            BEGIN
                SELECT t.*
                  INTO l_dpp_row
                  FROM uss_ndi.v_ndi_pay_person t
                 WHERE     t.dpp_tax_code = l_row.nb_edrpou
                       AND t.history_status = 'A'
                 FETCH FIRST ROW ONLY;
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;

            BEGIN
                SELECT d.*
                  INTO l_acc_row
                  FROM uss_ndi.v_ndi_fin_pay_config  t
                       JOIN uss_ndi.v_ndi_pay_person_acc d
                           ON (d.dppa_id = t.nfpc_dppa)
                 WHERE     t.nfpc_nb = P_NB_ID
                       AND t.history_status = 'A'
                       AND d.history_status = 'A'
                       AND t.nfpc_pay_tp = 'BANK'
                       AND t.com_org = tools.getcurrorg
                 FETCH FIRST ROW ONLY;
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;

            BEGIN
                SELECT b.*
                  INTO l_bank_row
                  FROM uss_ndi.v_ndi_bank b
                 WHERE b.nb_id = l_acc_row.dppa_nb AND b.history_status = 'A'
                 FETCH FIRST ROW ONLY;
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;

            /*         raise_application_error(-20000, 'p_nb_id='||p_nb_id||';tools.getcurrorg='||tools.getcurrorg||
                ';l_acc_row.dppa_id='||l_acc_row.dppa_account||';l_row.nb_id='||l_row.nb_id
                ||';l_dpp_row.dpp_id='||l_dpp_row.dpp_id||';l_dpp_row.dpp_name='||l_dpp_row.dpp_name
                ||';l_bank_row.nb_id='||l_bank_row.nb_id);*/

            SELECT COALESCE (MAX (TO_NUMBER (t.po_num)), 0) + 1
              INTO l_po_num
              FROM pay_order t
             WHERE t.po_pay_dt = p_po_date_pay AND t.com_org_src = l_org;

            --raise_application_error(-20000, l_dpp_row.dpp_tax_code);

            INSERT INTO pay_order (po_create_dt,
                                   po_pay_dt,
                                   po_number,
                                   po_sum,
                                   com_org_src,
                                   --com_org_dst,
                                   po_bank_account_src,
                                   po_bank_account_dest,
                                   po_bank_mfo_src,
                                   po_bank_mfo_dest,
                                   po_nb_src,
                                   po_nb_dest,
                                   po_tax_code_src,
                                   po_tax_code_dest,
                                   po_name_src,
                                   po_name_dest,
                                   po_bank_name_src,
                                   po_bank_name_dest,
                                   po_src,
                                   po_st,
                                   po_purpose,
                                   po_dpg,
                                   PO_NIE_AB,
                                   po_dppa_payer,
                                   po_dppa_recipient,
                                   po_circ_tp,
                                   po_num)
                 VALUES (SYSDATE,
                         p_po_date_pay,
                         l_num,
                         0,
                         l_org,
                         --p_com_org_dst,
                         p_po_bank_account_src,
                         COALESCE (l_acc_row.dppa_account, ' '),
                         p_po_bank_mfo_src,
                         l_row.nb_mfo,
                         NULL,
                         p_nb_id,
                         p_po_tax_code_src,
                         l_dpp_row.dpp_tax_code,
                         p_po_name_src,
                         COALESCE (                     /*l_bank_row.nb_name*/
                                   l_dpp_row.dpp_name, ' '),
                         p_po_bank_name_src,
                         l_row.nb_sname,
                         'OUT',
                         'E',
                         ' ',
                         p_po_dpg,
                         p_PO_NIE_AB,
                         P_PO_DPPA_PAYER,
                         l_acc_row.dppa_id,
                         'VD',
                         l_po_num)
              RETURNING po_id
                   INTO l_po_id;

            EXECUTE IMMEDIATE   'update v_payroll_reestr r
                           set r.pe_po = '
                             || l_po_id
                             || '
                          where r.pe_id in (SELECT t.pe_id
                                              FROM v_payroll_reestr t
                                              JOIN uss_ndi.v_ndi_bank b ON (b.nb_id = t.pe_nb)
                                              JOIN v_opfu p ON (p.org_id = t.com_org)
                                              /*LEFT JOIN v_opfu po ON (po.org_id = decode('
                             || l_org_to
                             || ', 31, p.org_id,  32, p.org_id,
                                                                                DECODE(p.org_to, 1, p.org_id, 2, p.org_id, NULL, p.org_id, p.org_org)) ) */
                                              LEFT JOIN v_opfu po ON (po.org_id = decode('
                             || l_org_to
                             || ', 31, p.org_acc_org, 32, p.org_id, 34, p.org_acc_org, p.org_org) )
                                             WHERE (b.nb_id = '
                             || l_row.nb_id
                             ||        /*' or b.nb_nb = ' || l_row.nb_id  ||*/
                                ')
                                              and t.pe_po is null
                                              AND t.pe_class = ''AID''
                                              and pe_nb is not null
                                              and t.pe_sum is not null and t.pe_sum != 0
                                             -----#81443
                                              AND t.pe_st = ''NEW'''
                             || CASE
                                    WHEN p_pe_tp IS NOT NULL
                                    THEN
                                           ' and t.pe_tp = '''
                                        || p_pe_tp
                                        || ''''
                                END
                             -----#81443
                             || CASE
                                    WHEN l_org_to = 30
                                    THEN
                                        ' and t.pe_npc = 24 '
                                    ELSE
                                        ' AND (t.pe_npc IS NULL OR t.pe_npc != 24) '
                                END
                             || CASE
                                    WHEN p_pe_npc = 57
                                    THEN
                                        ' AND po.org_acc_org = ' || l_org
                                END
                             /*|| CASE WHEN l_org_to = 32 THEN ' and po.org_acc_org = p.org_id '
                                     WHEN l_org_to = 34 THEN ' and p.org_acc_org = ' || l_org END*/
                             || CASE
                                    WHEN p_pe_src IS NOT NULL
                                    THEN
                                           ' and t.pe_src = '''
                                        || p_pe_src
                                        || ''''
                                END
                             || CASE
                                    WHEN p_pe_pay_tp IS NOT NULL
                                    THEN
                                           ' and t.pe_pay_tp = '''
                                        || p_pe_pay_tp
                                        || ''''
                                END
                             || CASE
                                    WHEN p_pe_npc IS NOT NULL
                                    THEN
                                        ' and t.pe_npc = ' || p_pe_npc
                                END
                             || CASE
                                    WHEN p_pe_nbg IS NOT NULL
                                    THEN
                                        ' and t.pe_nbg = ' || p_pe_nbg
                                END
                             || P_WHERE
                             || ')';

            SELECT SUM (t.pe_sum)
              INTO l_sum
              FROM v_payroll_reestr t
             WHERE t.pe_po = l_po_id;

            l_purpose := get_purpose (l_po_id);

            --вычисляем банк платника по его счету P_PO_DPPA_PAYER
            SELECT b.*
              INTO l_payer_bank_row
              FROM uss_ndi.v_ndi_bank b
             WHERE b.nb_id = (SELECT dppa_nb
                                FROM uss_ndi.v_ndi_pay_person_acc
                               WHERE dppa_id = P_PO_DPPA_PAYER);

            IF (l_payer_bank_row.nb_is_treasury = 'T')
            THEN
                l_cto_id :=
                    CREATE_OBLIGATION (l_po_id,
                                       P_PO_DPPA_PAYER,
                                       l_dpp_row.dpp_id,
                                       l_acc_row.dppa_id,
                                       l_sum,
                                       l_num,
                                       l_po_num);
            END IF;

            UPDATE pay_order
               SET po_sum = l_sum, po_purpose = l_purpose, po_cto = l_cto_id
             WHERE po_id = l_po_id;

            RETURN l_sum;
        END;

        FUNCTION SEED_PO_POST
            RETURN NUMBER
        IS
            l_po_id            NUMBER;
            l_po_num           VARCHAR2 (10);
            l_sum              NUMBER;
            l_dpp_id           NUMBER;
            l_cto_id           NUMBER;
            l_num              NUMBER
                := uss_ndi.tools.get_last_pay_order_num (P_PO_DPPA_PAYER);
            l_purpose          pay_order.po_purpose%TYPE;
            l_payer_bank_row   uss_ndi.v_ndi_bank%ROWTYPE;     --банк платника
        BEGIN
            SELECT COALESCE (MAX (TO_NUMBER (t.po_num)), 0) + 1
              INTO l_po_num
              FROM pay_order t
             WHERE t.po_pay_dt = p_po_date_pay AND t.com_org_src = l_org;


            INSERT INTO pay_order (po_create_dt,
                                   po_pay_dt,
                                   po_number,
                                   po_sum,
                                   com_org_src,
                                   --com_org_dst,
                                   po_bank_account_src,
                                   po_bank_account_dest,
                                   po_bank_mfo_src,
                                   po_bank_mfo_dest,
                                   po_tax_code_src,
                                   po_tax_code_dest,
                                   po_name_src,
                                   po_name_dest,
                                   po_bank_name_src,
                                   po_bank_name_dest,
                                   po_src,
                                   po_st,
                                   po_purpose,
                                   po_dpg,
                                   PO_NIE_AB,
                                   po_dppa_payer,
                                   po_dppa_recipient,
                                   po_circ_tp,
                                   po_num)
                 VALUES (SYSDATE,
                         p_po_date_pay,
                         l_num,
                         0,
                         l_org,
                         --p_com_org_dst,
                         p_po_bank_account_src,
                         p_po_bank_account_dest,
                         p_po_bank_mfo_src,
                         p_po_bank_mfo_dest,
                         p_po_tax_code_src,
                         p_po_tax_code_dest,
                         p_po_name_src,
                         COALESCE (p_po_name_dest, ' '),
                         p_po_bank_name_src,
                         p_po_bank_name_dest,
                         'OUT',
                         'E',
                         ' ',
                         p_po_dpg,
                         p_PO_NIE_AB,
                         P_PO_DPPA_PAYER,
                         P_PO_DPPA_recipient,
                         'VD',
                         l_po_num)
              RETURNING po_id
                   INTO l_po_id;

            EXECUTE IMMEDIATE   'update v_payroll_reestr r
                           set r.pe_po = '
                             || l_po_id
                             || '
                          where r.pe_id in (SELECT t.pe_id
                                              FROM v_payroll_reestr t
                                              JOIN v_opfu p ON (p.org_id = t.com_org)
                                              /*LEFT JOIN v_opfu po ON (po.org_id = decode('
                             || l_org_to
                             || ', 31, p.org_id,  32, p.org_id,
                                                                                DECODE(p.org_to, 1, p.org_id, 2, p.org_id, NULL, p.org_id, p.org_org)) ) */
                                               LEFT JOIN v_opfu po ON (po.org_id = decode('
                             || l_org_to
                             || ', 31, p.org_acc_org, 32, p.org_id, 34, p.org_acc_org, p.org_org) )
                                             WHERE 1 = 1
                                              and t.pe_po is null
                                              AND t.pe_class = ''AID''
                                              and t.pe_sum is not null and t.pe_sum != 0
                                              AND t.pe_st = ''NEW'''
                             || CASE
                                    WHEN p_pe_tp IS NOT NULL
                                    THEN
                                           ' and t.pe_tp = '''
                                        || p_pe_tp
                                        || ''''
                                END
                             -----#81443
                             || CASE
                                    WHEN l_org_to = 30
                                    THEN
                                        ' and t.pe_npc = 24 '
                                    ELSE
                                        ' AND (t.pe_npc IS NULL OR t.pe_npc != 24) '
                                END
                             || CASE
                                    WHEN p_pe_npc = 57
                                    THEN
                                        ' AND po.org_acc_org = ' || l_org
                                END
                             /*|| CASE WHEN l_org_to = 32 THEN ' and po.org_acc_org = p.org_id '
                                     WHEN l_org_to = 34 THEN ' and p.org_acc_org = ' || l_org END*/
                             || CASE
                                    WHEN p_pe_src IS NOT NULL
                                    THEN
                                           ' and t.pe_src = '''
                                        || p_pe_src
                                        || ''''
                                END
                             || CASE
                                    WHEN p_pe_pay_tp IS NOT NULL
                                    THEN
                                           ' and t.pe_pay_tp = '''
                                        || p_pe_pay_tp
                                        || ''''
                                END
                             || CASE
                                    WHEN p_pe_npc IS NOT NULL
                                    THEN
                                        ' and t.pe_npc = ' || p_pe_npc
                                END
                             || CASE
                                    WHEN p_pe_nbg IS NOT NULL
                                    THEN
                                        ' and t.pe_nbg = ' || p_pe_nbg
                                END
                             || P_WHERE
                             || ')';

            SELECT SUM (t.pe_sum)
              INTO l_sum
              FROM v_payroll_reestr t
             WHERE t.pe_po = l_po_id;

            l_purpose := get_purpose (l_po_id);

            --вычисляем банк платника по его счету P_PO_DPPA_PAYER
            SELECT b.*
              INTO l_payer_bank_row
              FROM uss_ndi.v_ndi_bank b
             WHERE b.nb_id = (SELECT dppa_nb
                                FROM uss_ndi.v_ndi_pay_person_acc
                               WHERE dppa_id = P_PO_DPPA_PAYER);

            SELECT MAX (t.dppa_dpp)
              INTO l_dpp_id
              FROM uss_ndi.v_ndi_pay_person_acc t
             WHERE t.dppa_id = P_PO_DPPA_RECIPIENT;

            IF (l_payer_bank_row.nb_is_treasury = 'T')
            THEN
                l_cto_id :=
                    CREATE_OBLIGATION (l_po_id,
                                       P_PO_DPPA_PAYER,
                                       l_dpp_id,
                                       P_PO_DPPA_RECIPIENT,
                                       l_sum,
                                       l_num,
                                       NULL);
            END IF;

            UPDATE pay_order
               SET po_sum = l_sum, po_purpose = l_purpose, po_cto = l_cto_id
             WHERE po_id = l_po_id;

            RETURN l_sum;
        END;
    BEGIN
        IF (P_pe_ST NOT IN ('NEW'))
        THEN
            raise_application_error (
                -20000,
                'Формування ПД неможливе з відповідним статусом!');
        END IF;

        IF (p_pe_pay_tp = '1' AND P_PO_DPPA_RECIPIENT IS NULL)
        THEN
            raise_application_error (-20000,
                                     'Не вказано рахунок отримувача!');
        END IF;

        /*SELECT t.dppa_ab_id
          INTO l_ba_id
          FROM uss_ndi.v_ndi_pay_person_acc t
         WHERE t.dppa_id  = P_PO_DPPA_PAYER;

        if (l_ba_id IS NULL) THEN
          raise_application_error(-20000, 'Рахунок платника не зареєстровано в підсистемі бухгалтерії!');
        END IF;*/


        TOOLS.validate_param (p_pe_tp);
        TOOLS.validate_param (p_pe_st);
        TOOLS.validate_param (p_pe_pay_tp);
        TOOLS.validate_param (p_pe_src);

        --TOOLS.validate_param(P_WHERE);


        IF (p_Is_Ur_Obligation = 1)
        THEN
            CREATE_UR_OBLIGATION ();
        END IF;

        -- post
        IF (p_pe_pay_tp = '1')
        THEN
            l_tot_sum := SEED_PO_POST ();
        ELSE
            IF (p_pe_nb IS NOT NULL)
            THEN
                l_tot_sum := SEED_PO (P_pe_NB);
            ELSE
                EXECUTE IMMEDIATE l_sql
                    BULK COLLECT INTO l_arr;

                IF (l_arr.COUNT () = 0)
                THEN
                    raise_application_error (
                        -20000,
                        'Серед вибраних отримувачів не знайдено банку!');
                END IF;

                l_tot_sum := 0;

                FOR xx IN l_arr.FIRST .. l_arr.LAST
                LOOP
                    l_tot_sum := l_tot_sum + NVL (SEED_PO (l_arr (xx)), 0);
                END LOOP;
            END IF;
        END IF;

        IF (p_Is_Ur_Obligation = 1)
        THEN
            UPDATE obligation t
               SET t.cto_sum = l_tot_sum, t.cto_sum_without_pdv = l_tot_sum
             WHERE t.cto_id = l_cto_ur_id;
        END IF;
    END;

    --------------------------------------------------------------------------
    --------------------------- Платіжне доручення ---------------------------

    -- Журнал ПД
    PROCEDURE GET_PAY_ORDER_JOURNAL (
        P_PO_DT_START       IN     DATE,
        P_PO_DT_STOP        IN     DATE,
        P_PO_PAY_DT_START   IN     DATE,
        P_PO_PAY_DT_STOP    IN     DATE,
        P_PO_NUMBER         IN     VARCHAR2,
        P_PO_ST             IN     VARCHAR2,
        P_NB_ID             IN     NUMBER,
        P_PO_SRC            IN     VARCHAR2,
        RES_CUR                OUT SYS_REFCURSOR)
    IS
        l_org   NUMBER := tools.getcurrorg;
        l_sql   VARCHAR2 (10000)
            :=    'SELECT t.*,
                                     st.dic_sname as po_st_name,
                                     null as po_bank_ppc_name
                                FROM pay_order t
                                JOIN uss_ndi.v_ddn_po_st st ON (st.dic_value = t.po_st)
                                --left join ikis_finzvit.v_rv2pda_prc_codes pc on (pc.ppc_id = t.po_bank_ppc)
                               WHERE 1 = 1
                                 and (t.po_dppa_payer is not null or t.po_dppa_recipient is not null)
                                 and t.com_org_src = '
               || l_org
               || '
                                 and t.po_src = '''
               || P_PO_SRC
               || '''
                                 ';
        l_mfo   VARCHAR2 (10);
    BEGIN
        TOOLS.validate_param (P_PO_NUMBER);
        TOOLS.validate_param (P_PO_ST);

        --TOOLS.validate_param(P_PO_SRC); -- IN/OUT

        IF (P_PO_DT_START IS NOT NULL)
        THEN
            l_sql :=
                   l_sql
                || ' and trunc(po_create_dt)  >= to_date('''
                || TO_CHAR (P_PO_DT_START, 'DD.MM.YYYY')
                || ''', ''DD.MM.YYYY'')';
        END IF;

        IF (P_PO_DT_STOP IS NOT NULL)
        THEN
            l_sql :=
                   l_sql
                || ' and trunc(po_create_dt) <= to_date('''
                || TO_CHAR (P_PO_DT_STOP, 'DD.MM.YYYY')
                || ''', ''DD.MM.YYYY'')';
        END IF;

        IF (P_PO_PAY_DT_START IS NOT NULL)
        THEN
            l_sql :=
                   l_sql
                || ' and po_pay_dt  >= to_date('''
                || TO_CHAR (P_PO_PAY_DT_START, 'DD.MM.YYYY')
                || ''', ''DD.MM.YYYY'')';
        END IF;

        IF (P_PO_PAY_DT_STOP IS NOT NULL)
        THEN
            l_sql :=
                   l_sql
                || ' and po_pay_dt <= to_date('''
                || TO_CHAR (P_PO_PAY_DT_STOP, 'DD.MM.YYYY')
                || ''', ''DD.MM.YYYY'')';
        END IF;

        IF (P_PO_NUMBER IS NOT NULL)
        THEN
            l_sql := l_sql || ' and po_number = ''' || P_PO_NUMBER || '''';
        END IF;

        IF (P_PO_ST IS NOT NULL)
        THEN
            l_sql := l_sql || ' and po_st = ''' || P_PO_ST || '''';
        END IF;

        IF (P_NB_ID IS NOT NULL)
        THEN
            SELECT t.nb_mfo
              INTO l_mfo
              FROM uss_ndi.v_ndi_bank t
             WHERE t.nb_id = P_NB_ID;

            --       raise_application_error(-20000, l_mfo);
            l_sql := l_sql || ' and po_bank_mfo_dest = ''' || l_mfo || '''';
        END IF;

        --raise_application_error(-20000, l_sql);
        OPEN res_cur FOR l_sql || ' ORDER by po_pay_dt desc';
    END;

    -- запит на видачу даних для картки ПД
    PROCEDURE GET_PAY_ORDER_CARD (P_PO_ID   IN     NUMBER,
                                  PO_CUR       OUT SYS_REFCURSOR,
                                  PR_CUR       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN PO_CUR FOR
            SELECT t.*,
                   CASE
                       WHEN o.cto_id IS NULL
                       THEN
                           ''
                       ELSE
                              '№'
                           || o.cto_num
                           || ' від '
                           || TO_CHAR (o.cto_dt, 'DD.MM.YYYY')
                   END    AS cto_descr,
                   o.cto_sum
              FROM uss_esr.pay_order  t
                   LEFT JOIN uss_esr.v_obligation o ON o.cto_id = t.po_cto
             WHERE t.PO_ID = P_PO_ID;

        OPEN Pr_CUR FOR
              SELECT t.pe_id,
                     t.pe_src_entity,
                     t.pe_rbm_pkt,
                     t.pe_bnk_rbm_code,
                     t.com_org,
                     t.pe_tp,
                     t.pe_code,
                     t.pe_name,
                     t.pe_pay_tp,
                     ptp.dic_name     AS pe_pay_tp_name,
                     nb.nb_name,
                     nb.nb_mfo,
                     t.pe_pay_dt,
                     t.pe_row_cnt,
                     t.pe_sum,
                     t.pe_st,
                     t.pe_po,
                     t.pe_dt,
                     t.pe_src_create_dt,
                     cd.npc_name      AS pe_code_name,
                     tp.dic_sname     AS pe_tp_name,
                     st.dic_sname     AS pe_st_name,
                     p.org_name       AS com_org_name
                FROM v_payroll_reestr t
                     --JOIN uss_ndi.v_ndi_bank b ON (b.nb_id = t.pe_nb)
                     JOIN v_opfu p ON (p.org_id = t.com_org)
                     LEFT JOIN uss_ndi.v_ndi_bank nb ON (nb.nb_id = t.pe_nb)
                     --LEFT JOIN uss_ndi.v_ddn_pe_code cd ON (cd.dic_value = t.pe_code and cd.dic_st = 'A')
                     LEFT JOIN uss_ndi.v_ndi_payment_codes cd
                         ON (cd.npc_code = t.pe_code)
                     LEFT JOIN uss_ndi.v_ddn_pe_tp tp
                         ON (tp.dic_value = t.pe_tp)
                     LEFT JOIN uss_ndi.v_ddn_pe_st st
                         ON (st.dic_value = t.pe_st)
                     LEFT JOIN uss_ndi.v_ddn_pe_pay_tp ptp
                         ON (ptp.dic_value = t.pe_pay_tp)
               WHERE t.pe_po = P_PO_ID
            ORDER BY t.pe_pay_dt;
    END;

    -- редагування ПД
    PROCEDURE UPDATE_PAY_ORDER (
        P_PO_ID                  IN NUMBER,
        p_PO_PAY_DT              IN pay_order.PO_PAY_DT%TYPE,
        p_PO_BANK_ACCOUNT_DEST   IN pay_order.PO_BANK_ACCOUNT_DEST%TYPE,
        p_PO_NAME_DEST           IN pay_order.PO_NAME_DEST%TYPE,
        --p_PO_DPG               IN pay_order.PO_DPG%type,
        p_PO_PURPOSE             IN pay_order.PO_PURPOSE%TYPE,
        --p_PO_NIE_AB            IN pay_order.po_nie_ab%TYPE,
        p_po_dppa_recipient      IN pay_order.po_dppa_recipient%TYPE,
        p_Po_Circ_Tp             IN pay_order.Po_Circ_Tp%TYPE,
        p_po_cto                 IN pay_order.po_cto%TYPE)
    IS
        l_flag   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO l_flag
          FROM v_pay_order t                       -- io 20211028 v_p*** + rls
         WHERE     t.po_id = P_PO_ID
               AND (   t.po_st = 'E' AND t.po_src = 'OUT'
                    OR t.po_st = 'APPR' AND t.po_src = 'IN');

        IF (l_flag = 0)
        THEN
            raise_application_error (
                -20000,
                'Редагувати вибраний ПД неможливо. Невідоповідний статус/джерело або ПД не знайдено.');
        END IF;

        UPDATE pay_order t
           SET t.po_pay_dt = P_PO_PAY_DT,
               t.po_bank_account_dest = p_PO_BANK_ACCOUNT_DEST,
               t.po_name_dest = p_PO_NAME_DEST,
               --t.po_dpg = p_PO_DPG,
               --t.po_nie_ab = p_PO_NIE_AB,
               t.po_dppa_recipient = p_po_dppa_recipient,
               t.Po_Circ_Tp = p_Po_Circ_Tp,
               t.po_cto = p_po_cto,                                   --#75058
               t.po_purpose = p_PO_PURPOSE /*(SELECT REPLACE(REPLACE(REPLACE(REPLACE(
                                        REPLACE(z.dpg_template, '<РІК>', to_char(po_pay_dt, 'YYYY')),
                                                                 '<МІСЯЦЬ>', (SELECT z.dic_sname FROM uss_ndi.v_ddn_month_names z WHERE z.dic_value = to_char(po_pay_dt, 'MM'))),
                                                                 '<ОТРИМУВАЧ_НАЗВА>', po_name_dest),
                                                                 '<ОТРИМУВАЧ_ЄДРПОУ>', po_tax_code_dest),
                                                                 '<ДНІ>', (SELECT listagg(dt, ',') within GROUP (ORDER BY dt)
                                                                             FROM (SELECT DISTINCT to_char(zz.pe_pay_dt, 'DD') AS dt
                                                                             FROM v_payroll_reestr zz
                                                                            WHERE zz.pe_po = po_id)))
                                  FROM uss_ndi.v_ndi_distrib_purpose_gr z
                                 WHERE z.dpg_id = p_PO_DPG)*/
         WHERE t.po_id = p_po_id;
    END;

    -- зафіксувати вибрані ПД
    PROCEDURE FIX_SELECTED_ORDERS (P_IDS IN VARCHAR2)
    IS
    BEGIN
        UPDATE v_pay_order t                       -- io 20211028 v_p*** + rls
           SET t.po_st = 'A'
         WHERE     t.po_st = 'E'
               --AND t.po_src = 'D'
               AND t.po_dppa_payer IS NOT NULL
               AND t.po_dppa_recipient IS NOT NULL
               AND t.po_dpg IS NOT NULL
               --AND t.po_nie_ab IS NOT NULL
               AND t.po_id IN (    SELECT REGEXP_SUBSTR (text,
                                                         '[^(\,)]+',
                                                         1,
                                                         LEVEL)    AS z_rdt_id
                                     FROM (SELECT P_IDS AS text FROM DUAL)
                               CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                                 '[^(\,)]+',
                                                                 1,
                                                                 LEVEL)) > 0);

        -- 20220506 io формуємо пакети ВВ ВПО по зафіксованих  вихідних ПД
        FOR po
            IN (SELECT *
                  FROM v_pay_order t              -- io 20211028 v_p*** + rls=
                 WHERE     t.po_st = 'A'
                       AND t.po_dppa_payer IS NOT NULL
                       AND t.po_dppa_recipient IS NOT NULL
                       AND t.po_dpg IS NOT NULL
                       AND t.po_src = 'OUT'
                       AND t.po_id IN
                               (    SELECT REGEXP_SUBSTR (text,
                                                          '[^(\,)]+',
                                                          1,
                                                          LEVEL)    AS z_rdt_id
                                      FROM (SELECT P_IDS AS text FROM DUAL)
                                CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                                  '[^(\,)]+',
                                                                  1,
                                                                  LEVEL)) > 0)
                       AND EXISTS
                               (SELECT 1
                                  FROM uss_esr.payroll_reestr  pe
                                       JOIN uss_ndi.v_ndi_budget_program nbg
                                           ON pe.pe_nbg = nbg_id
                                       JOIN uss_ndi.v_ndi_payment_codes npc
                                           ON     pe.pe_npc = npc_id
                                              AND npc.npc_code = '29'
                                 WHERE     pe_po = t.po_id                  --
                                       AND pe.pe_pay_tp = 2
                                       -- 20220829 and pe.pe_tp = 1
                                       AND nbg.nbg_kpk_code = '2501530' /* TN 20230504 '2501480'*/
                                                                       ))
        LOOP
            API$ESR_EXCHANGE.BuildJsonpktByPo (p_po_id => po.po_id);
        END LOOP;

        FOR po
            IN (SELECT *
                  FROM v_pay_order t
                 WHERE     t.po_st = 'A'
                       AND t.po_src = 'OUT'
                       AND t.po_id IN
                               (    SELECT REGEXP_SUBSTR (text,
                                                          '[^(\,)]+',
                                                          1,
                                                          LEVEL)    AS z_rdt_id
                                      FROM (SELECT P_IDS AS text FROM DUAL)
                                CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                                  '[^(\,)]+',
                                                                  1,
                                                                  LEVEL)) > 0)
                       AND EXISTS
                               (SELECT 1
                                  FROM uss_esr.payroll_reestr  pe
                                       JOIN uss_ndi.v_ndi_budget_program nbg
                                           ON pe.pe_nbg = nbg_id
                                       JOIN uss_ndi.v_ndi_payment_codes npc
                                           ON pe.pe_npc = npc_id
                                 WHERE     pe_po = t.po_id                  --
                                       -- пошта ? and pe.pe_pay_tp = 2
                                       AND npc.npc_code != '29'))
        LOOP
            API$ESR_EXCHANGE.BuildExchFilesByPo (p_po_id => po.po_id);
        END LOOP;
    END;

    -- розфіксувати вибрані ПД
    PROCEDURE UNFIX_SELECTED_ORDERS (P_IDS IN VARCHAR2)
    IS
    BEGIN
        -- 20220506 io #76999  Видаляємо невідправлені пакети ВВ ВПО по вихідних ПД
        -- При натисканні кнопки "Розфіксувати" перевіряється статус пакетів ПЕОД, пов'язаних з цим ПД.
        -- Якщо статус "Новий" або "Підписано" - пакет переводиться в статус "Видалено"
        -- Якщо статус "Відправлено" то користувачу надається повідомлення "Не можливо розфіксувати, оскільки реєстри по цьому документу відправлені в банк".
        FOR po
            IN (SELECT *
                  FROM v_pay_order t
                 WHERE     t.po_st = 'A'
                       AND t.po_src = 'OUT'
                       AND t.po_id IN
                               (    SELECT REGEXP_SUBSTR (text,
                                                          '[^(\,)]+',
                                                          1,
                                                          LEVEL)    AS z_rdt_id
                                      FROM (SELECT P_IDS AS text FROM DUAL)
                                CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                                  '[^(\,)]+',
                                                                  1,
                                                                  LEVEL)) > 0)
                       AND EXISTS
                               (SELECT 1
                                  FROM uss_esr.payroll_reestr  pe
                                       JOIN uss_ndi.v_ndi_budget_program nbg
                                           ON pe.pe_nbg = nbg_id
                                       JOIN uss_ndi.v_ndi_payment_codes npc
                                           ON pe.pe_npc = npc_id --io 20230609  and npc.npc_code = '29'
                                 WHERE pe_po = t.po_id                      --
                                                       AND pe.pe_pay_tp = 2--and pe.pe_tp = 1
                                                                           -- and nbg.nbg_kpk_code = '2501530' /* TN 20230504 '2501480'*/
                                                                           ))
        LOOP
            API$ESR_EXCHANGE.DelPoPackets (p_po_id => po.po_id);
        END LOOP;

        UPDATE v_pay_order t
           SET t.po_st = 'E'
         WHERE     t.po_st = 'A'
               --AND t.po_src = 'D'
               AND t.po_id IN (    SELECT REGEXP_SUBSTR (text,
                                                         '[^(\,)]+',
                                                         1,
                                                         LEVEL)    AS z_rdt_id
                                     FROM (SELECT P_IDS AS text FROM DUAL)
                               CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                                 '[^(\,)]+',
                                                                 1,
                                                                 LEVEL)) > 0);
    END;

    -- перевести в статус "Проведено банком" вибрані ПД
    PROCEDURE PROVE_SELECTED_ORDERS (P_IDS IN VARCHAR2)
    IS
    BEGIN
        UPDATE v_pay_order t
           SET t.po_st = 'APPR'
         WHERE     t.po_st = 'A'
               AND t.po_id IN (    SELECT REGEXP_SUBSTR (text,
                                                         '[^(\,)]+',
                                                         1,
                                                         LEVEL)    AS z_rdt_id
                                     FROM (SELECT P_IDS AS text FROM DUAL)
                               CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                                 '[^(\,)]+',
                                                                 1,
                                                                 LEVEL)) > 0);
    END;

    -- видалити вибрані ПД
    PROCEDURE DELETE_SELECTED_ORDERS (P_IDS IN VARCHAR2)
    IS
        l_check     NUMBER;
        l_cnt       NUMBER;
        l_err_msg   VARCHAR2 (4000);
        l_st        VARCHAR2 (10);
    BEGIN
            SELECT COUNT (*)
              INTO l_cnt
              FROM (SELECT P_IDS AS text FROM DUAL)
        CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                          '[^(\,)]+',
                                          1,
                                          LEVEL)) > 0;

        FOR xx IN (    SELECT REGEXP_SUBSTR (text,
                                             '[^(\,)]+',
                                             1,
                                             LEVEL)    AS id
                         FROM (SELECT P_IDS AS text FROM DUAL)
                   CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                     '[^(\,)]+',
                                                     1,
                                                     LEVEL)) > 0)
        LOOP
            BEGIN
                --FINZVIT_EXCHANGE.CheckPoReestrDel(p_po_id => xx.id, p_can_del => l_check);
                IF (l_check = 0)
                THEN
                    raise_application_error (
                        -20000,
                        'Статус вивандаженого реєстру в ПЕОД не дозволяє видалення!');
                END IF;

                --ikis_finzvit.FINZVIT_EXCHANGE.SetPoReestrDel(p_po_id => xx.id, p_msg => l_err_msg);
                --raise_application_error(-20000, l_err_msg);
                IF (l_err_msg IS NOT NULL)
                THEN
                    raise_application_error (-20000, l_err_msg);
                END IF;

                SELECT po_st
                  INTO l_st
                  FROM v_pay_order t
                 WHERE po_id = xx.id;

                IF (l_st != 'E')
                THEN
                    raise_application_error (
                        -20000,
                        'Статус ПД не дозволяє видалення!');
                END IF;

                UPDATE v_payroll_reestr t
                   SET t.pe_po = NULL
                 WHERE t.pe_po = xx.id;

                /* DELETE FROM v_obligation t
                 WHERE t.cto_id IN (SELECT z.po_cto FROM v_pay_order z WHERE z.po_id = xx.id AND z.po_st = 'E');
                 */
                DELETE FROM v_pay_order t
                      WHERE t.po_st = 'E' AND t.po_id = xx.id;
            EXCEPTION
                WHEN OTHERS
                THEN
                    IF (l_cnt = 1)
                    THEN
                        raise_application_error (-20000, SQLERRM);
                    ELSE
                        NULL;
                    END IF;
            END;
        END LOOP;
    END;

    -- видалити вибрані відомості ПД
    PROCEDURE DELETE_SELECTED_STATEMENTS (P_IDS     IN VARCHAR2,
                                          P_PO_ID   IN NUMBER)
    IS
        l_flag   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO l_flag
          FROM v_pay_order t                       -- io 20211028 v_p*** + rls
         WHERE t.po_id = P_PO_ID AND t.po_st = 'E';

        IF (l_flag = 0)
        THEN
            raise_application_error (
                -20000,
                'Видалити вибрані відомості з ПД неможливо. Невідоповідний статус або ПД не знайдено.');
        END IF;

        UPDATE v_payroll_reestr t
           SET t.pe_po = NULL
         WHERE     t.pe_po = P_PO_ID
               AND t.pe_id IN (    SELECT REGEXP_SUBSTR (text,
                                                         '[^(\,)]+',
                                                         1,
                                                         LEVEL)    AS z_rdt_id
                                     FROM (SELECT P_IDS AS text FROM DUAL)
                               CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                                 '[^(\,)]+',
                                                                 1,
                                                                 LEVEL)) > 0);

        UPDATE pay_order t
           SET t.po_sum =
                   (SELECT SUM (z.pe_sum)
                      FROM v_payroll_reestr z
                     WHERE z.pe_po = p_po_id)
         WHERE t.po_id = p_po_id;
    END;



    -- #70238: Додати функцію імпорту банківської виписки (аналогічно, як в АБ).
    PROCEDURE IMPORT_BANK_DATA (
        P_Nbi_Is_Diff_Payer               IN VARCHAR2,
        P_Nbi_In_Field_Val                IN VARCHAR2,
        P_Nbi_Receip_Edrpou_Field_Val     IN VARCHAR2,
        P_Nbi_Payer_Edrpou_Field_Val      IN VARCHAR2,
        P_Nbi_Purpose_Field_Val           IN VARCHAR2,
        P_Nbi_Dt_Field_Val                IN DATE,
        P_Nbi_Doc_Num_Field_Val           IN VARCHAR2,
        P_Nbi_Receip_Name_Field_Val       IN VARCHAR2,
        P_Nbi_Payer_Name_Field_Val        IN VARCHAR2,
        P_Nbi_Account_Field_Val           IN VARCHAR2,
        P_Nbi_Curr_Code_Tp                IN VARCHAR2,
        P_Nbi_Curr_Code_Field_Val         IN VARCHAR2,
        P_Nbi_Sum_Field_Val               IN VARCHAR2,
        P_Nbi_Sum_Val_Field_Val           IN VARCHAR2,
        P_Nbi_Payer_Bnk_Mfo_Field_Val     IN VARCHAR2,
        P_Nbi_Payer_Bnk_Name_Field_Val    IN VARCHAR2,
        P_Nbi_Receip_Bnk_Mfo_Field_Val    IN VARCHAR2,
        P_Nbi_Receip_Bnk_Name_Field_Val   IN VARCHAR2,
        P_Nbi_Payer_Bnk_Acc_Field_Val     IN VARCHAR2,
        P_Nbi_Doc_Dt_Field_Val            IN DATE,
        P_Nbi_Id                          IN NUMBER,
        p_dppa_id                         IN NUMBER)
    IS
        l_po_id          NUMBER;
        l_val            VARCHAR2 (30);
        l_res_tp         VARCHAR2 (10);

        l_res_edrpou     VARCHAR2 (10);
        l_res_name       VARCHAR2 (250);
        l_ba_number      VARCHAR2 (34);
        l_dppa_account   VARCHAR2 (34);
        l_pens           NUMBER;
        l_ca_id          NUMBER;
        l_dppa_id        NUMBER;
        l_nb_id          NUMBER;
    BEGIN
        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''. ''');

        SELECT t.nbi_in_code
          INTO l_val
          FROM uss_ndi.v_ndi_bank_cli t
         WHERE t.nbi_id = p_nbi_id;

        SELECT t.dppa_account
          INTO l_dppa_account
          FROM uss_ndi.v_ndi_pay_person_acc t
         WHERE t.dppa_id = p_dppa_id;

        SELECT MAX (t.po_id)
          INTO l_po_id
          FROM v_pay_order t                       -- io 20211028 v_p*** + rls
         WHERE     t.po_src = 'OUT'
               AND t.po_pay_dt = P_Nbi_Doc_Dt_Field_Val --to_date(P_Nbi_Doc_Dt_Field_Val, 'DD.MM.YYYY')
               AND t.po_number = P_Nbi_Doc_Num_Field_Val
               AND t.po_bank_account_src =
                   CASE
                       WHEN p_nbi_is_diff_payer = 'T'
                       THEN
                           P_Nbi_Account_Field_Val
                       ELSE
                           P_Nbi_Payer_Bnk_Acc_Field_Val
                   END;

        IF (l_po_id IS NOT NULL)
        THEN
            UPDATE pay_order
               SET po_st = 'APPR'
             WHERE po_id = l_po_id;

            RETURN;
        END IF;

        l_pens :=
            CASE
                WHEN TRIM (
                         TRANSLATE (SUBSTR (P_Nbi_Purpose_Field_Val, 1, 3),
                                    '1234567890',
                                    ' ')) =
                     ';'
                THEN
                    1
                ELSE
                    0
            END;

        -- Ознака окремих полів для платника та отримувача (НЕ ПЕРЕВІРЕНО, немає прикладу)
        IF (P_Nbi_Is_Diff_Payer = 'T')
        THEN
            IF (l_dppa_account != P_Nbi_Account_Field_Val)
            THEN
                RETURN;
            ELSIF (l_pens = 1 AND P_Nbi_In_Field_Val NOT IN ('VD', 'PVD'))
            THEN
                l_res_edrpou := P_Nbi_Payer_Edrpou_Field_Val;
                l_res_name := P_Nbi_Payer_Name_Field_Val;
                l_ba_number := P_Nbi_Payer_Bnk_Acc_Field_Val;
                l_res_tp := 'PPH';
            ELSE
                l_res_edrpou := P_Nbi_Payer_Edrpou_Field_Val;
                l_res_name := P_Nbi_Payer_Name_Field_Val;
                l_ba_number := P_Nbi_Payer_Bnk_Acc_Field_Val;
                l_res_tp := P_Nbi_In_Field_Val;
            END IF;
        -- Ознака не окремих полів для платника та отримувача
        ELSE
            IF (    P_Nbi_In_Field_Val = 'VD'
                AND l_ba_number = P_Nbi_Payer_Bnk_Acc_Field_Val /*  AND l_ct_code = p_nbi_curr_code*/
                                                               )
            THEN
                l_res_edrpou := P_Nbi_Receip_Edrpou_Field_Val;
                l_res_name := P_Nbi_Receip_Name_Field_Val;
                l_ba_number := P_Nbi_Account_Field_Val;
                l_res_tp := 'VD';
            ELSIF (    P_Nbi_In_Field_Val = 'PH'
                   AND l_ba_number = P_Nbi_Account_Field_Val /*AND l_ct_code = p_nbi_curr_code*/
                                                            )
            THEN
                l_res_edrpou := P_Nbi_Payer_Edrpou_Field_Val;
                l_res_name := P_Nbi_Payer_Bnk_Name_Field_Val;
                l_ba_number := P_Nbi_Payer_Bnk_Acc_Field_Val;
                l_res_tp := CASE WHEN l_pens = 1 THEN 'PPH' ELSE 'PH' END;
            ELSE
                RETURN;
            END IF;
        END IF;

        -- знаходимо контрагента. якщо не знайдено - створюємо його.
        -- Якщо банківський рахунок має ознаку пенсійного і ЕДРПОУ 10 символів (ФО) - використовуємо спец. контрагента (узагальгюючого для всіх пенсіонерів)
        SELECT MAX (t.dpp_id), MAX (ba.dppa_id)
          INTO l_ca_id, l_dppa_id
          FROM uss_ndi.v_ndi_pay_person  t
               JOIN uss_ndi.v_ndi_pay_person_acc ba
                   ON (ba.dppa_dpp = t.dpp_id)
         WHERE     t.dpp_tax_code = l_res_edrpou
               AND ba.dppa_account = l_ba_number;

        /*     -- старый поиск если новым не нашло
             IF (l_ca_id IS NULL) THEN
               SELECT MAX(t.dpp_id) INTO l_ca_id
               FROM uss_ndi.v_ndi_pay_person t
              WHERE t.dpp_tax_code = l_res_edrpou
                AND t.dpp_tp != 'OSZN';
             END IF;*/

        IF (l_res_tp IN ('PH', 'PPH') AND l_ca_id IS NOT NULL)
        THEN
            SELECT CASE WHEN COUNT (*) = 0 THEN l_res_tp ELSE 'PPH' END
              INTO l_res_tp
              FROM uss_ndi.v_ndi_pay_person_acc t
             WHERE t.dppa_dpp = l_ca_id AND t.dppa_account = l_ba_number;
        END IF;

        --повернення, возврат, погашення, погашение
        IF (       l_ca_id IS NULL
               AND ((   LENGTH (l_res_edrpou) = 10
                     OR INSTR (LOWER (P_Nbi_Purpose_Field_Val), 'повернення') >
                        0
                     OR INSTR (LOWER (P_Nbi_Purpose_Field_Val), 'возврат') >
                        0
                     OR INSTR (LOWER (P_Nbi_Purpose_Field_Val), 'погашення') >
                        0
                     OR INSTR (LOWER (P_Nbi_Purpose_Field_Val), 'погашение') >
                        0)          /* AND l_ba_is_pens IS NOT NULL AND l_ba_is_pens = 'T'*/
                          )
            OR l_ca_id IS NULL AND l_res_tp IN ('PH', 'PPH') /* AND l_ba_is_pens = 'T'*/
                                                            )
        THEN
            --l_ca_id := tools.GetLocalParameter('DEF_CA');
            -- якщо не знайдено в переліку контрагентів - встановити "кінцевий пенсіонер" та тип обігу "+ (пов)"
            IF (l_res_tp IN ('PH'))
            THEN
                l_res_tp := 'PPH';
            END IF;
        ELSIF (l_ca_id IS NULL)
        THEN
            l_ca_id :=
                uss_ndi.api$dic_contragent.insert_ndi_pay_person (
                    p_dpp_tax_code   => l_res_edrpou,
                    p_dpp_name       => l_res_name,
                    p_dpp_org        => tools.GetCurrOrg,
                    p_dpp_is_ur      => 'false',
                    p_dpp_sname      => SUBSTR (l_res_name, 1, 100),
                    p_dpp_address    => NULL,
                    p_dpp_tp         => 'OTHER');
        END IF;

        IF (l_dppa_id IS NULL)
        THEN
            SELECT MAX (t.nb_id)
              INTO l_nb_id
              FROM uss_ndi.v_ndi_bank t
             WHERE t.nb_mfo =
                   CASE
                       WHEN P_Nbi_Is_Diff_Payer = 'T'
                       THEN
                           CASE
                               WHEN P_Nbi_In_Field_Val = l_val
                               THEN
                                   P_Nbi_Payer_Bnk_Mfo_Field_Val
                               ELSE
                                   P_Nbi_Receip_Bnk_Mfo_Field_Val
                           END
                       ELSE
                           P_Nbi_Payer_Bnk_Mfo_Field_Val
                   END;

            l_dppa_id :=
                uss_ndi.api$dic_contragent.insert_ndi_pay_person_acc (
                    p_dppa_dpp                  => l_ca_id,
                    p_dppa_nb                   => l_nb_id,
                    p_dppa_ab_id                => NULL,
                    p_dppa_is_main              => NULL,
                    p_dppa_account              =>
                        CASE
                            WHEN P_Nbi_Is_Diff_Payer = 'T'
                            THEN
                                CASE
                                    WHEN P_Nbi_In_Field_Val = l_val
                                    THEN
                                        P_Nbi_Payer_Bnk_Acc_Field_Val
                                    ELSE
                                        P_Nbi_Account_Field_Val
                                END
                            ELSE
                                P_Nbi_Payer_Bnk_Acc_Field_Val
                        END,
                    p_dppa_last_payment_order   => 0,
                    p_dppa_nbg                  => NULL,
                    p_dppa_is_social            => 'F',
                    p_dppa_description          => NULL,
                    p_dppa_nb_filia_num         => NULL);
        END IF;


        --raise_application_error(-20000, P_Nbi_Doc_Dt_Field_Val);
        INSERT INTO pay_order t (t.po_create_dt,
                                 t.po_pay_dt,
                                 t.po_sum,
                                 t.po_number,
                                 t.com_org_src,
                                 t.com_org_dest,
                                 t.po_src,
                                 t.po_bank_account_src,
                                 t.po_bank_account_dest,
                                 t.po_bank_mfo_src,
                                 t.po_bank_mfo_dest,
                                 t.po_tax_code_src,
                                 t.po_tax_code_dest,
                                 t.po_name_src,
                                 t.po_name_dest,
                                 t.po_bank_name_src,
                                 t.po_bank_name_dest,
                                 t.po_st,
                                 t.po_purpose,
                                 t.po_circ_tp,
                                 t.po_dppa_payer)
                 VALUES (
                            P_Nbi_Doc_Dt_Field_Val,
                            P_Nbi_Dt_Field_Val,
                            TO_NUMBER (
                                REPLACE (P_Nbi_Sum_Field_Val, ',', '.')),
                            P_Nbi_Doc_Num_Field_Val,
                            tools.getcurrorg,
                            NULL,
                            --CASE WHEN P_Nbi_In_Field_Val = l_val THEN 'IN' ELSE 'OUT' END,
                            CASE
                                WHEN l_res_tp IN ('PH', 'PPH') THEN 'IN'
                                ELSE 'OUT'
                            END,
                            CASE
                                WHEN P_Nbi_Is_Diff_Payer = 'T'
                                THEN
                                    CASE
                                        WHEN P_Nbi_In_Field_Val = l_val
                                        THEN
                                            P_Nbi_Payer_Bnk_Acc_Field_Val
                                        ELSE
                                            P_Nbi_Account_Field_Val
                                    END
                                ELSE
                                    P_Nbi_Payer_Bnk_Acc_Field_Val
                            END,
                            CASE
                                WHEN P_Nbi_Is_Diff_Payer = 'T'
                                THEN
                                    CASE
                                        WHEN P_Nbi_In_Field_Val = l_val
                                        THEN
                                            P_Nbi_Account_Field_Val
                                        ELSE
                                            P_Nbi_Payer_Bnk_Acc_Field_Val
                                    END
                                ELSE
                                    P_Nbi_Account_Field_Val
                            END,
                            CASE
                                WHEN P_Nbi_Is_Diff_Payer = 'T'
                                THEN
                                    CASE
                                        WHEN P_Nbi_In_Field_Val = l_val
                                        THEN
                                            P_Nbi_Payer_Bnk_Mfo_Field_Val
                                        ELSE
                                            P_Nbi_Receip_Bnk_Mfo_Field_Val
                                    END
                                ELSE
                                    P_Nbi_Payer_Bnk_Mfo_Field_Val
                            END,
                            CASE
                                WHEN P_Nbi_Is_Diff_Payer = 'T'
                                THEN
                                    CASE
                                        WHEN P_Nbi_In_Field_Val = l_val
                                        THEN
                                            P_Nbi_Receip_Bnk_Mfo_Field_Val
                                        ELSE
                                            P_Nbi_Payer_Bnk_Mfo_Field_Val
                                    END
                                ELSE
                                    P_Nbi_Receip_Bnk_Mfo_Field_Val
                            END,
                            CASE
                                WHEN P_Nbi_Is_Diff_Payer = 'T'
                                THEN
                                    CASE
                                        WHEN P_Nbi_In_Field_Val = l_val
                                        THEN
                                            P_Nbi_Payer_Edrpou_Field_Val
                                        ELSE
                                            P_Nbi_Receip_Edrpou_Field_Val
                                    END
                                ELSE
                                    P_Nbi_Payer_Edrpou_Field_Val
                            END,
                            CASE
                                WHEN P_Nbi_Is_Diff_Payer = 'T'
                                THEN
                                    CASE
                                        WHEN P_Nbi_In_Field_Val = l_val
                                        THEN
                                            P_Nbi_Receip_Edrpou_Field_Val
                                        ELSE
                                            P_Nbi_Payer_Edrpou_Field_Val
                                    END
                                ELSE
                                    P_Nbi_Receip_Edrpou_Field_Val
                            END,
                            CASE
                                WHEN P_Nbi_Is_Diff_Payer = 'T'
                                THEN
                                    CASE
                                        WHEN P_Nbi_In_Field_Val = l_val
                                        THEN
                                            P_Nbi_Payer_Name_Field_Val
                                        ELSE
                                            P_Nbi_Receip_Name_Field_Val
                                    END
                                ELSE
                                    P_Nbi_Payer_Name_Field_Val
                            END,
                            CASE
                                WHEN P_Nbi_Is_Diff_Payer = 'T'
                                THEN
                                    CASE
                                        WHEN P_Nbi_In_Field_Val = l_val
                                        THEN
                                            P_Nbi_Receip_Name_Field_Val
                                        ELSE
                                            P_Nbi_Payer_Name_Field_Val
                                    END
                                ELSE
                                    P_Nbi_Receip_Name_Field_Val
                            END,
                            CASE
                                WHEN P_Nbi_Is_Diff_Payer = 'T'
                                THEN
                                    CASE
                                        WHEN P_Nbi_In_Field_Val = l_val
                                        THEN
                                            P_Nbi_Payer_Bnk_Name_Field_Val
                                        ELSE
                                            P_Nbi_Receip_Bnk_Name_Field_Val
                                    END
                                ELSE
                                    P_Nbi_Payer_Bnk_Name_Field_Val
                            END,
                            CASE
                                WHEN P_Nbi_Is_Diff_Payer = 'T'
                                THEN
                                    CASE
                                        WHEN P_Nbi_In_Field_Val = l_val
                                        THEN
                                            P_Nbi_Receip_Bnk_Name_Field_Val
                                        ELSE
                                            P_Nbi_Payer_Bnk_Name_Field_Val
                                    END
                                ELSE
                                    P_Nbi_Receip_Bnk_Name_Field_Val
                            END,
                            'APPR', --CASE WHEN P_Nbi_In_Field_Val = l_val THEN 'U' ELSE 'APPR' END,
                            P_Nbi_Purpose_Field_Val,
                            l_res_tp,
                            l_dppa_id);
    END;


    -------------------------------------------------------------------------
    --------------------------- RETURN PAY ORDER  ---------------------------
    -------------------------------------------------------------------------


    -- #73055 - Журнал ПД повернення
    PROCEDURE GET_RETURN_PAY_ORDER_JOURNAL (
        P_PO_DT_START       IN     DATE,
        P_PO_DT_STOP        IN     DATE,
        P_PO_PAY_DT_START   IN     DATE,
        P_PO_PAY_DT_STOP    IN     DATE,
        P_PO_NUMBER         IN     VARCHAR2,
        P_PO_ST             IN     VARCHAR2,
        P_NB_ID             IN     NUMBER,
        P_PO_SRC            IN     VARCHAR2,
        RES_CUR                OUT SYS_REFCURSOR)
    IS
        l_org   NUMBER := tools.getcurrorg;
        l_sql   VARCHAR2 (10000)
            :=    'SELECT t.*,
                                     st.dic_sname as po_st_name,
                                     null as po_bank_ppc_name
                                FROM pay_order t
                                JOIN uss_ndi.v_ddn_po_st st ON (st.dic_value = t.po_st)
                                --left join ikis_finzvit.v_rv2pda_prc_codes pc on (pc.ppc_id = t.po_bank_ppc)
                               WHERE 1 = 1
                                 and (t.po_dppa_payer is not null or t.po_dppa_recipient is not null)
                                 and t.com_org_src = '
               || l_org
               || '
                                 and t.po_src = '''
               || P_PO_SRC
               || '''
                                 and t.po_circ_tp = ''PPH''
                                 ';
        --                                 and t.po_St = ''APPR''
        l_mfo   VARCHAR2 (10);
    BEGIN
        TOOLS.validate_param (P_PO_NUMBER);
        TOOLS.validate_param (P_PO_ST);

        --TOOLS.validate_param(P_PO_SRC); -- IN/OUT

        IF (P_PO_DT_START IS NOT NULL)
        THEN
            l_sql :=
                   l_sql
                || ' and trunc(po_create_dt)  >= to_date('''
                || TO_CHAR (P_PO_DT_START, 'DD.MM.YYYY')
                || ''', ''DD.MM.YYYY'')';
        END IF;

        IF (P_PO_DT_STOP IS NOT NULL)
        THEN
            l_sql :=
                   l_sql
                || ' and trunc(po_create_dt) <= to_date('''
                || TO_CHAR (P_PO_DT_STOP, 'DD.MM.YYYY')
                || ''', ''DD.MM.YYYY'')';
        END IF;

        IF (P_PO_PAY_DT_START IS NOT NULL)
        THEN
            l_sql :=
                   l_sql
                || ' and po_pay_dt  >= to_date('''
                || TO_CHAR (P_PO_PAY_DT_START, 'DD.MM.YYYY')
                || ''', ''DD.MM.YYYY'')';
        END IF;

        IF (P_PO_PAY_DT_STOP IS NOT NULL)
        THEN
            l_sql :=
                   l_sql
                || ' and po_pay_dt <= to_date('''
                || TO_CHAR (P_PO_PAY_DT_STOP, 'DD.MM.YYYY')
                || ''', ''DD.MM.YYYY'')';
        END IF;

        IF (P_PO_NUMBER IS NOT NULL)
        THEN
            l_sql := l_sql || ' and po_number = ''' || P_PO_NUMBER || '''';
        END IF;

        IF (P_PO_ST IS NOT NULL)
        THEN
            l_sql := l_sql || ' and po_st = ''' || P_PO_ST || '''';
        END IF;

        IF (P_NB_ID IS NOT NULL)
        THEN
            SELECT t.nb_mfo
              INTO l_mfo
              FROM uss_ndi.v_ndi_bank t
             WHERE t.nb_id = P_NB_ID;

            --       raise_application_error(-20000, l_mfo);
            l_sql := l_sql || ' and po_bank_mfo_dest = ''' || l_mfo || '''';
        END IF;

        --raise_application_error(-20000, l_sql);
        OPEN res_cur FOR l_sql || ' ORDER by po_pay_dt desc';
    END;

    -- #73055 - запит на видачу даних для картки ПД повернення
    PROCEDURE GET_RETURN_PAY_ORDER_CARD (P_PO_ID   IN     NUMBER,
                                         PO_CUR       OUT SYS_REFCURSOR,
                                         RRL_CUR      OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN PO_CUR FOR
            SELECT t.*,
                   (SELECT SUM (z.rrl_sum_return)
                      FROM rr_list z
                     WHERE z.rrl_po = t.po_id)                      AS rr_sum_total,
                   (SELECT SUM (za.acd_sum)
                      FROM rr_list  z
                           JOIN ac_detail za ON (za.acd_rrl = z.rrl_id)
                     WHERE z.rrl_po = t.po_id AND za.acd_op = 8)    AS acd_sum
              FROM pay_order t
             WHERE t.PO_ID = P_PO_ID;

        OPEN RRL_CUR FOR
            SELECT t.*,
                   s.dic_sname      AS rrl_src_name,
                   st.dic_sname     AS rrl_st_name                         --,
              --r.rr_tp,
              --tp.sv_sname AS rr_tp_name
              FROM rr_list  t
                   --JOIN returns_reestr r ON (r.rr_id = t.rrl_rr)
                   --JOIN ST_RR_TP tp ON (tp.sv_id = r.rr_tp)
                   JOIN uss_ndi.v_ddn_rrl_st st ON (st.dic_value = t.rrl_st)
                   LEFT JOIN uss_ndi.v_ddn_rec_src s
                       ON (s.dic_value = t.rrl_src)
             WHERE t.rrl_po = p_po_id;
    END;


    -- #73055 - видає список невикористаних записів returns_reestr для звязки з ПД
    PROCEDURE GET_UNSELECT_RETURN_REESTR (p_po_id   IN     NUMBER,
                                          res_cur      OUT SYS_REFCURSOR)
    IS
        l_row   pay_order%ROWTYPE;
        l_org   NUMBER := tools.getcurrorg;
    BEGIN
        SELECT *
          INTO l_row
          FROM pay_order t
         WHERE t.po_id = p_po_id;

        OPEN res_cur FOR
            SELECT t.*, s.DIC_SNAME AS rrl_st_name
              FROM rr_list  t
                   JOIN uss_ndi.v_ddn_rrl_st s ON (s.DIC_VALUE = t.rrl_st)
                   LEFT JOIN uss_ndi.v_ndi_bank b ON (b.nb_id = t.rrl_nb_ab)
             WHERE     t.rrl_po IS NULL
                   AND t.rrl_sum_return > 0
                   AND (   l_org = 28000
                        OR     t.rrl_org IS NULL
                           AND b.nb_mfo = l_row.po_bank_mfo_dest
                        OR t.rrl_org = l_org
                        OR t.rrl_org IN (SELECT org_id
                                           FROM v_opfu z
                                          WHERE z.org_org = l_org))
                   AND TRUNC (t.rrl_create_dt) BETWEEN l_row.po_pay_dt - 7
                                                   AND l_row.po_pay_dt + 7;
    END;

    -- #73055 - привязати реєстр до ПД повернення
    PROCEDURE LINK_RR_TO_PD (p_po_id IN NUMBER, p_ids IN VARCHAR2)
    IS
        l_sum   NUMBER;
        l_org   NUMBER := tools.GetCurrOrg;
        l_row   pay_order%ROWTYPE;
    BEGIN
        SELECT t.*
          INTO l_row
          FROM pay_order t
         WHERE t.po_id = p_po_id;

        UPDATE rr_list t
           SET rrl_st = 'F',
               rrl_po = p_po_id,
               rrl_pd_num = l_row.po_number,
               rrl_pd_date = l_row.po_pay_dt,
               t.rrl_src = 'H'
         WHERE rrl_id IN (    SELECT REGEXP_SUBSTR (text,
                                                    '[^(\,)]+',
                                                    1,
                                                    LEVEL)    AS z_rdt_id
                                FROM (SELECT p_ids AS text FROM DUAL)
                          CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                            '[^(\,)]+',
                                                            1,
                                                            LEVEL)) > 0);

        UPDATE Returns_Reestr t
           SET t.rr_po = p_po_id,
               t.rr_org = l_org,
               t.rr_st = 'F',
               t.rr_src = NVL (t.rr_src, 'H')
         WHERE     t.rr_po IS NULL
               AND NOT EXISTS
                       (SELECT *
                          FROM rr_list z
                         WHERE z.rrl_rr = t.rr_id AND z.rrl_po != p_po_id)
               AND t.rr_id IN
                       (SELECT rrl_rr
                          FROM rr_list z
                         WHERE z.rrl_id IN
                                   (    SELECT REGEXP_SUBSTR (
                                                   text,
                                                   '[^(\,)]+',
                                                   1,
                                                   LEVEL)    AS z_rdt_id
                                          FROM (SELECT p_ids AS text FROM DUAL)
                                    CONNECT BY LENGTH (
                                                   REGEXP_SUBSTR (text,
                                                                  '[^(\,)]+',
                                                                  1,
                                                                  LEVEL)) >
                                               0));

        SELECT   t.po_sum
               - NVL ( (SELECT SUM (z.rrl_sum_return)
                          FROM rr_list z
                         WHERE z.rrl_po = t.po_id),
                      0)
          INTO l_sum
          FROM pay_order t
         WHERE t.po_id = p_po_id;

        IF (l_sum < 0)
        THEN
            raise_application_error (-20000, 'Недостатньо суми ПД!');
        END IF;
    END;

    -- #73055 - обробка реэстрів повернень
    PROCEDURE SEND_TO_PROCESS (p_ids IN VARCHAR2)
    IS
        l_flag   NUMBER := 0;
    BEGIN
        FOR xx
            IN (SELECT DISTINCT t.rr_id
                  FROM returns_reestr t
                 WHERE t.rr_po IN
                           (    SELECT REGEXP_SUBSTR (text,
                                                      '[^(\,)]+',
                                                      1,
                                                      LEVEL)    AS z_rdt_id
                                  FROM (SELECT p_ids AS text FROM DUAL)
                            CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                              '[^(\,)]+',
                                                              1,
                                                              LEVEL)) > 0))
        LOOP
            API$ESR_EXCHANGE.GetRrlPnfPpvp (xx.rr_id);
        END LOOP;
    END;


    -- #73055 - зняти привязку реєстра до ПД повернення
    PROCEDURE RELEASE_REESTR (p_rrl_id IN NUMBER)
    IS
        l_row       rr_list%ROWTYPE;
        l_org_org   NUMBER;
        l_org       NUMBER := tools.getcurrorg;
    BEGIN
        SELECT *
          INTO l_row
          FROM rr_list
         WHERE rrl_id = p_rrl_id;

        SELECT t.org_org
          INTO l_org_org
          FROM v_opfu t
         WHERE t.org_id = l_row.rrl_org;

        IF (l_row.rrl_po IS NULL)
        THEN
            raise_application_error (-20000,
                                     'Повернення не прив`язане до ПД!');
        END IF;

        IF (    l_row.rrl_org IS NOT NULL
            AND l_row.rrl_org != l_org
            AND l_org_org != l_org
            AND l_org != 28000)
        THEN
            raise_application_error (
                -20000,
                'Зняття прив`язки повернення не свого ОПФУ заборонено!');
        END IF;

        IF (l_row.rrl_st = 'P')
        THEN
            raise_application_error (
                -20000,
                'Не можна зняти прив`язку, оскільки повернення ідентифіковано підсистемою ІКІС');
        END IF;

        UPDATE rr_list
           SET rrl_pd_num = NULL,
               rrl_pd_date = NULL,
               rrl_po = NULL,
               rrl_st = 'L'
         WHERE rrl_id = p_rrl_id;

        UPDATE Returns_Reestr t
           SET rr_st = 'L',
               rr_pd_num = NULL,                                -- oi 20211022
               rr_pd_date = NULL,
               rr_po = NULL
         WHERE     t.rr_id = l_row.rrl_rr
               AND NOT EXISTS
                       (SELECT *
                          FROM rr_list z
                         WHERE z.rrl_rr = t.rr_id AND z.rrl_st != 'L');
    END;

    -- #73055 - видалити реєстр, створений вручну
    PROCEDURE DELETE_REESTR (p_rr_id IN NUMBER)
    IS
        l_row   returns_reestr%ROWTYPE;
        l_cnt   NUMBER;
        l_org   NUMBER := tools.getcurrorg;
    BEGIN
        SELECT *
          INTO l_row
          FROM returns_reestr
         WHERE rr_id = p_rr_id;

        IF (l_row.rr_src = 'A')
        THEN
            raise_application_error (
                -20000,
                'Видалення реєстру, який створений системою автоматично, заборонено!');
        END IF;

        IF (l_row.rr_st = 'P')
        THEN
            raise_application_error (
                -20000,
                'Видалення обробленого реєстру заборонено!');
        END IF;

        IF (l_row.rr_org IS NOT NULL AND l_row.rr_org != l_org)
        THEN
            raise_application_error (
                -20000,
                'Видалення реєстру не свого ОПФУ заборонено!');
        END IF;

        /* SELECT COUNT(*)
           INTO l_cnt
           FROM rr_list t
          WHERE t.rrl_rr = p_rr_id
            AND (t.rrl_pnf_ppvp IS NOT NULL OR t.rrl_pnf_dkg IS NOT NULL);

         IF (l_cnt > 0) THEN
           raise_application_error(-20000, 'Видалення реєстру, повернення якого використовуються в ППВП/ДКГ, заборонено!');
         END IF;*/

        DELETE FROM rr_list
              WHERE rrl_rr = p_rr_id;

        DELETE FROM Returns_Reestr
              WHERE rr_id = p_rr_id;
    END;

    -- #73055 - Зняти прив'язку до ОР
    --  #69965 відкат прив'язки повернення
    -- ikis_ppvp.DeleteReturnExternal вхідний параметр - rrl_id  Метод може повернути наступні помилки:
    --   "ППВП.Запис відсутній" - ід відсутній в ППВП
    --   "ППВП.Видаліть рознесення, перш ніж видаляти ПД повернення" - перед використанням методу необхідно видалити рознесені проводки в ППВП по цьому ПД.
    --   "ППВП.Неможливо видалити, вже зафіксовано рознесення по ПД"
    --  в ФС за відсутності помилок виклику ikis_ppvp.DeleteReturnExternal змінюємо статус на попередній (Знайдено ПД)
    --  та очищаємо ід ПС ППВП та № ОР (com_org не чистимо!). Відповідно, якщо статус реєстру "Оброблено" то змінюємо на "Знайдено ПД".
    PROCEDURE DELETE_REESTR_PNF (p_rrl_id IN uss_esr.rr_list.rrl_id%TYPE)
    IS
        l_row            pay_order%ROWTYPE;
        l_hs             NUMBER;
        --l_org NUMBER := sys_context(ikis_finzvit_context.gContext, ikis_finzvit_context.gOPFU);
        --l_wu NUMBER := sys_context(ikis_finzvit_context.gContext, ikis_finzvit_context.gUID);
        l_ppvp_message   VARCHAR2 (4000);
    BEGIN
        NULL;

        /*  ikis_ppvp.DeleteReturnExternal(p_rrl_id => p_rrl_id);*/

        UPDATE rr_list rrl
           SET --rrl.rrl_num_or = null,
               --rrl.rrl_pnf_ppvp = null,
               rrl.rrl_st =
                   CASE WHEN rrl.rrl_st = 'P' THEN 'F' ELSE rrl.rrl_st END
         WHERE rrl.rrl_id = p_rrl_id;

        UPDATE returns_reestr r
           SET r.rr_st = 'F'
         WHERE     r.rr_st = 'P'
               AND EXISTS
                       (SELECT 1
                          FROM rr_list rrl
                         WHERE     rrl_rr = rr_id
                               AND rrl_st = 'F'
                               AND rrl_id = p_rrl_id);
    END;


    -- #73055 - створення реєстру повернення
    PROCEDURE CREATE_REESTR (P_PO_ID         IN     NUMBER,
                             P_RR_PD_LINES   IN     NUMBER,
                             P_RR_PD_SUM     IN     NUMBER,
                             P_RR_ID            OUT NUMBER)
    IS
        l_row   pay_order%ROWTYPE;
        l_sum   NUMBER;
        l_nb    NUMBER;
        l_org   NUMBER := tools.getcurrorg;
    BEGIN
        IF (P_RR_PD_SUM IS NULL OR P_RR_PD_SUM = 0)
        THEN
            raise_application_error (-20000,
                                     'Неможливо створити реєстр з 0.');
        END IF;

        SELECT *
          INTO l_row
          FROM pay_order t
         WHERE t.po_id = p_po_id;

        SELECT l_row.po_sum - NVL (SUM (t.rrl_sum_return), 0) - P_RR_PD_SUM
          INTO l_sum
          FROM rr_list t
         WHERE t.rrl_po = p_po_id;

        SELECT MAX (t.nb_id)
          INTO l_nb
          FROM uss_ndi.v_ndi_bank t
         WHERE t.nb_mfo = l_row.po_bank_mfo_src;

        IF (l_sum < 0)
        THEN
            raise_application_error (
                -20000,
                'Сума реєстру перевищує залишок суми ПД!');
        END IF;

        INSERT INTO returns_reestr (rr_tp,
                                    rr_pd_num,
                                    rr_pd_date,
                                    rr_pd_sum,
                                    rr_pd_lines,
                                    rr_po,
                                    rr_st,
                                    rr_nb_ab,
                                    rr_id_rbm,
                                    rr_create_dt,
                                    rr_org,
                                    rr_src)
             VALUES ('R',
                     l_row.po_number,
                     l_row.po_pay_dt,
                     p_rr_pd_sum,
                     p_rr_pd_lines,
                     p_po_id,
                     'F',
                     l_nb,
                     NULL,
                     SYSDATE,
                     l_org,
                     'H')
          RETURNING rr_id
               INTO p_rr_id;
    END;

    -- #73055 - створення повернення
    PROCEDURE CREATE_REESTR_DETAIL (
        p_rrl_rr           IN uss_esr.rr_list.rrl_rr%TYPE,
        p_rrl_num          IN uss_esr.rr_list.rrl_num%TYPE,
        p_rrl_ln           IN uss_esr.rr_list.rrl_ln%TYPE,
        p_rrl_fn           IN uss_esr.rr_list.rrl_fn%TYPE,
        p_rrl_mn           IN uss_esr.rr_list.rrl_mn%TYPE,
        p_rrl_numident     IN uss_esr.rr_list.rrl_numident%TYPE,
        p_rrl_ser_num      IN uss_esr.rr_list.rrl_ser_num%TYPE,
        p_rrl_num_acc      IN uss_esr.rr_list.rrl_num_acc%TYPE,
        p_rrl_sum_return   IN uss_esr.rr_list.rrl_sum_return%TYPE,
        p_rrl_rsn_return   IN uss_esr.rr_list.rrl_rsn_return%TYPE,
        p_rrl_org          IN uss_esr.rr_list.rrl_org%TYPE,
        p_rrl_num_or       IN uss_esr.rr_list.rrl_num_or%TYPE)
    IS
        l_row   pay_order%ROWTYPE;
        l_nb    NUMBER;
        l_hs    NUMBER;
        l_org   NUMBER := tools.getcurrorg;
        l_wu    NUMBER := tools.GetCurrWu;
    BEGIN
        IF (p_rrl_sum_return IS NULL OR p_rrl_sum_return = 0)
        THEN
            raise_application_error (-20000,
                                     'Неможливо створити реєстр з 0.');
        END IF;

        SELECT t.*
          INTO l_row
          FROM pay_order t JOIN returns_reestr r ON (r.rr_po = t.po_id)
         WHERE r.rr_id = p_rrl_rr;

        SELECT MAX (t.nb_id)
          INTO l_nb
          FROM uss_ndi.v_ndi_bank t
         WHERE t.nb_mfo = l_row.po_bank_mfo_dest;

        INSERT INTO histsession (hs_dt, hs_wu)
             VALUES (SYSDATE, l_wu)
          RETURNING hs_id
               INTO l_hs;

        INSERT INTO rr_list (rrl_rr,
                             rrl_num,
                             rrl_ln,
                             rrl_fn,
                             rrl_mn,
                             rrl_numident,
                             rrl_ser_num,
                             rrl_num_acc,
                             rrl_sum_return,
                             rrl_rsn_return,
                             rrl_po,
                             rrl_st,
                             rrl_create_dt,
                             rrl_pd_num,
                             rrl_pd_date,
                             rrl_nb_ab,
                             rrl_org,
                             rrl_hs_ins,
                             rrl_src,
                             rrl_num_or)
             VALUES (p_rrl_rr,
                     p_rrl_num,
                     p_rrl_ln,
                     p_rrl_fn,
                     p_rrl_mn,
                     p_rrl_numident,
                     p_rrl_ser_num,
                     p_rrl_num_acc,
                     p_rrl_sum_return,
                     p_rrl_rsn_return,
                     l_row.po_id,
                     'F',
                     SYSDATE,
                     l_row.po_number,
                     l_row.po_pay_dt,
                     l_nb,
                     p_rrl_org                                       /*l_org*/
                              ,
                     l_hs,
                     'H',
                     p_rrl_num_or);
    END;

    -- #73301 - редагування повернення
    PROCEDURE UPDATE_REESTR_DETAIL (
        p_rrl_id           IN uss_esr.rr_list.rrl_id%TYPE,
        p_rrl_num          IN uss_esr.rr_list.rrl_num%TYPE,
        p_rrl_ln           IN uss_esr.rr_list.rrl_ln%TYPE,
        p_rrl_fn           IN uss_esr.rr_list.rrl_fn%TYPE,
        p_rrl_mn           IN uss_esr.rr_list.rrl_mn%TYPE,
        p_rrl_numident     IN uss_esr.rr_list.rrl_numident%TYPE,
        p_rrl_ser_num      IN uss_esr.rr_list.rrl_ser_num%TYPE,
        p_rrl_num_acc      IN uss_esr.rr_list.rrl_num_acc%TYPE,
        p_rrl_sum_return   IN uss_esr.rr_list.rrl_sum_return%TYPE,
        p_rrl_rsn_return   IN uss_esr.rr_list.rrl_rsn_return%TYPE,
        p_rrl_org          IN uss_esr.rr_list.rrl_org%TYPE,
        p_rrl_num_or       IN uss_esr.rr_list.rrl_num_or%TYPE)
    IS
        l_sum   NUMBER;
    BEGIN
        IF (p_rrl_sum_return IS NULL OR p_rrl_sum_return = 0)
        THEN
            raise_application_error (-20000,
                                     'Неможливо створити реєстр з 0.');
        END IF;

        SELECT   NVL (MAX (p.po_sum), 0)
               - NVL (SUM (sl.rrl_sum_return), 0)
               - p_rrl_sum_return
          INTO l_sum
          FROM rr_list  t
               JOIN pay_order p ON (p.po_id = t.rrl_po)
               LEFT JOIN rr_list sl
                   ON (sl.rrl_po = p.po_id AND sl.rrl_id != t.rrl_id)
         WHERE t.rrl_id = p_rrl_id;

        IF (l_sum < 0)
        THEN
            raise_application_error (-20000,
                                     'Сума по реєстрам перевищила суму ПД!');
        END IF;

        UPDATE RR_LIST
           SET RRL_NUM = p_RRL_NUM,
               RRL_LN = p_RRL_LN,
               RRL_FN = p_RRL_FN,
               RRL_MN = p_RRL_MN,
               RRL_NUMIDENT = p_RRL_NUMIDENT,
               RRL_SER_NUM = p_RRL_SER_NUM,
               RRL_NUM_ACC = p_RRL_NUM_ACC,
               RRL_NUM_OR = p_RRL_NUM_OR,
               RRL_SUM_RETURN = p_RRL_SUM_RETURN,
               RRL_ORG = p_RRL_ORG,
               rrl_rsn_return = p_rrl_rsn_return
         WHERE RRL_ID = p_RRL_ID;
    END;

    -- #81594: неоплата АСОПД, журнал
    PROCEDURE get_notpay_list (p_org_id     IN     NUMBER,
                               p_dt_start   IN     DATE,
                               p_dt_stop    IN     DATE,
                               res_cur         OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT t.*,
                   (SELECT COUNT (*)
                      FROM rr_list z
                     WHERE     z.rrl_rr = t.rr_id
                           AND z.rrl_pc IS NOT NULL)    AS processed_cnt,
                   /*(SELECT z.org_id || ' ' || z.org_name FROM v_opfu z WHERE z.org_id = t.rr_org)*/
                   p.org_id || ' ' || p.org_name        AS rr_org_name
              FROM returns_reestr t JOIN v_opfu p ON (p.org_id = t.rr_org)
             /* LEFT JOIN v_opfu po ON (po.org_id = decode(l_org_to, 31, p.org_id, 32, p.org_id,
                   DECODE(p.org_to, 1, p.org_id, 2, p.org_id, NULL, p.org_id, p.org_org)) )*/
             WHERE     t.rr_tp = 'K'
                   AND t.rr_src = 'A'
                   AND (p.org_id = p_org_id OR p.org_acc_org = p_org_id)
                   AND t.rr_create_dt BETWEEN p_dt_start AND p_dt_stop;
    END;

    -- #81594: неоплата АСОПД, картка
    PROCEDURE get_notpay_card (p_rr_id   IN     NUMBER,
                               res_cur      OUT SYS_REFCURSOR,
                               det_cur      OUT SYS_REFCURSOR)
    IS
        l_org      NUMBER := tools.GetCurrOrg;
        l_org_To   NUMBER := tools.GetCurrOrgTo;
    BEGIN
        OPEN res_cur FOR
            SELECT t.*,
                   (SELECT COUNT (*)
                      FROM rr_list z
                     WHERE     z.rrl_rr = t.rr_id
                           AND z.rrl_pc IS NOT NULL)
                       AS processed_cnt,
                   (SELECT SUM (z.rrl_sum_return)
                      FROM rr_list z
                     WHERE z.rrl_rr = t.rr_id AND z.rrl_pc IS NOT NULL)
                       AS processed_sum,
                   p.org_id || ' ' || p.org_name
                       AS rr_org_name
              FROM returns_reestr t JOIN v_opfu p ON (p.org_id = t.rr_org)
             /* LEFT JOIN v_opfu po ON (po.org_id = decode(l_org_to, 31, p.org_id, 32, p.org_id,
                   DECODE(p.org_to, 1, p.org_id, 2, p.org_id, NULL, p.org_id, p.org_org)) )*/
             WHERE t.rr_id = p_rr_id;

        OPEN det_cur FOR
            SELECT t.*,
                   t.rrl_ln || ' ' || t.rrl_fn || ' ' || t.rrl_mn
                       AS rrl_pib,
                   p.org_id || ' ' || p.org_name
                       AS rrl_org_name,
                   c.pc_num
                       AS rrl_pc_name,
                   CASE
                       WHEN     (       p.org_acc_org = l_org
                                    AND l_org_to IN (                 /*32, */
                                                     34)
                                 OR l_org_to IN (32))
                            AND t.rrl_pc IS NULL
                       THEN
                           1
                       ELSE
                           0
                   END
                       AS can_process
              FROM rr_list  t
                   JOIN v_opfu p ON (p.org_id = t.rrl_org)
                   LEFT JOIN personalcase c ON (c.pc_id = t.rrl_pc)
             WHERE t.rrl_rr = p_rr_id;
    END;

    -- #81594: неоплата АСОПД, дані для опрацювання
    -- mode: 0 - по всіх параметрах пошук
    --       1 - по ПІБ + РНОКПП
    --       2 - по ПІБ + ІБАН
    --       3 - по РНОКПП + ІБАН
    PROCEDURE get_process_data (p_rrl_id   IN     NUMBER,
                                p_mode     IN     NUMBER,
                                res_cur       OUT SYS_REFCURSOR)
    IS
        l_pc   NUMBER;
        l_dt   DATE;
    BEGIN
        SELECT MAX (t.rrl_pd_date), MAX (c.pc_id)
          INTO l_dt, l_pc
          FROM rr_list  t
               JOIN personalcase c ON (1 = 1)
               JOIN uss_person.v_sc_info i ON (i.sco_id = c.pc_sc)
         WHERE     t.rrl_id = p_rrl_id
               AND (p_mode IN (2) OR i.sco_numident = t.rrl_numident)
               AND (p_mode IN (3) OR UPPER (t.rrl_ln) = UPPER (i.sco_ln))
               AND (p_mode IN (3) OR UPPER (t.rrl_fn) = UPPER (i.sco_fn))
               AND (   p_mode IN (3)
                    OR UPPER (COALESCE (t.rrl_mn, '')) =
                       UPPER (COALESCE (i.sco_mn, '')))
               --AND iban =

               AND (   p_mode IN (1)
                    OR EXISTS
                           (SELECT *
                              FROM pc_decision  zd
                                   JOIN pd_pay_method pm
                                       ON (pm.pdm_pd = zd.pd_id)
                             WHERE     zd.pd_pc = c.pc_id
                                   AND pm.pdm_account = t.rrl_num_acc));

        IF (l_pc IS NULL)
        THEN
            raise_application_error (-20000, 'Не знайдено ЕОС!');
        END IF;

        OPEN res_cur FOR
            SELECT acd_id                                 AS x_id,
                   ac_month                               AS x_narah_period,
                   acd_start_dt                           AS x_acc_period,
                   acd_imp_pr_num                         AS x_pr_num,
                   uss_esr.api$accrual.xsign (acd_op)     AS x_sign,
                   acd_sum                                AS x_sum,
                   op.op_code || ' ' || op.op_name        AS x_op
              FROM uss_esr.accrual, uss_esr.ac_detail z, uss_ndi.v_ndi_op op
             WHERE     ac_pc = l_pc
                   AND ac_month <= l_dt
                   AND acd_ac = ac_id
                   AND z.acd_imp_pr_num IS NOT NULL
                   AND z.history_status = 'A'
                   AND z.acd_op = op.op_id;
    END;

    -- #81594: неоплата АСОПД, опрацювання вибраних нарахувань
    PROCEDURE PROCESS_RRL (p_rrl_id IN NUMBER, p_list IN VARCHAR2)
    IS
        l_dt   DATE;
        l_pc   NUMBER;
    BEGIN
        SELECT MAX (a.ac_pc)
          INTO l_pc
          FROM ac_detail t JOIN accrual a ON (a.ac_id = t.acd_ac)
         WHERE t.acd_id IN (    SELECT REGEXP_SUBSTR (text,
                                                      '[^(\,)]+',
                                                      1,
                                                      LEVEL)    AS id
                                  FROM (SELECT p_list AS text FROM DUAL)
                            CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                              '[^(\,)]+',
                                                              1,
                                                              LEVEL)) = 0);

        DELETE FROM TMP_ACD_BLOCK;

        INSERT INTO TMP_ACD_BLOCK (x_acd, x_block_tp, x_dt)
            SELECT d.id,
                   200 + TO_NUMBER (COALESCE (t.rrl_rsn_return, '0')),
                   t.rrl_pd_date
              FROM rr_list  t
                   JOIN (    SELECT REGEXP_SUBSTR (text,
                                                   '[^(\,)]+',
                                                   1,
                                                   LEVEL)    AS id
                               FROM (SELECT p_list AS text FROM DUAL)
                         CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                           '[^(\,)]+',
                                                           1,
                                                           LEVEL)) > 0) d
                       ON (1 = 1)
             WHERE t.rrl_id = p_rrl_id;

        API$PAYROLL.kv2_asopd_pay (2);

        UPDATE rr_list t
           SET t.rrl_pc = l_pc
         WHERE t.rrl_id = p_rrl_id;
    END;

    ----------------------------------------------------------------------------------------
    ----------------- #86318: Ручне введення "Платіжне доручення повернення коштів" --------

    PROCEDURE create_return_pd (
        p_po_number              IN     pay_order.po_number%TYPE,
        p_PO_PAY_DT              IN     pay_order.po_pay_dt%TYPE,
        p_po_sum                 IN     pay_order.po_sum%TYPE,
        p_po_purpose             IN     pay_order.po_purpose%TYPE,
        --P_PO_DPPA_PAYER        IN pay_order.po_dppa_payer%TYPE,
        p_PO_BANK_ACCOUNT_SRC    IN     pay_order.PO_BANK_ACCOUNT_SRC%TYPE,
        p_PO_BANK_MFO_SRC        IN     pay_order.PO_BANK_MFO_SRC%TYPE,
        p_PO_TAX_CODE_SRC        IN     pay_order.PO_TAX_CODE_SRC%TYPE,
        p_PO_NAME_SRC            IN     pay_order.PO_NAME_SRC%TYPE,
        p_PO_BANK_NAME_SRC       IN     pay_order.PO_BANK_NAME_SRC%TYPE,
        P_PO_DPPA_RECIPIENT      IN     pay_order.po_dppa_recipient%TYPE,
        p_PO_BANK_ACCOUNT_DEST   IN     pay_order.PO_BANK_ACCOUNT_DEST%TYPE,
        p_PO_BANK_MFO_DEST       IN     pay_order.PO_BANK_MFO_DEST%TYPE,
        p_PO_TAX_CODE_DEST       IN     pay_order.PO_TAX_CODE_DEST%TYPE,
        p_PO_NAME_DEST           IN     pay_order.PO_NAME_DEST%TYPE,
        p_PO_BANK_NAME_DEST      IN     pay_order.PO_BANK_NAME_DEST%TYPE,
        p_new_id                    OUT pay_order.po_id%TYPE)
    IS
        l_org   NUMBER := tools.GetCurrOrg;
    BEGIN
        INSERT INTO pay_order (po_create_dt,
                               po_pay_dt,
                               po_number,
                               po_sum,
                               com_org_src,
                               po_bank_account_src,
                               po_bank_account_dest,
                               po_bank_mfo_src,
                               po_bank_mfo_dest,
                               po_tax_code_src,
                               po_tax_code_dest,
                               po_name_src,
                               po_name_dest,
                               po_bank_name_src,
                               po_bank_name_dest,
                               po_src,
                               po_st,
                               po_purpose,
                               po_dppa_payer,
                               po_dppa_recipient,
                               po_circ_tp,
                               po_num)
             VALUES (SYSDATE,
                     p_po_pay_dt,
                     p_po_number,
                     p_po_sum,
                     l_org,
                     p_po_bank_account_src,
                     p_po_bank_account_dest,
                     p_po_bank_mfo_src,
                     p_po_bank_mfo_dest,
                     p_po_tax_code_src,
                     p_po_tax_code_dest,
                     p_po_name_src,
                     p_po_name_dest,
                     p_po_bank_name_src,
                     p_po_bank_name_dest,
                     'IN',
                     'E',
                     p_po_purpose,
                     NULL,                                  --P_PO_DPPA_PAYER,
                     P_PO_DPPA_RECIPIENT,
                     'PPH',
                     NULL)
          RETURNING po_id
               INTO p_new_id;
    END;

    PROCEDURE update_return_pd (
        p_po_id                  IN pay_order.po_id%TYPE,
        p_po_number              IN pay_order.po_number%TYPE,
        p_PO_PAY_DT              IN pay_order.po_pay_dt%TYPE,
        p_po_sum                 IN pay_order.po_sum%TYPE,
        p_po_purpose             IN pay_order.po_purpose%TYPE,
        --P_PO_DPPA_PAYER        IN pay_order.po_dppa_payer%TYPE,
        p_PO_BANK_ACCOUNT_SRC    IN pay_order.PO_BANK_ACCOUNT_SRC%TYPE,
        p_PO_BANK_MFO_SRC        IN pay_order.PO_BANK_MFO_SRC%TYPE,
        p_PO_TAX_CODE_SRC        IN pay_order.PO_TAX_CODE_SRC%TYPE,
        p_PO_NAME_SRC            IN pay_order.PO_NAME_SRC%TYPE,
        p_PO_BANK_NAME_SRC       IN pay_order.PO_BANK_NAME_SRC%TYPE,
        P_PO_DPPA_RECIPIENT      IN pay_order.po_dppa_recipient%TYPE,
        p_PO_BANK_ACCOUNT_DEST   IN pay_order.PO_BANK_ACCOUNT_DEST%TYPE,
        p_PO_BANK_MFO_DEST       IN pay_order.PO_BANK_MFO_DEST%TYPE,
        p_PO_TAX_CODE_DEST       IN pay_order.PO_TAX_CODE_DEST%TYPE,
        p_PO_NAME_DEST           IN pay_order.PO_NAME_DEST%TYPE,
        p_PO_BANK_NAME_DEST      IN pay_order.PO_BANK_NAME_DEST%TYPE)
    IS
        l_org   NUMBER := tools.GetCurrOrg;
    BEGIN
        UPDATE pay_order
           SET po_pay_dt = p_po_pay_dt,
               po_number = p_po_number,
               po_sum = p_po_sum,
               po_bank_account_src = p_po_bank_account_src,
               po_bank_account_dest = p_po_bank_account_dest,
               po_bank_mfo_src = p_po_bank_mfo_src,
               po_bank_mfo_dest = p_po_bank_mfo_dest,
               po_tax_code_src = p_po_tax_code_src,
               po_tax_code_dest = p_po_tax_code_dest,
               po_name_src = p_po_name_src,
               po_name_dest = p_po_name_dest,
               po_bank_name_src = p_po_bank_name_src,
               po_bank_name_dest = p_po_bank_name_dest,
               po_purpose = p_po_purpose,
               po_dppa_recipient = p_po_dppa_recipient
         WHERE po_id = p_po_id AND po_st = 'E';
    END;

    -- видалення
    PROCEDURE delete_return_po (p_po_id IN NUMBER)
    IS
        l_flag   NUMBER;
    BEGIN
        SELECT COUNT (*)
          INTO l_flag
          FROM pay_order t
         WHERE t.po_id = p_po_Id AND t.po_circ_tp = 'PPH' AND t.po_St = 'E';

        IF (l_flag = 0)
        THEN
            raise_application_error (-20000, 'Видалення ПІ неможливе!');
        END IF;

        UPDATE rr_list t
           SET t.rrl_po = NULL
         WHERE t.rrl_po = p_po_id;

        UPDATE Returns_Reestr t
           SET t.rr_po = NULL
         WHERE t.rr_po = p_po_id;

        DELETE pay_order t
         WHERE t.po_id = p_po_id;
    END;

    -- пошук ЕОС
    PROCEDURE search_pc (p_rrl_id       IN     NUMBER,
                         p_Found_Cnt       OUT INTEGER,
                         p_Show_Modal      OUT NUMBER,
                         RES_CUR           OUT SYS_REFCURSOR)
    IS
    BEGIN
        FOR xx IN (SELECT *
                     FROM rr_list t
                    WHERE t.rrl_id = p_rrl_id)
        LOOP
            uss_person.api$socialcard.Search_Pc_By_Params (xx.rrl_numident,
                                                           xx.rrl_ln,
                                                           xx.rrl_fn,
                                                           xx.rrl_mn,
                                                           p_found_cnt,
                                                           p_show_modal,
                                                           res_cur);
        END LOOP;
    END;

    -- прив"язка ЕОС до реєстру ПД
    PROCEDURE save_rrl_pc (p_rrl_id   IN NUMBER,
                           p_pc_id    IN NUMBER,
                           p_pc_num   IN VARCHAR2,
                           p_pc_ln    IN VARCHAR2,
                           p_pc_fn    IN VARCHAR2,
                           p_pc_mn    IN VARCHAR2)
    IS
    BEGIN
        UPDATE rr_list t
           SET t.rrl_pc = p_pc_id,
               t.rrl_num_or = p_pc_num,
               t.rrl_ln = p_pc_ln,
               t.rrl_fn = p_pc_fn,
               t.rrl_mn = p_pc_mn,
               t.rrl_Create_Dt = TRUNC (SYSDATE)
         WHERE t.rrl_id = p_rrl_id;
    END;

    -- список утримань для реєстру ПД
    PROCEDURE get_rrl_deduction_list (p_rrl_id   IN     NUMBER,
                                      RES_CUR       OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN res_cur FOR
            SELECT t.dn_id,
                      d.ndn_name
                   || ', №'
                   || t.dn_in_doc_num
                   || ' від '
                   || TO_CHAR (t.dn_in_doc_dt, 'DD.MM.YYYY')
                   || ' на суму '
                   || TO_CHAR (t.dn_debt_current,
                               'FM9G999G999G999G999G990D00',
                               'NLS_NUMERIC_CHARACTERS='',''''')
                   || ' грн.'         AS dn_name,
                   ad.acd_sum         AS dn_sum,
                   ad.acd_start_dt    AS month_period,
                   CASE ad.acd_op
                       WHEN 8 THEN 'SL'
                       WHEN 7 THEN 'RT'
                       ELSE 'SL'
                   END                AS sum_tp
              FROM deduction  t
                   JOIN uss_ndi.v_ndi_deduction d ON (d.ndn_id = t.dn_ndn)
                   JOIN rr_list rl ON (rl.rrl_pc = t.dn_pc)
                   LEFT JOIN ac_detail ad
                       ON (ad.acd_rrl = rl.rrl_id AND ad.acd_dn = t.dn_id)
             WHERE     1 = 1
                   AND dn_debt_current > 0
                   AND dn_st = 'R'
                   AND rl.rrl_id = p_rrl_id;
    END;

    -- обробка списку утримань по реєстру ПД
    PROCEDURE process_rrl_deduction_list (p_rrl_id IN NUMBER, p_xml IN CLOB)
    IS
        l_deductions   t_rpo_deduction := t_rpo_deduction ();
        l_po_id        NUMBER;
        l_cnt          NUMBER;
    BEGIN
        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''. ''');

        EXECUTE IMMEDIATE Type2xmltable (Package_Name,
                                         't_rpo_deduction',
                                         TRUE)
            BULK COLLECT INTO l_deductions
            USING p_xml;

        FOR xx
            IN (SELECT CASE WHEN t.dn_id > 0 THEN t.dn_id END     AS dn_id,
                       t.dn_sum,
                       t.month_period,
                       t.sum_tp
                  FROM TABLE (l_deductions) t)
        LOOP
            INSERT INTO tmp_work_set1 (x_id1,
                                       x_sum1,
                                       x_dt1,
                                       x_string1)
                 VALUES (xx.dn_id,
                         xx.dn_sum,
                         xx.month_period,
                         xx.sum_tp);
        END LOOP;


        api$deduction.process_rr_list (p_rrl_id);

        -- #108186
        UPDATE rr_list t
           SET t.rrl_st = 'P'
         WHERE t.rrl_id = p_rrl_id;

        SELECT t.rrl_po
          INTO l_po_id
          FROM rr_list t
         WHERE t.rrl_id = p_rrl_id;

        SELECT COUNT (*)
          INTO l_cnt
          FROM (  SELECT NVL (r.po_sum, 0)
                             AS po_sum,
                         NVL (SUM (l.rrl_sum_return), 0)
                             AS rrl_sum,
                         COUNT (CASE WHEN l.rrl_st = 'P' THEN 1 END)
                             AS cnt1,
                         COUNT (l.rrl_id)
                             AS cnt2
                    FROM pay_order r JOIN rr_list l ON (l.rrl_po = r.po_id)
                   WHERE r.po_id = l_po_id
                GROUP BY po_sum) t
         WHERE po_sum = rrl_sum AND cnt1 = cnt2;

        -- Якщо сума по ПІ та сума по реєстрам співпадає і всі списки у статусі "Оброблено", то змінювати статус ПІ на "Проведено".
        IF (l_cnt > 0)
        THEN
            UPDATE pay_order t
               SET t.po_st = 'APPR'
             WHERE t.po_id = l_po_id;
        END IF;
    END;


    ---------------------------------------------------------
    -------------------- відрахування -----------------------

    PROCEDURE GET_DDS_PAYMENT_ANAL_FORM (p_dt                 DATE,
                                         p_pe_dpp      IN     NUMBER,
                                         p_pe_dpp_Tp   IN     VARCHAR2,
                                         p_pe_tp       IN     VARCHAR2,
                                         p_pe_st       IN     VARCHAR2,
                                         p_pe_npc      IN     NUMBER,
                                         p_pe_nbg      IN     NUMBER,
                                         p_pe_src      IN     VARCHAR2,
                                         res_cur          OUT SYS_REFCURSOR)
    IS
        l_first_date   DATE := TRUNC (P_DT, 'MM');
        l_last_date    DATE := LAST_DAY (l_first_date);
        l_last_day     NUMBER := EXTRACT (DAY FROM l_last_date);
        l_org_to       NUMBER := tools.getcurrorgto;
        l_org_id       NUMBER := tools.getcurrorg;
        l_org_acc      NUMBER := tools.GetCurrOrgAcc;
    BEGIN
        tools.WriteMsg ('DNET$PAYMENT_ANALITIC.' || $$PLSQL_UNIT);

        OPEN RES_CUR FOR
            SELECT t.*
              FROM (  SELECT p.dpp_name,
                             p.dpp_id,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d01,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 1
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d02,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 2
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d03,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 3
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d04,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 4
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d05,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 5
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d06,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 6
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d07,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 7
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d08,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 8
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d09,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 9
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d10,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 10
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d11,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 11
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d12,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 12
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d13,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 13
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d14,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 14
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d15,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 15
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d16,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 16
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d17,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 17
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d18,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 18
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d19,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 19
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d20,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 20
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d21,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 21
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d22,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 22
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d23,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 23
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d24,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 24
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d25,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 25
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d26,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 26
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d27,
                             SUM (
                                 CASE
                                     WHEN t.pe_pay_dt = l_first_date + 27
                                     THEN
                                         t.pe_sum
                                 END)          AS sum_d28,
                             CASE
                                 WHEN l_last_day >= 29
                                 THEN
                                     SUM (
                                         CASE
                                             WHEN t.pe_pay_dt =
                                                  l_first_date + 28
                                             THEN
                                                 t.pe_sum
                                         END)
                             END               AS sum_d29,
                             CASE
                                 WHEN l_last_day >= 30
                                 THEN
                                     SUM (
                                         CASE
                                             WHEN t.pe_pay_dt =
                                                  l_first_date + 29
                                             THEN
                                                 t.pe_sum
                                         END)
                             END               AS sum_d30,
                             CASE
                                 WHEN l_last_day >= 31
                                 THEN
                                     SUM (
                                         CASE
                                             WHEN t.pe_pay_dt =
                                                  l_first_date + 30
                                             THEN
                                                 t.pe_sum
                                         END)
                             END               AS sum_d31,
                             SUM (t.pe_sum)    AS total_sum
                        FROM v_payroll_reestr t
                             JOIN uss_ndi.v_ndi_pay_person p
                                 ON (p.dpp_id = t.pe_dpp)
                       WHERE     t.pe_pay_dt BETWEEN l_first_date
                                                 AND l_last_date
                             AND t.pe_class = 'DDS'
                             AND p.dpp_tp IN ('STAL', 'COLL')
                             AND (p_pe_tp IS NULL OR t.pe_tp = p_pe_tp)
                             -----#81443
                             AND (   l_org_to = 30 AND t.pe_npc = 24
                                  OR     l_org_to != 30
                                     AND (t.pe_npc IS NULL OR t.pe_npc != 24))
                             AND (   p_pe_st IS NULL
                                  OR     p_pe_st = 'NEW'
                                     AND t.pe_st = p_pe_st
                                     AND t.pe_po IS NULL
                                  OR     p_pe_st = 'SELECTED'
                                     AND t.pe_po IS NOT NULL
                                     AND EXISTS
                                             (SELECT *
                                                FROM pay_order z
                                               WHERE     z.po_id = t.pe_po
                                                     AND z.po_st != 'APPR')
                                  OR     p_pe_st = 'PROVE'
                                     AND t.pe_po IS NOT NULL
                                     AND EXISTS
                                             (SELECT *
                                                FROM pay_order z
                                               WHERE     z.po_id = t.pe_po
                                                     AND z.po_st = 'APPR'))
                             AND (p_pe_nbg IS NULL OR t.pe_nbg = p_pe_nbg)
                             AND (p_pe_npc IS NULL OR t.pe_npc = p_pe_npc)
                             AND (p_pe_src IS NULL OR t.pe_src = p_pe_src)
                             AND (p_pe_dpp_Tp IS NULL OR p.dpp_tp = p_pe_dpp_Tp)
                             AND (p_pe_dpp IS NULL OR t.pe_dpp = p_pe_dpp)
                    GROUP BY p.dpp_name, p.dpp_id
                    ORDER BY p.dpp_name) t
             WHERE t.total_sum IS NOT NULL AND t.total_sum != 0;
    END;

    PROCEDURE GET_DDS_PAYROL_REESTR (p_dt                 DATE,
                                     p_pe_dpp      IN     NUMBER,
                                     p_pe_dpp_Tp   IN     VARCHAR2,
                                     p_pe_tp       IN     VARCHAR2,
                                     p_pe_st       IN     VARCHAR2,
                                     p_pe_npc      IN     NUMBER,
                                     p_pe_nbg      IN     NUMBER,
                                     p_pe_src      IN     VARCHAR2,
                                     P_WHERE       IN     VARCHAR2,
                                     RES_CUR          OUT SYS_REFCURSOR)
    IS
        l_org_to    NUMBER := tools.getcurrorgto;
        l_org_id    NUMBER := tools.getcurrorg;
        l_org_acc   NUMBER := tools.GetCurrOrgAcc;

        v_sql       VARCHAR2 (30000)
            :=    'SELECT t.pe_id,
                                     t.pe_src_entity,
                                     t.pe_rbm_pkt,
                                     t.pe_bnk_rbm_code,
                                     t.com_org,
                                     t.pe_tp,
                                     t.pe_code,
                                     t.pe_name,
                                     t.pe_pay_tp,
                                     ptp.dic_sname AS pe_pay_tp_name,
                                     p.dpp_name,
                                     t.pe_pay_dt,
                                     t.pe_row_cnt,
                                     t.pe_sum,
                                     t.pe_st,
                                     t.pe_po,
                                     t.pe_dt,
                                     t.pe_src_create_dt,
                                     cd.npc_name AS pe_code_name,
                                     tp.dic_sname AS pe_tp_name,
                                     st.dic_sname AS pe_st_name
                                FROM v_payroll_reestr t
                                JOIN uss_ndi.v_ndi_pay_person p ON (p.dpp_id = t.pe_dpp)
                                LEFT JOIN uss_ndi.v_ndi_payment_codes cd ON (cd.npc_code = t.pe_code)
                                LEFT JOIN uss_ndi.v_ddn_pe_tp tp ON (tp.dic_value = t.pe_tp)
                                LEFT JOIN uss_ndi.v_ddn_pe_st st ON (st.dic_value = t.pe_st)
                                left join uss_ndi.v_ddn_pe_pay_tp ptp on (t.pe_pay_tp = ptp.dic_value)
                               WHERE 1 = 1
                                 AND t.pe_class = ''DDS''
                                 AND p.dpp_tp IN (''STAL'', ''COLL'')
                                 -----#81443

                                '
               || CASE
                      WHEN P_pe_TP IS NOT NULL
                      THEN
                          ' and t.pe_tp = ''' || P_pe_TP || ''''
                  END
               || CASE
                      WHEN p_pe_dpp_Tp IS NOT NULL
                      THEN
                          ' and p.dpp_tp = ''' || p_pe_dpp_Tp || ''''
                  END
               || CASE
                      WHEN p_pe_dpp IS NOT NULL
                      THEN
                          ' and p.dpp_id = ' || p_pe_dpp
                  END
               -----#81443
               || CASE
                      WHEN l_org_to != 30
                      THEN
                          ' AND (t.pe_npc IS NULL OR t.pe_npc != 24) '
                  END
               || CASE WHEN l_org_to = 30 THEN ' AND (t.pe_npc = 24) ' END
               || CASE
                      WHEN p_pe_st = 'NEW'
                      THEN
                          ' and t.pe_st = ''NEW'' AND t.pe_po IS NULL '
                      WHEN p_pe_st = 'SELECTED'
                      THEN
                          ' AND t.pe_po IS NOT NULL AND EXISTS (SELECT * FROM pay_order z WHERE z.po_id = t.pe_po AND z.po_st != ''APPR'')'
                      WHEN p_pe_st = 'PROVE'
                      THEN
                          ' AND t.pe_po IS NOT NULL AND EXISTS (SELECT * FROM pay_order z WHERE z.po_id = t.pe_po AND z.po_st = ''APPR'')'
                  END
               || CASE
                      WHEN p_pe_nbg IS NOT NULL
                      THEN
                          ' and t.pe_nbg = ' || p_pe_nbg
                  END
               || CASE
                      WHEN p_pe_npc IS NOT NULL
                      THEN
                          ' and t.pe_npc = ' || p_pe_npc
                  END
               || CASE
                      WHEN p_pe_src IS NOT NULL
                      THEN
                          ' and t.pe_src = ''' || p_pe_src || ''''
                  END
               || P_WHERE
               || ' order by pe_dt';
    BEGIN
        tools.WriteMsg ('DNET$PAYMENT_ANALITIC.' || $$PLSQL_UNIT);

        TOOLS.validate_param (p_pe_dpp_Tp);
        TOOLS.validate_param (p_pe_tp);
        TOOLS.validate_param (p_pe_st);
        TOOLS.validate_param (p_pe_src);

        --TOOLS.validate_param(P_WHERE);

        --raise_application_error(-20000, substr(v_sql, length(v_sql) - 1000, 1000));
        OPEN RES_CUR FOR v_sql;
    END;


    PROCEDURE CREATE_DDS_PAY_ORDERS (
        p_dt                        DATE,
        p_pe_dpp                 IN NUMBER,
        p_pe_dpp_Tp              IN VARCHAR2,
        p_pe_tp                  IN VARCHAR2,
        p_pe_st                  IN VARCHAR2,
        p_pe_npc                 IN NUMBER,
        p_pe_nbg                 IN NUMBER,
        p_pe_src                 IN VARCHAR2,
        P_WHERE                  IN VARCHAR2,
        p_PO_DATE_PAY            IN pay_order.po_pay_dt%TYPE,
        P_PO_DPPA_PAYER          IN pay_order.po_dppa_payer%TYPE,
        p_PO_BANK_ACCOUNT_SRC    IN pay_order.PO_BANK_ACCOUNT_SRC%TYPE,
        p_PO_BANK_MFO_SRC        IN pay_order.PO_BANK_MFO_SRC%TYPE,
        p_PO_TAX_CODE_SRC        IN pay_order.PO_TAX_CODE_SRC%TYPE,
        p_PO_NAME_SRC            IN pay_order.PO_NAME_SRC%TYPE,
        p_PO_BANK_NAME_SRC       IN pay_order.PO_BANK_NAME_SRC%TYPE,
        P_PO_DPPA_RECIPIENT      IN pay_order.po_dppa_recipient%TYPE,
        p_PO_BANK_ACCOUNT_DEST   IN pay_order.PO_BANK_ACCOUNT_DEST%TYPE,
        p_PO_BANK_MFO_DEST       IN pay_order.PO_BANK_MFO_DEST%TYPE,
        p_PO_TAX_CODE_DEST       IN pay_order.PO_TAX_CODE_DEST%TYPE,
        p_PO_NAME_DEST           IN pay_order.PO_NAME_DEST%TYPE,
        p_PO_BANK_NAME_DEST      IN pay_order.PO_BANK_NAME_DEST%TYPE,
        p_PO_DPG                 IN pay_order.PO_DPG%TYPE,
        p_PO_NIE_AB              IN pay_order.Po_Nie_Ab%TYPE,
        p_Is_Ur_Obligation       IN NUMBER)
    IS
        l_arr         t_arr := t_arr ();
        l_org_to      NUMBER := tools.getcurrorgto;
        l_org         NUMBER := tools.getcurrorg;
        l_year        PLS_INTEGER := EXTRACT (YEAR FROM SYSDATE);
        l_ba_id       NUMBER;
        l_cto_ur_id   NUMBER;
        l_tot_sum     NUMBER;

        l_sql         VARCHAR2 (30000)
            :=    'SELECT DISTINCT p.dpp_id
                                FROM v_payroll_reestr t
                                JOIN uss_ndi.v_ndi_pay_person p ON (p.dpp_id = t.pe_dpp)
                               WHERE 1 = 1
                                 AND t.pe_class = ''DDS''
                                 AND p.dpp_tp IN (''STAL'', ''COLL'')
                                 and t.pe_po is null
                                 AND t.pe_st = ''NEW'''
               || CASE
                      WHEN p_pe_tp IS NOT NULL
                      THEN
                          ' and t.pe_tp = ''' || p_pe_tp || ''''
                  END
               || CASE
                      WHEN l_org_to = 30 THEN ' and t.pe_npc = 24 '
                      ELSE ' AND (t.pe_npc IS NULL OR t.pe_npc != 24) '
                  END
               || CASE
                      WHEN p_pe_src IS NOT NULL
                      THEN
                          ' and t.pe_src = ''' || p_pe_src || ''''
                  END
               || CASE
                      WHEN p_pe_npc IS NOT NULL
                      THEN
                          ' and t.pe_npc = ' || p_pe_npc
                  END
               || CASE
                      WHEN p_pe_nbg IS NOT NULL
                      THEN
                          ' and t.pe_nbg = ' || p_pe_nbg
                  END
               || CASE
                      WHEN p_pe_dpp_Tp IS NOT NULL
                      THEN
                          ' and p.dpp_tp = ''' || p_pe_dpp_Tp || ''''
                  END
               || CASE
                      WHEN p_pe_dpp IS NOT NULL
                      THEN
                          ' and p.dpp_id = ' || p_pe_dpp
                  END
               || P_WHERE;

        FUNCTION CREATE_OBLIGATION (p_po_id      IN NUMBER,
                                    p_dppa_id    IN NUMBER,
                                    p_dpp_id1    IN NUMBER,
                                    p_dppa_id1   IN NUMBER,
                                    p_sum        IN NUMBER,
                                    p_num        IN VARCHAR2,
                                    p_po_num     IN VARCHAR2)
            RETURN NUMBER
        IS
            l_cto_id        NUMBER;
            l_nfs_id        NUMBER;
            l_nkv_id        NUMBER;
            l_dt            DATE
                := TO_DATE ('31.12.' || TO_CHAR (SYSDATE, 'YYYY'),
                            'DD.MM.YYYY');
            l_cto_tp        VARCHAR2 (10) := 'FIN_OBLIG'; --CASE WHEN p_Is_Ur_Obligation = 1 THEN 'LEG_OBLIG' ELSE 'FIN_OBLIG' END;
            l_cto_oper_tp   VARCHAR2 (10) := 'FIN_OBL'; --CASE WHEN p_Is_Ur_Obligation = 1 THEN 'LEG_OBL' ELSE 'FIN_OBL' END;
        BEGIN
            SELECT MAX (t.nfs_id)
              INTO l_nfs_id
              FROM uss_ndi.v_ndi_funding_source t
             WHERE t.nfs_nbg = p_pe_nbg;

            SELECT MAX (c.npc_nkv)
              INTO l_nkv_id
              FROM payroll_reestr  t
                   JOIN uss_ndi.v_ndi_payment_codes c
                       ON (c.npc_id = t.pe_npc)
             WHERE t.pe_po = p_po_id
             FETCH FIRST ROW ONLY;

            INSERT INTO obligation (cto_tp,
                                    cto_oper_tp,
                                    com_org,
                                    cto_nfs,
                                    cto_dppa_own,
                                    cto_pdv_tp,
                                    cto_sum,
                                    cto_sum_without_pdv,
                                    cto_sum_pdv,
                                    cto_reestr_num,
                                    cto_num,
                                    cto_dksu_unload_dt,
                                    cto_dksu_get_dt,
                                    cto_dt,
                                    cto_dppa_ca,
                                    cto_dpp,
                                    cto_nkv,
                                    cto_st,
                                    cto_last_pay_dt,
                                    cto_term_dt,
                                    cto_reestr_dt,
                                    cto_acc_oper,
                                    cto_cto_ur)
                 VALUES (l_cto_tp,
                         l_cto_oper_tp,
                         tools.getcurrorg,
                         l_nfs_id,
                         p_dppa_id,
                         'N',
                         p_sum,
                         p_sum,
                         0,
                         p_num,
                         p_po_num,
                         TRUNC (SYSDATE),
                         TRUNC (SYSDATE),
                         TRUNC (SYSDATE),
                         p_dppa_id1,
                         p_dpp_id1,
                         l_nkv_id,
                         'IP',
                         l_dt,
                         l_dt,
                         TRUNC (SYSDATE),
                         'GET',
                         l_cto_ur_id)
              RETURNING cto_id
                   INTO l_cto_id;

            RETURN l_cto_id;
        END;

        FUNCTION SEED_PO (P_DPP_ID IN NUMBER)
            RETURN NUMBER
        IS
            l_po_id            NUMBER;
            l_sum              NUMBER;
            l_cto_id           NUMBER;
            l_num              NUMBER
                := uss_ndi.tools.get_last_pay_order_num (P_PO_DPPA_PAYER);
            l_dpp_row          uss_ndi.v_ndi_pay_person%ROWTYPE;
            l_acc_row          uss_ndi.v_ndi_pay_person_acc%ROWTYPE;
            l_bank_row         uss_ndi.v_ndi_bank%ROWTYPE;
            l_purpose          pay_order.po_purpose%TYPE;
            l_payer_bank_row   uss_ndi.v_ndi_bank%ROWTYPE;     --банк платника
            l_po_num           NUMBER;
        BEGIN
            BEGIN
                SELECT t.*
                  INTO l_dpp_row
                  FROM uss_ndi.v_ndi_pay_person t
                 WHERE t.dpp_id = p_dpp_id;
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;

            BEGIN
                SELECT d.*
                  INTO l_acc_row
                  FROM uss_ndi.v_ndi_pay_person  t
                       JOIN uss_ndi.v_ndi_pay_person_acc d
                           ON (d.dppa_dpp = t.dpp_id)
                 WHERE     t.dpp_id = p_dpp_id
                       AND d.dppa_is_main = 1
                       AND d.history_status = 'A';
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;

            BEGIN
                SELECT b.*
                  INTO l_bank_row
                  FROM uss_ndi.v_ndi_bank b
                 WHERE b.nb_id = l_acc_row.dppa_nb;
            EXCEPTION
                WHEN OTHERS
                THEN
                    NULL;
            END;

            SELECT COALESCE (MAX (TO_NUMBER (t.po_num)), 0) + 1
              INTO l_po_num
              FROM pay_order t
             WHERE t.po_pay_dt = p_po_date_pay;

            INSERT INTO pay_order (po_create_dt,
                                   po_pay_dt,
                                   po_number,
                                   po_sum,
                                   com_org_src,
                                   com_org_dest,
                                   po_bank_account_src,
                                   po_bank_account_dest,
                                   po_bank_mfo_src,
                                   po_bank_mfo_dest,
                                   po_tax_code_src,
                                   po_tax_code_dest,
                                   po_name_src,
                                   po_name_dest,
                                   po_bank_name_src,
                                   po_bank_name_dest,
                                   po_src,
                                   po_st,
                                   po_purpose,
                                   po_dpg,
                                   PO_NIE_AB,
                                   po_dppa_payer,
                                   po_dppa_recipient,
                                   po_circ_tp,
                                   po_num)
                 VALUES (SYSDATE,
                         p_po_date_pay,
                         l_num,
                         0,
                         l_org,
                         l_dpp_row.dpp_org,
                         --p_com_org_dst,
                         p_po_bank_account_src,
                         COALESCE (l_acc_row.dppa_account, ' '),
                         p_po_bank_mfo_src,
                         l_bank_row.nb_mfo,
                         p_po_tax_code_src,
                         l_dpp_row.dpp_tax_code,
                         p_po_name_src,
                         COALESCE (                     /*l_bank_row.nb_name*/
                                   l_dpp_row.dpp_name, ' '),
                         p_po_bank_name_src,
                         l_bank_row.nb_sname,
                         'OUT',
                         'E',
                         ' ',
                         p_po_dpg,
                         p_PO_NIE_AB,
                         P_PO_DPPA_PAYER,
                         l_acc_row.dppa_id,
                         'VD',
                         l_po_num)
              RETURNING po_id
                   INTO l_po_id;

            EXECUTE IMMEDIATE   'update v_payroll_reestr r
                           set r.pe_po = '
                             || l_po_id
                             || '
                          where r.pe_id in (SELECT t.pe_id
                                              FROM v_payroll_reestr t
                                              JOIN uss_ndi.v_ndi_pay_person p ON (p.dpp_id = t.pe_dpp)
                                             WHERE p.dpp_id = '
                             || P_DPP_ID
                             || '
                                              AND t.pe_class = ''DDS''
                                              AND p.dpp_tp IN (''STAL'', ''COLL'')
                                              and t.pe_po is null
                                              AND t.pe_st = ''NEW''
                                              and t.pe_sum is not null and t.pe_sum != 0
                                            '
                             || CASE
                                    WHEN p_pe_tp IS NOT NULL
                                    THEN
                                           ' and t.pe_tp = '''
                                        || p_pe_tp
                                        || ''''
                                END
                             -----#81443
                             || CASE
                                    WHEN l_org_to = 30
                                    THEN
                                        ' and t.pe_npc = 24 '
                                    ELSE
                                        ' AND (t.pe_npc IS NULL OR t.pe_npc != 24) '
                                END
                             || CASE
                                    WHEN p_pe_src IS NOT NULL
                                    THEN
                                           ' and t.pe_src = '''
                                        || p_pe_src
                                        || ''''
                                END
                             || CASE
                                    WHEN p_pe_npc IS NOT NULL
                                    THEN
                                        ' and t.pe_npc = ' || p_pe_npc
                                END
                             || CASE
                                    WHEN p_pe_nbg IS NOT NULL
                                    THEN
                                        ' and t.pe_nbg = ' || p_pe_nbg
                                END
                             || CASE
                                    WHEN p_pe_dpp_Tp IS NOT NULL
                                    THEN
                                           ' and p.dpp_tp = '''
                                        || p_pe_dpp_Tp
                                        || ''''
                                END
                             || P_WHERE
                             || ')';

            SELECT SUM (t.pe_sum)
              INTO l_sum
              FROM v_payroll_reestr t
             WHERE t.pe_po = l_po_id;

            l_purpose := get_purpose (l_po_id);

            --вычисляем банк платника по его счету P_PO_DPPA_PAYER
            SELECT b.*
              INTO l_payer_bank_row
              FROM uss_ndi.v_ndi_bank b
             WHERE b.nb_id = (SELECT dppa_nb
                                FROM uss_ndi.v_ndi_pay_person_acc
                               WHERE dppa_id = P_PO_DPPA_PAYER);

            IF (l_payer_bank_row.nb_is_treasury = 'T')
            THEN
                l_cto_id :=
                    CREATE_OBLIGATION (l_po_id,
                                       P_PO_DPPA_PAYER,
                                       l_dpp_row.dpp_id,
                                       l_acc_row.dppa_id,
                                       l_sum,
                                       l_num,
                                       l_po_num);
            END IF;

            UPDATE pay_order
               SET po_sum = l_sum, po_purpose = l_purpose, po_cto = l_cto_id
             WHERE po_id = l_po_id;

            RETURN l_sum;
        END;
    BEGIN
        IF (P_pe_ST NOT IN ('NEW'))
        THEN
            raise_application_error (
                -20000,
                'Формування ПД неможливе з відповідним статусом!');
        END IF;

        /* IF (p_pe_pay_tp = '1' AND P_PO_DPPA_RECIPIENT IS NULL) THEN
           raise_application_error(-20000, 'Не вказано рахунок отримувача!');
         END IF;
       */

        TOOLS.validate_param (p_pe_dpp_Tp);
        TOOLS.validate_param (p_pe_tp);
        TOOLS.validate_param (p_pe_st);
        TOOLS.validate_param (p_pe_src);

        --TOOLS.validate_param(P_WHERE);

        IF (p_pe_dpp IS NOT NULL)
        THEN
            l_tot_sum := SEED_PO (p_pe_dpp);
        ELSE
            EXECUTE IMMEDIATE l_sql
                BULK COLLECT INTO l_arr;

            IF (l_arr.COUNT () = 0)
            THEN
                raise_application_error (
                    -20000,
                    'Серед вибраних даних не знайдено утримувачів!');
            END IF;

            l_tot_sum := 0;

            FOR xx IN l_arr.FIRST .. l_arr.LAST
            LOOP
                l_tot_sum := l_tot_sum + NVL (SEED_PO (l_arr (xx)), 0);
            END LOOP;
        END IF;
    END;
BEGIN
    NULL;
END DNET$PAYMENT_ANALITIC;
/