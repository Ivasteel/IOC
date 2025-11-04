/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$MASS_EXCHANGE_DCZ
IS
    -- Author  : KELATEV
    -- Created : 02.02.2024 11:27:20
    -- Purpose : Верифікація в ДЦЗ #97845

    pkg   VARCHAR2 (100) := 'API$MASS_EXCHANGE_DCZ';

    --Uss_Ndi.v_Ddn_Mdrr_Tp
    --Uss_Ndi.v_Ddn_Mdsr_Answer

    --METHODS
    PROCEDURE prepare_me_rows (p_me_id mass_exchanges.me_id%TYPE);

    PROCEDURE make_me_packet (p_me_tp          mass_exchanges.me_tp%TYPE,
                              p_me_month       mass_exchanges.me_month%TYPE,
                              p_me_id      OUT mass_exchanges.me_id%TYPE,
                              p_me_jb      OUT mass_exchanges.me_jb%TYPE);

    PROCEDURE create_file_request_job (p_me_id mass_exchanges.me_id%TYPE);

    PROCEDURE parse_file_response (p_pkt_id ikis_rbm.v_packet.pkt_id%TYPE);
END api$mass_exchange_dcz;
/


GRANT EXECUTE ON USS_ESR.API$MASS_EXCHANGE_DCZ TO II01RC_USS_ESR_INTERNAL
/

GRANT EXECUTE ON USS_ESR.API$MASS_EXCHANGE_DCZ TO IKIS_RBM
/

GRANT EXECUTE ON USS_ESR.API$MASS_EXCHANGE_DCZ TO USS_PERSON
/

GRANT EXECUTE ON USS_ESR.API$MASS_EXCHANGE_DCZ TO USS_RPT
/

GRANT EXECUTE ON USS_ESR.API$MASS_EXCHANGE_DCZ TO USS_VISIT
/


/* Formatted on 8/12/2025 5:49:06 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$MASS_EXCHANGE_DCZ
IS
    g_debug_pipe   BOOLEAN := FALSE;                                  --  true

    --=====================================================================
    PROCEDURE generate_ext_id (p_ext_year OUT VARCHAR2, p_ext_id OUT NUMBER)
    IS
    BEGIN
        p_ext_year := TO_CHAR (SYSDATE, 'yyyy');

        SELECT NVL (MAX (mdrr_ext_id), 0) + 1
          INTO p_ext_id
          FROM me_dcz_request_rows
         WHERE mdrr_ext_year = p_ext_year;
    END;

    --=====================================================================
    -- процедура підготовки даних
    PROCEDURE prepare_me_rows (p_me_id mass_exchanges.me_id%TYPE)
    IS
        l_start_dt    DATE;
        l_start_dt2   DATE;
        l_start_dt3   DATE;
        l_stop_dt     DATE;
        l_stop_dt3    DATE;
        l_cnt         NUMBER;
        l_ext_year    VARCHAR2 (4);
        l_ext_id      NUMBER;
    BEGIN
        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.writemsg (
                pkg || '.' || $$PLSQL_UNIT || ', START');
        END IF;

        SELECT m.me_month
          INTO l_stop_dt
          FROM mass_exchanges m
         WHERE me_id = p_me_id;

        l_start_dt := ADD_MONTHS (TRUNC (l_stop_dt, 'MM'), -2);
        l_start_dt2 := ADD_MONTHS (TRUNC (l_stop_dt, 'MM'), -6);
        l_start_dt3 := ADD_MONTHS (TRUNC (l_stop_dt, 'MM'), -1);
        l_stop_dt := LAST_DAY (l_stop_dt);
        l_stop_dt3 := LAST_DAY (ADD_MONTHS (l_stop_dt, 4));

        generate_ext_id (p_ext_year => l_ext_year, p_ext_id => l_ext_id);

        INSERT INTO me_dcz_request_rows (mdrr_id,
                                         mdrr_me,
                                         mdrr_pc,
                                         mdrr_sc,
                                         mdrr_ef,
                                         mdrr_id_fam,
                                         mdrr_ext_year,
                                         mdrr_ext_id,
                                         mdrr_start_dt,
                                         mdrr_n_id,
                                         mdrr_doctype,
                                         mdrr_series,
                                         mdrr_numb,
                                         mdrr_surname,
                                         mdrr_name,
                                         mdrr_patronymic,
                                         mdrr_bdate,
                                         mdrr_tp,
                                         mdrr_doc_num,
                                         mdrr_doc_dt,
                                         mdrr_doc_org_name,
                                         mdrr_r_kaot,
                                         mdrr_r_street,
                                         mdrr_r_builing,
                                         mdrr_r_block,
                                         mdrr_r_apartment,
                                         mdrr_d_from,
                                         mdrr_d_till,
                                         mdrr_d_stop,
                                         mdrr_st)
            WITH
                src
                AS
                    (SELECT pd.pd_id             x_pd_id,
                            pd.pd_pc             x_pd_pc,
                            pdf.pdf_sc           x_pdf_sc,
                            l_start_dt           x_start_dt,
                            pdf.pdf_birth_dt     x_pdf_birth_dt,
                            pd.pd_nst            x_pd_nst,
                            pd.pd_start_dt       x_pd_start_dt,
                            pd.pd_stop_dt        x_pd_stop_dt,
                            pd.pd_st             x_pd_st,
                            pcb.pcb_hs_lock      x_pcb_hs_lock
                       FROM uss_esr.pc_decision  pd
                            JOIN uss_esr.pd_family pdf
                                ON     pdf.pdf_pd = pd.pd_id
                                   AND pdf.pdf_birth_dt BETWEEN ADD_MONTHS (
                                                                    l_start_dt,
                                                                    -60 * 12)
                                                            AND ADD_MONTHS (
                                                                    l_start_dt,
                                                                    -18 * 12)
                            LEFT JOIN uss_esr.pc_block pcb
                                ON pd.pd_pcb = pcb.pcb_id
                      WHERE     pd.pd_nst IN (664                      /*ВПО*/
                                                 )
                            AND TRUNC (pd.pd_start_dt, 'mm') = l_start_dt
                            AND (   pd.pd_st = 'P'              /*Призначено*/
                                 OR pd.pd_st = 'S'              /*Нараховано*/
                                 OR (    pd.pd_st = 'PS' /*Призупинено виплату*/
                                     AND EXISTS
                                             (SELECT 1
                                                FROM uss_ndi.v_ndi_reason_not_pay
                                                     r
                                                     LEFT JOIN
                                                     uss_esr.pc_block pcb
                                                         ON pd.pd_pcb =
                                                            pcb.pcb_id
                                               WHERE     r.rnp_id =
                                                         pcb.pcb_rnp
                                                     AND r.rnp_pnp_tp = 'CPY'
                                                     AND r.history_status =
                                                         'A')))
                            --Фільтруємо тих у яких є нарахування
                            AND EXISTS
                                    (SELECT 1
                                       FROM uss_esr.pd_payment  pdp
                                            JOIN uss_esr.pd_detail pdd
                                                ON     pdd.pdd_pdp =
                                                       pdp.pdp_id
                                                   AND pdd.pdd_value > 0
                                      WHERE     pdp.pdp_pd = pd_id
                                            AND pdp.history_status = 'A'
                                            AND pdp.pdp_start_dt BETWEEN l_start_dt
                                                                     AND l_stop_dt
                                            AND pdd.pdd_key = pdf.pdf_id)
                            --Виключаємо рішення для справ, звернених раніше за вказану дату - раніше не звертались за допомогою
                            AND NOT EXISTS
                                    (SELECT 1
                                       FROM uss_esr.pc_decision  pd2
                                            JOIN uss_esr.pd_family pdf2
                                                ON pdf2.pdf_pd = pd2.pd_id
                                      WHERE     pd2.pd_nst = pd.pd_nst
                                            AND pd2.pd_st IN
                                                    ('R0', 'S', 'SP')
                                            AND l_start_dt > pd2.pd_start_dt
                                            AND pdf2.pdf_sc = pdf.pdf_sc)
                     UNION ALL                                             --2
                     SELECT pd.pd_id             x_pd_id,
                            pd.pd_pc             x_pd_pc,
                            pdf.pdf_sc           x_pdf_sc,
                            l_start_dt2          x_start_dt,
                            pdf.pdf_birth_dt     x_pdf_birth_dt,
                            pd.pd_nst            x_pd_nst,
                            pd.pd_start_dt       x_pd_start_dt,
                            pd.pd_stop_dt        x_pd_stop_dt,
                            pd.pd_st             x_pd_st,
                            pcb.pcb_hs_lock      x_pcb_hs_lock
                       FROM uss_esr.pc_decision  pd
                            JOIN uss_esr.pd_family pdf
                                ON     pdf.pdf_pd = pd.pd_id
                                   AND pdf.pdf_birth_dt BETWEEN ADD_MONTHS (
                                                                    l_start_dt2,
                                                                    -60 * 12)
                                                            AND ADD_MONTHS (
                                                                    l_start_dt2,
                                                                    -18 * 12)
                            LEFT JOIN uss_esr.pc_block pcb
                                ON pd.pd_pcb = pcb.pcb_id
                      WHERE     pd.pd_nst IN (664                      /*ВПО*/
                                                 )
                            AND (   pd.pd_st = 'S'              /*Нараховано*/
                                 OR (    pd.pd_st = 'PS' /*Призупинено виплату*/
                                     AND EXISTS
                                             (SELECT 1
                                                FROM uss_ndi.v_ndi_reason_not_pay
                                                     r
                                                     LEFT JOIN
                                                     uss_esr.pc_block pcb
                                                         ON pd.pd_pcb =
                                                            pcb.pcb_id
                                               WHERE     r.rnp_id =
                                                         pcb.pcb_rnp
                                                     AND r.rnp_pnp_tp = 'CPY'
                                                     AND r.history_status =
                                                         'A')))
                            AND EXISTS
                                    (SELECT 1
                                       FROM uss_esr.pd_accrual_period pdap
                                      WHERE     pdap.pdap_pd = pd.pd_id
                                            AND pdap.history_status = 'A'
                                            AND TRUNC (l_stop_dt, 'MM') BETWEEN TRUNC (
                                                                                    pdap.pdap_start_dt,
                                                                                    'MM')
                                                                            AND pdap.pdap_stop_dt)
                            AND EXISTS
                                    (SELECT 1
                                       FROM uss_esr.appeal ap
                                      WHERE     ap_id = pd.pd_ap
                                            AND ap.ap_reg_dt BETWEEN l_start_dt2
                                                                 AND l_stop_dt)
                     UNION ALL                                             --3
                     SELECT pd.pd_id             x_pd_id,
                            pd.pd_pc             x_pd_pc,
                            pdf.pdf_sc           x_pdf_sc,
                            l_start_dt3          x_start_dt,
                            pdf.pdf_birth_dt     x_pdf_birth_dt,
                            pd.pd_nst            x_pd_nst,
                            pd.pd_start_dt       x_pd_start_dt,
                            pd.pd_stop_dt        x_pd_stop_dt,
                            pd.pd_st             x_pd_st,
                            pcb.pcb_hs_lock      x_pcb_hs_lock
                       FROM uss_esr.pc_decision  pd
                            JOIN uss_esr.pd_family pdf
                                ON     pdf.pdf_pd = pd.pd_id
                                   AND pdf.pdf_birth_dt BETWEEN ADD_MONTHS (
                                                                    l_start_dt3,
                                                                    -60 * 12)
                                                            AND ADD_MONTHS (
                                                                    l_start_dt3,
                                                                    -18 * 12)
                            LEFT JOIN uss_esr.pc_block pcb
                                ON pd.pd_pcb = pcb.pcb_id
                      WHERE     pd.pd_nst IN (664                      /*ВПО*/
                                                 )
                            AND pd.pd_start_dt = l_start_dt3
                            AND pd.pd_stop_dt = l_stop_dt3
                            AND (   pd.pd_st = 'S'              /*Нараховано*/
                                 OR (    pd.pd_st = 'PS' /*Призупинено виплату*/
                                     AND EXISTS
                                             (SELECT 1
                                                FROM uss_ndi.v_ndi_reason_not_pay
                                                     r
                                                     LEFT JOIN
                                                     uss_esr.pc_block pcb
                                                         ON pd.pd_pcb =
                                                            pcb.pcb_id
                                               WHERE     r.rnp_id =
                                                         pcb.pcb_rnp
                                                     AND r.rnp_pnp_tp = 'CPY'
                                                     AND r.history_status =
                                                         'A')))
                            AND EXISTS
                                    (SELECT 1
                                       FROM uss_esr.pd_accrual_period pdap
                                      WHERE     pdap.pdap_pd = pd.pd_id
                                            AND pdap.history_status = 'A'
                                            AND TRUNC (l_stop_dt, 'MM') BETWEEN TRUNC (
                                                                                    pdap.pdap_start_dt,
                                                                                    'MM')
                                                                            AND pdap.pdap_stop_dt)
                     UNION ALL                                             --4
                     SELECT pd.pd_id             x_pd_id,
                            pd.pd_pc             x_pd_pc,
                            pdf.pdf_sc           x_pdf_sc,
                            l_start_dt           x_start_dt,
                            pdf.pdf_birth_dt     x_pdf_birth_dt,
                            pd.pd_nst            x_pd_nst,
                            pd.pd_start_dt       x_pd_start_dt,
                            pd.pd_stop_dt        x_pd_stop_dt,
                            pd.pd_st             x_pd_st,
                            pcb.pcb_hs_lock      x_pcb_hs_lock
                       FROM uss_esr.pc_decision  pd
                            JOIN uss_esr.pd_family pdf
                                ON     pdf.pdf_pd = pd.pd_id
                                   AND pdf.pdf_birth_dt BETWEEN ADD_MONTHS (
                                                                    l_start_dt,
                                                                    -60 * 12)
                                                            AND ADD_MONTHS (
                                                                    l_start_dt,
                                                                    -18 * 12)
                            LEFT JOIN uss_esr.pc_block pcb
                                ON pd.pd_pcb = pcb.pcb_id
                      WHERE     pd.pd_nst IN (249)
                            AND (   pd.pd_st = 'S'              /*Нараховано*/
                                 OR (    pd.pd_st = 'PS' /*Призупинено виплату*/
                                     AND EXISTS
                                             (SELECT 1
                                                FROM uss_ndi.v_ndi_reason_not_pay
                                                     r
                                                     LEFT JOIN
                                                     uss_esr.pc_block pcb
                                                         ON pd.pd_pcb =
                                                            pcb.pcb_id
                                               WHERE     r.rnp_id =
                                                         pcb.pcb_rnp
                                                     AND r.rnp_pnp_tp = 'CPY'
                                                     AND r.history_status =
                                                         'A')))
                            AND EXISTS
                                    (SELECT 1
                                       FROM uss_esr.pd_accrual_period pdap
                                      WHERE     pdap.pdap_pd = pd.pd_id
                                            AND pdap.history_status = 'A'
                                            AND pdap.pdap_start_dt <=
                                                l_stop_dt
                                            AND pdap.pdap_stop_dt >=
                                                l_start_dt)),
                src_filter
                AS
                    (SELECT *
                       FROM src
                      WHERE x_start_dt IN (l_start_dt, l_start_dt3)
                     UNION ALL
                     SELECT s1.*
                       FROM src s1
                      WHERE     x_start_dt = l_start_dt2
                            AND NOT EXISTS
                                    (SELECT 1
                                       FROM src s2
                                      WHERE     s1.x_pdf_sc = s2.x_pdf_sc
                                            AND s2.x_start_dt != l_start_dt2))
            SELECT 0,
                   p_me_id,
                   x_pd_pc,
                   x_pdf_sc,
                   NULL,
                      '1'
                   || LPAD ('' || x_pd_id, 15, '0')
                   || LPAD (REPLACE (NVL (sc.sc_unique, 0), 'T', '9'),
                            14,
                            '0'),
                   l_ext_year,
                   l_ext_id,
                   x_start_dt,
                   NVL2 (scd_ipn.scd_number,
                         LPAD (scd_ipn.scd_number, 10, '0'),
                         NULL)
                       "IPN",
                   DECODE (scd_pass.scd_ndt,  6, '6',  7, '7',  '99')
                       "DTYPE",
                   scd_pass.scd_seria
                       "DSER",
                   SUBSTR (scd_pass.scd_number, 1, 9)
                       "DNUM",
                   SUBSTR (sci.sci_ln, 1, 70)
                       "LAST_NAME",
                   SUBSTR (sci.sci_fn, 1, 50)
                       "FIRST_NAME",
                   SUBSTR (sci.sci_mn, 1, 50)
                       "SECOND_NAME",
                   x_pdf_birth_dt
                       "BIRTHDAY",
                   DECODE (x_pd_nst, 664, '1'                          /*ВПО*/
                                             , '2'            /*Малозабезпечені*/
                                                  )
                       "OZN"                                                          /*Ознака*/
                            ,
                   --тільки для OZN=1
                   DECODE (x_pd_nst,
                           664, SUBSTR (scd_vpo.scd_number, 1, 20),
                           NULL)
                       "CertificateNumber"/*Номер довідки ВПО*/
                                          ,
                   DECODE (x_pd_nst, 664, scd_vpo.scd_issued_dt, NULL)
                       "CertificateDate"/*Дата видачі довідки ВПО*/
                                        ,
                   DECODE (x_pd_nst,
                           664, SUBSTR (scd_vpo.scd_issued_who, 1, 70),
                           NULL)
                       "CertificateIssuer"/*Орган який видав довідку ВПО*/
                                          ,
                   DECODE (x_pd_nst, 664, kaot.kaot_code, NULL)
                       "FactAddressAtu"/*КАТОТТГ населеного пункту адреси фактичного місця проживання/перебування*/
                                       ,
                   DECODE (x_pd_nst,
                           664, SUBSTR (sca.sca_street, 1, 50),
                           NULL)
                       "FactAddressStreetName"/*Тип та назва вулиці адреси фактичного місця проживання/перебування*/
                                              ,
                   DECODE (
                       x_pd_nst,
                       664, SUBSTR (REPLACE (sca.sca_building, CHR (10)),
                                    1,
                                    10),
                       NULL)
                       "FactAddressHouseNum"/*Номер будинку адреси фактичного місця проживання/перебування*/
                                            ,
                   DECODE (
                       x_pd_nst,
                       664, SUBSTR (REPLACE (sca.sca_block, CHR (10)), 1, 10),
                       NULL)
                       "FactAddressBuildNum"/*Номер / буква корпусу адреси фактичного місця проживання/перебування*/
                                            ,
                   DECODE (
                       x_pd_nst,
                       664, SUBSTR (REPLACE (sca.sca_apartment, CHR (10)),
                                    1,
                                    10),
                       NULL)
                       "FactAddressFlatNum"/*Номер квартири адреси фактичного місця проживання/перебування*/
                                           ,
                   --тільки для OZN=2
                   DECODE (x_pd_nst, 249, x_pd_start_dt, NULL)
                       "DateStart"/*Дата початку періоду призначення допомоги*/
                                  ,
                   DECODE (x_pd_nst, 249, x_pd_stop_dt, NULL)
                       "DateEnd"/*Дата закінчення періоду призначення допомоги*/
                                ,
                   CASE
                       WHEN x_pd_nst = 249 AND x_pd_st = 'PS'
                       THEN
                           (SELECT h.hs_dt
                              FROM uss_esr.histsession h
                             WHERE x_pcb_hs_lock = h.hs_id)
                   END
                       "DateStop"/*Дата припинення допомоги*/
                                 ,
                   'A'                                             /*mdrr_st*/
              FROM src_filter
                   JOIN uss_person.v_socialcard sc ON sc.sc_id = x_pdf_sc
                   JOIN uss_person.v_sc_change scc ON scc.scc_id = sc.sc_scc
                   JOIN uss_person.v_sc_identity sci
                       ON scc.scc_sci = sci.sci_id
                   LEFT JOIN uss_person.v_sc_document scd_ipn
                       ON     scd_ipn.scd_sc = sc.sc_id
                          AND scd_ipn.scd_ndt = 5
                          AND scd_ipn.scd_st = '1'              /*Актуальний*/
                   LEFT JOIN uss_person.v_sc_document scd_pass
                       ON     scd_pass.scd_sc = sc.sc_id
                          AND scd_pass.scd_ndt IN (6,
                                                   7,
                                                   8,
                                                   9)
                          AND scd_pass.scd_st = '1'             /*Актуальний*/
                   LEFT JOIN uss_person.v_sc_document scd_vpo
                       ON     scd_vpo.scd_sc = sc.sc_id
                          AND scd_vpo.scd_ndt = 10052
                          AND scd_vpo.scd_st = '1'              /*Актуальний*/
                   LEFT JOIN uss_person.v_sc_address sca
                       ON     sca.sca_sc = sc.sc_id
                          AND sca.sca_tp = 2              /*Місце проживання*/
                          AND sca.history_status = 'A'
                   LEFT JOIN uss_ndi.v_ndi_katottg kaot
                       ON kaot.kaot_id = sca.sca_kaot AND kaot.kaot_st = 'A';

        l_cnt := SQL%ROWCOUNT;

        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.writemsg (
                pkg || '.' || $$PLSQL_UNIT || ', INSERTED: ' || l_cnt);
        END IF;

        UPDATE mass_exchanges m
           SET m.me_count = l_cnt, m.me_st = api$mass_exchange.c_st_me_exists
         WHERE me_id = p_me_id;
    END;

    --=====================================================================
    --Сформувати пакет
    PROCEDURE make_me_packet (p_me_tp          mass_exchanges.me_tp%TYPE,
                              p_me_month       mass_exchanges.me_month%TYPE,
                              p_me_id      OUT mass_exchanges.me_id%TYPE,
                              p_me_jb      OUT mass_exchanges.me_jb%TYPE)
    IS
        l_hs_id   INTEGER := tools.gethistsession;
        l_cnt     INTEGER;
    BEGIN
        -- 0. контролі
        -- 0.1 перевіряємо на відсутність нескасованих записів відповідного місяця
        SELECT COUNT (1)
          INTO l_cnt
          FROM mass_exchanges m
         WHERE     m.me_tp = p_me_tp
               AND m.me_st IN (api$mass_exchange.c_st_me_creating,
                               api$mass_exchange.c_st_me_exists,
                               api$mass_exchange.c_st_me_file,
                               api$mass_exchange.c_st_me_ready2send);

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                'Помилка підготовки даних для обміну: Існує запущений процес обміну!');
        END IF;

        -- 1. реєструємо запис
        INSERT INTO mass_exchanges (me_id,
                                    me_tp,
                                    me_month,
                                    me_dt,
                                    me_st,
                                    me_hs_ins)
             VALUES (NULL,
                     p_me_tp,
                     p_me_month,
                     TRUNC (SYSDATE),
                     api$mass_exchange.c_st_me_creating,
                     l_hs_id)
          RETURNING me_id
               INTO p_me_id;

        COMMIT;
        -- 2. запускаємо джоб підготовки даних
        tools.submitschedule (
            p_jb       => p_me_jb,
            p_subsys   => 'USS_ESR',
            p_wjt      => 'ME_ROWS_PREPARE',
            p_what     =>
                   'begin uss_esr.'
                || pkg
                || '.Prepare_Me_Rows('
                || p_me_id
                || '); end;');

        UPDATE mass_exchanges
           SET me_jb = p_me_jb
         WHERE me_id = p_me_id;
    END;

    --=====================================================================
    PROCEDURE create_file_request_job (p_me_id mass_exchanges.me_id%TYPE)
    IS
        l_filter        VARCHAR2 (250);
        l_filename      VARCHAR2 (250);
        l_zip_name      VARCHAR2 (250);
        l_ecs           exchcreatesession.ecs_id%TYPE;
        l_ef            exchangefiles.ef_id%TYPE;
        l_pkt           exchangefiles.ef_pkt%TYPE;
        l_cnt           PLS_INTEGER;
        l_com_wu        NUMBER := tools.getcurrwu;
        l_me_count      PLS_INTEGER;
        l_rec           NUMBER := 21;
        l_sql           VARCHAR2 (32000);
        l_csv_blob      BLOB;
        l_zip_blob      BLOB;
        l_vis_clob      CLOB;
        l_date_format   VARCHAR2 (20) := 'DDMMYYYY';
    BEGIN
        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.writemsg (
                pkg || '.' || $$PLSQL_UNIT || ', p_me_id=' || p_me_id);
        END IF;

        SELECT m.me_count
          INTO l_me_count
          FROM mass_exchanges m
         WHERE m.me_id = p_me_id;

        -- захист від дублювання файлів
        l_filter := 'ME#' || p_me_id || '#MSP2DCZ';

        SELECT COUNT (1)
          INTO l_cnt
          FROM exchcreatesession
         WHERE ecs_filter = l_filter;

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                'Створення файлів з даними параметрами вже виконувалось!');
        END IF;

        -- реєструємо сесію формування файлів обміну
        INSERT INTO exchcreatesession (ecs_id, ecs_start_dt, ecs_filter)
             VALUES (0, SYSDATE, l_filter)
          RETURNING ecs_id
               INTO l_ecs;

        l_sql :=
               'SELECT mdrr_ext_id as EXTERNAL_ID,
                     to_char(Mdrr_Start_Dt, '''
            || l_date_format
            || ''') as START_DATE,
                     mdrr_id as ID_ISSUE,
                     mdrr_id_fam as ESR_ID,
                     mdrr_n_id as IPN,
                     mdrr_doctype as DTYPE,
                     mdrr_series as DSER,
                     mdrr_numb as DNUM,
                     mdrr_surname as LAST_NAME,
                     mdrr_name as FIRST_NAME,
                     mdrr_patronymic as SECOND_NAME,
                     to_char(mdrr_bdate, '''
            || l_date_format
            || ''') as BIRTHDAY,
                     mdrr_tp as OZN,
                     mdrr_doc_num as CertificateNumber,
                     to_char(mdrr_doc_dt, '''
            || l_date_format
            || ''') as CertificateDate,
                     mdrr_doc_org_name as CertificateIssuer,
                     mdrr_r_kaot as FactAddressAtu,
                     mdrr_r_street as FactAddressStreetName,
                     mdrr_r_builing as FactAddressHouseNum,
                     mdrr_r_block as FactAddressBuildNum,
                     mdrr_r_apartment as FactAddressFlatNum,
                     to_char(mdrr_d_from, '''
            || l_date_format
            || ''') as DateStart,
                     to_char(mdrr_d_till, '''
            || l_date_format
            || ''') as DateEnd,
                     to_char(mdrr_d_stop, '''
            || l_date_format
            || ''') as DateStop
                FROM me_dcz_request_rows r
               WHERE r.mdrr_me = '
            || p_me_id;

        -- формуємо csv
        api$mass_exchange.build_csv (p_sql => l_sql, p_csv_blob => l_csv_blob);

        IF l_csv_blob IS NULL OR DBMS_LOB.getlength (l_csv_blob) < 100
        THEN
            raise_application_error (
                -20000,
                'Помилка формування файлу обміну - файл порожній!');
        END IF;

        -- Ім’я файлів інформаційного обміну формується за такими масками MSP2DCZVPOLIYYYYMMDD.CSV
        l_filename :=
            'MSP2DCZVPOLI' || TO_CHAR (SYSDATE, 'YYYYMMDD') || '.CSV';
        l_zip_name :=
            'MSP2DCZVPOLI' || TO_CHAR (SYSDATE, 'YYYYMMDD') || '.zip';

        l_zip_blob :=
            tools.tozip2 (p_file_blob => l_csv_blob, p_file_name => l_filename);

        l_vis_clob :=
               'Файл '
            || l_filename
            || '<br>'
            || 'за даними державних допомог Єдиної інформаційної системи соціальної сфери Міністерства соціальної політики України'
            || '<br>'
            || 'Кількість рядків: '
            || l_me_count;

        INSERT INTO exchangefiles (ef_id,
                                   ef_po,
                                   com_org,
                                   com_wu,
                                   ef_tp,
                                   ef_name,
                                   ef_data,
                                   ef_visual_data,
                                   ef_header,
                                   ef_main_tag_name,
                                   ef_data_name,
                                   ef_ecp_list_name,
                                   ef_ecp_name,
                                   ef_ecp_alg,
                                   ef_st,
                                   ef_dt,
                                   ef_ident_data,
                                   ef_ecs,
                                   ef_rec,
                                   ef_file_idn,
                                   ef_pkt,
                                   ef_file_name)
             VALUES (NULL,
                     NULL,
                     50000,
                     l_com_wu,
                     'MSP2DCZ',
                     l_zip_name,
                     l_zip_blob,
                     l_vis_clob,
                     NULL,
                     'MSP2DCZVPOLI',
                     NULL,
                     NULL,
                     NULL,
                     NULL,
                     'Z',
                     SYSDATE,
                     NULL,
                     l_ecs,
                     l_rec,
                     NULL,
                     NULL,
                     l_filename)
          RETURNING ef_id
               INTO l_ef;

        -- заливаємо дані в ПЕОД
        INSERT INTO ikis_rbm.tmp_exchangefiles_m1 (ef_id,
                                                   ef_pr,
                                                   com_wu,
                                                   com_org,
                                                   ef_tp,
                                                   ef_name,
                                                   ef_data,
                                                   ef_visual_data,
                                                   ef_header,
                                                   ef_main_tag_name,
                                                   ef_data_name,
                                                   ef_ecp_list_name,
                                                   ef_ecp_name,
                                                   ef_ecp_alg,
                                                   ef_st,
                                                   ef_dt,
                                                   ef_ident_data,
                                                   ef_ecs,
                                                   ef_rec)
            SELECT ef_id,
                   ef_pr,
                   com_wu,
                   com_org,
                   ef_tp,
                   ef_name,
                   ef_data,
                   ef_visual_data,
                   ef_header,
                   ef_main_tag_name,
                   ef_data_name,
                   ef_ecp_list_name,
                   ef_ecp_name,
                   ef_ecp_alg,
                   ef_st,
                   ef_dt,
                   ef_ident_data,
                   ef_ecs,
                   ef_rec
              FROM exchangefiles
             WHERE ef_ecs = l_ecs;

        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.writemsg (
                pkg || '.' || $$PLSQL_UNIT || ', ef_ecs=' || l_ecs);
        END IF;

        -- формування пакета ПЕОД. тип визначається по ef_main_tag_name
        ikis_rbm.rdm$app_exchange.genpaketsfromtmptable;

        SELECT ef_pkt
          INTO l_pkt
          FROM ikis_rbm.tmp_exchangefiles_m1
         WHERE ef_id = l_ef;

        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.writemsg (
                pkg || '.' || $$PLSQL_UNIT || ', ef_pkt=' || l_pkt);
        END IF;

        UPDATE exchangefiles f
           SET ef_pkt = l_pkt
         WHERE ef_id = l_ef;

        UPDATE exchcreatesession
           SET ecs_stop_dt = SYSDATE
         WHERE ecs_id = l_ecs;

        -- зміна статусів на етапі А0.1 "Формування файлу для поточної верифікації"
        -- прописуємо ід пакета в таблицю обміну
        UPDATE mass_exchanges m
           SET me_pkt = l_pkt, me_st = api$mass_exchange.c_st_me_sent
         WHERE me_id = p_me_id AND me_pkt IS NULL;

        -- serhii: ^ me_pkt ^ повинен містити Ід файла з данними допомг, що відправлений в ПЕОД. Не можна його перезаписувати

        -- прописуємо ід файла обміну в таблицю рядків
        UPDATE me_dcz_request_rows
           SET mdrr_ef = l_ef, mdrr_st = api$mass_exchange.c_st_memr_sent
         WHERE mdrr_me = p_me_id;

        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.writemsg (
                pkg || '.' || $$PLSQL_UNIT || ' END, p_me_id=' || p_me_id);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            IF g_debug_pipe
            THEN
                ikis_sysweb.ikis_debug_pipe.writemsg (
                       pkg
                    || '.'
                    || $$PLSQL_UNIT
                    || ', EXCEPTION:'
                    || CHR (10)
                    || SQLERRM);
            END IF;

            ROLLBACK;

            UPDATE mass_exchanges
               SET me_st = api$mass_exchange.c_st_me_exists
             WHERE me_id = p_me_id;

            COMMIT;
            RAISE;
    END;

    --=====================================================================
    -- 4. Результатом завантаженого файлу відповіді є записи в таблиці me_dcz_result_rows.
    -- + формуємо html-таблицю і записуємо в pc_visual_data для відображення.
    -- p_pkt_id - ід пакета ПЕОД
    -- Файл Рекомендації повинен завантажуватися через картку пакета відповідного запиту!!!!
    PROCEDURE parse_file_response (p_pkt_id ikis_rbm.v_packet.pkt_id%TYPE)
    IS
        l_clob          CLOB;
        l_pc_name       ikis_rbm.v_packet_content.pc_name%TYPE;
        l_com_wu        NUMBER := tools.getcurrwu;
        l_me_id         NUMBER;
        l_ef_id         NUMBER;
        l_ecs           NUMBER;
        l_rec_id        NUMBER := 21;                   /*ikis_rbm.recipient*/
        l_file_name     VARCHAR2 (250);
        l_file_blob     BLOB;
        l_zip_blob      BLOB;
        l_lines_cnt     NUMBER;
        l_date_format   VARCHAR2 (20) := 'dd.mm.yyyy';
    BEGIN
        SELECT pc_data, UPPER (pc_name)
          INTO l_zip_blob, l_pc_name
          FROM ikis_rbm.v_packet  p
               JOIN ikis_rbm.v_packet_content c ON pc_pkt = pkt_id
         WHERE pkt_id = p_pkt_id AND pkt_st = 'N' AND pkt_pat IN (107); -- dcz_vrf_resp = Файл обліку осіб які шукають роботу з ДЦЗ

        IF UPPER (SUBSTR (l_pc_name, -4)) = '.ZIP'
        THEN
            BEGIN
                tools.unzip2 (p_zip_blob    => l_zip_blob,
                              p_file_blob   => l_file_blob,
                              p_file_name   => l_file_name);
                l_clob := tools.convertb2c (l_file_blob);
                l_pc_name := l_file_name;
            EXCEPTION
                WHEN OTHERS
                THEN
                    raise_application_error (
                        -20000,
                           'Помилка обробки архіву.'
                        || CHR (10)
                        || 'Перевірте відповідність файлу "'
                        || l_pc_name
                        || '" вимогам протоколу обміну.'
                        || CHR (10)
                        || DBMS_UTILITY.format_error_backtrace
                        || CHR (10)
                        || SQLERRM);
            END;
        ELSE
            l_clob := tools.convertb2c (l_zip_blob);
        END IF;

        l_clob :=
            REGEXP_REPLACE (l_clob,
                            '(' || CHR (10) || '|' || CHR (13) || ')+$');
        l_clob := RTRIM (l_clob, CHR (0));

        IF UPPER (SUBSTR (l_pc_name, -4)) != '.CSV'
        THEN
            l_pc_name := l_pc_name || '.CSV';
        END IF;

        SELECT m.me_id
          INTO l_me_id
          FROM ikis_rbm.v_packet_links  x
               JOIN mass_exchanges m ON m.me_pkt = x.pl_pkt_out
         WHERE x.pl_pkt_in = p_pkt_id;

        INSERT INTO me_dcz_result_rows (mdsr_id,
                                        mdsr_me,
                                        mdsr_st,
                                        mdsr_ef,
                                        mdsr_pc,
                                        mdsr_mdrr,
                                        mdsr_id_fam,
                                        mdsr_ext_id,
                                        mdsr_answer,
                                        mdsr_n_id,
                                        mdsr_doctype,
                                        mdsr_series,
                                        mdsr_numb,
                                        mdsr_surname,
                                        mdsr_name,
                                        mdsr_patronymic,
                                        mdsr_bdate,
                                        mdsr_d_start,
                                        mdsr_d_sb,
                                        mdsr_d_work,
                                        mdsr_d_voucher,
                                        mdsr_d_end,
                                        mdsr_d_stop,
                                        mdsr_ndt)
            SELECT NULL,
                   l_me_id,
                   'A',
                   NULL,
                   NULL,
                   TO_NUMBER (col002)
                       AS id_issue,
                   --ID - запису в запиті
                   CASE
                       WHEN col004 LIKE '%E%'
                       THEN
                           TO_NUMBER (col004,
                                      '999D999999999999999999EEEE',
                                      'NLS_NUMERIC_CHARACTERS='', ''')
                       ELSE
                           tools.tnumber (col004)
                   END
                       AS esr_id,
                   --Ідентифікатор ЄСР
                   TO_NUMBER (col001)
                       AS external_id,
                   --ID запиту СПСЗН
                   col003
                       AS answer/*Результат обробки запису*/
                                ,
                   col005
                       AS ipn/* Реєстраційний номер облікової картки платника податків */
                             ,
                   col010
                       AS dtype                            /* Тип документу */
                               ,
                   col011
                       AS dser/* Серія документу */
                              ,
                   col012
                       AS dnuм                          /* Номер документу */
                               ,
                   col006
                       AS last_nаме                          /* Прізвище */
                                      ,
                   col007
                       AS first_nаме/* Ім’я */
                                       ,
                   col008
                       AS second_nаме                     /* По батькові */
                                        ,
                   TO_DATE (SUBSTR (col009, 1, 10), l_date_format)
                       AS birthday/* Дата народження */
                                  ,
                   TO_DATE (SUBSTR (col013, 1, 10), l_date_format)
                       AS date_start/* Дата взяття на облік в службі зайнятості */
                                    ,
                   TO_DATE (SUBSTR (col014, 1, 10), l_date_format)
                       AS date_sb/* Дата надання статусу безробітного */
                                 ,
                   TO_DATE (SUBSTR (col015, 1, 10), l_date_format)
                       AS date_work/* Дата працевлаштування */
                                   ,
                   TO_DATE (SUBSTR (col016, 1, 10), l_date_format)
                       AS date_voucher/* Дата видачі ваучера на навчання */
                                      ,
                   TO_DATE (SUBSTR (col017, 1, 10), l_date_format)
                       AS date_end/* Дата зняття з обліку службі зайнятості */
                                  ,
                   TO_DATE (SUBSTR (col018, 1, 10), l_date_format)
                       AS date_stop/* Дата зняття з реєстрації в службі зайнятості */
                                   ,
                   uss_ndi.tools.decode_dict (p_nddc_tp         => 'NDT_ID',
                                              p_nddc_src        => 'DCZ',
                                              p_nddc_dest       => 'USS',
                                              p_nddc_code_src   => col010)
              FROM TABLE (csv_util_pkg.clob_to_csv (l_clob, p_skip_rows => 1))
                   p
             WHERE col001 IS NOT NULL AND col002 IS NOT NULL;

        l_lines_cnt := SQL%ROWCOUNT;

        IF l_lines_cnt = 0
        THEN
            raise_application_error (
                -20000,
                   'З файлу "'
                || l_pc_name
                || '" не вдалося завантажити жодного рядка.');
        END IF;

        ikis_rbm.rdm$app_exchange.set_visual_data (
            p_pkt_id        => p_pkt_id,
            p_visual_data   => l_pc_name);       -- #94133 l_clob -> l_pc_name

        ikis_rbm.rdm$packet.set_packet_state (p_pkt_id          => p_pkt_id,
                                              p_pkt_st          => 'PRC',
                                              p_pkt_change_wu   => l_com_wu,
                                              p_pkt_change_dt   => SYSDATE);

        INSERT INTO exchangefiles (ef_id,
                                   com_org,
                                   com_wu,
                                   ef_tp,
                                   ef_name,
                                   ef_data,
                                   ef_visual_data,
                                   ef_header,
                                   ef_main_tag_name,
                                   ef_data_name,
                                   ef_ecp_list_name,
                                   ef_ecp_name,
                                   ef_ecp_alg,
                                   ef_st,
                                   ef_dt,
                                   ef_ident_data,
                                   ef_ecs,
                                   ef_rec,
                                   ef_file_idn,
                                   ef_pkt,
                                   ef_file_name)
             VALUES (NULL,
                     50000,
                     l_com_wu,
                     'DCZ2MSP',
                     l_pc_name,
                     l_zip_blob,
                     l_clob,
                     NULL,
                     'DCZ2MSPVPOLI',
                     NULL,
                     NULL,
                     NULL,
                     NULL,
                     'Z',
                     SYSDATE,
                     NULL,
                     l_ecs,
                     l_rec_id,
                     NULL,
                     p_pkt_id,
                     l_pc_name)
          RETURNING ef_id
               INTO l_ef_id;

        UPDATE me_dcz_result_rows r
           SET r.mdsr_ef = l_ef_id,
               mdsr_pc =
                   (SELECT MIN (mdrr_pc)
                      FROM me_dcz_request_rows
                     WHERE mdrr_id = mdsr_mdrr AND mdrr_me = l_me_id),
               mdsr_sc =
                   (SELECT MIN (mdrr_sc)
                      FROM me_dcz_request_rows
                     WHERE mdrr_id = mdsr_mdrr AND mdrr_me = l_me_id),
               mdsr_id_fam =
                   (SELECT MIN (mdrr_id_fam)
                      FROM me_dcz_request_rows
                     WHERE mdrr_id = mdsr_mdrr AND mdrr_me = l_me_id)
         WHERE r.mdsr_me = l_me_id;

        UPDATE mass_exchanges
           SET me_st = api$mass_exchange.c_st_me_loaded
         WHERE me_id = l_me_id;
    END;
--=====================================================================

END api$mass_exchange_dcz;
/