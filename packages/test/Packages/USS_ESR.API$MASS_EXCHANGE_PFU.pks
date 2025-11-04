/* Formatted on 8/12/2025 5:48:25 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_ESR.API$MASS_EXCHANGE_PFU
IS
    -- Author  : SERHII
    -- Created : 02.05.2024 16:06:38
    -- Purpose : Масові обміни з ПФУ (для #100872 та ін.)

    -- Виклик формування пакету: API$MASS_EXCHANGE.make_me_packet
    PROCEDURE prepare_me_rows (p_me_id mass_exchanges.me_id%TYPE);

    -- #100872 serhii 28/04/2024 Функція NRT_BACKGROUND_FUNC фонової обробки запиту PutPersonEmpPens
    PROCEDURE Process_PutPersonEmpPens_Req (p_Ur_Id     IN NUMBER,
                                            p_Request   IN CLOB);
END API$MASS_EXCHANGE_PFU;
/


GRANT EXECUTE ON USS_ESR.API$MASS_EXCHANGE_PFU TO II01RC_USS_ESR_INTERNAL
/

GRANT EXECUTE ON USS_ESR.API$MASS_EXCHANGE_PFU TO IKIS_RBM
/

GRANT EXECUTE ON USS_ESR.API$MASS_EXCHANGE_PFU TO USS_PERSON
/

GRANT EXECUTE ON USS_ESR.API$MASS_EXCHANGE_PFU TO USS_RPT
/

GRANT EXECUTE ON USS_ESR.API$MASS_EXCHANGE_PFU TO USS_VISIT
/


/* Formatted on 8/12/2025 5:49:07 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_ESR.API$MASS_EXCHANGE_PFU
IS
    /*  M3RR_ST
      E Створено
      P Передано
      V Отримано відповідь
      D Cкасовано
        M3SR_ST
      O Отримано
      D Cкасовано
    */
    -- максимальна кількість осіб у запиті PutPersonVpoAidInfo
    c_BatchSize   CONSTANT NUMBER (10) := 1000;
    c_Pt_Me_Id    CONSTANT NUMBER := 489;
    c_Pt_Rn_Id    CONSTANT NUMBER := 490;
    c_Pt_Res_Dt   CONSTANT NUMBER := 491;

    -- процедура підготовки даних
    PROCEDURE prepare_me_rows (p_me_id mass_exchanges.me_id%TYPE)
    IS
        l_me_tp      mass_exchanges.me_tp%TYPE;
        l_me_month   mass_exchanges.me_month%TYPE;
        l_cnt        PLS_INTEGER;
        l_Rn_Id      ikis_rbm.v_request_journal.rn_id%TYPE;
    BEGIN
        SELECT me_tp, me_month
          INTO l_me_tp, l_me_month
          FROM mass_exchanges
         WHERE me_id = p_me_id;

        IF l_me_tp = 'PFU_51'
        THEN
            INSERT INTO me_332vpo_request_rows (m3rr_me,
                                                m3rr_sc,
                                                m3rr_req_id,
                                                m3rr_ip_unique,
                                                m3rr_ln,
                                                m3rr_fn,
                                                m3rr_mn,
                                                m3rr_unzr,
                                                m3rr_numident,
                                                m3rr_doc_tp,
                                                m3rr_doc_sn,
                                                m3rr_birthday,
                                                m3rr_pppr_dt,
                                                m3rr_accr_dt,
                                                m3rr_req_tp,
                                                m3rr_st)
                SELECT p_me_id,
                       t.sc_id,
                       NULL,
                       t.ip_unique,
                       t."Ln",
                       t.fn,
                       t.mn,
                       t.unzr,
                       t.numident,
                       t.doc_tp,
                       t.doc_sn,
                       t.birthday,
                       ADD_MONTHS (TRUNC (l_me_month, 'MM'), -3),
                       ADD_MONTHS (TRUNC (l_me_month, 'MM'), -1),
                       '5.1',
                       'E'
                  FROM (WITH
                            prs
                            AS   -- source: API$PD_OPERATIONS.Prepare_S_VPO_51
                                (  SELECT pdf_sc     sc
                                     FROM pd_family  mf,
                                          pc_decision md,
                                          pc_account,
                                          appeal
                                    WHERE     pdf_pd = pd_id
                                          AND pd_pa = pa_id
                                          AND pd_ap = ap_id
                                          AND ap_reg_dt BETWEEN ADD_MONTHS (
                                                                    TRUNC (
                                                                        l_me_month,
                                                                        'MM'),
                                                                    -3)
                                                            AND   ADD_MONTHS (
                                                                      TRUNC (
                                                                          l_me_month,
                                                                          'MM'),
                                                                      -2)
                                                                - 1
                                          AND pd_st = 'S'
                                          AND pd_nst = 664
                                          AND pd_stop_dt >=
                                              TRUNC (l_me_month, 'MM')
                                          AND NOT EXISTS
                                                  (SELECT 1
                                                     FROM pc_decision ed,
                                                          pd_family  ef
                                                    WHERE     ef.pdf_pd =
                                                              ed.pd_id
                                                          AND ed.pd_nst = 664
                                                          AND ef.pdf_sc =
                                                              mf.pdf_sc
                                                          AND ed.pd_start_dt <
                                                              md.pd_start_dt)
                                 GROUP BY pdf_sc)
                        SELECT o.sco_id                     AS Sc_id,
                               NULL                         AS Ip_Unique -- o.sco_unique не передаємо. Див: #100872-note27
                                                                        ,
                               NULL                         AS Ip_Pt,
                               o.sco_ln                     AS "Ln",
                               o.sco_fn                     AS Fn,
                               o.sco_mn                     AS Mn,
                               NULL                         AS Unzr,
                               o.sco_numident               AS Numident,
                               (  SELECT d.scd_ndt
                                    FROM uss_person.v_sc_document d
                                         JOIN USS_NDI.v_ndi_document_type dt
                                             ON d.scd_ndt = dt.ndt_id
                                   WHERE     d.scd_sc = o.sco_id
                                         AND dt.ndt_ndc = 13
                                         AND d.scd_st = '1'
                                ORDER BY d.scd_ndt, d.scd_id ASC
                                   FETCH FIRST ROW ONLY)    AS Doc_Tp,
                               (  SELECT d.scd_seria || d.scd_number
                                    FROM uss_person.v_sc_document d
                                         JOIN USS_NDI.v_ndi_document_type dt
                                             ON d.scd_ndt = dt.ndt_id
                                   WHERE     d.scd_sc = o.sco_id
                                         AND dt.ndt_ndc = 13
                                         AND d.scd_st = '1'
                                ORDER BY d.scd_ndt, d.scd_id ASC
                                   FETCH FIRST ROW ONLY)    AS Doc_Sn,
                               CASE o.sco_nationality
                                   WHEN 'громадянин України' THEN 1
                                   WHEN 'Не визначено' THEN NULL
                                   ELSE NULL
                               END                          AS Nt --1 –Громадянин України, 0 – Не громадянин України 2 – особа без громадянства
                                                                 ,
                               CASE o.sco_gender
                                   WHEN 'Чоловіча' THEN 1
                                   WHEN 'Жіноча' THEN 2
                                   ELSE NULL
                               END                          AS Sex --0 – Жінка, 1 – Чоловік
                                                                  ,
                               o.sco_birth_dt               AS Birthday
                          FROM prs
                               JOIN uss_person.v_sc_info o
                                   ON prs.sc = o.sco_id) t;
        ELSIF l_me_tp = 'PFU_131'
        THEN
            INSERT INTO me_332vpo_request_rows (m3rr_me,
                                                m3rr_sc,
                                                m3rr_req_id,
                                                m3rr_ip_unique,
                                                m3rr_ln,
                                                m3rr_fn,
                                                m3rr_mn,
                                                m3rr_unzr,
                                                m3rr_numident,
                                                m3rr_doc_tp,
                                                m3rr_doc_sn,
                                                m3rr_birthday,
                                                m3rr_pppr_dt,
                                                m3rr_accr_dt,
                                                m3rr_req_tp,
                                                m3rr_st)
                SELECT p_me_id,
                       t.sc_id,
                       NULL,
                       t.ip_unique,
                       t."Ln",
                       t.fn,
                       t.mn,
                       t.unzr,
                       t.numident,
                       t.doc_tp,
                       t.doc_sn,
                       t.birthday,
                       NULL,
                       ADD_MONTHS (TRUNC (l_me_month, 'MM'), -1),
                       '13.1',
                       'E'
                  FROM (WITH
                            prs
                            AS  -- source: API$PD_OPERATIONS.Prepare_S_VPO_131
                                (  SELECT pdf_sc     sc
                                     FROM pd_family  mf,
                                          pc_decision md,
                                          pc_account
                                    WHERE     pdf_pd = pd_id
                                          AND pd_pa = pa_id
                                          AND pd_st = 'S'
                                          AND pd_nst = 664
                                          AND (   (    pd_stop_dt =
                                                         TRUNC (l_me_month,
                                                                'MM')
                                                       - 1 --Діють на останній день що передує розрахунковому місяцю
                                                   AND NOT EXISTS
                                                           (SELECT 1
                                                              FROM pc_decision
                                                                   ed,
                                                                   pd_family ef
                                                             WHERE     ef.pdf_pd =
                                                                       ed.pd_id
                                                                   AND ed.pd_nst =
                                                                       664
                                                                   AND ef.pdf_sc =
                                                                       mf.pdf_sc
                                                                   AND ed.pd_stop_dt >=
                                                                       TRUNC (
                                                                           l_me_month,
                                                                           'MM')))
                                               OR (    pd_stop_dt =
                                                         ADD_MONTHS (
                                                             TRUNC (l_me_month,
                                                                    'MM'),
                                                             6)
                                                       - 1
                                                   AND NOT EXISTS
                                                           (SELECT 1 --немає інших рішень
                                                              FROM pc_decision
                                                                   ed,
                                                                   pd_family ef
                                                             WHERE     ef.pdf_pd =
                                                                       ed.pd_id
                                                                   AND ed.pd_nst =
                                                                       664
                                                                   AND ef.pdf_sc =
                                                                       mf.pdf_sc
                                                                   AND ed.pd_stop_dt >=
                                                                       TRUNC (
                                                                           l_me_month,
                                                                           'MM')
                                                                   AND ed.pd_id <>
                                                                       md.pd_id)
                                                   AND EXISTS
                                                           (SELECT 1
                                                              FROM pd_family
                                                                   chk --Перевіряємо не осіб-кандидатів, а "всіх осіб в рішення" - аби в результуючі кандидати попали всі особи рішення, а не тільки ті, що підходять під наступні умови
                                                             WHERE     chk.pdf_pd =
                                                                       pd_id
                                                                   AND EXISTS
                                                                           (SELECT 1 --Є сума, з розподілом, по особі в попередньому місяці
                                                                              FROM pd_payment
                                                                                       pdp,
                                                                                   pd_detail
                                                                             WHERE     pdp.history_status =
                                                                                       'A'
                                                                                   AND pdp_pd =
                                                                                       pd_id
                                                                                   AND pdd_pdp =
                                                                                       pdp_id
                                                                                   AND pdp_stop_dt =
                                                                                         TRUNC (
                                                                                             l_me_month,
                                                                                             'MM')
                                                                                       - 1
                                                                                   AND pdd_key =
                                                                                       chk.pdf_id
                                                                                   AND pdd_ndp IN
                                                                                           (290,
                                                                                            300)
                                                                                   AND pdd_value >
                                                                                       0)
                                                                   AND NOT EXISTS
                                                                           (SELECT 1 --Немає суми, з розподілом, по особі в поточному місяці (тобто - по особі не нарахували)
                                                                              FROM pd_payment
                                                                                       pdp,
                                                                                   pd_detail
                                                                             WHERE     pdp.history_status =
                                                                                       'A'
                                                                                   AND pdp_pd =
                                                                                       pd_id
                                                                                   AND pdd_pdp =
                                                                                       pdp_id
                                                                                   AND pdp_start_dt =
                                                                                       TRUNC (
                                                                                           l_me_month,
                                                                                           'MM')
                                                                                   AND pdd_key =
                                                                                       chk.pdf_id
                                                                                   AND pdd_ndp IN
                                                                                           (290,
                                                                                            300)
                                                                                   AND pdd_value >
                                                                                       0))))
                                 GROUP BY pdf_sc)
                        SELECT o.sco_id                     AS Sc_id,
                               NULL                         AS Ip_Unique -- o.sco_unique не передаємо. Див: #100872-note27
                                                                        ,
                               NULL                         AS Ip_Pt,
                               o.sco_ln                     AS "Ln",
                               o.sco_fn                     AS Fn,
                               o.sco_mn                     AS Mn,
                               NULL                         AS Unzr,
                               o.sco_numident               AS Numident,
                               (  SELECT d.scd_ndt
                                    FROM uss_person.v_sc_document d
                                         JOIN USS_NDI.v_ndi_document_type dt
                                             ON d.scd_ndt = dt.ndt_id
                                   WHERE     d.scd_sc = o.sco_id
                                         AND dt.ndt_ndc = 13
                                         AND d.scd_st = '1'
                                ORDER BY d.scd_ndt, d.scd_id ASC
                                   FETCH FIRST ROW ONLY)    AS Doc_Tp,
                               (  SELECT d.scd_seria || d.scd_number
                                    FROM uss_person.v_sc_document d
                                         JOIN USS_NDI.v_ndi_document_type dt
                                             ON d.scd_ndt = dt.ndt_id
                                   WHERE     d.scd_sc = o.sco_id
                                         AND dt.ndt_ndc = 13
                                         AND d.scd_st = '1'
                                ORDER BY d.scd_ndt, d.scd_id ASC
                                   FETCH FIRST ROW ONLY)    AS Doc_Sn,
                               CASE o.sco_nationality
                                   WHEN 'громадянин України' THEN 1
                                   WHEN 'Не визначено' THEN NULL
                                   ELSE NULL
                               END                          AS Nt --1 –Громадянин України, 0 – Не громадянин України 2 – особа без громадянства
                                                                 ,
                               CASE o.sco_gender
                                   WHEN 'Чоловіча' THEN 1
                                   WHEN 'Жіноча' THEN 2
                                   ELSE NULL
                               END                          AS Sex --0 – Жінка, 1 – Чоловік
                                                                  ,
                               o.sco_birth_dt               AS Birthday
                          FROM prs
                               JOIN uss_person.v_sc_info o
                                   ON prs.sc = o.sco_id) t;
        ELSIF l_me_tp = 'PFU_132'
        THEN
            INSERT INTO me_332vpo_request_rows (m3rr_me,
                                                m3rr_sc,
                                                m3rr_req_id,
                                                m3rr_ip_unique,
                                                m3rr_ln,
                                                m3rr_fn,
                                                m3rr_mn,
                                                m3rr_unzr,
                                                m3rr_numident,
                                                m3rr_doc_tp,
                                                m3rr_doc_sn,
                                                m3rr_birthday,
                                                m3rr_pppr_dt,
                                                m3rr_accr_dt,
                                                m3rr_req_tp,
                                                m3rr_st)
                SELECT p_me_id,
                       t.sc_id,
                       NULL,
                       t.ip_unique,
                       t."Ln",
                       t.fn,
                       t.mn,
                       t.unzr,
                       t.numident,
                       t.doc_tp,
                       t.doc_sn,
                       t.birthday,
                       ADD_MONTHS (TRUNC (l_me_month, 'MM'), -2),
                       ADD_MONTHS (TRUNC (l_me_month, 'MM'), -1),
                       '13.2',
                       'E'
                  FROM (WITH
                            prs
                            AS                           -- source: #100872-39
                                (  SELECT f.pdf_sc     sc
                                     FROM pc_decision d
                                          JOIN appeal a
                                              ON     d.pd_ap = a.ap_id
                                                 AND a.ap_reg_dt >=
                                                     TO_DATE ('01.03.2024',
                                                              'dd.mm.yyyy') -- #100872-42
                                          JOIN pd_log l
                                              ON     pdl_pd = d.pd_id
                                                 AND pdl_st = 'P'
                                          JOIN v_histsession h
                                              ON     h.hs_id = l.pdl_hs
                                                 AND hs_dt BETWEEN ADD_MONTHS (
                                                                       TRUNC (
                                                                           l_me_month,
                                                                           'MM'),
                                                                       -2)
                                                               AND   ADD_MONTHS (
                                                                         TRUNC (
                                                                             l_me_month,
                                                                             'MM'),
                                                                         -1)
                                                                   - 1
                                          JOIN pd_family f
                                              ON f.pdf_pd = d.pd_id
                                    -- JOIN uss_person.v_sc_info o ON f.pdf_sc = o.sco_id
                                    WHERE     pd_nst = 664
                                          AND FLOOR (
                                                    MONTHS_BETWEEN (
                                                        hs_dt,
                                                        f.pdf_birth_dt)
                                                  / 12) BETWEEN 18
                                                            AND 59 --віком від 18 років до 60 років
                                          AND (   EXISTS
                                                      (SELECT NULL --Мають право по коду 64
                                                         FROM pd_right_log rl
                                                              JOIN
                                                              uss_ndi.v_ndi_right_rule
                                                              rr
                                                                  ON rl.prl_nrr =
                                                                     rr.nrr_id
                                                        WHERE     rl.prl_pd =
                                                                  d.pd_id
                                                              AND rl.prl_result =
                                                                  'T'
                                                              AND rr.nrr_code =
                                                                  '64')
                                               OR NOT EXISTS
                                                      (SELECT NULL --Або не мають права по жодному з 3 кодів (63/64/65)
                                                         FROM pd_right_log rl
                                                              JOIN
                                                              uss_ndi.v_ndi_right_rule
                                                              rr
                                                                  ON rl.prl_nrr =
                                                                     rr.nrr_id
                                                        WHERE     prl_pd =
                                                                  d.pd_id
                                                              AND rl.prl_result =
                                                                  'T'
                                                              AND rr.nrr_code IN
                                                                      ('63',
                                                                       '64',
                                                                       '65')))
                                          AND EXISTS
                                                  (SELECT NULL -- Враховувати для аналіза тільки повторні рішення #100872-49
                                                     FROM pc_decision pre
                                                          JOIN pd_payment p
                                                              ON p.pdp_pd =
                                                                 pre.pd_id
                                                    WHERE     pre.pd_pc =
                                                              d.pd_pc
                                                          AND pre.pd_id !=
                                                              d.pd_id
                                                          AND pre.pd_nst =
                                                              d.pd_nst
                                                          AND p.pdp_start_dt <
                                                              h.hs_dt)
                                 GROUP BY f.pdf_sc)
                        SELECT o.sco_id                     AS Sc_id,
                               NULL                         AS Ip_Unique -- o.sco_unique не передаємо. Див: #100872-note27
                                                                        ,
                               NULL                         AS Ip_Pt,
                               o.sco_ln                     AS "Ln",
                               o.sco_fn                     AS Fn,
                               o.sco_mn                     AS Mn,
                               NULL                         AS Unzr,
                               o.sco_numident               AS Numident,
                               (  SELECT d.scd_ndt
                                    FROM uss_person.v_sc_document d
                                         JOIN USS_NDI.v_ndi_document_type dt
                                             ON d.scd_ndt = dt.ndt_id
                                   WHERE     d.scd_sc = o.sco_id
                                         AND dt.ndt_ndc = 13
                                         AND d.scd_st = '1'
                                ORDER BY d.scd_ndt, d.scd_id ASC
                                   FETCH FIRST ROW ONLY)    AS Doc_Tp,
                               (  SELECT d.scd_seria || d.scd_number
                                    FROM uss_person.v_sc_document d
                                         JOIN USS_NDI.v_ndi_document_type dt
                                             ON d.scd_ndt = dt.ndt_id
                                   WHERE     d.scd_sc = o.sco_id
                                         AND dt.ndt_ndc = 13
                                         AND d.scd_st = '1'
                                ORDER BY d.scd_ndt, d.scd_id ASC
                                   FETCH FIRST ROW ONLY)    AS Doc_Sn,
                               CASE o.sco_nationality
                                   WHEN 'громадянин України' THEN 1
                                   WHEN 'Не визначено' THEN NULL
                                   ELSE NULL
                               END                          AS Nt --1 –Громадянин України, 0 – Не громадянин України 2 – особа без громадянства
                                                                 ,
                               CASE o.sco_gender
                                   WHEN 'Чоловіча' THEN 1
                                   WHEN 'Жіноча' THEN 2
                                   ELSE NULL
                               END                          AS Sex --0 – Жінка, 1 – Чоловік
                                                                  ,
                               o.sco_birth_dt               AS Birthday
                          FROM prs
                               JOIN uss_person.v_sc_info o
                                   ON prs.sc = o.sco_id) t;
        ELSE
            Raise_application_error (-20000, 'Unkonwn Req Type:' || l_me_tp);
        END IF;

        l_cnt := SQL%ROWCOUNT;

        IF l_cnt = 0
        THEN
            UPDATE mass_exchanges
               SET me_st = 'E'                                     -- Створено
             WHERE me_id = p_me_id;
        ELSE
            UPDATE mass_exchanges
               SET me_count = l_cnt, me_st = 'R'        -- Готовий до передачі
             WHERE me_id = p_me_id;

            COMMIT;

            WHILE l_cnt > 0
            LOOP
                -- реєструєм новий запит:
                ikis_rbm.Api$request_Pfu.Reg_Put_Person_Vpo_Aid_Info_Req (
                    p_Me_Id       => p_me_id,
                    p_Rn_Nrt      => 82,
                    p_Rn_Hs_Ins   => NULL,
                    p_Rn_Src      => 'USS',
                    p_Ur_Ext_Id   => p_me_id,
                    p_Rn_Id       => l_Rn_Id);

                UPDATE me_332vpo_request_rows
                   SET m3rr_st = 'P'                               -- Передано
                                    , m3rr_req_id = l_Rn_Id
                 WHERE     m3rr_me = p_me_id
                       AND m3rr_req_id IS NULL
                       AND ROWNUM <= c_BatchSize;

                l_cnt := l_cnt - c_BatchSize;
                COMMIT;
            END LOOP;

            UPDATE mass_exchanges
               SET me_st = 'P'                 -- Передано в підсистему обміну
             WHERE me_id = p_me_id;
        END IF;
    --TOOLS.release_lock(g_lock);
    EXCEPTION
        WHEN OTHERS
        THEN
            --ROLLBACK;
            UPDATE mass_exchanges
               SET me_st = 'E'
             WHERE me_id = p_me_id;

            COMMIT;
            RAISE;
    END prepare_me_rows;

    PROCEDURE Process_PutPersonEmpPens_Req (p_Ur_Id     IN NUMBER,
                                            p_Request   IN CLOB)
    IS
        l_Req_Id   VARCHAR2 (100);
        l_Req_Rn   NUMBER (14);
        l_Res_Rn   NUMBER (14);
        l_Me_Id    NUMBER (14);
    BEGIN
        l_Req_Id :=
            Xmltype (p_Request).EXTRACT (
                '//PutPersonEmpPensReq/ReqId/text()').getStringVal ();

        IF l_Req_Id IS NULL
        THEN
            Raise_application_error (
                -20000,
                'Не вдалось отримати значення <ReqId></ReqId>!');
        END IF;

        l_Req_Rn := TO_NUMBER (l_Req_Id); -- фактично в <ReqId> приходить RN_ID але рахуємо, що він однаковий з UR_ID
        l_Me_Id :=
            ikis_rbm.Api$request.Get_Rn_Common_Info_Int (
                p_Rnc_Rn   => l_Req_Rn,
                p_Rnc_Pt   => c_Pt_Me_Id);

        -- l_Me_Id := ikis_rbm.Api$uxp_Request.Get_Request_Ext_Id(l_Req_Ur); -- можна і з UR_EXT_ID
        IF l_Me_Id IS NULL
        THEN
            Raise_application_error (
                -20000,
                   'Не вдалось визначити m3sr_me для Rn_Id: '
                || TO_CHAR (l_Req_Rn));
        END IF;

        INSERT INTO me_332vpo_result_rows (m3sr_me,
                                           m3sr_m3rr,
                                           m3sr_sc,
                                           m3sr_req_id,
                                           m3sr_result,
                                           m3sr_req_tp,
                                           m3sr_emp_mark,
                                           m3sr_start_dt,
                                           m3sr_pens_tp,
                                           m3sr_pens_sum,
                                           m3sr_dis_gr,
                                           m3sr_dis_dt,
                                           m3sr_dis_end_dt,
                                           m3sr_st)
            SELECT l_Me_Id,
                   TO_NUMBER (c.Pers_Id),
                   TO_NUMBER (c.ScId),
                   l_Req_Rn,
                   TO_NUMBER (c.Res),
                   c.ReqTp,
                   TO_NUMBER (c.EmpMark),
                   TO_DATE (c.StartDt, 'YYYY-MM-DD'),
                   TO_NUMBER (c.PensTp),
                   TO_NUMBER (c.PensSum, '99999999999999999.99'),
                   c.DisGr,
                   TO_DATE (c.DisDt, 'YYYY-MM-DD'),
                   TO_DATE (c.DisEndDt, 'YYYY-MM-DD'),
                   'O'
              FROM (     SELECT Pers_Id,
                                ScId,
                                Res,
                                ReqTp,
                                EmpMark,
                                StartDt,
                                PensTp,
                                PensSum,
                                DisGr,
                                DisDt,
                                DisEndDt                        --, rownum-1 i
                           FROM XMLTABLE (
                                    'PutPersonEmpPensReq/Persons/Person'
                                    PASSING Xmltype (p_Request)
                                    COLUMNS Pers_Id     VARCHAR2 (250) PATH 'id',
                                            ScId        VARCHAR2 (250) PATH 'ScId',
                                            Res         VARCHAR2 (250) PATH 'Result',
                                            ReqTp       VARCHAR2 (250) PATH 'ReqTp',
                                            EmpMark     VARCHAR2 (250) PATH 'EmpMark',
                                            StartDt     VARCHAR2 (250) PATH 'StartDt',
                                            PensTp      VARCHAR2 (250) PATH 'PensTp',
                                            PensSum     VARCHAR2 (250) PATH 'PensSum',
                                            DisGr       VARCHAR2 (250) PATH 'DisGr',
                                            DisDt       VARCHAR2 (250) PATH 'DisDt',
                                            DisEndDt    VARCHAR2 (250) PATH 'DisEndDt'))
                   c;

        --l_cnt := SQL%ROWCOUNT;
        IF SQL%ROWCOUNT > 0
        THEN
            UPDATE me_332vpo_request_rows r
               SET r.m3rr_st = 'V'                       -- Отримано відповідь
             -- select * from me_332vpo_request_rows r
             WHERE     r.m3rr_me = l_Me_Id
                   AND r.m3rr_req_id = l_Req_Rn
                   AND r.m3rr_st = 'P'
                   AND EXISTS
                           (SELECT NULL
                              FROM me_332vpo_result_rows s
                             WHERE     s.m3sr_st = 'O'
                                   AND s.m3sr_me = r.m3rr_me
                                   AND s.m3sr_m3rr = r.m3rr_id
                                   AND s.m3sr_req_id = r.m3rr_req_id
                                   AND s.m3sr_req_tp = r.m3rr_req_tp);

            IF SQL%ROWCOUNT > 0
            THEN
                UPDATE mass_exchanges
                   SET me_st = 'L'                        --Отримано відповідь
                 WHERE me_id = l_Me_Id;
            END IF;
        END IF;

        l_Res_Rn := ikis_rbm.api$uxp_request.Get_Ur_Rn (p_Ur_Id);
        -- зберігаємо Me_Id в журнал відповіді щоб полегшити відладку
        ikis_rbm.Api$request.Save_Rn_Common_Info (p_Rnc_Rn        => l_Res_Rn,
                                                  p_Rnc_Pt        => c_Pt_Me_Id,
                                                  p_Rnc_Val_Int   => l_Me_Id);
        --в журнал запиту зберігаємо дату і Ід відповіді
        ikis_rbm.Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => l_Req_Rn,
                                                  p_Rnc_Pt       => c_Pt_Res_Dt,
                                                  p_Rnc_Val_Dt   => SYSDATE);
        ikis_rbm.Api$request.Save_Rn_Common_Info (p_Rnc_Rn        => l_Req_Rn,
                                                  p_Rnc_Pt        => c_Pt_Rn_Id,
                                                  p_Rnc_Val_Int   => l_Res_Rn);
    END Process_PutPersonEmpPens_Req;
BEGIN
    NULL;
END API$MASS_EXCHANGE_PFU;
/