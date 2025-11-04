/* Formatted on 8/12/2025 5:58:55 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RPT.API$REPORTS
AS
    -- Author  : ivashchuk
    -- Created : 22.04.2019

    FUNCTION insert_reports (p_rpt_rt    NUMBER,
                             p_rpt_org   NUMBER,
                             p_rpt_wu    NUMBER,
                             p_rpt_st    VARCHAR2,
                             p_rpt_rq    NUMBER,
                             p_rpt_jb    NUMBER)
        RETURN NUMBER;

    PROCEDURE update_reports (p_rpt_id    NUMBER,
                              p_rpt_rt    NUMBER DEFAULT NULL,
                              p_rpt_org   NUMBER DEFAULT NULL,
                              p_rpt_wu    NUMBER DEFAULT NULL,
                              p_rpt_dt    DATE DEFAULT NULL,
                              p_rpt_st    VARCHAR2 DEFAULT NULL,
                              p_rpt_rq    NUMBER DEFAULT NULL);

    PROCEDURE delete_reports (p_rpt_id NUMBER);

    PROCEDURE set_rpt_st (p_rpt_id      NUMBER,
                          p_rpt_st      VARCHAR2,
                          p_action_tp   VARCHAR2 DEFAULT NULL,
                          p_info        VARCHAR2 DEFAULT NULL);

    PROCEDURE set_rpt_ready (p_rpt_id NUMBER, p_rows_cnt NUMBER);
END API$REPORTS;
/


GRANT EXECUTE ON USS_RPT.API$REPORTS TO II01RC_USS_RPT_INTERNAL
/

GRANT EXECUTE ON USS_RPT.API$REPORTS TO USS_ESR
/

GRANT EXECUTE ON USS_RPT.API$REPORTS TO USS_RNSP
/


/* Formatted on 8/12/2025 5:58:58 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RPT.API$REPORTS
AS
    -- Author  : ivashchuk
    -- Created : 22.04.2019

    msgCOMMON_EXCEPTION   NUMBER := 2;

    FUNCTION insert_reports (p_rpt_rt    NUMBER,
                             p_rpt_org   NUMBER,
                             p_rpt_wu    NUMBER,
                             p_rpt_st    VARCHAR2,
                             p_rpt_rq    NUMBER,
                             p_rpt_jb    NUMBER)
        RETURN NUMBER
    IS
        l_out_id   NUMBER;
    BEGIN
        INSERT INTO REPORTS (rpt_id,
                             rpt_rt,
                             com_org,
                             com_wu,
                             rpt_dt,
                             rpt_st,
                             rpt_rq,
                             rpt_jb)
             VALUES (0,
                     p_rpt_rt,
                     uss_rpt_context.GetContext (uss_rpt_context.gOPFU),
                     uss_rpt_context.GetContext (uss_rpt_context.gUID),
                     SYSDATE,
                     p_rpt_st,
                     p_rpt_rq,
                     p_rpt_jb)
          RETURNING rpt_id
               INTO l_out_id;

        api$rpt_hist.insert_rpt_hist (p_rh_rpt         => l_out_id,
                                      p_rh_rpt_st      => p_rpt_st,
                                      p_rh_action_tp   => 'CR',
                                      p_rh_info        => NULL);

        RETURN l_out_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'RDM$REPORTS.insert: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE update_reports (p_rpt_id    NUMBER,
                              p_rpt_rt    NUMBER DEFAULT NULL,
                              p_rpt_org   NUMBER DEFAULT NULL,
                              p_rpt_wu    NUMBER DEFAULT NULL,
                              p_rpt_dt    DATE DEFAULT NULL,
                              p_rpt_st    VARCHAR2 DEFAULT NULL,
                              p_rpt_rq    NUMBER DEFAULT NULL)
    IS
    BEGIN
        UPDATE REPORTS
           SET rpt_rt = NVL (p_rpt_rt, rpt_rt),
               --     rpt_org = nvl(p_rpt_org,rpt_org),
               --     rpt_wu = nvl(p_rpt_wu,com_wu),
               rpt_dt = NVL (p_rpt_dt, rpt_dt),
               rpt_st = NVL (p_rpt_st, rpt_st),
               rpt_rq = NVL (p_rpt_rq, rpt_rq)
         WHERE rpt_id = p_rpt_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'RDM$REPORTS.update: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE delete_reports (p_rpt_id NUMBER)
    IS
    BEGIN
        DELETE FROM REPORTS
              WHERE rpt_id = p_rpt_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'RDM$REPORTS.delete: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE set_rpt_st (p_rpt_id      NUMBER,
                          p_rpt_st      VARCHAR2,
                          p_action_tp   VARCHAR2 DEFAULT NULL,
                          p_info        VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        UPDATE REPORTS
           SET rpt_st = p_rpt_st
         WHERE rpt_id = p_rpt_id;

        api$rpt_hist.insert_rpt_hist (p_rh_rpt         => p_rpt_id,
                                      p_rh_rpt_st      => p_rpt_st,
                                      p_rh_action_tp   => p_action_tp,
                                      p_rh_info        => p_info);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'RDM$REPORTS.set_rpt_st: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE set_rpt_ready (p_rpt_id NUMBER, p_rows_cnt NUMBER)
    IS
    BEGIN
        UPDATE REPORTS
           SET rpt_st = 'R', rpt_rows_cnt = p_rows_cnt
         WHERE rpt_id = p_rpt_id;

        api$rpt_hist.insert_rpt_hist (p_rh_rpt         => p_rpt_id,
                                      p_rh_rpt_st      => 'R',
                                      p_rh_action_tp   => 'CR',
                                      p_rh_info        => '');
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'RDM$REPORTS.set_rpt_ready: '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;
END API$REPORTS;
/