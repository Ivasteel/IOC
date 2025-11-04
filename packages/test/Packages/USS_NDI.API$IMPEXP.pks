/* Formatted on 8/12/2025 5:55:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.API$IMPEXP
IS
    -- Author  : BOGDAN
    -- Created : 04.09.2023 15:41:25
    -- Purpose : Допоміжні функції для формування оновлень даних в версіях

    g_write_messages_to_output   INTEGER := 0;

    PROCEDURE import_reports (p_r_id IN NUMBER, p_blob IN BLOB);
END API$IMPEXP;
/


/* Formatted on 8/12/2025 5:55:29 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.API$IMPEXP
IS
    PROCEDURE WL (p_msg VARCHAR)
    IS
    BEGIN
        IF g_write_messages_to_output = 1
        THEN
            DBMS_OUTPUT.put_line (p_msg);
        END IF;
    END;


    PROCEDURE import_reports (p_r_id IN NUMBER, p_blob IN BLOB)
    IS
        l_rt     DECIMAL;
        l_nrg    DECIMAL;
        l_data   XMLTYPE;
    BEGIN
        WL ('Strting load reports!');
        l_data := XMLTYPE (TOOLS.ConvertB2C (p_blob));


        l_rt :=
            l_data.EXTRACT ('/report/ndi_report_type/rt_id/text()').getstringval ();
        l_nrg :=
            l_data.EXTRACT ('/report/ndi_rpt_group/nrg_id/text()').getstringval ();
        WL (
               '.  r_id='
            || p_r_id
            || ', rt_id='
            || l_rt
            || ',nrg_id='
            || l_nrg
            || ', name='
            || l_data.EXTRACT ('/report/ndi_report_type/rt_name/text()').getstringval ());

        MERGE INTO uss_ndi.v_ndi_rpt_group
             USING (   SELECT x_id, x_code, x_name
                         FROM XMLTABLE (
                                  '/report/ndi_rpt_group'
                                  PASSING l_data
                                  COLUMNS x_id      NUMBER PATH 'nrg_id',
                                          x_code    VARCHAR2 (10) PATH 'nrg_code',
                                          x_name    VARCHAR2 (250) PATH 'nrg_name'))
                ON (nrg_id = x_id)
        WHEN MATCHED
        THEN
            UPDATE SET nrg_code = x_code, nrg_name = x_name
        WHEN NOT MATCHED
        THEN
            INSERT     (nrg_id, nrg_code, nrg_name)
                VALUES (x_id, x_code, x_name);

        WL ('.         ndi_rpt_group. merged rows=' || SQL%ROWCOUNT);

        MERGE INTO uss_ndi.ndi_report_type
             USING (   SELECT x_id,
                              x_code,
                              x_name,
                              x_nrg,
                              x_desc
                         FROM XMLTABLE (
                                  '/report/ndi_report_type'
                                  PASSING l_data
                                  COLUMNS x_id      NUMBER PATH 'rt_id',
                                          x_code    VARCHAR2 (100) PATH 'rt_code',
                                          x_name    VARCHAR2 (250) PATH 'rt_name',
                                          x_nrg     NUMBER PATH 'rt_nrg',
                                          x_desc    VARCHAR2 (500) PATH 'rt_desc'))
                ON (rt_id = x_id)
        WHEN MATCHED
        THEN
            UPDATE SET rt_code = x_code,
                       rt_name = x_name,
                       rt_nrg = x_nrg,
                       rt_desc = x_desc
        WHEN NOT MATCHED
        THEN
            INSERT     (rt_id,
                        rt_code,
                        rt_name,
                        rt_nrg,
                        rt_desc)
                VALUES (x_id,
                        x_code,
                        x_name,
                        x_nrg,
                        x_desc);

        WL ('.         ndi_report_type. merged rows=' || SQL%ROWCOUNT);

        MERGE INTO uss_ndi.ndi_rpt_queries
             USING (         SELECT x_id,
                                    x_rt,
                                    TOOLS.ConvertB2C (TOOLS.decode_base64 (x_query))
                                        AS x_query,
                                    x_tp,
                                    x_st,
                                    TO_DATE (x_start_dt, 'DD.MM.YYYY HH24:MI:SS')
                                        AS x_start_dt,
                                    TO_DATE (x_stop_dt, 'DD.MM.YYYY HH24:MI:SS')
                                        AS x_stop_dt,
                                    TOOLS.ConvertB2C (
                                        TOOLS.decode_base64 (x_rpt_header))
                                        AS x_rpt_header
                               FROM XMLTABLE (
                                        '/report/ndi_rpt_queries'
                                        PASSING l_data
                                        COLUMNS x_id            NUMBER PATH 'rq_id',
                                                x_rt            NUMBER PATH 'rq_rt',
                                                x_query         CLOB PATH 'rq_query',
                                                x_tp            VARCHAR2 (10) PATH 'rq_tp',
                                                x_st            VARCHAR2 (10) PATH 'rq_st',
                                                x_start_dt      VARCHAR2 (100) PATH 'rq_start_dt',
                                                x_stop_dt       VARCHAR2 (100) PATH 'rq_stop_dt',
                                                x_rpt_header    CLOB PATH 'rq_rpt_header'))
                ON (rq_id = x_id)
        WHEN MATCHED
        THEN
            UPDATE SET rq_rt = x_rt,
                       rq_query = x_query,
                       rq_tp = x_tp,
                       rq_st = x_st,
                       rq_start_dt = x_start_dt,
                       rq_stop_dt = x_stop_dt,
                       rq_rpt_header = x_rpt_header
        WHEN NOT MATCHED
        THEN
            INSERT     (rq_id,
                        rq_rt,
                        rq_query,
                        rq_tp,
                        rq_st,
                        rq_start_dt,
                        rq_stop_dt,
                        rq_rpt_header)
                VALUES (x_id,
                        x_rt,
                        x_query,
                        x_tp,
                        x_st,
                        x_start_dt,
                        x_stop_dt,
                        x_rpt_header);

        WL ('.         ndi_rpt_queries. merged rows=' || SQL%ROWCOUNT);

        DELETE FROM uss_ndi.ndi_rpt_access
              WHERE ra_rt = l_rt OR (ra_nrg = l_nrg AND ra_rt IS NULL);

        WL ('.         ndi_rpt_access. deleted rows=' || SQL%ROWCOUNT);

        INSERT INTO uss_ndi.ndi_rpt_access (ra_id,
                                            ra_nrg,
                                            ra_rt,
                                            ra_start_dt,
                                            ra_stop_dt,
                                            ra_tp,
                                            ra_wr)
            SELECT 0,
                   x_nrg,
                   x_rt,
                   x_start_dt,
                   x_stop_dt,
                   x_tp,
                   x_wr
              FROM (       SELECT x_id,
                                  x_nrg,
                                  x_rt,
                                  TO_DATE (x_start_dt, 'DD.MM.YYYY HH24:MI:SS')
                                      AS x_start_dt,
                                  TO_DATE (x_stop_dt, 'DD.MM.YYYY HH24:MI:SS')
                                      AS x_stop_dt,
                                  x_tp,
                                  x_wr
                             FROM XMLTABLE (
                                      '/report/ndi_rpt_access/row'
                                      PASSING l_data
                                      COLUMNS x_id          NUMBER PATH 'ra_id',
                                              x_nrg         NUMBER PATH 'ra_nrg',
                                              x_rt          NUMBER PATH 'ra_rt',
                                              x_start_dt    VARCHAR2 (100) PATH 'ra_start_dt',
                                              x_stop_dt     VARCHAR2 (100) PATH 'ra_stop_dt',
                                              x_tp          VARCHAR2 (10) PATH 'ra_tp',
                                              x_wr          NUMBER PATH 'ra_wr'));

        WL ('.         ndi_rpt_access. inserted rows=' || SQL%ROWCOUNT);

        MERGE INTO uss_ndi.ndi_rpt_params
             USING (      SELECT x_id,
                                 x_rt,
                                 x_code,
                                 x_name,
                                 x_data_tp
                            FROM XMLTABLE (
                                     '/report/ndi_rpt_params/row'
                                     PASSING l_data
                                     COLUMNS x_id         NUMBER PATH 'nrp_id',
                                             x_rt         NUMBER PATH 'nrp_rt',
                                             x_code       VARCHAR2 (100) PATH 'nrp_code',
                                             x_name       VARCHAR2 (250) PATH 'nrp_name',
                                             x_data_tp    VARCHAR2 (10) PATH 'nrp_data_tp'))
                ON (nrp_id = x_id)
        WHEN MATCHED
        THEN
            UPDATE SET nrp_name = x_name, nrp_data_tp = x_data_tp
        WHEN NOT MATCHED
        THEN
            INSERT     (nrp_id,
                        nrp_rt,
                        nrp_code,
                        nrp_name,
                        nrp_data_tp)
                VALUES (x_id,
                        x_rt,
                        x_code,
                        x_name,
                        x_data_tp);

        WL ('.         ndi_rpt_params. merged rows=' || SQL%ROWCOUNT);

        WL ('Reports loaded!');
    END;
BEGIN
    NULL;
END API$IMPEXP;
/