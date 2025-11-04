/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.IKIS_RBM_RPT
IS
    -- Author  : OIVASHCHUK
    -- Created : 15.08.2016 18:12:18
    -- Purpose : RBM reports

    PROCEDURE GetRPT1;
END IKIS_RBM_RPT;
/


GRANT EXECUTE ON IKIS_RBM.IKIS_RBM_RPT TO IKIS_WEBPROXY
/


/* Formatted on 8/12/2025 6:10:50 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.IKIS_RBM_RPT
IS
    PROCEDURE GetRPT1
    IS
        l_rpt            BLOB;
        l_buff           VARCHAR2 (32760);
        l_cursor         BINARY_INTEGER DEFAULT DBMS_SQL.open_cursor;
        l_cnt            NUMBER;
        --l_value  varchar2(1000);
        l_sql            VARCHAR2 (32760);
        l_pnf            NUMBER := 0;
        l_filename       VARCHAR2 (100)
            :=    'rbm_stat_rpt_'
               || TO_CHAR (SYSDATE, 'yyyymmdd_hh24miss')
               || '.csv';


        pkt_id           VARCHAR2 (20);                              --number;
        pkt_create_dt    VARCHAR2 (20);                                --date;
        pkt_org          VARCHAR2 (5);
        org_name         VARCHAR2 (200);
        pkt_es           VARCHAR2 (50);
        pkt_pt           VARCHAR2 (50);
        packet_st        VARCHAR2 (50);
        last_oper_dt     VARCHAR2 (20);                                --date;
        recipient_name   VARCHAR2 (50);
        file_names       VARCHAR2 (250);
        file_cnt         VARCHAR2 (20);                              --number;

        GetRTP1Query     VARCHAR2 (4000)
            := 'select
      p.pkt_id,
    --Дата створення
      p.pkt_create_dt,
    --ОПФУ
      p.pkt_org,
      op.org_name,
    -- подсистема
      ess.es_sname  pkt_es ,
    -- тип конверта
      ptp.pt_sname pkt_pt ,
    --Статус
      pst.DIC_NAME packet_st,
    --дата останьої операції
      p.pkt_change_dt  last_oper_dt,
    --Адресат
      r.rec_name recipient_name,
    --назва файлу
      rtrim(dbms_lob.substr(XMLAGG(XMLELEMENT(E,pc.pc_name||'','')).EXTRACT(''//text()'').getClobVal(),2000,1),'','')  file_names,
      count(*) file_cnt
    from ikis_rbm.v_packet p
    join IKIS_RBM.V_OPFU_RBM op
      on op.org_id = p.pkt_org
    join ikis_rbm.v_ddn_packet_st pst
      on p.pkt_st = pst.DIC_CODE
    join ikis_rbm.v_packet_type ptp
      on p.pkt_pt = ptp.pt_id
    join ikis_rbm.v_exchange_subsystem ess
      on p.pkt_es = es_id
    left join ikis_rbm.v_recipient r
      on r.rec_id = p.pkt_rec
    left join ikis_rbm.v_packet_content pc
      on pc.pc_pkt = p.pkt_id
    where 1 = 1 -- payroll_pvp
      and (:P200_PKT_CREATE_DT_FROM is null or (:P200_PKT_CREATE_DT_FROM is not null and p.pkt_create_dt >= to_date(:P200_PKT_CREATE_DT_FROM, ''dd.mm.yyyy'')))
      and (:P200_PKT_CREATE_DT_TO is null or (:P200_PKT_CREATE_DT_TO is not null and p.pkt_create_dt < to_date(:P200_PKT_CREATE_DT_TO, ''dd.mm.yyyy'') + 1))
      and (nvl(:P200_OPFU, ''-1'') = ''-1'' or (nvl(:P200_OPFU, ''-1'') != ''-1'' and nvl(:P200_RPFU, ''~'') =''~'' and p.pkt_org in (select org_id from ikis_sysweb.V$V_OPFU_ALL where org_org = :P200_OPFU union all select to_number(:P200_OPFU) from dual)) or nvl(:P200_RPFU, ''~'') !=''~'')
      and (nvl(:P200_RPFU, ''~'') =''~'' or (nvl(:P200_RPFU, ''~'') != ''~'' and p.pkt_org = :P200_RPFU))
      and (nvl(:P200_SUBSYS, ''~'') =''~'' or (nvl(:P200_SUBSYS, ''~'') !=''~'' and to_char(p.pkt_es) = :P200_SUBSYS))
      and (nvl(:P200_PKT_TP, ''~'') =''~'' or (nvl(:P200_PKT_TP, ''~'') !=''~'' and to_char(p.pkt_pt) = :P200_PKT_TP))
      and (nvl(:P200_PKT_ST, ''~'') =''~'' or (nvl(:P200_PKT_ST, ''~'') !=''~'' and to_char(p.pkt_st) = :P200_PKT_ST))
    group by
      p.pkt_id,
      p.pkt_create_dt,
      p.pkt_org,
      op.org_name,
      pst.DIC_NAME,
      p.pkt_change_dt,
      p.pkt_rec,
      r.rec_name,
      ess.es_sname,
      ptp.pt_sname
    order by p.pkt_org, p.pkt_create_dt desc';
        l_spr            VARCHAR2 (1) := ';';
    BEGIN
        DBMS_LOB.createtemporary (lob_loc => l_rpt, CACHE => TRUE);
        DBMS_LOB.OPEN (lob_loc => l_rpt, open_mode => DBMS_LOB.lob_readwrite);
        l_sql := GetRTP1Query;

        DBMS_SQL.parse (C               => l_cursor,
                        STATEMENT       => l_sql,
                        language_flag   => DBMS_SQL.native);
        DBMS_SQL.DEFINE_COLUMN (l_cursor,
                                1,
                                pkt_id,
                                100);
        DBMS_SQL.DEFINE_COLUMN (l_cursor,
                                2,
                                pkt_create_dt,
                                20);
        DBMS_SQL.DEFINE_COLUMN (l_cursor,
                                3,
                                pkt_org,
                                5);
        DBMS_SQL.DEFINE_COLUMN (l_cursor,
                                4,
                                org_name,
                                100);
        DBMS_SQL.DEFINE_COLUMN (l_cursor,
                                5,
                                pkt_es,
                                50);
        DBMS_SQL.DEFINE_COLUMN (l_cursor,
                                6,
                                pkt_pt,
                                50);
        DBMS_SQL.DEFINE_COLUMN (l_cursor,
                                7,
                                packet_st,
                                50);
        DBMS_SQL.DEFINE_COLUMN (l_cursor,
                                8,
                                last_oper_dt,
                                20);
        DBMS_SQL.DEFINE_COLUMN (l_cursor,
                                9,
                                recipient_name,
                                100);
        DBMS_SQL.DEFINE_COLUMN (l_cursor,
                                10,
                                file_names,
                                250);
        DBMS_SQL.DEFINE_COLUMN (l_cursor,
                                11,
                                file_cnt,
                                10);

        DBMS_SQL.bind_variable (C       => l_cursor,
                                NAME    => 'P200_PKT_CREATE_DT_FROM',
                                VALUE   => v ('P200_PKT_CREATE_DT_FROM'));
        DBMS_SQL.bind_variable (C       => l_cursor,
                                NAME    => 'P200_PKT_CREATE_DT_TO',
                                VALUE   => v ('P200_PKT_CREATE_DT_TO'));
        DBMS_SQL.bind_variable (C       => l_cursor,
                                NAME    => 'P200_OPFU',
                                VALUE   => v ('P200_OPFU'));
        DBMS_SQL.bind_variable (C       => l_cursor,
                                NAME    => 'P200_RPFU',
                                VALUE   => v ('P200_RPFU'));
        DBMS_SQL.bind_variable (C       => l_cursor,
                                NAME    => 'P200_SUBSYS',
                                VALUE   => v ('P200_SUBSYS'));
        DBMS_SQL.bind_variable (C       => l_cursor,
                                NAME    => 'P200_PKT_TP',
                                VALUE   => v ('P200_PKT_TP'));
        DBMS_SQL.bind_variable (C       => l_cursor,
                                NAME    => 'P200_PKT_ST',
                                VALUE   => v ('P200_PKT_ST'));


        IF (DBMS_SQL.EXECUTE (l_cursor) <> 0)
        THEN
            raise_application_error (
                -20000,
                'Report EXEC error: ' || CHR (10) || SQLERRM);
        END IF;

        /*  IF v('P200_PKT_CREATE_DT_FROM') IS NOT NULL THEN
            dbms_sql.bind_variable(C => l_cursor,NAME => 'P200_PKT_CREATE_DT_FROM',VALUE => v('P200_PKT_CREATE_DT_FROM'));
          END IF;
          IF v('P200_PKT_CREATE_DT_TO') IS NOT NULL THEN
            dbms_sql.bind_variable(C => l_cursor,NAME => 'P200_PKT_CREATE_DT_TO',VALUE => v('P200_PKT_CREATE_DT_TO'));
          END IF;
          IF NVL(v('P200_OPFU'),'~')!='~' THEN
            dbms_sql.bind_variable(C => l_cursor,NAME => 'P200_OPFU',VALUE => v('P200_OPFU'));
          END IF;
          IF NVL(v('P200_SUBSYS'),'~')!='~' THEN
            dbms_sql.bind_variable(C => l_cursor,NAME => 'P200_SUBSYS',VALUE => v('P200_SUBSYS'));
          END IF;
          IF NVL(v('P200_PKT_TP'),'~')!='~' THEN
            dbms_sql.bind_variable(C => l_cursor,NAME => 'P200_PKT_TP',VALUE => v('P200_PKT_TP'));
          END IF;
          IF NVL(v('P200_PKT_ST'),'~')!='~' THEN
            dbms_sql.bind_variable(C => l_cursor,NAME => 'P200_PKT_ST',VALUE => v('P200_PKT_ST'));
          END IF;

          IF (dbms_sql.EXECUTE( l_cursor ) <> 0 )
          THEN
              raise_application_error( -20000,'Report EXEC error: '||CHR(10)|| SQLERRM );
          END IF;*/

        l_buff := 'Звіт по відпрацьованих конвертах' || CHR (13) || CHR (10);
        DBMS_LOB.writeappend (
            lob_loc   => l_rpt,
            amount    => DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
            buffer    => UTL_RAW.cast_to_raw (l_buff));

        l_buff := CHR (13) || CHR (10);
        DBMS_LOB.writeappend (
            lob_loc   => l_rpt,
            amount    => DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
            buffer    => UTL_RAW.cast_to_raw (l_buff));

        l_buff :=
               'Ідентифікатор пакета'
            || l_spr
            || 'Дата створення'
            || l_spr
            || 'Код ОПФУ'
            || l_spr
            || 'Назва ОПФУ'
            || l_spr
            || 'Підсистема'
            || l_spr
            || 'Тип конверта'
            || l_spr
            || 'Статус'
            || l_spr
            || 'Дата останньої операції'
            || l_spr
            || 'Отримувач'
            || l_spr
            || 'Кількість файлів'
            || CHR (13)
            || CHR (10);
        DBMS_LOB.writeappend (
            lob_loc   => l_rpt,
            amount    => DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
            buffer    => UTL_RAW.cast_to_raw (l_buff));


        LOOP
            l_cnt := DBMS_SQL.fetch_rows (C => l_cursor);
            EXIT WHEN l_cnt = 0;
            DBMS_SQL.COLUMN_VALUE (l_cursor, 1, pkt_id);
            DBMS_SQL.COLUMN_VALUE (l_cursor, 2, pkt_create_dt);
            DBMS_SQL.COLUMN_VALUE (l_cursor, 3, pkt_org);
            DBMS_SQL.COLUMN_VALUE (l_cursor, 4, org_name);
            DBMS_SQL.COLUMN_VALUE (l_cursor, 5, pkt_es);
            DBMS_SQL.COLUMN_VALUE (l_cursor, 6, pkt_pt);
            DBMS_SQL.COLUMN_VALUE (l_cursor, 7, packet_st);
            DBMS_SQL.COLUMN_VALUE (l_cursor, 8, last_oper_dt);
            DBMS_SQL.COLUMN_VALUE (l_cursor, 9, recipient_name);
            DBMS_SQL.COLUMN_VALUE (l_cursor, 10, file_names);
            DBMS_SQL.COLUMN_VALUE (l_cursor, 11, file_cnt);

            l_buff :=
                   pkt_id
                || l_spr
                || pkt_create_dt
                || l_spr
                || pkt_org
                || l_spr
                || org_name
                || l_spr
                || pkt_es
                || l_spr
                || pkt_pt
                || l_spr
                || packet_st
                || l_spr
                || last_oper_dt
                || l_spr
                || recipient_name
                || l_spr
                || file_names
                || l_spr
                || file_cnt
                || CHR (13)
                || CHR (10);


            DBMS_LOB.writeappend (
                lob_loc   => l_rpt,
                amount    => DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
                buffer    => UTL_RAW.cast_to_raw (l_buff));
            l_pnf := l_pnf + 1;
        END LOOP;

        --  l_buff:='Загалом: '||l_pnf||' справ(и) вивантажено.'||CHR(13)||CHR(10);
        --  dbms_lob.writeappend(lob_loc => l_rpt,amount => dbms_lob.getlength(utl_raw.cast_to_raw(l_buff)),buffer => utl_raw.cast_to_raw(l_buff));

        DBMS_SQL.close_cursor (l_cursor);

        --l_filename := replace(l_filename, 'xxx', );

        HTP.P ('Content-Type: text/csv ; name="' || l_filename || '"');
        HTP.P (
               'Content-Disposition: attachment; filename="'
            || l_filename
            || '"');
        HTP.P ('Content-Length: ' || DBMS_LOB.getlength (l_rpt));
        HTP.P ('');
        WPG_DOCLOAD.download_file (l_rpt);


        DBMS_LOB.CLOSE (l_rpt);
        DBMS_LOB.freetemporary (l_rpt);
    EXCEPTION
        WHEN OTHERS
        THEN
            IF DBMS_SQL.is_open (l_cursor)
            THEN
                DBMS_SQL.close_cursor (l_cursor);
            END IF;

            IF DBMS_LOB.ISOPEN (lob_loc => l_rpt) > 0
            THEN
                DBMS_LOB.CLOSE (l_rpt);
            END IF;

            DBMS_LOB.freetemporary (l_rpt);
            raise_application_error (
                -20000,
                   'Помилка публікації звіту по відпрацьованих конвертах: '
                || CHR (10)
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;
BEGIN
    NULL;
END IKIS_RBM_RPT;
/