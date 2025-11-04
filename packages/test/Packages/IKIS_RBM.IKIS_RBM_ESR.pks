/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.IKIS_RBM_ESR
IS
    -- Author  : ivashchuk
    -- Created : 08.12.2020

    PROCEDURE set_pkt_received (p_pkt_id NUMBER, p_recipient_code VARCHAR2);

    PROCEDURE GenPaketsFromTMPTable;

    --  #67448 Процедура перевірки та встановлення статусу "видалено" ресєтру по ПД в ПЕОД
    -- 1- виконано, 0 - не виконано
    PROCEDURE del_pkt81 (p_pkt_id NUMBER, p_result OUT NUMBER);
END ikis_rbm_esr;
/


GRANT EXECUTE ON IKIS_RBM.IKIS_RBM_ESR TO II01RC_RBM_ESR
/

GRANT EXECUTE ON IKIS_RBM.IKIS_RBM_ESR TO USS_ESR
/


/* Formatted on 8/12/2025 6:10:50 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.IKIS_RBM_ESR
IS
    -- Author  : OIVASHCHUK

    -- зміна статусу на "Отримано банком"
    PROCEDURE set_pkt_received (p_pkt_id NUMBER, p_recipient_code VARCHAR2)
    IS
        l_cnt   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_cnt
          FROM packet p
         WHERE     p.pkt_st IN ('NVP', 'SND')
               AND p.pkt_id = p_pkt_id
               AND pkt_rm > 0
               AND EXISTS
                       (SELECT 1
                          FROM ikis_rbm.recipient
                         WHERE     pkt_rec = rec_id
                               AND rec_code = p_recipient_code
                               AND rec_tp != 'IC');

        IF l_cnt = 1
        THEN
            rdm$packet.Set_Packet_State (p_Pkt_Id          => p_pkt_id,
                                         p_Pkt_St          => 'RCV',
                                         p_Pkt_Change_Wu   => NULL,
                                         p_Pkt_Change_Dt   => SYSDATE);
        END IF;
    END set_pkt_received;


    PROCEDURE GenPaketsFromTMPTable
    IS
        l_pkt          packet.pkt_id%TYPE;
        l_pkt_st       packet.pkt_st%TYPE;
        l_sysdate      DATE := TRUNC (SYSDATE);
        l_mil2fin_on   VARCHAR2 (10);
        l_cnt          NUMBER;
        l_rm_id        NUMBER;
    BEGIN
        FOR cc IN (SELECT * FROM tmp_exchangefiles_m3)
        LOOP
            SELECT MAX (rm_id)
              INTO l_rm_id
              FROM recipient_mail
             WHERE rm_rec = cc.ef_rec AND rm_st = 'A' AND com_org = 28000;

            l_pkt :=
                ikis_rbm.RDM$PACKET.insert_packet (
                    CASE
                        WHEN cc.ef_main_tag_name = 'rv2pd_list'
                        THEN
                            81
                        WHEN cc.ef_main_tag_name = 'post_rv2pd_answer'
                        THEN
                            82
                        WHEN cc.ef_main_tag_name = 'post_payment_reply'
                        THEN
                            103
                        WHEN cc.ef_main_tag_name = 'post_convert_answer'
                        THEN
                            102
                        WHEN cc.ef_main_tag_name = 'post_pd_return'
                        THEN
                            83
                    END,
                    --8,
                    /* case
                       when cc.ef_main_tag_name = 'rv2pd_list' then 8
                       when cc.ef_main_tag_name = 'post_rv2pd_answer' then 8
                       when cc.ef_main_tag_name = 'post_payment_reply' then 4
                       when cc.ef_main_tag_name = 'post_convert_answer' then 4
                       when cc.ef_main_tag_name = 'post_pd_return' then 8
                     end*/
                    101,
                    cc.com_org,
                    'N',
                    cc.com_wu,
                    SYSDATE,
                    NULL,
                    NULL,
                    cc.ef_rec,
                    CASE
                        WHEN cc.ef_main_tag_name = 'rv2pd_list' THEN l_rm_id
                    END);
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
                cc.ef_header,
                cc.ef_encr_blob);

            -- зв'язати дану відповідь з пакетом запиту!
            IF     l_pkt > 0
               AND cc.ef_main_tag_name IN
                       ('post_payment_reply',
                        'post_convert_answer',
                        'post_rv2pd_answer')
            THEN
                ikis_rbm.rdm$packet.insert_packet_link (
                    p_Pkt_prev   => cc.ef_pkt,                 -- v_pl_pkt_out
                    p_Pkt_id     => l_pkt                       -- v_pl_pkt_in
                                         );


                -- set_pkt_received(p_pkt_id => cc.ef_pkt, p_recipient_code => '');

                /*      select count(1) into l_cnt
                      from packet p
                      where p.pkt_st in ('NVP', 'SND')
                        and p.pkt_id = cc.ef_pkt
                        and pkt_rm > 0;*/

                SELECT pkt_st
                  INTO l_pkt_st
                  FROM packet p
                 WHERE 1 = 1 AND p.pkt_id = cc.ef_pkt AND pkt_rm > 0;

                IF l_pkt_st IN ('NVP', 'SND')
                THEN
                    rdm$packet.Set_Packet_State (p_Pkt_Id          => cc.ef_pkt,
                                                 p_Pkt_St          => 'RCV',
                                                 p_Pkt_Change_Wu   => NULL,
                                                 p_Pkt_Change_Dt   => SYSDATE);
                /*  io 20230219   MG ANS - Отримано відповідь  (після завантаження КВ-1/2) ===НЕ НУЖЕН    elsif l_pkt_st  in ('RCV') then
                       rdm$packet.Set_Packet_State(
                                              p_Pkt_Id        => cc.ef_pkt,
                                              p_Pkt_St        => 'ANS',
                                              p_Pkt_Change_Wu => null,
                                              p_Pkt_Change_Dt => sysdate);*/
                END IF;
            END IF;

            /*   update tmp_exchangefiles_m3 t
               set t.ef_kv_pkt = l_pkt
               where t.ef_id = cc.ef_id;*/

            UPDATE tmp_exchangefiles_m3 t
               SET t.ef_pkt = l_pkt
             WHERE     t.ef_id = cc.ef_id
                   AND t.ef_main_tag_name IN ('rv2pd_list', 'post_pd_return');

            UPDATE tmp_exchangefiles_m3 t
               SET t.ef_kv_pkt = l_pkt
             WHERE     t.ef_id = cc.ef_id
                   AND t.ef_main_tag_name IN
                           ('post_rv2pd_answer',
                            'post_payment_reply',
                            'post_convert_answer');
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'ikis_rbm_esr.GenPaketsFromTMPTable:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;

    --  #67448 Процедура перевірки та встановлення статусу "видалено" ресєтру по ПД в ПЕОД
    -- 1- виконано, 0 - не виконано
    PROCEDURE del_pkt81 (p_pkt_id NUMBER, p_result OUT NUMBER)
    IS
        l_cnt   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_cnt
          FROM packet p
         WHERE     p.pkt_st NOT IN ('NVP', 'SND', 'RCV')
               AND p.pkt_id = p_pkt_id
               AND pkt_pat = 81;

        IF l_cnt = 1
        THEN
            rdm$packet.Set_Packet_State (p_Pkt_Id          => p_pkt_id,
                                         p_Pkt_St          => 'D',
                                         p_Pkt_Change_Wu   => NULL,
                                         p_Pkt_Change_Dt   => SYSDATE);
            p_result := 1;
        ELSE
            p_result := 0;
        END IF;
    END del_pkt81;
END ikis_rbm_esr;
/