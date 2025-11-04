/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.RDM$PACKET_LINKS
IS
    -- Author  : JSHPAK
    -- Created : 09.07.2015 11:15:05
    -- Purpose :

    PROCEDURE insert_packet_LINKS (p_pl_pkt_in NUMBER, p_pl_pkt_out NUMBER);
END RDM$PACKET_LINKS;
/


/* Formatted on 8/12/2025 6:10:51 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.RDM$PACKET_LINKS
IS
    /*
    function get_pkt_links_id return number is
      l_curval number;
    begin
      SELECT SQ_ID_PACKET_LINKS.NEXTVAL INTO l_curval FROM dual;
      return(l_curval);
    end get_pkt_links_id;
    */
    PROCEDURE insert_packet_LINKS (p_pl_pkt_in NUMBER, p_pl_pkt_out NUMBER)
    IS
        l_pkt_links_id   NUMBER (14);
    BEGIN
        INSERT INTO packet_links (pl_id, pl_pkt_in, pl_pkt_out)
             VALUES (NULL, p_pl_pkt_in, p_pl_pkt_out);
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionRBM (
                'RDM$PACKET_LINKS.insert_packet_links ',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;
BEGIN
    -- Initialization
    NULL;
END RDM$PACKET_LINKS;
/