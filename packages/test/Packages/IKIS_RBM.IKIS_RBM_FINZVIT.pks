/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.IKIS_RBM_FINZVIT
IS
    -- Author  : ivashchuk
    -- Created : 08.12.2020

    PROCEDURE set_pkt_received (p_pkt_id NUMBER, p_recipient_code VARCHAR2);
END ikis_rbm_finzvit;
/


GRANT EXECUTE ON IKIS_RBM.IKIS_RBM_FINZVIT TO IKIS_FINZVIT
/


/* Formatted on 8/12/2025 6:10:50 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.IKIS_RBM_FINZVIT
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
            rdm$packet.Set_Packet_State (v_Pkt_Id          => p_pkt_id,
                                         v_Pkt_St          => 'RCV',
                                         v_Pkt_Change_Wu   => NULL,
                                         v_Pkt_Change_Dt   => SYSDATE);
        END IF;
    END set_pkt_received;
END ikis_rbm_finzvit;
/