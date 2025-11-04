/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.DNET$PACKET
IS
    -- Author  : io
    -- Created : 25.04.2022 17:30:51
    -- Purpose :

    -- info:  журнал пакетів
    -- params: "Пошук: Вхідні":
    --         p_pkt_es - Підсистема
    --         p_pkt_pt - Тип
    --         p_org_reg - Область
    --         p_org_distr - Район
    --         p_pkt_st - Статус
    --         p_pkt_dt_start - Дата створення з
    --         p_pkt_dt_stop -  Дата створення по
    --         p_pkt_rec - Адресат  /  Адресат (швидкий пошук)
    --         p_rds_pfu_dt_start - Автор
    --         p_pkt_id- Ід пакета в ПЕОД
    -- note:   «Перелік пакетів» - грід з такими полями:
    --- Ід пакета в ПЕОД
    --- Підсистема
    --- Дата створення
    --- Тип пакету
    --- ОПФУ
    --- Статус
    --- Автор
    --- Адресат
    --- Додаткова інформація
    --- Вміст
    PROCEDURE get_packet_list (
        p_pkt_nes             packet.pkt_nes%TYPE,
        p_pkt_pat             packet.pkt_pat%TYPE,
        p_org_reg             packet.pkt_org%TYPE,
        p_org_distr           packet.pkt_org%TYPE,
        p_pkt_st              packet.pkt_st%TYPE,
        p_pkt_dt_start        packet.pkt_create_dt%TYPE,
        p_pkt_dt_stop         packet.pkt_create_dt%TYPE,
        p_pkt_rec             packet.pkt_rec%TYPE,
        p_pkt_create_wu       packet.pkt_create_wu%TYPE,
        p_pkt_id              packet.pkt_id%TYPE,
        p_pat_direction       uss_ndi.v_ndi_packet_type.pat_direction%TYPE,
        p_npc_id              NUMBER,
        RES_CUR           OUT SYS_REFCURSOR);

    -- info:  Картка пакета
    -- params: p_pkt_id- Ід пакета в ПЕОД
    -- note:
    PROCEDURE get_packet_card (p_pkt_id       packet.pkt_id%TYPE,
                               pkt_cur    OUT SYS_REFCURSOR,
                               pc_cur     OUT SYS_REFCURSOR,
                               ecp_cur    OUT SYS_REFCURSOR,
                               link_cur   OUT SYS_REFCURSOR,
                               log_cur    OUT SYS_REFCURSOR);

    -- info:  Вивантаження вмісту пакета для підпису
    -- params: p_pkt_ids- Ід-и пакетів в ПЕОД, через кому
    -- note:   Тіло пакета тип 101 - заархівований json, підписувати - json
    --         certs_cur - курсор з сертифікатами для шифрування
    --          #88329 +  p_pc_encrypt_data
    PROCEDURE get_pkt_files4sign (p_pkt_ids       VARCHAR2,
                                  files_cur   OUT SYS_REFCURSOR,
                                  certs_cur   OUT SYS_REFCURSOR);

    -- info:  Збереження підпису вмісту пакета
    -- params: p_pc_id- Ід вмісту пакета в ПЕОД
    -- note:   після підпису - змінюємо статус пакета на NVP
    PROCEDURE save_pkt_sign (
        p_pc_id             ikis_rbm.v_packet_ecp.pce_pc%TYPE,
        p_pce_ecp           ikis_rbm.v_packet_ecp.pce_ecp%TYPE,
        p_pce_info          ikis_rbm.v_packet_ecp.pce_info%TYPE,
        p_pc_encrypt_data   ikis_rbm.v_packet_content.pc_encrypt_data%TYPE);

    -- info:  Вивантаження вмісту пакетів для передачі в ПФУ
    -- params: p_pkt_ids- Ід-и пакетів в ПЕОД, через кому
    -- note:
    PROCEDURE get_packet_files (p_pkt_ids       VARCHAR2,
                                files_cur   OUT SYS_REFCURSOR);

    -- info:  Відправка пакетів (зміна статусу на NVP)
    -- params: p_pkt_ids- Ід-и пакетів в ПЕОД, через кому
    -- note:  статус змінюється лише для вихідних пакетів в статусах N - новий, SGN - підписаний
    --        к-ть ЕЦП на яких не менше мінінмально необхідної = uss_ndi.v_ndi_packet_type.pat_min_ect_cnt
    PROCEDURE send_packets (p_pkt_ids VARCHAR2);

    -- Вивантаження КВ-1/2
    -- p_pkt_list - перелік Ід пакетів через ,
    -- files_cur : l_filename,  l_content, size
    PROCEDURE DownloadPktFiles (p_pkt_ids   IN     VARCHAR2,
                                files_cur      OUT SYS_REFCURSOR);

    -- info: #89509 Доопрацювання Реєстру пакетів для обміну з мінфіном.
    -- завантаження квитанції через картку пакета ПЕОД
    -- params: p_pkt_out- Ід вихідного пакета ПЕОД, для якого завантажується КВ
    --         p_pkt_pat - тип пакета з наданого преліку
    --         p_pc_src_entity - ід пакета/файла в підсистемах реципієнта.
    -- note:
    --
    PROCEDURE create_pkt (
        p_pkt_out             packet.pkt_id%TYPE,
        p_pkt_pat             packet.pkt_pat%TYPE,
        p_pc_name             packet_content.pc_name%TYPE,
        p_pc_data             packet_content.pc_data%TYPE,
        p_pc_src_entity       packet_content.pc_src_entity%TYPE := NULL,
        p_pkt_id          OUT packet.pkt_id%TYPE);

    -- IC #97478
    -- Обробка квитанції повернення від пошти
    PROCEDURE create_post_pkt (
        p_pkt_pat             packet.pkt_pat%TYPE := 104, -- payroll_return_esr Соцдопомога. Квитанція повернення від пошти
        p_pc_name             packet_content.pc_name%TYPE,
        p_pc_data             packet_content.pc_data%TYPE,
        p_pc_src_entity       packet_content.pc_src_entity%TYPE := NULL,
        p_pkt_id          OUT packet.pkt_id%TYPE);
END Dnet$Packet;
/


GRANT EXECUTE ON IKIS_RBM.DNET$PACKET TO DNET_PROXY
/

GRANT EXECUTE ON IKIS_RBM.DNET$PACKET TO II01RC_RBMWEB_COMMON
/

GRANT EXECUTE ON IKIS_RBM.DNET$PACKET TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 6:10:49 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.DNET$PACKET
IS
    -- info:  журнал пакетів
    -- params: "Пошук: Вхідні":
    --         p_pkt_nes - Підсистема
    --         p_pkt_pat - Тип
    --         p_org_reg - Область
    --         p_org_distr - Район
    --         p_pkt_st - Статус
    --         p_pkt_dt_start - Дата створення з
    --         p_pkt_dt_stop -  Дата створення по
    --         p_pkt_rec - Адресат  /  Адресат (швидкий пошук)
    --         p_rds_pfu_dt_start - Автор
    --         p_pkt_id- Ід пакета в ПЕОД
    -- note:   «Перелік пакетів» - грід з такими полями:
    --- Ід пакета в ПЕОД
    --- Підсистема
    --- Дата створення
    --- Тип пакету
    --- ОПФУ
    --- Статус
    --- Автор
    --- Адресат
    --- Додаткова інформація
    --- Вміст
    PROCEDURE get_packet_list (
        p_pkt_nes             packet.pkt_nes%TYPE,
        p_pkt_pat             packet.pkt_pat%TYPE,
        p_org_reg             packet.pkt_org%TYPE,
        p_org_distr           packet.pkt_org%TYPE,
        p_pkt_st              packet.pkt_st%TYPE,
        p_pkt_dt_start        packet.pkt_create_dt%TYPE,
        p_pkt_dt_stop         packet.pkt_create_dt%TYPE,
        p_pkt_rec             packet.pkt_rec%TYPE,
        p_pkt_create_wu       packet.pkt_create_wu%TYPE,
        p_pkt_id              packet.pkt_id%TYPE,
        p_pat_direction       uss_ndi.v_ndi_packet_type.pat_direction%TYPE,
        p_npc_id              NUMBER,
        RES_CUR           OUT SYS_REFCURSOR)
    IS
        l_org_to   NUMBER := tools.GetCurrOrgTo;
        --l_org NUMBER := tools.getcurrorg;
        l_sql      VARCHAR2 (20000)
            := q'[select p.pkt_id, p.pkt_id as rbm_pkt_id,
   pkt_pat, pat.pat_sname as pkt_pat_name,
   pkt_org, op.org_name,
   pkt_st, pst.dic_sname as pkt_st_name,
   pkt_nes, s.nes_sname as pkt_nes_name,
   (select sum(pe_row_cnt)
      from uss_esr.v_payroll_reestr z
     where z.pe_rbm_pkt = p.pkt_id
   ) as pe_row_cnt,
   --wu.wu_pib||'('||wu.wu_login||')' as wu_name,
   wu.wu_login as wu_name,
   pkt_create_wu, wu.wu_login,
   pkt_rec, r.rec_name  ||'('||decode(rec_tp, 'MAIL', 'КБ', rec_tp)||')' as pkt_rec_name,
   p.pkt_create_dt,
   sign(nvl(pc.pc_pkt, 0)) as is_content
   , rec_tp
   , case when p.pkt_nes = 8 then  (select max(to_char(ikis_rbm.tools.get_xmlattr_clob(pc.pc_visual_data, 'H3'))) from IKIS_RBM.V_PACKET_CONTENT pc where pc.pc_pkt =  p.pkt_id)
          when pkt_pat = 101 then
              trim(to_char(to_number(tools.get_xmlattr_clob(pc_header, 'full_sum'))/100, '999999999999999999999990D00')) -- '999999999999999999999990D00' '999G999G999G999G999G999G999G990D00'
          else null
     end as  pkt_info,
     npc.npc_code as Pc_Npc_Code,
     npc.npc_code || ' ' || npc.npc_name as Pc_Npc_Name
from IKIS_RBM.V_Packet p
join uss_ndi.v_ndi_packet_type pat on pat.pat_id = p.pkt_pat
join uss_ndi.v_ndi_exchange_system s on s.nes_id = p.pkt_nes
join IKIS_RBM.V_OPFU_RBM op on op.org_id = p.pkt_org
left outer join IKIS_SYSWEB.V$w_Users_4gic wu on wu.wu_id = p.pkt_create_wu
join uss_ndi.V_DDN_PACKET_ST pst on pst.dic_value = p.pkt_st
left join IKIS_RBM.V_RECIPIENT_all r on r.rec_id = p.pkt_rec
left join IKIS_RBM.V_PACKET_CONTENT pc on pc.pc_pkt = p.pkt_id
left join uss_ndi.v_ndi_payment_codes npc on (npc.npc_id = pc.pc_npc)
where 1 = 1
]';
        l_flt      VARCHAR2 (4000);
    BEGIN
        tools.WriteMsg ('DNET$PACKET.' || $$PLSQL_UNIT);

        IF p_pkt_nes != -1
        THEN
            l_flt := l_flt || ' and p.pkt_nes = ' || p_pkt_nes;
        ELSE
            NULL;
        END IF;

        IF p_pkt_st != '~'
        THEN
            l_flt := l_flt || ' and p.pkt_st =''' || p_pkt_st || '''';
        ELSE
            NULL;
        END IF;

        IF p_pkt_pat != -1
        THEN
            l_flt := l_flt || ' and p.pkt_pat =' || p_pkt_pat;
        ELSE
            NULL;
        END IF;

        IF (l_org_to = 32)
        THEN
            l_flt := l_flt || ' and pc.pc_npc != 24 ';
        -- #90231, #99087
        ELSIF (l_org_to = 40)
        THEN
            l_flt := l_flt || ' and s.nes_id IN (102, 104, 105, 106) ';
        END IF;

        IF (p_npc_id IS NOT NULL)
        THEN
            l_flt := l_flt || ' and pc.pc_npc =' || p_npc_id;
        END IF;

        IF p_pkt_dt_start IS NOT NULL
        THEN
            l_flt :=
                   l_flt
                || ' and p.PKT_CREATE_DT >=
           trunc(to_date('''
                || TO_CHAR (p_pkt_dt_start, 'dd.mm.yyyy')
                || ''',''dd.mm.yyyy'')) ';
        END IF;

        IF p_pkt_dt_stop IS NOT NULL
        THEN
            l_flt :=
                   l_flt
                || ' and p.PKT_CREATE_DT <=
           trunc(to_date('''
                || TO_CHAR (p_pkt_dt_stop, 'dd.mm.yyyy')
                || ''',''dd.mm.yyyy'') + 1) ';
        END IF;

        ----------------------------------------------
        IF NVL (p_org_reg, -1) <> -1
        THEN
            l_flt :=
                   l_flt
                || ' and (op.ORG_ORG = '
                || p_org_reg
                || ' or  op.ORG_ID =  '
                || p_org_reg
                || ')';
        END IF;

        ---
        IF NVL (p_org_distr, -1) <> -1
        THEN
            l_flt := l_flt || ' and op.ORG_ID = ' || p_org_distr;
        END IF;

        ---
        IF NVL (p_pkt_rec, -1) <> -1
        THEN
            l_flt := l_flt || ' and r.rec_id = ' || p_pkt_rec;
        END IF;

        IF NVL (p_pkt_create_wu, -1) <> -1
        THEN
            l_flt := l_flt || ' and wu.wu_id = ' || p_pkt_create_wu;
        END IF;

        IF p_pkt_id IS NOT NULL
        THEN
            l_flt := l_flt || ' and p.pkt_id =' || p_pkt_id;
        ELSE
            NULL;
        END IF;

        IF p_pat_direction IS NOT NULL
        THEN
            l_flt :=
                   l_flt
                || ' and pat.pat_direction = '''
                || p_pat_direction
                || '''';
        ELSE
            NULL;
        END IF;

        l_sql := l_sql || l_flt || ' order by p.pkt_create_dt desc ';

        --raise_application_error(-20000, l_sql);
        --
        DBMS_OUTPUT.PUT_LINE (l_sql);

        OPEN res_cur FOR l_sql;
    END;


    -- info:  Картка пакета
    -- params: p_pkt_id- Ід пакета в ПЕОД
    -- note:
    PROCEDURE get_packet_card (p_pkt_id       packet.pkt_id%TYPE,
                               pkt_cur    OUT SYS_REFCURSOR,
                               pc_cur     OUT SYS_REFCURSOR,
                               ecp_cur    OUT SYS_REFCURSOR,
                               link_cur   OUT SYS_REFCURSOR,
                               log_cur    OUT SYS_REFCURSOR)
    IS
        l_org_to   NUMBER := tools.GetCurrOrgTo;
    BEGIN
        tools.WriteMsg ('DNET$PACKET.' || $$PLSQL_UNIT);

        OPEN pkt_cur FOR
            SELECT pkt_id,
                   p.pkt_nes,
                   s.nes_sname                            AS pkt_nes_name,
                   p.pkt_pat,
                   pat.pat_sname                          AS pkt_pat_name,
                   pat.pat_direction,
                   p.pkt_org,                                 /*op.org_sname*/
                   TOOLS.GetOrgSName (p.pkt_org)          AS Pkt_Org_Name,
                   p.pkt_st,
                   pst.dic_sname                          AS pkt_st_name,
                   pkt_create_dt,
                   p.pkt_create_wu,
                   wu1.wu_login                           wu_create_login,
                   NVL (wu1.wu_pib, '')                   wu_create_pib,
                   p.pkt_change_wu,
                   wu2.wu_login                           wu_change_login,
                   NVL (wu2.wu_pib, '')                   wu_change_pib,
                   pkt_change_dt,
                   pkt_rec,
                   r.rec_name                             AS pkt_rec_name,
                   CASE
                       WHEN pkt_pat = 101
                       THEN
                           TRIM (
                               TO_CHAR (
                                     TO_NUMBER (
                                         tools.get_xmlattr_clob (pc_header,
                                                                 'full_sum'))
                                   / 100,
                                   '999G999G999G999G999G999G999G990D00'))
                       ELSE
                           NULL
                   END                                    AS pkt_sum,
                   (SELECT SUM (pe_row_cnt)
                      FROM uss_esr.v_payroll_reestr z
                     WHERE z.pe_rbm_pkt = p.pkt_id)       AS pe_row_cnt,
                   npc.npc_code                           AS Pc_Npc_Code,
                   npc.npc_code || ' ' || npc.npc_name    AS Pc_Npc_Name
              FROM IKIS_RBM.Packet  p
                   JOIN ikis_rbm.v_packet_content pc ON pc_pkt = pkt_id
                   JOIN uss_ndi.v_ndi_packet_type pat
                       ON pat.pat_id = p.pkt_pat
                   JOIN uss_ndi.v_ndi_exchange_system s
                       ON s.nes_id = p.pkt_nes
                   JOIN uss_ndi.V_DDN_PACKET_ST pst
                       ON pst.dic_value = p.pkt_st
                   JOIN IKIS_RBM.V_RECIPIENT_all r ON r.rec_id = p.pkt_rec
                   JOIN IKIS_RBM.V_OPFU_RBM op ON op.org_id = p.pkt_org
                   LEFT OUTER JOIN IKIS_SYSWEB.v$w_users wu1
                       ON wu1.wu_id = p.pkt_create_wu
                   LEFT JOIN ikis_sysweb.v$w_users wu2
                       ON wu2.wu_id = p.pkt_change_wu
                   LEFT JOIN uss_ndi.v_ndi_payment_codes npc
                       ON (npc.npc_id = pc.pc_npc)
             WHERE     p.pkt_id = p_pkt_id
                   -- #90231, #99087
                   AND (   l_org_to != 40
                        OR     l_org_to = 40
                           AND s.nes_id IN (101,
                                            102,
                                            104,
                                            105,
                                            106));

        OPEN pc_cur FOR
            SELECT pc.pc_id,
                   pc.pc_pkt,
                   pc.pc_src_entity,
                   pct.dic_name     AS pc_tp_name,
                   pc.pc_name,
                   pc.pc_visual_data
              --pc.pc_data
              FROM ikis_rbm.v_packet_content  pc
                   LEFT JOIN uss_ndi.v_ddn_pkt_content_tp pct
                       ON pct.dic_value = pc.pc_tp
             WHERE pc.pc_pkt = p_pkt_id;

        OPEN ecp_cur FOR
            SELECT ecp.pce_id,
                   ecp.pce_pc,
                   ecp.pce_info,
                   ecp.com_wu,
                   ecp.pce_dt,
                   ecp.pce_ecp
              FROM ikis_rbm.packet_ecp  ecp
                   JOIN ikis_rbm.v_packet_content pc ON pce_pc = pc_id
             WHERE pc.pc_pkt = p_pkt_id;

        OPEN link_cur FOR
            SELECT p.pkt_id,
                   pat.pat_sname                     AS pkt_pat_name,
                   /*op.org_name*/
                   TOOLS.GetOrgSName (p.pkt_org)     AS Pkt_Org_Name,
                   pst.dic_sname                     AS pkt_st_name,
                   s.nes_sname                       AS pkt_nes_Name,
                   p.pkt_create_dt
              FROM IKIS_RBM.V_Packet  p
                   JOIN IKIS_RBM.v_packet_links pl
                       ON pl.pl_pkt_out = p.pkt_id
                   JOIN USS_NDI.V_NDI_EXCHANGE_SYSTEM s
                       ON s.nes_id = p.pkt_nes
                   JOIN USS_NDI.V_NDI_PACKET_TYPE pat
                       ON pat.pat_id = p.pkt_pat
                   /*join IKIS_RBM.V_OPFU_RBM op on op.org_id = p.pkt_org*/
                   JOIN USS_NDI.V_DDN_PACKET_ST pst
                       ON pst.dic_value = p.pkt_st
             WHERE pl.pl_pkt_in = p_pkt_id
            UNION ALL
            SELECT p.pkt_id                          AS lnk_pkt_id,
                   pat.pat_sname                     AS pkt_pat_name,
                   /*op.org_name*/
                   TOOLS.GetOrgSName (p.pkt_org)     AS Pkt_Org_Name,
                   pst.dic_sname                     AS pkt_st_name,
                   s.nes_sname                       AS pkt_nes_name,
                   p.pkt_create_dt
              FROM IKIS_RBM.V_Packet  p
                   JOIN IKIS_RBM.v_packet_links pl ON pl.pl_pkt_in = p.pkt_id
                   JOIN USS_NDI.V_NDI_EXCHANGE_SYSTEM s
                       ON s.nes_id = p.pkt_nes
                   JOIN USS_NDI.V_NDI_PACKET_TYPE pat
                       ON pat.pat_id = p.pkt_pat
                   /*join IKIS_RBM.V_OPFU_RBM op on op.org_id = p.pkt_org*/
                   JOIN USS_NDI.V_DDN_PACKET_ST pst
                       ON pst.dic_value = p.pkt_st
             WHERE pl.pl_pkt_out = p_pkt_id
            ORDER BY 1 DESC;

        OPEN log_cur FOR
              SELECT /*WU.Wu_Pib*/
                     WU.Wu_login      AS Wu_Name,
                     lp_atp,
                     atp.dic_name     AS Lp_Atp_Name,
                     lp.lp_dt,
                     lp.lp_comment
                FROM ikis_rbm.v_log_packet lp
                     LEFT JOIN ikis_sysweb.v$w_users_4gic wu
                         ON wu.wu_id = lp.lp_wu
                     LEFT JOIN uss_ndi.v_ddn_pkt_action_tp atp
                         ON atp.dic_value = lp.lp_atp
               WHERE lp_pkt = p_pkt_id
            ORDER BY lp_dt DESC;
    END;

    -- info:  Вивантаження вмісту пакета для підпису
    -- params: p_pkt_ids- Ід-и пакетів в ПЕОД, через кому
    -- note:   Тіло пакета тип 101 - заархівований json, підписувати - json
    --         #88329 + certs_cur - курсор з сертифікатами для шифрування
    PROCEDURE get_pkt_files4sign (p_pkt_ids       VARCHAR2,
                                  files_cur   OUT SYS_REFCURSOR,
                                  certs_cur   OUT SYS_REFCURSOR)
    IS
        l_pkt_pat   packet.pkt_pat%TYPE;
    BEGIN
        OPEN files_cur FOR
            SELECT pc.pc_id,
                   pc.pc_pkt,
                   pc.pc_name || '.json'
                       AS pc_file_name,
                   UTL_COMPRESS.lz_uncompress (pc.pc_data)
                       AS pc_file_data,
                   p.pkt_rec,                          -- #88329 ід реципієнта
                   -- #101884 pc.pc_header, -- #88329
                   CASE
                       WHEN rec_tp = 'CMES'
                       THEN
                           TO_CHAR (tools.utf8todeflang (pc_header))
                       ELSE
                           pc_header
                   END
                       AS pc_header,
                   CASE WHEN rec_tp = 'CMES' THEN 1 ELSE 0 END
                       AS is_pkt2encrypt,
                   pc.pc_data,
                   -- #101884 case when rec_tp = 'CMES' then utl_compress.lz_uncompress(pc.pc_data) else pc.pc_data end as pc_data,
                   pkt_id
              FROM v_packet  p
                   JOIN ikis_rbm.v_packet_content pc ON pc_pkt = pkt_id
                   JOIN ikis_rbm.recipient r ON pkt_rec = rec_id
             WHERE     pkt_pat = 101
                   AND pkt_id IN
                           (    SELECT REGEXP_SUBSTR (text,
                                                      '[^(\,)]+',
                                                      1,
                                                      LEVEL)    AS x_pkt_id
                                  FROM (SELECT p_pkt_ids AS text FROM DUAL)
                            CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                              '[^(\,)]+',
                                                              1,
                                                              LEVEL)) > 0)
            UNION ALL
            SELECT pc.pc_id,
                   pc.pc_pkt,
                   pc.pc_name
                       AS pc_file_name,
                   pc.pc_data
                       AS pc_file_data,
                   p.pkt_rec,                                 -- ід реципієнта
                   pc.pc_header,                                     -- #88329
                   CASE WHEN rec_tp = 'CMES' THEN 1 ELSE 0 END
                       AS is_pkt2encrypt,
                   pc.pc_data,
                   pkt_id
              FROM v_packet  p
                   JOIN ikis_rbm.v_packet_content pc ON pc_pkt = pkt_id
                   JOIN ikis_rbm.recipient r ON pkt_rec = rec_id
             WHERE     pkt_pat != 101
                   AND pkt_id IN
                           (    SELECT REGEXP_SUBSTR (text,
                                                      '[^(\,)]+',
                                                      1,
                                                      LEVEL)    AS x_pkt_id
                                  FROM (SELECT p_pkt_ids AS text FROM DUAL)
                            CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                              '[^(\,)]+',
                                                              1,
                                                              LEVEL)) > 0);

        OPEN certs_cur FOR
            SELECT rec_id, rc.rmc_cert
              FROM ikis_rbm.recipient  r
                   JOIN ikis_rbm.recipient_mail rm ON rm_rec = rec_id
                   JOIN ikis_rbm.rm_certificates rc ON rmc_rm = rm_id
             WHERE     rc.rmc_st = 'A'                              -- період?
                   AND NVL (rc.rmc_expire_dt, SYSDATE) >= SYSDATE -- IC #109559
                   AND rec_tp = 'CMES'
                   AND rec_id IN
                           (SELECT pkt_rec
                              FROM v_packet  p,
                                   (    SELECT REGEXP_SUBSTR (text,
                                                              '[^(\,)]+',
                                                              1,
                                                              LEVEL)    AS x_pkt_id
                                          FROM (SELECT p_pkt_ids     AS text
                                                  FROM DUAL)
                                    CONNECT BY LENGTH (
                                                   REGEXP_SUBSTR (text,
                                                                  '[^(\,)]+',
                                                                  1,
                                                                  LEVEL)) >
                                               0) t
                             WHERE t.x_pkt_id = p.pkt_id);
    /*  select pkt_pat into l_pkt_pat
      from v_packet
      where pkt_id = p_pkt_id;

      if l_pkt_pat = 101 then
        OPEN files_cur FOR
        select
          pc.pc_id,
          pc.pc_pkt,
          pc.pc_name||'.json' as pc_file_name,
          utl_compress.lz_uncompress(pc.pc_data) as pc_file_data
        from  ikis_rbm.v_packet_content pc
        where pc.pc_pkt = p_pkt_id;
      else
        OPEN files_cur FOR
        select
          pc.pc_id,
          pc.pc_pkt,
          pc.pc_name as pc_file_name,
          pc.pc_data as pc_file_data
        from  ikis_rbm.v_packet_content pc
        where pc.pc_pkt = p_pkt_id;
      end if; */
    END;

    -- info:  Збереження підпису вмісту пакета
    -- params: p_pc_id- Ід вмісту пакета в ПЕОД
    -- note:   після підпису - змінюємо статус пакета на NVP
    --          #88329 +  p_pc_encrypt_data
    PROCEDURE save_pkt_sign (
        p_pc_id             ikis_rbm.v_packet_ecp.pce_pc%TYPE,
        p_pce_ecp           ikis_rbm.v_packet_ecp.pce_ecp%TYPE,
        p_pce_info          ikis_rbm.v_packet_ecp.pce_info%TYPE,
        p_pc_encrypt_data   ikis_rbm.v_packet_content.pc_encrypt_data%TYPE)
    IS
        --l_pc_id   ikis_rbm.v_packet_ecp.pce_pc%type;
        l_pkt_st    ikis_rbm.v_packet.pkt_st%TYPE;
        l_pkt_id    ikis_rbm.v_packet.pkt_id%TYPE;
        l_wu        NUMBER
            := SYS_CONTEXT (ikis_rbm_context.gContext, ikis_rbm_context.gUID);
        l_pc_id     ikis_rbm.v_packet_content.pc_id%TYPE;
        l_rec_tp    recipient.rec_tp%TYPE;
        l_pc_blob   BLOB;
    --l_encr_blob  blob;
    BEGIN
        IF NVL (DBMS_LOB.getlength (p_pce_ecp), 0) < 10
        THEN
            raise_application_error (
                -20000,
                'Помилка збереження підпису: файл ЕЦП порожній!');
        END IF;

        --raise_application_error(-20000, 'p_pc_id='||p_pc_id||';p_pce_ecp='||p_pce_ecp||';p_pce_info='||p_pce_info);
        SELECT pkt_id,
               pkt_st,
               pc_id,
               rec_tp,
               pc_data                                  --, pc.pc_encrypt_data
          INTO l_pkt_id,
               l_pkt_st,
               l_pc_id,
               l_rec_tp,
               l_pc_blob                                       --, l_encr_blob
          FROM ikis_rbm.v_packet
               JOIN ikis_rbm.v_packet_content pc ON pc_pkt = pkt_id
               JOIN ikis_rbm.recipient r ON pkt_rec = rec_id
         WHERE pc_id = p_pc_id;

        RDM$PACKET_CONTENT.SaveSign (p_pce_id     => NULL,
                                     p_pce_pc     => p_pc_id,
                                     p_pce_ecp    => p_pce_ecp,
                                     p_pce_info   => p_pce_info);

        ------------------------- io 20230809 заглушка для КБ перед установкою на пром бажано прибрати !!!
        IF l_rec_tp = 'CMES' AND p_pc_encrypt_data IS NOT NULL
        THEN
            RDM$PACKET_CONTENT.SavePacketEncryptData (
                p_pc_id             => l_pc_id,
                p_pc_encrypt_data   => p_pc_encrypt_data);
        END IF;

        -- Автоматична відправка після підпису - змінюємо статус пакета на NVP
        /*  if l_pkt_st in ('N', 'SGN') then
            send_packets(l_pkt_id);
          end if;*/
        IF l_pkt_st IN ('N')
        THEN
            rdm$packet.Set_Packet_State (p_Pkt_Id          => l_pkt_id,
                                         p_Pkt_St          => 'SGN',
                                         p_Pkt_Change_Wu   => l_wu,
                                         p_Pkt_Change_Dt   => SYSDATE);
        END IF;
    END;

    -- info:  Вивантаження вмісту пакетів для передачі в ПФУ
    -- params: p_pkt_ids- Ід-и пакетів в ПЕОД, через кому
    -- note:
    PROCEDURE get_packet_files (p_pkt_ids       VARCHAR2,
                                files_cur   OUT SYS_REFCURSOR)
    IS
    BEGIN
        tools.WriteMsg ('DNET$PACKET.' || $$PLSQL_UNIT);

        OPEN files_cur FOR
            SELECT pc.pc_id,
                   pc.pc_pkt,
                   pc.pc_name || '.zip'                         AS pc_file_name,
                   RDM$APP_EXCHANGE.Get_pkt_file (pc.pc_pkt)    AS pc_file_data
              FROM ikis_rbm.v_packet_content pc
             WHERE pc.pc_pkt IN
                       (    SELECT REGEXP_SUBSTR (text,
                                                  '[^(\,)]+',
                                                  1,
                                                  LEVEL)    AS x_pkt_id
                              FROM (SELECT p_pkt_ids AS text FROM DUAL)
                        CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                          '[^(\,)]+',
                                                          1,
                                                          LEVEL)) > 0);
    END;

    -- info:  Відправка пакетів (зміна статусу на NVP)
    -- params: p_pkt_ids- Ід-и пакетів в ПЕОД, через кому
    -- note:  статус змінюється лише для вихідних пакетів в статусах N - новий, SGN - підписаний
    --        к-ть ЕЦП на яких не менше мінінмально необхідної = uss_ndi.v_ndi_packet_type.pat_min_ect_cnt
    PROCEDURE send_packets (p_pkt_ids VARCHAR2)
    IS
        l_pce_cnt       NUMBER;
        l_wu            NUMBER
            := SYS_CONTEXT (ikis_rbm_context.gContext, ikis_rbm_context.gUID);
        l_nvp_cnt       NUMBER := 0;
        l_nvp_pkt_ids   VARCHAR2 (10000) := '';
        l_ur_id         NUMBER;
    BEGIN
        FOR pkt
            IN (SELECT pkt_id,
                       pkt_st,
                       pkt_pat,
                       pat_min_ect_cnt,
                       pc_id,
                       rec_id,
                       rec_tp,
                       CASE
                           WHEN c.pc_encrypt_data IS NOT NULL
                           THEN
                               DBMS_LOB.getlength (c.pc_encrypt_data)
                       END    AS encrypt_size
                  FROM ikis_rbm.v_packet  p
                       JOIN ikis_rbm.v_packet_content c ON pc_pkt = pkt_id
                       JOIN uss_ndi.v_ndi_packet_type t
                           ON pkt_pat = pat_id AND t.pat_direction = 'O'
                       JOIN ikis_rbm.v_recipient r ON pkt_rec = rec_id
                 WHERE     pkt_st IN (                               /*'N', */
                                      'SGN')
                       AND p.pkt_id IN
                               (    SELECT REGEXP_SUBSTR (text,
                                                          '[^(\,)]+',
                                                          1,
                                                          LEVEL)    AS x_pkt_id
                                      FROM (SELECT p_pkt_ids AS text FROM DUAL)
                                CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                                  '[^(\,)]+',
                                                                  1,
                                                                  LEVEL)) > 0))
        LOOP
            SELECT COUNT (1)
              INTO l_pce_cnt
              FROM ikis_rbm.v_packet_ecp pce
             WHERE     pce_pc = pkt.pc_id
                   AND pce_ecp IS NOT NULL
                   AND DBMS_LOB.getlength (pce_ecp) > 10;

            IF     l_pce_cnt >= pkt.pat_min_ect_cnt
               AND (   pkt.rec_tp = 'IC'
                    OR pkt.rec_tp = 'CMES' AND pkt.encrypt_size > 10)
            THEN
                rdm$packet.Set_Packet_State (p_Pkt_Id          => pkt.pkt_id,
                                             p_Pkt_St          => 'NVP',
                                             p_Pkt_Change_Wu   => l_wu,
                                             p_Pkt_Change_Dt   => SYSDATE);
                l_nvp_cnt := l_nvp_cnt + 1;
                l_nvp_pkt_ids := l_nvp_pkt_ids || pkt.pkt_id || ',';
            END IF;
        END LOOP;

        -- реєструємо запит на передачу пакетів в ПФУ
        IF l_nvp_cnt > 0
        THEN
            l_ur_id :=
                rdm$app_exchange_pfu.register_pkt_request (
                    p_pkt_ids   => l_nvp_pkt_ids);
        END IF;
    END;


    -- Вивантаження КВ-1/2
    -- p_pkt_list - перелік Ід пакетів через ,
    -- files_cur : l_filename,  l_content, mimetype, size
    PROCEDURE DownloadPktFiles (p_pkt_ids   IN     VARCHAR2,
                                files_cur      OUT SYS_REFCURSOR)
    IS
        l_content          packet_content.pc_data%TYPE;
        l_filename         packet_content.pc_name%TYPE;
        l_comment          log_packet.lp_comment%TYPE;
        l_files            ikis_sysweb.tbl_some_files
                               := ikis_sysweb.tbl_some_files ();
        l_pkt_files        ikis_sysweb.tbl_some_files
                               := ikis_sysweb.tbl_some_files ();
        l_change_wu        log_packet.lp_wu%TYPE
            := SYS_CONTEXT (ikis_rbm_context.gcontext, ikis_rbm_context.guid);
        l_ecp_blob         BLOB;
        l_file_idn         VARCHAR2 (50);
        l_cnt              NUMBER;
        exBadPktSt         EXCEPTION;
        exBadPktTp         EXCEPTION;
        l_is_origin_file   BOOLEAN := FALSE;
    BEGIN
        -- Контроль на сумарний розмір?\
        /* select count(1) into l_cnt
         from packet p
         where pkt_id in (
                   select regexp_substr(text ,'[^(\,)]+', 1, level)  as x_pkt_id
                   from (select p_pkt_ids as text from dual)
                   connect by length(regexp_substr(text ,'[^(\,)]+', 1, level)) > 0)
          -- and pkt_pt not in (select pt_id from packet_type where pt_es= 7 and pt_direction = 'I')
           ;

          if l_cnt > 0 then
            raise exBadPktTp;
          end if; */

        FOR pp
            IN (SELECT pc.pc_id,
                       pc.pc_data,
                       pc.pc_name,
                       pc_pkt,
                       pc.pc_file_idn,
                       pc.pc_main_tag_name
                  --             , p.pkt_pat, p.pkt_nes
                  FROM packet_content pc
                 --        join packet p on pc.pc_pkt=p.pkt_id
                 WHERE pc_pkt IN
                           (    SELECT REGEXP_SUBSTR (text,
                                                      '[^(\,)]+',
                                                      1,
                                                      LEVEL)    AS x_pkt_id
                                  FROM (SELECT p_pkt_ids AS text FROM DUAL)
                            CONNECT BY LENGTH (REGEXP_SUBSTR (text,
                                                              '[^(\,)]+',
                                                              1,
                                                              LEVEL)) > 0))
        LOOP
            l_content := NULL;
            l_filename := '';
            l_files := ikis_sysweb.tbl_some_files ();

            IF pp.pc_file_idn IS NOT NULL AND pp.pc_data IS NULL
            THEN
                l_content :=
                    ikis_sysweb.ikis_file_archive.getFile (
                        p_file_idn   => pp.pc_file_idn);
            ELSE
                l_content := pp.pc_data;
            END IF;

            l_is_origin_file :=
                   pp.pc_main_tag_name = 'EISC01'
                OR pp.pc_main_tag_name = 'EISF01'
                OR pp.pc_main_tag_name = 'EIS2MFU'
                OR pp.pc_main_tag_name = 'MSP2DCZVPOLI'
                OR                                                    --#97845
                   pp.pc_main_tag_name = 'DCZ2MSP'
                OR                                                    --#97845
                   pp.pc_main_tag_name = 'MSP2DPS'
                OR                                                    --#97928
                   pp.pc_main_tag_name = 'DPS2MSP'
                OR                                                    --#97928
                   pp.pc_main_tag_name = 'UNI2MSP'                    --#99087
                                                  ;

            --ikis_sysweb.ikis_debug_pipe.WriteMsg('pc_main_tag_name: ' || pp.pc_main_tag_name);
            IF DBMS_LOB.getlength (l_content) > 10
            THEN
                IF l_is_origin_file
                THEN -- 16/10/2023 serhii: #92025 для файлів Верифікація Мінфіну
                    l_filename := pp.pc_name;
                ELSE
                    l_filename := pp.pc_name || '_' || pp.pc_pkt || '.zip';
                END IF;

                l_files.EXTEND;
                l_files (l_files.LAST) :=
                    ikis_sysweb.t_some_file_info (l_filename, l_content); /* ||'.zip' */

                FOR r_ecp
                    IN (  SELECT ROWNUM AS rn, c.*
                            FROM packet_ecp c
                           WHERE     c.pce_pc = pp.pc_id
                                 AND c.pce_ecp IS NOT NULL
                                 AND DBMS_LOB.getlength (c.pce_ecp) > 10
                        ORDER BY pce_dt)
                LOOP
                    l_ecp_blob := NULL;

                    BEGIN
                        l_ecp_blob := HEXTORAW (r_ecp.pce_ecp);
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            l_ecp_blob := tools.ConvertC2B (r_ecp.pce_ecp);
                    END;

                    l_files.EXTEND;
                    l_files (l_files.LAST) :=
                        ikis_sysweb.t_some_file_info (
                            l_filename || '_ecp' || r_ecp.rn || '.p7s',
                            l_ecp_blob /* #74223 tools.ConvertC2B(r_ecp.pce_ecp)*/
                                      );
                END LOOP;
            ELSE
                ---htp.p('Не вдалося отримати вміст пакета ід = '||pp.pc_pkt||'!');
                NULL; -- raise_application_error(-20000, 'Не вдалося отримати вміст пакета ід = '||pp.pc_pkt||'!');
            END IF;

            IF l_files.COUNT > 0 AND NOT l_is_origin_file
            THEN
                l_content :=
                    ikis_sysweb.ikis_web_jutil.getZipFromStrms (l_files);
            END IF;

            -- додаємо до загального архіву
            IF l_content IS NOT NULL AND DBMS_LOB.getlength (l_content) > 0
            THEN
                l_pkt_files.EXTEND;
                l_pkt_files (l_pkt_files.LAST) :=
                    ikis_sysweb.t_some_file_info (l_filename || '.zip',
                                                  l_content);
            END IF;

            /*    Rdm$packet.Set_Packet_State(v_Pkt_Id => pp.pc_pkt,
                                            v_Pkt_St => 'M',
                                            v_Pkt_Change_Wu => l_change_wu,
                                            v_Pkt_Change_Dt => sysdate);*/

            /* vставка логу */
            RDM$LOG_PACKET.insert_message (
                p_lp_pkt       => pp.pc_pkt,
                p_lp_wu        => l_change_wu,
                p_lp_atp       => ikis_const.v_ddn_action_tp_unl,
                p_lp_comment   => NULL);
        END LOOP;

        IF l_pkt_files.COUNT > 0
        THEN
            IF l_is_origin_file
            THEN
                NULL;
            ELSE
                l_filename :=
                       'pkt_'
                    || TO_CHAR (SYSDATE, 'yyyymmdd_hh24miss')
                    || '.zip';
                l_content :=
                    ikis_sysweb.ikis_web_jutil.getZipFromStrms (l_pkt_files);
                l_comment := 'Файл ' || l_filename || ' вивантажено з БД.';
            END IF;

            OPEN files_cur FOR
                SELECT l_filename                         AS filename,
                       l_content                          AS content,
                       DBMS_LOB.getlength (l_content)     AS x_size,
                       'application/zip'                  AS mimetype
                  FROM DUAL;
        /*  -- pkt_st N=>M
            for pp in (
              select  pc_pkt
              from packet_content pc
              join packet on pkt_id = pc_pkt
              where pc_pkt in (select to_number(column_value) from APEX_STRING.SPLIT(p_pkt_list, ':'))
                and pkt_st = 'N')
           loop
            set_pkt_st_MOD(pp.pc_pkt, l_change_wu);
           end loop;
           */
        ELSE
            NULL;                                  -- htp.p('Файл порожній!');
        END IF;
    EXCEPTION
        WHEN exBadPktSt
        THEN
            ExceptionRBM (
                'Dnet$Packet.DownloadPktFiles',
                'Заборонено вивантажувати файли невідправлених пакетів');
        WHEN exBadPktTp
        THEN
            ExceptionRBM (
                'Dnet$Packet.DownloadPktFiles',
                'Вивантажувати можна лише файли квитанцій на пакети підсистеми Дія');
        WHEN OTHERS
        THEN
            ExceptionRBM (
                'Dnet$Packet.DownloadPktFiles',
                   CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    -- info: #89509 Доопрацювання Реєстру пакетів для обміну з мінфіном.
    -- завантаження квитанції через картку пакета ПЕОД
    -- params: p_pkt_out- Ід вихідного пакета ПЕОД, для якого завантажується КВ
    --         p_pkt_pat - тип пакета з наданого преліку
    --         p_pc_src_entity - ід пакета/файла в підсистемах реципієнта.
    -- note:
    --
    PROCEDURE create_pkt (
        p_pkt_out             packet.pkt_id%TYPE,
        p_pkt_pat             packet.pkt_pat%TYPE,
        p_pc_name             packet_content.pc_name%TYPE,
        p_pc_data             packet_content.pc_data%TYPE,
        p_pc_src_entity       packet_content.pc_src_entity%TYPE := NULL,
        p_pkt_id          OUT packet.pkt_id%TYPE)
    IS
        l_com_wu             packet.pkt_create_wu%TYPE := NULL;
        l_pkt_row            packet%ROWTYPE;

        l_pc_tp              packet_content.pc_tp%TYPE := 'F';
        l_pc_visual_data     packet_content.pc_visual_data%TYPE := NULL;
        l_pc_main_tag_name   packet_content.pc_main_tag_name%TYPE := NULL;
        l_pc_data_name       packet_content.pc_data_name%TYPE := NULL;
        l_pc_ecp_list_name   packet_content.pc_ecp_list_name%TYPE := NULL;
        l_pc_ecp_name        packet_content.pc_ecp_name%TYPE := NULL;
        l_pc_ecp_alg         packet_content.pc_ecp_alg%TYPE := NULL;
        l_pc_header          packet_content.pc_header%TYPE := NULL;
        l_pc_ecp             packet_ecp.pce_ecp%TYPE := NULL;
        l_cnt                PLS_INTEGER;
        l_lock               ikis_rbm.tools.t_lockhandler;
    BEGIN
        SELECT p.*
          INTO l_pkt_row
          FROM packet p
         WHERE pkt_id = p_pkt_out;

        --ikis_sysweb.ikis_debug_pipe.WriteMsg('create_pkt starts');
        -- контролі ???

        ikis_rbm.TOOLS.RequestDBLock (p_name                => p_pc_name,
                                      p_release_on_commit   => TRUE,
                                      p_lockhandler         => l_lock); --#96537-10

        -- serhii: #94322 контроль на повторне завантаження одного й того ж файлу рекомендацій
        SELECT COUNT (*)
          INTO l_cnt
          FROM packet_links  l
               JOIN packet p
                   ON     l.pl_pkt_in = p.pkt_id
                      AND p.pkt_pat IN (107,
                                        109,
                                        113,
                                        121,
                                        123)
                      AND p.pkt_st IN ('PRC', 'N')
               JOIN packet_content c ON c.pc_pkt = p.pkt_id
         WHERE l.pl_pkt_out = p_pkt_out AND c.pc_name = p_pc_name;

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                'Файл "' || TO_CHAR (p_pc_name) || '" вже завантажувався!');
        END IF;

        p_pkt_id :=
            rdm$packet.insert_packet (p_Pkt_pat         => p_pkt_pat,
                                      p_Pkt_nes         => l_pkt_row.pkt_nes,
                                      p_Pkt_org         => l_pkt_row.pkt_org,
                                      p_Pkt_st          => 'N',
                                      p_Pkt_create_wu   => l_com_wu,
                                      p_Pkt_create_dt   => SYSDATE,
                                      p_Pkt_change_wu   => NULL,
                                      p_Pkt_change_dt   => NULL,
                                      p_Pkt_rec         => l_pkt_row.pkt_rec);

        rdm$packet_content.insert_packet_content (
            p_pc_pkt             => p_pkt_id,
            p_pc_tp              => l_pc_tp,
            p_pc_name            => p_pc_name,
            p_pc_data            => p_pc_data,
            p_pc_pkt_change_wu   => l_com_wu,
            p_pc_pkt_change_dt   => SYSDATE,
            p_pc_visual_data     => l_pc_visual_data,
            p_pc_main_tag_name   => l_pc_main_tag_name,
            p_pc_data_name       => l_pc_data_name,
            p_pc_ecp_list_name   => l_pc_ecp_list_name,
            p_pc_ecp_name        => l_pc_ecp_name,
            p_pc_ecp_alg         => l_pc_ecp_alg,
            p_pc_src_entity      => p_pc_src_entity,
            p_pc_header          => l_pc_header);


        Rdm$packet.Insert_Packet_Link (p_Pkt_Prev   => p_pkt_out,
                                       p_Pkt_Id     => p_Pkt_Id);

        IF p_pkt_pat IN (107                                        /*#97845*/
                            ,
                         109                                        /*#97928*/
                            ,
                         113                                      /*#92749-4*/
                            ,
                         121,
                         123                                        /*#99087*/
                            ,
                         124                                       /*#106684*/
                            )
        THEN
            --ikis_sysweb.ikis_debug_pipe.WriteMsg('packet Id: '||p_Pkt_Id);
            uss_esr.API$MASS_EXCHANGE.Parse_File_On_Upload (p_Pkt_Id,
                                                            p_Pkt_Pat);
        END IF;
    --ikis_sysweb.ikis_debug_pipe.WriteMsg('create_pkt ends');
    END;

    -- IC #97478
    -- Обробка квитанції повернення від пошти
    PROCEDURE create_post_pkt (
        p_pkt_pat             packet.pkt_pat%TYPE := 104, -- payroll_return_esr Соцдопомога. Квитанція повернення від пошти
        p_pc_name             packet_content.pc_name%TYPE,
        p_pc_data             packet_content.pc_data%TYPE,
        p_pc_src_entity       packet_content.pc_src_entity%TYPE := NULL,
        p_pkt_id          OUT packet.pkt_id%TYPE)
    IS
        l_com_wu             packet.pkt_create_wu%TYPE := NULL;
        l_pkt_row            packet%ROWTYPE;

        l_pc_tp              packet_content.pc_tp%TYPE := 'F';
        l_pc_visual_data     packet_content.pc_visual_data%TYPE := NULL;
        l_pc_main_tag_name   packet_content.pc_main_tag_name%TYPE := NULL;
        l_pc_data_name       packet_content.pc_data_name%TYPE := NULL;
        l_pc_ecp_list_name   packet_content.pc_ecp_list_name%TYPE := NULL;
        l_pc_ecp_name        packet_content.pc_ecp_name%TYPE := NULL;
        l_pc_ecp_alg         packet_content.pc_ecp_alg%TYPE := NULL;
        l_pc_header          packet_content.pc_header%TYPE := NULL;
        l_pc_ecp             packet_ecp.pce_ecp%TYPE := NULL;
        l_cnt                PLS_INTEGER;
    BEGIN
        SELECT COUNT (*)
          INTO l_cnt
          FROM packet p JOIN packet_content c ON c.pc_pkt = p.pkt_id
         WHERE     p.pkt_pat = 104
               AND p.pkt_st IN ('PRC', 'N')
               AND c.pc_name = p_pc_name;

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                'Файл "' || TO_CHAR (p_pc_name) || '" вже завантажувався!');
        END IF;

        p_pkt_id :=
            rdm$packet.insert_packet (p_Pkt_pat         => p_pkt_pat,
                                      p_Pkt_nes         => 101, -- Єдина інформаційна система соціальної сфери
                                      p_Pkt_org         => NULL, -- інформація в середині файлу
                                      p_Pkt_st          => 'N',
                                      p_Pkt_create_wu   => l_com_wu,
                                      p_Pkt_create_dt   => SYSDATE,
                                      p_Pkt_change_wu   => NULL,
                                      p_Pkt_change_dt   => NULL,
                                      p_Pkt_rec         => 150); -- ПОШТА "Головне відділення"

        rdm$packet_content.insert_packet_content (
            p_pc_pkt             => p_pkt_id,
            p_pc_tp              => l_pc_tp,
            p_pc_name            => p_pc_name,
            p_pc_data            => p_pc_data,
            p_pc_pkt_change_wu   => l_com_wu,
            p_pc_pkt_change_dt   => SYSDATE,
            p_pc_visual_data     => l_pc_visual_data,
            p_pc_main_tag_name   => l_pc_main_tag_name,
            p_pc_data_name       => l_pc_data_name,
            p_pc_ecp_list_name   => l_pc_ecp_list_name,
            p_pc_ecp_name        => l_pc_ecp_name,
            p_pc_ecp_alg         => l_pc_ecp_alg,
            p_pc_src_entity      => p_pc_src_entity,
            p_pc_header          => l_pc_header);
    END create_post_pkt;
BEGIN
    NULL;
END Dnet$Packet;
/