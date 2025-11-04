/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$MASS_EXCHANGE
IS
    -- Author  : VANO
    -- Created : 11.07.2023 18:40:22
    -- Purpose : Функції оборобки даних масового обміну/верифікації

    -- #91349 SERHII коди довідників:
    -- V_DDN_ME_ST (3051) "Стани ПАКЕТІВ масового обміну/верифікації"
    c_st_ME_Creating       mass_exchanges.me_st%TYPE := 'C'; -- Пакет створюється
    c_st_ME_Exists         mass_exchanges.me_st%TYPE := 'E';       -- Створено
    c_st_ME_File           mass_exchanges.me_st%TYPE := 'F'; -- Формується файл обміну
    c_st_ME_Ready2Send     mass_exchanges.me_st%TYPE := 'R'; -- Готовий до передачі
    c_st_ME_Sent           mass_exchanges.me_st%TYPE := 'P'; -- Передано в підсистему обміну
    c_st_ME_Loaded         mass_exchanges.me_st%TYPE := 'L'; -- Отримано відповідь #97845
    c_st_ME_Received       mass_exchanges.me_st%TYPE := 'K'; -- Отримано рекомендації
    c_st_ME_Processed      mass_exchanges.me_st%TYPE := 'V'; -- Рекомендації відпрацьовано
    c_st_ME_Cancelled      mass_exchanges.me_st%TYPE := 'D'; -- Пакет скасовано (дані видалено)
    -- V_DDN_MEMR_ST (3052) "Стани РЯДКІВ пакету масового обміну/верифікації"
    c_st_MEMR_Exists       me_minfin_request_rows.memr_st%TYPE := 'E'; -- Створено
    c_st_MEMR_Sent         me_minfin_request_rows.memr_st%TYPE := 'P'; -- Передано в підсистему обміну
    c_st_MEMR_Received     me_minfin_request_rows.memr_st%TYPE := 'K'; -- Отримано рекомендації
    c_st_MEMR_Processed    me_minfin_request_rows.memr_st%TYPE := 'V'; -- Рекомендації відпрацьовано
    c_st_MEMR_Uncomplete   me_minfin_request_rows.memr_st%TYPE := 'U'; -- Неповні/помилкові дані
    -- V_DDN_MERC_ST (3053) "Стани рядків рекомендацій"
    c_st_MERC_Received     me_minfin_recomm_rows.merc_st%TYPE := 'O'; -- Отримано
    c_st_MERC_Processed    me_minfin_recomm_rows.merc_st%TYPE := 'V'; -- Відпрацьовано
    c_st_MERC_Sent         me_minfin_recomm_rows.merc_st%TYPE := 'P'; -- Передано відповіді
    -- V_DDN_MESR_ST (3054) "Стани рядків відповідей на рекомендації"
    c_st_MESR_Exists       me_minfin_result_rows.mesr_st%TYPE := 'E'; -- Створено
    c_st_MESR_Confirmed    me_minfin_result_rows.mesr_st%TYPE := 'P'; -- Підтверджено
    c_st_MESR_Sent         me_minfin_result_rows.mesr_st%TYPE := 'S'; -- Надіслано

    -- процедура підготовки даних
    PROCEDURE prepare_me_rows (p_me_id mass_exchanges.me_id%TYPE);

    -- процедура підготовки даних
    PROCEDURE prepare_me_rows_un (p_me_id mass_exchanges.me_id%TYPE);

    -- IC #107802 формування нових файлів по ВПП ООН (по тим сумам, що не виплачено)
    PROCEDURE prepare_me_rows_unr (p_me_id mass_exchanges.me_id%TYPE);

    -- IC #111818 Повторне вивантаження по невиплаченим сумам
    PROCEDURE prepare_me_rows_unrr (p_me_id mass_exchanges.me_id%TYPE);

    -- IC #112423 окреме довивантаження з типом "Вивантаження ВПП ООН (309 з додатками)"
    PROCEDURE prepare_me_rows_un306 (p_me_id mass_exchanges.me_id%TYPE);

    -- IC #109475 Формування рядків вивантаження по ЄСВ на редагування
    PROCEDURE prepare_me_rows_esv (p_me_id IN mass_exchanges.me_id%TYPE);

    -- процедура формування csv файлу по вказаному sql-запиту
    PROCEDURE build_csv (p_sql        IN     VARCHAR2,
                         p_csv_blob      OUT BLOB,
                         p_rtrim      IN     VARCHAR2 := ' ');

    -- формування html-таблиці по даних csv-файла(вмісту пакета квитанції)
    FUNCTION convert_csv2html (p_csv_clob CLOB, p_file_name VARCHAR2)
        RETURN CLOB;

    --Виконати розрахунок даних пакету
    PROCEDURE make_me_packet (p_me_tp          mass_exchanges.me_tp%TYPE,
                              p_me_month       mass_exchanges.me_month%TYPE,
                              p_me_id      OUT mass_exchanges.me_id%TYPE,
                              p_me_jb      OUT mass_exchanges.me_jb%TYPE);

    --Обгортка для виклику make_exchange_file_job через scheduler
    PROCEDURE make_exchange_file (p_me_id       mass_exchanges.me_id%TYPE,
                                  p_jb_id   OUT exchangefiles.ef_kv_pkt%TYPE);

    --Формувати файл для передачі отримувачу
    PROCEDURE create_file_F01_job (p_me_id mass_exchanges.me_id%TYPE);

    PROCEDURE create_file_C01_job (p_me_id mass_exchanges.me_id%TYPE);

    -- IC вивантаження інформації для ВПП ООН
    PROCEDURE create_file_MSP2WFP_job (p_me_id mass_exchanges.me_id%TYPE);

    --Скасувати пакет
    PROCEDURE reject_packet (p_me_id mass_exchanges.me_id%TYPE);

    -- IC #109475 Оновити статус пакета
    PROCEDURE setPacketSt (p_me_id   IN NUMBER,
                           p_me_st   IN mass_exchanges.me_st%TYPE);

    --А0.4 Отримання квитанції від МФУ
    PROCEDURE proc_me_kv (p_pkt_id ikis_rbm.v_packet.pkt_id%TYPE);

    --А0.6 Отримання рекомендацій
    PROCEDURE proc_me_recom (p_pkt_id ikis_rbm.v_packet.pkt_id%TYPE);

    -- IC #99160 Обробити відповідь від ВПП ООН по виплаті є-допомоги
    PROCEDURE proc_me_recom_un (p_pkt_id ikis_rbm.v_packet.pkt_id%TYPE);

    -- IC #106684 Завантаження результатів виплати по банку (ВПП ООН)
    PROCEDURE proc_me_payment_unb (p_pkt_id ikis_rbm.v_packet.pkt_id%TYPE);

    PROCEDURE Parse_File_On_Upload (
        p_Pkt_Id    IN Ikis_Rbm.v_Packet.Pkt_Id%TYPE,
        p_Pkt_Pat   IN Ikis_Rbm.v_Packet.Pkt_Pat%TYPE);

    -- #91349 2023.09.01 SERHII Підготовка імен, прізвищ перед вигрузкою
    FUNCTION prepare_names (p_name IN VARCHAR2, p_upper IN PLS_INTEGER:= 1)
        RETURN VARCHAR2;

    /*---------- #97756 copied from DNET$PAYMENT_REPORTS -------------*/
    FUNCTION getCharMF (p_val    IN VARCHAR2,
                        p_type   IN VARCHAR2 := '0',
                        p_def    IN VARCHAR2 := NULL)
        RETURN VARCHAR2;

    /* serhii 12/09/2023 #91349:
       варіант getCharMF під вібірку для Мінфіну uss_ndi.ndi_rpt_queries.rq_id = 152 */
    FUNCTION getCharMF_q152 (p_val    IN VARCHAR2,
                             p_type   IN VARCHAR2 := '0',
                             p_def    IN VARCHAR2 := NULL)
        RETURN VARCHAR2;

    FUNCTION getFAddrMF (p_app_id   IN NUMBER,
                         p_ndt_id   IN NUMBER := 605,
                         p_nda_id   IN NUMBER := NULL)
        RETURN VARCHAR;

    FUNCTION getRAddrMF (p_app_id   IN NUMBER,
                         p_ndt_id   IN NUMBER := 605,
                         p_nda_id   IN NUMBER := NULL)
        RETURN VARCHAR;

    FUNCTION getAddrUN (p_ap       IN NUMBER,
                        p_ndt_id   IN NUMBER := 600,
                        p_nda_id   IN NUMBER := NULL)
        RETURN VARCHAR;

    -- IC Отримання текстового параметру документу по учаснику
    FUNCTION get_doc_string (p_app   ap_document.apd_app%TYPE,
                             p_ap    ap_document.apd_ap%TYPE,
                             p_ndt   ap_document.apd_ndt%TYPE,
                             p_nda   ap_document_attr.apda_nda%TYPE)
        RETURN VARCHAR2;

    -- IC Отримання ID параметру документу по учаснику
    FUNCTION get_doc_id (p_app   ap_document.apd_app%TYPE,
                         p_ap    ap_document.apd_ap%TYPE,
                         p_ndt   ap_document.apd_ndt%TYPE,
                         p_nda   ap_document_attr.apda_nda%TYPE)
        RETURN VARCHAR2;

    /*---------- #97756 copied from DNET$PAYMENT_REPORTS -------------*/

    -- #103465 Додати логування етапів роботи з пакетами вериіфкації Мінфіну
    PROCEDURE write_me_log (
        p_mel_me        IN ME_LOG.mel_me%TYPE,
        p_mel_hs        IN ME_LOG.mel_hs%TYPE DEFAULT NULL,
        p_mel_st        IN ME_LOG.mel_st%TYPE,
        p_mel_message   IN ME_LOG.mel_message%TYPE,
        p_mel_st_old    IN ME_LOG.mel_st_old%TYPE DEFAULT NULL,
        p_mel_tp        IN ME_LOG.mel_tp%TYPE DEFAULT 'SYS');
END API$MASS_EXCHANGE;
/


GRANT EXECUTE ON USS_ESR.API$MASS_EXCHANGE TO II01RC_USS_ESR_INTERNAL
/

GRANT EXECUTE ON USS_ESR.API$MASS_EXCHANGE TO IKIS_RBM
/

GRANT EXECUTE ON USS_ESR.API$MASS_EXCHANGE TO USS_PERSON
/

GRANT EXECUTE ON USS_ESR.API$MASS_EXCHANGE TO USS_RPT
/

GRANT EXECUTE ON USS_ESR.API$MASS_EXCHANGE TO USS_VISIT
/


/* Formatted on 8/12/2025 5:49:06 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$MASS_EXCHANGE
IS
    g_debug_pipe   BOOLEAN := FALSE;                                  --  true

    -- info    https://ora-00001.blogspot.com/2010/04/select-from-spreadsheet-or-how-to-parse.html
    -- процедура підготовки даних
    PROCEDURE prepare_me_rows (p_me_id mass_exchanges.me_id%TYPE)
    IS
        l_start_dt   DATE;
        l_cnt        NUMBER;
        l_hs         histsession.hs_id%TYPE := TOOLS.GetHistSession;
    BEGIN
        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg ('START prepare_me_rows');
        END IF;

        SELECT m.me_month                                            /*me_dt*/
          INTO l_start_dt
          FROM mass_exchanges m
         WHERE me_id = p_me_id;

        INSERT INTO me_minfin_request_rows (memr_id,
                                            memr_me,
                                            memr_pc,
                                            memr_ef,
                                            memr_id_fam,
                                            memr_rep_period,
                                            memr_calc_period,
                                            memr_n_id,
                                            memr_surname,
                                            memr_name,
                                            memr_patronymic,
                                            memr_bdate,
                                            memr_doctype,
                                            memr_series,
                                            memr_numb,
                                            memr_docdate,
                                            memr_unzr,
                                            memr_gender,
                                            memr_citizenship,
                                            memr_r_address,
                                            memr_r_index,
                                            memr_r_catottg,
                                            memr_r_typev,
                                            memr_r_namev,
                                            memr_r_numb,
                                            memr_r_numk,
                                            memr_r_numa,
                                            memr_f_address,
                                            memr_f_index,
                                            memr_f_catottg,
                                            memr_f_typev,
                                            memr_f_namev,
                                            memr_f_numb,
                                            memr_f_numk,
                                            memr_f_numa,
                                            memr_fam_relat,
                                            memr_d_from,
                                            memr_d_till,
                                            memr_d_app,
                                            memr_dis_group,
                                            memr_dis_reason,
                                            memr_doc_inv,
                                            memr_d_inv,
                                            memr_dis_begin,
                                            memr_dis_start,
                                            memr_dis_end,
                                            memr_kfn,
                                            memr_p_summd,
                                            memr_n_summd,
                                            memr_v_summd,
                                            memr_size_smf,
                                            memr_st,
                                            memr_n_dov,
                                            memr_d_give,
                                            memr_ozn_fam,
                                            memr_ozn_otr,
                                            memr_ozn_agent,
                                            memr_app_tp,
                                            memr_sum_pmt)
            WITH
                nrh
                AS
                    (  SELECT org_id,
                              ac_pc
                                  x_pc,
                              pc_sc
                                  x_sc,
                              acd_pd
                                  x_pd,
                              sc_unique
                                  x_sc_unique,
                              ac_month,
                              acd_start_dt,
                              SUM (
                                  uss_esr.api$acctools.xsign (acd_op) * acd_sum)
                                  x_sum,
                              NVL (ptt.npt_code, pt.npt_code)
                                  npt_code
                         FROM ikis_sys.v_opfu org
                              INNER JOIN uss_esr.accrual a
                                  ON a.com_org = org.org_id     -- нарахування
                              INNER JOIN uss_esr.ac_detail d
                                  ON     d.acd_ac = a.ac_id
                                     AND d.history_status = 'A'
                                     AND d.acd_prsd IS NOT NULL -- нарахування
                              INNER JOIN uss_esr.personalcase pc
                                  ON pc.pc_id = a.ac_pc
                              INNER JOIN uss_person.v_socialcard c
                                  ON c.sc_id = pc.pc_sc
                              INNER JOIN uss_ndi.v_ndi_payment_type pt
                                  ON d.acd_npt = pt.npt_id
                              INNER JOIN uss_ndi.v_ndi_op o
                                  ON d.acd_op = o.op_id AND o.op_tp1 = 'NR'
                              LEFT JOIN uss_ndi.v_ndi_decoding_config n
                                  ON     n.nddc_code_src = pt.npt_id
                                     AND n.nddc_tp = 'NPT_MF'
                              LEFT JOIN uss_ndi.v_ndi_payment_type ptt
                                  ON ptt.npt_id = n.nddc_code_dest
                        WHERE     org.org_id IN
                                      (    SELECT org_id
                                             FROM ikis_sys.v_opfu
                                       CONNECT BY PRIOR org_id = org_org
                                       START WITH org_id = 50000 /* CASE WHEN #ORG# = 50001 THEN 50000 ELSE #ORG# END */
                                                                )
                              AND org.org_to = 32
                              AND ac_month = TRUNC (l_start_dt, 'MM')
                              AND acd_start_dt BETWEEN TRUNC (l_start_dt, 'MM')
                                                   AND TRUNC (
                                                           LAST_DAY (
                                                               l_start_dt))
                              AND d.acd_npt IN (SELECT nptc_npt
                                                  FROM USS_NDI.v_Ndi_Npt_Config
                                                 WHERE nptc_nst IN (664,
                                                                    248,
                                                                    269,
                                                                    267,
                                                                    249,
                                                                    265,
                                                                    268, -- #96361
                                                                    251,
                                                                    275,
                                                                    862,
                                                                    901) -- #102799
                                                                        )
                     GROUP BY org.org_id,
                              ac_pc,
                              pc_sc,
                              acd_pd,
                              ac_month,
                              acd_start_dt,
                              NVL (ptt.npt_code, pt.npt_code),
                              sc_unique) -- select  count(*), sum(x_sum) from nrh
                                        ,
                src
                AS
                    (SELECT nrh.ORG_ID,
                            nrh.X_PC,
                            nrh.X_SC,
                            nrh.X_PD,
                            nrh.X_SC_UNIQUE,
                            nrh.AC_MONTH,
                            nrh.ACD_START_DT,
                            nrh.X_SUM,
                            nrh.NPT_CODE,
                            ds.pd_id,
                            ds.pd_ap,
                            ds.pd_start_dt,
                            ds.pd_stop_dt,
                            ap.ap_reg_dt,
                            fml.pdf_sc,
                            fml.pdf_birth_dt,
                            prs.app_tp,
                            prs.app_id,
                            prs.app_ap,
                            i.sci_ln,
                            i.sci_fn,
                            i.sci_mn,
                            i.sci_gender,
                            inv.scy_group,
                            inv.scy_decision_dt,
                            inv.scy_start_dt,
                            inv.scy_stop_dt,
                            r.dic_code,
                            dinv.scd_number,
                            dinv.SCD_ISSUED_DT,
                            (SELECT SUM (pdd.pdd_value)
                               FROM uss_esr.pd_payment  pp           --виплати
                                                          ,
                                    uss_esr.pd_detail   pdd          --виплати
                              WHERE     pp.pdp_pd = nrh.X_PD
                                    AND pp.pdp_id = pdd.pdd_pdp
                                    AND pdd.pdd_key = fml.pdf_id
                                    AND pp.history_status = 'A'
                                    AND TRUNC (l_start_dt, 'MM') BETWEEN TRUNC (
                                                                             pdd.pdd_start_dt,
                                                                             'MM')
                                                                     AND pdd.pdd_stop_dt
                                    AND pdd.pdd_npt != 48
                                    AND pdd.pdd_ndp IN (280,
                                                        282,
                                                        290,
                                                        294,
                                                        300) --08/10/2024 serhii by #109490
                                                            )                 sum_pmt -- сума призначеної виплати по рішенню у звітний період
                                                                                     ,
                            ROW_NUMBER ()
                                OVER (PARTITION BY ds.pd_id,
                                                   fml.pdf_id,
                                                   app_ap,
                                                   app_sc,
                                                   app_tp
                                      ORDER BY prs.app_id DESC NULLS LAST)    rn
                       FROM nrh
                            INNER JOIN uss_esr.pc_decision ds
                                ON ds.pd_id = x_pd
                            INNER JOIN uss_esr.appeal ap
                                ON     ap.ap_id = ds.pd_ap
                                   AND ap.ap_reg_dt IS NOT NULL
                            LEFT JOIN uss_esr.pd_family fml
                                ON nrh.x_pd = fml.pdf_pd
                            LEFT JOIN uss_esr.ap_person prs
                                ON     prs.app_ap = ds.pd_ap
                                   AND prs.app_sc = fml.pdf_sc
                                   AND prs.history_status = 'A'
                            LEFT JOIN uss_person.v_socialcard sc
                                ON sc.sc_id = fml.pdf_sc
                            LEFT JOIN uss_person.v_sc_change scc
                                ON     scc.scc_sc = sc_id
                                   AND scc.scc_id = sc.sc_scc
                            LEFT JOIN uss_person.v_sc_identity i
                                ON i.sci_id = scc.scc_sci
                            LEFT JOIN uss_person.v_sc_disability inv
                                ON     inv.scy_sc = fml.pdf_sc
                                   AND inv.history_Status = 'A'
                                   --and inv.scy_decision_dt is not NULL  #105473
                                   --and inv.scy_start_dt is not null  #105473
                                   AND EXISTS
                                           (SELECT 1
                                              FROM uss_ndi.V_DDN_SCY_GROUP g
                                             WHERE inv.scy_group = g.dic_code)
                                   AND EXISTS
                                           (SELECT 1
                                              FROM Uss_Person.v_Sc_Document
                                                   idc
                                             WHERE idc.scd_id = inv.scy_scd-- and idc.scd_number is not null  #105473
                                                                           --  and idc.SCD_ISSUED_DT is not NULL  #105473
                                                                           )
                            LEFT JOIN uss_ndi.V_DDN_INV_REASON r
                                ON     inv.scy_reason = r.dic_code
                                   AND r.dic_st = 'A'
                            LEFT JOIN Uss_Person.v_Sc_Document dinv
                                ON dinv.scd_id = inv.scy_scd),
                flds
                AS
                    (SELECT ac_month
                                REP_PERIOD,
                            acd_start_dt
                                CALC_PERIOD,
                            NVL (
                                (SELECT MAX (scd_number)
                                   FROM uss_person.v_sc_document
                                  WHERE     scd_sc = pdf_sc
                                        AND scd_ndt = 5
                                        AND scd_st IN ('1', 'A')),
                                   (  SELECT p.scd_seria
                                        FROM uss_person.v_sc_document p
                                       WHERE     scd_sc = pdf_sc
                                             AND scd_ndt IN (6, 7)
                                             AND scd_st IN ('1', 'A')
                                    ORDER BY scd_id DESC
                                       FETCH FIRST ROW ONLY)
                                || (  SELECT p.scd_number
                                        FROM uss_person.v_sc_document p
                                       WHERE     scd_sc = pdf_sc
                                             AND scd_ndt IN (6, 7)
                                             AND scd_st IN ('1', 'A')
                                    ORDER BY scd_id DESC
                                       FETCH FIRST ROW ONLY))
                                N_ID,
                            USS_ESR.API$MASS_EXCHANGE.prepare_names (sci_ln)
                                SURNAME, --  #91349 2023.09.01 SERHII замінив DNET$PAYMENT_REPORTS.getCharMF(UPPER(sci_ln),'PIB')
                            USS_ESR.API$MASS_EXCHANGE.prepare_names (sci_fn)
                                NAME,
                            USS_ESR.API$MASS_EXCHANGE.prepare_names (sci_mn)
                                PATRONYMIC,
                            pdf_birth_dt
                                BDATE,
                            (  SELECT d.scd_ndt
                                 FROM uss_person.v_sc_document   d,
                                      USS_NDI.v_ndi_document_type dt
                                WHERE     scd_sc = pdf_sc
                                      AND d.scd_ndt = dt.ndt_id
                                      AND dt.ndt_ndc = 13
                                      AND d.scd_st IN ('1', 'A')
                             ORDER BY scd_ndt, d.scd_id DESC
                                FETCH FIRST ROW ONLY)
                                DOCTYPE,
                            (  SELECT d.scd_seria
                                 FROM uss_person.v_sc_document   d,
                                      USS_NDI.v_ndi_document_type dt
                                WHERE     scd_sc = pdf_sc
                                      AND d.scd_ndt = dt.ndt_id
                                      AND dt.ndt_ndc = 13
                                      AND d.scd_st IN ('1', 'A')
                             ORDER BY scd_ndt, d.scd_id DESC
                                FETCH FIRST ROW ONLY)
                                SERIES,
                            (  SELECT d.scd_number
                                 FROM uss_person.v_sc_document   d,
                                      USS_NDI.v_ndi_document_type dt
                                WHERE     scd_sc = pdf_sc
                                      AND d.scd_ndt = dt.ndt_id
                                      AND dt.ndt_ndc = 13
                                      AND d.scd_st IN ('1', 'A')
                             ORDER BY scd_ndt, d.scd_id DESC
                                FETCH FIRST ROW ONLY)
                                NUMB,
                            (  SELECT d.scd_issued_dt
                                 FROM uss_person.v_sc_document   d,
                                      USS_NDI.v_ndi_document_type dt
                                WHERE     scd_sc = pdf_sc
                                      AND d.scd_ndt = dt.ndt_id
                                      AND dt.ndt_ndc = 13
                                      AND d.scd_st IN ('1', 'A')
                             ORDER BY scd_ndt, d.scd_id DESC
                                FETCH FIRST ROW ONLY)
                                DOCDATE,
                            (SELECT MAX (
                                        CASE
                                            WHEN LENGTH (
                                                     TRANSLATE (
                                                         da.apda_val_string,
                                                         '1-',
                                                         '1')) =
                                                 13
                                            THEN
                                                TO_NUMBER (
                                                    TRANSLATE (
                                                        da.apda_val_string,
                                                        '1-',
                                                        '1')
                                                        DEFAULT NULL ON CONVERSION ERROR)
                                            ELSE
                                                NULL
                                        END) -- serhii: #fix_17/11/2023 UNZR restrict to number(13)
                               FROM uss_esr.ap_document       d,
                                    uss_esr.ap_document_attr  da
                              WHERE     PD_AP = d.apd_ap
                                    AND d.apd_id = da.apda_apd
                                    AND da.apda_nda = 810
                                    AND da.history_status = 'A'
                                    AND PD_ID = X_PD)
                                UNZR,
                            CASE SCI_GENDER
                                WHEN 'M' THEN 1
                                WHEN 'F' THEN 2
                                ELSE NULL
                            END
                                GENDER,
                            CASE
                                WHEN EXISTS
                                         (SELECT 1
                                            FROM uss_person.v_sc_document p
                                           WHERE     p.scd_sc = pdf_sc -- serhii 06/06/2024: changed from X_SC by #103761-4
                                                 AND p.scd_ndt IN (8, 9)
                                                 AND p.scd_st IN ('1', 'A'))
                                THEN
                                    2
                                ELSE
                                    1
                            END
                                CITIZENSHIP,
                            CASE
                                WHEN NPT_CODE = 327
                                THEN
                                    getRAddrMF (app_id)
                                ELSE
                                       --Індекс відділення зв’язку, тип населеного пункту, назва населеного пункту, тип вулиці, назва вулиці, номер будинку, номер корпусу, номер квартири
                                       NVL2 (get_doc_string (NULL,
                                                             app_ap,
                                                             600,
                                                             587),
                                                get_doc_string (NULL,
                                                                app_ap,
                                                                600,
                                                                587)
                                             || ', ',
                                             '')                    -- R_INDEX
                                    || NVL2 (get_doc_string (NULL,
                                                             app_ap,
                                                             600,
                                                             580),
                                                get_doc_string (NULL,
                                                                app_ap,
                                                                600,
                                                                580)
                                             || ', ',
                                             '') -- тип населеного пункту, назва населеного пункту
                                    || NVL2 (
                                           (SELECT MAX (st.nsrt_name)    stre_tp_name
                                              FROM uss_ndi.v_ndi_street  z
                                                   LEFT JOIN
                                                   uss_ndi.v_ndi_street_type
                                                   st
                                                       ON (st.nsrt_id =
                                                           z.ns_nsrt)
                                             WHERE z.ns_id =
                                                   get_doc_id (NULL,
                                                               app_ap,
                                                               600,
                                                               585)),
                                              (SELECT MAX (st.nsrt_name)    stre_tp_name
                                                 FROM uss_ndi.v_ndi_street  z
                                                      LEFT JOIN
                                                      uss_ndi.v_ndi_street_type
                                                      st
                                                          ON (st.nsrt_id =
                                                              z.ns_nsrt)
                                                WHERE z.ns_id =
                                                      get_doc_id (NULL,
                                                                  app_ap,
                                                                  600,
                                                                  585))
                                           || ', ',
                                           '')                   -- тип вулиці
                                    || NVL2 (
                                           NVL (
                                               (SELECT MAX (
                                                              st.nsrt_name
                                                           || z.ns_name)
                                                  FROM uss_ndi.v_ndi_street z
                                                       LEFT JOIN
                                                       uss_ndi.v_ndi_street_type
                                                       st
                                                           ON st.nsrt_id =
                                                              z.ns_nsrt
                                                 WHERE z.ns_id =
                                                       get_doc_id (NULL,
                                                                   app_ap,
                                                                   600,
                                                                   585))/* якщо дані дозволяють, то швидше: get_doc_string (null, app_ap, 600, 585) */
                                                                        ,
                                               get_doc_string (NULL,
                                                               app_ap,
                                                               600,
                                                               787)),
                                              NVL (
                                                  (SELECT MAX (
                                                                 st.nsrt_name
                                                              || z.ns_name)
                                                     FROM uss_ndi.v_ndi_street
                                                          z
                                                          LEFT JOIN
                                                          uss_ndi.v_ndi_street_type
                                                          st
                                                              ON st.nsrt_id =
                                                                 z.ns_nsrt
                                                    WHERE z.ns_id =
                                                          get_doc_id (NULL,
                                                                      app_ap,
                                                                      600,
                                                                      585)),
                                                  get_doc_string (NULL,
                                                                  app_ap,
                                                                  600,
                                                                  787))
                                           || ', ',
                                           '')                 -- назва вулиці
                                    || NVL2 (get_doc_string (NULL,
                                                             app_ap,
                                                             600,
                                                             584),
                                                get_doc_string (NULL,
                                                                app_ap,
                                                                600,
                                                                584)
                                             || ', ',
                                             '')
                                    || NVL2 (get_doc_string (NULL,
                                                             app_ap,
                                                             600,
                                                             583),
                                                get_doc_string (NULL,
                                                                app_ap,
                                                                600,
                                                                583)
                                             || ', ',
                                             '')
                                    || NVL2 (get_doc_string (NULL,
                                                             app_ap,
                                                             600,
                                                             582),
                                                get_doc_string (NULL,
                                                                app_ap,
                                                                600,
                                                                582)
                                             || ', ',
                                             '')
                            END
                                R_ADDRESS,
                            CASE
                                WHEN NPT_CODE = 327
                                THEN
                                    get_doc_string (app_id,
                                                    app_ap,
                                                    605,
                                                    1776)
                                ELSE
                                    get_doc_string (NULL,
                                                    app_ap,
                                                    600,
                                                    587)
                            END
                                R_INDEX,
                            (SELECT MAX (k.kaot_code)
                               FROM uss_ndi.v_ndi_katottg k
                              WHERE k.kaot_id = CASE
                                                    WHEN NPT_CODE = 327
                                                    THEN
                                                        get_doc_id (app_id,
                                                                    app_ap,
                                                                    605,
                                                                    1775)
                                                    ELSE
                                                        get_doc_id (NULL,
                                                                    app_ap,
                                                                    600,
                                                                    580)
                                                END)
                                R_CATOTTG,
                            (SELECT MAX (st.nsrt_code)     nsrt_code
                               FROM uss_ndi.v_ndi_street  z
                                    LEFT JOIN uss_ndi.v_ndi_street_type st
                                        ON (st.nsrt_id = z.ns_nsrt)
                              WHERE z.ns_id = CASE
                                                  WHEN NPT_CODE = 327
                                                  THEN
                                                      get_doc_id (app_id,
                                                                  app_ap,
                                                                  605,
                                                                  1777)
                                                  ELSE
                                                      get_doc_id (NULL,
                                                                  app_ap,
                                                                  600,
                                                                  585)
                                              END)
                                R_TYPEV,
                            CASE
                                WHEN NPT_CODE = 327
                                THEN
                                    NVL (
                                        (SELECT MAX (
                                                    st.nsrt_name || z.ns_name)
                                           FROM uss_ndi.v_ndi_street  z
                                                LEFT JOIN
                                                uss_ndi.v_ndi_street_type st
                                                    ON st.nsrt_id = z.ns_nsrt
                                          WHERE z.ns_id = get_doc_id (NULL,
                                                                      app_ap,
                                                                      605,
                                                                      1777)),
                                        get_doc_string (app_id,
                                                        app_ap,
                                                        605,
                                                        1785))
                                ELSE
                                    NVL (
                                        (SELECT MAX (
                                                    st.nsrt_name || z.ns_name)
                                           FROM uss_ndi.v_ndi_street  z
                                                LEFT JOIN
                                                uss_ndi.v_ndi_street_type st
                                                    ON st.nsrt_id = z.ns_nsrt
                                          WHERE z.ns_id = get_doc_id (NULL,
                                                                      app_ap,
                                                                      600,
                                                                      585))/* якщо дані дозволяють, то швидше: get_doc_string (null, app_ap, 600, 585) */
                                                                           ,
                                        get_doc_string (NULL,
                                                        app_ap,
                                                        600,
                                                        787))
                            END
                                R_NAMEV,
                            CASE
                                WHEN NPT_CODE = 327
                                THEN
                                    get_doc_string (app_id,
                                                    app_ap,
                                                    605,
                                                    1778)
                                ELSE
                                    get_doc_string (NULL,
                                                    app_ap,
                                                    600,
                                                    584)
                            END
                                R_NUMB,
                            CASE
                                WHEN NPT_CODE = 327
                                THEN
                                    get_doc_string (app_id,
                                                    app_ap,
                                                    605,
                                                    1779)
                                ELSE
                                    get_doc_string (NULL,
                                                    app_ap,
                                                    600,
                                                    583)
                            END
                                R_NUMK,
                            CASE
                                WHEN NPT_CODE = 327
                                THEN
                                    get_doc_string (app_id,
                                                    app_ap,
                                                    605,
                                                    1788)
                                ELSE
                                    get_doc_string (NULL,
                                                    app_ap,
                                                    600,
                                                    582)
                            END
                                R_NUMA, -- serhii: #fix_17/11/2023 memr_r_numa
                            CASE
                                WHEN NPT_CODE = 327
                                THEN
                                    getFAddrMF (app_id)
                                ELSE
                                       --Індекс відділення зв’язку, тип населеного пункту, назва населеного пункту, тип вулиці, назва вулиці, номер будинку, номер корпусу, номер квартири
                                       NVL2 (get_doc_string (NULL,
                                                             app_ap,
                                                             600,
                                                             599),
                                                get_doc_string (NULL,
                                                                app_ap,
                                                                600,
                                                                599)
                                             || ', ',
                                             '')
                                    || NVL2 (get_doc_string (NULL,
                                                             app_ap,
                                                             600,
                                                             604),
                                                get_doc_string (NULL,
                                                                app_ap,
                                                                600,
                                                                604)
                                             || ', ',
                                             '')
                                    || NVL2 (
                                           (SELECT MAX (st.nsrt_name)    stre_tp_name
                                              FROM uss_ndi.v_ndi_street  z
                                                   LEFT JOIN
                                                   uss_ndi.v_ndi_street_type
                                                   st
                                                       ON (st.nsrt_id =
                                                           z.ns_nsrt)
                                             WHERE z.ns_id =
                                                   get_doc_id (NULL,
                                                               app_ap,
                                                               600,
                                                               597)),
                                              (SELECT MAX (st.nsrt_name)    stre_tp_name
                                                 FROM uss_ndi.v_ndi_street  z
                                                      LEFT JOIN
                                                      uss_ndi.v_ndi_street_type
                                                      st
                                                          ON (st.nsrt_id =
                                                              z.ns_nsrt)
                                                WHERE z.ns_id =
                                                      get_doc_id (NULL,
                                                                  app_ap,
                                                                  600,
                                                                  597))
                                           || ', ',
                                           '')                   -- тип вулиці
                                    || NVL2 (
                                           NVL (
                                               (SELECT MAX (
                                                              st.nsrt_name
                                                           || z.ns_name)
                                                  FROM uss_ndi.v_ndi_street z
                                                       LEFT JOIN
                                                       uss_ndi.v_ndi_street_type
                                                       st
                                                           ON st.nsrt_id =
                                                              z.ns_nsrt
                                                 WHERE z.ns_id =
                                                       get_doc_id (NULL,
                                                                   app_ap,
                                                                   600,
                                                                   597)),
                                               get_doc_string (NULL,
                                                               app_ap,
                                                               600,
                                                               788)),
                                              NVL (
                                                  (SELECT MAX (
                                                                 st.nsrt_name
                                                              || z.ns_name)
                                                     FROM uss_ndi.v_ndi_street
                                                          z
                                                          LEFT JOIN
                                                          uss_ndi.v_ndi_street_type
                                                          st
                                                              ON st.nsrt_id =
                                                                 z.ns_nsrt
                                                    WHERE z.ns_id =
                                                          get_doc_id (NULL,
                                                                      app_ap,
                                                                      600,
                                                                      597)),
                                                  get_doc_string (NULL,
                                                                  app_ap,
                                                                  600,
                                                                  788))
                                           || ', ',
                                           '')
                                    || NVL2 (get_doc_string (NULL,
                                                             app_ap,
                                                             600,
                                                             596),
                                                get_doc_string (NULL,
                                                                app_ap,
                                                                600,
                                                                596)
                                             || ', ',
                                             '')
                                    || NVL2 (get_doc_string (NULL,
                                                             app_ap,
                                                             600,
                                                             595),
                                                get_doc_string (NULL,
                                                                app_ap,
                                                                600,
                                                                595)
                                             || ', ',
                                             '')
                                    || NVL2 (get_doc_string (NULL,
                                                             app_ap,
                                                             600,
                                                             594),
                                                get_doc_string (NULL,
                                                                app_ap,
                                                                600,
                                                                594)
                                             || ', ',
                                             '')
                            END
                                F_ADDRESS,
                            CASE
                                WHEN NPT_CODE = 327
                                THEN
                                    get_doc_string (app_id,
                                                    app_ap,
                                                    605,
                                                    1782)
                                ELSE
                                    get_doc_string (NULL,
                                                    app_ap,
                                                    600,
                                                    599)
                            END
                                F_INDEX,
                            (SELECT MAX (k.kaot_code)
                               FROM uss_ndi.v_ndi_katottg k
                              WHERE k.kaot_id = CASE
                                                    WHEN NPT_CODE = 327
                                                    THEN
                                                        get_doc_id (app_id,
                                                                    app_ap,
                                                                    605,
                                                                    1781)
                                                    ELSE
                                                        get_doc_id (NULL,
                                                                    app_ap,
                                                                    600,
                                                                    604)
                                                END)
                                F_CATOTTG,
                            (SELECT MAX (st.nsrt_code)     nsrt_code
                               FROM uss_ndi.v_ndi_street  z
                                    LEFT JOIN uss_ndi.v_ndi_street_type st
                                        ON (st.nsrt_id = z.ns_nsrt)
                              WHERE z.ns_id = CASE
                                                  WHEN NPT_CODE = 327
                                                  THEN
                                                      get_doc_id (app_id,
                                                                  app_ap,
                                                                  605,
                                                                  1783)
                                                  ELSE
                                                      get_doc_id (NULL,
                                                                  app_ap,
                                                                  600,
                                                                  597)
                                              END)
                                F_TYPEV,
                            CASE
                                WHEN NPT_CODE = 327
                                THEN
                                    NVL (
                                        (SELECT MAX (
                                                    st.nsrt_name || z.ns_name)
                                           FROM uss_ndi.v_ndi_street  z
                                                LEFT JOIN
                                                uss_ndi.v_ndi_street_type st
                                                    ON st.nsrt_id = z.ns_nsrt
                                          WHERE z.ns_id = get_doc_id (NULL,
                                                                      app_ap,
                                                                      605,
                                                                      1783)),
                                        get_doc_string (app_id,
                                                        app_ap,
                                                        605,
                                                        1786))
                                ELSE
                                    NVL (
                                        (SELECT MAX (
                                                    st.nsrt_name || z.ns_name)
                                           FROM uss_ndi.v_ndi_street  z
                                                LEFT JOIN
                                                uss_ndi.v_ndi_street_type st
                                                    ON st.nsrt_id = z.ns_nsrt
                                          WHERE z.ns_id = get_doc_id (NULL,
                                                                      app_ap,
                                                                      600,
                                                                      597)),
                                        get_doc_string (NULL,
                                                        app_ap,
                                                        600,
                                                        788))
                            END
                                F_NAMEV,
                            CASE
                                WHEN NPT_CODE = 327
                                THEN
                                    get_doc_string (app_id,
                                                    app_ap,
                                                    605,
                                                    1784)
                                ELSE
                                    get_doc_string (NULL,
                                                    app_ap,
                                                    600,
                                                    596)
                            END
                                F_NUMB,
                            CASE
                                WHEN NPT_CODE = 327
                                THEN
                                    get_doc_string (app_id,
                                                    app_ap,
                                                    605,
                                                    1787)
                                ELSE
                                    get_doc_string (NULL,
                                                    app_ap,
                                                    600,
                                                    595)
                            END
                                F_NUMK,
                            CASE
                                WHEN NPT_CODE = 327
                                THEN
                                    get_doc_string (app_id,
                                                    app_ap,
                                                    605,
                                                    1780)
                                ELSE
                                    get_doc_string (NULL,
                                                    app_ap,
                                                    600,
                                                    594)
                            END
                                F_NUMA,
                            NVL (get_doc_string (app_id,
                                                 app_ap,
                                                 605,
                                                 649),
                                 'B')
                                FAM_RELAT,
                            pd_start_dt
                                D_FROM,
                            pd_stop_dt
                                D_TILL,
                            ap_reg_dt
                                D_APP,
                            scy_group
                                DIS_GROUP,
                            dic_code
                                DIS_REASON,
                            scd_number
                                DOC_INV,
                            SCD_ISSUED_DT
                                D_INV,
                            scy_decision_dt
                                DIS_BEGIN,
                            scy_start_dt
                                DIS_START,
                            NVL2 (
                                scy_start_dt,
                                NVL (scy_stop_dt,
                                     TO_DATE ('31.12.2099', 'dd.mm.yyyy')),
                                NULL)
                                DIS_END,
                            NPT_CODE
                                KFN,
                            CASE
                                WHEN MIN (
                                         CASE
                                             WHEN APP_TP IN ('P', 'Z')
                                             THEN
                                                 APP_TP
                                         END)
                                         OVER (PARTITION BY X_SC, X_PD) =
                                     APP_TP
                                THEN
                                    (SELECT NVL (SUM (pp.pdp_sum), 0)
                                       FROM uss_esr.pd_payment pp
                                      WHERE     pp.pdp_pd = pd_id
                                            AND pp.history_status = 'A'
                                            AND TRUNC (l_start_dt, 'MM') BETWEEN pp.pdp_start_dt
                                                                             AND pp.pdp_stop_dt)
                                ELSE
                                    NULL
                            END
                                P_SUMMD,
                            CASE
                                WHEN MIN (
                                         CASE
                                             WHEN APP_TP IN ('P', 'Z')
                                             THEN
                                                 APP_TP
                                         END)
                                         OVER (PARTITION BY X_SC, X_PD) =
                                     APP_TP
                                THEN
                                    NVL (x_sum, 0)
                                ELSE
                                    NULL
                            END
                                N_SUMMD,
                            CASE
                                WHEN MIN (
                                         CASE
                                             WHEN APP_TP IN ('P', 'Z')
                                             THEN
                                                 APP_TP
                                         END)
                                         OVER (PARTITION BY X_SC, X_PD) =
                                     APP_TP
                                THEN
                                    (SELECT NVL (
                                                SUM (
                                                    CASE
                                                        WHEN psd.prsd_sum > 0
                                                        THEN
                                                            psd.prsd_sum
                                                        ELSE
                                                            0
                                                    END),
                                                0)    s_sum
                                       FROM uss_esr.pr_sheet_detail  psd
                                            JOIN uss_esr.pr_sheet ps
                                                ON     psd.prsd_prs =
                                                       ps.prs_id
                                                   AND ps.prs_st IN
                                                           ('NA',
                                                            'KV1',
                                                            'KV2')
                                            JOIN uss_esr.payroll pr
                                                ON     ps.prs_pr = pr.pr_id
                                                   AND pr.pr_st IN ('F')
                                      WHERE     prs_pc = X_PC
                                            AND pr.pr_month =
                                                TRUNC (l_start_dt, 'MM')
                                            AND psd.prsd_tp IN ('PWI', 'RDN')
                                            AND EXISTS
                                                    (SELECT 1
                                                       FROM uss_esr.ac_detail
                                                            ad
                                                      WHERE     ad.acd_prsd =
                                                                psd.prsd_id
                                                            AND ad.acd_pd =
                                                                PD_ID))
                                ELSE
                                    NULL
                            END
                                V_SUMMD,
                            CASE
                                WHEN     NPT_CODE != 327
                                     AND MIN (
                                             CASE
                                                 WHEN APP_TP IN ('P', 'Z')
                                                 THEN
                                                     APP_TP
                                             END)
                                             OVER (PARTITION BY X_SC, X_PD) =
                                         APP_TP
                                THEN
                                    (SELECT MAX (pd.pdd_value)
                                       FROM uss_esr.pd_detail  pd
                                            JOIN uss_esr.pd_payment p
                                                ON p.pdp_id = pd.pdd_pdp
                                      WHERE     p.pdp_pd = X_PD
                                            AND pd.pdd_ndp = 133 -- 133 Обмеження розміру допомоги (прожитковий мінімум сім`ї)
                                            AND l_start_dt BETWEEN pd.pdd_start_dt
                                                               AND pd.pdd_stop_dt
                                            AND p.history_status = 'A')
                                ELSE
                                    NULL
                            END
                                SIZE_SMF,
                            CASE
                                WHEN NPT_CODE = 327
                                THEN
                                    (SELECT MAX (dc.scd_number)
                                       FROM uss_person.v_sc_document dc
                                      WHERE     dc.scd_sc = pdf_sc -- serhii 06/06/2024: changed from X_SC by #103761-4
                                            AND dc.scd_ndt = 10052)
                                ELSE
                                    NULL
                            END
                                N_DOV,
                            CASE
                                WHEN NPT_CODE = 327
                                THEN
                                    (SELECT MAX (dc.scd_issued_dt)
                                       FROM uss_person.v_sc_document dc
                                      WHERE     dc.scd_sc = pdf_sc -- serhii 06/06/2024: changed from X_SC by #103761-4
                                            AND dc.scd_ndt = 10052)
                                ELSE
                                    NULL
                            END
                                D_GIVE,
                            CASE
                                WHEN     NPT_CODE = 327
                                     AND (APP_TP = 'FP' OR APP_TP = 'FM') -- тип учасника = "член сім'ї" або "Утриманець"
                                THEN
                                    1
                                WHEN     NPT_CODE = 327
                                     AND APP_TP != 'FP'
                                     AND APP_TP != 'FM'
                                THEN
                                    0
                                ELSE
                                    NULL
                            END
                                OZN_FAM,
                            SIGN (NVL (SUM_PMT, 0))
                                OZN_OTR,
                            CASE              /* Ознака уповноваженої особи */
                                WHEN NPT_CODE = 327 AND APP_TP = 'P' THEN 1
                                WHEN NPT_CODE = 327 AND APP_TP != 'P' THEN 0
                                ELSE NULL
                            END
                                OZN_AGENT,
                            APP_TP,
                            X_PC,
                            SUM_PMT,
                            X_SC,
                            PDF_SC,
                            ORG_ID,
                            X_SC_UNIQUE,
                            X_PD
                       FROM src
                      WHERE rn = 1)                     --  select * from flds
                                   ,
                cond
                AS
                    (  SELECT flds.*,
                                 '1'
                              || LPAD (org_id, 5, '0')
                              || LPAD (
                                     REPLACE (NVL (X_SC_UNIQUE, 0), 'T', '9'),
                                     14,
                                     '0')
                              || CASE
                                     WHEN MIN (
                                              CASE
                                                  WHEN APP_TP IN ('P', 'Z')
                                                  THEN
                                                      APP_TP
                                              END)
                                              OVER (PARTITION BY X_SC, X_PD) =
                                          APP_TP
                                     THEN
                                         '00'
                                     ELSE
                                         LPAD (
                                               DENSE_RANK ()
                                                   OVER (
                                                       PARTITION BY X_SC
                                                       ORDER BY
                                                           CASE APP_TP
                                                               WHEN 'P' THEN -1
                                                               WHEN 'Z' THEN 0
                                                               ELSE PDF_SC
                                                           END)
                                             - 1,
                                             2,
                                             '0')
                                 END    ID_FAM
                         FROM flds
                        WHERE     1 = 1
                              AND X_SC_UNIQUE IS NOT NULL
                              AND PDF_SC IS NOT NULL
                     /* 15/07/2024 serhii: #105323 перевіряємо заповнення нижче в ападейті
                       and REP_PERIOD is not null
                       and CALC_PERIOD is not null
                       --and N_ID is not null  #105473
                       and trim(SURNAME) is not null
                       and trim(NAME) is not null
                       and BDATE is not null
                       and DOCTYPE is not null
                       and NUMB is not null
                       --and DOCDATE is not null  #105473
                       and CITIZENSHIP is not null
                       and R_ADDRESS is not null
                       and F_ADDRESS is not null
                       and FAM_RELAT is not null
                       and D_FROM is not null
                       and D_TILL is not null
                       and D_APP is not null
                       --and (DIS_GROUP is null or DOC_INV is not null)  #105473
                       --and (DIS_GROUP is null or D_INV is not null)  #105473
                       --and (DIS_GROUP is null or DIS_BEGIN is not null) #105473
                       and KFN is not null
                       and (KFN != 327 or OZN_OTR = 0 or (OZN_OTR = 1 and N_DOV is not null and D_GIVE is not null))
                       and (KFN != 327 or (OZN_FAM is not null and OZN_OTR is not null and OZN_AGENT is not null))
                     */
                     ORDER BY org_id,
                              X_SC,
                              X_PD,
                              CASE APP_TP
                                  WHEN 'P' THEN -1
                                  WHEN 'Z' THEN 0
                                  ELSE PDF_SC
                              END)                       -- select * from cond
            SELECT NULL
                       AS memr_id,
                   p_me_id
                       AS memr_me,
                   X_PC
                       AS memr_pc,
                   NULL
                       AS memr_ef,
                   ID_FAM
                       AS memr_id_fam,
                   REP_PERIOD
                       AS memr_rep_period,
                   CALC_PERIOD
                       AS memr_calc_period,
                   N_ID
                       AS memr_n_id,
                   SURNAME
                       AS memr_surname,
                   NAME
                       AS memr_name,
                   PATRONYMIC
                       AS memr_patronymic,
                   BDATE
                       AS memr_bdate,
                   DOCTYPE
                       AS memr_doctype,
                   SERIES
                       AS memr_series,
                   NUMB
                       AS memr_numb,
                   DOCDATE
                       AS memr_docdate,
                   UNZR
                       AS memr_unzr,
                   GENDER
                       AS memr_gender,
                   CITIZENSHIP
                       AS memr_citizenship,
                   NVL (SUBSTR (R_ADDRESS, 1, 250), 'Україна')
                       AS memr_r_address,        -- 12/09/2024 serhii #108381 якщо пуста адреса
                   R_INDEX
                       AS memr_r_index,
                   R_CATOTTG
                       AS memr_r_catottg,
                   R_TYPEV
                       AS memr_r_typev,
                   SUBSTR (R_NAMEV, 1, 150)
                       AS memr_r_namev,
                   R_NUMB
                       AS memr_r_numb,
                   R_NUMK
                       AS memr_r_numk,
                   SUBSTR (R_NUMA, 1, 50)
                       AS memr_r_numa,
                   NVL (SUBSTR (F_ADDRESS, 1, 250), 'Україна')
                       AS memr_f_address,        -- 12/09/2024 serhii #108381 якщо пуста адреса
                   F_INDEX
                       AS memr_f_index,
                   F_CATOTTG
                       AS memr_f_catottg,
                   F_TYPEV
                       AS memr_f_typev,
                   SUBSTR (F_NAMEV, 1, 150)
                       AS memr_f_namev,
                   SUBSTR (F_NUMB, 1, 50)
                       AS memr_f_numb,
                   F_NUMK
                       AS memr_f_numk,
                   F_NUMA
                       AS memr_f_numa,
                   FAM_RELAT
                       AS memr_fam_relat,
                   D_FROM
                       AS memr_d_from,
                   D_TILL
                       AS memr_d_till,
                   D_APP
                       AS memr_d_app,
                   DIS_GROUP
                       AS memr_dis_group,
                   DIS_REASON
                       AS memr_dis_reason,
                   DOC_INV
                       AS memr_doc_inv,
                   D_INV
                       AS memr_d_inv,
                   DIS_BEGIN
                       AS memr_dis_begin,
                   DIS_START
                       AS memr_dis_start,
                   DIS_END
                       AS memr_dis_end,
                   KFN
                       AS memr_kfn,
                   P_SUMMD
                       AS memr_p_summd,
                   N_SUMMD
                       AS memr_n_summd,
                   V_SUMMD
                       AS memr_v_summd,
                   SIZE_SMF
                       AS memr_size_smf,
                   c_st_MEMR_Uncomplete
                       AS memr_st, -- 15/07/2024 serhii: c_st_MEMR_Exists => c_st_MEMR_Uncomplete by #105323
                   N_DOV
                       AS memr_n_dov,
                   D_GIVE
                       AS memr_d_give,
                   OZN_FAM
                       AS memr_ozn_fam,
                   OZN_OTR
                       AS memr_ozn_otr,
                   OZN_AGENT
                       AS memr_ozn_agent,
                   APP_TP
                       AS memr_app_tp,
                   SUM_PMT
                       AS memr_sum_pmt
              FROM cond;

        l_cnt := SQL%ROWCOUNT;

        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (
                'prepare_me_rows INSERTED: ' || l_cnt);
        END IF;

        -- 15/07/2024 serhii: added by #105323 у всіх рядках де заповенені обов'язкові поля проставляємо стан E:Створено
        UPDATE me_minfin_request_rows
           SET memr_st = c_st_MEMR_Exists
         WHERE     memr_me = p_me_id
               AND memr_rep_period IS NOT NULL
               AND memr_calc_period IS NOT NULL
               --and memr_n_id is not null  #105473
               AND TRIM (memr_surname) IS NOT NULL
               AND TRIM (memr_name) IS NOT NULL
               AND memr_bdate IS NOT NULL
               AND memr_doctype IS NOT NULL
               AND memr_numb IS NOT NULL
               --and memr_docdate is not null  #105473
               AND memr_citizenship IS NOT NULL
               AND memr_r_address IS NOT NULL
               AND memr_f_address IS NOT NULL
               AND memr_fam_relat IS NOT NULL
               AND memr_d_from IS NOT NULL
               AND memr_d_till IS NOT NULL
               AND memr_d_app IS NOT NULL
               --and (memr_dis_group is null or memr_doc_inv is not null)  #105473
               --and (memr_dis_group is null or memr_d_inv is not null)  #105473
               --and (memr_dis_group is null or memr_dis_begin is not null) #105473
               AND memr_kfn IS NOT NULL
               AND (   memr_kfn != 327
                    OR memr_ozn_otr = 0
                    OR (    memr_ozn_otr = 1
                        AND memr_n_dov IS NOT NULL
                        AND memr_d_give IS NOT NULL))
               AND (   memr_kfn != 327
                    OR (    memr_ozn_fam IS NOT NULL
                        AND memr_ozn_otr IS NOT NULL
                        AND memr_ozn_agent IS NOT NULL));

        l_cnt := SQL%ROWCOUNT;

        UPDATE mass_exchanges m
           SET m.me_count = l_cnt,
               m.me_st = c_st_ME_Exists,
               m.me_hs_fix = l_hs
         WHERE me_id = p_me_id;

        write_me_log (p_mel_me        => p_me_id,
                      p_mel_hs        => l_hs,
                      p_mel_st        => c_st_ME_Exists,
                      p_mel_message   => 'Завершено формування пакету',
                      p_mel_st_old    => c_st_ME_Creating);
    END;

    -- IC #98164 Формування рядків вивантаження по умовам запиту ВПП ООН
    PROCEDURE prepare_me_rows_un (p_me_id mass_exchanges.me_id%TYPE)
    IS
        l_start_dt   DATE;
        l_cnt        NUMBER;
        l_me_tp      mass_exchanges.me_tp%TYPE;
    BEGIN
        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg ('START prepare_me_rows_un');
        END IF;

        SELECT m.me_month, m.me_tp
          INTO l_start_dt, l_me_tp
          FROM mass_exchanges m
         WHERE me_id = p_me_id;

        INSERT INTO me_vppun_request_rows (mvrr_id,
                                           mvrr_me,
                                           mvrr_pc,
                                           mvrr_ef,
                                           mvrr_pd,
                                           mvrr_icc_registry,
                                           mvrr_id_fam,
                                           mvrr_surname,
                                           mvrr_name,
                                           mvrr_patronymic,
                                           mvrr_bdate,
                                           mvrr_n_id,
                                           mvrr_passport,
                                           mvrr_gender,
                                           mvrr_category,
                                           mvrr_amount,
                                           mvrr_phone,
                                           mvrr_region,
                                           mvrr_ratu,
                                           mvrr_district,
                                           mvrr_pindex,
                                           mvrr_pindexname,
                                           mvrr_address,
                                           mvrr_iban,
                                           mvrr_st)
            SELECT NULL
                       mvrr_id,
                   p_me_id
                       mvrr_me,
                   pc_id,
                   NULL
                       mvrr_ef,
                   pd_id,
                   ICC_REGISTRY,
                   ID_FAM,
                   SURNAME,
                   NAME,
                   PATRONYMIC,
                   BDATE,
                   N_ID,
                   PASSPORT,
                   GENDER,
                   CATEGORY,
                   TRIM (TO_CHAR (AMOUNT, '99999990.00'))
                       AMOUNT,
                   CASE WHEN LENGTH (PHONE) != 10 THEN NULL ELSE PHONE END
                       PHONE,
                   REGION,
                   RATU,
                   DISTRICT,
                   PINDEX,
                   PINDEXNAME,
                   ADDRESS,
                   IBAN,
                   c_st_ME_Exists
                       mvrr_st
              FROM (SELECT pd_pc
                               pc_id,
                           pd_id,
                              CASE WHEN l_me_tp = 'UNP'            -- ООН Post
                                                        THEN 'P' ELSE 'B' END -- Bank
                           || 'ICC'
                           || TO_CHAR (l_start_dt, 'yymm')
                               AS icc_registry,
                              '1'
                           || LPAD ('' || NVL (pa_org, 0), 5, 0)
                           || LPAD ('' || pd_id, 20, '0')
                           || LPAD ('' || '0', 2, '0')
                               AS id_fam,
                           SUBSTR (REPLACE (UPPER (ci.sco_ln), '1', 'І'),
                                   1,
                                   50)
                               surname,
                           SUBSTR (REPLACE (UPPER (ci.sco_fn), '1', 'І'),
                                   1,
                                   50)
                               name,
                           SUBSTR (REPLACE (UPPER (ci.sco_mn), '1', 'І'),
                                   1,
                                   50)
                               patronymic,
                           TO_CHAR (sco_birth_dt, 'YYYY-MM-DD')
                               AS bdate,
                           NVL (sco_numident, '0000000000')
                               n_id,
                           sco_pasp_seria || sco_pasp_number
                               AS passport,
                           DECODE (sco_gender,  'Чоловіча', 1,  'Жіноча', 2)
                               AS gender,
                           '169'
                               AS category,
                           (SELECT SUM (pdp_sum)
                              FROM uss_esr.pd_payment pdp
                             WHERE     pdp.pdp_pd = pd_id
                                   AND pdp.history_status = 'A'
                                   AND l_start_dt BETWEEN TRUNC (
                                                              pdp.pdp_start_dt,
                                                              'mm')
                                                      AND pdp.pdp_stop_dt)
                               AS amount,
                           REGEXP_REPLACE (get_doc_string (NULL,
                                                           pd_ap,
                                                           600,
                                                           605),
                                           '[^[:digit:]]',
                                           '')
                               AS phone,                       -- тільки цифри
                           (SELECT MAX (obl.kaot_name)
                              FROM uss_ndi.v_ndi_org2kaot  z,
                                   uss_ndi.v_ndi_katottg   osz,
                                   uss_ndi.v_ndi_katottg   obl
                             WHERE     osz.kaot_kaot_l1 = obl.kaot_id
                                   AND nok_kaot = osz.kaot_id
                                   AND nok_org = pa_org)
                               AS region,
                           (SELECT MAX (rn.kaot_code)
                              FROM uss_ndi.v_ndi_org2kaot  z,
                                   uss_ndi.v_ndi_katottg   osz,
                                   uss_ndi.v_ndi_katottg   rn
                             WHERE     osz.kaot_kaot_l2 = rn.kaot_id
                                   AND nok_kaot = osz.kaot_id
                                   AND nok_org = pa_org)
                               AS ratu,
                           (SELECT MAX (rn.kaot_name)
                              FROM uss_ndi.v_ndi_org2kaot  z,
                                   uss_ndi.v_ndi_katottg   osz,
                                   uss_ndi.v_ndi_katottg   rn
                             WHERE     osz.kaot_kaot_l2 = rn.kaot_id
                                   AND nok_kaot = osz.kaot_id
                                   AND nok_org = pa_org)
                               AS district,
                           NVL (
                               get_doc_string (NULL,
                                               pd_ap,
                                               600,
                                               599),
                               (SELECT MAX (sca_postcode)
                                  FROM uss_person.v_sc_address sca
                                 WHERE     sca_sc = pc_sc
                                       AND sca.history_status = 'A'
                                       AND sca_tp = '2'))
                               AS pindex,
                           NVL (
                               (SELECT MAX (kaot_name)
                                  FROM uss_ndi.v_ndi_katottg
                                 WHERE kaot_id =
                                       (SELECT MAX (Apda_Val_Id)
                                          FROM uss_esr.Ap_Person,
                                               uss_esr.Ap_Document,
                                               uss_esr.Ap_Document_Attr
                                         WHERE     Ap_Person.History_Status =
                                                   'A'
                                               AND Ap_Document.History_Status =
                                                   'A'
                                               AND Apd_App = App_Id
                                               AND Apda_Apd = Apd_Id
                                               AND App_Tp = 'Z'
                                               AND App_Ap = pd_ap
                                               AND Apd_Ndt = 600
                                               AND Apda_Nda = 604)),
                               (SELECT MAX (sca_city)
                                  FROM uss_person.v_sc_address sca
                                 WHERE     sca_sc = pc_sc
                                       AND sca.history_status = 'A'
                                       AND sca_tp = '2'))
                               AS pindexname,
                           NVL (
                               getAddrUN (d.pd_ap),
                               (SELECT MAX (
                                              sca_street
                                           || ';'
                                           || sca_building
                                           || ';'
                                           || CASE
                                                  WHEN sca_block IS NOT NULL
                                                  THEN
                                                      ' корп. ' || sca_block
                                              END
                                           || ';'
                                           || NVL2 (sca_apartment,
                                                    'кв.' || sca_apartment,
                                                    ''))
                                  FROM uss_person.v_sc_address sca
                                 WHERE     sca_sc = pc_sc
                                       AND sca.history_status = 'A'
                                       AND sca_tp = '2'))
                               AS address,
                           pdm_account
                               AS iban
                      FROM uss_esr.pc_decision  d
                           INNER JOIN uss_esr.personalcase c
                               ON c.pc_id = d.pd_pc
                           INNER JOIN uss_esr.pd_pay_method pm
                               ON     pm.pdm_pd = d.pd_id
                                  AND pm.history_status = 'A'
                                  AND pm.pdm_is_actual = 'T'
                           INNER JOIN uss_esr.pc_account ac
                               ON ac.pa_id = d.pd_pa
                           INNER JOIN uss_person.v_sc_change cc
                               ON cc.scc_id = pm.pdm_scc
                           INNER JOIN uss_person.v_sc_info ci
                               ON ci.sco_id = cc.scc_sc
                           INNER JOIN uss_esr.opfu o ON o.org_id = ac.pa_org
                     WHERE     d.pd_nst = 248
                           AND o.org_org IN (50900,
                                             51200,
                                             51400,
                                             52300,
                                             54800,
                                             55900,
                                             56300,
                                             56500,
                                             57400) -- IC #108764 брати лише рішення, які належать областям...
                           AND (   d.pd_st = 'S'
                                OR (    d.pd_st = 'PS'
                                    AND EXISTS
                                            (SELECT 1 -- IC #108764 Рішення, призупинені постійною причиною - не включати
                                               FROM uss_esr.pc_block  pcb,
                                                    uss_ndi.v_ndi_reason_not_pay
                                                    r
                                              WHERE     pcb.pcb_id = d.pd_pcb
                                                    AND r.rnp_id =
                                                        pcb.pcb_rnp
                                                    AND r.rnp_pnp_tp = 'CPY'
                                                    AND r.history_status =
                                                        'A')))
                           AND EXISTS
                                   (SELECT 1
                                      FROM uss_esr.pd_accrual_period ap
                                     WHERE     ap.pdap_pd = d.pd_id
                                           AND l_start_dt BETWEEN TRUNC (
                                                                      ap.pdap_start_dt,
                                                                      'mm')
                                                              AND ap.pdap_stop_dt
                                           AND ap.history_status = 'A')
                           AND NOT EXISTS
                                   (SELECT 1      -- НЕ отримують допомогу ВПО
                                      FROM uss_esr.pc_decision        d1,
                                           uss_esr.pd_family          f,
                                           uss_esr.pd_accrual_period  pdap
                                     WHERE     f.pdf_sc = cc.scc_sc
                                           AND f.pdf_pd = d1.pd_id
                                           AND pdap_pd = d1.pd_id
                                           AND d1.pd_nst = 664
                                           AND pdap.history_status = 'A'
                                           AND l_start_dt BETWEEN TRUNC (
                                                                      pdap_start_dt,
                                                                      'mm')
                                                              AND pdap_stop_dt)
                           AND NOT EXISTS
                                   (SELECT 1 -- КАТОТТГ місця проживання - у зоні активних або можливих бойових дій або у зоні тимчасової окупації без дати закінчення
                                      FROM uss_ndi.v_ndi_index_aspod_config,
                                           (SELECT apda_val_string    x_index
                                              FROM uss_esr.ap_person    p,
                                                   uss_esr.ap_document_attr a,
                                                   uss_esr.ap_document  dd
                                             WHERE     p.app_ap = d.pd_ap
                                                   AND p.app_sc = cc.scc_sc
                                                   AND a.apda_ap = d.pd_ap
                                                   AND dd.apd_app = p.app_id
                                                   AND a.apda_apd = dd.apd_Id
                                                   AND dd.apd_ndt = 600
                                                   AND a.apda_nda = 599
                                                   --and p.app_tp in ('O', 'Z')
                                                   AND p.history_status = 'A'
                                                   AND dd.history_status =
                                                       'A'
                                                   AND a.history_status = 'A') --Індекс адреси проживання з звернення
                                     WHERE     x_index IN
                                                   (niac_post_index,
                                                    niac_vipl_index) --Індекси з довідника АСОПД <-> КАТОТТГ
                                           AND EXISTS
                                                   (SELECT 1
                                                      FROM uss_ndi.v_ndi_kaot_state
                                                           kaots,
                                                           uss_ndi.v_ndi_normative_act
                                                           nna
                                                     WHERE     kaots_kaot =
                                                               niac_kaot
                                                           AND kaots.history_status =
                                                               'A'
                                                           AND kaots_nna =
                                                               nna_id
                                                           AND (   nna_num =
                                                                   '309' --По 309 поставнові
                                                                -- IC #112654
                                                                OR nna_nna_main =
                                                                   (SELECT aa.nna_id
                                                                      FROM uss_ndi.v_ndi_normative_act
                                                                           aa
                                                                     WHERE aa.nna_num =
                                                                           '309')--or  nna_id >= (select aa.nna_id from uss_ndi.v_ndi_normative_act aa where aa.nna_num = '309')
                                                                                 )
                                                           AND nna.history_status =
                                                               'A'
                                                           -- IC #113584
                                                           AND kaots_tp IN
                                                                   ('TO') -- Типи показників адм.одиниці V_DDN_KAOTS_TP
                                                           AND kaots_stop_dt
                                                                   IS NULL))
                           AND uss_person.API$SC_TOOLS.get_death_dt (
                                   cc.scc_sc)
                                   IS NULL -- Додати перевірку по SC_Death - чи жива ще людина
                           AND pdm_pay_tp =
                               CASE
                                   WHEN l_me_tp = 'UNP' THEN 'POST'
                                   ELSE 'BANK'
                               END
                           AND pd_stop_dt > l_start_dt)
             WHERE     amount > 0
                   AND amount < 3250
                   AND TRIM (ICC_REGISTRY) IS NOT NULL
                   AND TRIM (ID_FAM) IS NOT NULL
                   AND TRIM (SURNAME) IS NOT NULL
                   AND TRIM (NAME) IS NOT NULL
                   AND TRIM (N_ID) IS NOT NULL
                   AND TRIM (PASSPORT) IS NOT NULL
                   AND TRIM (CATEGORY) IS NOT NULL
                   AND TRIM (AMOUNT) IS NOT NULL
                   AND TRIM (REGION) IS NOT NULL
                   AND TRIM (RATU) IS NOT NULL
                   AND TRIM (DISTRICT) IS NOT NULL
                   -- для Банк: якщо в параметрах виплати довжина рахунку меньше 29 символів, то не вивантажувати (їм буде зміна виплати на пошту)
                   AND (LENGTH (IBAN) = 29 OR l_me_tp = 'UNP');

        l_cnt := SQL%ROWCOUNT;

        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (
                'prepare_me_rows_un INSERTED: ' || l_cnt);
        END IF;

        UPDATE mass_exchanges m
           SET m.me_count = l_cnt, m.me_st = c_st_ME_Exists
         WHERE me_id = p_me_id;

        write_me_log (p_mel_me        => p_me_id,
                      --p_mel_hs      => l_hs,
                      p_mel_st        => c_st_ME_Exists,
                      p_mel_message   => 'Завершено формування пакету',
                      p_mel_st_old    => c_st_ME_Creating);
    END prepare_me_rows_un;

    -- IC #107802 Формування рядків вивантаження по умовам запиту ВПП ООН (по тим сумам, що не виплачено)
    PROCEDURE prepare_me_rows_unr (p_me_id mass_exchanges.me_id%TYPE)
    IS
        l_start_dt   DATE;
        l_cnt        NUMBER;
        l_me_tp      mass_exchanges.me_tp%TYPE;
        l_me_r       NUMBER;
    BEGIN
        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (
                'START prepare_me_rows_unr');
        END IF;

        SELECT m.me_month, m.me_tp
          INTO l_start_dt, l_me_tp
          FROM mass_exchanges m
         WHERE me_id = p_me_id;

        -- формуються файли за 07-09 по тим особам, по яким невиплачено у 01-03 відповідно
        SELECT a.me_id
          INTO l_me_r
          FROM mass_exchanges a
         WHERE     a.me_tp =
                   CASE l_me_tp
                       WHEN 'UN_R' THEN 'UN'
                       WHEN 'UNP_R' THEN 'UNP'
                   END
               AND a.me_st != 'D'
               AND a.me_month = ADD_MONTHS (l_start_dt, -6);

        INSERT INTO me_vppun_request_rows (mvrr_id,
                                           mvrr_me,
                                           mvrr_pc,
                                           mvrr_ef,
                                           mvrr_pd,
                                           mvrr_icc_registry,
                                           mvrr_id_fam,
                                           mvrr_surname,
                                           mvrr_name,
                                           mvrr_patronymic,
                                           mvrr_bdate,
                                           mvrr_n_id,
                                           mvrr_passport,
                                           mvrr_gender,
                                           mvrr_category,
                                           mvrr_amount,
                                           mvrr_phone,
                                           mvrr_region,
                                           mvrr_ratu,
                                           mvrr_district,
                                           mvrr_pindex,
                                           mvrr_pindexname,
                                           mvrr_address,
                                           mvrr_iban,
                                           mvrr_st)
            SELECT NULL
                       mvrr_id,
                   p_me_id
                       mvrr_me,
                   mvrr_pc,
                   NULL
                       mvrr_ef,
                   a.mvrr_pd,
                      CASE WHEN e.me_tp = 'UNP'                    -- ООН Post
                                                THEN 'P' ELSE 'B' END  -- Bank
                   || 'ICC'
                   || TO_CHAR (l_start_dt, 'yymm')
                       mvrr_icc_registry,
                   a.mvrr_id_fam,
                   SUBSTR (REPLACE (UPPER (ci.sco_ln), '1', 'І'), 1, 50)
                       mvrr_surname,
                   SUBSTR (REPLACE (UPPER (ci.sco_fn), '1', 'І'), 1, 50)
                       mvrr_name,
                   SUBSTR (REPLACE (UPPER (ci.sco_mn), '1', 'І'), 1, 50)
                       mvrr_patronymic,
                   TO_CHAR (ci.sco_birth_dt, 'YYYY-MM-DD')
                       mvrr_bdate,
                   NVL (ci.sco_numident, '00000000000')
                       mvrr_n_id,
                   ci.sco_pasp_seria || ci.sco_pasp_number
                       mvrr_passport,
                   DECODE (UPPER (ci.sco_gender),
                           UPPER ('Чоловіча'), 1,
                           UPPER ('Жіноча'), 2)
                       mvrr_gender,
                   a.mvrr_category,
                   a.mvrr_amount,
                   a.mvrr_phone,
                   NVL (
                       (  SELECT NVL (sca_region, ko.kaot_name)
                            FROM uss_person.v_sc_address sca
                                 LEFT JOIN uss_ndi.v_ndi_katottg k
                                     ON k.kaot_id = sca_kaot
                                 LEFT JOIN uss_ndi.v_ndi_katottg ko
                                     ON ko.kaot_id = k.kaot_kaot_l1
                           WHERE     sca_sc = cc.scc_sc
                                 AND sca.history_status = 'A'
                                 AND sca_tp = '2'
                        ORDER BY sca_id DESC
                           FETCH FIRST ROW ONLY),
                       (SELECT MAX (obl.kaot_name)
                          FROM uss_ndi.v_ndi_org2kaot  z,
                               uss_ndi.v_ndi_katottg   osz,
                               uss_ndi.v_ndi_katottg   obl
                         WHERE     osz.kaot_kaot_l1 = obl.kaot_id
                               AND nok_kaot = osz.kaot_id
                               AND nok_org = pa_org))
                       mvrr_region,
                   NVL (
                       (  SELECT rn.kaot_code
                            FROM uss_person.v_sc_address sca,
                                 uss_ndi.v_ndi_katottg  rn
                           WHERE     sca_sc = cc.scc_sc
                                 AND sca.sca_kaot = rn.kaot_id
                                 AND sca.history_status = 'A'
                                 AND sca_tp = '2'
                        ORDER BY sca_id DESC
                           FETCH FIRST ROW ONLY),
                       (SELECT MAX (rn.kaot_code)
                          FROM uss_ndi.v_ndi_org2kaot  z,
                               uss_ndi.v_ndi_katottg   osz,
                               uss_ndi.v_ndi_katottg   rn
                         WHERE     osz.kaot_kaot_l2 = rn.kaot_id
                               AND nok_kaot = osz.kaot_id
                               AND nok_org = pa_org))
                       mvrr_ratu,
                   NVL (
                       (  SELECT NVL (sca_district, kr.kaot_name)
                            FROM uss_person.v_sc_address sca
                                 LEFT JOIN uss_ndi.v_ndi_katottg k
                                     ON k.kaot_id = sca_kaot
                                 LEFT JOIN uss_ndi.v_ndi_katottg kr
                                     ON kr.kaot_id = k.kaot_kaot_l2
                           WHERE     sca_sc = cc.scc_sc
                                 AND sca.history_status = 'A'
                                 AND sca_tp = '2'
                        ORDER BY sca_id DESC
                           FETCH FIRST ROW ONLY),
                       (SELECT MAX (rn.kaot_name)
                          FROM uss_ndi.v_ndi_org2kaot  z,
                               uss_ndi.v_ndi_katottg   osz,
                               uss_ndi.v_ndi_katottg   rn
                         WHERE     osz.kaot_kaot_l2 = rn.kaot_id
                               AND nok_kaot = osz.kaot_id
                               AND nok_org = pa_org))
                       mvrr_district,
                   NVL (
                       (  SELECT sca_postcode
                            FROM uss_person.v_sc_address sca
                           WHERE     sca_sc = cc.scc_sc
                                 AND sca.history_status = 'A'
                                 AND sca_tp = '2'
                        ORDER BY sca_id DESC
                           FETCH FIRST ROW ONLY),
                       get_doc_string (NULL,
                                       pd_ap,
                                       600,
                                       599))
                       mvrr_pindex,
                   NVL (
                       (  SELECT sca_city
                            FROM uss_person.v_sc_address sca
                           WHERE     sca_sc = cc.scc_sc
                                 AND sca.history_status = 'A'
                                 AND sca_tp = '2'
                        ORDER BY sca_id DESC
                           FETCH FIRST ROW ONLY),
                       (SELECT MAX (kaot_name)
                          FROM uss_ndi.v_ndi_katottg
                         WHERE kaot_id =
                               (SELECT MAX (Apda_Val_Id)
                                  FROM uss_esr.Ap_Person,
                                       uss_esr.Ap_Document,
                                       uss_esr.Ap_Document_Attr
                                 WHERE     Ap_Person.History_Status = 'A'
                                       AND Ap_Document.History_Status = 'A'
                                       AND Apd_App = App_Id
                                       AND Apda_Apd = Apd_Id
                                       AND App_Tp = 'Z'
                                       AND App_Ap = pd_ap
                                       AND Apd_Ndt = 600
                                       AND Apda_Nda = 604)))
                       mvrr_pindexname,
                   (  SELECT    sca_street
                             || ';'
                             || sca_building
                             || ';'
                             || CASE
                                    WHEN sca_block IS NOT NULL
                                    THEN
                                        ' корп. ' || sca_block
                                END
                             || ';'
                             || NVL2 (sca_apartment,
                                      'кв.' || sca_apartment,
                                      '')
                        FROM uss_person.v_sc_address sca
                       WHERE     sca_sc = cc.scc_sc
                             AND sca.history_status = 'A'
                             AND sca_tp = '2'
                    ORDER BY sca_id DESC
                       FETCH FIRST ROW ONLY)
                       mvrr_address,
                   pm.pdm_account
                       mvrr_iban,
                   c_st_ME_Exists
                       mvrr_st
              FROM uss_esr.mass_exchanges  e
                   INNER JOIN uss_esr.me_vppun_request_rows a
                       ON a.mvrr_me = e.me_id
                   INNER JOIN uss_esr.me_vppun_result_rows r
                       ON r.mvsr_mvrr = a.mvrr_id AND r.mvsr_st = 'P'
                   INNER JOIN uss_esr.pc_decision d
                       ON d.pd_id = r.mvsr_pd_pay
                   INNER JOIN uss_esr.pd_pay_method pm
                       ON     pm.pdm_pd = d.pd_id
                          AND pm.history_status = 'A'
                          AND pm.pdm_is_actual = 'T'
                   INNER JOIN uss_esr.pc_account ac ON ac.pa_id = d.pd_pa
                   INNER JOIN uss_person.v_sc_change cc
                       ON cc.scc_id = pm.pdm_scc
                   INNER JOIN uss_person.v_sc_info ci
                       ON ci.sco_id = cc.scc_sc
             WHERE     e.me_id = l_me_r
                   AND uss_person.API$SC_TOOLS.get_death_dt (cc.scc_sc)
                           IS NULL -- Додати перевірку по SC_Death - чи жива ще людина
                                  ;

        l_cnt := SQL%ROWCOUNT;

        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (
                'prepare_me_rows_unr INSERTED: ' || l_cnt);
        END IF;

        UPDATE mass_exchanges m
           SET m.me_count = l_cnt, m.me_st = c_st_ME_Exists
         WHERE me_id = p_me_id;

        write_me_log (p_mel_me        => p_me_id,
                      --p_mel_hs      => l_hs,
                      p_mel_st        => c_st_ME_Exists,
                      p_mel_message   => 'Завершено формування пакету',
                      p_mel_st_old    => c_st_ME_Creating);
    END prepare_me_rows_unr;

    -- IC #111818 Повторне вивантаження по невиплаченим сумам
    PROCEDURE prepare_me_rows_unrr (p_me_id mass_exchanges.me_id%TYPE)
    IS
        l_start_dt   DATE;
        l_me_tp      mass_exchanges.me_tp%TYPE;
        l_cnt        NUMBER;
    BEGIN
        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (
                'START prepare_me_rows_unr');
        END IF;

        SELECT m.me_month, m.me_tp
          INTO l_start_dt, l_me_tp
          FROM uss_esr.mass_exchanges m
         WHERE m.me_id = p_me_id;

        INSERT INTO me_vppun_request_rows (mvrr_id,
                                           mvrr_me,
                                           mvrr_pc,
                                           mvrr_ef,
                                           mvrr_pd,
                                           mvrr_icc_registry,
                                           mvrr_id_fam,
                                           mvrr_surname,
                                           mvrr_name,
                                           mvrr_patronymic,
                                           mvrr_bdate,
                                           mvrr_n_id,
                                           mvrr_passport,
                                           mvrr_gender,
                                           mvrr_category,
                                           mvrr_amount,
                                           mvrr_phone,
                                           mvrr_region,
                                           mvrr_ratu,
                                           mvrr_district,
                                           mvrr_pindex,
                                           mvrr_pindexname,
                                           mvrr_address,
                                           mvrr_iban,
                                           mvrr_st)
            SELECT NULL
                       mvrr_id,
                   p_me_id
                       mvrr_me,
                   mvrr_pc,
                   NULL
                       mvrr_ef,
                   a.mvrr_pd,
                      CASE WHEN e.me_tp = 'UNP'                    -- ООН Post
                                                THEN 'P' ELSE 'B' END  -- Bank
                   || 'ICC'
                   || TO_CHAR (l_start_dt, 'yymm')
                       mvrr_icc_registry,
                   a.mvrr_id_fam,
                   SUBSTR (REPLACE (UPPER (ci.sco_ln), '1', 'І'), 1, 50)
                       mvrr_surname,
                   SUBSTR (REPLACE (UPPER (ci.sco_fn), '1', 'І'), 1, 50)
                       mvrr_name,
                   SUBSTR (REPLACE (UPPER (ci.sco_mn), '1', 'І'), 1, 50)
                       mvrr_patronymic,
                   TO_CHAR (ci.sco_birth_dt, 'YYYY-MM-DD')
                       mvrr_bdate,
                   NVL (ci.sco_numident, '00000000000')
                       mvrr_n_id,
                   ci.sco_pasp_seria || ci.sco_pasp_number
                       mvrr_passport,
                   DECODE (UPPER (ci.sco_gender),
                           UPPER ('Чоловіча'), 1,
                           UPPER ('Жіноча'), 2)
                       mvrr_gender,
                   a.mvrr_category,
                   a.mvrr_amount,
                   a.mvrr_phone,
                   NVL (
                       (  SELECT NVL (sca_region, ko.kaot_name)
                            FROM uss_person.v_sc_address sca
                                 LEFT JOIN uss_ndi.v_ndi_katottg k
                                     ON k.kaot_id = sca_kaot
                                 LEFT JOIN uss_ndi.v_ndi_katottg ko
                                     ON ko.kaot_id = k.kaot_kaot_l1
                           WHERE     sca_sc = cc.scc_sc
                                 AND sca.history_status = 'A'
                                 AND sca_tp = '2'
                        ORDER BY sca_id DESC
                           FETCH FIRST ROW ONLY),
                       (SELECT MAX (obl.kaot_name)
                          FROM uss_ndi.v_ndi_org2kaot  z,
                               uss_ndi.v_ndi_katottg   osz,
                               uss_ndi.v_ndi_katottg   obl
                         WHERE     osz.kaot_kaot_l1 = obl.kaot_id
                               AND nok_kaot = osz.kaot_id
                               AND nok_org = pa_org))
                       mvrr_region,
                   NVL (
                       (  SELECT rn.kaot_code
                            FROM uss_person.v_sc_address sca,
                                 uss_ndi.v_ndi_katottg  rn
                           WHERE     sca_sc = cc.scc_sc
                                 AND sca.sca_kaot = rn.kaot_id
                                 AND sca.history_status = 'A'
                                 AND sca_tp = '2'
                        ORDER BY sca_id DESC
                           FETCH FIRST ROW ONLY),
                       (SELECT MAX (rn.kaot_code)
                          FROM uss_ndi.v_ndi_org2kaot  z,
                               uss_ndi.v_ndi_katottg   osz,
                               uss_ndi.v_ndi_katottg   rn
                         WHERE     osz.kaot_kaot_l2 = rn.kaot_id
                               AND nok_kaot = osz.kaot_id
                               AND nok_org = pa_org))
                       mvrr_ratu,
                   NVL (
                       (  SELECT NVL (sca_district, kr.kaot_name)
                            FROM uss_person.v_sc_address sca
                                 LEFT JOIN uss_ndi.v_ndi_katottg k
                                     ON k.kaot_id = sca_kaot
                                 LEFT JOIN uss_ndi.v_ndi_katottg kr
                                     ON kr.kaot_id = k.kaot_kaot_l2
                           WHERE     sca_sc = cc.scc_sc
                                 AND sca.history_status = 'A'
                                 AND sca_tp = '2'
                        ORDER BY sca_id DESC
                           FETCH FIRST ROW ONLY),
                       (SELECT MAX (rn.kaot_name)
                          FROM uss_ndi.v_ndi_org2kaot  z,
                               uss_ndi.v_ndi_katottg   osz,
                               uss_ndi.v_ndi_katottg   rn
                         WHERE     osz.kaot_kaot_l2 = rn.kaot_id
                               AND nok_kaot = osz.kaot_id
                               AND nok_org = pa_org))
                       mvrr_district,
                   NVL (
                       (  SELECT sca_postcode
                            FROM uss_person.v_sc_address sca
                           WHERE     sca_sc = cc.scc_sc
                                 AND sca.history_status = 'A'
                                 AND sca_tp = '2'
                        ORDER BY sca_id DESC
                           FETCH FIRST ROW ONLY),
                       get_doc_string (NULL,
                                       pd_ap,
                                       600,
                                       599))
                       mvrr_pindex,
                   NVL (
                       (  SELECT sca_city
                            FROM uss_person.v_sc_address sca
                           WHERE     sca_sc = cc.scc_sc
                                 AND sca.history_status = 'A'
                                 AND sca_tp = '2'
                        ORDER BY sca_id DESC
                           FETCH FIRST ROW ONLY),
                       (SELECT MAX (kaot_name)
                          FROM uss_ndi.v_ndi_katottg
                         WHERE kaot_id =
                               (SELECT MAX (Apda_Val_Id)
                                  FROM uss_esr.Ap_Person,
                                       uss_esr.Ap_Document,
                                       uss_esr.Ap_Document_Attr
                                 WHERE     Ap_Person.History_Status = 'A'
                                       AND Ap_Document.History_Status = 'A'
                                       AND Apd_App = App_Id
                                       AND Apda_Apd = Apd_Id
                                       AND App_Tp = 'Z'
                                       AND App_Ap = pd_ap
                                       AND Apd_Ndt = 600
                                       AND Apda_Nda = 604)))
                       mvrr_pindexname,
                   (  SELECT    sca_street
                             || ';'
                             || sca_building
                             || ';'
                             || CASE
                                    WHEN sca_block IS NOT NULL
                                    THEN
                                        ' корп. ' || sca_block
                                END
                             || ';'
                             || NVL2 (sca_apartment,
                                      'кв.' || sca_apartment,
                                      '')
                        FROM uss_person.v_sc_address sca
                       WHERE     sca_sc = cc.scc_sc
                             AND sca.history_status = 'A'
                             AND sca_tp = '2'
                    ORDER BY sca_id DESC
                       FETCH FIRST ROW ONLY)
                       mvrr_address,
                   pm.pdm_account
                       mvrr_iban,
                   c_st_ME_Exists
                       mvrr_st
              FROM uss_esr.mass_exchanges  e
                   INNER JOIN uss_esr.me_vppun_request_rows a
                       ON a.mvrr_me = e.me_id
                   LEFT JOIN uss_esr.me_vppun_result_rows r
                       ON r.mvsr_mvrr = a.mvrr_id AND r.mvsr_st = 'P'
                   INNER JOIN uss_esr.pc_decision d
                       ON    d.pd_id = r.mvsr_pd_pay
                          OR (    d.pd_pc = a.mvrr_pc
                              AND d.pd_nst = 1101 -- Допомога людям з інвалідністю від ВПП ООН до 3250 грн
                              AND r.mvsr_pd_pay IS NULL)
                   INNER JOIN uss_esr.pd_pay_method pm
                       ON     pm.pdm_pd = d.pd_id
                          AND pm.history_status = 'A'
                          AND pm.pdm_is_actual = 'T'
                   INNER JOIN uss_esr.pc_account ac ON ac.pa_id = d.pd_pa
                   INNER JOIN uss_person.v_sc_change cc
                       ON cc.scc_id = pm.pdm_scc
                   INNER JOIN uss_person.v_sc_info ci
                       ON ci.sco_id = cc.scc_sc
             WHERE     e.me_st != 'D'
                   AND e.me_tp IN ('UN', 'UNP')
                   AND e.me_month = l_start_dt
                   AND pm.pdm_pay_tp =
                       CASE l_me_tp
                           WHEN 'UN_RR' THEN 'BANK'
                           WHEN 'UNP_RR' THEN 'POST'
                       END
                   AND (   EXISTS
                               (SELECT 1                   -- відсутня виплата
                                  FROM uss_esr.ac_detail dd
                                 WHERE     dd.acd_pd = d.pd_id
                                       AND dd.acd_npt = 853 -- Виплата людям з інвалідністю від ВПП ООН до 3250 грн
                                       AND e.me_month BETWEEN TRUNC (
                                                                  dd.acd_start_dt,
                                                                  'mm')
                                                          AND dd.acd_stop_dt
                                       AND dd.history_status = 'A'
                                       AND dd.acd_prsd IS NULL)
                        OR r.mvsr_st = 'P');

        l_cnt := SQL%ROWCOUNT;

        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (
                'prepare_me_rows_unr INSERTED: ' || l_cnt);
        END IF;

        UPDATE mass_exchanges m
           SET m.me_count = l_cnt, m.me_st = c_st_ME_Exists
         WHERE me_id = p_me_id;

        write_me_log (p_mel_me        => p_me_id,
                      --p_mel_hs      => l_hs,
                      p_mel_st        => c_st_ME_Exists,
                      p_mel_message   => 'Завершено формування пакету',
                      p_mel_st_old    => c_st_ME_Creating);
    EXCEPTION
        WHEN OTHERS
        THEN
            TOOLS.JobSaveMessage (
                   'Помилка виконання prepare_me_rows_unrr:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END prepare_me_rows_unrr;

    -- IC #112423 Зробити вивантаження для ВПП ООН, в якому ми візьмемо всіх людей по територіям, яких не взяли по умовам вивантаження
    -- окреме довивантаження з типом "Вивантаження ВПП ООН (309 з додатками)"
    PROCEDURE prepare_me_rows_un306 (p_me_id mass_exchanges.me_id%TYPE)
    IS
        l_start_dt   DATE;
        l_me_tp      mass_exchanges.me_tp%TYPE;
        l_cnt        NUMBER;
    BEGIN
        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (
                'START prepare_me_rows_un306');
        END IF;

        SELECT m.me_month,
               CASE WHEN m.me_tp LIKE 'UNP%' THEN 'POST' ELSE 'BANK' END
          INTO l_start_dt, l_me_tp
          FROM uss_esr.mass_exchanges m
         WHERE m.me_id = p_me_id;

        INSERT INTO me_vppun_request_rows (mvrr_id,
                                           mvrr_me,
                                           mvrr_pc,
                                           mvrr_ef,
                                           mvrr_pd,
                                           mvrr_icc_registry,
                                           mvrr_id_fam,
                                           mvrr_surname,
                                           mvrr_name,
                                           mvrr_patronymic,
                                           mvrr_bdate,
                                           mvrr_n_id,
                                           mvrr_passport,
                                           mvrr_gender,
                                           mvrr_category,
                                           mvrr_amount,
                                           mvrr_phone,
                                           mvrr_region,
                                           mvrr_ratu,
                                           mvrr_district,
                                           mvrr_pindex,
                                           mvrr_pindexname,
                                           mvrr_address,
                                           mvrr_iban,
                                           mvrr_st)
            SELECT NULL
                       mvrr_id,
                   p_me_id
                       mvrr_me,
                   pc_id,
                   NULL
                       mvrr_ef,
                   pd_id,
                   ICC_REGISTRY,
                   ID_FAM,
                   SURNAME,
                   NAME,
                   PATRONYMIC,
                   BDATE,
                   N_ID,
                   PASSPORT,
                   GENDER,
                   CATEGORY,
                   TRIM (TO_CHAR (AMOUNT, '99999990.00'))
                       AMOUNT,
                   CASE WHEN LENGTH (PHONE) != 10 THEN NULL ELSE PHONE END
                       PHONE,
                   REGION,
                   RATU,
                   DISTRICT,
                   PINDEX,
                   PINDEXNAME,
                   ADDRESS,
                   IBAN,
                   c_st_ME_Exists
                       mvrr_st
              FROM (SELECT pd_pc
                               pc_id,
                           pd_id,
                              CASE
                                  WHEN pdm_pay_tp = 'POST'         -- ООН Post
                                                           THEN 'P'
                                  ELSE 'B'
                              END                                      -- Bank
                           || 'ICC'
                           || TO_CHAR (l_start_dt, 'yymm')
                               AS icc_registry,
                              '1'
                           || LPAD ('' || NVL (pa_org, 0), 5, 0)
                           || LPAD ('' || pd_id, 20, '0')
                           || LPAD ('' || '0', 2, '0')
                               AS id_fam,
                           SUBSTR (REPLACE (UPPER (ci.sco_ln), '1', 'І'),
                                   1,
                                   50)
                               surname,
                           SUBSTR (REPLACE (UPPER (ci.sco_fn), '1', 'І'),
                                   1,
                                   50)
                               name,
                           SUBSTR (REPLACE (UPPER (ci.sco_mn), '1', 'І'),
                                   1,
                                   50)
                               patronymic,
                           TO_CHAR (sco_birth_dt, 'YYYY-MM-DD')
                               AS bdate,
                           NVL (sco_numident, '0000000000')
                               n_id,
                           sco_pasp_seria || sco_pasp_number
                               AS passport,
                           DECODE (sco_gender,  'Чоловіча', 1,  'Жіноча', 2)
                               AS gender,
                           '169'
                               AS category,
                           (SELECT SUM (pdp_sum)
                              FROM uss_esr.pd_payment pdp
                             WHERE     pdp.pdp_pd = pd_id
                                   AND pdp.history_status = 'A'
                                   AND l_start_dt BETWEEN TRUNC (
                                                              pdp.pdp_start_dt,
                                                              'mm')
                                                      AND pdp.pdp_stop_dt)
                               AS amount,
                           REGEXP_REPLACE (uss_esr.API$MASS_EXCHANGE.get_doc_string (
                                               NULL,
                                               pd_ap,
                                               600,
                                               605),
                                           '[^[:digit:]]',
                                           '')
                               AS phone,                       -- тільки цифри
                           (SELECT MAX (obl.kaot_name)
                              FROM uss_ndi.v_ndi_org2kaot  z,
                                   uss_ndi.v_ndi_katottg   osz,
                                   uss_ndi.v_ndi_katottg   obl
                             WHERE     osz.kaot_kaot_l1 = obl.kaot_id
                                   AND nok_kaot = osz.kaot_id
                                   AND nok_org = pa_org)
                               AS region,
                           (SELECT MAX (rn.kaot_code)
                              FROM uss_ndi.v_ndi_org2kaot  z,
                                   uss_ndi.v_ndi_katottg   osz,
                                   uss_ndi.v_ndi_katottg   rn
                             WHERE     osz.kaot_kaot_l2 = rn.kaot_id
                                   AND nok_kaot = osz.kaot_id
                                   AND nok_org = pa_org)
                               AS ratu,
                           (SELECT MAX (rn.kaot_name)
                              FROM uss_ndi.v_ndi_org2kaot  z,
                                   uss_ndi.v_ndi_katottg   osz,
                                   uss_ndi.v_ndi_katottg   rn
                             WHERE     osz.kaot_kaot_l2 = rn.kaot_id
                                   AND nok_kaot = osz.kaot_id
                                   AND nok_org = pa_org)
                               AS district,
                           NVL (
                               uss_esr.API$MASS_EXCHANGE.get_doc_string (
                                   NULL,
                                   pd_ap,
                                   600,
                                   599),
                               (SELECT MAX (sca_postcode)
                                  FROM uss_person.v_sc_address sca
                                 WHERE     sca_sc = pc_sc
                                       AND sca.history_status = 'A'
                                       AND sca_tp = '2'))
                               AS pindex,
                           NVL (
                               (SELECT MAX (kaot_name)
                                  FROM uss_ndi.v_ndi_katottg
                                 WHERE kaot_id =
                                       (SELECT MAX (Apda_Val_Id)
                                          FROM uss_esr.Ap_Person,
                                               uss_esr.Ap_Document,
                                               uss_esr.Ap_Document_Attr
                                         WHERE     Ap_Person.History_Status =
                                                   'A'
                                               AND Ap_Document.History_Status =
                                                   'A'
                                               AND Apd_App = App_Id
                                               AND Apda_Apd = Apd_Id
                                               AND App_Tp = 'Z'
                                               AND App_Ap = pd_ap
                                               AND Apd_Ndt = 600
                                               AND Apda_Nda = 604)),
                               (SELECT MAX (sca_city)
                                  FROM uss_person.v_sc_address sca
                                 WHERE     sca_sc = pc_sc
                                       AND sca.history_status = 'A'
                                       AND sca_tp = '2'))
                               AS pindexname,
                           NVL (
                               uss_esr.API$MASS_EXCHANGE.getAddrUN (d.pd_ap),
                               (SELECT MAX (
                                              sca_street
                                           || ';'
                                           || sca_building
                                           || ';'
                                           || CASE
                                                  WHEN sca_block IS NOT NULL
                                                  THEN
                                                      ' корп. ' || sca_block
                                              END
                                           || ';'
                                           || NVL2 (sca_apartment,
                                                    'кв.' || sca_apartment,
                                                    ''))
                                  FROM uss_person.v_sc_address sca
                                 WHERE     sca_sc = pc_sc
                                       AND sca.history_status = 'A'
                                       AND sca_tp = '2'))
                               AS address,
                           pdm_account
                               AS iban,
                           pdm_pay_tp
                      FROM uss_esr.pc_decision  d
                           INNER JOIN uss_esr.personalcase c
                               ON c.pc_id = d.pd_pc
                           INNER JOIN uss_esr.pd_pay_method pm
                               ON     pm.pdm_pd = d.pd_id
                                  AND pm.history_status = 'A'
                                  AND pm.pdm_is_actual = 'T'
                                  AND pm.pdm_pay_tp = l_me_tp
                           INNER JOIN uss_esr.pc_account ac
                               ON ac.pa_id = d.pd_pa
                           INNER JOIN uss_person.v_sc_change cc
                               ON cc.scc_id = pm.pdm_scc
                           INNER JOIN uss_person.v_sc_info ci
                               ON ci.sco_id = cc.scc_sc
                           INNER JOIN uss_esr.opfu o ON o.org_id = ac.pa_org
                     WHERE     d.pd_nst = 248
                           AND o.org_org IN (50900,
                                             51200,
                                             51400,
                                             52300,
                                             54800,
                                             55900,
                                             56300,
                                             56500,
                                             57400) -- IC #108764 брати лише рішення, які належать областям...
                           AND (   d.pd_st = 'S'
                                OR (    d.pd_st = 'PS'
                                    AND EXISTS
                                            (SELECT 1 -- IC #108764 Рішення, призупинені постійною причиною - не включати
                                               FROM uss_esr.pc_block  pcb,
                                                    uss_ndi.v_ndi_reason_not_pay
                                                    r
                                              WHERE     pcb.pcb_id = d.pd_pcb
                                                    AND r.rnp_id =
                                                        pcb.pcb_rnp
                                                    AND r.rnp_pnp_tp = 'CPY'
                                                    AND r.history_status =
                                                        'A')))
                           AND EXISTS
                                   (SELECT 1
                                      FROM uss_esr.pd_accrual_period ap
                                     WHERE     ap.pdap_pd = d.pd_id
                                           AND l_start_dt BETWEEN TRUNC (
                                                                      ap.pdap_start_dt,
                                                                      'mm')
                                                              AND ap.pdap_stop_dt
                                           AND ap.history_status = 'A')
                           AND NOT EXISTS
                                   (SELECT 1      -- НЕ отримують допомогу ВПО
                                      FROM uss_esr.pc_decision        d1,
                                           uss_esr.pd_family          f,
                                           uss_esr.pd_accrual_period  pdap
                                     WHERE     f.pdf_sc = cc.scc_sc
                                           AND f.pdf_pd = d1.pd_id
                                           AND pdap_pd = d1.pd_id
                                           AND d1.pd_nst = 664
                                           AND pdap.history_status = 'A'
                                           AND l_start_dt BETWEEN TRUNC (
                                                                      pdap_start_dt,
                                                                      'mm')
                                                              AND pdap_stop_dt)
                           -- IC #113177
                           AND NOT EXISTS
                                   (SELECT 1 -- КАТОТТГ місця проживання - у зоні активних або можливих бойових дій або у зоні тимчасової окупації без дати закінчення
                                      FROM uss_ndi.v_ndi_index_aspod_config,
                                           (SELECT apda_val_string    x_index
                                              FROM uss_esr.ap_person    p,
                                                   uss_esr.ap_document_attr a,
                                                   uss_esr.ap_document  dd
                                             WHERE     p.app_ap = d.pd_ap
                                                   AND p.app_sc = cc.scc_sc
                                                   AND a.apda_ap = d.pd_ap
                                                   AND dd.apd_app = p.app_id
                                                   AND a.apda_apd = dd.apd_Id
                                                   AND dd.apd_ndt = 600
                                                   AND a.apda_nda = 599
                                                   --and p.app_tp in ('O', 'Z')
                                                   AND p.history_status = 'A'
                                                   AND dd.history_status =
                                                       'A'
                                                   AND a.history_status = 'A') --Індекс адреси проживання з звернення
                                     WHERE     x_index IN
                                                   (niac_post_index,
                                                    niac_vipl_index) --Індекси з довідника АСОПД <-> КАТОТТГ
                                           AND EXISTS
                                                   (SELECT 1
                                                      FROM uss_ndi.v_ndi_kaot_state
                                                           kaots,
                                                           uss_ndi.v_ndi_normative_act
                                                           nna
                                                     WHERE     kaots_kaot =
                                                               niac_kaot
                                                           AND kaots.history_status =
                                                               'A'
                                                           AND kaots_nna =
                                                               nna_id
                                                           AND (   nna_num =
                                                                   '309' --По 309 поставнові
                                                                -- IC #112654
                                                                OR nna_nna_main =
                                                                   (SELECT aa.nna_id
                                                                      FROM uss_ndi.v_ndi_normative_act
                                                                           aa
                                                                     WHERE aa.nna_num =
                                                                           '309')--or  nna_id >= (select aa.nna_id from uss_ndi.v_ndi_normative_act aa where aa.nna_num = '309')
                                                                                 )
                                                           AND nna.history_status =
                                                               'A'
                                                           -- IC #113584
                                                           AND kaots_tp IN
                                                                   ('BD',
                                                                    'PMO',
                                                                    'TO') -- Типи показників адм.одиниці    V_DDN_KAOTS_TP
                                                           AND kaots_stop_dt
                                                                   IS NULL))
                           AND uss_person.API$SC_TOOLS.get_death_dt (
                                   cc.scc_sc)
                                   IS NULL -- Додати перевірку по SC_Death - чи жива ще людина
                           AND NOT EXISTS
                                   (SELECT 1
                                      FROM uss_esr.mass_exchanges         me,
                                           uss_esr.me_vppun_request_rows  rr
                                     WHERE     rr.mvrr_pc = c.pc_id
                                           AND me.me_id = rr.mvrr_me
                                           AND me.me_tp LIKE ('UN%')
                                           AND me.me_st != 'D'
                                           AND me.me_month = l_start_dt)
                           AND pd_stop_dt > l_start_dt)
             WHERE     amount > 0
                   AND amount < 3250
                   AND TRIM (ICC_REGISTRY) IS NOT NULL
                   AND TRIM (ID_FAM) IS NOT NULL
                   AND TRIM (SURNAME) IS NOT NULL
                   AND TRIM (NAME) IS NOT NULL
                   AND TRIM (N_ID) IS NOT NULL
                   AND TRIM (PASSPORT) IS NOT NULL
                   AND TRIM (CATEGORY) IS NOT NULL
                   AND TRIM (AMOUNT) IS NOT NULL
                   AND TRIM (REGION) IS NOT NULL
                   AND TRIM (RATU) IS NOT NULL
                   AND TRIM (DISTRICT) IS NOT NULL
                   -- для Банк: якщо в параметрах виплати довжина рахунку меньше 29 символів, то не вивантажувати (їм буде зміна виплати на пошту)
                   AND (LENGTH (IBAN) = 29 OR l_me_tp = 'POST');

        l_cnt := SQL%ROWCOUNT;

        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (
                'prepare_me_rows_un306 INSERTED: ' || l_cnt);
        END IF;

        UPDATE mass_exchanges m
           SET m.me_count = l_cnt, m.me_st = c_st_ME_Exists
         WHERE me_id = p_me_id;

        write_me_log (p_mel_me        => p_me_id,
                      --p_mel_hs      => l_hs,
                      p_mel_st        => c_st_ME_Exists,
                      p_mel_message   => 'Завершено формування пакету',
                      p_mel_st_old    => c_st_ME_Creating);
    EXCEPTION
        WHEN OTHERS
        THEN
            TOOLS.JobSaveMessage (
                   'Помилка виконання prepare_me_rows_un306:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END prepare_me_rows_un306;

    -- IC #109475 Формування рядків вивантаження по ЄСВ на редагування
    PROCEDURE prepare_me_rows_esv (p_me_id IN mass_exchanges.me_id%TYPE)
    IS
        l_rep_date   DATE;
        l_cnt        NUMBER;
        l_org        NUMBER;
        l_org_to     NUMBER;
    BEGIN
        SELECT a.com_org, TRUNC (a.me_month, 'mm')
          INTO l_org, l_rep_date
          FROM uss_esr.mass_exchanges a
         WHERE a.me_id = p_me_id;

        l_org := CASE WHEN l_org = 50001 THEN 50000 ELSE l_org END;

        SELECT CASE WHEN org_to = 34 THEN 34 ELSE 32 END
          INTO l_org_to
          FROM ikis_sys.v_opfu
         WHERE org_id = l_org;

        INSERT INTO uss_esr.me_esv_unload_rows (meur_id,
                                                meur_me,
                                                meur_pc,
                                                meur_period_m,
                                                meur_period_y,
                                                meur_ukr_gromad,
                                                meur_numident,
                                                meur_ln,
                                                meur_nm,
                                                meur_ftn,
                                                meur_zo,
                                                meur_start_dt,
                                                meur_stop_dt,
                                                meur_pay_tp,
                                                meur_pay_mnth,
                                                meur_pay_year,
                                                meur_sum_total,
                                                meur_sum_max,
                                                meur_sum_ins,
                                                meur_ozn,
                                                meur_st)
            WITH
                dat
                AS
                    (SELECT m.nm_month,
                            m.nm_start_dt,
                            m.nm_stop_dt,
                            m.nm_days
                       FROM uss_ndi.v_ndi_months m
                      WHERE l_rep_date BETWEEN m.nm_start_dt AND m.nm_stop_dt),
                org
                AS
                    (    SELECT org_id
                           FROM ikis_sys.v_opfu
                          WHERE l_org_to = 32
                     CONNECT BY PRIOR org_id = org_org
                     START WITH org_id = l_org
                     UNION ALL
                     SELECT org_id
                       FROM ikis_sys.v_opfu
                      WHERE l_org_to = 34 AND org_acc_org = l_org),
                pdap
                AS
                    (SELECT dat.nm_month,
                            d.pd_id,
                            MIN (ap.pdap_start_dt)
                                OVER (PARTITION BY d.pd_id)
                                pdap_start_dt,
                            MAX (ap.pdap_stop_dt) OVER (PARTITION BY d.pd_id)
                                pdap_stop_dt,
                            CASE
                                WHEN     TRUNC (d.pd_dt, 'mm') = dat.nm_month
                                     AND TRUNC (ap.pdap_start_dt, 'mm') <
                                         TRUNC (d.pd_dt, 'mm')
                                THEN
                                    1
                                ELSE
                                    0
                            END
                                is_before,
                            CASE
                                WHEN TRUNC (d.pd_dt, 'mm') > dat.nm_month
                                THEN
                                    1
                                ELSE
                                    0
                            END
                                is_after,
                            ROW_NUMBER ()
                                OVER (
                                    PARTITION BY d.pd_pc, d.pd_nst
                                    ORDER BY d.pd_start_dt DESC, d.pd_id DESC)
                                rn
                       FROM uss_esr.pd_accrual_period  ap,
                            uss_esr.pc_decision        d,
                            dat
                      WHERE     d.pd_id = ap.pdap_pd
                            AND ap.history_status = 'A'
                            AND dat.nm_month BETWEEN TRUNC (ap.pdap_start_dt,
                                                            'mm')
                                                 AND ap.pdap_stop_dt
                            AND EXISTS
                                    (SELECT 1                    -- IC #106203
                                       FROM uss_esr.pc_account pa, org
                                      WHERE     pa.pa_id = d.pd_pa
                                            AND pa.pa_org = org.org_id)
                            -- не потрібно включати в звіт ЄСВ, якщо інвалід по даті народження старше ніж 18 років
                            AND (   EXISTS
                                        (SELECT 1                -- IC #106203
                                           FROM uss_esr.pd_family  f
                                                JOIN uss_esr.ap_person pp1
                                                    ON     pp1.app_ap =
                                                           d.pd_ap
                                                       AND pp1.app_sc =
                                                           f.pdf_sc
                                                       AND pp1.app_tp NOT IN
                                                               ('Z', 'P')
                                                JOIN uss_esr.ap_document ad
                                                    ON     ad.apd_ap =
                                                           pp1.app_ap
                                                       AND ad.apd_app =
                                                           pp1.app_id
                                                       AND ad.apd_ndt IN
                                                               (200, 201) -- Документ про інвалідність
                                          WHERE     f.pdf_pd = d.pd_id
                                                AND f.pdf_birth_dt >
                                                    ADD_MONTHS (dat.nm_month,
                                                                (-12 * 18)) -- не виповнилось 18 років
                                                                           )
                                 OR d.pd_nst != 248)),
                nrh
                AS
                    (SELECT c.pc_id,
                            c.pc_sc,
                            pp.pdp_npt
                                d_npt_id,
                            m.nm_month
                                ac_month,
                            GREATEST (pp.pdp_start_dt, m.nm_start_dt)
                                acd_start_dt,
                            LEAST (pp.pdp_stop_dt, m.nm_stop_dt)
                                acd_stop_dt,
                              LEAST (pp.pdp_stop_dt, m.nm_stop_dt)
                            - GREATEST (pp.pdp_start_dt, m.nm_start_dt)
                            + 1
                                cnt_dt,
                            m.nm_days
                                cnt_dt_month,
                            p.pdap_start_dt,
                            p.pdap_stop_dt,
                            p.pdap_stop_dt - p.pdap_start_dt + 1
                                cnt_dt_pdap,
                            CASE
                                -- IC #103937 Для npt_id = 37 - Розрахунок від МЗП пропорційно дням призначення
                                WHEN pt.npt_id = 37
                                THEN
                                    ROUND (
                                          dnet$payment_long_rep.get_mzp (
                                              GREATEST (pp.pdp_start_dt,
                                                        m.nm_start_dt))
                                        / m.nm_days
                                        * (  LEAST (pp.pdp_stop_dt,
                                                    m.nm_stop_dt)
                                           - GREATEST (pp.pdp_start_dt,
                                                       m.nm_start_dt)
                                           + 1),
                                        2)
                                -- Для npt_id IN (1, 219) - опікун особи/дитини з інвалідністю + НЕ ПРАЦЮЄ - ЄСВ нараховується з суми МЗП пропорційно дням призначення
                                WHEN     pt.npt_id IN (1, 219)
                                     AND NVL (dnet$payment_long_rep.get_doc_string (
                                                  NULL,
                                                  d.pd_ap,
                                                  605,
                                                  650),
                                              'F') = 'F'
                                     AND EXISTS
                                             (SELECT 1
                                                FROM uss_esr.pc_decision  d1
                                                     JOIN uss_esr.pd_family f
                                                         ON f.pdf_pd =
                                                            d1.pd_id
                                                     JOIN
                                                     uss_esr.ap_person pp1
                                                         ON     pp1.app_ap =
                                                                d.pd_ap
                                                            AND pp1.app_sc =
                                                                f.pdf_sc
                                                     JOIN
                                                     uss_esr.ap_document ad
                                                         ON     ad.apd_ap =
                                                                pp1.app_ap
                                                            AND ad.apd_app =
                                                                pp1.app_id
                                                     JOIN
                                                     uss_esr.ap_document_attr
                                                     da
                                                         ON     da.apda_apd =
                                                                ad.apd_id
                                                            AND da.apda_nda IN
                                                                    (797) -- категорія
                                                            AND da.history_status =
                                                                'A'
                                                            AND da.apda_val_string IN
                                                                    ('DI',
                                                                     'DIA') -- Дитина з інвалідністю, дитина з інвалідністю підгрупи А
                                               WHERE     d1.pd_ap = d.pd_ap
                                                     AND f.pdf_birth_dt >
                                                         ADD_MONTHS (
                                                             p.nm_month,
                                                             (-12 * 18))) -- не виповнилось 18 років
                                THEN
                                    ROUND (
                                          dnet$payment_long_rep.get_mzp (
                                              GREATEST (pp.pdp_start_dt,
                                                        m.nm_start_dt))
                                        / m.nm_days
                                        * (  LEAST (pp.pdp_stop_dt,
                                                    m.nm_stop_dt)
                                           - GREATEST (pp.pdp_start_dt,
                                                       m.nm_start_dt)
                                           + 1),
                                        2)
                                -- 20 - усиновлення (NPT_ID = 40), перевіряти вік дітей по рішенню
                                WHEN     pt.npt_id = 40
                                     -- Якщо у місяці звіту самій молодшій дитині виконується 3 роки
                                     AND m.nm_start_dt =
                                         (SELECT ADD_MONTHS (
                                                     MAX (
                                                         TRUNC (
                                                             f.pdf_birth_dt,
                                                             'mm')),
                                                     36)
                                            FROM pd_family f
                                           WHERE     f.pdf_pd = d.pd_id
                                                 AND NVL (f.history_status,
                                                          'A') =
                                                     'A')
                                -- то сума в колонку SUM_TOTAL та SUM_MAX розраховується пропорційно дням (кількість днів до дати народження)
                                THEN
                                    ROUND (
                                          pp.pdp_sum
                                        / m.nm_days
                                        * (SELECT   MAX (f.pdf_birth_dt)
                                                  - MAX (
                                                        TRUNC (
                                                            f.pdf_birth_dt,
                                                            'mm'))
                                             FROM pd_family f
                                            WHERE     f.pdf_pd = d.pd_id
                                                  AND NVL (f.history_status,
                                                           'A') =
                                                      'A'),
                                        2)
                                WHEN COUNT (*)
                                         OVER (
                                             PARTITION BY d.pd_id,
                                                          d.pd_nst,
                                                          m.nm_month) >
                                     1
                                THEN
                                    ROUND (
                                          pp.pdp_sum
                                        / m.nm_days
                                        * (  LEAST (pp.pdp_stop_dt,
                                                    m.nm_stop_dt)
                                           - GREATEST (pp.pdp_start_dt,
                                                       m.nm_start_dt)
                                           + 1),
                                        2)
                                ELSE
                                    pp.pdp_sum
                            END
                                acd_sum,
                            CASE
                                WHEN pt.npt_id = 37 THEN 70 -- 70 - по допомозі по догляду за дитиною
                                WHEN pt.npt_id IN (1, 219) THEN 21 -- 21 - по догляду за дітьми-інвалідами
                                WHEN pt.npt_id = 40 THEN 20 -- 20 - усиновлення
                                WHEN pt.npt_id IN (835, 836, 839) THEN 24 -- 24 - Грошове забезпечення патронатного вихователя
                                ELSE 0
                            END
                                npt_id,
                            CASE
                                WHEN EXISTS
                                         (SELECT 1
                                            FROM uss_esr.pc_decision  d1
                                                 JOIN uss_esr.pd_family f
                                                     ON f.pdf_pd = d1.pd_id
                                                 JOIN uss_esr.ap_person pp1
                                                     ON     pp1.app_ap =
                                                            d.pd_ap
                                                        AND pp1.app_sc =
                                                            f.pdf_sc
                                                 JOIN uss_esr.ap_document ad
                                                     ON     ad.apd_ap =
                                                            pp1.app_ap
                                                        AND ad.apd_app =
                                                            pp1.app_id
                                                 JOIN
                                                 uss_esr.ap_document_attr da
                                                     ON     da.apda_apd =
                                                            ad.apd_id
                                                        AND da.apda_nda IN
                                                                (797) -- категорія
                                                        AND da.history_status =
                                                            'A'
                                                        AND da.apda_val_string IN
                                                                ('DI', 'DIA') -- Дитина з інвалідністю, дитина з інвалідністю підгрупи А
                                           WHERE     d1.pd_ap = d.pd_ap
                                                 AND f.pdf_birth_dt >
                                                     ADD_MONTHS (p.nm_month,
                                                                 (-12 * 18))) -- не виповнилось 18 років
                                THEN
                                    1
                                ELSE
                                    0
                            END
                                is_dia,
                            NVL (dnet$payment_long_rep.get_doc_string (
                                     NULL,
                                     d.pd_ap,
                                     605,
                                     650),
                                 'F')
                                is_work,
                            (SELECT MIN (da.apda_val_dt)
                               FROM uss_esr.ap_person  pp1
                                    JOIN uss_esr.ap_document ad
                                        ON     ad.apd_ap = pp1.app_ap
                                           AND ad.apd_app = pp1.app_id
                                           AND ad.history_status = 'A'
                                           AND ad.apd_ndt = 675 -- Копія наказу (розпорядження) роботодавця про надання відпустки
                                    JOIN uss_esr.ap_document_attr da
                                        ON     da.apda_apd = ad.apd_id
                                           AND da.apda_nda IN (4364) -- Початок періоду відпустки, з
                                           AND da.history_status = 'A'
                                    JOIN uss_esr.ap_document_attr db
                                        ON     db.apda_apd = ad.apd_id
                                           AND db.apda_nda IN (4366) -- Вид відпустки
                                           AND db.apda_val_string = 'WTHT' -- V_DDN_VACATION_TP
                                           AND db.history_status = 'A'
                              WHERE pp1.app_ap = d.pd_ap)
                                dt_vacation_begin,
                            (SELECT MAX (da.apda_val_dt)
                               FROM uss_esr.ap_person  pp1
                                    JOIN uss_esr.ap_document ad
                                        ON     ad.apd_ap = pp1.app_ap
                                           AND ad.apd_app = pp1.app_id
                                           AND ad.apd_ndt = 675 -- Копія наказу (розпорядження) роботодавця про надання відпустки
                                           AND ad.history_status = 'A'
                                    JOIN uss_esr.ap_document_attr da
                                        ON     da.apda_apd = ad.apd_id
                                           AND da.apda_nda IN (4365) -- Кінець періоду відпустки, по
                                           AND da.history_status = 'A'
                                    JOIN uss_esr.ap_document_attr db
                                        ON     db.apda_apd = ad.apd_id
                                           AND db.apda_nda IN (4366) -- Вид відпустки
                                           AND db.apda_val_string = 'WTHT' -- V_DDN_VACATION_TP
                                           AND db.history_status = 'A'
                              WHERE pp1.app_ap = d.pd_ap)
                                dt_vacation_end,
                            CASE
                                WHEN EXISTS
                                         (SELECT 1
                                            FROM uss_esr.pc_decision  d1
                                                 JOIN uss_esr.pd_family f
                                                     ON f.pdf_pd = d1.pd_id
                                                 JOIN uss_esr.ap_person pp1
                                                     ON     pp1.app_ap =
                                                            d.pd_ap
                                                        AND pp1.app_sc =
                                                            f.pdf_sc
                                                        AND pp1.app_tp NOT IN
                                                                ('Z', 'P')
                                                 JOIN uss_esr.ap_document ad
                                                     ON     ad.apd_ap =
                                                            pp1.app_ap
                                                        AND ad.apd_app =
                                                            pp1.app_id
                                                 JOIN
                                                 uss_esr.ap_document_attr da
                                                     ON     da.apda_apd =
                                                            ad.apd_id
                                                        AND da.apda_nda IN
                                                                (349,
                                                                 666,
                                                                 1790) -- Група інвалідності
                                                        AND da.history_status =
                                                            'A'
                                                        AND da.apda_val_string IN
                                                                ('1') -- Група інвалідності I
                                           WHERE     d1.pd_ap = d.pd_ap
                                                 AND f.pdf_birth_dt <=
                                                     ADD_MONTHS (p.nm_month,
                                                                 (-12 * 18))) -- виповнилось 18 років
                                THEN
                                    1
                                ELSE
                                    0
                            END
                                is_gr1,
                            pp.pdp_sum
                       FROM pdap  p
                            INNER JOIN uss_esr.pc_decision d
                                ON d.pd_id = p.pd_id
                            INNER JOIN uss_esr.pd_payment pp
                                ON     pp.pdp_pd = d.pd_id
                                   AND pp.history_status = 'A'
                            INNER JOIN uss_esr.personalcase c
                                ON c.pc_id = d.pd_pc
                            INNER JOIN uss_ndi.v_ndi_payment_type pt
                                ON pt.npt_id = pp.pdp_npt
                            --INNER JOIN uss_ndi.v_ndi_months m         ON m.nm_month = p.nm_month
                            INNER JOIN uss_ndi.v_ndi_months m
                                ON     m.nm_month >=
                                       CASE -- Якщо дата рішення більша, ніж дата початку дії рішення в PD_Payment, тоді треба в місяці, коли прийнято рішення, зробити рядки по звіту за всі місяці, які перед місяцем рішення
                                           WHEN     p.is_before = 1
                                                -- Tania, 30.07.2024 14:55 по всім з NPT_ID = 37, 40, 1, 219
                                                AND pt.npt_id IN (37,
                                                                  40,
                                                                  1,
                                                                  219,
                                                                  835,
                                                                  836,
                                                                  839)
                                           THEN
                                               TRUNC (pp.pdp_start_dt, 'mm')
                                           ELSE
                                               p.nm_month
                                       END
                                   AND m.nm_month <= p.nm_month
                      WHERE     p.nm_month BETWEEN TRUNC (pp.pdp_start_dt,
                                                          'mm')
                                               AND pp.pdp_stop_dt
                            AND pp.pdp_stop_dt >= pp.pdp_start_dt
                            AND pp.pdp_sum > 0
                            -- не відображати попередні місяця по рішенням дата яких більше початку періоду нарахувань
                            AND (   p.is_after = 0
                                 OR pt.npt_id NOT IN (37,
                                                      40,
                                                      1,
                                                      219,
                                                      835,
                                                      836,
                                                      839))
                            -- ключове - сума не рахується по кількості рішень лише одне повинно бути
                            AND p.rn = 1
                            AND pt.npt_include_esv_rpt = 'T'
                            -- По допомозі по інвалідам потрібно брати лише тих осіб, по яким є надбавка на догляд (NPT_ID = 48), суму також лише по цій надбавці.
                            AND pt.npt_id NOT IN
                                    (SELECT pt.npt_id
                                       FROM uss_ndi.v_ndi_payment_type  pt
                                            JOIN uss_ndi.v_ndi_npt_config nc
                                                ON (nc.nptc_npt = pt.npt_id)
                                            JOIN
                                            uss_ndi.v_ndi_service_type st
                                                ON (st.nst_id = nc.nptc_nst)
                                      WHERE     pt.history_status = 'A'
                                            AND st.history_status = 'A'
                                            AND pt.npt_id != 1
                                            AND st.nst_id = 248)
                            -- по догляду за дітьми-інвалідами
                            AND CASE
                                    WHEN d.pd_nst != 248
                                    THEN
                                        1
                                    -- 1 заявник (без утриманців) - ЄСВ не нараховується
                                    WHEN NOT EXISTS
                                             (SELECT 1
                                                FROM uss_esr.pd_family  f,
                                                     uss_esr.ap_person  p1
                                               WHERE     f.pdf_pd = d.pd_id
                                                     AND p1.app_ap = d.pd_ap
                                                     AND p1.app_sc = f.pdf_sc
                                                     AND p1.app_tp NOT IN
                                                             ('P', 'Z'))
                                    THEN
                                        0
                                    -- IC #103937 якщо по людині немає рішення, де він лише сам є отримувачем (рішення, де лише один учасник).
                                    WHEN EXISTS
                                             (SELECT 1
                                                FROM uss_esr.pc_decision  d1
                                                     JOIN
                                                     uss_esr.pd_payment pp1
                                                         ON     pp1.pdp_pd =
                                                                d1.pd_id
                                                            AND pp1.history_status =
                                                                'A'
                                                            AND m.nm_month BETWEEN TRUNC (
                                                                                       pp1.pdp_start_dt,
                                                                                       'mm')
                                                                               AND pp1.pdp_stop_dt
                                               WHERE     d1.pd_pc = c.pc_id
                                                     AND d1.pd_id != d.pd_id
                                                     AND NOT EXISTS
                                                             (SELECT 1
                                                                FROM uss_esr.pd_family
                                                                     f,
                                                                     uss_esr.ap_person
                                                                     p1
                                                               WHERE     f.pdf_pd =
                                                                         d1.pd_id
                                                                     AND p1.app_ap =
                                                                         d1.pd_ap
                                                                     AND p1.app_sc =
                                                                         f.pdf_sc
                                                                     AND p1.app_tp NOT IN
                                                                             ('P',
                                                                              'Z')))
                                    THEN
                                        0
                                    -- або немає іншого рішення з іншим інвалідом
                                    WHEN EXISTS
                                             (SELECT 1
                                                FROM uss_esr.pc_decision  d1
                                                     JOIN
                                                     uss_esr.pd_payment pp1
                                                         ON     pp1.pdp_pd =
                                                                d1.pd_id
                                                            AND pp1.history_status =
                                                                'A'
                                                            AND m.nm_month BETWEEN TRUNC (
                                                                                       pp1.pdp_start_dt,
                                                                                       'mm')
                                                                               AND pp1.pdp_stop_dt
                                                     JOIN uss_esr.pd_family f
                                                         ON     d1.pd_id =
                                                                f.pdf_pd
                                                            AND NOT EXISTS
                                                                    (SELECT 1
                                                                       FROM uss_esr.pd_family
                                                                                f1
                                                                      WHERE     f1.pdf_pd =
                                                                                d.pd_id
                                                                            AND f1.pdf_sc =
                                                                                f.pdf_sc)
                                                     JOIN
                                                     uss_esr.ap_person p1
                                                         ON     p1.app_ap =
                                                                d1.pd_ap
                                                            AND p1.app_sc =
                                                                f.pdf_sc
                                                            AND p1.app_tp NOT IN
                                                                    ('P', 'Z')
                                                            AND EXISTS
                                                                    (SELECT 1
                                                                       FROM uss_esr.ap_document
                                                                                ad
                                                                      WHERE     ad.apd_ap =
                                                                                p1.app_ap
                                                                            AND ad.apd_app =
                                                                                p1.app_id
                                                                            AND ad.apd_ndt IN
                                                                                    (200,
                                                                                     201)) -- Документ про інвалідність
                                               WHERE     d1.pd_pc = c.pc_id
                                                     AND d1.pd_id != d.pd_id)
                                    THEN
                                        0
                                    ELSE
                                        1
                                END =
                                1
                            -- усиновлення (NPT_ID = 40)
                            AND (   EXISTS
                                        (SELECT 1
                                           FROM pd_family f
                                          WHERE     f.pdf_pd = d.pd_id
                                                AND f.pdf_birth_dt >
                                                    ADD_MONTHS (p.nm_month,
                                                                (-12 * 3)) -- Якщо вік всіх учасників > 3 років у місяці звіту, тоді не включати особу до звіту
                                                AND NVL (f.history_status,
                                                         'A') =
                                                    'A')
                                 OR pt.npt_id != 40)
                            AND (   EXISTS
                                        (SELECT 1
                                           FROM uss_esr.pd_detail pd
                                          WHERE     pd.pdd_pdp = pp.pdp_id
                                                AND p.nm_month BETWEEN TRUNC (
                                                                           pd.pdd_start_dt,
                                                                           'mm')
                                                                   AND pd.pdd_stop_dt
                                                AND pd.pdd_npt = 48)
                                 OR pt.npt_id != 1 -- перевірка тільки по допомозі по інвалідам
                                                  )
                            -- IC #101709 Якщо заявник - пенсіонер (більше 60 років), то виключаємо зі звіту
                            AND NOT EXISTS
                                    (SELECT 1
                                       FROM uss_esr.pd_family  f,
                                            uss_esr.ap_person  p1
                                      WHERE     p1.app_ap = d.pd_ap
                                            AND f.pdf_pd = d.pd_id
                                            AND p1.app_sc = f.pdf_sc
                                            AND p1.history_status = 'A'
                                            AND f.pdf_birth_dt <=
                                                ADD_MONTHS (p.nm_month,
                                                            (-12 * 60)) -- Більше 60 років
                                            AND p1.app_tp = 'Z')
                            -- IC #110501 Соціальна допомога на дітей-сиріт та дітей, позбавлених батьківського піклування, грошове забезпечення батькам-вихователям і прийомним батькам
                            -- Якщо по особі є такий документ з датою, яка пізніше дати вивантаження або довічно, тоді не вивантажумо цю особу до ЄСВ
                            AND (   NOT EXISTS
                                        (SELECT 1 -- IC #109713 первинна задача
                                           FROM uss_esr.pd_detail  pd
                                                JOIN uss_esr.pd_family f
                                                    ON f.pdf_id = pd.pdd_key
                                                JOIN uss_esr.ap_person pp1
                                                    ON     pp1.app_ap =
                                                           d.pd_ap
                                                       AND pp1.app_sc =
                                                           f.pdf_sc
                                                JOIN uss_esr.ap_document ad
                                                    ON     ad.apd_ap =
                                                           pp1.app_ap
                                                       AND ad.apd_app =
                                                           pp1.app_id
                                                       AND ad.apd_ndt IN
                                                               (200, 201) -- Документ про інвалідність
                                                       AND ad.history_status =
                                                           'A'
                                                JOIN DUAL
                                                    ON     1 = 1
                                                       AND (   EXISTS
                                                                   (SELECT 1
                                                                      FROM uss_esr.ap_document_attr
                                                                           da
                                                                     WHERE     da.apda_apd =
                                                                               ad.apd_id
                                                                           AND da.apda_nda IN
                                                                                   (347,
                                                                                    793) -- Встановлено на період до
                                                                           AND da.apda_val_dt >=
                                                                               p.nm_month
                                                                           AND da.history_status =
                                                                               'A')
                                                            OR EXISTS
                                                                   (SELECT 1
                                                                      FROM uss_esr.ap_document_attr
                                                                           da
                                                                     WHERE     da.apda_apd =
                                                                               ad.apd_id
                                                                           AND da.apda_nda IN
                                                                                   (2925) -- Призначено довічно
                                                                           AND da.apda_val_string =
                                                                               'T'
                                                                           AND da.history_status =
                                                                               'A'))
                                          WHERE     pd.pdd_pdp = pp.pdp_id
                                                AND pd.pdd_npt IN (835, 836))
                                 OR d.pd_nst NOT IN (275))) -- select * from nrh
              SELECT NULL                             MEUR_ID,
                     p_me_id                          MEUR_ME,
                     t2.pc_id                         MEUR_PC,
                     TO_CHAR (l_rep_date, 'mm')       PERIOD_M -- числове значення місяця (з параметрів)
                                                              ,
                     TO_CHAR (l_rep_date, 'yyyy')     PERIOD_Y -- числове значення року (з параметрів)
                                                              ,
                     1                                UKR_GROMAD -- виводимо 1 для всіх
                                                                ,
                     t2.NUMIDENT,
                     t2.LN,
                     t2.NM,
                     t2.FTN,
                     t2.ZO,
                     t2.START_DT,
                     t2.STOP_DT,
                     0                                PAY_TP,
                     t2.PAY_MNTH,
                     t2.PAY_YEAR,
                     t2.SUM_TOTAL,
                     t2.SUM_MAX,
                     t2.SUM_INS,
                     ''                               OZN,
                     c_st_MEMR_Exists                 MEUR_ST  -- E (Створено)
                FROM (SELECT t1.*,
                             -- Якщо по людині декілька допомог, тоді беремо будь яку з максимальним періодом (по мінімальному ЗО) за місяць.
                             -- Якщо 2 види допомоги, - основним кодом має бути 20 (до 3х років усиновлення чи при народженні),
                             -- після 3х має змінюватись на код догляду (21 чи 70).
                             DENSE_RANK ()
                                 OVER (
                                     PARTITION BY t1.pc_sc
                                     ORDER BY
                                         t1.cnt_dt DESC,
                                         CASE
                                             WHEN t1.zo = 0 THEN 10000
                                             ELSE t1.zo
                                         END)    rn
                        FROM (SELECT t.*,
                                     MAX (t.cnt_dt_pdap)
                                         OVER (PARTITION BY t.pc_sc, t.zo)    cnt_dt
                                FROM (  SELECT (  SELECT    CASE
                                                                WHEN dt.ndt_id = 6
                                                                THEN
                                                                    'БК' -- Якщо РНОКПП порожній, тоді заповнюємо конкатенацією "БК"+серія та № паспорту (якщо паспорт України)
                                                                WHEN dt.ndt_id = 7
                                                                THEN
                                                                    'П' -- У випадку ID картки конкатенація "П" + № картки
                                                                ELSE
                                                                    ''
                                                            END
                                                         || d.scd_seria
                                                         || d.scd_number -- 'П'
                                                    FROM uss_person.v_sc_document d,
                                                         USS_NDI.v_ndi_document_type
                                                         dt
                                                   WHERE     scd_sc = nrh.pc_sc
                                                         AND d.scd_ndt = dt.ndt_id
                                                         AND dt.ndt_ndc IN (2, 13)
                                                         AND d.scd_st IN ('1', 'A')
                                                         AND d.scd_number
                                                                 IS NOT NULL
                                                ORDER BY ndt_order NULLS LAST,
                                                         ndt_id
                                                   FETCH FIRST ROW ONLY)
                                                   NUMIDENT -- РНОКПП заявника. Якщо РНОКПП порожній, тоді вносимо серію та № паспорту (без пробілів, 8 символів) або ID-картку (9 символів) або серію та № свідоцтва про народження (в залежності того, які є документи по заявнику)
                                                           ,
                                               sci_ln
                                                   LN              -- прізвище
                                                     ,
                                               sci_fn
                                                   NM                  -- ім'я
                                                     ,
                                               sci_mn
                                                   FTN          -- по батькові
                                                      ,
                                               nrh.npt_id
                                                   ZO -- варіанти: 70 - по допомозі по догляду за дитиною (NPT_ID = 37);21 - по догляду за дітьми-інвалідами (NPT_ID = 1, 219)
                                                     ,
                                               TO_CHAR (MIN (nrh.acd_start_dt),
                                                        'dd')
                                                   START_DT -- число з поля ACD_Start_DT (мінімальне, якщо декілька рядків по місяцю)
                                                           ,
                                               TO_CHAR (MAX (nrh.acd_stop_dt),
                                                        'dd')
                                                   STOP_DT -- число з поля ACD_Stop_DT (максимальне, якщо декілька рядків по місяцю)
                                                          --,0                          PAY_TP -- заповнюємо всім 0
                                                          ,
                                               TO_CHAR (
                                                   TRUNC (nrh.acd_start_dt, 'mm'),
                                                   'mm')
                                                   PAY_MNTH -- номер місяця з поля ACD_Start_DT
                                                           ,
                                               TO_CHAR (
                                                   TRUNC (nrh.acd_start_dt, 'mm'),
                                                   'yyyy')
                                                   PAY_YEAR -- рік з поля ACD_Start_DT
                                                           -- IC #94638
                                                           ,
                                               LEAST (
                                                   GREATEST (
                                                       SUM (nrh.acd_sum),
                                                       ROUND (
                                                           SUM (
                                                                 uss_esr.dnet$payment_long_rep.get_MZP (
                                                                     nrh.acd_start_dt)
                                                               / nrh.cnt_dt_month
                                                               * nrh.cnt_dt),
                                                           2)),
                                                   ROUND (
                                                       SUM (
                                                             uss_esr.dnet$payment_long_rep.get_MZP (
                                                                 nrh.acd_start_dt,
                                                                 'max')
                                                           / nrh.cnt_dt_month
                                                           * nrh.cnt_dt),
                                                       2))
                                                   SUM_TOTAL -- нарахована сума за місяць
                                                            ,
                                               SUM (nrh.acd_sum)
                                                   SUM_MAX -- нарахована сума за місяць
                                                          ,
                                               ROUND (SUM (nrh.acd_sum) * 0.22,
                                                      2)
                                                   SUM_INS -- нарахована сума за місяць * 0,22 (округлення до 2 знаків після коми)
                                                          --,null                       OZN -- порожне значенн
                                                          ,
                                               nrh.pc_id,
                                               nrh.pc_sc,
                                               MAX (nrh.cnt_dt_pdap)
                                                   cnt_dt_pdap
                                          FROM nrh
                                               LEFT JOIN
                                               uss_person.v_socialcard sc
                                                   ON sc.sc_id = nrh.pc_sc
                                               LEFT JOIN
                                               uss_person.v_sc_change scc
                                                   ON     scc.scc_sc = sc_id
                                                      AND scc_id = sc_scc
                                               LEFT JOIN uss_person.v_sc_identity
                                                   ON sci_id = scc_sci
                                         WHERE -- Заявник - опікун особи/дитини з інвалідністю
                                               CASE
                                                   WHEN npt_id = 21
                                                   THEN
                                                       -- IC #110494
                                                       CASE
                                                           WHEN     is_work = 'T'
                                                                AND NOT EXISTS
                                                                        (SELECT 1
                                                                           FROM DUAL
                                                                          WHERE nrh.acd_start_dt BETWEEN nrh.dt_vacation_begin
                                                                                                     AND nrh.dt_vacation_end)
                                                           THEN
                                                               0 -- + ПРАЦЮЄ і не у відпустці без збереження з/п по догляду за дитиною - ЄСВ не нараховується
                                                           WHEN     is_dia = 0
                                                                AND is_gr1 = 0
                                                           THEN
                                                               0 -- якщо інваліду вже є 18 років і це не 1 група інвалідності, тоді теж не включаємо в звіт
                                                           -- WHEN is_pens = 1 THEN 0     -- + пенсіонер за віком (60 років по даті народження) - ЄСВ не нараховується
                                                           ELSE
                                                               1
                                                       END
                                                   ELSE
                                                       1
                                               END =
                                               1
                                      GROUP BY nrh.pc_id,
                                               nrh.pc_sc,
                                               sci_ln,
                                               sci_fn,
                                               sci_mn,
                                               nrh.npt_id,
                                               TRUNC (nrh.acd_start_dt, 'mm'))
                                     t
                               WHERE t.NUMIDENT IS NOT NULL) t1) t2
               WHERE    t2.rn = 1
                     OR     t2.ZO = 24 -- IC #109642  Вивантажується незалежно від інших допомог
                        -- IC #114347 треба перевіряти наявність вивантаження за цей місяць в попередні періоди
                        AND NOT EXISTS
                                (SELECT 1
                                   FROM uss_esr.mass_exchanges    m,
                                        uss_esr.me_esv_unload_rows rr
                                  WHERE     rr.meur_pc = t2.pc_id
                                        AND rr.meur_me = m.me_id
                                        AND rr.meur_pay_mnth = t2.pay_mnth
                                        AND rr.meur_pay_year = t2.pay_year
                                        AND m.me_id != p_me_id
                                        AND m.me_st = 'R')
            ORDER BY 1, 10, 9;

        l_cnt := SQL%ROWCOUNT;

        UPDATE uss_esr.mass_exchanges
           SET me_count = l_cnt
         WHERE me_id = p_me_id;

        UPDATE uss_esr.me_esv_unload_rows
           SET meur_sum_max = meur_sum_total,
               meur_sum_ins = ROUND (meur_sum_total * 0.22, 2)
         WHERE meur_me = p_me_id AND meur_st = c_st_MEMR_Exists;

        setPacketSt (p_me_id, c_st_MEMR_Exists);
    EXCEPTION
        WHEN OTHERS
        THEN
            TOOLS.JobSaveMessage (
                   'Помилка виконання prepare_me_rows_esv:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END prepare_me_rows_esv;

    -- додавання рядка в blob. використовується в build_csv
    PROCEDURE b_put_line (p_lob IN OUT NOCOPY BLOB, p_str VARCHAR2)
    IS
        l_buff   VARCHAR2 (32760);
    BEGIN
        l_buff := p_str || CHR (13) || CHR (10);
        DBMS_LOB.writeappend (
            lob_loc   => p_lob,
            amount    => DBMS_LOB.getlength (UTL_RAW.cast_to_raw (l_buff)),
            buffer    => UTL_RAW.cast_to_raw (l_buff));
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (-20000,
                                     'b_put_line: ' || CHR (10) || SQLERRM);
    END;

    -- процедура формування csv файлу по вказаному sql-запиту
    PROCEDURE build_csv (p_sql        IN     VARCHAR2,
                         p_csv_blob      OUT BLOB,
                         p_rtrim      IN     VARCHAR2 := ' ')
    IS
        l_csv_line   VARCHAR2 (32000);
        v_v_val      VARCHAR2 (4000);
        v_n_val      NUMBER;
        v_d_val      DATE;
        v_ret        NUMBER;
        c_sql        NUMBER;
        l_exec       NUMBER;
        col_cnt      INTEGER;
        --f           BOOLEAN;
        rec_tab      DBMS_SQL.DESC_TAB;
    --col_num     NUMBER;
    --v_fh        UTL_FILE.FILE_TYPE;
    BEGIN
        DBMS_LOB.createtemporary (lob_loc => p_csv_blob, cache => TRUE);
        DBMS_LOB.open (lob_loc     => p_csv_blob,
                       open_mode   => DBMS_LOB.lob_readwrite);
        -- dbms_output.put_line(p_sql);
        c_sql := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE (c_sql, p_sql, DBMS_SQL.NATIVE);
        l_exec := DBMS_SQL.EXECUTE (c_sql);
        DBMS_SQL.DESCRIBE_COLUMNS (c_sql, col_cnt, rec_tab);

        --dbms_sql.describe_columns2(c_sql, col_cnt, rec_tab);
        FOR j IN 1 .. col_cnt
        LOOP
            CASE rec_tab (j).col_type
                WHEN 1
                THEN
                    DBMS_SQL.DEFINE_COLUMN (c_sql,
                                            j,
                                            v_v_val,
                                            2000);
                WHEN 2
                THEN
                    DBMS_SQL.DEFINE_COLUMN (c_sql, j, v_n_val);
                WHEN 12
                THEN
                    DBMS_SQL.DEFINE_COLUMN (c_sql, j, v_d_val);
                ELSE
                    DBMS_SQL.DEFINE_COLUMN (c_sql,
                                            j,
                                            v_v_val,
                                            2000);
            END CASE;
        END LOOP;

        -- This part outputs the HEADER
        l_csv_line := '';

        FOR j IN 1 .. col_cnt
        LOOP
            l_csv_line := l_csv_line || '"' || rec_tab (j).col_name || '";';
        END LOOP;

        ---l_csv_line := l_csv_line||chr(10)||chr(13);
        b_put_line (p_csv_blob, RTRIM (l_csv_line, p_rtrim));

        --dbms_output.put_line(l_csv_line);

        -- This part outputs the DATA
        LOOP
            v_ret := DBMS_SQL.FETCH_ROWS (c_sql);
            EXIT WHEN v_ret = 0;
            l_csv_line := NULL;

            FOR j IN 1 .. col_cnt
            LOOP
                /*      CASE rec_tab(j).col_type
                        WHEN 1 THEN DBMS_SQL.COLUMN_VALUE(c_sql,j,v_v_val);
                                    l_csv_line := ltrim(l_csv_line||',"'||replace(v_v_val, '"', '""')||'"',',');
                        WHEN 2 THEN DBMS_SQL.COLUMN_VALUE(c_sql,j,v_n_val);
                                    l_csv_line := ltrim(l_csv_line||','||v_n_val,',');
                        WHEN 12 THEN DBMS_SQL.COLUMN_VALUE(c_sql,j,v_d_val);
                                    l_csv_line := ltrim(l_csv_line||','||to_char(v_d_val,'DD/MM/YYYY HH24:MI:SS'),',');
                      ELSE
                        DBMS_SQL.COLUMN_VALUE(c_sql,j,v_v_val);
                        l_csv_line := ltrim(l_csv_line||',"'||v_v_val||'"',',');
                      END CASE;*/
                /*
                  TYPECODE_CHAR            PLS_INTEGER :=  96;
                  TYPECODE_VARCHAR2        PLS_INTEGER :=   9;
                  TYPECODE_VARCHAR         PLS_INTEGER :=   1;
                  TYPECODE_NUMBER          PLS_INTEGER :=   2;
                  TYPECODE_DATE            PLS_INTEGER :=  12;
                     */
                CASE
                    WHEN rec_tab (j).col_type IN (1, 9, 96)
                    THEN                                              -- текст
                        DBMS_SQL.COLUMN_VALUE (c_sql, j, v_v_val);
                        l_csv_line :=
                               l_csv_line
                            || '"'
                            || REPLACE (TRIM (v_v_val), '"', '""')
                            || '";';
                    WHEN rec_tab (j).col_type = 2
                    THEN                                              -- число
                        DBMS_SQL.COLUMN_VALUE (c_sql, j, v_n_val);
                        l_csv_line :=
                               l_csv_line
                            || REPLACE (TO_CHAR (v_n_val), '.', ',')
                            || ';';
                    WHEN rec_tab (j).col_type = 12
                    THEN                                               -- дата
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
                        l_csv_line := l_csv_line || '"' || v_v_val || '";';
                END CASE;
            --dbms_output.put_line('val=<'||v_v_val||'>, type='||rec_tab(j).col_type) ;
            END LOOP;

            --DBMS_OUTPUT.PUT_LINE(l_csv_line);
            b_put_line (p_csv_blob, RTRIM (l_csv_line, p_rtrim)); -- завершальні ;  зайві  rtrim(, ';')
        END LOOP;

        DBMS_SQL.CLOSE_CURSOR (c_sql);
    END;

    -- формування html-таблиці по даних csv-файла(вмісту пакета квитанції)
    FUNCTION convert_csv2html (p_csv_clob CLOB, p_file_name VARCHAR2)
        RETURN CLOB
    IS
        l_clob   CLOB;
    BEGIN
        SELECT XMLELEMENT (
                   "div",
                   XMLELEMENT (
                       "style",
                       'table.z, th.z, td.z {border: 1px solid black;    border-collapse: collapse;}'),
                   XMLELEMENT ("p", 'Файл: ' || p_file_name     /*||'<br>Дата створення: '||to_char(sysdate, 'DD.MM.YYYY HH24:MI:SS')*/
                                                           ),
                   XMLELEMENT (
                       "table",
                       XMLATTRIBUTES ('z' AS "class"),
                       XMLAGG (
                           XMLELEMENT (
                               "tr",
                               XMLATTRIBUTES ('z' AS "class"),
                               XMLELEMENT ("td",
                                           XMLATTRIBUTES ('z' AS "class"),
                                           COL001),
                               XMLELEMENT ("td",
                                           XMLATTRIBUTES ('z' AS "class"),
                                           COL002),
                               XMLELEMENT ("td",
                                           XMLATTRIBUTES ('z' AS "class"),
                                           COL003),
                               CASE
                                   WHEN x004 IS NOT NULL
                                   THEN
                                       XMLELEMENT (
                                           "td",
                                           XMLATTRIBUTES ('z' AS "class"),
                                           COL004)
                               END,
                               CASE
                                   WHEN x005 IS NOT NULL
                                   THEN
                                       XMLELEMENT (
                                           "td",
                                           XMLATTRIBUTES ('z' AS "class"),
                                           COL005)
                               END,
                               CASE
                                   WHEN x006 IS NOT NULL
                                   THEN
                                       XMLELEMENT (
                                           "td",
                                           XMLATTRIBUTES ('z' AS "class"),
                                           COL006)
                               END,
                               CASE
                                   WHEN x007 IS NOT NULL
                                   THEN
                                       XMLELEMENT (
                                           "td",
                                           XMLATTRIBUTES ('z' AS "class"),
                                           COL007)
                               END,
                               CASE
                                   WHEN x008 IS NOT NULL
                                   THEN
                                       XMLELEMENT (
                                           "td",
                                           XMLATTRIBUTES ('z' AS "class"),
                                           COL008)
                               END,
                               CASE
                                   WHEN x009 IS NOT NULL
                                   THEN
                                       XMLELEMENT (
                                           "td",
                                           XMLATTRIBUTES ('z' AS "class"),
                                           COL009)
                               END,
                               CASE
                                   WHEN x010 IS NOT NULL
                                   THEN
                                       XMLELEMENT (
                                           "td",
                                           XMLATTRIBUTES ('z' AS "class"),
                                           COL010)
                               END,
                               CASE
                                   WHEN x011 IS NOT NULL
                                   THEN
                                       XMLELEMENT (
                                           "td",
                                           XMLATTRIBUTES ('z' AS "class"),
                                           COL011)
                               END)))).getClobVal ()
          INTO l_clob
          FROM (SELECT                                        /*line_number,*/
                       COL001,
                       COL002,
                       COL003,
                       COL004,
                       COL005,
                       COL006,
                       COL007,
                       COL008,
                       COL009,
                       COL010,
                       COL011,
                       MAX (COL004) OVER ()     AS x004,
                       MAX (COL005) OVER ()     AS x005,
                       MAX (COL006) OVER ()     AS x006,
                       MAX (COL007) OVER ()     AS x007,
                       MAX (COL008) OVER ()     AS x008,
                       MAX (COL009) OVER ()     AS x009,
                       MAX (COL010) OVER ()     AS x010,
                       MAX (COL011) OVER ()     AS x011
                  FROM TABLE (csv_util_pkg.clob_to_csv (p_csv_clob)/*apex_data_parser.parse(
                                                                       p_content           => tools.ConvertC2BUTF8(p_csv_clob),
                                                                       p_add_headers_row   => 'Y',
                                                                       p_file_name         => p_file_name
                                                                       )*/
                                                                   ) p);

        RETURN l_clob;
    END;

    --Виконати розрахунок даних пакету
    PROCEDURE make_me_packet (p_me_tp          mass_exchanges.me_tp%TYPE,
                              p_me_month       mass_exchanges.me_month%TYPE,
                              p_me_id      OUT mass_exchanges.me_id%TYPE,
                              p_me_jb      OUT mass_exchanges.me_jb%TYPE)
    IS
        l_hs_id      INTEGER := tools.GetHistSession;
        l_org        NUMBER := NVL (tools.GetCurrOrg, 50001);
        l_cnt        INTEGER;
        l_sql        VARCHAR2 (1024);
        l_me_month   DATE;
    BEGIN
        -- 0. контролі
        -- 0.1 перевіряємо на відсутність нескасованих записів відповідного місяця
        -- IC #116595
        l_me_month :=
            CASE
                WHEN p_me_tp IN ('ESV') THEN TRUNC (p_me_month, 'mm')
                ELSE p_me_month
            END;

        SELECT COUNT (1)
          INTO l_cnt
          FROM mass_exchanges m
         WHERE     m.me_tp = p_me_tp
               AND m.me_month = l_me_month
               AND NVL (m.com_org, 50001) = l_org
               AND m.me_st != 'D';

        IF l_cnt > 0
        THEN
            raise_application_error (
                -20000,
                'Помилка підготовки даних для обміну: Існує нескасований запис з вказаними параметрами!');
        END IF;

        -- 1. реєструємо запис
        INSERT INTO mass_exchanges (me_id,
                                    me_tp,
                                    me_month,
                                    me_dt,
                                    me_st,
                                    me_hs_ins,
                                    com_org)
             VALUES (NULL,
                     p_me_tp,
                     l_me_month,
                     TRUNC (SYSDATE),
                     c_st_ME_Creating,
                     l_hs_id,
                     l_org)
          RETURNING me_id
               INTO p_me_id;

        write_me_log (p_mel_me        => p_me_id,
                      p_mel_hs        => l_hs_id,
                      p_mel_st        => c_st_ME_Creating,
                      p_mel_message   => 'Почато формування пакету',
                      p_mel_st_old    => NULL);
        COMMIT;

        l_sql :=
               'begin uss_esr.api$mass_exchange.prepare_me_rows('
            || p_me_id
            || '); end;';

        IF p_me_tp IN ('UN', 'UNP')                     -- uss_ndi.v_ddn_me_tp
        THEN
            l_sql :=
                   'begin uss_esr.api$mass_exchange.prepare_me_rows_un('
                || p_me_id
                || '); end;';
        ELSIF p_me_tp IN ('UN_R', 'UNP_R')
        THEN
            l_sql :=
                   'begin uss_esr.api$mass_exchange.prepare_me_rows_unr('
                || p_me_id
                || '); end;';
        ELSIF p_me_tp IN ('UN_RR', 'UNP_RR')
        THEN
            l_sql :=
                   'begin uss_esr.api$mass_exchange.prepare_me_rows_unrr('
                || p_me_id
                || '); end;';
        ELSIF p_me_tp IN ('UN_306', 'UNP_306')
        THEN
            l_sql :=
                   'begin uss_esr.api$mass_exchange.prepare_me_rows_un306('
                || p_me_id
                || '); end;';
        ELSIF p_me_tp IN ('ESV')
        THEN
            l_sql :=
                   'begin uss_esr.api$mass_exchange.prepare_me_rows_esv('
                || p_me_id
                || '); end;';
        ELSIF p_me_tp = 'CZ'
        THEN
            l_sql :=
                   'begin uss_esr.Api$mass_Exchange_Dcz.Prepare_Me_Rows('
                || p_me_id
                || '); end;';
        ELSIF p_me_tp = 'DPS'
        THEN
            l_sql :=
                   'begin uss_esr.Api$mass_Exchange_Dps.Prepare_Me_Rows('
                || p_me_id
                || '); end;';
        ELSIF p_me_tp = 'UNI'
        THEN
            l_sql :=
                   'begin uss_esr.Api$mass_Exchange_Uni.Prepare_Me_Rows('
                || p_me_id
                || '); end;';
        ELSIF p_me_tp IN ('PFU_51', 'PFU_131', 'PFU_132')
        THEN
            l_sql :=
                   'begin uss_esr.Api$mass_Exchange_PFU.Prepare_Me_Rows('
                || p_me_id
                || '); end;';
        ELSIF p_me_tp IN ('INC', 'INC2')
        THEN
            l_sql :=
                   'begin uss_esr.Api$mass_Exchange_Inc.Prepare_Me_Rows('
                || p_me_id
                || '); end;';
        END IF;

        -- 2. запускаємо джоб підготовки даних
        TOOLS.SubmitSchedule (p_jb       => p_me_jb,
                              p_subsys   => 'USS_ESR',
                              p_wjt      => 'ME_ROWS_PREPARE',
                              p_what     => l_sql);

        UPDATE mass_exchanges
           SET me_jb = p_me_jb
         WHERE me_id = p_me_id;
    END make_me_packet;

    -- #92025  17/10/2023 serhii: розділив make_exchange_file_job на 2 окремі процедури:
    -- create_file_F01_job, create_file_C01_job
    PROCEDURE make_exchange_file (p_me_id       mass_exchanges.me_id%TYPE,
                                  p_jb_id   OUT exchangefiles.ef_kv_pkt%TYPE)
    IS
        l_prev_st        mass_exchanges.me_st%TYPE;
        l_me_tp          mass_exchanges.me_tp%TYPE;
        l_prev_st_name   VARCHAR2 (250);
        l_sql            VARCHAR2 (1024);
    BEGIN
        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (
                'make_exchange_file, p_me_id=' || p_me_id);
        END IF;

        SELECT me_st, dic_name, me_tp
          INTO l_prev_st, l_prev_st_name, l_me_tp
          FROM mass_exchanges
               JOIN uss_ndi.v_ddn_me_st st ON (st.dic_value = me_st)
         WHERE me_id = p_me_id;

        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (
                'make_exchange_file, l_prev_st=' || l_prev_st);
        END IF;

        IF l_prev_st = c_st_ME_Exists
        THEN
            UPDATE mass_exchanges
               SET me_st = c_st_ME_File
             WHERE me_id = p_me_id;

            write_me_log (p_mel_me        => p_me_id,
                          p_mel_st        => c_st_ME_File,
                          p_mel_message   => 'Почато формування файлу обміну',
                          p_mel_st_old    => l_prev_st);
            COMMIT;
            l_sql :=
                   'begin uss_esr.api$mass_exchange.create_file_F01_job(p_me_id => '
                || p_me_id
                || '); end;';

            -- IC #98164
            IF l_me_tp IN ('UN',
                           'UNP',
                           'UN_R',
                           'UNP_R',
                           'UN_RR',
                           'UNP_RR',
                           'UN_306',
                           'UNP_306')
            THEN
                l_sql :=
                       'begin uss_esr.api$mass_exchange.create_file_MSP2WFP_job(p_me_id => '
                    || p_me_id
                    || '); commit; end;';
            ELSIF l_me_tp = 'CZ'
            THEN
                l_sql :=
                       'begin uss_esr.api$mass_exchange_dcz.Create_File_Request_Job(p_me_id => '
                    || p_me_id
                    || '); end;';
            ELSIF l_me_tp = 'DPS'
            THEN
                l_sql :=
                       'begin uss_esr.api$mass_exchange_dps.Create_File_Request_Job(p_me_id => '
                    || p_me_id
                    || '); end;';
            ELSIF l_me_tp = 'UNI'
            THEN
                l_sql :=
                       'begin uss_esr.api$mass_exchange_uni.Create_File_Request_Job(p_me_id => '
                    || p_me_id
                    || '); end;';
            END IF;

            TOOLS.SubmitSchedule (p_jb       => p_jb_id,
                                  p_subsys   => 'USS_ESR',
                                  p_wjt      => 'ME_FILE_CREATION',
                                  p_what     => l_sql);
        ELSIF l_prev_st = c_st_ME_Received
        THEN
            UPDATE mass_exchanges
               SET me_st = c_st_ME_File
             WHERE me_id = p_me_id;

            write_me_log (
                p_mel_me        => p_me_id,
                p_mel_st        => c_st_ME_File,
                p_mel_message   => 'Почато формування файлу обміну C01',
                p_mel_st_old    => l_prev_st);
            COMMIT;
            TOOLS.SubmitSchedule (
                p_jb       => p_jb_id,
                p_subsys   => 'USS_ESR',
                p_wjt      => 'ME_FILE_CREATION',
                p_what     =>
                       'begin uss_esr.api$mass_exchange.create_file_C01_job(p_me_id => '
                    || p_me_id
                    || '); end;');
        ELSIF l_prev_st = c_st_ME_File
        THEN
            raise_application_error (
                -20000,
                'Пакет у статусі "Формується файл обміну". Якщо пакет перебуває у цьому стані тривалий час - зверніться до адміністратора системи.');
        ELSE
            raise_application_error (
                -20000,
                   'Неможливо формувати файл з пакета у статусі обміну "'
                || l_prev_st_name
                || '"!');
        END IF;

        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (
                'make_exchange_file, p_jb_id=' || p_jb_id);
        END IF;

        UPDATE mass_exchanges
           SET me_jb = p_jb_id
         WHERE me_id = p_me_id;

        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg ('make_exchange_file, END');
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            IF g_debug_pipe
            THEN
                ikis_sysweb.ikis_debug_pipe.WriteMsg (
                    'make_exchange_file, EXCEPTION');
            END IF;

            UPDATE mass_exchanges
               SET me_st = l_prev_st
             WHERE me_id = p_me_id;

            write_me_log (
                p_mel_me        => p_me_id,
                p_mel_st        => l_prev_st,
                p_mel_message   => 'Помилка формування файлу обміну',
                p_mel_st_old    => c_st_ME_File);
            COMMIT;
            RAISE;
    --raise_application_error(-20000, 'Помилка формування файлу.' || chr(10) || SQLERRM);
    END;

    -- #92025  17/10/2023 serhii: розділив make_exchange_file_job на 2 окремі процедури.
    -- Для "даних допомог":
    PROCEDURE create_file_F01_job (p_me_id mass_exchanges.me_id%TYPE)
    IS
        l_filter     VARCHAR2 (250);
        l_filename   VARCHAR2 (250);
        l_zip_name   VARCHAR2 (250);
        l_ecs        exchcreatesession.ecs_id%TYPE;
        l_ef         exchangefiles.ef_id%TYPE;
        l_pkt        exchangefiles.ef_pkt%TYPE;
        l_cnt        PLS_INTEGER;
        l_com_wu     NUMBER := TOOLS.GetCurrWu;
        l_me_count   PLS_INTEGER;
        l_rec        NUMBER := 20;
        l_sql        VARCHAR2 (32000);
        l_csv_blob   BLOB;
        l_zip_blob   BLOB;
        l_vis_clob   CLOB;
    BEGIN
        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (
                'create_file_F01_job, p_me_id=' || p_me_id);
        END IF;

        SELECT m.me_count
          INTO l_me_count
          FROM mass_exchanges m
         WHERE m.me_id = p_me_id;

        -- захист від дублювання файлів
        l_filter := 'ME#' || p_me_id || '#F01';

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

        l_sql := 'select
to_number(MEMR_ID_FAM) as ID_FAM,
to_char(MEMR_REP_PERIOD, ''MM.YYYY'') as REP_PERIOD,
to_char(MEMR_CALC_PERIOD, ''MM.YYYY'') as CALC_PERIOD,
MEMR_N_ID as N_ID,
MEMR_SURNAME as SURNAME,
MEMR_NAME as NAME,
MEMR_PATRONYMIC as PATRONYMIC,
trunc(MEMR_BDATE) as BDATE,
MEMR_DOCTYPE as DOCTYPE,
MEMR_SERIES as SERIES,
MEMR_NUMB as NUMB,
trunc(MEMR_DOCDATE) as DOCDATE,
MEMR_UNZR as UNZR,
to_number(MEMR_GENDER) as GENDER,
MEMR_CITIZENSHIP as CITIZENSHIP,
MEMR_R_ADDRESS as R_ADDRESS,
MEMR_R_INDEX as R_INDEX,
MEMR_R_CATOTTG as R_CATOTTG,
MEMR_R_TYPEV as R_TYPEV,
MEMR_R_NAMEV as R_NAMEV,
MEMR_R_NUMB as R_NUMB,
MEMR_R_NUMK as R_NUMK,
MEMR_R_NUMA as R_NUMA,
MEMR_F_ADDRESS as F_ADDRESS,
MEMR_F_INDEX as F_INDEX,
MEMR_F_CATOTTG as F_CATOTTG,
MEMR_F_TYPEV as F_TYPEV,
MEMR_F_NAMEV as F_NAMEV,
MEMR_F_NUMB as F_NUMB,
MEMR_F_NUMK as F_NUMK,
MEMR_F_NUMA as F_NUMA,
MEMR_FAM_RELAT as FAM_RELAT,
trunc(MEMR_D_FROM) as D_FROM,
trunc(MEMR_D_TILL) as D_TILL,
trunc(MEMR_D_APP) as D_APP,
MEMR_DIS_GROUP as DIS_GROUP,
MEMR_DIS_REASON as DIS_REASON,
MEMR_DOC_INV as DOC_INV,
trunc(memr_d_inv) as D_INV,
trunc(MEMR_DIS_BEGIN) as DIS_BEGIN,
trunc(MEMR_DIS_START) as DIS_START,
trunc(MEMR_DIS_END) as DIS_END,
MEMR_KFN as KFN,
MEMR_P_SUMMD as P_SUMMD,
MEMR_N_SUMMD as N_SUMMD,
MEMR_V_SUMMD as V_SUMMD,
MEMR_SIZE_SMF as SIZE_SMF,
MEMR_N_DOV as N_DOV,
trunc(MEMR_D_GIVE) as D_GIVE,
MEMR_OZN_FAM as OZN_FAM,
MEMR_OZN_OTR as OZN_OTR,
MEMR_OZN_AGENT as OZN_AGENT
from me_minfin_request_rows r
where r.memr_st = ''' || c_st_MEMR_Exists || ''' and r.memr_me = ' || p_me_id; -- 15/07/2024 serhii: chaged by #105323

        -- формуємо csv
        build_csv (p_sql => l_sql, p_csv_blob => l_csv_blob);

        IF l_csv_blob IS NULL OR DBMS_LOB.getlength (l_csv_blob) < 100
        THEN
            raise_application_error (
                -20000,
                'Помилка формування файлу обміну - файл порожній!');
        END IF;

        -- Ім’я файлів інформаційного обміну формується за такими масками EISKKKZNNDDMMYYYY.CSV
        l_filename :=
               'EIS'
            || 'F01'
            || '1'
            || '01'
            || TO_CHAR (SYSDATE, 'DDMMYYYY')
            || '.CSV';
        -- Ім’я архівного файлу формується за маскою VVV2OOODDMMYYYY.zip, де...
        l_zip_name := 'EIS2MFU' || TO_CHAR (SYSDATE, 'DDMMYYYY') || '.zip';

        l_zip_blob :=
            tools.toZip2 (p_file_blob => l_csv_blob, p_file_name => l_filename);

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
                     'F01',
                     l_zip_name,
                     l_zip_blob,
                     l_vis_clob,
                     NULL,
                     'EISF01',
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
            ikis_sysweb.ikis_debug_pipe.WriteMsg (
                'create_file_F01_job, ef_ecs=' || l_ecs);
        END IF;

        -- формування пакета ПЕОД. тип визначається по ef_main_tag_name
        ikis_rbm.RDM$APP_EXCHANGE.GenPaketsFromTMPTable;

        SELECT ef_pkt
          INTO l_pkt
          FROM ikis_rbm.tmp_exchangefiles_m1
         WHERE ef_id = l_ef;

        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (
                'create_file_F01_job, ef_pkt=' || l_pkt);
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
           SET me_pkt = l_pkt, me_st = c_st_ME_Sent
         WHERE me_id = p_me_id AND me_pkt IS NULL;

        -- serhii: ^ me_pkt ^ повинен містити Ід файла з данними допомг, що відправлений в ПЕОД. Не можна його перезаписувати
        write_me_log (
            p_mel_me        => p_me_id,
            p_mel_st        => c_st_ME_Sent,
            p_mel_message   => 'Завершено формування файлу обміну F01',
            p_mel_st_old    => c_st_ME_File);

        -- прописуємо ід файла обміну в таблицю рядків
        UPDATE me_minfin_request_rows
           SET memr_ef = l_ef, memr_st = c_st_MEMR_Sent
         WHERE memr_me = p_me_id AND memr_st = c_st_MEMR_Exists; -- 06/09/2024 serhii: fix #108001

        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (
                'create_file_F01_job END, p_me_id=' || p_me_id);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            IF g_debug_pipe
            THEN
                ikis_sysweb.ikis_debug_pipe.WriteMsg (
                    'create_file_F01_job, EXCEPTION:' || CHR (10) || SQLERRM);
            END IF;

            ROLLBACK;

            UPDATE mass_exchanges
               SET me_st = c_st_ME_Exists
             WHERE me_id = p_me_id;

            write_me_log (
                p_mel_me        => p_me_id,
                p_mel_st        => c_st_ME_Exists,
                p_mel_message   => 'Помилка формування файлу обміну',
                p_mel_st_old    => c_st_ME_File);
            COMMIT;
            RAISE;
    END;

    -- IC #97937
    -- Формування файла вивантаження по умовам запиту ВПП ООН
    PROCEDURE create_file_MSP2WFP_job (p_me_id mass_exchanges.me_id%TYPE)
    IS
        l_filter     VARCHAR2 (250);
        l_filename   VARCHAR2 (250);
        l_fname      VARCHAR2 (250);
        l_fmask      VARCHAR2 (16);
        l_zip_name   VARCHAR2 (250);
        l_ecs        exchcreatesession.ecs_id%TYPE;
        l_ef         exchangefiles.ef_id%TYPE;
        l_pkt        exchangefiles.ef_pkt%TYPE;
        l_cnt        PLS_INTEGER;
        l_com_wu     NUMBER := TOOLS.GetCurrWu;
        l_me_count   PLS_INTEGER;
        l_rec        NUMBER := 160;                         -- ВПП ООН в ЄІССС
        l_sql        VARCHAR2 (32000);
        l_csv_blob   BLOB;
        l_zip_blob   BLOB;
        l_vis_clob   CLOB;
        l_part       NUMBER := 100000;
        l_part_cnt   NUMBER;
        l_pr_files   ikis_sysweb.tbl_some_files
                         := ikis_sysweb.tbl_some_files ();
        l_me_r       NUMBER;
    BEGIN
        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (
                'create_file_MSP2WFP_job, p_me_id=' || p_me_id);
        END IF;

        -- захист від дублювання файлів
        l_filter := 'ME#' || p_me_id || '#MSP2WFP';

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

        SELECT m.me_count,
               CEIL (m.me_count / l_part), -- IC #99073 Для вивантаження по ВПП ООН зробити формування файлу з розподілом по 100K рядків
                  'MSP2WFP_DSD3250_'
               || CASE WHEN m.me_tp LIKE 'UNP%' THEN 'P' ELSE 'B' END
               || 'ICC'
               || TO_CHAR (m.me_month, 'yymm')
               || '_'
               || TO_CHAR (LEAST (LAST_DAY (m.me_month), SYSDATE),
                           'yyyymmdd')                                  fname,
               'ICC' || TO_CHAR (m.me_month, 'yymm')                    fmask,
               (SELECT MAX (a.me_id) -- IC #108025 Зробити вивантаження з доплат по ВПП ООН лише по особам, по яким змінилися дані (хоч які)
                  FROM mass_exchanges a
                 WHERE     a.me_tp =
                           CASE m.me_tp
                               WHEN 'UN_R' THEN 'UN'
                               WHEN 'UNP_R' THEN 'UNP'
                           END
                       AND a.me_st != 'D'
                       AND a.me_month = ADD_MONTHS (m.me_month, -6))    me_r
          INTO l_me_count,
               l_part_cnt,
               l_fname,
               l_fmask,
               l_me_r
          FROM mass_exchanges m
         WHERE m.me_id = p_me_id;

        l_zip_name := l_fname || '.zip';

        FOR i IN 1 .. l_part_cnt
        LOOP
            DELETE FROM tmp_work_set1
                  WHERE 1 = 1;

            INSERT INTO tmp_work_set1 (x_id1)
                  SELECT mvrr_id
                    FROM me_vppun_request_rows r
                   WHERE     r.mvrr_me = p_me_id
                         AND NOT EXISTS
                                 (SELECT 1
                                    FROM me_vppun_request_rows rr
                                   WHERE     rr.mvrr_me = l_me_r
                                         AND rr.mvrr_pc = r.mvrr_pc
                                         AND rr.mvrr_id_fam = r.mvrr_id_fam
                                         AND NVL (rr.mvrr_surname, '0') =
                                             NVL (r.mvrr_surname, '0')
                                         AND NVL (rr.mvrr_name, '0') =
                                             NVL (r.mvrr_name, '0')
                                         AND NVL (rr.mvrr_patronymic, '0') =
                                             NVL (r.mvrr_patronymic, '0')
                                         AND NVL (rr.mvrr_bdate, '0') =
                                             NVL (r.mvrr_bdate, '0')
                                         AND NVL (rr.mvrr_n_id, '0') =
                                             NVL (r.mvrr_n_id, '0')
                                         AND NVL (rr.mvrr_passport, '0') =
                                             NVL (r.mvrr_passport, '0')
                                         AND NVL (rr.mvrr_gender, '0') =
                                             NVL (r.mvrr_gender, '0')
                                         --and nvl(rr.mvrr_region,'0') = nvl(r.mvrr_region,'0')
                                         AND NVL (rr.mvrr_ratu, '0') =
                                             NVL (r.mvrr_ratu, '0')
                                         --and nvl(rr.mvrr_district,'0') = nvl(r.mvrr_district,'0')
                                         AND NVL (rr.mvrr_pindex, '0') =
                                             NVL (r.mvrr_pindex, '0')
                                         AND NVL (rr.mvrr_pindexname, '0') =
                                             NVL (r.mvrr_pindexname, '0')
                                         AND NVL (rr.mvrr_address, '0') =
                                             NVL (r.mvrr_address, '0')
                                         AND NVL (rr.mvrr_iban, '0') =
                                             NVL (r.mvrr_iban, '0'))
                ORDER BY r.mvrr_id
                  OFFSET (i - 1) * l_part ROWS
                   FETCH NEXT l_part ROWS ONLY;

            l_me_count := SQL%ROWCOUNT;
            EXIT WHEN l_me_count = 0;

            l_sql := '
    select  mvrr_icc_registry   ICC_REGISTRY,
            mvrr_id_fam         ID_FAM,
            mvrr_surname        SURNAME,
            mvrr_name           NAME,
            mvrr_patronymic     PATRONYMIC,
            mvrr_bdate          BDATE,
            mvrr_n_id           N_ID,
            mvrr_passport       PASSPORT,
            mvrr_gender         GENDER,
            mvrr_category       CATEGORY,
            mvrr_amount         AMOUNT,
            mvrr_phone          PHONE,
            mvrr_region         REGION,
            mvrr_ratu           RATU,
            mvrr_district       DISTRICT,
            mvrr_pindex         PINDEX,
            mvrr_pindexname     PINDEXNAME,
            mvrr_address        ADDRESS,
            mvrr_iban           IBAN
        from me_vppun_request_rows r,
            tmp_work_set1 s
        where r.mvrr_id = s.x_id1';

            -- формуємо csv
            build_csv (p_sql => l_sql, p_csv_blob => l_csv_blob, p_rtrim => ';');

            IF l_csv_blob IS NULL OR DBMS_LOB.getlength (l_csv_blob) < 100
            THEN
                raise_application_error (
                    -20000,
                    'Помилка формування файлу обміну - файл порожній!');
            END IF;

            -- IC #99073 при цьому назва файлу повинна змінитися - у блоці "BICC2402" змінюємо на "BICC2402-0Х"
            IF l_part_cnt > 1
            THEN
                l_filename :=
                    REPLACE (l_fname,
                             l_fmask,
                             l_fmask || '-' || LPAD (i, 2, '0'));
            ELSE
                l_filename := l_fname;
            END IF;

            DBMS_OUTPUT.put_line ('l_filename: ' || l_filename);

            l_filename := l_filename || '.csv';
            l_pr_files.EXTEND;
            l_pr_files (l_pr_files.LAST) :=
                ikis_sysweb.t_some_file_info (l_filename, l_csv_blob);

            l_vis_clob :=
                   l_vis_clob
                || CASE WHEN i > 1 THEN '<br>' ELSE '' END
                || 'Файл '
                || l_filename
                || '<br>'
                || 'за даними державних допомог Єдиної інформаційної системи соціальної сфери Міністерства соціальної політики України'
                || '<br>'
                || 'Кількість рядків: '
                || l_me_count;
        END LOOP;

        IF l_pr_files.COUNT > 0
        THEN
            l_zip_blob :=
                ikis_sysweb.ikis_web_jutil.getZipFromStrms (l_pr_files);
        ELSE
            RAISE NO_DATA_FOUND;
        END IF;

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
                     'MSP2WFP',
                     l_zip_name,
                     l_zip_blob,
                     l_vis_clob,
                     NULL,
                     'EISMSP2WFP',
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
        DELETE FROM ikis_rbm.tmp_exchangefiles_m1
              WHERE 1 = 1;

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
             WHERE ef_id = l_ef;

        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (
                'create_file_MSP2WFP_job, l_ef=' || l_ef);
        END IF;

        -- формування пакета ПЕОД. тип визначається по ef_main_tag_name
        -- Тут потрібно допиляти функціонал в ikis_rbm
        ikis_rbm.RDM$APP_EXCHANGE.GenPaketsFromTMPTable;

        SELECT ef_pkt
          INTO l_pkt
          FROM ikis_rbm.tmp_exchangefiles_m1
         WHERE ef_id = l_ef;

        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (
                'create_file_MSP2WFP_job, ef_pkt=' || l_pkt);
        END IF;

        UPDATE exchangefiles f
           SET ef_pkt = l_pkt
         WHERE ef_id = l_ef;

        -- прописуємо ід файла обміну в таблицю рядків
        UPDATE me_vppun_request_rows r
           SET mvrr_ef = l_ef, mvrr_st = c_st_MEMR_Sent
         WHERE mvrr_me = p_me_id;

        UPDATE exchcreatesession
           SET ecs_stop_dt = SYSDATE
         WHERE ecs_id = l_ecs;

        -- зміна статусів на етапі А0.1    "Формування файлу для поточної верифікації"
        -- прописуємо ід пакета в таблицю обміну
        UPDATE mass_exchanges m
           SET me_pkt = l_pkt, me_st = c_st_ME_Sent
         WHERE me_id = p_me_id AND me_pkt IS NULL;

        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (
                'create_file_MSP2WFP_job END, p_me_id=' || p_me_id);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            IF g_debug_pipe
            THEN
                ikis_sysweb.ikis_debug_pipe.WriteMsg (
                       'create_file_MSP2WFP_job, EXCEPTION:'
                    || CHR (10)
                    || SQLERRM);
            END IF;

            ROLLBACK;

            UPDATE mass_exchanges
               SET me_st = c_st_ME_Exists
             WHERE me_id = p_me_id;

            COMMIT;
            RAISE;
    END create_file_MSP2WFP_job;

    -- #92025  17/10/2023 serhii: розділив make_exchange_file_job на 2 окремі процедури.
    -- Для "відпрацюваннь":
    PROCEDURE create_file_C01_job (p_me_id mass_exchanges.me_id%TYPE)
    IS
        l_filter      VARCHAR2 (250);
        l_filename    VARCHAR2 (250);
        l_zip_name    VARCHAR2 (250);
        l_ecs         exchcreatesession.ecs_id%TYPE;
        l_ef          exchangefiles.ef_id%TYPE;
        l_pkt         exchangefiles.ef_pkt%TYPE;
        l_pkt_par     exchangefiles.ef_pkt%TYPE;
        l_cnt         PLS_INTEGER;
        l_com_wu      NUMBER := TOOLS.GetCurrWu;
        l_me_count    NUMBER;
        l_rec         NUMBER := 20;
        l_sql         VARCHAR2 (32000);
        l_csv_blob    BLOB;
        l_zip_blob    BLOB;
        l_vis_clob    CLOB;
        l_me_st_new   mass_exchanges.me_st%TYPE;
    BEGIN
        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (
                'create_file_C01_job, p_me_id=' || p_me_id);
        END IF;

        -- 24/05/2024 serhii: набір відпрацюваннь що підлягає вивантаженню:
        INSERT INTO tmp_work_set1 (x_id1, x_id2, x_id3)
            SELECT mesr_id, merc_id, memr_id
              FROM me_minfin_result_rows
                   INNER JOIN me_minfin_recomm_rows
                       ON     merc_id = mesr_merc
                          AND merc_st = c_st_MERC_Processed
                   INNER JOIN me_minfin_request_rows
                       ON     memr_id = merc_memr
                          -- serhii: #92025-33 включаються тільки рішення, що належать до відпрацьованих рядків
                          AND memr_st = c_st_MEMR_Processed
             WHERE     mesr_me = p_me_id
                   AND mesr_st = c_st_MESR_Confirmed
                   AND mesr_id_rec IS NOT NULL
                   AND mesr_id_fam IS NOT NULL
                   AND mesr_ris_code IS NOT NULL
                   AND mesr_klcom_coddec IS NOT NULL
                   AND mesr_res_date IS NOT NULL
                   AND mesr_type_rec IS NOT NULL
                   AND mesr_rec_code IS NOT NULL
                   AND mesr_rec_date IS NOT NULL;

        l_cnt := SQL%ROWCOUNT;

        IF l_cnt = 0
        THEN
            raise_application_error (
                -20000,
                'Не знайдено нових відпрацюваннь для передачі!');
        ELSE
            l_me_count := l_cnt;                                    -- #104305
        END IF;

        -- захист від дублювання файлів
        l_filter :=
            'ME#' || p_me_id || '#C01#' || TO_CHAR (SYSDATE, 'YYYY-MM'); -- serhii: формується раз на місяць?

        SELECT COUNT (1)
          INTO l_cnt
          FROM exchcreatesession
         WHERE ecs_filter = l_filter;

        IF l_cnt > 0
        THEN
            NULL;                                  -- #92025-22 немає обмежень
        --raise_application_error(-20000, 'Створення файлів з даними параметрами вже виконувалось!');
        END IF;

        -- реєструємо сесію формування файлів обміну
        INSERT INTO exchcreatesession (ecs_id, ecs_start_dt, ecs_filter)
             VALUES (0, SYSDATE, l_filter)
          RETURNING ecs_id
               INTO l_ecs;

        -- serhii: #92025-33 включаються тільки рішення, що належать до відпрацьованих рядків
        l_sql := 'SELECT
  to_number(mesr_id_rec) as id_rec,
  to_number(mesr_id_fam) as id_fam,
  mesr_ris_code as ris_code,
  mesr_klcom_coddec as klcom_coddec,
  mesr_res_date as res_date,
  to_number(mesr_summ_p) as summ_p,
  mesr_res_start as res_start,
  mesr_res_end as res_end,
  mesr_content_rec as content_rec,
  to_number(mesr_type_rec) as type_rec,
  to_number(mesr_rec_code) as rec_code,
  mesr_rec_date as rec_date
FROM me_minfin_result_rows
WHERE mesr_id IN(SELECT x_id1 FROM tmp_work_set1)';

        -- формуємо csv
        build_csv (p_sql => l_sql, p_csv_blob => l_csv_blob);

        IF l_csv_blob IS NULL OR DBMS_LOB.getlength (l_csv_blob) < 100
        THEN
            raise_application_error (
                -20000,
                'Помилка формування файлу обміну - файл порожній!');
        END IF;

        -- Ім’я файлів інформаційного обміну формується за такими масками EISKKKZNNDDMMYYYY.CSV
        l_filename :=
               'EIS'
            || 'C01'
            || '1'
            || '01'
            || TO_CHAR (SYSDATE, 'DDMMYYYY')
            || '.CSV';
        -- Ім’я архівного файлу формується за маскою VVV2OOODDMMYYYY.zip, де...
        l_zip_name := 'EIS2MFU' || TO_CHAR (SYSDATE, 'DDMMYYYY') || '.zip';

        l_zip_blob :=
            tools.toZip2 (p_file_blob => l_csv_blob, p_file_name => l_filename);

        l_vis_clob :=
               'Файл '
            || l_filename
            || '<br>'
            || 'щодо опрацювання рекомендацій та прийнятих рішень за результатами верифікації державних допомог.'
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
                     'C01',
                     l_zip_name,
                     l_zip_blob,
                     l_vis_clob,
                     NULL,
                     'EISC01',
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
            ikis_sysweb.ikis_debug_pipe.WriteMsg (
                'create_file_C01_job, ef_ecs=' || l_ecs);
        END IF;

        -- формування пакета ПЕОД. тип визначається по ef_main_tag_name
        ikis_rbm.RDM$APP_EXCHANGE.GenPaketsFromTMPTable;

        SELECT ef_pkt
          INTO l_pkt
          FROM ikis_rbm.tmp_exchangefiles_m1
         WHERE ef_id = l_ef;

        SELECT me_pkt
          INTO l_pkt_par
          FROM mass_exchanges
         WHERE me_id = p_me_id;

        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (
                   'create_file_C01_job, ef_pkt='
                || l_pkt
                || ',  par_pkt='
                || l_pkt_par);
        END IF;

        ikis_rbm.Rdm$packet.Insert_Packet_Link (p_Pkt_Prev   => l_pkt_par,
                                                p_Pkt_Id     => l_pkt);

        UPDATE exchangefiles f
           SET ef_pkt = l_pkt
         WHERE ef_id = l_ef;

        UPDATE exchcreatesession
           SET ecs_stop_dt = SYSDATE
         WHERE ecs_id = l_ecs;

        -- зміна статусів на етапі А0.11 "Формування файлу опрацювання рекомендацій"
        UPDATE me_minfin_result_rows
           SET mesr_st = c_st_MESR_Sent, mesr_ef = l_ef
         WHERE mesr_id IN (SELECT x_id1 FROM tmp_work_set1);

        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (
                   'create_file_C01_job, update me_minfin_result_rows:'
                || SQL%ROWCOUNT);
        END IF;

        UPDATE me_minfin_recomm_rows
           SET merc_st = c_st_MERC_Sent
         WHERE merc_id IN (SELECT x_id2 FROM tmp_work_set1);

        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (
                   'create_file_C01_job, update me_minfin_recomm_rows:'
                || SQL%ROWCOUNT);
        END IF;

        -- якщо всі невідповідності відпрацьовані/передані, то => P:Передано
        UPDATE me_minfin_request_rows
           SET memr_st = c_st_MEMR_Sent
         WHERE memr_id IN
                   (SELECT x_id3
                      FROM tmp_work_set1
                     -- крім тих, по яким лишились невідпрацьовані рекомендації:
                     WHERE NOT EXISTS
                               (SELECT *
                                  FROM me_minfin_recomm_rows
                                 WHERE     merc_memr = x_id3
                                       AND NVL (merc_st, c_st_MERC_Received) =
                                           c_st_MERC_Received));

        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (
                   'create_file_C01_job, update me_minfin_request_rows:'
                || SQL%ROWCOUNT);
        END IF;

        -- якщо є отримані або відпрацьовані (не передані), то повертаєм в "Отримано рекомендації"
        -- , інакше => V:Рекомендації відпрацьовано
        SELECT COUNT (*)
          INTO l_cnt
          FROM me_minfin_request_rows
         WHERE memr_me = p_me_id AND NVL (memr_st, 'xxx') != c_st_MEMR_Sent;

        IF l_cnt > 0
        THEN
            l_me_st_new := c_st_ME_Received;
        ELSE
            l_me_st_new := c_st_ME_Processed;
        END IF;

        UPDATE mass_exchanges
           SET me_st = l_me_st_new
         WHERE me_id = p_me_id;

        write_me_log (
            p_mel_me        => p_me_id,
            p_mel_st        => l_me_st_new,
            p_mel_message   => 'Завершено формування файлу обміну C01',
            p_mel_st_old    => c_st_ME_File);

        IF g_debug_pipe
        THEN
            ikis_sysweb.ikis_debug_pipe.WriteMsg (
                'create_file_C01_job END, p_me_id=' || p_me_id);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            IF g_debug_pipe
            THEN
                ikis_sysweb.ikis_debug_pipe.WriteMsg (
                    'create_file_C01_job, EXCEPTION:' || CHR (10) || SQLERRM);
            END IF;

            ROLLBACK;

            UPDATE mass_exchanges
               SET me_st = c_st_ME_Received
             WHERE me_id = p_me_id;

            write_me_log (
                p_mel_me        => p_me_id,
                p_mel_st        => c_st_ME_Received,
                p_mel_message   => 'Помилка формування файлу обміну',
                p_mel_st_old    => c_st_ME_File);
            COMMIT;
            RAISE;
    END;

    --Скасувати пакет
    PROCEDURE reject_packet (p_me_id mass_exchanges.me_id%TYPE)
    IS
        l_me_tp   mass_exchanges.me_tp%TYPE;
        l_org     NUMBER := NVL (tools.GetCurrOrg, 50001);
    BEGIN
           UPDATE mass_exchanges m
              SET m.me_st = c_st_me_cancelled
            WHERE     m.me_id = p_me_id
                  AND m.me_pkt IS NULL
                  AND NVL (m.com_org, 50001) = l_org
        RETURNING me_tp
             INTO l_me_tp;

        IF SQL%ROWCOUNT > 0
        THEN
            write_me_log (p_mel_me        => p_me_id,
                          p_mel_st        => c_st_ME_Cancelled,
                          p_mel_message   => 'Пакет скасовано',
                          p_mel_st_old    => c_st_ME_Exists);

            -- IC #109475 Для формування ЄСВ повністю видаляємо рядки вивантаження
            IF l_me_tp = 'ESV'
            THEN
                DELETE FROM me_esv_unload_rows
                      WHERE meur_me = p_me_id;
            END IF;
        END IF;
    END;

    -- IC #109475 Оновити статус пакета
    PROCEDURE setPacketSt (p_me_id   IN NUMBER,
                           p_me_st   IN mass_exchanges.me_st%TYPE)
    IS
        l_me_tp   mass_exchanges.me_tp%TYPE;
    BEGIN
           -- E Створено
           -- R Зафіксовано (Готовий до передачі)
           -- D Видалено
           UPDATE mass_exchanges m
              SET m.me_st = p_me_st
            WHERE m.me_id = p_me_id
        RETURNING me_tp
             INTO l_me_tp;

        IF SQL%ROWCOUNT > 0
        THEN
            write_me_log (p_mel_me        => p_me_id,
                          p_mel_st        => p_me_st,
                          p_mel_message   => 'Оновлено статус пакета',
                          p_mel_st_old    => c_st_ME_Exists);

            -- IC #109475 Для формування ЄСВ повністю видаляємо рядки вивантаження
            IF l_me_tp = 'ESV' AND p_me_st = 'D'
            THEN
                DELETE FROM me_esv_unload_rows
                      WHERE meur_me = p_me_id;
            END IF;
        END IF;
    END;

    -- обробка квитанцій.  по результатах формуємо html-таблицю і записуємо в pc_visual_data для відображення.
    -- p_pkt_id - ід пакета ПЕОД
    PROCEDURE proc_me_kv (p_pkt_id ikis_rbm.v_packet.pkt_id%TYPE)
    IS
        l_zip_blob    ikis_rbm.v_packet_content.pc_data%TYPE;
        l_clob        ikis_rbm.v_packet_content.pc_visual_data%TYPE;
        l_pc_name     ikis_rbm.v_packet_content.pc_name%TYPE;
        l_com_wu      NUMBER := tools.GetCurrWu;
        l_file_name   VARCHAR2 (250);
        l_file_blob   BLOB;
    BEGIN
        SELECT pc_data, UTL_COMPRESS.lz_uncompress (pc_data), UPPER (pc_name)
          INTO l_zip_blob, l_clob, l_pc_name
          FROM ikis_rbm.v_packet  p
               JOIN ikis_rbm.v_packet_content c ON pc_pkt = pkt_id
         WHERE pkt_id = p_pkt_id AND pkt_St = 'N' AND pkt_pat IN (112, 116); -- mfu_vrf_kv / mfu_vrf_kv2

        -- згідно документації на вхід маємо zip архів з csv-файлом
        BEGIN
            tools.unZip2 (p_zip_blob    => l_zip_blob,
                          p_file_blob   => l_file_blob,
                          p_file_name   => l_file_name);
            l_clob := tools.ConvertB2C (l_file_blob);
            l_pc_name := l_file_name;
        EXCEPTION
            WHEN OTHERS
            THEN -- не вдалося розархувувати як zip - працюємо далі з l_clob ???
                NULL;
        END;

        IF SUBSTR (l_pc_name, -4) != '.CSV'
        THEN
            l_pc_name := l_pc_name || '.CSV';
        END IF;

        l_clob :=
            convert_csv2html (p_csv_clob => l_clob, p_file_name => l_pc_name);

        ikis_rbm.RDM$APP_EXCHANGE.set_visual_data (p_pkt_id        => p_pkt_id,
                                                   p_visual_data   => l_clob);

        ikis_rbm.rdm$packet.Set_Packet_State (p_Pkt_Id          => p_pkt_id,
                                              p_Pkt_St          => 'PRC',
                                              p_Pkt_Change_Wu   => l_com_wu,
                                              p_Pkt_Change_Dt   => SYSDATE);
    END;


    -- 4. Результатом завантаженого файлу рекомендацій (Додаток 3) є записи в таблиці me_minfin_recomm_rows у відповідному статусі (Отримано).
    -- + формуємо html-таблицю і записуємо в pc_visual_data для відображення.
    -- p_pkt_id - ід пакета ПЕОД
    -- Файл Рекомендації повинен завантажуватися через картку пакета відповідного запиту!!!!
    -- Ім’я квитанції повинно збігатися з іменем інформаційного повідомлення, яке оброблялося, та мати розширення «.cvt».
    PROCEDURE proc_me_recom (p_pkt_id ikis_rbm.v_packet.pkt_id%TYPE)
    IS
        l_zip_blob     ikis_rbm.v_packet_content.pc_data%TYPE;
        l_clob         CLOB;
        l_pc_name      ikis_rbm.v_packet_content.pc_name%TYPE;
        l_com_wu       NUMBER := tools.GetCurrWu;
        l_me_id        NUMBER;
        l_ef_id        NUMBER;
        l_ecs          NUMBER;
        l_rec          NUMBER := 20;
        l_ef           NUMBER;
        l_file_name    VARCHAR2 (250);
        l_file_blob    BLOB;
        l_csv_blob     BLOB;
        l_vis_clob     ikis_rbm.v_packet_content.pc_visual_data%TYPE;
        l_lines_cnt    NUMBER;
        l_orphan_cnt   NUMBER;
        l_coment       VARCHAR2 (4000);
        l_cvt_pkt      ikis_rbm.v_packet.pkt_id%TYPE;
        l_cnt          PLS_INTEGER;
        l_me_st        mass_exchanges.me_st%TYPE;
    BEGIN
        SELECT pc_data, /*tools.ConvertB2C(utl_compress.lz_uncompress(pc_data)),*/
                        UPPER (pc_name)
          INTO l_zip_blob,                                         /*l_clob,*/
                           l_pc_name
          FROM ikis_rbm.v_packet  p
               JOIN ikis_rbm.v_packet_content c ON pc_pkt = pkt_id
         WHERE pkt_id = p_pkt_id AND pkt_St = 'N' AND pkt_pat IN (113); -- 113 = mfu_vrf_rec = Файл рекомендацій за результатами верифікації державних допомог

        -- згідно документації на вхід маємо zip архів з csv-файлом
        BEGIN
            tools.unZip2 (p_zip_blob    => l_zip_blob,
                          p_file_blob   => l_file_blob,
                          p_file_name   => l_file_name);
            l_clob := tools.ConvertB2C (l_file_blob);
            l_pc_name := l_file_name;
        EXCEPTION
            WHEN OTHERS
            THEN
                Raise_application_error (
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

        IF UPPER (SUBSTR (l_pc_name, -4)) != '.CSV'
        THEN
            l_pc_name := l_pc_name || '.CSV';
        END IF;

        SELECT m.me_id, m.me_st
          INTO l_me_id, l_me_st
          FROM ikis_rbm.v_packet_links  x
               JOIN mass_exchanges m ON m.me_pkt = x.pl_pkt_out
         WHERE x.pl_pkt_in = p_pkt_id;

        INSERT INTO me_minfin_recomm_rows (merc_id,
                                           merc_me,
                                           merc_memr,
                                           merc_ef,
                                           merc_id_rec,
                                           merc_id_fam,
                                           merc_type_pref,
                                           merc_type_rec,
                                           merc_org,
                                           merc_date_err,
                                           merc_content,
                                           merc_st)
            SELECT NULL,
                   l_me_id,
                   NULL,
                   NULL,
                   COL001                             AS ID_REC, --  Ідентифікатор рекомендації
                   COL002                             AS ID_FAM, --  Ідентифікатор особи
                   TO_NUMBER (COL003)                 AS TYPE_PREF, -- Код виплати
                   TO_NUMBER (COL004)                 AS TYPE_REC, --  Код вqиявленої невідповідності
                   COL005                             AS ORG, -- Джерело, -- надходження інформації
                   TO_DATE (COL006, 'YYYY-MM-DD')     AS DATE_ERR, --  Дата здійснення верифікації
                   COL007                             AS СONTENT,  -- JSON - Зміст виявленої невідповідності
                   c_st_MERC_Received
              FROM TABLE (csv_util_pkg.clob_to_csv_ext (l_clob)) p
             /*apex_data_parser.parse(
                   p_content           => tools.ConvertC2BUTF8(l_clob),
                   p_add_headers_row   => 'Y',
                   p_file_name         => l_pc_name
                   )*/
             WHERE     COL001 IS NOT NULL
                   AND COL002 IS NOT NULL                           -- serhii:
                   AND line_number > 1;

        l_lines_cnt := SQL%ROWCOUNT;

        IF l_lines_cnt = 0
        THEN
            raise_application_error (
                -20000,
                   'З файлу "'
                || l_pc_name
                || '" не вдалося завантажити жодного рядка.');
        END IF;

        /*   06/11/2023 serhii: #94133 "...рядки файлу - це зайве.."
           l_clob := convert_csv2html(p_csv_clob => l_clob,
                                      p_file_name => l_pc_name);
        */
        ikis_rbm.RDM$APP_EXCHANGE.set_visual_data (
            p_pkt_id        => p_pkt_id,
            p_visual_data   => l_pc_name);       -- #94133 l_clob -> l_pc_name

        ikis_rbm.rdm$packet.Set_Packet_State (p_Pkt_Id          => p_pkt_id,
                                              p_Pkt_St          => 'PRC',
                                              p_Pkt_Change_Wu   => l_com_wu,
                                              p_Pkt_Change_Dt   => SYSDATE);

        -- записуємо файл в exchangefiles  -- а чи порібно ????
        -- serhii: варто залишити, щоб зберегти зв'язок з джерелом через me_minfin_recomm_rows.merc_ef + exchangefiles.ef_pkt
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
                     'R01',
                     l_pc_name,
                     l_zip_blob,
                     l_clob,
                     NULL,
                     'EISR01',
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
                     p_pkt_id,
                     l_pc_name)
          RETURNING ef_id
               INTO l_ef_id;

        UPDATE me_minfin_recomm_rows r
           SET r.merc_memr =
                   (SELECT MIN (memr_id)
                      FROM uss_esr.me_minfin_request_rows
                     WHERE merc_id_fam = memr_id_fam AND memr_me = merc_me),
               r.merc_ef = l_ef_id
         WHERE r.merc_memr IS NULL AND r.merc_me = l_me_id;

        l_cnt := SQL%ROWCOUNT;

        -- serhii: встановлюємо стани #92025-14
        UPDATE me_minfin_request_rows r
           SET r.memr_st = c_st_MEMR_Received
         WHERE     r.memr_me = l_me_id
               AND EXISTS
                       (SELECT 1
                          FROM me_minfin_recomm_rows
                         WHERE     merc_st = c_st_MERC_Received
                               AND merc_memr = r.memr_id
                               AND merc_me = l_me_id);

        UPDATE mass_exchanges
           SET me_st = c_st_ME_Received
         WHERE     me_id = l_me_id
               AND EXISTS
                       (SELECT 1
                          FROM me_minfin_recomm_rows
                         WHERE     merc_st = c_st_MERC_Received
                               AND merc_memr IS NOT NULL
                               AND merc_me = l_me_id);

        IF l_cnt > 0
        THEN
            write_me_log (
                p_mel_me        => l_me_id,
                p_mel_st        => c_st_ME_Received,
                p_mel_message   =>
                       'У пакет завантажено '
                    || l_cnt
                    || ' нових рекомендацій з файлу '
                    || l_pc_name,
                p_mel_st_old    => l_me_st);
        END IF;

        -- контролі на коректність одержаних рядків
        -- serhii: в "Протоколі" LINES_VALID - це "Кількість помилкових строк"!
        SELECT COUNT (*)
          INTO l_orphan_cnt
          FROM me_minfin_recomm_rows
         WHERE merc_me = l_me_id --and merc_ef = l_ef_id
                                 AND merc_memr IS NULL;

        ---
        IF l_orphan_cnt = 0
        THEN
            l_coment := 'Завантажено без помилок';
        ELSE
            l_coment :=
                   TO_CHAR (l_orphan_cnt)
                || ' записів не знайдено в поточному пакеті';
        END IF;

        -- Формуємо КВ МСП
        l_csv_blob :=
            tools.ConvertC2B (
                   '"FILE_NAME";"LINES_ALL";"LINES_VALID";"COMMENT"'
                || CHR (10)
                || '"'
                || l_pc_name
                || '";'
                || l_lines_cnt
                || ';'
                || l_orphan_cnt
                || ';"'
                || l_coment
                || '"');
        l_pc_name := REPLACE (UPPER (l_pc_name), '.CSV', '.CVT');

        l_file_name :=
            'EIS2MFU' || TO_CHAR (SYSDATE, 'ddmmyyyyhh24mi') || '.zip';

        l_vis_clob :=
            convert_csv2html (p_csv_clob    => tools.ConvertB2C (l_csv_blob),
                              p_file_name   => l_pc_name);

        l_zip_blob :=
            tools.toZip2 (p_file_blob => l_csv_blob, p_file_name => l_pc_name);

        INSERT INTO exchcreatesession (ecs_id, ecs_start_dt, ecs_filter)
             VALUES (0, SYSDATE, SUBSTR (l_file_name, 1, 21))
          RETURNING ecs_id
               INTO l_ecs;

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
                     'EIS2MFU',
                     l_file_name,
                     l_zip_blob,
                     l_vis_clob,
                     NULL,
                     'EIS2MFU',
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
                     l_file_name)
          RETURNING ef_id
               INTO l_ef;

        -- заливаємо дані в ПЕОД
        INSERT INTO ikis_rbm.tmp_exchangefiles_m1 (ef_id,
                                                   ef_pr,
                                                   com_wu,
                                                   com_org,
                                                   ef_tp,
                                                   ef_name,
                                                   ef_data, --ivashchuk 20160513 #15516
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

        -- формування пакета ПЕОД. тип визначається по ef_main_tag_name
        ikis_rbm.RDM$APP_EXCHANGE.GenPaketsFromTMPTable;

           UPDATE exchangefiles f
              SET ef_pkt =
                      (SELECT t.ef_pkt
                         FROM ikis_rbm.tmp_exchangefiles_m1 t
                        WHERE t.ef_id = f.ef_id)
            WHERE     1 = 1
                  AND ef_ecs = l_ecs
                  AND EXISTS
                          (SELECT 1
                             FROM ikis_rbm.tmp_exchangefiles_m1 t
                            WHERE t.ef_id = f.ef_id)
        RETURNING ef_pkt
             INTO l_cvt_pkt;

        UPDATE exchcreatesession
           SET ecs_stop_dt = SYSDATE
         WHERE ecs_id = l_ecs;

        -- #92749-4 serhii: прив'язка пакету квитанції до пакету рекомендацій
        ikis_rbm.Rdm$packet.Insert_Packet_Link (p_Pkt_Prev   => p_pkt_id,
                                                p_Pkt_Id     => l_cvt_pkt);
    /*  -- прописуємо ід файла в таблицю рядків
      update me_minfin_request_rows r
      set r.memr_ef = l_ef
      where r.memr_me = l_me_id;
      -- прописуємо ід пакета в таблицю обміну
      update mass_exchanges m
      set m.me_pkt = (select t.ef_pkt from ikis_rbm.tmp_exchangefiles_m1 t
                      where t.ef_id = l_ef)
      where m.me_id = p_me_id
        and me_pkt is null;*/

    END;

    -- IC #99160 Обробити відповідь від ВПП ООН по виплаті є-допомоги
    PROCEDURE proc_me_recom_un (p_pkt_id ikis_rbm.v_packet.pkt_id%TYPE)
    IS
        l_zip_blob    ikis_rbm.v_packet_content.pc_data%TYPE;
        l_zip_name    ikis_rbm.v_packet_content.pc_name%TYPE;
        l_clob        CLOB;
        l_pc_name     ikis_rbm.v_packet_content.pc_name%TYPE;
        l_com_wu      NUMBER := tools.GetCurrWu;
        l_me_id       NUMBER;
        l_ecs         NUMBER;
        l_rec         NUMBER := 160;
        l_ef          NUMBER;
        l_file_name   VARCHAR2 (250);
        l_file_blob   BLOB;
        l_vis_clob    ikis_rbm.v_packet_content.pc_visual_data%TYPE;
        l_lines_cnt   NUMBER;
    BEGIN
        SELECT pc_data, UPPER (pc_name), pc_name
          INTO l_zip_blob, l_pc_name, l_zip_name
          FROM ikis_rbm.v_packet  p
               JOIN ikis_rbm.v_packet_content c ON pc_pkt = pkt_id
         WHERE pkt_id = p_pkt_id AND pkt_St = 'N' AND pkt_pat IN (121); -- un_resp Відповідь від ВПП ООН по виплаті є-допомоги

        IF SUBSTR (l_pc_name, -3) = 'ZIP'
        THEN
            BEGIN
                tools.unZip2 (p_zip_blob    => l_zip_blob,
                              p_file_blob   => l_file_blob,
                              p_file_name   => l_file_name);
                l_clob := tools.ConvertB2C (l_file_blob);
                l_pc_name := l_file_name;
            EXCEPTION
                WHEN OTHERS
                THEN
                    Raise_application_error (
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
            l_clob := tools.ConvertB2C (l_zip_blob);
        END IF;

        IF UPPER (SUBSTR (l_pc_name, -4)) != '.CSV'
        THEN
            l_pc_name := l_pc_name || '.CSV';
        END IF;

        SELECT MAX (m.me_id), COUNT (*)
          INTO l_me_id, l_lines_cnt
          FROM ikis_rbm.v_packet_links  x
               INNER JOIN uss_esr.mass_exchanges m ON m.me_pkt = x.pl_pkt_out
         WHERE x.pl_pkt_in = p_pkt_id;

        IF l_lines_cnt != 1
        THEN
            raise_application_error (
                -20000,
                   'По назві "'
                || l_pc_name
                || '" не вдалося визначити файл обміну.');
        END IF;

        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''. ''');

        DELETE FROM tmp_work_set1
              WHERE 1 = 1;

        INSERT INTO tmp_work_set1 (x_string1, x_sum1)
            SELECT TRIM (COL001)                                          ID_FAM,
                   TO_NUMBER (COL002 DEFAULT NULL ON CONVERSION ERROR)    PAYOUT
              FROM TABLE (csv_util_pkg.clob_to_csv_ext (l_clob)) p
             WHERE     COL001 IS NOT NULL
                   AND COL002 IS NOT NULL
                   AND line_number > 1;

        l_lines_cnt := SQL%ROWCOUNT;

        IF l_lines_cnt = 0
        THEN
            raise_application_error (
                -20000,
                   'З файлу "'
                || l_pc_name
                || '" не вдалося завантажити жодного рядка.');
        END IF;

        -- реєструємо сесію формування файлів обміну
        INSERT INTO exchcreatesession (ecs_id, ecs_start_dt, ecs_filter)
             VALUES (0, SYSDATE, 'ME#' || p_pkt_id || '#WFP2ICC')
          RETURNING ecs_id
               INTO l_ecs;

        l_vis_clob :=
               'Файл '
            || l_pc_name
            || '<br>'
            || 'Відповідь від ВПП ООН по виплаті є-допомоги'
            || '<br>'
            || 'Кількість завантажених рядків: '
            || l_lines_cnt;

        -- добавляю файл для аналізу завантаження
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
                     'WFP2ICC',
                     l_zip_name,
                     l_zip_blob,
                     l_vis_clob,
                     NULL,
                     'EISWFP2ICC',
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
                     p_pkt_id,
                     l_pc_name)
          RETURNING ef_id
               INTO l_ef;

        INSERT INTO me_vppun_result_rows (mvsr_id,
                                          mvsr_me,
                                          mvsr_mvrr,
                                          mvsr_pc,
                                          mvsr_pd_pay,
                                          mvsr_ef,
                                          mvsr_id_fam,
                                          mvsr_payout,
                                          mvsr_st)
            SELECT NULL         mvsr_id,
                   l_me_id      mvsr_me,
                   mvrr_id,
                   mvrr_pc,
                   NULL         mvsr_pd_pay,
                   l_ef         mvsr_ef,
                   x_string1    mvsr_id_fam,
                   x_sum1       mvsr_payout,
                   CASE
                       WHEN COUNT (*) OVER (PARTITION BY x_string1) > 1
                       THEN
                           'ERR-001'                   -- не унікальний id_fam
                       WHEN r.mvrr_id_fam IS NULL
                       THEN
                           'ERR-002'           -- відсутній рядок вивантаження
                       WHEN NVL (x_sum1, 0) = 0
                       THEN
                           'ERR-003' -- помилка конвертації, або відсутня сума
                       WHEN EXISTS
                                (SELECT 1
                                   FROM me_vppun_result_rows
                                  WHERE     mvsr_mvrr = mvrr_id
                                        AND mvsr_me = l_me_id
                                        AND mvsr_st NOT LIKE 'ERR%')
                       THEN
                           'ERR-004' -- вже існує завантажений рядок результату обробки
                       ELSE
                           c_st_MERC_Received                      -- Отримано
                   END          mvsr_st
              FROM tmp_work_set1  s
                   LEFT JOIN me_vppun_request_rows r
                       ON r.mvrr_me = l_me_id AND r.mvrr_id_fam = x_string1;

        l_vis_clob := l_vis_clob || '<br>' || '    в т.ч: ';

        FOR c IN (  SELECT mvsr_st, COUNT (*) cnt_st
                      FROM me_vppun_result_rows
                     WHERE mvsr_ef = l_ef
                  GROUP BY mvsr_st
                  ORDER BY 1)
        LOOP
            l_vis_clob :=
                   l_vis_clob
                || '<br>'
                || CASE c.mvsr_st
                       WHEN 'ERR-001'
                       THEN
                           '   не унікальний id_fam: '
                       WHEN 'ERR-002'
                       THEN
                           '   відсутній рядок вивантаження: '
                       WHEN 'ERR-003'
                       THEN
                           '   помилка конвертації, або відсутня сума payout: '
                       WHEN 'ERR-004'
                       THEN
                           '   повторне завантаження результату обробки '
                       ELSE
                           '  успішно: '
                   END
                || TO_CHAR (c.cnt_st);
        END LOOP;

        UPDATE exchangefiles
           SET ef_visual_data = l_vis_clob
         WHERE ef_id = l_ef;

        ikis_rbm.RDM$APP_EXCHANGE.set_visual_data (
            p_pkt_id        => p_pkt_id,
            p_visual_data   => l_vis_clob);
        ikis_rbm.rdm$packet.Set_Packet_State (p_Pkt_Id          => p_pkt_id,
                                              p_Pkt_St          => 'PRC',
                                              p_Pkt_Change_Wu   => l_com_wu,
                                              p_Pkt_Change_Dt   => SYSDATE);

        MERGE INTO me_vppun_request_rows r
             USING me_vppun_result_rows s
                ON (    r.mvrr_id = s.mvsr_mvrr
                    AND s.mvsr_ef = l_ef -- по файлу оскільки вивантаження/завантаження може відбуватися порціями
                    AND s.mvsr_st = c_st_MERC_Received)
        WHEN MATCHED
        THEN
            UPDATE SET mvrr_st = c_st_MEMR_Received;

        UPDATE mass_exchanges
           SET me_st = c_st_ME_Received
         WHERE     me_id = l_me_id
               AND NOT EXISTS
                       (SELECT 1
                          FROM me_vppun_request_rows
                               LEFT JOIN me_vppun_result_rows
                                   ON mvsr_mvrr = mvrr_id
                         WHERE mvrr_me = l_me_id AND mvsr_id IS NULL);

        --    COMMIT;
        API$PC_DECISION_EXT.Processing_vppun (
            l_me_id,
            uss_esr.tools.GetHistSession ());

        UPDATE exchcreatesession
           SET ecs_stop_dt = SYSDATE
         WHERE ecs_id = l_ecs;
    END proc_me_recom_un;

    -- IC #106684 Завантаження результатів виплати по банку (ВПП ООН)
    PROCEDURE proc_me_payment_unb (p_pkt_id ikis_rbm.v_packet.pkt_id%TYPE)
    IS
        l_zip_blob    ikis_rbm.v_packet_content.pc_data%TYPE;
        l_zip_name    ikis_rbm.v_packet_content.pc_name%TYPE;
        l_clob        CLOB;
        l_pc_name     ikis_rbm.v_packet_content.pc_name%TYPE;
        l_com_wu      NUMBER := tools.GetCurrWu;
        l_me_id       NUMBER;
        l_me_mon      DATE;
        l_me_tp       mass_exchanges.me_tp%TYPE;
        l_ecs         NUMBER;
        l_rec         NUMBER := 160;
        l_ef          NUMBER;
        l_file_name   VARCHAR2 (250);
        l_file_blob   BLOB;
        l_vis_clob    ikis_rbm.v_packet_content.pc_visual_data%TYPE;
        l_lines_cnt   NUMBER;
    BEGIN
        SELECT pc_data,
               UPPER (pc_name),
               pc_name,
               pkt_rec
          INTO l_zip_blob,
               l_pc_name,
               l_zip_name,
               l_rec
          FROM ikis_rbm.v_packet  p
               JOIN ikis_rbm.v_packet_content c ON pc_pkt = pkt_id
         WHERE pkt_id = p_pkt_id AND pkt_St = 'N' AND pkt_pat IN (124); -- un_bank_payment_reply Виплати по банку (ВПП ООН)

        IF SUBSTR (l_pc_name, -3) = 'ZIP'
        THEN
            BEGIN
                tools.unZip2 (p_zip_blob    => l_zip_blob,
                              p_file_blob   => l_file_blob,
                              p_file_name   => l_file_name);
                l_clob := tools.ConvertB2C (l_file_blob);
                l_pc_name := l_file_name;
            EXCEPTION
                WHEN OTHERS
                THEN
                    Raise_application_error (
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
            l_clob := tools.ConvertB2C (l_zip_blob);
        END IF;

        IF UPPER (SUBSTR (l_pc_name, -4)) != '.CSV'
        THEN
            l_pc_name := l_pc_name || '.CSV';
        END IF;

        l_me_tp :=
            CASE
                WHEN l_pc_name LIKE '%BICC%' THEN 'UN'
                WHEN l_pc_name LIKE '%PICC%' THEN 'UNP'
                ELSE ''
            END;
        l_me_mon := TO_DATE (SUBSTR (l_pc_name, 21, 4), 'yymm');

        SELECT MAX (m.me_id), COUNT (*)
          INTO l_me_id, l_lines_cnt
          FROM mass_exchanges m
         WHERE     m.me_st != c_st_ME_Cancelled                           -- D
               AND m.me_tp = l_me_tp
               AND m.me_month BETWEEN TRUNC (l_me_mon, 'mm')
                                  AND LAST_DAY (l_me_mon);

        IF l_lines_cnt != 1
        THEN
            raise_application_error (
                -20000,
                   'По назві "'
                || l_pc_name
                || '" не вдалося визначити файл обміну.');
        END IF;

        DBMS_SESSION.set_nls ('NLS_NUMERIC_CHARACTERS', '''. ''');

        DELETE FROM tmp_work_set1
              WHERE 1 = 1;

        INSERT INTO tmp_work_set1 (x_string1,
                                   x_id1,
                                   x_dt1,
                                   x_sum1)
            SELECT TRIM (COL001)
                       ID_FAM,
                   TO_NUMBER (COL002 DEFAULT NULL ON CONVERSION ERROR)
                       PAYMENT,
                   TO_DATE (COL003, 'YYYY-MM-DD')
                       PDATE,
                   TO_NUMBER (COL004 DEFAULT NULL ON CONVERSION ERROR)
                       PAYOUT
              FROM TABLE (csv_util_pkg.clob_to_csv_ext (l_clob)) p
             WHERE     COL001 IS NOT NULL
                   AND COL002 IS NOT NULL
                   AND line_number > 1;

        l_lines_cnt := SQL%ROWCOUNT;

        IF l_lines_cnt = 0
        THEN
            raise_application_error (
                -20000,
                   'З файлу "'
                || l_pc_name
                || '" не вдалося завантажити жодного рядка.');
        END IF;

        -- реєструємо сесію формування файлів обміну
        INSERT INTO exchcreatesession (ecs_id, ecs_start_dt, ecs_filter)
             VALUES (0, SYSDATE, 'ME#' || p_pkt_id || '#WFP2MSP')
          RETURNING ecs_id
               INTO l_ecs;

        l_vis_clob :=
               'Файл '
            || l_pc_name
            || '<br>'
            || 'Завантаження результатів виплати по банку (ВПП ООН)'
            || '<br>'
            || 'Кількість завантажених рядків: '
            || l_lines_cnt;

        -- добавляю файл для аналізу завантаження
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
                     'WFP2MSP',
                     l_zip_name,
                     l_zip_blob,
                     l_vis_clob,
                     NULL,
                     'EISWFP2MSP',
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
                     l_pc_name)
          RETURNING ef_id
               INTO l_ef;

        FOR c
            IN (SELECT mvsr_id,
                       mvrr_id,
                       NVL (mvsr_pc, mvrr_pc)    mvsr_pc,
                       x_string1                 mvsr_id_fam,
                       x_sum1                    mvsr_payout,
                       CASE
                           WHEN COUNT (*) OVER (PARTITION BY x_string1) > 1
                           THEN
                               'ERR-011'               -- не унікальний id_fam
                           WHEN r.mvsr_id_fam IS NULL
                           THEN
                               'ERR-012'       -- відсутній рядок вивантаження
                           WHEN NVL (x_sum1, 0) = 0 AND x_id1 = 1
                           THEN
                               'ERR-013' -- помилка конвертації, або відсутня сума
                           WHEN mvsr_st IN ('W', 'P')
                           THEN
                               'ERR-014' -- вже існує завантажений рядок результатів виплати по банку
                           WHEN mvsr_payout != x_sum1 AND x_id1 = 1
                           THEN
                               'ERR-015'       -- невідповідність суми виплати
                           ELSE
                               'W'               -- Отримано результат виплати
                       END                       mvsr_st,
                       x_id1                     mvsr_payment,
                       x_dt1                     mvsr_pdate
                  FROM tmp_work_set1  s
                       LEFT JOIN me_vppun_request_rows q
                           ON     q.mvrr_me = l_me_id
                              AND q.mvrr_id_fam = x_string1
                       LEFT JOIN me_vppun_result_rows r
                           ON r.mvsr_mvrr = q.mvrr_id AND r.mvsr_me = l_me_id)
        LOOP
            UPDATE me_vppun_result_rows
               SET mvsr_payment = c.mvsr_payment,
                   mvsr_pdate = c.mvsr_pdate,
                   mvsr_ef = l_ef,
                   mvsr_st = c.mvsr_st
             WHERE mvsr_id = c.mvsr_id;

            IF SQL%ROWCOUNT = 0
            THEN
                INSERT INTO me_vppun_result_rows (mvsr_id,
                                                  mvsr_me,
                                                  mvsr_mvrr,
                                                  mvsr_pc,
                                                  mvsr_pd_pay,
                                                  mvsr_ef,
                                                  mvsr_id_fam,
                                                  mvsr_payout,
                                                  mvsr_st,
                                                  mvsr_payment,
                                                  mvsr_pdate)
                     VALUES (NULL,
                             l_me_id,
                             c.mvrr_id,
                             c.mvsr_pc,
                             NULL,
                             l_ef,
                             c.mvsr_id_fam,
                             c.mvsr_payout,
                             c.mvsr_st,
                             c.mvsr_payment,
                             c.mvsr_pdate);
            END IF;
        END LOOP;

        l_vis_clob := l_vis_clob || '<br>' || '    в т.ч: ';

        FOR c IN (  SELECT mvsr_st, COUNT (*) cnt_st
                      FROM me_vppun_result_rows
                     WHERE mvsr_ef = l_ef
                  GROUP BY mvsr_st
                  ORDER BY 1)
        LOOP
            l_vis_clob :=
                   l_vis_clob
                || '<br>'
                || CASE c.mvsr_st
                       WHEN 'ERR-011'
                       THEN
                           '   не унікальний id_fam: '
                       WHEN 'ERR-012'
                       THEN
                           '   відсутній рядок вивантаження: '
                       WHEN 'ERR-013'
                       THEN
                           '   помилка конвертації, або відсутня сума payout: '
                       WHEN 'ERR-014'
                       THEN
                           '   повторне завантаження результатів виплати по банку: '
                       WHEN 'ERR-015'
                       THEN
                           '   невідповідність суми виплати: '
                       ELSE
                           '  успішно: '
                   END
                || TO_CHAR (c.cnt_st);
        END LOOP;

        UPDATE exchangefiles
           SET ef_visual_data = l_vis_clob
         WHERE ef_id = l_ef;

        ikis_rbm.RDM$APP_EXCHANGE.set_visual_data (
            p_pkt_id        => p_pkt_id,
            p_visual_data   => l_vis_clob);
        ikis_rbm.rdm$packet.Set_Packet_State (p_Pkt_Id          => p_pkt_id,
                                              p_Pkt_St          => 'PRC',
                                              p_Pkt_Change_Wu   => l_com_wu,
                                              p_Pkt_Change_Dt   => SYSDATE);

        MERGE INTO me_vppun_request_rows r
             USING me_vppun_result_rows s
                ON (    r.mvrr_id = s.mvsr_mvrr
                    AND s.mvsr_ef = l_ef -- по файлу оскільки вивантаження/завантаження може відбуватися порціями
                    AND s.mvsr_st = 'W')
        WHEN MATCHED
        THEN
            UPDATE SET mvrr_st = 'W';

        UPDATE mass_exchanges
           SET me_st = c_st_ME_Received
         WHERE     me_id = l_me_id
               AND NOT EXISTS
                       (SELECT 1
                          FROM me_vppun_request_rows
                               LEFT JOIN me_vppun_result_rows
                                   ON mvsr_mvrr = mvrr_id
                         WHERE mvrr_me = l_me_id AND mvsr_id IS NULL);

        --    COMMIT;

        API$PC_DECISION_EXT.Processing_vppun_pay_metod (
            l_me_id,
            uss_esr.tools.GetHistSession ());

        UPDATE exchcreatesession
           SET ecs_stop_dt = SYSDATE
         WHERE ecs_id = l_ecs;
    END proc_me_payment_unb;

    --Парсинг файлу який користувач завантажує у відповідь
    --Визивається з Ikis_Rbm.Dnet$Packet.create_pkt
    PROCEDURE Parse_File_On_Upload (
        p_Pkt_Id    IN Ikis_Rbm.v_Packet.Pkt_Id%TYPE,
        p_Pkt_Pat   IN Ikis_Rbm.v_Packet.Pkt_Pat%TYPE)
    IS
    BEGIN
        CASE
            WHEN p_Pkt_Pat IN (113)
            THEN
                Api$mass_Exchange.Proc_Me_Recom (p_Pkt_Id);
            WHEN p_Pkt_Pat IN (107)
            THEN
                Api$mass_Exchange_Dcz.Parse_File_Response (p_Pkt_Id);
            WHEN p_Pkt_Pat IN (109)
            THEN
                Api$mass_Exchange_Dps.Parse_File_Response (p_Pkt_Id);
            WHEN p_Pkt_Pat IN (121)
            THEN      -- un_resp (Відповідь від ВПП ООН по виплаті є-допомоги)
                Api$mass_Exchange.proc_me_recom_un (p_Pkt_Id);
            WHEN p_Pkt_Pat IN (124)
            THEN -- un_bank_payment_reply (Завантаження результатів виплати по банку (ВПП ООН))
                Api$mass_Exchange.proc_me_payment_unb (p_Pkt_Id);
            WHEN p_Pkt_Pat IN (123)
            THEN
                Api$mass_Exchange_Uni.Parse_File_Response (p_Pkt_Id);
            ELSE
                NULL;
        END CASE;
    END;

    -- #91349 2023.09.01 SERHII
    FUNCTION prepare_names (p_name IN VARCHAR2, p_upper IN PLS_INTEGER:= 1)
        RETURN VARCHAR2
    IS
        l_res   VARCHAR2 (500);
    BEGIN
        IF p_upper = 1
        THEN
            l_res := UPPER (p_name);
        ELSIF p_upper = 0
        THEN
            l_res := p_name;
        ELSE
            l_res := p_name;
        END IF;

        l_res := REGEXP_REPLACE (l_res, '[[:space:]]', ' ');
        l_res := REGEXP_REPLACE (l_res, ' +', ' ');
        l_res := TRIM (l_res);
        RETURN (l_res);
    END prepare_names;

    /*---------- #97756 copied from DNET$PAYMENT_REPORTS -------------*/
    FUNCTION getCharMF (                                          -- IC #87199
                        p_val    IN VARCHAR2,
                        p_type   IN VARCHAR2 := '0',
                        p_def    IN VARCHAR2 := NULL)
        RETURN VARCHAR2
    IS
        l_val   VARCHAR2 (4000);
    BEGIN
        l_val := REGEXP_REPLACE (p_val, '[[:space:]]', ' '); -- Прибираємо символи що не друкуються
        l_val := TRIM (l_val);          -- Прибираємо пробіли спереду і позаду
        l_val := REGEXP_REPLACE (l_val, '[ ]{1}+', ' '); -- Прибираємо лишні пробіли між словами

        IF REGEXP_COUNT (l_val, '"') = 2
        THEN
            l_val :=
                REGEXP_REPLACE (l_val,
                                '"',
                                CHR (171),
                                1,
                                1);                          -- Відкриті лапки
            l_val :=
                REGEXP_REPLACE (l_val,
                                '"',
                                CHR (187),
                                2,
                                1);                           -- Закриті лапки
        ELSIF REGEXP_COUNT (l_val, '"') = 1
        THEN
            l_val := REPLACE (l_val, '"', CHR (39));               -- Апостроф
        ELSE
            l_val := REPLACE (l_val, '"', ' '); -- просто заміняю на пробіл (ХЗ що робити) в цьому кейсі
        END IF;

        IF p_type = 'PIB'
        THEN
            l_val :=
                REGEXP_REPLACE (UPPER (l_val),
                                '[^А-ЯҐІЇЄ'' -]',
                                '',
                                1,
                                0,
                                'i');                      -- Тільки кириличні букви
        END IF;

        IF p_type = 'NUM'
        THEN
            l_val := REGEXP_REPLACE (l_val, '[^[:digit:]]', ''); -- Тільки цифри

            IF l_val IS NULL
            THEN
                RETURN NULL;
            END IF;
        END IF;

        IF p_type = 'UNZR'
        THEN
            l_val := REGEXP_REPLACE (l_val, '[^[:digit:]]', ''); -- Тільки цифри
            l_val := RPAD (l_val, 13, '0');
            RETURN l_val;
        END IF;

        l_val := NVL (l_val, p_def);

        l_val := '"' || l_val || '"';

        RETURN l_val;
    END getCharMF;

    /* serhii 12/09/2023 #91349: варіант getCharMF під вібірку для Мінфіну
        зберігаються дефіси, апстрофи, подвоюються " , обогортається в "" */
    FUNCTION getCharMF_q152 (p_val    IN VARCHAR2,
                             p_type   IN VARCHAR2 := '0',
                             p_def    IN VARCHAR2 := NULL)
        RETURN VARCHAR2
    IS
        l_val   VARCHAR2 (4000);
    BEGIN
        l_val := REGEXP_REPLACE (p_val, '[[:space:]]', ' ');
        l_val := TRIM (l_val);
        l_val := REGEXP_REPLACE (l_val, ' +', ' ');
        l_val := REPLACE (l_val, '"', '""');

        IF p_type = 'PIB'
        THEN
            --l_val := REGEXP_REPLACE(upper(l_val), '[^А-ЯҐІЇЄ'' -]', '', 1, 0, 'i');
            l_val := UPPER (l_val);
        END IF;

        IF p_type = 'NUM'
        THEN
            l_val := REGEXP_REPLACE (l_val, '[^[:digit:]]', '');

            IF l_val IS NULL
            THEN
                RETURN NULL;
            END IF;
        END IF;

        IF p_type = 'UNZR'
        THEN
            l_val := REGEXP_REPLACE (l_val, '[^[:digit:]]', '');
            l_val := RPAD (l_val, 13, '0');
            RETURN l_val;
        END IF;

        l_val := NVL (l_val, p_def);
        l_val := '"' || l_val || '"';
        RETURN l_val;
    END getCharMF_q152;

    FUNCTION getFAddrMF (p_app_id   IN NUMBER,
                         p_ndt_id   IN NUMBER := 605,
                         p_nda_id   IN NUMBER := NULL)
        RETURN VARCHAR
    IS
        l_str   uss_esr.ap_document_attr.apda_val_string%TYPE;
        l_res   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (da.apda_val_string)
          INTO l_str
          FROM uss_esr.ap_document d, uss_esr.ap_document_attr da
         WHERE     d.apd_app = p_app_id
               AND d.apd_id = da.apda_apd
               AND d.history_status = 'A'
               AND d.apd_ndt = 605
               AND da.apda_nda = 1782                                -- Індекс
               AND NVL (p_nda_id, 0) IN (0, 1782);

        l_res :=
            l_res || CASE WHEN l_str IS NULL THEN '' ELSE l_str || ',' END;

        SELECT MAX (da.apda_val_string)
          INTO l_str
          FROM uss_esr.ap_document d, uss_esr.ap_document_attr da
         WHERE     d.apd_app = p_app_id
               AND d.apd_id = da.apda_apd
               AND d.history_status = 'A'
               AND d.apd_ndt = 605
               AND da.apda_nda = 1781                               -- КАТОТТГ
               AND NVL (p_nda_id, 0) IN (0, 1781);

        l_res :=
            l_res || CASE WHEN l_str IS NULL THEN '' ELSE l_str || ',' END;

        SELECT MAX (
                      CASE
                          WHEN p_nda_id = 1786 THEN ''
                          ELSE st.nsrt_name || ','
                      END
                   || z.ns_name)
          INTO l_str
          FROM uss_ndi.v_ndi_street  z
               LEFT JOIN uss_ndi.v_ndi_street_type st
                   ON (st.nsrt_id = z.ns_nsrt)
         WHERE z.ns_id IN
                   (SELECT da.apda_val_id
                      FROM uss_esr.ap_document d, uss_esr.ap_document_attr da
                     WHERE     d.apd_app = p_app_id
                           AND d.apd_id = da.apda_apd
                           AND d.history_status = 'A'
                           AND d.apd_ndt = 605
                           AND da.apda_nda = 1783    -- Тип Назва вулиці (дов)
                           AND NVL (p_nda_id, 0) IN (0, 1783, 1786));

        l_res :=
            l_res || CASE WHEN l_str IS NULL THEN '' ELSE l_str || ',' END;

        SELECT MAX (da.apda_val_string)
          INTO l_str
          FROM uss_esr.ap_document d, uss_esr.ap_document_attr da
         WHERE     d.apd_app = p_app_id
               AND d.apd_id = da.apda_apd
               AND d.history_status = 'A'
               AND d.apd_ndt = 605
               AND da.apda_nda IN (1786)                 -- Назва вулиці (руч)
               AND NVL (p_nda_id, 0) IN (0, 1786, 1783);

        l_res :=
            l_res || CASE WHEN l_str IS NULL THEN '' ELSE l_str || ',' END;

        SELECT MAX (da.apda_val_string)
          INTO l_str
          FROM uss_esr.ap_document d, uss_esr.ap_document_attr da
         WHERE     d.apd_app = p_app_id
               AND d.apd_id = da.apda_apd
               AND d.history_status = 'A'
               AND d.apd_ndt = 605
               AND da.apda_nda = 1784                         -- Номер будинку
               AND NVL (p_nda_id, 0) IN (0, 1784);

        l_res :=
            l_res || CASE WHEN l_str IS NULL THEN '' ELSE l_str || ',' END;

        SELECT MAX (da.apda_val_string)
          INTO l_str
          FROM uss_esr.ap_document d, uss_esr.ap_document_attr da
         WHERE     d.apd_app = p_app_id
               AND d.apd_id = da.apda_apd
               AND d.history_status = 'A'
               AND d.apd_ndt = 605
               AND da.apda_nda = 1787                         -- Номер корпусу
               AND NVL (p_nda_id, 0) IN (0, 1787);

        l_res :=
            l_res || CASE WHEN l_str IS NULL THEN '' ELSE l_str || ',' END;

        SELECT MAX (da.apda_val_string)
          INTO l_str
          FROM uss_esr.ap_document d, uss_esr.ap_document_attr da
         WHERE     d.apd_app = p_app_id
               AND d.apd_id = da.apda_apd
               AND d.history_status = 'A'
               AND d.apd_ndt = 605
               AND da.apda_nda = 1780                        -- Номер квартири
               AND NVL (p_nda_id, 0) IN (0, 1780);

        l_res :=
            l_res || CASE WHEN l_str IS NULL THEN '' ELSE l_str || ',' END;

        l_res := RTRIM (l_res, ',');
        RETURN l_res;
    END getFAddrMF;

    FUNCTION getRAddrMF (p_app_id   IN NUMBER,
                         p_ndt_id   IN NUMBER := 605,
                         p_nda_id   IN NUMBER := NULL)
        RETURN VARCHAR
    IS
        l_str   uss_esr.ap_document_attr.apda_val_string%TYPE;
        l_res   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (da.apda_val_string)
          INTO l_str
          FROM uss_esr.ap_document d, uss_esr.ap_document_attr da
         WHERE     d.apd_app = p_app_id
               AND d.apd_id = da.apda_apd
               AND d.history_status = 'A'
               AND d.apd_ndt = 605
               AND da.apda_nda = 1776                                -- Індекс
               AND NVL (p_nda_id, 0) IN (0, 1776);

        l_res :=
            l_res || CASE WHEN l_str IS NULL THEN '' ELSE l_str || ',' END;

        SELECT MAX (da.apda_val_string)
          INTO l_str
          FROM uss_esr.ap_document d, uss_esr.ap_document_attr da
         WHERE     d.apd_app = p_app_id
               AND d.apd_id = da.apda_apd
               AND d.history_status = 'A'
               AND d.apd_ndt = 605
               AND da.apda_nda = 1775                               -- КАТОТТГ
               AND NVL (p_nda_id, 0) IN (0, 1775);

        l_res :=
            l_res || CASE WHEN l_str IS NULL THEN '' ELSE l_str || ',' END;

        SELECT MAX (
                      CASE
                          WHEN p_nda_id = 1785 THEN ''
                          ELSE st.nsrt_name || ','
                      END
                   || z.ns_name)
          INTO l_str
          FROM uss_ndi.v_ndi_street  z
               LEFT JOIN uss_ndi.v_ndi_street_type st
                   ON (st.nsrt_id = z.ns_nsrt)
         WHERE z.ns_id IN
                   (SELECT da.apda_val_id
                      FROM uss_esr.ap_document d, uss_esr.ap_document_attr da
                     WHERE     d.apd_app = p_app_id
                           AND d.apd_id = da.apda_apd
                           AND d.history_status = 'A'
                           AND d.apd_ndt = 605
                           AND da.apda_nda = 1777    -- Тип Назва вулиці (дов)
                           AND NVL (p_nda_id, 0) IN (0, 1777, 1785));

        l_res :=
            l_res || CASE WHEN l_str IS NULL THEN '' ELSE l_str || ',' END;

        SELECT MAX (da.apda_val_string)
          INTO l_str
          FROM uss_esr.ap_document d, uss_esr.ap_document_attr da
         WHERE     d.apd_app = p_app_id
               AND d.apd_id = da.apda_apd
               AND d.history_status = 'A'
               AND d.apd_ndt = 605
               AND da.apda_nda IN (1785)                 -- Назва вулиці (руч)
               AND NVL (p_nda_id, 0) IN (0, 1785, 1777);

        l_res :=
            l_res || CASE WHEN l_str IS NULL THEN '' ELSE l_str || ',' END;

        SELECT MAX (da.apda_val_string)
          INTO l_str
          FROM uss_esr.ap_document d, uss_esr.ap_document_attr da
         WHERE     d.apd_app = p_app_id
               AND d.apd_id = da.apda_apd
               AND d.history_status = 'A'
               AND d.apd_ndt = 605
               AND da.apda_nda = 1778                         -- Номер будинку
               AND NVL (p_nda_id, 0) IN (0, 1778);

        l_res :=
            l_res || CASE WHEN l_str IS NULL THEN '' ELSE l_str || ',' END;

        SELECT MAX (da.apda_val_string)
          INTO l_str
          FROM uss_esr.ap_document d, uss_esr.ap_document_attr da
         WHERE     d.apd_app = p_app_id
               AND d.apd_id = da.apda_apd
               AND d.history_status = 'A'
               AND d.apd_ndt = 605
               AND da.apda_nda = 1779                         -- Номер корпусу
               AND NVL (p_nda_id, 0) IN (0, 1779);

        l_res :=
            l_res || CASE WHEN l_str IS NULL THEN '' ELSE l_str || ',' END;

        SELECT MAX (da.apda_val_string)
          INTO l_str
          FROM uss_esr.ap_document d, uss_esr.ap_document_attr da
         WHERE     d.apd_app = p_app_id
               AND d.apd_id = da.apda_apd
               AND d.history_status = 'A'
               AND d.apd_ndt = 605
               AND da.apda_nda = 1788                        -- Номер квартири
               AND NVL (p_nda_id, 0) IN (0, 1788);

        l_res :=
            l_res || CASE WHEN l_str IS NULL THEN '' ELSE l_str || ',' END;

        l_res := RTRIM (l_res, ',');
        RETURN l_res;
    END getRAddrMF;

    FUNCTION getAddrUN (p_ap       IN NUMBER,
                        p_ndt_id   IN NUMBER := 600,
                        p_nda_id   IN NUMBER := NULL)
        RETURN VARCHAR
    IS
        l_str   uss_esr.ap_document_attr.apda_val_string%TYPE;
        l_res   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (st.nsrt_name || ' ' || z.ns_name)
          INTO l_str
          FROM uss_ndi.v_ndi_street  z
               LEFT JOIN uss_ndi.v_ndi_street_type st
                   ON st.nsrt_id = z.ns_nsrt
         WHERE z.ns_id IN
                   (SELECT da.apda_val_id
                      FROM uss_esr.ap_document d, uss_esr.ap_document_attr da
                     WHERE     d.apd_ap = p_ap
                           AND d.apd_id = da.apda_apd
                           AND d.history_status = 'A'
                           AND d.apd_ndt = 600
                           AND da.apda_nda = 597 -- Вулиця адреси проживання (довідник)
                                                );

        l_res := l_res || TRIM (l_str);

        SELECT MAX (da.apda_val_string)
          INTO l_str
          FROM uss_esr.ap_document d, uss_esr.ap_document_attr da
         WHERE     d.apd_ap = p_ap
               AND d.apd_id = da.apda_apd
               AND d.history_status = 'A'
               AND d.apd_ndt = 600
               AND da.apda_nda = 788               -- Вулиця адреси проживання
               AND l_res IS NULL         -- відсутній запис адреси з довідника
                                ;

        l_res := l_res || l_str || ';';

        SELECT MAX (da.apda_val_string)
          INTO l_str
          FROM uss_esr.ap_document d, uss_esr.ap_document_attr da
         WHERE     d.apd_ap = p_ap
               AND d.apd_id = da.apda_apd
               AND d.history_status = 'A'
               AND d.apd_ndt = 600
               AND da.apda_nda = 596              -- Будинок адреси проживання
                                    ;

        l_res := l_res || l_str || ';';

        SELECT MAX (da.apda_val_string)
          INTO l_str
          FROM uss_esr.ap_document d, uss_esr.ap_document_attr da
         WHERE     d.apd_ap = p_ap
               AND d.apd_id = da.apda_apd
               AND d.history_status = 'A'
               AND d.apd_ndt = 600
               AND da.apda_nda = 595               -- Корпус адреси проживання
                                    ;

        l_res := l_res || l_str || ';';

        SELECT MAX (da.apda_val_string)
          INTO l_str
          FROM uss_esr.ap_document d, uss_esr.ap_document_attr da
         WHERE     d.apd_ap = p_ap
               AND d.apd_id = da.apda_apd
               AND d.history_status = 'A'
               AND d.apd_ndt = 600
               AND da.apda_nda = 594             -- Квартира адреси проживання
                                    ;

        l_res := l_res || CASE WHEN l_str IS NULL THEN '' ELSE l_str END;

        --l_res := RTRIM (l_res, ';');
        RETURN l_res;
    END getAddrUN;

    -- IC Отримання текстового параметру документу по учаснику
    FUNCTION get_doc_string (p_app   ap_document.apd_app%TYPE,
                             p_ap    ap_document.apd_ap%TYPE,
                             p_ndt   ap_document.apd_ndt%TYPE,
                             p_nda   ap_document_attr.apda_nda%TYPE)
        RETURN VARCHAR2
    IS
        l_rez   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (apda_val_string)
          INTO l_rez
          FROM ap_document, ap_document_attr
         WHERE     apda_apd = apd_id
               AND ap_document.history_status = 'A'
               AND (apd_app = p_app OR p_app IS NULL) -- або шукати тільки по зверненню
               AND apd_ap = p_ap
               AND apd_ndt = p_ndt
               AND apda_nda = p_nda;

        RETURN l_rez;
    END get_doc_string;

    -- IC Отримання ID параметру документу по учаснику
    FUNCTION get_doc_id (p_app   ap_document.apd_app%TYPE,
                         p_ap    ap_document.apd_ap%TYPE,
                         p_ndt   ap_document.apd_ndt%TYPE,
                         p_nda   ap_document_attr.apda_nda%TYPE)
        RETURN VARCHAR2
    IS
        l_rez   VARCHAR2 (4000);
    BEGIN
        SELECT MAX (apda_val_id)
          INTO l_rez
          FROM ap_document, ap_document_attr
         WHERE     apda_apd = apd_id
               AND ap_document.history_status = 'A'
               AND (apd_app = p_app OR p_app IS NULL) -- або шукати тільки по зверненню
               AND apd_ap = p_ap
               AND apd_ndt = p_ndt
               AND apda_nda = p_nda;

        RETURN l_rez;
    END get_doc_id;

    /*---------- #97756 copied from DNET$PAYMENT_REPORTS -------------*/


    PROCEDURE write_me_log (
        p_mel_me        IN ME_LOG.mel_me%TYPE,
        p_mel_hs        IN ME_LOG.mel_hs%TYPE DEFAULT NULL,
        p_mel_st        IN ME_LOG.mel_st%TYPE,
        p_mel_message   IN ME_LOG.mel_message%TYPE,
        p_mel_st_old    IN ME_LOG.mel_st_old%TYPE DEFAULT NULL,
        p_mel_tp        IN ME_LOG.mel_tp%TYPE DEFAULT 'SYS')
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        l_hs := NVL (p_mel_hs, TOOLS.GetHistSession);

        INSERT INTO ME_LOG (mel_me,
                            mel_hs,
                            mel_st,
                            mel_message,
                            mel_st_old,
                            mel_tp)
             VALUES (p_mel_me,
                     l_hs,
                     p_mel_st,
                     p_mel_message,
                     p_mel_st_old,
                     p_mel_tp);
    END;
BEGIN
    NULL;
END API$MASS_EXCHANGE;
/