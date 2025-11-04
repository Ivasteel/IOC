/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.RDM$PACKET
IS
    -- Author  : ivashchuk
    -- Created : 06.07.2015

    FUNCTION Insert_Packet (            --  pkt_id        NUMBER(14) not null,
                            p_Pkt_Pat         NUMBER,
                            p_Pkt_Nes         NUMBER,
                            p_Pkt_Org         NUMBER,
                            p_Pkt_St          VARCHAR2,
                            p_Pkt_Create_Wu   NUMBER,
                            p_Pkt_Create_Dt   DATE,
                            p_Pkt_Change_Wu   NUMBER,
                            p_Pkt_Change_Dt   DATE,
                            p_Pkt_Rec         NUMBER,
                            p_Pkt_Rm          NUMBER DEFAULT NULL)
        RETURN NUMBER;

    PROCEDURE Insert_Packet (p_Pkt_Prev        NUMBER DEFAULT -1,
                             p_Pkt_Pat         NUMBER,
                             p_Pkt_Nes         NUMBER,
                             p_Pkt_Org         NUMBER,
                             p_Pkt_St          VARCHAR2,
                             p_Pkt_Create_Wu   NUMBER,
                             p_Pkt_Create_Dt   DATE,
                             p_Pkt_Change_Wu   NUMBER,
                             p_Pkt_Change_Dt   DATE DEFAULT NULL,
                             p_Pkt_Rec         NUMBER);

    PROCEDURE Update_Packet (p_Pkt_Id          NUMBER,
                             p_Pkt_Pat         NUMBER,
                             p_Pkt_Nes         NUMBER,
                             p_Pkt_Org         NUMBER,
                             p_Pkt_Change_Wu   NUMBER,
                             p_Pkt_Change_Dt   DATE,
                             p_Pkt_Rec         NUMBER);

    PROCEDURE Delete_Packet (p_Pkt_Id          NUMBER,
                             p_Pkt_Change_Wu   NUMBER,
                             p_Pkt_Change_Dt   DATE);

    PROCEDURE Set_Packet_State (p_Pkt_Id          NUMBER,
                                p_Pkt_St          VARCHAR2,
                                p_Pkt_Change_Wu   NUMBER,
                                p_Pkt_Change_Dt   DATE);

    -- o.ivashchuk #14351 20160219
    -- Кількість унікальних ЄЦП вмісту пакета
    FUNCTION Get_Packet_Ecp_Count (p_Pkt_Id NUMBER)
        RETURN NUMBER;

    -- Для використання в IC
    PROCEDURE Insert_Pkt_Ic (
        p_Pkt_Pat                Packet.Pkt_Pat%TYPE,
        p_Pkt_Nes                Packet.Pkt_Nes%TYPE,
        p_Pkt_Org                Packet.Pkt_Org%TYPE := NULL,
        p_Pkt_Create_Wu          Packet.Pkt_Create_Wu%TYPE := NULL,
        p_Pkt_Rec_Code           Recipient.Rec_Code%TYPE,
        p_Pc_Tp                  Packet_Content.Pc_Tp%TYPE,
        p_Pc_Name                Packet_Content.Pc_Name%TYPE,
        p_Pc_Data                Packet_Content.Pc_Data%TYPE,
        p_Pc_Visual_Data         Packet_Content.Pc_Visual_Data%TYPE := NULL,
        p_Pc_Main_Tag_Name       Packet_Content.Pc_Main_Tag_Name%TYPE := NULL,
        p_Pc_Data_Name           Packet_Content.Pc_Data_Name%TYPE := NULL,
        p_Pc_Ecp_List_Name       Packet_Content.Pc_Ecp_List_Name%TYPE := NULL,
        p_Pc_Ecp_Name            Packet_Content.Pc_Ecp_Name%TYPE := NULL,
        p_Pc_Ecp_Alg             Packet_Content.Pc_Ecp_Alg%TYPE := NULL,
        p_Pc_Src_Entity          Packet_Content.Pc_Src_Entity%TYPE := NULL,
        p_Pc_Header              Packet_Content.Pc_Header%TYPE := NULL,
        p_Pc_Ecp                 Packet_Ecp.Pce_Ecp%TYPE := NULL,
        p_Pkt_Id             OUT Packet.Pkt_Id%TYPE);

    -- Для використання в IC
    PROCEDURE Update_Pkt_Ic (
        p_Pkt_Id             Packet.Pkt_Id%TYPE,
        p_Pkt_Pat            Packet.Pkt_Pat%TYPE,
        p_Pkt_Nes            Packet.Pkt_Nes%TYPE,
        p_Pkt_Org            Packet.Pkt_Org%TYPE:= NULL,
        p_Pkt_Create_Wu      Packet.Pkt_Create_Wu%TYPE:= NULL,
        p_Pkt_Rec_Code       Recipient.Rec_Code%TYPE,
        p_Pc_Tp              Packet_Content.Pc_Tp%TYPE,
        p_Pc_Name            Packet_Content.Pc_Name%TYPE,
        p_Pc_Data            Packet_Content.Pc_Data%TYPE,
        p_Pc_Visual_Data     Packet_Content.Pc_Visual_Data%TYPE:= NULL,
        p_Pc_Main_Tag_Name   Packet_Content.Pc_Main_Tag_Name%TYPE:= NULL,
        p_Pc_Data_Name       Packet_Content.Pc_Data_Name%TYPE:= NULL,
        p_Pc_Ecp_List_Name   Packet_Content.Pc_Ecp_List_Name%TYPE:= NULL,
        p_Pc_Ecp_Name        Packet_Content.Pc_Ecp_Name%TYPE:= NULL,
        p_Pc_Ecp_Alg         Packet_Content.Pc_Ecp_Alg%TYPE:= NULL,
        p_Pc_Src_Entity      Packet_Content.Pc_Src_Entity%TYPE:= NULL,
        p_Pc_Header          Packet_Content.Pc_Header%TYPE:= NULL,
        p_Pc_Ecp             Packet_Ecp.Pce_Ecp%TYPE:= NULL);

    --Создание задания на отпрвку пакета по почте
    PROCEDURE Send_Pkt_Email (p_Pkt_Id Packet.Pkt_Id%TYPE);

    --Обновление статуса пакетов, которые отправляеются на e-mail
    PROCEDURE refresh_pkt_st_by_mail;

    PROCEDURE Insert_Packet_Link (p_Pkt_Prev   NUMBER DEFAULT -1,
                                  p_Pkt_Id     NUMBER);

    FUNCTION Init_Packet (p_Rq_Id           NUMBER,
                          p_Pkt_Pat         NUMBER,
                          p_Pkt_Nes         NUMBER,
                          p_Pkt_Org         NUMBER,
                          p_Pkt_Create_Wu   NUMBER,
                          p_Pkt_Change_Wu   NUMBER,
                          p_Pkt_Rec         NUMBER)
        RETURN NUMBER;
END Rdm$packet;
/


GRANT EXECUTE ON IKIS_RBM.RDM$PACKET TO DNET_PROXY
/

GRANT EXECUTE ON IKIS_RBM.RDM$PACKET TO IC_WORKER
/

GRANT EXECUTE ON IKIS_RBM.RDM$PACKET TO II01RC_RBMWEB_COMMON
/

GRANT EXECUTE ON IKIS_RBM.RDM$PACKET TO II01RC_RBM_ESR
/

GRANT EXECUTE ON IKIS_RBM.RDM$PACKET TO IKIS_PERSON
/

GRANT EXECUTE ON IKIS_RBM.RDM$PACKET TO PORTAL_PROXY
/

GRANT EXECUTE ON IKIS_RBM.RDM$PACKET TO USS_ESR
/

GRANT EXECUTE ON IKIS_RBM.RDM$PACKET TO USS_VISIT
/


/* Formatted on 8/12/2025 6:10:51 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.RDM$PACKET
IS
    -- Author  : OIVASHCHUK

    /* Purpose : generate pkt_id */
    FUNCTION get_pkt_id
        RETURN NUMBER
    IS
        l_curval   NUMBER;
    BEGIN
        SELECT SQ_ID_PACKET.NEXTVAL INTO l_curval FROM DUAL;

        RETURN (l_curval);
    END get_pkt_id;

    /* get log content */
    FUNCTION get_log_pkt_comment (p_Pkt_id    NUMBER,
                                  p_Pkt_pat   VARCHAR2,
                                  p_Pkt_nes   NUMBER,
                                  p_Pkt_org   NUMBER,
                                  p_Pkt_st    VARCHAR2,
                                  p_Pkt_rec   NUMBER,
                                  p_lp_tp     VARCHAR2)
        RETURN VARCHAR2
    IS
        l_comment   log_packet.lp_comment%TYPE;
    BEGIN
        l_comment := NULL;

        /* content */
        SELECT /*  case when nvl(t.pkt_pat, -1) <> p_Pkt_pat then 'тип пакета ' ||
                     (select pat.pat_name  from uss_ndi.v_ndi_packet_type pat where pat.pat_id = p_Pkt_pat) || ',' || chr(10)
                  else Null end ||
                 case when nvl(t.pkt_nes, -1) <> p_Pkt_nes then 'підсистема ' ||
                     (select nes.nes_name from uss_ndi.v_ndi_exchange_system nes where nes.nes_id = p_Pkt_nes) || ',' || chr(10)
                  else Null end ||
                 case when nvl(t.pkt_org, -1) <> p_Pkt_org then  'орган ПФУ ' || (select o.org_name from ikis_sys.v_opfu o where o.org_id = p_Pkt_org) || ','  || chr(10)
                  else Null end ||
                 case when nvl(t.pkt_rec, -1) <> nvl(p_Pkt_rec, -1) then 'адресат ' ||  (select r.rec_name from recipient r where r.rec_id = p_Pkt_rec)  || ','   || chr(10)
                  else Null end ||*/
               CASE
                   WHEN NVL (t.pkt_st, '-1') <> p_Pkt_st
                   THEN
                          'статус: '
                       || (SELECT st.dic_sname
                             FROM uss_ndi.v_ddn_packet_st st
                            WHERE st.dic_value = p_Pkt_st)
                       || ','
                       || CHR (10)
                   ELSE
                       NULL
               END    AS cmt
          INTO l_comment
          FROM DUAL d LEFT JOIN packet t ON t.pkt_id = NVL (p_Pkt_id, -1);

        CASE
            WHEN p_lp_tp = ikis_const.v_ddn_action_tp_mod
            THEN
                l_comment := TRIM (l_comment);
            WHEN p_lp_tp = ikis_const.v_ddn_action_tp_crt
            THEN
                l_comment := TRIM (l_comment);
        END CASE;

        RETURN l_comment;
    END;

    /*   ------------------------    insert packet ---------------------------------*/
    FUNCTION insert_packet (p_Pkt_pat         NUMBER,
                            p_Pkt_nes         NUMBER,
                            p_Pkt_org         NUMBER,
                            p_Pkt_st          VARCHAR2,
                            p_Pkt_create_wu   NUMBER,
                            p_Pkt_create_dt   DATE,
                            p_Pkt_change_wu   NUMBER,
                            p_Pkt_change_dt   DATE,
                            p_Pkt_rec         NUMBER,
                            p_Pkt_rm          NUMBER DEFAULT NULL)
        RETURN NUMBER
    IS
        l_pkt_id    NUMBER (14);
        l_comment   log_packet.lp_comment%TYPE;
    BEGIN
        l_pkt_id := get_pkt_id;
        l_comment :=
            get_log_pkt_comment (l_pkt_id,
                                 p_Pkt_pat,
                                 p_Pkt_nes,
                                 p_Pkt_org,
                                 p_Pkt_st,
                                 p_Pkt_rec,
                                 ikis_const.v_ddn_action_tp_crt);

        /*  insert  packet*/
        INSERT INTO packet (pkt_id,
                            pkt_pat,
                            pkt_nes,
                            pkt_org,
                            pkt_st,
                            pkt_create_wu,
                            pkt_create_dt,
                            pkt_change_wu,
                            pkt_change_dt,
                            pkt_rec,
                            pkt_rm)
             VALUES (l_pkt_id,
                     p_Pkt_pat,
                     p_Pkt_nes,
                     p_Pkt_org,
                     p_Pkt_st,
                     p_Pkt_create_wu,
                     p_Pkt_create_dt,
                     p_Pkt_change_wu,
                     p_Pkt_change_dt,
                     p_Pkt_rec,
                     p_Pkt_rm);

        /* set log */
        Rdm$log_Packet.insert_log_packet (
            p_lp_pkt       => l_pkt_id,
            p_lp_wu        => p_Pkt_create_wu,
            p_lp_dt        => p_Pkt_create_dt,
            p_lp_atp       => ikis_const.v_ddn_action_tp_crt,
            p_lp_comment   => l_comment);

        RETURN l_pkt_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionRBM (
                'RDM$PACKET.insert_packet ',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    /*   ------------------------    insert packet ---------------------------------*/
    PROCEDURE insert_packet (p_Pkt_prev        NUMBER DEFAULT -1,
                             p_Pkt_pat         NUMBER,
                             p_Pkt_nes         NUMBER,
                             p_Pkt_org         NUMBER,
                             p_Pkt_st          VARCHAR2,
                             p_Pkt_create_wu   NUMBER,
                             p_Pkt_create_dt   DATE,
                             p_Pkt_change_wu   NUMBER,
                             p_Pkt_change_dt   DATE DEFAULT NULL,
                             p_Pkt_rec         NUMBER)
    IS
        l_pkt_id     NUMBER (14);
        l_pkt_prev   NUMBER (14);
    BEGIN
        l_pkt_id :=
            insert_packet (p_Pkt_pat,
                           p_Pkt_nes,
                           p_Pkt_org,
                           p_Pkt_st,
                           p_Pkt_create_wu,
                           p_Pkt_create_dt,
                           p_Pkt_change_wu,
                           p_Pkt_change_dt,
                           p_Pkt_rec);

        -- на даний момент для вхідного пакету(in) має бути відповідний вихідний(out)
        -- надалі в залежності від типу пакету можливі інші варіанти
        SELECT NVL (MAX (pkt.pkt_id), 0)
          INTO l_pkt_prev
          FROM packet pkt
         WHERE pkt.pkt_id = p_Pkt_prev;

        IF l_pkt_prev > 0
        THEN
            RDM$PACKET_LINKS.insert_packet_LINKS (
                p_pl_pkt_in    => l_pkt_id,
                p_pl_pkt_out   => l_pkt_prev);
        ELSE
            NULL;                                     -- нотифікація? помилка?
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionRBM (
                'RDM$PACKET.insert_packet ',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    /*   ------------------------    update packet ---------------------------------*/
    PROCEDURE update_packet (p_Pkt_id          NUMBER,
                             p_Pkt_pat         NUMBER,
                             p_Pkt_nes         NUMBER,
                             p_Pkt_org         NUMBER,
                             p_Pkt_change_wu   NUMBER,
                             p_Pkt_change_dt   DATE,
                             p_Pkt_rec         NUMBER)
    IS
        l_comment   log_packet.lp_comment%TYPE;
    BEGIN
        l_comment :=
            get_log_pkt_comment (p_Pkt_id,
                                 p_Pkt_pat,
                                 p_Pkt_nes,
                                 p_Pkt_org,
                                 ikis_const.v_ddn_packet_st_m,
                                 p_Pkt_rec,
                                 ikis_const.v_ddn_action_tp_mod);

        /* update packet */
        UPDATE packet
           SET pkt_pat = p_Pkt_pat,
               pkt_nes = p_Pkt_nes,
               pkt_org = p_Pkt_org,
               pkt_st = ikis_const.v_ddn_packet_st_m,
               pkt_change_wu = p_Pkt_change_wu,
               pkt_change_dt = p_Pkt_change_dt,
               pkt_rec = p_Pkt_rec
         WHERE pkt_id = p_Pkt_id;

        /* log */
        IF l_comment != ikis_const.txt_v_ddn_action_tp_mod
        THEN
            Rdm$log_Packet.insert_log_packet (
                p_lp_pkt       => p_Pkt_id,
                p_lp_wu        => p_Pkt_change_wu,
                p_lp_dt        => p_Pkt_change_dt,
                p_lp_atp       => ikis_const.v_ddn_action_tp_mod,
                p_lp_comment   => l_comment);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionRBM (
                'RDM$PACKET.insert_packet ',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    /*   ------------------------    delete packet ---------------------------------*/
    PROCEDURE delete_packet (p_Pkt_id          NUMBER,
                             p_Pkt_change_wu   NUMBER,
                             p_Pkt_change_dt   DATE)
    IS
    BEGIN
        UPDATE packet
           SET pkt_st = ikis_const.v_ddn_packet_st_d,
               pkt_change_wu = p_Pkt_change_wu,
               pkt_change_dt = p_Pkt_change_dt
         WHERE pkt_id = p_Pkt_id;

        /* log */
        Rdm$log_Packet.insert_log_packet (
            p_lp_pkt   => p_Pkt_id,
            p_lp_wu    => p_Pkt_change_wu,
            p_lp_dt    => p_Pkt_change_dt,
            p_lp_atp   => ikis_const.v_ddn_action_tp_mod,
            p_lp_comment   =>
                'Стан змінено на ' || ikis_const.txt_v_ddn_packet_st_d);
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionRBM (
                'RDM$PACKET.insert_packet ',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    /*   ------------------------    set packet state ---------------------------------*/
    PROCEDURE set_packet_state (p_Pkt_id          NUMBER,
                                p_Pkt_st          VARCHAR2,
                                p_Pkt_change_wu   NUMBER,
                                p_Pkt_change_dt   DATE)
    IS
        l_st_name   uss_ndi.v_ddn_packet_st.dic_sname%TYPE;
    BEGIN
        UPDATE packet
           SET pkt_st = p_Pkt_st,
               pkt_change_wu = p_Pkt_change_wu,
               pkt_change_dt = p_Pkt_change_dt
         WHERE pkt_id = p_Pkt_id;

        SELECT st.dic_sname
          INTO l_st_name
          FROM uss_ndi.v_ddn_packet_st st
         WHERE st.dic_value = p_Pkt_st;

        /* set log */
        Rdm$log_Packet.insert_log_packet (
            p_lp_pkt   => p_Pkt_id,
            p_lp_wu    => p_Pkt_change_wu,
            p_lp_dt    => NVL (p_Pkt_change_dt, SYSDATE),
            p_lp_atp   =>
                CASE
                    WHEN p_Pkt_st IN ('D', 'SGN', 'NVP') THEN p_Pkt_st
                    ELSE 'PRCS'
                END,
            p_lp_comment   =>
                CASE
                    WHEN p_Pkt_st IN ('D', 'SGN', 'NVP') THEN NULL
                    ELSE 'статус: ' || l_st_name
                END);
    /*  if p_Pkt_st in ( 'SND', 'RCV') then   --  #64722 oivashchuk 20201208  RCV
        Rdm$log_Packet.insert_log_packet(p_lp_pkt     => p_Pkt_id,
                                         p_lp_wu      => p_Pkt_change_wu,
                                         p_lp_dt      => nvl(p_Pkt_change_dt, sysdate),
                                         p_lp_atp     => ikis_const.V_DDN_ACTION_TP_PRCS,
                                         p_lp_comment => p_Pkt_st\*'SND'*\);
      end if;

      if p_Pkt_st in ('RCV') then   --  #64722 oivashchuk 20201208  RCV
        begin
          \*ikis_finzvit.FINZVIT_BANKIR.SetPayrollStRbm*\
          ikis_finzvit.SetPayrollSt4Rbm(p_pkt_id => p_Pkt_id,
                                        p_pkt_st => p_Pkt_st);
        exception
          when others then
              Rdm$log_Packet.insert_log_packet(p_lp_pkt     => p_Pkt_id,
                                               p_lp_wu      => null,
                                               p_lp_dt      => sysdate,
                                               p_lp_atp     => ikis_const.V_DDN_ACTION_TP_PRCS,
                                               p_lp_comment => substr('ikis_finzvit: '||dbms_utility.format_error_stack || dbms_utility.format_error_backtrace, 1,500));
           ----ExceptionRBM('RDM$PACKET.set_packet_state ', chr(10) || dbms_utility.format_error_stack || dbms_utility.format_error_backtrace);
        end;
      end if;*/
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionRBM (
                'RDM$PACKET.set_packet_state ',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- o.ivashchuk #14351 20160219
    -- Кількість унікальних ЄЦП вмісту пакета
    FUNCTION get_packet_ecp_count (p_Pkt_id NUMBER)
        RETURN NUMBER
    IS
        l_pc_ecp_cnt   NUMBER;
    BEGIN
        SELECT COUNT (DISTINCT DBMS_CRYPTO.HASH (pce_ecp, 2)) -- DBMS_CRYPTO.HASH_MD5
          INTO l_pc_ecp_cnt
          FROM packet_content JOIN packet_ecp ee ON pc_id = pce_pc
         WHERE     pc_pkt = p_Pkt_id
               AND pce_ecp IS NOT NULL
               AND DBMS_LOB.getlength (pce_ecp) > 0;

        RETURN l_pc_ecp_cnt;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionRBM (
                'RDM$PACKET.get_packet_ecp_count ',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    /*   ------------------------    insert packet ---------------------------------*/
    -- Для використання в IC
    PROCEDURE insert_pkt_ic (
        p_pkt_pat                packet.pkt_pat%TYPE,
        p_pkt_nes                packet.pkt_nes%TYPE,
        p_pkt_org                packet.pkt_org%TYPE := NULL,
        p_pkt_create_wu          packet.pkt_create_wu%TYPE := NULL,
        p_pkt_rec_code           recipient.rec_code%TYPE,
        p_pc_tp                  packet_content.pc_tp%TYPE,
        p_pc_name                packet_content.pc_name%TYPE,
        p_pc_data                packet_content.pc_data%TYPE,
        p_pc_visual_data         packet_content.pc_visual_data%TYPE := NULL,
        p_pc_main_tag_name       packet_content.pc_main_tag_name%TYPE := NULL,
        p_pc_data_name           packet_content.pc_data_name%TYPE := NULL,
        p_pc_ecp_list_name       packet_content.pc_ecp_list_name%TYPE := NULL,
        p_pc_ecp_name            packet_content.pc_ecp_name%TYPE := NULL,
        p_pc_ecp_alg             packet_content.pc_ecp_alg%TYPE := NULL,
        p_pc_src_entity          packet_content.pc_src_entity%TYPE := NULL,
        p_pc_header              packet_content.pc_header%TYPE := NULL,
        p_pc_ecp                 packet_ecp.pce_ecp%TYPE := NULL,
        p_pkt_id             OUT packet.pkt_id%TYPE)
    IS
        l_pkt_id   NUMBER (14);
        l_rec_id   recipient.rec_id%TYPE;
        l_pc_id    packet_content.pc_id%TYPE;
    BEGIN
        SELECT rec_id
          INTO l_rec_id
          FROM recipient
         WHERE rec_code = p_pkt_rec_code;

        l_pkt_id :=
            insert_packet (p_Pkt_pat         => p_pkt_pat,
                           p_Pkt_nes         => p_pkt_nes,
                           p_Pkt_org         => p_pkt_org,
                           p_Pkt_st          => 'N',
                           p_Pkt_create_wu   => p_pkt_create_wu,
                           p_Pkt_create_dt   => SYSDATE,
                           p_Pkt_change_wu   => NULL,
                           p_Pkt_change_dt   => NULL,
                           p_Pkt_rec         => l_rec_id);

        rdm$packet_content.insert_packet_content (
            p_pc_pkt             => l_pkt_id,
            p_pc_tp              => p_pc_tp,
            p_pc_name            => p_pc_name,
            p_pc_data            => p_pc_data,
            p_pc_pkt_change_wu   => p_pkt_create_wu,
            p_pc_pkt_change_dt   => SYSDATE,
            p_pc_visual_data     => p_pc_visual_data,
            p_pc_main_tag_name   => p_pc_main_tag_name,
            p_pc_data_name       => p_pc_data_name,
            p_pc_ecp_list_name   => p_pc_ecp_list_name,
            p_pc_ecp_name        => p_pc_ecp_name,
            p_pc_ecp_alg         => p_pc_ecp_alg,
            p_pc_src_entity      => p_pc_src_entity,
            p_pc_header          => p_pc_header);
        p_pkt_id := l_pkt_id;

        SELECT pc_id
          INTO l_pc_id
          FROM packet_content pc
         WHERE pc_pkt = l_pkt_id;

        IF     l_pc_id IS NOT NULL
           AND p_pc_ecp IS NOT NULL
           AND DBMS_LOB.getlength (p_pc_ecp) > 0
        THEN
            INSERT INTO packet_ecp (pce_id,
                                    pce_pc,
                                    pce_ecp,
                                    pce_info,
                                    pce_dt,
                                    com_wu)
                SELECT 0, l_pc_id, p_pc_ecp, NULL, SYSDATE, NULL FROM DUAL;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionRBM (
                'RDM$PACKET.insert_pkt_ic <' || p_pkt_rec_code || '> ',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END insert_pkt_ic;

    -- Для використання в IC
    PROCEDURE update_pkt_ic (
        p_pkt_id             packet.pkt_id%TYPE,
        p_pkt_pat            packet.pkt_pat%TYPE,
        p_pkt_nes            packet.pkt_nes%TYPE,
        p_pkt_org            packet.pkt_org%TYPE:= NULL,
        p_pkt_create_wu      packet.pkt_create_wu%TYPE:= NULL,
        p_pkt_rec_code       recipient.rec_code%TYPE,
        p_pc_tp              packet_content.pc_tp%TYPE,
        p_pc_name            packet_content.pc_name%TYPE,
        p_pc_data            packet_content.pc_data%TYPE,
        p_pc_visual_data     packet_content.pc_visual_data%TYPE:= NULL,
        p_pc_main_tag_name   packet_content.pc_main_tag_name%TYPE:= NULL,
        p_pc_data_name       packet_content.pc_data_name%TYPE:= NULL,
        p_pc_ecp_list_name   packet_content.pc_ecp_list_name%TYPE:= NULL,
        p_pc_ecp_name        packet_content.pc_ecp_name%TYPE:= NULL,
        p_pc_ecp_alg         packet_content.pc_ecp_alg%TYPE:= NULL,
        p_pc_src_entity      packet_content.pc_src_entity%TYPE:= NULL,
        p_pc_header          packet_content.pc_header%TYPE:= NULL,
        p_pc_ecp             packet_ecp.pce_ecp%TYPE:= NULL)
    IS
        l_rec_id     recipient.rec_id%TYPE;
        l_pc_id      packet_content.pc_id%TYPE;
        l_pc_cnt     NUMBER;
        l_res_code   NUMBER;
    BEGIN
        SELECT rec_id
          INTO l_rec_id
          FROM recipient
         WHERE rec_code = p_pkt_rec_code;

        UPDATE packet
           SET pkt_pat = p_pkt_pat,
               pkt_nes = p_pkt_nes,
               pkt_org = p_pkt_org,
               --pkt_st = 'N',
               pkt_create_wu = p_pkt_create_wu,
               pkt_create_dt = SYSDATE,
               pkt_change_wu = NULL,
               pkt_change_dt = NULL,
               pkt_rec = l_rec_id
         WHERE pkt_id = p_pkt_id;

        ikis_rbm.rdm$log_packet.insert_message (p_lp_pkt       => p_pkt_id,
                                                p_lp_comment   => '&2');

        rdm$packet_content.insert_pc2fa (
            p_pc_pkt             => p_pkt_id,
            p_pkt_pat            => p_pkt_pat,
            p_pkt_org            => p_pkt_org,
            p_pc_tp              => p_pc_tp,
            p_pc_name            => p_pc_name,
            p_pc_data            => p_pc_data,
            p_pc_pkt_change_wu   => p_pkt_create_wu,
            p_pc_pkt_change_dt   => SYSDATE,
            p_pc_visual_data     => p_pc_visual_data,
            p_pc_main_tag_name   => p_pc_main_tag_name,
            p_pc_data_name       => p_pc_data_name,
            p_pc_ecp_list_name   => p_pc_ecp_list_name,
            p_pc_ecp_name        => p_pc_ecp_name,
            p_pc_ecp_alg         => p_pc_ecp_alg,
            p_pc_src_entity      => p_pc_src_entity,
            p_pc_header          => p_pc_header,
            p_res_code           => l_res_code);

        SELECT COUNT (1), MAX (pc_id)
          INTO l_pc_cnt, l_pc_id
          FROM packet_content pc
         WHERE pc_pkt = p_pkt_id;

        --ikis_rbm.rdm$log_packet.insert_message(p_lp_pkt => p_pkt_id,  p_lp_comment => '&3');

        IF     l_pc_cnt = 1
           AND l_pc_id IS NOT NULL
           AND p_pc_ecp IS NOT NULL
           AND DBMS_LOB.getlength (p_pc_ecp) > 0
        THEN
            INSERT INTO packet_ecp (pce_id,
                                    pce_pc,
                                    pce_ecp,
                                    pce_info,
                                    pce_dt,
                                    com_wu)
                SELECT 0, l_pc_id, p_pc_ecp, NULL, SYSDATE, NULL FROM DUAL;

            ikis_rbm.rdm$log_packet.insert_message (p_lp_pkt       => p_pkt_id,
                                                    p_lp_comment   => '&4');
        END IF;

        UPDATE packet
           SET pkt_st = CASE WHEN l_res_code = 0 THEN 'N' ELSE 'D' END
         WHERE pkt_id = p_pkt_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionRBM (
                'RDM$PACKET.update_pkt_ic <' || p_pkt_rec_code || '> ',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END update_pkt_ic;

    --Создание задания на отправку пакета по почте
    PROCEDURE send_pkt_email (p_pkt_id packet.pkt_id%TYPE)
    IS
        v_recipient_mail    VARCHAR2 (500);
        v_attachment_name   VARCHAR2 (255);
        v_attachment_body   BLOB;
        v_message_id        NUMBER;
    BEGIN
        NULL;
    /*  --Получаем email адрес получателя
      select max(m.rm_mail)
      into v_recipient_mail
      from packet p
      join recipient_mail m
      on p.pkt_rm=m.rm_id
      where p.pkt_id=p_pkt_id;

      if v_recipient_mail is null then
        raise_application_error(-20001, 'Не знайдено e-mail одержувача');
      end if;

      --получаем имя файла и зашифрованный конверт
      select c.pc_name || p_pkt_id || '.p7e',  c.pc_encrypt_data
      into v_attachment_name, v_attachment_body
      from packet_content c
      where c.pc_pkt=p_pkt_id;

      if v_attachment_body is null then
        raise_application_error(-20001, 'Не сформовано зашифрованний конверт для відправки через e-mail.');
      end if;

      --Создаем задание на отправку письма
      ikis_person.rdm$nt_api.SendTechnicalEmail(p_source          => 'RBM',
                                                p_email_addr      => v_recipient_mail,
                                                p_subject         => 'Виплатна відомість ПФУ',
                                                p_text            => null,
                                                p_attachment_name => v_attachment_name,
                                                p_attachment_body => v_attachment_body,
                                                p_attachment_mime => 'application/octet-stream',
                                                p_message_id      => v_message_id);
       update packet_content c
       set c.pc_msg = v_message_id
       where c.pc_pkt = p_pkt_id;    */
    END;

    --Обновление статуса пакетов, которые отправляеются на e-mail
    PROCEDURE refresh_pkt_st_by_mail
    IS
    BEGIN
        --#78995 2022.08.01
        IF ikis_sys.IKIS_PARAMETER_UTIL.GetParameter1 ('APP_JOBS_STOP',
                                                       'IKIS_SYS') !=
           'FALSE'
        THEN
            RETURN;
        END IF;

        NULL;
    /*  for pkt in(select p.pkt_id from packet p
                    join packet_content c
                      on p.pkt_id = c.pc_pkt
                    join ikis_person.v_nt_msg2task t
                      on c.pc_msg = t.Ntmt_Ntm
                     and t.Ntmt_St = 'D' --delivered
                   where p.pkt_st = 'NVP')
      loop
        update packet p set p.pkt_st = 'SND' where p.pkt_id = pkt.pkt_id;

        Rdm$log_Packet.insert_log_packet(p_lp_pkt     => pkt.pkt_id,
                                         p_lp_wu      => null,
                                         p_lp_dt      => sysdate,
                                         p_lp_atp     => 'SND',
                                         p_lp_comment => null);
      end loop;*/
    END;

    PROCEDURE insert_packet_link (p_Pkt_prev   NUMBER DEFAULT -1,
                                  p_Pkt_id     NUMBER)
    IS
        l_pkt_id     NUMBER (14);
        l_pkt_prev   NUMBER (14);
    BEGIN
        SELECT NVL (MAX (pkt.pkt_id), 0)
          INTO l_pkt_prev
          FROM packet pkt
         WHERE pkt.pkt_id = p_Pkt_prev;

        IF l_pkt_prev > 0 AND p_Pkt_id > 0
        THEN
            RDM$PACKET_LINKS.insert_packet_LINKS (
                p_pl_pkt_in    => p_Pkt_id,
                p_pl_pkt_out   => l_pkt_prev);
        ELSE
            NULL;                                     -- нотифікація? помилка?
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ExceptionRBM (
                'RDM$PACKET.insert_packet_link ',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    /*   ------------------------    insert packet ---------------------------------*/
    FUNCTION init_packet (p_rq_id           NUMBER,
                          p_pkt_pat         NUMBER,
                          p_pkt_nes         NUMBER,
                          p_pkt_org         NUMBER,
                          p_pkt_create_wu   NUMBER,
                          p_pkt_change_wu   NUMBER,
                          p_pkt_rec         NUMBER)
        RETURN NUMBER
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_pkt_id    NUMBER (14);
        l_comment   log_packet.lp_comment%TYPE;
    BEGIN
        l_pkt_id := get_pkt_id;
        l_comment :=
            get_log_pkt_comment (l_pkt_id,
                                 p_pkt_pat,
                                 p_pkt_nes,
                                 p_pkt_org,
                                 'INIT',
                                 p_pkt_rec,
                                 ikis_const.v_ddn_action_tp_crt);

        /*  insert  packet*/
        INSERT INTO packet (pkt_id,
                            pkt_pat,
                            pkt_nes,
                            pkt_org,
                            pkt_st,
                            pkt_create_wu,
                            pkt_create_dt,
                            pkt_change_wu,
                            pkt_change_dt,
                            pkt_rec,
                            pkt_rq_id)
             VALUES (l_pkt_id,
                     p_pkt_pat,
                     p_pkt_nes,
                     p_pkt_org,
                     'INIT',
                     p_pkt_create_wu,
                     SYSDATE,
                     p_pkt_change_wu,
                     NULL,
                     p_pkt_rec,
                     p_rq_id);

        /* set log */
        Rdm$log_Packet.insert_log_packet (p_lp_pkt       => l_pkt_id,
                                          p_lp_wu        => p_pkt_create_wu,
                                          p_lp_dt        => SYSDATE,
                                          p_lp_atp       => 'INIT',
                                          p_lp_comment   => '&1#' || p_rq_id);
        COMMIT;
        RETURN l_pkt_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            ikis_rbm.rdm$log_packet.insert_message (
                p_lp_pkt   => NULL,
                p_lp_comment   =>
                       '&109#<rq='
                    || p_rq_id
                    || '>'
                    || CHR (10)
                    || DBMS_UTILITY.format_error_stack
                    || DBMS_UTILITY.format_error_backtrace);
            ExceptionRBM (
                'RDM$PACKET.init_packet ',
                   SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END init_packet;
BEGIN
    NULL;
END RDM$PACKET;
/