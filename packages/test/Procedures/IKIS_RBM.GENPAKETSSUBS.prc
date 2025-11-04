/* Formatted on 8/12/2025 6:10:53 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_RBM.GenPaketsSubs (
    p_exchange_subsystem   NUMBER DEFAULT 6)
IS
    l_pkt     packet.pkt_id%TYPE;
    l_pt_id   packet_type.pt_id%TYPE;
BEGIN
    SELECT pt_id
      INTO l_pt_id
      FROM packet_type
     WHERE pt_code = 'payrollpassport_ppvp';

    FOR cc IN (SELECT * FROM tmp_exchangefiles_m2)
    LOOP
        l_pkt :=
            ikis_rbm.RDM$PACKET.insert_packet (l_pt_id,
                                               P_EXCHANGE_SUBSYSTEM,
                                               cc.ef_org,
                                               'N',
                                               NULL,
                                               SYSDATE,
                                               NULL,
                                               NULL,
                                               cc.ef_rec);
        ikis_rbm.RDM$PACKET_CONTENT.insert_packet_content (
            l_pkt,
            'F',
            cc.ef_name,
            cc.ef_data,
            NULL,
            SYSDATE,
            cc.ef_visual_data,
            cc.ef_main_tag_name,
            cc.ef_data_name,
            cc.ef_ecp_list_name,
            cc.ef_ecp_name,
            cc.ef_ecp_alg,
            cc.ef_id,
            cc.ef_header);
    END LOOP;
EXCEPTION
    WHEN OTHERS
    THEN
        raise_application_error (
            -20000,
               'GenPaketsPpvpPsp:'
            || CHR (10)
            || REPLACE (
                      DBMS_UTILITY.FORMAT_ERROR_STACK
                   || ' => '
                   || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                   'ORA-20000:')
            || CHR (10)
            || SQLERRM);
END GenPaketsSubs;

----> grant execute on  IKIS_RBM.GenPaketsPpvpPsp TO IKIS_SUBS;
/
