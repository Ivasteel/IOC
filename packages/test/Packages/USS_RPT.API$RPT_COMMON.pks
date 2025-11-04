/* Formatted on 8/12/2025 5:58:56 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RPT.API$RPT_COMMON
IS
    -- Author  : OIVASHCHUK
    -- Created : 22.04.2019 16:34:13
    -- Purpose :
    FUNCTION boolean_to_char (status IN BOOLEAN)
        RETURN VARCHAR2;

    FUNCTION check_rpt_user (
        p_wu_id       NUMBER DEFAULT uss_rpt_context.GetContext (
                                         uss_rpt_context.gUID),
        p_rt_id       NUMBER,
        p_access_tp   VARCHAR2                                  --  CRT / VIEW
                              )
        RETURN BOOLEAN;

    /*procedure build_report(
               --p_rpt_tp   varchar2,
               p_rt_id   number,
               p_org      number default 28000,
               p_start_dt date   default null,
               p_stop_dt  date   default null\*,
               p_sql      out Clob,
               p_rq_tp    out varchar2*\);*/

    PROCEDURE Get_report (p_rpt_id NUMBER);

    PROCEDURE rpt_params_html (p_rpt_id NUMBER);

    FUNCTION get_rpt_params_html (p_rpt_id NUMBER)
        RETURN VARCHAR2;
END API$rpt_common;
/


/* Formatted on 8/12/2025 5:58:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RPT.API$RPT_COMMON
IS
    FUNCTION BOOLEAN_TO_CHAR (STATUS IN BOOLEAN)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN CASE STATUS
                   WHEN TRUE THEN 'TRUE'
                   WHEN FALSE THEN 'FALSE'
                   ELSE 'NULL'
               END;
    END;

    FUNCTION check_rpt_user (
        p_wu_id       NUMBER DEFAULT uss_rpt_context.GetContext (
                                         uss_rpt_context.gUID),
        p_rt_id       NUMBER,
        p_access_tp   VARCHAR2                                  --  CRT / VIEW
                              )
        RETURN BOOLEAN
    IS
        l_res   BOOLEAN := FALSE;
        l_cnt   NUMBER;
    BEGIN
        -- права на роботу зі звітом видані користувачу
        SELECT COUNT (1)
          INTO l_cnt
          FROM uss_ndi.v_ndi_rpt_access  a
               JOIN ikis_sysweb.v$w_users_4gic u ON a.ra_wu = wu_id
         WHERE     ra_rt = p_rt_id
               AND (ra_tp = 'CRT' OR ra_tp = p_access_tp)
               AND SYSDATE >= a.ra_start_dt
               AND (a.ra_stop_dt IS NULL OR a.ra_stop_dt > SYSDATE)
               AND u.wu_id = p_wu_id;

        IF l_cnt > 0
        THEN
            RETURN TRUE;
        END IF;

        -- права на роботу зі звітом видані на роль користувача
        SELECT COUNT (1)
          INTO l_cnt
          FROM uss_ndi.v_ndi_rpt_access  a
               JOIN ikis_sysweb.w_usr2roles ur ON a.ra_wr = wr_id
               JOIN ikis_sysweb.v$w_users_4gic u ON ur.wu_id = u.wu_id
         WHERE     ra_rt = p_rt_id
               AND (ra_tp = 'CRT' OR ra_tp = p_access_tp)
               AND SYSDATE >= a.ra_start_dt
               AND (a.ra_stop_dt IS NULL OR a.ra_stop_dt > SYSDATE)
               AND u.wu_id = p_wu_id;

        IF l_cnt > 0
        THEN
            RETURN TRUE;
        END IF;

        -- права на роботу групою звітів видані користувачу
        SELECT COUNT (1)
          INTO l_cnt
          FROM uss_ndi.v_ndi_rpt_access  a
               JOIN uss_ndi.v_ndi_report_type t ON t.rt_nrg = a.ra_nrg
               JOIN ikis_sysweb.v$w_users_4gic u ON a.ra_wu = wu_id
         WHERE     t.rt_id = p_rt_id
               AND (ra_tp = 'CRT' OR ra_tp = p_access_tp)
               AND SYSDATE >= a.ra_start_dt
               AND (a.ra_stop_dt IS NULL OR a.ra_stop_dt > SYSDATE)
               AND u.wu_id = p_wu_id;

        IF l_cnt > 0
        THEN
            RETURN TRUE;
        END IF;

        -- права на роботу групою звітів видані на роль користувача
        SELECT COUNT (1)
          INTO l_cnt
          FROM uss_ndi.v_ndi_rpt_access  a
               JOIN uss_ndi.v_ndi_report_type t ON t.rt_nrg = a.ra_nrg
               JOIN ikis_sysweb.w_usr2roles ur ON a.ra_wr = wr_id
               JOIN ikis_sysweb.v$w_users_4gic u ON ur.wu_id = u.wu_id
         WHERE     t.rt_id = p_rt_id
               AND (ra_tp = 'CRT' OR ra_tp = p_access_tp)
               AND SYSDATE >= a.ra_start_dt
               AND (a.ra_stop_dt IS NULL OR a.ra_stop_dt > SYSDATE)
               AND u.wu_id = p_wu_id;

        IF l_cnt > 0
        THEN
            RETURN TRUE;
        END IF;

        RETURN l_res;
    END;

    /*
    PROCEDURE b_put_line(p_lob IN OUT NOCOPY BLOB, p_str VARCHAR2)
      IS
        l_buff VARCHAR2(32760);
        l_phase INTEGER;
      BEGIN
        l_phase := 0;
        l_buff := p_str || CHR(13) || CHR(10);
        l_phase := 1;
        dbms_lob.writeappend(lob_loc => p_lob, amount => dbms_lob.getlength(utl_raw.cast_to_raw(l_buff)), buffer => utl_raw.cast_to_raw(l_buff));
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20000,'HtpBlob.'||l_phase||': '||CHR(10)||SQLERRM);
      END;

    PROCEDURE run_query(p_lob IN OUT NOCOPY BLOB,p_sql IN VARCHAR2, p_captions IN VARCHAR2, p_rows_cnt out number) IS
        v_v_val     VARCHAR2(4000);
        v_n_val     NUMBER;
        v_d_val     DATE;
        v_ret       NUMBER;
        c_sql       NUMBER;
        l_exec      NUMBER;
        col_cnt     INTEGER;
        f_bool      BOOLEAN;
        rec_tab     DBMS_SQL.DESC_TAB2;
        col_num     NUMBER;
        l_csv_line  VARCHAR2(32000);
        l_rows_cnt  NUMBER := 0;
    BEGIN

      c_sql := DBMS_SQL.OPEN_CURSOR;
      -- parse the SQL statement
      -- dbms_output.put_line(p_sql) ;
      DBMS_SQL.PARSE(c_sql, p_sql, DBMS_SQL.NATIVE);
      -- start execution of the SQL statement
      l_exec := DBMS_SQL.EXECUTE(c_sql);
      -- get a description of the returned columns
      DBMS_SQL.DESCRIBE_COLUMNS2(c_sql, col_cnt, rec_tab);
      -- bind variables to columns
      FOR j in 1..col_cnt
        LOOP
          CASE rec_tab(j).col_type
            WHEN 1 THEN DBMS_SQL.DEFINE_COLUMN(c_sql,j,v_v_val,4000);
            WHEN 2 THEN DBMS_SQL.DEFINE_COLUMN(c_sql,j,v_n_val);
            WHEN 12 THEN DBMS_SQL.DEFINE_COLUMN(c_sql,j,v_d_val);
          ELSE
            DBMS_SQL.DEFINE_COLUMN(c_sql,j,v_v_val,4000);
          END CASE;
        END LOOP;

      if p_captions = 'T' then
          -- Output the column headers
          l_csv_line := '';
          FOR j in 1..col_cnt
          LOOP
            l_csv_line := l_csv_line||rec_tab(j).col_name||';';
          END LOOP;
          ---l_csv_line := l_csv_line||chr(10)||chr(13);
          B_PUT_LINE(p_lob,l_csv_line);
        end if;

        -- Output the data
        LOOP
          v_ret := DBMS_SQL.FETCH_ROWS(c_sql);
          EXIT WHEN v_ret = 0;
          l_csv_line := '';
          l_rows_cnt := l_rows_cnt + 1;
          --dbms_output.put_line('FETCH_ROWS='||v_ret);

          FOR j in 1..col_cnt
          LOOP
            CASE rec_tab(j).col_type
              WHEN 1 THEN DBMS_SQL.COLUMN_VALUE(c_sql,j,v_v_val);
                          l_csv_line := l_csv_line||v_v_val||';';
              WHEN 2 THEN DBMS_SQL.COLUMN_VALUE(c_sql,j,v_n_val);
                          l_csv_line := l_csv_line||replace(to_char(v_n_val),',','.')||';';
              WHEN 12 THEN DBMS_SQL.COLUMN_VALUE(c_sql,j,v_d_val);
                          l_csv_line := l_csv_line||\*to_char(v_d_val,'dd.mm.yyyy hh24:mi:ss')*\
                                                    case when v_d_val = trunc(v_d_val) then to_char(v_d_val,'dd.mm.yyyy')
                                                         else to_char(v_d_val,'dd.mm.yyyy hh24:mi:ss')
                                                    end
                                                  ||';';
             ELSE
                l_csv_line := l_csv_line||v_v_val||';';
            END CASE;
          END LOOP;
          ---l_csv_line := l_csv_line||chr(10)||chr(13);
          B_PUT_LINE(p_lob,l_csv_line);
        END LOOP;
        DBMS_SQL.CLOSE_CURSOR(c_sql);

        p_rows_cnt := l_rows_cnt;
    EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20000,'run_query: '||CHR(10)||SQLERRM||CHR(10)||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    END run_query;


    procedure prepare_query(
               p_rpt_id   number,
               p_rt_id   number,
               p_org      number default 28000,
               p_start_dt date   default null,
               p_stop_dt  date   default null,
               p_sql      out Clob,
               p_rq_tp    out varchar2) IS
    l_sql  Clob \*VARCHAR2(32000)*\;
    begin

     select rq.rq_query, rq.rq_tp
     into   p_sql,       p_rq_tp
     from rpt_queries rq
    \* join ndi_report_type t
       on rt_id= rq_rt*\
     where rq_rt = p_rt_id --t.rt_code = p_rpt_tp
       and rq.rq_st = 'A';

    \*  p_sql := replace(p_sql, '#ORG#',   p_org);
      p_sql := replace(p_sql, '#START#', case when p_start_dt is null then 'null' else 'to_date('''||to_char(p_start_dt,'dd.mm.yyyy')||''',''dd.mm.yyyy'')' end);
      p_sql := replace(p_sql, '#STOP#',  case when p_stop_dt is null then 'null' else 'to_date('''||to_char(p_stop_dt,'dd.mm.yyyy')||''',''dd.mm.yyyy'')' end);*\

      for prm in (select upper(t.nrp_code) as param_code,
                         case t.nrp_data_tp
                           when 'N' then case when p.rp_numvalue is null then 'null' else to_char(p.rp_numvalue) end
                           when 'C' then case when p.rp_charvalue is null then 'null' else p.rp_charvalue end
                           when 'D' then case when p.rp_datevalue is null then 'null' else 'to_date('''||to_char(p.rp_datevalue,'dd.mm.yyyy')||''',''dd.mm.yyyy'')'end
                         end as param_value
                  from RPT_PARAMS  p
                  join ndi_rpt_params t
                    on rp_nrp = nrp_id
                  where rp_rpt = p_rpt_id)
      loop
        p_sql := replace(p_sql, '#'||prm.param_code||'#', prm.param_value);
      end loop;

    EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20000,'prepare_query: '||CHR(10)||SQLERRM||CHR(10)||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    end prepare_query;


    procedure build_report(
               --p_rpt_tp   varchar2,
               p_rt_id   number,
               p_org      number default 28000,
               p_start_dt date   default null,
               p_stop_dt  date   default null\*,
               p_sql      out Clob,
               p_rq_tp    out varchar2*\) IS
    l_sql           Clob;
    l_rpt_blob      Blob;
    l_rq_tp         varchar2(10);
    l_rq_error      varchar2(4000);
    l_rpt_id        number;
    l_rq_id         number;
    l_rp_id         number;
    l_file_name     varchar2(250);
    l_csv_header    varchar2(250);
    l_rows_cnt      number;
    begin

      select  rq_id into l_rq_id
      from rpt_queries
      where rq_rt = p_rt_id
        and rq_st = 'A';

      select t.rt_code||'_'||lpad(p_org, 5, '0')||
             case when p_start_dt is null then '' else '_z'||to_char(p_start_dt,'dd.mm.yyyy') end ||
             case when p_stop_dt is null then '' else '_po'||to_char(p_stop_dt,'dd.mm.yyyy') end ||
             '.csv' ,
             t.rt_name
      into l_file_name , l_csv_header
      from ndi_report_type t
      where rt_id = p_rt_id;

      l_rpt_id := rdm$reports.insert_reports(
                    p_rpt_rt => p_rt_id,
                    p_rpt_org => p_org,
                    p_rpt_wu  => ikis_rpt_context.GetContext(ikis_rpt_context.gUID),
                    p_rpt_st  => 'Q',
                    p_rpt_rq  => l_rq_id);

      rdm$rpt_params .add_rpt_params(
                    p_rpt_id => l_rpt_id,
                    p_rt_id => p_rt_id,
                    p_org_id => p_org,
                    p_start_dt => p_start_dt,
                    p_stop_dt => p_stop_dt) ;

      if check_rpt_user(
                 p_wu_id     => ikis_rpt_context.GetContext(ikis_rpt_context.gUID),
                 p_rt_id    => p_rt_id,
                 p_access_tp => 'CRT')
      then

        begin
          dbms_lob.createtemporary(lob_loc => l_rpt_blob, CACHE => TRUE);
          dbms_lob.OPEN(lob_loc => l_rpt_blob, open_mode => dbms_lob.lob_readwrite);

          prepare_query(
                   p_rpt_id   => l_rpt_id,
                   p_rt_id   => p_rt_id,
                   p_org      => p_org,
                   p_start_dt => p_start_dt,
                   p_stop_dt  => p_stop_dt,
                   p_sql      => l_sql,
                   p_rq_tp    => l_rq_tp);

          if l_rq_tp = 'SQL' then


            B_PUT_LINE(l_rpt_blob,ikis_rpt_context.GetContext(ikis_rpt_context.gLogin)||';'||to_char(sysdate,'dd.mm.yyyy hh24:mi:ss')||';' );
            B_PUT_LINE(l_rpt_blob,l_csv_header||';');

            run_query(l_rpt_blob, l_sql, 'T', l_rows_cnt);
          elsif l_rq_tp = 'PLSQL' then
            execute immediate l_sql using out l_rpt_blob;
          end if;

          RDM$RPT_FILES.insert_rpt_files(
                   p_rf_rpt => l_rpt_id,
                   p_rf_data => l_rpt_blob,
                   p_rf_name => l_file_name);

          RDM$REPORTS.set_rpt_ready(
                   p_rpt_id   => l_rpt_id,
                   p_rows_cnt => l_rows_cnt);

        exception
            when others then
              l_rq_error := 'build_report: '||chr(10)||sqlerrm||chr(10)||dbms_utility.format_error_backtrace;
              RDM$REPORTS.set_rpt_st(
                  p_rpt_id => l_rpt_id,
                  p_rpt_st => 'E',
                  p_action_tp => 'CR',
                  p_info => l_rq_error);
            --- l_rpt_blob := tools.ConvertC2B('Помилка побудовит звіту: '||chr(10)||sqlerrm||chr(10)||dbms_utility.format_error_backtrace);
        end;
      else
        RDM$REPORTS.set_rpt_st(
                  p_rpt_id => l_rpt_id,
                  p_rpt_st => 'E',
                  p_action_tp => 'CR',
                  p_info => 'Користувач не має права на побудову звіту!');
      end if;
    EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20000,'build_report<'||p_org||';'||p_start_dt||';'||p_stop_dt||'>: '||CHR(10)||SQLERRM||CHR(10)||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    end;
    */

    PROCEDURE Get_report (p_rpt_id NUMBER)
    IS
        l_blob       BLOB;
        l_cnt        NUMBER;
        l_filesize   NUMBER;
        l_filename   VARCHAR2 (100);
        l_content    VARCHAR2 (50);
        l_rt_id      NUMBER;
    BEGIN
        SELECT COUNT (1), MAX (rpt_rt)
          INTO l_cnt, l_rt_id
          FROM reports t
         WHERE rpt_id = p_rpt_id;

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'Get_report: звіт rpt_id = <' || p_rpt_id || '> не знайдено!');
        END IF;

        SELECT COUNT (1)
          INTO l_cnt
          FROM rpt_files t
         WHERE rf_rpt = p_rpt_id;

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                   'Get_report: Файл звіту rpt_id = <'
                || p_rpt_id
                || '> не знайдено!');
        END IF;

        IF check_rpt_user (
               p_wu_id       => uss_rpt_context.GetContext (uss_rpt_context.gUID),
               p_rt_id       => l_rt_id,
               p_access_tp   => 'VIEW')
        THEN
            SELECT rf_name, rf_data, DBMS_LOB.getlength (rf_data)
              INTO l_filename, l_blob, l_filesize
              FROM rpt_files t
             WHERE rf_rpt = p_rpt_id;

            IF l_blob IS NOT NULL AND l_filesize > 0
            THEN
                api$rpt_hist.insert_rpt_hist (p_rh_rpt         => p_rpt_id,
                                              p_rh_rpt_st      => '',
                                              p_rh_action_tp   => 'DL',
                                              p_rh_info        => '');
                l_content := 'application/octet-stream'; --'application/binary';

                HTP.p (
                       'Content-Type: '
                    || l_content
                    || ' ; name="'
                    || l_filename
                    || '"');
                HTP.p (
                       'Content-Disposition: attachment; filename="'
                    || l_filename
                    || '"');
                HTP.p ('Content-Length: ' || l_filesize);
                HTP.p ('');
                WPG_DOCLOAD.download_file (l_blob);
            ELSE
                api$rpt_hist.insert_rpt_hist (
                    p_rh_rpt         => p_rpt_id,
                    p_rh_rpt_st      => '',
                    p_rh_action_tp   => 'DL',
                    p_rh_info        => 'Помилка вивантаження звіту!');
                COMMIT;

                raise_application_error (
                    -20000,
                       'Помилка вивантаження звіту rpt_id = <'
                    || p_rpt_id
                    || '>!');
            END IF;
        ELSE
            api$rpt_hist.insert_rpt_hist (
                p_rh_rpt         => p_rpt_id,
                p_rh_rpt_st      => '',
                p_rh_action_tp   => 'DL',
                p_rh_info        =>
                    'Користувач не має права на перегляд звіту!');
            COMMIT;

            raise_application_error (
                -20000,
                   'Користувач не має права на перегляд звіту rpt_id = <'
                || p_rpt_id
                || '>!');
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'Get_report: rpt_id = <'
                || p_rpt_id
                || '> '
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END Get_report;

    PROCEDURE rpt_params_html (p_rpt_id NUMBER)
    IS
    BEGIN
        HTP.p (
            '<table class="t20Region t20ReportRegion" border="1" cellpadding="0" cellspacing="0" summary="" >');
        -- htp.p('<thead><tr><th class="t20RegionHeader">Параметри побудови</th></tr></thead>');
        HTP.p ('<tbody>');
        HTP.p (
            '<tr ><th class="t20ReportHeader" align="center">Параметри побудови</th><th class="t20ReportHeader" align="center"></th></tr>');

        FOR pp
            IN (SELECT rp_id,
                       nrp_name    AS param_name,
                       CASE nrp_data_tp
                           WHEN 'N'
                           THEN
                               CASE
                                   WHEN p.rp_numvalue IS NULL THEN '-'
                                   ELSE TO_CHAR (p.rp_numvalue)
                               END
                           WHEN 'C'
                           THEN
                               CASE
                                   WHEN p.rp_charvalue IS NULL THEN '-'
                                   ELSE p.rp_charvalue
                               END
                           WHEN 'D'
                           THEN
                               CASE
                                   WHEN p.rp_datevalue IS NULL
                                   THEN
                                       '-'
                                   ELSE
                                       TO_CHAR (p.rp_datevalue, 'dd.mm.yyyy')
                               END
                       END         AS param_value
                  FROM v_rpt_params  p
                       JOIN uss_ndi.v_ndi_rpt_params np ON nrp_id = rp_nrp
                 WHERE rp_rpt = p_rpt_id)
        LOOP
            HTP.p (
                   '<tr class="highlight-row"><td  class="t20data">'
                || pp.param_name
                || '</td><td class="t20data">'
                || pp.param_value
                || '</td></tr>');
        END LOOP;

        HTP.p ('</tbody>');
        HTP.p ('</table>');
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'rpt_params_html<'
                || p_rpt_id
                || '>: '
                || CHR (10)
                || SQLERRM);
    END;

    FUNCTION get_rpt_params_html (p_rpt_id NUMBER)
        RETURN VARCHAR2
    IS
        l_result   VARCHAR2 (4000);
    BEGIN
        l_result :=
               l_result
            || '<table class="t20Region t20ReportRegion" border="1" cellpadding="0" cellspacing="0" summary="" >';
        l_result :=
               l_result
            || CHR (10)
            || '<thead><tr><th class="t20RegionHeader">Параметри побудови</th></tr></thead>';
        l_result := l_result || CHR (10) || '<tbody>';
        l_result :=
               l_result
            || CHR (10)
            || '<tr ><th class="t20ReportHeader" align="center">Nrp name</th><th class="t20ReportHeader" align="center">Param value</th></tr>';

        FOR pp
            IN (SELECT rp_id,
                       nrp_name    AS param_name,
                       CASE nrp_data_tp
                           WHEN 'N'
                           THEN
                               CASE
                                   WHEN p.rp_numvalue IS NULL THEN '-'
                                   ELSE TO_CHAR (p.rp_numvalue)
                               END
                           WHEN 'C'
                           THEN
                               CASE
                                   WHEN p.rp_charvalue IS NULL THEN '-'
                                   ELSE p.rp_charvalue
                               END
                           WHEN 'D'
                           THEN
                               CASE
                                   WHEN p.rp_datevalue IS NULL
                                   THEN
                                       '-'
                                   ELSE
                                       TO_CHAR (p.rp_datevalue, 'dd.mm.yyyy')
                               END
                       END         AS param_value
                  FROM v_rpt_params  p
                       JOIN uss_ndi.v_ndi_rpt_params np ON nrp_id = rp_nrp
                 WHERE rp_rpt = p_rpt_id)
        LOOP
            l_result :=
                   l_result
                || CHR (10)
                || '<tr class="highlight-row"><td  headers="Nrp name" class="t20data">'
                || pp.param_name
                || '</td><td  headers="Param value" class="t20data">'
                || pp.param_value
                || '</td></tr>';
        END LOOP;

        l_result := l_result || CHR (10) || '</tbody>';
        l_result := l_result || CHR (10) || '</table>';

        RETURN l_result;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'rpt_params_html<'
                || p_rpt_id
                || '>: '
                || CHR (10)
                || SQLERRM);
    END;
BEGIN
    NULL;
END API$rpt_common;
/