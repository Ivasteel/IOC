/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.RDM$PACKET_CONTENT
IS
    -- Author  : JSHPAK
    -- Created : 09.07.2015 11:15:05
    -- Purpose :

    PROCEDURE insert_packet_content (
        p_pc_pkt             packet_content.pc_pkt%TYPE,
        p_pc_tp              packet_content.pc_tp%TYPE,
        p_pc_name            packet_content.pc_name%TYPE,
        p_pc_data            packet_content.pc_data%TYPE,
        p_pc_pkt_change_wu   log_packet.lp_wu%TYPE,
        p_pc_pkt_change_dt   log_packet.lp_dt%TYPE,
        p_pc_visual_data     packet_content.pc_visual_data%TYPE:= NULL,
        p_pc_main_tag_name   packet_content.pc_main_tag_name%TYPE:= NULL,
        p_pc_data_name       packet_content.pc_data_name%TYPE:= NULL,
        p_pc_ecp_list_name   packet_content.pc_ecp_list_name%TYPE:= NULL,
        p_pc_ecp_name        packet_content.pc_ecp_name%TYPE:= NULL,
        p_pc_ecp_alg         packet_content.pc_ecp_alg%TYPE:= NULL,
        p_pc_src_entity      packet_content.pc_src_entity%TYPE:= NULL,
        p_pc_header          packet_content.pc_header%TYPE:= NULL,
        p_pc_encrypt_data    packet_content.pc_encrypt_data%TYPE:= NULL, -- 20201214
        p_pc_npc             packet_content.pc_npc%TYPE:= NULL);     -- #79230

    PROCEDURE SavePacketEncryptData (
        p_pc_id             packet_content.pc_id%TYPE,
        p_pc_encrypt_data   packet_content.pc_encrypt_data%TYPE);

    PROCEDURE delete_packet_content (
        p_pc_id              packet_content.pc_id%TYPE,
        p_pc_pkt             packet_content.pc_pkt%TYPE,
        p_pc_pkt_change_wu   log_packet.lp_wu%TYPE,
        p_pc_pkt_change_dt   log_packet.lp_dt%TYPE);

    PROCEDURE DownloadFileContent (
        p_download_pc_id     packet_content.pc_id%TYPE,
        p_pc_pkt             log_packet.lp_pkt%TYPE,
        p_pc_pkt_change_wu   log_packet.lp_wu%TYPE,
        p_pc_pkt_change_dt   log_packet.lp_dt%TYPE);

    PROCEDURE SaveSign (p_pce_id     packet_ecp.pce_id%TYPE,
                        p_pce_pc     packet_ecp.pce_pc%TYPE,
                        p_pce_ecp    packet_ecp.pce_ecp%TYPE,
                        p_pce_info   packet_ecp.pce_info%TYPE);

    PROCEDURE DeleteSign (p_pce_id packet_ecp.pce_id%TYPE);

    PROCEDURE insert_pc2fa (
        p_pc_pkt                 packet_content.pc_pkt%TYPE,
        p_pkt_pat                packet.pkt_pat%TYPE,
        p_pkt_org                packet.pkt_org%TYPE,
        p_pc_tp                  packet_content.pc_tp%TYPE,
        p_pc_name                packet_content.pc_name%TYPE,
        p_pc_data                packet_content.pc_data%TYPE,
        p_pc_pkt_change_wu       log_packet.lp_wu%TYPE,
        p_pc_pkt_change_dt       log_packet.lp_dt%TYPE,
        p_pc_visual_data         packet_content.pc_visual_data%TYPE := NULL,
        p_pc_main_tag_name       packet_content.pc_main_tag_name%TYPE := NULL,
        p_pc_data_name           packet_content.pc_data_name%TYPE := NULL,
        p_pc_ecp_list_name       packet_content.pc_ecp_list_name%TYPE := NULL,
        p_pc_ecp_name            packet_content.pc_ecp_name%TYPE := NULL,
        p_pc_ecp_alg             packet_content.pc_ecp_alg%TYPE := NULL,
        p_pc_src_entity          packet_content.pc_src_entity%TYPE := NULL,
        p_pc_header              packet_content.pc_header%TYPE := NULL,
        p_res_code           OUT NUMBER                      -- 0 - ok, 1 -err
                                       );

    -- io 20230222
    PROCEDURE set_pc_header (p_pc_pkt      packet_content.pc_pkt%TYPE,
                             p_pc_header   packet_content.pc_header%TYPE);

    -- io 20231124
    PROCEDURE set_visual_data (
        p_pc_pkt           packet_content.pc_pkt%TYPE,
        p_pc_visual_data   packet_content.pc_visual_data%TYPE);

    -- IC #97478
    PROCEDURE set_packet_content (
        p_set_row   IN     v_packet_content%ROWTYPE,
        p_pc_id        OUT NUMBER);
END RDM$PACKET_CONTENT;
/


GRANT EXECUTE ON IKIS_RBM.RDM$PACKET_CONTENT TO DNET_PROXY
/

GRANT EXECUTE ON IKIS_RBM.RDM$PACKET_CONTENT TO II01RC_RBMWEB_COMMON
/

GRANT EXECUTE ON IKIS_RBM.RDM$PACKET_CONTENT TO II01RC_RBM_ESR
/

GRANT EXECUTE ON IKIS_RBM.RDM$PACKET_CONTENT TO PORTAL_PROXY
/

GRANT EXECUTE ON IKIS_RBM.RDM$PACKET_CONTENT TO USS_ESR
/


/* Formatted on 8/12/2025 6:10:51 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.RDM$PACKET_CONTENT
IS
    FUNCTION blob_to_clob (blob_in IN BLOB)
        RETURN CLOB
    AS
        v_clob      CLOB;
        v_varchar   VARCHAR2 (32767);
        v_start     PLS_INTEGER := 1;
        v_buffer    PLS_INTEGER := 32767;
    BEGIN
        DBMS_LOB.CREATETEMPORARY (v_clob, TRUE);

        FOR i IN 1 .. CEIL (DBMS_LOB.GETLENGTH (blob_in) / v_buffer)
        LOOP
            v_varchar :=
                UTL_RAW.CAST_TO_VARCHAR2 (
                    DBMS_LOB.SUBSTR (blob_in, v_buffer, v_start));

            DBMS_LOB.WRITEAPPEND (v_clob, LENGTH (v_varchar), v_varchar);
            v_start := v_start + v_buffer;
        END LOOP;

        RETURN v_clob;
    END blob_to_clob;

    /*
    \* get id for packet content *\
    function get_pkt_content_id return number is
      l_curval number;
    begin
      SELECT SQ_ID_PACKET_CONTENT.NEXTVAL INTO l_curval FROM dual;
      return(l_curval);
    end get_pkt_content_id;
    */
    /* get log comment text */
    FUNCTION get_log_pc_pkt_comment (p_pc_id    NUMBER,
                                     p_pc_pkt   NUMBER,
                                     p_lp_tp    VARCHAR2)
        RETURN VARCHAR2
    IS
        l_comment      log_packet.lp_comment%TYPE;
        l_comment_st   log_packet.lp_comment%TYPE;
    BEGIN
        l_comment := NULL;

        /* формування значення коментаря */
        SELECT    COALESCE (pct.dic_name, '-')
               || '('
               || COALESCE (t.pc_name, '-')
               || ')'
          INTO l_comment
          FROM packet_content  t
               LEFT JOIN uss_ndi.v_ddn_pkt_content_tp pct
                   ON pct.dic_value = t.pc_tp
         WHERE t.pc_id = p_pc_id;

        CASE
            WHEN p_lp_tp = ikis_const.v_ddn_action_tp_mod
            THEN
                l_comment := TRIM (l_comment || ' видалено.');
            WHEN p_lp_tp = ikis_const.v_ddn_action_tp_sgn
            THEN
                l_comment := TRIM (l_comment || ' підписано.');
            WHEN p_lp_tp = ikis_const.v_ddn_action_tp_unl
            THEN
                l_comment := TRIM (l_comment || ' вивантажено з БД.');
        END CASE;

        SELECT CASE
                   WHEN NVL (t.pkt_st, '-1') <> ikis_const.v_ddn_packet_st_m
                   THEN
                          ' Стан змінено на: '
                       || (SELECT st.dic_sname
                             FROM uss_ndi.v_ddn_packet_st st
                            WHERE st.dic_value = ikis_const.v_ddn_packet_st_m)
               END
          INTO l_comment_st
          FROM DUAL d LEFT JOIN packet t ON t.pkt_id = NVL (p_pc_pkt, -1);

        l_comment := l_comment || l_comment_st;

        RETURN l_comment;
    END;

    PROCEDURE insert_packet_content (
        p_pc_pkt             packet_content.pc_pkt%TYPE,
        p_pc_tp              packet_content.pc_tp%TYPE,
        p_pc_name            packet_content.pc_name%TYPE,
        p_pc_data            packet_content.pc_data%TYPE,
        p_pc_pkt_change_wu   log_packet.lp_wu%TYPE,
        p_pc_pkt_change_dt   log_packet.lp_dt%TYPE,
        p_pc_visual_data     packet_content.pc_visual_data%TYPE:= NULL,
        p_pc_main_tag_name   packet_content.pc_main_tag_name%TYPE:= NULL,
        p_pc_data_name       packet_content.pc_data_name%TYPE:= NULL,
        p_pc_ecp_list_name   packet_content.pc_ecp_list_name%TYPE:= NULL,
        p_pc_ecp_name        packet_content.pc_ecp_name%TYPE:= NULL,
        p_pc_ecp_alg         packet_content.pc_ecp_alg%TYPE:= NULL,
        p_pc_src_entity      packet_content.pc_src_entity%TYPE:= NULL,
        p_pc_header          packet_content.pc_header%TYPE:= NULL,
        p_pc_encrypt_data    packet_content.pc_encrypt_data%TYPE:= NULL, -- 20201214
        p_pc_npc             packet_content.pc_npc%TYPE:= NULL)      -- #79230
    IS
        l_comment          log_packet.lp_comment%TYPE;
        l_pkt_content_id   NUMBER (14);
    BEGIN
        l_pkt_content_id := NULL;                      --id_packet_content(0);

        INSERT INTO packet_content (pc_id,
                                    pc_pkt,
                                    pc_src_entity,
                                    pc_tp,
                                    pc_name,
                                    pc_data,
                                    pc_main_tag_name,
                                    pc_data_name,
                                    pc_ecp_list_name,
                                    pc_ecp_name,
                                    pc_ecp_alg,
                                    pc_visual_data,
                                    pc_header,
                                    pc_encrypt_data,
                                    pc_npc)
             VALUES (l_pkt_content_id,
                     p_pc_pkt,
                     p_pc_src_entity,
                     p_pc_tp,
                     p_pc_name,
                     p_pc_data,
                     p_pc_main_tag_name,
                     p_pc_data_name,
                     p_pc_ecp_list_name,
                     p_pc_ecp_name,
                     p_pc_ecp_alg,
                     p_pc_visual_data,
                     p_pc_header,
                     p_pc_encrypt_data,
                     p_pc_npc);


        /*не логуємо підписування відповіді*/
        IF (p_pc_pkt_change_wu IS NOT NULL)
        THEN
            l_comment :=
                get_log_pc_pkt_comment (l_pkt_content_id,
                                        p_pc_pkt,
                                        ikis_const.v_ddn_action_tp_sgn);

            /* set state packet to SGN */
            RDM$PACKET.SET_PACKET_STATE (
                p_pkt_id          => p_pc_pkt,
                p_pkt_st          => ikis_const.v_ddn_packet_st_m,
                p_pkt_change_wu   => p_pc_pkt_change_wu,
                p_pkt_change_dt   => p_pc_pkt_change_dt);

            /* set log */
            RDM$LOG_PACKET.INSERT_LOG_PACKET (
                p_lp_pkt       => p_pc_pkt,
                p_lp_wu        => p_pc_pkt_change_wu,
                p_lp_dt        => p_pc_pkt_change_dt,
                p_lp_atp       => ikis_const.v_ddn_action_tp_sgn,
                p_lp_comment   => l_comment);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionRBM (
                'RDM$PACKET_CONTENT.insert_packet_content ',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE set_packet_content (
        p_set_row   IN     v_packet_content%ROWTYPE,
        p_pc_id        OUT NUMBER)
    IS
    BEGIN
           UPDATE packet_content
              SET pc_pkt = NVL (p_set_row.pc_pkt, pc_pkt),
                  pc_src_entity = NVL (p_set_row.pc_src_entity, pc_src_entity),
                  pc_tp = NVL (p_set_row.pc_tp, pc_tp),
                  pc_name = NVL (p_set_row.pc_name, pc_name),
                  pc_data = NVL (p_set_row.pc_data, pc_data),
                  pc_main_tag_name =
                      NVL (p_set_row.pc_main_tag_name, pc_main_tag_name),
                  pc_data_name = NVL (p_set_row.pc_data_name, pc_data_name),
                  pc_ecp_list_name =
                      NVL (p_set_row.pc_ecp_list_name, pc_ecp_list_name),
                  pc_ecp_name = NVL (p_set_row.pc_ecp_name, pc_ecp_name),
                  pc_ecp_alg = NVL (p_set_row.pc_ecp_alg, pc_ecp_alg),
                  pc_visual_data =
                      NVL (p_set_row.pc_visual_data, pc_visual_data),
                  pc_header = NVL (p_set_row.pc_header, pc_header),
                  pc_ecp_check = NVL (p_set_row.pc_ecp_check, pc_ecp_check),
                  pc_file_idn = NVL (p_set_row.pc_file_idn, pc_file_idn),
                  pc_encrypt_data =
                      NVL (p_set_row.pc_encrypt_data, pc_encrypt_data),
                  pc_msg = NVL (p_set_row.pc_msg, pc_msg),
                  pc_npc = NVL (p_set_row.pc_npc, pc_npc)
            WHERE pc_id = p_set_row.pc_id
        RETURNING pc_id
             INTO p_pc_id;

        IF SQL%ROWCOUNT = 0
        THEN
            INSERT INTO packet_content
                 VALUES p_set_row
              RETURNING pc_id
                   INTO p_pc_id;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionRBM (
                'RDM$PACKET_CONTENT.set_packet_content ',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END set_packet_content;


    PROCEDURE SavePacketEncryptData (
        p_pc_id             packet_content.pc_id%TYPE,
        p_pc_encrypt_data   packet_content.pc_encrypt_data%TYPE)
    IS
    --v_Ziped_Envelope blob;
    BEGIN
        --v_Ziped_Envelope := UTL_COMPRESS.Lz_Compress(Src => p_pc_encrypt_data, Quality => 8);

        UPDATE packet_content c
           SET c.pc_encrypt_data = p_pc_encrypt_data
         WHERE c.pc_id = p_pc_id;
    END;

    /* delete packet content */
    PROCEDURE delete_packet_content (
        p_pc_id              packet_content.pc_id%TYPE,
        p_pc_pkt             packet_content.pc_pkt%TYPE,
        p_pc_pkt_change_wu   log_packet.lp_wu%TYPE,
        p_pc_pkt_change_dt   log_packet.lp_dt%TYPE)
    IS
        l_comment   log_packet.lp_comment%TYPE;
    BEGIN
        l_comment :=
            get_log_pc_pkt_comment (p_pc_id,
                                    p_pc_pkt,
                                    ikis_const.v_ddn_action_tp_mod);

        DELETE FROM packet_content
              WHERE pc_id = p_pc_id;

        /* vставка логу */
        RDM$LOG_PACKET.INSERT_LOG_PACKET (
            p_lp_pkt       => p_pc_pkt,
            p_lp_wu        => p_pc_pkt_change_wu,
            p_lp_dt        => p_pc_pkt_change_dt,
            p_lp_atp       => ikis_const.v_ddn_action_tp_mod,
            p_lp_comment   => l_comment);
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionRBM (
                'RDM$PACKET_CONTENT.delete_packet_content ',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- загрузка файлов из веб интерфейса
    PROCEDURE DownloadFileContent (
        p_download_pc_id     packet_content.pc_id%TYPE,
        p_pc_pkt             log_packet.lp_pkt%TYPE,
        p_pc_pkt_change_wu   log_packet.lp_wu%TYPE,
        p_pc_pkt_change_dt   log_packet.lp_dt%TYPE)
    IS
        l_content    packet_content.pc_data%TYPE;
        l_filename   packet_content.pc_name%TYPE;
        l_comment    log_packet.lp_comment%TYPE;
    BEGIN
        SELECT pc.pc_data, pc.pc_name                          --|| '.p7s.p7e'
          INTO l_content, l_filename
          FROM packet_content pc
         WHERE pc.pc_id = p_download_pc_id;

        l_comment := 'Файл ' || l_filename || ' вивантажено з БД.';
        --  htp.p('Content-Type: application/zip; name="' || l_filename || '"');
        --  htp.p('Content-Disposition: attachment; filename="' || l_filename || '"');
        --  htp.p('Content-Length: ' || dbms_lob.getlength(l_content));
        --  htp.p('');
        --  wpg_docload.download_file(l_content);

        /* vставка логу */
        RDM$LOG_PACKET.INSERT_LOG_PACKET (
            p_lp_pkt       => p_pc_pkt,
            p_lp_wu        => p_pc_pkt_change_wu,
            p_lp_dt        => p_pc_pkt_change_dt,
            p_lp_atp       => ikis_const.v_ddn_action_tp_unl,
            p_lp_comment   => l_comment);
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionRBM (
                'RDM$PACKET_CONTENT.DownloadFileContent',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE SaveSign (p_pce_id     packet_ecp.pce_id%TYPE,
                        p_pce_pc     packet_ecp.pce_pc%TYPE,
                        p_pce_ecp    packet_ecp.pce_ecp%TYPE,
                        p_pce_info   packet_ecp.pce_info%TYPE)
    IS
    BEGIN
        IF     p_pce_ecp IS NOT NULL
           AND p_pce_info IS NOT NULL
           AND DBMS_LOB.getlength (p_pce_ecp) > 0        -- ivashchuk 20160304
        THEN
            INSERT INTO packet_ecp (pce_id,
                                    pce_pc,
                                    pce_ecp,
                                    pce_info,
                                    pce_dt,
                                    com_wu)
                SELECT NVL (p_pce_id, 0)
                           AS x_pce_id,
                       p_pce_pc,
                       p_pce_ecp,
                       p_pce_info,
                       SYSDATE,
                       SYS_CONTEXT (ikis_rbm_context.gcontext,
                                    ikis_rbm_context.guid)
                  FROM DUAL;
        ELSE
            ExceptionRBM (
                'RDM$PACKET_CONTENT.DownloadFileContent',
                   'Помилка підписання:'
                || CASE
                       WHEN p_pce_ecp IS NULL
                       THEN
                           ' файл ЕЦП відсутній'
                       WHEN DBMS_LOB.getlength (p_pce_ecp) = 0
                       THEN
                           ' файл ЕЦП порожній'
                       ELSE
                              ' p_pce_info='
                           || p_pce_info
                           || ', length(ecp)='
                           || DBMS_LOB.getlength (p_pce_ecp)
                   END);
        END IF;
    END;

    PROCEDURE DeleteSign (p_pce_id packet_ecp.pce_id%TYPE)
    IS
    BEGIN
        DELETE FROM packet_ecp
              WHERE pce_id = p_pce_id;
    END;

    PROCEDURE insert_pc2fa (
        p_pc_pkt                 packet_content.pc_pkt%TYPE,
        p_pkt_pat                packet.pkt_pat%TYPE,
        p_pkt_org                packet.pkt_org%TYPE,
        p_pc_tp                  packet_content.pc_tp%TYPE,
        p_pc_name                packet_content.pc_name%TYPE,
        p_pc_data                packet_content.pc_data%TYPE,
        p_pc_pkt_change_wu       log_packet.lp_wu%TYPE,
        p_pc_pkt_change_dt       log_packet.lp_dt%TYPE,
        p_pc_visual_data         packet_content.pc_visual_data%TYPE := NULL,
        p_pc_main_tag_name       packet_content.pc_main_tag_name%TYPE := NULL,
        p_pc_data_name           packet_content.pc_data_name%TYPE := NULL,
        p_pc_ecp_list_name       packet_content.pc_ecp_list_name%TYPE := NULL,
        p_pc_ecp_name            packet_content.pc_ecp_name%TYPE := NULL,
        p_pc_ecp_alg             packet_content.pc_ecp_alg%TYPE := NULL,
        p_pc_src_entity          packet_content.pc_src_entity%TYPE := NULL,
        p_pc_header              packet_content.pc_header%TYPE := NULL,
        p_res_code           OUT NUMBER                      -- 0 - ok, 1 -err
                                       )
    IS
        l_comment          log_packet.lp_comment%TYPE;
        l_pkt_content_id   NUMBER (14);
        l_file_idn         packet_content.pc_file_idn%TYPE;
    BEGIN
        l_pkt_content_id := id_packet_content (0);
        /*  ikis_rbm.rdm$log_packet.insert_message(p_lp_pkt => p_pc_pkt,
                   p_lp_comment => 'try to add file <tp = '||p_pc_tp
                   ||',name ='||p_pc_name||', u='||p_pc_pkt_change_wu||'>, '||dbms_lob.getlength(p_pc_data)||'b');*/
        l_file_idn :=
            ikis_sysweb.ikis_file_archive.putFile (
                p_wfs_code    =>
                    CASE p_pkt_pat
                        WHEN 3 THEN 'MILPR'
                        WHEN 13 THEN 'MILCA'
                        WHEN 21 THEN 'PPVP1'
                        WHEN 22 THEN 'PPVP1'
                        ELSE 'MIL01'
                    END,
                p_org         => p_pkt_org,
                p_filename    => p_pc_name,
                p_wu          => p_pc_pkt_change_wu,
                p_file_data   => p_pc_data);

        INSERT INTO packet_content (pc_id,
                                    pc_pkt,
                                    pc_src_entity,
                                    pc_tp,
                                    pc_name,
                                    pc_data,
                                    pc_main_tag_name,
                                    pc_data_name,
                                    pc_ecp_list_name,
                                    pc_ecp_name,
                                    pc_ecp_alg,
                                    pc_visual_data,
                                    pc_header,
                                    pc_file_idn)
             VALUES (l_pkt_content_id,
                     p_pc_pkt,
                     p_pc_src_entity,
                     p_pc_tp,
                     p_pc_name,
                     /*p_pc_data*/
                     NULL,
                     p_pc_main_tag_name,
                     p_pc_data_name,
                     p_pc_ecp_list_name,
                     p_pc_ecp_name,
                     p_pc_ecp_alg,
                     p_pc_visual_data,
                     p_pc_header,
                     l_file_idn);

        ikis_rbm.rdm$log_packet.insert_message (
            p_lp_pkt       => p_pc_pkt,
            p_lp_comment   => '&3#' || l_file_idn);
        p_res_code := 0;
    EXCEPTION
        WHEN OTHERS
        THEN
            p_res_code := 1;
            ikis_rbm.rdm$log_packet.insert_message (
                p_lp_pkt   => p_pc_pkt,
                p_lp_comment   =>
                    '&108#' || SQLERRM || DBMS_UTILITY.format_error_backtrace);
    --ExceptionRBM('RDM$PACKET_CONTENT.insert_pc2fa ', chr(10) || dbms_utility.format_error_stack || dbms_utility.format_error_backtrace);
    END insert_pc2fa;

    -- io 20230222
    PROCEDURE set_pc_header (p_pc_pkt      packet_content.pc_pkt%TYPE,
                             p_pc_header   packet_content.pc_header%TYPE)
    IS
    BEGIN
        UPDATE packet_content c
           SET c.pc_header = p_pc_header
         WHERE c.pc_pkt = p_pc_pkt;
    END;

    -- io 20231124
    PROCEDURE set_visual_data (
        p_pc_pkt           packet_content.pc_pkt%TYPE,
        p_pc_visual_data   packet_content.pc_visual_data%TYPE)
    IS
    BEGIN
        UPDATE packet_content c
           SET c.pc_visual_data = p_pc_visual_data
         WHERE c.pc_pkt = p_pc_pkt;
    END;
BEGIN
    -- Initialization
    NULL;
END RDM$PACKET_CONTENT;
/