/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.RDM$IC_REQUESTS_LOG
IS
    -- Author  : OIVASHCHUK
    -- Created : 24.11.2016 12:37:20
    -- Purpose : Логування запитів ІС

    PROCEDURE insert_ic_requests_log (
        p_irl_pkt       IC_REQUESTS_LOG.IRL_PKT%TYPE DEFAULT NULL,
        p_irl_code      IC_REQUESTS_LOG.IRL_CODE%TYPE,
        p_irl_rq        IC_REQUESTS_LOG.IRL_RQ%TYPE,
        p_irl_data      IC_REQUESTS_LOG.IRL_DATA%TYPE DEFAULT NULL,
        p_irl_message   IC_REQUESTS_LOG.IRL_MESSAGE%TYPE DEFAULT NULL);

    PROCEDURE set_ic_requests_log_st (
        p_irl_id        IC_REQUESTS_LOG.IRL_ID%TYPE,
        p_irl_st        IC_REQUESTS_LOG.IRL_ST%TYPE,
        p_irl_message   IC_REQUESTS_LOG.IRL_MESSAGE%TYPE DEFAULT NULL);
END RDM$IC_REQUESTS_LOG;
/


/* Formatted on 8/12/2025 6:10:50 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.RDM$IC_REQUESTS_LOG
IS
    PROCEDURE insert_ic_requests_log (
        p_irl_pkt       IC_REQUESTS_LOG.IRL_PKT%TYPE DEFAULT NULL,
        p_irl_code      IC_REQUESTS_LOG.IRL_CODE%TYPE,
        p_irl_rq        IC_REQUESTS_LOG.IRL_RQ%TYPE,
        p_irl_data      IC_REQUESTS_LOG.IRL_DATA%TYPE DEFAULT NULL,
        p_irl_message   IC_REQUESTS_LOG.IRL_MESSAGE%TYPE DEFAULT NULL)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_pkt_id    NUMBER (14);
        l_comment   log_packet.lp_comment%TYPE;
    BEGIN
        /*  insert  packet*/
        INSERT INTO IC_REQUESTS_LOG (IRL_ID,
                                     IRL_PKT,
                                     IRL_CODE,
                                     IRL_RQ,
                                     IRL_DATA,
                                     IRL_DT,
                                     IRL_ST,
                                     IRL_MESSAGE)
             VALUES (0,
                     p_irl_pkt,
                     p_irl_code,
                     p_irl_rq,
                     p_irl_data,
                     SYSDATE,
                     'N',
                     p_irl_message);

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ikis_rbm.rdm$log_packet.insert_message (
                p_lp_pkt   => p_irl_pkt,
                p_lp_comment   =>
                       '<rq='
                    || p_irl_rq
                    || ', pkt='
                    || p_irl_pkt
                    || '>'
                    || CHR (10)
                    || DBMS_UTILITY.format_error_stack
                    || DBMS_UTILITY.format_error_backtrace);
    END insert_ic_requests_log;

    PROCEDURE set_ic_requests_log_st (
        p_irl_id        IC_REQUESTS_LOG.IRL_ID%TYPE,
        p_irl_st        IC_REQUESTS_LOG.IRL_ST%TYPE,
        p_irl_message   IC_REQUESTS_LOG.IRL_MESSAGE%TYPE DEFAULT NULL)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_pkt_id    NUMBER (14);
        l_comment   log_packet.lp_comment%TYPE;
    BEGIN
        UPDATE IC_REQUESTS_LOG
           SET IRL_ST = p_irl_st, IRL_MESSAGE = p_irl_message
         WHERE IRL_ID = p_irl_id;

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            NULL;
    END set_ic_requests_log_st;
BEGIN
    NULL;
END RDM$IC_REQUESTS_LOG;
/