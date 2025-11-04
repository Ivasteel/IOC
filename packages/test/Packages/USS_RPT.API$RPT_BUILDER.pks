/* Formatted on 8/12/2025 5:58:56 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RPT.API$RPT_BUILDER
IS
    -- Author  : OIVASHCHUK
    -- Created : 06.05.2019 14:42:04
    -- Purpose : побудова звітів

    PROCEDURE b_put_line (p_lob IN OUT NOCOPY BLOB, p_str VARCHAR2);

    PROCEDURE run_query (p_lob        IN OUT NOCOPY BLOB,
                         p_sql        IN            VARCHAR2,
                         p_captions   IN            VARCHAR2,
                         p_rows_cnt      OUT        NUMBER);

    PROCEDURE build_report (
        p_rt_id         NUMBER,
        p_org           NUMBER DEFAULT uss_rpt_context.getcontext (
                                           uss_rpt_context.gopfu),
        p_start_dt      DATE DEFAULT NULL,
        p_stop_dt       DATE DEFAULT NULL,
        p_ap_tp      IN VARCHAR2 DEFAULT NULL,                -- тип звернення
        p_ap_nst     IN NUMBER DEFAULT NULL,                        -- послуга
        p_src_tp     IN VARCHAR2 DEFAULT NULL, -- Система, до якої передано звернення на опрацювання (ikis_rbm.request_journal)/Джерело надходження звернення (v_ddn_ap_src)
        p_ncs_id     IN NUMBER DEFAULT NULL, -- служба у справах дітей (ndi_children_service)
        p_jb            NUMBER DEFAULT NULL,
        p_wu            NUMBER DEFAULT uss_rpt_context.getcontext (
                                           uss_rpt_context.guid));

    PROCEDURE build_report_xls (
        p_rt_id         NUMBER,
        p_org           NUMBER DEFAULT uss_rpt_context.getcontext (
                                           uss_rpt_context.gopfu),
        p_start_dt      DATE DEFAULT NULL,
        p_stop_dt       DATE DEFAULT NULL,
        p_ap_tp      IN VARCHAR2 DEFAULT NULL,                -- тип звернення
        p_ap_nst     IN NUMBER DEFAULT NULL,                        -- послуга
        p_src_tp     IN VARCHAR2 DEFAULT NULL, -- Система, до якої передано звернення на опрацювання (ikis_rbm.request_journal)/Джерело надходження звернення (v_ddn_ap_src)
        p_ncs_id     IN NUMBER DEFAULT NULL, -- служба у справах дітей (ndi_children_service)
        p_jb            NUMBER DEFAULT NULL,
        p_wu            NUMBER DEFAULT uss_rpt_context.getcontext (
                                           uss_rpt_context.guid));
END api$rpt_builder;
/


/* Formatted on 8/12/2025 5:58:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RPT.API$RPT_BUILDER
IS
    PROCEDURE b_put_line (p_lob IN OUT NOCOPY BLOB, p_str VARCHAR2)
    IS
        l_buff    VARCHAR2 (32760);
        l_phase   INTEGER;
    BEGIN
        l_phase := 0;
        l_buff := p_str || CHR (13) || CHR (10);
        l_phase := 1;
        DBMS_LOB.writeappend (
            lob_loc   => p_lob,
            amount    => DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
            buffer    => UTL_RAW.cast_to_raw (l_buff));
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'HtpBlob.' || l_phase || ': ' || CHR (10) || SQLERRM);
    END;

    PROCEDURE run_query (p_lob        IN OUT NOCOPY BLOB,
                         p_sql        IN            VARCHAR2,
                         p_captions   IN            VARCHAR2,
                         p_rows_cnt      OUT        NUMBER)
    IS
        v_v_val      VARCHAR2 (4000);
        v_n_val      NUMBER;
        v_d_val      DATE;
        v_ret        NUMBER;
        c_sql        NUMBER;
        l_exec       NUMBER;
        col_cnt      INTEGER;
        --f_bool     BOOLEAN;
        rec_tab      DBMS_SQL.desc_tab2;
        --col_num    NUMBER;
        l_csv_line   VARCHAR2 (32000);
        l_rows_cnt   NUMBER := 0;
    BEGIN
        c_sql := DBMS_SQL.open_cursor;
        -- parse the SQL statement
        -- dbms_output.put_line(p_sql) ;
        -- ikis_sysweb.ikis_debug_pipe.WriteMsg(p_sql);
        DBMS_SQL.parse (c_sql, p_sql, DBMS_SQL.native);
        -- start execution of the SQL statement
        l_exec := DBMS_SQL.execute (c_sql);
        -- get a description of the returned columns
        DBMS_SQL.describe_columns2 (c_sql, col_cnt, rec_tab);

        -- bind variables to columns
        FOR j IN 1 .. col_cnt
        LOOP
            --dbms_output.put_line('ct='||rec_tab(j).col_type||':'||rec_tab(j).col_name) ;
            CASE rec_tab (j).col_type
                WHEN 1
                THEN
                    DBMS_SQL.define_column (c_sql,
                                            j,
                                            v_v_val,
                                            4000);
                WHEN 2
                THEN
                    DBMS_SQL.define_column (c_sql, j, v_n_val);
                WHEN 12
                THEN
                    DBMS_SQL.define_column (c_sql, j, v_d_val);
                ELSE
                    DBMS_SQL.define_column (c_sql,
                                            j,
                                            v_v_val,
                                            4000);
            END CASE;
        END LOOP;

        IF p_captions = 'T'
        THEN
            -- Output the column headers
            l_csv_line := '';

            FOR j IN 1 .. col_cnt
            LOOP
                l_csv_line :=
                    l_csv_line || '"' || rec_tab (j).col_name || '";';
            END LOOP;

            ---l_csv_line := l_csv_line||chr(10)||chr(13);
            b_put_line (p_lob, l_csv_line);
        END IF;

        -- Output the data
        LOOP
            v_ret := DBMS_SQL.fetch_rows (c_sql);
            EXIT WHEN v_ret = 0;
            l_csv_line := '';
            l_rows_cnt := l_rows_cnt + 1;

            --dbms_output.put_line('FETCH_ROWS='||v_ret);

            FOR j IN 1 .. col_cnt
            LOOP
                CASE rec_tab (j).col_type
                    WHEN 1
                    THEN
                        DBMS_SQL.COLUMN_VALUE (c_sql, j, v_v_val);
                        l_csv_line := l_csv_line || v_v_val || ';';
                    WHEN 2
                    THEN
                        DBMS_SQL.COLUMN_VALUE (c_sql, j, v_n_val);
                        l_csv_line :=
                               l_csv_line
                            || REPLACE (TO_CHAR (v_n_val), ',', '.')
                            || ';';
                    WHEN 12
                    THEN
                        DBMS_SQL.COLUMN_VALUE (c_sql, j, v_d_val);
                        l_csv_line :=
                               l_csv_line
                            ||    /*to_char(v_d_val,'dd.mm.yyyy hh24:mi:ss')*/
                               CASE
                                   WHEN v_d_val = TRUNC (v_d_val)
                                   THEN
                                       TO_CHAR (v_d_val, 'dd.mm.yyyy')
                                   ELSE
                                       TO_CHAR (v_d_val,
                                                'dd.mm.yyyy hh24:mi:ss')
                               END
                            || ';';
                    ELSE
                        DBMS_SQL.COLUMN_VALUE (c_sql, j, v_v_val);
                        l_csv_line := l_csv_line || v_v_val || ';';
                END CASE;
            END LOOP;

            ---l_csv_line := l_csv_line||chr(10)||chr(13);
            b_put_line (p_lob, l_csv_line);
        END LOOP;

        DBMS_SQL.close_cursor (c_sql);

        p_rows_cnt := l_rows_cnt;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'run_query: '
                || CHR (10)
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_backtrace);
    END run_query;

    PROCEDURE prepare_query (p_rpt_id         NUMBER,
                             p_rt_id          NUMBER,
                             p_org            NUMBER DEFAULT 50000,
                             p_start_dt       DATE DEFAULT NULL,
                             p_stop_dt        DATE DEFAULT NULL,
                             p_sql        OUT CLOB,
                             p_rq_tp      OUT VARCHAR2)
    IS
    --l_sql CLOB /*VARCHAR2(32000)*/;
    BEGIN
        SELECT rq.rq_query, rq.rq_tp
          INTO p_sql, p_rq_tp
          FROM uss_ndi.v_ndi_rpt_queries rq
         /* join ndi_report_type t
         on nrt_id= rq_nrt*/
         WHERE rq_rt = p_rt_id                         --t.nrt_code = p_rpt_tp
                               AND rq.rq_st = 'A';

        /*  p_sql := replace(p_sql, '#ORG#',   p_org);
        p_sql := replace(p_sql, '#START#', case when p_start_dt is null then 'null' else 'to_date('''||to_char(p_start_dt,'dd.mm.yyyy')||''',''dd.mm.yyyy'')' end);
        p_sql := replace(p_sql, '#STOP#',  case when p_stop_dt is null then 'null' else 'to_date('''||to_char(p_stop_dt,'dd.mm.yyyy')||''',''dd.mm.yyyy'')' end);*/

        FOR prm
            IN (SELECT UPPER (t.nrp_code)    AS param_code,
                       CASE t.nrp_data_tp
                           WHEN 'N'
                           THEN
                               CASE
                                   WHEN p.rp_numvalue IS NULL THEN 'null'
                                   ELSE TO_CHAR (p.rp_numvalue)
                               END
                           WHEN 'C'
                           THEN
                               CASE
                                   WHEN p.rp_charvalue IS NULL THEN 'null'
                                   ELSE '''' || p.rp_charvalue || ''''
                               END
                           WHEN 'D'
                           THEN
                               CASE
                                   WHEN p.rp_datevalue IS NULL
                                   THEN
                                       'null'
                                   ELSE
                                          'to_date('''
                                       || TO_CHAR (p.rp_datevalue,
                                                   'dd.mm.yyyy')
                                       || ''',''dd.mm.yyyy'')'
                               END
                       END                   AS param_value
                  FROM rpt_params  p
                       JOIN uss_ndi.v_ndi_rpt_params t ON rp_nrp = nrp_id
                 WHERE rp_rpt = p_rpt_id)
        LOOP
            p_sql :=
                REPLACE (p_sql,
                         '#' || prm.param_code || '#',
                         prm.param_value);
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'prepare_query: '
                || CHR (10)
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_backtrace);
    END prepare_query;

    PROCEDURE build_report (
        p_rt_id         NUMBER,
        p_org           NUMBER DEFAULT uss_rpt_context.getcontext (
                                           uss_rpt_context.gopfu),
        p_start_dt      DATE DEFAULT NULL,
        p_stop_dt       DATE DEFAULT NULL,
        p_ap_tp      IN VARCHAR2 DEFAULT NULL,                -- тип звернення
        p_ap_nst     IN NUMBER DEFAULT NULL,                        -- послуга
        p_src_tp     IN VARCHAR2 DEFAULT NULL, -- Система, до якої передано звернення на опрацювання (ikis_rbm.request_journal)/Джерело надходження звернення (v_ddn_ap_src)
        p_ncs_id     IN NUMBER DEFAULT NULL, -- служба у справах дітей (ndi_children_service)
        p_jb            NUMBER DEFAULT NULL,
        p_wu            NUMBER DEFAULT uss_rpt_context.getcontext (
                                           uss_rpt_context.guid))
    IS
        l_sql          CLOB;
        l_rpt_blob     BLOB;
        l_rq_tp        VARCHAR2 (10);
        l_rq_error     VARCHAR2 (4000);
        l_rpt_id       NUMBER;
        l_rq_id        NUMBER;
        --l_rp_id      NUMBER;
        l_file_name    VARCHAR2 (250);
        l_csv_header   VARCHAR2 (250);
        l_login        VARCHAR2 (250);
        l_rows_cnt     NUMBER;
        l_org          NUMBER;

        l_files        ikis_sysweb.tbl_some_files
                           := ikis_sysweb.tbl_some_files ();

        l_params       api$rpt_xls.t_params := api$rpt_xls.t_params ();
    --l_param  api$rpt_xls.t_param;
    BEGIN
        ikis_sysweb_schedule.savemessage ('Починаю побудову вибірки');

        SELECT rq_id
          INTO l_rq_id
          FROM uss_ndi.v_ndi_rpt_queries
         WHERE rq_rt = p_rt_id AND rq_st = 'A';

        l_params.EXTEND (7);
        l_params (1).p_name := 'ORG';
        l_params (1).p_value := p_org;

        l_params (2).p_name := 'START';
        l_params (2).p_value := TO_CHAR (p_start_dt, 'dd.mm.yyyy');

        l_params (3).p_name := 'STOP';
        l_params (3).p_value := TO_CHAR (p_stop_dt, 'dd.mm.yyyy');

        l_params (4).p_name := 'AP_TP';
        l_params (4).p_value := p_ap_tp;

        l_params (5).p_name := 'AP_NST';
        l_params (5).p_value := TO_CHAR (p_ap_nst);

        l_params (6).p_name := 'SRC_TP';
        l_params (6).p_value := p_src_tp;

        l_params (7).p_name := 'CHILD';
        l_params (7).p_value := TO_CHAR (p_ncs_id);

        SELECT                            -- ShY апендикс что остался от икиса
               CASE
                   WHEN rt_code IN ('IDP_AA_NRH_FML')
                   THEN
                          'EIS'
                       || 'F01'
                       || '1'
                       || '01'
                       || TO_CHAR (SYSDATE, 'ddmmyyyy')
                       || '.csv'
                   WHEN rt_code IN ('WRK', 'SUBS7C', 'SUBS7F')
                   THEN
                          t.rt_code
                       || '_'
                       || LPAD (p_org, 5, '0')
                       || '_'
                       || TO_CHAR (p_start_dt, 'dd.mm.yyyy')
                       || '.zip'
                   WHEN rt_code IN ('AUTOCAND')
                   THEN                                               --#60727
                          t.rt_code
                       || '_'
                       || TO_CHAR (SYSDATE, 'dd.mm.yyyy')
                       || '.zip'
                   WHEN rt_code IN ('ERSP_TK1')
                   THEN                                                --73139
                          t.rt_code
                       || '_'
                       || LPAD (p_org, 5, '0')
                       || '_'
                       || TO_CHAR (SYSDATE, 'dd.mm.yyyy')
                       || '.zip'
                   WHEN rt_code IN ('SUBS4C', 'SUBS4F', 'SUBS5C')
                   THEN
                          t.rt_code
                       || '_'
                       || TO_CHAR (p_start_dt, 'dd.mm.yyyy')
                       || '.csv'
                   WHEN rt_code IN ('TKANALITIC', 'TKANALIT')
                   THEN
                          t.rt_code
                       || '_'
                       || LPAD (p_org, 5, '0')
                       || CASE
                              WHEN p_start_dt IS NOT NULL
                              THEN
                                  '_' || TO_CHAR (p_start_dt, 'DD.MM.YYYY')
                          END
                       || CASE
                              WHEN p_stop_dt IS NOT NULL
                              THEN
                                  '_' || TO_CHAR (p_stop_dt, 'DD.MM.YYYY')
                          END
                       || '.zip'                                      --#65623
                   ELSE
                          -- ShY реальность
                          t.rt_code
                       || '_'
                       || LPAD (p_org, 5, '0')
                       || CASE
                              WHEN p_start_dt IS NULL THEN ''
                              ELSE '_z' || TO_CHAR (p_start_dt, 'dd.mm.yyyy')
                          END
                       || CASE
                              WHEN p_stop_dt IS NULL THEN ''
                              ELSE '_po' || TO_CHAR (p_stop_dt, 'dd.mm.yyyy')
                          END
                       || '.csv'
               END,
               t.rt_name
          INTO l_file_name, l_csv_header
          FROM uss_ndi.v_ndi_report_type t
         WHERE rt_id = p_rt_id;

        --raise_application_error(-20000, uss_esr.tools.GetCurrOrg);
        -- ShY 16/02/2022 для дефолтного параметра если 50000 и контекст пользователя отличается то берем контекст или параметр что пришел
        IF     p_org = 50000
           AND uss_rpt_context.getcontext (uss_rpt_context.gopfu) != 50000
        THEN
            l_org := uss_rpt_context.getcontext (uss_rpt_context.gopfu);
        ELSE
            l_org := p_org;
        END IF;

        ikis_sysweb_schedule.savemessage ('Ініціалізую параметри');
        l_rpt_id :=
            api$reports.insert_reports (p_rpt_rt    => p_rt_id,
                                        p_rpt_org   => l_org,
                                        p_rpt_wu    => p_wu,
                                        p_rpt_st    => 'Q',
                                        p_rpt_rq    => l_rq_id,
                                        p_rpt_jb    => p_jb);

        api$rpt_params.add_rpt_params_new (p_rpt_id   => l_rpt_id,
                                           p_rt_id    => p_rt_id,
                                           p_params   => l_params);

        /*api$rpt_params.add_rpt_params(
        p_rpt_id => l_rpt_id,
        p_rt_id => p_rt_id,
        p_org_id => l_org,
        p_start_dt => p_start_dt,
        p_stop_dt => p_stop_dt) ;  */

        IF api$rpt_common.check_rpt_user (p_wu_id       => p_wu,
                                          p_rt_id       => p_rt_id,
                                          p_access_tp   => 'CRT')
        THEN
            api$reports.set_rpt_st (p_rpt_id => l_rpt_id, p_rpt_st => 'F');

            IF api$reports_lock.allowparallel (l_rpt_id) = 0
            THEN
                l_rq_error :=
                    'Перевищена кількість одночасних побудов вибірок';
                api$reports.set_rpt_st (p_rpt_id      => l_rpt_id,
                                        p_rpt_st      => 'E',
                                        p_action_tp   => 'CR',
                                        p_info        => l_rq_error);
                RETURN;
            END IF;

            BEGIN
                DBMS_LOB.createtemporary (lob_loc => l_rpt_blob, cache => TRUE);
                DBMS_LOB.open (lob_loc     => l_rpt_blob,
                               open_mode   => DBMS_LOB.lob_readwrite);

                ikis_sysweb_schedule.savemessage ('Запускаю основний запит');
                prepare_query (p_rpt_id     => l_rpt_id,
                               p_rt_id      => p_rt_id,
                               p_org        => l_org,
                               p_start_dt   => p_start_dt,
                               p_stop_dt    => p_stop_dt,
                               p_sql        => l_sql,
                               p_rq_tp      => l_rq_tp);

                IF l_rq_tp = 'SQL'
                THEN
                    SELECT MAX (wu_login)
                      INTO l_login
                      FROM v$w_users_4gic
                     WHERE wu_id = p_wu;

                    IF p_rt_id != 152
                    THEN
                        b_put_line (
                            l_rpt_blob, /*ikis_rpt_context.GetContext(ikis_rpt_context.gLogin)*/
                               l_login
                            || ';'
                            || TO_CHAR (SYSDATE, 'dd.mm.yyyy hh24:mi:ss')
                            || ';');
                        b_put_line (l_rpt_blob, l_csv_header || ';');

                        b_put_line (l_rpt_blob,
                                    'Підрозділ:;' || l_org || ';');
                        b_put_line (
                            l_rpt_blob,
                            'Дата створення з:;' || p_start_dt || ';');
                        b_put_line (
                            l_rpt_blob,
                            'Дата створення по:;' || p_stop_dt || ';');
                    END IF;

                    --IKIS_SYSWEB_SCHEDULE.SaveMessage(l_sql);
                    run_query (l_rpt_blob,
                               l_sql,
                               'T',
                               l_rows_cnt);
                /*
                          if p_rt_id = 152 then
                            l_rpt_blob := utl_compress.lz_compress(l_rpt_blob, 9);
                          end if;
                */
                ELSIF l_rq_tp = 'PLSQL'
                THEN
                    /*API$RPT_FILES.insert_rpt_files(
                    p_rf_rpt => l_rpt_id,
                    p_rf_data => tools.ConvertC2B(l_sql),
                    p_rf_name => 'pl/sql');
                    commit;*/
                    EXECUTE IMMEDIATE l_sql
                        USING OUT l_rpt_blob;
                END IF;

                IF l_rpt_blob IS NULL
                THEN
                    raise_application_error (
                        -20000,
                           'Відсутні дані для вибірки<'
                        || l_org
                        || ';'
                        || p_start_dt
                        || ';'
                        || p_stop_dt
                        || '>: '
                        || p_rt_id);
                ELSE
                    IF p_rt_id = 152
                    THEN -- IC #87199 Костиль, поки не добавлять ознаку в типи звіту
                        l_files.EXTEND;
                        l_files (l_files.LAST) :=
                            ikis_sysweb.t_some_file_info (l_file_name,
                                                          l_rpt_blob);

                        l_rpt_blob :=
                            ikis_sysweb.ikis_web_jutil.getZipFromStrms (
                                l_files);
                        l_file_name := l_file_name || '.zip';
                    END IF;

                    IF p_rt_id = 158
                    THEN -- IC  #98164 Костиль, поки не добавлять ознаку в типи звіту
                        l_file_name :=
                               'MSP2WFP_DSD3250_BICC'
                            || TO_CHAR (p_start_dt, 'yymm')
                            || '2312_'
                            || TO_CHAR (SYSDATE, 'yyyymmdd')
                            || '.CSV';
                        l_files.EXTEND;
                        l_files (l_files.LAST) :=
                            ikis_sysweb.t_some_file_info (l_file_name,
                                                          l_rpt_blob);

                        l_rpt_blob :=
                            ikis_sysweb.ikis_web_jutil.getZipFromStrms (
                                l_files);
                        l_file_name := l_file_name || '.zip';
                    END IF;

                    ikis_sysweb_schedule.savemessage (
                        'Зберігаю результат побудови вибірки');
                    api$rpt_files.insert_rpt_files (
                        p_rf_rpt    => l_rpt_id,
                        p_rf_data   => l_rpt_blob,
                        p_rf_name   => l_file_name);

                    api$reports.set_rpt_ready (p_rpt_id     => l_rpt_id,
                                               p_rows_cnt   => l_rows_cnt);
                END IF;
            EXCEPTION
                WHEN OTHERS
                THEN
                    l_rq_error :=
                           'build_report: '
                        || CHR (10)
                        || SQLERRM
                        || CHR (10)
                        || DBMS_UTILITY.format_error_backtrace;
                    api$reports.set_rpt_st (p_rpt_id      => l_rpt_id,
                                            p_rpt_st      => 'E',
                                            p_action_tp   => 'CR',
                                            p_info        => l_rq_error);
                    ikis_sysweb_schedule.savemessage (
                           'Помилка: '
                        || CHR (10)
                        || SQLERRM
                        || CHR (10)
                        || DBMS_UTILITY.format_error_backtrace);
            --- l_rpt_blob := tools.ConvertC2B('Помилка побудовит вибірки: '||chr(10)||sqlerrm||chr(10)||dbms_utility.format_error_backtrace);
            END;
        ELSE
            api$reports.set_rpt_st (
                p_rpt_id      => l_rpt_id,
                p_rpt_st      => 'E',
                p_action_tp   => 'CR',
                p_info        =>
                       'Користувач <'
                    ||            /*ikis_rpt_context.GetContext(ikis_rpt_context.gUID)*/
                       p_wu
                    || '> не має права на побудову вибірки!');
        END IF;

        ikis_sysweb_schedule.savemessage ('Побудову вибірки завершено!');
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'build_report<'
                || TO_CHAR (p_org)
                || '=>'
                || TO_CHAR (l_org)
                || ';'
                || TO_CHAR (p_start_dt, 'DD.MM.YYYY')
                || ';'
                || TO_CHAR (p_stop_dt, 'DD.MM.YYYY')
                || ';'
                || p_ap_tp
                || ';'
                || TO_CHAR (p_ap_nst)
                || ';'
                || p_src_tp
                || ';'
                || TO_CHAR (p_ncs_id)
                || '>: '
                || CHR (10)
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE build_report_xls (
        p_rt_id         NUMBER,
        p_org           NUMBER DEFAULT uss_rpt_context.getcontext (
                                           uss_rpt_context.gopfu),
        p_start_dt      DATE DEFAULT NULL,
        p_stop_dt       DATE DEFAULT NULL,
        p_ap_tp      IN VARCHAR2 DEFAULT NULL,                -- тип звернення
        p_ap_nst     IN NUMBER DEFAULT NULL,                        -- послуга
        p_src_tp     IN VARCHAR2 DEFAULT NULL, -- Система, до якої передано звернення на опрацювання (ikis_rbm.request_journal)/Джерело надходження звернення (v_ddn_ap_src)
        p_ncs_id     IN NUMBER DEFAULT NULL, -- служба у справах дітей (ndi_children_service)
        p_jb            NUMBER DEFAULT NULL,
        p_wu            NUMBER DEFAULT uss_rpt_context.getcontext (
                                           uss_rpt_context.guid))
    IS
        l_sql          CLOB;
        l_rpt_blob     BLOB;
        l_rq_tp        VARCHAR2 (10);
        l_rq_error     VARCHAR2 (4000);
        l_rpt_id       NUMBER;
        l_rq_id        NUMBER;
        --l_rp_id      NUMBER;
        l_file_name    VARCHAR2 (250);
        l_xls_header   VARCHAR2 (250);
        l_rows_cnt     NUMBER;
        l_col_tp       VARCHAR2 (10);
        l_rpt_header   CLOB;
        l_org          NUMBER;
        l_params       api$rpt_xls.t_params := api$rpt_xls.t_params ();
        --l_param      api$rpt_xls.t_param;

        l_cols_width   VARCHAR2 (4000);
        l_cols_wrap    VARCHAR2 (4000);
        l_arch         VARCHAR2 (10) := 'F';
    BEGIN
        /*
        rdm$rpt_hist.insert_rpt_hist(p_rh_rpt => null, p_rh_rpt_st => null, p_rh_action_tp => 'TEST2', p_rh_info => 'ikis_sysweb_schedule.getuser='||ikis_sysweb_schedule.getuser);
        rdm$rpt_hist.insert_rpt_hist(p_rh_rpt => null, p_rh_rpt_st => null, p_rh_action_tp => 'TEST3', p_rh_info => 'ikis_rpt_context.GetContext(ikis_rpt_context.gUID)='||ikis_rpt_context.GetContext(ikis_rpt_context.gUID));
        */

        l_params.EXTEND (7);
        l_params (1).p_name := 'com_org';
        l_params (1).p_value := p_org;

        l_params (2).p_name := 'start_dt';
        l_params (2).p_value := TO_CHAR (p_start_dt, 'dd.mm.yyyy');

        l_params (3).p_name := 'stop_dt';
        l_params (3).p_value := TO_CHAR (p_stop_dt, 'dd.mm.yyyy');

        -- якщо потрібно зробити як в build_report то використовувати цей варіант
        /*l_params(1).p_name := 'ORG';
        l_params(1).p_value := p_org;

        l_params(2).p_name := 'START';
        l_params(2).p_value := to_char(p_start_dt,'dd.mm.yyyy');

        l_params(3).p_name := 'STOP';
        l_params(3).p_value := to_char(p_stop_dt,'dd.mm.yyyy');*/

        l_params (4).p_name := 'AP_TP';
        l_params (4).p_value := p_ap_tp;

        l_params (5).p_name := 'AP_NST';
        l_params (5).p_value := TO_CHAR (p_ap_nst);

        l_params (6).p_name := 'SRC_TP';
        l_params (6).p_value := TO_CHAR (p_src_tp);

        l_params (7).p_name := 'CHILD';
        l_params (7).p_value := TO_CHAR (p_ncs_id);

        -- ShY 16/02/2022 для дефолтного параметра если 50000 и контекст пользователя отличается то берем контекст или параметр что пришел
        IF     p_org = 50000
           AND uss_rpt_context.getcontext (uss_rpt_context.gopfu) != 50000
        THEN
            l_org := uss_rpt_context.getcontext (uss_rpt_context.gopfu);
        ELSE
            l_org := p_org;
        END IF;

        SELECT rq_id,
               CASE WHEN rq_rpt_header IS NULL THEN 'T' ELSE 'B' END,
               rq_rpt_header
          INTO l_rq_id, l_col_tp, l_rpt_header
          FROM uss_ndi.v_ndi_rpt_queries
         WHERE rq_rt = p_rt_id AND rq_st = 'A';

        SELECT -- ShY апендикс что остался от икиса
               CASE
                   WHEN rt_code = 'WRK'
                   THEN
                          t.rt_code
                       || '_'
                       || LPAD (l_org, 5, '0')
                       || '_'
                       || TO_CHAR (p_start_dt, 'dd.mm.yyyy')
                       || '.zip'
                   WHEN rt_code IN ('SUBS4C', 'SUBS4F', '')
                   THEN
                          t.rt_code
                       || '_'
                       || TO_CHAR (p_start_dt, 'dd.mm.yyyy')
                       || '.csv'
                   WHEN rt_code IN ('AUTOCAND')
                   THEN                                               --#60727
                          t.rt_code
                       || '_'
                       || TO_CHAR (SYSDATE, 'dd.mm.yyyy')
                       || '.zip'
                   WHEN rt_code IN ('TKANALITIC', 'TKANALIT')
                   THEN
                          t.rt_code
                       || '_'
                       || LPAD (p_org, 5, '0')
                       || CASE
                              WHEN p_start_dt IS NOT NULL
                              THEN
                                  '_' || TO_CHAR (p_start_dt, 'DD.MM.YYYY')
                          END
                       || CASE
                              WHEN p_stop_dt IS NOT NULL
                              THEN
                                  '_' || TO_CHAR (p_stop_dt, 'DD.MM.YYYY')
                          END
                       || '.zip'                                      --#65623
                   ELSE
                          -- ShY то что используется по справочникам
                          t.rt_code
                       || '_'
                       || LPAD (l_org, 5, '0')
                       || CASE
                              WHEN p_start_dt IS NULL THEN ''
                              ELSE '_z' || TO_CHAR (p_start_dt, 'dd.mm.yyyy')
                          END
                       || CASE
                              WHEN p_stop_dt IS NULL THEN ''
                              ELSE '_po' || TO_CHAR (p_stop_dt, 'dd.mm.yyyy')
                          END
                       || '.xls'
               END,
               /*
               ikis_rpt_context.GetContext(ikis_rpt_context.gLogin)
               ||'#'||ikis_rpt_context.GetContext(ikis_rpt_context.gDnetSession)
               ||'#'||ikis_rpt_context.GetContext(ikis_rpt_context.gDnetUser)
               ||'#'||ikis_rpt_context.GetContext(apex_application.g_user)
               ||'#'||ikis_rpt_context.GetContext(ikis_rpt_context.gUID)
               ||'#'||ikis_rpt_context.GetContext('uid')
               ||'#'||ikis_rpt_context.GetContext(ikis_rpt_context.gOPFU)
               ||'#'||ikis_rpt_context.GetContext(ikis_rpt_context.gUserTP)
               ||'#'||
               */
               t.rt_name
          INTO l_file_name, l_xls_header
          FROM uss_ndi.v_ndi_report_type t
         WHERE rt_id = p_rt_id;

        l_rpt_id :=
            api$reports.insert_reports (p_rpt_rt    => p_rt_id,
                                        p_rpt_org   => l_org,
                                        p_rpt_wu    => p_wu,
                                        p_rpt_st    => 'Q',
                                        p_rpt_rq    => l_rq_id,
                                        p_rpt_jb    => p_jb);

        api$rpt_params.add_rpt_params (p_rpt_id     => l_rpt_id,
                                       p_rt_id      => p_rt_id,
                                       p_org_id     => l_org,
                                       p_start_dt   => p_start_dt,
                                       p_stop_dt    => p_stop_dt);

        IF api$rpt_common.check_rpt_user (p_wu_id       => p_wu,
                                          p_rt_id       => p_rt_id,
                                          p_access_tp   => 'CRT')
        THEN
            api$reports.set_rpt_st (p_rpt_id => l_rpt_id, p_rpt_st => 'F');

            BEGIN
                DBMS_LOB.createtemporary (lob_loc => l_rpt_blob, cache => TRUE);
                DBMS_LOB.open (lob_loc     => l_rpt_blob,
                               open_mode   => DBMS_LOB.lob_readwrite);

                prepare_query (p_rpt_id     => l_rpt_id,
                               p_rt_id      => p_rt_id,
                               p_org        => l_org,
                               p_start_dt   => p_start_dt,
                               p_stop_dt    => p_stop_dt,
                               p_sql        => l_sql,
                               p_rq_tp      => l_rq_tp);

                IF l_rq_tp = 'SQL'
                THEN
                    IF p_rt_id = 24
                    THEN
                        l_cols_width :=
                            '75,370,37,35,32,90,90,90,57,34,57,34,99,57,51,51,51,90,58,58,58,58,58';
                        l_cols_wrap := '2';
                    ELSE
                        l_cols_width := NULL;
                        l_cols_wrap := NULL;
                    END IF;

                    --B_PUT_LINE(l_rpt_blob,ikis_rpt_context.GetContext(ikis_rpt_context.gLogin)||';'||to_char(sysdate,'dd.mm.yyyy hh24:mi:ss')||';' );
                    --B_PUT_LINE(l_rpt_blob,l_csv_header||';');

                    --IKIS_RPT_XLS.run_query(l_rpt_blob, l_sql, l_xls_header, l_col_tp/*  #63169 'T'*/, l_params, l_rpt_header);
                    api$rpt_xls.run_query (p_lob          => l_rpt_blob,
                                           p_sql          => l_sql,
                                           p_xls_header   => l_xls_header,
                                           p_captions     => l_col_tp,
                                           p_params       => l_params,
                                           p_cols_width   => l_cols_width, -- ширина стовпців. через кому
                                           p_cols_wrap    => l_cols_wrap, -- номери стовпців, що потребують переносу рядка. через кому
                                           p_rpt_header   => l_rpt_header -- шаблон шапки вибірки
                                                                         );
                /*          -- архівуємо
                l_rpt_blob := utl_compress.lz_compress(l_rpt_blob, 9);
                l_arch := 'T';*/

                ELSIF l_rq_tp = 'PLSQL'
                THEN
                    EXECUTE IMMEDIATE l_sql
                        USING OUT l_rpt_blob;
                END IF;

                api$rpt_files.insert_rpt_files (
                    p_rf_rpt    => l_rpt_id,
                    p_rf_data   => l_rpt_blob,
                    p_rf_name   =>
                           l_file_name
                        || CASE WHEN l_arch = 'T' THEN '.zip' ELSE '' END);

                api$reports.set_rpt_ready (p_rpt_id     => l_rpt_id,
                                           p_rows_cnt   => l_rows_cnt);
            EXCEPTION
                WHEN OTHERS
                THEN
                    l_rq_error :=
                           'build_report: '
                        || CHR (10)
                        || SQLERRM
                        || CHR (10)
                        || DBMS_UTILITY.format_error_backtrace;
                    api$reports.set_rpt_st (p_rpt_id      => l_rpt_id,
                                            p_rpt_st      => 'E',
                                            p_action_tp   => 'CR',
                                            p_info        => l_rq_error);
            --- l_rpt_blob := tools.ConvertC2B('Помилка побудовит вибірки: '||chr(10)||sqlerrm||chr(10)||dbms_utility.format_error_backtrace);
            END;
        ELSE
            api$reports.set_rpt_st (
                p_rpt_id      => l_rpt_id,
                p_rpt_st      => 'E',
                p_action_tp   => 'CR',
                p_info        =>
                       'Користувач <'
                    ||            /*ikis_rpt_context.GetContext(ikis_rpt_context.gUID)*/
                       p_wu
                    || '> не має права на побудову вибірки!');
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   'build_report_xls<'
                || TO_CHAR (p_org)
                || '=>'
                || TO_CHAR (l_org)
                || ';'
                || TO_CHAR (p_start_dt, 'DD.MM.YYYY')
                || ';'
                || TO_CHAR (p_stop_dt, 'DD.MM.YYYY')
                || ';'
                || p_ap_tp
                || ';'
                || TO_CHAR (p_ap_nst)
                || ';'
                || p_src_tp
                || ';'
                || TO_CHAR (p_ncs_id)
                || '>: '
                || CHR (10)
                || SQLERRM
                || CHR (10)
                || DBMS_UTILITY.format_error_backtrace);
    END;
BEGIN
    -- Initialization
    NULL;
END api$rpt_builder;
/