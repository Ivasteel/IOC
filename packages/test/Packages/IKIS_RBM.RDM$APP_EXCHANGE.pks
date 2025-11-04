/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.RDM$APP_EXCHANGE
IS
    -- Author  : VANO
    -- Created : 12.07.2015 18:04:21
    -- Purpose : Обмін пакетами з прикладними системами

    PROCEDURE GenPaketsFromTMPTable;

    --PROCEDURE GenPaketsPpvpPsp;
    -- Задача #57744  согласование механизма отправки email
    FUNCTION GetConvert (p_id NUMBER, p_recipient_code VARCHAR2)
        RETURN CLOB;

    -- процедура генерації пакетів ППВП
    --PROCEDURE GenPaketsPpvp(p_serv_code in varchar2);


    -- Формування файлу пакета для подальшого вивантаження
    -- для pkt_pat = 101 (json) = zip: json + ecp
    FUNCTION Get_pkt_file (p_pkt_id NUMBER)
        RETURN BLOB;

    --  #89670 збереження візуалізації вмісту пакета
    PROCEDURE set_visual_data (p_pkt_id NUMBER, p_visual_data CLOB);

    -- IC #111345 Перевипустив щоб не шукати ід пакета
    PROCEDURE GenPaketsFromTMPTable (o_pkt_id OUT NUMBER);
END RDM$APP_EXCHANGE;
/


GRANT EXECUTE ON IKIS_RBM.RDM$APP_EXCHANGE TO DNET_PROXY
/

GRANT EXECUTE ON IKIS_RBM.RDM$APP_EXCHANGE TO II01RC_RBMWEB_COMMON
/

GRANT EXECUTE ON IKIS_RBM.RDM$APP_EXCHANGE TO II01RC_RBM_ESR
/

GRANT EXECUTE ON IKIS_RBM.RDM$APP_EXCHANGE TO II01RC_RBM_INTERNAL
/

GRANT EXECUTE ON IKIS_RBM.RDM$APP_EXCHANGE TO PORTAL_PROXY
/

GRANT EXECUTE ON IKIS_RBM.RDM$APP_EXCHANGE TO USS_DOC
/

GRANT EXECUTE ON IKIS_RBM.RDM$APP_EXCHANGE TO USS_ESR
/

GRANT EXECUTE ON IKIS_RBM.RDM$APP_EXCHANGE TO USS_PERSON
/

GRANT EXECUTE ON IKIS_RBM.RDM$APP_EXCHANGE TO USS_RNSP
/

GRANT EXECUTE ON IKIS_RBM.RDM$APP_EXCHANGE TO USS_VISIT
/


/* Formatted on 8/12/2025 6:10:50 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.RDM$APP_EXCHANGE
IS
    PROCEDURE GenPaketsFromTMPTable
    IS
        l_pkt          packet.pkt_id%TYPE;
        l_sysdate      DATE := TRUNC (SYSDATE);
        l_mil2fin_on   VARCHAR2 (10);
        l_rm_id        NUMBER;
    BEGIN
        FOR cc IN (SELECT * FROM tmp_exchangefiles_m1)
        LOOP
            /*    select max(rm_id) into  l_rm_id
                from recipient_mail m
                where rm_rec = cc.ef_rec
                  and m.rm_st = 'A';*/
            IF cc.ef_main_tag_name = 'paymentlists'
            THEN
                -- #94282 1. визначаємо rm_id по ef_rec та com_org
                SELECT MAX (rm_id)
                  INTO l_rm_id
                  FROM recipient_mail m
                 WHERE     m.rm_rec = cc.ef_rec
                       AND m.com_org = cc.com_org
                       AND m.rm_st = 'A';

                -- #94282 2. якщо не знайшли - визначаємо rm_id по ef_rec та com_org=50000
                IF l_rm_id IS NULL
                THEN
                    SELECT MAX (rm_id)
                      INTO l_rm_id
                      FROM recipient_mail m
                     WHERE     m.rm_rec = cc.ef_rec
                           AND m.com_org = 50000
                           AND m.rm_st = 'A';
                END IF;
            ELSE
                SELECT MAX (rm_id)
                  INTO l_rm_id
                  FROM recipient_mail m
                 WHERE rm_rec = cc.ef_rec AND m.rm_st = 'A';
            END IF;

            l_pkt :=
                ikis_rbm.RDM$PACKET.insert_packet (
                    p_Pkt_Pat         =>
                        CASE
                            WHEN cc.ef_main_tag_name = 'paymentlists'
                            THEN
                                101
                            WHEN cc.ef_main_tag_name = 'EISF01'
                            THEN
                                111                     -- io  #89670 20230804
                            WHEN cc.ef_main_tag_name = 'EISC01'
                            THEN
                                115
                            WHEN cc.ef_main_tag_name = 'EIS2MFU'
                            THEN
                                114
                            WHEN cc.ef_main_tag_name = 'MSP2DCZVPOLI'
                            THEN
                                106
                            WHEN cc.ef_main_tag_name = 'MSP2DPS'
                            THEN
                                108
                            WHEN cc.ef_main_tag_name = 'EISMSP2WFP'
                            THEN
                                120                      -- IC #98164 (un_vrf)
                            WHEN cc.ef_main_tag_name = 'MSP2UNI'
                            THEN
                                122                                  -- #99087
                        END,
                    p_Pkt_Nes         =>
                        CASE
                            WHEN cc.ef_main_tag_name = 'paymentlists'
                            THEN
                                101
                            WHEN cc.ef_main_tag_name = 'EISF01'
                            THEN
                                102                     -- io  #89670 20230804
                            WHEN cc.ef_main_tag_name = 'EISC01'
                            THEN
                                102
                            WHEN cc.ef_main_tag_name = 'EIS2MFU'
                            THEN
                                102
                            WHEN cc.ef_main_tag_name = 'MSP2DCZVPOLI'
                            THEN
                                104
                            WHEN cc.ef_main_tag_name = 'MSP2DPS'
                            THEN
                                105
                            WHEN cc.ef_main_tag_name = 'EISMSP2WFP'
                            THEN
                                101                               -- IC #98164
                            WHEN cc.ef_main_tag_name = 'MSP2UNI'
                            THEN
                                106                                  -- #99087
                            ELSE
                                101
                        END,                                           /*101*/
                    p_Pkt_Org         => cc.com_org,
                    p_Pkt_St          => 'N',
                    p_Pkt_Create_Wu   => cc.com_wu,
                    p_Pkt_Create_Dt   => SYSDATE,
                    p_Pkt_Change_Wu   => NULL,
                    p_Pkt_Change_Dt   => NULL,
                    p_Pkt_Rec         => cc.ef_rec,
                    p_Pkt_Rm          => l_rm_id                      /*NULL*/
                                                );
            --dbms_output.put_line(cc.ef_id||': '||l_pkt||', tt='|| TO_CHAR(SYSTIMESTAMP, 'DD-MON-YYYY HH24:MI:SSxFF'));
            /*    ikis_rbm.RDM$PACKET_CONTENT.insert_packet_content(l_pkt, 'F', cc.ef_name, cc.ef_data,
                                                                  NULL, SYSDATE, cc.ef_visual_data, cc.ef_main_tag_name,
                                                                  cc.ef_data_name, cc.ef_ecp_list_name, cc.ef_ecp_name, cc.ef_ecp_alg,
                                                                  cc.ef_id, cc.ef_header);*/
            ikis_rbm.RDM$PACKET_CONTENT.insert_packet_content (             --
                p_pc_pkt             => l_pkt,
                p_pc_tp              => 'F',
                p_pc_name            => cc.ef_name,
                p_pc_data            => cc.ef_data,
                p_pc_pkt_change_wu   => NULL,
                p_pc_pkt_change_dt   => SYSDATE,
                p_pc_visual_data     => cc.ef_visual_data,
                p_pc_main_tag_name   => cc.ef_main_tag_name,
                p_pc_data_name       => cc.ef_data_name,
                p_pc_ecp_list_name   => cc.ef_ecp_list_name,
                p_pc_ecp_name        => cc.ef_ecp_name,
                p_pc_ecp_alg         => cc.ef_ecp_alg,
                p_pc_src_entity      => cc.ef_id,
                p_pc_header          => cc.ef_header,
                --p_pc_encrypt_data  => ,
                p_pc_npc             => cc.ef_npc                    -- #79230
                                                 );

            UPDATE tmp_exchangefiles_m1 t
               SET t.ef_pkt = l_pkt
             WHERE t.ef_id = cc.ef_id;
        --  #63118  Реєстр платіжних відомостей.
        /*  В payroll_reestr заливається при фіксації ВВ
        if cc.ef_main_tag_name = 'paymentlists' and l_pkt > 0
        then
          select nvl(max(prm_value), 'F') into l_mil2fin_on
          from ikis_rbm.param_rbm p
          where prm_code = 'MIL2FIN'
            and prm_st = 'L'
            and prm_start_dt <= sysdate
            and (prm_stop_dt is null or prm_stop_dt >  sysdate);

          if l_mil2fin_on = 'T' then
          begin
            insert into ikis_finzvit.payroll_reestr (pr_id, pr_src, pr_src_entity, pr_rbm_pkt, pr_bnk_rbm_code, com_org,
                             pr_tp, pr_code, pr_name, pr_pay_tp, pr_bnk_code, pr_filia_code, pr_bnk_mfo, pr_bnk_name,
                             pr_pay_dt, pr_row_cnt, pr_sum, pr_st, pr_po, pr_cat, pr_dt, pr_src_create_dt)
            select \*+ CURSOR_SHARING_EXACT *\  -- hint для коректного відпрацювання  to_date(*** default null on conversion error, ***)
              null as pr_id,
              1 as pr_src,
              cc.ef_pr  as  pr_src_entity,
              l_pkt as pr_rbm_pkt,
              (select rec_code from recipient where rec_id = cc.ef_rec) as pr_bnk_rbm_code,
              cc.com_org as com_org,
              case cc.ef_pr_code when '01' then 0 else 2 end as pr_tp,  -- Тип відомості  0 – основна, 1 – Коригуюча, 2 – Додаткова
              nvl(ltrim(cc.ef_pr_code, '0'), 0) as pr_code,
              nvl(cc.ef_pr_name, 'ВВ ПВП ДКГ') as pr_name,
              0 as pr_pay_tp,
              to_char(ikis_rbm.tools.get_xmlattr_clob('<pc_header>'||cc.ef_header||'</pc_header>', 'filia_num')) as pr_bnk_code,
              to_char(ikis_rbm.tools.get_xmlattr_clob('<pc_header>'||cc.ef_header||'</pc_header>', 'filia_num')) as pr_filia_code,
              to_char(ikis_rbm.tools.get_xmlattr_clob('<pc_header>'||cc.ef_header||'</pc_header>', 'MFO_filia')) as pr_bnk_mfo,
              (select rec_name from recipient where rec_id = cc.ef_rec) as pr_bnk_name,
              cc.ef_pr_pay_dt as pr_pay_dt,
              to_number(to_char(ikis_rbm.tools.get_xmlattr_clob('<pc_header>'||cc.ef_header||'</pc_header>', 'full_lines'))) as pr_row_cnt,
              to_number(\*replace(*\to_char(ikis_rbm.tools.get_xmlattr_clob('<pc_header>'||cc.ef_header||'</pc_header>', 'full_sum'))\*, ',', '.')*\
                        default null on conversion error) as  pr_sum,
              'T' as pr_st,
              null as pr_po,
              null as pr_cat,
              sysdate pr_dt,
              nvl(to_date(to_char(ikis_rbm.tools.get_xmlattr_clob('<pc_header>'||cc.ef_header||'</pc_header>', 'date_cr'))
                          default null on conversion error, 'ddmmyyyy' ), sysdate)  as pr_src_create_dt
              --ikis_rbm.tools.get_xmlattr_clob('<pc_header>'||cc.ef_header||'</pc_header>', 'date_cr')
            from dual;
          exception
            when others then
              --null;  -- log ???
              rdm$log_packet.insert_LOG_PACKET(
                   v_lp_pkt => \*null *\l_pkt,
                   v_lp_wu => null,
                   v_lp_dt => sysdate,
                   v_lp_atp => \*null*\'M2F',
                   v_lp_comment => substr(DBMS_UTILITY.FORMAT_ERROR_STACK||' => '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 1, 500));
          end;
          end if;
        end if;*/
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'RDM$APP_EXCHANGE.GenPaketsFromTMPTable:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;

    PROCEDURE GenPaketsFromTMPTable (o_pkt_id OUT NUMBER)
    IS
        l_sysdate      DATE := TRUNC (SYSDATE);
        l_mil2fin_on   VARCHAR2 (10);
        l_rm_id        NUMBER;
    BEGIN
        FOR cc IN (SELECT * FROM tmp_exchangefiles_m1)
        LOOP
            IF cc.ef_main_tag_name = 'paymentlists'
            THEN
                -- #94282 1. визначаємо rm_id по ef_rec та com_org
                SELECT MAX (rm_id)
                  INTO l_rm_id
                  FROM recipient_mail m
                 WHERE     m.rm_rec = cc.ef_rec
                       AND m.com_org = cc.com_org
                       AND m.rm_st = 'A';

                -- #94282 2. якщо не знайшли - визначаємо rm_id по ef_rec та com_org=50000
                IF l_rm_id IS NULL
                THEN
                    SELECT MAX (rm_id)
                      INTO l_rm_id
                      FROM recipient_mail m
                     WHERE     m.rm_rec = cc.ef_rec
                           AND m.com_org = 50000
                           AND m.rm_st = 'A';
                END IF;
            ELSE
                SELECT MAX (rm_id)
                  INTO l_rm_id
                  FROM recipient_mail m
                 WHERE rm_rec = cc.ef_rec AND m.rm_st = 'A';
            END IF;

            o_pkt_id :=
                ikis_rbm.RDM$PACKET.insert_packet (
                    p_Pkt_Pat         =>
                        CASE
                            WHEN cc.ef_main_tag_name = 'paymentlists'
                            THEN
                                101
                            WHEN cc.ef_main_tag_name = 'EISF01'
                            THEN
                                111                     -- io  #89670 20230804
                            WHEN cc.ef_main_tag_name = 'EISC01'
                            THEN
                                115
                            WHEN cc.ef_main_tag_name = 'EIS2MFU'
                            THEN
                                114
                            WHEN cc.ef_main_tag_name = 'MSP2DCZVPOLI'
                            THEN
                                106
                            WHEN cc.ef_main_tag_name = 'MSP2DPS'
                            THEN
                                108
                            WHEN cc.ef_main_tag_name = 'EISMSP2WFP'
                            THEN
                                120                      -- IC #98164 (un_vrf)
                            WHEN cc.ef_main_tag_name = 'MSP2UNI'
                            THEN
                                122                                  -- #99087
                        END,
                    p_Pkt_Nes         =>
                        CASE
                            WHEN cc.ef_main_tag_name = 'paymentlists'
                            THEN
                                101
                            WHEN cc.ef_main_tag_name = 'EISF01'
                            THEN
                                102                     -- io  #89670 20230804
                            WHEN cc.ef_main_tag_name = 'EISC01'
                            THEN
                                102
                            WHEN cc.ef_main_tag_name = 'EIS2MFU'
                            THEN
                                102
                            WHEN cc.ef_main_tag_name = 'MSP2DCZVPOLI'
                            THEN
                                104
                            WHEN cc.ef_main_tag_name = 'MSP2DPS'
                            THEN
                                105
                            WHEN cc.ef_main_tag_name = 'EISMSP2WFP'
                            THEN
                                101                               -- IC #98164
                            WHEN cc.ef_main_tag_name = 'MSP2UNI'
                            THEN
                                106                                  -- #99087
                            ELSE
                                101
                        END,                                           /*101*/
                    p_Pkt_Org         => cc.com_org,
                    p_Pkt_St          => 'N',
                    p_Pkt_Create_Wu   => cc.com_wu,
                    p_Pkt_Create_Dt   => SYSDATE,
                    p_Pkt_Change_Wu   => NULL,
                    p_Pkt_Change_Dt   => NULL,
                    p_Pkt_Rec         => cc.ef_rec,
                    p_Pkt_Rm          => l_rm_id                      /*NULL*/
                                                );

            ikis_rbm.RDM$PACKET_CONTENT.insert_packet_content (             --
                p_pc_pkt             => o_pkt_id,
                p_pc_tp              => 'F',
                p_pc_name            => cc.ef_name,
                p_pc_data            => cc.ef_data,
                p_pc_pkt_change_wu   => NULL,
                p_pc_pkt_change_dt   => SYSDATE,
                p_pc_visual_data     => cc.ef_visual_data,
                p_pc_main_tag_name   => cc.ef_main_tag_name,
                p_pc_data_name       => cc.ef_data_name,
                p_pc_ecp_list_name   => cc.ef_ecp_list_name,
                p_pc_ecp_name        => cc.ef_ecp_name,
                p_pc_ecp_alg         => cc.ef_ecp_alg,
                p_pc_src_entity      => cc.ef_id,
                p_pc_header          => cc.ef_header,
                --p_pc_encrypt_data  => ,
                p_pc_npc             => cc.ef_npc                    -- #79230
                                                 );

            UPDATE tmp_exchangefiles_m1 t
               SET t.ef_pkt = o_pkt_id
             WHERE t.ef_id = cc.ef_id;
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'RDM$APP_EXCHANGE.GenPaketsFromTMPTable:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;

    /*PROCEDURE GenPaketsPpvpPsp
    IS
      l_pkt    packet.pkt_id%TYPE;
      l_pt_id  uss_ndi.v_ndi_packet_type.pat_id%type;
      l_rec_tp recipient.rec_tp%type;
      l_rm_id  recipient_mail.rm_id%type;
      exNoRecMail  exception;
    BEGIN
      select pat_id into l_pt_id from uss_ndi.v_ndi_packet_type where pt_code = 'payrollpassport_ppvp';

      FOR cc IN (SELECT * FROM tmp_exchangefiles_m2)
      LOOP
        select rec_tp into l_rec_tp
        from recipient
        where rec_id = cc.ef_rec;

        if l_rec_tp = 'IC' then
          l_pkt := ikis_rbm.RDM$PACKET.insert_packet(l_pt_id, 4, cc.ef_org, 'N',
                                                     NULL, SYSDATE, NULL, NULL, cc.ef_rec);
        elsif l_rec_tp = 'MAIL' then -- #57744
        null;
        \*
          select max(rm_id) into l_rm_id
          from recipient_mail r
          join ikis_rbm.v_nsi_psb_ppvp p
            on psb_id=  r.rm_psb
          join (SELECT x_MFO_filia, x_filia_num, x_opfu_code
                FROM xmltable
                  ('/pc_header'
                   PASSING xmltype(to_clob('<pc_header>'||cc.ef_header||'</pc_header>'))
                     -- (select xmltype(to_clob('<pc_header>'||pc_header||'</pc_header>')) from PACKET_CONTENT t  where  pc_pkt = 4196)
                   COLUMNS
                     x_MFO_filia VARCHAR2(25) PATH 'MFO_filia',
                     x_filia_num VARCHAR(25) PATH 'filia_num',
                     x_opfu_code VARCHAR2(10) PATH 'opfu_code'
                   )
                ) x
             on r.com_org = x.x_opfu_code
             and r.rm_mfo = x.x_MFO_filia
            -- and r.rm_filia = x.x_filia_num
              and p.psb_nbank = x.x_filia_num
           where r.rm_rec = cc.ef_rec
             and r.rm_st = 'A';
          *\
          if l_rm_id is null then
    \*        select max(rm_id) into l_rm_id
            from recipient_mail r
            join (SELECT x_MFO_filia, x_filia_num, x_opfu_code
                  FROM xmltable
                    ('/pc_header'
                     PASSING xmltype(to_clob('<pc_header>'||cc.ef_header||'</pc_header>'))
                       -- (select xmltype(to_clob('<pc_header>'||pc_header||'</pc_header>')) from PACKET_CONTENT t  where  pc_pkt = 4196)
                     COLUMNS
                       x_MFO_filia VARCHAR2(25) PATH 'MFO_filia',
                       x_filia_num VARCHAR(25) PATH 'filia_num',
                       x_opfu_code VARCHAR2(10) PATH 'opfu_code'
                     )
                  ) x
               on r.com_org = x.x_opfu_code
               and r.rm_mfo = x.x_MFO_filia
             where r.rm_rec = cc.ef_rec
               and r.rm_st = 'A';*\

            if l_rm_id is null then
              raise exNoRecMail;
            end if;
          end if;
          l_pkt := ikis_rbm.RDM$PACKET.insert_packet(l_pt_id, 4, cc.ef_org, 'N',
                                                     NULL, SYSDATE, NULL, NULL, cc.ef_rec, l_rm_id);
        end if;

       ikis_rbm.RDM$PACKET_CONTENT.insert_packet_content(l_pkt, 'F', cc.ef_name, cc.ef_data,
                                                         NULL, SYSDATE, cc.ef_visual_data, cc.ef_main_tag_name,
                                                         cc.ef_data_name, cc.ef_ecp_list_name, cc.ef_ecp_name, cc.ef_ecp_alg,
                                                         cc.ef_id, cc.ef_header);
      END LOOP;

    EXCEPTION
      when exNoRecMail then
        raise_application_error(-20000, 'ikis_rbm.RDM$APP_EXCHANGE.GenPaketsPpvpPsp:'||chr(10)||
                 'Не вдалося визначити адресата для e-mail розсилки');
      WHEN OTHERS THEN
        raise_application_error(-20000, 'ikis_rbm.RDM$APP_EXCHANGE.GenPaketsPpvpPsp:'||chr(10)||replace(DBMS_UTILITY.FORMAT_ERROR_STACK||' => '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,'ORA-20000:')||chr(10)||sqlerrm);
    END GenPaketsPpvpPsp;*/

    -- Задача #57744  согласование механизма отправки email
    FUNCTION GetConvert (p_id NUMBER, p_recipient_code VARCHAR2)
        RETURN CLOB
    IS
        l_result       CLOB;
        l_pre_result   CLOB;
        l_data         CLOB;
        l_header       ikis_rbm.packet_content.pc_header%TYPE;
        l_st           ikis_rbm.packet.pkt_st%TYPE;
    BEGIN
        BEGIN
            SELECT XMLELEMENT (
                       "paymentlists",
                       XMLELEMENT ("id", pkt_id),
                       XMLELEMENT ("xXx", 'z'),
                       XMLELEMENT ("files_data", 'XX##XX'),
                       XMLELEMENT (
                           "ecp_list",
                           (SELECT XMLAGG (XMLELEMENT ("ecp", pce_ecp))
                              FROM ikis_rbm.packet_ecp
                             WHERE pce_pc = pc_id))).getclobval ()
              INTO l_pre_result
              FROM ikis_rbm.packet, ikis_rbm.packet_content, ikis_sys.v_opfu
             WHERE     pc_pkt = pkt_id
                   AND pkt_org = org_id
                   AND pkt_id = p_id
                   AND pkt_st IN ('NVP', 'SND', 'RCV') --  #64722 oivashchuk 20201208  RCV
                   AND pkt_pat IN (1, 21) -- payroll_pvp, payrollpassport_ppvp -- ivashchuk  #24611 20170823 -> #17432 20160823
                   AND EXISTS
                           (SELECT 1
                              FROM ikis_rbm.recipient
                             WHERE     pkt_rec = rec_id
                                   AND rec_code = p_recipient_code);

            SELECT TOOLS.ConvertBlobToBase64 (pc_data), pc_header
              INTO l_data, l_header
              FROM ikis_rbm.packet_content
             WHERE pc_pkt = p_id;

            l_result :=
                TOOLS.PasteClob (l_pre_result, l_header, '<xXx>z</xXx>');
            l_pre_result := l_result;
            l_result := TOOLS.PasteClob (l_pre_result, l_data, 'XX##XX');

            SELECT pkt_st
              INTO l_st
              FROM ikis_rbm.packet
             WHERE pkt_id = p_id;
        /*    IF l_st = 'NVP' THEN
              IKIS_RBM.rdm$packet.set_packet_state(p_id, 'SND', NULL, sysdate);
            END IF;*/
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                l_result := '<paymentlists></paymentlists>';
        END;

        RETURN l_result;
    END;

    -- процедура генерації пакетів ППВП
    /*PROCEDURE GenPaketsPpvp(p_serv_code in varchar2)
    IS
      l_pkt    packet.pkt_id%TYPE;
      l_pt_id  packet_type.pt_id%type;
      l_rec_tp recipient.rec_tp%type;
      l_rm_id  recipient_mail.rm_id%type;
      exNoRecMail  exception;
      exNoPktType  exception;
    BEGIN

      begin
        select pt_id into l_pt_id
        from packet_type
        where pt_code = ----lower(p_serv_code||'_ppvp')
                 case p_serv_code
           \*30*\  when 'get_verification_data'   then 'verification_data_ppvp'
           \*28*\  when 'get_notice_death_bank'   then 'death_ppvp'
           \*11*\  when 'get_replacement_account' then 'changeacc_reply_ppvp'
           \*15*\  when 'get_notice_drawing_bank' then 'notreceive_reply_ppvp'
                   else ''
                 end
          and pt_es = 4;
      exception
        when no_data_found then raise exNoPktType;
      end;

      FOR cc IN (SELECT * FROM tmp_exchangefiles_m2 t where t.ef_main_tag_name = p_serv_code)
      LOOP
        select rec_tp into l_rec_tp
        from recipient
        where rec_id = cc.ef_rec;

        if l_rec_tp = 'IC' then
          l_pkt := ikis_rbm.RDM$PACKET.insert_packet(l_pt_id, 4, cc.ef_org, 'N',
                                                     NULL, SYSDATE, NULL, NULL, cc.ef_rec);
        elsif l_rec_tp = 'MAIL' then -- #57744
          NULL;
    \*
          select max(rm_id) into l_rm_id
          from recipient_mail r
          join ikis_rbm.v_nsi_psb_ppvp p
            on psb_id=  r.rm_psb
          join (SELECT x_MFO_filia, x_filia_num, x_opfu_code
                FROM xmltable
                  ('/pc_header'
                   PASSING xmltype(to_clob('<pc_header>'||cc.ef_header||'</pc_header>'))
                     -- (select xmltype(to_clob('<pc_header>'||pc_header||'</pc_header>')) from PACKET_CONTENT t  where  pc_pkt = 4196)
                   COLUMNS
                     x_MFO_filia VARCHAR2(25) PATH 'MFO_filia',
                     x_filia_num VARCHAR(25) PATH 'filia_num',
                     x_opfu_code VARCHAR2(10) PATH 'opfu_code'
                   )
                ) x
             on r.com_org = x.x_opfu_code
             and r.rm_mfo = x.x_MFO_filia
            -- and r.rm_filia = x.x_filia_num
              and p.psb_nbank = x.x_filia_num
           where r.rm_rec = cc.ef_rec
             and r.rm_st = 'A';*\

          if l_rm_id is null then
    \*        select max(rm_id) into l_rm_id
            from recipient_mail r
            join (SELECT x_MFO_filia, x_filia_num, x_opfu_code
                  FROM xmltable
                    ('/pc_header'
                     PASSING xmltype(to_clob('<pc_header>'||cc.ef_header||'</pc_header>'))
                       -- (select xmltype(to_clob('<pc_header>'||pc_header||'</pc_header>')) from PACKET_CONTENT t  where  pc_pkt = 4196)
                     COLUMNS
                       x_MFO_filia VARCHAR2(25) PATH 'MFO_filia',
                       x_filia_num VARCHAR(25) PATH 'filia_num',
                       x_opfu_code VARCHAR2(10) PATH 'opfu_code'
                     )
                  ) x
               on r.com_org = x.x_opfu_code
               and r.rm_mfo = x.x_MFO_filia
             where r.rm_rec = cc.ef_rec
               and r.rm_st = 'A';*\

            if l_rm_id is null then
              raise exNoRecMail;
            end if;
          end if;
          l_pkt := ikis_rbm.RDM$PACKET.insert_packet(l_pt_id, 4, cc.ef_org, 'N',
                                                     NULL, SYSDATE, NULL, NULL, cc.ef_rec, l_rm_id);
        end if;

       ikis_rbm.RDM$PACKET_CONTENT.insert_packet_content(l_pkt, 'F', cc.ef_name, cc.ef_data,
                                                         NULL, SYSDATE, cc.ef_visual_data, cc.ef_main_tag_name,
                                                         cc.ef_data_name, cc.ef_ecp_list_name, cc.ef_ecp_name, cc.ef_ecp_alg,
                                                         cc.ef_id, cc.ef_header);
      END LOOP;

    EXCEPTION
      when exNoPktType then
        raise_application_error(-20000, 'ikis_rbm.RDM$APP_EXCHANGE.GenPaketsPpvp:'||chr(10)||
                 'Не вдалося визначити тип пакета для сервіса <'||p_serv_code||'>');
      when exNoRecMail then
        raise_application_error(-20000, 'ikis_rbm.RDM$APP_EXCHANGE.GenPaketsPpvp:'||chr(10)||
                 'Не вдалося визначити адресата для e-mail розсилки');
      WHEN OTHERS THEN
        raise_application_error(-20000, 'ikis_rbm.RDM$APP_EXCHANGE.GenPaketsPpvp:'||chr(10)||replace(DBMS_UTILITY.FORMAT_ERROR_STACK||' => '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,'ORA-20000:')||chr(10)||sqlerrm);
    END GenPaketsPpvp;*/



    -- Формування файлу пакета для подальшого вивантаження
    -- для pkt_pat = 101 (json) = zip: json + ecp
    FUNCTION Get_pkt_file (p_pkt_id NUMBER)
        RETURN BLOB
    IS
        l_pkt_name   VARCHAR2 (100);
        l_file_ext   VARCHAR2 (100);
        l_ecp_ext    VARCHAR2 (100);
        l_pkt_blob   BLOB;
        l_ecp_blob   BLOB;
        l_res_blob   BLOB;
        l_files      ikis_sysweb.tbl_some_files
                         := ikis_sysweb.tbl_some_files ();
    BEGIN
        FOR pp
            IN (SELECT pkt_id, pc_id, pkt_pat
                  FROM ikis_rbm.packet
                       JOIN ikis_rbm.packet_content ON pc_pkt = pkt_id
                 WHERE 1 = 1 --and pkt_pat = 101
                             --and pkt_st =
                             AND pc_pkt = p_pkt_id)
        LOOP
            IF pp.pkt_pat != 101
            THEN
                SELECT NVL (pc_data, c.pc_encrypt_data)
                  INTO l_res_blob
                  FROM ikis_rbm.packet_content c
                 WHERE pc_pkt = pp.pkt_id;
            ELSE
                SELECT UTL_COMPRESS.lz_uncompress (pc_data),
                       pc_name,
                       pc_data_name,
                       pc_ecp_list_name
                  INTO l_pkt_blob,
                       l_pkt_name,
                       l_file_ext,
                       l_ecp_ext
                  FROM ikis_rbm.packet_content c
                 WHERE pc_pkt = pp.pkt_id;

                l_files.EXTEND;
                l_files (l_files.LAST) :=
                    ikis_sysweb.t_some_file_info (
                        l_pkt_name || '.' || l_file_ext,
                        l_pkt_blob);

                -- ecp
                SELECT ikis_rbm.tools.decode_base64 (c.pce_ecp)
                  -- ikis_rbm.tools.ConvertC2B(c.pce_ecp)
                  INTO l_ecp_blob
                  FROM ikis_rbm.packet_ecp c
                 WHERE c.pce_pc = pp.pc_id AND ROWNUM = 1;

                l_files.EXTEND;
                l_files (l_files.LAST) :=
                    ikis_sysweb.t_some_file_info (
                        l_pkt_name || '.' || l_file_ext || '.' || l_ecp_ext,
                        l_ecp_blob);

                --Выходной архив
                IF l_files.COUNT > 0
                THEN
                    l_res_blob :=
                        ikis_sysweb.ikis_web_jutil.getZipFromStrms (l_files);
                --l_fname := l_pkt_name||'.zip';
                --insert into ikis_rbm.tmp_lob(x_id, x_clob, x_blob) values(1, l_pkt_name||'.zip', l_res_blob);
                ELSE
                    NULL;                                   -- raise exNoData;
                END IF;
            END IF;
        END LOOP;

        RETURN l_res_blob;
    END;

    --  #89670 збереження візуалізації вмісту пакета
    PROCEDURE set_visual_data (p_pkt_id NUMBER, p_visual_data CLOB)
    IS
    BEGIN
        UPDATE packet_content c
           SET pc_visual_data = p_visual_data
         WHERE pc_pkt = p_pkt_id;
    END;
BEGIN
    NULL;
END RDM$APP_EXCHANGE;
/