/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.RDM$LOG_PACKET
IS
    -- Author  : JSHPAK
    -- Created : 09.07.2015 11:15:05
    -- Purpose :

    PROCEDURE insert_LOG_PACKET (p_lp_pkt       NUMBER,
                                 p_lp_wu        NUMBER,
                                 p_lp_dt        DATE,
                                 p_lp_atp       VARCHAR2,
                                 p_lp_comment   VARCHAR2);

    PROCEDURE insert_message (p_lp_pkt       NUMBER,
                              p_lp_wu        NUMBER DEFAULT NULL,
                              p_lp_atp       VARCHAR2 DEFAULT NULL,
                              p_lp_comment   VARCHAR2 DEFAULT NULL);
END RDM$LOG_PACKET;
/


GRANT EXECUTE ON IKIS_RBM.RDM$LOG_PACKET TO DNET_PROXY
/

GRANT EXECUTE ON IKIS_RBM.RDM$LOG_PACKET TO IC_WORKER
/

GRANT EXECUTE ON IKIS_RBM.RDM$LOG_PACKET TO II01RC_RBMWEB_COMMON
/

GRANT EXECUTE ON IKIS_RBM.RDM$LOG_PACKET TO II01RC_RBM_ESR
/

GRANT EXECUTE ON IKIS_RBM.RDM$LOG_PACKET TO IKIS_WEBPROXY
/

GRANT EXECUTE ON IKIS_RBM.RDM$LOG_PACKET TO PORTAL_PROXY
/

GRANT EXECUTE ON IKIS_RBM.RDM$LOG_PACKET TO USS_ESR
/


/* Formatted on 8/12/2025 6:10:51 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.RDM$LOG_PACKET
IS
    /*function get_lp_id return number is
      l_curval number;
    begin
      SELECT SQ_ID_LOG_PACKET.NEXTVAL INTO l_curval FROM dual;
      return(l_curval);
    end get_lp_id;*/

    PROCEDURE insert_LOG_PACKET (p_lp_pkt       NUMBER,
                                 p_lp_wu        NUMBER,
                                 p_lp_dt        DATE,
                                 p_lp_atp       VARCHAR2,
                                 p_lp_comment   VARCHAR2)
    IS
        l_lp_id    NUMBER (14);
        l_pkt_rm   NUMBER (14);
        l_rm_msg   VARCHAR2 (500);
    BEGIN
        l_lp_id := NULL;                                         -- get_lp_id;

        SELECT MAX (pkt_rm)
          INTO l_pkt_rm
          FROM packet
         WHERE pkt_id = p_lp_pkt;

        /*  io 20230623 - не потрібно ...
          if l_pkt_rm > 0 and p_lp_atp in ('SGN','NVP','') then
            select 'mail:'||rm_mail||';cert:'||tools.hash_md5(RM_CERT)||';'
            into l_rm_msg
            from recipient_mail
            where rm_id = l_pkt_rm;
          end if;*/

        INSERT INTO log_packet (lp_id,
                                lp_pkt,
                                lp_wu,
                                lp_dt,
                                lp_atp,
                                lp_comment)
             VALUES (l_lp_id,
                     p_lp_pkt,
                     p_lp_wu,
                     NVL (p_lp_dt, SYSDATE),
                     p_lp_atp,
                     l_rm_msg || p_lp_comment);
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionRBM (
                'RDM$LOG_PACKET.insert_LOG_PACKET ',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE insert_message (p_lp_pkt       NUMBER,
                              p_lp_wu        NUMBER DEFAULT NULL,
                              p_lp_atp       VARCHAR2 DEFAULT NULL,
                              p_lp_comment   VARCHAR2 DEFAULT NULL)
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_lp_id   NUMBER (14);
    BEGIN
        l_lp_id := NULL;                                         -- get_lp_id;

        INSERT INTO log_packet (lp_id,
                                lp_pkt,
                                lp_wu,
                                lp_dt,
                                lp_atp,
                                lp_comment)
             VALUES (l_lp_id,
                     p_lp_pkt,
                     p_lp_wu,
                     SYSDATE,
                     p_lp_atp,
                     SUBSTR (p_lp_comment, 1, 500));

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionRBM (
                'RDM$LOG_PACKET.insert_message ',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END insert_message;
BEGIN
    -- Initialization
    NULL;
END RDM$LOG_PACKET;
/