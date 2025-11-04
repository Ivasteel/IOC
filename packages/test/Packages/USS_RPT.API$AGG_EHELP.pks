/* Formatted on 8/12/2025 5:58:55 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RPT.API$AGG_EHELP
AS
    -- Author  : DLEV
    -- Created :
    -- Purpose : єДопомога

    -- info:   підготовка агрегату даних по єДопомога (реєстр актуальних заявок)
    -- params:
    -- note:   #83957
    PROCEDURE prepare_agg_ehelp;

    -- info:   підготовка агрегату даних по отриманню квитанцій по єДопомога
    -- params:
    -- note:   #85105
    PROCEDURE prepare_agg_int_help;
END api$agg_ehelp;
/


/* Formatted on 8/12/2025 5:58:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RPT.API$AGG_EHELP
AS
    -- info:   підготовка агрегату даних по єДопомога (реєстр актуальних заявок)
    -- params:
    -- note:   #83957
    PROCEDURE prepare_agg_ehelp
    IS
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET cell_offload_processing=FALSE';

        DELETE FROM agg_ehelp;

        INSERT INTO agg_ehelp (ae_id,
                               ae_ap,
                               ae_ap_st,
                               ae_app_count,
                               ae_kaot_code,
                               ae_org_name,
                               ae_bank_name,
                               ae_app,
                               ae_birth_dt,
                               ae_is_repeated,
                               ae_is_disabiled,
                               ae_is_pensioner,
                               ae_is_lonely,
                               ae_is_large_family,
                               ae_is_low_income,
                               ae_is_vpo,
                               ae_is_non_above,
                               ae_row_create_dt)
              SELECT 0,
                     ae_ap,
                     ae_ap_st,
                     ae_app_count,
                     ae_kaot_code,
                     ae_org_name,
                     ae_bank_name,
                     ae_app,
                     ae_birth_dt,
                     ae_is_repeated,
                     ae_is_disabiled,
                     ae_is_pensioner,
                     ae_is_lonely,
                     ae_is_large_family,
                     ae_is_low_income,
                     ae_is_vpo,
                     ae_is_non_above,
                     SYSDATE
                FROM (SELECT a.ap_id
                                 AS ae_ap,                           --"Заява"
                             'в списку'
                                 AS ae_ap_st,                        --"Статус заяви"
                             (SELECT TO_NUMBER (f19.pde_val_string) + 1
                                FROM uss_esr.v_pd_features f19
                               WHERE f19.pde_pd = d.pd_id AND f19.pde_nft = 19)
                                 AS ae_app_count,             --"Осіб в заяві"
                             (SELECT f26.pde_val_string
                                FROM uss_esr.v_pd_features f26
                               WHERE f26.pde_pd = d.pd_id AND f26.pde_nft = 26)
                                 AS ae_kaot_code,                  --"КАТОТТГ"
                             (SELECT pt.npt_name
                                FROM uss_ndi.v_ndi_payment_type pt
                               WHERE pt.npt_id = p.pdp_npt)
                                 AS ae_org_name,         --"Назва організації"
                             NULL
                                 AS ae_bank_name,              --"Назва банку"
                             NULL
                                 AS ae_app,                  --"Учасник заяви"
                             f.pdf_birth_dt
                                 AS ae_birth_dt,           --"Дата народження"
                             'Ні'
                                 AS ae_is_repeated,         --"Учасник повторно"
                             COALESCE (
                                 (SELECT (CASE f16.pde_val_string
                                              WHEN 'Tak' THEN 'Так'
                                              ELSE f16.pde_val_string
                                          END)
                                    FROM uss_esr.v_pd_features f16
                                   WHERE     f16.pde_pd = d.pd_id
                                         AND f16.pde_pdf = f.pdf_id
                                         AND f16.pde_nft = 16),
                                 'Ні')
                                 AS ae_is_disabiled,            --"Інвалідність"
                             COALESCE (
                                 (SELECT (CASE f18.pde_val_string
                                              WHEN 'Tak' THEN 'Так'
                                              ELSE f18.pde_val_string
                                          END)
                                    FROM uss_esr.v_pd_features f18
                                   WHERE     f18.pde_pd = d.pd_id
                                         AND f18.pde_pdf = f.pdf_id
                                         AND f18.pde_nft = 18),
                                 'Ні')
                                 AS ae_is_pensioner,               --"Пенсіонер"
                             COALESCE (
                                 (SELECT (CASE f29.pde_val_string
                                              WHEN 'Tak' THEN 'Так'
                                              ELSE f29.pde_val_string
                                          END)
                                    FROM uss_esr.v_pd_features f29
                                   WHERE     f29.pde_pd = d.pd_id
                                         AND f29.pde_pdf = f.pdf_id
                                         AND f29.pde_nft = 29),
                                 'Ні')
                                 AS ae_is_lonely,           --"Одинока/одинокий"
                             COALESCE (
                                 (SELECT (CASE f30.pde_val_string
                                              WHEN 'Tak' THEN 'Так'
                                              ELSE f30.pde_val_string
                                          END)
                                    FROM uss_esr.v_pd_features f30
                                   WHERE     f30.pde_pd = d.pd_id
                                         AND f30.pde_pdf = f.pdf_id
                                         AND f30.pde_nft = 30),
                                 'Ні')
                                 AS ae_is_large_family,    --"Багатодітна сім’я"
                             COALESCE (
                                 (SELECT (CASE f31.pde_val_string
                                              WHEN 'Tak' THEN 'Так'
                                              ELSE f31.pde_val_string
                                          END)
                                    FROM uss_esr.v_pd_features f31
                                   WHERE     f31.pde_pd = d.pd_id
                                         AND f31.pde_pdf = f.pdf_id
                                         AND f31.pde_nft = 31),
                                 'Ні')
                                 AS ae_is_low_income,   --"Отримувач допомоги малозабезпеченим сім’ям"
                             COALESCE (
                                 (SELECT (CASE f28.pde_val_string
                                              WHEN 'Tak' THEN 'Так'
                                              ELSE f28.pde_val_string
                                          END)
                                    FROM uss_esr.v_pd_features f28
                                   WHERE     f28.pde_pd = d.pd_id
                                         AND f28.pde_pdf = f.pdf_id
                                         AND f28.pde_nft = 28),
                                 'Ні')
                                 AS ae_is_vpo,                           --"ВПО"
                             COALESCE (
                                 (SELECT (CASE f24.pde_val_string
                                              WHEN 'Tak' THEN 'Так'
                                              ELSE f24.pde_val_string
                                          END)
                                    FROM uss_esr.v_pd_features f24
                                   WHERE     f24.pde_pd = d.pd_id
                                         AND f24.pde_pdf = f.pdf_id
                                         AND f24.pde_nft = 24),
                                 'Ні')
                                 AS ae_is_non_above   --"Жодна з попередніх категорій"
                        FROM uss_esr.appeal a
                             JOIN uss_esr.pc_decision d
                                 ON d.pd_ap = a.ap_id AND d.pd_st != 'V'
                             JOIN uss_esr.v_pd_payment p
                                 ON     p.pdp_pd = d.pd_id
                                    AND p.pdp_stop_dt IS NULL
                             JOIN uss_esr.v_pd_family f ON f.pdf_pd = d.pd_id
                       WHERE a.ap_tp = 'IA' AND a.ap_id < 0
                      UNION ALL
                      SELECT a.ap_id
                                 AS ae_ap,                           --"Заява"
                             (CASE
                                  WHEN d.pd_id IS NULL
                                  THEN
                                      'не верифіковано'
                                  WHEN d.pd_st IN ('AM', 'S')
                                  THEN
                                      'в списку'
                                  WHEN d.pd_st IN ('AP', 'R1', 'R0')
                                  THEN
                                      'в черзі'
                                  WHEN d.pd_st = 'WD'
                                  THEN
                                      'дубль'
                              END)
                                 AS ae_ap_st,                 --"Статус заяви"
                             (CASE
                                  WHEN d.pd_id IS NOT NULL
                                  THEN
                                      (SELECT TO_NUMBER (f19.pde_val_string)
                                         FROM uss_esr.v_pd_features f19
                                        WHERE     f19.pde_pd = d.pd_id
                                              AND f19.pde_nft = 19)
                                  ELSE
                                      (SELECT COUNT (
                                                  DISTINCT
                                                      (COALESCE (apa.app_sc,
                                                                 apa.app_id)))
                                         FROM uss_visit.ap_person apa
                                        WHERE     apa.app_ap = a.ap_id
                                              AND apa.history_status = 'A')
                              END)
                                 AS ae_app_count,             --"Осіб в заяві"
                             COALESCE (
                                 (SELECT f26.pde_val_string
                                    FROM uss_esr.v_pd_features f26
                                   WHERE     f26.pde_pd = d.pd_id
                                         AND f26.pde_nft = 26
                                         AND f26.pde_val_string IS NOT NULL),
                                 (SELECT a2004.apda_val_string
                                    FROM uss_visit.ap_document_attr a2004
                                   WHERE     a2004.apda_apd = d909.apd_id
                                         AND a2004.apda_ap = a.ap_id
                                         AND a2004.apda_nda = 2004
                                         AND a2004.history_status = 'A'
                                         AND a2004.apda_val_string IS NOT NULL))
                                 AS ae_kaot_code,                  --"КАТОТТГ"
                             (CASE
                                  WHEN d.pd_st IN ('AM', 'S') AND p.pdp_npt < 0
                                  THEN
                                      (SELECT pt.npt_name
                                         FROM uss_ndi.v_ndi_payment_type pt
                                        WHERE pt.npt_id = p.pdp_npt)
                              END)
                                 AS ae_org_name,         --"Назва організації"
                             (CASE
                                  WHEN pmt.apm_account IS NOT NULL
                                  THEN
                                      (SELECT MAX (b.nb_name)
                                         FROM uss_ndi.v_ndi_bank b
                                        WHERE     b.nb_mfo =
                                                  SUBSTR (pmt.apm_account,
                                                          5,
                                                          6)
                                              AND b.history_status = 'A')
                              END)
                                 AS ae_bank_name,              --"Назва банку"
                             ap.app_id
                                 AS ae_app,                  --"Учасник заяви"
                             f.pdf_birth_dt
                                 AS ae_birth_dt,           --"Дата народження"
                             COALESCE (
                                 (CASE
                                      WHEN d.pd_st = 'WD'
                                      THEN
                                          (SELECT (CASE
                                                       WHEN COUNT (1) = 0
                                                       THEN
                                                           'Ні'
                                                       ELSE
                                                           'Так'
                                                   END)
                                             FROM uss_esr.appeal ad
                                                  JOIN uss_esr.pc_decision dd
                                                      ON     dd.pd_ap =
                                                             ad.ap_id
                                                         AND dd.pd_id !=
                                                             d.pd_id
                                                  JOIN uss_esr.v_pd_family fd
                                                      ON     fd.pdf_pd =
                                                             dd.pd_id
                                                         AND fd.pdf_sc =
                                                             ap.app_sc
                                            WHERE     ad.ap_tp = 'IA'
                                                  AND ad.ap_id != a.ap_id
                                            FETCH FIRST 1 ROW ONLY)
                                      ELSE
                                          'Ні'
                                  END),
                                 'Ні')
                                 AS ae_is_repeated,         --"Учасник повторно"
                             COALESCE (
                                 (CASE
                                      WHEN d.pd_id IS NOT NULL
                                      THEN
                                          (SELECT MAX (f16.pde_val_string)
                                             FROM uss_esr.v_pd_features f16
                                                  JOIN uss_esr.v_pd_family f
                                                      ON     f.pdf_id =
                                                             f16.pde_pdf
                                                         AND f.pdf_pd = d.pd_id
                                                         AND f.pdf_sc =
                                                             ap.app_sc
                                            WHERE     f16.pde_pd = d.pd_id
                                                  AND f16.pde_nft = 16)
                                      ELSE
                                          (SELECT (CASE MAX (
                                                            a660.apda_val_string)
                                                       WHEN 'T'
                                                       THEN
                                                           'Так'
                                                       ELSE
                                                           'Ні'
                                                   END)
                                             FROM uss_visit.ap_document_attr
                                                  a660
                                            WHERE     a660.apda_apd =
                                                      d605.apd_id
                                                  AND a660.apda_ap = a.ap_id
                                                  AND a660.apda_nda = 660
                                                  AND a660.history_status = 'A')
                                  END),
                                 'Ні')
                                 AS ae_is_disabiled,            --"Інвалідність"
                             COALESCE (
                                 (CASE
                                      WHEN d.pd_id IS NOT NULL
                                      THEN
                                          (SELECT MAX (f18.pde_val_string)
                                             FROM uss_esr.v_pd_features f18
                                                  JOIN uss_esr.v_pd_family f
                                                      ON     f.pdf_id =
                                                             f18.pde_pdf
                                                         AND f.pdf_pd = d.pd_id
                                                         AND f.pdf_sc =
                                                             ap.app_sc
                                            WHERE     f18.pde_pd = d.pd_id
                                                  AND f18.pde_nft = 18)
                                      ELSE
                                          (SELECT (CASE MAX (
                                                            a661.apda_val_string)
                                                       WHEN 'T'
                                                       THEN
                                                           'Так'
                                                       ELSE
                                                           'Ні'
                                                   END)
                                             FROM uss_visit.ap_document_attr
                                                  a661
                                            WHERE     a661.apda_apd =
                                                      d605.apd_id
                                                  AND a661.apda_ap = a.ap_id
                                                  AND a661.apda_nda = 661
                                                  AND a661.history_status = 'A')
                                  END),
                                 'Ні')
                                 AS ae_is_pensioner,               --"Пенсіонер"
                             COALESCE (
                                 (CASE
                                      WHEN d.pd_id IS NOT NULL
                                      THEN
                                          (SELECT MAX (f29.pde_val_string)
                                             FROM uss_esr.v_pd_features f29
                                                  JOIN uss_esr.v_pd_family f
                                                      ON     f.pdf_id =
                                                             f29.pde_pdf
                                                         AND f.pdf_pd = d.pd_id
                                                         AND f.pdf_sc =
                                                             ap.app_sc
                                            WHERE     f29.pde_pd = d.pd_id
                                                  AND f29.pde_nft = 29)
                                      ELSE
                                          (SELECT (CASE MAX (
                                                            a641.apda_val_string)
                                                       WHEN 'T'
                                                       THEN
                                                           'Так'
                                                       ELSE
                                                           'Ні'
                                                   END)
                                             FROM uss_visit.ap_document_attr
                                                  a641
                                            WHERE     a641.apda_apd =
                                                      d605.apd_id
                                                  AND a641.apda_ap = a.ap_id
                                                  AND a641.apda_nda = 641
                                                  AND a641.history_status = 'A')
                                  END),
                                 'Ні')
                                 AS ae_is_lonely,           --"Одинока/одинокий"
                             COALESCE (
                                 (CASE
                                      WHEN d.pd_id IS NOT NULL
                                      THEN
                                          (SELECT MAX (f30.pde_val_string)
                                             FROM uss_esr.v_pd_features f30
                                                  JOIN uss_esr.v_pd_family f
                                                      ON     f.pdf_id =
                                                             f30.pde_pdf
                                                         AND f.pdf_pd = d.pd_id
                                                         AND f.pdf_sc =
                                                             ap.app_sc
                                            WHERE     f30.pde_pd = d.pd_id
                                                  AND f30.pde_pdf = f.pdf_id
                                                  AND f30.pde_nft = 30)
                                      WHEN ap.app_id = d909.apd_app
                                      THEN
                                          (SELECT (CASE MAX (
                                                            a2011.apda_val_string)
                                                       WHEN 'T'
                                                       THEN
                                                           'Так'
                                                       ELSE
                                                           'Ні'
                                                   END)
                                             FROM uss_visit.ap_document_attr
                                                  a2011
                                            WHERE     a2011.apda_apd =
                                                      d909.apd_id
                                                  AND a2011.apda_ap = a.ap_id
                                                  AND a2011.apda_nda = 2011
                                                  AND a2011.history_status =
                                                      'A')
                                      ELSE
                                          'Ні'
                                  END),
                                 'Ні')
                                 AS ae_is_large_family,    --"Багатодітна сім’я"
                             COALESCE (
                                 (CASE
                                      WHEN d.pd_id IS NOT NULL
                                      THEN
                                          (SELECT MAX (f31.pde_val_string)
                                             FROM uss_esr.v_pd_features f31
                                                  JOIN uss_esr.v_pd_family f
                                                      ON     f.pdf_id =
                                                             f31.pde_pdf
                                                         AND f.pdf_pd = d.pd_id
                                                         AND f.pdf_sc =
                                                             ap.app_sc
                                            WHERE     f31.pde_pd = d.pd_id
                                                  AND f31.pde_pdf = f.pdf_id
                                                  AND f31.pde_nft = 31)
                                      WHEN ap.app_id = d909.apd_app
                                      THEN
                                          (SELECT (CASE MAX (
                                                            a2013.apda_val_string)
                                                       WHEN 'T'
                                                       THEN
                                                           'Так'
                                                       ELSE
                                                           'Ні'
                                                   END)
                                             FROM uss_visit.ap_document_attr
                                                  a2013
                                            WHERE     a2013.apda_apd =
                                                      d909.apd_id
                                                  AND a2013.apda_ap = a.ap_id
                                                  AND a2013.apda_nda = 2013
                                                  AND a2013.history_status =
                                                      'A')
                                      ELSE
                                          'Ні'
                                  END),
                                 'Ні')
                                 AS ae_is_low_income,   --"Отримувач допомоги малозабезпеченим сім’ям"
                             COALESCE (
                                 (CASE
                                      WHEN d.pd_id IS NOT NULL
                                      THEN
                                          (SELECT MAX (f28.pde_val_string)
                                             FROM uss_esr.v_pd_features f28
                                                  JOIN uss_esr.v_pd_family f
                                                      ON     f.pdf_id =
                                                             f28.pde_pdf
                                                         AND f.pdf_pd = d.pd_id
                                                         AND f.pdf_sc =
                                                             ap.app_sc
                                            WHERE     f28.pde_pd = d.pd_id
                                                  AND f28.pde_pdf = f.pdf_id
                                                  AND f28.pde_nft = 28)
                                      ELSE
                                          (SELECT (CASE MAX (v10052.vf_st)
                                                       WHEN 'X' THEN 'Так'
                                                       ELSE 'Ні'
                                                   END)
                                             FROM uss_visit.v_verification
                                                  v10052
                                            WHERE v10052.vf_id = d10052.apd_vf)
                                  END),
                                 'Ні')
                                 AS ae_is_vpo,                           --"ВПО"
                             COALESCE (
                                 (CASE
                                      WHEN d.pd_id IS NOT NULL
                                      THEN
                                          (SELECT MAX (f24.pde_val_string)
                                             FROM uss_esr.v_pd_features f24
                                                  JOIN uss_esr.v_pd_family f
                                                      ON     f.pdf_id =
                                                             f24.pde_pdf
                                                         AND f.pdf_pd = d.pd_id
                                                         AND f.pdf_sc =
                                                             ap.app_sc
                                            WHERE     f24.pde_pd = d.pd_id
                                                  AND f24.pde_pdf = f.pdf_id
                                                  AND f24.pde_nft = 24)
                                      WHEN ap.app_id = d909.apd_app
                                      THEN
                                          (SELECT (CASE MAX (
                                                            a2012.apda_val_string)
                                                       WHEN 'T'
                                                       THEN
                                                           'Так'
                                                       ELSE
                                                           'Ні'
                                                   END)
                                             FROM uss_visit.ap_document_attr
                                                  a2012
                                            WHERE     a2012.apda_apd =
                                                      d909.apd_id
                                                  AND a2012.apda_ap = a.ap_id
                                                  AND a2012.apda_nda = 2012
                                                  AND a2012.history_status =
                                                      'A')
                                      ELSE
                                          'Ні'
                                  END),
                                 'Ні')
                                 AS ae_is_non_above   --"Жодна з попередніх категорій"
                        FROM uss_visit.appeal a
                             JOIN uss_visit.ap_person ap
                                 ON     ap.app_ap = a.ap_id
                                    AND ap.history_status = 'A'
                             JOIN uss_visit.v_ap_payment pmt
                                 ON     pmt.apm_ap = a.ap_id
                                    AND pmt.history_status = 'A'
                             JOIN uss_visit.ap_document d909
                                 ON     d909.apd_ap = a.ap_id
                                    AND d909.apd_ndt = 909
                                    AND d909.history_status = 'A'
                             LEFT JOIN uss_visit.ap_document d605
                                 ON     d605.apd_ap = a.ap_id
                                    AND d605.apd_app = ap.app_id
                                    AND d605.apd_ndt = 605
                                    AND d605.history_status = 'A'
                             LEFT JOIN uss_visit.ap_document d10052
                                 ON     d10052.apd_ap = a.ap_id
                                    AND d10052.apd_app = ap.app_id
                                    AND d10052.apd_ndt = 10052
                                    AND d10052.history_status = 'A'
                             LEFT JOIN uss_esr.pc_decision d
                                 ON d.pd_ap = a.ap_id
                             LEFT JOIN uss_esr.v_pd_payment p
                                 ON     p.pdp_pd = d.pd_id
                                    AND p.pdp_stop_dt IS NULL
                             LEFT JOIN uss_esr.v_pd_family f
                                 ON f.pdf_pd = d.pd_id AND f.pdf_sc = ap.app_sc
                       WHERE     a.ap_tp = 'IA'
                             AND COALESCE (d.pd_st, 'NULL') != 'V'
                             AND (   a.ap_st NOT IN ('DEL', 'X')
                                  OR (a.ap_st = 'DEL' AND p.pdp_npt < 0)))
            ORDER BY ae_ap, ae_app;

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
    END;

    -- info:   підготовка агрегату даних по отриманню квитанцій по єДопомога
    -- params:
    -- note:   #85105
    PROCEDURE prepare_agg_int_help
    IS
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET cell_offload_processing=FALSE';

        DELETE FROM agg_int_help;

        INSERT INTO agg_int_help (aih_id,
                                  aih_ap,
                                  aih_dt,
                                  aih_int_org_gt,
                                  aih_int_org_name,
                                  aih_kv_dt,
                                  aih_result,
                                  aih_ap_st,
                                  aih_row_create_dt)
              SELECT 0,
                     a.ap_id,                                        --"Заява"
                     a.ap_reg_dt,                    --"Дата звернення заявки"
                     d.pd_start_dt,    --"Дата взяття на виплату організацією"
                     pt.npt_name,                        --"Назва організації"
                     COALESCE (
                         p.pdp_stop_dt,
                         (SELECT MAX (h.hs_dt)
                            FROM uss_esr.v_pd_log l
                                 JOIN uss_esr.v_histsession h
                                     ON h.hs_id = l.pdl_hs
                           WHERE     l.pdl_pd = d.pd_id
                                 AND l.pdl_st = 'S'
                                 AND l.pdl_st_old = 'AM')), --"Дата квитанції"
                     (CASE
                          WHEN p.pdp_stop_dt IS NOT NULL THEN 'відмовлено'
                          WHEN d.pd_st = 'S' THEN 'виплачено'
                      END),                                                         --"Результат"
                     (SELECT s.dic_sname
                        FROM uss_ndi.v_ddn_ap_st s
                       WHERE s.dic_value = a1.ap_st),        --"Статус заявки"
                     SYSDATE
                FROM uss_esr.appeal a
                     JOIN uss_esr.pc_decision d ON d.pd_ap = a.ap_id
                     JOIN uss_esr.v_pd_payment p ON p.pdp_pd = d.pd_id
                     JOIN uss_ndi.v_ndi_payment_type pt
                         ON pt.npt_id = p.pdp_npt
                     JOIN uss_visit.appeal a1 ON a1.ap_id = a.ap_id
               WHERE     a.ap_tp = 'IA'
                     AND (   a.ap_st NOT IN ('DEL')
                          OR (a.ap_st = 'DEL' AND p.pdp_npt < 0))
            ORDER BY a.ap_id;

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
    END;
END api$agg_ehelp;
/