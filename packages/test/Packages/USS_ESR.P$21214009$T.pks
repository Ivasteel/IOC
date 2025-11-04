/* Formatted on 8/12/2025 5:48:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.P$21214009$T
IS
    -- Author  : VANO
    -- Created : 22.07.2021 9:24:22
    -- Purpose : Розрахунок виплатних відомостей

    g_TraceMsgEnabled   INTEGER := 1;

    PROCEDURE create_payroll (
        p_tp          payroll.pr_tp%TYPE,
        p_org         payroll.com_org%TYPE,
        p_month       DATE,
        p_day_start   INTEGER,
        p_day_stop    INTEGER,
        p_pay_tp      VARCHAR2,
        p_npc         NUMBER,
        p_pe_code     USS_NDI.v_ddn_pe_code.DIC_VALUE%TYPE DEFAULT '1' -- Режим створення #79218 OPERVIEIEV 08.2022
                                                                      );

    PROCEDURE fix_payroll (p_pr_id payroll.pr_id%TYPE);

    PROCEDURE approve_payroll (p_pr_id payroll.pr_id%TYPE);

    PROCEDURE send_payroll (p_pr_id payroll.pr_id%TYPE);

    PROCEDURE make_payroll_reestr (p_pr_id payroll.pr_id%TYPE);

    PROCEDURE delete_payroll (p_pr_id payroll.pr_id%TYPE);

    PROCEDURE unfix_payroll (p_pr_id payroll.pr_id%TYPE);

    --Отримання серії та номеру паспорту з документів звернення
    FUNCTION get_pasp_info (p_mode INTEGER, p_ap appeal.ap_id%TYPE)
        RETURN VARCHAR2;

    FUNCTION get_fuctionary (p_org NUMBER, p_tp VARCHAR2)
        RETURN VARCHAR2;

    -- #80146 OPERVIEIEV новая идеология доступности ОСЗН (и новая табличка TMP_COM_ORGS)
    PROCEDURE init_com_orgs (p_org              NUMBER,
                             p_user_org_force   NUMBER DEFAULT NULL /*for test*/
                                                                   );

    PROCEDURE init_access_params;

    PROCEDURE SaveTraceMsg (p_msg VARCHAR2, p_type VARCHAR2 DEFAULT 'I');
END P$21214009$T;
/
