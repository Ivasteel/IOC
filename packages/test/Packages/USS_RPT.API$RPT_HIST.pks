/* Formatted on 8/12/2025 5:58:56 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RPT.API$RPT_HIST
AS
    -- Author  : ivashchuk
    -- Created : 22.04.2019

    PROCEDURE insert_rpt_hist (p_rh_rpt         NUMBER,
                               p_rh_rpt_st      VARCHAR2,
                               p_rh_action_tp   VARCHAR2 DEFAULT NULL,
                               p_rh_info        VARCHAR2 DEFAULT NULL);
END API$RPT_HIST;
/


/* Formatted on 8/12/2025 5:58:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RPT.API$RPT_HIST
AS
    -- Author  : ivashchuk
    -- Created : 22.04.2019

    msgCOMMON_EXCEPTION   NUMBER := 2;

    PROCEDURE insert_rpt_hist (p_rh_rpt         NUMBER,
                               p_rh_rpt_st      VARCHAR2,
                               p_rh_action_tp   VARCHAR2 DEFAULT NULL,
                               p_rh_info        VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        INSERT INTO rpt_hist (rh_id,
                              rh_dt,
                              rh_rpt,
                              rh_rpt_st,
                              rh_wu,
                              rh_action_tp,
                              rh_info)
             VALUES (0,
                     SYSDATE,
                     p_rh_rpt,
                     p_rh_rpt_st,
                     uss_rpt_context.GetContext (uss_rpt_context.gUID),
                     p_rh_action_tp,
                     p_rh_info);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'API$RPT_HIST.insert: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;
END API$RPT_HIST;
/