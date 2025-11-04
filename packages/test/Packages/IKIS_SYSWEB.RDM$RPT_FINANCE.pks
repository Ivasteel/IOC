/* Formatted on 8/12/2025 6:11:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.RDM$RPT_FINANCE
IS
    -- Author  : BOGDAN
    -- Created : 19.09.2018 18:39:40
    -- Purpose : Фінансова звітність

    PROCEDURE CALC_BALANCE (P_START_DT   IN DATE,
                            P_STOP_DT    IN DATE,
                            P_JBR_ID     IN NUMBER);

    PROCEDURE RegisterReport (P_START_DT   IN     DATE,
                              P_STOP_DT    IN     DATE,
                              P_RT_ID      IN     NUMBER,
                              p_jbr_id        OUT NUMBER);
END RDM$RPT_FINANCE;
/
