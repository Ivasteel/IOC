/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.RBM$PKT_PROCESS
IS
    -- Author  : VANO
    -- Created : 15.06.2015 17:39:07
    -- Purpose : Обробка пакету модулем обміну з Infocross

    PROCEDURE GetGPLPacketsData (p_srt_code             VARCHAR2,
                                 p_recipient_code       VARCHAR2,
                                 p_rq                   VARCHAR2,
                                 p_rq_req_num_in        VARCHAR2,
                                 p_packet_data      OUT CLOB);

    PROCEDURE SavePPRPacketsData (p_srt_code         VARCHAR2,
                                  p_recipient_code   VARCHAR2,
                                  p_rq               VARCHAR2,
                                  p_rq_req_num_in    VARCHAR2,
                                  p_packet_data      CLOB);

    PROCEDURE SavePPRPacketsDataEX (p_srt_code         VARCHAR2,
                                    p_recipient_code   VARCHAR2,
                                    p_rq               VARCHAR2,
                                    p_rq_req_num_in    VARCHAR2,
                                    p_pkt              VARCHAR2,
                                    p_file_name        VARCHAR2,
                                    p_file_data        CLOB);
END RBM$PKT_PROCESS;
/


/* Formatted on 8/12/2025 6:10:50 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.RBM$PKT_PROCESS
IS
    PROCEDURE GetGPLPacketsData (p_srt_code             VARCHAR2,
                                 p_recipient_code       VARCHAR2,
                                 p_rq                   VARCHAR2,
                                 p_rq_req_num_in        VARCHAR2,
                                 p_packet_data      OUT CLOB)
    IS
        l_result    CLOB;
        l_packets   CLOB;
        l_cnt       INTEGER;
    BEGIN
        --raise_application_error(-20000, 'p_srt_code='||p_srt_code||';p_recipient_code='||p_recipient_code||';p_rq='||p_rq);
        IF UPPER (p_srt_code) = 'GET_PAYMENT_LISTS'
        THEN
            INSERT INTO tmp_pkt_work (x_pkt)
                SELECT pkt_id
                  FROM packet, recipient
                 WHERE     pkt_rec = rec_id
                       AND rec_cert_idn = p_recipient_code
                       AND pkt_st = 'NVP';

            l_cnt := SQL%ROWCOUNT;

            IF l_cnt > 0
            THEN
                SELECT XMLELEMENT (
                           "paymentlists",
                           XMLAGG (
                               XMLELEMENT (
                                   "row",
                                   XMLELEMENT ("id", pc_pkt),
                                   XMLELEMENT ("es_code", nes_id),
                                   XMLELEMENT ("es_name", nes_name),
                                   XMLELEMENT ("opfu_code", pkt_org),
                                   XMLELEMENT ("opfu_name", org_name),
                                   XMLELEMENT ("file_name", PC_NAME),
                                   XMLELEMENT ("file_data",
                                               TOOLS.ConvertB2C (pc_data))))).getClobVal ()
                  INTO l_packets
                  FROM tmp_pkt_work,
                       packet,
                       recipient,
                       packet_content  z,
                       ikis_sys.v_opfu,
                       uss_ndi.v_ndi_exchange_system
                 WHERE     x_pkt = pkt_id
                       AND pkt_rec = rec_id
                       AND pc_pkt = pkt_id
                       AND pkt_org = org_id
                       AND pkt_nes = nes_id;

                l_result := '<?xml version="1.0" encoding="utf-8"?>';
                DBMS_LOB.append (l_result, l_packets);
                p_packet_data := l_result;

                UPDATE packet
                   SET pkt_st = 'SND'
                 WHERE EXISTS
                           (SELECT 1
                              FROM tmp_pkt_work
                             WHERE x_pkt = pkt_id);

                INSERT INTO packet_processing (pp_pkt, pp_infocross_num)
                    SELECT x_pkt, p_rq FROM tmp_pkt_work;

                FOR cc IN (SELECT x_pkt FROM tmp_pkt_work)
                LOOP
                    RDM$LOG_PACKET.insert_LOG_PACKET (
                        cc.x_pkt,
                        NULL,
                        SYSDATE,
                        'PRCS',
                           'Включено у відповідь на запит Infocross <'
                        || p_srt_code
                        || '> id=<'
                        || p_rq
                        || '>, вхідний № '
                        || p_rq_req_num_in
                        || '.');
                END LOOP;
            END IF;
        END IF;

        RETURN;
    END;

    FUNCTION ExtractNumber (p_data XMLTYPE, p_path VARCHAR2)
        RETURN NUMBER
    IS
        l_result   NUMBER;
    BEGIN
        l_result := NULL;

        BEGIN
            IF p_data.EXISTSNODE (p_path) > 0
            THEN
                l_result :=
                    TO_NUMBER (
                        p_data.EXTRACT (p_path || '/text()').getstringval ());
            END IF;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        RETURN l_result;
    END;

    PROCEDURE SavePPRPacketsData (p_srt_code         VARCHAR2,
                                  p_recipient_code   VARCHAR2,
                                  p_rq               VARCHAR2,
                                  p_rq_req_num_in    VARCHAR2,
                                  p_packet_data      CLOB)
    IS
        l_xml_data        XMLTYPE;
        l_pkt_in          packet.pkt_id%TYPE;
        l_pat_code_in     USS_NDI.V_NDI_PACKET_TYPE.pat_code%TYPE;
        l_pat_code_save   USS_NDI.V_NDI_PACKET_TYPE.pat_code%TYPE;
        l_save_pkt        packet.pkt_id%TYPE;
        l_row             packet%ROWTYPE;
        l_data            CLOB;
        l_file_name       packet_content.pc_name%TYPE;
    BEGIN
        l_xml_data := xmltype (p_packet_data);
        l_pkt_in := ExtractNumber (l_xml_data, '/paymentlistsreply/id');
        l_file_name :=
            l_xml_data.EXTRACT ('/paymentlistsreply/file_name/text()').getstringval ();
        l_data :=
            l_xml_data.EXTRACT ('/paymentlistsreply/file_data/text()').getclobval ();


        SELECT pat_code, pkt_org, pkt_rec
          INTO l_pat_code_in, l_row.pkt_org, l_row.pkt_rec
          FROM packet, USS_NDI.V_NDI_PACKET_TYPE
         WHERE pkt_id = l_pkt_in AND pkt_pat = pat_id;

        SELECT DECODE (l_pat_code_in,
                       'payroll_pvp', 'payroll_reply_pvp',
                       'payroll_asopd', 'payroll_reply_asopd')
          INTO l_pat_code_save
          FROM DUAL;

        SELECT pat_id, pat_nes
          INTO l_row.pkt_pat, l_row.pkt_nes
          FROM USS_NDI.V_NDI_PACKET_TYPE
         WHERE pat_code = l_pat_code_save;

        l_save_pkt :=
            RDM$PACKET.insert_packet (l_row.pkt_pat,
                                      l_row.pkt_nes,
                                      l_row.pkt_org,
                                      'ANS',
                                      NULL,
                                      SYSDATE,
                                      NULL,
                                      NULL,
                                      l_row.pkt_rec);
        RDM$PACKET_CONTENT.insert_packet_content (l_save_pkt,
                                                  'F',
                                                  l_file_name,
                                                  TOOLS.ConvertC2B (l_data),
                                                  NULL,
                                                  NULL);
        RDM$PACKET.SET_PACKET_STATE (l_save_pkt,
                                     'ANS',
                                     NULL,
                                     NULL);
        RDM$PACKET_LINKS.insert_packet_LINKS (l_pkt_in, l_save_pkt);
        RDM$LOG_PACKET.insert_LOG_PACKET (
            l_save_pkt,
            NULL,
            SYSDATE,
            'ANS',
               'Отримано дані у запиті Infocross <'
            || p_srt_code
            || '> id=<'
            || p_rq
            || '>, вхідний № '
            || p_rq_req_num_in
            || '.');
    END;

    PROCEDURE SavePPRPacketsDataEX (p_srt_code         VARCHAR2,
                                    p_recipient_code   VARCHAR2,
                                    p_rq               VARCHAR2,
                                    p_rq_req_num_in    VARCHAR2,
                                    p_pkt              VARCHAR2,
                                    p_file_name        VARCHAR2,
                                    p_file_data        CLOB)
    IS
        l_pkt_in          packet.pkt_id%TYPE;
        l_pat_code_in     USS_NDI.V_NDI_PACKET_TYPE.pat_code%TYPE;
        l_pat_code_save   USS_NDI.V_NDI_PACKET_TYPE.pat_code%TYPE;
        l_save_pkt        packet.pkt_id%TYPE;
        l_row             packet%ROWTYPE;
        l_data            CLOB;
        l_file_name       packet_content.pc_name%TYPE;
    BEGIN
        l_pkt_in := TO_NUMBER (p_pkt);
        l_file_name := p_file_name;
        l_data := p_file_data;

        SELECT pat_code, pkt_org, pkt_rec
          INTO l_pat_code_in, l_row.pkt_org, l_row.pkt_rec
          FROM packet, USS_NDI.V_NDI_PACKET_TYPE
         WHERE pkt_id = l_pkt_in AND pkt_pat = pat_id;

        SELECT DECODE (l_pat_code_in,
                       'payroll_pvp', 'payroll_reply_pvp',
                       'payroll_asopd', 'payroll_reply_asopd')
          INTO l_pat_code_save
          FROM DUAL;

        SELECT pat_id, pat_nes
          INTO l_row.pkt_pat, l_row.pkt_nes
          FROM USS_NDI.V_NDI_PACKET_TYPE
         WHERE pat_code = l_pat_code_save;

        l_save_pkt :=
            RDM$PACKET.insert_packet (l_row.pkt_pat,
                                      l_row.pkt_nes,
                                      l_row.pkt_org,
                                      'ANS',
                                      NULL,
                                      SYSDATE,
                                      NULL,
                                      NULL,
                                      l_row.pkt_rec);
        RDM$PACKET_CONTENT.insert_packet_content (l_save_pkt,
                                                  'F',
                                                  l_file_name,
                                                  TOOLS.ConvertC2B (l_data),
                                                  NULL,
                                                  NULL);
        RDM$PACKET.SET_PACKET_STATE (l_save_pkt,
                                     'ANS',
                                     NULL,
                                     NULL);
        RDM$PACKET_LINKS.insert_packet_LINKS (l_pkt_in, l_save_pkt);
        RDM$LOG_PACKET.insert_LOG_PACKET (
            l_save_pkt,
            NULL,
            SYSDATE,
            'ANS',
               'Отримано дані у запиті Infocross <'
            || p_srt_code
            || '> id=<'
            || p_rq
            || '>, вхідний № '
            || p_rq_req_num_in
            || '.');
    END;
END RBM$PKT_PROCESS;
/